;
; Spectrum 512 displayer (at 50Hz).
;

	clr.l	-(sp)		; supervisor
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp
	
	move.b	$ff8201,scrnpos+1
	move.b	$ff8203,scrnpos+2
	
	move.w	#37,-(sp)		; Vsync
	trap	#14
	addq.l	#2,sp

	move.b	#0,$ff8260	; low res
	
	lea	pic(pc),a0	; display picture data
	move.l	scrnpos(pc),a1
	move.w	#1999,d0
copy:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,copy
	
	move.l	#vbl,$4d2		; new vbl routine
	
	move.w	#1,-(sp)		; wait key
	trap	#1
	addq.l	#2,sp
	
	clr.l	$4d2		; remove vbl routine
	
*	clr.w	$ff8240
	
	move.l	oldsp(pc),-(sp)	; user mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)		; quit
	trap	#1


vbl:	TST.W	$43E
	BNE	evbl
	MOVE	SR,-(A7)
	ORI.W	#$700,SR
	LEA	$FF8240,A4
	LEA	$FF8209,A5
	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	LEA	noplist(PC),A6
	LEA	pic+32000+32,A3
	MOVE.W	#$C4,D7
	CLR.L	D0
waits:	TST.B	(A5)
	BEQ.S	waits
	MOVE.B	(A5),D0
	ADDA.L	D0,A6
	JMP	(A6)
noplist:NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
dopal:	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	nop
	nop
	DBF	D7,dopal
	NOP
	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	LEA	-$4A60(A3),A4
	NOP
	NOP
	NOP
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A4)+,(A2)+
	MOVE.L	(A4)+,(A2)+
	MOVE.L	(A4)+,(A2)+
	MOVE.L	(A4)+,(A2)+
	MOVE.L	(A4)+,(A2)+
	MOVE.L	(A4)+,(A2)+
	MOVE.L	(A4)+,(A2)+
	MOVE.L	(A4)+,(A2)+
	MOVE.W	(A7)+,SR
evbl:	RTS


oldsp:	even
	ds.l	1
scrnpos:even
	ds.l	1
pic:	even
	incbin	speccy.spu