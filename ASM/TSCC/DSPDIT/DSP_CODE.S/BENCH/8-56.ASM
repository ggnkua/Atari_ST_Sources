     page 132,66,0,6
;********************************************
;Motorola Austin DSP Operation  June 30, 1988
;********************************************
;DSP56000/1
;Matrix Multiply, [2x2] times [2x2]
;File name: 8-56.asm
;**************************************************************************
;    Maximum execution time: 2.049 us at 20.5MHz/ 1.556 us at 27.0MHz
;    Memory Size: Prog:  21 words ; Data memory: 12 words
;    Number of clock cycles:  42 (21 instruction cycles)
;    Clock Frequency:    20.5 MHz / 27.0 MHz
;    Cycle time:         97.5ns   / 74.1ns
;**************************************************************************
;This routine does a [2x2] times [2x2] matrix multiplication for
;the DSP56000. Since modulo 4 addressing is used 
;for all matrices, the first location must have the 2 lsb's =0.
;
;       Matrix a is in X memory, 
;       matrix b is in Y memory,
;       matrix c is stored in X memory. 
;
;       All matrices are stored in "row major" format.
;
;**************************************************************************
;
;     X Memory         Y Memory
;
; --->| a22 |      |--->| b22 |
; |   | a21 |    |-|--->| b21 |
; |   | a12 |    | |--->| b12 |
; --->| a11 |    |----->| b11 |
; r0              r4
;             
; --->| c22 |
; |   | c21 |
; |   | c12 |
; --->| c11 |
; r1
;
;The routine computes the result on a row-column basis, i.e. the
;row index changes fastest. The column pointer (r4) stays within
;the same column by using modulo addressing with offset. When
;all rows are calculated (r0 has wrapped around) column 2 is 
;chosen by simply decrementing r4, and repeating the same
;procedure
;
;Note: the previous assumes that all immediate addressing is
;immediate short, i.e. all data is in internal memory.
;
;**************************************************************************
;
mata    equ     $10
matb    equ     $10
matc    equ     $20

        org     x:mata
        dc      $700000
        dc      $600000
        dc      $500000
        dc      $400000

        org     y:matb
        dc      $300000
        dc      $200000
        dc      $100000
        dc      $0F0000

        org     P:$40
;********************************************************************
        move #<mata,r0                         ;r0 points to matrix a
        move #<3,m0                            ;address a modulo 4
        move #<matb,r4                         ;r4 points to matrix b
        move m0,m4                             ;address b modulo 4
        move #<matc,r1                         ;r1 points to matrix c
        move #<2,n4                            ;offset is row size
        move n4,n1                             ;for b and c
        move m0,m1                             ;address c modulo 4 
        move          x:(r0)+,x0  y:(r4)+n4,y0 ;load first element.
        mpy  x0,y0,a  x:(r0)+,x0  y:(r4)+n4,y0 ;a11*b11
        macr x0,y0,a  x:(r0)+,x0  y:(r4)+n4,y0 ;+a12*b21->c11
        move          a,x:(r1)+n1              ;store c11
        mpy  x0,y0,a  x:(r0)+,x0  y:(r4)-,y0   ;a21*b11
        macr x0,y0,a  x:(r0)+,x0  y:(r4)+n4,y0 ;+a22*b21->c21
        move          a,x:(r1)-                ;store c21
        mpy  x0,y0,a  x:(r0)+,x0  y:(r4)+n4,y0 ;a11*b12
        macr x0,y0,a  x:(r0)+,x0  y:(r4)+n4,y0 ;+a12*b22->c12
        move          a,x:(r1)+n1              ;store c12
        mpy  x0,y0,a  x:(r0)+,x0  y:(r4)-,y0   ;a21*b12
        macr x0,y0,a                           ;+a22*b22->c22
        move          a,x:(r1)                 ;store c22
;************************************************************
        end
