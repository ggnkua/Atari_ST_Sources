;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 5 Oct 87   Version 2.0
;
;
; Call FPLIB subroutines for listing purposes
;
        page    132,60,5,5
        opt     nomd,mex,mu,cre
        define  fp_space 'x'
fp_temp equ     0
        org     p:0
        jmp     start
        org     p:$100
        page
        include 'fpinit'
        page
        include 'fpadd'
        page
        include 'fpsub'
        page
        include 'fpcmp'
        page
        include 'fpmpy'
        page
        include 'fpmac'
        page
        include 'fpdiv'
        page
        include 'fpsqrt'
        page
        include 'fpneg'
        page
        include 'fpabs'
        page
        include 'fpscale'
        page
        include 'fpfix'
        page
        include 'fpfloat'
        page
start   jsr     fpinit
loop    jsr     fadd_xa
        jsr     fadd_xy
        jsr     fsub_xa
        jsr     fsub_xy
        jsr     fcmp_xa
        jsr     fcmp_xy
        jsr     fmpy_xa
        jsr     fmpy_xy
        jsr     fmac_xya
        jsr     fmac_mxya
        jsr     fdiv_xa
        jsr     fdiv_xy
        jsr     fsqrt_a
        jsr     fsqrt_x
        jsr     fneg_a
        jsr     fneg_x
        jsr     fabs_a
        jsr     fabs_x
        jsr     fscal_xa
        jsr     fscal_xy
        jsr     fix_a
        jsr     fix_x
        jsr     float_a
        jsr     float_x
        jmp     loop
        end
