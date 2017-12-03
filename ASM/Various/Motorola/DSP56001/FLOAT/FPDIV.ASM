;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 5 Oct 87   Version 2.0
;
fpdiv   ident   2,0
;
; MOTOROLA DSP56000/1 FPLIB VERSION 2
;
; FPDIV - FLOATING POINT DIVIDE SUBROUTINE
;
; Entry points: fdiv_xa R = A / X
;               fdiv_xy R = Y / X
;
;       m = 24 bit mantissa (two's complement, normalized fraction)
;
;       e = 14 bit exponent (unsigned integer, biased by +8191)
;
; Input variables:
;
;   X   x1 = ma  (normalized)
;       x0 = ea
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
; Error conditions:     Set CCR L=1 if divide by zero error.  Result is
;                       set to the maximum floating point value having
;                       the same sign as the dividend if the dividend
;                       is non-zero.  Result is set to floating point
;                       zero if the dividend is zero.  The CCR L bit
;                       remains set until cleared by the user.
;
;                       Set CCR L=1 if floating point overflow.  Result
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
;       y1                      x0
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
fdiv_xy tfr     y0,b    y1,a            ;get ey, my
fdiv_xa sub     x0,b    fp_space:fp_ebias,x0 ;calculate er' = ea - ex,get ebias
        add     x0,b                    ;add ebias to er'
        tfr     x1,b    b,r0            ;get mx, save er'
        tst     b                       ;check for divisor mx = 0
        jne     _div1                   ;jump if divisor not zero
        tst     a                       ;check for dividend ma = 0
        jne     limit                   ;jump if dividend not zero
        or      #$40,ccr                ;set L=1 for divide by zero error
_div1   asr     a       a,b             ;force fractional quotient, copy ma
        jeq     done                    ;jump if dividend ma = 0 (underflow)
        abs     a       (r0)+           ;make dividend positive, adjust er'
        eor     x1,b                    ;calculate quotient sign
        and     #$fe,ccr                ;clear carry (quotient sign bit)
        rep     #24                     ;repeat for 24 bit quotient
        div     x1,a                    ;generate one quotient bit
        jpl     _qpos                   ;jump if positive quotient
        neg     a                       ;negate mr' for negative quotient
_qpos   move    a0,a                    ;get quotient mr'
        tst     a                       ;normalize mr' 1 extra bit
        norm    r0,a                    ;shift 1 bit and update exponent by 1
        jmp     norm1                   ;normalize and check for errors
