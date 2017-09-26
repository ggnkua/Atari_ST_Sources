		xdef	LockSender
LockSender:
		tas		sem
		beq		locked
		bclr.b	#7,sem
		clr.w	d0					; return FALSE
		rts
locked:	ori.b	#$ff,sem
		move.w	#$ff,d0				; return TRUE
		rts
		
		xdef	UnlockSender
UnlockSender:
		clr.b	sem
		rts

sem:	dc.w	0


		xdef	GetSTInterface
GetSTInterface:
		movem.l	d1-d7/a0-a4,-(a7)

		pea		gestalt				; par to callMacContext
		jsr		(a0)				; callMacContext(gestalt)
		addq.l	#4,a7

		cmp.w	#0,res				; err==0?
		beq		ok
		
		move.l	#0,d0				; no: return 0
		bra		end

ok:		move.l	par,d0				; yes: return value
		
end:	movem.l	(a7)+,d1-d7/a0-a4
		rts

gestalt:move.l	#'STip',d0
		dc.w	$a1ad				; Gestalt
		move.w	d0,res				; save result
		move.l	a0,par
		rts

		xdef	WaitNextEvent
WaitNextEvent:
		movem.l	d1-d7/a0-a6,-(a7)
		pea		wait_next_event		; par to callMacContext
		jsr		(a0)				; callMacContext(wait_next_event)
		addq.l	#4,a7
		movem.l	(a7)+,d1-d7/a0-a6
		rts

wait_next_event:
		link	a6,#$fff0
		subq.w	#2,a7
		clr.w	-(a7)
		pea		-$0010(a6)
		pea		$0000
		clr.l	-(a7)
		dc.w	$a860				; WaitNextEvent
		move.b	(a7)+,d0
		unlk	a6
		rts


		data
		even

par:	dc.l	0
res:	dc.w	0
