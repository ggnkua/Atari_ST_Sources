;
;
;
;
;
; 3D.S
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

messageon		equ	1
loadtex			equ	0

rgb			equ	0
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
		output	e:\test\data\worship.prg

	ifne	demo
		include	d:\source\tdf\main\equates.s
		;output	e:\demo\data\room.prg
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
		dc.b	"Binliner unfinished test preview 1998",13,10
		dc.b	"RGB only",0
		even

preload:
		ifne	loadtex
		loadfile "envmap.god",texmap_64-6
		loadfile "tex128.god",texmap_256-6
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

		lea	Man_Scene,a0
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

		;add.l	#1,objectlist+0*objsize+objr2	;stays still!
		add.l	#6,objectlist+1*objsize+objr2
		add.l	#6,objectlist+1*objsize+objr2
		add.l	#-6,objectlist+2*objsize+objr2
		add.l	#6,objectlist+3*objsize+objr2
		add.l	#6,objectlist+4*objsize+objr2
		add.l	#-6,objectlist+5*objsize+objr2
		add.l	#-6,objectlist+6*objsize+objr2
		add.l	#6,objectlist+7*objsize+objr2
		add.l	#6,objectlist+8*objsize+objr2

		lea	flarelist+4*1,a0
		lea	sinetable,a1
		move.w	tempsin1,d0
		move.w	tempsin2,d1
		move.w	tempsin3,d2
		add.w	#-182,d0
		add.w	#+73,d1
		add.w	#-193,d2
		move.w	d0,tempsin1
		move.w	d1,tempsin2
		move.w	d2,tempsin3
		moveq	#8-1,d7

.loop1:
		and.w	#$1fff,d0
		and.w	#$1fff,d1
		and.w	#$1fff,d2

		move.w	(a1,d0.w*2),d3
		muls.w	#$2c00,d3
		swap	d3
		ext.l	d3
		move.l	d3,(a0)+

		move.w	(a1,d1.w*2),d3
		muls.w	#$600,d3
		swap	d3
		add.w	#$700,d3
		ext.l	d3
		move.l	d3,(a0)+

		move.w	(a1,d2.w*2),d3
		muls.w	#$2c00,d3
		swap	d3
		ext.l	d3
		move.l	d3,(a0)+

		lea	objsize-12(a0),a0
		add.w	#-$400,d0
		add.w	#-$400,d1
		add.w	#-$400,d2
		dbf	d7,.loop1

		bsr	send_objects
		jsr	spin_object
		bsr	start_world
		;bsr	clearscreen
		bsr	draw_object
		bsr	screen_swap_three
		rts


set_res:
		include	d:\data\tdf\res\mars2.s
		;include	d:\source\4k2\vga.s
		rts


;--------------------------------------------------------------

screen_swap_three:
		move.l	physic,d0
		move.l	logic,physic
		move.l	third,logic
		move.l	d0,third

		move.l	physic,-(a7)
		move.b	1(a7),$ffff8201.w
		move.b	2(a7),$ffff8203.w
		move.b	3(a7),$ffff820d.w
		addq.l	#4,a7
		rts





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
Manshape	equ 0
insideshape	equ	1
floorshape	equ	1
cubeshape	equ	2
skyshape	equ	3
skyshape2	equ	4

shape1		equ	0
shape2		equ	0
shape3		equ	0
thingshape	equ	5

size1		equ	$c00*3/2
size2		equ	$1200*3/2
size3		equ	$1200*3/2
size4		equ	$1200*3/2

objectlist:
	initobj
	defobj	Man01,shape1,000000,$000,000000,0,0,0,0

	defobj	Man02,shape2,-size2,0,000000,0,0,0,0
	defobj	Man09,shape3,-size1,0,-size1,0,0,0,0
	defobj	Man03,shape1,-size1,0,+size1,0,0,0,0
	defobj	Man04,shape2,000000,0,-size2,0,0,0,0
	defobj	Man06,shape3,000000,0,+size2,0,0,0,0
	defobj	Man07,shape1,+size1,0,-size1,0,0,0,0
	defobj	Man08,shape2,+size2,0,000000,0,0,0,0
	defobj	Man05,shape3,+size1,0,+size1,0,0,0,0
flarelist:
	defobj	Flare1,-1,0,0,0,0,0,0,0
	defobj	Flare2,-1,0,0,0,0,0,0,0
	defobj	Flare3,-1,0,0,0,0,0,0,0
	defobj	Flare4,-1,0,0,0,0,0,0,0
	defobj	Flare5,-1,0,0,0,0,0,0,0
	defobj	Flare6,-1,0,0,0,0,0,0,0
	defobj	Flare7,-1,0,0,0,0,0,0,0
	defobj	Flare8,-1,0,0,0,0,0,0,0
	;defobj	Flare9,-1,0,0,0,0,0,0,0
	;defobj	Flare10,-1,0,0,0,0,0,0,0
	;defobj	Flare11,-1,0,0,0,0,0,0,0
	;defobj	Flare12,-1,0,0,0,0,0,0,0
	;defobj	Flare13,-1,0,0,0,0,0,0,0

	defobj	Cube01,cubeshape,0,0,0,0,0,0,0
	defobj	Sky01,skyshape,0,-$1000,0,0,0,0,0
	defobj	Sky02,skyshape2,0,0,0,0,0,0,0

	defobj	Floor01,floorshape,000000,-$100,000000,0,0,0,0
	defobj	Floor02,floorshape,-size2,-$100,000000,0,0,0,0
	defobj	Floor09,floorshape,-size1,-$100,-size1,0,0,0,0
	defobj	Floor03,floorshape,-size1,-$100,+size1,0,0,0,0
	defobj	Floor04,floorshape,000000,-$100,-size2,0,0,0,0
	defobj	Floor06,floorshape,000000,-$100,+size2,0,0,0,0
	defobj	Floor07,floorshape,+size1,-$100,-size1,0,0,0,0
	defobj	Floor08,floorshape,+size2,-$100,000000,0,0,0,0
	defobj	Floor05,floorshape,+size1,-$100,+size1,0,0,0,0

	defobj	Floor12,floorshape,-size4,-$100,000000,0,0,0,0
	defobj	Floor19,floorshape,-size3,-$100,-size3,0,0,0,0
	defobj	Floor13,floorshape,-size3,-$100,+size3,0,0,0,0
	defobj	Floor14,floorshape,000000,-$100,-size4,0,0,0,0
	defobj	Floor16,floorshape,000000,-$100,+size4,0,0,0,0
	defobj	Floor17,floorshape,+size3,-$100,-size3,0,0,0,0
	defobj	Floor18,floorshape,+size4,-$100,000000,0,0,0,0
	defobj	Floor15,floorshape,+size3,-$100,+size3,0,0,0,0


objectlistsize	equ	(*-objectlist)/4

;--------------------------------------------------------------
drawlists:
		dc.l	3			;only one to send
		initdl

		defdl	Skylist,2,nosort
		dc.l	Sky02
		dc.l	Sky01

		defdl	Manlist,9+8,sort
		dc.l	Man01
		dc.l	Man02,Man03,Man04
		dc.l	Man05,Man06,Man07,Man08
		dc.l	Man09

		dc.l	Flare1
		dc.l	Flare2
		dc.l	Flare3
		dc.l	Flare4
		dc.l	Flare5
		dc.l	Flare6
		dc.l	Flare7
		dc.l	Flare8
		;dc.l	Flare9
		;dc.l	Flare10
		;dc.l	Flare11
		;dc.l	Flare12
		;dc.l	Flare13

		defdl	Floorlist,18,nosort
		dc.l	Floor01
		dc.l	Floor02,Floor03,Floor04
		dc.l	Floor05,Floor06,Floor07,Floor08
		dc.l	Floor09

		dc.l	Floor12,Floor13,Floor14
		dc.l	Floor15,Floor16,Floor17,Floor18
		dc.l	Floor19
		dc.l	Cube01

;--------------------------------------------------------------

worldlist:	dc.l	2
		dc.l	Skylist
		;dc.l	Floorlist
		dc.l	Manlist	;first drawlist

;--------------------------------------------------------------

Man_Scene:
		include e:\3d\man.ob3
		even

;--------------------------------------------------------------
;	graphics
;--------------------------------------------------------------

texmap_buffer		equ	*+6
			ds.w	64*64+3
			even

texmap_256:		equ *+6
			ifeq	loadtex
			incbin	e:\test\data\tex128.god
			else
			ds.w	128*128
			endc

texmap_64:		equ *+6
			ifeq	loadtex
			incbin	e:\test\data\envmap.god
			else
			ds.w	64*64
			endc

;--------------------------------------------------------------
;
; a0 points to the buffer of words:
;
;   val_mean, val_dev		red colour value mean + deviance
;   val_mean, val_dev		green colour value mean + deviance
;   val_mean, val_dev		blue colour value mean + deviance
;   dist_mean, dist_dev		distance
;   pos_mean, pos_dev           central position in the buffer
;   speed_mean, speed_dev	speed
;

			ds.l	100

flash_data_1:
			dc.w	128,24		;value
			dc.w	128,24		;value
			dc.w	128,24		;value
			dc.w	28,7		;distance
			dc.w	96,3		;position
			dc.w	2,2		;speed
			dc.w	10,8		;repeat speed

flash_data_2:
			dc.w	128,0		;value
			dc.w	128,0		;value
			dc.w	128,0		;value
			dc.w	22,0		;distance
			dc.w	96,0		;position
			dc.w	2,1		;speed
			dc.w	15,12		;repeat speed

cam_movement:
; anga - downwards
; angb - around z
; angc - off horizontal

; the tangent are defined as what is needed as the curve moves
; to this point...

		dc.w	-$0100,+$0300,+$0200,+$0000,+$0800,+$0100,+$3000
		dc.w	-$0000,-$0000,+$0000,-$0200,-$0000,-$0100,-$2000

bezspeed	equ	64

		rept	20
		dc.w	bezspeed
		dc.w	-$0000,+$0800,+$0000,+$0000,+$0600,+$0100,+$0800
		dc.w	-$0000,-$0000,+$0000,-$0000,-$0000,-$0000,-$0000

		dc.w	bezspeed
		dc.w	+$0000,+$0800,+$0000,-$0300,+$0400,+$0200,+$0800
		dc.w	-$0080,-$0000,+$0080,+$0100,+$0100,-$0000,-$0100

		dc.w	bezspeed		; Point at one of the figures:
		dc.w	-size1,+$0800,+size1,+$0000,+$0800,+$0400,+$0300
		dc.w	+$0000,+$0000,-$0000,+$0100,+$0100,-$0030,+$0000

		dc.w	bezspeed		; Point at one of the figures:
		dc.w	-size1,+$0800,+size1,+$0100,+$0c00,+$0100,+$0600
		dc.w	+$0030,+$0000,-$0040,-$0200,-$0200,-$0080,+$0200

		dc.w	bezspeed
		dc.w	+$0000,+$0800,+$0000,-$0800,+$0500,-$0100,+$1a00
		dc.w	+$0000,-$0000,+$0000,+$0100,-$0020,+$0040,+$0400

		dc.w	bezspeed
		dc.w	+$0000,+$0800,+$0000,-$0300,+$0400,+$0300,+$2000
		dc.w	-$0010,-$0010,-$0010,+$0000,-$0000,-$0100,-$0000

		dc.w	bezspeed
		dc.w	-$0100,+$0300,+$0200,+$0000,+$0800,+$0100,+$3000
		dc.w	-$0000,-$0000,+$0000,-$0200,-$0000,-$0100,-$0800
		endr

		dc.w	-1




;--------------------------------------------------------------
			cnop	0,4
			section	bss
tempsin1		ds.l	1
tempsin2		ds.l	1
tempsin3		ds.l	1

			ds.l	300
stack

