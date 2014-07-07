; 
; 512-Point, 28174 clock cycles Non-In-Place FFT. 
; 
; Sept. 11 92   Version 1.0
;
CFFT56  macro   IDATA,COEF,POINTS,ODATA
CFFT56  ident   1,0
;
; 512 Point Complex Fast Fourier Transform Routine
; using the Radix 2, Decimation in Time, Cooley-Tukey FFT algorithm.
;
; This routine performs a 512 point complex FFT by taking advantages of 
; 1). internal memory access by starting first half data at location 0,
;     avoid cycle stretching;
; 2). using N/4 complex twiddle factors based on the fact that two consective
;     twiddle factors in DIT FFT has a difference -j;
; 3). trivial twiddle factors (1,0) and (0,-1)  are utilized.
; 
;
;    Complex input and output data
;        Real data in X memory
;        Imaginary data in Y memory
;    Normally ordered input data
;    Bit reversed output data for 1024 real input FFT
;       Coefficient lookup table
;        +Cosine values in X memory
;        -Sine values in Y memory
;
;
; Address pointers are organized as follows:
;
;  r0 = ar,ai input pointer     n0 = group offset       m0 = modulo (points)
;  r1 = br,bi input pointer     n1 = group offset       m1 = modulo (points)
;  r2 = ext. data base address  n2 = groups per pass    m2 = 256 pt fft counter
;  r3 = coef. offset each pass  n3 = coefficient base addr.     m3 = linear
;  r4 = ar',ai' output pointer  n4 = group offset       m4 = modulo (points)
;  r5 = br',bi' output pointer  n5 = group offset       m5 = modulo (points)
;  r6 = wr,wi input pointer     n6 = coef. offset       m6 = bit reversed
;  r7 = not used (*)            n7 = not used (*)       m7 = not used (*)
;
;       * - r7, n7 and m7 are typically reserved for a user stack pointer.
;
; Alters Data ALU Registers
;       x1      x0      y1      y0
;       a2      a1      a0      a
;       b2      b1      b0      b
;
; Alters Address Registers
;       r0      n0      m0
;       r1      n1      m1
;       r2      n2      m2
;       r3      n3      m3
;       r4      n4      m4
;       r5      n5      m5
;       r6      n6      m6
;
; Alters Program Control Registers
;       pc      sr
;
; Uses 8 locations on System Stack                                           
;
;


;----------------------------------------------------------------------------;
; Initialize pointers to r0->Ar,r1->Cr,r4->Bi,r5->Di, and r3->temp location  ;
; r0,r1,r4, and r5 are modular addressing with modulo N/2                    ;
;----------------------------------------------------------------------------;

        move    #IDATA,r0       ;r0 -> Ar
        move    r0,n3
        move    #ODATA,r3       ;r3 always has ODATA
        move    #COEF+1,n6      ;n6 always has COEF,(0,1) is not used
        move    #POINTS/4,n0    ;offset and butterflies per group
        move    #POINTS/2-1,m0  ;modulo addressing
        move    r0,r6           ;r6=0 flag reg. for trivial groups

        do      #3,_end_trivial ;do three R4 passes
        move    n0,n1           ;pointer offset
        move    n0,n4           ;pointer offset
        move    n0,n5           ;
        lea     (r0)+n0,r4      ;r4 -> Bi
        move    m0,m5
        lea     (r4)+n4,r1      ;r1 -> Cr
        move    m0,m1           ;
        move    m0,m4
        lea     (r1)+n1,r5      ;r5 -> Di
;----------------------------------------------------------------------------------------;
;            First two passes are combined into a R4 pass without multiplication         ;
;             because Wr=1,Wi=0 in first R2 pass and Wr=0, Wi=-1 in 2nd R2 pass          ;
;                                                                                        ;
; Ar'=Ar+Cr+(Br+Dr)     Br'=Ar+Cr-(Br+Dr)     Cr'=(Ar-Cr)+(Bi-Di)    Dr'=(Ar-Cr)-(Bi-Di) ;     
; Ai'=Ai+Ci+(Bi+Di)     Bi'=Ai+Ci-(Bi+Di)     Ci'=(Ai-Ci)+(Dr-Br)    Di'=(Ai-Ci)-(Dr-Br) ;     
;                                                                                        ;
; This two passes fully ultilize internal memory by storing input data at location 0.    ;
; For 1024-point complex FFTs, only 256-point in internal, rest of them in               ;
; external, 17+2 instructions are needed for one butterfly because first and next to the ;
; last instruction in the loop takes two Icycles. Other parallel move seems to take two  ;
; cycles, but one of the two moves is internal, only one cycle is needed.                ;
; 4.75 Icycles per R2 butterfly in the fisrt two passes.                                 ;
;                                                                                        ;
; For 512-point complex FFT, 17+1 instructoins are used because first instruction in the ;
; loop takes only one Icycle. 4.5 Icycles per R2 butterfly.                              ;
;                                                                                        ;
; For 256 or less point complex FFT, 17 Icycles are needed. 4.25 Icycles/bfly.           ;
;                                                                                        ;
;----------------------------------------------------------------------------------------;
        move          x:(r0)+n0,a                ; a= Ar r0 -> Br
        move          x:(r1)+n1,b                ; b= Cr,r1 -> Dr

        do      n0,_twopass
        add     a,b   x:(r0)+n0,x1 y:(r5)+n5,y1  ;b=Ar+Cr,x1=Br,y1=Di,r0->Ar,r5->Ci
        subl    b,a   b,x:(r0)     y:(r4),b      ;a=Ar-Cr,save Ar+Cr temp in Ar,b=Bi
        add     y1,b  a,x0         y:(r4)+n4,a   ;b=Bi+Di,x0=Ar-Cr,a=Bi again, save Ar-Cr in Dr,r4->Ai
        sub     y1,a  b,x:(r3)     x0,b          ;a=Bi-Di,store Bi+Di temp in x:ODATA,b=Ar-Cr
        sub     a,b   x:(r1),x0                  ;b=Ar-Cr-(Bi-Di)=Dr',x0=Dr,r0 -> Ar
        addl    b,a   b,x:(r1)+n1  x0,b          ;a=Ar-Cr+(Bi-Di)=Cr',save Dr',b=Dr,r1->Cr
        sub     x1,b  a,x:(r1)+    x0,a          ;b=Dr-Br,            save Cr',a=Dr,r1->nCr
        add     x1,a  x:(r0)+n0,b  b,y1          ;a=Dr+Br,b=Ar+Cr, y1=Dr-Br,r0->Br
        sub     a,b                y:(r5),y0     ;a=Ar+Cr-(Dr+Br)=Br',y0=Ci
        addl    b,a   b,x:(r0)+n0  y:(r4),b      ;a=Ar+Cr+(Dr+Br)=Ar',save Br',r0->Ar,b=Ai
        sub     y0,b  a,x:(r0)+    y:(r4),a      ;b=Ai-Ci,a=Ai again, save Ar',r0->nAr
        add     y0,a  x:(r3),b     b,y0          ;a=Ai+Ci,y0=Ai-Ci,b=Bi+Di, r5->Ci
        add     a,b                              ;b=Ai+Ci+(Bi+Di)=Ai'
        subl    b,a   y0,b         b,y:(r4)+n4   ;a=Ai+Ci-(Bi+Di)=Bi',b=Ai-Ci,save Ai'
        add     y1,b  y0,a         a,y:(r4)+     ;b=Ai-Ci+(Dr-Br)=Ci',a=Ai-Ci,save Bi',r4->nBi
        sub     y1,a  x:(r1)+n1,b  b,y:(r5)+n5   ;a=Ai-Ci-(Dr-Br)=Di',b=nCr,  save Ci',
        move          x:(r0)+n0,a  a,y:(r5)+     ;                    a=nAr,  save Di',r5->nDi
_twopass
;----------------------------------------------------------------------------------------;
; Do rest of trivial group by 5 Icyc butterfly
;----------------------------------------------------------------------------------------;
        move    n5,a                             ;n5 contains ptr to Ar already
        asr     a      n5,r1                     ;r1->Ar
        move    a,n1                             ;get offset 
        move    r1,r5                            ;r5->Ai
        lea     (r1)+n1,r4                       ;r4->Bi
        move    #2,n4                            ;for pointer
        move    r4,r0                            ;r0->Br
        move         x:(r1),a  y:(r4)+,b         ;a=Ar,b=Bi,r4->nBi 
        do      n1,_no_more                      ;w=(0,-1), R2 butterfly 
        add     a,b  x:(r0),x0 y:(r4)-,y0        ;b=Ar+Bi=Ar',x0=Br,y0=nBi
        subl    b,a  b,x:(r1)+ y:(r5),b          ;a=Ar-Bi=Br',save Ar',b=Ai
        add     x0,b a,x:(r0)+ y:(r5),a          ;b=Ai+Br=Bi',save Br',a=Ai again
        subl    b,a  y0,b      b,y:(r4)+n4       ;a=Ai-Br=Ai',save Bi',b=nBi
        move         x:(r1),a  a,y:(r5)+         ;a=nAr,save Ai'  
_no_more
        move    n0,a
        asr     a     n3,r0                      ;r0->IDATA  
        asr     a     a,r2
        move    a,n0                             ;(points in a group)/4 after a radix 4 pass
        move    x:(r2)-,b                        ;dec r2
        move    r2,m0
_end_trivial
        move    r0,r4                            ;output pointer
        move    n1,r1                            ;r1->Br
        move    r1,r5                            ;r5->Bi
        move         x:(r0),a                    ;a=Ar
        move         x:(r1),b                    ;b=Br
        do      n1,_extra                        ;w=(1,0)
        add     a,b            y:(r5),y0         ;b=Ar+Br=Ar', y0=Bi 
        subl    b,a  b,x:(r0)+ y:(r4),b          ;a=Ar-Br=Br',save Ar',b=Ai
        add     y0,b a,x:(r1)+ y:(r4),a          ;b=Ai+Bi=Ai',save Br',a=Ai
        sub     y0,a x:(r1),b  b,y:(r4)+         ;a=Ai-Bi=Bi',save Ai',b=nBr
        move         x:(r0),a  a,y:(r5)+         ;a=nAr,      save Bi' 
_extra
        
;----------------------------------------------------------------------------------------;
; Remaining passes are broken down to POINTS/256 sets, each set has 256-point R2 FFT     ; 
; and runs on internal data and external coefficients.                                   ;
;                                                                                        ;
; In each pass, first two groups takes advantages of trivial twiddle factors and no      ;
; multiplication is carried out. Remaining groups use complex twiddle factors.           ;
;                                                                                        ;
; Radix 2, Decimation In Time Cooley-Tukey FFT algorithm                                 ;
;                  ___________                                                           ;
;                 |           |      Ar' = Ar + Wr*Br - Wi*Bi                            ;
;      Ar,Ai ---->|  Radix 2  |----> Ai' = Ai + Wi*Br + Wr*Bi                            ;
;      Br,Bi ---->| Butterfly |----> Br' = Ar - Wr*Br + Wi*Bi = 2*Ar - Ar'               ;
;                 |___________|      Bi' = Ai - Wi*Br - Wr*Bi = 2*Ai - Ai'               ;
;                       ^                                                                ;
;                       |                                                                ;
;                   W= Wr-jWi                                                            ;
;                                                                                        ;
; r0->A,r1->B,r4->A',r5->B',r6->TF,n0=offset for B pointer,n2=numberof bflies in a group ;
; n3=number of groups in a pass, m3=number of pass. r2=n3 or n3+1                        ;
;----------------------------------------------------------------------------------------;
        move    m2,m0                     ;linear address 
        move    m2,m1
        move    m2,m4
        move    m2,m5
        move    #POINTS/4,r0              ;start location of a pass
        move    #4,m3                     ;4 passes in first 256-point
        move    #POINTS/16,n0             ;offset to point to Br and Bi
        move    n0,n1
        move    n0,n4
        move    n0,n5           
        move    n6,r6                     ;r6->COEF
        move    n0,n2                     ;number of bflies in the first pass=R2 bfies/4
        lea     (r0)+n0,r1                ;r1->Br
        move    r0,r4                     ;r4->Ai
        lea     (r1)-,r5                  ;r5->Bi-1 for pointer reason
        jsr     _body

;----------------------------------------------------------------------------------------;
; The second 256-point FFT has no any trivial twiddle factors, three nested loops do it  ; 
;----------------------------------------------------------------------------------------;
        move    #256,r0                   ;start location of first pass in 2nd 256
        move    #5,m3                     ;5 passes in second 256-point
        move    #POINTS/8,n0              ;offset to point to Br and Bi
        move    #COEF+1,r6                ;twiddle factor pointer
        move    n0,n1
        move    n0,n4
        move    #IDATA,r4                 ;r4->A' =IDATA
        move    n0,n5
        lea     (r4)+n4,r5                ;r5->B'
        lea     (r0)+n0,r1                ;r1->B
        move    x:(r5)-,a                 ;r5->B'-1 for pointer reason
        jsr     _body
        jmp     _end_FFT

;----------------------------------------------------------------------------------------;
; All subroutines 
;----------------------------------------------------------------------------------------;
_body
        move    #1,n3                     ;number of groups in a pass
        move    n3,r2                     ;copy of n3
        jset    #0,m3,_set_grp            ;first 256-point has number of group 1,3,7,15,..
        move    #2,r2
_set_grp
        do      m3,_inner_loop
        jsr     _inner_pass
        move    n0,a
        asr     a      #IDATA,r0          ;r0=IDATA   
        move    a,n0                      ;n0=offset of B
        move    r2,a
        asl     a      n0,n1 
        move    a,r2                      ;r2=r2*2
        asr     b      r2,n3              ;n3=number of groups in second 256 
        jset    #0,m3,_inner_set          ;set up start address,for 2nd 256-point r0 is already ok
        lea     (r2)-,n3                  ;n3=number of groups in first 256 
        move    n4,a
        asl     a      n6,r6              ;for 1st 256, TF always starts at first location
        move    a,r0                      ;r0=start location of first 256-point
_inner_set
        move    n0,n4  
        move    n0,n5
     ;   move    n0,r4
        lea     (r0)+n0,r1                ;r1->B
        move    r0,r4                     ;r4->A'
        lea     (r1)-,r5                  ;r5->B'
_inner_loop

;----------------------------------------------------------------------------------------;
;  End inner loop
;----------------------------------------------------------------------------------------;
        move    #IDATA,r0
        move    #32,n2                    ;n2=number of groups in the next to last pass for 1st 256
        jset    #0,m3,_no_set             ;set up start address of TF,for 2nd 256-point r6 is already ok
        move    #COEF,n6                  ;now n6 -> COEF
        move    n6,r6                     ;r6=COEF
        lea     (r0)+n0,r1                ;r1->Br
        move    r0,r4                     ;r4->Ai
_no_set 
        move    #-1,r5                    ;r5->Bi
        move    #3,n0
        move    n0,n1
        move    n0,n4
        move    n0,n5
        jsr     _next_last                ;do the pass next to last
;----------------------------------------------------------------------------------------;
;  End _next_last pass
;----------------------------------------------------------------------------------------;
        move    #IDATA,r0                 ;r0->IDATA 
        move    r3,r4                     ;r4->A',output ptr -> external memory 
        jclr    #0,m3,_add_offset         ;set up output address for 2nd 256-point 
        move    #256,n3
        move    r6,n6                     ;start address of TF for 2nd 256
        lea     (r3)+n3,r4
_add_offset
        lea     (r0)+,r1                  ;r1->B
        lea     (r4)-,r5                  ;r5->B'
        move    #64,n2                    ;number of blies in the last pass
        move    #2,n0
        move    n0,n1
        move    n0,n4
        move    n0,n5
        move    n6,r6                     ;r6=COEF
        jsr     _last
        rts


_inner_pass
        do      n3,_end_grp                                  ;do groups in a pass
        move    x:(r5),a                                     ;for pointer reason,a=something  
        move    x:(r6),x0 y:(r0),b                           ;x0=Wr,b=Ai
        move    x:(r1),x1 y:(r6)+,y0                         ;x1=Br,y0=Wi 
        do      n0,_end_bfy1        ;Radix 2 DIT butterfly kernel with y0=Wi,x0=Wr
	mac     -x1,y0,b                      y:(r1)+,y1     ;b=Ai-BrWi,y1=Bi, r1->nBi
        macr    x0,y1,b         a,x:(r5)+     y:(r0),a       ;b=Ai-BrWi+BiWr=Ai',save prev. Br',a=Ai
        subl    b,a             x:(r0),b      b,y:(r4)       ;a=2Ai-Ai'=Bi',b=Ar,save Ai'
        mac     x1,x0,b         x:(r0)+,a     a,y:(r5)       ;b=Ar+BrWr,a=Ar,save Bi',r0->nAi
        macr    y1,y0,b         x:(r1),x1                    ;b=Ar+BrWr+BiWi=Ar',x1=nBr
        subl    b,a             b,x:(r4)+     y:(r0),b       ;a=2Ar-Ar'=Br',save Ar',b=nAi,r4->nAr
_end_bfy1
        move                    a,x:(r5)+n5   y:(r1)+n1,b    ;save preve. Br' inc r5 and r1
        move                    x:(r4)+n4,a   y:(r0)+n0,b    ;inc r0,r4  
        move                    x:(r1),x1                    ;x1=nGBr
        move                    x:(r5),a      y:(r0),b       ;for pointer reason,a=something,b=nGAr 

        do      n0,_end_bfy2       ;W=-j*W
	mac     -x1,x0,b                      y:(r1)+,y1     ;b=Ai-BrWr,y1=Bi,r1->nBi
        macr    -y0,y1,b        a,x:(r5)+     y:(r0),a       ;b=Ai-BrWr-BiWi=Ai',save prev. Br',a=Ai
        subl    b,a             x:(r0),b      b,y:(r4)       ;a=2Ai-Ai'=Bi',b=Ar,save Ai'
        mac     -x1,y0,b        x:(r0)+,a     a,y:(r5)       ;b=Ar-BrWi,a=Ar,save Bi',r0->nAi
        macr    y1,x0,b         x:(r1),x1                    ;b=Ar-BrWi+BiWr=Ar',x1=nBr
        subl    b,a             b,x:(r4)+     y:(r0),b       ;a=2Ar-Ar'=Br',save Ar',b=nAi,r4->nAr
_end_bfy2
        move                    a,x:(r5)+n5   y:(r1)+n1,b    ;save preve. Br' inc r5 and r1
        move                    x:(r4)+n4,a   y:(r0)+n0,b    ;inc r0,r4  
_end_grp
        rts

_next_last
        move    x:(r5),a  y:(r0),b                           ;a=something,b=Ai
        move    x:(r1),x1 y:(r6),y0                          ;x1=Br,y0=Wi 
        do      n2,_n_last        ;do the pass next to last, internal to internal
	mac     -x1,y0,b        x:(r6)+,x0      y:(r1)+,y1   ;b=Ai-BrWi,x0=Wr,y1=Bi, r1->nBi
        macr    x0,y1,b         a,x:(r5)+n5     y:(r0),a     ;b=Ai-BrWi+BiWr=Ai',save prev. Br',a=Ai
        subl    b,a             x:(r0),b        b,y:(r4)     ;a=2Ai-Ai'=Bi',b=Ar,save Ai'
        mac     x1,x0,b         x:(r0)+,a       a,y:(r5)     ;b=Ar+BrWr,a=Ar,save Bi',r0->nAi
        macr    y1,y0,b         x:(r1),x1                    ;b=Ar+BrWr+BiWi=Ar',x1=nBr
        subl    b,a             b,x:(r4)+       y:(r0),b     ;a=2Ar-Ar'=Br',save Ar',b=nAi,r4->nAr

	mac     -x1,y0,b                        y:(r1)+n1,y1 ;b=Ai-BrWi,y1=Bi, r1->nGBi
        macr    x0,y1,b         a,x:(r5)+       y:(r0),a     ;b=Ai-BrWi+BiWr=Ai',save prev. Br',a=Ai
        subl    b,a             x:(r0),b        b,y:(r4)     ;a=2Ai-Ai'=Bi',b=Ar,save Ai'
        mac     x1,x0,b         x:(r0)+n0,a     a,y:(r5)     ;b=Ar+BrWr,a=Ar,save Bi',r0->nGAi
        macr    y1,y0,b         x:(r1),x1                    ;b=Ar+BrWr+BiWi=Ar',x1=nGBr
        subl    b,a             b,x:(r4)+n4     y:(r0),b     ;a=2Ar-Ar'=Br',save Ar',b=nGAi,r4->nGAr

	mac     -x1,x0,b                        y:(r1)+,y1   ;b=Ai-BrWr,y1=Bi,r1->nGBi
        macr    -y0,y1,b        a,x:(r5)+n5     y:(r0),a     ;b=Ai-BrWr-BiWi=Ai',save prev. Br',a=Ai,r5->nGBi 
        subl    b,a             x:(r0),b        b,y:(r4)     ;a=2Ai-Ai'=Bi',b=Ar,save Ai'
        mac     -x1,y0,b        x:(r0)+,a       a,y:(r5)     ;b=Ar-BrWi,a=Ar,save Bi',r0->nGAi
        macr    y1,x0,b         x:(r1),x1                    ;b=Ar-BrWi+BiWr=Ar',x1=nBr
        subl    b,a             b,x:(r4)+       y:(r0),b     ;a=2Ar-Ar'=Br',save Ar',b=nAi,r4->nGAr

	mac     -x1,x0,b                        y:(r1)+n1,y1 ;b=Ai-BrWr,y1=Bi,r1->nGBi
        macr    -y0,y1,b        a,x:(r5)+       y:(r0),a     ;b=Ai-BrWi-BiWr=Ai',save prev. Br',a=Ai,r5->Bi 
        subl    b,a             x:(r0),b        b,y:(r4)     ;a=2Ai-Ai'=Bi',b=Ar,save Ai'
        mac     -x1,y0,b        x:(r0)+n0,a     a,y:(r5)     ;b=Ar-BrWi,a=Ar,save Bi',r0->nGAi
        macr    y1,x0,b         x:(r1),x1       y:(r6),y0    ;b=Ar-BrWi+BiWr=Ar',x1=nBr,y0=nWi
        subl    b,a             b,x:(r4)+n4     y:(r0),b     ;a=2Ar-Ar'=Br',save Ar',b=nAi,r4->nGAr

_n_last
        move                    a,x:(r5)
        rts

_last
        move    x:(r5),a y:(r0),b                            ;a=something,b=Ai
        move    x:(r1),x1 y:(r6),y0                          ;x1=Br,y0=Wi 
        do      n2,_end_last    ; do last pass, internal to external
	mac     -x1,y0,b        x:(r6)+,x0      y:(r1)+n1,y1 ;b=Ai-BrWi,x0=Wr,y1=Bi, r1->nGBi
        macr    x0,y1,b         a,x:(r5)+n5     y:(r0),a     ;b=Ai-BrWi+BiWr=Ai',save prev. Br',a=Ai
        subl    b,a             x:(r0),b        b,y:(r4)     ;a=2Ai-Ai'=Bi',b=Ar,save Ai'
        mac     x1,x0,b         x:(r0)+n0,a     a,y:(r5)     ;b=Ar+BrWr,a=Ar,save Bi',r0->nGAi
        macr    y1,y0,b         x:(r1),x1                    ;b=Ar+BrWr+BiWi=Ar',x1=nGBr
        subl    b,a             b,x:(r4)+n4     y:(r0),b     ;a=2Ar-Ar'=Br',save Ar',b=nGAi,r4->nGAr

	mac     -x1,x0,b                        y:(r1)+n1,y1 ;b=Ai-BrWr,y1=Bi,r1->nGBi
        macr    -y0,y1,b        a,x:(r5)+n5     y:(r0),a     ;b=Ai-BrWr-BiWi=Ai',save prev. Br',a=Ai,r5->Bi 
        subl    b,a             x:(r0),b        b,y:(r4)     ;a=2Ai-Ai'=Bi',b=Ar,save Ai'
        mac     -x1,y0,b        x:(r0)+n0,a     a,y:(r5)     ;b=Ar-BrWi,a=Ar,save Bi',r0->nGAi
        macr    y1,x0,b         x:(r1),x1       y:(r6),y0    ;b=Ar-BrWi+BiWr=Ar',x1=nBr,y0=nWi
        subl    b,a             b,x:(r4)+n4     y:(r0),b     ;a=2Ar-Ar'=Br',save Ar',b=nAi,r4->nGAr
_end_last
        move                    a,x:(r5)
        rts
_end_FFT
        endm
