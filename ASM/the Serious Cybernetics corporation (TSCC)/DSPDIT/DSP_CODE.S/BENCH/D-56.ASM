 	page 132,60,1,1
        opt  nomd,mex 
;*******************************************
;Motorola Austin DSP Operation  June 30,1988
;*******************************************
;DSP56000/1
;Port to Memory FFT - 64 point
;File name: D-56.asm
;**************************************************************************
;	Maximum sample rate:  121.9 us at 20.5 MHZ/ 92.56 us at 27.0 MHz
;	Memory Size: Prog:  254 words ; Data:  450 words
;	Number of clock cycles:	2499 (1249 instruction cycles)
;	Clock Frequency:	20.5MHz/27.0MHz
;	Instruction cycle time:	97.5ns /  74.1ns
;**************************************************************************
;
fftreald  macro     points,data,odata,coef,ptr1,ptr2
fftreald  ident     1,0   
;   
; Radix 2 Decimation in Time In-Place Fast Fourier Transform Routine   
;   
;    Real input data - normally ordered   
;        Real data in Y memory, 2 buffers: one being filled, the other one being processed
;    Complex output data - normally ordered   
;        Real data in X memory   
;        Imaginary data in Y memory   
;    Coefficient lookup table   
;        -Cosine value in X memory   
;        -Sine value in Y memory   
;   
; Macro Call - fftreald   points,data,outdata,coef,ptr1,ptr2
;   
;    points     number of points (2-32768, power of 2)   
;    data       start of data buffer   
;    outdata    output data buffer   
;    coef    start of sine/cosine table   
;    ptr1    memory location of pointer to input data block 1
;    ptr2    memory location of pointer to input data block 2
;
; Alters Data ALU Registers   
;    x1   x0   y1   y0   
;    a2   a1   a0   a   
;    b2   b1   b0   b   
;   
; Alters Address Registers   
;    r0   n0   m0   
;    r1   n1   m1   
;    r2   n2   m2
;    r3   n3   m3
;    r4   n4   m4   
;    r5   n5   m5   
;    r6   n6   m6   
;    r7   n7   m7
; Alters Program Control Registers   
;    pc   sr   
;   
; Uses 8 locations on System Stack   
;   
_intdata  equ $0    ;internal data space at 0 
;
;Check r7 to see if input buffer is filled
;
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
     move x:ptr2,r2 		;initialize input pointers   
     move #4,n2     		;initial offset for r2
     move r2,r0     		;input pointer for real passes
     move (r2)+n2   		;update external input pointer for complex passes
     move #points/4,n0   	;initialize input and output offsets   
     move #points-1,m0   	;initialize address modifiers for modulo N   
     move r0,r4   			;set up butterfly pointers in and out
     move (r0)+n0  			;
     move r0,r5  			;
     move (r0)+n0  			;
     move r0,r1  			;
     move r4,r0  			;
     move m0,m1  			;modulo N for remaining pointers in and out
     move m0,m4  			;
     move m0,m5  			;
;  
; Do first and second Radix 2 FFT passes: all have real input. First and second
; passes are combined using four-point butterflies.
     move           		y:(r0)+n0,a         ;get ar  
     move           		y:(r0)+n0,y1        ;get br  
     move           		y:(r0)+n0,b         ;get cr  
     add  a,b       		y:(r0)+n0,y0        ;(ar+cr),get dr  
     subl b,a                      			;cr'=(ar-cr)  
     do   n0,_twopass  						;do all four point butterflies
     tfr  y0,a      a,x:(r1)  				;get dr,save cr'  
     sub  y1,a      (r0)+          			;ci'=(dr-br)  
     tfr  y1,a      		a,y:(r1)+ 		;get br,save ci'  
     add  y0,a      		y:(r0)+n0,x1		;(br+dr),get ar  
     add  b,a       		y:(r0)+n0,y1   	;ar'=(ar+cr)+(br+dr),get br  
     subl a,b       		a,y:(r4)+ 		;br'=(ar+cr)-(br+dr),save ar'  
     tfr  x1,a      		b,x0 y:(r0)+n0,b    ;get ar,move br',get cr  
     add  a,b       		y:(r0)+n0,y0   	;(ar+cr),get dr  
     subl b,a       x0,x:(r5)+     			;cr'=(ar-cr),save br'  
_twopass  
;  
; Do next real-input FFT (RFFT) passes. Each RFFT butterfly is a four-point in,
; 3-point out. The fourth point is not computed since it is later obtained by
;using the conjugate symmetry property of the RFFT.
;
     move #points/8,n5        				;spacing, for 1024 spacing=128  
     do   #@cvi(@log(points)/@log(2)-2.5),_next   ;7 passes for 1024 pts  
     move #data,r5                 			;point to data   
     move n5,n0                         		;same offset  
     move r5,r0                         		;ar pointer  
     move (r5)+n5                       		;+1/4  
     move r5,r4                         		;br pointer  
     move (r5)+n5                       		;+1/2  
     move r5,r1                         		;ci pointer  
     move (r5)+n5                       		;+3/4  
     move                	y:(r0)+n0,a   		;get ar  
     move                	y:(r0)-n0,b   		;get br  
     add  a,b                      			;ar'=(ar+br)  
     do   n0,_nextpass  						;do for all p
     subl b,a  x:(r5)+,b 	b,y:(r0)+ 		;br'=(ar-br),get dr,save ar'  
     neg  b    a,x:(r4)+ 	y:(r0)+n0,a    	;ci'=-dr,save br',get ar  
     move b,x0      		y:(r0)-n0,b    	;move ci',get br  
     add  a,b            	x0,y:(r1)+     	;ar'=(ar+br),save ci'  
_nextpass  
     move n5,a                     			;get bflys/pass  
     lsr  a                        			;/2  
     move a1,n5                         		;put back  
_next  
;  
;    special RFFT pass: real input, (4-point). Complex output: stored in normal
;	order, 4-th output stored as complex conjugate of 3rd output.
;    
;  
     move #data,r0                 			;input pointer  
     move #odata,r4                			;output pointer  
     move #points/2,n4  						;output pointer offset
     move #0,m4                         		;bit reverse output  
     move             		y:(r0)+,a    		;get ar  
     move             		y:(r0)+,b    		;get br  
     add  a,b	x:(r0)+,x0 	  				;ar'=ar+br, get cr  
     move      b,x:(r4)+n4     				;save ar'
     subl b,a  x:(r0),b       				;br'=ar-br, get dr
     neg  b    b,y0   		a,x:(r4)+n4		;ci'=-dr, save dr, save br'  
     move      x0,x:(r4)      				;save cr'  
     move             		b,y:(r4)+n4  		;save ci'  
     move      x0,x:(r4)      				;save cr'  
     move              		y0,y:(r4)+n4     	;save cr,ci'*  
; 
;    do first 2-point complex fft with conjugate storage 
;    initialization 
     move      r2,r0          	;r0 points to external data 
     move      #-1,m2         	;linear addr. for external input data pointer 
     move      #4,n2          	;offset for external input data pointer 
     move      #points/8,r3   	;coefficient base offset -->r3 
     move      (r2)+n2        	;update external input data pointer 
     lua       (r0)+,r1       	;initialize input pointer b 
     lua       (r3)+n3,r6     	;initialize twiddle factor pointer 
     move      #points/4,n4   	;offset for output counter a 
     move      r4,n3          	;initialization of conjugate pointer 
     move      #odata+points,r3    ; 
     move      r4,r5               ;initialize output pointer b 
     move      (r3)-n3             ;initialize conjugate pointer 
     move      #odata,n3           ; 
     lua       (r4)+n4,r5          ;initialize output pointer b 
     move      (r3)+n3             ;initialize conjugate pointer 
     move      n4,n5               ;initialize offset for output pointer b 
     move      #0,m4               ;bit-reversed addressing for output ptr a 
     move      (r5)+n5             ;initialize output pointer b 
     move      #0,m5               ;bit-reversed addressing for output ptr b 
     move      #0,m3               ;bit-reversed addressing for conjug. ptr. 
     move      #points/2,n3        ;offset for conjugate pointer 
     move                y:(r0),b  ;initialize butterfly 
     move      (r3)+n3             ;future output pointer a 
     move      r3,ssh              ;save future output pointer a -->stack 
     move      (r3)-n3             ;reinit. conjugate pointer 
;
;    butterfly with conjugate storage    
;
     move           x:(r1),x1 y:(r6),y0  
     mac  x1,y0,b   x:(r6),x0 y:(r1),y1 
     macr -x0,y1,b            y:(r0),a 
     neg  b                   b,y:(r4)        
     move                     b,y:(r3)-n3 
     addl b,a       x:(r0),b   
     neg  a                   a,y:(r5) 
     move                     a,y:(r3)+n3 
     mac  -x1,x0,b  x:(r0),a   
     macr -y1,y0,b   
     subl b,a       b,x:(r4)+n4 
     move           b,x:(r3)-n3 
     move           a,x:(r5)+n5 
     move           a,x:(r3)-n3               
;    end of butterfly 
;
;	initialize pointers for complex fft's
;
     move      #coef,n3  ;initialize coefficient base 
     move      #-1,m3 
     move      m3,m4     ;output pointer a has linear addr. 
     move      m3,m5     ;output pointer b has linear addr. 
     move      ssh,r4    ;initialize next external output pointer a position     
     move      #2,m2     ;initialize butterflies per group 
     move      #1,n4     ;initialize number of passes-1 per FFT 
;
;	do all the complex fft's that are necessary (up to N/4-point)
;
     do   #@cvi(@log(points)/@log(2)-2.5),_end_fft     ;7 for 1024 pt (4- pt....256- pt)  
;
;	initialize pointers in each fft
     move      r4,ssh    ;push output data address onto stack 
     move r2,r0          ;get external data input address for first pass 
     move #points/8,r3   ;update coefficient offset 
     move m2,n1          ;initialize butterflies per group 
     move #1,n2          ;initialize groups per pass 
; 
;	complex fft passes are triple nested do-loops, with last pass split out 
     do   n4,_end_pass   ;do all passes but last in this fft 
;
;	initialize pointers in each pass
     move n4,ssh         ;put number of passes-1 in FFT on stack 
     move #_intdata,r4   ;initialize A output pointer 
     move n1,r5 
     move n1,n0          ;initialize pointer offsets 
     lua  (r5)-,n7 
     move n1,n4 
     move n1,r6 
     lua  (r0)+n0,r1     ;initialize B input pointer 
     lua  (r4)+n4,r5     ;initialize B output pointer 
     lua  (r6)+,n4 
     move n4,n5 
     lua  (r3)+n3,r6     ;initialize W input pointer 
     move n4,n0 
;	
;	initialize butterfly input
     move 		x:(r1),x1 	y:(r6),y0		;lookup -sine value 
     move           			y:(r0),b 		;imag. input a
     mac  x1,y0,b   x:(r6)+n6,x0   y:(r1)+,y1 	;cos., imag. input b
     macr -x0,y1,b            	y:(r0),a       ;
;
;	butterflies
     do   n2,_end_grp						;do for all groups 						
     do   n7,_end_bfy 						;do every butterfly in this group
     subl b,a       x:(r0),b  	b,y:(r4)
     mac  -x1,x0,b  x:(r0)+,a 	a,y:(r5)
     macr -y1,y0,b  x:(r1),x1
     subl b,a       b,x:(r4)+ 	y:(r0),b
     mac  x1,y0,b                  y:(r1)+,y1     ;Radix 2 DIT butterfly kernel
     macr -x0,y1,b  a,x:(r5)+ 	y:(r0),a  	;with constant twiddle factor
_end_bfy             
     move (r1)+n1
     subl b,a       x:(r0),b  	b,y:(r4)
     mac  -x1,x0,b  x:(r0)+n0,a    a,y:(r5)
     macr -y1,y0,b  x:(r1),x1 	y:(r6),y0  	;lookup -sine value
     subl b,a       b,x:(r4)+n4    y:(r0),b
     mac  x1,y0,b   x:(r6)+n6,x0   y:(r1)+,y1
     macr -x0,y1,b  a,x:(r5)+n5    y:(r0),a  	;with constant twiddle factor
_end_grp            
     move n1,b1
     lsr  b    n2,a1     					;divide butterflies per group by two
     lsl  a    b1,n1     					;multiply groups per pass by two
     move      r3,b1
     move      ssh,n4    					;get number of passes-1 back from stack
     lsr  b    a1,n2     					;divide coefficient offset by two
     move      b1,r3
     move      #_intdata,r0   				;intermediate passes use internal input data
_end_pass
;        
; Do last FFT pass and move output data off-chip to external data memory.
; The output data is stored in normal order. At the same time, data is stored for
; the next output block using conjugate properties and a "reverse counter"
;
;	initialize pointers
     move n7,r1
     move ssh,r4
     move (r1)+
     move n4,ssh    				;put #passes-1 in this fft back on stack
     move r1,n0
     move r1,n1    					;correct pointer offset for last pass
     move r1,n4
     move r1,n5
     move #points/4,n4  				;offset for output pointer A 
     lua  (r0)+,r1  				;initialize B input pointer        
     lua  (r4)+n4,r5     			;initialize B output pointer, first step
     move  n4,n5   		  		     ;offset for output pointer B 
     lua  (r3)+n3,r6     			;initialize W input pointer
     move (r5)+n5		        		;initialize B output pointer, second step
     move #0,m4	    	     		;bit-reversed addressing for output pointer A
     move r4,n3 			          ;initialization of conjugate pointer
     move #odata+points,r3			
;
;	initialize butterfly
     move                	y:(r0),b  		;initialization of first butterfly
     move      (r3)-n3        	     		;initialization of conjugate pointer    
     move      #odata,n3           			;
     move      x:(r1),x1 	y:(r6),y0 		;initialization of first butterfly
     move      (r3)+n3             			;initialization of conjugate pointer
     move      #0,m3               			;bit-reversed addressing for conjugate ptr
     move      #points/2,n3        			;correct offset for conjugate pointer
     move      m4,m5               			;bit-reversed addressing for output pointer B     
     move      (r3)+n3
     move      r3,ssh 				          ;put next output ptr a initialization on stack
     move      (r3)-n3             			;reset conjugate pointer
;
;	final butterfly with conjugate reverse storage of next block
     do   n2,_lastpass
     mac  x1,y0,b   x:(r6)+n6,x0   y:(r1)+n1,y1   ;Radix 2 DIT butterfly kernel
     macr -x0,y1,b                 y:(r0),a       ;with one butterfly per group                     
     neg b                         b,y:(r4)       ;and changing twiddle factor
     move                          b,y:(r3)-n3    ;with conjugate storage
     addl b,a  x:(r0),b  
     neg a                         a,y:(r5)
     move                          a,y:(r3)+n3
     mac  -x1,x0,b  x:(r0)+n0,a    
     macr -y1,y0,b  x:(r1),x1      y:(r6),y0
     move           b,x:(r4)+n4
     subl b,a       b,x:(r3)-n3    
     move           a,x:(r5)+n5    y:(r0),b
     move           a,x:(r3)-n3
_lastpass
;
;	update pointers
     move ssh,r4    	;get updated output ptr a from stck for next fft
     move #coef,n3  	;n3 points to coeff. base address again
     move #-1,m3    	;linear addressing for r3 again
     move n6,n2          ;get fft data input offset
     move m2,a           ;initial data offset-->a
     move ssh,r6    	;get #passes in FFT-1 back from stack
     lsl  a              ;initial data offset * 2 -->a
     move #-1,m6    	;r6 increments linearly in next instruction
     move #-1,m2    	;external data pointer uses linear addressing
     lua (r6)+,n4	  	;increment #passes-1 -->n4
     move #0,m6     	;r6 increments bit-reversed again
     move a1,r6     	;new initial data offset-->r6
     lsl a         		;2*#points in this fft -->a
     move a1,n2     	;offset for new external input data
     move m0,m4     	;initialize output pointers again for modulo addr.
     move m0,m5 		;
     move (r2)+n2   	;point to next complex fft input data block
     move      r6,m2     ;new initial data offset for next FFT-->m2
_end_fft
;
;	when fft is finished, jump back to see if data collection for next fft is completed
     jmp  strt           
     endm
;
;
;
     org p:$8
     movep     y:$ffff,y:(r7)+		;data collection upon interrupt
     org p:$100
     move #16,a
     move a,x:$d0					;store pointer to data block 1
     move #80,a
     move a,x:$d1					;store pointer to data block 2
     move #127,m7                		;set r7 for modulo addressing
;
;	call fft macro
     fftreald 64,16,144,210,208,209    

     end                                                                                                                               
