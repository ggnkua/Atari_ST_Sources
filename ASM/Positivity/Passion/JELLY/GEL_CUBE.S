; *************************************************************************
; *****              Routine which draws a jelly cube.                *****
; *************************************************************************
; The jelly cube is not clipped. It is always x centered.
; *************************************************************************
; Parameters:	a3.l = adress of ramvideo.
;	d7.l = adress of source image. (linear image)
;	a4.l = adress of zoom routines adress table.
;	d4.w = y1.
;	d5.w = y2.
;	d6.w = jelly_coefficient. (Between -8 ~ 16)

  movem.l	d0-a6,-(sp)

  sub.w	d4,d5	; d5=y2-y1=dy.
  move.l	#.y_table,a5	; Table y->adress, with x centering...
  add.w	d4,d4	; One word per y.
  add.w	(a5,d4.w),a3	; a3 points on the good (x;y).
  move.l	#.edges,a5	; Table of edges.
  addq.w	#8,d6	; This table begins at offset 0.
  mulu.w	#96*2,d6	; d6 is the offset to the good edge.
  add.w	d6,a5	; a5 points on the edge to use.
  move.w	d5,.counter
  addq.w	#$1,d5	; d5=y2-y1+1=dy.
  mulu.w	#682,d5	; d5=dy*65536/96.
  move.w	#$8000,d6	; d6=error.
  move.l	#.return,a2	; For the return.

.one_line:
  add.w	d5,d6	; error=error+(dy*65536/96).
  bcc.s	.pass_one_line
.draw_one_line:
  move.l	a3,a1	; Ramvideo adress.
  move.l	d7,a0	; Source image.
  move.w	(a5)+,d0	; d0 is the edge*4.
  move.l	(a4,d0.w),a6	; a6=adress of the zoomrout to use.
  add.w	#$a0,a3	; Next line.
  add.l	#96,d7	; Next source line.
  jmp	(a6)	; Print the line.
.return:
  sub.w	#$1,.counter	; We have done one line.
  bpl.s	.one_line
  movem.l	(sp)+,d0-a6
  rts

.pass_one_line:
  addq.w	#$2,a5	; Next edge.
  add.l	#96,d7	; Next source line.
  bra.s	.one_line

.edges:
  incbin	'e:\demos\positivi.ty\passion\jelly\gel_edge.xxx'

.y_table:		; Table y->adress.
N set 56		; For x centering.
 rept	200
  dc.w	N
N set N+160		; Next line.
 endr

.counter:
  ds.w	1
