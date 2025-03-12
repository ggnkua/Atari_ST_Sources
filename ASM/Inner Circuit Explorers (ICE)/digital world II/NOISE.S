ffa07.w		;b enable
		bset   	#0,$fffffa13.w		;b mask
		move.b 	#0,$fffffa1b.w		;tbcr
		move.b 	#255,$fffffa21.w	;tbdr
		move.b 	#8,$fffffa1b.w		;even count mode
		bsr.l 	init_music
		move.w	#$2300,sr

		sf	vbl_flg
key:		tst.b 	vbl_flg
		beq.s 	key
		cmp.b	#$3b,$fffffc02.w	; f1
		beq.s	osc_1
		cmp.b	#$3c,$fffffc02.w	; f2
		beq.s	osc_2
		cmp.b	#$44,$fffffc02.w	; f10
		beq.s	pause
		cmp.b	#$43,$fffffc02.w	; f9
		beq.l	nopause
		cmp.b 	#$61,$fffffc02.w	; keyb. ACIA data reg
		beq.l 	back
		cmp.b	#$14,$fffffc02.w
		beq.s	st_hide
		tst.b	hide_flg
		beq.s	no
		cmp.b	#$11,$fffffc02.w
		beq.s	hidescreen

		sf 	hide_flg
no:		sf 	vbl_flg
		bra.s 	key
st_hide:	st	hide_flg
		sf	vbl_flg
		bra.s	key

osc_1:		move.w	#0,osc_size
		move.w	#320-260,center
		sf	vbl_flg
		bra.s	key

osc_2:		move.w	#1,osc_size
		move.w	#320-130,center
		sf	vbl_flg
		bra.L	key

pause:		st	pause_flg
		sf	vbl_flg
		bra.l	key

nopause:	sf	pause_flg
		sf	vbl_flg
		bra.l	key

hidescreen:	sf	vbl_flg
vsync_hide:	tst.b	vbl_flg
		beq.s	vsync_hide
		move.l	#vbl_hide,$70

		sf	vbl_flg
key_2:		tst.b	vbl_flg
		beq.s	key_2
		cmp.b	#185,$fffffc02.w
		beq.s	back_vbl
		bra.s	key_2
back_vbl:	move.l	#vbl,$70
		sf	vbl_flg
		bra.l	key
		
;--------------------------------------------------------------------

vbl:		st 	vbl_flg
		;move.w	#$300,$ffff8240.w
		movem.l d0-d7/a0-a6,-(sp)

		move.l	#icetop+128,d0
		move.b	d0,$ffff8209.w
		lsr.w	#8,d0
		move.b	d0,$ffff8207.w
		swap	d0
		move.b	d0,$ffff8205.w

		lea	icetop+4,a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.b 	#0,$fffffa1b.w		
		move.b 	#1,$fffffa21.w		
		move.b 	#8,$fffffa1b.w		

;--------------------------------------------------------------------
		lea	sinstart,a0
		add.w	sinpoint,a0
		cmp.l	#sinend,a0
		bne.s	no_restart
		move.w	#0,sinpoint

no_restart:	lea	icetop+128+160,a1
		lea	hscroll_data,a5
		lea	screenp_data,a6

		moveq	#32-1,d7
lines:		moveq	#0,d0
		moveq	#0,d1

		move.b	(a0)+,d0	; get 1st x value!
		sub.b	#42,d0		; <------ center
		cmp.b 	#$f,d0     
		bhi.s	xfix_i	 	; higher than 15 ?
		move.l	a1,d1
		bra.s	go_on

xfix_i:		ror.l	#