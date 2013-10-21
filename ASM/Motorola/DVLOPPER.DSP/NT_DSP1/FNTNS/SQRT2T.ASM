;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Square Root by Polynomial Approximation, 10-bit Accuracy.
; (test program)
; 
; Last Update 26 Jan 87   Version 1.0
;
        opt     cex
        page    132,66,0,0
        nolist
        include 'dsplib:ioequ'
        list
        include 'dsplib:sqrt2'

datin   equ     $ffff           ;location in y memory of input file
datout  equ     $fffe           ;location in y memory of output file

        org     y:0
pcoef   dc      .8803385,-.1985987,.3185231     ;a1,a2,a0

        org     p:$100
start
        movep   #0,x:M_BCR      ;no wait states on external io
;
        do      #100,_e         ;number of points to do
        move    #pcoef,r1       ;point to poly coef
        movep   y:datin,x0      ;get input value
;
        sqrt2                   ;do square root
;
        movep   a,y:datout
_e
        end
