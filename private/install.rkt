#lang racket/base

(require racket/system)
(require racket/file)
(require dynext/file)
(require dynext/link)
(require (only-in srfi/13 string-suffix-ci?))

(require file/untgz)

(provide pre-installer)

(define SCRYPTVERSION "1.1.6")
(define SCRYPTUNPACKED (string-append "scrypt-"SCRYPTVERSION))

(define (pre-installer collections-top-path racl-path)
  (define private-path (build-path racl-path "private"))

  (parameterize ((current-directory private-path))
    (define unpacked-path (build-path private-path SCRYPTUNPACKED))
    (define shared-object-target-path (build-path private-path
						  "compiled"
						  "native"
						  (system-library-subpath)))
    (define shared-object-target (build-path shared-object-target-path
					     (append-extension-suffix "racket-scrypt")))

    (when (not (file-exists? shared-object-target))
      (when (not (directory-exists? unpacked-path))
	;; file/untgz doesn't return when invoked on scrypt-1.1.6.tgz,
	;; so I'm shelling out to tar instead.
	(system (string-append "tar -zxf "SCRYPTUNPACKED".tgz"))
	(copy-file (build-path private-path "config.h") (build-path unpacked-path "config.h"))
	(delete-file (build-path unpacked-path "lib" "crypto" "crypto_aesctr.h"))
	(delete-file (build-path unpacked-path "lib" "crypto" "crypto_aesctr.c"))
	(delete-file (build-path unpacked-path "lib" "crypto" "crypto_scrypt-nosse.c"))
	(delete-file (build-path unpacked-path "lib" "crypto" "crypto_scrypt-sse.c")))

      (define c-sources
	(find-files (lambda (p) (string-suffix-ci? ".c" (path->string p)))
		    (build-path unpacked-path "lib" "crypto")))

      (make-directory* shared-object-target-path)
      (parameterize ((current-extension-linker-flags
		      (append (current-extension-linker-flags)
			      (list "-O3" "-fomit-frame-pointer" "-funroll-loops"
				    "-DHAVE_CONFIG_H"
				    "-I" (path->string unpacked-path)
				    "-I" (string-append (path->string unpacked-path)"/lib/util")
				    ))))
	(link-extension #f ;; not quiet
			c-sources
			shared-object-target))

      (delete-directory/files unpacked-path))))
