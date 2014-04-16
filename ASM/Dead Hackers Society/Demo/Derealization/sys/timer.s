; Falcon demoshell
; June 17, 2006
;
; Anders Eriksson
; ae@dhs.nu
;
; timer.s

		section	text




; --------------------------------------------------------------
;		timer-d 100 Hz
; --------------------------------------------------------------

timer_d:	movem.l	d0-a6,-(sp)

		ifne	pause
		cmp.b	#$2a,$fffffc02.w			;pause
		beq.s	.done2					;
		endc

		subq.w	#1,.var					;300->100Hz sequencer
		bne.s	.skip_sequence				;
		move.w	#3,.var					;

		move.l	current_fx,a0				;current position
		lea.l	sys_param,a1				;rout/parameter list
		subq.l	#1,(a0)+				;dec
		bne.s	.done					;0=next part
		add.l	#40,current_fx				;next part
.done:
		move.l	(a0)+,(a1)+				;demo system parameter
		move.l	(a0)+,(a1)+				;timer routine
		move.l	(a0)+,(a1)+				;timer parameter
		move.l	(a0)+,(a1)+				;vbl routine
		move.l	(a0)+,(a1)+				;vbl parameter
		move.l	(a0)+,(a1)+				;main routine
		move.l	(a0)+,(a1)+				;main parameter
		move.l	(a0)+,(a1)+				;screens to cycle
		move.l	(a0)+,(a1)+				;vblwait type

.skip_sequence:	
		move.l	timer_routine,a2			;timer routine
		cmp.l	#1,sys_param				;param 1 = run part only one time
		bne.s	.run					;param not 1, run always
		cmp.l	.oldrout,a2				;param was 1, check if we have run the part before
		beq.s	.notimerrout				;part has already been run once, skip
.run:		move.l	a2,.oldrout				;
		jsr	(a2)					;run timer routine

.notimerrout:		

.nah:

.done2:		movem.l	(sp)+,d0-a6
		bclr	#4,$fffffa11.w				;clear busybit
		rte
.var:		dc.w	3
.oldrout:	dc.l	0
