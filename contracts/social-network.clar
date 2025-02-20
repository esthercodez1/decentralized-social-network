;; Decentralized Social Network - Stacks Layer 2 Smart Contract
;;
;; A robust, privacy-focused social networking protocol built on Stacks Layer 2
;; with Bitcoin-level security guarantees and advanced rate limiting mechanisms.
;;
;; Features:
;; - Privacy-preserving user relationships and content management
;; - Optimized batch processing for L2 scalability
;; - Rate limiting with automatic adjustments
;; - Encrypted metadata support for enhanced privacy
;; - Bitcoin-compliant activity tracking and verification
;; - Advanced friendship and blocking mechanisms
;;
;; Security:
;; - Implements comprehensive rate limiting
;; - Privacy-first design with granular controls
;; - Robust error handling and input validation
;; - Activity monitoring for fraud prevention

;; Error codes
(define-constant ERR_NOT_FOUND (err u100))
(define-constant ERR_ALREADY_EXISTS (err u101))
(define-constant ERR_UNAUTHORIZED (err u102))
(define-constant ERR_INVALID_INPUT (err u103))
(define-constant ERR_BLOCKED (err u104))
(define-constant ERR_DEACTIVATED (err u105))
(define-constant ERR_RATE_LIMITED (err u106))
(define-constant ERR_BATCH_FULL (err u107))
(define-constant ERR_BATCH_EXPIRED (err u108))

;; Constants
(define-constant STATUS_DEACTIVATED u0)
(define-constant STATUS_ACTIVE u1)
(define-constant STATUS_SUSPENDED u2)

(define-constant FRIENDSHIP_PENDING u0)
(define-constant FRIENDSHIP_ACTIVE u1)
(define-constant FRIENDSHIP_BLOCKED u2)

;; Rate limiting constants
(define-constant MAX_ACTIONS_PER_DAY u100)
(define-constant MAX_FRIEND_REQUESTS_PER_DAY u20)
(define-constant MAX_STATUS_UPDATES_PER_DAY u24)
(define-constant RATE_LIMIT_RESET_PERIOD u86400) ;; 24 hours in seconds

;; Batch processing constants
(define-constant MIN_BATCH_SIZE u10)
(define-constant MAX_BATCH_SIZE u100)
(define-constant BATCH_EXPIRY_PERIOD u3600) ;; 1 hour in seconds

;; Data structures
(define-map Users 
    principal 
    {
        name: (string-ascii 64),
        status: uint,
        timestamp: uint,
        metadata: (optional (string-utf8 256)),
        deactivation-time: (optional uint),
        encryption-key: (optional (buff 32)),
        profile-image: (optional (string-utf8 256))
    }
)

(define-map UserPrivacy
    principal
    {
        friend-list-visible: bool,
        status-visible: bool,
        metadata-visible: bool,
        last-seen-visible: bool,
        profile-image-visible: bool,
        encryption-enabled: bool,
        last-updated: uint
    }
)

(define-map RateLimits
    principal
    {
        daily-actions: uint,
        friend-requests: uint,
        status-updates: uint,
        last-reset: uint
    }
)

(define-map UserBatches
    principal
    {
        message-counter: uint,
        last-batch-timestamp: uint,
        batch-size: uint,
        current-batch-items: uint,
        total-batches: uint
    }
)

(define-map UserActivity
    principal
    {
        last-seen: uint,
        login-count: uint,
        total-actions: uint,
        last-action: uint
    }
)

(define-map Friendships
    {
        user1: principal,
        user2: principal
    }
    {
        status: uint
    }
)
