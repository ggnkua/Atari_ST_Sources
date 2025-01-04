   		output	f:\quast.tos
   		
   		clr.l 	-(sp)
            	move.w 	#$20,-(sp)
            	trap 	#1	            	            	            	
   		
   		move.b		#18,$fffffc02.w	   	
   		
   		lea	msg_1(pc),a0
   		bsr	print

		bra	skipp_inf

msg_1	        dc.b	27,"E"," Searching for sound card...",13,10,0
		even
skipp_inf
		lea	pic,a0
		move.w	#256*256*2/4-1,d7
		moveq	#0,d0
clr_pic		move.l	d0,(a0)+
		dbf	d7,clr_pic		
						            	
;---------------------------------------------------------------------;                                      
		lea 	offs,a0                                                        
            	move.l 	#-320/2,d4
            	moveq 	#-100,d5
            	move.w 	#200-1,d6
bigg_lop    	move.w 	#320-1,d7            
small_lop   	move.l 	d4,d2
            	move.l 	d5,d3                                    
            	muls.l 	d2,d2
            	muls.l 	d3,d3
            	add.l  	d3,d2
            	;----------
        	bsr	sqrt
            	;---------- 
	       	*****************
		cmp.w	#10,d0
		bgt.b	ok_no
		move.w	#$ffff,(a0)+
		bra	ssk
ok_no	    	move.w	d0,d1		;perspective corection...
	    	move.w	d0,d2
	    	asl.l	#7,d0
	    	not.w	d0
	    	divu.l	d1,d0 
	    	lsr.w	#5,d0		;perspective done.
	    	*****************
	    	move.l	d5,d3
	    	;ext.l	d3
	    	asl.l	#6,d3
	    	divs.l	d2,d3
	    	*****************
	    	tst.w	d4
	    	bmi.b	okl
	    	not.b	d3
	    	add.w	#128,d3
okl	    	move.b 	d0,(a0)+            
	    	move.b	d3,(a0)+	
            	;addq.l 	#1,a0            
ssk            	addq.l 	#1,d4
            	dbf 	d7,small_lop	
            	move.l 	#-320/2,d4
            	addq.l 	#1,d5            
            	dbf 	d6,bigg_lop  

		lea 	offs,a0
		lea	offs3,a1
 	    	move.w 	#320*200/2-1,d7
he	    	move.l 	(a0),d0  	               
	    	swap.w 	d0	
	    	move.l 	d0,(a0)+
	    	move.l 	d0,(a1)+
	    	dbf 	d7,he	    
		
		lea	msg_2(pc),a0
		bsr	print

		bra	skipp_inf2

msg_2	        dc.b	" No Gravis found...   ----> Switching to no sound.",13,10
stop	        dc.w	250

skipp_inf2	move.w	#37,-(sp)
		trap	#14
		addq.l	#2,sp
		subq.w	#1,stop
		bne.b	skipp_inf2						
;----------------------------------------------------------------;
            	lea 	sin_addit(pc),a0      ;make full sinus table
            	lea 	sin(pc),a5            ;(the  sin  deltas is stored 
            	lea 	128*2(a5),a1          ; in 4 bit)    
            	lea 	(a1),a2                        
            	lea 	256(a2),a3                              
            	moveq 	#1,d2		              
            	moveq 	#0,d1			      
            	moveq 	#32*2-1,d7   		      
sin_add     	bfextu 	(a0){d1:4},d0	      
            	sub.w  	d0,d2		      
            	move.w 	d2,(a5)+		      
            	move.w 	d2,-(a1)		      
            	neg.w 	d2		              
            	move.w 	d2,(a2)+ 		      	
            	move.w 	d2,-(a3) 		       		
            	neg.w 	d2			      
            	addq.w 	#4,d1		      
            	dbf	d7,sin_add  	      
;---------------------------------------------------------------------;                                      
                lea 	sin(pc),a0                    
            	lea 	wave1(pc),a1                   
            	move.w 	#256-1,d7                  
make_pl_sin 	move.w 	(a0)+,d0                   
            	lsr.w 	#2,d0                          
            	add.b 	#128,d0                     
            	move.b 	d0,(a1)+                   
            	dbf 	d7,make_pl_sin                  
;------------------------------------------------------;  
            	lea   	green2+64*4,a0
            	moveq 	#0,d0
            	moveq 	#0,d4
            	moveq 	#0,d5
            	moveq 	#64-1,d7
green_pal   	move.w 	d4,d1 
            	move.w 	d0,d2
            	move.w 	d0,d3
            	lsl.w  	#5,d1
            	lsl.w  	#8,d2
            	lsl.w  	#3,d2             
            	or.w   	d1,d3
            	or.w   	d2,d3                                    
            	move.w 	d3,(a0)+
            	move.w 	d3,(a0)+
            	addq.w 	#1,d4 
            	not.b  	d5
            	bne.b  	half
            	addq.w 	#1,d0                             
		move.w 	d3,(a0)+
		move.w 	d3,(a0)+
half        	dbf    	d7,green_pal            
		move	#128*2-1,d7
		
cont		move.w	d3,(a0)+
		dbf	d7,cont
	
		lea	blue2+64*5,a0
		moveq	#$1f,d0	
fill		move.w	d0,-(a0)		
		move.w	d0,-(a0)		
		subq.w	#1,d0
		bne.b	fill
	;---------------------------------
		lea   	blue2+64*5,a0
            	moveq 	#0,d0
            	moveq 	#0,d4
            	moveq 	#0,d5
            	moveq 	#64-1,d7
blue_pal   	move.w	d4,d1 
            	move.w 	d0,d2
            	moveq	#$1f,d3
            	lsl.w  	#5,d1
            	lsl.w  	#8,d2
            	lsl.w  	#3,d2             
            	or.w   	d1,d3
            	or.w   	d2,d3                                    
            	move.w 	d3,(a0)+
            	move.w 	d3,(a0)+
            	addq.w 	#1,d4 
            	not.b  	d5
            	bne.b  	half2
            	addq.w 	#1,d0                             
		move.w 	d3,(a0)+
		move.w 	d3,(a0)+
half2        	dbf    	d7,blue_pal            
		moveq	#128-1,d7		
cont2		move.w	d3,(a0)+
		dbf	d7,cont2
		
	;---------------------------------
		lea	red2+64*5,a0
		moveq	#$1f,d0	
fill2		move.w	d0,d1
		lsl.w	#8,d1
		lsl.w	#3,d1
		move.w	d1,-(a0)		
		move.w	d1,-(a0)		
		subq.w	#1,d0
		bne.b	fill2

		lea   	red2+64*5,a0
            	moveq 	#0,d0
            	moveq 	#0,d4
            	moveq 	#0,d5
            	moveq 	#64-1,d7
red_pal   	move.w	d4,d1 
            	moveq 	#$1f,d2
            	move.w	d0,d3
            	lsl.w  	#5,d1
            	lsl.w  	#8,d2
            	lsl.w  	#3,d2             
            	or.w   	d1,d3
            	or.w   	d2,d3                                    
            	move.w 	d3,(a0)+
            	move.w 	d3,(a0)+
            	addq.w 	#1,d4 
            	not.b  	d5
            	bne.b  	half3
            	addq.w 	#1,d0                             
		move.w 	d3,(a0)+
		move.w 	d3,(a0)+
half3        	dbf    	d7,red_pal
		moveq	#128-1,d7		
cont3		move.w	d3,(a0)+
		dbf	d7,cont3
	;---------------------------------
		lea	yel2+64*5,a0
		moveq	#$1f,d0	
fill3		move.w	d0,d1
		lsl.w	#8,d1
		lsl.w	#3,d1
		or.w	d0,d1
		move.w	d1,-(a0)		
		move.w	d1,-(a0)		
		subq.w	#1,d0
		bne.b	fill3

		lea   	yel2+64*5,a0
            	moveq 	#0,d0
            	moveq 	#0,d4
            	moveq 	#0,d5
            	moveq 	#64-1,d7
yel_pal   	move.w	d4,d1 
            	moveq 	#$1f,d2
            	move.w	#$1f,d3
            	lsl.w  	#5,d1
            	lsl.w  	#8,d2
            	lsl.w  	#3,d2             
            	or.w   	d1,d3
            	or.w   	d2,d3                                    
            	move.w 	d3,(a0)+
            	move.w 	d3,(a0)+
            	addq.w 	#1,d4 
            	not.b  	d5
            	bne.b  	half4
            	addq.w 	#1,d0                             
		move.w 	d3,(a0)+
		move.w 	d3,(a0)+
half4       	dbf    	d7,yel_pal
		moveq	#128-1,d7		
cont4		move.w	d3,(a0)+
		dbf	d7,cont4
;----------------------------------------- 
            	lea 	sqr_tab,a0                        
            	moveq 	#-128,d4
            	moveq 	#-128,d5
            	move.w 	#128*2-1,d6
bigg_lop_r    	move.w 	#128*2-1,d7            
small_lop_r   	move.l 	d4,d2
            	move.l 	d5,d3                        
            	muls 	d2,d2
            	muls 	d3,d3
            	add.l 	d3,d2            
            	;----------
        	bsr	sqrt
            	;---------- 
	       	and.w 	#$ff,d0
            	cmp.w 	#63,d0
            	ble.b 	a_kura_r          
            	moveq  	#0,d0    
            	bra 	pluj_r               
a_kura_r      	not.w 	d0
pluj_r        	and.l 	#%111111,d0
            	move.b	d0,(a0)+                                                
            	addq.w 	#1,d4
            	dbf 	d7,small_lop_r
            	moveq 	#-128,d4
            	addq.l 	#1,d5
            	dbf 	d6,bigg_lop_r  

		;move.l	#32*5,light
		lea	line_dup(pc),a0		;textura jest kawalkiem
		lea	pic,a1			;kodu:))))
		moveq	#0,d0
		moveq	#32-1,d6
line_l		moveq	#32-1,d7		
pixe_l		bfextu	(a0){d0:4},d1
		move.b	d1,(a1)		
		move.b	d1,1(a1)		
		move.b	d1,2(a1)		
		move.b	d1,3(a1)		
		move.b	d1,256(a1)		
		move.b	d1,1+256(a1)		
		move.b	d1,2+256(a1)		
		move.b	d1,3+256(a1)		

	        addq.l	#4,a1
		addq.l	#4,d0
		dbf	d7,pixe_l
		add.l	#256*2-32*4,a1
		dbf	d6,line_l
		
		lea	pic,a0
		lea	pic+128,a1
		moveq	#128-1,d7
line_dup	moveq	#128-1,d6
pixel_dup	move.b	(a0)+,(a1)+
		dbf	d6,pixel_dup
		add.l	#128,a0
		add.l	#128,a1
		dbf	d7,line_dup		
		
		lea	pic,a0
		lea	pic+256*64,a1
		move.w	#256*64/4-1,d7
copy_pic2	move.l	(a0)+,(a1)+	
		dbf	d7,copy_pic2		

		lea	pic,a0
		lea	pic+256*128,a1
		move.w	#256*129/4-1,d7
copy_pic3	move.l	(a0)+,(a1)+	
		dbf	d7,copy_pic3		

		bsr	blur2
		bsr	blur2
		bsr	blur2
		
		lea	pic,a0
		lea	pic+256*256,a1
		move.w	#256*256/4-1,d7
copy_pic	move.l	(a0)+,(a1)+	
		dbf	d7,copy_pic		
		
		lea	surf,a4
		moveq	#0,d0
		move.w	#80*2-1,d6
		moveq	#-192/2,d4
		moveq	#30,d5
		move.l	d5,d3
mk_image_y	move.w	#192-1,d7
mk_image_x	move.l	d5,d0		
		move.l	d4,d1
		move.l	d3,d2
		ext.l	d1
		asl.l	#7,d0
		asl.l	#6,d1
		divs	d2,d0
		divs 	d2,d1
		lsl.w	#8,d0
		move.b	d1,d0
	        move.w	d0,(a4)+	
	        addq.w	#1,d4
		dbf	d7,mk_image_x
		addq.l	#1,d5
		addq.l	#2,d3
		moveq	#-192/2,d4
		dbf	d6,mk_image_y

		moveq	#36,d0	            	
            	bsr	set_mode	
		move	d0,mode
					
            	lea	text1(pc),a0
            	bsr	print

		move.l	scren_p(pc),a0
		lea	sc_temp,a1
		move.w	#320*200/4-1,d7
copy_scr	move.l	(a0)+,(a1)+
		dbf	d7,copy_scr		
		
		moveq 	#$64,d0
            	bsr	set_mode
		
		move.w	#%1,$fffff82c2
            	clr.l	$fffff9800.w
;------------------------------------------------------            
yeah		; bra	new6
;--------------------------------------------------------------------					
		lea	sc_temp,a0
		lea	textura+192*28+5(pc),a2
		bsr	convert            	
            	bsr	blur
            	bsr	bump_map
            	
		move.w	#70/2,cnt_1
fx_1		lea 	green2(pC),a1            	
		bsr	bump_1
		subq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_1	
		**************
		move.w	#70/2,cnt_1
fx_2		lea 	green2(pC),a1            	
		bsr	bump_1
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_2		
		move.w	#100/2,cnt_1
fx_3		lea 	green2(pC),a1            	
		bsr	bump_1
		subq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_3
		
		
		lea	sc_temp+320*2*16,a0
		lea	textura+192*40+32(pc),a2		
		bsr	convert2            	
            	bsr	blur
            	bsr	bump_map		
            	clr.l	light
		move.w	#130/2,cnt_1
fx_4		lea 	blue2(pC),a1            	
		bsr	bump_1
		addq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_4
		**************
		move.w	#70/2,cnt_1
fx_5		lea 	blue2(pC),a1            	
		bsr	bump_1
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_5		
		move.w	#150/2,cnt_1
fx_6		lea 	blue2(pC),a1            	
		bsr	bump_1
		subq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_6
;------------------------------------------------------		
		lea	sc_temp+320*2*32,a0
		lea	textura+192*30+30(pc),a2		
		bsr	convert2            	
            	bsr	blur
            	bsr	bump_map		
		move.w	#130/2,cnt_1
fx_7		lea 	red2(pC),a1            	
		bsr	bump_1
		addq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_7
		**************
		move.w	#70/2,cnt_1
fx_8		lea 	red2(pC),a1            	
		bsr	bump_1
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_8		
		move.w	#140/2,cnt_1
fx_9		lea 	red2(pC),a1            	
		bsr	bump_1
		subq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_9
;---------------------------------------------------------		
		lea	sc_temp+320*2*48,a0
		lea	textura+192*30(pc),a2		
		bsr	convert2            	
            	bsr	blur
            	bsr	bump_map		
		move.w	#130/2,cnt_1
fx_10		lea 	yel2(pC),a1            	
		bsr	bump_1
		addq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_10
		**************
		move.w	#70/2,cnt_1
fx_11		lea 	yel2(pC),a1            	
		bsr	bump_1
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_11
		move.w	#110/2,cnt_1
fx_12		lea 	yel2(pC),a1            	
		bsr	bump_1
		subq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_12
;---------------------------------------------------------		
		lea	sc_temp+320*2*64,a0
		lea	textura+192*20(pc),a2		
		bsr	convert
            	bsr	blur
            	bsr	bump_map		
		move.w	#130/2,cnt_1
fx_13		lea 	green2(pC),a1            	
		bsr	bump_1
		addq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_13
		**************
		move.w	#70/2,cnt_1
fx_14		lea 	green2(pC),a1            	
		bsr	bump_1
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_14
		move.w	#120/2,cnt_1
fx_15		lea 	green2(pC),a1            	
		bsr	bump_1
		subq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_15

		clr.l	light

		bsr	clr_me
		lea	textura+192*30(pc),a0
		move.w	#192-1,d7
ll_1		move.b	#$19,(a0)+		
		dbf	d7,ll_1		
		lea	192*30(a0),a0	
		move.w	#192-1,d7
ll_2		move.b	#$19,(a0)+		
		dbf	d7,ll_2	
		lea	192*30(a0),a0		
		move.w	#192-1,d7
ll_3		move.b	#$19,(a0)+		
		dbf	d7,ll_3
		
		lea	textura+32(pc),a0
		move.w	#122*3-1,d7	
ll_4		move.b	#$16,(a0)
		lea	192/3(a0),a0
		dbf	d7,ll_4				
		
		moveq	#192/2-20,d0
		moveq	#60-20+1,d1		
		bsr	cross
		moveq	#11,d0
		moveq	#10,d1		
		bsr	cross
		move.w	#140,d0
		moveq	#10,d1		
		bsr	cross
		moveq	#11,d0
		moveq	#72,d1		
		bsr	cross
		move.w	#140,d0
		moveq	#72,d1		
		bsr	cross
		
		bsr	blur
		bsr	blur
		bsr	bump_map		
;------------------------------------------------
		move.w	#100/2,cnt_1
fx_16		lea 	green2(pC),a1            	
		bsr	bump_2
		addq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_16
		**************
		move.w	#170/2,cnt_1
fx_17		lea 	green2(pC),a1            	
		bsr	bump_2
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_17
		move.w	#125/2,cnt_1
fx_18		lea 	green2(pC),a1            	
		bsr	bump_2
		subq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_18
;------------------------------------------------------------------
;------------                    ----------------------------------
;------------------------------------------------------------------
new		move.l	#32*5,light		
		
		move.w	#50/2,cnt_1
fx_19		lea 	green2(pC),a4
		bsr	tunel
		addq.l	#4,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_19
		**************
		move.w	#170/2,cnt_1
fx_20		lea 	green2(pC),a4            	
		bsr	tunel
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_20
		move.w	#60/2,cnt_1
fx_21		lea 	green2(pC),a4            	
		bsr	tunel
		subq.l	#4,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_21				
;---------------------------------------------------------------------------------
;---------------
;---------------------------------------------------------------------------------
new2		move.l	#64,light
		
		**********************
		lea	wave2(pc),a0
		move.l	a0,a1
		move.l	a0,a3
		lea	wave2(pc),a0
		lea	map,a2
		lea	map+256*256,a4
		move.w	#256-1,d6
map_y		move.w	#256-1,d7
map_x		moveq	#0,d1
		moveq	#0,d0
		move.b	(a0),d0
		move.b	(a3)+,d1
		add.w	d1,d0
		lsr.w	#2,d0
		move.b	d0,(a2)+
		move.b	d0,(a4)+
		dbf	d7,map_x
		move.l	a1,a3
		addq.l	#1,a0
		dbf	d6,map_y
		**********************
		move.w	#150/4/2,cnt_1
fx_23		lea 	blue2(pC),a6
		bsr	scape
		add.l	#4*4*2,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_23
		**************
		move.w	#190/2,cnt_1
fx_24		lea 	blue2(pC),a6
		bsr	scape
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_24
		move.w	#150/4-20/2,cnt_1
fx_25		lea 	blue2(pC),a6
		bsr	scape
		sub.l	#16*2,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_25
		************************
new3		move.l	#32*5,light		
		lea		offs,a0
	    	lea		offs+64,a1
	    	move.w	#320*200-1,d7
do_iot      	move.w	(a0),d0
	    	add.w	(a1)+,d0
	    	move.w	d0,(a0)+
	    	dbf		d7,do_iot
		************************
		lea	offs+320*2*(100-10)+115*2,a0
		moveq	#21-1,d6
fix_line_	moveq	#30-1,d7
fix_pixe_	move.l	#$ffffffff,(a0)+
		dbf	d7,fix_pixe_
		add.l	#320*2-30*4,a0
		dbf	d6,fix_line_		
		************************
		move.w	#100/2,cnt_1
fx_26		lea 	green2(pC),a4
		bsr	tunel
		addq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_26		
		move.w	#170/2,cnt_1
fx_27		lea 	green2(pC),a4            	
		bsr	tunel
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_27
		move.w	#100/2,cnt_1
fx_28		lea 	green2(pC),a4
		bsr	tunel
		subq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_28
;------------------------------------------------------------------------
new4		
		bsr	wave_me
		lea	textura,a0
		lea	dist,a1
		move.w	#192*120-1,d7
mk_dist_offs	moveq	#0,d0
		move.b	(a0),d0
		move.l	d0,d1
		lsr.w	#2,d0
		lsr.w	#2,d1
		mulu	#256*2,d1
		lsl.l	d0
		sub.w	d0,d1
		move.w	d1,(a1)+
		addq.l	#1,a0
		dbf	d7,mk_dist_offs
		bsr	bump_map2
		**********************
		clr.l	light
		move.w	#130/2,cnt_1
fx_29		lea 	blue2(pC),a1
		bsr	bump_3
		addq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_29
		move.w	#120/2,cnt_1
fx_30		lea 	blue2(pC),a1            	
		bsr	bump_3
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_30
		move.w	#140/2,cnt_1
fx_31		lea 	blue2(pC),a1            	
		bsr	bump_3
		subq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_31
		****************		
		lea	textura,a0
		lea	dist,a1
		move.w	#192*120-1,d7
mk_dist_offs2	moveq	#0,d0
		move.b	(a0),d0
		move.l	d0,d1
		lsr.w	#2,d0
		lsr.w	#3,d1
		mulu	#320*2,d1
		lsl.l	#2,d0
		sub.w	d0,d1
		move.w	d1,(a1)+
		addq.l	#1,a0
		dbf	d7,mk_dist_offs2
		*****************
		move.l	#32*5,light		
		move.w	#50/2,cnt_1
fx_32		lea 	green2(pC),a4
		bsr	tunel2
		addq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_32
		move.w	#230/2,cnt_1
fx_33		lea 	green2(pC),a4            	
		bsr	tunel2
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_33
		move.w	#50/2,cnt_1
fx_34		lea 	green2(pC),a4
		bsr	tunel2
		subq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_34
		*************************
		move.l	#32*5,light		
		move.w	#50/2,cnt_1
fx_35		lea 	yel2(pC),a4
		bsr	surface
		addq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_35
		move.w	#230/2,cnt_1
fx_36		lea 	yel2(pC),a4            	
		bsr	surface
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_36
		move.w	#50/2,cnt_1
fx_37		lea 	yel2(pC),a4
		bsr	surface
		subq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_37
		************************
new5		
		bsr	wave_me
		lea	textura,a0
		lea	dist,a1
		move.w	#192*120-1,d7
mk_dist_offs3	moveq	#0,d0
		move.b	(a0),d0
		move.l	d0,d1
		lsr.w	#1,d0
		lsr.w	#1,d1
		mulu	#256,d1
		sub.w	d0,d1
		move.w	d1,(a1)+
		addq.l	#1,a0
		dbf	d7,mk_dist_offs3
		*****************
		move.l	#32*5,light		
		move.w	#70/2,cnt_1
fx_38		lea 	yel2(pC),a4
		bsr	scrol
		addq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_38
		move.w	#230/2,cnt_1
fx_39		lea 	yel2(pC),a4            	
		bsr	scrol
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_39
		move.w	#90/2,cnt_1
fx_40		lea 	yel2(pC),a4
		bsr	scrol
		subq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_40
		
;--------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;
;--------------------------------------------------------------
new6		move.l	#32*5,light		
		move.w	#50/2/2,cnt_1
fx_41		lea 	green2(pC),a4
		bsr	tunel3
		addq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_41
		move.w	#230/2,cnt_1
fx_42		lea 	green2(pC),a4            	
		bsr	tunel3
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_42
		move.w	#50/2+10/2,cnt_1
fx_43		lea 	green2(pC),a4
		bsr	tunel3
		subq.l	#8,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_43
		bra	skip
;--------------------------------------------------------------
BBB		move.l 	scren_p,d0
	        move.l 	scren_l,scren_p
            	move.l 	d0,scren_l
            	lsr.w 	#8,d0
            	move.l 	d0,$ffff8200.w                               
            	cmp.b 	#1,$ffffffc02.w
            	beq 	skip
            	rts            	
;--------------------------------------------------------------                        
skip            move.w  #$4a,d0
		bsr	set_mode
             	move.b	#8,$fffffc02.w	   	
             	clr.l -(sp)
             	trap #1
;--------------------------------------------------------------                        
set_mode             	
            	move.w  d0,-(a7)
            	move.w  #3,-(a7)                ;VsetMode option
            	pea     $3a0000
	        pea     $3a0000
            	move.w  #5,-(a7)
            	trap    #14
            	lea     14(a7),a7
             	rts
;--------------------------------------------------------------                                     	
print		move.l	a0,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		rts
;--------------------------------------------------------------                                     	
convert		
		bsr	clr_me
		
		moveq	#8*2-1,d2
		move.l	#$19191919,d5
y_scan		move	#8*6-1,d1	
x_scan		move.w	(a0)+,d0
		bne.b	dd
		move.l	d5,(a2)
		move.l	d5,192(a2)
		move.l	d5,192*2(a2)
		move.l	d5,192*3(a2)
dd		addq.l	#4,a2
		dbf	d1,x_scan
		add.l	#320*2-8*6*2,a0
		add.l	#192*4-8*6*4,a2
		dbf	d2,y_scan
		rts
convert2	
		bsr.b	clr_me
		moveq	#8*2-1,d2
		move.w	#$1919,d5
y_scan2		move	#8*12-1,d1	
x_scan2		move.w	(a0)+,d0
		bne.b	dd2
		move.w	d5,(a2)
		move.w	d5,192(a2)
		move.w	d5,192*2(a2)
		move.w	d5,192*3(a2)
dd2		addq.l	#2,a2
		dbf	d1,x_scan2
		add.l	#320*2-8*12*2,a0
		add.l	#192*4-8*12*2,a2
		dbf	d2,y_scan2
		rts
clr_me		lea	textura(pc),a3
		moveq	#0,d0
		move.w	#192*122/4-1,d7
clr_tex2	move.l	d0,(a3)+	
		dbf	d7,clr_tex2		
		rts	
;--------------------------------------------------------------                                     	
blur		lea	textura(pc),a0
		move.w	#192*120-1,d7
blur_high       move.b	(a0),d0
		add.b	-1-192(a0),d0
		add.b	   192(a0),d0
		add.b	-192+1(a0),d0
		add.b	    -1(a0),d0
		lsr.b		#2,d0
		add.b	     1(a0),d0
		add.b	 192-1(a0),d0
		add.b	   192(a0),d0
		add.b	 192+1(a0),d0
		lsr.b		#2,d0
		move.b	     d0,(a0)+
		dbf      d7,blur_high
		rts
blur2		lea	pic,a0
		move.w	#256*256-1,d7
blur_high2       move.b	(a0),d0
		add.b	-1-256(a0),d0
		add.b	   256(a0),d0
		add.b	-256+1(a0),d0
		add.b	    -1(a0),d0
		lsr.b		#2,d0
		add.b	     1(a0),d0
		add.b	 256-1(a0),d0
		add.b	   256(a0),d0
		add.b	 256+1(a0),d0
		lsr.b		#2,d0
		move.b	     d0,(a0)+
		dbf      d7,blur_high2
		rts
;--------------------------------------------------------------                                     	
bump_1		bsr	bump_set
            	;-----------------------
		move.l	scren_p(pc),a0		
		move.w	#192*120-1,d7
		lea	st,a2
		lea	sqr_tab+256*128+128,a5
            	add.l	light(pc),a1
            	
		moveq	#0,d5
		moveq	#0,d0
		move.w 	lx(pc),d0            
            	move.w 	ly(pc),d5        
            	lsl.w  	#8,d0
            	move.b 	d5,d0
		ext.l	d0
            	sub.l  	d0,a5            
		;---------------
		moveq	#0,d0
		moveq	#0,d1
draw		
		move.w	(a2)+,d2				
		move.b	(a5,d2.w),d1
		move.l	(a1,d1.w*4),(a0)+
		;move.w	d1,(a0)+	
		;move.w	d1,(a0)+	
		dbf	d7,draw		
		;-----------------
             	rts
;-----------------------------------------------------             	
bump_2		bsr	bump_set
            	;-----------------------
		move.l	scren_p(pc),a0		
		move.w	#192*120-1,d7
		lea	st,a2
		lea	sqr_tab+256*128+128,a5
		move.l	a5,a6
            	add.l	light(pc),a1
            	
		moveq	#0,d5
		moveq	#0,d0
		move.w 	lx(pc),d0            
            	move.w 	ly(pc),d5        
            	lsl.w  	#8,d0
            	move.b 	d5,d0
		ext.l	d0
            	sub.l  	d0,a5            
            	
            	moveq	#0,d5
		moveq	#0,d0
		move.w 	lx2(pc),d0            
            	move.w 	ly2(pc),d5        
            	lsl.w  	#7,d0
            	move.b 	d5,d0
		ext.l	d0
            	sub.l  	d0,a6            
		;---------------
		moveq	#0,d0
		moveq	#0,d1
draw2		
		move.w	(a2)+,d2				
		move.b	(a5,d2.w),d1
		add.b	(a6,d2.w),d1		
		move.l	(a1,d1.w*4),(a0)+
		;move.w	d1,(a0)+	
		;move.w	d1,(a0)+	
		dbf	d7,draw2		
		;-----------------
             	rts             	
;--------------------------------------------------------------                                     	
bump_3		bsr	bump_set
            	;-----------------------
		move.l	scren_p(pc),a0		
		lea	st2+32,a2
		lea	sqr_tab+256*128+128,a5
            	lea	dist,a6
            	add.l	light(pc),a1
            	
            	moveq	#0,d0
            	move.l	d0,d1
            	move.w	lx,d0
            	lsr.w	#1,d0
            	move.w	ly,d1
		lsl.w	d1
            	sub.w	#30,d1
            	mulu	#256,d1
		add.l	d1,d0
            	lsl.w	d0
            	add.l	d0,a2
            	
		moveq	#0,d5
		moveq	#0,d0
		move.w 	lx(pc),d0            
            	move.w 	ly(pc),d5        
            	lsl.w  	#8,d0
            	move.b 	d5,d0
		ext.l	d0
            	sub.l  	d0,a5            
		;---------------
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d3
		moveq	#120-1,d6
line_d_3	
		move.w	#192-1,d7		
draw3		
		move.w	(a6)+,d3
		move.w	(a2,d3.w),d2		
		move.b	(a5,d2.w),d1
		move.l	(a1,d1.w*4),(a0)+
		addq.l	#2,a2
		dbf	d7,draw3	
		add.l	#256*2-192*2,a2
		dbf	d6,line_d_3	
		;-----------------
             	rts
;--------------------------------------------             	
bump_set	moveq 	#0,d0
            	lea 	wave1(pc),a2           
		lea	wave2+2(pc),a6
            	move.b 	steper(pc),d0
	        moveq 	#0,d1
            	move.b 	(a2,d0.w),d1           
            	lsr.b 	#2,d1            
            	and.w 	#$ff,d1
            	move.w 	d1,ly                         
            	moveq 	#0,d1
            	move.b 	steper2(pc),d0
            	move.b 	(a6,d0.w),d1           
            	lsr.b 	#2,d1
		add.w	#40,d1
            	move.w 	d1,lx

		move.b 	steper3(pc),d0
	        moveq 	#0,d1
            	move.b 	(a2,d0.w),d1           
            	lsr.b 	#2,d1            
            	and.w 	#$ff,d1
            	move.w 	d1,ly2                         
            	moveq 	#0,d1
            	move.b 	steper4(pc),d0
            	move.b 	(a2,d0.w),d1           
            	lsr.b 	#2,d1
		add.w	#20,d1
            	move.w 	d1,lx2


            	addq.b	#2,steper
            	addq.b	#4,steper2             	
            	addq.b	#4,steper3
            	addq.b	#8,steper4             	
            	rts
;--------------------------------------------------------------                        
bump_map	lea 	textura+192(pc),a0
            	lea 	st,a1
            	moveq.w #0,d0
            	moveq.w #0,d1
            	move.w 	#120-1,d6
big_t       	move.w 	#192-1,d7
samll_e     	move.w 	d0,d3
            	move.w 	d1,d4 
            	move.b 	-2(a0),d2
            	sub.b 	2(a0),d2
            	add.w 	d2,d3
            	moveq	#0,d2
            	move.b 	-192(a0),d2
            	sub.b 	192(a0),d2 
            	add.w 	d2,d4            
            	move.b 	d3,(a1)+            
            	move.b 	d4,(a1)+            
		not.b	ss2
		bne.b	nno2
            	addq.w 	#1,d0
nno2            addq.l 	#1,a0
            	dbf 	d7,samll_e
            	moveq	#0,d0
		not.b	ss
		bne.b	nno
            	addq.w 	#1,d1
nno            	dbf 	d6,big_t            
		rts
ss		ds.b	1		
ss2		ds.b	1		
;-----------------------------------------------------
bump_map2	lea 	pic+256,a0
            	lea 	st2,a1
            	moveq.w #0,d0
            	moveq.w #0,d1
            	move.w 	#256-1,d6
big_tr       	move.w 	#256-1,d7
samll_er     	move.w 	d0,d3
            	move.w 	d1,d4 
            	move.b 	-2(a0),d2
            	sub.b 	2(a0),d2
            	add.w 	d2,d3
            	moveq	#0,d2
            	move.b 	-256(a0),d2
            	sub.b 	256(a0),d2 
            	add.w 	d2,d4            
            	move.b 	d3,(a1)+            
            	move.b 	d4,(a1)+            
		not.b	ss2
		bne.b	nno2r
            	addq.w 	#1,d0
nno2r           addq.l 	#1,a0
            	dbf 	d7,samll_er
            	moveq	#0,d0
		not.b	ss
		bne.b	nnor
            	addq.w 	#1,d1
nnor           	dbf 	d6,big_tr            
		rts
;--------------------------------------------------------------                        
cross		
		lea	textura(pc),a0
		mulu	#192,d1
		add.w	d0,d1
		lea	(a0,d1.w),a1
		add.l	#192*10,a1		
		moveq	#20-1,d7
y_cross		moveq	#40-1,d6
x_cross		move.b	#$17,(a1)+
		dbf	d6,x_cross
		add.l	#192-40,a1
		dbf	d7,y_cross		
		lea	10(a0,d1.w),a0		
		moveq	#40-1,d7
y_crosse	moveq	#20-1,d6
x_crosse	move.b	#$17,(a0)+
		dbf	d6,x_crosse
		add.l	#192-20,a0
		dbf	d7,y_crosse		
		rts
;---------------------------------------------------		
tunel	    	bsr		bump_set
	    	lea    		offs,a1
	    	bsr		setup_t	    		    	
	    	**************************
	    	moveq   	#120-1,d6	    
line	    	move.w  	#192/2-1,d7
mk_tunn     	 
	    	moveq	#0,d2
            	move.l 	(a1)+,d0
 	    	move.b 	(a2,d0.w),d2
 	    	lsr.w	#8,d0
	    	lsr.w	d0
 	    	sub.w	d0,d2
 	    	move.l	(a4,d2.w*4),(a0)+
 	    	swap.w 	d0
 	    	moveq	#0,d2
 	    	move.b 	(a2,d0.w),d2
 	    	lsr.w	#8,d0
 	    	lsr.w	d0
 	    	sub.w	d0,d2
 	    	move.l	(a4,d2.w*4),(a0)+ 	    
 	    	dbf 	d7,mk_tunn 
 	    	add.l 	a3,a1       
 	    	dbf 	d6,line 
good_end 	add.l 	#256*3+1,aaa
            	and.l 	#$ffff,aaa
 	    	rts
setup_t
		add.l	light,a4
	    	move.l 	scren_p(pc),a0
	    	lea    	pic+256*128,a2
	    	move.l 	aaa(pc),d0
	    	add.l  	d0,a2
	    	moveq 	#0,d0
	    	move.l  	#320*2-192*2,a3	    
	    	moveq  	#0,d1
	    	moveq  	#0,d2
	    	move.w 	ly(pc),d1
	    	mulu   	#320*2,d1
	    	move.w 	lx(pc),d2	    
	    	lsr.w	#1,d2
	    	lsl.w  	#2,d2
	    	add.w  	d2,d1
	    	lea    	(a1,d1.l),a1		
	    	rts
;----------------------------------------------------------
surface	    	bsr		bump_set
	    	add.l	light,a4
	    	move.l 	scren_p(pc),a0
	    	lea    	surf,a1
	    	moveq	#0,d0
	    	move.w	ly,d0
	    	lsr.w	d0
	    	mulu	#192*2,d0
	    	add.l	d0,a1
	    	lea    	pic+256*128+128,a2
	    	move.l 	aaa(pc),d0
	    	add.l  	d0,a2
	    	moveq 	#0,d0
	    	**************************
	    	move.w  #192/2*120-1,d7
line_sur    	
	    	moveq	#0,d2
            	move.w 	(a1)+,d0
 	    	move.b 	(a2,d0.w),d2
 	    	lsr.w	#8,d0
	    	lsr.w	d0
 	    	sub.w	d0,d2
 	    	move.l	(a4,d2.w*4),(a0)+
            	move.w 	(a1)+,d0 	    
 	    	moveq	#0,d2
 	    	move.b 	(a2,d0.w),d2
 	    	lsr.w	#8,d0
 	    	lsr.w	d0
 	    	sub.w	d0,d2
 	    	move.l	(a4,d2.w*4),(a0)+ 	    
 	    	dbf 	d7,line_sur
		bra	good_end
 	    	rts 	    	
;----------------------------------------------------
scrol		bsr		bump_set
	    	add.l	light,a4
	    	move.l 	scren_p(pc),a0
	    	lea    	dist,a1
	    	lea    	pic,a2	    	
	    	add.l 	aaa(pc),a2
	    	lea	textura,a3
	    	moveq 	#0,d3
	    	**************************
		moveq	#120-1,d6
line_rrrr
	    	move.w  #192-1,d7
line_scr    	
	    	moveq	#0,d2
            	move.w 	(a1)+,d0
 	    	move.b 	(a2,d0.w),d2
 	    	moveq	#0,d0
 	    	move.b	(a3)+,d3
	    	lsr.w	d3
 	    	sub.w	d3,d2 	    	
 	    	move.l	(a4,d2.w*4),(a0)+
 	    	addq.l	#1,a2
 	    	dbf 	d7,line_scr
 	    	add.l	#256-192,a2
 	    	dbf	d6,line_rrrr

		bra	good_end
 	    	rts 	    			
;----------------------------------------------------
tunel2	    	bsr		bump_set
	        add.l	light,a4
	    	move.l 	scren_p(pc),a0
	    	lea    	offs+64,a1
	    	lea    	pic+256*128,a2
	    	lea	dist,a5
	    	move.w	lx,d0
	    	lsr.w	d0
	    	lea	(a5,d0.w*2),a5
	    	move.l 	aaa(pc),d0
	    	add.l  	d0,a2
	    	moveq 	#0,d0
	    	move.l  	#320*2-192*2,a3	    
	    	moveq  	#0,d1
	    	moveq  	#0,d2
	    	move.w 	ly(pc),d1
	    	mulu   	#320*2,d1
	    	move.w 	lx(pc),d2	    
	    	lsr.w	#1,d2
	    	lsl.w  	#2,d2
	    	add.w  	d2,d1
	    	lea    	(a1,d1.l),a1		
	    	**************************
	    	moveq   	#120-1,d6	    
linet	    	move.w  	#192/2-1,d7
mk_tunnt     	moveq	#0,d2
	    	move.w	(a5)+,d3
            	move.l	(a1,d3.w),d0
 	    	move.b 	(a2,d0.w),d2
 	    	lsr.w	#8,d0
	    	lsr.w	d0
 	    	sub.w	d0,d2
 	    	move.l	(a4,d2.w*4),(a0)+ 	   	
 	    	swap.w	d0
 	    	moveq	#0,d2
 	    	move.b 	(a2,d0.w),d2
 	    	lsr.w	#8,d0
 	    	lsr.w	d0
 	    	sub.w	d0,d2
 	    	move.l	(a4,d2.w*4),(a0)+ 	     	    	
 	    	addq.l	#4,a1
 	    	dbf 	d7,mk_tunnt 
 	    	add.l 	a3,a1       
 	    	add.l	#192,a5
 	    	dbf 	d6,linet 
		bra	good_end
;-----------------------------------------------
tunel3	    	bsr		bump_set
	    	lea		offs3,a1
	    	bsr		setup_t
	    	lea		offs3,a5
	        **************************
	    	move.w 	ly(pc),d1
	    	mulu   	#320*2,d1
	    	move.w 	lx(pc),d2	    
	    	not.b	d2
	    	sub.w	#90,d2
	    	lsr.w	#1,d2
	    	lsl.w  	#2,d2
	    	add.w  	d2,d1
	    	lea    	(a5,d1.l),a5			    		    
	    	**************************
	    	moveq   	#120-1,d6	    
linetr	    	move.w  	#192/2-1,d7
mk_tunntr     	 
	    	moveq	#0,d2
            	moveq	#0,d4
            	************************
            	move.l 	(a1)+,d0
 	    	move.b 	(a2,d0.w),d2
 	    	lsr.w	#8,d0
	    	lsr.w	d0
 	    	sub.w	d0,d2
 	    	
 	    	move.l 	(a5)+,d3
 	    	move.b 	(a2,d3.w),d4
 	    	lsr.w	#8,d3
	    	lsr.w	d3
 	    	sub.w	d3,d4
 	    	 	    	 	    	 	    	
 	    	move.l	(a4,d2.w*4),d5
 	    	add.l	(a4,d4.w*4),d5
 	    	move.l	d5,(a0)+
 	    	
 	    	************************
 	    	moveq	#0,d2
            	moveq	#0,d4
 	    	swap.w	d0
 	    	move.b 	(a2,d0.w),d2
 	    	lsr.w	#8,d0
	    	lsr.w	d0
 	    	sub.w	d0,d2
 	    	
 	    	swap.w	d3
 	    	move.b 	(a2,d3.w),d4
 	    	lsr.w	#8,d3
	    	lsr.w	d3
 	    	sub.w	d3,d4
 	    	 	    	 	    	 	    	
 	    	move.l	(a4,d2.w*4),d5
 	    	add.l	(a4,d4.w*4),d5
 	    	move.l	d5,(a0)+
 	    	
 	        ************************
 	    	
 	    	
 	    	dbf 	d7,mk_tunntr
 	    	add.l 	a3,a1       
 	    	add.l	a3,a5
 	    	dbf 	d6,linetr 
		bra	good_end
;------------------------------------------------------
sqrt 	    	moveq.l 	#0,d0         
            	move.l  	#$40000000,d1 
sqrtLP1:    	move.l 	d2,d3          
            	sub.l 	d1,d3           
            	blt.b 	sqrtLP2         
            	sub.l 	d0,d3           
	        blt.b 	sqrtLP2         
            	move.l 	d3,d2          
            	lsr.l 	d0              
            	or.l 	d1,d0            
            	lsr.l 	#2,d1           
            	bne.b 	sqrtLP1                            
            	bra.b 	out_1                 
sqrtLP2:    	lsr.l 	d0              
            	lsr.l 	#2,d1           
            	bne.b 	sqrtLP1             
            	;---------- 
out_1      	rts
;--------------------------------------------------------------                        
scape		move.l	scren_p,a0
		move.w	#384*2*120/4/32-1,d7
		moveq	#0,d0
clr_sc		rept	32
		move.l	d0,(a0)+
		endr
		dbf	d7,clr_sc		

		lea	pic+256*128+128,a3
		lea	surf+192*2+(192*2*150)+2,a4
		lea	map+256*128+128,a5
		add.l	light,a6
		move.l	bbb2,d0
		add.l	d0,a3
		add.l	d0,a5
		move.l	scren_p(pc),a0		
		add.l	#192*4*225,a0
		move.l	a0,a2
		move.l	#-192*4,d6
		move.l	#192*4,d4
		
		move	#150-1,d5
scape_l			
		move.w	#192-1,d7
draw_sc			
		move.w	-(a4),d0		
		moveq	#0,d1	
		move.b	(a5,d0.w),d1
		move.b	(a3,d0.w),d0
		move.w	d1,d3
		muls	#-192*4,d3
		lea	(a0,d3.l),a1
		tst.l	(a1)
		bne.b	ab		
		and.w	#$ff,d0
		move.l	(a6,d0.w*4),d0
		bne.b	pasek
		bset	#0,d0
		
pasek		
		move.l  d0,(a1)		
		add.l	d4,a1
		tst.l	(a1)
		dbne	d1,pasek			
ab		
		subq.l	#4,a0
		dbf	d7,draw_sc
		exg.l	a0,a2
		subq.l	#4,a6
		dbf	d5,scape_l
		add.l	#256*3,bbb2
		and.l	#$ffff,bbb2
		rts
;--------------------------------------------------
wave_me		lea	wave2+2(pc),a0
		move.l	a0,a1
		move.l	a0,a3
		lea	wave2+2(pc),a0
		lea	textura,a2
		move.w	#120-1,d6
map_y_d		move.w	#192-1,d7
map_x_d		moveq	#0,d1
		moveq	#0,d0
		move.b	(a0),d0
		move.b	(a3)+,d1
		add.w	d1,d0
		lsr.w	#1,d0
		move.b	d0,(a2)+
		dbf	d7,map_x_d
		move.l	a1,a3
		addq.l	#1,a0
		dbf	d6,map_y_d
		rts
;--------------------------------------------------------------                        
             	data
steper		dc.b	0
steper2		dc.b	128
steper3		dc.b	64
steper4		dc.b	96
		even
light		dc.l	64*10
scren_p     	dc.l 	$3a0000
scren_l     	dc.l 	$3a0000-256*472*2 
aaa		ds.l	1
bbb2		ds.l	1
sin_addit       dc.b 	$67,$66,$67,$66,$66,$66,$66,$66
                dc.b 	$56,$65,$65,$55,$55,$55,$55,$54
                dc.b 	$45,$44,$44,$44,$43,$44,$33,$32
                dc.b 	$33,$22,$22,$21,$21,$20,$11,$01
                dc.b 	$0,0,0,0                                                                                                        
;--------------------------------------------------------------                        
text1		dc.b	"mYSTIc",13,10
		dc.b	"ByteS",13,10
		dc.b	"HIt  wITh",13,10
		dc.b	" ANOtHer",13,10
		dc.b	"  4Kb",13,10
		dc.b    " iNTro",13,10
		dc.b	"  RELeaSED",13,10
		dc.b	" aT QuaST 98",13,10
		dc.b	"CalleD",13,10
		dc.b	'~fURy~'
		dc.b	0
wave2		incbin	d:\sinus\d_sin.prg
		even
	     	bss	     		     		     	
lx     		ds.w 	1
ly     		ds.w 	1
lx2     	ds.w 	1
ly2     	ds.w 	1
mode	     	ds.w	1             
cnt_1		ds.w	1
sin		ds.w	256
wave1		ds.b	256
		ds.l	128
green2		ds.l	256*4
blue2		ds.l	256*2
red2		ds.l	256*2
yel2		ds.l	256*2
textura		ds.b	192*124
sqr_tab		ds.b	256*256
st		ds.w	192*120
sc_temp		ds.w	320*200
pic		ds.b	256*256
		ds.b	256*256
offs		ds.w	320*200		
offs2		ds.w	320*200		
offs3		ds.w	320*200		
surf		ds.w	192*200
map		ds.b	256*256
		ds.b	256*256
dist		ds.w	192*120		
st2		ds.w	256*256