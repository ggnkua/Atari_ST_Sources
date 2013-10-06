**************************************************************************************
*	GRF_TC_S.S
*
*	True Colour Rendering Functions
*
*	[c] 2002 Reservoir Gods
**************************************************************************************



**************************************************************************************
;	EXPORTS / IMPORTS
**************************************************************************************

	export	Graphic_TC_Blit
	export	Graphic_TC_ClearScreen
	export	Graphic_TC_CopyScreen
	export	Graphic_TC_DrawBox 
	export	Graphic_TC_DrawLine 
	export	Graphic_TC_DrawPixel 
	export	Graphic_TC_DrawSprite 
	export	Graphic_TC_DrawTri  
	export	Graphic_TC_DrawQuad 

	export	Graphic_TC_Blit_Clip
	export	Graphic_TC_ClearScreen_Clip
	export	Graphic_TC_CopyScreen_Clip
	export	Graphic_TC_DrawBox_Clip
	export	Graphic_TC_DrawLine_Clip
	export	Graphic_TC_DrawPixel_Clip
	export	Graphic_TC_DrawSprite_Clip
	export	Graphic_TC_DrawTri_Clip
	export	Graphic_TC_DrawQuad_Clip

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

Graphic_TC_Blit_Clip:
	movem.l	d3-d7/a2-a6,-(a7)				; save registers

	move.l	11*4(a7),a2
	move.l	12*4(a7),a3

	move.w	sGraphicRect_X(a2),d0			; blit x
	move.w	sGraphicRect_Y(a2),d1			; blit y
	move.w	sGraphicRect_Width(a2),d2		; blit width
	move.w	sGraphicRect_Height(a2),d3		; blit height

	move.w	sGraphicPos_X(a1),d4			; X
	move.w	sGraphicPos_Y(a1),d5			; Y

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


	bra		Graphic_TC_Blit_Go				; Blit it	

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

Graphic_TC_Blit:
	movem.l	d3-d7/a2-a6,-(a7)

	move.l	11*4(a7),a2
	move.l	12*4(a7),a3


	move.w	sGraphicRect_X(a2),d0
	move.w	sGraphicRect_Y(a2),d1
	move.w	sGraphicRect_Width(a2),d2
	move.w	sGraphicRect_Height(a2),d3

	move.w	sGraphicPos_X(a1),d4		; X
	move.w	sGraphicPos_Y(a1),d5		; Y

Graphic_TC_Blit_Go:

	move.l	sGraphicCanvas_pVRAM(a0),a1			; pDst
	add.w	d5,d5								; y*2
	add.w	d5,d5								; y*4
	add.l	#sGraphicCanvas_LineOffsets,d5
	add.l	(a0,d5.w),a1						; Dest Y offset
	add.w	d4,d4
	add.w	d4,a1								; get to x
	move.l	sGraphicCanvas_LineOffsets+4(a0),d4	; DST line offset
	ext.l	d2
	sub.l	d2,d4
	sub.l	d2,d4								; next line offset

	move.l	sGraphicCanvas_pVRAM(a3),a0			; pSrc
	add.w	d1,d1								; y*2
	add.w	d1,d1								; y*4
	add.l	#sGraphicCanvas_LineOffsets,d1
	add.l	(a3,d1.w),a0						; Dest Y offset
	add.w	d0,d0
	add.w	d0,a0
	move.l	sGraphicCanvas_LineOffsets+4(a3),d5	; SRC line offset
	sub.l	d2,d5
	sub.l	d2,d5
	
	subq.w	#1,d2
	bra.s	.first
.loopY:
	move.w	d2,d0
.loopX:
	move.w	(a0)+,(a1)+
	dbra	d0,.loopX
	add.l	d4,a1
	add.l	d5,a0
.first:
	dbra	d3,.loopY


GTC_Blit_RTS:
	movem.l	(a7)+,d3-d7/a2-a6
	rts



	

*------------------------------------------------------------------------------------*
* FUNCTION: void (*	ClearScreen )( const struct sGraphicCanvas * apCanvas );
* ACTION:   clears a 320x200 screen
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_TC_ClearScreen:
	movem.l	d3-d7/a2-a6,-(a7)							; save regs

	cmp.w	#320,sGraphicCanvas_Width(a0)
	bne		Graphic_TC_ClearScreen_Gen
	cmp.w	#240,sGraphicCanvas_Height(a0)
	bne		Graphic_TC_ClearScreen_Gen

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

	adda.l	#153600,a0									; get to end of screen

	moveq	#183,d7										; 38 loops

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
	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes

	movem.l	d0-d6/a1-a6,-(a0)							; clear 52 bytes

	movem.l	d0-d6/a1-a4,-(a0)							; clear 44 bytes

	movem.l	(a7)+,d3-d7/a2-a6
	rts


Graphic_TC_ClearScreen_Gen:

	move.l	sGraphicCanvas_LineOffsets+4(a0),d0			; line width
	move.w	sGraphicCanvas_Height(a0),d2				; height
	subq.w	#1,d0										; hwudth-1
	subq.w	#1,d2										; height-1

	moveq	#0,d3										; clear value

	move.l	sGraphicCanvas_pVRAM(a0),a0					; pScreen
.clrY:
	move.w	d0,d1										; X counter
.clrX:
	move.w	d3,(a0)+									; Clear Pixel
	dbra	d1,.clrX									; Loop For All X
	dbra	d2,.clrY									; Loop For All Y

	movem.l	(a7)+,d3-d7/a2-a6
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (*	CopyScreen )(  const struct sGraphicCanvas * apCanvas, void * apSrc, void * apDst );
* ACTION:   copies a 320x200 screen
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_TC_CopyScreen:
	movem.l	d3-d7/a2-a6,-(a7)							; save regs

	cmp.w	#320,sGraphicCanvas_Width(a0)
	bne		Graphic_TC_CopyScreen_Gen
	cmp.w	#240,sGraphicCanvas_Height(a0)
	bne		Graphic_TC_CopyScreen_Gen

	move.l	sGraphicCanvas_pVRAM(a0),a0					; dst

	move.w	#199,d7										; 41 loops

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

	movem.l	(a7)+,d3-d7/a2-a6							; restore registers
	rts


Graphic_TC_CopyScreen_Gen:

	move.w	sGraphicCanvas_LineOffsets+4(a0),d0			; line width
	move.w	sGraphicCanvas_Height(a0),d2				; height
	move.l	sGraphicCanvas_pVRAM(a0),a0					; dst
	subq.w	#1,d0										; width-1
	subq.w	#1,d2										; height-1


.cpyY:
	move.w	d0,d1										; X counter
.cpyX:
	move.w	(a1)+,(a0)+									; Copy Pixel
	dbra	d1,.cpyX									; Loop For All X
	dbra	d2,.cpyY									; Loop For All Y

	movem.l	(a7)+,d3-d7/a2-a6							; restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (* DrawBox )(      struct sGraphicCanvas * apCanvas,  sGraphicRect * apCoords,  S16 aColour );
* ACTION:   draws a box
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_TC_DrawBox_Clip:
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

	bra		Graphic_TC_DrawBox_Go				; Render box

.clip:
	movem.l	(a7)+,d3-d7/a2-a6					; restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (* DrawBox )(      struct sGraphicCanvas * apCanvas,  sGraphicRect * apCoords,  S16 aColour );
* ACTION:   draws a box
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_TC_DrawBox:
	movem.l	d3-d7/a2-a6,-(a7)					; save regs

	move.w	sGraphicRect_X(a1),d1				; Pixel X
	move.w	sGraphicRect_Y(a1),d2				; Pixel Y
	move.w	sGraphicRect_Width(a1),d3			; Width
	move.w	sGraphicRect_Height(a1),d4			; Height

Graphic_TC_DrawBox_Go:


	move.l	sGraphicCanvas_pVRAM(a0),a1			; pDst
	add.w	d2,d2								; y*2
	add.w	d2,d2								; y*4
	add.l	#sGraphicCanvas_LineOffsets,d2
	add.l	(a0,d2.w),a1						; Dest Y offset

	add.w	d1,d1
	add.w	d1,a1								; get to x
	move.l	sGraphicCanvas_LineOffsets+4(a0),d1	; DST line offset
	ext.l	d3
	sub.l	d3,d1
	sub.l	d3,d1								; next line offset

	subq.w	#1,d3
.loopY:
	move.w	d3,d2
.loopX:
	move.w	d0,(a1)+
	dbra	d2,.loopX
	add.l	d1,a1
.first:
	dbra	d4,.loopY


	movem.l	(a7)+,d3-d7/a2-a6					; restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (* DrawPixel )(   const struct sGraphicCanvas * apCanvas, const sGraphicPos * apCoords,  const S16 aColour )
* ACTION:   copies a 320x200 screen
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_TC_DrawPixel_Clip:

	move.w	sGraphicPos_X(a1),d1				; Pixel X
	move.w	sGraphicPos_Y(a1),d2				; Pixel Y

	cmp.w	sGraphicCanvas_Width(a0),d1			; Canvas Width
	bhs.s	.clip								; Clip X
	cmp.w	sGraphicCanvas_Height(a0),d2		; Canvas Height
	bhs.s	.clip								; Clip Y
	
	bra		Graphic_TC_DrawPixel_Go			; Draw Pixel

.clip:
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (* DrawPixel )(   const struct sGraphicCanvas * apCanvas, const sGraphicPos * apCoords,  const S16 aColour )
* ACTION:   copies a 320x200 screen
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_TC_DrawPixel:

	move.w	sGraphicPos_X(a1),d1				; Pixel X
	move.w	sGraphicPos_Y(a1),d2				; Pixel Y

Graphic_TC_DrawPixel_Go:

	move.l	sGraphicCanvas_pVRAM(a0),a1			; pDst
	add.w	d2,d2								; y*2
	add.w	d2,d2								; y*4
	add.l	#sGraphicCanvas_LineOffsets,d2
	add.l	(a0,d2.w),a1						; Dest Y offset
	add.w	d1,d1
	add.w	d1,a1								; get to x

	move.w	d0,(a1)

	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (* DrawSprite )(  const struct sGraphicCanvas * apCanvas, const sGraphicPos * apCoords,  const void * apSprite );
* ACTION:   copies a 320x200 screen
* CREATION: 01.02.02 PNK
*------------------------------------------------------------------------------------*

Graphic_TC_DrawSprite_Clip:
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

	bra		Graphic_TC_DrawSprite_Go

.clip:

	movem.l	(a7)+,d3-d7/a2-a6
	rts


*------------------------------------------------------------------------------------*
* FUNCTION: void (* DrawSprite )(  const struct sGraphicCanvas * apCanvas, const sGraphicPos * apCoords,  const void * apSprite );
* ACTION:   copies a 320x200 screen
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

Graphic_TC_DrawSprite:
	movem.l	d3-d7/a2-a6,-(a7)

	move.l	11*4(a7),a2
	move.w	sGraphicPos_X(a1),d0
	move.w	sGraphicPos_Y(a1),d1
	move.w	sGraphicSprite_Width(a2),d2
	move.w	sGraphicSprite_Height(a2),d3
	move.l	sGraphicSprite_pGfx(a2),a3
	move.l	sGraphicSprite_pMask(a2),a4

Graphic_TC_DrawSprite_Go:
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
	lea		gGraphic_TC_LongMasks,a6
	move.l	(a6,d5.w),d5						; mask

	add.w	d4,d4
	add.w	d4,d4
	jmp		gGTC_DrawSprite_Class(pc,d4.w)





GTC_DrawSprite_RTS:
	lea		slSpr_sizeof(a7),a7		; fix stack

	movem.l	(a7)+,d3-d7/a2-a6
	rts


**************************************************************************************
	DATA
**************************************************************************************

gGraphic_TC_LeftMasks:
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

gGraphic_TC_DoubleLeftMasks:
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

gGraphic_TC_RightMasks:
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

gGraphic_TC_DoubleRightMasks:
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

gGraphic_TC_LongMasks:
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


gGraphic_TC_Points:
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

Graphic_TC_ColourChunks:
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
