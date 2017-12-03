;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
;     
; Full Precision Square Root by Polynomial Approximation. 
; 
; Last Update 09 Feb 87   Version 1.0
;
sqrt3   macro
sqrt3   ident   1,0
;
; SQRT3 Macro
;
; Full 23 bit precision square root routine using
; a successive approximation technique.
;
; y  = double precision (48 bit) positive input number
; b  = 24 bit output root
;
; a  = temporary storage
; x0 = guess
; x1 = bit being tested
; y1:y0 = input number
 
sqrt3
        clr     b    #<$40,x0           ; init root and guess
        move                    x0,x1   ; init bit to test
        do      #23,_endl
                                        ;START OF LOOP
        mpy     -x0,x0,a                ; square and negate the guess
        add     y,a                     ; compare to double precision input
        tge     x0,b                    ; update root if input >= guess
        tfr     x1,a                    ; get bit to test
        asr     a                               ; shift to next bit to test
        add     b,a             a,x1            ; form new guess
        move                    a,x0            ; save new guess
_endl                                    ;END OF LOOP
        endm
