

help_screen
		tst.b	keytable+$3b
		beq	help_screen_out

	; help_screen aktivieren

		move.l	vbl_count,-(sp)
		clr.b	keytable+$3b

		movea.l	screen_1,a0
		suba.w	#128,a0
		move.l	a0,file_buf_ptr
		move.l	#help_pic,file_name_ptr
		move.l	#153728,file_size
		jsr	load_file

		move.w	#1,dont_change_scr
		tst.w	vga_monitor
		beq.s	hs_rgb

		move.l	#si_320x240vga,screen_init_rout_ptr
		bra.s	hs_screen_ok

hs_rgb
		move.l	#si_320x240,screen_init_rout_ptr

hs_screen_ok
		jsr	vsync
		jsr	swap_me

		lea	keytable,a0
hs_wait
		tst.b	$39(a0)			; space
		bne.s	hs_wait_over
		tst.b	$1(a0)			; esc
		bne.s	hs_wait_over
		tst.b	$3b(a0)			; f1
		beq.s	hs_wait

hs_wait_over
		clr.b	$39(a0)
		clr.b	$1(a0)
		clr.b	$3b(a0)

		jsr	install_si_routine
		move.w	#2,dont_change_scr
		jsr	vsync
		jsr	swap_me
		jsr	vsync
		jsr	swap_me

	; screen zurueckkopieren

		movea.l	screen_2,a0
		movea.l	screen_1,a1
		bsr	copy_240

		move.l	(sp)+,vbl_count


help_screen_out

		rts

