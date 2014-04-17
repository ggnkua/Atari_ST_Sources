;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Normalized Lattice IIR Filter Macro. (test program)
; 
; Last Update 01 Aug 86   Version 1.0
;
;
;       normalized lattice test program
;
        opt     cex
        page    132,66,0,10
        nolist
        include 'dsplib:ioequ'
        list
        include 'dsplib:latnrm'

order   equ     3               ;three coefficient lattice
datin   equ     $ffff           ;location in y memory of input file
datout  equ     $fffe           ;location in y memory of output file
npts    equ     20              ;number of points to process

        org     x:0
;       note: the following coefficients were used for testing
;       purposes only and do not follow the relationship q=sqrt(1-k**2)
;       as described by Markel
;
cadd    dc      .9,.8,.7,.6,.3,.2       ;q1,k1,q2,k2...
        dc      .1,.2,.3,.4             ;v's
        org     y:0
state   ds      10              ;filter states

        org     p:$100
start
        movep   #0,x:M_BCR      ;no wait states on external io

        move    #cadd,r0        ;point to k's
        move    #3*order,m0     ;mod order
        move    #state,r4       ;point to first state
        move    #order,m4       ;mod order

        do      #npts,_endp

        move    y:datin,y0      ;get input sample
        latnrm  order           ;do normalized lattice
        move    a,y:datout      ;output filtered sample
_endp
        end
