;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 16 Jul 87   Version 1.0
;
                                                                                                                               
; IIR7 Filter Test Program
;
        opt     cex,mex
        page    132,66,0,10

datin   equ    $ffff        ;location in Y memory of input file
datout  equ    $fffe        ;location in Y memory of output file
npts    equ    20           ;number of points to process
nsec    equ    2            ;number of biquad sections
        include 'iir7'

    org    x:0
states  ds    2*nsec        ;filter states

    org    y:0
coef
        dc    .7114114/2.0,-1.286688/2.0    ;a12,a11
        dc    -.5,0.0                ;b12,b11
        dc    .8069339/2.0,-1.641678/2.0    ;a22,a21
        dc    -.5,0.0                ;b22,b21

    org    p:$100
start

    do       #npts,_endp
    movep                y:datin,a    ;get sample
    move    #states,r0                ;point to filter states
    move    #coef,r4                  ;point to filter coefficients

    iir7    nsec                      ;do cascaded biquads

    nop                               ;let mode change back
    nop
    movep               a,y:datout    ;output sample
_endp
    end

