*****************************************************************
*								*
*		Wolfenstein 3D (v1.0 Freeware)			*
*		   16/32 Bit Atari version			*
*								*
*****************************************************************
* - Sourceport and optimization by ray//.tSCc. 2001-2005	*
* - Sfx/Gfx by Ninjaforce 1999					*
* - Macintosh sourcecode by Bill Heineman 2000			*
* - Level/Map data by Logicware(tm) 1994			*
*****************************************************************
* http://ray.tscc.de	  					*
* ray@tscc.de							*
*****************************************************************
* http://www.ninjaforce.com					*
*****************************************************************

		output	.prg
		opt	p=68000,ow-,o+

*debug
	ifd	debug
		opt	x+,d+
	else
		opt	x-,d-
	endc
		comment HEAD=%011	; fasload+fastram enabled

		section	text
		bra.w	_start

SCREENX		=	160	; Offscreen buffer resolution
SCREENY		=	SCREENX/2
FOV		=	70	; Field of vision in degrees

PHYSX		=	320	; Physical screen resolution
PHYSY		=	200

		
		
***********************************
*
*  d0.w w_rnd()
*
* Return a seeded random number
*	
***********************************

w_rnd		move.w	.rndindex(pc),d0
		addq.b	#1,.rndindex+1
		move.b	.rndtable(pc,d0.w),d0
		rts

.rndindex	dc.w	0

.rndtable	dc.b	0,8,109,220,222,241,149,107,75,248,254,140,16,66
		dc.b	74,21,211,47,80,242,154,27,205,128,161,89,77,36
		dc.b	95,110,85,48,212,140,211,249,22,79,200,50,28,188
		dc.b	52,140,202,120,68,145,62,70,184,190,91,197,152,224
		dc.b	149,104,25,178,252,182,202,182,141,197,4,81,181,242
		dc.b	145,42,39,227,156,198,225,193,219,93,122,175,249,0
		dc.b	175,143,70,239,46,246,163,53,163,109,168,135,2,235
		dc.b	25,92,20,145,138,77,69,166,78,176,173,212,166,113
		dc.b	94,161,41,50,239,49,111,164,70,60,2,37,171,75
		dc.b	136,156,11,56,42,146,138,229,73,146,77,61,98,196
		dc.b	135,106,63,197,195,86,96,203,113,101,170,247,181,113
		dc.b	80,250,108,7,255,237,129,226,79,107,112,166,103,241
		dc.b	24,223,239,120,198,58,60,82,128,3,184,66,143,224
		dc.b	145,224,81,206,163,45,63,90,168,114,59,33,159,95
		dc.b	28,139,123,98,125,196,15,70,194,253,54,14,109,226
		dc.b	71,17,161,93,186,87,244,138,20,52,123,251,26,36
		dc.b	17,46,52,231,232,76,31,221,84,37,216,165,212,106
		dc.b	197,242,98,43,39,175,254,145,190,84,118,222,187,136
		dc.b	120,163,236,249

		*temporary*
useheld		dc.b	0
d_held		dc.b	0
		
		
;-------------- includes ------------------------------------

		include 'inc\__isr.s'	; interrupt and mfp routs
	
		include	'inc\__atari.s'	; System library
		include	'inc\Ray.s'	; Sound and Video subsystem
		include	'inc\Sounds.s'
		include	'inc\WolfIO.s'	; IO

		include 'inc\SetupS~1.s'; Compiled scalers
		include 'inc\Refresh.s'	; 3D Engine
		include	'inc\Doors.s'	; Door processing
		include	'inc\PushWall.s'; Push walls

		include	'inc\Sight.s'	; Sightning
		include	'inc\EnMove.s'	; Bad guys
		include	'inc\EnThink.s'
		include	'inc\StateDef.s'

		include 'inc\__misc.s'
		include	'inc\PlMove.s'	; Operate the player
			
		include	'inc\RefSpr~1.s'; Sprite handling
		include	'inc\Level.s'	; Level processing
	
;------------------------------------------------------------

		section	text
_start		
		InitAtari	; init system

		*temporary* 
		bsr.w	ShowTitle  ; show the title screen
				   ; while initialising some
				   ; stuff
		
		bsr.w	ShowPanel  ; show the staus before
				   ; entering the gameloop
		
		move.w	sr,-(sp)
		move.w	#$2700,sr
		
		move.l	#IO_CheckInput,$118.w
		move.l	#TicCountISR,$110.w

		ori.b	#%01010000,$fffffa09.w ; Restore old mfp setting
		ori.b	#%01010000,$fffffa15.w

		move.w	(sp)+,sr

		bsr.w	SoundInit
		***********


PlayLoop	bsr.w	ControlMovement	; Read the controller

		*temporary*********
		tst.b	IO_ButtonState+bt_use	; Pressed use? 
		bne.s	_open
		
		clr.b	useheld	; Only once...
		bra.w	_skip
		
_open		tas.b	useheld
		bne.w	_skip

		movem.w	player.x(pc),d0/d1	; Get the x,y in tiles
		lsr.w	#FRACBITS,d0
		lsr.w	#FRACBITS,d1
		
		move.w	gamestate.viewangle,d2	; Force into a cardinal direction
		addi.w	#ANGLES/8,d2
		rol.w	#2,d2
		andi.b	#%11,d2
		
		bne.s	_not_east
		
		addq.w	#1,d0		; East
		moveq.l	#CD_EAST,d2
		bra.s	_break

_not_east	cmpi.b	#1,d2
		bne.s	_not_north
		
		addq.w	#1,d1		; North
		moveq.l	#CD_NORTH,d2
		bra.s	_break
		
_not_north	cmpi.b	#2,d2
		bne.s	_not_west
		
		subq.w	#1,d0		; West
		moveq.l	#CD_WEST,d2
		bra.s	_break
			
_not_west	cmpi.b	#3,d2
		bne.s	_break
		
		subq.w	#1,d1		; South
		moveq.l	#CD_SOUTH,d2

_break
		lea.l	Tilemap,a0	; Get the tile data
		lsl.w	#6,d0
		add.b	d1,d0
		move.b	(a0,d0.w),d3
		
		bclr.l	#TI_DOOR,d3	; Is it a door? 
		beq.w	_no_door
		
		ext.w	d3		; Door # to operate
		lsl.w	#3,d3

		OperateDoor d3
		bra.w	_skip
		
_no_door	lea.l	Actorat,a0	; Push wall?
		btst.b	#TI_PUSHWALL,(a0,d0.w) ; Note: Only 1 pushwall at a time!
		beq.w	_skip
		tst.b	PushWallRec+pwallcount
		bne.w	_skip
		
		PushWall d0,d2
		
_skip		
		*******************
		
		bsr.w	MoveDoors	; Open and close doors
		bsr.w	MovePWalls	; Move all push walls
		bsr.w	MoveActors	; Operate all the bad guys
		bsr.w	RenderView	; Draw the 3D view

		*******************

		; Handle window resize/detail toggle

		move.l	#32<<16|16,d2	; Resize delta dX|dY
		tst.b	detail		; Adapt to level of detail vertically
		beq.s	.keepdY
		add.w	d2,d2		; dY *= 2

.keepdY		tst.b	IO_ButtonState+$66	; *?
		beq.s	.keepdetail
		tas.b	d_held		; Toggle detail only once
		bne.s	.dont_dec

		not.b	detail

		move.w	ysize(pc),d0

		tst.b	detail		; Adapt ysize on detail toggle
		beq.s	.lowtoggle
		
		add.w	d0,d0		; High detail toggle
		bra.s	.def

.lowtoggle	lsr.w	d0
.def		move.w	d0,ysize

		bra.s	.dtoggle


.keepdetail	clr.b	d_held
		tst.b	IO_ButtonState+$4e	; +?
		beq.s	.dont_inc
		
		move.l	xsize(pc),d0		
		add.l	d2,d0
		move.w	#MAXY,d1

		tst.b	detail		; Check detail level
		beq.s	.low
		add.w	d1,d1

.low		cmp.w	d1,d0		; Keeps range?
		ble.s	.resize

.dont_inc	tst.b	IO_ButtonState+$4a	; -?
		beq.s	.dont_dec
	
		move.l	xsize(pc),d0
		
		move.l	d0,d1		; Keeps range?
		swap.w	d1
		cmpi.w	#MAXX-3*32,d1
		ble.s	.dont_dec

		sub.l	d2,d0

.resize		move.l	d0,xsize	; Resize
		
.dtoggle	lea.l	panel,a0
		bsr.w	ShowPic

		bsr.w	IO_SetUpDisplay
		bsr.w	SetupScalers
		

.dont_dec	*******************

		tst.b	IO_ButtonState+bt_quit
		beq.w	PlayLoop


	
		bsr.w	FadeToBlack

_restore	RestoreAtari	; restore and exit


		section bss
save		ds.l	64*65 *****
		end