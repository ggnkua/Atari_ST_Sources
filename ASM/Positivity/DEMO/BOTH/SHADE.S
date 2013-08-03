; *************************************************************************
; *****				      *****
; *****	Routine which draws a 3-planes shaded polygon.	      *****
; *****	            By Alain BROBECKER.		      *****
; *****	   Coded between 22nd and 23rd of june 1994.	      *****
; *****	  Rewritten & Optimised on 25th of june 1994.	      *****
; *****				      *****
; *************************************************************************
; Parameters:	a0.l = ramvideo adress.
;	a1.l = adress of brows coords and intensities.
;	d0.w = nb of brows.
;
; The brows coords and intensities are organised like this:
; 1 word: x.
; 1 word: y.
; 1 word: intensity. (Integer part of it in the 4 most significant bits.)
; The brows must be placed anticlockwise. Also, the min intensity must be
; 2 and the max one must be 14 as there sometimes is an imprecision of
; one color during the interpolation.
; *************************************************************************

  movem.l	d0-a6,-(sp)

; *************************************************************************
; * First copy the brows once just after their first appearance in a1.l, so
; * the "tracking" of the min & max lines will be easier. At the same time
; * search ymin & ymax of the poly.
.copy_and_search:
  move.l	a1,a2
  move.l	a2,a3
  move.w	d0,d1	; 6 words per brow.
  add.w	d1,d1
  add.w	d0,d1
  add.w	d1,d1
  add.w	d1,a3	; a3 points just after the brows.
  move.w	#800,d6	; d6=ymin.
  move.w	#-600,d7	; d7=ymax.
  subq.w	#$1,d0	; Beware the dbra.
  
.copy_one_brow:
  move.l	(a2)+,d1	; Load x and y in d1.
  move.l	d1,(a3)+	; Copy them.
  cmp.w	d1,d6	; This y lower than ymin?
  blt.s	.not_ymin
  move.w	d1,d6	; Yes, then it's the new ymin.
.not_ymin:
  cmp.w	d1,d7	; This y bigger than ymax?
  bgt.s	.not_ymax
  move.w	d1,d7	; Yes, then it' s the new ymax.
.not_ymax:
  move.w	(a2)+,(a3)+	; Copy intensity.
  dbra	d0,.copy_one_brow ; Next brow.
  
; *************************************************************************
; * When ymin and ymax are found, we can see if the poly is in the screen,
; * if it' s partly hidden (y_clipping only) or if it' s invisible.

.poly_visibility:
  cmp.w	d6,d7	; ymin=ymax?
  beq.s	.poly_invisible
  tst.w	d7	; ymax=<0?
  ble.s	.poly_invisible
  cmp.w	#198,d6	; ymin>=199?
  ble.s	.poly_clipping
.poly_invisible:	; Poly out of the screen, so...
  movem.l	(sp)+,d0-a6
  rts
  
.poly_clipping:		; The poly is (partly?) visible.
  moveq.l	#$0,d0	; d0=nb h_lines to pass at the beginning.
  move.w	d7,d1
  sub.w	d6,d1	; d1=ymax-ymin=nb h_lines to draw-1.
  tst.w	d6	; ymin<0?
  bge.s	.no_clip_up
.clip_up:		; Yes, so cut the first -ymin h_lines.
  move.w	d6,d0	; Pass -ymin h_lines at the beginning.
  neg.w	d0
  move.w	d7,d1	; Nb lines to draw=ymax-0.
  bra.s	.no_clip_down	; I assume the poly is not that big.
.no_clip_up:
  cmp.w	#199,d7	; ymax>199.
  ble.s	.no_clip_down
.clip_down:
  move.w	#199,d1	; Yes, so reduce the nb of h_lines.
  sub.w	d6,d1
.no_clip_down:
  move.w	d0,.nb_lines_2_pass
  addq.w	#$1,d1
  move.w	d1,.nb_lines_2_draw
  
; *************************************************************************
; * Not very hard or important, but we must do it, so....

  move.l	#.y_table,a2	; The faster way to multiply by 160???
  move.w	d6,d5
  add.w	d0,d5	; d5=first seen y.
  add.w	d5,d5	; One word per y.
  add.w	(a2,d5.w),a0	; a0 points on first line.

; *************************************************************************
; * Now, the first important part. We "track" the max_lines, which are on
; * the right of the poly and calculate xmax and intensity_max for each
; * y between ymin-ymax by using linear interpolations.

.xmax_tracking:		; First, search the upper right brow.
  subq.w	#$6,a3	; Next point in clockwise cycle.
  cmp.w	$2(a3),d6	; y=ymin?
  bne.s	.xmax_tracking
.xmax_ymin_found:	; If the next brow=ymin, then it' s more
  cmp.w	-$4(a3),d6	; on the right...
  bne.s	.xmax_ymin_ok
  subq.w	#$6,a3	; It is the upper right brow.
.xmax_ymin_ok:		; a3 points on the good brow.

  move.l	#.xmax_buffer,a2 ; Store int_maxs and xmaxs here.
  move.l	#.inverses,a4	; Inverse table.
  move.l	#.xmax_ad,a5	; The adresses for the jump.
.xmax_one_line:		; Interpolate on one line.
  move.w	(a3),d0	; d0=x1.
  move.w	$2(a3),d1	; d1=y1.
  cmp.w	d1,d7	; y1=ymax?
  beq	.xmax_end	; Yes, then it' s finished.
  move.w	$4(a3),d2	; d2=intensity1.
  subq.l	#$6,a3	; Next brow.
  move.w	(a3),d3	; d3=x2.
  move.w	$2(a3),d4	; d4=y2.
  move.w	$4(a3),d5	; d5=intensity2.
  sub.w	d1,d4	; d4=y2-y1, always <>0.
  add.w	d4,d4	; One word per inverse.
  move.w	(a4,d4.w),d1	; d1=16384/(y2-y1).
  add.w	d4,d4	; Two words per jump adress.
  move.l	(a5,d4.w),a6	; a6=adress where to jump.
  sub.w	d2,d5	; d5=int2-int1.
  muls.w	d1,d5
  lsl.l	#$2,d5	; d5=65536*(int2-int1)/dy.
  sub.w	d0,d3	; d3=x2-x1.
  muls.w	d1,d3
  lsl.l	#$2,d3	; d3=65536*(dx/dy).
  swap.w	d3
  move.w	d3,d5	; up(d5)=dint/dy ; low(d5)=int(dx/dy).
  swap.w	d3	; low(d3)=reg(dx/dy).
  swap.w	d2
  move.w	d0,d2	; up(d2)=intensity ; low(d2)=x.
  moveq.l	#$0,d0	; d0=error.
  jmp	(a6)

 rept	300
  move.l	d2,(a2)+	; Save intensity and x.
  add.w	d3,d0	; error=error+reg(dx/dy).
  addx.l	d5,d2	; int=int+inc ; x=x+int(dy/dx)+eXtend.
 endr
.xmax_line_end:
  subq.w	#$4,a2	; Erase last point.
  bra	.xmax_one_line
.xmax_end:

; *************************************************************************
; * Do the same with the min_lines, which are on the right of the poly
; * and calculate xmin and intensity_min for each y between ymin-ymax by
; * using linear interpolations.

  subq.w	#$6,a1
.xmin_tracking:		; First, search the upper left brow.
  addq.w	#$6,a1	; Next point in anticlockwise cycle.
  cmp.w	$2(a1),d6	; y=ymin?
  bne.s	.xmin_tracking
.xmin_ymin_found:	; If the next brow=ymin, then it' s more
  cmp.w	$a(a1),d6	; on the left...
  bne.s	.xmin_ymin_ok
  addq.w	#$6,a3	; It is the upper left brow.
.xmin_ymin_ok:		; a1 points on the good brow.

  move.l	#.xmin_buffer,a2 ; Store int_mins and xmins here.
  move.l	#.inverses,a4	; Inverse table.
  move.l	#.xmin_ad,a5	; The adresses for the jump.
.xmin_one_line:		; Interpolate on one line.
  move.w	(a1)+,d0	; d0=x1.
  move.w	(a1)+,d1	; d1=y1.
  cmp.w	d1,d7	; y1=ymax?
  beq	.xmin_end	; Yes, then it' s finished.
  move.w	(a1)+,d2	; d2=intensity1.
  move.w	(a1),d3	; d3=x2.
  move.w	$2(a1),d4	; d4=y2.
  move.w	$4(a1),d5	; d5=intensity2.
  sub.w	d1,d4	; d4=y2-y1, always <>0.
  add.w	d4,d4	; One word per inverse.
  move.w	(a4,d4.w),d1	; d1=16384/(y2-y1).
  add.w	d4,d4	; Two words per jump adress.
  move.l	(a5,d4.w),a6	; a6=adress where to jump.
  sub.w	d2,d5	; d5=int2-int1.
  muls.w	d1,d5
  lsl.l	#$2,d5	; d5=65536*(int2-int1)/dy.
  sub.w	d0,d3	; d3=x2-x1.
  muls.w	d1,d3
  lsl.l	#$2,d3	; d3=65536*(dx/dy).
  swap.w	d3
  move.w	d3,d5	; up(d5)=dint/dy ; low(d5)=int(dx/dy).
  swap.w	d3	; low(d3)=reg(dx/dy).
  swap.w	d2
  move.w	d0,d2	; up(d2)=intensity ; low(d2)=x.
  moveq.l	#$0,d0	; d0=error.
  jmp	(a6)

 rept	300
  move.l	d2,(a2)+	; Save intensity and x.
  add.w	d3,d0	; error=error+reg(dx/dy).
  addx.l	d5,d2	; int=int+inc ; x=x+int(dy/dx)+eXtend.
 endr
.xmin_line_end:
  subq.w	#$4,a2	; Erase last point.
  bra	.xmin_one_line
.xmin_end:

; *************************************************************************
; * Ok, now we have all we want, it' s now time to draw the poly on the
; * screen. I proceed by drawing each h_line one after another, and as
; * intensity_min and intensity_max are different, I have to do an
; * interpolation between them.

.draw_shaded:
  move.l	#.xmin_buffer,a1
  move.w	.nb_lines_2_pass,d0
  add.w	d0,d0	; 4 bytes per int+x.
  add.w	d0,d0
  add.w	d0,a1	; Pass the invisible lines.
  move.l	#.points_ad,-(sp) ; Store the table x->adress.
  move.l	#.endrouts_ad,-(sp) ; Table xmax mod(16)->endrout adress.
  move.w	.nb_lines_2_draw,d0 ; The counter.
  subq.w	#$1,d0	; Beware dbra..
  move.w	d0,-(sp)	; Store the counter.
  move.l	#.inverses,a2
.draw_one_hline:
  move.w	d0,(sp)	; Store the counter.
  move.w	(a1)+,d5	; d5=int_min.
  move.w	1198(a1),d6	; d6=int_max.
  move.w	(a1)+,d0	; d0=xmin.
  move.w	1198(a1),d1	; d1=xmax.
  move.w	d1,d2
  sub.w	d0,d2	; d2=xmax-xmin=dx.
  ble.s	.next_line	; Don' t draw if xmin>=xmax.
  add.w	d2,d2
  move.w	(a2,d2.w),d2	; d2=16384/dx.
  sub.w	d5,d6	; d6=int_max-int_min=dint.
  add.w	d5,d5	; The intensity in the 4 Msbits...
  muls.w	d2,d6
  lsl.l	#$3,d6	; d6=2*65536*(dint/dx). No more sign bit.
  swap.w	d6	; In the lowerword please.
  move.w	d6,d7
  add.w	#$800,d6	; d6=inc1=0.5+(dint/dx).
  sub.w	#$800,d7	; d7=inc2=-0.5+(dint/dx).
  move.l	$2(sp),a4	; a4=endrouts_ad table.
  move.w	d1,d2
  moveq.l	#$f,d3
  and.w	d3,d2	; d2=xmax mod(16).
  add.w	d2,d2	; One long per adress.
  add.w	d2,d2
  move.l	(a4,d2.w),a4	; a4 points on the endrout to use.
  move.l	$6(sp),a5	; points_ad table.
  and.w	d0,d3	; d3=xmin mod(16).
  sub.w	d3,d0	; d0=xmin-xmin mod(16).
  add.w	d3,d3
  add.w	d3,d3
  move.l	(a5,d3.w),a3	; a3 points on first point.
  sub.w	d0,d1	; d1=xmax-(xmin-xmin mod(16)).
  add.w	d1,d1
  add.w	d1,d1
  move.l	(a5,d1.w),a5	; a5 points on last point-1.
  move.w	#$4ed4,(a5)	; Put the "jump (a4)".
  lsr.w	#$1,d0	; d0=offset to xmin.
  move.l	a0,a6
  add.w	d0,a6	; a6 points on first word.
  add.w	#$a0,a0	; Next line.
  moveq.l	#$0,d1	; Clear bitplanes.
  moveq.l	#$0,d2
  moveq.l	#$0,d3
  moveq.l	#$0,d4
  jmp	(a3)	; Go on first point.
  
.next_line:
  move.w	(sp),d0	; Load the counter.
  dbra	d0,.draw_one_hline
  add.w	#$a,sp	; Fuck the stored tiddies.
.the_end:
  movem.l	(sp)+,d0-a6
  rts

; *************************************************************************
; * We have to use different endroutines in order to gain speed, cos the
; * ending bitplanes must be rotated and they must be "or.w".

shademac1:	MACRO
;  add.w	d5,d5
;  addx.w	d4,d4
  add.w	d5,d5
  addx.w	d3,d3
  add.w	d5,d5
  addx.w	d2,d2
  add.w	d5,d5
  addx.w	d1,d1
  	ENDM

shademac2:	MACRO
  and.w	d0,d1
  and.w	d0,d2
  and.w	d0,d3
;  and.w	d0,d4
	ENDM

shademac3:	MACRO
  or.w	d1,(a6)+
  or.w	d2,(a6)+
  or.w	d3,(a6)+
;  or.w	d4,(a6)+
  	ENDM

shademac4:	MACRO
  move.w	#$3005,(a5)	; Restore initial code.
  move.w	(sp),d0	; Load counter.
  dbra	d0,.draw_one_hline
  add.w	#$a,sp	; Fuck the stored tiddies.
  movem.l	(sp)+,d0-a6	; The end.
  rts
	ENDM


.endrout_0:
  shademac1		; Convert last point.
  ror.w	#$1,d1	; Rotate the bitplanes.
  ror.w	#$1,d2
  ror.w	#$1,d3
;  ror.w	#$1,d4
  move.w	#$8000,d0	; For destroying unusefull bits.
  shademac2		; Fuck them.
  shademac3		; Print last word.
  shademac4

.endrout_1:
  shademac1		; Convert last point.
  ror.w	#$2,d1	; Rotate the bitplanes.
  ror.w	#$2,d2
  ror.w	#$2,d3
;  ror.w	#$2,d4
  move.w	#$c000,d0	; For destroying unusefull bits.
  shademac2		; Fuck them.
  shademac3		; Print last word.
  shademac4

.endrout_2:
  shademac1		; Convert last point.
  ror.w	#$3,d1	; Rotate the bitplanes.
  ror.w	#$3,d2
  ror.w	#$3,d3
;  ror.w	#$3,d4
  move.w	#$e000,d0	; For destroying unusefull bits.
  shademac2		; Fuck them.
  shademac3		; Print last word.
  shademac4

.endrout_3:
  shademac1		; Convert last point.
  ror.w	#$4,d1	; Rotate the bitplanes.
  ror.w	#$4,d2
  ror.w	#$4,d3
;  ror.w	#$4,d4
  move.w	#$f000,d0	; For destroying unusefull bits.
  shademac2		; Fuck them.
  shademac3		; Print last word.
  shademac4

.endrout_4:
  shademac1		; Convert last point.
  ror.w	#$5,d1	; Rotate the bitplanes.
  ror.w	#$5,d2
  ror.w	#$5,d3
;  ror.w	#$5,d4
  move.w	#$f800,d0	; For destroying unusefull bits.
  shademac2		; Fuck them.
  shademac3		; Print last word.
  shademac4

.endrout_5:
  shademac1		; Convert last point.
  ror.w	#$6,d1	; Rotate the bitplanes.
  ror.w	#$6,d2
  ror.w	#$6,d3
;  ror.w	#$6,d4
  move.w	#$fc00,d0	; For destroying unusefull bits.
  shademac2		; Fuck them.
  shademac3		; Print last word.
  shademac4

.endrout_6:
  shademac1		; Convert last point.
  ror.w	#$7,d1	; Rotate the bitplanes.
  ror.w	#$7,d2
  ror.w	#$7,d3
;  ror.w	#$7,d4
  move.w	#$fe00,d0	; For destroying unusefull bits.
  shademac2		; Fuck them.
  shademac3		; Print last word.
  shademac4

.endrout_7:
  shademac1		; Convert last point.
  lsl.w	#$8,d1	; Rotate the bitplanes.
  lsl.w	#$8,d2
  lsl.w	#$8,d3
;  lsl.w	#$8,d4
  shademac3		; Print last word.
  shademac4

.endrout_8:
  shademac1		; Convert last point.
  lsl.w	#$7,d1	; Rotate the bitplanes.
  lsl.w	#$7,d2
  lsl.w	#$7,d3
;  lsl.w	#$7,d4
  shademac3		; Print last word.
  shademac4

.endrout_9:
  shademac1		; Convert last point.
  lsl.w	#$6,d1	; Rotate the bitplanes.
  lsl.w	#$6,d2
  lsl.w	#$6,d3
;  lsl.w	#$6,d4
  shademac3		; Print last word.
  shademac4

.endrout_a:
  shademac1		; Convert last point.
  lsl.w	#$5,d1	; Rotate the bitplanes.
  lsl.w	#$5,d2
  lsl.w	#$5,d3
;  lsl.w	#$5,d4
  shademac3		; Print last word.
  shademac4

.endrout_b:
  shademac1		; Convert last point.
  lsl.w	#$4,d1	; Rotate the bitplanes.
  lsl.w	#$4,d2
  lsl.w	#$4,d3
;  lsl.w	#$4,d4
  shademac3		; Print last word.
  shademac4

.endrout_c:
  shademac1		; Convert last point.
  lsl.w	#$3,d1	; Rotate the bitplanes.
  lsl.w	#$3,d2
  lsl.w	#$3,d3
;  lsl.w	#$3,d4
  shademac3		; Print last word.
  shademac4

.endrout_d:
  shademac1		; Convert last point.
  lsl.w	#$2,d1	; Rotate the bitplanes.
  lsl.w	#$2,d2
  lsl.w	#$2,d3
;  lsl.w	#$2,d4
  shademac3		; Print last word.
  shademac4

.endrout_e:
  shademac1		; Convert last point.
  add.w	d1,d1	; Rotate the bitplanes.
  add.w	d2,d2
  add.w	d3,d3
;  add.w	d4,d4
  shademac3		; Print last word.
  shademac4

.endrout_f:
  shademac1		; Convert last point.
  shademac3
  shademac4

; *************************************************************************
; * The core of the shading poly routine... Very repetitive, cos I don' t
; * like the dbra and I LOOOOooove Speed....

shademac5:	MACRO
 rept	8
  move.w	d5,d0	; Convert first point.
;  add.w	d0,d0
;  addx.w	d4,d4
  add.w	d0,d0
  addx.w	d3,d3
  add.w	d0,d0
  addx.w	d2,d2
  add.w	d0,d0
  addx.w	d1,d1
  add.w	d6,d5	; intensity=intensity+increment1.
  move.w	d5,d0	; Convert second point.
;  add.w	d0,d0
;  addx.w	d4,d4
  add.w	d0,d0
  addx.w	d3,d3
  add.w	d0,d0
  addx.w	d2,d2
  add.w	d0,d0
  addx.w	d1,d1
  add.w	d7,d5	; intensity=intensity+increment2.
 endr
	ENDM

.core:
  shademac5		; 16 pixies.
  or.w	d1,(a6)+	; Print first bitlanes.
  or.w	d2,(a6)+
  or.w	d3,(a6)+
  addq.w	#$2,a6
;  or.w	d4,(a6)+

.core_2:
  shademac5		; Do 16 pixies.
  movem.w	d1-d3,(a6)	; Store planes.
  addq.w	#$8,a6
  shademac5
  movem.w	d1-d3,(a6)
  addq.w	#$8,a6
  shademac5
  movem.w	d1-d3,(a6)
  addq.w	#$8,a6
  shademac5
  movem.w	d1-d3,(a6)
  addq.w	#$8,a6
  shademac5
  movem.w	d1-d3,(a6)
  addq.w	#$8,a6
  shademac5
  movem.w	d1-d3,(a6)
  addq.w	#$8,a6
  shademac5
  movem.w	d1-d3,(a6)
  addq.w	#$8,a6
  shademac5
  movem.w	d1-d3,(a6)
  addq.w	#$8,a6
  shademac5
  movem.w	d1-d3,(a6)
  addq.w	#$8,a6
  shademac5
  movem.w	d1-d3,(a6)
  addq.w	#$8,a6
  shademac5
  movem.w	d1-d3,(a6)
  addq.w	#$8,a6
  shademac5
  movem.w	d1-d3,(a6)
  addq.w	#$8,a6
  shademac5
  movem.w	d1-d3,(a6)
  addq.w	#$8,a6
  shademac5
  movem.w	d1-d3,(a6)
  addq.w	#$8,a6
  shademac5
  movem.w	d1-d3,(a6)
  addq.w	#$8,a6
 

; *************************************************************************
  Section DATA
  
.y_table:		; Table for y->y*160 conversions.
N set 0
 rept	200
  dc.w	N  
N set N+160
 endr
 
.inverses:		; Table n->16384/n.
  incbin	'..\shading\inverses.xxx'

.xmax_ad:		; Table of adresses for the jump.
N set 6
 rept	300
  dc.l	.xmax_line_end-N
N set N+6
 endr

.xmin_ad:		; The same for the xmin tracking.
N set 6
 rept	300
  dc.l	.xmin_line_end-N
N set N+6
 endr

.points_ad:		; Convert x->adress in the "core".
N set 0		; For the first 16 pixies.
 rept	16
  dc.l	.core+N
N set N+16
 endr
N set 0		; For the next ones.
 rept	15	; 240 points.
  dc.l	.core_2+000+N,.core_2+016+N
  dc.l	.core_2+032+N,.core_2+048+N
  dc.l	.core_2+064+N,.core_2+080+N
  dc.l	.core_2+096+N,.core_2+112+N
  dc.l	.core_2+128+N,.core_2+144+N
  dc.l	.core_2+160+N,.core_2+176+N
  dc.l	.core_2+192+N,.core_2+208+N
  dc.l	.core_2+224+N,.core_2+240+N
N set N+256+6
 endr
 
.endrouts_ad:		; Table for the endrouts adresses. 
  dc.l	.endrout_0,.endrout_1,.endrout_2,.endrout_3
  dc.l	.endrout_4,.endrout_5,.endrout_6,.endrout_7
  dc.l	.endrout_8,.endrout_9,.endrout_a,.endrout_b
  dc.l	.endrout_c,.endrout_d,.endrout_e,.endrout_f
   
 
; *************************************************************************
  Section BSS
  
.nb_lines_2_pass:	; This two vars are used for the clipping.
  ds.w	1
.nb_lines_2_draw:
  ds.w	1
.xmin_buffer:
  ds.l	300
.xmax_buffer:
  ds.l	300
