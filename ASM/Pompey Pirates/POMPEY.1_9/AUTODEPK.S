* This is the source you'll need to run a program with packed data files.
* Obviously this is only going to be of use with programs that use *REAL*
* files - i.e. gemdos accessed ones. Many programs will use files ok, but
* as soon as you pack them all hell will break loose - I won't go into the
* reasons and solutions here, though I may do in a future doc file...
* Remember that this program is just a patch to run another program which
* is your game/loader/whatever - so you'll have to change the filename on
* line 279 of this source.
yes	equ	1
no	equ	0

* the following line is important: if you want to run another program as
* mentioned above, then leave it set to 'no'. If, however, you want to
* stick it in an AUTO program and leave it in memory, which could save
* diskspace if you have a lot of programs with packed data files on the
* same disk, then set it to 'yes'.

tsr	equ	no

* The new improved Auto-depacker...
* For 1.8/1.9/1.9a-y packed files.
* Any program that picks up the filesize from the DTA after a SFIRST will
* now get the correct; unpacked; length.

	opt	o+,d-,x-

start
	ifeq	tsr
	pea	(end-(start-256)).w	save THIS much
	pea	start-256(pc)	from basepage
	pea	$4a0000	m_shrink with null before it
	trap	#1
	lea	12(sp),sp
	endc
	lea	mystack(pc),sp

	lea	newvector(pc),a0	patch trap #1 vector
	bsr.s	supexec

	ifeq	tsr
	pea	envcom(pc)
	move.l	(sp),-(sp)
	pea	filename(pc)
	pea	$4b0000
	trap	#1
	lea	16(sp),sp
	lea	oldvector(pc),a0
	bsr.s	supexec
	clr.w	-(sp)
	elseif
	clr.w	-(sp)
	pea	(end-(start-256)).w
	move.w	#$31,-(sp)
	endc
	trap	#1

supexec	pea	(a0)
	move.w	#38,-(sp)	run a routine in supervisor mode
	trap	#14
	addq.l	#6,sp
	rts
	
newvector	move.l	$84.w,oldtrap1+2
	move.l	#newtrap1,$84.w
	rts

oldvector	move.l	oldtrap1+2(pc),$84.w
	move.b	#7,$484.w
	rts

* this is where TRAP #1 goes now...

newtrap1	move.l	a0,save_a0
	btst	#5,(sp)		super mode bit set?
	bne.s	super
	move.l	usp,a0		user stack pointer
	bra.s	user

super	lea	6(sp),a0		SSP plus return addr.l and SR.w

user	tst.w	intrap1
	bne.s	dotrap
	cmp.w	#$3f,(a0)		f_read?
	beq.s	fread
	cmp.w	#$4e,(a0)
	bne.s	dotrap
	move.l	2(a0),a0
	cmp.b	#'.',(a0)
	beq.s	dotrap
	move.l	a0,sfirstfile+2
	move.l	2(sp),return+2
	move.l	#resize,2(sp)
	bra.s	dotrap

fread	move.l	8(a0),loadto+2	save file read address
	move.l	2(sp),return+2	save return addr
	move.l	#depack,2(sp)	replace return addr
dotrap	move.l	save_a0(pc),a0
oldtrap1	jmp	0.l	becomes JMP <old trap #1 vector>


resize	movem.l	d0-d7/a0-a6,regs
	move.l	d0,rsize+2
	move.w	#$2f,-(sp)		get DTA
	trap	#1
	addq.l	#2,sp
	move.l	d0,a6
	clr.w	-(sp)
sfirstfile	pea	0.l		open the searched file
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	#2,-(sp)		from the end of the
	move.w	d0,-(sp)		file...
	move.w	d0,d7
	pea	-8.w		-8 bytes
	move.w	#$42,-(sp)
	trap	#1
	lea	10(sp),sp
	pea	sizebuff(pc)
	pea	8.w
	move.w	d7,-(sp)
	move.w	#$3f,-(sp)
	st	intrap1
	trap	#1
	sf	intrap1
	lea	12(sp),sp
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	cmp.l	#'POPI',sizebuff+4
	bne.s	return2
	move.l	sizebuff(pc),26(a6)
	bra.s	return2

depack	tst.w	2(sp)			error reading file?
	bmi.s	return
	movem.l	d0-d7/a0-a6,regs
loadto	move.l	#0,a3
	move.l	d0,rsize+2		Save it incase it aint ours.
	add.l	d0,a3
	move.l	a3,a0
	move.l	a3,d7
	and.l	#1,d7
	tst.b	d7
	bne.s	return2

	cmp.l	#'POPI',-(a3)
	bne.s	return2
	move.l	-(a3),rsize+2		Now save real program size.
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	a0,unpack+2
	lea	unpack(pc),a0
	bsr	supexec
	movem.l	(sp)+,d1-d7/a0-a6
return2	movem.l	regs(pc),d0-d7/a0-a6
rsize	move.l	#$f0000000,d0
return	jmp	0.l			back to whatever used f_read

* the new value for d0 is because some program might check the number of
* bytes read. d0 becomes the length of the UNPACKED file, not the number
* of bytes actually read.

unpack	lea	0.l,a0

	move.l	a0,a3
	lea	-12(a0),a0
	sub.l	(a0),a3
	move.l	a3,a2
	add.l	4(a0),a2
	lea	$ffff8240.w,a4

	MOVE.W	(A4),D5
L76EF0	MOVE.B	-(A0),D0
	BEQ.S	L76EF0
L76EF4	MOVEQ	#0,D2
	BSR.s	L76F78
	BCS.S	L76F0E
	MOVE.B	-(A0),D2
L76EFE	MOVE.B	D2,-(A2)
	BRA.S	L76F38
L76F02	MOVEQ	#$F,D4
	MOVEQ	#2,D3
	BSR.s	L76F84
	BNE.s	L76F6C
	MOVE.W	D4,D2
	BRA.S	L76EFE
L76F0E	BSR.s	L76F78
	BCC.S	L76F48
L76F12	BSR.s	L76F78
	BCC.S	L76F02
	BSR.S	L76F78
	BCS.S	L76F28
	MOVEQ	#2,D1
	BSR	L76FA6
	EXG	D1,D2
	ADDQ.W	#1,D2
	BSET	D1,D2
	BRA.S	L76EFE
L76F28	BSR.S	L76F78
	BCC.S	L76F44
	MOVEQ	#$F,D4
	MOVE.W	#3,D3
	BSR.S	L76F84
	BNE.S	L76F6C
	MOVE.B	(A2),-(A2)
L76F38	move.w	d2,(a4)
	MOVE.W	D5,(a4)
	CMPA.L	A2,A3
	BLT.S	L76EF4
	rts			run the code


L76F44	MOVEQ	#4,D3
	BRA.S	L76F6A
L76F48	BSR.S	L76F78
L76F4A	BCS.S	L76FC0
	MOVEQ	#1,D1
L76F4E	LSR.B	#1,D0
	BNE.S	L76F56
	MOVE.B	-(A0),D0
	ROXR.B	#1,D0
L76F56	ADDX.W	D2,D2
	DBF	D1,L76F4E
	MOVE.W	D2,D1
	BEQ.S	L76FB8
	ADDQ.W	#1,D1
	ADD.W	D1,D1
	SUBQ.W	#1,D1
	BSR.S	L76FA6
	MOVE.W	D2,D3
L76F6A	BSR.S	L76F82
L76F6C	MOVEA.L	A2,A1
	ADDA.L	D2,A1
L76F70	MOVE.B	-(A1),-(A2)
	DBF	D3,L76F70
	BRA.S	L76F38
L76F78	LSR.B	#1,D0
	BNE.S	L76F80
L76F7C	MOVE.B	-(A0),D0
	ROXR.B	#1,D0
L76F80	RTS
L76F82	MOVEQ	#0,D4
L76F84	MOVEQ	#1,D1
	MOVEQ	#0,D2
L76F88	LSR.B	#1,D0
	BNE.S	L76F90
	MOVE.B	-(A0),D0
	ROXR.B	#1,D0
L76F90	ADDX.W	D2,D2
	DBF	D1,L76F88
	MOVE.W	D2,D1
	ADDQ.W	#1,D1
	LSL.W	#2,D1
	SUBQ.W	#1,D1
	EOR.B	D1,D4
	BNE.S	L76FA6
	RTS
	MOVEQ	#7,D1
L76FA6	MOVEQ	#0,D2
L76FA8	LSR.B	#1,D0
	BNE.S	L76FB0
	MOVE.B	-(A0),D0
L76FAE	ROXR.B	#1,D0
L76FB0	ADDX.W	D2,D2
	DBF	D1,L76FA8
	RTS
L76FB8	BSR.S	L76F82
	MOVE.W	D2,D3
	MOVEQ	#1,D2
	BRA.S	L76F6C
L76FC0	MOVEQ	#1,D3
	MOVE.B	-(A0),D2
	BRA.S	L76F6C
*******************************************************
	data
	ifeq	tsr
filename	dc.b	"PROGRAM.EXE",0
	endc
	bss
regs	ds.l	15
save_a0	ds.l	1
envcom	ds.l	1
sizebuff	ds.l	2
intrap1	ds.w	1
	ds.w	127
mystack	ds.w	1
end