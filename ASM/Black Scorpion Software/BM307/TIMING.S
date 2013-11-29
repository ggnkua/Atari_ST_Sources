*=======================================================*
*	Timing module: updated 12/06/97			*
*=======================================================*

timerb		=	$120
timerc		=	$114

tbcr		=	$fffffa1b
cdcr		=	$fffffa1d
tbdr		=	$fffffa21
tcdr		=	$fffffa23
iera		=	$fffffa07
ierb		=	$fffffa09
imra		=	$fffffa13
imrb		=	$fffffa15
isra		=	$fffffa0f

frames_per_sec

*-------------------------------------------------------*
init_timing:
*-------------------------------------------------------*
	tst.b		timing_on
	beq.s		.go
	rts
.go:	st		timing_on

	ifd		debuggable
	move.l		$4d2.w,old_vbi
	move.l		#new_vbi,$4d2.w
	elseif
	push.w		sr
	or.w		#$700,sr
	move.b		iera.w,old_iera
	move.b		ierb.w,old_ierb
	move.b		imra.w,old_imra
	move.b		imrb.w,old_imrb
	move.l		timerb.w,old_timerb
	move.b		#0,tbcr.w
	bclr		#0,iera.w
	move.l		#stabilizer_b,timerb.w
	move.b		#180,tbdr.w
	bset		#0,iera.w
	bset		#0,imra.w
	move.l		$70.w,old_vbi
	move.l		#new_vbi,$70.w
	move.l		timerc.w,old_timerc
	move.l		#framecounter,timerc.w
	and.b		#%00001111,cdcr.w
	move.b		#192,tcdr.w		; 2457600/192 = 12800Hz
	or.b		#(5<<4),cdcr.w		; 12800/64 = 200Hz
	pop.w		sr
	endc
	ifd		enable_timing
	bsr		init_font
	endc
	rts

*-------------------------------------------------------*
reset_timing:
*-------------------------------------------------------*
	tst.b		timing_on
	bne.s		.go
	rts
.go:	sf		timing_on

	ifd		debuggable
	move.l		old_vbi,$4d2.w
	elseif
	push.w		sr
	or.w		#$700,sr
	move.l		old_vbi,$70.w
	move.l		old_timerb,timerb.w
	move.l		old_timerc,timerc.w
	move.b		old_iera,iera.w
	move.b		old_ierb,ierb.w
	move.b		old_imra,imra.w
	move.b		old_imrb,imrb.w
	pop.w		sr
	endc
	rts

*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
timing:
*-------------------------------------------------------*
	ifd		show_timing
	ifd		enable_timing
	move.w		#8,char_x
	move.w		#8,char_y
	move.w		#$FFFF,char_col
	lea		stringspace,a0
	clr.b		(a0)
	move.l		a0,numtext_ptr
	ifd		frames_per_sec
	lea		fps,a0
	bsr		pushtext
	bsr		average_times
	move.l		#200*8,d0
	swap		d0
	divu.l		d1,d0
	push.l		d0
	mulu.w		#10000,d0
	swap		d0
	ext.l		d0
	moveq		#4,d7
	bsr		pushdigits
	lea		point,a0
	bsr		pushtext
	pop.l		d0
	swap		d0
	ext.l		d0
	moveq		#1,d7
	bsr		pushdigits
	elseif
	lea		frames,a0
	bsr		pushtext
	bsr		average_times
	move.l		d1,d0
	moveq		#1,d7
	bsr		pushdigits
	endc
	move.l		numtext_ptr,a0
	jsr		print_line
	endc
	endc
	rts

*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
average_times:
*-------------------------------------------------------*
	ifd		frames_per_sec
	lea		fc_history,a0
	moveq		#8-2,d0
	move.l		fpsc,d1
	clr.l		fpsc
	move.l		d1,d3
.lp:	move.l		4(a0),d2
	add.l		d2,d1
	move.l		d2,(a0)+
	dbra		d0,.lp
	move.l		d3,(a0)
	add.l		fpso,d1
	lsr.l		d1
	move.l		d1,fpso
	elseif
	move.l		ovbls,d1
	add.l		vbls,d1
	clr.l		vbls
	lsr.l		d1
	move.l		d1,ovbls
	endc
	rts
	
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
pushdigits:
*-------------------------------------------------------*
;	d0 	= 	number
	move.l		numtext_ptr,a0
	move.l		a0,a1
	moveq		#'0',d3
	move.l		d3,d1
	moveq		#10,d4
	tst.l		d0
	beq.s		.zero
.loop	ext.l		d0
	divu		d4,d0
	move.l		d0,d1
	swap		d1
	add.w		d3,d1
.zero:	move.b		d1,-(a0)
	subq.l		#1,d7
	bgt.s		.loop
	tst.w		d0
	bne.s		.loop
	move.l		a0,numtext_ptr
	rts

*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
pushtext:
*-------------------------------------------------------*
	move.l		numtext_ptr,a1
	moveq		#-1,d0
.lp	addq.l		#1,d0
	tst.b		(a0)+
	bne.s		.lp
	subq.l		#1,a0
	bra.s		.go
.cop:	move.b		-(a0),-(a1)
.go:	dbra		d0,.cop
	move.l		a1,numtext_ptr
	rts

*-------------------------------------------------------*
*	Print single character				*
*-------------------------------------------------------*
*	d0		character			*
*	a1		screen				*			
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
print_char:
*-------------------------------------------------------*
	move.w		char_y,d7
	move.l		a1,a3
	mulu		scrwidth,d7
	add.l		d7,d7
	add.l		d7,a3
	move.w		char_x,d7
	ext.l		d7
	add.l		d7,d7
	add.l		d7,a3
	lea		(a6,d0.w),a2
	move.w		char_col,d1
	move.w		#256,d6
	move.w		scrwidth,d7
	ext.l		d6
	ext.l		d7
	add.l		d7,d7
	moveq		#6-1,d4
	moveq		#0,d3
.ylp	move.l		a3,a5
	move.b		(a2),d0
	add.b		d0,d0
	bcc.s		.n1
	move.w		d1,(a5)
.n1	addq.l		#2,a5
	add.b		d0,d0
	bcc.s		.n2
	move.w		d1,(a5)
.n2	addq.l		#2,a5
	add.b		d0,d0
	bcc.s		.n3
	move.w		d1,(a5)
.n3	addq.l		#2,a5
	add.b		d0,d0
	bcc.s		.n4
	move.w		d1,(a5)
.n4	addq.l		#2,a5
	add.b		d0,d0
	bcc.s		.n5
	move.w		d1,(a5)
.n5	addq.l		#2,a5
	add.b		d0,d0
	bcc.s		.n6
	move.w		d1,(a5)
.n6	addq.l		#2,a5
	tst.b		d3
	beq.s		.next
	add.b		d0,d0
	bcc.s		.n7
	move.w		d1,(a5)
.n7	addq.l		#2,a5
	add.b		d0,d0
	bcc.s		.next
	move.w		d1,(a5)
.next	add.l		d6,a2
	add.l		d7,a3
	dbra		d4,.ylp
	rts

*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
print_line:
*-------------------------------------------------------*
	pushall
	move.l		fontptr,a6
	move.l		screen,a1
.loop	moveq		#0,d0
	move.b		(a0)+,d0
	beq.s		.out
	cmp.w		#27,d0
	beq.s		.ctrl
	bsr		print_char
	move.w		textgap,d0
	add.w		d0,char_x
	bra.s		.loop
.out	popall
	rts
.ctrl	move.b		(a0)+,d0
	cmp.b		#"Y",d0
	beq.s		.pos
	bra.s		.loop
.pos	moveq		#0,d0
	move.b		(a0)+,d0
	move.w		d0,char_x
	moveq		#0,d0
	move.b		(a0)+,d0
	add.w		d0,char_x
	moveq		#0,d0
	move.b		(a0)+,d0
	move.w		d0,char_y
	bra.s		.loop

*-------------------------------------------------------*
init_font:
*-------------------------------------------------------*
	move.w		#6,textgap
	move.l		#font,fontptr
	move.l		fontptr,a0
	lea		truefont,a1
	move.w		#256-1,d0
.char:	move.b		(a0)+,(a1)
	move.b		(a0)+,256*1(a1)
	move.b		(a0)+,256*2(a1)
	move.b		(a0)+,256*3(a1)
	move.b		(a0)+,256*4(a1)
	move.b		(a0)+,256*5(a1)
	addq.l		#1,a1
	dbra		d0,.char
	lea		truefont,a0
	move.l		fontptr,a1
	move.w		#256-1,d0
.copy	move.l		(a0)+,(a1)+
	move.w		(a0)+,(a1)+
	dbra		d0,.copy
	rts

*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
framecounter:
*-------------------------------------------------------*
	ifnd		debuggable
	subq.w		#1,move_flag
	and.w		#4-1,move_flag
	bne.s		.sk
	pushall
	bsr		player_movement
	popall
.sk:
	endc

;	jsr		run_demo

*-------------------------------------------------------*
	addq.l		#1,fpsc
	addq.l		#1,clock
*-------------------------------------------------------*
	ifd		debuggable
	jmp		([old_timerc.l])
	elseif
	bclr		#5,$FFFFFA11.w
	rte
	endc

*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
new_vbi:
*-------------------------------------------------------*
	ifnd		debuggable
*-------------------------------------------------------*
	push.l		vbi_direction(pc)
	rts
*-------------------------------------------------------*
vbi_direction:	dc.l	active_vbi
*-------------------------------------------------------*
active_vbi:
*-------------------------------------------------------*
	move.b		#0,tbcr.w
	push.l		d0
	move.w		height,d0
	tst.b		ilace_active
	beq.s		.no
	lsr.w		#1,d0
.no:	subq.w		#8,d0
	move.b		d0,tbdr.w
	move.b		#8,tbcr.w
	pop.l		d0
*-------------------------------------------------------*
	endc
*-------------------------------------------------------*
	ifd		debuggable
	pushall
	bsr		player_movement
	popall
	endc
*-------------------------------------------------------*
	tst.w		timer
	beq.s		.nd
	subq.w		#1,timer
.nd:	addq.l		#1,vbls
	addq.w		#1,frame
	ifnd		debuggable
	addq.l		#1,$462.w
	addq.l		#1,$466.w
	move.l		#bypass_vbi,vbi_direction
	endc
*-------------------------------------------------------*
bypass_vbi:
*-------------------------------------------------------*
	ifd		debuggable
	rts
	elseif
	rte
	endc

*-------------------------------------------------------*
	ifnd		debuggable
*-------------------------------------------------------*
stabilizer_b:
*-------------------------------------------------------*
	move.l		#active_vbi,vbi_direction
	move.b		#0,tbcr.w
	bclr		#0,isra.w
	rte
*-------------------------------------------------------*
	endc
*-------------------------------------------------------*

*-------------------------------------------------------*
			datlong
*-------------------------------------------------------*
	
fps:			dc.b	" FPS",0
frames:			dc.b	" VBL",0
point:			dc.b	".",0

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

old_vbi:		ds.l	1
old_timerb:		ds.l	1
old_timerc:		ds.l	1
numtext_ptr:		ds.l	1
fontptr:		ds.l	1

vbls:			ds.l	1
ovbls:			ds.l	1
fpsc:			ds.l	1
fpso:			ds.l	1
fc_history:		ds.l	8

timer:			ds.w	1
char_x:			ds.w	1
char_y:			ds.w	1
char_col:		ds.w	1
textgap:		ds.w	1

move_flag:		ds.w	1

truefont:		ds.w	256*8*8

			ds.b	256
stringspace:		ds.b	1

old_iera:		ds.b	1
old_ierb:		ds.b	1
old_imra:		ds.b	1
old_imrb:		ds.b	1

timing_on:		ds.b	1

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
