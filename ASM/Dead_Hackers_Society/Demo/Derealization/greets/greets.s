
		section	text


greets_init:
		lea.l	greets_rawtxt+788,a0
		lea.l	greets_txt,a1
		lea.l	greets_txt+256*256,a2
		lea.l	greets_txt+256*256*2,a3
		move.w	#256*256/4-1,d7
.copytxt:	move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	d0,(a3)+
		dbra	d7,.copytxt
		
		
		lea.l 	tex_knot3+788,a0
		move.w	#256*256-1,d7
.incenv:	move.b	(a0),d0
		add.b	#128,d0
		move.b	d0,(a0)+
		dbra	d7,.incenv


		lea.l	tex_knot3+20,a0
		lea.l	greets_rawtxt+20+128*3,a1
		move.w	#64-1,d7
.copyenvcols:	move.w	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		dbra	d7,.copyenvcols

		lea.l	greets_texts+788,a0
		move.w	#2520-1,d7
.shoty:		move.w	#128-1,d6
.shotx:		move.b	(a0),d0
		add.b	#192,d0
		move.b	d0,(a0)+
		dbra	d6,.shotx
		dbra	d7,.shoty
		

		lea.l	greets_texts+20,a0
		lea.l	greets_rawtxt+20+192*3,a1
		move.w	#64-1,d7
.copyshotcols:	move.w	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		dbra	d7,.copyshotcols

		lea.l	greets_rawtxt+20,a0
		lea.l	greets_pal,a1
		bsr.w	conv_apxpal_to_falcpal

		lea.l	greets_whitepal,a0
		move.l	#$aaaa00aa,d0
		move.w	#256-1,d7
.whitepal:	move.l	d0,(a0)+
		dbra	d7,.whitepal

		rts


greets_runtime_init:
		bsr.w	greetsenv_runtime_init
		rts


;greets_endfadeout:
;		lea.l	greets_blackpal,a0
;		move.w	#256-1,d0
;		bsr.w	falcon_setpal
		
;		lea.l	greets_blackpal,a0
;		lea.l	greets_outpal,a1
;		move.w	#256-1,d0
;		bsr.w	falcon_fade

;		rts

greets_timer:
		bsr.w	greetsenv_timer
		rts

greets_vbl:
		cmp.l	#1,vbl_param
		bne.s	.nofadeout

		;subq.w	#1,.fadeslow
		;bne.s	.done
		;move.w	#3,.fadeslow

		lea.l	greets_blackpal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal
		
		lea.l	greets_blackpal,a0
		lea.l	greets_outpal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade

		bra.s	.done		

.nofadeout:	subq.w	#1,greets_flash
		bgt.s	.flash
		
		lea.l	greets_blackpal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal
		
		lea.l	greets_blackpal,a0
		lea.l	greets_pal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade
		
		bra.s	.noflash
		
.flash:		lea.l	greets_blackpal+768,a0
		move.w	#64-1,d7
.copyflash:	move.l	#$88880088,(a0)+
		dbra	d7,.copyflash

.done:
.noflash:	add.l	#256,greets_txtofs
		and.l	#$ffff,greets_txtofs

		rts

.fadeslow:	dc.w	3


greets_main:
		bsr.w	greets_ofsbg
		bsr.w	greets_puttexts
		bsr.w	greetsenv_main
		bsr.w	greets_c2p
		rts


greets_swaptexts:
		lea.l	greets_textsadr,a0
		move.l	(a0),d0
		move.w	#22-2,d7
.loop:		move.l	4(a0),(a0)+
		dbra	d7,.loop
		move.l	d0,(a0)		
		rts

greets_puttexts:
		cmp.w	#1,greets_dotextswap
		bne.s	.noswap
		clr.w	greets_dotextswap	

		bsr.w	greets_swaptexts


		move.l	greets_textsadr,a0
		cmp.l	#greets_textsempty,a0
		beq.s	.noswap
		
		lea.l	greets_blackpal+128*4,a0
		move.w	#64-1,d7
.invenv:	move.l	(a0),d0
		not.l	d0
		move.l	d0,(a0)+
		dbra	d7,.invenv

.noswap:
		lea.l	chunky+192,a0
		move.l	greets_textsadr,a1
		move.l	#320-128,d0
		move.w	#180-1,d7
.y:		move.w	#128/4/4-1,d6
.x:		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		dbra	d6,.x
		add.l	d0,a0
		dbra	d7,.y
		
		rts



greets_ofsbg:	lea.l	chunky,a0
		lea.l	greets_txt+256*256,a1
		add.l	greets_txtofs,a1
		lea.l	greets_lut+20,a2
		lea.l	greets_fade+788,a3
		lea.l	greets_pic+788,a4
		
		clr.l	d0
		clr.l	d2
		move.l	#320-192,d1
		move.w	#180-1,d7
.y:		move.w	#192-1,d6
.x:
		move.w	(a2)+,d0
		move.b	(a1,d0.l),d2
		add.b	(a4)+,d2
		lsr.b	#1,d2
		add.b	(a3)+,d2
		move.b	d2,(a0)+
	
		dbra	d6,.x
		add.l	d1,a0
		dbra	d7,.y
		rts



greets_c2p:	lea.l	chunky,a0
		move.l	screen_adr,a1
		add.l	#320*30,a1
		move.l	#320*180,BPLSIZE
		bsr.w	c2p_8pl
		rts


		include	'greets\greetenv.s'
		

		section	data

greets_lut:	incbin	'greets\rippofs1.apx'
		even

greets_rawtxt:	incbin	'greets\ripptxt1.apx'
		even

greets_fade:	incbin	'greets\rippfad1.apx'
		even
		
greets_pic:	incbin	'greets\ripppic1.apx'
		even

greets_texts:	incbin	'greets\texts1c.apx'
		even
		
greets_txtofs:	dc.l	0		
greets_textofs:	dc.l	128*180*0

greets_flash:	dc.w	0
greets_dotextswap:	dc.w	0

greets_textsadr:
		dc.l	greets_textsempty
		dc.l	greets_texts+788+128*180*0
		dc.l	greets_texts+788+128*180*1
		dc.l	greets_texts+788+128*180*2
		dc.l	greets_texts+788+128*180*3
		dc.l	greets_texts+788+128*180*4
		dc.l	greets_texts+788+128*180*5
		dc.l	greets_texts+788+128*180*6
		dc.l	greets_texts+788+128*180*7
		dc.l	greets_texts+788+128*180*8
		dc.l	greets_texts+788+128*180*9
		dc.l	greets_texts+788+128*180*10
		dc.l	greets_texts+788+128*180*11
		dc.l	greets_texts+788+128*180*12
		dc.l	greets_texts+788+128*180*13
		dc.l	greets_textsempty
		dc.l	greets_textsempty
		dc.l	greets_textsempty
		dc.l	greets_textsempty
		dc.l	greets_textsempty
		dc.l	greets_textsempty


		section	bss

greets_textsempty:	ds.b	128*180
greets_txt:	ds.b	256*256*3
greets_pal:	ds.l	256
greets_blackpal:ds.l	256
greets_whitepal:ds.l	256
greets_outpal:	ds.l	256
		
		section	text