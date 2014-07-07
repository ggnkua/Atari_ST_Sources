;
FFTR2CNT ident   1,0
        page    132,60
        opt     nomd,nomex,loc,nocex,mu

        include 'sincos'
        include 'fftr2cn'
;
;
; Latest revision - Nov. 11 92

reset   equ     0
start   equ     $40
POINTS  equ     64
IDATA   equ     $00
ODATA   equ     $1000
COEF    equ     $800

        sincos  POINTS,COEF

        opt     mex
        org     p:reset
        jmp     start

        org     p:start
        movep	 #0,x:$fffe   ;0 wait states
        fftr2cn POINTS,IDATA,ODATA,COEF

        end
