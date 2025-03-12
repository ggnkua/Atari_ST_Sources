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

rgb			equ	1
flash			equ	0
vblwait			equ	0
keys			equ	1
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

display_routine:
		move.l	#-$100,rotation_x
		move.l	#+$200,viewer_y
		bsr	do_effects
	ifeq	demo
		illegal
	else
		move.l	(a7)+,d0
		rts
	endc


initialize_routine:
		bsr	set_res
		lea	colour_list_gouraud,a0
		bsr	calc_colours_gouraud
		rts

do_effects:

		bsr	set_palette
		bsr	clearscreens

		init_dsp_routine dsp_routine_object,$210.w
		jsr	sendoneover
		lea	object_a,a0
		jsr	send_object

	ifne animation_mode
		jsr	animate_init
		jsr	animate_object		;(once)
	endc

	ifne morphing_mode
		jsr	morph_init
		jsr	morph_object
	endc
		jsr	send_colours_gouraud
		bsr	send_drawlists
		bsr	send_world

		lea	flash_data_1,a0
		call	autopal_set,texture_palette

		lea	flash_data_2,a0
		call	autopal_set,back_palette

		move.w	#$2300,sr
.infinite:
		;jsr	autopal_reset
		move.w	#10-1,d0
		lea	object_a,a0
		lea	texlist,a1
		bsr	main_loop
		bra	.infinite

		jsr	wait_senddsp
		move.l	#"RTS",$ffffa204.w
		rts

main_loop:
		move.l	a1,which_texlist

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
		call	autopal_generate,texture_palette
						;returns pal in a0
		move.l	a0,pal_back_address

		call	autopal_generate,texture_palette
						;returns pal in a0
		move.l	a0,pal_address

		jsr	make_texture
	ifeq bitplane_mode
		add.l	#9,objectlist+0*objsize+objr2
		add.l	#3,objectlist+1*objsize+objr2
		add.l	#-3,objectlist+2*objsize+objr2
		add.l	#8,objectlist+3*objsize+objr2
		add.l	#5,objectlist+4*objsize+objr2
		add.l	#-8,objectlist+5*objsize+objr2
		add.l	#-5,objectlist+6*objsize+objr2
		add.l	#4,objectlist+7*objsize+objr2
		add.l	#7,objectlist+8*objsize+objr2
		bsr	send_objects

		jsr	spin_object
		lea	object_1_data,a0
		bsr	start_world
		bsr	clearscreen
		bsr	draw_object

	endc
		bsr	screen_swap
	ifne	vblwait
		bsr	wait_vbl
	endc
		rts


start_world:
		move.l	a0,current_object

	ifne animation_mode
		bsr	animate_object
	endc

	ifne morphing_mode
		bsr	morph_object
	endc

		move.l	current_object,a0
		bsr	send_viewpoint
		bsr	makematrixlight		;must be done first
		bsr	makematrixobject

		wait_transmit
		move.l	#"CAL",$ffffa204.w

		;move.l	current_object,a0
		;wait_transmit
		;move.l	#"HA1",$ffffa204.w
		;wait_transmit
		;move.l	object_number(a0),$ffffa204.w	;go
		rts


draw_object:
		move.l	logic,a0
		bsr	handle_object_world
		rts


;--------------------------------------------------------------

	ifeq bitplane_mode
reptval equ ((object_width*2)/13/4)+1

clearscreen:
		move.l	logic,a6
		add.l	#(lines+object_height-1)/2*bytesperline,a6
		lea	(2*(pixels+object_width)/2)(a6),a6

		move.l	pal_back_address,a0
		move.w	0*2(a0),d1
		swap	d1
		move.w	0*2(a0),d1
		moveq	#0,d1
		move.l	d1,d2
		move.l	d1,d3
		move.l	d1,d4
		move.l	d1,d5
		move.l	d1,d6
		move.l	d1,d7
		move.l	d1,a0
		move.l	d1,a1
		move.l	d1,a2
		move.l	d1,a3
		move.l	d1,a4
		move.l	d1,a5

		move.l	#$0001,d0
		movec	d0,cacr

		move.w	#object_height-1,d0
.wipe:		rept	reptval
		movem.l	d1-a5,-(a6)
		endr
		lea	-(bytesperline)+(13*4*reptval)(a6),a6
		dbf	d0,.wipe

		move.l	#$1919,d0
		movec	d0,cacr
		rts
	endc

;--------------------------------------------------------------
spin_object:
	ifne keys
		bsr	handle_keyboard
;		move.w	mouse_x,d0
;		ext.l	d0
;		asl.l	#4,d0	
;		move.l	d0,rotation_x
;		move.w	mouse_y,d0
;		ext.l	d0
;		asl.l	#4,d0	
;		move.l	d0,rotation_y

	else
		movem.l	rotation_x,d0/d1/d2
rotadd1 = *+2
		add.l	#0,d0
rotadd2 = *+2
		add.l	#15,d1
rotadd3 = *+2
		add.l	#0,d2
		movem.l	d0/d1/d2,rotation_x
	endc

		movem.l	rotation_x,d0/d1/d2
		;movem.l	lightrot_x,d0/d1/d2
		;add.l	#1*45,d0
		;add.l	#2*45,d1
		;add.l	#3*45,d2
		movem.l	d0/d1/d2,lightrot_x
		rts


makematrixobject:
		movem.l	rotation_x,d0/d1/d2
		move.l	current_object,a0
		add.l	object_rotx(a0),d0
		add.l	object_roty(a0),d1
		add.l	object_rotz(a0),d2
		move.l	#"MAT",d7
		bra.s	domatrix
makematrixlight:
		movem.l	lightrot_x,d0/d1/d2
		move.l	current_object,a0
		add.l	object_rotx(a0),d0
		add.l	object_roty(a0),d1
		add.l	object_rotz(a0),d2
		move.l	#"LIG",d7
; expansion to allow fading using the unit_vector?

domatrix:
		and.l	#$1fff,d0
		and.l	#$1fff,d1
		and.l	#$1fff,d2
		lea	costable,a0
		lea	sinetable,a1
		jsr	wait_senddsp
		move.l	d7,$ffffa204.w
		moveq	#0,d7
		move.w	(a0,d0.w*2),d7
		bsr.s	sendinfo
		move.w	(a1,d0.w*2),d7
		bsr.s	sendinfo
		move.w	(a0,d1.w*2),d7
		bsr.s	sendinfo
		move.w	(a1,d1.w*2),d7
		bsr.s	sendinfo
		move.w	(a0,d2.w*2),d7
		bsr.s	sendinfo
		move.w	(a1,d2.w*2),d7
		bsr.s	sendinfo
		rts
sendinfo:
		ext.l	d7
		asl.l	#8,d7
		 wait_transmit
		move.l	d7,$ffffa204.w
		rts










;
;
;
;		true colour routines
;
;
;








;--------------------------------------------------------------
handle_object_world:
		add.l	#(pixels/2)*2+bytesperline*(lines/2),a0
		move.l	a0,screen_centre
		move.l	#$0009,d0
		movec	d0,cacr

		lea	$ffffa206.w,a1
		lea	$ffffa202.w,a2
		move.l	#bytesperline,d7
		move.l	screen_centre,a4
		moveq	#0,d0
		moveq	#0,d2
handleloop
		wait_transmit
		move.l	#"GET",$ffffa204.w
.wr2:
		wait_receive
		 move.w	(a1),d0
		 bmi done
		 jmp .polylist(pc,d0.w*4)
.polylist:
		bra.w	get_flat		;0
		bra.w	get_flat		;1
		bra.w	get_gouraud		;2
		bra.w	get_texmap		;3
get_flat:
		 wait_receive
		 move.w	(a1),d6			;get top_height
		 muls.w	d7,d6
		 lea	(a4,d6.l),a0

		 wait_receive
		 move.w	(a1),d1
		 subq.w	#1,d1			;poly height
		 blt	dontdo

		 wait_receive
		 move.w	(a1),d5			;d4 - colour
		 move.w	d5,d4
		 swap	d4
		 move.w	d5,d4
.printpoly2:
		  move.w (a1),d2
		  lea	(a0,d2.w*2),a3
		  moveq	#0,d5
		  move.w (a1),d3
		  asr.w	#1,d3
		  bcc.s	.next3
		  move.w d4,(a3)+
.next3	  	subq.w #1,d3
		  bmi.s	.next2
.pp2		   move.l d4,(a3)+
		  dbra	d3,.pp2
.next2		  add.l d7,a0
		 dbf	d1,.printpoly2
		bra	handleloop

get_gouraud:
		bra	handleloop

get_texmap:
		 wait_receive
		 move.w	(a1),d6			;get top_height
		 muls.w	d7,d6
		 lea	(a4,d6.l),a0
		 move.w	(a1),d1
		 subq.w	#1,d1
		 bmi.s	.dontdo
.printpoly:
		  wait_receive
		  move.w (a1),d2
		  lea (a0,d2.w*2),a3	
		  move.w (a1),d3
		  subq.w #1,d3
		  bmi.s	.next
		  wait_receive
.pp	   	move.w (a1),(a3)+
		  dbra	d3,.pp
.next	  	add.l d7,a0
		 dbf	d1,.printpoly
.dontdo		bra	handleloop
done:
		move.l	#$1919,d0
		movec	d0,cacr
		rts
dontdo		illegal










;--------------------basic i/o routines------------------------
max_width=384

sendoneover
		lea	$ffffa204.w,a6
		 wait_transmit
		moveq	#0,d0
.sendy:
		move.l	#$7fffff,d1
		tst.w	d0
		beq	.skipdiv
		divu.l	d0,d1
.skipdiv
		 wait_transmit
		move.l	d1,(a6)
		addq.l	#1,d0
		cmp.w	#max_width,d0
		bne.s .sendy
		rts

;--------------------------------------------------------------
send_object:
		jsr	wait_senddsp
		move.l	#"OBJ",$ffffa204.w

		move.l	(a0)+,d0
		 wait_transmit
		move.l	d0,$ffffa204.w
		subq.l	#1,d0
.sendpoints:
		 wait_transmit		; not time-critical!
		move.l	(a0)+,$ffffa204.w
		dbf	d0,.sendpoints
		rts

;--------------------------------------------------------------
	ifne	mapping_mode
send_texmap:
		jsr	wait_senddsp
		move.l	#"TEX",$ffffa204.w
		move.l	#64*64,d0
		 wait_transmit
		move.l	d0,$ffffa204.w
		subq.l	#1,d0
.sendpoints:
		 wait_transmit		; not time-critical!
		move.w	(a0)+,$ffffa206.w
		dbf	d0,.sendpoints
		rts
	endc


;--------------------------------------------------------------
wait_senddsp:
		btst	#1,$ffffa202.w
		beq	wait_senddsp
		rts
;--------------------------------------------------------------
wait_receivedsp:
		btst	#0,$ffffa202.w
		beq	wait_receivedsp
		rts

;--------------------------------------------------------------
send_objects:
		lea	$ffffa204.w,a6
		lea	objectlist,a0
		wait_transmit
		move.l	#"OBS",(a6)		;command word
		wait_transmit
		clr.l	(a6)			;offset
		wait_transmit
		move.l	#objectlistsize,(a6)	;number of word
		move.w	#objectlistsize-1,d0
.send		wait_transmit
		move.l	(a0)+,(a6)
		dbf	d0,.send
		rts

;--------------------------------------------------------------
send_drawlists:
		lea	$ffffa204.w,a6
		lea	drawlists,a0
		wait_transmit
		move.l	#"DLS",(a6)		;command word
		move.l	(a0)+,d0		;number of lists
		wait_transmit
		move.l	d0,(a6)
		subq.l	#1,d0
.send_list:	 move.l	(a0)+,d1		;number of items in list
		 wait_transmit
		 move.l	d1,(a6)
		 wait_transmit
		 move.l	(a0)+,(a6)		;sortflag
		 subq.l	#1,d1
.send_object:
		  wait_transmit
		  move.l (a0)+,(a6)		;index of object
		  dbf	d1,.send_object
		dbf	d0,.send_list
		rts

;--------------------------------------------------------------
send_world:
		lea	$ffffa204.w,a6
		lea	worldlist(pc),a0
		wait_transmit
		move.l	#"WOR",(a6)		;command word
		move.l	(a0)+,d0		;number of lists
		wait_transmit
		move.l	d0,(a6)

		subq.l	#1,d0
.send_list:	 move.l	(a0)+,d1		;number of items in list
		 wait_transmit
		 move.l	d1,(a6)
		dbf	d0,.send_list
		rts

;--------------------------------------------------------------

			rsreset
object_x		rs.l	1
object_y		rs.l	1
object_z		rs.l	1
object_rotx		rs.l	1
object_roty		rs.l	1
object_rotz		rs.l	1
object_dspeed		rs.l	1
object_dsize		rs.l	1
object_doffset		rs.l	1
object_number		rs.l	1

object_1_data:
			dc.l	0,0,0
			dc.l	0,0,0
			dc.l	14,30,0			;speed,size,offset
			dc.l	0

set_res:
		;include	f:\source\sl\autopal\3810v32k.s
		;move #64,$ffff820e.w
		include	d:\data\tdf\res\mars2.s
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
init_dsp_calc:
		bsr	makematrixlight		;must be done first
		bsr	makematrixobject
		jsr	wait_senddsp
		move.l	#"CAL",$ffffa204.w
		wait_transmit
		move.l	#"HAN",$ffffa204.w
		rts




;
;
;
;	motion blur section
;
;
;
;

;--------------------------------------------------------------
calc_whiteout:
		move.w	#3-1,d7
.loop1:
		move.l	a1,a2			;save orig destination
		move.w	#64*64-1,d0
		lea	colour_table,a3
		moveq	#0,d1
.sendpoints:
		move.w	(a0)+,d1
		move.w	(a3,d1.l*2),d2
		move.w	d2,(a1)+
		dbf	d0,.sendpoints
		move.l	a2,a0
		dbf	d7,.loop1
		rts		


;--------------------------------------------------------------
make_texture:

		move.l	pal_address,a0

		 wait_transmit
		move.l	#"TEX",$ffffa204.w
		 wait_transmit
		move.l	#64*64,$ffffa204.w
		lea	texmap_buffer,a1
		lea	$ffffa206.w,a2
		move.w	#64*64-1,d0
		moveq	#0,d1
.sendpoints:
		move.w	(a1)+,d1
		 wait_transmit
		move.w	(a0,d1.l*2),(a2)	;don't do wait
		dbf	d0,.sendpoints
		rts		


;--------------------------------------------------------------
feed	macro
			dc.w	\1*07,\1*08,\1*09,\1*10
			dc.w	\1*11,\1*12,\1*13,\1*14
			dc.w	\1*15,\1*16,\1*17,\1*18
			dc.w	\1*19,\1*20,\1*21,\1*22
			dc.w	\1*23,\1*24,\1*25,\1*26
			dc.w	\1*27,\1*28,\1*29,\1*30
			dc.w	\1*31,\1*31,\1*31,\1*31
			dc.w	\1*31,\1*31,\1*31,\1*31
		endm
; should go up slowly, then quicker

feedback_table_red:
		feed	$0800
feedback_table_green:
		feed	$0040
feedback_table_blue:
		feed	$0001
		feed	$0001



;
;
;
;
;			info print section
;
;
;
;
;


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

		include	3dsys\view.s
		include	3dsys\animate.s
		include	3dsys\gouraud.s
		include	3dsys\keys.s
		include	d:\source\sl\autopal\autopal.s

		;include	3dsys\morph.s


		define_autopal	texture_palette
		define_autopal	back_palette

;--------------------------------------------------------------
			section data
;--------------------------------------------------------------
texlist:		dc.l	texmap_buffer
			dc.l	new_textures+0*64*64*2
			dc.l	new_textures+1*64*64*2
			dc.l	new_textures+2*64*64*2


rotation_x:		dc.l	$0000
rotation_y:		dc.l	$0000
rotation_z:		dc.l	$0000
lightrot_x:		ds.l	1
lightrot_y:		ds.l	1
lightrot_z:		ds.l	1

viewer_x:		ds.l	1
viewer_y:		ds.l	1
viewer_z:		ds.l	1

camera_x:		dc.l	0
camera_y:		dc.l	0
camera_z:		
viewer_distance:	dc.l	$4000
viewer_size:		dc.l	25000

current_object:		dc.l	0
which_texlist		ds.l	1

;--------------------------------------------------------------
;	miscellaneous data
;--------------------------------------------------------------
			cnop	0,4
sinetable:		incbin	d:\data\trailsin.dat
costable:		equ	sinetable+2048*2
			even

;--------------------------------------------------------------
;	dsp routines
;--------------------------------------------------------------

dsp_routine_object:
		ifne bitplane_mode
			incbin	d:\dsp\dsp\in_room.dsp
		else
			incbin	d:\dsp\dsp\gen_obj.dsp
		endc
			even


;--------------------------------------------------------------
;	3d objects
;--------------------------------------------------------------
manshape	equ	0
insideshape	equ	1

size1		equ	$c00*2
size2		equ	$1200*2

objectlist:
	initobj
	defobj	man01,manshape,-size1,0,-size1,0,0,0,0
	defobj	man02,manshape,-size2,0,000000,0,0,0,0
	defobj	man03,manshape,-size1,0,+size1,0,0,0,0

	defobj	man04,manshape,000000,0,-size2,0,0,0,0
	defobj	man09,manshape,000000,$800,000000,0,0,0,0
	defobj	man06,manshape,000000,0,+size2,0,0,0,0

	defobj	man07,manshape,+size1,0,-size1,0,0,0,0
	defobj	man08,manshape,+size2,0,000000,0,0,0,0
	defobj	man05,manshape,+size1,0,+size1,0,0,0,0

	defobj	inside,insideshape,0,0,0,0,0,0,0

objectlistsize	equ	(*-objectlist)/4

;--------------------------------------------------------------
drawlists:
		dc.l	2			;only one to send
		initdl

		defdl	insidelist,1,sort
		dc.l	inside

		defdl	manlist,9,sort
		dc.l	man01,man02,man03,man04
		dc.l	man05,man06,man07,man08
		dc.l	man09

		;defdl	manlist,1,sort
		;dc.l	man01

;--------------------------------------------------------------

worldlist:	dc.l	1
		dc.l	manlist	;first drawlist

;--------------------------------------------------------------




;object_a:	include c:\_data\_ob3\env_insi.ob3
object_a:	include d:\data\_data\_ob3\env_man.ob3
		even

;--------------------------------------------------------------
;	graphics
;--------------------------------------------------------------

		ifeq	bitplane_mode
texmap_buffer		equ	*+6
			;incbin	'f:\data\tdf\gfx\envmap4.god'
			incbin	d:\data\map3.256
			even

logo:			equ	*+6
			;incbin	'd:\data\tdf\gfx\avena.god'
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

flash_data_1:
			dc.w	128,0		;value
			dc.w	128,0		;value
			dc.w	128,0		;value
			dc.w	2,3		;distance
			dc.w	64,13		;position
			dc.w	3,1		;speed
			dc.w	15,2		;repeat speed

flash_data_2:
			dc.w	128,0		;value
			dc.w	128,0		;value
			dc.w	128,0		;value
			dc.w	2,0		;distance
			dc.w	64,0		;position
			dc.w	2,7		;speed
			dc.w	15,12		;repeat speed

colour_list_gouraud:
		dc.w	2		;total number
		dc.w	1
		;dc.l	128,$f0f000f0,$f0800000	;black --> yellow
		;dc.l	128,$f0800000,$00000000	;yellow--> green
		dc.l	128,$f0f000e0,$00000000	;yellow--> green
		dc.w	1
		;dc.l	128,$f0f000f0,$808000b0	;white --> lblue
		dc.l	128,$808000b0,$00000000	;lblue --> pink

;--------------------------------------------------------------
			cnop	0,4
			section	bss
scan_min		ds.l	1
scan_max		ds.l	1
screen_centre		ds.l	1
colour_table_gouraud	ds.w	128*16
pal_address		ds.l	1
pal_back_address	ds.l	1

		ifne	bitplane_mode
screen_buffer		ds.l	9600
		endc

colour_table		ds.w	65536
new_textures		ds.w	64*64*3

			ds.l	300
stack

