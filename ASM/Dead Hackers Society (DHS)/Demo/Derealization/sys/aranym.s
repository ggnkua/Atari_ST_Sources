; Falcon demoshell
; June 17, 2006
;
; Anders Eriksson
; ae@dhs.nu
;
; aranym.s

;-------------- aranym combined vbl/timer

		ifne	aranym

vbl:		movem.l	d0-a6,-(sp)

		ifne	pause
		cmp.b	#$2a,$fffffc02.w			;pause
		beq.w	.done					;
		endc


		cmp.l	#2,swapscreens				;set screen_adr
		bge.s	.no 					;
		move.l	screen_adr,d0				;single set
		cmp.l	.var,d0					;
		beq.s	.noset					;
		move.l	d0,.var					;
		bra.s	.set					;

.no:	 	move.l	screen_adr1,d0				;double/tripple set
		cmp.l	.var,d0					;
		beq.s	.noset					;
		move.l	d0,.var					;

.set:		move.l	d0,d1					;set screen
		lsr.w	#8,d0					;
		move.l	d0,$ffff8200.w				;
		move.b	d1,$ffff820d.w				;

.noset:		move.l	vbl_routine,a0				;vbl routine
		cmp.l	#1,sys_param				;param 1 = run part only one time
		bne.s	.run					;param not 1, run always
		cmp.l	.oldrout,a0				;param was 1, check if we have run the part before
		beq.s	.novblrout				;part has already been run once, skip
.run:		move.l	a0,.oldrout				;
		jsr	(a0)					;run vbl routine

.novblrout:
		addq.w	#1,vblwait				;inc vbl

		rept	6
		bsr.s	timer_d
		endr

.done:
		movem.l	(sp)+,d0-a6
		rte

.var:		dc.l	0
.oldrout:	dc.l	0




timer_d:
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

.skip_sequence:	move.l	timer_routine,a2			;timer routine
		cmp.l	#1,sys_param				;param 1 = run part only one time
		bne.s	.run					;param not 1, run always
		cmp.l	.oldrout,a2				;param was 1, check if we have run the part before
		beq.s	.notimerrout				;part has already been run once, skip
.run:		move.l	a2,.oldrout				;
		jsr	(a2)					;run timer routine

.notimerrout:	
.done2:		rts
.var:		dc.w	3
.oldrout:	dc.l	0


		endc

;-------------- end aranym


