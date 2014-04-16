; Falcon demosystem
;
; init.s

		section	text

begin:

; --------------------------------------------------------------
;		Reserve stackspace and leave back memory
; --------------------------------------------------------------

		move.l	4(sp),a5				;Address to basepage
		move.l	$0c(a5),d0				;Length of text segment
		add.l	$14(a5),d0				;Length of data segment
		add.l	$1c(a5),d0				;Length of bss segment
		add.l	#$1000+100,d0				;Length of stackpointer+basepage
		move.l	a5,d1					;Address to basepage
		add.l	d0,d1					;End of program
		and.l	#-2,d1					;Make address even
		move.l	d1,sp					;New stackspace

		move.l	d0,-(sp)				;mshrink()
		move.l	a5,-(sp)				;
		clr.w	-(sp)					;
		move.w	#$4a,-(sp)				;
		trap	#1					;
		lea	12(sp),sp				;

; --------------------------------------------------------------
monitor_test:
; --------------------------------------------------------------

		move.w	#$59,-(sp)				;VgetMonitor()
		trap	#14					;
		addq.l	#2,sp					;

		tst.w	d0					;Mono
		bne.s	.vga					;ok
		move.l	#exit_mono_text,error_adr		;Error message (mono)
		bra	exit					;

.vga:		cmp.w	#2,d0					;VGA
		bne.s	.ok					;
		clr.w	monitor					;
		bra.s	.ok

.rgb:		move.w	#1,monitor				;RGB/TV
.ok:

; --------------------------------------------------------------
audio_test:
; --------------------------------------------------------------

		move.w	#$68,-(sp)				;Dsp_Lock()
		trap	#14					;
		addq.l	#2,sp					;
		
		tst.w	d0					;DSP locked?
		beq.s	.dsplock				;no
		move.l	#exit_dsplocked_text,error_adr		;Error message (DSP busy)
		bra	exit					;

.dsplock:	move.w	#1,do_restore_dsp

		move.w	#$80,-(sp)				;Locksnd()
		trap	#14					;
		addq.l	#2,sp					;
		
		cmp.w	#1,d0					;Soundsystem lock
		beq.s	.sndlock				;ok
		move.l	#exit_sndlocked_text,error_adr		;Error message (soundsystem busy)
		bra	exit					;

.sndlock:	move.w	#1,do_restore_snd



; --------------------------------------------------------------
init_screens:
; --------------------------------------------------------------

		clr.w	-(sp)					;Mxalloc()
		move.l	#scr_w*scr_h*scr_d*3+256,-(sp)		;Size of all screens
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;


		tst.l	d0					;RAM-check
		bne.s	.makeeven				;ok
		move.l	#exit_nostram_text_screen,error_adr	;Error message (not enough memory)
		bra	exit					;

.makeeven:	add.l	#256,d0					;Make screen address even
		clr.b	d0					;

		move.l	d0,screen_adr1				;Screen 1

		add.l	#scr_w*scr_h*scr_d,d0			;Screen 2
		move.l	d0,screen_adr2				;

		add.l	#scr_w*scr_h*scr_d,d0			;Screen 3
		move.l	d0,screen_adr3				;


; --------------------------------------------------------------
init_dta:
; --------------------------------------------------------------

		move.w	#$2f,-(sp)				;fgetdta()
		trap	#1					;Save old dta
		addq.l	#2,sp					;
		move.l	d0,save_dta				;

		move.l	#dta,-(sp)				;fsetdta()
		move.w	#$1a,-(sp)				;Set new dta
		trap	#1					;
		addq.l	#6,sp					;

		move.w	#1,do_restore_dta

; --------------------------------------------------------------
enter_supervisor:
; --------------------------------------------------------------

		clr.l	-(sp)					;super()
		move.w	#$20,-(sp)				;
		trap	#1					;
		addq.l	#6,sp					;
		move.l	d0,save_stack				;

		move.w	#1,do_restore_sup

; --------------------------------------------------------------
init_video:
; --------------------------------------------------------------

		lea	$ffff9800.w,a0				;Save Falcon palette
		lea	save_pal,a1				;

		move.w	#256-1,d7				;
.pal:		move.l	(a0)+,(a1)+				;
		dbra	d7,.pal					;

		movem.l	$ffff8240.w,d0-d7			;Save ST palette
		movem.l	d0-d7,(a1)				;

		lea	save_video,a0				;Store videomode
		move.l	$ffff8200.w,(a0)+			;vidhm
		move.w	$ffff820c.w,(a0)+			;vidl
		move.l	$ffff8282.w,(a0)+			;h-regs
		move.l	$ffff8286.w,(a0)+			;
		move.l	$ffff828a.w,(a0)+			;
		move.l	$ffff82a2.w,(a0)+			;v-regs
		move.l	$ffff82a6.w,(a0)+			;
		move.l	$ffff82aa.w,(a0)+			;
		move.w	$ffff82c0.w,(a0)+			;vco
		move.w	$ffff82c2.w,(a0)+			;c_s
		move.l	$ffff820e.w,(a0)+			;offset
		move.w	$ffff820a.w,(a0)+			;sync
		move.b  $ffff8265.w,(a0)+			;p_o
		clr.b   (a0)					;test of st(e) or falcon mode
		cmp.w   #$b0,$ffff8282.w			;hht kleiner $b0?
		sle     (a0)+					;flag setzen
		move.w	$ffff8266.w,(a0)+			;f_s
		move.w	$ffff8260.w,(a0)+			;st_s

		move.l	screen_adr2,d0				;Set screen
		move.l	d0,d1					;
		lsr.w	#8,d0					;
		move.l	d0,$ffff8200.w				;
		move.b	d1,$ffff820d.w				;

		move.w	#1,do_restore_gfx

; --------------------------------------------------------------
init_keyclick:
; --------------------------------------------------------------

		move.b	$484.w,save_keymode			;Save keyclick
		bclr	#0,$484					;Keyclick off

		move.w	#1,do_restore_key


; --------------------------------------------------------------
init_mouse:
; --------------------------------------------------------------

	ifne	mouse
		bsr	mouse_init
		move.w	#1,do_restore_mouse
	endc


; --------------------------------------------------------------
run_user_inits:
; --------------------------------------------------------------

		lea	inits,a0				;Init list
.again:		move.l	(a0)+,a1				;
		tst.l	a1					;
		beq.s	.done					;
		move.l	a0,-(sp)				;
		jsr	(a1)					;
		move.l	(sp)+,a0				;
		bra.s	.again					;
.done:								;

		jsr	clear_all_screens			;

; --------------------------------------------------------------
init_music:
; --------------------------------------------------------------

		jsr	music_init


; --------------------------------------------------------------
init_mfp:
; --------------------------------------------------------------

		move.w	sr,d0					;Save SR
		move.w	#$2700,sr				;Ints off

		lea	save_mfp,a0				;Save mfp
		move.b	$fffffa09.w,(a0)+			;
		move.b	$fffffa15.w,(a0)+			;
		move.b	$fffffa1d.w,(a0)+			;
		move.b	$fffffa25.w,(a0)+			;

		bset	#4,$fffffa09.w				;Timer D
		bset	#4,$fffffa15.w				;
		or.b	#%111,$fffffa1d.w			;%111 = Divide by 200
		move.b	#41,$fffffa25.w				;2457600/200/41 Approx 300 Hz

		move.l	$110.w,save_timer_d			;Save Timer D vector
		move.l	#timer_d,$110.w				;Own Timer D

		move.l	$70.w,save_vbl				;Save VBL vector
		move.l	#vbl,$70.w				;Own VBL

		move.w	d0,sr					;Ints back


		move.w	#1,do_restore_mfp
