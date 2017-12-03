;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 15 Jul 87   Version 1.0
;
                                                                                                                               
iir6    macro   nstates
iir6    ident   1,0
;
;       IIR6 - Implements direct form iir with zeros
;
        move    x:(r0)+,x0   y:(r4)+,y0 ;first state, first coef
        rep     #nstates-1              ;do iir part
        mac     x0,y0,a  x:(r0)+,x0  y:(r4)+,y0
        macr    x0,y0,a
        move    a,x:(r0)+    y:(r4)+,y0 ;save new s1, get b1
        move    x:(r0)+,x0              ;get old s1
        rep     #nstates-1              ;do fir part
        mac     x0,y0,a  x:(r0)+,x0  y:(r4)+,y0
        macr    x0,y0,a
        endm

