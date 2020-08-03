;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 5 Oct 87   Version 2.0
;
fpmpy   ident   2,0
;
; MOTOROLA DSP56000/1 FPLIB - VERSION 2
;
; FPMPY - FLOATING POINT MULTIPLICATION SUBROUTINE
;
; Entry points: fmpy_xy R = X * Y
;               fmpy_xa R = X * A
;
;       m = 24 bit mantissa (two's complement, normalized fraction)
;
;       e = 14 bit exponent (unsigned integer, biased by +8191)
;
; Input variables:
;
;   X   x1 = mx  (normalized)
;       x0 = ex
;
;   Y   y1 = my  (normalized)
;       y0 = ey
;
;   A   a2 = sign extension of ma
;       a1 = ma  (normalized)
;       a0 = zero
;
;       b2 = sign extension of ea (always zero)
;       b1 = ea
;       b0 = zero
;
; Output variables:
;
;   R   a2 = sign extension of mr
;       a1 = mr  (normalized)
;       a0 = zero
;
;       b2 = sign extension of er (always zero)
;       b1 = er
;       b0 = zero
;
; Error conditions:     Set CCR L=1 if floating point overflow.  Result
;                       is set to the maximum floating point value of the
;                       correct sign.  The CCR L bit remains set until
;                       cleared by the user.
;
;                       Set CCR L=1 if floating point underflow.  Result
;                       is set to floating point zero.  The CCR L bit
;                       remains set until cleared by the user.
;
; Assumes n0, m0, shift constant table and scaling modes
; initialized by previous call to the subroutine "fpinit".
;                                       
; Alters Data ALU Registers
;       a2      a1      a0      a
;       b2      b1      b0      b
;       y1
;
; Alters Address Registers
;       r0
;
; Alters Program Control Registers
;       pc      sr
;
; Uses 0 locations on System Stack
;
;
fmpy_xy tfr     y0,b    y1,a            ;get ey, my
fmpy_xa add     x0,b    fp_space:fp_ebias,x0    ;er' = ex + ea,get ebias
        sub     x0,b    a,y1            ;subtract ebias from er',get ma
        mpy     x1,y1,a         b,r0    ;mr = mx * ma, get er'
        jmp     norm1                   ;normalize and check result
