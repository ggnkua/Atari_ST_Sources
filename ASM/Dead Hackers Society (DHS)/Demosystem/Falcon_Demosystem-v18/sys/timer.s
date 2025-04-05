; Falcon demosystem
;
; timer.s

		section	text

; --------------------------------------------------------------
;		timer-d 100 Hz
; --------------------------------------------------------------

timer_d:	movem.l	d0-a6,-(sp)

		subq.w	#1,.var					;300->100Hz sequencer
		bne.s	.skip_sequence				;
		move.w	#3,.var					;

		move.l	current_fx,a0				;Current position
		lea	sys_param,a1				;Rout/parameter list
		subq.l	#1,(a0)+				;Dec
		bne.s	.done					;0=next part
		add.l	#40,current_fx				;next part
.done:
		move.l	(a0)+,(a1)+				;Demo system parameter
		move.l	(a0)+,(a1)+				;Timer routine
		move.l	(a0)+,(a1)+				;Timer parameter
		move.l	(a0)+,(a1)+				;VBL routine
		move.l	(a0)+,(a1)+				;VBL parameter
		move.l	(a0)+,(a1)+				;Main routine
		move.l	(a0)+,(a1)+				;Main parameter
		move.l	(a0)+,(a1)+				;Screens to cycle
		move.l	(a0)+,(a1)+				;VBL-wait type

.skip_sequence:	
		move.l	timer_routine,a2			;Timer routine
		cmp.l	#1,sys_param				;Param 1 = run part only one time
		bne.s	.run					;Param not 1, run always
		cmp.l	.oldrout,a2				;Param was 1, check if we have run the part before
		beq.s	.notimerrout				;Part has already been run once, skip
.run:		move.l	a2,.oldrout				;
		jsr	(a2)					;Run timer routine

.notimerrout:	movem.l	(sp)+,d0-a6
		bclr	#4,$fffffa11.w				;Clear busybit
		rte

.var:		dc.w	3
.oldrout:	dc.l	0
