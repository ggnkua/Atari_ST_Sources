
	section	text

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Init routines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

real3d_runtime_init_sal:
	bsr	init_texmap

	;--- init complete scene -------------
	
	lea	scene_sal,a0
	bsr	init_scene
	bsr	scale_tcoords

	fmove.s	#100.0,fp0
	bsr	scale_scene	;scale to correct clip range
;	bsr	set_palette

		lea.l	tex_sal+20,a0
		lea.l	sal_pal,a1
		bsr.w	conv_apxpal_to_falcpal


	clr.l	t
	bsr.w	clear_all_screens
	rts


sal_vbl:
		cmp.w	#1,sal_flash
		bne.s	.noflash

		lea.l	sal_blackpal,a0
		move.l	#$88880088,d0
		move.w	#256-1,d7
.flash:		move.l	d0,(a0)+
		dbra	d7,.flash

		clr.w	sal_flash
		bra.s	.done
		
.noflash:	lea.l	sal_blackpal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal

		lea.l	sal_blackpal,a0
		lea.l	sal_pal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade
.done:
		rts

sal_timer:
		move.l	timer_param,a0
		move.l	a0,d0
		cmp.l	.clip,d0
		beq.s	.continue
		move.l	(a0),d0
		move.l	a0,.clip
		move.l	d0,t
		move.w	#1,sal_flash
.continue:	move.l	4(a0),d0
		add.l	d0,t
		rts
.clip:		dc.l	sal_clip01

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Main routines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

real3d_main_sal:
;	bsr.w	real3d_chunkyclear_320x180 ;optimized clear

	bsr	play_camera
	bsr	project_coords
	bsr	get_faces
	bsr	counting_sort
	bsr	real3d_draw_sal

		bsr.w	sal_mix

	lea.l	chunky,a0
	move.l	screen_adr,a1
	lea.l	XSCR*(240-YSCR)/2(a1),a1
	move.l	#XSCR*YSCR,BPLSIZE
	bsr.w	c2p_8pl
	rts


sal_mix:
		lea.l	chunky,a0
		lea.l	sal_girl+788,a1
		move.w	#180-1,d7
.y:		move.w	#320/4-1,d6
.x:
		move.l	(a1)+,d0
		sub.l	d0,(a0)+

		dbra	d6,.x
		dbra	d7,.y

		rts

;
; Draw faces in scene
;

real3d_draw_sal:
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
		;start, add
sal_clip01:	dc.l	0,6
sal_clip02:	dc.l	200000,-10
sal_clip03:	dc.l	10000,12
sal_flash:	dc.w	0

sal_girl:	incbin	'sal\title2.apx'
		even

scene_sal:	include	'sal\sal.inc'

		section	bss

sal_blackpal:	ds.l	256
sal_pal:	ds.l	256

	section	text

