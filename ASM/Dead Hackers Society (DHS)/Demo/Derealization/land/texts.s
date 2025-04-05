
		section	text

landtex_runtime_init:

		rts

landtext_timer:
		rts

landtext_vbl:
		rts

landtext_main:
		lea.l	chunky,a0

		move.l	timer_param,a2
		move.l	12(a2),a1	;text data
		move.l	16(a2),d0	;text screen ofs
		add.l	d0,a0

		clr.l	d0
		move.l	#320-128,d1
		move.w	#40-1,d7
.y:		move.w	#128-1,d6
.x:
		move.b	(a1)+,d0
		beq.s	.no
		move.b	d0,(a0)
.no:		addq.l	#1,a0

		dbra	d6,.x
		add.l	d1,a0
		dbra	d7,.y

		rts

landtext_main2:
		lea.l	intro_chunky,a0

		move.l	timer_param,a2
		move.l	12(a2),a1	;text data
		move.l	16(a2),d0	;text screen ofs
		add.l	d0,a0

		clr.l	d0
		move.l	#320-128,d1
		move.w	#40-1,d7
.y:		move.w	#128-1,d6
.x:
		move.b	(a1)+,d0
		beq.s	.no
		move.b	d0,(a0)
.no:		addq.l	#1,a0

		dbra	d6,.x
		add.l	d1,a0
		dbra	d7,.y

		rts



		section	data

landtext_data:	incbin	'land\alltxt03.apx'
		even

		section	bss

landtext_pal:	ds.l	256

		section	text