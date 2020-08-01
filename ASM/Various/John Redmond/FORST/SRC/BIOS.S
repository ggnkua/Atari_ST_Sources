; BIOS.S: bios and xbios routines
; Copyright <C> John Redmond 1989, 1990
; Public domain for non-commercial use.
;
	section	text
	even

_physbase: movem.l d2/a2/a3/a6,-(a7)
	move.w	#2,-(a7)
	trap	#14
	addq.l	#2,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	rts
;
_logbase: movem.l d2/a2/a3/a6,-(a7)
	move.w	#3,-(a7)
	trap	#14
	addq.l	#2,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	rts
;
_setprt: pop	d0
	movem.l d2/a2/a3/a6,-(a7)
	move.w	d0,-(a7)
	move.w	#33,-(a7)
	trap	#14
	addq.l	#4,a7
	movem.l (a7)+,d2/a2/a3/a6
	rts
;
_scrdmp: movem.l d2/a2/a3/a6,-(a7)
	move.w	#20,-(a7)
	trap	#14
	addq.l	#2,a7
	movem.l (a7)+,d2/a2/a3/a6
	rts
;
	section	data
	even
;
	dc.b	$88,'PHYSBASE',$a0
	ptrs	_physbase,22
;
	dc.b	$87,'LOGBAS','E'!$80
	ptrs	_logbase,20
;
	dc.b	$86,'SETPRT',$a0
	ptrs	_setprt,20
;
	dc.b	$86,'SCRDMP',$a0
	ptrs	_scrdmp,20
;
