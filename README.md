# Decentralized Social Network Smart Contract

A sophisticated, privacy-focused social networking protocol built on Stacks Layer 2, providing Bitcoin-level security guarantees with advanced scalability features.

## Overview

This smart contract implements a decentralized social networking platform with emphasis on privacy, security, and scalability. Built on Stacks Layer 2, it leverages Bitcoin's security while providing fast and efficient social interactions.

## Features

### User Management

- **Profile System**: Customizable user profiles with encrypted metadata support
- **Privacy Controls**: Granular privacy settings for each aspect of user data
- **Activity Tracking**: Secure logging of user interactions and logins
- **Deactivation Support**: Temporary or permanent account deactivation

### Social Interactions

- **Friendship System**: Two-way friendship connections with status tracking
- **Blocking Mechanism**: User blocking with timestamp tracking
- **Privacy-Preserving Relationships**: Configurable visibility of social connections

### Security & Privacy

- **Encryption Support**: Optional encryption for sensitive metadata
- **Granular Privacy Settings**:
  - Friend list visibility
  - Status visibility
  - Metadata visibility
  - Last seen visibility
  - Profile image visibility
  - Encryption settings

### Rate Limiting & Protection

- **Dynamic Rate Limits**:
  - Daily action limits: 100 actions per day
  - Friend request limits: 20 requests per day
  - Status update limits: 24 updates per day
- **Automatic Reset**: 24-hour reset period for all rate limits

### Batch Processing

- **Dynamic Batch Sizing**:
  - Minimum batch size: 10
  - Maximum batch size: 100
  - Auto-optimization based on usage patterns
- **Expiry Management**: 1-hour expiry period for batches
- **Size Optimization**: Automatic batch size adjustments based on usage

## Data Structures

### Users Map

```clarity
{
    name: (string-ascii 64),
    status: uint,
    timestamp: uint,
    metadata: (optional (string-utf8 256)),
    deactivation-time: (optional uint),
    encryption-key: (optional (buff 32)),
    profile-image: (optional (string-utf8 256))
}
```

### Privacy Settings

```clarity
{
    friend-list-visible: bool,
    status-visible: bool,
    metadata-visible: bool,
    last-seen-visible: bool,
    profile-image-visible: bool,
    encryption-enabled: bool,
    last-updated: uint
}
```

### Rate Limits

```clarity
{
    daily-actions: uint,
    friend-requests: uint,
    status-updates: uint,
    last-reset: uint
}
```

## Public Functions

### Profile Management

- `update-user-profile`: Update user profile information
- `update-advanced-privacy-settings`: Configure privacy settings
- `record-login`: Record user login activity

### Batch Management

- `set-batch-size`: Configure batch processing size
- `optimize-batch-size`: Automatically optimize batch processing

## Error Codes

| Code | Description    |
| ---- | -------------- |
| u100 | Not Found      |
| u101 | Already Exists |
| u102 | Unauthorized   |
| u103 | Invalid Input  |
| u104 | Blocked        |
| u105 | Deactivated    |
| u106 | Rate Limited   |
| u107 | Batch Full     |
| u108 | Batch Expired  |

## Status Constants

### User Status

- `STATUS_DEACTIVATED` (0): Account is deactivated
- `STATUS_ACTIVE` (1): Account is active
- `STATUS_SUSPENDED` (2): Account is suspended

### Friendship Status

- `FRIENDSHIP_PENDING` (0): Friend request pending
- `FRIENDSHIP_ACTIVE` (1): Active friendship
- `FRIENDSHIP_BLOCKED` (2): Blocked relationship

## Security Considerations

1. **Rate Limiting**

   - Implements tiered rate limiting for different actions
   - Automatic reset after 24 hours
   - Protection against spam and abuse

2. **Privacy Protection**

   - Granular privacy controls
   - Optional encryption for sensitive data
   - Visibility controls for all user data

3. **Activity Monitoring**
   - Tracks user actions for security
   - Monitors login patterns
   - Records batch processing statistics

## Best Practices for Integration

1. **Rate Limit Handling**

   - Implement client-side rate limit tracking
   - Add exponential backoff for rate limit errors
   - Cache rate limit status locally

2. **Batch Processing**

   - Start with minimum batch size
   - Allow automatic optimization
   - Monitor batch expiry times

3. **Privacy Implementation**
   - Default to most private settings
   - Implement proper encryption handling
   - Respect user privacy preferences
