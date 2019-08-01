;----------------------------------------------------------------------------
;File name:	stricmp.s			Revision date:	2000.08.25
;Revised by:	Ronald Andersson		Revision start:	2000.08.25
;----------------------------------------------------------------------------
stricmp:
	move.l	a2,-(a7)
	lea	_UpcTab(pc),a2
	clr	d0
	clr	d1
L3BF6:
	move.b	(a0)+,d0
	move.b	$00(a2,d0),d0
	beq.s	L3C1A
	move.b	(a1)+,d1
	move.b	$00(a2,d1),d1
	cmp.b	d1,d0
	beq.s	L3BF6
	move.b	-(a1),d1
	move.b	$00(a2,d1),d1
	cmp.b	d1,d0
	bcs.s	L3C16
	moveq	#$01,d0
	bra.s	L3C20

L3C16:
	moveq	#-$01,d0
	bra.s	L3C20

L3C1A:
	tst.b	(a1)
	bne.s	L3C16
	moveq	#$00,d0
L3C20:
	movea.l	(a7)+,a2
	rts
;----------------------------------------------------------------------------
;End of file:	stricmp.s
;----------------------------------------------------------------------------
