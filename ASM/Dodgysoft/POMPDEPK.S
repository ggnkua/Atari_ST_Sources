no	equ	0
yes	equ	1

* EXEC HEADER FOR EXEC FILES PACKED WITH POMPEY PACKER 1.9 FORM DODGYSOFT!
* You can customise this exec header by setting the values below to YES or
* NO. 'lowresonly' will correctly justify the 'POMPEY PACKER V1.9' text if
* it is set to NO, if set to yes, it will just print in the middle of the
* screen on low res, but will be incorrectly justified in med/high res.
* 'printheading' will print the "POMPEY PACKER V1.9' text if set to YES.
* 'okrobnorthen' will work with Rob Northen protection if set to YES; if
* set to NO it will lock up if protected with RN protection, but will save
* a few bytes.

lowresonly	equ	yes
printheading	equ	no
okrobnorthen	equ	no

start	move.l	4(sp),a5		base page address
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,2(sp)

	ifne	printheading
	ifeq	lowresonly
	move.w	#4,-(sp)		change x co-or of
	trap	#14			text if in medium
	addq.l	#2,sp			or high res
	tst.w	d0
	beq.s	low
	lea	x(pc),a0
	add.b	#20,(a0)
	endc
low	pea	text(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	endc

	ifne	okrobnorthen
	lea	endoffile,a4
	endc

	move.l	a4,a0
depack	movea.l	a0,a3			Start of packed file 
	lea	-12(a0),a0
	sub.l	(a0),a3			sub the packedsize.
	movea.l	a3,a2
	add.l	4(a0),a2
	lea	$ffff8240.w,a4
	move.w	(a4),d5			Save color

empty	move.b	-(a0),d0		Unpack data.
	beq.s	empty			Not empty.
umain	moveq	#0,d2
	bsr	shifter
	bcs.s	rep

	move.b	-(a0),d2
output	move.b	d2,-(a2)
	bra.s	ecxit

rep3	moveq	#15,d4			16bit in-operative.
	moveq	#2,d3
	bsr.s	leader
	bne.s	rloop
	move.w	d4,d2
	bra.s	output
		
rep	bsr.s	shifter
	bcc.s	repeat
	bsr.s	shifter
	bcc.s	rep3
	bsr.s	shifter
	bcs.s	rep4
special	moveq	#2,d1
	bsr	nibit
	exg	d1,d2
	addq.w	#1,d2
	bset	d1,d2
	bra.s	output
	
rep4	bsr.s	shifter
	bcc.s	rep5			V1.7 incompatability
	moveq	#15,d4			16bit in-operative.
	move.w	#3,d3
	bsr.s	leader
	bne.s	rloop
	move.b	(a2),-(a2)

ecxit	move.w	d3,(a4)
	move.w	d5,(a4)
	cmpa.l	a2,a3
	blt.s	umain
	bra	sort_it_out

rep5	moveq	#4,d3
	bra.s	reps

; **	Offset bitsize is x bits depending upon D2.
; **	Also serves to reproduce RUNS , because an offset of 1 = same
; **	character repeated D3 times.

repeat	bsr.s	shifter
	bcs.s	rep2
	moveq	#1,d1
.1	lsr.b	#1,d0
	bne.s	.2
	move.b	-(a0),d0
	roxr.b	#1,d0
.2	addx.w	d2,d2
	dbf	d1,.1
	
	move.w	d2,d1			Copy bitcount
	beq.s	runing			If ZERO then do RUNS
	addq.w	#1,d1
	add.w	d1,d1
	subq.w	#1,d1
	bsr.s	nibit
	move.w	d2,d3
reps	bsr.s	lead1			Get offset size.
rloop	movea.l	a2,a1
	add.l	d2,a1			Add the offset.
replp	move.b	-(a1),-(a2)
	dbf	d3,replp
	bra.s	ecxit

shifter	lsr.b	#1,d0
	bne.s	noz
	move.b	-(a0),d0
	roxr.b	#1,d0
noz	rts

; **	Collect 2bit leader into D1
; **	Algorithm :- 2bits + 1 (1 to 4) * 4.
; **	Return the BITS in D2.

lead1	moveq	#0,d4			16bits operative.
leader	moveq	#1,d1

	moveq	#0,d2
n1	lsr.b	#1,d0
	bne.s	n2
	move.b	-(a0),d0
	roxr.b	#1,d0
n2	addx.w	d2,d2
	dbf	d1,n1

	move.w	d2,d1
	addq.w	#1,d1
	lsl.w	#2,d1
	subq.w	#1,d1
	eor.b	d1,d4
	bne.s	nibit
	rts	
nibs	moveq	#7,d1
nibit	moveq	#0,d2
nlp	lsr.b	#1,d0
	bne.s	nlp1
	move.b	-(a0),d0
	roxr.b	#1,d0
nlp1	addx.w	d2,d2
	dbf	d1,nlp
	rts
runing	bsr.s	lead1			16bits operative
	move.w	d2,d3
	moveq	#1,d2
	bra.s	rloop
rep2	moveq	#1,d3			Size of loop.
	move.b	-(a0),d2
	bra.s	rloop

sort_it_out	trap	#1
	addq.l	#6,sp
* a3 is already pointing to start of depacked program
	move.l	2(a3),a0		text segment
	add.l	6(a3),a0		+ data segment
	add.l	14(a3),a0		+ symbol table
	lea	28(a0),a0		+ header
	add.l	a3,a0			+ start of program
* a0 now points to relocation table
	move.l	8(a5),d0		d0 points to TEXT
	lea	28(a3),a3		a3 points to program
	move.l	a3,a6
	tst.l	(a0)			zero 1st relocation?
	beq.s	done_reloc

	moveq	#0,d1
	add.l	(a0)+,a3		+ offset
relocate	add.l	d0,(a3)		relocate it
add_no_reloc	move.b	(a0)+,d1	next byte
	beq.s	done_reloc		zero is end
	cmp.b	#1,d1			1 is add 254, but
	bne.s	not1			don't relocate
	lea	254(a3),a3
	bra.s	add_no_reloc
not1	add.l	d1,a3			+ offset
	bra.s	relocate

done_reloc	lea	packedfile+2(pc),a2	past $601a
	move.l	(a2),12(a5)		write real TEXT len
	add.l	(a2),d0			TEXT len + TEXT addr
	move.l	d0,16(a5)		write real DATA addr
	move.l	4(a2),20(a5)		write real DATA len
	add.l	4(a2),d0		+ DATA len
	move.l	d0,24(a5)		write real BSS addr
	move.l	8(a2),28(a5)		write real BSS len

* now move code somewhere safe
	move.l	sp,a0
	lea	-256(a0),a0
	pea	(a0)
	lea	mover(pc),a1
	moveq	#(endofmover-mover)/2-1,d0
copy_mover	move.w	(a1)+,(a0)+
	dbf	d0,copy_mover
	rts

* move the program down to the correct address
mover	move.l	12(a5),d0		TEXT len
	add.l	20(a5),d0		+ DATA len
	lsr.l	#1,d0			divide by 2
	addq.l	#1,d0			one for luck
	move.l	8(a5),a4		pointer to TEXT addr
	pea	(a4)			run address
copydown	move.w	(a6)+,(a4)+
	subq.l	#1,d0
	bne.s	copydown
* clear the BSS
	move.l	28(a5),d1
	add.l	#(packedfile-start)+28,d1
	lsr.l	#1,d1
	addq.l	#1,d1
clearbss	move.l	d0,(a4)+
	subq.l	#1,d1
	bne.s	clearbss
	move.w	#$6006,start+$ef22
	rts				run the program
endofmover
	ifne	printheading
text	dc.b	27,"E",27,"Y",32
x	dc.b	43,"POMPEY PACKER V1.9a",0,0	;You Can Put your own in here!
	endc
* the packed exec file goes here
packedfile	incbin	"A:\gamename.prg"
endoffile