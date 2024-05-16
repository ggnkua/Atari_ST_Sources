;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 6 Oct 87   Version 2.0
;
fpfloat ident   2,0
;
; MOTOROLA DSP56000/1 FPLIB - VERSION 2
;
; FPFLOAT - FIXED POINT TO FLOATING POINT CONVERSION SUBROUTINE
;
; Entry points: float_a R = float(A)
;               float_x R = float(X)
;
;       data = 56 bit two's complement fixed point number
;              consisting of a 48 bit fraction with an 8 bit
;              integer extension in standard accumulator data
;              representation.
;
;       m = 24 bit mantissa (two's complement, normalized fraction)
;
;       e = 14 bit exponent (unsigned integer, biased by +8191)
;
; Input variables:
;
;   X   x1 = data
;
;   A    a = data
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
; Error conditions:     none
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
float_x tfr     x1,a                    ;get data
float_a tst     a       fp_space:fp_ebias,r0    ;check data, initialize er
        jnr     float1                  ;jump if data normalized
norm8   rep     #8                      ;normalize up to 8 bits left or right
        norm    r0,a                    ;normalize one bit, update er
        jnn     norm8                   ;jump if not normalized
float1  rnd     a                       ;round mr to 24 bits
        norm    r0,a                    ;correct overflow due to rounding
        jmp     check1                  ;go check exponent range
