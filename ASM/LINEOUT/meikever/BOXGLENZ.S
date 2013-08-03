; 3D for malctro (cogs)
;
; todo:
; - movement
; - transition(s)?
;
; 25-07-2007:
;
; hline routine has been optimised completely with look-up tables:
; left x-coord ->  (l_offset, l_mask)
; right x-coord -> (r_offset, r_mask)
;
; in case of left and right having the same offset no branch to end of
; y loop is done (saves 12 cycles on 68000).
;
; 07-08-2007:
;
; fixed hang in VBL wait routine
;
; 16-09-2007:
;
; attempt to make this into a glenz convex object thing with french type of
; design. added girl.. added dodecahedron.. seems damn fast. my routs are not
; as bad as thought before..
;
; 17-09-2007:
;
; optimised the poly filler when i thought i had already done everything in
; the best way.. turns out that move.w dn,xx(an) is better than 
; move.w dn,(an) + addq #x,an on plain 68000. who could have known. anyhow,
; this saves about 3 or 4 scanlines worst case for the dodecahedron. prolly
; more when it's closer. off to bed..
; 20:00: added loading pi1 graphics from file.. killed mask overlap..
; and it got faster on st! cmp.w (4 cycles) vs cmp.l (8 cycles)
;
; 30-12-2007:
;
; added two more objects.. it's quite impressive what i can still squeeze
; out of the st. although with more complex objects (like a rhombicuboocto-
; hedron with 26 faces) it's maybe best to recycle edges and use stupid
; scan tables again.. oh well. in any case it still runs in 50 fps. 
;
; 21-02-2008:
;
; simplified version: two boxes


; load from disk at init (1) or incbin (0)
BoxGlenz.DYNAMIC_PI1:=	0

; overlap polys horizontally (1/0) (y/n)
BoxGlenz.MASK_OVERLAP:=	0

; background color
BoxGlenz.BACK_COL:=	0	$335

; should be 1 or 2 (2 different detail versions!) 
BoxGlenz.NR_VBLS:=	1

PERSPECTIVE:=		1
BoxGlenz.MEASURE_CPU:=	0

MAX_Y:=			200
MAX_VERTICES:=		100
BoxGlenz.MAX_POLYS:=	100

BoxGlenz.INVTABLE_SIZE:=2048

;--

DEBUG_KEYS:=		0
BACKGOUND_PIC:=		0	
RASTERS:=		1

SCREEN_ROWS:=		25
FONT_HEIGHT:=		8
SCREEN_SCANS:=		SCREEN_ROWS*FONT_HEIGHT
TOTAL_ROWS:=		SCREEN_ROWS*2

;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0
	bra	end_libs
	include	mat.s
	include common.s
	include	lib_3d.s
	text
end_libs:
	include	tester.s
	text
	endc

;- plugin table ------------------------------------------------------------

	dc.l	BoxGlenz.mainloop
	dc.l	BoxGlenz.init
	dc.l	BoxGlenz.rt_init		; 2
	dc.l	BoxGlenz.deinit
	dc.l	BoxGlenz.set_no_rot		; 4
	dc.l	BoxGlenz.start_rot		; 5
	dc.l	BoxGlenz.trigger_grow_both	; 6
	dc.l	BoxGlenz.trigger_grow_single	; 7
	dc.l	BoxGlenz.trigger_crazy		; 8
	dc.l	BoxGlenz.trigger_flash		; 9
	dc.l	0

;- plugin routines ---------------------------------------------------------

BoxGlenz.init:
	rts

.handle:dc.w	0

BoxGlenz.rt_init:
	move.l	#BoxGlenz.init_pal,palirq

	jsr	Lib3D.precalc_mul_table
	bsr	calc_inv_table
	bsr	Polygon.calcInvTable

	bsr	Lib3D.calc_offsetmask_tables

	bsr	BoxGlenz.start_rot
	move.l	frmcnt,first_frame
	rts

BoxGlenz.deinit:
	move.l	#dummy,palirq
	rts

;--------------------------------------------------------------------------

BoxGlenz.mainloop:

	ifne	BoxGlenz.MEASURE_CPU
	ifeq	testmode
	move.w	#$0400,$FFFF8240.w
	endc
	endc

	move.l	frmcnt,d0
	sub.l	lastfrmcnt,d0
	subq.l	#2,d0
	bge.s	.clear_square
	movea.l	scr,a0
	bsr	CLEAR_STSCREEN
	bra.s	.end_clear
.clear_square:
	bsr	BoxGlenz.clear_square
.end_clear:

	movea.l	BoxGlenz.movement_rout,a0
	jsr	(a0)

	ifne	BoxGlenz.MEASURE_CPU
	ifeq	testmode
	move.w	#$0755,$FFFF8240.w
	endc
	endc

	move.w	BoxGlenz.bigbox_z,BoxGlenz.translation
	moveq	#0,d0
	move.w	d0,BoxGlenz.x_translation
	move.w	d0,BoxGlenz.y_translation
	bsr	BoxGlenz.gen_matrix

	ifne	BoxGlenz.MEASURE_CPU
	ifeq	testmode
	move.w	#$0304,$FFFF8240.w
	endc
	endc

	lea	transformed_object,a0
	lea	Lib3D.temp_matrix,a1
	lea	BoxGlenz.box_vertices,a2
	bsr	Object.transform

	ifne	BoxGlenz.MEASURE_CPU
	ifeq	testmode
	move.w	#$0440,$FFFF8240.w
	endc
	endc

; with sorting, required in most cases..
	;bsr	BoxGlenz.sort_polys
	;bsr	BoxGlenz.paint_sorted_polys
; without sorting.
	lea	BoxGlenz.inside_polys,a1
	lea	paint_flatfragment_fat_opt_m(pc),a4
	bsr	BoxGlenz.paint_polys

	ifne	1
; the small inner cube..

	ifne	BoxGlenz.MEASURE_CPU
	ifeq	testmode
	move.w	#$0755,$FFFF8240.w
	endc
	endc

	ifne	0

	move.w	BoxGlenz.smallbox_z,BoxGlenz.translation
	move.w	BoxGlenz.smallbox_x,BoxGlenz.x_translation
	move.w	BoxGlenz.smallbox_y,BoxGlenz.y_translation
	bsr	BoxGlenz.gen_matrix

	ifne	BoxGlenz.MEASURE_CPU
	ifeq	testmode
	move.w	#$0304,$FFFF8240.w
	endc
	endc

	lea	transformed_object,a0
	lea	Lib3D.temp_matrix,a1
	lea	BoxGlenz.box_vertices,a2
	bsr	Object.transform

	else
; more efficient transform..

	lea	BoxGlenz.temp_object+4,a0
	moveq	#8-1,d7
;	move.w	BoxGlenz.smallbox_x,d1
;	move.w	BoxGlenz.smallbox_y,d2
	move.w	BoxGlenz.smallbox_z,d3
	sub.w	BoxGlenz.bigbox_z,d3
;	addi.w	#160,d1
;	addi.w	#100,d2

;.transform_loop:	
;	add.w	d3,(a0)
;	addq	#6,a0
;	dbf	d7,.transform_loop
offset	set	0
	rept	8
	add.w	d3,offset(a0)
offset	set	offset+6
	endr

	lea	transformed_object+2,a0
	moveq	#8-1,d7
	move.w	BoxGlenz.smallbox_x,d6
	move.w	BoxGlenz.smallbox_y,a3
	bsr	Object.perspectivate

	endc

	ifne	BoxGlenz.MEASURE_CPU
	ifeq	testmode
	move.w	#$0440,$FFFF8240.w
	endc
	endc

	lea	BoxGlenz.outside_polys,a1
	lea	paint_flatfragment_fat_opt(pc),a4
	bsr	BoxGlenz.paint_polys

	endc			; little cube

; swap screens..
	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)

	ifeq	testmode
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	;swap	d0
	;move.b	d0,$FFFF8203.w
	endc

	ifne	BoxGlenz.MEASURE_CPU
	ifeq	testmode
	move.w	#BoxGlenz.BACK_COL,$FFFF8240.w
	endc
	endc

; wait for vbl..
	move.w	BoxGlenz.old_468(pc),d0
.vbl:	move.w	$0468.w,d1
	move.w	d1,d2
	sub.w	d0,d1
	cmpi.w	#BoxGlenz.NR_VBLS,d1
	blo.s	.vbl
	move.w	d2,BoxGlenz.old_468

	rts

BoxGlenz.old4ba:
	ds.l	1
BoxGlenz.old_468:
	ds.w	1

temp_poly:
	ds.w	100
first_frame:
	ds.l	1
vis_flags:
	ds.l	1

;--------------------------------------------------------------------------

BoxGlenz.set_no_rot:
	clr.w	BoxGlenz.rot_on
	rts

BoxGlenz.start_rot:
	move.w	$4BC.w,BoxGlenz.rot_start
	st	BoxGlenz.rot_on
	rts

BoxGlenz.trigger_grow_both:
	move.w	#4000,BoxGlenz.bigbox_z
	move.w	#4000,BoxGlenz.smallbox_z
	move.l	#BoxGlenz.move_both,BoxGlenz.movement_rout
	rts

BoxGlenz.trigger_grow_single:
	move.w	#1700,BoxGlenz.bigbox_z
	move.w	#1700,BoxGlenz.smallbox_z
	move.l	#BoxGlenz.move_small,BoxGlenz.movement_rout
	rts

BoxGlenz.move_both:
	move.w	BoxGlenz.bigbox_z,d0
	move.w	BoxGlenz.smallbox_z,d1
	subi.w	#20,d0
	subi.w	#20,d1
	cmpi.w	#1700,d0
	bge.s	.ok
	move.l	#dummy,BoxGlenz.movement_rout
	rts
.ok:	move.w	d0,BoxGlenz.bigbox_z
	move.w	d1,BoxGlenz.smallbox_z
	rts

BoxGlenz.move_small:
	move.w	BoxGlenz.bigbox_z,d0
	subi.w	#10,d0
	cmpi.w	#460,d0
	bge.s	.ok
	move.l	#dummy,BoxGlenz.movement_rout
	rts
.ok:	move.w	d0,BoxGlenz.bigbox_z
	rts

BoxGlenz.trigger_crazy:
	moveq	#0,d0
	move.w	d0,BoxGlenz.crazy_amp
	move.l	#BoxGlenz.move_crazy,BoxGlenz.movement_rout
	rts

BoxGlenz.trigger_flash:
	rts

BoxGlenz.move_crazy:
	move.w	BoxGlenz.crazy_amp,d7
	addq.w	#4,d7
	cmpi.w	#500,d7
	blt.s	.ok
	bra.s	.calc
.ok:	move.w	d7,BoxGlenz.crazy_amp

.calc:	lea	sine_tbl,a0
	bsr	getTime
	move.w	d0,d1
	move.w	d0,d2
	add.w	d0,d0
	add.w	d0,d0
	mulu.w	#7,d1
	mulu.w	#13,d2
	lsr.l	#1,d2
	andi.w	#SINTABLE_LEN-1,d0
	andi.w	#SINTABLE_LEN-1,d1
	andi.w	#SINTABLE_LEN-1,d2
	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d1
	add.w	d1,d1
	add.w	d2,d2
	add.w	d2,d2
	move.w	(a0,d0.w),d0
	move.w	(a0,d1.w),d1
	move.w	(a0,d2.w),d2
	muls.w	d7,d0
	muls.w	d7,d1
	muls.w	d7,d2
	swap	d0
	swap	d1
	swap	d2
	addi.w	#1700,d2
	asr.w	#3,d0
	asr.w	#3,d1
	move.w	d0,BoxGlenz.smallbox_x
	move.w	d1,BoxGlenz.smallbox_y
	move.w	d2,BoxGlenz.smallbox_z
	rts

BoxGlenz.init_pal:
	lea	$FFFF8240.w,a0
	moveq	#-1,d0
	rept	8
	move.l	d0,(a0)+
	endr

	move.w	#15,BoxGlenz.vbls2go
	move.l	#BoxGlenz.wait,palirq
	rts

BoxGlenz.wait:
	subq.w	#1,BoxGlenz.vbls2go
	bpl.s	.end
	move.l	#BoxGlenz.set_real_pal,palirq
.end:	rts

BoxGlenz.set_real_pal:
	movem.l	BoxGlenz.pal,d0-d7
	swap	d0
	move.w	#$0201,d0
	swap	d0
	movem.l	d0-d7,$FFFF8240.w
	move.l	#dummy,palirq
	rts

BoxGlenz.vbls2go:
	dc.w	0

;--------------------------------------------------------------------------
; vertex processing plant..
;--------------------------------------------------------------------------

BoxGlenz.gen_matrix:
	move.w	$04BC.w,d0
	sub.w	BoxGlenz.rot_start,d0
	;moveq	#0,d0

	lsr.w	#1,d0

	tst.w	BoxGlenz.rot_on
	bne.s	.rot_calced
	moveq	#0,d0
.rot_calced:

	ifne	0
; cogwheel rotation..
	mulu.w	#3,d0
	move.w	d0,d2
	move.w	#900,d0
	move.w	#200,d1
	else
	move.w	d0,d1
	move.w	d0,d2
	mulu.w	#3,d0
	mulu.w	#5,d1
	mulu.w	#7,d2
;	lsr.l	#1,d1
;	lsr.l	#2,d2
	endc
	;move.w	#550,d3				; fixed scale (for non-perspective mode)
	moveq	#0,d3
	bsr	Lib3D.generate_matrix

	move.w	BoxGlenz.translation,d2
	move.w	BoxGlenz.x_translation,d0
	move.w	BoxGlenz.y_translation,d1
	jsr	Lib3D.translate_matrix

	rts

; seems; input:
; a0: dst object
; a1: matrix
; a2: untransformed object
Object.transform:
	lea	Matrix.TX(a1),a3		; a3: translation vector
	move.w	(a2)+,d7			; d7.w=#vertices
	move.w	d7,(a0)+			; store #vertices in dst object.
	subq.w	#1,d7
	movea.l	d7,a5				; a5=#vertices
	move.l	a0,Object.dst
	lea	Lib3D.mul_table+128*256*2,a4
	lea	BoxGlenz.temp_object,a0

	move.w	(a3),d6
	movea.w	8(a3),a6
	movea.w	4(a3),a3

.vertexloop:
	movem.w	(a2)+,d0-d2

; 68000 optimised version! a4: multiply table
; x'
	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	move.w	d3,(a0)+			; store coordinate.
; y'
	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	move.w	d3,(a0)+			; store coordinate.
; z'

	ifne	PERSPECTIVE

	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	add.w	a6,d3				; translate coordinate.
	move.w	d3,(a0)+			; store coordinate.
	lea	-3*6(a1),a1

	else

	addq	#2,a0
	lea	-2*6(a1),a1

	endc

	dbf	d7,.vertexloop
	movea.l	Object.dst(pc),a0			; a0: dst object
	move.w	a5,d7				; d7.w=#vertices

; d7.w=count-1
; a0: dst
; d6.w=xoffset
; a3.w=yoffset
Object.perspectivate:
; perspectivate...
	lea	BoxGlenz.temp_object,a2
	move.w	#160,d4
	add.w	d6,d4
	move.w	#100,d5
	add.w	a3,d5
	move.w	#$0100,d3			; d3.w=z_offset

	lea	inv_table,a1

.persp_loop:

	ifne	PERSPECTIVE

;	movem.w	(a0),d0-d2
	movem.w	(a2)+,d0-d2
	add.w	d3,d2

	ifne	1
;	add.w	d2,d2
	andi.w	#$FFFE,d2
	move.w	(a1,d2.w),d2
	muls.w	d2,d0
	muls.w	d2,d1
	asr.l	#8,d0
	asr.l	#8,d1
	else
	lsl.l	#8,d0
	lsl.l	#8,d1
	divs.w	d2,d0
	divs.w	d2,d1
	endc

	add.w	d4,d0
	add.w	d5,d1
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq	#2,a0

	else

	move.w	(a0),d0
	asr.w	#1,d0
	add.w	d4,d0
	move.w	d0,(a0)+
	move.w	(a0),d1
	asr.w	#1,d1
	add.w	d5,d1
	move.w	d1,(a0)+
	addq	#2,a0

	endc

	dbf	d7,.persp_loop

	rts

Object.dst:
	dc.l	0
BoxGlenz.temp_object:
	ds.w	1+8*3

; fast but messes up rasters, tho..
; todo: flexible size (depending on bounding slab)
BoxGlenz.clear_square:
	movea.l	scr,a6				; a0: log screen, a1: phys screen
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movea.l	d0,a0
	movea.l	d0,a1
	movea.l	d0,a2
	movea.l	d0,a3
	movea.l	d0,a4
	movea.l	d0,a5

	ifne	0

; wipe the rest.. this is 16 lines less than usual..
	lea	20*160+32(a6),a6

offset	set	0

	rept	170
	movem.l	d0-a5,offset(a6)
	movem.l	d0-a1,offset+56(a6)
offset	set	offset+160
	endr

	else

; wipe the rest.. this is 16 lines less than usual..
	lea	35*160+48(a6),a6

offset	set	0

	rept	130
	movem.l	d0-a5,offset(a6)
	movem.l	d0-d1,offset+56(a6)
offset	set	offset+160
	endr

	endc

.end:	rts

;--------------------------------------------------------------------------

BoxGlenz.sort_polys:
	lea	BoxGlenz.poly_sort_list,a0
	lea	BoxGlenz.inside_polys,a1
	movea.l	a1,a6
	move.w	(a1)+,d7
	ble	.end
	subq.w	#1,d7
	lea	transformed_object+2,a2

.ploop:	move.l	a1,d0
	sub.l	a6,d0				; d0.l=poly offset
	move.w	d0,(a0)				; store poly offset.

	addq	#2,a1
	move.w	(a1)+,d6
	move.w	d6,d3
	add.w	d3,d3
	lea	(a1,d3.w),a3

	ifne	1

	move.w	(a1)+,d6
	add.w	d6,d6
	move.w	d6,d5
	add.w	d6,d6
	add.w	d5,d6				; d6.w= vertex offset (=vertex index * 6)
	movem.w	(a2,d6.w),d0-d1/a4		; d0.w=v[0].x, d1.w=v[0].y, a4.w= v[0].z
	move.w	(a1)+,d6
	add.w	d6,d6
	move.w	d6,d5
	add.w	d6,d6
	add.w	d5,d6				; d6.w= vertex offset (=vertex index * 6)
	lea	(a2,d6.w),a5
	move.w	(a5)+,d2			; d2.w=v[1].x
	move.w	(a5)+,d3			; d3.w=v[1].y
	add.w	(a5)+,a4			; a4= v[0].z+v[1].z
	move.w	(a1)+,d6
	add.w	d6,d6
	move.w	d6,d5
	add.w	d6,d6
	add.w	d5,d6				; d6.w= vertex offset (=vertex index * 6)
	lea	(a2,d6.w),a5
	move.w	(a5)+,d4			; d4.w=v[2].x
	move.w	(a5)+,d5			; d5.w=v[2].x
	add.w	(a5)+,a4			; a4= v[0].z+v[1].z+v[2].z

; backface culling!
;	sub.w	d2,d0				; d0.w=x1-x2
;	sub.w	d3,d1				; d1.w=y1-y2
;	sub.w	d2,d4				; d4.w=x3-x2
;	sub.w	d3,d5				; d5.w=y3-y2
;	muls.w	d1,d4				; d4.l=(x3-x2)(y1-y2)
;	muls.w	d0,d5				; d5.l=(x1-x2)(y3-y2)
;	sub.l	d4,d5
;	ble.s	.skip

	addq	#2,a0
	move.w	a4,(a0)+			; store z.

	else

	;subq.w	#1,d6
	moveq	#4-1,d6				; only take first 4 points.. (hope that works)

	moveq	#0,d2

.vloop:	move.w	(a1)+,d0
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0				; d0.w= vertex offset (=vertex index * 6)
	add.w	4(a2,d0.w),d2			; d2.w= v[0].z + .. + v[i].z
	dbf	d6,.vloop

	addq	#2,a0
	move.w	d2,(a0)+			; store z.

	endc

.skip:	movea.l	a3,a1				; a1: next poly
	dbf	d7,.ploop

; now sort all the visible triangles using combsort.
; combsort rules!! Thanx to Dynacore/.tSCc. for his great article!
	move.l	a0,d7
	sub.l	#BoxGlenz.poly_sort_list,d7
	lsr.w	#2,d7
	move.w	d7,BoxGlenz.num_sorted_polys
	subq.w	#1,d7
	beq.s	.endcombsort
	bmi	.end
	lea	BoxGlenz.poly_sort_list,a0
	movea.l	a1,a3
	movea.l	a0,a2
	move.w	d7,d4
	lsr.w	#1,d4				* d4.w: gapsize
	bra.s	.endcalcgap

.combsortloop:
	cmpi.w	#2,d4				* / If the gapsize
	bhi.s	.calcgap			* | is already 1 or
	moveq	#1,d4				* | 2 then always
	bra.s	.endcalcgap			* \ set it to 1.
.calcgap:
	mulu.w	#((1<<16)*10)/13,d4		* / Resize
	swap	d4				* \ the gap.
.endcalcgap:
	move.w	d7,d6
	sub.w	d4,d6
	move.w	d4,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	(a2,d0.w),a4
	moveq	#0,d5				* d5.w: number of swaps done in loop

.combsortinloop:
	move.l	(a0)+,d0
	move.l	(a4)+,d1
	cmp.w	d1,d0
	bge.s	.noswap
	move.l	d0,-4(a4)
	move.l	d1,-4(a0)
	addq.w	#1,d5
.noswap:dbf	d6,.combsortinloop

.combsortloopend:
	movea.l	a2,a0
	tst.w	d5
	bne.s	.combsortloop
	cmpi.w	#1,d4
	bne.s	.combsortloop
.endcombsort:

.end:	rts

BoxGlenz.poly_sort_list:
	ds.w	2*BoxGlenz.MAX_POLYS		; (poly offset, z_sum)
BoxGlenz.num_sorted_polys:
	ds.w	1

BoxGlenz.paint_sorted_polys:
	lea	BoxGlenz.poly_sort_list(pc),a3

	;lea	rts(pc),a4
	;lea	paint_flatfragment_fat(pc),a4
	lea	paint_flatfragment_fat_opt(pc),a4
	;lea	paint_flatfragment_slim(pc),a4

	lea	Polygon.invTable(pc),a5
	move.w	BoxGlenz.num_sorted_polys(pc),d7
	beq	.end_loop
	subq.w	#1,d7
;	clr.l	vis_flags

.loop:	move.w	(a3),d0
	addq	#4,a3
	lea	BoxGlenz.inside_polys,a1
	adda.w	d0,a1
	
	move.w	(a1)+,d0			; d0.w=plane index
	add.w	d0,d0				; d0.w=plane offset
	movea.l	scr,a0
	adda.w	d0,a0
	move.l	a0,Lib3D.screenadr

	lea	transformed_object+2,a2
	lea	temp_poly(pc),a0
	move.w	(a1)+,d6
	move.w	d6,(a0)+
	subq.w	#1,d6

.vloop:	move.w	(a1)+,d0
	add.w	d0,d0				; d0.w=2i
	move.w	d0,d1				; d1.w=2i
	add.w	d0,d0				; d0.w=4i
	add.w	d1,d0				; d0.w=2i+4i=6i
	move.l	(a2,d0.w),(a0)+
	dbf	d6,.vloop

	movem.l	d7/a1/a3,-(sp)
	lea	temp_poly(pc),a0
	bsr	paint_flat_poly
	movem.l	(sp)+,d7/a1/a3

; vis flags only needed when patterns mapped on polys..
	;addq.w	#1,vis_flags+2
.skippy_the_bush_kangaroo:
	;lea	vis_flags(pc),a0
	;move.l	(a0),d0
	;add.l	d0,d0
	;move.l	d0,(a0)

.next_poly:
	dbf	d7,.loop
.end_loop:
	rts

; input:
; a1: polys
; a4: fragment rout
BoxGlenz.paint_polys:

	lea	Polygon.invTable(pc),a5

	move.w	(a1)+,d7
	beq	.end_loop
	subq.w	#1,d7
;	clr.l	vis_flags

.loop:	move.w	(a1)+,d0			; d0.w=plane index
	add.w	d0,d0				; d0.w=plane offset
	movea.l	scr,a0
	adda.w	d0,a0
	move.l	a0,Lib3D.screenadr

	lea	transformed_object+2,a2
	lea	temp_poly(pc),a0
	move.w	(a1)+,d6
	move.w	d6,(a0)+
	subq.w	#1,d6

.vloop:	move.w	(a1)+,d0
	add.w	d0,d0				; d0.w=2i
	move.w	d0,d1				; d1.w=2i
	add.w	d0,d0				; d0.w=4i
	add.w	d1,d0				; d0.w=2i+4i=6i
	move.l	(a2,d0.w),(a0)+
	dbf	d6,.vloop

	movem.w	temp_poly+2(pc),d0-d5		; d0.w=x1, d1.w=y1, d2.w=x2, d3.w=y2, d4.w=x3, d5.w=y3
	sub.w	d2,d0				; d0.w=x1-x2
	sub.w	d3,d1				; d1.w=y1-y2
	sub.w	d2,d4				; d4.w=x3-x2
	sub.w	d3,d5				; d5.w=y3-y2
	muls.w	d1,d4				; d4.l=(x3-x2)(y1-y2)
	muls.w	d0,d5				; d5.l=(x1-x2)(y3-y2)
	sub.l	d4,d5
	ble.s	.skippy_the_bush_kangaroo

	movem.l	d7/a1,-(sp)
	lea	temp_poly(pc),a0
	bsr	paint_flat_poly
	movem.l	(sp)+,d7/a1

; vis flags only needed when patterns mapped on polys..
	;addq.w	#1,vis_flags+2
.skippy_the_bush_kangaroo:
	;lea	vis_flags(pc),a0
	;move.l	(a0),d0
	;add.l	d0,d0
	;move.l	d0,(a0)

.next_poly:
	dbf	d7,.loop
.end_loop:
	rts

;--------------------------------------------------------------------------

	data

BoxGlenz.box_vertices:
	dc.w	8
	dc.w	-050,-050,-050
	dc.w	-050,-050,+050
	dc.w	-050,+050,-050
	dc.w	-050,+050,+050
	dc.w	+050,-050,-050
	dc.w	+050,-050,+050
	dc.w	+050,+050,-050
	dc.w	+050,+050,+050

BoxGlenz.inside_polys:
	dc.w	6
	dc.w	1,4,+02,03,01,00
	dc.w	1,4,+04,05,07,06
	dc.w	0,4,+04,06,02,00
	dc.w	0,4,+01,03,07,05
	dc.w	2,4,+06,07,03,02
	dc.w	2,4,+00,01,05,04

BoxGlenz.outside_polys:
	dc.w	6
	dc.w	3,4,+00,01,03,02 02,03,01,00
	dc.w	3,4,+06,07,05,04 04,05,07,06
	dc.w	3,4,+00,02,06,04 04,06,02,00
	dc.w	3,4,+05,07,03,01 01,03,07,05
	dc.w	3,4,+02,03,07,06 06,07,03,02
	dc.w	3,4,+04,05,01,00 00,01,05,04

BoxGlenz.movement_rout:
	dc.l	dummy

BoxGlenz.bigbox_z:
	dc.w	4000

BoxGlenz.smallbox_z:
	dc.w	4000
BoxGlenz.smallbox_x:
	dc.w	0
BoxGlenz.smallbox_y:
	dc.w	0

BoxGlenz.pal:
	dc.w	$0501,$0756,$0634,$0533,$0534,$0411,$0632,$0601
	dc.w	$0765,$0543,$0644,$0320,$0431,$0000,$0766,$0654

;--------------------------------------------------------------------------

	bss

BoxGlenz.rot_on:
	ds.w	1
BoxGlenz.rot_start:
	ds.w	1
BoxGlenz.translation:
	ds.w	1
BoxGlenz.x_translation:
	ds.w	1
BoxGlenz.y_translation:
	ds.w	1

transformed_object		;:=	Lib3D.end_of_bss
	ds.w	1+MAX_VERTICES*3

BoxGlenz.crazy_amp:
	ds.w	1

