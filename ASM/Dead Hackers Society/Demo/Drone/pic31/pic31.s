; 31-scale picture by ultradialectics


		section	text

pic31_init:
		rts

pic31_runtime_init:
		run_once				;Macro to ensure the runtime init only run once
		init_finish_red

		bsr	pic31_load_data
		bsr	pic31_copy_pics
		bsr	pic31_code_copy

		init_finish_green
		rts

pic31_runtime_init_2:
		run_once				;Macro to ensure the runtime init only run once
		init_finish_red

		bsr	pic31_load_data_2
		bsr	pic31_copy_pics
		bsr	pic31_code_copy

		init_finish_green
		rts



pic31_vbl:
		move.l  empty_adr,d0			;Set screenaddress
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		move.l	empty_adr,d0
		lea	$ffff8203.w,a0
		movep.l	d0,0(a0)

		movem.l	pic31_black,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2
		rts

pic31_vbl_in:
		bsr	pic31_vbl

		lea	pic31_black,a0
		lea	pic31_pal,a1
		jsr	component_fade

		rts

pic31_vbl_out:
		bsr	pic31_vbl

		subq.w	#1,.wait
		bne.s	.no
		move.w	#2,.wait

		lea	pic31_black,a0
		lea	pic31_black2,a1
		jsr	component_fade

.no:		rts
.wait:		dc.w	1


pic31_vbl_in2:
		bsr	pic31_vbl

		lea	pic31_black,a0
		lea	pic31_pal2,a1
		jsr	component_fade

		rts

pic31_vbl_out2:
		bsr	pic31_vbl

		subq.w	#1,.wait
		bne.s	.no
		move.w	#2,.wait

		lea	pic31_black,a0
		lea	pic31_black2,a1
		jsr	component_fade

.no:		rts
.wait:		dc.w	1

pic31_main:
		rts


pic31_ta:
		do_hardsync_top_border			;Macro to syncronize into exact cycle and remove top border

		;inits
		moveq	#2,d7				;D7 used for the overscan code

		dcb.w	66-13,$4e71			;Time for user to set up registers etc

		move.l	screen_adr,d0			;5
		lea	$ffff8203.w,a0			;2
		movep.l	d0,0(a0)			;6

		jsr	codebuf				;Run generated code
		jsr	black_pal			;Set colours black in case some emulator show >274 lines
		rts


pic31_main_begin:
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90,$4e71

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	26,$4e71
pic31_main_end:

pic31_lower_begin:
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90,$4e71

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	23,$4e71
		move.w	d7,$ffff820a.w			;3 left border

		;-----------------------------------

		move.b	d7,$ffff8260.w			;3 lower border
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3

		dcb.w	87,$4e71

		move.w	d7,$ffff820a.w			;3 right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	26,$4e71

pic31_lower_end:

pic31_code_copy:
		;Copy code to the code buffer
		jsr	code_copy_reset			;Reset code copier variables

		move.l	#pic31_main_begin,d0		;
		move.l	#pic31_main_end,d1		;
		move.w	#227,d2				;
		jsr	code_copy			;

		move.l	#pic31_lower_begin,d0		;Copy the lower border special case (2 scanlines)
		move.l	#pic31_lower_end,d1		;
		moveq	#1,d2				;
		jsr	code_copy			;

		move.l	#pic31_main_begin,d0		;
		move.l	#pic31_main_end,d1		;
		move.w	#44,d2				;
		jsr	code_copy			;

		jsr	code_copy_rts			;Make sure the code buffer does rts :)
		rts


pic31_load_data:
		move.l	#pic31_fn,filename
		move.l	pic31_fl,filelength
		move.l	#buf+pic31_pic,filebuffer
		jsr	loader

		rts

pic31_load_data_2:
		move.l	#pic31_fn2,filename
		move.l	pic31_fl2,filelength
		move.l	#buf+pic31_pic,filebuffer
		jsr	loader

		rts

pic31_copy_pics:
		move.l	screen_adr,a0
		move.l	screen_adr2,a1
		;lea	160(a0),a0
		;lea	160(a1),a1
		lea	buf+pic31_pic,a2
		lea	buf+pic31_pic+400*273/2,a3

		move.w	#273-1,d7
.y:		move.w	#400/2/4-1,d6
.x:
		move.l	(a2)+,(a0)+
		move.l	(a3)+,(a1)+

		dbra	d6,.x
		lea	224-200(a0),a0
		lea	224-200(a1),a1
		dbra	d7,.y
		rts

		section	data

pic31_fn:	dc.b	'data\pic31.4pl',0
		even
pic31_fl:	dc.l	400*273/2*2

pic31_fn2:	dc.b	'data\pic31b.4pl',0
		even
pic31_fl2:	dc.l	400*273/2*2

;08192a3b4c5d6e7f
pic31_pal:	dc.w	$0000,$0118,$0991,$0229,$0aa2,$033a,$0bb3,$044b
		dc.w	$0cc4,$055c,$0dd5,$066d,$0ee6,$077e,$0ff7,$0fff

pic31_pal2:	dc.w	$0000,$0088,$0811,$0199,$0922,$02aa,$0a33,$03bb
		dc.w	$0b44,$04cc,$0c55,$05dd,$0d66,$06ee,$0e77,$0fff


pic31_black:	dcb.w	16,$0000
pic31_black2:	dcb.w	16,$0000


		section	bss

		rsreset
pic31_pic:	rs.b	400*273/2*2
		section	text

