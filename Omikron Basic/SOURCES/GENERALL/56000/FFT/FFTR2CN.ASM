;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Radix 2, In-Place, Decimation-In-Time FFT (fast).
; 
; Last Update 18 Aug 88   Version 1.0
;
fftr2cn  macro   points,data,odata,coef
fftr2cn  ident   1,0
;
; Radix 2 Decimation in Time In-Place Fast Fourier Transform Routine
;
;    Complex input and output data
;        Real data in X memory
;        Imaginary data in Y memory
;    Normally ordered input data
;    Normally ordered output data
;       Coefficient lookup table
;        -Cosine values in X memory
;        -Sine values in Y memory
;
; Macro Call - fftr2cn   points,data,odata,coef
;
;       points     number of points (16-32768, power of 2)
;       data       start of data buffer
;       odata      start of output data buffer
;       coef       start of sine/cosine table
;
; Alters Data ALU Registers
;       x1      x0      y1      y0
;       a2      a1      a0      a
;       b2      b1      b0      b
;
; Alters Address Registers
;       r0      n0      m0
;       r1      n1      m1
;               n2
;
;       r4      n4      m4
;       r5      n5      m5
;       r6      n6      m6
;
; Alters Program Control Registers
;       pc      sr
;
; Uses 6 locations on System Stack
;
; Latest Revision - 18 Aug-88
;
     move #data,r0            ;initialize input pointer
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

     do   #@cvi(@log(points)/@log(2)-2.5),_end_pass  ;-1 ??? example: 7 passes for 1024 pt. FFT
     move #data,r0                                     ;initialize A input pointer
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
     move           x:(r1),x1      y:(r6),y0           ;x1=br,y0=wi,lookup -sine and -cosine values
     move           x:(r6)+n6,x0   y:(r0),b            ; b=ai, x0=wr,update C pointer, preload data
     mac  x1,y0,b                  y:(r1)+,y1		    ;y1=bi,b=ai+br*wi,
     macr -x0,y1,b                 y:(r0),a            ; a=ai again,b=ai+br*wi-bi*wr=bi'

     do   n2,_end_grp
     do   r2,_end_bfy                                  ;loop BF-1 times and start Radix 2 DIT BF kernel 
     subl b,a       x:(r0),b       b,y:(r4)            ;b=ar,a=ai-br*wi+bi*wr=ai',         PUT bi'
     mac  -x1,x0,b  x:(r0)+,a      a,y:(r5)            ;a=br,b=ar-br*wr,                   PUT ai'
     macr -y1,y0,b  x:(r1),x1                          ;b=ar-(br*wr+bi*wi)=br',x1=next br
     subl b,a       b,x:(r4)+      y:(r0),b	          ;b=nai,a=2*ar-ar+br*wr+bi*wi=ar',   PUT br'
     mac  x1,y0,b                  y:(r1)+,y1          ;y1=nbi,b=nai+nbr*wi	
     macr -x0,y1,b  a,x:(r5)+      y:(r0),a            ;a=nai,b=nai+nbr*wi-nbi*wr=nbi'     PUT ar'
_end_bfy
     move (r1)+n1                                      ;points to first B in next group
     subl b,a       x:(r0),b       b,y:(r4)            ; PUT last bi' in a group
     mac  -x1,x0,b  x:(r0)+n0,a    a,y:(r5)            ; PUT last ai' in a group and update A pointer
     macr -y1,y0,b  x:(r1),x1      y:(r6),y0
     subl b,a       b,x:(r4)+n4    y:(r0),b            ; PUT last br' in a group and update A' pointer
     mac  x1,y0,b   x:(r6)+n6,x0   y:(r1)+,y1          ; update W pointer 
     macr -x0,y1,b  a,x:(r5)+n5    y:(r0),a            ; PUT last ar' in a group and update B' pointer
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
     move #data,r0       ;initialize A input pointer
     move #odata,r4      ;initialize A output pointer
     move r4,r2          ;save A output pointer
     lua  (r0)+,r1       ;initialize B input pointer
     lua  (r2)+n2,r5     ;initialize B output pointer
     move #0,m4          ;bit-reversed addressing for output ptr. A
     move m4,m5          ;bit-reversed addressing for output ptr. B
     move #coef,r6       ;initialize C input pointer
     move (r5)-n5        ;predecrement output pointer
     move           x:(r1),x1      y:(r6),y0 ;x1=br,y0=wi
     move           x:(r5),a       y:(r0),b	;a=?,b=ai

     do   n2,_lastpass   ;Radix 2 DIT butterfly kernel with one butterfly per group 
     mac  x1,y0,b   x:(r6)+n6,x0   y:(r1)+n1,y1  ;b=ai+br*wi,x0=wr, y1=bi 
     macr -x0,y1,b  a,x:(r5)+n5    y:(r0),a      ;b=ai+br*wi-bi*wr=bi',a=ai, PUT previous ar'  
     subl b,a       x:(r0),b       b,y:(r4)		 ;a=ai',b=ar,                PUT bi' 
     mac  -x1,x0,b  x:(r0)+n0,a    a,y:(r5)		 ;b=ar-br*wr,a=ar,           PUT ai'
     macr -y1,y0,b  x:(r1),x1      y:(r6),y0		 ;b=br',x1=nbr,y0=nwi
     subl b,a       b,x:(r4)+n4    y:(r0),b		 ;a=ar',b=nai,               PUT br'
_lastpass
     move           a,x:(r5)+n5                  ;                           PUT ar'
     endm
