; Exit routines

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

exit:		tst.b	run_ints
		bpl.b	.r1
		bsr.w	restore_ints
		
.r1:		
		IFNE	earxplay
		tst.b	run_player
		bpl.b	.r2
		bsr.w	earx_end
		ENDC
		
.r2:		tst.b	run_cache
		bpl.b	.r3
		bsr.w	restore_cache
		
.r3:		tst.b	run_keyclick
		bpl.b	.r4
		bsr.w	restore_click
		
.r4:		bsr.w	flush_keyboard

		tst.b	run_setvideo
		bpl.b	.r5
		bsr.w	restore_video
		
.r5:		tst.b	run_supervisor
		bpl.b	.r6

		move.l	save_stack,-(sp)		; exit supervisor
		move.w	#$20,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;
		
.r6:		tst.b	run_getdta
		bpl.b	.r7
		bsr.w	restore_dta
		
.r7:		tst.b	run_locksnd
		bpl.b	.r8
		bsr.w	unlocksnd
		
.r8:		tst.b	run_dsplock
		bpl.b	.fps
		bsr.w	dsp_unlock

.fps:
		IFNE	fps
		tst.b	run_fps
		bpl.b	.nofps
		bsr.w	fps_print
.nofps:
		ENDC

		tst.l	error_adr			; see if print error message
		beq.b	.pterm
		
		move.l	error_adr,d0
		bsr.w	cconws
		
		bsr.w	crawcin				; wait key
		
.pterm:		clr.w	-(sp)				; pterm()
		trap	#1				;

; ------------------------------------------------------
;		exit subroutines
; ------------------------------------------------------

cconws:		move.l	d0,-(sp)			; Cconws()
		move.w	#9,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;
		rts					;

crawcin:	move.w	#7,-(sp)			; Crawcin()
		trap	#1				;
		addq.l	#2,sp				;
		rts					;

restore_cache:	cmpi.l	#030,cpu_type
		bhi.b	.not_030
		move.l	save_cacr,d0
		bset	#11,d0				; clear data cache
		bset	#3,d0				; clear inst cache
		movec	d0,cacr
.not_030:	rts

flush_keyboard:

.read_key:	move.w	#11,-(sp)			; Cconis()
		trap	#1
		addq.l	#2,sp

		tst.w	d0
		beq.b	.empty

		move.w	#8,-(sp)			; Cnecin()
		trap	#1
		addq.l	#2,sp
		bra.b	.read_key

.empty:		rts

restore_click:	move.b	save_keymode,$484.w		; restore keyclick
		rts					;

restore_ints:	move	sr,d0				; save sr
		ori	#$0700,sr			; ints off
		
		move.l	save_vbl,$70.w			; vbl
		
		move.l	save_timer_d,$110.w		; timer_d
		lea	save_mfp,a0			; mfp regs
		move.b	(a0)+,$fffffa09.w		;
		move.b	(a0)+,$fffffa15.w		;
		move.b	(a0)+,$fffffa1d.w		;
		move.b	(a0)+,$fffffa25.w		;
		
		move	d0,sr				; ints back
		rts

restore_video:	bsr.w	wait_vbl

		lea	save_video,a0
		
		move.l	(a0)+,$ffff8200.w		; videobase_address:h&m
		move.w	(a0)+,$ffff820c.w		; l
		
		move.l	(a0)+,$ffff8282.w		; h-regs
		move.l	(a0)+,$ffff8286.w		;
		move.l	(a0)+,$ffff828a.w		;
		
		move.l	(a0)+,$ffff82a2.w		; v-regs
		move.l	(a0)+,$ffff82a6.w		;
		move.l	(a0)+,$ffff82aa.w		;
		
		move.w	(a0)+,$ffff82c0.w		; vco
		move.w	(a0)+,$ffff82c2.w		; c_s
		
		move.l	(a0)+,$ffff820e.w		; offset
		move.w	(a0)+,$ffff820a.w		; sync
	        
	        move.b  (a0)+,$ffff8256.w		; p_o
	        
	        tst.b   (a0)+   			; st(e) compatible mode?
        	bne.b   .ok				; yes
        	
		move.w  (a0),$ffff8266.w		; falcon-shift
		
		move.w  $ffff8266.w,-(sp)		; Videl patch
		bsr.w	wait_vbl			; to avoid monochrome
		clr.w   $ffff8266.w			; sync errors
		bsr.w	wait_vbl			; (ripped from
		move.w	(sp)+,$ffff8266.w		; FreeMiNT kernel)
	       	
		bra.b	.video_restored

.ok:		;clr.w	$ffff8266.w
		move.w	(a0)+,$ffff8266.w		; falcon-shift
		move.w  (a0),$ffff8260.w		; st-shift
		lea	save_video,a0
		move.w	32(a0),$ffff82c2.w		; c_s
		move.l	34(a0),$ffff820e.w		; offset		
.video_restored:

		lea	save_pal,a1			; restore falcon palette
		bsr.w	set_palette			;

		movem.l	(a1),d0-d7			; restore st palette
		movem.l	d0-d7,$ffff8240.w		;
		rts

restore_dta:	move.l	save_dta,-(sp)			; fsetdta() restore dta
		move.w	#$1a,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;
		rts

dsp_unlock:	move.w	#$69,-(sp)			; Dsp_Unlock()
		trap	#14				;
		addq.l	#2,sp				;
		rts


unlocksnd:	move.w	#$81,-(sp)			; Unlocksnd()
		trap	#14				;
		addq.l	#2,sp				;
		rts
		
wait_vbl:	move.l	a0,-(sp)			; Vsync()
		move.w	#$25,-(sp)			; 
		trap	#14				; 
		addq.l	#2,sp				;
		movea.l	(sp)+,a0			;
		rts


; ------------------------------------------------------
		SECTION	DATA
; ------------------------------------------------------

		EVEN

error_adr:	ds.l	1

		dc.b	"                                        "

exit_nostram_text:
		dc.b	13,10
		dc.b	"Not enough free ST-RAM to run the demo.",13,10
		dc.b	"[Any key to exit]",13,10,0
		even

exit_mono_text:	dc.b	13,10
		dc.b	"Monochrome mode detected.",13,10
		dc.b	"[Any key to exit]",13,10,0
		even

exit_dsplocked_text:
		dc.b	13,10
		dc.b	"The DSP is already in use by another",13,10
		dc.b	"application.",13,10
		dc.b	"[Any key to exit]",13,10,0
		even

exit_sndlocked_text:
		dc.b	13,10
		dc.b	"The Falcon audio subsystem already in",13,10
		dc.b	"use by another application.",13,10
		dc.b	"[Any key to exit]",13,10,0
		even

exit_noram_text:
		dc.b	13,10
		dc.b	"Not enough free RAM to run this demo.",13,10
		dc.b	"[Any key to exit]",13,10,0
		even

bad_p56_text:	dc.b	13,10
		dc.b	"Bad format of DSP binary file",13,10
		dc.b	"[Any key to exit]",13,10,0
		even
		
dead_dsp_text:	dc.b	13,10
		dc.b	"DSP is dead !",13,10
		dc.b	"[Any key to exit]",13,10,0
		even
		
bad_cpu_text:	dc.b	13,10
		dc.b	"The demo works on 68030 and higher only.",13,10
		dc.b	"[Any key to exit]",13,10,0
		
unexpected_text:
		dc.b	13,10
		dc.b	"Error in DSP communication!",13,10
		dc.b	"[Any key to exit]",13,10,0
		even
		
bad_m3d_text:	dc.b	13,10
		dc.b	"Bad format/version of M3D object!",13,10
		dc.b	"[Any key to exit]",13,10,0
		even

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------
