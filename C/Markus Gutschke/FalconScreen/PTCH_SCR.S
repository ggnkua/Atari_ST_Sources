* Little patch done by Sharp Man of The Black Cats to allow GEM
* to support new rezolutions.


	export	sharp


sharp:

	move.w	d0,RES_X
	move.w	d1,RES_Y
	movem.l	d3-d7/a2-a6,-(a7)
	pea		routine
	move.w	#$26,-(a7)
	trap	#14
	addq.l	#6,a7
	movem.l	(a7)+,d3-d7/a2-a6
	rts
	
* Initialisations

routine:
	move.l	$432.w,a1
	lea		$400.w,a0
	LEA		BUF640,A4
	LEA		BUF480,A5
	LEA		BUF461,A6

* looks for in the system ram

CONT:
	CMP.W	#640,(A0)
	BEQ.S	AJ_640
	CMP.W	#480,(A0)
	BEQ.S	AJ_480
	CMP.W	#480-19,(A0)
	BEQ.S	AJ_461

SCONT0:
	ADDQ.L	#2,A0
	CMP.L	A0,A1
	BNE.S	CONT
	
* patching 640

	LEA		BUF640,A0
B640:	
	MOVE.L	(A0)+,A1
	CMP.L	#0,A1
	BEQ.S	PTCH480
	MOVE.W	RES_X,(A1)
	BRA.S	B640

* patching 480

PTCH480:	
	LEA		BUF480,A0
B480:	
	MOVE.L	(A0)+,A1
	CMP.L	#0,A1
	BEQ.S	PTCH461
	MOVE.W	RES_Y,(A1)
	BRA.S	B480
	
* patching 461

PTCH461:
	LEA		BUF461,A0
	MOVE.W	RES_Y,D0
	SUB.W	#19,D0
B461:	
	MOVE.L	(A0)+,A1
	CMP.L	#0,A1
	BEQ.S	FIN
	MOVE.W	D0,(A1)
	BRA.S	B461
	
* end

FIN:
	rts
	
* save into arrays

AJ_640:
	MOVE.L	A0,(A4)+
	BRA.S	SCONT0
AJ_480:
	MOVE.L	A0,(A5)+
	BRA.S	SCONT0
AJ_461:
	MOVE.L	A0,(A6)+
	BRA.S	SCONT0
	
	bss
	
BUF640:	DS.L	200
BUF480:	DS.L	200
BUF461:	DS.L	200
RES_X:	DS.W	1
RES_Y:	DS.W	1

