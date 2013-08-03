; *************************************************************************
; ***          Routine which pre-zoom and pre-shade an image.           ***
; ***                        Dracula / Positivity.                      ***
; *************************************************************************
; Parameters:	a0.l = adress for the storage of the images.
;	a1.l = adress of the source image.
;	a2.l = adress where to put the img_adresses.
; * To shade an image, the easiest and fastest ( I think ) method consist
; in having the image converted in a linear mode. ( 1 byte=1 pixie. )
; That' s why the first part of the precalcs consists in transforming the
; image in linear mode.

  movem.l	d0-a6,-(sp)	; I can't believe it.

  move.l	a1,-(sp)	; Store the adress of initial image.

  move.l	#.buffer,a3	; Buffer to put the linear image.
.img_2_linear:		; Convert in 1 byte=1 pixie mode.
  move.w	#99,d0  	; 100 lines.
.one_line_2_linear:
  movem.w	(a1)+,d1-d4
 rept	16	; 16 pixies.
  moveq.l	#$0,d5
  add.w	d4,d4	; Put the left bit in X.
  addx.w	d5,d5	; Rotate d5 left and put X in lower bit.
  add.w	d3,d3	; The same for bpl2.
  addx.w	d5,d5	; So, so...
  add.w	d2,d2
  addx.w	d5,d5	; Bpl3.
  add.w	d1,d1
  addx.w	d5,d5	; Bpl4.
  move.b	d5,(a3)+	; Store this pixie.
 endr

  movem.w	(a1)+,d1-d4
 rept	16	; 16 pixies.
  moveq.l	#$0,d5
  add.w	d4,d4	; Put the left bit in X.
  addx.w	d5,d5	; Rotate d5 left and put X in lower bit.
  add.w	d3,d3	; The same for bpl2.
  addx.w	d5,d5	; So, so...
  add.w	d2,d2
  addx.w	d5,d5	; Bpl3.
  add.w	d1,d1
  addx.w	d5,d5	; Bpl4.
  move.b	d5,(a3)+	; Store this pixie.
 endr

  movem.w	(a1)+,d1-d4
 rept	16	; 16 pixies.
  moveq.l	#$0,d5
  add.w	d4,d4	; Put the left bit in X.
  addx.w	d5,d5	; Rotate d5 left and put X in lower bit.
  add.w	d3,d3	; The same for bpl2.
  addx.w	d5,d5	; So, so...
  add.w	d2,d2
  addx.w	d5,d5	; Bpl3.
  add.w	d1,d1
  addx.w	d5,d5	; Bpl4.
  move.b	d5,(a3)+	; Store this pixie.
 endr

  movem.w	(a1)+,d1-d4
 rept	16	; 16 pixies.
  moveq.l	#$0,d5
  add.w	d4,d4	; Put the left bit in X.
  addx.w	d5,d5	; Rotate d5 left and put X in lower bit.
  add.w	d3,d3	; The same for bpl2.
  addx.w	d5,d5	; So, so...
  add.w	d2,d2
  addx.w	d5,d5	; Bpl3.
  add.w	d1,d1
  addx.w	d5,d5	; Bpl4.
  move.b	d5,(a3)+	; Store this pixie.
 endr

  movem.w	(a1)+,d1-d4
 rept	16	; 16 pixies.
  moveq.l	#$0,d5
  add.w	d4,d4	; Put the left bit in X.
  addx.w	d5,d5	; Rotate d5 left and put X in lower bit.
  add.w	d3,d3	; The same for bpl2.
  addx.w	d5,d5	; So, so...
  add.w	d2,d2
  addx.w	d5,d5	; Bpl3.
  add.w	d1,d1
  addx.w	d5,d5	; Bpl4.
  move.b	d5,(a3)+	; Store this pixie.
 endr
 
  dbra	d0,.one_line_2_linear

; *************************************************************************
; Second part of the precalcs.

  move.l	#.buffer,a1	; Buffer to put the linear image.
  move.l	#.shading,a3
  moveq.l	#$2,d0	; Size of the first image.
.one_zoom:
  move.l	a0,(a2)+	; Save the adress of the image.
  move.l	d0,a4	; Nb of lines to copy.
  move.l	#$6400,d2	; d2=100*256.
  divs.w	d0,d2	; d2=nb of lines between 2 line copy.
  and.l	#$ffff,d2	; Don' t care about the remainder.
  lsl.l	#$8,d2	; d2=((100*256)/d0)*256.
  moveq.l	#$0,d3	; d3 points on the line to copy.
.zoom_one_line:
  move.l	a1,a5	; a5 will point on the good line.
  swap.w	d3	; lowerword(d3)=line nb.
  move.w	d3,d4	; d4=d3 multiplied by 80.
  add.w	d4,d4
  add.w	d4,d4
  add.w	d3,d4
  swap.w	d3	; d3 back to real.
  lsl.w	#$4,d4
  add.w	d4,a5	; a5 points on the good line.
.copy_line:
  moveq.l	#$0,d1

  moveq.l	#$0,d7
  moveq.l	#$0,d6
  moveq.l	#$0,d5
  moveq.l	#$0,d4
 rept	16	; 16 pixies in four bitplanes.
  move.b	(a5)+,d1	; Pixel value.
  move.b	(a3,d1.w),d1	; Shade this pixie.
  lsr.w	#$1,d1	; Put the right bit in X.
  addx.w	d4,d4	; Rotate d7 left and put X in lower bit.
  lsr.w	#$1,d1
  addx.w	d5,d5	; Same for bpl2.
  lsr.w	#$1,d1
  addx.w	d6,d6	; Bpl3.
  lsr.w	#$1,d1
  addx.w	d7,d7	; Bpl4.
 endr 
  movem.w	d4-7,(a0)	; Save the shaded line.
  addq.w	#$8,a0

  moveq.l	#$0,d7
  moveq.l	#$0,d6
  moveq.l	#$0,d5
  moveq.l	#$0,d4
 rept	16	; 16 pixies in four bitplanes.
  move.b	(a5)+,d1	; Pixel value.
  move.b	(a3,d1.w),d1	; Shade this pixie.
  lsr.w	#$1,d1	; Put the right bit in X.
  addx.w	d4,d4	; Rotate d7 left and put X in lower bit.
  lsr.w	#$1,d1
  addx.w	d5,d5	; Same for bpl2.
  lsr.w	#$1,d1
  addx.w	d6,d6	; Bpl3.
  lsr.w	#$1,d1
  addx.w	d7,d7	; Bpl4.
 endr 
  movem.w	d4-7,(a0)	; Save the shaded line.
  addq.w	#$8,a0

  moveq.l	#$0,d7
  moveq.l	#$0,d6
  moveq.l	#$0,d5
  moveq.l	#$0,d4
 rept	16	; 16 pixies in four bitplanes.
  move.b	(a5)+,d1	; Pixel value.
  move.b	(a3,d1.w),d1	; Shade this pixie.
  lsr.w	#$1,d1	; Put the right bit in X.
  addx.w	d4,d4	; Rotate d7 left and put X in lower bit.
  lsr.w	#$1,d1
  addx.w	d5,d5	; Same for bpl2.
  lsr.w	#$1,d1
  addx.w	d6,d6	; Bpl3.
  lsr.w	#$1,d1
  addx.w	d7,d7	; Bpl4.
 endr 
  movem.w	d4-7,(a0)	; Save the shaded line.
  addq.w	#$8,a0

  moveq.l	#$0,d7
  moveq.l	#$0,d6
  moveq.l	#$0,d5
  moveq.l	#$0,d4
 rept	16	; 16 pixies in four bitplanes.
  move.b	(a5)+,d1	; Pixel value.
  move.b	(a3,d1.w),d1	; Shade this pixie.
  lsr.w	#$1,d1	; Put the right bit in X.
  addx.w	d4,d4	; Rotate d7 left and put X in lower bit.
  lsr.w	#$1,d1
  addx.w	d5,d5	; Same for bpl2.
  lsr.w	#$1,d1
  addx.w	d6,d6	; Bpl3.
  lsr.w	#$1,d1
  addx.w	d7,d7	; Bpl4.
 endr 
  movem.w	d4-7,(a0)	; Save the shaded line.
  addq.w	#$8,a0

  moveq.l	#$0,d7
  moveq.l	#$0,d6
  moveq.l	#$0,d5
  moveq.l	#$0,d4
 rept	16	; 16 pixies in four bitplanes.
  move.b	(a5)+,d1	; Pixel value.
  move.b	(a3,d1.w),d1	; Shade this pixie.
  lsr.w	#$1,d1	; Put the right bit in X.
  addx.w	d4,d4	; Rotate d7 left and put X in lower bit.
  lsr.w	#$1,d1
  addx.w	d5,d5	; Same for bpl2.
  lsr.w	#$1,d1
  addx.w	d6,d6	; Bpl3.
  lsr.w	#$1,d1
  addx.w	d7,d7	; Bpl4.
 endr 
  movem.w	d4-7,(a0)	; Save the shaded line.
  addq.w	#$8,a0
  
.line_copied:
  add.l	d2,d3	; Next line.
  subq.w	#$1,a4	; Is this the last line?
  cmp.w	#$0,a4
  bne	.zoom_one_line
  add.w	#$10,a3	; Next shading table.
  addq.l	#$2,d0	; Next size for the image.
  cmp.w	#$64,d0
  bne	.one_zoom	; Last zoom?

.last_image:		; Don' t forget it.
  move.l	(sp)+,(a2)

  movem.l	(sp)+,d0-a6
  rts  

.shading:
  dc.b	$0,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1
  dc.b	$0,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1
  dc.b	$0,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1
  dc.b	$0,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1
  dc.b	$0,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$2,$2,$2
  dc.b	$0,$1,$1,$1,$1,$1,$1,$1,$1,$1,$2,$2,$2,$2,$2,$2
  dc.b	$0,$1,$1,$1,$1,$1,$1,$1,$1,$2,$2,$2,$2,$2,$2,$2
  dc.b	$0,$1,$1,$1,$1,$1,$1,$2,$2,$2,$2,$2,$2,$2,$3,$3
  dc.b	$0,$1,$1,$1,$1,$1,$1,$2,$2,$2,$2,$2,$2,$3,$3,$3
  dc.b	$0,$1,$1,$1,$1,$1,$2,$2,$2,$2,$2,$3,$3,$3,$3,$3

  dc.b	$0,$1,$1,$1,$1,$2,$2,$2,$2,$2,$3,$3,$3,$3,$3,$4
  dc.b	$0,$1,$1,$1,$1,$2,$2,$2,$2,$3,$3,$3,$3,$3,$4,$4
  dc.b	$0,$1,$1,$1,$1,$2,$2,$2,$2,$3,$3,$3,$3,$4,$4,$4
  dc.b	$0,$1,$1,$1,$2,$2,$2,$2,$3,$3,$3,$3,$4,$4,$4,$4
  dc.b	$0,$1,$1,$1,$2,$2,$2,$3,$3,$3,$3,$4,$4,$4,$5,$5
  dc.b	$0,$1,$1,$1,$2,$2,$2,$3,$3,$3,$4,$4,$4,$5,$5,$5
  dc.b	$0,$1,$1,$1,$2,$2,$2,$3,$3,$3,$4,$4,$4,$5,$5,$5
  dc.b	$0,$1,$1,$2,$2,$2,$3,$3,$3,$4,$4,$4,$5,$5,$5,$6
  dc.b	$0,$1,$1,$2,$2,$2,$3,$3,$3,$4,$4,$5,$5,$5,$6,$6
  dc.b	$0,$1,$1,$2,$2,$2,$3,$3,$4,$4,$4,$5,$5,$6,$6,$6

  dc.b	$0,$1,$1,$2,$2,$3,$3,$3,$4,$4,$5,$5,$5,$6,$6,$7
  dc.b	$0,$1,$1,$2,$2,$3,$3,$4,$4,$4,$5,$5,$6,$6,$7,$7
  dc.b	$0,$1,$1,$2,$2,$3,$3,$4,$4,$5,$5,$5,$6,$6,$7,$7
  dc.b	$0,$1,$1,$2,$2,$3,$3,$4,$4,$5,$5,$6,$6,$7,$7,$7
  dc.b	$0,$1,$1,$2,$2,$3,$3,$4,$4,$5,$5,$6,$6,$7,$7,$8
  dc.b	$0,$1,$2,$2,$3,$3,$4,$4,$5,$5,$6,$6,$7,$7,$8,$8
  dc.b	$0,$1,$2,$2,$3,$3,$4,$4,$5,$5,$6,$6,$7,$7,$8,$8
  dc.b	$0,$1,$2,$2,$3,$3,$4,$4,$5,$5,$6,$7,$7,$8,$8,$9
  dc.b	$0,$1,$2,$2,$3,$3,$4,$4,$5,$6,$6,$7,$7,$8,$9,$9
  dc.b	$0,$1,$2,$2,$3,$3,$4,$5,$5,$6,$6,$7,$7,$8,$9,$9

  dc.b	$0,$1,$2,$2,$3,$4,$4,$5,$5,$6,$7,$7,$8,$9,$9,$a
  dc.b	$0,$1,$2,$2,$3,$4,$4,$5,$5,$6,$7,$7,$8,$9,$9,$a
  dc.b	$0,$1,$2,$2,$3,$4,$4,$5,$6,$6,$7,$8,$8,$9,$a,$a
  dc.b	$0,$1,$2,$2,$3,$4,$4,$5,$6,$7,$7,$8,$8,$9,$a,$a
  dc.b	$0,$1,$2,$3,$3,$4,$5,$5,$6,$7,$7,$8,$9,$a,$a,$b
  dc.b	$0,$1,$2,$3,$3,$4,$5,$5,$6,$7,$8,$8,$9,$a,$b,$b
  dc.b	$0,$1,$2,$3,$3,$4,$5,$6,$6,$7,$8,$9,$9,$a,$b,$b
  dc.b	$0,$1,$2,$3,$3,$4,$5,$6,$6,$7,$8,$9,$9,$a,$b,$c
  dc.b	$0,$1,$2,$3,$4,$4,$5,$6,$7,$7,$8,$9,$a,$b,$b,$c
  dc.b	$0,$1,$2,$3,$4,$4,$5,$6,$7,$8,$8,$9,$a,$b,$c,$c

  dc.b	$0,$1,$2,$3,$4,$5,$5,$6,$7,$8,$9,$9,$a,$b,$c,$d
  dc.b	$0,$1,$2,$3,$4,$5,$5,$6,$7,$8,$9,$a,$a,$b,$c,$d
  dc.b	$0,$1,$2,$3,$4,$5,$6,$6,$7,$8,$9,$a,$b,$c,$d,$d
  dc.b	$0,$1,$2,$3,$4,$5,$6,$7,$7,$8,$9,$a,$b,$c,$d,$d
  dc.b	$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$9,$a,$b,$c,$d,$e
  dc.b	$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$a,$b,$b,$c,$d,$e
  dc.b	$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$a,$b,$c,$d,$e,$e
  dc.b	$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$a,$b,$c,$d,$e,$f
  dc.b	$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$a,$b,$c,$d,$e,$f
  dc.b	$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$a,$b,$c,$d,$e,$f

; *************************************************************************
  Section BSS
  
.buffer:		; Buffer for the linear image.
  ds.b	8000
  
