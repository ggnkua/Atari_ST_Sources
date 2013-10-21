;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Lattice IIR Filter Macro. (test program)
; 
; Last Update 31 Jul 86   Version 1.0
;
;
;       LATTICE IIR
;
        opt     cex
        page    132,66,0,10
        nolist
        include 'dsplib:ioequ'
        list
        include 'dsplib:latiir'


order   equ     3               ;three coefficient lattice
datin   equ     $ffff           ;location of input file
datout  equ     $fffe           ;location of output file
npts    equ     20              ;number of points to process

        org     x:0
kadd    dc      .5,-.5,.8       ;filter reflection coefficients
        org     y:0
state   ds      3               ;filter states

        org     p:$100
start
        movep   #0,x:M_BCR      ;no wait states on external i/o

        move    #kadd+order-1,r0        ;point to k's
        move    #order-1,m0             ;mod order
        move    #state,r4               ;point to state variables
        move    #order-1,m4             ;mod order

        do      #npts,_endp             ;filter some points
        move    y:datin,a               ;get input sample
        latiir  order                   ;filter it
        move    a,y:datout              ;output sample
_endp
        END
