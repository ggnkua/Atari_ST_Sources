; Fullscreen 1 vbl bumpmap (4x4 with mirror and scrolling)
;
; ae 2012-03-22


		section	text


bump_init:	rts

bump_runtime_init:

		run_once
		init_finish_red

		jsr	clear_screens
		;jsr	clear_buf
		bsr	bump_load_data
		bsr	bump_make_linelists
		bsr	bump_scramble_texture
		bsr	bump_code_copy
		bsr	bump_smc_ofstable
		bsr	bump_smc_screenofs
		bsr	bump_distconv
		bsr	bump_convert_pal
		bsr	bump_make_fades
		init_finish_green

		rts



bump_main:
		bsr	bump_distort_dl
		rts

bump_vbl:
		;move.l  screen_adr,d0
		move.l  empty_adr,d0
		lea	$ffff8203.w,a0
		movep.l	d0,0(a0)


		lea	buf+bump_fades,a0
		add.w	bump_fadepos,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240.w

		bsr	bump_move


		cmp.w	#32*47,bump_fadepos
		ble.s	.ok
		sub.w	#32,bump_fadepos
.ok:

		subq.w	#1,.cnt
		bne.s	.no
		move.w	#32*70,bump_fadepos
		move.w	#48,.cnt
.no:
		rts
.cnt:		dc.w	80

bump_vbl_in:
		move.l  screen_adr,d0
		lea	$ffff8203.w,a0
		movep.l	d0,0(a0)

		lea	buf+bump_fades,a0
		add.w	bump_fadepos,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240.w

		bsr	bump_move

		cmp.w	#32*47,bump_fadepos
		bge.s	.ok
		add.w	#32,bump_fadepos
.ok:		rts

bump_vbl_out:
		move.l  screen_adr,d0
		lea	$ffff8203.w,a0
		movep.l	d0,0(a0)

		lea	buf+bump_fades,a0
		add.w	bump_fadepos,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240.w

		bsr	bump_move

		tst.w	bump_fadepos
		ble.s	.ok
		sub.w	#32,bump_fadepos
.ok:		rts

bump_ta:
		do_hardsync_top_border			;Macro to syncronize into exact cycle and remove top border

		;inits
		moveq	#2,d7				;D7 used for the overscan code

		dcb.w	57-16-13,$4e71			;Time for user to set up registers etc

		lea	$ffff8203.w,a0			;2 screen address counter
		lea	buf+bump_disted_dl,a1		;3
		lea	buf+bump_t1+256*64/2+80,a2	;3 texture 1
		lea	buf+bump_t2+256*64/2+80,a3	;3 texture 2
		add.w	bump_txpos,a2			;5 flare movement
		add.w	bump_txpos,a3			;5 flare movement

		move.l	bump_dl2adr,a4			;5
		move.l	(a4),a4				;3

		jsr	codebuf				;Run generated code
		jsr	black_pal			;Set colours black in case some emulator show >274 lines

		move.l	bump_dl1adr,d0
		move.l	bump_dl2adr,bump_dl1adr
		move.l	d0,bump_dl2adr
		rts




bump_c2p_start:
		move.l	(a1)+,d0			;3 fetch screen address
		movep.l	d0,0(a0)			;6 set screen address

		move.b	d7,$ffff8260.w			;3 left border
		move.w	d7,$ffff8260.w			;3

		rept	6
		move.l	1234(a2),d0			;4
		or.l	1234(a3),d0			;5
		movep.l	d0,5678(a4)			;6
		endr

		move.w	d7,$ffff820a.w			;3 right border
		move.b	d7,$ffff820a.w			;3
		dcb.w	17-15,$4e71

		move.l	1234(a2),d0			;4
		or.l	1234(a3),d0			;5
		movep.l	d0,5678(a4)			;6

		;---------------------------------------

		move.l	(a1)+,d0			;3 fetch screen address
		movep.l	d0,0(a0)			;6 set screen address

		move.b	d7,$ffff8260.w			;3 left border
		move.w	d7,$ffff8260.w			;3

		rept	6
		move.l	1234(a2),d0			;4
		or.l	1234(a3),d0			;5
		movep.l	d0,5678(a4)			;6
		endr

		move.w	d7,$ffff820a.w			;3 right border
		move.b	d7,$ffff820a.w			;3
		dcb.w	17-15,$4e71

		move.l	1234(a2),d0			;4
		or.l	1234(a3),d0			;5
		movep.l	d0,5678(a4)			;6

bump_c2p_end:
	

bump_lower_border_start:
		move.l	(a1)+,d0			;3 fetch screen address
		movep.l	d0,0(a0)			;6 set screen address
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	90,$4e71
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	17,$4e71

		move.l	(a1)+,d0			;3 fetch screen address
		movep.l	d0,0(a0)			;6 set screen address
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	90,$4e71
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	17-3,$4e71

		move.l	(a1)+,d0			;3 fetch screen address
		movep.l	d0,0(a0)			;6 set screen address
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	87,$4e71
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	17,$4e71
bump_lower_border_end:

bump_dummy_start:
		move.l	(a1)+,d0			;3 fetch screen address
		movep.l	d0,0(a0)			;6 set screen address
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	90,$4e71
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	17,$4e71
bump_dummy_end:


bump_code_copy:
		jsr	code_copy_reset
		
		move.l	#bump_c2p_start,d0
		move.l	#bump_c2p_end,d1
		move.w	#226/2,d2
		jsr	code_copy

		;3 scans
		move.l	#bump_lower_border_start,d0
		move.l	#bump_lower_border_end,d1
		move.w	#1,d2
		jsr	code_copy

		move.l	#bump_c2p_start,d0
		move.l	#bump_c2p_end,d1
		move.w	#34/2,d2
		jsr	code_copy

		move.l	#bump_dummy_start,d0
		move.l	#bump_dummy_end,d1
		move.w	#10,d2
		jsr	code_copy
		
		jsr	code_copy_rts
		rts



bump_scramble_texture:
		lea	buf+bump_txt+1024+54,a0
		lea	buf+bump_t1,a2
		lea	buf+bump_t2,a3

		move.l	#64*64*4,d5
		move.l	#64*64*4*2,d6

		move.w	#64*64-1,d4
.l:
		moveq	#0,d0
		move.b	(a0)+,d0

		move.l	d0,d1			;bpl1
		and.b	#%00000001,d1
		move.l	d1,d2
		lsl.b	#1,d1
		or.b	d1,d2
		lsl.b	#1,d1
		or.b	d1,d2
		lsl.b	#1,d1
		or.b	d1,d2

		lsl.l	#8,d2			;bpl2
		move.l	d0,d1
		and.b	#%00000010,d1
		move.b	d1,d2
		lsr.b	#1,d2
		or.b	d1,d2
		move.b	d2,d1
		lsl.b	#2,d1
		or.b	d1,d2

		lsl.l	#8,d2			;bpl3
		move.l	d0,d1
		and.b	#%00000100,d1
		lsl.b	#1,d1
		move.b	d1,d2
		lsr.b	#1,d1
		or.b	d1,d2
		lsr.b	#1,d1
		or.b	d1,d2
		lsr.b	#1,d1
		or.b	d1,d2


		lsl.l	#8,d2			;bpl4
		move.l	d0,d1
		and.b	#%00001000,d1
		move.b	d1,d2
		lsr.b	#1,d1
		or.b	d1,d2
		lsr.b	#1,d1
		or.b	d1,d2
		lsr.b	#1,d1
		or.b	d1,d2
		lsr.b	#1,d1
		or.b	d1,d2

		move.l	d2,(a3,d5.l)
		move.l	d2,(a3,d6.l)
		move.l	d2,(a3)+
		lsl.l	#4,d2
		move.l	d2,(a2,d5.l)
		move.l	d2,(a2,d6.l)
		move.l	d2,(a2)+

		dbra	d4,.l

		rts


bump_make_linelists:
		move.l	screen_adr,a0
		move.l	screen_adr2,a1

		lea	buf+bump_dl1,a2
		lea	buf+bump_dl2,a3
		move.l	a2,bump_dl1adr
		move.l	a3,bump_dl2adr



		move.w	#272/4/2+1-1,d7
.l:
		rept	4
		move.l	a0,(a2)+
		move.l	a1,(a3)+
		endr

		lea	224(a0),a0
		lea	224(a1),a1

		dbra	d7,.l


		;mirror

		lea	-224*2(a0),a0
		lea	-224*2(a1),a1

		move.w	#272/4/2-1-1,d7
.l2:
		rept	4
		move.l	a0,(a2)+
		move.l	a1,(a3)+
		endr

		lea	-224(a0),a0
		lea	-224(a1),a1

		dbra	d7,.l2

		rept	7
		move.l	a0,(a2)+
		move.l	a1,(a3)+
		endr

		rts

bump_smc_ofstable:							;write bump lookups to code and compensate for flare offset
		lea	codebuf-2,a0
		lea	buf+bump_ofs,a1
		moveq	#0,d0
		moveq	#0,d3
		moveq	#0,d4
		move.w	#35-1,d7
.y:		move.w	#104-1,d6
		moveq	#0,d5
.x:		addq.l	#2,a0
		cmp.w	#1234,(a0)
		bne.s	.x
		move.w	(a1)+,d1

		move.w	d1,d2						;x
		add.w	d5,d1
		addq.w	#1,d5
		lsr.b	#2,d1
		lsl.b	#2,d1
		and.w	#$00ff,d1

		add.w	d4,d2
		lsr.w	#2,d2						;y
		and.w	#$ff00,d2
		or.w	d2,d1

		move.w	d1,(a0)

		dbra	d6,.x
		addq.w	#1,d4
		dbra	d7,.y

		rts


bump_smc_screenofs:							;write screen offsets to movep's
		lea	codebuf-2,a0
		moveq	#0,d0

		move.w	#260/2-1,d7
.y:		move.w	#28/4-1,d6
.x:
		addq.l	#2,a0
		cmp.w	#5678,(a0)
		bne.s	.x
		move.w	d0,(a0)
		addq.w	#1,d0

.x2:
		addq.l	#2,a0
		cmp.w	#5678,(a0)
		bne.s	.x2
		move.w	d0,(a0)
		addq.w	#7,d0

		subq.w	#4,.ofs
		bne.s	.next
		add.w	#224-208,d0
		move.w	#104,.ofs


.next:		dbra	d6,.x
		dbra	d7,.y

		rts
.ofs:		dc.w	104


bump_load_data:
		move.l	#bump_txt_fn,filename
		move.l	bump_txt_fl,filelength
		move.l	#buf+bump_txt,filebuffer
		jsr	loader

		move.l	#bump_ofs_fn,filename
		move.l	bump_ofs_fl,filelength
		move.l	#buf+bump_ofs,filebuffer
		jsr	loader

		rts


bump_move:
		add.l	#32,.sin
		and.l	#$1fff,.sin

		lea	sincos4000,a0
		move.l	.sin,d0
		move.w	(a0,d0.l),d1
		muls.w	#48,d1
		asr.l	#8,d1
		asr.l	#7,d1

		asl.l	#2,d1
		move.w	d1,bump_txpos

		rts
.sin:		dc.l	0


bump_distconv:
	ifne	1
		lea	buf+bump_dist,a1
		lea	276*2(a1),a2
		moveq	#0,d0
		move.w	#276-1,d7
.l:		move.w	d0,(a1)+
		move.w	d0,(a2)+
		addq.w	#4,d0
		dbra	d7,.l
		rts
	endc
	ifne	0
;convert 3 byte tga to 2 byte values
		lea	bump_dlofs,a0
		lea	buf+bump_dist,a1
		lea	276*2(a1),a2
		move.w	#280-1,d7
.l:
		moveq	#0,d0

		move.b	(a0)+,d0
		lsl.w	#8,d0
		move.b	(a0)+,d0

		lsl.w	#2,d0				;4 byte boundary
		move.w	d0,(a1)+
		move.w	d0,(a2)+

		addq.l	#1,a0

		dbra	d7,.l

		rts
	endc

bump_distort_dl:
		move.l	bump_dl1adr,a0
		lea	buf+bump_disted_dl,a1
		lea	buf+bump_dist,a2
		add.w	.pos,a2
		moveq	#0,d0
		rept	273
		move.w	(a2)+,d0
		move.l	(a0,d0.w),(a1)+
		endr

		cmp.w	#276*2,.pos
		blt.s	.add
		move.w	#-2,.pos
.add:		addq.w	#2,.pos

		rts
.pos:		dc.w	0


bump_convert_pal:
		lea	bump_bmppal,a0
		lea	buf+bump_pal,a1
		jsr	convert_bmp_pal
		rts

bump_make_fades:

		move.w	#48-1,.cnt			;black>pal
.l1:
		move.l	.adr,a0
		movem.l	bump_black,d0-d7
		movem.l	d0-d7,(a0)
		add.l	#32,.adr

		lea	bump_black,a0
		lea	buf+bump_pal,a1
		jsr	component_fade

		subq.w	#1,.cnt
		bpl.s	.l1

		move.w	#48-1,.cnt			;pal>white
.l2:
		move.l	.adr,a0
		movem.l	buf+bump_pal,d0-d7
		movem.l	d0-d7,(a0)
		add.l	#32,.adr

		lea	buf+bump_pal,a0
		lea	bump_white,a1
		jsr	component_fade

		subq.w	#1,.cnt
		bpl.s	.l2



		rts
.adr:		dc.l	buf+bump_fades
.cnt:		dc.w	0

		section	data

bump_fadepos:	dc.w	0

bump_txpos:	dc.w	0

bump_txt_fn:	dc.b	'data\bumptx.bmp',0
		even
bump_txt_fl:	dc.l	64*64+1024+54

bump_ofs_fn:	dc.b	'data\bumpofs.bin',0
		even
bump_ofs_fl:	dc.l	7280

bump_dlofs:

bump_black:	dcb.w	16,$0000
bump_white:	dcb.w	16,$0fff
bump_bmppal:	incbin	'bump/pal.bmp'
		even

bump_dl1adr:	dc.l	buf+bump_dl1
bump_dl2adr:	dc.l	buf+bump_dl2


			
		section	bss

		section	text
