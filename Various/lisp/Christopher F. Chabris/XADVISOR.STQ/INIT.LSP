; INIT.LSP for XLisp Version 1.5b
; Modified by Christopher F. Chabris


; Get some more memory - this should be OK with TOS on disk
;  if there are no RAMdisks:
(expand 9)

; Some more cxr functions:
(defun caaar (x) (car (caar x)))
(defun cdaar (x) (cdr (caar x)))
(defun caadr (x) (car (cadr x)))
(defun cdadr (x) (cdr (cadr x)))
(defun cadar (x) (car (cdar x)))
(defun cddar (x) (cdr (cdar x)))
(defun caddr (x) (car (cddr x)))
(defun cdddr (x) (cdr (cddr x)))

; Some fake definitions for Common Lisp pseudo-compatiblity:
(setq first car)
(setq second cadr)
(setq third caddr)
(setq rest cdr)


; (when test code...) - execute code when test is true:
(defmacro when (test &rest code)
  `(cond (,test ,@code)))

; (unless test code...) - execute code unless test is true:
(defmacro unless (test &rest code)
  `(cond ((not ,test) ,@code)))

; (makunbound sym) - make a symbol be unbound:
(defun makunbound (sym)
  (setq sym '*unbound*)
  sym)

; (objectp expr) - object predicate:
(defun objectp (x)
  (eq (type-of x) :OBJECT))

; (filep expr) - file predicate:
(defun filep (x)
  (eq (type-of x) :FILE))

; (unintern sym) - remove a symbol from the oblist:
(defun unintern (sym)
  (cond ((member sym *oblist*)
         (setq *oblist* (delete sym *oblist*))
          t)
         (t nil)))

; (mapcan ...)
(defmacro mapcan (&rest args)
  `(apply #'nconc (mapcar ,@args)))

; (mapcon ...)
(defmacro mapcon (&rest args)
  `(apply #'nconc (maplist ,@args)))

; (save fun) - save a function definition to a file:
(defmacro save (fun)
  `(let* ((fname (strcat (symbol-name ',fun) ".lsp"))
          (fval ',fun)
          (fp (openo fname)))
         (cond (fp (print (cons (if (eq (car fval) 'lambda)
                                    'defun
                                    'defmacro)
                                (cons fun (cdr fval))) fp)
                   (close fp)
                   fname)
               (t nil))))

; (debug) - enable debug breaks:
(defun debug ()
  (setq *breakenable* t))

; (nodebug) - disable debug breaks:
(defun nodebug ()
  (setq *breakenable* nil))

; initialize to enable breaks but no traceback:
(setq *breakenable* t)
(setq *tracenable* nil)


; load the pretty-printer:
(load "pprint.lsp")

; display the memory statistics:
(mem)

