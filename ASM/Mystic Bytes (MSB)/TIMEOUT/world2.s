out	=	0	  	            
	    clr.l	-(sp)
            move.w	#$20,-(sp)
            trap	#1
            addq.l	#6,sp
            
            move.w  #$24,d0
            or.w    #%0001000000,d0
            move.w  d0,-(a7)
            move.w  #3,-(a7)                ;VsetMode option
            pea     $3a0000
            pea     $3a0000
            move.w  #5,-(a7)
            trap    #14
            lea     14(a7),a7
            move.w  d0,mode
wide2        = 384
            move.w 	#%0001,$ffff82c2.w
            move.w 	#20,$ffff8288.w 
            move.w 	#60,$ffff8286.w
            move.w 	#188,$ffff828a.w 
            move.w 	#170-35,$ffff82a8.w            
            move.w 	#550-35+2,$ffff82aa.w
            move.w 	#wide2,$ff8210  
            clr.l 	$ff9800
            
            move.l	#jpeg_pic,d0
	    move.l	#jpeg_pic_len,d1
	    move.l	#pic,d2
	    jsr		jpeg_driver

            
;-------------------------------------------            
            lea 	pic,a0
	    lea 	out_put,a1
	    moveq 	#0,d0
	    move.w 	#256-1,d6
sec 	    move.w 	#256-1,d7
fir 	    move.w 	(a0)+,d0
 	    move.w 	d0,(a1)+
 	    move.w 	d0,(a1)+
            dbf    	d7,fir
            dbf 	d6,sec 
;-------------------------------------------                        
            ;move.l  #bus,8.w
;-------------------------------------------                                    
            lea 	adr_yt-(64*4),a0
            move.l  	#64*(-384*2),d0    
            move.w 	#250-1,d7
doo_adr     move.l 	d0,(a0)+
            add.l 	#wide*2,d0
            dbf 	d7,doo_adr                                 
;-----------------------------------                  
wide        = 384
            move.w 	#%0001,$ffff82c2.w
            move.w 	#20,$ffff8288.w 
            move.w 	#60-5,$ffff8286.w
            move.w 	#188,$ffff828a.w 
            move.w 	#170-35,$ffff82a8.w            
            move.w 	#550-35+2,$ffff82aa.w
            move.w 	#wide,$ff8210  
;------------------------------------ 
;-------------------------------------
           bra 		env_main      
;-------------------------------------     
timer	   dc.w 1        
x_tdd	   ds.w 1
y_tdd	   ds.w 1   
z_tdd	   ds.w 1
ad_xdd	   ds.w 1
ad_ydd	   ds.w 1
ad_zdd	   ds.w 1
sav_sp	   ds.l	1
;---------------------------------
env_main
wait                            
            move.l 	scren_p(pc),a0            
            move.w 	#384*2*99/4/64-1,d7
            move.l 	#$000F000F,d0
clr_scren   rept 	64            
            move.l 	d0,(a0)+ 
            endr
            dbf 	d7,clr_scren
ooo     
;---------------------------------------  
          ;add.w #2,ad_x
          ;add.w #4,ad_y
          ;add.w #2,ad_z
          
          
            subq.w 	#1,timer
 	   bne.b 	back_i
 	   
 	   
 	   move.l	point_cam,a1
 	   move.w 	(a1)+,timer
 	   move.w 	(a1)+,x_tdd
 	   move.w       (a1)+,y_tdd
 	   move.w 	(a1)+,z_tdd
 	   move.w 	(a1)+,ad_xdd
 	   move.w 	(a1)+,ad_ydd
 	   move.w 	(a1)+,ad_zdd 
 	   move.l	a1,point_cam
 	   cmp.l 	#cam_end,a1
 	   blt  	steel
 	   bra  	exit
back_i     	   
 	  move.w y_tdd,d0
          add.w  d0,y_t+2           
          move.w x_tdd,d0
          add.w d0,x_t+2   
          move.w z_tdd,d0
          add.w d0,z_t+2 
                 
          move.w ad_ydd,d0
          add.w  d0,ad_y          
          move.w ad_xdd,d0
          add.w  d0,ad_x           
          move.w ad_zdd,d0
          add.w  d0,ad_z           
          
          move.w y_tdd,d0
          add.w  d0,y_t+2           
          move.w x_tdd,d0
          add.w d0,x_t+2   
          move.w z_tdd,d0
          add.w d0,z_t+2 
                 
          move.w ad_ydd,d0
          add.w  d0,ad_y          
          move.w ad_xdd,d0
          add.w  d0,ad_x           
          move.w ad_zdd,d0
          add.w  d0,ad_z           
          
      
          and.w #$1ff,ad_x
          and.w #$1ff,ad_y 
          and.w #$1ff,ad_z          
 	   
steel 	            
          
;--------------------------------------- 
            move.w #192/2,pop+2
            move.w #100/2,pop2+2
            
            
draw        lea  cos,a3
            lea  sin,a4
            move.l  actual,a6
            move.w #71+1,d7                       
            move.w 4(a6),add_to_z+2
            add.w #8,a6
            lea output__(pc),a5 
            lea zety(pc),a0                                                                                                                             
            move.w ad_x(pc),a1
            move.w ad_y(pc),d6
            move.w ad_z(pc),a2 
loop    
            movem.w (a6)+,d0-d2                 
            
y_t         add.w #0,d1
x_t         add.w #0,d0
z_t         add.w #0,d0
            
os_y        move.w d1,d3
            move.w d2,d4
            muls (a4,d6.w),d3
            muls (a3,d6.w),d4
            sub.l d3,d4
            asr.l #8,d4
            move.w d4,d5
            move.w d1,d3
            move.w d2,d4
            muls (a3,d6.w),d3
            muls (a4,d6.w),d4
            add.l d3,d4
            asr.l #8,d4
            move.w d4,d2
            move.w d5,d1  
os_x        move.w d0,d3
            move.w d2,d4
            muls (a4,a1.w),d3
            muls (a3,a1.w),d4
            sub.l d3,d4
            asr.l #8,d4
            move.w d4,d5
            move.w d0,d3
            move.w d2,d4
            muls (a3,a1.w),d3
            muls (a4,a1.w),d4
            add.l d3,d4
            asr.l #8,d4
            move.w d4,d2 
            move.w d5,d0                 
os_z        move.w d0,d3        
            move.w d1,d4
            muls (a4,a2.w),d3
            muls (a3,a2.w),d4
            sub.l d3,d4
            asr.l #8,d4
            move.w d4,d5
            move.w d0,d3
            move.w d1,d4
            muls (a3,a2.w),d3
            muls (a4,a2.w),d4
            add.l d3,d4
            asr.l #8,d4
            move.w d4,d1
            move.w d5,d0 
        
            move.w d2,(a0)+
add_to_z    add.w #520,d2
            
            ext.l d0                  
            ext.l d1     
            asl.l  #7,d0
            asl.l  #7,d1     
            divs d2,d0
            divs d2,d1 
                
pop         add.w #192/2,d0
pop2        add.w #100/2,d1
                   
            move.w d0,(a5)+
            move.w d1,(a5)+
            
            subq.w #1,d7
            bne loop 
;-----------------------------------------            
licz_sumy   lea zety(pc),a0
            move.w #108-1,d7  
            lea fejsy,a1
            lea to_sort(pc),a2            
            lea output__,a3
            lea kolej,a5
            sub.l a6,a6
            sub.l a4,a4
            
            
sumy_z      move.w (a1),d6
	    movem.w (a3,d6.w*4),d0/d3	    
	    move.w 2(a1),d6
	    movem.w (a3,d6.w*4),d1/d4	    
	    move.w 4(a1),d6
	    movem.w (a3,d6.w*4),d2/d5

            sub.l d1,d2
            sub.l d0,d1
            sub.l d4,d5
            sub.l d3,d4
            muls d1,d5
            muls d4,d2
            sub.l d2,d5
            bmi.b one_less
           
            move.w (a1),d0            
            move.w (a0,d0.w*2),d1                                                
            ;bpl.b  one_less
            move.w 2(a1),d0            
            move.w (a0,d0.w*2),d2                                                
            ;bpl.b  one_less
            move.w 4(a1),d0            
            move.w (a0,d0.w*2),d3
            ;bpl.b  one_less
            add.w d2,d1
            add.w d3,d1                                               
            asr.w #1,d1
            add.w #14000,d1 
            move.w d1,(a2)+
            move.w a6,(a5)+
            addq.l #1,a4
                               
one_less    addq.l #8,a1
            addq.l #1,a6                                    
            dbf d7,sumy_z
            move.w a4,next_nomber
;----------------------------------            
; - - - - - - - - - - - - - - - - - - - - - - - -
i        		equr d0 
j        		equr d1 
e        		equr d2 
xt        		equr d3 
l			equr d4
r			equr d5
; - - - - - - - - - - - - - - - - - - - - - - - -
			;bra  fff
            		lea kolej(pc),a1
            		lea to_sort(pc),a0
                        ;lea safe_end,a2
                        
			moveq 	#0,l
			move.w 	next_nomber,r
			subq.w  #1,r
			move.l  #escape,-(sp)
			
sort			move.w  r,j
			move.w  l,i
                        move.w 	i,e
                      	add.w 	j,e
                      	lsr.w  	e
                      	move.w 	(a0,e.w*2),e
                      	
                      	bra.b	r_01
r_01a                   addq.w  #1,i
r_01 		        cmp.w  	(a0,i.w*2),e
                        bgt.b  	r_01a
                        
                        bra.b  	r_02
r_02a                   tst.w   j
                        beq.b 	r_02
                        subq.w  #1,j                        
r_02 	                cmp.w  	(a0,j.w*2),e
   			blt.b   r_02a

			
r_03			cmp.w 	i,j
 			blt.b 	r_04		
 		        move.w  (a0,i.w*2),xt
 		        move.w  (a0,j.w*2),(a0,i.w*2)
 		        move.w  xt,(a0,j.w*2)
 		        
 		        move.w  (a1,i.w*2),xt
 		        move.w  (a1,j.w*2),(a1,i.w*2)
 		        move.w  xt,(a1,j.w*2)
 		         		         		         		        
 		        addq.w 	#1,i
 		        tst.w 	j
 		        beq.b   r_04 
 		        subq.w 	#1,j
r_04			cmp.w   i,j
 			bge.b	r_01 			
 			cmp.w   l,j 			
 			bls.b   r_05
 			movem.w i/j/r/l,-(sp)
 			move.w  j,r
 			bsr.b   sort		
 			movem.w (sp)+,i/j/r/l
r_05 			cmp.w   i,r
			bls.b 	r_06 			
 			movem.w i/j/r/l,-(sp)
 			move.w  i,l
 			bsr.b   sort		
 			movem.w (sp)+,i/j/r/l
r_06			
                        rts
escape                
            
;----------------------------------            
fff            
            lea     output__(pc),a0
            lea     rot_norms,a4
            lea     zety,a5
            lea     fejsy,a3
            lea     kolej(pc),a2                                                
            move.w  next_nomber,d7                        
            move.w d7,d0
            addq.w #1,d0
            lsl.w d0
            add.w d0,a2 
d_loop    
            move.w -(a2),d6
                    
            lea (a3,d6.w*8),a1       
            
            move.w (a1)+,d6                                       
            movem.w (a0,d6.w*4),d0/d3                                                       
            move.w  (a5,d6.w*2),d6
            cmp.w   #-7000,d6
            blt   nie_rysuj
            
            move.w (a1)+,d6                                     
            movem.w (a0,d6.w*4),d1/d4                                          
            move.w  (a5,d6.w*2),d6
            cmp.w   #-7000,d6
            blt   nie_rysuj
            
                        
            move.w (a1)+,d6                                                          
            movem.w (a0,d6.w*4),d2/d5
            move.w  (a5,d6.w*2),d6
            cmp.w   #-7000,d6
            blt.b   nie_rysuj
            
            lea xt1(pc),a6
            move.w #0,(a6)+
            move.w #255-1,(a6)+
            move.w #0,(a6)+
            move.w #0,(a6)+
            move.w #0,(a6)+
            move.w #255-1,(a6)+
           
                      
dalej_ho_3  
            cmp.w #320,d0
	    bgt.b nie_rysuj
            cmp.w #320,d1
	    bgt.b nie_rysuj
	    cmp.w #320,d2
	    bgt.b nie_rysuj
	    
            cmp.w #-200,d0
	    blt.b nie_rysuj
            cmp.w #-200,d1
	    blt.b nie_rysuj
	    cmp.w #-200,d2
	    blt.b nie_rysuj
	    
            

            move.l d0,x1
            move.l d1,x2
            move.l d2,x3
            move.l d3,y1
            move.l d4,y2
            move.l d5,y3                                                                                                                                     
                              
            movem.l d0-a6,-(sp)                        
            bsr recgo
            movem.l (sp)+,d0-a6                        
nie_rysuj   
            dbf d7,d_loop                          
        
;------------------------------------------                  
            move.l scren_p,d0
            move.l scren_l,scren_p
            move.l d0,scren_l
            lsr.w #8,d0
            move.l d0,$ffff8200.w
    
            cmp.b #1,$ffffffffc02.w
            bne env_main
;------------------------------------------                               
fin                 
exit 
;-------------------------------------
            
            move.w  #$4a,d0
            move.w  d0,-(a7)
            move.w  #3,-(a7)                ;VsetMode option
            pea     $3ca000
            pea     $3ca000
            move.w  #5,-(a7)
            trap    #14
            lea     14(a7),a7
            
            clr.l	-(sp)
            trap	#1                       
;------------------------------------------------           
recgo    
           move.l  x1(pc),d0          
           move.l  y1(pc),d1            
           move.l  x2(pc),d2
           move.l  y2(pc),d3             
           move.l  x3(pc),d4
           move.l  y3(pc),d5
           lea     xt1(pC),a4
           
           cmp.w   d5,d1
           blt.b   w_1            
           exg.l   d0,d4     ;1&3
           exg.l   d1,d5  
            
           move.w  4(a4),d6
           move.w  (a4),4(a4)
           move.w  d6,(a4)
            
           move.w  4+6(a4),d6
           move.w  6(a4),4+6(a4)
           move.w  d6,6(a4)
                                                                                                                               
w_1        cmp.w   d5,d3
           blt.b   w_3            
           exg.l   d2,d4     ;2&3 
           exg.l   d3,d5   
                        
           move.w  4(a4),d6
           move.w  2(a4),4(a4)
           move.w  d6,2(a4)              
            
           move.w  4+6(a4),d6
           move.w  2+6(a4),4+6(a4)
           move.w  d6,2+6(a4)                          
                                                   
w_3        cmp.w   d3,d1
           blt.b   w_2            
           exg.l   d1,d3     ;1&2
           exg.l   d0,d2   
            
           move.w  2+6(a4),d6
           move.w  6(a4),2+6(a4)
           move.w  d6,6(a4)                               
                                    
           move.w  2(a4),d6
           move.w  (a4),2(a4)
           move.w  d6,(a4)                                                                                                                           
w_2        
           cmpi.w  #99,d1
           blt.b   faraway           
back       rts     

faraway    

outside    lea     save_ar(pc),a0
           move.w  d1,(a0)+
           move.w  d3,(a0)+
           move.w  d5,(a0)+
           move.w  d0,(a0)+
           move.w  d2,(a0)+
           move.w  d4,(a0)+
           
           move.l  d2,a3
           move.l  d3,a4
           move.l  d4,a5
           move.l  d5,a6             
;licz przyrost miedzy (x1,y1) a (x2,y2)
           lea     dane(pc),a0
           move.w  d0,d6
           sub.w   d0,d2
           sub.w   d1,d3
           move.w  d3,tem1(a0)
           bne.b   ok_zero_1            
           moveq   #1,d3   
ok_zero_1  swap.w  d2           
           ext.l   d3
           divs.l  d3,d2                                                                
           move.l  d2,tyle+2
           move.w  d3,d7 
;licz przyrost miedzy (x1,y1) a (x3,y3)        
           sub.w   d0,d4
           sub.w   d1,d5
           move.w  d5,tem2(a0)               
           bne.b   ok_zero_2
           moveq   #1,d5                         
ok_zero_2  swap.w  d4
           ext.l   d5           
           divs.l  d5,d4                                      
           move.l  d4,mod10+2
           move.l  d4,mod11+2             
;licz przyrost miedzy (x2,y2) a (x3,y3)                                             
           move.l  a5,d4
           move.l  a6,d5              
           sub.w   a3,d4
           sub.w   a4,d5         
           bne.b   ok_zero_3
           moveq   #1,d5   
ok_zero_3  swap.w  d7           
           move.w  d5,d7
           swap.w  d7                                    
           swap.w  d4 
           ext.l   d5
           divs.l  d5,d4                                            
           move.l  d4,tyle2+2                         
;-----------------------------------------                          
           move.l  scren_p(pc),a6            
           lea     adr_yt,a5                                                                                                       
           tst.w   d1
           bpl.b   y_is_ok 
           moveq   #0,d1    
y_is_ok    add.l   (a5,d1.w*4),a6                                                                                                                                                                                         
           move.l  a0,a4 
           swap.w  d0                      
           move.l  d0,a0
           move.l  d0,a1                                  
           moveq   #0,d0
           moveq   #0,d1          
                    
           move.w  tem1(a4),d3
           move.w  tem2(a4),d4                                                                                
           ext.l   d3
           ext.l   d4
           ***** 
           move.w  xt2(pc),d0
           sub.w   xt1(pc),d0                                                        
           swap.w  d0
           divs.l  d3,d0                        
           move.l  d0,d_x1
           *****      
           move.w  xt3(pc),d0
           sub.w   xt1(pc),d0                                                
           swap.w  d0
           divs.l  d4,d0                        
           move.l  d0,d_x2           
           *****        
           move.w  xt3(pc),d0
           sub.w   xt2(pc),d0                                    
           swap.w  d0            
           divs.l  d5,d0                                             
           move.l  d0,d_x3
           *****       
           move.w  yt2(pc),d0
           sub.w   yt1(pc),d0                                    
           swap.w  d0           
           divs.l  d3,d0                                    
           move.l  d0,d_y1
           *****                    
           move.w  yt3(pc),d0
           sub.w   yt1(pc),d0                                             
           swap.w  d0
           divs.l  d4,d0                       
           move.l  d0,d_y2           
           *****                     
           move.w  yt3(pc),d0
           sub.w   yt2(pc),d0                                  
           swap.w  d0            
           divs.l  d5,d0                        
           move.l  d0,d_y3
           *****                                                                            
;---------------------------------                      
oy1         =      0
oy2         =      2
oy3         =      4
ox1         =      6
ox2         =      8
ox3         =      10 
           moveq   #0,d0
           moveq   #0,d1           
           lea     save_ar(pc),a2 
;-------------------------------------------------------
;          (At-Ct)*(By-Cy) - (Bt-Ct)*(Ay-Cy)
;   du =   ---------------------------------
;          (Ax-Cx)*(By-Cy) - (Bx-Cx)*(Ay-Cy)
;--------------------------------------------------------
	;(At-Ct)*(By-Cy) - (Bt-Ct)*(Ay-Cy)
	   move.w	xt1(pc),d0
	   sub.w	xt3(pc),d0
	   move.w	oy2(a2),d1
	   sub.w	oy3(a2),d1
	   muls		d1,d0	   
	   move.w	xt2(pc),d1
	   sub.w	xt3(pc),d1
	   move.w	oy1(a2),d2
	   sub.w	oy3(a2),d2
	   muls		d2,d1
	   sub.l	d1,d0
	   asl.l	#8,d0	
	;(Ax-Cx)*(By-Cy) - (Bx-Cx)*(Ay-Cy)		
	   move.w	ox1(a2),d1
	   sub.w	ox3(a2),d1
	   move.w	oy2(a2),d2
	   sub.w	oy3(a2),d2
	   muls		d2,d1
	   move.w	ox2(a2),d3
	   sub.w	ox3(a2),d3
	   move.w	oy1(a2),d4
	   sub.w	oy3(a2),d4
	   muls		d4,d3
	   sub.l	d3,d1
           tst.l	d1
           bne.b	no_zero
           moveq	#1,d1
no_zero    move.l	d1,d3
	   divs.l	d1,d0				           
           move.l 	d0,_u3+2
;	_u3+2           
;-----------------------------------------------------------
;calc v
;----------------------------------------------------------            
           ;(At-Ct)*(By-Cy) - (Bt-Ct)*(Ay-Cy)
	   move.w	yt1(pc),d0
	   sub.w	yt3(pc),d0
	   move.w	oy2(a2),d1
	   sub.w	oy3(a2),d1
	   muls		d1,d0	   
	   move.w	yt2(pc),d1
	   sub.w	yt3(pc),d1
	   move.w	oy1(a2),d2
	   sub.w	oy3(a2),d2
	   muls		d2,d1
	   sub.l	d1,d0
	   asl.l	#8,d0	
	;(Ax-Cx)*(By-Cy) - (Bx-Cx)*(Ay-Cy)		
	   divs.l	d3,d0				           
           move.l 	d0,_v3+2          
;	 _v3+2           
;-----------------------------------------------------------            
           ;-----------------------------;
           ;  make lookup table! on DSP! ;
           ;-----------------------------;
	   move.w #192*2-1,d5
	   lea lookup(pc),a3
	   moveq #0,d0
	   moveq #0,d1
	   clr.l	(a3)+
_u3        move.l  #0,d2
_v3        move.l  #0,d6           	   	   
mk_lookup  move.l  d0,d3	   
           lsr.l   #8,d3                                            
           move.l  d1,d4                                                     
           move.b  d3,d4                                
           and.l	#$ffffff,d4
           move.l  d4,(a3)+           
           add.l   d2,d0
           add.l   d6,d1           
           dbf     d5,mk_lookup
           clr.l   (a3)+
;-----------------------------------------------------------                                           
           move.w  xt1(pc),xd1(a4)                    
           move.w  yt1(pc),yd1(a4)                    
           movem.l xd1(a4),d3-d6   
           lea     xd1(a4),a4                                             
           move.l  tyle+2(pc),d0
           cmp.l   mod10+2(pc),d0           
           blt.b   cipa           
           move.l  tyle+2(pc),d0
           move.l  mod10+2(pc),tyle+2
           move.l  d0,mod10+2                                  
           move.l  tyle2+2(pc),d0
           move.l  mod11+2(pc),tyle2+2
           move.l  d0,mod11+2                                             
           move.l  d_x2(pc),d0
           move.l  d_y2(pc),d1                                 
           move.l  d0,mod1+2
           move.l  d1,mod2+2             
           move.l  d0,mod5+2
           move.l  d1,mod6+2             
           bra.b   wporzo                                                             
cipa       move.l  d_x1(pc),mod1+2
           move.l  d_y1(pc),mod2+2
           move.l  d_x3(pc),mod5+2
           move.l  d_y3(pc),mod6+2  
wporzo:
;-----------------------------------------------------------           
           move.w  oy1(a2),d1          ;upper cliping 
           tst.w   d1
           bpl.b   reset_
           neg.w   d1
           bra.b   reset_jump
reset_     moveq   #0,d1     
reset_jump move.w  d1,d4      
;-----------------------------------------------------------
           move.w  oy1(a2),d0         ;buttom cliping
           move.w  oy2(a2),d1 
           move.w  oy3(a2),d2
           moveq   #99,d3           
           cmp.w   d3,d0
           bgt     d_3        
           cmp.w   d3,d1
           blt.b   oops_y3           
           sub.w   d3,d1                       
           sub.w   d1,d7           
oops_y3    cmp.w   d3,d2
           blt.b   dalej_szalej
           sub.w   d3,d2     
           swap.w  d7
           sub.w   d2,d7
           swap.w  d7      
dalej_szalej:
;-----------------------------------------------------------
           
           move.l  #out_put,d6                                          
           move.l  #lookup,d2
           subq.w  #1,d7
           bmi     d_2             
           
half_1     dbf     d4,tyle
           moveq   #0,d4
           
           move.l  a0,d0
           move.l  a1,d1                       
           swap.w  d0
           swap.w  d1                                                                                                                                                                                                                      
           
           cmpi.w  #384/2-1,d1
           blt.b   lucky_one 
           move.w   #384/2-1,d1  
lucky_one  move.l  d2,a5 
           tst.w   d0
           bpl.b   _lucky_1 
           neg.w   d0
           lea     (a5,d0.w*4),a5
           moveq   #0,d0
_lucky_1                        
           sub.w   d0,d1                                     
           bmi.b   inc_it_1
           lea     (a6,d0.w*4),a3                                                                                                                                                 
           move.l  d6,a2 
           swap.w  d3       ;initial u           
           lsr.l   #8,d5    ;initial v                                                               
           move.b  d3,d5  
           lea     (a2,d5.l*4),a2
           moveq   #0,d3
fill       
	   move.l (a5)+,d3                             
	   move.l  (a2,d3.l*4),(a3)+                                                   
           dbf     d1,fill    
           
inc_it_1   add.w   #wide*2,a6                                                                                                                                                                                         
tyle       add.l   #0,a0 
mod10      add.l   #0,a1   
                                
mod1       add.l   #0,(a4)+
mod2       add.l   #0,(a4)                        
           move.l  (a4),d5
           move.l  -(a4),d3
                                                                                                                                                                                           
           dbf     d7,half_1                                                                                                                                                                           
           ;----------------           
           move.w  xt2(pc),xd1(a4)                                  
           move.w  yt2(pc),yd1(a4)
                                            
d_2        swap.w  d7   
           subq.w  #1,d7
           bmi.b   d_3     
                                                                                       
half_2     dbf     d4,tyle2
           moveq   #0,d4
           move.l  a0,d0
           move.l  a1,d1            
           swap.w  d0
           swap.w  d1                                                                                                                                                                                                                    
           
           cmpi.w  #384/2-1,d1
           blt.b   lucky_two
           move.w  #384/2-1,d1  
lucky_two            
           move.l  d2,a5 
           tst.w   d0
           bpl.b   _lucky_2 
           neg.w   d0
           lea     (a5,d0.w*4),a5
           moveq   #0,d0
_lucky_2             
           sub.w   d0,d1                                     
           bmi.b   inc_it_2
           lea     (a6,d0.w*4),a3                                                                                                                                     
           
           move.l  d6,a2 
           swap.w  d3       ;initial u           
           lsr.l   #8,d5    ;initial v           
           move.b  d3,d5                                                             
           lea     (a2,d5.l*4),a2
           moveq   #0,d3
fill2       
	   move.l (a5)+,d3                               
	   move.l  (a2,d3.l*4),(a3)+                                                   
           dbf     d1,fill2
               
inc_it_2   add.w   #wide*2,a6                                                                                                                                                                                        
tyle2      add.l   #0,a0 
mod11      add.l   #0,a1   
                     
mod5       add.l   #0,(a4)+
mod6       add.l   #0,(a4)
           move.l  (a4),d5
           move.l  -(a4),d3                                                                                                                                                                                                               
           
           dbf     d7,half_2                                                                                                                                                                           
d_3        rts 
;-------------------------------------------------------------                          

;-----------------------------------------------------------
dod  dc.l 0
dod1 dc.l 0	
old_vbl dc.l 0
ad_x dc.w 0
ad_y dc.w 0
ad_z dc.w 0
u       ds.l 1
v       dc.l 1
x1      dc.l 350
x2      dc.l 150
x3      dc.l 220
y1      dc.l 59
y2      dc.l 0
y3      dc.l 110
k3      dc.w 0
k2      dc.w 31
k1      dc.w 0
d_x1    dc.l 0
d_x2    dc.l 0
d_x3    dc.l 0
d_y1    dc.l 0
d_y2    dc.l 0
d_y3    dc.l 0
width   dc.w 0
next_nomber dc.w 0
;------------------------------------------
xt1      dc.w 0
xt2      dc.w 128/3
xt3      dc.w 0

yt1      dc.w 0
yt2      dc.w 0
yt3      dc.w 128/3
;------------------------------------------
save_ar  ds.l 32
dane    ds.l 64*2 
rx12    = 0
rx13    = 4
rx23    = 8
ry12    = 12
ry13    = 16
ry23    = 20
x11     = 24
x12     = 28  

xd1     = 32
yd1     = 36  

dx12    = 48
dx13    = 52
dx23    = 56
tem1    = 60
tem2    = 64
tem3    = 68



color   dc.w $ff
scren_p  dc.l $2f0000
scren_l  dc.l $2f0000-256*372 
mode dc.w 0	     
od_m dc.w 0
point  ds.b 1
       even
output__    ds.w 100*6
output__2    ds.w 100*6
;--------------------------------------------------
actual      dc.l box
;--------------------------------------------------             
    EVEN        
fnormals ds.w 256*5
pnormals ds.w 256*5
rot_norms ds.w 256*5
rot_norms2 ds.w 256*5
zety ds.w 256*5    
to_sort ds.w 256*5
kolej ds.w 256*5
        ds.w 1000
lookup  ds.l 640*10
;------------------------------------
  ;Tri-mesh, Vertices: 22     Faces: 40
box     dc.w 72-1
        dc.w 108-1
        dc.w 6700
        dc.w (72-1)*2*3
points        
        dc     -714,-2430,1107
        dc     665,-2430,1107
        dc     645,-2430,-1182
        dc     -704,-2430,-1182
        dc     -714,-3630,1107
        dc     665,-3630,1107
        dc     645,-3630,-1182
        dc     -704,-3630,-1182
        dc     -664,736,1107
        dc     714,736,1107
        dc     694,736,-1181
        dc     -654,736,-1181
        dc     -664,-462,1107
        dc     714,-462,1107
        dc     694,-462,-1181
        dc     -654,-462,-1181
        dc     -4379,-2478,1107
        dc     -2999,-2478,1107
        dc     -3019,-2478,-1180
        dc     -4369,-2478,-1180
        dc     -4379,-3678,1107
        dc     -2999,-3678,1107
        dc     -3019,-3678,-1180
        dc     -4369,-3678,-1180
        dc     -4379,760,1107
        dc     -2999,760,1107
        dc     -3019,760,-1180
        dc     -4369,760,-1180
        dc     -4379,-438,1107
        dc     -2999,-438,1107
        dc     -3019,-438,-1180
        dc     -4369,-438,-1180
        dc     2925,686,1182
        dc     4305,686,1182
        dc     4285,686,-1106
        dc     2935,686,-1106
        dc     2925,-512,1182
        dc     4305,-512,1182
        dc     4285,-512,-1106
        dc     2935,-512,-1106
        dc     2901,-2454,1182
        dc     4281,-2454,1182
        dc     4261,-2454,-1106
        dc     2911,-2454,-1106
        dc     2901,-3654,1182
        dc     4281,-3654,1182
        dc     4261,-3654,-1106
        dc     2911,-3654,-1106
        dc     -4354,3629,1182
        dc     -2974,3629,1182
        dc     -2994,3629,-1106
        dc     -4344,3629,-1106
        dc     -4354,2429,1182
        dc     -2974,2429,1182
        dc     -2994,2429,-1106
        dc     -4344,2429,-1106
        dc     -614,3654,1182
        dc     764,3654,1182
        dc     744,3654,-1106
        dc     -604,3654,-1106
        dc     -614,2454,1182
        dc     764,2454,1182
        dc     744,2454,-1106
        dc     -604,2454,-1106
        dc     3000,3679,1182
        dc     4380,3679,1182
        dc     4360,3679,-1106
        dc     3010,3679,-1106
        dc     3000,2479,1182
        dc     4380,2479,1182
        dc     4360,2479,-1106
        dc     3010,2479,-1106
fejsy

        dc     00001-1,00005-1,00006-1,0
        dc     00001-1,00006-1,00002-1,0
        dc     00002-1,00006-1,00007-1,0
        dc     00002-1,00007-1,00003-1,0
        dc     00003-1,00007-1,00008-1,0
        dc     00003-1,00008-1,00004-1,0
        dc     00004-1,00008-1,00005-1,0
        dc     00004-1,00005-1,00001-1,0
        dc     00001-1,00002-1,00003-1,0
        dc     00005-1,00007-1,00006-1,0
        dc     00001-1,00003-1,00004-1,0
        dc     00005-1,00008-1,00007-1,0
        dc     00009-1,00013-1,00014-1,0
        dc     00009-1,00014-1,00010-1,0
        dc     00010-1,00014-1,00015-1,0
        dc     00010-1,00015-1,00011-1,0
        dc     00011-1,00015-1,00016-1,0
        dc     00011-1,00016-1,00012-1,0
        dc     00012-1,00016-1,00013-1,0
        dc     00012-1,00013-1,00009-1,0
        dc     00009-1,00010-1,00011-1,0
        dc     00013-1,00015-1,00014-1,0
        dc     00009-1,00011-1,00012-1,0
        dc     00013-1,00016-1,00015-1,0
        dc     00017-1,00021-1,00022-1,0
        dc     00017-1,00022-1,00018-1,0
        dc     00018-1,00022-1,00023-1,0
        dc     00018-1,00023-1,00019-1,0
        dc     00019-1,00023-1,00024-1,0
        dc     00019-1,00024-1,00020-1,0
        dc     00020-1,00024-1,00021-1,0
        dc     00020-1,00021-1,00017-1,0
        dc     00017-1,00018-1,00019-1,0
        dc     00021-1,00023-1,00022-1,0
        dc     00017-1,00019-1,00020-1,0
        dc     00021-1,00024-1,00023-1,0
        dc     00025-1,00029-1,00030-1,0
        dc     00025-1,00030-1,00026-1,0
        dc     00026-1,00030-1,00031-1,0
        dc     00026-1,00031-1,00027-1,0
        dc     00027-1,00031-1,00032-1,0
        dc     00027-1,00032-1,00028-1,0
        dc     00028-1,00032-1,00029-1,0
        dc     00028-1,00029-1,00025-1,0
        dc     00025-1,00026-1,00027-1,0
        dc     00029-1,00031-1,00030-1,0
        dc     00025-1,00027-1,00028-1,0
        dc     00029-1,00032-1,00031-1,0
        dc     00033-1,00037-1,00038-1,0
        dc     00033-1,00038-1,00034-1,0
        dc     00034-1,00038-1,00039-1,0
        dc     00034-1,00039-1,00035-1,0
        dc     00035-1,00039-1,00040-1,0
        dc     00035-1,00040-1,00036-1,0
        dc     00036-1,00040-1,00037-1,0
        dc     00036-1,00037-1,00033-1,0
        dc     00033-1,00034-1,00035-1,0
        dc     00037-1,00039-1,00038-1,0
        dc     00033-1,00035-1,00036-1,0
        dc     00037-1,00040-1,00039-1,0
        dc     00041-1,00045-1,00046-1,0
        dc     00041-1,00046-1,00042-1,0
        dc     00042-1,00046-1,00047-1,0
        dc     00042-1,00047-1,00043-1,0
        dc     00043-1,00047-1,00048-1,0
        dc     00043-1,00048-1,00044-1,0
        dc     00044-1,00048-1,00045-1,0
        dc     00044-1,00045-1,00041-1,0
        dc     00041-1,00042-1,00043-1,0
        dc     00045-1,00047-1,00046-1,0
        dc     00041-1,00043-1,00044-1,0
        dc     00045-1,00048-1,00047-1,0
        dc     00049-1,00053-1,00054-1,0
        dc     00049-1,00054-1,00050-1,0
        dc     00050-1,00054-1,00055-1,0
        dc     00050-1,00055-1,00051-1,0
        dc     00051-1,00055-1,00056-1,0
        dc     00051-1,00056-1,00052-1,0
        dc     00052-1,00056-1,00053-1,0
        dc     00052-1,00053-1,00049-1,0
        dc     00049-1,00050-1,00051-1,0
        dc     00053-1,00055-1,00054-1,0
        dc     00049-1,00051-1,00052-1,0
        dc     00053-1,00056-1,00055-1,0
        dc     00057-1,00061-1,00062-1,0
        dc     00057-1,00062-1,00058-1,0
        dc     00058-1,00062-1,00063-1,0
        dc     00058-1,00063-1,00059-1,0
        dc     00059-1,00063-1,00064-1,0
        dc     00059-1,00064-1,00060-1,0
        dc     00060-1,00064-1,00061-1,0
        dc     00060-1,00061-1,00057-1,0
        dc     00057-1,00058-1,00059-1,0
        dc     00061-1,00063-1,00062-1,0
        dc     00057-1,00059-1,00060-1,0
        dc     00061-1,00064-1,00063-1,0
        dc     00065-1,00069-1,00070-1,0
        dc     00065-1,00070-1,00066-1,0
        dc     00066-1,00070-1,00071-1,0
        dc     00066-1,00071-1,00067-1,0
        dc     00067-1,00071-1,00072-1,0
        dc     00067-1,00072-1,00068-1,0
        dc     00068-1,00072-1,00069-1,0
        dc     00068-1,00069-1,00065-1,0
        dc     00065-1,00066-1,00067-1,0
        dc     00069-1,00071-1,00070-1,0
        dc     00065-1,00067-1,00068-1,0
        dc     00069-1,00072-1,00071-1,0       
;---------------------------------------------- 
point_cam	dc.l camera
;
;            timer xd  yd zd ax ay az
;             \/   |  |  |  |  |  |
;
;
camera  
	dc.w 1268,0,0,0,2,0,2
	dc.w 20,0,0,15,0,0,-2
cam_end
;----------------------------------------------
sin:
       dc.w 1,-5,-12,-18,-24,-30,-37,-43
       dc.w -49,-55,-61,-67,-73,-79,-85,-91
       dc.w -97,-103,-108,-114,-120,-125,-131,-136
       dc.w -141,-146,-151,-156,-161,-166,-171,-176
       dc.w -180,-184,-189,-193,-197,-201,-205,-208
       dc.w -212,-215,-219,-222,-225,-228,-230,-233
       dc.w -236,-238,-240,-242,-244,-246,-247,-249
       dc.w -250,-252,-252,-253,-254,-254,-255,-255
       dc.w -255,-255,-255,-254,-254,-253,-252,-251
       dc.w -250,-249,-247,-246,-244,-242,-240,-238
       dc.w -236,-233,-230,-228,-225,-222,-219,-215
       dc.w -212,-208,-205,-201,-197,-193,-189,-184
       dc.w -180,-176,-171,-166,-161,-156,-151,-146
       dc.w -141,-136,-131,-125,-120,-114,-108,-103
       dc.w -97,-91,-85,-79,-73,-67,-61,-61,-55
       dc.w -49,-43,-37,-30,-24,-18,-12,-5
       dc.w 1,6,13,25,31,38,44
       dc.w 50,56,62,68,74,80,86,92
       dc.w 97,103,108,114,120,125,131,136
       dc.w 141,146,151,156,161,166,171,176
       dc.w 180,184,189,193,197,201,205,208
       dc.w 212,215,219,222,225,228,230,233
       dc.w 236,238,240,242,244,246,247,249
       dc.w 250,252,252,253,254,254,255,255
       dc.w 255,255,255,254,254,253,252,251
       dc.w 250,249,247,246,244,242,240,238
       dc.w 236,233,230,228,225,222,219,215
       dc.w 212,208,205,201,197,193,189,184
       dc.w 180,176,171,166,161,156,151,146
       dc.w 141,136,131,125,120,114,108,103
       dc.w 97,91,85,79,73,67,61,61,55
       dc.w 49,43,37,30,24,18,12,5 
       rept 32
       dc.w 1
       endr
       
cos    
       dc.w 256,256,256,255,255,254,253,252
       dc.w 251,250,248,247,245,243,241,239
       dc.w 237,234,231,229,226,223,220,216
       dc.w 213,209,206,202,198,194,190,185
       dc.w 181,177,172,167,162,157,152,147
       dc.w 142,137,132,126,121,115,109,104
       dc.w 98,92,86,80,74,68,62,56
       dc.w 50,44,38,31,25,19,13,6
       dc.w 1,-5,-12,-18,-24,-30,-37,-43
       dc.w -49,-55,-61,-67,-73,-79,-85,-91
       dc.w -97,-103,-108,-114,-120,-125,-131,-136
       dc.w -141,-146,-151,-156,-161,-166,-171,-176
       dc.w -180,-184,-189,-193,-197,-201,-205,-208
       dc.w -212,-215,-219,-222,-225,-228,-230,-233
       dc.w -236,-238,-240,-242,-244,-246,-247,-249
       dc.w -250,-251,-252,-253,-254,-254,-255,-255
       dc.w -255,-255,-255,-254,-254,-253,-252,-251
       dc.w -250,-249,-247,-246,-244,-242,-240,-238
       dc.w -236,-233,-230,-228,-225,-222,-219,-215
       dc.w -212,-208,-205,-201,-197,-193,-189,-184
       dc.w -180,-176,-171,-166,-161,-156,-151,-146
       dc.w -141,-136,-131,-125,-120,-114,-108,-103
       dc.w -97,-91,-85,-79,-73,-67,-61,-55
       dc.w -49,-43,-37,-30,-24,-18,-12,-5
       dc.w 1,6,13,19,25,31,38,44
       dc.w 50,56,62,68,74,80,86,92
       dc.w 98,104,109,115,121,126,132,137
       dc.w 142,147,152,158,162,167,172,177
       dc.w 181,185,190,194,198,202,206,209
       dc.w 213,216,220,223,226,229,231,234
       dc.w 237,239,241,243,245,247,248,250
       dc.w 251,252,253,254,255,256,256,256
       rept 32
       dc.w 256
       endr
       even 
;-----------------------------                  
;tablica  rept 128*3
;         dc.w 0
;         endr      
;_----------------------------
         ds.w 100
adr_yt   ds.l 300*10      
jpeg_driver incbin	f:\jfif.bin
jpeg_pic    incbin	d:\mess3.jpg
jpeg_pic_len 	equ	*-jpeg_pic
mov_sin_1 incbin d:\sinus\v_sin.prg
mov_sin_2 incbin d:\sinus\g_sin.prg       
pic       incbin d:\mess.565

          even   
          section bss
          even
;real_t   ds.b 256*4*128            
green2   ds.w 128*2              
out_put  ds.l 256*256