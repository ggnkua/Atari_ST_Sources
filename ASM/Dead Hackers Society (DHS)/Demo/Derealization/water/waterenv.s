
		section	text

waterenv_runtime_init:
	
		bsr.w	init_texmap

		lea.l	waterenv_scene,a0
		bsr.w	init_scene
		bsr.w	wavefront_obj_fix
		bsr.w	calc_normals_env
	
		clr.l	t
		rts
	

waterenv_main:
		bsr.w	waterenv_new_angs
		bsr.w	spin_scene
		bsr.w	project_coords_env
		bsr.w	get_faces
		bsr.w	counting_sort
		bsr.w	waterenv_draw

		rts


waterenv_new_angs:

		
		fmove.s	#0,fp0
		fmove.s	fp0,anz_env

		fmove.l	t,fp0
		fmul.s	#0.0005,fp0
		;fmove.s	#3.1,fp0
		fmove.s	fp0,any_env

		fmove.s	#-0.5,fp0
		fmove.s	fp0,anx_env


		fmove.s	#100,fp0
		fmove.s	fp0,xpos_env
		fmove.s	#90,fp0
		fmove.s	fp0,ypos_env


		tst.l	timer_param
		beq.s	.fixed_size


		fmove.l	waterenv_size,fp0
		fmove.s	#0.0025,fp1
		fmul	fp1,fp0
		fmove.s	fp0,zpos_env
		
		bra.s	.rts		

.fixed_size:	fmove.s	#25,fp0	;5
		fmove.s	fp0,zpos_env

.rts:		rts

waterenv_timer:
		addq.l	#4,t

;		cmp.l	#1,timer_param
;		bne.s	.no1

;		cmp.l	#10000,waterenv_size
;		bge.s	.nomove
;		addq.l	#2,waterenv_size
;		bra.s	.nomove

;.no1:		cmp.l	#2,timer_param
;		bne.s	.no2
;		cmp.l	#500,waterenv_size
;		ble.s	.nomove
;		subq.l	#3,waterenv_size
;.no2:	
;.nomove:
		tst.l	timer_param
		beq.s	.nomove
		cmp.l	#500,waterenv_size
		ble.s	.nomove
		subq.l	#4,waterenv_size
.nomove:

		rts

waterenv_draw:
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
		lea.l	water_chunky,a1
		bsr.w	gizpoly	
		dbra	d7,.faclop

		rts




		section	data


waterenv_scene:	include	'water\feto4.r3d'

		section	data
		
waterenv_size:	dc.l	10000	;2000

		section	text

