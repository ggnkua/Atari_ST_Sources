;
;
;
;
;
; LAND.S
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
;
messageon		equ	0
loadtex			equ	0

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
		output	e:\men.prg

	ifne	demo
		include	f:\source\tdf\main\equates.s
		output	c:\_demo\data\room.prg
		opt	nodebug
	endc


	ifeq	demo
		include equates.s
		include	tosstart.i
	else
		include	demstart.i
	endc


;--------------------------------------------------------------
preload		rts

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
		jsr	cam_set
		jsr	cam_calc
		endc

		jsr	calc_colour_table

		bsr	set_res
		;lea	colour_list_gouraud,a0
		;bsr	calc_colours_gouraud
		bsr	tex_calc_envmap
		rts

do_effects:

		bsr	set_palette
		bsr	clearscreens

		init_dsp_routine dsp_routine_object,$210.w
		jsr	sendoneover

		lea	sea_Scene,a0
		jsr	send_object

	ifne animation_mode
		jsr	animate_init
		jsr	animate_object		;(once)
	endc

	ifne morphing_mode
		jsr	morph_init
		jsr	morph_object
	endc
		;jsr	send_colours_gouraud
		bsr	send_drawlists
		bsr	send_world

		lea	texmap_64,a0
		bsr	send_texmap

		move.w	#$2300,sr
.infinite:
		;jsr	autopal_reset
		move.w	#10-1,d0
		lea	texlist,a1
		bsr	main_loop
		bra	.infinite

		jsr	wait_senddsp
		move.l	#"RTS",$ffffa204.w
		rts

main_loop:
		move.l	d0,-(a7)
		bsr	send_objects

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


set_res:
		include	d:\data\tdf\res\mars2.s
		rts

;--------------------------------------------------------------
make_landscape:
		lea	$ffffa204.w,a0
		lea	sine_buffer,a1
		lea	sinetable,a2
		 wait_transmit
		move.l	#"POI",(a0)
		 wait_transmit
		move.l	#0,(a0)			;send object no.

		 wait_transmit
		move.l	#17*17*3,(a0)

		moveq	#1,d5

		move.w	#17-1,d0
		move.l	#-15000*2,d2
.loop1:
		move.w	#17-1,d1
		move.l	#-15000*2,d3
.loop2:
		 wait_transmit
		move.l	d2,(a0)

		move.w	(a1),d4
		add.w	d5,d4
		and.w	#$1fff,d4
		add.w	#10,d5
		and.w	#63,d5
		move.w	d4,(a1)+		;save
		move.w	(a2,d4.w*2),d4
		muls.w	#2000,d4
		swap	d4
		ext.l	d4		
		move.l	d4,(a0)			;height

		move.l	d3,(a0)

		add.l	#30000*2/16,d3
		dbf	d1,.loop2

		add.l	#30000*2/16,d2
		dbf	d0,.loop1

; Now do the textures:

		 wait_transmit
		move.l	#"TPO",(a0)
		 wait_transmit
		move.l	#0,(a0)			;send object no.

		 wait_transmit
		move.l	#17*17*3,(a0)
		moveq	#1,d5
		moveq	#1,d6
		move.w	#17-1,d0
.loop3:
		move.w	#17-1,d1
.loop4:
		move.w	(a1),d4
		add.w	d5,d4
		and.w	#$1fff,d4
		add.w	#8,d5
		and.w	#63,d5
		move.w	d4,(a1)+
		move.w	(a2,d4.w*2),d4
		ext.l	d4
		asl.l	#7,d4
		add.l	#$400000,d4
		move.l	d4,(a0)

		move.w	(a1),d4
		add.w	d6,d4
		and.w	#$1fff,d4
		add.w	#-3,d6
		and.w	#63,d6
		move.w	d4,(a1)+
		move.w	(a2,d4.w*2),d4
		ext.l	d4
		asl.l	#7,d4
		add.l	#$400000,d4
		move.l	d4,(a0)

		move.l	#0,(a0)

		dbf	d1,.loop4
		dbf	d0,.loop3
		rts





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

		defdl	Landlist,2,nosort
		dc.l	Sky01
		dc.l	Land01

;--------------------------------------------------------------

worldlist:	dc.l	1
		dc.l	Landlist

;--------------------------------------------------------------
sea_Scene:
		include e:\3d\sea.ob3
		even

;--------------------------------------------------------------
;	graphics
;--------------------------------------------------------------

texmap_buffer		equ	*+6
			;incbin	d:\data\map3.256
			ds.w	64*64+3
			even

texmap_256:		equ *+6
			incbin	d:\data\tex2563.god

texmap_64:		equ *+6
			;incbin	d:\data\_data\_gfx\tmap4.god
			incbin	d:\data\tex64.god

;--------------------------------------------------------------

cam_movement:
; anga - downwards
; angb - around z
; angc - off horizontal

; the tangent are defined as what is needed as the curve moves
; to this point...

		;	;  x      y     z     down    spin  bank
		dc.w	-$0000,+$0c00,+$0000,+$0000,+$0000,+$0100,+$2000
		dc.w	-$0000,-$0000,+$0000,-$0200,+$0100,+$0100,-$1000
		rept	20
		dc.w	128
		dc.w	-$0000,+$0c00,+$0000,-$0100,+$0600,+$0100,+$1000
		dc.w	-$0000,-$0000,+$0000,-$0100,+$0100,-$0000,-$0100
		dc.w	128
		dc.w	-$0000,+$0b00,+$0000,-$0800,+$0c00,+$0400,+$0400
		dc.w	-$0000,-$0000,+$0000,-$0100,-$0100,-$0000,+$0100
		; now flip upside down
		dc.w	128
		dc.w	-$0000,+$0c00,+$0000,-$1100,-$0600,+$0100,+$1000
		dc.w	-$0000,-$0000,+$0000,+$0100,-$0100,-$0000,-$0100
		dc.w	128
		dc.w	-$0000,+$0b00,+$0000,-$0100,-$0c00,-$0000,+$1000
		dc.w	-$0000,-$0000,+$0000,+$0100,+$0100,-$0000,+$0100
		endr

		dc.w	-1




;--------------------------------------------------------------
			cnop	0,4
			section	bss

sine_buffer		ds.w	17*17*6
			ds.l	300
stack

