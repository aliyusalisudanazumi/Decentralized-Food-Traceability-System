;; Quality Certification Contract

(define-map certifications
  { cert-id: uint }
  {
    item-id: uint,
    certifier: principal,
    certification-type: (string-ascii 50),
    expiration: uint,
    status: (string-ascii 10)
  }
)

(define-data-var cert-id-nonce uint u0)

(define-constant AUTHORIZED_CERTIFIERS
  (list
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
    'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
    'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC
  )
)

(define-public (issue-certification
  (item-id uint)
  (certification-type (string-ascii 50))
  (validity-period uint)
)
  (let
    ((new-cert-id (+ (var-get cert-id-nonce) u1)))
    (asserts! (is-authorized-certifier tx-sender) (err u403))
    (map-set certifications
      { cert-id: new-cert-id }
      {
        item-id: item-id,
        certifier: tx-sender,
        certification-type: certification-type,
        expiration: (+ block-height validity-period),
        status: "active"
      }
    )
    (var-set cert-id-nonce new-cert-id)
    (ok new-cert-id)
  )
)

(define-public (revoke-certification (cert-id uint))
  (let
    ((cert (unwrap! (map-get? certifications { cert-id: cert-id }) (err u404))))
    (asserts! (is-authorized-certifier tx-sender) (err u403))
    (map-set certifications
      { cert-id: cert-id }
      (merge cert { status: "revoked" })
    )
    (ok true)
  )
)

(define-read-only (get-certification (cert-id uint))
  (map-get? certifications { cert-id: cert-id })
)

(define-read-only (is-authorized-certifier (address principal))
  (is-some (index-of AUTHORIZED_CERTIFIERS address))
)

