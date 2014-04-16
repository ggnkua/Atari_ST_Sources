
		section	text

scaryenv_runtime_init:
	
		bsr.w	init_texmap

		lea.l	scaryenv_scene,a0
		bsr.w	init_scene
		bsr.w	wavefront_obj_fix
		bsr.w	calc_normals_env
	
		clr.l	t
		rts
	

scaryenv_main:
		bsr.w	scaryenv_new_angs
		bsr.w	spin_scene
		bsr.w	project_coords_env
		bsr.w	get_faces
		bsr.w	counting_sort
		bsr.w	scaryenv_draw

		rts


scaryenv_new_angs:
		fmove.l	t,fp0
		fmul.s	#0.001,fp0
		fmove.s	fp0,any_env

		fmove.s	#0,fp0
		;fmove.l	t,fp0
		;fmul.s	#0.0001,fp0
		fmove.s	fp0,anz_env
		fmove.s	fp0,anx_env

		fmove.l	scaryenv_xpos,fp0
		fmul.s	#0.09,fp0
		;fmove.s	#-160,fp0
		fmove.s	fp0,xpos_env
		fmove.s	#90,fp0
		fmove.s	fp0,ypos_env
		;fmove.s	#7,fp0	;10
		fmove.l	scaryenv_size,fp0
		fmul.s	#0.01,fp0
		fmove.s	fp0,zpos_env

		rts

scaryenv_timer:
		addq.l	#4,t

		cmp.l	#2000,scaryenv_xpos
		ble.s	.add
		add.l	#1,scaryenv_size
		bra.s	.noadd
.add:		addq.l	#1,scaryenv_xpos
.noadd:

		rts

scaryenv_draw:
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
		lea.l	scaryq_chunky,a1
		bsr.w	gizpoly	
		dbra	d7,.faclop

		rts




		section	data

scaryenv_size:	dc.l	700
scaryenv_xpos:	dc.l	-1000
;scaryenv_scene:	include	'scaryq\spid02.r3d'
scaryenv_scene:	include	'scaryq\brain.r3d'


		section	text

