; *************************************************************************
; *****       Routine which generates the code for the zoomer.        *****
; *************************************************************************
; The zoomrouts are generated taking in account that the size of the source
; image is 96. The zoomrouts for a size between 0-46 are not generated, the
; routine only puts a rts for this size. The zoomrouts for a size between
; 48-96 are generated and are ending with a rts too. The adresses of the
; 48 routines (48 because the zoomed size must be even) are saved in the
; table pointed by a1.The size of all the routines is 34884 bytes.
; *************************************************************************
;     A zoom routine is composed like this: There is a big part of it which
; consists into linear to planar conversion, and as the size is defined,
; the pixels not to show are passed with an "addq.l #$1,a0". (Considering
; a0 contains the adress of the linear image.) During the generation of a
; zoom of a given size I have to calculate when a pixel must be passed.
; This is made with a kind of real number... I had a certain coef to the
; error, and if there isn't an overflow I must pass the next pixel. So if
; the carry is set, we draw a point, if not we pass one point and draw
; one. (By the way, original_size/zoomed_size is always =<2, that's why
; only this 2 case are possible.) The zoom coefficient is then calculated
; like this: N=nb of points to pass, then we must do N carry clear and
;            96-2*N carry set, so coef=(96-2*N)*65536/(96-N).
;    An other thing to understand, is that if the zoomed_size is not a
; multiple of 16 (96 or 64) then the two extreme words are not full! So
; we must have the 4 planes on the left 16 pixels set to 0 before we begin
; to work on them, and on the right 16 pixels we must rotate the planes
; left so that the first pixie is just after the last word.
; *************************************************************************
; The parameters of the generated routs are:
;	a0.l = adress of linear sourceline.
;	a1.l = adress of the planar dest.line.
;	a2.l = adress where to jump after the zoom.
;	       ( Jsr & Rts are too slow. )
; The sourceline must be so that the 4 most significant bits of each bytes
; are the value of the pixel.
; The registers d0-d4 are used by the routines.
; *************************************************************************
; Parameters:	a0.l = adress where to generate the code.
;	a1.l = adress where to save the adresses of the zoomrouts.

  Section TEXT

  movem.l	d0-a6,-(sp)
 rept	24	; The size between 0-46 are not taken in
  move.l	a0,(a1)+	; account, so just generate "jmp (a2)".
  move.w	#$4ed2,(a0)+
 endr

  move.l	#.zoom_coefs,a2	; They are a bit hard to calculate, so...
  move.w	#24,a3	; The first routine for a size of 2*24=48.
.generate_one_zoom:
  move.l	a0,(a1)+	; Save the adress of the routine.
  cmp.w	#32,a3	; Is the size bigger than 64?
  bgt.s	.bigger_64
.lower_64:		; If size=<64 then image begins on the 5th
  move.w	#$5089,(a0)+	; word, so generate the "addq.l #$8,a1".
.bigger_64:		; If size>64, it begins on 1st word.
  move.w	(a2)+,d0	; d0=zoom_coef for this size.
  moveq.l	#96,d1	; d1=error.
  move.w	a3,d2	; d2=size/2 mod(16)=nb of pixels on the
  and.w	#$f,d2	; "extremes" sets of 16 pixels.
  move.w	a3,d4	; d4=size/32=nb of "full" words/2.
  lsr.w	#$4,d4
  add.w	d4,d4	; d4=nb of "full" words.
  cmp.w	#$0,d2	; If size/2 mod(16)=0, then there are no
  beq.s	.full_sets	; "incomplete" words.

.left_case:		; First incomplete extremity.
  move.w	#$7200,(a0)+	; Generates "moveq.l #$0,d1".
  move.w	#$7400,(a0)+	; And the same for d2-d4.
  move.w	#$7600,(a0)+
  move.w	#$7800,(a0)+
  move.w	d2,d3	; Nb of points on the extremities.
  subq.w	#$1,d3	; Beware the dbra.
.left_one_point:
  add.w	d0,d1	; error=error+zoom_coef.
  bcs.s	.left_overflow
.left_no_overflow:	; If no overflow, the pass one source
  move.w	#$5288,(a0)+	; point by generating an "addq.l #$1,a0".
.left_overflow:
  move.w	#$1018,(a0)+	; Generate a "move.b (a0)+,d0".
  move.w	#$d000,(a0)+	; Generate the linear-planar conversion
  move.w	#$d944,(a0)+	; by generating "add.b d0,d0"
  move.w	#$d000,(a0)+	; then "addx.w d4,d4" and then the same
  move.w	#$d743,(a0)+	; with d3-d1.
  move.w	#$d000,(a0)+
  move.w	#$d542,(a0)+
  move.w	#$d000,(a0)+
  move.w	#$d341,(a0)+
  dbra	d3,.left_one_point
  move.l	#$4891001e,(a0)+ ; "movem.w d1-d4,(a1)".
  move.w	#$5089,(a0)+	; "addq.l #$8,a1".

.full_sets:		; Generate code for the "full" sets.
  subq.w	#$1,d4	; Beware the dbra.
.one_full_set:
  moveq.l	#$f,d3	; 16 points for a full set.
.full_one_point:
  add.w	d0,d1	; error=error+zoom_coef.
  bcs.s	.full_overflow
.full_no_overflow:	; If no overflow, the pass one source
  move.w	#$5288,(a0)+	; point by generating an "addq.l #$1,a0".
.full_overflow:
  move.w	#$1018,(a0)+	; Generate a "move.b (a0)+,d0".
  move.w	#$d000,(a0)+	; Generate the linear-planar conversion
  move.w	#$d944,(a0)+	; by generating "add.b d0,d0"
  move.w	#$d000,(a0)+	; then "addx.w d4,d4" and then the same
  move.w	#$d743,(a0)+	; with d3-d1.
  move.w	#$d000,(a0)+
  move.w	#$d542,(a0)+
  move.w	#$d000,(a0)+
  move.w	#$d341,(a0)+
  dbra	d3,.full_one_point
  move.l	#$4891001e,(a0)+ ; "movem.w d1-d4,(a1)".
  move.w	#$5089,(a0)+	; "addq.l #$8,a1".
  dbra	d4,.one_full_set

  cmp.w	#$0,d2	; Check if there is an incomplete set
  beq	.end_one_zoom	; after the full sets.
.right_case:		; Second incomplete extremity.
  move.w	d2,d3	; d3=nb of points to generate.
  subq.w	#$1,d3	; Beware the dbra.
.right_one_point:
  add.w	d0,d1	; error=error+zoom_coef.
  bcs.s	.right_overflow
.right_no_overflow:	; If no overflow, the pass one source
  move.w	#$5288,(a0)+	; point by generating an "addq.l #$1,a0".
.right_overflow:
  move.w	#$1018,(a0)+	; Generate a "move.b (a0)+,d0".
  move.w	#$d000,(a0)+	; Generate the linear-planar conversion
  move.w	#$d944,(a0)+	; by generating "add.b d0,d0"
  move.w	#$d000,(a0)+	; then "addx.w d4,d4" and then the same
  move.w	#$d743,(a0)+	; with d3-d1.
  move.w	#$d000,(a0)+
  move.w	#$d542,(a0)+
  move.w	#$d000,(a0)+
  move.w	#$d341,(a0)+
  dbra	d3,.right_one_point

; The right extremity must be rotated left so that the 16-(size/2 mod(16))
; points on the left of this set are 0.
.right_rotation:
  cmp.w	#$f,d2	; Only one rotation?
  bne.s	.right_more_1
  move.w	#$d041,(a0)+	; Then the quickest method to rotate
  move.w	#$d042,(a0)+	; the bitplanes is to generate an
  move.w	#$d043,(a0)+	; "add.w dx,dx" on all bitplanes.
  move.w	#$d044,(a0)+
  bra	.right_end
.right_more_1:
  cmp.w	#$8,d2	; More than 8 rotations?
  blt.s	.right_more_8
.right_less_8:		; We must create the opcode for a
  move.w	#$10,d3	; "lsl.w #16-d2,dx" instruction.
  sub.w	d2,d3	; d3=16-d2=nb of rotations.
  and.w	#%111,d3	; In the opcode a rotation of 8=0.
  lsl.w	#$8,d3	; Put nb_rot at its place in opcode.
  add.w	d3,d3
  move.w	#$e149,d2	; Opcode for a "lsl.w #0,d1".
  or.w	d3,d2	; Put the good nb of rot in opcode.
  move.w	d2,(a0)+
  move.w	#$e14a,d2	; Do the same with d2-d4.
  or.w	d3,d2
  move.w	d2,(a0)+
  move.w	#$e14b,d2
  or.w	d3,d2
  move.w	d2,(a0)+
  move.w	#$e14c,d2
  or.w	d3,d2
  move.w	d2,(a0)+
  bra.s	.right_end
.right_more_8:		; We must rotate by 8 and re-rotate.
  move.w	#$e149,(a0)+	; "lsl.w #$8,d1".
  move.w	#$e14a,(a0)+	; The same with d2-d4.
  move.w	#$e14b,(a0)+
  move.w	#$e14c,(a0)+	
  cmp.w	#$7,d2	; 9 rotations?
  bne.s	.right_not_9
  move.w	#$d041,(a0)+	; Then the quickest method to rotate
  move.w	#$d042,(a0)+	; the bitplanes is to generate an
  move.w	#$d043,(a0)+	; "add.w dx,dx" on all bitplanes.
  move.w	#$d044,(a0)+
  bra.s	.right_end
.right_not_9:		; We must create the opcode for a
  move.w	#$8,d3	; "lsl.w #8-d2,dx" instruction.
  sub.w	d2,d3	; d3=16-d2=nb of rotations.
  and.w	#%111,d3	; In the opcode a rotation of 8=0.
  lsl.w	#$8,d3	; Put nb_rot at its place in opcode.
  add.w	d3,d3
  move.w	#$e149,d2	; Opcode for a "lsl.w #0,d1".
  or.w	d3,d2	; Put the good nb of rot in opcode.
  move.w	d2,(a0)+
  move.w	#$e14a,d2	; Do the same with d2-d4.
  or.w	d3,d2
  move.w	d2,(a0)+
  move.w	#$e14b,d2
  or.w	d3,d2
  move.w	d2,(a0)+
  move.w	#$e14c,d2
  or.w	d3,d2
  move.w	d2,(a0)+

.right_end:
  move.l	#$4891001e,(a0)+ ; "movem.w d1-d4,(a1)".
  move.w	#$5089,(a0)+	; "addq.l #$8,a1".

.end_one_zoom:		; The end of the zoom.
  subq.l	#$2,a0	; The last "addq.l #$8,a1" is unusefull.
  move.w	#$4ed2,(a0)+	; "jmp (a2)"=end of this rout.
  addq.w	#$1,a3	; Next size.
  cmp.w	#48,a3	; It was the last size?
  ble	.generate_one_zoom
  movem.l	(sp)+,d0-a6
  rts

.zoom_coefs:
  dc.w	00000,05243,10083,14564,18725
  dc.w	22599,26215,29597,32768,35757
  dc.w	38551,41195,43691,46053,48290
  dc.w	50413,52429,54347,56174,57916
  dc.w	59579,61167,62687,64142,65535
