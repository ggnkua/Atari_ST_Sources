; Atari ST/e synclock demosystem
; January 14, 2011
;
; Old fashioned but stable 7-line syncscroller
;
; sys/syncscr.s

		
		section	text

sscrl_init:	lea	sscrl_jumplist,a0
		move.l	#sscrl_line0,d0
		move.w	#7-1,d7
.l:		move.l	d0,(a0)+
		dbra	d7,.l
		clr.l	sscrl_offset
		rts

sscrl_setup_list:
		moveq	#0,d2
		move.l	screen_adr_base,d2
		add.l	sscrl_offset,d2
		and.l	#$000000ff,d2

		lea	sscrl_combo_table,a1		;list of all 256/2 offset combos
		lsr.w	#1,d2				;reduce to 128 combinations
		lsl.w	#3,d2				;align with address list (8 byte boundary)
		add.l	d2,a1

		lea	sscrl_linewidths,a0		;list of routs with different linewidths
		lea	sscrl_jumplist,a2		;

		rept	7
		moveq	#0,d0
		move.b	(a1)+,d0			;get routine to run (0-6)
		lsl.w	#2,d0				;align to address list (4 byte boundary)
		move.l	(a0,d0.w),(a2)+			;write address to list
		endr

		rts



;-------------- Linewidth routines

		;160 byte line
sscrl_line0:	nop
		;music_ymdigi8_play_sample		;23
		dcb.w	23,$4e71			;23
		move.l	(a3)+,a0			;3 fetch next address
		dcb.w	119-26,$4e71			;
		rts					;4

		;158 byte line
sscrl_line1:	nop
		;music_ymdigi8_play_sample		;23
		dcb.w	23,$4e71			;23
		move.l	(a3)+,a0			;3
		dcb.w	93-26,$4e71			;
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	20,$4e71
		rts					;4

		;184 byte line
sscrl_line2:	nop
		nop
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		;music_ymdigi8_play_sample		;23
		dcb.w	23,$4e71			;23
		move.l	(a3)+,a0			;3
		dcb.w	86-26,$4e71
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	13,$4e71
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		nop
		rts					;4

		;204 byte line
sscrl_line3:	nop
		;music_ymdigi8_play_sample		;23
		dcb.w	23,$4e71			;23
		move.l	(a3)+,a0			;3
		dcb.w	95-26,$4e71			;
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	17,$4e71
		nop
		rts					;4

		;230 byte line
sscrl_line4:	nop
		nop
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		;music_ymdigi8_play_sample		;23
		dcb.w	23,$4e71			;23
		move.l	(a3)+,a0			;3
		dcb.w	88-26,$4e71
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	11,$4e71
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		nop
		rts					;4

		;186 byte line
sscrl_line5:	nop
		nop
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		;music_ymdigi8_play_sample		;23
		dcb.w	23,$4e71			;23
		move.l	(a3)+,a0			;3
		dcb.w	105-26,$4e71
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		nop
		rts					;4

		;54 byte line
sscrl_line6:	nop
		;music_ymdigi8_play_sample		;23
		dcb.w	23,$4e71			;23
		move.l	(a3)+,a0			;3
		dcb.w	41-26,$4e71			;
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	71,$4e71
		nop
		rts					;4

		
		section	data

sscrl_offset:	dc.l	0

sscrl_linewidths:
		dc.l	sscrl_line0			;+000 bytes
		dc.l	sscrl_line1			;-002 bytes
		dc.l	sscrl_line2			;+024 bytes
		dc.l	sscrl_line3			;+044 bytes
		dc.l	sscrl_line4			;+070 bytes
		dc.l	sscrl_line5			;+026 bytes
		dc.l	sscrl_line6			;-106 bytes


sscrl_combo_table:
		include	'sys/synctab.inc'
		even

		section	bss

sscrl_jumplist:	ds.l	7


		section	text
