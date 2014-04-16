; Atari ST/e synclock demosystem
; March 27, 2010
;
; sys/exit.s


		section	text
exit:
		bsr.w	black_pal

		move.w	#$2700,sr			;Stop interrupts

		move.l	save_usp,a0			;USP
		move.l	a0,usp				;
		move.l	save_hbl,$68.w			;HBL
		move.l	save_vbl,$70.w			;VBL
		move.l	save_timer_a,$134.w		;Timer-A
		move.l	save_timer_b,$120.w		;Timer-B
		move.l	save_timer_c,$114.w		;Timer-C
		move.l	save_timer_d,$110.w		;Timer-D
		move.l	save_acia,$118.w		;ACIA

		lea	save_mfp,a0			;restore vectors and mfp
		move.b	(a0)+,$fffffa01.w		;// datareg
		move.b	(a0)+,$fffffa03.w		;Active edge
		move.b	(a0)+,$fffffa05.w		;Data direction
		move.b	(a0)+,$fffffa07.w		;Interrupt enable A
		move.b	(a0)+,$fffffa13.w		;Interupt Mask A
		move.b	(a0)+,$fffffa09.w		;Interrupt enable B
		move.b	(a0)+,$fffffa15.w		;Interrupt mask B
		move.b	(a0)+,$fffffa17.w		;Automatic/software end of interupt
		move.b	(a0)+,$fffffa19.w		;Timer A control
		move.b	(a0)+,$fffffa1b.w		;Timer B control
		move.b	(a0)+,$fffffa1d.w		;Timer C & D control
		move.b	(a0)+,$fffffa27.w		;Sync character
		move.b	(a0)+,$fffffa29.w		;USART control
		move.b	(a0)+,$fffffa2b.w		;Receiver status
		move.b	(a0)+,$fffffa2d.w		;Transmitter status
		move.b	(a0)+,$fffffa2f.w		;USART data

		move.w	#$2300,sr			;Start interrupts
	
		jsr	music_deinit			;Deinit music player

	ifne	falcon_compat				;Restore Falcon specific hardware
		cmp.b	#"F",computer_type		;
		beq.s	.falcon_setup			;
		bra.s	.st_restore			;
.falcon_setup:	jsr	falcon_restore_video		;
		bra.s	.res_done			;
	endc						;

.st_restore:	move.b	save_refresh,$ffff820a.w	;Restore refreshrate
		bsr	xbios_vsync			;Restore resolution
		move.b	save_res,$ffff8260.w		;
.res_done:

		cmp.l	#"MSTe",computer_type		;Check for Mega STe
		bne.s	.not_mste			;
		move.b	save_mste,$ffff8e21.w		;Save MSTe speed
.not_mste:

	ifne	ste_demo
		clr.w	$ffff8264.w			;Reset left border
		move.b	save_hscroll,$ffff8265.w	;Restore hscroll
		move.b	save_lw,$ffff820f.w		;Restore linewidth
	endc

		move.b	#$8,$fffffc02.w			;Enable mouse
		move.b	save_keymode,$484.w		;Restore keyclick

		lea	save_screenadr,a0		;Restore screenaddress
		move.b	(a0)+,$ffff8201.w		;
		move.b	(a0)+,$ffff8203.w		;
		move.b	(a0)+,$ffff820d.w		;
				
		movem.l	save_pal,d0-d7			;Restore palette
		movem.l	d0-d7,$ffff8240.w		;

		bsr	clear_kbd

exit_super:	move.l	save_stack,-(sp)		;Exit supervisor
		move.w	#32,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;

	ifne	code_dump				;Save code buffer to file (dump.bin)
		jsr	do_code_dump			;
		ifne	show_infos			;
			move.l	#text_code_dump,d0	;
			jsr	print			;
		endc					;
	endc						;

exit_pterm:

	ifne	show_infos				;Wait for keypress
		move.l	#text_waitkey,d0		;
		jsr	print				;
		jsr	waitkey				;
	endc						;

		clr.w	-(sp)				;pterm()
		trap	#1				;

