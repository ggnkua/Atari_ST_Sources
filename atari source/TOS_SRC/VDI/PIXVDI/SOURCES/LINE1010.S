*******************************  line1010.s  *********************************
*
* $Revision: 3.2 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/line1010.s,v $
* ============================================================================
* $Author: lozben $	$Date: 91/07/29 14:49:28 $     $Locker:  $
* ============================================================================
*
* $Log:	line1010.s,v $
* Revision 3.2  91/07/29  14:49:28  lozben
* Got rid of some useless equates.
* 
* Revision 3.1  91/02/08  17:29:59  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.0  91/01/03  15:12:12  lozben
* New generation VDI
* 
* Revision 2.5  90/02/16  12:23:08  lozben
* Fixed some of the code so that it can be assembled with mas.
* 
* Revision 2.4  89/10/10  14:55:40  lozben
* Fixed a bug. HABLINE() was not vectored properly.
* 
* Revision 2.3  89/07/11  16:01:24  lozben
* Added 16x32 system font to the font list
* 
* Revision 2.2  89/05/23  16:49:45  lozben
* Revectored all the lineA routines which used to use bit plane
* flags. Now the flags are used to set a color index then old
* routines are called.
* 
* Revision 2.1  89/02/21  17:23:31  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
******************************************************************************

.include	"lineaequ.s"

		text

		globl	_put_pix,_get_pix,_ABLINE,_HABLINE
		globl	_RECTFILL,_CLC_FLIT,_COPY_RFM,_TEXT_BLT
		globl	_v_show_c,_HIDE_CUR,_XFM_CRFM
		globl	cur_replace,cur_display,KG_BLT,_seedfill
		globl	line1010
		globl	_first,_f8x8,_f8x16,_f16x32
		globl	_retfalse


*************************************************************************
*	This routine decodes the "line 1010" instruction to call	*
*    the appropriate primitive graphics routine.			*
*************************************************************************

line1010:	move.l	2(sp),a1	; fetch pc off stack.
		move.w	(a1),d2		; fetch 1010 instruction.
		and.w	#$0FFF,d2	; remove the 1010.
		addq.l	#2,a1		; increment pc.
		move.l	a1,2(sp)	; restore pc to stack.
		cmp.w	#15,d2		; opcode = 15?
		bhi	la_out		; above 15 => exit.
		lsl.w	#2,d2		; long word indexing.
		move.l	atab(pc,d2.w),a1  ; fetch routine address.
		movem.l	d3-d7/a3-a5,-(sp) ; for "C".
		jsr	(a1)		  ; call routine.
		movem.l	(sp)+,d3-d7/a3-a5 ; for "C".
la_out:		rte
*
var_base:	move.l	_lineAVar,a0	; return the base address of line 1010.
		move.l	a0,d0		; for "C".
		lea	fonts,a1	; and a ptr to the first font header.
		lea	atab,a2		; and a ptr to the array of pointers.
		rts
*
atab:		dc.l	var_base,_put_pix,_get_pix,M_ABLINE
		dc.l	M_HABLINE,M_RECTFILL,M_CLC_FLIT,KG_BLT
		dc.l	_TEXT_BLT,_v_show_c,_HIDE_CUR,_XFM_CRFM
		dc.l	cur_replace,cur_display,_COPY_RFM,_seedfill

*+
*  These routines set the color index then go to the primitives.
*  We are stuck using bit plane flags for backward compatibility.
*-
M_ABLINE:	bsr	set_index
		jmp	_ABLINE

M_HABLINE:	bsr	set_index
		jmp	_HABLINE

M_RECTFILL:	bsr	set_index
		jmp	_RECTFILL

M_CLC_FLIT:	bsr	set_index
		jmp	_CLC_FLIT

*+
* Set the color index by checking the bit plane flags then
* setting the appropriate bits.
*-
set_index:	move.l	_lineAVar,a4		; a4 -> LineA variable base
		clr.l	d0			; clear color index
		lea	_FG_BP_1(a4),a3		; a3 -> 1st 4 back plane flags
		lea	_FG_BP_5(a4),a5		; a5 -> 2nd 4 back plane flags

		tst.w	(a3)+
		beq	bp2
		bset.l	#0,d0

bp2:		tst.w	(a3)+
		beq	bp3
		bset.l	#1,d0

bp3:		tst.w	(a3)+
		beq	bp4
		bset.l	#2,d0

bp4:		tst.w	(a3)+
		beq	bp5
		bset.l	#3,d0

bp5:		tst.w	(a5)+
		beq	bp6
		bset.l	#4,d0

bp6:		tst.w	(a5)+
		beq	bp7
		bset.l	#5,d0

bp7:		tst.w	(a5)+
		beq	bp8
		bset.l	#6,d0

bp8:		tst.w	(a5)+
		beq	bp9
		bset.l	#7,d0

bp9:		move.l	d0,_FG_B_PLANES(a4)	; copy the color index
		rts



*+
* pointer to system fonts
*-
fonts:		dc.l	_first,_f8x8,_f8x16,_f16x32,0


_retfalse:	moveq	#0,d0		; FALSE => continue seedfill.
		rts
		end
