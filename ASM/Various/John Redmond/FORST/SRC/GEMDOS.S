; GEMDOS.S: non-file TOS functions
; Copyright <C> John Redmond 1989, 1990
; Public domain for non-commercial use.
;
	section	text
	even

_constat: movem.l d2/a2/a3/a6,-(a7)
	move.w	#11,-(a7)
	trap	#1
	addq.l	#2,a7
	movem.l (a7)+,d2/a2/a3/a6
	ext.l	d0
	push	d0		;status
	rts
;
_prtstat: movem.l d2/a2/a3/a6,-(a7)
	move.w	#17,-(a7)
	trap	#1
	addq.l	#2,a7
	movem.l (a7)+,d2/a2/a3/a6
	ext.l	d0
	push	d0		;status
	rts
;
_auxinstat: movem.l d2/a2/a3/a6,-(a7)
	move.w	#18,-(a7)
	trap	#1
	addq.l	#2,a7
	movem.l (a7)+,d2/a2/a3/a6
	ext.l	d0
	push	d0		;status
	rts
;
_auxoutstat: movem.l d2/a2/a3/a6,-(a7)
	move.w	#19,-(a7)
	trap	#1
	addq.l	#2,a7
	movem.l (a7)+,d2/a2/a3/a6
	ext.l	d0
	push	d0		;status
	rts
;
_conin: movem.l d2/a2/a3/a6,-(a7) ;without echo
	move.w	#8,-(a7)
	trap	#1
	addq.l	#2,a7
	movem.l (a7)+,d2/a2/a3/a6
	clr.l	d1
	move.b	d0,d1		;remove scan code
	push	d1		;char
	rts
;
_conout: pop	d0
	movem.l d2/a2/a3/a6,-(a7)
	move.w	d0,-(a7)	;char
	move.w	#2,-(a7)	;screen = device 2
	move.w	#3,-(a7)	;bconout of bios
	trap	#13
	addq.l	#6,a7
	movem.l (a7)+,d2/a2/a3/a6
	rts
;
_auxin: movem.l d2/a2/a3/a6,-(a7)
	move.w	#3,-(a7)
	trap	#1
	addq.l	#2,a7
	movem.l (a7)+,d2/a2/a3/a6
	clr.l	d1
	move.b	d0,d1
	push	d1		;char
	rts
;
_auxout: pop	d0
	movem.l d2/a2/a3/a6,-(a7)
	move.w	d0,-(a7)
	move.w	#4,-(a7)
	trap	#1
	addq.l	#4,a7
	movem.l (a7)+,d2/a2/a3/a6
	rts
;
_prtout: pop	d0
	movem.l d2/a2/a3/a6,-(a7)
	move.w	d0,-(a7)
	move.w	#5,-(a7)
	trap	#1
	addq.l	#4,a7
	movem.l (a7)+,d2/a2/a3/a6
	tst.w	d0
	bne.s	.ptx
	lea	prterr,a0
	bra	_error
.ptx:	rts
;
	section	data
	even
;
	dc.b	$87,'CONSTA','T'!$80
	ptrs	_constat,20
;
	dc.b	$85,'CONI','N'!$80
	ptrs	_conin,18
;
	dc.b	$86,'CONOUT',$a0
	ptrs	_conout,20
;
	dc.b	$87,'PRTSTA','T'!$80
	ptrs	_prtstat,20
;
	dc.b	$89,'AUXINSTA','T'!$80
	ptrs	_auxinstat,22
;
	dc.b	$8a,'AUXOUTSTAT',$a0
	ptrs	_auxoutstat,24
;
