;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 15 Jul 87   Version 1.0
;
                                                                                                                               
iir4    macro
iir4    ident   1,0
;
;       IIR4 - Implements biquad filter
;
        move    x:(r0)+,x0  y:(r4)+,y0  ;s1,a1
        mac     x0,y0,a  x:(r0),x1  y:(r4)+,y0  ;s2, a2
        macr    x1,y0,a  x0,x:(r0)- y:(r4)+,y0  ;new s2, get b1
        mac     x0,y0,a  a,x:(r0)   y:(r4)+,y0  ;new s1, get b2
        macr    x1,y0,a
