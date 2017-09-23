;
; Sine-Cosine Table Generator for rfft56.asm 
; 
; Last Update 11/11/92
;
sincosr  macro   points,coef
sincosr  ident   1,2
;
;       sincosr  -      macro to generate sine and cosine coefficient
;                       lookup tables for Decimation in Time real FFT
;                       twiddle factors. Only points/4 coefficients
;                       are generted. For real FFT another points/4
;                       coefficients with higher freq. are created.
;
;       points  -       number of points (2 - 32768, power of 2)
;       coef    -       base address of sine/cosine table
;                       positive cosine value in X memory
;                       positive sine value in Y memory
;
;    8/12/92

pi      equ     3.141592654
freq    equ     2.0*pi/@cvf(points*2)

        org     x:coef-points/2
count   set     0
        dup     points/2
        dc      @cos(@cvf(count)*freq)
count   set     count+1
        endm

        org     y:coef-points/2
count   set     0
        dup     points/2
        dc      -@sin(@cvf(count)*freq)
count   set     count+1
        endm

freq1   equ     2.0*pi/@cvf(points)

        org     x:coef
count   set     0
        dup     points/4
        dc      @cos(@cvf(count)*freq1)
count   set     count+1
        endm

        org     y:coef
count   set     0
        dup     points/4
        dc      @sin(@cvf(count)*freq1)
count   set     count+1
        endm

        endm    ;end of sincosr  macro
