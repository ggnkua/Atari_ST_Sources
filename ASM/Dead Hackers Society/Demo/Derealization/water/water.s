
		section	text

water_init:
		lea.l	tex_feto4+20,a0
		lea.l	water_rawtxt+20+128*3,a1
		move.w	#128-1,d7
.copyenvcols:	move.w	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		dbra	d7,.copyenvcols

		lea.l	water_rawtxt+20,a0
		lea.l	water_pal,a1
		bsr.w	conv_apxpal_to_falcpal


		lea.l	water_rawtxt+788,a0
		lea.l	water_txt,a1
		lea.l	water_txt+256*256,a2
		lea.l	water_txt+256*256*2,a3
		move.w	#256*256/4-1,d7
.copytxt:	move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	d0,(a3)+
		dbra	d7,.copytxt

		lea.l	water_lightraw+788,a0
		lea.l	water_light,a1
		lea.l	water_light+256*256,a2
		move.w	#256*256-1,d7
.copylight:	move.b	(a0)+,d0
		lsr.b	#1,d0
		move.b	d0,(a1)+
		move.b	d0,(a2)+
		dbra	d7,.copylight


		lea.l	tex_feto4+788,a0
		move.w	#256*256-1,d7
.addenv:	move.b	(a0),d0
		add.b	#128,d0
		move.b	d0,(a0)+
		dbra	d7,.addenv

		lea.l	water_flashpal,a0
		move.w	#256-1,d7
.flashfill:	move.l	#$aaaa00aa,(a0)+
		dbra	d7,.flashfill

		rts


water_runtime_init:
		bsr.w	waterenv_runtime_init
		
		rts


water_timer:	
		bsr.w	waterenv_timer
		rts

water_vbl:
		cmp.l	#3,vbl_param		;param=3 fadeout
		bne.s	.nofadeout

		lea.l	water_pal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal
		
		lea.l	water_pal,a0
		lea.l	water_outpal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade

		bra.s	.sin

.nofadeout:
		cmp.l	#2,vbl_param		;param=2 fadein
		bne.s	.nofadein

		lea.l	water_blackpal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal
		
		lea.l	water_blackpal,a0
		lea.l	water_pal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade
		bra.s	.sin
		
.nofadein:


		cmp.l	#1,vbl_param		;param=1 flash
		bne.s	.noflash

		lea.l	water_flashpal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal
		
		lea.l	water_flashpal,a0
		lea.l	water_pal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade
		
		bra.s	.sin
		

.noflash:	lea.l	water_pal,a0		;no param
		move.w	#256-1,d0
		bsr.w	falcon_setpal



.sin:
		add.l	#12,water_sintxt
		and.l	#$1fff,water_sintxt

		add.l	#16,water_sintxt2
		and.l	#$1fff,water_sintxt2

		addq.l	#1,water_lightofs
		and.l	#$ffff,water_lightofs

		rts


water_main:

		bsr.w	water_draw_water

		cmp.l	#1,main_param
		bne.s	.no_env
		bsr.w	waterenv_main
.no_env:

		lea.l	water_chunky,a0
		move.l	screen_adr,a1
		add.l	#320*30,a1
		move.l	#320*180,BPLSIZE
		bsr.w	c2p_8pl

*		move.l	#$55000000,$ffff9800.w
		rts


water_draw_water:
		lea.l	sincos4000,a3

		move.l	water_sintxt,d0
		move.l	(a3,d0.l),d1
                muls.w	#256,d1	
		asr.l	#8,d1
		asr.l	#7,d1
		muls.l	#256,d1

		move.l	water_sintxt2,d0
		move.l	(a3,d0.l),d2
                muls.w	#128,d2	
		asr.l	#8,d2
		asr.l	#7,d2
		*add.l	d2,d2

		lea.l	water_chunky,a0
		lea.l	water_lut+20,a1
		lea.l	water_txt+256*256,a2
		lea.l	water_wave+20,a3
		lea.l	water_light+788,a4
		
		add.l	water_lightofs,a4
		add.l	d1,a2
		add.l	d2,a2
		


		clr.l	d0
		clr.l	d1
		
		move.w	#180-1,d7
.y:		move.w	#320/8-1,d6
.x:
		rept	8
		move.w	(a1)+,d0
		move.b	(a2,d0.l),d1	;(a0)+
		move.w	(a3)+,d0
		add.b	(a4,d0.l),d1
		move.b	d1,(a0)+
		endr

		dbra	d6,.x
		dbra	d7,.y

		rts



		include	'water\waterenv.s'


		section	data


water_lut:	incbin	'water\watofs01.apx'
		even

water_rawtxt:	incbin	'water\wattxt02.apx'
		even

water_lightraw:	incbin	'water\lmap01.apx'
		even
water_wave:	incbin	'water\wave02.apx'
		even

water_txtofs:	dc.l	0
water_lightofs:	dc.l	0
water_sintxt:	dc.l	0
water_sintxt2:	dc.l	1000

		section	bss

water_outpal:	ds.l	256
water_blackpal:	ds.l	256
water_pal:	ds.l	256
water_flashpal:	ds.l	256

water_chunky:	ds.b	320*180
water_txt:	ds.b	256*256*3
water_light:	ds.b	256*256*2
		section	text

