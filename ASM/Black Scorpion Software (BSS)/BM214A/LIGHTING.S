*=======================================================*
*	Lighting module: latest update 25/03/96		*
*=======================================================*
*	Covers palette, colour & lighting processes	*
*=======================================================*
*	The contents of this module are temporary,	*
*	and should not be taken seriously. I just 	*
*	wanted to see what lighting would look like!	*
*=======================================================*

*-------------------------------------------------------*
*	Dodgey hacks to set up sector lighting		*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
set_lighting:
	move.w		frame,framelock
	rts

*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
process_lighting:
*-------------------------------------------------------*
	pushall
	move.l		display_sectorptr(a6),a0
	move.w		sector_special(a0),d2
	move.w		sector_light(a0),d1
	cmp.w		#1,d2
	beq		.off
	cmp.w		#2,d2
	beq		.rand
	cmp.w		#3,d2
	beq		.rand
	cmp.w		#4,d2
	beq		.rand
	cmp.w		#8,d2
	beq		.osc
	cmp.w		#12,d2
	beq		.sync
	cmp.w		#13,d2
	beq		.sync
	cmp.w		#17,d2
	beq		.rand
.end:	tst.w		d1
	bpl.s		.p1
	moveq		#0,d1
.p1:	cmp.w		#255,d1
	bmi.s		.ok
	move.w		#255,d1
.ok:	move.w		d1,sector_tag(a0)
	move.w		d1,brightness
	move.w		d1,d2
	move.w		d1,d3

	move.w		sky_index,d5
	cmp.w		display_ct(a6),d5
	bne.s		.no_upper_sky
	move.w		#upper_sky_lum,d2
.no_upper_sky:
	cmp.w		display_ft(a6),d5
	bne.s		.no_lower_sky
	move.w		#lower_sky_lum,d3
.no_lower_sky:

	dspwrite.b	#setluminance_command
	dspwrite.w	d1
	dspwrite.w	d2
	dspwrite.w	d3
	popall
	rts

.sync:
.off:
	move.w		framelock,d2
	lsr.w		#4,d2
	and.w		#8-1,d2
	bne		.end
	sub.w		#100,d1
	bra		.end

.rand:	move.w		framelock,d0
	and.w		#3,d0
	bne.s		.off
.osc:	move.w		d1,d0
	lsr.w		#2,d0
	sub.w		d0,d1
	lea		sine,a1
	move.w		framelock,d0
	lsl.w		#6,d0
	and.w		#sinres-1,d0
	move.w		(a1,d0.w*2),d0
	asr.w		#8,d0
	add.w		d0,d1
	bra		.end

*-------------------------------------------------------*
*	Load palette from WAD and generate coltables	*
*-------------------------------------------------------*
init_colours:
*-------------------------------------------------------*
	lea		ascii_playpal,a0
	bsr		load_resource
	tst.l		d0
	beq		err_missing
	move.l		a6,playpal_ptr
	lea		ascii_colormap,a0
	bsr		load_resource
	tst.l		d0
	beq		err_missing
	move.l		a6,colormap_ptr
	move.w		#255,redfilter
	move.w		#255,greenfilter
	move.w		#255,bluefilter
	lea		colourtables,a2
	bsr		create_palettes
	bsr		find_keycol
	bsr		create_quick_alpha
	rts

*-------------------------------------------------------*
find_keycol:
*-------------------------------------------------------*
	move.l		playpal_ptr,a0
	addq.l		#3,a0
	moveq		#0,d5
	moveq		#0,d6
	move.l		#$3FFFFFFF,d4
	move.w		#256-1-1,d7
.loop:	moveq		#0,d1
	move.b		(a0)+,d1
	moveq		#0,d2
	move.b		(a0)+,d2
	moveq		#0,d3
	move.b		(a0)+,d3
	mulu.w		d1,d1
	mulu.w		d2,d2
	mulu.w		d3,d3
	add.l		d1,d2
	add.l		d2,d3
	cmp.l		d4,d3
	bgt.s		.no
	move.l		d3,d4
	move.l		d5,d6
.no:	addq.l		#1,d5
	dbra		d7,.loop
	move.w		d6,black
	rts

*-------------------------------------------------------*
*	Generate 64 light levels of palette data	*
*-------------------------------------------------------*
create_palettes:
*-------------------------------------------------------*
	move.w		max_saturation,d0
	sub.w		saturation,d0
	add.l		#512*64,a2
	move.w		#256,d5
	moveq		#64-1,d7
.loop:	move.w		#256-1,d6
	move.l		playpal_ptr,a1
	lea		-512(a2),a2
	move.l		a2,a3
.cols:	moveq		#0,d1
	move.b		(a1)+,d1
	moveq		#0,d2
	move.b		(a1)+,d2
	moveq		#0,d3
	move.b		(a1)+,d3
	mulu.w		redfilter,d1
	mulu.w		greenfilter,d2
	mulu.w		bluefilter,d3
	lsr.l		#8,d1
	lsr.l		#8,d2
	lsr.l		#8,d3
	mulu.w		saturation,d1
	mulu.w		saturation,d2
	mulu.w		saturation,d3
	move.w		d0,d4
	mulu.w		#base_red,d4
	add.w		d4,d1
	mulu.w		d5,d1
	divu.w		max_saturation,d1		
	move.w		d0,d4
	mulu.w		#base_green,d4
	add.w		d4,d2
	mulu.w		d5,d2
	divu.w		max_saturation,d2
	move.w		d0,d4
	mulu.w		#base_blue,d4
	add.w		d4,d3
	mulu.w		d5,d3
	divu.w		max_saturation,d3
	add.w		#127,d1
	add.w		#127,d2
	add.w		#127,d3
	bfins		d1,d4{16:16}
	bfins		d2,d4{21:16}
	bfins		d3,d4{27:16}
	ifd		intel
	ror.w		#8,d4
	endc
	move.w		d4,(a3)+
	dbra		d6,.cols
	subq.w		#(256/64),d5
	dbra		d7,.loop
	rts

*-------------------------------------------------------*
*	Generate quick-alpha table			*
*-------------------------------------------------------*
create_quick_alpha:
*-------------------------------------------------------*
	lea		quick_alpha_table,a5
	move.l		#65536-1,d7
.loop:	move.w		d7,d0
	ifd		intel
	ror.w		#8,d0
	endc
	bfextu		d0{16:08},d1
	bfextu		d0{21:08},d2
	bfextu		d0{27:08},d3
	and.w		#%11111000,d1
	and.w		#%11111100,d2
	and.w		#%11111000,d3
	mulu.w		#7,d1
	mulu.w		#7,d2
	mulu.w		#7,d3
	add.w		#256,d1
	add.w		#256,d2
	add.w		#256,d3
	lsr.w		#3,d1
	lsr.w		#3,d2
	lsr.w		#3,d3
	bfins		d1,d0{16:08}
	bfins		d2,d0{21:08}
	bfins		d3,d0{27:08}
	ifd		intel
	ror.w		#8,d0
	endc
	move.w		d0,(a5,d7.l*2)
	dbra		d7,.loop
	rts

*-------------------------------------------------------*
			datlong
*-------------------------------------------------------*

max_saturation:		dc.w	256			; maximum saturation range
saturation:		dc.w	256			; actual colour saturation level

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

redfilter:		ds.w	1			; red filter 0-255
greenfilter:		ds.w	1			; green filter 0-255
bluefilter:		ds.w	1			; blue filter 0-255
black:			ds.w	1

frame:			ds.w	1			; some timing variables
framelock:		ds.w	1			; for hacked lighting effects
brightness:		ds.w	1

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
