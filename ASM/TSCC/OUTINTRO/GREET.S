
		text
greetInit:	move.w	#1,logoFade2
		move.l	#greetFadeIn,VBLHookPtr
		bra.w	setSemaphore


******************************************************
*  void greetMain()
*
* Greeting screen main stepping routine.
******************************************************

greetFadeIn:	moveq.l	#3,d0
		and.l	$466.w,d0	; Fade every 4th VBL
		bne.s	.break

		moveq.l	#(1<<PHYS_BPP)-1,d0	; Max. brightness

		cmp.w	logoFade2,d0	; Max. brightness approached yet?
		beq.s	.done

		addq.w	#1,logoFade2

.break:		rts

.done:		clr.l	VBLHookPtr
		rts

greetFadeOut:	moveq.l	#3,d0		; Fade every 4th VBL
		and.l	$466.w,d0
		bne.s	.break

      		tst.w	logoFade2	; Min. brightness approached yet?
		beq.s	.done

		subq.w	#1,logoFade2

.break:		rts

.done:          clr.l	VBLHookPtr
		rts

		text
greetMain:	move.l	#greyPal,logoPalPatch
                lea.l	logoPalObj,a0
		bsr.w	installSplitPalette

		movea.l	greetPtr,a0	; Get current greeting object pointer

		tst.l	(a0)		; == NULL?
		beq.s	.done

                movea.l	(a0),a1		; Dissolve object pointer

		bsr.w	getTime

                tst.w	(a1)		; tics <= 0 ?
                ble.s	.nextObj

		cmpi.w	#60,(a1)	; Trigger fade out?
		bhi.s	.dont_fade
		move.l	#greetFadeOut,VBLHookPtr

.dont_fade:	movem.l	d0-a6,-(sp)

		bsr.w	wVBL

		movea.l	screen3(pc),a0	; Clear screen and plot current string
		lea.l	OUTLOGO_Y*BYTESPERSCL(a0),a0
		move.l	#(PHYS_Y-2*OUTLOGO_Y)*BYTESPERSCL,d0
		moveq.l	#0,d1
		bsr.w	ClearBlock

		movem.l	(sp)+,d0-a6


		sub.w	d0,(a1)+	; Decrease tics
		movem.w	(a1)+,d0-d1	; Get the x, y pixel position
		movea.l	a1,a0		; *src
		movea.l	screen3(pc),a1	; *dst

		bsr.w	plotString
		bra.w	cycleScreens

.nextObj:	addq.l	#4,greetPtr	; Next object
		move.l	#greetFadeIn,VBLHookPtr
;>		rts

.done:          rts
;>		moveq.l	#3-1,d0
;>
;>.cls_loop:      move.w	d0,-(sp)
;>
;>		movea.l	screen3(pc),a0	; Clear screen and plot current string
;>		lea.l	OUTLOGO_Y*BYTESPERSCL(a0),a0
;>		move.l	#(PHYS_Y-2*OUTLOGO_Y)*BYTESPERSCL,d0
;>		moveq.l	#0,d1
;>		bsr.w	ClearBlock
;>		bsr.w	cycleScreens
;>
;>		move.w	(sp)+,d0
;>		dbra	d0,.cls_loop
;>                rts


; Greeting screen data objects

		data
greetPtr:	dc.l	greetObjs	; Current greeting object to be shown

greetObjs:	dc.l	greet2		; greetObjs[] = { &greetObj } (Null terminated)
                dc.l	greet1
                dc.l	greet3
                dc.l	greet4
                dc.l	greet5
                dc.l	greet6
                dc.l	greet7
                dc.l	greet8
                dc.l	greet9
                dc.l	greet10
                dc.l	greet11
                dc.l	greet12
                dc.l	greet13
                dc.l	greet14
                dc.l	greet15
                dc.l	greet16
		dc.l	greet17
                dc.l	greet18
                dc.l	greet19
                dc.l	greet20
                dc.l	greet21
                dc.l	greet22
                dc.l	greet23
                dc.l	greet24
		dc.l	greet25
                dc.l	greet26
                dc.l	greet27
                dc.l	greet28
                dc.l	greet29
                dc.l	greet30
                dc.l	greet31
                dc.l	greet32
                dc.l	greet33
                dc.l	greet34
                dc.l	greet35
                dc.l	greet36
                dc.l	greet37
                dc.l	greet38
                dc.l	greet39
                dc.l	greet40
                dc.l	greet41
                dc.l	greet42
		dc.l	ending1
		dc.l	ending2
		dc.l	ending3
		dc.l	ending4
		dc.l	ending7
		dc.l	ending5
		dc.l	ending8
		dc.l	ending9
		dc.l	NULL


greet1:		dc.w	200,72,92	; Greet Objects (60Hz_tics, x, y, str[])
		dc.b	'..coming up',0
		even
greet2:		dc.w	200,72,92
		dc.b	'greetings..',0
		even
greet3:		dc.w	200,136,92
		dc.b	'dhs',0
		even
greet4:		dc.w	200,128,92
		dc.b	'dune',0
		even
greet5:		dc.w	200,96,92
		dc.b	'paradize',0
		even
greet6:		dc.w	200,104,92
		dc.b	'equinox',0
		even
greet7:		dc.w	200,80,92
		dc.b	'sector one',0
		even
greet8:		dc.w	200,136,92
		dc.b	'mjj',0
		even
greet9:		dc.w	200,48,92
		dc.b	'reservoir gods',0
		even
greet10:	dc.w	200,128,92
		dc.b	'gwem',0
		even
greet11:	dc.w	200,80,92
		dc.b	'ym rockerz',0
		even
greet12:	dc.w	200,88,92
		dc.b	'evolution',0
		even
greet13:	dc.w	200,104,92
		dc.b	'lineout',0
		even
greet14:	dc.w	200,136,92
		dc.b	'phf',0
		even
greet15:	dc.w	200,120,92
		dc.b	'd-bug',0
		even
greet16:	dc.w	200,128,92
		dc.b	'stax',0
		even
greet17:	dc.w	200,136,92
		dc.b	'tce',0
		even
greet18:	dc.w	200,40,92
		dc.b	'cerebral vortex',0
		even
greet19:	dc.w	200,64,92
		dc.b	'atari legend',0
		even
greet20:	dc.w	200,128,92
		dc.b	'taos',0
		even
greet21:	dc.w	200,80,92
		dc.b	'checkpoint',0
		even
greet22:	dc.w	200,112,92
		dc.b	'escape',0
		even
greet23:	dc.w	200,136,92
		dc.b	'tuc',0
		even
greet24:	dc.w	200,104,92
		dc.b	'x-troll',0
		even
greet25:	dc.w	200,104,92
		dc.b	'paradox',0
		even
greet26:	dc.w	200,112,92
		dc.b	'ribbon',0
		even
greet27:	dc.w	200,64,92
		dc.b	'mystic bytes',0
		even
greet28:	dc.w	200,104,92
		dc.b	'yescrew',0
		even
greet29:	dc.w	200,120,92
		dc.b	'sedma',0
		even
greet30:	dc.w	200,72,92
		dc.b	'satantronic',0
		even
greet31:	dc.w	200,112,92
		dc.b	'c.p.u.',0
		even
greet32:	dc.w	200,104,92
		dc.b	'taquart',0
		even
greet33:	dc.w	200,104,92
		dc.b	'oxygene',0
		even
greet34:	dc.w	200,88,92
		dc.b	'rabenauge',0
		even
greet35:	dc.w	200,88,92
		dc.b	'ephidrena',0
		even
greet36:	dc.w	200,120,92
		dc.b	'wamma',0
		even
greet37:	dc.w	200,112,92
		dc.b	'scarab',0
		even
greet38:	dc.w	200,80,92
		dc.b	'farbrausch',0
		even
greet39:	dc.w	200,96,92
		dc.b	'outracks',0
		even
greet40:	dc.w	200,56,92
		dc.b	'neoscientists',0
		even
greet41:	dc.w	200,80,92
		dc.b	'st knights',0
		even
greet42:	dc.w	200,40,92
		dc.b	'the black lotus',0
		even

ending1:	dc.w	200,48,92
		dc.b	'...and now for',0
		even
ending2:	dc.w	200,88,92
		dc.b	'something',0
		even
ending3:	dc.w	200,80,92
		dc.b	'completely',0
		even
ending4:	dc.w	200,96,92
		dc.b	'diffrent',0
		even
ending5:	dc.w	200,40,92
		dc.b	'to be announced',0
		even
ending7:	dc.w	300,96,92
		dc.b	'DOOM ST!',0
		even
ending8:	dc.w	200,64,92
		dc.b	'here comes a',0
		even
ending9:	dc.w	10000,64,92
		dc.b	'tech preview',0
		even


******************************************************
*  void showCredits()
*
* Credit screen main animation routine
******************************************************

		text
showCredits:	lea.l	strPalObj,a0
		bsr.w	installSplitPalette

		lea.l	strObj,a2

.drawStrings:	tst.l	(a2)
		beq.s	.break
		movea.l	(a2)+,a0	; Fetch Source pointer
		movea.l	screen3(pc),a1
		movem.w	(a2)+,d0/d1	; Fetch x, y pixel position

		movem.l	d2/a2,-(sp)
		bsr.w	plotString
		movem.l	(sp)+,d2/a2
		bra.s	.drawStrings

.break:		move.l	#strVBLHook,VBLHookPtr

		bra.w	cycleScreens

creditsFadeOut: move.l	#strFadeOutVBL,VBLHookPtr
		rts

; Scroll in faded raster pattern

STR_YMAX	=	180		; Max. raster y position

strVBLHook:	cmpi.w	#STR_YMAX,strPalObjY	; Max. scanline position approached?
		bhs.s	.done

		addq.w	#2,strPalObjY
.break:		rts

.done:		clr.l	VBLHookPtr
		rts

; Fade out credits screen

strFadeOutVBL:	moveq.l	#%11,d0
		and.l	$466.w,d0
		bne.s	.break

		tst.w	strPalObjBrgt	; Min. brightness approached?
		beq.s	.done

                subq.w	#1,strPalObjBrgt
.break:		rts

.done:		clr.l	VBLHookPtr
		rts

		data
strPalObj:
strPalObjBrgt:	dc.w	15		; Credit string palette object
		dc.l	greyPal

strPalObjY:	dc.w	2	; y distance
		dc.w	15	; brightness
		dc.l	greyPal

bright		set	1
	rept	14
                dc.w	2
		dc.w	15-bright	; brightness
		dc.l	greyPal
bright		set	bright+1
	endr

		dc.w	-1


strObj:		dc.l	.msxStr		; NULL-terminated credit text object
		dc.w	80,68
		dc.l	.gfxStr1
		dc.w	80,84
		dc.l	.gfxStr2
		dc.w    80,100
		dc.l	.codeStr
		dc.w	80,116
		dc.l	NULL

.msxStr:	dc.b	'msx...lotek',0
.gfxStr1:	dc.b	'gfx...c-rem',0
.gfxStr2:	dc.b	'......havoc',0
.codeStr:	dc.b	'code....ray',0
		even

greyPal:	dc.w	$000,$888,$111,$999
		dc.w	$222,$aaa,$333,$bbb
		dc.w	$444,$ccc,$555,$ddd
		dc.w	$666,$eee,$777,$fff


