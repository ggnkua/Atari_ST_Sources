;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 30 Oct 87   Version 2.1
;
fpmac   ident   2,1
;
; MOTOROLA DSP56000/1 FPLIB - VERSION 2
;
; FPMAC - FLOATING POINT MULTIPLY/ACCUMULATION SUBROUTINE
;
; Entry points: fmac_xya        R = A + X * Y
;               fmac_mxya       R = A - X * Y
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
;       x1      x0      y1      y0
;
; Alters Address Registers
;       r0
;
; Alters Program Control Registers
;       pc      sr
;
; Uses 1 location on System Stack
;
fmac_xya move   a,fp_space:fp_temp+1    ;save ma
        move    b,fp_space:fp_temp+2    ;save ea
        jsr     fmpy_xy                 ;multiply x*y first
        move    fp_space:fp_temp+1,x1   ;restore ma
        move    fp_space:fp_temp+2,x0   ;restore ea
        jmp     fadd_xa                 ;add product to a
;
fmac_mxya move  a,fp_space:fp_temp+1    ;save ma
        move    b,fp_space:fp_temp+2    ;save ea
        jsr     fmpy_xy                 ;multiply x*y first
        move    a,x1                    ;save product mantissa
        move    b,x0                    ;save product exponent
        move    fp_space:fp_temp+1,a    ;restore ma
        move    fp_space:fp_temp+2,b    ;restore ea
        jmp     fsub_xa                 ;subtract product from a

