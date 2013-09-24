
		section	text

SPSIZE = 8*4 	; size of one struct in the motion keys
fpusave: dc.l	0

;cubic splines
;in 

CalcSpline:
	fmove.l	fpcr,fpusave
	fpu_rnd_floor

	move.l	camera,a0
	lea	xpos,a1
	move.w	#7-1,d7
.cs:
	fmove.l	t,fp0
	fmul.s	#0.00006,fp0		;1/100s
	movem.l	d0-a6,-(sp)
	bsr	spline
	movem.l	(sp)+,d0-a6
	fmove.s	fp0,(a1)+
	add.l	#4,a0	   	;next coord
	dbra	d7,.cs

	fmove.l	fpusave,fpcr
	rts

;in
;a0  : splinecurve
;fp0 : current linear time , intervalue=splinepos

spline:
	movem.l	d0-a6,-(sp)
	fmovem	fp1-fp7,-(sp)

	fmove	fp0,fp7
;	fsub.s	#0.5,fp7	;???
;	fmove.l	fp7,d0		;  key = int(t);
	fmove	fp7,fp6
;	fint	fp6
	fmove.l	fp6,d0
	
	move.l	d0,d1
	divu	NUMCAM,d1
 	swap	d1

;	and.w	#3,d1
	mulu	#SPSIZE,d1
	add.l	d1,a0

	fmove.s	1*SPSIZE(a0),fp0	;  y0=coord[tid+1];
	fmove.s	2*SPSIZE(a0),fp1	;  y1=coord[tid+2];

	fmove	fp1,fp2			;  yd0=(coord[tid+2]-coord[tid+0])/2;
	fsub.s	0*SPSIZE(a0),fp2
	fdiv.s	#2,fp2

	fmove.s	3*SPSIZE(a0),fp3	;  yd1=(coord[tid+3]-coord[tid+1])/2;
	fsub	fp0,fp3
	fdiv.s	#2,fp3

;  d1=y0; fp0
;  c=yd0; fp2

	fmove	fp3,fp4		;  a=yd1-2*y1+c+2*d1;
	fsub	fp1,fp4
	fsub	fp1,fp4
	fadd	fp2,fp4
	fadd	fp0,fp4
	fadd	fp0,fp4	;a

	fmove	fp3,fp5		;  b=(yd1-3*a-c)/2;
	fsub	fp4,fp5
	fsub	fp4,fp5
	fsub	fp4,fp5
	fsub	fp2,fp5
	fdiv.s	#2,fp5	;b

;	fadd.s	#0.5,fp7		;  t=t-tid; ???
	fsub.l	d0,fp7	;t

	fmul	fp7,fp4		;  y=a*t*t*t+b*t*t+c*t+d1;
	fmul	fp7,fp4
	fmul	fp7,fp4
	fmul	fp7,fp5	
	fmul	fp7,fp5	
	fmul	fp7,fp2
	fadd	fp5,fp4
	fadd	fp2,fp4
	fadd	fp0,fp4

	fmove	fp4,fp0
;	fmove.s	fp4,retur		;  return y;

	fmovem	(sp)+,fp1-fp7
	movem.l	(sp)+,d0-a6

;	fmove.s	retur,fp0

	rts			;}

;retur:	dc.s	0
