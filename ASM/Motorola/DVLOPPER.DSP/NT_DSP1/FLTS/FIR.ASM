;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 15 Jul 87   Version 1.0
;
fir     macro   ntaps
fir     ident   1,0
;
;       FIR - direct form FIR filter
;
;       FIR filter macro
;
        clr     a    x0,x:(r0)+  y:(r4)+,y0     ;save first state
        rep     #ntaps-1
        mac     x0,y0,a  x:(r0)+,x0  y:(r4)+,y0
        macr    x0,y0,a  (r0)-
        endm
