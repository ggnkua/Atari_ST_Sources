;----------------------------------------------------------------------------
;File name:	strnicmp.s			Revision date:	2000.08.25
;Revised by:	Ronald Andersson		Revision start:	2000.08.25
;----------------------------------------------------------------------------
strnicmp:
	move.l	a2,-(a7)
	lea	_UpcTab(pc),a2
	clr	d1
	clr	d2
L3C2E:
	subq.l	#1,d0
	bcs.s	L3C4E
	move.b	(a0)+,d1
	move.b	$00(a2,d1),d1
	beq.s	L3C4A
	move.b	(a1)+,d2
	move.b	$00(a2,d2),d2
	cmp.b	d2,d1
	beq.s	L3C2E
	bcs.s	L3C52
L3C46:
	moveq	#$01,d0
	bra.s	L3C54

L3C4A:
	tst.b	(a1)
	bne.s	L3C46
L3C4E:
	moveq	#$00,d0
	bra.s	L3C54

L3C52:
	moveq	#-$01,d0
L3C54:
	movea.l	(a7)+,a2
	rts
;----------------------------------------------------------------------------
;End of file:	strnicmp.s
;----------------------------------------------------------------------------
