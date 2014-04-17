;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Full Precision Square Root by Polynomial Approximation. (test program)
; 
; Last Update 09 Feb 87   Version 1.0
;
sqrt3t  ident   1,0
;
;       square root test program
;
        opt     cex
        page    132,66,0,0
        nolist
        include 'dsplib:ioequ'
        list
        include 'dsplib:sqrt3'

datin   equ     $ffff           ;location in y memory of input file
datout  equ     $fffe           ;location in y memory of output file

        org     p:$100
start   movep   #0,x:M_BCR      ;no wait states on external io
        move    #<$0,y0         ;clear ls input word
        do      #100,_e         ;number of points to do
        movep   y:datin,y1      ;get input value
        sqrt3                   ;do 24 bit sqrt
        movep   b,y:datout      ;output square root
_e                     
        wait
        end
