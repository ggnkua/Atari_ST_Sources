;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 16 Jul 87   Version 1.0
;
;
;       FIR test program
;
        opt     cex,mex
        page    132,66,0,10
        include 'fir'

datin   equ     $ffff           ;location in Y memory of input file
datout  equ     $fffe           ;location in Y memory of output file
npts    equ     20              ;number of points to process
ntaps   equ     4               ;number of taps in filter

        org     x:0
states  dsm     ntaps           ;filter states

        org     y:0
coef    dc      .1,.3,-.1,.2    ;coefficients

        org     p:$100
start
        move    #states,r0      ;point to filter states
        move    #ntaps-1,m0     ;mod(ntaps)
        move    #coef,r4        ;point to filter coefficients
        move    #ntaps-1,m4     ;mod(ntaps)

        do      #npts,_endp

        movep   y:datin,x0      ;get sample

        fir     ntaps           ;do fir

        movep   a,y:datout      ;output sample
_endp
        end
