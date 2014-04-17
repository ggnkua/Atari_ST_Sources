;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
;
sinegen	macro	points,amplitud,freq,phase
sinegen	ident	1,0
;
; SINEGEN Macro
;
; Generates "points" samples of a sinewave of arbitrary
; amplitude, frequency and phase.
;
;       points  -       number of points (1-65536)
;       amplitud-       maximum amplitude of sinewave (0.0-1.0)
;       freq    -       frequency w.r.t. sampling frequency (0.0-1.0)
;       phase   -       starting phase in radians (0.0-6.28)
;
; Latest revision - 12-Feb-87
; Tested and verified - 12-Feb-87
;

_pi     equ     3.141592654
inc     set     2.0*_pi*freq

angle   set     0.0
        dup     points
        dc      amplitud*@sin(angle+phase)
angle   set     angle+inc
        endm

        endm    ;end of sinegen macro
