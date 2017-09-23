;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Leroux-Gueguen Solution for PARCOR (LPC) Coefficients
; 
; Last Update 21 May 87   Version 2.0 
;
;       Implements the Leroux-Gueguen algorithm.
;
        opt     cex
        page    132,66,0,10
;
;       i/o file definitions 
;
datain   equ    $ffff
dataout  equ    $fffe
nk      equ     10              ;10th order LPC analysis
;
        org     x:0
r       ds      nk+1            ;autocorrelation coefficients
fk      ds      nk              ;LPC reflection coefficients
;
        org     y:0
bi      ds      nk
bim1    ds      nk+1
;
        org     p:$100
;
;       find out how many frames to process
;
        movep   y:datain,n0     ;input number of frames
        do      n0,endfram      ;do LPC analysis on all frames
;
;       load the autocorrelations from an external file
;
        move    #r,r0           ;r(0) points to r[0]
        do      #nk+1,endin     ;
        movep   y:datain,a      ;get next autocorrelation value
        move    a,x:(r0)+       ;put value in local r[] array
;
;       Start of LPC analysis
;
;       The following registers correspond to the FORTRAN variables:
;
;       r0 - r[i] = irptr        r4 - bim1[j] = jbm1
;       r1 - fk[i] = ifk         r5 - bim1[i] = ibim1
;       r2 - fk[j] = jfk         r6 - bi[i] = ibi
;       r3 - bi[j] = jbi         r7 - loop counter = im1
;
;       Approximate analysis times:
;
;       8th  order: 46.2  uS
;       10th order: 61.6  uS
;       16th order: 117.2 uS
;
;       Initialization
;
endin   move    #r,r0                   ;r(0) points to r[0]
        move    #fk,r1                  ;r(1) points to fk[1]
        move    #bim1,r5                ;r(5) points to bim1[1]
        move    #bi+1,r6                ;r(6) points to bi[2]
;
;       Begin Leroux - Gueguen Algorithm
;
        move    x:(r0)+,x0              ;get r[0]
        move    x:(r0)+,a               ;get r[1], r(0) points to r[2]
        abs     a      a,b              ;get abs(r[1]), copy r[1] to b
        eor     x0,b   b,y0             ;N = sign bit, copy r[1] to y0
        and     #$fe,ccr                ;clear quotient sign bit
        rep     #24                     ;set up for 24-bit quotient
        div     x0,a                    ;get abs(r[1])/r[0]
        jmi     L1                      ;check sign bit N
        neg     a                       ;negate quotient if needed
L1      move    a0,a                    ;move -r[1]/r[0] to a
        move    a,x:(r1)+   a,y1        ;copy -r[1]/r[0] to fk[1] and y1
        tfr     x0,b    y0,y:(r5)+      ;bim1[1] = r[1], copy r[0] to b
        macr    y1,y0,b     #1,r7       ;r[0] + fk[1] * r[1]; loop count = 1
        move    b,y:(r5)                ;bim1[2] = r[0] + (fk[1] * r[1])
;
;       outer do loop
;
        do      #nk-1,L4
        move    #fk,r2                  ;r(2) points to fk[1]
        move    #bi,r3                  ;r(3) points to bi[1]
        move    #bim1,r4                ;r(4) points to bim1[1]
        move    x:(r0)+,b   y:(r5),y1   ;yi = r[i], get bim1[i]
        move    b,x1        b,y:(r3)    ;copy yi to x1, bi[1] = yi
;
;       inner do loop
;
        do      r7,L2                   ;begin inner do loop
        move    x:(r2)+,x0  y:(r4),a    ;get fk[j] and bim1[j]
        macr    x1,x0,a a,x1 y:(r3)+,y0 ;bim1[j]+(fk[j]*yi)
        macr    x1,x0,b     a,y:(r3)    ;save bi[j+1], yi=yi+(fk[j]*bim1[j])
        move    b,x1       y0,y:(r4)+   ;copy yi to x1, save bim1[j]
;
;       end of inner do loop (note: b = x1 = yi)
;
L2      abs     b        b,a            ;get abs(yi), copy yi to a
        eor     y1,a     (r7)+          ;N = sign bit, inc. outer loop counter
        and     #$fe,ccr                ;clear quotient sign bit
        rep     #24                     ;set up for 24-bit quotient
        div     y1,b                    ;get abs(yi)/bim1[i]
        jmi     L3                      ;check sign bit N
        neg     b                       ;negate quotient if needed
L3      move    b0,x0                   ;move -yi/bim1[i] to x0
        tfr     y1,b  x0,x:(r1)+  y:(r6)+,y0 ;get bim1[i],save fk[i],get bi[i]
        macr    x1,x0,b    y0,y:(r5)+   ;bim1[i]+(fk[i]*yi), bim1[i] = bi[i]
        move    b,y:(r5)                ;bim1[i+1] = bim1[i]*(fk[i]*yi)
;
;       end of outer do loop
;
;       end of analysis
;
;       output coefficients to an external file
;
L4      move    #fk,r1                  ;r(1) points to fk[1]
        do      #nk,endout              ;output (nk) reflection coeffs.
        move    x:(r1)+,a               ;get next k value
        movep   a,y:dataout             ;output next k value
;
endout  nop
;
endfram nop
        end

