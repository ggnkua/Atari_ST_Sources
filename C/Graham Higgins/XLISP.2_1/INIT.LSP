; Initialisation file for XLISP 2.0

; get some more memory
(defun grow ()
	(alloc 4000)
	(expand 9))

; (debug) --- enable debug breaks
(defun debug ()
	(setq *breakenable* t))

; (nodebug) --- disable debug breaks
(defun nodebug ()
	(setq *breakenable* ()))

; initialise to enable breaks but no traceback
(defun btrace ()
	(setq *tracelimit* 2)
	(setq *tracenable* T))

(defun nobtrace ()
	(setq *tracenable* ()))

(setq *breakenable* T)

(debug)

(btrace)

(defun mapcan (x y)
	(apply #'nconc (mapcar x y)))


