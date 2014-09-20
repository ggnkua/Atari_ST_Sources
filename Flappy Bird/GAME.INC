
;Game handling

ENABLEDEBUGJOY = 0							;Set to 1 to enable debug joystick control
GRAVITY_50HZ = $3a00						;Velocity for gravity as 16:16 fixed-point
BIRDFLAPVELY_50HZ = $38000					;Velocity for a 'flap' as fixed-point
GRAVITY_60HZ = $3100						;And 60Hz versions (otherwise 60Hz is too difficult)
BIRDFLAPVELY_60HZ = $31000

	SECTION	TEXT

;----------------------------------
;Initialise 'Game' screen
gameinit
	moveq.l	#0,d0
	move.l	d0,bcdscore
	move.l	d0,bcdhighscore
	move.w	d0,gameholdtimer
	move.l	#whiteoutscreen+255,d0
	move.b	#0,d0
	move.l	d0,whiteoutbse					;Get address of white-out screen aligned to 256 bytes
	bsr		gamecleargamewhiteout
	bsr		gameresetscore
	bra		gamesetbirdvelocity				;(does RTS)

;----------------------------------
;Reset for 'Game' screen
gamereset
	move.l	#BIRDANIMCLAMPVEL,birdframeclamp
	move.w	#0,exitcount
	bra		pipereset						;(does RTS)

;----------------------------------
;'Game' screen handlers
gamehandler
	move.w	#RASTERSET_GAME,nextrasterset
	
	cmp.w	#2,exitcount					;Repair last screen on both swap buffers
	bgt.s	.norepair
	bsr		getreadyrepaironexit
.norepair

	bsr		gamescoreclear
	bsr		birdclear	
	bsr		pipedrawall
	bsr		birdanim
	bsr		birddraw
	bsr		gamescoredraw
	bra		gameupdate						;(does RTS)

gamedeadhandler
	bsr		gamescoreclear
	bsr		birdclear
	bsr		pipedrawall
	bsr		birddraw
	
	subq.w	#1,gameholdtimer				;Hold, drawing to both swap buffers before bring up medals
	bne.s	.notimer
	bsr		medalreset
	move.l	#medalhandler,handler
.notimer
	rts

;----------------------------------
;Update bird, check collisions and handle death
gameupdate
	move.w	birdhit,d0						;Have we hit a pipe or the floor?
	bne.w	.wearedead						;Yes
	bsr		pipeupdate						;No
	bsr		floorupdate
	bsr		pipecheckcollision				;Check for collision, return !=0 if detect hit
	beq.s	.nocollision
	move.w	#5,whiteoutcount				;White-out screen
	move.l	#0,birdvely
	cmp.w	#2,d0							;Check return from collision to see if we hit floor
	beq.s	.hitfloor						;If we did skip fall sound
	lea		fallsfx,a0
	bsr		soundplay1
.hitfloor
	lea		hitsfx,a0
	bsr		soundplay0
	rts
.nocollision

	IFGT ENABLEDEBUGJOY
	bsr		gamedebugjoystick				;Debug check to move bird up/down on joystick
	ENDC

	IFEQ ENABLEDEBUGJOY	
	move.w	flapbutton,d0					;Read input
	beq.s	.noinput
	lea		flapsfx,a0
	bsr		soundplay0
	move.l	birdflapvely,birdvely			;Flap
	move.l	#BIRDANIMFLAPVEL,birdframevel
	bsr		utilrandomise
.noinput

	move.l	birdgravity,d0					;Add gravity and velocity
	sub.l	d0,birdvely
	move.l	birdy,d0						;Do this last so player can see change before test collision
	sub.l	birdvely,d0
	move.l	#(160-13)<<16,d1				;Floor as fixed-point
	cmp.l	d1,d0							;Clamp to floor
	ble.s	.clampfloor
	move.l	d1,d0
.clampfloor
	move.l	d0,birdy
	ENDC
	rts

.wearedead
	move.l	birdgravity,d0					;Add gravity and velocity
	sub.l	d0,birdvely
	move.l	birdy,d0
	sub.l	birdvely,d0
	move.l	#(160-13)<<16,d1
	cmp.l	d1,d0							;Wait until bird falls to floor
	ble.s	.stillfalling
	move.l	d1,d0							;Put bird on floor
	move.w	#2,gameholdtimer				;Hold for 2 frames
	move.l	#gamedeadhandler,handler		;Show medal screen
.stillfalling
	move.l	d0,birdy
	rts

;----------------------------------
;Debug input to move bird with up/down on joystick
gamedebugjoystick
	IFGT ENABLEDEBUGJOY
	move.w	statejoys,d0
	and.w	#JOYSTICK1UP,d0
	beq.s	.noup
	subq.w	#1,birdy
.noup
	move.w	statejoys,d0
	and.w	#JOYSTICK1DOWN,d0
	beq.s	.nodown
	addq.w	#1,birdy
.nodown
	ENDC
	rts

;----------------------------------
;Clear white-out screen to show on death as cannot change palette as we use colour 0 in the game
gamecleargamewhiteout
	move.l	whiteoutbse,a0					;Start at end of screen
	lea		32000(a0),a0
	move.l	#$0000ffff,d0					;Set d1-d7/a1-a5 for colour index 2
	moveq.l	#0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	move.l	d1,a1
	move.l	d0,a2
	move.l	d1,a3
	move.l	d0,a4
	move.l	d1,a5
	moveq.w	#74-1,d7						;Loop for 31968 bytes
.loop
	movem.l d0-d6/a1-a5,-(a0)				;Clear 432 bytes
	movem.l d0-d6/a1-a5,-(a0)
	movem.l d0-d6/a1-a5,-(a0)
	movem.l d0-d6/a1-a5,-(a0)
	movem.l d0-d6/a1-a5,-(a0)
	movem.l d0-d6/a1-a5,-(a0)
	movem.l d0-d6/a1-a5,-(a0)
	movem.l d0-d6/a1-a5,-(a0)
	movem.l d0-d6/a1-a5,-(a0)
	dbra.w	d7,.loop
	movem.l d0-d6/a1,-(a0)					;Clear remaining 32 bytes
	rts

;----------------------------------
;Clear lines with solid colour, pass number of lines to clear, plane1+2 and plane3+4
GAMECLEARLINES	MACRO
	move.w	#\1*10-1,d7
.loop\@
	move.l	\2,(a1)+						;Clear 32 pixels
	move.l	\3,(a1)+
	move.l	\2,(a1)+
	move.l	\3,(a1)+
	dbra.w	d7,.loop\@
	ENDM

;----------------------------------
;Draw entire game screen
gameredrawscreen
	move.l	offscreenbse,a1
	moveq.l	#0,d0							;Plane colour fills
	move.l	#$ffff0000,d1
	move.l	#$ffffffff,d2
	move.l	#$0000ffff,d3
	
	GAMECLEARLINES	112,d1,d0				;Fill sky, index 1
	
	movem.l	d0-d3,-(sp)
	move.l	skyimg,a0
	lea		80*17(a0),a0					;Skip solid colour at top of sky
	moveq.w	#48-1,d7
.skyloop
	movem.l	(a0)+,d0-d6/a2-a6				;Repeat image across screen
	movem.l	d4-d6/a2-a6,(a1)
	movem.l	d0-d6/a2-a6,48(a1)
	movem.l	d0-d6/a2-a6,112(a1)
	movem.l	(a0)+,d0-d3
	movem.l	d0-d3,32(a1)
	movem.l	d0-d3,96(a1)
	lea		16(a0),a0
	lea		160(a1),a1
	dbra.w	d7,.skyloop
	movem.l	(sp)+,d0-d3

	GAMECLEARLINES	1,d0,d0					;Black, index 0
	GAMECLEARLINES	1,d2,d1					;Light beige, index 7
	GAMECLEARLINES	6,d0,d3					;Floor anim, index 8
	GAMECLEARLINES	1,d0,d1					;Dark green, index 4
	GAMECLEARLINES	1,d3,d3					;Dark beige, index 10
	GAMECLEARLINES	21,d2,d3				;Beige, index 11
	GAMECLEARLINES	9,d0,d0					;Black, index 0
	rts	

;----------------------------------
;Draw game screen to both swap buffers during initialisation
gamebuildscreen
	bsr		gameredrawscreen				;Fully redraw screen
	bsr		utilrandomise					;Good time to add to random
	bsr		utilswapscreen					;Swap screens
	bsr		utilwaitvbl						;Wait for retrace
	bra		gameredrawscreen				;Draw to both screens (does RTS)

;----------------------------------
;Reset player score
gameresetscore
	moveq.l	#0,d0
	move.l	d0,bcdscore						;Set 32-bit BCD
	move.l	d0,bcdhighscore
	rts

;----------------------------------
;Draw game score
gamescoredraw
	move.l	bcdscore,d1						;Read score in 32-bit BCD format
	bsr		scorelargelength				;Get length of score in pixels
	lsr.w	#1,d0
	neg.w	d0								;-(Length>>1)
	add.w	#160,d0							;Centre on X
	move.l	offscreenbse,a0
	lea		160*9(a0),a0					;Offset for Y
	bra		drawscorelarge					;(does RTS)

;----------------------------------
;Clear background behind game score
gamescoreclear						;2020 cycles, 4 rasters
	move.l	offscreenbse,a1			;20

	move.l	#$ffff0000,d0			;12		;Sky, index 1
	moveq.l	#0,d1					;4
	move.l	d0,d2					;4
	move.l	d1,d3					;4
	move.l	d0,d4					;4
	move.l	d1,d5					;4
	move.l	d0,d6					;4
	move.l	d1,d7					;4
	move.l	d0,a2					;4
	move.l	d1,a3					;4
	move.l	d0,a4					;4
	move.l	d1,a5					;4

	movem.l	d0-d7/a2-a5,160*9+56(a1)		;Clear 96 pixels by 18 lines, 1944 cycles	
	movem.l	d0-d7/a2-a5,160*10+56(a1)
	movem.l	d0-d7/a2-a5,160*11+56(a1)
	movem.l	d0-d7/a2-a5,160*12+56(a1)
	movem.l	d0-d7/a2-a5,160*13+56(a1)
	movem.l	d0-d7/a2-a5,160*14+56(a1)
	movem.l	d0-d7/a2-a5,160*15+56(a1)
	movem.l	d0-d7/a2-a5,160*16+56(a1)
	movem.l	d0-d7/a2-a5,160*17+56(a1)
	movem.l	d0-d7/a2-a5,160*18+56(a1)
	movem.l	d0-d7/a2-a5,160*19+56(a1)
	movem.l	d0-d7/a2-a5,160*20+56(a1)
	movem.l	d0-d7/a2-a5,160*21+56(a1)
	movem.l	d0-d7/a2-a5,160*22+56(a1)
	movem.l	d0-d7/a2-a5,160*23+56(a1)
	movem.l	d0-d7/a2-a5,160*24+56(a1)
	movem.l	d0-d7/a2-a5,160*25+56(a1)
	movem.l	d0-d7/a2-a5,160*26+56(a1)
	rts

;----------------------------------
;Increment score by 1, pass a0.l as pointer to BCD score
gamescoreinc						;100 cycles, 0.2 rasters
	addq.w	#4,a0					;8		;End of destination score
	lea		bcdone+4,a1				;12		;End of source '1' in BCD
	moveq.w	#0,d0					;4		;Clear X (faster than using CCR)
	neg.w	d0						;4
	abcd	-(a1),-(a0)				;18		;Add 4 BCD bytes, 8 digits
	abcd	-(a1),-(a0)				;18
	abcd	-(a1),-(a0)				;18
	abcd	-(a1),-(a0)				;18
	rts

;----------------------------------
;Set game velocities according to 50hz/60hz
gamesetbirdvelocity
	btst.b	#1,$ffff820a.w					;Bit 1 is 0 for 60Hz or 1 for 50Hz
	beq.s	.set60hz
.set50hz
	move.l	#BIRDFLAPVELY_50HZ,birdflapvely
	move.l	#GRAVITY_50HZ,birdgravity
	rts

.set60hz
	move.l	#BIRDFLAPVELY_60HZ,birdflapvely
	move.l	#GRAVITY_60HZ,birdgravity
	rts
	
;----------------------------------

	SECTION	DATA

bcdone		dc.l	$00000001				;'1' in 32-bit BCD format

;----------------------------------

	SECTION	BSS

bcdscore			ds.l	1				;32-bit BCD score (BCD on 68000 dc.l $12345678 is the same as dc.b $12,$34,$56,$78)
bcdhighscore		ds.l	1				;32-bit BCD high-score
gameholdtimer		ds.w	1				;Hold timer to draw same image to both swap buffers
whiteoutbse			ds.l	1				;White-out screen base address
whiteoutscreen		ds.b	32256			;320*200 32Kbyte white-out screen, with 256 bytes for alignment
