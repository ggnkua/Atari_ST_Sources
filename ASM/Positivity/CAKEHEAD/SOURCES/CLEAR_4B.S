; *************************************************************************
; ***            Routine which clear a box, in four bitplanes.          ***
; ***                         Dracula/Positivity.                       ***
; *************************************************************************
; Parameters:	a0.l = adress of the ramvideo.
;	d0.w = x1.
;	d1.w = y1.
;	d2.w = x2.
;	d3.w = y2.
; Note that this runs only on STe ( Blitter! ) and that it clear a box
; bigger that the one specified. ( I align the box on words. )
; Also note that it is not clipped!

  movem.l	d0-4/a0-1,-(sp)
  
.box_calculations:
  sub.w	d1,d3	; d3=dy=y2-y1.
  addq.w	#$1,d3	; d3=nb of h_lines to clear.
  move.w	d1,d4	; Multiply y1 by $a0.
  add.w	d1,d1
  add.w	d1,d1
  add.w	d4,d1
  lsl.w	#$5,d1
  add.w	d1,a0	; a0 points on the first line to clear.
.x_size:		; Calculate the x_size and then the
  moveq.l	#-$10,d4	; inc_y_dest.
  and.w	d4,d0	; Care only about the words.
  and.w	d4,d2
  sub.w	d0,d2	; d2=(nb of words-1)*16.
  lsr.w	#$1,d0
  add.w	d0,a0	; a0 points on the first word.
  lsr.w	#$2,d2	; d2=nb of words-4.
  addq.w	#$4,d2	; d2=nb of words to clear.
  move.w	#$51,d0
  sub.w	d2,d0	; d0=inc_y_dest.
  lsl.w	#$1,d0	; It must be given in bytes.
.clear_it:
  move.w	#$8a28,a1	; Base adress for the blitter.
  moveq.l	#-$1,d4
  move.l	d4,(a1)+	; Set all masks.
  move.w	d4,(a1)+
  move.w	#$2,(a1)+	; Inc_x_dest=2.
  move.w	d0,(a1)+	; Inc_y_dest=d0.
  move.l	a0,(a1)	; Adress for dest.
  move.w	d2,$4(a1)	; Nb of words per line.
  move.w	d3,$6(a1)	; Nb of h_lines per bitblock.
  move.w	#$200,$8(a1)	; Put everything to zero.
  move.b	#$c0,$a(a1)	; Launch the blitter.

  movem.l	(sp)+,d0-4/a0-1
  rts

  
