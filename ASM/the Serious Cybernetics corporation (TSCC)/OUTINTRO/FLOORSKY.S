; DOOM sorta sky-/flooremapping, by ray//.tSCc., June 23rd, 2001


FRDR_XWIN	=	128		; Effect window resolution
FRDR_YWIN	=	60		; (half height)

FRDR_FLR_U	=	256		; Floor texture resolution
FRDR_FLR_V	=	256

FRDR_SKY_U	=	384		; Sky texture resolution
FRDR_SKY_V	=	60

FRDR_ANGLES 	=	256

; Freedir palette object, must be -1 terminated
		data
frdrPalObj:     dc.w	15		; brightness1
		dc.l	outPal		; &palette1

		dc.w	OUTLOGO_Y-1     ; scanline2
frdrSkyFade:	dc.w	1		; brightness2
		dc.l	skyPal		; &palette2

		dc.w	FRDR_YWIN+1	; scanline3
frdrFloorFade:	dc.w	1		; brightness3
		dc.l	floorPal

		dc.w	FRDR_YWIN,15	; scanline4, brightness4
		dc.l	outPal

		dc.w    -1


******************************************************
*  Doom like screen demo sequencing routines.
******************************************************
		text
fadeInDoom:	bsr.w	clearScreens

		lea.l	frdrPalObj,a0
		bsr.w	installSplitPalette

		move.l	#frdrFadeIn,VBLHookPtr
		bra.w	setSemaphore

fadeOutDoom:	move.l	#frdrFadeOut,VBLHookPtr
		bra.w	doomMain


*********************************************************
*  void frdrFadeIn()
*  void frdrFadeOut()
*
* Fading VBL hook routines.
*********************************************************

		text
frdrFadeIn:	moveq.l	#3,d0
		and.l	$466.w,d0	; Fade every 4th VBL
		bne.s	.break

		moveq.l	#(1<<PHYS_BPP)-1,d0	; Max. brightness

		cmp.w	frdrSkyFade(pc),d0	; Max. brightness approached yet?
		beq.s	.done

		addq.w	#1,frdrSkyFade
		addq.w	#1,frdrFloorFade

.break:		rts

.done:		clr.l	VBLHookPtr
		rts


frdrFadeOut:	moveq.l	#3,d0		; Fade every 4th VBL
		and.l	$466.w,d0
		bne.s	.break

      		tst.w	frdrSkyFade	; Min. brightness approached yet?
		beq.s	.done

		subq.w	#1,frdrSkyFade
		subq.w	#1,frdrFloorFade

.break:		rts

.done:          clr.l	VBLHookPtr
		rts



*******************************************************
*  void initDoom()
*
* Initialise effect.
*******************************************************

initDoom:	lea.l	divtbl,a0	; Generate 1/x table
		move.l	#persp,d0

		moveq	#1,d1

.gen_div:	move.l	d0,d2
		divu	d1,d2
		move.w	d2,(a0)+

		addq.w	#1,d1
		cmpi.w	#FRDR_YWIN,d1
		bls.s	.gen_div

; Deflate textures

		move.l	#FRDR_FLR_U*FRDR_FLR_V+$00010000,d0
		moveq	#TTRAM,d1
		bsr	AllocSomeMem
		move.l	d0,floorTexPtr

		addi.l	#$0000ffff,d0	; Align destination array to 64k boundary
		clr.w	d0
		move.l	d0,floorTexAligned
		movea.l d0,a1

		lea.l	floorTexPak,a0
		bsr.w	d_lz77

		move.l	#FRDR_SKY_U*FRDR_SKY_V,d0
		moveq	#TTRAM,d1
		bsr	AllocSomeMem
		move.l	d0,.skyTexTmp

		lea.l	skyTexPak,a0
		movea.l d0,a1
		bsr.w	d_lz77

; Create preshifted sky textures in 4 bitplanes

		move.l	#4*FRDR_SKY_U*FRDR_SKY_V,d0 ; Allocate preshifted texture arrays
		moveq	#TTRAM,d1
		bsr	AllocSomeMem

		movea.l .skyTexTmp,a0	; Source texture, 8(4) bpp

		movea.l d0,a1		; Four texture preshifts
		lea	FRDR_SKY_U*FRDR_SKY_V.w,a5
		lea	0(a1,a5.l),a2
		lea	0(a2,a5.l),a3
		lea	0(a3,a5.l),a4
		movem.l a1-a4,skyPat1Ptr

		lea.l	c2p1(pc),a5
		lea.l	c2p3(pc),a6

		moveq	#0,d1

		move.w	#FRDR_SKY_U*FRDR_SKY_V/4-1,d0

.preshift_sky:	move.b	(a0)+,d1
		lsl.b	#2,d1
		move.l	0(a5,d1.l),d2	; 1st preshift

		move.b	(a0)+,d1
		lsl.b	#2,d1
		or.l	16*4(a5,d1.l),d2
		move.l	0(a5,d1.l),d3	; 2nd preshift

		move.b	(a0)+,d1
		lsl.b	#2,d1
		or.l	0(a6,d1.l),d2
		or.l	16*4(a5,d1.l),d3
		move.l	0(a5,d1.l),d4	; 3rd preshift

		move.b	(a0)+,d1
		lsl.b	#2,d1
		or.l	16*4(a6,d1.l),d2
		or.l	0(a6,d1.l),d3
		or.l	16*4(a5,d1.l),d4
		move.l	0(a5,d1.l),d5	; 4th preshift

		move.b	(a0)+,d1
		lsl.b	#2,d1
		or.l	16*4(a6,d1.l),d3
		or.l	0(a6,d1.l),d4
		or.l	16*4(a5,d1.l),d5

		move.b	(a0)+,d1
		lsl.b	#2,d1
		or.l	16*4(a6,d1.l),d4
		or.l	0(a6,d1.l),d5

		move.b	(a0)+,d1
		lsl.b	#2,d1
		or.l	16*4(a6,d1.l),d5

		subq.l	#3,a0

		move.l	d2,(a1)+
		move.l	d3,(a2)+
		move.l	d4,(a3)+
		move.l	d5,(a4)+

		dbra	d0,.preshift_sky



; Preshift floor texture

		movea.l floorTexAligned,a0
		move.w	#FRDR_FLR_U*FRDR_FLR_V/2-1,d0
.preshift_floor:
	rept 2
		move.b	(a0),d1
		lsl.b	#2,d1
		move.b	d1,(a0)+
	endr
		dbra	d0,.preshift_floor

		move.l	.skyTexTmp(pc),d0
		bsr.w	FreeSomeMem

; Convert palettes

		lea	skyPalette,a0
		lea	skyPal,a1
		bsr.w	convPalette

		lea.l	floorPalette,a0
		lea.l	floorPal,a1
		bra.w	convPalette

;>		lea.l	frdrPalObj,a0
;>		bra.w	installSplitPalette

.skyTexTmp:	ds.l	1		; Temporary array



*******************************************************
*  void restoreDoom()
*
* Deinitialise effect.
*******************************************************

restoreDoom:	move.l	screen3(pc),a0	; Clear screen
		lea.l	OUTLOGO_Y*BYTESPERSCL(a0),a0
		move.l	#(PHYS_Y-2*OUTLOGO_Y)*BYTESPERSCL,d0
		moveq.l	#0,d1
		bsr.w	ClearBlock
                bsr.w	cycleScreens
	        
;>		bsr.w	uninstallSplitPalette

		move.l	skyPat1Ptr,d0	; Release texture arrays
		bsr.w	FreeSomeMem
	    	move.l	floorTexPtr,d0
		bra.w	FreeSomeMem



*******************************************************
*  void plotSky(d0.b facing, a0.l * dst)
*
* Plot a texturemapped parallaxing sky. The given
* destination screen is assumed to be BYTESPERSCL bytes
* wide and in 4bpl.
*******************************************************

skyPat1Ptr:	ds.l	1		; Preshifted sky textures (4bpl)
skyPat2Ptr:	ds.l	1
skyPat3Ptr:	ds.l	1
skyPat4Ptr:	ds.l	1

plotSky:	lsr.w	#3,d0
		andi.w	#FRDR_SKY_U-1-(FRDR_ANGLES/2),d0

		lea	skyPat1Ptr,a1	; Select appropriate preshifted pattern
		move.w	d0,d1
		andi.w	#3,d1
		lsl.w	#2,d1
		movea.l 0(a1,d1.w),a1

		andi.w	#-4,d0		; Pixel skew
		adda.w	d0,a1

		moveq.l	#0,d1

		moveq.l	#FRDR_YWIN-1,d0

.yloop_sky:

ofs	set	(BYTESPERSCL-FRDR_XWIN)/2 ; Center destination window
ofs	set	ofs+BYTESPERSCL*(PHYS_Y/2-FRDR_YWIN-1)

	rept	FRDR_XWIN/16

		movem.l (a1)+,d2-d5	; Load 16 pixels

		movep.l d2,ofs(a0)	; Put 16 pixels
		movep.l d3,ofs+1(a0)
		movep.l d4,ofs+8(a0)
		movep.l d5,ofs+9(a0)

ofs	set	ofs+16
	endr

		lea.l	((FRDR_SKY_U-FRDR_XWIN))&-4(a1),a1 ; Source texture interleav
		lea.l	BYTESPERSCL(a0),a0		; Scanline interleave

		dbra	d0,.yloop_sky
		rts


*******************************************************
*  void plotFloor(d1.b angle, a1.l * dst)
*
* Plot a perspectively texturemapped floor.
* Note: The texture must be aligned to a 64k boundary
*******************************************************

floorTexPtr:	ds.l 1
floorTexAligned:ds.l 1		; Floor texture aligned to a 64 boundary, 8(4) bpp

persp		=	$00010000	; Perspective distortion value
size		=	6		; Zoom value

u0:		dc.l	0		; Texture offset
v0:		dc.l	0
facing: 	dc.w	0		; Heading

plotFloor:	lea.l	sin,a0
		move.w	#(2048-1)<<1,d2 ; Angle mask
		and.w	d2,d1

		move.w	(a0,d1.w),d0	; sin(angle)
		addi.w	#(2048/4)<<1,d1
		and.w	d2,d1
		move.w	(a0,d1.w),d1	; cos(angle)

		movem.l	u0(pc),d3-d4
		lsr.l	#3,d3
		lsr.l	#3,d4
		lsr.l	#8-1,d3
		lsr.l	#8-1,d4


		and.w	d2,d3
		addi.w	#(1048/4)<<1,d4
		and.w	d2,d4
		move.w	(a0,d3.w),d3
		move.w	(a0,d4.w),d4
		lsl.w	#6,d3
		lsl.w	#6,d4
		movea.w	d3,a3
		movea.w	d4,a4

		lea	divtbl,a0	; Inverse table

; Center output window

		lea	BYTESPERSCL*PHYS_Y/2+(BYTESPERSCL-FRDR_XWIN)/2(a1),a1


;>		movem.w u0(pc),a3-a4	; u0,v0

.yloop_flr:	move.w	(a0)+,d3	; persp / z
		move.w	d3,d4
		muls	d1,d3		; cos(angle) * persp / z
		muls	d0,d4		; sin(angle) * persp / z

		moveq	#8+size,d7

		move.l	d3,d5		; du/dx
		asr.l	d7,d5
		asr.l	#8,d3

		move.l	d4,d6		; dv/dx
		asr.l	d7,d6
		asr.l	#8,d4

		move.w	d5,d2
		muls	#-FRDR_XWIN/2,d2
		sub.w	a3,d2
		add.w	d4,d2		; u = (-xsize/2)*du/dx-u0+cos(angle)*persp/z

		move.w	d6,d4
		muls	#-FRDR_XWIN/2,d4
		sub.w	a4,d4
		sub.w	d3,d4		; v = (-xsize/2)*dv/dx-v0-sin(angle)*persp/z

		moveq	#0,d3		; Reorganize u,v, du,dv for fast
		lsl.l	#8,d4		; addx scaling
		move.b	d2,d4
		lsr.w	#8,d2
		ror.l	#8,d4

		lsl.l	#8,d6
		move.b	d5,d6
		ror.l	#8,d6
		lsr.w	#8,d5

		movem.l d0/a3-a6,-(sp)

		moveq	#0,d0
		lea	c2p1(pc),a3
		lea	c2p2(pc),a4
		lea	c2p3(pc),a5
		lea	c2p4(pc),a6

		move.l	floorTexAligned,d3

ofs	set	0
	rept	FRDR_XWIN/8
		move.w	d4,d3
		move.b	d2,d3
		movea.l d3,a2		; Faster than indexed addressing
		move.b	(a2),d0 	; Store pixel
		add.l	d6,d4		; uu--VVvv += d(uu--VVvv)/dx
		addx.b	d5,d2		; UU += d(UU)/dx

		move.l	0(a3,d0.l),d7

		move.w	d4,d3
		move.b	d2,d3
		movea.l d3,a2
		move.b	(a2),d0 	; Next pixel
		add.l	d6,d4
		addx.b	d5,d2

		or.l	0(a4,d0.l),d7

		move.w	d4,d3
		move.b	d2,d3
		movea.l d3,a2
		move.b	(a2),d0
		add.l	d6,d4
		addx.b	d5,d2

		or.l	0(a5,d0.l),d7

		move.w	d4,d3
		move.b	d2,d3
		movea.l d3,a2
		move.b	(a2),d0
		add.l	d6,d4
		addx.b	d5,d2

		or.l	0(a6,d0.l),d7

		movep.l d7,ofs(a1)	; Plot four doublepixels


		move.w	d4,d3
		move.b	d2,d3
		movea.l d3,a2		; Faster than indexed addressing
		move.b	(a2),d0 	; Store pixel
		add.l	d6,d4		; uu--VVvv += d(uu--VVvv)/dx
		addx.b	d5,d2		; UU += d(UU)/dx

		move.l	0(a3,d0.l),d7

		move.w	d4,d3
		move.b	d2,d3
		movea.l d3,a2
		move.b	(a2),d0 	; Next pixel
		add.l	d6,d4
		addx.b	d5,d2

		or.l	0(a4,d0.l),d7

		move.w	d4,d3
		move.b	d2,d3
		movea.l d3,a2
		move.b	(a2),d0
		add.l	d6,d4
		addx.b	d5,d2

		or.l	0(a5,d0.l),d7

		move.w	d4,d3
		move.b	d2,d3
		movea.l d3,a2
		move.b	(a2),d0
		add.l	d6,d4
		addx.b	d5,d2

		or.l	0(a6,d0.l),d7

		movep.l d7,ofs+1(a1)
ofs	set	ofs+8
	endr

		lea.l	BYTESPERSCL(a1),a1 ; Scanline interleave

		movem.l (sp)+,d0/a3-a6

		cmpa.l	#divtbl+2*FRDR_YWIN,a0
		bne	.yloop_flr
		rts

c2p1:
	dc.l $00000000
	dc.l $c0000000
	dc.l $00c00000
	dc.l $c0c00000
	dc.l $0000c000
	dc.l $c000c000
	dc.l $00c0c000
	dc.l $c0c0c000
	dc.l $000000c0
	dc.l $c00000c0
	dc.l $00c000c0
	dc.l $c0c000c0
	dc.l $0000c0c0
	dc.l $c000c0c0
	dc.l $00c0c0c0
	dc.l $c0c0c0c0

c2p2:
	dc.l $00000000
	dc.l $30000000
	dc.l $00300000
	dc.l $30300000
	dc.l $00003000
	dc.l $30003000
	dc.l $00303000
	dc.l $30303000
	dc.l $00000030
	dc.l $30000030
	dc.l $00300030
	dc.l $30300030
	dc.l $00003030
	dc.l $30003030
	dc.l $00303030
	dc.l $30303030

c2p3:
	dc.l $00000000
	dc.l $0c000000
	dc.l $000c0000
	dc.l $0c0c0000
	dc.l $00000c00
	dc.l $0c000c00
	dc.l $000c0c00
	dc.l $0c0c0c00
	dc.l $0000000c
	dc.l $0c00000c
	dc.l $000c000c
	dc.l $0c0c000c
	dc.l $00000c0c
	dc.l $0c000c0c
	dc.l $000c0c0c
	dc.l $0c0c0c0c

c2p4:
	dc.l $00000000
	dc.l $03000000
	dc.l $00030000
	dc.l $03030000
	dc.l $00000300
	dc.l $03000300
	dc.l $00030300
	dc.l $03030300
	dc.l $00000003
	dc.l $03000003
	dc.l $00030003
	dc.l $03030003
	dc.l $00000303
	dc.l $03000303
	dc.l $00030303
	dc.l $03030303



*******************************************************
*  void doomMain()
*
* Doom-like effect animation mainloop.
*******************************************************

doomMain:	bsr.w	getTime 	; Step the animation
		mulu.w	#130*256/60,d0

;>		lsr.w	#1,d0
		add.l	d0,v0
		lsr.w	#1,d0
		add.l	d0,u0
		lsr.w	#7,d0
		add.w	d0,facing

		move.w	facing(pc),d0	; Map sky and floor seperately

                lea.l	sin,a0		; Compute viewing angle as sin(facing)
                move.w	#(2048-1)<<1,d1
		and.w	d1,d0
		move.w	(a0,d0.w),d0
		asr.w	#5-1,d0
		and.w	d1,d0

		move.w	d0,.angle

		movea.l screen3(pc),a0
		bsr.w	plotSky

		movea.l screen3(pc),a1
		move.w	.angle(pc),d1
		bsr.w	plotFloor

		bra.w	cycleScreens

.angle:		dc.w	0		; Viewing angle


		data
skyPalette:	incbin	'SKY.ACT',48
floorPalette:	incbin	'FLOOR.ACT',48

; Textures

floorTexPak:    incbin	'FLOOR.LZ7'
		even
skyTexPak:	incbin	'SKY.LZ7'
		even

sin:		incbin	'SIN.TBL'
		even



		bss
skyPal:		ds.w	1<<PHYS_BPP
floorPal:	ds.w	1<<PHYS_BPP

divtbl:		ds.w	FRDR_YWIN	; persp / z table
