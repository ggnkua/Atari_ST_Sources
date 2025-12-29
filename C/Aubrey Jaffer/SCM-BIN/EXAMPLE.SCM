;From Revised^4 Report on the Algorithmic Language Scheme
;William Clinger and Jonathon Rees (Editors)

;			       EXAMPLE

;INTEGRATE-SYSTEM integrates the system 
;	y_k' = f_k(y_1, y_2, ..., y_n), k = 1, ..., n
;of differential equations with the method of Runge-Kutta.

;The parameter SYSTEM-DERIVATIVE is a function that takes a system
;state (a vector of values for the state variables y_1, ..., y_n) and
;produces a system derivative (the values y_1', ..., y_n').  The
;parameter INITIAL-STATE provides an initial system state, and H is an
;initial guess for the length of the integration step.

;The value returned by INTEGRATE-SYSTEM is an infinite stream of
;system states.

(define integrate-system
  (lambda (system-derivative initial-state h)
    (let ((next (runge-kutta-4 system-derivative h)))
      (letrec ((states
		(cons initial-state
		      (delay (map-streams next states)))))
	states))))

;RUNGE-KUTTA-4 takes a function, F, that produces a
;system derivative from a system state.  RUNGE-KUTTA-4
;produces a function that takes a system state and
;produces a new system state.

(define runge-kutta-4
  (lambda (f h)
    (let ((*h (scale-vector h))
	  (*2 (scale-vector 2))
	  (*1/2 (scale-vector (/ 1 2)))
	  (*1/6 (scale-vector (/ 1 6))))
      (lambda (y)
	;; Y is a system state
	(let* ((k0 (*h (f y)))
	       (k1 (*h (f (add-vectors y (*1/2 k0)))))
	       (k2 (*h (f (add-vectors y (*1/2 k1)))))
	       (k3 (*h (f (add-vectors y k2)))))
	  (add-vectors y
		       (*1/6 (add-vectors k0
					  (*2 k1)
					  (*2 k2)
					  k3))))))))

(define elementwise
  (lambda (f)
    (lambda vectors
      (generate-vector
       (vector-length (car vectors))
       (lambda (i)
	 (apply f
		(map (lambda (v) (vector-ref  v i))
		     vectors)))))))

(define generate-vector
  (lambda (size proc)
    (let ((ans (make-vector size)))
      (letrec ((loop
		(lambda (i)
		  (cond ((= i size) ans)
			(else
			 (vector-set! ans i (proc i))
			 (loop (+ i 1)))))))
	(loop 0)))))

(define add-vectors (elementwise +))

(define scale-vector
  (lambda (s)
    (elementwise (lambda (x) (* x s)))))

;MAP-STREAMS is analogous to MAP: it applies its first
;argument (a procedure) to all the elements of its second argument (a
;stream).

(define map-streams
  (lambda (f s)
    (cons (f (head s))
	  (delay (map-streams f (tail s))))))

;Infinite streams are implemented as pairs whose car holds the first
;element of the stream and whose cdr holds a promise to deliver the rest
;of the stream.

(define head car)
(define tail
  (lambda (stream) (force (cdr stream))))


;The following illustrates the use of INTEGRATE-SYSTEM in
;integrating the system
;
;			     dvC	vC
;			   C --- = -i - --
;			     dt	     L	 R
;
;				diL
;			      L --- = v
;				dt     C
;
;which models a damped oscillator.

(define damped-oscillator
  (lambda (R L C)
    (lambda (state)
      (let ((Vc (vector-ref state 0))
	    (Il (vector-ref state 1)))
	(vector (- 0 (+ (/ Vc (* R C)) (/ Il C)))
		(/ Vc L))))))

(define the-states
  (integrate-system
   (damped-oscillator 10000 1000 .001)
   '#(1 0)
   .01))

(do ((i 10 (- i 1))
     (s the-states (tail s)))
    ((zero? i) (newline))
  (newline)
  (write (head s)))

; #(1 0)
; #(0.99895054 9.994835e-6)
; #(0.99780226 1.9978681e-5)
; #(0.9965554 2.9950552e-5)
; #(0.9952102 3.990946e-5)
; #(0.99376684 4.985443e-5)
; #(0.99222565 5.9784474e-5)
; #(0.9905868 6.969862e-5)
; #(0.9888506 7.9595884e-5)
; #(0.9870173 8.94753e-5)
