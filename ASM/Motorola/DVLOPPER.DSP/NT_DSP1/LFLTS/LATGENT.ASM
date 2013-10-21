;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Generalized Lattice FIR/IIR Filter Macro. (test program)
; 
; Last Update 01 Aug 86   Version 1.0
;
;
;     generalized lattice iir/fir test program
;

order   equ   3               ;third order lattice
datin   equ   $ffff           ;location of input file
datout  equ   $fffe           ;location of output file
npts    equ   20              ;number of points to process

      org     x:0
kadd  dc      .8,-.5,.5       ;k3, k2, k1
      dc      .1,.2,.3,.4     ;v3, v2, v1, v0
      org     y:0
state ds      10              ;filter states
        include 'dsplib:ioequ'
        include 'dsplib:latgen'
        org     p:$100
start
      movep   #0,x:M_BCR      ;no wait states on external io

      move    #kadd,r0        ;point to k's
      move    #order*2,m0     ;mod order*2+1
      move    #state,r4       ;point to first state
      move    #order,m4       ;mod order+1

      do      #npts,_endp
      movep   y:datin,a       ;get sample

      latgen  order           ;filter sample

      movep   a,y:datout      ;output sample
_endp
      end
