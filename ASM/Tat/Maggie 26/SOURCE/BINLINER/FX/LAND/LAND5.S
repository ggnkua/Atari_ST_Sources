;
;
;
;
;
; LAND.S
; of hope and glory.
; this is just getting ridiculous!
;
;
;
;
;
;
;
;
;
;
;
;
;
;
loadtex			equ	0
messageon		equ	1

rgb			equ	1
flash			equ	0
vblwait			equ	0
keys			equ	0
tracker_on		equ	0

number_of_colours 	equ	4

bitplane_mode		equ	0
mapping_mode		equ	1
motion_blur_mode	equ	0
animation_mode		equ	0
morphing_mode		equ	0

xmax			equ	383
ymax			equ	099

movespeed		equ 16*4
movespeed2		equ $100

screenlines		equ	200/2
bytesperline		equ	384*2
lines			equ	200/2
pixels			equ	384

object_width		equ	384
object_height		equ	200/2

direction		equ	1		;(motion blur)







back_colour	equ	1*$08410841
noscreens	equ	3
demo		equ	0






start:
		output	e:\demos\test\mars.prg

	ifne	demo
		include	d:\source\tdf\main\equates.s
		opt	nodebug
	endc


	ifeq	demo
		include d:\source\tdf\main\equates.s
		include	tosstart.i
	else
		include	demstart.i
	endc


;--------------------------------------------------------------
message:	dc.b	27,"E"
		dc.b	"Binliner landscape preview 14/7/98",13,10
		dc.b	"fuggy as buck",13,10
		dc.b	"tat",0
		even

preload:
		ifne	loadtex
		loadfile "groundk.god",texmap_64-6
		endc
		rts

display_routine:
		bsr	do_effects
	ifeq	demo
		illegal
	else
		move.l	(a7)+,d0
		rts
	endc


initialize_routine:
		ifeq	keys
		lea	cam_movement,a0
		lea	cam_restart_pos,a1
		jsr	cam_set
		jsr	cam_calc
		endc

		lea	texmap_64,a0
		jsr	calc_shademap_buffer
		
		jsr	calc_colour_table
		jsr	calc_land_tex_table

		bsr	set_res
		;lea	colour_list_gouraud,a0
		;bsr	calc_colours_gouraud
		;bsr	tex_calc_envmap
		rts

do_effects:

		bsr	set_palette
		bsr	clearscreens

		init_dsp_routine dsp_routine_object,$210.w
		jsr	sendoneover

		move.w	#60,c_persp
		bsr	send_clipping

		lea	Land_Scene,a0
		jsr	send_object

		bsr	send_drawlists
		bsr	send_world

		lea	texmap_64,a0
		bsr	send_texmap

		move.w	#$2300,sr
.infinite:
		move.w	#10-1,d0
		bsr	main_loop
		bra	.infinite

		jsr	wait_senddsp
		move.l	#"RTS",$ffffa204.w
		rts

main_loop:
		move.l	d0,-(a7)
		;bsr	send_objects

		move.l	(a7)+,d0
		subq.w	#1,d0
.main_loop
		move.w	d0,-(a7)
		bsr	create_frame
		move.w	(a7)+,d0
		dbf	d0,.main_loop
		rts

create_frame:
		bsr	make_landscape

		bsr	send_objects
		jsr	spin_object
		bsr	start_world
		jsr	clearscreen_fast
		bsr	draw_object
		;bsr	draw_flare
		bsr	screen_swap
		rts


set_res:	
		;include	d:\source\4k2\vga.s
		include	d:\data\tdf\res\mars2.s
		rts

;--------------------------------------------------------------
make_landscape:

		bsr	set_landscape_pos

		lea	$ffffa204.w,a0
		 wait_transmit
		move.l	#"POI",(a0)
		 wait_transmit
		move.l	#0,(a0)			;send object no.
		 wait_transmit
		move.l	#17*17*3,(a0)

		move.w	tempsin,d0
		addq.w	#1,d0
		and.w	#255,d0
		move.w	d0,tempsin

		lea	land_table,a3
		add.l	land_offset,a3
		lea	land_shade_table,a4

		move.l	#-32000,d2
		sub.l	vertex_offset+4,d2
		move.w	#17-1,d0
.loop1:
		move.l	#-32000,d3
		sub.l	vertex_offset+0,d3
		move.w	#17-1,d1
.loop2:
		 wait_transmit
		move.l	d2,(a0)

		moveq	#0,d4
		move.b	(a3)+,d4
		mulu.w	#100,d4
		sub.l	#100*$80,d4
		move.l	d4,(a0)

		move.l	d3,(a0)

		move.w	d2,d5		;now calc the depth cue
		move.w	d3,d6
		muls.w	d5,d5	
		muls.w	d6,d6
		add.l	d6,d5
		swap	d5
		lsr.w	#6,d5
		move.w	d5,(a4)+	;save this shade value

		add.l	#60000/16,d3
		dbf	d1,.loop2
		lea	256-17(a3),a3
		add.l	#60000/16,d2
		dbf	d0,.loop1

; ---------------------------------------------------------------

; Now do the textures:
		 wait_transmit
		move.l	#"TPO",(a0)
		 wait_transmit
		move.l	#0,(a0)			;send object no.
		 wait_transmit
		move.l	#17*17*3,(a0)

		lea	levelval,a4
		lea	land_tex_table,a1
		lea	land_shade_table,a5

		move.l	land_offset,d0
		mulu.w	#6,d0
		add.l	d0,a1

		move.w	#17-1,d0
.loop3:
		move.w	#17-1,d1
.loop4:
		 wait_transmit
		move.w	(a1)+,d2
		lsl.l	#8,d2
		move.l	d2,(a0)
		 wait_transmit
		move.w	(a1)+,d2
		lsl.l	#8,d2
		move.l	d2,(a0)

		move.w	(a5)+,d2		;get shade from calcs
		add.w	(a1)+,d2		;shading value from land
		move.l	(a4,d2.w*4),d2
		move.l	d2,(a0)			; darkness

		dbf	d1,.loop4
		lea	6*(256-17)(a1),a1
		dbf	d0,.loop3
		rts

; ---------------------------------------------------------------
set_landscape_pos:
		movem.l	landsin(pc),d0-d1
		add.w	#+$0005,d0
		add.w	#-$0003,d1
		and.w	#$1fff,d0
		and.w	#$1fff,d1
		movem.l	d0-d1,landsin
		lea	sinetable,a0
		move.w	(a0,d0.w*2),d0
		lea	sinetable+$1000,a0
		move.w	(a0,d1.w*2),d1
		add.w	#$8000,d0
		add.w	#$8000,d1

		mulu.w	#200*256,d0
		mulu.w	#200*256,d1
		swap	d0
		swap	d1

; d0-d1 are now values 0000 to 240*256

; we want 0-255:
		move.w	d0,d2
		move.w	d1,d3

; Get the fractional part first
		and.w	#$ff,d2
		and.w	#$ff,d3
		movem.w	d2/d3,shade_offset
		muls.w	#4000/256,d2
		muls.w	#4000/256,d3
		movem.l	d2/d3,vertex_offset

; Work out the position in the land table
; convert to +ve only
		;add.w	#$8000,d0
		;add.w	#$8000,d1
		lsr.w	#8,d0
		lsr.w	#8,d1
; we want 256*d1+d0
		lsl.w	#8,d1		;ugh!
		add.w	d1,d0
		moveq	#0,d2
		move.w	d0,d2
		move.l	d2,land_offset
		rts

; ---------------------------------------------------------------
landsin		dc.l	$2120,$220
vertex_offset	dc.l	0,0
land_offset	dc.l	0
shade_offset	dc.w	0,0
; ---------------------------------------------------------------

calc_land_tex_table:
		lea	land_tex_table,a0
		lea	land_table,a1
		move.w	#256,d0
		move.w	#$800,d2
.loop:
		move.w	#256,d1
		move.w	#$800,d3
.loop2:
		add.w	#$2000,d3
		and.w	#$7fff,d3
		move.w	d3,(a0)+
		move.w	d2,(a0)+
; calc the shading value here:
		bsr	.calc_shading
		move.w	d7,(a0)+
		subq.w	#1,d1
		bne.s	.loop2

		add.w	#$2000,d2
		and.w	#$7fff,d2

		subq.w	#1,d0
		bne.s	.loop
		rts

.calc_shading:
		movem.l	d0-d6,-(a7)
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		move.b	-256*1(a1),d1
		move.b	+256*1(a1),d2
		move.b	-001*1(a1),d3
		move.b	+001*1(a1),d4
		move.b	(a1)+,d0
		lsl.w	#2,d0
		sub.w	d1,d0
		sub.w	d2,d0
		sub.w	d3,d0
		sub.w	d4,d0
		;asr.w	#1,d0
		neg.w	d0
		;bpl.s	.ok
		;moveq	#0,d0			;don't make it brighter!
.ok:		move.w	d0,d7
		movem.l	(a7)+,d0-d6
;result in d7
		rts
		

taboff:
o		set	$8000
		rept	17
		dc.l	o
o		set	(o+$c0000)&$7fffff
		endr


; ---------------------------------------------------------------
o		set	$01000
		dcb.l	$200,o
levelval:
		dcb.l	$20,o
		rept	$60
		dc.l	o
o		set	o+$7fffff/$60
		endr
		dcb.l	$200,$7fffff

;--------------------------------------------------------------





;--------------------------------------------------------------
set_palette:
	ifne bitplane_mode
		lea	$ffff9800.w,a0
		move.l	#$d0b000d0,(a0)+
		move.l	#$d8c200d4,(a0)+
		move.l	#$f8f800e0,(a0)+
		move.l	#$e8e400dc,(a0)+
	else
	endc
		lea	$ffff9800.w,a0
		move.l	#0,(a0)+
		rts
;--------------------------------------------------------------

		include	system\3d.s

;--------------------------------------------------------------
			section data
;--------------------------------------------------------------
texlist:		dc.l	texmap_buffer
			;dc.l	new_textures+0*64*64*2
			;dc.l	new_textures+1*64*64*2
			;dc.l	new_textures+2*64*64*2

;--------------------------------------------------------------
;	miscellaneous data
;--------------------------------------------------------------

;--------------------------------------------------------------
;	dsp routines
;--------------------------------------------------------------

;--------------------------------------------------------------
;	3d objects
;--------------------------------------------------------------
Landshape	equ	0
Skyshape	equ	1

objectlist:
		initobj
		defobj	Land01,Landshape,000000,000,000000,0,0,0,0
		defobj	Sky01,Skyshape,000000,-$1000,000000,0,0,0,0

objectlistsize	equ	(*-objectlist)/4

;--------------------------------------------------------------
drawlists:
		dc.l	1			;only one to send
		initdl
		defdl	Landlist,1,nosort
		;dc.l	Sky01
		dc.l	Land01

;--------------------------------------------------------------

worldlist:	dc.l	1
		dc.l	Landlist

;--------------------------------------------------------------
Land_Scene:
			include e:\3d\land.ob3
			even

;--------------------------------------------------------------
;	graphics
;--------------------------------------------------------------

texmap_256:		equ *+6
texmap_64:		equ *+6
			ifeq	loadtex
			incbin	d:\data\ground.god
			;incbin	d:\data\tex64.god
			;incbin	d:\data\plasma.god
			;incbin	d:\data\plasma2.god
			else
			ds.w	64*64
			endc
;--------------------------------------------------------------

cam_movement:
; y - negative=downwards!


; anga - downwards
; angb - around z
; angc - off horizontal

; the tangent are defined as what is needed as the curve moves
; to this point...

		;	;  x      y     z     down    spin  bank
		dc.w	-$0000,+$0c00,+$0000,-$0100,+$0000,+$0100,+$1000
		dc.w	-$0000,-$0010,+$0000,-$0100,+$0100,+$0010,-$0100
cam_restart_pos:
		dc.w	64
		dc.w	-$0000,+$0d00,+$0000,-$0000,+$0600,+$0100,+$1000
		dc.w	-$0000,-$0010,+$0000,-$0100,+$0100,-$0010,-$0040
		dc.w	64
		dc.w	-$0000,+$0d00,+$0100,-$0080,-$0000,-$0200,+$0600
		dc.w	-$0000,-$0010,+$0000,-$0010,-$0100,+$0010,-$0100
		dc.w	64
		dc.w	-$0000,+$0d00,+$0000,-$0180,+$0c00,+$0200,+$0400
		dc.w	-$0000,-$0010,+$0000,-$0200,-$0100,-$0010,+$0100
		dc.w	64
		dc.w	-$0100,+$0d00,+$0000,-$0f00,+$0800,-$0100,+$0800
		dc.w	-$0000,+$0010,+$0000,+$0040,-$0100,-$0010,+$0100
		dc.w	-1

		ds.w	100

land_table	incbin	e:\3d\map.dat


;--------------------------------------------------------------
			cnop	0,4
			section	bss
texmap_buffer		equ	*+6
			ds.w	64*64+3
			even

land_tex_table		ds.w	3*256*256
land_shade_table	ds.w	17*17
tempsin			ds.w	1
			ds.l	1300
stack

