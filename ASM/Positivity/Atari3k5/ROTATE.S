; ***********************************
; **	                   **
; **  Rotation routine by Dracula  **
; **        made on june 93        **
; **   commercial use prohibited   **
; **	                   **
; ***********************************
; Parameters:
;     a0.l = adress of points' coords.
;     a1.l = stockage adress.
;     a2.w = z translation.
;     d0.w = angle around x. (alpha)
;     d1.w = angle around y. (teta)
;     d2.w = nb of points.
; Uses no register, uses no customchips!...
;   ( Who needs a 68882 anyway?... )

;************
 Section TEXT

  movem.l	d3-d7/a3,-(sp)

.calc_matrix:
  move.l	#.sin_cos,a3
  add.w	d0,d0
  add.w	d1,d1
  move.w	(a3,d0.w),d4	; d4=sin(alpha).
  move.w	(a3,d1.w),d5	; d5=sin(teta).
  add.l	#$100,a3
  move.w	(a3,d0.w),d6	; d6=cos(alpha).
  move.w	(a3,d1.w),d7	; d7=cos(teta).
  move.l	#.matrix,a3
  move.w	d7,(a3)+	; a11=cos(teta).
  move.w	d4,d0
  muls.w	d5,d0
  add.l	d0,d0
  add.l	d0,d0
  swap.w	d0
  move.w	d0,(a3)+	; a12=sin(alpha)*sin(teta).
  move.w	d6,d0
  muls.w	d5,d0
  add.l	d0,d0
  add.l	d0,d0
  swap.w	d0
  move.w	d0,(a3)+	; a13=cos(alpha)*sin(teta).
  move.w	d6,(a3)+	; a21=0, a22=cos(alpha).
  neg.w	d4
  move.w	d4,(a3)+	; a23=-sin(alpha).
  neg.w	d4
  neg.w	d5
  move.w	d5,(a3)+	; a31=-sin(teta).
  muls.w	d7,d4
  add.l	d4,d4
  add.l	d4,d4
  swap.w	d4
  move.w	d4,(a3)+	; a32=sin(alpha)*cos(teta).
  muls.w	d7,d6
  add.l	d6,d6
  add.l	d6,d6
  swap.w	d6
  move.w	d6,(a3)+	; a33=cos(alpha)*cos(teta).
  subq.w	#$1,d2	; cos of the dbra.
.calc_one:
  move.l	#.matrix,a3
  move.w	(a0)+,d5	; x.
  move.w	(a0)+,d6	; y.
  move.w	(a0)+,d7	; z.
  move.w	(a3)+,d0	; a11.
  move.w	(a3)+,d1	; a12.
  move.w	(a3)+,d3	; a13.
  muls.w	d5,d0
  muls.w	d6,d1
  muls.w	d7,d3
  add.l	d0,d1
  add.l	d1,d3
  lsr.l	#$6,d3	; d3=x'*256.
  move.w	(a3)+,d0	; a22.
  move.w	(a3)+,d1	; a23.
  muls.w	d6,d0
  muls.w	d7,d1
  add.l	d0,d1
  lsr.l	#$6,d1	; d1=y'*256.
  move.w	(a3)+,d0	; a31.
  move.w	(a3)+,d4	; a32.
  muls.w	d5,d0
  muls.w	d6,d4
  add.l	d0,d4
  move.w	(a3)+,d0	; a33.
  muls.w	d7,d0
  add.l	d4,d0
  add.l	d0,d0
  add.l	d0,d0
  swap.w	d0	; d0=z'.
.perspective:
  add.w	a2,d0	; z translation.
  add.w	#$100,d0	; dist_user=256.
  ext.l	d1	; Extend x' and y' to a long.
  ext.l	d3
  divs.w	d0,d3
  divs.w	d0,d1
  move.w	d3,(a1)+
  move.w	d1,(a1)+
  dbra	d2,.calc_one
  
  movem.l	(sp)+,d3-d7/a3
  rts
  

;************
 Section DATA

.sin_cos:
  incbin	'c:\sources\atari\sin_cos.bin',0

;***********
 Section BSS
 
.matrix:
  ds.w	8
  
