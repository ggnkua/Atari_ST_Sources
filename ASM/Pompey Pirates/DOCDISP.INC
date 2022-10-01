
dispdoc	bsr	setupmouse
	lea	na_txt,a5 
	lea	l01a1,a4
	bsr	copyoptxt 
	lea	na_txt,a5 
	lea	l01a2,a4
	bsr	copyoptxt 
	lea	notapplic,a5
	lea	l019d(pc),a4
	bsr	copyoptxt 
	lea	notapplic,a5
	lea	l019e(pc),a4
	bsr	copyoptxt 
	lea	fon,a0
	lea	font,a1 
	lea	thinfon,a3
	lea	thinfont,a4 
	move.l	a4,d0 
	move.l	a1,d1 
	eor.l	d1,d0 
	move.l	d0,l005c
	moveq	#0,d0 
	moveq	#0,d1 
	move.w	#$ff,d7 
	movea.l	a0,a2 
	movea.l	a3,a5 
redo_font1	movea.l	a2,a0 
	movea.l	a5,a3 
	moveq	#7,d6 
redo_font2	move.b	(a0),d0 
	move.b	(a3),d1 
	move.w	d0,(a1)+
	move.w	d1,(a4)+
	lea	256(a0),a0
	lea	256(a3),a3
	dbf	d6,redo_font2 
	addq.l	#1,a2 
	addq.l	#1,a5 
	dbf	d7,redo_font1 
reset	movea.l	$42e.w,a0 
	move	#$2300,sr 
	move.l	#screen,screen_addr
	move.b	$44c.w,d0 
	cmp.b	#2,d0 
	bne.b	l0004 
	move.w	l0007(pc),l0008 
	move.w	#$280,l000a 
	bra.b	l0005 
l0004	move.w	#$5640,l0008
	move.w	#$500,l000a 
l0005	lea	x_offsets,a0
	moveq	#$27,d7 
	moveq	#0,d0 
l0006	move.w	d0,(a0)+
l0007	addq.w	#1,d0 
	move.w	d0,(a0)+
l0008	addq.w	#3,d0 
	dbf	d7,l0006
	lea	y_offsets,a0
	moveq	#$31,d7 
	moveq	#0,d0 
l0009	move.w	d0,(a0)+
	addi.w	#$500,d0
l000a	equ	*-2 
	dbf	d7,l0009
	pea	$f0001
	move.w	#$23,-(a7) 	;kbrate 
	trap	#$e 
	addq.l	#6,a7 
	move.b	#6,$484.w 
	lea	setcolorstxt(pc),a5 
	lea	l019f(pc),a4
	bsr	copyoptxt 
	lea	togglehertz(pc),a5
	lea	l01a0(pc),a4
	bsr	copyoptxt 
	move.w	#$27f,l001d 
	move.w	#$27f,l0020 
	move.w	#$7300,l001f
	move.w	#$a0,l00b1
	move.w	#$140,l00b2 
	move.w	#$1e0,l00b3 
	move.w	#$280,l00b4 
	move.w	#$320,l00b5 
	move.w	#$3c0,l00b6 
	move.w	#$460,l00b7 
	moveq	#$14,d1 
	move.w	d1,l0018
	move.w	d1,l0024
	move.w	d1,l0029
	move.w	d1,l002a
	move.w	d1,l003a
	move.w	d1,l003c
	move.w	d1,l0040
	move.w	d1,l0043
	move.w	d1,l004b
	move.w	d1,l0050
	move.w	d1,l0053
	move.w	d1,l0059
	move.w	d1,l0060
	move.w	d1,l0074
	move.w	d1,l0087
	move.w	d1,l0088
	move.w	d1,l008d
	move.w	d1,l00f3
	move.w	d1,l011e
	move.w	d1,l0129
	move.w	d1,l005d
	move.w	d1,l0069
	move.w	d1,l006c
	move.w	d1,l0125
	move.b	d1,l00f9
	moveq	#$18,d1 
	move.b	d1,l0027
	move.b	d1,l0047
	move.b	d1,l0064
	move.b	d1,l00c2
	move.b	d1,l00c5
	move.w	#$f00,l002b 
	move.w	#$fb00,l002c
	move.w	#$13,l002d
	move.w	#$13,l0035
	move.b	#$1f,l002f
	move.b	#$1f,l0037
	move.b	#$16,l0031
	move.w	#$6e00,l0033
	move.w	#$500,l0034 
	move.w	#$28,l008f
	move.w	#$a00,l00f6 
	move.w	#$29f,l00f7 
	moveq	#$13,d1 
	move.w	d1,l011f
	move.w	d1,l012a
	move.w	#$15,l0054
	move.w	#$15,l0150
	moveq	#$17,d1 
	clr.b	l00e1 
	move.b	d1,l00e2
	move.b	d1,l00e3
	move.b	d1,l00e8
	move.b	#$c,l000e 
	move.w	#$13f,l00c0 
	move.w	#$13f,l00d2 
	move.w	#$7800,l00be
	move.w	#$7800,l00bf
	move.w	#$7800,l00d0
	move.w	#$7800,l00d1
	movem.l	colorvalues,d0-d1 
	movem.l	d0-d1,$ffff8240.w 
.FLUSH	BTST.B	#0,$fffffc00.w	IS A CHARACTER WAITING ?
	BEQ.S	.INTSON		BR. IF NOT
	MOVE.B	$fffffc02.w,D0	READ CHARACTER (& IGNORE IT)
	BRA.S	.FLUSH		CHECK FOR ANOTHER
.INTSON	lea	processing(pc),a6 
	moveq	#$1b,d0 
	moveq	#$b,d1
l000e	equ	*-1 
	bsr	printline 
fin_reloc	
alreadyinits	bsr	gettime 
	tst.w	d0
	bne.b	timedateval 
	lea	timetext(pc),a4 
	lea	invalidtime(pc),a5
	bsr	copyoptxt 
timedateval	lea	table,a1
	lea	docfile,a5
l0014	move.l	a5,(a1)+
l0015	tst.b	(a5)
	beq.b	cont
	cmpi.b	#$a,(a5)+ 
	bne.b	l0015 
	bra.b	l0014 
cont	suba.l	#table,a1 
	move.l	a1,d0 
	lsr.w	#2,d0 
	subq.w	#1,d0 
	move.w	d0,lastline 
	subq.w	#1,d0 
	tst.w	tableinit 
	bne.b	make45_1
	st	tableinit 
	move.w	d0,e_p_page_no
make45_1	subi.w	#$14,d0 
l0018	equ	*-2 
	move.w	d0,l0063
	move.w	lastline,d0 
	lea	l018b,a3
	pea	fakereturn(pc)
convertlnum	moveq	#3,d7 
doolnum	divu	#$a,d0
	swap	d0
	move.b	#$30,-(a3) 	;#'0' 
	add.b	d0,(a3) 
	clr.w	d0
	swap	d0
	dbf	d7,doolnum
	cmpi.b	#$30,(a3) 
	bne.b	nozeros2kill
	move.b	1(a3),(a3)
	move.b	2(a3),1(a3) 
	move.b	3(a3),2(a3) 
	move.b	#$20,3(a3)
	cmpi.b	#$30,(a3) 
	bne.b	nozeros2kill
	move.b	1(a3),(a3)
	move.b	2(a3),1(a3) 
	move.b	#$20,2(a3)
	cmpi.b	#$30,(a3) 
	bne.b	nozeros2kill
	move.b	1(a3),(a3)
	move.b	#$20,1(a3)
nozeros2kill	rts 
fakereturn	movea.l	screen_addr,a0
	move.w	#$27f,d0
l001d	equ	*-2 
ego1	move.w	#$ffff,(a0)+
	dbf	d0,ego1 
	lea	29440(a0),a0
l001f	equ	*-2 
	move.w	#$27f,d0
l0020	equ	*-2 
ego2	move.w	#$ffff,(a0)+
	dbf	d0,ego2 
	lea	egobars(pc),a6
	move.b	#$40,82(a6) 
	moveq	#0,d0 
	moveq	#0,d1 
	sf	ghoster 
	bsr	printline 
	clr.b	takemeout 
totalhome	lea	docfile,a5
	moveq	#0,d6 
gotomark	moveq	#0,d7 
	move.w	#$6677,d4 
	bsr	printpage 
	cmp.w	#$14,d6 
l0024	equ	*-2 
	bgt.b	pastline0 
	lea	foretext(pc),a6 
	move.w	#$6674,bartype
	bra.b	barprint
pastline0	lea	moretext(pc),a6 
	move.w	#$6d74,bartype
barprint	sf	ghoster 
	moveq	#0,d0 
	moveq	#$18,d1 
l0027	equ	*-1 
	bsr	printline 
	bra	get_key 
l0028	move.w	#0,$484.l 
	subi.w	#$14,d6 
l0029	equ	*-2 
	bsr	boringnums
	addi.w	#$14,d6 
l002a	equ	*-2 
	cmp.w	#$6677,d4 
	bne	notscrollup 
	movea.l	screen_addr,a0
	lea	3840(a0),a0 
l002b	equ	*-2 
	lea	-1280(a0),a1
l002c	equ	*-2 
	movem.l	a2-a4/d0-d6,-(a7) 
	move.w	#$13,d7 
l002d	equ	*-2 
scrollup	

	rept	32
	movem.l	(a0)+,a2-a4/d0-d6 
	movem.l	a2-a4/d0-d6,(a1)
	lea	40(a1),a1 
	endr

	dbf	d7,scrollup 
	movem.l	fortyzeros,a2-a4/d0-d6
	moveq	#$1f,d7 
l002f	equ	*-1 
scrollupclr	movem.l	a2-a4/d0-d6,(a1)
	lea	40(a1),a1 
	dbf	d7,scrollupclr
	movem.l	(a7)+,a2-a4/d0-d6 
	moveq	#$16,d1 
l0031	equ	*-1 
	bra	fin_scroll
notscrollup	movea.l	screen_addr,a0
	lea	28160(a0),a0
l0033	equ	*-2 
	lea	1280(a0),a1 
l0034	equ	*-2 
	movem.l	a2-a4/d0-d6,-(a7) 
	move.w	#$13,d7 
l0035	equ	*-2 
scrolldown

	rept	32
	lea	-40(a0),a0
	movem.l	(a0),a2-a4/d0-d6
	movem.l	a2-a4/d0-d6,-(a1) 
	endr

	dbf	d7,scrolldown 
	movem.l	fortyzeros,a2-a4/d0-d6
	moveq	#$1f,d7 
l0037	equ	*-1 
scrolldnclr	lea	-40(a1),a1
	movem.l	a2-a4/d0-d6,(a1)
	dbf	d7,scrolldnclr
	movem.l	(a7)+,a2-a4/d0-d6 
	moveq	#2,d1 
fin_scroll	lea	table,a1
	cmp.w	#$626b,d4 
	bne.b	notbk 
	subi.w	#$14,d6 
l003a	equ	*-2 
notbk	lsl.w	#2,d6 
	movea.l	0(a1,d6.w),a5 
	lsr.w	#2,d6 
	cmp.w	#$626b,d4 
	bne.b	nextline
	addi.w	#$14,d6 
l003c	equ	*-2 
nextline	lea	linebuffer,a6 
	cmpa.l	start_p_page,a5 
	blt.b	noghostout
	cmpa.l	end_p_page,a5 
	bge.b	noghostout
	sf	ghoster 
	bra.b	copyline
noghostout	st	ghoster 
copyline	move.b	(a5)+,(a6)+ 
	tst.b	(a5)
	beq.b	past_end
	cmpi.b	#$a,-1(a6)
	bne.b	copyline
	clr.b	(a6)+ 
	lea	linebuffer,a6 
	moveq	#0,d0 
	bsr	printline 
	move.w	l0063(pc),d0
	addi.w	#$14,d0 
l0040	equ	*-2 
	cmp.w	d0,d6 
	beq.b	past_end
	moveq	#0,d7 
	bra.b	prompt
past_end	moveq	#$21,d7 
	clr.b	(a6)+ 
	lea	linebuffer,a6 
	moveq	#0,d0 
	bsr	printline 
prompt	cmp.w	#$14,d6 
l0043	equ	*-2 
	beq.b	atstart 
	cmp.w	#$21,d7 
	beq.b	atend 
	cmpi.w	#$6d74,bartype
	beq.b	get_key 
	lea	moretext(pc),a6 
	move.w	#$6d74,bartype
	bra.b	print 
atstart	cmpi.w	#$6674,bartype
	beq.b	get_key 
	lea	foretext(pc),a6 
	move.w	#$6674,bartype
	bra.b	print 
atend	cmpi.w	#$6274,bartype
	beq.b	get_key 
	lea	backtext(pc),a6 
	move.w	#$6274,bartype
print	sf	ghoster 
	moveq	#0,d0 
	moveq	#$18,d1 
l0047	equ	*-1 
	bsr	printline 
get_key	move.b	#6,$484.l 
	bsr	wait_key
	swap	d0
	bsr	cleartopmess
	cmp.l	#$50,d0 
	bne.b	notcurdown
samecurdown	cmpi.w	#$6274,bartype
	beq.b	get_key 
	st	moved 
	addq.w	#1,d6 
	move.w	#$6677,d4 
	bra	l0028 
notcurdown	cmp.w	#$1c,d0 
	beq.b	samecurdown 
	cmp.w	#$72,d0 
	beq.b	samecurdown 
	cmp.l	#$48,d0 
	bne.b	notcup
	cmp.w	#$14,d6 
l004b	equ	*-2 
	beq.b	get_key 
	st	moved 
	subq.w	#1,d6 
	move.w	#$626b,d4 
	bra	l0028 
notcup	cmp.w	#$39,d0 
	beq	samescurdown
	cmp.w	#$66,d0 
	bne.b	notasterisk 
	cmpi.b	#2,$44c.w 
	beq.b	get_key 
	eori.b	#2,$ffff820a.w
	eori.w	#7,l00e7
	move.w	l00e7(pc),hurtztime 
	bra	get_key 
notasterisk	cmp.w	#2,d0 
	blt.b	notsetmark
	cmp.w	#$b,d0
	bgt.b	notsetmark
	lea	setnum(pc),a6 
commonmark	subq.b	#2,d0 
	move.b	#$31,(a6) 
	add.b	d0,(a6) 
	cmpi.b	#$3a,(a6) 
	bne.b	notm9 
	move.b	#$30,(a6) 
notm9	add.w	d0,d0 
	lea	mark0,a0
	adda.w	d0,a0 
	swap	d0
	cmp.w	#$aaaa,d0 
	beq.b	notset
	move.w	d6,(a0) 
	subi.w	#$14,(a0) 
l0050	equ	*-2 
	lea	markset(pc),a6
	sf	ghoster 
	moveq	#0,d0 
	moveq	#1,d1 
	bsr	printline 
	bra	get_key 
notsetmark	cmp.w	#$78,d0 
	blt.b	notmark 
	cmp.w	#$81,d0 
	bgt.b	notmark 
	subi.w	#$76,d0 
	lea	retnum(pc),a6 
	bra.b	commonmark
notset	move.w	(a0),d5 
	move.w	d5,d0 
	addi.w	#$14,d0 
l0053	equ	*-2 
	cmp.w	d0,d6 
	beq	get_key 
	st	moved 
	move.w	d5,d6 
	lea	markret(pc),a6
	sf	ghoster 
	moveq	#0,d0 
	moveq	#1,d1 
	bsr	printline 
	move.w	lastline,d5 
	subi.w	#$15,d5 
l0054	equ	*-2 
	cmp.w	d5,d6 
	ble	gotomark
	move.w	d5,d6 
	bra	gotomark
notmark	cmp.w	#$62,d0 
	bne.b	nothelp 
	bsr	printhelp 
	bra	get_key 
nothelp	cmp.l	#$3002e,d0
	bne.b	notcontc
	eori.l	#$7770777,$ffff8240.w 
	bra	get_key 
notcontc	cmp.l	#$140014,d0 
	bne.b	notcontt
	move.w	s_p_page_no,d6
	st	moved 
	bra	gotomark
notcontt	cmp.l	#$20030,d0
	bne.b	notcontb
	move.w	e_p_page_no,d6
	subi.w	#$14,d6 
l0059	equ	*-2 
	st	moved 
	bra	gotomark
notcontb	cmp.l	#$13001f,d0 
	bne.b	notconts
	bra	get_key 

notconts	cmp.l	#$60021,d0
	bne.b	notcontf
	eori.l	#0,l00a0
l005c	equ	*-8 
	subi.w	#$14,d6 
l005d	equ	*-2 
	bsr	printpage 
	bra	get_key 
notcontf	cmp.l	#$aaaa002e,d0 
	bne.b	notaltc 
	cmpi.b	#2,$44c.w 
	beq	get_key 
	bsr	setcolors 
notaltc	cmp.l	#$aaaa0014,d0 
	bne.b	notaltt 
	cmp.w	#$14,d6 
l0060	equ	*-2 
	beq	get_key 
	st	moved 
	bra	totalhome 
notaltt	cmp.l	#$aaaa0030,d0 
	bne.b	notaltb 
	cmpi.w	#$6274,bartype
	beq	get_key 
	st	moved 
last_page	move.w	#0,d6 
l0063	equ	*-2 
	bsr	printpage 
	lea	backtext(pc),a6 
	move.w	#$6274,bartype
	sf	ghoster 
	moveq	#0,d0 
	moveq	#$18,d1 
l0064	equ	*-1 
	bsr	printline 
	moveq	#$21,d7 
	bra	get_key 
notaltb	cmp.l	#$aaaa0022,d0 
	bne.b	notaltg 
	move.w	d6,l0066
	bsr	getlinenum
	cmp.w	#0,d6 
l0066	equ	*-2 
	beq	get_key 
	st	moved 
	cmp.w	#$ffff,d6 
	beq.b	last_page 
	bra	gotomark
notaltg	cmp.l	#$aaaa0021,d0 
	bne.b	notaltf 
	sf	ghoster 
	bsr	search
	bra	get_key 
notaltf	cmp.l	#$aaaa0031,d0 
	bne.b	notaltn 
	tst.b	doneasearch 
	beq	get_key 
	move.w	#$101d,direction
	move.w	#$4e71,previous 
	move.w	#$14,l012a
l0069	equ	*-6 
	move.l	#endmarker,l0130
commonnext	bsr	cleartopmess
	lea	searching(pc),a6
	moveq	#$22,d0 
	moveq	#1,d1 
	bsr	printline 
	bsr	nextsearch
	bra	get_key 
notaltn	cmp.l	#$aaaa0019,d0 
	bne.b	notaltp 
	tst.b	doneasearch 
	beq	get_key 
	subq.l	#1,l012c
	move.w	#$1025,direction
	move.w	#$528d,previous 
	move.l	#docfile,l0130
	move.w	#$14,l012a
l006c	equ	*-6 
	bra.b	commonnext
notaltp	cmp.w	#$40,d0 
	bne.b	notf6 
	eori.w	#1,ff_enable
	tst.w	ff_enable 
	beq.b	ffen
	lea	ffs_off(pc),a6
	lea	disabledtxt(pc),a5
	bra.b	dofftype
ffen	lea	ffs_on(pc),a6 
	lea	enabledtxt(pc),a5 
dofftype	lea	fftext(pc),a4 
	bsr	copyoptxt 
	moveq	#0,d0 
	moveq	#1,d1 
	bsr	printline 
	bsr	soundbell 
	bra	get_key 
notf6	cmp.w	#$41,d0 
	bne.b	notf7 
	bsr	sendchar
	bra	get_key 
notf7	cmp.w	#$42,d0 
	bne.b	notf8 
	eori.w	#1,biflag 
	tst.w	biflag
	beq.b	bien
	lea	disabledtxt(pc),a5
	bra.b	dobitxt 
bien	lea	enabledtxt(pc),a5 
dobitxt	lea	blditltext(pc),a4 
	bsr	copyoptxt 
	subi.w	#$14,d6 
l0074	equ	*-2 
	bsr	printpage 
	bra	get_key 
notf8	cmp.w	#$43,d0 
	bne	notf9 
	bsr	cleartopmess
	lea	quest_port(pc),a6 
	sf	ghoster 
	moveq	#0,d0 
	moveq	#1,d1 
	bsr	printline 
	bsr	soundbell 
nogood1	bsr	wait_key
	swap	d0
	cmp.w	#$3b,d0 
	blt.b	nogood1 
	cmp.w	#$3c,d0 
	bgt.b	nogood1 
	subi.w	#$3b,d0 
	lsl.b	#4,d0 
	bclr	#4,l01c1
	or.b	d0,l01c1
	tst.b	d0
	bne.b	isser 
	lea	paralleltxt(pc),a5
	bra.b	doport
isser	lea	serialtxt(pc),a5
doport	lea	prttyptext,a4 
	bsr	copyoptxt 
	bsr	cleartopmess
	lea	quest_qualty(pc),a6 
	moveq	#0,d0 
	moveq	#1,d1 
	bsr	printline 
nogood3	bsr	wait_key
	swap	d0
	cmp.w	#$3b,d0 
	blt.b	nogood3 
	cmp.w	#$3c,d0 
	bgt.b	nogood3 
	subi.w	#$3b,d0 
	lsl.b	#3,d0 
	bclr	#3,l01c1
	or.b	d0,l01c1
	tst.b	d0
	beq.b	isdraft 
	lea	finaltxt(pc),a5 
	bra.b	doqual
isdraft	lea	drafttxt(pc),a5 
doqual	lea	gfxquality,a4 
	bsr	copyoptxt 
	bsr	cleartopmess
	lea	quest_printr(pc),a6 
	moveq	#0,d0 
	moveq	#1,d1 
	bsr	printline 
nogood2	moveq	#0,d0 
	move.w	print_type(pc),d0 
	move.l	d0,d1 
	lsl.w	#1,d1 
	lsl.w	#2,d0 
	lea	printers(pc),a6 
	lea	setprts(pc),a5
	move.w	0(a5,d1.w),d1 
	andi.b	#$f8,l01c1
	or.b	d1,l01c1
	movea.l	0(a6,d0.w),a6 
	movea.l	a6,a5 
	lea	gfxprinter(pc),a4 
	bsr	copyoptxt 
	moveq	#$2c,d0 
	moveq	#1,d1 
	bsr	printline 
	bsr	wait_key
	swap	d0
	cmp.w	#$48,d0 
	beq.b	yo_curup
	cmp.w	#$50,d0 
	beq.b	yo_curdn
	swap	d0
	cmp.w	#$d,d0
	beq.b	gotprn
	bra.b	nogood2 
yo_curdn	subq.w	#1,print_type 
	cmpi.w	#$ffff,print_type 
	bne.b	nogood2 
	move.w	#3,print_type 
	bra.b	nogood2 
yo_curup	addq.w	#1,print_type 
	cmpi.w	#4,print_type 
	bne	nogood2 
	clr.w	print_type
	bra	nogood2 
gotprn	bsr	cleartopmess
	lea	quest_lines(pc),a6
	moveq	#0,d0 
	moveq	#1,d1 
	bsr	printline 
nogood4	lea	linesperpagt(pc),a6 
	moveq	#0,d0 
	move.w	linesperpage,d0 
	divu	#$a,d0
	move.w	#$3030,(a6) 
	add.b	d0,(a6) 
	swap	d0
	add.b	d0,1(a6)
	moveq	#$42,d0 
	moveq	#1,d1 
	bsr	printline 
nogood5	bsr	wait_key
	swap	d0
	cmp.w	#$48,d0 
	beq.b	yo_curup2 
	cmp.w	#$50,d0 
	beq.b	yo_curdown2 
	swap	d0
	cmp.w	#$d,d0
	beq.b	okgotlin
	bra.b	nogood5 
yo_curup2	addq.w	#1,linesperpage 
	cmpi.w	#$64,linesperpage 
	bne.b	nogood4 
	move.w	#2,linesperpage 
	bra.b	nogood4 
yo_curdown2	subq.w	#1,linesperpage 
	cmpi.w	#1,linesperpage 
	bne.b	nogood4 
	move.w	#$63,linesperpage 
	bra.b	nogood4 
okgotlin	bsr	cleartopmess
	bra	get_key 
notf9	cmp.w	#$44,d0 
	bne.b	notf10
	bsr	epsonprint
	bra	get_key 
notf10	cmp.w	#$3b,d0 
	bne.b	notf1 
	subi.w	#$14,d6 
l0087	equ	*-2 
	cmp.w	e_p_page_no,d6
	ble.b	ok_sb 
	addi.w	#$14,d6 
l0088	equ	*-2 
	lea	illeg_start(pc),a6
illeg_block	sf	ghoster 
	moveq	#0,d0 
	moveq	#1,d1 
	bsr	printline 
	bsr	soundbell 
	bra	get_key 
ok_sb	lsl.w	#2,d6 
	lea	table,a1
	move.l	0(a1,d6.w),start_p_page 
	lsr.w	#2,d6 
	move.w	d6,s_p_page_no
	bsr	printpage 
	bra	get_key 
notf1	cmp.w	#$3c,d0 
	bne.b	notf2 
	cmp.w	s_p_page_no,d6
	bge.b	ok_eb 
	lea	illeg_end(pc),a6
	bra.b	illeg_block 
ok_eb	lsl.w	#2,d6 
	lea	l01f9,a1
	move.l	0(a1,d6.w),end_p_page 
	lsr.w	#2,d6 
	move.w	d6,e_p_page_no
	subi.w	#$14,d6 
l008d	equ	*-2 
	bsr	printpage 
	bra	get_key 
notf2	cmp.l	#$380048,d0 
	bne.b	notscurup 
	cmpi.w	#$6674,bartype
	beq	get_key 
	st	moved 
	moveq	#0,d7 
	subi.w	#$28,d6 
l008f	equ	*-2 
	bmi.b	negad6
taken20	bsr	printpage 
	bra	prompt
negad6	moveq	#0,d6 
	bra.b	taken20 
notscurup	cmp.l	#$aaaa0010,d0 
	beq.b	theend
	cmp.l	#$320050,d0 
	bne	get_key 
samescurdown	cmpi.w	#$6274,bartype
	beq	get_key 
	st	moved 
	cmp.w	l0063,d6
	blt.b	taken20 
	bra	last_page 

theend	BTST.B	#0,$fffffc00.w
	BEQ.S	.INTSON
	MOVE.B	$fffffc02.w,D0
	BRA.S	theend
.INTSON	bsr	getkbdvbase 
	move.l	oldmouse,16(a0)
	move.w	#$3,-(sp)
	move.w	#$b,-(sp)
	move.w	#$23,-(a7) 	;kbrate 
	trap	#$e 
	addq.l	#6,a7 
	rts	

vsync	move.w	$468.w,d0 
sync	cmp.w	$468.w,d0 
	beq.b	sync
	rts 

copyoptxt	move.b	(a5)+,d0
	beq.b	imdone
	move.b	d0,(a4)+
	bra.b	copyoptxt 
imdone	rts 
cleartopmess	movem.l	a6/d0-d1,-(a7)
	lea	ablankline(pc),a6 
	moveq	#0,d0 
	moveq	#1,d1 
	bsr.b	printline 
	movem.l	(a7)+,a6/d0-d1
	rts 
printline	movem.l	a0-a6/d0-d7,-(a7) 
	move.w	d0,cursor_x 
	move.w	d1,cursor_y 
	lea	x_offsets,a1
	lea	y_offsets,a2
	lea	font,a4 
l00a0	equ	*-4 
	movea.l	screen_addr,a5
nextchar	moveq	#0,d0 
nextchar2	move.b	(a6)+,d0
	beq	endprintlin 
	cmp.w	#$40,d0 
	bne.b	notat 
	move.b	(a6)+,d0
	cmp.w	#$35,d0 
	beq.b	isital
	cmp.w	#$34,d0 
	bne.b	notital 
isital	subi.w	#$34,d0 
	move.w	d0,italic_on
	bra.b	nextchar2 
notital	cmp.w	#$48,d0 
	beq.b	isbold
	cmp.w	#$47,d0 
	bne.b	notbold 
isbold	subi.w	#$47,d0 
	move.w	d0,bold_on
	bra.b	nextchar2 
notbold	cmp.w	#$49,d0 
	beq.b	isinvert
	cmp.w	#$4a,d0 
	bne.b	notrealat 
isinvert	subi.w	#$49,d0 
	move.w	d0,invert_on
	bra.b	nextchar2 
notrealat	moveq	#$40,d0 
	subq.l	#1,a6 
notat	cmp.w	#9,d0 
	bne.b	nottab
	andi.w	#$f8,cursor_x 
	addq.w	#8,cursor_x 
	bra.b	nextchar
nottab	cmp.w	#$a,d0
	bne.b	notlf 
	addq.w	#1,cursor_y 
	bra.b	nextchar
notlf	cmp.w	#$d,d0
	bne.b	notspecial
	move.w	#0,cursor_x 
	bra	nextchar
notspecial	movea.l	a5,a0 
	move.w	cursor_x,d1 
	move.w	cursor_y,d2 
	add.w	d1,d1 
	add.w	d2,d2 
	adda.w	0(a1,d1.w),a0 
	adda.w	0(a2,d2.w),a0 
	lsl.w	#4,d0 
	lea	0(a4,d0.w),a3 
	movem.w	(a3),d0-d7
	tst.w	biflag
	bne.b	italicisoff 
	tst.w	bold_on 
	bne.b	boldisoff 
	movem.w	d0-d7,-(a7) 
	lsl.w	#1,d0 
	lsl.w	#1,d1 
	lsl.w	#1,d2 
	lsl.w	#1,d3 
	lsl.w	#1,d4 
	lsl.w	#1,d5 
	lsl.w	#1,d6 
	lsl.w	#1,d7 
	or.w	(a7)+,d0
	or.w	(a7)+,d1
	or.w	(a7)+,d2
	or.w	(a7)+,d3
	or.w	(a7)+,d4
	or.w	(a7)+,d5
	or.w	(a7)+,d6
	or.w	(a7)+,d7
boldisoff	tst.w	italic_on 
	bne.b	italicisoff 
	lsr.w	#1,d0 
	lsr.w	#1,d1 
	lsr.w	#1,d2 
	lsl.w	#1,d5 
	lsl.w	#1,d6 
	lsl.w	#1,d7 
italicisoff	tst.w	invert_on 
	bne.b	invertisoff 
	eori.w	#$ffff,d0 
	eori.w	#$ffff,d1 
	eori.w	#$ffff,d2 
	eori.w	#$ffff,d3 
	eori.w	#$ffff,d4 
	eori.w	#$ffff,d5 
	eori.w	#$ffff,d6 
	eori.w	#$ffff,d7 
invertisoff	tst.w	ghoster 
	beq.b	ghostisoff
	andi.w	#$55,d0 
	andi.w	#$aa,d1 
	andi.w	#$55,d2 
	andi.w	#$aa,d3 
	andi.w	#$55,d4 
	andi.w	#$aa,d5 
	andi.w	#$55,d6 
	andi.w	#$aa,d7 
ghostisoff	move.b	d0,(a0) 
	move.b	d1,160(a0)
l00b1	equ	*-2 
	move.b	d2,320(a0)
l00b2	equ	*-2 
	move.b	d3,480(a0)
l00b3	equ	*-2 
	move.b	d4,640(a0)
l00b4	equ	*-2 
	move.b	d5,800(a0)
l00b5	equ	*-2 
	move.b	d6,960(a0)
l00b6	equ	*-2 
	move.b	d7,1120(a0) 
l00b7	equ	*-2 
	addq.w	#1,cursor_x 
	bra	nextchar
endprintlin	movem.l	(a7)+,a0-a6/d0-d7 
	rts 
soundbell	pea	$20007
	move.w	#3,-(a7) 	;bconout
	trap	#$d 
	addq.l	#6,a7 
	rts 
epsonprint	movem.l	a0-a6/d0-d7,-(a7) 
	sf	ghoster 
	bsr.b	isitawake 
	tst.l	d0
	beq.b	dumpit
	movem.l	(a7)+,a0-a6/d0-d7 
	rts 
isitawake	move.w	#$11,-(a7) 	;cprnos 
	trap	#1
	addq.l	#2,a7 
	tst.w	d0
	bmi.b	printok 
	lea	no_print(pc),a6 
	move.w	#$6e70,bartype
	sf	ghoster 
	moveq	#0,d0 
	moveq	#1,d1 
	bsr	printline 
	bsr.b	soundbell 
	move	#$ff,d0 
	rts 
printok	moveq	#0,d0 
brad	rts 
dumpit	bsr	flash 
	movea.l	#screen,a0 
	lea	30720(a0),a0
l00be	equ	*-2 
	lea	save_screen,a1
	lea	30720(a1),a1
l00bf	equ	*-2 
	move.w	#$13f,d0
l00c0	equ	*-2 
savebotline	move.l	(a0)+,(a1)+ 
	dbf	d0,savebotline
	bsr.b	soundbell 
	bsr	flash 
	lea	printingline(pc),a6 
	moveq	#0,d0 
	moveq	#$18,d1 
l00c2	equ	*-1 
	bsr	printline 
	clr.w	linesprinted
	move.w	printerdata(pc),-(a7) 
	move.w	#$21,-(a7) 	;setprt 
	trap	#$e 
	addq.l	#4,a7 
	move.w	s_p_page_no,-(a7) 
printloop	lea	save_screen,a0
	move.w	#$13f,d0
cptline	move.l	#0,(a0)+
	dbf	d0,cptline
	movem.l	a0-a6/d0-d7,-(a7) 
	move.w	s_p_page_no,d6
	lea	table,a6
	lsl.w	#2,d6 
	movea.l	0(a6,d6.w),a5 
	moveq	#0,d1 
	move.l	#save_screen,screen_addr
	bsr	copyaline 
	move.l	#screen,screen_addr
	moveq	#0,d0 
	move.w	e_p_page_no,d0
	sub.w	s_p_page_no,d0
	lea	l0191(pc),a3
	bsr	convertlnum 
	move.w	#$7072,bartype
	lea	linesleft(pc),a6
	moveq	#$18,d0 
	moveq	#$18,d1 
l00c5	equ	*-1 
	bsr	printline 
	tst.w	ff_enable 
	bne.b	nottimeforff
	move.w	linesprinted,d1 
	cmp.w	linesperpage,d1 
	bne.b	nottimeforff
	moveq	#$c,d0
	bsr	printer 
	clr.w	linesprinted
nottimeforff	movem.l	(a7)+,a0-a6/d0-d7 
	lea	linebuffer,a5 
printloop2	moveq	#0,d0 
	move.b	(a5)+,d0
	tst.b	d0
	beq.b	done_gfx
	cmp.b	#$60,d0 
	bne.b	notgfxp 
	cmpi.b	#$60,(a5) 
	bne.b	is_gfx
	addq.l	#1,a5 
	bra.b	notgfxp 
is_gfx	addq.l	#5,a5 
	bra.b	printloop2
notgfxp	cmp.b	#$40,d0 
	bne.b	notpat
	cmpi.b	#$34,(a5) 
	blt.b	notpat
	cmpi.b	#$35,(a5) 
	beq.b	notdoubpat
	cmpi.b	#$47,(a5) 
	blt.b	notpat
	cmpi.b	#$4a,(a5) 
	bgt.b	notpat
notdoubpat	moveq	#$1b,d0 
notpat	bsr.b	printer 
	pea	$600ff
	trap	#1
	addq.l	#4,a7 
	cmp.w	#$1b,d0 
	beq.b	printfinish 
	swap	d0
	cmp.w	#$61,d0 
	beq.b	printfinish 
	bra.b	printloop2
done_gfx	addq.w	#1,s_p_page_no
	addq.w	#1,linesprinted 
	move.w	s_p_page_no,d6
	move.w	e_p_page_no,d7
	cmp.w	d6,d7 
	bge	printloop 
printfinish	move.w	(a7)+,s_p_page_no 
	moveq	#5,d7 
printbeep	moveq	#7,d0 
	bsr.b	printer 
	dbf	d7,printbeep
	tst.w	ff_enable 
	bne.b	noendff 
	moveq	#$c,d0
	bsr.b	printer 
noendff	lea	save_screen,a0
	lea	30720(a0),a0
l00d0	equ	*-2 
	movea.l	#screen,a1 
	lea	30720(a1),a1
l00d1	equ	*-2 
	move.w	#$13f,d0
l00d2	equ	*-2 
restbotline	move.l	(a0)+,(a1)+ 
	dbf	d0,restbotline
	movem.l	(a7)+,a0-a6/d0-d7 
	rts 
printer	move.w	d0,-(a7)
	pea	$30000
	trap	#$d 
	addq.l	#6,a7 
	rts 
flash	eori.l	#$7770777,$ffff8240.w 
	move	#$ff,d0 
hangabaht	dbf	d0,hangabaht
	rts 
wait_key	move.b	mouse_click,d0
	cmp.b	#$fa,d0 
	bne.b	notleftbut
	move.l	#$480038,d0 
	rts 
notleftbut	cmp.b	#$f9,d0 
	bne.b	noclick 
	move.l	#$500032,d0 
	rts 
noclick	tst.w	mouse_moved 
	beq.b	nomousey
	bmi.b	mousedown 
	move.l	#$500000,d0 
clrmovement	clr.w	mouse_moved 
	rts 
mousedown	move.l	#$480000,d0 
	bra.b	clrmovement 
nomousey	pea	$600ff
	trap	#1
	addq.l	#4,a7 
	tst.l	d0
	beq.b	wait_key
	move.l	d0,-(a7)
	pea	$bffff
	trap	#$d 
	addq.l	#4,a7 
	btst	#3,d0 
	beq.b	notalt
	move.l	(a7)+,d0
	move.w	#$aaaa,d0 
	rts 
notalt	move.l	(a7)+,d0
	rts 
printhelp	clr.b	$484.w
	movea.l	#screen,a0 
	lea	save_screen,a1
	move.w	#$3e7f,d0 
savescr	move.w	(a0)+,(a1)+ 
	dbf	d0,savescr
	movea.l	#screen,a4 
	move.w	#$1f3f,d0 
helpcls	clr.l	(a4)+ 
	dbf	d0,helpcls
	lea	helpscreen(pc),a6 
	move.b	linesperpagt(pc),1746(a6) 
	move.b	l01c3(pc),1747(a6)
	moveq	#0,d0 
	moveq	#0,d1 
l00e1	equ	*-1 
	sf	ghoster 
	bsr	printline 
	lea	timetext,a6 
	moveq	#$3c,d0 
	moveq	#$17,d1 
l00e2	equ	*-1 
	bsr	printline 
	lea	helpbottom,a6 
	moveq	#$4d,d0 
	moveq	#$17,d1 
l00e3	equ	*-1 
	bsr	printline 
updatetime	lea	timetext,a6 
	movem.l	a0-a6/d0-d7,-(a7) 
	bsr	gettime 
	tst.w	d0
	beq.b	invalidtime1
	moveq	#0,d1 
	moveq	#0,d2 
	move.w	d0,d1 
	move.w	d0,d2 
	andi.w	#$1f,d0 
	andi.w	#$7e0,d1
	andi.w	#$f800,d2 
	lsr.w	#5,d1 
	lsr.w	#8,d2 
	lsr.w	#3,d2 
	movea.l	a6,a0 
	move.w	d2,d7 
	bsr	hextoasc
	move.w	d1,d7 
	bsr	hextoasc
	move.w	d0,d7 
	bsr	hextoasc
	bsr	gettime 
	swap	d0
	moveq	#0,d1 
	moveq	#0,d2 
	move.w	d0,d1 
	move.w	d0,d2 
	andi.l	#$1f,d0 
	andi.w	#$1e0,d1
	andi.w	#$fe00,d2 
	lsr.w	#5,d1 
	lsr.w	#8,d2 
	lsr.w	#1,d2 
	move.l	4.w,d7
	clr.b	d7
	movea.l	d7,a0 
	tst.w	28(a0)
	bne.b	notyankee 
	exg	d1,d0 
notyankee	lea	9(a6),a0
	moveq	#0,d7 
	move.w	d0,d7 
	bsr.b	hextoasc
	move.w	d1,d7 
	bsr.b	hextoasc
	move.w	d2,d7 
	addi.w	#$50,d7 
	bsr.b	hextoasc
invalidtime1	movem.l	(a7)+,a0-a6/d0-d7 
	bsr	vsync 
	subq.w	#1,hurtztime
	bne.b	noblink 
	move.w	#$19,hurtztime
l00e7	equ	*-6 
	cmpi.b	#$54,timetext 
	beq.b	noblink 
	eori.b	#$1a,2(a6)
	eori.b	#$1a,5(a6)
	moveq	#$3c,d0 
	moveq	#$17,d1 
l00e8	equ	*-1 
	bsr	printline 
noblink	pea	$600ff
	trap	#1
	addq.l	#4,a7 
	tst.l	d0
	beq	updatetime
	movea.l	screen_addr,a0
	lea	save_screen,a1
	move.w	#$3e7f,d0 
restscr	move.w	(a1)+,(a0)+ 
	dbf	d0,restscr
	move.b	#6,$484.w 
	rts 
gettime	move.w	#$17,-(a7) 	;gettime
	trap	#$e 
	addq.l	#2,a7 
	rts 
hextoasc	divu	#$a,d7
	addi.b	#$30,d7 
	move.b	d7,(a0)+
	swap	d7
	addi.b	#$30,d7 
	move.b	d7,(a0)+
	addq.l	#1,a0 
	moveq	#0,d7 
	rts 
copyaline	lea	linebuffer,a6 
	cmpa.l	start_p_page,a5 
	blt.b	l00ee 
	cmpa.l	end_p_page,a5 
	bge.b	l00ee 
	sf	ghoster 
	bra.b	l00ef 
l00ee	st	ghoster 
l00ef	tst.b	(a5)
	beq.b	l00f0 
	move.b	(a5)+,(a6)+ 
	cmpi.b	#$a,-1(a6)
	bne.b	l00ef 
	move.b	#0,(a6)+
l00f0	lea	linebuffer,a6 
	moveq	#0,d0 
	bsr	printline 
	rts 
printpage	move.w	#0,$484.l 
	pea	fakereturn2(pc) 
boringnums	movem.l	a0-a6/d0-d7,-(a7) 
	moveq	#0,d0 
	move.w	d6,d0 
	lea	l0188,a3
	bsr	convertlnum 
	moveq	#0,d0 
	move.w	d6,d0 
	addi.w	#$14,d0 
l00f3	equ	*-2 
	cmp.w	lastline,d0 
	blt.b	notonlastpag
	move.w	lastline,d0 
	subq.w	#1,d0 
notonlastpag	lea	l0189,a3
	bsr	convertlnum 
	lea	current_ptop(pc),a6 
	sf	ghoster 
	moveq	#$3f,d0 
	moveq	#0,d1 
	bsr	printline 
	movem.l	(a7)+,a0-a6/d0-d7 
	rts 
fakereturn2	movem.l	a0-a6/d0-d7,-(a7) 
	movea.l	screen_addr,a0
	lea	2560(a0),a0 
l00f6	equ	*-2 
	move.w	#$29f,d7
l00f7	equ	*-2 
	movem.l	fortyzeros,a2-a4/d0-d6
clspage	movem.l	a2-a4/d0-d6,(a0)
	lea	40(a0),a0 
	dbf	d7,clspage
	movem.l	(a7)+,a0-a6/d0-d7 
	moveq	#2,d1 
	moveq	#$14,d3 
l00f9	equ	*-1 
	lsl.w	#2,d6 
l00fa	lea	table,a2
	movea.l	0(a2,d6.w),a5 
	bsr	copyaline 
	addq.w	#1,d1 
	addq.l	#4,d6 
	dbf	d3,l00fa
	lsr.w	#2,d6 
	subq.w	#1,d6 
	move.b	#6,$484.l 
	rts 
sendchar	movem.l	a0-a6/d0-d7,-(a7) 
	move.b	#7,$484.w 
	move.l	#$63686172,l017b
	move.l	#$61637465,l017c
startinput	bsr	cleartopmess
	lea	input_text(pc),a6 
	moveq	#0,d0 
	moveq	#1,d1 
	bsr	printline 
	moveq	#0,d5 
curprint	lea	cancinput(pc),a6
	moveq	#$39,d0 
	moveq	#1,d1 
	bsr	printline 
	lea	inputted(pc),a6 
	move.b	#$db,0(a6,d5.w) 
	move.b	#$20,1(a6,d5.w) 
	clr.b	2(a6,d5.w)
	moveq	#$2f,d0 
	moveq	#1,d1 
	bsr	printline 
inploop	bsr	wait_key
	cmp.w	#$1b,d0 
	bne.b	notesc
	tst.w	d5
	bne.b	startinput
	bra.b	inploop 
notesc	tst.w	d5
	bne.b	morethan0 
	sf	hexmode 
	cmp.w	#$32,d0 
	bgt.b	inploop 
morethan0	cmp.w	#1,d5 
	bgt.b	morethan1 
	cmpi.b	#$32,inputted 
	bne.b	morethan1 
	cmp.w	#$35,d0 
	bgt.b	inploop 
morethan1	cmp.w	#2,d5 
	bgt.b	morethan2 
	cmpi.w	#$3235,inputted 
	bne.b	morethan2 
	cmp.w	#$36,d0 
	bgt.b	inploop 
morethan2	cmp.w	#$d,d0
	bne.b	notreturn 
	tst.w	d5
	beq	no_input
	cmp.w	#3,d5 
	bne.b	inploop 
	bra.b	entered 
notreturn	cmp.w	#8,d0 
	bne.b	notdel
	tst.w	d5
	beq.b	inploop 
	subq.w	#1,d5 
	bra	curprint
notdel	cmp.w	#$24,d0 
	bne.b	notstring 
	tst.w	d5
	bne.b	inploop 
	st	hexmode 
	bra.b	okchar
notstring	cmp.w	#$30,d0 
	blt	inploop 
	cmp.w	#$39,d0 
	ble.b	okchar
	tst.w	hexmode 
	beq	inploop 
	ori.w	#$20,d0 
	cmp.w	#$61,d0 
	blt	inploop 
	cmp.w	#$66,d0 
	bgt	inploop 
okchar	lea	inputted(pc),a6 
	move.b	d0,0(a6,d5.w) 
	cmp.w	#3,d5 
	beq	curprint
	addq.w	#1,d5 
	bra	curprint
entered	lea	inputted(pc),a6 
	bsr.b	get_num 
	bsr	isitawake 
	tst.l	d0
	bmi.b	nodump2 
	bsr	printer 
nodump2	move.l	#$6e657874,l017b
	move.l	#$20636861,l017c
	bra	startinput
no_input	bsr	cleartopmess
	move.b	#6,$484.w 
	movem.l	(a7)+,a0-a6/d0-d7 
	rts 
get_num	movem.l	a6/d1-d2,-(a7)
	moveq	#0,d0 
	moveq	#0,d1 
	moveq	#0,d2 
	move.b	(a6)+,d0
	cmp.b	#$24,d0 
	beq.b	hex 
	subi.b	#$30,d0 
	mulu	#$64,d0 
	move.b	(a6)+,d1
	subi.b	#$30,d1 
	mulu	#$a,d1
	add.b	d1,d0 
	move.b	(a6)+,d1
	subi.b	#$30,d1 
	add.b	d1,d0 
	bra.b	done_num
hex	move.b	(a6)+,d0
	cmp.b	#$39,d0 	;#'9'
	bgt.b	notnumeric
	subi.b	#$30,d0 
donum1	lsl.w	#4,d0 
	bra.b	nextnybble
notnumeric	subi.b	#$57,d0 
	bra.b	donum1
nextnybble	move.b	(a6)+,d1
	cmp.b	#$39,d1 	;#'9'
	bgt.b	notnumeric2 
	subi.b	#$30,d1 
donum2	add.b	d1,d0 
	bra.b	done_num
notnumeric2	subi.b	#$57,d1 
	bra.b	donum2
done_num	movem.l	(a7)+,a6/d1-d2
	rts 
search	move.b	#7,$484.w 
	movem.l	a0-a6/d0-d7,-(a7) 
resetinput	lea	input_string(pc),a6 
	moveq	#0,d0 
	moveq	#1,d1 
	bsr	printline 
	moveq	#0,d5 
curprint2	lea	cancinput(pc),a6
	moveq	#$39,d0 
	moveq	#1,d1 
	bsr	printline 
	lea	inputted_str(pc),a6 
	move.b	#$db,0(a6,d5.w) 
	move.b	#$20,1(a6,d5.w) 
	clr.b	2(a6,d5.w)
	moveq	#$14,d0 
	moveq	#1,d1 
	bsr	printline 
inploop2	bsr	wait_key
	cmp.b	#$60,d0 
	beq.b	inploop2
	cmp.b	#$40,d0 
	beq.b	inploop2
	cmp.b	#$1b,d0 
	bne.b	notesc2 
	tst.w	d5
	bne.b	resetinput
	bra.b	inploop2
notesc2	cmp.b	#$d,d0
	bne.b	notreturn2
	tst.w	d5
	beq	no_input2 
	cmp.w	#1,d5 
	beq.b	inploop2
	bra.b	entered2
notreturn2	cmp.b	#8,d0 
	bne.b	notdel2 
	tst.w	d5
	beq.b	inploop2
	subq.w	#1,d5 
	bra.b	curprint2 
notdel2	cmp.b	#$20,d0 
	blt.b	inploop2
	cmp.b	#$7f,d0 
	bgt.b	inploop2
	lea	inputted_str(pc),a6 
	move.b	d0,0(a6,d5.w) 
	cmp.w	#$23,d5 
	beq.b	curprint2 
	addq.w	#1,d5 
	bra	curprint2 
entered2	bsr	cleartopmess
	lea	input_case(pc),a6 
	moveq	#0,d0 
	moveq	#1,d1 
	bsr	printline 
notn	bsr	wait_key
	cmp.w	#$d,d0
	beq.b	defy
	swap	d0
	cmp.w	#$15,d0 
	bne.b	noty
defy	st	case_sens 
	bra.b	do_search 
noty	cmp.w	#$31,d0 
	bne.b	notn
	sf	case_sens 
do_search	bsr	cleartopmess
	lea	searching(pc),a6
	moveq	#$22,d0 
	moveq	#1,d1 
	bsr	printline 
	move.w	d6,-(a7)
	cmp.w	#$14,d6 
l011e	equ	*-2 
	blt.b	onpage0 
	subi.w	#$14,d6 
l011f	equ	*-2 
onpage0	lsl.w	#2,d6 
	lea	table,a2
	movea.l	0(a2,d6.w),a5 
	tst.w	moved 
	bne.b	wasmoved
	lea	docfile,a5
wasmoved	move.w	(a7)+,d6
	lea	inputted_str(pc),a6 
	movea.l	a6,a0 
	moveq	#0,d1 
donextml	move.b	(a0),d0 
	cmp.b	#$db,d0 
	beq.b	endml 
	addq.w	#1,d1 
	tst.b	case_sens 
	bmi.b	iscs
	cmp.b	#$41,d0 	;#'a'
	blt.b	iscs
	cmp.b	#$5a,d0 	;#'z'
	bgt.b	iscs
	ori.b	#$20,d0 
iscs	move.b	d0,(a0)+
	bra.b	donextml
endml	clr.b	(a0)
	move.w	d1,len_search 
	subq.w	#2,d1 
	move.l	a6,l0127
	move.w	d1,l0128
	st	doneasearch 
	move.w	#$101d,direction
	move.w	#$4e71,previous 
	move.l	#endmarker,l0130
	move.w	#$14,l012a
l0125	equ	*-6 
	bra.b	pastnexts 
nextsearch	movem.l	a0-a6/d0-d7,-(a7) 
	lea	0.l,a6
l0127	equ	*-4 
	move.l	#0,d1 
l0128	equ	*-2 
	move.w	d6,-(a7)
	cmp.w	#$14,d6 
l0129	equ	*-2 
	blt.b	onpage02
	subi.w	#$14,d6 
l012a	equ	*-2 
onpage02	lsl.w	#2,d6 
	lea	table,a2
	movea.l	0(a2,d6.w),a5 
	tst.w	moved 
	bne.b	wasmoved2 
	lea	docfile,a5
l012c	equ	*-4 
wasmoved2	move.w	(a7)+,d6
pastnexts	move.b	(a6)+,d7
searchloop	cmpa.l	#endmarker,a5 
l0130	equ	*-4 
	beq	lost
direction	move.b	(a5)+,d0
	tst.b	case_sens 
	bmi.b	iscs2 
	cmp.b	#$41,d0 	;#'a'
	blt.b	iscs2 
	cmp.b	#$5a,d0 	;#'z'
	bgt.b	iscs2 
	ori.b	#$20,d0 
iscs2	cmp.b	d0,d7 
	bne.b	searchloop
	movem.l	a5-a6/d0-d2,-(a7) 
previous	addq.l	#1,a5 
realsearch	move.b	(a5)+,d0
	tst.b	case_sens 
	bmi.b	iscs3 
	cmp.b	#$41,d0 	;#'a'
	blt.b	iscs3 
	cmp.b	#$5a,d0 	;#'z'
	bgt.b	iscs3 
	ori.b	#$20,d0 
iscs3	move.b	(a6)+,d2
	tst.b	case_sens 
	bmi.b	iscs4 
	cmp.b	#$41,d2 	;#'a'
	blt.b	iscs4 
	cmp.b	#$5a,d2 	;#'z'
	bgt.b	iscs4 
	ori.b	#$20,d2 
iscs4	cmp.b	d0,d2 
	bne	falsealarm
	dbf	d1,realsearch 
	movem.l	(a7)+,a0-a1/d0-d2 
	subq.l	#2,a5 
	suba.l	d1,a5 
	move.l	a5,l0138
	addq.l	#1,a5 
	move.l	a5,l012c
	clr.w	moved 
	lea	table,a6
searchline	cmpi.l	#0,(a6)+
l0138	equ	*-4 
	ble.b	searchline
	subq.l	#8,a6 
	suba.l	#table,a6 
	move.l	a6,d6 
	lsr.w	#2,d6 
	move.w	d6,l0139
	movem.l	(a7)+,a0-a6/d0-d7 
	move.w	#0,d6 
l0139	equ	*-2 
	moveq	#0,d7 
	move.b	#2,l0140
	move.w	l0063(pc),d5
	move.w	d6,d0 
	cmp.w	d5,d6 
	ble.b	notonlastpa2
	moveq	#$21,d7 
	sub.w	d5,d0 
	add.b	d0,l0140
	move.w	d5,d6 
notonlastpa2	bsr	printpage 
	lea	table,a5
	move.w	l0139(pc),d0
	lsl.w	#2,d0 
	movea.l	0(a5,d0.w),a5 
	lea	linebuffer,a6 
	pea	(a6)
	movea.l	l0138(pc),a4
copysearline	cmpa.l	a4,a5 
	beq.b	atstartofwrd
	move.b	(a5)+,(a6)+ 
	bra.b	copysearline
atstartofwrd	move.b	#$40,(a6)+
	move.b	#$49,(a6)+
	move.w	len_search,d0 
copyfoundwrd	move.b	(a5)+,(a6)+ 
	subq.w	#1,d0 
	bne.b	copyfoundwrd
	move.b	#$40,(a6)+
	move.b	#$4a,(a6)+
copysearlin2	move.b	(a5)+,(a6)+ 
	cmpi.b	#$a,-1(a6)
	beq.b	printfoundwd
	cmpi.b	#0,-1(a6) 
	bne.b	copysearlin2
printfoundwd	clr.b	(a6)+ 
	moveq	#0,d0 
	moveq	#0,d1 
l0140	equ	*-1 
	movea.l	(a7)+,a6
	bsr	printline 
	sf	ghoster 
	bsr	cleartopmess
	lea	foundit(pc),a6
	moveq	#$22,d0 
	moveq	#1,d1 
	bsr	printline 
	addq.l	#4,a7 
	bra	prompt
falsealarm	movem.l	(a7)+,a5-a6/d0-d2 
	bra	searchloop
lost	sf	ghoster 
	lea	notfound(pc),a6 
	moveq	#$20,d0 
	moveq	#1,d1 
	bsr	printline 
	bsr	soundbell 
	bra.b	lostret 
no_input2	bsr	cleartopmess
lostret	movem.l	(a7)+,a0-a6/d0-d7 
	rts 
getlinenum	movem.l	a0-a6/d7/d0-d5,-(a7)
	move.w	d6,l014a
	move.b	#7,$484.w 
startinput_l	lea	getlinetext(pc),a6
	moveq	#0,d0 
	moveq	#1,d1 
	bsr	printline 
	moveq	#0,d5 
curprint_l	lea	inputtedlin(pc),a6
	move.b	#$db,0(a6,d5.w) 
	move.b	#$20,1(a6,d5.w) 
	clr.b	2(a6,d5.w)
	moveq	#$34,d0 
	moveq	#1,d1 
	bsr	printline 
inploop_l	bsr	wait_key
	cmp.b	#$1b,d0 
	bne.b	notesc_l
	tst.w	d5
	bne.b	startinput_l
	bra.b	inploop_l 
notesc_l	cmp.w	#$d,d0
	bne	notcr_l 
	bsr	cleartopmess
	tst.w	d5
	bne.b	morethan0_l 
	move.w	#0,d6 
l014a	equ	*-2 
	movem.l	(a7)+,a0-a6/d7/d0-d5
	rts 
morethan0_l	cmp.w	#4,d5 
	beq.b	all4chars 
	subq.w	#1,d5 
	move.w	d5,d0 
	lea	buff4nums,a0
	movea.l	a0,a1 
	movea.l	a6,a2 
copypartnum	move.b	(a2)+,(a1)+ 
	dbf	d0,copypartnum
	movea.l	a6,a2 
	moveq	#2,d0 
	sub.w	d5,d0 
fillzeros	move.b	#$30,(a2)+
	dbf	d0,fillzeros
copynumson	move.b	(a0)+,(a2)+ 
	dbf	d5,copynumson 
all4chars	moveq	#0,d0 
	move.b	(a6)+,d0
	subi.b	#$30,d0 
	mulu	#$3e8,d0
	moveq	#0,d1 
	move.b	(a6)+,d1
	subi.b	#$30,d1 
	mulu	#$64,d1 
	add.w	d1,d0 
	moveq	#0,d1 
	move.b	(a6)+,d1
	subi.b	#$30,d1 
	mulu	#$a,d1
	add.w	d1,d0 
	moveq	#0,d1 
	move.b	(a6)+,d1
	subi.b	#$30,d1 
	add.w	d1,d0 
	move.w	d0,d6 
	move.w	lastline,d5 
	subi.w	#$15,d5 
l0150	equ	*-2 
	cmp.w	d5,d6 
	blt.b	okgotl
	move	#$ff,d6 
okgotl	movem.l	(a7)+,a0-a6/d7/d0-d5
	rts 
notcr_l	cmp.b	#8,d0 
	bne.b	notdel_l
	tst.w	d5
	beq	inploop_l 
	subq.w	#1,d5 
	bra	curprint_l
notdel_l	cmp.b	#$30,d0 	;#'0'
	blt	inploop_l 
	cmp.b	#$39,d0 	;#'9'
	bgt	inploop_l 
	move.b	d0,0(a6,d5.w) 
	cmp.w	#4,d5 
	beq	curprint_l
	addq.w	#1,d5 
	bra	curprint_l

setupmouse	bsr.b	getkbdvbase 
	move.l	16(a0),oldmouse
	move.l	#mousevec,16(a0)
	rts 
getkbdvbase	move.w	#$22,-(a7) 	;kbdvbase 
	trap	#$e 
	addq.l	#2,a7 
	movea.l	d0,a0 
	rts 
mousevec	move.l	d0,-(a7)
	move.b	(a0),mouse_click
	moveq	#0,d0 
	move.b	2(a0),d0
	ext.w	d0
	move.w	d0,mouse_moved
	move.l	(a7)+,d0
	rts 
setcolors	movem.l	a0-a6/d0-d7,-(a7) 
	movem.l	$ffff8240.w,d6-d7 
	andi.l	#$7770777,d6
	andi.l	#$7770777,d7
	movem.l	d6-d7,colorvalues 
	lea	colorkeys(pc),a6
	moveq	#0,d0 
	moveq	#$17,d1 
	sf	ghoster 
	bsr	printline 
	lea	colorseld(pc),a6
	moveq	#$11,d0 
	moveq	#1,d1 
	bsr	printline 
coloop	move.w	colorselect(pc),d7
	move.w	d7,d6 
	mulu	#$e,d6
	lea	colortypes(pc),a6 
	lea	0(a6,d6.w),a6 
	moveq	#$21,d0 
	moveq	#1,d1 
	bsr	printline 
	lea	colorvalues(pc),a0
	add.w	d7,d7 
	move.w	0(a0,d7.w),d2 
	move.w	d2,d3 
	move.w	d2,d4 
	andi.w	#$700,d2
	andi.w	#$70,d3 
	andi.w	#7,d4 
coloop2	move.w	d2,d5 
	move.w	d3,d6 
	move.w	d4,d7 
	lsr.w	#8,d5 
	addi.b	#$30,d5 
	move.b	d5,rgbtext
	lsr.w	#4,d6 
	addi.b	#$30,d6 
	move.b	d6,l01ca
	addi.b	#$30,d7 
	move.b	d7,l01cb
	lea	colorval(pc),a6 
	moveq	#$32,d0 
	moveq	#1,d1 
	bsr	printline 
	bsr	wait_key
	cmp.w	#$d,d0
	beq	fincol
	swap	d0
	cmp.w	#$48,d0 
	bne.b	notccup 
	subq.w	#1,colorselect
	cmpi.w	#$ffff,colorselect
	bne	coloop
	move.w	#3,colorselect
	bra	coloop
notccup	cmp.w	#$50,d0 
	bne.b	notccdown 
	addq.w	#1,colorselect
	cmpi.w	#4,colorselect
	bne	coloop
	clr.w	colorselect 
	bra	coloop
notccdown	cmp.w	#$67,d0 
	bne.b	notk7 
	addi.w	#$100,d2
	cmp.w	#$800,d2
	bne.b	notr8 
	clr.w	d2
notr8	move.w	d2,d0 
	or.w	d3,d0 
	or.w	d4,d0 
commoncol	move.w	colorselect(pc),d1
	add.w	d1,d1 
	lea	$ffff8240.w,a0
	lea	colorvalues(pc),a1
	move.w	d0,0(a0,d1.w) 
	move.w	d0,0(a1,d1.w) 
	bra	coloop2 
notk7	cmp.w	#$68,d0 
	bne.b	notk8 
	addi.w	#$10,d3 
	cmp.w	#$80,d3 
	bne.b	notg8 
	clr.w	d3
notg8	move.w	d3,d0 
	or.w	d2,d0 
	or.w	d4,d0 
	bra.b	commoncol 
notk8	cmp.w	#$69,d0 
	bne.b	notk9 
	addq.w	#1,d4 
	cmp.w	#8,d4 
	bne.b	notb8 
	clr.w	d4
notb8	move.w	d4,d0 
	or.w	d2,d0 
	or.w	d3,d0 
	bra.b	commoncol 
notk9	cmp.w	#$6a,d0 
	bne.b	notk4 
	subi.w	#$100,d2
	cmp.w	#$ff00,d2 
	bne.b	notrneg 
	move.w	#$700,d2
notrneg	move.w	d2,d0 
	or.w	d3,d0 
	or.w	d4,d0 
	bra.b	commoncol 
notk4	cmp.w	#$6b,d0 
	bne.b	notk5 
	subi.w	#$10,d3 
	cmp.w	#$fff0,d3 
	bne.b	notgneg 
	moveq	#$70,d3 
notgneg	move.w	d3,d0 
	or.w	d2,d0 
	or.w	d4,d0 
	bra	commoncol 
notk5	cmp.w	#$6c,d0 
	bne.b	notk6 
	subq.w	#1,d4 
	cmp.w	#$ffff,d4 
	bne.b	notbneg 
	moveq	#7,d4 
notbneg	move.w	d4,d0 
	or.w	d2,d0 
	or.w	d3,d0 
	bra	commoncol 
notk6	bra	coloop
fincol	lea	ablankline(pc),a6 
	moveq	#0,d0 
	moveq	#$17,d1 
	bsr	printline 
	bsr	cleartopmess
	movem.l	(a7)+,a0-a6/d0-d7 
	rts 

getlinetext:	dc.b	'                        @GEnter line number to go to:@H ',0
inputtedlin:	dc.b	'€ ',0
	ds.b	4 
hexmode:	ds.b	2 
input_text:	dc.b	'@GEnter code of '
l017b:	dc.b	'char'
l017c:	dc.b	'acter to be sent to printer:@H ',0 
inputted:	dc.b	'€ ',$D
	ds.b	4
cancinput:	dc.b	'@G(just Return to cancel)@H',0 
input_string:	dc.b	'@GEnter text to find:@H ',0
inputted_str:	dc.b	'€ '
	ds.b	36
input_case:	dc.b	'@G',9,9,9,'  Case sensitive search (Y/n)?@H',0 
case_sens:	dc.b	0 
searching:	dc.b	'@GSearching...@H',0
notfound:	dc.b	'@GText not found!@H',0 
foundit:	dc.b	'@GFound text!@H',0 
egobars:	dc.b	'@IDOC Displayer v5.7 by @GTHE@H çéèêëí. HELP for keys. Showing lines ' 
current_ptop:	dc.b	'@I0000'
l0188:	dc.b	'-0000' 
l0189:	dc.b	'@J'
takemeout:	dc.b	'@I of 0000'
l018b:	dc.b	'@J',0
foretext:	dc.b	'@I                [Shift]',2,':Forwards   Alt-Q:Quit   Alt-B:Last line                @J',0
moretext:	dc.b	'@I[Shift]',1,':Back  [Shift]',2,':Forwards  Alt-Q:Quit  Alt-T:First line  Alt-B:Last line @J',0
backtext:	dc.b	'@I                 [Shift]',1,':Back    Alt-Q:Quit   Alt-T:First line                 @J',0
printingline:	dc.b	'@I     Printing document:      lines left to print... Undo or Esc to cancel.      @J',0
linesleft:	dc.b	'@I0000'
l0191:	dc.b	'@J',0
no_print:	dc.b	'@I                @GPrinter not responding! Is it connected? Online?@H                @J',0
illeg_start:	dc.b	'@I                           Block @4START@5 after block @4END@5?                         @J',0
illeg_end:	dc.b	'@I                           Block @4END@5 before block @4START@5?                        @J',0
ffs_off:	dc.b	'@I                             Form feeds @Gdisabled@H.                               @J',0
ffs_on:	dc.b	'@I                             Form feeds @Genabled.@H                                @J',0
markset:	dc.b	'@I                                 Marker #' 
setnum:	dc.b	'0 set.                                 @J',0 
markret:	dc.b	'@I                                 Marker #' 
retnum:	dc.b	'0 recalled.                              @J',0 
processing:	dc.b	'Processing... please wait.',0
helpscreen:	dc.b	9,'      @GThe@H ÄÅÇÉÑÖ Üáàâäãå @GDoc Displayer v5.7@H by @GTHE@H çéèêëí',$D,$A,'⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ'
	dc.b	'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø',$D,$A,'ü F1',9,' Mark start of block to print ü Co' 
	dc.b	'ntrol+C',9,9,'Invert Colors ü',$D,$A,'ü F2',9,'   Mark end of block to print ü Control+S',9,' Speak block out loud ü'
	dc.b	$D,$A,'ü F3  '
l019d:	dc.b	'Toggle graphics printing on/off ü Control+B',9,' Goto bottom of block ü',$D,$A,'ü F4  '
l019e:	dc.b	'Toggle graphic text mode on/off ü Control+T',9,'    Goto top of block ü',$D,$A,'ü F6',9,'      Toggle formfeeds' 
	dc.b	' on/off ü Control+F',9,' Toggle between fonts ü',$D,$A,'ü F7  Send a character to the printer √ƒƒƒƒƒƒƒƒƒƒƒƒ' 
	dc.b	'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥',$D,$A,'ü F8',9,' Enable/disable @Gbold@H & @4italic@5 ü Alternate+C',9,9,'   ' 
l019f:	dc.b	'Set colors ü',$D,$A,'ü F9',9,9,'      Printer options ü Alternate+G',9,9,'  Goto a line ü',$D,$A,'ü F10',9,9,'   Print marked' 
	dc.b	' block ü Alternate+F',9,9,'    Find text ü',$D,$A,'√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥ Alternate+N',9,9,'    ' 
	dc.b	'Find next ü',$D,$A,'ü Numeric keys 1 to 0',9,'  Set markers ü Alternate+P',9,9,'Find previous ü',$D,$A,'ü Alternate + 1' 
	dc.b	' to 0   Recall markers ü Alternate+B',9,'   Goto bottom of doc ü',$D,$A,'√ƒƒƒƒƒƒƒƒ But. = mouse button ƒƒƒƒ' 
	dc.b	'ƒƒƒƒ¥ Alternate+T',9,'      Goto top of doc ü',$D,$A,'ü Shift+',2,' / Space / RBut.   Page down ü Alternate+Q',9,9 
	dc.b	9,' Quit ü',$D,$A,'ü Shift+',1,' / LBut.',9,'      Page up √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥',$D,$A,'ü ',2,' / Retur' 
	dc.b	'n / Mouse ',2,9,'    Line down ü Esc or Undo   Abort printing/speaking ü',$D,$A,'ü ',1,' / Mouse ',1,9,9,'      Line u'
	dc.b	'p ü * on keypad',9,'   ' 
l01a0:	dc.b	'Toggle 50/60 Hertz ü',$D,$A,'¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ' 
	dc.b	'ƒƒƒƒŸ',$D,$A,'⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø',$D,$A,'ü Graphi'
	dc.b	'cs printing: ' 
l01a1:	dc.b	'ON     Graphic text mode: '
l01a2:	dc.b	'OFF    Bold & italic: '
blditltext:	dc.b	' ENABLED ü',$D,$A,'ü Printer port: ' 
prttyptext:	dc.b	'PARALLEL       Formfeeds: '
fftext:	dc.b	' ENABLED       Print quality: '
gfxquality:	dc.b	'DRAFT ü',$D,$A,'ü Printer: ' 
gfxprinter:	dc.b	'EPSON BLACK & WHITE DOT MATRIX  Lines/page: 00   ',0 
timetext:	dc.b	'        ,  /  /  ',0 
helpbottom:	dc.b	' ü',$D,$A,'¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ',0
disabledtxt:	dc.b	'DIS',0 
enabledtxt:	dc.b	' EN',0 
paralleltxt:	dc.b	'PARALLE',0 
serialtxt:	dc.b	'  SERIA',0 
drafttxt:	dc.b	'DRAFT',0 
finaltxt:	dc.b	'FINAL',0 
invalidtime:	dc.b	'TIME/DATE INVALID',0 
coloronlytx8:	dc.b	'        '
coloronlytxt:	dc.b	'Color only',0
setcolorstxt:	dc.b	'Set colors',0
togglehertz:	dc.b	'Toggle 50/60 Hertz',0
	dc.b	0 
printers:	DC.L	ataribwdm
	dc.l	ataricldm 
	dc.l	ataribwdw 
	dc.l	epsonbwdm 
ataribwdm:	dc.b	'ATARI BLACK & WHITE DOT MATRIX',0
ataricldm:	dc.b	'ATARI COLOR DOT MATRIX        ',0
ataribwdw:	dc.b	'ATARI BLACK & WHITE DAISYWHEEL',0
epsonbwdm:	dc.b	'EPSON BLACK & WHITE DOT MATRIX',0
setprts:	ds.b	3 
	dc.b	2,0 
	dc.b	1,0 
	dc.b	4 
quest_port:	dc.b	'   Select printer port:    F1...Centronics (Parallel)    F2...RS-232 (Serial)   ',0
quest_qualty:	dc.b	'           Select graphic print quality:    F1...Draft    F2...Final',0
quest_printr:	dc.b	'      Select printer using ',1,', ',2,' and Return: ',0
quest_lines:	dc.b	'           Select number of lines per page using ',1,', ',2,' and Return: ',0
ablankline:	dc.b	'                                                                        '
	dc.b	'        '
printerdata:	dc.b	$00 
l01c1:	dc.b	$04 
linesperpagt:	dc.b	'5' 
l01c3:	dc.b	'5',$00,$00 
hurtztime:	dc.b	$00,$01 
colorvalues:	dc.w	$000,$666,$770,$606 
colorselect:	dc.b	$00,$00 
colorseld:	dc.b	'Color selected: '
	dc.b	$00 
colorval:	dc.b	'RGB value' 
	dc.b	': '
rgbtext:	dc.b	'0' 
l01ca:	dc.b	'0' 
l01cb:	dc.b	'0',$00 
colorkeys:	dc.b	'@I@G',$01,' + '
	dc.b	$02,': select color    Keypad 789/456: increase/decrease RGB'
	dc.b	'    Return to finish@H@J'
	dc.b	$00 
colortypes:	dc.b	'0 (paper)' 
	dc.b	'    ',$00,'1 (ink)    '
	dc.b	'  ',$00,'2 (bar ink)  '
	dc.b	$00,'3 (bar paper)',$00,$00
start_p_page:	DC.L	docfile
end_p_page:	DC.L	endmarker
mark0:	dc.b	$01,$0B,$05,$D3,$00,')',$00,$00 
	dcb.b	6,0 
linesperpage:	dc.b	$00,'7' 
italic_on:	dc.b	$00,$01 
bold_on:	dc.b	$00,$01 
invert_on:	dc.b	$00,$01 
