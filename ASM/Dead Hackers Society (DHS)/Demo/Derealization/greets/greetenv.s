
		section	text

greetsenv_runtime_init:
	
		bsr.w	init_texmap

		lea.l	greetsenv_scene,a0
		;lea.l	scene_env,a0
		bsr.w	init_scene
		bsr.w	wavefront_obj_fix
		bsr.w	calc_normals_env
	
		clr.l	t

*		move.l	#$00ff0000,$ffff9800.w

		bsr.w	clear_all_screens

		rts
	

greetsenv_main:
		bsr.w	greetsenv_new_angs
		bsr.w	spin_scene
		bsr.w	project_coords_env
		bsr.w	get_faces
		bsr.w	counting_sort
		bsr.w	greetsenv_draw

		rts


greetsenv_new_angs:

		fmove.l	t,fp0
		fmul.s	#0.0004,fp0
		fmove.s	fp0,anz_env
		*fmove.s	#0,fp0
		fmove.s	fp0,any_env
		fmove.s	fp0,anx_env

		fmove.s	#120,fp0
		fmove.s	fp0,xpos_env
		fmove.s	#90,fp0
		fmove.s	fp0,ypos_env
		;fmove.s	#30,fp0	;10
		;fmove.l	greetsenv_size,fp0
		;fmul.s	#0.01,fp0
		fmove.s	#31,fp0
		fmove.s	fp0,zpos_env

		rts

greetsenv_timer:
		addq.l	#4,t


		subq.w	#1,.timer
		bne.s	.noreset

;		*move.l	#45000,greetsenv_size
;		move.l	#2800,greetsenv_size

		move.w	#393,.timer
		move.w	#3,greets_flash
		move.w	#1,greets_dotextswap
;		bra.s	.done
		
.noreset:
	*sub.l	#112,greetsenv_size
;		cmp.l	#2000,greetsenv_size
;		bgt.s	.done
;		move.l	#2000,greetsenv_size

.done:
		rts

.timer:		dc.w	40+195

greetsenv_draw:
		lea.l	rotobj,a3
		lea.l	facelst_sorted,a5
		clr.l	d0

		move.w	NUMFACES,d7
		subq.w	#1,d7
.faclop:
		move.l	faces,a4
		move.l	(a5)+,d4	;face num : z val
		swap	d4
		mulu	#FACE_SIZE,d4
		add.l	d4,a4

		lea.l	polygon,a0
		moveq.l	#3-1,d6

.vertlop:				;copy vert data to current polygon
		move.w	(a4)+,d1	;coord index
		mulu	#VERTSIZE,d1
		lea.l	(a3,d1.l),a1
		move.l	(a1)+,(a0)+	;x
		move.l	(a1)+,(a0)+	;y
		move.l	(a1)+,(a0)+	;z
		move.l	(a1)+,(a0)+	;u
		move.l	(a1)+,(a0)+	;v

		add.l	#VERTSIZE-5*4,a0
		dbra	d6,.vertlop

		addq.l	#3*2,a4
		moveq.l	#3,d0		;num sides, only 3 sides now
		move.w	(a4)+,d2	;texture index
		move.w	(a4)+,d1	;type

		move.l	textures,a0
		move.l	(a0,d2.w*4),a0

		add.l	#128*256+127,a0	;center texture
		
		move.l	a0,d2
		lea.l	polygon,a0
		lea.l	chunky,a1
		bsr.w	gizpoly	
		dbra	d7,.faclop

		rts




		section	data

greetsenv_size:		dc.l	45000

greetsenv_scene:	include	'greets\knot3.r3d'


		section	text

