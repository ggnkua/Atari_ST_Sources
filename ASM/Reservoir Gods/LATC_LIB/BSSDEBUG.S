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

	xdef	_rlbssd_open
	xdef	_rlbssd_close

	xref	_videl_changed_flag
	xref	_videl_current
	xref	_rlsc_set_videl

**************************************************************************
	SECTION TEXT
**************************************************************************

_rlbssd_open
	movem.l	a0-a2,-(a7)

	cmp.l	#$42535344,$40.w
	bne	.notins
	tst.l	$44.w
	beq	.notins
	move.l	$44.w,a0
	move.w	#$67f8,$4324(a0)
	move.w	#$4ef9,$4332(a0)
	lea	_rlbssd_new_set_screen_init,a1
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
	movem.l	(a7)+,a0-a2
	rts

_rlbssd_close
	clr.l	$40.w
	clr.l	$44.w
	rts

_rlbssd_new_set_screen_init
	clr.w	$58(a6)
	movem.l	d0-d7/a0-a6,-(a7)
	tst.w	_videl_changed_flag
	beq	no_rlbssd_set_videl
	pea	_videl_current
	jsr	_rlsc_set_videl
	addq.l	#4,a7
no_rlbssd_set_videl
	movem.l	(a7)+,d0-d7/a0-a6
	rts

	END