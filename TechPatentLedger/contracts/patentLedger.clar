;; TechPatentLedger - Intellectual Property Platform
;; A decentralized platform for patent applications and prior art documentation

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-already-exists (err u103))
(define-constant err-invalid-status (err u104))

;; Data Variables
(define-data-var patent-nonce uint u0)
(define-data-var prior-art-nonce uint u0)

;; Patent Status Types
(define-constant status-pending u1)
(define-constant status-under-review u2)
(define-constant status-approved u3)
(define-constant status-rejected u4)

;; Data Maps
(define-map patents
  { patent-id: uint }
  {
    inventor: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    documentation-hash: (string-ascii 64),
    filing-date: uint,
    status: uint,
    reviewer: (optional principal)
  }
)

(define-map prior-art
  { art-id: uint }
  {
    submitter: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    documentation-hash: (string-ascii 64),
    submission-date: uint,
    related-patent-id: (optional uint)
  }
)

(define-map inventor-patents
  { inventor: principal, patent-id: uint }
  { exists: bool }
)

(define-map patent-prior-art
  { patent-id: uint, art-id: uint }
  { exists: bool }
)

;; Read-Only Functions

(define-read-only (get-patent (patent-id uint))
  (map-get? patents { patent-id: patent-id })
)

(define-read-only (get-prior-art (art-id uint))
  (map-get? prior-art { art-id: art-id })
)

(define-read-only (get-patent-count)
  (var-get patent-nonce)
)

(define-read-only (get-prior-art-count)
  (var-get prior-art-nonce)
)

(define-read-only (is-inventor-patent (inventor principal) (patent-id uint))
  (default-to false 
    (get exists (map-get? inventor-patents { inventor: inventor, patent-id: patent-id }))
  )
)

(define-read-only (is-art-linked-to-patent (patent-id uint) (art-id uint))
  (default-to false
    (get exists (map-get? patent-prior-art { patent-id: patent-id, art-id: art-id }))
  )
)

;; Public Functions

(define-public (register-patent 
  (title (string-ascii 100))
  (description (string-ascii 500))
  (documentation-hash (string-ascii 64))
)
  (let
    (
      (new-patent-id (+ (var-get patent-nonce) u1))
      (current-block stacks-block-height)
    )
    (map-set patents
      { patent-id: new-patent-id }
      {
        inventor: tx-sender,
        title: title,
        description: description,
        documentation-hash: documentation-hash,
        filing-date: current-block,
        status: status-pending,
        reviewer: none
      }
    )
    (map-set inventor-patents
      { inventor: tx-sender, patent-id: new-patent-id }
      { exists: true }
    )
    (var-set patent-nonce new-patent-id)
    (ok new-patent-id)
  )
)

(define-public (submit-prior-art
  (title (string-ascii 100))
  (description (string-ascii 500))
  (documentation-hash (string-ascii 64))
  (related-patent-id (optional uint))
)
  (let
    (
      (new-art-id (+ (var-get prior-art-nonce) u1))
      (current-block stacks-block-height)
    )
    (map-set prior-art
      { art-id: new-art-id }
      {
        submitter: tx-sender,
        title: title,
        description: description,
        documentation-hash: documentation-hash,
        submission-date: current-block,
        related-patent-id: related-patent-id
      }
    )
    (match related-patent-id
      patent-id
        (map-set patent-prior-art
          { patent-id: patent-id, art-id: new-art-id }
          { exists: true }
        )
      true
    )
    (var-set prior-art-nonce new-art-id)
    (ok new-art-id)
  )
)

(define-public (update-patent-status
  (patent-id uint)
  (new-status uint)
)
  (let
    (
      (patent-data (unwrap! (get-patent patent-id) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (or 
      (is-eq new-status status-pending)
      (is-eq new-status status-under-review)
      (is-eq new-status status-approved)
      (is-eq new-status status-rejected)
    ) err-invalid-status)
    (map-set patents
      { patent-id: patent-id }
      (merge patent-data { 
        status: new-status,
        reviewer: (some tx-sender)
      })
    )
    (ok true)
  )
)

(define-public (update-patent-details
  (patent-id uint)
  (new-description (string-ascii 500))
  (new-documentation-hash (string-ascii 64))
)
  (let
    (
      (patent-data (unwrap! (get-patent patent-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get inventor patent-data)) err-unauthorized)
    (asserts! (is-eq (get status patent-data) status-pending) err-invalid-status)
    (map-set patents
      { patent-id: patent-id }
      (merge patent-data {
        description: new-description,
        documentation-hash: new-documentation-hash
      })
    )
    (ok true)
  )
)

(define-public (link-prior-art-to-patent
  (patent-id uint)
  (art-id uint)
)
  (begin
    (asserts! (is-some (get-patent patent-id)) err-not-found)
    (asserts! (is-some (get-prior-art art-id)) err-not-found)
    (asserts! (not (is-art-linked-to-patent patent-id art-id)) err-already-exists)
    (map-set patent-prior-art
      { patent-id: patent-id, art-id: art-id }
      { exists: true }
    )
    (ok true)
  )
)