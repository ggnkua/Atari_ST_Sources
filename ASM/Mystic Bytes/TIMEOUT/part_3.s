	    output  m1.dat

	    move.l sp,sav_sp
	    
            lea 	$fffff9800.w,a1
            move.w 	#256-1,d7
rew_it2     move.l 	#0,(a1)+
            dbf 	d7,rew_it2            
            

	    moveq 	#2,d0
	    trap	#4		

            move.l	#pic,a0
            move.l	#$370000,a1
            moveq  #3,d0
            trap #4
            ;----------------            
wait_m1     moveq	#4,d0
            trap	#4
            cmp.w	#1,d0
            bne.b	wait_m1
            
_vbl_       
              
	    move.w 	#37,-(sp)
	    trap 	#14     
	    addq.l 	#2,sp
	    
	    ;tst.b	$ffff8209.w
	    ;bne.b	_vbl_
	    
	    lea 	temp_pal,a0
            lea 	$fffff9800.w,a1
            move.w 	#256/64-1,d7
rew_it      
	    rept 	64
            move.l 	(a0)+,(a1)+
            endr
            dbf 	d7,rew_it            
            


real_fade   
	    move.w 	tim_op(pc),d3
            lea 	pic_pal,a0
            lea 	temp_pal,a1
            move.w 	#256-1,d7               
            move.l 	#%111111,d4
next_color  move.l 	(a0)+,d0
            move.l 	d0,d1
            move.l 	d0,d2
            lsr.w 	#2,d0	
            	
            swap.w 	d1
            lsr.w 	#2,d1
            
            ;move.w d1,d2
            swap.w 	d2
            lsr.w 	#8,d2
            lsr.w 	#2,d2
            
            and.l 	d4,d0   ;blue
            and.l 	d4,d1   ;green
            and.l 	d4,d2   ;red
            mulu  	d3,d0
            mulu  	d3,d1
            mulu  	d3,d2 
            divu  	#64,d0
            divu  	#64,d1
            divu  	#64,d2
            and.l 	d4,d0   ;blue
            and.l 	d4,d1   ;green
            and.l 	d4,d2   ;red                                        
            moveq 	#0,d5
            lsl.l 	#2,d0
            move.l 	d0,d5
            
            swap.w 	d1
            lsl.l 	#2,d1
            or.l 	d1,d5
            
            swap.w 	d2
            lsl.l 	#8,d2
            lsl.l 	#2,d2
            or.l 	d2,d5
                                                           
            move.l 	d5,(a1)+
            dbf 	d7,next_color
            ;--------------          
            tst.w	tim_op
            beq.b	no_sub_
                                    
            subq.w 	#1,tim_op
no_sub_                        
            
            move.w	various(pc),d0
            lea		tab_(pc),a1
            
            moveq	#0,d2
            moveq	#0,d3
            
            move.b	1(a1,d0.w),d2	 
            move.b	(a1,d0.w),d3
            
            moveq	#4,d0                        
            trap	#4
            
            cmp.w	d2,d1
            bne.b	nop_now
            
            addq.w	#2,various
            
            cmp.w	#63,tim_op
            bge.b	nop_now
                        
            add.w 	d3,tim_op
                        
nop_now     
	    cmp.b	#1,$fffffc02.w
	    beq.b	done

	    subq.w 	#1,wsjo
            bne  	_vbl_
            
            
            ;-------------
done        move.l 	sav_sp,sp
	    rts	    
;---------------------------------------------------------------------------           
            section data
teeem      dc.w 	0
wsjo       dc.w 	500*2-10
tim_op     dc.w 	40
various	   dc.w		0
sav_sp	   ds.l         1
temp_pal   ds.l 	256

tab_	   	dc.b	19,$00
		dc.b	19,$06
		dc.b	19,$0c
		dc.b	18,$10
		dc.b	19,$16
		dc.b	19,$1c
		dc.b	18,$20
		dc.b	19,$26
		dc.b	19,$2c
		dc.b	18,$30
		dc.b	19,$36
		dc.b	34,$3c	

                rept 	2
		dc.b	18,$00
		dc.b	19,$06
		dc.b	19,$0c
		dc.b	18,$10
		dc.b	19,$16
		dc.b	19,$1c
		dc.b	18,$20
		dc.b	19,$26
		dc.b	19,$2c
		dc.b	18,$30
		dc.b	19,$36
		dc.b	34,$3c	
		endr
		
		dc.b	18,$00
		dc.b	19,$06
		dc.b	19,$0c
		dc.b	18,$10
		dc.b	19,$16
		dc.b	19,$1c
		dc.b	18,$20
		dc.b	19,$26
		dc.b	19,$2c
		dc.b	18,$30
		dc.b	0,$36
		dc.b	0,$3c
;---------------------------------------------------------------------------
pic       incbin  	mb_hi.dat
pic_pal   incbin  	mb_hi.pal
;---------------------------------------------------------------------------
