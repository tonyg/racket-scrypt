#lang setup/infotab

(define name "scrypt")
(define blurb
  (list
   `(p "Racket binding to Colin Percival's \"scrypt\" function.")))
(define homepage "https://github.com/tonyg/racket-scrypt")
(define primary-file "main.rkt")
(define categories '(misc))
(define repositories '("4.x"))

(define pre-install-collection "private/install.rkt")
(define compile-omit-files '("private/install.rkt"))

(define deps '("srfi-lite-lib"
               "base" "dynext-lib" "rackunit-lib"))
