;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Durbin Solution for PARCOR (LPC) Coefficients
; 
; Last Update 3 June 87   Version 1.2
;
;       Implements the Durbin LPC algorithm.
;
        opt     cex
        page    132,66,3,3
;
;       i/o file definitions
;
datain   equ    $ffff
dataout  equ    $fffe
nk       equ    10              ;10th order LPC analysis

        org     x:0             ;I/O values in X: memory
r       ds      nk+1            ;autocorrelation coefficients
k       ds      nk              ;reflection coefficients

        org     y:0             ;temporary values in Y: memory
acoeffs dc      $7fffff         ;define a[0] = 1.0
        ds      nk              ;LPC filter coefficients
anew    dc      $7fffff         ;define anew[0] = 1.0
        ds      nk              ;updated LPC filter coefficients
alpha   ds      1               ;Durbin alpha
error   ds      1               ;Durbin error

        org     p:$100
;
;       find out how many frames to process
;
        movep   y:datain,n0
        do      n0,endframe

;
;       load the autocorrelations from an external file
;
        move    #r,r0           ;load autocorrelation
        do      #nk+1,loadr     ;get nk+1 autocorrelation values
        movep   y:datain,a      ;get next autocorrelation value
        move    a,x:(r0)+       ;and save it in the r array
;
;       The following registers correspond to the C variables:
;
;       r0 - r[i]               r4 - acoeffs[i]
;       r1 - k[i-1]             r5 - acoeffs[j-1]
;       r2 - r[i-j+1]           r6 - acoeffs[i-j+1]
;       r3 - anew[j-1]          r7 - loop counter
;
;       Approximate analysis times:
;
;            8th  order: 63.5  uS
;            10th order: 85.6  uS
;            16th order: 165.7 uS
;
;       Initialization
;
loadr   move    #r,r0                   ;r(0) points to r[0]
        move    #k,r1                   ;r(1) points to k[0]
;
;       Begin Durbin Algorithm
;
        move    x:(r0)+,x0              ;get r[0]
        move    x:(r0)+,a               ;get r[1], r(0) points to r[i]
        abs     a          a,b          ;get abs(r[1]), copy r[1] to b
        eor     x0,b  #acoeffs+1,r4     ;N = sign bit, r(4) points to a[i]
        and     #$fe,ccr                ;make quotient positive
        rep     #24                     ;set up for 24-bit quotient
        div     x0,a                    ;get abs(r[1])/r[0]
        jmi     L1                      ;check sign bit N
        neg     a                       ;negate quotient if needed
L1      move    a0,a                    ;move -r[1]/r[0] to A
        clr     b   a,x:(r1)+  a,y0     ;k[0] = -r[1]/r[0], copy k[0] to y0
        move    #$800000,b1             ;b = 1.0, r(1) points to k[i-1]
        macr    -y0,y0,b  #2,r7         ;b=1.0-(k[0]*k[0]),loop counter=2
        move    b,x1  a,y:(r4)+         ;x1 = 1.0-(k[0] * k[0]), a[1] = k[0]
        mpyr    x1,x0,a   #2,n7         ;a1 = r[0] * (1.0 - (k[0] * k[0]))
        move    a,y1                    ;alpha = r[0] * (1.0 - k[0] * k[0]))
        move    #-2,n5                   ;initialize n(5) 
;
;       outer do loop  (note: alpha = y1)
;
        do      #nk-1,L6                ;do outer do loop (nk-1) times
        move    r0,r2                   ;r(2) points to r[i]
        move    #acoeffs,r5             ;r(5) points to a[0]
        move    (r0)+                   ;r(0) points to next r[i]
        clr     a x:(r2)-,x0 y:(r5)+,y0 ;error = 0, preload 1st operand set
;
;       inner do loop #1  (note: r7 = i)
;
        do      r7,L2                         ;do inner do loop #1 (i) times
        mac     x0,y0,a x:(r2)-,x0 y:(r5)+,y0 ;error += a[j-1] * r[i-j+1]
;
;       back to outer do loop  (note: error = a)
;
L2      abs     a          a,b          ;get abs(error), copy error to b
        eor     y1,b       #2,n6        ;N = sign bit, y1 = alpha
        and     #$fe,ccr                ;make quotient positive
        rep     #24                     ;set up for 24-bit quotient
        div     y1,a                    ;get abs(error)/alpha
        jmi     L3                      ;check sign bit N
        neg     a                       ;negate quotient if needed
L3      move    a0,a                    ;move k[i-1] = -(error/alpha) to a
        clr b   a,x0    a,y:(r4)+       ;put k[i-1] in x0, a[i] = k[i-1]
        move    a,x:(r1)+  y:(r7)-,a    ;k[i-1] = -(error/alpha), dec r(7)
        move    #$800000,b1             ;b = 1.0
        macr    -x0,x0,b    r4,r6       ;b = 1.0 - (k[i-1] * k[i-1])
        move    b,x1                    ;r(6) points to a[i+1]
        mpyr    x1,y1,b   (r6)-n6       ;b = alpha * (1.0-(k[i-1]*k[I-1]))
        move    b,y1                    ;save alpha=alpha*(1-k[i-1]*k[i-1])
        move    #acoeffs+1,r5           ;r(5) points to a[j-1]
        move    #anew+1,r3              ;r(3) points to anew[j-1]
        move    y:(r6)-,y0              ;y0 = a[i-j+1], x0 = k[i-1]
        move    y:(r5)+,a               ;a = a[j-1]
;
;       inner do loop #2  (note: r7 = (i-1))
;
        do      r7,L4                   ;do inner do loop #2 (i-1) times
        macr    x0,y0,a  y:(r6)-,y0     ;get anew[j-1], y0 = next a[i-j+1]
        move    a,y:(r3)+               ;anew[j-1]=a[j-1]+k[i-1]*a[i-j+1]
        move    y:(r5)+,a               ;a = a[j-1]
;
;       end of inner do loop #2
;
;       inner do loop #3  (note: r7 = (i-1))
;
L4      move    x:(r3)-,x0 y:(r5)+n5,y0 ;dummy reads to dec r(3) and r(5)
        do      r7,L5                   ;do inner do loop #3 (i-1) times
        move    y:(r3)-,a               ;get anew[j-1]
        move    a,y:(r5)-               ;a[j-1] = anew[j-1]
;
;       end of inner do loop #3
;
;       end of outer do loop
;
;       end of analysis
;
;       output reflection coefficients to an external file
;
L5      move    (r7)+n7                 ;update loop counter
L6      move    #k,r1                   ;point to reflection coeffs.
        do      #nk,endsend             ;output nk k values
        move    x:(r1)+,x0              ;get next k value
        move    x0,y:dataout            ;output next K coefficient value
endsend
        nop
endframe
        nop
        end

