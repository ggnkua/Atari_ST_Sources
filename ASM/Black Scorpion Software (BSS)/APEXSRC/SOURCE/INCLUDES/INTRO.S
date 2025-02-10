
xsize		=	128
ysize		=	80
exp		=	16
frames		=	2
edge_length	=	4096/4

*-----------------------------------------------------------------------*
*	Translation mapping code							*
*-----------------------------------------------------------------------*

copyprot:
	moveq		#20-1,d0

.lp	move.b		(a0)+,(a1)+

;	move.w		(a0)+,d1
;	eor.w		#$9ac6,d1
;	add.b		#32,d1
;	ror.w		#8,d1
;	add.b		#32,d1
;	ror.w		#8,d1
;	move.w		d1,(a1)+

	dbra		d0,.lp
	clr.b		(a1)

	rts

protline1:	dc.b	27,"Y",0,100,77+12*0,0
protline2:	dc.b	27,"Y",0,100,77+12*1,0
protline3:	dc.b	27,"Y",0,100,77+12*2,0
protline4:	dc.b	27,"Y",0,100,77+12*3,0
protline5:	dc.b	27,"Y",0,100,77+12*4,0

introduction:
	jsr		HIDE_MOUSE
	move.w	#iface_dgrey,CHAR_COL
	lea		protline1,a0
	jsr		PRINT_LINE
	lea		apexdata+(0*apexdata_linelen),a0
	lea		apextext,a1	
	bsr		copyprot
	lea		apextext,a0
	jsr		PRINT_LINE_ADJ
	lea		protline2,a0
	jsr		PRINT_LINE
	lea		apexdata+(1*apexdata_linelen),a0
	lea		apextext,a1	
	bsr		copyprot
	lea		apextext,a0
	jsr		PRINT_LINE_ADJ
	lea		protline3,a0
	jsr		PRINT_LINE
	lea		apexdata+(2*apexdata_linelen),a0
	lea		apextext,a1	
	bsr		copyprot
	lea		apextext,a0
	jsr		PRINT_LINE_ADJ
	lea		protline4,a0
	jsr		PRINT_LINE
	lea		apexdata+(3*apexdata_linelen),a0
	lea		apextext,a1	
	bsr		copyprot
	lea		apextext,a0
	jsr		PRINT_LINE_ADJ
	lea		protline5,a0
	jsr		PRINT_LINE
	lea		apexdata+(4*apexdata_linelen),a0
	lea		apextext,a1	
	bsr		copyprot
	lea		apextext,a0
	jsr		PRINT_LINE_ADJ
	jsr		WAIT_MOUSE2
	jsr		WAIT_RELEASE
	jsr		intro_loop
	jsr		SHOW_MOUSE
	move.w	#-1,DIALOG_BITS
	rts
	
intro_loop:
	tst.b		TRUE_FLAG
	beq.s		crap_intro_loop

crap_intro_waves:
	jsr		Init_Bum
.loop	tst.w		wormhole_handle
	bmi.s		.skip
	move.l	PHYS_SCR,a0
	add.l		screen_offset,a0
	jsr		Draw_Bum
.wt	tst.w		TIMER
	bne.s		.wt
	move.w	#1,TIMER
.skip	cmp.b		#right_button,BUTTONS
	bne.s		.loop
	rts

crap_intro_loop:
	jsr		Init_DSP_MIX
.loop	tst.w		wormhole_handle
	bmi.s		.skip
	bsr		draw_tunnel
.wt	tst.w		TIMER
	bne.s		.wt
	move.w	#1,TIMER
.skip	cmp.b		#right_button,BUTTONS
	bne.s		.loop
	rts

init_intro:
	tst.b		TRUE_FLAG
	beq		init_wormhole

init_waves:
	move.l	#0,sysfile_index
	move.w	#-1,wormhole_handle
	move.w	X_RESOLUTION,d0
	sub.w		#xsize,d0
	lsr.w		d0
	ext.l		d0
	move.w	Y_RESOLUTION,d1
	sub.w		#ysize,d1
	lsr.w		d1
	move.w	#5,d2
	yresfactor	d2
	add.w		d2,d1
	mulu		X_RESOLUTION,d1
	add.l		d0,d1
	tst.b		TRUE_FLAG
	bne.s		.tc
	and.w		#-16,d1
	bra.s		.bpl
.tc	add.l		d1,d1	
.bpl	move.l	d1,screen_offset
	move.l	#65556,d0
	jsr		Add_fast
	tst.l		d0
	bmi		.err
	move.w	d0,wormhole_handle
	jsr		Find_block
	move.l	a0,megacol_ptr
	pushall
	move.l	#MEGACOL_NAME,sysfile_name
	move.l	#65556,sysfile_size
	move.l	megacol_ptr,a0
	move.l	a0,sysfile_ptr
	jsr		READ_SYSFILE
	popall
	jsr		Init_Bum
	moveq		#0,d0
	rts
.err	moveq		#-1,d0
	rts


init_wormhole:
	move.l	#20,sysfile_index
	move.l	#0,fcount
	move.w	#-1,wormhole_handle
	move.w	X_RESOLUTION,d0
	sub.w		#xsize,d0
	lsr.w		d0
	ext.l		d0
	move.w	Y_RESOLUTION,d1
	sub.w		#ysize,d1
	lsr.w		d1
	move.w	#5,d2
	yresfactor	d2
	add.w		d2,d1
	mulu		X_RESOLUTION,d1
	add.l		d0,d1
	tst.b		TRUE_FLAG
	bne.s		.tc
	and.w		#-16,d1
	bra.s		.bpl
.tc	add.l		d1,d1	
.bpl	move.l	d1,screen_offset
	move.l	#(256*512*2)+(xsize*ysize*2),d0
	jsr		Add_fast
	tst.l		d0
	bmi		.err
	move.w	d0,wormhole_handle
	jsr		Find_block
	move.l	a0,texture1
	add.l		#256*256*2,a0
	move.l	a0,texture2
	add.l		#256*256*2,a0
	move.l	a0,indices
	pushall
	move.l	#INTRO_NAME,sysfile_name
	move.l	#(256*256*2),sysfile_size
	move.l	texture2,a0
	move.l	a0,sysfile_ptr
	jsr		READ_SYSFILE
	move.l	texture1,a0
	move.l	a0,sysfile_ptr
	jsr		READ_SYSFILE
	popall
	jsr		generate_tunnel
	moveq		#0,d0
	rts
.err	moveq		#-1,d0
	rts

generate_tunnel:
	clr.l		xstart
	clr.l		iradius
	move.w	#256,d5
	swap		d5
	divu.l	#edge_length,d5
	move.l	indices,a6
	clr.l		scan_zed
	clr.l		scan_add
	move.w	#-101,scan_zed
	move.l	#$80000,scan_add	
.new	move.l	scan_zed,d3
	move.l	scan_add,d4
	add.l		d4,scan_zed
	move.l	d3,d2
	move.l	d3,d4
	swap		d2
	move.w	#-101,d3
	sub.w		d2,d3
	ext.l		d3
	divs.l	d3,d4
	asr.l		#8,d4
	and.l		#255,d4
	move.w	#256,d3
	ext.l		d3
	muls.l	d3,d4
	move.l	d4,yos
	moveq		#0,d2
	moveq		#0,d6
	moveq		#0,d7
;	subq.l	#1,xstart
	move.l	xstart,d1
	move.w	#edge_length-1,d0
.edge	move.w	#4096-1,d2
	and.w		d1,d2
	move.w	(SINE.l,d2.w*2),d3
	add.w		#1024,d2
	and.w		#4096-1,d2
	move.w	(SINE.l,d2.w*2),d4
	ext.l		d3
	ext.l		d4
	muls.l	iradius,d3
	muls.l	iradius,d4
	lsl.l		#1,d3
	lsl.l		#1,d4
	swap		d3
	swap		d4
	add.w		#xsize/2,d3
	bmi.s		.err
	add.w		#ysize/2,d4
	bmi.s		.err
	cmp.w		#xsize,d3
	bge.s		.err
	cmp.w		#ysize,d4
	bge.s		.err
	mulu		#xsize*2,d4
	add.w		d3,d3
	move.l	a6,a5
	add.w		d3,a5
	add.l		d4,a5
	swap		d6
	move.w	d6,d4
	swap		d6
	ext.l		d4
	add.l		yos,d4
	move.w	d4,(a5)
	moveq		#-1,d7
.err	addq		#4,d1
	add.l		d5,d6
	dbra		d0,.edge
	addq.l	#1,iradius
	tst.l		d7
	bne		.new
	rts

draw_tunnel:
	addq.l	#1,fcount
	cmp.l		#2,fcount
	ble.s		.go
	move.l	#600,fcount	
	cmp.l		#4<<16,zoom
	bge.s		.skip
	add.l		#$4000,zoom
.skip	move.w	zoom,d0
	ext.l		d0
	add.l		d0,d0
	lsl.l		#8,d0
	add.l		d0,inc
.go	add.l		#(1*1)*2,inc
	cmp.l		#256*256*2,inc
	blt.s		.ok
	sub.l		#256*256*2,inc
.ok	move.l	indices,a0
	move.l	texture1,a1
	add.l		inc,a1
	move.l	PHYS_SCR,a2
	add.l		screen_offset,a2
	move.w	physwid,d5
	ext.l		d5
	tst.b		TRUE_FLAG
	beq.s		bplintro
	move.w	#ysize-1,d7
.ylp	move.w	#(xsize/exp)-1,d6
	moveq		#0,d0
	move.l	a2,a3
.xlp	move.w	(a0)+,d0
	move.w	(a1,d0.l*2),(a3)+
	rept		exp-1
	move.w	(a0)+,d0
	move.w	(a1,d0.l*2),(a3)+
	endr
	dbra		d6,.xlp
	add.l		d5,a2
	dbra		d7,.ylp
	rts

bplintro:
	lea		$FFFFA202.w,a5
	lea		$FFFFA206.w,a6
	moveq		#0,d0
	move.w	#ysize-1,d7
.ylp	move.l	a2,a3
	move.w	#xsize,d6
	dspwrite	d6
	dspwrite	#0
	bra.s		.xs
.pxlp	btst		#1,(a5)
	beq.s		.pxlp
	move.w	(a0)+,d0
	moveq		#32-1,d1
	and.w		(a1,d0.l*2),d1
	move.b	d1,1(a6)
.xs	dbra		d6,.pxlp
	dspread	d6
	bra.s		.wgo
.wxlp	move.w	(a6),(a3)+
	move.w	(a6),(a3)+
	move.w	(a6),(a3)+
	move.w	(a6),(a3)+
	move.w	(a6),(a3)+
	move.w	(a6),(a3)+
	move.w	(a6),(a3)+
	move.w	(a6),(a3)+
.wgo	dbra		d6,.wxlp		
	add.l		d5,a2
	dbra		d7,.ylp
	rts

	include	waves\wavedsp2.s

inc:			ds.l	1
zoom:			ds.l	1
fcount:		ds.l	1
yos:			ds.l	1
iradius:		ds.l	1
scan_zed:		ds.l	1
scan_add:		ds.l	1
xstart:		ds.l	1

wormhole_handle:	ds.w	1
screen_offset:	ds.l	1
texture1:		ds.l	1
texture2:		ds.l	1
indices:		ds.l	1

MEGACOL_NAME:	dc.b	"megacol.ami",0
INTRO_NAME:		dc.b	"xtra.ami",0
			even

