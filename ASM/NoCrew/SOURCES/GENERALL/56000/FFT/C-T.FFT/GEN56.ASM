;
; Input signal for FFT rfft56.asm and cfft56.asm 
; 
; Last Update 10/28/92
;
gen56    macro   POINTS,IDATA
;
;       gen56    -      macro to generate input signal for FFT test on 56001
;                       2000 Hz sinewave with scaling factor POINTS in X and Y memory
;
;       POINTS  -       number of points (2 - 32768, power of 2)
;       IDATA    -      base address of signal
;
srate   set     44100   ;Hz
ffreq    set     2000    ;Hz
ppi     equ     3.141592654
freq2   equ     2.0*ppi*ffreq/@cvf(srate)

        org     x:IDATA
count   set     0
        dup     POINTS
        dc      @sin(@cvf(count)*freq2)/POINTS
count   set     count+1
        endm

        org     y:IDATA
count   set     0
        dup     POINTS
        dc      @sin(@cvf(count)*freq2)/POINTS
count   set     count+1
        endm

        endm    ;end of gen56  macro
