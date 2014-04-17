*********************************  blitinit.s  ********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/blitinit.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/02/01 15:29:25 $     $Locker:  $
* =============================================================================
*
* $Log:	blitinit.s,v $
* Revision 3.1  91/02/01  15:29:25  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.0  91/01/03  15:06:21  lozben
* New generation VDI
* 
* Revision 2.3  90/03/01  11:33:51  lozben
* Did conditional assembly for hardblit vectors.
* 
* Revision 2.2  89/04/13  19:32:37  lozben
* Got rid of conditional assembly which forced hard
* text blit, it was not needed.
* 
* Revision 2.1  89/02/21  17:18:31  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************

.include	"lineaequ.s"

		.globl	_GETBLT
		.globl	_SETBLT
		.globl	rout_init


*******************************************************************************
*									      *
*	Set the BLASTER primitive vector list then call initialize routine.   *
*									      *
* in:		d0	blit mode word				              *
*									      *
*		bit0	0:soft			1:hard			      *
*		bit1	0:no hardware assist    1:hardware assist	      *
*									      *
*		other bits currently undefined				      *
*									      *
*******************************************************************************

rout_init:
_SETBLT:	move.l  _lineAVar,a1		; a1 -> linea var struct
		move.w	d0,_BLT_MODE(a1)	; store present mode selection
		move.l	CUR_DEV(a1),a0		; a0 -> current device struct


		;
		; Init routines vector list pointer
		;
		move.l	DEVSOFTROUTINES(a0),a2	; a2 -> routine list
		btst.l	#0,d0
		beq	setblt0
		move.l	DEVHARDROUTINES(a0),a2	; a2 -> routine list


setblt0:	lea	V_PRIMITIVES(a1),a0	; a0 -> space for primitives
		move.l	a0,V_ROUTINES(a1)	; pnt to ram based routine list
		move.w	#21,d0			; setup the loop count

rCopyLoop:	move.l	(a2)+,(a0)+		; copy vector
		dbra	d0,rCopyLoop

		move.l	V_ROUTINES(a1),a1	; a1 -> vector list
		move.l	V_INIT(a1),a1		; a1 -> version of init
		jsr	(a1)			; 
		rts


*******************************************************************************
*									      *
*	Get the current BiT BLiT mode					      *
*									      *
* out:	d0	bit blit mode word					      *
*									      *
*******************************************************************************

_GETBLT:	move.l	a0,-(sp)
		move.l  _lineAVar,a0		; a0 -> linea var struct
		move.w	_BLT_MODE(a0),d0
		move.l	(sp)+,a0
		rts

.end
