
	section	text

rotstart:

ROTONLY:	dc.w	1
	    
; in: ptr to 3x3 matrix in a0
;
transpose:
	  move.l	3*4(a0),d0
	  move.l	1*4(a0),3*4(a0)
	  move.l	d0,1*4(a0)

	  move.l	6*4(a0),d0
	  move.l	2*4(a0),6*4(a0)
	  move.l	d0,2*4(a0)

	  move.l	7*4(a0),d0
	  move.l	5*4(a0),7*4(a0)
	  move.l	d0,5*4(a0)
	  rts

negate_x:
	 fmove.s	0*3*4(a0),fp0
	 fneg		fp0
	 fmove.s	fp0,(a0)

	 fmove.s	1*3*4(a0),fp0
	 fneg		fp0
	 fmove.s	fp0,1*3*4(a0)

	 fmove.s	2*3*4(a0),fp0
	 fneg		fp0
	 fmove.s	fp0,2*3*4(a0)
	 rts
negate_z:
	 fmove.s	0*3*4+2*4(a0),fp0
	 fneg		fp0
	 fmove.s	fp0,2*4(a0)

	 fmove.s	1*3*4+2*4(a0),fp0
	 fneg		fp0
	 fmove.s	fp0,1*3*4+2*4(a0)

	 fmove.s	2*3*4+2*4(a0),fp0
	 fneg		fp0
	 fmove.s	fp0,2*3*4+2*4(a0)
	 rts

;in:  rot_camera in a1
rotate_scene:
	lea	xpos,a0
;	move.l	rot_camera,a1

	fmove.l	t,fp5
	fmul.s	#0.001,fp5
	fsincos	fp5,fp6:fp7
	
	fmove.s	(a1)+,fp0	;xpos
	fmove.s	(a1)+,fp1	;ypos
	fmove.s	(a1)+,fp2	;zpos

;	fmove.s	#250,fp1	;hardcoded z/y
;	fmove.s	#500,fp2

	fmove	fp0,fp3
	fmove	fp2,fp4
	fmul	fp7,fp3		;x*sin
	fmul	fp6,fp4		;z*cos
	fmul	fp6,fp0		;x*cos
	fmul	fp7,fp2		;z*sin
	fadd	fp4,fp3
	fsub	fp2,fp0

	fmove.s	fp0,xpos
	fmove.s	fp1,ypos
	fmove.s	fp3,zpos

	fmove.s	(a1)+,fp0	;rotx
	fmove.s	(a1)+,fp1	;roty
	fmove.s	(a1)+,fp2	;rotz
	fmove.s	(a1)+,fp3	;time

;	fmove.s	#0.99,fp1
;	fmove.s	#0.1,fp2
	fneg	fp5

	fmove.s	fp0,rotx
	fmove.s	fp1,roty
	fmove.s	fp2,rotz
	fmove.s	fp5,rotw

	bra	transform_scene
	rts
	
camerapos:	dc.s	0,0,0,0,0,1
;CPOS = 0
;keyt:  dc.s	0

play_camera:
        bsr	CalcSpline

transform_scene:
	lea	xx,a1
	bsr	mk_rotation_matrix

	move.l	coords,a0
	lea	rotobj,a1
	move.w	NUMVERTS,d7	;  for(i=0;i<ant;i++){
	subq.w	#1,d7
rot_loop:
	lea.l	xx,a2
	fmove.s	(a0)+,fp3	;    xt=coords[a+0];
	fmove.s	(a0)+,fp4	;    yt=coords[a+1];
	fmove.s	(a0)+,fp5	;    zt=coords[a+2];

;	tst.w	ROTONLY
;	bra.s	.nopos
	fsub.s	xpos,fp3
	fsub.s	ypos,fp4
	fsub.s	zpos,fp5
.nopos:

	fmove	fp3,fp0		;    xa=xx*xt+xy*yt+xz*zt;
	fmove	fp4,fp1
	fmove	fp5,fp2
	fmul.s	(a2)+,fp0
	fmul.s	(a2)+,fp1
	fmul.s	(a2)+,fp2
	fadd	fp1,fp0
	fadd	fp2,fp0
	fmove.s	fp0,(a1)+
	fmove	fp4,fp1
	fmove	fp3,fp0		;    ya=yx*xt+yy*yt+yz*zt;
	fmove	fp5,fp2
	fmul.s	(a2)+,fp0
	fmul.s	(a2)+,fp1
	fmul.s	(a2)+,fp2
	fadd	fp1,fp0
	fadd	fp2,fp0
	fmove.s	fp0,(a1)+
	fmove	fp4,fp1
	fmove	fp3,fp0		;    za=zx*xt+zy*yt+zz*zt;
	fmove	fp5,fp2
	fmul.s	(a2)+,fp0
	fmul.s	(a2)+,fp1
	fmul.s	(a2)+,fp2
	fadd	fp1,fp0
	fadd	fp2,fp0
	fmove.s	fp0,(a1)+
	add.l	#VERTSIZE-12,a1
	dbra	d7,rot_loop
	rts

project_coords:
	       ;fmove.s	camera_fov,fp7 
	       ;fdiv.s	#2,fp7	       	;does net work !?!
	       ;ftan.s	camera_fov,fp7
	       fmove.s	#0.7895,fp7
	       fmul.s	#2,fp7
	       fmul.s	#160,fp7
	       lea	rotobj,a0
	move.w	NUMVERTS,d7
	subq.w	#1,d7
.projc:
	fmove.s	0(a0),fp0	;x
	fmove.s	4(a0),fp1	;y
	fmove.s	8(a0),fp2	;z

;	tst.w	ROTONLY
	bra.s	.nopos
	fadd.s	xposa,fp0
	fadd.s	yposa,fp1
	fadd.s	zposa,fp2
.nopos:
	fneg	fp1
	fmove	fp7,fp3		;fov zoom
	fdiv	fp2,fp3
	fmul	fp3,fp0
	fmul	fp3,fp1

	ftst	fp2		;is z behind z=0???
	fbge	.noneg
	fneg	fp0		;z clip ok
	fneg	fp1
.noneg:
	fadd.s	#160.0,fp0
	fadd.s	#90.0,fp1

	fmove.s	fp0,0(a0)
	fmove.s	fp1,4(a0)
	fmove.s	fp2,8(a0)

	add.l	#VERTSIZE,a0
	dbra	d7,.projc
	rts


;   Rotate a point p by angle theta around an arbitrary axis r:
;      U = [ (t*x*x + c),    (t*x*y + s*z),  (t*x*z - s*y)]
;      V = [ (t*x*y - s*z),  (t*y*y + c),    (t*y*z + s*x)]
;      N = [-(t*x*z + s*y), -(t*y*z - s*x), -(t*z*z + c)  ]
;
; in:  a0 ptr to   dc.s rx,ry,rz,theta
;      a1 prt to   rotation matrix (3x3) to be created
mk_rotation_matrix:
		 fsin.s		rotw,fp0	;sin(theta)
		 fcos.s		rotw,fp1	;cos(theta)
		 fmove.s	#1.0,fp2
		 fsub		fp1,fp2		;1-cost

	       	 ; xx
		 fmove		fp2,fp3
		 fmul.s		rotx,fp3
		 fmul.s		rotx,fp3
		 fadd		fp1,fp3
		 fmove.s	fp3,(a1)+

		 ; xy
		 fmove		fp2,fp3
		 fmul.s		rotx,fp3
		 fmul.s		roty,fp3
		 fmove		fp0,fp4
		 fmul.s		rotz,fp4
		 fadd		fp4,fp3
		 fmove.s	fp3,(a1)+
		 
		 ; xz
		 fmove		fp2,fp3
		 fmul.s		rotx,fp3
		 fmul.s		rotz,fp3
		 fmove		fp0,fp4
		 fmul.s		roty,fp4
		 fsub		fp4,fp3
		 fmove.s	fp3,(a1)+
		 
		 ; yx
		 fmove		fp2,fp3
		 fmul.s		rotx,fp3
		 fmul.s		roty,fp3
		 fmove		fp0,fp4
		 fmul.s		rotz,fp4
		 fsub		fp4,fp3
		 fmove.s	fp3,(a1)+
		 
		 ; yy
		 fmove		fp2,fp3
		 fmul.s		roty,fp3
		 fmul.s		roty,fp3
		 fadd		fp1,fp3
		 fmove.s	fp3,(a1)+
		 
		 ; yz
		 fmove		fp2,fp3
		 fmul.s		roty,fp3
		 fmul.s		rotz,fp3
		 fmove		fp0,fp4
		 fmul.s		rotx,fp4
		 fadd		fp4,fp3
		 fmove.s	fp3,(a1)+
		 
		 ; zx
		 fmove		fp2,fp3
		 fmul.s		rotx,fp3
		 fmul.s		rotz,fp3
		 fmove		fp0,fp4
		 fmul.s		roty,fp4
		 fadd		fp4,fp3
		 fneg		fp3
		 fmove.s	fp3,(a1)+
		 
		 ; zy
		 fmove		fp2,fp3
		 fmul.s		roty,fp3
		 fmul.s		rotz,fp3
		 fmove		fp0,fp4
		 fmul.s		rotx,fp4
		 fsub		fp4,fp3
		 fneg		fp3
		 fmove.s	fp3,(a1)+
		 
		 ; zz
		 fmove		fp2,fp3
		 fmul.s		rotz,fp3
		 fmul.s		rotz,fp3
		 fadd		fp1,fp3
		 fneg		fp3
		 fmove.s	fp3,(a1)+
		 
		 rts

rotend:

xposa:	dc.s	0
yposa:	dc.s	15
zposa:	dc.s	20

xpos:	dc.s	0
ypos:	dc.s	0
zpos:	dc.s	0

rotx:   dc.s	   0	;rotation_vector
roty:	dc.s	   1
rotz:	dc.s	   0
rotw:	dc.s	   0

xx:	dc.l	0	;  float s1,s2,s3,c1,c2,c3,xx,xy,xz,yx,yy,yz,zx,zy,zz;
xy:	dc.l	0
xz:	dc.l	0
yx:	dc.l	0
yy:	dc.l	0
yz:	dc.l	0
zx:	dc.l	0
zy:	dc.l	0
zz:	dc.l	0
