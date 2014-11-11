;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 15 Jul 87   Version 1.0
;
                                                                                                                               
iir1    macro
iir1    ident   1,0
;
;       IIR1 - Implements 2nd order IIR filter with only poles
;
        move    x:(r0)+,x0   y:(r4)+,y0 ;1st state, b1
        mac     x0,y0,a  x:(r0),x1 y:(r4)-,y0
        macr    x1,y0,a  x0,x:(r0)-
        move    a,x:(r0)
        endm
