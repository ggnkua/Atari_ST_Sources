; Assuming that the name of the XScheme executable file is:
;	xs_xxx
; you can run the benchmark by typing:
;	xs_xxx bench.s
; from the DOS prompt.  If the executable uses the PharLap DOS
; extender, type:
;	run386 xs_xxx bench.s
; instead
;
(define (bench expr)
  (let ((gc-start (gc))
	(start (time)))
    (eval expr)
    (let ((end (time))
	  (gc-end (gc)))
      (write expr)
      (display ", elapsed time: ")
      (write (difftime end start))
      (display ", gc calls: ")
      (write (- (car gc-end) (car gc-start) 1))
      (display ", memory: ")
      (write (list-ref gc-end 5))
      (newline))))

(define (fib n)
  (cond ((= n 0) 0)
	((= n 1) 1)
	(else (+ (fib (- n 1))
	         (fib (- n 2))))))

(bench '(fib 25))

(exit)
