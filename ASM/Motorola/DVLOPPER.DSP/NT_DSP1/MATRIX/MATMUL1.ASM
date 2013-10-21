;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; [1x3][3x3]=[1x3] Matrix Multiplication       
; 
; Last Update 04 Feb 87   Version 1.0
;
        opt     cex
        page    132,66,0,0
;
;       matrix multiply
;
;
        org     x:0
;
mat_a
        dc        .4                    ;a(1,1)
        dc        .3                    ;a(1,2)
        dc        -.6                   ;a(1,3)

        org     y:0
mat_b
        dc        -.4                   ;b(1,1)
        dc        .5                    ;b(2,1)
        dc        .6                    ;b(3,1)
        dc        .35                   ;b(1,2)
        dc       -.3                    ;b(2,2)
        dc        -.35                  ;b(3,2)
        dc       .15                    ;b(1,3)
        dc       .4                     ;b(2,3)
        dc       .45                    ;b(3,3)

mat_x   ds      3
;
;
        org     p:$100
matmul  move    #mat_a,r0       ;point to A matrix
        move    #mat_b,r4       ;point to B matrix
        move    #2,m0           ;mod 3
        move    #mat_x,r1       ;output X matrix
;
        move            x:(r0)+,x0  y:(r4)+,y0
        mpy     x0,y0,a  x:(r0)+,x0  y:(r4)+,y0
        mac     x0,y0,a  x:(r0)+,x0  y:(r4)+,y0
        macr    x0,y0,a  x:(r0)+,x0  y:(r4)+,y0
        move    a,y:(r1)+
        mpy     x0,y0,a  x:(r0)+,x0  y:(r4)+,y0
        mac     x0,y0,a  x:(r0)+,x0  y:(r4)+,y0
        macr    x0,y0,a  x:(r0)+,x0  y:(r4)+,y0
        move    a,y:(r1)+
        mpy     x0,y0,a  x:(r0)+,x0  y:(r4)+,y0
        mac     x0,y0,a  x:(r0)+,x0  y:(r4)+,y0
        macr    x0,y0,a  x:(r0)+,x0  y:(r4)+,y0
        move    a,y:(r1)+
        end
