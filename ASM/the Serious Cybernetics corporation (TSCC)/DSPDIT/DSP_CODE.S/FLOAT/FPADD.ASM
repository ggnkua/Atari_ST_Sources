;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 7 Oct 87   Version 2.0
;
fpadd   ident   2,0
;
; MOTOROLA DSP56000/1 FPLIB - VERSION 2
;
; FPADD - FLOATING POINT ADDITION SUBROUTINE
;
; Entry points: fadd_xa R = A + X
;               fadd_xy R = Y + X
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
; Uses 0 locations on System Stack
;
;
fadd_xy tfr     y0,b    y1,a            ;get ey, my
fadd_xa cmp     x0,b    fp_space:fp_23,y0       ;compare delta = er - ea,
                                                ; get delta limit
        jge     _dpos                   ;jump if er >= ea
;
; er < ea
;
_dneg   tfr     x1,a    a1,x1           ;swap ma with mr
        tfr     x0,b    b1,x0           ;swap ea with er
;
; er >= ea
;
_dpos   sub     x0,b    b1,y1           ;calculate delta, save er'
        cmp     y0,b    b1,r0           ;check delta limit, save delta
        jgt     done1                   ;jump if delta > 23
addm    move    fp_space:(r0+n0),x0     ;lookup shift constant s
        mac     -x1,x0,a        y1,r0   ;denormalize by s, add mantissa, get er'
        jmp     norm1                   ;try for quick normalization
;
; normalize and round result - assumes a=mr', r0=er' and CCR reflects mr' value.
;
norm    rep     #8                      ;normalize up to 8 bits left or right
norm1   norm    r0,a                    ;shift 1 bit and update exponent by 1
        jnn     norm                    ;jump if not normalized
round   rnd     a                       ;round to 24 bit mr
        norm    r0,a                    ;correct mr overflow due to round
;
; detect and correct exceptions - assumes a=mr and r0=er
;
check   move    r0,fp_space:fp_temp     ;check er
        jset    #15,fp_space:fp_temp,under      ;jump if exponent underflow
        jset    #14,fp_space:fp_temp,limit      ;jump if exponent overflow
check1  tst     a       r0,b            ;check mr, get er
        teq     a,b                     ;if mr=0, correct to fp zero
        rts
under   or      #$40,ccr                ;set L=1 for exponent underflow
zero    clr     a       #0,b            ;correct to fp zero
        rts
limit   asl     a       fp_space:fp_emax,y1     ;correct to maximum fp value
done1   tfr     y1,b    a,a             ;get mr and er, set L bit if mr limited
done    rts
