***********************************
*=================================*
* RESERVOIR GODS LIBRARY ROUTINES *
*=================================*
*       |                |        *
*       |DISK_OS LIBRARY |        *
*       |                |        *
***********************************
* CODE: MR. PINK | (C): 28/07/96  *
***********************************

	SECTION CSECT

	xdef	rlbssd_open
	xdef	rlbssd_close
	xref	rlbssd_new_set_screen

**************************************************************************
	SECTION TEXT
**************************************************************************

rlbssd_bss_debug_constructor:
	movem.l	a0-2,-(a7)

	cmp.l	#"BSSD",$40.w
	bne	.notins
	tst.l	$44.w
	beq	.notins
	move.l	$44.w,a0
	move.w	#$67f8,$4324(a0)
	move.w	#$4ef9,$4332(a0)
	lea	rlbssd_new_set_screen,a1
	move.l	a1,$4332+2(a0)

	lea	$830(a0),a2
	lea	18(a2),a1
	move.l	-(a2),-(a1)
	move.l	-(a2),-(a1)
	move.w	-(a2),-(a1)
	lea	$4332(a0),a2
	move.l	a2,-(a1)
	move.l	#$426e0058,-(a1)
	move.w	#$23fc,-(a1)
	addq.w	#4,a2
	move.l	a2,-(a1)
	move.l	#$33fc4e75,-(a1)

	clr.l	$40.w
	clr.l	$44.w
.notins
	movem.l	(a7)+,a0-2
	rts

rlbssd_bss_debug_deconstructor:
	clr.l	$40.w
	clr.l	$44.w
	rts


