# TechPatentLedger

A decentralized Intellectual Property platform built on the Stacks blockchain using Clarity smart contracts. TechPatentLedger enables inventors to register patent applications and submit prior art documentation in a transparent, immutable ledger.

## Overview

TechPatentLedger provides a blockchain-based solution for managing patent applications and prior art submissions. All records are permanently stored on-chain, ensuring transparency, tamper-proof documentation, and verifiable timestamps for intellectual property claims.

## Features

- **Patent Registration**: Inventors can file patent applications with detailed documentation
- **Prior Art Submission**: Community members can submit prior art relevant to patents
- **Status Management**: Administrative control over patent application reviews
- **Immutable Records**: All filings are permanently recorded with blockchain timestamps
- **Transparent History**: Full audit trail of all patent and prior art submissions
- **Decentralized Access**: Anyone can view registered patents and prior art

## Smart Contract Functions

### Public Functions

#### `register-patent`
Allows inventors to register a new patent application.

**Parameters:**
- `title` (string-ascii 100): Patent title
- `description` (string-ascii 500): Detailed description of the invention
- `documentation-hash` (string-ascii 64): Hash of supporting documentation (e.g., IPFS hash)

**Returns:** Patent ID (uint)

**Example:**
```clarity
(contract-call? .tech-patent-ledger register-patent 
  "AI-Powered Widget"
  "An innovative widget that uses artificial intelligence to optimize performance..."
  "QmX4H5YT9ZK8mN3P2R1V6W7...")
```

#### `submit-prior-art`
Submit prior art documentation, optionally linking it to an existing patent.

**Parameters:**
- `title` (string-ascii 100): Prior art title
- `description` (string-ascii 500): Description of the prior art
- `documentation-hash` (string-ascii 64): Hash of supporting documentation
- `related-patent-id` (optional uint): ID of related patent (if applicable)

**Returns:** Prior art ID (uint)

**Example:**
```clarity
(contract-call? .tech-patent-ledger submit-prior-art
  "Similar Widget Design from 2020"
  "A widget design that shares similarities with patent #5..."
  "QmY5J6ZU0AL9nO4Q3S2W7X8..."
  (some u5))
```

#### `update-patent-status`
Updates the status of a patent application (contract owner only).

**Parameters:**
- `patent-id` (uint): ID of the patent to update
- `new-status` (uint): New status code (1=Pending, 2=Under Review, 3=Approved, 4=Rejected)

**Returns:** Boolean success

**Example:**
```clarity
(contract-call? .tech-patent-ledger update-patent-status u1 u3)
```

#### `update-patent-details`
Allows inventors to update their patent details while in pending status.

**Parameters:**
- `patent-id` (uint): ID of the patent to update
- `new-description` (string-ascii 500): Updated description
- `new-documentation-hash` (string-ascii 64): Updated documentation hash

**Returns:** Boolean success

#### `link-prior-art-to-patent`
Creates an association between prior art and a patent.

**Parameters:**
- `patent-id` (uint): Patent ID
- `art-id` (uint): Prior art ID

**Returns:** Boolean success

### Read-Only Functions

#### `get-patent`
Retrieves complete patent information.

**Parameters:**
- `patent-id` (uint): Patent ID

**Returns:** Patent details or none

#### `get-prior-art`
Retrieves complete prior art information.

**Parameters:**
- `art-id` (uint): Prior art ID

**Returns:** Prior art details or none

#### `get-patent-count`
Returns the total number of registered patents.

**Returns:** uint

#### `get-prior-art-count`
Returns the total number of submitted prior art entries.

**Returns:** uint

#### `is-inventor-patent`
Checks if a specific principal is the inventor of a patent.

**Parameters:**
- `inventor` (principal): Address to check
- `patent-id` (uint): Patent ID

**Returns:** Boolean

#### `is-art-linked-to-patent`
Checks if prior art is linked to a specific patent.

**Parameters:**
- `patent-id` (uint): Patent ID
- `art-id` (uint): Prior art ID

**Returns:** Boolean

## Patent Status Codes

- `1` - **Pending**: Initial status upon registration
- `2` - **Under Review**: Patent is being examined
- `3` - **Approved**: Patent has been approved
- `4` - **Rejected**: Patent application was rejected

## Data Structures

### Patent Record
```clarity
{
  inventor: principal,
  title: (string-ascii 100),
  description: (string-ascii 500),
  documentation-hash: (string-ascii 64),
  filing-date: uint,
  status: uint,
  reviewer: (optional principal)
}
```

### Prior Art Record
```clarity
{
  submitter: principal,
  title: (string-ascii 100),
  description: (string-ascii 500),
  documentation-hash: (string-ascii 64),
  submission-date: uint,
  related-patent-id: (optional uint)
}
```

## Error Codes

- `u100` - Owner only: Action requires contract owner privileges
- `u101` - Not found: Requested patent or prior art does not exist
- `u102` - Unauthorized: Caller lacks permission for this action
- `u103` - Already exists: Resource already exists
- `u104` - Invalid status: Invalid status code provided

## Deployment

1. Install Clarinet: https://github.com/hirosystems/clarinet
2. Create a new Clarinet project or add to existing one
3. Place the contract in `contracts/tech-patent-ledger.clar`
4. Deploy using Clarinet:
```bash
clarinet deploy
```

## Usage Examples

### Registering a Patent
```clarity
;; Register a new patent
(contract-call? .tech-patent-ledger register-patent 
  "Quantum Computing Algorithm"
  "A novel algorithm for optimizing quantum gate operations..."
  "QmHash123...")
```

### Submitting Prior Art
```clarity
;; Submit prior art related to patent #3
(contract-call? .tech-patent-ledger submit-prior-art
  "Previous Research Paper"
  "Academic paper from 2019 describing similar concepts..."
  "QmHash456..."
  (some u3))
```

### Checking Patent Status
```clarity
;; Retrieve patent information
(contract-call? .tech-patent-ledger get-patent u1)
```

## Best Practices

1. **Documentation Hashes**: Store full documentation on IPFS or similar decentralized storage, and only store the hash on-chain
2. **Detailed Descriptions**: Provide comprehensive descriptions within the character limits
3. **Prior Art Research**: Submit relevant prior art to maintain transparency
4. **Status Updates**: Regularly check patent status after submission
5. **Backup Records**: Keep off-chain backups of all documentation

## Security Considerations

- Only the contract owner can update patent statuses
- Inventors can only update their own patents while in pending status
- All submissions are immutable once recorded
- Patent ownership is tracked and verifiable on-chain

## License

This smart contract is provided as-is for educational and commercial use.

## Contributing

Contributions are welcome! Please ensure all code is tested with Clarinet before submitting pull requests.

## Support

For issues or questions, please open an issue on the project repository.