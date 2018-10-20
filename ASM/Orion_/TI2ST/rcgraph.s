;
; PedroM - Operating System for Ti-89/Ti-92+/V200.
; Copyright (C) 2005-2009 Patrick Pelissier
;
; This program is free software ; you can redistribute it and/or modify it under the
; terms of the GNU General Public License as published by the Free Software Foundation;
; either version 2 of the License, or (at your option) any later version. 
; 
; This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
; See the GNU General Public License for more details. 
; 
; You should have received a copy of the GNU General Public License along with this program;
; if not, write to the 
; Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 


; ***************************************************************
; *								*
; *		Pedrom		/	Graph			*
; *								*
; ***************************************************************

USED_FONT	EQU	0	; Small Font for dialog
KEY_ENTER	EQU	13
SCR_WIDTH	EQU	160
SCR_HEIGHT	EQU	100
ST_Y		EQU	SCR_HEIGHT-7

; ***************************************************************
; 			Set functions
; ***************************************************************

; Reset the normal output of all graph functions.
ReInitGraphSystem:
	bsr.s	PortRestore
;	move.w	#LCD_MEM/8,$600010		; Set $4C00 as VRAM for HW1
;	clr.b	$700017				; Set $4C00 as VRAM for HW2
	move.b	#USED_FONT,CURRENT_FONT		; Set Current Font
	clr.w	CURRENT_ATTR			; Set Current Attr
;	lea	ScrRect(pc),a0			; Set Current Clip area
;	move.l	(a0),ScrRectRam			; ScrRectRam is a RAM copy of ScrRect
;	jsr	SetCurClip_reg			; Set clipping
;	move.w	#$8001,PRINTF_LINE_COUNTER	; Reset printf counter
;	jmp	InitTerminal			; Init stdin/stdout/stderr
	rts

;unsigned char FontSetSys (short Font);
FontSetSys:
	move.b	CURRENT_FONT,d0
	move.b	5(a7),CURRENT_FONT
	rts

;unsigned char FontGetSys(void);
FontGetSys:
	move.b	CURRENT_FONT,d0
	rts
	
; To do: Support GrayScale graphics
;void PortRestore (void);
PortRestore:
	move.l	#LCD_MEM,CURRENT_SCREEN
	move.w	#30,CURRENT_INCY
	move.w	#239,CURRENT_SIZEX
	move.w	#127,CURRENT_SIZEY
	clr.b	CURRENT_GRAPH_UNALIGNED
	rts

;void PortSet (void *vm_addr, short x_max, short y_max); ; SideEffect: Do not destroy a0/a1
PortSet:
	move.l	4(a7),CURRENT_SCREEN	; Current Target for Graph functions
	move.w	10(a7),CURRENT_SIZEY	; Height
	move.w	8(a7),d0	
	move.w	d0,CURRENT_SIZEX	; Width
PortSet_inline:
	lsr.w	#3,d0			;/8
	addq.w	#1,d0			;+1 
	move.w	d0,CURRENT_INCY		; Some programs give a non multiple of 2 arg (ex 1 !)
	or.l	CURRENT_SCREEN,d0	; In this case, and if the screen is non aligned
	andi.w	#1,d0			; Tadam 
	move.b	d0,CURRENT_GRAPH_UNALIGNED	; Set this variable and use slow functions (Byte access)
	rts

;void RestoreScrState (const void *buffer);
RestoreScrState:
	move.l	4(a7),a0
RestoreScrState_reg:
	move.l	(a0)+,CURRENT_SCREEN
	move.b	(a0)+,CURRENT_SIZEX+1
	move.b	(a0)+,CURRENT_SIZEY+1
	move.b	(a0)+,CURRENT_FONT
	addq.l	#1,a0
	move.w	(a0)+,CURRENT_ATTR
	move.w	(a0)+,CURRENT_POINT_X
	move.w	(a0)+,CURRENT_POINT_Y
	move.b	(a0)+,CLIP_MIN_X+1
	move.b	(a0)+,CLIP_MIN_Y+1
	move.b	(a0)+,CLIP_MAX_X+1
	move.b	(a0)+,CLIP_MAX_Y+1
	move.w	CURRENT_SIZEX,d0
	bra.s	PortSet_inline

;void SaveScrState (void *buffer);
SaveScrState:
	move.l	4(a7),a0
SaveScrState_reg:
	move.l	CURRENT_SCREEN,(a0)+
	move.b	CURRENT_SIZEX+1,(a0)+
	move.b	CURRENT_SIZEY+1,(a0)+
	move.b	CURRENT_FONT,(a0)+
	clr.b	(a0)+
	move.w	CURRENT_ATTR,(a0)+
	move.w	CURRENT_POINT_X,(a0)+
	move.w	CURRENT_POINT_Y,(a0)+
	move.b	CLIP_MIN_X+1,(a0)+
	move.b	CLIP_MIN_Y+1,(a0)+
	move.b	CLIP_MAX_X+1,(a0)+
	move.b	CLIP_MAX_Y+1,(a0)+
	rts
		
;short SetCurAttr (short Attr);
SetCurAttr:
	move.w	CURRENT_ATTR,d0
	move.w	4(a7),CURRENT_ATTR
	rts

;void SetCurClip (const SCR_RECT *clip);
SetCurClip:
	move.l	4(a7),a0
SetCurClip_reg:
	pea	(a2)
	lea	CLIP_MIN_X,a1
	lea	CLIP_TEMP_RECT,a2
	clr.w	d0
	moveq	#4-1,d1
.loop:		move.b	(a0)+,d0	; Read Scr Rect 
		move.b	1(a1),(a2)+	; Save Old SCR_RECT clip area to CLIP_TEMP_RECT, so that we can restore  it quite easily
		move.w	d0,(a1)+	; Write it
		dbra	d1,.loop
	move.l	(a7)+,a2
	rts
	
; ***************************************************************
; 			Line functions
; ***************************************************************

;void MoveTo (short x, short y); 
MoveTo:
	move.w	4(a7),CURRENT_POINT_X
	move.w	6(a7),CURRENT_POINT_Y
	rts

;void LineTo (short x, short y);
LineTo:		; To fix use DrawClipLine
	move.w	CURRENT_ATTR,-(a7)
	move.w	CURRENT_POINT_Y,-(a7)
	move.w	CURRENT_POINT_X,-(a7)
	move.w	2+4+6(a7),-(a7)
	move.w	(a7),CURRENT_POINT_Y
	move.w	4+6+2(a7),-(a7)
	move.w	(a7),CURRENT_POINT_X
	bsr.s	DrawLine
	lea	(2+2+2+2+2)(a7),a7
	rts

;void DrawLine (short x0, short y0, short x1, short y1, short Attr);
DrawLine:
	movem.l d3-d7/a2,-(a7)
	move.w	4+6*4+0(a7),d0		; X1
	move.w	4+6*4+2(a7),d1		; Y1
	move.w	4+6*4+4(a7),d2		; X2
	move.w	4+6*4+6(a7),d3		; Y2
	move.l	CURRENT_SCREEN,a0
	move.w	CURRENT_INCY,a2
	; Classement des points
	cmp.w	d0,d2
	bge.s	.no_exg
		exg	d2,d0
		exg	d1,d3
.no_exg:
	; * 30
	move.w	a2,d4
	mulu.w	d1,d4	; d4 = '30' * d1

	; X / 8 
	move.w	d0,d6
	lsr.w	#3,d6		; x/8->x
	add.w	d6,d4		; D4 = 30*y + x /8
	adda.w	d4,a0

	move.w	d0,d6
	not.w	d6
	and.w	#07,d6		;obtient le pixel à changer ; *

	; Calcul de Dx, Dy et Offset
	move.w	d2,d5
	sub.w	d0,d5		; D5 = Dx = x2 - x1 >0
	move.w	a2,d4		; +30
	move.w	d3,d7
	sub.w	d1,d7		; D7 = Dy = y2 - y1
	bcc.s	.no
		neg.w	d4	; -30
		neg.w	d7
.no:	
	move.w	4+6*4+8(a7),d2		; Attr
	beq	DrawLineWhite
	subq.w	#1,d2
	bne	DrawLineXor
	
DrawLineBlack:
	cmp.w	d5,d7		; Cmp Dx et Dy 
	bcc.s	.up
	; Dx > Dy
	move.w	d5,d2		; D2 = Dx
	move.w	d7,d3
	sub.w	d5,d3
	add.w	d3,d3
	add.w	d7,d7
	sub.w	d7,d5
	neg.w	d5
	bpl.s	.loop1b		; 
.loop1a:
	bset.b	d6,(a0)		; *
	add.w	d7,d5
	bpl.s	.mb
.ma:	subq.w	#1,d6	; *
	bge.s	.OK1a
		moveq	#7,d6
		addq.w	#1,a0
.OK1a:	dbra	d2,.loop1a
	bra.s	.end
.loop1b:
	bset.b	d6,(a0)		; *
	adda.w	d4,a0
	add.w	d3,d5
	bmi.s	.ma
.mb:	subq.w	#1,d6	; *
	bge.s	.OK1b
		moveq	#7,d6
		addq.w	#1,a0
.OK1b:	dbra	d2,.loop1b
	bra.s	.end
	; Dx < Dy
.up:	
	move.w	d7,d3
	move.w	d5,d2
	sub.w	d7,d2
	add.w	d2,d2
	add.w	d5,d5
	sub.w	d5,d7
	neg.w	d7
	bpl.s	.loop2b
.loop2a:
	bset.b	d6,(a0)		; *
	add.w	d5,d7
	bpl.s	.m2b
.m2a	adda.w	d4,a0
	dbra	d3,.loop2a
	bra.s	.end
.loop2b:
	bset.b	d6,(a0)		; *
	subq.w	#1,d6		; *
	bge.s	.Ok2b
		moveq	#7,d6
		addq.w	#1,a0
.Ok2b:	add.w	d2,d7
	bmi.s	.m2a
.m2b:	adda.w	d4,a0
	dbra	d3,.loop2b
.end:	movem.l (a7)+,d3-d7/a2
	rts

DrawLineWhite:
	cmp.w	d5,d7		; Cmp Dx et Dy 
	bcc.s	.up
	; Dx > Dy
	move.w	d5,d2		; D2 = Dx
	move.w	d7,d3
	sub.w	d5,d3
	add.w	d3,d3
	add.w	d7,d7
	sub.w	d7,d5
	neg.w	d5
	bpl.s	.loop1b		; 
.loop1a:
	bclr.b	d6,(a0)		; *
	add.w	d7,d5
	bpl.s	.mb
.ma:	subq.w	#1,d6	; *
	bge.s	.OK1a
		moveq	#7,d6
		addq.w	#1,a0
.OK1a:	dbra	d2,.loop1a
	bra.s	.end
.loop1b:
	bclr.b	d6,(a0)		; *
	adda.w	d4,a0
	add.w	d3,d5
	bmi.s	.ma
.mb:	subq.w	#1,d6	; *
	bge.s	.OK1b
		moveq	#7,d6
		addq.w	#1,a0
.OK1b:	dbra	d2,.loop1b
	bra.s	.end
	; Dx < Dy
.up:	
	move.w	d7,d3
	move.w	d5,d2
	sub.w	d7,d2
	add.w	d2,d2
	add.w	d5,d5
	sub.w	d5,d7
	neg.w	d7
	bpl.s	.loop2b
.loop2a:
	bclr.b	d6,(a0)		; *
	add.w	d5,d7
	bpl.s	.m2b
.m2a	adda.w	d4,a0
	dbra	d3,.loop2a
	bra.s	.end
.loop2b:
	bclr.b	d6,(a0)		; *
	subq.w	#1,d6		; *
	bge.s	.Ok2b
		moveq	#7,d6
		addq.w	#1,a0
.Ok2b:	add.w	d2,d7
	bmi.s	.m2a
.m2b:	adda.w	d4,a0
	dbra	d3,.loop2b
.end:	movem.l (a7)+,d3-d7/a2
	rts

DrawLineXor:
	cmp.w	d5,d7		; Cmp Dx et Dy 
	bcc.s	.up

	; Dx > Dy
	move.w	d5,d2		; D2 = Dx
	move.w	d7,d3
	sub.w	d5,d3
	add.w	d3,d3
	add.w	d7,d7
	sub.w	d7,d5
	neg.w	d5
	bpl.s	.loop1b		; 
.loop1a:
	bchg.b	d6,(a0)		; *
	add.w	d7,d5
	bpl.s	.mb
.ma:	subq.w	#1,d6	; *
	bge.s	.OK1a
		moveq	#7,d6
		addq.w	#1,a0
.OK1a:	dbra	d2,.loop1a
	bra.s	.end
.loop1b:
	bchg.b	d6,(a0)		; *
	adda.w	d4,a0
	add.w	d3,d5
	bmi.s	.ma
.mb:	subq.w	#1,d6	; *
	bge.s	.OK1b
		moveq	#7,d6
		addq.w	#1,a0
.OK1b:	dbra	d2,.loop1b
	bra.s	.end

	; Dx < Dy
.up:	
	move.w	d7,d3
	move.w	d5,d2
	sub.w	d7,d2
	add.w	d2,d2
	add.w	d5,d5
	sub.w	d5,d7
	neg.w	d7
	bpl.s	.loop2b
.loop2a:
	bchg.b	d6,(a0)		; *
	add.w	d5,d7
	bpl.s	.m2b
.m2a	adda.w	d4,a0
	dbra	d3,.loop2a
	bra.s	.end
	
.loop2b:
	bchg.b	d6,(a0)		; *
	subq.w	#1,d6		; *
	bge.s	.Ok2b
		moveq	#7,d6
		addq.w	#1,a0
.Ok2b:	add.w	d2,d7
	bmi.s	.m2a
.m2b:	adda.w	d4,a0
	dbra	d3,.loop2b

.end:	movem.l (a7)+,d3-d7/a2
	rts

; ***************************************************************
; 			Misc functions
; ***************************************************************
	
ScreenClear:
	moveq	#0,d2			; D2 = PATTERN
	move.l	CURRENT_SCREEN,a0	; a0 = DEST
	move.w	CURRENT_SIZEY,d0
	addq.w	#1,d0			
	mulu.w	CURRENT_INCY,d0		; d0 = SIZE
	bra	memset_reg_align

;void DrawClipPix (short x, short y); 
DrawClipPix:
	move.w	4(a7),d0
	move.w	6(a7),d1
DrawClipPix_reg:	
	cmp.w	CLIP_MIN_X,d0
	blt.s	.end
	cmp.w	CLIP_MAX_X,d0
	bge.s	.end
	cmp.w	CLIP_MIN_Y,d1
	blt.s	.end
	cmp.w	CLIP_MAX_Y,d1
	bge.s	.end
	bsr.s	_GetScrPtr
	move.w	CURRENT_ATTR,d2
	bra.s	DrawPix_Inline
.end	rts

;void DrawPix (short x, short y, short Attr);
DrawPix:
	move.w	4(a7),d0
	move.w	6(a7),d1
	bsr.s	_GetScrPtr
	move.w	8(a7),d2
DrawPix_Inline:
	beq.s	.revers
	subq.w	#1,d2
	beq.s	.normal
	bchg.b	d1,(a0)
	rts
.normal	bset.b	d1,(a0)
	rts
.revers	bclr.b	d1,(a0)
	rts

; In:
;	d0.w = X
;	d1.w = Y
; Out:
;	a0 -> Screen + 30*Y + X/8
;	d1 = 7-x&7
; Destroy:
;	d0-d2/a0
_GetScrPtr:
	move.l	CURRENT_SCREEN,a0
	move.w	d1,d2
	mulu.w	CURRENT_INCY,d2
	moveq	#7,d1
	eor.w	d1,d0
	and.w	d0,d1
	lsr.w	#3,d0
	add.w	d0,d2
	add.w	d2,a0
	rts
	
;short GetPix (short x, short y);
GetPix:
	move.w	4(a7),d0
	move.w	6(a7),d1
GetPix_reg:
	bsr.s	_GetScrPtr
	btst.b	d1,(a0)
	sne	d0
	ext.w	d0
	rts


; ***************************************************************
; 			String functions
; ***************************************************************

; void DrawClipChar (short x, short y, short c, const SCR_RECT *clip, short Attr);
DrawClipChar:
	move.w	4(a7),d0	; X
	move.w	6(a7),d1	; Y
	move.w	8(a7),d2	; Char
	move.l	10(a7),a0	; Clip Area
	movem.l	d3-d7/a2-a6,-(a7)
	; Get the Width/Height/Ptr/Mask of the char
	move.b	CURRENT_FONT,d5		; 0, 1 or 2
	subq.b	#1,d5
	beq.s	.medium
	blt.s	.small
		moveq	#8,d3		; Large Width
		moveq	#10,d6		; Large Height
		moveq	#-1,d4
		clr.b	d4			; d4.l = $FFFFFF00 = Masque pour Replace
		lea	MediumFont+$E00,a4
		mulu.w	d6,d2
		adda.w	d2,a4		; Character Ptr
		bra.s	.end_char
.small		lea	MediumFont+$800,a4 ; Small Font
		mulu.w	#6,d2		; x6
		adda.w	d2,a4		; Character Ptr
		move.b	(a4)+,d3	; Width
		moveq	#5,d6		; Height
		moveq	#-1,d4		; Start the calcul of the mask
		lsr.l	d3,d4		; Create the '0'
		rol.l	#8,d4		; Mask (it is left aligned)
		bra.s	.end_char
.medium:	moveq	#6,d3		; Medium Width
		moveq	#8,d6		; Medium Height
		move.l	#$FFFFFFC0,d4	; = Masque pour Replace
		lea	MediumFont,a4	; Medium Font
		lsl.w	#3,d2
		adda.w	d2,a4		; Character Ptr
.end_char:	
	; Check Big Clipping
	clr.w	d7
	add.w	d3,d0		; 
	add.w	d6,d1
	move.b	(a0)+,d7
	cmp.w	d7,d0
	ble	.NoDraw
	move.b	(a0)+,d7
	cmp.w	d7,d1
	ble	.NoDraw
	sub.w	d3,d0
	sub.w	d6,d1
	move.b	(a0)+,d7
	cmp.w	d7,d0
	bgt	.NoDraw
	move.b	(a0)+,d7
	cmp.w	d7,d1
	bgt	.NoDraw
	; Something to draw
	subq.l	#4,a0
	; Check Y clipping
	clr.w	d7
	move.b	1(a0),d7
	cmp.w	d7,d1
	bge.s	.NoYTop
		sub.w	d7,d1
		add.w	d1,d6		; Height + (y) (y <0)
		suba.w	d1,a4		; Y first char
		move.w	d7,d1
.NoYTop	move.w	d1,d2
	add.w	d6,d2
	move.b	3(a0),d7
	sub.w	d7,d2
	ble.s	.NoYDn
		sub.w	d2,d6		; Height - (Y+Height-Ydown)
		addq.w	#1,d6
.NoYDn	
	; Check X clipping
	moveq	#-1,d5			; Clipping Mask
	move.w	d0,d2
	add.w	d3,d2			; X +w
	move.w	d2,d7
	addq.w	#8,d7
	andi.w	#$F8,d7	
	move.w	d7,a2
	clr.w	d7
	move.b	(a0),d7
	cmp.w	d7,d0
	bge.s	.NoLf
		move.w	a2,d7		
		sub.b	(a0),d7
		moveq	#1,d5
		lsl.w	d7,d5
		subq.w	#1,d5		; d5 = 2^(((X+w)/8+1)*8-Xclip)-1
.NoLf	clr.w	d7
	move.b	2(a0),d7
	cmp.w	d7,d2
	ble.s	.NoRg
		move.w	a2,d7
		sub.b	2(a0),d7
		move.w	d5,-(a7)
		moveq	#1,d5
		lsl.w	d7,d5
		subq.w	#1,d5
		not.w	d5
		and.w	(a7)+,d5
.NoRg:	add.w	d3,d0			; X+= Len of first char	
	move.w	d0,d7			; Calcul des coordonnées X
	lsr.w	#4,d0			; / 16
	add.w	d0,d0			; *2
	mulu.w	CURRENT_INCY,d1		; 30 *d1
	add.w	d1,d0			; x/16*2 + 30 *y
	move.l	CURRENT_SCREEN,a1
	adda.w	d0,a1			; Ecran positionné
	; Calcul decalage
	moveq	#16-8,d2	; 16 - ((x+size)%16 - (8 - size)
	and.w	#15,d7		; (X+Size)%16
	sub.w	d7,d2
	add.w	d3,d2
	bge.s	.OkDeca		; If (<0)
		add.w	#16,d2	; deca+=16
		addq.w	#2,a1	; Ecran++
.OkDeca:
	; Display the char according to ATTR
	move.w	CURRENT_INCY,a6	; A6 = 30 (Inc Vertical)
	subq.w	#1,d6		; Line -1
	move.w	40+14(a7),d0	; Attr
	cmpi.w	#4,d0
	bhi.s	.NoDraw
	addq.w	#5,d0		; We must use the slow version
	add.w	d0,d0
	move.w	DrawStrAttrTable(Pc,d0.w),d0
	jsr	DrawStrAttrTable(Pc,d0.w)	; Get the draw char function
.NoDraw	movem.l	(a7)+,d3-d7/a2-a6
	rts
	
; void DrawChar(short x, short y, 'short' c, short Attr);
DrawChar:
	move.w	4(a7),d0	; X
	move.w	6(a7),d1	; Y
	move.b	9(a7),DRAW_CHAR	; Char
	clr.b	NULL_CHAR
	move.w	10(a7),-(a7)	; Attr
	pea	DRAW_CHAR
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	bsr.s	DrawStr
	lea	10(a7),a7
	rts

; Contrary to Tios, DrawStr returns a char* (The first non-printed char).
; Usefull if you use DrawStrMax !
; Since you can easily displayed a long String:
;	while (*str)
;		str = DrawStrMax(x, y, str, Attr, Xmax), y+=8;

;char *DrawStrMax(short x, short y, const char *str, short Attr, short Xmax);
DrawStrMax:
	move.w	4(a7),d0
	move.w	6(a7),d1
	move.l	8(a7),a0
	move.w	12(a7),d2
	movem.l	d3-d7/a2-a6,-(a7)
	
	move.w	(14+10*4)(a7),d7		; X-max
	bra.s	DrawStr_Entry
	
DrawStrAttrTable:
	dc.w	_put_char_off-DrawStrAttrTable
	dc.w	_put_char_or-DrawStrAttrTable
	dc.w	_put_char_xor-DrawStrAttrTable
	dc.w	_put_char_and-DrawStrAttrTable
	dc.w	_put_char_replace-DrawStrAttrTable

	dc.w	_put_char_off_slow-DrawStrAttrTable
	dc.w	_put_char_or_slow-DrawStrAttrTable
	dc.w	_put_char_xor_slow-DrawStrAttrTable
	dc.w	_put_char_and_slow-DrawStrAttrTable
	dc.w	_put_char_replace_slow-DrawStrAttrTable
	
; Tigcc Fast Draw Hack Support
	dc.l	MediumFont+$800
	dc.l	MediumFont
	dc.l	MediumFont+$E00
	dc.l	'Pedr'

;char *DrawStr (short x, short y, const char *str, short Attr); 
DrawStr:
	move.w	4(a7),d0
	move.w	6(a7),d1
	move.l	8(a7),a0
	move.w	12(a7),d2
	movem.l	d3-d7/a2-a6,-(a7)
	
	move.w	#240,d7		; X-max = 240
DrawStr_Entry:
	cmpi.w	#4,d2
	bhi	.END
	
	tst.b	CURRENT_GRAPH_UNALIGNED	; Can we use fast version ?
	beq.s	.Yes
		addq.w	#5,d2		; No, we must use the slow version
.Yes	add.w	d2,d2
	move.w	DrawStrAttrTable(Pc,d2.w),d2
	lea	DrawStrAttrTable(Pc,d2.w),a5	; Get the draw char function
	
	moveq	#-1,d5			; Clipping Mask (Not used)

	move.w	CURRENT_INCY,a6		; A6 = 30 (Inc Vertical)
	mulu.w	CURRENT_INCY,d1		; Calcul des coordonnées Y = OK
	
	; Get the len of the first char
	moveq	#4,d3			; Small Font
	move.b	CURRENT_FONT,d2		; 0, 1 or 2
	add.b	d2,d3			; 4 + 1/2
	add.b	d2,d3			; 4 + 2/4 = 6 (Medium Font) or 8 (Large Font)
	subq.b	#1,d2
	bge.s	.end_char
		lea	MediumFont+$800,a1 ; Small Font
		clr.w	d2
		move.b	(a0),d2		; Read Char
		mulu.w	#6,d2		; x6
		move.b	0(a1,d2.w),d3
.end_char:	
	sub.w	d0,d7			; Xmax - X = DeltaX
	add.w	d3,d0			; X+= Len of first char	

	move.w	d0,d4			; Calcul des coordonnées X
	lsr.w	#4,d0			; / 16
	add.w	d0,d0			; *2
	add.w	d1,d0
	move.l	CURRENT_SCREEN,a1
	adda.w	d0,a1			; Ecran positionné

	; Calcul decalage (J'en ai bave pour trouver le bon calcul a faire... Pas si evident)
	moveq	#16-8,d2	; 16 - ((x+size)%16 - (8 - size)
	and.w	#15,d4		; (X+Size)%16
	sub.w	d4,d2
	add.w	d3,d2
	bge.s	.OkDeca		; If (<0)
		add.w	#16,d2	; deca+=16
		addq.w	#2,a1	; Ecran++
.OkDeca:

	; Selon la fonte courante
	move.b	CURRENT_FONT,d3
	subq.b	#1,d3
	blt.s	.small
	beq.s	.medium

	; Huge Font & Loop
	lea	MediumFont+$E00,a3
	moveq	#-1,d4
	clr.b	d4			; d4.l = $FFFFFF00 = Masque pour Replace
.LOOP_H
		clr.w	d0
		move.b	(a0)+,d0		; Test de présence d'un indicateur
		beq.s	.END			; Check end of Ptr
		cmpi.b	#KEY_ENTER,d0		; IF LINE_RETURN
		beq.s	.END			; End of line (Usefull for DrawText function !)
		subq.w	#8,d7			; Gestion X-max
		blt.s	.END			; If (X < 0) quit
		mulu.w	#10,d0			; x10
		lea	0(a3,d0.w),a4		; A4 = Pointeur sur fonte
		moveq	#9,d6			; Height = 10
		jsr	(a5)			; Print Char
		subq.w	#8,d2
		bge.s	.LOOP_H
			and.w	#15,d2
			addq.w	#2,a1
			bra.s	.LOOP_H
.END	subq.l	#1,a0			; Return the last ptr to the first non-printed char
	movem.l	(a7)+,d3-d7/a2-a6
	moveq	#0,d1			; Some Buggy asm programs need it ! <JezzBall>
	moveq	#0,d0			; Some Buggy asm programs need it ! <MegaCar>
	rts


.medium	; Normal Font
	lea	MediumFont,a3
	move.l	#$FFFFFF03,d4		; = Masque pour Replace
.LOOP_N
		clr.w	d0
		move.b	(a0)+,d0		; Test end of string
		beq.s	.END
		cmpi.b	#KEY_ENTER,d0		; IF LINE_RETURN
		beq.s	.END			; End of line (Usefull for DrawText function !)
		subq.w	#6,d7			; Check X max
		blt.s	.END			; If (X <0) quit
		lsl.w	#3,d0			; x8
		lea	0(a3,d0.w),a4		; A4 = Pointeur sur fonte
		moveq	#7,d6			; Height = 8
		jsr	(a5)			; Print Char
		subq.w	#6,d2
		bge.s	.LOOP_N
			and.w	#15,d2
			addq.w	#2,a1
			bra.s	.LOOP_N
	
.small	; Small Font
	lea	MediumFont+$800,a3
.LOOP_S
	clr.w	d0
	move.b	(a0)+,d0		; Test de présence d'un indicateur
	beq.s	.END
	cmpi.b	#KEY_ENTER,d0
	beq.s	.END
	mulu.w	#6,d0			; x6
	lea	0(a3,d0.w),a4		; A4 = Pointeur sur fonte
	move.b	(a4)+,d3		; Width
	sub.w	d3,d7			; Gestion Xmax
	blt.s	.END			; If (X<0) quit.
	moveq	#-1,d4			; Start the calcul of the mask
	lsr.l	d3,d4			; Create the '0'
	rol.l	#8,d4			; Mask (it is left aligned)
	moveq	#4,d6			; Height = 5
	jsr	(a5)			; Print Char
	sub.b	d3,d2
	bge.s	.LOOP_S
		and.w	#15,d2
		addq.w	#2,a1
		bra.s	.LOOP_S
	
; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_and:
	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	.word
		subq.w	#2,a2
.put:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.l	d2,d0
			not.l	d0
			and.l	d0,(a2)
			adda.w	a6,a2
			dbra	d6,.put
		rts
.word:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.w	d2,d0
			not.w	d0
			and.w	d0,(a2)
			adda.w	a6,a2
			dbra	d6,.word
		rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_or:
	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	.word
		subq.w	#2,a2
.put:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.l	d2,d0
			or.l	d0,(a2)
			adda.w	a6,a2
			dbra	d6,.put
		rts
.word:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.w	d2,d0
			or.w	d0,(a2)
			adda.w	a6,a2
			dbra	d6,.word
		rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_xor:
	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	.word
		subq.w	#2,a2
.put:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.l	d2,d0
			eor.l	d0,(a2)
			adda.w	a6,a2
			dbra	d6,.put
		rts
.word:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.w	d2,d0
			eor.w	d0,(a2)
			adda.w	a6,a2
			dbra	d6,.word
		rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6/d1
_put_char_replace:
	move.l	d4,d1
	rol.l	d2,d1		; d1.l = Masque

	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	.word
		subq.w	#2,a2
.put:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.l	d2,d0
			and.l	d1,(a2)
			or.l	d0,(a2)
			adda.w	a6,a2
			dbra	d6,.put
		rts
.word:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.w	d2,d0
			and.w	d1,(a2)
			or.w	d0,(a2)
			adda.w	a6,a2
			dbra	d6,.word
		rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_off:
	move.l	d4,d1
	rol.l	d2,d1		; d1.l = Masque
	not.l	d1

	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	.word
		subq.w	#2,a2
.put:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.l	d2,d0
			not.l	d0
			or.l	d1,(a2)
			and.l	d0,(a2)
			adda.w	a6,a2
			dbra	d6,.put
		rts
.word:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.w	d2,d0
			not.w	d0
			or.w	d1,(a2)
			and.w	d0,(a2)
			adda.w	a6,a2
			dbra	d6,.word
		rts
	

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_and_slow:
	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	.word
		subq.l	#1,a2
		subq.w	#8,d2
.word		moveq	#0,d0
		move.b	(a4)+,d0
		lsl.w	d2,d0
		and.w	d5,d0
		not.w	d0
		and.b	d0,1(a2)
		lsr.w	#8,d0
		and.b	d0,(a2)
		adda.w	a6,a2
		dbra	d6,.word
	rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_or_slow:
	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	.word
		subq.l	#1,a2
		subq.w	#8,d2
.word:		moveq	#0,d0
		move.b	(a4)+,d0
		lsl.w	d2,d0
		and.w	d5,d0
		or.b	d0,1(a2)
		lsr.w	#8,d0
		or.b	d0,(a2)
		adda.w	a6,a2
		dbra	d6,.word
	rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_xor_slow:
	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	.word
		subq.l	#1,a2
		subq.w	#8,d2
.word:		moveq	#0,d0
		move.b	(a4)+,d0
		lsl.w	d2,d0
		and.w	d5,d0
		eor.b	d0,1(a2)
		lsr.w	#8,d0
		eor.b	d0,(a2)
		adda.w	a6,a2
		dbra	d6,.word
	rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6/d1
_put_char_replace_slow:
	move.l	d4,d1
	rol.l	d2,d1		; d1.l = Masque

	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	.start
		subq.l	#1,a2
		subq.w	#8,d2
		ror.l	#8,d1
.start	not.w	d5
	or.w	d5,d1
	not.w	d5
.word:		moveq	#0,d0
		move.b	(a4)+,d0
		lsl.w	d2,d0
		and.w	d5,d0
		ror.w	#8,d1
		and.b	d1,(a2)+
		ror.w	#8,d1
		and.b	d1,(a2)
		or.b	d0,(a2)
		lsr.w	#8,d0
		or.b	d0,-(a2)
		adda.w	a6,a2
		dbra	d6,.word
	rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_off_slow:
	move.l	d4,d1
	rol.l	d2,d1		; d1.l = Masque
	not.l	d1

	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	.start
		subq.l	#1,a2
		subq.w	#8,d2
		ror.l	#8,d1
.start	and.w	d5,d1
.word:		moveq	#0,d0
		move.b	(a4)+,d0
		lsl.w	d2,d0
		and.w	d5,d0
		not.w	d0
		ror.w	#8,d1
		or.b	d1,(a2)+
		ror.w	#8,d1
		or.b	d1,(a2)
		and.b	d0,(a2)
		lsr.w	#8,d0
		and.b	d0,-(a2)
		adda.w	a6,a2
		dbra	d6,.word
	rts




;short FontCharWidth (short c);
FontCharWidth:
	moveq	#4,d0			; Small
	move.b	CURRENT_FONT,d1
	add.b	d1,d0
	add.b	d1,d0			; d0 = 4 (Small), 6 (Medium), 8 (Large
	subq.b	#1,d1
	bge.s	.end
		lea	MediumFont+$800,a1
		clr.w	d1
		move.b	5(a7),d1		; Read Char
		mulu.w	#6,d1			; x6
		move.b	0(a1,d1.w),d0		;  d0.ub is cleared
.end:	rts

;short DrawStrWidth (const char *str, short Font);
DrawStrWidth:
	move.l	4(a7),a0	; Str
	move.w	8(a7),d1	; Font

DrawStrWidth_reg:	
	lea	MediumFont+$800,a1
	moveq	#6,d2		; Medium
	moveq	#0,d0

	; Select Font
	subq.b	#1,d1
	blt.s	.final_small
	beq.s	.final_calc

	; Large / Medium
	moveq	#8,d2		; Large
	bra.s	.final_calc
.loop_calc	add.w	d2,d0
.final_calc	tst.b	(a0)+
		bne.s	.loop_calc
	rts
	; Small
.loop_small	mulu.w	#6,d2
		add.b	0(a1,d2.w),d0		; Ca peut pas depasser 240 !
.final_small	clr.w	d2
		move.b	(a0)+,d2
		bne.s	.loop_small
	rts

; In :
;	a0 -> Str (in CURRENT FONT)
StrWidth:
	movem.l	d1-d2/a0-a1,-(a7)
	move.b	CURRENT_FONT,d1
	bsr.s	DrawStrWidth_reg
	movem.l	(a7)+,d1-d2/a0-a1
	rts
	

	
ScrRect:	dc.b	0,0,SCR_WIDTH-1,ST_Y-1			; Working screen
STRect:		dc.b	0,ST_Y+1,SCR_WIDTH-1,SCR_HEIGHT-1	; ST screen
FullRect:	dc.b	0,0,SCR_WIDTH-1,SCR_HEIGHT-1		; Full Screen
MenuRect:	dc.b	0,0,SCR_WIDTH-1,18			; Menu Screen

	even

MediumFont	incbin	"Fontes.bin"

	even
