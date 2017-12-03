;
; This program, originally available on the Motorola DSP bulletin board,
; is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas  78735-8598.
;
;       DURBIN's recursive solution of linear predictive coefficients (LPC)
;       using the floating point library.
;
;       Execution time for a 10th order system: 855 uS (in floating point)
;
;       Version 1.0      10-Nov-87
;
        opt     nomd,mex,mu,cre
        page    132,60,1,1
;
;       Durbin's recursive LPC solution
;
        define  fp_space 'x'
ncoef   equ     10              ;10th order system
        org     l:0
eng     ds      1               ;energy
k       ds      1               ;temporary reflection coefficient
anew    ds      ncoef           ;temporary predictor coefficients
alpha   ds      ncoef           ;final predictor coefficients
coef    equ     *
rn      ds      ncoef+1         ;autocorrelation coefficients
 
;
;       overlay the data into the "rn" array in long memory
;
        org     x:coef          ;mantissas of rn data
        dc      $400000         ;r(0)=1.0
        dc      $533333         ;r(1)=.65
        dc      $4ccccd         ;r(2)=.6
        dc      $400000         ;r(3)=.5
        dc      $666666         ;r(4)=.1
        dc      $666666         ;r(5)=.1
        dc      $99999a         ;r(6)=-.05
        dc      $851eb9         ;r(7)=-.03
        dc      $99999a         ;r(8)=-.05
        dc      $b851ec         ;r(9)=-.07
        dc      $51eb85         ;r(10)=.01
;
;       Define the starting address for the data and scratch pad for
;       the floating point subroutines
;
fp_temp equ     *               ;define address of fp space
 
        org     y:coef          ;exponents of rn values
        dc      $2000
        dc      $1fff
        dc      $1fff
        dc      $1fff
        dc      $1ffc
        dc      $1ffc
        dc      $1ffb
        dc      $1ffa
        dc      $1ffb
        dc      $1ffc
        dc      $1ff9
 
;
;       define floating point routines
;
        org     p:$100
        nolist
        page
        include 'dsplib:fpinit'
        page
        include 'dsplib:fpadd'
        page
        include 'dsplib:fpsub'
        page
        include 'dsplib:fpcmp'
        page
        include 'dsplib:fpmpy'
        page
        include 'dsplib:fpmac'
        page
        include 'dsplib:fpdiv'
        page
        include 'dsplib:fpsqrt'
        page
        include 'dsplib:fpneg'
        page
        include 'dsplib:fpabs'
        page
        include 'dsplib:fpscale'
        page
        include 'dsplib:fpfix'
        page
        include 'dsplib:fpfloat'
        list
 
        org     p:$500
start
        jsr     fpinit          ;initialize floating point library
 
        move    l:rn,x          ;get rn(0)
        move    x,l:eng         ;eng=rn(0)
        move    l:rn+1,y        ;get rn(1)
        jsr     fdiv_xy         ;rn(1)/rn(0)
        move    ab,l:alpha      ;alpha(1)=rn(1)/rn(0)
        move    a,x1            ;copy alpha(1)
        move    b,x0
        move    a,y1            ;copy alpha(1) to y
        move    b,y0
        move    #$400000,a      ;1.0
        move    #$2000,b        ;exponent of 1.0
        jsr     fmac_mxya       ;1.0-alpha(1)*alpha(1)
        move    l:eng,x         ;get eng
        jsr     fmpy_xa         ;*eng
        move    ab,l:eng        ;save new eng
 
        move    #1,r1           ;m
        move    #rn+2,r6        ;point to rn(i)
        move    #alpha+1,r7     ;point to alpha(i)
 
        do      #ncoef-1,_edurbin
        move    #rn,r4          ;point to base of rn array
        move    r1,n4           ;offset m
        clr     a       #0,b    ;clear sum
        lua     (r4)+n4,r4      ;generate iptr
        move    #alpha,r5       ;point to alpha base
        do      r1,_esum        ;generate sum
        move    l:(r5)+,x       ;get alpha(j)
        move    l:(r4)-,y       ;get rn(iptr)
        jsr     fmac_xya        ;compute sum
        nop
_esum
        move    a,x1            ;copy sum to x
        move    b,x0
        move    l:(r6)+,y       ;get rn(i), point to next
        jsr     fsub_xy         ;do rn(i)-sum
        move    l:eng,x         ;get eng
        jsr     fdiv_xa         ;do (rn(i)-sum)/eng
        move    ab,l:k          ;save as k
        move    #alpha-1,r4     ;point to alpha base
        move    ab,l:(r7)+      ;save as alpha(i), point to next
        lua     (r4)+n4,r4      ;generate iptr
        move    #alpha,r5       ;pointer for alpha(j)
        move    #anew,r3        ;point to anew array
        do      r1,_eupdate     ;update alphas
        move    l:(r5)+,ab      ;get alpha(j)
        move    l:k,x           ;get k
        move    l:(r4)-,y       ;get alpha(iptr), dec iptr
        jsr     fmac_mxya       ;alpha(j)-k*alpha(iptr)
        move    ab,l:(r3)+      ;save anew(j)
_eupdate
        move    #anew,r4        ;point to anew array
        move    #alpha,r5       ;point to alpha array
        do      r1,_ecopy       ;copy anew to alpha
        move    l:(r4)+,x       ;get anew(j)
        move    x,l:(r5)+       ;save alpha(J)
_ecopy
        move    #$400000,a      ;get a 1.0
        move    #$2000,b        ;exponent
        move    l:k,x           ;get k
        move    l:k,y           ;get k again
        jsr     fmac_mxya       ;1.0-k*k
        move    l:eng,x         ;get energy
        jsr     fmpy_xa         ;(1.0-k*k)*eng
        move    ab,l:eng        ;save new eng
        move    (r1)+           ;increment m
_edurbin
        end
 
 
 
 
