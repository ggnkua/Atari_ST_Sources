	IFD		__G2		am i using devpac 2?
	opt     o+			if so turn all the optimisations on
	opt		ow-			but turn the iritating warnings off
	ENDC
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
NO_NASTYS	equ	12						number of nastys
NA_ST_DELAY	equ 128						nasty start delay
QUICK_DELAY	equ	200						nasty's home-in delay
QUICKER		equ	8						how much the delay is shortened by
MAX_QUICK	equ	16						shortest allowable delay
NASTY_COL	equ 64						nasty/player colision size
SHOT_COL	equ 40						shot/nasty colision size
BIRTH_DELAY	equ	4						birth animation countdown
DEATH_DELAY	equ	3						death animation countdown
MAX_SH_ALT	equ 7						max altitude of ball to hit
NUM_NASTYS	equ	2						initial number of nastys
NASTY_SPEED	equ 4                       initial nastys speed
NASTY_ACCEL	equ	2						nasty's speedup per level
MORE_NASTYS	equ	1						how many more nastys per level
NASTY_QUICK	equ	7						how quickly the nastys get inteligent
*****************************************************************************
*                    Hardware Regs & system variables                       *
*****************************************************************************
REZ			equ	$ffff8260				resolution
H_PAL  		equ $ffff8240				palette
KB_CONTROL	equ	$fffffc00				keyboard control
KB_DATA		equ $fffffc02				keyboard data

VBI			equ	$70						vertical blank interupt

KB_SPACE	equ $39						key code for space
SCREEN_WIDTH	equ	160					a screen line is 160 bytes long
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
UNI_E_W		equ 	0
UNI_NW_SE	equ 	8
UNI_N_S		equ		16
UNI_SW_NE	equ		24
FIRST_HOLE	equ		32
HOLE_W		equ		FIRST_HOLE+0
HOLE_NW		equ		FIRST_HOLE+4
HOLE_N		equ		FIRST_HOLE+8
HOLE_NE		equ		FIRST_HOLE+12
HOLE_E		equ		FIRST_HOLE+16
HOLE_SE		equ		FIRST_HOLE+20
HOLE_S		equ		FIRST_HOLE+24
HOLE_SW		equ		FIRST_HOLE+28
HOLE_UP_ST	equ		64
HOLE_UP_END	equ		64+7
HOLE_DN_ST	equ		64+7
HOLE_DN_END	equ		64
*****************************************************************************
*                          shot structure stuff                             *
*****************************************************************************
SH_MODE		equ		0
SH_ALL      equ		2
SH_XY		equ     2
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
*                          nasty structure stuff                            *
*****************************************************************************
NA_MODE		equ		0
NA_ALL		equ		2
NA_XY		equ     2
NA_XY_HXY	equ		2
NA_X		equ     2
NA_Y		equ     4
NA_HOMEXY	equ     6
NA_HOMEX	equ     6
NA_HOMEY	equ     8
NA_FRAME	equ     10
NA_COUNT	equ     12
NA_DELAY	equ		14
NA_SPEED	equ		16
NA_SIZE		equ		18
*****************************************************************************
*                              nasty's modes                                *
*****************************************************************************
NA_DEAD		equ		0
NA_INIT		equ		2
NA_BIRTH    equ     4
NA_THINK	equ     6
NA_MOVE		equ     8
NA_DIE		equ     10
NA_DYING	equ		12
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
	move.l	#640*72,d0					the size of the file
	jsr     _load_file					read 32*32 sprites
	blt.s	error_end

	lea		spr16_fname,a0				the sprite file name
    lea		_spr_16,a1					the address to load the file to
	move.l	#5*160,d0	     			the size of the file
	jsr     _load_file					read 32*32 sprites
	blt.s	error_end

	lea		font_fname,a0
	lea		_font,a1
	move.l	#1472,d0
	jsr		_load_file
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
	bsr		_init_game					initialise the game

	bsr		_init_player				initialise player
disploop
		tst.w	active_holes			if no holes are active
		bne.s	holes_are_active
			bsr		_init_all_nastys    activate them
holes_are_active
		bsr		_wait_vbi				wait for the vbi
		move.l	_w_screen,a0
		bsr		_do_background  		draw the background

**************************** draw the sprites *******************************
		bsr		_draw_shads				draw the shot shadows
		bsr		_draw_nastys			draw the nastys

		lea		_score_digits,a0		convert the score
		move.w	score,d0				from binary
		bsr		_bin2dec				to decimal
		lea		_score_string,a0        print
		move.l	_w_screen,a1			the
		moveq	#14,d0					score
		moveq	#24,d1					at
		bsr		_draw_string			the bottom of the screen

		movem.w	player_xy,d0/d1			draw the player
        asr.w	#2,d0
        asr.w	#3,d1
		sub.w	#32,d1					subtract these values because the -
		sub.w	#16,d0					coordinate is the mid centre
		move.w	player_frame,d2
		bsr     _spr3232

		bsr		_draw_shots				draw the shots
****************************** flip screens *********************************

		bsr		_swap_screens

*********** now do any non graphic work like moving the sprites *************

		bsr		_colision				check for colision
		bsr		_move_player            move the player
		move.l	dxy_joy,d0				process the fire button
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
		bsr		_move_nastys

		tst.w	player_mode
		beq		exit_display
		cmp.b	#KB_SPACE,(KB_DATA).w		is space bar pressed ?
		beq.s   exit_display				yes, exit!

******************* force a joystick interupt to occur **********************
jr_loop
		btst.b	#1,(KB_CONTROL).w			is keyboard ready for command
		beq.s   jr_loop                     no, loop
		move.b	#$16,(KB_DATA).w            request a joystick packet
		bra		disploop

exit_display
	bsr		_game_over
	bne		_display
	rts
*****************************************************************************
_init_all_nastys
	move.w	vnum_nastys,d6
	subq.w	#1,d6							for dbra
ianloop
		bsr		_init_nasty
		dbra	d6,ianloop
	addq.w	#MORE_NASTYS,vnum_nastys        adjust
	addq.w	#NASTY_ACCEL,vnasty_speed		tuning
	subq.w	#NASTY_QUICK,vquick_delay		variables
	rts
*****************************************************************************
_init_game
	lea		_shots,a0
	moveq	#MAX_SHOTS-1,d0					clear shots
igcsloop
		clr.w	SH_MODE(a0)
		lea		SH_SIZE(a0),a0
		dbra	d0,igcsloop
	moveq	#NO_NASTYS-1,d0					clear nastys
igcnloop
		clr.w	NA_MODE(a0)
		lea		NA_SIZE(a0),a0
		dbra	d0,igcnloop

	clr.w	active_holes					flag all holes as dead
	clr.w	score							clear the score

	move.w	#QUICK_DELAY,vquick_delay		clear
	move.w	#NUM_NASTYS,vnum_nastys			tuning
	move.w	#NASTY_SPEED,vnasty_speed		variables
	rts
*****************************************************************************
_colision
	movem.w	player_xy,d6/d7					check player's coordinates
	lea		_nastys,a0						against nastys first
	lea		NA_SIZE*NO_NASTYS(a0),a1		-> end of nastys
	lea		_shots,a2
	lea		SH_SIZE*MAX_SHOTS(a2),a3
	moveq	#NASTY_COL,d5
	moveq	#SHOT_COL,d4

cn_loop
		move.w	NA_MODE(a0),d2
		beq.s	no_nasty
			cmpi.w	#NA_THINK,d2
			blt.s	no_nasty
			cmp.w	#NA_DIE,d2
			bge.s	no_nasty
			movem.w	NA_XY(a0),d0/d1
* check colision of this nasty against all the active shots!!!
			move.l	a2,a4					-> shot structure
cs_loop
			tst.w	SH_MODE(a4)				active?
			beq.s	no_shot_col				no, dont bother
			movem.w	SH_XY(a4),d2/d3
			sub.w	d1,d3					compare ys
			bpl.s	cs_ynn
				neg.w	d3
cs_ynn
			cmp.w	d4,d3
			bge.s	no_shot_col				dont bother
			sub.w	d0,d2
			bpl.s	cs_xnn					compares xs
				neg.w	d2
cs_xnn
			cmp.w	d4,d2
			bgt.s	no_shot_col				dont bother
			cmp.w	#MAX_SH_ALT,SH_Z(a4)	z low enough?
			bgt.s	no_shot_col				no dont bother

***************************** it's gonna die ********************************

				move.w	#NA_DIE,NA_MODE(a0)	kill it
				clr.w	SH_MODE(a4)         kill the shot

				move.w  NA_DELAY(a0),d2		increment the score
				add.w	d2,score
no_shot_col
			lea		SH_SIZE(a4),a4			move to next shot
			cmpa.l	a4,a3					last one?
			bne.s	cs_loop					no loop
*
			sub.w	d7,d1
			bpl.s	cn_ynn
				neg.w	d1
cn_ynn
			cmp.w	d5,d1
			bge.s	no_nasty
			sub.w	d6,d0
			bpl.s	cn_xnn
				neg.w	d0
cn_xnn
			cmp.w   d5,d0
			bge.s	no_nasty
				move.w	#0,player_mode	kill the player
no_nasty
        lea		NA_SIZE(a0),a0
		cmpa.l	a0,a1
		bne		cn_loop
	rts
*****************************************************************************
_init_nasty
    lea		_nastys-NA_SIZE,a0				one nasty back from the start as-
	move.w	#NO_NASTYS-1,d7
in_loop
		lea		NA_SIZE(a0),a0				this line increments the pointer
        tst.w	NA_MODE(a0)
        dbeq	d7,in_loop					loop until d7=0 or z flag set
		beq.s	found_empty_nasty			found one!
	rts										return if no empty nasty structures
found_empty_nasty
	addq.w	#1,active_holes
	move.w	#NA_INIT,NA_MODE(a0)			set mode to birth
	move.w	#HOLE_UP_ST,NA_FRAME(a0)		set the frame
	bsr		_random
	moveq	#0,d1
	move.w	d0,d1
    divu	#320*4,d1						get a random x
	swap	d1
	bsr		_random
	moveq	#0,d2
	move.w	d0,d2
    divu	#192*8,d2						get a random y
	swap	d2
	movem.w	d1/d2,NA_XY(a0)					set the x and y
	bsr		_random
	ext.l	d0
	divu	#NA_ST_DELAY,d0
	swap	d0
	addq.w	#1,d0							ensure non zero
	move.w	d0,NA_COUNT(a0)					set birth delay

	bsr		_random
	ext.l	d0
	divu	#7,d0
	swap	d0
	addq.w	#8,d0
	move.w	d0,NA_SPEED(a0)
	rts
*****************************************************************************
_draw_nastys
	lea		_nastys,a5						the nasty structures
	lea		_nastys+NO_NASTYS*NA_SIZE,a6	the end of the nasty structures
dn_loop
		tst.w	NA_MODE(a5)					is this nasty active ?
		beq		dn_next						no, move to the next one
			movem.w	NA_XY(a5),d0/d1
	        asr.w	#2,d0
	        asr.w	#3,d1
			sub.w	#32,d1					subtract these values because the -
			sub.w	#16,d0					coordinate is the mid centre
			move.w	NA_FRAME(a5),d2
			bsr     _spr3232
dn_next
    lea		NA_SIZE(a5),a5
	cmpa.l	a5,a6
	bne.s	dn_loop
	rts
*****************************************************************************
_move_nastys
    lea		_nastys,a0
	lea		NA_SIZE*NO_NASTYS(a0),a1
mn_loop
		move.w	NA_MODE(a0),d0
		move.w  mn_jt(pc,d0.w),d0
		jmp		mn_jt(pc,d0.w)
mn_jt	dc.w	mn_done-mn_jt	the dead one
		dc.w	mn_init-mn_jt	NA_INIT
		dc.w	mn_birth-mn_jt	NA_BIRTH
		dc.w	mn_think-mn_jt	NA_THINK
		dc.w	mn_move-mn_jt	NA_MOVE
		dc.w	mn_die-mn_jt	NA_DIE
		dc.w	mn_dying-mn_jt	MN_DYING
*****************************************************************************
mn_init
	subq.w	#1,NA_COUNT(a0)					count down
	bne		mn_done							have i been born yet?
		move.w	vquick_delay,NA_DELAY(a0)   yes, set the initial delay
		move.w  #NA_BIRTH,NA_MODE(a0)		born next
		move.w	#BIRTH_DELAY,NA_COUNT(a0)	birth countdown doobrey
		bra		mn_done
*****************************************************************************
mn_birth
	subq.w	#1,NA_COUNT(a0)					is this frame over ?
	bne		mn_done							no
        move.w  NA_FRAME(a0),d0
		addq.w	#1,d0                       inc frame
		cmp.w	#HOLE_UP_END,d0
		bgt.s	mn_birth_done
			move.w	d0,NA_FRAME(a0)
			move.w	#BIRTH_DELAY,NA_COUNT(a0)	reinitialise birth countdown
			bra		mn_done
mn_birth_done
    move.w	#NA_THINK,NA_MODE(a0)
	bra		mn_done
*****************************************************************************
mn_think
	move.l	player_xy,NA_HOMEXY(a0)		set destination x and y
	move.w	NA_DELAY(a0),d0				wots the delay?
	sub.w	#QUICKER,d0					make it quicker
	cmp.w	#MAX_QUICK,d0				but not quicker than the maximum
	bge.s	mn_mq_ok
		move.w	#MAX_QUICK,d0
mn_mq_ok
	move.w	d0,NA_DELAY(a0)				store it back in the delay
	move.w	d0,NA_COUNT(a0)				and the frame
	move.w	#NA_MOVE,NA_MODE(a0)		set it to move next game turn
	bra		mn_done
*****************************************************************************
*           move the nastys with a fairly basic ZOMBIE routine              *
*****************************************************************************
mn_move
	movem.w	NA_XY_HXY(a0),d0/d1/d2/d3	get nastys x,y and destination x,y
	moveq	#0,d6
	cmp.w	d2,d0
	beq.s	mn_xdone
	bgt.s	mn_xgt
mn_xlt
		moveq	#2,d6
		add.w	NA_SPEED(a0),d0
		cmp.w	d2,d0
		ble.s	mn_xdone
        	move.w	d2,d0
			bra.s	mn_xdone
mn_xgt
		moveq	#-2,d6
		sub.w	NA_SPEED(a0),d0
		cmp.w	d2,d0
		bge.s	mn_xdone
			move.w	d2,d0
mn_xdone
	cmp.w	d3,d1
	beq.s	mn_ydone
	bgt.s	mn_ygt
mn_ylt
    	addq.w	#6,d6
		add.w	NA_SPEED(a0),d1
		cmp.w	d3,d1
		ble.s	mn_ydone
        	move.w	d3,d1
			bra.s	mn_ydone
mn_ygt
		subq.w	#6,d6
		sub.w	NA_SPEED(a0),d1
		cmp.w	d3,d1
		bge.s	mn_ydone
			move.w	d3,d1
mn_ydone
	movem.w	d0/d1,NA_XY(a0)
	move.w  dir_table(pc,d6.w),d0
	bne.s	mn_moved
		move.w	NA_FRAME(a0),d0
		and.w	#%11111000,d0
mn_moved
	move.w	NA_COUNT(a0),d1
    sub.w	#1,d1
    and.w	#%11,d1
	add.b	anim_table(pc,d1.w),d0
	move.w	d0,NA_FRAME(a0)
	subq.w	#1,NA_COUNT(a0)				finished this go?
	bge		mn_done						no
		move.w	#NA_THINK,NA_MODE(a0)	yes, we better re-sample the players position
		bra	mn_done
	dc.w	HOLE_NW,HOLE_N,HOLE_NE
	dc.w	HOLE_W
dir_table	dc.w		 0,HOLE_E
	dc.w	HOLE_SW,HOLE_S,HOLE_SE
anim_table	dc.b	0,1,2,3,3,2,1,0
*****************************************************************************
mn_die
	move.w	#HOLE_DN_ST,NA_FRAME(a0)    frame = first death frame
	move.w	#DEATH_DELAY,NA_COUNT(a0)	set animation delay
	move.w	#NA_DYING,NA_MODE(a0)		set to dying animation
    bra		mn_done
*****************************************************************************
mn_dying
    subq.w	#1,NA_COUNT(a0)
	bne		mn_done
		move.w	NA_FRAME(a0),d0			get the frame
		subq.w	#1,d0					move back a frame
		cmp.w	#HOLE_DN_END,d0
		blt.s	mn_dead
			move.w	d0,NA_FRAME(a0)
			move.w	#DEATH_DELAY,NA_COUNT(a0)
			bra		mn_done
mn_dead
		clr.w	NA_MODE(a0)
		subq.w	#1,active_holes
*****************************************************************************
mn_done
		lea		NA_SIZE(a0),a0			move to next baddie
		cmpa.l	a0,a1					have we got to the end
		bne		mn_loop
	rts
*****************************************************************************
_draw_shads
	lea		_shots,a5						the shot structures
	lea		_shots+MAX_SHOTS*SH_SIZE,a6		the end of the shot structures
ds_loop
		tst.w	SH_MODE(a5)					is this shot on ?
		beq		ds_next						no, move to the next one
		movem.w	SH_XY(a5),d0/d1		        get sprites x and y coords
        asr.w	#2,d0						scale-
        asr.w	#3,d1						em
		subq.w	#8,d0
		sub.w	#7,d1                       move to top of shadow
		movem.w	d0/d1,-(sp)
		lea		_spr_16+160*4,a1
		move.l	_w_screen,a0
		moveq	#7,d2						height of a shadow
		bsr		_s16_draw
		bne.s	shot_not_killed
			clr.w	SH_MODE(a5)				kill the shot if it was off screen
shot_not_killed
		movem.w	(sp)+,d0/d1
ds_next
    lea		SH_SIZE(a5),a5
	cmpa.l	a5,a6
	bne.s	ds_loop
	rts
*****************************************************************************
_draw_shots
	lea		_shots,a5						the shot structures
	lea		_shots+MAX_SHOTS*SH_SIZE,a6		the end of the shot structures
dsh_loop
		tst.w	SH_MODE(a5)					is this shot on ?
		beq		dsh_next					no, move to the next one
		movem.w	SH_XYZ(a5),d0/d1/d2         get sprites x,y and z coords
        asr.w	#2,d0						scale-
        asr.w	#3,d1						em;
		subq.w	#8,d0
		sub.w	#16,d1                       move to top of shadow
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
dsh_next
    lea		SH_SIZE(a5),a5
	cmpa.l	a5,a6
	bne.s	dsh_loop
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
	move.w	#0,player_frame
	move.w	#160*4,player_x
	move.w	#100*4,player_y
    move.w	#1,player_mode
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
*
	move.w	d1,d7
	add.w	d7,d7								*2
	add.w	d1,d7								*3
	add.w   d0,d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	d6,d0								for frame calculation
	movem.w anim_lookup(pc,d7.w),d6/d7
	tst.w	d6
	beq.s	no_joy_move
		add.w	d0,d6							animate
		andi.w	#%111,d6
		or.w	d7,d6
		bra.s	joy_move_done
*************************************
	dc.w	1,1*8,1,2*8,1,3*8		*
	dc.w	1,0*8					*
anim_lookup	dc.w	  0,0,-1,0*8
	dc.w	-1,3*8,-1,2*8,-1,1*8

no_joy_move
	move.w	d0,d6								put frameback as it was!
joy_move_done
*
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
	adda.l	d2,a1
	moveq	#32,d2
	bsr		_s32_draw
	rts
*****************************************************************************
draw_char 	macro ; a3->character a1-> screen

			movem.l	(a3)+,d0-d7			pick up 8 lines and 4 planes of character
			movep.l	d0,SCREEN_WIDTH*0(a5)
			movep.l	d1,SCREEN_WIDTH*1(a5)
			movep.l	d2,SCREEN_WIDTH*2(a5)
			movep.l	d3,SCREEN_WIDTH*3(a5)
			movep.l	d4,SCREEN_WIDTH*4(a5)
			movep.l	d5,SCREEN_WIDTH*5(a5)
			movep.l	d6,SCREEN_WIDTH*6(a5)
			movep.l	d7,SCREEN_WIDTH*7(a5)
			endm
*****************************************************************************
; a0->string, a1-> screen, d0=x, d1=y
_draw_string
	lea		_font-32*'0',a4		characters from 0 to '0' will not be used
	move.w	d1,d2				*1
	add.w	d1,d1				*2
	add.w	d1,d1				*4
	add.w	d2,d1				*5
	lsl.w	#8,d1				*5*256=8*160			y offset calculated
	bclr	#0,d0				odd or even start?
	beq.s   even_start
    lsl.w	#2,d0				odd start
	add.w	d0,d1
	lea		1(a1,d1.w),a5
	bra		_ds_odd
even_start
	lsl.w	#2,d0				x offset
	add.w	d0,d1				add to y
	lea		0(a1,d1.w),a5		add to screen, and drop into even start
_ds_even
	moveq	#0,d0
	move.b  (a0)+,d0
	beq		string_done
	lsl.w	#5,d0				*32
	lea		0(a4,d0.w),a3		a3-> correct character
	draw_char
	addq.l	#1,a5				increment to odd
_ds_odd
	moveq	#0,d0
	move.b  (a0)+,d0
	beq		string_done
	lsl.w	#5,d0				*32
	lea		0(a4,d0.w),a3		a3-> correct character
	draw_char
	addq.l	#7,a5				increment to even
	bra		_ds_even
string_done
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
	moveq	#0,d0
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
	moveq	#0,d0
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
	moveq	#1,d0
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
	moveq	#1,d0
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
	moveq	#1,d0
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
	moveq	#1,d0
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
	moveq	#1,d0
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
	moveq	#1,d0
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
_random
	move.w	seed,d0
	mulu	#9377,d0
	add.w	#9439,d0
	bclr	#15,d0
	move.w	d0,seed
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
 dc.l $FFFFFF00,$C001FFFE,$0700F9FF,$001CFFEF,$FFC7C038,$C000FFFF,$0380FCFF,$019FFFE7
 dc.l $F3070CF9,$0000FFFF,$03C0FCFF,$67FFFFF0,$000EFFF3,$0000FFFF,$01C7FE7F,$FFFEFC01
 dc.l $008FFFF3,$0020FFFF,$00FFFF3F,$FF80007F,$021FFDE7,$0080FF7F,$007FFF80,$CC0033FF
 dc.l $001CFFEF,$0000FFFF,$0073FF9C,$0000FFFF,$0038FFCF,$0000FFFF,$043CFFCF,$0000FFFF
 dc.l $007FFF9F,$8000FFFF,$103CEFCF,$0020FFFF,$007FFF81,$FC60FFFF,$001CFFE7,$0080FF7F
 dc.l $00EFFF30,$FFF807FF,$0007FFFB,$0000FFFF,$21C0FE7F,$6FFF901F,$D007FFFB,$0000FFFF
 dc.l $81C07EFF,$033FFCC0,$FF9B7FFD,$0000FFFF,$0384FCFF,$001CFFE7,$FFFF01FE,$C000FFFF
 dc.l $0710F9EF,$001CFFEF,$1BFFE400,$E700FFFF,$0700FBFF,$0038FFCF,$00F3FF0C,$FFC67FFF
 dc.l $C600FBFF,$0170FF9F,$0800FFFF,$FFFF007F,$FE40F7FF,$04F0FB3F,$2000DFFF,$61FFBE01
 dc.l $FFF807FF,$00E0FF3F,$0000FFFF,$70339FCC,$5FFFA01F,$CCC0FF7F,$0000FFFF,$7C008FFF
 dc.l $01FFFE00,$FFC07EFF,$0000FFFF,$3E00CFFF,$001CFFE3,$FFC000FF,$0010FFFF,$1E02E7FF
 dc.l $0000FFFF,$0F80F1FF,$8040FFBF,$0E08F3F7,$0000FFFF,$0602FBFD,$0000FFFF,$6600FBFF
 dc.l $0004FFFF,$0E00F3FF,$0003FFFF,$FF00FDFF,$0010FFEF,$0E00F7FF,$039FFFFF,$FFC080FF
 dc.l $0000FFFF,$1C00EFFF,$1FFFFFE0,$E3C01CFF,$2000FFFF,$380DCFFF,$FFF3F80C,$01E0FE7F
 dc.l $80007FFF,$79FF9FFE,$FCC0073F,$00E0FF3F,$0000FFFF,$7FFEBF81,$7E0087FF,$20E0FF3F
 dc.l $003CFFFF,$FFF0000F,$0F00F3FF,$80787F9F,$3CFFFFFF,$CE0071FF,$4F00F3FF,$0038FFCF

*****************************************************************************
_game_over
	bsr		_wait_vbi
	move.l	_d_screen,a1
	lea		_go_box,a0
	bsr		_random
	ext.l	d0
	divu	#25-4,d0
	swap	d0
	move.w	d0,d1
	bsr		_random
	ext.l	d0
	divu	#40-5,d0
	swap	d0
	bsr		_do_box
	sf		_vbi_done
	tst.b	fire
	bne.s	next_game
gojr_loop
		btst.b	#1,(KB_CONTROL).w			is keyboard ready for command
		beq.s   gojr_loop                   no, loop
		move.b	#$16,(KB_DATA).w            request a joystick packet

	cmp.b	#KB_SPACE,(KB_DATA).w		is space bar pressed ?
	bne		_game_over
	moveq	#0,d0                       no next game
	rts
next_game
	moveq	#1,d0
	rts
*****************************************************************************
_do_box
	tst.b	(a0)
	bne.s	do_draw_this_line
		rts
do_draw_this_line
	movem.w	d0/d1,-(sp)
	bsr		_draw_string
	movem.w	(sp)+,d0/d1
	addq.w	#1,d1
	bra.s	_do_box

*****************************************************************************
; d0.w -> a0
_bin2dec
	movem.l  d0/d1/d2/a1,-(sp)
	lea		bdsubs(pc),a1
bddloop
	move.w	(a1)+,d1				subber
	bne.s	bdok
		subq.l	#5,a0
		moveq	#4-1,d1
bddzloop
		cmpi.b	#'0',(a0)
		bne.s	bdnz
			move.b	#'@',(a0)+
			dbra	d1,bddzloop
bdnz
		movem.l  (sp)+,d0/d1/d2/a1
		rts
bdok
	moveq	#'0'-1,d2				char
bdcloop
		addq.b	#1,d2
		sub.w	d1,d0
		bpl.s	bdcloop
	add.w	d1,d0
	move.b  d2,(a0)+
	bra.s	bddloop

bdsubs
		dc.w	10000
		dc.w	1000
		dc.w	100
		dc.w	10
		dc.w	1
		dc.w	0
*****************************************************************************
fnf_msg		dc.b    7,'FILE NOT FOUND',10,13,7,0
spr16_fname	dc.b	'sprite16.dat',0
spr32_fname	dc.b	'sprite32.dat',0
font_fname	dc.b	'font.dat',0
_score_string	dc.b	'SCORE:'
_score_digits	dc.b	'.....',0					26
_go_box		dc.b	';<<<<=',0
			dc.b	'>GAME?',0
			dc.b	'>OVER?',0
			dc.b	'[\\\\]',0,0
	even
palette		dc.w	$000,$030,$341,$442,$222,$300,$421,$600
			dc.w	$633,$545,$206,$033,$333,$244,$066,$666
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

player_mode		ds.w	1
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
active_holes	ds.w	1					number of active holes
score			ds.w	1					yer score
seed			ds.w	1					random number seed
vnum_nastys		ds.w	1					number of nastys
vnasty_speed	ds.w	1					speed of em
vquick_delay	ds.w	1					how quick they get clever
old_pal			ds.w	16					the old palette
w_screen		ds.b	32000+256			screen has to be on a 256 byte boundry
_spr_32			ds.b	640*72				for 72 32*32 sprites
_spr_16			ds.b	5*160
_shots			ds.b	MAX_SHOTS*SH_SIZE	the shot structures
_nastys			ds.b	NO_NASTYS*NA_SIZE	the nasty structures
_font			ds.b	1472
*
