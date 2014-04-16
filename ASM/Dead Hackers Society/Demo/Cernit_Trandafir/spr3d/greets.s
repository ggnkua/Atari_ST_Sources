
		section	text

greets_in1:
		bsr.w	spr3d_vbl

		movem.l	greets_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		bsr.w	spr3d_stars	

		move.w	.pos,d0
		bsr.w	greets_draw

		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2

		subq.w	#1,.wait
		bne.s	.noadd
		move.w	#4,.wait
		cmp.w	#14,.pos
		beq.s	.noadd
		addq.w	#1,.pos

.noadd:		rts
.pos:		dc.w	0
.wait:		dc.w	4

greets_out1:
		bsr.w	spr3d_vbl

		bsr.w	spr3d_stars	

		move.w	.pos,d0
		bsr.w	greets_clr

		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2

		subq.w	#1,.wait
		bne.s	.noadd
		move.w	#4,.wait
		cmp.w	#14,.pos
		beq.s	.noadd
		addq.w	#1,.pos

.noadd:		rts
.pos:		dc.w	0
.wait:		dc.w	4

greets_in2:
		bsr.w	spr3d_vbl

		movem.l	greets_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		bsr.w	spr3d_stars	

		move.w	#240*200/4,greets_srcofs
		move.w	.pos,d0
		bsr.w	greets_draw

		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2

		subq.w	#1,.wait
		bne.s	.noadd
		move.w	#4,.wait
		cmp.w	#14,.pos
		beq.s	.noadd
		addq.w	#1,.pos

.noadd:		rts
.pos:		dc.w	0
.wait:		dc.w	4

greets_out2:
		bsr.w	spr3d_vbl

		bsr.w	spr3d_stars	

		move.w	.pos,d0
		bsr.w	greets_clr

		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2

		subq.w	#1,.wait
		bne.s	.noadd
		move.w	#4,.wait
		cmp.w	#14,.pos
		beq.s	.noadd
		addq.w	#1,.pos

.noadd:		rts
.pos:		dc.w	0
.wait:		dc.w	4


greets_clr:
;input d0.w	x ofs (0-14)
		lsl.w	#3,d0

		move.l	screen_adr,a0
		lea.l	192*65+16(a0),a0
		move.l	screen_adr2,a1
		lea.l	192*65+16(a1),a1
		add.w	d0,a0
		add.w	d0,a1
		moveq.l	#0,d0
		move.w	#200-1,d7
.y:
		move.l	d0,(a0)
		move.l	d0,(a1)
		lea.l	192(a1),a1

		dbra	d7,.y

		rts

greets_draw:
;input d0.w	x ofs (0-14)

		move.l	d0,d1
		lsl.w	#2,d0	;source pos
		lsl.w	#3,d1	;dest pos

		move.l	screen_adr,a0
		lea.l	192*65+16(a0),a0
		add.w	d1,a0
		move.l	screen_adr2,a2
		lea.l	192*65+16(a2),a2
		add.w	d1,a2

		lea.l	greets_data,a1
		add.w	d0,a1
		add.w	greets_srcofs,a1	;which greets screen to show
		move.w	#200-1,d7
.y:
		move.l	(a1),d0
		move.l	d0,(a0)
		move.l	d0,(a2)
		lea.l	60(a1),a1
		lea.l	192(a0),a0
		lea.l	192(a2),a2

		dbra	d7,.y

		rts


		section	data

greets_srcofs:	dc.w	0
greets_pal:	dc.w	$0000,$0123,$0345,$0567,$0000,$0000,$0000,$0000
		dc.w	$046f,$0012,$0123,$0234,$0000,$0000,$0000,$0000

greets_data_ice:
		incbin	'spr3d/greets.ice'
		even

		section	text
