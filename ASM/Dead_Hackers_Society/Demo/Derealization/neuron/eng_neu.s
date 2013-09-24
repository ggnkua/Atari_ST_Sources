
	section	text

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Init routines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

real3d_runtime_init_neuron:
	bsr	init_texmap

	;--- init complete scene -------------
	
	lea	scene_neuron_sky,a0
	bsr	init_scene
	bsr	fix_sky
	bsr	scale_tcoords

	lea	scene_neuron,a0
	bsr	init_scene
	bsr	fix_tex_neuron
;	bsr	fix_transform_16
	bsr	scale_tcoords
;	fmove.s	#1.0,fp0
;	bsr	scale_scene	;scale to correct clip range
;	bsr	set_palette

		lea.l	tex_neuron_bak+20,a0
		lea.l	neuron_pal,a1
		bsr.w	conv_apxpal_to_falcpal
		
		;lea.l	neuron_pal,a0
		;move.w	#256-1,d0
		;bsr.w	falcon_setpal


	clr.l	t
	bsr.w	clear_all_screens
	rts


fix_tex_neuron:
	move.l	tcoords,a0
	move.w	TNUMVERTS,d7
	subq.w	#1,d7
.lp:
	fmove.s	(a0),fp0	;u
	fmove.s	4(a0),fp1	;v

;	ftst	fp0
;	fbge	.vok1
;	fmove.s	#0,fp0
;.vok1:
;	fcmp.s	#1.0,fp0
;	fblt	.vok2
;	fmove.s	#0.99,fp0
;.vok2:

	fmul.s	#2,fp0		;wrap
	fmul.s	#2,fp1
	fmove.s	fp0,(a0)+	;swap u-v
	fmove.s	fp1,(a0)+
	dbra	d7,.lp
	rts


neuron_timer:
		move.l	main_param,d0
		move.l	d0,a0
		cmp.l	.current_clip,d0
		beq.s	.nochange
		move.l	(a0),t
		move.l	d0,.current_clip
		move.w	#1,neuron_flash

.nochange:	move.l	4(a0),d0
		add.l	d0,t
		

		rts
.current_clip:	dc.l	0


neuron_vbl:
		cmp.l	#1,vbl_param
		bne.s	.normal

		lea.l	neuron_blackpal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal
		
		lea.l	neuron_blackpal,a0
		lea.l	neuron_outpal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade
		bra.s	.done
		
.normal:	cmp.w	#1,neuron_flash
		bne.s	.noflash
		clr.w	neuron_flash
		lea.l	neuron_blackpal,a0
		move.l	#$88880088,d0
		move.w	#256-1,d7
.flashit:	move.l	d0,(a0)+
		dbra	d7,.flashit
		bra.s	.done
		
.noflash:	lea.l	neuron_blackpal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal
		
		lea.l	neuron_blackpal,a0
		lea.l	neuron_pal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade

.done:		rts

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Main routines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

real3d_main_neuron:

	bsr.w	real3d_chunkyclear_320x180 ;optimized clear

	lea	scene_neuron_sky,a0
	bsr	init_scene
	bsr	play_camera
	bsr	project_coords
	bsr	get_faces
	bsr	counting_sort
	bsr	real3d_draw_sky

	lea	scene_neuron,a0
	bsr	init_scene

	bsr	play_camera
	bsr	project_coords
	bsr	get_faces
	bsr	counting_sort
	bsr	real3d_draw_neuron

		bsr.w	neuron_text

	lea.l	chunky,a0
	move.l	screen_adr,a1
	lea.l	XSCR*(240-YSCR)/2(a1),a1
	move.l	#XSCR*YSCR,BPLSIZE
	bsr.w	c2p_8pl
	rts


neuron_text:
		lea.l	chunky,a0
		lea.l	neuron_textdata+788,a1

		move.l	main_param,a6
		move.l	8(a6),d0
		add.l	d0,a1
		move.l	12(a6),d0
		add.l	d0,a0
		
		clr.l	d0
		move.w	#40-1,d7
.y:		move.w	#128-1,d6
.x:
		move.b	(a1)+,d0
		beq.s	.no
		move.b	d0,(a0)
.no:		addq.l	#1,a0
		dbra	d6,.x
		lea.l	320-128(a0),a0
		dbra	d7,.y


		rts

;
; Draw faces in scene
;

real3d_draw_neuron:
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

	lea	polygon+3*4,a0	;v
	fmove.s	(a0),fp0	;v1
	fmove.s	1*VERTSIZE(a0),fp1	;v2
	fmove.s	2*VERTSIZE(a0),fp2	;v3

	fmove	fp0,fp3		;vmin
	fcmp	fp1,fp3
	fbge	.nov1
	fmove	fp1,fp3
.nov1:
	fcmp	fp2,fp3
	fbge	.nov2
	fmove	fp2,fp3
.nov2:
	fsub	fp3,fp0
	fsub	fp3,fp1
	fsub	fp3,fp2

	fmove.s	fp0,(a0)
	fmove.s	fp1,1*VERTSIZE(a0)
	fmove.s	fp2,2*VERTSIZE(a0)

	fdiv.s	#256,fp3
	fdiv.s	#65536,fp3
	fmul.s	#256,fp3
	fmove.l	fp3,d2
	lsl.l	#8,d2

	move.w	#3,d0		;num sides, only 3 sides now
;	move.w	(a4)+,d2	;texture index
;	move.w	(a4)+,d1	;type
	addq.l	#4,a4

	move.l	textures,a0
;	move.l	(a0,d2.w*4),a0
	move.l	(a0),a0		;one texture 256x1024
	add.l	#128*256+127,a0	;center texture
	add.l	d2,a0		;individual polygon offset


	move.w	#POLY_TEX,d1
	move.l	a0,d2
	lea	polygon,a0
	lea.l	chunky,a1
	bsr	gizpoly	
	dbra	d7,.faclop

	rts


real3d_draw_sky_neuron:
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

	lea	polygon+3*4,a0	;v
	fmove.s	(a0),fp0	;v1
	fmove.s	1*VERTSIZE(a0),fp1	;v2
	fmove.s	2*VERTSIZE(a0),fp2	;v3

	fmove	fp0,fp3		;vmin
	fcmp	fp1,fp3
	fbge	.nov1
	fmove	fp1,fp3
.nov1:
	fcmp	fp2,fp3
	fbge	.nov2
	fmove	fp2,fp3
.nov2:
	fsub	fp3,fp0
	fsub	fp3,fp1
	fsub	fp3,fp2

	fmove.s	fp0,(a0)
	fmove.s	fp1,1*VERTSIZE(a0)
	fmove.s	fp2,2*VERTSIZE(a0)

	fdiv.s	#256,fp3
	fdiv.s	#65536,fp3
	fmul.s	#256,fp3
	fmove.l	fp3,d2
	lsl.l	#8,d2

	move.w	#3,d0		;num sides, only 3 sides now
;	move.w	(a4)+,d2	;texture index
;	move.w	(a4)+,d1	;type
	addq.l	#4,a4

	move.l	textures,a0
;	move.l	(a0,d2.w*4),a0
	move.l	(a0),a0		;one texture 256x1024
	add.l	#128*256+127,a0	;center texture
	add.l	d2,a0		;individual polygon offset


	move.w	#POLY_TEX,d1
	move.l	a0,d2
	lea	polygon,a0
	lea.l	chunky,a1
	bsr	gizpoly	
	dbra	d7,.faclop

	rts



real3d_draw_neuron_tile:
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

;%%% Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		section	data

		;spline start, spline add, text ofs, text screen ofs
neuron_clip01:	dc.l	0,10,128*40*0,320*20+20
neuron_clip02:	dc.l	50000,-8,128*40*1,320*20+172
neuron_clip03:	dc.l	100000,-10,128*40*2,320*120+172
neuron_clip04:	dc.l	165000,-4,128*40*3,320*120+20
neuron_clip05:	dc.l	200000,8,128*40*4,320*20+20
neuron_clip06:	dc.l	1000,-4,128*40*5,320*20+172
neuron_flash:	dc.w	1

neuron_textdata:	incbin	'neuron\alltxt02.apx'
			even

;scene_land:	include	'land\land.inc'
;scene_neuron_tile:	include	'neuron\neuron.inc'
scene_neuron:	include	'neuron\neubak.inc'
scene_neuron_sky:	include	'neuron\sky.inc'
;scene_sky:	include	'skycube\sky.inc'

		section	bss
		
neuron_pal:	ds.l	256
neuron_blackpal:ds.l	256
neuron_outpal:	ds.l	256
	section	text

