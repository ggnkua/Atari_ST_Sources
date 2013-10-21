;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Lattice FIR Filter Macro (modified modulo count). (test program)
; 
; Last Update 08 Aug 86   Version 1.0
;
;
;       lattice FIR test program
;
        opt     cex
        page    132,66,0,10
        nolist
        include 'dsplib:ioequ'
        list
        include 'dsplib:latfir2'

order   equ     3               ;3 coefficient lattice
datin   equ     $ffff           ;location in Y memory of input file
datout  equ     $fffe           ;location in Y memory of output file
npts    equ     20              ;number of points to process

        org     x:0
state   ds      10              ;filter states

        org     y:0
kadd    dc      .5,-.5,.2       ;reflection coefficients, k1,k2,k3

        org     p:$100
start
        movep   #0,x:M_BCR      ;no wait states on external i/o

        move    #state,r0       ;point to filter states
        move    #order,m0       ;mod order+1
        move    #kadd,r4        ;point to coefficients
        move    #order-1,m4     ;mod order on coefficients

        do      #npts,_endp

        movep   y:datin,b       ;get sample, set t

        latfir2 order           ;do lattice fir

        movep   b,y:datout              ;output sample
_endp

        END
