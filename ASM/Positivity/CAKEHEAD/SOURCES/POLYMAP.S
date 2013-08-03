; *************************************************************************
; ***         Routine which draws a mapped, y rotated polygon.          ***
; ***                        Dracula / Positivity.                      ***
; *************************************************************************
;
; Parameters:	a0.l = adress of the video ram.
;	a1.l = adress of the imgx_adresses.
;	d0.w = x1.
;	d1.w = x2.
;	d2.w = y1.
;	d3.w = y2.


  movem.l	d0-a6,-(sp)
  tst.w	d1
  bmi.s	.poly_invisible
  cmp.w	#$13f,d0
  ble.s	.poly_x_clipping
  
.poly_invisible:	; I' m the invisible poly....
  movem.l	(sp)+,d0-a6
  rts

.poly_x_clipping:	; Seems part of the poly is visible.
  moveq.l	#$0,d6	; d6 will be the number of x to pass.
  tst.w	d0	; Is there left clipping?
  bge.s	.no_left_clip
.left_clipping:		; Poly hidden on left, so we will begin
  sub.w	d0,d6	; to draw after the border.
  add.w	d6,d6	; Nb of heights and x_src to pass*2.
  bra.s	.no_right_clip	; Never have left+right clipping.

.no_left_clip:
  cmp.w	#$13f,d1	; Is there right clipping?
  ble.s	.no_right_clip
.right_clipping:	; Poly hidden on left, so we will not
  move.w	#$13f,d7  	; draw the lasts height and x_src.
  sub.w	d0,d7	; Nb of height and x_src to calculate.
  ble.s	.poly_invisible	; If dx=0, don' t draw.
  bra.s	.clipping_ok

.no_right_clip:		; If there's no right clipping, the
  move.w	d1,d7	; nb of height and x_src to calculate
  sub.w	d0,d7	; is dx=d1-d0.
  ble.s	.poly_invisible	; Don' t draw if dx=<0.
  
.clipping_ok:		; Clipping is done.
  sub.w	d0,d1	; d1=dx.
  addq.w	#$1,d1	; Nb of lines.
  move.l	#.xsource,a2	; We will stock the x_sources in here.
  move.l	#$5000,d4	; d4=80*256.
  divs.w	d1,d4	; d4=80/(dx+1)=nb of source lines to pass
  ext.l	d4	; between 2 dest lines, it' s a real, so
  ror.l	#$8,d4	; represent it with regular part in the
	; upper word, and part to save in the lower word.
  move.l	#.end_xsrc_calc,a3 ; We will jump in (a3).
  move.w	d7,d5	; d5=nb of x_src to calc.
  addq.w	#$1,d5
  add.w	d5,d5	; 4 bytes per calculation.
  add.w	d5,d5
  sub.w	d5,a3	; a3 points on the first calc to do.
  moveq.l	#$0,d5	; d5=first x_src.

  cmp.w	#$50,d1
  ble.s	.go_xsrc_calc
  addx.l	d4,d5	; Next x_src.
.go_xsrc_calc:  
  jmp	(a3)	; Go!

  
 rept	160	; Here are the calculations.
  move.w	d5,(a2)+	; Stock the x_src.
  addx.l	d4,d5	; Next x_src.
 endr
.end_xsrc_calc:		; Finished for this.
  
  move.l	#.heights,a2	; Do the same for the heights.
  sub.w	d2,d3	; d3=dy.
  bmi	.dyneg	; Two different routines, depending
  	; on the sign of dy.

.dypos:		; First case, dy is positive.
  addq.w	#$1,d3	; d3=nb of v_lines.
  lsl.w	#$8,d3	; d3=(dy+1)*256.
  ext.l	d3
  divs.w	d1,d3	; d3=(dy+1)/(dx+1)=increment on y for
  ext.l	d3	; each v_line, and like before it' s
  ror.l	#$8,d3	; represented as a real.
  move.l	#.end_dypos_calc,a3 ; We will jump in (a3).
  move.w	d7,d5	; d5=number of heights to calc.
  addq.w	#$1,d5
  add.w	d5,d5	; 4 bytes per calculation.
  add.w	d5,d5
  sub.w	d5,a3	; a3 points on the first calc to do.
  ext.l	d2	; d2 is the current height.
  add.l	#$80000000,d2
  jmp	(a3)	; Go!
  
 rept	160	; Here are the calculations.
  move.w	d2,(a2)+	; Stock the height.
  addx.l	d3,d2	; Next height.
 endr
.end_dypos_calc:	; Finished for this.
  bra	.lets_go

.dyneg:		; Second case, dy is negative.
  neg.w	d3	; Approximately the same, but we must
  addq.w	#$1,d3	; substract the y_increment.
  lsl.w	#$8,d3	; d3=(dy+1)*256.
  ext.l	d3
  divs.w	d1,d3	; d3=(dy+1)/(dx+1)=increment on y for
  ext.l	d3	; each v_line, and like before it' s
  ror.l	#$8,d3	; represented as a real.
  move.l	#.end_dyneg_calc,a3 ; We will jump in (a3).
  move.w	d7,d5	; d5=number of heights to calc.
  addq.w	#$1,d5
  add.w	d5,d5	; 4 bytes per calculation.
  add.w	d5,d5
  sub.w	d5,a3	; a3 points on the first calc to do.
  ext.l	d2	; d2 is the current height.
  jmp	(a3)	; Go!
  
 rept	160	; Here are the calculations.
  move.w	d2,(a2)+	; Stock the height.
  subx.l	d3,d2	; Next height.
 endr
.end_dyneg_calc:	; Finished for this.

.lets_go:		; Now sumthing will appear on screen.

  move.l	#.heights,a2
  move.l	#.xsource,a3
  add.w	d6,a2	; Pass the clipped_left v_lines.
  add.w	d6,a3

  lsr.w	#$1,d6
  sub.w	d6,d7	; Don' t draw the first v_lines.
  add.w 	d6,d0	; Begin to draw after the left clipping.
  
  move.l	#.x_conv,a4	; Conversion table. ( x->pattern+offset.)
  add.w	d0,d0
  add.w	d0,d0
  add.w	d0,a4	; a4 points on the first x_dest.
  lsr.w	#$2,d0
  
.init_blitter:
  move.w	#$2,$ffff8a20.w	; Increment on x source.
  move.w	#$22,$ffff8a22.w ; 40 bytes/line for the source.
  move.w	#$2,$ffff8a2e.w	; Increment on x dest.
  move.w	#$9a,$ffff8a30.w ; 160 bytes/line for the dest.
  move.w	#$4,$ffff8a36.w	; Four words per line.
  move.b	#%10,$ffff8a3a.w ; No halftoning. (Source only.)
  move.b	#$03,$ffff8a3b.w ; Source only.
  
.one_line:
  move.w	d0,d1	; d0=d1=x of dest.
  and.w	#$f,d1	; d1=x_dest mod(16).
  move.w	(a4)+,d2	; Mask.
  move.w	d2,$ffff8a28.w
  move.w	d2,$ffff8a2a.w
  move.w	d2,$ffff8a2c.w
  move.l	a0,a5	; Add will point on dest adress.
  add.w	(a4)+,a5	; Add the offset for the x.
  move.w	(a2)+,d2	; d2=height.
;  cmp.w	#49,d2	; d2>100?
;  bgt.s	.z_clipping
  moveq.l	#99,d3
  sub.w	d2,d3	; First line where to copy.
  move.w	d3,d4	; Multiply by 160.
  add.w	d3,d3
  add.w	d3,d3
  add.w	d4,d3
  lsl.w	#$5,d3
  add.w	d3,a5	; a5 points on the good word.
  move.l	a5,$ffff8a32.w	; Dest adress.
  add.w	d2,d2	; d2=nb of lines to copy.  
  move.w	d2,$ffff8a38.w	; Nb of lines to copy.
  add.w	d2,d2
  move.l	(a1,d2.w),a5	; a5 point on the src image.
  move.w	(a3)+,d2	; d2=x_src.
  move.w	d2,d3
  and.w	#$f,d3	; d3=x_src mod(16).
  sub.w	d3,d2	; d2=x_src-x_src mod(16).
  lsr.w	#$1,d2	; d2=offset for x_src.
  add.w	d2,a5
  move.l	a5,$ffff8a24.w	; Source adress.
.skew:
  sub.w	d3,d1	; d1=x_dest mod(16)-_src mod(16).
  bpl.s	.skew_ok

  and.w	#$f,d1
  bset.l	#$7,d1	; Force eXtra source read.
  move.w	#$20,$ffff8a22.w ; 40 bytes/line for the source.
  move.b	d1,$ffff8a3d.w	; Skew register.
  move.b	#$c0,$ffff8a3c.w ; Launch the blitter.
  move.w	#$22,$ffff8a22.w ; 40 bytes/line for the source.

  addq.l	#$1,d0	; Next v_line.
  dbra	d7,.one_line
  
  movem.l	(sp)+,d0-a6
  rts
  
.skew_ok:
  move.b	d1,$ffff8a3d.w	; Skew register.
  move.b	#$c0,$ffff8a3c.w ; Launch the blitter.

  addq.l	#$1,d0	; Next v_line.
  dbra	d7,.one_line
  
  movem.l	(sp)+,d0-a6
  rts

;.z_clipping:		; Size too big.
;  addq.w	#$1,d0	; Next x_dest.
;  addq.w	#$2,a3	; Next x_src.
;  addq.w	#$4,a5	; Bpl 3.
;  move.w	$ffff8a28.w,d2
;N set 50*160
; rept	98
;  or.w	d2,N(a5)
;N set N+160
; endr  

;  dbra	d7,.one_line
;  movem.l	(sp)+,d0-a6
;  rts

.x_conv:
N set 0
 rept	20
  dc.w	$8000,N,$4000,N,$2000,N,$1000,N
  dc.w	$0800,N,$0400,N,$0200,N,$0100,N
  dc.w	$0080,N,$0040,N,$0020,N,$0010,N
  dc.w	$0008,N,$0004,N,$0002,N,$0001,N
N set N+8
 endr

; **********************************************************************
  Section BSS

.heights:		; Table to store the calculated y.
  ds.w	200

.xsource:
  ds.w	200

