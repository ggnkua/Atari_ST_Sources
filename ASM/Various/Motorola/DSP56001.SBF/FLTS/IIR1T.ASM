;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 16 Jul 87   Version 1.0
;
                                                                                                                               
; IIR1 Filter Test Program
;
        opt     cex,mex
        page    132,66,0,10
        include 'iir1'

datin   equ     $ffff           ;location in Y memory of input file
datout  equ     $fffe           ;location in Y memory of output file
npts    equ     20              ;number of points to process

        org     x:0
states  ds      2               ;filter states

        org     y:0
coef    dc      .8,-.3          ;coefficients

        org     p:$100
start
        move    #states,r0      ;point to filter states
        move    #coef,r4        ;point to filter coefficients

        do      #npts,_endp

        movep   y:datin,a       ;get sample

        iir1                    ;do 2nd order iir

        movep   a,y:datout      ;output sample
_endp
        end
