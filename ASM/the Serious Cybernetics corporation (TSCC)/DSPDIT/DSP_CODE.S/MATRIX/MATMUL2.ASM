;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; General Matrix Multiplication, C=AB. 
; 
; Last Update 04 Feb 87   Version 1.0
;
        opt     cex
        page    132,66,0,0
;
;       matrix multiply. Implements X=AB matrix operation.
;
;       A 2x3
mw      equ     2
mx      equ     3
;       B 3x5
my      equ     3
mz      equ     5
;
;
;
        org     x:0
mat_a                           ; A matrix 2x3
        dc        .4                    ;a(1,1)
        dc        .3                    ;a(1,2)
        dc        -.6                   ;a(1,3)
        dc       .15                    ;a(2,1)
        dc       -.8                    ;a(2,2)
        dc       .25                    ;a(2,3)

        org     y:0
mat_b                           ; B matrix 3x5
        dc        -.4                   ;b(1,1)
        dc        .35                   ;b(1,2)
        dc       .15                    ;b(1,3)
        dc        -.4                   ;b(1,4)
        dc       .2                     ;b(1,5)
        dc        .5                    ;b(2,1)
        dc       -.3                    ;b(2,2)
        dc       .4                     ;b(2,3)
        dc        .1                    ;b(2,4)
        dc       -.15                   ;b(2,5)
        dc        .6                    ;b(3,1)
        dc        -.35                  ;b(3,2)
        dc       .45                    ;b(3,3)
        dc        .25                   ;b(3,4)
        dc        .2                    ;b(3,5)

mat_c   ds      mw*mz           ;output C martix 2x5
;
;       matrix multiply for row major storage format
;
        org     p:$100
matmul  move    #mat_a,r0       ;point to A matrix
        move    #mat_b,r4       ;point to B matrix
        move    #mat_c,r6       ;output to C matrix
        move    #my,n0          ;second dimension of A
        move    #mz,n5          ;second dimension of B

        do      #mw,_ew         ;number of final rows
        do      #mz,_ez         ;number of final columns
        move    r0,r1           ; copy ptr
        move    r4,r5           ;copy second ptr
        clr     a
        move    x:(r1)+,x0  y:(r5)+n5,y0
        rep     #my-1           ;inner sum
        mac     x0,y0,a  x:(r1)+,x0  y:(r5)+n5,y0
        macr    x0,y0,a   (r4)+ ;move to next column in B
        move    a,y:(r6)+       ;save result
_ez
        move    (r0)+n0         ;move to next row in A
        move    #mat_b,r4       ;point back to first column in B
_ew
        end
