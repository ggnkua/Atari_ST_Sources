
; 3D engine
;
;
;
;	opt	x-,p=68030/68882

;XSCR	=	320
;YSCR	=	180
	
	include	'real3d\macros.s'
	include 'real3d\sort.s'
	include 'real3d\rotate.s'
	include	'real3d\rotspin.s'
	include 'real3d\clp_tex.s'
	include	'real3d\ply_tex.s'
	;include	'real3d\ply_gou1.s'
	;include	'real3d\ply_flat.s'
	include	'real3d\spline.s'

	section	text

;--------------------------------------------------------------------
; Initialize the scene structure 
; in: ptr to scene struct in a0
init_scene:
	move.w	(a0),d0
	sub.w	#2,d0
	move.w	d0,NUMCAM
	move.w	2(a0),d0
	move.w	d0,NUMVERTS
	move.w	4(a0),d0
	move.w	d0,TNUMVERTS
	move.w	6(a0),d0
	move.w	d0,NUMFACES
	move.l	8(a0),d0	;fov
	move.l	12(a0),d0
	move.l	d0,camera
	move.l	16(a0),d0
	move.l	d0,coords
	move.l	20(a0),d0
	move.l	d0,faces
	move.l	24(a0),d0
	move.l	d0,tcoords
	move.l	28(a0),d0
	move.l	d0,palettes
	move.l	32(a0),d0
	move.l	d0,textures
	rts

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Texmapper routines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scale_tcoords:
	move.l	tcoords,a0
	move.w	TNUMVERTS,d7
	tst.w	d7
	beq.s	.notexcoords
	subq.w	#1,d7
.lp:
	fmove.s	(a0),fp0	;v
	fmove.s	4(a0),fp1	;v
	fsub.s	#0.5,fp0
	fsub.s	#0.5,fp1
	fmul.s	#253,fp0	;texture size
	fmul.s	#253,fp1	;texture size
	fmul.s	#65536,fp0	;precalc u fixed point
	fmul.s	#65536,fp1	;precalc v fixed point
;	fmul.s	#2,fp0		;wrap
;	fmul.s	#2,fp1
	fmove.s	fp1,(a0)+
	fmove.s	fp0,(a0)+
	dbra	d7,.lp
.notexcoords:
	rts

invert_face_order:
	move.l	faces,a0
	move.w	NUMFACES,d7
	subq.w	#1,d7
.fl:
	move.w	0(a0),d0
	move.w	2(a0),d1
	move.w	4(a0),d2
	move.w	d2,0(a0)
	move.w	d1,2(a0)
	move.w	d0,4(a0)

	lea	3*2(a0),a1
	move.w	0(a1),d0
;	move.w	1(a1),d1
	move.w	6(a1),d2
	move.w	d2,0(a1)
;	move.w	d1,1(a1)
	move.w	d0,6(a1)

;	move.w	#0,6(a0)	
;	move.w	#0,8(a0)
	add.l	#FACE_SIZE,a0	;next polygon struct
	dbra	d7,.fl
	rts

;
; in: scale factor in fp0
;
scale_scene:
	fmove.s	fp0,sfact
	move.l	camera,a0
	move.w	NUMCAM,d7
	subq.l	#1,d7
.scam:
	rept	3
	fmove.s	(a0),fp0
	fmul.s	sfact,fp0
	fmove.s	fp0,(a0)+
	endr
	add.l	#5*4,a0		;skip rx ry rz rw time
	dbra	d7,.scam

	move.l	coords,a0
	move.w	NUMVERTS,d7
	mulu	#3,d7
	subq.l	#1,d7
.scrd:
	fmove.s	(a0),fp0
	fmul.s	sfact,fp0
	fmove.s	fp0,(a0)+
	dbra	d7,.scrd
	rts
	
sfact:	dc.s	1.0

perm_axis:
	move.l	coords,a0
	move.w	NUMVERTS,d7
	subq.w	#1,d7
.pc:
	fmove.s	0(a0),fp0
	fmove.s	4(a0),fp1
	fmove.s	8(a0),fp2

	fmove.s	#1.10,fp3
	fmul	fp3,fp0
	fmul	fp3,fp1
	fmul	fp3,fp2

	fmove.s	fp1,0(a0)
;	fadd.s	#22,fp2
	fmove.s	fp2,4(a0)
	fneg	fp0
	fmove.s	fp0,8(a0)
	add.l	#3*4,a0
	dbra	d7,.pc
	rts

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Envmapper routines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wavefront_obj_fix:		;fix non 0-indexing in wavefront .obj files
	move.l	faces,a0
	move.w	NUMFACES,d7
	subq.w	#1,d7
.ff:
	move.w	0(a0),d0
	move.w	2(a0),d1
	move.w	4(a0),d2
	move.w	d2,0(a0)
	move.w	d1,2(a0)
	move.w	d0,4(a0)

	rept	3
	sub.w	#1,(a0)+
	endr
	add.l	#FACE_SIZE-3*2,a0
	dbra	d7,.ff
	rts

calc_normals_env:

	lea	norm_calc,a0
	move.l	norms,a1
	move.w	NUMVERTS,d7
	subq.w	#1,d7
.cv:
	clr.l	(a0)+
	rept	3
	clr.l	(a1)+
	endr
	dbra	d7,.cv

	move.l	faces,a6
	move.w	NUMFACES,d7
	subq.w	#1,d7
.an:
	move.w	(a6)+,d0	;f1
	move.w	(a6)+,d1	;f2
	move.w	(a6)+,d2	;f3

	add.l	#FACE_SIZE-3*2,a6

	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5

	mulu	#3*4,d0
	mulu	#3*4,d1
	mulu	#3*4,d2

	move.l	coords,a1
	lea	(a1,d2.l),a3
	lea	(a1,d1.l),a2
	lea	(a1,d0.l),a1

	fmove.s	VX(a3),fp0
	fmove.s	VY(a3),fp1
	fmove.s	VZ(a3),fp2
	fsub.s	VX(a1),fp0
	fsub.s	VY(a1),fp1
	fsub.s	VZ(a1),fp2

	fmove.s	VX(a2),fp3
	fmove.s	VY(a2),fp4
	fmove.s	VZ(a2),fp5
	fsub.s	VX(a1),fp3
	fsub.s	VY(a1),fp4
	fsub.s	VZ(a1),fp5

	lea	v3_1,a0
	lea	v3_2,a1
	fmove.s	fp0,(a0)+
	fmove.s	fp1,(a0)+
	fmove.s	fp2,(a0)+
	fmove.s	fp3,(a1)+
	fmove.s	fp4,(a1)+
	fmove.s	fp5,(a1)+

	lea	v3_1,a0
	lea	v3_2,a1
	lea	v3_3,a2
	bsr	v3_cross	;calc cross product

	lea	v3_3,a0
	bsr	v3_norm

	move.l	norms,a3
	lea	v3_3,a0
	fmove.s	(a0)+,fp0	;x
	fmove.s	(a0)+,fp1	;y
	fmove.s	(a0)+,fp2	;z

	fmove.s	VX(a3,d0.l),fp3
	fmove.s	VY(a3,d0.l),fp4
	fmove.s	VZ(a3,d0.l),fp5
	fadd	fp0,fp3
	fadd	fp1,fp4
	fadd	fp2,fp5
	fmove.s	fp3,VX(a3,d0.l)
	fmove.s	fp4,VY(a3,d0.l)
	fmove.s	fp5,VZ(a3,d0.l)

	fmove.s	VX(a3,d1.l),fp3
	fmove.s	VY(a3,d1.l),fp4
	fmove.s	VZ(a3,d1.l),fp5
	fadd	fp0,fp3
	fadd	fp1,fp4
	fadd	fp2,fp5
	fmove.s	fp3,VX(a3,d1.l)
	fmove.s	fp4,VY(a3,d1.l)
	fmove.s	fp5,VZ(a3,d1.l)

	fmove.s	VX(a3,d2.l),fp3
	fmove.s	VY(a3,d2.l),fp4
	fmove.s	VZ(a3,d2.l),fp5
	fadd	fp0,fp3
	fadd	fp1,fp4
	fadd	fp2,fp5
	fmove.s	fp3,VX(a3,d2.l)
	fmove.s	fp4,VY(a3,d2.l)
	fmove.s	fp5,VZ(a3,d2.l)

	lea	norm_calc,a4
	addq.l	#1,(a4,d3.w*4)
	addq.l	#1,(a4,d4.w*4)
	addq.l	#1,(a4,d5.w*4)

	dbra	d7,.an

	move.l	norms,a0
	move.l	coords,a2
	lea	norm_calc,a1
	move.w	NUMVERTS,d7
	subq.w	#1,d7
.dn:
	fmove.l	(a1)+,fp0
;	clr.l	(a1)+

	fmove.s	VX(a0),fp1
	fmove.s	VY(a0),fp2
	fmove.s	VZ(a0),fp3

	fdiv.s	#128,fp0
	fdiv.s	#65536,fp0
	fdiv	fp0,fp1
	fdiv	fp0,fp2
	fdiv	fp0,fp3

	fmove.s	fp1,VX(a0)
	fmove.s	fp2,VY(a0)
	fmove.s	fp3,VZ(a0)

	add.l	#3*4,a0
	dbra	d7,.dn

	rts

v3_1:	dc.l	0,0,0
v3_2:	dc.l	0,0,0
v3_3:	dc.l	0,0,0

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Math routines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

; x1 y1 z1
; x2 y2 z2
; e1 e2 e3
; z = x1*y2 - x2*y1
; y = z1*x2 - z2*x1
; x = y1*z2 - y2*z1

v3_cross:
	fmove.s	VX(a0),fp0
	fmove.s	VY(a0),fp1
	fmove.s	VZ(a0),fp2

	fmove	fp0,fp3
	fmove	fp1,fp4
	fmove	fp2,fp5

	fmul.s	VY(a1),fp0
	fmul.s	VX(a1),fp2
	fmul.s	VZ(a1),fp1
		
	fmul.s	VX(a1),fp4
	fmul.s	VZ(a1),fp3
	fmul.s	VY(a1),fp5

	fsub	fp4,fp0		;z
	fsub	fp3,fp2		;y
	fsub	fp5,fp1		;x

	fmove.s	fp1,VX(a2)
	fmove.s	fp2,VY(a2)
	fmove.s	fp0,VZ(a2)

	rts

v3_norm:
	fmove.s	VX(a0),fp0
	fmove.s	VY(a0),fp1
	fmove.s	VZ(a0),fp2

	fmove	fp0,fp3
	fmove	fp1,fp4
	fmove	fp2,fp5

	fmul	fp0,fp0
	fmul	fp1,fp1
	fmul	fp2,fp2
	fadd	fp2,fp0
	fadd	fp1,fp0
	fsqrt	fp0,fp0

	fdiv	fp0,fp3
	fdiv	fp0,fp4
	fdiv	fp0,fp5

	fmove.s	fp3,VX(a0)
	fmove.s	fp4,VY(a0)
	fmove.s	fp5,VZ(a0)

	rts

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Timer routines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

real3d_timer:
	addq.l	#8,t
	rts

real3d_vbl:
	rts

real3d_clear_t:
	clr.l	t
	rts

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Util routines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

real3d_chunkyclear_320x200:
	lea.l	chunky+XSCR*YSCR,a6
	movem.l	.zero,d0-a5	;56
	move.w	#285-1,.count	;56*4*285 = 63840 (missing 160bytes)
.loop:
	rept	4
	movem.l	d0-a5,-(a6)
	endr
	subq.w	#1,.count
	bpl.w	.loop

	movem.l	d0-a5,-(a6)	;56	remaining 160bytes
	movem.l	d0-a5,-(a6)	;112
	movem.l	d0-a3,-(a6)	;160
	rts

.zero:	dcb.l	16,$0
.count:	dc.w	0

real3d_chunkyclear_320x180:
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

.zero:	dcb.l	16,$0
.count:	dc.w	0


set_palette:
    	lea.l	$ffff9800.w,a0
	move.l	palettes,a1
;	add.l	#256*3,a1
	move.w	#256-1,d7
.black:
	clr.l	d0
	move.b	2(a1),d0
	rol.l	#8,d0
	move.b	1(a1),d0
	swap	d0
	move.b	0(a1),d0
	move.l	d0,(a0)+
	addq.l	#3,a1
	dbra	d7,.black
	rts


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Debug routines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

view_dots:
	lea	chunky,a0
	lea	rotobj,a1
	move.w	NUMVERTS,d7
	subq.w	#1,d7
.dl:
   	fmove.s	(a1)+,fp0	;x
  	fmove.s	(a1)+,fp1	;y
    	fmove.s	(a1)+,fp2	;z

	fmove.s	#1,fp3
	fmul	fp3,fp0
	fmul	fp3,fp1
	fmul	fp3,fp2

;	fsub.s	#60,fp0
;	fsub.s	#50,fp1

;	bra	.noclip

	ftst	fp2		;zclip
	fble	.nodraw

	fcmp.s	#0,fp0
	fble	.nodraw
	fcmp.s	#287,fp0
	fbge	.nodraw
	fcmp.s	#0,fp1
	fble	.nodraw
	fcmp.s	#159,fp1
	fbge	.nodraw

.noclip:

	fmove.l	fp0,d0
	fmove.l	fp1,d1	

	add.l	#20,d0
	add.l	#XSCR*20,d1

	mulu	#288,d1
	add.l	d1,d0
	and.l	#$7fff,d0
	move.b	#-1,(a0,d0.l)
.nodraw:
	add.l		#VERTSIZE-3*4,a1
	dbra		d7,.dl
	rts

view_tex:
	move.l	textures,a0
	move.l	(a0),a0
	lea	chunky,a1
	move.l	#160,d6
.y:
	move.l	#256-1,d7
.x:
	move.b	(a0)+,(a1)+
	dbra	d7,.x
	add.l	#XSCR-256,a1
	dbra	d6,.y
	rts

		
;--- Data ----------------------------------------------------------
;object structure
;----------------
;
;only 3 sided polygons
;
;coords:	x,y,z	;as 4 byte single floats
;
;faces:		f1,f2,f3,t1,t2,t3,texture,type
;
;		f1     : 16bit word, ptr to coord values
;		t1     : 16bit word, ptr to texcoord values
;		texture: 16bit index to 256x256 8bit texture 
;			 or 8bit color in flatshade and gourade mode
;		type   : 16bit word
;
;type:

POLY_NONE	= 0	;draw no poly
POLY_TEX	= 1	;affine texturemapped polygon
POLY_ENV	= 2	;env polygon
;POLY_FLAT_A	= 3	;flat polygon in alpha layer
;POLY_GOURADE	= 4	;gourade shaded polygon
;POLY_GOURADE_A	= 5	;gourade shaded polygon in alpha layer
;POLY_LINE	= 6	;draw polygon as outline
;POLY_LINE_AA	= 7	;draw polygon as antialias line in alpha layer
;POLY_TEX_FLAT	= 8	;affine and flatshaded polygon
;POLY_TEX_G	= 9	;gourade shaded texturemapped polygon
;POLY_TEX_P	=10	;perspective correct texturemapped polygon
;POLY_FLARE	=11	;draw a flare in every corner of polygon
;POLY_FLARE_A	=12	;draw a flare in every corner of polygon in alpha

FACE_SIZE	=	(3*2+3*2+2+2)	;size of one face struct in bytes
VERTSIZE	=	4*8		;size of one vertex in bytes

VX		=	0
VY		=	4
VZ		=	8
VU		=	12
VV		=	16

	section	data

NUMCAM:		dc.w	0
NUMVERTS:	dc.w	0
TNUMVERTS:	dc.w	0
NUMFACES:	dc.w	0
camera:		dc.l	0
coords:		dc.l	0
;norms:		dc.l	0
faces:		dc.l	0
norms:				;same as tcoords!
tcoords:	dc.l	0
palettes:	dc.l	0
textures:	dc.l	0

	section	bss

t:		ds.l	1
polygon:	ds.b	VERTSIZE*16		;max 16 verts
rotobj:		ds.l	VERTSIZE*10000
ncoordrot:	ds.l	VERTSIZE*10000
facelst:	ds.l	10000 		;NUMFACES
facelst_sorted:	ds.l	10000 		;NUMFACES
chunky:		ds.b	320*240		;XSCR*YSCR
;alpha:		ds.w	XSCR*YSCR

fpolygon1:	ds.b	VERTSIZE*16	;max 16 vertex
fpolygon2:	ds.b	VERTSIZE*16
;BPLSIZE:	ds.l	1

norm_calc:	ds.l	4*10000		;4bytes per vertex needed

		section	text

