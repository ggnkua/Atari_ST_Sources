;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 3 Nov 87   Version 2.1
;
fpcmp   ident   2,1
;
; MOTOROLA DSP56000/1 FPLIB - VERSION 2
;
; FPCMP - FLOATING POINT COMPARISON (SETS CONDITION CODES) SUBROUTINE
;
;
; Entry points: fcmp_xa A - X   SET CONDITION CODES
;               fcmp_xy Y - X   SET CONDITION CODES
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
;       The following Jcc branch conditions can be used after calling
;       fcmp_xa or fcmp_xy.  The other branch conditions should not be used.
;
;       "cc" Mnemonic                   Condition
;       -------------                   ---------
;       EQ - equal                      Z = 1
;       GE - greater than or equal      N eor V = 0
;       GT - greater than               Z + (N eor V) = 0
;       LE - less than or equal         Z + (N eor V) = 1
;       LT - less than                  N eor V = 1
;       NE - not equal                  Z = 0
;
; Error conditions:     none
;
; Assumes n0, m0, shift constant table and scaling modes
; initialized by previous call to the subroutine "fpinit".
;
; Alters Data ALU Registers
;       a2      a1      a0      a
;       b2      b1      b0      b
;               x0              y0
;
; Alters Address Registers
;
;
; Alters Program Control Registers
;       pc      sr
;
; Uses 0 locations on System Stack
;
;
fcmp_xy tfr     y0,b    y1,a            ;get ey, my
fcmp_xa eor     x1,a    a,y0            ;compare signs, save ma
        jmi     _mant                   ;jump if different signs
;
; Same signs
;
_sign   eor     x1,a                    ;check sign of ma
        jpl     _sign1                  ;jump if ma and mx positive
        tfr     x0,b    b,x0            ;if minus, exchange ea and ex
_sign1  cmp     x0,b                    ;compare exponents
        jne     done                    ;jump if different exponents
;
; Same signs, same exponents or different signs
;
_mant   tfr     y0,a                    ;restore ma
        cmp     x1,a                    ;compare mantissa
        rts
