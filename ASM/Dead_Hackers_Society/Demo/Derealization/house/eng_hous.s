
		section	text

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Init routines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

real3d_runtime_init_house:


	bsr	init_texmap

	;--- init complete scene -------------
	
	lea	scene_housesky,a0
	bsr	init_scene
	bsr	fix_sky
	bsr	scale_tcoords

	lea	scene_house,a0
	bsr	init_scene
;	bsr	fix_tex_tile
;	bsr	fix_transform_16
	bsr	scale_tcoords
	fmove.s	#10.0,fp0
	bsr	scale_scene	;scale to correct clip range
;	bsr	set_palette

		;lea.l	tex_housesky+20,a0
		lea.l	tex_hisp+20,a0
		lea.l	house_pal,a1
		bsr.w	conv_apxpal_to_falcpal

		lea.l	tex_hisp+20,a0
		lea.l	house_pal2,a1
		bsr.w	conv_apxpal_to_falcpal
		

	;clr.l	t
	lea.l	house_clip01,a0
	move.l	(a0),t
	
;	bsr.w	clear_all_screens
	rts

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Main routines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

real3d_main_house:

	bsr.w	house_clear

	lea	scene_housesky,a0
	bsr	init_scene
	bsr	play_camera
	bsr	project_coords
	bsr	get_faces
	bsr	counting_sort
	bsr	real3d_draw_sky

	lea	scene_house,a0
	bsr	init_scene
	bsr	play_camera
	bsr	project_coords
	bsr	get_faces
	bsr	counting_sort
	bsr	real3d_draw_house


		bsr.w	sal_mix

	lea.l	chunky,a0
	move.l	screen_adr,a1
	lea.l	XSCR*(240-YSCR)/2(a1),a1
	move.l	#XSCR*YSCR,BPLSIZE
	bsr.w	c2p_8pl
	rts


house_timer:
		move.l	timer_param,a0
		move.l	a0,d0
		cmp.l	.current_clip,d0
		beq.s	.nochange
		move.l	d0,.current_clip
		move.l	(a0),t
		move.w	#1,house_flash
.nochange:		
		move.l	4(a0),d0
		add.l	d0,t

		rts

.current_clip:	dc.l	house_clip01


house_vbl:
		cmp.l	#1,vbl_param
		bne.s	.noparam

		subq.w	#1,.wait
		bne.s	.done
		move.w	#3,.wait

		lea.l	house_pal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal
		
		lea.l	house_pal,a0
		lea.l	house_outpal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade
		bra.s	.done
		
		
.noparam:	cmp.w	#1,house_flash
		bne.s	.noflash
		clr.w	house_flash
		
		lea.l	house_pal,a0
		move.w	#256-1,d7
.fill:		move.l	#$66660066,(a0)+
		dbra	d7,.fill

.noflash:	lea.l	house_pal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal

		lea.l	house_pal,a0
		lea.l	house_pal2,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade
.done:
		rts

.wait:		dc.w	3

real3d_draw_house:
	lea	rotobj,a3
	move.l	tcoords,a6
	lea	facelst_sorted,a5
	clr.l	d0

	move.w	NUMFACES,d7
	subq.w	#1,d7
.faclop:
	move.l	faces,a4
	move.l	(a5)+,d4	;face num : z val
	swap	d4
	mulu	#FACE_SIZE,d4
	add.l	d4,a4

	lea	polygon,a0
	moveq.l	#3-1,d6

.vertlop:			;copy vert data to current polygon
	move.w	(a4)+,d1	;coord index
	move.w	3*2-2(a4),d2	;tcoord index
	mulu	#VERTSIZE,d1
	mulu	#2*4,d2	    	;tcoord size
	lea	(a3,d1.l),a1
	lea	(a6,d2.l),a2
	move.l	(a1)+,(a0)+	;x
	move.l	(a1)+,(a0)+	;y
	move.l	(a1)+,(a0)+	;z
	move.l	(a2)+,(a0)+	;u
	move.l	(a2)+,(a0)+	;v
	add.l	#VERTSIZE-20,a0
	dbra	d6,.vertlop

	add.l	#3*2,a4
	move.w	#3,d0		;num sides, only 3 sides now
	move.w	(a4)+,d2	;texture index
	move.w	(a4)+,d1	;type

	move.l	textures,a0
	move.l	(a0,d2.w*4),a0
	add.l	#128*256+127,a0	;center texture
	move.w	#POLY_TEX,d1
	move.l	a0,d2
	lea	polygon,a0
	lea.l	chunky,a1
	bsr	gizpoly	
	dbra	d7,.faclop

	rts



house_endfadeout:
		lea.l	house_outpal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal
		
		lea.l	house_outpal,a0
		lea.l	house_endingpal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade

		rts

house_clear:
	lea.l	chunky+XSCR*YSCR,a6
	movem.l	.zero,d0-a5	;56
	move.w	#257-1,.count	;56*4*257 = 57568 (missing 32bytes)
.loop:
	rept	4
	movem.l	d0-a5,-(a6)
	endr
	subq.w	#1,.count
	bpl.w	.loop

	movem.l	d0-d7,-(a6)	;56	remaining 32bytes
	rts

.zero:	dcb.l	16,$20202020
.count:	dc.w	0

house_outpal:	dcb.l	256,$aaaa00aa


;%%% Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	section	data

		;start,add
house_clip01:	dc.l	10000,4
house_clip02:	dc.l	55000,-5

house_flash:	dc.w	0

scene_housesky:	include	'house\sky.inc'
scene_house:	include	'house\hispan.inc'

	section	bss
house_pal:	ds.l	256
house_pal2:	ds.l	256
house_endingpal:ds.l	256
tex_house1024:	ds.b	1024*1024

	section	text

