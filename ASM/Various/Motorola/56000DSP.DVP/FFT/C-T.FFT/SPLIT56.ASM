
;**************************************************************************
;
; Split N/2 Complex FFT(Hn) for N real FFT(Fn)
;
SPLIT56 	macro	 IDATA,COEF,POINTS,ODATA
SPLIT56 	ident    1,0
;
;
; Fi=0.5(Hi+Hn/2-i*)-0.5j(Hi-Hn/2-i*)W i=0,1,,,N-1
;
; Bit reverse input, Normal order output
; This macro amplifies coefficients of FFT by 2.
; If absolute values of spectrum are desired, then scaling up factor is 2^(N-1),
; assuming inputs are scaled by 2^N before complex FFT.
; POINTS is the number of real data /2
; COEF is twiddle factor location other than TF used in complex FFT (see sincosr)
;
;

      move    #POINTS-1,n0   	                         ;number of complex FFT input data -1
      move    #POINTS/2-1,n2                             ;loop counter
      move    #ODATA,r0	   	                         ;r0 ptr to Ar=Hi
      move    #COEF-POINTS/2+1,r2                        ;twiddle factor start location 
      move    r2,r6                                      ;r6 -> Wi
      lea     (r0)+n0,r5                                 ;r5 ptr to Br & Bi
      move    #IDATA,r3                                  ;r3 pointer for A'
     ; move    r3,r4                                      
      move    n0,r1                                      ;r1 ptr for B', r1=B
      move    #POINTS/2,n0
      move    n0,n5
      move    m5,m3                                      ;m3 and m1 linear address
      move    m5,m1
      move    #0,m0                                      ;bit reverse address
      move    m0,m5                                      ;bit reverse address
      move                     x:(r0),b                  ;b=Ar0
      move                     x:(r5),x1   y:(r0),a      ;a=Ai0,x1=Br 
      add     a,b              x:(r1)+,x0                ;b=Ar0+Ai0=DC, for ptr reason inc r1 
      subl    b,a              r3,r4                     ;r4 ptr to temp location 
      asl     b                            y:(r1),a      ;a=something 
      asl     a                b,x:(r3)+   y:(r5),b      ;a=Niquist=Ar0-Ai0, save DC,b=Bi   
      move                                 a,y:(r0)+n0   ;save Niq in y:ODATA temp, 
      move                                 y:(r0),y0     ;y0=Ai

      do      n2,_end_split
      add     y0,b             y0,a        a,y:(r1)-     ;b=Ai+Bi=H2r,a=Ai, save prev. Bi' 
      subl    b,a              x:(r0),b    b,y1          ;a=Ai-Bi=H1i, b=Ar, y1=H2r
      sub     x1,b             x:(r0)+n0,a a,y:(r4)      ;b=Ar-Br=H2i,a=Ar again,save H1i temp,r0->nA
      subl    b,a              x:(r2)+,x1  y:(r6)+,y0    ;a=Ar+Br=H1r,x1=Wr,y0=Wi 
      mac     x1,y1,a          b,x0        a,y:(r5)      ;a=H1r+Wr*H2r,x0=H2i,save H1r temp
      macr    y0,x0,a                      y:(r5)-n5,b   ;a=H1r+Wr*H2r-Wi*H2i=Ar', b=H1r
      subl    a,b              a,x:(r3)    y:(r4),a      ;b=H1r-(Wr*H2r-Wi*H2i)=Br',a=H1i,save Ar' 
      mac     -x1,x0,a         b,x:(r1)    y:(r5),b      ;a=H1i-Wr*H2i,save Br',b=nBi
      macr    y1,y0,a                      y:(r4),y0     ;a=Wi*H2r-Wr*H2i+H1i=Ai',y0=H1i again  
      sub     y0,a             x:(r5),x1   a,y:(r3)+     ;a=Wi*H2r-Wr*H2i, x1=nBr,save Ai'
      sub     y0,a                         y:(r0),y0     ;a=Wi*H2r-Wr*H2i-H1i=Bi',y0=nAi
_end_split
      move                     y0,a        a,y:(r1)      ;save last Bi',conjugate last Ai
      neg     a                #ODATA,r5
      move                     #IDATA,r0   
      move                                 a,y:(r4)
      move                                 y:(r5),a
      move                                 a,y:(r0)      ;move Niq. back

      endm ;split56
