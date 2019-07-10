;;; QQUOTE.S  01-14-89 11:34 AM by John Armstrong

;; Expands QUASIQUOTE/UNQUOTE/UNQUOTE according to Rev^3 Report specs.
;;
;; This file can be included as is in XSCHEME.INI, or can be incorporated 
;; into MACROS.S, with expander functions anywhere and macros after
;; after definition of COMPILER-SYNTAX

;;; EXPANDER-FUNCTIONS: compilable under the core XSCHEME, can be evaluated
;;; independently of MACRO system

(define APPEND-ME-SYM (gensym)) ;; must be a gensym to avoid capture in
				;; certain (pathological) situations

(define QQ-EXPANDER
  (lambda (l)
	  (letrec
	   (
	    (qq-lev 0) ; always >= 0
	    (QQ-CAR-CDR
	     (lambda (exp)
		     (let ((qq-car (qq (car exp)))
			   (qq-cdr (qq (cdr exp))))
			  (if (and (pair? qq-car)
				   (eq? (car qq-car) append-me-sym))
			      (list 'append (cdr qq-car) qq-cdr)
			      (list 'cons qq-car qq-cdr)))))
	    (QQ
	     (lambda (exp)
		     (cond ((symbol? exp)
			    (list 'quote exp))
			   ((vector? exp)
			    (list 'list->vector (qq (vector->list exp))))
			   ((atom? exp) ; nil, number or boolean
			    exp)
			   ((eq? (car exp) 'quasiquote)
			    (set! qq-lev (1+ qq-lev))
			    (let ((qq-val
				   (if (= qq-lev 1) ; min val after inc
				       ; --> outermost level
				       (qq (cadr exp))
				       (qq-car-cdr exp))))
				 (set! qq-lev (-1+ qq-lev))
				 qq-val))
			   ((or (eq? (car exp) 'unquote)
				(eq? (car exp) 'unquote-splicing))
			    (set! qq-lev (-1+ qq-lev))
			    (let ((qq-val
				   (if (= qq-lev 0) ; min val 
				       ; --> outermost level
				       (if (eq? (car exp) 'unquote-splicing)
					   (cons append-me-sym 
						 (%expand-macros (cadr exp)))
					   (%expand-macros (cadr exp))) 
				       (qq-car-cdr exp))))
				 (set! qq-lev (1+ qq-lev))
				 qq-val))
			   (else
			    (qq-car-cdr exp)))))
	    )
	   (let ((expansion (qq l)))
		(if check-qq-expansion-flag
		    (check-qq-expansion expansion)) ; error on failure
		expansion))))

(define CHECK-QQ-EXPANSION
  (lambda (exp)
	  (cond ((vector? exp)
		 (check-qq-expansion (vector->list exp)))
		((atom? exp)
		 #f)
		(else
		 (if (eq? (car exp) append-me-sym)
		     (error "UNQUOTE-SPLICING in unspliceable position"
			    (list 'unquote-splicing (cdr exp)))
		     (or (check-qq-expansion (car exp))
			 (check-qq-expansion (cdr exp))))))))

(define CHECK-QQ-EXPANSION-FLAG #t) ; do checking

(define UNQ-EXPANDER
  (lambda (l) (error "UNQUOTE outside QUASIQUOTE" l)))

(define UNQ-SPL-EXPANDER
  (lambda (l) (error "UNQUOTE SPLICING outside QUASIQUOTE" l)))

;;; MACROS: must be evaluated with MACRO system in place

(compiler-syntax QUASIQUOTE qq-expander)
(compiler-syntax UNQUOTE unq-expander)
(compiler-syntax UNQUOTE-SPLICING unq-spl-expander)

;;; END
