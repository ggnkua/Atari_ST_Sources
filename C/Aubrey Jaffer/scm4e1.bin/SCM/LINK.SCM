;;;; "Link.scm", Compiling and dynamic linking code for SCM.
;;; Copyright (C) 1993, 1994 Aubrey Jaffer.
;;; See the file `COPYING' for terms applying to this program.

(define cc:command
  (let ((default "cc -c"))	;-O removed for HP-UX self-compile
    (case (software-type)
      ((unix) (if (memq 'sun-dl *features*)
		  "gcc -g -O -fpic -c" ; If you have problems change -fpic to
		                       ; -fPIC (see GCC info pages).
		  default))
      (else default))))

(define link:command
  (case (software-type)
    (else "cc")))

(define scm:object-suffix
  (case (software-type)
    ((MSDOS VMS) ".OBJ")
    (else ".o")))

(if (not (defined? hobbit))		;Autoload for hobbit
    (define (hobbit . args)
      (require (in-vicinity (implementation-vicinity) "hobbit"))
      (apply hobbit args)))

(define (compile-file file . args)
  (apply hobbit file args)
  (let ((do-compile (lambda (str)
		      (if (>= (verbose) 3) (begin (display str) (newline)))
		      (system str)))
	(str (string-append
	      cc:command" -I"(implementation-vicinity)
	      " -DHOBBIT "(descmify file)".c")))
    (if (memq 'sun-dl *features*)	; Using sun dynamic linking.
	(let* ((tmp (tmpnam))
	       (sunstr (string-append
			str " -o " tmp
;;; The following is the magic incantation used to produce dynamically
;;; linkable object files under SunOS 4.1.x.  Under Solaris 2.x I
;;; believe it'll be something like "ld -G -ztext -o".
			"; ld -assert pure-text -o "
			(descmify file) scm:object-suffix " " tmp
			"; rm -f " tmp)))
	  (do-compile sunstr))
	(do-compile str))))

(define (link-named-scm name . modules)
  (let* ((iv (implementation-vicinity))
	 (oss (string-append scm:object-suffix " "))
	 (str (string-append
	       link:command" -o "name" -I"iv " -DINITS="
	       (apply string-append
		      (map (lambda (n)
			     (string-append "\\;init_" n "\\(\\)"))
			   modules))
	       "\\; "iv"scm.c "
	       iv"time"oss iv"repl"oss iv"escl"oss
	       iv"sys"oss iv"eeval"oss iv"subr"oss iv"eunif"oss
	       (apply string-append
		      (map (lambda (n) (string-append n oss)) modules)))))
    (cond ((>= (verbose) 3)
	   (display str) (newline)))
    (system str)))

(define (compile file . args)		;for backwards compatability.
  (apply hobbit file args)
  (link-named-scm (descmify file) "sc2"))

;;;; Dynamic linking/loading

(cond
 ((or (defined? dld:link) (defined? shl:load))
  (define link:modules '())
  (define link:able-suffix ".o")
  (define link:link
    (let ((link (if (defined? dld:link) dld:link shl:load))
	  (unlink (if (defined? dld:link) dld:unlink shl:unload))
	  (call (if (defined? dld:link)
		    (lambda (name package) (dld:call name))
		    shl:call)))
      (lambda (file . libs)
	(let* ((sl (string-length file))
	       (lasl (string-length link:able-suffix))
	       (*vicinity-suffix*
		(case (software-type)
		  ((NOSVE)	'(#\: #\.))
		  ((AMIGA)	'(#\: #\/))
		  ((UNIX)	'(#\/))
		  ((VMS)	'(#\: #\]))
		  ((MSDOS ATARIST OS/2)	'(#\\))
		  ((MACOS THINKC)	'(#\:))))
	       (fname (let loop ((i (- sl 1)))
			(cond ((negative? i) file)
			      ((memv (string-ref file i) *vicinity-suffix*)
			       (substring file (+ i 1) sl))
			      (else (loop (- i 1))))))
	       (nsl (string-length fname))
	       (name (cond ((< nsl lasl) fname)
			   ((string-ci=? (substring fname (- nsl lasl) nsl)
					 link:able-suffix)
			    (substring fname 0 (- nsl lasl)))
			   (else fname)))
	       (linkobj #f))
	  (set! linkobj (assoc name link:modules))
	  (cond (linkobj (unlink (cdr linkobj))))
	  (set! linkobj (link file))
	  (for-each link libs)
	  (cond ((not linkobj) #f)
		((call (string-append "init_" name) linkobj)
		 (set! link:modules (acons name linkobj link:modules)) #t)
		(else (unlink linkobj) #f))))))))

(cond
 ((defined? vms:dynamic-link-call)
  (define link:able-suffix #f)
  (define (link:link file)
    (define dir "")
    (define fil "")
    (let loop ((i (- (string-length file) 1)))
      (cond ((negative? i) (set! dir file))
	    ((memv (string-ref file i) '(#\: #\]))
	     (set! dir (substring file 0 (+ i 1)))
	     (set! fil (substring file (+ i 1) (string-length file))))
	    (else (loop (- i 1)))))
    (vms:dynamic-link-call dir fil (string-append "init_" fil)))))

(and (defined? *catalog*) (defined? link:link)
     (define (usr:lib lib)
       (string-append "/usr/lib/lib" lib ".a"))
     (define wb:vicinity (string-append (implementation-vicinity) "../wb/"))
     (define (catalog:add-link feature ofile . libs)
       (set! *catalog*
	     (acons feature (cons 'compiled (cons ofile libs)) *catalog*)))
     (catalog:add-link 'db
		       (in-vicinity wb:vicinity "db.o")
		       (in-vicinity wb:vicinity "handle.o")
		       (in-vicinity wb:vicinity "blink.o")
		       (in-vicinity wb:vicinity "prev.o")
		       (in-vicinity wb:vicinity "ent.o")
		       (in-vicinity wb:vicinity "sys.o")
		       (in-vicinity wb:vicinity "del.o")
		       (in-vicinity wb:vicinity "stats.o")
		       (in-vicinity wb:vicinity "blkio.o")
		       (in-vicinity wb:vicinity "scan.o")
		       (usr:lib "c"))
     (catalog:add-link 'turtle-graphics
		       (in-vicinity (implementation-vicinity) "turtlegr.o")
		       (usr:lib "X11")
		       (usr:lib "c")
		       (usr:lib "m"))
     (catalog:add-link 'curses
		       (in-vicinity (implementation-vicinity) "crs.o")
		       (usr:lib "ncurses")
		       (usr:lib "c"))
     (catalog:add-link 'regex
		       (in-vicinity (implementation-vicinity) "rgx.o")
		       (usr:lib "c"))
     (catalog:add-link 'rev2-procedures
		       (in-vicinity (implementation-vicinity) "sc2.o"))
     (set! *catalog* (append '((rev3-procedures . rev2-procedures)
			       (wb . db))
			     *catalog*)))
