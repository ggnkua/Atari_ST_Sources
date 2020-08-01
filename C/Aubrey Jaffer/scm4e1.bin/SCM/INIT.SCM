;;;; "Init.scm", Scheme initialization code for SCM.
;;; Copyright (C) 1991, 1992, 1993, 1994 Aubrey Jaffer.
;;; See the file `COPYING' for terms applying to this program.

(define (scheme-implementation-type) 'SCM)
(define (scheme-implementation-version) "4e1")

;;; (library-vicinity) should be defined to be the pathname of the
;;; directory where files of Scheme library functions reside.

(define library-vicinity
  (let ((library-path
	 (or (getenv "SCHEME_LIBRARY_PATH")
	     (case (software-type)
	       ((UNIX COHERENT) "/usr/local/lib/slib/")
	       ((VMS) "lib$scheme:")
	       ((MSDOS ATARIST) "C:\\SCM\\SLIB\\")
	       ((OS/2) "\\languages\\scm\\slib\\")
	       ((MACOS THINKC) "camus Napoleon:Think C4.0:scm3.0:")
	       ((AMIGA) "Scheme:libs/")
	       (else "")))))

    (lambda () library-path)))

;;; program-vicinity is here in case the Scheme Library cannot be found.
(define program-vicinity
  (let ((*vicinity-suffix*
	 (case (software-type)
	   ((UNIX COHERENT) '(#\/))
	   ((AMIGA) '(#\: #\/))
	   ((VMS) '(#\: #\]))
	   ((MSDOS ATARIST OS/2) '(#\\))
	   ((MACOS THINKC) '(#\:)))))
    (lambda ()
      (let loop ((i (- (string-length *load-pathname*) 1)))
	(cond ((negative? i) "")
	      ((memv (string-ref *load-pathname* i)
		     *vicinity-suffix*)
	       (substring *load-pathname* 0 (+ i 1)))
	      (else (loop (- i 1))))))))

;;; Here for backward compatability
(define scheme-file-suffix
  (case (software-type)
    ((NOSVE) (lambda () "_scm"))
    (else (lambda () ".scm"))))

(set! *features*
      (append '(getenv tmpnam system abort transcript with-file
		ieee-p1178 rev4-report rev4-optional-procedures
		hash object-hash delay eval dynamic-wind
		multiarg-apply multiarg/and- logical defmacro
		string-port source)
	      *features*))

(define in-vicinity string-append)

(define slib:exit quit)

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

(define (read:eval-feature exp)
  (cond ((symbol? exp)
	 (or (memq exp *features*) (eq? exp (software-type))))
	((and (pair? exp) (list? exp))
	 (case (car exp)
	   ((not) (not (read:eval-feature (cadr exp))))
	   ((or) (if (null? (cdr exp)) #f
		     (or (read:eval-feature (cadr exp))
			 (read:eval-feature (cons 'or (cddr exp))))))
	   ((and) (if (null? (cdr exp)) #t
		      (and (read:eval-feature (cadr exp))
			   (read:eval-feature (cons 'and (cddr exp))))))
	   (else (error "read:sharp+ invalid expression " exp))))))

(define (read:array digit port)
  (define chr0 (char->integer #\0))
  (let ((rank (let readnum ((val (- (char->integer digit) chr0)))
		(if (char-numeric? (peek-char port))
		    (readnum (+ (* 10 val)
				(- (char->integer (read-char port)) chr0)))
		    val)))
	(prot (if (eq? #\( (peek-char port))
		  '()
		  (let ((c (read-char port)))
		    (case c ((#\b) #t)
			  ((#\a) #\a)
			  ((#\u) 1)
			  ((#\e) -1)
			  ((#\s) 1.0)
			  ((#\i) 1/3)
			  ((#\c) 0+i)
			  (else (error "read:array unknown option " c)))))))
    (if (eq? (peek-char port) #\()
	(list->uniform-array rank prot (read port))
	(error "read:array list not found"))))

(define (read:uniform-vector proto port)
  (if (eq? #\( (peek-char port))
      (list->uniform-array 1 proto (read port))
      (error "read:uniform-vector list not found")))

(define (read:sharp c port)
  (define (barf)
    (error "unknown # object" c))
  (case c ((#\') (read port))
	((#\+) (if (read:eval-feature (read port))
		   (read port)
		   (begin (read port) (if #f #f))))
	((#\-) (if (not (read:eval-feature (read port)))
		   (read port)
		   (begin (read port) (if #f #f))))
	((#\b) (read:uniform-vector #t port))
	((#\a) (read:uniform-vector #\a port))
	((#\u) (read:uniform-vector 1 port))
	((#\e) (read:uniform-vector -1 port))
	((#\s) (read:uniform-vector 1.0 port))
	((#\i) (read:uniform-vector 1/3 port))
	((#\c) (read:uniform-vector 0+i port))
	((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
	 (read:array c port))
	((#\!) (if (= 1 (line-number))
		   (let skip () (if (eq? #\newline (peek-char port))
				    (if #f #f)
				    (begin (read-char port) (skip))))
		   (barf)))
	(else (barf))))

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
(define sequence begin)

(set! apply (lambda (fun . args) (@apply fun (apply:nconc-to-last args))))
(define (call-with-current-continuation proc)
  (@call-with-current-continuation proc))

;;; VMS does something strange when output is sent to both
;;; CURRENT-OUTPUT-PORT and CURRENT-ERROR-PORT.
(case (software-type) ((VMS) (set-current-error-port (current-output-port))))

;;; OPEN_READ, OPEN_WRITE, and OPEN_BOTH are used to request the proper
;;; mode to open files in.  MSDOS does carraige return - newline
;;; translation if not opened in `b' mode.

(define OPEN_READ (case (software-type)
		    ((MSDOS ATARIST) "rb")
		    (else "r")))
(define OPEN_WRITE (case (software-type)
		     ((MSDOS ATARIST) "wb")
		     (else "w")))
(define OPEN_BOTH (case (software-type)
		    ((MSDOS ATARIST) "r+b")
		    (else "r+")))

(define could-not-open #f)

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

(define (with-input-from-port port thunk)
  (let* ((swaports (lambda () (set! port (set-current-input-port port)))))
    (dynamic-wind swaports thunk swaports)))

(define (with-output-to-port port thunk)
  (let* ((swaports (lambda () (set! port (set-current-output-port port)))))
    (dynamic-wind swaports thunk swaports)))

(define (with-error-to-port port thunk)
  (let* ((swaports (lambda () (set! port (set-current-error-port port)))))
    (dynamic-wind swaports thunk swaports)))

(define (with-input-from-file file thunk)
  (let* ((nport (open-input-file file))
	 (ans (with-input-from-port nport thunk)))
    (close-port nport)
    ans))

(define (with-output-to-file file thunk)
  (let* ((nport (open-output-file file))
	 (ans (with-output-to-port nport thunk)))
    (close-port nport)
    ans))

(define (with-error-to-file file thunk)
  (let* ((nport (open-output-file file))
	 (ans (with-error-to-port nport thunk)))
    (close-port nport)
    ans))

(define (error . args)
  (define cep (current-error-port))
  (perror "ERROR")
  (errno 0)
  (display "ERROR: " cep)
  (if (not (null? args))
      (begin (display (car args) cep)
	     (for-each (lambda (x) (display #\  cep) (write x cep))
		       (cdr args))))
  (newline cep)
  (force-output cep)
  (abort))

(define set-errno errno)
(define exit quit)

(define (file-exists? str)
  (let ((port (open-file str OPEN_READ)))
    (if port (begin (close-port port) #t)
	#f)))

(if (memq 'line-i/o *features*)
    (define (write-line str . arg)
      (apply display str arg)
      (apply newline arg)))

(if (memq 'pipe *features*)
    (define (open-input-pipe str) (open-pipe str "r")))
(if (memq 'pipe *features*)
    (define (open-output-pipe str) (open-pipe str "w")))

(if (not (memq 'ed *features*))
    (begin
      (define (ed . args)
	(system (apply string-append
		       (or (getenv "EDITOR") "ed")
		       (map (lambda (s) (string-append " " s)) args))))
      (set! *features* (cons 'ed *features*))))

(if (not (defined? output-port-width))
    (define (output-port-width . arg) 80))

(if (not (defined? output-port-height))
    (define (output-port-height . arg) 24))

(define (has-suffix? str suffix)
  (let ((sufl (string-length suffix))
	(sl (string-length str)))
    (and (> sl sufl)
	 (string=? (substring str (- sl sufl) sl) suffix))))

(define slib:error error)
(define slib:tab #\tab)
(define slib:form-feed #\page)
(define slib:eval eval)

;;; Load.
(define (scm:load file . libs)
  (define sfs (scheme-file-suffix))
  (define cep (current-error-port))
  (define filesuf file)
  (define hss (has-suffix? file sfs))
  (cond ((> (verbose) 1)
	 (display ";loading " cep) (write file cep) (newline cep)))
  (force-output cep)
  (or (and (defined? link:link) (not hss)
	   (or (apply link:link file libs)
	       (and link:able-suffix
		    (let ((fs (string-append file link:able-suffix)))
		      (cond ((not (file-exists? fs)) #f)
			    ((apply link:link fs libs) (set! filesuf fs) #t)
			    (else #f))))))
      (and (null? libs)
	   (or (try-load file)
	       ;;HERE is where the suffix gets specified
	       (and (not hss)
		    (begin (set! filesuf (string-append file sfs))
			   (try-load filesuf)))))
      (and (procedure? could-not-open) (could-not-open) #f)
      (error "LOAD couldn't find file " file))
  (errno 0)
  (cond ((> (verbose) 1)
	 (display ";done loading " cep) (write filesuf cep) (newline cep)
	 (force-output cep))))
(define load scm:load)
(define slib:load load)

(define (scm:load-source file)
  (define sfs (scheme-file-suffix))
  (define cep (current-error-port))
  (define filesuf file)
  (cond ((> (verbose) 1)
	 (display ";loading " cep) (write file cep) (newline cep)))
  (force-output cep)
  (or (and (or (try-load file)
	       ;;HERE is where the suffix gets specified
	       (and (not (has-suffix? file sfs))
		    (begin (set! filesuf (string-append file sfs))
			   (try-load filesuf)))))
      (and (procedure? could-not-open) (could-not-open) #f)
      (error "LOAD couldn't find file " file))
  (errno 0)
  (cond ((> (verbose) 1)
	 (display ";done loading " cep) (write filesuf cep) (newline cep)
	 (force-output cep))))
(define slib:load-source scm:load-source)

(cond ((try-load
	(in-vicinity (library-vicinity) "require" (scheme-file-suffix))))
      (else
       (perror "WARNING")
       (display "WARNING: Couldn't find require.scm in (library-vicinity)"
		(current-error-port))
       (write (library-vicinity) (current-error-port))
       (newline (current-error-port))
       (errno 0)))

;;; DO NOT MOVE!  This has to be done after "require.scm" is loaded.
(define slib:load-source scm:load-source)
(define slib:load scm:load)

(if (or (defined? dld:link)
	(defined? shl:load)
	(defined? vms:dynamic-link-call)
	(file-exists? (in-vicinity (implementation-vicinity) "hobbit.tms")))
    (try-load (in-vicinity (implementation-vicinity)
			   "Link" (scheme-file-suffix))))

(cond ((defined? link:link)
       (define slib:load-compiled link:link)
       (provide 'compiled)))

(define logical:logand logand)
(define logical:logior logior)
(define logical:logxor logxor)
(define logical:lognot lognot)
(define logical:ash ash)
(define logical:logcount logcount)
(define logical:integer-length integer-length)
(define logical:bit-extract bit-extract)
(define logical:integer-expt integer-expt)

(define (logical:ipow-by-squaring x k acc proc)
  (cond ((zero? k) acc)
	((= 1 k) (proc acc x))
	(else (logical:ipow-by-squaring (proc x x)
					(quotient k 2)
					(if (even? k) acc (proc acc x))
					proc))))

;defmacro from dorai@cs.rice.edu (heavily hacked by jaffer):
(define *defmacros* '())
(define (macro? m) (and (assq m *defmacros*) #t))

(define defmacro:transformer
  (lambda (f)
    (procedure->memoizing-macro
      (lambda (exp env)
	(copy-tree (apply f (cdr exp)))))))

(define defmacro
  (let ((defmacro-transformer
	  (lambda (name parms . body)
	    `(define ,name
	       (let ((transformer (lambda ,parms ,@body)))
		 (set! *defmacros* (acons ',name transformer *defmacros*))
		 (defmacro:transformer transformer))))))
    (set! *defmacros* (acons 'defmacro defmacro-transformer *defmacros*))
    (defmacro:transformer defmacro-transformer)))

(define (macroexpand-1 e)
  (if (pair? e) (let ((a (car e)))
		  (cond ((symbol? a) (set! a (assq a *defmacros*))
				     (if a (apply (cdr a) (cdr e)) e))
			(else e)))
      e))

(define (macroexpand e)
  (if (pair? e) (let ((a (car e)))
		  (cond ((symbol? a)
			 (set! a (assq a *defmacros*))
			 (if a (macroexpand (apply (cdr a) (cdr e))) e))
			(else e)))
      e))

(define gentemp
  (let ((*gensym-counter* -1))
    (lambda ()
      (set! *gensym-counter* (+ *gensym-counter* 1))
      (string->symbol
       (string-append "scm:G" (number->string *gensym-counter*))))))

(define defmacro:eval slib:eval)
(define defmacro:load load)

(define (slib:eval-load <filename> evl)
  (if (not (file-exists? <filename>))
      (set! <filename> (string-append <filename> (scheme-file-suffix))))
  (call-with-input-file <filename>
    (lambda (port)
      (let ((old-load-pathname *load-pathname*))
	(set! *load-pathname* <filename>)
	(do ((o (read port) (read port)))
	    ((eof-object? o))
	  (evl o))
	(set! *load-pathname* old-load-pathname)))))

;;; Autoloads for SLIB procedures.

(define (tracef . args) (require 'debug) (apply tracef args))
(define *traced-procedures* '())
(define (trace:tracef fun sym)
  (cond ((memq sym *traced-procedures*)
	 (display "WARNING: already traced " (current-error-port))
	 (display sym (current-error-port))
	 (newline (current-error-port))
	 fun)
	(else
	 (set! *traced-procedures* (cons sym *traced-procedures*))
	 (tracef fun sym))))
(define (trace:untracef fun sym)
  (require 'common-list-functions)
  (cond ((memq sym *traced-procedures*)
	 (set! *traced-procedures* (remove sym *traced-procedures*))
	 (untracef fun))
	(else
	 (display "WARNING: not traced " (current-error-port))
	 (display sym (current-error-port))
	 (newline (current-error-port))
	 fun)))

;;; Macros.

(defmacro trace x
  (if (null? x) '*traced-procedures*
      `(begin ,@(map (lambda (x) `(set! ,x (trace:tracef ,x ',x))) x))))
(defmacro untrace x
  (if (null? x)
      (slib:eval
       `(begin ,@(map (lambda (x) `(set! ,x (trace:untracef ,x ',x)))
		      *traced-procedures*)
	       '',*traced-procedures*))
      `(begin ,@(map (lambda (x) `(set! ,x (trace:untracef ,x ',x))) x))))

(defmacro defvar (var val)
  `(if (not (defined? ,var)) (define ,var ,val)))

;;; ABS and MAGNITUDE can be the same.
(if (inexact? (string->number "0.0"))
    (begin (load (in-vicinity (implementation-vicinity)
			      "Transcen" (scheme-file-suffix)))
	   (set! abs magnitude)))

(if (defined? array?)
    (begin
      (define uniform-vector? array?)
      (define make-uniform-vector dimensions->uniform-array)
;      (define uniform-vector-ref array-ref)
      (define (uniform-vector-set! u i o)
	(uniform-vector-set1! u o i))
      (define uniform-vector-fill! array-fill!)

      (define (make-array fill . args)
	(dimensions->uniform-array args () fill))
      (define (make-uniform-array prot . args)
	(dimensions->uniform-array args prot))
      (define (list->array ndim lst)
	(list->uniform-array ndim '() lst))
      (define (list->uniform-vector prot lst)
	(list->uniform-array 1 prot lst))
      (define (array-shape a)
	(map (lambda (ind) (if (number? ind) (list 0 (+ -1 ind)) ind))
	     (array-dimensions a)))))

;;; Use *argv* instead of (program-arguments), to allow option
;;; processing to be done on it.
(define *argv* (program-arguments))

;;; This loads the user's initialization file, or files named in
;;; program arguments.

(or
 (eq? (software-type) 'THINKC)
 (member "-no-init-file" (program-arguments))
 (try-load
  (in-vicinity
   (let ((home (getenv "HOME")))
     (if home
	 (case (software-type)
	   ((UNIX COHERENT)
	    (if (char=? #\/ (string-ref home (+ -1 (string-length home))))
		home			;V7 unix has a / on HOME
		(string-append home "/")))
	   (else home))
	 (user-vicinity)))
   "ScmInit.scm"))
 (errno 0))

(if (not (defined? *R4RS-macro*))
    (define *R4RS-macro* #f))
(if (not (defined? *interactive*))
    (define *interactive* #f))

(cond
 ((and (> (length *argv*) 1) (char=? #\- (string-ref (cadr *argv*) 0)))
  (require 'getopt)
;;; (else
;;;  (define *optind* 1)
;;;  (define getopt:opt #f)
;;;  (define (getopt argc argv optstring) #f))

  (let* ((simple-opts "muqvbis")
	 (arg-opts '("a kbytes" "no-init-file" "p number"
				"r feature" "f filename" "l filename"
				"c string" "e string"))
	 (opts (apply string-append ":" simple-opts
		      (map (lambda (o)
			     (string-append (string (string-ref o 0)) ":"))
			   arg-opts)))
	 (argc (length *argv*))
	 (didsomething #f)
	 (moreopts #t))

    (define (do-thunk thunk)
      (if *interactive*
	  (thunk)
	  (let ((complete #f))
	    (dynamic-wind
	     (lambda () #f)
	     (lambda ()
	       (thunk)
	       (set! complete #t))
	     (lambda () (if (not complete) (quit)))))))

    (define (do-string-arg)
      (require 'string-port)
      (do-thunk
       (lambda ()
	 (eval
	  (call-with-input-string
	   (string-append "(begin " *optarg* ")")
	   read))))
      (set! didsomething #t))

    (define (do-load file)
      (do-thunk
       (lambda ()
	 (cond (*R4RS-macro* (require 'macro) (macro:load file))
	       (else (load file)))))
      (set! didsomething #t))

    (define (usage preopt opt postopt)
      (define cep (current-error-port))
      (define indent (make-string 6 #\ ))
      (define i 2)
      (if (char? opt) (set! opt (string opt)))
      (display (string-append preopt opt postopt) cep)
      (newline cep)
      (display (string-append "Usage: " (car (program-arguments))
			      " [-" simple-opts "]") cep)
      (for-each
       (lambda (o)
	 (display (string-append " [-" o "]") cep)
	 (set! i (+ 1 i))
	 (cond ((zero? (modulo i 4)) (newline cep) (display indent cep))))
       arg-opts)
      (display " [-- | -s | -] [file] [args...]" cep) (newline cep)
      (exit 1))

    ;; -c str => (eval str)
    ;; -e str => (eval str)
    ;; -f str => (load str)
    ;; -l str => (load str)
    ;; -r str => (require str)
    ;; -p int => (verbose int)
    ;; -m     => (set! *R4RS-macro* #t)
    ;; -u     => (set! *R4RS-macro* #f)
    ;; -v     => (verbose 3)
    ;; -q     => (verbose 0)
    ;; -i     => (set! *interactive* #t)
    ;; -b     => (set! *interactive* #f)
    ;; -s     => set argv, don't execute first one
    ;; -no-init-file => don't load init file
    ;; --     => last option

    (let loop ()
      (case (getopt argc *argv* opts)
	((#\e #\c) (do-string-arg))	;sh-like
	((#\f #\l);;(set-car! *argv* *optarg*)
	 (do-load *optarg*))
	((#\r) (do-thunk (lambda ()
			   (if (and (= 1 (string-length *optarg*))
				    (char-numeric? (string-ref *optarg* 0)))
			       (case (string-ref *optarg* 0)
				 ((#\2) (require 'rev3-procedures)
					(require 'rev2-procedures))
				 ((#\3) (require 'rev3-procedures))
				 ((#\4) (require 'rev4-optional-procedures))
				 ((#\5) (require 'dynamic-wind)
					(require 'values)
					(require 'macro)
					(set! *R4RS-macro* #t))
				 (else (require (string->symbol *optarg*))))
			       (require (string->symbol *optarg*))))))
	((#\p) (verbose (string->number *optarg*)))
	((#\q) (verbose 0))
	((#\v) (verbose 3))
	((#\i) (set! *interactive* #t)	;sh-like
	       (verbose (max 2 (verbose))))
	((#\b) (set! *interactive* #f))
	((#\s) (set! moreopts #f)	;sh-like
	       (set! didsomething #t)
	       (set! *interactive* #t))
	((#\m) (set! *R4RS-macro* #t))
	((#\u) (set! *R4RS-macro* #f))
	((#\n) (if (not (string=? "o-init-file" *optarg*))
		   (usage "scm: unrecognized option `-n" *optarg* "'")))
	((#\:) (usage "scm: option `-" getopt:opt "' requires an argument"))
	((#\?) (usage "scm: unrecognized option `-" getopt:opt "'"))
	((#f) (set! moreopts #f)	;sh-like
	      (cond ((and (< *optind* (length *argv*))
			  (string=? "-" (list-ref *argv* *optind*)))
		     (set! *optind* (+ 1 *optind*)))))
	(else (usage "scm: unknown option `-" getopt:opt "'")))

      (cond ((and moreopts (< *optind* (length *argv*)))
	     (loop))
	    ((< *optind* (length *argv*)) ;No more opts
	     (set! *argv* (list-tail *argv* *optind*))
	     (set! *optind* 1)
	     (cond ((not didsomething) (do-load (car *argv*))
				       (set! *optind* (+ 1 *optind*))))
	     (cond ((and (> (verbose) 2)
			 (not (= (+ -1 *optind*) (length *argv*))))
		    (display "scm: extra command arguments unused:"
			     (current-error-port))
		    (for-each (lambda (x) (display (string-append " " x)
						   (current-error-port)))
			      (list-tail *argv* (+ -1 *optind*)))
		    (newline (current-error-port)))))
	    ((and (not didsomething) (= *optind* (length *argv*)))
	     (set! *interactive* #t)))))

  (cond ((not *interactive*) (quit))
	(*R4RS-macro*
	 (require 'repl)
	 (require 'macro)
	 (let* ((oquit quit))
	   (set! quit (lambda () (repl:quit)))
	   (set! exit quit)
	   (repl:top-level macro:eval)
	   (oquit))))
  ;;otherwise, fall into non-macro SCM repl.
  )
 (else
  (begin (errno 0)
	 (for-each load (cdr (program-arguments))))))
