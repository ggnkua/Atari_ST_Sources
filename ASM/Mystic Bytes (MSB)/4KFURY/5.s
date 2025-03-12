		output	f:\quast.tos


		move.w #0,-(sp)     ;open surce code
		pea  name(pc)
		move.w 	#$3d,-(sp)
		trap 	#1
		addq.l #8,sp
	
		move.l #pic,-(sp)  ;read surce code 
		move.l #-1,-(sp)
		move.w d0,-(sp)
		move.w #$3f,-(sp)
		trap 	#1
		lea 12(sp),sp              
		
		move.w #0,-(sp)     ;open surce code
		pea  name(pc)
		move.w 	#$3d,-(sp)
		trap 	#1
		addq.l #8,sp
	
		move.l #pic+256*256*2,-(sp)  ;read surce code 
		move.l #-1,-(sp)
		move.w d0,-(sp)
		move.w #$3f,-(sp)
		trap 	#1
		lea 12(sp),sp              
				
            	clr.l 	-(sp)
            	move.w 	#$20,-(sp)
            	trap 	#1	
;---------------------------------------------------------------------;                                      
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
;---------------------------------------------------------------------;                                                  
            	moveq 	#$64,d0
            	bsr	set_mode
		
		move.w	#%1,$fffff82c2
            	clr.l	$fffff9800.w
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
		moveq	#128-1,d7
		
cont		move.w	d3,(a0)+
		dbf	d7,cont
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
            	moveq	 #0,d0         
            	move.l  #$40000000,d1 
sqrtLP1_r:    	move.l 	d2,d3          
            	sub.l 	d1,d3           
            	blt.b 	sqrtLP2_r
            	sub.l 	d0,d3           
            	blt.b 	sqrtLP2_r         
            	move.l 	d3,d2          
            	lsr.l 	d0              
            	or.l 	d1,d0            
            	lsr.l 	#2,d1           
            	bne.b 	sqrtLP1_r                            
            	bra.b 	out_1_r                 
sqrtLP2_r:    	lsr.l 	d0              
            	lsr.l 	#2,d1           
            	bne.b 	sqrtLP1_r             
            	;---------- 
out_1_r       	and.w 	#$ff,d0
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
;------------------------------------------------------            
yeah		
;--------------------------------------------------------------------					
		lea	sc_temp,a0
		bsr	convert            	
            	bsr	blur
            	bsr	bump_map
		move.w	#70,cnt_1
fx_1		lea 	green2(pC),a1            	
		bsr	bump_1
		subq.l	#4,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_1	
		**************
		move.w	#70,cnt_1
fx_2		lea 	green2(pC),a1            	
		bsr	bump_1
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_2		
		move.w	#90,cnt_1
fx_3		lea 	green2(pC),a1            	
		bsr	bump_1
		subq.l	#4,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_3
		
		;bra	new
		
		lea	sc_temp+320*2*16,a0
		lea	textura+192*40+32(pc),a2		
		bsr	convert2            	
            	bsr	blur
            	bsr	bump_map		
		move.w	#90,cnt_1
fx_4		lea 	green2(pC),a1            	
		bsr	bump_1
		addq.l	#4,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_4
		**************
		move.w	#70,cnt_1
fx_5		lea 	green2(pC),a1            	
		bsr	bump_1
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_5		
		move.w	#90,cnt_1
fx_6		lea 	green2(pC),a1            	
		bsr	bump_1
		subq.l	#4,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_6
;------------------------------------------------------		
		lea	sc_temp+320*2*32,a0
		lea	textura+192*30+30(pc),a2		
		bsr	convert2            	
            	bsr	blur
            	bsr	bump_map		
		move.w	#90,cnt_1
fx_7		lea 	green2(pC),a1            	
		bsr	bump_1
		addq.l	#4,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_7
		**************
		move.w	#70,cnt_1
fx_8		lea 	green2(pC),a1            	
		bsr	bump_1
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_8		
		move.w	#90,cnt_1
fx_9		lea 	green2(pC),a1            	
		bsr	bump_1
		subq.l	#4,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_9
;---------------------------------------------------------		
		lea	sc_temp+320*2*48,a0
		lea	textura+192*30(pc),a2		
		bsr	convert2            	
            	bsr	blur
            	bsr	bump_map		
		move.w	#90,cnt_1
fx_10		lea 	green2(pC),a1            	
		bsr	bump_1
		addq.l	#4,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_10
		**************
		move.w	#70,cnt_1
fx_11		lea 	green2(pC),a1            	
		bsr	bump_1
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_11
		move.w	#90,cnt_1
fx_12		lea 	green2(pC),a1            	
		bsr	bump_1
		subq.l	#4,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_12
;---------------------------------------------------------		
		lea	sc_temp+320*2*64,a0
		lea	textura+192*20(pc),a2		
		bsr	convert
            	bsr	blur
            	bsr	bump_map		
		move.w	#90,cnt_1
fx_13		lea 	green2(pC),a1            	
		bsr	bump_1
		addq.l	#4,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_13
		**************
		move.w	#70,cnt_1
fx_14		lea 	green2(pC),a1            	
		bsr	bump_1
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_14
		move.w	#90,cnt_1
fx_15		lea 	green2(pC),a1            	
		bsr	bump_1
		subq.l	#4,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_15
new		

		move.l	#-40,light

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
		move.w	#100,cnt_1
fx_16		lea 	green2(pC),a1            	
		bsr	bump_2
		addq.l	#4,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_16
		**************
		move.w	#170,cnt_1
fx_17		lea 	green2(pC),a1            	
		bsr	bump_2
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_17
		move.w	#100,cnt_1
fx_18		lea 	green2(pC),a1            	
		bsr	bump_2
		subq.l	#4,light
		bsr	BBB
		subq.w	#1,cnt_1
		bne.b	fx_18
		
		
		bra	skip
;---------------------------------------------------------------------------------
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
		lea	textura+192*28(pc),a2
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
;--------------------------------------------             	
bump_set	moveq 	#0,d0
            	lea 	wave1(pc),a2           
            	move.b 	steper(pc),d0
	        moveq 	#0,d1
            	move.b 	(a2,d0.w),d1           
            	lsr.b 	#2,d1            
            	and.w 	#$ff,d1
            	move.w 	d1,ly                         
            	moveq 	#0,d1
            	move.b 	steper2(pc),d0
            	move.b 	(a2,d0.w),d1           
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
            	addq.b	#6,steper2             	
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
;--------------------------------------------------------------                        
             	data
steper		dc.b	0
steper2		dc.b	128
steper3		dc.b	64
steper4		dc.b	96
		even
light		dc.l	64*10
scren_p     	dc.l 	$3a0000
scren_l     	dc.l 	$3a0000-256*372*2 
sin_addit       dc.b 	$67,$66,$67,$66,$66,$66,$66,$66
                dc.b 	$56,$65,$65,$55,$55,$55,$55,$54
                dc.b 	$45,$44,$44,$44,$43,$44,$33,$32
                dc.b 	$33,$22,$22,$21,$21,$20,$11,$01
                dc.b 	$0,0,0,0                                                                                                        
;--------------------------------------------------------------                        
text1		dc.b	"Mystic",13,10
		dc.b	"Bytes!",13,10
		dc.b	"Presents",13,10
		dc.b	"--------",13,10
		dc.b	"Our 4kb",13,10
		dc.b    " Intro",13,10
		dc.b	"  Released",13,10
		dc.b	"for QuaST 98",13,10
		dc.b	"Called",13,10
		dc.b	'"DUDE"'
		dc.b	0
name		dc.b	"d:\mess.565",0
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
green2		ds.l	256*2
textura		ds.b	192*124
sqr_tab		ds.b	256*256
st		ds.w	192*120
sc_temp		ds.w	320*200
pic		ds.w	256*256
		ds.w	256*256
		
		