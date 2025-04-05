; Falcon demoshell
; February 8, 2004
; Updated June 17, 2006
;
; Anders Eriksson
; ae@dhs.nu
;
; init.s
		section	text

begin:

; --------------------------------------------------------------
;		reserve stackspace and leave back memory
; --------------------------------------------------------------

		move.l	4(sp),a5				;address to basepage
		move.l	$0c(a5),d0				;length of text segment
		add.l	$14(a5),d0				;length of data segment
		add.l	$1c(a5),d0				;length of bss segment
		add.l	#$1000+100,d0				;length of stackpointer+basepage
		move.l	a5,d1					;address to basepage
		add.l	d0,d1					;end of program
		and.l	#-2,d1					;make address even
		move.l	d1,sp					;new stackspace

		move.l	d0,-(sp)				;mshrink()
		move.l	a5,-(sp)				;
		clr.w	-(sp)					;
		move.w	#$4a,-(sp)				;
		trap	#1					;
		lea.l	12(sp),sp				;


; --------------------------------------------------------------
;		audio/dsp testings
; --------------------------------------------------------------

		move.w	#$68,-(sp)				;Dsp_Lock()
		trap	#14					;
		addq.l	#2,sp					;
		
		tst.w	d0					;dsp locked?
		beq.s	.dsplock				;ok
		move.l	#exit_dsplocked_text,error_adr		;error message
		bra.w	exit					;

.dsplock:	addq.w	#1,runlevel				;1 restore dsp_lock


		move.w	#$80,-(sp)				;Locksnd()
		trap	#14					;
		addq.l	#2,sp					;
		
		cmp.w	#1,d0					;soundsystem lock
		beq.s	.sndlock				;ok
		move.l	#exit_sndlocked_text,error_adr		;error message
		bra.w	exit					;

.sndlock:	addq.w	#1,runlevel				;2 restore locksnd



; --------------------------------------------------------------
;		monitor test
; --------------------------------------------------------------

		move.w	#$59,-(sp)				;VgetMonitor()
		trap	#14					;
		addq.l	#2,sp					;

		tst.w	d0					;mono
		bne.s	.vga					;ok
		move.l	#exit_mono_text,error_adr		;error message
		bra.w	exit					;
		
.vga:		cmp.w	#2,d0					;vga
		beq.s	.ok					;

		move.w	#1,monitor				;rgb/tv
.ok:


; --------------------------------------------------------------
;		demo gem/text init
; --------------------------------------------------------------

		addq.w	#1,runlevel				;3 restore gem

		ifne	startupmenu
		bsr.w	startup
		endc



; --------------------------------------------------------------
;		initiate workscreens
; --------------------------------------------------------------

		clr.w	-(sp)					;Mxalloc()
		move.l	#scr_w*scr_h*scr_d*3+256,-(sp)		;size of all screens
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;ramcheck
		bne.s	.makeeven				;ok
		move.l	#exit_nostram_text,error_adr		;error message
		bra.w	exit					;

.makeeven:	add.l	#256,d0					;make even address
		clr.b	d0					;

		move.l	#scr_w*scr_h*scr_d,d1			;screensize
		lea.l	screen_adr1,a0				;screen addresses
		
		move.l	d0,a1					;for clear screens
		move.l	d0,(a0)+				;screen_adr
		add.l	d1,d0					;
		move.l	d0,(a0)+				;screen_adr2
		add.l	d1,d0					;
		move.l	d0,(a0)					;screen_adr3

		move.w	#scr_h*3-1,d7				;clear screens
.y:		move.w	#scr_w*scr_d/4-1,d6			;
.x:		clr.l	(a1)+					;
		dbra	d6,.x					;
		dbra	d7,.y					;




; --------------------------------------------------------------
;		dta save/init
; --------------------------------------------------------------


		move.w	#$2f,-(sp)				;fgetdta()
		trap	#1					;save old dta
		addq.l	#2,sp					;
		move.l	d0,save_dta				;

		move.l	#dta,-(sp)				;fsetdta()
		move.w	#$1a,-(sp)				;set new dta
		trap	#1					;
		addq.l	#6,sp					;

		addq.w	#1,runlevel				;4 restore dta


; --------------------------------------------------------------
;		supervisor
; --------------------------------------------------------------


		clr.l	-(sp)					;super()
		move.w	#$20,-(sp)				;
		trap	#1					;
		addq.l	#6,sp					;
		move.l	d0,save_stack				;

		addq.w	#1,runlevel				;5 restore super


; --------------------------------------------------------------
;		video save / init
; --------------------------------------------------------------


		lea.l	$ffff9800.w,a0				;save falcon palette
		lea.l	save_pal,a1				;
		move.w	#256-1,d7				;
.colloop:	move.l	(a0)+,(a1)+				;
		dbra	d7,.colloop				;

		movem.l	$ffff8240.w,d0-d7			;save st palette
		movem.l	d0-d7,(a1)				;

		lea.l	save_video,a0				;store videomode
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
		move.b  $ffff8256.w,(a0)+			;p_o
		clr.b   (a0)					;test of st(e) or falcon mode
		cmp.w   #$b0,$ffff8282.w			;hht kleiner $b0?
		sle     (a0)+					;flag setzen
		move.w	$ffff8266.w,(a0)+			;f_s
		move.w	$ffff8260.w,(a0)+			;st_s



		move.l	screen_adr2,d0				;set screen
		move.b	d0,d1					;
		lsr.w   #8,d0					;
		move.b  d0,$ffff8203.w				;
		swap    d0					;
		move.b  d0,$ffff8201.w				;
		move.b  d1,$ffff820d.w				;

		addq.w	#1,runlevel				;6 restore video



; --------------------------------------------------------------
;		save / remove keyclick
; --------------------------------------------------------------

		move.b	$484.w,save_keymode			;save keyclick
		bclr	#0,$484					;keyclick off
		addq.w	#1,runlevel				;7 restore keyclick


; --------------------------------------------------------------
;		run the init-list
; --------------------------------------------------------------


		lea.l	inits,a0				;init list
.again:		move.l	(a0)+,a1				;
		tst.l	a1					;
		beq.s	.done					;
		move.l	a0,-(sp)				;
		jsr	(a1)					;
		move.l	(sp)+,a0				;
		bra.s	.again					;
.done:								;

		addq.w	#1,runlevel				;8 restore sound


; --------------------------------------------------------------
;		init timer-d and vbl
; --------------------------------------------------------------

		addq.w	#1,runlevel				;9 restore interupts

		move.w	sr,d0					;save sr
		move.w	#$2700,sr				;ints off

		ifeq	aranym
		lea.l	save_mfp,a0				;save mfp
		move.b	$fffffa09.w,(a0)+			;
		move.b	$fffffa15.w,(a0)+			;
		move.b	$fffffa1d.w,(a0)+			;
		move.b	$fffffa25.w,(a0)+			;

		bset	#4,$fffffa09.w				;timer-d
		bset	#4,$fffffa15.w				;
		or.b	#%111,$fffffa1d.w			;%111 = divide by 200
		move.b	#41,$fffffa25.w				;2457600/200/41 approx 300 Hz

		move.l	$110.w,save_timer_d			;save timer-d vector
		move.l	#timer_d,$110.w				;own timer-d
		endc

		move.l	$70.w,save_vbl				;save vbl vector
		move.l	#vbl,$70.w				;own vbl

		move.w	d0,sr					;ints back
