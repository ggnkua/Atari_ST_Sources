* ProPack 1.02 cracker
* for files such as the F-29 demo on Zero coverdisk...
* (after you've got past the rob northen!!!)
	opt	o+,x+

start	pea	(end-start)+256.w
	pea	start-256(pc)
	pea	$4a0000		reserve memory
	trap	#1
	lea	12(sp),sp

	lea	stack(pc),sp

	clr.l	-(sp)
	move.w	#$20,-(sp)		supervisor
	trap	#1

	cmp.b	#2,$44c.w
	beq.s	hi
	move.w	#1,-(sp)
	pea	-1.w
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	move.l	#$7770000,$ffff8240.w
	clr.l	$ffff8244.w
hi	lea	input(pc),a6
	bsr	print
	lea	filename(pc),a6
	bsr	print
	lea	cursor(pc),a6
	bsr	print

	pea	inputline(pc)
	move.w	#$a,-(sp)		input filename
	trap	#1
	addq.l	#6,sp

	cmp.b	#'?',inputline+2
	bne.s	notq
	move.b	#'A',inputline+2
	lea	help(pc),a6
	bsr.s	print
	bsr.s	get_key
	bra.s	hi

notq	movem.l	$8.w,d0-d7
	movem.l	d0-d7,tex

	pea	envcom(pc)
	move.l	(sp),-(sp)
	pea	filename(pc)
	pea	$4b0003		load and set up
	trap	#1
	lea	16(sp),sp
	tst.l	d0
	bmi.s	error

	move.l	d0,a0		basepage addr

	lea	256+40(a0),a0
	move.w	#$a300,(a0)		run with interrupts!
	lea	270(a0),a0
	move.l	a0,compare+6

	move.l	$114.w,oldtimerC+2	save old timer C
	move.l	#mytimerC,$114.w	patch my timer C

	clr.l	-(sp)
	move.l	d0,-(sp)
	clr.l	-(sp)
	pea	$4b0004		run the shit...
	trap	#1
	lea	16(sp),sp
	clr.w	-(sp)
	trap	#1

error	lea	text(pc),a6
	bsr.s	print
	bsr.s	get_key
	clr.w	-(sp)
	trap	#1

print	pea	(a6)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts



mytimerC	eor.w	#$77,$ffff8240	muck up colors

	movem.l	d0-d7/a0-a6,-(sp)
compare	cmp.l	#$41e8001c,$00000000	decrypted yet?
	bne	notyet		no
	move.l	compare+6(pc),a0
	move.w	#$4e4a,(a0)
	move.l	#trap10,$a8.w
notyet	movem.l	(sp)+,d0-d7/a0-a6
oldtimerC	jmp	0		do old timer C

trap10	move.l	oldtimerc+2(pc),$114.w
	movem.l	tex(pc),d0-d7
	movem.l	d0-d7,$8.w
	pea	(a0)
	lea	choice(pc),a6
	bsr.s	print
not1	bsr.s	get_key
	cmp.b	#'2',d0
	beq.s	return
	cmp.b	#'1',d0
	bne.s	not1
	move.w	#$2300,sr
	lea	input2(pc),a6
	bsr.s	print
	lea	filename(pc),a6
	bsr	print
	lea	cursor(pc),a6
	bsr	print
	pea	inputline(pc)
	move.w	#$a,-(sp)		input filename
	trap	#1
	addq.l	#6,sp
	clr.w	-(sp)
	pea	filename(pc)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,d7
	move.l	(sp)+,a0
	move.l	a0,a1
	lea	32(a1),a2
	add.l	2(a0),a2
	add.l	6(a0),a2
	add.l	14(a0),a2
findend	tst.b	(a2)+
	bne.s	findend
	move.l	a2,d0
	move.l	a0,d1
	sub.l	d1,d0
	pea	(a0)
	move.l	d0,-(sp)
	move.w	d7,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	clr.w	-(sp)
	trap	#1

return	move.w	#$a300,sr
	rts

	data
	ds.l	400
stack	ds.l	1
envcom	dc.w	0		null environment/command

text	dc.b	27,"E",7,"File not found. Hit it...",0
help	dc.b	27,"E",27,"f","Crakpro 1.02 will depack programs that have been packed with ProPack 1.02;",13,10
	dc.b	"this is the packer that is used on the F-29 Zero mission. ProPack will not",13,10
	dc.b	"depack from within MonST, as it specifically checks for MonST's presence (try",13,10
	dc.b	"it for a laugh - it just says FUCK YOU at PC when it crashes!). So run this",13,10
	dc.b	"program and enter the name of the file you wish to depack. It will then be",13,10
	dc.b	"depacked.",13,10
	dc.b	"Then it will offer you the choice of either saving the depacked file or",13,10
	dc.b	"dropping back to MonST (PC=start of depacked file) if you ran CrakPro from",13,10
	dc.b	"within it.",13,10,10
	dc.b	"All coding by The Alien... hit a key.",0
choice	dc.b	27,"E",27,"f1...Save file",13,10,"2...Return to MonST (TRACE exception)",0
input	dc.b	27,"E",27,"e","CrakPro 1.02 by The Alien, ",$bd," 1990.",13,10
	dc.b	"Enter filename or ? for help.",13,10,10
	dc.b	"Program to crack >",0
input2	dc.b	27,"Y",35,32,"Save file as     >",0
cursor	dc.b	27,"Y",35,50,27,"e",0

inputline	dc.b	128		max 128 chars
	dc.b	8		8 given chars
filename	dc.b	"A:\*.PRG"		default filename
	bss
	ds.b	120		128 chars buffer
tex	ds.l	8
end