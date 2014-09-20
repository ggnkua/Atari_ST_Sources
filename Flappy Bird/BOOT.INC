
;Flappybird for the Atari ST

ENABLECPUTIME = 0							;Set to 1 to enable CPU timing bars
ENABLEMEMLOG = 0							;Set to 1 to output memory stats to log
ENABLEDEBUGQUIT = 0							;Set to 1 to enable debug quit key

	SECTION	TEXT

start
	move.l	sp,a5							;Store stack
	move.l	4(a5),a5						;Base page as a5
	move.l	$c(a5),d0						;Text segment length in d0
	add.l	$14(a5),d0						;Add length of data segment
	add.l	$1c(a5),d0						;And add length of bss segment
	add.l	#$1000,d0						;Add space needed for stack
	move.l	d0,d1
	add.l	a5,d1
	and.l	#-2,d1							;Ensure stack address is even
	move.l	d1,sp							;Set new stack
	move.l	d0,-(sp)						;Size of reserved area
	move.l	a5,-(sp)						;From base page
	clr.w	-(sp)
	move.w	#$4a,-(sp)						;Mshrink
	trap	#1
	add.l	#12,sp

	;Do as much processing as possible before change screen resolution for a clean boot sequence
	move.l	#0,a0							;Enter supervisor mode
	bsr		utilsupermode
	bsr		utilinit						;Initialise utility functions and read machine type
	bsr		loginit							;Create log file
	IFGT ENABLEMEMLOG	
	bsr		utilavailablemem				;Write size of free memory to log
	bsr		loglong
	ENDC
	bsr		utilstorestate					;Store all vectors
	move.l	#gemdoserrorhandler,$404.w		;Redirect GEMDOS error handler for silent file errors	
	bsr		errorsetexceptions				;Set exception handler
	bsr		ikbdinit						;Set new IKBD handler
	bsr		soundinit						;Set sound interrupt
	bsr		rastersinit						;Initialise raster effects
	
	;Game boot
	moveq.l	#0,d0
	move.b	d0,pal50hz
	move.b	d0,ntsc60hz
	move.w	d0,count
	move.w	d0,exitcount
	move.w	d0,whiteoutcount
	move.w	d0,flapbutton
	move.l	d0,handler

	bsr		datauncompress					;Uncompress LZ77 data
	bsr		preshiftinit					;Create preshifts
	bsr		skyinit							;Create sky preshifts
	bsr		birdinit						;Initialise game
	bsr		floorinit
	bsr		pipeinit
	bsr		gameinit
	bsr		tickerinit
	bsr		highscoreinit
	bsr		tickersethighscore
	bsr		titleinit
	bsr		medalinit
	bsr		titlereset						;Start on title screen

	;Now change resolution
	bsr		utilsetlowres
	lea		intvbl,a0						;Set new VBL vector
	bsr		utilsetvblvector
	bsr		utilwaitvbl						;Wait for next retrace
	bsr		utilblackpalette				;Black out palette
	bsr		utilfindscreen					;Find physical and off-screen addresses
	move.l	phybse,a0						;Clear both screens
	bsr		utilclearscreen
	move.l	logbse,a0
	bsr		utilclearscreen

	;Game start
	bsr		gamebuildscreen					;Draw game screen to both swap buffers
	move.l	#skyhandler,timerbhandler
	move.l	#titlehandler,handler

.loop
	IFGT ENABLECPUTIME
	move.w	#$700,$ffff8240.w
	ENDC
	move.l	handler,a0						;Run game handler
	jsr		(a0)
	bsr		floordraw
	bsr		tickerupdate
	bsr		tickerdraw
	addq.w	#1,exitcount
	IFGT ENABLECPUTIME
	move.w	#$000,$ffff8240.w
	ENDC

	bsr		ikbdupdate						;Read input
	move.w	debouncejoys,d0					;Check joysticks and extended joysticks
	or.w	debounceextjoys,d0
	and.w	#JOYSTICK0FIRE+JOYSTICK1FIRE,d0
	move.w	d0,flapbutton
	lea		debouncekeys,a0					;Fast check for multiple keypress bytes
	move.b	3(a0),d0
	and.b	#$10,d0							;Check Return(bit 28)
	bne.s	.setinput
	move.l	4(a0),d0
	and.l	#$00044002,d0					;Check Left Shift(bit 42), Right Shift(bit 54), Space(bit 57)
	bne.s	.setinput
	beq.s	.noinput
.setinput
	move.w	#1,flapbutton
.noinput

	move.b	#$02,d0							;'1' pressed for 60Hz?
	bsr		ikbdtestdebouncekey
	beq.s	.nontsc60hz
	move.b	#1,ntsc60hz
.nontsc60hz
	move.b	#$0b,d0							;'0' pressed for 50Hz?
	bsr		ikbdtestdebouncekey
	beq.s	.nopal50hz
	move.b	#1,pal50hz
.nopal50hz
	
	IFGT ENABLEDEBUGQUIT
	move.b	#$01,d0							;Pressed 'ESC' to quit?
	bsr		ikbdtestdebouncekey
	bne.s	.done
	ENDC

	cmp.w	#MACHINE_FALCON,machine			;If running on a Falcon sync to VBL
	beq.s	.syncvbl
	bsr		utilwaitdisplayblank			;Wait for Display Blanking on ST/STe
	bra.s	.sync
.syncvbl
	bsr		utilwaitvbl						;Wait for VBL on Falcon
.sync
	move.w	whiteoutcount,d0				;Check if need to white-out screen
	beq.s	.nowhiteout
	subq.w	#1,d0
	move.w	d0,whiteoutcount
	move.l	whiteoutbse,d0
	bsr		utilswapscreend0
	bra.w	.loop
.nowhiteout
	bsr		utilswapscreen					;Swap screens
	bra.w	.loop

.done	
	;Cleanup on exit
	bsr		logcleanup
	bsr		ikbdcleanup
	bsr		utilrestorestate
	bsr		soundstopall
	move.l	oldsuper,a0
	bsr		utilsupermode

	move.w	#0,-(sp)						;Return code (ie program completed without error)
	move.w	#$4c,-(sp)						;Pterm (releases all memory and closes files)
	trap	#1
	addq.w	#4,sp

;----------------------------------
;Empty GEMDOS critical error handler to avoid GEM dialogs appearing (ie disc write-protect)
gemdoserrorhandler
	rts

;----------------------------------
;New VBL interrupt routine
intvbl
	movem.l	d0/a0-a1,-(sp)
	
	addq.l	#1,vblcount						;Increment VBL counter	
	move.w	nextrasterset,rasterset			;Set raster set

	move.l	timerbhandler,d0				;Do we have a Timer B handler?
	beq.s	.notimerb
	move.l	d0,a0
	jsr		(a0)							;Set Timer B
.notimerb
	
	move.l	nextscreen,d0					;Do we have a new screen address to set?
	beq.s	.noscreen
	lea		$ffff8201.w,a0					;Video Base Address
	lsr.l	#8,d0							;Get screen address High+Mid
	movep.w	d0,(a0)							;Write High+Mid value
	move.l	#0,nextscreen					;Clear as done
.noscreen

	move.l	nextpalette,d0					;Do we have a new palette? Stored as 16 STfm colours and 16 STe colours
	beq.s	.nopalette
	move.l	d0,a0
	move.w	machine,d0
	btst	#0,d0							;Test bottom bit of machine which is set for STe/Falcon
	beq.s	.standardpal
	lea		16*2(a0),a0						;Select enhanced palette for STe/Falcon
.standardpal
	lea		$ffff8240.w,a1
	move.l	(a0)+,(a1)+						;Copy all 16 palette RGB values
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)
	move.l	#0,nextpalette					;Clear as done
.nopalette

	moveq.w	#0,d0
	cmp.b	pal50hz,d0						;Check for 50Hz/60Hz
	beq.s	.nopal50hz
	move.b	d0,pal50hz
	bsr		utilset50hz
	bsr		gamesetbirdvelocity				;Update velocities for refresh rate
	bra.s	.nontsc60hz
.nopal50hz
	cmp.b	ntsc60hz,d0
	beq.s	.nontsc60hz
	move.b	d0,ntsc60hz
	bsr		utilset60hz
	bsr		gamesetbirdvelocity
.nontsc60hz

	movem.l	(sp)+,d0/a0-a1
	rte

;----------------------------------

	SECTION	BSS

pal50hz				ds.b	1				;Set to 1 to set Hz on next VBL
ntsc60hz			ds.b	1
count				ds.w	1				;Generic counter
exitcount			ds.w	1				;Frame counter used to clean up from previous screen
whiteoutcount		ds.w	1				;White-out screen timer if !=0
flapbutton			ds.w	1				;!=0 if pressed key/fire button to flap
handler				ds.l	1				;Game handler (called each frame)
	EVEN
