; Video library v1.0, ray//.tSCc. 2004

************************************************************
*  void setBase(d0.l &physBase)
*
* Update physical screenbase. Note: Address must be byte
* aligned. Call from vertical blank handler!
************************************************************
		section	text
setBase		lsr.w	#8,d0
		move.l	d0,$ffff8200.w
		rts

		
************************************************************
*  void cycleScreens(d0.w numScreens)
*
* Cycle workscreens. Allows a maximum of four workscreens.
************************************************************

cycleScreens	movem.l	actScreen(pc),d1-d4
		subq.w	#2,d0
		lsl.w	#4,d0
		movem.l	.cycle(pc,d0.w),a1-a4
		
		move.l	d1,(a1)		; Swap screen pages
		move.l	d2,(a2)
		move.l	d3,(a3)
		move.l	d4,(a4)
		
		clr.b	baseUpdate	; vbl semaphore
		rts

.cycle		dc.l	wrkScreen1,actScreen,wrkScreen2,wrkScreen3	; Double buffer
		dc.l	wrkScreen1,wrkScreen2,actScreen,wrkScreen3	; Tripple buffer
		dc.l	wrkScreen1,wrkScreen2,wrkScreen3,actScreen	; Quad buffer

actScreen	ds.l	1	; Screen page pointers
wrkScreen1	ds.l	1
wrkScreen2	ds.l	1
wrkScreen3	ds.l	1

baseUpdate	dc.b	TRUE
		even


************************************************************
*  void setMode(d0.w mode, d1.w rate, d3.b bool greyScale)
*
* Update video mode according to the specified parameters.
*************************************************************

MODE320480	=	0	; Resolution constants
MODE288180	=	1
MODE320180	=	2
MODE320200	=	3

RFRSH5060	=	0	; Refrash rate constants
RFRSH60100	=	1

logSize		ds.l	1	; Size of logical view buffer
logXres		ds.w	1	; Resolution of the logical view buffer
logYres		ds.w	1
logYinc		ds.w	1	; Scanline interleave

physSize	ds.l	1
physDisplace	ds.l	1

setMode		mulu.w	#6,d0	; Initialise resolution
		movem.w	(.mode0,pc,d0.l),d4-d6

		move.w	d4,d7	; Compute logical screen size
		mulu.w	d5,d7
		move.l	d7,logSize

		tst.w	sysMachine	; Initialise video
		bne.s	.f030		; hardware
	
	
; TT030 video hardware

.tt030		mulu.w	#TTXRES,d1	; Set Interlaced mode
		add.w	d1,d6		; (emulated 100Hz)
		
		movem.w	d4-d6,logXres
			
		; Compute physical screen displacement to
		; center the virtual screen buffer
		move.l	#TTXRES*(TTYRES+1)/2,d7
		add.w	#TTXRES,d1
		mulu.w	d5,d1
		lsr.l	d1
		sub.l	d1,d7
		lsr.l	d4
		sub.l	d4,d7
		move.l	d7,physDisplace

		moveq.l	#%111,d4	; Physical mode (320x480x8bpl)

		tst.b	d3		; Grayscale mode?
		beq.s	.color		
		bset.l	#3,d4
		
.color		move.b	d4,$ffff8262.w	; Set __TTShiftMode
		rts


; F030 video hardware

.f030		movem.w	d4-d6,logXres

		move.w	sysMonitor(pc),d0
;>		add.w	d0,d0		; Choose screen preset (RGB, VGA)
;>		or.w	d1,d0
		mulu.w	#158,d0		; Choose refresh preset (50, 60, 100Hz)

		lea.l	(.r50hz+122,pc,d0.l),a0; Set videl registers
		move.l  (a0)+,$ffff8282.w
                move.l  (a0)+,$ffff8286.w
                move.l  (a0)+,$ffff828a.w
                move.l  (a0)+,$ffff82a2.w
                move.l  (a0)+,$ffff82a6.w
                move.l  (a0)+,$ffff82aa.w
                move.w  (a0)+,$ffff820a.w
                move.w  (a0)+,$ffff82c0.w
                move.w  (a0)+,$ffff8266.w
                move.w  (a0)+,$ffff8266.w
                move.w  (a0)+,$ffff82c2.w
                move.w  (a0)+,$ffff8210.w
		rts


; Resolution presets

.mode0		dc.w	320,480,0
;>.mode1		dc.w	288,180,320-288
;>.mode2		dc.w	320,180,320-320
;>.mode3		dc.w	320,200,320-320

; Videl presets
.r50hz		incbin	'320x480r.scp'	; Tnx earx for making this up
;>.r60hz		dcb.b	158,0
.v60hz		incbin	'320x480v.scp'
;>.v100hz		dcb.b	158,0


************************************************************
*  void blit6bpp(a0.l * Src, a1.l * Dst)
*
* Blit one horizontal scanline (6bpp) into the given physical
* screen (8bpl)
************************************************************

blit6bpp	movem.l	d0-a0/a2-a6,-(sp)

		move.l	#$0f0f0f0f,d4
		move.l	#$00ff00ff,d5
		move.l	#$55555555,d6

		lea.l	XRES(a0),a2	; Dst limit
		move.l	(a0)+,d0
		move.l	(a0)+,d1
		move.l	(a0)+,d2
		move.l	(a0)+,d3

		move.l	d1,d7
		lsr.l	#4,d7
		eor.l	d0,d7
		and.l	d4,d7
		eor.l	d7,d0
		lsl.l	#4,d7
		eor.l	d7,d1
		move.l	d3,d7
		lsr.l	#4,d7
		eor.l	d2,d7
		and.l	d4,d7
		eor.l	d7,d2
		lsl.l	#4,d7
		eor.l	d7,d3

		move.l	d2,d7
		lsr.l	#8,d7
		eor.l	d0,d7
		and.l	d5,d7
		eor.l	d7,d0
		lsl.l	#8,d7
		eor.l	d7,d2
		move.l	d3,d7
		lsr.l	#8,d7
		eor.l	d1,d7
		and.l	d5,d7
		eor.l	d7,d1
		lsl.l	#8,d7
		eor.l	d7,d3
	
		bra.s	.start
		
.pix16		move.l	(a0)+,d0
		move.l	(a0)+,d1
		move.l	(a0)+,d2
		move.l	(a0)+,d3

		move.l	d1,d7
		lsr.l	#4,d7
		move.l	a4,(a1)+
		eor.l	d0,d7
		and.l	d4,d7
		eor.l	d7,d0
		lsl.l	#4,d7
		eor.l	d7,d1
		move.l	d3,d7
		lsr.l	#4,d7
		eor.l	d2,d7
		and.l	d4,d7
		eor.l	d7,d2
		move.l	a5,(a1)+
		lsl.l	#4,d7
		eor.l	d7,d3

		move.l	d2,d7
		lsr.l	#8,d7
		eor.l	d0,d7
		and.l	d5,d7
		eor.l	d7,d0
		lsl.l	#8,d7
		eor.l	d7,d2
		move.l	a6,(a1)+
		move.l	d3,d7
		lsr.l	#8,d7
		addq.l	#4,a1
		eor.l	d1,d7
		and.l	d5,d7
		eor.l	d7,d1
		lsl.l	#8,d7
		eor.l	d7,d3
	
.start		move.l	d2,d7
		lsr.l	#1,d7
		eor.l	d0,d7
		and.l	d6,d7
		eor.l	d7,d0
		add.l	d7,d7
		eor.l	d7,d2
		move.l	d3,d7
		lsr.l	#1,d7
		eor.l	d1,d7
		and.l	d6,d7
		eor.l	d7,d1
		add.l	d7,d7
		eor.l	d7,d3

		move.w	d2,d7
		move.w	d0,d2
		swap.w	d2
		move.w	d2,d0
		move.w	d7,d2
		move.w	d3,d7
		move.w	d1,d3
		swap.w	d3
		move.w	d3,d1
		move.w	d7,d3

		move.l	#$33333333,d7
		and.l	d7,d0
		and.l	d7,d2
		lsl.l	#2,d0
		or.l	d2,d0

		move.l	d3,d7
		lsr.l	#2,d7
		eor.l	d1,d7
		and.l	#$33333333,d7
		eor.l	d7,d1
		lsl.l	#2,d7
		eor.l	d7,d3

		swap.w	d0
		swap.w	d1
		swap.w	d3

		move.l	d0,a6
		move.l	d1,a5
		move.l	d3,a4

		cmpa.l	a0,a2
		bne.w	.pix16

		move.l	a4,(a1)+
		move.l	a5,(a1)+
		move.l	a6,(a1)+

		lea.l	4+PHYSX-XRES(a1),a1	; Scanline grille (TT)	
		movem.l	(sp)+,d0-a0/a2-a6
		rts

		section	bss
lineBuffer	ds.b	XRES
		even


************************************************************
*  setPalette(a0.l * palette)
*
* Update the systems hardware palette. "palette" is assumed to
* be a 32 bit ARGB formatted color array of 256 entries.
* Note: call this close to the beginning of a vbl!
************************************************************

		section	text
setPalette	tst.w	sysMachine	; Properly select
		bne.s	.f030		; video hardware


addsat		macro		; Saturated 8bit addition
		add.\0	\1,\2
		bcc.s	.\@c
		st.b	\2
	ifnc	'\0','b'
		ext.\0	\2
	endc
.\@c		
		endm
		
subsat		macro		; Saturated 8bit substraction
		sub.\0	\1,\2
		bcc.s	.\@c
		sf.\0	\2		
.\@c
		endm


; TT030 video, -RGB format

		lea.l	$ffff8400.w,a1	; TT shifter palette

		move.w	#256-1,d0
.tpal		move.b	(a0)+,d1	; Alpha
		move.b	(a0)+,d2	; Red
		move.b	(a0)+,d3	; Green
		move.b	(a0)+,d4	; Blue

		add.b	d1,d1		; Alpha *= 2
		bcc.s	.tlighten
		
		not.b	d1
		subsat.b	d1,d2	; Darken color
		subsat.b	d1,d3
		subsat.b	d1,d4
		bra.s	.tdarken

.tlighten	addsat.b	d1,d2	; Lighten color
		addsat.b	d1,d3
		addsat.b	d1,d4

.tdarken	lsl.w	#4,d2	; Merge channels
		move.b	d3,d2
		lsl.w	#4,d2
		move.b	d4,d2
		lsr.w	#4,d2

		move.w	d2,(a1)+; Store color

		dbra	d0,.tpal
		rts


; F030 video, RRGG--BB format

.f030		lea.l	$ffff9800.w,a1	; Videl palette

		move.w	#256-1,d0
.fpal		move.b	(a0)+,d1	; Alpha
		move.b	(a0)+,d2	; Red
		move.b	(a0)+,d3	; Green
		move.b	(a0)+,d4	; Blue

		add.b	d1,d1	; Alpha *= 2
		bcc.s	.flighten
		
		not.b	d1
		subsat.b	d1,d2	; Darken color
		subsat.b	d1,d3
		subsat.b	d1,d4
		bra.s	.fdarken

.flighten	addsat.b	d1,d2	; Lighten color
		addsat.b	d1,d3
		addsat.b	d1,d4

.fdarken	lsl.w	#8,d2	; Merge channels
		move.b	d3,d2
		swap.w	d2
		move.b	d4,d2
		
		move.l	d2,(a1)+

		dbra	d0,.fpal
		rts
		

************************************************************
*  void setPixel(a0.l * Dst, d0.w x, d1.w y, d2.b color)
*
* Put a pixel (8bpp) at the specified screen position
************************************************************

setPixel	moveq.l	#15,d3		; horizonzal bit skew
		and.w	d0,d3
		eori.w	#15,d3

		lsr.w	#4,d0
		lsl.w	#4,d0
		adda.w	d0,a0

		mulu.w	#PHYSX,d1
		adda.l	d1,a0

		moveq.l	#COLORDEPTH-1,d4; Loop through each plane	
.planeloop	move.w	(a0),d0
		lsr.b	d2		; Next bit
		bcc.s	.clear

.set		bset.l	d3,d0		; Set/Clear accordant bit
		move.w	d0,(a0)+
		dbra	d4,.planeloop
		rts
		
.clear		bclr.l	d3,d0
		move.w	d0,(a0)+
		dbra	d4,.planeloop
		rts


************************************************************
*  d2.b getPixel(a0.l * Src, d0.w x, d1.w y)
*
* Get the color value of a pixel in the specified screen position
************************************************************

getPixel	moveq.l	#15,d3
		and.w	d0,d3
		eori.w	#15,d3

		lsr.w	#4,d0
		lsl.w	#4,d0
		adda.w	d0,a0

		mulu.w	#PHYSX,d1
		adda.l	d1,a0

		sf.b	d2

		moveq.l	#COLORDEPTH-1,d4; Loop through each plane	
.planeloop	move.w	(a0)+,d0
		btst.l	d3,d0
		beq.s	.clear
		addq.b	#1,d2		; Set according to bit in plane

.clear		ror.b	d2
		dbra	d4,.planeloop
		rts
