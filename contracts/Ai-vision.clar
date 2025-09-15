;; AI Vision collective AI Future Roadmap
;; Clarity v2 contract
;; Theme: AI Vision

(clarity-version 2)
(contract-name ai-vision)

;; ---------------------------------------
;; Data Structures
;; ---------------------------------------

(define-data-var vision-counter uint u0)

(define-map visions
  ((id uint))
  ((creator principal) (title (string-utf8 100)) (description (string-utf8 200))
   (funds uint) (votes uint) (status (string-utf8 20))))

(define-map supporters
  ((vision-id uint) (supporter principal))
  ((amount uint)))

;; ---------------------------------------
;; Vision Management
;; ---------------------------------------

(define-public (create-vision (title (string-utf8 100)) (description (string-utf8 200)))
  (let ((id (var-get vision-counter)))
    (begin
      (map-set visions ((id id))
        ((creator tx-sender) (title title) (description description)
         (funds u0) (votes u0) (status "open")))
      (var-set vision-counter (+ id u1))
      (ok id)
    )
  )
)

(define-public (vote-vision (id uint))
  (let ((vision (map-get? visions ((id id)))))
    (match vision
      v
      (begin
        (map-set visions ((id id))
          ((creator (get creator v)) (title (get title v))
           (description (get description v)) (funds (get funds v))
           (votes (+ (get votes v) u1)) (status (get status v))))
        (ok true)
      )
      (err u404)
    )
  )
)

(define-public (fund-vision (id uint) (amount uint))
  (let ((vision (map-get? visions ((id id)))))
    (match vision
      v
      (begin
        (try! (stx-transfer? amount tx-sender (get creator v)))
        (map-set visions ((id id))
          ((creator (get creator v)) (title (get title v))
           (description (get description v)) (funds (+ (get funds v) amount))
           (votes (get votes v)) (status (get status v))))
        (map-set supporters ((vision-id id) (supporter tx-sender))
          ((amount amount)))
        (ok true)
      )
      (err u404)
    )
  )
)

(define-public (close-vision (id uint))
  (let ((vision (map-get? visions ((id id)))))
    (match vision
      v
      (if (is-eq (get creator v) tx-sender)
        (begin
          (map-set visions ((id id))
            ((creator (get creator v)) (title (get title v))
             (description (get description v)) (funds (get funds v))
             (votes (get votes v)) (status "closed")))
          (ok true)
        )
        (err u403) ;; only creator can close
      )
      (err u404)
    )
  )
)

;; ---------------------------------------
;; Read-Only Views
;; ---------------------------------------

(define-read-only (get-vision (id uint))
  (map-get? visions ((id id)))
)

(define-read-only (get-total-visions)
  (var-get vision-counter)
)

(define-read-only (get-supporter (vision-id uint) (supporter principal))
  (map-get? supporters ((vision-id vision-id) (supporter supporter)))
)
