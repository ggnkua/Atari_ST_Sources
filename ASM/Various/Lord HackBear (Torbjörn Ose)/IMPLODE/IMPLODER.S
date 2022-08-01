;
; File Imploder, Atari version by Torbjorn 'Hackbear' Ose
;                another Digital Chaos hack for you.
;
; based on an Amiga binary from Claude who said this was a good packer
; however some tests showed that it's not as good as Atomic or Ice
; but it depacks fast and in it's own space.  
;
; so i've decided not to waste much time on this, but instead release it
; as it is with source and all..
;
;

	opt	d-,o+

	move.l	4(a7),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)	; mshrink
	trap	#1
	lea	12(a7),a7

	pea	MyDta(pc)
	move.w	#$1a,-(a7)	; Set DTA
	trap	#1
	addq.l	#6,a7


;
; Parse command line (a5 + 128)
;
	lea	exeflag(pc),a0
	move.w	#11,(a0)	; exe off, mode 11 default
	
	lea	129(a5),a5
	lea	MyPath(pc),a6
parsel	move.b	(a5)+,(a6)+
	bne.s	parsel

	bsr	chkfile
	cmp.w	#1,d0
	bne.s	NoIm
	lea	DepackTxt(pc),a0
	bsr	YesNo
	bne.s	Exit
	bsr	do_depack
	bra.s	Exit
NoIm	cmp.w	#2,d0
	bne.s	NoE
	lea	ExecutableTxt(pc),a0
	bsr	YesNo
	bne.s	NoE
	lea	exeflag(pc),a0
	st	(a0)
NoE	bsr.s	do_pack

Exit	clr.w	-(a7)
	trap	#1
;
; Pack a file
;	
do_pack
	bsr	fsfirst
	bmi.s	Exit
	bsr	alloc
	bmi.s	Exit
	bsr	fopen
	move.l	faddr(pc),a0
	move.l	dta_len(pc),d0
	bsr	fread
	bsr	fclose

	move.l	faddr(pc),a0
	move.l	a0,a2
	move.l	dta_len(pc),d0
	moveq	#1,d1
	ror.l	#1,d1
	move.b	pckmode(pc),d1
	swap	d1
	bclr	#7,d1
	Bsr	Implode
	lea	psize(pc),a0
	move.l	d0,(a0)
	
	bsr	fcreate
	move.b	exeflag(pc),d0
	beq.s	nohead
	lea	ExeHeader(pc),a0
	move.l	#ExeEnd-ExeHeader,d0
	lea	SegText(pc),a1
	moveq	#32,d1
	add.l	psize(pc),d1
	add.l	d0,d1
	move.l	d1,(a1)
	bsr	fwrite
nohead	move.l	faddr(pc),a0
	move.l	psize(pc),d0
	bsr.s	fwrite
	move.b	exeflag(pc),d0
	beq.s	nohead2
	lea	Blank(pc),a0
	moveq	#4,d0
	bsr.s	fwrite
nohead2	bsr	fclose
	rts
;
;
;

do_depack
	move.l	orglen(pc),d0
	add.l	#1024,d0
	bsr	alloc
	bmi	Exit
	bsr.s	fsfirst
	bmi	Exit
	bsr.s	fopen
	move.l	faddr(pc),a0
	move.l	dta_len(pc),d0
	bsr.s	fread
	bsr.s	fclose

	lea	faddr(pc),a1
	move.l	(a1),a0
	cmp.w	#$601a,(a0)
	bne.s	noprog
	lea	ExeEnd-ExeHeader(a0),a0
	move.l	a0,(a1)
noprog	bsr	Explode_Data

	bsr.s	fcreate
	move.l	faddr(pc),a0
	move.l	orglen(pc),d0
	bsr.s	fwrite
	bsr.s	fclose
	rts


;
; Boring but essential routs, file handling etc..
;
fsfirst	clr.w	-(a7)
	pea	MyPath(pc)
	move.w	#$4e,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.w	d0
	bne.s	fsferr
	move.l	dta_len(pc),d0	; return file lenght if found
fsfx	tst.l	d0
	rts
fsferr	moveq	#-1,d0		; otherwise negative error message
	bra.s	fsfx

fwrite	move.l	a0,-(a7)	; addr
	move.l	d0,-(a7)	; size
	move.w	d7,-(a7)	; handle
	move.w	#$40,-(a7)
	trap	#1
	lea	12(a7),a7
	rts
fread	move.l	a0,-(a7)	; addr
	move.l	d0,-(a7)	; size
	move.w	d7,-(a7)	; handle
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7
	rts
fclose	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
fopen	clr.w	-(a7)
	pea	MyPath(pc)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7
	move.w	d0,d7
	rts
fcreate	clr.w	-(a7)
	pea	MyPath(pc)
	move.w	#$3c,-(a7)
	trap	#1
	addq.l	#8,a7
	move.w	d0,d7
	rts
alloc	move.l	d0,-(a7)
	move.w	#$48,-(a7)
	trap	#1
	addq.l	#6,a7
	lea	faddr(pc),a0
	move.l	d0,(a0)
	tst.l	d0
	rts

chkfile	bsr.s	fopen
	lea	ChkBuff(pc),a0
	move.l	#ExeEnd-ExeHeader+12,d0
	bsr.s	fread
	bsr.s	fclose
	moveq	#0,d0
	lea	ChkBuff(pc),a0
	cmp.l	#'IMP!',(a0)
	bne.s	noimp
	move.l	4(a0),-4(a0)
	moveq	#1,d0
noimp	cmp.l	#'IMP!',ExeEnd-ExeHeader(a0)
	bne.s	noimp2
	move.l	ExeEnd-ExeHeader+4(a0),-4(a0)
	moveq	#1,d0
	bra.s	noex
noimp2	cmp.w	#$601a,(a0)
	bne.s	noex
	moveq	#2,d0
noex	rts

YesNo	move.l	a0,-(a7)
	move.w	#9,-(a7)
	trap	#1
	move.w	#7,-(a7)
	trap	#1
	addq.l	#8,a7
	or.w	#$20,d0
	cmp.b	#'y',d0
	rts
;
;
;


;
; Packer routs
;


Malloc	movem.l	d1-a6,-(a7)
	move.l	d0,-(a7)
	move.l	d0,-(a7)
	move.w	#$48,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,a0
	move.l	(a7)+,d1	; size
.clsl	clr.b	(a0)+
	subq.l	#1,d1
	bne.s	.clsl
	movem.l	(a7)+,d1-a6
	rts
MemFree	movem.l	d0-a6,-(a7)
	move.l	a1,-(a7)
	move.w	#$49,-(a7)
	trap	#1
	addq.l	#6,a7
	movem.l	(a7)+,d0-a6
	rts

GetMem	movem.l	d1-a6,-(a7)
	move.l	#$40000,d0
	bsr.s	Malloc
	move.l	d0,32(a6)
	beq	GotNMem
	move.l	28(a6),d2
	lsl.l	#3,d2
	sub.l	a2,a2
.gm1	move.l	#$800,d0
	sub.l	d0,d2
	bpl.s	.gm2
	add.l	d2,d0
	moveq	#0,d2
.gm2	addq.l	#8,d0
	move.l	d0,d1
	bsr.s	Malloc
	tst.l	d0
	beq.s	GotNMem
	move.l	d0,36(a6)
	move.l	d0,a0
	move.l	d1,(a0)
	move.l	a2,4(a0)
	move.l	a0,a2
	tst.l	d2
	bne.s	.gm1
	MOVEA.L	32(A6),A0
	MOVEA.L	12(A6),A1
	ADDA.L	28(A6),A1
	MOVEA.L	36(A6),A2
L0085	MOVEA.L	A2,A3
	ADDA.L	(A3),A3
	ADDQ.W	#8,A2
L0086	MOVEQ	#0,D0
	MOVE.B	-1(A1),D0
	LSL.W	#8,D0
	MOVE.B	(A1),D0
	LSL.L	#2,D0
	MOVE.L	0(A0,D0.L),D1
	BEQ.S	L0087
	MOVEA.L	D1,A4
	MOVE.L	A1,-(A3)
	MOVE.L	(A4),-(A3)
	MOVE.L	A3,(A4)
	BRA.S	L0088
L0087	MOVE.L	A1,-(A3)
	SUBQ.L	#4,A3
	MOVE.L	A3,(A3)
	MOVE.L	A3,0(A0,D0.L)
L0088	SUBQ.L	#1,A1
	CMPA.L	A2,A3
	BHI.S	L0086
	MOVEA.L	-(A2),A2
	MOVE.L	A2,D0
	BNE.S	L0085
	MOVEQ	#-1,D0
GetMemX	movem.l	(a7)+,d1-a6
	tst.l	d0
	rts
GotNMem	moveq	#0,d0
	bra.s	GetMemX

FreeMem	movem.l	d0-a6,-(a7)
	move.l	32(a6),d0
	beq.s	.fm1
	move.l	d0,a1
	bsr	MemFree
.fm1	move.l	36(a6),a2
.fml	move.l	a2,d0
	beq.s	.fmx
	move.l	4(a2),a1
	exg	a1,a2
	bsr	MemFree
	bra.s	.fml
.fmx	clr.l	36(a6)
	clr.l	32(a6)
	movem.l	(a7)+,d0-a6
	rts


L008F	MOVE.L	16(A6),D5
	MOVEA.L	44(A6),A5
	MOVEQ	#1,D7
	MOVEA.L	32(A6),A3
	MOVEQ	#0,D0
	MOVE.B	(A5)+,D0
	LSL.W	#8,D0
	MOVE.B	(A5)+,D0
	LSL.L	#2,D0
	MOVE.B	(A5),D3
	ADDA.L	D0,A3
	MOVEA.L	(A3),A0
	MOVEA.L	(A0),A4
	MOVE.L	A4,40(A6)
	CMPA.L	A0,A4
	BNE.S	L0090
	CLR.L	(A3)
	BRA.s	L0096
L0090	MOVEA.L	(A4),A4
	MOVE.L	A4,(A0)
	MOVE.L	A4,D4
	LEA	70(A6),A3
	CLR.L	-(A3)
	CLR.L	-(A3)
	BRA.S	L0092
L0091	MOVEA.L	(A4),A4
	CMP.L	A4,D4
	BEQ.S	L0096
L0092	MOVEA.L	4(A4),A2
	LEA	1(A2),A1
	CMP.B	(A1)+,D3
	BNE.S	L0094
	LEA	1(A5),A0
	MOVE.W	#$FC,D0
L0093	CMPM.B	(A0)+,(A1)+
	DBNE	D0,L0093
	CMPA.L	D5,A1
	BLS.S	L0094
	MOVEA.L	D5,A1
L0094	MOVE.L	A1,D6
	SUB.L	A2,D6
	CMP.W	D6,D7
	BCC.S	L0091
	MOVE.W	D6,D7
	CMP.W	#8,D6
	BHI.S	L0095
	TST.B	-2(A3,D6.W)
	BNE.S	L0091
	MOVE.B	D6,-2(A3,D6.W)
	MOVE.L	A2,D0
	SUB.L	A5,D0
	MOVE.W	D6,D1
	LSL.W	#2,D1
	MOVE.L	D0,0(A3,D1.W)
	BRA.S	L0091
L0095	MOVE.B	D6,7(A3)
	MOVE.L	A2,D0
	SUB.L	A5,D0
	MOVE.L	D0,36(A3)
	CMP.B	#-1,D6
	BNE.S	L0091
L0096	ADDA.L	28(A6),A5
	CMPA.L	D5,A5
	BCC.S	L0098
	SUBQ.L	#2,A5
	MOVEA.L	32(A6),A0
	MOVEA.L	40(A6),A1
	MOVEQ	#0,D0
	MOVE.B	(A5)+,D0
	LSL.W	#8,D0
	MOVE.B	(A5),D0
	LSL.L	#2,D0
	MOVE.L	A5,4(A1)
	ADDA.L	D0,A0
	MOVE.L	(A0),D1
	BEQ.S	L0097
	MOVE.L	A1,(A0)
	MOVEA.L	D1,A0
	MOVE.L	(A0),(A1)
	MOVE.L	A1,(A0)
	SUBQ.B	#1,D7
	RTS
L0097	MOVE.L	A1,(A0)
	MOVE.L	A1,(A1)
L0098	SUBQ.B	#1,D7
	RTS

L0099	MOVEA.L	44(A6),A5
	MOVE.L	16(A6),D5
	MOVE.L	A5,D0
	ADD.L	28(A6),D0
	CMP.L	D5,D0
	BLS.S	L009A
	MOVE.L	D5,D0
L009A	MOVE.L	D0,D4
	MOVEA.L	A5,A2
	ADDQ.L	#1,A2
	MOVEA.L	A2,A4
	MOVEQ	#1,D7
	MOVE.B	(A5),D3
	LEA	70(A6),A3
	CLR.L	-(A3)
	CLR.L	-(A3)
L009B	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.B	(A2)+,D3
	BEQ.S	L009D
	CMP.L	A2,D4
	BHI.S	L009B
L009C	RTS
L009D	CMP.L	A2,D4
	BLS.S	L009C
	MOVEA.L	A4,A0
	MOVEA.L	A2,A1
	CMPM.B	(A0)+,(A1)+
	BNE.S	L009B
	CMPM.B	(A0)+,(A1)+
	BNE.S	L00A0
	CMPM.B	(A0)+,(A1)+
	BNE.S	L009F
	MOVE.W	#$FB,D0
L009E	CMPM.B	(A0)+,(A1)+
	DBNE	D0,L009E
L009F	CMPA.L	D5,A1
	BLS.S	L00A0
	MOVEA.L	D5,A1
L00A0	MOVE.L	A1,D6
	SUB.L	A2,D6
	CMP.W	D6,D7
	BCC.S	L009B
	MOVE.W	D6,D7
	CMP.W	#8,D6
	BHI.S	L00A1
	TST.B	-2(A3,D6.W)
	BNE.S	L009B
	MOVE.B	D6,-2(A3,D6.W)
	MOVE.L	A2,D0
	SUB.L	A5,D0
	SUBQ.L	#2,D0
	MOVE.W	D6,D1
	LSL.W	#2,D1
	MOVE.L	D0,0(A3,D1.W)
	BRA	L009B
L00A1	MOVE.B	D6,7(A3)
	MOVE.L	A2,D0
	SUB.L	A5,D0
	SUBQ.L	#2,D0
	MOVE.L	D0,36(A3)
	CMP.B	#-1,D6
	BNE	L009B
	RTS

L00A2	MOVE.B	54(A6),D2
	MOVE.B	55(A6),D3
	MOVEA.L	48(A6),A0
L00A3	LSR.L	#1,D1
	ROXR.B	#1,D2
	SUBQ.B	#1,D3
	BPL.S	L00A4
	MOVEQ	#7,D3
	MOVE.B	D2,(A0)+
	MOVEQ	#0,D2
L00A4	SUBQ.B	#1,D0
	BNE.S	L00A3
	MOVE.L	A0,48(A6)
	MOVE.B	D3,55(A6)
	MOVE.B	D2,54(A6)
	RTS

L00A5	ANDI.W	#$FF,D0
	CMP.B	#$D,D0
	BHI.S	L00A7
	CMP.B	#5,D0
	BHI.S	L00A6
	LEA	L007D(PC),A0
	ADDA.W	D0,A0
	MOVE.B	-2(A0),123(A6)
	MOVE.B	2(A0),115(A6)
	BRA.S	L00A9
L00A6	SUBQ.B	#6,D0
	ORI.B	#-$10,D0
	MOVE.B	D0,123(A6)
	MOVE.B	#8,115(A6)
	BRA.S	L00A8
L00A7	MOVE.B	#$1F,122(A6)
	MOVE.B	D0,123(A6)
	MOVE.B	#$D,115(A6)
L00A8	MOVEQ	#5,D0
L00A9	SUBQ.B	#2,D0
	MOVE.L	58(A6),D2
	LEA	L007C(PC),A1
	LEA	L007B(PC),A0
	ADDA.W	D0,A0
	ADDA.W	D0,A0
	CMP.W	(A0),D2
	BCC.S	L00AA
	MOVE.B	0(A1,D0.W),D6
	MOVE.B	D6,D3
	ADDQ.B	#1,D3
	MOVE.B	#0,125(A6)
	MOVEQ	#0,D4
	BRA.S	L00AD
L00AA	CMP.W	8(A0),D2
	BCC.S	L00AB
	MOVE.B	4(A1,D0.W),D6
	MOVE.B	D6,D3
	ADDQ.B	#2,D3
	MOVE.B	#2,125(A6)
	MOVE.W	(A0),D4
	BRA.S	L00AD
L00AB	CMP.W	16(A0),D2
	BCS.S	L00AC
	MOVEQ	#0,D0
	RTS
L00AC	MOVE.B	8(A1,D0.W),D6
	MOVE.B	D6,D3
	ADDQ.B	#2,D3
	MOVE.B	#3,125(A6)
	MOVE.W	8(A0),D4
L00AD	MOVE.B	D3,116(A6)
	SUB.W	D4,D2
	MOVEQ	#$10,D5
	SUB.B	D6,D5
	LSL.W	D5,D2
L00AE	ADD.W	D2,D2
	ROXL	124(A6)
	SUBQ.B	#1,D6
	BNE.S	L00AE
	LEA	174(A6),A1
	LEA	126(A6),A0
	ADDA.W	D0,A0
	ADDA.W	D0,A0
	ADDA.W	D0,A0
	ADDA.W	D0,A0
	CMP.L	(A0),D1
	BCC.S	L00AF
	MOVE.B	0(A1,D0.W),D6
	MOVE.B	D6,D3
	ADDQ.B	#1,D3
	MOVEQ	#0,D7
	MOVEQ	#0,D4
	BRA.S	L00B2
L00AF:
	CMP.L	16(A0),D1
	BCC.S	L00B0
	MOVE.B	4(A1,D0.W),D6
	MOVE.B	D6,D3
	ADDQ.B	#2,D3
	MOVEQ	#2,D7
	MOVE.L	(A0),D4
	BRA.S	L00B2
L00B0	CMP.L	32(A0),D1
	BCS.S	L00B1
	MOVEQ	#0,D0
	RTS
L00B1	MOVE.B	8(A1,D0.W),D6
	MOVE.B	D6,D3
	ADDQ.B	#2,D3
	MOVEQ	#3,D7
	MOVE.L	16(A0),D4
L00B2	MOVE.B	D3,114(A6)
	SUB.L	D4,D1
	MOVEQ	#$20,D5
	SUB.B	D6,D5
	LSL.L	D5,D1
L00B3	ADD.L	D1,D1
	ADDX.L	D7,D7
	SUBQ.B	#1,D6
	BNE.S	L00B3
	MOVE.L	D7,118(A6)
	MOVEQ	#-1,D0
	RTS

L00B4	CLR.W	52(A6)
	CLR.W	56(A6)
	LEA	62(A6),A2
	LEA	70(A6),A3
L00B5	MOVE.L	(A3)+,D1
	MOVE.B	(A2)+,D0
	BEQ.S	L00B7
	BSR	L00A5
	BEQ.S	L00B7
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	-1(A2),D0
	LSL.W	#3,D0
	ADD.B	115(A6),D1
	ADD.B	114(A6),D1
	ADD.B	116(A6),D1
	SUB.W	D1,D0
	BMI.S	L00B7
	CMP.W	52(A6),D0
	BCS.S	L00B7
	MOVE.W	D0,52(A6)
	MOVE.B	-1(A2),57(A6)
	LEA	102(A6),A0
	LEA	114(A6),A1
	MOVEQ	#$B,D1
L00B6	MOVE.B	(A1)+,(A0)+
	DBF	D1,L00B6
L00B7	MOVE.L	A2,D0
	SUB.L	A6,D0
	CMP.W	#$46,D0
	BNE.S	L00B5
	TST.W	56(A6)
	RTS

;pack
;regs: - 
;a0= fileptr
;a1= donecode=0
;a2= fileptr
;a5= lib ptr.
;d0= size
;d1= mode 0-11
;
;


Implode	MOVEM.L	A2-A6/D2-D7,-(A7)
	MOVE.W	#$5C,D2
L00B9	CLR.W	-(A7)
	DBF	D2,L00B9
	MOVE.L	A7,A6
	MOVE.L	A5,4(A6)
	CMP.L	#$40,D0
	BCS	L00D9
	LSR.L	#8,D1
	SCS	(A6)
	LSR.L	#8,D1
	SCS	1(A6)
	CMP.B	#$C,D1
	BCS.S	L00BA
	MOVEQ	#0,D1
L00BA
	MOVE.L	A0,12(A6)
	MOVE.L	A0,44(A6)
	MOVE.L	A0,48(A6)
	MOVE.L	D0,20(A6)
	ADDA.L	D0,A0
	MOVE.L	A0,16(A6)

	LEA	L007E(PC),A0
	LSL.W	#2,D1
	MOVE.L	0(A0,D1.W),D1
	ADDQ.L	#1,D1
	CMP.L	D0,D1
	BLS.S	L00BB
	MOVE.L	D0,D1
	SUBQ.L	#1,D1
L00BB	MOVE.L	D1,28(A6)
	SUBQ.L	#1,D1
	MOVEQ	#0,D0
L00BC	CMP.L	(A0)+,D1
	BLS.S	L00BD
	ADDQ.B	#1,D0
	BRA.S	L00BC
L00BD	MOVE.B	D0,2(A6)
	LEA	174(A6),A1
	MOVEQ	#$C,D1
	MULU	D1,D0
	LEA	L007F(PC),A0
	ADDA.L	D0,A0
	SUBQ.W	#1,D1
L00BE	MOVE.B	(A0)+,(A1)+
	DBF	D1,L00BE
	LEA	126(A6),A1
	LEA	174(A6),A0
	MOVEQ	#$B,D1
L00BF	MOVE.B	(A0)+,D0
	MOVEQ	#0,D2
	BSET	D0,D2
	MOVE.L	D2,(A1)+
	DBF	D1,L00BF
	LEA	126(A6),A0
	LEA	142(A6),A1
	MOVEQ	#7,D1
L00C0	MOVE.L	(A0)+,D0
	ADD.L	D0,(A1)+
	DBF	D1,L00C0
	TST.B	(A6)
	BEQ.S	L00C3
	LEA	126(A6),A1
	MOVEQ	#7,D0
L00C1	MOVE.L	(A1)+,D1
	MOVE.W	D1,(A2)+
	DBF	D0,L00C1
	LEA	174(A6),A1
	MOVEQ	#$B,D0
L00C2	MOVE.B	(A1)+,(A2)+
	DBF	D0,L00C2
L00C3:
	MOVE.B	#7,55(A6)
	TST.B	1(A6)
	BEQ.S	L00C4
	BSR	GetMem
	BNE.S	L00C4
	SF	1(A6)
	BSR	FreeMem
L00C4	MOVE.L	16(A6),D0
	SUBQ.L	#2,D0
	CMP.L	44(A6),D0
	BLS	L00D1
	TST.B	1(A6)
	BNE.S	L00C5
	BSR	L0099
	BRA.S	L00C6
L00C5	BSR	L008F
	BEQ.S	L00C7
L00C6	BSR	L00B4
	BNE.S	L00C8
L00C7	MOVEA.L	44(A6),A0
	MOVEA.L	48(A6),A1
	MOVE.B	(A0),(A1)
	ADDQ.L	#1,44(A6)
	ADDQ.L	#1,48(A6)
	ADDQ.L	#1,58(A6)
	CMPI.L	#$4012,58(A6)
	BCS.S	L00C4
	BRA	L00D1
L00C8	CLR.L	58(A6)
	TST.B	1(A6)
	BEQ.S	L00CF
	MOVEA.L	44(A6),A2
	ADDQ.L	#1,A2
	MOVEA.L	A2,A3
	ADDA.L	28(A6),A3
	MOVE.W	56(A6),D3
	SUBQ.W	#1,D3
	MOVE.L	16(A6),D2
	SUB.L	A3,D2
	SUBQ.L	#1,D2
	BPL.S	L00C9
	MOVEQ	#0,D2
L00C9	MOVEA.L	32(A6),A4
	MOVEQ	#0,D0
	MOVE.B	(A2)+,D0
	LSL.W	#8,D0
	MOVE.B	(A2),D0
	LSL.L	#2,D0
	ADDA.L	D0,A4
	MOVEA.L	(A4),A0
	MOVEA.L	(A0),A5
	CMPA.L	A0,A5
	BNE.S	L00CA
	CLR.L	(A4)
	BRA.S	L00CB
L00CA	MOVE.L	(A5),(A0)
L00CB	SUBQ.L	#1,D2
	BMI.S	L00CE
	SUBA.L	D0,A4
	MOVEQ	#0,D0
	MOVE.B	(A3)+,D0
	LSL.W	#8,D0
	MOVE.B	(A3),D0
	LSL.L	#2,D0
	ADDA.L	D0,A4
	MOVE.L	A3,4(A5)
	MOVE.L	(A4),D1
	BEQ.S	L00CC
	MOVEA.L	D1,A0
	MOVE.L	(A0),(A5)
	MOVE.L	A5,(A0)
	BRA.S	L00CD
L00CC	MOVE.L	A5,(A5)
L00CD	MOVE.L	A5,(A4)
L00CE	SUBQ.W	#1,D3
	BNE.S	L00C9
L00CF	MOVE.W	56(A6),D0
	EXT.L	D0
	ADD.L	D0,44(A6)
	MOVE.B	102(A6),D0
	MOVE.L	106(A6),D1
	BSR	L00A2
	MOVE.B	104(A6),D0
	MOVE.W	112(A6),D1
	BSR	L00A2
	MOVE.B	103(A6),D0
	MOVE.W	110(A6),D1
	CMP.B	#$D,D0
	BNE.S	L00D0
	MOVEA.L	48(A6),A0
	MOVE.B	D1,(A0)
	ADDQ.L	#1,48(A6)
	MOVEQ	#5,D0
	MOVEQ	#$1F,D1
L00D0	BSR	L00A2
	BRA	L00C4

L00D1
	MOVEA.L	44(A6),A0
	MOVEA.L	48(A6),A1
	MOVE.B	(A0),(A1)
	ADDQ.L	#1,44(A6)
	ADDQ.L	#1,48(A6)
	ADDQ.L	#1,58(A6)
	MOVE.L	44(A6),D0
	CMP.L	16(A6),D0
	BNE.S	L00D1
	TST.B	(A6)
	BNE	L00D5
	MOVE.L	48(A6),D0
	SUB.L	12(A6),D0
	CMP.L	#$C,D0
	BCS	L00D9
	MOVE.L	20(A6),D1
	SUB.L	D0,D1
	CMP.L	#$36,D1
	BLS	L00D9
	MOVEA.L	12(A6),A1
	MOVEA.L	48(A6),A0
	MOVE.L	#$FF00,D7
	BTST	#0,D0
	BEQ.S	L00D2
	MOVEQ	#0,D7
	ADDQ.L	#1,D0
	CLR.B	(A0)+
L00D2	MOVE.L	(A1),8(A0)
	MOVE.L	#$494D5021,(A1)
	MOVE.L	4(A1),4(A0)
	MOVE.L	20(A6),4(A1)
	MOVE.L	8(A1),(A0)
	MOVE.L	D0,8(A1)
	ADDI.L	#$2E,D0
	MOVE.L	D0,24(A6)
	MOVE.L	58(A6),12(A0)
	MOVE.B	54(A6),D1
	ANDI.W	#$FE,D1
	MOVE.B	55(A6),D0
	BSET	D0,D1
	OR.W	D7,D1
	MOVE.W	D1,16(A0)
	LEA	126(A6),A1
	ADDA.W	#$12,A0
	MOVEQ	#7,D0
L00D3	MOVE.L	(A1)+,D1
	MOVE.W	D1,(A0)+
	DBF	D0,L00D3
	LEA	174(A6),A1
	MOVEQ	#$B,D0
L00D4	MOVE.B	(A1)+,(A0)+
	DBF	D0,L00D4
	BRA.S	L00D9
L00D5	MOVE.L	48(A6),D0
	SUB.L	12(A6),D0
	MOVE.L	20(A6),D1
	SUB.L	D0,D1
	CMP.L	#6,D1
	BLS.S	L00D9
	MOVE.B	54(A6),D1
	ANDI.B	#-2,D1
	MOVE.B	55(A6),D2
	BSET	D2,D1
	MOVEA.L	48(A6),A0
	BTST	#0,D0
	BEQ.S	L00D6
	MOVE.B	D1,(A0)+
	MOVE.L	58(A6),(A0)
	BRA.S	L00D7
L00D6	MOVE.L	58(A6),(A0)+
	MOVE.B	D1,(A0)
L00D7	ADDQ.L	#5,D0
	MOVE.L	D0,24(A6)
	BRA.S	L00D9
L00D8	MOVEQ	#-1,D0
	BRA.S	L00DA
L00D9	MOVE.L	24(A6),D0
L00DA	MOVEM.L	D0,-(A7)
	BSR	FreeMem
	MOVEM.L	(A7)+,D0
	MOVE.W	#$5C,D2
L00DB	CLR.W	(A7)+
	DBF	D2,L00DB
	MOVEM.L	(A7)+,A2-A6/D2-D7
	TST.L	D0
	RTS

;
; Executable Header (mostly stolen from Ice Packer)
;
ExeHeader
	dc.w	$601a
SegText	dcb.l	3,0		; text, data, bss
	dcb.w	5,0		; reserved
	dc.w	1		; progflags
	dc.w	-1		; relocflag
	
ExeTop
	lea	ExeEnd(pc),a0
	bsr	Explode_Data
	move.l	a0,a4
	move.l	4(a7),a5
	lea	ExeTop(pc),a6
	lea	28(a4),a3
	movem.l	-26(a3),d0-d3
	lea	0(a3,d0.l),a0
	add.l	d1,a0
	add.l	d3,a0
	move.l	a6,d0
	move.l	(A0)+,D1
	beq.s	ExeRx
	add.l	d1,a3
	moveq	#0,d1
ExeR1	add.l	d0,(a3)
ExeR2	move.b	(a0)+,d1
	beq.s	ExeRx
	cmp.b	#1,d1
	bne.s	ExeR3
	lea	$fe(a3),a3
	bra.s	ExeR2
ExeR3	add.l	d1,a3
	bra.s	ExeR1
ExeRx	lea	2(a4),a3
	addq.l	#8,a5
	move.l	(a5)+,a2
	moveq	#0,d2
	sub.l	a2,d2
	move.l	(a3),(a5)+
	add.l	(a3)+,a2
	move.l	a2,(a5)+
	move.l	(a3),(a5)+
	add.l	(a3)+,a2
	add.l	a2,d2
	move.l	a2,(a5)+
	move.l	(a3),(a5)+
	add.l	(a3)+,a2
	lea	710(a2),a2
	movem.l	ExeMov(pc),a3/a0-a1/d3-d5/d0-d1
	movem.l	a3/a0-a1/d3-d5/d0-d1,(a2)
	lea	28(a4),a1
	lsr.l	#3,d2
	move.l	a6,a3
	jmp	(a2)

ExeMov	move.l	(a1)+,(a3)+
	move.l	(a1)+,(a3)+
	subq.l	#1,d2
	bpl.s	ExeMov
	move.l	-232(a6),a3
	move.l	-228(a6),d1
	lsr.l	#3,d1
	sub.l	a0,a0
ExeMov2	move.l	a0,(a3)+
	move.l	a0,(a3)+
	subq.l	#1,d1
	bpl.s	ExeMov2
	jmp	(a6)

;
;
;
**********************************************************************
* Data Exploder  a0 = Source/Dest Buffer (must be size of dest!)
*                          Resource by GROO 1990
**********************************************************************
Explode_Data	movem.l	d0-d5/a0-a4,-(sp)
		move.l	a0,a3
		move.l	a0,a4
		cmp.l	#"IMP!",(a0)+
		bne.s	NotImplDataErr
		add.l	(a0)+,a4
		add.l	(a0)+,a3
		move.l	a3,a2
		move.l	(a2)+,-(a0)
		move.l	(a2)+,-(a0)
		move.l	(a2)+,-(a0)
		move.l	(a2)+,d2
		move.w	(a2)+,d3
		bmi.s	.1
		subq.l	#1,a3
.1		lea	-$001C(sp),sp
		move.l	sp,a1
		moveq.l	#6,d0
.2		move.l	(a2)+,(a1)+
		dbra	d0,.2
		move.l	sp,a1
		moveq.l	#0,d4
Expl1		tst.l	d2
		beq.s	.3
.4		move.b	-(a3),-(a4)
		subq.l	#1,d2
		bne.s	.4
.3		cmp.l	a4,a0
		bcs.s	Expl2
		lea	$001C(sp),sp
		moveq.l	#-1,d0
		cmp.l	a3,a0
		beq.s	Expl_Exit
NotImplDataErr	moveq.l	#0,d0
Expl_Exit	movem.l	(sp)+,d0-d5/a0-a4
		rts		; d0 = 0 = error
 
Expl2		add.b	d3,d3
		bne.s	.1
		move.b	-(a3),d3
		addx.b	d3,d3
.1		bcc.s	Expl3
		add.b	d3,d3
		bne.s	.2
		move.b	-(a3),d3
		addx.b	d3,d3
.2		bcc.s	Expl4
		add.b	d3,d3
		bne.s	.3
		move.b	-(a3),d3
		addx.b	d3,d3
.3		bcc.s	Expl5
		add.b	d3,d3
		bne.s	.4
		move.b	-(a3),d3
		addx.b	d3,d3
.4		bcc.s	Expl6
		add.b	d3,d3
		bne.s	.5
		move.b	-(a3),d3
		addx.b	d3,d3
.5		bcc.s	.6
		move.b	-(a3),d4
		moveq.l	#3,d0
		bra.s	Expl7
 
.6		add.b	d3,d3
		bne.s	.7
		move.b	-(a3),d3
		addx.b	d3,d3
.7		addx.b	d4,d4
		add.b	d3,d3
		bne.s	.8
		move.b	-(a3),d3
		addx.b	d3,d3
.8		addx.b	d4,d4
		add.b	d3,d3
		bne.s	.9
		move.b	-(a3),d3
		addx.b	d3,d3
.9		addx.b	d4,d4
		addq.b	#6,d4
		moveq.l	#3,d0
		bra.s	Expl7
 
Expl6		moveq.l	#5,d4
		moveq.l	#3,d0
		bra.s	Expl7
 
Expl5		moveq.l	#4,d4
		moveq.l	#2,d0
		bra.s	Expl7
 
Expl4		moveq.l	#3,d4
		moveq.l	#1,d0
		bra.s	Expl7
 
Expl3		moveq.l	#2,d4
		moveq.l	#0,d0
Expl7		moveq.l	#0,d5
		move.w	d0,d1
		add.b	d3,d3
		bne.s	.1
		move.b	-(a3),d3
		addx.b	d3,d3
.1		bcc.s	.4
		add.b	d3,d3
		bne.s	.2
		move.b	-(a3),d3
		addx.b	d3,d3
.2		bcc.s	.3
		move.b	Expl_Tab1(pc,d0.w),d5
		addq.b	#8,d0
		bra.s	.4
 
.3		moveq.l	#2,d5
		addq.b	#4,d0
.4		move.b	Expl_Tab2(pc,d0.w),d0
.5		add.b	d3,d3
		bne.s	.6
		move.b	-(a3),d3
		addx.b	d3,d3
.6		addx.w	d2,d2
		subq.b	#1,d0
		bne.s	.5
		add.w	d5,d2
		moveq.l	#0,d5
		move.l	d5,a2
		move.w	d1,d0
		add.b	d3,d3
		bne.s	.7
		move.b	-(a3),d3
		addx.b	d3,d3
.7		bcc.s	Expl9
		add.w	d1,d1
		add.b	d3,d3
		bne.s	.8
		move.b	-(a3),d3
		addx.b	d3,d3
.8		bcc.s	Expl8
		move.w	8(a1,d1.w),a2
		addq.b	#8,d0
		bra.s	Expl9
 
Expl8		move.w	0(a1,d1.w),a2
		addq.b	#4,d0
Expl9		move.b	$0010(a1,d0.w),d0
.1		add.b	d3,d3
		bne.s	.2
		move.b	-(a3),d3
		addx.b	d3,d3
.2		addx.l	d5,d5
		subq.b	#1,d0
		bne.s	.1
		addq.w	#1,a2
		add.l	d5,a2
		add.l	a4,a2
.3		move.b	-(a2),-(a4)
		subq.b	#1,d4
		bne.s	.3
		bra	Expl1
 
Expl_Tab1	dc.l	$060A0A12
Expl_Tab2	dc.l	$01010101
		dc.l	$02030304
		dc.l	$0405070E

; =========================================================================

ExeEnd
;
;
;
	data

L007B	DC.B	$00,$02,$00,$02,$00,$02,$00,$02
	DC.B	$00,$06,$00,$0A,$00,$0A,$00,$12
	DC.B	$00,$16,$00,'*',$00,$8A,'@',$12

L007C	DC.B	$01,$01,$01,$01,$02,$03,$03,$04
	DC.B	$04,$05,$07,$0E

L007D	DC.B	$00,$02,$06,$0E,$01,$02,$03,$04

L007E:
	DC.B	$00,$00,$00,$80,$00,$00,$01,$00
	DC.B	$00,$00,$02,$00,$00,$00,$04,$00
	DC.B	$00,$00,$07,$00,$00,$00,$0D,$00
	DC.B	$00,$00,$15,$00,$00,$00,'%',$00
	DC.B	$00,$00,'Q',$00,$00,$00,$92,$00
	DC.B	$00,$01,$09,$00,$00,$01,$09,$00
L007F:
	DC.B	$05,$05,$05,$05,$05,$05,$05,$05
	DC.B	$06,$06,$06,$06,$05,$06,$07,$07
	DC.B	$06,$06,$06,$06,$07,$07,$06,$06
	DC.B	$05,$06,$07,$07,$07,$07,$07,$07
	DC.B	$08,$08,$08,$08,$05,$06,$07,$08
	DC.B	$07,$07,$08,$08,$08,$08,$09,$09
	DC.B	$06,$07,$07,$08,$07,$08,$09,$09
	DC.B	$08,$09,$0A,$0A,$06,$07,$07,$08
	DC.B	$07,$09,$09,$0A,$08,$0A,$0B,$0B
	DC.B	$06,$07,$08,$08,$07,$09,$09,$0A
	DC.B	$08,$0A,$0B,$0C,$06,$07,$08,$08
	DC.B	$07,$09,$09,$0A,$09,$0A,$0C,$0D
	DC.B	$06,$07,$07,$08,$07,$09,$09,$0C
	DC.B	$09,$0A,$0C,$0E,$06,$07,$08,$09
	DC.B	$07,$09,$0A,$0C,$09,$0B,$0D,$0F
	DC.B	$06,$07,$08,$08,$07,$0A,$0B,$0B
	DC.B	$09,$0C,$0D,$10,$06,$08,$08,$09
	DC.B	$07,$0B,$0C,$0C,$09,$0D,$0E,$11

;
;
;
ExecutableTxt	dc.b	'Executable? (y/n)',13,10,0
DepackTxt	dc.b	'Imploder File, Depack? (y/n)',13,10,0
		even
Blank		dc.l	0
	bss
MyDta	ds.b	21	; reserved
dta_att	ds.b	1	; attrib
dta_tim	ds.w	1	; time
dta_dat	ds.w	1	; date
dta_len	ds.l	1	; lenglt
dta_nam	ds.b	14	; name
faddr	ds.l	1	; malloc address for input file
psize	ds.l	1	; packed size
exeflag	ds.b	1	; add exe header?
pckmode	ds.b	1	; packing method 0-11
MyPath	ds.b	512
orglen	ds.l	1	; original length from IMP header
ChkBuff	ds.b	ExeEnd-ExeHeader+12
