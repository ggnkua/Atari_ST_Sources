;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 15 Jul 87   Version 1.0
;

iir7    macro    nsec
iir7    ident    1,0
;
;    Implements cascaded biquads
;
    ori    #$08,mr                                ;set scaling mode
    move                 x:(r0)+,x0  y:(r4)+,y0  ;first state, a12
    do     #nsec,_ends                           ;do each section
    mac    -x0,y0,a      x:(r0)-,x1  y:(r4)+,y0  ;ax2
    macr   -x1,y0,a      x1,x:(r0)+  y:(r4)+,y0  ;ax1
    mac    x0,y0,a       a,x:(r0)+   y:(r4)+,y0  ;bx2
    mac    x1,y0,a       x:(r0)+,x0  y:(r4)+,y0  ;bx1
_ends
    rnd    a                                     ;round result
    andi   #$f7,mr                               ;remove scaling mode
    endm


