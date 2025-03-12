;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 5 Oct 87   Version 2.0
;
fpinit  ident   2,0
;
; MOTOROLA DSP56000/1 FPLIB - VERSION 2
;
; FPINIT - FLOATING POINT LIBRARY INITIALIZATION SUBROUTINE
;
; Entry point:  fpinit  Initialize address pointers and shift constant
;                       table for DSP56000/1 floating point subroutine
;                       library.
;
; Input variables:      none
;
; Output variables:
;
;       n0 = base address of shift constant table
;       m0 = $ffff  (linear address modifier)
;
;       shift constant table - stores multiplication constants for
;                              denormalization operations.
;
;       The X or Y data memory space (without the colon) used for the
;       shift constant table must be specified in single quotes by a
;       DEFINE directive for the global symbol "fp_space" and the base
;       address of the shift constant table must be specified for the
;       global symbol "fp_temp" via an EQU or similar directive.  An
;       example is given below.
;
;               define  fp_space        'x'
;       fp_temp equ     $0000
;
; Error conditions:     none
;
; Memory requirements:  28 locations in "fp_space" memory space
;
; Alters Address Registers
;               n0      m0
;
; Alters Program Control Registers
;       pc      sr
;
; Uses 0 locations on System Stack
;
;
        org     fp_space:fp_temp
        ds      4       ;temporary storage locations
fp_23   dc      23      ;exponent delta limit
fp_ebias dc     $001fff ;fixed point exponent bias
fp_emax dc      $003fff ;maximum exponent
fp_shift dc     $800000,$c00000,$e00000,$f00000,$f80000,$fc0000,$fe0000,$ff0000
        dc      $ff8000,$ffc000,$ffe000,$fff000,$fff800,$fffc00,$fffe00,$ffff00
        dc      $ffff80,$ffffc0,$ffffe0,$fffff0,$fffff8,$fffffc,$fffffe
fp_m1   dc      $ffffff
;
        org p:
fpinit  move    fp_space:fp_m1,m0       ;initialize linear address modifier
        move    #fp_shift,n0    ;initialize base address of shift constant table
        and     #$f3,mr         ;reset scaling modes (S1,S0)
        and     #$bf,ccr        ;reset overflow flag (L bit)
        rts
