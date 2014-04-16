; Falcon demoshell
; June 17, 2006
;
; Anders Eriksson
; ae@dhs.nu
;
; vbl.s


		section	text

; --------------------------------------------------------------
;		vbl 50-100 Hz
; --------------------------------------------------------------

vbl:		movem.l	d0-a6,-(sp)

		ifne	pause
		cmp.b	#$2a,$fffffc02.w			;pause
		beq.s	.done					;
		endc

		ifne	cputime
		cmp.b	#$1d,$fffffc02.w
		bne.s	.nocpu
		clr.l	$ffff9800.w
.nocpu:
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

		ifne	dspmodmusic
		bsr.w	dspmod_vbl				;modplayer
		endc

.done:		movem.l	(sp)+,d0-a6
		rte

.var:		dc.l	0
.oldrout:	dc.l	0