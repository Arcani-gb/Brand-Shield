# Brand Shield Smart Contract

**AI-Powered Trademark Monitoring with Automated Enforcement on Stacks Blockchain**

Brand Shield is a comprehensive smart contract solution that enables trademark owners to register their brands and leverage AI-powered monitoring for automated trademark violation detection and enforcement on the Stacks blockchain.

## Features

- **Trademark Registration**: Secure on-chain registration of brand trademarks
- **AI-Powered Monitoring**: Automated detection of trademark violations across digital platforms
- **Violation Reporting**: Confidence-scored violation detection with detailed logging
- **Automated Enforcement**: Streamlined enforcement actions with complete audit trails
- **Reputation System**: Quality control for AI monitoring nodes
- **Fee-Based Protection**: Economic incentives for maintaining high-quality monitoring

## Contract Architecture

### Core Components

1. **Trademark Registry**: On-chain storage of trademark information and ownership
2. **AI Monitor Network**: Decentralized network of AI-powered monitoring nodes
3. **Violation Detection**: Automated reporting system with confidence scoring
4. **Enforcement Engine**: Streamlined violation enforcement with fee structure
5. **Reputation System**: Quality assurance for monitoring node performance

### Data Structures

- `trademarks`: Maps trademark IDs to detailed registration information
- `violations`: Stores violation reports with status tracking
- `ai-monitors`: Manages AI monitoring nodes and their reputation scores
- `user-trademarks`: Quick lookup for trademark ownership verification

## Getting Started

### Prerequisites

- Stacks blockchain node or testnet access
- Clarinet CLI for local development
- STX tokens for transaction fees

### Deployment

1. Clone the repository:
```bash
git clone <repository-url>
cd Brand-Shield
```

2. Install Clarinet (if not already installed):
```bash
curl -L https://github.com/hirosystems/clarinet/releases/download/v1.8.0/clarinet-linux-x64.tar.gz | tar xz
```

3. Check contract syntax:
```bash
clarinet check
```

4. Run tests:
```bash
clarinet test
```

5. Deploy to testnet:
```bash
clarinet deploy --network testnet
```

## Usage Guide

### For Trademark Owners

#### 1. Register a Trademark

```clarity
(contract-call? .brand-shield register-trademark 
  "YourBrandName" 
  "Description of your trademark" 
  "Technology")
```

**Cost**: 1 STX registration fee
**Returns**: Unique trademark ID

#### 2. Activate Monitoring

```clarity
(contract-call? .brand-shield activate-monitoring 
  u1          ;; trademark-id
  u4320)      ;; duration in blocks (approximately 30 days)
```

**Cost**: 0.5 STX per month (calculated based on duration)
**Effect**: Enables AI monitoring for the specified period

#### 3. Enforce Violations

```clarity
(contract-call? .brand-shield enforce-violation u1) ;; violation-id
```

**Cost**: 2 STX enforcement fee
**Effect**: Takes enforcement action against confirmed violation

#### 4. Dismiss False Positives

```clarity
(contract-call? .brand-shield dismiss-violation u1) ;; violation-id
```

**Cost**: Free
**Effect**: Marks violation as false positive, improving AI accuracy

### For AI Monitoring Nodes

#### 1. Register as Monitor

```clarity
(contract-call? .brand-shield register-ai-monitor)
```

**Requirements**: None
**Effect**: Enables violation reporting capabilities

#### 2. Report Violations

```clarity
(contract-call? .brand-shield report-violation 
  u1                           ;; trademark-id
  "https://violating-site.com" ;; detected-url
  "Domain Squatting"           ;; violation-type
  u85)                         ;; confidence-score (0-100)
```

**Requirements**: Active monitor status and valid trademark monitoring
**Effect**: Creates violation report for trademark owner review

## Contract Functions

### Public Functions

| Function | Description | Fee | Access |
|----------|-------------|-----|---------|
| `register-trademark` | Register new trademark | 1 STX | Anyone |
| `activate-monitoring` | Enable AI monitoring | 0.5 STX/month | Trademark owners |
| `register-ai-monitor` | Register as AI monitor | Free | Anyone |
| `report-violation` | Report trademark violation | Free | AI monitors |
| `enforce-violation` | Take enforcement action | 2 STX | Trademark owners |
| `dismiss-violation` | Dismiss false positive | Free | Trademark owners |

### Read-Only Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `get-trademark` | Get trademark details | Trademark info or none |
| `get-violation` | Get violation details | Violation info or none |
| `get-ai-monitor` | Get monitor information | Monitor stats or none |
| `owns-trademark` | Check trademark ownership | Boolean |
| `get-contract-stats` | Get contract statistics | Stats object |
| `get-monitoring-status` | Check monitoring status | Status info |

### Admin Functions

| Function | Description | Access |
|----------|-------------|---------|
| `set-contract-owner` | Update contract owner | Contract owner only |
| `deactivate-monitor` | Disable AI monitor | Contract owner only |
| `emergency-pause` | Emergency contract pause | Contract owner only |

## Fee Structure

- **Registration Fee**: 1 STX per trademark
- **Monitoring Fee**: 0.5 STX per month (prorated by blocks)
- **Enforcement Fee**: 2 STX per enforcement action
- **False Positive Dismissal**: Free

## Error Codes

- `u100`: Unauthorized access
- `u101`: Trademark already exists
- `u102`: Trademark not found
- `u103`: Insufficient payment
- `u104`: Invalid status
- `u105`: Already processed

## Security Considerations

### Access Control
- Trademark owners have exclusive control over their registrations
- AI monitors must be registered before reporting violations
- Admin functions restricted to contract owner

### Economic Security
- Fee structure prevents spam and ensures quality
- Reputation system for AI monitors discourages false reporting
- Economic incentives align with network security

### Data Integrity
- Immutable trademark registration with block height timestamps
- Complete violation audit trail
- Ownership verification for all sensitive operations

## AI Monitor Integration

### Requirements for AI Monitors

1. **Registration**: Must call `register-ai-monitor` before reporting
2. **Active Monitoring**: Only report violations for actively monitored trademarks
3. **Confidence Scoring**: Provide realistic confidence scores (0-100)
4. **Quality Standards**: Maintain good reputation through accurate reporting

### Reputation System

- **Starting Reputation**: 50/100 (neutral)
- **Reputation Factors**: 
  - Accuracy of violation reports
  - False positive rate
  - Total violations reported
- **Consequences**: Poor reputation may lead to deactivation

## Development and Testing

### Local Development

```bash
# Check contract
clarinet check

# Run unit tests
clarinet test

# Interactive console
clarinet console
```

### Test Coverage

The contract includes comprehensive tests for:
- Trademark registration and ownership
- Monitoring activation and expiration
- Violation reporting and enforcement
- AI monitor reputation system
- Fee calculations and transfers
- Error conditions and edge cases

## Future Enhancements

- **Multi-chain Support**: Expand to other blockchain networks
- **Advanced AI Integration**: More sophisticated violation detection algorithms
- **Automated Enforcement**: Direct integration with domain registrars and platforms
- **Insurance Integration**: Trademark protection insurance products
- **Analytics Dashboard**: Real-time monitoring and enforcement statistics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request with detailed description

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For technical support or questions:
- Create an issue in the GitHub repository
- Join our Discord community
- Review the documentation at [docs link]

## Acknowledgments

- Stacks Foundation for blockchain infrastructure
- Clarity language development team
- Open source contributors and community
