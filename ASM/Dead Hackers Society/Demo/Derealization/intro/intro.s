
		section	text

intro_init:	lea.l	tex_land+20,a0
		lea.l	intro_pal,a1
		bsr.w	conv_apxpal_to_falcpal

		rts

intro_timer:
		addq.l	#1,t
		rts

intro_vbl:	
		lea.l	intro_pal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal

		cmp.l	#1,vbl_param
		bne.s	.nofade

		lea.l	intro_pal,a0
		lea.l	intro_outpal,a1
		move.w	#248-1,d0
		bsr.w	falcon_fade

.nofade:	rts

intro_main:	

		bsr.w	real3d_chunkyclear_320x180 ;optimized clear

		lea.l	scene_land_sky,a0
		bsr.w	init_scene
		bsr.w	play_camera
		bsr.w	project_coords
		bsr.w	get_faces
		bsr.w	counting_sort
		bsr.w	real3d_draw_sky

		lea.l	scene_land,a0
		bsr.w	init_scene
		bsr.w	play_camera
		bsr.w	project_coords
		bsr.w	get_faces
		bsr.w	counting_sort
		bsr.w	real3d_draw_land


		tst.l	main_param
		bne.s	.param_available

		clr.l	d0
		bsr.w	intro_putblock
		bra.s	.doneblock

.param_available:
		move.l	main_param,a0
		move.l	(a0),d0
		bsr.w	intro_putblock


.doneblock:
		tst.l	timer_param
		beq.s	.c2p
		bsr.w	landtext_main2
.c2p:
		lea.l	intro_chunky,a0
		move.l	screen_adr,a1
		add.l	#320*30,a1
		move.l	#320*180,BPLSIZE
		bsr.w	c2p_8pl
				
		rts


intro_putblock:
;in: d0.l=offset to block&dest

		lea.l	intro_chunky,a0
		lea.l	chunky,a1
		add.l	d0,a0
		add.l	d0,a1
		move.l	#320-80,d0
		move.w	#45-1,d7
.y:		move.w	#80/4-1,d6
.x:		move.l	(a1)+,(a0)+
		dbra	d6,.x
		add.l	d0,a0
		add.l	d0,a1
		dbra	d7,.y
		rts

		section	data


intro_ofs11:	dc.l	0
intro_ofs13:	dc.l	80
intro_ofs08:	dc.l	160
intro_ofs14:	dc.l	240
intro_ofs01:	dc.l	0+320*45
intro_ofs05:	dc.l	80+320*45
intro_ofs02:	dc.l	160+320*45
intro_ofs16:	dc.l	240+320*45
intro_ofs04:	dc.l	0+320*90
intro_ofs07:	dc.l	80+320*90
intro_ofs15:	dc.l	160+320*90
intro_ofs09:	dc.l	240+320*90
intro_ofs06:	dc.l	0+320*135
intro_ofs10:	dc.l	80+320*135
intro_ofs12:	dc.l	160+320*135
intro_ofs03:	dc.l	240+320*135


;intro_gfx:	incbin	'intro\ghgirl02.apx'
		even


		section	bss

intro_pal:	ds.l	256
intro_outpal:	ds.l	256
intro_chunky:	ds.b	320*180

		section	text
