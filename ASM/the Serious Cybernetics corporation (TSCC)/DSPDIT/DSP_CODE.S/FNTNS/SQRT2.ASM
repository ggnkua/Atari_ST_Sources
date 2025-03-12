;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Square Root by Polynomial Approximation, 10-bit Accuracy.
; 
; Last Update 26 Jan 87   Version 1.0
;
sqrt2   macro
sqrt2   ident   1,0
;
;       Does a square root by polynomial aproximation, 10 bit accuracy.
;       sqrt(x)=-.1985987*x*x+.8803385*x+.3175231
;       valid for:  .5<= x < 1.0
;
;       input value in x0, output in register A.
;
;       r1 initially points to the coefficients in y memory in this
;       order: a1,a2,a0
;
        mpyr    x0,x0,a  y:(r1)+,y0     ;x**2, get a1
        mpy     x0,y0,a  a,x1 y:(r1)+,y0        ;a1*x, mv x**2, get a2
        macr    x1,y0,a  y:(r1)+,y0     ;a2* x**2, get a0
        add     y0,a                    ;add in a0
        endm
