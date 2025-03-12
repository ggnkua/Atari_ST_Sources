;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 16 Jul 87   Version 1.0
;
                                                                                                                               
; IIR6 Filter Test Program
;
        opt     cex,mex
        page    132,66,0,10
        include 'iir6'

datin   equ     $ffff           ;location in Y memory of input file
datout  equ     $fffe           ;location in Y memory of output file
npts    equ     20              ;number of points to process
nstates equ     5               ;number of states

        org     x:0
states  dsm     nstates+1       ;filter states

        org     y:0
coef
        dc      .8,-.7,.6,-.5,.4        ;a1,a2,a3,a4,a5
        dc      .1,.2,.3,.4,.5          ;b1,b2,b3,b4,b5

        org     p:$100
start
        move    #states,r0      ;point to filter states
        move    #nstates,m0     ;mod (nstates+1)
        move    #coef,r4        ;point to filter coefficients
        move    #2*nstates-1,m4 ;mod (2*nstates)

        do      #npts,_endp

        movep   y:datin,a       ;get sample

        iir6    nstates         ;do 2nd order iir

        movep   a,y:datout      ;output sample
_endp
        end

