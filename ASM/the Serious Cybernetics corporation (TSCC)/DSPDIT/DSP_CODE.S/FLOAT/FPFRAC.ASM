fpfrac  ident   2,0
;
; MOTOROLA DSP56000/1 FPLIB - VERSION 2
;
; This program, originally available on the Motorola DSP bulletin board,
; is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive, West, Austin, Texas  78735-8598.
;
; FPFRAC - FLOATING POINT FRACTION SUBROUTINE
;
; Entry points: frac_a     R = frac(A)
;               frac_x     R = frac(X)
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
; Error conditions:     No error conditions are signaled.
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
;       ssh     ssl     sp
;
; Uses 1 location on System Stack
;
; Version - 2.0
; Latest Revision - February 22, 1988
;
frac_x
        tfr     x0,b    x1,a            ;get mx,ex
frac_a  
        move    b1,y0                   ;copy input
        move    a1,y1
        jsr     floor_a                 ;get floor of input
        move    b1,x0                   ;put floor in X
        move    a1,x1
        jmp     fsub_xy                 ;R=x-floor(x)
 
 
 
 
