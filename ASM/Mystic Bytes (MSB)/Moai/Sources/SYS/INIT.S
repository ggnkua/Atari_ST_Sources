; Init routines

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

begin:

; ------------------------------------------------------
;		reserve stackspace and leave back memory
; ------------------------------------------------------

		movea.l	4(sp),a5			; address to basepage
		move.l	a5,d0
		;add.l	#129,d0				; offset to command line
		;move.l	d0,file_list			; fill the address for m3d path
		move.l	$0c(a5),d0			; length of text segment
		add.l	$14(a5),d0			; length of data segment
		add.l	$1c(a5),d0			; length of bss segment
		add.l	#$1000+$100,d0			; length of stackpointer+basepage
		move.l	a5,d1				; address to basepage
		add.l	d0,d1				; end of program
		and.b	#%11111100,d1			; make address long even
		movea.l	d1,sp				; new stackspace

		move.l	d0,-(sp)			; mshrink()
		move.l	a5,-(sp)			;
		clr.w	-(sp)				;
		move.w	#$4a,-(sp)			;
		trap	#1				;
		lea	12(sp),sp			;
		
; ------------------------------------------------------
;		check the CPU
; ------------------------------------------------------

		move.l	#check_cpu,-(sp)
		move.w	#$26,-(sp)			; Superexec()
		trap	#14
		addq.l	#6,sp
		
		cmpi.l	#030,cpu_type
		bhs.b	.cpu_ok
		move.l	#bad_cpu_text,error_adr
		bra.w	exit

.cpu_ok:
		
; ------------------------------------------------------
;		audio/dsp testings
; ------------------------------------------------------

		IFEQ	debug
		IFNE	DSP_OS
		move.w	#$68,-(sp)			; Dsp_Lock()
		trap	#14				;
		addq.l	#2,sp				;
		
		tst.w	d0				; dsp locked?
		beq.b	.dsplock			; ok
		move.l	#exit_dsplocked_text,error_adr	; error message
		bra.w	exit				;

.dsplock:	st	run_dsplock
		ENDC

		IFNE	earxplay
		move.w	#$80,-(sp)			; Locksnd()
		trap	#14				;
		addq.l	#2,sp				;
		
		cmp.l	#1,d0				; soundsystem lock
		beq.b	.sndlock			; ok
		move.l	#exit_sndlocked_text,error_adr	; error message
		bra.w	exit				;

.sndlock:	st	run_locksnd
		ENDC
		ENDC
		
; ------------------------------------------------------
;		install dsp stuff
; ------------------------------------------------------

		IFNE	DSP_OS
		lea	dsp_engine,a0
		move.l	#(dsp_engine_end-dsp_engine)/3,d0
		bsr.w	dsp_load_program		; use NoCrew's one
		tst.l	d0
		bne.b	.dsp_ok
		move.l	#bad_p56_text,error_adr
		bra.w	exit

.dsp_ok:	move.l	#check_dsp_alive,-(sp)
		move.w	#$26,-(sp)			; Superexec()
		trap	#14
		addq.l	#6,sp
		ENDC

; ------------------------------------------------------
;		monitor test
; ------------------------------------------------------

		move.w	#$59,-(sp)			; VgetMonitor()
		trap	#14				;
		addq.l	#2,sp				;

		tst.w	d0				; mono
		bne.b	.vga				; ok
		move.l	#exit_mono_text,error_adr	; error message
		bra.w	exit				;
		
.vga:		cmp.w	#2,d0				; vga
		beq.b	.ok				;

		move.w	#1,monitor			; rgb/tv
.ok:

; ------------------------------------------------------
;		initiate workscreens
; ------------------------------------------------------

		clr.w	-(sp)				; Mxalloc()
		move.l	#SCR_W*SCR_H*SCR_D*3+256,-(sp)	; size of all screens
		move.w	#$44,-(sp)			;
		trap	#1				;
		addq.l	#8,sp				;

		tst.l	d0				; ramcheck
		bne.b	.makeeven			; ok
		move.l	#exit_nostram_text,error_adr	; error message
		bra.w	exit				;

.makeeven:	add.l	#256,d0				; make even address
		clr.b	d0				;

		move.l	#SCR_W*SCR_H*SCR_D,d1		; screensize
		lea	screen_adr1,a0			; screen addresses
		
		move.l	d0,a1				; for clear screens

		move.l	d0,(a0)+			; screen_adr
		add.l	d1,d0				;
		move.l	d0,(a0)+			; screen_adr2
		add.l	d1,d0				;
		move.l	d0,(a0)				; screen_adr3

		move.w	#SCR_H*3-1,d7			; clear screens
.y:		move.w	#SCR_W*SCR_D/4-1,d6		;
.x:		clr.l	(a1)+				;
		dbra	d6,.x				;
		dbra	d7,.y				;

; ------------------------------------------------------
;		dta save/init
; ------------------------------------------------------

		move.w	#$2f,-(sp)			; fgetdta()
		trap	#1				; save old dta
		addq.l	#2,sp				;
		move.l	d0,save_dta			;

		move.l	#dta,-(sp)			; fsetdta()
		move.w	#$1a,-(sp)			; set new dta
		trap	#1				;
		addq.l	#6,sp				;

		st	run_getdta
		
; ------------------------------------------------------
;		supervisor
; ------------------------------------------------------

		clr.l	-(sp)				; super()
		move.w	#$20,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;
		move.l	d0,save_stack			;

		st	run_supervisor

; ------------------------------------------------------
;		video save
; ------------------------------------------------------

		move.w	#$25,-(sp)			; Vsync()
		trap	#14				; avoids cracks by
		addq.l	#2,sp				; palette access

		lea	$ffff9800.w,a0			; save falcon palette
		lea	save_pal,a1			;
		moveq	#128-1,d7			;
.loop:		move.l	(a0)+,(a1)+			;
		move.l	(a0)+,(a1)+			;
		dbra	d7,.loop			;

		movem.l	$ffff8240.w,d0-d7		; save st palette
		movem.l	d0-d7,(a1)			;

store_video:	lea	save_video,a0
		move.l	$ffff8200.w,(a0)+		; vidhm
		move.w	$ffff820c.w,(a0)+		; vidl
		
		move.l	$ffff8282.w,(a0)+		; h-regs
		move.l	$ffff8286.w,(a0)+		;
		move.l	$ffff828a.w,(a0)+		;
		
		move.l	$ffff82a2.w,(a0)+		; v-regs
		move.l	$ffff82a6.w,(a0)+		;
		move.l	$ffff82aa.w,(a0)+		;
		
		move.w	$ffff82c0.w,(a0)+		; vco
		move.w	$ffff82c2.w,(a0)+		; c_s
		
		move.l	$ffff820e.w,(a0)+		; offset
		move.w	$ffff820a.w,(a0)+		; sync
		
		move.b  $ffff8256.w,(a0)+		; p_o
		
		;move.w	$ffff8282.w,d0			; st(e) / falcon test
		;subi.w	#9,d0				;
		;cmp.w	$ffff828c,d0			; if hss < hht + 1 - 10
		cmpi.w   #$b0,$ffff8282.w		; hht kleiner $b0?
		sle	(a0)+				; it's a falcon resolution
		
		move.w	$ffff8266.w,(a0)+		; f_s
		move.w	$ffff8260.w,(a0)+		; st_s
		
		st	run_setvideo
		
; ------------------------------------------------------
;		save / remove keyclick
; ------------------------------------------------------

		move.b	$484.w,save_keymode		; save keyclick
		bclr	#0,$484				; keyclick off
		
		st	run_keyclick

; ------------------------------------------------------
;		save cache settings
; ------------------------------------------------------

		movec	cacr,d0
		move.l	d0,save_cacr
		
		st	run_cache
		
; ------------------------------------------------------
;		set new videoram
; ------------------------------------------------------

		IFEQ	debug
		move.l	screen_adr1,d0
		move.l	d0,d1
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w
		move.b	d1,$ffff820d.w
		ENDC

; ------------------------------------------------------
;		run the init-list
; ------------------------------------------------------

		lea	inits,a0			; init list
.again:		move.l	(a0)+,a1			;
		tst.l	a1				;
		beq.b	.done				;
		move.l	a0,-(sp)			;
		jsr	(a1)				;
		move.l	(sp)+,a0			;
		bra.b	.again				;
.done:

; ------------------------------------------------------
;		init timer-d & vbl
; ------------------------------------------------------

		IFEQ	debug
		move	sr,d0				; save sr
		ori	#$0700,sr			; ints off
		
		lea	save_mfp,a0			; save mfp
		move.b	$fffffa09.w,(a0)+		;
		move.b	$fffffa15.w,(a0)+		;
		move.b	$fffffa1d.w,(a0)+		;
		move.b	$fffffa25.w,(a0)+		;

		bset	#4,$fffffa09.w			; timer-d
		bset	#4,$fffffa15.w			;
		or.b	#%111,$fffffa1d.w		; %111 = divide by 200
		move.b	#41,$fffffa25.w			; 2457600/200/41 approx 300 Hz

		move.l	$110.w,save_timer_d		; save timer-d vector
		move.l	#timer_d,$110.w			; own timer-d

		move.l	$70.w,save_vbl			; save vbl vector
		move.l	#vbl,$70.w			; own vbl
		
		move	d0,sr				; ints back
		st	run_ints
		ENDC

; ------------------------------------------------------
;		init start value for fps counter
; ------------------------------------------------------

		IFNE	fps
		move.l	$04BA.w,starttime
		st	run_fps
		ENDC