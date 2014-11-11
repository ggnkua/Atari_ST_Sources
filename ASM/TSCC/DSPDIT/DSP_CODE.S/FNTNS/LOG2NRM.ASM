;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Normalizing Base 2 Logarithm Macro
; 
; Last Update 30 Mar 87   Version 1.0
;
log2nrm macro
log2nrm ident   1,0
;
;       This program calculates the base 2 logarithm of an unnormalized
;       24 bit fraction "x" in register A and returns a scaled fraction
;       "y" in register A.
;
;       y = log2(x)/32.0        where   2**(-23) =< x < 1.0
;                                       -23/32 =< y < 0.0
;
;       Note - "x" must be a non-zero, positive fraction.
;
;       Three steps are required.
;
;       1. Normalize "x" so that 0.5 =< A < 1.0.
;       2. Calculate the log2(A).
;       3. Divide the result by 32.0
;
;
;       Step 1 - Normalize A to get value between .5 and 1.0
;
        move    #-1,m1          ;linear addressing
        move    m1,m7
        move    m7,r7           ;initial count = -1
        rep     #23             ;normalize to between .5 and 1.0
        norm    r7,a            ;shift left and decrement r7 if needed
        move    #pcoef,r1       ;point to polynomial coefficients for log2
        move    a,x0            ;put normalized number in x0
;
;       Step 2 - Calculate LOG2 by polynomial approximation.  8 Bit accuracy.
;
;       LOG2(x) = 4.0* (-.3372223 x*x + .9981958 x - .6626105)
;                           a2             a1            a0
;       where  0.5 <= x < 1.0
;
;       r1 initially points to the coefficients in y memory in the
;       order: a1,a2,a0
;
        mpyr    x0,x0,a  y:(r1)+,y0     ;x**2, get a1
        mpy     x0,y0,a  a,x1 y:(r1)+,y0        ;a1*x, mv x**2, get a2
        mac     x1,y0,a  y:(r1)+,y0     ;a2* x**2, get a0
        add     y0,a                    ;add in a0
        asl     a                       ;multiply by 4
        asl     a
;
;       Step 3 - Divide result by 32.
;
        asl     a                       ;shift out sign bit
        move    r7,a2                   ;new sign = characteristic
        rep     #6                      ;divide by 32, create sign bit
        asr     a
        rnd     a                       ;round result
        endm
