;; Auction House Smart Contract
;; Allows users to create and bid on auctions
;; Handles auction lifecycle, bidding, and settlement

;; Error codes
(define-constant ERR-EXPIRED (err u100))
(define-constant ERR-NOT-EXPIRED (err u101))
(define-constant ERR-LOW-BID (err u102))
(define-constant ERR-NO-AUCTION (err u103))
(define-constant ERR-ALREADY-EXISTS (err u104))
(define-constant ERR-NOT-OWNER (err u105))
(define-constant ERR-AUCTION-ACTIVE (err u106))
(define-constant ERR-NOT-ACTIVE (err u107))

;; Data structures
(define-map auctions
    { auction-id: uint }
    {
        owner: principal,
        token-id: uint,
        start-block: uint,
        end-block: uint,
        reserve-price: uint,
        current-bid: uint,
        highest-bidder: (optional principal),
        status: (string-ascii 20)
    }
)

(define-map user-bids 
    { auction-id: uint, bidder: principal } 
    { amount: uint }
)

;; Storage of next auction ID
(define-data-var next-auction-id uint u1)

;; Read-only functions
(define-read-only (get-auction (auction-id uint))
    (map-get? auctions { auction-id: auction-id })
)

(define-read-only (get-user-bid (auction-id uint) (bidder principal))
    (map-get? user-bids { auction-id: auction-id, bidder: bidder })
)

(define-read-only (is-auction-active (auction-id uint))
    (let (
        (auction (unwrap! (get-auction auction-id) false))
        (current-block block-height)
    )
    (and 
        (>= current-block (get start-block auction))
        (<= current-block (get end-block auction))
        (is-eq (get status auction) "active")
    ))
)

;; Public functions
(define-public (create-auction (token-id uint) (duration uint) (reserve-price uint))
    (let (
        (auction-id (var-get next-auction-id))
        (start-block block-height)
        (end-block (+ block-height duration))
    )
    (asserts! (> duration u0) ERR-EXPIRED)
    (asserts! (> reserve-price u0) ERR-LOW-BID)
    
    (map-insert auctions
        { auction-id: auction-id }
        {
            owner: tx-sender,
            token-id: token-id,
            start-block: start-block,
            end-block: end-block,
            reserve-price: reserve-price,
            current-bid: u0,
            highest-bidder: none,
            status: "active"
        }
    )
    
    (var-set next-auction-id (+ auction-id u1))
    (ok auction-id))
)

(define-public (place-bid (auction-id uint) (bid-amount uint))
    (let (
        (auction (unwrap! (get-auction auction-id) ERR-NO-AUCTION))
        (current-block block-height)
    )
    
    ;; Verify auction is active
    (asserts! (is-auction-active auction-id) ERR-NOT-ACTIVE)
    
    ;; Verify bid is higher than current bid and reserve price
    (asserts! (> bid-amount (get current-bid auction)) ERR-LOW-BID)
    (asserts! (>= bid-amount (get reserve-price auction)) ERR-LOW-BID)
    
    ;; Handle previous highest bidder refund if exists
    (match (get highest-bidder auction)
        prev-bidder (begin
            ;; Refund previous bidder
            (try! (as-contract (stx-transfer? (get current-bid auction) contract-caller prev-bidder)))
            true
        )
        false
    )
    
    ;; Transfer bid amount from bidder
    (try! (stx-transfer? bid-amount tx-sender (as-contract tx-sender)))
    
    ;; Update auction state
    (map-set auctions
        { auction-id: auction-id }
        (merge auction {
            current-bid: bid-amount,
            highest-bidder: (some tx-sender)
        })
    )
    
    ;; Update user bid mapping
    (map-set user-bids
        { auction-id: auction-id, bidder: tx-sender }
        { amount: bid-amount }
    )
    
    (ok true))
)
