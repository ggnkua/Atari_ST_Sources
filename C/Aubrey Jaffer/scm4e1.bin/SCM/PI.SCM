;;;; "pi.scm", program for computing digits of numerical value of PI.
;;; Copyright (C) 1991 Aubrey Jaffer.
;;; See the file `COPYING' for terms applying to this program.

;;; (pi <n> <d>) prints out <n> digits of pi in groups of <d> digits.

;;; 'Spigot' algorithm origionally due to Stanly Rabinowitz.
;;; This algorithm takes time proportional to the square of <n>/<d>.
;;; This fact can make comparisons of computational speed between systems
;;; of vastly differring performances quicker and more accurate.

;;; Try (pi 100 5)
;;; The digit size <d> will have to be reduced for larger <n> or an
;;; overflow error will occur (on systems lacking bignums).

;;; It your Scheme has bignums try (pi 1000).

(define (pi n  . args)
  (if (null? args) (bigpi n)
      (let* ((d (car args))
	     (r (do ((s 1 (* 10 s))
		     (i 0 (+ 1 i)))
		    ((>= i d) s)))
	     (n (+ (quotient n d) 1))
	     (m (quotient (* n d 3322) 1000))
	     (a (make-vector (+ 1 m) 2)))
	(vector-set! a m 4)
	(do ((j 1 (+ 1 j))
	     (q 0 0)
	     (b 2 (remainder q r)))
	    ((> j n))
	  (do ((k m (- k 1)))
	      ((zero? k))
	    (set! q (+ q (* (vector-ref a k) r)))
	    (let ((t (+ 1 (* 2 k))))
	      (vector-set! a k (remainder q t))
	      (set! q (* k (quotient q t)))))
	  (let ((s (number->string (+ b (quotient q r)))))
	    (do ((l (string-length s) (+ 1 l)))
		((>= l d) (display s))
	      (display #\0)))
	  (if (zero? (modulo j 10)) (newline) (display #\ )))
	(newline))))

;;; "bigpi.scm", program for computing digits of numerical value of PI.
;;; Copyright (C) 1993 Jerry D. Hedden
;;; See the file `COPYING' for terms applying to this program.

;;; (pi <n>) prints out <n> digits of pi.

;;; 'Spigot' algorithm originally due to Stanly Rabinowitz:
;;;
;;; PI = 2+(1/3)*(2+(2/5)*(2+(3/7)*(2+ ... *(2+(k/(2k+1))*(4)) ... )))
;;;
;;; where 'k' is approximately equal to the desired precision of 'n'
;;; places times 'log2(10)'.
;;;
;;; This version takes advantage of "bignums" in SCM to compute all
;;; of the requested digits in one pass!  Basically, it calculates
;;; the truncated portion of (PI * 10^n), and then displays it in a
;;; nice format.

(define (bigpi digits)
  (let* ((n (* 10 (quotient (+ digits 9) 10)))	; digits in multiples of 10
	 (q (do ((x 2 (* 10000000000 x))	; q = 2 * 10^n
		 (i 0 (+ 1 i)))
		((>= i (/ n 10)) x)))
	 (_pi (+ q q))				; _pi = result variable
	 (z (inexact->exact (truncate (/ (* n (log 10)) (log 2))))))
						; z = number of iterations
      ; do the calculations in one pass!!!
      (do ((j     z     (- j 1))
	   (k (+ z z 1) (- k 2)))
	  ((zero? j))
	  (set! _pi (+ q (quotient (* _pi j) k))))
      ; print out the result
      (set! _pi (number->string _pi))			; _pi = PI * 10^n
      (display (substring _pi 0 1)) (display #\.)	; displays "3."
      (newline)
      (do ((i 0 (+ i 10)))				; groups of 10 digits
	  ((>= i n))					;   5 groups per line
	  (display (substring _pi (+ i 1) (+ i 11)))
	  (display (if (zero? (modulo (+ i 10) 50)) #\newline #\ )))
      (if (not (zero? (modulo n 50))) (newline))))
