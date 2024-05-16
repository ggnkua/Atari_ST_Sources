; Outline top and bottom logo, image crossfade effects, outline 2007 intro, by ray//.tSCc., 2007

OUTLOGO_X	=	256	; The Logos' pixel dimensions
OUTLOGO_Y	=	35

YSCROLL		=	32	; Top/bottom logo max. scrolling amount

LOGO_X		=	256	; Unified interlude image pixel size
LOGO_Y		=	128


		data
logoPalObj:
logoFade1:	dc.w	15		; Logo split palette object
		dc.l	outPal

                dc.w	OUTLOGO_Y-1
logoFade2:	dc.w	1
logoPalPatch:	dc.l	tsccPal

		dc.w	LOGO_Y-1
logoFade3:	dc.w	15
		dc.l	outPal

		dc.w	-1


; Palettes

outPal:		include	'outpal.i'
tsccPal:	include	'tsccpal.i'
fujiPal:	include	'logo2.i'	;;'fuji2pal.i'
greetPal:	include	'grtings.i'

; Packed image data

outLogoPak:	incbin	'outlogo.lz7'	; NOTE: Both must have the same pixel size!
		even
out2007LogoPak:	incbin	'2007logo.lz7'
		even
fujiPak1:	incbin	'logo.lz7'	;;'fuji2.lz7'
		even
tsccPak:	incbin	'tscclogo.lz7'
		even
titlePak:	incbin	'logo2.lz7'
		even

		bss
outLogoPtr:	ds.l	1
out2007LogoPtr:	ds.l	1
fujiPtr1:	ds.l	1
tsccPtr:	ds.l	1
titlePtr:	ds.l	1


******************************************************
*  void logoInit()
*
* Prepare outline logos.
******************************************************

		text
logoInit:	move.l	#OUTLOGO_X*OUTLOGO_Y/2,d0	; Allocate arrays
		moveq.l	#TTRAM,d1
		bsr.w	AllocSomeMem
		move.l	d0,outLogoPtr

		lea.l	outLogoPak,a0	; Decrunch logos
		movea.l	d0,a1
		bsr.w	d_lz77

		move.l	#OUTLOGO_X*OUTLOGO_Y/2,d0
		moveq.l	#TTRAM,d1
		bsr.w	AllocSomeMem
		move.l	d0,out2007LogoPtr

		lea.l	out2007LogoPak,a0
		movea.l	d0,a1
		bsr.w	d_lz77


; Decrunch intermission images

		move.l	#LOGO_X*LOGO_Y,d0
		moveq.l	#TTRAM,d1
		bsr.w	AllocSomeMem
		move.l	d0,fujiPtr1

		lea.l	fujiPak1,a0
		movea.l	d0,a1
		bsr.w	d_lz77

       		move.l	#LOGO_X*LOGO_Y,d0
		moveq.l	#TTRAM,d1
		bsr.w	AllocSomeMem
		move.l	d0,titlePtr

		lea.l	titlePak,a0
		movea.l	d0,a1
		bsr.w	d_lz77

  		lea.l	logoPalObj,a0
  		bsr.w	installSplitPalette

		bsr.w	clearScreens
                bra.w	setSemaphore


******************************************************
*  void logoDeInit()
*
* Release logo bitmap arrays.
******************************************************

;>logoDeInit:     move.l	outLogoPtr,d0
;>		bsr.w	FreeSomeMem
;>
;>		move.l	out2007LogoPtr,d0
;>		bra.w	FreeSomeMem


******************************************************
*  void drawLogo(a1.l * dst, d0.w pixelHeight)
*
* Draw "pixelHeight" scanlines of the outline 2007 logo
* at the upper and lower screen borders.
******************************************************

logoScrollY:	dc.w	0		; Vertical logo scrolling amount

drawLogo:	tst.w	d0		; Draw anything?
		ble.s	.break

		cmpi.w	#OUTLOGO_Y,d0	; Clip scroll value
		ble.s	.ok
		moveq.l	#OUTLOGO_Y,d0

.ok:		lea.l	((PHYS_X-OUTLOGO_X)/2)/2(a1),a1	; Center bounding box
		lea.l	BYTESPERSCL*PHYS_Y(a1),a3	; Screen bottom

		movea.l	outLogoPtr,a0		; Top logo
		movea.l	out2007LogoPtr,a2	; Bottom logo

		move.w	#OUTLOGO_Y,d1		; Compute source skip (top)
		sub.w	d0,d1
		mulu.w	#OUTLOGO_X/2,d1
		adda.l	d1,a0

		move.w	d0,d1
		mulu.w	#BYTESPERSCL,d1		; Compute destination skip (bottom)
		suba.l	d1,a3

		bra.s	.entry

.yloop:		moveq.l	#OUTLOGO_X/2/16-1,d1

.xloop:
	rept	4
		move.l	(a0)+,(a1)+
		move.l	(a2)+,(a3)+
	endr
		dbra	d1,.xloop

		lea.l	(PHYS_X-OUTLOGO_X)/2(a1),a1	; Destination interleave
		lea.l	(PHYS_X-OUTLOGO_X)/2(a3),a3

.entry:		dbra	d0,.yloop
.break		rts


******************************************************
*  void drawImage(a0.l * src, a1.l * dsr, d0.w width, d1.w height, d2.w pixelOfs)
*
* Blend in the given source image based on the current
* pixel offset, and width and height parameters.
*
* NOTE: Width must be a mulitple of 16 pixels!
******************************************************

drawImage:	cmpi.w	#31,d2		; Blank out image?
		bls.s	.ok
		moveq.l	#0,d3		; Clear pixel mask
        	bra.s	.blank

.ok:            add.w	d2,d2
		move.w	.x_masks(pc,d2.w),d3	; Retrieve pixel mask
		move.w	d3,d4			; Longword expand
		swap.w	d3
		move.w	d4,d3

.blank:		lea.l	BYTESPERSCL.w,a2	; Compute destination increment
		move.w	d0,d4
		lsr.w	d4
		suba.w	d4,a2


		lea.l	sin,a3		; Distortion table
		lsl.w	#4,d2		; Normalize pixelOfs

		bra.s	.yentry		; Enter scanline loop

.yloop:         move.w	d1,d7		; Normalize y
		lsl.w	#5,d7

		add.w	d2,d7
		andi.w	#2048-1,d7	; Angle mask
		add.w	d7,d7
		move.w	(a3,d7.w),d7	; Get sin(y + pixelOfs)
		asr.w	#8,d7
		asr.w	#3,d7

		move.l	d3,d4           ; Distorted mask
		ror.l	d7,d4

		move.w	d0,d7		; width/16
		lsr.w	#4,d7
		bra.s	.xentry

.xloop:         move.l	(a0)+,d5	; Load 16 pixels
		move.l	(a0)+,d6
		and.l	d4,d5		; Mask out blank pixels
		and.l	d4,d6
		move.l	d5,(a1)+	; Plot visible pixels (4 bitplanes)
		move.l	d6,(a1)+

.xentry:	dbra	d7,.xloop

		adda.l	a2,a1		; Add destination increment

.yentry:	dbra	d1,.yloop
		rts


.x_masks:	dc.w	%1000000000000000	; Scroll in masks
		dc.w	%1100000000000000
		dc.w	%1110000000000000
		dc.w	%1111000000000000
		dc.w	%1111100000000000
		dc.w	%1111110000000000
		dc.w	%1111111000000000
		dc.w	%1111111100000000
		dc.w	%1111111110000000
		dc.w	%1111111111000000
		dc.w	%1111111111100000
		dc.w	%1111111111110000
		dc.w	%1111111111111000
		dc.w	%1111111111111100
		dc.w	%1111111111111110
		dc.w	%1111111111111111

		dc.w	%1111111111111111	; Scroll out masks
       		dc.w	%0111111111111111
                dc.w	%0011111111111111
		dc.w	%0001111111111111
		dc.w	%0000111111111111
       		dc.w	%0000011111111111
                dc.w	%0000001111111111
		dc.w	%0000000111111111
		dc.w	%0000000011111111
       		dc.w	%0000000001111111
                dc.w	%0000000000111111
		dc.w	%0000000000011111
		dc.w	%0000000000001111
		dc.w	%0000000000000111
                dc.w	%0000000000000011
		dc.w	%0000000000000001


******************************************************
*  void logoInMain()
*  void logoOutMain()
*
* Show/hide top and bottom logo.
******************************************************

logoInMain:	bsr.w	wVBL

		cmpi.w	#OUTLOGO_Y,logoScrollY
		bhs.s	.done
		addq.w	#1,logoScrollY

.done:          move.w	logoScrollY(pc),d0
		movea.l	screen3(pc),a1
		bsr.w	drawLogo
		bra.w	cycleScreens


logoOutMain:	bsr.w	wVBL

		movea.l	screen3(pc),a0		; Clear screen
		move.l	#BYTESPERSCL*PHYS_Y,d0
		moveq.l	#0,d1
		bsr.w	ClearBlock

		tst.w	logoScrollY
		ble.s	.done2
		subq.w	#1,logoScrollY

.done2:		move.w	logoScrollY(pc),d0	; Draw scrolling logos
		movea.l	screen3(pc),a1
		bsr.w	drawLogo
		bra.w	cycleScreens


******************************************************
*  void interludeInit(a0.l * palObj, a1.l * srcImg)
*  void interludeDeinit(a0.l * srcImg)
*
* Show/hide given interlude screen.
******************************************************

pixelOfs:	dc.w	0

interludeInit:	move.l	a1,.which	; Save source image
        	bsr.w	installSplitPalette

		clr.w	pixelOfs

.interlude:	bsr.w	wVBL

;>		bsr.w	getTime		; Retrieve keyframing delta
;>		lsr.w	#2,d0
;>		tst.w	d0		; Don't let it drop below 1
;>		bne.s	.draw
;>
;>		moveq.l	#1,d0

.draw		cmpi.w	#16,pixelOfs	; Done scrolling in?
		beq.s	.break
;>		add.w	d0,pixelOfs
		addq.w	#1,pixelOfs

		movea.l	.which(pc),a0	; Source image
		movea.l	screen3(pc),a1

		lea.l	((PHYS_X-LOGO_X)/2)/2+BYTESPERSCL*((PHYS_Y-LOGO_Y)/2)(a1),a1

		move.w	#LOGO_X,d0
		move.w	#LOGO_Y,d1
		move.w	pixelOfs(pc),d2
		bsr.w	drawImage

		bsr.w	cycleScreens
		bra.s	.interlude

.break:		rts

.which:		dc.l	NULL		; Source image pointer


interludeDeinit:move.l	a0,.which

.interlude:
;>		bsr.w	getTime		; Same as above
;>		lsr.w	#2,d0
;>		tst.w	d0
;>		bne.s	.draw
;>		moveq.l	#1,d0
		bsr.w	wVBL

.draw:		cmpi.w	#YSCROLL,pixelOfs	; Done scrolling out?
		bhi.s	.break
;>		add.w	d0,pixelOfs
		addq.w	#1,pixelOfs

		movea.l	.which(pc),a0	; Source image
		movea.l	screen3(pc),a1
		lea.l	((PHYS_X-LOGO_X)/2)/2+BYTESPERSCL*((PHYS_Y-LOGO_Y)/2)(a1),a1

		move.w	#LOGO_X,d0
		move.w	#LOGO_Y,d1
		move.w	pixelOfs(pc),d2
		bsr.w	drawImage

		bsr.w	cycleScreens
		bra.s	.interlude

.break:		rts

.which:		dc.l	NULL

*********************************************************
*  void logoFadeIn()
*  void logoFadeOut()
*
* Fading VBL hook routines.
*********************************************************

logoFadeIn:	moveq.l	#3,d0
		and.l	$466.w,d0	; Fade every 4th VBL
		bne.s	.break

		cmpi.w	#(1<<PHYS_BPP)-1,logoFade2	; Max. brightness approached yet?
		beq.s	.done

		addq.w	#1,logoFade2
.break:		rts

.done:		clr.l	VBLHookPtr
		rts


logoFadeOut:	moveq.l	#3,d0		; Fade every 4th VBL
		and.l	$466.w,d0
		bne.s	.break

      		tst.w	logoFade2	; Min. brightness approached yet?
		beq.s	.done

		subq.w	#1,logoFade2

.break:		rts

.done:          clr.l	VBLHookPtr
		rts
