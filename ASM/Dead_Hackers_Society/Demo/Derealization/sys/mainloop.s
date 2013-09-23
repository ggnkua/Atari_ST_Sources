; Falcon demoshell
; June 17, 2006
;
; Anders Eriksson
; ae@dhs.nu
;
; mainloop.s

		section	text

; --------------------------------------------------------------
;		mainloop 
; --------------------------------------------------------------

mainloop:
		ifne	pause
		cmp.b	#$2a,$fffffc02.w			;pause
		beq.s	.done					;
		endc

		tst.l	vblsync					;vbl wait mode
		bne.s	.always					;
.firstonly:	tst.w	vblwait		
								;wait for first vbl only
		beq.s	.done					;
		clr.w	vblwait					;
		bra.s	.waitdone				;

.always:	move.w	.var,d0					;wait for next vbl always
		cmp.w	vblwait,d0				;
		beq.s	.done					;


.waitdone:	move.l	main_routine,a0				;main routine
		cmp.l	#1,sys_param				;param 1 = run part only one time
		bne.s	.run					;param not 1, run always
		cmp.l	.oldrout,a0				;param was 1, check if we have run the part before
		beq.s	.nomainrout				;part has already been run once, skip
.run:		move.l	a0,.oldrout				;
		jsr	(a0)					;run main routine

.nomainrout:
		move.w	vblwait,.var				;later use

		cmp.l	#2,swapscreens				;number of screens to cycle
		blt.s	.done					;
		lea.l	screen_adr1,a0				;
		bgt.s	.swap3					;

.swap2:		move.l	(a0),d0					;cycle 2 screens
		move.l	4(a0),(a0)+				;
		move.l	d0,(a0)					;
		bra.s	.done					;

.swap3:		move.l	(a0),d0					;cycle 3 screens
		move.l	4(a0),(a0)+				;
		move.l	4(a0),(a0)+				;
		move.l	d0,(a0)					;

.done:
		ifne	cputime
		cmp.b	#$1d,$fffffc02.w
		bne.s	.nocpu
		move.l	#$000000ff,$ffff9800.w
.nocpu:
		endc
		
		cmp.b	#$39,$fffffc02.w			;exit
		bne.w	mainloop				;
		bra.w	exit					;

.var:		dc.w	0
.oldrout:	dc.l	0
