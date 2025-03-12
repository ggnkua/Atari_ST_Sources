     page 132,66,0,6
;********************************************
;Motorola Austin DSP Operation  June 30, 1988
;********************************************
;DSP56000/1
;Matrix Multiply, [3x3] times [3x1]
;File name: 9-56.asm
;**************************************************************************
;    Maximum execution time: 1.659 us at 20.5MHz/ 1.259 us at 27.0MHz
;    Memory Size: Prog:  17 words ; Data memory: 12 words (if b and c 
;                                                   occupy the same locations)
;    Number of clock cycles:  34 (17 instruction cycles)
;    Clock Frequency:    20.5 MHz / 27.0 MHz
;    Cycle time:         97.5ns   / 74.1ns
;**************************************************************************
;       This routine computes the product of a [3x3] matrix and a
;       [3x1] column vector for the DSP56000. 
;
;       Matrix a is in X memory, 
;       vector b is in Y memory, 
;       the resulting vector c is stored in Y memory. 
;
;       All matrices are in "row major" format.
;
;**************************************************************************
;    X Memory         Y Memory
;
; |->| a33 |          |     |
; |  | a32 |          |     |
; |  | a31 |      |-->| b3  |
; |  | a23 |      |   | b2  |
; |  | a22 |      |-->| b1  |
; |  | a21 |       r4 |     |
; |  | a13 |          |     |
; |  | a12 |           
; |->| a11 |      |-->| c3  |
; r0 |     |      |   | c2  |
;    |     |      |-->| c1  |
;                  r5
;
;Note: the previous assumes that all immediate addressing is
;immediate short, i.e. all data is in internal memory.
;
;**************************************************************************
;
mata    equ     $10
vecb    equ     $10
vecc    equ     $20

        org     x:mata
        dc      $700000
        dc      $600000
        dc      $500000
        dc      $400000
        dc      $300000
        dc      $200000
        dc      $100000
        dc      $0F0000
        dc      $0E0000

        org     y:vecb
        dc      $0C0000
        dc      $0B0000
        dc      $0A0000

        org     p:$40
;*****************************************************************
        move #<mata,r0                          ;point to matrix a
        move #<vecb,r4                          ;point to vector b
        move #<2,m4                             ;address b modulo 3
        move #<vecc,r5                          ;point to vector c
        move          x:(r0)+,x0  y:(r4)+,y0   ;initialize x0, y0
        mpy  x0,x0,a  x:(r0)+,x0  y:(r4)+,y0   ;a11*b1
        mac  x0,y0,a  x:(r0)+,x0  y:(r4)+,y0   ;+a12*b2
        macr x0,y0,a  x:(r0)+,x0  y:(r4)+,y0   ;+a13*b3->c1
        move                      a,y:(r5)+    ;store c1
        mpy  x0,y0,a  x:(r0)+,x0  y:(r4)+,y0   ;a21*b1
        mac  x0,y0,a  x:(r0)+,x0  y:(r4)+,y0   ;+a22*b2
        macr x0,y0,a  x:(r0)+,x0  y:(r4)+,y0   ;+a23*b3->c2
        move                      a,y:(r5)+    ;store c2
        mpy  x0,y0,a  x:(r0)+,x0  y:(r4)+,y0   ;a31*b11
        mac  x0,y0,a  x:(r0)+,x0  y:(r4)+,y0   ;+a32*b2
        macr x0,y0,a                           ;+a33*b3->c3
        move                      a,y:(r5)+    ;store c3
;**********************************************************
        end

