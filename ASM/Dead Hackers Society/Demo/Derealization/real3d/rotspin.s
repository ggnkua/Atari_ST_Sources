
	section	text

spin_scene:
	bsr	fix_rotmtx
	
	move.l	coords,a0
	lea	rotobj,a1
	bsr	.rotate

	move.l	norms,a0
	lea	rotobj+3*4,a1
	bsr	.rotate
	rts

.rotate:
	move.w	NUMVERTS,d7	;  for(i=0;i<ant;i++){
	subq.w	#1,d7
.rl:
	lea.l	xx_env,a2
	move.l	(a0)+,d0	;    xt=coords[a+0];
	move.l	(a0)+,d1	;    yt=coords[a+1];
	move.l	(a0)+,d2	;    zt=coords[a+2];
	fmove.s	d0,fp0		;    xa=xx*xt+xy*yt+xz*zt;
	fmove.s	d1,fp1
	fmove.s	d2,fp2
	fmul.s	(a2)+,fp0	
	fmul.s	(a2)+,fp1
	fmul.s	(a2)+,fp2
	fadd	fp1,fp0
	fadd	fp2,fp0
	fmove.s	fp0,(a1)+
	fmove.s	d1,fp1
	fmove.s	d0,fp0		;    ya=yx*xt+yy*yt+yz*zt;
	fmove.s	d2,fp2
	fmul.s	(a2)+,fp0
	fmul.s	(a2)+,fp1
	fmul.s	(a2)+,fp2
	fadd	fp1,fp0
	fadd	fp2,fp0
	fmove.s	fp0,(a1)+
	fmove.s	d1,fp1
	fmove.s	d0,fp0		;    za=zx*xt+zy*yt+zz*zt;
	fmove.s	d2,fp2
	fmul.s	(a2)+,fp0
	fmul.s	(a2)+,fp1
	fmul.s	(a2)+,fp2
	fadd	fp1,fp0
	fadd	fp2,fp0
	fmove.s	fp0,(a1)+
	add.l	#VERTSIZE-12,a1
	dbra	d7,.rl
	rts

project_coords_env:
	lea	rotobj,a0
	fmove.s	xpos_env,fp5
	fmove.s	ypos_env,fp6
	fmove.s	zpos_env,fp7
	move.w	NUMVERTS,d7
	subq.w	#1,d7
.projc:
	fmove.s	0(a0),fp0	;x
	fmove.s	4(a0),fp1	;y
	fmove.s	8(a0),fp2	;z

;	fadd	fp5,fp0
;	fadd	fp6,fp1
;	fadd	fp7,fp2

	fneg	fp2
	fadd	fp7,fp2		;z+d
	fmove.s	#300,fp3	;zoom
	fdiv	fp2,fp3
	fmul	fp3,fp0
	fmul	fp3,fp1

	ftst	fp2		;is z behind z=0???
	fbge	.noneg
	fneg	fp0		;z clip ok
	fneg	fp1
.noneg:

;	fadd.s	#144,fp0
;	fadd.s	#100,fp1

	fadd	fp5,fp0		;xpos
	fadd	fp6,fp1		;ypos

	fmove.s	fp0,0(a0)
	fmove.s	fp1,4(a0)
	fmove.s	fp2,8(a0)

	add.l	#VERTSIZE,a0
	dbra	d7,.projc
	rts

fix_rotmtx:

	lea.l	anx_env,a2
	fsincos.s	(a2)+,fp5:fp2	;  s3=sin(anx); c3=cos(anx);
	fsincos.s	(a2)+,fp4:fp1	;  s2=sin(any); c2=cos(any);	
	fsincos.s	(a2)+,fp3:fp0	;  s1=sin(anz); c1=cos(anz);

	fmove	fp4,fp7		;  xx=c2*c1;
	fmul	fp3,fp7
	fmove.s	fp7,(a2)+

	fmove	fp4,fp7		;  xy=c2*s1;
	fmul	fp0,fp7
	fmove.s	fp7,(a2)+

	fmove.s	fp1,(a2)+	;  xz=s2;

	fmove	fp5,fp7		;  yx=c3*s1+s3*s2*c1;
	fmul	fp0,fp7
	fmove	fp2,fp6
	fmul	fp1,fp6
	fmul	fp3,fp6
	fadd	fp6,fp7
	fmove.s	fp7,(a2)+

	fmove	fp2,fp7		;  yy=-c3*c1+s3*s2*s1;
	fmul	fp1,fp7
	fmul	fp0,fp7
	fmove	fp5,fp6
	fmul	fp3,fp6
	fsub	fp6,fp7
	fmove.s	fp7,(a2)+
	
	fmove	fp2,fp7		;  yz=-s3*c2;
	fmul	fp4,fp7
	fneg	fp7
	fmove.s	fp7,(a2)+

	fmove	fp2,fp7		;  zx=s3*s1-c3*s2*c1;
	fmul	fp0,fp7
	fmove	fp5,fp6
	fmul	fp1,fp6
	fmul	fp3,fp6
	fsub	fp6,fp7
	fmove.s	fp7,(a2)+

	fmove	fp2,fp7		;  zy=-s3*c1-c3*s2*s1;
	fneg	fp7
	fmul	fp3,fp7
	fmove	fp5,fp6
	fmul	fp1,fp6
	fmul	fp0,fp6
	fsub	fp6,fp7
	fmove.s	fp7,(a2)+
	
	fmove	fp5,fp7		;  zz=c3*c2;
	fmul	fp4,fp7
	fmove.s	fp7,(a2)+
	rts

;--- Data ------------------------------------------------------------------

	section	data

xpos_env:	dc.s	160
ypos_env:	dc.s	100
zpos_env:	dc.s	20	

	section	bss

anx_env:	ds.l	1
any_env:	ds.l	1
anz_env:	ds.l	1
;OBS!!! inget mellen anz och xx
xx_env:	ds.l	1	;  float s1,s2,s3,c1,c2,c3,xx,xy,xz,yx,yy,yz,zx,zy,zz;
	ds.l	1
	ds.l	1
	ds.l	1
	ds.l	1
	ds.l	1
	ds.l	1
	ds.l	1
	ds.l	1
