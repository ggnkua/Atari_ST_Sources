;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Radix 2, In-Place, Decimation-In-Time FFT
; (using DSP56001 Y Data ROM sine-cosine tables).  (test program)
; 
; Last Update 08 Aug 86   Version 1.0
;
fftr2dt ident   1,0
        page    132,66,2,2
        opt     nomd,loc,cre,mu

        include 'dsplib:sinewave'
        include 'dsplib:fftr2d'

;
; Main program to call the FFTR2D macro
;       Argument list
;
;       16 point complex, in-place FFT
;       Data starts at address 0
;       Coefficient table starts at address $100
;
; This example shows how to perform a 16 point FFT
; using a 256 point full cycle sinewave table.  The
; SINEWAVE macro generates identical coefficients to
; those stored at address $100 in the DSP56001 Y Data ROM.
;                          
; Latest revision - 8-Aug-86
;
reset   equ     0
start   equ     $100
points  equ     16
data    equ     0
coef    equ     $100
table   equ     256

        org     y:coef
        sinewave        table

        opt     mex
        org     p:reset
        jmp     start

        org     p:start
        fftr2d points,data,coef,table
        end
