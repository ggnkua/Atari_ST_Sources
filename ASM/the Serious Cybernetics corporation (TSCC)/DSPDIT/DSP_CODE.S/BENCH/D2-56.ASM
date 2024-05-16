     page 132,60,1,1
;*******************************************
;Motorola Austin DSP Operation  June 30,1988
;*******************************************
;DSP56000/1
;Port to Memory FFT - 64 point
;File name: D2-56.asm
;**************************************************************************
;    Maximum sample rate:  266.54 us at 20.5 MHZ/ 202.37 us at 27.0 MHz
;    Memory Size: Prog:  118 words ; Data:  514 words
;    Number of clock cycles:  5464 (2732 instruction cycles)
;    Clock Frequency:    20.5MHz/27.0MHz
;    Instruction cycle time:  97.5ns /  74.1ns
;**************************************************************************
;
; Radix 2 Decimation in Time Fast Fourier Transform Routine
;
;    Real input and output data
;        Real data in X memory
;        Imaginary data in Y
;    Normally ordered input data
;    Normally ordered output data
;    Coefficient lookup table
;        -Cosine value in X memory
;        -Sine value in Y memory
;
; Macro Call - fftedn1   points,data,odata,coef,ptr1,ptr2
;
;    points     number of points (2-32768, power of 2)
;    data       start of data buffer
;    odata      start of output data buffer
;    coef    start of sine/cosine table
;    ptr1    location of pointer to block 1 (data collection)
;    ptr2    location of pointer to block 2 (FFT computation)
;
; Alters Data ALU Registers
;    x1   x0   y1   y0
;    a2   a1   a0   a
;    b2   b1   b0   b
;
; Alters Address Registers
;    r0   n0   m0
;    r1   n1   m1
;    r2   n2
;
;    r4   n4   m4
;    r5   n5   m5
;    r6   n6   m6
;
; Alters Program Control Registers
;    pc   sr
;
; Uses 6 locations on System Stack
;
;**************************************************************************
;
fftedn1   macro     points,data,odata,coef,ptr1,ptr2
fftedn1   ident     1,2

strt move #points,b ;input buffer length
loop move r7,a      ;get input data pointer
     sub  a,b       ;subtract buffer length from current input location
     move x:ptr1,a  ;move input data base addres into a
     cmp  a,b       ;see if equal
     jne  loop      ;if not, go back
;
;    when ready, swap pointers of buffer to be loaded and buffer to be processed
;
     move x:ptr1,a
     move x:ptr2,b
     move b,x:ptr1
     move a,x:ptr2
;
;    main fft routine
;

     move ptr2,r0             ;initialize input pointer
     move #points/4,n0        ;initialize input and output pointers offset
     move n0,n4               ;
     move n0,n6               ;initialize coefficient offset
     move #points-1,m0        ;initialize address modifiers
     move m0,m1               ;for modulo addressing
     move m0,m4
     move m0,m5
;
; Do first and second Radix 2 FFT passes, combined as 4-point butterflies
;
     move           x:(r0)+n0,x0
     tfr  x0,a      x:(r0)+n0,y1   

     do   n0,_twopass
     tfr  y1,b      x:(r0)+n0,y0
     add  y0,a      x:(r0),x1                     ;ar+cr
     add  x1,b      r0,r4                         ;br+dr
     add  a,b       (r0)+n0                       ;ar'=(ar+cr)+(br+dr)
     subl b,a       b,x:(r0)+n0                   ;br'=(ar+cr)-(br+dr)
     tfr  x0,a      a,x0           y:(r0),b
     sub  y0,a                     y:(r4)+n4,y0   ;ar-cr
     sub  y0,b      x0,x:(r0)                     ;bi-di
     add  a,b                      y:(r0)+n0,x0   ;cr'=(ar-cr)+(bi-di)
     subl b,a       b,x:(r0)                      ;dr'=(ar-cr)-(bi-di)
     tfr  x0,a      a,x0           y:(r4),b
     add  y0,a                     y:(r0)+n0,y0   ;bi+di
     add  y0,b      x0,x:(r0)+n0                  ;ai+ci
     add  b,a                      y:(r0)+,x0     ;ai'=(ai+ci)+(bi+di)
     subl a,b                      a,y:(r4)+n4    ;bi'=(ai+ci)-(bi+di)
     tfr  x0,a                     b,y:(r4)+n4
     sub  y0,a      x1,b                          ;ai-ci
     sub  y1,b      x:(r0)+n0,x0                  ;dr-br
     add  a,b       x:(r0)+n0,y1                  ;ci'=(ai-ci)+(dr-br)
     subl b,a                      b,y:(r4)+n4    ;di'=(ai-ci)-(dr-br)
     tfr  x0,a                     a,y:(r4)+
_twopass
;
; Perform all next FFT passes except last pass with triple nested DO loop
;    
     move #points/8,n1        ;initialize butterflies per group
     move #4,n2               ;initialize groups per pass
     move #-1,m2              ;linear addressing for r2
     move #0,m6               ;initialize C address modifier for
                              ;reverse carry (bit-reversed) addressing

     do   #@cvi(@log(points)/@log(2)-2.5),_end_pass    ;example: 7 passes for 1024 pt. FFT
     move ptr2,r0                                      ;initialize A input pointer
     move r0,r1
     move n1,r2
     move r0,r4                                        ;initialize A output pointer
     move (r1)+n1                                      ;initialize B input pointer
     move r1,r5                                        ;initialize B output pointer
     move #coef,r6                                     ;initialize C input pointer
     lua  (r2)+,n0                                     ;initialize pointer offsets
     move n0,n4
     move n0,n5
     move (r2)-                                        ;butterfly loop count
     move           x:(r1),x1      y:(r6),y0           ;lookup -sine and -cosine values
     move           x:(r6)+n6,x0   y:(r0),b            ;update C pointer, preload data
     mac  x1,y0,b                  y:(r1)+,y1
     macr -x0,y1,b                 y:(r0),a

     do   n2,_end_grp
     do   r2,_end_bfy
     subl b,a       x:(r0),b       b,y:(r4)            ;Radix 2 DIT butterfly kernel
     mac  -x1,x0,b  x:(r0)+,a      a,y:(r5)
     macr -y1,y0,b  x:(r1),x1
     subl b,a       b,x:(r4)+      y:(r0),b
     mac  x1,y0,b                  y:(r1)+,y1
     macr -x0,y1,b  a,x:(r5)+      y:(r0),a
_end_bfy
     move (r1)+n1
     subl b,a       x:(r0),b       b,y:(r4)
     mac  -x1,x0,b  x:(r0)+n0,a    a,y:(r5)
     macr -y1,y0,b  x:(r1),x1      y:(r6),y0
     subl b,a       b,x:(r4)+n4    y:(r0),b
     mac  x1,y0,b   x:(r6)+n6,x0   y:(r1)+,y1
     macr -x0,y1,b  a,x:(r5)+n5    y:(r0),a
_end_grp
     move n1,b1
     lsr  b    n2,a1     ;divide butterflies per group by two
     lsl  a    b1,n1     ;multiply groups per pass by two
     move a1,n2
_end_pass
;
; Do last FFT pass
;
     move #2,n0          ;initialize pointer offsets
     move n0,n1
     move #points/4,n4   ;output pointer A offset
     move n4,n5          ;output pointer B offset
     move ptr2,r0        ;initialize A input pointer
     move #odata,r4      ;initialize A output pointer
     move r4,r2          ;save A output pointer
     lua  (r0)+,r1       ;initialize B input pointer
     lua  (r2)+n2,r5     ;initialize B output pointer
     move #0,m4          ;bit-reversed addressing for output ptr. A
     move m4,m5          ;bit-reversed addressing for output ptr. B
     move #coef,r6       ;initialize C input pointer
     move (r5)-n5        ;predecrement output pointer
     move           x:(r1),x1      y:(r6),y0
     move           x:(r5),a       y:(r0),b

     do   n2,_lastpass
     mac  x1,y0,b   x:(r6)+n6,x0   y:(r1)+n1,y1   ;Radix 2 DIT butterfly kernel
     macr -x0,y1,b  a,x:(r5)+n5    y:(r0),a       ;with one butterfly per group
     subl b,a       x:(r0),b       b,y:(r4)
     mac  -x1,x0,b  x:(r0)+n0,a    a,y:(r5)
     macr -y1,y0,b  x:(r1),x1      y:(r6),y0
     subl b,a       b,x:(r4)+n4    y:(r0),b
_lastpass
     move           a,x:(r5)+n5
;
;    when fft is finished, jump back to see if data collection for next fft is completed
     jmp  strt           
     endm
;
;
;
;    interrupt routine
     org p:$8
     movep     y:$ffff,y:(r7)+          ;data collection upon interrupt
;
;    main routine
     org p:$100
     move #16,a
     move a,x:$d0                       ;store pointer to data block 1
     move #80,a
     move a,x:$d1                       ;store pointer to data block 2
     move #127,m7                       ;set r7 for modulo addressing
;
;    call fft macro
     fftedn1 64,16,144,210,208,209    
     end
