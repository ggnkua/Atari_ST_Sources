;;;; "Init.scm", Scheme initialization code for SCM.
;;; Copyright (C) 1991, 1992 Aubrey Jaffer.
;;; See the file `COPYING' for terms applying to this program.

;;; OPEN_READ, OPEN_WRITE, and OPEN_BOTH are used to request the proper
;;; mode to open files in.  MSDOS does carraige return - newline
;;; translation if not opened in `b' mode.

(define OPEN_READ (if (eq? 'MSDOS (software-type)) "rb" "r"))
(define OPEN_WRITE (if (eq? 'MSDOS (software-type)) "wb" "w"))
(define OPEN_BOTH (if (eq? 'MSDOS (software-type)) "r+b" "r+"))

(define (open-input-file str)
  (or (open-file str OPEN_READ)
      (and (procedure? could-not-open) (could-not-open) #f)
      (error "OPEN-INPUT-FILE couldn't find file " str)))
(define (open-output-file str)
  (or (open-file str OPEN_WRITE)
      (and (procedure? could-not-open) (could-not-open) #f)
      (error "OPEN-OUTPUT-FILE couldn't find file " str)))
(define (open-io-file str) (open-file str OPEN_BOTH))

(define close-input-port close-port)
(define close-output-port close-port)
(define close-io-port close-port)

(define (call-with-input-file str proc)
  (let* ((file (open-input-file str))
	 (ans (proc file)))
    (close-input-port file)
    ans))

(define (call-with-output-file str proc)
  (let* ((file (open-output-file str))
	 (ans (proc file)))
    (close-output-port file)
    ans))

(define (with-input-from-file str thunk)
  (let* ((port (set-current-input-port (open-input-file str)))
	 (ans (apply thunk '())))
    (close-port (set-current-input-port port))
    ans))

(define (with-output-to-file str thunk)
  (let* ((port (set-current-output-port (open-output-file str)))
	 (ans (apply thunk '())))
    (close-port (set-current-output-port port))
    ans))

(define (file-exists? str)
  (let ((port (open-file str OPEN_READ)))
    (if port (begin (close-port port) #t)
	#f)))

(if (memq 'pipe *features*)
    (define (open-input-pipe str) (open-pipe str "r")))
(if (memq 'pipe *features*)
    (define (open-output-pipe str) (open-pipe str "w")))

(set! *features*
      (append '(getenv tmpnam system abort integer-limits
		p1178 rev4-report rev4-optional-procedures
		rev3-procedures rev2-procedures delay)
	      *features*))

;;; Autoloads for SLIB procedures.

(define (tracef . args) (require 'debug) (apply tracef args))

;;; Macros.

#.(define (trace proc) `(set! ,proc (tracef ,proc ',proc)))
#.(define (untrace proc) `(set! ,proc (untracef ,proc)))

;;; (library-vicinity) should be defined to be the pathname of the
;;; directory where files of Scheme library functions reside.

(define library-vicinity
  (let ((library-path
	 (or (getenv "SCHEME_LIBRARY_PATH")
	     (case (software-type)
	       ((UNIX) "/usr/lib/scheme/")
	       ((VMS) "lib$scheme:")
	       ((MSDOS) "C:\\SCM\\SLIB\\")
 	       ((MACOS THINKC) "camus Napoleon:Think C4.0:scm3.0:")
	       ((AMIGA) "Scheme:libs/")
	       ((ATARIST) "C:\\MISC\\SLIB\\1B6\\")
	       (else "")))))

    (lambda () library-path)))

;;; program-vicinity is here in case the Scheme Library cannot be found.
(define program-vicinity
  (let ((*vicinity-suffix*
	 (case (software-type)
	   ((UNIX AMIGA)	'(#\/))
	   ((VMS)	'(#\: #\]))
	   ((MSDOS)	'(#\\))
	   ((MACOS THINKC)	'(#\:)))))
    (lambda ()
      (let loop ((i (- (string-length *load-pathname*) 1)))
	(cond ((negative? i) "")
	      ((memv (string-ref *load-pathname* i)
		     *vicinity-suffix*)
	       (substring *load-pathname* 0 (+ i 1)))
	      (else (loop (- i 1))))))))

(define scheme-file-suffix
  (case (software-type)
    ((NOSVE) (lambda () "_scm"))
    (else (lambda () ".scm"))))

(define in-vicinity string-append)

(cond ((try-load
	(in-vicinity (library-vicinity) "require" (scheme-file-suffix))))
      (else
       (perror "WARNING")
       (display "WARNING: Couldn't find require.scm in (library-vicinity)")
       (write (library-vicinity))
       (newline)
       (set-errno! 0)))

;;; DO NOT MOVE!  This has to be done after "require.scm" is loaded.
(set! load
      (lambda (file)
	(cond ((> (verbose) 0)
	       (display ";loading ")
	       (write file)
	       (newline)))
	(force-output)
	(or (try-load file)
	    ;;HERE is where the suffix gets specified
	    (try-load (string-append file ".scm"))
	    (and (procedure? could-not-open) (could-not-open) #f)
	    (error "LOAD couldn't find file " file))
	(set-errno! 0)
	(cond ((> (verbose) 0)
	       (display ";done loading ")
	       (write file)
	       (newline)))))
(define could-not-open #f)

(define (error . args)
  (perror "ERROR")
  (set-errno! 0)
  (display "ERROR: ")
  (if (not (null? args))
      (begin (display (car args))
	     (for-each (lambda (x) (display #\ ) (write x))
		       (cdr args))))
  (newline)
  (abort))

(define (output-port-width . arg) 79)

(define slib:error error)

;;; This is the vicinity where this file resides.
(define implementation-vicinity
  (let ((vic (program-vicinity)))
    (lambda () vic)))

(define (terms)
  (list-file (in-vicinity (implementation-vicinity) "COPYING")))

(define (list-file file)
  (call-with-input-file file
    (lambda (inport)
      (do ((c (read-char inport) (read-char inport)))
	  ((eof-object? c))
	(write-char c)))))

;;;; Here are some Revised^2 Scheme functions:
(define 1+
  (let ((+ +))
    (lambda (n) (+ n 1))))
(define -1+
  (let ((+ +))
    (lambda (n) (+ n -1))))
(define 1- -1+)
(define <? <)
(define <=? <=)
(define =? =)
(define >? >)
(define >=? >=)
(define t #t)
(define nil #f)

;; define these as appropriate for your system.
(define slib:tab #\tab)
(define slib:form-feed #\page)

(if (= (length (program-arguments)) 1) (verbose 1))

(if (not (memq 'ed *features*))
    (define (ed . args)
      (system (apply string-append
		     (or (getenv "EDITOR") "ed")
		     (map (lambda (s) (string-append " " s)) args)))))
(if (not (memq 'ed *features*))
    (set! *features* (cons 'ed *features*)))

;;; ABS and MAGNITUDE can be the same.
(if (inexact? (string->number "0.0")) (set! abs magnitude))

;;; This loads JCAL, the user's initialization file, or files named in
;;; program arguments.
(let ((progname (car (program-arguments))))
  (or
   (eq? (software-type) 'THINKC)
   (member "-no-init-file" (program-arguments))

   ;; This clause is special for JACAL
   (let ((len (string-length progname)))
     (and
      (cond ((>= len 4)
	     (string-ci=? "JCAL" (substring progname (- len 4) len)))
	    ((>= len 5)
	     (string-ci=? "JACAL" (substring progname (- len 5) len)))
	    (else #f))
      (verbose 0)
      (try-load
       (or (getenv "JCAL_INIT")
	   (case (software-type)
	     ((UNIX) "/usr/lib/jcal/math.scm")
	     ((VMS) "lib$jcal:math.scm")
	     ((MSDOS) "C:\\SCM\\JCAL\\MATH.SCM")
	     ((MACOS THINKC) "camus Napoleon:Think C4.0:jcal:math.scm")
	     ((AMIGA) "Jcal:libs/math.scm")
	     (else "math.scm"))))
      (set! *load-pathname* #f)
      (math)))

   (and (not (string-ci=? (car (program-arguments)) "SCM")) ;this file!
	(let ((path (getenv (string-append (car (program-arguments))
					   "_INIT_PATH"))))
	  (and path (cond ((try-load path) #t)
			  (else
			   (display "WARNING: Couldn't find ")
			   (display path)
			   (newline)
			   #f)))))

   ;; If your program uses an _INIT_PATH file you need to replicate
   ;; the following terms if you want them executed.
   (try-load
    (in-vicinity
     (let ((home (getenv "HOME")))
       (if home
	   (case (software-type)
	     ((UNIX)
	      (if (char=? #\/ (string-ref home (+ -1 (string-length home))))
		  home			;V7 unix has a / on HOME
		  (string-append home "/")))
	     (else home))
	   (user-vicinity)))
     "ScmInit.scm"))
   (begin (set-errno! 0)
	  (for-each load (cdr (program-arguments))))))
