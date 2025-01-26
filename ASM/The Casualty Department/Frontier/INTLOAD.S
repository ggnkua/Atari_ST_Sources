*	FRONTIER INTRO CODE BY DR DYNAC



;	opt	O+,W-

HEADER:
	MOVE.L	A7,A5
	MOVE.L	#USTK,A7
	MOVE.L	4(A5),A5
	MOVE.L	12(A5),D0
	ADD.L	20(A5),D0
	ADD.L	28(A5),D0
	ADD.L	#$100,D0
	MOVE.L	D0,-(A7)
	MOVE.L	A5,-(A7)
	MOVE.W	#0,-(A7)
	MOVE.W	#$4A,-(A7)
	TRAP	#1
	ADD.L	#12,A7

	dc.w	$a00a
	bsr	super
	move.l	#mytrap,$a8	;TRAP #10 vector
	bsr	play
	bra	go

desk	bsr	stop
	clr.w	-(a7)
	trap	#1


go	lea	cls(pc),a6
	bsr	print
	
	lea	count(pc),a5
	move.l	#counten-count-1,d5
intro	move.b	(a5)+,d6
	moveq	#20,d7
	bsr	conout
	bsr	vsync
	lea	cls(pc),a6
	bsr	print
	dbf	d5,intro		

;	bsr	wait
	lea	enable(pc),a6
	bsr	print

	moveq	#16,d6
	bsr	cright

	
	lea	red(pc),a6
	bsr	print
	lea	tcd(pc),a5
	move.l	#tcdend-tcd-1,d5
	bsr	loop

	moveq	#4,d6
	bsr	cleft

	lea	black(pc),a6
	bsr	print
	lea	pres(pc),a5
	move.l	#presend-pres-1,d5
	bsr	loop
	
	moveq	#3,d6
	bsr	cdown
	moveq	#9,d6
	bsr	cleft
	
	lea	blue(pc),a6
	bsr	print
	lea	apb(pc),a5
	move.l	#apbend-apb-1,d5
	bsr	loop
	bsr	wait
		
	moveq	#5,d6
	bsr	cdown
	moveq	#10,d6
	bsr	cleft

	lea	black(pc),a6
	bsr	print
	lea	crack(pc),a5
	move.l	#cracend-crack-1,d5
	bsr	loop

	moveq	#2,d6
	bsr	cdown
	moveq	#8,d6
	bsr	cleft

	lea	purple(pc),a6
	bsr	print
	lea	dr(pc),a5
	move.l	#drend-dr-1,d5
	bsr	loop

	moveq	#2,d6
	bsr	cdown

	bsr	wait

	moveq	#6,d6
	bsr	cleft
	moveq	#5,d6
	bsr	cup

endseq	moveq	#2,d6
	bsr	cup
	moveq	#2,d6
	bsr	cleft
	moveq	#2,d6
	bsr	cup
	moveq	#2,d6
	bsr	cleft
	moveq	#6,d6
	bsr	cup
	moveq	#7,d6
	bsr	cleft
	bsr	wait

t	moveq	#4,d6
	bsr	cright
	lea	red(pc),a6
	bsr	print	
	lea	cas(pc),a5
	move.l	#casend-cas-1,d5
	bsr	loop
	bsr	wait
	
	moveq	#19,d6
	bsr	cdown
	moveq	#22,d6
	bsr	cleft

	lea	grey(pc),a6
	bsr	print	
	lea	press(pc),a5
	move.l	#pressen-press-1,d5
	bsr	loop
	
	bsr	waitkey

	moveq	#1,d6
	bsr	cdown
	moveq	#21,d6
	bsr	cleft
	lea	black(pc),a6
	bsr	print
	lea	load(pc),a5
	move.l	#loadend-load-1,d5
	bsr	loop
	
d	moveq	#11,d6
	bsr	cup
	moveq	#24,d6
	bsr	cleft
	moveq	#10,d6
	lea	clst(pc),a6
	bsr	print
delete	moveq	#2,d7
	bsr	vsync
	lea	del(pc),a6
	bsr	print
	dbf	d6,delete
	lea	dis(pc),a6
	bsr	print
	bsr	fade
	rts

wait	moveq	#3,d6
wait2	moveq	#20,d7
	bsr	vsync
	dbf	d6,wait2
	rts

fade	moveq	#6,d6
fade2	moveq	#5,d7
	bsr	vsync
	sub.w	#$111,$ffff8240
	add.w	#$111,$ffff825e
	dbf	d6,fade2
	rts

	
waitkey	move.b	$fffffc02,d3
	cmp.b	#57,d3
	beq	please
	rts

please	bsr	fade
	lea	pos(pc),a6
	bsr	print

	PEA	0
	PEA	0
	PEA	FRONT(PC)
	MOVE.W	#0,-(A7)	;0=LOAD AND GO  3=LOAD AND STOP
	MOVE.W	#$4B,-(A7)
	TRAP	#1
	ADD.L	#16,A7
	TST.L	D0
	BMI 	desk

****************************************

mytrap	LEA	TRAINER(PC),A4
	BSR	PRN
CHECK	BSR	waitk

	SWAP	D0
	CMP.B	#$15,D0		;YES
	BEQ	ALTER
	CMP.B	#$31,D0		;NO
	BNE	CHECK
	MOVE.L	#1000,D1
	BRA	put
	
ALTER	LEA	amount(PC),A4
	BSR	PRN

top	bsr	waitk
	cmp.b	#"1",d0
	bne	two
	move.l	#10000,d1
	bra	put

two	cmp.b	#"2",d0
	bne	three
	move.l	#100000,d1
	bra	put

three	cmp.b	#"3",d0
	bne	four
	move.l	#1000000,d1
	bra	put

four	cmp.b	#"4",d0
	bne	five
	move.l	#2000000,d1
	bra	put

five	cmp.b	#"5",d0
	bne	six
	move.l	#3000000,d1

six	cmp.b	#"6",d0
	bne	seven
	move.l	#4000000,d1

seven	cmp.b	#"7",d0
	bne	eight
	move.l	#5000000,d1

eight	cmp.b	"8",d0
	bne	nine
	move.l	#6000000,d1

nine	cmp.b	#"9",d0
	bne	top
	move.l	#7000000,d1

put	move.l	a6,a5
	add.l	#398992-28,a5
	move.l	d1,(a5)

	clr.l	$4d2			;clear interrupt
	bchg	#0,$484			;click on
	move.l	#$8000000,$ffff8800	;clear sound channels
      	move.l  #$9000000,$ffff8800 	;
      	move.l  #$a000000,$ffff8800 	;

	
GO	JMP	(A6)

PRN	MOVE.L	A4,-(A7)
	MOVE.W	#9,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	RTS
	
waitk	MOVE.W	#7,-(A7)
	TRAP	#1
	ADDQ.L	#2,A7
	RTS
	
	RTE
	

amount	dc.b	27,"E"
	dc.b	"Choose amount of credits to start:",13,10,10,10
	dc.b	"1 - $1000",13,10
	dc.b	"2 - $10000",13,10
	dc.b	"3 - $100000",13,10
	dc.b	"4 - $200000",13,10
	dc.b	"5 - $300000",13,10
	dc.b	"6 - $400000",13,10
	dc.b	"7 - $500000",13,10
	dc.b	"8 - $600000",13,10
	dc.b	"9 - $700000",13,10,10,10
	dc.b	"PS - This music from the game is also",13,10
	dc.b	"on this disk along with the replay code."
	dc.b	0
	even

TRAINER	DC.B	27,"Y",32+17,32+6
	DC.B	"DO YOU WANT TO CHEAT? [Y]es [N]o",0
	even


****************************************

cup	moveq	#2,d7
	lea	up(pc),a6
	bsr	print
	bsr	vsync
	dbf	d6,cup
	rts

cdown	moveq	#2,d7
	lea	down(pc),a6
	bsr	print
	bsr	vsync
	dbf	d6,cdown
	rts
	
cleft	moveq	#2,d7
	lea	left(pc),a6
	bsr	print
	bsr	vsync
	dbf	d6,cleft
	rts

cright	moveq	#2,d7
	lea	right(pc),a6
	bsr	print
	bsr	vsync
	dbf	d6,cright
	rts
	

loop	move.b	(a5)+,d6
	bsr	conout
	moveq	#2,d7
	bsr	vsync
	dbf	d5,loop
	rts
	

conout	move.w	d6,-(a7)
	move.w	#2,-(a7)
	trap	#1
	addq.l	#4,a7
	rts

print	move.l	a6,-(a7)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts

vsync	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7
	dbf	d7,vsync
	rts

super	move.w	sr,d7
	btst	#13,d7
	beq	sup
	bra	over
sup	pea	0
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
over	rts
	
play	bchg	#0,$484
	moveq	#1,d0
	bsr	music
	move.l	#music+8,$4d2
	rts

stop	bchg	#0,$484
	moveq	#0,d0
	bsr	music
	clr.l	$4d2
	rts

	data

	even	
cls	dc.b	27,"E",0
enable	dc.b	27,"e",0
dis	dc.b	27,"f",0
up	dc.b	27,"A",0
down	dc.b	27,"B",0
right	dc.b	27,"C",0
left	dc.b	27,"D",0
del	dc.b	27,"M",0
clst	dc.b	27,"d",0

red	dc.b	27,"b",1,0	
blue	dc.b	27,"b",4,0
black	dc.b	27,"b",15,0
purple	dc.b	27,"b",5,0
grey	dc.b	27,"b",8,0


count	dc.b	"9876543210 "
counten	even	

tcd	dc.b	"TCD",10,10
tcdend	even

pres	dc.b	"PRESENTS"
presend	even

apb	dc.b	"* FRONTIER *"
apbend	even

crack	dc.b	"CRACKED BY"
cracend	even

dr	dc.b	"DR DYNAC"
drend	even


cas	dc.b	"THE CASUALTY DEPARTMENT"
casend	even

press	dc.b	"PRESS SPACE TO CONTINUE"
pressen	even

pos	dc.b	27,"E"
	dc.b	27,"Y",32+12,32+4
	dc.b	27,"b",3
load	dc.b	"LOADING...PLEASE WAIT"
loadend	even
 
FRONT	DC.B	"FRONTIER.PRG",0
	even

music	incbin "alec5.mus"
musend	even


	DS.B	256
USTK	DS.L	1

