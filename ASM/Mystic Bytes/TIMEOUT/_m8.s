	    output  m8.dat

	    move.l sp,sav_sp
	    
	    cmp.w	#1,d0
	    beq		un_dep
	    
            lea 	$fffff9800.w,a1
            move.w 	#256-1,d7
rew_it2     move.l 	#0,(a1)+
            dbf 	d7,rew_it2            
            
            bclr	#0,$ffffffa13.w
            move.w	#37,-(sp)
            trap	#14
            addq.l	#2,sp
     	    
     	    move.l 	#$370000,d0
            lsr.w 	#8,d0
            move.l 	d0,$ffff8200.w                   
                 	   
	    moveq 	#2,d0
	    trap	#4		
	    move.w  	#90,$fffff82a8
	    bset	#0,$ffffffa13.w
	
	    lea		out_pic,a0
            lea		$370000,a1
            move.w	#768*480/4/16-1,d7
copy_to	    rept	16
	    move.l	(a0)+,(a1)+            
	    endr
	    dbf		d7,copy_to
	    moveq	#0,d0
	    move.w	#50*768/4/16-1,d7
clr_tra	    rept	16
	    move.l	d0,(a1)+	    
	    endr
	    dbf		d7,clr_tra

            bra		wait_m1
;-----------------------------------------
un_dep      lea		pic,a0
            lea		out_pic,a1
	    bsr		UNPACK
	    move.l	sav_sp,sp
	    rts	    
;-----------------------------------------            
wait_m1     ;moveq	#4,d0
            ;trap	#4
            ;cmp.w	#1,d0
            ;bne.b	wait_m1
            
_vbl_       
            bclr	#0,$fffffffa13.w  
	    
	    move.w 	#37,-(sp)
	    trap 	#14     
	    addq.l 	#2,sp
	    
	    lea 	temp_pal,a0
            lea 	$fffff9800.w,a1
            move.w 	#256/64-1,d7
rew_it      
	    rept 	64
            move.l 	(a0)+,(a1)+
            endr
            dbf 	d7,rew_it            
            
            clr.b  $fffa1b
            and.b  #%11111110,$fffa13      
            move.b #%0111,$fffffa1b.w
     	    move.b #2,$fffffa21.w             
	    or.b   #%00000001,$fffffa13.w     
            
	    
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
;------------------------------------------------
;LZW Depack routine for the JAM packer V4.0
;It is kept simple to minimise depack time.
;------------------------------------------------------
UNPACK:
	;MOVE.W	$FFFF8240.W,-(A7)
	MOVE.L	A0,A4
	MOVE.L	A1,A6
	ADDA.L	8(A0),A4
	ADDA.L	4(A0),A6
	MOVE.L	A6,A5			;KEEP COPY TO CHECK AGAINST
	MOVE.L	4(A0),D4
	MOVE.B	#$20,D3

	MOVE.W	#$0FED,D5
	MOVEA.L A6,A3			;KEEP ADDR OF END OF SPACES

	MOVEQ	#$00,D7			;START UNPACK ROUTINE
TOPDEP:	DBF	D7,NOTUSED
	MOVE.B	-(A4),D6		;GET COMMAND BYTE
	MOVEQ	#$07,D7
NOTUSED:
	LSR.B	#1,D6
	BCC.S	COPY			;BIT NOT SET, COPY FROM UNPACKED AREA 
	MOVE.B	-(A4),-(A6)		;COPY BYTES FROM PACKED AREA
	ADDQ.W	#1,D5
	SUBQ.L	#1,D4
	BGT.S	TOPDEP
	BRA.S	EXITUP
COPY:	MOVE.B	-2(A4),D0
	LSL.W	#4,D0
	MOVE.B	-(A4),D0
	;MOVE.W	D0,$FFFF8240.W
	SUB.W	D5,D0
	NEG.W	D0
	AND.W	#$0FFF,D0
	LEA	1(A6,D0.W),A0
	MOVEQ	#$0F,D1
	AND.B	-(A4),D1
	ADDQ.W	#2,D1
	MOVEQ	#$01,D0
	ADD.W	D1,D0
	CMPA.L	A5,A0
	BGT.S	SPACES
	
WRITE:	MOVE.B	-(A0),-(A6)
	DBF	D1,WRITE
BACK:	ADD.L	D0,D5
	SUB.L	D0,D4
	BGT.S	TOPDEP
EXITUP:	;MOVE.W	(A7)+,$FFFF8240.W
	RTS

SPACES: CMPA.L	A5,A0
	BLE.S	WRITE
	MOVE.B	D3,-(A6)		;COPY OUT SPACES
	SUBQ.L	#1,A0
	DBF	D1,SPACES
	BRA.S	BACK
	
;---------------------------------------------------------------------------           
            section data
teeem      dc.w 	0
wsjo       dc.w 	500*4-390
tim_op     dc.w 	0
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

                rept 	4
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
pic       incbin  	mystic.dat
pic_pal   incbin  	mystic.pal
;---------------------------------------------------------------------------
	     section  bss
out_pic	      ds.b	768*480	     