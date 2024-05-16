;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Square Root by Polynomial Approximation, 7-bit Accuracy.
; 
; Last Update 26 Jan 87   Version 1.0
;
sqrt1   macro
sqrt1   ident   1,0
;
;       Does a square root by polynomial aproximation, 7 bit accuracy.
;       sqrt(x)=-.2831102*x*x+2*.5031642*x+.272661
;                  a2             a1          a0
;       valid for:  .25<= x < 1.0
;
;       input value in x0, output in regester A.
;
;       r1 initially points to the coefficients in y memory in
;       this order: a1, a2, a0.
;
;
        mpyr    x0,x0,a  y:(r1)+,y0 ;x**2, get a1
        mpy     x0,y0,a  a,x1           ;x*a1, save x**2
        mac     x0,y0,a  y:(r1)+,y0     ;2*x*a1, get a2
        macr    x1,y0,a  y:(r1)+,y0     ;a2* x**2, get a0
        add     y0,a                    ;add in a0
        endm
