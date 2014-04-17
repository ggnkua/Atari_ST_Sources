***********************************  txtblt.s  ********************************
*
* $Revision: 3.2 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/textblt.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/02/12 17:03:43 $     $Locker:  $
* =============================================================================
*
* $Log:	textblt.s,v $
* Revision 3.2  91/02/12  17:03:43  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.1  91/01/28  18:24:01  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.0  91/01/03  15:19:45  lozben
* New generation VDI
* 
* Revision 2.3  90/03/09  12:48:01  lozben
* Made _scrtsiz 666 word to accomodate the 16x32 system font.
* 
* Revision 2.2  89/04/14  15:37:19  lozben
* Moved hb_text() into another file. The idea is to have all
* the hard blit code in independent files.
* 
* Revision 2.1  89/02/21  17:28:44  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************

.include	"lineaequ.s"


	globl	_scrtsiz

_scrtsiz:	.dc.w	666	; WUT THE FUT ??$*&@!??

*  entry point for textblt & scaling routine
*
	.globl	_TEXT_BL
	.globl	_ACT_SIZ
	.globl	_CLC_DDA

	.text

*******************************************************************************
*
*  calculate DDA
*
*  entry:
*     4(sp) = actual size
*     6(sp) = requested size
*  exit:
*     d0    = DDA_INC
*
*******************************************************************************

_CLC_DDA:
	move.l  _lineAVar,a0		; a0 -> linea var struct
	move.w	6(sp),d0		;d0 = requested size (dx)
	move.w	4(sp),d1		;d1 = actual size    (bx)
	cmp.w	d1,d0			;if actual =< requested
	ble	clc_smal		;  then scale down

	move.w	#1,_T_SCLSTS(a0)	;set enlarge indicator
	sub.w	d1,d0
	cmp.w	d1,d0			;larger than 2x?
	blt	smal_ok			;br if not
clc_big:
	moveq	#-1,d0			;put $FFFF in d0 (max value, 2x)
	rts

clc_smal:
	clr.w	_T_SCLSTS(a0)		;clear enlarge indicator (scale down)
	tst.w	d0			;check requested size
	bne	smal_ok			;br if non-zero
	moveq	#1,d0			;if 0 then make it 1 (minimum value)
smal_ok:
	swap	d0			;requested size to high word
	clr.w	d0			;clear lo word
	divu	d1,d0			;d0 = requested/actual
	rts


*******************************************************************************
*
*  Actual sizer routine
*
*  entry:
*	_DDA_INC  = dda increment value
*	_T_SCLSTS = scaling up or down flag (0 if down, 1 if up)
*
*    4(sp) = pixel size to be scaled
*
*  exit:
*    d0    = actual size after scaling
*	destroyed: d0.w,d1.w 
*
*******************************************************************************

_ACT_SIZ:

	move.l  _lineAVar,a0		; a0 -> linea var struct
	move.w	4(sp),d1		;get last stacked word to d1 (cx)
	movem.l	d2-d3, -(sp)		; save c regs
	move.w	#32767,d2		;d2 = accumulator = 1/2      (bx)
	move.w	_DDA_INC(a0),d3		;d3 = dda_inc		     (dx)
	cmp.w	#$FFFF,d3
	beq	siz_doub

	moveq	#0,d0			;d0 = new count
	subq.w	#1,d1			;zero adjust DELY count
	bmi	siz_0			;if it was 0, just exit

	btst.b	#0,_T_SCLSTS+1(a0)	;check for shrink
	beq	sz_sm_lp		;br if so

sz_lp:	add.w	d3,d2			;else, enlarge
	bcc	siz_tim1

	addq.w	#1,d0

siz_tim1:

	addq.w	#1,d0
	dbra	d1,sz_lp

siz_0:	bra	act_exit

siz_doub:

	move.w	d1,d0
	add.w	d0,d0			; d0 = size * 2
	bra	act_exit

sz_sm_lp:

	add.w	d3,d2
	bcc	sz_sm_1

	addq.w	#1,d0

sz_sm_1:

	dbra	d1,sz_sm_lp

	tst.w	d0			;if d0 = 0, then make = 1
	bne	sz_sm_2

	addq.w	#1,d0

act_exit:
sz_sm_2:

	movem.l	(sp)+,d2-d3
	rts


*****************************************
*					*
*  Text Blt code entry point here...	*
*					*
*****************************************

_TEXT_BL:

	movem.l	a5-a6,-(sp)
	move.l  _lineAVar,a6		; a6 -> linea var struct
	move.l	V_ROUTINES(a6),a4	; a4 -> list of vectored routines
	move.l	V_TEXT(a4),a4		; vector to desired text primitive
	jmp	(a4)

	.end
