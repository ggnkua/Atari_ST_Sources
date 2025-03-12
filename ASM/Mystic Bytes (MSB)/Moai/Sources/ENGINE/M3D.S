; m3d8 structure
; ===============
;
; dc.l 'M3D8'
; dc.w no_of_objects
; dc.w no_of_points
; dc.w no_of_faces
; dc.w FEDCBA9876543210
;      |          |||||
;      |          +++++-- number of materials (0-16)
;      +----------------- 0: planar mapping
;                         1: spherical mapping
;
; if flat or gouraud shaded:
; 	for each material:
;		dc.b r,g,b
;
; for each object:
; 	dc.w vertices_per_mesh,faces_per_mesh
; 	dc.w cx,cy,cz
;
; for each object:
;	for each point:
;		dc.w x,y,z
;
; for each object:
;	for each point:
;		dc.w nx,ny,nz
;
; if spherical mapping:
;	for each object:
;		for each point:
;			dc.b u,v
;
; for each object:
;	for each face:
;		dc.w vertices_per_face  1: sprite (point)
;                                       2: line
;                                       3-8: polygon with 3-8 vertices
;		dc.w ____BA9876_43210   (only 12 bits can be used)
;		         |||||| |||||
;		         |||||| |++++-- for sprite: number of sprite
;		         |||||| |       for line & polygon: number of envmap/texture/material
;		         |||||| |
;		         |||||| |
;		         |||||| |
;		         |||||| +------ 1: wrap texture               [polygon]
;		         |||||+-------- 1: wire frame                 [polygon] TODO?
;		         ||||+--------- 1: flat shaded                [polygon]
;		         |||+---------- 1: gouraud shaded             [line,polygon] TODO line
;		         ||+----------- 1: env mapped                 [polygon]
;		         |+------------ 1: texture mapped             [polygon]
;		         +------------- 1: use texture in DSP memory  [polygon]
;		for each vertex:
;			dc.w point_number
;			if planar mapping && texture mapped:
;				dc.b u, v


M3D_SCENES	EQU	5

FLG_WRAPTEX	EQU	4					; 1: wrap texture
FLG_WIREFRAME	EQU	6					; 1: draw polygon as wireframe
FLG_FLAT	EQU	7					; 1: polygon is flat shaded
FLG_GOURAUD	EQU	8					; 1: polygon/line is Gouraud-shaded
FLG_ENVMAP	EQU	9					; 1: polygonis env mapped
FLG_TEXMAP	EQU	10					; 1: polygon is texture mapped
FLG_DSPTEX	EQU	11					; 1: texture lies in DSP memory

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

m3d_init_scenes:
		lea	m3d_scenes,a0
		lea	m3d_palettes,a2
		moveq	#M3D_SCENES-1,d7
		
.loop:		movea.l	(a0)+,a1
		cmpi.l	#'M3D8',(a1)+
		beq.b	.ok
		move.l	#bad_m3d_text,error_adr
		bra.w	exit

.ok:		move.w	(a1)+,scene_objects
		move.w	(a1)+,scene_points
		move.w	(a1)+,scene_faces
		move.w	(a1)+,scene_materials

		move.l	a0,-(sp)
		move.w	d7,-(sp)

		movea.l	(a2)+,a0			; a0: dst pal (hc) // a1: src pal (tc)
		clr.l	d7
		move.w	scene_materials,d7
		andi.w	#$7fff,d7			; clear bit #15
		beq.b	.no_materials
		
		bsr.w	convert_tcpal
		
.no_materials:	move.w	(sp)+,d7
		movea.l	(sp)+,a0

		dbra	d7,.loop
		rts

; set current scene
; be sure you call it before m3d send!
; input: d0.w: number of m3d scene

m3d_set_scene:	movea.l	(m3d_scenes.l,pc,d0.w*4),a0
		lea	obj_centers,a1
		
		addq.l	#4,a0				; skip header
		move.w	(a0)+,scene_objects
		move.w	(a0)+,scene_points
		move.w	(a0)+,scene_faces
		move.w	(a0)+,scene_materials
		
		move.w	scene_materials,d7
		andi.w	#$7fff,d7
		mulu.w	#3,d7
		adda.l	d7,a0				; skip materials
		
		move.w	scene_objects,d7		; copy objects' centers
		subq.w	#1,d7

.loop:		addq.l	#4,a0				; skip points,faces
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		dbra	d7,.loop
		rts

; ------------------------------------------------------
		SECTION	DATA
; ------------------------------------------------------

m3d_scenes:	dc.l	m3d_obj_0
		dc.l	m3d_obj_1
		dc.l	m3d_obj_2
		dc.l	m3d_obj_3
		dc.l	m3d_obj_4
		
m3d_palettes:	dc.l	m3d_pal_0
		dc.l	m3d_pal_1
		dc.l	m3d_pal_2
		dc.l	m3d_pal_3
		dc.l	m3d_pal_4
		
m3d_colortabs:	dc.l	m3d_coltab_0
		dc.l	m3d_coltab_1
		dc.l	m3d_coltab_2
		dc.l	m3d_coltab_3
		dc.l	m3d_coltab_4
		
m3d_obj_0:	incbin	"m3d\hlava.m3d"			; scn1
m3d_obj_1:	incbin	"m3d\kanon.m3d"			; scn3
m3d_obj_2:	incbin	"m3d\stlpy.m3d"			; scn4
m3d_obj_3:	incbin	"m3d\kostol.m3d"		; scn2
m3d_obj_4:	incbin	"m3d\end.m3d"			; scn5

; ------------------------------------------------------
		SECTION	BSS
; ------------------------------------------------------

scene_pal:	ds.l	1				; current hicolor palette
scene_colortab:	ds.l	1				; current colortab

scene_objects:	ds.w	1
scene_points:	ds.w	1
scene_faces:	ds.w	1
scene_materials:
		ds.w	1
		
cam_angle_add:	ds.w	3				; da, db, dc
obj_angle_add:	
		REPT	64
		ds.w	3				; da, db, dc
		ENDR
		
obj_angles:	ds.w	64*3				; 64 objects * [a b c]
obj_centers:	ds.w	64*3				; 64 objects * [x y z]
		
m3d_pal_0:	ds.w	256				; hicolor palette
m3d_pal_1:	ds.w	256
m3d_pal_2:	ds.w	256
m3d_pal_3:	ds.w	256
m3d_pal_4:	ds.w	256

m3d_coltab_0:	ds.w	256*64				; 256 colours x 64 shades
m3d_coltab_1:	ds.w	256*64
m3d_coltab_2:	ds.w	256*64
m3d_coltab_3:	ds.w	256*64
m3d_coltab_4:	ds.w	256*64

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------
