.EXPORT asmousevec, mousevec, mp


asmousevec:
		pea			s_click
		move.w	#$26,-(sp)
		trap		#14
		addq.l	#6,sp
		rts
s_click:
		.SUPER
		
		movem.l	d0/a0-a2,-(sp)
;		move.w	SR,-(sp)
;		ori			#$700,sr	;alle Interrupts sperren
		
		move.l	mousevec,a2
		lea			mp,a0
		jsr			(a2)
;		move.w	(sp)+,SR
		movem.l	(sp)+,d0/a0-a2
		rts
		
		.USER


mousevec:
	.DS.L	1
mp:
	.DS.L	1