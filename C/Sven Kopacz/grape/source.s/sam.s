start:
	move.l	4(sp),a0
	move.l	$c(a0),d0
	add.l	$14(a0),d0
	add.l	$1c(a0),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	pea	(a0)
	pea	$004a0000
	trap	#1
	lea	12(sp),sp
	;
	move.w	#4,-(sp)
	trap	#$e
	addq.l	#2,sp
	subq.w	#1,d0
	;
	;
	nolowrez:
	move.w	d0,rez
	.dc.w	$a000
	move.l	a0,lineavar
	move.w	#1,24(a0)
	moveq.l	#-1,d0
	move.w	d0,34(a0)
	move.w	d0,32(a0)
	clr.w	36(a0)
	;
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap#1
	addq.l	#6,sp
	move.l	d0,oldsp
	;
	moveq.l	#-1,d0
	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap#1
	addq.l	#6,sp
	sub.l	#5*1024,d0
	move.l	d0,freemem
	lea memtext(pc),a0
	move.l	#$ffff,d7
	move.l	d0,d1
	lsr.l	#5,d1
	lsr.l	#5,d1
	move.l	#1000,d2
	moveq.l	#3,d3
	mainl:
	divu	d2,d1
	moveq.l	#'0',d4
	add.b	d1,d4
	move.b	d4,(a0)+
	swap	d1
	and.l	d7,d1
	divu	#10,d2
	dbf	d3,mainl
	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,memadr
	;
	clr.b	$484
	pea	siditab(pc)
	move.w	#$20,-(sp)
	trap	#$e
	addq.l	#6,sp
	;
	lea	inittext(pc),a0
	bsr	print
	;
	menuloop:
	lea	menutext(pc),a0
	bsr print
	;bsr showgraf
	menukey:
	bsr	getkey
	swap	d0
	moveq.l	#$3b,d1
	cmp.w	d1,d0
	bmi.s	menukey
	;
	sub.w	d1,d0
	lsl.w	#2,d0
	lea	cmdtab(pc),a0
	move.l	0(a0,d0),a0
	jsr	(a0)
	;
	bra.s	menuloop
	;
	print:
	pea	(a0)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
	;
	getkey:
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts
	;
	printmsg:
	pea	(a0)
	lea	msg1text(pc),a0
	bsr print
	move.l	(sp)+,a0
	bsr	print
	lea	msg2text(pc),a0
	bra print
	
	;
	clrmsg:
	;
	calctext:
	lea	inptext(pc),a6
	moveq.l	#0,d0
	calcloop:
	moveq.l	#0,d1
	move.b	(a6)+,d1
	cmp.w	#'0',d1
	bmi.s	calcend
	cmp.w	#'9'+1,d1
	bpl.s	calcend
	sub.b	#'0',d1
	mulu	#10,d0
	add.w	d1,d0
	bra.s	calcloop
	calcend:
	rts
	
	;
	gettext:
	moveq.l	#0,d7
	move.l	d7,d6
	move.b	(a0)+,d7
	pea	(a0)
	lea	get1text(pc),a0
	bsr	print
	move.l	(sp)+,a0
	bsr	print
	lea	inptext(pc),a6
	;
	keyinpl:
	bsr	getkey
	cmp.b	#$d,d0
	beq.s	endgett
	cmp.b	#$8,d0
	beq.s	delgett
	cmp.b	d6,d7
	beq.s	keyinpl
	move.b	d0,(a6)+
	addq.l	#1,d6
	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	bra.s	keyinpl
	;
	delgett:
	tst.b	d6
	beq.s	keyinpl
	subq.l	#1,a6
	subq.l	#1,d6
	lea	deltext(pc),a0
	bsr	print
	bra.s	keyinpl
	;
	endgett:
	clr.b	(a6)
	lea	get2text(pc),a0
	bsr	print
	bra clrmsg
	;
	error:
	bsr	printmsg
	bsr	getkey
	bra	clrmsg
	;
	input:
	move.l	a1,startadr
	bsr	sndinit
	move.b	#$e,(a5)
	move.b	(a5),d7
	or.b	#$20,d7
	move.b	d7,2(a5)
	move.b	#7,(a5)
	move.b	(a5),d7
	and.b	#$7f,d7
	move.b	d7,2(a5)
	;
	inploop:
	moveq.l	#0,d6
	move.b	#$f,(a5)
	move.b	(a5),d6
	;
	move.b	#$e,(a5)
	move.b	(a5),d7
	and.b	#$df,d7
	move.b	d7,2(a5)
	move.b	(a5),d7
	or.b	#$20,d7
	move.b	d7,2(a5)
	;
	tst.b	d2
	beq.s	norec
	move.b	d6,(a1)+
	cmp.l	a1,a2
	beq.s	inpend
	norec:
	and.b	#%11111100,d6
	move.w	d6,d7
	add.w	d6,d7
	add.w	d6,d7
	movem.l	0(a3,d7),d5-d7
	movem.l	d5-d7,(a5)
	;
	cmp.b	2(a4),d0
	beq.s	inpend
	inpsync:
	btst	#4,$d(a6)
	beq.s	inpsync
	bclr	#4,$d(a6)
	bra	inploop
	inpend:
	tst.b	d2
	beq.s	inpend2
	sub.l	startadr,a1
	move.l	a1,smpllen
	inpend2:
	bra	sndinit2
	;
	play:
	subq.w	#1,d3
	move.l	a1,startadr
	move.l	a2,endadr
	bsr	sndinit
	moveq.l	#0,d4
	;
	playloop:
	tst.b	d2
	bne.s	playb
	move.b	(a1)+,d4
	cmp.l	a1,a2
	bne.s	playfl
	dbf	d3,playfla
	bra.s	playend
	;
	playfla:
	move.l	startadr,a1
	;
	playfl:
	bra.s	playl
	;
	playb:
	move.b	-(a2),d4
	cmp.l	a1,a2
	bne.s	playl
	dbf	d3,playla
	bra.s	playend
	;
	playla:
	move.l	endadr,a2
	playl:
	and.b	#%11111100,d4
	move.w	d4,d7
	add.w	d4,d7
	add.w	d4,d7
	movem.l	0(a3,d7),d5-d7
	movem.l	d5-d7,(a5)
	;
	cmp.b	2(a4),d0
	beq.s	playend
	playsync:
	btst	#4,$d(a6)
	beq.s	playsync
	bclr	#4,$d(a6)
	bra	playloop
	;
	playend:
	bra	sndinit2
	;
	sndinit:
	SUPER
	move.w	#$2700,sr
	USER
	lea	voldat(pc),a3
	move.w	#$fc00,a4
	move.w	#$8800,a5
	move.w	#$fa00,a6
	;
	move.l	#2457600,d7
	divu	d1,d7
	lsr.w	#2,d7
	move.b	d7,$25(a6)
	move.b	$1d(a6),d7
	and.b	#$f0,d7
	or.b	#$01,d7
	move.b	d7,$1d(a6)
	bset	#4,9(a6)
	rts
	;
	sndinit2:
	move.b	$1d(a6),d7
	and.b	#$f0,d7
	move.b	d7,$1d(a6)
	bclr	#4,9(a6)
	SUPER
	move.w	#$2300,sr
	USER
	rts
	;
	quit:
	addq.l	#4,sp
	move.b	#7,$484
	move.l	oldsp,-(sp)
	move.w	#$20,-(sp)
	trap#1
	addq.l	#6,sp
	move.l	memadr,-(sp)
	move.w	#$49,-(sp)
	trap#1
	addq.l	#6,sp
	clr.w	-(sp)
	trap#1
	
	;
	listen:
	lea	heartext(pc),a0
	listenl:
	bsr	printmsg
	moveq.l	#$39,d0
	move.w	recfrq,d1
	moveq.l	#0,d2
	bsr	input
	bra	clrmsg
	;
	record:
	lea	rec1text(pc),a0
	bsr	listenl
	lea	rec2text(pc),a0
	bsr printmsg
	moveq.l	#$01,d0
	move.w	recfrq,d1
	moveq.l	#1,d2
	move.l	memadr,a1
	move.l	a1,a2
	add.l	freemem,a2
	bsr input
	bra clrmsg
	;
	setplay:
	lea	setptext(pc),a0
	move.l	#playfrq,frqptr
	moveq.l	#30,d0
	bra.s	setlabl
	;
	setrec:
	lea	setrtext(pc),a0
	move.l	#recfrq,frqptr
	moveq.l	#22,d0
	setlabl:
	move.w d0,-(sp)
	bsr	gettext
	bsr	calctext
	move.w	(sp)+,d1
	cmp.w	#3,d0
	blt.s	seterr
	cmp.w	d1,d0
	bhi.s	seterr
	mulu	#1000,d0
	move.l	frqptr,a0
	move.w	d0,(a0)
	rts
	seterr:
	lea	setetext(pc),a0
	bra error
	
	;
	playback:
	moveq.l	#1,d2
	bra.s	playsnd
	playforw:
	moveq.l	#0,d2
	playsnd:
	move.w	d2,-(sp)
	lea	playtext(pc),a0
	bsr printmsg
	moveq.l	#$39,d0
	move.w	playfrq,d1
	move.w	(sp)+,d2
	moveq.l	#-1,d3
	move.l	memadr,a1
	move.l	a1,a2
	add.l	smpllen,a2
	bsr	play
	bra clrmsg
	;
	setdrv:
	cmp.b	#':',inptext+1
	bne.s	setdrve
	moveq.l	#0,d0
	move.b	inptext,d0
	and.b	#%11,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	#$e,-(sp)
	trap	#1
	addq.l	#4,sp
	setdrve:
	rts
	
	;
	load:
	;
	save:
	lea	savetext(pc),a0
	bsr	gettext
	bsr	setdrv
	clr.w	-(sp)
	pea	diskinfo(pc)
	move.w	#$36,-(sp)
	trap #1
	addq.l	#8,sp
	move.l	smpllen,d7
	move.l	diskinfo,d0
	subq.l	#2,d0
	mulu	#1024,d0
	cmp.l	d7,d0
	bmi.s	saveerr
	saveerr1:
	clr.w	-(sp)
	pea	inptext(pc)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,-(sp)
	move.l	memadr,-(sp)
	move.l	d7,-(sp)
	move.w	d0,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	bra	clrmsg
	saveerr:
	exg	d0,d7
	lea	saveetxt(pc),a0
	bsr printmsg
	bra	saveerr1
	
	;
	format:
	;
	showgraf:
	rts
	;
	
	.data
	
	inittext:
	.dc.b	$1b,"E",$1b,"f",0
	menutext:
	.dc.b	$1b,"Y",32+16,32+0,$1b,"d",$1b,"H"
	.dc.b	" ",$1b,"p"," ST Sound Sampler - "
	memtext:
	.dc.b	"0000 KB frei ",$1b,"q",13,10,13,10
	.dc.b	"Software blablabla",13,10
	.dc.b "F1 Hîren",13,10
	.dc.b "F2 Aufnehmen",13,10
	.dc.b "F3 Load",13,10
	.dc.b "F4 Save",13,10
	.dc.b "F5 Play",13,10
	.dc.b "F6 Backwd",13,10
	.dc.b "F7 Recfreq",13,10
	.dc.b "F8 Playfreq",13,10
	.dc.b "F9 Format",13,10
	.dc.b "F10 Quit",13,10
	
	clrgrtxt:
	.dc.b		$1b,"Y",32+18,32+0,$1b,"J",0
	get1text:
	.dc.b		$1b,"Y",32+16,32+0,$1b,"e",0
	get2text:
	.dc.b		$1b,"f",0
	msg1text:
	.dc.b		$1b,"Y",32+16,32+0,$1b,"p",0
	msg2text:
	.dc.b		$1b,"q",0
	clrmtex:
	.dc.b		$1b,"Y",32+16,32+0,$1b,"l",0
	deltext:
	.dc.b		$1b,"D"," ",$1b,"D",0
	;
	heartext:
	.dc.b	" Space = Abbruch", 0
	rec1text:
	.dc.b	" Space = STart",0
	rec2text:
	.dc.b	" ESC Stop",0
	setrtext:
	.dc.b 2
	.dc.b	"Neue RecFreq KHz (3-22):",0
	setptext:
	.dc.b 2
	.dc.b "Neue Playfreq (3-22 KHz):",0
	setetext:
	.dc.b "Falsch! (3-22)!)",0
	playtext:
	.dc.b	"SPACE = Abbruch (sonst Loop)",0
	savetext:
	.dc.b 40
	.dc.b	"Datei-Name:",0
	saveetxt:
	.dc.b "Zu wenig Platz: Sample gekÅrzt!",0
	;
	;
	;
	.even
	cmdtab:
	.dc.l	listen,record,load,save,playforw
	.dc.l	playback,setrec,setplay,format,quit
	
	;Lautprecher:
	voldat:
	.dc.l	$08000000,$09000000,$0a000000
	.dc.l	$08000000,$09000000,$0a000200
	.dc.l $08000000,$09000000,$0a000300
	.dc.l $08000200,$09000200,$0a000200
	.dc.l $08000500,$09000000,$0a000000
	
	.dc.l	$08000500,$09000200,$0a000000
	.dc.l	$08000600,$09000100,$0a000000
	.dc.l $08000600,$09000200,$0a000100
	.dc.l $08000700,$09000100,$0a000200
	.dc.l $08000700,$09000200,$0a000000
	
	.dc.l	$08000700,$09000300,$0a000100
	.dc.l	$08000800,$09000000,$0a000000
	.dc.l $08000800,$09000200,$0a000000
	.dc.l $08000800,$09000300,$0a000100
	.dc.l $08000800,$09000400,$0a000100
	
	.dc.l	$08000900,$09000000,$0a000000
	.dc.l	$08000900,$09000200,$0a000000
	.dc.l $08000900,$09000300,$0a000100
	.dc.l $08000900,$09000400,$0a000100
	.dc.l $08000900,$09000500,$0a000000
	;
	
	.dc.l	$08000900,$09000500,$0a000200
	.dc.l	$08000900,$09000600,$0a000000
	.dc.l $08000900,$09000600,$0a000200
	.dc.l $08000a00,$09000200,$0a000000
	.dc.l $08000a00,$09000200,$0a000200
	
	.dc.l	$08000a00,$09000400,$0a000100
	.dc.l	$08000a00,$09000500,$0a000000
	.dc.l $08000a00,$09000500,$0a000200
	.dc.l $08000a00,$09000600,$0a000100
	.dc.l $08000a00,$09000600,$0a000300
	
	.dc.l	$08000b00,$09000100,$0a000000
	.dc.l	$08000b00,$09000200,$0a000100
	.dc.l $08000b00,$09000300,$0a000100
	.dc.l $08000b00,$09000400,$0a000100
	.dc.l $08000b00,$09000500,$0a000100
	
	.dc.l	$08000b00,$09000600,$0a000000
	.dc.l	$08000b00,$09000600,$0a000200
	.dc.l $08000b00,$09000700,$0a000000
	.dc.l $08000b00,$09000700,$0a000100
	.dc.l $08000b00,$09000700,$0a000300
	;
	.dc.l	$08000b00,$09000700,$0a000400
	.dc.l	$08000b00,$09000800,$0a000100
	.dc.l $08000b00,$09000800,$0a000300
	.dc.l $08000b00,$09000800,$0a000400
	.dc.l $08000b00,$09000800,$0a000500
	
	.dc.l	$08000b00,$09000800,$0a000500
	.dc.l	$08000c00,$09000200,$0a000000
	.dc.l $08000c00,$09000200,$0a000200
	.dc.l $08000c00,$09000400,$0a000100
	.dc.l $08000c00,$09000500,$0a000000
	
	.dc.l	$08000c00,$09000500,$0a000300
	.dc.l	$08000c00,$09000600,$0a000000
	.dc.l $08000c00,$09000600,$0a000200
	.dc.l $08000c00,$09000700,$0a000000
	.dc.l $08000c00,$09000700,$0a000300
	
	.dc.l	$08000c00,$09000700,$0a000400
	.dc.l	$08000c00,$09000800,$0a000000
	.dc.l $08000c00,$09000800,$0a000300
	.dc.l $08000c00,$09000800,$0a000400
	.dc.l $08000c00,$09000800,$0a000500
	;
	.dc.l	$08000c00,$09000900,$0a000000
	.dc.l $08000c00,$09000900,$0a000300
	.dc.l $08000c00,$09000900,$0a000400
	.dc.l $08000c00,$09000900,$0a000500
	
	siditab:
	.dc.b	0,$ff,1,$ff,2,$ff,3,$ff,4,$ff,5,$ff,6,0,7,$3f
	.dc.b	8,0,9,0,10,0,$ff,0
	
	recfrq:
	.dc.w	20000
	playfrq:
	.dc.w	20000
	smpllen:
	.dc.l	1
	;
	;
	;
	.bss
	rez:
	.ds.w	1
	lineavar:
	.ds.l 1
	oldsp:
	.ds.l	1
	inptext:
	.ds.b	80
	frqptr:
	.ds.l	1
	memadr:
	.ds.l	1
	freemem:
	.ds.l	1
	startadr:
	.ds.l	1
	endadr:
	.ds.l	1
	diskinfo:
	.ds.l	4
	formtpuf:
	.ds.b	9*1024
	
	