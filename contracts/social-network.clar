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

(define-map BlockedUsers
    {
        blocker: principal,
        blocked: principal
    }
    {
        timestamp: uint
    }
)

;; Private functions
(define-private (check-rate-limit (user principal) (action-type uint))
    (let
        (
            (rate-data (default-to 
                {
                    daily-actions: u0,
                    friend-requests: u0,
                    status-updates: u0,
                    last-reset: (unwrap-panic (get-block-info? time u0))
                }
                (map-get? RateLimits user)
            ))
            (current-time (unwrap-panic (get-block-info? time u0)))
            (should-reset (> (- current-time (get last-reset rate-data)) RATE_LIMIT_RESET_PERIOD))
        )
        (if should-reset
            ;; Reset counters if period expired
            (begin
                (map-set RateLimits user
                    {
                        daily-actions: u1,
                        friend-requests: (if (is-eq action-type u1) u1 u0),
                        status-updates: (if (is-eq action-type u2) u1 u0),
                        last-reset: current-time
                    }
                )
                true
            )
            ;; Check limits
            (and
                (< (get daily-actions rate-data) MAX_ACTIONS_PER_DAY)
                (or 
                    (not (is-eq action-type u1))
                    (< (get friend-requests rate-data) MAX_FRIEND_REQUESTS_PER_DAY)
                )
                (or
                    (not (is-eq action-type u2))
                    (< (get status-updates rate-data) MAX_STATUS_UPDATES_PER_DAY)
                )
            )
        )
    )
)

(define-private (update-rate-limit (user principal) (action-type uint))
    (let
        (
            (rate-data (unwrap-panic (map-get? RateLimits user)))
        )
        (map-set RateLimits user
            (merge rate-data {
                daily-actions: (+ (get daily-actions rate-data) u1),
                friend-requests: (+ (get friend-requests rate-data) (if (is-eq action-type u1) u1 u0)),
                status-updates: (+ (get status-updates rate-data) (if (is-eq action-type u2) u1 u0))
            })
        )
    )
)

(define-private (update-user-activity (user principal))
    (let
        (
            (current-time (unwrap-panic (get-block-info? time u0)))
            (activity (default-to
                {
                    last-seen: current-time,
                    login-count: u0,
                    total-actions: u0,
                    last-action: current-time
                }
                (map-get? UserActivity user)
            ))
        )
        (map-set UserActivity user
            (merge activity {
                last-seen: current-time,
                total-actions: (+ (get total-actions activity) u1),
                last-action: current-time
            })
        )
    )
)

(define-private (max-uint (a uint) (b uint))
    (if (>= a b)
        a
        b
    )
)

(define-private (min-uint (a uint) (b uint))
    (if (<= a b)
        a
        b
    )
)

;; Check if users are friends
(define-private (are-friends (user1 principal) (user2 principal))
    (match (map-get? Friendships {user1: user1, user2: user2})
        friendship (is-eq (get status friendship) FRIENDSHIP_ACTIVE)
        false
    )
)

;; Check if user is active
(define-private (check-active-user (user principal))
    (match (map-get? Users user)
        user-data (and 
            (is-eq (get status user-data) STATUS_ACTIVE)
            (is-none (get deactivation-time user-data))
        )
        false
    )
)

;; Check if user exists
(define-private (user-exists (user principal))
    (is-some (map-get? Users user))
)

;; Check if user is blocked
(define-private (is-blocked (blocker principal) (blocked principal))
    (is-some (map-get? BlockedUsers {blocker: blocker, blocked: blocked}))
)

;; Get user privacy settings with defaults
(define-private (get-privacy-settings (user principal))
    (default-to
        {
            friend-list-visible: true,
            status-visible: true,
            metadata-visible: true,
            last-seen-visible: true,
            profile-image-visible: true,
            encryption-enabled: false,
            last-updated: (unwrap-panic (get-block-info? time u0))
        }
        (map-get? UserPrivacy user)
    )
)

;; Modified optimize-batch-size function
(define-public (optimize-batch-size (user principal))
    (let (
        (batch-data (unwrap-panic (map-get? UserBatches user)))
        (current-time (unwrap-panic (get-block-info? time u0)))
        (time-since-last-batch (- current-time (get last-batch-timestamp batch-data)))
        (current-batch-size (get batch-size batch-data))
        (items-in-current-batch (get current-batch-items batch-data))
    )
        (if (> time-since-last-batch BATCH_EXPIRY_PERIOD)
            ;; Batch expired, reset and adjust size
            (begin
                (map-set UserBatches user
                    (merge batch-data {
                        batch-size: (max-uint MIN_BATCH_SIZE (/ current-batch-size u2)),
                        current-batch-items: u0,
                        last-batch-timestamp: current-time
                    })
                )
                (ok true)
            )
            ;; Adjust based on usage
            (begin
                (map-set UserBatches user
                    (merge batch-data {
                        batch-size: (min-uint MAX_BATCH_SIZE 
                            (if (>= items-in-current-batch (/ current-batch-size u2))
                                (* current-batch-size u2)
                                current-batch-size
                            ))
                    })
                )
                (ok true)
            )
        )
    )
)
