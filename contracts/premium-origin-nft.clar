;; Premium Origin NFT Contract

(define-non-fungible-token premium-origin uint)

(define-map token-metadata
  { token-id: uint }
  {
    item-id: uint,
    origin: (string-ascii 100),
    product-type: (string-ascii 50),
    quality-score: uint,
    minter: principal
  }
)

(define-data-var token-id-nonce uint u0)

(define-public (mint-premium-origin-nft
  (item-id uint)
  (origin (string-ascii 100))
  (product-type (string-ascii 50))
  (quality-score uint)
)
  (let
    ((new-token-id (+ (var-get token-id-nonce) u1)))
    (asserts! (>= quality-score u90) (err u400)) ;; Only allow high-quality items
    (try! (nft-mint? premium-origin new-token-id tx-sender))
    (map-set token-metadata
      { token-id: new-token-id }
      {
        item-id: item-id,
        origin: origin,
        product-type: product-type,
        quality-score: quality-score,
        minter: tx-sender
      }
    )
    (var-set token-id-nonce new-token-id)
    (ok new-token-id)
  )
)

(define-read-only (get-token-metadata (token-id uint))
  (map-get? token-metadata { token-id: token-id })
)

(define-public (transfer-nft (token-id uint) (recipient principal))
  (nft-transfer? premium-origin token-id tx-sender recipient)
)

