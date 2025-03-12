;----------------------------------------------------------
; RAYTRACE.S : faked raytracing effect
;----------------------------------------------------------
; TOBE / MJJPROD

win_w:		equ			240
win_h:		equ			150
win_s:		equ			win_w*win_h
win_p:		equ			(320-win_w)/2

off_w:		equ			win_w/2
off_h:		equ			win_h
off_s:		equ			off_w*off_h

tex_w:		equ			64
tex_h:		equ			64
tex_l:		equ			7
tex_s:		equ			tex_w*tex_h*4

pic_time:	equ			625
ray_time:	equ			869

;----------------------------------------------------------
	SECTION TEXT
;----------------------------------------------------------

setpal	MACRO
	lea			pal(pc),		a1
	adda.w		pal_idx(pc),	a1
	movem.l		(a1),			d0-d7
	movem.l		d0-d7,			$FFFF8240.W
	ENDM

main:
	clr.l		-(sp)
	move.w		#$20,			-(sp)		; super()
	trap		#1
	addq.l		#6,				sp
	move.l		d0,user_stack
	
	bsr			ikbd_flush

	move.w		#$25,			-(sp)		; vsync
	trap		#14
	addq.l		#2,				sp

	move.w		#$2700,			sr			; setup sys

	lea			$FFFFFA00.W,	a0
	move.b		$07(a0),user_mfp7
	move.b		$09(a0),user_mfp9
	clr.b		$07(a0)
	clr.b		$09(a0)
	move.b		$484.W,user_kbd
	clr.b		$484.W
	move.l		$44E.W,user_scr
	lea			$FFFF8260.W,	a0
	move.b		(a0),user_res
	lea			$70.W,			a0
	move.l		(a0),user_vbl
	move.l		#simple_vbl,	(a0)

	lea			$FFFF8240.W,	a0
	lea			user_pal,		a1
	movem.l		(a0),			d0-d7
	movem.l		d0-d7,			(a1)

	lea			user_pal,		a0
	bsr			build_pal

	move.w		#$2300,			sr

	move.w		#32*8,pal_idx
	moveq		#7,				d0
.fadein:
	subi.w		#32,pal_idx
	bsr			render_vsync
	move.w		d0,				-(sp)
	setpal
	move.w		(sp)+,			d0
	dbra		d0,.fadein

	move.w		#$2700,			sr

	clr.b		$FFFF8260.W

	lea			text,			a0
	move.l		user_scr,		a1
	bsr			unpack_4x4
	move.l		user_scr,		a0
	lea			text,			a1
	move.w		#3999,			d0
.copy:
	movem.w		(a0)+,			d1-d4
	movem.w		d1-d3,			(a1)
	addq.w		#6,				a1
	dbra		d0,.copy

	move.l		#-256,			d1
	move.l		#scr_buf+255,	d0
	and.l		d1,				d0
	move.l		#32768,			d1
	move.l		d0,scr_1
	add.l		d1,				d0
	move.l		d0,scr_2
	add.l		d1,				d0
	move.l		d0,scr_3
	move.l		user_scr,scr_4

	bsr			build_pix					; build pixel table

	lea			distort_cod1,	a0			; prepare code buffers
	moveq		#6,				d0
	bsr			prepare_code
	lea			distort_cod2,	a0
	move.w		#166,			d0
	bsr			prepare_code

	move.l		#distort_cod2,cod_1
	move.l		#distort_cod1,cod_2
	
	clr.w		map_x
	clr.w		map_y
	clr.w		crv_off
	clr.w		txt_idx
	clr.w		esc_flag
	clr.w		do_quit

	lea			sid_tvs,		a0			; setup zik
	lea			sid_tri,		a1
	jsr			sid_drv

	move.l		#render_vbl,	$70.W

	move.w		#$2300,			sr

	;---------------------------------------------------------

	lea			dominium,		a0
	bsr			pic_loop

	;---------------------------------------------------------

main_loop:
	move.w		#8+(160*10),scr_off

	move.w		#0*2400,		d0
	move.w		#180*160,		d1
	bsr			draw_text

	move.w		#0*160,			d0
	move.w		#(160+10)*160,	d1
	bsr			draw_lines

	move.w		#(160*13),		d0
	bsr			ray_loop

	;---------------------------------------------------------

	move.w		#32+(160*25),scr_off

	bsr			draw_small

	move.w		#15*160,		d0
	move.w		#(175+10)*160,	d1
	bsr			draw_lines

	move.w		#(160*28),		d0
	bsr			ray_loop

	;---------------------------------------------------------

	move.w		#8+(160*40),scr_off

	move.w		#1*2400,		d0
	move.w		#0*160,			d1
	bsr			draw_text

	move.w		#30*160,		d0
	move.w		#(190+10)*160,	d1
	bsr			draw_lines

	move.w		#(160*43),		d0
	bsr			ray_loop

	;---------------------------------------------------------

	move.w		#32+(160*25),scr_off

	bsr			draw_small

	move.w		#15*160,		d0
	move.w		#(175+10)*160,	d1
	bsr			draw_lines

	move.w		#(160*28),		d0
	bsr			ray_loop

	;---------------------------------------------------------

	move.w		#8+(160*10),scr_off

	move.w		#2*2400,		d0
	move.w		#180*160,		d1
	bsr			draw_text

	move.w		#0*160,			d0
	move.w		#(160+10)*160,	d1
	bsr			draw_lines

	move.w		#(160*13),		d0
	bsr			ray_loop

	;---------------------------------------------------------

	move.w		#32+(160*25),scr_off

	bsr			draw_small

	move.w		#15*160,		d0
	move.w		#(175+10)*160,	d1
	bsr			draw_lines

	move.w		#(160*28),		d0
	bsr			ray_loop

	;---------------------------------------------------------

	move.w		#8+(160*40),scr_off

	move.w		#3*2400,		d0
	move.w		#0*160,			d1
	bsr			draw_text

	move.w		#30*160,		d0
	move.w		#(190+10)*160,	d1
	bsr			draw_lines

	move.w		#(160*43),		d0
	bsr			ray_loop

	;---------------------------------------------------------

	move.w		#32+(160*25),scr_off

	bsr			draw_small

	move.w		#15*160,		d0
	move.w		#(175+10)*160,	d1
	bsr			draw_lines

	move.w		#(160*28),		d0
	bsr			ray_loop

	bra			main_loop

	;---------------------------------------------------------

main_exit:
	st			do_quit

.fadeout:
	subi.w		#32,pal_idx
	blt.s		.endfade
	bsr			render_loop
	setpal
	bra.s		.fadeout
.endfade:
	bsr			clear_screens

	move.l		#render_vbl,	$70.W

	lea			tobe12,			a0
	bsr			pic_loop

;----------------------------------------------------------

demo_exit:

.fadeout:
	subi.w		#32,pal_idx
	blt.s		.endfade
	bsr			render_loop
	setpal
	bra.s		.fadeout
.endfade:
	bsr			clear_screens

	lea			user_pal,		a0
	bsr			build_pal
	clr.w		pal_idx
	moveq		#7,				d0
.fade:
	bsr			render_vsync
	move.w		d0,				-(sp)
	setpal
	move.w		(sp)+,			d0
	addi.w		#32,pal_idx
	dbra		d0,.fade

	bsr			render_vsync

	move.w		#$2700,			sr

	move.l		user_vbl,		$70.W		; restore sys
	lea			$FFFF8240.W,	a0
	lea			user_pal,		a1
	movem.l		(a1),			d0-d7
	movem.l		d0-d7,			(a0)
	move.b		user_res,		$FFFF8260.W
	move.l		user_scr,		d0
	lsr.w		#8,				d0
	lea			$FFFF8200.W,	a0
	move.l		d0,				(a0)

	jsr			sid_drv+8					; stop music

	move.b		user_kbd,		$484.W

	lea			$FFFFFA00.W,	a0
	move.b		user_mfp7,		$07(a0)
	move.b		user_mfp9,		$09(a0)

	move.w		#$2300,			sr

	bsr			ikbd_flush

	move.l		user_stack,		-(sp)
	move.w		#$20,			-(sp)		; super()
	trap		#1
	addq.l		#6,				sp
	clr.w		-(sp)						; exit0()
	trap		#1

;----------------------------------------------------------

; display a picture
;	a0 = picture
pic_loop:
	bsr			show_pic
	clr.w		pal_idx

	sf			vbl_sync
	bsr			render_vsync

	moveq		#7,				d0
.fadein:
	move.w		d0,				-(sp)
	bsr			render_loop
	setpal
	addi.w		#32,pal_idx
	bsr			render_loop
	bsr			render_loop
	move.w		(sp)+,			d0
	dbra		d0,.fadein

	move.w		#pic_time,		d0
.loop:
	move.w		d0,				-(sp)
	bsr			render_loop
	move.w		(sp)+,			d0
	dbra		d0,.loop

	moveq		#7,				d0
.fadeout:
	move.w		d0,				-(sp)
	subi.w		#32,pal_idx
	bsr			render_loop
	setpal
	move.w		(sp)+,			d0
	dbra		d0,.fadeout

	bsr			clear_screens
	rts

; display raytrace
ray_loop:
	bsr			next_fx

	clr.w		pal_idx

	move.l		#render_vbl_swap,$70.W
	sf			vbl_sync
	bsr			render_vsync

	moveq		#7,				d0
.fadein:
	move.w		d0,				-(sp)
	bsr			render_step
	bsr			render_loop
	setpal
	addi.w		#32,pal_idx
	move.w		(sp)+,			d0
	dbra		d0,.fadein

	move.w		#ray_time,		d0
.loop:
	move.w		d0,				-(sp)
	bsr			render_step
	bsr			render_loop
	move.w		(sp)+,			d0
	dbra		d0,.loop

	moveq		#7,				d0
.fadeout:
	move.w		d0,				-(sp)
	subi.w		#32,pal_idx
	bsr			render_step
	bsr			render_loop
	setpal
	move.w		(sp)+,			d0
	dbra		d0,.fadeout

	move.l		#render_vbl,	$70.W
	bsr			clear_screens
	rts

;----------------------------------------------------------

render_loop:
	cmp.b		#185,			$FFFFFC02.W
	bne.s		.no_exit
	tst.b		esc_flag
	beq.s		.no_exit
	sf			esc_flag
	tst.b		do_quit
	bne			demo_exit
	bra			main_exit
.no_exit:
	cmp.b		#57,			$FFFFFC02.W
	seq			esc_flag
	bra			render_vsync

render_step:
	move.b		#8,				$FFFF8800.W
	move.b		$FFFF8800.W,	d4

	andi.w		#$E,			d4
	add.w		d4,				d4
	addq.w		#4,				d4

	lea			crv_off(pc),	a0
	add.w		(a0),			d4
	andi.w		#4095,			d4
	move.w		d4,				(a0)

	lea			curve(pc),		a0
	adda.w		d4,				a0
	move.w		(a0)+,			d0
	move.w		(a0)+,			d1

	moveq		#tex_w-1,		d2
	lea			map_x(pc),		a0
	add.w		(a0),			d0
	and.w		d2,				d0
	move.w		d0,				(a0)+
	add.w		(a0),			d1
	and.w		d2,				d1
	move.w		d1,				(a0)+

	lsl.w		#7,				d1
	add.w		d0,				d1
	add.w		d1,				d1
	add.w		d1,				d1

	move.w		scr_off(pc),	d0
	move.l		scr_1(pc),		a0
	adda.w		d0,				a0
	move.l		scr_2(pc),		a1
	adda.w		d0,				a1
	lea			texture_map+32768,a2
	adda.w		d1,				a2

	moveq		#1,				d0
	swap						d0
	move.l		a2,				a3
	adda.l		d0,				a3
	move.l		a3,				a4
	adda.l		d0,				a4
	move.l		a4,				a5
	adda.l		d0,				a5
	move.l		cod_1(pc),		a6
	jmp			(a6)

simple_vbl:
	st			vbl_sync
	rte

render_vbl:
	move.l		a0,				-(sp)
	st			vbl_sync
	jsr			sid_drv+4
	lea			scr_1+1(pc),	a0
	move.b		(a0)+,			$FFFF8201.W
	move.b		(a0)+,			$FFFF8203.W
	move.l		(sp)+,			a0
	rte

render_vbl_swap:
	movem.l		d0-d4/a0,		-(sp)
	st			vbl_sync
	jsr			sid_drv+4
	lea			scr_1(pc),		a0
	movem.l		(a0),			d0-d3
	move.l		d0,				d4
	movem.l		d1-d4,			(a0)
	lea			cod_1(pc),		a0
	move.l		(a0),			d0
	move.l		cod_2(pc),		(a0)+
	move.l		d0,				(a0)
	lea			scr_1+1(pc),	a0
	move.b		(a0)+,			$FFFF8201.W
	move.b		(a0)+,			$FFFF8203.W
	movem.l		(sp)+,			d0-d4/a0
	rte

render_vsync:
	tst.b		vbl_sync
	beq.s		.wait
	clr.b		$FFFFFA09.W		; emergency cpu recovery ;)
	sf			vbl_sync
	rts
.wait:
	tst.b		vbl_sync
	beq.s		.wait
	sf			vbl_sync
	rts

ikbd_flush:
	btst.b		#0,				$FFFFFC00.W
	beq.s		.exit
	tst.b		$FFFFFC02.W
	bra.s		ikbd_flush
.exit:
	rts

;-- SETUP -------------------------------------------------

; prepare next fx set
next_fx:
	bsr			draw_tile					; draw tile
	move.l		dis_1,			a0			; generate code
	lea			distort_cod1,	a1
	bsr			build_code
	move.l		dis_1,			a0
	lea			off_s(a0),		a0
	lea			distort_cod2,	a1
	bsr			build_code
	move.l		lit_1,			a0			; dither light
	bsr			build_light
	move.l		pal_1,			a0			; build palette
	bsr			build_pal
	move.l		tex_1,			a0			; build texture
	bsr			build_tex

	move.l		dis_1,			d0
	move.l		dis_2,dis_1
	move.l		d0,dis_2

	move.l		lit_1,			d0
	move.l		lit_2,lit_1
	move.l		d0,lit_2

	move.l		pal_1,			d0
	move.l		pal_2,pal_1
	move.l		pal_3,pal_2
	move.l		d0,pal_3

	move.l		tex_1,			d0
	move.l		tex_2,tex_1
	move.l		tex_3,tex_2
	move.l		tex_4,tex_3
	move.l		tex_5,tex_4
	move.l		d0,tex_5

	move.l		til_1,			d0
	move.l		til_2,til_1
	move.l		til_3,til_2
	move.l		til_4,til_3
	move.l		til_5,til_4
	move.l		d0,til_5

	rts

; draw text
;	d0 = text offset
;	d1 = screen offset
draw_text:
	lea			text,			a0
	adda.w		d0,				a0
	move.l		scr_1(pc),		a1
	move.l		scr_2(pc),		a2
	move.l		scr_3(pc),		a3
	move.l		scr_4(pc),		a4
	adda.w		d1,				a1
	adda.w		d1,				a2
	adda.w		d1,				a3
	adda.w		d1,				a4
	moveq		#0,				d4
	move.w		#399,			d0
.text:
	movem.w		(a0)+,			d1-d3
	movem.w		d1-d4,			(a1)
	movem.w		d1-d4,			(a2)
	movem.w		d1-d4,			(a3)
	movem.w		d1-d4,			(a4)
	addq.w		#8,				a1
	addq.w		#8,				a2
	addq.w		#8,				a3
	addq.w		#8,				a4
	dbra		d0,.text
	rts

; draw small text
draw_small:
	lea			text+10080,		a0
	adda.w		txt_idx,		a0
	lea			960(a0),		a1
	move.l		scr_1(pc),		a2
	move.l		scr_2(pc),		a3
	move.l		scr_3(pc),		a4
	move.l		scr_4(pc),		a5

	moveq		#0,				d4
	move.w		#159,			d0
.small:
	movem.w		(a0)+,			d1-d3
	movem.w		d1-d4,			(a2)
	movem.w		d1-d4,			(a3)
	movem.w		d1-d4,			(a4)
	movem.w		d1-d4,			(a5)
	movem.w		(a1)+,			d1-d3
	movem.w		d1-d4,			30560(a2)
	movem.w		d1-d4,			30560(a3)
	movem.w		d1-d4,			30560(a4)
	movem.w		d1-d4,			30560(a5)
	addq.w		#8,				a2
	addq.w		#8,				a3
	addq.w		#8,				a4
	addq.w		#8,				a5
	dbra		d0,.small

	move.w		txt_idx,		d0
	addi.w		#1920,			d0
	cmpi.w		#13440,			d0
	bne.s		.ok
	clr.w						d0
.ok:
	move.w		d0,txt_idx
	rts

; draw two lines
;	d0 = screen offset 1
;	d1 = screen offset 2
draw_lines:
	subi.w		#160,			d1
	move.l		scr_1(pc),		a0
	move.l		scr_2(pc),		a1
	move.l		scr_3(pc),		a2
	move.l		scr_4(pc),		a3
	lea			text+9600,		a4
	lea			120(a4),		a5
	moveq		#0,				d5
	moveq		#19,			d6
.line:
	movem.w		(a4)+,			d2-d4
	movem.w		d2-d5,			0(a0,d0.w)
	movem.w		d2-d5,			0(a0,d1.w)
	movem.w		d2-d5,			0(a2,d0.w)
	movem.w		d2-d5,			0(a2,d1.w)
	movem.w		(a5)+,			d2-d4
	movem.w		d2-d5,			0(a1,d0.w)
	movem.w		d2-d5,			0(a1,d1.w)
	movem.w		d2-d5,			0(a3,d0.w)
	movem.w		d2-d5,			0(a3,d1.w)
	addq.w		#8,				a0
	addq.w		#8,				a1
	addq.w		#8,				a2
	addq.w		#8,				a3
	dbra		d6,.line
	rts

; draw scrolling tile
;	d0 = offset
draw_tile:
	addi.w		#160,			d0
	move.l		til_1,			a0
	move.l		scr_1(pc),		a1
	adda.w		d0,				a1
	move.l		scr_2(pc),		a2
	adda.w		d0,				a2
	move.l		scr_3(pc),		a3
	adda.w		d0,				a3
	move.l		scr_4(pc),		a4
	adda.w		d0,				a4
	moveq		#8,				d0
.lines:
	movea.l		a0,				a5
	moveq		#15,			d1
.line:
	movem.w		(a5)+,			d2-d5
off	SET			0
	REPT 20
		or.w	d2,				off(a1)
		or.w	d3,				off(a2)
		or.w	d4,				off(a3)
		or.w	d5,				off(a4)
off		SET		off+8
	ENDR
	lea			160(a1),		a1
	lea			160(a2),		a2
	lea			160(a3),		a3
	lea			160(a4),		a4
	dbra		d1,.line
	dbra		d0,.lines
	rts

; display a picture
;	a0 = pi1
show_pic:
	move.l		a0,				-(sp)
	bsr			build_pal
	move.l		(sp)+,			a0
	move.l		scr_1,			a1
	bsr			unpack_4x4
	rts

; clear screens
clear_screens:
	moveq		#0,				d1
	moveq		#0,				d2
	moveq		#0,				d3
	moveq		#0,				d4
	moveq		#0,				d5
	moveq		#0,				d6
	moveq		#0,				d7
	move.l		d7,				a4
	move.w		#32000,			d0
	move.l		scr_1(pc),		a0
	adda.w		d0,				a0
	move.l		scr_2(pc),		a1
	adda.w		d0,				a1
	move.l		scr_3(pc),		a2
	adda.w		d0,				a2
	move.l		scr_4(pc),		a3
	adda.w		d0,				a3
	move.w		#499,			d0
.copy:
	movem.l		d1-d7/a4,		-(a0)
	movem.l		d1-d7/a4,		-(a1)
	movem.l		d1-d7/a4,		-(a2)
	movem.l		d1-d7/a4,		-(a3)
	movem.l		d1-d7/a4,		-(a0)
	movem.l		d1-d7/a4,		-(a1)
	movem.l		d1-d7/a4,		-(a2)
	movem.l		d1-d7/a4,		-(a3)
	dbra		d0,.copy
	rts

; build palette
;	a0 = palette
build_pal:
	lea			16*2(a0),		a0
	lea			pal+256,		a1

	moveq		#15,			d6
.split:
	move.w		-(a0),			d0
	move.w		d0,				-(a1)
	move.l		a1,				a2
	move.w		d0,				d1
	move.w		d0,				d2
	andi.w		#$700,			d0			; red
	andi.w		#$70,			d1			; green
	andi.w		#$7,			d2			; blue

	moveq		#6,				d7
.red:
	cmp.w		#$700,			d0
	beq.s		.green
	addi.w		#$100,			d0
.green:
	cmp.w		#$70,			d1
	beq.s		.blue
	addi.w		#$10,			d1
.blue:
	cmp.w		#$7,			d2
	beq.s		.join
	addq.w		#$1,			d2
.join:
	move.w		d0,				d3
	or.w		d1,				d3
	or.w		d2,				d3
	lea			-16*2(a1),		a1
	move.w		d3,				(a1)
	dbra		d7,.red

	move.l		a2,				a1
	dbra		d6,.split
	rts

; build pixel table
build_pix:
	lea			pixel_tab+112,	a0
	moveq		#0,				d7
	moveq		#7,				d0
.pix_loop:
	move.w		d0,				d6
	moveq		#0,				d1
	lsr.w		#1,				d6
	addx.w		d7,				d1
	moveq		#0,				d2
	lsr.w		#1,				d6
	addx.w		d7,				d2
	moveq		#0,				d3
	lsr.w		#1,				d6
	addx.w		d7,				d3
	movea.l		a0,				a1
	moveq		#15,			d6
.pix_shift:
	movem.l		d1-d3,			(a1)
	lea			256(a1),		a1			; next shift
	add.w		d1,				d1
	add.w		d2,				d2
	add.w		d3,				d3
	dbra		d6,.pix_shift
	lea			-16(a0),		a0			; prev color
	dbra		d0,.pix_loop

	lea			pixel_tab+112,	a0
	moveq		#15,			d0
.pix_last:
	movem.l		(a0),			d1-d3
	movem.l		d1-d3,			16(a0)
	lea			256(a0),		a0
	dbra		d0,.pix_last

	lea			light_tab+512,	a0
	moveq		#$F,			d2
	move.w		#255,			d0
.pix_light:
	move.w		d0,				d1
	and.w		d2,				d1
	move.b		d1,				-(a0)
	move.w		d0,				d1
	lsr.w		#4,				d1
	move.b		d1,				-(a0)
	dbra		d0,.pix_light
	rts

; dither lightmap
;	a0 = light
build_light:

	lea			light_buf,		a1
	lea			light_tab,		a2
	move.w		#(win_s/32)-1,	d0
.unpack:
	REPT 16
		clr.w					d1
		move.b	(a0)+,			d1
		add.w	d1,				d1
		move.w	0(a2,d1.w),		(a1)+
	ENDR
	dbra		d0,.unpack

light_1		MACRO
	move.b		(a0)+,			d3		; 8
	lsr.w		#1,				d3		; 8
	move.w		d3,				d5		; 4
	addx.w		d4,				d3		; 4
	swap						d3		; 4
	move.w		d5,				d3		; 4
	lsl.l		#4,				d3		; 16
	or.w		2(a5,d3.w),		d0
	or.w		6(a5,d3.w),		d1
	or.w		10(a5,d3.w),	d2
	swap						d3		; 4  = 52
	or.l		2(a5,d3.w),		d0
	or.l		6(a5,d3.w),		d1
	or.l		10(a5,d3.w),	d2
	lea			-256(a5),		a5
	ENDM

light_2		MACRO
	move.b		(a0)+,			d3		; 8
	lsr.w		#1,				d3		; 8
	move.w		d3,				d5		; 4
	addx.w		d4,				d5		; 4
	swap						d3		; 4
	move.w		d5,				d3		; 4
	lsl.l		#4,				d3		; 16
	or.w		2(a5,d3.w),		d0
	or.w		6(a5,d3.w),		d1
	or.w		10(a5,d3.w),	d2
	swap						d3		; 4 = 52
	or.l		2(a5,d3.w),		d0
	or.l		6(a5,d3.w),		d1
	or.l		10(a5,d3.w),	d2
	lea			-256(a5),		a5
	ENDM

	lea			light_buf,		a0
	move.l		scr_1,			a1
	adda.w		scr_off,		a1
	move.l		scr_2,			a2
	adda.w		scr_off,		a2
	move.l		scr_3,			a3
	adda.w		scr_off,		a3
	move.l		scr_4,			a4
	adda.w		scr_off,		a4
	moveq		#0,				d3
	moveq		#0,				d4
	moveq		#0,				d5

	move.w		#(win_h/2)-1,	d7
.light_y:

	moveq		#(win_w/16)-1,	d6
.light_x1:
	lea			pixel_tab+3840,	a5

	moveq		#0,				d0
	moveq		#0,				d1
	moveq		#0,				d2
	light_1
	light_2
	light_1
	light_2
	light_1
	light_2
	light_1
	light_2
	light_1
	light_2
	light_1
	light_2
	light_1
	light_2
	light_1
	light_2

	movem.w		d0-d2,			(a1)
	addq.w		#8,				a1
	movem.w		d0-d2,			(a3)
	addq.w		#8,				a3
	swap		d0
	swap		d1
	swap		d2
	movem.w		d0-d2,			(a2)
	addq.w		#8,				a2
	movem.w		d0-d2,			(a4)
	addq.w		#8,				a4
	dbra		d6,.light_x1

  	lea			win_p(a1),		a1
  	lea			win_p(a2),		a2
  	lea			win_p(a3),		a3
  	lea			win_p(a4),		a4

	moveq		#(win_w/16)-1,	d6
.light_x2:
	lea			pixel_tab+3840,	a5

	moveq		#0,				d0
	moveq		#0,				d1
	moveq		#0,				d2
	light_2
	light_1
	light_2
	light_1
	light_2
	light_1
	light_2
	light_1
	light_2
	light_1
	light_2
	light_1
	light_2
	light_1
	light_2
	light_1

	movem.w		d0-d2,			(a1)
	addq.w		#8,				a1
	movem.w		d0-d2,			(a3)
	addq.w		#8,				a3
	swap		d0
	swap		d1
	swap		d2
	movem.w		d0-d2,			(a2)
	addq.w		#8,				a2
	movem.w		d0-d2,			(a4)
	addq.w		#8,				a4
	dbra		d6,.light_x2

  	lea			win_p(a1),		a1
  	lea			win_p(a2),		a2
  	lea			win_p(a3),		a3
  	lea			win_p(a4),		a4

	dbra		d7,.light_y

	rts

; build quad texture map
;	a0 = texture
build_tex:
	lea			texture_map,	a1
	lea			tex_w*4(a1),	a2
	moveq		#3,				d4
	moveq		#0,				d1
	move.w		#tex_h-1,		d7
.tex_loopy:
	move.w		#(tex_w/16)-1,	d6
.tex_loopx:
	move.w		(a0)+,			d0
	REPT 16
		add.w	d0,				d0
		scs						d1
		and.w	d4,				d1
		move.l	d1,				(a1)
		move.b	d1,				(a1)
		move.l	(a1)+,			(a2)+
	ENDR
	dbra		d6,.tex_loopx
	lea			tex_w*4(a1),	a1
	lea			tex_w*4(a2),	a2
	dbra		d7,.tex_loopy

	lea			texture_map,	a1
	move.l		#tex_s*4,		d0
	move.l		a1,				a2
	adda.l		d0,				a2
	move.l		a2,				a3
	adda.l		d0,				a3
	move.l		a3,				a4
	adda.l		d0,				a4
	move.w		#(tex_s/32)-1,	d7
.tex_shift:
	REPT 16
		move.l	(a1)+,			d0
		add.l	d0,				d0
		add.l	d0,				d0
		move.l	d0,				(a2)+
		add.l	d0,				d0
		add.l	d0,				d0
		move.l	d0,				(a3)+
		add.l	d0,				d0
		add.l	d0,				d0
		move.l	d0,				(a4)+
	ENDR
	dbra		d7,.tex_shift

tex_copy	MACRO
	move.w		#(tex_s*2/512)-1,d7
.\@:
off	SET			0
	REPT 16
		movem.l	(a1)+,			d0-d6/a3
		movem.l	d0-d6/a3,		off(a2)
off		SET		off+32
	ENDR
	lea			512(a2),		a2
	dbra		d7,.\@
	ENDM

	lea			texture_map,	a1
	move.l		a1,				a2
	adda.l		#tex_s*2,		a2
	tex_copy
	adda.l		#tex_s*2,		a1
	adda.l		#tex_s*2,		a2
	tex_copy
	adda.l		#tex_s*2,		a1
	adda.l		#tex_s*2,		a2
	tex_copy
	adda.l		#tex_s*2,		a1
	adda.l		#tex_s*2,		a2
	tex_copy

	rts

; prepare code
;	a0 = code buffer
;	d0 = offset
prepare_code:
	move.w		#(off_h/2)-1,	d1
.prepare_y:
	move.w		#(off_w/8)-1,	d2
.prepare_x:
	move.l		#$322D0000,		(a0)+	; move.w	src(a5),d1
	move.l		#$826C0000,		(a0)+	; or.w		src(a4),d1
	move.l		#$826B0000,		(a0)+	; or.w		src(a3),d1
	move.l		#$826A0000,		(a0)+	; or.w		src(a2),d1
	move.l		#$826D0000,		(a0)+	; or.w		src+2(a5),d1
	move.l		#$826C0000,		(a0)+	; or.w		src+2(a4),d1
	move.l		#$826B0000,		(a0)+	; or.w		src+2(a3),d1
	move.l		#$826A0000,		(a0)+	; or.w		src+2(a2),d1
	move.w		#$3141,			(a0)+	; move.w	d1,dst(a0)
	move.w		d0,				(a0)+
	move.w		#$3341,			(a0)+	; move.w	d1,dst(a1)
	move.w		d0,				(a0)+
	addq.w		#8,				d0
	dbra.w		d2,.prepare_x
	addi.w		#win_p+160,		d0
	dbra.w		d1,.prepare_y
	move.w		#$4E75,			(a0)+	; rts
	rts

; generate code
;	a0 = offset map
;	a1 = code buffer
build_code:
	lea			off_s/2(a0),	a2
	move.w		#-32768,		d7
	move.w		#-32766,		d6
	move.w		#(off_h/2)-1,	d0
.build_y:
	move.w		#(off_w/8)-1,	d1
.build_x:

calc_off:	MACRO
	moveq		#0,				d3
	move.b		(a2)+,			d3
	lsl.w		#tex_l,			d3
	add.b		(a0)+,			d3
	add.w		d7,				d3
	move.w		d3,				\1(a1)
	ENDM

calc_off2:	MACRO
	moveq		#0,				d3
	move.b		(a2)+,			d3
	lsl.w		#tex_l,			d3
	add.b		(a0)+,			d3
	add.w		d6,				d3
	move.w		d3,				\1(a1)
	ENDM

	calc_off	2						; move.w	src(a5),d1
	calc_off	6						; or.w		src(a4),d1
	calc_off	10						; or.w		src(a3),d1
	calc_off	14						; or.w		src(a2),d1
	calc_off2	18						; or.w		src+2(a5),d1
	calc_off2	22						; or.w		src+2(a4),d1
	calc_off2	26						; or.w		src+2(a3),d1
	calc_off2	30						; or.w		src+2(a2),d1
	lea			40(a1),			a1

	dbra.w		d1,.build_x
	dbra.w		d0,.build_y
	rts


;----------------------------------------------------------
;	IMPORTS
;----------------------------------------------------------


	INCLUDE		"UN4X4.S"


;----------------------------------------------------------
	SECTION DATA
;----------------------------------------------------------


vbl_sync:		dc.w			0

map_x:			dc.w			0
map_y:			dc.w			0

crv_off:		dc.w			0

scr_1:			dc.l			0
scr_2:			dc.l			0
scr_3:			dc.l			0
scr_4:			dc.l			0
scr_off:		dc.w			0

cod_1:			dc.l			0
cod_2:			dc.l			0

pal_idx:		dc.w			0
pal:			dcb.w			16*8, 0

curve:			INCBIN			"CURVE.BIN"		; 4096

sid_tvs:		INCBIN			"SID.TVS"
sid_tri:		INCBIN			"SID.TRI"
sid_drv:		INCBIN			"SID.DRV"

palette_001:	INCBIN			"PALETTE.001"	; 32
palette_002:	INCBIN			"PALETTE.002"	; 32
palette_003:	INCBIN			"PALETTE.003"	; 32

texture_001:	INCBIN			"TEXTURE.001"	; 512
texture_002:	INCBIN			"TEXTURE.002"	; 512
texture_003:	INCBIN			"TEXTURE.003"	; 512
texture_004:	INCBIN			"TEXTURE.004"	; 512
texture_005:	INCBIN			"TEXTURE.005"	; 512

light_001:		INCBIN			"LIGHT.001"		; 18000
light_002:		INCBIN			"LIGHT.002"		; 18000

distort_001:	INCBIN			"DISTORT.001"	; 36000
distort_002:	INCBIN			"DISTORT.002"	; 36000

dominium:		INCBIN			"DOMINIUM.4X4"	; 24032
tobe12:			INCBIN			"TOBE12.4X4"	; 24032

text:			INCBIN			"TEXT.4X4"		; 24032

tiles:			INCBIN			"TILES.BIN"		; 640

dis_1:			dc.l			distort_001
dis_2:			dc.l			distort_002

lit_1:			dc.l			light_001
lit_2:			dc.l			light_002

pal_1:			dc.l			palette_001
pal_2:			dc.l			palette_002
pal_3:			dc.l			palette_003

tex_1:			dc.l			texture_001
tex_2:			dc.l			texture_002
tex_3:			dc.l			texture_003
tex_4:			dc.l			texture_004
tex_5:			dc.l			texture_005

til_1:			dc.l			tiles+(128*0)
til_2:			dc.l			tiles+(128*1)
til_3:			dc.l			tiles+(128*2)
til_4:			dc.l			tiles+(128*3)
til_5:			dc.l			tiles+(128*4)


;----------------------------------------------------------
	SECTION BSS
;----------------------------------------------------------


txt_idx:		ds.w			1

esc_flag:		ds.w			1
do_quit:		ds.w			1

user_stack:		ds.l			1
user_pal:		ds.w			16
user_scr:		ds.l			1
user_vbl:		ds.l			1
user_res:		ds.w			1
user_mfp7:		ds.w			1
user_mfp9:		ds.w			1
user_kbd:		ds.w			1

pixel_tab:		ds.l			16*4*16

light_tab:		ds.w			256
light_buf:		ds.b			win_s						; 36000

distort_cod1:	ds.b			((win_w/16)*76*win_h/2)+2
distort_cod2:	ds.b			((win_w/16)*76*win_h/2)+2	; 171004

texture_map:	ds.l			tex_s*4						; 262144

scr_buf:		ds.b			(32000*3)+256


;----------------------------------------------------------
	END
;----------------------------------------------------------


