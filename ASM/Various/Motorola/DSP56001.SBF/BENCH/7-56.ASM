     page 132,66,0,6
;********************************************
;Motorola Austin DSP Operation  June 30, 1988
;********************************************
;DSP56000/1
;Dot Product
;File name: 7-56.asm
;**************************************************************************
;    Maximum execution time: 585.4 ns at 20.5MHz/ 444.4 ns at 27.0MHz
;    Memory Size: Prog: 6 words ; Data: 4 words (if z uses the same 
;                                                   address as x1 or x2)  
;    Number of clock cycles:  12 (6 instruction cycles)
;    Clock Frequency:    20.5 MHz / 27.0 MHz
;    Cycle time:         97.5ns   / 74.1ns
;**************************************************************************
;       This routine performs the scalar product of two
;       [2x1] vectors on the DSP56000. 
;
;       Vector a is in X memory, 
;       vector b is in Y memory, 
;       the result z is stored in X memory.
;
;**************************************************************************
;
;     X Memory                     Y Memory
;
; |  | x2 |          |->|  y2 |
; |->| x1 |          |->|  y1 |
; r0 |    |          r0 |     |
;
; |->| z  |              
;
;
;Note: the previous assumes that all immediate addressing is
;immediate short, i.e. all data is in internal memory.
;
;**************************************************************************
;
veca    equ     $010
z       equ     $010

        org     x:veca
        dc      $600000
        dc      $400000

        org     y:veca
        dc      $300000
        dc      $100000

        org     p:$40
;************************************************************
        move #<veca,r0                   ;point to vectors a,b
        move #<z,r1                      ;point to z
        move            l:(r0)+,x       ;load first elements.
        mpy  x0,x1,a    l:(r0)+,x       ;a1*b1
        macr x0,x1,a                    ;+a2*b2
        move            a,x:(r0)        ;--> z
;*************************************************************
        end
