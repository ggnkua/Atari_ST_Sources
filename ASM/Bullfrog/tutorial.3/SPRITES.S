*****************************************************************************
*                   SET YOUR TAB SIZE TO 4 !!!!!!!!!!!!                     *
*          OTHERWISE IT WILL LOOK LIKE A TOTAL MESS !!!!!!!!!!!             *
*****************************************************************************
;ISOCONTROL	equ	1						try this line for fake isometric!
;RAPID_FIRE	equ	1						makes the fire button auto-repeat
MAX_SPEED	equ 16						max speed of the main character
MAX_SHOTS	equ 16						max number of shots active at any time
BOING       equ 14						bounce factor of the shots
SHOT_COUNT	equ	256						death delay of the shots
*****************************************************************************
*                    Hardware Regs & system variables                       *
*****************************************************************************
REZ			equ	$ffff8260				resolution
H_PAL  		equ $ffff8240				palette
KB_CONTROL	equ	$fffffc00				keyboard control
KB_DATA		equ $fffffc02				keyboard data

VBI			equ	$70						vertical blank interupt

KB_SPACE	equ $39						key code for space
*****************************************************************************
*                              Dos functions                                *
*****************************************************************************
PRINTLINE	equ	$9
FOPEN		equ $3d
FCLOSE		equ	$3e
FREAD		equ	$3f
*****************************************************************************
*                              sprite stuff                                 *
*****************************************************************************
QUIF_LEFT_START		equ	0
QUIF_LEFT_END		equ 3
QUIF_RIGHT_START	equ 4
QUIF_RIGHT_END		equ 7
QUIF_DEATH_START	equ	8
QUIF_DEATH_END		equ	15
GUMBO_LEFT_START	equ 16
GUMBO_LEFT_END		equ 19
GUMBO_RIGHT_START	equ 20
GUMBO_RIGHT_END		equ 23
TEDDY_LEFT_START	equ	24
TEDDY_LEFT_END		equ	27
TEDDY_RIGHT_START	equ	28
TEDDY_RIGHT_END		equ 31
EXPLODE1_START		equ	32
EXPLODE1_END		equ	35
EXPLODE2_START		equ	36
EXPLODE2_END		equ	39
*****************************************************************************
*                          shot structure stuff                             *
*****************************************************************************
SH_MODE		equ		0
SH_ALL      equ		2
SH_XYZ		equ     2
SH_X		equ     2
SH_Y		equ     4
SH_Z		equ     6
SH_VXYZ		equ     8
SH_VX		equ     8
SH_VY		equ     10
SH_VZ		equ     12
SH_FRAME    equ		14
SH_SIZE		equ		16
*****************************************************************************
*            This is about the cleanest startup I can think of              *
*****************************************************************************
start
	clr.l	-(sp)						OS startup stuff
	move.w	#$20,-(sp)
	trap	#1   						stick it in supervisor mode
	addq.l	#6,sp
	move.l	d0,old_ssp
    move.w	#3,-(sp)					logbase to find the screen
	trap	#14
	addq.l	#2,sp
	move.l	d0,_d_screen				currently displayed screen
	move.l	d0,old_screen
    move.l	#w_screen,d0
	addi.l	#256,d0						ensure it's on a 256 byte boundry
	andi.l	#$ffffff00,d0
	move.l	d0,_w_screen				and you have another screen
	move.l  VBI,old_vbi					back up the old vbi
	move.l	#_vbi,VBI					patch in the new one

	move.w	#34,-(sp)
	trap	#14							get system vectors
	addq.l  #2,sp

	move.l	d0,a0						address of system vectors
	lea		24(a0),a0					move to joystick vector
	move.l  a0,j_pack_address			store the address of the vector
	move.l	(a0),old_j_pack				store the old vector
	move.l	#_joy_handler,(a0)			patch in the new one

js_loop
	btst.b	#1,(KB_CONTROL).w			is keyboard ready for command
	beq.s   js_loop                     no, loop
	move.b	#$15,(KB_DATA).w			set joysick to, must request a packet mode

	bsr		_main						yer actual program

jrs_loop
	btst.b	#1,(KB_CONTROL).w			is keyboard ready for command
	beq.s   jrs_loop                    no, loop
	move.b	#$8,(KB_DATA).w				set mouse relative mode

	move.l	j_pack_address,a0
	move.l	old_j_pack,(a0)				put the old joystick handler back

	move.l  old_vbi,VBI
    move.l	old_ssp,sp					clean exit

	move.w	#-1,-(sp)					res
	move.l	old_screen,-(sp)			reset the screen pos
	move.l	old_screen,-(sp)
	move.w	#5,-(sp)
	trap    #14
	lea		12(sp),sp
	clr.w	-(sp)
	trap	#1
*****************************************************************************
*           Do the disc access and call _display if it was ok,              *
*                   otherwise end with an error message                     *
*****************************************************************************
_main
	lea		spr32_fname,a0				the sprite file name
    lea		_spr_32,a1					the address to load the file to
	move.l	#256*10*32,d0				the size of the file
	jsr     _load_file					read 32*32 sprites
	blt.s	error_end

	lea		spr16_fname,a0				the sprite file name
    lea		_spr_16,a1					the address to load the file to
	move.l	#5*160,d0	     			the size of the file
	jsr     _load_file					read 32*32 sprites
	blt.s	error_end

		move.b  (REZ).w,old_rez			store the old resolution
		move.b	#0,(REZ).w				whack it into lo rez
		movem.l	(H_PAL).w,d0-d7
		movem.l	d0-d7,old_pal
		movem.l	palette,d0-d7			how to set the palette in 2 instructions
		movem.l	d0-d7,(H_PAL).w			but remember, it trashes all data regs

		bsr		_display				the main game loop

       	movem.l	old_pal,d0-d7
		movem.l	d0-d7,(H_PAL).w
		move.b	old_rez,(REZ).w			stick it back in original mode

error_end
	rts
*****************************************************************************
*                      The main loop of the program                         *
*****************************************************************************
_display
	bsr		_init_player
disploop
		bsr		_wait_vbi				wait for the vbi
		move.l	_w_screen,a0
		bsr		_do_background  		draw the background

**************************** draw the sprites *******************************

		movem.w	player_xy,d0/d1
        asr.w	#2,d0
        asr.w	#3,d1
		sub.w	#32,d1					subtract these values because the -
		sub.w	#16,d0					coordinate is the mid centre
		move.w	player_frame,d2
		bsr     _spr3232

		bsr		_draw_shots
****************************** flip screens *********************************

		bsr		_swap_screens

*********** now do any non graphic work like moving the sprites *************

		bsr		_move_player
		move.l	dxy_joy,d0
		beq.s	not_valid
			move.l	d0,lv_joy
not_valid
		tst.b	fire_last_turn
		beq.s	check4fire
	ifnd	RAPID_FIRE
			tst.b	fire
			bne.s	no_fire
	endc
			sf		fire_last_turn
			bra.s	no_fire
check4fire
		tst.b	fire
		beq.s	no_fire
			bsr		_init_shot
			st		fire_last_turn
no_fire

		bsr		_move_shots

		cmp.b	#KB_SPACE,(KB_DATA).w		is space bar pressed ?
		beq.s   exit_display				yes, exit!

******************* force a joystick interupt to occur **********************
jr_loop
		btst.b	#1,(KB_CONTROL).w			is keyboard ready for command
		beq.s   jr_loop                     no, loop
		move.b	#$16,(KB_DATA).w            request a joystick packet
		bra		disploop

exit_display
	rts
*****************************************************************************
_draw_shots
	lea		_shots,a5						the shot structures
	lea		_shots+MAX_SHOTS*SH_SIZE,a6		the end of the shot structures
ds_loop
		tst.w	SH_MODE(a5)					is this shot on ?
		beq		ds_next						no, move to the next one
		movem.w	SH_XYZ(a5),d0/d1/d2         get sprites x,y and z coords
        asr.w	#2,d0						scale-
        asr.w	#3,d1						em
		subq.w	#8,d0
		sub.w	#7,d1                       move to top of shadow
		movem.w	d0/d1/d2,-(sp)
		lea		_spr_16+160*4,a1
		move.l	_w_screen,a0
		moveq	#7,d2						height of a shadow
		bsr		_s16_draw
		movem.w	(sp)+,d0/d1/d2
		sub.w	#9,d1
		asr.w	#1,d2
		sub.w	d2,d1
		lea		_spr_16,a1
		move.w	SH_FRAME(a5),d3
		and.w	#%1100,d3					frame *4
*
;		mulu	#160,d3						* size of one sprite
****** the following five lines are the quick way to multiply by 160 ********
		move.w	d3,d4
		add.w	d3,d3						*8
		add.w	d3,d3						*16
		add.w	d4,d3						*20
		lsl.w	#3,d3						*8*20 = *160
*
		adda.w	d3,a1
		move.l	_w_screen,a0
		moveq	#16,d2
		bsr		_s16_draw
ds_next
    lea		SH_SIZE(a5),a5
	cmpa.l	a5,a6
	bne.s	ds_loop
	rts
*****************************************************************************
_init_shot
    lea		_shots-SH_SIZE,a0				one shot back from the start as-
	move.w	#MAX_SHOTS-1,d7
is_loop
		lea		SH_SIZE(a0),a0				this line increments the pointer
        tst.w	SH_MODE(a0)
        dbeq	d7,is_loop					loop until d7=0 or z flag set
		beq.s	found_empty_shot			found one!
	rts										return if no empty shot structures
found_empty_shot
	movem.w player_xy,d0/d1					get the player x & y
    moveq	#0,d2							clear z
	movem.w	lv_joy,d3/d4					joystick directions
	asl.w	#3,d3							scale em up as velocities
	asl.w	#3,d4
	movem.w	player_vxy,d5/d6
	add.w	d5,d3
	add.w	d6,d4
	moveq	#BOING,d5						the initial velocity
	move.w	#SHOT_COUNT,d6					the life expectency of the shot
	move.w	#1,SH_MODE(a0)					flag the shot as alive
	movem.w	d0/d1/d2/d3/d4/d5/d6,SH_ALL(a0)	set all the shot variables
	rts
*****************************************************************************
_move_shots
	lea		_shots,a0						a0-> the shot structures
	move.w	#MAX_SHOTS-1,d7					-1 coz of the dbra instruction
ms_loop
    move.w	SH_MODE(a0),d0

* maybe switch on mode here

	beq		next_shot
	movem.w	SH_ALL(a0),d0/d1/d2/d3/d4/d5/d6	get all the data
	add.w	d3,d0
	add.w	d4,d1
	add.w	d5,d2
	bpl.s	still_positive					it's still above the ground
        neg.w	d5							'bounce' by inverting the velocity
		add.w	d5,d2
		subq.w	#1,d5

	tst.w	d3
	beq.s	no_xv
	bpl.s	pl_xv
		addq.w	#1,d3
		bra.s	no_xv
pl_xv
		subq.w	#1,d3
no_xv

	tst.w	d4
	beq.s	no_yv
	bpl.s	pl_yv
		addq.w	#1,d4
		bra.s	no_yv
pl_yv
		subq.w	#1,d4
no_yv


still_positive
	subq.w	#1,d5							gravity

	subq.w	#1,d6							decrease life counter
    beq.s	kill_shot						kill it off if it's 0
	movem.w	d0/d1/d2/d3/d4/d5/d6,SH_ALL(a0)	put all the data back
next_shot
	lea		SH_SIZE(a0),a0					move to next shot
	dbra	d7,ms_loop
	rts
kill_shot
	clr.w	SH_MODE(a0)						kill the shot
	bra.s	next_shot						move on to the next one

*****************************************************************************
_init_player
	move.w	#GUMBO_RIGHT_START,player_frame
	move.w	#160*4,player_x
	move.w	#100*4,player_y
	rts
*****************************************************************************
_move_player
	movem.w	dxy_joy,d0/d1						get joystick directions
	movem.w	player_data,d2/d3/d4/d5/d6
	moveq	#0,d7                               clear animation flag

; d2 = x, d3 = y, d4 = vx, d5 = vy, d6 = frame
;
;	x & y coordinates are stored *4 to make the momentum work
;
	tst.w	d0									joystick x moving?
	bne.s	xjoy_moving							yes

	tst.w	d4									any x vel?
	beq.s	p_xmove_done						no, so dont move
	bpl.s	p_xvpos
		addq.w	#2,d4							negative slowdown
p_xvpos
		subq.w	#1,d4               	        slow down

xjoy_moving
		add.w	d0,d4                           adjust x vel
		cmp.w	#MAX_SPEED,d4
		ble.s	p_xv_adj_done					dont go above max right speed
			moveq	#MAX_SPEED,d4
			bra.s	p_xadj_done
p_xv_adj_done
		cmp.w	#-MAX_SPEED,d4
		bge.s	p_xadj_done						dont go above max left speed
			moveq	#-MAX_SPEED,d4
p_xadj_done
		moveq	#1,d7							set animation flag
p_xmove
		add.w	d4,d2							adjust x
p_xmove_done
	tst.w	d1									joystick y moving?
	bne.s	yjoy_moving							yes

	tst.w	d5									any y vel?
	beq.s	p_ymove_done						no, so dont move
	bpl.s	p_yvpos
		addq.w	#2,d5							negative slowdown
p_yvpos
		subq.w	#1,d5               	        slow down

yjoy_moving
		add.w	d1,d5                           adjust y vel
		cmp.w	#MAX_SPEED,d5
		ble.s	p_yv_adj_done					dont go above max down speed
			moveq	#MAX_SPEED,d5
			bra.s	p_yadj_done
p_yv_adj_done
		cmp.w	#-MAX_SPEED,d5
		bge.s	p_yadj_done						dont go above max up speed
			moveq	#-MAX_SPEED,d5
p_yadj_done
		moveq	#1,d7							set animation flag
p_ymove
		add.w	d5,d3							adjust y
p_ymove_done

	tst.w	d0									joy x
	beq.s	no_reframe
	bmi.s   reframe_left
		and.w   #%11,d6							just keep animation count
        or.w	#GUMBO_RIGHT_START,d6			face right
		bra.s	no_reframe
reframe_left
		and.w   #%11,d6							just keep animation count
		or.w	#GUMBO_LEFT_START,d6
no_reframe
    tst.w	d7
	beq.s	p_no_anim
		move.w  player_delay,d7
		addq.w	#1,d7
		and.w	#%11,d7
		move.w	d7,player_delay
		tst.w	d7
		bne		p_no_anim
			move.w	d6,d7
			addq.w	#1,d7							inc anim
			and.w	#%00000011,d7
			and.w	#%11111100,d6
			or.w	d7,d6
p_no_anim
	tst.w	d2            						keep x coord on screen
	bpl.s	xnotneg
		moveq	#0,d2
xnotneg
	cmp.w	#(320)*4,d2
	ble.s	xnotpos
		move.w	#(320)*4,d2
xnotpos
	tst.w	d3									keep y coord on screen
	bpl.s	ynotneg
		moveq	#0,d3
ynotneg
	cmp.w	#(192)*8,d3
	ble.s	ynotpos
		move.w	#(192)*8,d3
ynotpos
    movem.w		d2/d3/d4/d5/d6,player_data		put the data back
	rts
*****************************************************************************
; this routine waits until the vertical blank interupt has occured
_wait_vbi
	tst.b	_vbi_done
	beq.s   _wait_vbi
	rts
*****************************************************************************
; very simple vertical blank routine, it just flags that it has happened
_vbi
    st		_vbi_done
	rte
*****************************************************************************
_joy_handler
	move.w	d0,-(sp)
	clr.w	d0
	move.b	1(a0),d0				F...RLDU
	add.b	d0,d0					...RLDU.	*2 for the lookup table
	scs		fire					set fire to true if it bit 7 was set
	add.b	d0,d0					..RLDU..
	move.l	jlt(pc,d0.w),dxy_joy

;	move.b	(a0),d0					use these 5 lines if you want 2 joysticks
;	add.b	d0,d0					you will need variables for
;	scs		fire0           		the other fire button
;	add.b	d0,d0           		and
;	move.l	jlt(pc,d0.w),dxy_joy0	joystick x & y directions

	move.w	(sp)+,d0
	rts
;			dx dy			the bits	imposible cases
jlt
	IFD		ISOCONTROL
	dc.w	 0,0			..0000..
	dc.w	 1,-1			..000U..
	dc.w	 -1,1			..00D0..
	dc.w	 0,0			..00DU..	*
	dc.w	-1,-1			..0L00..
	dc.w	 0,-1			..0L0U..
	dc.w	-1,0			..0LD0..
	dc.w	-1,0			..0LDU..	*
	dc.w	 1,1			..R000..
	dc.w	 1,0			..R00U..
	dc.w	 0,1			..R0D0..
	dc.w	 1,1			..R0DU..	*
	dc.w	 0,0			..RL00..	*
	dc.w	 1,-1			..RL0U..	*
	dc.w	 -1,1			..RLD0..	*
	dc.w	 0,0			..RLDU..	*
	ENDC
	IFND     ISOCONTROL
	dc.w	 0,0			..0000..
	dc.w	 0,-1			..000U..
	dc.w	 0,1			..00D0..
	dc.w	 0,0			..00DU..	*
	dc.w	-1,0			..0L00..
	dc.w	-1,-1			..0L0U..
	dc.w	-1,1			..0LD0..
	dc.w	-1,0			..0LDU..	*
	dc.w	 1,0			..R000..
	dc.w	 1,-1			..R00U..
	dc.w	 1,1			..R0D0..
	dc.w	 1,0			..R0DU..	*
	dc.w	 0,0			..RL00..	*
	dc.w	 0,-1			..RL0U..	*
	dc.w	 0,1			..RLD0..	*
	dc.w	 0,0			..RLDU..	*
	ENDC
*****************************************************************************
_swap_screens
	move.l	_w_screen,d0			d0 = screen address
	move.l	_d_screen,_w_screen
	move.l	d0,_d_screen			d0 = xxxx high low	0000

	lsr.w	#8,d0
	move.l	d0,$ffff8200.w			d0 = xxxx high xxxx low
	sf		_vbi_done
	rts
*****************************************************************************
; d0 = x, d1 = y, d2 = sprite number
_spr3232
	move.l	_w_screen,a0		draw on _w_screen
	lea		_spr_32,a1
	mulu	#640,d2				size of a 32*32 sprite
	add.w	d2,a1
	moveq	#32,d2
	bsr		_s32_draw
	rts
*****************************************************************************
*	16 pixel wide sprite draw												*
*	d0.w = QX																*
*	d1.w = QY																*
*	d2.w = sprite height													*
*   a0 -> screen                         							        *
*	a1	-> the sprite data													*
*****************************************************************************
LINES_HIGH	set 192
_s16_draw
	tst.w	d1					is y less than 0
	bge.s	y_not_minus_16		no, ok.
*****************************************************************************
*	QY is negative
	neg.w	d1
	sub.w	d1,d2				do we see any of it ?
	ble		not_drawn_16		no, dont draw it at all
; a 16 pixel wide sprite has 10 bytes a line, so we have to multiply by 10
	add.w	d1,d1				*2
	move.w	d1,d7
	add.w	d1,d1				*4
	add.w	d1,d1				*8
	add.w	d7,d1				In2Data and QY are the same reg
	adda.w	d1,a1				move into the source the required no. of line
	bra.s	y_clipped_16
*********
y_not_minus_16
	moveq	#256-LINES_HIGH,d6
	neg.b	d6					quicker than move.w #LINES_HIGH,d6
	cmp.w	d6,d1
	bge 	not_drawn_16
	move.w	d1,d7
	add.w	d7,d7				*2
	add.w	d7,d7				*4
	add.w	d1,d7				*5
	lsl.w	#5,d7				*5*32 (28 clock cycles, less than 70 for *160
	adda.w	d7,a0				move down the screen
	add.w	d2,d1
	subi.w	#LINES_HIGH,d1
	blt.s	y_clipped_16
	sub.w	d1,d2				adjust height of sprite to fit it on
y_clipped_16
*****************************************************************************
*	I suppose I better do the QX stuff now
	tst.w	d0
	bge.s	x_not_minus_16		x ok, well at least it isn't negative!
	cmpi.w	#-16,d0
	ble.s	not_drawn_16		it is off screen
	moveq	#0,d1
	bra		_left_16
x_not_minus_16
	move.w	d0,d7
	andi.w	#$f,d0				QX and QShift are the same Reg

* we want . . . 0-15 ->0, 16-31->8 etc.........

	andi.w	#$fff0,d7
	lsr.w	#1,d7
	moveq	#256-160,d6
	neg.b	d6
	cmp.w	d6,d7				is it off the right side of the screen ?
	bge.s	not_drawn_16		yes
	adda.w	d7,a0				adjust destination
	subq.w	#8,d6
	cmp.w	d6,d7
	bne		_all_16

*	right hand only case

	moveq	#0,d1
	bra		_right_16
not_drawn_16
	rts

*****************************************************************************
*	32 pixel wide sprite draw												*
*	d0.w = QX																*
*	d1.w = QY																*
*	d2.w = sprite height													*
*   a0 -> screen                         							        *
*	a1	-> the sprite data													*
*****************************************************************************
_s32_draw
	tst.w	d1					is y less than 0
	bge.s	y_not_minus_32		no, ok.
*****************************************************************************
*	QY is negative
	neg.w	d1
	sub.w	d1,d2				do we see any of it ?
	ble		not_drawn_32		no, dont draw it at all
; a 32 pixel wide sprite has 20 bytes a line, so we have to multiply by 20
	move.w	d1,d7
	add.w	d1,d1				*2
	add.w	d1,d1				*4
	add.w	d7,d1				*5
	add.w	d1,d1				*10
	add.w	d1,d1				*20
	adda.w	d1,a1				move into the source the required no. of line
	bra.s	y_clipped_32
*********
y_not_minus_32
	moveq	#256-LINES_HIGH,d6
	neg.b	d6					quicker than move.w #LINES_HIGH,d6
	cmp.w	d6,d1
	bge 	not_drawn_32
	move.w	d1,d7
	add.w	d7,d7				*2
	add.w	d7,d7				*4
	add.w	d1,d7				*5
	lsl.w	#5,d7				*5*32 (28 clock cycles, less than 70 for *160
	adda.w	d7,a0				move down the screen
	add.w	d2,d1
	subi.w	#LINES_HIGH,d1
	blt.s	y_clipped_32
	sub.w	d1,d2				adjust height of sprite to fit it on
y_clipped_32
*****************************************************************************
*	I suppose I better do the QX stuff now
	tst.w	d0
	bge.s	x_not_minus_32		x ok, well at least it isn't negative!
	cmpi.w	#-16,d0
	ble.s	may_be_32
	moveq	#0,d1
	bra		_left_32
may_be_32
	cmpi.w	#-32,d0
	ble.s	not_drawn_32
	moveq	#10,d1
	bra		_left_16
x_not_minus_32
	move.w	d0,d7
	andi.w	#$f,d0				QX and QShift are the same Reg

* we want . . . 0-15 ->0, 16-31->8 etc.........

	andi.w	#$fff0,d7
	lsr.w	#1,d7
	moveq	#256-(160-16),d6
	neg.b	d6
	adda.w	d7,a0				adjust destination
	cmp.w	d6,d7				is it definately on screen ?
	bmi		_all_32				yes
	addq.w	#8,d6
	moveq	#0,d1
	cmp.w	d6,d7
	bmi		_right_32
	addq.w	#8,d6
	moveq	#10,d1
	cmp.w	d6,d7
	bmi		_right_16
not_drawn_32
	rts
*****************************************************************************
*	The low level routines, may be useful for other stuff at some stage..	*
*****************************************************************************
DO_RIGHT	macro
	moveq	#-1,d3
	move.w	(a1)+,d3			get the QTemplate
	ror.l	d0,d3				rotate it

	moveq	#0,d4
	move.w	(a1)+,d4			get QPlane 0
	ror.l	d0,d4				rotate it
	move.w	(a0)+,d5
	and.w	d3,d5
	or.w	d5,d4				QPlane 0 made

	moveq	#0,d5
	move.w	(a1)+,d5			get QPlane 1
	ror.l	d0,d5				rotate it
	move.w	(a0)+,d6
	and.w	d3,d6
	or.w	d6,d5				QPlane 1 made

	moveq	#0,d6
	move.w	(a1)+,d6			get QPlane 2
	ror.l	d0,d6				rotate it
	move.w	(a0)+,d7
	and.w	d3,d7
	or.w	d7,d6				QPlane 0 made

	moveq	#0,d7
	move.w	(a1)+,d7			get QPlane 3
	ror.l	d0,d7				rotate it
	and.w	(a0)+,d3			may as well corrupt the QTemplate this time
	or.w	d3,d7				QPlane 3 made
	endm
*************
DO_LEFTM	macro
	swap	d3
	swap	d4
	move.w	(a0)+,d5
	and.w	d3,d5
	or.w	d5,d4				QPlane 0 made

	swap	d5
	move.w	(a0)+,d6
	and.w	d3,d6
	or.w	d6,d5				QPlane 1 made

	swap	d6
	move.w	(a0)+,d7
	and.w	d3,d7
	or.w	d7,d6				QPlane 2 made

	swap	d7
	and.w	(a0)+,d3			corrupting QTemplate
	or.w	d3,d7				QPlane 3 made
	endm
*******
DO_LEFT macro
	moveq	#-1,d3
	move.w	(a1)+,d3			get the QTemplate
	rol.l	d0,d3				rotate it

	move.w	(a1)+,d4			get QPlane 0
	lsl.w	d0,d4				rotate it
	move.w	(a0)+,d5
	and.w	d3,d5
	or.w	d5,d4				QPlane 0 made

	move.w	(a1)+,d5			get QPlane 1
	lsl.w	d0,d5				rotate it
	move.w	(a0)+,d6
	and.w	d3,d6
	or.w	d6,d5				QPlane 1 made

	move.w	(a1)+,d6			get QPlane 2
	lsl.w	d0,d6				rotate it
	move.w	(a0)+,d7
	and.w	d3,d7
	or.w	d7,d6				QPlane 0 made

	move.w	(a1)+,d7			get QPlane 3
	lsl.w	d0,d7				rotate it
	and.w	(a0)+,d3			may as well corrupt the QTemplate this time
	or.w	d3,d7				QPlane 3 made
	ENDM
*****************************************************************************
_all_16
; A0 = QSource, A1 = QDest, D0 = QShift, D2 = Height

	moveq	#256-(160-16),d1
	neg.b	d1
	subq.w	#1,d2				for dbra
a16_loop
	DO_RIGHT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	DO_LEFTM
	movem.w d4-d7,-8(a0)		another one
	adda.w	d1,a0
	dbra	d2,a16_loop
	rts
********************************************************************
_left_16
; A0 = QSource, A1 = QDest, D0 = QShift, D1 = QSkip, D2 = Height
	subq.w	#1,d2
	neg.w	d0
	andi.w	#$f,d0
l16_loop
	adda.w	d1,a1
	DO_LEFT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	lea		160-8(a0),a0
	dbra	d2,l16_loop
	rts
********************************************************************
_right_16
; A0 = QSource, A1 = QDest, D0 = QShift, D1 = QSkip, D2 = Height
	subq.w	#1,d2
r16_loop
	DO_RIGHT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	lea		160-8(a0),a0
	adda.w	d1,a1
	dbra	d2,r16_loop
	rts

*****************************************************************************
_all_32
; A0 = QSource, A1 = QDest, D0 = QShift, D2 = Height

	moveq	#256-(160-24),d1
	neg.b	d1
	subq.w	#1,d2				for dbra
a32_loop
	DO_RIGHT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	DO_LEFTM
	subq.l	#8,a0
	movem.w d4-d7,(a0)		 	another one
	DO_RIGHT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	DO_LEFTM
	movem.w d4-d7,-8(a0)		another one
	adda.w	d1,a0
	dbra	d2,a32_loop
	rts
*****************************************************************************
_left_32
; A0 = a1, A1 = QDest, D0 = QShift, D1 = QSkip, D2 = Height
	subq.w	#1,d2
	move.w	d0,d4
	neg.w	d4
	moveq	#$f,d5
	and.w	d5,d4
	and.w	d5,d0
	swap	d0
	move.w	d4,d0
l32_loop
	adda.w	d1,a1
	DO_LEFT
	subq.l	#8,a0
	movem.w d4-d7,(a0) 			i had to get a movem in there somewhere
	swap	d0
	DO_RIGHT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	DO_LEFTM
	movem.w d4-d7,-8(a0)		another one
	swap	d0
	lea		160-16(a0),a0
	dbra	d2,l32_loop
	rts
*****************************************************************************
_right_32
; A0 = QSource, A1 = QDest, D0 = QShift, D1 = QSkip, D2 = Height
	subq.w	#1,d2
	andi.w	#$f,d0
r32_loop
	DO_RIGHT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	DO_LEFTM
	subq.l	#8,a0
	movem.w d4-d7,(a0) 			another one
	DO_RIGHT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	lea		160-16(a0),a0
	adda.w	d1,a1
	dbra	d2,r32_loop
	rts
*****************************************************************************
; a0-> filename a1-> destination d0 = length
; on return d0 = file length actually read or -1 if read failed
_load_file
	move.l	d0,d6
	clr.w	-(sp)               read
	move.l	a0,-(sp)			-> filename
	move.w	#FOPEN,-(sp)
	trap	#1					open the file
	addq.l	#8,sp				readjust the stack
	move.w	d0,d7				handle
	ble.s   file_not_found
*
	move.l  a1,-(sp)			destination memory
	move.l	d6,-(sp)
	move.w	d7,-(sp)			file handle
	move.w	#FREAD,-(sp)
	trap	#1					read the file
	lea		12(sp),sp			the quick way of adding 12 to the stack
	move.l	d0,d6				length read
*
	move.w	d7,-(sp)			file handle
	move.w	#FCLOSE,-(sp)
	trap	#1					close the file
	addq.l	#4,sp
	move.l	d6,d0				so we can return the file length
	rts
file_not_found
	pea		fnf_msg(pc)			address of the error message
	move.w	#PRINTLINE,-(sp)
	trap	#1					print it
	addq.l	#6,sp
	moveq	#-1,d0
	rts
*****************************************************************************
_do_background
; copys the pattern below to the background
	move.l  _w_screen,a0
	lea		160*192(a0),a0					a0-> end of screen
	lea		-160*32(a0),a1					a1-> a2 -32 lines
	lea		-160*32(a1),a2					a2-> a3 -32 lines
	lea		-160*32(a2),a3					a3-> a4 -32 lines
	lea		-160*32(a3),a4					a4-> a5 -32 lines
	lea		-160*32(a4),a5					a5-> a6 -32 lines
	lea		background(pc),a6				-> upside-down background source

doline	macro
		movem.l d0-d7,-(\1)					set 64  pixels
		movem.l d0-d7,-(\1)						128
		movem.l d0-d7,-(\1)						192
		movem.l d0-d7,-(\1)						256
		movem.l d0-d7,-(\1)						320, a whole line
		endm

	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d5
	moveq	#0,d7
	move.b	#32,linesleft
bg_loop
		movem.l	(a6)+,d0/d2/d4/d6
		doline	a0
		doline	a1
		doline	a2
		doline	a3
		doline	a4
		doline	a5
		subq.b	#1,linesleft
		bne		bg_loop
		rts

background
 dc.l $F80F00D0,$FC1F00E0,$787F0080,$F83F00C0,$F1BF0200,$E00F0230,$BFF74000,$F11F0220
 dc.l $85FF0A00,$C3C30C0C,$FFFD0002,$87870808,$1FFE2000,$07E13802,$FFFF0000,$1FF02003
 dc.l $7FFE8000,$3F78C000,$3FBEC000,$5FF8A000,$E7FF0800,$0FDF3020,$1FDF2020,$1EBF2040
 dc.l $FFBF0000,$87FF0800,$83FF0C00,$C3FF0C00,$FE1A0061,$E0FF0300,$F1FE0200,$E07F0380
 dc.l $F83F00C0,$F81F00E0,$F87F0080,$BC3C40C1,$F0070338,$E07F0380,$E0EF0300,$E10F0230
 dc.l $83C30C0C,$87FF0800,$C1FB0E04,$C781080E,$1FE12002,$0FFE3000,$0FFE3000,$1FF02003
 dc.l $3FF8C000,$1EFCE000,$3EFCC000,$5EF8A000,$79E08203,$FF7E0080,$0F703083,$0F7F3080
 dc.l $FFC3000C,$FFFF0000,$C783080C,$87FF0800,$FE1F0020,$FFFF0000,$E00F0330,$E07F0380
 dc.l $BE1F00E0,$783F80C0,$F85F00A0,$FC3F00C0,$DF0F2030,$B01F0320,$BE0F0030,$FF1F0020
 dc.l $FFC3000C,$81830E0C,$EFC71008,$DF83000C,$FAE00102,$1FE02003,$FFE00003,$FFF00003
 dc.l $1FF8E000,$3FF8C000,$7FF88000,$77F88800,$7FFF8000,$FBF10002,$FFE10002,$FFF10002
 dc.l $FFFF0000,$FD83020C,$FF870008,$FF870008,$7F7F0080,$FF0E0030,$FF1F0020,$FF1E0021
 dc.l $F83D00C0,$F83F00C0,$7E5F80A0,$BC7F0080,$F11F0220,$710F8230,$FE0F0030,$EE1F1020
 dc.l $85810A0E,$8781080E,$FF070008,$FFC3000C,$1FF02003,$17E02803,$F7E00003,$FFE10002
 dc.l $4E78B080,$5FFCA000,$3DF8C200,$7FFC8000,$07FF3800,$FFE10002,$1FE12002,$FFBF0000
 dc.l $83FF0C00,$FFC3000C,$83C50C0A,$DFDF0020,$F0DC0321,$FE1F0020,$F01F0320,$EFFF1000

*****************************************************************************
fnf_msg		dc.b    7,'FILE NOT FOUND',10,13,7,0
spr16_fname	dc.b	'sprite16.dat',0
spr32_fname	dc.b	'sprite32.dat',0
	even
palette		dc.w	$000,$321,$432,$543,$400,$520,$630,$651
			dc.w	$331,$441,$551,$661,$013,$034,$345,$555
*****************************************************************************
	IFD		__G2		am i using devpac 2?
	section	bss			if so use this line, it saves a lot of time & disk space

	ENDC
old_rez			ds.b	1					the resolution the machine was in
_vbi_done		ds.b	1                   set during the vertical blank
fire			ds.b	1					set if fire button pressed
linesleft		ds.b	1					used as a counter in background draw
fire_last_turn	ds.b	1
	even
old_vbi			ds.l	1					for saving the system vertical blank
old_ssp			ds.l	1					system stack pointer
old_screen		ds.l	1					and original screen
_d_screen		ds.l	1					pointer to the displayed screen
_w_screen		ds.l	1					pointer to the work screen
j_pack_address	ds.l	1					where to patch the joystick vector
old_j_pack		ds.l	1					the old joystick vector
dxy_joy
;											both joystick directions for movem
dx_joy			ds.w	1					joystick x direction
dy_joy			ds.w	1					joystick y direction
lv_joy			ds.w    2					last non zero joystick directions

player_data
;											for accessing all of the player data-
player_xy
;											with a single movem
player_x		ds.w	1					player's x coordinate
player_y		ds.w	1					guess
player_vxy
player_vx		ds.w	1					player's x velocity
player_vy		ds.w	1					player's y velocity
player_frame	ds.w	1					animation frame
player_delay	ds.w	1					animation delay

seed			ds.w	1					random number seed

old_pal			ds.w	16					the old palette
w_screen		ds.b	32000+256			screen has to be on a 256 byte boundry
_spr_32			ds.b	640*40				for 40 32*32 sprites
_spr_16			ds.b	5*160
_shots			ds.b	MAX_SHOTS*SH_SIZE	the shot structures
*
