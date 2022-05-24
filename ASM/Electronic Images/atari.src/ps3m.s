;PS3M 0.950 020+ 14-bit stereo surround version ;) 19.03.1995
;Copyright (c) Jarno Paananen a.k.a. Guru / S2 1994-95
;Some portions based on STMIK 0.9฿ by Sami Tammilehto / PSI of Future Crew

;ASM-ONE 1.20 or newer is required unless disable020 is set to 1, when
;at least 1.09 (haven't tried older) is sufficient.


SURROUND = 1
STEREO = 2
MONO = 3
REAL = 4
STEREO14 = 5

DISABLED = 1
ENABLED = 2

mtS3M = 1
mtMOD = 2
mtMTM = 3
mtXM  = 4

BUFFER = 16*1024				; MUST BE 2^N
						; MIN 4K
debug = 0
fromasmone = 0
allocchans = 1
disable020 = 0
beta = 1

GADGETS = 14
CTRL_C	= 12

	incdir	include:
	include	Guru.i
	include	exec/types.i
	include	ps3m.i

	include exec/io.i
	include exec/memory.i
	include	exec/execbase.i
;	include	lvo3.0/exec_lib.i
	include	exec/exec_lib.i
	include	hardware/intbits.i
	include	graphics/gfxbase.i

	include	libraries/reqtools.i
	include	libraries/reqtools_lib.i
	include	dos/dos.i
	include	dos/dos_lib.i

	include	intuition/intuition_lib.i
;	include	lvo3.0/intuition_lib.i
	include	intuition/intuition.i

	include	graphics/graphics_lib.i
;	include	lvo3.0/graphics_lib.i

	include	libraries/ppbase.i
	include	libraries/Powerpacker_lib.i

	include	libraries/xpk.i

	include	resources/cia_lib.i

	include	workbench/startup.i

	
VER 	macro
	dc.b	`Version 3.10฿ / 19.03.1995`,10
	endm

sVER	macro
	dc.b	`Replay version 0.950/020+ / 19.03.1995 `,10,10
	endm



wb	macro
	btst	#14,2(a6)
	dc	$66f8
	endm

iword	macro
	ror	#8,\1
	endm

ilword	macro
	ror	#8,\1
	swap	\1
	ror	#8,\1
	endm

tlword	macro
	move.b	\1,\2
	ror.l	#8,\2
	move.b	\1,\2
	ror.l	#8,\2
	move.b	\1,\2
	ror.l	#8,\2
	move.b	\1,\2
	ror.l	#8,\2
	endm

tword	macro
	move.b	\1,\2
	ror	#8,\2
	move.b	\1,\2
	ror	#8,\2
	endm


	section	detach,code
CreateProc
	Push	All

	BaseReg	data,a5
	lea	data,a5

	Push	d0/a0

	sub.l	a1,a1
	CLIB	Exec,FindTask
	move.l	d0,a4

	moveq	#0,d7

	ifeq	fromasmone
	tst.l   $ac(a4)
	bne.b	.cli

	lea	$5c(a4),a0
	CALL	WaitPort

	lea	$5c(a4),a0
	CALL	GetMsg
	move.l	d0,d7

	Pull	d0/a0
	bra.b	.noparams

.cli	endc

	Pull	d0/a0
	move.l	a0,cmdline
	clr.b	-1(a0,d0.l)
	tst.b	(a0)
	beq.b	.noparams
	st	params(a5)

.noparams
	lea	_DOSName(pc),a1
	moveq	#0,d0
	CALL	OpenLibrary
	move.l	d0,_DOSBase(a5)

	tst	params(a5)
	beq.b	.no
	bsr	parsecmdline

.no	lea	_RTName(pc),a2
	move.l	a2,a1
	moveq	#0,d0
	CLIB	Exec,OpenLibrary
	move.l	d0,_RTBase(a5)
	beq.b	print

	lea	_PPName(pc),a2
	move.l	a2,a1
	moveq	#0,d0
	CALL	OpenLibrary
	move.l	d0,_PPBase(a5)
	beq.b	print

	ifne	fromasmone
	Pull	All
	jmp	alkuu
	else

	move.l	pr_CurrentDir(a4),d1
	beq.b	.oji
	C5LIB	DOS,DupLock
	move.l	d0,lock(a5)

.oji	move.l	#procname,d1
	moveq	#-1,d2
	lea	CreateProc-4(pc),a0
	move.l	(a0),d3
	move.l	d3,segment(a5)
	clr.l   (a0)
	move.l	#4096,d4
	C5LIB	DOS,CreateProc
	tst.l	d7
	beq.b	poiss
	CLIB	Exec,Forbid
	move.l	d7,a1
	CALL	ReplyMsg
	endc

poiss	Pull	All
	moveq	#0,d0
	rts

;; ERROR

print	lea	nolib(pc),a0
	move.l	a0,d2
	lea	nap-nolib(a0),a0
.l	move.b	(a2)+,(a0)+
	bne.b	.l
	move.b	#10,-1(a0)
	sub.l	d2,a0
	move.l	a0,d3
printa	C5LIB	DOS,Output
	move.l	d0,d1
 	beq.b	poiss
	CALL	Write
	bra.b	poiss

parsecmdline
	move.l	cmdline(pc),a0

.argumentloop	
	tst.b	(a0)
	beq	.exit
	cmp.b	#` `,(a0)
	bne.b	.juu
	addq.l	#1,a0
	bra.b	.argumentloop

.juu	cmp.b	#`?`,(a0)
	beq	.apua

	cmp.b	#`-`,(a0)
	bne	.filename

.optio	addq.l	#1,a0
	move.b	(a0),d0
	cmp.b	#`Z`,d0
	bhs.b	.eid
	add.b	#`a`-`A`,d0
.eid
	cmp.b	#`r`,(a0)
	beq.b	.rate

	cmp.b	#`v`,(a0)
	beq.b	.boost

	cmp.b	#`m`,(a0)
	beq.b	.pmode

	cmp.b	#`s`,(a0)
	bne	.inva

.system	addq.l	#1,a0

	moveq	#0,d0
	move.b	(a0)+,d0
	sub	#`0`-1,d0	
	cmp	#DISABLED,d0
	blt	.inva
	cmp	#ENABLED,d0
	bgt	.inva
	move	d0,fstate(a5)
	addq	#8,forced(a5)
	bra.b	.skip

.pmode	addq.l	#1,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	sub	#`0`-1,d0
	cmp	#SURROUND,d0
	blt.b	.inva
	cmp	#STEREO14,d0
	bgt.b	.inva

	move	d0,fpmode(a5)
	addq	#4,forced(a5)
	bra.b	.skip

.boost	addq.l	#1,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	sub.b	#`0`,d0
	bmi.b	.inva
	cmp	#8,d0
	bhi.b	.inva

	move.l	d0,fboost(a5)
	addq	#2,forced(a5)
	bra.b	.skip

.rate	addq.l	#1,a0
	moveq	#0,d1
.los	moveq	#0,d0
	move.b	(a0)+,d0
	beq.b	.lop
	cmp	#` `,d0
	beq.b	.lop

	sub	#`0`,d0
	bmi.b	.inva
	cmp	#9,d0
	bgt.b	.inva
	mulu	#10,d1
	add	d0,d1
	bra.b	.los

.lop	cmp.l	#4000,d1
	blt.b	.inva

	cmp.l	#56000,d1
	bgt.b	.inva

	move.l	d1,frate(a5)
	addq	#1,forced(a5)

.skip	tst.b	(a0)
	beq.b	.exit
	cmp.b	#` `,(a0)+
	bne.b	.skip
	bra	.argumentloop

.inva	lea	invalid(pc),a0
	bra.b	.qq

.filename
	lea	fname2,a1
	cmp.b	#`"`,(a0)
	beq.b	.quotes
.loo	move.b	(a0)+,d0
	move.b	d0,(a1)+
	beq.b	.findmodulename
	cmp.b	#` `,d0
	bne.b	.loo
	clr.b	-1(a1)
	bra.b	.findmodulename

.quotes	addq.l	#1,a0
.luu	move.b	(a0)+,d0
	move.b	d0,(a1)+
	beq.b	.findmodulename
	cmp.b	#`"`,d0
	bne.b	.luu
	clr.b	-1(a1)

.findmodulename
	lea	fname,a3
	lea	fname2,a2
.search	move.b	-(a1),d0
	cmp.b	#`:`,d0
	beq.b	.found
	cmp.b	#`/`,d0
	beq.b	.found
	cmp.l	a1,a2
	bne.b	.search
	subq.l	#1,a1
.found
	addq.l	#1,a1
.cp	move.b	(a1)+,(a3)+
	bne.b	.cp
	bra	.argumentloop

.exit	tst.b	fname2
	beq.b	.apu
	rts

.apu
.apua	lea	usage(pc),a0
.qq	move.l	a0,d2
.l	tst.b	(a0)+
	bne.b	.l
	sub.l	d2,a0
	move.l	a0,d3
	addq.l	#4,sp			; skip return
	bra	printa

cmdline	dc.l	0

ver	dc.b	`$VER: PS3M `
	VER
	dc.b	0

procname dc.b	`PS3M!`,0
nolib	dc.b	`You need `
nap	dcb.b	21
invalid	dc.b	`Invalid command line option!`,10,10
usage	dc.b	`PS3M `
	VER
	sVER
	dc.b	`Usage: PS3M [options] [filename] [options]`,10
	dc.b	`Options: -r##### Mixing rate (default 16000)`,10
	dc.b	`         -v#     Volume boost (default 0)`,10
	dc.b	`         -m#     Playing mode:`,10
	dc.b	`                 0 = Surround (default)`,10
	dc.b	`                 1 = Stereo`,10
	dc.b	`                 2 = Mono`,10
	dc.b	`                 3 = Real surround`,10
	dc.b	`                 4 = 14-bit stereo`,10
	dc.b	`         -s#     System state:`,10
	dc.b	`                 0 = Disabled (default)`,10
	dc.b	`                 1 = Enabled`,10,0

_DOSName DOSNAME
_RTName REQTOOLSNAME
_PPName	PPNAME


;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญ
;ญ   PS3M - The S3M Player  ญ
;ญ	 Version 3.05฿	    ญ
;ญ ฉ 1994-95 Jarno Paananen ญ
;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญ

	section	PS3M,code
alkuu	movem.l	d0-a6,-(sp)

	lea	data,a5

	sub.l	a1,a1
	CLIB	Exec,FindTask
	move.l	d0,task(a5)

	lea	_XpkName(a5),a1
	moveq	#0,d0
	CALL	OpenLibrary
	move.l	d0,_XpkBase(a5)

	moveq	#-1,d0
	CALL	AllocSignal
	move.l	d0,signaali(a5)
	bmi	exit

	move.l	lock(a5),d1
	beq.b	.ohitaaa
	C5LIB	DOS,CurrentDir

.ohitaaa
	move.l	_RTBase(a5),a1
	move.l	rt_GfxBase(a1),_GFXBase(a5)
	move.l	rt_IntuitionBase(a1),_IntBase(a5)

	lea	configname(a5),a0
	moveq	#2,d0
	moveq	#MEMF_PUBLIC,d1
	lea	config(a5),a1
	lea	conlen(a5),a2
	sub.l	a3,a3
	bsr	LoadData

	clr	noconf(a5)

	tst.l	d0
	bpl.b	.pe

	st	noconf(a5)

.pe	tst	noconf(a5)
	bne.b	.skiba

	bsr	GetPlayMode
	move	d0,pmode(a5)
	btst	#2,forced+1(a5)
	beq.b	.q1
	move	d0,fpmode(a5)
.q1	bsr	GetSystemState
	move	d0,system(a5)
	btst	#3,forced+1(a5)
	beq.b	.q2
	move	d0,fstate(a5)
.q2
	bsr	GetDefaultRate
	move.l	d0,mixingrate(a5)

	bsr	GetDefaultBoost
	move.l	d0,vboost(a5)

	bsr	GetBufferSize

	bsr	GetBanner

.skiba	C5LIB	Int,OpenWorkBench
	move.l	d0,a0
	move.l	a0,wbscr(a5)

	moveq	#0,d0
	move.b	sc_BarHeight(a0),d0
	move	d0,bar(a5)
	add.b	sc_WBorTop(a0),d0
	add	d0,winstr+6(a5)
	move	d0,topbor(a5)

	move	sc_Width(a0),d0
	asr	#1,d0
	move	winstr+4(a5),d1
	asr	#1,d1
	sub	d1,d0
	move	d0,winstr(a5)

	move	sc_Height(a0),d0
	asr	#1,d0
	move	winstr+6(a5),d1
	asr	#1,d1
	sub	d1,d0
	move	d0,winstr+2(a5)

	tst	params(a5)
	bne.b	conttaa

	tst	bann(a5)
	bne.b	conttaa

	lea	alkutext(a5),a1
	lea	tags(a5),a0
	sub.l	a3,a3
	move.l	a3,a4
	lea	contta2(a5),a2
	C5LIB	RT,rtEZRequestA
	tst.l	d0
	bne.b	.nexit
	bra	exit

.nexit	subq.l	#1,d0
	beq.b	conttaa

	lea	alkutext2(a5),a1
	lea	tags(a5),a0
	sub.l	a3,a3
	move.l	a3,a4
	lea	contta(a5),a2
	C5LIB	RT,rtEZRequestA

conttaa	lea	winstr(a5),a0
	C5LIB	Int,OpenWindow
	move.l	d0,winpoin(a5)
	beq	exit

	move.l	d0,a0
	move.l	wd_RPort(a0),rast(a5)

	bsr	drawtexture

event	moveq	#23,d0
	lea	nimi(a5),a0
.spc	move.b	#` `,(a0)+
	dbf	d0,.spc

	lea	Name(a5),a0
	move.l	winpoin(a5),a1
	sub.l	a2,a2
	moveq	#1,d0
	C5LIB	Int,RefreshGList

	move.l	winpoin(a5),a0
	lea	winname(a5),a1
	lea	scrname(a5),a2
	CALL	SetWindowTitles

	and	#~SELECTED,Pause+12(a5)
	and	#~SELECTED,Mute+12(a5)

	lea	Pause(a5),a0
	move.l	winpoin(a5),a1
	sub.l	a2,a2
	moveq	#1,d0
	CALL	RefreshGList

	lea	position(a5),a0
	move.l	winpoin(a5),a1
	sub.l	a2,a2
	moveq	#AUTOKNOB!FREEHORIZ!PROPBORDERLESS!PROPNEWLOOK,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#-1,d3
	moveq	#-1,d4
	moveq	#1,d5
	CALL	NewModifyProp

	lea	position(a5),a0
	move.l	winpoin(a5),a1
	sub.l	a2,a2
	moveq	#1,d0
	CALL	RefreshGList

	tst	params(a5)
	bne	lataa
	
event2	moveq	#0,d7
	sub.l	a4,a4

	move.l	winpoin(a5),a0
	move.l	wd_UserPort(a0),a2
	move.b	15(a2),d1
	moveq	#0,d0
	bset	d1,d0
	bset	#CTRL_C,d0
	CLIB	Exec,Wait
	move.l	d0,d6
eventloop
	move.l	a2,a0
	CALL	GetMsg
	tst.l	d0
	beq.b	eventdone

	move.l	d0,a1

	moveq	#0,d7
	cmpi.l	#INTUITICKS,im_Class(a1)
	bne.b	.aj
	moveq	#1,d7
	bra.b	.rep
.aj
	move.l	im_Class(a1),d2
	move	im_Code(a1),d3
	move.l	im_IAddress(a1),a4
.rep	CALL	ReplyMsg
	bra.b	eventloop

eventdone
	btst	#CTRL_C,d6
	bne.b	closeup
		
	tst	d7
	beq.b	kidp

	move	gvolume+12(a5),d0
	and	#SELECTED,d0
	beq.b	kidp
	bsr	saataa

kidp	cmp.l	#GADGETUP,d2
	beq	Painettu

	cmp.l	#MOUSEBUTTONS,d2
	beq.b	button

.aj	cmp.l	#CLOSEWINDOW,d2
	bne	event2

closeup	move.l	winpoin(a5),a0
	C5LIB	Int,CloseWindow
	clr.l	winpoin(a5)
	bra	exit

button	cmp	#MENUDOWN,d3
	bne	event2

	not	zoomstate(a5)
	bne	pienenna

	move.l	winpoin(a5),a0
	move	wd_TopEdge(a0),d0
	add	winstr+6(a5),d0

	move.l	wbscr(a5),a1
	cmp	sc_Height(a1),d0
	blt.b	.ok

	move	sc_Height(a1),d1
	sub	d0,d1
	ext.l	d1
	moveq	#0,d0
	C5LIB	Int,MoveWindow

	move.l	winpoin(a5),a0

.ok	move	winstr+6(a5),d1
	sub	bar(a5),d1
	moveq	#0,d0
	C5LIB	Int,SizeWindow

	bsr.b	waitsize
	pea	event2(pc)
	bra	drawtexture

waitsize
	moveq	#0,d7
wsize	move.l	winpoin(a5),a0
	move.l	wd_UserPort(a0),a2
	move.b	15(a2),d1
	moveq	#0,d0
	bset	d1,d0
	CLIB	Exec,Wait

.loop	move.l	a2,a0
	CALL	GetMsg
	tst.l	d0
	beq.b	eventd

	move.l	d0,a1
	move.l	im_Class(a1),d2
	cmp.l	#NEWSIZE,d2
	bne.b	.ksl
	moveq	#1,d7
.ksl	CALL	ReplyMsg
	bra.b	.loop

eventd	tst	d7
	beq.b	wsize
	rts

pienenna
	move.l	winpoin(a5),a0
	lea	gvolume(a5),a1
	moveq	#GADGETS,d0
	C5LIB	Int,RemoveGList

	move	winstr+6(a5),d1
	sub	bar(a5),d1
	neg	d1
	moveq	#0,d0
	move.l	winpoin(a5),a0
	CALL	SizeWindow
	bra	event2

Painettu
	cmp.l	#gvolume,a4
	bne.b	.ed

	pea	event2(pc)
	bra	saataa

.ed	cmp.l	#Name,a4
	bne.b	.dd
	pea	event2(pc)
	bra	aboutti

.dd	cmp.l	#Prefs,a4
	bne.b	.ddq

	pea	event2(pc)
	bra	override

.ddq	cmp.l	#Play,a4
	bne	event2



****  playmodule
modplayer
	move.l	s3m(a5),d0
	beq.b	dnid
	move.l	d0,a1
	move.l	s3mlen(a5),d0
	CLIB	Exec,FreeMem
	clr.l	s3m(a5)

dnid	tst.l	reqptr(a5)
	bne.b	.kej

	sub.l	a0,a0
	moveq	#RT_FILEREQ,d0
	C5LIB	RT,rtAllocRequestA
	move.l	d0,reqptr(a5)
	bne.b	.okei

	lea	outofmemory(a5),a0
	bsr	error
	bra	event2

.okei	tst	noconf(a5)
	bne.b	.kej

	bsr	GetDefaultDir
	tst.l	d0
	beq.b	.kej

	move.l	reqptr(a5),a1
	lea	diretags(a5),a0
	move.l	d0,4(a0)			; Set directory
	CALL	rtChangeReqAttrA

.kej	move.l	reqptr(a5),a1
	lea	playtags(a5),a0
	lea	fname,a2
	lea	title7(a5),a3
	C5LIB	RT,rtFileRequestA
	tst.l	d0
	beq	event2

	move.l	d0,a2
	move.l	reqptr(a5),a0
	move.l	rtfi_Dir(a0),a1
	move.l	a2,a0
	bsr	NewProgram

	move.l	d0,program(a5)
	move	d1,maxfile(a5)
	clr	progpos(a5)

	move.l	a2,a0
	C5LIB	RT,rtFreeFileList

nextafile
	move.l	program(a5),a0
	move	progpos(a5),d0
	bsr	GetName

	move.l	d0,a0
	lea	fname2,a1
.lopa	move.b	(a0)+,(a1)+
	bne.b	.lopa

	lea	fname,a1
	lea	fname2,a2
	move.l	a2,a3
.find	move.b	(a3)+,d0
	beq.b	nimee2
	cmp.b	#`/`,d0
	beq.b	.pathia
	cmp.b	#`:`,d0
	bne.b	.find
.pathia	move.l	a3,a2
	bra.b	.find
nimee2	move.b	(a2)+,(a1)+
	bne.b	nimee2

lataa	lea	fname2,a0
	moveq	#2,d0
	moveq	#MEMF_PUBLIC,d1
	lea	s3m(a5),a1
	lea	s3mlen(a5),a2
	sub.l	a3,a3
	bsr	LoadData
	tst.l	d0
	beq.b	okeei

moka	C5LIB	PP,ppErrorMessage
	move.l	d0,a0
	bsr	error
	clr.l	s3m(a5)
	clr	PS3M_eject(a5)
	tst	params(a5)
	bne	exit
	bra	ejecti

okeei	clr	PS3M_initialized(a5)
	clr	PS3M_reinit(a5)
hepoinen
	clr	PS3M_eject(a5)
	clr	PS3M_position(a5)
	clr	PS3M_play(a5)

	move.l	a5,-(sp)
	bsr	init
	move.l	(sp)+,a5
	tst	d0
	bne	errore

	st	PS3M_play(a5)
	clr	PS3M_paused(a5)

	lea	btitle,a0
	move.l	#`00:0`,(a0)+
	move	#`0 `,(a0)+
	move.l	mname(a5),a1
.lep	move.b	(a1)+,(a0)+
	bne.b	.lep

happo	move.l	mname(a5),a1
	lea	nimi(a5),a0
	moveq	#23,d0
.copy	tst.b	(a1)
	beq.b	spacee
	move.b	(a1)+,(a0)+
	dbf	d0,.copy
	bra.b	lu9

spacee	move.b	#` `,(a0)+
	dbf	d0,spacee

lu9	move.l	winpoin(a5),a0
	lea	btitle,a1
	lea	scrname(a5),a2
	C5LIB	Int,SetWindowTitles

	and	#~SELECTED,Pause+12(a5)
	and	#~SELECTED,Mute+12(a5)

	tst	zoomstate(a5)
	bne.b	soii

	lea	Name(a5),a0
	move.l	winpoin(a5),a1
	sub.l	a2,a2
	moveq	#1,d0
	C5LIB	Int,RefreshGList

	lea	Pause(a5),a0
	move.l	winpoin(a5),a1
	sub.l	a2,a2
	moveq	#1,d0
	C5LIB	Int,RefreshGList

soii	tst	PS3M_initialized(a5)
	bne.b	.kej2

	st	PS3M_initialized(a5)

	tst	noconf(a5)
	bne.b	.kej2

	bsr	CheckChannelSettings
	bsr	CheckSpecific

.kej2	move	forced(a5),d0
	btst	#0,d0
	beq.b	.nrate
	move.l	frate(a5),mixingrate(a5)
.nrate
	btst	#1,d0
	beq.b	.nboost
	move.l	fboost(a5),vboost(a5)
.nboost
	btst	#2,d0
	beq.b	.npmode
	move	fpmode(a5),pmode(a5)
.npmode
	btst	#3,d0
	beq.b	.nsstate
	move	fstate(a5),system(a5)
.nsstate
	move	system(a5),fstate(a5)
	move	pmode(a5),fpmode(a5)

	move.l	buffSize(a5),d0
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	CLIB	Exec,AllocMem
	move.l	d0,buff1(a5)
	beq	.memerr

	move.l	buffSize(a5),d0
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	CALL	AllocMem
	move.l	d0,buff2(a5)
	beq	.memerr

	move.l	#66*256,d7			; Volume tab size

	cmp	#REAL,pmode(a5)
	beq.b	.varaa
	cmp	#STEREO14,pmode(a5)
	bne.b	.ala2

.varaa	move.l	buffSize(a5),d0
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	CLIB	Exec,AllocMem
	move.l	d0,buff3(a5)
	beq.b	.memerr

	move.l	buffSize(a5),d0
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	CALL	AllocMem
	move.l	d0,buff4(a5)
	beq.b	.memerr

.ala2	cmp	#STEREO14,pmode(a5)
	beq.b	.bit14

	moveq	#0,d0
	move	maxchan(a5),d1
	move.l	#256,d2
	subq	#1,d1
.l	add.l	d2,d0
	add.l	#256,d2
	dbf	d1,.l

	move.l	d0,dtabsize(a5)
	moveq	#MEMF_PUBLIC,d1
	CALL	AllocMem
	move.l	d0,dtab(a5)
	beq.b	.memerr	
	bra.b	.alavaraa

.bit14	move.l	#66*256*2,d7			; Volume tab size

	move.l	#64*1024,d0
	moveq	#MEMF_PUBLIC,d1
	CALL	AllocMem
	move.l	d0,buff14(a5)
	bne.b	.alavaraa

.memerr	lea	outofmemory(a5),a0
	bsr	error
	bra	ejecti

.alavaraa
	move.l	d7,d0
	moveq	#MEMF_PUBLIC,d1
	CALL	AllocMem
	move.l	d0,vtab(a5)
	beq.b	.memerr

	add.l	#255,d0
	and.l	#~$ff,d0
	move.l	d0,vtabaddr(a5)

	clr	params(a5)

	cmp	#DISABLED,system(a5)
	bne.b	syssy

	clr	PS3M_cont(a5)

kala	jsr	s3mPlay

	bsr	positio

	or	#SELECTED,Pause+12(a5)

	lea	Pause(a5),a0
	move.l	winpoin(a5),a1
	sub.l	a2,a2
	moveq	#1,d0
	C5LIB	Int,RefreshGList

	move.l	winpoin(a5),a0
	move.l	wd_UserPort(a0),a2

.ksa	move.l	a2,a0
	CLIB	Exec,GetMsg
	tst.l	d0
	beq.b	pevent

	move.l	d0,a1
	CALL	ReplyMsg
	bra.b	.ksa

syssy	clr	PS3M_cont(a5)

	ifeq	fromasmone
	move.l	#winname,d1
	moveq	#9,d2
	lea	alkuu-4,a0			; SYSTEM SECTION
						; !MUST! BE AFTER MAIN SECTION
	move.l	(a0),d3
	move.l	#4096,d4
	C5LIB	DOS,CreateProc

	else

	jsr	syss3mPlay

	endc

	clr.l	timethisfar(a5)

	move.l	#dates,d1
	C5LIB	DOS,DateStamp
	move.l	dates+4(a5),d0
	mulu	#50*60,d0
	add.l	d0,fifties(a5)

	tst	zoomstate(a5)
	bne.b	pevent

	bsr	positio

pevent	sub.l	a4,a4
	moveq	#0,d7
	move.l	winpoin(a5),a0
	move.l	wd_UserPort(a0),a2
	move.b	15(a2),d1
	moveq	#0,d0
	bset	d1,d0
	move.l	d0,d3
	move.l	signaali(a5),d1
	bset	d1,d0
	bset	#CTRL_C,d0
	CLIB	Exec,Wait

	move.l	d0,d6
kilke
	and.l	d0,d3
	bne.b	ksa

	tst	PS3M_break(a5)
	bne.b	.k

	tst	PS3M_poscha(a5)
	beq.b	.l

	bsr	positio
	clr	PS3M_poscha(a5)

.l	tst	paivita(a5)
	bne.b	heppi
	bra.b	pevent

.k	clr	PS3M_break(a5)
	cmp	#1,maxfile(a5)
	beq.b	pevent
	bra	piisiloppu

ksa	move.l	a2,a0
	CALL	GetMsg
	tst.l	d0
	beq	pedone

	move.l	d0,a1
	cmpi.l	#INTUITICKS,im_Class(a1)
	bne.b	.aj
	moveq	#1,d7
	bra.b	.rep

.aj	move.l	im_Class(a1),d2
	move	im_Code(a1),d3
	move.l	im_IAddress(a1),a4
.rep	CALL	ReplyMsg
	bra.b	ksa

heppi	btst	#CTRL_C,d6
	bne	closeup2

	clr	paivita(a5)
	tst	PS3M_paused(a5)
	bne	pevent
	tst	PS3M_play(a5)
	beq	pevent
	move.l	#dates2,d1
	C5LIB	DOS,DateStamp
	move.l	dates2+4(a5),d0
	mulu	#50*60,d0
	add.l	fifties2(a5),d0
	sub.l	fifties(a5),d0

	lea	btitle,a0
	move.l	a0,a1

	divu	#50,d0
	swap	d0
	clr	d0
	swap	d0
	add.l	timethisfar(a5),d0
	cmp.l	oldsec(a5),d0
	beq	pevent
	move.l	d0,oldsec(a5)

	divu	#60,d0
	swap	d0
	moveq	#0,d1
	move	d0,d1
	clr	d0
	swap	d0

	divu	#10,d0
	add.b	#`0`,d0
	move.b	d0,(a0)+
	swap	d0
	add.b	#`0`,d0
	move.b	d0,(a0)+
	addq.l	#1,a0

	divu	#10,d1
	add.b	#`0`,d1
	move.b	d1,(a0)+
	swap	d1
	add.b	#`0`,d1
	move.b	d1,(a0)
		
	move.l	winpoin(a5),a0
	lea	scrname(a5),a2
	C5LIB	Int,SetWindowTitles
	bra	pevent

pedone	tst	d7
	beq.b	.kidp

	move	gvolume+12(a5),d0
	and	#SELECTED,d0
	beq.b	.kidp
	bsr	saataa

.kidp	cmp.l	#GADGETUP,d2
	beq	spainettu

	cmp.l	#MOUSEBUTTONS,d2
	beq.b	button2

	cmp.l	#CLOSEWINDOW,d2
	bne	pevent

closeup2
	move.l	winpoin(a5),a0
	C5LIB	Int,CloseWindow
	clr.l	winpoin(a5)

	pea	exit(pc)
	bra	lopeta

button2	cmp	#MENUDOWN,d3
	bne	pevent

	not	zoomstate(a5)
	bne.b	pienenna2

	move.l	winpoin(a5),a0
	move	wd_TopEdge(a0),d0
	add	winstr+6(a5),d0

	move.l	wbscr(a5),a1
	cmp	sc_Height(a1),d0
	blt.b	.ok

	move	sc_Height(a1),d1
	sub	d0,d1
	ext.l	d1
	moveq	#0,d0
	C5LIB	Int,MoveWindow
	move.l	winpoin(a5),a0

.ok	move	winstr+6(a5),d1
	sub	bar(a5),d1
	moveq	#0,d0
	C5LIB	Int,SizeWindow

	move.l	winpoin(a5),a0
	lea	btitle,a1
	lea	scrname(a5),a2
	CALL	SetWindowTitles

	bsr	waitsize

	bsr	drawtexture
	pea	pevent(pc)
	bra.b	positio

pienenna2
	move.l	winpoin(a5),a0
	lea	gvolume(a5),a1
	moveq	#GADGETS,d0
	C5LIB	Int,RemoveGList

	move	winstr+6(a5),d1
	sub	bar(a5),d1
	neg	d1
	moveq	#0,d0
	move.l	winpoin(a5),a0
	CALL	SizeWindow

	move.l	winpoin(a5),a0
	lea	btitle,a1
	lea	scrname(a5),a2
	CALL	SetWindowTitles
	bra	pevent

positio	clr	PS3M_poscha(a5)

	move	PS3M_position(a5),d0
	mulu	#-1,d0
	move	positioneita(a5),d1
	subq	#1,d1
	beq.b	kieldi
	divu	d1,d0
	move	d0,d1

kieldi	moveq	#-1,d0
	clr	d0
	swap	d0
	divu	positioneita(a5),d0
	move	d0,d3

	lea	position(a5),a0
	move.l	winpoin(a5),a1
	sub.l	a2,a2

	moveq	#AUTOKNOB!FREEHORIZ!PROPBORDERLESS!PROPNEWLOOK,d0
	moveq	#0,d2
	moveq	#-1,d4
	moveq	#1,d5
	C5LIB	Int,NewModifyProp
	rts

spainettu
	cmp.l	#Name,a4
	bne.b	.dd
	pea	pevent(pc)
	bra	aboutti

.dd	cmp.l	#Prg,a4
	beq	prog

	cmp.l	#Next,a4
	beq	piisiloppu

	cmp.l	#Prev,a4
	beq	edellinen

	cmp.l	#Pause,a4
	beq	pause

	cmp.l	#PosGad,a4
	beq	alusta

	cmp.l	#Mute,a4
	beq	smute

	cmp.l	#position,a4
	beq	jump

	cmp.l	#Prefs,a4
	beq	pref1

	cmp.l	#Play,a4
	bne.b	.ek2

	move.l	program(a5),d0
	beq	stopa
	move.l	d0,a0
	bsr	FreeProgram
	clr.l	program(a5)

	bsr	lopeta

	move.l	s3m(a5),d0
	beq.b	.nomem
	move.l	d0,a1
	move.l	s3mlen(a5),d0
	CLIB	Exec,FreeMem
	clr.l	s3m(a5)
.nomem	bra	modplayer

.ek2	cmp.l	#gvolume,a4
	bne.b	.ed
	pea	pevent(pc)
	bra	saataa

.ed	cmp.l	#Eject,a4
	bne	pevent

ejecti	move.l	program(a5),d0
	beq	stopa
	move.l	d0,a0
	bsr	FreeProgram
	clr.l	program(a5)
	bra	stopa

pause	move	Pause+12(a5),d0
	and	#SELECTED,d0
	beq.b	konttaa

	move.l	oldsec(a5),d0
	sub.l	timethisfar(a5),d0
	add.l	d0,timethisfar(a5)
	move.l	timethisfar(a5),oldsec(a5)

	st	PS3M_paused(a5)

	bsr	PS3M_pause
	bra	pevent

konttaa	cmp	#DISABLED,system(a5)
	beq.b	.cont

	move.l	#dates,d1
	C5LIB	DOS,DateStamp
	move.l	dates+4(a5),d0
	mulu	#50*60,d0
	add.l	d0,fifties(a5)

	clr	PS3M_paused(a5)
	bsr	PS3M_pause
	bra	pevent

.cont	move	#1,PS3M_cont(a5)
	bra	kala


smute	lea	$dff000,a6
	move	Mute+12(a5),d0
	and	#SELECTED,d0
	beq.b	.turnon

	moveq	#0,d0
	move	d0,$a8(a6)
	move	d0,$b8(a6)
	move	d0,$c8(a6)
	move	d0,$d8(a6)
	bra	pevent

.turnon
	moveq	#64,d1

	move	pmode(a5),d0
	subq	#1,d0
	bne.b	.nosurround

	moveq	#32,d2
	move	d1,$a8(a6)
	move	d1,$b8(a6)
	move	d2,$c8(a6)
	move	d2,$d8(a6)
	bra.b	.ohiis

.nosurround
	subq	#4,d0
	bpl.b	.bit14

; Stereo, Mono and Real Surround
	move	d1,$a8(a6)
	move	d1,$b8(a6)
	move	d1,$c8(a6)
	move	d1,$d8(a6)
	bra.b	.ohiis

; 14-BIT STEREO

.bit14	moveq	#1,d2
	move	d1,$a8(a6)
	move	d1,$b8(a6)
	move	d2,$c8(a6)
	move	d2,$d8(a6)
.ohiis	bra	pevent



alusta	bsr	lopeta
	bra	hepoinen

edellinen
	cmp	#1,maxfile(a5)
	beq	pevent

	move	progpos(a5),d0
	bne.b	vahenna
	move	maxfile(a5),progpos(a5)
vahenna
	subq	#1,progpos(a5)
	bra.b	stopa

piisiloppu
	cmp	#1,maxfile(a5)
	beq	pevent

uuspiisi
	addq	#1,progpos(a5)
	move	progpos(a5),d0
	cmp	maxfile(a5),d0
	bne.b	stopa
	clr	progpos(a5)

stopa	bsr.b	lopeta

urgh	move.l	s3m(a5),d0
	beq.b	.nomem
	move.l	d0,a1
	move.l	s3mlen(a5),d0
	CLIB	Exec,FreeMem
	clr.l	s3m(a5)
.nomem	tst.l	program(a5)
	bne	nextafile
	bra	event


pref1	bsr	override
	tst.l	d7
	beq	pevent
	bra.b	alusta


errore	bsr.b	lopeta

	lea	tags(a5),a0
	sub.l	a3,a3
	move.l	a3,a4
	lea	initerror(a5),a1
	lea	retry(a5),a2
	C5LIB	RT,rtEZRequestA
	subq	#1,d0
	bmi.b	uuspiisi
	beq	hepoinen
	bra	ejecti

lopeta	st	PS3M_eject(a5)
	st	PS3M_wait(a5)

	tst	PS3M_play(a5)
	beq.b	.d

	cmp	#DISABLED,system(a5)
	beq.b	.d

.l	tst	PS3M_wait(a5)			; Wait for the player
	bne.b	.l				; task to finish

.d	move.l	4.w,a6
	move.l	buff1(a5),d0
	beq.b	.eimem
	move.l	d0,a1
	move.l	buffSize(a5),d0
	CALL	FreeMem
	clr.l	buff1(a5)

.eimem	move.l	buff2(a5),d0
	beq.b	.eimem1
	move.l	d0,a1
	move.l	buffSize(a5),d0
	CALL	FreeMem
	clr.l	buff2(a5)

.eimem1	move.l	buff3(a5),d0
	beq.b	.eimem2
	move.l	d0,a1
	move.l	buffSize(a5),d0
	CALL	FreeMem
	clr.l	buff3(a5)

.eimem2	move.l	buff4(a5),d0
	beq.b	.eimem3
	move.l	d0,a1
	move.l	buffSize(a5),d0
	CALL	FreeMem
	clr.l	buff4(a5)

.eimem3	move.l	buff14(a5),d0
	beq.b	.eimem4
	move.l	d0,a1
	move.l	#64*1024,d0
	CALL	FreeMem
	clr.l	buff14(a5)

.eimem4	move.l	vtab(a5),d0
	beq.b	.eimem5
	move.l	d0,a1
	move.l	#66*256,d0
	cmp	#STEREO14,pmode(a5)
	bne.b	.cd
	add.l	d0,d0
.cd	CALL	FreeMem
	clr.l	vtab(a5)

.eimem5	move.l	dtab(a5),d0
	beq.b	.eimem6
	move.l	d0,a1
	move.l	dtabsize(a5),d0
	CALL	FreeMem
	clr.l	dtab(a5)

.eimem6	rts


saataa	moveq	#64,d1
	move	propspecial+2(a5),d0
	mulu	d0,d1
	swap	d1
	move	d1,PS3M_master

	lea	gvolume(a5),a0
	move.l	winpoin(a5),a1
	sub.l	a2,a2
	moveq	#1,d0
	C5LIB	Int,RefreshGList
	rts

jump	move	positioneita(a5),d1
	move	propspecial2+2(a5),d0
	mulu	d0,d1
	swap	d1
	ext.l	d1

	move	d1,d0
	bsr	setPosition

	lea	position(a5),a0
	move.l	winpoin(a5),a1
	sub.l	a2,a2
	moveq	#1,d0
	C5LIB	Int,RefreshGList
	pea	pevent(pc)
	bra	positio


prog	tst.l	reqptr(a5)
	bne.b	.kej

	sub.l	a0,a0
	moveq	#RT_FILEREQ,d0
	C5LIB	RT,rtAllocRequestA
	move.l	d0,reqptr(a5)
	bne.b	.okei

	lea	outofmemory(a5),a0
	bsr	lopeta
	pea	exit(pc)
	bra	error

.okei	tst	noconf(a5)
	bne.b	.kej

	bsr	GetDefaultDir
	tst.l	d0
	beq.b	.kej

	move.l	reqptr(a5),a1
	lea	diretags(a5),a0
	move.l	d0,4(a0)			; Set directory
	CALL	rtChangeReqAttrA

.kej	move.l	reqptr(a5),a1
	lea	addtags(a5),a0
	lea	fname,a2
	lea	title6(a5),a3
	C5LIB	RT,rtFileRequestA
	tst.l	d0
	beq	pevent
	move.l	d0,a4

	move.l	reqptr(a5),a0
	move.l	rtfi_Dir(a0),a2
	move.l	a4,a1

	move.l	program(a5),a0
	bsr	AddProgram

	move	d0,maxfile(a5)
	move.l	a4,a0
	C5LIB	RT,rtFreeFileList
	bra	pevent
	endb	a3


****************************************

override
	moveq	#0,d7

over	lea	vars,a1
	move.l	mixingrate(a5),(a1)+
	move.l	vboost(a5),(a1)+

	move	pmode(a5),d0	
	btst	#2,forced+1(a5)
	beq.b	.q
	move	fpmode(a5),d0
.q	subq	#1,d0
	bne.b	.nsurr
	lea	surr(a5),a2
	bra.b	.deq

.nsurr	subq	#1,d0
	bne.b	.nster
	lea	ster(a5),a2
	bra.b	.deq

.nster	subq	#1,d0
	bne.b	.nmon
	lea	mon(a5),a2
	bra.b	.deq
.nmon
	subq	#1,d0
	bne.b	.nreal
	lea	real(a5),a2
	bra.b	.deq

.nreal	lea	stereo14(a5),a2

.deq	move.l	a2,(a1)+

	move	system(a5),d0
	btst	#3,forced+1(a5)
	beq.b	.q2
	move	fstate(a5),d0
.q2	cmp	#DISABLED,d0
	beq.b	.dis
	move.l	#on,(a1)+
	bra.b	.ddq
.dis	move.l	#off,(a1)+

.ddq	clr.l	defaultresponse(a5)
	lea	overtxt(a5),a1
	lea	tags(a5),a0
	sub.l	a3,a3
	lea	vars,a4
	lea	overgad(a5),a2
	C5LIB	RT,rtEZRequestA
	tst.l	d0
	beq	.over

	moveq	#1,d7

	subq.l	#1,d0
	beq.b	.rate

	subq.l	#1,d0
	beq.b	.boost

	subq.l	#1,d0
	beq.b	.pmode

	subq.l	#1,d0
	beq.b	.state

	move.l	mixingrate(a5),frate(a5)
	move.l	vboost(a5),fboost(a5)
	or	#$f,forced(a5)
	bra	over

.rate	lea	ltags(a5),a0
	lea	mixingrate(a5),a1
	lea	mratetitle(a5),a2
.d	sub.l	a3,a3
	C5LIB	RT,rtGetLongA
	bra	over

.boost	lea	ltags2(a5),a0
	lea	vboost(a5),a1
	lea	vboosttitle(a5),a2
	bra.b	.d


.pmode	moveq	#0,d0
	move	pmode(a5),d0
	move.l	d0,defaultresponse(a5)

	lea	playmode(a5),a1
	lea	tags(a5),a0
	sub.l	a3,a3
	move.l	a3,a4
	lea	pmodeg(a5),a2
	C5LIB	RT,rtEZRequestA
	tst.l	d0
	beq.b	.ov

	move	d0,fpmode(a5)
	or	#4,forced(a5)

.ov	bra	over


.state	moveq	#0,d0
	move	system(a5),d0
	move.l	d0,defaultresponse(a5)

	lea	killer(a5),a1
	lea	tags(a5),a0
	sub.l	a3,a3
	move.l	a3,a4
	lea	killerg(a5),a2
	C5LIB	RT,rtEZRequestA
	tst.l	d0
	beq.b	.ov2

	move	d0,fstate(a5)
	or	#8,forced(a5)

.ov2	bra	over

.over	rts


****************************************

showsamples
	clr	ssnpos(a5)
.reqloop
	cmp	#mtMOD,mtype(a5)
	beq	.mod
	cmp	#mtMTM,mtype(a5)
	beq	.mtm
	cmp	#mtXM,mtype(a5)
	beq.b	.xm

.s3m	move.l	s3m(a5),a0
	move.l	samples(a5),a1
	move	ssnpos(a5),d7
	moveq	#15,d6				; 16 names per requester
	lea	vars,a4

	move	insnum(a0),d5
	iword	d5

.loop	move	d7,d0
	add	d0,d0
	move	(a1,d0),d0
	iword	d0
	lsl	#4,d0
	lea	(a0,d0),a2
	lea	insname(a2),a3
	move.l	a3,(a4)+			; Name

	move.l	inslength(a2),d0
	ilword	d0		
	move.l	d0,(a4)+

	addq	#1,d7
	cmp	d5,d7
	bhs	.pois
	dbf	d6,.loop
	bra	.show

.xm	move.l	s3m(a5),a0
	move	ssnpos(a5),d7
	moveq	#15,d6				; 16 names per requester
	lea	vars,a4
	lea	xmNumInsts(a0),a0
	tword	(a0)+,d5
	lea	xm_insts,a0
.loop0	move	d7,d0
	lsl	#2,d0
	move.l	(a0,d0),a2
	moveq	#0,d4
	move.l	a2,a1
	tlword	(a1)+,d0			; Insthdr size
	move.l	a1,(a4)+			; Name
	lea	xmNumSamples(a2),a1
	tword	(a1)+,d2
	tst	d2
	beq.b	.skip
	lea	xmSmpHdrSize(a2),a1
	tlword	(a1)+,d3
	add.l	d0,a2
	subq	#1,d2
.koo	move.l	a2,a1
	tlword	(a1)+,d0
	add.l	d0,d4
	add.l	d3,a2
	dbf	d2,.koo

.skip	move.l	d4,(a4)+

	addq	#1,d7
	cmp	d5,d7
	bhs	.pois

	dbf	d6,.loop0
	bra	.show


.mod	move.l	s3m(a5),a0
	move	ssnpos(a5),d7
	moveq	#15,d6				; 16 names per requester
	lea	vars,a4
	moveq	#31,d5
.loop2	move	d7,d0
	mulu	#30,d0
	lea	20(a0,d0),a2
	move.l	a2,(a4)+			; Name

	moveq	#0,d0
	move	22(a2),d0
	add.l	d0,d0
	move.l	d0,(a4)+

	addq.l	#1,d7
	cmp	d5,d7
	bhs.b	.pois

	dbf	d6,.loop2
	bra.b	.show

.mtm	move.l	s3m(a5),a0
	move	ssnpos(a5),d7
	moveq	#15,d6				; 15 names per requester
	lea	vars,a4
	moveq	#0,d5
	move.b	30(a0),d5
.loop3	move	d7,d0
	mulu	#37,d0
	lea	66(a0,d0),a2
	move.l	a2,(a4)+			; Name

	lea	22(a2),a2
	tlword	(a2)+,d1
	move.l	d1,(a4)+

	addq	#1,d7
	cmp	d5,d7
	bhs.b	.pois

	dbf	d6,.loop3
	bra.b	.show

.pois	move.l	#tyhja,(a4)+
	clr.l	(a4)+
	dbf	d6,.pois

.show	lea	ssn(a5),a1
	lea	tags(a5),a0
	sub.l	a3,a3
	lea	vars,a4

	clr.l	defaultresponse(a5)

	tst	ssnpos(a5)
	beq.b	.first

	move	ssnpos(a5),d0
	add	#16,d0
	cmp	d5,d0
	bhs.b	.last

	lea	ssn1(a5),a2
	bra.b	.juu

.last	lea	ssn3(a5),a2
	move.l	#2,defaultresponse(a5)
	bra.b	.juu

.first	move	ssnpos(a5),d0
	add	#16,d0
	cmp	d5,d0
	blo.b	.fir

	lea	ssn4(a5),a2
	move.l	#2,defaultresponse(a5)
	bra.b	.juu

.fir	lea	ssn2(a5),a2

.juu	C5LIB	RT,rtEZRequestA
	cmp	#2,d0
	beq.b	.exit
	tst	d0
	beq.b	.right

	cmp	#16,ssnpos(a5)
	blo	.reqloop
	sub	#16,ssnpos(a5)
	bra	.reqloop

.right	move	ssnpos(a5),d0
	add	#16,d0
	cmp	d5,d0
	bhs	.reqloop
	add	#16,ssnpos(a5)
	bra	.reqloop

.exit	rts


*******


GetDefaultDir
	bsr	defaultsec

.dloop	bsr	getline
	cmp.b	#`[`,(a0)
	beq.b	.q
	lea	directory(a5),a1
	bsr	cmpstr
	bne.b	.dloop

	bsr	skipequal

	bsr	copy2temp

	move.l	#tempstr,d0
	rts

.q	moveq	#0,d0
	rts

GetDefaultRate
	bsr	defaultsec

.dloop	bsr	getline
	cmp.b	#`[`,(a0)
	beq.b	.q
	lea	mxrate(a5),a1
	bsr	cmpstr
	bne.b	.dloop

	bsr	skipequal

	bsr	decimal2temp
	move.l	tempstr,d0
	cmp.l	#4000,d0
	blo.b	.q
	cmp.l	#56000,d0
	bhi.b	.q
	rts

.q	move.l	#16000,d0			; Default
	rts

GetDefaultBoost
	bsr	defaultsec

.dloop	bsr	getline
	cmp.b	#`[`,(a0)
	beq.b	.q
	lea	boost(a5),a1
	bsr	cmpstr
	bne.b	.dloop

	bsr	skipequal

	bsr	decimal2temp
	move.l	tempstr,d0
	cmp.l	#4,d0
	bhi.b	.q
	rts

.q	moveq	#0,d0				; Default
	rts


GetPlayMode
	bsr	defaultsec

.dloop	bsr	getline
	cmp.b	#`[`,(a0)
	beq.b	.q
	lea	plmode(a5),a1
	bsr	cmpstr
	bne.b	.dloop

	bsr	skipequal

	moveq	#1,d2
	move.l	a0,-(sp)
	lea	surr(a5),a1
	bsr	cmpstr
	move.l	(sp)+,a0
	tst.l	d0
	beq.b	.qw
	addq.l	#1,d2

	move.l	a0,-(sp)
	lea	ster(a5),a1
	bsr	cmpstr
	move.l	(sp)+,a0
	tst.l	d0
	beq.b	.qw

	addq.l	#1,d2

	move.l	a0,-(sp)
	lea	mon(a5),a1
	bsr	cmpstr
	move.l	(sp)+,a0
	tst.l	d0
	beq.b	.qw

	addq.l	#1,d2

	move.l	a0,-(sp)
	lea	real(a5),a1
	bsr	cmpstr
	move.l	(sp)+,a0
	tst.l	d0
	beq.b	.qw

	addq.l	#1,d2

	move.l	a0,-(sp)
	lea	stereo14(a5),a1
	bsr	cmpstr
	move.l	(sp)+,a0
	tst.l	d0
	bne.b	.q

.qw	move.l	d2,d0
	rts

.q	moveq	#SURROUND,d0				; Default
	rts


GetSystemState
	bsr	defaultsec

.dloop	bsr	getline
	cmp.b	#`[`,(a0)
	beq.b	.q
	lea	sstate(a5),a1
	bsr	cmpstr
	bne.b	.dloop

	bsr	skipequal

	moveq	#1,d2
	move.l	a0,-(sp)
	lea	off(a5),a1
	bsr	cmpstr
	move.l	(sp)+,a0
	tst.l	d0
	beq.b	.qw
	addq.l	#1,d2

	move.l	a0,-(sp)
	lea	on(a5),a1
	bsr	cmpstr
	move.l	(sp)+,a0
	tst.l	d0
	bne.b	.q

.qw	move.l	d2,d0
	rts

.q	moveq	#DISABLED,d0				; Default
	rts


GetBufferSize
	bsr	defaultsec

.dloop	bsr	getline
	cmp.b	#`[`,(a0)
	beq.b	.q
	lea	bsize(a5),a1
	bsr	cmpstr
	bne.b	.dloop

	bsr	skipequal

	bsr	decimal2temp
	move.l	tempstr,d0
	cmp.l	#3,d0
	bhi.b	.q

	move.l	#4*1024,d1
	lsl.l	d0,d1
	move.l	d1,buffSize(a5)
	subq.l	#1,d1
	move.l	d1,buffSizeMask(a5)
	lsl.l	#8,d1
	move.b	#$ff,d1
	move.l	d1,buffSizeMaskFF
.q	moveq	#0,d0				; Default
	rts


GetBanner
	bsr	defaultsec
	moveq	#0,d2
.dloop	bsr	getline
	cmp.b	#`[`,(a0)
	beq.b	.qw
	lea	banner(a5),a1
	bsr	cmpstr
	bne.b	.dloop

	bsr	skipequal

	move.l	a0,-(sp)
	lea	on(a5),a1
	bsr	cmpstr
	move.l	(sp)+,a0
	tst.l	d0
	beq.b	.qw

	move.l	a0,-(sp)
	lea	off(a5),a1
	bsr	cmpstr
	move.l	(sp)+,a0
	tst.l	d0
	bne.b	.qw

	moveq	#-1,d2

.qw	move	d2,bann(a5)
	rts


CheckChannelSettings
	bsr	chansec

	moveq	#0,d2
	move	numchans(a5),d2
.dloop
	bsr	getline
	cmp.b	#`[`,(a0)
	beq.b	.q

	bsr	decimal2temp
	cmp.l	tempstr,d2
	bne.b	.dloop

	bsr	skipequal

	bra.b	takedefaults
.q	rts


CheckSpecific
	bsr	tunesec
.dloop	bsr	getline
	cmp.b	#`[`,(a0)
	beq.b	.q
	lea	fname,a1
	bsr	cmpstr
	bne.b	.dloop

	bsr	skipequal

	bra.b	takedefaults

.q	moveq	#0,d0
	rts


takedefaults
	move.b	(a0),d1
	bsr	locase
	cmp.b	#`r`,d1
	beq.b	.rate

	cmp.b	#`v`,d1
	beq.b	.boost

	cmp.b	#`m`,d1
	bne.b	.skip

.mode	addq.l	#1,a0
	bsr	decimal2temp
	move.l	tempstr,d1
	addq.l	#1,d1
	cmp.l	#SURROUND,d1
	blo.b	.skip
	cmp.l	#STEREO14,d1
	bhi.b	.skip

	move	d1,pmode(a5)
	bra.b	.skip

.boost	addq.l	#1,a0
	bsr	decimal2temp
	move.l	tempstr,d1
	cmp	#4,d1
	bhi.b	.skip

	move.l	d1,vboost(a5)
	bra.b	.skip

.rate	addq.l	#1,a0
	bsr	decimal2temp
	move.l	tempstr,d1
	cmp.l	#4000,d1
	blo.b	.skip
	cmp.l	#56000,d1
	bhi.b	.skip

	move.l	d1,mixingrate(a5)

.skip	tst.b	(a0)
	beq.b	.q
	cmp.b	#` `,(a0)
	beq.b	.next
	cmp.b	#10,(a0)
	beq.b	.q
	cmp.l	a4,a0
	bhs.b	.q
	bra	takedefaults
.next	addq.l	#1,a0
	bra.b	.skip


.q	rts


defaultsec
	move.l	config(a5),d0
	beq.b	errexit
	move.l	d0,a0
	move.l	a0,a4
	add.l	conlen(a5),a4
.loop	bsr	getline
	lea	defaultsection(a5),a1
	bsr.b	cmpstr
	bne.b	.loop
	rts

errexit	addq.l	#4,sp
	moveq	#0,d0
	rts


chansec	move.l	config(a5),d0
	beq.b	errexit
	move.l	d0,a0
	move.l	a0,a4
	add.l	conlen(a5),a4
.loop	bsr	getline
	lea	channelsection(a5),a1
	bsr.b	cmpstr
	bne.b	.loop
	rts


tunesec	move.l	config(a5),d0
	beq.b	errexit
	move.l	d0,a0
	move.l	a0,a4
	add.l	conlen(a5),a4
.loop	bsr	getline
	lea	tunesection(a5),a1
	bsr.b	cmpstr
	bne.b	.loop
	rts


cmpstr	move.b	(a1)+,d1
	beq.b	.q
	bsr.b	locase
	move.b	d1,d0

	move.b	(a0)+,d1
	bsr.b	locase
	cmp.b	d0,d1
	beq.b	cmpstr
	moveq	#1,d0
	rts

.q	moveq	#0,d0				; match
	rts

skipequal
.qw	cmp.b	#`=`,(a0)+
	bne.b	.qw
.l	cmp.b	#` `,(a0)+
	beq.b	.l
	subq.l	#1,a0
	rts

copy2temp
	lea	tempstr,a1
.cp	move.b	(a0)+,(a1)+
	cmp.b	#10,-1(a1)
	bne.b	.cp
	clr.b	-1(a1)
	rts

decimal2temp
	moveq	#0,d1
.los	moveq	#0,d0
	move.b	(a0),d0
	cmp	#` `,d0
	beq.b	.lop
	cmp	#10,d0
	beq.b	.lop
	cmp.l	a4,a0
	bhs.b	.lop

	addq.l	#1,a0
	sub	#`0`,d0
	mulu	#10,d1
	add	d0,d1
	bra.b	.los

.lop	move.l	d1,tempstr
	rts


locase	cmp.b	#`A`,d1
	blo.b	.q
	cmp.b	#`Z`,d1
	bhi.b	.q
	add.b	#`a`-`A`,d1
.q	rts

getline	cmp.b	#10,-1(a0)
	bne.b	.skip
.gloop	cmp.b	#`;`,(a0)
	beq.b	.skip
	cmp.b	#10,(a0)
	beq.b	.skip
.q	rts					; Found

.skip	move.b	(a0)+,d0
	beq.b	.q2
	cmp.b	#10,d0
	beq.b	.gloop
	cmp.l	a4,a0
	blo.b	.skip
.q2	addq.l	#4,sp
	moveq	#0,d0
	rts					; No line found, quit

	endb	a5


*****************************************
*   NewProgram (filelist,path)(A0,A1)	*
*	    D0 = *program		*
*	    D1 = amount of files	*
*****************************************
NewProgram
	Push	d2-a6
	move.l	a1,a2
.size	tst.b	(a2)+
	bne.b	.size
	subq.l	#1,a2
	sub.l	a1,a2
	move.l	a2,d7			;pathlength

	moveq	#10,d0
	add.l	d7,d0
	add.l	4(a0),d0		;Nodenpituus
	moveq	#1,d2
	and.l	d0,d2
	add.l	d2,d0
	move.l	d0,d2
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	Push	a0/a1
	CLIB	Exec,AllocMem
	Pull	a0/a1
	move.l	d0,-(sp)		;Program!

	move.l	d0,a2
	move	d2,4(a2)

	move.l	a1,a4
	lea	8(a2),a3
	tst.b	(a4)
	beq.b	.okd
.lopa	move.b	(a4)+,(a3)+
	bne.b	.lopa

	move.b	#`/`,-1(a3)
	cmp.b	#`:`,-2(a3)
	bne.b	.okd
	subq.l	#1,a3
.okd	move.l	8(a0),a4
.lop	move.b	(a4)+,(a3)+
	bne.b	.lop

	moveq	#1,d6
nodeloop
	move.l	(a0),d0
	beq.b	NPloppu
	move.l	d0,a0

	addq.l	#1,d6
	moveq	#10,d0
	add.l	d7,d0
	add.l	4(a0),d0		;Noden pituus
	moveq	#1,d2
	and.l	d0,d2
	add.l	d2,d0
	move.l	d0,d2
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	Push	a0/a1
	CALL	AllocMem
	Pull	a0/a1
	move.l	d0,(a2)

	move.l	d0,a2
	move	d2,4(a2)

	move.l	a1,a4
	lea	8(a2),a3
	tst.b	(a4)
	beq.b	.okd
.lopa	move.b	(a4)+,(a3)+
	bne.b	.lopa

	move.b	#`/`,-1(a3)
	cmp.b	#`:`,-2(a3)
	bne.b	.okd
	subq.l	#1,a3
.okd	move.l	8(a0),a4
.lop	move.b	(a4)+,(a3)+
	bne.b	.lop
	bra.b	nodeloop

NPloppu	move.l	d6,d1
	move.l	(sp)+,d0
	Pull	d2-a6
	rts

*****************************************
*   NewProgram2 (Filename)(A0)		*
*	    D0 = *program		*
*****************************************
NewProgram2
	Push	d1-a6
	move.l	a0,a2
.size	tst.b	(a2)+
	bne.b	.size
	subq.l	#1,a2
	sub.l	a0,a2
	move.l	a2,d7			;NAMElength

	moveq	#10,d0
	add.l	d7,d0			;NODElength
	moveq	#1,d2
	and.l	d0,d2
	add.l	d2,d0
	move.l	d0,d2
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	a0,a3
	CLIB	Exec,AllocMem
	move.l	d0,-(sp)		;Program!

	move.l	d0,a2
	move	d2,4(a2)
	addq.l	#8,a2
.lopa	move.b	(a3)+,(a2)+
	bne.b	.lopa
	move.l	(sp)+,d0
	Pull	d1-a6
	rts

*************************************************
* AddProgram (program,filelist,path)(A0,A1,A2)	*
*		D0 = amount of files		*
*************************************************
AddProgram
	Push	d1-a6
	moveq	#1,d6
.montako
	move.l	(a0),d0
	beq.b	uutta
	addq.l	#1,d6
	move.l	d0,a0
	bra.b	.montako
uutta	
	move.l	a2,a4
.size	tst.b	(a4)+
	bne.b	.size
	subq	#1,a4
	sub.l	a2,a4
	move.l	a4,d7

nodeloop2
	addq.l	#1,d6
	moveq	#10,d0
	add.l	d7,d0
	add.l	4(a1),d0		;Noden pituus
	moveq	#1,d2
	and.l	d0,d2
	add.l	d2,d0
	move.l	d0,d2
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	Push	a0/a1
	CLIB	Exec,AllocMem
	Pull	a0/a1
	move.l	d0,(a0)

	move.l	d0,a0
	move	d2,4(a0)

	move.l	a2,a4
	lea	8(a0),a5
	tst.b	(a4)
	beq.b	.okd
.lopa	move.b	(a4)+,(a5)+
	bne.b	.lopa

	move.b	#`/`,-1(a5)
	cmp.b	#`:`,-2(a5)
	bne.b	.okd
	subq.l	#1,a5
.okd	move.l	8(a1),a4
.lop	move.b	(a4)+,(a5)+
	bne.b	.lop

	move.l	(a1),d0
	beq.b	NPloppu2
	move.l	d0,a1
	bra.b	nodeloop2

NPloppu2
	move.l	d6,d0
	Pull	d1-a6
	rts


*************************************************
* AddProgram2 (program,filename)(A0,A1)		*
*		D0 = amount of files		*
*************************************************
AddProgram2
	Push	d1-a6
	moveq	#2,d6
.montako
	move.l	(a0),d0
	beq.b	.uutta
	addq.l	#1,d6
	move.l	d0,a0
	bra.b	.montako
.uutta
	move.l	a1,a4
.size	tst.b	(a4)+
	bne.b	.size
	subq	#1,a4
	sub.l	a1,a4

	moveq	#10,d0
	add.l	a4,d0			;Noden pituus
	moveq	#1,d2
	and.l	d0,d2
	add.l	d2,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	a1,a3
	move.l	a0,a4
	move.l	d0,d2
	CLIB	Exec,AllocMem
	move.l	d0,(a4)

	move.l	d0,a0
	move	d2,4(a0)

	addq.l	#8,a0
.lopa	move.b	(a3)+,(a0)+
	bne.b	.lopa
	move.l	d6,d0
	Pull	d1-a6
	rts

*****************************************
*     GetName (program,count)(A0,D0)	*
*	    D0 = *filename		*
*****************************************
GetName
	Push	d1-a6
	subq	#1,d0
	bmi.b	.eka
.dbf	move.l	(a0),a0
	dbf	d0,.dbf
.eka	addq.l	#8,a0
	move.l	a0,d0
	Pull	d1-a6
	rts

*****************************************
*     GetFlags (program,count)(A0,D0)	*
*	    D0 = flags			*
*****************************************
GetFlags
	Push	d1-a6
	subq	#1,d0
	bmi.b	.eka
.dbf	move.l	(a0),a0
	dbf	d0,.dbf
.eka	move	6(a0),d0
	Pull	d1-a6
	rts

*****************************************
*     MarkProg (program,count)(A0,D0)	*
*****************************************
MarkProg
	Push	All
	subq	#1,d0
	bmi.b	.eka
.dbf	move.l	(a0),a0
	dbf	d0,.dbf
.eka	or	#1,6(a0)
	Pull	All
	rts

*****************************************
*	ClearProg (program)(A0)		*
*****************************************
ClearProg
	Push	All
	moveq	#-2,d1
clearloop
	and	d1,6(a0)
	move.l	(a0),d0
	beq.b	.pois
	move.l	d0,a0
	bra.b	clearloop
.pois	Pull	All
	rts

*****************************************
* 	FreeProgram (program)(A0)	*
*****************************************
FreeProgram
	Push	All
freeloop
	move.l	(a0),d2
	moveq	#0,d0
	move	4(a0),d0
	move.l	a0,a1
	move.l	a0,-(sp)
	CLIB	Exec,FreeMem
	move.l	(sp)+,a0
	tst.l	d2
	beq.b	.pois
	move.l	d2,a0
	bra.b	freeloop	
.pois	Pull	All
	rts


	

****************************************

	basereg	data,a5

exit	lea	data,a5
	move.l	s3m(a5),d0
	beq.b	.eimem
	move.l	d0,a1
	move.l	s3mlen(a5),d0
	CLIB	Exec,FreeMem
	clr.l	s3m(a5)

.eimem	move.l	config(a5),d0
	beq.b	.eicfg
	move.l	d0,a1
	move.l	conlen(a5),d0
	CLIB	Exec,FreeMem
	clr.l	config(a5)

.eicfg	move.l	reqptr(a5),d0
	beq.b	nodh
	move.l	d0,a1
	C5LIB	RT,rtFreeRequest
	clr.l	reqptr(a5)

nodh	move.l	lock(a5),d1
	beq.b	nolock
	C5LIB	DOS,UnLock
	clr.l	lock(a5)

nolock	move.l	signaali(a5),d0
	bmi.b	.nsig
	CLIB	Exec,FreeSignal
	move.l	#-1,signaali(a5)

.nsig	move.l	winpoin(a5),d0
	beq.b	.nwin
	move.l	d0,a0
	C5LIB	Int,CloseWindow
	clr.l	winpoin(a5)

.nwin	move.l	_XpkBase(a5),d0
	beq.b	noxpk
	move.l	d0,a1
	CLIB	Exec,CloseLibrary
	clr.l	_XpkBase(a5)

noxpk	move.l	_PPBase(a5),a1
	CLIB	Exec,CloseLibrary
	clr.l	_PPBase(a5)

	move.l	_RTBase(a5),a1
	CALL	CloseLibrary
	clr.l	_RTBase(a5)

	CALL	Forbid
	move.l	segment(a5),d1
	C5LIB	DOS,UnLoadSeg

	move.l	_DOSBase(a5),a1
	CLIB	Exec,CloseLibrary
	clr.l	_DOSBase(a5)

	Pull	All
	moveq	#0,d0
	rts


*******************************

;; Sets up an about window

aboutti	move.l	#1,defaultresponse(a5)

	lea	alkutext(a5),a1
	lea	tags(a5),a0
	sub.l	a3,a3
	move.l	a3,a4

	lea	contta3(a5),a2

	tst.l	s3m(a5)
	bne.b	.q
	lea	contta4(a5),a2

.q	C5LIB	RT,rtEZRequestA
	tst.l	d0
	bne.b	.con

	lea	alkutext2(a5),a1
	lea	tags(a5),a0
	sub.l	a3,a3
	move.l	a3,a4
	lea	contta(a5),a2
	C5LIB	RT,rtEZRequestA
	bra	positio

.con	subq.l	#1,d0
	beq	positio

	subq.l	#1,d0
	bne.b	.info
	bsr	showsamples
	bra	positio


.info	lea	vars,a1

	moveq	#0,d0
	move	numchans(a5),d0
	move.l	d0,(a1)+

	cmp	#mtMOD,mtype(a5)
	beq.b	.dd

	cmp	#mtMTM,mtype(a5)
	beq.b	.qqe

	cmp	#mtXM,mtype(a5)
	beq.b	.qqq

	lea	st3(a5),a2
	bra.b	.dq

.qqq	lea	xm(a5),a2
	bra.b	.dq

.qqe	lea	mtm(a5),a2
	bra.b	.dq

.dd	cmp	#4,numchans(a5)
	beq.b	.pro
	lea	fast(a5),a2
	bra.b	.dq
.pro	lea	pro(a5),a2
.dq	move.l	a2,(a1)+

	move.l	mname(a5),(a1)+
	move.l	#fname,(a1)+

	move.l	mixingrate(a5),(a1)+
	move.l	vboost(a5),(a1)+

	move	pmode(a5),d0	
	subq	#1,d0
	bne.b	.nsurr
	lea	surr(a5),a2
	bra.b	.deq

.nsurr	subq	#1,d0
	bne.b	.nster
	lea	ster(a5),a2
	bra.b	.deq

.nster	subq	#1,d0
	bne.b	.nmon
	lea	mon(a5),a2
	bra.b	.deq
.nmon
	subq	#1,d0
	bne.b	.nreal
	lea	real(a5),a2
	bra.b	.deq

.nreal	lea	stereo14(a5),a2

.deq	move.l	a2,(a1)+

	cmp	#DISABLED,system(a5)
	beq.b	.dis
	move.l	#on,(a1)+
	bra.b	.ddq
.dis	move.l	#off,(a1)+
.ddq
	tst	opt020(a5)
	bne.b	.dis2
	move.l	#m000,(a1)+
	bra.b	.ddq2
.dis2	move.l	#m020,(a1)+
.ddq2
	lea	infos(a5),a1
	lea	tags(a5),a0
	sub.l	a3,a3
	lea	vars,a4
	lea	contta(a5),a2
	C5LIB	RT,rtEZRequestA
	bra	positio




;; Draws the background texture

drawtexture
	lea	texture(a5),a0
	move.l	rast(a5),a1
	move.l	a1,a2
	move.l	a0,rp_AreaPtrn(a1)
	move.b	#1,rp_AreaPtSz(a1)

	moveq	#2,d0
	C5LIB	GFX,SetAPen

	move.l	a1,a2
	moveq	#3,d0
	moveq	#-1,d1
	move	#236,d2
	move	#79,d3
	add	topbor(a5),d1
	add	topbor(a5),d3
	CALL	RectFill

	lea	otextu(a5),a0
	move.l	a0,rp_AreaPtrn(a2)
	clr.b	rp_AreaPtSz(a2)

	move.l	a2,a1
	moveq	#3,d0
	moveq	#56,d1
	add	topbor(a5),d1
	CALL	Move

	move.l	a2,a1
	move	#236,d0
	moveq	#56,d1
	add	topbor(a5),d1
	CALL	Draw

	lea	gvolume(a5),a4
gadloop	
	move	4(a4),d0
	move	winstr+6(a5),d1
	add	6(a4),d1
	subq	#1,d1

	move	d0,d2
	move	d1,d3
	add	8(a4),d2
	add	10(a4),d3
	subq	#1,d2
	subq	#1,d3
	move.l	a2,a1
	C5LIB	GFX,RectFill

	move.l	(a4),d6
	move.l	a4,a1
	move.l	winpoin(a5),a0
	moveq	#-1,d0
	C5LIB	Int,AddGadget
	tst.l	d6
	beq.b	pesa		
	move.l	d6,a4
	bra.b	gadloop

pesa	lea	gvolume(a5),a0
	move.l	winpoin(a5),a1
	sub.l	a2,a2
	CALL	RefreshGadgets
	rts


;	basereg	data,a5
	
;; Xpk, FImp and PPdata loader

LoadData
	movem.l	d2-d7/a2-a6,-(sp)
	movem.l	d0-a6,-(sp)

	move.l	a0,d1
	move.l	#1005,d2
	C5LIB	DOS,Open
.d	tst.l	d0
	bmi.b	.err
	bne.b	.okei
	moveq	#-1,d0
.err	move.l	d0,errorcode(a5)
	movem.l	(sp)+,d0-a6
	bra	eifimp

.okei	move.l	d0,d7
	move.l	d0,d1
	move.l	#buhku,d2
	moveq	#4,d3
	CALL	Read
	tst.l	d0
	bmi.b	.err
	beq.b	.d

	move.l	d7,d1
	CALL	Close

	movem.l	(sp)+,d0-a6

	cmp.l	#`XPKF`,buhku(a5)
	bne.b	.x
	move.l	_XpkBase(a5),d3
	bne.b	XPK
.x	movem.l	d0/d1/a0/a1,-(sp)
	C5LIB	PP,ppLoadData
	move.l	d0,errorcode(a5)
	movem.l	(sp)+,d0/d1/a0/a1

	move.l	(a1),a3
	cmp.l	#`IMP!`,(a3)
	bne.b	eifimp

	move.l	4(a3),d0
	move.l	a1,-(sp)
	CLIB	Exec,AllocMem
	movem.l	(sp)+,a1

	tst.l	d0
	bne.b	memokei

	moveq	#-3,d0
	move.l	d0,errorcode(a5)
	move.l	(a2),d0
	move.l	(a1),d1
	clr.l	(a1)
	move.l	d1,a1
	CALL	FreeMem
	bra.b	eifimp
	
memokei
	move.l	(a1),a4
	move.l	d0,a0
	move.l	(a2),d7
	asr.l	#1,d7
.cop	move	(a4)+,(a0)+
	subq.l	#1,d7
	bne.b	.cop

	move.l	a1,a4
	move.l	(a1),a1
	move.l	d0,(a4)
	move.l	d0,d2

	move.l	(a2),d0
	move.l	4(a3),(a2)

	CALL	FreeMem

	move.l	d2,a0
	clr.l	errorcode(a5)
	bsr.b	FImp_decrunch

eifimp
	movem.l	(sp)+,d2-d7/a2-a6
	move.l	errorcode(a5),d0
	rts

XPK	move.l	a0,XpkFN(a5)
	move.l	a1,XpkTo(a5)
	move.l	a2,XpkFlen(a5)
	move.l	d1,XpkMem(a5)
	lea	XpkTags(a5),a0
	move.l	d3,a6
	CALL	XpkUnpack
	move.l	d0,errorcode(a5)
	bra.b	eifimp


; Decrunch routine from FImp v2.34 by A.J. Brouwer
; A0 must be pointing at the start of the decrunched data

FImp_decrunch
	movem.l	d2-d5/a2-a4,-(a7)
	move.l	a0,a3
	move.l	a0,a4
	tst.l	(a0)+
	adda.l	(a0)+,a4
	adda.l	(a0)+,a3
	move.l	a3,a2
	move.l	(a2)+,-(a0)
	move.l	(a2)+,-(a0)
	move.l	(a2)+,-(a0)
	move.l	(a2)+,d2
	move	(a2)+,d3
	bmi.b	lb_180e
	subq.l	#1,a3
lb_180e	lea	-$1c(a7),a7
	move.l	a7,a1
	moveq	#6,d0
lb_1816	move.l	(a2)+,(a1)+
	dbf	d0,lb_1816
	move.l	a7,a1
	bra.b	lb_1e90
lb_1822	moveq	#0,d0
	rts
lb_1e90	tst.l	d2
	beq.b	lb_1e9a
lb_1e94	move.b	-(a3),-(a4)
	subq.l	#1,d2
	bne.b	lb_1e94
lb_1e9a	cmpa.l	a4,a0
	bcs.b	lb_1eb2
	lea	$1c(a7),a7
	moveq	#-1,d0
	cmpa.l	a3,a0
	beq.b	lb_1eaa
	moveq	#0,d0
lb_1eaa	movem.l	(a7)+,d2-d5/a2-a4
	tst.l	d0
	rts
lb_1eb2	add.b	d3,d3
	bne.b	lb_1eba
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1eba	bcc.b	lb_1f24
	add.b	d3,d3
	bne.b	lb_1ec4
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1ec4	bcc.b	lb_1f1e
	add.b	d3,d3
	bne.b	lb_1ece
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1ece	bcc.b	lb_1f18
	add.b	d3,d3
	bne.b	lb_1ed8
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1ed8	bcc.b	lb_1f12
	moveq	#0,d4
	add.b	d3,d3
	bne.b	lb_1ee4
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1ee4	bcc.b	lb_1eee
	move.b	-(a3),d4
	moveq	#3,d0
	subq.b	#1,d4
	bra.b	lb_1f28
lb_1eee	add.b	d3,d3
	bne.b	lb_1ef6
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1ef6	addx.b	d4,d4
	add.b	d3,d3
	bne.b	lb_1f00
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f00	addx.b	d4,d4
	add.b	d3,d3
	bne.b	lb_1f0a
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f0a	addx.b	d4,d4
	addq.b	#5,d4
	moveq	#3,d0
	bra.b	lb_1f28
lb_1f12	moveq	#4,d4
	moveq	#3,d0
	bra.b	lb_1f28
lb_1f18	moveq	#3,d4
	moveq	#2,d0
	bra.b	lb_1f28
lb_1f1e	moveq	#2,d4
	moveq	#1,d0
	bra.b	lb_1f28
lb_1f24	moveq	#1,d4
	moveq	#0,d0
lb_1f28	moveq	#0,d5
	move	d0,d1
	add.b	d3,d3
	bne.b	lb_1f34
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f34	bcc.b	lb_1f4c
	add.b	d3,d3
	bne.b	lb_1f3e
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f3e	bcc.b	lb_1f48
	move.b	lb_1fac(pc,d0),d5
	addq.b	#8,d0
	bra.b	lb_1f4c
lb_1f48	moveq	#2,d5
	addq.b	#4,d0
lb_1f4c	move.b	lb_1fb0(pc,d0),d0
lb_1f50	add.b	d3,d3
	bne.b	lb_1f58
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f58	addx	d2,d2
	subq.b	#1,d0
	bne.b	lb_1f50
	add	d5,d2
	moveq	#0,d5
	move.l	d5,a2
	move	d1,d0
	add.b	d3,d3
	bne.b	lb_1f6e
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f6e	bcc.b	lb_1f8a
	add	d1,d1
	add.b	d3,d3
	bne.b	lb_1f7a
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f7a	bcc.b	lb_1f84
	move	8(a1,d1),a2
	addq.b	#8,d0
	bra.b	lb_1f8a
lb_1f84	move	(a1,d1),a2
	addq.b	#4,d0
lb_1f8a	move.b	16(a1,d0),d0
lb_1f8e	add.b	d3,d3
	bne.b	lb_1f96
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f96	addx.l	d5,d5
	subq.b	#1,d0
	bne.b	lb_1f8e
	addq	#1,a2
	adda.l	d5,a2
	adda.l	a4,a2
lb_1fa2	move.b	-(a2),-(a4)
	dbf	d4,lb_1fa2
	bra	lb_1e90

lb_1fac	dc.b	6,10,10,18
lb_1fb0	dc.b	1,1,1,1,2,3,3,4
	dc.b	4,5,7,14



********


; Error message in A0

error	movem.l	d0/d1/a1-a4,-(sp)
	cmp.b	#`a`,(a0)
	blo.b	.e

	cmp.b	#`z`,(a0)
	bhi.b	.e

	sub.b	#`a`-`A`,(a0)			; Upper case :)

.e	move.l	a0,a1
	lea	tags(a5),a0
	move.l	#1,defaultresponse(a5)
	sub.l	a3,a3
	move.l	a3,a4
	lea	errorgadget(a5),a2
	C5LIB	RT,rtEZRequestA
	movem.l	(sp)+,d0/d1/a1-a4
	rts


*******
	endb	a5

*********************************
*	   PS3M 0.9A ฎ		*
*	  Version 0.950		*
*   ฉ 1994-95 Jarno Paananen	*
*      All rights reserved	*
*********************************

;; LEV4 - IRQ HANDLER

lev4	clr.l	playpos
	move	#$80,$dff09c
	nop
	rte

slev4	move	d1,$9c(a0)
	clr.l	(a1)
	rts


lev3	move.l	d0,-(sp)
	move	#$20,$dff09c
	move.l	mrate50,d0
	add.l	d0,playpos
	move.l	buffSizeMaskFF(pc),d0
	and.l	d0,playpos
	move.l	(sp)+,d0
	nop
	rte


lev6server
	move.l	mrate50-playpos(a1),d0
	add.l	d0,(a1)
	move.l	buffSizeMaskFF(pc),d0
	and.l	d0,(a1)
	moveq	#1,d0
	rts

buffSizeMaskFF
	dc.l	(BUFFER-1)<<8!$ff


	basereg	data,a5
play	;movem.l	d0-a6,-(sp)
	lea	data,a5

	move.l	playpos(a5),d2
	lsr.l	#8,d2
	move.l	bufpos(a5),d0
	cmp.l	d2,d0
	ble.b	.norm
	sub.l	buffSize(a5),d0
.norm	move.l	mrate50(a5),d1
	lsr.l	#7,d1
	add.l	d0,d1

	sub.l	d1,d2
	bmi	.ei

	moveq	#1,d0
	and.l	d2,d0
	add	d0,d2

	cmp.l	#16,d2
	blt	.ei

	move	d2,todobytes(a5)

.mix	move	bytes2music(a5),d0
	cmp	todobytes(a5),d0
	bgt.b	.mixaa

	sub	d0,todobytes(a5)
	sub	d0,bytes2music(a5)
	move	d0,bytes2do(a5)
	beq.b	.q
	
	bsr	domix

.q	tst	PS3M_paused
	bne.b	.o

	tst	PS3M_play
	beq.b	.o

	cmp	#mtS3M,mtype(a5)
	bne.b	.xm
	bsr	s3m_music
	lea	data,a5
	bra.b	.kool

.xm	cmp	#mtXM,mtype(a5)
	bne.b	.mod

	bsr	xm_music
	lea	data,a5
	bra.b	.kool

.mod	bsr	mt_music			; Also with MTMs

.kool	st	paivita(a5)

	cmp	#DISABLED,system(a5)
	beq.b	.o

	move.l	signaali(a5),d1
	moveq	#0,d0
	bset	d1,d0
	move.l	task,a1
	CLIB	Exec,Signal

.o	move	bytesperframe(a5),d0
	add	d0,bytes2music(a5)
	bra	.mix

.mixaa	move	todobytes(a5),d0
	sub	d0,bytes2music(a5)
	move	d0,bytes2do(a5)
	beq.b	.q2

	bsr	domix

.q2	lea	data,a5
.ei	moveq	#0,d7
	rts


init	clr	mtype(a5)

	move.l	s3m(a5),a0
	cmp.l	#`SCRM`,44(a0)
	beq	.s3m

	move.l	(a0),d0
	lsr.l	#8,d0
	cmp.l	#`MTM`,d0
	beq	.mtm

	move.l	a0,a1
	lea	xmsign(a5),a2
	moveq	#3,d0
.l	cmpm.l	(a1)+,(a2)+
	bne.b	.j
	dbf	d0,.l
	bra	.xm

.j	move.l	1080(a0),d0
	cmp.l	#`OCTA`,d0
	beq	.fast8
	cmp.l	#`M.K.`,d0
	beq	.pro4
	cmp.l	#`M!K!`,d0
	beq	.pro4
	cmp.l	#`FLT4`,d0
	beq	.pro4

	move.l	d0,d1
	and.l	#$ffffff,d1
	cmp.l	#`CHN`,d1
	beq.b	.chn

	and.l	#$ffff,d1
	cmp.l	#`CH`,d1
	beq.b	.ch

	move.l	d0,d1
	and.l	#$ffffff00,d1
	cmp.l	#`TDZ<<8`,d1
	beq.b	.tdz
	bra	.error

.chn	move.l	d0,d1
	swap	d1
	lsr	#8,d1
	sub	#`0`,d1
	move	#mtMOD,mtype(a5)
	move	d1,numchans(a5)
	addq	#1,d1
	lsr	d1
	move	d1,maxchan(a5)
	bra	.init

.ch	move.l	d0,d1
	swap	d1
	sub	#`00`,d1
	move	d1,d0
	lsr	#8,d0
	mulu	#10,d0
	and	#$f,d1
	add	d0,d1

	move	#mtMOD,mtype(a5)
	move	d1,numchans(a5)
	addq	#1,d1
	lsr	d1
	move	d1,maxchan(a5)
	bra.b	.init

.tdz	and.l	#$ff,d0
	sub	#`0`,d0
	move	#mtMOD,mtype(a5)
	move	d0,numchans(a5)
	addq	#1,d0
	lsr	d0
	move	d0,maxchan(a5)
	bra.b	.init

.fast8	move	#mtMOD,mtype(a5)
	move	#8,numchans(a5)
	move	#4,maxchan(a5)
	bra.b	.init

.pro4	move	#mtMOD,mtype(a5)
	move	#4,numchans(a5)
	move	#2,maxchan(a5)
	bra.b	.init

.mtm	move	#mtMTM,mtype(a5)
	bra.b	.init

.xm	cmp	#$401,xmVersion(a0)		; Kool turbo-optimizin'...
	bne	.j
	move	#mtXM,mtype(a5)
	bra.b	.init

.s3m	move	#mtS3M,mtype(a5)


.init

; TEMPORARY BUGFIX...

	cmp	#2,maxchan(a5)
	bhs.b	.opk

	move	#2,maxchan(a5)

.opk	tst	mtype(a5)
	beq.b	.error

	cmp	#mtS3M,mtype(a5)
	beq	s3m_init

	cmp	#mtMOD,mtype(a5)
	beq	mt_init

	cmp	#mtMTM,mtype(a5)
	beq	mtm_init

	cmp	#mtXM,mtype(a5)
	beq	xm_init

.error	moveq	#1,d0
	rts


FinalInit
	clr.l	bufpos(a5)
	clr.l	playpos(a5)

	clr	cn(a5)
	clr.b	mt_counter

	lea	buff1,a0
	moveq	#3,d6
.clloop
	move.l	(a0)+,d0
	beq.b	.skip
	move.l	d0,a1

	move.l	buffSize(a5),d7
	lsr.l	#2,d7
	subq.l	#1,d7
.cl	clr.l	(a1)+
	dbf	d7,.cl
.skip	dbf	d6,.clloop

	tst	PS3M_cont(a5)
	bne	.q

.huu	lea	cha0(a5),a0
	move	#mChanBlock_SIZE*16-1,d7
.cl2	clr	(a0)+
	dbf	d7,.cl2

	lea	c0(a5),a0
	move	#s3mChanBlock_SIZE*8-1,d7
.cl3	clr.l	(a0)+
	dbf	d7,.cl3

	move	tempo(a5),d0
	bne.b	.qw
	moveq	#125,d0
.qw	move.l	mrate(a5),d1
	move.l	d1,d2
	lsl.l	#2,d1
	add.l	d2,d1
	add	d0,d0
	divu	d0,d1

	addq	#1,d1
	and	#~1,d1

	move	d1,bytesperframe(a5)
	clr	bytes2do(a5)

	bset	#1,$bfe001

	bsr	makedivtabs
	bsr	Makevoltable

	ifeq	disable020
	
	move.l	4.w,a6
	btst	#1,297(a6)
	beq.b	.no020

; Processor is 020+!

	st	opt020(a5)
	
	cmp	#STEREO14,pmode(a5)
	beq.b	.s14_020

	move.l	#mix_020,mixad1(a5)
	move.l	#mix2_020,mixad2(a5)
	bra.b	.e

.s14_020
	move.l	#mix16_020,mixad1(a5)
	move.l	#mix162_020,mixad2(a5)
	bra.b	.e

	endc

; Processor is 000/010

.no020	clr	opt020(a5)

	cmp	#STEREO14,pmode(a5)
	beq.b	.s14_000

	move.l	#mix,mixad1(a5)
	move.l	#mix2,mixad2(a5)
	bra.b	.e

.s14_000
	move.l	#mix16,mixad1(a5)
	move.l	#mix162,mixad2(a5)


.e	cmp	#STEREO14,pmode(a5)
	bne.b	.nop

	move.l	#copybuf14,cbufad(a5)

	bsr	do14tab
	bra.b	.q

.nop	cmp	#REAL,pmode(a5)
	beq.b	.surr

	move.l	#copybuf,cbufad(a5)
	bra.b	.q

.surr	move.l	#copysurround,cbufad(a5)

.q	moveq	#0,d0
	rts




; D0 = New position

setPosition
	move	d0,PS3M_position(a5)
	cmp	#mtS3M,mtype(a5)
	beq.b	.s3m

	cmp	#mtXM,mtype(a5)
	beq.b	.xm

; MOD or MTM
	subq.b	#1,d0
	move.b	d0,mt_songpos
	clr.b	mt_pbreakpos
	st 	mt_posjumpflag
	clr.b	mt_counter
	
	movem.l	d0-d4/a0-a6,-(sp)
	bra	mt_nextposition

; S3M
.s3m	subq	#1,d0
	move	d0,pos(a5)
	move.l	s3m(a5),a0
	move.b	initialspeed(a0),spd+1(a5)
	clr	cn
	bra	burk

; XM
.xm	move	d0,pos(a5)
	st	pbflag(a5)
	clr	rows(a5)
	rts

PS3M_pause
	tst	PS3M_paused(a5)
	beq.b	.restore

.save	lea	cha0,a0
	lea	saveArray(pc),a1
	moveq	#31,d0
.l	move.b	mOnOff(a0),(a1)+
	st	mOnOff(a0)
	lea	mChanBlock_SIZE(a0),a0
	dbf	d0,.l
	rts

.restore
	lea	cha0,a0
	lea	saveArray(pc),a1
	moveq	#31,d0
.l2	move.b	(a1)+,mOnOff(a0)
	lea	mChanBlock_SIZE(a0),a0
	dbf	d0,.l2
	rts

saveArray
	dcb.b	32





;;***** Mixing routines *********


domix	lea	cha0(a5),a4
	lea	pantab(a5),a0
	moveq	#31,d7
	move.l	mixad1(a5),a1
.loo	tst.b	(a0)+
	beq.b	.n
	bmi.b	.n

	lea	tbuf,a2
	Push	a0/a1/d7
	jsr	(a1)				; Mix
	Pull	a0/a1/d7
	move	#1,chans(a5)
	lea	mChanBlock_SIZE(a4),a4
	subq	#1,d7
	bra.b	.loo2

.n	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.loo
	bra.b	.ddq


.loo2	cmp	#1,maxchan(a5)
	beq.b	.ddq

	move.l	mixad2(a5),a1
.loka	tst.b	(a0)+
	beq.b	.n2
	bmi.b	.n2

	lea	tbuf,a2
	Push	a0/a1/d7
	jsr	(a1)
	Pull	a0/a1/d7

.n2	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.loka

.ddq	lea	tbuf,a0
	move.l	buff1(a5),a1
	move.l	buff3(a5),a4
	move.l	cbufad(a5),a2
	jsr	(a2)


right	lea	cha0(a5),a4
	lea	pantab(a5),a0
	move.l	mixad1(a5),a1
	moveq	#31,d7
.loo	tst.b	(a0)+
	bpl.b	.n

	lea	tbuf2,a2
	Push	a0/a1/d7
	jsr	(a1)
	Pull	a0/a1/d7
	move	#1,chans(a5)
	lea	mChanBlock_SIZE(a4),a4
	subq	#1,d7
	bra.b	.loo2

.n	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.loo
	bra.b	.ddq


.loo2	cmp	#1,maxchan(a5)
	beq.b	.ddq
	move.l	mixad2(a5),a1
.loka	tst.b	(a0)+
	bpl.b	.n2

	lea	tbuf2,a2
	Push	a0/a1/d7
	jsr	(a1)
	Pull	a0/a1/d7

.n2	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.loka

.ddq	lea	tbuf2,a0
	move.l	buff2(a5),a1
	move.l	buff4(a5),a4
	move.l	cbufad(a5),a2
	jsr	(a2)

	moveq	#0,d0
	move	bytes2do(a5),d0
	add.l	d0,bufpos(a5)
	move.l	buffSizeMask(a5),d0
	and.l	d0,bufpos(a5)
	clr	bytes2do(a5)
	rts


copybuf	move.l	bufpos(a5),d0
	move.l	d0,d1
	moveq	#0,d2
	move	bytes2do(a5),d2
	add.l	d2,d1
	cmp.l	buffSizeMask(a5),d1
	ble.b	.dd

	move.l	a1,a3

	move.l	buffSize(a5),d7
	sub.l	d0,d7
	lsr.l	#1,d7
	subq	#1,d7
	add.l	d0,a1
	lea	divtabs(a5),a2
	move	chans(a5),d0
	lsl	#2,d0
	move.l	-4(a2,d0),a2

.ldd	move	(a0)+,d2
	move.b	(a2,d2),(a1)+
	move	(a0)+,d2
	move.b	(a2,d2),(a1)+
	dbf	d7,.ldd

	move.l	a3,a1
	move.l	d1,d7
	sub.l	buffSize(a5),d7
	lsr.l	#1,d7
	subq	#1,d7
	bmi.b	.ddq
.ldd2	move	(a0)+,d2
	move.b	(a2,d2),(a1)+
	move	(a0)+,d2
	move.b	(a2,d2),(a1)+
	dbf	d7,.ldd2
.ddq	rts

.dd	add.l	d0,a1
	lea	divtabs(a5),a2
	move	chans(a5),d0
	lsl	#2,d0
	move.l	-4(a2,d0),a2
	move	bytes2do(a5),d7
	lsr	#1,d7
	subq	#1,d7
.ldd3	move	(a0)+,d1
	move.b	(a2,d1),(a1)+
	move	(a0)+,d1
	move.b	(a2,d1),(a1)+
	dbf	d7,.ldd3
	rts

copysurround
	move.l	bufpos(a5),d0
	move.l	d0,d1

	moveq	#0,d2
	move	bytes2do(a5),d2
	add.l	d2,d1

	cmp.l	buffSizeMask(a5),d1
	ble.b	.dd

	movem.l	a1/a4,-(sp)

	move.l	buffSize(a5),d7
	sub.l	d0,d7
	lsr.l	#1,d7
	subq	#1,d7
	add.l	d0,a1
	add.l	d0,a4
	lea	divtabs(a5),a2
	move	chans(a5),d0
	lsl	#2,d0
	move.l	-4(a2,d0),a2

.ldd	move	(a0)+,d2
	move.b	(a2,d2),d2
	move.b	d2,(a1)+
	not	d2
	move.b	d2,(a4)+

	move	(a0)+,d2
	move.b	(a2,d2),d2
	move.b	d2,(a1)+
	not	d2
	move.b	d2,(a4)+
	dbf	d7,.ldd

	movem.l	(sp)+,a1/a4

	move.l	d1,d7
	sub.l	buffSize(a5),d7
	lsr.l	#1,d7
	subq	#1,d7
	bmi.b	.ddq
.ldd2	move	(a0)+,d2
	move.b	(a2,d2),d2
	move.b	d2,(a1)+
	not	d2
	move.b	d2,(a4)+

	move	(a0)+,d2
	move.b	(a2,d2),d2
	move.b	d2,(a1)+
	not	d2
	move.b	d2,(a4)+
	dbf	d7,.ldd2
.ddq	rts

.dd	add.l	d0,a1
	add.l	d0,a4
	lea	divtabs(a5),a2
	move	chans(a5),d0
	lsl	#2,d0
	move.l	-4(a2,d0),a2
	move	bytes2do(a5),d7
	lsr	#1,d7
	subq	#1,d7
.ldd3	move	(a0)+,d2
	move.b	(a2,d2),d2
	move.b	d2,(a1)+
	not	d2
	move.b	d2,(a4)+

	move	(a0)+,d2
	move.b	(a2,d2),d2
	move.b	d2,(a1)+
	not	d2
	move.b	d2,(a4)+
	dbf	d7,.ldd3
	rts


copybuf14
	move.l	bufpos(a5),d0
	move.l	d0,d1
	moveq	#0,d2
	move	bytes2do(a5),d2
	add.l	d2,d1
	cmp.l	buffSizeMask(a5),d1
	ble.b	.dd

	movem.l	a1/a4,-(sp)

	move.l	buffSize(a5),d7
	sub.l	d0,d7
	subq	#1,d7
	add.l	d0,a1
	add.l	d0,a4
	moveq	#0,d2
	move.l	buff14(a5),a2
	moveq	#-2,d0
.ldd	move	(a0)+,d2
	and.l	d0,d2
	move.b	(a2,d2.l),(a1)+
	move.b	1(a2,d2.l),(a4)+
	dbf	d7,.ldd

.huu	movem.l	(sp)+,a1/a4
	move.l	d1,d7
	sub.l	buffSize(a5),d7
	subq	#1,d7
	bmi.b	.ddq

.ldd2	move	(a0)+,d2
	and.l	d0,d2
	move.b	(a2,d2.l),(a1)+
	move.b	1(a2,d2.l),(a4)+
	dbf	d7,.ldd2
.ddq	rts


.dd	add.l	d0,a1
	add.l	d0,a4
	move	bytes2do(a5),d7
	subq	#1,d7
	move.l	buff14(a5),a2
	moveq	#0,d2
	moveq	#-2,d0
.ldd3	move	(a0)+,d2
	and.l	d0,d2
	move.b	(a2,d2.l),(a1)+
	move.b	1(a2,d2.l),(a4)+
	dbf	d7,.ldd3
	rts


; 000/010 Mixing routines

; Mixing routine for the first channel (moves data)


mix	moveq	#0,d7
	move	bytes2do(a5),d7
	subq	#1,d7
	
	tst	mPeriod(a4)
	beq	.ty
	tst.b	mOnOff(a4)
	bne	.ty			;sound off

	tst	mVolume(a4)
	beq	.vol0

.dw	move.l	clock(a5),d4
	divu	mPeriod(a4),d4
	swap	d4
	clr	d4
	lsr.l	#2,d4

	move.l	mrate(a5),d0
	divu	d0,d4
	swap	d4
	clr	d4
	rol.l	#4,d4

	move.l	vtabaddr(a5),d2
	move	mVolume(a4),d0
	mulu	PS3M_master(a5),d0
	lsr	#6,d0
	lsl.l	#8,d0
	add.l	d0,d2				; Position in volume table

	move.l	(a4),a0				;mStart
	move.l	mFPos(a4),d0

	moveq	#0,d3
	moveq	#0,d5

	move.l	mLength(a4),d6
	beq.b	.ddwq

	cmp.l	#$ffff,d6
	bls.b	.leii
	move	#$ffff,d6

.leii	cmp	#32,d7
	blt.b	.lep
	move.l	d4,d1
	swap	d1
	lsl.l	#5,d1
	swap	d1
	add.l	d0,d1
	cmp	d6,d1
	bhs.b	.lep
	pea	.leii(pc)
	bra	.mix32

.lep	move.b	(a0,d0),d2
	move.l	d2,a1
	add.l	d4,d0
	move.b	(a1),d3
	addx	d5,d0
	move	d3,(a2)+

	cmp	d6,d0
	bhs.b	.ddwq
	dbf	d7,.lep
	bra.b	.qw

.ddwq	tst.b	mLoop(a4)
	bne.b	.q
	st	mOnOff(a4)
	bra.b	.ty

.q	move.l	mLStart(a4),a0
	moveq	#0,d1
	move	d0,d1
	sub.l	mLength(a4),d1
	add.l	d1,a0
	move.l	mLLength(a4),d6
	sub.l	d1,d6
	move.l	d6,mLength(a4)

	cmp.l	#$ffff,d6
	bls.b	.j
	move	#$ffff,d6
.j	clr	d0				;reset integer part
	dbf	d7,.leii

.qw	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)				;mStart
	move.l	d0,mFPos(a4)

	sub.l	d1,mLength(a4)
	bpl.b	.u

	tst.b	mLoop(a4)
	bne.b	.q2
	st	mOnOff(a4)
	bra.b	.u

.q2	move.l	mLLength(a4),d6
	sub.l	(a4),a0
	add.l	mLStart(a4),a0
	sub.l	d6,a0
	add.l	d6,mLength(a4)
	move.l	a0,(a4)				; mStart
.u	rts

.ty	move	#$80,d0
	tst	d7
	bmi.b	.e
.lll	move	d0,(a2)+
	dbf	d7,.lll
.e	rts

.mix32	rept	16
	move.b	(a0,d0),d2
	move.l	d2,a1
	move.b	(a1),d3
	move	d3,(a2)+
	add.l	d4,d0
	addx	d5,d0

	move.b	(a0,d0),d2
	move.l	d2,a1
	move.b	(a1),d3
	move	d3,(a2)+
	add.l	d4,d0
	addx	d5,d0
	endr

	sub	#32,d7
	rts



.vol0	move.l	clock(a5),d4
	divu	mPeriod(a4),d4		;period
	swap	d4
	clr	d4
	lsr.l	#2,d4

	move.l	mrate(a5),d0
	divu	d0,d4
	swap	d4
	clr	d4
	rol.l	#4,d4
	swap	d4

	move.l	(a4),a0			;mStart
	move.l	mFPos(a4),d0

	addq	#1,d7

	movem.l	d0/d1,-(sp)
	move.l	d7,d1
	move.l	d4,d0
	bsr	mulu_32
	move.l	d0,d4
	movem.l	(sp)+,d0/d1

	subq	#1,d7

	swap	d0
	add.l	d4,d0			; Position after "mixing"
	swap	d0
	
	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)
	move.l	d0,mFPos(a4)
	sub.l	d1,mLength(a4)
	bpl	.ty			; OK, Done!

; We're about to mix past the end of the sample

	tst.b	mLoop(a4)
	bne.b	.q3
	st	mOnOff(a4)
	bra	.ty

.q3	move.l	mLLength(a4),d6
.loop	sub.l	d6,a0
	add.l	d6,mLength(a4)
	bmi.b	.loop
	beq.b	.loop

	move.l	a0,(a4)
	bra	.ty



; Mixing routine for rest of the channels (adds data)

mix2	moveq	#0,d7
	move	bytes2do(a5),d7

	tst	mPeriod(a4)
	beq	.ty
	tst.b	mOnOff(a4)
	bne	.ty			;noloop

	tst	mVolume(a4)
	beq	.vol0

.dw	subq	#1,d7

	move.l	clock(a5),d4
	divu	mPeriod(a4),d4
	swap	d4
	clr	d4
	lsr.l	#2,d4

	move.l	mrate(a5),d0
	divu	d0,d4
	swap	d4
	clr	d4
	rol.l	#4,d4

	move.l	vtabaddr(a5),d2
	move	mVolume(a4),d0
	mulu	PS3M_master(a5),d0
	lsr	#6,d0
	lsl.l	#8,d0
	add.l	d0,d2

	move.l	(a4),a0			;mStart
	move.l	mFPos(a4),d0

	moveq	#0,d3
	moveq	#0,d5

	move.l	mLength(a4),d6
	beq.b	.ddwq

	cmp.l	#$ffff,d6
	bls.b	.leii
	move	#$ffff,d6

.leii	cmp	#32,d7
	blt.b	.lep
	move.l	d4,d1
	swap	d1
	lsl.l	#5,d1
	swap	d1
	add.l	d0,d1
	cmp	d6,d1
	bhs.b	.lep
	pea	.leii(pc)
	bra	.mix32

.lep	move.b	(a0,d0),d2
	move.l	d2,a1
	add.l	d4,d0
	move.b	(a1),d3
	addx	d5,d0
	add	d3,(a2)+

	cmp	d6,d0
	bhs.b	.ddwq
	dbf	d7,.lep
	bra.b	.qw

.ddwq	tst.b	mLoop(a4)
	bne.b	.q
	st	mOnOff(a4)
	bra.b	.tyy

.q	move.l	mLStart(a4),a0
	moveq	#0,d1
	move	d0,d1
	sub.l	mLength(a4),d1
	add.l	d1,a0
	move.l	mLLength(a4),d6
	sub.l	d1,d6
	move.l	d6,mLength(a4)
	cmp.l	#$ffff,d6
	bls.b	.j
	move	#$ffff,d6
.j	clr	d0			;reset integer part
	dbf	d7,.leii

.qw	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)
	move.l	d0,mFPos(a4)

	sub.l	d1,mLength(a4)
	bpl.b	.u

	tst.b	mLoop(a4)
	bne.b	.q2
	st	mOnOff(a4)
	bra.b	.u

.q2	move.l	mLLength(a4),d6
	sub.l	(a4),a0
	add.l	mLStart(a4),a0
	sub.l	d6,a0
	add.l	d6,mLength(a4)
	move.l	a0,(a4)

.u	addq	#1,chans(a5)
.ty	rts

.tyy	move	#$80,d0
	tst	d7
	bmi.b	.u
.ll3	add	d0,(a2)+
	dbf	d7,.ll3
	bra.b	.u

.mix32	rept	32
	move.b	(a0,d0),d2
	move.l	d2,a1
	move.b	(a1),d3
	add	d3,(a2)+
	add.l	d4,d0
	addx	d5,d0
	endr
	sub	#32,d7
	rts


.vol0	move.l	clock(a5),d4
	divu	mPeriod(a4),d4
	swap	d4
	clr	d4
	lsr.l	#2,d4

	move.l	mrate(a5),d0
	divu	d0,d4
	swap	d4
	clr	d4
	rol.l	#4,d4
	swap	d4

	move.l	(a4),a0			;pos (addr)
	move.l	mFPos(a4),d0

	addq	#1,d7
	movem.l	d0/d1,-(sp)
	move.l	d7,d1
	move.l	d4,d0
	bsr	mulu_32
	move.l	d0,d4
	movem.l	(sp)+,d0/d1

	subq	#1,d7
	swap	d0
	add.l	d4,d0			; Position after "mixing"
	swap	d0
	
	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)
	move.l	d0,mFPos(a4)
	sub.l	d1,mLength(a4)
	bpl	.ty			; OK, Done!

; We're about to mix past the end of the sample

	tst.b	mLoop(a4)
	bne.b	.q3
	st	mOnOff(a4)
	bra	.ty

.q3	move.l	mLLength(a4),d6
.loop	sub.l	d6,a0
	add.l	d6,mLength(a4)
	bmi.b	.loop
	beq.b	.loop

	move.l	a0,(a4)
	bra	.ty


; 16-bit mixing routine for first channel (moves data)

mix16	moveq	#0,d7
	move	bytes2do(a5),d7
	subq	#1,d7

	tst	mPeriod(a4)
	beq	.ty
	tst.b	mOnOff(a4)
	bne	.ty

	tst	mVolume(a4)
	beq	.vol0

.dw	move.l	clock(a5),d4
	divu	mPeriod(a4),d4
	swap	d4
	clr	d4
	lsr.l	#2,d4

	move.l	mrate(a5),d0
	divu	d0,d4
	swap	d4
	clr	d4
	rol.l	#4,d4

	move.l	vtabaddr(a5),a3
	move	mVolume(a4),d0
	mulu	PS3M_master(a5),d0
	lsr	#6,d0
	add	d0,d0
	lsl.l	#8,d0
	add.l	d0,a3				; Position in volume table

	move.l	(a4),a0				;mStart
	move.l	mFPos(a4),d0

	moveq	#0,d3
	moveq	#0,d5

	move.l	mLength(a4),d6
	beq.b	.ddwq

	cmp.l	#$ffff,d6
	bls.b	.leii
	move	#$ffff,d6

.leii	cmp	#32,d7
	blt.b	.lep
	move.l	d4,d1
	swap	d1
	lsl.l	#5,d1
	swap	d1
	add.l	d0,d1
	cmp	d6,d1
	bhs.b	.lep
	pea	.leii(pc)
	bra	.mix32

.lep	moveq	#0,d2
	move.b	(a0,d0),d2
	add	d2,d2
	add.l	d4,d0
	move	(a3,d2),(a2)+
	addx	d5,d0

	cmp	d6,d0
	bhs.b	.ddwq
	dbf	d7,.lep
	bra.b	.qw

.ddwq	tst.b	mLoop(a4)
	bne.b	.q
	st	mOnOff(a4)
	bra.b	.ty

.q	move.l	mLStart(a4),a0
	moveq	#0,d1
	move	d0,d1
	sub.l	mLength(a4),d1
	add.l	d1,a0
	move.l	mLLength(a4),d6
	sub.l	d1,d6
	move.l	d6,mLength(a4)

	cmp.l	#$ffff,d6
	bls.b	.j
	move	#$ffff,d6
.j	clr	d0				;reset integer part
	dbf	d7,.leii

.qw	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)				;mStart
	move.l	d0,mFPos(a4)

	sub.l	d1,mLength(a4)
	bpl.b	.u

	tst.b	mLoop(a4)
	bne.b	.q2
	st	mOnOff(a4)
	bra.b	.u

.q2	move.l	mLLength(a4),d6
	sub.l	(a4),a0
	add.l	mLStart(a4),a0
	sub.l	d6,a0
	add.l	d6,mLength(a4)
	move.l	a0,(a4)				; mStart
.u	rts

.ty	moveq	#0,d0
	tst	d7
	bmi.b	.e
.lll	move	d0,(a2)+
	dbf	d7,.lll
.e	rts


.mix32	rept	32

	moveq	#0,d2
	move.b	(a0,d0),d2
	add	d2,d2
	add.l	d4,d0
	move	(a3,d2),(a2)+
	addx	d5,d0

	endr

	sub	#32,d7
	rts


.vol0	move.l	clock(a5),d4
	divu	mPeriod(a4),d4		;period
	swap	d4
	clr	d4
	lsr.l	#2,d4

	move.l	mrate(a5),d0
	divu	d0,d4
	swap	d4
	clr	d4
	rol.l	#4,d4
	swap	d4

	move.l	(a4),a0			;mStart
	move.l	mFPos(a4),d0

	addq	#1,d7

	movem.l	d0/d1,-(sp)
	move.l	d7,d1
	move.l	d4,d0
	bsr	mulu_32
	move.l	d0,d4
	movem.l	(sp)+,d0/d1

	subq	#1,d7

	swap	d0
	add.l	d4,d0			; Position after "mixing"
	swap	d0
	
	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)
	move.l	d0,mFPos(a4)
	sub.l	d1,mLength(a4)
	bpl	.ty			; OK, Done!

; We're about to mix past the end of the sample

	tst.b	mLoop(a4)
	bne.b	.q3
	st	mOnOff(a4)
	bra	.ty

.q3	move.l	mLLength(a4),d6
.loop	sub.l	d6,a0
	add.l	d6,mLength(a4)
	bmi.b	.loop
	beq.b	.loop

	move.l	a0,(a4)
	bra	.ty



; Mixing routine for rest of the channels (adds data)

mix162	moveq	#0,d7
	move	bytes2do(a5),d7

	tst	mPeriod(a4)
	beq	.ty
	tst.b	mOnOff(a4)
	bne	.ty

	tst	mVolume(a4)
	beq	.vol0

.dw	subq	#1,d7

	move.l	clock(a5),d4
	divu	mPeriod(a4),d4
	swap	d4
	clr	d4
	lsr.l	#2,d4

	move.l	mrate(a5),d0
	divu	d0,d4
	swap	d4
	clr	d4
	rol.l	#4,d4

	move.l	vtabaddr(a5),a3
	move	mVolume(a4),d0		;volu
	mulu	PS3M_master(a5),d0
	lsr	#6,d0
	add	d0,d0
	lsl.l	#8,d0
	add.l	d0,a3

	move.l	(a4),a0			;mStart
	move.l	mFPos(a4),d0

	moveq	#0,d3
	moveq	#0,d5

	move.l	mLength(a4),d6
	beq.b	.ddwq

	cmp.l	#$ffff,d6
	bls.b	.leii
	move	#$ffff,d6

.leii	cmp	#32,d7
	blt.b	.lep
	move.l	d4,d1
	swap	d1
	lsl.l	#5,d1
	swap	d1
	add.l	d0,d1
	cmp	d6,d1
	bhs.b	.lep
	pea	.leii(pc)
	bra	.mix32

.lep	moveq	#0,d2
	move.b	(a0,d0),d2
	add	d2,d2
	add.l	d4,d0
	move	(a3,d2),d3
	addx	d5,d0
	add	d3,(a2)+

	cmp	d6,d0
	bhs.b	.ddwq
	dbf	d7,.lep
	bra.b	.qw

.ddwq	tst.b	mLoop(a4)
	bne.b	.q
	st	mOnOff(a4)
	bra.b	.tyy

.q	move.l	mLStart(a4),a0
	moveq	#0,d1
	move	d0,d1
	sub.l	mLength(a4),d1
	add.l	d1,a0
	move.l	mLLength(a4),d6
	sub.l	d1,d6
	move.l	d6,mLength(a4)
	cmp.l	#$ffff,d6
	bls.b	.j
	move	#$ffff,d6
.j	clr	d0			;reset integer part
	dbf	d7,.leii

.qw	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)
	move.l	d0,mFPos(a4)

	sub.l	d1,mLength(a4)
	bpl.b	.u

	tst.b	mLoop(a4)
	bne.b	.q2
	st	mOnOff(a4)
	bra.b	.u

.q2	move.l	mLLength(a4),d6
	sub.l	(a4),a0
	add.l	mLStart(a4),a0
	sub.l	d6,a0
	add.l	d6,mLength(a4)
	move.l	a0,(a4)

.u
.ty	rts

.tyy	move	#$80,d0
	tst	d7
	bmi.b	.u
.ll3	add	d0,(a2)+
	dbf	d7,.ll3
	bra.b	.u

.mix32	rept	32
	moveq	#0,d2
	move.b	(a0,d0),d2
	add	d2,d2
	move	(a3,d2),d3
	add.l	d4,d0
	addx	d5,d0
	add	d3,(a2)+
	endr
	sub	#32,d7
	rts

.vol0	move.l	clock(a5),d4
	divu	mPeriod(a4),d4
	swap	d4
	clr	d4
	lsr.l	#2,d4

	move.l	mrate(a5),d0
	divu	d0,d4
	swap	d4
	clr	d4
	rol.l	#4,d4
	swap	d4

	move.l	(a4),a0			;pos (addr)
	move.l	mFPos(a4),d0

	addq	#1,d7
	movem.l	d0/d1,-(sp)
	move.l	d7,d1
	move.l	d4,d0
	bsr	mulu_32
	move.l	d0,d4
	movem.l	(sp)+,d0/d1

	subq	#1,d7
	swap	d0
	add.l	d4,d0			; Position after "mixing"
	swap	d0
	
	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)
	move.l	d0,mFPos(a4)
	sub.l	d1,mLength(a4)
	bpl	.ty			; OK, Done!

; We're about to mix past the end of the sample

	tst.b	mLoop(a4)
	bne.b	.q3
	st	mOnOff(a4)
	bra	.ty

.q3	move.l	mLLength(a4),d6
.loop	sub.l	d6,a0
	add.l	d6,mLength(a4)
	bmi.b	.loop
	beq.b	.loop

	move.l	a0,(a4)
	bra	.ty




	ifeq	disable020

; 020+ Optimized versions!

; Mixing routine for the first channel (moves data)


mix_020	moveq	#0,d7
	move	bytes2do(a5),d7
	tst	mPeriod(a4)
	beq	.ty
	tst.b	mOnOff(a4)
	bne	.ty

	tst	mVolume(a4)
	beq	.vol0

.dw	move.l	clock(a5),d4
	moveq	#0,d0
	move	mPeriod(a4),d0

	divu.l	d0,d4

	lsl.l	#8,d4
	lsl.l	#6,d4

	move.l	mrate(a5),d0
	lsr.l	#4,d0

	divu.l	d0,d4
	swap	d4

	move.l	vtabaddr(a5),d2
	move	mVolume(a4),d0
	mulu	PS3M_master(a5),d0
	lsr	#6,d0
	lsl.l	#8,d0
	add.l	d0,d2			; Position in volume table

	move.l	(a4),a0			;pos (addr)
	move.l	mFPos(a4),d0		;fpos

	move.l	mLength(a4),d6		;len
	beq	.resloop

	cmp.l	#$ffff,d6
	bls.b	.restart
	move	#$ffff,d6
.restart
	swap	d6
	swap	d0
	sub.l	d0,d6
	swap	d0
	move.l	d4,d5
	swap	d5

	divul.l	d5,d5:d6		; bytes left to loop end
	tst.l	d5
	beq.b	.e
	addq.l	#1,d6
.e
	moveq	#0,d3
	moveq	#0,d5
.mixloop
	moveq	#8,d1
	cmp	d1,d7
	bhs.b	.ok
	move	d7,d1
.ok	cmp.l	d1,d6
	bhs.b	.ok2
	move.l	d6,d1
.ok2	sub	d1,d7
	sub.l	d1,d6

	jmp	.jtab1(pc,d1*2)

.a set 0
.jtab1
	rept	8
	bra.b	.mend-.a
.a set .a+14				; (mend - dmix) / 8
	endr

.dmix	rept	8
	move.b	(a0,d0),d2
	move.l	d2,a1
	move.b	(a1),d3
	add.l	d4,d0
	move	d3,(a2)+
	addx	d5,d0
	endr
.mend	tst	d7
	beq.b	.done
	tst.l	d6
	bne	.mixloop

.resloop
	tst.b	mLoop(a4)
	bne.b	.q
	st	mOnOff(a4)
	bra.b	.ty

.q	moveq	#0,d1
	move	d0,d1
	sub.l	mLength(a4),d1
	move.l	mLStart(a4),a0
	add.l	d1,a0
	move.l	mLLength(a4),d6
	sub.l	d1,d6
	move.l	d6,mLength(a4)
	cmp.l	#$ffff,d6
	bls.b	.j
	move	#$ffff,d6
.j	clr	d0			;reset integer part
	bra	.restart

.done	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)
	move.l	d0,mFPos(a4)
	sub.l	d1,mLength(a4)
	bpl.b	.u

	tst.b	mLoop(a4)
	bne.b	.q2
	st	mOnOff(a4)
	bra.b	.u

.q2	move.l	mLLength(a4),d6
	sub.l	(a4),a0
	add.l	mLStart(a4),a0
	sub.l	d6,a0
	add.l	d6,mLength(a4)
	move.l	a0,(a4)
.u	rts

.ty	move	#$80,d0
	subq	#1,d7
.lll	move	d0,(a2)+
	dbf	d7,.lll
	rts


.vol0	move.l	clock(a5),d4
	moveq	#0,d0
	move	mPeriod(a4),d0

	divu.l	d0,d4

	lsl.l	#8,d4
	lsl.l	#6,d4

	move.l	mrate(a5),d0
	lsr.l	#4,d0

	divu.l	d0,d4

	move.l	(a4),a0
	move.l	mFPos(a4),d0

	mulu.l	d7,d4

	swap	d0
	add.l	d4,d0			; Position after "mixing"
	swap	d0
	
	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)
	move.l	d0,mFPos(a4)
	sub.l	d1,mLength(a4)
	bpl.b	.ty			; OK, Done!

; We're about to mix past the end of the sample

	tst.b	mLoop(a4)
	bne.b	.q3
	st	mOnOff(a4)
	bra.b	.ty

.q3	move.l	mLLength(a4),d6
.loop	sub.l	d6,a0
	add.l	d6,mLength(a4)
	bmi.b	.loop
	beq.b	.loop

	move.l	a0,(a4)
	bra.b	.ty


; Mixing routine for rest of the channels (adds data)

mix2_020
	moveq	#0,d7
	move	bytes2do(a5),d7
	tst	mPeriod(a4)
	beq	.ty
	tst.b	mOnOff(a4)
	bne	.ty

	tst	mVolume(a4)
	beq	.vol0

.dw	move.l	clock(a5),d4
	moveq	#0,d0
	move	mPeriod(a4),d0

	divu.l	d0,d4

	lsl.l	#8,d4
	lsl.l	#6,d4

	move.l	mrate(a5),d0
	lsr.l	#4,d0

	divu.l	d0,d4

	swap	d4

	move.l	vtabaddr(a5),d2
	move	mVolume(a4),d0
	mulu	PS3M_master(a5),d0
	lsr	#6,d0
	lsl.l	#8,d0
	add.l	d0,d2			; Position in volume table

	move.l	(a4),a0
	move.l	mFPos(a4),d0

	move.l	mLength(a4),d6
	beq	.resloop

	cmp.l	#$ffff,d6
	bls.b	.restart
	move	#$ffff,d6
.restart
	swap	d6
	swap	d0
	sub.l	d0,d6
	swap	d0

	move.l	d4,d5
	swap	d5

	divul.l	d5,d5:d6		; bytes left to loop end
	tst.l	d5
	beq.b	.e
	addq.l	#1,d6
.e	moveq	#0,d3
	moveq	#0,d5
.mixloop
	moveq	#8,d1
	cmp	d1,d7
	bhi.b	.ok
	move	d7,d1
.ok	cmp.l	d1,d6
	bhi.b	.ok2
	move	d6,d1
.ok2	sub	d1,d7
	sub.l	d1,d6
	jmp	.jtab1(pc,d1*2)

.a set 0
.jtab1	rept	8
	bra.b	.mend-.a
.a set .a+14				; (mend - dmix) / 8
	endr

.dmix	rept	8
	move.b	(a0,d0),d2
	move.l	d2,a1
	move.b	(a1),d3
	add	d3,(a2)+
	add.l	d4,d0
	addx	d5,d0
	endr
.mend	tst	d7
	beq.b	.done
	tst.l	d6
	bne	.mixloop

.resloop
	tst.b	mLoop(a4)
	bne.b	.q
	st	mOnOff(a4)
	bra.b	.tyy

.q	moveq	#0,d1
	move	d0,d1
	sub.l	mLength(a4),d1
	move.l	mLStart(a4),a0
	add.l	d1,a0
	move.l	mLLength(a4),d6
	sub.l	d1,d6
	move.l	d6,mLength(a4)
	cmp.l	#$ffff,d6
	bls.b	.j
	move	#$ffff,d6
.j	clr	d0			;reset integer part
	bra	.restart

.done	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)
	move.l	d0,mFPos(a4)
	sub.l	d1,mLength(a4)
	bpl.b	.u

	tst.b	mLoop(a4)
	bne.b	.q2
	st	mOnOff(a4)
	bra.b	.u

.q2	move.l	mLLength(a4),d6
	sub.l	(a4),a0
	add.l	mLStart(a4),a0
	sub.l	d6,a0
	add.l	d6,mLength(a4)
	move.l	a0,(a4)

.u	addq	#1,chans
.ty	rts

.tyy	move	#$80,d0
	subq	#1,d7
	bmi.b	.u
.ll3	add	d0,(a2)+
	dbf	d7,.ll3
	bra.b	.u


.vol0	move.l	clock(a5),d4
	moveq	#0,d0
	move	mPeriod(a4),d0

	divu.l	d0,d4

	lsl.l	#8,d4
	lsl.l	#6,d4

	move.l	mrate(a5),d0
	lsr.l	#4,d0

	divu.l	d0,d4

	move.l	(a4),a0
	move.l	mFPos(a4),d0

	mulu.l	d7,d4

	swap	d0
	add.l	d4,d0			; Position after "mixing"
	swap	d0
	
	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)
	move.l	d0,mFPos(a4)
	sub.l	d1,mLength(a4)
	bpl.b	.ty			; OK, Done!

; We're about to mix past the end of the sample

	tst.b	mLoop(a4)
	bne.b	.q3
	st	mOnOff(a4)
	bra.b	.ty

.q3	move.l	mLLength(a4),d6
.loop	sub.l	d6,a0
	add.l	d6,mLength(a4)
	bmi.b	.loop
	beq.b	.loop

	move.l	a0,(a4)
	bra.b	.ty



; Mixing routine for the first channel (moves data)


mix16_020
	moveq	#0,d7
	move	bytes2do(a5),d7
	tst	mPeriod(a4)
	beq	.ty
	tst.b	mOnOff(a4)
	bne	.ty

	tst	mVolume(a4)
	beq	.vol0

.dw	move.l	clock(a5),d4
	moveq	#0,d0
	move	mPeriod(a4),d0

	divu.l	d0,d4

	lsl.l	#8,d4
	lsl.l	#6,d4

	move.l	mrate(a5),d0
	lsr.l	#4,d0

	divu.l	d0,d4
	swap	d4

	move.l	vtabaddr(a5),a3
	move	mVolume(a4),d0
	mulu	PS3M_master(a5),d0
	lsr	#6,d0
	add	d0,d0
	lsl.l	#8,d0
	add.l	d0,a3			; Position in volume table

	move.l	(a4),a0			;pos (addr)
	move.l	mFPos(a4),d0		;fpos

	move.l	mLength(a4),d6		;len
	beq	.resloop

	cmp.l	#$ffff,d6
	bls.b	.restart
	move	#$ffff,d6
.restart
	swap	d6
	swap	d0
	sub.l	d0,d6
	swap	d0
	move.l	d4,d5
	swap	d5

	divul.l	d5,d5:d6		; bytes left to loop end
	tst.l	d5
	beq.b	.e
	addq.l	#1,d6
.e
	moveq	#0,d5
	moveq	#0,d2
.mixloop
	moveq	#8,d1
	cmp	d1,d7
	bhs.b	.ok
	move	d7,d1
.ok	cmp.l	d1,d6
	bhs.b	.ok2
	move.l	d6,d1
.ok2	sub	d1,d7
	sub.l	d1,d6

	jmp	.jtab1(pc,d1*2)

.a set 0
.jtab1
	rept	8
	bra.b	.mend-.a
.a set .a+12				; (mend - dmix) / 8
	endr

.dmix	rept	8
	move.b	(a0,d0),d2
	add.l	d4,d0
	move	(a3,d2*2),(a2)+
	addx	d5,d0
	endr

.mend	tst	d7
	beq.b	.done
	tst.l	d6
	bne	.mixloop

.resloop
	tst.b	mLoop(a4)
	bne.b	.q
	st	mOnOff(a4)
	bra.b	.ty

.q	moveq	#0,d1
	move	d0,d1
	sub.l	mLength(a4),d1
	move.l	mLStart(a4),a0
	add.l	d1,a0
	move.l	mLLength(a4),d6
	sub.l	d1,d6
	move.l	d6,mLength(a4)
	cmp.l	#$ffff,d6
	bls.b	.j
	move	#$ffff,d6
.j	clr	d0			;reset integer part
	bra	.restart

.done	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)
	move.l	d0,mFPos(a4)
	sub.l	d1,mLength(a4)
	bpl.b	.u

	tst.b	mLoop(a4)
	bne.b	.q2
	st	mOnOff(a4)
	bra.b	.u

.q2	move.l	mLLength(a4),d6
	sub.l	(a4),a0
	add.l	mLStart(a4),a0
	sub.l	d6,a0
	add.l	d6,mLength(a4)
	move.l	a0,(a4)
.u	rts

.ty	moveq	#0,d0
	subq	#1,d7
.lll	move	d0,(a2)+
	dbf	d7,.lll
	rts


.vol0	move.l	clock(a5),d4
	moveq	#0,d0
	move	mPeriod(a4),d0

	divu.l	d0,d4

	lsl.l	#8,d4
	lsl.l	#6,d4

	move.l	mrate(a5),d0
	lsr.l	#4,d0

	divu.l	d0,d4

	move.l	(a4),a0
	move.l	mFPos(a4),d0

	mulu.l	d7,d4

	swap	d0
	add.l	d4,d0			; Position after "mixing"
	swap	d0
	
	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)
	move.l	d0,mFPos(a4)
	sub.l	d1,mLength(a4)
	bpl.b	.ty			; OK, Done!

; We're about to mix past the end of the sample

	tst.b	mLoop(a4)
	bne.b	.q3
	st	mOnOff(a4)
	bra.b	.ty

.q3	move.l	mLLength(a4),d6
.loop	sub.l	d6,a0
	add.l	d6,mLength(a4)
	bmi.b	.loop
	beq.b	.loop

	move.l	a0,(a4)
	bra.b	.ty


; Mixing routine for rest of the channels (adds data)

mix162_020
	moveq	#0,d7
	move	bytes2do(a5),d7
	tst	mPeriod(a4)
	beq	.ty
	tst.b	mOnOff(a4)
	bne	.ty

	tst	mVolume(a4)
	beq	.vol0

.dw	move.l	clock(a5),d4
	moveq	#0,d0
	move	mPeriod(a4),d0

	divu.l	d0,d4

	lsl.l	#8,d4
	lsl.l	#6,d4

	move.l	mrate(a5),d0
	lsr.l	#4,d0

	divu.l	d0,d4

	swap	d4

	move.l	vtabaddr(a5),a3
	move	mVolume(a4),d0
	mulu	PS3M_master(a5),d0
	lsr	#6,d0
	add	d0,d0
	lsl.l	#8,d0
	add.l	d0,a3			; Position in volume table

	move.l	(a4),a0
	move.l	mFPos(a4),d0

	move.l	mLength(a4),d6
	beq	.resloop

	cmp.l	#$ffff,d6
	bls.b	.restart
	move	#$ffff,d6
.restart
	swap	d6
	swap	d0
	sub.l	d0,d6
	swap	d0

	move.l	d4,d5
	swap	d5

	divul.l	d5,d5:d6		; bytes left to loop end
	tst.l	d5
	beq.b	.e
	addq.l	#1,d6
.e	moveq	#0,d2
	moveq	#0,d5
.mixloop
	moveq	#8,d1
	cmp	d1,d7
	bhi.b	.ok
	move	d7,d1
.ok	cmp.l	d1,d6
	bhi.b	.ok2
	move	d6,d1
.ok2	sub	d1,d7
	sub.l	d1,d6
	jmp	.jtab1(pc,d1*2)

.a set 0
.jtab1
	rept	8
	bra.b	.mend-.a
.a set .a+14				; (mend - dmix) / 8
	endr

.dmix	rept	8
	move.b	(a0,d0),d2
	add.l	d4,d0
	move	(a3,d2*2),d3
	addx	d5,d0
	add	d3,(a2)+
	endr

.mend	tst	d7
	beq.b	.done
	tst.l	d6
	bne	.mixloop

.resloop
	tst.b	mLoop(a4)
	bne.b	.q
	st	mOnOff(a4)
	bra.b	.tyy

.q	moveq	#0,d1
	move	d0,d1
	sub.l	mLength(a4),d1
	move.l	mLStart(a4),a0
	add.l	d1,a0
	move.l	mLLength(a4),d6
	sub.l	d1,d6
	move.l	d6,mLength(a4)
	cmp.l	#$ffff,d6
	bls.b	.j
	move	#$ffff,d6
.j	clr	d0			;reset integer part
	bra	.restart

.done	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)
	move.l	d0,mFPos(a4)
	sub.l	d1,mLength(a4)
	bpl.b	.u

	tst.b	mLoop(a4)
	bne.b	.q2
	st	mOnOff(a4)
	bra.b	.u

.q2	move.l	mLLength(a4),d6
	sub.l	(a4),a0
	add.l	mLStart(a4),a0
	sub.l	d6,a0
	add.l	d6,mLength(a4)
	move.l	a0,(a4)
.u
.ty
.tyy	rts


.vol0	move.l	clock(a5),d4
	moveq	#0,d0
	move	mPeriod(a4),d0

	divu.l	d0,d4

	lsl.l	#8,d4
	lsl.l	#6,d4

	move.l	mrate(a5),d0
	lsr.l	#4,d0

	divu.l	d0,d4

	move.l	(a4),a0
	move.l	mFPos(a4),d0

	mulu.l	d7,d4

	swap	d0
	add.l	d4,d0			; Position after "mixing"
	swap	d0
	
	moveq	#0,d1
	move	d0,d1
	add.l	d1,a0
	clr	d0
	move.l	a0,(a4)
	move.l	d0,mFPos(a4)
	sub.l	d1,mLength(a4)
	bpl.b	.ty			; OK, Done!

; We're about to mix past the end of the sample

	tst.b	mLoop(a4)
	bne.b	.q3
	st	mOnOff(a4)
	bra.b	.ty

.q3	move.l	mLLength(a4),d6
.loop	sub.l	d6,a0
	add.l	d6,mLength(a4)
	bmi.b	.loop
	beq.b	.loop

	move.l	a0,(a4)
	bra.b	.ty

	endc


* mulu_32 --- d0 = d0*d1
mulu_32	movem.l	d2/d3,-(sp)
	move.l	d0,d2
	move.l	d1,d3
	swap	d2
	swap	d3
	mulu	d1,d2
	mulu	d0,d3
	mulu	d1,d0
	add	d3,d2
	swap	d2
	clr	d2
	add.l	d2,d0
	movem.l	(sp)+,d2/d3
	rts	

* divu_32 --- d0 = d0/d1, d1=jakojไไnn๖s
divu_32	move.l	d3,-(a7)
	swap	d1
	tst	d1
	bne.b	lb_5f8c
	swap	d1
	move.l	d1,d3
	swap	d0
	move	d0,d3
	beq.b	lb_5f7c
	divu	d1,d3
	move	d3,d0
lb_5f7c	swap	d0
	move	d0,d3
	divu	d1,d3
	move	d3,d0
	swap	d3
	move	d3,d1
	move.l	(a7)+,d3
	rts	

lb_5f8c	swap	d1
	move	d2,-(a7)
	moveq	#16-1,d3
	move	d3,d2
	move.l	d1,d3
	move.l	d0,d1
	clr	d1
	swap	d1
	swap	d0
	clr	d0
lb_5fa0	add.l	d0,d0
	addx.l	d1,d1
	cmp.l	d1,d3
	bhi.b	lb_5fac
	sub.l	d3,d1
	addq	#1,d0
lb_5fac	dbf	d2,lb_5fa0
	move	(a7)+,d2
	move.l	(a7)+,d3
	rts	


;;******** Init routines ***********


detectchannels
	lea	ch(pc),a0
	moveq	#7,d0
.l2	clr.l	(a0)+
	dbf	d0,.l2

	move.l	patts(a5),a1
	lea	ch(pc),a2
	move.l	s3m(a5),a0
	move	pats(a5),d7
	subq	#1,d7
.pattloop
	moveq	#0,d0
	move	(a1)+,d0
	iword	d0
	lsl.l	#4,d0
	lea	(a0,d0.l),a3
	addq.l	#2,a3
	moveq	#63,d6
.rowloop
	move.b	(a3)+,d0
	beq.b	.newrow

	moveq	#31,d1
	and	d0,d1

	moveq	#32,d2
	and	d0,d2
	beq.b	.nnot

	tst.b	(a3)
	bmi.b	.skip

	tst.b	1(a3)
	bmi.b	.skip

	st	(a2,d1)

.skip	addq.l	#2,a3

.nnot	moveq	#64,d2
	and	d0,d2
	beq.b	.nvol

	addq.l	#1,a3

.nvol	and	#128,d0
	beq.b	.rowloop

	move.b	(a3),d0
	cmp.b	#1,d0
	blo.b	.skip2

	cmp.b	#`Z`-`@`,d0
	bhi.b	.skip2

	st	(a2,d1)

.skip2	addq.l	#2,a3
	bra.b	.rowloop

.newrow
	dbf	d6,.rowloop
	dbf	d7,.pattloop	

	moveq	#1,d0
	moveq	#1,d1
	moveq	#31,d7
	moveq	#0,d5
	moveq	#0,d6
	lea	$40(a0),a1
	lea	pantab(a5),a0
.l	clr.b	(a0)
	tst.b	(a2)+
	beq.b	.d

	move.b	(a1),d2
	bmi.b	.d
	cmp.b	#8,d2
	blo.b	.vas
	move.b	#-1,(a0)
	move	d1,d0
	addq	#1,d5
	bra.b	.d
.vas	move.b	#1,(a0)
	move	d1,d0
	addq	#1,d6
.d	addq.l	#1,a1
	addq.l	#1,a0
	addq	#1,d1
	dbf	d7,.l

	cmp	d5,d6
	bls.b	.k	
	move	d6,d5
.k	move	d5,maxchan(a5)
	
	move	d0,numchans(a5)
ret	rts

ch	ds.b	32


makedivtabs
	cmp	#STEREO14,pmode(a5)
	beq.b	ret

	lea	divtabs(a5),a1
	move.l	dtab(a5),a0

	move	#255,d6
	moveq	#0,d5
	move	maxchan(a5),d5
	move.l	d5,d3
	move.l	d5,d2

	subq	#1,d5
	move	d5,d4
	lsl.l	#7,d5

	lsl.l	#7,d2

	sub.l	vboost(a5),d3
	cmp	#1,d3
	bge.b	.laa
	moveq	#1,d3

.laa	moveq	#0,d0
	move	d6,d7
	move.l	a0,(a1)+
.l	move.l	d0,d1
	add.l	d5,d1
	sub.l	d2,d1
	divs	d3,d1
	cmp	#$7f,d1
	ble.b	.d
	move	#$7f,d1
.d	cmp	#$ff80,d1
	bge.b	.d2
	move	#$80,d1
.d2	move.b	d1,(a0)+
	addq.l	#1,d0
	dbf	d7,.l

	add	#256,d6
	sub.l	#$80,d5
	dbf	d4,.laa
	rts


Makevoltable
	move.l	vtabaddr(a5),a0

	cmp	#STEREO14,pmode(a5)
	beq.b	bit16

	moveq	#0,d3		;volume
	cmp	#1,fformat(a5)
	beq.b	signed

.lop	moveq	#0,d4		;data
.lap	move	d4,d5
	sub	#$80,d5
	mulu	d3,d5
	asr.l	#6,d5
	add	#$80,d5
	move.b	d5,(a0)+
	addq	#1,d4
	cmp	#256,d4
	bne.b	.lap
	addq	#1,d3
	cmp	#65,d3
	bne.b	.lop
	rts

signed
.lop	moveq	#0,d4		;data
.lap	move.b	d4,d5
	ext	d5
	mulu	d3,d5
	asr.l	#6,d5
	add	#$80,d5
	move.b	d5,(a0)+
	addq	#1,d4
	cmp	#256,d4
	bne.b	.lap
	addq	#1,d3
	cmp	#65,d3
	bne.b	.lop
	rts


bit16	move	maxchan(a5),d3
	moveq	#0,d7		; "index"

	cmp	#1,fformat(a5)
	beq.b	signed2

.lop	move	d7,d6
	tst.b	d7
	bmi.b	.above

	and	#127,d6
	move	#128,d5
	sub	d6,d5
	lsl	#8,d5
	move	d7,d6
	lsr	#8,d6
	mulu	d6,d5
	divu	#63,d5
	swap	d5
	clr	d5
	swap	d5
	divu	d3,d5
	neg	d5
	move	d5,(a0)+
	addq	#1,d7
	cmp	#256*65,d7
	bne.b	.lop
	rts

.above	and	#127,d6
	lsl	#8,d6

	move	d7,d5
	lsr	#8,d5
	mulu	d6,d5
	divu	#63,d5
	swap	d5
	clr	d5
	swap	d5
	divu	d3,d5
	move	d5,(a0)+
	addq	#1,d7
	cmp	#256*65,d7
	bne.b	.lop
	rts

signed2
.lop	move	d7,d6
	tst.b	d7
	bpl.b	.above

	and	#127,d6
	move	#128,d5
	sub	d6,d5
	lsl	#8,d5
	move	d7,d6
	lsr	#8,d6
	mulu	d6,d5
	divu	#63,d5
	swap	d5
	clr	d5
	swap	d5
	divu	d3,d5
	neg	d5
	move	d5,(a0)+
	addq	#1,d7
	cmp	#256*65,d7
	bne.b	.lop
	rts

.above	and	#127,d6
	lsl	#8,d6

	move	d7,d5
	lsr	#8,d5
	mulu	d6,d5
	divu	#63,d5
	swap	d5
	clr	d5
	swap	d5
	divu	d3,d5
	move	d5,(a0)+
	addq	#1,d7
	cmp	#256*65,d7
	bne.b	.lop
	rts


do14tab	move.l	buff14(a5),a0
	moveq	#0,d7
.loo	move	d7,d2
	bpl.b	.plus

	neg	d2
	move	d2,d3
	lsr	#8,d2
	neg.b	d2

	lsr.b	#2,d3
	neg	d3

	move.b	d2,(a0)+
	move.b	d3,(a0)+
	addq.l	#2,d7
	cmp.l	#$10000,d7
	bne.b	.loo
	rts

.plus	move	d2,d3
	lsr	#8,d2
	lsr.b	#2,d3
	move.b	d2,(a0)+
	move.b	d3,(a0)+
	addq.l	#2,d7
	cmp.l	#$10000,d7
	bne.b	.loo
	rts




;;********** S3M Play Routine **********


s3m_init
	move.l	s3m(a5),a0
	move.l	a0,mname(a5)
	move	ordernum(a0),d0
	iword	d0
	move	d0,slen(a5)
	move	d0,positioneita(a5)

	move	patnum(a0),d0
	iword	d0
	move	d0,pats(a5)

	move	insnum(a0),d0
	iword	d0
	move	d0,inss(a5)

	move	ffv(a0),d0
	iword	d0
	move	d0,fformat(a5)

	move	flags(a0),d0
	iword	d0
	move	d0,sflags(a5)

	lea	$60(a0),a1
	moveq	#0,d0
	move	slen(a5),d0
	moveq	#1,d1
	and	d0,d1
	add	d1,d0
	lea	(a1,d0.l),a2
	move.l	a2,samples(a5)

	move	inss(a5),d0
	add	d0,d0
	lea	(a2,d0.l),a3
	move.l	a3,patts(a5)

	moveq	#0,d0
	move.b	(a1),d0
	add	d0,d0
	move	(a3,d0),d0
	iword	d0
	asl.l	#4,d0
	lea	2(a0,d0.l),a1
	move.l	a1,ppos(a5)

	moveq	#0,d0
	move.b	initialspeed(a0),d0
	move	d0,spd(a5)

	move.b	initialtempo(a0),d0
	bne.b	.qw
	moveq	#125,d0
.qw	move	d0,tempo(a5)

	clr	pos(a5)
	move	#63,rows(a5)
	clr	cn(a5)

	bsr	detectchannels

	move.l	#14317056/4,clock(a5)		; Clock constant

	moveq	#0,d0
	rts


s3m_music
	lea	data,a5
	move.l	s3m(a5),a0

	addq	#1,cn
	move	cn(a5),d0
	cmp	spd(a5),d0
	beq.b	uusrow

ccmds	lea	c0(a5),a2
	lea	cha0(a5),a4
	move	numchans(a5),d7
	subq	#1,d7
.loo	btst	#7,5(a2)
	beq.b	.edi

	lea	cct(pc),a1
	moveq	#0,d0
	move.b	cmd(a2),d0
	cmp	#`Z`-`@`,d0
	bgt.b	.edi
	add	d0,d0
	move	(a1,d0),d0
	jsr	(a1,d0)

.edi	lea	s3mChanBlock_SIZE(a2),a2
	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.loo
	rts

uusrow	clr	cn

	lea	c0(a5),a2
	move	numchans(a5),d7
	subq	#1,d7
.cl	clr.b	flgs(a2)
	lea	s3mChanBlock_SIZE(a2),a2
	dbf	d7,.cl

	move.l	ppos(a5),a1
	lea	c0(a5),a4		;chanblocks
.loo	move.b	(a1)+,d0
	beq.b	.end

	moveq	#$1f,d5
	and	d0,d5			;chan
	mulu	#s3mChanBlock_SIZE,d5
	lea	(a4,d5),a2

	and	#~31,d0
	move.b	d0,flgs(a2)
	
	moveq	#32,d2
	and	d0,d2
	beq.b	.nnot

	move.b	(a1)+,(a2)
	move.b	(a1)+,inst(a2)

.nnot	moveq	#64,d2
	and	d0,d2
	beq.b	.nvol

	move.b	(a1)+,vol(a2)

.nvol	and	#128,d0
	beq.b	.loo

	move.b	(a1)+,d0
	bmi.b	.d
	move.b	d0,cmd(a2)
.d	move.b	(a1)+,info(a2)
	bra.b	.loo

.end	move.l	a1,ppos

process	lea	c0(a5),a2
	lea	cha0(a5),a4
	move	numchans(a5),d7
	move.l	samples(a5),a5
	subq	#1,d7
	endb	a5
.lloo	tst.b	5(a2)
	beq	.evol

	moveq	#32,d0
	and.b	flgs(a2),d0
	beq	.f

	move.b	inst(a2),d0
	beq	.esmp
	bmi	.esmp

	cmp	inss,d0
	bgt	.mute

	btst	#7,flgs(a2)
	beq.b	.eii
	cmp.b	#`S`-`@`,cmd(a2)
	bne.b	.eii
	move.b	info(a2),d1
	and	#$f0,d1
	cmp	#$d0,d1
	beq	.evol

.eii	add	d0,d0
	move	-2(a5,d0),d0
	iword	d0
	lsl	#4,d0
	lea	(a0,d0),a1

	moveq	#0,d0
	move	insmemseg(a1),d0
	iword	d0
	lsl.l	#4,d0
	move.l	a0,d4
	add.l	d0,d4

	move.l	insloopbeg(a1),d1
	ilword	d1
	move.l	insloopend(a1),d2
	ilword	d2
	sub.l	d1,d2
	add.l	d4,d1

	move.l	d1,mLStart(a4)
	move.l	d2,mLLength(a4)
	move.b	insvol(a1),volume+1(a2)
	cmp	#64,volume(a2)
	blo.b	.e
	move	#63,volume(a2)
.e	move	volume(a2),mVolume(a4)

	move.l	a1,sample(a2)

	btst	#0,insflags(a1)
	beq.b	.eloo
	cmp.l	#2,d2
	bls.b	.eloo
	st	mLoop(a4)
	bra.b	.esmp

.mute	st	mOnOff(a4)
	bra	.f

.eloo	clr.b	mLoop(a4)

.esmp	moveq	#0,d0
	move.b	(a2),d0
	beq	.f
	cmp.b	#254,d0
	beq.b	.mute
	cmp.b	#255,d0
	beq	.f

	move.b	d0,note(a2)
	move	d0,d1
	lsr	#4,d1

	and	#$f,d0
	add	d0,d0

	move.l	sample(a2),a1
	move.l	$20(a1),d2
	ilword	d2

	lea	Periods(pc),a1
	move	(a1,d0),d0
	mulu	#8363,d0
	lsl.l	#4,d0
	lsr.l	d1,d0	

	divu	d2,d0


	btst	#7,flgs(a2)
	beq.b	.ei

	cmp.b	#`Q`-`@`,cmd(a2)	;retrig
	beq.b	.eiik

.ei	clr.b	retrigcn(a2)

.eiik	clr.b	vibpos(a2)


	btst	#7,flgs(a2)
	beq.b	.eitopo

	cmp.b	#`G`-`@`,cmd(a2)	;TOPO
	beq.b	.eddo

	cmp.b	#`L`-`@`,cmd(a2)	;TOPO+VSLD
	bne.b	.eitopo

.eddo	move	d0,toperiod(a2)
	bra.b	.f

.eitopo	move	d0,mPeriod(a4)
	move	d0,period(a2)
	clr.l	mFPos(a4)

	move.l	sample(a2),d0
	beq.b	.f
	move.l	d0,a1

	moveq	#0,d0
	move	insmemseg(a1),d0
	iword	d0
	lsl.l	#4,d0
	move.l	a0,d4
	add.l	d0,d4

	move.l	inslength(a1),d0
	ilword	d0

	move.l	d4,(a4)
	move.l	d0,mLength(a4)
	clr.b	mOnOff(a4)

.f	moveq	#64,d0
	and.b	flgs(a2),d0
	beq.b	.evol
	move.b	vol(a2),volume+1(a2)
	cmp	#64,volume(a2)
	blo.b	.evol
	move	#63,volume(a2)

.evol	btst	#7,flgs(a2)
	beq.b	.eivib

	cmp.b	#`H`-`@`,cmd(a2)
	beq.b	.vib

.eivib	bsr	checklimits
.vib

	btst	#7,flgs(a2)
	beq.b	.eitre

	cmp.b	#`R`-`@`,cmd(a2)
	beq.b	.tre
	cmp.b	#`I`-`@`,cmd(a2)
	beq.b	.tre

.eitre	move	volume(a2),mVolume(a4)

.tre	btst	#7,flgs(a2)
	beq.b	.edd

	move.b	info(a2),d0
	beq.b	.dd
	move.b	d0,lastcmd(a2)
.dd	lea	ct(pc),a1
	moveq	#0,d0
	move.b	cmd(a2),d0
	cmp	#`Z`-`@`,d0
	bgt.b	.edd

	add	d0,d0
	move	(a1,d0),d0
	jsr	(a1,d0)

.edd	lea	s3mChanBlock_SIZE(a2),a2
	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.lloo

	lea	data,a5
	basereg	data,a5

	subq	#1,rows(a5)
	bpl.b	dee

burk	addq	#1,pos(a5)
	move	slen(a5),d0
	cmp	pos(a5),d0
	bgt.b	.ee

.alkd	clr	pos
	st	PS3M_break(a5)
	move.b	initialspeed(a0),spd+1(a5)

.ee	move	pos(a5),d0

	move.l	patts(a5),a3
	moveq	#0,d1
	move.b	$60(a0,d0),d1
	cmp.b	#$fe,d1
	beq.b	burk
	cmp.b	#$ff,d1
	beq.b	burk

	add	d1,d1

	moveq	#0,d0
	move	(a3,d1),d0
	iword	d0
	asl.l	#4,d0
	lea	2(a0,d0.l),a1
	move.l	a1,ppos(a5)

	move	#63,rows(a5)

	move	pos(a5),d0
	move	d0,PS3M_position(a5)
	st	PS3M_poscha(a5)

dee	bra	xm_dee
	endb	a5


ct	dc	rt-ct
	dc	changespeed-ct
	dc	posjmp-ct
	dc	patbrk-ct
	dc	vslide-ct
	dc	portadwn-ct
	dc	portaup-ct
	dc	rt-ct
	dc	rt-ct
	dc	tremor-ct
	dc	arpeggio-ct
	dc	rt-ct
	dc	rt-ct
	dc	rt-ct
	dc	rt-ct
	dc	soffset-ct
	dc	rt-ct
	dc	retrig-ct
	dc	rt-ct
	dc	rt-ct
	dc	stempo-ct
	dc	rt-ct
	dc	setmaster-ct
	dc	rt-ct
	dc	rt-ct
	dc	rt-ct
	dc	rt-ct



cct	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	vslide-cct
	dc	portadwn-cct
	dc	portaup-cct
	dc	noteporta-cct
	dc	vibrato-cct
	dc	tremor-cct
	dc	arpeggio-cct
	dc	vvslide-cct
	dc	pvslide-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	retrig-cct
	dc	tremolo-cct
	dc	specials-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct

tremor
tremolo
rt	rts


changespeed
	move.b	info(a2),d0
	bne.b	.e
	st	PS3M_break
.e	move.b	info(a2),spd+1
	rts

posjmp	clr	rows
	move.b	info(a2),pos+1
	subq	#1,pos
	st	PS3M_poscha
	rts

patbrk	clr	rows
	st	PS3M_poscha
	rts

vslide	moveq	#0,d0
	move.b	lastcmd(a2),d0
	moveq	#$f,d1
	and	d0,d1
	move	d0,d2
	lsr	#4,d2

	cmp.b	#$f,d1
	beq.b	.addfine

	cmp.b	#$f,d2
	beq.b	.subfine
	
	tst	d1
	beq.b	.add
	and	#$f,d0
	bra.b	.sub

.subfine
	tst	cn
	bne.b	.dd
	and	#$f,d0
.sub	sub	d0,volume(a2)
	bpl.b	.dd
	clr	volume(a2)
.dd	move	volume(a2),mVolume(a4)
	rts

.addfine
	tst	d2
	beq.b	.sub
	tst	cn
	bne.b	.dd
.add	lsr	#4,d0

.add2	add	d0,volume(a2)
	cmp	#64,volume(a2)
	blo.b	.dd
	move	#63,volume(a2)
	bra.b	.dd


portadwn
	moveq	#0,d0
	move.b	lastcmd(a2),d0

	tst	cn
	beq.b	.fined
	cmp.b	#$e0,d0
	bhs.b	.dd
	lsl	#2,d0

.ddd	add	d0,period(a2)
	bra.b	checklimits
.dd	rts

.fined	cmp.b	#$e0,d0
	bls.b	.dd
	cmp.b	#$f0,d0
	bls.b	.extr
	and	#$f,d0
	lsl	#2,d0
	bra.b	.ddd

.extr	and	#$f,d0
	bra.b	.ddd

portaup
	moveq	#0,d0
	move.b	lastcmd(a2),d0

	tst	cn
	beq.b	.fined
	cmp.b	#$e0,d0
	bhs.b	.dd
	lsl	#2,d0

.ddd	sub	d0,period(a2)
	bra.b	checklimits

.dd	rts

.fined	cmp.b	#$e0,d0
	bls.b	.dd
	cmp.b	#$f0,d0
	bls.b	.extr
	and	#$f,d0
	lsl	#2,d0
	bra.b	.ddd

.extr	and	#$f,d0
	bra.b	.ddd


checklimits
	move	period(a2),d0
	btst	#4,sflags+1
	beq.b	.sii
	
	cmp	#856*4,d0
	bls.b	.dd
	move	#856*4,d0
.dd	cmp	#113*4,d0
	bhs.b	.dd2
	move	#113*4,d0
.dd2	move	d0,period(a2)
	move	d0,mPeriod(a4)
	rts

.sii	cmp	#$7fff,d0
	bls.b	.dd3
	move	#$7fff,d0
.dd3	cmp	#64,d0
	bhs.b	.dd4
	move	#64,d0
.dd4	move	d0,mPeriod(a4)
	rts


noteporta
	move.b	info(a2),d0
	beq.b	notchange
	move.b	d0,notepspd(a2)
notchange
	move	toperiod(a2),d0
	beq.b	.1
	moveq	#0,d1
	move.b	notepspd(a2),d1
	lsl	#2,d1

	cmp	period(a2),d0
	blt.b	.topoup

	add	d1,period(a2)
	cmp	period(a2),d0
	bgt.b	.1
	move	d0,period(a2)
	clr	toperiod(a2)
.1	move	period(a2),mPeriod(a4)
	rts

.topoup	sub	d1,period(a2)
	cmp	period(a2),d0
	blt.b	.dd
	move	d0,period(a2)
	clr	toperiod(a2)
.dd	move	period(a2),mPeriod(a4)
	rts


vibrato	move.b	cmd(a2),d0
	bne.b	.e
	move.b	vibcmd(a2),d0
	bra.b	vibskip2

.e	move	d0,d1
	and	#$f0,d1
	bne.b	vibskip2

	move.b	vibcmd(a2),d1
	and	#$f0,d1
	or	d1,d0

vibskip2
	move.b	d0,vibcmd(a2)

vibrato2
	moveq	#$1f,d0
	and.b	vibpos(a2),d0
	moveq	#0,d2
	lea	mt_vibratotable(pc),a3
	move.b	(a3,d0),d2
	moveq	#$f,d0
	and.b	vibcmd(a2),d0
	mulu	d0,d2

	moveq	#4,d0
	btst	#0,sflags+1
	bne.b	.sii
	moveq	#5,d0
.sii	lsr	d0,d2
	move	period(a2),d0
	btst	#5,vibpos(a2)
	bne.b	.neg
	add	d2,d0
	bra.b	.vib3
.neg
	sub	d2,d0
.vib3
	move	d0,mPeriod(a4)
	move.b	vibcmd(a2),d0
	lsr.b	#4,d0
	add.b	d0,vibpos(a2)
	rts


arpeggio
	moveq	#0,d0
	move.b	note(a2),d0
	beq.b	.qq

	moveq	#$70,d1
	and	d0,d1
	and	#$f,d0

	moveq	#0,d2
	move	cn,d2
	divu	#3,d2
	swap	d2
	tst	d2
	beq.b	.norm
	subq	#1,d2
	beq.b	.1

	moveq	#$f,d2
	and.b	lastcmd(a2),d2
	add	d2,d0
.f	cmp	#12,d0
	blt.b	.norm
	sub	#12,d0
	add	#$10,d1
	bra.b	.f

.1	move.b	lastcmd(a2),d2
	lsr.b	#4,d2
	add.b	d2,d0
.f2	cmp	#12,d0
	blt.b	.norm
	sub	#12,d0
	add	#$10,d1
	bra.b	.f2

.norm	add	d0,d0
	lsr	#4,d1

	move.l	sample(a2),a1

	move.l	$20(a1),d2
	ilword	d2

	lea	Periods(pc),a1
	move	(a1,d0),d0
	mulu	#8363,d0
	lsl.l	#4,d0
	lsr.l	d1,d0
	divu	d2,d0
	move	d0,mPeriod(a4)
.qq	rts


pvslide	bsr	notchange
	bra	vslide

vvslide	bsr	vibrato2
	bra	vslide

soffset	move.l	(a4),d0
	move.l	mLength(a4),d1
	moveq	#0,d2
	move.b	lastcmd(a2),d2
	lsl.l	#8,d2
	add.l	d2,d0
	sub.l	d2,d1
	bpl.b	.ok
	move.l	mLStart(a4),d0
	move.l	mLLength(a4),d1
.ok	move.l	d0,(a4)
	move.l	d1,mLength(a4)
	rts


retrig	move.b	retrigcn(a2),d0
	subq.b	#1,d0
	cmp.b	#0,d0
	ble.b	.retrig

	move.b	d0,retrigcn(a2)
	rts

.retrig
	move.l	sample(a2),a1
	moveq	#0,d1
	move	insmemseg(a1),d1
	iword	d1
	lsl.l	#4,d1
	move.l	a0,d4
	add.l	d1,d4

	move.l	inslength(a1),d1
	ilword	d1

	move.l	d4,(a4)
	move.l	d1,mLength(a4)
	clr.b	mOnOff(a4)
	clr.l	mFPos(a4)

	move.b	lastcmd(a2),d0
	moveq	#$f,d1
	and.b	d0,d1
	and	#$f0,d0
	move.b	d1,retrigcn(a2)

	lsr	#4,d0
	moveq	#0,d2
	lea	ftab2(pc),a3
	move.b	(a3,d0),d2
	beq.b	.ddq

	mulu	volume(a2),d2
	lsr	#4,d2
	move	d2,volume+1(a2)
	bra.b	.ddw

.ddq	lea	ftab1(pc),a3
	move.b	(a3,d0),d2
	ext	d2
	add	d2,volume(a2)

.ddw	tst	volume(a2)
	bpl.b	.ei0
	clr	volume(a2)
.ei0	cmp	#64,volume+1(a2)
	blo.b	.ei64
	move	#63,volume(a2)
.ei64	move	volume(a2),mVolume(a4)
	rts

specials
ncut_delay
	move.b	info(a2),d0
	and	#$f0,d0
	cmp	#$d0,d0
	beq.b	.delay
	cmp	#$c0,d0
	bne.b	.dd

	move.b	info(a2),d0
	and	#$f,d0
	cmp	cn,d0
	bne.b	.dd
	clr	volume(a2)
	clr	mVolume(a4)
.dd	rts

.delay	move.b	info(a2),d0
	and	#$f,d0
	cmp	cn,d0
	bne.b	.dd
	
	moveq	#32,d0
	and.b	flgs(a2),d0
	beq	.f

	move.b	inst(a2),d0
	beq	.esmp
	bmi	.esmp

	cmp	inss,d0
	bgt.b	.dd

	move.l	samples,a5
	add	d0,d0
	move	-2(a5,d0),d0
	iword	d0
	asl	#4,d0
	lea	(a0,d0),a1

	moveq	#0,d0
	move	insmemseg(a1),d0
	iword	d0
	asl.l	#4,d0
	move.l	a0,d4
	add.l	d0,d4

	move.l	insloopbeg(a1),d1
	ilword	d1
	move.l	insloopend(a1),d2
	ilword	d2
	sub.l	d1,d2
	add.l	d4,d1

	move.l	inslength(a1),d0
	ilword	d0

	move.l	d4,(a4)
	move.l	d0,mLength(a4)
	move.l	d1,mLStart(a4)
	move.l	d2,mLLength(a4)
	move.b	insvol(a1),volume+1(a2)
	cmp	#64,volume(a2)
	blo.b	.e
	move	#63,volume(a2)
.e	move	volume(a2),mVolume(a4)
	clr.b	mOnOff(a4)

	move.l	a1,sample(a2)

	btst	#0,insflags(a1)
	beq.b	.eloo
	cmp.l	#2,d2
	bls.b	.eloo
	st	mLoop(a4)
	bra.b	.esmp
.eloo	clr.b	mLoop(a4)

.esmp	moveq	#0,d0
	move.b	(a2),d0
	beq.b	.f
	bmi.b	.f

	moveq	#$70,d1
	and	d0,d1
	lsr	#4,d1

	and	#$f,d0
	add	d0,d0

	move.l	sample(a2),a1

	move.l	$20(a1),d2
	ilword	d2

	lea	Periods(pc),a1
	move	(a1,d0),d0
	mulu	#8363,d0
	lsl.l	#4,d0
	lsr.l	d1,d0
	divu	d2,d0

	move	d0,mPeriod(a4)
	move	d0,period(a2)
	clr.l	mFPos(a4)
	clr.b	vibpos(a2)

.f	moveq	#64,d0
	and.b	flgs(a2),d0
	beq.b	.evol
	move.b	vol(a2),volume+1(a2)
	cmp	#64,volume(a2)
	blo.b	.evol
	move	#63,volume(a2)
.evol
	move	volume(a2),mVolume(a4)
	rts


stempo	moveq	#0,d0
	move.b	info(a2),d0
	beq.b	.e
	move.l	mrate,d1
	move.l	d1,d2
	lsl.l	#2,d1
	add.l	d2,d1
	add	d0,d0
	divu	d0,d1

	addq	#1,d1
	and	#~1,d1
	move	d1,bytesperframe
.e	rts

setmaster
	moveq	#0,d0
	move.b	info(a2),d0
	cmp	#64,d0
	bls.b	.d
	moveq	#64,d0
.d	move	d0,PS3M_master

	mulu	#-1,d0
	divu	#64,d0
	move	d0,d1

	moveq	#-1,d0
	clr	d0
	swap	d0
	divu	#65,d0
	move	d0,d3

	movem.l	a0-a2/a6,-(sp)
	lea	gvolume,a0
	move.l	winpoin,a1
	sub.l	a2,a2

	moveq	#AUTOKNOB!FREEHORIZ!PROPBORDERLESS!PROPNEWLOOK,d0
	moveq	#0,d2
	moveq	#-1,d4
	moveq	#1,d5
	CLIB	Int,NewModifyProp

	lea	gvolume,a0
	move.l	winpoin,a1
	moveq	#1,d0
	CALL	RefreshGList

	movem.l	(sp)+,a0-a2/a6
	rts

Periods
 dc	1712,1616,1524,1440,1356,1280,1208,1140,1076,1016,960,907

ftab1	dc.b	0,-1,-2,-4,-8,-16,0,0
	dc.b	0,1,2,4,8,16,0,0

ftab2	dc.b	0,0,0,0,0,0,10,8
	dc.b	0,0,0,0,0,0,24,32

********** Fasttracker ][ XM player **************

	basereg	data,a5

xm_init	move.l	s3m(a5),a0
	lea	xmName(a0),a1
	move.l	a1,mname(a5)

	lea	xmNum1A(a0),a2
	moveq	#18,d0
.t	cmp.b	#` `,-(a2)
	bne.b	.x
	dbf	d0,.t
.x	clr.b	1(a2)

	move	xmSpeed(a0),d0
	iword	d0
	move	d0,spd(a5)

	move	xmTempo(a0),d0
	iword	d0
	move	d0,tempo(a5)

	move	xmFlags(a0),d0
	iword	d0
;	clr	sflags(a5)			; force to use Amiga-freq.
	move	d0,sflags(a5)

	tst	PS3M_reinit(a5)
	bne	xm_skipinit

	move	xmSongLength(a0),d0
	iword	d0
	move	d0,slen(a5)
	move	d0,positioneita(a5)

	moveq	#0,d0
	move.b	xmNumChans(a0),d0
	move	d0,numchans(a5)
	addq	#1,d0
	lsr	#1,d0
	move	d0,maxchan(a5)			;!!!

	lea	xmHdrSize(a0),a1
	move.l	(a1),d0
	ilword	d0
	add.l	d0,a1
	lea	xm_patts,a2
	move	xmNumPatts(a0),d7
	iword	d7
	subq	#1,d7
.pattloop
	move.l	a1,(a2)+
	move.l	a1,a3				; xmPattHdrSize
	tlword	(a3)+,d0
	lea	xmPattDataSize(a1),a3
	add.l	d0,a1
	moveq	#0,d0
	tword	(a3)+,d0
	add.l	d0,a1
	dbf	d7,.pattloop

	lea	xm_insts,a2
	move	xmNumInsts(a0),d7
	iword	d7
	subq	#1,d7
.instloop
	moveq	#0,d5				; instlength
	move.l	a1,(a2)+
	move.l	a1,a3				; xmInstSize
	tlword	(a3)+,d0
	lea	xmNumSamples(a1),a3
	tword	(a3)+,d1
	lea	xmSmpHdrSize(a1),a3
	add.l	d0,a1
	tst	d1
	beq	.q
	tlword	(a3)+,d2			; xmSmpHdrSize
	move	d2,d6
	mulu	d1,d6
	lea	(a1,d6.l),a4			; sample start
	subq	#1,d1
.l	move.l	a1,a3				; xmSmpLength
	tlword	(a3)+,d0
	tst.l	d0
	beq.b	.e
	add.l	d0,d5

	btst	#xm16bitf,xmSmpFlags(a1)
	beq.b	.bit8

; Dedelta the samples

.bit16	moveq	#0,d4
	move.l	a4,a6
.l3	move.b	(a4)+,d3
	move.b	(a4)+,d6
	lsl	#8,d6
	move.b	d3,d6
	add	d4,d6
	move	d6,d4
	lsr	#8,d6
	eor.b	#$80,d6
	move.b	d6,(a6)+
	subq.l	#2,d0
	bne.b	.l3
	bra.b	.e

.bit8	moveq	#0,d4
.l2	add.b	(a4),d4
	eor.b	#$80,d4
	move.b	d4,(a4)+
	subq.l	#1,d0
	bne.b	.l2

.e	add.l	d2,a1
	dbf	d1,.l

	add.l	d5,a1

.q	dbf	d7,.instloop


xm_skipinit
	clr	pos(a5)
	clr	rows(a5)
	clr	cn(a5)
	move	#64,globalVol(a5)

	lea	pantab(a5),a1
	move.l	a1,a2
	moveq	#7,d0
.l9	clr.l	(a2)+
	dbf	d0,.l9

	move	numchans(a5),d0
	subq	#1,d0
	moveq	#0,d1
.lop	tst	d1
	beq.b	.vas
	cmp	#3,d1
	beq.b	.vas
.oik	move.b	#-1,(a1)+
	bra.b	.je
.vas	move.b	#1,(a1)+
.je	addq	#1,d1
	and	#3,d1
	dbf	d0,.lop

	move.l	#8363*1712/4,clock(a5)		; Clock constant
	move	#1,fformat(a5)			; signed samples

	moveq	#0,d1
	move.b	xmOrders(a0),d1
	lsl.l	#2,d1
	lea	xm_patts,a1
	move.l	(a1,d1),a1

	lea	xmNumRows(a1),a3
	tword	(a3)+,d0
	move	d0,plen(a5)
	move.l	a1,a3
	tlword	(a3)+,d0
	add.l	d0,a1
	move.l	a1,ppos(a5)

	st	PS3M_reinit(a5)
	moveq	#0,d0
	rts


xm_music
	lea	data,a5
	move.l	s3m(a5),a0
	pea	xm_runEnvelopes(pc)

	addq	#1,cn(a5)
	move	cn(a5),d0
	cmp	spd(a5),d0
	beq	xm_newrow

xm_ccmds
	lea	c0(a5),a2
	lea	cha0(a5),a4
	move	numchans(a5),d7
	subq	#1,d7

.loo	moveq	#0,d0
	move.b	vol(a2),d0
	cmp.b	#$60,d0
	blo.b	.eivol

	lea	xm_cvct(pc),a1
	moveq	#$f,d1
	and	d0,d1
	move	d1,d2
	lsr	#4,d0
	subq	#6,d0
	add	d0,d0
	move	(a1,d0),d0
	jsr	(a1,d0)

.eivol	lea	xm_cct(pc),a1
	moveq	#0,d0
	move.b	cmd(a2),d0
	cmp.b	#$20,d0
	bhi.b	.edi
	moveq	#0,d1
	move.b	info(a2),d1
	beq.b	.zero
	move.b	d1,lastcmd(a2)
.zero	moveq	#0,d2
	move.b	lastcmd(a2),d2
	add	d0,d0
	move	(a1,d0),d0
	jsr	(a1,d0)

.edi	lea	s3mChanBlock_SIZE(a2),a2
	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.loo
	rts


xm_runEnvelopes
	lea	c0(a5),a2
	lea	cha0(a5),a4
	move	numchans(a5),d7
	subq	#1,d7
.envloop
	move.l	sample(a2),d1
	beq	.skip

	move.l	d1,a1	

	move	rVolume(a2),d0

	tst.b	fading(a2)
	beq.b	.sk

	mulu	fadeOut(a2),d0
	swap	d0

	tst	fadeOut(a2)
	beq.b	.sk

	lea	xmVolFadeout(a1),a3
	moveq	#0,d1
	tword	(a3)+,d1
	moveq	#0,d2
	move	fadeOut(a2),d2
	sub.l	d1,d2
	bpl.b	.ok
	moveq	#0,d2
.ok	move	d2,fadeOut(a2)
.sk	cmp	#64,globalVol(a5)
	beq.b	.skipglobal

	mulu	globalVol(a5),d0
	lsr	#6,d0

.skipglobal
	tst.b	volEnvOn(a2)
	beq	.skipenv

	tst.b	volSustained(a2)
	bne	.sust

	tst.b	volRecalc(a2)
	beq.b	.cont

	btst	#xmEnvSustain,xmVolType(a1)
	beq.b	.nsus
	move.b	xmVolSustain(a1),d3
	cmp.b	volCurPnt(a2),d3
	bne.b	.nsus
	tst.b	keyoff(a2)
	bne.b	.nsus
	st	volSustained(a2)

.nsus	moveq	#0,d1
	move.b	volCurPnt(a2),d1
	lsl	#2,d1
	lea	xmVolEnv(a1),a3
	add.l	d1,a3
	moveq	#0,d2
	tword	(a3)+,d1			; Envelope X
	tword	(a3)+,d2			; Envelope Y

	moveq	#0,d3
	tword	(a3)+,d4			; To X
	tword	(a3)+,d3			; To Y

	sub.l	d2,d3
	asl.l	#8,d3
	sub	d1,d4
	beq.b	.hups
	divs	d4,d3
.hups	move	d3,volEnvDelta(a2)

	move	d1,volEnvX(a2)
	lsl	#8,d2
	move	d2,volEnvY(a2)

	addq.b	#1,volCurPnt(a2)
	clr.b	volRecalc(a2)
	bra.b	.juuh


.cont	addq	#1,volEnvX(a2)
	move	volEnvY(a2),d2
	add	volEnvDelta(a2),d2
	move	d2,volEnvY(a2)
.juuh	asr	#8,d2
	bpl.b	.jupo
	moveq	#0,d2
.jupo	cmp	#64,d2
	bls.b	.oko
	moveq	#64,d2
.oko	mulu	d2,d0
	lsr	#6,d0

	move	volEnvX(a2),d2
	moveq	#0,d1
	move.b	volCurPnt(a2),d1
	lsl	#2,d1
	lea	xmVolEnv(a1),a3
	add.l	d1,a3
	tword	(a3)+,d1			; Envelope X
	cmp	d1,d2
	blo.b	.skipenv

.kaa	st	volRecalc(a2)

	btst	#xmEnvSustain,xmVolType(a1)
	beq.b	.nosust

	move.b	xmVolSustain(a1),d3
	cmp.b	volCurPnt(a2),d3
	bne.b	.nosust
	tst.b	keyoff(a2)
	bne.b	.nosust
	st	volSustained(a2)
	bra.b	.skipenv

.nosust	btst	#xmEnvLoop,xmVolType(a1)
	beq.b	.noloop

	move.b	xmVolLoopEnd(a1),d3
	cmp.b	volCurPnt(a2),d3
	bne.b	.noloop

	move.b	xmVolLoopStart(a1),volCurPnt(a2)
	bra.b	.skipenv

.noloop	move.b	xmNumVolPnts(a1),d3
	subq.b	#1,d3
	cmp.b	volCurPnt(a2),d3
	bne.b	.skipenv
	st.b	volSustained(a2)
	bra.b	.skipenv

.sust	move	volEnvY(a2),d2
	asr	#8,d2
	bpl.b	.jupi
	moveq	#0,d2
.jupi	cmp	#64,d2
	bls.b	.okk
	moveq	#64,d2
.okk	mulu	d2,d0
	lsr	#6,d0
.skipenv
	move	d0,mVolume(a4)

.skip	btst	#0,sflags+1(a5)
	beq.b	.amigaperiods

	moveq	#0,d0
	move	rPeriod(a2),d0
	divu	#768,d0
	move	d0,d1
	swap	d0
	lsl	#2,d0
	lea	xm_linFreq(pc),a0
	move.l	(a0,d0),d0
	lsr.l	d1,d0
	move.l	d0,d1
	move.l	#8363*1712,d0
	bsr	divu_32

	move	d0,mPeriod(a4)
	bra.b	.k


.amigaperiods
	move	rPeriod(a2),mPeriod(a4)

.k	lea	s3mChanBlock_SIZE(a2),a2
	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.envloop
	rts


xm_newrow
	clr	cn(a5)

	tst.b	pdelaycnt(a5)
	bne.b	.process

	move.l	ppos(a5),a1
	lea	c0(a5),a2		;chanblocks
	move	numchans(a5),d7
	subq	#1,d7
.loo	move.b	(a1)+,d0
	bpl.b	.all

	clr.l	(a2)
	clr.b	info(a2)

	btst	#0,d0
	beq.b	.nonote
	move.b	(a1)+,(a2)
.nonote	btst	#1,d0
	beq.b	.noinst
	move.b	(a1)+,inst(a2)
.noinst	btst	#2,d0
	beq.b	.novol
	move.b	(a1)+,vol(a2)
.novol	btst	#3,d0
	beq.b	.nocmd
	move.b	(a1)+,cmd(a2)
.nocmd	btst	#4,d0
	beq.b	.next
	move.b	(a1)+,info(a2)
	bra.b	.next
	
.all	move.b	d0,(a2)
	move.b	(a1)+,inst(a2)
	move.b	(a1)+,vol(a2)
	move.b	(a1)+,cmd(a2)
	move.b	(a1)+,info(a2)

.next	lea	s3mChanBlock_SIZE(a2),a2
	dbf	d7,.loo
	move.l	a1,ppos(a5)

.process
	lea	c0(a5),a2
	lea	cha0(a5),a4
	move	numchans(a5),d7
	subq	#1,d7
.channelloop
	tst.b	pdelaycnt(a5)
	bne	.skip

	tst	(a2)
	beq	.skip

	moveq	#0,d0
	move.b	(a2),d0
	bne.b	.note
	move.b	note(a2),d0
.note	move.b	d0,note(a2)

	moveq	#0,d1
	move.b	inst(a2),d1
	beq.b	.esmp

	lsl	#2,d1
	lea	xm_insts,a1
	move.l	-4(a1,d1),a1

	move.l	a1,sample(a2)
	bra.b	.ju
.esmp	move.l	sample(a2),d2
	beq	.skip
	move.l	d2,a1

.ju	moveq	#$f,d1
	and.b	cmd(a2),d1
	cmp	#$e,d1
	bne.b	.s
	move.b	info(a2),d1
	and	#$f0,d1
	cmp	#$d0,d1
	beq	.skip

.s	bsr	xm_getInst

	tst.b	inst(a2)
	beq.b	.smpok
	tst.b	(a2)
	beq.b	.smpok

	lea	xmLoopStart(a1),a3
	tlword	(a3)+,d1
	lea	xmLoopLength(a1),a3
	tlword	(a3)+,d2

	btst	#xm16bitf,xmSmpFlags(a1)
	beq.b	.bit8
	lsr.l	#1,d1
	lsr.l	#1,d2
.bit8	add.l	a6,d1

	move.l	d1,mLStart(a4)
	move.l	d2,mLLength(a4)
	move.b	xmVolume(a1),volume+1(a2)
	cmp	#64,volume(a2)
	bls.b	.e
	move	#64,volume(a2)
.e	move	volume(a2),rVolume(a2)

	moveq	#xmLoopType,d1
	and.b	xmSmpFlags(a1),d1
	beq.b	.eloo
	st	mLoop(a4)
	bra.b	.smpok

.eloo	clr.b	mLoop(a4)

.smpok	tst.b	(a2)
	beq	.skip

	cmp.b	#97,(a2)			; Key off -note
	beq	.keyoff

	bsr	xm_getPeriod

; Handle envelopes
	move	#$ffff,fadeOut(a2)
	clr.b	fading(a2)
	clr.b	keyoff(a2)

	move.l	sample(a2),d2
	beq	.skip
	move.l	d2,a3

	btst	#xmEnvOn,xmVolType(a3)
	beq.b	.voloff

	st	volEnvOn(a2)
	clr.b	volCurPnt(a2)
	st	volRecalc(a2)
	clr.b	volSustained(a2)
	bra.b	.jep

.voloff	clr.b	volEnvOn(a2)


.jep	btst	#xmEnvOn,xmPanType(a3)
	beq.b	.panoff

	st	panEnvOn(a2)
	clr.b	panCurPnt(a2)
	st	panRecalc(a2)
	clr.b	panSustained(a2)
	bra.b	.jep2

.panoff	clr.b	panEnvOn(a2)

.jep2	cmp.b	#3,cmd(a2)
	beq	.tonep
	cmp.b	#5,cmd(a2)
	beq	.tonep

	move	d0,rPeriod(a2)
	move	d0,period(a2)
	clr.l	mFPos(a4)

	move.l	a1,a3
	tlword	(a3)+,d0			; sample length

	cmp.b	#9,cmd(a2)
	bne.b	.nooffset

	moveq	#0,d1
	move.b	info(a2),d1
	bne.b	.ok3
	move.b	lastOffset(a2),d1
.ok3	move.b	d1,lastOffset(a2)
	lsl	#8,d1
	add.l	d1,a6
	sub.l	d1,d0
	bpl.b	.nooffset
	st	mOnOff(a4)
	bra.b	.skip

.nooffset
	move.l	a6,(a4)				; sample start
	btst	#xm16bitf,xmSmpFlags(a1)
	beq.b	.bit8_2
	lsr.l	#1,d0
.bit8_2	move.l	d0,mLength(a4)
	clr.b	mOnOff(a4)
	bra.b	.skip

.keyoff	
	tst.b	volEnvOn(a2)
	beq.b	.vol0

	clr.b	volSustained(a2)
	st	fading(a2)
	st	keyoff(a2)
	bra.b	.skip

.vol0	tst.b	inst(a2)
	bne.b	.skip
	clr	volume(a2)
	bra.b	.skip

.tonep	move	d0,toperiod(a2)

.skip	moveq	#0,d0
	move.b	vol(a2),d0
	cmp.b	#$10,d0
	blo.b	.eivol

	cmp.b	#$50,d0
	bhi.b	.volcmd

	sub	#$10,d0
	move	d0,volume(a2)
	bra.b	.eivol

.volcmd	cmp.b	#$60,d0
	blo.b	.eivol

	lea	xm_vct(pc),a1
	moveq	#$f,d1
	and	d0,d1
	move	d1,d2
	lsr	#4,d0
	subq	#6,d0
	add	d0,d0
	move	(a1,d0),d0
	jsr	(a1,d0)

.eivol	lea	xm_ct(pc),a1
	moveq	#0,d0
	move.b	cmd(a2),d0
	cmp.b	#$20,d0
	bhs.b	.skipa
	moveq	#0,d1
	move.b	info(a2),d1
	beq.b	.zero
	move.b	d1,lastcmd(a2)

.zero	moveq	#0,d2
	move.b	lastcmd(a2),d2

	ifne	debug
	move.l	kalas(a5),a3
	st	(a3,d0)
	endc

	add	d0,d0
	move	(a1,d0),d0
	jsr	(a1,d0)

.skipa	move	volume(a2),rVolume(a2)
	move	period(a2),rPeriod(a2)

	lea	s3mChanBlock_SIZE(a2),a2
	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.channelloop

	tst.b	pdelaycnt(a5)
	beq.b	.oke

	subq.b	#1,pdelaycnt(a5)
	bra	xm_exit

.oke	tst	pbflag(a5)
	bne.b	.break

	addq	#1,rows(a5)
	move	plen(a5),d0
	cmp	rows(a5),d0
	bhi.b	xm_dee

	addq	#1,pos(a5)
	clr	rows(a5)

.break	move	slen(a5),d0
	cmp	pos(a5),d0
	bhi.b	.ee

	move	xmRestart(a0),d0
	iword	d0
	move	d0,pos(a5)
	st	PS3M_break(a5)

.ee	move	pos(a5),d0
	move	d0,PS3M_position(a5)
	st	PS3M_poscha(a5)

	moveq	#0,d1
	move.b	xmOrders(a0,d0),d1	

	lsl	#2,d1

	lea	xm_patts,a1
	move.l	(a1,d1),a1
	lea	xmNumRows(a1),a3
	tword	(a3)+,d0
	move	d0,plen(a5)
	move.l	a1,a3
	tlword	(a3)+,d0
	add.l	d0,a1
	move.l	a1,ppos(a5)
	clr	pbflag(a5)

xm_dee	lea	c0(a5),a2
	lea	cha0(a5),a4
	move	numchans(a5),d7
	subq	#1,d7

.luu	tst	volume(a2)
	bne.b	.noaging

	cmp.b	#8,age(a2)
	bhs.b	.stop
	addq.b	#1,age(a2)
	bra.b	.nextt
.stop	st	mOnOff(a4)
	bra.b	.nextt
.noaging
	clr.b	age(a2)

.nextt	lea	s3mChanBlock_SIZE(a2),a2
	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.luu
xm_exit	rts

xm_ret	rts


; COMMANDS!


xm_getInst
	moveq	#0,d6
	move.b	xmSmpNoteNums-1(a1,d0),d6	; sample number
	lea	xmNumSamples(a1),a3
	tword	(a3)+,d2
	lea	xmSmpHdrSize(a1),a3
	tlword	(a3)+,d3
	move.l	a1,a3				; InstHdrSize
	tlword	(a3)+,d1
	add.l	d1,a1				; Now at the first sample!

	move.l	d3,d4
	mulu	d2,d4
	lea	(a1,d4),a6

	tst	d6
	beq.b	.rightsample

.skiploop
	lea	xmSmpLength(a1),a3
	tlword	(a3)+,d4
	add.l	d4,a6
	add.l	d3,a1
	subq	#1,d6
	bne.b	.skiploop

.rightsample
	rts



xm_getPeriod
	move.b	xmRelNote(a1),d1
	ext	d1
	add	d1,d0
	bpl.b	.ok
	moveq	#0,d0
.ok	cmp	#118,d0
	bls.b	.ok2
	moveq	#118,d0
.ok2	move.b	xmFinetune(a1),d1
	ext.l	d0
	ext	d1

	btst	#0,sflags+1(a5)
	beq.b	.amigafreq

	move	#121*64,d2
	lsl	#6,d0
	sub	d0,d2
	asr	d1
	sub	d1,d2
	move	d2,d0
	rts

.amigafreq
	divu	#12,d0
	swap	d0
	move	d0,d2				; note
	clr	d0
	swap	d0				; octave
	lsl	#3,d2

	move	d1,d3
	asr	#4,d3
	move	d2,d4
	add	d3,d4

	add	d4,d4
	lea	xm_periods(pc),a3
	moveq	#0,d5
	move	(a3,d4),d5

	tst	d1
	bpl.b	.k
	subq	#1,d3
	neg	d1
	bra.b	.k2
.k	addq	#1,d3
.k2	move	d2,d4
	add	d3,d4
	add	d4,d4
	moveq	#0,d6
	move	(a3,d4),d6

	and	#$f,d1
	mulu	d1,d6
	move	#16,d3
	sub	d1,d3
	mulu	d3,d5
	add.l	d6,d5

	subq	#1,d0
	bmi.b	.f2
	lsr.l	d0,d5
	bra.b	.d

.f2	add.l	d5,d5
.d	move	d5,d0
	rts


; Command 0 - Arpeggio

xm_arpeggio
	tst.b	info(a2)
	beq.b	.skip

	moveq	#0,d0
	move.b	note(a2),d0
	beq.b	.skip

	move.l	sample(a2),d2
	beq.b	.skip
	move.l	d2,a1

	bsr	xm_getInst

	moveq	#0,d2
	move	cn(a5),d2
	divu	#3,d2
	swap	d2
	tst	d2
	beq.b	.f
	subq	#1,d2
	beq.b	.1

.2	moveq	#$f,d2
	and.b	lastcmd(a2),d2
	add	d2,d0
	bra.b	.f

.1	move.b	lastcmd(a2),d2
	lsr.b	#4,d2
	add.b	d2,d0

.f	bsr	xm_getPeriod
	move	d0,mPeriod(a4)
.skip	rts



; Command 1 - Portamento up
; Also command E1 - fine portamento up
; and command X1 - extra fine portamento up

xm_slideup
	lsl	#2,d2
xm_xslideup
	sub	d2,period(a2)
	bra.b	xm_checklimits


; Command 2 - Portamento down
; Also command E2 - fine portamento down
; and command X2 - extra fine portamento down

xm_slidedwn
	lsl	#2,d2
xm_xslidedwn
	add	d2,period(a2)

xm_checklimits
	move	period(a2),d0
	btst	#0,sflags+1(a5)
	beq.b	.amiga

	cmp	#2*64,d0
	bhs.b	.ok
	move	#2*64,d0
.ok	cmp	#121*64,d0
	bls.b	.dd2
	move	#121*64,d0
	bra.b	.dd2

.amiga	cmp	#$7fff,d0
	bls.b	.dd
	move	#$7fff,d0
.dd	cmp	#64,d0
	bhs.b	.dd2
	move	#64,d0
.dd2	move	d0,period(a2)
	move	d0,rPeriod(a2)
	rts


; Command 3 - Tone portamento

xm_tonep
	tst	d1
	beq.b	xm_tonepnoch
	move.b	d1,notepspd(a2)
xm_tonepnoch
	move	toperiod(a2),d0
	beq.b	.1
	moveq	#0,d1
	move.b	notepspd(a2),d1
	lsl	#2,d1

	cmp	period(a2),d0
	blt.b	.topoup

	add	d1,period(a2)
	cmp	period(a2),d0
	bhi.b	.1
	move	d0,period(a2)
	clr	toperiod(a2)
.1	move	period(a2),rPeriod(a2)
	rts

.topoup	sub	d1,period(a2)
	cmp	period(a2),d0
	blt.b	.dd
	move	d0,period(a2)
	clr	toperiod(a2)
.dd	move	period(a2),rPeriod(a2)
	rts


; Command 4 - Vibrato

xm_svibspd
	move.b	vibcmd(a2),d2
	moveq	#$f,d0
	and	d1,d0
	beq.b	.skip
	and	#$f0,d2
	or	d0,d2
.skip	move.b	d2,vibcmd(a2)
	rts

xm_vibrato
	move.b	vibcmd(a2),d2
	move	d1,d0
	and	#$f0,d0
	beq.b	.vib2

	and	#$f,d2
	or	d0,d2

.vib2	moveq	#$f,d0
	and	d1,d0
	beq.b	.vibskip2

	and	#$f0,d2
	or	d0,d2
.vibskip2
	move.b	d2,vibcmd(a2)

xm_vibrato2
	moveq	#$1f,d0
	and.b	vibpos(a2),d0
	moveq	#0,d2
	lea	mt_vibratotable(pc),a3
	move.b	(a3,d0),d2
	moveq	#$f,d0
	and.b	vibcmd(a2),d0
	mulu	d0,d2
	lsr	#5,d2

	move	period(a2),d0
	btst	#5,vibpos(a2)
	bne.b	.neg
	add	d2,d0
	bra.b	.vib3
.neg
	sub	d2,d0
.vib3
	move	d0,mPeriod(a4)
	move.b	vibcmd(a2),d0
	lsr.b	#4,d0
	add.b	d0,vibpos(a2)
	rts

; Command 5 - Tone portamento and volume slide

xm_tpvsl
	bsr	xm_tonepnoch
	bra.b	xm_vslide

; Command 6 - Vibrato and volume slide

xm_vibvsl
	move	d2,-(sp)
	bsr.b	xm_vibrato2
	move	(sp)+,d2
	bra.b	xm_vslide


; Command 7 - Tremolo

xm_tremolo
	move.b	vibcmd(a2),d2
	move	d1,d0
	and	#$f0,d0
	beq.b	.vib2

	and	#$f,d2
	or	d0,d2

.vib2	moveq	#$f,d0
	and	d1,d0
	beq.b	.vibskip2

	and	#$f0,d2
	or	d0,d2
.vibskip2
	move.b	d2,vibcmd(a2)

	moveq	#$1f,d0
	and.b	vibpos(a2),d0
	moveq	#0,d2
	lea	mt_vibratotable(pc),a3
	move.b	(a3,d0),d2
	moveq	#$f,d0
	and.b	vibcmd(a2),d0
	mulu	d0,d2
	lsr	#6,d2

	move	volume(a2),d0
	btst	#5,vibpos(a2)
	bne.b	.neg
	add	d2,d0
	bra.b	.vib3
.neg
	sub	d2,d0
.vib3	move	d0,mVolume(a4)
	move.b	vibcmd(a2),d0
	lsr.b	#4,d0
	add.b	d0,vibpos(a2)
	rts


; Command A - Volume slide
; Also commands EA and EB, fine volume slides

xm_vslide
	lsr	#4,d2
	beq.b	xm_vslidedown
xm_vslideup
	add	d2,volume(a2)
	cmp	#64,volume(a2)
	bls.b	xm_vsskip
	move	#64,volume(a2)
xm_vsskip
	move	volume(a2),rVolume(a2)
	rts

xm_vslidedown
	moveq	#$f,d2
	and.b	lastcmd(a2),d2
xm_vslidedown2
	sub	d2,volume(a2)
	bpl.b	xm_vsskip
	clr	volume(a2)
	clr	rVolume(a2)
	rts


; Command B - Pattern jump

xm_pjmp	move	d1,pos(a5)
	st	pbflag(a5)
	clr	rows(a5)
	rts


; Command C - Set volume

xm_setvol
	cmp	#64,d1
	bls.b	.ok
	moveq	#64,d1
.ok	move	d1,volume(a2)
	rts


; Command D - Pattern break

xm_pbrk	addq	#1,pos(a5)
	st	pbflag(a5)
	moveq	#$f,d2
	and.l	d1,d2
	lsr.l	#4,d1
	mulu	#10,d1
	add	d2,d1
	move	d1,rows(a5)
	rts


; Command E - Extended commands

xm_ecmds
	lea	xm_ect(pc),a1
xm_ee	move	d1,d0
	moveq	#$f,d1
	and	d0,d1
	move	d1,d2
	lsr	#4,d0

	ifne	debug
	move.l	kalas(a5),a3
	st	$40(a3,d0)
	endc

	add	d0,d0
	move	(a1,d0),d0
	jmp	(a1,d0)

xm_cecmds
	lea	xm_cect(pc),a1
	bra.b	xm_ee


; Command E9 - Retrig note

xm_retrig
	subq.b	#1,retrigcn(a2)
	bne	xm_eret

	move.l	sample(a2),d2
	beq	xm_eret
	move.l	d2,a1

	move	d1,-(sp)

	bsr	xm_getInst

	clr.l	mFPos(a4)
; Handle envelopes
	move	#$ffff,fadeOut(a2)
	clr.b	fading(a2)
	clr.b	keyoff(a2)

	move.l	sample(a2),a3
	btst	#xmEnvOn,xmVolType(a3)
	beq.b	.voloff

	st	volEnvOn(a2)
	clr.b	volCurPnt(a2)
	st	volRecalc(a2)
	clr.b	volSustained(a2)
	bra.b	.jep

.voloff	clr.b	volEnvOn(a2)


.jep	btst	#xmEnvOn,xmPanType(a3)
	beq.b	.panoff

	st	panEnvOn(a2)
	clr.b	panCurPnt(a2)
	st	panRecalc(a2)
	clr.b	panSustained(a2)
	bra.b	.jep2

.panoff	clr.b	panEnvOn(a2)

.jep2	move.l	a1,a3
	tlword	(a3)+,d0			; sample length

	move.l	a6,(a4)				; sample start
	btst	#xm16bitf,xmSmpFlags(a1)
	beq.b	.bit8_2
	lsr.l	#1,d0
.bit8_2	move.l	d0,mLength(a4)
	clr.b	mOnOff(a4)
	move	(sp)+,d1
xm_sretrig
	move.b	d1,retrigcn(a2)
	rts


; Command EC - Note cut

xm_ncut	cmp	cn(a5),d1
	bne.b	xm_eret
	clr	volume(a2)
	clr	rVolume(a2)
xm_eret	rts


; Command ED - Delay note

xm_ndelay
	cmp	cn(a5),d1
	bne.b	xm_eret

	tst	(a2)
	beq	.skip

	moveq	#0,d0
	move.b	(a2),d0
	beq	.skip

	cmp.b	#97,d0				; Key off -note
	beq	.keyoff

	move.b	d0,note(a2)

	moveq	#0,d1
	move.b	inst(a2),d1
	beq.b	.esmp

	lsl	#2,d1
	lea	xm_insts,a1
	move.l	-4(a1,d1),a1

	move.l	a1,sample(a2)
	bra.b	.ju
.esmp	move.l	sample(a2),d2
	beq	.skip
	move.l	d2,a1

.ju	bsr	xm_getInst

	tst.b	inst(a2)
	beq.b	.smpok

	lea	xmLoopStart(a1),a3
	tlword	(a3)+,d1
	lea	xmLoopLength(a1),a3
	tlword	(a3)+,d2

	btst	#xm16bitf,xmSmpFlags(a1)
	beq.b	.bit8
	lsr.l	#1,d1
	lsr.l	#1,d2
.bit8	add.l	a6,d1

	move.l	d1,mLStart(a4)
	move.l	d2,mLLength(a4)
	move.b	xmVolume(a1),volume+1(a2)
	cmp	#64,volume(a2)
	bls.b	.e
	move	#64,volume(a2)
.e	move	volume(a2),rVolume(a2)

	moveq	#xmLoopType,d1
	and.b	xmSmpFlags(a1),d1
	beq.b	.eloo
	st	mLoop(a4)
	bra.b	.smpok

.eloo	clr.b	mLoop(a4)

.smpok
	bsr	xm_getPeriod

	move	d0,rPeriod(a2)
	move	d0,period(a2)
	clr.l	mFPos(a4)

; Handle envelopes
	move	#$ffff,fadeOut(a2)
	clr.b	fading(a2)
	clr.b	keyoff(a2)

	move.l	sample(a2),a3

	btst	#xmEnvOn,xmVolType(a3)
	beq.b	.voloff

	st	volEnvOn(a2)
	clr.b	volCurPnt(a2)
	st	volRecalc(a2)
	clr.b	volSustained(a2)
	bra.b	.jep

.voloff	clr.b	volEnvOn(a2)


.jep	btst	#xmEnvOn,xmPanType(a3)
	beq.b	.panoff

	st	panEnvOn(a2)
	clr.b	panCurPnt(a2)
	st	panRecalc(a2)
	clr.b	panSustained(a2)
	bra.b	.jep2

.panoff	clr.b	panEnvOn(a2)

.jep2	move.l	a1,a3
	tlword	(a3)+,d0			; sample length
	move.l	a6,(a4)				; sample start
	btst	#xm16bitf,xmSmpFlags(a1)
	beq.b	.bit8_2
	lsr.l	#1,d0
.bit8_2	move.l	d0,mLength(a4)
	clr.b	mOnOff(a4)
	bra.b	.skip

.keyoff
	tst.b	volEnvOn(a2)
	beq.b	.vol0

	clr.b	volSustained(a2)
	st	fading(a2)
	st	keyoff(a2)
	bra.b	.skip

.vol0	tst.b	inst(a2)
	bne.b	.skip
	clr	volume(a2)
.skip
.ret	rts




; Command EE - Pattern delay

xm_pdelay
	tst.b	pdelaycnt(a5)
	bne.b	.skip

	move	d1,pdelaycnt(a5)

.skip	rts

; Command F - Set speed

xm_spd	cmp	#$20,d1
	bhs.b	.bpm

	tst	d1
	beq.b	.g
	move	d1,spd(a5)
.g	rts

.bpm	move	d1,tempo(a5)
	move.l	mrate(a5),d0
	move.l	d0,d2
	lsl.l	#2,d0
	add.l	d2,d0
	add	d1,d1
	divu	d1,d0

	addq	#1,d0
	and	#~1,d0
	move	d0,bytesperframe(a5)
	rts


; Command G - Set global volume

xm_sgvol
	cmp	#64,d1
	bls.b	.ok
	moveq	#64,d1
.ok	move	d1,globalVol(a5)
	rts


; Command H - Global volume slide

xm_gvslide
	lsr	#4,d2
	beq.b	.down
	add	d2,globalVol(a5)
	cmp	#64,globalVol(a5)
	bls.b	.x
	move	#64,globalVol(a5)
.x	rts

.down	moveq	#$f,d2
	and.b	lastcmd(a2),d2
	sub	d2,globalVol(a5)
	bpl.b	.x
	clr	globalVol(a5)
	rts


; Command K - Key off

xm_keyoff
	clr.b	volSustained(a2)
	st	fading(a2)
	st	keyoff(a2)
	rts


; Command L - Set envelope position

xm_setenvpos
	tst.b	volEnvOn(a2)
	beq	.skip

	move	d1,volEnvX(a2)

	move.l	sample(a2),d2
	beq	.skip

	move.l	d2,a1

	clr.b	volSustained(a2)

	moveq	#0,d2
	lea	xmVolEnv(a1),a3
	moveq	#11,d3
.loop	tword	(a3)+,d0
	cmp	d0,d1
	beq.b	.exact
	blo.b	.found
	addq	#2,a3
	addq	#1,d2
	dbf	d3,.loop
	subq	#2,a3
	bra.b	.found
.exact	move.b	d2,volCurPnt(a2)
	subq	#2,a3
	bra.b	.con
.found	move.b	d2,volCurPnt(a2)
	subq	#6,a3
.con
	moveq	#0,d2
	tword	(a3)+,d1			; Envelope X
	tword	(a3)+,d2			; Envelope Y

	moveq	#0,d3
	tword	(a3)+,d4			; To X
	tword	(a3)+,d3			; To Y

	sub.l	d2,d3
	asl.l	#8,d3
	sub	d1,d4
	beq.b	.hups
	divs	d4,d3
.hups	move	d3,volEnvDelta(a2)

	lsl	#8,d2

	move	volEnvX(a2),d0
	sub	d1,d0
	mulu	d3,d0
	add	d0,d2
	move	d2,volEnvY(a2)

	addq.b	#1,volCurPnt(a2)
	clr.b	volRecalc(a2)
.skip	rts



; Command R - Multi retrig note

xm_rretrig
	subq.b	#1,retrigcn(a2)
	bne	xm_eret

	move.l	sample(a2),d2
	beq	xm_eret
	move.l	d2,a1

	move	d1,-(sp)

	bsr	xm_getInst

	clr.l	mFPos(a4)
; Handle envelopes
	move	#$ffff,fadeOut(a2)
	clr.b	fading(a2)
	clr.b	keyoff(a2)

	move.l	sample(a2),a3
	btst	#xmEnvOn,xmVolType(a3)
	beq.b	.voloff

	st	volEnvOn(a2)
	clr.b	volCurPnt(a2)
	st	volRecalc(a2)
	clr.b	volSustained(a2)
	bra.b	.jep

.voloff	clr.b	volEnvOn(a2)


.jep	btst	#xmEnvOn,xmPanType(a3)
	beq.b	.panoff

	st	panEnvOn(a2)
	clr.b	panCurPnt(a2)
	st	panRecalc(a2)
	clr.b	panSustained(a2)
	bra.b	.jep2

.panoff	clr.b	panEnvOn(a2)

.jep2	move.l	a1,a3
	tlword	(a3)+,d0			; sample length

	move.l	a6,(a4)				; sample start
	btst	#xm16bitf,xmSmpFlags(a1)
	beq.b	.bit8_2
	lsr.l	#1,d0
.bit8_2	move.l	d0,mLength(a4)
	clr.b	mOnOff(a4)

	moveq	#0,d0
	move.b	lastcmd(a2),d0
	lsr	#4,d0
	moveq	#0,d2
	lea	ftab2(pc),a3
	move.b	(a3,d0),d2
	beq.b	.ddq

	mulu	volume(a2),d2
	lsr	#4,d2
	move	d2,volume(a2)
	bra.b	.ddw

.ddq	lea	ftab1(pc),a3
	move.b	(a3,d0),d2
	ext	d2
	add	d2,volume(a2)

.ddw	tst	volume(a2)
	bpl.b	.ei0
	clr	volume(a2)
.ei0	cmp	#64,volume(a2)
	bls.b	.ei64
	move	#64,volume(a2)
.ei64	move	volume(a2),mVolume(a4)
	move	(sp)+,d1
xm_srretrig
	and	#$f,d1
	move.b	d1,retrigcn(a2)
	rts


; Command T - Tremor

xm_tremor
	rts


; Command X - Extra fine slides

xm_xfinesld
	move.b	d2,d1
	and	#$f,d2
	cmp.b	#$10,d1
	blo.b	.q
	cmp.b	#$20,d1
	blo	xm_xslideup
	cmp.b	#$30,d1
	blo	xm_xslidedwn
.q	rts

	dc	960,954,948,940,934,926,920,914
xm_periods
	dc	907,900,894,887,881,875,868,862,856,850,844,838,832,826,820,814
	dc	808,802,796,791,785,779,774,768,762,757,752,746,741,736,730,725
	dc	720,715,709,704,699,694,689,684,678,675,670,665,660,655,651,646
	dc	640,636,632,628,623,619,614,610,604,601,597,592,588,584,580,575
	dc	570,567,563,559,555,551,547,543,538,535,532,528,524,520,516,513
	dc	508,505,502,498,494,491,487,484,480,477,474,470,467,463,460,457

xm_linFreq
	dc.l	535232,534749,534266,533784,533303,532822,532341,531861
	dc.l	531381,530902,530423,529944,529466,528988,528511,528034
	dc.l	527558,527082,526607,526131,525657,525183,524709,524236
	dc.l	523763,523290,522818,522346,521875,521404,520934,520464
	dc.l	519994,519525,519057,518588,518121,517653,517186,516720
	dc.l	516253,515788,515322,514858,514393,513929,513465,513002
	dc.l	512539,512077,511615,511154,510692,510232,509771,509312
	dc.l	508852,508393,507934,507476,507018,506561,506104,505647
	dc.l	505191,504735,504280,503825,503371,502917,502463,502010
	dc.l	501557,501104,500652,500201,499749,499298,498848,498398
	dc.l	497948,497499,497050,496602,496154,495706,495259,494812
	dc.l	494366,493920,493474,493029,492585,492140,491696,491253
	dc.l	490809,490367,489924,489482,489041,488600,488159,487718
	dc.l	487278,486839,486400,485961,485522,485084,484647,484210
	dc.l	483773,483336,482900,482465,482029,481595,481160,480726
	dc.l	480292,479859,479426,478994,478562,478130,477699,477268
	dc.l	476837,476407,475977,475548,475119,474690,474262,473834
	dc.l	473407,472979,472553,472126,471701,471275,470850,470425
	dc.l	470001,469577,469153,468730,468307,467884,467462,467041
	dc.l	466619,466198,465778,465358,464938,464518,464099,463681
	dc.l	463262,462844,462427,462010,461593,461177,460760,460345
	dc.l	459930,459515,459100,458686,458272,457859,457446,457033
	dc.l	456621,456209,455797,455386,454975,454565,454155,453745
	dc.l	453336,452927,452518,452110,451702,451294,450887,450481
	dc.l	450074,449668,449262,448857,448452,448048,447644,447240
	dc.l	446836,446433,446030,445628,445226,444824,444423,444022
	dc.l	443622,443221,442821,442422,442023,441624,441226,440828
	dc.l	440430,440033,439636,439239,438843,438447,438051,437656
	dc.l	437261,436867,436473,436079,435686,435293,434900,434508
	dc.l	434116,433724,433333,432942,432551,432161,431771,431382
	dc.l	430992,430604,430215,429827,429439,429052,428665,428278
	dc.l	427892,427506,427120,426735,426350,425965,425581,425197
	dc.l	424813,424430,424047,423665,423283,422901,422519,422138
	dc.l	421757,421377,420997,420617,420237,419858,419479,419101
	dc.l	418723,418345,417968,417591,417214,416838,416462,416086
	dc.l	415711,415336,414961,414586,414212,413839,413465,413092
	dc.l	412720,412347,411975,411604,411232,410862,410491,410121
	dc.l	409751,409381,409012,408643,408274,407906,407538,407170
	dc.l	406803,406436,406069,405703,405337,404971,404606,404241
	dc.l	403876,403512,403148,402784,402421,402058,401695,401333
	dc.l	400970,400609,400247,399886,399525,399165,398805,398445
	dc.l	398086,397727,397368,397009,396651,396293,395936,395579
	dc.l	395222,394865,394509,394153,393798,393442,393087,392733
	dc.l	392378,392024,391671,391317,390964,390612,390259,389907
	dc.l	389556,389204,388853,388502,388152,387802,387452,387102
	dc.l	386753,386404,386056,385707,385359,385012,384664,384317
	dc.l	383971,383624,383278,382932,382587,382242,381897,381552
	dc.l	381208,380864,380521,380177,379834,379492,379149,378807
	dc.l	378466,378124,377783,377442,377102,376762,376422,376082
	dc.l	375743,375404,375065,374727,374389,374051,373714,373377
	dc.l	373040,372703,372367,372031,371695,371360,371025,370690
	dc.l	370356,370022,369688,369355,369021,368688,368356,368023
	dc.l	367691,367360,367028,366697,366366,366036,365706,365376
	dc.l	365046,364717,364388,364059,363731,363403,363075,362747
	dc.l	362420,362093,361766,361440,361114,360788,360463,360137
	dc.l	359813,359488,359164,358840,358516,358193,357869,357547
	dc.l	357224,356902,356580,356258,355937,355616,355295,354974
	dc.l	354654,354334,354014,353695,353376,353057,352739,352420
	dc.l	352103,351785,351468,351150,350834,350517,350201,349885
	dc.l	349569,349254,348939,348624,348310,347995,347682,347368
	dc.l	347055,346741,346429,346116,345804,345492,345180,344869
	dc.l	344558,344247,343936,343626,343316,343006,342697,342388
	dc.l	342079,341770,341462,341154,340846,340539,340231,339924
	dc.l	339618,339311,339005,338700,338394,338089,337784,337479
	dc.l	337175,336870,336566,336263,335959,335656,335354,335051
	dc.l	334749,334447,334145,333844,333542,333242,332941,332641
	dc.l	332341,332041,331741,331442,331143,330844,330546,330247
	dc.l	329950,329652,329355,329057,328761,328464,328168,327872
	dc.l	327576,327280,326985,326690,326395,326101,325807,325513
	dc.l	325219,324926,324633,324340,324047,323755,323463,323171
	dc.l	322879,322588,322297,322006,321716,321426,321136,320846
	dc.l	320557,320267,319978,319690,319401,319113,318825,318538
	dc.l	318250,317963,317676,317390,317103,316817,316532,316246
	dc.l	315961,315676,315391,315106,314822,314538,314254,313971
	dc.l	313688,313405,313122,312839,312557,312275,311994,311712
	dc.l	311431,311150,310869,310589,310309,310029,309749,309470
	dc.l	309190,308911,308633,308354,308076,307798,307521,307243
	dc.l	306966,306689,306412,306136,305860,305584,305308,305033
	dc.l	304758,304483,304208,303934,303659,303385,303112,302838
	dc.l	302565,302292,302019,301747,301475,301203,300931,300660
	dc.l	300388,300117,299847,299576,299306,299036,298766,298497
	dc.l	298227,297958,297689,297421,297153,296884,296617,296349
	dc.l	296082,295815,295548,295281,295015,294749,294483,294217
	dc.l	293952,293686,293421,293157,292892,292628,292364,292100
	dc.l	291837,291574,291311,291048,290785,290523,290261,289999
	dc.l	289737,289476,289215,288954,288693,288433,288173,287913
	dc.l	287653,287393,287134,286875,286616,286358,286099,285841
	dc.l	285583,285326,285068,284811,284554,284298,284041,283785
	dc.l	283529,283273,283017,282762,282507,282252,281998,281743
	dc.l	281489,281235,280981,280728,280475,280222,279969,279716
	dc.l	279464,279212,278960,278708,278457,278206,277955,277704
	dc.l	277453,277203,276953,276703,276453,276204,275955,275706
	dc.l	275457,275209,274960,274712,274465,274217,273970,273722
	dc.l	273476,273229,272982,272736,272490,272244,271999,271753
	dc.l	271508,271263,271018,270774,270530,270286,270042,269798
	dc.l	269555,269312,269069,268826,268583,268341,268099,267857

xm_ct	dc	xm_arpeggio-xm_ct	;0
	dc	xm_ret-xm_ct		;1
	dc	xm_ret-xm_ct		;2
	dc	xm_ret-xm_ct		;3
	dc	xm_ret-xm_ct		;4
 	dc	xm_ret-xm_ct		;5
	dc	xm_ret-xm_ct		;6
	dc	xm_ret-xm_ct		;7
	dc	xm_ret-xm_ct		;8
	dc	xm_ret-xm_ct		;9
	dc	xm_ret-xm_ct		;A
 	dc	xm_pjmp-xm_ct		;B
 	dc	xm_setvol-xm_ct		;C
 	dc	xm_pbrk-xm_ct		;D
 	dc	xm_ecmds-xm_ct		;E
 	dc	xm_spd-xm_ct		;F
	dc	xm_sgvol-xm_ct		;G
 	dc	xm_ret-xm_ct		;H
 	dc	xm_ret-xm_ct		;I
 	dc	xm_ret-xm_ct		;J
 	dc	xm_keyoff-xm_ct		;K
 	dc	xm_setenvpos-xm_ct	;L
 	dc	xm_ret-xm_ct		;M
 	dc	xm_ret-xm_ct		;N
 	dc	xm_ret-xm_ct		;O
 	dc	xm_ret-xm_ct		;P
 	dc	xm_ret-xm_ct		;Q
 	dc	xm_srretrig-xm_ct	;R
 	dc	xm_ret-xm_ct		;S
 	dc	xm_tremor-xm_ct		;T
 	dc	xm_ret-xm_ct		;U
 	dc	xm_ret-xm_ct		;V
 	dc	xm_ret-xm_ct		;W
 	dc	xm_xfinesld-xm_ct	;X
 	dc	xm_ret-xm_ct		;Y
 	dc	xm_ret-xm_ct		;Z

xm_cct	dc	xm_arpeggio-xm_cct	;0
	dc	xm_slideup-xm_cct	;1
	dc	xm_slidedwn-xm_cct	;2
	dc	xm_tonep-xm_cct		;3
	dc	xm_vibrato-xm_cct	;4
	dc	xm_tpvsl-xm_cct		;5
	dc	xm_vibvsl-xm_cct	;6
	dc	xm_tremolo-xm_cct	;7
	dc	xm_ret-xm_cct		;8
	dc	xm_ret-xm_cct		;9
	dc	xm_vslide-xm_cct	;A
 	dc	xm_ret-xm_cct		;B
 	dc	xm_ret-xm_cct		;C
 	dc	xm_ret-xm_cct		;D
 	dc	xm_cecmds-xm_cct	;E
 	dc	xm_ret-xm_cct		;F
 	dc	xm_ret-xm_cct		;G
	dc	xm_gvslide-xm_cct	;H
 	dc	xm_ret-xm_cct		;I
 	dc	xm_ret-xm_cct		;J
 	dc	xm_ret-xm_cct		;K
 	dc	xm_ret-xm_cct		;L
 	dc	xm_ret-xm_cct		;M
 	dc	xm_ret-xm_cct		;N
 	dc	xm_ret-xm_cct		;O
 	dc	xm_ret-xm_cct		;P
 	dc	xm_ret-xm_cct		;Q
 	dc	xm_rretrig-xm_cct	;R
 	dc	xm_ret-xm_cct		;S
 	dc	xm_tremor-xm_cct	;T
 	dc	xm_ret-xm_cct		;U
 	dc	xm_ret-xm_cct		;V
 	dc	xm_ret-xm_cct		;W
 	dc	xm_ret-xm_cct		;X
 	dc	xm_ret-xm_cct		;Y
 	dc	xm_ret-xm_cct		;Z

xm_ect	dc	xm_ret-xm_ect		;0
	dc	xm_slideup-xm_ect	;1
	dc	xm_slidedwn-xm_ect	;2
	dc	xm_ret-xm_ect		;3
	dc	xm_ret-xm_ect		;4
	dc	xm_ret-xm_ect		;5
	dc	xm_ret-xm_ect		;6
	dc	xm_ret-xm_ect		;7
	dc	xm_ret-xm_ect		;8
	dc	xm_sretrig-xm_ect	;9
	dc	xm_vslideup-xm_ect	;A
 	dc	xm_vslidedown2-xm_ect	;B
 	dc	xm_ncut-xm_ect		;C
 	dc	xm_ret-xm_ect		;D
 	dc	xm_pdelay-xm_ect	;E
 	dc	xm_ret-xm_ect		;F

xm_cect	dc	xm_ret-xm_cect		;0
	dc	xm_ret-xm_cect		;1
	dc	xm_ret-xm_cect		;2
	dc	xm_ret-xm_cect		;3
	dc	xm_ret-xm_cect		;4
	dc	xm_ret-xm_cect		;5
	dc	xm_ret-xm_cect		;6
	dc	xm_ret-xm_cect		;7
	dc	xm_ret-xm_cect		;8
	dc	xm_retrig-xm_cect	;9
	dc	xm_ret-xm_cect		;A
 	dc	xm_ret-xm_cect		;B
 	dc	xm_ncut-xm_cect		;C
 	dc	xm_ndelay-xm_cect	;D
 	dc	xm_ret-xm_cect		;E
 	dc	xm_ret-xm_cect		;F

xm_vct	dc	xm_ret-xm_vct		;6
	dc	xm_ret-xm_vct		;7
	dc	xm_vslidedown2-xm_vct	;8
	dc	xm_vslideup-xm_vct	;9
	dc	xm_svibspd-xm_vct	;A
 	dc	xm_ret-xm_vct		;B
 	dc	xm_ret-xm_vct		;C
 	dc	xm_ret-xm_vct		;D
 	dc	xm_ret-xm_vct		;E
 	dc	xm_ret-xm_vct		;F

xm_cvct	dc	xm_vslidedown2-xm_cvct	;6
	dc	xm_vslideup-xm_cvct	;7
	dc	xm_ret-xm_cvct		;8
	dc	xm_ret-xm_cvct		;9
	dc	xm_ret-xm_cvct		;A
 	dc	xm_vibrato-xm_cvct	;B
 	dc	xm_ret-xm_cvct		;C
 	dc	xm_ret-xm_cvct		;D
 	dc	xm_ret-xm_cvct		;E
 	dc	xm_tonep-xm_cvct	;F


   *************************
   *   Standard effects:   *
   *************************

;!      0      Arpeggio
;!      1  (*) Porta up
;!      2  (*) Porta down
;!      3  (*) Tone porta
;-      4  (*) Vibrato
;!      5  (*) Tone porta+Volume slide
;-      6  (*) Vibrato+Volume slide
;-      7  (*) Tremolo
;*      8      Set panning
;!      9      Sample offset
;!      A  (*) Volume slide
;!      B      Position jump
;!      C      Set volume
;!      D      Pattern break
;!      E1 (*) Fine porta up
;!      E2 (*) Fine porta down
;-      E3     Set gliss control
;-      E4     Set vibrato control
;-      E5     Set finetune
;-      E6     Set loop begin/loop
;-      E7     Set tremolo control
;!      E9     Retrig note
;!      EA (*) Fine volume slide up
;!      EB (*) Fine volume slide down
;!      EC     Note cut
;!      ED     Note delay
;-      EE     Pattern delay
;!      F      Set tempo/BPM
;!      G      Set global volume
;!      H  (*) Global volume slide
;!     	K      Key off
;!      L      Set envelope position
;*      P  (*) Panning slide
;!      R  (*) Multi retrig note
;-      T      Tremor
;-      X1 (*) Extra fine porta up
;-      X2 (*) Extra fine porta down
;
;      (*) = If the command byte is zero, the last nonzero byte for the
;            command should be used.
;
;   *********************************
;   *   Effects in volume column:   *
;   *********************************
;
;   All effects in the volume column should work as the standard effects.
;   The volume column is interpreted before the standard effects, so
;   some standard effects may override volume column effects.
;
;   Value      Meaning
;
;      0       Do nothing
;    $10-$50   Set volume Value-$10
;      :          :        :
;      :          :        :
;!    $60-$6f   Volume slide down
;!    $70-$7f   Volume slide up
;!    $80-$8f   Fine volume slide down
;!    $90-$9f   Fine volume slide up
;-    $a0-$af   Set vibrato speed
;-    $b0-$bf   Vibrato
;*    $c0-$cf   Set panning
;*    $d0-$df   Panning slide left
;*    $e0-$ef   Panning slide right
;!    $f0-$ff   Tone porta

	endb	a5

********** Protracker (Fasttracker player) **************

n_note		equ	0
n_cmd		equ	2
n_cmdlo		equ	3
n_start		equ	4
n_length	equ	8
n_loopstart	equ	10
n_replen	equ	14
n_period	equ	16
n_finetune	equ	18
n_volume	equ	19
n_dmabit	equ	20
n_toneportdirec	equ	22
n_toneportspeed	equ	23
n_wantedperiod	equ	24
n_vibratocmd	equ	26
n_vibratopos	equ	27
n_tremolocmd	equ	28
n_tremolopos	equ	29
n_wavecontrol	equ	30
n_glissfunk	equ	31
n_sampleoffset	equ	32
n_pattpos	equ	33
n_loopcount	equ	34
n_funkoffset	equ	35
n_wavestart	equ	36
n_reallength	equ	40

	basereg	data,a5
mtm_init
	move.l	s3m(a5),a0
	move.l	a0,mt_songdataptr
	lea	4(a0),a1
	move.l	a1,mname(a5)

	move.l	#mtm_periodtable,peris
	move	#1616,lowlim
	move	#45,upplim
	move	#126,octs

	moveq	#0,d0
	move.b	27(a0),d0
	addq.b	#1,d0
	move.b	d0,slene
	move	d0,positioneita(a5)

	moveq	#0,d1
	move.b	33(a0),d1
	move	d1,numchans(a5)

	moveq	#0,d0
	move.b	32(a0),d0
	lsl	#2,d0
	mulu	d1,d0
	move	d0,patlen

	move.l	a0,d0
	add.l	#66,d0

	moveq	#0,d1
	move.b	30(a0),d1			; NOS
	mulu	#37,d1
	add.l	d1,d0

	move.l	d0,orderz
	add.l	#128,d0
	move.l	d0,tracks

	move	24(a0),d1			; number of tracks
	iword	d1
	mulu	#192,d1
	add.l	d1,d0

	move.l	d0,sequ

	moveq	#0,d1
	move.b	26(a0),d1			; last pattern saved
	addq	#1,d1
	lsl	#6,d1
	add.l	d1,d0

	moveq	#0,d1
	move	28(a0),d1			; length of comment field
	iword	d1
	add.l	d1,d0

	lea	66(a0),a2			; sample infos

	moveq	#0,d7
	move.b	30(a0),d7			; NOS
	subq	#1,d7

	lea	mt_sampleinfos(pc),a1
.loop	move.l	d0,(a1)+
	lea	22(a2),a3
	tlword	(a3)+,d1
	add.l	d1,d0
	lsr.l	#1,d1
	move	d1,(a1)+

	lea	26(a2),a3
	tlword	(a3)+,d1
	lsr.l	#1,d1
	move	d1,(a1)+			; rep offset

	lea	30(a2),a3
	tlword	(a3)+,d2
	lsr.l	#1,d2
	sub.l	d1,d2	
	move	d2,(a1)+			; rep length

	clr.b	(a1)+				; no finetune
	move.b	35(a2),(a1)+			; volume

	lea	37(a2),a2
	dbf	d7,.loop

	or.b	#2,$bfe001
	move.b	#6,mt_speed
	clr.b	mt_counter
	clr.b	mt_songpos
	clr	mt_patternpos

	move	#2,fformat			; unsigned data
	move	#125,tempo
	move.l	#14317056/4,clock		; Clock constant

	lea	34(a0),a2
	lea	pantab(a5),a0
	move.l	a0,a1
	moveq	#7,d0
.l	clr.l	(a1)+
	dbf	d0,.l

	move	numchans(a5),d0
	subq	#1,d0
	moveq	#0,d5
	moveq	#0,d6
.lop	move.b	(a2)+,d1
	cmp.b	#8,d1
	blo.b	.vas
	move.b	#-1,(a0)+
	addq	#1,d5
	bra.b	.je
.vas	move.b	#1,(a0)+
	addq	#1,d6
.je	dbf	d0,.lop

	cmp	d5,d6
	bls.b	.k
	move	d6,d5
.k	move	d5,maxchan(a5)

	lea	mt_chan1temp(pc),a0
	move	#44*8-1,d0
.cl	clr.l	(a0)+
	dbf	d0,.cl

	moveq	#0,d0
	rts

orderz	dc.l	0
tracks	dc.l	0
sequ	dc.l	0
slene	dc	0
patlen	dc	0
upplim	dc	0
lowlim	dc	0
peris	dc.l	0
octs	dc	0

mt_init	lea	data,a5
	move.l	s3m(a5),a0
	move.l	a0,mname
	move.l	a0,mt_songdataptr
	move.l	a0,a1
	moveq	#0,d0
	move.b	950(a1),d0
	move.b	d0,slene
	move	d0,positioneita

	move	#256,d0
	mulu	numchans(a5),d0
	move	d0,patlen

	move	#113,upplim
	move	#856,lowlim
	move.l	#mt_periodtable,peris
	move	#36*2,octs

	lea	952(a1),a1
	moveq	#127,d0
	moveq	#0,d1
mtloop	move.l	d1,d2
	subq	#1,d0
mtloop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.b	mtloop
	dbra	d0,mtloop2
	addq.b	#1,d2
			
	lea	mt_sampleinfos(pc),a1
	asl	#8,d2
	mulu	numchans(a5),d2

	add.l	#1084,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#30,d0
mtloop3	move.l	a2,(a1)+
	moveq	#0,d1
	move	42(a0),d1
	move	d1,(a1)+
	asl.l	#1,d1
	add.l	d1,a2

	move	46(a0),(a1)+
	move	48(a0),(a1)+
	move	44(a0),(a1)+			; finetune and volume

	add.l	#30,a0
	dbra	d0,mtloop3

	or.b	#2,$bfe001
	move.b	#6,mt_speed
	clr.b	mt_counter
	clr.b	mt_songpos
	clr	mt_patternpos

	move	#1,fformat
	move	#125,tempo
	move.l	#14187580/4,clock		; Clock constant

	lea	pantab(a5),a0
	move.l	a0,a1
	moveq	#7,d0
.l	clr.l	(a1)+
	dbf	d0,.l

	move	numchans(a5),d0
	subq	#1,d0
	moveq	#0,d1
.lop	tst	d1
	beq.b	.vas
	cmp	#3,d1
	beq.b	.vas
.oik	move.b	#-1,(a0)+
	bra.b	.je
.vas	move.b	#1,(a0)+
.je	addq	#1,d1
	and	#3,d1
	dbf	d0,.lop

	lea	mt_chan1temp(pc),a0
	move	#44*8-1,d0
.cl	clr.l	(a0)+
	dbf	d0,.cl

	moveq	#0,d0
	rts

	endb	a5
mt_music
	movem.l	d0-d4/a0-a6,-(sp)
	addq.b	#1,mt_counter
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blo.b	mt_nonewnote
	clr.b	mt_counter
	tst.b	mt_pattdeltime2
	beq.b	mt_getnewnote
	bsr.b	mt_nonewallchannels
	bra	mt_dskip

mt_nonewnote
	bsr.b	mt_nonewallchannels
	bra	mt_nonewposyet

mt_nonewallchannels
	move	numchans,d7
	subq	#1,d7
	lea	cha0,a5
	lea	mt_chan1temp(pc),a6
.loo	move	d7,-(sp)
	bsr	mt_checkefx
	move	(sp)+,d7
	lea	mChanBlock_SIZE(a5),a5
	lea	44(a6),a6			; Size of MT_chanxtemp
	dbf	d7,.loo
	rts

mt_getnewnote
	move.l	mt_songdataptr(pc),a0
	lea	12(a0),a3
	lea	952(a0),a2	;pattpo
	lea	1084(a0),a0	;patterndata
	moveq	#0,d0
	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0),d1
	asl.l	#8,d1
	mulu	numchans,d1
	add	mt_patternpos(pc),d1
	clr	mt_dmacontemp

	cmp	#mtMTM,mtype
	bne.b	.ei
	moveq	#0,d1
.ei
	move	numchans,d7
	subq	#1,d7
	lea	cha0,a5
	lea	mt_chan1temp(pc),a6
.loo	move	d7,-(sp)

	tst.l	(a6)
	bne.b	.mt_plvskip
	bsr	mt_pernop
.mt_plvskip
	bsr.b	getnew

	bsr	mt_playvoice
	move	(sp)+,d7
	lea	mChanBlock_SIZE(a5),a5
	lea	44(a6),a6			; Size of MT_chanxtemp
	dbf	d7,.loo

	bra	mt_setdma

getnew	cmp	#mtMOD,mtype
	bne.b	.mtm
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	rts

.mtm	move.l	mt_songdataptr(pc),a0
	move.l	orderz(pc),a2
	moveq	#0,d0
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0),d0

	lsl	#6,d0				; 32 channels * word
	move.l	sequ(pc),a2
	add	d1,d0
	move.b	(a2,d0),d2
	lsl	#8,d2
	move.b	1(a2,d0),d2
	move	d2,d0
	beq.b	.zero
	iword	d0
	move.l	tracks(pc),a2
	subq	#1,d0
	mulu	#192,d0

	moveq	#0,d2
	move	mt_patternpos(pc),d2
	divu	numchans,d2
	lsr	#2,d2
	mulu	#3,d2
	add.l	d2,d0

	moveq	#0,d2
	move.b	(a2,d0.l),d2
	lsr	#2,d2
	beq.b	.huu
	move.l	peris(pc),a1
	subq	#1,d2
	add	d2,d2
	move	(a1,d2),d2

.huu	clr.l	(a6)
	or	d2,(a6)

	moveq	#0,d2
	move.b	(a2,d0.l),d2
	lsl	#8,d2
	move.b	1(a2,d0.l),d2
	and	#$3f0,d2
	lsr	#4,d2
	move.b	d2,d3
	and	#$10,d3
	or.b	d3,(a6)
	lsl.b	#4,d2
	or.b	d2,2(a6)

	moveq	#0,d2
	move.b	1(a2,d0.l),d2
	lsl	#8,d2
	move.b	2(a2,d0.l),d2
	and	#$fff,d2
	or	d2,2(a6)

	addq.l	#2,d1
	rts

.zero	clr.l	(a6)
	addq.l	#2,d1
	rts

mt_playvoice
	moveq	#0,d2
	move.b	n_cmd(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.b	mt_setregs
	moveq	#0,d3
	lea	mt_sampleinfos(pc),a1
	move	d2,d4
	subq	#1,d4
	mulu	#12,d4
	move.l	(a1,d4.l),n_start(a6)
	move	4(a1,d4.l),n_length(a6)
	move	4(a1,d4.l),n_reallength(a6)
	move.b	10(a1,d4.l),n_finetune(a6)
	move.b	11(a1,d4.l),n_volume(a6)
	move	6(a1,d4.l),d3 ; get repeat
	tst	d3
	beq.b	mt_noloop
	move.l	n_start(a6),d2	; get start
	asl	#1,d3
	add.l	d3,d2		; add repeat
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move	6(a1,d4.l),d0	; get repeat
	add	8(a1,d4.l),d0	; add replen
	move	d0,n_length(a6)
	move	8(a1,d4.l),n_replen(a6)	; save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move	d0,mVolume(a5)	; set volume
	bra.b	mt_setregs

mt_noloop
	move.l	n_start(a6),d2
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move	8(a1,d4.l),n_replen(a6)	; save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move	d0,mVolume(a5)	; set volume
mt_setregs
	move	(a6),d0
	and	#$fff,d0
	beq	mt_checkmoreefx	; if no note
	move	2(a6),d0
	and	#$ff0,d0
	cmp	#$e50,d0
	beq.b	mt_dosetfinetune
	move.b	2(a6),d0
	and.b	#$f,d0
	cmp.b	#3,d0	; toneportamento
	beq.b	mt_chktoneporta
	cmp.b	#5,d0
	beq.b	mt_chktoneporta
	cmp.b	#9,d0	; sample offset
	bne.b	mt_setperiod
	bsr	mt_checkmoreefx
	bra.b	mt_setperiod

mt_dosetfinetune
	bsr	mt_setfinetune
	bra.b	mt_setperiod

mt_chktoneporta
	bsr	mt_settoneporta
	bra	mt_checkmoreefx

mt_setperiod
	movem.l	d0-d1/a0-a1,-(sp)
	move	(a6),d1
	and	#$fff,d1
	move.l	peris(pc),a1
	moveq	#0,d0
	move	octs(pc),d7
	lsr	#1,d7
mt_ftuloop
	cmp	(a1,d0),d1
	bhs.b	mt_ftufound
	addq.l	#2,d0
	dbra	d7,mt_ftuloop
mt_ftufound
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	octs(pc),d1
	add.l	d1,a1
	move	(a1,d0),n_period(a6)
	movem.l	(sp)+,d0-d1/a0-a1

	move	2(a6),d0
	and	#$ff0,d0
	cmp	#$ed0,d0 ; notedelay
	beq	mt_checkmoreefx

	btst	#2,n_wavecontrol(a6)
	bne.b	mt_vibnoc
	clr.b	n_vibratopos(a6)
mt_vibnoc
	btst	#6,n_wavecontrol(a6)
	bne.b	mt_trenoc
	clr.b	n_tremolopos(a6)
mt_trenoc
	move.l	n_start(a6),(a5)	; set start
	moveq	#0,d0
	move	n_length(a6),d0
	add.l	d0,d0
	move.l	d0,mLength(a5)		; set length
	move	n_period(a6),d0
	lsl	#2,d0
	move	d0,mPeriod(a5)		; set period

	clr.b	mOnOff(a5)		; turn on
	clr.l	mFPos(a5)		; retrig
	bra	mt_checkmoreefx

 
mt_setdma
	move	numchans,d7
	subq	#1,d7
	lea	cha0,a5
	lea	mt_chan1temp(pc),a6
.loo	move	d7,-(sp)
	bsr	setreg
	move	(sp)+,d7
	lea	mChanBlock_SIZE(a5),a5
	lea	44(a6),a6			; Size of MT_chanxtemp
	dbf	d7,.loo

mt_dskip
	moveq	#4,d0
	mulu	numchans,d0
	add	d0,mt_patternpos
	move.b	mt_pattdeltime,d0
	beq.b	mt_dskc
	move.b	d0,mt_pattdeltime2
	clr.b	mt_pattdeltime
mt_dskc	tst.b	mt_pattdeltime2
	beq.b	mt_dska
	subq.b	#1,mt_pattdeltime2
	beq.b	mt_dska

	moveq	#4,d0
	mulu	numchans,d0
	sub	d0,mt_patternpos

mt_dska	tst.b	mt_pbreakflag
	beq.b	mt_nnpysk
	sf	mt_pbreakflag
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	clr.b	mt_pbreakpos
	lsl	#2,d0
	mulu	numchans,d0	
	move	d0,mt_patternpos
mt_nnpysk
	move	patlen(pc),d0
	cmp	mt_patternpos(pc),d0
	bhi.b	mt_nonewposyet
mt_nextposition	
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	lsl	#2,d0
	mulu	numchans,d0
	move	d0,mt_patternpos
	clr.b	mt_pbreakpos
	clr.b	mt_posjumpflag
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos

	moveq	#0,d1
	move.b	mt_songpos(pc),d1
	st	PS3M_poscha
	move	d1,PS3M_position

	cmp.b	slene(pc),d1
	blo.b	mt_nonewposyet
	clr.b	mt_songpos
	st	PS3M_break
mt_nonewposyet	
	tst.b	mt_posjumpflag
	bne.b	mt_nextposition
	movem.l	(sp)+,d0-d4/a0-a6
	rts


setreg	move.l	n_loopstart(a6),mLStart(a5)
	moveq	#0,d0
	move	n_replen(a6),d0
	add.l	d0,d0
	move.l	d0,mLLength(a5)
	cmp.l	#2,mLLength(a5)
	bls.b	.eloo
	st	mLoop(a5)
	tst.b	mOnOff(a5)
	beq.b	.ok
	clr.b	mOnOff(a5)
	clr.l	mFPos(a5)
.ok	rts
.eloo	clr.b	mLoop(a5)
	rts


mt_checkefx
	bsr	mt_updatefunk
	move	n_cmd(a6),d0
	and	#$fff,d0
	beq.b	mt_pernop
	move.b	n_cmd(a6),d0
	and.b	#$f,d0
	beq.b	mt_arpeggio
	cmp.b	#1,d0
	beq	mt_portaup
	cmp.b	#2,d0
	beq	mt_portadown
	cmp.b	#3,d0
	beq	mt_toneportamento
	cmp.b	#4,d0
	beq	mt_vibrato
	cmp.b	#5,d0
	beq	mt_toneplusvolslide
	cmp.b	#6,d0
	beq	mt_vibratoplusvolslide
	cmp.b	#$e,d0
	beq	mt_e_commands
setback	move	n_period(a6),d2
	lsl	#2,d2
	move	d2,mPeriod(a5)
	cmp.b	#7,d0
	beq	mt_tremolo
	cmp.b	#$a,d0
	beq	mt_volumeslide
mt_return2
	rts

mt_pernop
	move	n_period(a6),d2
	lsl	#2,d2
	move	d2,mPeriod(a5)
	rts

mt_arpeggio
	moveq	#0,d0
	move.b	mt_counter(pc),d0
	divs	#3,d0
	swap	d0
	cmp	#0,d0
	beq.b	mt_arpeggio2
	cmp	#2,d0
	beq.b	mt_arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	bra.b	mt_arpeggio3

mt_arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#15,d0
	bra.b	mt_arpeggio3

mt_arpeggio2
	move	n_period(a6),d2
	bra.b	mt_arpeggio4

mt_arpeggio3
	asl	#1,d0
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	octs(pc),d1
	move.l	peris(pc),a0
	add.l	d1,a0
	moveq	#0,d1
	move	n_period(a6),d1
	move	octs(pc),d7
	lsr	#1,d7
	subq	#1,d7
mt_arploop
	move	(a0,d0),d2
	cmp	(a0),d1
	bhs.b	mt_arpeggio4
	addq.l	#2,a0
	dbra	d7,mt_arploop
	rts

mt_arpeggio4
	lsl	#2,d2
	move	d2,mPeriod(a5)
	rts

mt_fineportaup
	tst.b	mt_counter
	bne	mt_return2
	move.b	#$f,mt_lowmask
mt_portaup
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	move.b	#$ff,mt_lowmask
	sub	d0,n_period(a6)
	move	n_period(a6),d0
	and	#$fff,d0
	cmp	upplim(pc),d0
	bpl.b	mt_portauskip
	and	#$f000,n_period(a6)
	move	upplim(pc),d0
	or	d0,n_period(a6)
mt_portauskip
	move	n_period(a6),d0
	and	#$fff,d0
	lsl	#2,d0
	move	d0,mPeriod(a5)
	rts	
 
mt_fineportadown
	tst.b	mt_counter
	bne	mt_return2
	move.b	#$f,mt_lowmask
mt_portadown
	clr	d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	move.b	#$ff,mt_lowmask
	add	d0,n_period(a6)
	move	n_period(a6),d0
	and	#$fff,d0
	cmp	lowlim(pc),d0
	bmi.b	mt_portadskip
	and	#$f000,n_period(a6)
	move	lowlim(pc),d0
	or	d0,n_period(a6)
mt_portadskip
	move	n_period(a6),d0
	and	#$fff,d0
	lsl	#2,d0
	move	d0,mPeriod(a5)
	rts

mt_settoneporta
	move.l	a0,-(sp)
	move	(a6),d2
	and	#$fff,d2
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	octs(pc),d0
	move.l	peris(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_stploop
	cmp	(a0,d0),d2
	bhs.b	mt_stpfound
	addq	#2,d0
	cmp	octs(pc),d0
	blo.b	mt_stploop
	move	octs(pc),d0
	subq	#2,d0
mt_stpfound
	move.b	n_finetune(a6),d2
	and.b	#8,d2
	beq.b	mt_stpgoss
	tst	d0
	beq.b	mt_stpgoss
	subq	#2,d0
mt_stpgoss
	move	(a0,d0),d2
	move.l	(sp)+,a0
	move	d2,n_wantedperiod(a6)
	move	n_period(a6),d0
	clr.b	n_toneportdirec(a6)
	cmp	d0,d2
	beq.b	mt_cleartoneporta
	bge	mt_return2
	move.b	#1,n_toneportdirec(a6)
	rts

mt_cleartoneporta
	clr	n_wantedperiod(a6)
	rts

mt_toneportamento
	move.b	n_cmdlo(a6),d0
	beq.b	mt_toneportnochange
	move.b	d0,n_toneportspeed(a6)
	clr.b	n_cmdlo(a6)
mt_toneportnochange
	tst	n_wantedperiod(a6)
	beq	mt_return2
	moveq	#0,d0
	move.b	n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.b	mt_toneportaup
mt_toneportadown
	add	d0,n_period(a6)
	move	n_wantedperiod(a6),d0
	cmp	n_period(a6),d0
	bgt.b	mt_toneportasetper
	move	n_wantedperiod(a6),n_period(a6)
	clr	n_wantedperiod(a6)
	bra.b	mt_toneportasetper

mt_toneportaup
	sub	d0,n_period(a6)
	move	n_wantedperiod(a6),d0
	cmp	n_period(a6),d0
	blt.b	mt_toneportasetper
	move	n_wantedperiod(a6),n_period(a6)
	clr	n_wantedperiod(a6)

mt_toneportasetper
	move	n_period(a6),d2
	move.b	n_glissfunk(a6),d0
	and.b	#$f,d0
	beq.b	mt_glissskip
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	octs(pc),d0
	move.l	peris(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_glissloop
	cmp	(a0,d0),d2
	bhs.b	mt_glissfound
	addq	#2,d0
	cmp	octs(pc),d0
	blo.b	mt_glissloop
	move	octs(pc),d0
	subq	#2,d0
mt_glissfound
	move	(a0,d0),d2
mt_glissskip
	lsl	#2,d2
	move	d2,mPeriod(a5) ; set period
	rts

mt_vibrato
	move.b	n_cmdlo(a6),d0
	beq.b	mt_vibrato2
	move.b	n_vibratocmd(a6),d2
	and.b	#$f,d0
	beq.b	mt_vibskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_vibskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.b	mt_vibskip2
	and.b	#$f,d2
	or.b	d0,d2
mt_vibskip2
	move.b	d2,n_vibratocmd(a6)
mt_vibrato2
	move.b	n_vibratopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr	#2,d0
	and	#$1f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	and.b	#3,d2
	beq.b	mt_vib_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.b	mt_vib_rampdown
	move.b	#255,d2
	bra.b	mt_vib_set
mt_vib_rampdown
	tst.b	n_vibratopos(a6)
	bpl.b	mt_vib_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.b	mt_vib_set
mt_vib_rampdown2
	move.b	d0,d2
	bra.b	mt_vib_set
mt_vib_sine
	move.b	0(a4,d0),d2
mt_vib_set
	move.b	n_vibratocmd(a6),d0
	and	#15,d0
	mulu	d0,d2
	lsr	#7,d2
	move	n_period(a6),d0
	tst.b	n_vibratopos(a6)
	bmi.b	mt_vibratoneg
	add	d2,d0
	bra.b	mt_vibrato3
mt_vibratoneg
	sub	d2,d0
mt_vibrato3
	lsl	#2,d0
	move	d0,mPeriod(a5)
	move.b	n_vibratocmd(a6),d0
	lsr	#2,d0
	and	#$3c,d0
	add.b	d0,n_vibratopos(a6)
	rts

mt_toneplusvolslide
	bsr	mt_toneportnochange
	bra	mt_volumeslide

mt_vibratoplusvolslide
	bsr.b	mt_vibrato2
	bra	mt_volumeslide

mt_tremolo
	move.b	n_cmdlo(a6),d0
	beq.b	mt_tremolo2
	move.b	n_tremolocmd(a6),d2
	and.b	#$f,d0
	beq.b	mt_treskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_treskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.b	mt_treskip2
	and.b	#$f,d2
	or.b	d0,d2
mt_treskip2
	move.b	d2,n_tremolocmd(a6)
mt_tremolo2
	move.b	n_tremolopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr	#2,d0
	and	#$1f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	lsr.b	#4,d2
	and.b	#3,d2
	beq.b	mt_tre_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.b	mt_tre_rampdown
	move.b	#255,d2
	bra.b	mt_tre_set
mt_tre_rampdown
	tst.b	n_vibratopos(a6)
	bpl.b	mt_tre_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.b	mt_tre_set
mt_tre_rampdown2
	move.b	d0,d2
	bra.b	mt_tre_set
mt_tre_sine
	move.b	0(a4,d0),d2
mt_tre_set
	move.b	n_tremolocmd(a6),d0
	and	#15,d0
	mulu	d0,d2
	lsr	#6,d2
	moveq	#0,d0
	move.b	n_volume(a6),d0
	tst.b	n_tremolopos(a6)
	bmi.b	mt_tremoloneg
	add	d2,d0
	bra.b	mt_tremolo3
mt_tremoloneg
	sub	d2,d0
mt_tremolo3
	bpl.b	mt_tremoloskip
	clr	d0
mt_tremoloskip
	cmp	#$40,d0
	bls.b	mt_tremolook
	move	#$40,d0
mt_tremolook
	move	d0,mVolume(a5)
	move.b	n_tremolocmd(a6),d0
	lsr	#2,d0
	and	#$3c,d0
	add.b	d0,n_tremolopos(a6)
	rts

mt_sampleoffset
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	beq.b	mt_sononew
	move.b	d0,n_sampleoffset(a6)
mt_sononew
	move.b	n_sampleoffset(a6),d0
	lsl	#7,d0
	cmp	n_length(a6),d0
	bge.b	mt_sofskip
	sub	d0,n_length(a6)
	lsl	#1,d0
	add.l	d0,n_start(a6)
	rts
mt_sofskip
	move	#1,n_length(a6)
	rts

mt_volumeslide
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.b	mt_volslidedown
mt_volslideup
	add.b	d0,n_volume(a6)
	cmp.b	#$40,n_volume(a6)
	bmi.b	mt_vsuskip
	move.b	#$40,n_volume(a6)
mt_vsuskip
	move.b	n_volume(a6),d0
	move.b	d0,mVolume+1(a5)
	rts

mt_volslidedown
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
mt_volslidedown2
	sub.b	d0,n_volume(a6)
	bpl.b	mt_vsdskip
	clr.b	n_volume(a6)
mt_vsdskip
	move.b	n_volume(a6),d0
	move	d0,mVolume(a5)
	rts

mt_positionjump
	move.b	n_cmdlo(a6),d0
	cmp.b	mt_songpos(pc),d0
	bhi.b	.e
	st	PS3M_break

.e	subq.b	#1,d0
	move.b	d0,mt_songpos
mt_pj2	clr.b	mt_pbreakpos
	st 	mt_posjumpflag
	rts

mt_volumechange
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	cmp.b	#$40,d0
	bls.b	mt_volumeok
	moveq	#$40,d0
mt_volumeok
	move.b	d0,n_volume(a6)
	move	d0,mVolume(a5)
	rts

mt_patternbreak
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	move.l	d0,d2
	lsr.b	#4,d0
	mulu	#10,d0
	and.b	#$f,d2
	add.b	d2,d0
	cmp.b	#63,d0
	bhi.b	mt_pj2
	move.b	d0,mt_pbreakpos
	st	mt_posjumpflag
	st	PS3M_poscha
	rts

mt_setspeed
	moveq	#0,d0
	move.b	3(a6),d0
	bne.b	.e
	st	PS3M_break
	bra.b	.q
.e	clr.b	mt_counter
	cmp	#32,d0
	bhs.b	mt_settempo
	move.b	d0,mt_speed
.q	rts

mt_settempo
	move.l	d1,-(sp)
	move.l	mrate,d1
	move.l	d1,d2
	lsl.l	#2,d1
	add.l	d2,d1
	add	d0,d0
	divu	d0,d1

	addq	#1,d1
	and	#~1,d1
	move	d1,bytesperframe
	move.l	(sp)+,d1
	rts

mt_checkmoreefx
	bsr	mt_updatefunk
	move.b	2(a6),d0
	and.b	#$f,d0
	cmp.b	#$9,d0
	beq	mt_sampleoffset
	cmp.b	#$b,d0
	beq	mt_positionjump
	cmp.b	#$d,d0
	beq	mt_patternbreak
	cmp.b	#$e,d0
	beq.b	mt_e_commands
	cmp.b	#$f,d0
	beq.b	mt_setspeed
	cmp.b	#$c,d0
	beq	mt_volumechange

	cmp	#mtMOD,mtype
	beq	mt_pernop

; MTM runs these also in set frames

	cmp.b	#1,d0
	beq	mt_portaup
	cmp.b	#2,d0
	beq	mt_portadown
	cmp.b	#3,d0
	beq	mt_toneportamento
	cmp.b	#4,d0
	beq	mt_vibrato
	cmp.b	#5,d0
	beq	mt_toneplusvolslide
	cmp.b	#6,d0
	beq	mt_vibratoplusvolslide
	bra	mt_pernop


mt_e_commands
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	lsr.b	#4,d0
;	beq.b	mt_filteronoff
	cmp.b	#1,d0
	beq	mt_fineportaup
	cmp.b	#2,d0
	beq	mt_fineportadown
	cmp.b	#3,d0
	beq.b	mt_setglisscontrol
	cmp.b	#4,d0
	beq	mt_setvibratocontrol
	cmp.b	#5,d0
	beq	mt_setfinetune
	cmp.b	#6,d0
	beq	mt_jumploop
	cmp.b	#7,d0
	beq	mt_settremolocontrol
	cmp.b	#9,d0
	beq	mt_retrignote
	cmp.b	#$a,d0
	beq	mt_volumefineup
	cmp.b	#$b,d0
	beq	mt_volumefinedown
	cmp.b	#$c,d0
	beq	mt_notecut
	cmp.b	#$d,d0
	beq	mt_notedelay
	cmp.b	#$e,d0
	beq	mt_patterndelay
	cmp.b	#$f,d0
	beq	mt_funkit
	rts

mt_filteronoff
	move.b	n_cmdlo(a6),d0
	and.b	#1,d0
	asl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts	

mt_setglisscontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	and.b	#$f0,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	rts

mt_setvibratocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	and.b	#$f0,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_setfinetune
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	move.b	d0,n_finetune(a6)
	rts

mt_jumploop
	tst.b	mt_counter
	bne	mt_return2
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	beq.b	mt_setloop
	tst.b	n_loopcount(a6)
	beq.b	mt_jumpcnt
	subq.b	#1,n_loopcount(a6)
	beq	mt_return2
mt_jmploop
	move.b	n_pattpos(a6),mt_pbreakpos
	st	mt_pbreakflag
	rts

mt_jumpcnt
	move.b	d0,n_loopcount(a6)
	bra.b	mt_jmploop

mt_setloop
	move	mt_patternpos(pc),d0
	lsr	#4,d0
	move.b	d0,n_pattpos(a6)
	rts

mt_settremolocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	lsl.b	#4,d0
	and.b	#$f,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_retrignote
	move.l	d1,-(sp)
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	beq.b	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
	bne.b	mt_rtnskp
	move	(a6),d1
	and	#$fff,d1
	bne.b	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
mt_rtnskp
	divu	d0,d1
	swap	d1
	tst	d1
	bne.b	mt_rtnend
mt_doretrig
	move.l	n_start(a6),(a5)	; set start
	moveq	#0,d1
	move	n_length(a6),d1
	add.l	d1,d1
	move	d1,mLength(a5)		; set length
	clr.b	mOnOff(a5)		; turn on
	clr.l	mFPos(a5)		; retrig

	move.l	n_loopstart(a6),mLStart(a5)
	moveq	#0,d1
	move	n_replen(a6),d1
	add.l	d1,d1
	move.l	d1,mLLength(a5)
	cmp.l	#2,mLLength(a5)
	bls.b	.eloo
	st	mLoop(a5)
	move.l	(sp)+,d1
	rts
.eloo	clr.b	mLoop(a5)

mt_rtnend
	move.l	(sp)+,d1
	rts

mt_volumefineup
	tst.b	mt_counter
	bne	mt_return2
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	bra	mt_volslideup

mt_volumefinedown
	tst.b	mt_counter
	bne	mt_return2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	bra	mt_volslidedown2

mt_notecut
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	cmp.b	mt_counter(pc),d0
	bne	mt_return2
	clr.b	n_volume(a6)
	clr	mVolume(a5)
	rts

mt_notedelay
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	cmp.b	mt_counter(pc),d0
	bne	mt_return2
	move	(a6),d0
	beq	mt_return2

	move	n_period(a6),d0
	lsl	#2,d0
	move	d0,mPeriod(a5)		; set period
	move.l	d1,-(sp)
	bra	mt_doretrig

mt_patterndelay
	tst.b	mt_counter
	bne	mt_return2
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	tst.b	mt_pattdeltime2
	bne	mt_return2
	addq.b	#1,d0
	move.b	d0,mt_pattdeltime
	rts

mt_funkit
	tst.b	mt_counter
	bne	mt_return2
	move.b	n_cmdlo(a6),d0
	lsl.b	#4,d0
	and.b	#$f,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	tst.b	d0
	beq	mt_return2
mt_updatefunk
	movem.l	a0/d1,-(sp)
	moveq	#0,d0
	move.b	n_glissfunk(a6),d0
	lsr.b	#4,d0
	beq.b	mt_funkend
	lea	mt_funktable(pc),a0
	move.b	(a0,d0),d0
	add.b	d0,n_funkoffset(a6)
	btst	#7,n_funkoffset(a6)
	beq.b	mt_funkend
	clr.b	n_funkoffset(a6)

	move.l	n_loopstart(a6),d0
	moveq	#0,d1
	move	n_replen(a6),d1
	add.l	d1,d0
	add.l	d1,d0
	move.l	n_wavestart(a6),a0
	addq.l	#1,a0
	cmp.l	d0,a0
	blo.b	mt_funkok
	move.l	n_loopstart(a6),a0
mt_funkok
	move.l	a0,n_wavestart(a6)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
mt_funkend
	movem.l	(sp)+,a0/d1
	rts


mt_funktable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_vibratotable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_periodtable
; tuning 0, normal
	dc	856,808,762,720,678,640,604,570,538,508,480,453
	dc	428,404,381,360,339,320,302,285,269,254,240,226
	dc	214,202,190,180,170,160,151,143,135,127,120,113
; tuning 1
	dc	850,802,757,715,674,637,601,567,535,505,477,450
	dc	425,401,379,357,337,318,300,284,268,253,239,225
	dc	213,201,189,179,169,159,150,142,134,126,119,113
; tuning 2
	dc	844,796,752,709,670,632,597,563,532,502,474,447
	dc	422,398,376,355,335,316,298,282,266,251,237,224
	dc	211,199,188,177,167,158,149,141,133,125,118,112
; tuning 3
	dc	838,791,746,704,665,628,592,559,528,498,470,444
	dc	419,395,373,352,332,314,296,280,264,249,235,222
	dc	209,198,187,176,166,157,148,140,132,125,118,111
; tuning 4
	dc	832,785,741,699,660,623,588,555,524,495,467,441
	dc	416,392,370,350,330,312,294,278,262,247,233,220
	dc	208,196,185,175,165,156,147,139,131,124,117,110
; tuning 5
	dc	826,779,736,694,655,619,584,551,520,491,463,437
	dc	413,390,368,347,328,309,292,276,260,245,232,219
	dc	206,195,184,174,164,155,146,138,130,123,116,109
; tuning 6
	dc	820,774,730,689,651,614,580,547,516,487,460,434
	dc	410,387,365,345,325,307,290,274,258,244,230,217
	dc	205,193,183,172,163,154,145,137,129,122,115,109
; tuning 7
	dc	814,768,725,684,646,610,575,543,513,484,457,431
	dc	407,384,363,342,323,305,288,272,256,242,228,216
	dc	204,192,181,171,161,152,144,136,128,121,114,108
; tuning -8
	dc	907,856,808,762,720,678,640,604,570,538,508,480
	dc	453,428,404,381,360,339,320,302,285,269,254,240
	dc	226,214,202,190,180,170,160,151,143,135,127,120
; tuning -7
	dc	900,850,802,757,715,675,636,601,567,535,505,477
	dc	450,425,401,379,357,337,318,300,284,268,253,238
	dc	225,212,200,189,179,169,159,150,142,134,126,119
; tuning -6
	dc	894,844,796,752,709,670,632,597,563,532,502,474
	dc	447,422,398,376,355,335,316,298,282,266,251,237
	dc	223,211,199,188,177,167,158,149,141,133,125,118
; tuning -5
	dc	887,838,791,746,704,665,628,592,559,528,498,470
	dc	444,419,395,373,352,332,314,296,280,264,249,235
	dc	222,209,198,187,176,166,157,148,140,132,125,118
; tuning -4
	dc	881,832,785,741,699,660,623,588,555,524,494,467
	dc	441,416,392,370,350,330,312,294,278,262,247,233
	dc	220,208,196,185,175,165,156,147,139,131,123,117
; tuning -3
	dc	875,826,779,736,694,655,619,584,551,520,491,463
	dc	437,413,390,368,347,328,309,292,276,260,245,232
	dc	219,206,195,184,174,164,155,146,138,130,123,116
; tuning -2
	dc	868,820,774,730,689,651,614,580,547,516,487,460
	dc	434,410,387,365,345,325,307,290,274,258,244,230
	dc	217,205,193,183,172,163,154,145,137,129,122,115
; tuning -1
	dc	862,814,768,725,684,646,610,575,543,513,484,457
	dc	431,407,384,363,342,323,305,288,272,256,242,228
	dc	216,203,192,181,171,161,152,144,136,128,121,114


mtm_periodtable
; Tuning 0, Normal
	dc	1616,1524,1440,1356,1280,1208,1140,1076,1016,960,907
	dc	856,808,762,720,678,640,604,570,538,508,480,453
	dc	428,404,381,360,339,320,302,285,269,254,240,226
	dc	214,202,190,180,170,160,151,143,135,127,120,113
	dc	107,101,95,90,85,80,75,71,67,63,60,56
	dc	53,50,48,45

; Tuning 1
	dc	1604,1514,1430,1348,1274,1202,1134,1070,1010,954,900
	dc	850,802,757,715,674,637,601,567,535,505,477,450
	dc	425,401,379,357,337,318,300,284,268,253,239,225
	dc	213,201,189,179,169,159,150,142,134,126,119,113
	dc	106,100,94,89,84,80,75,71,67,63,59,56
	dc	53,50,47,45

; Tuning 2
	dc	1592,1504,1418,1340,1264,1194,1126,1064,1004,948,894
	dc	844,796,752,709,670,632,597,563,532,502,474,447
	dc	422,398,376,355,335,316,298,282,266,251,237,224
	dc	211,199,188,177,167,158,149,141,133,125,118,112
	dc	105,99,94,88,83,79,74,70,66,62,59,56
	dc	53,50,47,44

; Tuning 3
	dc	1582,1492,1408,1330,1256,1184,1118,1056,996,940,888
	dc	838,791,746,704,665,628,592,559,528,498,470,444
	dc	419,395,373,352,332,314,296,280,264,249,235,222
	dc	209,198,187,176,166,157,148,140,132,125,118,111
	dc	104,99,93,88,83,78,74,70,66,62,59,55
	dc	52,49,47,44

; Tuning 4
	dc	1570,1482,1398,1320,1246,1176,1110,1048,990,934,882
	dc	832,785,741,699,660,623,588,555,524,495,467,441
	dc	416,392,370,350,330,312,294,278,262,247,233,220
	dc	208,196,185,175,165,156,147,139,131,124,117,110
	dc	104,98,92,87,82,78,73,69,65,62,58,55
	dc	52,49,46,44

; Tuning 5
	dc	1558,1472,1388,1310,1238,1168,1102,1040,982,926,874
	dc	826,779,736,694,655,619,584,551,520,491,463,437
	dc	413,390,368,347,328,309,292,276,260,245,232,219
	dc	206,195,184,174,164,155,146,138,130,123,116,109
	dc	103,97,92,87,82,77,73,69,65,61,58,54
	dc	52,49,46,43

; Tuning 6
	dc	1548,1460,1378,1302,1228,1160,1094,1032,974,920,868
	dc	820,774,730,689,651,614,580,547,516,487,460,434
	dc	410,387,365,345,325,307,290,274,258,244,230,217
	dc	205,193,183,172,163,154,145,137,129,122,115,109
	dc	102,97,91,86,81,77,72,68,64,61,57,54
	dc	51,48,46,43

; Tuning 7
	dc	1536,1450,1368,1292,1220,1150,1086,1026,968,914,862
	dc	814,768,725,684,646,610,575,543,513,484,457,431
	dc	407,384,363,342,323,305,288,272,256,242,228,216
	dc	204,192,181,171,161,152,144,136,128,121,114,108
	dc	102,96,91,85,81,76,72,68,64,60,57,54
	dc	51,48,45,43

; Tuning -8
	dc	1712,1616,1524,1440,1356,1280,1208,1140,1076,1016,960
	dc	907,856,808,762,720,678,640,604,570,538,508,480
	dc	453,428,404,381,360,339,320,302,285,269,254,240
	dc	226,214,202,190,180,170,160,151,143,135,127,120
	dc	113,107,101,95,90,85,80,75,71,67,63,60
	dc	56,53,50,48

; Tuning -7
	dc	1700,1604,1514,1430,1350,1272,1202,1134,1070,1010,954
	dc	900,850,802,757,715,675,636,601,567,535,505,477
	dc	450,425,401,379,357,337,318,300,284,268,253,238
	dc	225,212,200,189,179,169,159,150,142,134,126,119
	dc	112,106,100,94,89,84,79,75,71,67,63,60
	dc	56,53,50,47

; Tuning -6
	dc	1688,1592,1504,1418,1340,1264,1194,1126,1064,1004,948
	dc	894,844,796,752,709,670,632,597,563,532,502,474
	dc	447,422,398,376,355,335,316,298,282,266,251,237
	dc	223,211,199,188,177,167,158,149,141,133,125,118
	dc	112,105,99,94,89,84,79,75,70,66,63,59
	dc	56,53,50,47

; Tuning -5
	dc	1676,1582,1492,1408,1330,1256,1184,1118,1056,996,940
	dc	887,838,791,746,704,665,628,592,559,528,498,470
	dc	444,419,395,373,352,332,314,296,280,264,249,235
	dc	222,209,198,187,176,166,157,148,140,132,125,118
	dc	111,105,99,93,88,83,78,74,70,66,62,59
	dc	55,52,49,47

; Tuning -4
	dc	1664,1570,1482,1398,1320,1246,1176,1110,1048,988,934
	dc	881,832,785,741,699,660,623,588,555,524,494,467
	dc	441,416,392,370,350,330,312,294,278,262,247,233
	dc	220,208,196,185,175,165,156,147,139,131,123,117
	dc	110,104,98,93,87,82,78,73,69,65,62,58
	dc	55,52,49,46

; Tuning -3
	dc	1652,1558,1472,1388,1310,1238,1168,1102,1040,982,926
	dc	875,826,779,736,694,655,619,584,551,520,491,463
	dc	437,413,390,368,347,328,309,292,276,260,245,232
	dc	219,206,195,184,174,164,155,146,138,130,123,116
	dc	109,103,97,92,87,82,77,73,69,65,61,58
	dc	55,52,49,46

; Tuning -2
	dc	1640,1548,1460,1378,1302,1228,1160,1094,1032,974,920
	dc	868,820,774,730,689,651,614,580,547,516,487,460
	dc	434,410,387,365,345,325,307,290,274,258,244,230
	dc	217,205,193,183,172,163,154,145,137,129,122,115
	dc	108,102,97,91,86,81,77,72,68,64,61,57
	dc	54,51,48,46

; Tuning -1
	dc	1628,1536,1450,1368,1292,1220,1150,1086,1026,968,914
	dc	862,814,768,725,684,646,610,575,543,513,484,457
	dc	431,407,384,363,342,323,305,288,272,256,242,228
	dc	216,203,192,181,171,161,152,144,136,128,121,114
	dc	108,102,96,91,85,81,76,72,68,64,60,57
	dc	54,51,48,45

mt_chan1temp	ds.b	44*32

mt_sampleinfos
	ds	31*12

mt_songdataptr	dc.l 0

mt_speed	dc.b 6
mt_tempo	dc.b 0
mt_counter	dc.b 0
mt_songpos	dc.b 0
mt_pbreakpos	dc.b 0
mt_posjumpflag	dc.b 0
mt_pbreakflag	dc.b 0
mt_lowmask	dc.b 0
mt_pattdeltime	dc.b 0
mt_pattdeltime2	dc.b 0

mt_patternpos	dc 0
mt_dmacontemp	dc 0



; PLAYING PROCESSES
; ญญญญญญญญญญญญญญญญญ

	section	system,code
syss3mPlay
	movem.l	d0-a6,-(sp)
	lea	data,a5
	basereg	data,a5
	
	lea	$dff000,a6
	move	#$f,$96(a6)

	move.l	4.w,a6

	if	allocchans
	moveq	#-1,d0
	CALL	AllocSignal
	move.b	d0,sigbit(a5)
	bmi	exiz

	lea	allocport(a5),a1
	move.b	d0,15(a1)
	move.l	a1,-(sp)
	suba.l	a1,a1
	CALL	FindTask
	move.l	(sp)+,a1
	move.l	d0,16(a1)
	lea	reqlist(a5),a0
	move.l	a0,(a0)
	addq.l	#4,(a0)
	clr.l	4(a0)
	move.l	a0,8(a0)

	lea	allocreq(a5),a1
	lea	audiodev(a5),a0
	moveq	#0,d0
	moveq	#0,d1
	CALL	OpenDevice
	tst.b	d0
	bne	exiz
	st.b	audioopen(a5)

	endc

	lea	lev4int(a5),a1
	moveq	#INTB_AUD0,d0
	CALL	SetIntVector
	move.l	d0,olev4(a5)

	move.l	_GFXBase(a5),a2
	move.l	a2,-(sp)

	move.b	PowerSupplyFrequency(a6),d0
	cmp.b	#60,d0
	beq.b	.NTSC

.PAL	move.l	#3546895,audiorate(a5)
	move.l	#1773447,timer(a5)
	bra.b	.qw

.NTSC	move	gb_DisplayFlags(a2),d0
	btst	#4,d0				; REALLY_PAL
	bne.b	.PAL				; Just to be sure

	move.l	#3579545,audiorate(a5)
	move.l	#1789773,timer(a5)
.qw
	move.l	timer(a5),d0
	divu	#250,d0				; 100 Hz
	move	d0,thi(a5)

	move.l	audiorate(a5),d0
	move.l	mixingrate(a5),d1
	divu	d1,d0
	move.l	audiorate(a5),d1
	divu	d0,d1
	swap	d1
	clr	d1
	swap	d1
	move.l	d1,mrate(a5)

	move.l	audiorate(a5),d0
	divu	d1,d0
	swap	d0
	clr	d0
	swap	d0
	move.l	d0,mixingperiod(a5)

	lsl.l	#8,d1				; 8-bit fraction
	move.l	d1,d0
	moveq	#100,d1
	jsr	divu_32
	move.l	d0,mrate50(a5)			;In fact vblankfrequency

	moveq	#0,d3
	lea	cianame(a5),a1
	move.b	#'b',3(a1)
openciares
	moveq	#0,d0
	CLIB	Exec,OpenResource
	move.l	d0,ciares(a5)
	beq.b	tryCIAA
	move.l	d0,a6
	lea	timerinterrupt(a5),a1
	moveq	#0,d0
	CALL	AddICRVector
	tst.l	d0
	beq.b	gottimer
	addq.l	#4,d3
	lea	timerinterrupt(a5),a1
	moveq	#1,d0
	CALL	AddICRVector
	tst.l	d0
	beq.b	gottimer
tryCIAA
	lea	cianame(a5),a1
	cmp.b	#'b',3(a1)
	bne	exits
	subq.b	#1,3(a1)
	moveq	#8,d3
	bra.b	openciares

ciaaddr		dc.l	$bfd500,$bfd700,$bfe501,$bfe701

gottimer
	lea	craddr+8(a5),a6
	move.l	ciaaddr(pc,d3),d0
	move.l	d0,(a6)
	sub	#$100,d0
	move.l	d0,-(a6)
	moveq	#2,d3
	btst	#9,d0
	bne.b	timerB
	subq.b	#1,d3
	add	#$100,d0
timerB
	add	#$900,d0
	move.l	d0,-(a6)
	move.l	d0,a0
	and.b	#%10000000,(a0)
	move.b	d3,timeropen(a5)
	moveq	#0,d0

	move.l	craddr+4(a5),a1
	move.b	tlo(a5),(a1)
	move.b	thi(a5),$100(a1)
	move.b	#$11,(a0)			; Continuous, force load

	move.l	mixingperiod(a5),d0

	lea	$dff000,a6
	move.l	buffSize(a5),d1
	lsr.l	#1,d1
	move	d1,$a4(a6)
	move	d1,$b4(a6)
	move	d1,$c4(a6)
	move	d1,$d4(a6)
	move	d0,$a6(a6)
	move	d0,$b6(a6)
	move	d0,$c6(a6)
	move	d0,$d6(a6)

	movem.l	buff1(a5),a0-a3
	moveq	#64,d1

	move	pmode(a5),d0
	subq	#1,d0
	bne.b	.nosurround

	moveq	#32,d2

	move.l	a0,$a0(a6)
	move.l	a1,$b0(a6)
	move.l	a0,$c0(a6)
	move.l	a1,$d0(a6)
	move	d1,$a8(a6)
	move	d1,$b8(a6)
	move	d2,$c8(a6)
	move	d2,$d8(a6)
	bra	.ohiis

.nosurround
	subq	#1,d0
	bne.b	.nostereo

	move.l	a0,$a0(a6)
	move.l	a1,$b0(a6)
	move.l	a1,$c0(a6)
	move.l	a0,$d0(a6)
	move	d1,$a8(a6)
	move	d1,$b8(a6)
	move	d1,$c8(a6)
	move	d1,$d8(a6)
	bra	.ohiis

.nostereo
	subq	#1,d0
	bne.b	.nomono

	move.l	a0,$a0(a6)
	move.l	a1,$b0(a6)
	move.l	a0,$c0(a6)
	move.l	a1,$d0(a6)
	move	d1,$a8(a6)
	move	d1,$b8(a6)
	move	d1,$c8(a6)
	move	d1,$d8(a6)
	bra.b	.ohiis

.nomono

; REAL SURROUND

	subq	#1,d0
	bne.b	.bit14

	move.l	a0,$a0(a6)
	move.l	a2,$b0(a6)
	move.l	a3,$c0(a6)
	move.l	a1,$d0(a6)

	move	d1,$a8(a6)
	move	d1,$b8(a6)
	move	d1,$c8(a6)
	move	d1,$d8(a6)
	bra.b	.ohiis


; 14-BIT STEREO

.bit14	moveq	#1,d2

	move.l	a0,$a0(a6)
	move.l	a1,$b0(a6)
	move.l	a3,$c0(a6)
	move.l	a2,$d0(a6)
	move	d1,$a8(a6)
	move	d1,$b8(a6)
	move	d2,$c8(a6)
	move	d2,$d8(a6)

.ohiis	jsr	FinalInit

	lea	$dff000,a6
	move	#$80,$9c(a6)
	move	#$c080,$9a(a6)
	move	#$820f,$96(a6)
	clr.l	playpos

syncz	move.l	(sp),a6
	CALL	WaitTOF

	lea	$dff000,a6
	jsr	play

	tst	PS3M_eject
	beq.b	syncz

exits	lea	$dff000,a6
	move	#$f,$96(a6)
	clr	$a8(a6)
	clr	$b8(a6)
	clr	$c8(a6)
	clr	$d8(a6)
	move	#$80,$9c(a6)
	move	#$80,$9a(a6)

	addq.l	#4,sp				; Flush GFXbase

	move.l	olev4(a5),a1
	moveq	#INTB_AUD0,d0
	CLIB	Exec,SetIntVector

exiz	lea	data,a5
	moveq	#0,d0
	move.b	timeropen(a5),d0
	beq.b	rem1
	move.l	ciares(a5),a6
	lea	timerinterrupt(a5),a1
	subq.b	#1,d0
	CALL	RemICRVector

rem1	move.l	4.w,a6
	tst.b	audioopen(a5)
	beq.b	rem2
	lea	allocreq(a5),a1
	CALL	CloseDevice

rem2	moveq	#0,d0
	move.b	sigbit(a5),d0
	bmi.b	rem3
	CALL	FreeSignal

rem3	CALL	Forbid
	clr	PS3M_wait(a5)
	movem.l	(sp)+,d0-a6
	moveq	#0,d0			;No error code
	rts

*************

	section	killer,code
s3mPlay	movem.l	d0-a6,-(sp)
	lea	data,a5
	move	$dff002,-(sp)		;Old DMAs

	move.l	_GFXBase(a5),a6
	move.l	34(a6),-(sp)		;Old view
	move.l	a6,-(sp)
	sub.l	a1,a1
	CALL	LoadView
	CALL	WaitTOF
	CALL	WaitTOF

	lea	$dff000,a6
	wb
	move	$1c(a6),d1
.irqs	move	$1e(a6),d0		;Wait for all IRQs to finish...
	and	d1,d0			;before killing the system...
	bne.b	.irqs			;Over safety you might think, but...

	move	#$7ff,$96(a6)		;Disable DMAs
	move	#$8200,$96(a6)		;Enable master DMA
	move	$1c(a6),-(sp)		;Old IRQs
	move	#$7fff,$9a(a6)		;Disable IRQs

	move.l	4.w,a6
	move.b	PowerSupplyFrequency(a6),d0
	cmp.b	#60,d0
	beq.b	.NTSC
	move.l	#3546895,audiorate(a5)
	bra.b	.qw
.NTSC
	move.l	#3579545,audiorate(a5)
.qw
	move.l	audiorate(a5),d0
	move.l	mixingrate(a5),d1
	divu	d1,d0
	move.l	audiorate(a5),d1
	divu	d0,d1
	swap	d1
	clr	d1
	swap	d1
	move.l	d1,mrate(a5)

	move.l	audiorate(a5),d0
	divu	d1,d0

	swap	d0
	clr	d0
	swap	d0
	move.l	d0,mixingperiod(a5)

	lsl.l	#8,d1				; 8-bit fraction
	move.l	d1,d0
	move.l	4.w,a6
	moveq	#0,d1
	move.b	VBlankFrequency(a6),d1
	jsr	divu_32
	move.l	d0,mrate50(a5)			;In fact vblank frequency

	movem.l	buff1(a5),a0-a3
	move.l	mixingperiod(a5),d0

	lea	$dff000,a6
	move.l	buffSize(a5),d1
	lsr.l	#1,d1
	move	d1,$a4(a6)
	move	d1,$b4(a6)
	move	d1,$c4(a6)
	move	d1,$d4(a6)
	move	d0,$a6(a6)
	move	d0,$b6(a6)
	move	d0,$c6(a6)
	move	d0,$d6(a6)

	moveq	#64,d1

	move	pmode(a5),d0
	subq	#1,d0
	bne.b	.nosurround

	moveq	#32,d2

	move.l	a0,$a0(a6)
	move.l	a1,$b0(a6)
	move.l	a0,$c0(a6)
	move.l	a1,$d0(a6)
	move	d1,$a8(a6)
	move	d1,$b8(a6)
	move	d2,$c8(a6)
	move	d2,$d8(a6)
	bra	.ohiis

.nosurround
	subq	#1,d0
	bne.b	.nostereo

	move.l	a0,$a0(a6)
	move.l	a1,$b0(a6)
	move.l	a1,$c0(a6)
	move.l	a0,$d0(a6)
	move	d1,$a8(a6)
	move	d1,$b8(a6)
	move	d1,$c8(a6)
	move	d1,$d8(a6)
	bra.b	.ohiis

.nostereo
	subq	#1,d0
	bne.b	.nomono

	move.l	a0,$a0(a6)
	move.l	a1,$b0(a6)
	move.l	a0,$c0(a6)
	move.l	a1,$d0(a6)
	move	d1,$a8(a6)
	move	d1,$b8(a6)
	move	d1,$c8(a6)
	move	d1,$d8(a6)
	bra.b	.ohiis

.nomono

; REAL SURROUND!

	subq	#1,d0
	bne.b	.bit14

	move.l	a0,$a0(a6)
	move.l	a1,$b0(a6)
	move.l	a2,$c0(a6)
	move.l	a3,$d0(a6)
	move	d1,$a8(a6)
	move	d1,$b8(a6)
	move	d1,$c8(a6)
	move	d1,$d8(a6)
	bra.b	.ohiis


; 14-BIT STEREO

.bit14	moveq	#1,d2

	move.l	a0,$a0(a6)
	move.l	a1,$b0(a6)
	move.l	a3,$c0(a6)
	move.l	a2,$d0(a6)
	move	d1,$a8(a6)
	move	d1,$b8(a6)
	move	d2,$c8(a6)
	move	d2,$d8(a6)

.ohiis	move.l	4.w,a6
	moveq	#0,d0
	btst	d0,AttnFlags(a6)
	beq.b	.no68010

	Push	a5
	lea	liko(pc),a5
	CALL	Supervisor
	Pull	a5
.no68010
	move.l	d0,vbrr(a5)

	Push	a5
	jsr	FinalInit
	Pull	a5

	lea	$dff000,a6
	move.l	vbrr(a5),a0
	move.l	$70(a0),olev4(a5)
	move.l	#lev4,$70(a0)
	move.l	$6c(a0),olev3(a5)
	move.l	#lev3,$6c(a0)
	move	#$800f,$96(a6)

	move	#$80+$20,$9c(a6)
	move	#$c080+$20,$9a(a6)

sync	move	#4,$180(a6)
	jsr	play

	lea	$dff000,a6
	move	#$5a,$180(a6)
	btst	#6,$bfe001
	bne.b	sync

exitz	move	#$f00,$180(a6)
	move	#$7fff,$9a(a6)		;Restore system status
	move	#$7ff,$96(a6)
	move	#$7fff,$9c(a6)		;Clear possible IRQ-requests (4 safety)

	move.l	vbrr(a5),a0
	move.l	olev4(a5),$70(a0)	;Restore IRQ-vectors
	move.l	olev3(a5),$6c(a0)

.q	btst	#6,$bfe001
	beq.b	.q

	move	(sp)+,d7		;Old IRQs

	move.l	(sp)+,a6		;Old gfxbase
	move.l	(sp)+,a1		;Old view

	lea	$dff000,a0
	move	#$ff0,$180(a0)		;!!! debug color

	or	#$8000,d7
	and	#~$780,d7		;And off Audio IRQs (for safety again)
	move	d7,$9a(a0)		;Old IRQs

	move	(sp)+,d7		;Old DMAs
	or	#$8000,d7
	and	#~$f,d7			;And off Audio DMAs (convenience...)
	move	d7,$96(a0)

	clr	$a8(a0)			;Volumes down...
	clr	$b8(a0)
	clr	$c8(a0)
	clr	$d8(a0)

	move	#$ff,$180(a0)		;!!! debug color2

	CALL	LoadView		;Old view
	move.l	38(a6),d3		;Old Copper1
	move.l	d3,$dff080		;Set old Copper
	move	d3,$dff088		;Trigger

	movem.l	(sp)+,d0-a6
	moveq	#0,d0			;No error code
	move	#$f0,$dff000		;Safe! (Hopefully...)
	rts

liko	ifeq	disable020
	MOVEC	VBR,d0
	endc
	rte


*******

;*** Datas ***


	section	datas,data
data

lev4int		dc.l	0,0
		dc.b	NT_INTERRUPT,127
		dc.l	l4name
		dc.l	playpos
		dc.l	slev4

timerinterrupt 	dc.l	0,0
		dc.b	NT_INTERRUPT,127
		dc.l	timerint
		dc.l	playpos
		dc.l	lev6server

vbrr		dc.l	0
olev4		dc.l	0
olev3		dc.l	0
vtabaddr	dc.l	0
playpos		dc.l	0
bufpos		dc.l	0
buffSize	dc.l	BUFFER
buffSizeMask	dc.l	BUFFER-1

bytesperframe	dc	0
bytes2do	dc	0
todobytes	dc	0
bytes2music	dc	0
	ifne	debug
kalas		dc.l	$c70000
	endc

mixad1		dc.l	0
mixad2		dc.l	0
cbufad		dc.l	0
opt020		dc	0

mixingrate	dc.l	16000
mixingperiod	dc.l	0
vboost		dc.l	0
pmode		dc	SURROUND
system		dc	DISABLED

PS3M_play	dc	0
PS3M_break	dc	0
PS3M_poscha	dc	0
PS3M_position	dc	0
PS3M_master	dc	64
PS3M_eject	dc	0
PS3M_wait	dc	0
PS3M_cont	dc	0
PS3M_paused	dc	0
PS3M_initialized dc	0
PS3M_reinit	dc	0

audiorate	dc.l	0
mrate		dc.l	0
mrate50		dc.l	0

slen		dc	0
pats		dc	0
inss		dc	0

samples		dc.l	0
patts		dc.l	0

fformat		dc	0
sflags		dc	0

rows		dc	63
spd		dc	6
tempo		dc	125

cn		dc	0
pbflag		dc	0
pdelaycnt	dc.b	0
ploopcnt	dc.b	0

chans		dc	0
numchans	dc	0
maxchan		dc	0
mtype		dc	0			
clock		dc.l	0			; 14317056/4 for S3Ms
globalVol	dc	0

pos		dc	0
plen		dc	0
ppos		dc.l	0

divtabs		ds.l	16

c0		ds.b	s3mChanBlock_SIZE*32

cha0		ds.b	mChanBlock_SIZE*32

pantab		ds.b	32			;channel panning infos


s3m		dc.l	0
s3mlen		dc.l	0

buff1		dc.l	0
buff2		dc.l	0
buff3		dc.l	0
buff4		dc.l	0
buff14		dc.l	0
vtab		dc.l	0
dtab		dc.l	0
dtabsize	dc.l	0

frate		dc.l	16000
fboost		dc.l	0
fpmode		dc	SURROUND
fstate		dc	DISABLED
forced		dc	0	; Bits:
				; 0 mixing rate
				; 1 volume boost
				; 2 playing mode
				; 3 system state

segment		dc.l	0
errorcode	dc.l	0
params		dc	0
bann		dc	0

config		dc.l	0
conlen		dc.l	0

buhku		dc.l	0
lock		dc.l	0

loadtags	dc.l	RTFI_OkText,loadtext
		dc.l	RTFI_Flags,0
		dc.l	0

diretags	dc.l	RTFI_Dir,0
		dc.l	0


reqptr		dc.l	0
variable	dc.l	0
noconf		dc	0
ssnpos		dc	0
tyhja		dc.l	0

tags		dc.l	RT_ReqPos,2
		dc.l	RTEZ_Flags,4
		dc.l	RTEZ_DefaultResponse
defaultresponse	dc.l	1
		dc.l	RTEZ_ReqTitle,winname
		dc.l	RT_Underscore,`_`
		dc.l	$8000000f,textattr
		dc.l	0

ltags		dc.l	RT_ReqPos,2
		dc.l	RTGL_Min,4000
		dc.l	RTGL_Max,56000
		dc.l	0

ltags2		dc.l	RT_ReqPos,2
		dc.l	RTGL_Min,0
		dc.l	RTGL_Max,8
		dc.l	0

mname		dc.l	0
var		dc.l	fname

XpkTags		dc.l	XPK_InName
XpkFN		dc.l	0
		dc.l	XPK_GetOutBuf
XpkTo		dc.l	0
		dc.l	XPK_GetOutBufLen
XpkFlen		dc.l	0
		dc.l	XPK_OutMemType
XpkMem		dc.l	2
		dc.l	XPK_PassThru,1
		dc.l	0


thi		dc.b	0
tlo		dc.b	0
timer		dc.l	0
ciares		dc.l	0
craddr		dc.l	0,0,0
timeropen	dc.b	0
		even

audioopen	dc.b	0
sigbit		dc.b	-1

dat		dc	$f00

allocport	dc.l	0,0
		dc.b	4,0
		dc.l	0
		dc.b	0,0
		dc.l	0
reqlist	dc.l	0,0,0
		dc.b	5,0

allocreq	dc.l	0,0
		dc	127
		dc.l	0
		dc.l	allocport
		dc	68
		dc.l	0,0,0
		dc	0
		dc.l	dat
		dc.l	1,0,0,0,0,0,0
		dc	0

xmsign		dc.b	`Extended Module:`
title7		dc.b	`Select module(s) to play:`,0
title6		dc.b	`Select module(s) to add:`,0
retry		dc.b	`Retry|Abort|Cancel`,0
winname		dc.b	`PS3M 3.10฿`,0
scrname		dc.b	`PS3M 3.10฿ - Copyright ฉ 1994-95 Jarno Paananen`,0
time		dc.b	`00:00`,0
playr		dc.b	`Play`,0
add		dc.b	`Add`,0

overtxt		dc.b	`Current settings:`,10
		dc.b	`ญญญญญญญญญญญญญญญญญ`,10
		dc.b	`Mixing rate: %ld`,10
		dc.b	`Volume boost: %ld`,10
		dc.b	`Playing mode: %s`,10
		dc.b	`System: %s`,10,10
		dc.b	`Change:`,0

overgad		dc.b	`_Rate|_Boost|_Mode|_System|to _Defaults|_Exit`,0

mratetitle	dc.b	`Mixing rate:`,0
vboosttitle	dc.b	`Volume boost:`,0
playmode	dc.b	`Select play mode:`,0
killer		dc.b	`Select system state:`,0

pmodeg		dc.b	`_Surround|S_tereo|_Mono|_Real Surround|_14-bit|Cancel`,0
killerg		dc.b	`_Disabled|_Enabled|Cancel`,0

_XpkName 	dc.b	`xpkmaster.library`,0
fontname	dc.b	`topaz.font`,0

loadtext	dc.b	`Load`,0

alkutext	dc.b 10
		dc.b `PS3M - The S3M Player`,10
		dc.b `ญญญญญญญญญญญญญญญญญญญญญ`,10
		VER
		sVER
		dc.b `Copyright ฉ 1994-95 Jarno Paananen`,10
		dc.b `ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ`,10,10
		dc.b `A Sahara Surfers (tm) Production!`,10
		dc.b `ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ`,10,10
		dc.b `All rights reserved`,10,10
		dc.b `- Dedicated to Anna and Kausti, Ones I love -`,10
		ifne beta
		dc.b 10,`BETA VERSION FOR INTERNAL USE ONLY!`,10
		dc.b `DO _NOT_ DISTRIBUTE!`,10
		endc
		dc.b 0

alkutext2	dc.b	10
		dc.b	`To contact me:`,10
		dc.b	`ญญญญญญญญญญญญญญ`,10
		dc.b	`Preferably via Internet:`,10
		dc.b	`jpaana@kauhajoki.fi`,10
		dc.b	`Jarno_Paananen@sonata.fipnet.fi`,10
		dc.b	`or jpaana@freenet.hut.fi`,10,10
		dc.b	`Or snail me at:`,10
		dc.b	`J.Paananen`,10
		dc.b	`Puskalantie 6`,10
		dc.b	`FIN-37120 Nokia`,10
		dc.b	`Finland`,10
		dc.b	`Europe ;)`,10,10
		dc.b	`Or by phone: +358-31-3422147`,10
		dc.b	`(18-22 EET, please!)`,10,0

outofmemory	dc.b	`Out of memory`,0
initerror	dc.b	`Initialization error`,10
		dc.b	`(Is it a module?)`,0

errorgadget	dc.b	`Understood`,0

infos		dc.b	`%ld-channel %s module:`,10
		dc.b	`%s (%s)`,10,10
		dc.b	`Mixing rate: %ld`,10
		dc.b	`Volume boost: %ld`,10
		dc.b	`Playing mode: %s`,10
		dc.b	`System: %s`,10
		dc.b	`Using %s mixing routines`,0

ssn		dc.b	10
		rept	16
		dc.b	`%-32.32s Len: %6.6ld`,10
		endr
		dc.b	0

ssn1		dc.b	`_<<|_Exit|_>>`,0
ssn2		dc.b	` |_Exit|_>>`,0
ssn3		dc.b	`_<<|_Exit| `,0
ssn4		dc.b	` |_Exit| `,0

contta		dc.b	`_Ok`,0
contta2		dc.b	`_Ok|_Contact|_Quit`,0
contta3		dc.b	`_Ok|_Sample names|_Mod Info|_Contact`,0
contta4		dc.b	`_Ok|_Contact`,0
timerint 	dc.b	`PS3M-Lev6`,0
l4name		dc.b	`PS3M-Lev4`,0

cianame		dc.b	`ciax.resource`,0
audiodev 	dc.b	`audio.device`,0

pro		dc.b	`Protracker`,0
fast		dc.b	`Fasttracker`,0
st3		dc.b	`Scream Tracker ]I[`,0
mtm		dc.b	`Multitracker`,0
xm		dc.b	`Fasttracker ][ XM`,0
configname	dc.b	`S:PS3M.config`,0
defaultsection	dc.b	`[defaults]`,0
directory	dc.b	`directory`,0
mxrate		dc.b	`rate`,0
boost		dc.b	`boost`,0
sstate		dc.b	`system`,0
plmode		dc.b	`mode`,0
bsize		dc.b	`buffersize`,0
banner		dc.b	`banner`,0
on		dc.b	`on`,0
off		dc.b	`off`,0
m000		dc.b	`000/010`,0
m020		dc.b	`020+`,0
surr		dc.b	`surround`,0
ster		dc.b	`stereo`,0
mon		dc.b	`mono`,0
real		dc.b	`real surround`,0
stereo14	dc.b	`14-bit stereo`,0
channelsection	dc.b	`[channels]`,0
tunesection	dc.b	`[tunes]`,0

		even

playtags	dc.l	RTFI_OkText,playr
		dc.l	RTFI_Flags,FREQF_MULTISELECT!FREQF_PATGAD
		dc.l	RT_TextAttr,textattr
		dc.l	0

addtags		dc.l	RTFI_OkText,add
		dc.l	RTFI_Flags,FREQF_MULTISELECT!FREQF_PATGAD
		dc.l	RT_TextAttr,textattr
		dc.l	0

textattr	dc.l	fontname
		dc	8,0

task		dc.l	0

positioneita	dc	1
signaali	dc.l	-1
progpos		dc	0
program		dc.l	0
maxfile		dc	0
topbor		dc	0
bar		dc	0
wbscr		dc.l	0
windowptr 	dc.l	0
rast		dc.l	0
winpoin		dc.l	0
_IntBase	dc.l	0
_GFXBase 	dc.l	0
_DOSBase 	dc.l	0
_PPBase 	dc.l	0
_RTBase 	dc.l	0
_XpkBase	dc.l	0
zoomstate	dc	0
dates		dc.l	0,0
fifties		dc.l	0

dates2		dc.l	0,0
fifties2 	dc.l	0

oldsec		dc.l	0
paivita		dc	0

timethisfar 	dc.l 0

winstr	dc	0,0,240,82
	dc.b	0,1
	dc.l	CLOSEWINDOW!GADGETUP!MOUSEBUTTONS!NEWSIZE!INTUITICKS
	dc.l	WINDOWDEPTH!WINDOWCLOSE!WINDOWDRAG!ACTIVATE!NOCAREREFRESH!SMART_REFRESH!RMBTRAP
	dc.l	0,0,winname,0,0,0,0
	dc	WBENCHSCREEN

******* Gadgets *******


gvolume	dc.l	position
	dc	55,-39,165,10,GADGHNONE!GRELBOTTOM,RELVERIFY
	dc	PROPGADGET
	dc.l	vbor,0,0,0,propspecial
	dc	0
	dc.l	0

position
	dc.l	dummy3
	dc	55,-59,165,10,GADGHNONE!GRELBOTTOM,RELVERIFY
	dc	PROPGADGET
	dc.l	vbor2,0,0,0,propspecial2
	dc	0
	dc.l	0

dummy3	dc.l	dummy4
	dc	54,-60,1,1,GADGHNONE!GRELBOTTOM,0,1
	dc.l	bgr,0,0,0,0
	dc	0
	dc.l	0

dummy4	dc.l	Name
	dc	54,-40,1,1,GADGHNONE!GRELBOTTOM,0,1
	dc.l	bgr,0,0,0,0
	dc	0
	dc.l	0

vtext	dc.b	1,0,1,0
	dc	3,3
	dc.l	textattr,teksti3,vtext2

vtext2	dc.b	2,0,0,0
	dc	4,2
	dc.l	textattr,teksti3,0


vtext3	dc.b	1,0,1,0
	dc	3,3
	dc.l	textattr,teksti2,vtext4

vtext4	dc.b	2,0,0,0
	dc	4,2
	dc.l	textattr,teksti2,0

vbor	dc	0,0
	dc.b	2,0,0,1
	dc.l	lines,0

vbor2	dc	0,0
	dc.b	2,0,0,1
	dc.l	lines,0

lines	dc	0,11

propspecial
	dc	AUTOKNOB!FREEHORIZ!PROPBORDERLESS!PROPNEWLOOK
	dc	-1,0
	dc	$ffff/64,-1
	dc.l	0,0,0

propspecial2
	dc	AUTOKNOB!FREEHORIZ!PROPBORDERLESS!PROPNEWLOOK
nyky	dc	0,0
positioosa
	dc	-1,-1
	dc.l	0,0,0

Name	dc.l	PosGad
	dc	20,-80,200,12,GADGHCOMP!GRELBOTTOM,1,1
	dc.l	Namegr,0,Namet3,0,0
	dc	0
	dc.l	0

PosGad	dc.l	Mute
	dc	20,-60,30,11,GADGHCOMP!GRELBOTTOM,1,1
	dc.l	gr,0,vtext3,0,0
	dc	0
	dc.l	0

Mute	dc.l	Pause
	dc	20,-40,30,11,GADGHCOMP!GRELBOTTOM,$101,1
	dc.l	gr,0,vtext,0,0
	dc	0
	dc.l	0

Pause	dc.l	Play
	dc	46,-20,28,13,12,$101,1
	dc.l	pausegr,0,0,0,0
	dc	0
	dc.l	0

Play	dc.l	Eject
	dc	16,-20,28,13,12,1,1
	dc.l	playgr,0,0,0,0
	dc	0
	dc.l	0

Eject	dc.l	Next
	dc	76,-20,28,13,12,1,1
	dc.l	Ejectgr,0,0,0,0
	dc	0
	dc.l	0

Next	dc.l	Prev
	dc	136,-20,28,13,12,1,1
	dc.l	nextgr,0,0,0,0
	dc	0
	dc.l	0

Prev	dc.l	Prefs
	dc	106,-20,28,13,12,1,1
	dc.l	prevgr,0,0,0,0
	dc	0
	dc.l	0

Prefs	dc.l	Prg
	dc	166,-20,28,13,12,1,1
	dc.l	prefsgr,0,0,0,0
	dc	0
	dc.l	0

Prg	dc.l	0
	dc	196,-20,28,13,12,1,1
	dc.l	Prggr,0,0,0,0
	dc	0
	dc.l	0

Namet3	dc.b	1,0,1,0
	dc	4,2
	dc.l	textattr,nimi,0

Namegr	dc	0,0
	dc.b	2,0,1,3
	dc.l	Namexy,Namegr2
Namexy	dc	0,11
	dc	0,0
	dc	200,0

Namegr2	dc	0,0
	dc.b	1,0,1,3
	dc.l	Namexy2,0

Namexy2	dc	200,1
	dc	200,11
	dc	1,11

gr	dc	0,0
	dc.b	2,0,1,3
	dc.l	xy,gr2
xy	dc	0,11
	dc	0,0
	dc	29,0

gr2	dc	0,0
	dc.b	1,0,1,3
	dc.l	xy2,0

xy2	dc	29,1
	dc	29,11
	dc	1,11

bgr	dc	0,0
	dc.b	2,0,1,3
	dc.l	bxy,bgr2
bxy	dc	0,11
	dc	0,0
	dc	166,0

bgr2	dc	0,0
	dc.b	1,0,1,3
	dc.l	bxy2,0

bxy2	dc	166,1
	dc	166,11
	dc	1,11

Ejectgr	dc	0,0,28,13,2
	dc.l	Ejectim
	dc.b	3,0
	dc.l	0

prevgr	dc	0,0,28,13,2
	dc.l	previm
	dc.b	3,0
	dc.l	0

playgr	dc	0,0,28,13,2
	dc.l	playim
	dc.b	3,0
	dc.l	0

nextgr	dc	0,0,28,13,2
	dc.l	nextim
	dc.b	3,0
	dc.l	0

pausegr	dc	0,0,28,13,2
	dc.l	pauseim
	dc.b	3,0
	dc.l	0

prefsgr	dc	0,0,28,13,2
	dc.l	prefsim
	dc.b	3,0
	dc.l	0

Prggr	dc	0,0,28,13,2
	dc.l	Prgim
	dc.b	3,0
	dc.l	0

texture	dc	$5555,$aaaa
otextu	dc	0

Nametx	dc.b	"Name",0
teksti2	dc.b	`Pos`,0
teksti3	dc.b	`Vol`,0
nimi	dcb.b	24,` `
	dc.b	0

	even

*************** Chip datas ****************

	section chip,data_c

Ejectim	dc.l $10,$30,$30,$30,$F0030,$3FC030,$FFF030,$30,$FFF030
	dc.l $30,$30,$30,$7FFFFFF0,$FFFFFFE0,$C0000000,$C0000000,$C0000000,$C0000000
	dc.l $C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$80000000,$37070

previm	dc.l $10,$30,$30,$1C71C30,$1CF3C30,$1DF7C30,$1FFFC30,$1DF7C30,$1CF3C30
	dc.l $1C71C30,$30,$30,$7FFFFFF0,$FFFFFFE0,$C0000000,$C0000000,$C0000000,$C0000000
	dc.l $C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$80000000,$43AA8

playim	dc.l $10,$30,$30,$3C0030,$3F0030,$3FC030,$3FF030,$3FC030,$3F0030
	dc.l $3C0030,$30,$30,$7FFFFFF0,$FFFFFFE0,$C0000000,$C0000000,$C0000000,$C0000000
	dc.l $C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$80000000,$10

nextim	dc.l $10,$30,$30,$38E3830,$3CF3830,$3EFB830,$3FFF830,$3EFB830,$3CF3830
	dc.l $38E3830,$30,$30,$7FFFFFF0,$FFFFFFE0,$C0000000,$C0000000,$C0000000,$C0000000
	dc.l $C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$80000000,$10

pauseim	dc.l $10,$30,$30,$39C030,$39C030,$39C030,$39C030,$39C030,$39C030
	dc.l $39C030,$30,$30,$7FFFFFF0,$FFFFFFE0,$C0000000,$C0000000,$C0000000,$C0000000
	dc.l $C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$80000000,$34F18

prefsim	dc.l $10,$30,$30,$1F8030,$39C030,$1C030,$38030,$60030,$30
	dc.l $60030,$30,$30,$7FFFFFF0,$FFFFFFE0,$C0000000,$C0000000,$C0000000,$C0000000
	dc.l $C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$80000000,$10

Prgim	dc.l $10,$30,$7800030,$4400030,$45E3C30,$7914430,$4104430,$4103C30,$4100430
	dc.l $3830,$30,$30,$7FFFFFF0,$FFFFFFE0,$C0000000,$C0000000,$C0000000,$C0000000
	dc.l $C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$C0000000,$80000000,$34F18

*********** BSS **************


	section	bsss,bss
tbuf		ds	1024*4
tbuf2		ds	1024*4

xm_patts	ds.l	256
xm_insts	ds.l	128

vars		ds.b	256
tempstr		ds.b	128
fname		ds.b	128
fname2		ds.b	128
fname3		ds.b	128
btitle		ds.b	128
	END

