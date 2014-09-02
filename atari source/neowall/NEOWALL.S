;
;	NEOWALL.S   Horizontal and Vertical Scrolling Demo
;
;	Copyright 1988 ATARI CORP.
;	Started 10/10/88 .. Rob Zdybel
;

	.text
	.include atari

;
;	HARDWARE CONSTANTS
;
vbaselo	=	$ffff820d		; Video Base Address (lo)
linewid	=	$ffff820f		; Width of a scan-line (Words, minus 1)
hscroll	=	$ffff8265		; Horizontal scroll count (0 .. 15)

;
;	SYSTEM CONSTANTS
;
vblvect	=	$70		; System VBlank Vector

;
;	LOCAL CONSTANTS
;

;
;	System Initialization
;
start:
	move.l	a7,a5
	move.l	#mystack,a7	; Get Our Own Local Stack
	move.l	4(a5),a5	; a5 = basepage address
	move.l	TEXTSZ(a5),d0
	add.l	DATASZ(a5),d0
	add.l	BSSSZ(a5),d0
	add.l	#$100,d0	; RAM req'd = text+bss+data+BasePageLength
	move.l	d0,d4		; d4 = RAM req'd
	Mshrink	a5,d0		; Return Excess Storage
;
;	Other Initialization
;
	Super			; enter supervisor mode

	Fgetdta
	move.l	d0,a4
	adda	#30,a4		; a4 = Filename ptr
	moveq	#0,d4		; d4 = Loop Count
	Fsfirst	#neofiles,#0
.neoloop:			; FOR (Nine NEO Files) DO
	tst	d0
	bmi	abort		; IF (No more NEO files) ABORT
	Fopen	a4,#0
	tst	d0
	bmi	abort		; IF (Error opening a file) ABORT
	lea	handlist,a0
	move	d0,(a0,d4)	; Save the Handle
	addq	#2,d4
	cmp	#16,d4
	bgt	.gotnine
	Fseek	#128,d0,#0	; Skip NEO Header
	tst.l	d0
	bmi	abort		; IF (File Seek Error) ABORT
	Fsnext
	bra	.neoloop
.gotnine:
	Fread	d0,#128,#bigbuff
	tst.l	d0
	bmi	abort		; IF (File Read Error) ABORT
	lea	bigbuff+4,a2
	lea	palette,a0
	lea	oldpal,a1
	move	#15,d0
.ploop:	move.w	(a0),(a1)+	; save old color palette
	move.w	(a2)+,(a0)+	; create new color palette
	dbra	d0,.ploop

	move.l	#bigbuff,buffptr
	moveq	#0,d7		; d7 = Row Count
.rowlp:	lea	threebuf,a4	; FOR (Three rows) DO
	lea	handlist,a5
	adda	d7,a5
	move	#2,d6		; d5 = Column Count
.redlp:	Fread	(a5)+,#32000,a4	; FOR (3 Files) DO Read into temp buff
	tst.l	d0
	bmi	abort		; IF (File Read Error) ABORT
	adda	#32000,a4
	dbra	d6,.redlp

	lea	threebuf,a1
	lea	threebuf+32000,a2
	lea	threebuf+64000,a3
	move.l	buffptr,a0
	move	#199,d6		; d6 = Scan Line Count
.linlp:	move	#39,d5		; FOR (200 Lines) DO
.t1:	move.l	(a1)+,(a0)+	; Copy a line from screen0
	dbra	d5,.t1
	move	#39,d5
.t2:	move.l	(a2)+,(a0)+	; Copy a line from screen1
	dbra	d5,.t2
	move	#39,d5
.t3:	move.l	(a3)+,(a0)+	; Copy a line from screen2
	dbra	d5,.t3
	dbra	d6,.linlp
	move.l	a0,buffptr
	addq	#6,d7
	cmp	#12,d7
	ble	.rowlp

	moveq	#16,d4
	lea	handlist,a4
.close:	move	(a4,d4),-(sp)	; FOR (Nine files) DO Close all
	Gemdos	$3e,4		; Fclose
	tst	d0
	bmi	abort		; IF (Error Closing a file) ABORT
	subq	#2,d4
	bpl	.close

	jsr	initmaus	; Install our own mouse handler

	move.l	vblvect,oldvbl
	move.l	#vbl,vblvect	; Capture System VBlank Interrupt

;
;	Scrolling Demo loop
;
wavelp:
	Bconstat CON		; Keyboard Polling
	tst	d0
	beq	noexit		; IF (Keyboard Input Available) THEN
	Bconin	CON
	cmp.b	#'C'-64,d0
	beq	exit		; CTRL-C ==> EXIT
noexit:
	bra	wavelp
exit:
;
;	System Tear-Down
;
	move.l	oldvbl,vblvect	; Restore System VBlank Interrupt

	move.b	#0,linewid
	move.b	#0,hscroll	; Restore Normal Display

	jsr	unmaus		; Restore System mouse handler

	lea	oldpal,a0
	lea	palette,a1
	move	#15,d0
.unplp:	move.w	(a0)+,(a1)+
	dbra	d0,.unplp	; restore old color palette

abort:	User			; return to user mode
	Pterm0			; return to GEMDOS

;
;	VBL	Vertical-Blank Interrupt Server
;
vbl:
	movem.l	d0/a0,-(sp)

	move	xmouse,d0
	and	#$0f,d0
	move.b	d0,hscroll	; Xpos MOD 16 = Scroll count
	tst.b	d0
	bne	.non0		; IF (Scrolling) THEN 4 word offset
	move.b	#160,linewid
	bra	.join
.non0:	move.b	#156,linewid
.join:
	lea	bigbuff,a0
	move	ymouse,d0
	mulu	#3*160,d0	; Ypos * Linewid = Vertical offset
	adda.l	d0,a0
	move	xmouse,d0
	asr	#1,d0
	and	#$fff8,d0	; 8*(Xpos DIV 16) = Line offset
	adda	d0,a0		; a0 = Video Base Address
	move.l	a0,vbltemp
	move.b	vbltemp+1,vcounthi
	move.b	vbltemp+2,vcountmid
	move.b	vbltemp+3,vcountlo

	movem.l	(sp)+,d0/a0
	.dc.w	$4ef9
oldvbl:	.dc.l	0		; JMP (Old-Vblank)
	illegal

;
;	DATA STORAGE
;
	.data
neofiles:			; NEO filename search string
	.dc.b	"*.neo",0

	.even

;
;	RANDOM DATA STORAGE
;
	.bss

oldpal:
	.ds.l	16		; Original color palette

handlist:			; Array of Active Handles (9)
	.ds.w	9
buffptr:			; Load ptr for bigbuff
	.ds.l	1
bigbuff:			; Mega-Image Buffer 
	.ds.b	9*32000
threebuf:			; Temporary Triple-Image Buffer 
	.ds.b	3*32000

vbltemp:			; Vblank Temporary Storage
	.ds.l	1

	.ds.l	256		; (stack body)
mystack:
	.ds.l	1		; Local Stack Storage

	.end
