;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Exponential Base 2 by Polynomial Approximation
; 
; Last Update 26 Jan 87   Version 1.0
;
exp2    macro
exp2    ident   1,0
;
;       Does 2**(x) by polynomial approximation, 8 bit accuracy.
;       2**(x)=.1713425*x*x+.6674432*x+.9979554
;                 a2          a1         a0
;       valid for -1<= x <=0
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
