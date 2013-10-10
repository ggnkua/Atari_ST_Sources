	moveq.w	#0,d2
	move.w	#1,d3
	move.w	#319,d1	
	lea	GEN,a0
	move.w	#$4efb,(a0)		;jmp	gen_line(pc,d4.w)
	move.w	#$5002,2(a0)
	addq.l	#4,a0
GEN_LINE
	ror.w	d3
	move.w	#$50,(a0)		;or.w	#-----,(a0)
	move.w	d3,2(a0)		;
	move.w	#$d244,4(a0)		;add.w	d4,d1
	move.w	#$6404,6(a0)		;bcc.s
	move.w	#$41e8,8(a0)		;lea.l	160(a0),a0
	move.w	#$00a0,10(a0)	
	addq.w	#1,d2
	cmpi.w	#16,d2
	bne.s	NO_ADD
	move.w	#$5088,12(a0)		;addq.l	#8,a0
	moveq.w	#0,d2	
	bra.s	NO_NOP
NO_ADD	
	move.w	#$4e71,12(a0)
NO_NOP
	lea	14(a0),a0		
	dbf	d1,GEN_LINE
	move.w	#$4e75,(a0)		;rts
	SECTION BSS
GEN	DS.B	5000
	END
																																																																													