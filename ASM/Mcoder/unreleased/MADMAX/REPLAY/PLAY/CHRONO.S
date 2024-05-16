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
	move.l	$4ba,time

	MOVEQ	#MUS,D0
	JSR	BASE
	move	#1000,cpt
BCL:
	MOVE	#37,-(SP)
;	TRAP	#14
	ADDQ	#2,SP

;	MOVE	#5000,D0
;WAIT:	DBRA	D0,WAIT

	NOT	$FFFF8240.W
	JSR	BASE+8
	CLR	$FFFF8240.W

	MOVE	#$FF,-(SP)
	MOVE	#6,-(SP)
;	TRAP	#1
	ADDQ	#4,SP

;	TST	D0
;	BEQ.S	BCL
	subq	#1,cpt
	bne	bcl

	move.l	$4ba,d0
	sub.l	time,d0
	ILLEGAL
time:	dc.l	0
cpt:	dc.w	0
