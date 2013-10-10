	clr.w -(sp)
	move.l #fic,-(sp)
	move.w #61,-(sp)
	trap #1
	addq.l #8,sp
	move.w d0,d1
	
	move.l #99000,a0
	move.l #debrecop,a1
	move.w #20,d0
recop:	move.l (a1)+,(a0)+
	dbf d0,recop
	
	move.l #49000,a0
	jmp (a0)

debrecop:	move.l #100000,-(sp)
	move.l #235072,-(sp)
	move.w d1,-(sp)
	move.w #63,-(sp)
	trap #1
	add.l #12,sp
	
	move.l #100000,a0
	jmp (a0)
	
	clr.w -(sp)
	trap #1
	
fic:	dc.b 'FROG2.SCT',0
	even