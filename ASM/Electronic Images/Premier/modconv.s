;-----------------------------------------------------------------------;
; ProTracker Replay (ST/STE)						;
; by Griff of Electronic Images. 30/04/1992				;
;-----------------------------------------------------------------------;

padsize		EQU 650

go		LEA infile(PC),A4
		LEA mt_data,A5
		MOVE.L #1000000,D7
		BSR load_file
		BSR mt_init
		BSR prepare
		LEA outfile(PC),A4
		LEA mt_data,A5
		MOVE.L new_length,D7
		CMP.L #1000000,D7
		BGE.S .skip
		BSR save_file
.skip
		CLR -(SP)
		TRAP #1
; Pad samps.

prepare		movea.l	mt_SampleStarts(PC),A0
		movea.l	end_of_samples(pc),a1
		lea endworkspace,a6	
tostack		move.w	-(a1),-(a6)
		cmpa.l	a0,a1			; Move all samples to stack
		bgt.s	tostack
		LEA	mt_SampleStarts(PC),A2
		LEA.L	mt_data(pc),a1		; Module
		movea.l	(a2),a0			; Start of samples
		movea.l	a0,a5			; Save samplestart in a5
		moveq	#30,d7
roop		move.l	a0,(a2)+		; Sampleposition
		move.l a0,d6
		sub.l #mt_data,d6
		move.l	d6,$26(a1)		; store the sample offset
		tst.w	$2A(a1)
		beq.s	samplok			; Len=0 -> no sample
		tst.w	$2E(a1)			; Test repstrt
		bne.s	repne			; Jump if not zero
repeq		move.w	$2A(a1),d0		; Length of sample
		move.w	d0,d4
		subq.w	#1,d0
		movea.l	a0,a4
fromstk		move.w	(a6)+,(a0)+		; Move all samples back from stack
		dbra	d0,fromstk
		bra.s	rep
repne		move.w	$2E(a1),d0		; repstrt
		move.w	d0,d4
		subq.w	#1,d0
		movea.l	a6,a4
get1st		move.w	(a4)+,(a0)+		; Fetch first part
		dbra	d0,get1st
		adda.w	$2A(a1),a6		; Move a6 to next sample
		adda.w	$2A(a1),a6
rep		movea.l	a0,a5
		moveq	#0,d1
toosmal		movea.l	a4,a3
		move.w	$30(a1),d0
		subq.w	#1,d0
moverep		move.w	(a3)+,(a0)+		; Repeatsample
		addq.w	#2,d1
		dbra	d0,moverep
		cmp.w	#padsize,d1		; Must be > padsize
		blt.s	toosmal
		move.w	#padsize/2-1,d2
.last		move.w	(a5)+,(a0)+		; Safety padsize bytes
		dbra	d2,.last
done		add.w	d4,d4
		move.w	d4,$2A(a1)		; length
		move.w	d1,$30(a1)		; Replen
		clr.w	$2E(a1)
samplok		lea	$1E(a1),a1
		dbra	d7,roop
		CLR.L (A0)+
		SUB.L #mt_data,A0
		MOVE.L A0,new_length
		rts

new_length	DC.L 0
end_of_samples	DC.L 0

mt_init	lea.l mt_data(pc),A0
	MOVE.L	A0,A1
	LEA	952(A1),A1
	MOVEQ	#127,D0
	MOVEQ	#0,D1
mtloop	MOVE.L	D1,D2
	SUBQ.W	#1,D0
mtloop2	MOVE.B	(A1)+,D1
	CMP.B	D2,D1
	BGT.S	mtloop
	DBRA	D0,mtloop2
	ADDQ.B	#1,D2
	LEA	mt_SampleStarts(PC),A1
	ASL.L	#8,D2
	ASL.L	#2,D2
	ADD.L	#1084,D2
	ADD.L	A0,D2
	MOVE.L	D2,A2
	MOVEQ	#30,D0
mtloop3	CLR.L	(A2)
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	42(A0),D1
	ASL.L	#1,D1
	ADD.L	D1,A2
	ADD.L	#30,A0
	DBRA	D0,mtloop3
	MOVE.L A2,end_of_samples
	RTS

mt_SampleStarts	ds.l 31

; Load a file of D7 bytes, Filename at A4 into address A5.

Load_file	MOVE #2,-(SP)
		MOVE.L A4,-(SP)
		MOVE #$3D,-(SP)
		TRAP #1
		ADDQ.L #8,SP
		MOVE D0,D4
.read		MOVE.L A5,-(SP)
		MOVE.L D7,-(SP)
		MOVE D4,-(SP)
		MOVE #$3F,-(SP)
		TRAP #1
		LEA 12(SP),SP
.close		MOVE D4,-(SP)
		MOVE #$3E,-(SP)
		TRAP #1
		ADDQ.L #4,SP
		RTS

* Save a file of D7 bytes, Filename at A4 at address A5.

Save_file	MOVE #0,-(SP)
		PEA (A4)
		MOVE #$3C,-(SP)
		TRAP #1
		ADDQ.L #8,SP
		MOVE D0,D4
.write		MOVE.L A5,-(SP)
		MOVE.L D7,-(SP)
		MOVE D4,-(SP)
		MOVE #$40,-(SP)
		TRAP #1
		LEA 12(SP),SP
.close		MOVE D4,-(SP)
		MOVE #$3E,-(SP)
		TRAP #1
		ADDQ.L #4,SP
		RTS

infile		DC.B "D:\VERT_MAY.HEM\SYMPATHY.MOD",0
		EVEN
outfile		DC.B "D:\VERT_MAY.HEM\SYMPATHY.MOP",0
		EVEN

		section bss

mt_data:	ds.b 256000
workspace	ds.b 256000
endworkspace	
