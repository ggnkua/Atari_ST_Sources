;
;	HSCROLL.S   Horizontal Scrolling Demo
;	THE ONE LINE VERSION
;
;	Copyright 1988 ATARI CORP.
;	Started 9/12/88 .. Rob Zdybel
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
vblvec	=	$70		; System VBlank Vector
ikbdvec	= 	$118		; IKBD/MIDI (6850) Vector
hblvec	=	$120		; Horizontal Blank Counter (68901) Vector

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
	Fsfirst	#neofile,#0
	tst	d0
	bmi	abort		; IF (No NEO files) ABORT
	Fopen	a4,#0
	tst	d0
	bmi	abort		; IF (Error opening file) ABORT

	move	d0,handle
	Fread	d0,#32128,#neobuff
	tst.l	d0
	bmi	abort		; IF (File Read Error) ABORT
	Fclose	handle
	tst	d0
	bmi	abort		; IF (Error Closing a file) ABORT

	lea	neobuff+4,a2
	lea	palette,a0
	lea	oldpal,a1
	move	#15,d0
.ploop:	move.w	(a0),(a1)+	; save old color palette
	move.w	(a2)+,(a0)+	; create new color palette
	dbra	d0,.ploop

	move	#160,d0		; Double each display line
	lea	bigbuff,a0
	lea	neobuff+128,a1
	move	#199,d2
.linlp:	move	#39,d1		; FOR (200 Lines) DO
.dublp:	move.l	(a1),(a0,d0)	; duplicate line
	move.l	(a1)+,(a0)+
	dbra	d1,.dublp
	adda	d0,a0
	dbra	d2,.linlp

	lea	baseaddr,a0
	lea	xoffset,a1
	lea	bigbuff,a2
	move	#9,d0
.strlp:	move	#0,(a1)+	; FOR (10 Strips) DO Init base and offset
	move.l	a2,(a0)+
	adda	#320*20,a2
	dbra	d0,.strlp

	move.l	ikbdvec,oldikbd
	move.l	#ikbd,ikbdvec	; IPL 5 hack for IKBD/MIDI

	move.l	vblvec,oldvbl
	move.l	#vbl,vblvec	; Capture System VBlank Interrupt

	move.l	#hbl,hblvec	; Capture HBlank Interrupt
	bclr.b	#5,imrb
	bclr.b	#5,ierb
	bset.b	#0,imra
	bset.b	#0,iera		; Enable Hblank

;
;	Scrolling Demo loop
;
wavelp:
;	Bconstat CON		; Keyboard Polling
;	tst	d0
;	beq	noexit		; IF (Keyboard Input Available) THEN
;	Bconin	CON
;	cmp.b	#'C'-64,d0
;	beq	exit		; CTRL-C ==> EXIT
noexit:
	bra	wavelp
exit:
;
;	System Tear-Down
;
	bclr.b	#0,iera
	bclr.b	#0,imra		; Disable Hblank
	move.l	oldikbd,ikbdvec ; Restore System IKBD/MIDI Interrupt
	move.l	oldvbl,vblvec	; Restore System VBlank Interrupt

	move.b	#0,linewid
	move.b	#0,hscroll	; Restore Normal Display

	Gettime
	move.l	d0,vbltemp	; Get IKBD Date/Time
	Tsettime d0
	Tsetdate vbltemp	; Set GEMDOS Time and Date

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
	movem.l	d0-d2/a0-a2,-(sp)

	lea	video,a0	; a0 = Display list (scroll,base)
	lea	xoffset,a1	; a1 = Xoffset list
	lea	baseaddr,a2	; a2 = Base address list
	move	#9,d1
.reglp:				; FOR (10 scrolling regions) DO
	move	(a1),d0		; d0 = current Xoffset
	move.l	_vbclock,d2
	and	#1,d2		; Scrolling speed control
	bne	.join

	btst.l	#0,d1
	bne	.odd
	addq	#1,d0		; EVEN --> Increment
	cmp	#320,d0
	blt	.join
	moveq	#0,d0		; Wrap-up
	bra	.join
.odd:	subq	#1,d0		; ODD --> Decrement
	bge	.join
	move	#319,d0		; Wrap-down
.join:	move	d0,(a1)		; New Xoffset
	asr	#1,d0
	and.l	#$0fff8,d0	; d0 = byte offset within line
	add.l	(a2)+,d0	; d0 = Regions video base
	move.l	d0,(a0)
	move	(a1)+,d0
	and	#$0f,d0		; d0 = Regions horizontal scroll count
	move.b	d0,(a0)
	addq.l	#4,a0
	dbra	d1,.reglp
.skip:

	lea	video,a0
	move.b	(a0)+,d0
	move.b	d0,hscroll
	move.b	(a0)+,vcounthi
	move.b	(a0)+,vcountmid
	move.b	(a0)+,vcountlo	; Initialize first region

	move	#80,d1		; Double normal ST line width
	tst.b	d0
	beq	.zero		; IF (non-zero scroll count) Reduce line width
	subq	#4,d1
.zero:	move.b	d1,linewid

	move.l	(a0)+,d0
	rol.l	#8,d0
	move.l	d0,videodata	; Init next lines data
	move.l	a0,videoptr	; Init display list ptr

	move.b	#0,tbcr
	move.b	#20,tbdr	; Interrupt every twenty HBlanks
	move.b	#8,tbcr

	movem.l	(sp)+,d0-d2/a0-a2
	.dc.w	$4ef9
oldvbl:	.dc.l	0		; JMP (Old-Vblank)
	illegal

;
;	IKBD	IKBD/MIDI Interrupt Server
;
ikbd:
	move	d0,-(sp)

	move	sr,d0
	and	#$f8ff,d0
	or	#$500,d0
	move	d0,sr		; Set IPL down to 5

	move	(sp)+,d0
	.dc.w	$4ef9
oldikbd:
	.dc.l	0		; JMP (Old-IKBD)
	illegal

;
;	HBL	*ONE LINE* Horizontal-Blank Interrupt Server
;
hbl:
	movem.l	d0/a0,-(sp)	; 			(44+28=72)

	move.l	videodata,d0	; d0 = vcount/scroll	(20)
	lea	vcounthi,a0	; a0 = movep base	(8)
	move.b	d0,hscroll	; set HScroll		(12)
	movep.l	d0,(a0)		; set VideoBase		(24)
				;			(total = 136+ cycles)
	tst.b	d0
	beq	.zero		; IF (non-zero scroll count) Reduce line width
	move.b	#76,linewid
	bra	.join
.zero:	move.b	#80,linewid
.join:
	move.l	videoptr,a0
	move.l	(a0)+,d0
	rol.l	#8,d0
	move.l	d0,videodata	; Init next regions data
	move.l	a0,videoptr

	movem.l	(sp)+,d0/a0
	bclr.b	#0,isra		; Clear In-Service bit
	rte

;
;	DATA STORAGE
;
	.data
neofile:			; NEO filename search string
	.dc.b	"*.neo",0

	.even

;
;	RANDOM DATA STORAGE
;
	.bss

oldpal:
	.ds.l	16		; Original color palette
handle:				; Active Handle
	.ds.w	1

baseaddr:			; Image Base address for each strip
	.ds.l	10
xoffset:			; Pixel-offset for each strip
	.ds.w	10
video:				; HScroll and Video Base address for each strip
	.ds.l	10
videoptr:			; Display list ptr
	.ds.l	1
videodata:			; Next regions display info
	.ds.l	1

neobuff:			; NEO-Image Buffer 
	.ds.b	32128
bigbuff:			; Mega-Image Buffer 
	.ds.b	2*32000

vbltemp:			; Vblank Temporary Storage
	.ds.l	1

	.ds.l	256		; (stack body)
mystack:
	.ds.l	1		; Local Stack Storage

	.end
