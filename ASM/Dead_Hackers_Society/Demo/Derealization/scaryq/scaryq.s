
		section	text

scaryq_init:
	
		;init graphics and palettes..
		
		lea.l	scaryq_text+788,a0
		move.w	#320*180-1,d7
.fixtext:	move.b	(a0),d0
		add.b	#48,d0
		move.b	d0,(a0)+
		dbra	d7,.fixtext

		lea.l	scaryq_face+20+48*3,a0
		lea.l	scaryq_text+20,a1
		move.w	#16-1,d7
.fixtextpal:	move.w	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		dbra	d7,.fixtextpal

		lea.l	tex_brain+20,a0
		lea.l	scaryq_face+20,a1
		move.w	#48-1,d7
.fixenvpal:	move.w	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		dbra	d7,.fixenvpal

		lea.l	scaryq_face+20,a0
		lea.l	scaryq_pal,a1
		bsr.w	conv_apxpal_to_falcpal
		
		

		rts


scaryq_runtime_init:

		bsr.w	clear_all_screens
		
		move.l	screen_adr1,a0
		move.l	screen_adr2,a1
		move.l	screen_adr3,a2
		add.l	#640*60+320,a0
		add.l	#640*60+320,a1
		add.l	#640*60+320,a2
		lea.l	scaryq_face+788,a3
		lea.l	scaryq_left+788,a4
		move.w	#360-1,d7
.face_y:	move.w	#20-1,d6
.face_x:
		addq.l	#2,a3
		addq.l	#2,a4
		rept	4
		move.l	(a3)+,d0
		move.l	(a4)+,d1
		move.l	d1,-320(a0)
		move.l	d0,(a0)+
		move.l	d1,-320(a1)
		move.l	d0,(a1)+
		move.l	d1,-320(a2)
		move.l	d0,(a2)+
		endr
	
		dbra	d6,.face_x
		lea.l	320(a0),a0
		lea.l	320(a1),a1
		lea.l	320(a2),a2
		dbra	d7,.face_y


		bsr.w	scaryenv_runtime_init

		rts


scaryq_timer:
		bsr.w	scaryenv_timer
		rts
		
scaryq_vbl:
		cmp.l	#1,vbl_param
		bne.s	.nofadeout
		lea.l	scaryq_setpal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal
		
		lea.l	scaryq_setpal,a0
		lea.l	scaryq_outpal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade
		
		bra.w	.noswapface

.nofadeout:	lea.l	scaryq_setpal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal

		lea.l	scaryq_setpal,a0
		move.l	.facesource,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade

		subq.l	#1,.facewait
		bne.s	.noswapface

		move.l	.facesource,d0
		move.l	.facesource2,.facesource
		move.l	d0,.facesource2
		move.l	.facesource+4,d0
		move.l	.facesource2+4,.facesource+4
		move.l	d0,.facesource2+4
		move.l	.facesource+4,.facewait

.noswapface:
		rts

.facewait:	dc.l	10
.facesource:	dc.l	scaryq_pal,8
.facesource2:	dc.l	scaryq_black,3

scaryq_main:

		bsr.w	scaryq_clrchunky
		bsr.w	scaryenv_main
		bsr.w	scaryq_c2p


		rts


scaryq_c2p:	lea.l	scaryq_chunky,a0
		move.l	screen_adr,a1
		add.l	#210*640,a1
		bsr.w	c2p_6pl_hires
		rts

scaryq_clrchunky:
		lea.l	scaryq_text+788,a0
		lea.l	scaryq_chunky,a1
		move.w	#320*180/16-1,d7
.clr:
		rept	4
		move.l	(a0)+,(a1)+
		endr
		
		dbra	d7,.clr

		rts


		include	'scaryq\scaryenv.s'
		

		section	data

scaryq_face:	incbin	'scaryq\scary320.apx'
		even

scaryq_left:	incbin	'scaryq\scarylft.apx'
		even

scaryq_text:	incbin	'scaryq\scarytxt.apx'
		even


		section	bss

scaryq_chunky:	ds.b	320*180

scaryq_setpal:	ds.l	256
scaryq_black:	ds.l	256
scaryq_pal:	ds.l	256
scaryq_outpal:	ds.l	256

		section	text
