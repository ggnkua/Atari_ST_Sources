; some 3D subroutines which are good to have in a central place.

Lib3D.MASK_OVERLAP:=	0
Lib3D.MAX_X:=		320
Lib3D.MAX_Y:=		200
Lib3D.INVTABLE_SIZE:=	4096

			rsreset
Lib3D.POLYSTRUCT_LSCANS:rs.l	1
Lib3D.POLYSTRUCT_RSCANS:rs.l	1
Lib3D.POLYSTRUCT_TOP:	rs.w	1
Lib3D.POLYSTRUCT_BTM:	rs.w	1
Lib3D.POLYSTRUCT_IDX:	rs.w	1
Lib3D.POLYSTRUCT_SIZE:	rs.b	0

	text

Lib3D.precalc_mul_table:
	ifne	1

	lea	Lib3D.mul_table,a0
	movea.l	a0,a2
	adda.l	#128*4*255+128*2,a2
	moveq	#-128,d1
	lea	128*2(a0),a0

.yloop:	lea	2(a0),a1
	lea	2(a2),a3
	moveq	#-128,d2
	muls.w	d1,d2
	moveq	#128-1,d0

.ext_xloop:
	move.w	d2,d3
	add.w	d1,d2
	asr.w	#6,d3

	neg.w	d3
	move.w	d3,-(a1)
	move.w	d3,(a2)+
	neg.w	d3
	move.w	d3,-(a3)
	move.w	d3,(a0)+

	dbf	d0,.ext_xloop

; finish off with the left edge, this isn't mirrored on the right side.
; the table isn't centre-symmetrical.
	move.w	d2,d3
	asr.w	#6,d3
	move.w	d3,-(a3)
	neg.w	d3
	move.w	d3,-(a1)
	lea	128*2(a0),a0
	lea	-128*2*3(a2),a2
	addq.w	#1,d1
	bmi.s	.yloop

	else

	lea	Lib3D.mul_table+128*256*2,a0
	clr.w	d1

.yloop:	clr.w	d0
	move.w	d0,d4
	move.w	d1,d3
	ext.w	d4
	ext.w	d3
	muls.w	d3,d4
	ext.w	d1

.xloop:	move.w	d0,d2
	move.w	d1,d3
	ext.w	d2
	ext.w	d3
	muls.w	d2,d3
	asr.w	#6,d3

	move.w	d0,d2
	lsl.w	#8,d2
	move.b	d1,d2
	ext.l	d2
	add.l	d2,d2
	move.w	d3,(a0,d2.l)
	addq.b	#1,d0
	bne.s	.xloop

	addq.b	#1,d1
	bne.s	.yloop

	endc

	rts

Lib3D.precalc_mul_table_new:
	lea	Lib3D.mul_table,a0
	movea.l	a0,a2
	adda.l	#176*4*255,a2
	moveq	#-128,d1

.yloop:	move.w	#-176,d0
	lea	176*2*2(a0),a1
	lea	176*2*2(a2),a3

	move.w	d0,d2
	muls.w	d1,d2
	move.w	#176-1,d0

.ext_xloop:
	add.w	d1,d2
	move.w	d2,d3
	asr.w	#6,d3
	move.w	d3,(a0)+
	move.w	d3,-(a3)
	neg.w	d3
	move.w	d3,(a2)+
	move.w	d3,-(a1)
	dbf	d0,.ext_xloop

	lea	176*2(a0),a0
	lea	-176*2*3(a2),a2
	addq.w	#1,d1
	bmi.s	.yloop

	rts

; seems to work ok, since there has been some patching on the overflow
; errors (caused by combination of finite accuracy and use of maximum range).
; input:
; d0.w= x rotation (a)
; d1.w= y rotation (b)
; d2.w= z rotation (c)
; d3.w= z (for non-perspective scaled projection, 0: use perspective)
Lib3D.generate_matrix:
	move.w	d3,Lib3D.persp_off
	beq.s	.use_persp
	move.l	#$00FFFFFF,d7
	divu.w	d3,d7
.use_persp:
	lea	Lib3D.temp_matrix,a0
; 1] rotate 3 axis.
	move.w	#2048-1,d3
	and.w	d3,d0
	and.w	d3,d1
	and.w	d3,d2
	movea.w	d0,a3				; a3=xrot=a
	movea.w	d1,a4				; a4=yrot=b
	movea.w	d2,a5				; a5=zrot=c
	adda.w	a3,a3
	adda.w	a3,a3				; a3=xrot*4=4a (addressing offset)
	adda.w	a4,a4
	adda.w	a4,a4				; a4=yrot*4=4b (addressing offset)
	adda.w	a5,a5
	adda.w	a5,a5				; a5=zrot*4=4c (addressing offset)
	lea	sine_tbl,a2

; x' = + x*cos(b)*cos(c)
;      - y*cos(b)*sin(c)
;      + z*sin(b)
	movem.w	(a2,a4.w),d3/d4
	movem.w	(a2,a5.w),d5/d6
	muls.w	d4,d6				; / cos(b)*sin(c)
	add.l	d6,d6				; |
	swap	d6				; \
	muls.w	d4,d5				; / -cos(b)*sin(c)
	add.l	d5,d5				; |
	swap	d5				; |
	neg.w	d5				; \

	tst.w	Lib3D.persp_off
	beq.s	.store_x_row
	muls.w	d7,d6
	muls.w	d7,d5
	muls.w	d7,d3
	add.l	d6,d6
	add.l	d5,d5
	add.l	d3,d3
	swap	d6
	swap	d5
	swap	d3
.store_x_row:
	move.w	d6,(a0)+
	move.w	d5,(a0)+
	move.w	d3,(a0)+
	
; y' = + x*(sin(a)*sin(b)*cos(c)+cos(a)*sin(c))
;      + y*(cos(a)*cos(c)-sin(a)*sin(b)*sin(c))
;      - z*sin(a)*cos(b)
	movem.w	(a2,a3.w),d0/d1
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d0,d2
	add.l	d2,d2
	swap	d2
	muls.w	d2,d5
	add.l	d5,d5
	swap	d5
	muls.w	d1,d4
	add.l	d4,d4
	swap	d4
	add.w	d4,d5
	bvc.s	.skipyvd5
	addq.w	#1,d5
	neg.w	d5
.skipyvd5:
	move.w	d5,d3
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d1,d5
	add.l	d5,d5
	swap	d5
	muls.w	d0,d2
	add.l	d2,d2
	swap	d2
	muls.w	d2,d4
	add.l	d4,d4
	swap	d4
	sub.w	d4,d5
	bvc.s	.skipyv2d5
	addq.w	#1,d5
	neg.w	d5
.skipyv2d5:
	move.w	2(a2,a4.w),d4
	muls.w	d0,d4
	add.l	d4,d4
	swap	d4
	neg.w	d4

	tst.w	Lib3D.persp_off
	beq.s	.store_y_row
	muls.w	d7,d3
	muls.w	d7,d5
	muls.w	d7,d4
	add.l	d3,d3
	add.l	d5,d5
	add.l	d4,d4
	swap	d3
	swap	d5
	swap	d4
.store_y_row:
	move.w	d3,(a0)+
	move.w	d5,(a0)+
	move.w	d4,(a0)+

	tst.w	Lib3D.persp_off
	bne.s	.store_z_row

; z' = + x*(sin(a)*sin(c)-cos(a)*sin(b)*cos(c))
;      + y*(cos(a)*sin(b)*sin(c)+sin(a)*cos(c))
;      + z*cos(a)*cos(b)
	movem.w	(a2,a3.w),d0/d1
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d0,d4
	add.l	d4,d4
	swap	d4
	muls.w	d1,d2
	add.l	d2,d2
	swap	d2
	muls.w	d2,d5
	add.l	d5,d5
	swap	d5
	sub.w	d5,d4
	bvc.s	.skipzvd4
	addq.w	#1,d4
	neg.w	d4
.skipzvd4:
	move.w	d4,d3
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d1,d2
	add.l	d2,d2
	swap	d2
	muls.w	d2,d4
	add.l	d4,d4
	swap	d4
	muls.w	d0,d5
	add.l	d5,d5
	swap	d5
	add.w	d4,d5
	bvc.s	.skipzvd5
	addq.w	#1,d5
	neg.w	d5
.skipzvd5:
	move.w	2(a2,a4.w),d4
	muls.w	d1,d4
	add.l	d4,d4
	swap	d4

;	muls.w	d7,d3
;	muls.w	d7,d5
;	muls.w	d7,d4
;	add.l	d3,d3
;	add.l	d5,d5
;	add.l	d4,d4
;	swap	d3
;	swap	d5
;	swap	d4
.store_z_row:
	move.w	d3,(a0)+
	move.w	d5,(a0)+
	move.w	d4,(a0)+

; translation vector = (0,0,0)
	clr.l	d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	rts

Lib3D.persp_off:
	dc.w	0

; translate the matrix translation vector.
; input:
; d0.w: x translation
; d1.w: y translation
; d2.w: z translation
Lib3D.translate_matrix:
	lea	Lib3D.temp_matrix,a0
	add.w	d0,Matrix.TX(a0)
	add.w	d1,Matrix.TY(a0)
	add.w	d2,Matrix.TZ(a0)
	rts

; Subroutine that paints a flatshaded fragment. NO clipping!
; note: scan width is now fixed!
; 68000 optimised version using offset addressing instead of addq
; INPUT:
; d0.l: 16:16 left X-start
; d1.l: 16:16 right X-start
; d2.l: 16:16 left stepvalue
; d3.l: 16:16 right stepvalue
; d7.w: number of scanlines to paint - 1
; a0: start of begin screenline
; a3: right offset and mask table (!)
; OUTPUT: a0: start of next screenline
paint_flatfragment_fat_opt:
	movem.l	a1-a2/a6,-(sp)
	lea	Lib3D.left_offsetmask_table(pc),a1
	movea.l	d2,a2				; a2: 16:16 left stepvalue
	move.w	d7,d2
	moveq	#$FFFFFFFF,d4

.yloop:
	ifne	Lib3D.MASK_OVERLAP
; todo: nasty stack stuff this.. define a stack offset record?
	cmp.l	d0,d1
	blt	.end__
	endc

	move.l	d0,d5
	move.l	d1,d6
	swap	d5
	swap	d6

	ifeq	Lib3D.MASK_OVERLAP
	cmp.w	d5,d6
;	blt	.end__
	ble	.end_hline
	endc

; note: no more than 20 chunks (=320 pixels) in a row!
; input:
; d5.w=x0
; d6.w=x1
; a0: screen
; a1: offset and mask table
	add.w	d5,d5
	add.w	d5,d5
	move.l	(a1,d5.w),d5		; d5.l=(lmask<<16)|l_off
	add.w	d6,d6
	add.w	d6,d6
	move.l	(a3,d6.w),d6		; d6.l=(rmask<<16)|r_off
	sub.w	d5,d6			; d6.w=r_off-l_off
	bne.s	.multi_chunk

.single_chunk:
	and.l	d5,d6			; d6.l=((lmask&rmask)<<16) | garbage.w
	swap	d6			; d6.l=(garbage.w<<16) | (lmask&rmask)
	or.w	d6,(a0,d5.w)		; write it.
	lea	160(a0),a0
	add.l	a2,d0
	add.l	d3,d1
	dbf	d2,.yloop

.s_end_:move.l	a2,d2			; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	rts

.multi_chunk:
	lea	(a0,d5.w),a6		; a6: start of scan + l_off
	swap	d5			; d5.w=l_mask
	or.w	d5,(a6)			; write l_mask.
	move.w	d6,d5			; d5.w=r_off-l_off
	swap	d6			; d6.w=r_mask
	or.w	d6,(a6,d5.w)		; write r_mask. a6+d5.w=a0+r_off-l_off_r_off=a0+r_off

	neg.w	d5
	asr.w	#1,d5
	jmp	.jump_end+4(pc,d5.w)
offset	set	160
	rept	20
	move.w	d4,offset(a6)
offset	set	offset-8
	endr
.jump_end:

.end_hline:
	lea	160(a0),a0
	add.l	a2,d0
	add.l	d3,d1
	dbf	d2,.yloop

.end_:	move.l	a2,d2				; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	rts

.end__:	move.l	a2,d2				; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	addq	#4,sp
	rts

; Subroutine that paints a flatshaded fragment. NO clipping!
; note: scan width is now fixed!
; 68000 optimised version using offset addressing instead of addq
; INPUT:
; d0.l: 16:16 left X-start
; d1.l: 16:16 right X-start
; d2.l: 16:16 left stepvalue
; d3.l: 16:16 right stepvalue
; d7.w: number of scanlines to paint - 1
; a0: start of begin screenline
; a3: right offset and mask table (!)
; OUTPUT: a0: start of next screenline
; NOTE: hard move version, makes sure polys are remote or on different planes!
paint_flatfragment_fat_opt_m:
	movem.l	a1-a2/a6,-(sp)
	lea	Lib3D.left_offsetmask_table(pc),a1
	movea.l	d2,a2				; a2: 16:16 left stepvalue
	move.w	d7,d2
	moveq	#$FFFFFFFF,d4

.yloop:
	ifne	Lib3D.MASK_OVERLAP
; todo: nasty stack stuff this.. define a stack offset record?
	cmp.l	d0,d1
	blt	.end__
	endc

	move.l	d0,d5
	move.l	d1,d6
	swap	d5
	swap	d6

	ifeq	Lib3D.MASK_OVERLAP
	cmp.w	d5,d6
;	blt	.end__
	ble	.end_hline
	endc

; note: no more than 20 chunks (=320 pixels) in a row!
; input:
; d5.w=x0
; d6.w=x1
; a0: screen
; a1: offset and mask table
	add.w	d5,d5
	add.w	d5,d5
	move.l	(a1,d5.w),d5		; d5.l=(lmask<<16)|l_off
	add.w	d6,d6
	add.w	d6,d6
	move.l	(a3,d6.w),d6		; d6.l=(rmask<<16)|r_off
	sub.w	d5,d6			; d6.w=r_off-l_off
	bne.s	.multi_chunk

.single_chunk:
	and.l	d5,d6			; d6.l=((lmask&rmask)<<16) | garbage.w
	swap	d6			; d6.l=(garbage.w<<16) | (lmask&rmask)
	move.w	d6,(a0,d5.w)		; write it.
	lea	160(a0),a0
	add.l	a2,d0
	add.l	d3,d1
	dbf	d2,.yloop

.s_end_:move.l	a2,d2			; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	rts

.multi_chunk:
	lea	(a0,d5.w),a6		; a6: start of scan + l_off
	swap	d5			; d5.w=l_mask
	move.w	d5,(a6)			; write l_mask.
	move.w	d6,d5			; d5.w=r_off-l_off
	swap	d6			; d6.w=r_mask
	move.w	d6,(a6,d5.w)		; write r_mask. a6+d5.w=a0+r_off-l_off_r_off=a0+r_off
	neg.w	d5
	asr.w	#1,d5
	jmp	.jump_end+4(pc,d5.w)
offset	set	160
	rept	20
	move.w	d4,offset(a6)
offset	set	offset-8
	endr
.jump_end:

.end_hline:
	lea	160(a0),a0
	add.l	a2,d0
	add.l	d3,d1
	dbf	d2,.yloop

.end_:	move.l	a2,d2				; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	rts

.end__:	move.l	a2,d2				; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	addq	#4,sp
	rts

; input:
; a0: poly (#vertices, (x,y), (x,y) ...)
; a4: trapezoid paint rout
; a5: inverse table
paint_flat_poly:
	move.w	(a0)+,d7

	;move.l	a0,a1
	;move.w	d7,d6
	;bsr.s	check_width

; INPUT:
; d4.l=color (optional)
; d7.w=#points
; a0: poly (without vertices header)
; a4: trapezoid paintrout
; a5: inverse table
prest_paint_poly:

; -------
; reorder: can you tell your head from your ass?

; d7.w=pointcount >=3
; a0: point table count*(x.w,y.w)
; Find min y and max y.
	movea.l	a0,a1				; a1: backup src poly
	addq	#2,a0				; a0: y coords
	move.w	d7,d6
	move.w	d7,d1				; d1.w=count-index_min[0]
	subq.w	#1,d6
	moveq	#$FFFFFFFF,d0			; d0.w=min[0]
	moveq	#$00000000,d2			; d2.w=max[0]

.find_minmax_loop:
	cmp.w	(a0),d0				; y[n]<min[n-1] ?
	blo.s	.try_max			; nope -> check next
	move.w	(a0),d0				; Set new min.
	move.w	d6,d1				; Set new minindex.
.try_max:
	cmp.w	(a0),d2
	bhi.s	.next
	move.w	(a0),d2				; Set new max.
.next:	addq	#4,a0				; a0: next point
	dbf	d6,.find_minmax_loop

; store (min,max)..
	movem.w	d0/d2,prest_min

	lea	prest_poly2(pc),a0		; Head up!

; Rotate the point table using a barrel shift.
; The 
; a0: dst point table
; a1: src point table
; d1.w=count - split index
; d7.w=pointcount
	move.w	d7,d4
	subq.w	#1,d7				; d7.w=#points-1
	move.w	d7,d6
	sub.w	d1,d6				; d6.w=count-(count-split)=split

	move.w	d6,d5
	add.w	d5,d5
	add.w	d5,d5
	lea	(a1,d5.w),a2			; a2: src tail

	move.w	d1,d5				; d5.w=headsize
.headloop:
	move.l	(a2)+,(a0)+
	dbf	d5,.headloop

	subq.w	#1,d6
	bmi.s	.tail_done
.tailloop:
	move.l	(a1)+,(a0)+
	dbf	d6,.tailloop
.tail_done:
	move.w	d4,d7

; -------
; reordering done..

; if not anti-clockwise, you can make it..
; todo: do the test when required..
.anti_clockwise:
	lea	prest_left_table(pc),a6
	lea	prest_right_table(pc),a2
;	bra.s	.dir_done
;.clockwise:
;	lea	prest_left_table,a2
;	lea	prest_right_table,a6
;.dir_done:

; -------
	lea	prest_poly2(pc),a1
	movea.l	a6,a0
	move.w	prest_max(pc),d6
; d6.w=btm
; a0: left table [(y.w,x.w,slope.l),(),...]
; a1: pointtable
; a5: invtable
;prest_calc_left_points:
	clr.l	d2
	move.w	(a1)+,d1				; d1.w=x[0]
	move.w	(a1)+,d0				; d0.w=y[0]

.calc_left_loop:
; a1: next point
	move.w	(a1)+,d3				; d3.w=x[n]
	move.w	(a1)+,d2				; d2.w=y[n]
	move.w	d2,d4					; d4.w=x[n]
	move.w	d3,d5					; d5.w=y[n]
	move.w	d2,(a0)+				; Store y.
	move.w	d3,(a0)+				; Store x.
	sub.w	d0,d2					; d2.w=dy
	sub.w	d1,d3					; d1.w=dx
; d2.w should not exceed 32767.. (very relevant, i know ;))
	add.w	d2,d2
	muls.w	(a5,d2.w),d3				; d3.l=dx<<16/dy
	add.l	d3,d3
	move.l	d3,(a0)+				; Store slope.
	move.w	d5,d1					; d1.w=x[n]
	move.w	d4,d0					; d0.w=y[n]
	cmp.w	d0,d6
	bne.s	.calc_left_loop
.end_calc_left:
; -------

; -------
	lea	prest_poly2(pc),a1
	movea.l	a2,a0
	move.w	prest_max(pc),d6
	;bsr	prest_calc_right_points
; d6.w=btm
; d7.w=#points
; a0: right table [(y.w,x.w,slope.l),(),...]
; a1: pointtable
; a5: invtable
;prest_calc_right_points:
	clr.l	d2
	move.w	(a1)+,d1				; d0.w=y[0]
	move.w	(a1)+,d0				; d1.w=x[0]
	move.w	d7,d2
	add.w	d2,d2
	add.w	d2,d2
	lea	-8(a1,d2.w),a1

.calc_right_loop:
; a1: next point
	move.w	(a1)+,d3				; d3.w=x[n]
	move.w	(a1)+,d2				; d2.w=y[n]
	move.w	d2,d4					; d4.w=x[n]
	move.w	d3,d5					; d5.w=y[n]
	move.w	d2,(a0)+				; Store y.
	move.w	d3,(a0)+				; Store x.
	sub.w	d0,d2					; d2.w=dy
	sub.w	d1,d3					; d1.w=dx
; d2.w should not exceed 32767.. (very relevant ;))
	add.w	d2,d2
	muls.w	(a5,d2.w),d3				; d3.l=dx<<16/dy
	add.l	d3,d3
	move.l	d3,(a0)+				; Store slope.
	move.w	d5,d1					; d1.w=x[n]
	move.w	d4,d0					; d0.w=y[n]
	subq	#8,a1
	cmp.w	d0,d6
	bne.s	.calc_right_loop
.end_calc_right:
; -------

; Now paint trapezoids..
; d4.l=color (optional)
; a4: trapezoid paintrout
; a6: left
; a2: right
	movem.w	prest_poly2(pc),d0-d1
	move.w	d1,d6				; d1.w=d6.w=top

; Set screenstart
	movea.l	Lib3D.screenadr(pc),a0

; mulu takes 38+2n (n = amount of ones in 160 (=2)) = 42 (44)
	ifne	0
	mulu.w	#160,d1				; 44
	adda.l	d1,a0				;  8
						; -- +
						; 52 cycles
	endc

	ifne	0
	move.w	d1,d2				;  4
	add.w	d2,d2				;  4
	add.w	d2,d2				;  4
	add.w	d1,d2				;  4
	lsl.w	#5,d2				; 18 (20)
	adda.l	d2,a0				;  8
						; -- +
						; 42 (44) cycles
	endc

	ifne	1
	add.w	d1,d1				;  4
	lea	Lib3D.scan_table(pc),a3		;  8 
	adda.w	(a3,d1.w),a0			; 16
						; -- +
						; 28 cycles
	endc	

	lea	Lib3D.right_offsetmask_table(pc),a3

; Head..
	cmp.w	(a6),d6
	beq	.horizontal_head_l
	cmp.w	(a2),d6
	beq.s	.horizontal_head_r
; Normal triangular head..
	swap	d0
	move.w	#$8000,d0			; d0.l=lx start (16:16)
	move.l	d0,d1				; d1.l=rx start (16:16)
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	move.l	4(a2),d3			; d3.l=r slope (16:16)

.loop:
; d6.w=y start
; a0: start of next screenline
	cmp.w	prest_max(pc),d6
	beq.s	.end
	move.w	(a6),d7
	cmp.w	(a2),d7
	bgt.s	.left_bigger
	blt.s	.right_bigger

; Both sides equal..
;  / \
; /   \
	sub.w	d6,d7
	subq.w	#1,d7				; d7.w=h-1
	bmi.s	.skip_b
	jsr	(a4)
.skip_b:move.w	(a6)+,d6			; d6.w=y
	move.w	(a6)+,d0			; d0.w=lx start
	swap	d0
	move.w	#$8000,d0			; d0.l=lx start (16:16)
	move.w	2(a2),d1
	swap	d1
	move.w	d0,d1				; d1.l=rx start (16:16)
	addq	#4,a6				; a6: next left
	addq	#8,a2				; a2: next right
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	move.l	4(a2),d3			; d3.l=r slope (16:16)
	bra.s	.loop

.right_bigger:
; Right bigger, proceed to next left..
; / \
;    \
	sub.w	d6,d7
	subq.w	#1,d7				; d7.w=h-1
	bmi.s	.skip_r
	jsr	(a4)
.skip_r:move.w	(a6)+,d6
	move.w	(a6)+,d0
	swap	d0
	move.w	#$8000,d0			; d0.l=lx start (16:16)
	addq	#4,a6				; a6: next left
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	bra.s	.loop

.left_bigger:
; Left bigger, proceed to next right..
;  / \
; /
	move.w	(a2),d7
	sub.w	d6,d7
	subq.w	#1,d7				; d7.w=h-1
	bmi.s	.skip_l
	jsr	(a4)
.skip_l:move.w	(a2)+,d6
	move.w	(a2)+,d1
	swap	d1
	move.w	#$8000,d1			; d1.l=rx start (16:16)
	addq	#4,a2				; a2: next right
	move.l	4(a2),d3			; d3.l=r slope (16:16)
	bra.s	.loop

.end:	rts

; Special fucking cases..

;   o---r
;  /    :
; l
.horizontal_head_r:
	move.w	2(a2),d1
	swap	d1
	move.w	#$8000,d1			; d1.l=right x (16:16)
	swap	d0
	move.w	d1,d0				; d0.l=left x (16:16)
	addq	#8,a2				; a2: next right
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	move.l	4(a2),d3			; d3.l=l slope (16:16)
	bra	.loop

.horizontal_head_l:
	cmp.w	(a2),d1
	beq.s	.horizontal_head
; l---o
; :    \
;       r
	swap	d0
	move.w	#$8000,d0
	move.l	d0,d1				; d1.l=right x (16:16)
	move.w	2(a6),d0
	swap	d0
	move.w	d1,d0				; d0.l=left x (16:16)
	addq	#8,a6				; a6: next left
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	move.l	4(a2),d3			; d3.l=l slope (16:16)
	bra	.loop

; l---o---r
; :       :
.horizontal_head:
	move.w	2(a6),d0
	swap	d0
	move.w	#$8000,d0			; d0.l=left x (16:16)
	move.w	2(a2),d1
	swap	d1
	move.w	d0,d1				; d1.l=right x (16:16)
	addq	#8,a6				; a6: next left
	addq	#8,a2				; a6: next right
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	move.l	4(a2),d3			; d3.l=l slope (16:16)
	bra	.loop

prest_min:
	ds.w	1
prest_max:
	ds.w	1
prest_poly2:
	ds.l	16
prest_left_table:
	ds.l	2*16
prest_right_table:
	ds.l	2*16

Polygon.invTable:
	DS.W	Lib3D.MAX_Y+1

Lib3D.screenadr:
	ds.l	1

SCALED_SCANS:=	1

; input:
; d0.l= xstart<<16 | ystart
; d2.l= xend<<16   | height
; a2: scan buffer
; a4: inverse table
convert_scan:
; compute jump table entry point..
	add.w	d2,d2				; d2.w=height*2
	move.w	d2,d3				; d3.w=height*2
	add.w	d2,d2				; d2.w=height*4
	lea	.end(pc),a3
	suba.w	d2,a3				; a3: jump table entry point

; compute slope and set start.
	ifne	SCALED_SCANS
	lsl.l	#2,d0
	lsl.l	#2,d2
	endc

	move.w	#$8000,d0
	swap	d2				; d2.l=xend
	swap	d0				; d0.l=xstart
	sub.w	d0,d2				; d2.l=xend-xstart=width
	muls.w	(a4,d3.w),d2			; d2.l=slope=width/height [17:15]
	add.l	d2,d2				; d2.l=slope [SS:ss] [16:16]
	swap	d2				; d2.l=slope [ss:SS] for addx..

; do it..
	jmp	(a3)
	
	rept	200
	move.w	d0,(a2)+
	addx.l	d2,d0
	endr
.end:	rts

; convert a polygon to a scan table..
; input:
; d4.l=color (optional)
; d7.w=#points
; a0: poly (without vertices header)
; a3: left table
; a4: right table
; a5: inverse table
; output:
; d5.w= top
; d4.w= btm
scan_convert_poly:
	movem.l	a3-a4,leftright_table_adrs
	subq.w	#1,d7				; d7.w=#points-1

; wrap and find min and max y.
	movea.l	a0,a1
	lea	wrapped_poly,a2
	move.w	d7,d6
	moveq	#0,d4				; d4.w= initial btm value (the top)
	move.w	#200,d5				; d5.w= initial top value (the bottom)

.init_loop:
; load and copy coordinates..
	move.l	(a1)+,d0
	move.l	d0,(a2)+

; compute new top and btm..
	cmp.w	d5,d0
	bgt.s	.got_top
	move.w	d0,d5
.got_top:
	cmp.w	d4,d0
	blt.s	.got_btm
	move.w	d0,d4
.got_btm:	
	dbf	d6,.init_loop
; wrap..
	move.l	wrapped_poly,(a2)+

; d4.w= max y
; d5.w= min y

; scan-convert the edges..
	lea	wrapped_poly,a1
	lea	inv_table,a4
	move.w	d7,d6

.convert_edge_loop:
; get the vertex (x,y) coordinates..
	move.l	(a1)+,d0
	move.l	(a1),d2

; left or right edge?
	cmp.w	d0,d2
	bgt.s	.left
.right:	exg.l	d0,d2
	movea.l	right_table_adr,a2
	bra.s	.convert
.left:	movea.l	left_table_adr,a2
.convert:
	sub.w	d0,d2

; convert the edge scans..

; find the start in the edge buffer
	move.w	d0,d1				; d1.w=y_start
	sub.w	d5,d1				; d1.w=y_start-top
	add.w	d1,d1				; d1.w=edge_off=2*(y_start-top)
	adda.w	d1,a2				; a2: start of edge

	bsr	convert_scan

	dbf	d6,.convert_edge_loop
	rts

leftright_table_adrs:
left_table_adr:
	ds.l	1
right_table_adr:
	ds.l	1

; left/right scan buffer pointers
lr_scans:
	ds.l	2

; polygon routine using scan tables instead of directly rendering..
; INPUT:
; d4.l=color (optional)
; d7.w=#points
; a0: poly (without vertices header)
; a5: inverse table
; a6: structure [in: lscans_ptr.l, in: rscans_ptr.l, out: top.w, out: btm.w]
paint_scanned_poly:
	movem.l	(a6),a3/a4
	bsr	scan_convert_poly
; d5.w= top
; d4.w= btm
	move.w	d5,8(a6)
	move.w	d4,10(a6)
	movem.l	(a6),a2/a4
	bra	fill_spans

; polygon routine using scan tables instead of directly rendering..
; INPUT:
; d4.l=color (optional)
; d7.w=#points
; a0: poly (without vertices header)
; a5: inverse table
; in/out:
; a6: poly structure [in: lscans_ptr.l, in: rscans_ptr.l, out: top.w, out: btm.w]
wipe_scanned_poly:
	movem.l	(a6),a3/a4
	bsr	scan_convert_poly
; d5.w= top
; d4.w= btm
	move.w	d5,8(a6)
	move.w	d4,10(a6)
	movem.l	(a6),a2/a4
	bra	wipe_spans

; a0: old poly structure [in: lscans_ptr.l, in: rscans_ptr.l, in: top.w, in: btm.w]
; a1: new poly structure [in: lscans_ptr.l, in: rscans_ptr.l, out: top.w, out: btm.w]
; a2: poly
; d7.w=#points
paint_delta_poly:
	movem.l	(a1),a3/a4
	movem.l	a0-a1,-(sp)
	movea.l	a2,a0
	bsr	scan_convert_poly
	movem.l	(sp),a0-a1
; d5.w= top
; d4.w= btm
	move.w	d5,Lib3D.POLYSTRUCT_TOP(a1)
	move.w	d4,Lib3D.POLYSTRUCT_BTM(a1)

; paint or wipe top
	move.w	Lib3D.POLYSTRUCT_TOP(a0),d4
	move.w	Lib3D.POLYSTRUCT_TOP(a1),d5
	move.w	d5,d0
	sub.w	d4,d0				; d0.w=new_top - old_top
	move.w	d0,top_spill
	cmp.w	d4,d5				; new_top - old_top
	bgt.s	.top_ok
	move.w	d4,body_top
	movem.l	(a1),a2/a4
	bsr	fill_spans
	bra.s	.top_done
.top_ok:exg	d4,d5
	move.w	d4,body_top
	movem.l	(a0),a2/a4
	bsr	wipe_spans
.top_done:
	movem.l	(sp),a0-a1

; paint or wipe bottom
; TODO: place behind body to not have to calculate these fucking offsets?
	move.w	Lib3D.POLYSTRUCT_BTM(a0),d4
	move.w	Lib3D.POLYSTRUCT_BTM(a1),d5
	cmp.w	d4,d5				; new_btm - old_btm
	bgt.s	.btm_ok

	move.w	d4,d0
	sub.w	d5,d0				; d0.w=old_btm-new_btm (>=0)
	move.w	d5,body_btm
	move.w	d4,d1
	sub.w	Lib3D.POLYSTRUCT_TOP(a0),d1	; d1.w=height of old poly
	sub.w	d0,d1				; d1.w=index to bottom part of old scans
	move.w	d0,btm_spill
	add.w	d1,d1
	movem.l	(a0),a2/a4
	adda.w	d1,a2
	adda.w	d1,a4
	bsr	wipe_spans
	bra.s	.btm_done

.btm_ok:move.w	d5,d1				; d1.w=new btm
	sub.w	Lib3D.POLYSTRUCT_TOP(a1),d1	; d1.w=height of new poly
	exg	d4,d5
	move.w	d5,body_btm
	move.w	d4,d0
	sub.w	d5,d0				; d0.w=new_btm-old_btm (>0)
	sub.w	d0,d1				; d1.w=index to bottom part of new scans
	move.w	d0,btm_spill
	add.w	d1,d1
	movem.l	(a1),a2/a4
	adda.w	d1,a2
	adda.w	d1,a4
	bsr	fill_spans

.btm_done:
	movem.l	(sp)+,a0-a1

; paint/wipe body
	movem.l	(a0),a2/a4
	movem.l	(a1),a5/a6
	move.w	top_spill(pc),d0
	add.w	d0,d0
	bmi.s	.offset_old
	adda.w	d0,a2
	adda.w	d0,a4
	bra.s	.offset_done
.offset_old:
	suba.w	d0,a5
	suba.w	d0,a6
.offset_done:
	move.w	body_top(pc),d5
	move.w	body_btm(pc),d4
	bsr	paint_delta_spans_
	move.w	btm_spill(pc),d0
	add.w	d0,d0
	adda.w	d0,a5
	adda.w	d0,a6
	rts

top_spill:
	dc.w	0
btm_spill:
	dc.w	0
body_top:
	dc.w	0
body_btm:
	dc.w	0

macro_hline_fill:	macro
	ifne	SCALED_SCANS
	;andi.w	#$FFFC,d5
	;andi.w	#$FFFC,d6
	and.w	d2,d5
	and.w	d2,d6
	else
	add.w	d5,d5
	add.w	d5,d5
	add.w	d6,d6
	add.w	d6,d6
	endc
	move.l	(a1,d5.w),d5		; d5.l=(lmask<<16)|l_off
	move.l	(a3,d6.w),d6		; d6.l=(rmask<<16)|r_off
	sub.w	d5,d6			; d6.w=r_off-l_off
	bgt.s	.\@multi_chunk
	bmi.s	.\@end
	and.l	d5,d6			; d6.l=((lmask&rmask)<<16) | garbage.w
	swap	d6			; d6.l=(garbage.w<<16) | (lmask&rmask)
	or.w	d6,(a0,d5.w)		; write it.
	bra.s	.\@end
.\@multi_chunk:
	lea	(a0,d5.w),a6		; a6: start of scan + l_off
	swap	d5			; d5.w=l_mask
	or.w	d5,(a6)			; write l_mask.
	move.w	d6,d5			; d5.w=r_off-l_off
	swap	d6			; d6.w=r_mask
	or.w	d6,(a6,d5.w)		; write r_mask. a6+d5.w=a0+r_off-l_off_r_off=a0+r_off
	neg.w	d5
	asr.w	#1,d5
	jmp	.\@end+4(pc,d5.w)
	move.w	d4,$A0(a6)
	move.w	d4,$98(a6)
	move.w	d4,$90(a6)
	move.w	d4,$88(a6)
	move.w	d4,$80(a6)
	move.w	d4,$78(a6)
	move.w	d4,$70(a6)
	move.w	d4,$68(a6)
	move.w	d4,$60(a6)
	move.w	d4,$58(a6)
	move.w	d4,$50(a6)
	move.w	d4,$48(a6)
	move.w	d4,$40(a6)
	move.w	d4,$38(a6)
	move.w	d4,$30(a6)
	move.w	d4,$28(a6)
	move.w	d4,$20(a6)
	move.w	d4,$18(a6)
	move.w	d4,$10(a6)
	move.w	d4,$08(a6)
.\@end:
	endm

; note: a1,a3 reversed!
macro_hline_wipe:	macro
	ifne	SCALED_SCANS
	;andi.w	#$FFFC,d5
	;andi.w	#$FFFC,d6
	and.w	d2,d5
	and.w	d2,d6
	else
	add.w	d5,d5
	add.w	d5,d5
	add.w	d6,d6
	add.w	d6,d6
	endc
	move.l	(a3,d5.w),d5		; d5.l=(lmask<<16)|l_off
	move.l	(a1,d6.w),d6		; d6.l=(rmask<<16)|r_off
	sub.w	d5,d6			; d6.w=r_off-l_off
	bgt.s	.\@multi_chunk
	bmi.s	.\@end
	or.l	d5,d6			; d6.l=((lmask&rmask)<<16) | garbage.w
	swap	d6			; d6.l=(garbage.w<<16) | (lmask&rmask)
	and.w	d6,(a0,d5.w)		; write it.
	bra.s	.\@end
.\@multi_chunk:
	lea	(a0,d5.w),a6		; a6: start of scan + l_off
	swap	d5			; d5.w=l_mask
	and.w	d5,(a6)			; write l_mask.
	move.w	d6,d5			; d5.w=r_off-l_off
	swap	d6			; d6.w=r_mask
	and.w	d6,(a6,d5.w)		; write r_mask. a6+d5.w=a0+r_off-l_off_r_off=a0+r_off
	neg.w	d5
	asr.w	#1,d5
	jmp	.\@end+4(pc,d5.w)
	move.w	d3,$A0(a6)
	move.w	d3,$98(a6)
	move.w	d3,$90(a6)
	move.w	d3,$88(a6)
	move.w	d3,$80(a6)
	move.w	d3,$78(a6)
	move.w	d3,$70(a6)
	move.w	d3,$68(a6)
	move.w	d3,$60(a6)
	move.w	d3,$58(a6)
	move.w	d3,$50(a6)
	move.w	d3,$48(a6)
	move.w	d3,$40(a6)
	move.w	d3,$38(a6)
	move.w	d3,$30(a6)
	move.w	d3,$28(a6)
	move.w	d3,$20(a6)
	move.w	d3,$18(a6)
	move.w	d3,$10(a6)
	move.w	d3,$08(a6)
.\@end:
	endm

; in:
; d5.w= top
; d4.w= btm
; a2: left scans
; a4: right scans
; out:
; a2: end of left scans
; a4: end of left scans
fill_spans:
	sub.w	d5,d4
	beq	.end

	movea.l	Lib3D.screenadr,a0
	mulu.w	#160,d5
	adda.w	d5,a0
	lea	Lib3D.left_offsetmask_table(pc),a1
	lea	Lib3D.right_offsetmask_table(pc),a3
	move.w	d4,d7
	subq.w	#1,d7
	moveq	#-1,d4
	moveq	#$FFFFFFFC,d2

.yloop:	move.w	(a2)+,d5
	move.w	(a4)+,d6

;	bsr.s	paint_hline
	macro_hline_fill

	ifne	0
	add.w	d5,d5
	add.w	d5,d5
	move.l	(a1,d5.w),d5		; d5.l=(lmask<<16)|l_off
	add.w	d6,d6
	add.w	d6,d6
	move.l	(a3,d6.w),d6		; d6.l=(rmask<<16)|r_off
	sub.w	d5,d6			; d6.w=r_off-l_off
	bgt.s	.multi_chunk
	bmi.s	.end_
.single_chunk:
	and.l	d5,d6			; d6.l=((lmask&rmask)<<16) | garbage.w
	swap	d6			; d6.l=(garbage.w<<16) | (lmask&rmask)
	or.w	d6,(a0,d5.w)		; write it.
.end_:	lea	160(a0),a0
	dbf	d7,.yloop
	rts

.multi_chunk:
	lea	(a0,d5.w),a6		; a6: start of scan + l_off
	swap	d5			; d5.w=l_mask
	or.w	d5,(a6)			; write l_mask.
	move.w	d6,d5			; d5.w=r_off-l_off
	swap	d6			; d6.w=r_mask
	or.w	d6,(a6,d5.w)		; write r_mask. a6+d5.w=a0+r_off-l_off_r_off=a0+r_off
	neg.w	d5
	asr.w	#1,d5
	jmp	.jump_end+4(pc,d5.w)
offset	set	160
	rept	20
	move.w	d4,offset(a6)
offset	set	offset-8
	endr
.jump_end:
	endc

	lea	160(a0),a0
	dbf	d7,.yloop

.end:	rts

;----------------------------------
; fill the stuff between the scans.
; input:
; note: no more than 20 chunks (=320 pixels) in a row!
; input:
; d4.w=fill mask
; d5.w=xleft
; d6.w=xright
; a0: screen
; a1: left offset and mask table
; a3: right offset and mask table
paint_hline:
	cmp.w	d5,d6
	ble	.end_hline

	add.w	d5,d5
	add.w	d5,d5
	move.l	(a1,d5.w),d5		; d5.l=(lmask<<16)|l_off
	add.w	d6,d6
	add.w	d6,d6
	move.l	(a3,d6.w),d6		; d6.l=(rmask<<16)|r_off
	sub.w	d5,d6			; d6.w=r_off-l_off
	bne.s	.multi_chunk

.single_chunk:
	and.l	d5,d6			; d6.l=((lmask&rmask)<<16) | garbage.w
	swap	d6			; d6.l=(garbage.w<<16) | (lmask&rmask)
	or.w	d6,(a0,d5.w)		; write it.

	rts

.multi_chunk:
	lea	(a0,d5.w),a6		; a6: start of scan + l_off
	swap	d5			; d5.w=l_mask
	or.w	d5,(a6)			; write l_mask.
	move.w	d6,d5			; d5.w=r_off-l_off
	swap	d6			; d6.w=r_mask
	or.w	d6,(a6,d5.w)		; write r_mask. a6+d5.w=a0+r_off-l_off_r_off=a0+r_off
	neg.w	d5
	asr.w	#1,d5
	jmp	.jump_end+4(pc,d5.w)
offset	set	160
	rept	20
	move.w	d4,offset(a6)
offset	set	offset-8
	endr
.jump_end:

.end_hline:
	rts

;----------------------------------
; fill the stuff between the scans. (NOTE: no width check!)
; input:
; note: no more than 20 chunks (=320 pixels) in a row!
; input:
; d4.w=fill mask
; d5.w=xleft
; d6.w=xright
; a0: screen
; a1: left offset and mask table
; a3: right offset and mask table
paint_hline_:
	add.w	d5,d5
	add.w	d5,d5
	move.l	(a1,d5.w),d5		; d5.l=(lmask<<16)|l_off
	add.w	d6,d6
	add.w	d6,d6
	move.l	(a3,d6.w),d6		; d6.l=(rmask<<16)|r_off
	sub.w	d5,d6			; d6.w=r_off-l_off
	bgt.s	.multi_chunk
	bmi.s	.end
.single_chunk:
	and.l	d5,d6			; d6.l=((lmask&rmask)<<16) | garbage.w
	swap	d6			; d6.l=(garbage.w<<16) | (lmask&rmask)
	or.w	d6,(a0,d5.w)		; write it.
.end	rts

.multi_chunk:
	lea	(a0,d5.w),a6		; a6: start of scan + l_off
	swap	d5			; d5.w=l_mask
	or.w	d5,(a6)			; write l_mask.
	move.w	d6,d5			; d5.w=r_off-l_off
	swap	d6			; d6.w=r_mask
	or.w	d6,(a6,d5.w)		; write r_mask. a6+d5.w=a0+r_off-l_off_r_off=a0+r_off
	neg.w	d5
	asr.w	#1,d5
	jmp	.jump_end+4(pc,d5.w)
offset	set	160
	rept	20
	move.w	d4,offset(a6)
offset	set	offset-8
	endr
.jump_end:
	rts

; in:
; d5.w= top
; d4.w= btm
; a2: left scans
; a4: right scans
; out:
; a2: end of left scans
; a4: end of left scans
wipe_spans:
	sub.w	d5,d4
	beq	.end

	movea.l	Lib3D.screenadr,a0
	mulu.w	#160,d5
	adda.w	d5,a0

; reversing l,r masks is equivalent to the logical compliment
; reverse for full rout!
	lea	Lib3D.right_offsetmask_table(pc),a3
	lea	Lib3D.left_offsetmask_table(pc),a1
	move.w	d4,d7
	subq.w	#1,d7
	moveq	#0,d3
	moveq	#$FFFFFFFC,d2

.yloop:	move.w	(a2)+,d5
	move.w	(a4)+,d6

;	bsr.s	wipe_hline
	macro_hline_wipe

	ifne	0
	add.w	d5,d5
	add.w	d5,d5
	move.l	(a1,d5.w),d5		; d5.l=(lmask<<16)|l_off
	add.w	d6,d6
	add.w	d6,d6
	move.l	(a3,d6.w),d6		; d6.l=(rmask<<16)|r_off
	sub.w	d5,d6			; d6.w=r_off-l_off
	bgt.s	.multi_chunk
	bmi.s	.end_
.single_chunk:
	or.l	d5,d6			; d6.l=((lmask&rmask)<<16) | garbage.w
	swap	d6			; d6.l=(garbage.w<<16) | (lmask&rmask)
	and.w	d6,(a0,d5.w)		; write it.
.end_:	lea	160(a0),a0
	dbf	d7,.yloop
	rts

.multi_chunk:
	lea	(a0,d5.w),a6		; a6: start of scan + l_off
	swap	d5			; d5.w=l_mask
	and.w	d5,(a6)			; write l_mask.
	move.w	d6,d5			; d5.w=r_off-l_off
	swap	d6			; d6.w=r_mask
	and.w	d6,(a6,d5.w)		; write r_mask. a6+d5.w=a0+r_off-l_off_r_off=a0+r_off
	neg.w	d5
	asr.w	#1,d5
	jmp	.jump_end+4(pc,d5.w)
offset	set	160
	rept	20
	move.w	d4,offset(a6)
offset	set	offset-8
	endr
.jump_end:
	endc

	lea	160(a0),a0
	dbf	d7,.yloop

.end:	rts

;----------------------------------
; fill the stuff between the scans.
; input:
; note: no more than 20 chunks (=320 pixels) in a row!
; input:
; d4.w=fill mask
; d5.w=xleft
; d6.w=xright
; a0: screen
; a1: left offset and mask table
; a3: right offset and mask table
wipe_hline:
	cmp.w	d5,d6
	ble	.end_hline

	add.w	d5,d5
	add.w	d5,d5
	move.l	(a1,d5.w),d5		; d5.l=(lmask<<16)|l_off
	add.w	d6,d6
	add.w	d6,d6
	move.l	(a3,d6.w),d6		; d6.l=(rmask<<16)|r_off
	sub.w	d5,d6			; d6.w=r_off-l_off
	bne.s	.multi_chunk

.single_chunk:
	or.l	d5,d6			; d6.l=((lmask&rmask)<<16) | garbage.w
	swap	d6			; d6.l=(garbage.w<<16) | (lmask&rmask)
	and.w	d6,(a0,d5.w)		; write it.
	rts

.multi_chunk:
	lea	(a0,d5.w),a6		; a6: start of scan + l_off
	swap	d5			; d5.w=l_mask
	and.w	d5,(a6)			; write l_mask.
	move.w	d6,d5			; d5.w=r_off-l_off
	swap	d6			; d6.w=r_mask
	and.w	d6,(a6,d5.w)		; write r_mask. a6+d5.w=a0+r_off-l_off_r_off=a0+r_off
	neg.w	d5
	asr.w	#1,d5
	jmp	.jump_end+4(pc,d5.w)
offset	set	160
	rept	20
	move.w	d4,offset(a6)
offset	set	offset-8
	endr
.jump_end:

.end_hline:
	rts

;----------------------------------
; fill the stuff between the scans. (NOTE: no width check!)
; input:
; note: no more than 20 chunks (=320 pixels) in a row!
; input:
; d4.w=fill mask
; d5.w=xleft
; d6.w=xright
; a0: screen
; a1: left offset and mask table
; a3: right offset and mask table
wipe_hline_:
	add.w	d5,d5
	add.w	d5,d5
	move.l	(a1,d5.w),d5		; d5.l=(lmask<<16)|l_off
	add.w	d6,d6
	add.w	d6,d6
	move.l	(a3,d6.w),d6		; d6.l=(rmask<<16)|r_off
	sub.w	d5,d6			; d6.w=r_off-l_off
	bgt.s	.multi_chunk
	bmi.s	.end
.single_chunk:
	or.l	d5,d6			; d6.l=((lmask&rmask)<<16) | garbage.w
	swap	d6			; d6.l=(garbage.w<<16) | (lmask&rmask)
	and.w	d6,(a0,d5.w)		; write it.
.end:	rts

.multi_chunk:
	lea	(a0,d5.w),a6		; a6: start of scan + l_off
	swap	d5			; d5.w=l_mask
	and.w	d5,(a6)			; write l_mask.
	move.w	d6,d5			; d5.w=r_off-l_off
	swap	d6			; d6.w=r_mask
	and.w	d6,(a6,d5.w)		; write r_mask. a6+d5.w=a0+r_off-l_off_r_off=a0+r_off
	neg.w	d5
	asr.w	#1,d5
	jmp	.jump_end+4(pc,d5.w)
offset	set	160
	rept	20
	move.w	d4,offset(a6)
offset	set	offset-8
	endr
.jump_end:
	rts

; d5.w= top
; d4.w= btm
; a2: old left scans
; a4: old right scans
; a5: new left scans
; a6: new right scans
; todo: 
; NO BSRS!
paint_delta_spans:
	sub.w	d5,d4
	beq	.end

	movea.l	Lib3D.screenadr,a0
	mulu.w	#160,d5
	adda.w	d5,a0
	lea	Lib3D.left_offsetmask_table(pc),a1
	lea	Lib3D.right_offsetmask_table(pc),a3
	moveq	#$FFFFFFFC,d2
	move.w	d4,d7
	subq.w	#1,d7

.yloop:
; left side delta
; todo: clipping case
	move.w	(a2)+,d5			; d5.w=old_l
	move.w	(a5)+,d6			; d6.w=new_l
	cmp.w	d5,d6				; new_l - old_l
	bgt.s	.wipe_l				; new_l > old_l ? -> wipe, else paint

.paint_l:
	exg	d5,d6
; d5.w=new_l (start), d6.w=old_l (end)
	cmp.w	(a6),d6				; old_l - new_r
	ble.s	.paint_l_ok			; old_l <= new_r ? -> normal paint, else clip and paint
	move.w	(a6),d6
.paint_l_ok:
	moveq	#-1,d4
	move.l	a6,-(sp)
	bsr	paint_hline_
	movea.l	(sp)+,a6
	bra.s	.l_done

; d5.w=old_l (start), d6.w=new_l (end)
.wipe_l:cmp.w	(a4),d6				; new_l - old_r
	ble.s	.wipe_l_ok			; new_l <= old_r ? -> normal wipe, else clip and wipe
	move.w	(a4),d6				; clip: d6.w=end=old_r
.wipe_l_ok:
	exg	a1,a3
	moveq	#0,d4
	move.l	a6,-(sp)
	bsr	wipe_hline_
	movea.l	(sp)+,a6
	exg	a1,a3

.l_done:

; right side delta
; todo: clipping case
	move.w	(a4)+,d5			; d5.w=old_r
	move.w	(a6)+,d6			; d6.w=new_r
	cmp.w	d5,d6				; new_r-old_r
	blt.s	.wipe_r				; new_r < old_r ? -> wipe, else paint 

; d5.w=old_r (start), d6.w=new_r (end) 
.paint_r:
	cmp.w	-2(a5),d5			; old_r - new_l
	bge.s	.paint_r_ok			; old_r >= new_l ? -> normal paint, else clip and paint
	move.w	-2(a5),d5
.paint_r_ok:
	moveq	#-1,d4
	move.l	a6,-(sp)
	bsr	paint_hline_
	movea.l	(sp)+,a6
	bra.s	.r_done

.wipe_r:exg	d5,d6
; d5.w=new_r (start), d6.w=old_r (end)
	cmp.w	-2(a2),d5			; new_r - old_l
	bge.s	.wipe_r_ok			; new_r > old_l ? -> normal wipe, else clip and wipe
	move.w	-2(a2),d5			; clip: d5.w=start=old_l
.wipe_r_ok:
	exg	a1,a3
	moveq	#0,d4
	move.l	a6,-(sp)
	bsr	wipe_hline_
	movea.l	(sp)+,a6
	exg	a1,a3

.r_done:

	lea	160(a0),a0
	dbf	d7,.yloop

.end:	rts

; without the goddamn bsr's..
; d5.w= top
; d4.w= btm
; a2: old left scans
; a4: old right scans
; a5: new left scans
; a6: new right scans
paint_delta_spans_:
	sub.w	d5,d4
	bgt.s	.go_on
	rts
.go_on:	movea.l	Lib3D.screenadr,a0
	mulu.w	#160,d5
	adda.w	d5,a0
	lea	Lib3D.left_offsetmask_table(pc),a1
	lea	Lib3D.right_offsetmask_table(pc),a3
	move.w	d4,d7
	subq.w	#1,d7
	moveq	#$FFFFFFFC,d2
	moveq	#0,d3
	moveq	#-1,d4
	move.l	a6,d1

.yloop:
; left side delta
	move.w	(a2)+,d5			; d5.w=old_l
	move.w	(a5)+,d6			; d6.w=new_l
	cmp.w	d5,d6				; new_l - old_l
	bgt	.wipe_l				; new_l > old_l ? -> wipe, else paint

.paint_l:
	exg	d5,d6
; d5.w=new_l (start), d6.w=old_l (end)
	movea.l	d1,a6
	cmp.w	(a6),d6				; old_l - new_r
	ble.s	.paint_l_ok			; old_l <= new_r ? -> normal paint, else clip and paint
	move.w	(a6),d6
.paint_l_ok:
	macro_hline_fill
	bra	.l_done

; d5.w=old_l (start), d6.w=new_l (end)
.wipe_l:cmp.w	(a4),d6				; new_l - old_r
	ble.s	.wipe_l_ok			; new_l <= old_r ? -> normal wipe, else clip and wipe
	move.w	(a4),d6				; clip: d6.w=end=old_r
.wipe_l_ok:
	macro_hline_wipe

.l_done:
; right side delta
	move.w	(a4)+,d5			; d5.w=old_r
	movea.l	d1,a6
	move.w	(a6)+,d6			; d6.w=new_r
	move.l	a6,d1
	cmp.w	d5,d6				; new_r-old_r
	blt	.wipe_r				; new_r < old_r ? -> wipe, else paint 

; d5.w=old_r (start), d6.w=new_r (end) 
.paint_r:
	cmp.w	-2(a5),d5			; old_r - new_l
	bge.s	.paint_r_ok			; old_r >= new_l ? -> normal paint, else clip and paint
	move.w	-2(a5),d5
.paint_r_ok:
	macro_hline_fill

;	bra	.r_done
	lea	160(a0),a0
	dbf	d7,.yloop
	move.l	d1,a6
	rts

.wipe_r:exg	d5,d6
; d5.w=new_r (start), d6.w=old_r (end)
	cmp.w	-2(a2),d5			; new_r - old_l
	bge.s	.wipe_r_ok			; new_r > old_l ? -> normal wipe, else clip and wipe
	move.w	-2(a2),d5			; clip: d5.w=start=old_l
.wipe_r_ok:
	macro_hline_wipe

.r_done:

	lea	160(a0),a0
	dbf	d7,.yloop
	move.l	d1,a6
	rts

; shit, since these are (pc) relative, they need to stay here :/
; fill versions (or)
Lib3D.left_offsetmask_table: ;=	(Lib3D.mul_table+352*256*2)
	ds.w	2*320				; lmask,l_off
Lib3D.right_offsetmask_table: ;=	(Lib3D.left_offsetmask_table+4*320)
	ds.w	2*320				; rmask,r_off

; todo: these should not be here, but outside
left_scan_buf:
	ds.w	200
right_scan_buf:
	ds.w	200

wrapped_poly:
	ds.w	1+2*10

Lib3D.calc_offsetmask_tables:
	lea	Lib3D.left_offsetmask_table,a0
	lea	Lib3D.right_offsetmask_table,a1
	move.w	#Lib3D.MAX_X-1,d7
	move.w	#$FFFF,d0
	moveq	#0,d1
	ifne	Lib3D.MASK_OVERLAP
	move.l	#$FFFF8000,d5 ; rmask, horizontal neighbour overlap!
	else
	move.l	#$FFFF0000,d5 ; rmask, no overlap!
	endc
	move.l	d5,d2
	moveq	#0,d3

.loop:
; store lmask[n] and calc lmask[n+1]
	move.w	d0,(a0)+
	lsr.w	#1,d0
	bne.s	.lmask_ok
	moveq	#$FFFFFFFF,d0
.lmask_ok:

; store l_off[n] and calc l_off[n+1]
	move.w	d1,d6
;	beq.s	.lok
;	addq.w	#1,d6
;.lok:

	lsr.w	#1,d6
	andi.w	#$FFF8,d6
	move.w	d6,(a0)+
	addq.w	#1,d1

; store rmask[n] and calc rmask[n+1]
	move.w	d2,(a1)+
	lsr.l	#1,d2
	bcc.s	.rmask_ok
	move.l	#$FFFF8000,d2
.rmask_ok:

; store r_off[n] and calc r_off[n+1]
	move.w	d3,d6

	ifeq	Lib3D.MASK_OVERLAP
	beq.s	.rok
	subq.w	#1,d6
.rok:
	endc

	lsr.w	#1,d6
	andi.w	#$FFF8,d6
	move.w	d6,(a1)+
	addq.w	#1,d3

	dbf	d7,.loop
	rts

calc_inv_table:
	lea	inv_table,a0
	move.l	#$7FFF,d0
	moveq	#1,d7
	move.w	d0,(a0)+

.loop:	move.l	d0,d1
	divu.w	d7,d1
	move.w	d1,(a0)+
	addq.w	#1,d7
	cmpi.w	#Lib3D.INVTABLE_SIZE,d7
	blt.s	.loop
	rts

; input:
; d0.w=x0
; d1.w=y0
; d2.w=x1
; d3.w=y1
; d4.w=$F
; a0: screen
; a1: offset table
; a2: putpixel table
Line.paint:
	ifne	1

	cmp.w	d0,d2
	blt.s	.x_order_ok
	exg	d0,d2
	exg	d1,d3
.x_order_ok:
	sub.w	d0,d2				; d2.w=dx=abs(dx)
	sub.w	d1,d3				; d3.w=dy
	add.w	d1,d1
	move.w	d0,d5
	and.w	d4,d0				; d0.w=lx&$F
	sub.w	d0,d5				; d5.w=lx&$FFF0
	lsr.w	d5				; d5.w=chunk=(lx&$FFF0)>>2
	add.w	(a1,d1.w),d5			; d5.w=offset=y*160+chunk
	lea	(a0,d5.w),a6
	move.w	#160,d6				; d6.w=y increment
	move.w	d3,d7
	bpl.s	.y_abs
	neg.w	d7
	neg.w	d6				; negative increment!
.y_abs:	neg.w	d2
	cmp.w	d2,d7
	bgt.s	.dy_greater

.dx_greater:
; for now we use a totally 100% pessimised (but simple) loop!
	move.w	d2,d5				; d5.w=abs(dx)
	move.w	d2,d3				; d3.w=abx(dx)
	add.w	d0,d0
	move.w	(a2,d0.w),d0
	moveq	#0,d1

.hor_loop:
	or.w	d0,d1
	sub.w	d7,d5
	bgt.s	.next_hor
	add.w	d2,d5
	or.w	d1,(a6)
	moveq	#0,d1
	adda.w	d6,a6
.next_hor:
	add.w	d0,d0
	dbcs	d3,.hor_loop

	moveq	#1,d0
	or.w	d1,(a6)
	moveq	#0,d1
	subq	#8,a6
; beware, d3 may already be -1! no dbf possible!
	subq.w	#1,d3
	bpl.s	.hor_loop

	rts

.dy_greater:
	move.w	d7,d5				; d5.w=abs(dy)
	move.w	d7,d3
	add.w	d0,d0
	move.w	(a2,d0.w),d0

; too bad about the loop size.. for the rest it should be faster with
; add instead of the ror.
	lea	.len_mul_table(pc),a3   	;  8
	add.w	d7,d7				;  4
	move.w	(a3,d7.w),d7			; 14 (16)
	lea	.jump_end(pc),a3		;  8
	jmp	(a3,d7.w)			; 14 (16)

	rept	200
	or.w	d0,(a6)
	sub.w	d2,d5
	bgt.s	*+12	;.next
	add.w	d3,d5
	add.w	d0,d0
	bcc.s	*+6	;.next
	moveq	#1,d0
	subq	#8,a6
;.next:
	adda.w	d6,a6
	endr
.jump_end:
	rts

.len_mul_table:
num	set	0
	rept	200
	dc.w	num
num	set	num-18
	endr

	else

; original routine (slightly slower)..
	cmp.w	d0,d2
	bgt.s	.x_order_ok
	exg	d0,d2
	exg	d1,d3
.x_order_ok:
	sub.w	d0,d2				; d2.w=dx=abs(dx)
	sub.w	d1,d3				; d3.w=dy
	add.w	d1,d1
	move.w	d0,d5
	and.w	d4,d0				; d0.w=lx&$F
	sub.w	d0,d5				; d5.w=lx&$FFF0
	lsr.w	d5				; d5.w=chunk=(lx&$FFF0)>>2
	add.w	(a1,d1.w),d5			; d5.w=offset=y*160+chunk
	lea	(a0,d5.w),a6
	move.w	#160,d6				; d6.w=y increment
	move.w	d3,d7
	bpl.s	.y_abs
	neg.w	d7
	neg.w	d6				; negative increment!
.y_abs:	cmp.w	d2,d7
	bgt.s	.dy_greater

.dx_greater:
; todo: special masking shit!	
;	add.w	d0,d0
;	cmp.w	d0,d5
;	bgt.s	.mask_optimised
; choose a mask-optimised thingy or straight-forward put-pixel stuffs.

; for now we use a totally 100% pessimised (but simple) loop!
	move.w	d2,d5				; d5.w=abs(dx)
	move.w	d2,d3				; d3.w=abx(dx)
	add.w	d0,d0
	move.w	(a2,d0.w),d0
	moveq	#0,d1

.hor_loop:
	or.w	d0,d1
	sub.w	d7,d5
	bgt.s	.next_hor
	add.w	d2,d5
	or.w	d1,(a6)
	moveq	#0,d1
	adda.w	d6,a6
.next_hor:
	ror.w	d0
	dbcs	d3,.hor_loop

	or.w	d1,(a6)
	moveq	#0,d1
	addq	#8,a6
; beware, d3 may already be -1! no dbf possible!
	subq.w	#1,d3
	bpl.s	.hor_loop

	rts

; todo: use table to get rout decision?
.dy_greater:
	move.w	d7,d5				; d5.w=abs(dy)
	move.w	d7,d3
	add.w	d0,d0
	move.w	(a2,d0.w),d0
;	tst.w	d2
;	bmi.s	.rol_loop

	ifne	1

	lea	.jump_end(pc),a3		;  8
	neg.w	d7				;  4
	lsl.w	#4,d7				; 14 / combines to 
	jmp	(a3,d7.w)			; 14 \ 28, not 32 :))
	
	rept	200
	or.w	d0,(a6)
	sub.w	d2,d5
	bgt.s	*+10	;.next
	add.w	d3,d5
	ror.w	d0
	bcc.s	*+4	;.next
	addq	#8,a6
;.next:
	adda.w	d6,a6
	endr
.jump_end:

	else

.ror_loop:
	or.w	d0,(a6)
	sub.w	d2,d5
	bgt.s	.next_ror
	add.w	d3,d5
	ror.w	d0
	bcc.s	.next_ror
	addq	#8,a6
.next_ror:
	adda.w	d6,a6
	dbf	d7,.ror_loop

	endc
	rts

; never gets called with dx>=0
.rol_loop:
	or.w	d0,(a6)
	sub.w	d2,d5
	bgt.s	.next_rol
	add.w	d3,d5
	add.w	d0,d0
	bcc.s	.next_rol
	moveq	#1,d0
	subq	#8,a6
.next_rol:
	adda.w	d6,a6
	dbf	d7,.rol_loop
	rts

	endc

;--------------------------------------------------------------------------

Polygon.calcInvTable:
	lea	Polygon.invTable,a0
	move.l	#$8000,d1
	moveq	#2,d0
	move.w	#$7fff,(a0)+
	move.w	#$7fff,(a0)+

.posloop:
	move.l	d1,d2
	divu.w	d0,d2
	move.w	d2,(a0)+
	addq.w	#1,d0
	cmpi.w	#Lib3D.MAX_Y+1,d0
	blt.s	.posloop
	rts

;--------------------------------------------------------------------------

; note: no more than 20 chunks (=320 pixels) in a row!
; input:
; d5.w=x0
; d6.w=x1
; a0: screen
; a1: left_edge_table
macro_hline1slim:	macro
	moveq	#$F,d4			; d4.w=$000F=mask
	move.w	d6,d7			; d7.w=x1
	and.w	d4,d7			; d7.w=x1&$F
	and.w	d5,d4			; d4.w=$F&x0=x0&$F
	sub.w	d4,d5			; d5.w=x0-(x0&$F)=x0&$FFF0=(x0>>4)<<4
	sub.w	d7,d6			; d6.w=x1-(x1&$F)=x1&$FFF0=(x0>>4)<<4
	sub.w	d5,d6			; d6.w=(x1>>4-x0>>4)<<4
	bne.s	.multi_chunk

.single_chunk:
	lsr.w	#1,d5			; d5.w=(x0>>4)<<3=offset to first chunk
	add.w	d4,d4
	add.w	d7,d7
	move.w	(a1,d4.w),d4
	and.w	32(a1,d7.w),d4
	or.w	d4,(a0,d5.w)
	bra.s	.end

.multi_chunk:
	lsr.w	#1,d5			; d5.w=(x0>>4)<<3=offset to first chunk
	lea	(a0,d5.w),a6		; a6: first chunk

	lsr.w	#4,d6			; d6.w=#num_chunks=x1>>4-x0>>4 (right chunk excluded)

; leftmost chunk..
	add.w	d4,d4
	beq.s	.end_left_chunk
	move.w	(a1,d4.w),d4		; d4.w=mask
	or.w	d4,(a6)
	addq	#8,a6			; a6: next chunk
	subq.w	#1,d6			; d6.w=chunks-1
.end_left_chunk:

; body chunks..
	subq.w	#1,d6
	bmi.s	.end_body
	moveq	#$FFFFFFFF,d4
.loop:	move.w	d4,(a6)
	addq	#8,a6
	dbf	d6,.loop
.end_body:		

; rightmost chunk..
	add.w	d7,d7
	move.w	32(a1,d7.w),d5		; d5.w=mask
	or.w	d5,(a6)
.end_right_chunk:
.end:
	endm

; Subroutine that paints a flatshaded fragment. NO clipping!
; note: scan width is now fixed!
; INPUT:
; d0.l: 16:16 left X-start
; d1.l: 16:16 right X-start
; d2.l: 16:16 left stepvalue
; d3.l: 16:16 right stepvalue
; d7.w: number of scanlines to paint - 1
; a0: start of begin screenline
; OUTPUT: a0: start of next screenline
paint_flatfragment_slim:
	movem.l	a1-a2/a6,-(sp)
	lea	left_edge_table(pc),a1
	movea.l	d2,a2				; a2: 16:16 left stepvalue
	move.w	d7,d2

.yloop:
; todo: nasty stack stuff this.. define a stack offset record?
	cmp.l	d0,d1
	blt	.end__

	move.l	d0,d5
	move.l	d1,d6
	swap	d5
	swap	d6

;	cmp.w	d5,d6
;	blt	.end__

	macro_hline1slim
.end_hline:

	lea	160(a0),a0
	add.l	a2,d0
	add.l	d3,d1
	dbf	d2,.yloop

.end_:	move.l	a2,d2				; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	rts

.end__:	move.l	a2,d2				; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	addq	#4,sp
	rts

; input:
; d6.w=n
; a1: poly (x1.w, y1.w, ..., xn.w, yn.w)
check_width:
	moveq	#$FFFFFFFF,d0
	moveq	#$00000000,d1
	subq.w	#1,d6
.loop:	move.w	(a1),d2
	cmp.w	d0,d2
	bhs.s	.no_new_left
	move.w	d2,d0
.no_new_left:
	cmp.w	d1,d2
	bls.s	.no_new_right
	move.w	d2,d1
.no_new_right:
	addq	#4,a1
	dbf	d6,.loop	
; d0.w=left x, d1.w=right x

; decision making..
	sub.w	d0,d1
	cmpi.w	#32,d1
	blt.s	.slim
.fat:	lea	paint_flatfragment_fat_opt(pc),a4
	rts
.slim:	lea	paint_flatfragment_slim(pc),a4
	rts

;--------------------------------------------------------------------------

; keep the tables toghether, please.
left_edge_table:
	dc.w	$FFFF,$7FFF,$3FFF,$1FFF,$0FFF,$07FF,$03FF,$01FF
	dc.w	$00FF,$007F,$003F,$001F,$000F,$0007,$0003,$0001
right_edge_table:
	dc.w	$0000,$8000,$C000,$E000,$F000,$F800,$FC00,$FE00
	dc.w	$FF00,$FF80,$FFC0,$FFE0,$FFF0,$FFF8,$FFFC,$FFFE

mixed_edge_table:
	dc.w	$FFFF,$0000,$7FFF,$8000,$3FFF,$C000,$1FFF,$E000
	dc.w	$0FFF,$F000,$07FF,$F800,$03FF,$FC00,$01FF,$FE00
	dc.w	$00FF,$FF00,$007F,$FF80,$003F,$FFC0,$001F,$FFE0
	dc.w	$000F,$FFF0,$0007,$FFF8,$0003,$FFFC,$0001,$FFFE

Lib3D.scan_table:
.offset	set	0
	rept	Lib3D.MAX_Y
	dc.w	.offset
.offset	set	.offset+160
	endr

Lib3D.putpix_table:
        dc.w    $8000,$4000,$2000,$1000
        dc.w    $0800,$0400,$0200,$0100
        dc.w    $0080,$0040,$0020,$0010
        dc.w    $0008,$0004,$0002,$0001

;--------------------------------------------------------------------------

	bss

Lib3D.temp_matrix:
	ds.b	Matrix.SIZE

; note: this now resides in common.s
inv_table:=		Common.block
;	ds.w	Lib3D.INVTABLE_SIZE+1
Lib3D.mul_table:=	(inv_table+Lib3D.INVTABLE_SIZE*2+2)
;	ds.w	352*256
Lib3D.end_of_bss:=	(Lib3D.mul_table+352*256*2)		;(Lib3D.right_offsetmask_table_+4*320)
