;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 15 Jul 87   Version 1.0
;
                                                                                                                               
iir3    macro   ncoef
iir3    ident   1,0
;
;       IIR3 - Implements IIR filter with only poles
;
        move    x:(r0)+,x0   y:(r4)+,y0 ;first state, first coef
        rep     #ncoef-1                ;do macs
        mac     x0,y0,a  x:(r0)+,x0  y:(r4)+,y0
        macr    x0,y0,a  (r0)-          ;rnd, adj ptr
        move    a,x:(r0)                ;save output as first state
        endm
