; Falcon demosystem
;
; vbl.s


		section	text

; --------------------------------------------------------------
;		vbl 50-100 Hz
; --------------------------------------------------------------

vbl:		movem.l	d0-a6,-(sp)

		move.l	screen_adr,d0
		move.l	d0,d1					;Set screen
		lsr.w	#8,d0					;
		move.l	d0,$ffff8200.w				;
		move.b	d1,$ffff820d.w				;

.noset:		move.l	vbl_routine,a0				;VBL routine
		cmp.l	#1,sys_param				;Param 1 = run part only one time
		bne.s	.run					;Param not 1, run always
		cmp.l	.oldrout,a0				;Param was 1, check if we have run the part before
		beq.s	.novblrout				;Part has already been run once, skip
.run:		move.l	a0,.oldrout				;
		jsr	(a0)					;Run VBL routine

.novblrout:

		addq.w	#1,vblwait				;Inc VBL

		jsr	music_play				;Call music driver

.done:		movem.l	(sp)+,d0-a6
		rte

.var:		dc.l	0
.oldrout:	dc.l	0
