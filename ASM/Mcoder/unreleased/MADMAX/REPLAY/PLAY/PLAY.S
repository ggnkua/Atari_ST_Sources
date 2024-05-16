MUS=1
BASE=$40000
	MOVE	SR,D0
	AND	#$2000,D0
	BNE.S	SUPER
	CLR.L	-(SP)
	MOVE	#$20,-(SP)
	TRAP	#1
	ADDQ	#6,SP
SUPER:
	MOVEQ	#MUS,D0
	JSR	BASE
BCL:
	MOVE	#37,-(SP)
	TRAP	#14
	ADDQ	#2,SP
wait:	move.b	$ffff8209.w,d0
	beq.s	wait
	not	d0
	lsr	d0,d0
	MOVE	#$700,$FFFF8240.W
	JSR	BASE+8
	CLR	$FFFF8240.W
	MOVE	#$FF,-(SP)
	MOVE	#6,-(SP)
	TRAP	#1
	ADDQ	#4,SP
	TST	D0
	BEQ.S	BCL
	MOVEQ	#0,D0
	JSR	BASE

	move.l	#$08080000,$ffff8800.w
	move.l	#$09090000,$ffff8800.w
	move.l	#$0a0a0000,$ffff8800.w
	ILLEGAL
