;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; 1024-Point Real Input Non-In-Place FFT. (test program) 
; 
;
RFFT56T ident   1,0
        page    132,60
        opt     nomd,nomex,loc,nocex,mu

        include 'sincosr'
        include 'bitrevtwd56'
        include 'gen56'
        include 'cfft56'
        include 'split56'
;
;
; Latest revision - Nov. 11 92

reset   equ     0
start   equ     $40
POINTS  equ     512
IDATA   equ     $00
ODATA   equ     $1000
COEF    equ     $800

        sincosr  POINTS,COEF
        gen56    POINTS,IDATA

        opt     mex
        org     p:reset
        jmp     start

        org     p:start
        movep	 #0,x:$fffe   ;0 wait states
        bitrevtwd56 POINTS,COEF
        CFFT56  IDATA,COEF,POINTS,ODATA
        SPLIT56 IDATA,COEF,POINTS,ODATA

        end
