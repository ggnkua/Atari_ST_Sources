	    clr.w	-(sp)
	    move.w	#$20,-(sp)
	    trap	#1
	    addq.l	#2,sp
	    	    
	    
	    move.w  	#363,d0
            move.w  	d0,-(a7)
            move.w  	#3,-(a7)                 ;VsetMode option
            pea     	$370000	
            pea     	$370000
            move.w  	#5,-(a7)
            trap    	#14
            lea     	14(a7),a7
	    move	d0,mode
	
	    lea 	pic_pal,a0
            lea 	$fffff9800.w,a1
            move.w 	#256-1,d7
rew_it      
            move.l 	(a0)+,(a1)+
            dbf 	d7,rew_it                        	    	
;-----------------------------------------
un_dep      lea		pic,a0
            lea		out_pic,a1
	    bsr		UNPACK
;-----------------------------------------            
            
_vbl_       	    
	    move.w 	#37,-(sp)
	    trap 	#14     
	    addq.l 	#2,sp
	    
	    subq.w	#1,dd
	    bne.b	_vbl_
	    bra.b 	for
dd	    dc.w	5	    
for	    
	    move.w	#5,dd
	    
	    move.l	poi,a0
	    move.w	(a0)+,x_
	    move.w	(a0)+,y_
	    move.l	a0,poi
	    
	    cmp.w	#$ffff,y_
	    beq.b	stop
	    
	    move.w	x_,d0
	    move.w	y_,d1	   
	    mulu	#32,d0
	    mulu	#32*768,d1
	    add.l	d1,d0
	    	    	    
	    lea		out_pic,a0
	    move.l      #$370000,a1	   
	    add.l	d0,a1
	    add.l	d0,a0
	    
	    move.l	#768-8*4,a2
	    
	    move.w	#16*2-1,d7
line	    rept	8
	    move.l	(a0)+,(a1)+	    
	    endr
	    add.l	a2,a0	    
	    add.l	a2,a1
	    dbf		d7,line	
	    
	    bra	_vbl_
	    
stop	    move.w	#7,-(sp)
	    trap	#1
	    addq.l	#2,sp
	    

            ;-------------
done        move.w  	mode,d0
            move.w  	d0,-(a7)
            move.w  	#3,-(a7)                 ;VsetMode option
            pea     	$370000	
            pea     	$370000
            move.w  	#5,-(a7)
            trap    	#14
            lea     	14(a7),a7
            
            
            clr.l	-(sp)
            trap	#1
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
mode	   dc.w		0
wsjo       dc.w 	500*4-390
tim_op     dc.w 	0
various	   dc.w		0
x_	   dc.w		0
y_	   dc.w		0
sav_sp	   ds.l         1
temp_pal   ds.l 	256
;--------------------------------------------------------------------------
poi	   dc.l		tab_adr
tab_adr	   dc.w		1,14		;m leg
           dc.w		1,13
           dc.w		1,12
           dc.w		1,11
           dc.w		1,10
           dc.w		1,9
           dc.w		1,8
           dc.w		1,7
           dc.w		1,6
           dc.w		1,5
           dc.w		1,4
           dc.w		1,3
           dc.w		1,2
           dc.w		1,1
           dc.w		1,0
            
           dc.w		7,0         ;m s leg
           dc.w		7,1
           dc.w		7,2
           dc.w		7,3
           dc.w		7,4
           dc.w		7,5
           dc.w		7,6
           dc.w		7,7
           dc.w		7,8
           dc.w		7,9
           dc.w		7,10
           dc.w		7,11
           dc.w		7,12
           dc.w		7,13
           dc.w		7,14	
           ;beetw
           dc.w		2,2
           dc.w		2,3
           
           dc.w		3,3
           dc.w		3,4
           dc.w		4,4
           dc.w		4,5	
           dc.w		5,4
           dc.w		5,3
           dc.w		6,3
           dc.w		6,2
				           	
           
	   dc.w		$ffff,$ffff
;---------------------------------------------------------------------------
pic       incbin  	mystic.dat
pic_pal   incbin  	mystic.pal
;---------------------------------------------------------------------------
	     section  bss
out_pic	      ds.b	768*480
;---------------------------------------------------------------------------


	     