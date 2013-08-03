; camera chasing growing ribbons
;
; 02-11-2007:
;
; 02:40: first version
; 12:40: 2D growing and clipping done but testing is still to be done.
; 14:45: growing and clipping seems to work
;
; 03-11-2007:
;
; creating vertices and polys is done but untested.. time to do that.
; and, of course, check and modify the 3d transform.
; 14:00: 3D transform -seems- to do something..
; 14:15: added Z translation.. seems to do something.. needs to be
; centered.
; 14:45: centered, seems to zoom in, but gets too high.. no clipping
; anywhere, so best avoid too big polys
; 15:30: still some problems, zooming faster, limited y range, but still
; gets too high, and it seems polys come out of nowhere?
; 17:00: did it.
;
; 04-11-2007:
;
; z clipping fixed (was unused *brainfuck or what*)
;
; 08-11-2007:
;
; let's translate vertically, looks better.. but really needs some
; clipping!
; let's try some mirroring.. inefficient (could be done in poly rout)
; but working..
;
; 09-01-2008:
;
; added counter reset at start to avoid overflow issues.. (took days to
; figure out). 
;
; 10-01-2008:
;
; stripped loads of dead code from the source.
;
; 26-01-2008:
;
; attempt to straighten out far-end (head) clipping. gotta use pen, paper
; and brain here. 
;

; load from disk at init (1) or incbin (0)
	ifd	DEMO_SYSTEM
Ribbons.DYNAMIC_PI1:=	0
	else
Ribbons.DYNAMIC_PI1:=	0 1
	endc

; overlap polys horizontally (1/0) (y/n)
Ribbons.MASK_OVERLAP:=	0

; benchmark poly speed or show actual effect?
Ribbons.BENCHMARK:=	0
	ifne	Ribbons.BENCHMARK
WAIT_FOR_KEY:=		1
	endc

; 'camera' clip segment..
Ribbons.MAX_Z:=		1000
Ribbons.MIN_Z:=		0

; background color
Ribbons.BACK_COL:=	0	$335

; should be 1 or 2 (2 different detail versions!) 
Ribbons.NR_VBLS:=	1

; Z translation in case of perspective.
Ribbons.TRANSLATION:=	2500 950

Ribbons.PERSPECTIVE:=	1 Ribbons.NR_VBLS-1
Ribbons.MEASURE_CPU:=	0

Ribbons.MAX_Y:=		200
Ribbons.MAX_VERTICES:=	100
Ribbons.MAX_POLYS:=	100

Ribbons.INVTABLE_SIZE:=	4096

;--

Ribbons.DEBUG_KEYS:=	0
Ribbons.BACKGOUND_PIC:=	0	
Ribbons.RASTERS:=	0

Ribbons.SCREEN_ROWS:=	25
Ribbons.FONT_HEIGHT:=	8
Ribbons.SCREEN_SCANS:=	Ribbons.SCREEN_ROWS*Ribbons.FONT_HEIGHT
Ribbons.TOTAL_ROWS:=	Ribbons.SCREEN_ROWS*2

Ribbons.WHEEL_COLOUR1:=	1
Ribbons.WHEEL_COLOUR2:=	2

;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0
	bra	end_libs
	include	mat.s
	include	common.s
	include	lib_3d.s
	text
end_libs:
	include	tester.s
	text
	endc

;- plugin table ------------------------------------------------------------

	dc.l	Ribbons.mainloop
	dc.l	Ribbons.init
	dc.l	Ribbons.rt_init			; 2
	dc.l	Ribbons.deinit
	dc.l	Ribbons.trigger_dec_max		; 4
	dc.l	Ribbons.trigger_fade_in		; 5
	dc.l	Ribbons.trigger_fade_out	; 6
	dc.l	0

;- plugin routines ---------------------------------------------------------

Ribbons.init:
	ifne	Ribbons.DYNAMIC_PI1

; fopen
	clr.w	-(sp)
	pea	Ribbons.girlpic_name
	move.w	#$3D,-(sp)
	trap	#1
	addq	#8,sp
	tst.l	d0
	bmi	OUT
	move.w	d0,.handle

	pea	Ribbons.girl
	move.l	#32034,-(sp)
	move.w	d0,-(sp)
	move.w	#$3F,-(sp)
	trap	#1
	lea	12(sp),sp
	cmpi.l	#32034,d0
	bne	OUT

; fclose
	move.w	.handle(pc),-(sp)
	move.w	#$3E,-(sp)
	trap	#1
	addq	#4,sp

	endc

	rts

.handle:dc.w	0

Ribbons.rt_init:

	ifne	0
; to extract half of the degas..
	lea	Ribbons.girl+34,a1
	movea.l	a1,a0
	move.w	#200-1,d7
.loop:
	rept	80/4
	move.l	(a1)+,(a0)+
	endr
	lea	80(a1),a1
	dbf	d7,.loop

	endc

	jsr	Lib3D.precalc_mul_table
	jsr	calc_inv_table
	jsr	Polygon.calcInvTable
	jsr	Lib3D.calc_offsetmask_tables
	jsr	Ribbons.calc_fadepals

	move.w	#Ribbons.MAX_Z,Ribbons.max_z
	move.l	frmcnt,Ribbons.first_frame
	rts

Ribbons.deinit:
	move.l	#dummy,palirq
	rts

;--------------------------------------------------------------------------

Ribbons.mainloop:

	ifnd	DEMO_SYSTEM
	cmpi.l	#2000,frmcnt
	bge	OUT
	endc

;--------------------------------------------------------------------------
; tridi stuffs..

	ifne	Ribbons.MEASURE_CPU
	ifeq	testmode
	move.w	#$0400,$FFFF8240.w
	endc
	endc

	move.l	frmcnt,d0
	sub.l	lastfrmcnt,d0
	subq.l	#2,d0
	bge.s	.clear_square
	movea.l	scr,a0
	;jsr	CLEAR_STSCREEN
	bsr	Ribbons.copy_girlright
	bra.s	.end_clear
.clear_square:
	;bsr	Ribbons.clear_square
	movea.l	scr,a0
	bsr	Ribbons.clear_half CLEAR_STSCREEN
.end_clear:

	ifne	Ribbons.MEASURE_CPU
	ifeq	testmode
	move.w	#$0755,$FFFF8240.w
	endc
	endc

; 2D ribbon stuff..
	ifne	1
	tst.w	Ribbons.dec_max_enable
	beq.s	.end_max_dec
	jsr	getTime
	sub.w	Ribbons.dec_max_start,d0
	move.w	#Ribbons.MAX_Z,d1
	sub.w	d0,d1
	bpl.s	.max_pos
	moveq	#0,d1
.max_pos:
	move.w	d1,Ribbons.max_z
.end_max_dec:
	endc

	move.l	frmcnt,d0
	sub.l	Ribbons.first_frame,d0
	lsl.w	#3,d0
	move.w	d0,Ribbons.z_trans
	bsr	Ribbons.grow

	bsr	Ribbons.clip

; 3D ribbon stuff

; generate 3D vertices
Ribbons.XLEFT:=		-16
Ribbons.XRIGHT:=	+16

	lea	Ribbons.vertex_table,a0

; use unclipped (culled) ribbon..
;	movea.l	Ribbons.tail_adr,a1

; use clipped ribbon..
	lea	Ribbons.clipped_seg,a1

	move.w	Ribbons.clipped_num_segs,d7
	move.w	d7,d1
	subq.w	#1,d1
	move.w	d1,Ribbons.polys
	add.w	d7,d7
	move.w	d7,(a0)+
	ble.s	.end_gen_3d
	asr.w	#1,d7
	subq.w	#1,d7

.gen_3d_loop:
; left vertex
	move.w	#Ribbons.XLEFT,(a0)+
	move.w	2(a1),(a0)+
	move.w	(a1),(a0)+
; right vertex
	move.w	#Ribbons.XRIGHT,(a0)+
	move.w	2(a1),(a0)+
	move.w	(a1),(a0)+
	addq	#4,a1
	dbf	d7,.gen_3d_loop
.end_gen_3d:

	bsr	Ribbons.gen_matrix

	ifne	Ribbons.MEASURE_CPU
	ifeq	testmode
	move.w	#$0304,$FFFF8240.w
	endc
	endc

	lea	Ribbons.transformed_object,a0
	lea	Lib3D.temp_matrix,a1
	lea	Ribbons.vertex_table,a2
	bsr	Ribbons.Object.transform

	ifne	Ribbons.MEASURE_CPU
	ifeq	testmode
	move.w	#$0440,$FFFF8240.w
	endc
	endc

; with sorting, required in most cases..
	;bsr	Ribbons.sort_polys
	;bsr	Ribbons.paint_sorted_polys
; without sorting.
	bsr	Ribbons.paint_polys

	ifne	Ribbons.MEASURE_CPU
	ifeq	testmode
	move.w	#$0f00,$FFFF8240.w
	endc
	endc

	bsr	Ribbons.mirror_plane

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

	ifne	Ribbons.MEASURE_CPU
	ifeq	testmode
	move.w	#Ribbons.BACK_COL,$FFFF8240.w
	endc
	endc

	move.l	frmcnt,d0
	cmp.l	lastfrmcnt,d0
	bne.s	.end_pal
	move.l	#Ribbons.init_pal,palirq
.end_pal:

; wait for vbl..
	move.w	Ribbons.old_468(pc),d0
.vbl:	move.w	$0468.w,d1
	move.w	d1,d2
	sub.w	d0,d1
	cmpi.w	#Ribbons.NR_VBLS,d1
	blo.s	.vbl
	move.w	d2,Ribbons.old_468

	rts

Ribbons.old4ba:
	ds.l	1
Ribbons.old_468:
	ds.w	1

Ribbons.temp_poly:
	ds.w	100
Ribbons.temp_poly3:
	ds.w	100
Ribbons.first_frame:
	ds.l	1
Ribbons.vis_flags:
	ds.l	1

;--------------------------------------------------------------------------

Ribbons.trigger_dec_max:
	jsr	getTime
	move.w	d0,Ribbons.dec_max_start
	st	Ribbons.dec_max_enable
	rts

Ribbons.trigger_fade_in:
	jsr	getTime
	move.l	d0,Ribbons.fade_start_time
	move.w	#+255,Ribbons.fade_steps_left
	move.l	#Ribbons.blackfade_table,Ribbons.fade_table_addr
	move.l	#Ribbons.perform_fade_step,palirq
	rts

Ribbons.trigger_fade_out:
	jsr	getTime
	move.l	d0,Ribbons.fade_start_time
	move.w	#+255,Ribbons.fade_steps_left
	move.l	#Ribbons.bluefade_table,Ribbons.fade_table_addr
	move.l	#Ribbons.perform_fade_step,palirq
	rts

;--------------------------------------------------------------------------

Ribbons.init_pal:
	move.w	#Ribbons.BACK_COL,$FFFF8240.w	; %0000

	ifne	1
	lea	$FFFF8240.w,a0
	moveq	#0,d0
	rept	8
	move.l	d0,(a0)+
	endr
	else
; girl palette
	movem.l	Ribbons.girl+2,d0-d7
	movem.l	d0-d7,$FFFF8240.w
	endc

	move.l	#dummy,palirq
	rts

Ribbons.perform_fade_step:
	moveq	#-1,d2			; d2.w=increment
	move.w	Ribbons.fade_steps_left,d1
	move.w	d1,d4			; d4.w=backup fade steps
	beq.s	.stop
	bpl.s	.fade_index_ok
	neg.w	d2
	addi.w	#256,d1
.fade_index_ok:
	lsl.w	#1,d1
	andi.w	#$FFE0,d1
	movea.l	Ribbons.fade_table_addr,a0
	;adda.w	d1,a0

.all:	movem.l	(a0,d1.w),d0-d1/d3/d5-d7/a2-a3
	movem.l	d0-d1/d3/d5-d7/a2-a3,$FFFF8240.w
.pal_is_set:

	move.l	Ribbons.fade_start_time,d0
	add.w	d2,d4
	move.w	d4,Ribbons.fade_steps_left
	rts
.stop:	move.l	#dummy,palirq
	rts

Ribbons.calc_fadepals:
; split palette up into 24bit
	lea	Ribbons.girl+2,a1
	lea	Ribbons.tmp_pal(pc),a0
	moveq	#16-1,d7

.preloop:
	move.w	(a1)+,d0
	move.w	d0,d1
	move.w	d0,d2
	move.w	d0,d3
	move.w	d0,d4
	move.w	d0,d5

	andi.w	#$0700,d0
	lsr.w	#7,d0
	rol.w	#5,d3
	andi.w	#$0001,d3
	or.w	d3,d0

	andi.w	#$0070,d1
	lsr.w	#3,d1
	rol.b	#1,d4
	andi.w	#$0001,d4
	or.w	d4,d1
	
	andi.w	#$0007,d2
	add.w	d2,d2
	rol.b	#5,d5
	andi.w	#$0001,d5
	or.w	d5,d2

	move.b	d0,(a0)+
	move.b	d1,(a0)+
	move.b	d2,(a0)+

	dbf	d7,.preloop

; fade to white... (for 4th bitplane)
	lea	Ribbons.whitefade_table,a0
	moveq	#16-1,d7

.loop:
; calc greylevel (faded white)
	moveq	#16,d5
	sub.w	d7,d5
	lsl.w	#4,d5
	subq.w	#1,d5

	lea	Ribbons.tmp_pal(pc),a1
	moveq	#16-1,d6

.entryloop:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2

; mix color with white.
	move.b	(a1)+,d0
	mulu.w	d7,d0
	move.b	(a1)+,d1
	mulu.w	d7,d1
	move.b	(a1)+,d2
	mulu.w	d7,d2

	add.w	d5,d0
	add.w	d5,d1
	add.w	d5,d2

	ror.w	#5,d0
	ror.b	#5,d1
	ror.b	#5,d2
; ste
	move.w	d0,d3
	andi.w	#$8000,d3
	lsr.w	#4,d3
	move.w	d3,d4
	move.b	d1,d3
	andi.b	#$80,d3
	or.b	d3,d4
	move.b	d2,d3
	andi.b	#$80,d3
	lsr.b	#4,d3
	or.b	d3,d4
;st
	andi.w	#$0007,d0
	andi.w	#$0007,d1
	andi.w	#$0007,d2
	lsl.w	#8,d0
	lsl.w	#4,d1
	or.w	d0,d4
	or.w	d1,d4
	or.w	d2,d4
	move.w	d4,(a0)+
	dbf	d6,.entryloop

	dbf	d7,.loop

; fade-to-black ehmm.. purple..
	lea	Ribbons.temp_table,a0
	movea.w	#10,a3			; a3= dst red level
	movea.w	#0,a4			; a4= dst green level
	movea.w	#2,a5			; a5= dst blue level
	bsr	Ribbons.fade_to

	lea	Ribbons.temp_table,a1
	lea	Ribbons.blackfade_table+15*16*2,a0
	move.w	#16-1,d7
.revloop:
	movem.l	(a1)+,d0-d6/a2
	movem.l	d0-d6/a2,(a0)
	lea	-16*2(a0),a0
	dbf	d7,.revloop

; fade to blue (or any colour you like)
	lea	Ribbons.bluefade_table,a0
	movea.w	#15,a3			; a3= dst red level
	movea.w	#15,a4			; a4= dst green level
	movea.w	#15,a5			; a5= dst blue level
	bsr	Ribbons.fade_to

	rts

; input: a0: dst table, a3: r, a4: g, a5: b
Ribbons.fade_to:
	moveq	#16-1,d7

.bloop:	lea	Ribbons.tmp_pal(pc),a1
	moveq	#16-1,d6

.bentryloop:
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	move.b	(a1)+,d3		; d3.w=r
	move.b	(a1)+,d4		; d4.w=g
	move.b	(a1)+,d5		; d5.w=b

	cmp.w	d3,a3
	blt.s	.rdown
.rup:	add.w	d7,d3
	cmp.w	a3,d3
	ble.s	.rok
	move.w	a3,d3
	bra.s	.rok
.rdown:	sub.w	d7,d3
	cmp.w	a3,d3
	bgt.s	.rok
	move.w	a3,d3
.rok:
	cmp.w	d4,a4
	blt.s	.gdown
.gup:	add.w	d7,d4
	cmp.w	a4,d4
	ble.s	.gok
	move.w	a4,d4
	bra.s	.gok
.gdown:	sub.w	d7,d4
	cmp.w	a4,d4
	bgt.s	.gok
	move.w	a4,d4
.gok:
	cmp.w	d5,a5
	blt.s	.bdown
.bup:	add.w	d7,d5
	cmp.w	a5,d5
	ble.s	.bok
	move.w	a5,d5
	bra.s	.bok
.bdown:	sub.w	d7,d5
	cmp.w	a5,d5
	bgt.s	.bok
	move.w	a5,d5
.bok:

; r,g,b -> STe palette format
	ror.w	d3
	ror.b	d4
	ror.b	d5
; ste
	move.w	d3,d0
	andi.w	#$8000,d0
	lsr.w	#4,d0
	move.w	d0,d1		; d1.w=r0<<11
	move.b	d4,d0
	andi.b	#$80,d0
	or.b	d0,d1		; d1.w=r0<<11+g0<<7
	move.b	d5,d0
	andi.b	#$80,d0
	lsr.b	#4,d0
	or.b	d0,d1		; d1.w=r0<<11+g0<<7+b0<<3
; st
	andi.w	#$0007,d3
	andi.w	#$0007,d4
	andi.w	#$0007,d5
	lsl.w	#8,d3
	lsl.w	#4,d4
	or.w	d3,d5
	or.w	d4,d5		; d5.w=%0RRR0GGG0BBB
	or.w	d1,d5		; d5.w=%rRRRgGGGbBBB
	move.w	d5,(a0)+
	dbf	d6,.bentryloop

	dbf	d7,.bloop

	rts

Ribbons.tmp_pal:
	ds.b	3*16

;--------------------------------------------------------------------------
; growth..
;--------------------------------------------------------------------------

; todo: wrapping ribbon? or will it ever grow so large that wrapping is
; needed? depends on how long it is shown..
Ribbons.grow:

.loop:

; todo: use better counter?
	move.w	Ribbons.z_trans,d0

; move tail if counter exceeds near clipping end.
	movea.l	Ribbons.tail_adr,a0
	cmpa.l	Ribbons.head_adr,a0
	beq.s	.tail_done
	move.w	(a0),d2
	cmp.w	d0,d2
	bge.s	.tail_done
	addq.l	#4,Ribbons.tail_adr
.tail_done:

; grow only if far clipping end not exceeded yet.
	;addi.w	#Ribbons.MAX_Z,d0
	add.w	Ribbons.max_z,d0

	move.w	Ribbons.old_z,d1
	move.w	d1,d2
	add.w	Ribbons.dz,d2
	cmp.w	d0,d2
	bge.s	.end

	move.l	.rnd(pc),d3
	addq.l	#5,d3
	rol.l	d3,d3
	move.l	d3,.rnd

	andi.w	#$00FF,d3
	addi.w	#$0080,d3
; d3.w = avg(s)=$0100, max(s)=$017F, min(s)=$0080
	move.w	d3,Ribbons.dz			; store dz.
	move.w	d2,Ribbons.old_z		; store z_old.

	swap	d3
	andi.w	#$003F,d3
	subi.w	#$0020,d3
; d3.w = avg(s)=$0000, max(s)=+$007F, min(s)=-$0080

; append vertex..
	movea.l	Ribbons.head_adr,a0
	move.w	Ribbons.old_z(pc),(a0)+
	move.w	Ribbons.old_y(pc),(a0)+
	move.l	a0,Ribbons.head_adr

	move.w	d3,Ribbons.old_y

	bra	.loop

.end:	movea.l	Ribbons.head_adr,a0
	move.w	Ribbons.old_z,d0
	add.w	Ribbons.dz,d0
	move.w	d0,(a0)+

	move.w	Ribbons.old_y,(a0)+
	
; todo: translate ribbon to actual z_offset?
	rts

.rnd: 	dc.l	$17327081

; todo: translate unclipped ribbon? (then you don't have to use the
; counter)
; todo: !! decent head (=far end) clipping!!
Ribbons.clip:
; clip the far (new) end of the ribbon.
	movea.l	Ribbons.head_adr,a0
	movem.w	-4(a0),d0-d3			; d0.w=z[n],d1.w=y[n],d2.w=z[n+1],d3.w=y[n+1]

	;move.w	#Ribbons.MAX_Z,d5
	move.w	Ribbons.max_z,d5

	add.w	Ribbons.z_trans,d5
	bsr	Ribbons.clip_ribbon
	move.w	d1,d7				; d7.w=y'[n]

; clip the near (old) end of the ribbon.
	movea.l	Ribbons.tail_adr,a0
	movem.w	-4(a0),d0-d3			; d0.w=z[m],d1.w=y[m],d2.w=z[m+1],d3.w=y[m+1]
	move.w	#Ribbons.MIN_Z,d5
	add.w	Ribbons.z_trans,d5
	bsr	Ribbons.clip_ribbon		; d1.w=y'[m]

; generate clipped ribbon segment..
; note: this requires at least 2 segments in the clip window.
	lea	Ribbons.clipped_seg,a0
	move.l	Ribbons.head_adr,d0
	move.l	Ribbons.tail_adr,a1
	sub.l	a1,d0
	lsr.l	#2,d0
	move.w	d0,Ribbons.clipped_num_segs
; todo: randgeval?
	addq	#2,Ribbons.clipped_num_segs

; generate/copy new head..
	move.w	Ribbons.z_trans,d6
	add.w	#Ribbons.MIN_Z,d6
	move.w	d6,(a0)+
	move.w	d1,(a0)+

; copy body..
	subq.w	#1,d0
	bmi.s	.no_body
.copy_loop:
	move.l	(a1)+,(a0)+
	dbf	d0,.copy_loop
.no_body:

; generate new tail..
	move.w	Ribbons.z_trans,d6

;	addi.w	#Ribbons.MAX_Z,d6
	add.w	Ribbons.max_z,d6

	move.w	d6,(a0)+
	move.w	d7,(a0)+

	rts

Ribbons.dz:
	ds.w	1
Ribbons.old_z:
	ds.w	1
Ribbons.old_y:
	ds.w	1
Ribbons.dy:
	ds.w	1
Ribbons.head_adr:
	dc.l	Ribbons.unclipped_ribbon
Ribbons.tail_adr:
	dc.l	Ribbons.unclipped_ribbon
Ribbons.clipped_num_segs:
	ds.w	1

; input:
; d0.w=z[n],d1.w=y[n],d2.w=z[n+1],d3.w=y[n+1],d5.w=MAX_Z
Ribbons.clip_ribbon:
	move.w	d2,d4
	sub.w	d0,d4				; d4.w=dz[n]=z[n+1]-z[n]
	sub.w	d5,d0				; d0.w=-zm[n]=z[n]-MAX_Z
	sub.w	d5,d2				; d2.w=z[n+1]-MAX_Z
	sub.w	d1,d3				; d3.w=dy[n]=y[n+1]-y[n]
	ext.l	d3
	lsl.l	#8,d3				; d3.l=dy[n]<<8
	divs.w	d4,d3				; d3.w= slope[n]<<8 = dy[n]<<8 / dz[n]

	muls.w	d0,d3				; d3.l= -zm[n] * (slope[n]<<8)
	lsl.l	#8,d1				; d1.l= y[n]<<8
	sub.l	d3,d1				; d1.l= y'[n]<<8 = y[n]<<8 +zm[n]*slope[n]
	asr.l	#8,d1				; d1.l= y'[n]
	rts

;--------------------------------------------------------------------------
; vertex processing plant..
;--------------------------------------------------------------------------

Ribbons.gen_matrix:
	move.w	$04BC.w,d0

	moveq	#0,d1
	moveq	#0,d2

	move.w	#600,d3				; fixed scale (for non-perspective mode)
	jsr	Lib3D.generate_matrix

	move.w	#-40,d0
	moveq	#20,d1
	moveq	#0,d2
; todo: decent counter
	sub.w	Ribbons.z_trans,d2
	jsr	Lib3D.translate_matrix

	rts

; input:
; a0: dst object
; a1: matrix
; a2: untransformed object
Ribbons.Object.transform:
	lea	Matrix.TX(a1),a3		; a3: translation vector
	move.w	(a2)+,d7			; d7.w=#vertices
	move.w	d7,(a0)+			; store #vertices in dst object.
	subq.w	#1,d7
	movea.l	d7,a5				; a5=#vertices
	move.l	a0,.dst
	lea	Lib3D.mul_table+128*256*2,a4

	move.w	(a3),d6
	movea.w	8(a3),a6
	movea.w	4(a3),a3

.vertexloop:
	movem.w	(a2)+,d0-d2

; 68000 optimised version! a4: multiply table
; x'
	movem.w	(a1)+,d3-d5

	ifne	0				; too limited range, fuck it
	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	else
	move.w	d0,d3
	endc
	add.w	d6,d3
	move.w	d3,(a0)+			; store coordinate.
; y'
	movem.w	(a1)+,d3-d5

	ifne	0				; too limited range, fuck it
	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	else
	move.w	d1,d3
	endc
	add.w	a3,d3
	move.w	d3,(a0)+			; store coordinate.
; z'

	ifne	Ribbons.PERSPECTIVE

	movem.w	(a1)+,d3-d5

	ifne	0				; too limited range, fuck it
	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	else
	move.w	d2,d3
	endc
	add.w	a6,d3				; translate coordinate.
	move.w	d3,(a0)+			; store coordinate.
	lea	-3*6(a1),a1

	else

	addq	#2,a0
	lea	-2*6(a1),a1

	endc

	dbf	d7,.vertexloop

; perspectivate...
	movea.l	.dst(pc),a0			; a0: dst object
	move.w	a5,d7				; d7.w=#vertices
	move.w	#160,d4
	;add.w	d6,d4
	move.w	#100,d5
	;add.w	a3,d5
	move.w	#$0100,d3			; d3.w=z_offset

	lea	inv_table,a1

.persp_loop:

	ifne	Ribbons.PERSPECTIVE

	movem.w	(a0),d0-d2
	add.w	d3,d2

	ifne	1
	;add.w	d2,d2
	andi.w	#$FFFE,d2
	move.w	(a1,d2.w),d2
	muls.w	d2,d0
	muls.w	d2,d1
	asr.l	#7,d0
	asr.l	#7,d1
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

.dst:	dc.l	0

Ribbons.clear_half:
	movea.l	scr,a6				; a0: log screen, a1: phys screen
	addq	#8,a6
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

offset	set	0

	rept	200
	movem.l	d0-a5,offset(a6)
	movem.l	d0-d3,offset+56(a6)
offset	set	offset+160
	endr

.end:	rts

Ribbons.mirror_plane:
	movea.l	scr,a1

;	lea	2+32000-160(a1),a0
	lea	2+160*195-160(a1),a0
	lea	5*160(a1),a1

	move.w	#190-1,d7

offset	set	0
.yloop:
	rept	11
	move.w	offset(a1),offset(a0)
offset	set	offset+8
	endr
	lea	160(a1),a1
	lea	-160(a0),a0
	dbf	d7,.yloop

	rts

; input: 
; a0: screen
Ribbons.copy_girlright:
	lea	Ribbons.girl+34,a1
	lea	80(a0),a0
	move.w	#200-1,d7

.copyloop:
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,(a0)
	movem.l	(a1)+,d0-d6/a2
	movem.l	d0-d6/a2,48(a0)
	ifne	Ribbons.DYNAMIC_PI1
	lea	80(a1),a1
	endc
	lea	160(a0),a0
	dbf	d7,.copyloop

	lea	-160(a0),a0
	move.w	#200-1,d7
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	movea.l	d0,a1
	movea.l	d0,a2
	movea.l	d0,a3
	movea.l	d0,a4
	movea.l	d0,a5
	movea.l	d0,a6
.clearloop:
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6,-(a0)
	lea	-80(a0),a0
	dbf	d7,.clearloop
	rts

;--------------------------------------------------------------------------

	ifne	0

Ribbons.sort_polys:
	lea	Ribbons.poly_sort_list,a0

;	movea.l	Ribbons.polys_adr,a1
	lea	Ribbons.polys,a1

	movea.l	a1,a6
	move.w	(a1)+,d7
	ble	.end
	subq.w	#1,d7
	lea	Ribbons.transformed_object+2,a2

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
	sub.l	#Ribbons.poly_sort_list,d7
	lsr.w	#2,d7
	move.w	d7,Ribbons.num_sorted_polys
	subq.w	#1,d7
	beq.s	.endcombsort
	bmi	.end
	lea	Ribbons.poly_sort_list,a0
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

Ribbons.poly_sort_list:
	ds.w	2*Ribbons.MAX_POLYS		; (poly offset, z_sum)
Ribbons.num_sorted_polys:
	ds.w	1

Ribbons.paint_sorted_polys:
	lea	Ribbons.poly_sort_list(pc),a3

	;lea	rts(pc),a4
	;lea	paint_flatfragment_fat(pc),a4
	lea	paint_flatfragment_fat_opt,a4
	;lea	paint_flatfragment_slim(pc),a4

	lea	Polygon.invTable,a5
	move.w	Ribbons.num_sorted_polys(pc),d7
	beq	.end_loop
	subq.w	#1,d7
;	clr.l	vis_flags

.loop:	move.w	(a3),d0
	addq	#4,a3
	lea	Ribbons.polys,a1
	adda.w	d0,a1
	
	move.w	(a1)+,d0			; d0.w=plane index
	add.w	d0,d0				; d0.w=plane offset
	movea.l	scr,a0
	adda.w	d0,a0
	move.l	a0,Lib3D.screenadr

	lea	Ribbons.transformed_object+2,a2
	lea	Ribbons.temp_poly(pc),a0
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
	lea	Ribbons.temp_poly(pc),a0
	jsr	paint_flat_poly
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

	endc

Ribbons.paint_polys:
	lea	Ribbons.polys,a1

	;lea	rts(pc),a4
	;lea	paint_flatfragment_fat(pc),a4
	lea	paint_flatfragment_fat_opt,a4
	;lea	paint_flatfragment_slim(pc),a4

	lea	Polygon.invTable,a5

	move.w	(a1)+,d7
	beq	.end_loop
	subq.w	#1,d7
;	clr.l	vis_flags

.loop:	move.w	(a1)+,d0			; d0.w=plane index
	add.w	d0,d0				; d0.w=plane offset
	movea.l	scr,a0
	adda.w	d0,a0
	move.l	a0,Lib3D.screenadr

	lea	Ribbons.transformed_object+2,a2
	lea	Ribbons.temp_poly(pc),a0
	move.w	(a1)+,d6
	move.w	d6,(a0)+
	subq.w	#1,d6
	movea.w	d6,a6
	movea.l	a0,a3

.vloop:	move.w	(a1)+,d0
	add.w	d0,d0				; d0.w=2i
	move.w	d0,d1				; d1.w=2i
	add.w	d0,d0				; d0.w=4i
	add.w	d1,d0				; d0.w=2i+4i=6i
	move.l	(a2,d0.w),(a0)+
	dbf	d6,.vloop

	movem.w	Ribbons.temp_poly+2(pc),d0-d5		; d0.w=x1, d1.w=y1, d2.w=x2, d3.w=y2, d4.w=x3, d5.w=y3
	sub.w	d2,d0				; d0.w=x1-x2
	sub.w	d3,d1				; d1.w=y1-y2
	sub.w	d2,d4				; d4.w=x3-x2
	sub.w	d3,d5				; d5.w=y3-y2
	muls.w	d1,d4				; d4.l=(x3-x2)(y1-y2)
	muls.w	d0,d5				; d5.l=(x1-x2)(y3-y2)
	sub.l	d4,d5
	bpl.s	.paint_clockwise

	lea	Ribbons.temp_poly3(pc),a3
	move.w	a6,d6
	addq.w	#1,a6
	move.w	a6,(a3)+
.rev_loop:
	move.l	-(a0),(a3)+
	dbf	d6,.rev_loop
	lea	Ribbons.temp_poly3(pc),a0
	bra.s	.paint

.paint_clockwise:
	lea	Ribbons.temp_poly(pc),a0

.paint:	movem.l	d7/a1,-(sp)
	jsr	paint_flat_poly
	movem.l	(sp)+,d7/a1

.next_poly:
	dbf	d7,.loop
.end_loop:
	rts

;--------------------------------------------------------------------------

	data

	ifeq	Ribbons.DYNAMIC_PI1
Ribbons.girl:
	;incbin	ribbons2.pi1
	;incbin	ribbons3.pi1
	;incbin	ribbons4.pi1
	incbin	girl.dat
	endc

Ribbons.girlpic_name:
	dc.b	"ribbons4.pi1",0
	even

Ribbons.polys:
	dc.w	12345
idx	set	0
	rept	15
	dc.w	0,4,idx+0,idx+1,idx+3,idx+2
idx	set	idx+2
	dc.w	0,4,idx+0,idx+1,idx+3,idx+2
idx	set	idx+2
	dc.w	0,4,idx+0,idx+1,idx+3,idx+2
idx	set	idx+2
	dc.w	0,4,idx+0,idx+1,idx+3,idx+2
idx	set	idx+2
	endr

;--------------------------------------------------------------------------

	bss

	ifne	Ribbons.DYNAMIC_PI1
Ribbons.girl:
	ds.b	32034
	endc

Ribbons.rot_on:
	ds.w	1
Ribbons.rot_start:
	ds.w	1
Ribbons.z_trans:
	ds.w	1
Ribbons.max_z:
	ds.w	1
Ribbons.dec_max_start:
	ds.w	1
Ribbons.dec_max_enable:
	ds.w	1

	ds.w	1			; todo: why this?

Ribbons.vertex_table:=		Lib3D.end_of_bss
;	ds.w	4*Ribbons.MAX_POLYS
Ribbons.transformed_object:=	(Ribbons.vertex_table+4*Ribbons.MAX_POLYS)
;	ds.w	1+Ribbons.MAX_VERTICES*3

; 20 segments should be ok?
;	ds.l	1
Ribbons.unclipped_ribbon:=	(Ribbons.transformed_object+2+Ribbons.MAX_VERTICES*6+4)
;	ds.l	512
;	ds.l	1
Ribbons.clipped_seg:=		(Ribbons.unclipped_ribbon+513*4)
;	ds.l	512

Ribbons.whitefade_table:
	ds.w	16*16
Ribbons.blackfade_table:
	ds.w	16*16
Ribbons.bluefade_table:
	ds.w	16*16
Ribbons.temp_table:
	ds.w	16*16

Ribbons.fade_start_time:
	ds.l	1
Ribbons.fade_steps_left:
	ds.w	1
Ribbons.fade_table_addr:
	ds.l	1
