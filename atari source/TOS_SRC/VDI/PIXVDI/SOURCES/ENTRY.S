*********************************  entry.s  ***********************************
*
* $Revision: 3.3 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/entry.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/02/14 17:57:44 $     $Locker:  $
* =============================================================================
*
* $Log:	entry.s,v $
* Revision 3.3  91/02/14  17:57:44  lozben
* We forgot to reference the local_pb of a linea structure pointer.
* 
* Revision 3.2  91/02/13  10:36:41  lozben
* Forgot to include "lineaequ.s".
* 
* Revision 3.1  91/02/11  13:25:55  lozben
* Adjusted the code to work with the multiple linea variablestructures.
* 
* Revision 3.0  91/01/03  15:07:00  lozben
* New generation VDI
* 
* Revision 2.2  90/12/05  13:47:32  lozben
* Changed PTSIN from 512 to 1024.
* 
* Revision 2.1  89/02/21  17:18:57  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************

.include	"lineaequ.s"

	.globl	_GSX_ENTRY
	.globl	_MAX_VERT

	.xdef	ptsin_array
	.xdef	_FLIP_Y
	.xdef	_SCREEN


PTSIN		equ	1024		; PTSIN maximum length:	1024 verticies


*******************************************************************************
*
* _GSX_ENTRY
*  This module is the front end of the built-in screen GIOS for the Atari RBP.
*  The application will have arrived at this point via
*
*	...
*
*	move	#115,d0
*	move.l	#PB,d1
*	trap	#2
*
*	...
*
* PB:	.dc.l	contrl
*	.dc.l	intin
*	.dc.l	ptsin
*	.dc.l	intout
*	.dc.l	ptsout
*
*******************************************************************************

_GSX_ENTRY:

	movem.l	d1-d7/a0-a6,-(sp)	; Save the callers registers

	move.l	d1,a0			; a0 -> caller's parameter block
	move.l  _lineAVar,a2		; a2 -> linea var struct
	lea	local_pb(a2),a1		; a1 -> local parameter block
	lea	ptsin_array,a3		; a3 -> local ptsin array

*   make a local copy of the pointers in the caller's parameter block

	move.l	(a0)+,a2		; a2 -> caller's contrl array
	move.l	a2,(a1)+		; contrl
	move.l	(a0)+,(a1)+		; intin
	move.l	(a0)+,a4		; a4 -> caller's ptsin array
	move.l	a3,(a1)+		; ptsin (local ptsin array)
	move.l	(a0)+,(a1)+		; intout
	move.l	(a0)+,(a1)+		; ptsout


*   get number of ptsin entries to copy locally

	move.w	2(a2),d0	 ; d0 <- number of verticies from CONTRL[1]
	move.w	d0,-(sp)	 ; save copy since driver may alter original
	beq	no_ptsin	 ; no entries to copy

	move.w	#PTSIN,d1	 ; d1 <- maximum length of ptsin array  (words)
	cmp.w	d1,d0		 ; is it more than we have room for?
	ble	ptsin_ok	 ; no, transfer this number

	move.w	d1,d0		 ; yes, set size to max
	move.w	d1,2(a2)	 ; truncate value in user's CONTRL array


*   make a local copy of the PTSIN array

ptsin_ok:
	move.w	d0,d1			; d1 <- gets the number of verticies
	asr.w	#3,d0			; d0 <- (# of verticies) div (8)
	andi.w	#7,d1			; d1 <- (# of verticies) mod (8)
	add.w	d1,d1			; make d1 a word index
	neg.w	d1			; make it an index from the bottom
	jmp	dec_count(pc,d1.w)	; move mod 8 vertices

ptsin_loop:

	move.l	(a4)+,(a3)+		; move 8 verticies [(x,y)] at a time
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+

dec_count:				

	dbra	d0,ptsin_loop		; d0 contains count ((# of verts) / (8))


no_ptsin:

*   jump to SCREEN, front end of C routines for screen GIOS

	jsr	_SCREEN


*   Restore the vertex count in the callers control array

	move.l  _lineAVar,a2		; a2 -> linea var struct
	move.l	_CONTRL(a2),a0		; a0 -> CONTRL
	move.w	(sp)+,2(a0)		; restore original array length

	movem.l	(sp)+,d1-d7/a0-a6	; Restore the callers registers
	move.w	_FLIP_Y,d0		; d0 indicates magnitude/coordinate

	rts


_MAX_VERT:	dc.w	PTSIN

.end
