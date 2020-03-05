	    	include	e:\macrodsp.s		
		
            	clr.l -(sp)
            	move.w #$20,-(sp)
            	trap #1
            
            	move.w #$24,d0
            	or.w #%0001000000,d0
            	move.w  d0,-(a7)
            	move.w  #3,-(a7)                ;VsetMode option
            	pea     $3a0000
	        pea     $3a0000
            	move.w  #5,-(a7)
            	trap    #14
            	lea     14(a7),a7
            	move.w d0,mode
            
            	move.w #%0001,$ffff82c2.w
            	move.w #20+10,$ffff8288.w 
            	move.w #180,$ffff828a.w 
            	move.w #120-35,$ffff82a8.w            
            	move.w #555,$ffff82aa.w
            	move.w #wide,$ff8210   
            	not.l $ff9800                                   
wide        = 384
;-----------------------------------------
            	lea   green2,a0
            	moveq #0,d0
            	moveq #0,d4
            	moveq #0,d5
            	moveq #64-1,d7
green_pal   	move.w d4,d1 
            	move.w d0,d2
            	move.w d0,d3
            	lsl.w  #5,d1
            	lsl.w  #8,d2
            	lsl.w  #3,d2             
            	or.w   d1,d3
            	or.w   d2,d3                                    
            	move.w d3,(a0)+
            	addq.w #1,d4 
            	not.b  d5
            	bne.b  half
            	addq.w #1,d0                             
		move.w d3,(a0)+
half        	dbf    d7,green_pal            
		rept	20
		move.w d3,(a0)+
		endr
;----------------------------------------- 
            	lea green2,a1
            	lea sqr_tab,a0                        
            	move.l #-128,d4
            	move.l #-128,d5
            	move.w #128*2-1,d6
bigg_lop_r    	move.w #128*2-1,d7            
small_lop_r   	move.l d4,d2
            	move.l d5,d3                        
            	muls d2,d2
            	muls d3,d3
            	add.l d3,d2            
            	;----------
            	moveq.l #0,d0         
            	move.l  #$40000000,d1 
sqrtLP1_r:    	move.l d2,d3          
            	sub.l d1,d3           
            	blt.b sqrtLP2_r
            	sub.l d0,d3           
            	blt.b sqrtLP2_r         
            	move.l d3,d2          
            	lsr.l d0              
            	or.l d1,d0            
            	lsr.l #2,d1           
            	bne.b sqrtLP1_r                            
            	bra.b out_1_r                 
sqrtLP2_r:    	lsr.l d0              
            	lsr.l #2,d1           
            	bne.b sqrtLP1_r             
            	;---------- 
out_1_r       	and.w #$ff,d0
            	cmp.w #63,d0
            	ble.b a_kura_r          
            	moveq  #0,d0    
            	bra pluj_r               
a_kura_r      	not.w d0
pluj_r        	and.l #%111111,d0
            	move.w (a1,d0.w*2),d0
            	move.w	d0,(a0)+                                                
            	addq.w #1,d4
            	dbf d7,small_lop_r
            	moveq #-128,d4
            	addq.l #1,d5
            	dbf d6,bigg_lop_r  
;------------------------------------------------------            
		lea	textura,a0
		move.w	#256*256-1,d7
do_it		move.b	(a0),d0
		lsr.b	#1,d0
		move.b	d0,(a0)+
		dbf	d7,do_it		

            	lea textura+256*2+20,a0
            	lea st,a1
            	moveq.w #0,d0
            	moveq.w #0,d1
            	move.w #118-1,d6
big_t       	move.w #192-1,d7
samll_e     	move.w d0,d3
            	move.w d1,d4 
            	move.b -2(a0),d2
            	sub.b 2(a0),d2
            	add.b d2,d3
            	moveq.w #0,d2
            	move.b -256*2(a0),d2
            	sub.b 256*2(a0),d2 
            	add.b d2,d4            
            	move.b d3,(a1)+            
            	move.b d4,(a1)+            
		not.b	ss2
		bne.b	nno2
            	addq.w #1,d0
nno2         

            	addq.l #1,a0
            	dbf d7,samll_e
            	moveq.w #0,d0
            	add.l	#256-192,a0
		not.b	ss
		bne.b	nno
            	addq.w #1,d1
nno            	dbf d6,big_t            


		bra.b	yeah
ss		ds.b	1		
ss2		ds.b	1		
;---------------------------------------------------------------             
yeah		
;--------------------------------------------------------------------					
		moveq #0,d0
            	lea wave3+2(pc),a1           
            	lea wave4+2(pc),a0           
            	move.b steper(pc),d0
            	;move.w #129,lx 
	        moveq #0,d1
            	move.b (a1,d0.w),d1           
            	lsr.b #2,d1            
            	and.w #$ff,d1
            	move.w d1,ly                         
            	moveq #0,d1
            	move.b (a0,d0.w),d1           
            	lsr.b #1,d1
            	;add.w  #45,d1
            	move.w d1,lx
            	addq.b	#3,steper
            	;-----------------------
		move.l	scren_p(pc),a0		
		move.w	#192*118/4-1,d7
		lea	st,a2
		lea	sqr_tab+256*2*128+256,a5

		moveq	#0,d5
		moveq	#0,d0
		move.w lx(pc),d0            
            	move.w ly(pc),d5        
            	;add.w	#50,d0
            	lsl.w  #7,d0
            	;sub.w	#40,d5
            	move.b d5,d0
		ext.l	d0
            	asl.l  #1,d0		
            	sub.l  d0,a5
            
		;---------------
		moveq	#0,d0
		moveq	#0,d2
draw		rept	4
		move.w	(a2)+,d2				
		move.w	(a5,d2.w*2),d1
		move.w	d1,(a0)+	
		move.w	d1,(a0)+	
		endr
		dbf	d7,draw		
		;-----------------
;---------------------------------------------------------------------------------
BBB		move.l 	scren_p,d0
	        move.l 	scren_l,scren_p
            	move.l 	d0,scren_l
            	lsr.w 	#8,d0
            	move.l 	d0,$ffff8200.w                               
            	;add.l 	#256*2,aaa
            	and.l 	#$ffff,aaa            
            	cmp.b 	#1,$ffffffc02.w
            	bne 	yeah                        	
;--------------------------------------------------------------                        
             	move.w  #$4a,-(a7)
             	move.w  #3,-(a7)                ;VsetMode option
             	pea     $3a0000
	        pea     $3a0000
	        move.w  #5,-(a7)
             	trap    #14
             	lea     14(a7),a7                               
             
             	clr.l -(sp)
             	trap #1
             	data
DSPbin.start
		incbin	d:\viev3.p56	; DSP binary file
DSPbin.end	even	
wave1		incbin	d:\sinus\v_sin.prg
wave2		incbin	d:\sinus\d_sin.prg
wave3		incbin	d:\sinus\t_sin.prg
wave4		incbin	d:\sinus\v_sin.prg

steper		dc.b	128
steper2		ds.b	1
		even
lx     		dc.w 	0
ly     		dc.w 	0
wave_cnt	dc.w	0		
p1		dc.l	30
p2		dc.l	110
mode	     	ds.w	1             
scren_p     	dc.l 	$3a0000
scren_l     	dc.l 	$3a0000-256*372*2 
aaa	    	ds.l	1
textura		incbin	e:\textury.!!!\image1.raw
	     	bss
green2		ds.l	256
ecs		ds.b	192*118
;textura		ds.b	256*256
sqr_tab		ds.w	256*256
st		ds.w	256*256