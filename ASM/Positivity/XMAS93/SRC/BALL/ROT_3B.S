; *************************************************************************
; **        Routine qui effectue les rotations des trois boules.         **
; *************************************************************************
; a0.l = adresse du tableau de coords.
; a1.l = adresse ou stocker les coords.
; d0.w = angle autour de z.
; d1.w = angle autour de y.
; d2.w = angle autour de x.

  movem.l	d0-a5,-(sp)

  add.w	d0,d0	; 1 mot par sin_cos.
  add.w	d1,d1
  add.w	d2,d2
  
  move.l	#.sin_cos,a2 	; a2 pointe sur les sin.
  move.l	#.sin_cos+$100,a3 ; a3 pointe sur les cos.
  
.z_rotation:
  move.l	a1,a4	; a4 pointe sur le tableau final.
  move.w	(a3,d0.w),d3	; d3=cos(ang_z).
  move.w	(a2,d0.w),d0	; d0=sin(ang_z).

  rept	3
  move.w	(a0)+,d4	; Coord x.
  move.w	(a0)+,d5	; Coord y.
  move.w	d4,d6
  move.w	d5,d7
  muls.w	d0,d4	; d4=x*sin(ang_z).
  add.l	d4,d4
  add.l	d4,d4
  swap.w	d4
  muls.w	d3,d6	; d6=x*cos(ang_z).
  add.l	d6,d6
  add.l	d6,d6
  swap.w	d6
  muls.w	d0,d5	; d5=y*sin(ang_z).
  add.l	d5,d5
  add.l	d5,d5
  swap.w	d5
  muls.w	d3,d7	; d7=y*cos(ang_z).
  add.l	d7,d7
  add.l	d7,d7
  swap.w	d7
  sub.w	d5,d6	; d6=x'=x*cos-y*sin.
  add.w	d4,d7	; d7=y'=x*sin+y*cos.
  move.w	d6,(a4)+	; Sauver x.	
  move.w	d7,(a4)+	; Sauver y.
  move.w	(a0)+,(a4)+	; Sauver z.
  endr

.y_rotation:
  move.l	a1,a4	; a4 pointe sur le tableau final.
  move.l	a1,a0	; a0 aussi.
  move.w	(a3,d1.w),d3	; d3=cos(ang_y).
  move.w	(a2,d1.w),d0	; d0=sin(ang_y).

  rept	3
  move.w	(a0)+,d4	; Coord x.
  move.w	(a0)+,a5	; Coord y.
  move.w	(a0)+,d5	; Coord z.
  move.w	d4,d6
  move.w	d5,d7
  muls.w	d0,d4	; d4=x*sin(ang_y).
  add.l	d4,d4
  add.l	d4,d4
  swap.w	d4
  muls.w	d3,d6	; d6=x*cos(ang_y).
  add.l	d6,d6
  add.l	d6,d6
  swap.w	d6
  muls.w	d0,d5	; d5=z*sin(ang_y).
  add.l	d5,d5
  add.l	d5,d5
  swap.w	d5
  muls.w	d3,d7	; d7=z*cos(ang_y).
  add.l	d7,d7
  add.l	d7,d7
  swap.w	d7
  add.w	d5,d6	; d6=x'=x*cos+y*sin.
  sub.w	d4,d7	; d7=y'=z*cos-x*sin.
  move.w	d6,(a4)+	; Sauver x.	
  move.w	a5,(a4)+	; Sauver y.
  move.w	d7,(a4)+	; Sauver z.
  endr

.x_rotation:
  move.l	a1,a4	; a4 pointe sur le tableau final.
  move.l	a1,a0	; a0 aussi.
  move.w	(a3,d2.w),d3	; d3=cos(ang_x).
  move.w	(a2,d2.w),d0	; d0=sin(ang_x).

  rept	3
  move.w	(a0)+,(a4)+	; Sauver x.
  move.w	(a0)+,d4	; Coord y.
  move.w	(a0)+,d5	; Coord z.
  move.w	d4,d6
  move.w	d5,d7
  muls.w	d0,d4	; d4=y*sin(ang_x).
  add.l	d4,d4
  add.l	d4,d4
  swap.w	d4
  muls.w	d3,d6	; d6=y*cos(ang_x).
  add.l	d6,d6
  add.l	d6,d6
  swap.w	d6
  muls.w	d0,d5	; d5=z*sin(ang_x).
  add.l	d5,d5
  add.l	d5,d5
  swap.w	d5
  muls.w	d3,d7	; d7=z*cos(ang_x).
  add.l	d7,d7
  add.l	d7,d7
  swap.w	d7
  sub.w	d5,d6	; d6=y'=y*cos-z*sin.
  add.w	d4,d7	; d7=z'=y*sin+z*cos.
  move.w	d6,(a4)+	; Sauver y.	
  move.w	d7,(a4)+	; Sauver z.
  endr

.de_profundis:
  move.l	a1,a4	; a4 pointe sur le tableau final.

  move.w	$4(a4),d3	; d3=z.
  move.w	(a4),d0	; d0=x.
  ext.l	d0
  lsl.w	#$8,d0	; d0=x*256.
  move.w	$2(a4),d1	; d1=y.
  ext.l	d1
  lsl.w	#$8,d1	; d1=y*256.
  move.l	#$2800,d2	; d2=40*256.
  add.w	#$100,d3	; d3=z+256.
  divs.w	d3,d0	; x final.
  divs.w	d3,d1	; y final.
  divs.w	d3,d2	; Taille finale.
  move.w	d0,(a4)+
  move.w	d1,(a4)+
  addq.l	#$2,a4
  move.w	d2,$c(a4)

  move.w	$4(a4),d3	; d3=z.
  move.w	(a4),d0	; d0=x.
  ext.l	d0
  lsl.w	#$8,d0	; d0=x*256.
  move.w	$2(a4),d1	; d1=y.
  ext.l	d1
  lsl.w	#$8,d1	; d1=y*256.
  move.l	#$2800,d2	; d2=40*256.
  add.w	#$100,d3	; d3=z+256.
  divs.w	d3,d0	; x final.
  divs.w	d3,d1	; y final.
  divs.w	d3,d2	; Taille finale.
  move.w	d0,(a4)+
  move.w	d1,(a4)+
  addq.l	#$2,a4
  move.w	d2,$8(a4)

  move.w	$4(a4),d3	; d3=z.
  move.w	(a4),d0	; d0=x.
  ext.l	d0
  lsl.w	#$8,d0	; d0=x*256.
  move.w	$2(a4),d1	; d1=y.
  ext.l	d1
  lsl.w	#$8,d1	; d1=y*256.
  move.l	#$2800,d2	; d2=40*256.
  add.w	#$100,d3	; d3=z+256.
  divs.w	d3,d0	; x final.
  divs.w	d3,d1	; y final.
  divs.w	d3,d2	; Taille finale.
  move.w	d0,(a4)+
  move.w	d1,(a4)+
  move.w	d2,$6(a4)
  
  movem.l	(sp)+,d0-a5
  rts

  Section DATA
  
.sin_cos:
  incbin	'a:\ball\sin_cos.xxx'
  
  Section TEXT
