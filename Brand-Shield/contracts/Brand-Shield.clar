;; Brand Shield - AI-Powered Trademark Monitoring Contract
;; Built for STX Blockchain

;; Contract Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_TRADEMARK_EXISTS (err u101))
(define-constant ERR_TRADEMARK_NOT_FOUND (err u102))
(define-constant ERR_INSUFFICIENT_PAYMENT (err u103))
(define-constant ERR_INVALID_STATUS (err u104))
(define-constant ERR_ALREADY_PROCESSED (err u105))

;; Registration and monitoring fees (in microSTX)
(define-constant REGISTRATION_FEE u1000000) ;; 1 STX
(define-constant MONITORING_FEE u500000)   ;; 0.5 STX per month
(define-constant ENFORCEMENT_FEE u2000000) ;; 2 STX per enforcement action

;; Data Variables
(define-data-var contract-owner principal CONTRACT_OWNER)
(define-data-var total-trademarks uint u0)
(define-data-var total-violations uint u0)

;; Trademark registration structure
(define-map trademarks 
  { trademark-id: uint }
  {
    owner: principal,
    brand-name: (string-ascii 50),
    description: (string-ascii 200),
    category: (string-ascii 30),
    registration-block: uint,
    monitoring-active: bool,
    monitoring-expires: uint,
    violation-count: uint
  }
)

;; Violation detection and enforcement
(define-map violations
  { violation-id: uint }
  {
    trademark-id: uint,
    detected-url: (string-ascii 200),
    violation-type: (string-ascii 50),
    confidence-score: uint, ;; 0-100 AI confidence
    status: (string-ascii 20), ;; "pending", "enforced", "dismissed"
    reported-block: uint,
    enforced-block: (optional uint)
  }
)

;; AI monitoring nodes (simulated oracles)
(define-map ai-monitors
  { monitor-id: principal }
  {
    active: bool,
    reputation-score: uint, ;; 0-100
    violations-reported: uint,
    false-positives: uint
  }
)

;; User trademark ownership lookup
(define-map user-trademarks
  { owner: principal, trademark-id: uint }
  { active: bool }
)

;; Public Functions

;; Register a new trademark
(define-public (register-trademark (brand-name (string-ascii 50)) 
                                 (description (string-ascii 200))
                                 (category (string-ascii 30)))
  (let ((trademark-id (+ (var-get total-trademarks) u1)))
    (asserts! (>= (stx-get-balance tx-sender) REGISTRATION_FEE) ERR_INSUFFICIENT_PAYMENT)
    (asserts! (is-none (map-get? trademarks {trademark-id: trademark-id})) ERR_TRADEMARK_EXISTS)
    
    ;; Transfer registration fee
    (try! (stx-transfer? REGISTRATION_FEE tx-sender (var-get contract-owner)))
    
    ;; Register trademark
    (map-set trademarks 
      { trademark-id: trademark-id }
      {
        owner: tx-sender,
        brand-name: brand-name,
        description: description,
        category: category,
        registration-block: stacks-block-height,
        monitoring-active: false,
        monitoring-expires: u0,
        violation-count: u0
      })
    
    ;; Set user ownership
    (map-set user-trademarks 
      { owner: tx-sender, trademark-id: trademark-id }
      { active: true })
    
    ;; Update counter
    (var-set total-trademarks trademark-id)
    
    (ok trademark-id)))

;; Activate AI monitoring for a trademark
(define-public (activate-monitoring (trademark-id uint) (duration-blocks uint))
  (let ((trademark (unwrap! (map-get? trademarks {trademark-id: trademark-id}) ERR_TRADEMARK_NOT_FOUND))
        (monitoring-cost (* MONITORING_FEE (/ duration-blocks u144)))) ;; Assuming 144 blocks per day
    
    (asserts! (is-eq (get owner trademark) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (>= (stx-get-balance tx-sender) monitoring-cost) ERR_INSUFFICIENT_PAYMENT)
    
    ;; Transfer monitoring fee
    (try! (stx-transfer? monitoring-cost tx-sender (var-get contract-owner)))
    
    ;; Update trademark with active monitoring
    (map-set trademarks 
      { trademark-id: trademark-id }
      (merge trademark {
        monitoring-active: true,
        monitoring-expires: (+ stacks-block-height duration-blocks)
      }))
    
    (ok true)))

;; Register as AI monitoring node
(define-public (register-ai-monitor)
  (begin
    (map-set ai-monitors
      { monitor-id: tx-sender }
      {
        active: true,
        reputation-score: u50, ;; Start with neutral reputation
        violations-reported: u0,
        false-positives: u0
      })
    (ok true)))

;; Report a trademark violation (called by AI monitors)
(define-public (report-violation (trademark-id uint)
                               (detected-url (string-ascii 200))
                               (violation-type (string-ascii 50))
                               (confidence-score uint))
  (let ((violation-id (+ (var-get total-violations) u1))
        (monitor (unwrap! (map-get? ai-monitors {monitor-id: tx-sender}) ERR_UNAUTHORIZED))
        (trademark (unwrap! (map-get? trademarks {trademark-id: trademark-id}) ERR_TRADEMARK_NOT_FOUND)))
    
    (asserts! (get active monitor) ERR_UNAUTHORIZED)
    (asserts! (get monitoring-active trademark) ERR_INVALID_STATUS)
    (asserts! (< stacks-block-height (get monitoring-expires trademark)) ERR_INVALID_STATUS)
    (asserts! (<= confidence-score u100) ERR_INVALID_STATUS)
    
    ;; Record violation
    (map-set violations
      { violation-id: violation-id }
      {
        trademark-id: trademark-id,
        detected-url: detected-url,
        violation-type: violation-type,
        confidence-score: confidence-score,
        status: "pending",
        reported-block: stacks-block-height,
        enforced-block: none
      })
    
    ;; Update monitor stats
    (map-set ai-monitors
      { monitor-id: tx-sender }
      (merge monitor {
        violations-reported: (+ (get violations-reported monitor) u1)
      }))
    
    ;; Update violation counter
    (var-set total-violations violation-id)
    
    (ok violation-id)))

;; Enforce violation (automated action)
(define-public (enforce-violation (violation-id uint))
  (let ((violation (unwrap! (map-get? violations {violation-id: violation-id}) ERR_TRADEMARK_NOT_FOUND))
        (trademark-id (get trademark-id violation))
        (trademark (unwrap! (map-get? trademarks {trademark-id: trademark-id}) ERR_TRADEMARK_NOT_FOUND)))
    
    (asserts! (is-eq (get owner trademark) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status violation) "pending") ERR_ALREADY_PROCESSED)
    (asserts! (>= (stx-get-balance tx-sender) ENFORCEMENT_FEE) ERR_INSUFFICIENT_PAYMENT)
    
    ;; Transfer enforcement fee
    (try! (stx-transfer? ENFORCEMENT_FEE tx-sender (var-get contract-owner)))
    
    ;; Update violation status
    (map-set violations
      { violation-id: violation-id }
      (merge violation {
        status: "enforced",
        enforced-block: (some stacks-block-height)
      }))
    
    ;; Update trademark violation count
    (map-set trademarks
      { trademark-id: trademark-id }
      (merge trademark {
        violation-count: (+ (get violation-count trademark) u1)
      }))
    
    (ok true)))

;; Dismiss false positive
(define-public (dismiss-violation (violation-id uint))
  (let ((violation (unwrap! (map-get? violations {violation-id: violation-id}) ERR_TRADEMARK_NOT_FOUND))
        (trademark-id (get trademark-id violation))
        (trademark (unwrap! (map-get? trademarks {trademark-id: trademark-id}) ERR_TRADEMARK_NOT_FOUND)))
    
    (asserts! (is-eq (get owner trademark) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status violation) "pending") ERR_ALREADY_PROCESSED)
    
    ;; Update violation status
    (map-set violations
      { violation-id: violation-id }
      (merge violation {
        status: "dismissed"
      }))
    
    (ok true)))

;; Read-only functions

;; Get trademark information
(define-read-only (get-trademark (trademark-id uint))
  (map-get? trademarks {trademark-id: trademark-id}))

;; Get violation information  
(define-read-only (get-violation (violation-id uint))
  (map-get? violations {violation-id: violation-id}))

;; Get AI monitor information
(define-read-only (get-ai-monitor (monitor-id principal))
  (map-get? ai-monitors {monitor-id: monitor-id}))

;; Check if user owns trademark
(define-read-only (owns-trademark (owner principal) (trademark-id uint))
  (default-to false (get active (map-get? user-trademarks {owner: owner, trademark-id: trademark-id}))))

;; Get contract stats
(define-read-only (get-contract-stats)
  {
    total-trademarks: (var-get total-trademarks),
    total-violations: (var-get total-violations),
    contract-owner: (var-get contract-owner)
  })

;; Get monitoring status for trademark
(define-read-only (get-monitoring-status (trademark-id uint))
  (match (map-get? trademarks {trademark-id: trademark-id})
    trademark (ok {
      active: (get monitoring-active trademark),
      expires-at: (get monitoring-expires trademark),
      currently-active: (and (get monitoring-active trademark) 
                           (< stacks-block-height (get monitoring-expires trademark)))
    })
    ERR_TRADEMARK_NOT_FOUND))

;; Admin functions

;; Update contract owner (only current owner)
(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (var-set contract-owner new-owner)
    (ok true)))

;; Deactivate AI monitor for misbehavior
(define-public (deactivate-monitor (monitor-id principal))
  (let ((monitor (unwrap! (map-get? ai-monitors {monitor-id: monitor-id}) ERR_TRADEMARK_NOT_FOUND)))
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    
    (map-set ai-monitors
      { monitor-id: monitor-id }
      (merge monitor { active: false }))
    
    (ok true)))

;; Emergency functions

;; Pause all monitoring (emergency only)
(define-public (emergency-pause)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    ;; Implementation would disable new violations and monitoring
    (ok true)))