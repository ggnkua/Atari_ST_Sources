;
;
;
;
;
; SPHERE.S
; .. of destiny
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
;
loadtex			equ	1
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
		output	e:\test\sphere.prg

	ifne	demo
		include	f:\source\tdf\main\equates.s
		opt	nodebug
	endc


	ifeq	demo
		include equates.s
		include	tosstart.i
	else
		include	demstart.i
	endc


;--------------------------------------------------------------
message:	dc.b	27,"E"
		dc.b	"another little freaky thing, ",13,10
		dc.b	"this time inside a sphere...",13,10
		dc.b	"i can code 1000 of these things",13,10
		dc.b	"and switch between them for nice",13,10
		dc.b	"effects...",13,10
		dc.b	"tat",0
		even

preload:
		ifne	loadtex
		loadfile "plasma.god",texmap_64-6
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

		lea	Land_Scene,a0
		jsr	send_object

		bsr	send_drawlists
		bsr	send_world

		lea	texmap_64,a0
		bsr	send_texmap

		move.l	#25000,Viewer_Size
		move.w	#150,c_persp
		bsr	send_clipping

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
		;jsr	clearscreen
		bsr	draw_object
		;bsr	draw_flare
		bsr	screen_swap
		rts


set_res:	include	d:\data\tdf\res\mars2.s
		rts

;--------------------------------------------------------------
make_landscape:

; Now do the textures:
		;bsr	ring_make_points

		lea	$ffffa204.w,a0
		lea	sine_buffer,a1
		lea	sinetable,a2
		 wait_transmit
		move.l	#"TPO",(a0)
		 wait_transmit
		move.l	#0,(a0)			;send object no.

		 wait_transmit
		move.l	#16*16*3,(a0)
		moveq	#1,d5
		moveq	#1,d6
		moveq	#1,d7

		move.w	#16-1,d0
.loop3:
		move.w	#16-1,d1
.loop4:
		move.w	(a1),d4
		add.w	d5,d4
		and.w	#$1fff,d4
		add.w	#17,d5
		and.w	#255,d5
		move.w	d4,(a1)+
		move.w	(a2,d4.w*2),d4
		ext.l	d4
		asl.l	#7,d4
		add.l	#$400000,d4
		move.l	d4,(a0)

		move.w	(a1),d4
		add.w	d6,d4
		and.w	#$1fff,d4
		add.w	#-31,d6
		and.w	#255,d6
		move.w	d4,(a1)+
		move.w	(a2,d4.w*2),d4
		ext.l	d4
		asl.l	#7,d4
		add.l	#$400000,d4
		move.l	d4,(a0)

		move.w	(a1),d4
		add.w	d7,d4
		and.w	#$1fff,d4
		add.w	#-9,d7
		and.w	#255,d7
		move.w	d4,(a1)+
		move.w	(a2,d4.w*2),d4
		ext.l	d4
		asl.l	#7,d4
		add.l	#$400000,d4
		move.l	d4,(a0)			;shade value

		dbf	d1,.loop4
		dbf	d0,.loop3
		rts

ring_make_points:
		lea	$ffffa204.w,a0
		lea	sine_buffer,a1
		lea	sinetable,a2
		lea	costable,a3

		move.w	heightsin,d2
		add.w	#150,d2
		move.w	d2,heightsin

		 wait_transmit
		move.l	#"POI",(a0)
		 wait_transmit
		move.l	#0,(a0)			;send object no.

		 wait_transmit
		move.l	#16*16*3,(a0)

		move.w	#2000*15,d0		;initial radius
		moveq	#16-1,d1
.loop:
; now calc height:
		and.w	#$1fff,d2
		move.w	(a2,d2.w*2),d7
		add.w	#$2000/$8,d2
		muls.w	#8000,d7
		swap	d7
		ext.l	d7

		moveq	#16-1,d3
		move.w	#0,d4
.loop2:
		move.w	(a2,d4.w*2),d5
		move.w	(a3,d4.w*2),d6
		muls	d0,d5
		muls	d0,d6
		swap	d5
		swap	d6
		ext.l	d5
		move.l	d5,(a0)			;x (cos)
		ext.l	d6
		move.l	d7,(a0)			;height
		move.l	d6,(a0)			;z (sin)

		add.w	#$2000/$10,d4		;inc angle

		dbf	d3,.loop2
		sub.w	#2000,d0
		dbf	d1,.loop		
		rts

heightsin	ds.w	1

; ---------------------------------------------------------------
		

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

objectlist:
		initobj
		defobj	Land01,Landshape,000000,000,000000,0,0,0,0

objectlistsize	equ	(*-objectlist)/4

;--------------------------------------------------------------
drawlists:
		dc.l	1			;only one to send
		initdl
		defdl	Landlist,1,nosort
		dc.l	Land01

;--------------------------------------------------------------

worldlist:	dc.l	1
		dc.l	Landlist

;--------------------------------------------------------------
Land_Scene:
			include e:\3d\sphere.ob3
			;include e:\3d\tube.ob3
			even

;--------------------------------------------------------------
;	graphics
;--------------------------------------------------------------

texmap_256:		equ *+6
texmap_64:		equ *+6
			ifeq	loadtex
			incbin	d:\data\plasma.god
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
		dc.w	-$0000,-$0000,+$0000,-$0200,+$0000,+$0000,+$0000
		dc.w	-$0000,-$0000,+$0000,+$0100,+$0100,+$0000,-$0000
cam_restart_pos:
		dc.w	80
		dc.w	-$0000,-$0000,+$0000,+$0800,+$0600,+$0000,+$0000
		dc.w	-$0000,-$0000,+$0000,-$0100,-$0200,-$0000,-$0000
		dc.w	80
		dc.w	-$0000,-$0000,+$0000,-$0c00,-$1000,-$0000,+$0000
		dc.w	-$0000,-$0000,+$0000,+$0040,+$0200,+$0000,+$0000
		dc.w	80
		dc.w	-$0000,-$0000,+$0000,-$0200,+$0c00,+$0000,+$0000
		dc.w	-$0000,-$0000,+$0000,+$0100,-$0100,-$0000,+$0000
		dc.w	-1

		ds.w	100

;--------------------------------------------------------------
			cnop	0,4
			section	bss
texmap_buffer		equ	*+6
			ds.w	64*64+3
			even
sine_buffer		ds.w	1000
land_tex_table		ds.w	3*256*256
land_shade_table	ds.w	17*17
tempsin			ds.w	1
			ds.l	1300
stack

