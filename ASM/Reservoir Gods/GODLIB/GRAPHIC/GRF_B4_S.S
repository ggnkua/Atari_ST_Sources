**************************************************************************************
*	GRF_B4_S.S
*
*	4 BitPlane Blitter Rendering Functions
*
*	[c] 2002 Reservoir Gods
**************************************************************************************



**************************************************************************************
;	EXPORTS / IMPORTS
**************************************************************************************

	export	Graphic_4BP_Blit_BLT
	export	Graphic_4BP_ClearScreen_BLT
	export	Graphic_4BP_CopyScreen_BLT
	export	Graphic_4BP_DrawBox_BLT
	export	Graphic_4BP_DrawLine_BLT
	export	Graphic_4BP_DrawPixel_BLT 
	export	Graphic_4BP_DrawSprite_BLT 
	export	Graphic_4BP_DrawTri_BLT  
	export	Graphic_4BP_DrawQuad_BLT 

	export	Graphic_4BP_Blit_Clip_BLT
	export	Graphic_4BP_ClearScreen_Clip_BLT
	export	Graphic_4BP_CopyScreen_Clip_BLT
	export	Graphic_4BP_DrawBox_Clip_BLT
	export	Graphic_4BP_DrawLine_Clip_BLT
	export	Graphic_4BP_DrawPixel_Clip_BLT
	export	Graphic_4BP_DrawSprite_Clip_BLT
	export	Graphic_4BP_DrawTri_Clip_BLT
	export	Graphic_4BP_DrawQuad_Clip_BLT


**************************************************************************************
;	DEFINES
**************************************************************************************

eBLITTERLOP_ZERO				EQU	0
eBLITTERLOP_SRC_AND_DST			EQU	1
eBLITTERLOP_SRC_ANDNOT_DST		EQU	2
eBLITTERLOP_SRC					EQU	3
eBLITTERLOP_NOTSRC_AND_DST		EQU	4
eBLITTERLOP_DST					EQU	5
eBLITTERLOP_SRC_XOR_DST			EQU	6
eBLITTERLOP_SRC_OR_DST			EQU	7
eBLITTERLOP_NOTSRC_ANDNOT_DST	EQU	8
eBLITTERLOP_NOTSRC_XOR_DST		EQU	9
eBLITTERLOP_NOTDST				EQU	10
eBLITTERLOP_SRC_ORNOT_DST		EQU	11
eBLITTERLOP_NOTSRC				EQU	12
eBLITTERLOP_NOTSRC_OR_DST		EQU	13
eBLITTERLOP_NOTSRC_ORNOT_DST	EQU	14
eBLITTERLOP_ONE					EQU	15

eBLITTERHOP_ONE					EQU	0
eBLITTERHOP_HALFTONE			EQU	1
eBLITTERHOP_SRC					EQU	2
eBLITTERHOP_SRC_AND_HALFTONE	EQU	3

eBLITTERMODE_LINENUMBER_MASK	EQU	$F
eBLITTERMODE_SMUDGE_BIT			EQU	$20
eBLITTERMODE_SMUDGE_MASK		EQU	$DF
eBLITTERMODE_HOG_BIT			EQU	$40
eBLITTERMODE_HOG_MASK			EQU	$BF
eBLITTERMODE_BUSY_BIT			EQU	$80
eBLITTERMODE_BUSY_MASK			EQU	$7F

eBLITTERSKEW_SKEW_MASK			EQU	$F
eBLITTERSKEW_NFSR_BIT			EQU	$40
eBLITTERSKEW_NFSR_MASK			EQU	$BF
eBLITTERSKEW_FXSR_BIT			EQU	$80
eBLITTERSKEW_FXSR_MASK			EQU	$7F

eBLITREG_HALFTONE				EQU	$FFFF8A00
eBLITREG_SRC_INC_X				EQU	$FFFF8A20
eBLITREG_SRC_INC_Y				EQU	$FFFF8A22
eBLITREG_pSRC					EQU	$FFFF8A24
eBLITREG_ENDMASK_1				EQU	$FFFF8A28
eBLITREG_ENDMASK_2				EQU	$FFFF8A2A
eBLITREG_ENDMASK_3				EQU	$FFFF8A2C
eBLITREG_DST_INC_X				EQU	$FFFF8A2E
eBLITREG_DST_INC_Y				EQU	$FFFF8A30
eBLITREG_pDST					EQU	$FFFF8A32
eBLITREG_COUNT_X				EQU	$FFFF8A36
eBLITREG_COUNT_Y				EQU	$FFFF8A38
eBLITREG_HOP					EQU	$FFFF8A3A
eBLITREG_LOP					EQU	$FFFF8A3B
eBLITREG_MODE					EQU	$FFFF8A3C
eBLITREG_SKEW					EQU	$FFFF8A3D

eBLITTER_BASE					EQU	$FFFF8A00
eBLITTER_HALFTONE				EQU	$00
eBLITTER_SRC_INC_X				EQU	$20
eBLITTER_SRC_INC_Y				EQU	$22
eBLITTER_pSRC					EQU	$24
eBLITTER_ENDMASK_1				EQU	$28
eBLITTER_ENDMASK_2				EQU	$2A
eBLITTER_ENDMASK_3				EQU	$2C
eBLITTER_DST_INC_X				EQU	$2E
eBLITTER_DST_INC_Y				EQU	$30
eBLITTER_pDST					EQU	$32
eBLITTER_COUNT_X				EQU	$36
eBLITTER_COUNT_Y				EQU	$38
eBLITTER_HOP					EQU	$3A
eBLITTER_LOP					EQU	$3B
eBLITTER_MODE					EQU	$3C
eBLITTER_SKEW					EQU	$3D


**************************************************************************************
;	STRUCTS
**************************************************************************************

	OFFSET

sGraphicPos_X:					ds.w	1
sGraphicPos_Y:					ds.w	1
sGraphicPos_sizeof:				ds.w	1


	OFFSET
sGraphicRect_X:					ds.w	1
sGraphicRect_Y:					ds.w	1
sGraphicRect_Width:				ds.w	1
sGraphicRect_Height:			ds.w	1
sGraphicRect_sizeof:			ds.w	1


	OFFSET
sGraphicSprite_pGfx:			ds.l	1
sGraphicSprite_pMask:			ds.l	1
sGraphicSprite_Width:			ds.w	1
sGraphicSprite_Height:			ds.w	1
sGraphicSprite_GfxPlaneCount:	ds.w	1
sGraphicSprite_MaskPlaneCount:	ds.w	1
sGraphicSprite_sizeof:			ds.w	1


	OFFSET
sGraphicCanvas_pVRAM:			ds.l	1
sGraphicCanvas_ColourMode:		ds.w	1
sGraphicCanvas_Width:			ds.w	1
sGraphicCanvas_Height:			ds.w	1
sGraphicCanvas_pad:				ds.w	1
sGraphicCanvas_pFuncs:			ds.l	1
sGraphicCanvas_pClipFuncs:		ds.l	1
sGraphicCanvas_LineOffsets:		ds.l	1025
sGraphicCanvas_sizeof:			ds.w	1

	OFFSET
slSpr_Xcount:					ds.w	1
slSpr_Xloop:					ds.w	1
slSpr_Yloop:					ds.w	1
slSpr_LeftMask:					ds.w	1
slSpr_sizeof:					ds.w	1

**************************************************************************************
;	MACROS
**************************************************************************************

	MACRO	mBlitterWait	aReg

	btst.b	#7,eBLITTER_MODE(aReg)	; is blitter busy?
	nop
	bne.s	*-8						; yes, wait

	ENDM

	MACRO	mBlitterGoWait	aReg
	move.b	#eBLITTERMODE_BUSY_BIT,eBLITTER_MODE(aReg)
	nop
	bset.b	#7,eBLITTER_MODE(aReg)	; is blitter busy?
	nop
	bne.s	*-8						; yes, wait

	ENDM

**************************************************************************************
	TEXT
**************************************************************************************


*------------------------------------------------------------------------------------*
* FUNCTION: void (*	Blit )(         struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,  sGraphicRect * apRect, void * apSrc, void * apDst );
* ACTION:   Blits rectangular area from apSrc to apDst
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_BlitClip_BLT:
	movem.l	d3-d7/a2-a6,-(a7)				; save registers

	move.w	sGraphicRect_X(a2),d0			; blit x
	move.w	sGraphicRect_Y(a2),d1			; blit y
	move.w	sGraphicRect_Width(a2),d2		; blit width
	move.w	sGraphicRect_Height(a2),d3		; blit height

	move.w	sGraphicPos_X(a1),d4		; X
	move.w	sGraphicPos_Y(a1),d5		; Y

	tst.w	d0								; X < 0?	
	bpl		.rectx0_ok						; X >= 0, no left clip	

	add.w	d0,d2							; Clip Width	
	ble		.clip							; Entirely off left, clip	
	moveq	#0,d0							; Set New X0	
	
.rectx0_ok:

	move.w	d0,d6							; X
	add.w	d2,d6							; X+Width
	sub.w	sGraphicCanvas_Width(a0),d6		; Check Amount off right of screen
	ble		.rectx1_ok						; None, no clipping
	
	sub.w	d6,d2							; Clip Width	
	ble		.clip							; Entirely Off Left, Cull	

.rectx1_ok:

	tst.w	d1								; Y < 0 ?	
	bpl		.recty0_ok						; Y >= 0, no top clip	

	add.w	d1,d3							; Clip Height	
	ble		.clip							; Entirely Off Top, Cull	
	moveq	#0,d1							; Clip Y	
	
.recty0_ok:

	move.w	d1,d6							; Y	
	add.w	d3,d6							; Y+Width	
	sub.w	sGraphicCanvas_Height(a0),d6	; Check amount off bottom	
	ble		.recty1_ok						; None, no bot clip	
	
	sub.w	d6,d3							; Clip Height	
	ble		.clip							; Entirely off bottom, Cull	

.recty1_ok:



	tst.w	d4								; X < 0?	
	bpl		.x0_ok							; X >= 0, no left clip	

	add.w	d4,d2							; Clip Width	
	ble		.clip							; Entirely off left, clip	
	moveq	#0,d4							; Set New X0	
	
.x0_ok:

	move.w	d4,d6							; X	
	add.w	d2,d6							; X+Width	
	sub.w	sGraphicCanvas_Width(a0),d6		; Check Amount off right of screen	
	ble		.x1_ok							; None, no clipping	
	
	sub.w	d6,d2							; Clip Width	
	ble		.clip							; Entirely Off Left, Cull	

.x1_ok:

	tst.w	d5								; Y < 0 ?	
	bpl		.y0_ok							; Y >= 0, no top clip	

	add.w	d5,d3							; Clip Height	
	ble		.clip							; Entirely Off Top, Cull	
	moveq	#0,d6							; Clip Y	
	
.y0_ok:

	move.w	d5,d6							; Y	
	add.w	d3,d6							; Y+Width	
	sub.w	sGraphicCanvas_Height(a0),d6	; Check amount off bottom	
	ble		.y1_ok							; None, no bot clip	
	
	sub.w	d6,d3							; Clip Height	
	ble		.clip							; Entirely off bottom, Cull	

.y1_ok:


	bra		Graphic_4BP_Blit_Go					; Blit it	

.clip:
	movem.l	(a7)+,d3-d7/a2-a6				; restore registers	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (*	Blit )( const struct sGraphicCanvas * apCanvas, const sGraphicRect * apCoords, void * apSrc, void * apDst );
* ACTION:   Blits rectangular area from apSrc to apDst
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_Blit_BLT:
	movem.l	d3-d7/a2-a6,-(a7)
Graphic_4BP_Blit_Go:					; Blit it	

	movem.l	(a7)+,d3-d7/a2-a6
	rts



*------------------------------------------------------------------------------------*
* FUNCTION: void (*	ClearScreen )( const struct sGraphicCanvas * apCanvas );
* ACTION:   clears a 320x200 screen
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_ClearScreen_BLT:
	movea.w	#eBLITTER_BASE,a1

	mBlitterWait	a1

	move.w	sGraphicCanvas_Width(a0),d0
	lsr.w	#2,d0

	move.w	d0,eBLITTER_COUNT_X(a1)
	move.w	sGraphicCanvas_Height(a0),eBLITTER_COUNT_Y(a1)
	move.l	sGraphicCanvas_pVRAM(a0),eBLITTER_pDST(a1)

	move.l	#$00020002,eBLITTER_DST_INC_X(a1)

	moveq	#-1,d0
	move.l	d0,eBLITTER_ENDMASK_1(a1)
	move.w	d0,eBLITTER_ENDMASK_3(a1)

	move.l	#$00008000,eBLITTER_HOP(a1)					; HOP=1 :LOP=ALL ZERO:MODE=GO|SHAREBUS:SKEW=0

	mBlitterGoWait	a1

	rts



*------------------------------------------------------------------------------------*
* FUNCTION: void (*	CopyScreen )(  const struct sGraphicCanvas * apCanvas, void * apSrc, void * apDst );
* ACTION:   copies a 320x200 screen
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_CopyScreen_BLT:
	move.l	a2,-(a7)							; save regs
	movea.w	#eBLITTER_BASE,a2

	mBlitterWait	a2

	move.w	sGraphicCanvas_Width(a0),d0
	lsr.w	#2,d0

	move.w	d0,eBLITTER_COUNT_X(a2)
	move.w	sGraphicCanvas_Height(a0),eBLITTER_COUNT_Y(a2)
	move.l	a1,eBLITTER_pSRC(a2)
	move.l	sGraphicCanvas_pVRAM(a0),eBLITTER_pDST(a2)

	move.l	#$00020002,eBLITTER_SRC_INC_X(a2)
	move.l	#$00020002,eBLITTER_DST_INC_X(a2)

	moveq	#-1,d0
	move.l	d0,eBLITTER_ENDMASK_1(a2)
	move.w	d0,eBLITTER_ENDMASK_3(a2)

	move.l	#$02038000,eBLITTER_HOP(a2)					; HOP=SRC :LOP=SRC:MODE=GO|SHAREBUS:SKEW=0

	mBlitterGoWait	a2

	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (* DrawBox )(      struct sGraphicCanvas * apCanvas,  sGraphicRect * apCoords,  S16 aColour );
* ACTION:   draws a box with clipping
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_DrawBox_Clip_BLT:
	movem.l	d3-d7/a2-a3,-(a7)					; save regs

	move.w	sGraphicRect_X(a1),d1				; Pixel X
	move.w	sGraphicRect_Y(a1),d2				; Pixel Y
	move.w	sGraphicRect_Width(a1),d3			; Width
	move.w	sGraphicRect_Height(a1),d4			; Height

	tst.w	d1									; X < 0?
	bpl		.x0_ok								; X >= 0, no left clip

	add.w	d1,d3								; Clip Width
	ble		.clip								; Entirely off left, clip
	moveq	#0,d1								; Set New X0
	
.x0_ok:

	move.w	d1,d5								; X
	add.w	d3,d5								; X+Width
	sub.w	sGraphicCanvas_Width(a0),d5			; Check Amount off right of screen
	ble		.x1_ok								; None, no clipping
	
	sub.w	d5,d3								; Clip Width
	ble		.clip								; Entirely Off Left, Cull

.x1_ok:

	tst.w	d2									; Y < 0 ?
	bpl		.y0_ok								; Y >= 0, no top clip

	add.w	d2,d3								; Clip Height
	ble		.clip								; Entirely Off Top, Cull
	moveq	#0,d2								; Clip Y
	
.y0_ok:

	move.w	d2,d5								; Y
	add.w	d4,d5								; Y+Width
	sub.w	sGraphicCanvas_Height(a0),d5		; Check amount off bottom
	ble		.y1_ok								; None, no bot clip
	
	sub.w	d5,d4								; Clip Height
	ble		.clip								; Entirely off bottom, Cull

.y1_ok:

	bra		Graphic_4BP_DrawBox_Go				; Render box

.clip:
	movem.l	(a7)+,d3-d7/a2-a3					; restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (* DrawBox )(      struct sGraphicCanvas * apCanvas,  sGraphicRect * apCoords,  S16 aColour );
* ACTION:   draws a box
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_DrawBox_BLT:
	movem.l	d3-d7/a2-a3,-(a7)					; save regs

	move.w	sGraphicRect_X(a1),d1				; Pixel X
	move.w	sGraphicRect_Y(a1),d2				; Pixel Y
	move.w	sGraphicRect_Width(a1),d3			; Width
	move.w	sGraphicRect_Height(a1),d4			; Height

Graphic_4BP_DrawBox_Go:
	movea.w	#eBLITTER_BASE,a2

	mBlitterWait	a2

	move.l	sGraphicCanvas_pVRAM(a0),a3

	add.w	d2,d2								; Y * 2
	add.w	d2,d2								; Y * 4
	add.l	#sGraphicCanvas_LineOffsets,d2		; Line Offsets Table
	add.l	(a0,d2.w),a3						; Get To Y

	move.w	d1,d2								; X
	and.l	#$0000FFF0,d2						; To Nearest 16
	lsr.w	#1,d2								; 8 Byte Offset for bitplane
	add.l	d2,a3								; Get To X

	subq.w	#1,d3								; width-1
	add.w	d1,d3								; X1=X0+width-1

	move.w	d1,d7								; X0
	move.w	d3,d5								; X1

	and.w	#$FFF0,d7							; X0 to nearest 16
	and.w	#$FFF0,d5							; X1 to nearest 16
	sub.w	d7,d5								; PixelCount
	lsr.w	#4,d5								; /16 = ChunkCount
	addq.w	#1,d5

	move.w	d5,eBLITTER_COUNT_X(a2)				; set x count
	move.w	#8,eBLITTER_DST_INC_X(a2)			; offset to next chunk

	move.w	d5,d7								; xcount
	lsl.w	#3,d7								; xcount * sizeof(bitplane)
	move.w	sGraphicCanvas_LineOffsets+6(a0),d6	; LineSize
	addq.w	#8,d6								; +8
	sub.w	d7,d6								; -xcount
	move.w	d6,eBLITTER_DST_INC_Y(a2)			; set dst y inc

	move.b	#eBLITTERHOP_ONE,eBLITTER_HOP(a2)
	clr.b	eBLITTER_SKEW(a2)

	and.w	#15,d1								; X0 & 15
	and.w	#15,d3								; X1 & 15
	add.w	d1,d1
	add.w	d3,d3
	lea		gGraphic_4BP_LeftMasks,a0
	move.w	(a0,d1.w),d1
	lea		gGraphic_4BP_RightMasks,a0
	move.w	(a0,d3.w),d3

	cmp.w	#1,d5
	bgt		.xcnot1

	and.w	d1,d3
	move.w	d3,eBLITTER_ENDMASK_1(a2)
	bra		.start

.xcnot1:
	cmp.w	#2,d5
	bgt		.xcnot2

	move.w	d1,eBLITTER_ENDMASK_1(a2)
	move.w	d3,eBLITTER_ENDMASK_2(a2)
	move.w	d3,eBLITTER_ENDMASK_3(a2)

	bra		.start

.xcnot2:

	move.w	d1,eBLITTER_ENDMASK_1(a2)
	move.w	#$FFFF,eBLITTER_ENDMASK_2(a2)
	move.w	d3,eBLITTER_ENDMASK_3(a2)

.start:
	
	lea		Graphic_4BP_LopColours,a0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a0,d0.w),d0
	

	move.b	d0,eBLITTER_LOP(a2)
	move.l	a3,eBLITTER_pDST(a2)
	move.w	d4,eBLITTER_COUNT_Y(a2)
	mBlitterGoWait	a2

	lsr.l	#8,d0
	addq.l	#2,a3
	move.b	d0,eBLITTER_LOP(a2)
	move.l	a3,eBLITTER_pDST(a2)
	move.w	d4,eBLITTER_COUNT_Y(a2)
	mBlitterGoWait	a2

	lsr.l	#8,d0
	addq.l	#2,a3
	move.b	d0,eBLITTER_LOP(a2)
	move.l	a3,eBLITTER_pDST(a2)
	move.w	d4,eBLITTER_COUNT_Y(a2)
	mBlitterGoWait	a2

	lsr.l	#8,d0
	addq.l	#2,a3
	move.b	d0,eBLITTER_LOP(a2)
	move.l	a3,eBLITTER_pDST(a2)
	move.w	d4,eBLITTER_COUNT_Y(a2)
	mBlitterGoWait	a2


	movem.l	(a7)+,d3-d7/a2-a3					; restore regs
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (* DrawPixel )(   const struct sGraphicCanvas * apCanvas, const sGraphicPos * apCoords,  const S16 aColour )
* ACTION:   draws a pixel with clipping
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_DrawPixel_Clip_BLT:

	move.w	sGraphicPos_X(a1),d1				; Pixel X
	move.w	sGraphicPos_Y(a1),d2				; Pixel Y

	cmp.w	sGraphicCanvas_Width(a0),d1			; Canvas Width
	bhs.s	.clip								; Clip X
	cmp.w	sGraphicCanvas_Height(a0),d2		; Canvas Height
	bhs.s	.clip								; Clip Y
	
	bra		Graphic_4BP_DrawPixel_Go			; Draw Pixel

.clip:
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (* DrawPixel )(   const struct sGraphicCanvas * apCanvas, const sGraphicPos * apCoords,  const S16 aColour )
* ACTION:   draws a pixel
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_DrawPixel_BLT:

	move.w	sGraphicPos_X(a1),d1				; Pixel X
	move.w	sGraphicPos_Y(a1),d2				; Pixel Y

Graphic_4BP_DrawPixel_Go:

	add.w	d2,d2								; Y * 2
	add.w	d2,d2								; Y * 4
	add.l	#sGraphicCanvas_LineOffsets,d2		; Line Offsets Table
	move.l	(a0,d2.w),a1						; Get To Y

	move.w	d1,d2								; X
	and.l	#$0000FFF0,d2						; To Nearest 16
	lsr.w	#1,d2								; 8 Byte Offset for bitplane
	add.l	d2,a1								; Get To X

	add.l	sGraphicCanvas_pVRAM(a0),a1			; Get To Position On Screen

	and.w	#15,d1								; X & 15
	add.w	d1,d1								; *2 As Offset In Table
	lea		gGraphic_4BP_Points,a0
	move.w	(a0,d1.w),d1						; Read Point
	move.w	d1,d2								; Copy Point
	not.w	d2									; Make Mask

	and.w	d2,(a1)								; Mask Plane 0
	and.w	d2,2(a1)							; Mask Plane 1
	and.w	d2,4(a1)							; Mask Plane 2
	and.w	d2,6(a1)							; Mask Plane 3

	lsr.w	#1,d0								; Check Bit 0
	bcc.s	.nbp0								; Not Set
	or.w	d1,6(a1)							; Draw To Plane0
.nbp0:
	lsr.w	#1,d0								; Check Bit 1
	bcc.s	.nbp1								; Not Set
	or.w	d1,4(a1)							; Draw To Plane 1
.nbp1:
	lsr.w	#1,d0								; Check Bit 2
	bcc.s	.nbp2								; Not Set
	or.w	d1,2(a1)							; Draw To Plane 2
.nbp2:
	lsr.w	#1,d0								; Check Bit 3
	bcc.s	.nbp3								; Not Set
	or.w	d1,0(a1)							; Draw To Plane 3
.nbp3:

	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (* DrawSprite )(  const struct sGraphicCanvas * apCanvas, const sGraphicPos * apCoords,  const void * apSprite );
* ACTION:   draws a sprite with clipping
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_DrawSprite_Clip_BLT:
	movem.l	d3-d7/a2-a6,-(a7)

	move.l	11*4(a7),a2
	move.w	sGraphicPos_X(a1),d0
	move.w	sGraphicPos_Y(a1),d1
	move.w	sGraphicSprite_Width(a2),d2
	move.w	sGraphicSprite_Height(a2),d3
	move.l	sGraphicSprite_pGfx(a2),a3
	move.l	sGraphicSprite_pMask(a2),a4


	cmp.w	sGraphicCanvas_Width(a0),d0
	bge		.clip
	cmp.w	sGraphicCanvas_Height(a0),d1
	bge		.clip

	tst.w	d1
	bpl.s	.y0_ok

	add.w	d1,d3
	ble		.clip

	move.w	sGraphicSprite_Width(a2),d4
	add.w	#15,d4
	and.l	#$0000FFF0,d4
	lsr.w	#1,d4
	move.w	d4,d5
	lsr.w	#2,d5

	neg.w	d1
	mulu.w	d1,d4
	mulu.w	d1,d5
	add.l	d4,a3
	add.l	d5,a4
	moveq	#0,d1
.y0_ok:

	move.w	d1,d4							;y
	add.w	d3,d4							;y2
	sub.w	sGraphicCanvas_Height(a0),d4
	ble		.y1_ok

	sub.w	d4,d3							; clip height
	ble		.clip

.y1_ok:

	tst.w	d0
	bpl.s	.x0_ok

	add.w	d0,d2							; clip width
	ble		.clip

	neg.w	d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	add.w	d0,a3
	lsr.w	#2,d0
	add.w	d0,a4

	moveq	#0,d0
.x0_ok:

	move.w	d0,d4							;x
	add.w	d2,d4							;x2
	sub.w	sGraphicCanvas_Width(a0),d4
	ble		.x1_ok

	sub.w	d4,d2							; clip width
	ble		.clip

.x1_ok:

	bra		Graphic_4BP_DrawSprite_Go

.clip:

	movem.l	(a7)+,d3-d7/a2-a6
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (* DrawSprite )(  const struct sGraphicCanvas * apCanvas, const sGraphicPos * apCoords,  const void * apSprite );
* ACTION:   draws a sprite
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_DrawSprite_BLT:
	movem.l	d3-d7/a2-a6,-(a7)

	move.l	11*4(a7),a2
	move.w	sGraphicPos_X(a1),d0
	move.w	sGraphicPos_Y(a1),d1
	move.w	sGraphicSprite_Width(a2),d2
	move.w	sGraphicSprite_Height(a2),d3
	move.l	sGraphicSprite_pGfx(a2),a3
	move.l	sGraphicSprite_pMask(a2),a4

Graphic_4BP_DrawSprite_Go:

	movea.w	#eBLITTER_BASE,a6

	mBlitterWait	a6


	move.l	sGraphicCanvas_pVRAM(a0),a5

	add.w	d1,d1								; Y * 2
	add.w	d1,d1								; Y * 4
	add.l	#sGraphicCanvas_LineOffsets,d1		; Line Offsets Table
	add.l	(a0,d1.w),a5						; Get To Y

	move.w	d0,d1								; X
	and.l	#$0000FFF0,d1						; To Nearest 16
	lsr.w	#1,d1								; 8 Byte Offset for bitplane
	add.l	d1,a5								; Get To X

	subq.w	#1,d2								; width-1
	add.w	d0,d2								; X1=X0+width-1

	move.w	d0,d7								; X0
	move.w	d2,d5								; X1

	and.w	#$FFF0,d7							; X0 to nearest 16
	and.w	#$FFF0,d5							; X1 to nearest 16
	sub.w	d7,d5								; PixelCount
	lsr.w	#4,d5								; /16 = ChunkCount
	addq.w	#1,d5

	move.w	d5,eBLITTER_COUNT_X(a6)				; set x count
	move.w	#8,eBLITTER_DST_INC_X(a6)			; offset to next chunk

	move.w	d5,d7								; xcount
	lsl.w	#3,d7								; xcount * sizeof(bitplane)
	move.w	sGraphicCanvas_LineOffsets+6(a0),d6	; LineSize
	addq.w	#8,d6								; +8
	sub.w	d7,d6								; -xcount
	move.w	d6,eBLITTER_DST_INC_Y(a6)			; set dst y inc

	move.w	sGraphicSprite_Width(a2),d6			; Sprite Width
	lsr.w	#3,d6
	addq.w	#2,d6								; +8
	lsr.w	#2,d7
	sub.w	d7,d6								; -xcount
	move.w	d6,eBLITTER_SRC_INC_Y(a6)			; set dst y inc


	move.b	#eBLITTERHOP_SRC,eBLITTER_HOP(a6)
	clr.b	eBLITTER_SKEW(a6)

	and.w	#15,d0								; X0 & 15
	and.w	#15,d2								; width

	move.b	d0,eBLITTER_SKEW(a6)

	tst.w	d0
	beq.s	.noSKEW
	cmp.w	#15,d2
	beq.s	.noSKEW
	or.b	#eBLITTERSKEW_NFSR_BIT,eBLITTER_SKEW(a6)
	addq.w	#2,eBLITTER_SRC_INC_Y(a6)
.noSKEW:


	cmp.w	#15,d2
	beq.s	.x2a
	tst.w	d0
	bne.s	.x2a
	
	move.b	d2,eBLITTER_SKEW(a6)
	addq.b	#1,eBLITTER_SKEW(a6)

	or.b	#eBLITTERSKEW_FXSR_BIT,eBLITTER_SKEW(a6)
	subq.w	#2,eBLITTER_SRC_INC_Y(a6)
.x2a:
	add.w	d0,d0
	add.w	d2,d2
	lea		gGraphic_4BP_LeftMasks,a1
	move.w	(a1,d0.w),d0
	lea		gGraphic_4BP_RightMasks,a1
	move.w	(a1,d2.w),d2

	cmp.w	#1,d5
	bgt		.xcnot1

	and.w	d0,d2
	move.w	d2,eBLITTER_ENDMASK_1(a6)
	bra		.start

.xcnot1:
	cmp.w	#2,d5
	bgt		.xcnot2

	move.w	d0,eBLITTER_ENDMASK_1(a6)
	move.w	d2,eBLITTER_ENDMASK_2(a6)
	move.w	d2,eBLITTER_ENDMASK_3(a6)

	bra		.start

.xcnot2:

	move.w	d0,eBLITTER_ENDMASK_1(a6)
	move.w	#$FFFF,eBLITTER_ENDMASK_2(a6)
	move.w	d2,eBLITTER_ENDMASK_3(a6)

.start:
		
	move.b	#eBLITTERLOP_SRC,eBLITTER_LOP(a6)
	tst.w	sGraphicSprite_MaskPlaneCount(a2)
	beq		.noMASKING

	move.b	#eBLITTERLOP_SRC_AND_DST,eBLITTER_LOP(a6)
	move.w	#2,eBLITTER_SRC_INC_X(a6)			; offset to next chunk

	move.l	a4,eBLITTER_pSRC(a6)
	move.l	a5,eBLITTER_pDST(a6)
	move.w	d3,eBLITTER_COUNT_Y(a6)
	mBlitterGoWait	a6

	addq.l	#2,a5
	move.l	a4,eBLITTER_pSRC(a6)
	move.l	a5,eBLITTER_pDST(a6)
	move.w	d3,eBLITTER_COUNT_Y(a6)
	mBlitterGoWait	a6

	addq.l	#2,a5
	move.l	a4,eBLITTER_pSRC(a6)
	move.l	a5,eBLITTER_pDST(a6)
	move.w	d3,eBLITTER_COUNT_Y(a6)
	mBlitterGoWait	a6

	addq.l	#2,a5
	move.l	a4,eBLITTER_pSRC(a6)
	move.l	a5,eBLITTER_pDST(a6)
	move.w	d3,eBLITTER_COUNT_Y(a6)
	mBlitterGoWait	a6

	subq.l	#6,a5

	move.b	#eBLITTERLOP_SRC_OR_DST,eBLITTER_LOP(a6)

.noMASKING:

	move.w	eBLITTER_SRC_INC_Y(a6),d0
	lsl.w	#2,d0
	move.w	d0,eBLITTER_SRC_INC_Y(a6)
	move.w	#8,eBLITTER_SRC_INC_X(a6)			; offset to next chunk

	move.l	a3,eBLITTER_pSRC(a6)
	move.l	a5,eBLITTER_pDST(a6)
	move.w	d3,eBLITTER_COUNT_Y(a6)
	mBlitterGoWait	a6

	addq.l	#2,a3
	addq.l	#2,a5
	move.l	a3,eBLITTER_pSRC(a6)
	move.l	a5,eBLITTER_pDST(a6)
	move.w	d3,eBLITTER_COUNT_Y(a6)
	mBlitterGoWait	a6

	addq.l	#2,a3
	addq.l	#2,a5
	move.l	a3,eBLITTER_pSRC(a6)
	move.l	a5,eBLITTER_pDST(a6)
	move.w	d3,eBLITTER_COUNT_Y(a6)
	mBlitterGoWait	a6

	addq.l	#2,a3
	addq.l	#2,a5
	move.l	a3,eBLITTER_pSRC(a6)
	move.l	a5,eBLITTER_pDST(a6)
	move.w	d3,eBLITTER_COUNT_Y(a6)
	mBlitterGoWait	a6


G4BP_DrawSprite_RTS:

	movem.l	(a7)+,d3-d7/a2-a6
	rts


**************************************************************************************
	DATA
**************************************************************************************

gGraphic_4BP_LeftMasks:
	dc.w	$FFFF
	dc.w	$7FFF
	dc.w	$3FFF
	dc.w	$1FFF
	dc.w	$0FFF
	dc.w	$07FF
	dc.w	$03FF
	dc.w	$01FF
	dc.w	$00FF
	dc.w	$007F
	dc.w	$003F
	dc.w	$001F
	dc.w	$000F
	dc.w	$0007
	dc.w	$0003
	dc.w	$0001

gGraphic_4BP_DoubleLeftMasks:
	dc.w	$FFFF,$FFFF
	dc.w	$7FFF,$7FFF
	dc.w	$3FFF,$3FFF
	dc.w	$1FFF,$1FFF
	dc.w	$0FFF,$0FFF
	dc.w	$07FF,$07FF
	dc.w	$03FF,$03FF
	dc.w	$01FF,$01FF
	dc.w	$00FF,$00FF
	dc.w	$007F,$007F
	dc.w	$003F,$003F
	dc.w	$001F,$001F
	dc.w	$000F,$000F
	dc.w	$0007,$0007
	dc.w	$0003,$0003
	dc.w	$0001,$0001

gGraphic_4BP_RightMasks:
	dc.w	$8000
	dc.w	$C000
	dc.w	$E000
	dc.w	$F000
	dc.w	$F800
	dc.w	$FC00
	dc.w	$FE00
	dc.w	$FF00
	dc.w	$FF80
	dc.w	$FFC0
	dc.w	$FFE0
	dc.w	$FFF0
	dc.w	$FFF8
	dc.w	$FFFC
	dc.w	$FFFE
	dc.w	$FFFF

gGraphic_4BP_DoubleRightMasks:
	dc.w	$8000,$8000
	dc.w	$C000,$C000
	dc.w	$E000,$E000
	dc.w	$F000,$F000
	dc.w	$F800,$F800
	dc.w	$FC00,$FC00
	dc.w	$FE00,$FE00
	dc.w	$FF00,$FF00
	dc.w	$FF80,$FF80
	dc.w	$FFC0,$FFC0
	dc.w	$FFE0,$FFE0
	dc.w	$FFF0,$FFF0
	dc.w	$FFF8,$FFF8
	dc.w	$FFFC,$FFFC
	dc.w	$FFFE,$FFFE
	dc.w	$FFFF,$FFFF

gGraphic_4BP_LongMasks:
	dc.l	$FFFF0000
	dc.l	$7FFF8000
	dc.l	$3FFFC000
	dc.l	$1FFFE000
	dc.l	$0FFFF000
	dc.l	$07FFF800
	dc.l	$03FFFC00
	dc.l	$01FFFE00
	dc.l	$00FFFF00
	dc.l	$007FFF80
	dc.l	$003FFFC0
	dc.l	$001FFFE0
	dc.l	$000FFFF0
	dc.l	$0007FFF8
	dc.l	$0003FFFC
	dc.l	$0001FFFE
	dc.l	$0000FFFF


gGraphic_4BP_Points:
	dc.w	$8000
	dc.w	$4000
	dc.w	$2000
	dc.w	$1000
	dc.w	$0800
	dc.w	$0400
	dc.w	$0200
	dc.w	$0100
	dc.w	$0080
	dc.w	$0040
	dc.w	$0020
	dc.w	$0010
	dc.w	$0008
	dc.w	$0004
	dc.w	$0002
	dc.w	$0001

Graphic_4BP_LopColours:
	dc.l	$00000000
	dc.l	$0000000F
	dc.l	$00000F00
	dc.l	$00000F0F
	dc.l	$000F0000
	dc.l	$000F000F
	dc.l	$000F0F00
	dc.l	$000F0F0F
	dc.l	$0F000000
	dc.l	$0F00000F
	dc.l	$0F000F00
	dc.l	$0F000F0F
	dc.l	$0F0F0000
	dc.l	$0F0F000F
	dc.l	$0F0F0F00
	dc.l	$0F0F0F0F

Graphic_4BP_ColourChunks:
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000
	dc.w	$0000,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$0000,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000
	dc.w	$0000,$0000,$0000,$FFFF
	dc.w	$FFFF,$0000,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$FFFF,$FFFF,$0000,$FFFF
	dc.w	$0000,$0000,$FFFF,$FFFF
	dc.w	$FFFF,$0000,$FFFF,$FFFF
	dc.w	$0000,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
