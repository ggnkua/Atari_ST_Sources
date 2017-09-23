;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; 
;
FFTR2FNT ident   1,0
        page    132,60
        opt     nomd,nomex,loc,nocex,mu

        include 'sincos'
        include 'gen56'
        include 'fftr2fn'
;
;
; Latest revision - Nov. 11 92

reset   equ     0
start   equ     $40
POINTS  equ     1024
IDATA   equ     $1000
ODATA   equ     $2000
COEF    equ     $3000

        sincos  POINTS,COEF
        gen56   POINTS,IDATA

        opt     mex
        org     p:reset
        jmp     start

        org     p:start
        movep	 #0,x:$fffe   ;0 wait states
        fftr2fn IDATA,COEF,ODATA

        end
