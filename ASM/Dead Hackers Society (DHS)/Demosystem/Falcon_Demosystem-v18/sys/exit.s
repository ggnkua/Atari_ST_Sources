; Falcon demosystem
;
; exit.s

		section	text

;---------------------------------------------------------------
exit:
;---------------------------------------------------------------


		tst.w	do_restore_mfp				;Restore MFP
		beq.s	.no_mfp					;
		bsr	restore_ints				;

.no_mfp:	jsr	music_exit


	ifne	mouse
		tst.w	do_restore_mouse			;Restore mouse
		beq.s	.no_mouse				;
		bsr	mouse_exit				;
.no_mouse:
	endc

		tst.w	do_restore_key				;Restore keyclick
		beq.s	.no_key					;
		bsr	restore_click				;
.no_key:


	ifne	screenshot
		bsr	screenshot_snapit			;Save screenshot
	endc

		tst.w	do_restore_gfx				;Restore video
		beq.s	.no_gfx					;
		bsr	restore_video				;

.no_gfx:	tst.w	do_restore_sup				;Exit supervisor
		beq.s	.no_sup					;
		move.l	save_stack,-(sp)			;
		move.w	#32,-(sp)				;
		trap	#1					;
		addq.l	#6,sp					;

.no_sup:	tst.w	do_restore_dta				;Restore DTA
		beq.s	.no_dta					;
		bsr	restore_dta				;

.no_dta:	tst.w	do_restore_snd				;Unlock soundsystem
		beq.s	.no_snd					;
		bsr	unlocksnd				;

.no_snd:	tst.w	do_restore_dsp				;Unlock DSP
		beq.s	.no_dsp					;
		bsr	dsp_unlock				;
.no_dsp:

		bsr	keyboard_clear

.error:		tst.l	error_adr				;Error message to print?
		beq.s	.pterm					;no
		move.l	error_adr,d0				;Print error message
		bsr	cconws					;

		move.l	filename,d0				;Print filename
		bsr	cconws					;

		move.l	#text_nl,d0				;Newline
		bsr	cconws					;

		bsr	crawcin					;Wait key

.pterm:		clr.w	-(sp)					;pterm()
		trap	#1					;



; --------------------------------------------------------------
;		exit subroutines
; --------------------------------------------------------------


cconws:		move.l	d0,-(sp)				;cconws()
		move.w	#9,-(sp)				;
		trap	#1					;
		addq.l	#6,sp					;
		rts

crawcin:	move.w	#7,-(sp)				;crawcin()
		trap	#1					;
		addq.l	#2,sp					;
		rts						;

restore_click:	move.b	save_keymode,$484.w			;Restore keyclick
		rts

restore_ints:	move.w	sr,d0					;Save SR
		move.w	#$2700,sr				;Ints off
		move.l	save_vbl,$70.w				;VBL
		move.l	save_timer_d,$110.w			;Timer D
		lea	save_mfp,a0				;MFP regs
		move.b	(a0)+,$fffffa09.w			;
		move.b	(a0)+,$fffffa15.w			;
		move.b	(a0)+,$fffffa1d.w			;
		move.b	(a0)+,$fffffa25.w			;
		move.w	d0,sr					;Ints back
		rts
	

restore_video:	lea	save_video,a0				;Restore video
		clr.w   $ffff8266.w				;Falcon-shift clear
		move.l	(a0)+,$ffff8200.w			;Videobase_address:h&m
		move.w	(a0)+,$ffff820c.w			;L
		move.l	(a0)+,$ffff8282.w			;H-regs
		move.l	(a0)+,$ffff8286.w			;
		move.l	(a0)+,$ffff828a.w			;
		move.l	(a0)+,$ffff82a2.w			;V-regs
		move.l	(a0)+,$ffff82a6.w			;
		move.l	(a0)+,$ffff82aa.w			;
		move.w	(a0)+,$ffff82c0.w			;VCO
		move.w	(a0)+,$ffff82c2.w			;C_S
		move.l	(a0)+,$ffff820e.w			;Offset
		move.w	(a0)+,$ffff820a.w			;Sync
	        move.b  (a0)+,$ffff8265.w			;P_O
	        tst.b   (a0)+   				;ST(e) comptaible mode?
        	bne.s   .ok
		move.l	a0,-(sp)				;Wait for VBL
		move.w	#37,-(sp)				;To avoid syncerrors
		trap	#14					;In Falcon monomodes
		addq.l	#2,sp					;
		movea.l	(sp)+,a0				;
	       	move.w  (a0),$ffff8266.w			;Falcon-shift
		bra.s	.video_restored
.ok:		move.w  2(a0),$ffff8260.w			;ST-shift
		lea	save_video,a0
		move.w	32(a0),$ffff82c2.w			;C_S
		move.l	34(a0),$ffff820e.w			;Offset
.video_restored:
		lea	$ffff9800.w,a0				;Restore Falcon palette
		lea	save_pal,a1				;
		move.w	#256-1,d7				;
.loop:		move.l	(a1)+,(a0)+				;
		dbra	d7,.loop				;
		movem.l	(a1),d0-d7				;Restore ST palette
		movem.l	d0-d7,$ffff8240.w			;
		rts


restore_dta:	move.l	save_dta,-(sp)				;fsetdta() restore dta
		move.w	#$1a,-(sp)				;
		trap	#1					;
		addq.l	#6,sp					;
		rts

dsp_unlock:	move.w	#$69,-(sp)				;Dsp_Unlock()
		trap	#14					;
		addq.l	#2,sp					;
		rts


unlocksnd:	move.w	#$81,-(sp)				;Unlocksnd()
		trap	#14					;
		addq.l	#2,sp					;
		rts						;

debug:		move.l	#debugtxt,d0
		bsr	cconws
		rts

keyboard_clear:	move.w	#2,-(sp)				;Bios #1
		move.w	#1,-(sp)				;Check status
		trap	#13					;of buffer
		addq.l	#4,sp					;
		cmp.l	#0,d0					;if 0 = empty
		beq.s	.ok					;
		move.w	#2,-(sp)				;bios #2
		move.w	#2,-(sp)				;Remove one char
		trap	#13					;from buffer
		addq.l	#4,sp					;
		bra.s	keyboard_clear				;Check again
.ok:		rts




		section	text
