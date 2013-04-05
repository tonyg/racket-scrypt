#lang racket/base
;; Wrapper for Colin Percival's scrypt function, http://www.tarsnap.com/scrypt.html

(require racket/include)
(require ffi/unsafe)
(require ffi/unsafe/define)
(require setup/dirs)

(provide scrypt)

;;---------------------------------------------------------------------------
;; FFI

(define (local-lib-dirs)
  (list (build-path (collection-path "scrypt")
		    "private"
		    "compiled"
		    "native"
		    (system-library-subpath))))

(define scrypt-lib (ffi-lib "racket-scrypt" #:get-lib-dirs local-lib-dirs))

(define-ffi-definer define-scrypt scrypt-lib
  #:default-make-fail make-not-available)

;; Oh gross. Should this be part of Racket?
(define _size_t _intptr)

;;---------------------------------------------------------------------------
;; The function itself

(define-scrypt crypto_scrypt
  (_fun _bytes _size_t ;; passwd, passwdlen
	_bytes _size_t ;; salt, saltlen
	_uint64 ;; N
	_uint32 ;; r
	_uint32 ;; p
	_bytes _size_t ;; buf, buflen
	-> _int
	))

(define (scrypt passwd salt N r p buflen)
  (define buf (make-bytes buflen))
  (if (zero? (crypto_scrypt passwd (bytes-length passwd)
			    salt (bytes-length salt)
			    N
			    r
			    p
			    buf (bytes-length buf)))
      buf
      (error 'scrypt "Error from scrypt primitive")))
