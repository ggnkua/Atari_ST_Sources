*=======================================================*
*	Rendering module: latest update 25/03/96	*
*=======================================================*
*	Render walls & floors onto screenbuffer		*
*=======================================================*

*-------------------------------------------------------*
*	Texel addressing units [horizontal]		*
*-------------------------------------------------------*

*-------------------------------------------------------*
*	8-bit texel -> 16-bit pixel unit		*
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

*-------------------------------------------------------*
*	8-bit texel -> 32-bit (double) pixel unit	*
*-------------------------------------------------------*

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
*	8-bit scaled -> 16-bit pixel unit		*
*-------------------------------------------------------*

srun16	macro				; 14
	move.w		d3,d0
	and.w		d4,d0
	move.b		(a1,d0.w*8),d6
	addx.l		d7,d3
	move.w		(a0,d6.l*2),(a6)+
	endm

*-------------------------------------------------------*
*	8-bit scaled -> 32-bit (double) pixel unit	*
*-------------------------------------------------------*

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
*	Texel addressing units [vertical]		*
*-------------------------------------------------------*

*-------------------------------------------------------*
*	8-bit texel -> 16-bit pixel unit		*
*-------------------------------------------------------*

vrun16	macro
	and.w		d5,d4
	move.b		(a2,d4.w),d1
	addx.l		d3,d4
	move.w		(a5,d1.l*2),d0
	adda.l		a6,a0
	move.w		d0,(a0)
	endm

*-------------------------------------------------------*
*	8-bit texel -> 32-bit (double) pixel unit	*
*-------------------------------------------------------*

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
*	Transparent texel addressing units [vertical]	*
*-------------------------------------------------------*

*-------------------------------------------------------*
*	8-bit texel -> 16-bit pixel unit		*
*-------------------------------------------------------*

tvrun16	macro				; 16
	and.w		d5,d4
	move.b		(a2,d4.w),d1
	beq.s		.tp\@
	move.w		(a5,d1.l*2),(a0)
.tp\@:	addx.l		d3,d4
	adda.l		a6,a0
	endm

*-------------------------------------------------------*
*	8-bit texel -> 32-bit (double) pixel unit	*
*-------------------------------------------------------*

tvrun32	macro				; 20
	and.w		d5,d4
	move.b		(a2,d4.w),d1
	beq.s		.tp\@
	move.w		(a5,d1.l*2),d0
	move.w		d0,(a0)
	move.w		d0,2(a0)
.tp\@:	addx.l		d3,d4
	adda.l		a6,a0
	endm

*-------------------------------------------------------*
*	QuickAlpha texel addressing units [vertical]	*
*-------------------------------------------------------*

*-------------------------------------------------------*
*	8-bit texel -> 16-bit pixel unit		*
*-------------------------------------------------------*

avrun16	macro				; 10
	move.w		(a0,a6.l),d1
	adda.l		a6,a0
	move.w		(a5,d1.l*2),(a0)
	endm

*-------------------------------------------------------*
*	8-bit texel -> 32-bit (double) pixel unit	*
*-------------------------------------------------------*

avrun32	macro				; 14
	move.w		(a0,a6.l),d1
	adda.l		a6,a0
	move.w		(a5,d1.l*2),d1
	move.w		d1,(a0)+
	move.w		d1,(a0)+
	endm

*-------------------------------------------------------*
*	Render the floors & ceilings			*
*-------------------------------------------------------*
render_flats:
*-------------------------------------------------------*
	tst.b		halfrows
	bne		render_flats_2x1

*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
render_flats_1x1:
*-------------------------------------------------------*
	moveq		#rotatemap_command,d0
	dspwrite.l	d0
*-------------------------------------------------------*
	move.l		screen,.local_screen
	lea		zone_space,a3
*-------------------------------------------------------*
	lea		DSPHost16.w,a4
	lea		DSPHostStat.w,a5
*-------------------------------------------------------*
*	Zone loop					*
*-------------------------------------------------------*
.zone_loop:
*-------------------------------------------------------*
	moveq		#0,d4
	move.b		(a3)+,d4			; [zone_lines]
	moveq		#0,d0
	subq.w		#1,d4
	bmi		.last_zone
*-------------------------------------------------------*
	move.b		(a3)+,d0			; [zone_texture]
	cmp.w		sky_index,d0
	beq		.scaled_chunk
*-------------------------------------------------------*
.perspected_chunk:	
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
	dspwaitread.4	(a5)
	move.w		(a4),d3				; map_x
	dspwaitread.4	(a5)
	move.w		(a4),d4				; map_yi
	dspwaitread.4	(a5)
	move.w		(a4),d1				; map_y
	dspwaitread.4	(a5)
	move.w		(a4),d6				; x1
*-------------------------------------------------------*
*	Render flat run					*
*-------------------------------------------------------*
	lea		colourtables,a0
	moveq		#0,d0
	move.w		(a3)+,d0
	lsl.l		#6,d3
	lsl.l		#6,d7
	swap		d2
	move.w		(a3)+,d2
	lsl.l		#8,d0
	add.l		d0,d0
	add.l		d0,a0
	lea		(a2,d6.w*2),a6
	sub.w		d6,d2
	moveq		#4-1,d0
	and.w		d2,d0
	lsr.w		#2,d2				; dx{loop}
	moveq		#0,d6
*-------------------------------------------------------*
*	Flat-rendering instruction tower		*
*-------------------------------------------------------*
	jmp		.pdx_l(pc,d0.w*2)		; index instruction tower
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
.scaled_chunk:	
*-------------------------------------------------------*
	move.l		#.err,d5
	move.w		current_sky,d0
	bmi.s		.err
	bsr		cache_resource
	move.l		d0,d5
*-------------------------------------------------------*
.err:	move.l		skyx(pc),d7				; sxi
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
	dspwaitread.4	(a5)
	tst.b		(a1)				; map_x
	dspwaitread.4	(a5)
	tst.b		(a1)				; map_yi
	dspwaitread.4	(a5)
	tst.b		(a1)				; map_y	
	dspwaitread.4	(a5)
	move.w		(a4),d6				; x1
*-------------------------------------------------------*
	moveq		#128-1,d0
	and.w		d1,d0
	mulu.l		skyy(pc),d0
	move.l		d5,a1
	clr.w		d0
	swap		d0
	add.l		d0,a1
*-------------------------------------------------------*
	moveq		#0,d3
	move.w		d6,d3
	swap		d7
	muls.l		d7,d3
	add.l		xoff(pc),d3
	move.w		#%0000111111110000,d4
	swap		d7
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
	moveq		#0,d6
*-------------------------------------------------------*
*	Flat-rendering instruction tower		*
*-------------------------------------------------------*
	jmp		.sdx_l(pc,d0.w*2)		; index instruction tower
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
;	lea		(max_xres*2)(a2),a2
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
	moveq		#rotatemap_command,d0
	dspwrite.l	d0
*-------------------------------------------------------*
	move.l		screen,.local_screen
	lea		zone_space,a3
*-------------------------------------------------------*
	lea		DSPHostStat.w,a5
*-------------------------------------------------------*
*	Zone loop					*
*-------------------------------------------------------*
.zone_loop:
*-------------------------------------------------------*
	moveq		#0,d4
	move.b		(a3)+,d4			; [zone_lines]
	moveq		#0,d0
	subq.w		#1,d4
	bmi		.last_zone
*-------------------------------------------------------*
	move.b		(a3)+,d0			; [zone_texture]
	cmp.w		sky_index,d0
	beq		.scaled_chunk
*-------------------------------------------------------*
.perspected_chunk:
*-------------------------------------------------------*
	bsr		cache_resource
	move.l		d0,a1
	move.w		(a3)+,d0			; [zone_start]
	move.l		.local_screen(pc),a2
	mulu.w		bytewidth,d0
	add.l		d0,a2
*-------------------------------------------------------*
.line_loop:
*-------------------------------------------------------*
	move.w		(a3)+,d2			; [line_runs]
	swap		d4
	subq.w		#1,d2
	bmi		.null_line
*-------------------------------------------------------*
.run_loop:
*-------------------------------------------------------*
	lea		DSPHost16.w,a4
	dspwaitread.0	(a5)
	move.w		(a4),d7				; map_xi
	dspwaitread.4	(a5)
	move.w		(a4),d3				; map_x
	dspwaitread.4	(a5)
	move.w		(a4),d4				; map_yi
	dspwaitread.4	(a5)
	move.w		(a4),d1				; map_y
	dspwaitread.4	(a5)
	move.w		(a4),d6				; x1
*-------------------------------------------------------*
*	Render flat run					*
*-------------------------------------------------------*
	lea		colourtables,a0
	moveq		#0,d0
	move.w		(a3)+,d0
	lsl.l		#6,d3
	lsl.l		#6,d7
	swap		d2
	move.w		(a3)+,d2
	lsl.l		#8,d0
	add.l		d0,d0
	add.l		d0,a0
	lea		(a2,d6.w*4),a6
	addq.w		#1,d6
	sub.w		d6,d2
	moveq		#4-1,d0
	and.w		d2,d0
	lsr.w		#2,d2				; dx{loop}
	move.l		d0,d6
	lsl.w		#2,d6
	sub.w		d6,d0				; dx{remainder} * -24
*-------------------------------------------------------*
*	Flat-rendering instruction tower		*
*-------------------------------------------------------*
	hrun32s
	jmp		.dx_j(pc,d0.w*8)		; index instruction tower
.dx_l:	hrun32
	hrun32
	hrun32
	hrun32
.dx_j:	dbra		d2,.dx_l
	move.w		d7,(a6)+
	move.w		d7,(a6)+
*-------------------------------------------------------*
	swap		d2
	dbra		d2,.run_loop
*-------------------------------------------------------*
.null_line:
*-------------------------------------------------------*
;	lea		(max_xres*2)(a2),a2
	add.w		bytewidth,a2
	swap		d4
	dbra		d4,.line_loop
*-------------------------------------------------------*
	bra		.zone_loop
*-------------------------------------------------------*
.scaled_chunk:	
*-------------------------------------------------------*
	move.l		#.err,d5
	move.w		current_sky,d0
	bmi.s		.err
	bsr		cache_resource
	move.l		d0,d5
*-------------------------------------------------------*
.err:	move.l		skyx(pc),d7				; sxi
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
	lea		DSPHost16.w,a4
	lea		1(a4),a1
	dspwaitread.0	(a5)
	tst.b		(a1)				; map_xi
	dspwaitread.4	(a5)
	tst.b		(a1)				; map_x
	dspwaitread.4	(a5)
	tst.b		(a1)				; map_yi
	dspwaitread.4	(a5)
	tst.b		(a1)				; map_y	
	dspwaitread.4	(a5)
	move.w		(a4),d6				; x1
*-------------------------------------------------------*
	move.l		skyy(pc),d0
	move.l		d5,a1
	mulu.l		d1,d0
	clr.w		d0
	swap		d0
	add.l		d0,a1
*-------------------------------------------------------*
	moveq		#0,d3
	move.w		d6,d3
	swap		d7
	mulu.l		d7,d3
	add.l		xoff(pc),d3
	move.w		#%0000111111110000,d4
	swap		d7
	swap		d3
*-------------------------------------------------------*
*	Render flat run					*
*-------------------------------------------------------*
	swap		d2
	move.w		(a3)+,d2
*-------------------------------------------------------*
	lea		(a2,d6.w*4),a6
*-------------------------------------------------------*
	sub.w		d6,d2
	moveq		#4-1,d0
	and.w		d2,d0
	asr.w		#2,d2				; dx{loop}
*-------------------------------------------------------*
	move.l		d0,d6
	lsl.w		#3,d6
	add.w		d6,d0				; dx{remainder} * -9
	neg.w		d0
*-------------------------------------------------------*
	move.w		d3,d6
	add.l		d7,d3
	move.w		d6,d3
	moveq		#0,d6
*-------------------------------------------------------*
*	Flat-rendering instruction tower		*
*-------------------------------------------------------*
	jmp		.sdx_j(pc,d0.w*2)		; index instruction tower
.sdx_l:	srun32
	srun32
	srun32
	srun32
.sdx_j:	dbra		d2,.sdx_l
*-------------------------------------------------------*
	swap		d2
	dbra		d2,.srun_loop
*-------------------------------------------------------*
.snull_line:
*-------------------------------------------------------*
	add.w		bytewidth,a2
;	lea		(max_xres*2)(a2),a2
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

	rept		0

vrun	macro
	and.w		d5,d4
	move.b		(a2,d4.w),d1
	addx.l		d3,d4
	move.w		(a5,d1.l*2),d0
	adda.l		a6,a0
	move.w		d0,(a0)
	endm

*-------------------------------------------------------*
*	Render the walls				*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
render_walls:
*-------------------------------------------------------*
	rts
	lea		wallruns,a1
	moveq		#0,d6
	move.w		wallruncount,d6
	subq.w		#1,d6
	bmi		.err
	move.l		screen,a4
	moveq		#0,d5
	move.w		bytewidth,d5
	move.l		d5,a6
	sub.l		a6,a4

	move.w		#128-1,d5

;	i,j1j2,z,u,dv,v
	
	lea		wall_texture,a3
*-------------------------------------------------------*
*	Wall-column horizontal loop			*	
*-------------------------------------------------------*
.runs:	move.w		(a1)+,d3			; i (screen)
	moveq		#0,d1
	move.b		(a1)+,d1			; j1 (screen/top)
	moveq		#0,d2
	move.b		(a1)+,d2			; j2 (screen/bot)
	lea		colourtables,a5
	lea		(a4,d3.w*2),a0			; address screen (i)
	sub.w		d1,d2				; dj (height)
;	lsl.l		#4,d1
;	move.l		d1,d0
	move.w		(a1)+,d4			; u (texture)
;	lsl.l		#2,d1
;	add.l		d1,d0
;	lsl.l		#3,d0
	move.l		(a1)+,d3			; dv[i:f] (texture)
;	add.l		d0,a0				; address j (screen)

	mulu.w		bytewidth,d1	****
	add.l		d1,a0				; address j (screen)

	moveq		#0,d0
	lea		(a3,d4.w),a2			; address u (texture)
	moveq		#0,d4
	move.w		(a1)+,d4			; v (texture)
	move.b		d3,d0				; luminance
	lsl.l		#8,d0
	add.l		d0,a5				; address luminance table
	asr.l		#8,d3
	swap		d3
	lsl.l		#8,d4
	swap		d4
*-------------------------------------------------------*
*	Calculate tower index & interations		*
*-------------------------------------------------------*
	moveq		#4-1,d0
	and.w		d2,d0				; index = remainder(4)
	lsr.w		#2,d2				; loopsize / 4
	neg.w		d0
	add.w		d0,d0				; index * -2
*-------------------------------------------------------*
*	Preload carry for cascading adder		*
*-------------------------------------------------------*
	move.w		d4,d1				; store v[i]
	add.l		d3,d4				; v[i:f]=v[i:f]+dv[i:f]
	move.w		d1,d4				; restore v[i]
*-------------------------------------------------------*
*	Execute instruction tower			*
*-------------------------------------------------------*
	clr.l		d1
	jmp		.dx_j(pc,d0.w*8)		; jump -> index * -16
.dx_l:	vrun
	vrun
	vrun
	vrun
.dx_j:	dbra		d2,.dx_l
*-------------------------------------------------------*
*	Address next wall column			*
*-------------------------------------------------------*
	dbra		d6,.runs
.err:	rts

	endr

*-------------------------------------------------------*
render_wall:
*-------------------------------------------------------*
	cmp.w		#texcode_none,wall_id
	beq		flush_badwall
	cmp.w		#texcode_sky,wall_id
	beq		flush_badwall
*-------------------------------------------------------*
	tst.b		addwall_opaque(a6)
	bne		stack_transparent
*-------------------------------------------------------*
	moveq		#0,d0
	move.w		wall_id,d0
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
;	lsl.l		#4,d1
;	move.l		d1,d0
	dspwaitread.0	(a3)
	move.w		(a1),d4				; z
	lea		(a5,d4.w*8),a5			; address luminance table
	moveq		#0,d4
	dspwaitread.3	(a3)
	move.w		(a1),d4				; u (texture)
;	lsl.l		#2,d1
;	add.l		d1,d0
;	lsl.l		#3,d0
	move.l		d6,a2
	add.l		d4,a2				; address u (texture)
	dspwaitread.0	(a3)
	move.l		-2(a1),d3			; dv[i:f] (texture)
;	add.l		d0,a0				; address j (screen)

	mulu.w		bytewidth,d1	****
	add.l		d1,a0
	
	moveq		#0,d4
	swap		d3
	ext.w		d3
	dspwaitread.3	(a3)
	move.w		(a1),d4				; v (texture)
*-------------------------------------------------------*
*	Calculate tower index & interations		*
*-------------------------------------------------------*
	moveq		#4-1,d0
	and.w		d2,d0				; index = remainder(4)
	lsr.w		#2,d2				; loopsize / 4
	neg.w		d0
	add.w		d0,d0				; index * -2
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
	jmp		.dx_j(pc,d0.w*8)		; jump -> index * -16
.dx_l:	vrun16
	vrun16
	vrun16
	vrun16
.dx_j:	dbra		d2,.dx_l
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
;	lsl.l		#4,d1
;	move.l		d1,d0
	dspwaitread.0	(a3)
	move.w		(a1),d4				; z
	lea		(a5,d4.w*8),a5			; address luminance table
	moveq		#0,d4
	dspwaitread.3	(a3)
	move.w		(a1),d4				; u (texture)
;	lsl.l		#2,d1
;	add.l		d1,d0
;	lsl.l		#3,d0
	move.l		d6,a2
	add.l		d4,a2				; address u (texture)
	dspwaitread.0	(a3)
	move.l		-2(a1),d3			; dv[i:f] (texture)
;	add.l		d0,a0				; address j (screen)
	
	mulu.w		bytewidth,d1	****
	add.l		d1,a0

	moveq		#0,d4
	swap		d3
	ext.w		d3
	dspwaitread.3	(a3)
	move.w		(a1),d4				; v (texture)
*-------------------------------------------------------*
*	Calculate tower index & interations		*
*-------------------------------------------------------*
	moveq		#4-1,d0
	and.w		d2,d0				; index = remainder(4)
	lsr.w		#2,d2				; loopsize / 4
	move.w		d0,d1
	lsl.w		#3,d1
	add.w		d1,d0
	neg.w		d0				; index * -9
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
	jmp		.dx_j(pc,d0.w*2)		; jump -> index * -16
.dx_l:	vrun32
	vrun32
	vrun32
	vrun32
.dx_j:	dbra		d2,.dx_l
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
	moveq		#0,d2
	move.b		d1,d2				; j2 (screen/bot)
	lsr.w		#8,d1				; j1 (screen/top)
	sub.w		d1,d2				; dj (height)
;	lsl.l		#4,d1
;	move.l		d1,d0
	move.w		(a1)+,d4			; z
	lea		(a5,d4.w*8),a5			; address luminance table
	moveq		#0,d4
	move.w		(a1)+,d4			; u (texture)
;	lsl.l		#2,d1
;	add.l		d1,d0
;	lsl.l		#3,d0
	move.l		d6,a2
	add.l		d4,a2				; address u (texture)
	move.l		(a1)+,d3			; dv[i:f] (texture)
;	add.l		d0,a0				; address j (screen)

	mulu.w		bytewidth,d1	****
	add.l		d1,a0

	moveq		#0,d4
	swap		d3
	ext.w		d3
	move.w		(a1)+,d4			; v (texture)
*-------------------------------------------------------*
*	Calculate tower index & interations		*
*-------------------------------------------------------*
	moveq		#4-1,d0
	and.w		d2,d0				; index = remainder(4)
	lsr.w		#2,d2				; loopsize / 4
	add.w		d0,d0
	neg.w		d0				; index * -2
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
	jmp		.dx_j(pc,d0.w*8)		; jump -> index * -16
.dx_l:	tvrun16
	tvrun16
	tvrun16
	tvrun16
.dx_j:	dbra		d2,.dx_l
*-------------------------------------------------------*
	dbra		d7,.column_loop
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

;	lsl.l		#4,d1
;	move.l		d1,d0
;	lsl.l		#2,d1
;	add.l		d1,d0
;	lsl.l		#3,d0
;	add.l		d0,a0				; address j (screen)

	mulu.w		bytewidth,d1	****
	add.l		d1,a0

*-------------------------------------------------------*
*	Calculate tower index & interations		*
*-------------------------------------------------------*
	moveq		#4-1,d0
	and.w		d2,d0				; index = remainder(4)
	lsr.w		#2,d2				; loopsize / 4

	move.w		d0,d1
	add.w		d1,d1
	sub.w		d1,d0
	add.w		d1,d1
	sub.w		d1,d0				; index * -5
	
;	neg.w		d0				; index * -1

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
	moveq		#0,d2
	move.b		d1,d2				; j2 (screen/bot)
	lsr.w		#8,d1				; j1 (screen/top)
	sub.w		d1,d2				; dj (height)
;	lsl.l		#4,d1
;	move.l		d1,d0
	move.w		(a1)+,d4			; z
	lea		(a5,d4.w*8),a5			; address luminance table
	moveq		#0,d4
	move.w		(a1)+,d4			; u (texture)
;	lsl.l		#2,d1
;	add.l		d1,d0
;	lsl.l		#3,d0
	move.l		d6,a2
	add.l		d4,a2				; address u (texture)
	move.l		(a1)+,d3			; dv[i:f] (texture)
;	add.l		d0,a0				; address j (screen)

	mulu.w		bytewidth,d1	****
	add.l		d1,a0

	moveq		#0,d0
	moveq		#0,d4
	swap		d3
	ext.w		d3
	move.w		(a1)+,d4			; v (texture)
*-------------------------------------------------------*
*	Calculate tower index & interations		*
*-------------------------------------------------------*
	moveq		#4-1,d0
	and.w		d2,d0				; index = remainder(4)
	lsr.w		#2,d2				; loopsize / 4
	move.w		d0,d1
	add.w		d1,d1
	add.w		d1,d0
	lsl.w		#2,d1
	add.w		d1,d0
	neg.w		d0				; index * -11
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
	jmp		.dx_j(pc,d0.w*2)		; jump -> index * -22
.dx_l:	tvrun32
	tvrun32
	tvrun32
	tvrun32
.dx_j:	dbra		d2,.dx_l
*-------------------------------------------------------*
	dbra		d7,.column_loop
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

;	lsl.l		#4,d1
;	move.l		d1,d0
;	lsl.l		#2,d1
;	add.l		d1,d0
;	lsl.l		#3,d0
;	add.l		d0,a0				; address j (screen)
	
	mulu.w		bytewidth,d1	****
	add.l		d1,a0

*-------------------------------------------------------*
*	Calculate tower index & interations		*
*-------------------------------------------------------*
	moveq		#4-1,d0
	and.w		d2,d0				; index = remainder(4)
	lsr.w		#2,d2				; loopsize / 4
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
*	Draw composite texture to the screen		*
*-------------------------------------------------------*
render_texture:
*-------------------------------------------------------*
	bsr		clear_patchtags
	bsr		load_patches
	bsr		add_patches
	rts
	
*-------------------------------------------------------*
*	Load all unique patches into temp buffer	*
*-------------------------------------------------------*
load_patches:
*-------------------------------------------------------*
	pushall
;	move.l		texturelist_array,a0
	move.l		graphics_array,a0
	move.l		(a0,d0.w*4),a0
	move.w		tex_width(a0),patch_xclip
	move.w		tex_height(a0),patch_yclip
	move.w		tex_patches(a0),d6
	lea		tex_len(a0),a0
	bra.s		.go
.all:	move.w		texp_index(a0),d0
	lea		patch_taglist,a1
	move.w		patch_tags,d1
	bra.s		.tgo
.tlp:	cmp.w		(a1),d0
	beq.s		.old
	addq.l		#6,a1
.tgo:	dbra		d1,.tlp
	addq.w		#1,patch_tags
	move.w		d0,(a1)+
	move.l		patchbuffer_ptr,(a1)+
	pushall
	move.l		pnamelist_array,a2
	move.l		(a2,d0.w*4),d1
	beq		.skip
	move.l		d1,a0
	move.l		patchbuffer_ptr,a1
	move.l		wd_size(a0),d1
	add.l		d1,patchbuffer_ptr
	bsr		read_resource
.skip:	popall
.old:	lea		texp_len(a0),a0
.go:	dbra		d6,.all
	popall
	rts

*-------------------------------------------------------*
*	Prepare to load unique patches using tags	*
*-------------------------------------------------------*
clear_patchtags:
*-------------------------------------------------------*
	clr.w		patch_tags
	move.l		#buffer_space,patchbuffer_ptr
	move.w		#max_patches,d1
	lea		patch_taglist,a1
	bra.s		.fgo
.flp:	move.w		#terminator,(a1)+
	addq.l		#4,a1
.fgo:	dbra		d1,.flp
	rts
	
*-------------------------------------------------------*
*	Build texture up from patches			*
*-------------------------------------------------------*
add_patches:
*-------------------------------------------------------*
	pushall
	move.l		graphics_array,a0
;	move.l		texturelist_array,a0
	move.l		(a0,d0.w*4),a0
	move.w		tex_width(a0),patch_xclip
	move.w		tex_height(a0),patch_yclip
	move.w		tex_patches(a0),d6
	lea		tex_len(a0),a0
	bra.s		.go
.all:	move.w		texp_xoff(a0),patch_xoff
	move.w		texp_yoff(a0),patch_yoff
	move.w		texp_index(a0),patch_index
	push.w		d6
	push.l		a0
	bsr		render_patch_tex
	pop.l		a0
	pop.w		d6
	lea		texp_len(a0),a0
.go:	dbra		d6,.all
	popall
	rts

*-------------------------------------------------------*
*	Draw one patch as a section of a texture	*
*-------------------------------------------------------*
render_patch:
*-------------------------------------------------------*
	move.w		patch_index,d0
	move.w		patch_tags,d1
	lea		patch_taglist,a1
	bra.s		.fgo
.flp:	cmp.w		(a1),d0
	beq.s		.got
	addq.l		#6,a1
.fgo:	dbra		d1,.flp
	bra		.err
.got:	addq.l		#2,a1
	move.l		(a1)+,a0
	move.l		ScreenPhy,a3
	lea		colourtables+(63*512),a5
	move.l		a0,a1
	imov.w		(a0)+,d6			; width
	imov.w		(a0)+,d7			; height
	imov.w		(a0)+,d0			; xoff
	imov.w		(a0)+,d1			; yoff
	move.w		patch_yclip,d5
	move.w		patch_yoff,d1
	move.w		patch_xoff,d0
	bpl.s		.xok
	add.w		d0,d6
	ble		.err
	neg.w		d0
	lea		(a0,d0.w*4),a0
	moveq		#0,d0
.xok:	lea		(a3,d0.w*2),a3
	add.w		d6,d0
	sub.w		patch_xclip,d0
	ble.s		.go
	sub.w		d0,d6
	ble		.err
	bra.s		.go
.col:	imov.l		(a0)+,a2
	add.l		a1,a2				; post data
.next:	moveq		#0,d0
	move.b		(a2)+,d0
	cmp.b		#255,d0
	beq.s		.stop
	move.w		d1,d2				; base y-offset
	add.w		d0,d2				; post y-offset
	move.w		d2,d3
	muls.w		bytewidth,d3
;	muls.w		#(max_xres*2),d3
	lea		(a3,d3.l),a4
	moveq		#0,d0
	move.b		(a2)+,d0			; post length
	moveq		#0,d3
	addq.l		#1,a2
	bra.s		.vgo
.vert:	move.b		(a2)+,d3
	tst.w		d2
	bmi.s		.skip
	cmp.w		d5,d2
	bpl.s		.skip
	move.w		(a5,d3.w*2),(a4)
.skip:	addq.w		#1,d2
	add.w		bytewidth,a4
;	lea		(max_xres*2)(a4),a4
.vgo:	dbra		d0,.vert
	addq.l		#1,a2
	bra.s		.next
.stop:	addq.l		#2,a3
.go:	dbra		d6,.col
.err:	rts

*-------------------------------------------------------*
*	Draw one patch as a section of a texture	*
*-------------------------------------------------------*
render_patch_tex:
*-------------------------------------------------------*
	move.w		patch_index,d0
	move.w		patch_tags,d1
	lea		patch_taglist,a1
	bra.s		.fgo
.flp:	cmp.w		(a1),d0
	beq.s		.got
	addq.l		#6,a1
.fgo:	dbra		d1,.flp
	bra		.err
.got:	addq.l		#2,a1
	move.l		(a1)+,a0
	move.l		texture_ptr,a3
	move.l		a0,a1
	imov.w		(a0)+,d6			; width
	imov.w		(a0)+,d7			; height
	imov.w		(a0)+,d0			; xoff
	imov.w		(a0)+,d1			; yoff
	move.w		black,d7
	move.w		patch_yclip,d5
	move.w		patch_yoff,d1
	move.w		patch_xoff,d0
	bpl.s		.xok
	add.w		d0,d6
	ble		.err
	neg.w		d0
	lea		(a0,d0.w*4),a0
	moveq		#0,d0
.xok:	move.w		d0,d3
	mulu.w		patch_yclip,d3
	add.l		d3,a3
	add.w		d6,d0
	sub.w		patch_xclip,d0
	ble.s		.go
	sub.w		d0,d6
	ble		.err
	bra.s		.go
.col:	imov.l		(a0)+,a2
	add.l		a1,a2				; post data
.next:	moveq		#0,d0
	move.b		(a2)+,d0
	cmp.b		#255,d0
	beq.s		.stop
	move.w		d1,d2				; base y-offset
	add.w		d0,d2				; post y-offset
	move.w		d2,d3
	lea		(a3,d3.w),a4
	moveq		#0,d0
	move.b		(a2)+,d0			; post length
	moveq		#0,d3
	addq.l		#1,a2
	bra.s		.vgo
.vert:	tst.w		d2
	bmi.s		.skip
	cmp.w		d5,d2
	bpl.s		.skip
	move.b		(a2),d3
	bne.s		.nz
	move.b		d7,d3
.nz:	move.b		d3,(a4)
.skip:	addq.l		#1,a2
	addq.w		#1,d2
	addq.l		#1,a4
.vgo:	dbra		d0,.vert
	addq.l		#1,a2
	bra.s		.next
.stop:	add.w		patch_yclip,a3
.go:	dbra		d6,.col
.err:	rts

xoff:			ds.l	1
skyx:			ds.l	1
skyy:			ds.l	1
	
texture_ptr:		ds.l	1

*-------------------------------------------------------*
			datlong
*-------------------------------------------------------*

wall_texture_file:	;incbin	data\wall8bit.apx
wall_texture:	=	wall_texture_file+20+768

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

patchbuffer_ptr:	ds.l	1

colourtables:		ds.w	256*64			; space for 64 light levels of palette
quick_alpha_table:	ds.w	65536			; space for quick-alpha indexes

patch_xclip:		ds.w	1			; patch dimensions & clipping rectangle
patch_yclip:		ds.w	1
patch_xoff:		ds.w	1
patch_yoff:		ds.w	1
patch_index:		ds.w	1
patch_tags:		ds.w	1

patch_taglist:		ds.b	(2+4)*max_patches	; space for list of unique patch tags
buffer_space:		ds.b	65536			; space for all patches in texture

final_flat:		ds.b	1			; flag for last texture run

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
