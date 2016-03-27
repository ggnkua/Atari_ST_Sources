;
;
;
;
;
; MAGGIE26.S
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
ymax			equ	199

movespeed		equ 16*4
movespeed2		equ $100

;screenlines		equ	200
;bytesperline		equ	384*2
;lines			equ	200
;pixels			equ	384

object_width		equ	384
object_height		equ	200

direction		equ	1		;(motion blur)




back_colour	equ	0*$08410841
noscreens	equ	3
demo		equ	0






start:
		output	e:\mags\m25test.f\data\tatintro.dat
		opt	nodebug

		include equates.s
init_dsp	MACRO
		;JSR	dsp_library+0
		ENDM


install_vbl	MACRO
		move.l	#\1,my_vbl
		ENDM

loadfile	MACRO
		lea	.file(pc),a0
		lea	\2,a1
		jsr	load_file
		bra.s	\@
.file		dc.b	\1
		even
\@
		ENDM

		pea	start-256(pc)
		pea	lastline-start+256
		pea	$4a0000
		trap	#1
		lea	12(a7),a7

		CLR.L -(A7)
		MOVE.W #$20,-(A7)
		TRAP #1
		MOVE.L D0,save_stack
		ADDq.L #6,A7		;use existing stacks

		ifne	messageon
		move	#-1,-(a7)
		move.w	#11,-(a7)
		trap	#13
		addq.l	#4,a7

		and.w	#%1111,d0
		bne	simple_exit
		endc

		BSR savevectors
		BRA program_start

		dc.b	"hey look! it's a heap of old crap!"
		even

*********************************
*	vector-saving routines:	*
*********************************
savevectors:
	movec	cacr,d0
	move.l	d0,save_cache

	move.w	#-1,-(a7)
	move.w	#$58,-(a7)
	trap	#14
	addq.l	#4,a7
	move.w	d0,resolution

	move.w	#2,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,screen_base

	move.w	#3,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,screen_base_2
	move.l	$44e.w,old_44e

	lea	save_vectors(pc),a0
	lea	$8.w,a1
	moveq	#($140-8)/4-1,d0
.copy1	move.l	(a1)+,(a0)+
	dbf	d0,.copy1
	
	lea	$fffffa01.w,a1
	moveq	#21,d0
.copy2	move.b	(a1),(a0)+
	addq.l	#2,a1
	dbf	d0,.copy2

;set  error vectors:
	lea	$8.w,a0
	lea	restore_vectors(pc),a1
	moveq	#9,d0
.copy3	move.l	a1,(a0)+
	dbf	d0,.copy3
	bclr	#3,$fffffa17.w
	rts

quit:
restore_vectors:
mono_exit:
	movem.l	d0-a6,save_registers

	move.w	#$2700,sr
	lea	save_vectors(pc),a0
	lea	$8.w,a1
	moveq	#($140-8)/4-1,d0
.copy1	move.l	(a0)+,(a1)+
	dbf	d0,.copy1

	lea	$fffffa01.w,a1
	moveq	#21,d0
.copy2	move.b	(a0)+,(a1)
	addq.l	#2,a1
	dbf	d0,.copy2

	move.b	#$c8,$fffffa23.w

	lea	mouse_on(pc),a0
	bsr	send_ikbd

; Flush:

.flush	move.b	$fffffc02.w,d0
	btst	#0,$fffffc00.w
	bne.s	.flush

	move.w	#$2300,sr

	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7		;wait vbl

	move.w	resolution(pc),-(a7)
	move.w	#3,-(a7)
	move.l	screen_base(pc),-(a7)
	move.l	screen_base_2(pc),-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	14(a7),a7

	move.l	save_cache,d0
	movec	d0,cacr

	movem.l	save_registers(pc),d0-a6
simple_exit:
	;illegal
	clr.w	-(a7)
	trap	#1

which_error	dc.w 0
error_flag	dc.w -1		;assume error

screen_base:
	ds.l 1
screen_base_2:
	ds.l 1
resolution:
	ds.w 1
save_stack:
	ds.l 1
save_cache	ds.l	1
*****************************************
*	Keyboard handler:		*
*****************************************

keyboard:
	move.w	#$2300,sr
	move.w	d6,-(a7)
	move.l	a6,-(a7)
.read_data
	move.w	status(pc),d6
	move.w	.jumplist(pc,d6.w),d6
	jmp	.jumplist(pc,d6.w)

.jumplist
	dc.w	.keypress-.jumplist	;0 - keypress
	dc.w	.mouse1-.jumplist	;$f8 2
	dc.w	.mouse1-.jumplist	;$f9 4
	dc.w	.mouse1-.jumplist	;$fa 6
	dc.w	.mouse1-.jumplist	;$fb 8
	dc.w	.keypress-.jumplist	;$fc 10 - keypress
	dc.w	.mouse2-.jumplist	;$fd 12
	dc.w	.joy1-.jumplist		;$fe 14 - get j1 data
	dc.w	.joy2-.jumplist		;$ff 16 - get j2 data

*routines:
.keypress
	sub.w	d6,d6			;cant use MOVEQ
	move.b	$fffffc02.w,d6
	move.b	d6,keypress

	cmp.w	#$f8,d6			;special cases....
	bge.s	.special

	lea	keyboard_matrix,a6
	bclr	#7,d6			;ignore	bit 7
	bne.s	.keyup

	move.b	d6,lastkey
	st.b	(a6,d6.w)
	bra.s	.end
.keyup	clr.b	(a6,d6.w)
					;falls through
.end
	btst	#4,$fffffa01.w
	beq.s	.read_data		;another interrupt
	move.l	(a7)+,a6
	move.w	(a7)+,d6
	rte

**** Handle joysticks:
.special:	sub.w	#$f7,d6		; 1 or 2
	add.w	d6,d6			; 2 or 4...
	move.w	d6,status
	bra.s	.end

.joy1	move.b	$fffffc02.w,joy1
	clr.w	status
	bra.s	.end
.joy2	move.b	$fffffc02.w,joy2
	clr.w	status
	bra.s	.end

.mouse1	move.b	$fffffc02.w,d6
	ext.w	d6
	add.w	d6,mouse_x
	move.w	status(pc),d6		;2-8
	lsr.w	#1,d6			;1-4
	subq.w	#1,d6			;0-3
	move.b	d6,mouse_button
	move.w	#12,status
	bra.s	.end

.mouse2	move.b	$fffffc02.w,d6
	ext.w	d6
	add.w	d6,mouse_y
	clr.w	status
	bra.s	.end

*****************************
send_ikbd:
	move.w	#$fc00,a1

.loop	btst	#1,(a1)			;ready to send?
	beq.s	.loop
	move.b	(a0)+,2(a1)		;plonk it in
	cmp.b	#-5,(a0)		;end?
	bne.s	.loop
	rts

*****************************
mouse_on	dc.b	$1a,$8,-5
joy_on	dc.b	$14,$8,-5
	even

*********************
vbl:
	addq.l	#1,$466.w
	addq.w	#1,vbl_timer
	cmp.b	#$39,$fffffc02.w	;check for user quit
	bne	.noquit
	st	quit_flag
.noquit:
	movem.l	d0-a6,-(A7)
	move.l	my_vbl(pc),a0
	jsr	(a0)
	movem.l	(a7)+,d0-a6
	rte

rts	rts

wait_vbl:
	clr.w	vbl_timer
.wv	tst.w	vbl_timer
	beq.s	.wv
	rts



*************************
*	Data Section:	*
*************************
* Mouse information:
lastkey		dc.b 0
mouse_button	dc.b 0
		even
mouse_x		dc.w 0
screenshot	dc.w 0
mouse_y		dc.w 0
save_a0		ds.l 1
status		ds.w 1
keypress	ds.w 1
keyboard_matrix	ds.b 128
joy1		ds.w 1
joy2		ds.w 1
kb_data		ds.w 1
vbl_timer	ds.w 1
logic		ds.l 1
physic		ds.l 1
old_44e		ds.l 1
my_vbl		dc.l rts

save_vectors	ds.l 350/4
save_registers	ds.l 16
quit_flag	ds.w	1

program_start:
; Set original vectors and screens etc.

		;LEA	stack,A7

;---------------------------------------------------------------

                move.w  #0,-(a7)
                pea     (codesize).w
                pea     code_address(pc)
                move.w  #109,-(a7)
                trap    #14
                lea     12(a7),a7

		MOVE.W	#$2700,SR

		MOVE.L	#vbl,$70.W
		MOVE.L	#keyboard,$118.W
		MOVE.L	#$ff00ff40,$fffffA06.W
		MOVE.L	#$ff00ff40,$fffffA12.W
		BCLR	#3,$fffffA17.W 
		MOVE.W	#$2300,SR

begin:

		bsr	set_res
		MOVE.L	#STACK+4000,D0		;top of memory - change!
		SUB.B	D0,D0
		MOVE.L	D0,logic
		MOVE.W	Lines,d1
		mulu.w	BytesPerLine,d1
		ADD.L	D1,D0
		MOVE.L	D0,physic
		 IFEQ noscreens-3
		ADD.L	D1,D0
		MOVE.L	D0,third
		 ENDC

		BSR	ClearScreens
		BSR	Initialize_Routine
		move.w	#-1,d7			;do 65535 frames ;)
		JSR	Display_Routine
		bra	quit


; Utility routines:
;--------------------------------------------------------------
screen_swap:
	IFEQ	noscreens-3
		MOVE.L	logic,D0
		MOVE.L	third,logic
		MOVE.L	physic,third
		MOVE.L	D0,physic
	ELSE
		MOVE.L	logic,D0
		MOVE.L	physic,logic
		MOVE.L	D0,physic
	ENDC
		MOVE.L	physic,-(A7)
		MOVE.B	1(A7),$ffff8201.W
		MOVE.B	2(A7),$ffff8203.W
		MOVE.B	3(A7),$ffff820d.W
		ADDQ.L	#4,A7
		RTS

;--------------------------------------------------------------
ClearScreens:
		MOVE.L	physic,A0
		MOVE.L	logic,A1
	IFEQ	noscreens-3
		MOVE.L	third,A2
	ENDC
		MOVE.L	#Back_Colour,D0
		;MOVE.L	#ScreenLines*BytesPerLine/4,D1

		MOVE.W	Lines,d1
		mulu.w	BytesPerLine,d1
		ASR.L	#2,D1

.Wipe:		MOVE.L	D0,(A0)+
		MOVE.L	D0,(A1)+
	IFEQ	noscreens-3
		MOVE.L	D0,(A2)+
	ENDC
		SUBQ.L	#1,D1
		BNE.S	.Wipe
		RTS

*--------------------------------------------------------
		section	bss
		IFEQ	noscreens-3
third			ds.l	1
		ENDC



		SECTION	DATA

		IFNE	Tracker_On
		INCLUDE	TRACKERC.S
		ELSE
Dsp_Library:	INCLUDE NEW_OS3.S
		ENDC

		SECTION	TEXT



;--------------------------------------------------------------

preload:
		ifne	loadtex
		loadfile "envmap.god",texmap_64-6
		loadfile "tex128.god",texmap_256-6
		endc

		rts

display_routine:
		bsr	do_effects
	ifeq	demo
		rts
	else
		move.l	(a7)+,d0
		rts
	endc


initialize_routine:
		lea	cam_movement,a0
		lea	cam_restart_pos,a1
		jsr	cam_set
		jsr	cam_calc
		rts

do_effects:
		bsr	clearscreens

		jsr	init_scroller
		move.l	#scroller,my_vbl
		move.w	#$2300,sr

.holdit:
		tst.w	quit_flag
		bne.s	.exit

		tst.b	scroll_table+0
		beq.s	.holdit

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

		bsr	send_clipping

		bsr	main_loop

.exit
		rts

main_loop:
		bsr	send_objects
.main_loop
		tst.w	quit_flag
		bne.s	.exit
		bsr	create_frame
		bra.s	.main_loop
.exit:
		 wait_transmit
		move.l	#"RTS",$ffffa204.w
		rts

create_frame:
		bsr	send_objects
		jsr	spin_object
		bsr	start_world
		bsr	clearscreen
		bsr	draw_object
		bsr	screen_swap_three
		rts


set_res:
		clr.l	$ffff9800.w

;??? MISSING LINE
		and.b	#%11,d0
		cmp.b	#0,d0
		beq	mono_exit

		cmp.b	#2,d0		;vga?
		beq	set_vga


* ###########################################################################
* #                                                                         #
* #  'Screens Pain' coded 1993 by Chris of AURA & Scandion of the Mugwumps  #
* #                                                                         #
* #                 --- It's an INDEPENDENT-Product ---                     #
* #                                                                         #
* ###########################################################################
* Monitor: RGB/TV
* 384*200, True Color, 50.0 Hz, 15625 Hz

		move.b	$ffff82c1.w,d0
		and.b	#%100,d0			;save bit 2

	        MOVE.L   #$FE00CC,$FFFF8282.W
                MOVE.L   #$280019,$FFFF8286.W
                MOVE.L   #$BA00D9,$FFFF828A.W
                MOVE.L   #$2710265,$FFFF82A2.W
                MOVE.L   #$2F0081,$FFFF82A6.W
                MOVE.L   #$211026B,$FFFF82AA.W
                MOVE.W   #$200,$FFFF820A.W
                MOVE.W   #$181,$FFFF82C0.W
                CLR.W    $FFFF8266.W
                MOVE.W   #$100,$FFFF8266.W
                MOVE.W   #$0,$FFFF82C2.W		;double scan off
                MOVE.W   #$180,$FFFF8210.W
		or.b	d0,$ffff82c1.w

		lea	x_min,a0
		move.w	#-192,(a0)+
		move.w	#+190,(a0)+
		move.w	#-100,(a0)+
		move.w	#+90,(a0)+

		move.w	#768,BytesPerLine
		move.w	#200,Lines
		rts

set_vga:

* ###########################################################################
* #                                                                         #
* #  'Screens Pain' coded 1993 by Chris of AURA & Scandion of the Mugwumps  #
* #                                                                         #
* #                 --- It's an INDEPENDENT-Product ---                     #
* #                                                                         #
* ###########################################################################
* Monitor: VGA
* 320*200, True Color, 60.0 Hz, 31470 Hz
	
        	MOVE.L   #$C6008D,$FFFF8282.W
        	MOVE.L   #$1502AC,$FFFF8286.W
        	MOVE.L   #$8D0097,$FFFF828A.W
        	MOVE.L   #$41903AF,$FFFF82A2.W
        	MOVE.L   #$8F008D,$FFFF82A6.W
        	MOVE.L   #$3AD0415,$FFFF82AA.W
        	MOVE.W   #$200,$FFFF820A.W
        	MOVE.W   #$186,$FFFF82C0.W
        	CLR.W    $FFFF8266.W
        	MOVE.W   #$100,$FFFF8266.W
        	MOVE.W   #$5,$FFFF82C2.W
	        MOVE.W   #$140,$FFFF8210.W

		lea	x_min,a0
		move.w	#-160,(a0)+
		move.w	#+158,(a0)+
		move.w	#-100,(a0)+
		move.w	#+90,(a0)+
		move.w	#640,BytesPerLine
		move.w	#200,Lines
		rts

;--------------------------------------------------------------

screen_swap_three:
		move.l	physic,d0
		move.l	logic,physic
		move.l	third,logic
		move.l	d0,third

		;move.l	physic,-(a7)
		;move.b	1(a7),$ffff8201.w
		;move.b	2(a7),$ffff8203.w
		;move.b	3(a7),$ffff820d.w
		;addq.l	#4,a7
		rts





;--------------------------------------------------------------
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


start_world:
		tst.b	scroll_table+1
		beq.s	.nowobble

		lea	objectlist+4*3,a0
		lea	wobblelist,a1
		lea	sinetable,a2
		move.w	#8-1,d0
.wobble:
		move.w	(a1)+,d1
		move.w	(a1),d2
		add.w	d1,d2
		and.w	#$1fff,d2
		move.w	d2,(a1)+
		move.w	(a2,d2.w*2),d2
		muls.w	#1800,d2
		swap	d2
		ext.l	d2
		move.l	d2,(a0)
		lea	objsize(a0),a0
		dbf	d0,.wobble

.nowobble:

		tst.b	scroll_table+2
		beq.s	.nospin

		lea	objectlist,a0
		add.l	#+4,0*objsize+4*4(a0)
		add.l	#-1,1*objsize+4*4(a0)
		add.l	#+4,2*objsize+4*4(a0)
		add.l	#+1,3*objsize+4*4(a0)
		add.l	#+2,4*objsize+4*4(a0)
		add.l	#+3,5*objsize+4*4(a0)
		add.l	#+4,6*objsize+4*4(a0)
		add.l	#+5,7*objsize+4*4(a0)
.nospin:
		bsr	send_viewpoint
		bsr	makematrixlight		;must be done first
		bsr	makematrixobject

		wait_transmit
		move.l	#"CAL",$ffffa204.w
		rts

wobblelist:
		dc.w	70,0
		dc.w	120,0
		dc.w	-84,0
		dc.w	32,0
		dc.w	-143,0
		dc.w	88,0
		dc.w	96,0
		dc.w	-63,0

draw_object:
		move.l	logic,a0
		bsr	handle_object_world
		rts


;--------------------------------------------------------------

	ifeq bitplane_mode
reptval equ ((object_width*2)/13/4)+1

clearscreen:
		move.l	logic,a6
		;add.l	#191*bytesperline,a6
		;lea	(2*(pixels+object_width)/2)(a6),a6

		MOVE.W	Lines,d1
		sub.w	#8,d1
		mulu.w	BytesPerLine,d1
		add.l	d1,a6

		moveq	#0,d1
		move.l	d1,d2
		move.l	d1,d3
		move.l	d1,d4

		move.l	#$0001,d0
		movec	d0,cacr

		move.w	Lines,d0
		subq.w	#8,d0
		mulu.w	BytesPerLine,d0
		asr.l	#6,d0			;divide by 64
		subq.w	#1,d0

.wipe:
		movem.l	d1-d4,-(a6)
		movem.l	d1-d4,-(a6)
		movem.l	d1-d4,-(a6)
		movem.l	d1-d4,-(a6)
		dbf	d0,.wipe

		move.l	#$1919,d0
		movec	d0,cacr
		rts
	endc

;--------------------------------------------------------------
spin_object:
	ifne keys
		bsr	handle_keyboard
	else
		jsr	cam_calc

		lea	cam_output_values,a0
		move.w	(a0)+,d0
		ext.l	d0
		move.l	d0,viewer_x
		move.w	(a0)+,d0
		ext.l	d0
		move.l	d0,viewer_y
		move.w	(a0)+,d0
		ext.l	d0
		move.l	d0,viewer_z
		move.w	(a0)+,d0
		ext.l	d0
		move.l	d0,rotation_x
		move.w	(a0)+,d0
		ext.l	d0
		move.l	d0,rotation_y
		move.w	(a0)+,d0
		ext.l	d0
		move.l	d0,rotation_z
		move.w	(a0)+,d0
		ext.l	d0
		asl.l	#2,d0
		move.l	d0,viewer_distance
	endc
		movem.l	rotation_x,d0/d1/d2
		movem.l	d0/d1/d2,lightrot_x
		rts


makematrixobject:
		movem.l	rotation_x,d0/d1/d2
		move.l	#"MAT",d7
		bra.s	domatrix
makematrixlight:
		movem.l	lightrot_x,d0/d1/d2
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


x_min		dc.w	0
x_max		dc.w	0
y_min		dc.w	0
y_max		dc.w	0
c_persp		dc.w	50

send_clipping:
		lea	$ffffa204.w,a0
		 wait_transmit
		move.l	#"CLI",(a0)	

		lea	x_min(pc),a1
		move.w	#5-1,d0
.sendit:
		move.w	(a1)+,d1
		ext.l	d1
		 wait_transmit
		move.l	d1,(a0)	
		dbf	d0,.sendit
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
		;add.l	#(pixels/2)*2+bytesperline*(lines/2),a0


		MOVE.W	Lines,d1
		asr.w	#1,d1
		mulu.w	BytesPerLine,d1
		add.l	d1,a0

		move.w	BytesPerLine,d1
		asr.w	d1
		add.w	d1,a0

		move.l	a0,screen_centre
		move.l	#$0009,d0
		movec	d0,cacr
handleloopfull:
		lea	$ffffa206.w,a1
		lea	$ffffa202.w,a2
		move.w	bytesperline,d7
		ext.l	d7
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
;-----------------------------------------------------------
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
		 moveq #0,d4
		 ;move.w	d5,d4
		 ;swap	d4
		 ;move.w	d5,d4
.printpoly2:
		  move.w (a1),d2
		  lea	(a0,d2.w*2),a3
		  moveq	#0,d5
		  move.w (a1),d3
		  asr.w	#3,d3
		  ;bcc.s	.next3
		  ;move.w d4,(a3)+
.next3	  	;subq.w #1,d3
		  bmi.s	.next2
.pp2
		   move.l d4,(a3)+
		   move.l d4,(a3)+
		   move.l d4,(a3)+
		   move.l d4,(a3)+
		  dbra	d3,.pp2
.next2		  add.l d7,a0
		 dbf	d1,.printpoly2
		bra	handleloop

get_gouraud:
		bra	handleloop

;-----------------------------------------------------------
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
		 wait_transmit
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
		lea	worldlist,a0
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


		ifne	0
tex_calc_envmap:
		lea	texmap_64,a0
		move.w	#-32,d7
.row
		move.w	#-32,d6
.col
		move.w	d6,d0
		muls	d0,d0
		move.w	d7,d1
		muls	d1,d1
		add.l	d1,d0
		asr.l	#3,d0
		neg.w	d0
		add.w	#127,d0
		bge.s	.ok
		moveq	#0,d0
.ok
		asr.w	#2,d0
		mulu.w	#$841,d0
		move.w	d0,(a0)+
		addq.w	#1,d6
		cmp.w	#32,d6
		bne.s	.col
		addq.w	#1,d7
		cmp.w	#32,d7
		bne.s	.row
		rts
		endc

;--------------------------------------------------------------
 
		include	include\cam.s

;--------------------------------------------------------------

send_viewpoint:
		LEA	$FFFFA204.W,A1
		 wait_transmit
		MOVE.L	#"VIE",(A1)
		MOVEQ	#3-1,D0			;for view pos
		LEA	viewer_x,A2
.loop:
		;MOVE.L	(A0)+,D1
		MOVE.L	(A2)+,D1
		wait_transmit
		MOVE.L	D1,(A1)
		DBF	D0,.loop

		LEA	camera_x,A2
		MOVEQ	#3-1,D0			;for view pos
.loop2:
		MOVE.L	(A2)+,D1
		wait_transmit
		MOVE.L	D1,(A1)
		DBF	D0,.loop2

		 wait_transmit
		MOVE.L	Viewer_Size,(A1)
		RTS

		;include	d:\source\sl\autopal\autopal.s

		;define_autopal	texture_palette
		;define_autopal	back_palette

;--------------------------------------------------------------
			section data
;--------------------------------------------------------------

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



;--------------------------------------------------------------
init_scroller:
		move.l	physic,lastscreen
		move.l	#scrollerstart,scroller_pos
		move.w	#7,scroller_bit

		rts

scroller:	
		move.l	physic,-(a7)		;force the
		move.b	1(a7),$ffff8201.w	;screen addy
		move.b	2(a7),$ffff8203.w	;to be "physic"
		move.b	3(a7),$ffff820d.w
		addq.l	#4,a7


		move.l	physic,a0
		move.l	lastscreen,a1
		move.l	a0,lastscreen		;remember where we
						;last drew it
						;for next time!
		;move.l	logic,a0
		;move.l	logic,a1
; now copy from a1 to a0
		;add.l	#192*BytesPerLine,a0
		;'add.l	#192*BytesPerLine+2,a1

		MOVE.W	#192,d1
		mulu.w	BytesPerLine,d1
		add.l	d1,a0
		add.l	d1,a1
		addq.l	#2,a1

		pea	(a0)
		;move.w	#BytesPerLine/4*10-1,d0

		move.w	BytesPerLine,d0
		mulu.w	#8,d0
		asr.w	#2,d0
		subq.w	#1,d0

.copy		move.l	(a1)+,(a0)+
		dbf	d0,.copy
		move.l	(a7)+,a0
		bsr	Scroller_draw_ends
		rts

scroller_draw_ends:
		move.w	scroller_bit,d0
		subq.w	#1,d0
		bge.s	.ok
		add.w	#6,d0
		addq.l	#1,scroller_pos
.ok		move.w	d0,scroller_bit

		move.l	scroller_pos,a1
		moveq	#0,d1
		move.b	(a1),d1			;font char
; check for a control byte

		bne.s	.nope
		addq.l	#1,a1
		move.b	(a1)+,d1
		st	(scroll_table.l,d1.w)

		move.b	(a1),d1			;get next char
		move.l	a1,scroller_pos
.nope:
		bpl.s	.carryon
		move.l	#scrollerend,a1
		move.l	a1,scroller_pos
		move.b	(a1),d1
.carryon:
		lea	(scroller_font-33*8,d1.w*8),a1
; we now have the font address

		moveq	#8-1,d2
		add.w	BytesPerLine,a0
		subq.l	#2,a0

.draw:		move.b	(a1)+,d3
		btst	d0,d3
		sne	d4
		ext.w	d4
		move.w	d4,(a0)
		;lea	BytesPerLine(a0),a0
		add.w	BytesPerLine,a0
		dbf	d2,.draw
		rts


lastscreen:	ds.l	1
scroller_pos:	ds.l	1
scroller_bit	ds.w	1
scroll_table	ds.b	20

scrollerstart:
		dc.b	"   If you think this is all, then "
		dc.b	"boy, you're so... actually you're not "
		dc.b	"too far off the mark..."

		dc.b	0,0			;start play
		dc.b	"     welcome to oldskool Maggie 26 with "
		dc.b	"a teeny-weeny intro without any music. "

		dc.b	"This is a little test rout by Tat/Avena to "
		dc.b	"see if his 3D-routines will run for "
		dc.b	"5 minutes without crashing. "
		dc.b	"In fact, they're quite cute (despite the "
		dc.b	"polygon-sorting bugs). Watch this"
		dc.b	"........"
		dc.b	0,1			;start wobble

		dc.b	"       There! That's nice. "
		dc.b	"(Incidentally, it's nice to be re-introduced "
		dc.b	"to the joy of a good row of dots). "
		dc.b	"Indeed the objects do other things as well as "
		dc.b	"wobble......      "
		dc.b	0,2
		dc.b	"See?     Hopefully this intro will give you a "
		dc.b	"taster of what might be coming in 'Binliner'"
		dc.b	", the forthcoming Avena demo. Now go "
		dc.b	"and read the articles! bye"
scrollerend:
		dc.b	"            "

		dc.b	-1



		ds.b	8
scroller_font:	incbin	m26intro.fnt

;--------------------------------------------------------------


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
code_address:
			incbin	d:\dsp\asm\maggie26.cld
codesize		equ	(*-code_Address)/3
			even


;--------------------------------------------------------------
			cnop	0,4

			section	bss
scan_min		ds.l	1
scan_max		ds.l	1
screen_centre		ds.l	1
;shademap_buffer		ds.w	64*64*16
;colour_table		ds.w	65536
			section	text

;--------------------------------------------------------------

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
mshape	equ	0
ashape	equ	1
gshape	equ	2
ishape	equ	3
eshape	equ	4
shape2	equ	5
shape6	equ	6
objectlist:
	initobj
	defobj	 LetterM,mshape,-3600,+00800,00000,0,0,0,0
	defobj	 LetterA,ashape,-2400,+00800,00000,0,0,0,0
	defobj	LetterG1,gshape,-0800,+00800,00000,0,0,0,0
	defobj	LetterG2,gshape,+0800,+00800,00000,0,0,0,0
	defobj	 LetterI,ishape,+2400,+00800,00000,0,0,0,0
	defobj	 LetterE,eshape,+3600,+00800,00000,0,0,0,0
	defobj	 Letter2,shape2,-0800,-00800,00000,0,0,0,0
	defobj	 Letter6,shape6,+0800,-00800,00000,0,0,0,0

objectlistsize	equ	(*-objectlist)/4

;--------------------------------------------------------------
drawlists:
		dc.l	3			;only one to send
		initdl

		defdl	Maglist,8,sort
		dc.l	LetterM
		dc.l	LetterA
		dc.l	LetterG1
		dc.l	LetterG2
		dc.l	LetterI
		dc.l	LetterE
		dc.l	Letter2
		dc.l	Letter6

;--------------------------------------------------------------

worldlist:	dc.l	1
		dc.l	Maglist

;--------------------------------------------------------------

Man_Scene:
		include e:\3d\maggie26.ob3
		even


;--------------------------------------------------------------
;	graphics
;--------------------------------------------------------------

;texmap_256:		equ *+6
;			ifeq	loadtex
;			;incbin	e:\test\data\tex128.god
;			else
;			;ds.w	128*128
;			endc

texmap_64:		equ	*+6
			incbin	d:\data\_data\_gfx\tmap3.god

cam_movement:
; anga - downwards
; angb - around z
; angc - off horizontal

; the tangent are defined as what is needed as the curve moves
; to this point...

		dc.w	-$0100,+$0300,+$0200,+$0000,+$0800,+$0100,+$3000
		dc.w	-$0000,-$0000,+$0000,-$0200,-$0100,-$0100,-$2000

bezspeed	equ	64

cam_restart_pos:
		dc.w	bezspeed
		dc.w	-$0000,+$0000,+$0000,+$0000,+$0000,+$0100,+$0900
		dc.w	+$0100,-$0000,+$0000,-$0000,+$0200,-$0000,-$0010

		dc.w	bezspeed
		dc.w	+$1000,+$0000,+$0000,-$0300,+$1100,+$0200,+$0800
		dc.w	-$0100,-$0000,+$0000,+$0000,-$0100,-$0000,-$0100

		dc.w	bezspeed		; Point at one of the figures:
		dc.w	-00000,+$0000,+00000,+$0000,-$0800,+$0400,+$0400
		dc.w	+$0010,+$0010,-$0010,-$0100,+$0100,-$0010,+$0010

		dc.w	bezspeed		; Point at one of the figures:
		dc.w	-00000,+$0000,+00000,+$0100,+$0f00,+$0100,+$0500
		dc.w	+$0010,+$0010,-$0010,-$0100,-$0100,+$0010,+$0200

		dc.w	bezspeed
		dc.w	+$0000,+$0800,+$0000,-$0800,-$1100,-$0100,+$0a00
		dc.w	+$0000,+$0100,+$0000,+$0100,+$0100,+$0100,-$0200

		dc.w	bezspeed
		dc.w	+$0000,+$1800,+$0000,-$0300,+$0400,+$0300,+$0600
		dc.w	-$0010,-$0100,-$0010,+$0000,-$0000,-$0100,+$0100

		dc.w	bezspeed
		dc.w	-$0100,+$0300,+$0200,+$0000,+$0800,+$0100,+$0700
		dc.w	-$0000,-$0000,+$0000,-$0200,-$0000,-$0100,-$0100
		dc.w	-1




;--------------------------------------------------------------
			cnop	0,4
			section	bss
BytesPerLine		ds.w	1
Lines			ds.w	1

;tempsin1		ds.l	1
;tempsin2		ds.l	1
;tempsin3		ds.l	1


			ds.l	300
stack
			ds.b	3*768*200+4256
lastline:
