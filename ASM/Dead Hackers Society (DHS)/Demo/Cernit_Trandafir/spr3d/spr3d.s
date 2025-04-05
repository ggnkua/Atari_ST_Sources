; Altparty 2009 STe demo
; Sprite 3D with BLiTTER
;
; spr3d.s

spr3d_maxvertex:	equ	40
spr3d_frames:		equ	256
spr3d_showcpu:		equ	0

		section	text

		include	'spr3d/3d.s'
		include	'spr3d/greets.s'
		include	'spr3d/stars.s'
		include	'spr3d/64x64.s'
		include	'spr3d/48x48.s'
		include	'spr3d/32x32.s'
		include	'spr3d/16x16.s'
		include	'spr3d/obj_mega.s'
		include	'spr3d/obj_cubs.s'
		include	'spr3d/obj_str1.s'
		include	'spr3d/obj_64.s'

;-------------- INIT -----------------------------------------------------------
spr3d_init:	rts


;-------------- RUNTIME INIT ---------------------------------------------------
spr3d_runtime_init_2pl:
		subq.w	#1,.once
		bne.w	.done

		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		ifne	init_finish
		move.w	#$0700,$ffff8240.w
		endc

		;depack sprites
		lea.l	spr3d_sprites_ice,a0
		lea.l	spr3d_sprites,a1
		jsr	ice

		bsr.w	spr3d_genmask64
		bsr.w	spr3d_genmask48
		bsr.w	spr3d_genmask32
		bsr.w	spr3d_genmask16

		;depack 2bpl background
		lea.l	spr3d_2plbg_ice,a0
		lea.l	spr3d_2plbg,a1
		jsr	ice

		;copy 2pl background to screen
		move.l	screen_adr,a0
		lea.l	192*65(a0),a0
		move.l	screen_adr2,a1
		lea.l	192*65(a1),a1
		lea.l	spr3d_2plbg+80*199,a2
		move.w	#200-1,d7
.bgy:		move.w	#320/16-1,d6
.bgx:		move.l	(a2)+,d0
		move.l	d0,(a0)
		move.l	d0,(a1)
		addq.l	#8,a0
		addq.l	#8,a1
		dbra	d6,.bgx
		lea.l	192-160(a0),a0
		lea.l	192-160(a1),a1
		lea.l	-80*2(a2),a2
		dbra	d7,.bgy

		;generate scanline multab about 32k cycles faster without muls
		; (340 lines signed - any more gives overflow)
		lea.l	spr3d_multab192,a0
		move.l	#-170*192,d0
		move.l	#192,d1
		move.w	#170*2-1,d7
.multab:	
		move.w	d0,(a0)+
		add.l	d1,d0
		dbra	d7,.multab

		move.b	#16,$ffff820f.w			;32 bytes extra linewidth


		ifne	init_finish
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1

spr3d_stars_runtime_init:
		subq.w	#1,.once
		bne.s	.done
		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal
		
		ifne	init_finish
		move.w	#$700,$ffff8240.w
		endc

		move.b	#16,$ffff820f.w			;32 bytes extra linewidth

		bsr.w	spr3d_stars_init

		;movem.l	spr3d_4pl_pal,d0-d7
		;movem.l	d0-d7,$ffff8240.w

		ifne	init_finish
		move.w	#$0070,$ffff8240.w
		endc
.done
		rts	

.once:		dc.w	1

spr3d_runtime_init_4pl:
		subq.w	#1,.once
		bne.w	.done
		ifne	init_finish
		move.w	#$0700,$ffff8240.w
		endc

		;depack sprites
		lea.l	spr3d_sprites_ice,a0
		lea.l	spr3d_sprites,a1
		jsr	ice

		bsr.w	spr3d_genmask64
		bsr.w	spr3d_genmask48
		bsr.w	spr3d_genmask32
		bsr.w	spr3d_genmask16

		;depack greetings text
		lea.l	greets_data_ice,a0
		lea.l	greets_data,a1
		jsr	ice

		;generate scanline multab about 32k cycles faster without muls
		; (340 lines signed - any more gives overflow)
		lea.l	spr3d_multab192,a0
		move.l	#-170*192,d0
		move.l	#192,d1
		move.w	#170*2-1,d7
.multab:	
		move.w	d0,(a0)+
		add.l	d1,d0
		dbra	d7,.multab

		jsr	stars_extraclear

		ifne	init_finish
		move.w	#$0070,$ffff8240.w
		endc
		
.done:		rts
.once:		dc.w	1


spr3d_runtime_exit:
		jsr	black_pal
		clr.b	$ffff820f.w
		jsr	black_pal
		rts




;-------------- VBL -------------------------------------------------------------
spr3d_vbl:	move.l	screen_adr2,d0
		add.l	#192*65,d0
		lea.l	$ffff8203.w,a0
		movep.l	d0,0(a0)
		rts

spr3d_fadein_2pl:
		bsr.w	spr3d_vbl

		subq.w	#1,.wait
		bne.s	.no
		move.w	#4,.wait
		
		movem.l	spr3d_pal_black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		
		lea.l	spr3d_pal_black,a0
		lea.l	spr3d_pal_2pl,a1
		jsr	component_fade
		
.no:		rts
.wait:		dc.w	4

spr3d_4pl_fadein:
		bsr.s	spr3d_vbl

		movem.l	spr3d_4pl_black,d0-d7
		movem.l	d0-d7,$ffff8240.w

		lea.l	spr3d_4pl_black,a0
		lea.l	spr3d_4pl_pal,a1
		jsr	component_fade

		bsr.w	spr3d_stars	

		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2
		rts


spr3d_4pl_fadeout:
		bsr.w	spr3d_vbl

		subq.w	#1,.wait
		bne.s	.no
		move.w	#2,.wait
		
		movem.l	spr3d_4pl_black,d0-d7
		movem.l	d0-d7,$ffff8240.w

		lea.l	spr3d_4pl_black,a0
		lea.l	spr3d_4pl_black2,a1
		jsr	component_fade
.no:
		bsr.w	spr3d_stars	

		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2
		rts
.wait:		dc.w	2

;-------------- MAIN -----------------------------------------------------------

spr3d_main:
		tst.w	spr3d_do_main
		beq.w	.no

		;swap clearoffset for x/y move
		move.w	spr3d_xpos_clr,d0
		move.w	spr3d_xpos_clr+2,spr3d_xpos_clr
		move.w	d0,spr3d_xpos_clr+2
		move.w	spr3d_ypos_clr,d0
		move.w	spr3d_ypos_clr+2,spr3d_ypos_clr
		move.w	d0,spr3d_ypos_clr+2

		move.w	spr3d_numplanes,d0						
		bsr.w	spr3d_draw_object					;render 3D sprite-object

		addq.w	#1,spr3d_anipos
		and.w	#$000000ff,spr3d_anipos

		addq.w	#1,spr3d_aniposclr
		and.w	#$000000ff,spr3d_aniposclr

		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2


		ifne	spr3d_showcpu
			not.w	$ffff8240.w
			move.w	#32,d0
			jsr	pause
			not.w	$ffff8240.w
		endc
	

.no:		rts

spr3d_starsonly_vbl:
		bsr	spr3d_vbl
		bsr	spr3d_stars
		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2
		rts


spr3d_draw_object:	
; d0.w	= select number of bitplanes (2 or 4)
; Needs an object to have it's rotation/sorting precalc done first 

		cmp.w	#4,d0
		bne.s	.bpl2
		move.l	#.blit4,.blits
		move.l	#.clr4,.clrs
		bra.s	.doit
.bpl2:		move.l	#.blit2,.blits
		move.l	#.clr2,.clrs

.doit:		;clear old sprites
		moveq.l	#0,d0
		move.w	spr3d_aniposclr,d0
		lsl.w	#3,d0			;size of each vert
		mulu.w	spr3d_verts,d0		;numverts in object
		
		move.w	spr3d_verts,.count
		move.l	#spr3d_vertanim,.obj
		add.l	d0,.obj
.clr:		move.l	.obj,a0
		move.l	.clrs,a1
		move.w	(a0)+,d0		;x
		move.w	(a0)+,d1		;y
		add.w	spr3d_xpos_clr,d0
		add.w	spr3d_ypos_clr,d1
		addq.l	#2,a0			;z
		move.w	(a0)+,d2		;size
		move.l	a0,.obj
		lsl.w	#2,d2
		move.l	(a1,d2.w),a0
		jsr	(a0)

		subq.w	#1,.count
		bne.s	.clr


		tst.w	spr3d_dostars
		beq.s	.nostars
		bsr.w	spr3d_stars
.nostars:		

		;draw new sprites
		moveq.l	#0,d0
		move.w	spr3d_anipos,d0
		lsl.w	#3,d0
		mulu.w	spr3d_verts,d0
		
		move.w	spr3d_verts,.count
		move.l	#spr3d_vertanim,.obj
		add.l	d0,.obj
.spr:		move.l	.obj,a0
		move.l	.blits,a1
		move.w	(a0)+,d0		;x
		move.w	(a0)+,d1		;y
		add.w	spr3d_xpos,d0
		add.w	spr3d_ypos,d1
		addq.l	#2,a0			;x
		move.w	(a0)+,d2		;size
		move.l	a0,.obj
		lsl.w	#2,d2
		move.l	(a1,d2.w),a0
		jsr	(a0)

		subq.w	#1,.count
		bne.s	.spr


		rts
.obj:		dc.l	0
.count:		dc.w	0
.blits:		dc.l	0	;address to blit-rout
.clrs:		dc.l	0	;address to clear-rout
.blit4:		dc.l	spr3d_blit16_4pl,spr3d_blit32_4pl,spr3d_blit48_4pl,spr3d_blit64_4pl
.clr4:		dc.l	spr3d_clr16_4pl,spr3d_clr32_4pl,spr3d_clr48_4pl,spr3d_clr64_4pl
.blit2:		dc.l	spr3d_blit16_2pl,spr3d_blit32_2pl,spr3d_blit48_2pl,spr3d_blit64_2pl
.clr2:		dc.l	spr3d_clr16_2pl,spr3d_clr32_2pl,spr3d_clr48_2pl,spr3d_clr64_2pl


		
spr3d_precalc:
; a0	= address to object
		move.l	a0,.obj

		;rotate
		move.l	.obj,a0
		move.w	(a0)+,d0
		bsr.w	spr3d_rotate

		;sort
		move.l	.obj,a0
		move.w	(a0),d0
		bsr.w	spr3d_slowsort

		rts
.obj:		dc.l	0



spr3d_makeanim:
; a0	= address to object
; d0.w	= x rot even by 16
; d1.w	= y rot even by 16
; d2.w	= z rot even by 16
		move.l	a0,.adr
		move.w	(a0),spr3d_verts
		move.w	d0,.xrot
		move.w	d1,.yrot
		move.w	d2,.zrot

		move.w	#spr3d_frames-1,.count			;precalc rotation and sorting
		clr.w	spr3d_anx
		clr.w	spr3d_any
		clr.w	spr3d_anz

		
		move.l	#spr3d_vertanim,.aniadr
.precalc:	
		move.l	.adr,a0
		bsr.w	spr3d_precalc
		
		move.l	.aniadr,a0
		lea.l	spr3d_rotcoords,a2
		move.w	spr3d_verts,d7
		subq.w	#1,d7
.cpy:		move.l	(a2)+,(a0)+
		move.l	(a2)+,(a0)+
		dbra	d7,.cpy
		move.l	a0,.aniadr
		
		move.w	.xrot,d1
		add.w	d1,spr3d_anx
		move.w	.yrot,d1
		add.w	d1,spr3d_any
		move.w	.zrot,d1
		add.w	d1,spr3d_anz
		and.w	#$0fff,spr3d_anx
		and.w	#$0fff,spr3d_any
		and.w	#$0fff,spr3d_anz

		subq.w	#1,.count
		bpl.s	.precalc


		rts
.count:		dc.w	0
.adr:		dc.l	0
.aniadr:	dc.l	0
.xrot:		dc.w	0
.yrot:		dc.w	0
.zrot:		dc.w	0




		section	data

;0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15		
;0 8 1 9 2 a 3 b 4 d  5  e  6  e  7  f 

spr3d_4pl_black2:	dcb.w	16,$0000
spr3d_4pl_black:	dcb.w	16,$0000
spr3d_4pl_pal:		dc.w	$0000,$0001,$0009,$0002,$008a,$0013,$009b,$0024
			dc.w	$046f,$0135,$09bd,$0246,$0ace,$0357,$0bdf,$08ac



spr3d_pal_black:	dcb.w	16,$0000
spr3d_pal_black2:	dcb.w	16,$0000

p1:			set	$0a18
p2:			set	$0400
p3:			set	$0000
spr3d_pal_2pl:		dc.w	$0908,$0baa,$05db,$0e64,p1,p1,p1,p1
			dc.w	p2,p2,p2,p2,p3,p3,p3,p3

spr3d_pal_2pl2:		dc.w	$0908,$0baa,$05db,$0e64,$0908,$0baa,$05db,$0e64
			dc.w	$0908,$0baa,$05db,$0e64,$0908,$0baa,$05db,$0e64
		
spr3d_endmask1:		dc.w	%1111111111111111
			dc.w	%0111111111111111
			dc.w	%0011111111111111
			dc.w	%0001111111111111
			dc.w	%0000111111111111
			dc.w	%0000011111111111
			dc.w	%0000001111111111
			dc.w	%0000000111111111
			dc.w	%0000000011111111
			dc.w	%0000000001111111
			dc.w	%0000000000111111
			dc.w	%0000000000011111
			dc.w	%0000000000001111
			dc.w	%0000000000000111
			dc.w	%0000000000000011
			dc.w	%0000000000000001


spr3d_dostars:		dc.w	0
spr3d_anipos:		dc.w	2
spr3d_aniposclr:	dc.w	0
spr3d_numplanes:	dc.w	4
spr3d_verts:		dc.w	0
spr3d_xpos:		dc.w	0
spr3d_ypos:		dc.w	0
spr3d_xpos_clr:		dc.w	0,0
spr3d_ypos_clr:		dc.w	0,0
spr3d_do_main:		dc.w	0


spr3d_2plbg_ice:	incbin	'spr3d/bg.ice'
			even

spr3d_sprites_ice:	incbin	'spr3d/sprall.ice'
			even
			
;spr3d_mask16_4pl:	ds.b	32*16/2	;256	ofs	0
;spr3d_mask32_4pl:	ds.b	48*32/2	;768	ofs	256
;spr3d_mask48_4pl:	ds.b	64*48/2	;1536	ofs	1024
;spr3d_mask64_4pl:	ds.b	80*64/2	;2560	ofs	2560
;spr3d_mask16_2pl:	ds.b	32*16/4	;128	ofs	5120
;spr3d_mask32_2pl:	ds.b	48*32/4	;384	ofs	5248
;spr3d_mask48_2pl:	ds.b	64*48/4	;768	ofs	5632
;spr3d_mask64_2pl:	ds.b	80*64/4	;1280	ofs	6400


		section	text
