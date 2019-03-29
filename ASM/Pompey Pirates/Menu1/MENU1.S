* Pompey Pirates scroll menu DevPac2 source code

	opt	o+
* first release memory so gemdos $4b exec can work later on
start	dc.w	$a00a	hide mouse
	pea	(envcom-start)+256.w	keep filenames safe
	pea	start-256(pc)	basepage
	pea	$4a0000	m_shrink
	trap	#1	release mem
	lea	12(sp),sp

* supervisor mode
	clr.l	-(sp)
	move.w	#32,-(sp)	super
	trap	#1	now in supervisor mode

	lea	$80000,a7

	clr.w	-(sp)	low res
	pea	$78000	physical screen
	pea	$78000	logical screen
	move.w	#5,-(sp)	setscreen
	trap	#14	screen now at $78000 in low res
	lea	12(sp),sp

* depack degas pc1 file
	lea	pic+34(pc),a0	start of data
	lea	$68000,a1		start of free space
	CLR.W	D0
	CLR.W	D1
	CLR.W	D2
	MOVEQ	#1,D3
next_code	MOVE.B	(A0)+,D4
	BMI.S	negative
	EXT.W	D4
	ADD.W	D4,D2
copy	MOVE.B	(A0)+,(A1)
	LEA	0(A1,D3.W),A1
	EORI.W	#6,D3
	DBF	D4,copy
	BRA.S	next_op
negative	NEG.B	D4
	EXT.W	D4
	ADD.W	D4,D2
	MOVE.B	(A0)+,D5
duplicate	MOVE.B	D5,(A1)
	LEA	0(A1,D3.W),A1
	EORI.W	#6,D3
	DBF	D4,duplicate
next_op	ADDQ.W	#1,D2
	CMP.W	#40,D2
	BNE.S	next_line
	CLR.W	D2
	LEA	-158(A1),A1
	ADDQ.W	#1,D1
	CMP.W	#4,D1
	BNE.S	next_line
	CLR.W	D1
	LEA	152(A1),A1
	ADDQ.W	#1,D0
next_line	CMP.W	#200,D0
	BNE.S	next_code

* knock out keyclick, set colors
	move.b	#6,$484.w	key repeat, but no click
	lea	$ffff8240.w,a0	color registers
	lea	pic+2(pc),a1		degas file's palette
	moveq.l	#15,d0
setcol	move.w	(a1)+,(a0)+
	dbf	d0,setcol

* copy picture to screen
	lea	$68000,a0
	lea	$78000,a1
	move.w	#$1f3f,d0
copypic	move.l	(a0)+,(a1)+
	dbf	d0,copypic

* clear $7f580 to $7fd02 (scrolline buffer)
	lea	$7f580,a0
	lea	$7fd02,a1
csc	clr.w	(a0)+
	cmpa.l	a0,a1
	bne.s	csc

* scrolling message handler...
restart	lea	message(pc),a6	message text
nextlet	move.b	(a6)+,d0	get character
	cmp.b	#253,d0	toggle speed?
	bne.s	check254	no
	eor.b	#255,slowscroll	yes
	bra.s	nextlet

check254	cmp.b	#254,d0	pause message?
	bne.s	check255	no
	movem.l	d0-d1/a0-a1,-(sp)	save registers
	move.w	#200,d1	200 vsyncs of 1/50 sec each:
vsyncloop	bsr	vsync	around 4 seconds pause
	dbf	d1,vsyncloop
	movem.l	(sp)+,d0-d1/a0-a1	restore registers
	bra.s	nextlet

check255	cmp.b	#255,d0	end of message?
	beq.s	restart	yes

* build a character from font data
	clr.w	d5
	lea	font(pc),a1	start of font data
	adda.l	d0,a1	add character code to font start
	lea	build(pc),a2	start of area to build char in
	moveq.l	#7,d7	8 lines of the char
allchar	move.b	(a1),(a2)+	take line from font to build area
	adda.l	#256,a1	next line of char
	dbf	d7,allchar

test0	cmpi.b	#0,vsyncflag	time for a vsync?
	bne.s	sub1	no
	cmp.b	#0,slowscroll	speed set to slow?
	bne.s	fastscroll	no- so skip past vsync
	bsr	vsync
	
* vsyncs are performed every other scroll in slow mode, not at all in fast
* mode

fastscroll	move.b	#2,vsyncflag	
sub1	subq.b	#1,vsyncflag
key	pea	$600ff	gemdos 6 with $ff: test keyboard
	trap	#1	check for key press
	addq.l	#4,sp
	tst.w	d0	key pressed?
	bne.s	keyhit	yes

cont	clr.l	d0
	lea	build(pc),a5	start of character data
	lea	$7f580,a0
	moveq.l	#7,d7	8 lines of char


lines	move.l	a0,-(sp)	save a0
	adda.l	#312,a0
	move.b	(a5),d1	get char line
	lsl.b	#1,d1	shift left one pixel
	move.b	d1,(a5)+	write back to build area

	moveq.l	#19,d6
cols	move.w	(a0),d1
	roxl.w	#1,d1
	move.w	d1,(a0)
	move.w	d1,$2(a0)
	move.w	d1,$4(a0)
	move.w	d1,$6(a0)
	subq.l	#8,a0
	dbf	d6,cols
	
	movea.l	(a7)+,a0	restore a0
	lea	160(a0),a0	next screen line
	dbf	d7,lines


	addq.w	#1,d5
	andi.w	#7,d5
	bne.s	test0

	bra	nextlet


keyhit	cmp.b	#' ',d0
	beq.s	term2
	cmp.b	#'0',d0	0-toggle hz
	blt.s	cont	less than 0 so forget the keypress
	bgt.s	not0	more than so check for other options
	eor.b	#2,$ffff820a.w	toggle hz video reg.
	bra.s	cont
	
not0	cmp.b	#'1',d0	1-program 1?
	bne.s	notgame1	nope
	lea	game1(pc),a3	address of filename 1
	bra.s	exec
	
notgame1	cmp.b	#'2',d0	2-program 2?
	bne.s	notgame2
	lea	game2(pc),a3	filename 2
	bra.s	exec

* obviously, you can add as many keys as you want to the program- just check
* for their ascii codes and act accordingly. you could have a routine to
* change the current folder, anything...
notgame2	cmp.b	#'3',d0
	bne.s	cont	not a useful key so ignore it
	lea	game3(pc),a3	filename 3

* load and run an executable file after printing 'loading' message
exec	move.b	#$f,$484.w	restore keyclick
	lea	loading(pc),a0
	bsr.s	print
	pea	envcom(pc)	null command line
	pea	envcom(pc)	null environment
	pea	(a3)	filename
	pea	$4b0000	load and run
	trap	#1	pow!

* should never get here if all is ok, but if it has got here you'd better
* let the user know!
	lea	16(sp),sp
	lea	errortext(pc),a0	address of message
	bsr.s	print
	move.w	#8,-(sp)	c_conin- wait for a key
	trap	#1	wait
	addq.l	#2,sp
term	clr.w	-(sp)	p_term- quit program
	trap	#1	bye bye
term2	move.b	#$f,$484.w
	bra.s	term
* print a message
print	pea	(a0)
	move.w	#9,-(sp)	c_conws
	trap	#1
	addq.l	#6,sp
	rts

* wait for a vertical blank- vsync
vsync	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	rts
		
vsyncflag	dc.w	2	flag for vsyncing
build	ds.l	4	buffer for char building
slowscroll	ds.b	1	flag for slow/fast mode scrolling

* insert extra file/folder names as needed
game1	dc.b	"NEWZEALA.PRG",0
game2	dc.b	"RICKDANG.TOS",0
game3	dc.b	"GRIDRUNR.PRG"
envcom	dc.b	0	null environment/command line

* change message as needed- all characters can be displayed, end message
* with 255, pause with 254, toggle slow/fast with 253 (default is slow).
* put a space before the start of the message!
message	dc.b	"Blah blah BLAH BLAH etc. etc. waffle etc. "
	dc.b	"rhubarb rhubarb...         "
	dc.b	255

errortext	dc.b	27,"E",27,"Y",44," Program load failed - recopy this disk?",0
loading	dc.b	27,"E",27,"Y",44,36,"Loading program... please wait."
	even

* fonts are standard NewFont ones! i.e. completely normal 8x8 font data as
* in the rom for low/medium res but without the header, so it's just 2048
* bytes of pure font data
font	 incbin	 "a:\source\asm\pompey\typewrit.fnt"	-or any font

* pictures are standard DEGAS compressed low res ones!
pic	 incbin	 "a:\source\asm\pompey\menu1.pc1"		-or any pic