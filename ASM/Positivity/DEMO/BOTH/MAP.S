; *************************************************************************
; *****				      *****
; *****	Routine which draws a 1-planes mapped polygon.	      *****
; *****	            By Alain BROBECKER.		      *****
; *****	        Coded on 27th of june 1994.	      *****
; *****				      *****
; *************************************************************************
; Parameters:	a0.l = ramvideo adress.
;	a1.l = adress of brows coords and sourcecoords.
;	a2.l = adress of source image.
;	d0.w = nb of brows.
;
; The brows coords and sourcecoords are organised like this:
; 1 word: x.
; 1 word: y.
; 1 word: source x.
; 1 word: source y.
; The brows must be placed anticlockwise. Like for the shading routine,
; the extremities of the poly are printed using an or.w, so there may be
; a conflict if the pixels are already occupied. (There are some "bad"
; pixies on the shaded cube's edges.) You can avoid this by masking the
; dest words before. (Like a sprite.)
; *************************************************************************

  movem.l	d0-a6,-(sp)
  move.l	a2,.source
  
; *************************************************************************
; * First copy the brows once just after their first appearance in a1.l, so
; * the "tracking" of the min & max lines will be easier. At the same time
; * search ymin & ymax of the poly.
.copy_and_search:
  move.l	a1,a2
  move.l	a2,a3
  move.w	d0,d1	; 8 words per brow.
  lsl.w	#$3,d1
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
  move.l	(a2)+,(a3)+	; Copy source_x and y.
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
; * the right of the poly and calculate xmax,source_x_max and source_y_max
; * for each y between ymin-ymax by using linear interpolations.

.xmax_tracking:		; First, search the upper right brow.
  subq.w	#$8,a3	; Next point in clockwise cycle.
  cmp.w	$2(a3),d6	; y=ymin?
  bne.s	.xmax_tracking
.xmax_ymin_found:	; If the next brow=ymin, then it' s more
  cmp.w	-$6(a3),d6	; on the right...
  bne.s	.xmax_ymin_ok
  subq.w	#$8,a3	; It is the upper right brow.
.xmax_ymin_ok:		; a3 points on the good brow.

  move.l	#.xmax_buffer,a2 ; Store source_x&y maxs and xmaxs here.
  move.l	#.inverses,a4	; Inverse table.
  move.l	#.xmax_ad,a5	; The adresses for the jump.
  move.w	d6,.ymin
  move.w	d7,.ymax
.xmax_one_line:		; Interpolate on one line.
  move.w	(a3),d0	; d0=x1.
  move.w	$2(a3),d1	; d1=y1.
  cmp.w	.ymax,d1	; y1=ymax?
  beq	.xmax_end	; Yes, then it' s finished.
  move.w	$4(a3),d2	; d2=source_x1.
  move.w	$6(a3),d3	; d3=source_y1.
  subq.l	#$8,a3	; Next brow.
  move.w	(a3),d4	; d4=x2.
  move.w	$2(a3),d5	; d5=y2.
  move.w	$4(a3),d6	; d6=source_x2.
  move.w	$6(a3),d7	; d7=source_y2.
  sub.w	d1,d5	; d5=y2-y1, always <>0.
  add.w	d5,d5	; One word per inverse.
  move.w	(a4,d5.w),d1	; d1=16384/(y2-y1).
  add.w	d5,d5	; Two words per jump adress.
  move.l	(a5,d5.w),a6	; a6=adress where to jump.
  sub.w	d0,d4	; d4=dx=x2-x1.
  muls.w	d1,d4
  lsl.l	#$2,d4	; d4=65536*(dx/dy).
  sub.w	d2,d6	; d6=dsource_x=source_x2-source_x1.
  muls.w	d1,d6
  lsl.l	#$2,d6	; d6=65536*(dsource_x/dy).
  sub.w	d3,d7	; d7=dsource_y.
  muls.w	d1,d7
  lsl.l	#$2,d7	; d7=65536*(dsource_y/dy).
  move.w	d4,d1	; d1=reg(dx/dy).
  move.w	d6,d4	; low(d4)=reg(dsource_x/dy).
  swap.w	d4	; d4=reg(dsource_x/dy) | int(dx/dy).
  move.w	d7,d6	; low(d6)=reg(dsource_y/dy).
  swap.w	d6	; d6=reg(dsource_y/dy) | int(dsource_x/dy).
  swap.w	d7	; low(d7)=int(dsource_y/dy).
  move.l	#$ffff,d5
  and.l	d5,d0	; d0=source_x_error | int(x).
  and.l	d5,d2	; d2=source_y_error | int(source_x).
  moveq.l	#$0,d5	; d5=x_error.
  jmp	(a6)

 rept	200
  move.w	d0,(a2)+	; Save xmax.
  move.w	d2,(a2)+	; Save source_x_max.
  move.w	d3,(a2)+	; Save source_y_max.
  add.w	d1,d5	; x_error=x_error+reg(dx/dy).
  addx.l	d4,d0	; src_x_error=src_x_error+reg(dsrc_x/dy),
  ; and in the lowerword: x=x+int(dx/dy)+eXtend.
  addx.l	d6,d2	; src_y_error=src_y_error+reg(dsrc_y/dy),
  ; and in lowerword: src_x=src_x+int(dsrc_x/dy)+eXtend.
  addx.w	d7,d3	; src_y=src_y+int(dsrc_y/dy)+eXtend.
 endr
.xmax_line_end:
  subq.w	#$6,a2	; Erase last point.
  bra	.xmax_one_line
.xmax_end:

; *************************************************************************
; * Do the same with the min_lines, which are on the right of the poly
; * and calculate xmin, src_x_min and src_y_min for each y between ymin
; * and ymax by using linear interpolations.

  move.w	.ymin,d6
  subq.w	#$8,a1
.xmin_tracking:		; First, search the upper left brow.
  addq.w	#$8,a1	; Next point in anticlockwise cycle.
  cmp.w	$2(a1),d6	; y=ymin?
  bne.s	.xmin_tracking
.xmin_ymin_found:	; If the next brow=ymin, then it' s more
  cmp.w	$e(a1),d6	; on the left...
  bne.s	.xmin_ymin_ok
  addq.w	#$8,a3	; It is the upper left brow.
.xmin_ymin_ok:		; a1 points on the good brow.

  move.l	#.xmin_buffer,a2 ; Store int_mins and xmins here.
  move.l	#.inverses,a4	; Inverse table.
  move.l	#.xmin_ad,a5	; The adresses for the jump.
.xmin_one_line:		; Interpolate on one line.
  move.w	(a1)+,d0	; d0=x1.
  move.w	(a1)+,d1	; d1=y1.
  cmp.w	.ymax,d1	; y1=ymax?
  beq	.xmin_end	; Yes, then it' s finished.
  move.w	(a1)+,d2	; d2=src_x1.
  move.w	(a1)+,d3	; d3=src_y1.
  move.w	(a1),d4	; d3=x2.
  move.w	$2(a1),d5	; d5=y2.
  move.w	$4(a1),d6	; d6=src_x2.
  move.w	$6(a1),d7	; d7=src_y2.
  sub.w	d1,d5	; d5=y2-y1, always <>0.
  add.w	d5,d5	; One word per inverse.
  move.w	(a4,d5.w),d1	; d1=16384/(y2-y1).
  add.w	d5,d5	; Two words per jump adress.
  move.l	(a5,d5.w),a6	; a6=adress where to jump.
  sub.w	d0,d4	; d4=dx=x2-x1.
  muls.w	d1,d4
  lsl.l	#$2,d4	; d4=65536*(dx/dy).
  sub.w	d2,d6	; d6=dsrc_x=src_x2-src_x1.
  muls.w	d1,d6
  lsl.l	#$2,d6	; d6=65536*(dsrc_x/dy).
  sub.w	d3,d7	; d7=dsrc_y.
  muls.w	d1,d7
  lsl.l	#$2,d7	; d7=65536*(dsrc_y/dy).
  move.w	d4,d1	; d1=reg(dx/dy).
  move.w	d6,d4	; low(d4)=reg(dsrc_x/dy).
  swap.w	d4	; d4=reg(dsrc_x/dy) | int(dx/dy).
  move.w	d7,d6	; low(d6)=reg(dsrc_y/dy).
  swap.w	d6	; d6=reg(dsrc_y/dy) | int(dsrc_x/dy).
  swap.w	d7	; low(d7)=int(dsrc_y/dy).
  move.l	#$ffff,d5
  and.l	d5,d0	; d0=src_x_error | int(x).
  and.l	d5,d2	; d2=src_y_error | int(source_x).
  moveq.l	#$0,d5	; d5=x_error.
  jmp	(a6)

 rept	200
  move.w	d0,(a2)+	; Save xmin.
  move.w	d2,(a2)+	; Save source_x_min.
  move.w	d3,(a2)+	; Save source_y_min.
  add.w	d1,d5	; x_error=x_error+reg(dx/dy).
  addx.l	d4,d0	; src_x_error=src_x_error+reg(dsrc_x/dy),
  ; and in the lowerword: x=x+int(dx/dy)+eXtend.
  addx.l	d6,d2	; src_y_error=src_y_error+reg(dsrc_y/dy),
  ; and in lowerword: src_x=src_x+int(dsrc_x/dy)+eXtend.
  addx.w	d7,d3	; src_y=src_y+int(dsrc_y/dy)+eXtend.
 endr
.xmin_line_end:
  subq.w	#$6,a2	; Erase last point.
  bra	.xmin_one_line
.xmin_end:

; *************************************************************************
; * Ok, now we have all we want, it' s now time to draw the poly on the
; * screen. I proceed by drawing each h_line one after another. We do an
; * interpolation between src_x_min,src_y_min and src_x_max,src_y_max.

.draw_mapped:
  move.l	#.xmin_buffer,a1
  move.w	.nb_lines_2_pass,d0 ; Pass the invisible h_lines.
  move.w	d0,d1
  add.w	d0,d0
  add.w	d1,d0
  add.w	d0,d0
  add.w	d0,a1
  move.l	a0,-(sp)	; Save ramvideo adress.
  move.l	#.inverses,-(sp)
  move.l	a1,-(sp)
  move.l	#.endrouts_ad,-(sp)
  move.l	#.points_ad,-(sp)
  move.w	.nb_lines_2_draw,d0
  subq.w	#$1,d0
  move.w	d0,-(sp)
  move.l	.source,a1
  move.w	#128,a3
  
.draw_one_hline:
  move.w	d0,(sp)	; Store the counter.
  move.l	$a(sp),a0	; a0=xmin_buffer.
  move.w	(a0)+,d0	; d0=xmin.
  move.w	1198(a0),d1	; d1=xmax.
  move.w	d1,d2
  sub.w	d0,d2	; d2=dx=xmax-xmin.
  ble	.next_line
  moveq.l	#$f,d3
  move.w	d1,d4
  and.w	d3,d4	; d4=xmax mod(16).
  and.w	d0,d3	; d3=xmin mod(16).
  sub.w	d3,d0	; d0=xmin-xmin mod(16).
  move.l	$6(sp),a2	; a2=endrout_ad_table.
  add.w	d4,d4
  add.w	d4,d4
  move.l	(a2,d4.w),a6	; a6=adress of endrout to use.
  move.l	$2(sp),a2	; a2=table x->adress.
  add.w	d3,d3
  add.w	d3,d3
  move.l	(a2,d3.w),a5	; a5=adress of first point.
  sub.w	d0,d1	; d1=xmax-(xmin-xmin mod(16)).
  add.w	d1,d1
  add.w	d1,d1
  move.l	(a2,d1.w),a4	; a4=adress of last point.
  move.w	#$4ed6,(a4)	; Put "jmp (a6)" on last point.
  move.l	a4,-(sp)	; Save the adress where it has changed.
  moveq.l	#$0,d7	; up(d7)=error2=0 at the beginning.
  move.w	(a0)+,d7	; low(d7)=src_xmin.
  move.w	1198(a0),d6	; low(d6)=src_xmax.
  move.w	(a0)+,d4	; d4=src_ymin.
  move.w	1198(a0),d5	; d5=src_ymax.
  move.l	a0,$e(sp)	; Save the pos in xmin_buffer.
  move.l	$16(sp),a0	; a0=ramvideo adress.
  move.l	a0,a2
  add.w	#160,a2	; For next line.
  move.l	a2,$16(sp)	; Save next line adress.
  lsr.w	#$1,d0	; d0=(xmin-xmin mod(16))/2.
  add.w	d0,a0	; a0 points on good word.
  move.l	$12(sp),a2	; Inverses table.
  add.w	d2,d2
  move.w	(a2,d2.w),d2	; d2=16384/dx.
  sub.w	d7,d6	; d6=dsrc_x.
  muls.w	d2,d6
  lsl.l	#$2,d6	; d6=65536*(dsrc_x/dx).
  sub.w	d4,d5	; d5=dsrc_y.
  muls.w	d2,d5
  lsl.l	#$2,d5	; d5=65536*(dsrc_y/dx).
  lsl.w	#$7,d4	; d4=src_ymin*128.
  add.w	d4,d7	; low(d7)=pos in source image.
  move.w	d6,a2	; a2=reg(dsrc_x/dx).
  move.w	d5,d6
  swap.w	d6  	; d6= reg(dsrc_y/dx) | int(dsrc_x/dx).
  swap.w	d5
  lsl.w	#$7,d5	; low(d5)=int(dsrc_y/dx)*128.
  move.w	d5,a4	; a4=int(dsrc_y/dx)*128.
  moveq.l	#$0,d5	; d5=error1.
  moveq.l	#$0,d1	; Clear bitplanes.
  moveq.l	#$0,d2
  moveq.l	#$0,d3
  moveq.l	#$0,d4
  jmp	(a5)	; Go on first point.
  
.next_line:
  addq.w	#$4,a0	; Pass src_xmin and src_ymin.
  move.l	a0,$a(sp)	; Save the pos in xmin_buffer.
  move.l	$12(sp),a0	; a0=ramvideo adress.
  add.w	#160,a0	; For next line.
  move.l	a0,$12(sp)	; Save next line adress.
  move.w	(sp),d0	; Load the counter.
  dbra	d0,.draw_one_hline
  add.w	#$16,sp	; Fuck the stored tiddies.
.the_end:
  movem.l	(sp)+,d0-a6
  rts

; *************************************************************************
; * We have to use different endroutines in order to gain speed, cos the
; * ending bitplanes must be rotated and they must be "or.w".

mapmac1:	MACRO
  move.b	(a1,d7.w),d0
;  add.b	d0,d0
;  addx.w	d4,d4
;  add.b	d0,d0
;  addx.w	d3,d3
;  add.b	d0,d0
;  addx.w	d2,d2
  add.b	d0,d0
  addx.w	d1,d1
  	ENDM

mapmac2:	MACRO
  and.w	d0,d1
;  and.w	d0,d2
;  and.w	d0,d3
;  and.w	d0,d4
	ENDM

mapmac3:	MACRO
  or.w	d1,(a0)+
;  or.w	d2,(a0)+
;  or.w	d3,(a0)+
;  or.w	d4,(a0)+
  	ENDM

mapmac4:	MACRO
  move.l	(sp)+,a4	; Adress where we put the "jmp (a6)".
  move.w	#$1031,(a4)	; Restore initial code.
  move.w	(sp),d0	; Load counter.
  dbra	d0,.draw_one_hline
  add.w	#$16,sp	; Fuck the stored tiddies.
  movem.l	(sp)+,d0-a6	; The end.
  rts
	ENDM


.endrout_0:
  mapmac1		; Convert last point.
  ror.w	#$1,d1	; Rotate the bitplanes.
;  ror.w	#$1,d2
;  ror.w	#$1,d3
;  ror.w	#$1,d4
  move.w	#$8000,d0	; For destroying unusefull bits.
  mapmac2		; Fuck them.
  mapmac3		; Print last word.
  mapmac4

.endrout_1:
  mapmac1		; Convert last point.
  ror.w	#$2,d1	; Rotate the bitplanes.
;  ror.w	#$2,d2
;  ror.w	#$2,d3
;  ror.w	#$2,d4
  move.w	#$c000,d0	; For destroying unusefull bits.
  mapmac2		; Fuck them.
  mapmac3		; Print last word.
  mapmac4

.endrout_2:
  mapmac1		; Convert last point.
  ror.w	#$3,d1	; Rotate the bitplanes.
;  ror.w	#$3,d2
;  ror.w	#$3,d3
;  ror.w	#$3,d4
  move.w	#$e000,d0	; For destroying unusefull bits.
  mapmac2		; Fuck them.
  mapmac3		; Print last word.
  mapmac4

.endrout_3:
  mapmac1		; Convert last point.
  ror.w	#$4,d1	; Rotate the bitplanes.
;  ror.w	#$4,d2
;  ror.w	#$4,d3
;  ror.w	#$4,d4
  move.w	#$f000,d0	; For destroying unusefull bits.
  mapmac2		; Fuck them.
  mapmac3		; Print last word.
  mapmac4

.endrout_4:
  mapmac1		; Convert last point.
  ror.w	#$5,d1	; Rotate the bitplanes.
;  ror.w	#$5,d2
;  ror.w	#$5,d3
;  ror.w	#$5,d4
  move.w	#$f800,d0	; For destroying unusefull bits.
  mapmac2		; Fuck them.
  mapmac3		; Print last word.
  mapmac4

.endrout_5:
  mapmac1		; Convert last point.
  ror.w	#$6,d1	; Rotate the bitplanes.
;  ror.w	#$6,d2
;  ror.w	#$6,d3
;  ror.w	#$6,d4
  move.w	#$fc00,d0	; For destroying unusefull bits.
  mapmac2		; Fuck them.
  mapmac3		; Print last word.
  mapmac4

.endrout_6:
  mapmac1		; Convert last point.
  ror.w	#$7,d1	; Rotate the bitplanes.
;  ror.w	#$7,d2
;  ror.w	#$7,d3
;  ror.w	#$7,d4
  move.w	#$fe00,d0	; For destroying unusefull bits.
  mapmac2		; Fuck them.
  mapmac3		; Print last word.
  mapmac4

.endrout_7:
  mapmac1		; Convert last point.
  lsl.w	#$8,d1	; Rotate the bitplanes.
;  lsl.w	#$8,d2
;  lsl.w	#$8,d3
;  lsl.w	#$8,d4
  mapmac3		; Print last word.
  mapmac4

.endrout_8:
  mapmac1		; Convert last point.
  lsl.w	#$7,d1	; Rotate the bitplanes.
;  lsl.w	#$7,d2
;  lsl.w	#$7,d3
;  lsl.w	#$7,d4
  mapmac3		; Print last word.
  mapmac4

.endrout_9:
  mapmac1		; Convert last point.
  lsl.w	#$6,d1	; Rotate the bitplanes.
;  lsl.w	#$6,d2
;  lsl.w	#$6,d3
;  lsl.w	#$6,d4
  mapmac3		; Print last word.
  mapmac4

.endrout_a:
  mapmac1		; Convert last point.
  lsl.w	#$5,d1	; Rotate the bitplanes.
;  lsl.w	#$5,d2
;  lsl.w	#$5,d3
;  lsl.w	#$5,d4
  mapmac3		; Print last word.
  mapmac4

.endrout_b:
  mapmac1		; Convert last point.
  lsl.w	#$4,d1	; Rotate the bitplanes.
;  lsl.w	#$4,d2
;  lsl.w	#$4,d3
;  lsl.w	#$4,d4
  mapmac3		; Print last word.
  mapmac4

.endrout_c:
  mapmac1		; Convert last point.
  lsl.w	#$3,d1	; Rotate the bitplanes.
;  lsl.w	#$3,d2
;  lsl.w	#$3,d3
;  lsl.w	#$3,d4
  mapmac3		; Print last word.
  mapmac4

.endrout_d:
  mapmac1		; Convert last point.
  lsl.w	#$2,d1	; Rotate the bitplanes.
;  lsl.w	#$2,d2
;  lsl.w	#$2,d3
;  lsl.w	#$2,d4
  mapmac3		; Print last word.
  mapmac4

.endrout_e:
  mapmac1		; Convert last point.
  add.w	d1,d1	; Rotate the bitplanes.
;  add.w	d2,d2
;  add.w	d3,d3
;  add.w	d4,d4
  mapmac3		; Print last word.
  mapmac4

.endrout_f:
  mapmac1		; Convert last point.
  mapmac3
  mapmac4

; *************************************************************************
; * The core of the shading poly routine... Very repetitive, cos I don' t
; * like the dbra and I LOOOOooove Speed....

mapmac5:	MACRO
 rept	16
  move.b	(a1,d7.w),d0	; Convert point.
;  add.b	d0,d0
;  addx.w	d4,d4
;  add.b	d0,d0
;  addx.w	d3,d3
;  add.b	d0,d0
;  addx.w	d2,d2
  add.b	d0,d0
  addx.w	d1,d1
  add.w	a2,d5	; error1=error1+reg(dsrc_x/dx).
  addx.l	d6,d7	; error2=error2+reg(dsrc_y/dx),
  ; and in the lowerword position=position+int(dsrc_x/dx)+eXtend.
  dc.w	$6402	; Pass next instruction if CarryClear.
  add.w	a3,d7	; Position=pos+128*eXtend.
  add.w	a4,d7	; position=pos+128*int(dsrc_y/dx).
 endr
	ENDM

.core:
  mapmac5		; 16 pixies.
  or.w	d1,(a0)	; Print first bitlanes.
  addq.w	#$8,a0
;  or.w	d2,(a0)+
;  or.w	d3,(a0)+
;  or.w	d4,(a0)+

.core_2:
  mapmac5		; Do 16 pixies.
  move.w	d1,(a0)	; Store planes.
  addq.w	#$8,a0
  mapmac5
  move.w	d1,(a0)
  addq.w	#$8,a0
  mapmac5
  move.w	d1,(a0)
  addq.w	#$8,a0
  mapmac5
  move.w	d1,(a0)
  addq.w	#$8,a0
  mapmac5
  move.w	d1,(a0)
  addq.w	#$8,a0
  mapmac5
  move.w	d1,(a0)
  addq.w	#$8,a0
  mapmac5
  move.w	d1,(a0)
  addq.w	#$8,a0
  mapmac5
  move.w	d1,(a0)
  addq.w	#$8,a0
  mapmac5
  move.w	d1,(a0)
  addq.w	#$8,a0
  mapmac5
  move.w	d1,(a0)
  addq.w	#$8,a0
  mapmac5
  move.w	d1,(a0)
  addq.w	#$8,a0
  mapmac5
  move.w	d1,(a0)
  addq.w	#$8,a0
  mapmac5
  move.w	d1,(a0)
  addq.w	#$8,a0
  mapmac5
  move.w	d1,(a0)
  addq.w	#$8,a0
  mapmac5
  move.w	d1,(a0)
  addq.w	#$8,a0
 

; *************************************************************************
  Section DATA
  
.y_table:		; Table for y->y*160 conversions.
N set 0
 rept	200
  dc.w	N  
N set N+160
 endr
 
.inverses:		; Table n->16384/n.
  incbin	'e:\demos\positivi.ty\passion\mapping\inverses.xxx'

.xmax_ad:		; Table of adresses for the jump.
N set 14
 rept	300
  dc.l	.xmax_line_end-N
N set N+14
 endr

.xmin_ad:		; The same for the xmin tracking.
N set 14
 rept	300
  dc.l	.xmin_line_end-N
N set N+14
 endr

.points_ad:		; Convert x->adress in the "core".
N set 0		; For the first 16 pixies.
 rept	16
  dc.l	.core+N
N set N+18
 endr
N set 0		; For the next ones.
 rept	15	; 240 points.
  dc.l	.core_2+000+N,.core_2+018+N
  dc.l	.core_2+036+N,.core_2+054+N
  dc.l	.core_2+072+N,.core_2+090+N
  dc.l	.core_2+108+N,.core_2+126+N
  dc.l	.core_2+144+N,.core_2+162+N
  dc.l	.core_2+180+N,.core_2+198+N
  dc.l	.core_2+216+N,.core_2+234+N
  dc.l	.core_2+252+N,.core_2+270+N
N set N+288+4
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
  ds.w	3*200
.xmax_buffer:
  ds.w	3*200
.source:
  ds.l	1
.ymin:
  ds.w	1
.ymax:
  ds.w	1