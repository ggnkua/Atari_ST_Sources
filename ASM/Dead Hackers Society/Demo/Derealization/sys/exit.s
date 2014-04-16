; Falcon demoshell
; February 3, 2000
; Updated June 17, 2006
;
; Anders Eriksson
; ae@dhs.nu
;
; exit.s


; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------



;---------------------------------------------------------------
;		runlevel based exit
;---------------------------------------------------------------


exit:		cmp.w	#9,runlevel				;9=interupts
		blt.s	.r8					;next
		bsr.w	restore_ints				;restore interups
;---------------------------------------------------------------
.r8:		cmp.w	#8,runlevel				;8=music
		blt.s	.r7					;next
		nop						;
		ifne	dspmodmusic				;
		bsr.w	dspmod_end				;restore dspmod
		endc						;
		ifne	mp2music				;
		bsr.w	mp2_end					;restore mp2
		endc						;
		ifne	acemusic				;
		bsr.w	ace_stop				;restore ace
		endc						;
;---------------------------------------------------------------
.r7:		cmp.w	#7,runlevel				;7=keyklick
		blt.s	.r6					;next
		bsr.w	restore_click				;restore keyclick
;---------------------------------------------------------------
.r6:		cmp.w	#6,runlevel				;6=video
		blt.s	.r5					;next
		ifne	screenshot
		bsr.w	screenshot_snapit
		endc
		bsr.w	restore_video				;restore video
;---------------------------------------------------------------
.r5:		cmp.w	#5,runlevel				;5=supervisor
		blt.s	.r4					;next
		move.l	save_stack,-(sp)			;exit supervisor
		move.w	#32,-(sp)				;
		trap	#1					;
		addq.l	#6,sp					;
;---------------------------------------------------------------
.r4:		cmp.w	#4,runlevel				;4=dta
		blt.s	.r3					;next
		bsr.w	restore_dta
;---------------------------------------------------------------
.r3:								;3=gem (unused)
;---------------------------------------------------------------
.r2:		cmp.w	#2,runlevel				;2=Locksnd()
		blt.s	.r1					;next
		bsr.w	unlocksnd				;unlock soundsystem
;---------------------------------------------------------------
.r1:		cmp.w	#1,runlevel				;1=Dsp_Lock()
		blt.s	.clrkbd					;next
		bsr.w	dsp_unlock				;unlock the dsp
;---------------------------------------------------------------

.clrkbd:	bsr.w	clear_kbd				;clear kbd buffer


.printfile:	tst.l	filename				;see if print filename
		beq.s	.print_error				;
		move.l	filename,d0				;print filename
		bsr.w	cconws					;

.print_error:	tst.l	error_adr				;see if print error message
		beq.w	.pterm					;
		move.l	error_adr,d0				;print error message
		bsr.w	cconws					;

		bsr.w	crawcin					;wait key

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

clear_kbd:	move.w	#2,-(sp)				;bconstat()
		move.w	#1,-(sp)				;
		trap	#13					;
		addq.l	#4,sp					;
		tst.l	d0					;
		beq.s	.ok					;
		move.w	#2,-(sp)				;bconin()
		move.w	#2,-(sp)				;
		trap	#13					;
		addq.l	#4,sp					;
		bra.s	clear_kbd				;
.ok:		rts						;

crawcin:	move.w	#7,-(sp)				;crawcin()
		trap	#1					;
		addq.l	#2,sp					;
		rts						;

restore_click:	move.b	save_keymode,$484.w			;restore keyclick
		rts

restore_ints:	move.w	sr,d0					;save sr
		move.w	#$2700,sr				;ints off
		move.l	save_vbl,$70.w				;vbl
		ifeq	aranym
		move.l	save_timer_d,$110.w			;timer_d
		lea.l	save_mfp,a0				;mfp regs
		move.b	(a0)+,$fffffa09.w			;
		move.b	(a0)+,$fffffa15.w			;
		move.b	(a0)+,$fffffa1d.w			;
		move.b	(a0)+,$fffffa25.w			;
		endc
		move.w	d0,sr					;ints back
		rts
	

restore_video:	lea.l	save_video,a0				;restore video
		clr.w   $ffff8266.w				;falcon-shift clear
		move.l	(a0)+,$ffff8200.w			;videobase_address:h&m
		move.w	(a0)+,$ffff820c.w			;l
		move.l	(a0)+,$ffff8282.w			;h-regs
		move.l	(a0)+,$ffff8286.w			;
		move.l	(a0)+,$ffff828a.w			;
		move.l	(a0)+,$ffff82a2.w			;v-regs
		move.l	(a0)+,$ffff82a6.w			;
		move.l	(a0)+,$ffff82aa.w			;
		move.w	(a0)+,$ffff82c0.w			;vco
		move.w	(a0)+,$ffff82c2.w			;c_s
		move.l	(a0)+,$ffff820e.w			;offset
		move.w	(a0)+,$ffff820a.w			;sync
	        move.b  (a0)+,$ffff8256.w			;p_o
	        tst.b   (a0)+   				;st(e) comptaible mode?
        	bne.s   .ok
		move.l	a0,-(sp)				;wait for vbl
		move.w	#37,-(sp)				;to avoid syncerrors
		trap	#14					;in falcon monomodes
		addq.l	#2,sp					;
		movea.l	(sp)+,a0				;
	       	move.w  (a0),$ffff8266.w			;falcon-shift
		bra.s	.video_restored
.ok:		move.w  2(a0),$ffff8260.w			;st-shift
		lea.l	save_video,a0
		move.w	32(a0),$ffff82c2.w			;c_s
		move.l	34(a0),$ffff820e.w			;offset		
.video_restored:
		lea.l	$ffff9800.w,a0				;restore falcon palette
		lea.l	save_pal,a1				;
		move.w	#256-1,d7				;
.loop:		move.l	(a1)+,(a0)+				;
		dbra	d7,.loop				;
		movem.l	(a1),d0-d7				;restore st palette
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



; --------------------------------------------------------------
		section	data
; --------------------------------------------------------------

		even

error_adr:	ds.l	1

exit_nostram_text:
		dc.b	13,10
		dc.b	"Sorry, you don't have enough free ST-RAM",13,10
		dc.b	"to run this demo.",13,10,13,10
		dc.b	"Press any key to exit.",13,10,0
		even

exit_mono_text:	dc.b	13,10
		dc.b	"Sorry, this demo does not work with",13,10
		dc.b	"monochrome monitors.",13,10,13,10
		dc.b	"Press any key to exit.",13,10,0
		even

exit_dsplocked_text:
		dc.b	13,10
		dc.b	"The DSP is already in use by anohter",13,10
		dc.b	"application.",13,10,13,10
		dc.b	"Press any key to exit.",13,10,0
		even

exit_sndlocked_text:
		dc.b	13,10
		dc.b	"The Falcon audio subsystem already in",13,10
		dc.b	"use by another application.",13,10,13,10
		dc.b	"Press any key to exit.",13,10,0
		even

		ifne	dspmodmusic
exit_nomodram_text:
		dc.b	13,10
		dc.b	"Sorry, you don't have enough free",13,10
		dc.b	"ST-RAM or TT-RAM to run this demo.",13,10,13,10
		dc.b	"Press any key to exit.",13,10,0
		even
		endc

exit_musicnotfound_text:
		dc.b	13,10
		dc.b	"Sorry, the musicfile was not found.",13,10,13,10
		dc.b	"Press any key to exit.",13,10,0
		even

exit_filenotfound_text:
		dc.b	13,10
		dc.b	"Sorry, the file was not found.",13,10,13,10
		dc.b	"Press any key to exit.",13,10,0
		even


; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------
