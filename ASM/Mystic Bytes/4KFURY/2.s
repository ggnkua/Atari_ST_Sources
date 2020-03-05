		output	f:\quast.tos
				
            	clr.l 	-(sp)
            	move.w 	#$20,-(sp)
            	trap 	#1	
;---------------------------------------------------------------------;                                      
		moveq	#36,d0	            	
            	bsr	set_mode	
		move	d0,mode
			
            	lea	text1(pc),a0
            	bsr	print

		moveq	#8*6,d0		
		bsr	convert
            	
            	bsr	blur
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
            	lea   	green2,a0
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
            	addq.w 	#1,d4 
            	not.b  	d5
            	bne.b  	half
            	addq.w 	#1,d0                             
		move.w 	d3,(a0)+
half        	dbf    	d7,green_pal            
;----------------------------------------- 
            	lea 	green2(pC),a1
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
            	move.w 	(a1,d0.w*2),d0
            	move.w	d0,(a0)+                                                
            	addq.w 	#1,d4
            	dbf 	d7,small_lop_r
            	moveq 	#-128,d4
            	addq.l 	#1,d5
            	dbf 	d6,bigg_lop_r  
;------------------------------------------------------            
            	lea 	textura+192,a0
            	lea 	st,a1
            	moveq.w #0,d0
            	moveq.w #0,d1
            	move.w 	#120-1,d6
big_t       	move.w 	#192-1,d7
samll_e     	move.w 	d0,d3
            	move.w 	d1,d4 
            	move.b 	-2(a0),d2
            	sub.b 	2(a0),d2
            	add.b 	d2,d3
            	moveq	#0,d2
            	move.b 	-192(a0),d2
            	sub.b 	192(a0),d2 
            	add.b 	d2,d4            
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
		bra.b	yeah
ss		ds.b	1		
ss2		ds.b	1		
;---------------------------------------------------------------             
yeah		
;--------------------------------------------------------------------					
		moveq 	#0,d0
            	lea 	wave1(pc),a1           
            	move.l	a1,a0
            	move.b 	steper(pc),d0
	        moveq 	#0,d1
            	move.b 	(a1,d0.w),d1           
            	lsr.b 	#2,d1            
            	and.w 	#$ff,d1
            	move.w 	d1,ly                         
            	moveq 	#0,d1
            	move.b 	steper2(pc),d0
            	move.b 	(a0,d0.w),d1           
            	lsr.b 	#1,d1
		add.w	#50,d1
            	move.w 	d1,lx
            	addq.b	#2,steper
            	addq.b	#6,steper2
            	;-----------------------
		move.l	scren_p(pc),a0		
		move.w	#192*120-1,d7
		lea	st,a2
		lea	sqr_tab+256*2*128+256,a5

		moveq	#0,d5
		moveq	#0,d0
		move.w 	lx(pc),d0            
            	move.w 	ly(pc),d5        
            	lsl.w  	#7,d0
            	move.b 	d5,d0
		ext.l	d0
            	asl.l  	#1,d0		
            	sub.l  	d0,a5            
		;---------------
		moveq	#0,d0
		moveq	#0,d2
draw		
		move.w	(a2)+,d2				
		move.w	(a5,d2.w*2),d1
		move.w	d1,(a0)+	
		move.w	d1,(a0)+	
		dbf	d7,draw		
		;-----------------
;---------------------------------------------------------------------------------
BBB		move.l 	scren_p,d0
	        move.l 	scren_l,scren_p
            	move.l 	d0,scren_l
            	lsr.w 	#8,d0
            	move.l 	d0,$ffff8200.w                               
            	cmp.b 	#1,$ffffffc02.w
            	bne 	yeah                        	
;--------------------------------------------------------------                        
             	move.w  mode(pc),d0
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
convert		move.l	scren_p(pc),a0
		lea	textura+192*28,a2
		moveq	#8*2-1,d2
		move.l	#$1f1f1f1f,d5
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
;--------------------------------------------------------------                                     	
blur		lea	textura,a0
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
             	data
steper		dc.b	0
steper2		dc.b	128
		even
scren_p     	dc.l 	$3a0000
scren_l     	dc.l 	$3a0000-256*372*2 
sin_addit       dc.b 	$67,$66,$67,$66,$66,$66,$66,$66
                dc.b 	$56,$65,$65,$55,$55,$55,$55,$54
                dc.b 	$45,$44,$44,$44,$43,$44,$33,$32
                dc.b 	$33,$22,$22,$21,$21,$20,$11,$01
                dc.b 	$0,0,0,0                                                                                                        
;--------------------------------------------------------------                        
text1		dc.b	"Mystic",13,10
		dc.b	"Bytes!",0

	     	bss	     		     		     	
lx     		ds.w 	1
ly     		ds.w 	1
mode	     	ds.w	1             
sin		ds.w	256
wave1		ds.b	256
green2		ds.l	256
ecs		ds.b	192*118
textura		ds.b	192*120
sqr_tab		ds.w	256*256
st		ds.w	256*256