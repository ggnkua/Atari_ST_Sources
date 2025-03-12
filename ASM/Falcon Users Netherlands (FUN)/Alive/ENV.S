;4orce env part
;
;gizmo / dhs
;
;no spread earx!

ScrWidth	=	144
ScrHeight	=	100
rots	=	7
maps	=	2^rots
ands	=	$ff80


;%%% Mainloop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Main:

		bsr.w	ClearScreen
env_1x:		move.l	#576*100+288,screen_centre	
		bsr.w	EnvTorus
		rts

env_2x:
		move.l	#288,tunnelmix_skip
		bsr.w	tunnelmix_trash
		move.l	#576*50+144,screen_centre
		bsr.s	EnvTorus
		rts




env_50hz:

		*bsr.w	tunnelmix_50hz

		fmovem.x	fp0-fp7,-(sp)			;
		lea.l	save_fpu,a0			;save fpu
		fsave	(a0)				;

		lea.l	anx,a2
		fmovem.x	(a2)+,fp0-fp2
		fadd.s	#0.0040,fp0
		fadd.s	#0.0073,fp1
		fadd.s	#0.0066,fp2
		fmovem.x	fp0-fp2,-(a2)


		lea.l	save_fpu,a0			;
		frestore	(a0)			;
		fmovem.x	(sp)+,fp0-fp7			;restore fpu


	        rts

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%
;%%%	Optimized rotate-matrix-multiplication with 68882 FPU
;%%%	508 bytes
;%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


EnvTorus:
RotateCoords:


	lea.l	anx,a2
	fsincos.x	(a2)+,fp2:fp5	;  s3=sin(anx); c3=cos(anx);
	fsincos.x	(a2)+,fp1:fp4	;  s2=sin(any); c2=cos(any);	
	fsincos.x	(a2)+,fp0:fp3	;  s1=sin(anz); c1=cos(anz);

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

	lea.l	Coords,a0
	lea.l	RotCoords,a1
	move.w	#NUMCOORD*2-1,d7	;  for(i=0;i<ant;i++){
rot_loop:
	lea.l	xx,a2
	move.w	(a0)+,d0	;    xt=coords[a+0];
	move.w	(a0)+,d1	;    yt=coords[a+1];
	move.w	(a0)+,d2	;    zt=coords[a+2];
	fmove.w	d0,fp0		;    xa=xx*xt+xy*yt+xz*zt;
	fmove.w	d1,fp1
	fmove.w	d2,fp2
	fmul.s	(a2)+,fp0	
	fmul.s	(a2)+,fp1
	fmul.s	(a2)+,fp2
	fadd	fp1,fp0
	fadd	fp2,fp0
	fmove.w	fp0,(a1)+
	fmove.w	d0,fp0		;    ya=yx*xt+yy*yt+yz*zt;
	fmove.w	d1,fp1
	fmove.w	d2,fp2
	fmul.s	(a2)+,fp0
	fmul.s	(a2)+,fp1
	fmul.s	(a2)+,fp2
	fadd	fp1,fp0
	fadd	fp2,fp0
	fmove.w	fp0,(a1)+
	fmove.w	d0,fp0		;    za=zx*xt+zy*yt+zz*zt;
	fmove.w	d1,fp1
	fmove.w	d2,fp2
	fmul.s	(a2)+,fp0
	fmul.s	(a2)+,fp1
	fmul.s	(a2)+,fp2
	fadd	fp1,fp0
	fadd	fp2,fp0
	fmove.w	fp0,(a1)+
	addq.l	#2,a1
	dbra	d7,rot_loop
;	rts

;%%% Project Coordinates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ProjectCoords:
	lea.l	RotCoords,a0
	move.l	a0,a1
	move.w	#NUMCOORD-1,d7
.loop:
	movem.w (a0)+,d0-d3	;x,y,z (eller z,y,x?)
	asr.w	#7,d2
	sub.w	#120,d2		;dist-z
	neg.w	d2
	divs.w	d2,d0
	divs.w	d2,d1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	addq.l	#2,a1
	dbra	d7,.loop
;	rts


;%%%%%% Backface Faces %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BackFaces:
	clr.w	ant_synl_faces
	lea.l	faces,a3
	lea.l	synl_faces,a5
	lea.l	zposition,a6
	lea.l	RotCoords,a0
	moveq.l	#NUMFACE-1,d7	;   For N=1 To 6*4 Step 4
.drawloop:
;	move.w	(a3)+,d0	;	F1=F(N)
;	move.w	(a3)+,d1	;	F2=F(N+1)
;	move.w	(a3)+,d2	;	F3=F(N+2) 
	movem.w	(a3)+,d0-d2
	move.w	0(a0,d1*2),d3	;	DX1=XP(F2)-XP(F1)
	sub.w	0(a0,d0*2),d3	;dx1
	move.w	2(a0,d1*2),d4	;	DY1=YP(F2)-YP(F1)
	sub.w	2(a0,d0*2),d4	;dy1
	move.w	0(a0,d2*2),d5	;	DX2=XP(F3)-XP(F1)
	sub.w	0(a0,d0*2),d5	;dx2
	move.w	2(a0,d2*2),d6	;	DY2=YP(F3)-YP(F1)
	sub.w	2(a0,d0*2),d6	;dy2
	muls	d3,d6		;	NV=DX1*DY2-DX2*DY1
	muls	d4,d5
	sub.l	d5,d6		;nv
	move.w	(a3)+,d3	;	F4=F(N+3)
	tst.w	d6		;	If NV>0
	bgt.b	.noPoly
	addq.w	#1,ant_synl_faces
	moveq.l	#NUMFACE-1,d6
	sub.w	d7,d6
	move.w	d6,(a5)+
	move.w	4(a0,d0.w*2),d4	;z1+z2+z3+z4
	add.w	4(a0,d1.w*2),d4
	add.w	4(a0,d2.w*2),d4
	add.w	4(a0,d3.w*2),d4	
	move.w	d4,(a6)+
.noPoly:				;	End If 
	dbra	d7,.drawloop	;	Next N
;	rts

;%%%%%%%% Sort Faces %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SortFaces:
	move.w	ant_synl_faces,d7
	subq	#2,d7
	blt.s	.no
.sort1:
	lea.l	zposition,a0
	lea.l	synl_faces,a1
	move.w	ant_synl_faces,d6
	subq	#2,d6
.sort2:
	move.w	(a0)+,d0
	move.w	(a0),d1
	cmp.w	d0,d1
	blt.b	.noswap
	move.w	d1,-2(a0)
	move.w	d0,(a0)
	move.w	(a1),d2
	move.w	2(a1),(a1)
	move.w	d2,2(a1)
.noswap:
	addq	#2,a1
	dbra	d6,.sort2
	dbra	d7,.sort1
.no:
;	rts


;%%%%%%%% Draw %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GetFaces:
	lea.l	synl_faces,a5
	moveq.l	#0,d7
	move.w	ant_synl_faces,d7
	subq	#1,d7
	blt.s	.no
.tstface:
	move.w	(a5)+,d0
	movem.l	d7/a5,-(a7)
	muls	#NUMSID*2,d0
	lea.l	faces,a3
	add.w	d0,a3
	movem.w	(a3)+,d0-d3

	lea.l	RotCoords,a0
	lea.l	EnvCoords,a3
	lea.l	sortcoords,a1
	move.l	(a0,d0.w*2),(a1)+	;xp(f1)
	move.l	(a0,d1.w*2),(a1)+	;xp(f2)
	move.l	(a0,d2.w*2),(a1)+	;xp(f3)
	move.l	(a0,d3.w*2),(a1)+	;xp(f4)
	lea.l	mapcoords,a4
	move.l	(a3,d0.w*2),(a4)+	;u1,v1
	move.l	(a3,d1.w*2),(a4)+	;u1,v1
	move.l	(a3,d2.w*2),(a4)+	;u1,v1
	move.l	(a3,d3.w*2),(a4)+	;u1,v1
	sub.w	#4*4,a4
	sub.w	#4*4,a1
	bsr.b	TraceMap
	bsr.w	Filler
	movem.l	(a7)+,d7/a5
	dbra	d7,.tstface
.no:	rts

TraceMap:	;***************************************** Trace Map ***

		lea.l	ymax,a0
		move.l	#$ff8000ff,(a0)
		move.l	(a1),2*2*4(a1)
		move.l	(a4),2*2*4(a4)
		moveq.l	#4-1,d7
draw:
		move.l	d7,-(a7)

		movem.w	(a1)+,d0-d3
		subq.l	#4,a1
		movem.w	(a4)+,d4-d7
		subq.l	#4,a4

		lea.l	trace_scr,a3
		lea.l	trace_map,a5
		cmp.w	(a0),d1
		blt.b	nomaxy
		move.w	d1,(a0)
nomaxy:
		cmp.w	2(a0),d1
		bgt.b	nominy
		move.w	d1,2(a0)
nominy:
		cmp.w	d1,d3
		bgt.b	ydirok
		exg.l	d0,d2
		exg.l	d1,d3		
		exg.l	d4,d6
		exg.l	d5,d7
		add.w	#256*2,a3
		add.w	#256*4,a5
ydirok:
		sub.w	d1,d3		;y2-y1
		ble.b	NoDraw
		sub.w	d0,d2		;x2-x1
		ext.l	d2
		lsl.l	#rots,d2
		divs	d3,d2		;dx
		lsl.w	#rots,d0
		sub.w	d4,d6		;x2_map-x1_map
		sub.w	d5,d7		;y2_map-y1_map
		ext.l	d6
		ext.l	d7
		divs.w	d3,d6		;dx_map
		divs.w	d3,d7		;dy_map
		subq.w	#1,d3
		blt.b	NoDraw
		lea.l	(a3,d1.w*2),a3
		lea.l	(a5,d1.w*4),a5
trace_y:
		add.w	d2,d0
		add.w	d6,d4
		add.w	d7,d5
		move.w	d0,d1
		asr.w	#rots,d1
		move.w	d1,(a3)+
		move.w	d4,(a5)+
		move.w	d5,(a5)+
		dbra	d3,trace_y
NoDraw:
		move.l	(a7)+,d7
		dbra	d7,draw				
		rts

;%%% 2 instr texmap %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Filler:
		lea.l	trace_scr,a1
		lea.l	trace_map,a2
		move.w	(a0)+,d7	;ymax
		move.w	(a0),d6		;ymin
		sub.w	d6,d7		;yfill counter
		move.w	d7,d1

		subq.w	#1,d7		;ylines-1
		blt.w	NoFill		;>0 ylines?

		asr.w	#1,d1		;ylines/2
		lea.l	(a1,d6.w*2),a1
		lea.l	(a2,d6.w*4),a2
		add.w	#256,d1
		move.w	(a1,d1.w*2),d0
		move.w	(a2,d1.w*4),d2
		move.w	2(a2,d1.w*4),d4
		sub.w	#256,d1
		sub.w	(a1,d1.w*2),d0		;x2_t-x_t
		ble.w	noFill
		sub.w	(a2,d1.w*4),d2
		sub.w	2(a2,d1.w*4),d4
		ext.l	d2
		ext.l	d4
		divs.w	d0,d2
		divs.w	d0,d4

		lea.l	trace_vector,a0
		sub.l	a6,a6		;x=0
		sub.l	a5,a5		;y=0
		move.w	#ands,d1
		add.l	d0,d0
make_tracevect:				;d6 d7
		add.w	d2,a6	;x	
		add.w	d4,a5	;y
		move.w	a6,d3
		asr.w	#rots,d3
		move.w	a5,d5
		and.w	d1,d5
		add.w	d3,d5
		move.w	d5,(a0)+
		dbra	d0,make_tracevect

		muls.w	#576,d6

		move.l	screen_adr,a5

		add.l	screen_centre,a5

		add.l	d6,a5
		lea.l	env_flare+64*128*2+64*2,a6
yfill:
		move.w	256*2(a1),d0
		move.w	(a1)+,d2	;x2_t-x_t
		move.w	(a2)+,d3
		move.w	(a2)+,d5
		lea.l	(a5,d2.w*2),a0	;start scr pos
		asr.w	#rots,d3
		and.w	d1,d5
		add.w	d3,d5
		lea.l	(a6,d5.w*2),a3	;start tex pos
		sub.w	d2,d0		;scanline width
		ble.b	noXfill
		lea.l	trace_vector,a4
xfill:
		move.w	(a4)+,d5
		move.w	(a3,d5.w*2),(a0)+
		dbra	d0,xfill
noXfill:
		add.l	#576,a5		;next line
		dbra	d7,yfill
noFill:
		rts


;%%% Clear Screen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ClearScreen:
	move.l	screen_adr,a0
	clr.l	d0
	move.w	#288*200/8-1,d7
.loop
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d7,.loop
	rts



		section	data

		even

		

*****************************  Fast Data  ********************************

NUMSID	=	4	;antal sidor i texturen
NUMCOORD=	16	;antal koordinater i objektet
NUMFACE	=	16	;antal faces hos objektet

X0	=	80	;objektets placering
Y0	=	64	; -""-
D	=	200

ant_synl_faces:	dc.w	0

	even


s	=	10*128
s1	=	-2*s
s2	=	-1*s
s3	=	1*s
s4	=	2*s
z1	=	-5*128
z2	=	5*128

coords:	
	dc.w	s1,s1,z1
	dc.w	s4,s1,z1
	dc.w	s4,s4,z1
	dc.w	s1,s4,z1
	dc.w	s2,s2,z1
	dc.w	s3,s2,z1
	dc.w	s3,s3,z1
	dc.w	s2,s3,z1
	dc.w	s1,s1,z2
	dc.w	s4,s1,z2
	dc.w	s4,s4,z2
	dc.w	s1,s4,z2
	dc.w	s2,s2,z2
	dc.w	s3,s2,z2
	dc.w	s3,s3,z2
	dc.w	s2,s3,z2

	even

p1	=	-20*128
p2	=	20*128

ecoords:
	dc.w	p1,p1,p1
	dc.w	p2,p1,p1
	dc.w	p2,p2,p1
	dc.w	p1,p2,p1
	dc.w	p2,p2,p1
	dc.w	p1,p2,p1
	dc.w	p1,p1,p1
	dc.w	p2,p1,p1
	dc.w	p1,p1,p2
	dc.w	p2,p1,p2
	dc.w	p2,p2,p2
	dc.w	p1,p2,p2
	dc.w	p2,p2,p2
	dc.w	p1,p2,p2
	dc.w	p1,p1,p2
	dc.w	p2,p1,p2

	even

faces:
	dc.w	0*4,4*4,5*4,1*4
	dc.w	1*4,5*4,6*4,2*4
	dc.w	2*4,6*4,7*4,3*4
	dc.w	3*4,7*4,4*4,0*4

	dc.w	8*4,9*4,13*4,12*4
	dc.w	9*4,10*4,14*4,13*4
	dc.w	10*4,11*4,15*4,14*4
	dc.w	11*4,8*4,12*4,15*4

	dc.w	0*4,1*4,9*4,8*4
	dc.w	1*4,2*4,10*4,9*4
	dc.w	2*4,3*4,11*4,10*4
	dc.w	3*4,0*4,8*4,11*4

	dc.w	5*4,4*4,12*4,13*4
	dc.w	6*4,5*4,13*4,14*4
	dc.w	7*4,6*4,14*4,15*4
	dc.w	4*4,7*4,15*4,12*4

	even

anx:	dc.x	0.0
any:	dc.x	0.0
anz:	dc.x	0.0
;OBS!!! inget mellen anz och xx
xx:	dc.s	0	;  float s1,s2,s3,c1,c2,c3,xx,xy,xz,yx,yy,yz,zx,zy,zz;
xy:	dc.s	0
xz:	dc.s	0
yx:	dc.s	0
yy:	dc.s	0
yz:	dc.s	0
zx:	dc.s	0
zy:	dc.s	0
zz:	dc.s	0

sortcoords:	dcb.w	2*(4+1),0
		even

mapcoords:	dc.w	0,0,maps^2-1,0,maps^2-1,maps^2-1,0,maps^2-1,0,0
		even

		section	bss

		even

ymax:		ds.w	0
ymin:		ds.w	0
		even

synl_faces:	ds.w	NUMFACE
zposition:	ds.w	NUMFACE
		even

RotCoords:	ds.w	NUMCOORD*4	;x,y,z,0
EnvCoords:	ds.w	NUMCOORD*4	;u,v,0,0
		even

MatCoords:	ds.b	100*NUMCOORD*3	;x,y,z
MatCoords2:	ds.b	100*NUMCOORD*3	;normals nx,ny,nz,0	
		even

ytrace1:	ds.w	256
ytrace2:	ds.w	256
ytrace_xt1:	ds.w	256
ytrace_xt2:	ds.w	256
ytrace_yt1:	ds.w	256
ytrace_yt2:	ds.w	256
		even

trace_vector:	ds.w	256
		even

		ds.w	256*2
trace_scr:	ds.w	256*2
		ds.w	256*2
		even

		ds.w	256*2
trace_map:	ds.w	256*4
		ds.w	256*2
		even

		ds.l	10000


		ds.l	2000
save_fpu:	ds.l	2000			;fpu save
		even
screen_centre:	ds.l	1
		even

		section text