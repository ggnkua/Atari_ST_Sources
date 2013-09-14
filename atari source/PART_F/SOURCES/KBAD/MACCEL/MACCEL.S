******************************************************************
* maccel
* proportional mouse accelerator
* Copyright (c) 1989, Atari Corporation
*
* Permission is granted to copy this program, its source code
* and documentation file, provided they are kept together in
* an archive file exactly as they were originally distributed.
*
******************************************************************
*
* 900806 kbad	Support dynamic cookie jar size, and TT 256 colors
*		added XBRA in stolen vectors
* 890731 kbad	Acceleration no longer timer dependent
*		Added cookie jar support.
* 890126 kbad	added auto folder & medium rez checks
* 890117 kbad	added 2-speed switch and config. message
* 890116 kbad	Cleaned up for PD release.  Happy birthday, Dr. King
* 881020 kbad	Hack hack hack.
*
******************************************************************

* ================================================================
* OS equates
* ----------------------------------------------------------------

STACY		= 1
MADMAC		= 0
CLICK_CONFIG	= 0

* .include	"atari.s"

mfp		= $fffffa00	; mfp base
rsr		= mfp+$2b	; receiver status
CharInProg	= 2		; character in progress bit number

LCDCTL		= $ffff827e
sshiftmd	= $44c		; shadow for 'shiftmd' register
p_cookies	= $5a0		; pointer to cookie jar
kbs10		= $e1b		; kbshift var for TOS 1.0
color0		= $ffff8240	; ST color registers 0..15
ttcolor0	= $ffff8400	; TT color registers 0..255

resvalid	= $426		; validates 'resvector'
resvector	= $42a		; [RESET] bailout vector
RESMAGIC	= $31415926

******** cursor modes
blink		=	$20000	; function codes as longwords
solid		=	$30000	; for speed & size

******** IKBD vector table
.if MADMAC
		.ABS	0
.else
		.OFFSET	0
.endif
midivec:	ds.l	1
vkbderr:	ds.l	1
vmiderr:	ds.l	1
statvec:	ds.l	1
mousevec:	ds.l	1
clockvec:	ds.l	1
joyvec:		ds.l	1
midisys:	ds.l	1
ikbdsys:	ds.l	1

******** IKBD mouse packet offsets
.if MADMAC
		.ABS	0
.else
		.OFFSET	0
.endif
button:		ds.b	1
xdelta:		ds.b	1
ydelta:		ds.b	1

******** 68000 instructions
jmp_abs_l	= $4ef9		; 68000 opcode JMP XXX.L
and_b_d1	= $c239		; 68000 opcode AND.B XXX.L,D1
movi_l_w	= $21fc		; 68000 opcode MOVE.L #XXX,XXX.W

.BSS
__bss:
.DATA
__data:
.TEXT
__text:
* ================================================================
.globl	start

start:	bra	startup			; jump past the handlers
* ----------------------------------------------------------------
******** Resident variables used by keyboard handler
* TLINK expects to find a symbol ref at 2nd longword of text segment
cookie:		dc.l	cookie + $AA006A ; gets stuffed with $AA006E later
watch:		dc.b	0		; 0: don't watch modem, 1: do
linear:		dc.b	0		; 0: fast accel, 1: slow accel
lbdown:		dc.b	0		; left button debounce
rbdown:		dc.b	0		; right button debounce

******** Resident variables used by VBI/screensaver
.globl	mvloc
mvloc:		dc.l	0		; location of mouse vector
vdivec:		dc.l	0		; saved vdi mouse vector
timeout:	dc.w	$4000		; vbls before scrnsave kicks in
fliptime:	dc.w	$400		; vbls while flipping (mono only)
udset:		dc.w	1		; used by int routines to set updown
updown:		dc.w	1		; adder for vbl count
					; also serves as an "enable" flag
vblcount:	dc.w	0		; count of vblanks
colors:		dcb.w	16,0		; place to save shifter color regs
flipped:	dc.w	0		; nonzero if screensaver is activated
stacy:		dc.b	0		; nonzero if we're on Stacy
stacmask:	dc.b	0		; mask for SHADOW reg.
savepark:	dc.w	0		; saved park time
.globl video
video:		dc.l	0		; save _VDO cookie
palbase:	dc.l	color0		; ST palette base
ncols:		dc.w	15		; ST # of colors
monomode:	dc.w	2		; ST mono mode
ttcols:		dcb.w	256,0

* ================================================================
* X/Y delta accelerator
* If mouse delta in d0 is > 1 or < -1, it gets multiplied by
* 4 (linear = 0) or 2 (linear = 1)
* ----------------------------------------------------------------
* input:	d0 = mouse delta
* output:	d0 = munged mouse delta
* uses:		d1
* ----------------------------------------------------------------
accel:	cmp.b	#2,d0
	bge.b	shift
	cmp.b	#-2,d0
	ble.b	shift
	rts
shift:	moveq	#2,d1
	sub.b	linear(pc),d1
	lsl.b	d1,d0
	rts

* ================================================================
* Here be the mouse packet handler...
* ----------------------------------------------------------------
* Two types of acceleration are provided, "slow" and "fast", determined
* by the "linear" flag.  "Slow" acceleration multiplies an X or Y delta
* by 2 if <1 or >-1.  "Fast" acceleration is similar, but multiplies
* by 4.
* ----------------------------------------------------------------
* input:	pointer to mouse packet in a0
* output:	munged mouse packet if the mouse was moved fast
* uses:		d0-d1
* ----------------------------------------------------------------
.globl oldmvec
	    dc.l	'XBRA'
	    dc.l	'macc'
oldmvec:    dc.l	0

.globl mouse
mouse:	move.b	linear(pc),d0
	blt.b	out
	move.b	xdelta(a0),d0		; Get the delta x byte,
	bsr.b	accel			; munge it
	move.b	d0,xdelta(a0)		; put it back
	
	move.b	ydelta(a0),d0		; get the delta y byte
	bsr.b	accel
	move.b	d0,ydelta(a0)		; and delta y byte

.if CLICK_CONFIG
******** check for Control-Shift-Alt click
rbut:	btst	#0,(a0)			; right button down?
	bne.b	rstill			; yes, see if it was down before
	clr.b	rbdown			; button not down, clear flag
	bra.b	lbut			; and check left button
rstill:	tst.b	rbdown			; was it down before?
	bne.b	lbut			; yes, go check left button
	st	rbdown			; set right button flag
	bsr.b	ckcsa			; check keys
	bne.b	out			; CAS not down, skip left button check
	eor.b	#1,linear		; toggle linear acceleration flag
lbut:	btst	#1,(a0)			; left button down?
	bne.b	lstill			; yes, see if it was down before
	clr.b	lbdown			; button not down, clear flag
	bra.b	out			; and scram
lstill:	tst.b	lbdown			; was it down before?
	bne.b	out			; yes, scram
	st	lbdown			; set button flag
	bsr.b	ckcsa
	bne.b	out
******** No need to restore colors here, because
******** they get restored by ikbd before we get here.
	tst	updown
	beq.b	ssin			; If we're enabled
	clr	updown			; disable counter,
	bra.b	ssout
ssin:	move	#1,updown		; else enable counter.
ssout:	clr.w	vblcount		; Zero vblank count.
.endif

out:	move.l	oldmvec(pc),-(sp)
	rts

.if CLICK_CONFIG
******** Look for Control-Alt-Shift, return with CCR Z flag set if they're down
ckcsa:	moveq	#$e,d1
	dc.w	and_b_d1
.globl kbshift
kbshift:
	dc.l	0
	cmp.b	#$e,d1
	rts
.endif

* ================================================================
* IKBD int handler to turn off the screen saver.
* Uses d0-d1/a0-a1.
* ----------------------------------------------------------------
.globl oldkbd
	    dc.l	'XBRA'
	    dc.l	'macc'
oldkbd:	    dc.l	0
.globl ikbd
ikbd:	movem.l	d0-d1/a0-a1,-(sp)
	move	udset(pc),updown
	move	flipped(pc),d0	; get flip state
	beq.b	xikbd		; if we're not flipped, we don't have to unflip
	bsr	csaver		; otherwise restore colors (d0 != 0)
	clr	flipped
xikbd:	clr	vblcount
	movem.l	(sp)+,d0-d1/a0-a1
	move.l	oldkbd(pc),-(sp)
	rts

* ================================================================
* RS232 int handler to turn off the screen saver.
* Uses d0-d1/a0-a1.
* ----------------------------------------------------------------
.globl oldrs
	    dc.l	'XBRA'
	    dc.l	'macc'
oldrs:	    dc.l	0
.globl rs232
rs232:	movem.l	d0-d1/a0-a1,-(sp)
	tst.b	watch		; if we're not watching
	beq.b	nors		; do nothing
	move	udset(pc),updown
	move	flipped(pc),d0	; get flip state
	beq.b	xrs		; if we're not flipped, we don't have to unflip
	bsr	csaver		; otherwise restore colors (d0 != 0)
	clr	flipped
xrs:	clr	vblcount
nors:	movem.l	(sp)+,d0-d1/a0-a1
	move.l	oldrs(pc),-(sp)
	rts

* ================================================================
* Here be the multi-purpose VBI routine that:
* 1) ensures we keep our vector
*   (the VDI will snarf it at the first open screen workstation!)
* 2) handles the screensaver
* ----------------------------------------------------------------

.globl myvbl
******** First see if we need to take back the mouse handler
myvbl:	move.l	mvloc(pc),a0		; get mouse vector
	move.l	(a0),a1			; for speed
	cmp.l	#mouse,a1		; still ours?
	beq.b	ssave			; yup, check the screensaver
	move.l	vdivec(pc),d0		; have we stored the VDI mouse vector?
	bne.b	isvdi			; yes, see who's going for it this time
	move.l	a1,vdivec		; store the VDI mouse vector
	bra.b	takem			; and replace it
isvdi:	cmpa.l	d0,a1			; is it VDI?
	bne.b	ssave			; no, leave it be
takem:	move.l	a1,oldmvec
	move.l	#mouse,(a0)

******** Then see if we need to flip the screen
ssave:	tst.b	watch			; see if we're watching rs232
	beq.b	snors			; if not watching, do nothing
	btst.b	#CharInProg,rsr		; check the reciever status reg.
	beq.b	snors

	move	flipped(pc),d0		; if we're flipped,
	beq.b	charip			; don't have to unflip
	bsr	csaver			; otherwise, restore colors (d0!=0)
	clr	flipped
charip:	clr	vblcount
snors:
	move	updown(pc),d0		; See if it's disabled
	beq	xvbl
	add	vblcount(pc),d0		; Bump vblank counter
	move	d0,vblcount
	bne.b	flip1			; If nonzero, check timeouts.
	neg	updown			; If zero, start counting up.
	bra.b	doflip			; flip and exit
flip1:	tst	flipped			; Already flipped?
	bne.b	isflip
	move	timeout(pc),d1		; No, use user timeout
	bra.b	cktime
isflip:	move	fliptime(pc),d1		; else use short timeout.
cktime:	cmp	d1,d0			; Time to flip again?
	bne.b	xvbl			; No, exit.
	move	fliptime(pc),vblcount	; Set short timeout,
	neg	updown			; and start counting down.
	move	flipped(pc),d0		; See if we've flipped -
	bne.b	doflip			; if so, we've already saved colors;
	bsr.b	csaver			; if not, save colors now (d0 == 0).
doflip:
* Screen flipper
flip:	move.l	palbase,a0		; get palette base
	moveq	#0,d0
	move.b	sshiftmd,d0		; see if we're presently mono
	cmp	monomode,d0		; if not, zero out palettes
	bne.b	zpal
	not	(a0)			; else just flip b/w.
	tst.b	stacy			; if stacy,
	beq.b	xflip
	move.b	stacmask,LCDCTL		; hit LCDCTL for stacy screen
	bra.b	xflip

zpal:	tst	flipped			; If we're already flipped,
	bne.b	xvbl			; no need to blank colors.
	move.w	ncols,d0
z1:	clr	(a0)+
	dbra	d0,z1
xflip:	st	flipped			; and set flip flag.
xvbl:	rts

* ================================================================
* Color register save & restore
* If d0 == 0 on entry, save colors, else restore them
* ----------------------------------------------------------------
csaver:	move.l	palbase,a0
	lea	color0,a1
	cmp	a0,a1
	beq.b	isst
	lea	ttcols(pc),a1		; TT save area
	bra.b	sorr
isst:	lea	colors(pc),a1		; ST save area
sorr:	tst	d0
	beq.b	dosave
	exg.l	a0,a1			; if we were flipped, this is a restore
* if stacy, hit LCDCTL
	tst.b	stacy
	beq.b	dosave
	clr.b	LCDCTL
* .endif
dosave:	move	ncols,d1
nxcol:	move	(a0)+,(a1)+
	dbra	d1,nxcol
	rts

* ================================================================
* Reset handler to un-install cookie jar
* ----------------------------------------------------------------
.globl myreset
.globl oldrvec
.globl oldrval
myreset:
	clr.l	p_cookies
	dc.w	movi_l_w
oldrvec:dc.l	0
	dc.w	resvector
	dc.w	movi_l_w
oldrval:dc.l	0
	dc.w	resvalid
	jmp	(a6)

jar:
	dcb.l	128,0			; enough jar for 64 cookies
					; "more than enough"

resend:					; end of resident code segment


* Base page structure

.if MADMAC
		.ABS	0
.else
		.OFFSET 0
.endif
TpaStart:	.DS.L   1
TpaEnd:		.DS.L   1
TextSegStart:	.DS.L   1
TextSegSize:	.DS.L   1
DataSegStart:	.DS.L   1
DataSegSize:	.DS.L   1
BssSegStart:	.DS.L   1
BssSegSize:	.DS.L   1
DtaPtr:		.DS.L   1
PntPrcPtr:	.DS.L   1
Reserved0:	.DS.L   1
EnvStrPtr:	.DS.L   1
Reserved1:	.DS.B   7
CurDrv:		.DS.B   1
Reserved2:	.DS.L   18
CmdLine:	.DS.B   128
BasePageSize:	.DS     0

.globl		main
.globl		get_cookie

.TEXT

* ================================================================
* Here be the initialization code
* ----------------------------------------------------------------

startup:
	move.l	a0,a3
	move.l	a3,d0
	bne	exit
	move.l	4(sp),a3

* Compute size of required memory
* := text segment size + data segment size + bss segment size
*  + stack size + base page size
        move.l  TextSegSize(A3),a0
        add.l   DataSegSize(A3),a0
        add.l   BssSegSize(A3),a0	; TC wires stack to bss
        add.w   #BasePageSize,a0

* Setup longword aligned application stack
        move.l  a3,d0
        add.l   a0,d0
        and.b   #$fc,d0
        move.l  d0,a7

* Free not required memory
        move.l  a0,-(a7)
        move.l  a3,-(a7)
	move	#0,-(a7)
        move	#74,-(a7)
        trap    #1
        lea.l   12(a7),a7

* initialize some stuff
	lea	cookie(pc),a0
	move.w	#$AA,(a0)+
	move.w	#$6e,(a0)+
	move	udset(pc),updown
	pea	get_cookie(pc)		; Supexec(get_cookie)
	move.w	#38,-(sp)
	trap	#14
	addq	#6,sp
	moveq	#2,d0
	cmp.w	video,d0
	bne.b	gomain
	move.l	#ttcolor0,palbase
	move.w	#255,ncols
	move.w	#6,monomode

gomain:	jsr	main

**** Here we save ONLY the memory needed for the mouse and VBI handlers.
**** The rest of the code (everything after resend) goes away bye-bye.

.if MADMAC
	Ptermres mem2save, #0 ; save handlers + basepage
.else
	clr	-(sp)
	move.l	mem2save,-(sp)
	move	#$31,-(sp)
	trap	#1
.endif
	illegal

exit:
	clr	(sp)
	trap	#1
	illegal

.if !MADMAC
.super
.endif

.globl IPL7
IPL7:
	move	sr,savesr
	ori	#$700,sr
	rts

.globl IPL_RESTORE
IPL_RESTORE:
	move	savesr,sr
	rts

savesr:	dc.w	0


.globl ma_info
.globl set_ptime
.globl get_parktime
.globl set_cookie
*-- set_cookie moved here from C to allow dynamic jar sizing
set_cookie:
	bsr	get_parktime	; set up park time first
	lea	ma_info,a2
	move.w	$6c(a2),d0	; if (parktime >= 0)
	blt.b	setp
	move.l	(a2),a0		;   parktime = ma_info->savepark
	move.w	$42(a0),$6c(a2)
setp:	bsr	set_ptime

	move.l	#$AA006E,d2	; maccel cookie
	move.l	p_cookies,d0	; initial jar pointer
	beq.b	initjar		; if no jar, install one
	move.l	d0,a0		; else let's count cookies
	move.l	a0,a1		; save start
	moveq	#0,d0		; init cookie counter
	moveq	#0,d7		; size of potentially created jar
got1:
	move.l	(a0)+,d1	; get a cookie
	beq.b	jarend		; if it's 0, we're done counting
	addq	#1,d0		; count it
	lea	4(a0),a0	; skip the value
	bra.b	got1

*-- at this point, d0 holds the number of cookies in the current jar
jarend:
	addq	#2,d0		; account for our entry and cookie count
	move.l	(a0)+,d3	; get the jar size
	cmp.l	d0,d3		; is there room for me?
	blt.b	initjar		; nope, copy it into my jar
	move.l	d2,-8(a0)	; otherwise, just stuff my cookie
	move.l	(a2),-4(a0)	; in the existing jar
	clr.l	(a0)+		; and move the cookie count entry
	move.l	d3,(a0)
	bra.b	figger

*-- allocate a new jar
initjar:
	lea	jar(pc),a0	; get our jar
	move.l	a0,a3		; save it
	move.l	d0,d7		; save count of cookies
	subq	#3,d0		; if there are no cookies
	blt.b	setjar		; just make a new jar with only my entry
move1:	move.l	(a1)+,(a0)+	; move a cookie
	move.l	(a1)+,(a0)+
	dbra	d0,move1
setjar:	move.l	d2,(a0)+	; add ours to the end
	move.l	(a2),(a0)+
	clr.l	(a0)+		; and set the jar size entry
	addq	#8,d7		; leave space for 8 (more) entries
	move.l	d7,(a0)+
	move.l	a3,p_cookies
	lsl.l	#3,d7		; count * 8 is bytes to save

*-- compute memory to save, d7 holds size of jar in bytes
figger:
	add.l	#(jar-start+$100),d7
	move.l	d7,mem2save
	rts

mem2save: dc.l	0

*the
.END
