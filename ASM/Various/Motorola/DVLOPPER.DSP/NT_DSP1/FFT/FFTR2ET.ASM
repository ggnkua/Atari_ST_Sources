;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; 1024-Point, 3.39ms Non-In-Place FFT. (test program) 
; 
; Last Update 03 Feb 87   Version 1.0
;
fftr2et ident   1,0
        page    132,60
        opt     nomd,nomex,loc,nocex,mu

        include 'dsplib:sincos'
        include 'dsplib:fftr2e'

;
; Main program to call the FFTR2E macro
;       Argument list
;
;       1024 point complex FFT
;       External data starts at address $400
;       Internal data starts at address 0
;       Coefficient table starts at address $800
;
; Latest revision - 3-Feb-87

reset   equ     0
start   equ     $100
points  equ     1024
data    equ     $400
coef    equ     $800

        sincos  points,coef

        opt     mex
        org     p:reset
        jmp     start

        org     p:start
        fftr2e  data,coef
        end
