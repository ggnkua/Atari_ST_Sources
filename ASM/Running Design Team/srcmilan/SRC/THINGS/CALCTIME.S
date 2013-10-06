

		text


; ---------------------------------------------------------
; 09.08.00/vk
; berechnet das zeitlimit von aktivierten gegenstaenden neu.
; falls ein zeitlimit abgelaufen ist, wird der gegenstand
; - sofern kein weiterer bei der multiple eigenschaft vor-
; handen ist - deaktiviert.
calcActivatedItemTimelimit

		lea	playerThings,a0
		lea	things,a2

		moveq	#THINGSMAX-1,d7
		move.w	d6,d1
caitLoop
		movea.l	(a2)+,a1

		tst.w	PTHGFLAG(a0)				; gegenstand vorhanden?
		beq.s	caitSkip
		tst.w	PTHGACTFLAG(a0)				; gegenstand auch aktiviert?
		beq.s	caitSkip
		tst.l	PTHGTIMELIMIT(a0)			; zeitlimit vorhanden?
		bmi.s	caitSkip

		move.w	d1,d0
		sub.w	d7,d0					; d0 = gegenstandsindex
		bsr.s	calcActivatedSingleItemTimelimit
caitSkip
		lea	PTHGBYTES(a0),a0
		
		dbra	d7,caitLoop

		rts


; ---------------------------------------------------------
; 09.08.00/vk
; unterroutine von calcactivateditemtimelimit fuer einen
; einzelnen gegenstand (der nach vor. ein zeitlimit
; besitzt).
; d0 = gegenstandsindex
; a0 = zeiger auf gegenstand in playerthings
; a1 = zeiger auf allg. gegenstandsdefinition (array things)
; rettet alle register
calcActivatedSingleItemTimelimit

		movem.l	d0-d3,-(sp)

		move.l	PTHGTIMECOUNTER(a0),d3
		move.w	vblTime1000,d1
		move.w	THGTIMEDURATION(a1),d2
		lsl.w	d2,d1
		ext.l	d1
		sub.l	d1,d3
		bmi.s	casitTimeOut				; zeit ist abgelaufen

		move.l	d3,PTHGTIMECOUNTER(a0)
		bra.s	casitOut

casitTimeOut
		tst.w	PTHGMULTIPLE(a0)
		beq.s	casitRemoveAll

		subq.w	#1,PTHGNB(a0)
		beq.s	casitRemoveAll

		move.l	PTHGTIMELIMIT(a0),PTHGTIMECOUNTER(a0)
		bra.s	casitOut

casitRemoveAll
		bsr	tDeactivateText
		clr.w	PTHGFLAG(a0)

casitOut
		movem.l	(sp)+,d0-d3
		rts


