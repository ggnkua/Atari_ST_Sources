**********************************  mono.s  ***********************************
*
* $Revision: 3.2 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/mono.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/07/30 12:12:48 $     $Locker:  $
* =============================================================================
*
* $Log:	mono.s,v $
* Revision 3.2  91/07/30  12:12:48  lozben
* Cleaned up the code.
* 
* Revision 3.1  91/01/28  17:26:40  lozben
* Adjusted the code to work with the muultiple linea variable structure.
* 
* Revision 3.0  91/01/03  15:12:36  lozben
* New generation VDI
* 
* Revision 2.2  89/04/14  14:42:57  lozben
* Moved hb_mono() into another file. The idea is to have
* all the hard blit code in independent files.
* 
* Revision 2.1  89/02/21  17:23:41  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************

*   Mono-spaced text blt

	.include	"lineaequ.s"

	.globl	_MONO8XH

*  Mono spaced text blt...

	.text

fail_ret:	moveq	#0,d0		; exit if not byte bnd or clip required
		rts			; 0 indicates failure

*  Entry point here..

_MONO8XH:	move.l  _lineAVar,a1		; a1 -> linea var struct
		move.w	_DESTX(a1),d0		; d0 <- dst X
		move.w	d0,d2			; d2 <- dst X
		and.w	#$0007,d2		; this routine is only for
		bne	fail_ret		; byte alligned characters

on_bounds:	move.w	_DESTY(a1),d1		; d1 <- dst Y
		move.w	_DELY(a1),d3		; d3 <- dY

		move.l	_CONTRL(a1),a0		; a0 -> CONTRL array
		move.w	  6(a0),d2		; d2 <- # chars in string

		tst.w	_CLIP(a1)
		beq	no_clip			; skip clip test if disabled

		move.w	_XMN_CLIP(a1),d5	;8	d5 <- Xmin clip
		move.w	_YMN_CLIP(a1),d6	;8	d6 <- Ymin clip
		move.w	_XMX_CLIP(a1),d7	;8	d7 <- Xmax clip

		cmp.w	d6,d1			; str can't extend above Ymin
		blt	fail_ret		;

		move.w	d1,d4			;4	d4 <- dst Y
		add.w	d3,d4			;4	d4 <- bottom Y +1
		cmp.w	_YMX_CLIP(a1),d4	; str can't descend below Ymax
		bge	fail_ret		;8/10

		cmp.w	d5,d0			; str can't extend left of Xmin
		blt	fail_ret		;8/10

		move.w	d2,d4			; d4 <- number of characters
		lsl.w	#3,d4			; d4 <- width of str in pixels
		add.w	d0,d4			; d4 <- rightmost X +1
		cmp.w	d7,d4			; str can't extend right of Xmax
		bge	fail_ret		;8/10


*  no clipping to worry about
*
*   d0.w = _DESTX
*   d1.w = _DESTY
*   d2.w = # of characters
*   d3.w = _DELY

no_clip:	move.l	V_ROUTINES(a1),a0	; a1 -> routines vector list
		move.l	V_MONO(a0),a0		; a1 -> version of mono
		jmp	(a0)

	end
