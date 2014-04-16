
	section	text

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Init routines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

real3d_init_land:
		;bsr.w	real3d_init_blur
		;bsr.w	real3d_init_blur
		;bsr.w	real3d_init_blur


		lea.l	landpal01,a0
		lea.l	landpal02,a1
		lea.l	landpal03,a2
		lea.l	landpal04,a3
		lea.l	landpal05,a3
		
		move.w	#256-1,d7
.initpal:	move.l	#$00000000,(a0)+
		move.l	#$66660066,(a1)+
		move.l	#$66660066,(a2)+
		move.l	#$66660066,(a3)+
		move.l	#$66660066,(a4)+
		dbra	d7,.initpal

		rts

real3d_init_blur:
		lea.l	tex_land+788,a0
		lea.l	-1024(a0),a1
		lea.l	-1(a0),a2
		lea.l	1024(a0),a3
		lea.l	1(a0),a4
		move.l	#1024*1024-1,d7
.blur:		clr.l	d0
		clr.l	d1
		move.b	(a1)+,d0
		move.b	(a2)+,d1
		add.l	d1,d0
		move.b	(a3)+,d1
		add.l	d1,d0
		move.b	(a4)+,d1
		add.l	d1,d0
		lsr.l	#2,d0
		move.b	d0,(a0)+

		subq.l	#1,d7
		bpl.s	.blur


		rts


real3d_runtime_init_land:


	bsr	init_texmap

	;--- init complete scene -------------
	
	lea	scene_land_sky,a0
	bsr	init_scene
	bsr	fix_sky
	bsr	scale_tcoords

	lea	scene_land,a0
	bsr	init_scene
	bsr	fix_tex_tile
	bsr	fix_transform_16
	bsr	scale_tcoords
;	fmove.s	#1.0,fp0
;	bsr	scale_scene	;scale to correct clip range
;	bsr	set_palette

		lea.l	tex_land+20,a0
		lea.l	land_pal,a1
		bsr.w	conv_apxpal_to_falcpal
		
		;lea.l	land_pal,a0
		;move.w	#256-1,d0
		;bsr.w	falcon_setpal
		;lea.l	landpal01,a0
		;move.w	#248-1,d0
		;bsr.w	falcon_setpal


	move.l	land_clip01,t
	
;	bsr.w	clear_all_screens
	rts

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Main routines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

real3d_main_land:

	bsr.w	real3d_chunkyclear_320x180 ;optimized clear

	lea	scene_land_sky,a0
	bsr	init_scene
	bsr	play_camera
	bsr	project_coords
	bsr	get_faces
	bsr	counting_sort
	bsr	real3d_draw_sky

	lea	scene_land,a0
	bsr	init_scene
	bsr	play_camera
	bsr	project_coords
	bsr	get_faces
	bsr	counting_sort
	bsr	real3d_draw_land

		bsr.w	landtext_main

	lea.l	chunky,a0
	move.l	screen_adr,a1
	lea.l	XSCR*(240-YSCR)/2(a1),a1
	move.l	#XSCR*YSCR,BPLSIZE
	bsr.w	c2p_8pl
	rts


land_timer:
		move.l	timer_param,d0
		move.l	d0,a0
		cmp.l	.current_clip,d0
		beq.s	.continue
		move.l	d0,.current_clip
		move.l	(a0),t
		
.continue:	move.l	4(a0),d0
		add.l	d0,t

		rts

.current_clip:	dc.l	land_clip01


land_vbl:
		move.l	timer_param,a0
		move.l	8(a0),.pal
		move.l	.pal,a0
		move.w	#248-1,d0
		bsr.w	falcon_setpal

		move.l	.pal,a0
		lea.l	land_pal,a1
		move.w	#248-1,d0
		bsr.w	falcon_fade		

		rts
.pal:		dc.l	land_clip01+8



;
; Draw faces in scene
;

real3d_draw_sky:
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



real3d_draw_land:
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

fix_sky:
	move.l	tcoords,a0
	move.w	TNUMVERTS,d7
	subq.w	#1,d7
.lp:
	fmove.s	(a0),fp0	;v
	fmove.s	4(a0),fp1	;v
	
	;clip uv for wrapping
	ftst	fp0
	fbge	.uminok
	fmove.s	#0,fp0
.uminok:
	fcmp.s	#1.0,fp0
	fblt	.umaxok
	fmove.s	#0.999,fp0
.umaxok:
	
	fmul.s	#4,fp0		;wrap
	fmul.s	#1,fp1
	fmove.s	fp1,(a0)+	;swap u-v
	fmove.s	fp0,(a0)+
	dbra	d7,.lp
	rts


fix_tex_tile:
	move.l	faces,a4
	move.l	tcoords,a6
	move.w	NUMFACES,d7
	subq.w	#1,d7
.fl:
	add.l	#3*2,a4		;skip coord index

	move.w	(a4)+,d2	;f1
	move.w	(a4)+,d3	;f2
	move.w	(a4)+,d4	;f3

	mulu	#2*4,d2
	mulu	#2*4,d3
	mulu	#2*4,d4

	bra	.noswap
	fmove.s	#1,fp0
	fmove.s	#1,fp1
	fmove.s	#1,fp2
	fsub.s	(a6,d2.w),fp0	;u
	fsub.s	(a6,d3.w),fp1
	fsub.s	(a6,d4.w),fp2
	fmove.s	#1,fp3
	fmove.s	#1,fp4
	fmove.s	#1,fp5
	fsub.s	4(a6,d2.w),fp3	;v
	fsub.s	4(a6,d3.w),fp4
	fsub.s	4(a6,d4.w),fp5
.noswap:
	fmove.s	(a6,d2.w),fp0	;u
	fmove.s	(a6,d3.w),fp1
	fmove.s	(a6,d4.w),fp2
	fmove.s	4(a6,d2.w),fp3	;v
	fmove.s	4(a6,d3.w),fp4
	fmove.s	4(a6,d4.w),fp5

	
	
	fmove	fp0,fp6
	fadd	fp1,fp6
	fadd	fp2,fp6	;avg u
	fmove	fp3,fp7
	fadd	fp4,fp7
	fadd	fp5,fp7	;avg v
	fdiv.s	#3,fp6
	fdiv.s	#3,fp7

	fmul.s	#4,fp6
	fmul.s	#4,fp7
	
	fsub.s	#0.99,fp6
	fsub.s	#0.99,fp7
	
	fmove.l	fp6,d0
	fmove.l	fp7,d1

	fmove.l	d0,fp6
	fmove.l	d1,fp7
	fdiv.s	#4,fp6
	fdiv.s	#4,fp7

;	fneg	fp6
;	fneg	fp7

;	fadd.s	#0.005,fp6
;	fadd.s	#0.005,fp7

	fsub	fp6,fp0
	fsub	fp6,fp1
	fsub	fp6,fp2
	fsub	fp7,fp3
	fsub	fp7,fp4
	fsub	fp7,fp5
	fmul.s	#4,fp0
	fmul.s	#4,fp1
	fmul.s	#4,fp2
	fmul.s	#4,fp3
	fmul.s	#4,fp4
	fmul.s	#4,fp5
	
	bra	.nouvclip

	ftst	fp0
	fble	.o1
	fmove.s	#-0,fp0
.o1:
	ftst	fp1
	fble	.o2
	fmove.s	#-0,fp1
.o2:
	ftst	fp2
	fble	.o3
	fmove.s	#-0,fp2
.o3:
	ftst	fp3
	fble	.o4
	fmove.s	#-0,fp3
.o4:
	ftst	fp4
	fble	.o5
	fmove.s	#-0,fp4
.o5:
	ftst	fp5
	fble	.o6
	fmove.s	#-0,fp5
.o6:
;.nouvclip:

	fcmp.s	#-1,fp0
	fbgt	.m1
	fmove.s	#-0.99,fp0
.m1:
	fcmp.s	#-1,fp1
	fbgt	.m2
	fmove.s	#-0.99,fp1
.m2:
	fcmp.s	#-1,fp2
	fbgt	.m3
	fmove.s	#-0.99,fp2
.m3:
	fcmp.s	#-1,fp3
	fbgt	.m4
	fmove.s	#-0.99,fp3
.m4:
	fcmp.s	#-1,fp4
	fbgt	.m5
	fmove.s	#-0.99,fp4
.m5:
	fcmp.s	#-1,fp5
	fbgt	.m6
	fmove.s	#-0.99,fp5
.m6:

;.nouvclip:

	fneg	fp0
	fneg	fp1
	fneg	fp2
	fneg	fp3
	fneg	fp4
	fneg	fp5
.nouvclip:
	fmove.s	fp0,(a6,d2.w)
	fmove.s	fp1,(a6,d3.w)
	fmove.s	fp2,(a6,d4.w)
	fmove.s	fp3,4(a6,d2.w)
	fmove.s	fp4,4(a6,d3.w)
	fmove.s	fp5,4(a6,d4.w)
.oo:

	lsl.l	#2,d1
	add.l	d1,d0	;texindx

	;eor.b	#15,d0	;invert face order...
;	sub.b	#5,d0
	and.l	#15,d0

	move.w	d0,(a4)+
	move.w	#0,(a4)+

;	add.l	#2*2,a4

	dbra	d7,.fl
	rts
	

fix_transform_16:
	lea	tex_land+20+768,a0 ;18+768,a0
	lea	tex_land1024,a1
	lea	textures_land,a3
	move.w	#16-1,d7	;4x4 squares
.sq:
	move.w	#15,d0
	sub.w	d7,d0		;0->15
	move.w	d0,d1
	and.w	#3,d0
	lsr.w	#2,d1
	and.w	#3,d1
;	eor.b	#3,d1

	mulu	#256,d0
	mulu	#256,d1
	mulu	#1024,d1
	add.l	d1,d0
	lea	(a0,d0.l),a2	;tex square to read from
	move.l	a1,(a3)+	;write new tex ptr to scene

	move.w	#256-1,d6
.y:
	move.w	#256-1,d5
.x:
	move.b	(a2)+,(a1)+
	dbra	d5,.x
	add.l	#1024-256,a2	;next line
	dbra	d6,.y

	dbra	d7,.sq

	rts


	include	'land\texts.s'

;%%% Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	section	data

;---------------------- start,addvalue,startpal,textdata,textpos
land_clip01:	dc.l	41000,1,landpal01,landtext_data+788+128*40*0,320*20+20
land_clip02:	dc.l	100000,-7,landpal01,landtext_data+788+128*40*1,320*30+180
land_clip03:	dc.l	115000,6,landpal03,landtext_data+788+128*40*2,320*40+40
land_clip04:	dc.l	140000,-5,landpal04,landtext_data+788+128*40*3,320*110+80
land_clip05:	dc.l	80000,-2,landpal05,landtext_data+788+128*40*4,320*30+180
;-------------------------------------

;scene_land:	include	'land\land.inc'
scene_land:	include	'land\s2.inc'
scene_land_sky:	include	'land\sky.inc'
;scene_sky:	include	'skycube\sky.inc'

	section	bss
land_pal:	ds.l	256

landpal01:	ds.l	256
landpal02:	ds.l	256
landpal03:	ds.l	256
landpal04:	ds.l	256
landpal05:	ds.l	256

tex_land1024:	ds.b	1024*1024

	section	text

