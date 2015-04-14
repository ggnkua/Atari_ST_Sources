; Floating water effect, by ray//.tSCc., jan. 2007


WATER_XWIN	=	128	; Resolution of the effect window
WATER_YWIN 	=	128

WATER_TXT_U	=	128	; Texture resolution
WATER_TXT_V	=	128

WATER_BMP_U	=	383	; Distortion map resolution
WATER_BMP_V	=	128

WATER_DU_SCL	=	3	; Horizontal distortion normalization and clip values
WATER_DU_CLIP	=	31

WATER_DV_SCL	=	5	; Vertical distortion normalization and clip values
WATER_DV_CLIP	=	8


		data
waterPalObj:	dc.w	15	; Water palette object
		dc.l	outPal

		dc.w	OUTLOGO_Y-1
waterFade:	dc.w	1
		dc.l	waterPalette

		dc.w	WATER_YWIN-1,15
		dc.l	outPal

		dc.w	-1


waterPalette:	include	'waterpal.i'


		text
waterBmpPtr:	ds.l	1

waterBmpPtr1:	ds.l	1	; Preshifted textures (4bpl)
waterBmpPtr2:	ds.l	1
waterBmpPtr3:	ds.l	1
waterBmpPtr4:	ds.l	1

distTablePtr:	ds.l	1	; Distortion Table


******************************************************
*  Water ripples demo sequencing rouintes.
******************************************************

waterInit:	move.l	#fujiPal,logoPalPatch
		move.w	#15,logoFade2

		lea.l	logoPalObj,a0	; Show Intermission #2
		movea.l	titlePtr,a1
		bsr.w	interludeInit

                bra.w	initWater

waterInitFadeOut:
		movea.l	titlePtr,a0
                bsr.w	interludeDeinit

		move.l	titlePtr,d0
		bra.w	FreeSomeMem


fadeInWater:	lea.l	waterPalObj,a0
		bsr.w	installSplitPalette

		move.l	#waterFadeIn,VBLHookPtr
		bra.w	setSemaphore

fadeOutWater:	move.l	#waterFadeOut,VBLHookPtr
		bra.w	waterMain


*********************************************************
*  void waterFadeIn()
*  void waterFadeOut()
*
* Fading VBL hook routines.
*********************************************************

waterFadeIn:	moveq.l	#3,d0
		and.l	$466.w,d0	; Fade every 4th VBL
		bne.s	.break

		moveq.l	#(1<<PHYS_BPP)-1,d0	; Max. brightness

		cmp.w	waterFade,d0	; Max. brightness approached yet?
		beq.s	.done

		addq.w	#1,waterFade

.break:		rts

.done:		clr.l	VBLHookPtr
		rts


waterFadeOut:	moveq.l	#3,d0		; Fade every 4th VBL
		and.l	$466.w,d0
		bne.s	.break

      		tst.w	waterFade	; Min. brightness approached yet?
		beq.s	.done

		subq.w	#1,waterFade

.break:		rts

.done:          clr.l	VBLHookPtr
		rts



*********************************************
*  void initWater()
*
* Initialise water effect.
*********************************************

initWater:	move.l	#WATER_XWIN*WATER_YWIN,d0	; Deflate texture
		moveq.l	#TTRAM,d1
		bsr.w	AllocSomeMem
		move.l	d0,.waterBitmapPtr

		lea.l	bitmapPak,a0
		movea.l d0,a1
		bsr.w	d_lz77

; Create preshifted patterns (4bpl)

		move.l	#4*WATER_TXT_U*(WATER_TXT_V+2*WATER_DV_CLIP)*4,d0
		moveq	#TTRAM,d1
		bsr.w	AllocSomeMem
		move.l	d0,waterBmpPtr

		lea.l	4*WATER_TXT_U*WATER_DV_CLIP.w,a1 ; Clipping interleave
		lea.l	4*WATER_TXT_U*(WATER_TXT_V+WATER_DV_CLIP*2),a2 ; Texture array interleave

		lea.l	waterBmpPtr1,a0
		add.l	a1,d0
		move.l	d0,(a0)+
		add.l	a2,d0
		move.l	d0,(a0)+
		add.l	a2,d0
		move.l	d0,(a0)+
		add.l	a2,d0
		move.l	d0,(a0)+

		movea.l waterBmpPtr,a0	; Clear texture arrays to black
		move.l	#4*WATER_TXT_U*(WATER_TXT_V+2*WATER_DV_CLIP)*4,d0
		moveq	#0,d1
		bsr	ClearBlock


		movea.l .waterBitmapPtr,a0
;>		lea	.c2pTmp(pc),a1
		lea.l	c2p4,a1		; Use the previous c2p table as shared array

		movem.l waterBmpPtr1,a2-a5

		moveq	#0,d1

		move.w	#WATER_XWIN*WATER_YWIN-1,d0

.water_preshift:move.b	(a0)+,d1	; Load	pixel
		lsl.b	#2,d1
		move.l	0(a1,d1.l),d2	; Convert 4bpp -> 4bpl

		lsl.l	#6,d2		; Preshift and store
		move.l	d2,(a2)+
		lsr.l	#2,d2
		move.l	d2,(a3)+
		lsr.l	#2,d2
		move.l	d2,(a4)+
		lsr.l	#2,d2
		move.l	d2,(a5)+

		dbra	d0,.water_preshift

		move.l	.waterBitmapPtr,d0 ; Release texture
		bsr.w	FreeSomeMem


; Deflate distortion map and compute distortion table

		move.l	#WATER_BMP_U*WATER_BMP_V,d0 ; Temporary array
		moveq.l	#TTRAM,d1
		bsr.w	AllocSomeMem
		move.l	d0,.waterDistmapPtr

		move.l	#WATER_BMP_U*WATER_BMP_V*2,d0 ; Distortion table
		moveq	#TTRAM,d1
		bsr.w	AllocSomeMem
		move.l	d0,distTablePtr

		lea.l	distmapPak,a0
		movea.l .waterDistmapPtr,a1
		bsr.w	d_lz77

		movea.l .waterDistmapPtr,a0
		movea.l distTablePtr,a1

		move.w	#WATER_BMP_V-1,d0

.water_dist_y:	move.w	#WATER_BMP_U-1,d1

.water_dist_x:	moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		move.b	1(a0),d2	; Load 4 sourounding "bumps"
		move.b	-1(a0),d3
		move.b	WATER_BMP_U(a0),d4
		move.b	-WATER_BMP_U(a0),d5

		sub.w	d3,d2		; Compute and clip du
		asr.w	#WATER_DU_SCL,d2

		cmp.w	#-WATER_DU_CLIP,d2
		bgt.s	.du_greater
		moveq	#-WATER_DU_CLIP,d2
.du_greater:	cmpi.w	#WATER_DU_CLIP,d2
		blt.s	.du_less
		moveq	#WATER_DU_CLIP,d2

.du_less:	sub.w	d5,d4		; Compute and clip dv
		asr.w	#WATER_DV_SCL,d4
		cmpi.w	#-WATER_DV_CLIP,d4
		bgt.s	.dv_greater
		moveq	#-WATER_DV_CLIP,d4
.dv_greater:	cmpi.w	#WATER_DV_CLIP,d4
		blt.s	.dv_less
		moveq	#WATER_DV_CLIP,d4
.dv_less:

		muls	#WATER_TXT_U,d4
		add.w	d2,d4
		lsl.w	#2,d4

		move.w	d4,(a1)+
		addq.l	#1,a0
		dbra	d1,.water_dist_x

		dbra	d0,.water_dist_y

		move.l	.waterDistmapPtr,d0
		bra.w	FreeSomeMem


.waterBitmapPtr:	ds.l	1		; Temporary arrays
.waterDistmapPtr:	ds.l	1


;>.c2pTmp:    	dc.l	$00000000
;>		dc.l	$03000000
;>		dc.l	$00030000
;>		dc.l	$03030000
;>		dc.l	$00000300
;>		dc.l	$03000300
;>		dc.l	$00030300
;>		dc.l	$03030300
;>		dc.l	$00000003
;>		dc.l	$03000003
;>		dc.l	$00030003
;>		dc.l	$03030003
;>		dc.l	$00000303
;>		dc.l	$03000303
;>		dc.l	$00030303
;>		dc.l	$03030303



*********************************************
*  void restoreWater()
*
*`Deinitialise water effect.
*********************************************

restoreWater:	movea.l	screen3(pc),a0	; Clear screen
		lea.l	BYTESPERSCL*((PHYS_Y-WATER_YWIN)/2)(a0),a0
		move.l	#BYTESPERSCL*WATER_YWIN,d0
		moveq.l	#0,d1
		bsr.w	ClearBlock
		bsr.w	cycleScreens

		move.l	waterBmpPtr,d0	; Release water effect arrays
		bsr.w	FreeSomeMem
		move.l	distTablePtr,d0
		bra.w	FreeSomeMem


*********************************************
*  void plotWater(d0.w u_ofs, d1.w v_ofs, a6.l * dstScreen)
*
* Plot water effect based on the given u, v offsets.
* a6 points to a 4 bpl destination screen which is assumed to be
* BYTESPERSCL bytes wide and in 4 bitplanes.
*********************************************

plotWater:	movem.l waterBmpPtr1,a1-a4 ; Texture preshifts

		movea.l distTablePtr,a5
		andi.w	#255,d0
		adda.w	d0,a5
		adda.w	d0,a5

		moveq	#WATER_YWIN-1,d0

.water_yloop:
ofs	set	0
	rept	WATER_XWIN/8
		movem.w (a5)+,d1-d4
		move.l	0(a1,d1.l),d5
		or.l	4(a2,d2.l),d5
		or.l	8(a3,d3.l),d5
		or.l	12(a4,d4.l),d5

		movem.w (a5)+,d1-d4
		move.l	16(a1,d1.l),d6
		or.l	16+4(a2,d2.l),d6
		or.l	16+8(a3,d3.l),d6
		or.l	16+12(a4,d4.l),d6

		lea	32(a1),a1
		lea	32(a2),a2
		lea	32(a3),a3
		lea	32(a4),a4

		movep.l d5,ofs(a6)
		movep.l d6,ofs+1(a6)
ofs	set	ofs+8
	endr

		lea	(WATER_BMP_U-WATER_XWIN)*2(a5),a5
		lea	BYTESPERSCL(a6),a6
		dbra	d0,.water_yloop

		rts

waterOfs:	dc.w 0		; Distorion offset


*********************************************
*  void waterMain()
*
* Water effect animation loop.
*********************************************

waterMain:	bsr.w	getTime 	; Retrieve time elapsed since last call

		moveq.l	#10,d1		; Force down to at least 4 vbl tics
		cmp.w	d1,d0
		bhs.s	.keep_tics
		move.w	d1,d0

.keep_tics:	divu.w	d1,d0
		add.w	d0,waterOfs

		move.w	waterOfs(pc),d0	; Draw ripples
		movea.l screen3(pc),a6	; Destination address
		lea.l	(BYTESPERSCL-WATER_XWIN)/2+80*(PHYS_Y-WATER_YWIN)(a6),a6 ; Center screen window
		bsr.w	plotWater
		bra.w	cycleScreens	; Refresh screen


		data
distmapPak:	incbin	'DISTMAP.LZ7'
		even
bitmapPak:	incbin	'BITMAP.LZ7'
		even
