;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 16 Jul 87   Version 1.0
;
                                                                                                                               
; IIR2 Filter Test Program
;
;  This test program has the filter coefficients divided by two
:  because the filter program uses coefficient scaling.
;
        opt     cex,mex
        page    132,66,0,10
        include 'iir2'

datin   equ     $ffff           ;location in Y memory of input file
datout  equ     $fffe           ;location in Y memory of output file
npts    equ     20              ;number of points to process

        org     x:0
states  ds      2               ;filter states

        org     y:0
coef    dc      .8/2.0,-.3/2.0          ;coefficients

        org     p:$100
start
        move    #states,r0      ;point to filter states
        move    #coef,r4        ;point to filter coefficients

        do      #npts,_endp

        movep   y:datin,a       ;get sample

        iir2                    ;do 2nd order iir

        nop
        nop
        movep   a,y:datout      ;output sample
_endp
        end
