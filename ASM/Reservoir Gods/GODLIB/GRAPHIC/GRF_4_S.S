**************************************************************************************
*	GRF_4_S.S
*
*	4 BitPlane Rendering Functions
*
*	[c] 2002 Reservoir Gods
**************************************************************************************



**************************************************************************************
;	EXPORTS / IMPORTS
**************************************************************************************

	export	Graphic_4BP_Blit
	export	Graphic_4BP_ClearScreen
	export	Graphic_4BP_CopyScreen
	export	Graphic_4BP_DrawBox 
	export	Graphic_4BP_DrawLine 
	export	Graphic_4BP_DrawPixel 
	export	Graphic_4BP_DrawSprite 
	export	Graphic_4BP_DrawTri  
	export	Graphic_4BP_DrawQuad 

	export	Graphic_4BP_Blit_Clip
	export	Graphic_4BP_ClearScreen_Clip
	export	Graphic_4BP_CopyScreen_Clip
	export	Graphic_4BP_DrawBox_Clip
	export	Graphic_4BP_DrawLine_Clip
	export	Graphic_4BP_DrawPixel_Clip
	export	Graphic_4BP_DrawSprite_Clip
	export	Graphic_4BP_DrawTri_Clip
	export	Graphic_4BP_DrawQuad_Clip

	export	gGraphicBlitRout

**************************************************************************************
;	DEFINES
**************************************************************************************

dSPRCHUNK_OPAQUE	EQU	1
dSPRCHUNK_RIGHT		EQU	2
dSPRCHUNK_MID		EQU	4
dSPRCHUNK_LEFT		EQU	8


dBLIT_ROUT_RIGHT	EQU	1
dBLIT_ROUT_CENTRE	EQU	2
dBLIT_ROUT_LEFT		EQU	4
dBLIT_ROUT_ALIGNED	EQU	8
dBLIT_ROUT_FXSR		EQU	16
dBLIT_ROUT_NFSR		EQU	32

dBLIT_ROUT_RIGHT_MASK	EQU	-2
dBLIT_ROUT_CENTRE_MASK	EQU	-3
dBLIT_ROUT_LEFT_MASK	EQU	-5
dBLIT_ROUT_ALIGNED_MASK	EQU	-9
dBLIT_ROUT_FXSR_MASK	EQU	-17
dBLIT_ROUT_NFSR_MASK	EQU	-33


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
sGraphicCanvas_pClipFuncs:			ds.l	1
sGraphicCanvas_LineOffsets:		ds.l	1025
sGraphicCanvas_sizeof:			ds.w	1

	OFFSET
slSpr_Xcount:					ds.w	1
slSpr_Xloop:					ds.w	1
slSpr_Yloop:					ds.w	1
slSpr_LeftMask:					ds.w	1
slSpr_sizeof:					ds.w	1


**************************************************************************************
	TEXT
**************************************************************************************


*------------------------------------------------------------------------------------*
* FUNCTION: void (*	Blit )(         struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,  sGraphicRect * apRect, void * apSrc, void * apDst );
* ACTION:   Blits rectangular area from apSrc to apDst
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_Blit_Clip:
	movem.l	d3-d7/a2-a6,-(a7)				; save registers

	move.l	11*4(a7),a2
	move.l	12*4(a7),a3

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
	sub.w	sGraphicCanvas_Width(a3),d6		; Check Amount off right of screen
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
	sub.w	sGraphicCanvas_Height(a3),d6	; Check amount off bottom	
	ble		.recty1_ok						; None, no bot clip	
	
	sub.w	d6,d3							; Clip Height	
	ble		.clip							; Entirely off bottom, Cull	

.recty1_ok:



	tst.w	d4								; X < 0?	
	bpl		.x0_ok							; X >= 0, no left clip	

	add.w	d4,d2							; Clip Width	
	ble		.clip							; Entirely off left, clip	
	sub.w	d4,d0							; adjust rect x
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
	sub.w	d5,d1							; adjust rect y
	moveq	#0,d5							; Clip Y	
	
.y0_ok:

	move.w	d5,d6							; Y	
	add.w	d3,d6							; Y+Width	
	sub.w	sGraphicCanvas_Height(a3),d6	; Check amount off bottom	
	ble		.y1_ok							; None, no bot clip	
	
	sub.w	d6,d3							; Clip Height	
	ble		.clip							; Entirely off bottom, Cull	

.y1_ok:


	bra		Graphic_4BP_Blit_Go					; Blit it	

.clip:
	movem.l	(a7)+,d3-d7/a2-a6				; restore registers	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (*	Blit )( struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,  sGraphicRect * apRect, struct sGraphicCanvas * apSrc	);
* ACTION:   Blits rectangular area from apSrc to apDst
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

*
* D0 : gfx0             A0 : VRAM Line Offset
* D1 : gfx1             A1 : GFX Line Offset
* D2 : Width/gfx2       A2 : 
* D3 : Height/gfx3      A3 : pSpriteGFX
* D4 : msk              A4 : LoopY
* D5 : BITMASK          A5 : pVRAM
* D6 : SHIFT            A6 : LoopX
* D7 : temp                  

Graphic_4BP_Blit:
	movem.l	d3-d7/a2-a6,-(a7)

	move.l	11*4(a7),a2
	move.l	12*4(a7),a3


	move.w	sGraphicRect_X(a2),d0
	move.w	sGraphicRect_Y(a2),d1
	move.w	sGraphicRect_Width(a2),d2
	move.w	sGraphicRect_Height(a2),d3

	move.w	sGraphicPos_X(a1),d4		; X
	move.w	sGraphicPos_Y(a1),d5		; Y

Graphic_4BP_Blit_Go:



	move.l	sGraphicCanvas_pVRAM(a0),a5			; pDst
	add.w	d5,d5								; y*2
	add.w	d5,d5								; y*4
	add.l	#sGraphicCanvas_LineOffsets,d5
	move.l	(a0,d5.w),d5						; Dest Y offset
	move.w	d4,d7
	asr.w	#4,d7							
	asl.w	#3,d7
	ext.l	d7
	add.l	d7,d5
	add.l	d5,a5								; +x offset
	move.l	sGraphicCanvas_LineOffsets+4(a0),a0	; DST line offset


	move.l	sGraphicCanvas_LineOffsets+4(a3),a1	; SRC line offset
	add.w	d1,d1								; y*2
	add.w	d1,d1								; y*4
	add.l	#sGraphicCanvas_LineOffsets,d1
	move.l	(a3,d1.w),d1						; Dest Y offset
	move.l	sGraphicCanvas_pVRAM(a3),a3			; pDst
	move.w	d0,d7
	asr.w	#4,d7							
	asl.w	#3,d7
	ext.l	d7
	add.l	d7,d1								; +x offset
	add.l	d1,a3


	move.w	d3,a4								; height	
	moveq	#0,d3								; ROUT

	subq.w	#1,d2								; width-1
	move.w	d2,d5								; width

	add.w	d0,d2								; srcx1 = srcx0+width-1
	lsr.w	#4,d2								; srcx1/16

	move.w	d0,d6								; srcx0
	lsr.w	#4,d6								; srcx0/16
	sub.w	d6,d2								; srcwords

	add.w	d4,d5								; dstx1 = dstx0+width-1
	move.w	d5,d1								; dstx1
	lsr.w	#4,d1								; dstx1/16
	move.w	d1,d7								; dstx1/16

	move.w	d4,d6								; dstx0
	lsr.w	#4,d6								; dstx0/16
	sub.w	d6,d1								; dstwords

	move.w	d1,d6								; dst words
	move.w	d2,d7								; src words
	lsl.w	#3,d6
	lsl.w	#3,d7
	addq.w	#8,d6
	addq.w	#8,d7
	sub.w	d6,a0
	sub.w	d7,a1

	moveq	#15,d6
	moveq	#1,d7
	add.w	d4,d6								; dstx0+15
	add.w	d5,d7								; dstx1+1
	lsr.w	#4,d6
	lsr.w	#4,d7
	sub.w	d6,d7
	ble		.noCentre
	move.w	d7,a6								; central wordcount
	or.w	#dBLIT_ROUT_CENTRE,d3
.noCentre:

	moveq	#15,d7
	and.w	d7,d0								; srcx0 & 15
	and.w	d7,d4								; dstx0 & 15
	and.w	d7,d5								; dstx1 & 15

	move.w	d4,d6								;  (dstx0 & 15)
	sub.w	d0,d6								;  (dstx0 & 15)-(srcx0 & 15)
	and.w	d7,d6								; ((dstx0 & 15)-(srcx0 & 15)) & 15 

	cmp.w	d4,d0								; (d,s)
	ble.s	.noFXSR
	tst.w	d2									; srcwords
	ble		.noFXSR

	subq.w	#1,d2
	or.w	#dBLIT_ROUT_FXSR,d3
.noFXSR:

	cmp.w	#15,d5
	beq.s	.noRight
	or.w	#dBLIT_ROUT_RIGHT,d3
.noRight:

	cmp.w	d2,d1
	ble.s	.noNFSR
	or.w	#dBLIT_ROUT_NFSR,d3
.noNFSR:

	tst.w	d4	
	beq.s	.noLeft
	or.w	#dBLIT_ROUT_LEFT,d3
.noLeft:

	cmp.w	d0,d4
	bne.s	.noAligned
	or.w	#dBLIT_ROUT_ALIGNED,d3
.noAligned:


	add.w	d5,d5
	lea		gGraphic_4BP_RightMasks,a2
	move.w	(a2,d5.w),d5
	swap	d5

	add.w	d4,d4
	lea		gGraphic_4BP_LeftMasks,a2
	move.w	(a2,d4.w),d5

	tst.w	d1
	bne.s	.noSingle

	moveq	#dBLIT_ROUT_CENTRE,d0
	and.w	d3,d0
	bne.s	.noSingle
		
	move.l	d5,d4
	swap	d4
	and.l	d4,d5

	and.w	#dBLIT_ROUT_RIGHT_MASK,d3
	or.w	#dBLIT_ROUT_LEFT,d3

.noSingle:

	move.l	d5,d4
	not.l	d5

	move.w	d3,gGraphicBlitRout
	lea		Graphic_4BP_Blit_JMP,a2
	add.w	d3,d3
	add.w	d3,d3

	jmp		(a2,d3.w)

gGraphicBlitRout:	dc.w	0

Graphic_4BP_Blit_JMP:
	bra.w	G4BP_Blit_RTS
	bra.w	G4BP_Blit_R
	bra.w	G4BP_Blit_C
	bra.w	G4BP_Blit_CR
	bra.w	G4BP_Blit_L
	bra.w	G4BP_Blit_LR
	bra.w	G4BP_Blit_LC
	bra.w	G4BP_Blit_LCR

	bra.w	G4BP_Blit_RTS
	bra.w	G4BP_Blit_R_A
	bra.w	G4BP_Blit_C_A
	bra.w	G4BP_Blit_CR_A
	bra.w	G4BP_Blit_L_A
	bra.w	G4BP_Blit_LR_A
	bra.w	G4BP_Blit_LC_A
	bra.w	G4BP_Blit_LCR_A

	rept	2

	bra.w	G4BP_Blit_RTS
	bra.w	G4BP_Blit_R_F
	bra.w	G4BP_Blit_C_F
	bra.w	G4BP_Blit_CR_F
	bra.w	G4BP_Blit_L_F
	bra.w	G4BP_Blit_LR_F
	bra.w	G4BP_Blit_LC_F
	bra.w	G4BP_Blit_LCR_F

	endm

	rept	2

	bra.w	G4BP_Blit_RTS
	bra.w	G4BP_Blit_R_N
	bra.w	G4BP_Blit_C_N
	bra.w	G4BP_Blit_CR_N
	bra.w	G4BP_Blit_L_N
	bra.w	G4BP_Blit_LR_N
	bra.w	G4BP_Blit_LC_N
	bra.w	G4BP_Blit_LCR_N

	endm

	rept	2

	bra.w	G4BP_Blit_RTS
	bra.w	G4BP_Blit_R_FN
	bra.w	G4BP_Blit_C_FN
	bra.w	G4BP_Blit_CR_FN
	bra.w	G4BP_Blit_L_FN
	bra.w	G4BP_Blit_LR_FN
	bra.w	G4BP_Blit_LC_FN
	bra.w	G4BP_Blit_LCR_FN

	endm


;-------------------------------------------------------------------------------------------------
; NON-ALIGNED ROUTS
;-------------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------------
;	--R-	Right Blit
;-------------------------------------------------------------------------------------------------

G4BP_Blit_R:
	move.l	a4,d7
	subq.w	#1,d7

.yloop:

	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3

	ror.w	d6,d0
	ror.w	d6,d1
	ror.w	d6,d2
	ror.w	d6,d3

	and.w	d4,d0
	and.w	d4,d1
	and.w	d4,d2
	and.w	d4,d3

	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+

	add.l	a0,a3
	add.l	a1,a5

	dbra	d7,.yloop

	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	-C--	Central Blit	[ not possible ]
;-------------------------------------------------------------------------------------------------

G4BP_Blit_C:
	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	-CR-	Central.Right Blit
;-------------------------------------------------------------------------------------------------

G4BP_Blit_CR:
	bra		G4BP_Blit_RTS

;-------------------------------------------------------------------------------------------------
;	L---	Left Blit	[ same as R case ]
;-------------------------------------------------------------------------------------------------

G4BP_Blit_L:
	move.l	a4,d7
	subq.w	#1,d7

.yloop:

	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3

	ror.w	d6,d0
	ror.w	d6,d1
	ror.w	d6,d2
	ror.w	d6,d3

	and.w	d4,d0
	and.w	d4,d1
	and.w	d4,d2
	and.w	d4,d3

	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+

	add.l	a0,a3
	add.l	a1,a5

	dbra	d7,.yloop

	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	L--R	Left.Right Blit
;-------------------------------------------------------------------------------------------------

G4BP_Blit_LR:

	move.l	a4,d7
	subq.w	#1,d7
	swap	d4
	swap	d5
.yloop:
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3

	ror.l	d6,d0
	ror.l	d6,d1
	ror.l	d6,d2
	ror.l	d6,d3

	and.l	d4,d0
	and.l	d4,d1
	and.l	d4,d2
	and.l	d4,d3

	swap	d0
	swap	d1
	swap	d2
	swap	d3
	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+

	swap	d0
	swap	d1
	swap	d2
	swap	d3
	swap	d5
	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+
	swap	d5

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	dbra	d7,.yloop

	bra		G4BP_Blit_RTS

;-------------------------------------------------------------------------------------------------
;	LC--	Left.Centre
;-------------------------------------------------------------------------------------------------

G4BP_Blit_LC:

.yloop:

	moveq	#0,d0					; gfx plane 0
	moveq	#0,d1					; gfx plane 1
	moveq	#0,d2					; gfx plane 2
	moveq	#0,d3					; gfx plane 3
	move.l	#$FFFF0000,d4			; mask

	ror.l	d6,d4					; shift mask

	move.w	(a3)+,d0				; read gfx plane 2
	ror.l	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	ror.l	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	ror.l	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	ror.l	d6,d3					; shift gfx plane 3

	move.w	d5,d7
	not.w	d7
	and.w	d7,d0					; clear unwanted plane0 bits
	and.w	d7,d1					; clear unwanted plane1 bits
	and.w	d7,d2					; clear unwanted plane2 bits
	and.w	d7,d3					; clear unwanted plane3 bits

	and.w	d5,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d5,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d5,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d5,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	move.w	a6,a2					; loopX
.xloop:
	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.l	d4,d0					; clear unwanted plane0 bits
	and.l	d4,d1					; clear unwanted plane1 bits
	and.l	d4,d2					; clear unwanted plane2 bits
	and.l	d4,d3					; clear unwanted plane3 bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	move.w	d0,(a5)+				; draw plane 0
	move.w	d1,(a5)+				; draw plane 1
	move.w	d2,(a5)+				; draw plane 2
	move.w	d3,(a5)+				; draw plane 3

	suba.l	#1,a2					; dec mid loop counter
	move.l	a2,d7
	bne		.xloop					; loop

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	suba.l	#1,a4					; dec y
	move.l	a4,d7
	bne		.yloop

	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	LCR-	Left.Centre
;-------------------------------------------------------------------------------------------------

G4BP_Blit_LCR:


.yloop:
	move.l	#$FFFF0000,d4			; mask
	ror.l	d6,d4					; shift mask

	moveq	#0,d0					; gfx plane 0
	moveq	#0,d1					; gfx plane 1
	moveq	#0,d2					; gfx plane 2
	moveq	#0,d3					; gfx plane 3

	move.w	(a3)+,d0				; read gfx plane 2
	ror.l	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	ror.l	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	ror.l	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	ror.l	d6,d3					; shift gfx plane 3

	move.w	d5,d7
	not.w	d7
	and.w	d7,d0					; clear unwanted plane0 bits
	and.w	d7,d1					; clear unwanted plane1 bits
	and.w	d7,d2					; clear unwanted plane2 bits
	and.w	d7,d3					; clear unwanted plane3 bits

	and.w	d5,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d5,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d5,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d5,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	move.w	a6,a2
.xloop:
	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.l	d4,d0					; clear unwanted plane0 bits
	and.l	d4,d1					; clear unwanted plane1 bits
	and.l	d4,d2					; clear unwanted plane2 bits
	and.l	d4,d3					; clear unwanted plane3 bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	move.w	d0,(a5)+				; draw plane 0
	move.w	d1,(a5)+				; draw plane 1
	move.w	d2,(a5)+				; draw plane 2
	move.w	d3,(a5)+				; draw plane 3

	suba.w	#1,a2					; dec mid loop counter
	move.l	a2,d7
	bne		.xloop					; loop

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.l	d4,d0					; clear unwanted plane0 bits
	and.l	d4,d1					; clear unwanted plane1 bits
	and.l	d4,d2					; clear unwanted plane2 bits
	and.l	d4,d3					; clear unwanted plane3 bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	swap	d5
	move.w	d5,d7
	not.w	d7
	and.w	d7,d0					; clear unwanted plane0 bits
	and.w	d7,d1					; clear unwanted plane1 bits
	and.w	d7,d2					; clear unwanted plane2 bits
	and.w	d7,d3					; clear unwanted plane3 bits

	and.w	d5,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d5,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d5,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d5,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3
	swap	d5

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	suba.l	#1,a4					; dec y
	move.l	a4,d7
	bne		.yloop

	bra		G4BP_Blit_RTS

;-------------------------------------------------------------------------------------------------
; FXSR - Forced eXtra Source Read
;-------------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------------
;	--R-	Right Blit
;-------------------------------------------------------------------------------------------------

G4BP_Blit_R_F:

	move.l	a4,d7
	subq.w	#1,d7
.yloop:
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3

	ror.l	d6,d0
	ror.l	d6,d1
	ror.l	d6,d2
	ror.l	d6,d3

	and.l	d4,d0
	and.l	d4,d1
	and.l	d4,d2
	and.l	d4,d3

	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	dbra	d7,.yloop

	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	-C--	Central Blit	[ not possible ]
;-------------------------------------------------------------------------------------------------

G4BP_Blit_C_F:
	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	-CR-	Central.Right Blit
;-------------------------------------------------------------------------------------------------

G4BP_Blit_CR_F:
	move.l	#$FFFF0000,d4			; mask
	ror.l	d6,d4					; shift mask
	swap	d5
.yloop:
	move.w	(a3)+,d0				; gfx plane0
	move.w	(a3)+,d1				; gfx plane0
	move.w	(a3)+,d2				; gfx plane0
	move.w	(a3)+,d3				; gfx plane0
	ror.l	d6,d0					; shift gfx plane 0
	ror.l	d6,d1					; shift gfx plane 0
	ror.l	d6,d2					; shift gfx plane 0
	ror.l	d6,d3					; shift gfx plane 0

	move.l	a6,a2					; chunk loop
.xloop:

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.l	d4,d0					; clear unwanted plane0 bits
	and.l	d4,d1					; clear unwanted plane1 bits
	and.l	d4,d2					; clear unwanted plane2 bits
	and.l	d4,d3					; clear unwanted plane3 bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	move.w	d0,(a5)+				; draw plane 0
	move.w	d1,(a5)+				; draw plane 1
	move.w	d2,(a5)+				; draw plane 2
	move.w	d3,(a5)+				; draw plane 3

	suba.l	#1,a2					; dec mid loop counter
	move.l	a2,d7
	bne		.xloop					; loop

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.l	d4,d0					; clear unwanted plane0 bits
	and.l	d4,d1					; clear unwanted plane1 bits
	and.l	d4,d2					; clear unwanted plane2 bits
	and.l	d4,d3					; clear unwanted plane3 bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	move.l	d5,d7
	not.l	d7
	and.l	d7,d0
	and.l	d7,d1
	and.l	d7,d2
	and.l	d7,d3

	and.w	d5,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d5,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d5,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d5,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	suba.l	#1,a4					; dec y
	move.l	a4,d0
	bne		.yloop

	bra		G4BP_Blit_RTS

;-------------------------------------------------------------------------------------------------
;	L---	Left Blit	[ same as R case ]
;-------------------------------------------------------------------------------------------------

G4BP_Blit_L_F:
	move.l	a4,d7
	subq.w	#1,d7
.yloop:
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3

	ror.l	d6,d0
	ror.l	d6,d1
	ror.l	d6,d2
	ror.l	d6,d3

	and.l	d4,d0
	and.l	d4,d1
	and.l	d4,d2
	and.l	d4,d3

	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	dbra	d7,.yloop

	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	L--R	Left.Right Blit
;-------------------------------------------------------------------------------------------------

G4BP_Blit_LR_F:

	move.l	#$FFFF0000,d4			; mask
	ror.l	d6,d4					; shift mask

.yloop:

	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3

	ror.l	d6,d0
	ror.l	d6,d1
	ror.l	d6,d2
	ror.l	d6,d3

	move.w	d5,d7
	not.w	d7
	and.w	d7,d0
	and.w	d7,d1
	and.w	d7,d2
	and.w	d7,d3

	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.l	d4,d0					; clear unwanted plane0 bits
	and.l	d4,d1					; clear unwanted plane1 bits
	and.l	d4,d2					; clear unwanted plane2 bits
	and.l	d4,d3					; clear unwanted plane3 bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	swap	d5

	move.l	d5,d7
	not.l	d7
	and.l	d7,d0
	and.l	d7,d1
	and.l	d7,d2
	and.l	d7,d3

	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+
	swap	d5

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	suba.l	#1,a4					; dec mid loop counter
	move.l	a4,d7
	bne		.yloop					; loop

	bra		G4BP_Blit_RTS

;-------------------------------------------------------------------------------------------------
;	LC--	Left.Centre
;-------------------------------------------------------------------------------------------------

G4BP_Blit_LC_F:

.yloop:
	move.l	#$FFFF0000,d4			; mask
	ror.l	d6,d4					; shift mask

	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3


	move.w	(a3)+,d0				; read gfx plane 2
	ror.l	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	ror.l	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	ror.l	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	ror.l	d6,d3					; shift gfx plane 3

	move.w	d5,d7
	not.w	d7
	and.w	d7,d0
	and.w	d7,d1
	and.w	d7,d2
	and.w	d7,d3

	and.w	d5,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d5,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d5,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d5,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	move.w	a6,a2					; loopX
.xloop:
	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.l	d4,d0					; clear unwanted plane0 bits
	and.l	d4,d1					; clear unwanted plane1 bits
	and.l	d4,d2					; clear unwanted plane2 bits
	and.l	d4,d3					; clear unwanted plane3 bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	move.w	d0,(a5)+				; draw plane 0
	move.w	d1,(a5)+				; draw plane 1
	move.w	d2,(a5)+				; draw plane 2
	move.w	d3,(a5)+				; draw plane 3

	suba.l	#1,a2					; dec mid loop counter
	move.l	a2,d7
	bne		.xloop					; loop

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	suba.l	#1,a4					; dec y
	move.l	a4,d7
	bne		.yloop

	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	LCR-	Left.Centre
;-------------------------------------------------------------------------------------------------

G4BP_Blit_LCR_F:

.yloop:
	move.l	#$FFFF0000,d4			; mask
	ror.l	d6,d4					; shift mask

	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3


	move.w	(a3)+,d0				; read gfx plane 2
	ror.l	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	ror.l	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	ror.l	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	ror.l	d6,d3					; shift gfx plane 3

	move.w	d5,d7
	not.w	d7
	and.w	d7,d0
	and.w	d7,d1
	and.w	d7,d2
	and.w	d7,d3

	and.w	d5,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d5,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d5,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d5,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	move.w	a6,a2					; loopX
.xloop:
	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.l	d4,d0					; clear unwanted plane0 bits
	and.l	d4,d1					; clear unwanted plane1 bits
	and.l	d4,d2					; clear unwanted plane2 bits
	and.l	d4,d3					; clear unwanted plane3 bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	move.w	d0,(a5)+				; draw plane 0
	move.w	d1,(a5)+				; draw plane 1
	move.w	d2,(a5)+				; draw plane 2
	move.w	d3,(a5)+				; draw plane 3

	suba.l	#1,a2					; dec mid loop counter
	move.l	a2,d7
	bne		.xloop					; loop

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.l	d4,d0					; clear unwanted plane0 bits
	and.l	d4,d1					; clear unwanted plane1 bits
	and.l	d4,d2					; clear unwanted plane2 bits
	and.l	d4,d3					; clear unwanted plane3 bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	swap	d5

	move.w	d5,d7
	not.w	d7
	and.w	d7,d0
	and.w	d7,d1
	and.w	d7,d2
	and.w	d7,d3

	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+
	swap	d5

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	suba.l	#1,a4					; dec y
	move.l	a4,d7
	bne		.yloop

	bra		G4BP_Blit_RTS






;-------------------------------------------------------------------------------------------------
; FXSR - Forced eXtra Source Read
;-------------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------------
;	--R-	Right NFSR Blit
;-------------------------------------------------------------------------------------------------

G4BP_Blit_R_N:
	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	-C--	Central NFSR Blit	[ not possible ]
;-------------------------------------------------------------------------------------------------

G4BP_Blit_C_N:
	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	-CR-	Central.Right NFSR	[ not possible ]
;-------------------------------------------------------------------------------------------------

G4BP_Blit_CR_N:
	bra		G4BP_Blit_RTS

;-------------------------------------------------------------------------------------------------
;	L---	Left Blit	NFSR	[ not possible ]
;-------------------------------------------------------------------------------------------------

G4BP_Blit_L_N:
	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	L--R	Left.Right Blit NFSR
;-------------------------------------------------------------------------------------------------

G4BP_Blit_LR_N:


	move.l	a4,d7
	subq.w	#1,d7
.yloop:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3

	ror.l	d6,d0
	ror.l	d6,d1
	ror.l	d6,d2
	ror.l	d6,d3

	and.l	d4,d0
	and.l	d4,d1
	and.l	d4,d2
	and.l	d4,d3

	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+

	swap	d0
	swap	d1
	swap	d2
	swap	d3
	swap	d5
	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+
	swap	d5

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	dbra	d7,.yloop


	bra		G4BP_Blit_RTS

;-------------------------------------------------------------------------------------------------
;	LC--	Left.Centre NFSR	[ not possible ]
;-------------------------------------------------------------------------------------------------

G4BP_Blit_LC_N:
	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	LCR-	Left.Centre NFSR
;-------------------------------------------------------------------------------------------------

G4BP_Blit_LCR_N:

.yloop:
	move.l	#$FFFF0000,d4			; mask
	ror.l	d6,d4					; shift mask

	moveq	#0,d0					; gfx plane 0
	moveq	#0,d1					; gfx plane 1
	moveq	#0,d2					; gfx plane 2
	moveq	#0,d3					; gfx plane 3

	move.w	(a3)+,d0				; read gfx plane 2
	ror.l	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	ror.l	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	ror.l	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	ror.l	d6,d3					; shift gfx plane 3

	move.w	d5,d7
	not.w	d7
	and.w	d7,d0
	and.w	d7,d1
	and.w	d7,d2
	and.w	d7,d3


	and.w	d5,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d5,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d5,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d5,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	move.w	a6,a2
.xloop:
	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.l	d4,d0					; clear unwanted plane0 bits
	and.l	d4,d1					; clear unwanted plane1 bits
	and.l	d4,d2					; clear unwanted plane2 bits
	and.l	d4,d3					; clear unwanted plane3 bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	move.w	d0,(a5)+				; draw plane 0
	move.w	d1,(a5)+				; draw plane 1
	move.w	d2,(a5)+				; draw plane 2
	move.w	d3,(a5)+				; draw plane 3

	suba.w	#1,a2					; dec mid loop counter
	move.l	a2,d7
	bgt		.xloop					; loop

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	swap	d5
	move.w	d5,d7
	not.w	d7
	and.w	d7,d0
	and.w	d7,d1
	and.w	d7,d2
	and.w	d7,d3


	and.w	d5,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d5,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d5,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d5,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3
	swap	d5

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	suba.l	#1,a4					; dec y
	move.l	a4,d7
	bne		.yloop

	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
; FXSR.NFSR ROUTS
;-------------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------------
;	---R	Right Blit FXSR.NFSR [ not possible ]
;-------------------------------------------------------------------------------------------------

G4BP_Blit_R_FN:
	bra		G4BP_Blit_RTS

;-------------------------------------------------------------------------------------------------
;	--C-	Central Blit FXSR.NFSR [ not possible ]
;-------------------------------------------------------------------------------------------------

G4BP_Blit_C_FN:
	bra		G4BP_Blit_RTS

;-------------------------------------------------------------------------------------------------
;	-L--	Left Blit FXSR.NFSR [ not possible ]
;-------------------------------------------------------------------------------------------------

G4BP_Blit_L_FN:
	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	--CR	Central.Right Blit FXSR.NFSR [ not possible ]
;-------------------------------------------------------------------------------------------------

G4BP_Blit_CR_FN:
	move.l	#$FFFF0000,d4			; mask
	ror.l	d6,d4					; shift mask
	swap	d5
.yloop:
	move.w	(a3)+,d0				; gfx plane0
	move.w	(a3)+,d1				; gfx plane0
	move.w	(a3)+,d2				; gfx plane0
	move.w	(a3)+,d3				; gfx plane0
	ror.l	d6,d0					; shift gfx plane 0
	ror.l	d6,d1					; shift gfx plane 0
	ror.l	d6,d2					; shift gfx plane 0
	ror.l	d6,d3					; shift gfx plane 0

	move.l	a6,a2					; chunk loop
.xloop:

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.l	d4,d0					; clear unwanted plane0 bits
	and.l	d4,d1					; clear unwanted plane1 bits
	and.l	d4,d2					; clear unwanted plane2 bits
	and.l	d4,d3					; clear unwanted plane3 bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	move.w	d0,(a5)+				; draw plane 0
	move.w	d1,(a5)+				; draw plane 1
	move.w	d2,(a5)+				; draw plane 2
	move.w	d3,(a5)+				; draw plane 3

	suba.l	#1,a2					; dec mid loop counter
	move.l	a2,d7
	bne		.xloop					; loop

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	move.w	d5,d7
	not.w	d7
	and.w	d7,d0
	and.w	d7,d1
	and.w	d7,d2
	and.w	d7,d3

	and.w	d5,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d5,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d5,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d5,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	suba.l	#1,a4					; dec y
	move.l	a4,d0
	bne		.yloop

	bra		G4BP_Blit_RTS

;-------------------------------------------------------------------------------------------------
;	L--R	Left.Right Blit FXSR.NFSR
;-------------------------------------------------------------------------------------------------

G4BP_Blit_LR_FN:


	move.l	a4,d7
	subq.w	#1,d7
.yloop:
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3

	ror.l	d6,d0
	ror.l	d6,d1
	ror.l	d6,d2
	ror.l	d6,d3

	and.l	d4,d0
	and.l	d4,d1
	and.l	d4,d2
	and.l	d4,d3

	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+

	swap	d0
	swap	d1
	swap	d2
	swap	d3
	swap	d5
	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+
	swap	d5

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	dbra	d7,.yloop


	bra		G4BP_Blit_RTS

;-------------------------------------------------------------------------------------------------
;	-LC-	Left.Central Blit FXSR.NFSR [ not possible ]
;-------------------------------------------------------------------------------------------------

G4BP_Blit_LC_FN:
	bra		G4BP_Blit_RTS

;-------------------------------------------------------------------------------------------------
;	LCR-	Left.Centre NFSR
;-------------------------------------------------------------------------------------------------

G4BP_Blit_LCR_FN:

.yloop:
	move.l	#$FFFF0000,d4			; mask
	ror.l	d6,d4					; shift mask

	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	move.w	(a3)+,d0				; read gfx plane 2
	ror.l	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	ror.l	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	ror.l	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	ror.l	d6,d3					; shift gfx plane 3

	move.w	d5,d7
	not.w	d7
	and.w	d7,d0
	and.w	d7,d1
	and.w	d7,d2
	and.w	d7,d3

	and.w	d5,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d5,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d5,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d5,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	move.w	a6,a2
.xloop:
	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.l	d4,d0					; clear unwanted plane0 bits
	and.l	d4,d1					; clear unwanted plane1 bits
	and.l	d4,d2					; clear unwanted plane2 bits
	and.l	d4,d3					; clear unwanted plane3 bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	move.w	d0,(a5)+				; draw plane 0
	move.w	d1,(a5)+				; draw plane 1
	move.w	d2,(a5)+				; draw plane 2
	move.w	d3,(a5)+				; draw plane 3

	suba.w	#1,a2					; dec mid loop counter
	move.l	a2,d7
	bgt		.xloop					; loop

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	swap	d5
	move.w	d5,d7
	not.w	d7
	and.w	d7,d0
	and.w	d7,d1
	and.w	d7,d2
	and.w	d7,d3
	and.w	d5,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d5,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d5,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d5,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3
	swap	d5

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	suba.l	#1,a4					; dec y
	move.l	a4,d7
	bne		.yloop

	bra		G4BP_Blit_RTS

;-------------------------------------------------------------------------------------------------
; ALIGNED ROUTS
;-------------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------------
;	--RA	Right Aligned Blit
;-------------------------------------------------------------------------------------------------

G4BP_Blit_R_A:

	move.l	a4,d6
	subq.w	#1,d6

	swap	d4
	swap	d5
.yloop:

	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3

	and.w	d4,d0
	and.w	d4,d1
	and.w	d4,d2
	and.w	d4,d3

	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+

	add.l	a0,a3
	add.l	a1,a5

	dbra	d6,.yloop

	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	-CRA	Central.Right Aligned Blit
;-------------------------------------------------------------------------------------------------

G4BP_Blit_CR_A:

	move.l	a4,d7
	subq.w	#1,d7
	suba.l	#1,a6

	swap	d4
	swap	d5

.yloop:
	move.l	a6,d0
.xloop:
	move.w	(a3)+,(a5)+
	move.w	(a3)+,(a5)+
	move.w	(a3)+,(a5)+
	move.w	(a3)+,(a5)+

	dbra	d0,.xloop

	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3

	and.w	d4,d0
	and.w	d4,d1
	and.w	d4,d2
	and.w	d4,d3

	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+

	add.l	a0,a3
	add.l	a1,a5

	dbra	d7,.yloop

	bra		G4BP_Blit_RTS



;-------------------------------------------------------------------------------------------------
;	-C-A	Central Aligned Blit
;-------------------------------------------------------------------------------------------------

G4BP_Blit_C_A:
	move.l	a4,d1
	subq.w	#1,d1
	suba.l	#1,a6
.yloop:
	move.l	a6,d0
.xloop:
	move.w	(a3)+,(a5)+
	move.w	(a3)+,(a5)+
	move.w	(a3)+,(a5)+
	move.w	(a3)+,(a5)+

	dbra	d0,.xloop

	add.l	a0,a3
	add.l	a1,a5
	dbra	d1,.yloop

	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	L--A	Left Aligned Blit
;-------------------------------------------------------------------------------------------------

G4BP_Blit_L_A:
	move.l	a4,d6
	subq.w	#1,d6

.yloop:

	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3

	and.w	d4,d0
	and.w	d4,d1
	and.w	d4,d2
	and.w	d4,d3

	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+

	add.l	a0,a3
	add.l	a1,a5

	dbra	d6,.yloop

	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	L-RA	Left.Right Aligned Blit
;-------------------------------------------------------------------------------------------------

G4BP_Blit_LR_A:

	move.l	a4,d1
	subq.w	#1,d1

	move.l	d4,d6
	move.l	d5,d7
	swap	d6
	swap	d7

;	subq.l	#8,a0
;	subq.l	#8,a1
.yloop:
	move.w	(a3)+,d0
	and.w	d4,d0
	and.w	d5,(a5)
	or.w	d0,(a5)+
	move.w	(a3)+,d0
	and.w	d4,d0
	and.w	d5,(a5)
	or.w	d0,(a5)+
	move.w	(a3)+,d0
	and.w	d4,d0
	and.w	d5,(a5)
	or.w	d0,(a5)+
	move.w	(a3)+,d0
	and.w	d4,d0
	and.w	d5,(a5)
	or.w	d0,(a5)+

	move.w	(a3)+,d0
	and.w	d6,d0
	and.w	d7,(a5)
	or.w	d0,(a5)+
	move.w	(a3)+,d0
	and.w	d6,d0
	and.w	d7,(a5)
	or.w	d0,(a5)+
	move.w	(a3)+,d0
	and.w	d6,d0
	and.w	d7,(a5)
	or.w	d0,(a5)+
	move.w	(a3)+,d0
	and.w	d6,d0
	and.w	d7,(a5)
	or.w	d0,(a5)+

	add.l	a0,a3
	add.l	a1,a5

	dbra	d1,.yloop
	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	LC-A	Left.Central Aligned Blit
;-------------------------------------------------------------------------------------------------

G4BP_Blit_LC_A:

	move.l	a4,d7
	subq.w	#1,d7
	suba.l	#1,a6
.yloop:

	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.w	(a3)+,d3

	and.w	d4,d0
	and.w	d4,d1
	and.w	d4,d2
	and.w	d4,d3

	and.w	d5,(a5)
	or.w	d0,(a5)+
	and.w	d5,(a5)
	or.w	d1,(a5)+
	and.w	d5,(a5)
	or.w	d2,(a5)+
	and.w	d5,(a5)
	or.w	d3,(a5)+

	move.l	a6,d0
.xloop:
	move.w	(a3)+,(a5)+
	move.w	(a3)+,(a5)+
	move.w	(a3)+,(a5)+
	move.w	(a3)+,(a5)+

	dbra	d0,.xloop


	add.l	a0,a3
	add.l	a1,a5

	dbra	d7,.yloop

	bra		G4BP_Blit_RTS


;-------------------------------------------------------------------------------------------------
;	LCRA	Left.Central Aligned Blit
;-------------------------------------------------------------------------------------------------

G4BP_Blit_LCR_A:
	
	move.l	d4,d6
	move.l	d5,d7
	swap	d6
	swap	d7

	move.l	a4,d1
	subq.w	#1,d1
	suba.l	#1,a6
.yloop:

	move.w	(a3)+,d0
	and.w	d4,d0
	and.w	d5,(a5)
	or.w	d0,(a5)+
	move.w	(a3)+,d0
	and.w	d4,d0
	and.w	d5,(a5)
	or.w	d0,(a5)+
	move.w	(a3)+,d0
	and.w	d4,d0
	and.w	d5,(a5)
	or.w	d0,(a5)+
	move.w	(a3)+,d0
	and.w	d4,d0
	and.w	d5,(a5)
	or.w	d0,(a5)+

	move.l	a6,d0
.xloop:
	move.w	(a3)+,(a5)+
	move.w	(a3)+,(a5)+
	move.w	(a3)+,(a5)+
	move.w	(a3)+,(a5)+

	dbra	d0,.xloop

	move.w	(a3)+,d0
	and.w	d6,d0
	and.w	d7,(a5)
	or.w	d0,(a5)+
	move.w	(a3)+,d0
	and.w	d6,d0
	and.w	d7,(a5)
	or.w	d0,(a5)+
	move.w	(a3)+,d0
	and.w	d6,d0
	and.w	d7,(a5)
	or.w	d0,(a5)+
	move.w	(a3)+,d0
	and.w	d6,d0
	and.w	d7,(a5)
	or.w	d0,(a5)+

	add.l	a0,a3
	add.l	a1,a5

	dbra	d1,.yloop



G4BP_Blit_RTS:
	movem.l	(a7)+,d3-d7/a2-a6
	rts



	

*------------------------------------------------------------------------------------*
* FUNCTION: void (*	ClearScreen )( const struct sGraphicCanvas * apCanvas );
* ACTION:   clears a 320x200 screen
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_ClearScreen:
	movem.l	d3-d7/a2-a6,-(a7)							; save regs

	cmp.w	#320,sGraphicCanvas_Width(a0)
	bne		Graphic_4BP_ClearScreen_Gen
	cmp.w	#200,sGraphicCanvas_Height(a0)
	bne		Graphic_4BP_ClearScreen_Gen

	move.l	sGraphicCanvas_pVRAM(a0),a0					; pScreen

	moveq	#0,d0										; clear d0
	move.l	d0,d1										; clear d1
	move.l	d0,d2										; clear d2
	move.l	d0,d3										; clear d3
	move.l	d0,d4										; clear d4
	move.l	d0,d5										; clear d5
	move.l	d0,d6										; clear d6
	move.l	d0,d7										; clear d7
	move.l	d0,a1										; clear a1
	move.l	d0,a2										; clear a2
	move.l	d0,a3										; clear a3
	move.l	d0,a4										; clear a4
	move.l	d0,a5										; clear a5
	move.l	d0,a6										; clear a6

	adda.l	#32000,a0									; get to end of screen

	moveq	#37,d7										; 38 loops

.ClearLoop:

	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes

	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes

	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes

	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes

	dbra	d7,.ClearLoop

	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes

	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes

	movem.l	d0-d4,-(a0)									; clear 20 bytes

	movem.l	(a7)+,d3-d7/a2-a6
	rts


Graphic_4BP_ClearScreen_Gen:

	move.l	sGraphicCanvas_LineOffsets+4(a0),d0			; line width
	move.w	sGraphicCanvas_Height(a0),d2				; height
	subq.w	#1,d2										; height-1

	lsr.l	#4,d0										; width/16
	subq.w	#1,d0										; -1 for dbra
	moveq	#0,d3										; clear value

	move.l	sGraphicCanvas_pVRAM(a0),a0					; pScreen
.clrY:
	move.w	d0,d1										; X counter
.clrX:
	move.l	d3,(a0)+									; Clear Planes 0.1
	move.l	d3,(a0)+									; Clear Planes 2.3
	dbra	d1,.clrX									; Loop For All X
	dbra	d2,.clrY									; Loop For All Y

	movem.l	(a7)+,d3-d7/a2-a6
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (*	CopyScreen )(  const struct sGraphicCanvas * apCanvas, void * apSrc, void * apDst );
* ACTION:   copies a 320x200 screen
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_CopyScreen:
	movem.l	d3-d7/a2-a6,-(a7)							; save regs

	cmp.w	#320,sGraphicCanvas_Width(a0)
	bne		Graphic_4BP_CopyScreen_Gen
	cmp.w	#200,sGraphicCanvas_Height(a0)
	bne		Graphic_4BP_CopyScreen_Gen

	move.l	sGraphicCanvas_pVRAM(a0),a0					; dst

	moveq	#40,d7										; 41 loops

.CopyLoop:

	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location

	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location

	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location

	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location

	dbra	d7,.CopyLoop

	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location

	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location

	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location
	movem.l	(a1)+,d0-d6/a2-a6							; read 48 bytes
	movem.l	d0-d6/a2-a6,(a0)							; write 48 bytes
	lea		48(a0),a0									; next chunk location

	movem.l	(a1),d0-d6/a2								; read 48 bytes
	movem.l	d0-d6/a2,(a0)								; write 48 bytes

	movem.l	(a7)+,d3-d7/a2-a6							; restore registers
	rts


Graphic_4BP_CopyScreen_Gen:

	move.w	sGraphicCanvas_LineOffsets+4(a0),d0			; line width
	move.w	sGraphicCanvas_Height(a0),d2				; height
	move.l	sGraphicCanvas_pVRAM(a0),a0					; dst
	subq.w	#1,d2										; height-1

	lsr.w	#4,d0										; width/16
	subq.w	#1,d0										; -1 for dbra

.cpyY:
	move.w	d0,d1										; X counter
.cpyX:
	move.l	(a1)+,(a0)+									; Copy Planes 0.1
	move.l	(a1)+,(a0)+									; Copy Planes 2.3
	dbra	d1,.cpyX									; Loop For All X
	dbra	d2,.cpyY									; Loop For All Y

	movem.l	(a7)+,d3-d7/a2-a6							; restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (* DrawBox )(      struct sGraphicCanvas * apCanvas,  sGraphicRect * apCoords,  S16 aColour );
* ACTION:   draws a box
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_DrawBox_Clip:
	movem.l	d3-d7/a2-a6,-(a7)					; save regs

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
	movem.l	(a7)+,d3-d7/a2-a6					; restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (* DrawBox )(      struct sGraphicCanvas * apCanvas,  sGraphicRect * apCoords,  S16 aColour );
* ACTION:   draws a box
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_DrawBox:
	movem.l	d3-d7/a2-a6,-(a7)					; save regs

	move.w	sGraphicRect_X(a1),d1				; Pixel X
	move.w	sGraphicRect_Y(a1),d2				; Pixel Y
	move.w	sGraphicRect_Width(a1),d3			; Width
	move.w	sGraphicRect_Height(a1),d4			; Height

Graphic_4BP_DrawBox_Go:

	move.l	sGraphicCanvas_LineOffsets+4(a0),a6	; line width

	subq.w	#1,d4								; -1 for dbra

	add.w	d2,d2								; Y * 2
	add.w	d2,d2								; Y * 4
	add.l	#sGraphicCanvas_LineOffsets,d2		; Line Offsets Table
	move.l	(a0,d2.w),a2						; Get To Y

	move.w	d1,d2								; X
	and.l	#$0000FFF0,d2						; To Nearest 16
	lsr.w	#1,d2								; 8 Byte Offset for bitplane
	add.l	d2,a2								; Get To X
	add.l	sGraphicCanvas_pVRAM(a0),a2			; Get To Position On Screen

	and.l	#15,d0								; Colour
	lsl.w	#3,d0								; Colour * 8
	lea		Graphic_4BP_ColourChunks,a0			; colour chunks
	add.l	d0,a0

	moveq	#-1,d5

	moveq	#15,d2								; mask
	and.w	d1,d2								; X & 15
	beq.s	.noLeft								; 16 pixel aligned, no left strip

	move.w	d2,d0								; X0 &15

	add.w	d2,d2								; X offset *2
	add.w	d2,d2								; X offset *4
	lea		gGraphic_4BP_DoubleLeftMasks,a1
	move.l	(a1,d2.w),d5						; double mask

	add.w	d3,d0								; +Width
	cmp.w	#16,d0								; into next plane?
	bge		.noDClip

	add.w	d0,d0								; X offset *2
	add.w	d0,d0								; X offset *4
	lea		gGraphic_4BP_DoubleRightMasks-4,a1
	and.l	(a1,d0.w),d5						; double mask

.noDClip:

	move.l	(a0),d0								; Plane 0.1
	move.l	4(a0),d2							; Plane 2.3
	and.l	d5,d0								; Mask Planes 0.1
	and.l	d5,d2								; Mask Planes 1.2
	not.l	d5

	move.w	d4,d6								; Height
	move.l	a2,a1								; pVRAM
	move.l	a6,a3								; Line Width
	subq.l	#4,a3								; -4
.leftLoop:
	and.l	d5,(a1)								; Mask Dst Planes 0.1
	or.l	d0,(a1)+							; Draw Planes 0.1
	and.l	d5,(a1)								; Mask Planes 1.2
	or.l	d2,(a1)								; Draw Planes 1.2
	add.l	a3,a1								; Next Scanline
	dbra	d6,.leftLoop						; Loop For Box Height

	addq.l	#8,a2								; Get to Next bitplanes

	moveq	#15,d0								; 15
	and.w	d1,d0								; X & 15
	moveq	#16,d2								; 16
	sub.w	d0,d2								; 16-(X&15) = num pixels drawn
	add.w	d2,d1								; New X Pos
	sub.w	d2,d3								; Dec Width
	ble		.fin								; All Drawn

.noLeft:

	move.w	d3,d6								; width
	lsr.w	#4,d6								; /16
	beq		.noMid

	move.w	d6,d0								; num chunks
	lsl.w	#3,d0								; *chunk size
	move.l	a6,a5
	sub.w	d0,a5								; adjust line offset

	move.l	a2,a1								; pVRAM
	lea		(a2,d0.w),a2						; scren adr for right strip
	subq.w	#1,d6								; -1 for dbra

	move.l	(a0),d0								; Plane 0.1
	move.l	4(a0),d2							; Plane 2.3

	move.w	d4,d7								; height
.midLoopY:
	move.w	d6,d5								; Init X Loop
.midLoopX:
	move.l	d0,(a1)+							; Draw Planes 0.1
	move.l	d2,(a1)+							; Draw Planes 2.3
	dbra	d5,.midLoopX						; Loop For X
	add.l	a5,a1								; Next Line
	dbra	d7,.midLoopY						; Loop For Y


.noMid:

	and.w	#15,d3								; dec width
	beq		.fin

	add.w	d3,d3								; X offset *2
	add.w	d3,d3								; X offset *4
	lea		gGraphic_4BP_DoubleRightMasks-4,a1
	move.l	(a1,d3.w),d5						; double mask

	move.l	(a0),d0								; Plane 0.1
	move.l	4(a0),d2							; Plane 2.3
	and.l	d5,d0								; Mask Planes 0.1
	and.l	d5,d2								; Mask Planes 2.3
	not.l	d5

	subq.l	#4,a6								; LineSize -4
.rightLoop:
	and.l	d5,(a2)								; Mask Planes 0.1
	or.l	d0,(a2)+							; Draw Planes 0.1
	and.l	d5,(a2)								; Mask Planes 2.3
	or.l	d2,(a2)								; Draw Planes 2.3
	add.l	a6,a2								; Next Scanline
	dbra	d4,.rightLoop						; Loop For Box Height

	
.fin:			

	movem.l	(a7)+,d3-d7/a2-a6					; restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (* DrawPixel )(   const struct sGraphicCanvas * apCanvas, const sGraphicPos * apCoords,  const S16 aColour )
* ACTION:   draws a pixel with clipping
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_4BP_DrawPixel_Clip:

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

Graphic_4BP_DrawPixel:

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

Graphic_4BP_DrawSprite_Clip:
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

*
* D0 : gfx0             A0 : VRAM Line Offset
* D1 : gfx1             A1 : GFX Line Offset
* D2 : Width/gfx2       A2 : MSK Line Offset
* D3 : Height/gfx3      A3 : pSpriteGFX
* D4 : msk              A4 : pSpriteMSK
* D5 : BITMASK          A5 : pVRAM
* D6 : SHIFT            A6 : LoopX
* D7 : temp                  
* 0(a7) loopx
* 4(a7) loopy

Graphic_4BP_DrawSprite:
	movem.l	d3-d7/a2-a6,-(a7)

	move.l	11*4(a7),a2
	move.w	sGraphicPos_X(a1),d0
	move.w	sGraphicPos_Y(a1),d1
	move.w	sGraphicSprite_Width(a2),d2
	move.w	sGraphicSprite_Height(a2),d3
	move.l	sGraphicSprite_pGfx(a2),a3
	move.l	sGraphicSprite_pMask(a2),a4

Graphic_4BP_DrawSprite_Go:
	lea		-slSpr_sizeof(a7),a7				; create space for locals

	move.w	d3,slSpr_Yloop(a7)					; loopy

	tst.w	sGraphicSprite_MaskPlaneCount(a2)
	seq		d4
	and.l	#1,d4

;-------------------------------------------------------------------------------------------------
;	get to position on screen
;-------------------------------------------------------------------------------------------------

	add.w	d1,d1								; Y*2
	add.w	d1,d1								; Y*4
	add.l	#sGraphicCanvas_LineOffsets,d1		; Line Offsets Table
	move.l	(a0,d1.w),d1						; Read Line Offset
	move.l	sGraphicCanvas_pVRAM(a0),a5			; pointer to screen memory
	add.l	d1,a5								; get to Y Line

	move.w	d0,d1								; X
	and.l	#$0000FFF0,d1						; to Nearest 16
	lsr.w	#1,d1								; X offset
	add.l	d1,a5								; get to X

;-------------------------------------------------------------------------------------------------
;	calc chunk count
;-------------------------------------------------------------------------------------------------

	move.w	sGraphicCanvas_Width(a0),d1			; canvas with
	lsr.w	#1,d1
	move.w	d1,a0								; VRAM Offset

	move.w	sGraphicSprite_Width(a2),d1			; original sprite width
	lsr.w	#1,d1								; offset to next line in vram
	move.l	d1,a1								; GFX offset
	lsr.w	#2,d1
	move.w	d1,a2								; MSK offset

	moveq	#15,d6								; shift mask
	and.w	d0,d6								; shift amount

	move.w	d0,d1								; X0
	add.w	d0,d2								; X1
	moveq	#15,d3
	and.w	d0,d3
	beq.s	.noLM
	or.w	#dSPRCHUNK_LEFT,d4
	add.w	#16,d1
	and.w	#$FFF0,d1
	suba.l	#8,a0
.noLM:
	moveq	#15,d3
	and.w	d2,d3
	beq		.noRM
	or.w	#dSPRCHUNK_RIGHT,d4	
	and.w	#$FFF0,d2
	suba.l	#8,a0
	move.w	d3,d6
.noRM:
	sub.w	d1,d2								; chunk count
	ble		.noCM
	or.w	#dSPRCHUNK_MID,d4	
.noCM:			
	lsr.w	#4,d2
	bpl.s	.cPL
	moveq	#0,d2
.cPL:
	move.w	d2,slSpr_Xloop(a7)
	add.w	d2,d2
	suba.w	d2,a2
	lsl.w	#2,d2
	suba.w	d2,a0
	suba.w	d2,a1

;-------------------------------------------------------------------------------------------------
;	calc offsets
;-------------------------------------------------------------------------------------------------



	move.w	d6,d5
	lsl.w	#2,d5								; *4
	lea		gGraphic_4BP_LongMasks,a6
	move.l	(a6,d5.w),d5						; mask

	add.w	d4,d4
	add.w	d4,d4
	jmp		gG4BP_DrawSprite_Class(pc,d4.w)

gG4BP_DrawSprite_Class:							; LCRO
	bra.w	G4BP_DrawSprite_RTS					; 0000
	bra.w	G4BP_DrawSprite_RTS					; 0001
	bra.w	G4BP_DrawSprite_R_T					; 0010
	bra.w	G4BP_DrawSprite_R_O					; 0011
	bra.w	G4BP_DrawSprite_C_T					; 0100
	bra.w	G4BP_DrawSprite_C_O					; 0101
	bra.w	G4BP_DrawSprite_CR_T				; 0110
	bra.w	G4BP_DrawSprite_CR_O				; 0111
	bra.w	G4BP_DrawSprite_L_T					; 1000
	bra.w	G4BP_DrawSprite_L_O					; 1001
	bra.w	G4BP_DrawSprite_LR_T				; 1010
	bra.w	G4BP_DrawSprite_LR_O				; 1011
	bra.w	G4BP_DrawSprite_LC_T				; 1100
	bra.w	G4BP_DrawSprite_LC_O				; 1101
	bra.w	G4BP_DrawSprite_LCR_T				; 1110
	bra.w	G4BP_DrawSprite_LCR_O				; 1111


;-------------------------------------------------------------------------------------------------
;	--R-	Right Chunk Transparent Sprite Render
;-------------------------------------------------------------------------------------------------

G4BP_DrawSprite_R_T:
	suba.l	#8,a1
	suba.l	#2,a2
	move.w	slSpr_Yloop(a7),d5
	subq.w	#1,d5
	neg.w	d6
	add.w	#16,d6

	moveq	#0,d0					; gfx plane 0
	moveq	#0,d1					; gfx plane 1
	moveq	#0,d2					; gfx plane 2
	moveq	#0,d3					; gfx plane 3

.yloop:
	moveq	#-1,d4					; mask

	move.w	(a4)+,d4				; read mask
	rol.l	d6,d4					; shift mask

	move.w	(a3)+,d0				; read gfx plane 2
	lsl.w	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	lsl.w	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	lsl.w	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	lsl.w	d6,d3					; shift gfx plane 3

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line
	add.l	a2,a4					; next mask line

	dbra	d5,.yloop
	bra		G4BP_DrawSprite_RTS


;-------------------------------------------------------------------------------------------------
;	--RO	Right Chunk Opaque Sprite Render
;-------------------------------------------------------------------------------------------------

G4BP_DrawSprite_R_O:
	suba.l	#8,a1
	move.w	slSpr_Yloop(a7),d5
	subq.w	#1,d5
	neg.w	d6
	add.w	#16,d6

	moveq	#0,d0					; gfx plane 0
	moveq	#0,d1					; gfx plane 1
	moveq	#0,d2					; gfx plane 2
	moveq	#0,d3					; gfx plane 3

	move.l	#$FFFF0000,d4
	rol.l	d6,d4

.yloop:
	move.w	(a3)+,d0				; read gfx plane 2
	lsl.w	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	lsl.w	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	lsl.w	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	lsl.w	d6,d3					; shift gfx plane 3

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	dbra	d5,.yloop

	bra		G4BP_DrawSprite_RTS


;-------------------------------------------------------------------------------------------------
;	-M--	Central Chunk Transparent Sprite Render
;-------------------------------------------------------------------------------------------------

G4BP_DrawSprite_C_T:

	move.w	slSpr_Yloop(a7),d1		; y loop
	move.w	slSpr_Xloop(a7),a6
	subq.w	#1,d1					; -1 for dbra
	suba.w	#1,a6

.yloop:
	move.l	a6,d0					; xloop
.xloop:
	move.w	(a4)+,d4				; read mask
	move.w	(a3)+,d7				; read gfx plane 0
	and.w	d4,(a5)					; mask plane 0     
	or.w	d7,(a5)+				; draw plane 0     
	move.w	(a3)+,d7				; read gfx plane 1
	and.w	d4,(a5)					; mask plane 1
	or.w	d7,(a5)+				; draw plane 1
	move.w	(a3)+,d7				; read gfx plane 2
	and.w	d4,(a5)					; mask plane 2
	or.w	d7,(a5)+				; draw plane 2
	move.w	(a3)+,d7				; read gfx plane 3
	and.w	d4,(a5)					; mask plane 3
	or.w	d7,(a5)+				; draw plane 3
	
	dbra	d0,.xloop				; loop for x

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line
	add.l	a2,a4					; next mask line
	dbra	d1,.yloop				; loop for all y
	bra		G4BP_DrawSprite_RTS


;-------------------------------------------------------------------------------------------------
;	-C-O	Central Chunk Opaque Sprite Render
;-------------------------------------------------------------------------------------------------

G4BP_DrawSprite_C_O:

	move.w	slSpr_Yloop(a7),d1				; y loop
	move.w	slSpr_Xloop(a7),a6
	subq.w	#1,d1					; -1 for dbra
	suba.w	#1,a6

.yloop:
	move.l	a6,d0					; xloop
.xloop:
	move.l	(a3)+,(a5)+				; draw sprite plane 0.1
	move.l	(a3)+,(a5)+				; draw sprite plane 2.3
	
	dbra	d0,.xloop				; loop for x

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line
	dbra	d1,.yloop				; loop for all y
	bra		G4BP_DrawSprite_RTS


;-------------------------------------------------------------------------------------------------
;	-CR-	Central.Right Chunk Transparent Sprite Render
;-------------------------------------------------------------------------------------------------

G4BP_DrawSprite_CR_T:
	suba.l	#8,a1
	suba.l	#2,a2

.yloop:
	move.w	(a3)+,d0				; gfx plane0
	move.w	(a3)+,d1				; gfx plane0
	move.w	(a3)+,d2				; gfx plane0
	move.w	(a3)+,d3				; gfx plane0
	move.w	(a4)+,d4				; mask
	ror.l	d6,d0					; shift gfx plane 0
	ror.l	d6,d1					; shift gfx plane 0
	ror.l	d6,d2					; shift gfx plane 0
	ror.l	d6,d3					; shift gfx plane 0
	ror.l	d6,d4					; shift gfx plane 0

	move.w	slSpr_Xloop(a7),a6		; chunk loop
.xloop:

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3
	swap	d4						; rem of last mask

	and.l	d5,d0					; clear unwanted plane0 bits
	and.l	d5,d1					; clear unwanted plane1 bits
	and.l	d5,d2					; clear unwanted plane2 bits
	and.l	d5,d3					; clear unwanted plane3 bits
	move.l	d5,d7
	not.l	d7
	or.l	d7,d4					; clear unwanted mask bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	move.l	#$FFFF0000,d7			; clear high word of tmp
	move.w	(a4)+,d7				; read msk 
	ror.l	d6,d7					; shift msk
	and.l	d7,d4					; combine last and new msk chunks

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	suba.w	#1,a6					; dec mid loop counter
	move.l	a6,d7
	bne		.xloop					; loop

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3
	swap	d4						; rem of last mask

	and.l	d5,d0					; clear unwanted plane0 bits
	and.l	d5,d1					; clear unwanted plane1 bits
	and.l	d5,d2					; clear unwanted plane2 bits
	and.l	d5,d3					; clear unwanted plane3 bits
	move.l	d5,d7
	not.l	d7
	or.l	d7,d4					; clear unwanted mask bits

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line
	add.l	a2,a4					; next mask line

	subq.w	#1,slSpr_Yloop(a7)		; dec y
	bne		.yloop

	bra		G4BP_DrawSprite_RTS


;-------------------------------------------------------------------------------------------------
;	-CRO	Central.Right Chunk Opaque Sprite Render
;-------------------------------------------------------------------------------------------------

G4BP_DrawSprite_CR_O:
	suba.l	#8,a1

	move.l	#$0000FFFF,d4			; mask
	ror.l	d6,d4					; shift mask

.yloop:
	move.w	(a3)+,d0				; gfx plane0
	move.w	(a3)+,d1				; gfx plane0
	move.w	(a3)+,d2				; gfx plane0
	move.w	(a3)+,d3				; gfx plane0
	ror.l	d6,d0					; shift gfx plane 0
	ror.l	d6,d1					; shift gfx plane 0
	ror.l	d6,d2					; shift gfx plane 0
	ror.l	d6,d3					; shift gfx plane 0

	move.w	slSpr_Xloop(a7),a6		; chunk loop
.xloop:

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.l	d5,d0					; clear unwanted plane0 bits
	and.l	d5,d1					; clear unwanted plane1 bits
	and.l	d5,d2					; clear unwanted plane2 bits
	and.l	d5,d3					; clear unwanted plane3 bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks


	move.w	d0,(a5)+				; draw plane 0
	move.w	d1,(a5)+				; draw plane 1
	move.w	d2,(a5)+				; draw plane 2
	move.w	d3,(a5)+				; draw plane 3

	suba.w	#1,a6					; dec mid loop counter
	move.l	a6,d7
	bne		.xloop					; loop

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.l	d5,d0					; clear unwanted plane0 bits
	and.l	d5,d1					; clear unwanted plane1 bits
	and.l	d5,d2					; clear unwanted plane2 bits
	and.l	d5,d3					; clear unwanted plane3 bits

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	subq.w	#1,slSpr_Yloop(a7)		; dec y
	bne		.yloop
	bra		G4BP_DrawSprite_RTS


;-------------------------------------------------------------------------------------------------
;	L---	Left Chunk Transparent Sprite Render
;-------------------------------------------------------------------------------------------------

G4BP_DrawSprite_L_T:
	suba.l	#8,a1
	suba.l	#2,a2
	move.w	slSpr_Yloop(a7),d5
	subq.w	#1,d5

	moveq	#0,d0					; gfx plane 0
	moveq	#0,d1					; gfx plane 1
	moveq	#0,d2					; gfx plane 2
	moveq	#0,d3					; gfx plane 3

.yloop:
	moveq	#-1,d4					; mask

	move.w	(a4)+,d4				; read mask
	lsr.l	d6,d4					; shift mask

	move.w	(a3)+,d0				; read gfx plane 2
	lsr.w	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	lsr.w	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	lsr.w	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	lsr.w	d6,d3					; shift gfx plane 3

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line
	add.l	a2,a4					; next mask line

	dbra	d5,.yloop

	bra		G4BP_DrawSprite_RTS


;-------------------------------------------------------------------------------------------------
;	L--O	Left Chunk Opaque Sprite Render
;-------------------------------------------------------------------------------------------------

G4BP_DrawSprite_L_O:
	suba.l	#8,a1
	move.w	slSpr_Yloop(a7),d5
	subq.w	#1,d5

	move.l	#$FFFF0000,d4			; mask
	lsr.l	d6,d4					; shift mask

.yloop:

	move.w	(a3)+,d0				; read gfx plane 2
	lsr.w	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	lsr.w	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	lsr.w	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	lsr.w	d6,d3					; shift gfx plane 3

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	dbra	d5,.yloop

	bra		G4BP_DrawSprite_RTS


;-------------------------------------------------------------------------------------------------
;	L-R-	Left.Right Chunk Transparent Sprite Render
;-------------------------------------------------------------------------------------------------

G4BP_DrawSprite_LR_T:
	suba.l	#8,a1
	suba.l	#2,a2
	move.w	slSpr_Yloop(a7),d5
	subq.w	#1,d5
.yloop:
	moveq	#0,d0					; gfx plane 0
	moveq	#0,d1					; gfx plane 1
	moveq	#0,d2					; gfx plane 2
	moveq	#0,d3					; gfx plane 3
	moveq	#-1,d4					; mask

	move.w	(a4)+,d4				; read mask
	ror.l	d6,d4					; shift mask

	move.w	(a3)+,d0				; read gfx plane 2
	ror.l	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	ror.l	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	ror.l	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	ror.l	d6,d3					; shift gfx plane 3

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3
	swap	d4						; rem of last mask

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line
	add.l	a2,a4					; next mask line

	dbra	d5,.yloop

	bra		G4BP_DrawSprite_RTS


;-------------------------------------------------------------------------------------------------
;	L-RO	Left.Right Chunk Opaque Sprite Render
;-------------------------------------------------------------------------------------------------

G4BP_DrawSprite_LR_O:
	suba.l	#8,a1
	suba.l	#2,a2
	move.w	slSpr_Yloop(a7),d7
	subq.w	#1,d7
	not.l	d5
	move.l	d5,d4
	swap	d4
.yloop:
	moveq	#0,d0					; gfx plane 0
	moveq	#0,d1					; gfx plane 1
	moveq	#0,d2					; gfx plane 2
	moveq	#0,d3					; gfx plane 3

	move.w	(a3)+,d0				; read gfx plane 2
	ror.l	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	ror.l	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	ror.l	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	ror.l	d6,d3					; shift gfx plane 3

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.w	d5,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d5,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d5,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d5,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	dbra	d7,.yloop

	bra		G4BP_DrawSprite_RTS


;-------------------------------------------------------------------------------------------------
;	LC--	Left.Central Chunk Transparent Sprite Render
;-------------------------------------------------------------------------------------------------

G4BP_DrawSprite_LC_T:
	suba.l	#8,a1
	suba.l	#2,a2

.yloop:

	moveq	#0,d0					; gfx plane 0
	moveq	#0,d1					; gfx plane 1
	moveq	#0,d2					; gfx plane 2
	moveq	#0,d3					; gfx plane 3
	moveq	#-1,d4					; mask

	move.w	(a4)+,d4				; read mask
	ror.l	d6,d4					; shift mask

	move.w	(a3)+,d0				; read gfx plane 2
	ror.l	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	ror.l	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	ror.l	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	ror.l	d6,d3					; shift gfx plane 3

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	move.w	slSpr_Xloop(a7),a6
.xloop:
	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3
	swap	d4						; rem of last mask

	and.l	d5,d0					; clear unwanted plane0 bits
	and.l	d5,d1					; clear unwanted plane1 bits
	and.l	d5,d2					; clear unwanted plane2 bits
	and.l	d5,d3					; clear unwanted plane3 bits
	move.l	d5,d7
	not.l	d7
	or.l	d7,d4					; clear unwanted mask bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	moveq	#-1,d7					; clear high word of tmp
	move.w	(a4)+,d7				; read msk 
	ror.l	d6,d7					; shift msk
	and.l	d7,d4					; combine last and new msk chunks

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	suba.w	#1,a6					; dec mid loop counter
	move.l	a6,d7
	bne		.xloop					; loop

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line
	add.l	a2,a4					; next mask line

	subq.w	#1,slSpr_Yloop(a7)				; dec y
	bne		.yloop

	bra		G4BP_DrawSprite_RTS


;-------------------------------------------------------------------------------------------------
;	LC-O	Left.Central Chunk Opaque Sprite Render
;-------------------------------------------------------------------------------------------------

G4BP_DrawSprite_LC_O:
	suba.l	#8,a1

.yloop:

	moveq	#0,d0					; gfx plane 0
	moveq	#0,d1					; gfx plane 1
	moveq	#0,d2					; gfx plane 2
	moveq	#0,d3					; gfx plane 3
	move.l	#$FFFF0000,d4			; mask

	ror.l	d6,d4					; shift mask

	move.w	(a3)+,d0				; read gfx plane 2
	ror.l	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	ror.l	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	ror.l	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	ror.l	d6,d3					; shift gfx plane 3

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	move.w	slSpr_Xloop(a7),a6
.xloop:
	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3
	swap	d4						; rem of last mask

	and.l	d5,d0					; clear unwanted plane0 bits
	and.l	d5,d1					; clear unwanted plane1 bits
	and.l	d5,d2					; clear unwanted plane2 bits
	and.l	d5,d3					; clear unwanted plane3 bits
	and.l	d5,d4					; clear unwanted mask bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	move.w	d0,(a5)+				; draw plane 0
	move.w	d1,(a5)+				; draw plane 1
	move.w	d2,(a5)+				; draw plane 2
	move.w	d3,(a5)+				; draw plane 3

	suba.w	#1,a6					; dec mid loop counter
	move.l	a6,d7
	bne		.xloop					; loop

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	subq.w	#1,slSpr_Yloop(a7)				; dec y
	bne		.yloop
	bra		G4BP_DrawSprite_RTS


;-------------------------------------------------------------------------------------------------
;	LCR-	Left.Central.Right Chunk Transparent Sprite Render
;-------------------------------------------------------------------------------------------------

G4BP_DrawSprite_LCR_T:
	suba.l	#8,a1
	suba.l	#2,a2

.yloop:

	moveq	#0,d0					; gfx plane 0
	moveq	#0,d1					; gfx plane 1
	moveq	#0,d2					; gfx plane 2
	moveq	#0,d3					; gfx plane 3
	moveq	#-1,d4					; mask

	move.w	(a4)+,d4				; read mask
	ror.l	d6,d4					; shift mask

	move.w	(a3)+,d0				; read gfx plane 2
	ror.l	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	ror.l	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	ror.l	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	ror.l	d6,d3					; shift gfx plane 3

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	move.w	slSpr_Xloop(a7),a6
.xloop:
	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3
	swap	d4						; rem of last mask

	and.l	d5,d0					; clear unwanted plane0 bits
	and.l	d5,d1					; clear unwanted plane1 bits
	and.l	d5,d2					; clear unwanted plane2 bits
	and.l	d5,d3					; clear unwanted plane3 bits
	move.l	d5,d7					; clear unwanted mask bits
	not.l	d7
	or.l	d7,d4

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	moveq	#-1,d7					; clear high word of tmp
	move.w	(a4)+,d7				; read msk 
	ror.l	d6,d7					; shift msk
	and.l	d7,d4					; combine last and new msk chunks

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	suba.w	#1,a6					; dec mid loop counter
	move.l	a6,d7
	bne		.xloop					; loop

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3
	swap	d4						; rem of last mask

	and.l	d5,d0					; clear unwanted plane0 bits
	and.l	d5,d1					; clear unwanted plane1 bits
	and.l	d5,d2					; clear unwanted plane2 bits
	and.l	d5,d3					; clear unwanted plane3 bits
	move.l	d5,d7					; clear unwanted mask bits
	not.l	d7
	or.l	d7,d4

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line
	add.l	a2,a4					; next mask line

	subq.w	#1,slSpr_Yloop(a7)				; dec y
	bne		.yloop

	bra		G4BP_DrawSprite_RTS


;-------------------------------------------------------------------------------------------------
;	LCRO	Left.Central.Right Chunk Opaque Sprite Render
;-------------------------------------------------------------------------------------------------

G4BP_DrawSprite_LCR_O:
	suba.l	#8,a1
	move.l	#$FFFF0000,d4			; mask
	ror.l	d6,d4					; shift mask

.yloop:

	moveq	#0,d0					; gfx plane 0
	moveq	#0,d1					; gfx plane 1
	moveq	#0,d2					; gfx plane 2
	moveq	#0,d3					; gfx plane 3

	move.w	(a3)+,d0				; read gfx plane 2
	ror.l	d6,d0					; shift gfx plane 2
	move.w	(a3)+,d1				; read gfx plane 2
	ror.l	d6,d1					; shift gfx plane 2
	move.w	(a3)+,d2				; read gfx plane 2
	ror.l	d6,d2					; shift gfx plane 2
	move.w	(a3)+,d3				; read gfx plane 3
	ror.l	d6,d3					; shift gfx plane 3

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	move.w	slSpr_Xloop(a7),a6
.xloop:
	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3

	and.l	d5,d0					; clear unwanted plane0 bits
	and.l	d5,d1					; clear unwanted plane1 bits
	and.l	d5,d2					; clear unwanted plane2 bits
	and.l	d5,d3					; clear unwanted plane3 bits

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 0
	ror.l	d6,d7					; shift gfx plane 0
	or.l	d7,d0					; combine last and new plane0 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 1
	ror.l	d6,d7					; shift gfx plane 1
	or.l	d7,d1					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d2					; combine last and new plane1 chunks

	moveq	#0,d7					; clear high word of tmp
	move.w	(a3)+,d7				; read gfx plane 2
	ror.l	d6,d7					; shift gfx plane 2
	or.l	d7,d3					; combine last and new plane1 chunks

	move.w	d0,(a5)+				; draw plane 0
	move.w	d1,(a5)+				; draw plane 1
	move.w	d2,(a5)+				; draw plane 2
	move.w	d3,(a5)+				; draw plane 3

	suba.w	#1,a6					; dec mid loop counter
	move.l	a6,d7
	bne		.xloop					; loop

	swap	d0						; rem of last gfx plane 0
	swap	d1						; rem of last gfx plane 1
	swap	d2						; rem of last gfx plane 2
	swap	d3						; rem of last gfx plane 3
	swap	d4

	and.l	d5,d0					; clear unwanted plane0 bits
	and.l	d5,d1					; clear unwanted plane1 bits
	and.l	d5,d2					; clear unwanted plane2 bits
	and.l	d5,d3					; clear unwanted plane3 bits

	and.w	d4,(a5)					; mask plane 0
	or.w	d0,(a5)+				; draw plane 0
	and.w	d4,(a5)					; mask plane 1
	or.w	d1,(a5)+				; draw plane 1
	and.w	d4,(a5)					; mask plane 2
	or.w	d2,(a5)+				; draw plane 2
	and.w	d4,(a5)					; mask plane 3
	or.w	d3,(a5)+				; draw plane 3

	swap	d4

	add.l	a0,a5					; next screen line
	add.l	a1,a3					; next gfx line

	subq.w	#1,slSpr_Yloop(a7)				; dec y
	bne		.yloop
	bra		G4BP_DrawSprite_RTS




G4BP_DrawSprite_RTS:
	lea		slSpr_sizeof(a7),a7		; fix stack

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
