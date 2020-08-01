(define %compile compile)

(define (%expand-macros expr)
  (if (pair? expr)
    (if (symbol? (car expr))
      (let ((expander (get (car expr) '%syntax)))
        (if expander
          (expander expr)
          (let ((expander (get (car expr) '%macro)))
            (if expander
              (%expand-macros (expander expr))
              (cons (car expr) (%expand-list (cdr expr)))))))
      (%expand-list expr))
    expr))

(define (%expand-list lyst)
  (if (pair? lyst)
    (cons (%expand-macros (car lyst)) (%expand-list (cdr lyst)))
    lyst))

(define (compile expr #!optional env)
  (if (default-object? env)
    (%compile (%expand-macros expr))
    (%compile (%expand-macros expr) env)))

(put 'macro '%macro
  (lambda (form)
    (list 'put
          (list 'quote (cadr form))
          (list 'quote '%macro)
          (caddr form))))

(macro syntax
  (lambda (form)
    #f))

(macro compiler-syntax
  (lambda (form)
    (list 'put
          (list 'quote (cadr form))
          (list 'quote '%syntax)
          (caddr form))))

(compiler-syntax quote
  (lambda (form) form))
	  
(compiler-syntax lambda
  (lambda (form)
    (cons
      'lambda
      (cons
        (cadr form)
        (%expand-list (cddr form))))))

(compiler-syntax define
  (lambda (form)
    (cons
      'define
      (cons
        (cadr form)
        (%expand-list (cddr form))))))
  
(compiler-syntax set!
  (lambda (form)
    (cons
      'set!
      (cons
        (cadr form)
        (%expand-list (cddr form))))))

(define (%cond-expander lyst)
  (cond
      ((pair? lyst)
       (cons
         (if (pair? (car lyst))
           (%expand-list (car lyst))
           (car lyst))
         (%cond-expander (cdr lyst))))
      (else lyst)))

(compiler-syntax cond
  (lambda (form)
    (cons 'cond (%cond-expander (cdr form)))))

; The following code for expanding let/let*/letrec was donated by:
;
; Harald Hanche-Olsen
; The University of Trondheim
; The Norwegian Institute of Technology
; Division of Mathematics
; N-7034 Trondheim NTH
; Norway

(define (%expand-let-assignment pair)
  (if (pair? pair)
    (cons
      (car pair)
      (%expand-macros (cdr pair)))
    pair))

(define (%expand-let-form form)
  (cons
    (car form)
    (cons
      (let ((lyst (cadr form)))
        (if (pair? lyst)
          (map %expand-let-assignment lyst)
          lyst))
      (%expand-list (cddr form)))))

(compiler-syntax let %expand-let-form)
(compiler-syntax let* %expand-let-form)
(compiler-syntax letrec %expand-let-form)

(macro define-integrable
  (lambda (form)
    (cons 'define (cdr form))))

(macro declare
  (lambda (form) #f))
