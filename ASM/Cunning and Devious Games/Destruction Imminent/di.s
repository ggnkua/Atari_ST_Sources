	****************************
	*   Destruction Imminent   *
	*By Cunning & Devious Games*
	*Programmed By Andrew Gower*
	* Copyright (c) 1995/1996  *
	****************************

	*Start of main loop

numlevel	equ	25		Number of levels

start	move.l	#mystack,a7	New stack address
	bsr	init		Initialise global routines
restart	bsr	init2		Initialise local routines
	clr.b	joy0		Reset joystick status
mainloop	bsr	calcscrn		Calculate screen
	bsr	drawscrn		Draw screen
	bsr	chckdoor		Check doors
	bsr	checkjoy		Check controls
	bsr	checkkeys		Check function keys
	bsr	monsters		Calculate monsters
	bsr	shootgun		Check weapons
	tst.w	health		Still alive?
	bgt	mainloop		Yes, loop back around
	bsr	gameover		Game over sequence
	move.l	#restart,-(sp)	Return address
	move.l	samples,-(sp)	Music sample data
	bsr	resetvars		Reset variables
end	bra	title2		Title screen sequence

	*End of main loop

	*Start of stfm compatability routines

stfm	move.w	#$888,$ffff825e.w	Is it an stfm?
	cmp.w	#$888,$ffff825e.w	Check palette register
	bne	stfmmode		Yes, only 512 colours so must be
	rts			Return

stfmmode	move.w	#$4e75,initdma	No DMA sound
	move.w	#$4e75,stopdma	No DMA sound
	move.w	#$4e75,initblit	No Blitter chip
	move.l	#stback,drawscrn+2	No Blitter chip
	move.l	#stflip,flipadr+2	No Blitter chip
	clr.l	output		No stereo sound
	move.l	#stfmpalt,a0	New palette
	move.l	#palette,a1	Old palette
	move.w	#7,d0		Set up a counter
col512	move.l	(a0)+,(a1)+	Switch to 512 colour mode
	dbf	d0,col512		Copy some more palette
	move.w	#1,stfm_on	Set stfm mode
	rts			Return

	*Start of gameover routines

replayopt	clr.w	d0		Side 0
	move.w	#4,d1		Track 4
	move.w	#4,d2		Sector 4
	move.l	#2580,d3		Size of file
	move.l	#12158,d4		Unpacked Size
	move.l	#24,d5		Depack delay
	move.l	map2,a0		Destination address
	bsr	packload		Load it in
	move.w	#64,d7		Size of input buffer
	bsr	ckloop		Clear keyboard buffer
	move.l	map2,a0		Address of program
	bsr	relorout		Relocate it

	move.w	score,-(sp)	Past total score to program
	move.w	beetleh,d0	Number of beetles killed
	add.w	roboth,d0		Add on number of robots killed
	add.w	rockmonh,d0	Add on number of rockmen killed
	add.w	mutanth,d0	Add on number of mutants killed
	add.w	gunposth,d0	Add on number of gunpost killed
	add.w	ghosth,d0		Add on number of ghosts killed
	add.w	bath,d0		Add on number of bats killed
	move.w	d0,-(sp)		Pass to program
	move.w	shothits,d0	Get number of hits
	mulu.w	#100,d0		Multiply by 100
	divu.w	shottotal,d0	Divide by total shot
	move.w	d0,-(sp)		Pass to program

	jsr	(a0)		Run it
	cmp.w	#"Y",d0		Replay?
	beq	replayyes		Yes, goto routine
	cmp.w	#"y",d0		Replay?
	beq	replayyes		Yes, goto routine
	bsr	bpalt		Set black palette
	bsr	newscore		Reset score
	move.b	#$0f,$ff8201	New screen address
	move.b	#$80,$ff8203	New screen address
	bra	replayor		Return

replayyes	bsr	bpalt		Set black palette
	bsr	newscore		Reset score
	move.b	#$0f,$ff8201	New screen address
	move.b	#$80,$ff8203	New screen address
	move.l	mempos,-(a7)	Store memory pointer
	move.w	#1,warmreset	Do warm reset of variables
	bsr	resetv2		Goto routine
	clr.w	warmreset		Restore to old reset mode
	move.l	objmap,mempos	Address of map data
	add.l	#2304,mempos	Set up memory pointer
	bsr	initcalc		Reset game map
	move.l	(a7)+,mempos	Restore memory pointer
	addq.l	#4,sp		Drop return address	
	bsr	initbord		Load and draw border
	bsr	setpalt		Set palette up for game
	move.w	#64,d7		Size of input buffer
	bsr	ckloop		Clear keyboard buffer
	bra	mainloop		Jump back into game

gameover	move.l	screen2,a0	Source address
	move.l	screen1,a1	Destination address
	move.w	#7999,d0		Set up a counter
gameoverl	move.l	(a0)+,(a1)+	Copy across screen
	dbf	d0,gameoverl	Ensure both screens identical
	move.w	#1,mesc		Set message draw flag
	move.w	#4,mesn		Message number
	move.w	won,d0		Get gameover status
	sub.w	d0,mesn		Get correct message
	bsr	drawmes		Draw message
	move.w	#15,d7		Set up a counter
gameover2	bsr	scrnswap		Reveal screen
	move.w	#7,d6		Set up a counter
gameover3	move.w	#37,-(sp)		Wait VBL
	trap	#14		Call XBIOS
	addq.l	#2,sp		Correct stack
	dbf	d6,gameover3	Keep waiting
	dbf	d7,gameover2	Swap screens
	bsr	bpalt		Set black palette
	tst.w	won		Have we won?
	beq	replayopt		No, go to replay option
replayor	move.l	memreset,mempos	Reset memory pointer
	sub.l	#200000,mempos	Request 200K
	move.l	mempos,a0		Destination address
	clr.w	d0		Side 0
	move.w	#23,d1		Track 23
	move.w	#8,d2		Sector 8
	move.l	#148833,d3	Size of file
	move.l	#197882,d4	Unpacked size
	move.w	#24,d5		Depack delay
	move.l	a0,samples	Store address
	bsr	packload		Load it in
	move.w	#64,d7		Size of input buffer
	bsr	ckloop		Clear keyboard buffer
	tst.w	won		Have we won or lost the level?
	bne	wonlevel		We've won, goto routine

lostlevel	sub.l	#35000,mempos	Request 35000 bytes
	move.l	mempos,a0		Destination address
	clr.w	d0		Side 0
	move.w	#12,d1		Track 12
	move.w	#8,d2		Sector 8
	move.l	#12388,d3		Size of file
	move.l	#34138,d4		Unpacked size
	move.w	#24,d5		Depack dealy
	move.l	a0,music		Address of music
	move.l	a0,backpic	Address of back picture
	add.l	#2068,backpic	Find correct address
	bsr	packload		Load it in
	bsr	loadquart		Load in quartet music
	bsr	showbpic		Show background picture
	bsr	playquart		Play quartet music
	clr.b	joy0		Reset joystick status
firecheck	move.w	#$ff,-(sp)	Check keyboard
	move.w	#6,-(sp)		Function number
	trap	#1		Call GEMDOS
	addq.l	#4,sp		Correct stack
	tst.w	d0		Pressed key?
	bne	gokey		Yes, exit loop
	btst	#7,joy0		Pressed fire?
	beq	firecheck		No, keep waiting
gokey	bsr	stopquart		Stop quartet music
	bsr	bpalt		Set black palette
	add.l	#46000,mempos	Return memory
	rts			Return

wonlevel	cmp.w	#numlevel,level	Completed game?
	beq	wongame		Yes, Yes, Yes!
	move.l	samples,-(a7)	Address of music samples
	sub.l	#54000,mempos	Request 54000 bytes
	move.l	mempos,a0		Destination address
	clr.w	d0		Side 0
	move.w	#1,d1		Track 1
	move.w	#1,d2		Sector 1
	move.l	#7349,d3		Size of file
	move.l	#53194,d4		Unpacked size
	move.w	#24,d5		Depack delay
	move.l	a0,-(sp)		Preserve address
	bsr	packload		Load it in
	move.l	(sp)+,a0		Restore address
	move.l	a0,d2		Copy into d2
	add.l	#$1c,d2		Move to end of base page
	lea	$1c(a0),a1	Copy into a1
	move.l	a1,a2		Copy into a2
	add.l	2(a0),a2		Pointer to start of program
	add.l	(a2)+,a1		Store in a1
	add.l	d2,(a1)		Modify start address
wonloop2	tst.b	(a2)		All relocated yet?
	beq	endwon		Yes, return
	moveq.l	#0,d1		Clear d1
wonloop	moveq.l	#0,d0		Clear d0
	move.b	(a2)+,d0		Get address
	cmp.b	#1,d0		Convert it?
	bne	nowonloop		Yes, goto routine
	add.w	#$fe,d1		Move to next address
	bra	wonloop		Loop back around
nowonloop	add.w	d0,d1		Relocate address
	add.w	d1,a1		New address
	add.l	d2,(a1)		Store it
	bra	wonloop2		Convert next address
endwon	jsr	(a0)		Run it
	bsr	bpalt		Set black palette
	add.l	#54000,mempos	Return memory
	move.l	#levorder,a0	Order of levels to run in
	move.w	level,d0		Get current level number
findlev	cmp.w	(a0)+,d0		Find place in table
	bne	findlev		No, keep searching
	move.w	(a0),level	Move onto next level
	addq.l	#4,sp		Drop return address
	bsr	resetvars		Reset variables
	bra	restart		Run next level

wongame	move.l	samples,-(a7)	Address of music samples
	sub.l	#54000,mempos	Request 54000 bytes
	move.l	mempos,a0		Destination address
	move.w	#1,d0		Side 1
	move.w	#74,d1		Track 74
	move.w	#7,d2		Sector 7
	move.l	#11846,d3		Size of file
	move.l	#49657,d4		Unpacked size
	move.w	#24,d5		Depack delay
	move.l	a0,-(sp)		Preserve address
	bsr	packload		Load it in
	move.l	(sp)+,a0		Restore address
	move.l	a0,d2		Copy into d2
	add.l	#$1c,d2		Move to end of base page
	lea	$1c(a0),a1	Copy into a1
	move.l	a1,a2		Copy into a2
	add.l	2(a0),a2		Pointer to start of program
	add.l	(a2)+,a1		Store in a1
	add.l	d2,(a1)		Modify start address
wnloop2	tst.b	(a2)		All relocated yet?
	beq	endwn		Yes, return
	moveq.l	#0,d1		Clear d1
wnloop	moveq.l	#0,d0		Clear d0
	move.b	(a2)+,d0		Get address
	cmp.b	#1,d0		Convert it?
	bne	nownloop		Yes, goto routine
	add.w	#$fe,d1		Move to next address
	bra	wnloop		Loop back around
nownloop	add.w	d0,d1		Relocate address
	add.w	d1,a1		New address
	add.l	d2,(a1)		Store it
	bra	wnloop2		Convert next address
endwn	jsr	(a0)		Run it
	bsr	bpalt		Set black palette
	add.l	#54000,mempos	Return memory
	rts			Return

	*End of gameover routines

	*Start of weapon routines

shootgun	move.w	weapon,d0		Get gun type
	cmp.w	#3,d0		Heavy weapon?
	bgt	hweapon		Yes, goto routine
	beq	weapon3		Pistol?
	bra	weapon1_2		No, must be close range
hweapon	cmp.w	#5,d0		Rocket launcher?
	beq	weapon5		Yes, goto routine
	blt	weapon4		Machine gun?
	bra	weapon6		No, must be plasma gun

weapon1_2	clr.w	shoot		Reset attack variable
	cmp.w	#5,firecount	Reached target yet?
	beq	hittarget		Yes, set variable
	tst.w	firecount		Able to use yet?
	bne	nofire		No, quit routine
	tst.w	fire		Attacked yet?
	beq	return		No, return
	add.w	#1,shottotal	Increase shot count
	move.w	#6,firecount	Set up delay counter
	move.l	#swipe,gunpos	Set up swipe animation
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#102552,d5	Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#2195,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	rts			Return

hittarget	move.w	#1,shoot		Set attack variable
	bra	nofire		Return

weapon3	clr.w	shoot		Reset shoot variable
	cmp.w	#3,firecount	Reset gun icon yet?
	beq	resetgun		Yes, goto routine
	tst.w	firecount		Able to shoot yet?
	bne	nofire		No, quit routine
	tst.w	fire		Shot gun?
	beq	return		No, return
	tst.w	ammo1		Any ammo left?
	beq	return		No, return

	add.w	#1,shottotal	Increase shot count
	move.w	#6,firecount	Set up fire counter
	move.w	#1,guntype	Change gun icon
	move.l	#fireanim,gunpos	Set up fire animation
	move.w	#1,shoot		Set shoot variable
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#28840,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#2478,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	sub.w	#1,ammo1		Decrease ammo
	sub.w	#1,reload		Decrease reload counter
updatea1	move.w	ammo1,d5		Get amount of ammo
	move.w	#19,d6		X-coordinate
	move.w	#111,d7		Y-coordinate
	bsr	showammo		Update control panel
	rts			Return

nofire	sub.w	#1,firecount	Decrease fire counter
	rts			Return

resetgun	clr.w	guntype		Reset gun icon
	move.l	#gunanim,gunpos	Reset gun animation
	tst.w	reload		Test reload counter
	blt	reload2		Reload gun yet?
	bra	nofire		Return
reload2	move.w	#6,reload		Reset reload variable
	move.l	#ranim,gunpos	Reload gun animation
	move.w	#12,firecount	Set up fire counter
	bra	nofire		Return

weapon4	clr.w	shoot		Reset shoot variable
	cmp.w	#1,firecount	Reset gun icon yet?
	beq	resetmgun		Yes, goto routine
	tst.w	firecount		Able to shoot yet?
	bne	nofire		No, quit routine
	tst.w	fire		Shot gun?
	beq	return		No, return
	tst.w	ammo2		Any ammo left?
	beq	return		No, return

	add.w	#1,shottotal	Increase shot count
	move.w	#2,firecount	Set up fire counter
	move.w	#5,guntype	Change gun icon
	move.l	#quickfire,gunpos	Set up fire animation
	move.w	#1,shoot		Set shoot variable
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#28840,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#2478,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	sub.w	#1,ammo2		Decrease ammo
	move.w	ammo2,d5		Get amount of ammo
	move.w	#19,d6		X-coordinate
	move.w	#151,d7		Y-coordinate
	bsr	showammo		Update control panel
	rts			Return

resetmgun	move.w	#4,guntype	Reset gun icon
	move.l	#gunanim,gunpos	Reset gun animation
	bra	nofire		Return

weapon5	cmp.w	#3,firecount	Reset gun icon yet?
	beq	resetrl		Yes, goto routine
	tst.w	firecount		Able to use yet?
	bne	nofire		No, quit routine
	tst.w	fire		Shot gun?
	beq	return		No, return
	tst.w	ammo3		Any ammo left?
	beq	return		No, return
	tst.w	rocketh		Rocket already launched?
	bne	return		Yes, return

	move.l	#montable,a0	Address of monster table
	move.w	nummon,d6		Get number of monsters
	lsl.w	#3,d6		Multiply by 8
	add.w	d6,a0		Find place in table
	add.w	#1,nummon		Increase number of monsters
	move.w	xpos,(a0)+	Store xposition
	move.w	ypos,(a0)+	Store yposition
	move.w	#129,(a0)+	Set graphic to rocket
	move.w	#51,(a0)+		Sprite type to projectile
	move.w	face,rocketf	Direction of rocket
	move.w	#18880,rocketh	Height of rocket	
	move.w	#7,guntype	Change gun sprite
	move.l	#fireanim,gunpos	Set fire animation
	move.w	#6,firecount	Set up fire counter
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#89950,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#7347,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	move.w	xpos,d3		X position
	move.w	ypos,d4		Y position
	bsr	mrocket		Move rocket
	sub.w	#1,ammo3		Decrease ammo
	move.w	ammo3,d5		Get amount of ammo
	move.w	#19,d6		X-coordinate
	move.w	#191,d7		Y-coordinate
	bsr	showammo		Update control panel
	rts			Return

resetrl	move.w	#6,guntype	Reset gun icon
	move.l	#gunanim,gunpos	Reset gun animation
	bra	nofire		Return

weapon6	clr.w	shoot		Reset shoot variable
	cmp.w	#1,firecount	Reset gun icon yet?
	beq	resetpgun		Yes, goto routine
	tst.w	firecount		Able to shoot yet?
	bne	nofire		No, quit routine
	tst.w	fire		Shot gun?
	beq	return		No, return
	tst.w	ammo4		Any ammo left?
	beq	return		No, return

	add.w	#1,shottotal	Increase shot count
	move.w	#5,firecount	Set up fire counter
	move.w	#9,guntype	Change gun icon
	move.l	#fireanim,gunpos	Set up fire animation
	move.w	#1,shoot		Set shoot variable
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#69860,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#5484,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	sub.w	#1,ammo4		Decrease ammo
	move.w	ammo4,d5		Get amount of ammo
	move.w	#300,d6		X-coordinate
	move.w	#31,d7		Y-coordinate
	bsr	showammo		Update control panel
	rts			Return

resetpgun	move.w	#8,guntype	Reset gun icon
	move.l	#gunanim,gunpos	Reset gun animation
	bra	nofire		Return

	*End of weapon routines

	*Start of monster routines

monsters	sub.w	#1,samdelay	Decrease sample delay?
	blt	samzero		At zero yet?
samzeror	bsr	sortmon		Sort monsters
	tst.w	nummon		Any monsters?
	beq	return		No, return
	bsr	movemon		Move monsters
	clr.w	batactiv		Clear bat activation flag
	tst.w	nummon		Any monsters?
	beq	return		No, return
	bsr	depthsort		Depth sort monsters
	rts			Return

samzero	clr.w	samdelay		Sample can now play
	bra	samzeror		Return

	*Start of monster sort routines

sortmon	move.w	xpos,d3		Get player xposition
	move.w	ypos,d4		Get player yposition
	tst.w	nummon		Any active monsters?
	beq	noactive		No, skip deactivate routine
	move.l	#montable,a0	Address of monster table
	move.w	nummon,d0		Get number of monsters
	sub.w	#1,d0		Count from zero
sortmon2	move.w	d3,d5		Get player xposition
	sub.w	(a0)+,d5		Get monster xposition
	cmp.w	#190,d5		Out of range?
	bgt	outrange		Yes, disable
	cmp.w	#-190,d5		Out of range?
	blt	outrange		Yes, disable
	move.w	d4,d5		Get player yposition
	sub.w	(a0),d5		Get monster yposition
	cmp.w	#190,d5		Out of range?
	bgt	outrange		Yes, disable
	cmp.w	#-190,d5		Out of range?
	blt	outrange		Yes, disable
outranger	addq.l	#6,a0		Move to next monster
	dbf	d0,sortmon2	Check, next monster
	tst.w	nummon		Any monsters left?
	beq	noactive		No, skip sort routine
	move.w	nummon,d0		Get number of monsters
	sub.w	#1,d0		Count from zero
	move.l	#montable,a0	Address of monster table
	move.l	a0,a1		Destination address
sortmon3	tst.w	(a0)		Is monster active?
	beq	skipmon		No, shift monster up
	move.l	(a0)+,(a1)+	Copy across monster
	move.l	(a0)+,(a1)+	Copy across monster
	dbf	d0,sortmon3	Sort next monster

noactive	move.l	monmap,a0		Address of monster map
	move.l	#hitmon,a1	Strength of monsters
	move.w	xpos,d0		Get xposition
	lsr.w	#5,d0		Divide by 32
	move.w	ypos,d1		Get position
	lsr.w	#5,d1		Divide by 32
	lsl.w	#6,d1		Multiply by 64
	add.w	d1,d0		Find position in map
	sub.w	#325,d0		Go to corner of square
	add.w	d0,a0		Add onto address
	move.w	#10,d1		Set up x counter
xmonloop	move.w	#10,d2		Set up y counter
ymonloop	tst.b	(a0)+		Any monster in square?
	bne	activmon		Yes, activate it
activmonr	tst.b	4607(a0)		Any object in square?
	bne	activobj		Yes, activate it
activobjr	dbf	d2,ymonloop	Check next square
	lea	53(a0),a0		Move to next line
	dbf	d1,xmonloop	Check next line
	rts			Return

skipmon	addq.l	#8,a0		Skip monster
	bra	sortmon3		Return

outrange	cmp.w	#51,4(a0)		Is it a projectile?
	beq	outranger		Yes, can't be disabled!
	cmp.w	#60,4(a0)		Half way through exploding?
	bge	outranger		Yes, can't be disabled!
	move.w	-2(a0),d1		Get xcoordinate
	lsr.w	#5,d1		Divide by 32
	move.w	(a0),d2		Get ycoordinate
	lsr.w	#5,d2		Divide by 32
	lsl.w	#6,d2		Multiply by 64
	add.w	d2,d1		Find position in map
	move.w	2(a0),d2		Get monster frame number
	lsr.w	#4,d2		Find type of monster
	cmp.w	#7,d2		Is it an object?
	bge	killobj		Yes, store in other map
	add.w	#1,d2		Count from 1
	move.l	monmap,a1		Address of monster map
	tst.b	(a1,d1)		Is map space empty?
	bne	outranger		No, return
	move.b	d2,(a1,d1)	Store in map
	clr.w	-2(a0)		Disable monster
	sub.w	#1,nummon		Decrease number of monsters
	bra	outranger		Return

killobj	move.l	objmap,a1		Address of object map
	move.w	2(a0),d2		Get object type
	sub.w	#111,d2		Count from 1
	move.b	d2,(a1,d1)	Store in map
	clr.w	-2(a0)		Disable monster
	sub.w	#1,nummon		Decrease number of monsters
	bra	outranger		Return

activmon	move.b	-1(a0),d7		Get monster type
	sub.b	#1,d7		Count from zero
	ext.w	d7		Extend to word
	add.w	d7,d7		Scale up
	clr.b	-1(a0)		Erase monster from map
	bsr	getstats		Get monster statistics
	move.w	d7,d6		Get monster type
	lsl.w	#3,d6		Scale up
	move.w	d6,(a2)+		Store in table
	move.w	(a1,d7),(a2)+	Store monster strength
	bra	activmonr		Return

activobj	move.b	4607(a0),d7	Get object type
	sub.b	#1,d7		Count from 0
	ext.w	d7		Extend to word
	clr.b	4607(a0)		Erase object from map
	bsr	getstats		Get object statistics
	add.w	#112,d7		Set type to object
	move.w	d7,(a2)+		Store in table
	move.w	#50,(a2)+		Set object indicator flag
	bra	activobjr		Return

getstats	move.l	#montable,a2	Address of monster table
	move.w	nummon,d6		Get number of monsters
	lsl.w	#3,d6		Multiply by 8
	add.w	d6,a2		Find place in table
	add.w	#1,nummon		Increase number of monsters
	move.w	#5,d6		Get monster xposition
	sub.w	d2,d6		Find local position
	lsl.w	#5,d6		Scale up
	move.w	xpos,d5		Get xposition
	and.w	#$ffe0,d5		Round off
	add.w	#16,d5		Find centre of square
	add.w	d5,d6		Find global postion
	move.w	d6,(a2)+		Store in table
	move.w	#5,d6		Get monster yposition
	sub.w	d1,d6		Find local position
	lsl.w	#5,d6		Scale up
	move.w	ypos,d5		Get yposition
	and.w	#$ffe0,d5		Round off
	add.w	#16,d5		Find centre of square
	add.w	d5,d6		Find global postion
	move.w	d6,(a2)+		Store in table
	rts			Return

	*End of monster sort routines

	*Start of monster movement routines

movemon	add.w	#1,animcount	Move up animation counter
	cmp.w	#4,animcount	Loop back around?
	beq	resetac		Yes, goto routine
resetacr	move.w	nummon,d0		Get number of monsters
	sub.w	#1,d0		Count from zero
	move.w	xpos,d1		Get xposition
	move.w	ypos,d2		Get yposition
	move.l	#montable,a0	Address of monster table
movemloop	move.w	(a0)+,d3		Get monster xpos
	move.w	(a0)+,d4		Get monster ypos
	move.w	(a0)+,d5		Get monster type
	lsr.w	#4,d5		Scale down
	addq.l	#2,a0		Move to next monster
	cmp.w	#50,-2(a0)	Is monster exploding?
	bge	banganim		Yes, don't move it

	cmp.w	#2,d5		Beetle?
	beq	beetle		Yes, goto routine
	bgt	smallmon		Small monster?
	tst.w	d5		Rock monster?
	beq	rockmon		Yes, goto routine
	bra	robot		Draw robot
smallmon	cmp.w	#4,d5		Bat?
	beq	bat		Yes, goto routine
	blt	gunpost		Gunpost?
	cmp.w	#5,d5		Ghost?
	beq	ghost		Yes, goto routine
	bra	mutant		Mutant

resetac	clr.w	animcount		Reset animation counter
	bra	resetacr		Return

ghstcoli	move.l	blockmap,a2	Address of blockage map
	move.w	d3,d6		Get xposition
	lsr.w	#5,d6		Divide by 32
	move.w	d4,d7		Get yposition
	and.w	#$ffe0,d7		Round off
	add.w	d7,d7		Multiply by 2
	add.w	d7,d6		Find position in map
	add.w	d6,a2		Find correct address
	cmp.b	#$cc,(a2)		Blockage in square?
	beq	moncoli2		Yes, collided
	move.l	a2,a1		Update map address
	rts			Return

moncoli	move.l	blockmap,a2	Address of blockage map
	move.w	d3,d6		Get xposition
	lsr.w	#5,d6		Divide by 32
	move.w	d4,d7		Get yposition
	and.w	#$ffe0,d7		Round off
	add.w	d7,d7		Multiply by 2
	add.w	d7,d6		Find position in map
	add.w	d6,a2		Find correct address

	tst.b	(a2)		Blockage in square?
	bne	moncoli2		Yes, collided

	move.w	d3,d6		Get xposition
	and.w	#$1f,d6		Find position in square
	move.w	d4,d7		Get yposition
	and.w	#$1f,d7		Find position in square

	cmp.w	#9,d6		Xpos less than 9?
	blt	chckleft		Yes, check to left
	cmp.w	#22,d6		Xpos greater than 22?
	bgt	chckright		Yes, check to right
xchckr	cmp.w	#9,d7		Ypos less than 9?
	blt	chckup		Yes, check up
	cmp.w	#22,d7		Ypos greater than 22?
	bgt	chckdown		Yes, check down
ychckr	move.l	a2,a1		Address of new position
	rts			Return

chckleft	cmp.w	-8(a0),d3		Moving away from blockage?
	bgt	xchckr		Yes, return
	tst.b	-1(a2)		Any blockage left?
	bne	moncoli2		Yes, collided
	bra	xchckr		Return

chckright	cmp.w	-8(a0),d3		Moving away from blockage?
	blt	xchckr		Yes, return	
	tst.b	1(a2)		Any blockage right?
	bne	moncoli2		Yes, collided
	bra	xchckr		Return

chckup	cmp.w	-6(a0),d4		Moving away from blockage?
	bgt	ychckr		Yes, return
	tst.b	-64(a2)		Any blockage above?
	bne	moncoli2		Yes, collided
	bra	ychckr		Return

chckdown	cmp.w	-6(a0),d4		Moving away from blockage?
	blt	ychckr		Yes, return
	tst.b	64(a2)		Any blockage down?
	bne	moncoli2		Yes, collided
	bra	ychckr		Return

moncoli2	move.w	-8(a0),d3		Reset xposition
	move.w	-6(a0),d4		Reset yposition
	clr.w	d5		No need to animate
	rts			Return

banganim	cmp.w	#51,-2(a0)	Is it a projectile?
	beq	missile		Yes, goto routine
	cmp.w	#60,-2(a0)	Is monster exploding?
	blt	nomove		No, it must be an object
	add.w	#1,-2(a0)		Move up explosion counter
	cmp.w	#71,-2(a0)	End of explosion?
	beq	killmon		Yes, kill monster
nomove	dbf	d0,movemloop	Move next monster
	rts			Return

reloadrl	clr.w	rocketh		Reload rocket launcher
	bra	reloadrlr		Return

killmon	cmp.w	#129,-4(a0)	Is it a rocket?
	beq	reloadrl		Yes, reload launcher
reloadrlr	clr.w	-8(a0)		Erase monster
	sub.w	#1,nummon		Decrease number of monsters
	move.w	nummon,d3		Get number of monsters
	sub.w	#1,d3		Count from zero
	tst.w	d3		Any monsters left?
	blt	return		No, return
	move.l	#montable,a1	Address of monster table
	move.l	a1,a2		Destination address
killmon2	tst.w	(a1)		Is monster active?
	beq	killmon3		No, shift monster up
	move.l	(a1)+,(a2)+	Copy across monster
	move.l	(a1)+,(a2)+	Copy across monster
	dbf	d3,killmon2	Sort next monster
	sub.w	#1,d0		Decrease number of monsters
	tst.w	d0		All moved yet?
	blt	return		Yes, return
	subq.l	#8,a0		Point to next monster
	dbf	d0,movemloop	Move monster
	rts			Return

killmon3	addq.l	#8,a1		Skip monster
	bra	killmon2		Return

chckexplo	move.l	blockmap,a1	Address of blockage map
	move.w	d3,d6		Get xposition
	lsr.w	#5,d6		Divide by 32
	move.w	d4,d7		Get yposition
	and.w	#$ffe0,d7		Round off
	add.w	d7,d7		Multiply by 2
	add.w	d7,d6		Find position in map
	add.w	d6,a1		Find correct address
	cmp.b	#$ee,(a1)		Hit explosion
	bne	return		No, return
	addq.l	#4,sp		Drop return address
	move.w	#60,-2(a0)	Explode monster
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d6		Address of samples
	add.l	#75346,d6		Address of sample
	move.l	d6,samdata	Pass to routine
	move.w	#6792,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	move.w	#1,batactiv	Activate bats
	dbf	d0,movemloop	Check next monster
	rts			Return

getdist	clr.l	d5		Get animation status
	move.w	d3,d6		Get monster xpos
	sub.w	d1,d6		Find relative to us
	tst.w	d6		Negative?
	blt	xneg		Yes, change sign
xnegr	move.w	d4,d7		Get monster ypos
	sub.w	d2,d7		Find relative to us
	tst.w	d7		Negative?
	blt	yneg		Yes, change sign
ynegr	add.w	d7,d6		Get total distance
	move.w	d6,distance	Store it
	rts			Return
xneg	neg.w	d6		Change sign
	bra	xnegr		Return
yneg	neg.w	d7		Change sign
	bra	ynegr		Return

	*Start of rockmonster routines

rockmon	bsr	getdist		Get distance of monster
	bsr	chckexplo		Check for explosions

	cmp.w	#25,distance	Is monster close enough?
	blt	rmattack		Yes, make it attack
	clr.b	(a1)		Remove monster from old pos
	cmp.w	d1,d3		Move monster left or right?
	blt	rmonright		Move right
	bgt	rmonleft		Move left
xrmonr	swap	d5		Use other half of register next
	cmp.w	d2,d4		Move monster up or down?
	blt	rmondown		Move down
	bgt	rmonup		Move up

yrmonr	tst.l	d5		Animate monster?
	bne	animrmon		Yes, goto routine
	clr.w	-4(a0)		No, reset animation frame
animrmn2r	move.b	#$cc,(a1)		Store monster in blockage map
	dbf	d0,movemloop	Check next monster
	rts			Return

	*Start of rockmonster animation routines

animrmon	tst.w	animcount		Animate this screen update?
	beq	animrmon2		Yes, goto routine
	cmp.w	#2,animcount	Animate this screen update?
	beq	animrmon2		Yes, goto routine
	bra	animrmn2r		Return

animrmon2	cmp.l	#$10000,d5	Walking sideways?
	beq	horirmon		Yes, goto routine
	cmp.l	#1,d5		Walking sideways?
	beq	vertrmon		Yes, goto routine
	cmp.l	#$20000,d5	Walking sideways?
	beq	horirmon2		Yes, goto routine
	cmp.l	#2,d5		Walking sideways?
	beq	vertrmon2		Yes, goto routine
sidermonr	add.w	#1,-4(a0)		Move up frame number
	cmp.w	#3,-4(a0)		Back to first frame yet?
	bgt	rmonf1		Yes, reset variable
	bra	animrmonr		Return
rmonf1	clr.w	-4(a0)		Back to first frame
	bra	animrmonr		Return

horirmon	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	rmonri		Yes, goto routine
	cmp.w	#325,d7		Walking sideways?
	bgt	rmonri		Yes, goto routine
	cmp.w	#145,d7		Walking sideways?
	blt	sidermonr		No, return
	cmp.w	#215,d7		Walking sideways?
	bgt	sidermonr		No, return

rmonle	cmp.w	#9,-4(a0)		Just turned around?
	blt	rmonle2		Yes, reset frame number
	add.w	#1,-4(a0)		Move up frame number
	cmp.w	#12,-4(a0)	Loop animation yet?
	bgt	rmonle2		Yes, reset frame number
	bra	animrmonr		Return
rmonle2	move.w	#9,-4(a0)		Reset frame number
	bra	animrmonr		Return

horirmon2	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	rmonle		Yes, goto routine
	cmp.w	#325,d7		Walking sideways?
	bgt	rmonle		Yes, goto routine
	cmp.w	#145,d7		Walking sideways?
	blt	sidermonr		No, return
	cmp.w	#215,d7		Walking sideways?
	bgt	sidermonr		No, return

rmonri	cmp.w	#5,-4(a0)		Just turned around?
	blt	rmonri2		Yes, reset frame number
	add.w	#1,-4(a0)		Move up frame number
	cmp.w	#8,-4(a0)		Loop animation yet?
	bgt	rmonri2		Yes, reset frame number
	bra	animrmonr		Return
rmonri2	move.w	#5,-4(a0)		Reset frame number
	bra	animrmonr		Return

vertrmon	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	sidermonr		No, return
	cmp.w	#325,d7		Walking sideways?
	bgt	sidermonr		No, return
	cmp.w	#145,d7		Walking sideways?
	blt	rmonri		Yes, goto routine
	cmp.w	#215,d7		Walking sideways?
	bgt	rmonle		Yes, goto routine
	bra	sidermonr		Return

vertrmon2	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	sidermonr		No, return
	cmp.w	#325,d7		Walking sideways?
	bgt	sidermonr		No, return
	cmp.w	#145,d7		Walking sideways?
	blt	rmonle		Yes, goto routine
	cmp.w	#215,d7		Walking sideways?
	bgt	rmonri		Yes, goto routine
	bra	sidermonr		Return

animrmonr	move.w	-4(a0),d7		Get frame type
	tst.w	d7		Sound effect?
	beq	footstep		Yes, play sample
	cmp.w	#5,d7		Sound effect?
	beq	footstep		Yes, play sample
	cmp.w	#9,d7		Sound effect?
	beq	footstep		Yes, play sample
	bra	animrmn2r		Return

footstep	cmp.w	#100,distance	Is it in range?
	bgt	animrmn2r		No, return
	cmp.w	#64,distance	Is it very close?
	blt	loudstep		Yes, play at full volume
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#82140,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#2658,sampos	Size of sample
	move.w	#1,volume		Half volume
	or.b	#$20,$fffffa07.w	Play sample
	bra	animrmn2r		Return
loudstep	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#82140,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#2658,sampos	Size of sample
	clr.w	volume		Full volume
	or.b	#$20,$fffffa07.w	Play sample
	bra	animrmn2r		Return

	*End of rockmonster animation routines

rmattack	tst.w	animcount		Attack this screen update?
	bne	rmattackr		No skip routine
	move.w	-4(a0),d5		Get frame number
	cmp.w	#4,d5		Already attacking?
	beq	rmattack2		Yes, stop attacking
	move.w	#4,-4(a0)		Make monster attack
	move.w	#1,hchange	Change in health
	move.w	mon1p,d5		Get monster power
	sub.w	d5,health		Lose health
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#84800,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#5148,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	dbf	d0,movemloop	Check next monster
	rts			Return
rmattack2	clr.w	-4(a0)		Stop attacking
rmattackr	dbf	d0,movemloop	Check next monster
	rts			Return

rmonright	move.w	#1,d5		Activate walking animation
	add.w	mon1s,d3		Move monster right
	bsr	moncoli		Check for collisions
	move.w	d3,-8(a0)		Store x position
	bra	xrmonr		Return
rmonleft	move.w	#2,d5		Activate walking animation
	sub.w	mon1s,d3		Move monster left
	bsr	moncoli		Check for collisions
	move.w	d3,-8(a0)		Store x position
	bra	xrmonr		Return
rmondown	move.w	#1,d5		Activate walking animation
	add.w	mon1s,d4		Move monster down
	bsr	moncoli		Check for collisions
	move.w	d4,-6(a0)		Store y position
	bra	yrmonr		Return
rmonup	move.w	#2,d5		Activate walking animation
	sub.w	mon1s,d4		Move monster up
	bsr	moncoli		Check for collisions
	move.w	d4,-6(a0)		Store y position
	bra	yrmonr		Return

	*End of rockmonster routines

	*Start of beetle routines

beetle	bsr	getdist		Get distance
	cmp.w	#72,d6		Make sound effect?
	beq	btnoise		Yes, goto routine
	cmp.w	#71,d6		Make sound effect?
	beq	btnoise		Yes, goto routine
btnoiser	bsr	chckexplo		Check for explosions

	cmp.w	#25,distance	Is monster close enough?
	blt	btattack		Yes, make it attack
	clr.b	(a1)		Remove monster from old pos
	cmp.w	d1,d3		Move monster left or right?
	blt	btleright		Move right
	bgt	btleleft		Move left
xbtler	swap	d5		Use other half of register next
	cmp.w	d2,d4		Move monster up or down?
	blt	btledown		Move down
	bgt	btleup		Move up

ybtler	tst.l	d5		Animate monster?
	bne	animbtle		Yes, goto routine
	move.w	#32,-4(a0)	No, reset animation frame
animbtler	move.b	#$cc,(a1)		Store monster in blockage map
	dbf	d0,movemloop	Check next monster
	rts			Return

btnoise	tst.w	samdelay		Play sample?
	bne	btnoiser		No, skip replay routines
	move.l	samadr,d5		Address of samples
	add.l	#6592,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#5043,sampos	Size of sample
	clr.w	volume		Full volume
	or.b	#$20,$fffffa07.w	Play sample
	move.w	#16,samdelay	Set up delay till next sample
	bra	btnoiser		Return

	*Start of beetle animation routines

animbtle	tst.w	animcount		Animate this screen update?
	beq	animbtle2		Yes, goto routine
	cmp.w	#2,animcount	Animate this screen update?
	beq	animbtle2		Yes, goto routine
	bra	animbtler		Return

animbtle2	cmp.l	#$10000,d5	Walking sideways?
	beq	horibtle		Yes, goto routine
	cmp.l	#1,d5		Walking sideways?
	beq	vertbtle		Yes, goto routine
	cmp.l	#$20000,d5	Walking sideways?
	beq	horibtle2		Yes, goto routine
	cmp.l	#2,d5		Walking sideways?
	beq	vertbtle2		Yes, goto routine
sidebtler	add.w	#1,-4(a0)		Move up frame number
	cmp.w	#34,-4(a0)	Back to first frame yet?
	bgt	btlef1		Yes, reset variable
	bra	animbtler		Return
btlef1	move.w	#32,-4(a0)	Back to first frame
	bra	animbtler		Return

horibtle	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	btleri		Yes, goto routine
	cmp.w	#325,d7		Walking sideways?
	bgt	btleri		Yes, goto routine
	cmp.w	#145,d7		Walking sideways?
	blt	sidebtler		No, return
	cmp.w	#215,d7		Walking sideways?
	bgt	sidebtler		No, return

btlele	cmp.w	#39,-4(a0)	Just turned around?
	blt	btlele2		Yes, reset frame number
	add.w	#1,-4(a0)		Move up frame number
	cmp.w	#41,-4(a0)	Loop animation yet?
	bgt	btlele2		Yes, reset frame number
	bra	animbtler		Return
btlele2	move.w	#39,-4(a0)	Reset frame number
	bra	animbtler		Return

horibtle2	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	btlele		Yes, goto routine
	cmp.w	#325,d7		Walking sideways?
	bgt	btlele		Yes, goto routine
	cmp.w	#145,d7		Walking sideways?
	blt	sidebtler		No, return
	cmp.w	#215,d7		Walking sideways?
	bgt	sidebtler		No, return

btleri	cmp.w	#36,-4(a0)	Just turned around?
	blt	btleri2		Yes, reset frame number
	add.w	#1,-4(a0)		Move up frame number
	cmp.w	#38,-4(a0)	Loop animation yet?
	bgt	btleri2		Yes, reset frame number
	bra	animbtler		Return
btleri2	move.w	#36,-4(a0)	Reset frame number
	bra	animbtler		Return

vertbtle	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	sidebtler		No, return
	cmp.w	#325,d7		Walking sideways?
	bgt	sidebtler		No, return
	cmp.w	#145,d7		Walking sideways?
	blt	btleri		Yes, goto routine
	cmp.w	#215,d7		Walking sideways?
	bgt	btlele		Yes, goto routine
	bra	sidebtler		Return

vertbtle2	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	sidebtler		No, return
	cmp.w	#325,d7		Walking sideways?
	bgt	sidebtler		No, return
	cmp.w	#145,d7		Walking sideways?
	blt	btlele		Yes, goto routine
	cmp.w	#215,d7		Walking sideways?
	bgt	btleri		Yes, goto routine
	bra	sidebtler		Return

	*End of beetle animation routines

btattack	tst.w	animcount		Attack this screen update?
	bne	btattackr		No skip routine
	move.w	-4(a0),d5		Get frame number
	cmp.w	#35,d5		Already attacking?
	beq	btattack2		Yes, stop attacking
	move.w	#35,-4(a0)	Make monster attack
	move.w	#1,hchange	Change in health
	move.w	mon3p,d5		Get monster power
	sub.w	d5,health		Lose health
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#31320,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#1863,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	dbf	d0,movemloop	Check next monster
	rts			Return
btattack2	move.w	#32,-4(a0)	Stop attacking
btattackr	dbf	d0,movemloop	Check next monster
	rts			Return

btleright	move.w	d1,d6		Get x position
	sub.w	d3,d6		Find distance from beetle
	cmp.w	#3,d6		Is beetle in range?
	blt	xbtler		Yes, return
	move.w	#1,d5		Activate walking animation
	add.w	mon3s,d3		Move monster right
	bsr	moncoli		Check for collisions
	move.w	d3,-8(a0)		Store x position
	bra	xbtler		Return
btleleft	move.w	d3,d6		Get x position
	sub.w	d1,d6		Find distance from beetle
	cmp.w	#3,d6		Is beetle in range?
	blt	xbtler		Yes, return
	move.w	#2,d5		Activate walking animation
	sub.w	mon3s,d3		Move monster left
	bsr	moncoli		Check for collisions
	move.w	d3,-8(a0)		Store x position
	bra	xbtler		Return
btledown	move.w	d2,d6		Get y position
	sub.w	d4,d6		Find distance from beetle
	cmp.w	#3,d6		Is beetle in range?
	blt	ybtler		Yes, return
	move.w	#1,d5		Activate walking animation
	add.w	mon3s,d4		Move monster down
	bsr	moncoli		Check for collisions
	move.w	d4,-6(a0)		Store y position
	bra	ybtler		Return
btleup	move.w	d4,d6		Get y position
	sub.w	d2,d6		Find distance from beetle
	cmp.w	#3,d6		Is beetle in range?
	blt	ybtler		Yes, return
	move.w	#2,d5		Activate walking animation
	sub.w	mon3s,d4		Move monster up
	bsr	moncoli		Check for collisions
	move.w	d4,-6(a0)		Store y position
	bra	ybtler		Return

	*End of beetle routines

	*Start of robot routines

robot	clr.w	rbackward		Move robot forwards!
	bsr	getdist		Get distance
	bsr	chckexplo		Check for explosions

	cmp.w	#40,distance	Is monster close enough?
	blt	rbattack		Yes, make it attack
robobackr	clr.b	(a1)		Remove monster from old pos
	cmp.w	d1,d3		Move monster left or right?
	blt	roboright		Move right
	bgt	roboleft		Move left
xrobor	swap	d5		Use other half of register next
	cmp.w	d2,d4		Move monster up or down?
	blt	robodown		Move down
	bgt	roboup		Move up

yrobor	bra	animrobo		Animate robot
animrobor	move.b	#$cc,(a1)		Store monster in blockage map
	dbf	d0,movemloop	Check next monster
	rts			Return

roboback	move.w	#1,rbackward	Set backwards variable
	bra	robobackr		Return

	*Start of robot animation routines

animrobo	tst.w	animcount		Animate this screen update?
	beq	animrobo2		Yes, goto routine
	cmp.w	#2,animcount	Animate this screen update?
	beq	animrobo2		Yes, goto routine
	bra	animrobor		Return

animrobo2	cmp.l	#$10000,d5	Walking sideways?
	beq	horirobo		Yes, goto routine
	cmp.l	#1,d5		Walking sideways?
	beq	vertrobo		Yes, goto routine
	cmp.l	#$20000,d5	Walking sideways?
	beq	horirobo2		Yes, goto routine
	cmp.l	#2,d5		Walking sideways?
	beq	vertrobo2		Yes, goto routine
siderobor	add.w	#1,-4(a0)		Move up frame number
	cmp.w	#18,-4(a0)	Back to first frame yet?
	bgt	robof1		Yes, reset variable
	bra	animrobor		Return
robof1	move.w	#16,-4(a0)	Back to first frame
	bra	animrobor		Return

horirobo	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	robori		Yes, goto routine
	cmp.w	#325,d7		Walking sideways?
	bgt	robori		Yes, goto routine
	cmp.w	#145,d7		Walking sideways?
	blt	siderobor		No, return
	cmp.w	#215,d7		Walking sideways?
	bgt	siderobor		No, return

robole	move.w	#20,-4(a0)	Change graphic
	bra	animrobor		Return

horirobo2	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	robole		Yes, goto routine
	cmp.w	#325,d7		Walking sideways?
	bgt	robole		Yes, goto routine
	cmp.w	#145,d7		Walking sideways?
	blt	siderobor		No, return
	cmp.w	#215,d7		Walking sideways?
	bgt	siderobor		No, return

robori	move.w	#21,-4(a0)	Change graphic
	bra	animrobor		Return

vertrobo	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	siderobor		No, return
	cmp.w	#325,d7		Walking sideways?
	bgt	siderobor		No, return
	cmp.w	#145,d7		Walking sideways?
	blt	robori		Yes, goto routine
	cmp.w	#215,d7		Walking sideways?
	bgt	robole		Yes, goto routine
	bra	siderobor		Return

vertrobo2	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	siderobor		No, return
	cmp.w	#325,d7		Walking sideways?
	bgt	siderobor		No, return
	cmp.w	#145,d7		Walking sideways?
	blt	robole		Yes, goto routine
	cmp.w	#215,d7		Walking sideways?
	bgt	robori		Yes, goto routine
	bra	siderobor		Return

	*End of robot animation routines

rbattack	cmp.w	#35,distance	Too close?
	blt	roboback		Yes, move robot backwards
	tst.w	animcount		Attack this screen update?
	bne	rbattackr		No skip routine
	move.w	-4(a0),d5		Get frame number
	cmp.w	#19,d5		Already attacking?
	beq	rbattack2		Yes, stop attacking
	move.w	#19,-4(a0)	Make monster attack
	move.w	#1,hchange	Change in health
	move.w	mon2p,d5		Get monster power
	sub.w	d5,health		Lose health
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#69860,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#5484,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	dbf	d0,movemloop	Check next monster
	rts			Return
rbattack2	move.w	#16,-4(a0)	Stop attacking
rbattackr	dbf	d0,movemloop	Check next monster
	rts			Return

robor2	move.w	#1,d5		Activate walking animation
	sub.w	mon2s,d3		Move monster left
	bra	robor2r		Return	
robol2	move.w	#2,d5		Activate walking animation
	add.w	mon2s,d3		Move monster right
	bra	robol2r		Return
robod2	move.w	#1,d5		Activate walking animation
	sub.w	mon2s,d4		Move monster up
	bra	robod2r		Return
robou2	move.w	#2,d5		Activate walking animation
	add.w	mon2s,d4		Move monster down
	bra	robou2r		Return	

roboright	tst.w	rbackward		Moving backwards?
	bne	robor2		Yes, use other routine
	move.w	d1,d6		Get x position
	sub.w	d3,d6		Find distance from robot
	cmp.w	#2,d6		Is robot in range?
	blt	xrobor		Yes, return
	move.w	#1,d5		Activate walking animation
	add.w	mon2s,d3		Move monster right
robor2r	bsr	moncoli		Check for collisions
	move.w	d3,-8(a0)		Store x position
	bra	xrobor		Return

roboleft	tst.w	rbackward		Moving backwards?
	bne	robol2		Yes, use other routine
	move.w	d3,d6		Get x position
	sub.w	d1,d6		Find distance from robot
	cmp.w	#2,d6		Is robot in range?
	blt	xrobor		Yes, return
	move.w	#2,d5		Activate walking animation
	sub.w	mon2s,d3		Move monster left
robol2r	bsr	moncoli		Check for collisions
	move.w	d3,-8(a0)		Store x position
	bra	xrobor		Return

robodown	tst.w	rbackward		Moving backwards?
	bne	robod2		Yes, use other routine
	move.w	d2,d6		Get y position
	sub.w	d4,d6		Find distance from robot
	cmp.w	#2,d6		Is robot in range?
	blt	yrobor		Yes, return
	move.w	#1,d5		Activate walking animation
	add.w	mon2s,d4		Move monster down
robod2r	bsr	moncoli		Check for collisions
	move.w	d4,-6(a0)		Store y position
	bra	yrobor		Return

roboup	tst.w	rbackward		Moving backwards?
	bne	robou2		Yes, use other routine
	move.w	d4,d6		Get y position
	sub.w	d2,d6		Find distance from robot
	cmp.w	#2,d6		Is robot in range?
	blt	yrobor		Yes, return
	move.w	#2,d5		Activate walking animation
	sub.w	mon2s,d4		Move monster up
robou2r	bsr	moncoli		Check for collisions
	move.w	d4,-6(a0)		Store y position
	bra	yrobor		Return

	*End of robot routines

	*Start of mutant routines

mutant	bsr	getdist		Get distance
	bsr	chckexplo		Check for explosions

	cmp.w	#25,distance	Is monster close enough?
	blt	mtattack		Yes, make it attack
	clr.b	(a1)		Remove monster from old pos
	cmp.w	d1,d3		Move monster left or right?
	blt	mtntright		Move right
	bgt	mtntleft		Move left
xmtntr	swap	d5		Use other half of register next
	cmp.w	d2,d4		Move monster up or down?
	blt	mtntdown		Move down
	bgt	mtntup		Move up

ymtntr	tst.l	d5		Animate monster?
	bne	animmtnt		Yes, goto routine
	move.w	#96,-4(a0)	No, reset animation frame
animmtntr	move.b	#$cc,(a1)		Store monster in blockage map
	bsr	getdist		Get distance
	cmp.w	#72,d6		Make sound effect?
	beq	mtnoise		Yes, goto routine
	cmp.w	#71,d6		Make sound effect?
	beq	mtnoise		Yes, goto routine
mtnoiser	dbf	d0,movemloop	Check next monster
	rts			Return

mtnoise	tst.w	samdelay		Play sample?
	bne	mtnoiser		No, skip replay routines
	move.l	samadr,d5		Address of samples
	add.l	#49768,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#7908,sampos	Size of sample
	move.w	#1,volume		Half volume
	or.b	#$20,$fffffa07.w	Play sample
	move.w	#20,samdelay	Set up delay till next sample
	move.w	#105,-4(a0)	Do animation
	bra	mtnoiser		Return

	*Start of mutant animation routines

animmtnt	tst.w	animcount		Animate this screen update?
	beq	animmtnt2		Yes, goto routine
	cmp.w	#2,animcount	Animate this screen update?
	beq	animmtnt2		Yes, goto routine
	bra	animmtntr		Return

animmtnt2	cmp.l	#$10000,d5	Walking sideways?
	beq	horimtnt		Yes, goto routine
	cmp.l	#1,d5		Walking sideways?
	beq	vertmtnt		Yes, goto routine
	cmp.l	#$20000,d5	Walking sideways?
	beq	horimtnt2		Yes, goto routine
	cmp.l	#2,d5		Walking sideways?
	beq	vertmtnt2		Yes, goto routine
sidemtntr	add.w	#1,-4(a0)		Move up frame number
	cmp.w	#98,-4(a0)	Back to first frame yet?
	bgt	mtntf1		Yes, reset variable
	bra	animmtntr		Return
mtntf1	move.w	#96,-4(a0)	Back to first frame
	bra	animmtntr		Return

horimtnt	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	mtntri		Yes, goto routine
	cmp.w	#325,d7		Walking sideways?
	bgt	mtntri		Yes, goto routine
	cmp.w	#145,d7		Walking sideways?
	blt	sidemtntr		No, return
	cmp.w	#215,d7		Walking sideways?
	bgt	sidemtntr		No, return

mtntle	cmp.w	#102,-4(a0)	Just turned around?
	blt	mtntle2		Yes, reset frame number
	add.w	#1,-4(a0)		Move up frame number
	cmp.w	#104,-4(a0)	Loop animation yet?
	bgt	mtntle2		Yes, reset frame number
	bra	animmtntr		Return
mtntle2	move.w	#102,-4(a0)	Reset frame number
	bra	animmtntr		Return

horimtnt2	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	mtntle		Yes, goto routine
	cmp.w	#325,d7		Walking sideways?
	bgt	mtntle		Yes, goto routine
	cmp.w	#145,d7		Walking sideways?
	blt	sidemtntr		No, return
	cmp.w	#215,d7		Walking sideways?
	bgt	sidemtntr		No, return

mtntri	cmp.w	#99,-4(a0)	Just turned around?
	blt	mtntri2		Yes, reset frame number
	add.w	#1,-4(a0)		Move up frame number
	cmp.w	#101,-4(a0)	Loop animation yet?
	bgt	mtntri2		Yes, reset frame number
	bra	animmtntr		Return
mtntri2	move.w	#99,-4(a0)	Reset frame number
	bra	animmtntr		Return

vertmtnt	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	sidemtntr		No, return
	cmp.w	#325,d7		Walking sideways?
	bgt	sidemtntr		No, return
	cmp.w	#145,d7		Walking sideways?
	blt	mtntri		Yes, goto routine
	cmp.w	#215,d7		Walking sideways?
	bgt	mtntle		Yes, goto routine
	bra	sidemtntr		Return

vertmtnt2	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	sidemtntr		No, return
	cmp.w	#325,d7		Walking sideways?
	bgt	sidemtntr		No, return
	cmp.w	#145,d7		Walking sideways?
	blt	mtntle		Yes, goto routine
	cmp.w	#215,d7		Walking sideways?
	bgt	mtntri		Yes, goto routine
	bra	sidemtntr		Return

	*End of mutant animation routines

mtattack	tst.w	animcount		Attack this screen update?
	bne	mtattackr		No skip routine
	move.w	-4(a0),d5		Get frame number
	cmp.w	#105,d5		Already attacking?
	beq	mtattack2		Yes, stop attacking
	move.w	#105,-4(a0)	Make monster attack
	move.w	#1,hchange	Change in health
	move.w	mon7p,d5		Get monster power
	sub.w	d5,health		Lose health
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#49768,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#7908,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	dbf	d0,movemloop	Check next monster
	rts			Return
mtattack2	move.w	#96,-4(a0)	Stop attacking
mtattackr	dbf	d0,movemloop	Check next monster
	rts			Return

mtntright	move.w	d1,d6		Get x position
	sub.w	d3,d6		Find distance from mutant
	cmp.w	#2,d6		Is mutant in range?
	blt	xmtntr		Yes, return
	move.w	#1,d5		Activate walking animation
	add.w	mon7s,d3		Move monster right
	bsr	moncoli		Check for collisions
	move.w	d3,-8(a0)		Store x position
	bra	xmtntr		Return
mtntleft	move.w	d3,d6		Get x position
	sub.w	d1,d6		Find distance from mutant
	cmp.w	#2,d6		Is mutant in range?
	blt	xmtntr		Yes, return
	move.w	#2,d5		Activate walking animation
	sub.w	mon7s,d3		Move monster left
	bsr	moncoli		Check for collisions
	move.w	d3,-8(a0)		Store x position
	bra	xmtntr		Return
mtntdown	move.w	d2,d6		Get y position
	sub.w	d4,d6		Find distance from mutant
	cmp.w	#2,d6		Is mutant in range?
	blt	ymtntr		Yes, return
	move.w	#1,d5		Activate walking animation
	add.w	mon7s,d4		Move monster down
	bsr	moncoli		Check for collisions
	move.w	d4,-6(a0)		Store y position
	bra	ymtntr		Return
mtntup	move.w	d4,d6		Get y position
	sub.w	d2,d6		Find distance from mutant
	cmp.w	#2,d6		Is mutant in range?
	blt	ymtntr		Yes, return
	move.w	#2,d5		Activate walking animation
	sub.w	mon7s,d4		Move monster up
	bsr	moncoli		Check for collisions
	move.w	d4,-6(a0)		Store y position
	bra	ymtntr		Return

	*End of mutant routines

	*Start of ghost routines

ghost	bsr	getdist		Get distance of monster
	cmp.w	#72,d6		Make sound effect?
	beq	ghnoise		Yes, goto routine
	cmp.w	#71,d6		Make sound effect?
	beq	ghnoise		Yes, goto routine

ghnoiser	move.l	blockmap,a1	Address of blockage map
	move.w	d3,d6		Get xposition
	lsr.w	#5,d6		Divide by 32
	move.w	d4,d7		Get yposition
	and.w	#$ffe0,d7		Round off
	add.w	d7,d7		Multiply by 2
	add.w	d7,d6		Find position in map
	add.w	d6,a1		Find correct address
	cmp.b	#$cc,(a1)		Walking through wall?
	bne	inwall		Yes, don't delete it
	clr.b	(a1)		Remove from blockage map

inwall	cmp.w	#25,distance	Is monster close enough?
	blt	ghattack		Yes, make it attack
	cmp.w	d1,d3		Move monster left or right?
	blt	ghstright		Move right
	bgt	ghstleft		Move left
xghstr	cmp.w	d2,d4		Move monster up or down?
	blt	ghstdown		Move down
	bgt	ghstup		Move up
yghstr	cmp.w	#1,animcount	Animate this screen update?
	beq	ghanimr		No, skip routine
	cmp.w	#3,animcount	Animate this screen update?
	beq	ghanimr		No, skip routine
	add.w	#1,-4(a0)		Move up ghost animation
	cmp.w	#83,-4(a0)	Loop animation yet?
	bgt	ghostanim		Yes, goto routine
ghanimr	tst.b	(a1)		Walking through wall?
	bne	inwall2		Yes, don't delete it
	move.b	#$cc,(a1)		Store ghost on blockage map
inwall2	dbf	d0,movemloop	Check next monster
	rts			Return

ghostanim	move.w	#80,-4(a0)	Reset ghost animation
	bra	ghanimr		Return

ghnoise	tst.w	samdelay		Play sample?
	bne	ghnoiser		No, skip replay routines
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#11636,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#13599,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	move.w	#30,samdelay	Set up delay before repeat
	bra	ghnoiser		Return

ghattack	tst.w	animcount		Attack this screen update?
	bne	ghattackr		No skip routine
	move.w	-4(a0),d5		Get frame number
	cmp.w	#84,d5		Already attacking?
	beq	ghattack2		Yes, stop attacking
	move.w	#84,-4(a0)	Make monster attack
	move.w	#1,hchange	Change in health
	move.w	mon6p,d5		Get monster power
	sub.w	d5,health		Lose health
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#31320,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#1863,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	dbf	d0,movemloop	Check next monster
	rts			Return
ghattack2	move.w	#80,-4(a0)	Stop attacking
ghattackr	dbf	d0,movemloop	Check next monster
	rts			Return

ghstright	add.w	mon6s,d3		Move monster right
	bsr	ghstcoli		Check for collisions
	move.w	d3,-8(a0)		Store x position
	bra	xghstr		Return
ghstleft	sub.w	mon6s,d3		Move monster left
	bsr	ghstcoli		Check for collisions
	move.w	d3,-8(a0)		Store x position
	bra	xghstr		Return
ghstdown	add.w	mon6s,d4		Move monster down
	bsr	ghstcoli		Check for collisions
	move.w	d4,-6(a0)		Store y position
	bra	yghstr		Return
ghstup	sub.w	mon6s,d4		Move monster up
	bsr	ghstcoli		Check for collisions
	move.w	d4,-6(a0)		Store y position
	bra	yghstr		Return

	*End of ghost routines

	*Start of gunpost routines

gunpost	bsr	getdist		Get distance
	bsr	chckexplo		Check for explosions
	cmp.b	#$cc,(a1)		Gunpost still in blockage map?
	bne	wipegun		Yes, wipe from map
wipegunr	cmp.w	#48,-4(a0)	Just been activated?
	beq	initgun		Yes, initialise direction
initgunr	tst.w	animcount		Move gun this time
	bne	nogunmove		No, skip routine
	cmp.w	#56,-4(a0)	Already attacking?
	beq	gunfire2		Yes, stop attacking
	move.w	mon4r,d5		Get monster range
	cmp.w	distance,d5	In range?
	blt	nogunmove		No, don't move it
	cmp.w	#32,distance	Very close?
	bgt	wallchck		No, check for blocking walls
wallchckr	cmp.w	#52,-4(a0)	Facing us yet?
	blt	gunright		No, turn right
	bgt	gunleft		No, turn left

	move.w	#56,-4(a0)	Make monster attack
	move.w	#1,hchange	Change in health
	move.w	mon4p,d5		Get monster power
	sub.w	d5,health		Lose health
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#69860,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#5484,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
nogunmove	dbf	d0,movemloop	Check next monster
	rts			Return

gunfire2	move.w	#52,-4(a0)	Stop attacking
	bra	nogunmove		Return
wipegun	clr.b	(a1)		Wipe gunpost from blockage map
	bra	wipegunr		Return

gunright	add.w	#1,-4(a0)		Turn gun right
	bra	nogunmove		Return
gunleft	sub.w	#1,-4(a0)		Turn gun left
	bra	nogunmove		Return

initgun	move.l	$4ba,d5		Get a random number!
	btst	#0,d5		Point gun left or right?
	beq	gunpright		Point to right
	move.w	#49,-4(a0)	Point gun to left
	bra	initgunr		Return
gunpright	move.w	#55,-4(a0)	Point gun to right
	bra	initgunr		Return

wallchck	move.w	d1,d5		Get x position
	sub.w	d3,d5		Find x distance from gun
	asr.w	#2,d5		Divide by 4
	move.w	d2,d6		Get y position
	sub.w	d4,d6		Find y distance from gun
	asr.w	#2,d6		Divide by 4

	add.w	d5,d3		Move up x check point
	add.w	d6,d4		Move up y check point
	move.l	blockmap,a1	Address of blockage map
	move.w	d3,d7		Get xposition
	lsr.w	#5,d7		Divide by 32
	add.w	d7,a1		Add on to map address
	move.w	d4,d7		Get yposition
	and.w	#$ffe0,d7		Round off
	add.w	d7,d7		Multiply by 2
	add.w	d7,a1		Find correct address
	cmp.b	#$cc,(a1)		Shooting through wall?
	beq	wallchck2		No, continue checks
	tst.b	(a1)		Shooting through wall?
	bne	nogunmove		Yes, exit routine

wallchck2	add.w	d5,d3		Move up x check point
	add.w	d6,d4		Move up y check point
	move.l	blockmap,a1	Address of blockage map
	move.w	d3,d7		Get xposition
	lsr.w	#5,d7		Divide by 32
	add.w	d7,a1		Add on to map address
	move.w	d4,d7		Get yposition
	and.w	#$ffe0,d7		Round off
	add.w	d7,d7		Multiply by 2
	add.w	d7,a1		Find correct address
	cmp.b	#$cc,(a1)		Shooting through wall?
	beq	wallchck3		No, continue checks
	tst.b	(a1)		Shooting through wall?
	bne	nogunmove		Yes, exit routine

wallchck3	add.w	d5,d3		Move up x check point
	add.w	d6,d4		Move up y check point
	move.l	blockmap,a1	Address of blockage map
	move.w	d3,d7		Get xposition
	lsr.w	#5,d7		Divide by 32
	add.w	d7,a1		Add on to map address
	move.w	d4,d7		Get yposition
	and.w	#$ffe0,d7		Round off
	add.w	d7,d7		Multiply by 2
	add.w	d7,a1		Find correct address
	cmp.b	#$cc,(a1)		Shooting through wall?
	beq	wallchckr		No, fire gun
	tst.b	(a1)		Shooting through wall?
	bne	nogunmove		Yes, exit routine
	bra	wallchckr		Fire gun

	*End of gunpost routines

	*Start of bat routines

bat	bsr	chckexplo		Check for explosions
	move.b	#$cc,(a1)		Store monster in blockage map
	cmp.w	#64,-4(a0)	Dormant bat?
	beq	dormbat		Yes, goto routine

	bsr	getdist		Get distance of bat
	cmp.w	#25,distance	Is monster close enough?
	blt	baattack		Yes, make it attack
	clr.b	(a1)		Remove monster from old pos
	cmp.w	d1,d3		Move monster left or right?
	blt	batright		Move right
	bgt	batleft		Move left
xbatr	swap	d5		Use other half of register next
	cmp.w	d2,d4		Move monster up or down?
	blt	batdown		Move down
	bgt	batup		Move up
ybatr	bra	animbat		Animate bat
animbatr	move.b	#$cc,(a1)		Store monster in blockage map
nobat	dbf	d0,movemloop	Check next monster
	rts			Return

	*Start of bat animation routines

animbat	cmp.l	#$10000,d5	Flying sideways?
	beq	horibat		Yes, goto routine
	cmp.l	#1,d5		Flying sideways?
	beq	vertbat		Yes, goto routine
	cmp.l	#$20000,d5	Flying sideways?
	beq	horibat2		Yes, goto routine
	cmp.l	#2,d5		Flying sideways?
	beq	vertbat2		Yes, goto routine
sidebatr	add.w	#1,-4(a0)		Move up frame number
	cmp.w	#66,-4(a0)	Back to first frame yet?
	bgt	batf1		Yes, reset variable
	bra	animbatr		Return
batf1	move.w	#65,-4(a0)	Back to first frame
	bra	animbatr		Return

horibat	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	batri		Yes, goto routine
	cmp.w	#325,d7		Walking sideways?
	bgt	batri		Yes, goto routine
	cmp.w	#145,d7		Walking sideways?
	blt	sidebatr		No, return
	cmp.w	#215,d7		Walking sideways?
	bgt	sidebatr		No, return

batle	cmp.w	#67,-4(a0)	Just turned around?
	blt	batle2		Yes, reset frame number
	add.w	#1,-4(a0)		Move up frame number
	cmp.w	#66,-4(a0)	Loop animation yet?
	bgt	batle2		Yes, reset frame number
	bra	animbatr		Return
batle2	move.w	#67,-4(a0)	Reset frame number
	bra	animbatr		Return

horibat2	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	batle		Yes, goto routine
	cmp.w	#325,d7		Walking sideways?
	bgt	batle		Yes, goto routine
	cmp.w	#145,d7		Walking sideways?
	blt	sidebatr		No, return
	cmp.w	#215,d7		Walking sideways?
	bgt	sidebatr		No, return

batri	cmp.w	#69,-4(a0)	Just turned around?
	blt	batri2		Yes, reset frame number
	add.w	#1,-4(a0)		Move up frame number
	cmp.w	#68,-4(a0)	Loop animation yet?
	bgt	batri2		Yes, reset frame number
	bra	animbatr		Return
batri2	move.w	#69,-4(a0)	Reset frame number
	bra	animbatr		Return

vertbat	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	sidebatr		No, return
	cmp.w	#325,d7		Walking sideways?
	bgt	sidebatr		No, return
	cmp.w	#145,d7		Walking sideways?
	blt	batri		Yes, goto routine
	cmp.w	#215,d7		Walking sideways?
	bgt	batle		Yes, goto routine
	bra	sidebatr		Return

vertbat2	move.w	face,d7		Get player's directions
	cmp.w	#35,d7		Walking sideways?
	blt	sidebatr		No, return
	cmp.w	#325,d7		Walking sideways?
	bgt	sidebatr		No, return
	cmp.w	#145,d7		Walking sideways?
	blt	batle		Yes, goto routine
	cmp.w	#215,d7		Walking sideways?
	bgt	batri		Yes, goto routine
	bra	sidebatr		Return

	*End of bat animation routines

baattack	tst.w	animcount		Attack this screen update?
	bne	batckanim	 	No skip routine
	move.w	-4(a0),d5		Get frame number
	cmp.w	#70,d5		Already attacking?
	bgt	baattack2		Yes, stop attacking
	add.w	#6,-4(a0)		Make monster attack
	move.w	#1,hchange	Change in health
	move.w	mon5p,d5		Get monster power
	sub.w	d5,health		Lose health
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#31320,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#1863,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	bra	batckanim		Animate bat

baattack2	sub.w	#6,-4(a0)		Stop attacking
	bra	batckanim		Animate bat

batckanim	add.w	#1,-4(a0)		Move up bat animation frame
	cmp.w	#72,-4(a0)	Loop animation?
	bgt	bataloop		Yes, goto routine
	cmp.w	#70,-4(a0)	Is bat attacking?
	bgt	bataloopr		Yes, skip next bit
	cmp.w	#66,-4(a0)	Is bat flying alright?
	bgt	bataloop2		No, alter animation frame
bataloopr	dbf	d0,movemloop	Check next monster
	rts			Return

bataloop	move.w	#71,-4(a0)	Cycle wing flap animation
	bra	bataloopr		Return
bataloop2	move.w	#65,-4(a0)	Cycle wing flap animation
	bra	bataloopr		Return

batright	move.w	d1,d6		Get x position
	sub.w	d3,d6		Find distance from bat
	cmp.w	#4,d6		Is bat in range?
	blt	xbatr		Yes, return
	move.w	#1,d5		Activate walking animation
	add.w	mon5s,d3		Move monster right
	bsr	moncoli		Check for collisions
	move.w	d3,-8(a0)		Store x position
	bra	xbatr		Return
batleft	move.w	d3,d6		Get x position
	sub.w	d1,d6		Find distance from bat
	cmp.w	#4,d6		Is bat in range?
	blt	xbatr		Yes, return
	move.w	#2,d5		Activate walking animation
	sub.w	mon5s,d3		Move monster left
	bsr	moncoli		Check for collisions
	move.w	d3,-8(a0)		Store x position
	bra	xbatr		Return
batdown	move.w	d2,d6		Get y position
	sub.w	d4,d6		Find distance from bat
	cmp.w	#4,d6		Is bat in range?
	blt	ybatr		Yes, return
	move.w	#1,d5		Activate walking animation
	add.w	mon5s,d4		Move monster down
	bsr	moncoli		Check for collisions
	move.w	d4,-6(a0)		Store y position
	bra	ybatr		Return
batup	move.w	d4,d6		Get y position
	sub.w	d2,d6		Find distance from bat
	cmp.w	#4,d6		Is bat in range?
	blt	ybatr		Yes, return
	move.w	#2,d5		Activate walking animation
	sub.w	mon5s,d4		Move monster up
	bsr	moncoli		Check for collisions
	move.w	d4,-6(a0)		Store y position
	bra	ybatr		Return

dormbat	tst.w	batactiv		Activate bat?
	beq	nobat		No, skip routine
	move.w	#65,-4(a0)	Wake up bat
	bra	nobat		Return

batacti	move.w	#1,batactiv	Activate bats
	bra	colmonr		Return

	*End of bat routines

	*Start of missile routines

missile	move.l	#missiler,-(sp)	Return address
	cmp.w	#128,-4(a0)	Get missile type
	beq	mgrenade		Is it a grenade?
	bra	mrocket		No, move rocket
missiler	dbf	d0,movemloop	Check next monster
	rts			Return

rocketup	sub.w	#1280,rocketh	Move up rocket
	bra	rocketupr		Return

mrocket	move.l	blockmap,a1	Address of blockage map
	move.w	d3,d6		Get xposition
	lsr.w	#5,d6		Divide by 32
	move.w	d4,d7		Get yposition
	and.w	#$ffe0,d7		Round off
	add.w	d7,d7		Multiply by 2
	add.w	d7,d6		Find position in map
	add.w	d6,a1		Find correct address
	clr.b	(a1)		Remove rocket from old pos

	cmp.w	#11200,rocketh	Move rocket up
	bgt	rocketup		Yes, goto routine
rocketupr	move.w	rocketf,d6	Which way is it moving?
	move.l	#trig+720,a2	Address of trig table
	add.w	d6,d6		Multiply by 2
	neg.w	d6		Subtract from 180
	add.w	#180,d6		To get sin of angle
	move.w	(a2,d6),d5	Get value from table
	asr.w	#5,d5		Scale down
	add.w	d5,d3		Add onto xposition
	lea	180(a2),a2	Get cos of angle
	move.w	(a2,d6),d5	Get value from table
	asr.w	#5,d5		Scale down
	add.w	d5,d4		Add onto yposition

	move.l	blockmap,a1	Address of blockage map
	move.w	d3,d6		Get xposition
	lsr.w	#5,d6		Divide by 32
	move.w	d4,d7		Get yposition
	and.w	#$ffe0,d7		Round off
	add.w	d7,d7		Multiply by 2
	add.w	d7,d6		Find position in map
	add.w	d6,a1		Find correct address
	tst.b	(a1)		Collided?
	bne	blowrock		Yes, explode it!
blowrockr	move.w	d3,-8(a0)		Store x position
	move.w	d4,-6(a0)		Store y position
	move.b	#$ee,(a1)		Store rocket on map
	rts			Return

blowrock	cmp.b	#$cc,(a1)		Another monster?
	beq	blowrockr		Yes, keep going
	cmp.b	#$ee,(a1)		Hit explosion?
	beq	blowrockr		Yes, keep going
	move.w	#60,-2(a0)	Trigger explosion
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d6		Address of samples
	add.l	#75346,d6		Address of sample
	move.l	d6,samdata	Pass to routine
	move.w	#6792,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	rts			Return

grendown	sub.w	#1120,grenadeh	Move down grenade
	bra	grendownr		Return

mgrenade	cmp.w	#960,grenadeh	Move grenade down?
	bgt	grendown		Yes, goto routine
	bra	stillgren		No, already on floor
grendownr	move.w	grenadef,d6	Which way is it moving?
	move.l	#trig+720,a2	Address of trig table
	add.w	d6,d6		Multiply by 2
	neg.w	d6		Subtract from 180
	add.w	#180,d6		To get sin of angle
	move.w	(a2,d6),d5	Get value from table
	asr.w	#6,d5		Scale down
	add.w	d5,d3		Add onto xposition
	lea	180(a2),a2	Get cos of angle
	move.w	(a2,d6),d5	Get value from table
	asr.w	#6,d5		Scale down
	add.w	d5,d4		Add onto yposition

stillgren	move.l	blockmap,a1	Address of blockage map
	move.w	d3,d6		Get xposition
	lsr.w	#5,d6		Divide by 32
	move.w	d4,d7		Get yposition
	and.w	#$ffe0,d7		Round off
	add.w	d7,d7		Multiply by 2
	add.w	d7,d6		Find position in map
	add.w	d6,a1		Find correct address

	cmp.w	#3,grenadec	Explode yet?
	beq	blowgren		Yes, goto routine
	cmp.w	#2,grenadec	End of explosion?
	beq	stopgren		Yes, remove radiation
	tst.b	(a1)		Collided?
	bne	grenhit		Yes, move back
grenhitr	move.w	d3,-8(a0)		Store x position
	move.w	d4,-6(a0)		Store y position
	rts			Return

grenhit	cmp.b	#$cc,(a1)		Another monster?
	beq	grenhitr		Yes, keep going
	cmp.b	#$ee,(a1)		Hit explosion?
	beq	grenhitr		Yes, keep going
	rts			Return

blowgren	lea	-65(a1),a1	Kill anything near
	move.w	#2,d6		Set up a counter
bgloop	move.w	#2,d5		Set up second counter
bgloop2	cmp.b	#$cc,(a1)+	Hit monster?
	beq	putradi		Yes, place radiation
	tst.b	-1(a1)		Hit monster?
	beq	putradi		Yes, place radiation
putradir	dbf	d5,bgloop2	Check next square
	lea	61(a1),a1		Move to next line of map
	dbf	d6,bgloop		Check next line
	rts			Return
putradi	move.b	#$ee,-1(a1)	Spread radiation
	bra	putradir		Return

stopgren	move.w	#60,-2(a0)	Trigger explosion
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d6		Address of samples
	add.l	#75346,d6		Address of sample
	move.l	d6,samdata	Pass to routine
	move.w	#6792,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	lea	-65(a1),a1	Remove nearby radiation
	move.w	#2,d6		Set up a counter
sgloop	move.w	#2,d5		Set up a second counter
sgloop2	cmp.b	#$ee,(a1)+	Found radiation
	beq	stopradi		Yes, remove it
stopradir	dbf	d5,sgloop2	Check next square
	lea	61(a1),a1		Move to next line of map
	dbf	d6,sgloop		Check next line
	rts			Return
stopradi	clr.b	-1(a1)		Remove radiation
	bra	stopradir		Return

	*End of missile routines

	*End of monster movement routines

	*Start of monster depthsort routines

depthsort	move.w	xpos,d0		Get player xposition
	move.w	ypos,d1		Get player yposition
	move.l	#montable,a0	Address of monster table
	move.l	#mondepth,a1	Address of depth table
	move.w	nummon,d3		Get number of monsters
	sub.w	#1,d3		Set up a counter
depthloop	move.w	(a0)+,d4		Get xposition
	sub.w	xpos,d4		Find relative to us
	tst.w	d4		Negative?
	blt	invd4		Yes, inverse
invd4r	move.w	(a0)+,d5		Get yposition
	sub.w	ypos,d5		Find relative to us
	tst.w	d5		Negative?
	blt	invd5		Yes, inverse
invd5r	add.w	d5,d4		Find distance from us
	cmp.w	#20,d4		Too close?
	blt	colmon		Yes, collided
colmonr	move.w	d4,(a1)+		Store depth in table
	subq.l	#4,a0		Move to start of defintion
	move.l	a0,(a1)+		Store address of monster
	addq.l	#8,a0		Move to next monster
	dbf	d3,depthloop	Check next monster
	move.w	nummon,d2		Get number of monsters
	cmp.w	#1,d2		Only 1 monster?
	beq	return		Yes, return
	sub.w	#2,d2		Set up counter
bubblsort	move.l	#mondepth,a0	Address of depth table
	clr.w	d1		Set up end flag
	move.w	d2,d0		Set up counter
bubblloop	move.w	(a0),d4		Get data 1
	cmp.w	6(a0),d4		Swap contents?
	blt	bubblswap		Yes, goto routine
	addq.l	#6,a0		Move up position
	dbf	d0,bubblloop	Check next pair
	tst.w	d1		Sorted yet?
	beq	return		Yes, return
	dbf	d2,bubblsort	Do next pass
	rts			Return

invd4	neg.w	d4		Inverse d4
	bra	invd4r		Return
invd5	neg.w	d5		Inverse d5
	bra	invd5r		Return

bubblswap	move.w	#1,d1		Set flag
	move.l	2(a0),d3		Get address
	move.w	6(a0),(a0)	Swap number
	move.l	8(a0),2(a0)	Swap address
	move.w	d4,6(a0)		Swap number
	move.l	d3,8(a0)		Swap address
	addq.l	#6,a0		Move up position
	dbf	d0,bubblloop	Check next pair
	dbf	d2,bubblsort	Do next pass
	rts			Return

colmon	cmp.w	#50,2(a0)		Is monster still alive?
	beq	getobject		No, its an object!
	bge	colmonr		No, so we can't collide
	move.w	(a0),d2		Get monster type
	lsr.w	#4,d2		Convert to general type
	cmp.w	#3,d2		Is it a gunpost?
	beq	colmonr		Yes, return
	move.l	oldpos,xpos	Restore coordinates
	cmp.w	#4,d2		Is it a bat?
	beq	batacti		Yes, activate the bats!
	bra	colmonr		Return

	*End of monster depth sort routines

	*Start of object collection routines

getobject	clr.w	-4(a0)		Remove object from game
	move.w	(a0),d2		Get object type
	sub.w	#111,d2		Find object number
	cmp.b	#1,d2		Knife?		
	beq	getobj1		Yes, goto routine
	cmp.b	#2,d2		Machine-gun?
	beq	getobj2		Yes, goto routine
	cmp.b	#3,d2		Rocket-launcher?
	beq	getobj3		Yes, goto routine
	cmp.b	#4,d2		Plasma gun?
	beq	getobj4		Yes, goto routine
	cmp.b	#5,d2		Grenade?
	beq	getobj5		Yes, goto routine
	cmp.b	#6,d2		Keys?
	beq	getobj6		Yes, goto routine
	cmp.b	#7,d2		Medi-kit?
	beq	getobj7		Yes, goto routine
	cmp.b	#8,d2		Radar?
	beq	getobj8		Yes, goto routine
	cmp.b	#9,d2		Mapper?
	beq	getobj9		Yes, goto routine
	cmp.b	#10,d2		Pistol ammo?
	beq	gammo1		Yes, goto routine
	cmp.b	#11,d2		Machine gun ammo?
	beq	gammo2		Yes, goto routine
	cmp.b	#12,d2		Rocket launcher ammo?
	beq	gammo3		Yes, goto routine
	cmp.b	#13,d2		Plasma gun ammo?
	beq	gammo4		Yes, goto routine
	cmp.b	#14,d2		Bat activator?
	beq	batacti		Yes, goto routine
	bra	colmonr		Return

gammo1	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d2		Address of sample
	move.l	d2,samdata	Pass to routine
	move.w	#4021,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	movem.l	d0-d7/a0-a6,-(sp)	Preserve registers
	add.w	#50,ammo1		Increase ammo
	move.w	ammo1,d5		Get amount of ammo
	move.w	#19,d6		X-coordinate
	move.w	#111,d7		Y-coordinate
	bsr	showammo		Update control panel
	movem.l	(sp)+,d0-d7/a0-a6	Restore registers
	bra	colmonr		Return

gammo2	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d2		Address of sample
	move.l	d2,samdata	Pass to routine
	move.w	#4021,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	movem.l	d0-d7/a0-a6,-(sp)	Preserve registers
	add.w	#50,ammo2		Increase ammo
	move.w	ammo2,d5		Get amount of ammo
	move.w	#19,d6		X-coordinate
	move.w	#151,d7		Y-coordinate
	bsr	showammo		Update control panel
	movem.l	(sp)+,d0-d7/a0-a6	Restore registers
	bra	colmonr		Return

gammo3	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d2		Address of sample
	move.l	d2,samdata	Pass to routine
	move.w	#4021,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	movem.l	d0-d7/a0-a6,-(sp)	Preserve registers
	add.w	#10,ammo3		Increase ammo
	move.w	ammo3,d5		Get amount of ammo
	move.w	#19,d6		X-coordinate
	move.w	#191,d7		Y-coordinate
	bsr	showammo		Update control panel
	movem.l	(sp)+,d0-d7/a0-a6	Restore registers
	bra	colmonr		Return

gammo4	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d2		Address of sample
	move.l	d2,samdata	Pass to routine
	move.w	#4021,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	movem.l	d0-d7/a0-a6,-(sp)	Preserve registers
	add.w	#50,ammo4		Increase ammo
	move.w	ammo4,d5		Get amount of ammo
	move.w	#300,d6		X-coordinate
	move.w	#31,d7		Y-coordinate
	bsr	showammo		Update control panel
	movem.l	(sp)+,d0-d7/a0-a6	Restore registers
	bra	colmonr		Return

getobj1	movem.l	a0-a2/d0-d5,-(sp)	Preserve registers
	move.l	bordicon,a0	Source address
	lea	96(a0),a2		Mask address
	move.l	screen1,a1	Dest address
	move.w	#1,d0		Destination x
	move.w	#40,d1		Destination y
	move.w	#2,d2		Width
	move.w	#38,d3		Height
	bsr	graphic3		Update control panel
	move.l	bordicon,a0	Source address
	lea	96(a0),a2		Mask address
	move.l	screen2,a1	Dest address
	move.w	#1,d0		Destination x
	move.w	#40,d1		Destination y
	move.w	#2,d2		Width
	move.w	#38,d3		Height
	bsr	graphic3		Update control panel
	movem.l	(sp)+,a0-a2/d0-d5	Restore registers
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d2		Address of samples
	add.l	#36212,d2		Address of sample
	move.l	d2,samdata	Pass to routine
	move.w	#3033,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	move.w	#1,knife		Set variable
	bra	colmonr		Return

getobj2	movem.l	a0-a6/d0-d7,-(sp)	Preserve registers
	move.l	bordicon,a0	Source address
	lea	96(a0),a2		Mask address
	lea	24(a0),a0		Graphic address
	move.l	screen1,a1	Dest address
	move.w	#1,d0		Destination x
	move.w	#120,d1		Destination y
	move.w	#2,d2		Width
	move.w	#38,d3		Height
	bsr	graphic3		Update control panel
	move.l	bordicon,a0	Source address
	lea	96(a0),a2		Mask address
	lea	24(a0),a0		Graphic address
	move.l	screen2,a1	Dest address
	move.w	#1,d0		Destination x
	move.w	#120,d1		Destination y
	move.w	#2,d2		Width
	move.w	#38,d3		Height
	bsr	graphic3		Update control panel
	move.w	ammo2,d5		Get amount of ammo
	move.w	#19,d6		X-coordinate
	move.w	#151,d7		Y-coordinate
	bsr	showammo		Update control panel
	movem.l	(sp)+,a0-a6/d0-d7	Restore registers
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d2		Address of samples
	add.l	#39246,d2		Address of sample
	move.l	d2,samdata	Pass to routine
	move.w	#4668,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	move.w	#1,macgun		Set variable
	bra	colmonr		Return

getobj3	movem.l	a0-a6/d0-d7,-(sp)	Preserve registers
	move.l	bordicon,a0	Source address
	lea	96(a0),a2		Mask address
	lea	48(a0),a0		Graphic address
	move.l	screen1,a1	Dest address
	move.w	#1,d0		Destination x
	move.w	#160,d1		Destination y
	move.w	#2,d2		Width
	move.w	#38,d3		Height
	bsr	graphic3		Update control panel
	move.l	bordicon,a0	Source address
	lea	96(a0),a2		Mask address
	lea	48(a0),a0		Graphic address
	move.l	screen2,a1	Dest address
	move.w	#1,d0		Destination x
	move.w	#160,d1		Destination y
	move.w	#2,d2		Width
	move.w	#38,d3		Height
	bsr	graphic3		Update control panel
	move.w	ammo3,d5		Get amount of ammo
	move.w	#19,d6		X-coordinate
	move.w	#191,d7		Y-coordinate
	bsr	showammo		Update control panel
	movem.l	(sp)+,a0-a6/d0-d7	Restore registers
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d2		Address of samples
	add.l	#65046,d2		Address of sample
	move.l	d2,samdata	Pass to routine
	move.w	#4812,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	move.w	#1,rlaunch	Set variable
	bra	colmonr		Return

getobj4	movem.l	a0-a6/d0-d7,-(sp)	Preserve registers
	move.l	bordicon,a0	Source address
	lea	96(a0),a2		Mask address
	lea	72(a0),a0		Graphic address
	move.l	screen1,a1	Dest address
	move.w	#282,d0		Destination x
	move.w	#0,d1		Destination y
	move.w	#2,d2		Width
	move.w	#38,d3		Height
	bsr	graphic3		Update control panel
	move.l	bordicon,a0	Source address
	lea	96(a0),a2		Mask address
	lea	72(a0),a0		Graphic address
	move.l	screen2,a1	Dest address
	move.w	#282,d0		Destination x
	move.w	#0,d1		Destination y
	move.w	#2,d2		Width
	move.w	#38,d3		Height
	bsr	graphic3		Update control panel
	move.w	ammo4,d5		Get amount of ammo
	move.w	#300,d6		X-coordinate
	move.w	#31,d7		Y-coordinate
	bsr	showammo		Update control panel
	movem.l	(sp)+,a0-a6/d0-d7	Restore registers
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d2		Address of samples
	add.l	#57678,d2		Address of sample
	move.l	d2,samdata	Pass to routine
	move.w	#4243,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	move.w	#1,plasma		Set variable
	bra	colmonr		Return

getobj5	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d2		Address of samples
	add.l	#25236,d2		Address of sample
	move.l	d2,samdata	Pass to routine
	move.w	#3603,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	movem.l	d0-d7/a0-a6,-(sp)	Preserve registers
	add.w	#1,collect1	Increase quantity
	move.w	collect1,d5	Get quantity
	move.w	#306,d6		X-coordinate
	move.w	#71,d7		Y-coordinate
	bsr	showcount		Update control panel
	movem.l	(sp)+,d0-d7/a0-a6	Restore registers
	bra	colmonr		Return

getobj6	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d2		Address of samples
	add.l	#33184,d2		Address of sample
	move.l	d2,samdata	Pass to routine
	move.w	#3027,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	movem.l	d0-d7/a0-a6,-(sp)	Preserve registers
	add.w	#1,collect2	Increase quantity
	move.w	collect2,d5	Get quantity
	move.w	#306,d6		X-coordinate
	move.w	#111,d7		Y-coordinate
	bsr	showcount		Update control panel
	movem.l	(sp)+,d0-d7/a0-a6	Restore registers
	bra	colmonr		Return

getobj7	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d2		Address of samples
	add.l	#46416,d2		Address of sample
	move.l	d2,samdata	Pass to routine
	move.w	#3351,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	movem.l	d0-d7/a0-a6,-(sp)	Preserve registers
	add.w	#1,collect3	Increase quantity
	move.w	collect3,d5	Get quantity
	move.w	#306,d6		X-coordinate
	move.w	#151,d7		Y-coordinate
	bsr	showcount		Update control panel
	movem.l	(sp)+,d0-d7/a0-a6	Restore registers
	bra	colmonr		Return

getobj8	movem.l	a0-a2/d0-d5,-(sp)	Preserve registers
	move.l	bordicon,a0	Source address
	lea	6320(a0),a2	Mask address
	lea	6280(a0),a0	Graphic address
	move.l	screen1,a1	Dest address
	move.w	#201,d0		Destination x
	move.w	#151,d1		Destination y
	move.w	#4,d2		Width
	move.w	#47,d3		Height
	bsr	graphic3		Update control panel
	move.l	bordicon,a0	Source address
	lea	6320(a0),a2	Mask address
	lea	6280(a0),a0	Graphic address
	move.l	screen2,a1	Dest address
	move.w	#201,d0		Destination x
	move.w	#151,d1		Destination y
	move.w	#4,d2		Width
	move.w	#47,d3		Height
	bsr	graphic3		Update control panel
	movem.l	(sp)+,a0-a2/d0-d5	Restore registers
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d2		Address of samples
	add.l	#61922,d2		Address of sample
	move.l	d2,samdata	Pass to routine
	move.w	#3123,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	move.w	#1,radar		Set variable
	bra	colmonr		Return

getobj9	movem.l	a0-a2/d0-d5,-(sp)	Preserve registers
	move.l	bordicon,a0	Source address
	lea	6320(a0),a2	Mask address
	lea	6240(a0),a0	Graphic address
	move.l	screen1,a1	Dest address
	move.w	#40,d0		Destination x
	move.w	#151,d1		Destination y
	move.w	#4,d2		Width
	move.w	#47,d3		Height
	bsr	graphic3		Update control panel
	move.l	bordicon,a0	Source address
	lea	6320(a0),a2	Mask address
	lea	6240(a0),a0	Graphic address
	move.l	screen2,a1	Dest address
	move.w	#40,d0		Destination x
	move.w	#151,d1		Destination y
	move.w	#4,d2		Width
	move.w	#47,d3		Height
	bsr	graphic3		Update control panel
	movem.l	(sp)+,a0-a2/d0-d5	Restore registers
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d2		Address of samples
	add.l	#43916,d2		Address of sample
	move.l	d2,samdata	Pass to routine
	move.w	#2499,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	move.w	#1,mapper		Set variable
	bra	colmonr		Return

showammo	move.w	d5,d4		Get amount of ammo
	ext.l	d4		Ensure correct division
	divs.w	#100,d4		Divide by 100
	move.w	d6,d0		X-coordinate
	move.w	d7,d1		Y-coordinate
	bsr	smallnum		Draw it
	add.w	#6,d6		Move up x-coordinate
	mulu.w	#100,d4		Multiply d4 by 100
	neg.w	d4		Make negative
	add.w	d5,d4		Find second digit of number

	move.w	d4,d5		Copy to d5
	ext.l	d4		Ensure correct division
	divs.w	#10,d4		Divide by 10
	move.w	d6,d0		X-coordinate
	move.w	d7,d1		Y-coordinate
	bsr	smallnum		Draw it
	add.w	#6,d6		Move up x-coordinate
	mulu.w	#10,d4		Multiply d4 by 10
	neg.w	d4		Make negative
	add.w	d5,d4		Find last digit of number
	move.w	d6,d0		X-coordinate
	move.w	d7,d1		Y-coordinate
	bsr	smallnum		Draw it
	rts			Return

showcount	move.w	d5,d4		Get amount of object
	ext.l	d4		Ensure correct division
	divs.w	#10,d4		Divide by 10
	move.w	d6,d0		X-coordinate
	move.w	d7,d1		Y-coordinate
	bsr	smallnum		Draw it
	add.w	#6,d6		Move up x-coordinate
	mulu.w	#10,d4		Multiply d4 by 10
	neg.w	d4		Make negative
	add.w	d5,d4		Find last digit of number
	move.w	d6,d0		X-coordinate
	move.w	d7,d1		Y-coordinate
	bsr	smallnum		Draw it
	rts			Return

	*End of object collection routines

	*Start of monster drawing/health routines

drawmon	tst.w	nummon		Any monsters
	beq	return		No, return
	clr.l	hurtmon		Reset monster injury flag
	move.w	nummon,d0		Get number of monsters
	sub.w	#1,d0		Count from zero
	move.l	#mondepth,a1	Address of monster table
	addq.l	#2,a1		Find position in table
dmonloop	move.l	(a1),a0		Address of monster
	pea	6(a1)		Preserve address
	bsr	displaym		Draw monster on screen
	tst.w	(a0)		Injured monster?
	blt	whitemon		Yes, reset variable
whitemonr	move.l	(sp)+,a1		Restore address
	dbf	d0,dmonloop	Draw next monster
	tst.l	hurtmon		Have we shot anything?
	bne	injuredm		Yes, reduce energy
	rts			Return

injuredm	add.w	#1,shothits	Increase succesful hits counter
	move.l	hurtmon,a0	Address of monsters health
	move.w	damage,d6		Get strength of weapon
	sub.w	d6,(a0)		Reduce monsters health
	neg.w	(a0)		Turn monster white
	tst.w	(a0)		Is monster dead yet?
	bge	explodem		Yes, kill monster
	rts			Return

explodem	bsr	countkill		Count number of kills
	move.w	#60,(a0)		Trigger explosion
	move.l	blockmap,a1	Address of blockage map
	move.w	-6(a0),d6		Get xposition
	lsr.w	#5,d6		Divide by 32
	move.w	-4(a0),d7		Get yposition
	and.w	#$ffe0,d7		Round off
	add.w	d7,d7		Multiply by 2
	add.w	d7,d6		Find position in map
	cmp.b	#$cc,(a1,d6)	Need to remove from bmap?
	bne	noblock		No, don't alter map
	clr.b	(a1,d6)		Remove monster from map
noblock	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d6		Address of samples
	add.l	#75346,d6		Address of sample
	move.l	d6,samdata	Pass to routine
	move.w	#6792,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	move.w	#1,batactiv	Activate bats
	rts			Return

countkill	move.w	-2(a0),d6		Get monster type
	lsr.w	#4,d6		Divide by 16
	tst.w	d6		Rock monster?
	beq	incmon1k		Yes, move up counter
	cmp.w	#1,d6		Robot?
	beq	incmon2k		Yes, move up counter
	cmp.w	#2,d6		Beetle?
	beq	incmon3k		Yes, move up counter
	cmp.w	#3,d6		Gunpost?
	beq	incmon4k		Yes, move up counter
	cmp.w	#4,d6		Bat?
	beq	incmon5k		Yes, move up counter
	cmp.w	#5,d6		Ghost?
	beq	incmon6k		Yes, move up counter
	cmp.w	#6,d6		Mutant?
	beq	incmon7k		Yes, move up counter
	rts			Return
incmon1k	add.w	#1,rockmonh	Increase counter
	add.w	#20,score		Increase score
	rts			Return
incmon2k	add.w	#1,roboth		Increase counter
	add.w	#10,score		Increase score
	rts			Return
incmon3k	add.w	#1,beetleh	Increase counter
	add.w	#5,score		Increase score
	rts			Return
incmon4k	add.w	#1,gunposth	Increase counter
	add.w	#5,score		Increase score
	rts			Return
incmon5k	add.w	#1,bath		Increase counter
	add.w	#3,score		Increase score
	rts			Return
incmon6k	add.w	#1,ghosth		Increase counter
	add.w	#10,score		Increase score
	rts			Return
incmon7k	add.w	#1,mutanth	Increase counter
	add.w	#15,score		Increase score
	rts			Return

whitemon	neg.w	(a0)		Reset health variable
	bra	whitemonr		Return

displaym	move.w	(a0)+,d1		Get xcoordinate
	sub.w	xpos,d1		Find relative to player
	move.w	(a0)+,d2		Get ycoordinate
	sub.w	ypos,d2		Find relative to player

	move.l	#trig+720,a2	Address of trig table
	move.w	face,d7		Which way are we facing?
	add.w	d7,d7		Multiply by 2
	add.w	d7,a2		Find place in trig table
	move.w	(a2),d6		Get trig angle 1
	move.w	180(a2),d7	Get trig angle 2
	move.w	d1,d3		Get x
	muls.w	d7,d3		x=x*co
	move.w	d2,d4		Get y
	muls.w	d7,d4		y=y*co
	muls.w	d6,d2		y=y*si
	add.l	d3,d2		y=y+(x*co)
	asr.l	#4,d2		Scale down
	tst.w	d2		Is monster visible
	bge	return		No, return
	muls.w	d6,d1		x=x*si
	sub.l	d4,d1		x=x-(y*co)
	asr.l	#4,d1		Scale down

	move.w	d1,d4		Get x1
	muls.w	#90,d4		Multiply by 90
	divs.w	d2,d4		Divide by y1
	neg.w	d4		Make positive
	add.w	#120,d4		Find relative to centre
	cmp.w	#-10,d4		Is d4 out of range?
	blt	return		Yes, return
	cmp.w	#250,d4		Is d4 out of range?
	bgt	return		Yes, return
	move.l	#7333,d5		Calculate sy1
	divs.w	d2,d5		Divide by y
	cmp.w	#48,(a0)		Is object on ceiling?
	blt	upclose		No, still visible up close
	cmp.w	#64,(a0)		Is object on ceiling?
	bgt	upclose		No, still visible up close
	cmp.w	#-35,d5		Too close up?
	blt	return		Yes, return
upclose	cmp.w	#-24,d5		Sprite too big?
	blt	bigmon		Yes, reduce
	cmp.w	#-5,d5		Too small?
	bgt	return		Yes, return
	add.w	#24,d5		Make positive
	lsl.w	#4,d5		16 bytes per frame

bigmonr	move.l	#animdata,a1	Address of animation table
	move.w	(a0)+,d7		Get monster frame number
toowider	lsl.w	#3,d7		Scale up
	add.w	d7,a1		Find address of animation
	move.l	(a1)+,a2		Get frame address
	cmp.l	#-1,a2		Any frame to draw?
	beq	frame2		No, return
	add.w	d5,a2		Find correct subframe
	cmp.w	#5,(a2)		Frame too wide?
	beq	toowide		Yes, use alternative frame

	cmp.w	#1032,d7		Is it a rocket?
	beq	drocket		Yes, adjust height
	cmp.w	#1024,d7		Is it a grenade?
	beq	drgrenade		Yes, adjust height
drocketr	move.w	d5,-(sp)		Preserve d5
	move.w	d4,-(sp)		Preserve d4
	bsr	blitmon		Copy across to screen
	move.w	(sp)+,d4		Restore d4
	move.w	(sp)+,d5		Restore d5

frame2	move.l	(a1)+,a2		Get frame address
	cmp.l	#-1,a2		Any frame to draw?
	beq	return		No, return
	add.w	d5,a2		Find correct subframe
	move.w	d4,-(sp)		Preserve d4
	bsr	blitmon		Copy across to screen
	move.w	(sp)+,d4		Restore d4
	rts			Return

toowide	move.l	#animdata,a1	Address of animation table
	move.w	#80,d7		New frame number
	bra	toowider		Return

drocket	move.w	rocketh,14(a2)	Set y correction
	bra	drocketr		Return

drgrenade	move.l	#dummytble,a5	Address of dummy table
	move.l	(a2)+,(a5)+	Copy across old table
	move.l	(a2)+,(a5)+	Copy across old table
	move.l	(a2)+,(a5)+	Copy across old table
	move.l	(a2)+,(a5)+	Copy across old table
	lea	-16(a5),a2	Address of new table
	move.w	grenadeh,d3	Get height of grenade
	sub.w	d3,14(a2)		Set y correction
	bra	drocketr		Return

	*****************************************
	*  blitmon - copies monster onto screen *
	*    d4 = xpos, a2 = parameter table    *
	*        d5 = frame number x 16         *
	*     Must preserve d0,d4,d5,a0,a1      *
	*****************************************

blitmon	move.w	#75,d3		Max size of walls
	move.w	d5,d1		Monster frame number
	lsr.w	#3,d1		Find wall size
	sub.w	d1,d3		At which monster goes
	lsr.w	#1,d1		In front of the wall
	sub.w	d1,d3		Instead of behind
	move.w	d1,monsize	Store size

	move.w	d4,d7		Get xposition
	sub.w	12(a2),d7		Get x correction
	move.w	(a2),d1		Find width of monster
	lsl.w	#4,d1		In pixels

	move.l	#screenh,a5	Address of screen table
	add.w	d7,a5		Find place in table
	cmp.b	(a5),d3		Is left of monster visible?
	blt	nlmon		No, clip it off
	cmp.b	(a5,d1),d3	Is right of monster visible?
	blt	nrmon		No, clip it off

	move.l	screen1,a5	Find screen address
	add.w	14(a2),a5		Add on y correction
	add.w	#40,d7		Find x coordinate
	move.w	d7,d6		Make copy of x coordinate
	and.w	#$fff0,d6		Round of to nearest 16
	lsr.w	#1,d6		To find which word
	add.w	d6,a5		Graphics start at

	and.w	#$f,d7		Find amount to shift graphics
	move.l	#shiftmsk,a6	Address of end masks
	add.w	d7,a6		Find place in table
	move.w	(a6,d7),d2	Get end mask 1
	move.w	32(a6,d7),d6	Get end mask 2
	move.w	d2,d4		Find inverse of
	not.w	d4		end mask 1
	move.w	d6,d5		Find inverse of
	not.w	d5		end mask 2
	move.l	8(a2),a4		Find mask address
	move.l	4(a2),a3		Find graphics address
	move.w	(a2),d3		Find width in words

	tst.w	shoot		Have we fired a weapon?
	bne	shootmon1		Yes, check if monster is hit

	cmp.w	#1,d3		1 word?
	beq	word1		Yes, goto routine
	cmp.w	#2,d3		2 words?
	beq	word2		Yes, goto routine
	cmp.w	#3,d3		3 words?
	beq	word3		Yes, goto routine

word4	move.w	2(a2),d3		Set up y counter
	tst.w	(a0)		Injured monster?
	blt	iword4l		Yes, draw white
	cmp.w	#60,(a0)		Dead monster?
	bge	bword4		Yes, blow it up!
word4l	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	lea	-40(a5),a5	Reset screen address
	rept	4
	move.l	-2(a3),d1		Get first 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d2,d1		Add on endmask
	or.w	d1,(a5)+		Place on screen
	move.l	(a3)+,d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,6(a5)		Place on screen
	move.l	-2(a3),d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,14(a5)		Place on screen
	move.l	(a3)+,d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,22(a5)		Place on screen
	move.l	-2(a3),d1		Get last 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d6,d1		Add on endmask
	or.w	d1,30(a5)		Place on screen
	endr
	lea	152(a5),a5	Move down a line
	dbf	d3,word4l		Do next line
	rts			Return

iword4l	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	lea	120(a5),a5	Move down a line
	dbf	d3,iword4l	Do next line
	rts			Return

bword4	move.w	d0,-(sp)		Preserve d0
	move.w	(a0),d0		Get explosion counter
	sub.w	#60,d0		Count from 0
	lsl.w	#5,d0		Multiply by 32
	move.w	d0,d1		Copy into d1
	add.w	d1,d1		Multiply d1
	add.w	d1,d1		by 4 more
	add.w	d1,d0		Found d0*160 in d0
	move.w	d3,d1		Get height
	lsr.w	#1,d1		Divide by 2
	mulu.w	d0,d1		Multiply by spacing factor
	sub.l	d1,a5		Update screen address

bword4l	cmp.l	screen1,a5	Off top of screen?
	blt	sline4		Yes, skip line
	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	lea	-40(a5),a5	Reset screen address
	rept	4
	move.l	-2(a3),d1		Get first 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d2,d1		Add on endmask
	or.w	d1,(a5)+		Place on screen
	move.l	(a3)+,d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,6(a5)		Place on screen
	move.l	-2(a3),d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,14(a5)		Place on screen
	move.l	(a3)+,d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,22(a5)		Place on screen
	move.l	-2(a3),d1		Get last 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d6,d1		Add on endmask
	or.w	d1,30(a5)		Place on screen
	endr
	lea	152(a5),a5	Move down a line
sline4r	add.w	d0,a5		Skip lines for explode effect
	move.l	a5,d1		Get screen address
	sub.l	screen1,d1	Find relative to top
	cmp.w	#23840,d1		Off bottom yet?
	bgt	eline4		Yes, exit routine
	dbf	d3,bword4l	Do next line
eline4	move.w	(sp)+,d0		Restore d0
	rts			Return

sline4	addq.l	#8,a4		Move up mask address
	lea	32(a3),a3		Move up graphic address
	lea	160(a5),a5	Move up screen address
	bra	sline4r		Return

word3	move.w	2(a2),d3		Set up y counter
	tst.w	(a0)		Injured monster?
	blt	iword3l		Yes, draw it white
	cmp.w	#60,(a0)		Dead monster?
	bge	bword3		Yes, explode it
word3l	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on end mask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on mask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	addq.l	#2,a4		Move up mask address
	lea	-32(a5),a5	Reset screen address
	rept	4
	move.l	-2(a3),d1		Get first 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d2,d1		Add on end mask
	or.w	d1,(a5)+		Place on screen
	move.l	(a3)+,d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,6(a5)		Place on screen
	move.l	-2(a3),d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,14(a5)		Place on screen
	move.l	(a3),d1		Get last 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d6,d1		Add on end mask
	or.w	d1,22(a5)		Place on screen
	addq.l	#2,a3		Move up graphic address
	endr
	lea	152(a5),a5	Move down a line
	dbf	d3,word3l		Draw next line
	rts			Return

iword3l	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on end mask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on mask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	addq.l	#2,a4		Move up mask address
	lea	128(a5),a5	Move to next line
	dbf	d3,iword3l	Draw next line
	rts			Return

bword3	move.w	d0,-(sp)		Preserve d0
	move.w	(a0),d0		Get explosion counter
	sub.w	#60,d0		Count from 0
	lsl.w	#5,d0		Multiply by 32
	move.w	d0,d1		Copy into d1
	add.w	d1,d1		Multiply d1
	add.w	d1,d1		by 4 more
	add.w	d1,d0		Found d0*160 in d0
	move.w	d3,d1		Get height
	lsr.w	#1,d1		Divide by 2
	mulu.w	d0,d1		Multiply by spacing factor
	sub.l	d1,a5		Update screen address

bword3l	cmp.l	screen1,a5	Off top of screen?
	blt	sline3		Yes, skip line
	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on end mask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on mask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	addq.l	#2,a4		Move up mask address
	lea	-32(a5),a5	Reset screen address
	rept	4
	move.l	-2(a3),d1		Get first 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d2,d1		Add on end mask
	or.w	d1,(a5)+		Place on screen
	move.l	(a3)+,d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,6(a5)		Place on screen
	move.l	-2(a3),d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,14(a5)		Place on screen
	move.l	(a3),d1		Get last 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d6,d1		Add on end mask
	or.w	d1,22(a5)		Place on screen
	addq.l	#2,a3		Move up graphic address
	endr
	lea	152(a5),a5	Move down a line
sline3r	add.w	d0,a5		Skip lines for explode effect
	move.l	a5,d1		Get screen address
	sub.l	screen1,d1	Find relative to top
	cmp.w	#23840,d1		Off bottom yet?
	bgt	eline3		Yes, exit routine
	dbf	d3,bword3l	Do next line
eline3	move.w	(sp)+,d0		Restore d0
	rts			Return

sline3	addq.l	#6,a4		Move up mask address
	lea	24(a3),a3		Move up graphic address
	lea	160(a5),a5	Move up screen address
	bra	sline3r		Return

word2	move.w	2(a2),d3		Set up y counter
	tst.w	(a0)		Injured monster?
	blt	iword2l		Yes, draw it white
	cmp.w	#60,(a0)		Dead monster?
	bge	bword2		Yes, blow it up
word2l	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	lea	-24(a5),a5	Reset screen address
	rept	4
	move.l	-2(a3),d1		Get first 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d2,d1		Add on endmask
	or.w	d1,(a5)+		Place on screen
	move.l	(a3)+,d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,6(a5)		Place on screen
	move.l	-2(a3),d1		Get last 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d6,d1		Add on endmask
	or.w	d1,14(a5)		Place on screen
	endr	
	lea	152(a5),a5	Move down a line
	dbf	d3,word2l		Draw next line
	rts			Return

iword2l	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	lea	136(a5),a5	Move to next line
	dbf	d3,iword2l	Draw next line
	rts			Return

bword2	move.w	d0,-(sp)		Preserve d0
	move.w	(a0),d0		Get explosion counter
	sub.w	#60,d0		Count from 0
	lsl.w	#5,d0		Multiply by 32
	move.w	d0,d1		Copy into d1
	add.w	d1,d1		Multiply d1
	add.w	d1,d1		by 4 more
	add.w	d1,d0		Found d0*160 in d0
	move.w	d3,d1		Get height
	lsr.w	#1,d1		Divide by 2
	mulu.w	d0,d1		Multiply by spacing factor
	sub.l	d1,a5		Update screen address

bword2l	cmp.l	screen1,a5	Off top of screen?
	blt	sline2		Yes, skip line
	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	lea	-24(a5),a5	Reset screen address
	rept	4
	move.l	-2(a3),d1		Get first 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d2,d1		Add on endmask
	or.w	d1,(a5)+		Place on screen
	move.l	(a3)+,d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,6(a5)		Place on screen
	move.l	-2(a3),d1		Get last 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d6,d1		Add on endmask
	or.w	d1,14(a5)		Place on screen
	endr	
	lea	152(a5),a5	Move down a line
sline2r	add.w	d0,a5		Skip lines for explode effect
	move.l	a5,d1		Get screen address
	sub.l	screen1,d1	Find relative to top
	cmp.w	#23840,d1		Off bottom yet?
	bgt	eline2		Yes, exit routine
	dbf	d3,bword2l	Do next line
eline2	move.w	(sp)+,d0		Restore d0
	rts			Return

sline2	addq.l	#4,a4		Move up mask address
	lea	16(a3),a3		Move up graphic address
	lea	160(a5),a5	Move up screen address
	bra	sline2r		Return

word1	move.w	2(a2),d3		Set up y counter
	tst.w	(a0)		Injured monster?
	blt	iword1l		Yes, draw it white
	cmp.w	#60,(a0)		Dead monster?
	bge	bword1		Yes, blow it up
word1l	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	addq.l	#2,a4		Move up mask address
	lea	-16(a5),a5	Reset screen address
	rept	4
	move.l	-2(a3),d1		Get first 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d2,d1		Add on endmask
	or.w	d1,(a5)+		Place on screen
	move.l	(a3),d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d6,d1		Add on endmask
	or.w	d1,6(a5)		Place on screen
	addq.l	#2,a3		Move up graphic address
	endr		
	lea	152(a5),a5	Move down a line
	dbf	d3,word1l		Draw next line
	rts			Return

iword1l	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	addq.l	#2,a4		Move up mask address
	lea	144(a5),a5	Move down a line
	dbf	d3,iword1l	Draw next line
	rts			Return

bword1	move.w	d0,-(sp)		Preserve d0
	move.w	(a0),d0		Get explosion counter
	sub.w	#60,d0		Count from 0
	lsl.w	#5,d0		Multiply by 32
	move.w	d0,d1		Copy into d1
	add.w	d1,d1		Multiply d1
	add.w	d1,d1		by 4 more
	add.w	d1,d0		Found d0*160 in d0
	move.w	d3,d1		Get height
	lsr.w	#1,d1		Divide by 2
	mulu.w	d0,d1		Multiply by spacing factor
	sub.l	d1,a5		Update screen address

bword1l	cmp.l	screen1,a5	Off top of screen?
	blt	sline1		Yes, skip line
	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	addq.l	#2,a4		Move up mask address
	lea	-16(a5),a5	Reset screen address
	rept	4
	move.l	-2(a3),d1		Get first 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d2,d1		Add on endmask
	or.w	d1,(a5)+		Place on screen
	move.l	(a3),d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d6,d1		Add on endmask
	or.w	d1,6(a5)		Place on screen
	addq.l	#2,a3		Move up graphic address
	endr		
	lea	152(a5),a5	Move down a line
sline1r	add.w	d0,a5		Skip lines for explode effect
	move.l	a5,d1		Get screen address
	sub.l	screen1,d1	Find relative to top
	cmp.w	#23840,d1		Off bottom yet?
	bgt	eline1		Yes, exit routine
	dbf	d3,bword1l	Do next line
eline1	move.w	(sp)+,d0		Restore d0
	rts			Return

sline1	addq.l	#2,a4		Move up mask address
	lea	8(a3),a3		Move up graphic address
	lea	160(a5),a5	Move up screen address
	bra	sline1r		Return

word3c	move.w	2(a2),d3		Set up y counter
	tst.w	(a0)		Injured monster?
	blt	iword3lc		Yes, draw it white
	cmp.w	#60,(a0)		Dead monster?
	bge	bword3c		Yes, blow it up
word3lc	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on end mask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on mask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	addq.l	#2,a4		Move up mask address
	add.w	a6,a4		Move up mask address
	lea	-32(a5),a5	Reset screen address
	rept	4
	move.l	-2(a3),d1		Get first 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d2,d1		Add on end mask
	or.w	d1,(a5)+		Place on screen
	move.l	(a3)+,d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,6(a5)		Place on screen
	move.l	-2(a3),d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,14(a5)		Place on screen
	move.l	(a3),d1		Get last 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d6,d1		Add on end mask
	or.w	d1,22(a5)		Place on screen
	addq.l	#2,a3		Move up graphic address
	add.w	a6,a3		Move up graphic address
	endr
	lea	152(a5),a5	Move down a line
	dbf	d3,word3lc	Draw next line
	rts			Return

iword3lc	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on end mask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on mask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	addq.l	#2,a4		Move up mask address
	add.w	a6,a4		Move up mask address
	lea	128(a5),a5	Move to next line
	dbf	d3,iword3lc	Draw next line
	rts			Return

bword3c	move.w	d0,-(sp)		Preserve d0
	move.w	(a0),d0		Get explosion counter
	sub.w	#60,d0		Count from 0
	lsl.w	#5,d0		Multiply by 32
	move.w	d0,d1		Copy into d1
	add.w	d1,d1		Multiply d1
	add.w	d1,d1		by 4 more
	add.w	d1,d0		Found d0*160 in d0
	move.w	d3,d1		Get height
	lsr.w	#1,d1		Divide by 2
	mulu.w	d0,d1		Multiply by spacing factor
	sub.l	d1,a5		Update screen address

bword3cl	cmp.l	screen1,a5	Off top of screen?
	blt	sline3c		Yes, skip line
	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on end mask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on mask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	addq.l	#2,a4		Move up mask address
	add.w	a6,a4		Move up mask address
	lea	-32(a5),a5	Reset screen address
	rept	4
	move.l	-2(a3),d1		Get first 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d2,d1		Add on end mask
	or.w	d1,(a5)+		Place on screen
	move.l	(a3)+,d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,6(a5)		Place on screen
	move.l	-2(a3),d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,14(a5)		Place on screen
	move.l	(a3),d1		Get last 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d6,d1		Add on end mask
	or.w	d1,22(a5)		Place on screen
	addq.l	#2,a3		Move up graphic address
	add.w	a6,a3		Move up graphic address
	endr
	lea	152(a5),a5	Move down a line
sline3cr	add.w	d0,a5		Skip lines for explode effect
	move.l	a5,d1		Get screen address
	sub.l	screen1,d1	Find relative to top
	cmp.w	#23840,d1		Off bottom yet?
	bgt	eline3c		Yes, exit routine
	dbf	d3,bword3cl	Do next line
eline3c	move.w	(sp)+,d0		Restore d0
	rts			Return

sline3c	addq.l	#6,a4		Move up mask address
	lea	24(a3),a3		Move up graphic address
	lea	160(a5),a5	Move up screen address
	bra	sline3cr		Return

word2c	move.w	2(a2),d3		Set up y counter
	tst.w	(a0)		Is monster injured?
	blt	iword2lc		Yes, draw it white
	cmp.w	#60,(a0)		Is monster dead?
	bge	bword2c		Yes, blow it up
word2lc	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	lea	-24(a5),a5	Reset screen address
	add.w	a6,a4		Move up mask address
	rept	4
	move.l	-2(a3),d1		Get first 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d2,d1		Add on endmask
	or.w	d1,(a5)+		Place on screen
	move.l	(a3)+,d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,6(a5)		Place on screen
	move.l	-2(a3),d1		Get last 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d6,d1		Add on endmask
	or.w	d1,14(a5)		Place on screen
	add.w	a6,a3		Move up graphic address
	endr	
	lea	152(a5),a5	Move down a line
	dbf	d3,word2lc	Draw next line
	rts			Return

iword2lc	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	lea	136(a5),a5	Move to next line
	add.w	a6,a4		Move up mask address
	dbf	d3,iword2lc	Draw next line
	rts			Return

bword2c	move.w	d0,-(sp)		Preserve d0
	move.w	(a0),d0		Get explosion counter
	sub.w	#60,d0		Count from 0
	lsl.w	#5,d0		Multiply by 32
	move.w	d0,d1		Copy into d1
	add.w	d1,d1		Multiply d1
	add.w	d1,d1		by 4 more
	add.w	d1,d0		Found d0*160 in d0
	move.w	d3,d1		Get height
	lsr.w	#1,d1		Divide by 2
	mulu.w	d0,d1		Multiply by spacing factor
	sub.l	d1,a5		Update screen address
bword2cl	cmp.l	screen1,a5	Off top of screen?
	blt	sline2c		Yes, skip line
	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4)+,d1		Get next 16 bits of mask
	lsr.l	d7,d1		Shift them
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	-2(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	lea	-24(a5),a5	Reset screen address
	add.w	a6,a4		Move up mask address
	rept	4
	move.l	-2(a3),d1		Get first 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d2,d1		Add on endmask
	or.w	d1,(a5)+		Place on screen
	move.l	(a3)+,d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	or.w	d1,6(a5)		Place on screen
	move.l	-2(a3),d1		Get last 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d6,d1		Add on endmask
	or.w	d1,14(a5)		Place on screen
	add.w	a6,a3		Move up graphic address
	endr	
	lea	152(a5),a5	Move down a line
sline2cr	add.w	d0,a5		Skip lines for explode effect
	move.l	a5,d1		Get screen address
	sub.l	screen1,d1	Find relative to top
	cmp.w	#23840,d1		Off bottom yet?
	bgt	eline2c		Yes, exit routine
	dbf	d3,bword2cl	Do next line
eline2c	move.w	(sp)+,d0		Restore d0
	rts			Return

sline2c	addq.l	#4,a4		Move up mask address
	lea	16(a3),a3		Move up graphic address
	lea	160(a5),a5	Move up screen address
	bra	sline2cr		Return

word1c	move.w	2(a2),d3		Set up y counter
	tst.w	(a0)		Injured monster?
	blt	iword1lc		Yes, draw it white
	cmp.w	#60,(a0)		Is monster dead?
	bge	bword1c		Yes, blow it up
word1lc	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	addq.l	#2,a4		Move up mask address
	add.w	a6,a4		Move up mask address
	lea	-16(a5),a5	Reset screen address
	rept	4
	move.l	-2(a3),d1		Get first 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d2,d1		Add on endmask
	or.w	d1,(a5)+		Place on screen
	move.l	(a3),d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d6,d1		Add on endmask
	or.w	d1,6(a5)		Place on screen
	addq.l	#2,a3		Move up graphic address
	add.w	a6,a3		Move up mask address
	endr		
	lea	152(a5),a5	Move down a line
	dbf	d3,word1lc	Draw next line
	rts			Return

iword1lc	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	move.l	(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	or.w	d1,(a5)+		Place on screen
	not.w	d1		Inverse mask
	and.w	d1,(a5)+		Place on screen
	addq.l	#2,a4		Move up mask address
	add.w	a6,a4		Move up mask address
	lea	144(a5),a5	Reset screen address
	dbf	d3,iword1lc	Draw next line
	rts			Return

bword1c	move.w	d0,-(sp)		Preserve d0
	move.w	(a0),d0		Get explosion counter
	sub.w	#60,d0		Count from 0
	lsl.w	#5,d0		Multiply by 32
	move.w	d0,d1		Copy into d1
	add.w	d1,d1		Multiply d1
	add.w	d1,d1		by 4 more
	add.w	d1,d0		Found d0*160 in d0
	move.w	d3,d1		Get height
	lsr.w	#1,d1		Divide by 2
	mulu.w	d0,d1		Multiply by spacing factor
	sub.l	d1,a5		Update screen address
bword1cl	cmp.l	screen1,a5	Off top of screen?
	blt	sline1c		Yes, skip line
	move.l	-2(a4),d1		Get first 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d4,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	move.l	(a4),d1		Get last 16 bits of mask
	lsr.l	d7,d1		Shift them
	or.w	d5,d1		Add on endmask
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	and.w	d1,(a5)+		Place on screen
	addq.l	#2,a4		Move up mask address
	add.w	a6,a4		Move up mask address
	lea	-16(a5),a5	Reset screen address
	rept	4
	move.l	-2(a3),d1		Get first 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d2,d1		Add on endmask
	or.w	d1,(a5)+		Place on screen
	move.l	(a3),d1		Get next 16 bits of graphic
	lsr.l	d7,d1		Shift them
	and.w	d6,d1		Add on endmask
	or.w	d1,6(a5)		Place on screen
	addq.l	#2,a3		Move up graphic address
	add.w	a6,a3		Move up mask address
	endr		
	lea	152(a5),a5	Move down a line
sline1cr	add.w	d0,a5		Skip lines for explode effect
	move.l	a5,d1		Get screen address
	sub.l	screen1,d1	Find relative to top
	cmp.w	#23840,d1		Off bottom yet?
	bgt	eline1c		Yes, exit routine
	dbf	d3,bword1cl	Do next line
eline1c	move.w	(sp)+,d0		Restore d0
	rts			Return

sline1c	addq.l	#2,a4		Move up mask address
	lea	8(a3),a3		Move up graphic address
	lea	160(a5),a5	Move up screen address
	bra	sline1cr		Return

shootgh1	cmp.w	#6,weapon		Plasma gun?
	bne	sm1r		No, return
	bra	shootgh1r		Yes, hurt energy lifeform
shootgh2	cmp.w	#6,weapon		Plasma gun?
	bne	sm2r		No, return
	bra	shootgh2r		Yes, hurt energy lifeform

shootmon1	cmp.w	#50,(a0)		Is monster still alive?
	bge	sm1r		No, return
	move.w	-2(a0),d1		Get monster type
	lsr.w	#4,d1		Scale down
	cmp.w	#5,d1		Is it a ghost?
	beq	shootgh1		Yes, check for plasma attack
shootgh1r	move.w	d3,d1		Get width
	lsl.w	#3,d1		Multiply by 8
	add.w	4(sp),d1		Add on x position
	cmp.w	#120,d1		Have we hit?
	blt	sm1r		No, return
	sub.w	4(sp),d1		Subtract x position
	neg.w	d1		Find x position
	add.w	4(sp),d1		Minus the width
	cmp.w	#120,d1		Have we hit?
	bgt	sm1r		No, return
	tst.w	withdraw		Close range weapon?
	bne	close1		Yes, extra checks needed
	move.l	a0,hurtmon	Yes we hit, set variable
	bra	sm1r		Return

close1	cmp.w	#5,monsize	Is monster in range?
	bgt	sm1r		No, return
	move.l	a0,hurtmon	Yes, we hit, set variable
	bra	sm1r		Return

close2	cmp.w	#5,monsize	Is monster in range?
	bgt	sm2r		No, return
	move.l	a0,hurtmon	Yes, we hit, set variable
	bra	sm2r		Return

shootmon2	cmp.w	#50,(a0)		Is monster still alive?
	bge	sm2r		No, return
	move.w	-2(a0),d1		Get monster type
	lsr.w	#4,d1		Scale down
	cmp.w	#5,d1		Is it a ghost?
	beq	shootgh2		Yes, check for plasma attack
shootgh2r	move.w	d3,d1		Get width
	lsl.w	#3,d1		Multiply by 8
	add.w	4(sp),d1		Add on x position
	cmp.w	#120,d1		Have we hit?
	blt	sm2r		No, return
	sub.w	4(sp),d1		Subtract x position
	neg.w	d1		Find x position
	add.w	4(sp),d1		Minus the width
	cmp.w	#120,d1		Have we hit?
	bgt	sm2r		No, return
	tst.w	withdraw		Close range weapon?
	bne	close2		Yes, extra checks needed
	move.l	a0,hurtmon	Yes we hit, set variable
	bra	sm2r		Return

nlmon	cmp.b	(a5,d1),d3	Is right of monster visible?
	blt	return		No, don't draw it at all
	move.w	#-1,d1		Set up a counter
chckmpl	add.w	#1,d1		Number of lines to chop off
	cmp.b	(a5)+,d3		Is line visible yet?
	blt	chckmpl		No, check next one

	move.l	screen1,a5	Find screen address
	add.w	14(a2),a5		Add on y correction
	add.w	#40,d7		Find x coordinate
	move.w	d7,d6		Make copy of x coordinate
	and.w	#$fff0,d6		Round of to nearest 16
	lsr.w	#1,d6		To find which word
	add.w	d6,a5		Graphics start at

	and.w	#$f,d7		Find amount to shift graphics
	add.w	d7,d1		Add to clip amount

	cmp.w	#15,d1		Chopping off more than 15 lines?
	bgt	lwordchop		Yes, chop off entire word

	move.l	#shiftmsk,a6	Address of end masks
	add.w	d1,a6		Find place in table
	move.w	(a6,d1),d2	Get end mask 1

	move.l	#shiftmsk,a6	Address of end masks
	add.w	d7,a6		Find place in table
	move.w	32(a6,d7),d6	Get end mask 2
	move.w	d2,d4		Find inverse of
	not.w	d4		end mask 1
	move.w	d6,d5		Find inverse of
	not.w	d5		end mask 2
	move.l	8(a2),a4		Find mask address
	move.l	4(a2),a3		Find graphics address
	move.w	(a2),d3		Find width in words

	tst.w	shoot		Have we fired a weapon?
	bne	shootmon1		Yes, check if monster is hit

sm1r	cmp.w	#1,d3		1 word?
	beq	word1		Yes, goto routine
	cmp.w	#2,d3		2 words?
	beq	word2		Yes, goto routine
	cmp.w	#3,d3		3 words?
	beq	word3		Yes, goto routine
	bra	word4		4 words

lwordchop	clr.w	d5		Set up word chop counter
	move.w	(a2),d3		Find width in words
	move.l	8(a2),a4		Find mask address
	move.l	4(a2),a3		Find graphics address
lwcloop	add.w	#2,d5		Move up counter
	sub.w	#16,d1		Reduce shift
	sub.w	#1,d3		Reduce width
	addq.l	#2,a4		Move up mask address
	addq.l	#2,a3		Move up graphic address
	addq.l	#8,a5		Move up destination address
	cmp.w	#15,d1		Still too big?
	bgt	lwcloop		Yes, chop off
	tst.w	d3		Anything left?
	beq	return		No, return

	move.l	#shiftmsk,a6	Address of end masks
	add.w	d1,a6		Find place in table
	move.w	(a6,d1),d2	Get end mask 1
	move.l	#shiftmsk,a6	Address of end masks
	add.w	d7,a6		Find place in table
	move.w	32(a6,d7),d6	Get end mask 2

	move.w	d5,a6		Number words to chop off
	move.w	d2,d4		Find inverse of
	not.w	d4		end mask 1
	move.w	d6,d5		Find inverse of
	not.w	d5		end mask 2

	tst.w	shoot		Have we fired a weapon?
	bne	shootmon2		Yes, check if monster is hit

sm2r	cmp.w	#1,d3		1 word?
	beq	word1c		Yes, goto routine
	cmp.w	#2,d3		2 words?
	beq	word2c		Yes, goto routine
	bra	word3c		3 words
	
rwordchop	clr.w	d5		Set up word chop counter
	move.w	(a2),d3		Find width in words
	move.l	8(a2),a4		Find mask address
	move.l	4(a2),a3		Find graphics address
rwcloop	add.w	#2,d5		Move up counter
	add.w	#16,d1		Reduce shift
	sub.w	#1,d3		Reduce width
	tst	d1		Still too big?
	blt	rwcloop		Yes, chop off
	tst.w	d3		Anything left?
	beq	return		No, return

	move.l	#shiftmsk,a6	Address of end masks
	add.w	d7,a6		Find place in table
	move.w	(a6,d7),d2	Get end mask 1
	move.l	#shiftmsk,a6	Address of end masks
	add.w	d1,a6		Find place in table
	move.w	32(a6,d1),d6	Get end mask 2

	move.w	d5,a6		Number of words to chop off
	move.w	d2,d4		Find inverse of
	not.w	d4		end mask 1
	move.w	d6,d5		Find inverse of
	not.w	d5		end mask 2

	tst.w	shoot		Have we just fired a weapon?
	bne	shootmon2		Yes, check if monster is hit

	cmp.w	#1,d3		1 word?
	beq	word1c		Yes, goto routine
	cmp.w	#2,d3		2 words?
	beq	word2c		Yes, goto routine
	bra	word3c		3 words

nrmon	add.w	d1,a5		Move to right of monster
	move.w	#-1,d1		Set up a counter
chckmpr	add.w	#1,d1		Number of lines to chop off
	cmp.b	-(a5),d3		Is line visible yet?
	blt	chckmpr		No, check next one

	move.l	screen1,a5	Find screen address
	add.w	14(a2),a5		Add on y correction
	add.w	#40,d7		Find x coordinate
	move.w	d7,d6		Make copy of x coordinate
	and.w	#$fff0,d6		Round of to nearest 16
	lsr.w	#1,d6		To find which word
	add.w	d6,a5		Graphics start at

	and.w	#$f,d7		Find amount to shift graphics
	neg.w	d1		Find amount to clip off
	add.w	d7,d1		In d1

	tst.w	d1		More than 16 lines?
	blt	rwordchop		Yes, chop off word

	move.l	#shiftmsk,a6	Address of end masks
	add.w	d7,a6		Find place in table
	move.w	(a6,d7),d2	Get end mask 1

	move.l	#shiftmsk,a6	Address of end masks
	add.w	d1,a6		Find place in table
	move.w	32(a6,d1),d6	Get end mask 2
	move.w	d2,d4		Find inverse of
	not.w	d4		end mask 1
	move.w	d6,d5		Find inverse of
	not.w	d5		end mask 2
	move.l	8(a2),a4		Find mask address
	move.l	4(a2),a3		Find graphics address
	move.w	(a2),d3		Find width in words

	tst.w	shoot		Have we just fired a weapon
	bne	shootmon1		Yes, check if monster is hit

	cmp.w	#1,d3		1 word?
	beq	word1		Yes, goto routine
	cmp.w	#2,d3		2 words?
	beq	word2		Yes, goto routine
	cmp.w	#3,d3		3 words?
	beq	word3		Yes, goto routine
	bra	word4		4 words

bigmon	clr.w	d5		Maximum size monster
	clr.w	d6		Position of base
	bra	bigmonr		Return

return	rts			Return

	*End of monster drawing routines
	*End of monster routines

	*Start of player control routines

checkkeys	move.w	keybuff,d0	Get keyboard status
	cmp.w	oldkbuff,d0	Any change in status?
	beq	return		No, return
	move.w	d0,oldkbuff	Update old buffer
	cmp.b	#66,d0		Select keys?
	beq	fkey8		Yes, goto routine
	cmp.b	#67,d0		Select medi-kit?
	beq	fkey9		Yes, goto routine
	cmp.b	#68,d0		select save/load?
	beq	fkey10		Yes, goto routine
	cmp.b	#98,d0		select save/load?
	beq	fkey10		Yes, goto routine
	cmp.b	#25,d0		select save/load?
	beq	fkey10		Yes, goto routine
	tst.w	firecount		Gun in use?
	bne	return		Yes, return
	cmp.b	#59,d0		Select fist?
	beq	fkey1		Yes, goto routine
	cmp.b	#60,d0		Select knife?
	beq	fkey2		Yes, goto routine
	cmp.b	#61,d0		Select revolver?
	beq	fkey3		Yes, goto routine
	cmp.b	#62,d0		Select machine gun?
	beq	fkey4		Yes, goto routine
	cmp.b	#63,d0		Select rocket launcher?
	beq	fkey5		Yes, goto routine
	cmp.b	#64,d0		Select plasma gun?
	beq	fkey6		Yes, goto routine
	cmp.b	#65,d0		Select grenades?
	beq	fkey7		Yes, goto routine
	rts			Return

fkey1	cmp.w	#1,weapon		Already selected?
	beq	return		Yes, return
	bsr	deselect		Deselect old weapon
	move.w	#1,weapon		Select weapon 1
	bsr	select		Select new weapon
	move.l	#changegun,gunpos	Change gun animation
	move.w	#14,firecount	Set up fire counter
	rts			Return

fkey2	tst.w	knife		Have we a knife?
	beq	return		No, return
	cmp.w	#2,weapon		Already selected?
	beq	return		Yes, return
	bsr	deselect		Deselect old weapon
	move.w	#2,weapon		Select weapon 2
	bsr	select		Select new weapon
	move.l	#changegun,gunpos	Change gun animation
	move.w	#14,firecount	Set up fire counter
	rts			Return

fkey3	cmp.w	#3,weapon		Already selected?
	beq	return		Yes, return
	bsr	deselect		Deselect old weapon
	move.w	#3,weapon		Select weapon 3
	bsr	select		Select new weapon
	move.l	#changegun,gunpos	Change gun animation
	move.w	#14,firecount	Set up fire counter
	rts			Return

fkey4	tst.w	macgun		Have we a machine gun?
	beq	return		No, return
	cmp.w	#4,weapon		Already selected?
	beq	return		Yes, return
	bsr	deselect		Deselect old weapon
	move.w	#4,weapon		Select weapon 4
	bsr	select		Select new weapon
	move.l	#changegun,gunpos	Change gun animation
	move.w	#14,firecount	Set up fire counter
	rts			Return

fkey5	tst.w	rlaunch		Have we a rocket launcher?
	beq	return		No, return
	cmp.w	#5,weapon		Already selected?
	beq	return		Yes, return
	bsr	deselect		Deselect old weapon
	move.w	#5,weapon		Select weapon 5
	bsr	select		Select new weapon
	move.l	#changegun,gunpos	Change gun animation
	move.w	#14,firecount	Set up fire counter
	rts			Return

fkey6	tst.w	plasma		Have we a plasma gun?
	beq	return		No, return
	cmp.w	#6,weapon		Already selected?
	beq	return		Yes, return
	bsr	deselect		Deselect old weapon
	move.w	#6,weapon		Select weapon 6
	bsr	select		Select new weapon
	move.l	#changegun,gunpos	Change gun animation
	move.w	#14,firecount	Set up fire counter
	rts			Return

fkey7	tst.w	collect1		Have we any grenades?
	beq	return		No, return
	tst.w	grenadec		Ready to throw yet?
	bne	return		No, return
	sub.w	#1,collect1	Decrease number of grenades
	move.w	#19,grenadec	Set up grenade counter
	move.w	collect1,d5	Get quantity
	move.w	#306,d6		X-coordinate
	move.w	#71,d7		Y-coordinate
	bsr	showcount		Update control panel
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#102552,d5	Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#2195,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	rts			Return

fkey8	tst.w	collect2		Have we any keys?
	beq	return		No, return
	move.l	map1,a0		Address of map
	move.w	xpos,d2		Get xposition
	lsr.w	#5,d2		Divide by 32
	move.w	ypos,d3		Get yposition
	and.w	#$ffe0,d3		Round off
	add.w	d3,d3		Multiply by 2
	add.w	d3,d2		Find pos in map
	add.w	d2,a0		Find correct address
	lea	-65(a0),a0	Check nearby walls
	move.w	#2,d1		Set up a counter
fkey8l2	move.w	#2,d0		Set up a counter
fkey8l	cmp.b	#11,(a0)+		Locked door?
	beq	unlock		Yes, unlock it
	dbf	d0,fkey8l		Check next square
	lea	61(a0),a0		Move to next line
	dbf	d1,fkey8l2	Check next line
	rts			Return

unlock	sub.w	#1,collect2	Decrease number of keys
	move.b	#2,-1(a0)		Unlock door
	move.b	#1,2303(a0)	Open door
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#97298,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#2856,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	move.w	collect2,d5	Get quantity
	move.w	#306,d6		X-coordinate
	move.w	#111,d7		Y-coordinate
	bsr	showcount		Update control panel
	rts			Return

fkey9	tst.w	collect3		Have we any medi-kits?
	beq	return		No, return
	sub.w	#1,collect3	Reduce number
	move.w	collect3,d5	Get quantity
	move.w	#306,d6		X-coordinate
	move.w	#151,d7		Y-coordinate
	bsr	showcount		Update control panel
	add.w	#50,health	Increase health
	move.w	#1,hchange	Health has changed
	cmp.w	#100,health	Over max?
	bgt	tophealth		Yes, place on limit
	rts			Return

tophealth	move.w	#100,health	Maximum health
	rts			Retrun

fkey10	movem.l	d0-d7/a0-a6,-(sp)	Preserve registers
	move.l	screen1,a0	Destination address
	move.w	#1,d0		Side 1
	move.w	#77,d1		Track 77
	move.w	#4,d2		Sector 4
	move.l	#4977,d3		Size of file
	move.l	#24000,d4		Unpacked size
	move.w	#24,d5		Depack delay
	bsr	packload		Load it in
	move.l	screen1,a0	Source address
	move.l	screen2,a1	Destination address
	lea	17(a0),a0		Move to start of box
	lea	17(a1),a1		Move to start of box
	move.w	#149,d0		Set up a counter
fkey10l	move.b	(a0),(a1)		Copy first 8 pixels of line
	move.b	2(a0),2(a1)
	move.b	4(a0),4(a1)
	move.b	6(a0),6(a1)
	addq.l	#7,a0		Move up source address
	addq.l	#7,a1		Move up destination address
	move.w	#13,d1		Set up a counter
fkey10l2	move.w	(a0)+,(a1)+	Copy across middle of line
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	dbf	d1,fkey10l2	Keep copying
	rept	4		
	move.w	(a0)+,d2		Get end of line
	and.w	#$ff80,d2		Get 9 pixels of graphic
	and.w	#$7f,(a1)		Mask graphic
	or.w	d2,(a1)+		Store on screen
	endr
	lea	33(a0),a0		Move to next line
	lea	33(a1),a1		Move to next line
	dbf	d0,fkey10l	Copy onto screen
	move.l	screen2,a0	Source address
	move.l	screen1,a1	Destination address
	move.w	#7999,d0		Set up a counter
fkey10dup	move.l	(a0)+,(a1)+	Update other screen
	dbf	d0,fkey10dup	Keep copying

waitf10	move.l	#$600ff,-(sp)	Check Keyboard
	trap	#1		Call GEMDOS
	addq.l	#4,sp		Correct stack
	cmp.w	#"R",d0		Resume game?
	beq	fkey10r2		Yes, return
	cmp.w	#"r",d0		Resume game?
	beq	fkey10r2		Yes, return
	cmp.w	#"Q",d0		Quit game?
	beq	fkey10r		Yes, return
	cmp.w	#"q",d0		Quit game?
	beq	fkey10r		Yes, return
	bra	waitf10		No, keep waiting

fkey10r	clr.w	health		Quit game
	move.w	#1,hchange	Our health has changed
fkey10r2	bsr	clearkey		Clear key buffer
	movem.l	(sp)+,d0-d7/a0-a6	Restore registers
	rts			Return

deselect	move.l	bordicon,a0	Source address
	lea	13968(a0),a5	Mask address
	lea	13944(a0),a6	Graphic address
	move.w	weapon,d1		Get weapon number
	cmp.w	#6,d1		Right column?
	beq	riweapon		Yes, goto routine
	bra	leweapon		No, draw on left

select	move.l	bordicon,a0	Source address
	lea	13968(a0),a5	Mask address
	lea	13920(a0),a6	Graphic address
	move.w	weapon,d1		Get weapon number
	cmp.w	#6,d1		Right column?
	beq	riweapon		Yes, goto routine

leweapon	sub.w	#1,d1		Find y coordinate
	lsl.w	#3,d1		Multiply by 8
	move.w	d1,d7		Find y coordinate
	add.w	d1,d1		Multiply by 4
	add.w	d1,d1		Muitiply by 4
	add.w	d1,d7		Destination y

	move.w	#1,d0		Destination x
	move.w	d7,d1		Destination y
	move.w	#2,d2		Width
	move.w	#38,d3		Height
	move.l	a5,a2		Mask address
	move.l	a6,a0		Graphic address
	move.l	screen1,a1	Destination address
	bsr	graphic3		Update control panel
	move.w	#1,d0		Destination x
	move.w	d7,d1		Destination y
	move.w	#2,d2		Width
	move.w	#38,d3		Height
	move.l	a5,a2		Mask address
	move.l	a6,a0		Graphic address
	move.l	screen2,a1	Destination address
	bsr	graphic3		Update control panel
	rts			Return

riweapon	move.w	#282,d0		Destination x
	clr.w	d1		Destination y
	move.w	#2,d2		Width
	move.w	#38,d3		Height
	move.l	a5,a2		Mask address
	move.l	a6,a0		Graphic address
	move.l	screen1,a1	Destination address
	bsr	graphic3		Update control panel
	move.w	#282,d0		Destination x
	clr.w	d1		Destination y
	move.w	#2,d2		Width
	move.w	#38,d3		Height
	move.l	a5,a2		Mask address
	move.l	a6,a0		Graphic address
	move.l	screen2,a1	Destination address
	bsr	graphic3		Update control panel
	rts			Return

checkjoy	move.w	#$16,-(sp)	Request joystick packet
	move.w	#4,-(sp)		Message to IKBD
	move.w	#3,-(sp)		Function number
	trap	#13		Call BIOS
	addq.l	#6,sp		Correct stack

	move.w	#-1,-(sp)		Request keyboard status
	move.w	#11,-(sp)		Function number
	trap	#13		Call BIOS
	addq.l	#4,sp		Correct stack
	move.w	d0,a5		Store in a5
	btst	#1,d0		Fast move option?
	bne	fastmove		Yes, goto routine
	move.w	#6,turnspeed	Default turning speed
	move.w	#6,walkspeed	Default walking speed

fastmover	move.l	#$600ff,-(sp)	Check Keyboard
	trap	#1		Call GEMDOS
	addq.l	#4,sp		Correct stack
	swap	d0		Get scancode
	move.w	d0,a6		Store in a6
	move.w	d0,keybuff	Store in keyboard buffer
	bsr	clearkey		Clear keyboard buffer
	clr.w	movement		We haven't moved yet
	move.b	joy0,d7		Get joystick position
	btst	#2,d7		Rotate left?
	bne	turnl		Yes, goto routine
	cmp.w	#75,a6		Rotate left key?
	beq	turnl		Yes, goto routine
turnlr	btst	#3,d7		Rotate right?
	bne	turnr		Yes, goto routine
	cmp.w	#77,a6		Rotate right key?
	beq	turnr		Yes, goto routine
turnrr	btst	#0,d7		Walk forward?
	bne	walkf		Yes, goto routine
	cmp.w	#72,a6		Walk forward key?
	beq	walkf		Yes, goto routine
walkfr	btst	#1,d7		Walk back?
	bne	walkb		Yes, goto routine
	cmp.w	#80,a6		Walk back key?
	beq	walkb		Yes, goto routine
walkbr	cmp.w	#82,a6		Side step left?
	beq	walkl		Yes, goto routine
walklr	cmp.w	#71,a6		Side step right?
	beq	walkr		Yes, goto routine
walkrr	clr.w	fire		Reset fire variable
	move.w	a5,d0		Get control key status
	btst	#2,d0		Fire pressed?
	bne	firekey		Yes, goto routine
	btst	#7,d7		Check fire button?
	beq	return		Not pressed
firekey	move.w	#1,fire		Set fire variable
	rts			Return

fastmove	move.w	#12,turnspeed	Increase turning speed
	move.w	#5,walkspeed	Increase walking speed
	bra	fastmover		Return

clearkey	move.w	#5,d7		Set up a counter
ckloop	move.l	#$600ff,-(sp)	Check Keyboard
	trap	#1		Call GEMDOS
	addq.l	#4,sp		Correct stack
	dbf	d7,ckloop		Clear entire buffer
	rts			Return

turnr	move.w	turnspeed,d0	Get turning speed
	add.w	d0,face		Turn round
	cmp.w	#360,face		Full turn yet?
	bge	fullr		Yes, turn back
	bra	turnrr		Return
fullr	sub.w	#360,face		Turn back
	bra	turnrr		Return

turnl	move.w	turnspeed,d0	Get turning speed
	sub.w	d0,face		Turn around
	tst.w	face		Full turn yet?
	blt	fulll		Yes, turn back
	bra	turnlr		Return
fulll	add.w	#360,face		Turn back
	bra	turnlr		Return

walkr	move.w	face,d6		Which way are we facing?
	move.w	xpos,d4		Get xposition
	move.w	ypos,d5		Get yposition
	move.l	xpos,oldpos	Save position
	move.l	#trig+720,a2	Address of trig table
	move.w	#180,d0		Get sin of angle
	sub.w	d6,d0		Store in d0
	sub.w	d6,d0		Find place in table
	move.w	(a2,d0),d1	Get value from table
	move.w	walkspeed,d2	Get walking speed
	asr.w	d2,d1		Scale down
	add.w	d1,d5		Add onto yposition
	bsr	hitwall		Check for collisions
	move.w	d5,ypos		Update yposition
	lea	180(a2),a2	Get cos of angle
	move.w	(a2,d0),d1	Get value from table
	move.w	walkspeed,d2	Get walking speed
	asr.w	d2,d1		Scale down
	sub.w	d1,d4		Subtract from xposition
	bsr	hitwall		Check for collisions
 	move.w	d4,xpos		Update yposition
	bra	walkrr		Return

walkl	move.w	face,d6		Which way are we facing?
	move.w	xpos,d4		Get xposition
	move.w	ypos,d5		Get yposition
	move.l	xpos,oldpos	Save position
	move.l	#trig+720,a2	Address of trig table
	move.w	#180,d0		Get sin of angle
	sub.w	d6,d0		Store in d0
	sub.w	d6,d0		Find place in table
	move.w	(a2,d0),d1	Get value from table
	move.w	walkspeed,d2	Get walking speed
	asr.w	d2,d1		Scale down
	sub.w	d1,d5		Subtract from yposition
	bsr	hitwall		Check for collisions
	move.w	d5,ypos		Update yposition
	lea	180(a2),a2	Get cos of angle
	move.w	(a2,d0),d1	Get value from table
	move.w	walkspeed,d2	Get walking speed
	asr.w	d2,d1		Scale down
	add.w	d1,d4		Add onto xposition
	bsr	hitwall		Check for collisions
 	move.w	d4,xpos		Update yposition
	bra	walklr		Return

walkf	move.w	face,d6		Which way are we facing?
	move.w	xpos,d4		Get xposition
	move.w	ypos,d5		Get yposition
	move.l	xpos,oldpos	Save position
	move.l	#trig+720,a2	Address of trig table
	move.w	#180,d0		Get sin of angle
	sub.w	d6,d0		Store in d0
	sub.w	d6,d0		Find place in table
	move.w	(a2,d0),d1	Get value from table
	move.w	walkspeed,d2	Get walking speed
	asr.w	d2,d1		Scale down
	add.w	d1,d4		Add onto xposition
	bsr	hitwall		Check for collisions
	move.w	d4,xpos		Update xposition
	lea	180(a2),a2	Get cos of angle
	move.w	(a2,d0),d1	Get value from table
	move.w	walkspeed,d2	Get walking speed
	asr.w	d2,d1		Scale down
	add.w	d1,d5		Add onto yposition
	bsr	hitwall		Check for collisions
 	move.w	d5,ypos		Update yposition
	bra	walkfr		Return

walkb	move.w	face,d6		Which way are we facing?
	move.w	xpos,d4		Get xposition
	move.w	ypos,d5		Get yposition
	move.l	xpos,oldpos	Save position
	move.l	#trig+720,a2	Address of trig table
	move.w	#180,d0		Get sin of angle
	sub.w	d6,d0		Store in d0
	sub.w	d6,d0		Find place in table
	move.w	(a2,d0),d1	Get value from table
	move.w	walkspeed,d2	Get walking speed
	asr.w	d2,d1		Scale down
	sub.w	d1,d4		Subtract from xposition
	bsr	hitwall		Check for collisions
	move.w	d4,xpos		Update xposition
	lea	180(a2),a2	Get cos of angle
	move.w	(a2,d0),d1	Get value from table
	move.w	walkspeed,d2	Get walking speed
	asr.w	d2,d1		Scale down
	sub.w	d1,d5		Subtract from yposition
	bsr	hitwall		Check for collisions
	move.w	d5,ypos		Update yposition
	bra	walkbr		Return

hitwall	move.l	map1,a0		Address of map
	move.w	d4,d2		Get xposition
	sub.w	#14,d2		Subtract 14
	lsr.w	#5,d2		Divide by 32
	move.w	d5,d3		Get yposition
	sub.w	#14,d3		Subtract 14
	and.w	#$ffe0,d3		Round off
	add.w	d3,d3		Multiply by 2
	add.w	d3,d2		Find pos in map
	tst.b	(a0,d2)		Collided?
	bne	collide1		Yes, move back

collide1r	move.w	d4,d2		Get xposition
	add.w	#14,d2		Add 14
	lsr.w	#5,d2		Divide by 32
	add.w	d3,d2		Find pos in map
	tst.b	(a0,d2)		Collided?
	bne	collide2		Yes, move back

collide2r	move.w	d4,d2		Get xposition
	sub.w	#14,d2		Subtract 14
	lsr.w	#5,d2		Divide by 32
	move.w	d5,d3		Get yposition
	add.w	#14,d3		Add 14
	lsr.w	#5,d3		Divide by 32
	lsl.w	#6,d3		Multiply by 64
	add.w	d3,d2		Find pos in map
	tst.b	(a0,d2)		Collided?
	bne	collide3		Yes, move back

collide3r	move.w	d4,d2		Get xposition
	add.w	#14,d2		Add 14
	lsr.w	#5,d2		Divide by 32
	add.w	d3,d2		Find pos in map
	tst.b	(a0,d2)		Collided?
	bne	collide4		Yes, move back
	move.w	#1,movement	Set movement flag
	rts			Return

collide1	bsr	collided		We've collided
	bra	collide1r		Return
collide2	bsr	collided		We've collided
	bra	collide2r		Return
collide3	bsr	collided		We've collided
	bra	collide3r		Return
collide4	bsr	collided		We've collided
	rts			Return

collided	cmp.b	#2,(a0,d2)	Is it a door?
	beq	opendoor		Yes, open it
	cmp.b	#11,(a0,d2)	Locked door?
	beq	lockdoor		Yes, print message
	cmp.b	#12,(a0,d2)	Secret door?
	beq	fakedoor		Yes, open it
	cmp.b	#13,(a0,d2)	Is it the exit?
	beq	exitdoor		Yes, level complete!
	move.w	xpos,d4		Restore xposition
	move.w	ypos,d5		Restore yposition
	addq.l	#4,sp		Quit collide routine
	rts			Return

	*End of player control routines

	*Start of door routines

fakedoor	clr.b	(a0,d2)		Erase door from map
	move.l	blockmap,a1	Address of blockage map
	clr.b	(a1,d2)		Erase door from map
	move.l	map2,a1		Address of wall map
	clr.b	(a1,d2)		Erase door from map
	rts			Return

lockdoor	tst.w	mesc		Already printing message?
	bne	lockdoor2		Yes, don't print again
	move.w	#10,mesc		Set up message counter
	move.w	#2,mesn		Message number
lockdoor2	move.w	xpos,d4		Restore xposition
	move.w	ypos,d5		Restore yposition
	addq.l	#4,sp		Quit collide routine
	rts			Return

exitdoor	move.w	#1,won		Completed level!
	move.w	#0,health		Quit mainloop
	move.w	xpos,d4		Restore xposition
	move.w	ypos,d5		Restore yposition
	addq.l	#4,sp		Quit collide routine
	rts			Return

opendoor	move.l	doormap,a1	Address of doormap
	cmp.b	#15,(a1,d2)	Full open?
	beq	return		Yes, return
	tst.b	(a1,d2)		Currently opening?
	bne	halfopen		Yes, don't reset
	move.b	#1,(a1,d2)	Open door
	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#97298,d5		Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#2856,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
halfopen	move.w	xpos,d4		Restore xposition
	move.w	ypos,d5		Restore yposition
	rts			Return

chckdoor	move.l	doormap,a0	Address of doormap
	move.w	xpos,d0		Get xposition
	lsr.w	#5,d0		Divide by 32
	move.w	ypos,d1		Get position
	lsr.w	#5,d1		Divide by 32
	lsl.w	#6,d1		Multiply by 64
	add.w	d1,d0		Find position in map
	sub.w	#260,d0		Go to corner of square
	add.w	d0,a0		Add onto address
	move.w	#8,d1		Set up x counter
xdoorloop	move.w	#8,d2		Set up y counter
ydoorloop	tst.b	(a0)+		Is door active
	bgt	movedoor		Yes, move it
movedoorr	dbf	d2,ydoorloop	Check next square
	lea	55(a0),a0		Move to next line
	dbf	d1,xdoorloop	Check next line
	rts			Return

movedoor	cmp.w	#5,d1		Are we near door?
	bgt	shutdoor		No, close it
	cmp.w	#3,d1		Are we near door?
	blt	shutdoor		No, close it
	cmp.w	#5,d2		Are we near door?
	bgt	shutdoor		No, close it
	cmp.w	#3,d2		Are we near door?
	blt	shutdoor		No, close it
	cmp.b	#15,-1(a0)	Fully open
	beq	fullopen		Yes, return
	add.b	#1,-1(a0)		Open door
	bra	movedoorr		Return
shutdoor	cmp.b	#$f,4607(a0)	Is blockage map clear?
	beq	movedoorr		No, door can't shut
	sub.b	#1,-1(a0)		Close door
	move.b	#2,4607(a0)	Place back on blockage map
	bra	movedoorr		Return

fullopen	cmp.b	#2,4607(a0)	Still on blockage map?
	bne	movedoorr		No, return
	clr.b	4607(a0)		Remove from blockage map
	bra	movedoorr		Return

	*End of door routines

	*Start of screen calculation routines

calcscrn	move.l	#screenh,a0	Address of wall heights
	move.w	#59,d0		Set up counter
clrsh	clr.l	(a0)+		Clear it
	dbf	d0,clrsh		Loop back around
	clr.b	(a0)+		Clear last byte

	move.l	#rotate,a0	Address of rotation table
	move.w	face,d7		Which way are we facing?
	lsr.w	#1,d7		Divide by 2
	move.w	d7,d6		Add on 1 time
	lsl.w	#4,d7		Multiply by 16
	add.w	d7,d6		Added on 17 times
	lsl.w	#2,d7		Multiply by 4
	add.w	d7,d6		Added on 81 times
	add.w	d6,a0		Add to table address

	move.l	map2,a1		Address of wallmap
	move.w	xpos,d7		Get xposition
	lsr.w	#5,d7		Divide by 32
	add.w	d7,a1		Add onto map address
	move.w	ypos,d7		Get yposition
	lsr.w	#5,d7		Divide by 32
	lsl.w	#6,d7		Multiply by 64
	sub.w	#260,d7		Relative to centre
	add.w	d7,a1		Add onto map address

	move.w	xpos,d0		Get xpos
	lsr.w	#1,d0		Divide by 2
	and.w	#$000f,d0		Only want bottom 4 bits
	neg.w	d0		Make it negative
	sub.w	#64,d0		Relative to centre
	move.w	ypos,d1		Get ypos
	lsr.w	#1,d1		Divide by 2
	and.w	#$000f,d1		Only want bottom 4 bits
	neg.w	d1		Make it negative
	sub.w	#64,d1		Relative to centre

	move.w	#8,d2		Set up xcounter
xcsloop	move.w	#8,d3		Set up ycounter
ycsloop	move.b	(a0),d7		Get data from rotate table
	and.b	(a1),d7		Get data from wallmap
	tst.b	d7		Need to draw block?
	bne	drawblck		Yes goto routine
drawblckr	addq.l	#1,a0		Move up rotate table
	addq.l	#1,a1		Move up wallmap
	add.w	#16,d0		Increase xposition
	dbf	d3,ycsloop	Do next block
	lea	55(a1),a1		Move up wallmap
	sub.w	#144,d0		Reset xposition
	add.w	#16,d1		Move up yposition
	dbf	d2,xcsloop	Do next line
	rts			Return

	*Start of block calculation routines

drawblck	move.w	d2,a3		Preserve d2
	move.w	d3,a4		Preserve d3
	move.l	a0,-(sp)		Preserve a0
	btst	#0,d7		Draw top wall?
	bne	twall		Yes, goto routine
twallr	btst	#1,d7		Draw right wall?
	bne	rwall		Yes, goto routine
rwallr	btst	#2,d7		Draw base wall?
	bne	bwall		Yes, goto routine
bwallr	btst	#3,d7		Draw left wall?
	bne	lwall		Yes, goto routine
lwallr	btst	#4,d7		Draw horizontal door?
	bne	dhdoor		Yes, goto routine
dhdoorr	btst	#5,d7		Draw vertical door?
	bne	dvdoor		Yes, goto routine
dvdoorr	move.l	(sp)+,a0		Restore a0
	move.w	a4,d3		Restore d3
	move.w	a3,d2		Restore d2
	bra	drawblckr		Return

dhdoor	move.w	d0,a5		Preserve d0
	move.w	d1,a6		Preserve d1
	move.w	d7,-(a7)		Preserve d7
	move.l	a1,-(a7)		Preserve a1
	cmp.w	#90,face		Which face of door?
	blt	frhdoor		Front face	
	cmp.w	#270,face		Which face of door?
	bgt	frhdoor		Front face
	move.w	#1,backface	Back of door
frhdoor	move.w	d0,d2		Copy xposition
	add.w	#8,d1		y1=yps+8, y2=yps+8
	move.w	d1,d3		Copy yposition
	add.w	#16,d2		x2=xps+16
	tst.b	4608(a1)		Is door open?
	bne	openhdoor		Yes, goto routine
	bsr	drawwall		Draw wall
	clr.w	backface		Reset backface
	move.w	a6,d1		Restore d1
	move.w	a5,d0		Restore d0
	move.l	(a7)+,a1		Restore a1
	move.w	(a7)+,d7		Restore d7
	bra	dhdoorr		Return

openhdoor	move.b	4608(a1),d7	How open is door?
	ext.w	d7		Extend to word
	sub.w	d7,d2		Open door
	lsl.w	#5,d7		Scale up texture shift
	lsl.w	#5,d7		Scale up texture shift
	move.w	d7,tshift		Amount to shift texture
	bsr	drawwall		Draw door
	clr.w	backface		Reset backface
	clr.w	tshift		Reset texture shift
	move.w	a6,d1		Restore d1
	move.w	a5,d0		Restore d0
	move.l	(a7)+,a1		Restore a1
	move.w	(a7)+,d7		Restore d7
	bra	dhdoorr		Return

dvdoor	move.w	d0,a5		Preserve d0
	move.w	d1,a6		Preserve d1
	move.w	d7,-(a7)		Preserve d7
	move.l	a1,-(a7)		Preserve a1
	cmp.w	#180,face		Which face of door?
	blt	frvdoor		Front face
	move.w	#1,backface	Backface of door
frvdoor	add.w	#8,d0		x1=xps+8, x2=xps+8
	move.w	d0,d2		Copy xposition
	move.w	d1,d3		Copy yposition
	add.w	#16,d3		y2=yps+16
	tst.b	4608(a1)		Is door open?
	bne	openvdoor		Yes, goto routine
	bsr	drawwall		Draw door
	clr.w	backface		Reset backface
	move.w	a6,d1		Restore d1
	move.w	a5,d0		Restore d0
	move.l	(a7)+,a1		Restore a1
	move.w	(a7)+,d7		Restore d7
	bra	dvdoorr		Return

openvdoor	move.b	4608(a1),d7	How open is door?
	ext.w	d7		Extend to word
	sub.w	d7,d3		Open door
	lsl.w	#5,d7		Scale up texture shift
	lsl.w	#5,d7		Scale up texture shift
	move.w	d7,tshift		Amount to shift texture
	bsr	drawwall		Draw door
	clr.w	tshift		Reset texture shift
	clr.w	backface		Reset backface
	move.w	a6,d1		Restore d1
	move.w	a5,d0		Restore d0
	move.l	(a7)+,a1		Restore a1
	move.w	(a7)+,d7		Restore d7
	bra	dvdoorr		Return

twall	move.w	d0,a5		Preserve d0
	move.w	d1,a6		Preserve d1
	move.w	d7,-(a7)		Preserve d7
	move.l	a1,-(a7)		Preserve a1
	move.w	d0,d2		Copy xposition
	move.w	d1,d3		Copy yposition
	add.w	#16,d2		x2=xps+16
	bsr	drawwall		Draw wall
	move.w	a6,d1		Restore d1
	move.w	a5,d0		Restore d0
	move.l	(a7)+,a1		Restore a1
	move.w	(a7)+,d7		Restore d7
	bra	twallr		Return

rwall	move.w	d0,a5		Preserve d0
	move.w	d1,a6		Preserve d1
	move.w	d7,-(a7)		Preserve d7
	move.l	a1,-(a7)		Preserve a1
	add.w	#16,d0		x1=xps+16, x2=xps+16
	move.w	d0,d2		Copy xposition
	move.w	d1,d3		Copy yposition
	add.w	#16,d3		y2=yps+16
	bsr	drawwall		Draw wall
	move.w	a6,d1		Restore d1
	move.w	a5,d0		Restore d0
	move.l	(a7)+,a1		Restore a1
	move.w	(a7)+,d7		Restore d7
	bra	rwallr		Return

bwall	move.w	d0,a5		Preserve d0
	move.w	d1,a6		Preserve d1
	move.w	d7,-(a7)		Preserve d7
	move.l	a1,-(a7)		Preserve a1
	move.w	d0,d2		Copy xposition
	add.w	#16,d1		y1=yps+16, y2=yps+16
	move.w	d1,d3		Copy yposition
	add.w	#16,d2		x2=xps+16
	bsr	drawwall		Draw wall
	move.w	a6,d1		Restore d1
	move.w	a5,d0		Restore d0
	move.l	(a7)+,a1		Restore a1
	move.w	(a7)+,d7		Restore d7
	bra	bwallr		Return

lwall	move.w	d0,a5		Preserve d0
	move.w	d1,a6		Preserve d1
	move.w	d7,-(a7)		Preserve d7
	move.l	a1,-(a7)		Preserve a1
	move.w	d0,d2		Copy xposition
	move.w	d1,d3		Copy yposition
	add.w	#16,d3		y2=yps+16
	bsr	drawwall		Draw wall
	move.w	a6,d1		Restore d1
	move.w	a5,d0		Restore d0
	move.l	(a7)+,a1		Restore a1
	move.w	(a7)+,d7		Restore d7
	bra	lwallr		Return

	*End of block calculation routines

	*Start of wall calculation routines

drawwall	move.l	#trig+720,a2	Address of trig table
	move.w	face,d7		Which way are we facing?
	add.w	d7,d7		Multiply by 2
	add.w	d7,a2		Find place in trig table
	move.w	(a2),d6		Get trig angle 1
	move.w	180(a2),d7	Get trig angle 2
	move.w	d0,d4		Get x1
	muls.w	d7,d4		Multiply by trig 2
	move.w	d1,d5		Get y1
	muls.w	d7,d5		Multiply by trig 2
	muls.w	d6,d0		x1=x1*si
	sub.l	d5,d0		x1=x1-(y1*co)
	asr.l	#4,d0		Scale down
	muls.w	d6,d1		y1=y1*si
	add.l	d4,d1		y1=y1+(x1*co)
	asr.l	#4,d1		Scale down
	move.w	d2,d4		Get x2
	muls.w	d7,d4		Multiply by trig 2
	move.w	d3,d5		Get y2
	muls.w	d7,d5		Multiply by trig 2
	muls.w	d6,d2		x2=x2*si
	sub.l	d5,d2		x2=x2-(y2*co)
	asr.l	#4,d2		Scale down
	muls.w	d6,d3		y2=y2*si
	add.l	d4,d3		y2=y2+(x2*co)
	asr.l	#4,d3		Scale down
	tst.w	d1		Is wall behind us?
	bge	behind1		Yes, goto routine
behind1r	tst.w	d1		Is left point visible
	blt	calcp1		Yes, calculate position
p1fail	move.w	#255,d4		No, set to 255
calcp1r	tst.w	d3		Is right point visible
	blt	calcp2		Yes, calculate position
p2fail	move.w	#255,d6		No, set to 255	
calcp2r	cmp.w	#255,d4		Do we know point 1?
	beq	nop1		No, check point 2
	cmp.w	#255,d6		Do we know point 2?
	beq	onlyp1		No, only know point 1

bothp	cmp.w	d4,d6		Is wall visable?
	beq	return		No, return
	blt	invboth		Is wall back to front?
invbothr	move.l	#screenh,a2	Address of screen grid
	move.w	d5,d0		Get initial height
	lsl.w	#8,d0		Scale up for accuracy
	move.w	d7,d1		Get sy2
	sub.w	d5,d1		sy2=sy2-sy1
	move.w	d6,d2		Get sx2
	sub.w	d4,d2		sx2=sx2-sx1
	asl.w	#8,d1		Find gradient
	ext.l	d1		Prepare for division
	divs.w	d2,d1		Store gradient in d1
	move.w	d4,d2		Set up a counter
	clr.w	d4		Clear d4
	move.b	2304(a1),d4	Get texture type
	sub.w	#1,d4		Count from zero
	lsl.w	#8,d4		Scale up
	tst.w	backface		Which side of door?
	bne	backbp		Back face
	move.l	#texture_a,a0	Texture layout table
	add.w	d4,a0		Find place in table
	move.l	#divide,a1	Address of divide table
	clr.w	d4		Set up texture xpos
	bsr	shifttext		Shift texture
bploop	move.w	d0,d3		Get height
	lsr.w	#8,d3		Scale back down
	cmp.w	#75,d3		Too big?
	bgt	bigbp		Yes reduce
	move.w	d3,d7		Get height
	add.w	d7,d7		Find place in table
	add.w	(a1,d7),d4	Move up texture xpos
	cmp.w	2(a0),d4		Next texture yet?
	bge	ntbp		Yes, goto routine
	cmp.b	(a2,d2),d3	Place in grid?
	bgt	bpgrid		Yes, goto routine
	add.w	d1,d0		Increase height
	add.w	#1,d2		Move up counter	
	cmp.w	d6,d2		End of loop?
	ble	bploop		No, loop back around
	rts			Return

backbp	move.l	#texture_b,a0	Texture layout table
	add.w	d4,a0		Find place in table
	move.l	#divide,a1	Address of divide table
	clr.w	d4		Set up texture xpos
	bra	bploop		Draw texture

bigbp	move.w	#75,d3		Maximum height
	add.w	150(a1),d4	Move up texture xpos
	cmp.w	2(a0),d4		Next texture yet?
	bge	ntbp		Yes, goto routine
	cmp.b	(a2,d2),d3	Place in grid?
	bgt	bpgrid		Yes, goto routine
	add.w	d1,d0		Increase height
	add.w	#1,d2		Move up counter
	cmp.w	d6,d2		End of loop?
	ble	bploop		No, loop back around
	rts			Return

ntbp	addq.l	#4,a0		Move to next texture
	cmp.b	(a2,d2),d3	Place in grid?
	bgt	bpgrid		Yes, goto routine
	add.w	d1,d0		Increase height
	add.w	#1,d2		Move up counter
	cmp.w	d6,d2		End of loop?
	ble	bploop		No, loop back around
	rts			Return

bpgrid	move.b	d3,(a2,d2)	Place height in grid
	lea	291(a2),a2	Go to other table
	move.b	(a0),(a2,d2)	Place texture in grid
	lea	-291(a2),a2	Move back to first table
	add.w	d1,d0		Increase height
	add.w	#1,d2		Move up counter
	cmp.w	d6,d2		End of loop?
	ble	bploop		No, loop back around
	rts			Return

invboth	exg	d4,d6		Swap sx1 and sx2
	exg	d5,d7		Swap sy1 and sy2
	bra	invbothr		Return

nop1	cmp.w	#255,d6		Do we know point 2?
	beq	nopoints		No, don't know any points

onlyp2	move.w	d1,d4		Get y1
	sub.w	d3,d4		Get y1-y2
	ext.l	d4		Extend to long word
	asl.w	#3,d4		Scale up
	asl.l	#8,d4		Scale up
	muls.w	d0,d3		Get y2*x1
	muls.w	d2,d1		Get y1*x2
	sub.l	d3,d1		Get (y1*x2)-(y2*x1)
	asr.l	#4,d1		Scale down
	divs.w	d1,d4		Find gradient
	exg	d6,d0		Get xp
	move.w	d7,d1		Get yp
	lsl.w	#8,d1		Scale up
	move.w	d4,d7		Get gradient
	tst.w	d6		Draw to left?
	blt	drawleft		Yes, goto routine
	bra	drawright		No, draw right

onlyp1	move.w	d3,d7		Get y2
	sub.w	d1,d7		Get y2-y1
	ext.l	d7		Extend to long word
	asl.w	#3,d7		Scale up
	asl.l	#8,d7		Scale up
	muls.w	d0,d3		Get y2*x1
	muls.w	d2,d1		Get y1*x2
	sub.l	d1,d3		Get (y2*x1)-(y1*x2)
	asr.l	#4,d3		Scale down
	divs.w	d3,d7		Find gradient
	move.w	d4,d0		Get xp
	move.w	d5,d1		Get yp
	lsl.w	#8,d1		Scale up
	tst.w	d2		Draw to left?
	blt	drawleft		Yes, goto routine
	bra	drawright		No, draw right

nopoints	tst.w	d0		Check sign of x1
	blt	negx1		Negative
	bgt	posx1		Positive
nopoints2	tst.w	d1		Is wall behind us?
	bgt	return		Yes, return
	tst.w	d3		Is wall behind us?
	bgt	return		Yes, return
	move.l	#screenh,a2	Address of wall heights
	move.w	#59,d0		Set up counter
noploop	move.l	#$4b4b4b4b0,(a2)+	Set 4 bytes
	dbf	d0,noploop	Loop back around
	move.b	#$4b,(a2)+	Set last byte
	rts			Return

negx1	tst.w	d2		Check sign of x2
	blt	return		If negative return
	bra	nopoints2		If positive continue
posx1	tst.w	d2		Check sign of x2
	bgt	return		If positive return
	bra	nopoints2		If negative continue

shifttext	tst.w	tshift		Any texture shift
	beq	return		No, return
	move.w	tshift,d4		Get texture shift
st1loop	cmp.w	2(a0),d4		New texture type?
	blt	return		No, return
	addq.l	#4,a0		Move to next texture
	bra	st1loop		Check again

drawleft	move.l	#screenh,a2	Address of screen grid
	clr.w	d4		Clear d4
	move.b	2304(a1),d4	Get texture type
	sub.w	#1,d4		Count from zero
	lsl.w	#8,d4		Scale up
	tst.w	backface		Which face of door
	bne	backdl		Back face
	move.l	#texture_b,a0	Texture layout table
	add.w	d4,a0		Find place in table
	move.l	#divide,a1	Address of divide table
	clr.w	d4		Set up texture xpos
dlloop	move.w	d1,d2		Get height
	lsr.w	#8,d2		Scale down
	tst.w	d2		Anything to draw?
	beq	return		No, return
	cmp.w	#75,d2		Too big
	bgt	toobigl		Yes, reduce size
	move.w	d2,d6		Get height
	add.w	d6,d6		Find place in table
	add.w	(a1,d6),d4	Move up texture xpos
	cmp.w	2(a0),d4		Next texture yet?
	bge	ntdl		Yes, goto routine
	cmp.b	(a2,d0),d2	Place in grid?
	bgt	dlgrid		Yes, goto routine
	sub.w	d7,d1		Move up height
	sub.w	#1,d0		Move up counter
	tst.w	d0		End of loop
	bge	dlloop		No loop back around
	rts			Return

backdl	move.l	#texture_a,a0	Texture layout table
	add.w	d4,a0		Find place in table
	move.l	#divide,a1	Address of divide table
	clr.w	d4		Set up texture xpos
	bsr	shifttext		Shift texture
	bra	dlloop		Draw texture

toobigl	clr.w	d7		zero gradient
	move.w	#75,d2		Reduce size
	move.w	150(a1),d4	Move up texture xpos
	cmp.w	2(a0),d4		Next texture yet?
	bge	ntdl		Yes, goto routine
	cmp.b	(a2,d0),d2	Place in grid?
	bgt	dlgrid		Yes, goto routine
	sub.w	d7,d1		Move up height
	sub.w	#1,d0		Move up counter
	tst.w	d0		End of loop
	bge	dlloop		No loop back around
	rts			Return

ntdl	addq.l	#4,a0		Move up texture counter
	cmp.b	(a2,d0),d2	Place in grid?
	bgt	dlgrid		Yes, goto routine
	sub.w	d7,d1		Move up height
	sub.w	#1,d0		Move up counter
	tst.w	d0		End of loop
	bge	dlloop		No loop back around
	rts			Return

dlgrid	move.b	d2,(a2,d0)	Place value in grid
	lea	291(a2),a2	Move to other grid
	move.b	(a0),(a2,d0)	Place texture in grid
	lea	-291(a2),a2	Move back to first grid
	sub.w	d7,d1		Move up height
	sub.w	#1,d0		Move up counter
	tst.w	d0		End of loop
	bge	dlloop		No loop back around
	rts			Return

drawright	move.l	#screenh,a2	Address of screen grid
	clr.w	d4		Clear d4
	move.b	2304(a1),d4	Get texture type
	sub.w	#1,d4		Count from zero
	lsl.w	#8,d4		Scale up
	tst.w	backface		Which face
	bne	backdr		Back face
	move.l	#texture_a,a0	Texture layout table
	add.w	d4,a0		Find place in table
	move.l	#divide,a1	Address of divide table
	clr.w	d4		Set up texture xpos
	bsr	shifttext		shift texture
drloop	move.w	d1,d2		Get height
	lsr.w	#8,d2		Scale down
	tst.w	d2		Anything to draw?
	beq	return		No, return
	cmp.w	#75,d2		Too big
	bgt	toobigr		Yes, reduce size
	move.w	d2,d6		Get height
	add.w	d6,d6		Find place in table
	add.w	(a1,d6),d4	Move up texture xpos
	cmp.w	2(a0),d4		Next texture yet?
	bge	ntdr		Yes, goto routine
	cmp.b	(a2,d0),d2	Place in grid?
	bgt	drgrid		Yes, goto routine
	add.w	d7,d1		Move up height
	add.w	#1,d0		Move up counter
	cmp.w	#240,d0		End of loop
	ble	drloop		No loop back around
	rts			Return

backdr	move.l	#texture_b,a0	Texture layout table
	add.w	d4,a0		Find place in table
	move.l	#divide,a1	Address of divide table
	clr.w	d4		Set up texture xpos
	bra	drloop		Draw texture

toobigr	clr.w	d7		zero gradient
	move.w	#75,d2		Reduce size
	move.w	150(a1),d4	Move up texture xpos
	cmp.w	2(a0),d4		Next texture yet?
	bge	ntdr		Yes, goto routine
	cmp.b	(a2,d0),d2	Place in grid?
	bgt	drgrid		Yes, goto routine
	add.w	d7,d1		Move up height
	add.w	#1,d0		Move up counter
	cmp.w	#240,d0		End of loop
	ble	drloop		No loop back around
	rts			Return

ntdr	addq.l	#4,a0		Move up texture counter
	cmp.b	(a2,d0),d2	Place in grid?
	bgt	drgrid		Yes, goto routine
	add.w	d7,d1		Move up height
	add.w	#1,d0		Move up counter
	cmp.w	#240,d0		End of loop
	ble	drloop		No loop back around
	rts			Return

drgrid	move.b	d2,(a2,d0)	Place in grid
	lea	291(a2),a2	Move to other grid
	move.b	(a0),(a2,d0)	Place texture in grid
	lea	-291(a2),a2	Move back to first grid
	add.w	d7,d1		Move up height
	add.w	#1,d0		Move up counter
	cmp.w	#240,d0		End of loop
	ble	drloop		No loop back around
	rts			Return

behind1	tst.w	d3		Is wall behind us?
	blt	behind1r		No, return
	rts			Return

calcp1	move.w	d0,d4		Get x1
	muls.w	#90,d4		Multiply by 90
	divs.w	d1,d4		Divide by y1
	neg.w	d4		Make positive
	add.w	#120,d4		Find relative to centre
	tst.w	d4		Is d4 out of range?
	blt	p1fail		Yes, return
	cmp.w	#240,d4		Is d4 out of range?
	bgt	p1fail		Yes, return
	move.l	#11520,d5		Calculate sy1
	divs.w	d1,d5		Divide by y1
	neg.w	d5		Make positive
	bra	calcp1r		Return

calcp2	move.w	d2,d6		Get x2
	muls.w	#90,d6		Multiply by 90
	divs.w	d3,d6		Divide by y1
	neg.w	d6		Make positive
	add.w	#120,d6		Find relative to centre
	tst.w	d6		Is d6 out of range?
	blt	p2fail		Yes, return
	cmp.w	#240,d6		Is d6 out of range?
	bgt	p2fail		Yes, return
	move.l	#11520,d7		Calculate sy1
	divs.w	d3,d7		Divide by y1
	neg.w	d7		Make positive
	bra	calcp2r		Return

	*End of wall calculation routines
	*End of screen calculation routines

	*Start of screen draw routines

drawscrn	jsr	drawback		Draw background
	bsr	drawwalls		Draw walls
flipadr	jsr	flipscrn		Flip screen over
	bsr	drawmon		Draw monsters
	bsr	dgrenade		Draw grenades
	bsr	drawgun		Draw gun
	bsr	cpanel		Update control panel
	bsr	drawmes		Draw messages
	bsr	drawradar		Draw radar
	bsr	drawmap		Draw mapper display
	bsr	scrnswap		Reveal screen
	bsr	cpanel		Update other control panel
	clr.w	hchange		Reset health change variable
	rts			Return

drawmap	tst.w	mapper		Have we got a mapper?
	beq	return		No, return

	move.l	map1,a0		Address of map
	clr.l	d2		Clear d2
	move.w	xpos,d2		Get xposition
	sub.w	#14,d2		Subtract 14
	lsr.w	#5,d2		Divide by 32
	move.w	ypos,d3		Get yposition
	sub.w	#14,d3		Subtract 14
	and.w	#$ffe0,d3		Round off
	add.w	d3,d3		Multiply by 2
	add.w	d3,d2		Find pos in map
	add.l	d2,a0		Find correct address
	move.l	mapmap,a1		Address of explored map
	add.l	d2,a1		Find correct address

	move.b	-65(a0),-65(a1)	Copy across inside ring
	move.b	-64(a0),-64(a1)	Of surrounding area
	move.b	-63(a0),-63(a1)
	move.b	-1(a0),-1(a1)
	move.b	(a0),(a1)
	move.b	1(a0),1(a1)
	move.b	63(a0),63(a1)
	move.b	64(a0),64(a1)
	move.b	65(a0),65(a1)

	tst.b	-65(a0)		Copy top left corner?
	bne	nomaptl		No, skip copy commands
	move.b	-130(a0),-130(a1)
	move.b	-129(a0),-129(a1)
	move.b	-66(a0),-66(a1)
nomaptl	tst.b	-64(a0)		Copy top middle?
	bne	nomaptm		No, skip copy commands
	move.b	-128(a0),-128(a1)
nomaptm	tst.b	-63(a0)		Copy top right?
	bne	nomaptr		No, skip copy commands
	move.b	-127(a0),-127(a1)
	move.b	-126(a0),-126(a1)
	move.b	-62(a0),-62(a1)
nomaptr	tst.b	-1(a0)		Copy middle left?
	bne	nomapml		No, skip copy commands
	move.b	-64(a0),-64(a1)
nomapml	tst.b	1(a0)		Copy middle right?
	bne	nomapmr		No, skip copy commands
	move.b	64(a0),64(a1)
nomapmr	tst.b	63(a0)		Copy bottom left?
	bne	nomapbl		No, skip copy commands
	move.b	62(a0),62(a1)
	move.b	126(a0),126(a1)
	move.b	127(a0),127(a1)
nomapbl	tst.b	64(a0)		Copy bottom middle?
	bne	nomapbm		No, skip copy commands
	move.b	128(a0),128(a1)
nomapbm	tst.b	65(a0)		Copy bottom right?
	bne	nomapbr		No, skip copy commands
	move.b	66(a0),66(a1)
	move.b	129(a0),129(a1)
	move.b	130(a0),130(a1)
nomapbr
	move.l	mapmap,a0		Address of map to draw
	clr.l	d2		Clear d2
	move.w	xpos,d2		Get xposition
	sub.w	#14,d2		Subtract 14
	lsr.w	#5,d2		Divide by 32
	move.w	ypos,d3		Get yposition
	sub.w	#14,d3		Subtract 14
	and.w	#$ffe0,d3		Round off
	add.w	d3,d3		Multiply by 2
	add.w	d3,d2		Find pos in map
	add.l	d2,a0		Find correct address
	lea	-263(a0),a0	Centre map on our position

	move.l	screen1,a1	Address of screen
	lea	24828(a1),a1	Move to first square of mapper
	move.w	#9,d0		Set up y counter
mapyloop	move.w	#7,d1		Set up x counter
mapxloop	move.b	(a0)+,d2		Get square from map
	cmp.b	#2,d2		Is it a door?
	beq	mapdoor		Yes, show on map
	cmp.b	#11,d2		Is it a door?
	beq	mapdoor		Yes, show on map
	cmp.b	#13,d2		Is it a door?
	beq	mapdoor		Yes, show on map
	tst.b	d2		Anything there?
	beq	mapblack		No, set to black
	move.b	#$f0,(a1)		Set square to grey
	move.b	#$f0,160(a1)	Set next line to grey
	move.b	#$f0,320(a1)	Set next line to grey
	move.b	#$f0,480(a1)	Set next line to grey

drawmapr	move.b	(a0)+,d2		Get square from map
	cmp.b	#2,d2		Is it a door?
	beq	mapdoor2		Yes, show on map
	cmp.b	#11,d2		Is it a door?
	beq	mapdoor2		Yes, show on map
	cmp.b	#13,d2		Is it a door?
	beq	mapdoor2		Yes, show on map
	tst.b	d2		Anything there?
	beq	drawmap2r		No, set to black
	or.b	#$f,(a1)		Set square to grey
	or.b	#$f,160(a1)	Set next line to grey
	or.b	#$f,320(a1)	Set next line to grey
	or.b	#$f,480(a1)	Set next line to grey
drawmap2r	addq.l	#1,a1		Move up screen address
	move.l	a1,d7		Get current screen address
	btst	#0,d7		Into next word?
	beq	mapword		Yes, modify address
mapwordr	dbf	d1,mapxloop	Draw next square
	lea	608(a1),a1	Move down to next row
	lea	48(a0),a0		Move down to next row
	dbf	d0,mapyloop	Draw next line
	move.w	#78,d0		Destination x
	move.w	#173,d1		Destination y
	clr.w	d2		Draw dot red
	bsr	radardot		Show position on map
	rts			Return

mapword	addq.l	#6,a1		Move up screen address
	bra	mapwordr		Return

mapblack	clr.b	(a1)		Set square to black
	clr.b	160(a1)		Set next line to black
	clr.b	320(a1)		Set next line to black
	clr.b	480(a1)		Set next line to black
	bra	drawmapr		Return
mapdoor	clr.b	(a1)		Set line to black
	move.b	#$60,160(a1)	Set edge to black
	move.b	#$60,320(a1)	Set edge to black
	clr.b	480(a1)		Set line to black
	bra	drawmapr		Return	
mapdoor2	or.b	#6,160(a1)	Set edge to black
	or.b	#6,320(a1)	Set edge to black
	bra	drawmap2r		Return	

drawradar	tst.w	radar		Have we got a radar?
	beq	return		No, return
	move.l	screen1,a0	Address of screen
	add.l	#24904,a0		Address of centre of radar
	move.w	#39,d0		Set up a line counter
radarline	rept	8		Clear whole line
	clr.l	(a0)+		Clear a bit of radar
	endr			Clear some more
	lea	128(a0),a0	Move down to next line
	dbf	d0,radarline	Clear next line
	move.w	#240,d0		X centre of radar
	move.w	#175,d1		Y centre of radar
	clr.w	d2		Draw red
	bsr	radardot		Show dot on radar
	tst.w	nummon		Any monsters?
	beq	return		No, return
	move.w	nummon,d7		Set up a counter
	sub.w	#1,d7		Count from zero

	move.l	#trig+720,a2	Address of trig table
	move.w	face,d0		Which way are we facing?
	add.w	d0,d0		Multiply by 2
	add.w	d0,a2		Find place in trig table
	move.w	(a2),d5		Get trig angle 1
	move.w	180(a2),d6	Get trig angle 2

	move.l	#montable,a1	Address of monster table
radarloop	move.w	(a1)+,d0		Get monster xpos
	sub.w	xpos,d0		Find relative to us
	asr.w	#2,d0		Scale down x distance
	move.w	(a1)+,d1		Get monster ypos
	sub.w	ypos,d1		Find relative to us
	asr.w	#2,d1		Scale down y distance

	move.w	d0,d3		Get x
	muls.w	d6,d3		x=x*co
	move.w	d1,d4		Get y
	muls.w	d6,d4		y=y*co
	muls.w	d5,d1		y=y*si
	add.l	d3,d1		y=y+(x*co)
	asr.l	#4,d1		Scale down
	asr.l	#5,d1		Scale down
	muls.w	d5,d0		x=x*si
	sub.l	d4,d0		x=x-(y*co)
	asr.l	#4,d0		Scale down
	asr.l	#5,d0		Scale down

	move.w	(a1)+,d2		Get monster frame number
	cmp.w	#125,d2		Bat activator?
	beq	nextradar		Yes, don't draw

	cmp.w	#-30,d0		Out of range?
	blt	nextradar		Yes, check next monster
	cmp.w	#30,d0		Out of range?
	bgt	nextradar		Yes, check next monster
	cmp.w	#-18,d1		Out of range?
	blt	nextradar		Yes, check next monster
	cmp.w	#18,d1		Out of range?
	bgt	nextradar		Yes, check next monster

	add.w	#240,d0		Find final x coordinate
	add.w	#175,d1		Find final y coordinate
	bsr	radardot		Show monster on radar
nextradar	addq.l	#2,a1		Move up monster address
	dbf	d7,radarloop	Check next monster
	rts			Return

radardot	move.l	screen1,a0	Destination address
	lsl.w	#5,d1		Scale up y coordinate
	add.w	d1,a0		Add onto address
	add.w	d1,d1		Scale up y coordinate
	add.w	d1,d1		Scale up y coordinate
	add.w	d1,a0		Add onto address
	move.w	d0,d1		Make copy of x coordinate
	and.w	#$f,d1		Find shift required	
	neg.w	d1		Subtract from 7
	add.w	#7,d1		Since each word is stored backwards
	and.w	#$fff0,d0		Find x coordinate
	lsr.w	#1,d0		Scale down x coordinate
	add.w	d0,a0		Add onto address
	tst.w	d1		Into next byte?
	blt	nextrbyte		Yes, adjust address
	cmp.w	#111,d2		Draw green?
	bgt	greendot		Yes, goto routine
greendotr	bclr.b	d1,(a0)		Clear 1st bitplane
	bset.b	d1,2(a0)		Set 2nd bitplane
	bset.b	d1,4(a0)		Set 3rd bitplane
	bset.b	d1,6(a0)		Set 4th bitplane
	rts			Return
nextrbyte	add.w	#8,d1		Adjust shift required
	addq.l	#1,a0		Adjust destination address
	cmp.w	#111,d2		Draw green?
	bgt	greendot		Yes, goto routine
	bclr.b	d1,(a0)		Clear 1st bitplane
	bset.b	d1,2(a0)		Set 2nd bitplane
	bset.b	d1,4(a0)		Set 3rd bitplane
	bset.b	d1,6(a0)		Set 4th bitplane
	rts			Return

greendot	cmp.w	#124,d2		Is it a missile?
	bgt	greendotr		Yes, don't draw it green
	bset.b	d1,(a0)		Set 1st bitplane
	bset.b	d1,2(a0)		Set 2nd bitplane
	bset.b	d1,4(a0)		Set 3rd bitplane
	bset.b	d1,6(a0)		Set 4th bitplane
	rts			Return

cpanel	bsr	timechck		Check for change in time limit
	tst.w	hchange		Any change in health?
	beq	return		No, return
	move.w	health,d7		Get current health
	move.w	d7,d6		Copy into d6
	ext.l	d6		Ensure correct division
	divs.w	#100,d6		Divide by 100
	move.w	#144,d0		X-coordinate
	move.w	#165,d1		Y-coordinate
	bsr	bignum		Draw it
	mulu.w	#100,d6		Multiply d6 by 100
	neg.w	d6		Make negative
	add.w	d7,d6		Find second digit of number
	move.w	d6,d7		Copy to d7
	ext.l	d6		Ensure correct division
	divs.w	#10,d6		Divide by 10
	move.w	#152,d0		X-coordinate
	move.w	#165,d1		Y-coordinate
	bsr	bignum		Draw it
	mulu.w	#10,d6		Multiply d6 by 10
	neg.w	d6		Make negative
	add.w	d7,d6		Find last digit of number
	move.w	#160,d0		X-coordinate
	move.w	#165,d1		Y-coordinate
	bsr	bignum		Draw it
	rts			Return

timechck	cmp.l	#200,$4ba		Check system clock
	bgt	chngtime		Move down time limit?
	rts			No, return
resetclck	clr.l	$4ba		Reset system clock
	rts			Return

chngtime	sub.l	#200,$4ba		Move clock back one second
	cmp.l	#200,$4ba		Still reading more than 1 sec?
	bgt	resetclck		Yes, reset it
	sub.w	#1,time		Decrease remaining time
	move.w	time,d5		Get remaining time
	ext.l	d5		Extend to long word
	divu.w	#60,d5		Find number of minutes
	move.w	#143,d6		X-coordinate
	move.w	#190,d7		Y-coordinate
	bsr	showcount		Update control panel
	move.w	time,d5		Get remaining time
	ext.l	d5		Extend to long word
	divu.w	#60,d5		Find number of minutes
	mulu.w	#60,d5		Convert to seconds
	neg.w	d5		And subtract from total
	add.w	time,d5		To find number of seconds
	move.w	#161,d6		X-coordinate
	move.w	#190,d7		Y-coordinate
	bsr	showcount		Update control panel
	tst.w	time		Out of time?
	beq	timeout		Yes, goto routine
	rts			Return

timeout	clr.w	health		Gameover
	clr.w	hchange		Prevent control panel update
	rts			Return

bignum	clr.w	d2		Width of sprite
	move.w	#7,d3		Height of sprite
	move.l	screen1,a1	Dest address
	move.l	bordicon,a0	Source address
	move.l	a0,a2		Mask address
	move.l	#numtable,a4	Find local address
	move.w	d6,d4		Get number to draw
	add.w	d4,d4		Multiply by 4
	add.w	d4,d4		To find place in table
	add.l	(a4,d4),a0	Find correct source address
	lea	5560(a2),a2	Find correct mask address
	bsr	graphic3		Draw it
	rts			Return

smallnum	movem.w	d4-d5,-(sp)	Preserve registers
	clr.w	d2		Width of sprite
	move.l	#$f0000,a1	Dest address
	move.l	bordicon,a0	Source address
	move.l	a0,a2		Mask address
	move.l	#snumtable,a4	Find local address
	move.w	d4,d3		Get number to draw
	add.w	d3,d3		Multiply by 4
	add.w	d3,d3		To find place in table
	add.l	(a4,d3),a0	Find correct source address
	lea	2040(a2),a2	Find correct mask address
	move.w	#5,d3		Height of sprite
	movem.l	a0-a2/d0-d3,-(sp)	Preserve registers
	bsr	graphic3		Draw it
	movem.l	(sp)+,a0-a2/d0-d3	Restore registers
	add.l	#$8000,a1		Address of screen 2
	bsr	graphic3		Draw it
	movem.w	(sp)+,d4-d5	Restore registers
	rts			Return

drawgun	move.w	guntype,d0	Icon number
	move.l	gunpos,a0		Position of gun
	cmp.l	#ranim,gunpos	Reload animation?
	bge	movegun		Yes, don't override
	tst.w	movement		Have we moved?
	beq	nogunanim		No, don't wobble gun
movegun	add.l	#2,gunpos		Move to next animation
nogunanim	move.w	(a0),d1		Get vertical offset
	cmp.w	#42,d1		Reload sound effect?
	beq	reloadsnd		Yes, goto routine
	cmp.w	#77,d1		Change gun?
	beq	gunswitch		Yes, goto routine
rsr	cmp.w	#-1,d1		Loop animation yet?
	beq	loopgun		Yes, goto routine
loopgunr	move.l	screen1,a0	Destination address
	lea	23912(a0),a0	Draw gun in centre
	bsr	drawicon		Draw it
	rts			Return
loopgun	clr.w	d1		Reset position variable
	move.l	#gunanim,gunpos	Reset animation pointer
	bra	loopgunr		Return

gunswitch	move.w	weapon,d5		Get weapon type
	cmp.w	#1,d5		Fist?
	beq	icon2		Yes, draw icon 2
	cmp.w	#2,d5		Knife?
	beq	icon3		Yes, draw icon 3
	cmp.w	#3,d5		Pistol?
	beq	icon0		Yes, draw icon 0
	cmp.w	#4,d5		Machine gun?
	beq	icon4		Yes, draw icon 4
	cmp.w	#5,d5		Rocket launcher?
	beq	icon6		Yes, draw icon 6
	cmp.w	#6,d5		Plasma gun?
	beq	icon8		Yes, draw icon 8
	bra	rsr		Return

icon0	clr.w	guntype		Change icon
	clr.w	d0		Change icon
	clr.w	withdraw		Select correct ypos
	move.w	#1,damage		Strength of weapon
	bra	rsr		Return
icon2	move.w	#2,guntype	Change icon
	move.w	#2,d0		Change icon
	move.w	#25,withdraw	Select correct ypos
	move.w	#1,damage		Strength of weapon
	bra	rsr		Return
icon3	move.w	#3,guntype	Change icon
	move.w	#3,d0		Change icon
	move.w	#25,withdraw	Select correct ypos
	move.w	#2,damage		Strength of weapon
	bra	rsr		Return
icon4	move.w	#4,guntype	Change icon
	move.w	#4,d0		Change icon
	clr.w	withdraw		Select correct ypos
	move.w	#1,damage		Strength of weapon
	bra	rsr		Return
icon6	move.w	#6,guntype	Change icon
	move.w	#6,d0		Change icon
	clr.w	withdraw		Select correct ypos
	move.w	#10,damage	Strength of weapon
	bra	rsr		Return
icon8	move.w	#8,guntype	Change icon
	move.w	#8,d0		Change icon
	clr.w	withdraw		Select correct ypos
	move.w	#1,damage		Strength of weapon
	bra	rsr		Return

reloadsnd	move.b	#0,$fffffa07.w	Stop sample
	move.l	samadr,d5		Address of samples
	add.l	#100156,d5	Address of sample
	move.l	d5,samdata	Pass to routine
	move.w	#2395,sampos	Size of sample
	clr.w	volume		Maximum volume
	or.b	#$20,$fffffa07.w	Play sample
	bra	rsr		Return

drawicon	move.l	icons,a1		Address of icon table
	add.w	d0,d0		Multiply icon number
	add.w	d0,d0		By four, and add
	add.w	d0,a1		Onto table address
	add.w	d0,d0		Multiply icon number by 2
	add.w	d0,a1		Find position in table
	move.w	(a1)+,d2		Get width
	sub.w	#1,d2		Count from zero
	cmp.w	#3,d2		Move back screen address?
	beq	xtrawide		Yes, goto routine
xtrawider	move.w	(a1)+,d3		Get height
	sub.w	d1,d3		Correct using vertical offset
	sub.w	withdraw,d3	Allow for close range weapons
	sub.w	#1,d3		Count from zero
	tst.w	d3		Anything to draw?
	blt	return		No, return
	move.l	(a1)+,a2		Mask address
	move.l	(a1)+,a3		Graphic address
	move.w	d3,d1		Get height
	lsl.w	#5,d1		Multiply height by 32
	sub.w	d1,a0		Subtract from screen address
	add.w	d1,d1		Multiply height
	add.w	d1,d1		By 4 more
	sub.w	d1,a0		Find final screen address
	move.w	d2,d1		Get width
	lsl.w	#3,d1		Multiply by 8
	neg.w	d1		Make negative
	add.w	#152,d1		Find dest y increment
iconyloop	move.w	d2,d6		Width of graphic
iconxloop	move.w	(a2)+,d0		Get word of mask
	and.w	d0,(a0)		Copy onto screen
	and.w	d0,2(a0)		2nd bitplane
	and.w	d0,4(a0)		3rd bitplane
	and.w	d0,6(a0)		4th bitplane
	rept	4		4 bit planes
	move.w	(a3)+,d0		Get word of graphic
	or.w	d0,(a0)+		Copy onto screen
	endr			Copy next bitplane
	dbf	d6,iconxloop	Copy next word
	add.w	d1,a0		Move up screen address
	dbf	d3,iconyloop	Copy next line
	rts			Return

xtrawide	subq.l	#8,a0		Move back screen address
	bra	xtrawider		Return

drawmes	tst.w	mesc		Any message?
	beq	return		No, return
	sub.w	#1,mesc		Decrease message counter
	move.w	mesc,d0		Get message counter
	btst.l	#0,d0		Draw this time?
	bne	return		No, return

	move.l	icons2,a1		Address of icon table
	move.w	mesn,d0		Get icon number
	add.w	d0,d0		Multiply icon number
	add.w	d0,d0		By four, and add
	add.w	d0,a1		Onto table address
	add.w	d0,d0		Multiply icon number by 2
	add.w	d0,a1		Find position in table
	move.w	(a1)+,d2		Get width
	sub.w	#1,d2		Count from zero
	move.w	(a1)+,d3		Get height
	sub.w	#1,d3		Count from zero
	move.l	(a1)+,a2		Mask address
	move.l	(a1)+,a3		Graphic address
	move.l	screen1,a0	Destination address
	lea	8064(a0),a0	Draw in centre of screen
	move.w	d2,d1		Get width
	lsl.w	#3,d1		Multiply by 8
	neg.w	d1		Make negative
	add.w	#152,d1		Find dest y increment
	bra	iconyloop		Draw it

dgrenade	tst.w	grenadec		Any grenades
	beq	return		No, return
	sub.w	#1,grenadec	Decrease grenade count
	cmp.w	#18,grenadec	Draw big grenade?
	beq	biggren		Yes, goto routine
	cmp.w	#17,grenadec	Draw medium grenade?
	beq	midgren		Yes, goto routine
	rts			Return

biggren	move.l	icons2,a1		Address of icon table
	move.w	(a1)+,d2		Get width
	sub.w	#1,d2		Count from zero
	move.w	(a1)+,d3		Get height
	sub.w	#1,d3		Count from zero
	move.l	screen1,a0	Destination address
	lea	9024(a0),a0	Draw in centre of screen
	move.l	(a1)+,a2		Mask address
	move.l	(a1)+,a3		Graphic address
	move.w	d2,d1		Get width
	lsl.w	#3,d1		Multiply by 8
	neg.w	d1		Make negative
	add.w	#152,d1		Find dest y increment
	bra	iconyloop		Draw it

midgren	move.l	icons2,a1		Address of icon table
	lea	12(a1),a1		Find correct icon
	move.w	(a1)+,d2		Get width
	sub.w	#1,d2		Count from zero
	move.w	(a1)+,d3		Get height
	sub.w	#1,d3		Count from zero
	move.l	screen1,a0	Destination address
	lea	9824(a0),a0	Draw in centre of screen
	move.l	(a1)+,a2		Mask address
	move.l	(a1)+,a3		Graphic address
	move.w	d2,d1		Get width
	lsl.w	#3,d1		Multiply by 8
	neg.w	d1		Make negative
	add.w	#152,d1		Find dest y increment
	bsr	iconyloop		Draw it

	move.l	#montable,a0	Address of monster table
	move.w	nummon,d6		Get number of monsters
	lsl.w	#3,d6		Multiply by 8
	add.w	d6,a0		Find place in table
	add.w	#1,nummon		Increase number of monsters
	move.w	xpos,(a0)+	Store xposition
	move.w	ypos,(a0)+	Store yposition
	move.w	#128,(a0)+	Set graphic to grenade
	move.w	#51,(a0)+		Sprite type to projectile
	move.w	face,grenadef	Direction of rocket
	move.w	#12160,grenadeh	Height of grenade
	move.w	xpos,d3		X position
	move.w	ypos,d4		Y position
	bsr	mgrenade		Move grenade
	rts			Return

drawwalls	move.l	screen1,a0	Destination address
	lea	17(a0),a0		In centre of screen
	move.l	#screenh,a2	Height of walls
	move.l	#screent,a3	Texture of walls
	move.w	#7,d0		Destination shift
	move.w	#-1,d3		Line type
	move.w	#240,d4		Set up a counter

drawloop	move.b	(a2)+,d1		Get height
	ext.w	d1		Extend d1
	move.b	(a3)+,d2		Get texture
	ext.w	d2		Extend d2
	bsr	tmap		Do tmap line
	neg.w	d3		Change line type
	sub.w	#1,d0		Reduce shift
	cmp.w	#-1,d0		Next byte?
	beq	nextbyte		Yes, alter address
	dbf	d4,drawloop	Draw next line
	rts			return

nextbyte	move.w	#7,d0		Reset shift counter
	move.w	a0,d1		Get address
	btst.l	#0,d1		Next word?
	bne	nextword		Yes, goto routine
	addq.l	#1,a0		Move up address
	dbf	d4,drawloop	Draw next line
	rts			Return
nextword	addq.l	#7,a0		Move up address
	dbf	d4,drawloop	Draw next line
	rts			Return

drawback	move.w	#0,$ff8a20	Source X increment
	move.l	screen1,a0	Get dest address
	lea	16(a0),a0		In centre of screen
	move.l	#backgrnd,a1	Get source address
	rept	4		
	move.l	a0,$ff8a32	Dest address
	move.l	a1,$ff8a24	Source address
	move.w	#75,$ff8a38	Number of lines
	move.b	#192,$ff8a3c	Activate blitter
	addq.l	#2,a0		Move up dest address
	addq.l	#2,a1		Move up source address
	endr
	rts			Return

stback	move.l	screen1,a0	Get dest address
	lea	17(a0),a0		In centre of screen
	move.l	#backgrnd,a1	Get source address
	move.w	#74,d5		Set up line counter
backline	move.w	(a1)+,d0		Get background info
	move.w	(a1)+,d1		Get second bit plane
	move.w	(a1)+,d2		Get third bit plane
	move.w	(a1)+,d3		Get fourth bit plane
	move.b	d0,(a0)		First byte only 8 pixels
	move.b	d1,2(a0)		Set second bit plane
	move.b	d2,4(a0)		Set third bit plane
	move.b	d3,6(a0)		Set fourth bit plane
	addq.l	#7,a0		Move to next 16 pixels
	move.w	#13,d4		Set up a counter
stbkloop	move.w	d0,(a0)+		Copy across background
	move.w	d1,(a0)+		Copy second bit plane
	move.w	d2,(a0)+		Copy third bit plane
	move.w	d3,(a0)+		Copy fourth bit plane
	dbf	d4,stbkloop	Complete all the way across
	and.w	#$7f,(a0)		Last word only 9 pixels
	and.w	#$7f,2(a0)	Mask second bit plane
	and.w	#$7f,4(a0)	Mask third bit plane
	and.w	#$7f,6(a0)	Mask fourth bit plane
	and.w	#$ff80,d0		Get 9 pixels of background
	and.w	#$ff80,d1		Get second bit plane
	and.w	#$ff80,d2		Get third bit plane
	and.w	#$ff80,d3		Get fourth bit plane
	or.w	d0,(a0)		Store on screen
	or.w	d1,2(a0)		Store second bit plane
	or.w	d2,4(a0)		Store second bit plane
	or.w	d3,6(a0)		Store second bit plane
	lea	41(a0),a0		Move to next line
	dbf	d5,backline	Copy across next line
	rts			Return	

stflip	move.l	screen1,a0	Get source address
	lea	17(a0),a0		Top of view window
	move.l	a0,a1		Dest address
	lea	23840(a1),a1	Bottom of view window
	move.w	#74,d5		Set up line counter
flipline	move.b	(a0),(a1)		First byte only 8 pixels
	move.b	2(a0),2(a1)	2nd bit plane
	move.b	4(a0),4(a1)	3rd bit plane
	move.b	6(a0),6(a1)	4th bit plane
	addq.l	#7,a0		Move to next 16 pixels
	addq.l	#7,a1		Move to next 16 pixels
	move.w	#13,d4		Set up a counter
stflloop	move.w	(a0)+,(a1)+	Copy across picture
	move.w	(a0)+,(a1)+	Copy second bit plane
	move.w	(a0)+,(a1)+	Copy third bit plane
	move.w	(a0)+,(a1)+	Copy fourth bit plane
	dbf	d4,stflloop	Complete all the way across
	move.w	(a0),d0		Get last byte
	move.w	2(a0),d1		Get 2nd bit plane
	move.w	4(a0),d2		Get 3rd bit plane
	move.w	6(a0),d3		Get 4th bit plane
	and.w	#$7f,(a1)		Last word only 9 pixels
	and.w	#$7f,2(a1)	Mask second bit plane
	and.w	#$7f,4(a1)	Mask third bit plane
	and.w	#$7f,6(a1)	Mask fourth bit plane
	and.w	#$ff80,d0		Get 9 pixels of graphics
	and.w	#$ff80,d1		Get second bit plane
	and.w	#$ff80,d2		Get third bit plane
	and.w	#$ff80,d3		Get fourth bit plane
	or.w	d0,(a1)		Store on screen
	or.w	d1,2(a1)		Store second bit plane
	or.w	d2,4(a1)		Store second bit plane
	or.w	d3,6(a1)		Store second bit plane
	lea	41(a0),a0		Move down source address
	lea	-279(a1),a1	Move up dest address
	dbf	d5,flipline	Copy next line
	rts			Return

flipscrn	move.w	#8,$ff8a20	Source X increment
	move.l	screen1,a0	Source address
	lea	16(a0),a0		Move up address
	move.l	a0,a1		Dest address
	lea	23840(a1),a1	Move up address
	move.w	#74,d0		Number of lines

fliploop	move.l	a0,$ff8a24	Source address
	move.l	a1,$ff8a32	Dest address
	move.w	#1,$ff8a38	Height
	move.b	#192,$ff8a3c	Activate blitter
	addq.l	#2,a0		Move up source address
	addq.l	#2,a1		Move up dest address
	move.l	a0,$ff8a24	Source address
	move.l	a1,$ff8a32	Dest address
	move.w	#1,$ff8a38	Height
	move.b	#192,$ff8a3c	Activate blitter
	addq.l	#2,a0		Move up source address
	addq.l	#2,a1		Move up dest address
	move.l	a0,$ff8a24	Source address
	move.l	a1,$ff8a32	Dest address
	move.w	#1,$ff8a38	Height
	move.b	#192,$ff8a3c	Activate blitter
	addq.l	#2,a0		Move up source address
	addq.l	#2,a1		Move up dest address
	move.l	a0,$ff8a24	Source address
	move.l	a1,$ff8a32	Dest address
	move.w	#1,$ff8a38	Height
	move.b	#192,$ff8a3c	Activate blitter

	lea	154(a0),a0	Move up source
	lea	-166(a1),a1	Move up dest
	dbf	d0,fliploop	Do next line
	rts			Return

	********************************
	*Texture map routine           *
	*a0=dest address, d0=dest shift*
	*d1=height, d2=texture	 *
	*d3=linetype -1 or 1	 *
	*corrupts a1,a6,d1,d2	 *
	********************************

tmap	tst.w	d1		Any texture?
	beq	return		No, return
	move.l	#textadr,a6	Get texture list
	add.w	d2,d2		Get texture type
	add.w	d2,d2		In d2
	move.l	(a6,d2),a6	Get address of texture
	move.l	texttble,a1	Get texture table
	add.w	d1,d1		Get height
	add.w	d1,d1		In d1
	add.w	d3,d1		Get linetype
	add.w	1(a1,d1),a6	Get routine to run
	move.l	pixplot,d1	Pixel plot routines
	move.w	(a6)+,d1		Get routine to run
	move.l	d1,a1		Move to address register
	jmp	(a1)		Run it

	*End of screen draw routines

	*Start of special screen routines

title	sub.l	#200000,mempos	Request 200K
	move.l	mempos,a0		Destination address
	clr.w	d0		Side 0
	move.w	#23,d1		Track 23
	move.w	#8,d2		Sector 8
	move.l	#148833,d3	Size of file
	move.l	#197882,d4	Unpacked size
	move.w	#24,d5		Depack delay
	pea	(a0)		Store address
	bsr	packload		Load it in
title2	sub.l	#200000,mempos	Request 200K
	move.l	mempos,a0		Destination address
	clr.w	d0		Side 0
	move.w	#5,d1		Track 5
	move.w	#1,d2		Sector 1
	move.l	#35836,d3		Size of file
	move.l	#193405,d4	Unpacked size
	move.w	#24,d5		Depack delay
	move.l	a0,-(sp)		Preserve address
	bsr	packload		Load it in

	move.w	#64,d7		Size of input buffer
	bsr	ckloop		Clear keyboard buffer

	move.l	(sp)+,a0		Restore address
	move.l	a0,d2		Copy into d2
	add.l	#$1c,d2		Move to end of base page
	lea	$1c(a0),a1	Copy into a1
	move.l	a1,a2		Copy into a2
	add.l	2(a0),a2		Pointer to start of program
	add.l	(a2)+,a1		Store in a1
	add.l	d2,(a1)		Modify start address
reloloop2	tst.b	(a2)		All relocated yet?
	beq	endrelo		Yes, return
	moveq.l	#0,d1		Clear d1
reloloop	moveq.l	#0,d0		Clear d0
	move.b	(a2)+,d0		Get address
	cmp.b	#1,d0		Convert it?
	bne	norelloop		Yes, goto routine
	add.w	#$fe,d1		Move to next address
	bra	reloloop		Loop back around
norelloop	add.w	d0,d1		Relocate address
	add.w	d1,a1		New address
	add.l	d2,(a1)		Store it
	bra	reloloop2		Convert next address
endrelo	jsr	(a0)		Run it
	add.l	#200000,mempos	Return memory
	move.w	#1,level		Return to level 1
	bsr	newscore		Reset score
	rts			Return

briefing	bsr	bpalt		Set black palette
	move.l	mempos,samples	Address of samples

	sub.l	#91000,mempos	Request 91000 bytes
	move.l	mempos,a0		Destination address
	move.w	#1,d0		Side 1
	move.w	#69,d1		Track 69
	move.w	#3,d2		Sector 3
	move.l	#16008,d3		Size of file
	move.l	#90334,d4		Unpacked size
	move.w	#24,d5		Depack delay
	bsr	packload		Load it in

	move.w	#64,d7		Size of input buffer
	bsr	ckloop		Clear keyboard buffer

	move.w	level,-(sp)	Level number
	move.l	samples,-(sp)	Address of samples
	move.l	mempos,a0		Address of routine

	move.l	a0,d2		Copy into d2
	add.l	#$1c,d2		Move to end of base page
	lea	$1c(a0),a1	Copy into a1
	move.l	a1,a2		Copy into a2
	add.l	2(a0),a2		Pointer to start of program
	add.l	(a2)+,a1		Store in a1
	add.l	d2,(a1)		Modify start address
brloop2	tst.b	(a2)		All relocated yet?
	beq	endbr		Yes, return
	moveq.l	#0,d1		Clear d1
brloop	moveq.l	#0,d0		Clear d0
	move.b	(a2)+,d0		Get address
	cmp.b	#1,d0		Convert it?
	bne	nobrloop		Yes, goto routine
	add.w	#$fe,d1		Move to next address
	bra	brloop		Loop back around
nobrloop	add.w	d0,d1		Relocate address
	add.w	d1,a1		New address
	add.l	d2,(a1)		Store it
	bra	brloop2		Convert next address

endbr	jsr	(a0)		Run it
	move.w	d0,level		Store level number

	bsr	bpalt		Set black palette
	add.l	#291000,mempos	Return memory
	rts			Return

stopdma	move.b	#0,$ff8901	Stop DMA chip
	rts			Return

showbpic	move.l	screen2,a0	Dest address 1
	move.l	screen1,a1	Dest address 2
	move.l	backpic,a2	Source address
	lea	34(a2),a2		Jump past palette
	move.w	#7999,d0		Set up counter
bpicloop	move.l	(a2)+,d1		Get picture data
	move.l	d1,(a0)+		Copy to screen 1
	move.l	d1,(a1)+		Copy to screen 2
	dbf	d0,bpicloop	Keep copying
	move.l	backpic,a2	Address of palette
	addq.l	#2,a2		In a2
	move.l	a2,-(sp)		Place on stack
	move.w	#6,-(sp)		Function number
	trap	#14		Call XBIOS
	addq.l	#6,sp		Correct stack
	rts			Return

loadquart	sub.l	#11000,mempos	Request 11000 bytes
	move.l	mempos,a0		Destination address
	clr.w	d0		Side 0
	move.w	#3,d1		Track 3
	move.w	#7,d2		Sector 7
	move.l	#2592,d3		Size of file
	move.l	#9952,d4		Unpacked size
	move.w	#24,d5		Unpack delay
	pea	(a0)		Store address
	bsr	packload		Load it in
	move.l	(sp)+,a0		Address of replay routine

relorout	move.l	a0,d2		Copy into d2
	add.l	#$1c,d2		Move to end of base page
	lea	$1c(a0),a1	Copy into a1
	move.l	a1,a2		Copy into a2
	add.l	2(a0),a2		Pointer to start of program
	add.l	(a2)+,a1		Store in a1
	add.l	d2,(a1)		Modify start address
qloop2	tst.b	(a2)		All relocated yet?
	beq	endqloop		Yes, return
	moveq.l	#0,d1		Clear d1
qloop	moveq.l	#0,d0		Clear d0
	move.b	(a2)+,d0		Get address
	cmp.b	#1,d0		Convert it?
	bne	noqloop		Yes, goto routine
	add.w	#$fe,d1		Move to next address
	bra	qloop		Loop back around
noqloop	add.w	d0,d1		Relocate address
	add.w	d1,a1		New address
	add.l	d2,(a1)		Store it
	bra	qloop2		Convert next address
endqloop	move.l	a0,replay		Store address
	rts			Return

playquart	move.l	replay,a5		Address of replayer
	move.l	#0,d0		Initialise replayer
	jsr	(a5)		Run replayer
	move.l	#5,d0		Install replayer
	move.l	output,d1		Select DMA Chip
	jsr	(a5)		Run replayer
	move.l	#1,d0		Start music
	move.l	music,a0		Address of music
	move.l	samples,a1	Address of samples
	jsr	(a5)		Run replayer
	rts			Return

stopquart	move.l	replay,a5		Address of replayer
	move.l	#2,d0		Stop music
	jsr	(a5)		Run replayer
	move.l	#3,d0		De-install player
	jsr	(a5)		Run replayer
	bsr	stopdma		Stop DMA chip
	rts			Return

	*End of special screen routines

	*Start of initialisation routines

init	bsr	super		Supervisor mode
	move.b	#2,$484		Disable key click
	bsr	fastchck		Check for dodgy disk drives
	bsr	logo		Redraw C&D logo
	bsr	stfm		Check for stfm computers
	bsr	initdma		Initialise dma chip
	bsr	loadsam		Initialise sample routine
	bsr	initobj		Initialise objects
	bsr	initmis		Initialise missiles
	bsr	initicon		Initialise icons
	bsr	initbord2		Initialise border icons
	bsr	stopdma		Stop dma chip
	move.l	mempos,memreset	Store memory pointer
	bsr	title		Title screen
	rts			Return

init2	move.b	#$0f,$ff8201	New screen address
	move.b	#$80,$ff8203	New screen address
	bsr	setrepeat		Set keyboard repeat rate
	bsr	briefing		Briefing screen
	bsr	initjoy		Initialise joystick
	bsr	initsam		Initialise sound chip
	bsr	inittmap		Initialise tmap routine
	bsr	initcalc		Init screen-calculation
	bsr	initanim		Initialise animation routines
	bsr	bpalt		Set palette to black
	bsr	initbord		Load and draw border
	bsr	setpalt		Set palette up for game
	bsr	initblit		Initialise blitter
	rts			Return

setrepeat	move.w	#1,-(sp)		No delay before repeating key
	move.w	#1,-(sp)		Repeat rapidly
	move.w	#35,-(sp)		Function number
	trap	#14		Call XBIOS
	addq.l	#6,sp		Correct stack
	rts			Return

super	clr.l	-(sp)		No new stack
	move.w	#$20,-(sp)	Fucntion number
	trap	#1		Call GEMDOS
	addq.l	#6,sp		Correct stack
	rts			Return

resetvars	move.l	#textadr,a0	
	move.w	#33,d0		
reset1	clr.l	(a0)+		Clear addresses
	dbf	d0,reset1
resetv2	move.w	#100,health	Reset health
	move.w	#1,hchange
	move.l	#samdelay,a0	
	move.w	#16,d0
reset2	clr.w	(a0)+		Clear system variables
	dbf	d0,reset2
	move.l	#gunanim,gunpos	Reset gun type
	move.w	#5,reload
	clr.w	nummon
	move.l	#knife,a0
	move.w	#8,d0
reset3	clr.w	(a0)+		Reset collectables
	dbf	d0,reset3
	move.w	#50,ammo1		Reset ammunition
	move.w	#50,ammo2
	move.w	#10,ammo3
	move.w	#50,ammo4
	move.w	#3,weapon		Reset weapon statistics
	clr.w	withdraw
	move.w	#1,damage
	move.l	#rocketf,a0	Reset projectiles
	move.w	#7,d0		
reset4	clr.w	(a0)+
	dbf	d0,reset4
	move.w	#900,time		Reset time limit
	tst.w	warmreset		Only warm reset?
	bne	return		Yes, return
	move.w	#223,d0
	move.l	#animdata,a0
	move.l	#animback,a1
reset5	move.l	(a1)+,(a0)+	Restore animation data table
	dbf	d0,reset5
	rts			Return

newscore	move.l	#score,a0		Address of game over data
	move.w	#9,d0		Set up a counter
newscore2	clr.w	(a0)+		Clear it
	dbf	d0,newscore2	Clear some more
	rts			Return

initdma	move.b	#0,$ff8901		Stop DMA chip
	move.b	#0,$ff8907		Start low byte
	move.b	#0,$ff8905		Start mid byte
	move.b	#$f,$ff8903		Start high byte
	move.b	#2,$ff8913		End low byte
	move.b	#0,$ff8911		End mid byte
	move.b	#$f,$ff890f		End high byte
	move.b	#3,$ff8921		Set frequency
	move.b	#3,$ff8901		Activate DMA chip!
	move.w	#$07ff,$ffff8924		Message to microwire
	move.w	#%10001001100,$ffff8922	Maximum bass!
	rts				Return

fastchck	sub.l	#40000,mempos	Request 40000 bytes
	move.l	mempos,a0		Destination address
	move.w	#1,d0		Side 1
	move.w	#78,d1		Track 78
	move.w	#5,d2		Sector 5
	move.l	#671,d3		Size of file
	move.l	#32066,d4		Decompressed size
	move.w	#24,d5		Unpack delay
	bsr	packload2		Load it in
	bsr	bpalt		Set palette to black
	move.w	#2,-(sp)		Get screen address
	trap	#14		Call XBIOS
	addq.l	#2,sp		Correct stack
	move.l	d0,a1		Destination address
	move.l	mempos,a0		Source address
	lea	34(a0),a0		Move to picture
	move.w	#7999,d0		Set up a counter
topbytel	move.l	(a0)+,(a1)+	Copy across top byte logo
	dbf	d0,topbytel	Copy some more
	move.l	mempos,a0		Source address
	addq.l	#2,a0		Address of palette
	move.l	a0,-(sp)		Set colour palette
	move.w	#6,-(sp)		Function number
	trap	#14		Call XBIOS
	addq.l	#6,sp		Correct stack
	add.l	#40000,mempos	Return memory
	move.w	#1,-(sp)		Get key press
	trap	#1		Call GEMDOS
	addq.l	#2,sp		Correct stack
	move.w	d0,d7		Preserve d0
	bsr	bpalt		Set palette to black
	cmp.b	#"N",d7		Cancel routine?
	beq	slowload		No, goto routine
	cmp.b	#"n",d7		Cancel routine?
	beq	slowload		No, goto routine
	rts			Return

logo	sub.l	#40000,mempos	Request 40000 bytes
	move.l	mempos,a0		Destination address
	clr.w	d0		Side 0
	move.w	#23,d1		Track 23
	move.w	#2,d2		Sector 2
	move.l	#2754,d3		Size of file
	move.l	#32066,d4		Decompressed size
	move.w	#24,d5		Unpack delay

	bsr	interload		Load in file
waitload2	move.l	oldint,d0		Get old interrupt address
	cmp.l	$68,d0		Loaded in yet?
	bne	waitload2		No, keep waiting

	move.l	mempos,a0		Destination address
	lea	2754(a0),a0	Move to end
	move.l	a0,a1		Source address
	move.w	#2753,d0		Set up a counter
revlogo	move.b	-(a1),(a0)+	Copy across picture
	dbf	d0,revlogo	Copy some more

	move.l	mempos,a0		Address of logo
	lea	2754(a0),a0	Move to start
	jsr	(a0)		Decompress it

	bsr	bpalt		Set palette to black
	move.w	#2,-(sp)		Get screen address
	trap	#14		Call XBIOS
	addq.l	#2,sp		Correct stack
	move.l	d0,a1		Destination address
	move.l	mempos,a0		Source address
	lea	2818(a0),a0	Move to picture
	move.w	#7999,d0		Set up a counter
logol	move.l	(a0)+,(a1)+	Copy across top byte logo
	dbf	d0,logol		Copy some more
	move.l	#$00002222,$ffff8240.w	Set palette
	move.l	#$33334444,$ffff8244.w	Set palette
	add.l	#40000,mempos	Return memory
	rts			Return

loadsam	sub.l	#105572,mempos	Request 105572 bytes
	move.l	mempos,a0		Destination address
	move.l	a0,samadr		Store address
	clr.w	d0		Side 0
	move.w	#56,d1		Track 56
	move.w	#2,d2		Sector 2
	move.l	#62748,d3		Size of file
	move.l	#104752,d4	Unpacked size
	move.w	#24,d5		Unpack delay
	bsr	packload		Load it in
	rts			Return

initblit	move.w	#8,$ff8a22	Source Y increment
	move.w	#40,$ff8a30	Dest Y increment
	move.w	#8,$ff8a2e	Dest X increment
	move.w	#16,$ff8a36	X count
	clr.b	$ff8a3d		Shift
	move.w	#$ff,$ff8a28	Endmask 1
	move.w	#$ffff,$ff8a2a	Endmask 2
	move.w	#$ff80,$ff8a2c	Endmask 3
	move.b	#3,$ff8a3b	Logical operation
	move.b	#2,$ff8a3a	Set HOP register
	rts			Return

initcalc	sub.l	#2304,mempos	Request 2304 bytes
	move.l	mempos,a1		Address of object map
	move.l	a1,objmap		Store address
	sub.l	#2304,mempos	Request 2304 bytes
	move.l	mempos,a1		Address of blockage map
	move.l	a1,blockmap	Store address

	sub.l	#2304,mempos	Request 2304 bytes
	move.l	mempos,a1		Address of monster map
	move.l	a1,monmap		Store address
	move.w	#575,d0		Set up a counter
clrmon	clr.l	(a1)+		Clear monster map
	dbf	d0,clrmon		Do next longword

	sub.l	#2304,mempos	Request 2304 bytes
	move.l	mempos,doormap	Address of doormap

	sub.l	#2304,mempos	Request 2304 bytes
	move.l	mempos,a0		Destination address
	clr.w	d0		Side 0
	move.w	level,d1		Get level number
	move.w	#10,d2		Sector 10
	move.l	#levelsize-2,a1	Size of levels table
	add.w	level,a1		Find place in table
	add.w	level,a1		Find place in table
	clr.l	d3		Clear d3
	move.w	(a1),d3		Size of file
	move.l	#2330,d4		Depacked size
	move.w	#24,d5		Depack delay
	move.l	a0,map1		Address of map data
	bsr	packload		Load in data
	move.l	map1,a1		Address of map
	clr.w	d0		Clear d0
	move.b	2304(a1),d0	Get x start point
	lsl.w	#5,d0		Scale up
	add.w	#16,d0		Start in centre of squre
	move.w	d0,xpos		And Store
	clr.w	d0		Clear d0
	move.b	2305(a1),d0	Get y start point
	lsl.w	#5,d0		Scale up
	add.w	#16,d0		Start in centre of square
	move.w	d0,ypos		And store
	clr.w	d0		Clear d0
	move.b	2306(a1),d0	Get start direction
	move.w	d0,face		And store
	lea	2307(a1),a1	Address of time limit data
	clr.w	d0		Clear d0
	move.b	(a1)+,d0		Get first half
	lsl.w	#8,d0		Make room for second half
	move.b	(a1)+,d0		Get second half
	move.w	d0,time		Store time limit
	clr.w	d0		Clear d0
	move.w	#20,d1		Set up a counter
	move.l	#mon1s,a2		Address of monster stats table
statcopy	move.b	(a1)+,d0		Get piece of data
	move.w	d0,(a2)+		Store in monster stats table
	dbf	d1,statcopy	Get next piece of data

	move.l	#hitmon,a1	Address of monster defences
	move.w	mon1h,(a1)+	Copy across data
	move.w	mon2h,(a1)+	Copy across data
	move.w	mon3h,(a1)+	Copy across data
	move.w	mon4h,(a1)+	Copy across data
	move.w	mon5h,(a1)+	Copy across data
	move.w	mon6h,(a1)+	Copy across data
	move.w	mon7h,(a1)+	Copy across data

	move.l	doormap,a1	Address of doormap
	move.w	#575,d0		Set up a counter
clrdoor	clr.l	(a1)+		Clear door map
	dbf	d0,clrdoor	Do next longword

	move.l	objmap,a0		Get object map address
	move.l	map1,a1		Address of level map
	move.w	#2303,d0		Set up a counter
objloop	move.b	(a1)+,d1		Get block from map
	cmp.b	#32,d1		Is it an object?
	bgt	copyobj		Yes, copy to object map
	clr.b	(a0)+		No, blank object map
copyobjr	dbf	d0,objloop	Get next block

	move.l	map1,a1		Get source address
	move.l	blockmap,a0	Get destination address
	move.w	#575,d0		Set up a counter
blockloop	move.l	(a1)+,(a0)+	Copy across long word
	dbf	d0,blockloop	Get next longword

	sub.l	#2304,mempos	Request 2304 bytes
	move.l	mempos,a1		Map 2 address
	move.l	a1,map2		Store address
	move.l	map1,a2		Address of map 1
	move.l	monmap,a3		Address of monster map
	move.w	#63,d0		Set up xcounter
xdoor	move.w	#35,d1		Set up ycounter
ydoor	move.w	d1,d2		Get ypos
	asl.w	#6,d2		Find line address
	add.w	d0,d2		Get xpos
	cmp.b	#2,(a2,d2)	Is it a door?
	beq	getdoor		Yes, copy to wallmap
	cmp.b	#11,(a2,d2)	Is it a door?
	beq	getdoor		Yes, copy to wallmap
	cmp.b	#12,(a2,d2)	Is it a secret door?
	beq	getsdoor		Yes, make removable
	cmp.b	#13,(a2,d2)	Is it a door?
	beq	getdoor		Yes, copy to wallmap
getdoorr	cmp.b	#16,(a2,d2)	Is it a monster?
	bgt	getmon		Yes, copy to monstermap
getmonr	dbf	d1,ydoor		Next block
	dbf	d0,xdoor		Next line

	move.w	#63,d0		Set up xcounter
xcloop	move.w	#35,d1		Set up ycounter
ycloop	move.w	d1,d2		Get ypos
	asl.w	#6,d2		Find line address
	add.w	d0,d2		Get xpos
	tst.b	(a2,d2)		Get block from map
	bgt	wallmap		copy to wall map
	tst.b	(a2,d2)		Is it a door?
	blt	wallmapr		Yes, don't erase
	clr.b	(a1,d2)		No, clear wallmap
wallmapr	dbf	d1,ycloop		Next block
	dbf	d0,xcloop		Next line

	move.w	#63,d0		Set up xcounter
xnegbl	move.w	#35,d1		Set up ycounter
ynegbl	move.w	d1,d2		Get ypos
	asl.w	#6,d2		Find line address
	add.w	d0,d2		Get xpos
	tst.b	(a2,d2)		Get block from map
	blt	invwall		Is it negative?
invwallr	dbf	d1,ynegbl		Next block
	dbf	d0,xnegbl		Next line
	sub.l	#2496,mempos	Request 2496 bytes
	move.l	mempos,mapmap	Store address
	move.l	mempos,a0		Address of map
	move.w	#623,d0		Set up a counter
mapmapl	clr.l	(a0)+		Blank out mapper map
	dbf	d0,mapmapl	Keep erasing
	rts			Return

invwall	neg.b	(a2,d2)		Negate block
	bra	invwallr		Return

copyobj	sub.b	#32,d1		Count from 1
	move.b	d1,(a0)+		Copy to object map
	clr.b	-1(a1)		Clear from main map
	bra	copyobjr		Return

getmon	move.b	(a2,d2),d7	Get monster type
	sub.b	#16,d7		Count from 1
	move.b	d7,(a3,d2)	Store in monster map
	clr.b	(a2,d2)		Erase from wall map
	bra	getmonr		Return

getsdoor	neg.b	(a2,d2)		Allow walls next to door
	tst.b	-64(a2,d2)	Anything above?
	beq	sdoorh		No, horizontal door
	tst.b	1(a2,d2)		Anything right?
	beq	sdoorv		No, vertical door
sdoorh	move.b	#5,(a1,d2)	Copy to wall map
	bra	getdoorr		Return
sdoorv	move.b	#10,(a1,d2)	Copy to wall map
	bra	getdoorr		Return

getdoor	neg.b	(a2,d2)		Allow walls next to door
	tst.b	-64(a2,d2)	Anything above?
	beq	doorh		No, horizontal door
	tst.b	1(a2,d2)		Anything right?
	beq	doorv		No, vertical door
doorh	move.b	#16,(a1,d2)	Copy to wall map
	bra	getdoorr		Return
doorv	move.b	#32,(a1,d2)	Copy to wall map
	bra	getdoorr		Return

wallmap	clr.w	d3		Wall flag = 0
	tst.b	-64(a2,d2)	Anything above?
	ble	wallu		No, set flag
wallur	tst.b	1(a2,d2)		Anything right?
	ble	wallr		No, set flag
wallrr	tst.b	64(a2,d2)		Anything down?
	ble	walld		No, set flag
walldr	tst.b	-1(a2,d2)		Anything left?
	ble	walll		No, set flag
walllr	move.b	d3,(a1,d2)	Copy to wall map
	bra	wallmapr		Return

wallu	add.w	#1,d3		Set flag
	bra	wallur		Return
wallr	add.w	#2,d3		Set flag
	bra	wallrr		Return
walld	add.w	#4,d3		Set flag
	bra	walldr		Return
walll	add.w	#8,d3		Set flag
	bra	walllr		Return

noint	rte			No interrupt

inittmap	sub.l	#24784,mempos	Request 24784 bytes
	move.l	mempos,a0		Destination address
	clr.w	d0		Side 0
	move.w	#2,d1		Track 2
	move.w	#7,d2		Sector 7
	move.l	#4584,d3		Size of file
	move.l	#23954,d4		Unpacked size
	move.w	#24,d5		Unpack delay
	move.l	a0,pixplot	Store address
	bsr	packload		Load in data

	sub.l	#258586,mempos	Request 258586 bytes
	move.l	mempos,a0		Destination address
	clr.w	d0		Side 0
	move.w	#16,d1		Track 16
	move.w	#5,d2		Sector 5
	move.l	#25089,d3		Size of file
	move.l	#257712,d4	Unpacked size
	move.w	#24,d5		Depack delay
	bsr	packload		Load in data

	move.l	mempos,a1		Address of textures
	move.l	a1,texttble	Address of textures table
	lea	304(a1),a1	Address of graphic data

	move.l	#textadr,a2	Texture address list
	move.l	a1,d2		Address of texture data
	move.w	#21,d0		Set up a counter
itmpl	move.l	d2,(a2)+		Store address
	add.l	#11700,d2		Move up pointer
	dbf	d0,itmpl		Store next address

	move.l	pixplot,d2	Address of pixelplot routine
	move.w	#32174,d0		Set up a counter
itmpl2	add.w	d2,(a1)+		Find absolute address
	add.w	d2,(a1)+		Find absolute address
	add.w	d2,(a1)+		Find absolute address
	add.w	d2,(a1)+		Find absolute address
	dbf	d0,itmpl2		Loop back around
	rts			Return

cls	move.l	#$100000,a0	End of screen memory
	move.w	#16383,d0		Setup counter
clrloop	clr.l	-(a0)		Blank out 4 bytes
	dbf	d0,clrloop	Next 4 bytes
	rts			Return

initicon	sub.l	#17664,mempos	Request 17664 bytes
	move.l	mempos,a0		Destination address
	clr.w	d0		Side 0
	move.w	#15,d1		Track 15
	move.w	#6,d2		Sector 6
	move.l	#3781,d3		Size of file
	move.l	#16834,d4		Unpacked size
	move.w	#24,d5		Depack delay
	bsr	packload		Load it in
	move.l	mempos,a1		Address of file
	move.l	a1,icons		Store address of table
	lea	120(a1),a1	Jump to graphic data
	
	move.l	#gunanim,gunpos	Set up gun animation
	move.l	a1,d1		Address of icon graphics
	move.l	icons,a2		Address of icons table
	addq.l	#4,a2		Move to first address
	move.w	#9,d0		Number of icons -1
initiloop	add.l	d1,(a2)+		Convert to absolute address
	add.l	d1,(a2)+		Convert next address
	addq.l	#4,a2		Jump to next icon
	dbf	d0,initiloop	Convert it
	rts			Return 

initbord2	sub.l	#20906,mempos	Request 20906 bytes
	move.l	mempos,a0		Destination address
	move.l	a0,bordicon	Store address
	clr.w	d0		Side 0
	move.w	#22,d1		Track 22
	move.w	#8,d2		Sector 8
	move.l	#1343,d3		Size of file
	move.l	#20076,d4		Depacked size
	move.w	#24,d5		Depack delay
	bsr	packload		Load it in
	rts			Return

initbord	move.l	#$eff7c,a0	Destination address
	clr.w	d0		Side 0
	move.w	#22,d1		Track 22
	move.w	#1,d2		Sector 1
	move.l	#3307,d3		Size of file
	move.l	#32070,d4		Unpacked size
	move.w	#24,d5		Depack delay
	bsr	packload		Load it in
	move.l	#$eff9e,a0	Source address
	move.l	#$f8000,a1	Destination address
	move.w	#7999,d0		Set up counter
bordloop	move.l	(a0)+,(a1)+	Copy across long word
	dbf	d0,bordloop	Next 4 bytes
	move.l	#$f8000,a0	Source address
	move.l	#$f0000,a1	Destination address
	move.w	#7999,d0		Set up counter
bordloop2	move.l	(a0)+,(a1)+	Copy across long word
	dbf	d0,bordloop2	Next 4 bytes
	bsr	updatea1		Update ammo 1
	rts			Return

initobj	sub.l	#50644,mempos	Request 50644 bytes
	move.l	mempos,a0		Destination address
	move.w	#1,d0		Side 1
	move.w	#29,d1		Track 29
	move.w	#7,d2		Sector 7
	move.l	#17560,d3		Size of file
	move.l	#49814,d4		Unpacked size
	move.w	#24,d5		Depack delay
	bsr	packload		Load in data
	move.l	mempos,a1		Address of file
	lea	4160(a1),a6	Jump to graphic data
	move.l	#objdata,a0	Address of object animation data
	bsr	create_at		Create animation table
	move.l	a6,d0		Address of graphics
	move.w	#259,d6		Set up a counter
	addq.l	#4,a1		Move to first address
lobloop	add.l	d0,(a1)+		Convert to absolute address
	add.l	d0,(a1)+		Convert to absolute address
	addq.l	#8,a1		Move to next address
	dbf	d6,lobloop	Convert next 2 addresses
	rts			Return

initmis	sub.l	#13994,mempos	Request 13994 bytes
	move.l	mempos,a0		Destination address
	move.w	#1,d0		Side 1
	move.w	#13,d1		Track 13
	move.w	#4,d2		Sector 4
	move.l	#4059,d3		Size of file
	move.l	#13164,d4		Depacked size
	move.w	#24,d5		Depack delay
	bsr	packload		Load in data
	move.l	mempos,a6		Address of data
	lea	12520(a6),a1	Address of object table
	lea	6000(a6),a6	Address of graphic data
	move.l	#misdata,a0	Address of missile data
	bsr	create_at		Create animation table
	move.l	a6,d0		Address of graphics
	move.w	#39,d6		Set up a counter
	addq.l	#4,a1		Move to first address
misloop	add.l	d0,(a1)+		Convert to absolute address
	add.l	d0,(a1)+		Convert to absolute address
	addq.l	#8,a1		Move to next address
	dbf	d6,misloop	Convert next 2 addresses

	move.l	mempos,a1		Address of file
	lea	5940(a1),a1	Jump past header
	move.l	a1,icons2		Store address of table
	lea	-5940(a1),a1	Jump to graphic data
	
	move.l	a1,d1		Address of icon graphics
	move.l	icons2,a2		Address of icons table
	addq.l	#4,a2		Move to first address
	move.w	#4,d0		Number of icons -1
misloop2	add.l	d1,(a2)+		Convert to absolute address
	add.l	d1,(a2)+		Convert next address
	addq.l	#4,a2		Jump to next icon
	dbf	d0,misloop2	Convert it
	rts			Return

initanim	move.l	monmap,a0		Address of monster map
	move.w	#2303,d0		Set up a counter
initanim2	cmp.b	#1,(a0)+		Load rock monster?
	beq	loadmon1		Yes, goto routine
	dbf	d0,initanim2	Check next square of map
loadmon1r	move.l	monmap,a0		Address of monster map
	move.w	#2303,d0		Set up a counter
initanim3	cmp.b	#2,(a0)+		Load robot?
	beq	loadmon2		Yes, goto routine
	dbf	d0,initanim3	Check next sqaure of map
loadmon2r	move.l	monmap,a0		Address of monster map
	move.w	#2303,d0		Set up a counter
initanim4	cmp.b	#3,(a0)+		Load beetle?
	beq	loadmon3		Yes, goto routine
	dbf	d0,initanim4	Check next sqaure of map
loadmon3r	move.l	monmap,a0		Address of monster map
	move.w	#2303,d0		Set up a counter
initanim5	cmp.b	#4,(a0)+		Load gun-turret?
	beq	loadmon4		Yes, goto routine
	dbf	d0,initanim5	Check next sqaure of map
loadmon4r	move.l	monmap,a0		Address of monster map
	move.w	#2303,d0		Set up a counter
initanim6	cmp.b	#5,(a0)+		Load bat?
	beq	loadmon5		Yes, goto routine
	dbf	d0,initanim6	Check next sqaure of map
loadmon5r	move.l	monmap,a0		Address of monster map
	move.w	#2303,d0		Set up a counter
initanim7	cmp.b	#6,(a0)+		Load ghost?
	beq	loadmon6		Yes, goto routine
	dbf	d0,initanim7	Check next sqaure of map
loadmon6r	move.l	monmap,a0		Address of monster map
	move.w	#2303,d0		Set up a counter
initanim8	cmp.b	#7,(a0)+		Load mutant?
	beq	loadmon7		Yes, goto routine
	dbf	d0,initanim8	Check next sqaure of map
loadmon7r	rts			Return

loadmon1	sub.l	#177764,mempos	Request 177764 bytes
	move.l	mempos,a0		Destination address
	move.w	#1,d0		Side 1
	move.w	#38,d1		Track 38
	move.w	#9,d2		Sector 9
	move.l	#79347,d3		Size of file
	move.l	#176934,d4	Unpacked size
	move.w	#24,d5		Depack delay
	bsr	packload		Load in data
	move.l	mempos,a1		Address of file
	lea	4160(a1),a6	Address of graphic data
	move.l	#animdata,a0	Address of animation data
	bsr	create_at		Create animation table
	move.l	a6,d0		Address of graphics
	move.w	#259,d6		Set up a counter
	bsr	conv_adr		Convert to absolute adresses
	bra	loadmon1r		Return

conv_adr	addq.l	#4,a1		Move to first address
conv_adrl	add.l	d0,(a1)+		Convert to absolute address
	add.l	d0,(a1)+		Convert to absolute address
	addq.l	#8,a1		Move to next address
	dbf	d6,conv_adrl	Convert next 2 addresses
	rts			Return

loadmon2	sub.l	#81954,mempos	Request 81954 bytes
	move.l	mempos,a0		Destination address
	move.w	#1,d0		Side 1
	move.w	#33,d1		Track 33
	move.w	#6,d2		Sector 6
	move.l	#24499,d3		Size of file
	move.l	#81124,d4		Unpacked size
	move.w	#24,d5		Depack delay
	bsr	packload		Load in data
	move.l	mempos,a1		Address of file
	lea	2240(a1),a6	Address of graphic data
	move.l	#animdata2,a0	Address of animation data
	bsr	create_at		Create animation table
	move.l	a6,d0		Address of graphics
	move.w	#139,d6		Set up a counter
	bsr	conv_adr		Convert addresses
	bra	loadmon2r		Return

loadmon3	sub.l	#112854,mempos	Request 112854 bytes
	move.l	mempos,a0		Destination address
	clr.w	d0		Side 0
	move.w	#74,d1		Track 74
	move.w	#4,d2		Sector 4
	move.l	#36520,d3		Size of file
	move.l	#112024,d4	Unpacked size
	move.w	#24,d5		Depack delay
	bsr	packload		Load in data
	move.l	mempos,a1		Address of file
	lea	3200(a1),a6	Address of graphic data
	move.l	#animdata3,a0	Address of animation data
	bsr	create_at		Create animation table
	move.l	a6,d0		Address of graphics
	move.w	#199,d6		Set up a counter
	bsr	conv_adr		Convert addresses
	bra	loadmon3r		Return

loadmon4	sub.l	#33314,mempos	Request 33314 bytes
	move.l	mempos,a0		Destination address
	move.w	#1,d0		Side 1
	move.w	#10,d1		Track 10
	move.w	#6,d2		Sector 6
	move.l	#12694,d3		Packed size
	move.l	#32484,d4		Unpacked size
	move.w	#24,d5		Depack delay
	bsr	packload		Load in data
	move.l	mempos,a1		Address of file
	lea	1920(a1),a6	Address of graphic data
	move.l	#animdata4,a0	Address of animation data
	bsr	create_at		Create animation table
	move.l	a6,d0		Address of graphics
	move.w	#119,d6		Set up a counter
	bsr	conv_adr		Convert addresses
	bra	loadmon4r		Return

loadmon5	sub.l	#45278,mempos	Request 45278 bytes
	move.l	mempos,a0		Destination address
	clr.w	d0		Side 0
	move.w	#69,d1		Track 69
	move.w	#8,d2		Sector 8
	move.l	#20483,d3		Packed size
	move.l	#44414,d4		Depacked size
	move.w	#24,d5		Depack delay
	bsr	packload		Load in data
	move.l	mempos,a1		Address of file
	lea	2240(a1),a6	Address of graphic data
	move.l	#animdata5,a0	Address of animation data
	bsr	create_at		Create animation table
	move.l	a6,d0		Address of graphics
	move.w	#139,d6		Set up a counter
	bsr	conv_adr		Convert addresses
	bra	loadmon5r		Return

loadmon6	sub.l	#113198,mempos	Request 113198 bytes
	move.l	mempos,a0		Destination address
	move.w	#1,d0		Side 1
	move.w	#2,d1		Track 2
	move.w	#4,d2		Sector 4
	move.l	#37385,d3		Packed size
	move.l	#112334,d4	Unpacked size
	move.w	#24,d5		Depack delay
	bsr	packload		Load in data
	move.l	mempos,a1		Address of file
	lea	1280(a1),a6	Address of graphic data
	move.l	#animdata6,a0	Address of animation data
	bsr	create_at		Create animation table
	move.l	a6,d0		Address of graphics
	move.w	#79,d6		Set up a counter
	bsr	conv_adr		Convert addresses
	bra	loadmon6r		Return

loadmon7	sub.l	#156288,mempos	Request 156288 bytes
	move.l	mempos,a0		Destination address
	move.w	#1,d0		Side 1
	move.w	#14,d1		Track 14
	move.w	#3,d2		Sector 3
	move.l	#70854,d3		Packed size
	move.l	#155424,d4	Unpacked size
	move.w	#24,d5		Depack delay
	bsr	packload		Load in data
	move.l	mempos,a1		Address of file
	lea	4160(a1),a6	Address of graphic data
	move.l	#animdata7,a0	Address of animation data
	bsr	create_at		Create animation table
	move.l	a6,d0		Address of graphics
	move.w	#259,d6		Set up a counter
	bsr	conv_adr		Convert addresses
	bra	loadmon7r		Return

create_at	move.w	#31,d2		Set up a counter
loadmonl	move.l	a1,d1		Address of monster table
	move.l	(a0),d0		Get frame number
	cmp.l	#-1,d0		Any frame?
	beq	norelo		No, don't relocate
	lsl.l	#6,d0		Multiply by 64
	add.l	d0,d1		Add onto address
	lsl.l	#2,d0		Multiply by 4 more
	add.l	d0,d1		Add onto address
	move.l	d1,(a0)+		Store absolute address
	dbf	d2,loadmonl	Relocate next frame
	rts			Return

norelo	addq.l	#4,a0		Move up frame address
	dbf	d2,loadmonl	Relocate next frame
	rts			Return

setpalt	pea	palette		New palette
	move.w	#6,-(sp)		Function number
	trap	#14		Call XBIOS
	addq.l	#6,sp		Correct stack
	rts			Return

bpalt	pea	blackpal		New palette
	move.w	#6,-(sp)		Function number
	trap	#14		Call XBIOS
	addq.l	#6,sp		Correct stack
	rts			Return

	*End of intitialisation routines

	*Start of program data

	***************
	*Include Files*
	***************

	*Library
	include	"\assembly\routines\video.s"
	include	"\assembly\routines\joystick.s"
	include	"\assembly\routines\graphic3.s"
	include	"\assembly\routines\samplay.s"
	include	"\assembly\routines\packload.s"

	*Data tables
backgrnd	incbin	"\assembly\backgrnd.dat"
rotate	incbin	"\assembly\rotate.tbl"
trig	incbin	"\assembly\trig.tbl"
divide	incbin	"\assembly\divide.tbl"

	********************
	*Variables and data*
	********************

	*Addresses
	even				Ensure even address
mempos	dc.l	$eff7c			Free memory pointer
memreset	dc.l	0			Free Memory reset point
textadr	ds.l	22			Texture addresses
map1	dc.l	0			Map address
map2	dc.l	0			Wallmap address
doormap	dc.l	0			Doormap address
monmap	dc.l	0			Monstermap address
blockmap	dc.l	0			Blockage map address
objmap	dc.l	0			Object map address
texttble	dc.l	0			Address of texture table
pixplot	dc.l	0			Pixplot routine address
samples	dc.l	0			Address of music samples
replay	dc.l	0			Address of replay routines
music	dc.l	0			Address of music data
backpic	dc.l	0			Address of still pictures
bordicon	dc.l	0			Address of border icons
icons	dc.l	0			Address of icons table
icons2	dc.l	0			Address of icons2 table
samadr	dc.l	0			Samples address
mapmap	dc.l	0			Mapper map address

	*Palettes
palette	dc.w	$000,$888,$111,$999,$222,$AAA,$333,$BBB
	dc.w	$100,$980,$280,$A10,$390,$B21,$500,$030
blackpal	ds.w	16
stfmpalt	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$200,$310,$410,$520,$630,$742,$700,$060
stfmpalt2	dc.w	$000,$111,$222,$333,$111,$222,$333,$444
	dc.w	$111,$222,$333,$444,$222,$333,$444,$555

	*Texture data
texture_a	dc.w	0,$0333,256,0,768,0,0,$0999,512,0,1024,0
	dc.w	0,$0FFF,256,0,768,0,0,$1665,512,0,1024,0
	dc.w	0,$1CCB,256,0,768,0,0,$2331,512,0,1024,0
	dc.w	0,$2997,256,0,768,0,0,$2FFD,512,0,1024,0
	dc.w	0,$3663,256,0,768,0,0,$3CC9,512,0,1024,0
	dc.w	0,$7FFF
	ds.w	66
	dc.w	2304,$0666,2048,0
	dc.w	2560,0,2304,$0BBB,2816,$0DDD,2304,$1332,2048,0
	dc.w	2560,0,2304,$1887,2816,$1AA9,2304,$1FFE,2048,0
	dc.w	2560,0,2304,$2553,2816,$2775,2304,$2CCA,2048,0
	dc.w	2560,0,2304,$3552,3328,$3663,3072,$3885
	dc.w	3328,$3996,2048,0,2560,0,2304,$7FFF
	ds.w	78
	dc.w	2816,$0111,2304,$0666,2048,0
	dc.w	2560,0,2304,$0BBB,2816,$0DDD,2304,$1332,2048,0
	dc.w	2560,0,2304,$1887,2816,$1AA9,2304,$1FFE,2048,0
	dc.w	2560,0,2304,$2553,2816,$2775,2304,$2CCA,2048,0
	dc.w	2560,0,2304,$321F,2816,$3441,2304,$3996,2048,0
	dc.w	2560,0,2304,$3EEB,2816,$4000,2304,$7FFF
	ds.w	74
	dc.w	1536,$333,3840,0,3584,$1CCD,4096,0,1536,$2000
	dc.w	1536,$2333,3840,0,3584,$3CCD,4096,0,1536,$7FFF
	ds.w	108
	dc.w	2304,$333,4608,0,4352,$1CCD,4864,0,2304,$2000
	dc.w	2304,$2333,4608,0,4352,$3CCD,4864,0,2304,$7FFF
	ds.w	108
	dc.w	0,$0666,1280,0,1792,0,0,$1332,1280,0,1792,0,0,$2000
	dc.w	0,$2666,1280,0,1792,0,0,$3332,1280,0,1792,0,0,$7FFF
	ds.w	102
	dc.w	1280,$111,1536,$222,1792,$333,1536,$444
	dc.w	1280,$555,1536,$666,1792,$777,1536,$888
	dc.w	1280,$999,1536,$AAA,1792,$BBB,1536,$CCC
	dc.w	1280,$DDD,1536,$EEE,1792,$FFF,1536,$1110
	dc.w	1280,$1221,1536,$1332,1792,$1443,1536,$1554
	dc.w	1280,$1665,1536,$1776,1792,$1887,1536,$1998
	dc.w	1280,$1AA9,1536,$1BBA,1792,$1CCB,1536,$1DDC
	dc.w	1280,$1EED,1536,$2000
	dc.w	1792,$2111,1536,$2222,1280,$2333,1536,$2444
	dc.w	1792,$2555,1536,$2666,1280,$2777,1536,$2888
	dc.w	1792,$2999,1536,$2AAA,1280,$2BBB,1536,$2CCC
	dc.w	1792,$2DDD,1536,$2EEE,1280,$2FFF,1536,$3110
	dc.w	1792,$3221,1536,$3332,1280,$3443,1536,$3554
	dc.w	1792,$3665,1536,$3776,1280,$3887,1536,$3998
	dc.w	1792,$3AA9,1536,$3BBA,1280,$3CCB,1536,$3DDC
	dc.w	1792,$3EED,1536,$7FFF
	ds.w	8
	dc.w	1536,$222,5376,$444,1536,$666
	dc.w	5376,$888,1536,$AAA,5376,$CCC
	dc.w	1536,$EEE,5376,$1110,1536,$1332
	dc.w	5376,$1554,1536,$1776,5376,$1998
	dc.w	1536,$1BBA,5120,$1DDC,1536,$2000,1280,0
	dc.w	1792,0,1536,$2222,5120,$2444,1536,$2666
	dc.w	5376,$2888,1536,$2AAA,5376,$2CCC
	dc.w	1536,$2EEE,5376,$3110,1536,$3332
	dc.w	5376,$3554,1536,$3776,5376,$3998
	dc.w	1536,$3BBA,5376,$3DDC,1536,$7FFF
	ds.w	64
	dc.w	5376,$0111,1536,$0666,1280,0
	dc.w	1792,0,1536,$0BBB,5376,$0DDD,1536,$1332,1280,0
	dc.w	1792,0,1536,$1887,5376,$1AA9,1536,$1FFE,1280,0
	dc.w	1792,0,1536,$2553,5376,$2775,1536,$2CCA,1280,0
	dc.w	1792,0,1536,$321F,5376,$3441,1536,$3996,1280,0
	dc.w	1792,0,1536,$3EEB,5376,$4000,1536,$7FFF
	ds.w	74
	dc.w	1536,$222,5120,$444,1536,$666
	dc.w	5120,$888,1536,$AAA,5120,$CCC
	dc.w	1536,$EEE,5120,$1110,1536,$1332
	dc.w	5120,$1554,1536,$1776,5120,$1998
	dc.w	1536,$1BBA,5120,$1DDC,1536,$2000,1280,0
	dc.w	1792,0,1536,$2222,5120,$2444,1536,$2666
	dc.w	5120,$2888,1536,$2AAA,5120,$2CCC
	dc.w	1536,$2EEE,5120,$3110,1536,$3332
	dc.w	5120,$3554,1536,$3776,5120,$3998
	dc.w	1536,$3BBA,5120,$3DDC,1536,$7FFF
	ds.w	64
	dc.w	2304,$0666,2048,0
	dc.w	2560,0,2304,$0BBB,2816,$0DDD,2304,$1332,2048,0
	dc.w	2560,0,2304,$1887,2816,$1AA9,2304,$1FFE,2048,0
	dc.w	2560,0,2304,$2553,2816,$2775,2304,$2CCA,2048,0
	dc.w	2560,0,2304,$3552,3328,$3663,3072,$3885
	dc.w	3328,$3996,2048,0,2560,0,2304,$7FFF
	ds.w	78
	dc.w	1536,$333,3840,0,3584,$1CCD,4096,0,1536,$2000
	dc.w	1536,$2333,3840,0,3584,$3CCD,4096,0,1536,$7FFF
	ds.w	108
	dc.w	1536,$222,5376,$444,1536,$666,5376,$888
	dc.w	1536,$AAA,5376,$CCC,1536,$EEE,5376,$1110
	dc.w	1536,$1332,5376,$1554,1536,$1776,5376,$1998
	dc.w	1536,$1BBA,5376,$1DDC,1536,$2000,5376,$2222
	dc.w	1536,$2444,5376,$2666,1536,$2888,5376,$2AAA
	dc.w	1536,$2CCC,5376,$2EEE,1536,$3110,5376,$3332
	dc.w	1536,$3554,5376,$3776,1536,$3998,5376,$3BBA
	dc.w	1536,$3DDC,5376,$4000,1536,$7FFF
	ds.w	66

texture_b	dc.w	0,$0333,1024,0,512,0,0,$0999,768,0,256,0
	dc.w	0,$0FFF,1024,0,512,0,0,$1665,768,0,256,0
	dc.w	0,$1CCB,1024,0,512,0,0,$2331,768,0,256,0
	dc.w	0,$2997,1024,0,512,0,0,$2FFD,768,0,256,0
	dc.w	0,$3663,1024,0,512,0,0,$3CC9,768,0,256,0
	dc.w	0,$7FFF
	ds.w	66
	dc.w	2304,$0666,2560,0,2048,0,3328,$0777
	dc.w	3072,$0999,3328,$0AAA,2304,$1332,2560,0
	dc.w	2048,0,2304,$1887,2816,$1AA9,2304,$1FFE,2560,0
	dc.w	2048,0,2304,$2553,2816,$2775,2304,$2CCA,2560,0
	dc.w	2048,0,2304,$321F,2816,$3441,2304,$3996,2560,0
	dc.w	2048,0,2304,$7FFF
	ds.w	78
	dc.w	2816,$0111,2304,$0666,2560,0
	dc.w	2048,0,2304,$0BBB,2816,$0DDD,2304,$1332,2560,0
	dc.w	2048,0,2304,$1887,2816,$1AA9,2304,$1FFE,2560,0
	dc.w	2048,0,2304,$2553,2816,$2775,2304,$2CCA,2560,0
	dc.w	2048,0,2304,$321F,2816,$3441,2304,$3996,2560,0
	dc.w	2048,0,2304,$3EEB,2816,$4000,2304,$7FFF
	ds.w	74
	dc.w	1536,$333,4096,0,3584,$1CCD,3840,0,1536,$2000
	dc.w	1536,$2333,4096,0,3584,$3CCD,3840,0,1536,$7FFF
	ds.w	108
	dc.w	2304,$333,4864,0,4352,$1CCD,4608,0,2304,$2000
	dc.w	2304,$2333,4864,0,4352,$3CCD,4608,0,2304,$7FFF
	ds.w	108
	dc.w	0,$0666,1792,0,1280,0,0,$1332,1792,0,1280,0,0,$2000
	dc.w	0,$2666,1792,0,1280,0,0,$3332,1792,0,1280,0,0,$7FFF
	ds.w	102
	dc.w	1792,$111,1536,$222,1280,$333,1536,$444
	dc.w	1792,$555,1536,$666,1280,$777,1536,$888
	dc.w	1792,$999,1536,$AAA,1280,$BBB,1536,$CCC
	dc.w	1792,$DDD,1536,$EEE,1280,$FFF,1536,$1110
	dc.w	1792,$1221,1536,$1332,1280,$1443,1536,$1554
	dc.w	1792,$1665,1536,$1776,1280,$1887,1536,$1998
	dc.w	1792,$1AA9,1536,$1BBA,1280,$1CCB,1536,$1DDC
	dc.w	1792,$1EED,1536,$2000
	dc.w	1280,$2111,1536,$2222,1792,$2333,1536,$2444
	dc.w	1280,$2555,1536,$2666,1792,$2777,1536,$2888
	dc.w	1280,$2999,1536,$2AAA,1792,$2BBB,1536,$2CCC
	dc.w	1280,$2DDD,1536,$2EEE,1792,$2FFF,1536,$3110
	dc.w	1280,$3221,1536,$3332,1792,$3443,1536,$3554
	dc.w	1280,$3665,1536,$3776,1792,$3887,1536,$3998
	dc.w	1280,$3AA9,1536,$3BBA,1792,$3CCB,1536,$3DDC
	dc.w	1280,$3EED,1536,$7FFF
	ds.w	8
	dc.w	1536,$222,5376,$444,1536,$666
	dc.w	5376,$888,1536,$AAA,5376,$CCC
	dc.w	1536,$EEE,5376,$1110,1536,$1332
	dc.w	5376,$1554,1536,$1776,5376,$1998
	dc.w	1536,$1BBA,5120,$1DDC,1536,$2000,1792,0
	dc.w	1280,0,1536,$2222,5120,$2444,1536,$2666
	dc.w	5376,$2888,1536,$2AAA,5376,$2CCC
	dc.w	1536,$2EEE,5376,$3110,1536,$3332
	dc.w	5376,$3554,1536,$3776,5376,$3998
	dc.w	1536,$3BBA,5376,$3DDC,1536,$7FFF
	ds.w	64
	dc.w	5376,$0111,1536,$0666,1792,0
	dc.w	1280,0,1536,$0BBB,5376,$0DDD,1536,$1332,1792,0
	dc.w	1280,0,1536,$1887,5376,$1AA9,1536,$1FFE,1792,0
	dc.w	1280,0,1536,$2553,5376,$2775,1536,$2CCA,1792,0
	dc.w	1280,0,1536,$321F,5376,$3441,1536,$3996,1792,0
	dc.w	1280,0,1536,$3EEB,5376,$4000,1536,$7FFF
	ds.w	74
	dc.w	1536,$222,5120,$444,1536,$666
	dc.w	5120,$888,1536,$AAA,5120,$CCC
	dc.w	1536,$EEE,5120,$1110,1536,$1332
	dc.w	5120,$1554,1536,$1776,5120,$1998
	dc.w	1536,$1BBA,5120,$1DDC,1536,$2000,1792,0
	dc.w	1280,0,1536,$2222,5120,$2444,1536,$2666
	dc.w	5120,$2888,1536,$2AAA,5120,$2CCC
	dc.w	1536,$2EEE,5120,$3110,1536,$3332
	dc.w	5120,$3554,1536,$3776,5120,$3998
	dc.w	1536,$3BBA,5120,$3DDC,1536,$7FFF
	ds.w	64
	dc.w	2304,$0666,2560,0,2048,0,3328,$0777
	dc.w	3072,$0999,3328,$0AAA,2304,$1332,2560,0
	dc.w	2048,0,2304,$1887,2816,$1AA9,2304,$1FFE,2560,0
	dc.w	2048,0,2304,$2553,2816,$2775,2304,$2CCA,2560,0
	dc.w	2048,0,2304,$321F,2816,$3441,2304,$3996,2560,0
	dc.w	2048,0,2304,$7FFF
	ds.w	78
	dc.w	1536,$333,4096,0,3584,$1CCD,3840,0,1536,$2000
	dc.w	1536,$2333,4096,0,3584,$3CCD,3840,0,1536,$7FFF
	ds.w	108
	dc.w	1536,$222,5376,$444,1536,$666,5376,$888
	dc.w	1536,$AAA,5376,$CCC,1536,$EEE,5376,$1110
	dc.w	1536,$1332,5376,$1554,1536,$1776,5376,$1998
	dc.w	1536,$1BBA,5376,$1DDC,1536,$2000,5376,$2222
	dc.w	1536,$2444,5376,$2666,1536,$2888,5376,$2AAA
	dc.w	1536,$2CCC,5376,$2EEE,1536,$3110,5376,$3332
	dc.w	1536,$3554,5376,$3776,1536,$3998,5376,$3BBA
	dc.w	1536,$3DDC,5376,$4000,1536,$7FFF
	ds.w	66

	*Animation data
animdata	dc.l	0,2,0,3,0,2,0,4,1,2		Rockmonster data
	dc.l	5,6,5,7,5,6,5,8
	dc.l	9,10,9,11,9,10,9,12
	ds.l	6
animdata2	dc.l	0,3,1,3,2,3,0,4		Robot data
	dc.l	5,-1,6,-1
	ds.l	20
animdata3	dc.l	0,-1,1,-1,2,-1,3,-1		Beetle data
	dc.l	4,-1,5,-1,6,-1,7,-1
	dc.l	8,-1,9,-1
	ds.l	12
animdata4	dc.l	3,-1,3,-1,3,-1,2,-1		Gunpost data
	dc.l	0,-1,4,-1,5,-1,5,-1
	dc.l	1,-1
	ds.l	14
animdata5	dc.l	0,-1,1,-1,2,-1,3,-1		Bat data
	dc.l	4,-1,5,-1,6,-1,1,-1,2,-1
	ds.l	14
animdata6	dc.l	0,-1,1,-1,2,-1,1,-1,3,-1	Ghost data
	ds.l	22
animdata7	dc.l	0,1,0,2,0,3		Mutant data
	dc.l	4,5,4,6,4,7
	dc.l	8,9,8,10,8,11,12,-1
	ds.l	12

objdata	dc.l	0,-1,1,-1,2,-1,3,-1,4,-1	Object data
	dc.l	5,-1,6,-1,7,-1,8,-1,9,-1
	dc.l	10,-1,11,-1,12,-1,-1,-1
	ds.l	4
misdata	dc.l	0,-1,1,-1			Missile data
	ds.l	28

	*Animation data backup
animback	dc.l	0,2,0,3,0,2,0,4,1,2		Rockmonster data
	dc.l	5,6,5,7,5,6,5,8
	dc.l	9,10,9,11,9,10,9,12
	ds.l	6
animback2	dc.l	0,3,1,3,2,3,0,4		Robot data
	dc.l	5,-1,6,-1
	ds.l	20
animback3	dc.l	0,-1,1,-1,2,-1,3,-1		Beetle data
	dc.l	4,-1,5,-1,6,-1,7,-1
	dc.l	8,-1,9,-1
	ds.l	12
animback4	dc.l	3,-1,3,-1,3,-1,2,-1		Gunpost data
	dc.l	0,-1,4,-1,5,-1,5,-1
	dc.l	1,-1
	ds.l	14
animback5	dc.l	0,-1,1,-1,2,-1,3,-1		Bat data
	dc.l	4,-1,5,-1,6,-1,1,-1,2,-1
	ds.l	14
animback6	dc.l	0,-1,1,-1,2,-1,1,-1,3,-1	Ghost data
	ds.l	22
animback7	dc.l	0,1,0,2,0,3		Mutant data
	dc.l	4,5,4,6,4,7
	dc.l	8,9,8,10,8,11,12,-1
	ds.l	12

	*Icon data
gunanim	dc.w	0,0,1,1,2,2,3,3,4,4,3,3,2,2,1,1,-1
fireanim	dc.w	2,2,2,2,2,-1
quickfire	dc.w	0,0,-1
ranim	dc.w	2,12,22,32,42,32,22,12,2,2,-1
changegun	dc.w	2,17,32,47,62,77,62,47,32,17,2,2,-1
swipe	dc.w	-12,-25,-12,2,2,-1

numtable	dc.l	3000,3008,3016,3024,3032
	dc.l	4280,4288,4296,4304,4312

snumtable	dc.l	120,128,136,144,152
	dc.l	1080,1088,1096,1104,1112

	*Level data
levelsize	dc.w	196,210,303,302,390,253,382
	dc.w	330,390,322,425,400,441,495
	dc.w	433,434,395,426,393,363,469
	dc.w	410,318,427,365
levorder	dc.w	1,2,3,4,5,20,9,6,17,10,8,7,12,15
	dc.w	11,13,16,19,14,18,22,21,23,24,25

	*Monster behaviour stats

mon1s	dc.w	0
mon1p	dc.w	0
mon1h	dc.w	0
mon2s	dc.w	0
mon2p	dc.w	0
mon2h	dc.w	0
mon3s	dc.w	0
mon3p	dc.w	0
mon3h	dc.w	0
mon4r	dc.w	0
mon4p	dc.w	0
mon4h	dc.w	0
mon5s	dc.w	0
mon5p	dc.w	0
mon5h	dc.w	0
mon6s	dc.w	0
mon6p	dc.w	0
mon6h	dc.w	0
mon7s	dc.w	0
mon7p	dc.w	0
mon7h	dc.w	0

	*Screen layout data
	dcb.b	99,50
screenh	ds.b	241			Wall heights
	dcb.b	99,50
screent	ds.b	241			Wall textures
	dcb.b	99,50

	*variables
keybuff	dc.w	0			Keyboard buffer
oldkbuff	dc.w	0			Old keyboard buffer
turnspeed	dc.w	6			Turning speed
walkspeed	dc.w	6			Walking speed
warmreset	dc.w	0			Reset priority mode
stfm_on	dc.w	0			Backwards compatability
output	dc.l	4			Output method
time	dc.w	900			Remaining time
health	dc.w	100			Current health
hchange	dc.w	1			Update health indicator?
level	dc.w	0			Level number

samdelay	dc.w	0			Slow down sample repeats
batactiv	dc.w	0			Activate bats
movement	dc.w	0			Movement indicator
xpos	dc.w	0			X position
ypos	dc.w	0			Y position
oldpos	dc.l	0,0			Space to store old pos
face	dc.w	0			Angle of vision
tshift	dc.w	0			Amount to shift texture?
backface	dc.w	0			Which side of texture?
animcount	dc.w	0			Animation counter
guntype	dc.w	0			Currently selected gun
fire	dc.w	0			Fire button status
firecount	dc.w	0			Post-fire delay counter
shoot	dc.w	0			Are we shooting the gun?
gunpos	dc.l	gunanim			Position of gun
reload	dc.w	5			Shots left before reload
rbackward	dc.w	0			Is monster running away?
hurtmon	dc.l	0			Address of shot monster
montable	ds.l	80			Table of active monsters
mondepth	ds.l	120			Table of monster depths
dummytble	ds.w	16			Temporary SG layout table
distance	dc.w	0			Distance of monster
monsize	dc.w	0			Size of monster
nummon	dc.w	0			Number of active monsters
hitmon	dc.w	6,3,2,4,1,2,3		Monster strengths
shiftmsk	dc.w	$ffff,$7fff,$3fff,$1fff,$fff,$7ff,$3ff,$1ff
	dc.w	$ff,$7f,$3f,$1f,$f,$7,$3,$1
shiftmsk2	dc.w	$0,$8000,$c000,$e000,$f000,$f800,$fc00,$fe00
	dc.w	$ff00,$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe

knife	dc.w	0			Holding knife?
macgun	dc.w	0			Holding machine gun?
rlaunch	dc.w	0			Holding rocket launcher?
plasma	dc.w	0			Holding plasma gun?
mapper	dc.w	0			Holding mapper?
radar	dc.w	0			Holding radar?
collect1	dc.w	0			Number of grenades
collect2	dc.w	0			Number of medikits
collect3	dc.w	0			Number of keys
ammo1	dc.w	50			Pistol ammo
ammo2	dc.w	50			Machine-gun ammo
ammo3	dc.w	10			Rocket laucnher ammo
ammo4	dc.w	50			Plasma-gun ammo
weapon	dc.w	3			Selected weapon
withdraw	dc.w	0			How far back weapon is
damage	dc.w	1			Power of current weapon
rocketf	dc.w	0			Direction of rocket
rocketh	dc.w	0			Height of rocket
grenadef	dc.w	0			Direction of grenade
grenadeh	dc.w	0			Height of grenade
grenadec	dc.w	0			Grenade explosion timer
mesc	dc.w	0			Message counter
mesn	dc.w	0			Message number
won	dc.w	0			Have we won or lost?

score	dc.w	0			Current score
shottotal	dc.w	0			No of shots taken
shothits	dc.w	0			No of shots which hit 
beetleh	dc.w	0			Number of beetles killed
roboth	dc.w	0			Number of robots killed
rockmonh	dc.w	0			Number of rockmen killed
mutanth	dc.w	0			Number of mutants killed
gunposth	dc.w	0			Number of gunposts killed
bath	dc.w	0			Number of bats killed
ghosth	dc.w	0			Number of ghosts killed
	even

	*Stack
	ds.l	100			Stacks go backwards
mystack	dc.l	0			Space for stack