; *************************************************************************
; ****				       ****
; ****	 Routine which rotate points around two axis.	       ****
; ****	              By Alain BROBECKER.	       ****
; ****		24th June 1994		       ****
; ****				       ****
; *************************************************************************
; To gain speed, I have decided to make only two rotations.. The movements
; are then less various, but you can make nice moves anyway.. Another gain
; is done due to the organisation of the initial points. They are placed so
; that all the points with the same x coordinates are placed one after
; another... The exact definition for a set of point which have the same
; x coord is the following:
;   1 word	  n	Number of points with the next x coord.
;   1 word	  x	x coord of the n points.
;   2*n words	y(n);z(n)	y and z of all the points.
;
; For example a cube will be defined like this:
;	  4	There are 4 brows with the next x.
;	 40	x coord of next 4 brows.
;	 40; 40	y & z coords of brow 1.
;	-40; 40	y & z coords of brow 2.
;	 40;-40	y & z coords of brow 3.
;	-40;-40	y & z coords of brow 4.
;	  4	There are 4 brows with the next x.
;	- 40	x coord of next 4 brows.
;	 40; 40	y & z coords of brow 5.
;	-40; 40	y & z coords of brow 6.
;	 40;-40	y & z coords of brow 7.
;	-40;-40	y & z coords of brow 8.
;	  0	No more brows.
;
; The points after the rotation are saved "normally". This mean each point
; has its x;y;z coords saved, one after another. The depth effect is not
; done because some tridi calculations (lightsourcing...) need to have
; tridi vectors.
; Another thing, again to gain some clockcycles is that all the coords must
; be premultiplicated by 256. So, in the example above, you should have
; 40*256 instead of 40.
; *************************************************************************
; The parameters for the routine are:
;	a0.l = adress of the initial points.
;	a1.l = adress where to save the rotated points.
;	d0.w = angle around x=a. (0-255)
;	d1.w = angle around y=b. (0-255)

  movem.l	d0-a6,-(sp)

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Let' s begin with the calculation of all the matricial coefficients.

.calc_coefs:
  move.l	#.sinus,a2	; Sinus table.
  move.l	a2,a3
  add.w	#$80,a3	; Cosinus table.
  add.w	d0,d0	; One word per sinus.
  add.w	d1,d1
  move.w	(a3,d1.w),-(sp)	; Store A=cos(b).
  move.w	(a2,d1.w),-(sp)	; Store G=sin(b).
  move.w	(a3,d0.w),-(sp)	; Store E=cos(a).
  move.w	(a2,d0.w),-(sp)	; Store F=sin(a).
  move.w	#$1ff,d7	; A mask for (a+-b mod(256))*2.
  move.w	d0,d2
  add.w	d1,d2	; d2=a+b.
  and.w	d7,d2	; Only 256 sinus.
  move.w	d0,d3
  sub.w	d1,d3	; d3=a-b.
  and.w	d7,d3
  sub.w	d0,d1	; d1=b-a.
  and.w	d7,d1
  move.w	(a3,d3.w),d0	; d0=cos(a-b).
  move.w	(a3,d2.w),d4	; d4=cos(a+b).
  move.w	(a2,d1.w),d1	; d1=sin(b-a).
  move.w	(a2,d2.w),d2	; d2=sin(a+b).
  move.w	(a2,d3.w),d3	; d3=sin(a-b).
  move.w	d4,d5
  sub.w	d0,d5	; d5=cos(a+b)-cos(a-b).
  ext.l	d5
  lsr.l	#$1,d5
  move.w	d5,-(sp)	; Store B=-0.5*(cos(a-b)-cos(a+b)).
  add.w	d2,d1	; d1=sin(b-a)+sin(a+b)
  ext.l	d1
  lsr.l	#$1,d1
  move.w	d1,-(sp)	; Store C=0.5*(sin(a+b)+sin(b-a)).
  move.w	d2,d1
  add.w	d3,d1	; d1=sin(a+b)+sin(a-b).
  ext.l	d1
  lsr.l	#$1,d1	; d1=H=0.5*(sin(a+b)+sin(a-b)).
  add.w	d4,d0	; d0=cos(a-b)+cos(a+b).
  neg.w	d0
  ext.l	d0
  lsr.l	#$1,d0	; d0=I=-0.5*(cos(a+b)+cos(a-b)).

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Let' s continue with the calculations of B*C;E*F;H*I.

  move.w	(sp),d2
  muls.w	d2,d5	; d5=B*C.
  swap.w	d5
  move.w	d5,a2
  move.w	d1,d2
  muls.w	d0,d2	; d2=H*I.
  swap.w	d2
  move.w	d2,a4
  move.w	$4(sp),d2	; d2=F.
  muls.w	$6(sp),d2	; d2=E*F.
  swap.w	d2
  move.w	d2,a3

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; So, here we have:
;  a2.w = B*C	  a3.w = E*F	 a4.w = H*I
;  d0.w = I	  d1.w = H	 (sp) = C
;  2(sp) = B	  4(sp) = F	 6(sp) = E
;  8(sp) = G	  a(sp) = A.
; Now let' s go for the calculations for each point.

.one_x_coord:		; A set of points with the same x coord.
  move.w	(a0)+,d7	; d7=nb of points with this x.
  subq.w	#$1,d7	; Beware the dbra.
  bmi.s	.the_end	; d7=0? No more points?
  move.w	(a0)+,d6	; d6=x.
  move.w	$a(sp),d5	; d5=A.
  muls.w	d6,d5
  swap.w	d5
  move.w	d5,a5	; a5=A*x.
  muls.w	$8(sp),d6
  swap.w	d6
  move.w	d6,a6	; a6=G*x.
.one_point:
  move.w	(a0)+,d5	; d5=y.
  move.w	(a0)+,d6	; d6=z.
  move.w	d6,d4
  muls.w	d5,d4	; d4=y*z.
  swap.w	d4
  move.w	(sp),d2	; d2=C.
  move.w	$2(sp),d3	; d3=B.
  add.w	d5,d2	; d2=C+y.
  add.w	d6,d3	; d3=B+z.
  muls.w	d2,d3	; d3=(B+z)*(C+y).
  swap.w	d3
  sub.w	d4,d3	; d3=..-y*z.
  sub.w	a2,d3	; d3=..-B*C.
  add.w	a5,d3	; d3=..+A*x.
  move.w	d3,(a1)+	; Save x=(B+z)*(C+y)-y*z-B*C+A*x.
  move.w	$4(sp),d2	; d2=F.
  move.w	$6(sp),d3	; d3=E.
  add.w	d5,d2	; d2=F+y.
  add.w	d6,d3	; d3=E+z.
  muls.w	d2,d3	; d3=(E+z)*(F+y).
  swap.w	d3
  sub.w	d4,d3	; d3=..-y*z.
  sub.w	a3,d3	; d3=..-E*F.
  move.w	d3,(a1)+	; Save y=(E+z)*(F+y)-y*z-E*F.
  add.w	d0,d5	; d5=I+y.
  add.w	d1,d6	; d6=H+z.
  muls.w	d5,d6	; d6=(H+z)*(I+y).
  swap.w	d6
  sub.w	d4,d6	; d6=..-y*z.
  sub.w	a4,d6	; d6=..-H*I.
  add.w	a6,d6	; d6=..+G*x.
  neg.w	d6
  move.w	d6,(a1)+	; Save z=(H+z)*(I+y)-y*z-H*I+G*x.
  dbra	d7,.one_point	; Next point.
  bra.s	.one_x_coord	; Next x set.

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Pfiuuuu... It's the end for now.

.the_end:
  add.l	#$c,sp	; Fuck what was stored.
  movem.l	(sp)+,d0-a6
  rts

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Section DATA

.sinus:
  incbin	'..\shading\sinus.xxx'
