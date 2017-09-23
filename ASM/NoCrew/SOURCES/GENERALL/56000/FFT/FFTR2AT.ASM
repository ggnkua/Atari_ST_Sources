;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Radix 2, In-Place, Decimation-In-Time FFT (smallest code size).
; (test program)
; 
; Last Update 30 Sep 86   Version 1.1
;
fftr2bt ident   1,1
        page    132,54
        opt     nomd,nomex,loc,cre,nocex,mu

        include 'sincos'
        include 'fftr2b'

;
; Main program to call the FFTR2A macro
;       Argument list
;
;       16 point complex, in-place FFT
;       4 FFT passes
;       Data starts at address 0
;       Coefficient table starts at address 16
;
; Latest revision - 2-Oct-86

reset   equ     0
start   equ     $100
points  equ     1024
data    equ     0          
coef    equ     1024

        sincos  points,coef

        opt     mex
        org     p:reset
        jmp     start

        org     p:start
		movep   #0,x:$fffe         ; 0 wait state
        fftr2b  points,data,coef
        end
