; Graoumf Is Not So Damn Slow
;
; cmdline.s
;
; August 11, 2001
;
; Anders Eriksson
; ae@dhs.nu

		section	text


commandline:
		move.l	filename,a0			;supersimple commandline check


.loop:
		cmp.b	#"-",(a0)			;check for (new) command
		bne.s	.nothing			;nope
		addq.l	#1,a0				;yep something is there

		cmp.b	#"q",(a0)			;check quiet mode
		bne.s	.nextq				;nope
		move.w	#1,quiet			;yep do it quiet
		addq.l	#2,a0				;next command
		bra.s	.qdone				;done
.nextq:		cmp.b	#"Q",(a0)			;
		bne.s	.qdone				;nope
		move.w	#1,quiet			;yep do it quiet
		addq.l	#2,a0				;next command
.qdone:	
	

		lea.l	freq_cmp_tab,a1			;check replay frequency
		moveq.l	#8-1,d7				;max 8 freqs
.freq:		
		move.w	(a1)+,d0			;(fx) commandline table
		cmp.w	(a0),d0				;compare to actual commandline
		beq.s	.freqdone			;yep found it

		dbra	d7,.freq			;next freq

		bra.s	.nofreq				;no freq setting found

.freqdone:	lea.l	prediv_tab,a1			;frequency table
		move.w	(a1,d7.w*2),gtkr_replay_prediv	;write via loopnumber
		addq.l	#3,a0				;next command

.nofreq:

		bra.s	.loop				;do it again
		
		

.nothing:	move.l	a0,filename			;all done store new filename addr



		move.l	#98340,d0			;calculate new replayfreq data
		move.w	gtkr_replay_prediv,d1		;
		addq.w	#1,d1				;
		divu.w	d1,d0				;
		move.w	d0,gtkr_replay_freq		;

		