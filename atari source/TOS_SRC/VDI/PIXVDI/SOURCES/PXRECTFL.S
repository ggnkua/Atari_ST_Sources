******************************** routines.s ***********************************
*
* $Revision: 3.3 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/mouse.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/07/30 12:18:47 $     $Locker:  $
* =============================================================================
*
* $Log:	mouse.s,v $
*******************************************************************************

.include	"lineaequ.s"

	.globl	PX_RECTFILL

*******************************************************************************
*******************************************************************************
**									     **
**	_RECTFILL							     **
**									     **
**	This routine fills a rectangular area of the screen with a	     **
**	pattern.							     **
**									     **
**	input:	_X1	  = X upper left corner				     **
**		_Y1	  = Y upper left corner				     **
**		_X2	  = X lower right corner			     **
**		_Y2	  = Y lower right corner			     **
**		_CLIP	  = clipping flag (0 => no clipping)		     **
**		_XMN_CLIP = X clipping minimum				     **
**		_XMX_CLIP = X clipping maximum				     **
**		_YMN_CLIP = Y clipping minimum				     **
**		_YMX_CLIP = Y clipping maximum				     **
**	        _WRT_MODE = writing mode (0-3)				     **
**		V_RECT    = vector to rectangle filler			     **
**									     **
**									     **
**									     **
**	Notes:								     **
**									     **
**	 _X1,_Y1,_X2,_Y2 are contiguous words				     **
**	 _CLIP,_XMN_CLIP,_YMN_CLIP,_XMX_CLIP,_YMX_CLIP are contiguous words  **
**									     **
*******************************************************************************
*******************************************************************************


rf_null:

	movem.w	d4-d7,(a0)		; the old routine saved clipped values
	rts


PX_RECTFILL:

	move.l  _lineAVar,a4		; a4 -> linea var struct
	lea	_X1(a4),a0		; a0 -> rectangle endpoints array
	movem.w	(a0),d4-d7		; d4<-X1   d5<-Y1   d6<-X2   d7<-Y2

	lea	_CLIP(a4),a1		; a1 -> clipping flag
	tst.w	(a1)+			; a1 -> 1st entry in clipping array
	beq	rf_noclip		; if no clipping, don't dawdle here.

	;
	;   Clipping is in effect
	;
	movem.w	(a1),d0-d3		; d0<-Xmin d1<-Ymin d2<-Xmax d3<-Ymax

	cmp.w	d0,d4			; X1 < clipping Xmin ?
	bge	rf_xmax			; no  => X1 is in bounds
	cmp.w	d0,d6			; X2 < clipping Xmin ?
	blt	rf_null			; yes => null rectangle

	move.w	d0,d4			; d4 <- clipped X1

rf_xmax:

	cmp.w	d2,d6			; X2 > clipping Xmax ?
	ble	rf_yclip		; no  => X2 is in bounds
	cmp.w	d2,d4			; X1 > clipping Xmax ?
	bgt	rf_null			; yes => null rectangle

	move.w	d2,d6			; d6 <- clipped X2

rf_yclip:

	cmp.w	d1,d5			; Y1 < clipping Ymin ?
	bge	rf_ymax			; no  => Y1 is in bounds
	cmp.w	d1,d7			; Y2 < clipping Ymin ?
	blt	rf_null			; yes => null rectangle 

	move.w	d1,d5			; d5 <- clipped Y1

rf_ymax:

	cmp.w	d3,d7			; Y2 > clipping Ymax ?
	ble	rf_rsave		; no  => Y2 is in bounds
	cmp.w	d3,d5			; Y1 > clipping Ymax ?
	bgt	rf_null			; yes => null rectangle 

	move.w	d3,d7			; d7 <- clipped Y2

	;
	; To maintain compatibility with previous versions of
	; this routine, the clipped values must be saved to their original
	; memory locations.
	;

rf_rsave:

	movem.w	d4-d7,(a0)		; save clipped values: X1 Y1 X2 Y2

rf_noclip:

*
* in:	d4	X1
*	d5	Y1
*	d6	X2
*	d7	Y2
*
*	a4	pointer to LineA variables
*

rect:	movem.w	d4-d7,-(sp)		; save registers
	jsr	px_fline		; draw a horisontal line
	movem.w	(sp)+,d4-d7		; restore registers
	addq.w	#1,d5			; Y1 = Y1 + 1
	cmp.w	d5,d7			; see if Y1 > Y2
	bge	rect			; loop back if not
	rts
