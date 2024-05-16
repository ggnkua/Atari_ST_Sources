*=======================================================*
*	Rendering module: updated 12/06/97		*
*=======================================================*

*-------------------------------------------------------*
*	Texel u/v addressing units			*
*-------------------------------------------------------*

*-------------------------------------------------------*
*	Basic vertical u/v lookup			*
*-------------------------------------------------------*

hrun16	macro
	move.l		d3,d0
	move.w		d1,d0
	lsr.l		#6,d0
	lsr.w		#4,d0
	move.b		(a1,d0.w),d6
	add.l		d7,d3
	move.w		(a0,d6.l*2),d0
	add.w		d4,d1
	move.w		d0,(a6)+
	endm

hrun32s	macro
	move.l		d7,a4
	move.l		d3,d7
	move.w		d1,d7
	lsr.l		#6,d7
	lsr.w		#4,d7
	move.b		(a1,d7.w),d6
	add.l		a4,d3
	move.w		(a0,d6.l*2),d7
	add.w		d4,d1
	endm

hrun32	macro
	move.l		d3,d0
	move.w		d7,(a6)+
	move.w		d1,d0
	lsr.l		#6,d0
	move.w		d7,(a6)+
	lsr.w		#4,d0
	move.b		(a1,d0.w),d6
	add.l		a4,d3
	move.w		(a0,d6.l*2),d7
	add.w		d4,d1
	endm

*-------------------------------------------------------*
*	Turbulent vertical u/v lookup			*
*-------------------------------------------------------*

hturb16	macro
	move.w		d1,d0
	lsr.w		d5,d0
	move.w		(a4,d0.l*2),d0
	move.w		d3,d6
	lsr.w		d5,d6
	move.w		(a4,d6.l*2),d6
	add.w		d3,d0
	and.w		#%1111110000000000,d0
	add.w		d1,d6
	lsr.w		#6,d6
	or.w		d0,d6
	lsr.w		#4,d6
	clr.w		d0
	move.b		(a1,d6.l),d0
	add.w		d4,d1
	add.w		d7,d3
	move.w		(a0,d0.l*2),(a6)+
	endm

hturb32	macro
	move.w		d1,d0
	lsr.w		d5,d0
	move.w		(a4,d0.l*2),d0
	move.w		d3,d6
	lsr.w		d5,d6
	move.w		(a4,d6.l*2),d6
	add.w		d3,d0
	and.w		#%1111110000000000,d0
	add.w		d1,d6
	lsr.w		#6,d6
	or.w		d0,d6
	lsr.w		#4,d6
	clr.w		d0
	move.b		(a1,d6.l),d0
	add.w		d4,d1
	add.w		d7,d3
	move.w		(a0,d0.l*2),d6
	move.w		d6,(a6)+
	move.w		d6,(a6)+
	endm

*-------------------------------------------------------*
*	Linear horizontal u/v lookup			*
*-------------------------------------------------------*

srun16	macro				; 14
	move.w		d3,d0
	and.w		d4,d0
	move.b		(a1,d0.w*8),d6
	addx.l		d7,d3
	move.w		(a0,d6.l*2),(a6)+
	endm

srun32	macro
	move.w		d3,d0
	and.w		d4,d0
	move.b		(a1,d0.w*8),d6
	addx.l		d7,d3
	move.w		(a0,d6.l*2),d0
	move.w		d0,(a6)+
	move.w		d0,(a6)+
	endm

*-------------------------------------------------------*
*	Perspected 64x64 horizontal u/v lookup		*
*-------------------------------------------------------*

vrun16	macro
	and.w		d5,d4
	move.b		(a2,d4.w),d1
	addx.l		d3,d4
	move.w		(a5,d1.l*2),d0
	adda.l		a6,a0
	move.w		d0,(a0)
	endm

vrun32	macro
	and.w		d5,d4
	move.b		(a2,d4.w),d1
	addx.l		d3,d4
	move.w		(a5,d1.l*2),d0
	adda.l		a6,a0
	move.w		d0,(a0)+
	move.w		d0,(a0)
	endm

*-------------------------------------------------------*
*	Turbulent 64x64 horizontal u/v lookup		*
*-------------------------------------------------------*

vturb16	macro
	move.w		d4,d0
	lsr.w		d5,d0
	move.w		(a4,d0.l*2),d0
	move.w		d6,d7
	add.w		d4,d7
	add.w		d1,d0
	and.w		#%1111110000000000,d0
	lsr.w		#7,d7		; #6
	or.w		d0,d7
	lsr.w		#3,d7		; #4
	clr.w		d0
	move.b		(a2,d7.l),d0
	add.w		d3,d4
	adda.l		a6,a0
	move.w		(a5,d0.l*2),(a0)
	endm

vturb32	macro
	move.w		d4,d0
	lsr.w		d5,d0
	move.w		(a4,d0.l*2),d0
	move.w		d6,d7
	add.w		d4,d7
	add.w		d1,d0
	and.w		#%1111110000000000,d0
	lsr.w		#7,d7		; #6
	or.w		d0,d7
	lsr.w		#3,d7		; #4
	clr.w		d0
	move.b		(a2,d7.l),d0
	add.w		d3,d4
	move.w		(a5,d0.l*2),d7
	adda.l		a6,a0
	move.w		d7,(a0)+
	move.w		d7,(a0)
	endm

*-------------------------------------------------------*
*	Transparent vertical u/v lookup			*
*-------------------------------------------------------*

tvrs16	macro
	and.w		d5,d4
	move.b		(a2,d4.w),d1
	adda.l		a6,a0
	ifd		m68040
	beq.s		.cs_\1
	bra.s		.cw_\1
	elseif
	bne.s		.cw_\1
	endc
.cs_\1:	addx.l		d3,d4
	endm

tvrw16	macro
	and.w		d5,d4
	move.b		(a2,d4.w),d1
	adda.l		a6,a0
	ifd		m68040
	bne.s		.cw_\1
	bra.s		.cs_\1
	elseif
	beq.s		.cs_\1
	endc
.cw_\1:	move.w		(a5,d1.l*2),(a0)
	addx.l		d3,d4
	endm

tvrw32	macro
	and.w		d5,d4
	move.b		(a2,d4.w),d1
	adda.l		a6,a0
	ifd		m68040
	bne.s		.cw_\1
	bra.s		.cs_\1
	elseif
	beq.s		.cs_\1
	endc
.cw_\1:	move.w		(a5,d1.l*2),d0
	addx.l		d3,d4
	move.w		d0,(a0)
	move.w		d0,2(a0)
	endm

*-------------------------------------------------------*
*	Alpha channeling vertical u/v lookup		*
*-------------------------------------------------------*

avrun16	macro				; 10
	move.w		(a0,a6.l),d1
	adda.l		a6,a0
	move.w		(a5,d1.l*2),(a0)
	endm

avrun32	macro				; 14
	move.w		(a0,a6.l),d1
	adda.l		a6,a0
	move.w		(a5,d1.l*2),d1
	move.w		d1,(a0)+
	move.w		d1,(a0)+
	endm

*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
*	Render the floors & ceilings			*
*-------------------------------------------------------*
render_flats:
*-------------------------------------------------------*
	tst.b		halfrows
	bne		render_flats_2x1

*-------------------------------------------------------*
render_flats_1x1:
*-------------------------------------------------------*
	lea		DSPHost16.w,a4
	lea		DSPHostStat.w,a5
*-------------------------------------------------------*
	moveq		#rotatemap_command,d0
	dspwaitwrite.0	(a5)
	move.b		d0,1(a4)
*-------------------------------------------------------*
	move.l		screen,.local_screen
	lea		zone_space,a3
*-------------------------------------------------------*
*	Zone loop					*
*-------------------------------------------------------*
.zone_loop:
*-------------------------------------------------------*
	clr.l		d4
	move.b		(a3)+,d4			; [zone_lines]
	clr.l		d0
	subq.w		#1,d4
	bmi		.last_zone
*-------------------------------------------------------*
*	Decode map type (scale, perspect or warp)	*
*-------------------------------------------------------*
	move.b		(a3)+,d0			; [zone_texture]
	cmp.w		sky_index,d0
	beq		.linear_chunk

	tst.b		turbulence_on
	beq.b		.normal_chunk

	cmp.w		waste_index,d0
	beq		.turbulent_chunk
	cmp.w		water_index,d0
	beq		.turbulent_chunk
	cmp.w		slime_index,d0
	beq		.turbulent_chunk
	cmp.w		lava_index,d0
	beq		.turbulent_chunk
	cmp.w		blood_index,d0
	beq		.turbulent_chunk
*-------------------------------------------------------*
.normal_chunk:	
*-------------------------------------------------------*
	bsr		cache_resource
	move.l		d0,a1
	move.w		(a3)+,d0			; [zone_start]
	move.l		.local_screen(pc),a2
	mulu.w		bytewidth,d0
	add.l		d0,a2
*-------------------------------------------------------*
.pline_loop:
*-------------------------------------------------------*
	move.w		(a3)+,d2			; [line_runs]
	swap		d4
	subq.w		#1,d2
	bmi		.pnull_line
*-------------------------------------------------------*
.prun_loop:
*-------------------------------------------------------*
	dspwaitread.0	(a5)
	move.w		(a4),d7				; map_xi
	dspwaitread.1	(a5)
	move.w		(a4),d3				; map_x
	dspwaitread.1	(a5)
	move.w		(a4),d4				; map_yi
	dspwaitread.1	(a5)
	move.w		(a4),d1				; map_y
	dspwaitread.1	(a5)
	move.w		(a4),d6				; x1
*-------------------------------------------------------*
*	Render flat run					*
*-------------------------------------------------------*
	lea		colourtables,a0
	moveq		#0,d0
	lsl.l		#6,d3
	move.w		(a3)+,d0
	swap		d2
	lsl.l		#6,d7
	lsl.l		#8,d0
	move.w		(a3)+,d2
	add.l		d0,d0
	add.l		d0,a0
	sub.w		d6,d2
	lea		(a2,d6.w*2),a6
	moveq		#4-1,d0
	and.w		d2,d0
	lsr.w		#2,d2				; dx{loop}
*-------------------------------------------------------*
*	Flat-rendering instruction tower		*
*-------------------------------------------------------*
	moveq		#0,d6
	jmp		.pdx_l(pc,d0.l*2)		; index instruction tower
.pdx_l:	bra.s		.o00
	bra.s		.o01
	bra.s		.o02
	bra.s		.o03
.o04	hrun16
.o03	hrun16
.o02	hrun16
.o01	hrun16
.o00	dbra		d2,.o04
*-------------------------------------------------------*
.o0d:	swap		d2
	dbra		d2,.prun_loop
*-------------------------------------------------------*
.pnull_line:
*-------------------------------------------------------*
	add.w		bytewidth,a2
	swap		d4
	dbra		d4,.pline_loop
*-------------------------------------------------------*
	bra		.zone_loop
*-------------------------------------------------------*
.turbulent_chunk:	
*-------------------------------------------------------*
	bsr		cache_resource
	move.l		d0,a1
	move.w		(a3)+,d0			; [zone_start]
	move.l		.local_screen(pc),a2
	mulu.w		bytewidth,d0
	add.l		d0,a2
*-------------------------------------------------------*
.tline_loop:
*-------------------------------------------------------*
	move.w		(a3)+,d2			; [line_runs]
	swap		d4
	subq.w		#1,d2
	bmi		.tnull_line
*-------------------------------------------------------*
.trun_loop:
*-------------------------------------------------------*
	dspwaitread.0	(a5)
	move.w		(a4),d7				; map_xi
	dspwaitread.1	(a5)
	move.w		(a4),d3				; map_x
	dspwaitread.1	(a5)
	move.w		(a4),d4				; map_yi
	dspwaitread.1	(a5)
	move.w		(a4),d1				; map_y
	dspwaitread.1	(a5)
	move.w		(a4),d6				; x1
*-------------------------------------------------------*
	lea		colourtables,a0
	moveq		#0,d0
	move.w		(a3)+,d0
	swap		d2
	lea		(a2,d6.w*2),a6
	lsl.l		#8,d0
	move.w		(a3)+,d2
	add.l		d0,d0
	add.l		d0,a0
	move.l		turb_ptr,a4
	sub.w		d6,d2
	moveq		#2-1,d0
	and.w		d2,d0
	lsr.w		#1,d2				; dx{loop}
*-------------------------------------------------------*
*	Flat-rendering instruction tower		*
*-------------------------------------------------------*
	moveq		#10,d5
	moveq		#0,d6
	jmp		.tdx_l(pc,d0.l*2)		; index instruction tower
.tdx_l:	bra.s		.t00
	bra.s		.t01
.t02:	hturb16
.t01:	hturb16
.t00:	dbra		d2,.t02
	lea		DSPHost16.w,a4
	swap		d2
	dbra		d2,.trun_loop
*-------------------------------------------------------*
.tnull_line:
*-------------------------------------------------------*
	add.w		bytewidth,a2
	swap		d4
	dbra		d4,.tline_loop
*-------------------------------------------------------*
	bra		.zone_loop
*-------------------------------------------------------*
.linear_chunk:	
*-------------------------------------------------------*
	move.l		#.err,d5
	move.w		current_sky,d0
	bmi.s		.err
	bsr		cache_resource
	move.l		d0,d5
*-------------------------------------------------------*
.err:	move.l		sky_xi(pc),d7			; sxi
	lea		colourtables+63*(2*256),a0
	moveq		#0,d0
	move.w		(a3)+,d0			; [zone_start]
	move.l		.local_screen(pc),a2
	move.l		d0,d1
	mulu.w		bytewidth,d0
	swap		d7
	add.l		d0,a2
*-------------------------------------------------------*
.sline_loop:
*-------------------------------------------------------*
	move.w		(a3)+,d2			; [line_runs]
	swap		d4
	subq.w		#1,d2
	bmi		.snull_line
*-------------------------------------------------------*
.srun_loop:
*-------------------------------------------------------*
	addq.l		#2,a3
	lea		1(a4),a1
	dspwaitread.0	(a5)
	tst.b		(a1)				; map_xi
	dspwaitread.1	(a5)
	tst.b		(a1)				; map_x
	dspwaitread.1	(a5)
	tst.b		(a1)				; map_yi
	dspwaitread.1	(a5)
	tst.b		(a1)				; map_y	
	dspwaitread.1	(a5)
	move.w		(a4),d6				; x1
*-------------------------------------------------------*
	move.l		d1,d0
	mulu.l		sky_yi(pc),d0
	move.l		d5,a1
	add.l		sky_ys(pc),d0
	moveq		#128-1,d3
	clr.w		d0
	swap		d0
	and.l		d3,d0
	add.l		d0,a1
*-------------------------------------------------------*
	moveq		#0,d3
	move.w		d6,d3
	swap		d7
	mulu.l		d7,d3
	add.l		sky_xs(pc),d3
	swap		d7
	move.w		sky_width(pc),d4
	swap		d3
*-------------------------------------------------------*
*	Render flat run					*
*-------------------------------------------------------*
	swap		d2
	move.w		(a3)+,d2
*-------------------------------------------------------*
	lea		(a2,d6.w*2),a6
*-------------------------------------------------------*
	sub.w		d6,d2
	moveq		#4-1,d0
	and.w		d2,d0
	lsr.w		#2,d2				; dx{loop}
	move.w		d3,d6
	add.l		d7,d3
	move.w		d6,d3
*-------------------------------------------------------*
*	Flat-rendering instruction tower		*
*-------------------------------------------------------*
	moveq		#0,d6
	jmp		.sdx_l(pc,d0.l*2)		; index instruction tower
.sdx_l:	bra.s		.o10
	bra.s		.o11
	bra.s		.o12
	bra.s		.o13
.o14	srun16
.o13	srun16
.o12	srun16
.o11	srun16
.o10	dbra		d2,.o14
*-------------------------------------------------------*
	swap		d2
	dbra		d2,.srun_loop
*-------------------------------------------------------*
.snull_line:
*-------------------------------------------------------*
	add.w		bytewidth,a2
	addq.l		#1,d1
	swap		d4
	dbra		d4,.sline_loop
*-------------------------------------------------------*
	bra		.zone_loop
*-------------------------------------------------------*
.last_zone:
*-------------------------------------------------------*
.stop:	rts
	
*-------------------------------------------------------*
*	Local variables					*
*-------------------------------------------------------*
.local_screen:		ds.l	1
*-------------------------------------------------------*

*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
render_flats_2x1:
*-------------------------------------------------------*
	lea		DSPHost16.w,a4
	lea		DSPHostStat.w,a5
*-------------------------------------------------------*
	moveq		#rotatemap_command,d0
	dspwaitwrite.0	(a5)
	move.b		d0,1(a4)
*-------------------------------------------------------*
	move.l		screen,.local_screen
	lea		zone_space,a3
*-------------------------------------------------------*
*	Zone loop					*
*-------------------------------------------------------*
.zone_loop:
*-------------------------------------------------------*
	clr.l		d4
	move.b		(a3)+,d4			; [zone_lines]
	clr.l		d0
	subq.w		#1,d4
	bmi		.last_zone
*-------------------------------------------------------*
*	Decode map type (scale, perspect or warp)	*
*-------------------------------------------------------*
	move.b		(a3)+,d0			; [zone_texture]
	cmp.w		sky_index,d0
	beq		.linear_chunk

	tst.b		turbulence_on
	beq.b		.normal_chunk

	cmp.w		waste_index,d0
	beq		.turbulent_chunk
	cmp.w		water_index,d0
	beq		.turbulent_chunk
	cmp.w		slime_index,d0
	beq		.turbulent_chunk
	cmp.w		lava_index,d0
	beq		.turbulent_chunk
	cmp.w		blood_index,d0
	beq		.turbulent_chunk
*-------------------------------------------------------*
.normal_chunk:	
*-------------------------------------------------------*
	bsr		cache_resource
	move.l		d0,a1
	move.w		(a3)+,d0			; [zone_start]
	move.l		.local_screen(pc),a2
	mulu.w		bytewidth,d0
	add.l		d0,a2
*-------------------------------------------------------*
.pline_loop:
*-------------------------------------------------------*
	move.w		(a3)+,d2			; [line_runs]
	swap		d4
	subq.w		#1,d2
	bmi		.pnull_line
*-------------------------------------------------------*
.prun_loop:
*-------------------------------------------------------*
	dspwaitread.0	(a5)
	move.w		(a4),d7				; map_xi
	dspwaitread.1	(a5)
	move.w		(a4),d3				; map_x
	dspwaitread.1	(a5)
	move.w		(a4),d4				; map_yi
	dspwaitread.1	(a5)
	move.w		(a4),d1				; map_y
	dspwaitread.1	(a5)
	move.w		(a4),d6				; x1
*-------------------------------------------------------*
*	Render flat run					*
*-------------------------------------------------------*
	lea		colourtables,a0
	moveq		#0,d0
	lsl.l		#6,d3
	move.w		(a3)+,d0
	swap		d2
	lsl.l		#6,d7
	lsl.l		#8,d0
	move.w		(a3)+,d2
	add.l		d0,d0
	add.l		d0,a0
	lea		(a2,d6.w*4),a6
	addq.w		#1,d6
	sub.w		d6,d2
	moveq		#4-1,d0
	and.w		d2,d0
	lsr.w		#2,d2				; dx{loop}
*-------------------------------------------------------*
*	Flat-rendering instruction tower		*
*-------------------------------------------------------*
	moveq		#0,d6
	hrun32s
	jmp		.pdx_l(pc,d0.l*2)		; index instruction tower
.pdx_l:	bra.s		.p10
	bra.s		.p11
	bra.s		.p12
	bra.s		.p13
.p14:	hrun32
.p13:	hrun32
.p12:	hrun32
.p11:	hrun32
.p10:	dbra		d2,.p14
	lea		DSPHost16.w,a4
	move.w		d7,(a6)+
	move.w		d7,(a6)+
*-------------------------------------------------------*
	swap		d2
	dbra		d2,.prun_loop
*-------------------------------------------------------*
.pnull_line:
*-------------------------------------------------------*
	add.w		bytewidth,a2
	swap		d4
	dbra		d4,.pline_loop
*-------------------------------------------------------*
	bra		.zone_loop
*-------------------------------------------------------*
.turbulent_chunk:	
*-------------------------------------------------------*
	bsr		cache_resource
	move.l		d0,a1
	move.w		(a3)+,d0			; [zone_start]
	move.l		.local_screen(pc),a2
	mulu.w		bytewidth,d0
	add.l		d0,a2
*-------------------------------------------------------*
.tline_loop:
*-------------------------------------------------------*
	move.w		(a3)+,d2			; [line_runs]
	swap		d4
	subq.w		#1,d2
	bmi		.tnull_line
*-------------------------------------------------------*
.trun_loop:
*-------------------------------------------------------*
	dspwaitread.0	(a5)
	move.w		(a4),d7				; map_xi
	dspwaitread.1	(a5)
	move.w		(a4),d3				; map_x
	dspwaitread.1	(a5)
	move.w		(a4),d4				; map_yi
	dspwaitread.1	(a5)
	move.w		(a4),d1				; map_y
	dspwaitread.1	(a5)
	move.w		(a4),d6				; x1
*-------------------------------------------------------*
	lea		colourtables,a0
	moveq		#0,d0
	move.w		(a3)+,d0
	swap		d2
	lea		(a2,d6.w*4),a6
	lsl.l		#8,d0
	move.w		(a3)+,d2
	add.l		d0,d0
	add.l		d0,a0
	move.l		turb_ptr,a4
	sub.w		d6,d2
	moveq		#2-1,d0
	and.w		d2,d0
	lsr.w		#1,d2				; dx{loop}
*-------------------------------------------------------*
*	Flat-rendering instruction tower		*
*-------------------------------------------------------*
	moveq		#10,d5
	moveq		#0,d6
	jmp		.tdx_l(pc,d0.l*2)		; index instruction tower
.tdx_l:	bra.s		.t00
	bra.s		.t01
.t02:	hturb32
.t01:	hturb32
.t00:	dbra		d2,.t02
	lea		DSPHost16.w,a4
	swap		d2
	dbra		d2,.trun_loop
*-------------------------------------------------------*
.tnull_line:
*-------------------------------------------------------*
	add.w		bytewidth,a2
	swap		d4
	dbra		d4,.tline_loop
*-------------------------------------------------------*
	bra		.zone_loop
*-------------------------------------------------------*
.linear_chunk:	
*-------------------------------------------------------*
	move.l		#.err,d5
	move.w		current_sky,d0
	bmi.s		.err
	bsr		cache_resource
	move.l		d0,d5
*-------------------------------------------------------*
.err:	move.l		sky_xi(pc),d7				; sxi
	lea		colourtables+63*(2*256),a0
	moveq		#0,d0
	move.w		(a3)+,d0			; [zone_start]
	move.l		.local_screen(pc),a2
	move.l		d0,d1
	mulu.w		bytewidth,d0
	swap		d7
	add.l		d0,a2
*-------------------------------------------------------*
.sline_loop:
*-------------------------------------------------------*
	move.w		(a3)+,d2			; [line_runs]
	swap		d4
	subq.w		#1,d2
	bmi		.snull_line
*-------------------------------------------------------*
.srun_loop:
*-------------------------------------------------------*
	addq.l		#2,a3
	lea		1(a4),a1
	dspwaitread.0	(a5)
	tst.b		(a1)				; map_xi
	dspwaitread.1	(a5)
	tst.b		(a1)				; map_x
	dspwaitread.1	(a5)
	tst.b		(a1)				; map_yi
	dspwaitread.1	(a5)
	tst.b		(a1)				; map_y	
	dspwaitread.1	(a5)
	move.w		(a4),d6				; x1
*-------------------------------------------------------*
	move.l		d1,d0
	mulu.l		sky_yi(pc),d0
	move.l		d5,a1
	add.l		sky_ys(pc),d0
	moveq		#128-1,d3
	clr.w		d0
	swap		d0
	and.l		d3,d0
	add.l		d0,a1
*-------------------------------------------------------*
	moveq		#0,d3
	move.w		d6,d3
	swap		d7
	mulu.l		d7,d3
	add.l		sky_xs(pc),d3
	swap		d7
	move.w		sky_width(pc),d4
	swap		d3
*-------------------------------------------------------*
*	Render flat run					*
*-------------------------------------------------------*
	swap		d2
	move.w		(a3)+,d2
*-------------------------------------------------------*
	lea		(a2,d6.w*4),a6
*-------------------------------------------------------*
	moveq		#4-1,d0
	sub.w		d6,d2
	and.w		d2,d0
	lsr.w		#2,d2				; dx{loop}
*-------------------------------------------------------*
	move.w		d3,d6
	add.l		d7,d3
	move.w		d6,d3
*-------------------------------------------------------*
*	Flat-rendering instruction tower		*
*-------------------------------------------------------*
	moveq		#0,d6
	jmp		.sdx_l(pc,d0.l*2)		; index instruction tower
.sdx_l:	bra.s		.s10
	bra.s		.s11
	bra.s		.s12
	bra.s		.s13
.s14:	srun32
.s13:	srun32
.s12:	srun32
.s11:	srun32
.s10:	dbra		d2,.s14
	lea		DSPHost16.w,a4
*-------------------------------------------------------*
	swap		d2
	dbra		d2,.srun_loop
*-------------------------------------------------------*
.snull_line:
*-------------------------------------------------------*
	add.w		bytewidth,a2
	addq.l		#1,d1
	swap		d4
	dbra		d4,.sline_loop
*-------------------------------------------------------*
	bra		.zone_loop
*-------------------------------------------------------*
.last_zone:
*-------------------------------------------------------*
.stop:	rts

*-------------------------------------------------------*
*	Local variables					*
*-------------------------------------------------------*
.local_screen:		ds.l	1
*-------------------------------------------------------*

*-------------------------------------------------------*
render_wall:
*-------------------------------------------------------*
	cmp.w		#texcode_none,gbl_seg_tex(a6)
	beq		flush_badwall
	cmp.w		#texcode_sky,gbl_seg_tex(a6)
	beq		flush_badwall
*-------------------------------------------------------*
	tst.b		gbl_seg_opaque(a6)
	bne		stack_transparent
*-------------------------------------------------------*
	moveq		#0,d0
	move.w		gbl_seg_tex(a6),d0
	bmi.s		.err
	bsr		cache_resource
	move.l		d0,d6
.err:	move.l		screen,a4
	move.w		#128-1,d5
	lea		DSPHost16.w,a1
	lea		DSPHostStat.w,a3
*-------------------------------------------------------*
	tst.b		halfrows
	bne		render_wall_2x1

*-------------------------------------------------------*
render_wall_1x1:
*-------------------------------------------------------*
	tst.b		turbulence_on
	beq.s		.cont
	move.w		gbl_seg_tex(a6),d0
	cmp.w		warp_index,d0
	beq		render_wall_1x1_warp
*-------------------------------------------------------*
.cont:	move.w		bytewidth,a6
	sub.l		a6,a4
*-------------------------------------------------------*
	dspwaitread.0	(a3)
	move.w		(a1),d3				; i (screen)
	bmi		.dsp_done
*-------------------------------------------------------*
.next:	clr.l		d1
	dspwaitread.0	(a3)
	move.w		(a1),d1				; j1j2
	lea		colourtables,a5
	lea		(a4,d3.w*2),a0			; address screen (i)
	clr.l		d2
	move.b		d1,d2				; j2 (screen/bot)
	lsr.w		#8,d1				; j1 (screen/top)
	sub.w		d1,d2				; dj (height)
	mulu.w		bytewidth,d1
	dspwaitread.0	(a3)
	move.w		(a1),d4				; z
	lea		(a5,d4.w*8),a5			; address luminance table
	moveq		#0,d4
	dspwaitread.1	(a3)
	move.w		(a1),d4				; u (texture)
	move.l		d6,a2
	add.l		d4,a2				; address u (texture)
	dspwaitread.1	(a3)
	move.l		-2(a1),d3			; dv[i:f] (texture)
	moveq		#0,d4
	swap		d3
	ext.w		d3
	add.l		d1,a0
	dspwaitread.1	(a3)
	move.w		(a1),d4				; v (texture)
*-------------------------------------------------------*
*	Calculate tower index & interations		*
*-------------------------------------------------------*
	moveq		#4-1,d0
	and.w		d2,d0				; index = remainder(4)
	lsr.w		#2,d2				; loopsize / 4
*-------------------------------------------------------*
*	Preload carry for cascading adder		*
*-------------------------------------------------------*
	lsl.l		#8,d4
	swap		d4
	move.w		d4,d1				; store v[i]
	add.l		d3,d4				; v[i:f]=v[i:f]+dv[i:f]
	move.w		d1,d4				; restore v[i]
*-------------------------------------------------------*
*	Execute instruction tower			*
*-------------------------------------------------------*
	clr.l		d1
	jmp		.dx_l(pc,d0.l*2)		; jump -> index * -16
.dx_l:	bra.s		.w00
	bra.s		.w01
	bra.s		.w02
	bra.s		.w03
.w04:	vrun16
.w03:	vrun16
.w02:	vrun16
.w01:	vrun16
.w00:	dbra		d2,.w04
*-------------------------------------------------------*
	dspwaitread.0	(a3)
	move.w		(a1),d3				; i (screen)
	bpl		.next
*-------------------------------------------------------*
.dsp_done:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
render_wall_1x1_warp:
*-------------------------------------------------------*
	move.w		bytewidth,a6
	sub.l		a6,a4
*-------------------------------------------------------*
	dspwaitread.0	(a3)
	move.w		(a1),d3				; i (screen)
	bmi		.dsp_done
*-------------------------------------------------------*
.next:	moveq		#0,d1
	dspwaitread.0	(a3)
	move.w		(a1),d1				; j1j2
	lea		colourtables,a5
	lea		(a4,d3.w*2),a0			; address screen (i)
	moveq		#0,d2
	move.b		d1,d2				; j2 (screen/bot)
	lsr.w		#8,d1				; j1 (screen/top)
	sub.w		d1,d2				; dj (height)
	mulu.w		bytewidth,d1	****
	add.l		d1,a0
	dspwaitread.0	(a3)
	move.w		(a1),d4				; z
	lea		(a5,d4.w*8),a5			; address luminance table
	moveq		#0,d4
	dspwaitread.1	(a3)
	move.w		(a1),d4				; u (texture)
	move.l		d6,a2
	move.w		d4,d1
	lsr.w		#7,d1
	dspwaitread.1	(a3)
	move.l		-2(a1),d3			; dv[i:f] (texture)
	lsl.w		#10-8,d1
	lsl.w		#8,d1
	lsr.l		#6,d3	
	moveq		#0,d4
	dspwaitread.1	(a3)
	move.w		(a1),d4				; v (texture)
*-------------------------------------------------------*
*	Calculate tower index & interations		*
*-------------------------------------------------------*
	moveq		#2-1,d0
	and.w		d2,d0				; index = remainder(4)
	lsr.w		#1,d2				; loopsize / 4
*-------------------------------------------------------*
	lsl.w		#2,d4
*-------------------------------------------------------*
*	Execute instruction tower			*
*-------------------------------------------------------*
	push.l		a4
	push.l		d6
*-------------------------------------------------------*
	move.l		turb_ptr,a4
	moveq		#10,d5
	move.w		d1,d7
	lsr.w		d5,d7
	move.w		(a4,d7.l*2),d6
*-------------------------------------------------------*
	clr.l		d7
	jmp		.dx_l(pc,d0.l*2)		; jump -> index * -16
.dx_l:	bra.s		.w00
	bra.s		.w01
.w02:	vturb16
.w01:	vturb16
.w00:	dbra		d2,.w02
*-------------------------------------------------------*
	pop.l		d6
	pop.l		a4
*-------------------------------------------------------*
	dspwaitread.0	(a3)
	move.w		(a1),d3				; i (screen)
	bpl		.next
*-------------------------------------------------------*
.dsp_done:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
render_wall_2x1:
*-------------------------------------------------------*
	tst.b		turbulence_on
	beq.s		.cont
	move.w		gbl_seg_tex(a6),d0
	cmp.w		warp_index,d0
	beq		render_wall_2x1_warp
*-------------------------------------------------------*
.cont:	move.w		bytewidth,a6
	subq.l		#2,a6
	sub.l		a6,a4
*-------------------------------------------------------*
	dspwaitread.0	(a3)
	move.w		(a1),d3				; i (screen)
	bmi		.dsp_done
*-------------------------------------------------------*
.next:	clr.l		d1
	dspwaitread.0	(a3)
	move.w		(a1),d1				; j1j2
	lea		colourtables,a5
	lea		(a4,d3.w*4),a0			; address screen (i)
	clr.l		d2
	move.b		d1,d2				; j2 (screen/bot)
	lsr.w		#8,d1				; j1 (screen/top)
	sub.w		d1,d2				; dj (height)
	mulu.w		bytewidth,d1
	dspwaitread.0	(a3)
	move.w		(a1),d4				; z
	lea		(a5,d4.w*8),a5			; address luminance table
	moveq		#0,d4
	dspwaitread.1	(a3)
	move.w		(a1),d4				; u (texture)
	move.l		d6,a2
	add.l		d4,a2				; address u (texture)
	dspwaitread.1	(a3)
	move.l		-2(a1),d3			; dv[i:f] (texture)
	moveq		#0,d4
	swap		d3
	ext.w		d3
	add.l		d1,a0
	dspwaitread.1	(a3)
	move.w		(a1),d4				; v (texture)
*-------------------------------------------------------*
*	Calculate tower index & interations		*
*-------------------------------------------------------*
	moveq		#4-1,d0
	and.w		d2,d0				; index = remainder(4)
	lsr.w		#2,d2				; loopsize / 4
*-------------------------------------------------------*
*	Preload carry for cascading adder		*
*-------------------------------------------------------*
	lsl.l		#8,d4
	swap		d4
	move.w		d4,d1				; store v[i]
	add.l		d3,d4				; v[i:f]=v[i:f]+dv[i:f]
	move.w		d1,d4				; restore v[i]
*-------------------------------------------------------*
*	Execute instruction tower			*
*-------------------------------------------------------*
	clr.l		d1
	jmp		.dx_l(pc,d0.l*2)		; jump -> index * -16
.dx_l:	bra.s		.w10
	bra.s		.w11
	bra.s		.w12
	bra.s		.w13
.w14:	vrun32
.w13:	vrun32
.w12:	vrun32
.w11:	vrun32
.w10:	dbra		d2,.w14
*-------------------------------------------------------*
	dspwaitread.0	(a3)
	move.w		(a1),d3				; i (screen)
	bpl		.next
*-------------------------------------------------------*
.dsp_done:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
render_wall_2x1_warp:
*-------------------------------------------------------*
	move.w		bytewidth,a6
	subq.l		#2,a6
	sub.l		a6,a4
*-------------------------------------------------------*
	dspwaitread.0	(a3)
	move.w		(a1),d3				; i (screen)
	bmi		.dsp_done
*-------------------------------------------------------*
.next:	moveq		#0,d1
	dspwaitread.0	(a3)
	move.w		(a1),d1				; j1j2
	lea		colourtables,a5
	lea		(a4,d3.w*4),a0			; address screen (i)
	moveq		#0,d2
	move.b		d1,d2				; j2 (screen/bot)
	lsr.w		#8,d1				; j1 (screen/top)
	sub.w		d1,d2				; dj (height)
	mulu.w		bytewidth,d1	****
	add.l		d1,a0
	dspwaitread.0	(a3)
	move.w		(a1),d4				; z
	lea		(a5,d4.w*8),a5			; address luminance table
	moveq		#0,d4
	dspwaitread.1	(a3)
	move.w		(a1),d4				; u (texture)
	move.l		d6,a2
	move.w		d4,d1
	lsr.w		#7,d1
	dspwaitread.1	(a3)
	move.l		-2(a1),d3			; dv[i:f] (texture)
	lsl.w		#10-8,d1
	lsl.w		#8,d1
	lsr.l		#6,d3	
	moveq		#0,d4
	dspwaitread.1	(a3)
	move.w		(a1),d4				; v (texture)
*-------------------------------------------------------*
*	Calculate tower index & interations		*
*-------------------------------------------------------*
	moveq		#2-1,d0
	and.w		d2,d0				; index = remainder(4)
	lsr.w		#1,d2				; loopsize / 4
*-------------------------------------------------------*
	lsl.w		#2,d4
*-------------------------------------------------------*
*	Execute instruction tower			*
*-------------------------------------------------------*
	push.l		a4
	push.l		d6
*-------------------------------------------------------*
	move.l		turb_ptr,a4
	moveq		#10,d5
	move.w		d1,d7
	lsr.w		d5,d7
	move.w		(a4,d7.l*2),d6
*-------------------------------------------------------*
	clr.l		d7
	jmp		.dx_l(pc,d0.l*2)		; jump -> index * -16
.dx_l:	bra.s		.w00
	bra.s		.w01
.w02:	vturb32
.w01:	vturb32
.w00:	dbra		d2,.w02
*-------------------------------------------------------*
	pop.l		d6
	pop.l		a4
*-------------------------------------------------------*
	dspwaitread.0	(a3)
	move.w		(a1),d3				; i (screen)
	bpl		.next
*-------------------------------------------------------*
.dsp_done:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
render_transparent:
*-------------------------------------------------------*
	
	move.l		screen,a4
	move.w		#128-1,d5

	tst.b		halfrows
	bne		render_transparent_2x1

*-------------------------------------------------------*
render_transparent_1x1:
*-------------------------------------------------------*
	move.w		bytewidth,a6
*-------------------------------------------------------*
	move.l		transparent_array,a3
	move.w		transparent_count,d7
	subq.w		#1,d7
	bmi		.err
*-------------------------------------------------------*
.wall_loop:
*-------------------------------------------------------*
	swap		d7
	move.w		-(a3),d7
*-------------------------------------------------------*
*	Case #1 - masked transparent			*
*-------------------------------------------------------*
	moveq		#0,d0
	move.w		-(a3),d0
	bpl.s		.masked_transparent
*-------------------------------------------------------*
*	Case #2 - alpha transparent			*
*-------------------------------------------------------*
	cmp.w		#texcode_qalpha,d0
	bra		.alpha_transparent
*-------------------------------------------------------*
*	Case #3 - invalid transparent			*
*-------------------------------------------------------*
	bra		.skip_wall
*-------------------------------------------------------*
.masked_transparent:
*-------------------------------------------------------*
	bsr		cache_resource
	move.l		d0,d6
*-------------------------------------------------------*
.column_loop:
*-------------------------------------------------------*
	lea		-14(a3),a3
	move.l		a3,a1
	move.w		(a1)+,d3			; i (screen)
	moveq		#0,d1
	move.w		(a1)+,d1			; j1j2
	lea		colourtables,a5
	lea		(a4,d3.w*2),a0			; address screen (i)
	sub.l		a6,a0
	moveq		#0,d2
	move.b		d1,d2				; j2 (screen/bot)
	lsr.w		#8,d1				; j1 (screen/top)
	sub.w		d1,d2				; dj (height)
	move.w		(a1)+,d4			; z
	lea		(a5,d4.w*8),a5			; address luminance table
	moveq		#0,d4
	move.w		(a1)+,d4			; u (texture)
	move.l		d6,a2
	add.l		d4,a2				; address u (texture)
	move.l		(a1)+,d3			; dv[i:f] (texture)
	mulu.w		bytewidth,d1	****
	moveq		#0,d4
	swap		d3
	ext.w		d3
	add.l		d1,a0
	move.w		(a1)+,d4			; v (texture)
*-------------------------------------------------------*
*	Calculate tower index & interations		*
*-------------------------------------------------------*
	moveq		#4-1,d0
	and.w		d2,d0				; index = remainder(4)
	lsr.w		#2,d2				; loopsize / 4
*-------------------------------------------------------*
*	Preload carry for cascading adder		*
*-------------------------------------------------------*
	lsl.l		#8,d4
	swap		d4
	move.w		d4,d1				; store v[i]
	add.l		d3,d4				; v[i:f]=v[i:f]+dv[i:f]
	move.w		d1,d4				; restore v[i]
*-------------------------------------------------------*
*	Execute instruction tower			*
*-------------------------------------------------------*
	clr.l		d1
	jmp		.ttab(pc,d0.l*2)
.ttab	bra.s		.t_0		
	bra.s		.t_1
	bra.s		.t_2		
	bra.s		.t_3		
.s_lp:	tvrs16		0
.t_3:	tvrs16		1
.t_2:	tvrs16		2
.t_1:	tvrs16		3
.t_0:	dbra		d2,.s_lp
	dbra		d7,.column_loop
	bra.s		.skip_wall
.w_lp:	tvrw16		0
	tvrw16		1
	tvrw16		2
	tvrw16		3
	dbra		d2,.w_lp
*-------------------------------------------------------*
.done:	dbra		d7,.column_loop
*-------------------------------------------------------*
.skip_wall:
*-------------------------------------------------------*
	swap		d7
	dbra		d7,.wall_loop
.err:	rts

*-------------------------------------------------------*
.alpha_transparent:
*-------------------------------------------------------*
	lea		quick_alpha_table,a5
*-------------------------------------------------------*
.acolumn_loop:
*-------------------------------------------------------*
	lea		-14(a3),a3
	move.l		a3,a1
	move.w		(a1)+,d3			; i (screen)
	moveq		#0,d1
	move.w		(a1)+,d1			; j1j2
	lea		(a4,d3.w*2),a0			; address screen (i)
	moveq		#0,d2
	move.b		d1,d2				; j2 (screen/bot)
	lsr.w		#8,d1				; j1 (screen/top)
	sub.w		d1,d2				; dj (height)
	mulu.w		bytewidth,d1	****
*-------------------------------------------------------*
*	Calculate tower index & interations		*
*-------------------------------------------------------*
	moveq		#4-1,d0
	and.w		d2,d0				; index = remainder(4)
	lsr.w		#2,d2				; loopsize / 4
	add.l		d1,a0
	move.w		d0,d1
	add.w		d1,d1
	sub.w		d1,d0
	add.w		d1,d1
	sub.w		d1,d0				; index * -5
*-------------------------------------------------------*
*	Execute instruction tower			*
*-------------------------------------------------------*
	sub.l		a6,a0
	clr.l		d1
	jmp		.adx_j(pc,d0.w*2)		; jump -> index * -10
.adx_l:	avrun16
	avrun16
	avrun16
	avrun16
.adx_j:	dbra		d2,.adx_l
*-------------------------------------------------------*
	dbra		d7,.acolumn_loop
*-------------------------------------------------------*
	swap		d7
	dbra		d7,.wall_loop
	rts

*-------------------------------------------------------*
render_transparent_2x1:
*-------------------------------------------------------*
	move.w		bytewidth,a6
*-------------------------------------------------------*
	move.l		transparent_array,a3
	move.w		transparent_count,d7
	subq.w		#1,d7
	bmi		.err
*-------------------------------------------------------*
.wall_loop:
*-------------------------------------------------------*
	swap		d7
	move.w		-(a3),d7
*-------------------------------------------------------*
*	Case #1 - masked transparent			*
*-------------------------------------------------------*
	moveq		#0,d0
	move.w		-(a3),d0
	bpl.s		.masked_transparent
*-------------------------------------------------------*
*	Case #2 - alpha transparent			*
*-------------------------------------------------------*
	cmp.w		#texcode_qalpha,d0
	beq		.alpha_transparent
*-------------------------------------------------------*
*	Case #3 - invalid transparent			*
*-------------------------------------------------------*
	bra		.skip_wall
*-------------------------------------------------------*
.masked_transparent:
*-------------------------------------------------------*
	bsr		cache_resource
	move.l		d0,d6
*-------------------------------------------------------*
.column_loop:
*-------------------------------------------------------*
	lea		-14(a3),a3
	move.l		a3,a1
	move.w		(a1)+,d3			; i (screen)
	moveq		#0,d1
	move.w		(a1)+,d1			; j1j2
	lea		colourtables,a5
	lea		(a4,d3.w*4),a0			; address screen (i)
	sub.l		a6,a0
	moveq		#0,d2
	move.b		d1,d2				; j2 (screen/bot)
	lsr.w		#8,d1				; j1 (screen/top)
	sub.w		d1,d2				; dj (height)
	move.w		(a1)+,d4			; z
	lea		(a5,d4.w*8),a5			; address luminance table
	moveq		#0,d4
	move.w		(a1)+,d4			; u (texture)
	move.l		d6,a2
	add.l		d4,a2				; address u (texture)
	move.l		(a1)+,d3			; dv[i:f] (texture)
	mulu.w		bytewidth,d1	****
	moveq		#0,d0
	moveq		#0,d4
	swap		d3
	ext.w		d3
	add.l		d1,a0
	move.w		(a1)+,d4			; v (texture)
*-------------------------------------------------------*
*	Calculate tower index & interations		*
*-------------------------------------------------------*
	moveq		#4-1,d0
	and.w		d2,d0				; index = remainder(4)
	lsr.w		#2,d2				; loopsize / 4
*-------------------------------------------------------*
*	Preload carry for cascading adder		*
*-------------------------------------------------------*
	lsl.l		#8,d4
	swap		d4
	move.w		d4,d1				; store v[i]
	add.l		d3,d4				; v[i:f]=v[i:f]+dv[i:f]
	move.w		d1,d4				; restore v[i]
*-------------------------------------------------------*
*	Execute instruction tower			*
*-------------------------------------------------------*
	clr.l		d1
	jmp		.ttab(pc,d0.w*2)	; jump -> index * -16
.ttab	bra.s		.t_0		
	bra.s		.t_1
	bra.s		.t_2		
	bra.s		.t_3		
.s_lp:	tvrs16		0
.t_3:	tvrs16		1
.t_2:	tvrs16		2
.t_1:	tvrs16		3
.t_0:	dbra		d2,.s_lp
	bra.s		.done
.w_lp:	tvrw32		0
	tvrw32		1
	tvrw32		2
	tvrw32		3
	dbra		d2,.w_lp
*-------------------------------------------------------*
.done:	dbra		d7,.column_loop
*-------------------------------------------------------*
.skip_wall:
*-------------------------------------------------------*
	swap		d7
	dbra		d7,.wall_loop
.err:	rts

*-------------------------------------------------------*
.alpha_transparent:
*-------------------------------------------------------*
	lea		quick_alpha_table,a5
	subq.l		#2*2,a6
*-------------------------------------------------------*
.acolumn_loop:
*-------------------------------------------------------*
	lea		-14(a3),a3
	move.l		a3,a1
	move.w		(a1)+,d3			; i (screen)
	moveq		#0,d1
	move.w		(a1)+,d1			; j1j2
	lea		(a4,d3.w*4),a0			; address screen (i)
	moveq		#0,d2
	move.b		d1,d2				; j2 (screen/bot)
	lsr.w		#8,d1				; j1 (screen/top)
	sub.w		d1,d2				; dj (height)
	mulu.w		bytewidth,d1	****
*-------------------------------------------------------*
*	Calculate tower index & interations		*
*-------------------------------------------------------*
	moveq		#4-1,d0
	and.w		d2,d0				; index = remainder(4)
	lsr.w		#2,d2				; loopsize / 4
	add.l		d1,a0
	move.w		d0,d1
	lsl.w		#3,d1
	sub.w		d1,d0				; index * -7
*-------------------------------------------------------*
*	Execute instruction tower			*
*-------------------------------------------------------*
	clr.l		d1
	sub.l		a6,a0
	jmp		.adx_j(pc,d0.w*2)		; jump -> index * -14
.adx_l:	avrun32
	avrun32
	avrun32
	avrun32
.adx_j:	dbra		d2,.adx_l
*-------------------------------------------------------*
	dbra		d7,.acolumn_loop
*-------------------------------------------------------*
	addq.l		#2*2,a6
	swap		d7
	dbra		d7,.wall_loop
	rts

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*

sky_xs:			ds.l	1
sky_xi:			ds.l	1
sky_ys:			ds.l	1
sky_yi:			ds.l	1
sky_width:		ds.l	1

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

colourtables:		ds.w	256*64			; space for 64 light levels of palette
quick_alpha_table:	ds.w	65536			; space for quick-alpha indexes

final_flat:		ds.b	1			; flag for last texture run
turbulence_on:		ds.b	1

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
