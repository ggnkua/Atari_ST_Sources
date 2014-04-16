; Atari ST/e synclock demosystem
; September 2, 2011
;
; sys/init.s

		section	text
init:

		move.l	4(sp),a5			;address to basepage
		move.l	$0c(a5),d0			;length of text segment
		add.l	$14(a5),d0			;length of data segment
		add.l	$1c(a5),d0			;length of bss segment
		add.l	#$100,d0			;length of basepage
		add.l	#$1000,d0			;length of stackpointer
		move.l	a5,d1				;address to basepage
		add.l	d0,d1				;end of program
		and.l	#-2,d1				;make address even
		move.l	d1,sp				;new stackspace

		move.l	d0,-(sp)			;mshrink()
		move.l	a5,-(sp)			;
		move.w	d0,-(sp)			;
		move.w	#$4a,-(sp)			;
		trap	#1				;
		lea	12(sp),sp			;

	ifne	show_infos				;
		move.l	#text_demosys,d0		;
		jsr	print				;
	endc

		move.l	#screensize*2+256,-(sp)		;Reserve screen memory
		move.w	#$48,-(sp)			;Malloc()
		trap	#1				;
		tst.l	d0				;
		beq	exit_pterm			;Not enough memory
		add.l	#256,d0				;
		clr.b	d0				;Even by 256
		move.l	d0,screen_adr			;
		move.l	d0,screen_adr_base		;
		add.l	#screensize,d0			;
		move.l	d0,screen_adr2			;

		jsr	clear_screens			;Clear workscreens

		clr.l	-(sp)				;Enter supervisor mode
		move.w	#32,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;
		move.l	d0,save_stack			;

		jsr	cookie_check			;Check _MCH and CT60

		cmp.l	#"TT  ",computer_type		;Check for TT and exit if true
		bne.s	.not_tt				;
	ifne	show_infos
		move.l	#text_tt,d0			;
		jsr	print				;
	endc
		bra	exit_super			;
.not_tt:						;

	ifeq	falcon_compat				;If not in Falcon compatible mode, exit if we're on a Falcon machine
		cmp.b	#"F",computer_type		;
		bne.s	.not_falcon			;
		ifne	show_infos			;
			move.l	#text_falcon,d0		;
			jsr	print			;
		endc					;
		bra	exit_super			;
.not_falcon:						;
	endc						;


	ifne	ste_demo				;Exit if ST machine (demo is for STe)
		cmp.l	#"ST  ",computer_type		;
		bne.s	.not_st				;
		ifne	show_infos			;
			move.l	#text_st,d0		;
			jsr	print			;
		endc					;
		bra	exit_super			;
.not_st:						;
	endc						;

	ifne	falcon_compat				;Setup Falcon specific video hardware
		cmp.b	#"F",computer_type		;
		bne.s	.st_setup			;
		jsr	falcon_save_video		;
		jsr	falcon_set_video		;
		bra.s	.st_done			;
	endc						;


.st_setup:	move.b	$ffff820a.w,save_refresh	;Save and set refreshrate
		or.b	#%00000010,$ffff820a.w		;

		bsr	xbios_vsync			;Save and set resolution
		move.b	$ffff8260.w,save_res		;
		clr.b	$ffff8260.w			;
.st_done:

		movem.l	$ffff8240.w,d0-d7		;Save palette
		movem.l	d0-d7,save_pal			;

		lea	save_screenadr,a0		;Save screenaddress
		move.b	$ffff8201.w,(a0)+		;
		move.b	$ffff8203.w,(a0)+		;
		move.b	$ffff820d.w,(a0)+		;

		move.l  screen_adr,d0			;Set screenaddress
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

	ifne	ste_demo
		move.b	$ffff8265.w,save_hscroll	;Save hscroll
		move.b	$ffff820f.w,save_lw		;Save linewidth
	endc

		cmp.l	#"MSTe",computer_type		;Check for Mega STe
		bne.s	.not_mste			;
		move.b	$ffff8e21.w,save_mste		;Save MSTe speed
		clr.b	$ffff8e21.w			;Set MSTe to 8 MHz no cache
.not_mste:

		move.b	$484.w,save_keymode		;Save and turn keyclick off
		bclr	#0,$484				;

		move.b	#$12,$fffffc02.w		;Kill mouse


;-------------- User + music init

		jsr	black_pal
		jsr	initlist			;Run user inits
		jsr	music_init			;Init music player

	ifne	show_infos
		move.l	#text_init,d0
		jsr	print
	endc


;--------------	Save vectors, MFP and start the demosystem
		move.w	#$2700,sr			;Stop interrupts

		move.l	usp,a0				;USP
		move.l	a0,save_usp			;
		
		move.l	$68.w,save_hbl			;HBL
		move.l	$70.w,save_vbl			;VBL
		move.l	$134.w,save_timer_a		;Timer-A
		move.l	$120.w,save_timer_b		;Timer-B
		move.l	$114.w,save_timer_c		;Timer-C
		move.l	$110.w,save_timer_d		;Timer-D
		move.l	$118.w,save_acia		;ACIA

		lea	save_mfp,a0			;Restore vectors and mfp
		move.b	$fffffa01.w,(a0)+		;// datareg
		move.b	$fffffa03.w,(a0)+		;Active edge
		move.b	$fffffa05.w,(a0)+		;Data direction
		move.b	$fffffa07.w,(a0)+		;Interrupt enable A
		move.b	$fffffa13.w,(a0)+		;Interupt Mask A
		move.b	$fffffa09.w,(a0)+		;Interrupt enable B
		move.b	$fffffa15.w,(a0)+		;Interrupt mask B
		move.b	$fffffa17.w,(a0)+		;Automatic/software end of interupt
		move.b	$fffffa19.w,(a0)+		;Timer A control
		move.b	$fffffa1b.w,(a0)+		;Timer B control
		move.b	$fffffa1d.w,(a0)+		;Timer C & D control
		move.b	$fffffa27.w,(a0)+		;Sync character
		move.b	$fffffa29.w,(a0)+		;USART control
		move.b	$fffffa2b.w,(a0)+		;Receiver status
		move.b	$fffffa2d.w,(a0)+		;Transmitter status
		move.b	$fffffa2f.w,(a0)+		;USART data

		move.l	#vbl,$70.w 			;Set VBL
	ifeq	music_sndh_fx
		move.l	#timer_a,$134.w			;Set Timer-A
	endc
		move.l	#timer_b,$120.w			;Set Timer-B
		move.l	#timer_c,$114.w			;Set Timer-C
		move.l	#timer_d,$110.w			;Set Timer-D
		move.l	#acia,$118.w			;Set ACIA

	ifne	music_ymdigi8
		move.l	#music_ymdigi8_timer,$68	;Set HBL to YM digi
	else
		move.l	#hbl,$68.w 			;Set HBL
	endc


		clr.b	$fffffa07.w			;Interrupt enable A (Timer-A & B)
		clr.b	$fffffa13.w			;Interrupt mask A (Timer-A & B)
		clr.b	$fffffa09.w			;Interrupt enable B (Timer-C & D)
		clr.b	$fffffa15.w			;Interrupt mask B (Timer-C & D)

		clr.b	$fffffa19.w			;Timer-A control (stop)
		clr.b	$fffffa1b.w			;Timer-B control (stop)
		clr.b	$fffffa1d.w			;Timer-C & D control (stop)

		bclr	#3,$fffffa17.w			;Automatic end of interrupt
		bset	#5,$fffffa07.w			;Interrupt enable A (Timer-A)
		bset	#5,$fffffa13.w			;Interrupt mask A

	ifne	music_ymdigi8
		move.w	#$2100,sr			;Enable interrupts with HBL for YM digi
	else
		move.w	#$2300,sr			;Enable interrupts
	endc


		section	text
