; Falcon demosystem
;
; mainloop.s

		section	text

; --------------------------------------------------------------
;		mainloop 
; --------------------------------------------------------------

mainloop:
		tst.l	vblsync					;VBL wait mode
		bne.s	.always					;
.firstonly:	tst.w	vblwait		
								;Wait for first VBL only
		beq.s	.done					;
		clr.w	vblwait					;
		bra.s	.waitdone				;

.always:	move.w	.var,d0					;Wait for next VBL always
		cmp.w	vblwait,d0				;
		beq.s	.done					;


.waitdone:	move.l	main_routine,a0				;Main routine
		cmp.l	#1,sys_param				;Param 1 = run part only one time
		bne.s	.run					;Param not 1, run always
		cmp.l	.oldrout,a0				;Param was 1, check if we have run the part before
		beq.s	.nomainrout				;Part has already been run once, skip
.run:		move.l	a0,.oldrout				;
		jsr	(a0)					;Run main routine

.nomainrout:
		move.w	vblwait,.var				;Later use

		cmp.l	#2,swapscreens				;Number of screens to cycle
		blt.s	.done					;
		lea	screen_adr1,a0				;
		bgt.s	.swap3					;

.swap2:		move.l	(a0),d0					;Cycle 2 screens
		move.l	4(a0),(a0)+				;
		move.l	d0,(a0)					;
		bra.s	.done					;

.swap3:		move.l	(a0),d0					;cycle 3 screens
		move.l	4(a0),(a0)+				;
		move.l	4(a0),(a0)+				;
		move.l	d0,(a0)					;

.done:
	ifeq	mouse
		cmp.b	#$39,$fffffc02.w			;Exit? Spacebar
		bne	mainloop				;
	else
		btst	#0,mousebuttons				;Exit? Right mouse
		beq	mainloop				;
	endc

		bra	exit					;

.var:		dc.w	0
.oldrout:	dc.l	0

		section	text

