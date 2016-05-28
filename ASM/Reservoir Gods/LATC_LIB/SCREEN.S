	SECTION CSECT	

	xdef	_rlsc_save_videl
	xdef	_rlsc_restore_videl	
	xdef	_rlsc_return_monitor_type
	xdef	_rlsc_set_videl

	SECTION	TEXT

_rlsc_save_videl
	movem.l	a0/d0,-(a7)
	
	move.l	12(a7),a0	
	addq.l	#1,a0

	move.l	$466.w,d0
wvbl1
	cmp.l	$466.w,d0
	beq.s	wvbl1

	move.b	$ffff8201.w,(a0)+	; 0 Screen Adr (high)
	move.b	$ffff8203.w,(a0)+	; 1 Screen Adr (medium)
	move.b	$ffff820d.w,(a0)+	; 2 Screen Adr (low)
	addq.l	#1,a0
	move.b	$ffff8265.w,(a0)+	; 3 Horizontal Scroll
	move.w	$ffff8282.w,(a0)+	; 4 Horizontal Hold Timer
	move.w	$ffff8284.w,(a0)+	; 6 Horizontal Border Begin
	move.w	$ffff8286.w,(a0)+	; 8 Horizontal Border End
	move.w	$ffff8288.w,(a0)+	;10 Horizontal Display Begin
	move.w	$ffff828a.w,(a0)+	;12 Horizontal display End 
	move.w	$ffff828c.w,(a0)+	;14 HSS-Synchro
	move.w	$ffff828e.w,(a0)+	;16 HFS
	move.w	$ffff8290.w,(a0)+	;18 HEE
	move.w	$ffff82a2.w,(a0)+	;20 Vertical Frequency Timer
	move.w	$ffff82a4.w,(a0)+	;22 Vertical Border Begin
	move.w	$ffff82a6.w,(a0)+	;24 Vertical Border End
	move.w	$ffff82a8.w,(a0)+	;26 Vertical Display Begin
	move.w	$ffff82aa.w,(a0)+	;28 Vertical Display End
	move.w	$ffff82ac.w,(a0)+	;30 VSS
	move.w	$ffff820a.w,(a0)+	;32 Video Sync Mode
	move.w	$ffff82c0.w,(a0)+	;34 Video Clock
	move.w	$ffff8266.w,(a0)+	;36 SPSHIFT - Falcon res
	move.w	$ffff82c2.w,(a0)+	;38 Video Control
	move.w	$ffff8210.w,(a0)+	;40 Falcon Line Width
	move.w	$ffff820e.w,(a0)+	;42 Offset to next line
	move.b	$ffff8260.w,(a0)+	;44 ST Resolution
	clr.b	(a0)				;st flag

	movem.l	(a7)+,a0/d0
	rts





_rlsc_restore_videl
	movem.l	a0/d0,-(a7)

	move.l	12(a7),a0
	addq.l	#1,a0

	move.l	$466.w,d0
wvbl2
	cmp.l	$466.w,d0
	beq.s	wvbl2

	move.b	(a0)+,$ffff8201.w	; 0 Screen Adr (high)
	move.b	(a0)+,$ffff8203.w	; 1 Screen Adr (medium)
	move.b	(a0)+,$ffff820d.w	; 2 Screen Adr (low)
	addq.l	#1,a0
	move.b	(a0)+,$ffff8265.w	; 3 Horizontal Scroll

	move.w	(a0)+,$ffff8282.w	; 4 Horizontal Hold Timer
	move.w	(a0)+,$ffff8284.w	; 6 Horizontal Border Begin
	move.w	(a0)+,$ffff8286.w	; 8 Horizontal Border End
	move.w	(a0)+,$ffff8288.w	;10 Horizontal Display Begin
	move.w	(a0)+,$ffff828a.w	;12 Horizontal display End 
	move.w	(a0)+,$ffff828c.w	;14 HSS-Synchro
	move.w	(a0)+,$ffff828e.w	;16 HFS
	move.w	(a0)+,$ffff8290.w	;18 HEE
	move.w	(a0)+,$ffff82a2.w	;20 Vertical Frequency Timer
	move.w	(a0)+,$ffff82a4.w	;22 Vertical Border Begin
	move.w	(a0)+,$ffff82a6.w	;24 Vertical Border End
	move.w	(a0)+,$ffff82a8.w	;26 Vertical Display Begin
	move.w	(a0)+,$ffff82aa.w	;28 Vertical Display End
	move.w	(a0)+,$ffff82ac.w	;30 VSS
	move.w	(a0)+,$ffff820a.w	;32 Video Sync Mode
	move.w	(a0)+,$ffff82c0.w	;34 Video Clock
	move.w	(a0)+,$ffff8266.w	;36 SPSHIFT - Falcon res
	tst.b	7(a0)
	beq.s	.no_st
	move.b	6(a0),$ffff8260.w
.no_st
	move.w	(a0)+,$ffff82c2.w	;38 Video Control
	move.w	(a0)+,$ffff8210.w	;40 Falcon Line Width
	move.w	(a0)+,$ffff820e.w	;42 STe Line Width

	movem.l	(a7)+,a0/d0
	rts


_rlsc_return_monitor_type:
	movem.l	a0-a2/d1-d2,-(a7)
	move.w	#$59,-(a7)
	trap	#14
	addq.l	#2,a7
	movem.l	(a7)+,a0-a2/d1-d2
	rts



_rlsc_set_videl
	movem.l	d0/a0,-(a7)

	move.l	12(a7),a0
	addq.l	#6,a0

	move.l	$466.w,d0
.wt	cmp.l	$466.w,d0
	beq.s	.wt

	clr.b	$ffff8265.w		; Horizontal Scroll

	move.w	(a0)+,$ffff8282.w	; Horizontal Hold Timer
	move.w	(a0)+,$ffff8284.w	; Horizontal Border Begin
	move.w	(a0)+,$ffff8286.w	; Horizontal Border End
	move.w	(a0)+,$ffff8288.w	; Horizontal Display Begin
	move.w	(a0)+,$ffff828a.w	; Horizontal display End 
	move.w	(a0)+,$ffff828c.w	; HSS-Synchro
	move.w	(a0)+,$ffff828e.w	; HFS
	move.w	(a0)+,$ffff8290.w	; HEE

	move.w	(a0)+,$ffff82a2.w	; Vertical Frequency Timer
	move.w	(a0)+,$ffff82a4.w	; Vertical Border Begin
	move.w	(a0)+,$ffff82a6.w	; Vertical Border End
	move.w	(a0)+,$ffff82a8.w	; Vertical Display Begin
	move.w	(a0)+,$ffff82aa.w	; Vertical Display End
	move.w	(a0)+,$ffff82ac.w	; VSS
	move.w	(a0)+,$ffff820a.w	; Video Sync Mode
	move.w	(a0)+,$ffff82c0.w	; Video Clock
	move.w	(a0)+,$ffff8266.w	; SPSHIFT - Falcon res
	tst.b	(a0)+				; use st mode?
	beq.s	no_st				; no
	move.b	(a0),$ffff8260.w	; set st mode
no_st
	addq.w	#1,a3				; next data
	move.w	(a0)+,$ffff82c2.w	; Video Control
	move.w	(a0)+,$ffff8210.w	; Falcon Line Width
	move.w	(a0)+,$ffff820e.w	; STe Line Width

	movem.l	(a7)+,a0/d0
	rts

	END
