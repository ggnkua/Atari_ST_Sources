*********************************************************************************
*										*
*	GCC TC interface. Does save d2 that is destroyed by TC			*
*	(C) 2000 Dr. Thomas Redelberger						*
*										*
*										*
*********************************************************************************
* $Id$


*
* code generation options
*
*		OPT	D+		; switch on symbol info
		OPT	O+		; optimize 0(an) to (an)
		OPT	W-		; warnings off
		OPT	M+		; macro expansion in listings on

		OUTPUT	C:\TMP\LPGCC2TC.O
		XDEF	lp_open
		XDEF	lp_write
		XDEF	lp_read
		XDEF	lp_lseek
		XDEF	lp_ioctl
		XDEF	lp_datime
		XDEF	lp_close
		XDEF	lp_select
		XDEF	lp_unselect

* entry points defined in lpgcc2tc.c
		XREF	tlp_open
		XREF	tlp_write
		XREF	tlp_read
		XREF	tlp_lseek
		XREF	tlp_ioctl
		XREF	tlp_datime
		XREF	tlp_close
		XREF	tlp_select
		XREF	tlp_unselect


lp_open		move.l	d2,-(sp)
		jsr	tlp_open
		move.l	(sp)+,d2
		rts

lp_write	move.l	d2,-(sp)
		jsr	tlp_write
		move.l	(sp)+,d2
		rts

lp_read		move.l	d2,-(sp)
		jsr	tlp_read
		move.l	(sp)+,d2
		rts

lp_lseek	move.l	d2,-(sp)
		jsr	tlp_lseek
		move.l	(sp)+,d2
		rts

lp_ioctl	move.l	d2,-(sp)
		jsr	tlp_ioctl
		move.l	(sp)+,d2
		rts

lp_datime	move.l	d2,-(sp)
		jsr	tlp_datime
		move.l	(sp)+,d2
		rts

lp_close	move.l	d2,-(sp)
		jsr	tlp_close
		move.l	(sp)+,d2
		rts

lp_select	move.l	d2,-(sp)
		jsr	tlp_select
		move.l	(sp)+,d2
		rts

lp_unselect	move.l	d2,-(sp)
		jsr	tlp_unselect
		move.l	(sp)+,d2
		rts

******** end of lpgcc2tc.s ************************************************************
