	OPT d+			Long labels for debugging
	move.l	a7,a5		Save stack pointer
	move.l	#stack,sp		Set up out own stack
	BRA	savemem		Free memory for replayer
start	BSR	init		Initialise program
rstart	BSR	title		Title screen
	move.w	#0,bluewin	Reset blue's score
	move.w	#0,purpwin	Reset purple's score
	cmp.w	#0,mode		Is it 2 player mode
	bgt	get2pldat		Yes, load 2 player data
	move.w	#1,newgame	It is a new game
levwon	BSR	initlev		Initialise level
	move.w	#0,newgame	It isn't a new game
	BSR	clw		Clear screen
	BSR	scrnswap		Set up double buffered screens
	move.w	#0,keypress	Clear keyboard buffer
	cmp.w	#2,mode		Are we on competative mode?
	beq	setclock		Yes, set up clock
mainloop	cmp.w	#0,mode		Are we on two player mode?
	bgt	tplmod		Yes, alternate player counter
tplmodr	move.l	#pl1draw,-(sp)	Return address
	cmp.w	#0,mode		Is it player one?
	beq	drawscrn		Yes, draw player one's screen
	addq.l	#4,sp		Correct stack
pl1draw	BSR	checkjoy		Check controls
	BSR	moveblck		Move moving blocks
	BSR	lookdown		What are we standing on?
	BSR	killcrum		Destroy crumbling blocks
	BSR	pullme		Look for attractors/repellers
	BSR	moveblob		Move players sprite
	move.l	#pl2draw,-(sp)	Return address
	cmp.w	#0,mode		Is it player two?
	bgt	drawscrn		Yes, draw player two's screen
	addq.l	#4,sp		Correct stack
pl2draw	BSR	chckkeys		Check keyboard
	BSR	chckblue		Have we won?
	cmp.w	#1,death		Are we dead?
	beq	loselife		Lose a life
	cmp.w	#2,mode		On two player mode?
	beq	chcktime		Are we out of time yet?
lose2	cmp.w	#1,death		Are we still dead?
	bne	mainloop		Yes we are
	move.w	#1,slide		Reset movement counter
	move.w	#0,somerslt	Reset somersault counter
	move.w	#0,jetp		Reset jetpack counter
	BSR	clw		Clear the screen
	BSR	scrnswap		Reveal the new screen
	cmp.w	#1,won		Have we won?
	beq	nextlev		Yes, go onto next level
	move.w	#1,plyno		Reset to master joystick
	BSR	gameover		Goto gameover routine
wewon3	BSR	stopquart		Stop quartet music
	BRA	rstart		Start the game again
	BSR	end		End the program

chcktime	cmp.w	#0,timelmt	Out of time
	bne	lose2		No, return
	move.w	#1,death		We are dead
	move.w	#1,won		Move to next level
	bsr	clw		Clear screen
	bsr	countblck		Count number of blocks
	cmp.w	d6,d7		Who painted most?
	bgt	pl1won		Player 1 did
	cmp.w	d6,d7		Who painted most?
	beq	draw		It was a draw
	add.w	#1,bluewin	Blue won
showscore	move.l	#cmpscore3,a0	Space for purple blocks message
	move.w	d7,d5		Copy d7
	ext.l	d7		Extend d7
	divu.w	#100,d7		Divide d7 by 100
	move.w	d7,d4		Make copy of d7
	add.w	#$30,d7		Convert to ascii
	move.b	d7,(a0)+		Store first digit
	ext.l	d4		Extend d4
	mulu.w	#100,d4		Multiply d4 by 100
	sub.w	d4,d5		Subtract to find second digit
	move.w	d5,d7		Make copy of number
	ext.l	d7		Extend d7
	divu.w	#10,d7		Divide d7 by 10
	move.w	d7,d4		Make copy of d7
	add.w	#$30,d7		Convert to ascii
	move.b	d7,(a0)+		Store second digit
	ext.l	d4		Extend d4
	mulu.w	#10,d4		Multiply d4 by 10
	sub.w	d4,d5		Subtract to find third digit
	add.w	#$30,d5		Convert to ascii
	move.b	d5,(a0)+		Store third digit
	move.l	#cmpscore5,a0	Space for blue blocks message
	move.w	d6,d7		Get number of blue blocks
	move.w	d7,d5		Copy d7
	ext.l	d7		Extend d7
	divu.w	#100,d7		Divide d7 by 100
	move.w	d7,d4		Make copy of d7
	add.w	#$30,d7		Convert to ascii
	move.b	d7,(a0)+		Store first digit
	ext.l	d4		Extend d4
	mulu.w	#100,d4		Multiply d4 by 100
	sub.w	d4,d5		Subtract to find second digit
	move.w	d5,d7		Make copy of number
	ext.l	d7		Extend d7
	divu.w	#10,d7		Divide d7 by 10
	move.w	d7,d4		Make copy of d7
	add.w	#$30,d7		Convert to ascii
	move.b	d7,(a0)+		Store second digit
	ext.l	d4		Extend d4
	mulu.w	#10,d4		Multiply d4 by 10
	sub.w	d4,d5		Subtract to find third digit
	add.w	#$30,d5		Convert to ascii
	move.b	d5,(a0)+		Store third digit
	move.l	#cmpscore7,a0	Space for player 1's score
	move.w	purpwin,d7	Number of levels one by purple
	move.w	d7,d5		Make copy of d7
	ext.l	d7		Extend d7
	divu.w	#10,d7		Divide d7 by 10
	move.w	d7,d4		Make copy of d7
	add.w	#$30,d7		Convert to ascii
	move.b	d7,(a0)+		Store first digit
	ext.l	d4		Extend d4
	mulu.w	#10,d4		Multiply d4 by 10
	sub.w	d4,d5		Subtract to find third digit
	add.w	#$30,d5		Convert to ascii
	move.b	d5,(a0)+		Store second digit
	move.l	#cmpscore9,a0	Space for player 1's score
	move.w	bluewin,d7	Number of levels one by purple
	move.w	d7,d5		Make copy of d7
	ext.l	d7		Extend d7
	divu.w	#10,d7		Divide d7 by 10
	move.w	d7,d4		Make copy of d7
	add.w	#$30,d7		Convert to ascii
	move.b	d7,(a0)+		Store first digit
	ext.l	d4		Extend d4
	mulu.w	#10,d4		Multiply d4 by 10
	sub.w	d4,d5		Subtract to find third digit
	add.w	#$30,d5		Convert to ascii
	move.b	d5,(a0)+		Store second digit
	move.l	#cmpscore,a5	Message to draw
	move.w	#136,d2		X coordinate
	move.w	#48,d3		Y coordinate
	bsr	drawmes		Draw it
	move.l	#cmpscore2,a5	Message to draw
	move.w	#52,d2		X coordinate
	move.w	#80,d3		Y coordinate
	bsr	drawmes		Draw it
	move.l	#cmpscore4,a5	Message to draw
	move.w	#60,d2		X coordinate
	move.w	#96,d3		Y coordinate
	bsr	drawmes		Draw it
	move.l	#cmpscore6,a5	Message to draw
	move.w	#56,d2		X coordinate
	move.w	#128,d3		Y coordinate
	bsr	drawmes		Draw it
	move.l	#cmpscore8,a5	Message to draw
	move.w	#56,d2		X coordinate
	move.w	#144,d3		Y coordinate
	bsr	drawmes		Draw it
	move.w	#50,d0		Top left X
	move.w	#46,d1		Top left Y
	move.w	#270,d2		Bottom right x
	move.w	#162,d3		Bottom right y
	bsr	border		Draw a border
	bsr	scrnswap		Reveal screen
	move.l	#0,d7		Reset counter
cmpdelay	addq.l	#1,d7		Move up counter
	cmp.l	#1500000,d7	Do we wait longer?
	bne	cmpdelay		Yes loop around
	bra	lose2		Return

pl1won	add.w	#1,purpwin	Purple won
	bra	showscore		Now show the score

draw	add.w	#1,purpwin	It was a draw
	add.w	#1,bluewin	Both players score
	bra	showscore		Now show the score

tplmod	add.w	#1,plyno		Move up player counter
	cmp.w	#3,plyno		Do we go back to player one?
	beq	play1		Yes, reset variable
play1r	bsr	swapvars		Swap variables
	bsr	checkbump		Have we collided?
	cmp.w	#2,mode		Are we on competative mode
	beq	moveclock		Yes, update clock
clockr	bra	tplmodr		Return

moveclock	bsr	getclock		Get system clock variable
	move.l	oldclock,d1	Get oldclock variable
	add.l	#16,d1		Clock counts in 16ths of a second
	cmp.l	d1,d0		Do we move down timer yet?
	bgt	movetimer		Yes, we do
	sub.l	#100,d1		Move back clock
	cmp.l	d1,d0		Has the timer reset?
	blt	mvetimer2		Yes, reset ours also
	bra	clockr		Return

setclock	bsr	getclock		Get system clock variable
	move.l	d0,oldclock	Set up our clock from it
	bra	mainloop		Return

movetimer	move.l	d1,oldclock	Move up our clock
	sub.b	#1,timelmt	Move down time limit
	cmp.w	#0,ddelay		Are controls locked?
	bne	unlock		Yes, unlock them
unlock2	bsr	swapvars		Check other player
	cmp.w	#0,ddelay		Are controls locked?
	bne	unlock3		Yes, unlock them
unlock4	bsr	swapvars		Swap variables back
	bra	clockr		Return

unlock	sub.w	#1,ddelay		Reduce time penalty
	bra	unlock2		Return

unlock3	sub.w	#1,ddelay		Reduce time penalty
	bra	unlock4		Return

mvetimer2	move.l	d0,oldclock	Move up our clock
	bra	clockr		Return

checkbump	move.l	#player2,a6	Address of player 2's variables
	add.l	#42,a6		Address of coordinates
	move.l	#coord,a5		Address of player 1's variables
	move.w	2(a5),d0		Get level
	cmp.w	2(a6),d0		On same level?
	bne	return		No, return
	move.w	(a5),d0		Get height
	cmp.w	(a6),d0		At same height?
	bne	return		No, return
	move.w	6(a5),d0		Get Xcoordinate
	move.w	d0,d1		Make copy
	sub.w	#30,d0		Find left limit
	add.w	#30,d1		Find right limit
	move.w	6(a6),d2		Find other player's Xcoordinate
	cmp.w	d0,d2		Check left edge
	blt	return		In range?
	cmp.w	d1,d2		Check right edge
	bgt	return		In range?
	move.w	4(a5),d0		Get Ycoordinate
	move.w	d0,d1		Make copy
	sub.w	#30,d0		Find left limit
	add.w	#30,d1		Find right limit
	move.w	4(a6),d2		Find other player's Ycoordinate
	cmp.w	d0,d2		Check top edge
	blt	return		In range?
	cmp.w	d1,d2		Check bottom edge
	bgt	return		In range?
	cmp.w	#1,16(a6)		Are we jumping?
	beq	jumppl1		Yes, push up player 1
	cmp.w	#1,16(a5)		Is the other player jumping?
	beq	jumppl2		Yes, push up player 2
	cmp.w	#1,18(a6)		Are we falling
	beq	jumppl2		Yes, bounce up player 2
	cmp.w	#1,18(a5)		Is the other player falling?
	beq	jumppl1		Yes, bounce up player 1
	move.w	28(a5),d0		Get Xmomentum of player 1
	move.w	28(a6),28(a5)	Swap momentum's
	move.w	d0,28(a6)		Store other momentum
	move.w	30(a5),d0		Get Ymomentum of player 1
	move.w	30(a6),30(a5)	Swap momentum's
	move.w	d0,30(a6)		Store other momentum
	move.w	6(a6),d0		Find Xmomentum
	cmp.w	6(a5),d0		Are we left or right?
	blt	bumpleft		Bump player 2 left
bumpright	sub.w	#2,28(a5)		Ampilfy collision
	add.w	#2,28(a6)		Other player moves other way
bumpr	move.w	4(a6),d0		Find Ymomentum
	cmp.w	4(a5),d0		Are we up or down?
	blt	bumpup		Bump player 2 up
bumpdown	sub.w	#2,30(a5)		Amplify collision
	add.w	#2,30(a6)		Other player moves other way
	rts			Return

bumpup	sub.w	#2,30(a6)		Amplify collision
	add.w	#2,30(a5)		Other player moves other way
	rts			Return

bumpleft	sub.w	#2,28(A6)		Amplify collision
	add.w	#2,28(a5)		Other player moves other way
	bra	bumpr		Return

jumppl1	move.w	#6,16(a5)		Make player 1 jump
	move.w	#0,18(a5)		He isn't falling
	move.w	#0,16(a6)		Stop other player
	rts			Return

jumppl2	move.w	#6,16(a6)		Make player 2 jump
	move.w	#0,18(a6)		He isn't falling
	move.w	#0,16(a5)		Stop other player
	rts			Return

play1	move.w	#1,plyno		Reset player no variable
	bra	play1r		Return

gameover	bsr	clw		Clear the screen
	bsr	scrnswap		Reveal screen
	cmp.w	#2,mode		On competative mode?
	beq	return		No quit sequence
	bsr	inpalt		Get palette
	bsr	clw		Clear the screen
	move.l	#yourscore,a5	Address of message
	move.w	#124,d2		X coordinate
	move.w	#80,d3		Y coordinate
	bsr	drawmes		Draw message
	move.l	score,d0		Get score
	move.w	d0,d1		Make copy for 1st digit
	lsr.w	#2,d1		Divide by 4
	divu.w	#25000,d1		Divide by 25000
	move.l	#points2,a0	Address to store numbers
	add.w	#$30,d1		Convert to ascii
	move.b	d1,(a0)+		Store number
	sub.w	#$30,d1		Convert back to normal
	mulu.w	#25000,d1		Multiply by 25000
	lsl.w	#2,d1		Multiply by 4
	sub.w	d1,d0		Subtract from original score
	move.w	d0,d1		Make copy for 2nd digit
	divu.w	#10000,d1		Divide by 10000
	add.w	#$30,d1		Convert to ascii
	move.b	d1,(a0)+		Store number
	sub.w	#$30,d1		Convert back to normal
	mulu.w	#10000,d1		Multiply by 10000
	sub.w	d1,d0		Subtract from original score
	move.w	d0,d1		Make copy for 3rd digit
	divu.w	#1000,d1		Divide by 1000
	add.w	#$30,d1		Convert to ascii
	move.b	d1,(a0)+		Store number
	sub.w	#$30,d1		Convert back to normal
	mulu.w	#1000,d1		Multiply by 1000
	sub.w	d1,d0		Subtract from original score
	move.w	d0,d1		Make copy for 4th digit
	divu.w	#100,d1		Divide by 100
	add.w	#$30,d1		Convert to ascii
	move.b	d1,(a0)+		Store number
	sub.w	#$30,d1		Convert back to normal
	mulu.w	#100,d1		Multiply by 100
	sub.w	d1,d0		Subtract from original score
	move.w	d0,d1		Make copy for 5th digit
	divu.w	#10,d1		Divide by 10
	add.w	#$30,d1		Convert to ascii
	move.b	d1,(a0)+		Store number
	sub.w	#$30,d1		Convert back to normal
	mulu.w	#10,d1		Multiply by 10
	sub.w	d1,d0		Subtract from original score
	add.w	#$30,d0		Convert last digit to ascii
	move.b	d0,(a0)+		Store last number
	move.l	#points,a5	Address of message
	move.w	#92,d2		X coordinate
	move.w	#100,d3		Y coordinate
	bsr	drawmes		Draw message
	move.w	#90,d0		Top left X
	move.w	#78,d1		Top left Y
	move.w	#230,d2		Bottom right X
	move.w	#118,d3		Bottom right Y
	bsr	border		Draw border
	bsr	scrnswap		Reveal screen
	move.l	score,d0		Get score back again
	move.l	#hiscores2,a0	Address of hiscore table
	lea	18(a0),a0		Move to first score
	move.w	#0,d2		Zero counter
gameover2	move.l	(a0),d1		Retrieve score
	cmp.l	d1,d0		Did we beat it?
	bgt	gameover3		Yes, we have a highscore
	lea	22(a0),a0		Move to next score
	add.w	#1,d2		Move up counter
	cmp.w	#10,d2		Any more scores left
	bne	gameover2		Yes, check next score
	rts			Return

gameover3	move.l	#0,d7		Reset counter
delay	addq.l	#1,d7		Move up counter
	cmp.l	#200000,d7	Do we wait longer?
	bne	delay		Yes loop around
	move.l	#tableend,a1	Find end of table
	sub.l	#4,a1		Move to last score
	cmp.l	a1,a0		Have we got the bottom score?
	beq	gameover5		Yes, no need to move anything up
	sub.l	#18,a1		Move to start of score
	move.l	a1,a2		Make copy of pointer
	move.w	#10,d3		Set counter
	add.w	#1,d2		D2 points to our score position
	sub.l	#22,a2		Move to previous score
gameover4	move.l	(a2)+,(a1)+	Move score down a bit
	move.l	(a2)+,(a1)+	Move next piece
	move.l	(a2)+,(a1)+	Move next piece
	move.l	(a2)+,(a1)+	Move next piece
	move.l	(a2)+,(a1)+	Move next piece
	move.w	(a2)+,(a1)+	Move down last piece
	sub.w	#1,d3		Move up counter
	sub.l	#44,a2		Move up one score
	sub.l	#44,a1		On both pointers
	cmp.w	d2,d3		All moved up yet?
	bne	gameover4		No copy next piece
	lea	18(a1),a1		Point a1 to actual score
gameover5	sub.l	#18,a1		A1 points to space for our score
	move.l	a1,ourscore	Make a copy of a1
	move.l	#yourname,a1	Address of name buffer
	move.l	#0,(a1)+		Wipe buffer
	move.l	#0,(a1)+		Wipe buffer
	move.l	#0,(a1)+		Wipe buffer
	move.l	#yourname,a1	Address of name buffer
gameover6	bsr	clw		Clear the screen
	move.l	#hiscores3,a5	Address of message
	move.w	#100,d2		Xcoordinate
	move.w	#70,d3		Ycoordinate
	bsr	drawmes		Draw it
	move.l	#hiscores4,a5	Address of message
	move.w	#76,d2		Xcoordinate
	move.w	#85,d3		Ycoordinate
	bsr	drawmes		Draw it
	move.l	#hiscores5,a5	Address of message
	move.w	#72,d2		Xcoordinate
	move.w	#100,d3		Ycoordinate
	bsr	drawmes		Draw it
	move.l	#yourname,a0	Address of our name
	move.w	#0,d0		Length counter
gameover7	cmp.b	#0,(a0)+		Is there still a letter
	beq	gameover8		No, we know the length
	add.w	#1,d0		Yes, move up the counter
	bra	gameover7		Check for another letter
gameover8	move.l	#yourname,a5	Address of message
	move.w	#160,d2		Xcoordinate
	lsl.w	#2,d0		Multiply length by 4
	sub.w	d0,d2		To find xcoordinate
	move.w	#115,d3		Ycoordinate
	bsr	drawmes		Draw it
	move.w	#70,d0		Top left X coordinate
	move.w	#68,d1		Top left Y coordinate
	move.w	#250,d2		Bottom right X coordinate
	move.w	#133,d3		Bottom right Y coordinate
	bsr	border		Draw border
	bsr	scrnswap		Reveal screen
	move.w	#$ff,-(sp)	Test keyboard
	move.w	#6,-(sp)		Function number
	trap	#1		Call GEMDOS
	addq.l	#4,sp		Correct stack
	tst.w	d0		Charactor arrived?
	bne	addletg		Yes, add letter
addlet2g	bra	gameover6		check some more		
gameover9	move.l	#yourname,a0	Address of message
	move.l	ourscore,a1	Address of space
	move.l	(a0)+,(a1)+	Copy name into space
	move.l	(a0)+,(a1)+	Copy name into space
	move.w	(a0)+,(a1)+	Copy name into space
	move.b	(a0)+,(a1)+	Copy name into space
	move.l	#points2,a0	Address of our score
	move.b	(a0)+,(a1)+	Copy score into space
	move.b	(a0)+,(a1)+	Copy score into space
	move.b	(a0)+,(a1)+	Copy score into space
	move.b	(a0)+,(a1)+	Copy score into space
	move.b	(a0)+,(a1)+	Copy score into space
	move.b	(a0)+,(a1)+	Copy score into space
	move.b	#0,(a1)+		Indicate end of string
	move.l	score,(a1)+	Copy actual score underneath
	move.l	ourscore,a0	Address of space
	move.w	#0,d0		Reset counter
nogaps	cmp.b	#0,(a0)+		Is it a gap?
	beq	filgap		Yes, fill it
filgapr	add.w	#1,d0		Move up counter
	cmp.w	#17,d0		All checked yet?
	bne	nogaps		No, check some more
	bsr	clw		Clear the screen
	bsr	showtable		Draw high score table
	bsr	stopquart		Stop quartet music
	bsr	savehi		Save hiscores
	move.l	(sp)+,d0		Take old address of stack
	move.l	#rstart,-(sp)	Return to restart address
	rts			Return

filgap	sub.l	#1,a0		Move back 1 space
	move.b	#32,(a0)+		Put space in gap
	bra	filgapr		Return

showtable	move.l	#hiscores,a5	Address of message
	move.w	#108,d2		X coordinate
	move.w	#20,d3		Y coordinate
	bsr	drawmes		Draw message
	move.w	#0,d6		Reset counter
showtab2	move.w	d6,d3		Make copy of counter
	mulu.w	#22,d3		Find height on table
	move.l	#hiscores2,a5	Address of hiscores
	add.l	d3,a5		Find address of highscore
	move.w	d6,d3		Make copy of counter
	mulu.w	#13,d3		Find height on screen
	add.w	#50,d3		Y coordinate
	move.w	#88,d2		X coordinate
	bsr	drawmes		Draw message
	add.w	#1,d6		Move up counter
	cmp.w	#10,d6		All done yet?
	bne	showtab2		No, draw next score
	move.w	#86,d0		Top left X coordinate
	move.w	#18,d1		Top left Y coordinate
	move.w	#226,d2		Bottom right X coordinate
	move.w	#183,d3		Bottom right Y coordinate
	bsr	border		Draw the border
	bsr	scrnswap		Show screen
	rts			Return

addletg	cmp.w	#8,d0		Is it delete
	beq	delletg		Yes, erase 1 letter
	cmp.w	#13,d0		Is it return
	beq	gameover9		Yes, return completly
	cmp.w	#32,d0		Is it a space
	beq	allowsp		Yes, allow space bar
	cmp.w	#90,d0		Is it capital
	bgt	makecapsg		No, convert it
makecap2g	cmp.w	#90,d0		Is it in range
	bgt	addlet2g		No, return
	cmp.w	#65,d0		Is it in range
	blt	addlet2g		No, return
allowsp	move.l	#yourname,a0	Address of our name
	move.w	#1,d1		Reset counter
addlet3g	cmp.b	#0,(a0)		Is it a blank space
	beq	addlet4g		Yes, exit loop
	add.w	#1,d1		Move up counter
	add.w	#1,a0		Move up pointer
	cmp.w	#11,d1		Are we out of room
	beq	addlet2g		Yes, return
	bra	addlet3g		No, Check for next space
addlet4g	move.b	d0,(a0)		Store letter in space
	bra	addlet2g		Return

delletg	move.l	#yourname,a0	Address of our name
	move.w	#0,d1		Reset counter
dellet2g	cmp.b	#0,(a0)		Is it a blank space
	beq	dellet3g		Yes, exit loop
	add.w	#1,d1		Move up counter
	add.w	#1,a0		Move up pointer
	bra	dellet2g		Check next space
dellet3g	cmp.w	#0,d1		Any letters
	beq	addlet2g		No, return
	sub.w	#1,a0		Move back pointer
	move.b	#0,(a0)		Wipe out letter
	bra	addlet2g		Return

makecapsg	sub.w	#32,d0		Make into capital letter
	bra	makecap2g		Return
	
checkend2	cmp.w	#31,clevel	Have we won?
	beq	wewon		Yes, no more levels
	bra	checkend3		No, return

checkend4	cmp.w	#41,clevel	Have we won?
	beq	wewon		Yes, no more levels
	bra	checkend5		No, return

nextlev	move.w	#0,death		No longer dead
	add.w	#1,clevel		Move up to next level
	cmp.w	#51,clevel	Have we won?
	beq	wewon		Yes, no more levels
	cmp.w	#1,mode		Team mode?
	beq	checkend2		Yes different number of levels
checkend3	cmp.w	#2,mode		Competition mode?
	beq	checkend4		Yes different number of levels
checkend5	bsr	prompt		Bring up level prompt
	move.w	#-1,-(sp)		don't change mode
	move.l	screen_1,-(sp)	change physical address
	move.l	screen_1,-(sp)	change logical address
	move.w	#5,-(sp)		change screen parameters
	trap	#14		Call XBIOS
	lea	12(sp),sp		Correct stack
	move.w	#37,-(sp)		Wait for Vsync
	trap	#14		Call XBIOS
	addq.l	#2,sp		Correct stack
	bsr	stopquart		Stop quartet music
	bra	levwon		Load next level

pausebox	bsr	clw		Clear screen
	move.l	#pause,a5		Message to draw
	move.w	#116,d2		Xcoordinate
	move.w	#87,d3		Y coordinate
	bsr	drawmes		Draw message
	move.l	#pause2,a5	Message to draw
	move.w	#108,d2		X coordinate
	move.w	#100,d3		Y coordinate
	bsr	drawmes		Draw message
	move.w	#106,d0		Top left X coordinate
	move.w	#85,d1		Top left Y coordinate
	move.w	#214,d2		Bottom right X coordinate
	move.w	#116,d3		Bottom right Y coordiante
	bsr	border		Draw the border
	bsr	scrnswap		Show the screen
pausebox2	MOVE.W	#$FF,-(sp)	Check Keyboard
	MOVE.W	#6,-(sp)		Function number
	TRAP	#1		Call GEMDOS
	ADDQ.L	#4,sp		Correct stack
	SWAP	D0		Get scancode
	cmp.w	#0,d0		Key pressed?
	bne	pausebox2		Yes, wait for depress
pausebox3	move.w	#$ff,-(sp)	Check Keyboard
	move.w	#6,-(sp)		Function number
	trap	#1		Call GEMDOS
	addq.l	#4,sp		Correct stack
	swap	d0		Get scancode
	cmp.w	#0,d0		Key pressed?
	beq	pausebox3		No, wait for key press
pausebox4	MOVE.W	#$FF,-(sp)	Check Keyboard
	MOVE.W	#6,-(sp)		Function number
	TRAP	#1		Call GEMDOS
	ADDQ.L	#4,sp		Correct stack
	SWAP	D0		Get scancode
	cmp.w	#0,d0		Key pressed?
	bne	pausebox4		Yes, wait for depress
	rts			Return

wewon	cmp.w	#2,mode		On comptative mode?
	beq	wewon2		Yes, no message
	bsr	clw		Clear screen
	move.l	#won1,a5		Message to draw
	move.w	#100,d2		X coordinate
	move.w	#87,d3		Y coordinate
	bsr	drawmes		Draw message
	move.l	#won2,a5		Message to draw
	move.w	#112,d2		X coordinate
	move.w	#100,d3		Y coordinate
	bsr	drawmes		Draw message
	move.w	#98,d0		Top left X coordinate
	move.w	#85,d1		Top left Y coordinate
	move.w	#222,d2		Bottom right X coordinate
	move.w	#116,d3		Bottom right Y coordinate
	bsr	border		Draw the border
	bsr	scrnswap		Show screen
wewon2	move.w	#1,plyno		Reset to master joystick
	bra	wewon3		Return

nocheck	move.w	keypress,d0	Key pressed
	bra	nocheck2		Return

chckkeys	cmp.w	#0,mode		1 player mode?
	beq	nobuff		Yes, don't use buffer
	cmp.w	#1,plyno		Player 1?
	bne	nocheck		No, don't check keys
nobuff	MOVE.W	#$FF,-(sp)	Check Keyboard
	MOVE.W	#6,-(sp)		Function number
	TRAP	#1		Call GEMDOS
	ADDQ.L	#4,sp		Correct stack
	SWAP	D0		Get scancode
	MOVE.W	d0,keypress	Store keypress
nocheck2	CMP.B	#0,D0		Key pressed?
	BEQ	return		No, return
	CMP.B	#59,d0		Quit?
	BEQ	quitopts		Gosub quit routine
	cmp.b	#60,d0		Pause?
	beq	pausebox		Pause routine
	cmp.w	#2,plyno		Player 2?
	beq	pl2keys		Yes, use differant keys
pl2keysr	CMP.B	#68,d0		Dynamite activated?
	BEQ	activdyna		Activate dynamite
	CMP.B	#67,d0		Jetpack activated?
	BEQ	activjetp		Activate jetpack
	cmp.b	#61,d0		Break point?
	BEQ	testr		Goto test routine
	RTS			Return	

pl2keys	add.b	#2,d0		Use keys f7 and f8
	bra	pl2keysr		Return

testr	rts			Place breakpoint here

activdyna	cmp.w	#3,dynamite	Any dynamite?
	beq	return		No so we can't explode it
	add.w	#1,dynamite	Decrease amount of dynamite
	move.w	#1,blowdyna	Set variable to explode
	rts			Return

activjetp	cmp.w	#3,jetpack	Any jetpacks?
	beq	return		No so we can't use them
	add.w	#1,jetpack	Decrease amount of jetpacks
	move.w	#12,jump		Jump extra high whatever
	move.w	#12,jetp		Draw jetpack for 12 frames
	rts			Return

quitopts	move.w	#1,death		We are dead
	move.w	#3,lives		Remove remaining lives
	rts			Return

loselife	cmp.w	#1,won		Have we won?
	beq	lose2		Yes, don't lose a life
	bsr	drawdead		Do death animation
	cmp.w	#3,lives		Have we any lives left
	beq	lose2		No. We are dead this time
	cmp.w	#2,mode		Are we on competative mode?
	beq	compdie		Yes, we don't die
	add.w	#1,lives		Decrease number of lives
	bsr	copymap		Restore map
	bsr	copymov		Restore moving blocks
	bsr	copypull		Restore attractors/repellers
	bsr	varibles		Get starting coordinates
	move.w	#0,death		We aren't dead yet
	bra	lose2		Return

compdie	move.w	#0,d4		Set up counter
	bsr	vars2r		Set up variables
	bsr	swapvars		Swap variables back
	move.w	#10,ddelay	Time penalty of ten seconds
	move.w	#0,death		We aren't dead yet
	bra	lose2		Return

savemem	move.l	4(a5),a5		Find base page start
	move.l	$c(a5),d0		Length of program area
	add.l	$14(a5),d0	Length of data area
	add.l	$1c(a5),d0	Length of data area
	add.l	#$100,d0		100 bytes for base page
	move.l	d0,-(sp)		Length of area to reserve
	move.l	a5,-(sp)		Start to area to reserve
	move.w	#0,-(sp)		Blank word
	move.w	#$4a,-(sp)	Function number
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	tst.l	d0		Check for errors
	bne	error		Error found?
	bra	start		Return

getclock	move.l	myclock,d0	Get clock variable
	rts			Return

lookdown	move.l	#coord,a6		Address of Coordinates
	movem.w	(a6),d4-d7	Restore coordinates
	move.w	d4,height		Store height
	move.b	#1,d0		Set falling variable
	mulu.w	#25,d5		Adjust Z coordinate
	move.l	#map,a0		Address of mapdata
	add.w	d5,a0		Add on d5
	add.w	#24,a0		Go to end of level

	move.w	d7,d3		Copy Xcoordinate
	add.w	#66,d3		Add 66 to find left edge
	lsr	#5,d3		Divide by 32 to find square
	move.w	d6,d4		Copy Ycoordinate
	add.w	#66,d4		Add 66 to find top edge
	lsr	#5,d4		Divide by 32 to find square
	mulu.w	#5,d4		Multiply by 5 to get address
	move.w	d7,d2		Copy Xcoordinate
	add.w	#94,d2		Add 94 to find right edge
	lsr	#5,d2		Divide by 32 to find square
	move.w	d6,d1		Copy Ycoordinate
	add.w	#94,d1		Add 94 to find bottom edge
	lsr	#5,d1		Divide by 32 to find square
	mulu.w	#5,d1		Multiply by 5 to get address

	move.l	a0,a5		Address of map data
	sub.w	d4,a5		subtract top ycoordinate
	move.l	a5,a4		Copy to a4
	sub.w	d3,a5		subtract left xcoordinate	
	sub.w	d2,a4		subtract right xcoordinate

	move.l	a0,a3		Address of map data
	sub.w	d1,a3		subtract bottom ycoordinate
	move.l	a3,a2		Copy to a2
	sub.w	d3,a3		subtract left xcoordinate
	sub.w	d2,a2		subtract right xcoordinate

	divu.w	#5,d4		Put d4 back to normal
	divu.w	#5,d1		Put d1 back to normal

check1	cmp.w	#0,d3		Are we off the edge
	blt	noa5a3		Zero a5 and a3
	cmp.w	#4,d3		Are we off the edge
	bgt	noa5a3		Zero a5 and a3
check2	cmp.w	#0,d2		Are we off the edge
	blt	noa4a2		Zero a4 and a2
	cmp.w	#4,d2		Are we off the edge
	bgt	noa4a2		Zero a4 and a2
check3	cmp.w	#0,d4		Are we off the edge
	blt	noa5a4		Zero a5 and a4
	cmp.w	#4,d4		Are we off the edge
	bgt	noa5a4		Zero a5 and a4
check4	cmp.w	#0,d1		Are we off the edge
	blt	noa3a2		Zero a3 and a2
	cmp.w	#4,d1		Are we off the edge
	bgt	noa3a2		Zero a3 and a2

check5	movem.l	a2-a5/d1-d4,-(sp)	Store reigisters
	bsr	checkmov		Are we standing on a moving block?
	movem.l	(sp)+,a2-a5/d1-d4	Restore registers
	move.l	a0,-(sp)		Preserve a0
	move.l	a2,a6		Get block at top left
	cmp.b	#0,(a6)		Are we standing on anything?
	bne	special1		Yes we are
specr1	move.l	a3,a6		Get block at top right
	cmp.b	#0,(a6)		Are we standing on anything?
	bne	special2		Yes we are
specr2	move.l	a4,a6		Get block at bottom left
	cmp.b	#0,(a6)		Are we standing on anything?
	bne	special3		Yes we are
specr3	move.l	a5,a6		Get block at bottom right
	cmp.b	#0,(a6)		Are we standing on anything?
	bne	special4		Yes we are
		
specr4	move.l	(sp)+,a0		Restore a0
	move.l	#coord,a6		Get coordinates
	movem.w	(A6),d4-d7	Restore coordinates
	add.w	#80,d7		Find central block
	add.w	#80,d6		For special blocks
	lsr.w	#5,d7		Divide by 32
	lsr.w	#5,d6		Divide by 32
	mulu.w	#5,d6		Convert to address
	move.l	a0,a6		Address of map data
	sub.w	d6,a6		Find correct line
	sub.w	d7,a6		Find correct line
	divu.w	#5,d6		Put d6 back to normal
	cmp.w	#1,blowdyna	Is dynamite triggered?
	beq	explode		Yes, explode it
	cmp.w	#0,d7		Are we off the left
	blt	look2		Yes, No block
	cmp.w	#4,d7		Are we off the right
	bgt	look2		Yes, No block
	cmp.w	#0,d6		Are we off the top
	blt	look2		Yes, No block
	cmp.w	#4,d6		Are we off the bottom
	bgt	look2		Yes, No block
	cmp.b	#0,(A6)		Are we standing on anything
	bne	spec2		Yes look up on table

look2	move.w	d0,fall		Store falling status
	rts			Return


special1	cmp.w	#2,d0		Are we on moving block
	beq	skipz1		Yes, don't cancel its effect
	move.w	#0,d0		We aren't falling
skipz1	move.w	#4,d7		Position 4
	bsr	specials		Check for special blocks
	bra	specr1		Return

special2	cmp.w	#2,d0		Are we on moving block
	beq	skipz2		Yes, don't cancel its effect
	move.w	#0,d0		We aren't falling
skipz2	move.w	#3,d7		Position 3
	bsr	specials		Check for special blocks
	bra	specr2		Return

special3	cmp.w	#2,d0		Are we on moving block
	beq	skipz3		Yes, don't cancel its effect
	move.w	#0,d0		We aren't falling
skipz3	move.w	#2,d7		Position 2
	bsr	specials		Check for special blocks
	bra	specr3		Return

special4	cmp.w	#2,d0		Are we on moving block
	beq	skipz4		Yes, don't cancel its effect
	move.w	#0,d0		We aren't falling
skipz4	move.w	#1,d7		Position 1
	bsr	specials		Check for special blocks
	bra	specr4		Return

specials	cmp.w	#0,height		Are we actually on block
	bne	return		No, just above it
	cmp.b	#16,(a6)		Is it a sticky block
	beq	sticky		Yes, so we can't jump
	cmp.b	#15,(a6)		Is it a cracked block?
	beq	cracked		Yes, change status
	cmp.b	#17,(a6)		Is it a forcefield block?
	beq	wall		Yes, bounce us off it
	rts			Return

specialm	cmp.b	#16,d0		Is it a sticky block?
	beq	sticky		Yes, so we can't jump
	cmp.b	#6,d0		Is it a skull block?
	beq	skull		Yes, We are dead
	cmp.b	#5,d0		Is it a paint pot?
	beq	paintpm		Yes, fill up supplies
	cmp.b	#3,d0		Is it a blue block?
	beq	bluebm		Yes, colour it in
	cmp.b	#4,d0		Is it a purple block?
	beq	purplebm		Yes, check for blue paint
	cmp.b	#1,d0		Is it a blue trampoline?
	beq	bluetm		Yes, colour it in
	cmp.b	#2,d0		Is it a purple trampoline?
	beq	purpletm		Yes, extra high bounces
	cmp.b	#12,d0		Is it a bonus block?
	beq	bonusm		Yes, move up score
	cmp.b	#15,d0		Is it a cracked block?
	beq	crackedm		Yes, change status
	cmp.b	#11,d0		Is it a dynamite block?
	beq	dynablckm		Yes, pick it up
	cmp.b	#8,d0		Is it a bomb block?
	beq	explodemo		Yes, explode it!
	cmp.b	#18,d0		Is it a jetpack block?
	beq	jetblckm		Yes, pick it up
	cmp.b	#19,d0		Is it a life block?
	beq	lifem		Yes, pick it up
	cmp.b	#9,d0		Is it a map block?
	beq	mapbm		Yes, draw map on screen
	cmp.b	#10,d0		Is it blue paint?
	beq	bluepm		Yes, pick it up
	cmp.b	#20,d0		Is it a position saver?
	beq	savepm		Yes, store position
	cmp.b	#21,d0		Is it a password block?
	beq	showpasm		Yes show password
	rts			Return

explodemo	move.w	#1,blowdyna	Activate explosion
	move.w	#100,6(a1)	Kill moving block
	rts			Return

killcrum	move.l	#coord,a0		Address of coordinate
	movem.w	(a0),d4-d7	Restore coordinates
	cmp.w	#2,d4		Have we just moved down?
	bgt	sub1d5		Assume we're on level above
killcrum2	move.l	#crumble,a0	Get crumble table
	move.l	#map,a1		Get address of map
	mulu.w	#25,d5		Find address of level
	add.w	d5,a1		Find position in table
	move.w	#0,d0		Zero counter
killcrum3	move.b	(a0),d1		Get data out of table
	cmp.b	#2,d1		Does the block crumble?
	beq	dstrycrum		Destroy it
	cmp.b	#1,d1		Change status
	beq	dsrycrum2		Gosub correct routine
killcrum4	add.w	#1,a1		Move up map counter
	add.w	#1,a0		Move up crumble counter
	add.w	#1,d0		Move up counter
	cmp.w	#25,d0		All checked yet?
	bne	killcrum3		No, check next block
	cmp.w	#0,nummov		Any moving blocks?
	beq	return		No so return
	move.l	#movcrmb,a0	moving cracked blocks
	move.l	#blcoord,a1	moving block coordinates
	move.w	#0,d0		Zero counter
killcrum5	move.b	(a0),d1		Get data out of table
	cmp.b	#3,d1		Does it crumble
	beq	killmov		Yes destroy it
	cmp.b	#0,d1		Change status
	bgt	killmov2		Gosub routine
killcrum6	add.w	#1,a0		Move up crumble counter
	add.w	#18,a1		Move up coordinate counter
	add.w	#1,d0		Move up counter
	cmp.w	nummov,d0		All checked yet?
	bne	killcrum5		No, check next block
	rts			Return

killmov2	add.b	#1,(a0)		Change status
	bra	killcrum6		Return

killmov	move.b	#0,(a0)		Wipe out of table
	move.w	#100,6(a1)	Destroy moving block
	bra	killcrum6		Return

dstrycrum	move.b	#0,(a1)		Wipe off map
	move.b	#0,(a0)		Wipe out of table
	bra	killcrum4		Return

dsrycrum2	move.b	#2,(a0)		Convert type
	bra	killcrum4		Return

sub1d5	sub.w	#1,d5		Look at level above
	bra	killcrum2		Return

crackedm	move.l	a0,-(sp)		Preserve a0
	move.l	#movcrmb,a0	Address of table
	add.w	blckno,a0		Find position in table
	move.b	#1,(a0)		Store status
	move.l	(sp)+,a0		Restore a0
	rts			Return

cracked	cmp.w	#0,jump		Are we jumping
	bne	return		Yes, so block doesn't crack
	movem.w	d3-d4,-(sp)	Store coordinates
	cmp.w	#1,d7		Is it at our top left
	beq	cracked2		Yes, get coordinates
	cmp.w	#2,d7		Is it at our top right
	beq	crack2		Yes, get coordinates
	cmp.w	#3,d7		Is it at bottom left
	beq	crack3		Yes, get coordinates
	cmp.w	#4,d7		Is it at bottom right
	beq	crack4		Yes, get coordinates
cracked2	mulu.w	#5,d4		Convert ycoordinate
	move.l	#crumble,a0	Store data in table
	add.w	#24,a0		Coordinates are stored backwards
	sub.w	d3,a0		Find position of X coordinate
	sub.w	d4,a0		Find position of Y coordinate
	move.b	#1,(a0)		Store position of block
	movem.w	(sp)+,d3-d4	Restore coordinates
	rts			Return

wall	cmp.w	#3,d7		Is it above us
	blt	bounced		Yes bounce down
	bra	bounceu		Otherwise bounce up
wall2	cmp.w	#1,d7		Is it to our left
	beq	bouncer		Yes, bounce right
	cmp.w	#3,d7		Is it to our left
	beq	bouncer		Yes, bounce right
	bra	bouncel		Otherwise bounce left

bounceu	cmp.w	#0,ymomentum	Are we moving up?
	bgt	switchy		Yes reverse y momentum
	bra	wall2		Return

bounced	cmp.w	#0,ymomentum	Are we moving down?
	blt	switchy		Yes reverse y momentum
	bra	wall2		Return

switchy	move.w	d6,-(sp)		Store d6
	move.w	#0,d6		Zero d6
	sub.w	ymomentum,d6	Reverse ymomentum
	move.w	d6,ymomentum	Store new momentum
	move.w	(sp)+,d6		Restore d6
	bra	wall2		Return

bouncel	cmp.w	#0,xmomentum	Are we moving left?
	bgt	switchx		Yes reverse x momentum
	rts			Return

bouncer	cmp.w	#0,xmomentum	Are we moving right?
	blt	switchx		Yes reverse x momentum
	rts			Return

switchx	move.w	d6,-(sp)		Store d6
	move.w	#0,d6		Zero d6
	sub.w	xmomentum,d6	Reverse xmomentum
	move.w	d6,xmomentum	Store new momentum
	move.w	(sp)+,d6		Restore d6
	rts			Return

crack2	move.w	d2,d3		Get coordinate
	bra	cracked2		Return

crack3	move.w	d1,d4		Get coordinate
	bra	cracked2		Return

crack4	move.w	d2,d3		Get xcoordinate
	move.w	d1,d4		Get ycoordinate
	bra	cracked2		Return

skull	move.w	#1,death		Instant death
	rts			Return

skulln	move.w	#1,death		Instant death
	bra	look2		Return

sticky	move.w	#0,fire		Cancel effect of fire button
	move.w	#0,jump		We aren't jumping either
	rts			Return

spec2	cmp.w	#0,height		Are we actually on block
	bne	look2		No, just above it
	cmp.b	#5,(a6)		Is it paint pot?
	beq	paintp		Yes Gosub Correct routine
	cmp.b	#3,(a6)		Is it a blue block?
	beq	blueb		Yes colour it in
	cmp.b	#4,(a6)		Is it a purple block?
	beq	purpleb		Yes, check for blue paint
	cmp.b	#1,(a6)		Is it a blue trampoline?
	beq	bluet		Yes colour it in
	cmp.b	#2,(a6)		Is it a purple trampline?
	beq	purplet		Yes, bounce extra high
	cmp.b	#6,(a6)		Is it a skull block?
	beq	skulln		Yes it is
	cmp.b	#7,(a6)		Is it a teleporter?
	beq	teleport		Yes it is
	cmp.b	#12,(a6)		Is it a bonus block?
	beq	bonus		Yes it is
	cmp.b	#11,(a6)		Is it a dynamite block?
	beq	dynablck		Yes it is
	cmp.b	#8,(a6)		Is it a bomb block?
	beq	explode		Yes it is
	cmp.b	#18,(a6)		Is it a jet pack block?
	beq	jetblck		Yes it is
	cmp.b	#19,(a6)		Is it a life block?
	beq	life		Yes it is
	cmp.b	#9,(a6)		Is it a map block?
	beq	mapb		Yes it is
	cmp.b	#10,(a6)		Is it blue paint?
	beq	bluep		Yes pick it up
	cmp.b	#20,(a6)		Is it a position saver?
	beq	savep		Yes, save position
	cmp.b	#21,(a6)		Is it a password block?
	beq	showpas		Yes, show passwords
	bra	look2		Return

explode	movem.w	d6-d7,-(sp)	Store d6 and d7
	cmp.w	#0,height		Are we on normal blocks?
	beq	explode2		Yes explode them
explode3	cmp.w	#0,nummov		Any moving blocks?
	bne	explodem		blow 'em up!
explode4	movem.w	(sp)+,d6-d7	Restore coordinates
	cmp.w	#0,nopull		Any repellers/attractors?
	bne	explpull		blow them up as well!
explpullr	bsr	explosion		Do explosion animation
	move.w	#0,blowdyna	Dynamite is no longer exploding
	bra	look2		Return

explode2	cmp.b	#-1,d6		Are we out of range?
	blt	explode3		Yes, return
	cmp.b	#5,d6		Are we out of range?
	bgt	explode3		Yes, return
	cmp.b	#-1,d7		Are we out of range?
	blt	explode3		Yes, return
	cmp.b	#5,d7		Are we out of range?
	bgt	explode3		Yes, return

	move.w	#4,d0		Reverse d6
	sub.w	d6,d0		coordinates are stored backwards
	move.w	d0,d6		Store new variable

	move.w	#4,d0		Reverse d7
	sub.w	d7,d0		coordinates are stored backwards
	move.w	d0,d7		Store new variable

	move.l	#range,a0		Address of range matrix
	move.l	#0,(a0)+		Fill in matrix with zeros
	move.l	#0,(a0)+		Next four zeros
	move.b	#0,(a0)+		Fill in last zero
	move.l	#range,a0		Go back to start of matrix
	sub.w	#6,a6		Move to start position

matrix1	cmp.b	#0,d6		Are we very near the top
	blt	wipetm		Yes wipe top and middle rows
	cmp.b	#1,d6		Are we near the top
	blt	wipetop		Yes wipe top row

matrix2	cmp.b	#4,d6		Are we very near the bottom
	bgt	wipebm		Yes wipe bottom and middle rows
	cmp.b	#3,d6		Are we near the bottom
	bgt	wipebot		Yes wipe bottom row

matrix3	cmp.b	#0,d7		Are we very near the left
	blt	wipelm		Yes wipe left and middle rows
	cmp.b	#1,d7		Are we near the left
	blt	wipelef		Yes wipe left row

matrix4	cmp.b	#4,d7		Are we very near the right
	bgt	wiperm		Yes wipe right and middle rows
	cmp.b	#3,d7		Are we near the right
	bgt	wiperig		Yes wipe right row
	
matrix5	cmp.b	#0,(a0)		Destroy top left?
	beq	topleft		Yes destroy it
	add.w	#1,a6		Move up counter
matrix6	cmp.b	#0,1(a0)		Destroy top middle?
	beq	topmid		Yes destroy it
	add.w	#1,a6		Move up counter
matrix7	cmp.b	#0,2(a0)		Destroy top right?
	beq	topright		Yes destroy it
	add.w	#1,a6		Move up counter
matrix8	add.w	#2,a6		Move down row
	cmp.b	#0,3(a0)		Destroy middle left?
	beq	midleft		Yes destroy it
	add.w	#1,a6		Move up counter
matrix9	cmp.b	#0,4(a0)		Destroy middle?
	beq	middle		Yes destory it
	add.w	#1,a6		Move up counter
matrix10	cmp.b	#0,5(a0)		Destroy middle right?
	beq	midright		Yes destroy it
	add.w	#1,a6		Move up counter
matrix11	add.w	#2,a6		Move down row
	cmp.b	#0,6(a0)		Destroy bottom left?
	beq	botleft		Yes destroy it
	add.w	#1,a6		Move up counter
matrix12	cmp.b	#0,7(a0)		Destroy bottom middle?
	beq	botmid		Yes destroy it
	add.w	#1,a6		Move up counter
matrix13	cmp.b	#0,8(a0)		Destroy bottom right?
	beq	botright		Yes destroy it
	add.w	#1,a6		Move up counter
matrix14	bra	explode3		Return

topleft	move.b	#0,(a6)+		Destroy top left block
	bra	matrix6		Return

topmid	move.b	#0,(a6)+		Destroy top middle block
	bra	matrix7		Return

topright	move.b	#0,(a6)+		Destroy top right block
	bra	matrix8		Return

midleft	move.b	#0,(a6)+		Destroy middle left block
	bra	matrix9		Return

middle	move.b	#0,(a6)+		Destroy middle
	bra	matrix10		Return
	
midright	move.b	#0,(a6)+		Destroy middle right
	bra	matrix11		Return

botleft	move.b	#0,(a6)+		Destroy bottom left block
	bra	matrix12		Return

botmid	move.b	#0,(a6)+		Destroy bottom middle
	bra	matrix13		Return

botright	move.b	#0,(a6)+		Destroy bottom right block
	bra	matrix14		Return

wipetop	move.b	#1,(a0)		Delete top left
	move.b	#1,1(a0)		Delete top middle
	move.b	#1,2(a0)		Delete top right
	bra	matrix3		Return

wipetm	move.b	#1,(a0)		Delete top left
	move.b	#1,1(a0)		Delete top middle
	move.b	#1,2(a0)		Delete top right
	move.b	#1,3(a0)		Delete middle left
	move.b	#1,4(a0)		Delete middle
	move.b	#1,5(a0)		Delete middle right
	bra	matrix3		Return

wipebot	move.b	#1,6(a0)		Delete bottom left
	move.b	#1,7(a0)		Delete bottom middle
	move.b	#1,8(a0)		Delete bottom right
	bra	matrix3		Return

wipebm	move.b	#1,3(a0)		Delete middle left
	move.b	#1,4(a0)		Delete middle
	move.b	#1,5(a0)		Delete middle right
	move.b	#1,6(a0)		Delete bottom left
	move.b	#1,7(a0)		Delete bottom middle
	move.b	#1,8(a0)		Delete bottom right
	bra	matrix3		Return

wipelef	move.b	#1,(a0)		Delete top left
	move.b	#1,3(a0)		Delete middle left
	move.b	#1,6(a0)		Delete bottom left
	bra	matrix5		Return

wipelm	move.b	#1,(a0)		Delete top left
	move.b	#1,1(a0)		Delete top middle
	move.b	#1,3(a0)		Delete middle left
	move.b	#1,4(a0)		Delete middle
	move.b	#1,6(a0)		Delete bottom left
	move.b	#1,7(a0)		Delete bottom middle
	bra	matrix5		Return

wiperig	move.b	#1,2(a0)		Delete top right
	move.b	#1,5(a0)		Delete middle right
	move.b	#1,8(a0)		Delete bottom right
	bra	matrix5		Return

wiperm	move.b	#1,1(a0)		Delete top middle
	move.b	#1,2(a0)		Delete top right
	move.b	#1,4(a0)		Delete middle
	move.b	#1,5(a0)		Delete middle right
	move.b	#1,7(a0)		Delete bottom middle
	move.b	#1,8(a0)		Delete bottom right
	bra	matrix5		Return

explodem	move.l	#coord,a0		Get coordinates
	movem.w	(a0),d4-d7	Retrieve into registers
	move.w	#0,d2		Coordinates are stored reversed
	sub.w	d6,d2		So swap them around
	move.w	d2,d6		Copy Y coordinate
	move.w	#0,d3		Coordinates are stored reversed
	sub.w	d7,d3		So swap them aroud
	move.w	d3,d7		Copy X coordinate
	add.w	#114,d2		Convert to coordinate
	add.w	#114,d3		Convert to coordinate
	add.w	#14,d6		Convert to coordinate
	add.w	#14,d7		Convert to coordinate
	move.w	#0,d0		Zero counter
	move.l	#blcoord,a0	Moving block coordinates
explodem2	cmp.w	6(a0),d5		On same level?
	bne	movinup1		No, don't blow them up
	cmp.w	8(a0),d4		On same height?
	bne	movinup2		No, don't blow them up
	cmp.w	2(a0),d3		Is it in range?
	blt	explodem3		No, don't blow them up
	cmp.w	2(a0),d7		Is it in range?
	bgt	explodem3		No, don't blow them up
	cmp.w	4(a0),d2		Is it in range?
	blt	explodem3		No, don't blow them up
	cmp.w	4(a0),d6		Is it in range?
	bgt	explodem3		No, don't blow them up
	move.w	#100,6(a0)	Destroy block
explodem3	add.w	#1,d0		Move up counter
	add.w	#18,a0		Address of next moving block
	cmp.w	nummov,d0		All checked yet?
	bne	explodem2		No check next block
	bra	explode4		Return

movedown1	cmp.w	#0,d4		At bottom of layer?
	bne	explodem3		No, return
	cmp.w	#4,8(a0)		Is block at top of layer?
	bne	explodem3		No, return
	move.w	d5,d1		Get layer
	add.w	#1,d1		Move down a layer
	cmp.w	6(a0),d1		On same layer now?
	bne	explodem3		No, return
	move.w	#100,6(a0)	Destory block
	bra	explodem3		Return	

movinup1	cmp.w	#4,d4		At top of layer?
	bne	movedown1		No, return
	cmp.w	#0,8(a0)		Is block at the bottom of layer?
	bne	explodem3		No, return
	move.w	d5,d1		Get layer
	sub.w	#1,d1		Move up a layer
	cmp.w	6(a0),d1		On same layer now?
	bne	explodem3		No, return
	move.w	#100,6(a0)	Destroy block
	bra	explodem3		Return

movinup2	move.w	d4,d1		Get layer
	add.w	#1,d1		Move up a layer
	cmp.w	8(a0),d1		On same height now?
	bne	movedown2		No, return
	move.w	#100,6(a0)	Destroy block
	bra	explodem3		Return

movedown2	move.w	d4,d1		Get layer
	sub.w	#1,d1		Move down a layer
	cmp.w	8(a0),d1		On same height now?
	bne	explodem3		No, return
	move.w	#100,6(a0)	Destroy block
	bra	explodem3		Return

bluet	move.w	#1,tblock		Set high bounce variable
	cmp.w	#0,paint		Is our paint pot empty?
	ble	look2		Yes, so return
	sub.w	#1,paint		Decrease amount of paint
	move.b	#2,(a6)		Change block to purple
	add.l	#5,score		Increase score
	bra	look2		Return

dynablck	sub.w	#1,dynamite	Increase amount of dynamite
	move.b	#4,(a6)		Chnage block to purple
	bra	look2		Return

teleport	movem.l	a0/a2,-(sp)	Preserve registers
	move.w	paint,-(sp)	Store paint
	move.w	dynamite,-(sp)	Store dynamite
	move.w	jetpack,-(sp)	Store jetpacks
	move.l	a6,d0		Get address of map
	sub.l	#map,d0		Find address in teleport table.	
	mulu.w	#3,d0		Then multiply by 3
	add.l	#tmap,d0		Because of additional data
	move.l	#coord,a2		Address to put coordinates
	move.l	d0,a0		Address of where to get new coords
	move.l	a0,-(sp)		Store variable
	move.l	#coord,a1		Current coordinates
	move.w	#5000,6(a1)	Move us well out of the way
	bsr	killcrum		Crumble crumblies
	bsr	killcrum		Crumble crumbled crumblies
	bsr	killcrum		Just, to make sure
	move.l	(sp)+,a0		Restore variable
	bsr	gettele		Move to new position
	move.w	(sp)+,jetpack	Restore jetpacks
	move.w	(sp)+,dynamite	Restore dynamite
	move.w	(sp)+,paint	Don't want to leave paint behind
	movem.l	(sp)+,a0/a2	Restore registers
	bra	look2		Return

bluetm	move.w	#1,tblock		Set high bounce variable
	cmp.w	#0,paint		Is our paint pot empty?
	ble	return		Yes, so return
	sub.w	#1,paint		Decrease amount of paint
	move.w	#2,12(a1)		Change block to purple
	add.l	#5,score		Increase score
	rts			Return

dynablckm	sub.w	#1,dynamite	Increase amount of dynamite
	move.w	#4,12(a1)		Change block to purple
	rts			Return

purplet	move.w	#1,tblock		Set high bounce variable
	cmp.w	#0,paint		Have we any blue paint
	bge	look2		No, so return
	add.w	#1,paint		Decrease amount of paint
	move.b	#1,(a6)		Turn block to blue block
	add.l	#5,score		Increase score
	bra	look2		Return

purpletm	move.w	#1,tblock		Set high bounce variable
	cmp.w	#0,paint		Have we any blue paint
	bge	return		No, so return
	add.w	#1,paint		Decrease amount of paint
	move.b	#1,12(a1)		Turn block to blue block
	add.l	#5,score		Increase score
	rts			Return

blueb	cmp.w	#0,paint		Is our paint pot empty?
	ble	look2		Yes, so return
	sub.w	#1,paint		Decrease amount of paint
	move.b	#4,(a6)		Turn block to purple block
	add.l	#5,score		Increase score
	bra	look2		Return

savep	move.b	#4,(a6)		Turn block to purple block
	bsr	savepos		Save position
	bra	look2		Return

savepm	move.w	#4,12(a1)		Turn block to purple block
	bsr	savepos		Save position
	rts			Return

purpleb	cmp.w	#0,paint		Have we any blue paint
	bge	look2		No, so return
	add.w	#1,paint		Decrease amount of paint
	move.b	#3,(a6)		Turn block to blue block
	add.l	#5,score		Increase score
	bra	look2		Return

purplebm	cmp.w	#0,paint		Have we any blue paint
	bge	return		No, so return
	add.w	#1,paint		Decrease amount of paint
	move.w	#3,12(a1)		Turn block to blue block
	add.l	#5,score		Increase score
	rts			Return

mapb	move.b	#4,(a6)		Turn block to purple block
	bsr	drawmap		Draw the map
	bra	look2		Return

mapbm	move.w	#4,12(a1)		Turn block to purple block
	bsr	drawmap		Draw the map
	rts			Return

bonus	add.l	#20,score		Increase score
	move.b	#4,(a6)		Turn block to purple block
	bra	look2		Return

jetblckm	sub.w	#1,jetpack	Pick up jetpack
	move.w	#4,12(a1)		Turn block to purple block
	rts			Return

jetblck	sub.w	#1,jetpack	Pick up jetpack
	move.b	#4,(a6)		Turn block to purple block
	bra	look2		Return

lifem	sub.w	#1,lives		Increase number of lives
	move.w	#4,12(a1)		Turn block to purple block
	rts			Return

life	sub.w	#1,lives		Increase number of lives
	move.b	#4,(a6)		Turn block to purple block
	bra	look2		Return

bluebm	cmp.w	#0,paint		Is our paint pot empty?
	ble	return		Yes, so return
	sub.w	#1,paint		Decrease amount of paint
	move.w	#4,12(a1)		Turn block to purple block
	add.l	#5,score		Increase score
	rts			Return

bonusm	add.l	#20,score		Increase score
	move.w	#4,12(a1)		Turn block to purple block
	rts			Return

showpas	move.b	#4,(a6)		Turn block to purple block
	bsr	drawpb		Draw password box
	bra	look2		Return

showpasm	move.w	#4,12(a1)		Turn block to purple block
	bsr	drawpb		Draw password box
	bra	look2		Return

paintp	cmp.w	#0,paint		Is our paint pot empty?
	bne	look2		No Return
	move.w	#5,paint		Fill up paint pot
	cmp.w	#2,mode		Are we on competative mode?
	beq	look2		Yes, paint pot isn't used up
	move.b	#4,(a6)		Turn block to purple block
	bra	look2		Return	

paintpm	cmp.w	#0,paint		Is our paint pot empty?
	bne	return		No Return
	move.w	#5,paint		Fill up paint pot
	cmp.w	#2,mode		Are we on competative mode?
	beq	return		Yes, paint pot isn't used up
	move.w	#4,12(a1)		Turn block to purple block
	rts			Return

bluep	cmp.w	#0,paint		Is our paint pot empty?
	bne	look2		No Return
	move.w	#-5,paint		Fill up paint pot
	cmp.w	#2,mode		Are we on competative mode?
	beq	look2		Yes, paint pot isn't used up
	move.b	#3,(a6)		Turn block to blue block
	bra	look2		Return

bluepm	cmp.w	#0,paint		Is our paint pot empty?
	bne	return		No Return
	move.w	#-5,paint		Fill up paint pot
	cmp.w	#2,mode		Are we on competative mode?
	beq	return		Yes, paint pot isn't used up
	move.w	#3,12(a1)		Turn block to blue block
	rts			Return

checklift	move.w	10(a1),d1		Is it going up?
	cmp.w	#0,d1		If it's not don't pick us up
	blt	checklft2		It isn't
	move.w	6(a1),d1		Get level
	cmp.w	d1,d5		Same level?
	beq	chcklift2		Yes go to routine2
	sub.w	d5,d1		It should only be 1 level above
	cmp.w	#-1,d1		If not we're not on it
	bne	checklft2		No we're not on it
	move.w	8(a1),d1		Get height
	cmp.w	#0,d1		If its not 0
	bne	checklft2		Then we're not on it
	cmp.w	#4,d4		We must be at top of layer
	bne	checklft2		Or else we're not on it
	bra	checkexs2		Return

chcklift2	move.w	8(a1),d1		Get height
	sub.w	d4,d1		Should be one more than ours
	cmp.w	#1,d1		If it isn'0t
	bne	checklft2		we're not on it
	bra	checkexs2		Return

checkmov	cmp.w	#0,nummov		Any moving blocks?
	beq	return		No so return
	move.w	d0,fall		Asume we're falling
	move.l	#coord,a2		Address of coordinates
	movem.w	(a2),d4-d7	Get out coordinates
	move.l	#blcoord,a1	Address of block coordinates
	move.w	#0,d2		Coordinates are stored reversed
	sub.w	d6,d2		So swap them around
	move.w	d2,d6		Copy Y coordinate
	move.w	#0,d3		Coordinates are stored reversed
	sub.w	d7,d3		So swap them aroud
	move.w	d3,d7		Copy X coordinate
	add.w	#94,d2		Convert to coordinate
	add.w	#94,d3		Convert to coordinate
	add.w	#34,d6		Convert to coordinate
	add.w	#34,d7		Convert to coordinate
	move.w	#0,d0		Zero counter
checkmov2	move.w	d0,blckno		Store counter
	move.w	(a1),d1		Is it a lift?
	cmp.w	#4,d1		Check varaible to find out
	beq	checklift		Yes it is. Are we on it?
checklft2	move.w	6(a1),d1		Get block's Z coordinate
	cmp.w	d1,d5		Are we on the same level
	bne	checkmov3		No so we can't collide
	move.w	8(a1),d1		Get block's height
	cmp.w	d1,d4		Are we at the same height
	bne	checkmov3		No so we can't collide
	move.w	(a1),d1		What type of block is it?
	cmp.w	#5,d1		Is it a flashing block
	beq	checkexs		Yes. Check it's there
checkexs2	move.w	2(a1),d0		Get block's X coordinate
	move.w	4(a1),d1		Get block's Y coordinate
	cmp.w	d0,d3		Is our X coordinate out of range?
	blt	checkmov3		Yes so we can't collide
	cmp.w	d0,d7		Is our X coordinate out of range?
	bgt	checkmov3		Yes so we can't collide
	cmp.w	d1,d2		Is our Y coordinate out of range?
	blt	checkmov3		Yes so we can't collide
	cmp.w	d1,d6		Is our Y coordinate out of range?
	bgt	checkmov3		Yes so we can't collide
	move.w	#2,fall		We aren't falling
	movem.w	d4-d7,-(sp)	Preserve registers
	movem.w	(a2),d4-d7	Restore coordinates
	move.w	12(a1),d0		Is it a special block?
	bsr	specialm		Gosub Routine to check it out
	move.w	(a1),d0		What type of block is it?
	cmp.w	#4,d0		In an out block
	beq	inout		Block type 4
	cmp.w	#2,d0		Left and right block
	beq	lftrgt		Block type 2
	cmp.w	#3,d0		Up and down block
	beq	updown		Block type 3
checkmor3	movem.w	(sp)+,d4-d7	Restore registers
checkmov3	move.w	blckno,d0		Restore counter
	add.w	#1,d0		Move up counter
	add.w	#18,a1		Move up to next blocks
	cmp.w	nummov,d0		All blocks checked yet
	bne	checkmov2		No check next one
	move.w	fall,d0		Get falling status
	rts			Return

movedble	lsl.w	#1,d0		Double speed
	bra	movedble2		Return

lftrgt	move.w	10(a1),d0		Which direction
	cmp.w	#0,mode		Are we on two player mode
	bgt	movedble		Yes, move double distance 
movedble2	sub.w	d0,d7		Update X coordinate
	movem.w	d4-d7,(a2)	Store coordinates
	bra	checkmor3		Return
	
inout	move.w	8(a1),d0		Get height
	cmp.w	d0,d4		Is at the same height?
	beq	checkmor3		Yes. So it can't be going up
	move.w	#1,goingup	Make us go up with it
	bra	checkmor3		Return

dblemove	lsl.w	#1,d0		Double speed
	bra	dblemove2		Return

updown	move.w	10(a1),d0		Which direction
	cmp.w	#0,mode		Are we on two player mode
	bgt	dblemove		Yes,move double distance
dblemove2	sub.w	d0,d6		Update Y coordinate
	movem.w	d4-d7,(a2)	Store coordinates
	bra	checkmor3		Return

checkexs	move.w	10(a1),d1		Is it there?
	cmp.w	#0,d1		If its status is less than 0
	blt	checkmov3		It isn't there
	bra	checkexs2		Return

noa5a3	move.l	#dud,a3		Zero a3
	move.l	#dud,a5		Zero a5
	bra	check2		Return

noa4a2	move.l	#dud,a4		Zero a4
	move.l	#dud,a2		Zero a2
	bra	check3		Return

noa5a4	move.l	#dud,a5		Zero a5
	move.l	#dud,a4		Zero a4
	bra	check4		Return

noa3a2	move.l	#dud,a3		Zero a3
	move.l	#dud,a2		Zero a2
	bra	check5		Return

dontfall	move.w	#0,d0		We aren't falling
	bra	look2		Return

dead	move.w	#1,death		We are dead
	bra	dead2		Return

timepen	move.w	#0,xmomentum	Zero X momementum
	move.w	#0,ymomentum	Zero Y momementum
	move.w	#0,jump		We aren't jumping
	bra	timepen2		Return

moveblob	cmp.w	#0,ddelay		Are we on time penalty?
	bne	timepen		Yes, we can't move
timepen2	move.l	#coord,a6		Address of coordinates
	movem.w	(a6),d4-d7	Restore coordinates
	cmp.w	#19,d5		Are we dead?
	beq	dead		yes we've fallen off the bottom
dead2	add.w	xmomentum,d7	Update X position
	add.w	ymomentum,d6	Update Y position
	move.w	counter,d0	Get counter
	add.w	#1,d0		Move up
	cmp.w	#3,d0		Check for slow down
	beq	slowdown		Slowdown player
move2	move.w	d0,counter	Store counter
	cmp.w	#1,goingup	Are we moving up on a lift
	beq	lift		Yes we are
lift2	cmp.w	#0,jump		Are we jumping?
	bne	moveup		yes move upwards
	cmp.w	#2,fall		Are we on a moving block
	beq	onmb		Yes so we don't fall whatever
	cmp.w	#0,d4		Are we inbetween layers
	bne	falling		Yes we are
	move.w	fall,d0		Are we falling?
	cmp.w	#1,d0		Check variable
	beq	nextlayer		Yes we are
onmb	cmp.w	#1,fire		are we trying to jump
	beq	jumpup		yes we are
move3	movem.w	d4-d7,(a6)	Save coordinates
	move.w	#0,tblock		Reset trampoline check
	rts			Return

lift	move.w	#0,goingup	Reset lift variable
	move.w	#2,fall		We aren't falling
	bra	moveup2		Move upwards
	bra	lift2		Return

moveup	sub.w	#1,jump		Decriminate counter
	cmp.w	#4,d4		Are we at the top stage?
	beq	uplevel		Yes go up a level
	add.w	#1,d4		No move up one stage
	bra	move3		return

moveup2	cmp.w	#4,d4		Are we at the top stage?
	beq	uplevel2		Yes go up a level
	add.w	#1,d4		No move up one stage
	bra	lift2		Return

uplevel2	move.w	#0,d4		go to bottom stage
	sub.w	#1,d5		of level above
	bra	lift2		Return

uplevel	move.w	#0,d4		go to bottom stage
	sub.w	#1,d5		of level above
	cmp.w	#1,d5		At very top?
	beq	topblock		Yes, don't go any higher
	bra	move3		return

topblock	move.w	#0,jump		Not jumping
	move.w	#0,fire		Cancel fire button
	add.w	#1,d5		Go back down
	move.w	#4,d4		Top stage of layer below
	bra	move3		Return

jumpup	cmp.w	#0,jump		Are we already jumping?
	bne	move3		yes we are
	cmp.w	#1,tblock		Are we on a trampoline
	beq	highjump		Yes, jump extra high
	move.w	#6,jump		jump 6 places
	bra	move3		return

highjump	move.w	#12,somerslt	Start somersault sequence
	move.w	#12,jump		jump 12 place
	bra	move3		Return

falling	sub.b	#1,d4		Move down one stage
	move.w	#1,fall		Inform program we are falling
	bra	move3		Return

nextlayer	move.w	#4,d4		place at top stage
	addq.b	#1,d5		move down to next layer
	bra	move3		Return

slowdown	cmp.w	#0,xmomentum	Check xmomentum
	blt	movexup		If minus number increase
	bgt	movexdown		Otherwise decrease
slowdown2	cmp.w	#0,ymomentum	Check ymomentum
	blt	moveyup		If minue number increase
	bgt	moveydown		Otherwise decrease
slowdown3	move.w	#0,d0		Reset counter
	bra	move2		Return

movexup	add.w	#1,xmomentum	decrease xmomentum
	bra	slowdown2		Return

movexdown	sub.w	#1,xmomentum	decrease xmomentum
	bra	slowdown2		Return

moveyup	add.w	#1,ymomentum	decrease ymomentum
	bra	slowdown3		Return

moveydown	sub.w	#1,ymomentum	decrease ymomentum
	bra	slowdown3		Return

init	BSR	initjoy		Initialise joystick routine
	BSR	findmode		Get Screen resolution
	MOVE.W	d0,old_rez	Store it for later
	BSR	getscreen		Make extra screens
	BSR	loadquart		Load quartet music
	BSR	loaddeg		Load in Degas picture
	BSR	shift		Preshift Graphics
	DC.W	$A000		Get address of
	move.l	8(a0),intin	of intin array
	move.l	12(a0),ptsin	and ptsin array	
	move.l	a0,atable		Store address of entire table
	bsr	bits		Set up parameters for line drawing
	BSR	loadps		Load in passwords
	BSR	stars		Initialise stars
	BSR	loadhi		Load in hiscores
	RTS			Return

loadhi	move.w	#0,-(sp)		Open for reading
	move.l	#hifile,-(sp)	Address of file name
	move.w	#$3d,-(sp)	Function number
	trap	#1		Call GEMDOS
	addq.l	#8,sp		Correct stack
	tst.l	d0		Check for errors
	bmi	return		No file to load
	move.w	d0,handle		Store handle
	move.l	#hiscores2,-(sp)	Address to load into
	move.l	#220,-(sp)	Number of bytes to read
	move.w	handle,-(sp)	Handle number
	move.w	#$3f,-(sp)	Function number
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	move.w	handle,-(sp)	Handle number
	move.w	#$3e,-(sp)	Function number
	trap	#1		Call GEMDOS
	addq.l	#4,sp		Correct stack
	rts			Return

savehi	move.w	#1,-(sp)		Read one sector
	move.w	#0,-(sp)		From side 0
	move.w	#10,-(sp)		Track 10
	move.w	#3,-(sp)		Sector 3
	move.w	#0,-(sp)		Drive A
	clr.l	-(sp)		Filler
	move.l	#sectbuf,-(sp)	Buffer to store data
	move.w	#8,-(sp)		Function Number
	trap	#14		Call XBIOS
	lea	20(sp),sp		Correct stack
	tst.w	d0		Check for errors
	bmi	return		Yes, return
	move.w	#1,-(sp)		Write one sector
	move.w	#0,-(sp)		To side 0
	move.w	#10,-(sp)		Track 10
	move.w	#3,-(sp)		Sector 3
	move.w	#0,-(sp)		Drive A
	clr.l	-(sp)		Filler
	move.l	#sectbuf,-(sp)	Buffer to store data
	move.w	#9,-(sp)		Function Number
	trap	#14		Call XBIOS
	lea	20(sp),sp		Correct stack
	tst.w	d0		Check for errors
	bmi	return		Yes, return

	move.w	#$0,-(sp)		File should have read write status
	move.l	#hifile,-(sp)	Address of file name
	move.w	#$3c,-(sp)	Create new file
	trap	#1		Call GEMDOS
	addq.l	#8,sp		Correct stack
	move.w	d0,handle		Store handle
	move.l	#hiscores2,-(sp)	Addresss to save from
	move.l	#220,-(sp)	Number of bytes to save
	move.w	handle,-(sp)	Handle number
	move.w	#$40,-(sp)	Function number
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	move.w	handle,-(sp)	Handle number
	move.w	#$3e,-(sp)	Function number
	trap	#1		Call GEMDOS
	addq.l	#4,sp		Correct stack
	rts			Return

initlev	move.w	clevel,d0		Quartet tune to load
	add.w	#1,d0		Allow for title screen music
	BSR	loadtune		Load it in
	BSR	loadlev		Load in level data
	BSR	convert		Intialise moving blocks
	BSR	varibles		Set up varibles
	BSR	clw		Clear the screen
	BSR	palt		Get colour palette
	move.l	#initlev2,-(sp)	Return address
	cmp.w	#0,mode		Are we on 1 player mode?
	beq	playquart		play quartet music
	addq.l	#4,sp		Correct stack
initlev2	move.w	#0,death		We aren't dead
	move.w	#0,restart	Reset restart parameters
	move.w	#0,opaint		Reset paint stores
	move.w	#3,odyna		Original amount of dynamite
	move.w	#3,ojet		Original number of jetpacks
	move.w	#3,dynamite	Actual amount of dynamite
	move.w	#3,jetpack	Actual number of jetpacks
	cmp.w	#0,mode		Are we on two player mode?
	bgt	copyvars		Yes, set up player 2's variables
	RTS			Return

copyvars	move.l	#excoord,a0	Source address
	move.l	#player2,a1	Destination address
	move.w	30(a1),d1		Get number of lives
	move.l	42(a1),d2		Get coordinates
	move.l	46(a1),d3		Get rest of coordinates
	move.l	22(a1),d4		Get start position
	move.w	#14,d0		Set up counter
copyvars2	move.l	(a0)+,(a1)+	Copy across variable
	dbf	d0,copyvars2	Move up counter
	move.l	#player2,a1	Player 2's variables
	move.l	d2,42(a1)		Put coordinates back
	move.l	d3,46(a1)		Put coordinates back
	move.l	d4,22(a1)		Get start position back
	cmp.w	#1,newgame	Is it a new game
	bne	oldlives		No, don't get lives back
	rts			Return

oldlives	move.l	#player2,a1	Destination address
	move.w	d1,30(a1)		Save number of lives
	rts			Return

swapvars	move.l	#excoord,a0	Source address
	move.l	#player2,a1	Destination address
	move.w	#37,d1		Set up counter
swapvars2	move.l	(a0),d0		Get long word
	move.l	(a1),(a0)+	Swap variables
	move.l	d0,(a1)+		To swap current player
	dbf	d1,swapvars2	Swap more variables
	rts			Return

vars2	move.w	#1,d4		Set up timer
	bra	vars2r		Return

varibles	move.w	#0,d4		Set up timer
	cmp.w	#0,mode		Are we on two player mode
	bgt	vars2		Yes set up both varibles
vars2r	bsr	getstart		Get start position
	bsr	checkjoy		Clear joystick buffer
	bsr	checkjoy		Make sure
	move.w	#0,ddelay		No time penalty
	move.w	#0,xmomentum	Zero X momentum
	move.w	#0,ymomentum	Zero Y momentum
	move.w	#0,counter	Zero Counter
	move.w	#0,jump		We aren't jumping
	move.w	#0,fire		Cancel effect of fire button
	move.w	#0,blowdyna	Dynamite isn't exploding
	move.w	odyna,dynamite	Amount of dynamite
	move.w	ojet,jetpack	Number of jetpacks
	move.l	#crumble,a0	Address of crumble tables
	move.w	#18,d0		Set up counter
wipetble	move.l	#0,(a0)+		Blank 4 bytes
	dbf	d0,wipetble	Continue wiping table
	cmp.w	#0,mode		Check number of players
	bgt	setvars		if 2 switch to other player
setvars2	dbf	d4,vars2r		Set up player 2's varibles
	RTS			Return

setvars	bsr	swapvars		Swap variables
	bra	setvars2		Return

drawdead	move.w	#0,d0		Reset counter
drawdead2	move.w	d0,-(sp)		Store counter
	BSR	drawscrn		Draw screen
	move.w	(sp)+,d0		Restore counter
	add.w	#1,d0		Move up counter
	cmp.w	#25,d0		Death sequence finished yet
	bne	drawdead2		No draw next frame
	rts			Return

explosion	move.w	#0,d0		Reset counter
explosin2	move.w	d0,-(sp)		Store counter
	add.w	#1,blowdyna	Change frame of animation
	BSR	drawscrn		Draw screen
	move.w	(sp)+,d0		Restore counter
	add.w	#1,d0		Move up counter
	cmp.w	#25,d0		Explosion finished yet?
	bne	explosin2		No draw next frame
	rts			Return

seffects	BSR	drawstars		Draw stars on top
	BSR	drawstars		Cause streaks
	BSR	drawstars		By drawing several times
	BSR	drawstars		Draw 4 times in total
	BRA	seffects2		Return

seffects3	move.l	#exps,a0		Address of colour sequence
	add.w	blowdyna,a0	Find address of correct colour
	add.w	blowdyna,a0	One colour is a word
	move.w	(a0),-(sp)	Colour to make
	move.w	#0,-(sp)		Change colour 0
	move.w	#7,-(sp)		Functon number
	trap	#14		Call XBIOS
	addq.l	#6,sp		Correct stack
	BRA	seffects4		Return

drawarrow	move.w	#0,d0		Zero xcounter
	move.w	#0,d1		Zero ycounter
	move.l	#larrow,a0	Address of left arrow
	move.l	#rarrow,a1	Address of right arrow
	move.l	intin,a5		Address of intin array
	move.l	ptsin,a4		Address of ptsin array
arrow2	move.b	(a0)+,d2		Get colour
	move.w	d0,d3		Find X coordinate
	add.w	#153,d3		Add offset
	move.w	d1,d4		Find Y coordinate
	add.w	#89,d4		Add offset
	move.w	mode,d5		What have we selected?
	mulu.w	#6,d5		Point arrow to selection
	add.w	d5,d4		Move arrow to correct position
	move.w	d3,(a4)		Pass parameter
	move.w	d4,2(a4)		Ycoordinate
	move.w	d2,(a5)		Pass colour
	movem.l	d0-d2/a0-a2,-(sp)	Preserve registers
	dc.w	$a001		Plot pixel
	movem.l	(sp)+,d0-d2/a0-a2	Restore registers
	move.b	(a1)+,d2		Get colour
	add.w	#72,d3		Move across to right arrow
	move.w	d3,(a4)		Pass parameter
	move.w	d4,2(a4)		Ycoordinate
	move.w	d2,(a5)		Pass colour
	movem.l	d0-d2/a0-a2,-(sp)	Preserve registers
	dc.w	$a001		Plot pixel
	movem.l	(sp)+,d0-d2/a0-a2	Restore registers
	add.w	#1,d0		Move up xcounter
	cmp.w	#3,d0		Do we move down yet?
	beq	arrowd		Yes, move down
arrowd2	cmp.w	#6,d1		Have we finished yet?
	bne	arrow2		No, draw next point
	rts			Return

arrowd	move.w	#0,d0		Reset xcounter
	add.w	#1,d1		Move down ycounter
	bra	arrowd2		Return

drawmini	sub.w	#1,d0		Blocks count from zero
	lsl.w	#5,d0		Find position of block
	add.w	d0,a1		Find address of graphic
	move.w	#0,d0		Zero xcounter
	move.w	#0,d1		Zero ycounter
drawmini2	move.w	d5,d2		Get xcoordinate
	add.w	d0,d2		Add offset
	move.w	d2,(a4)		Pass parameter
	move.w	d6,d2		Get ycoordinate
	add.w	d1,d2		Add offset
	move.w	d2,2(a4)		Ycoordinate
	move.w	#0,d2		Zero d2
	move.b	(a1)+,d2		Get colour
	move.w	d2,(a5)		Pass colour to routine
	movem.l	d0-d2/a0-a2,-(sp)	Preserve registers
	dc.w	$a001		Plot pixel
	movem.l	(sp)+,d0-d2/a0-a2	Restore registers
	add.w	#1,d0		Move up xcounter
	cmp.w	#5,d0		Done yet?
	bne	drawmini2		No, draw next pixel
	add.w	#1,d1		Move up ycounter
	move.w	#0,d0		Reset xcounter
	cmp.w	#5,d1		Done yet?
	bne	drawmini2		No, draw next pixel
	bra	drawmini3		Return

num2pl	move.w	#0,d0		Zero d0
	move.b	numlev2,d0	Number of levels
	move.l	#passinf2,a0	Differant passwords
	bra	checkpas2		Return

nmcmppl	move.w	#0,d0		Zero d0
	move.b	numlev3,d0	Number of levels
	move.l	#passinf3,a0	Differant passwords
	bra	checkpas2		Return

checkpas	move.w	#1,clevel		Level to load
	move.l	#passb,a1		Password typed in
	cmp.b	#0,(a1)		Is there a password there?
	beq	return		No, return
	move.w	#1,d3		Set level counter
	move.l	#passinf,a0	Passwords to check
	move.w	#0,d0		Clear d0
	cmp.w	#1,mode		Are we on 2player mode?
	beq	num2pl		Yes, differant number of levels
	cmp.w	#2,mode		Are we on competative mode?
	beq	nmcmppl		Yes, differant number of levels
	move.b	numlev,d0		Number of levels
checkpas2	move.l	#passb,a1		Password typed in
checkpas3	move.b	(a1)+,d2		Get letter to compare
	cmp.b	(a0)+,d2		Do they match?
	bne	checkpas4		No, next password
	cmp.b	#0,(a0)		Are we at the end
	bne	checkpas3		No, check next letter
	cmp.b	#0,(a1)		Same number of letters?
	bne	checkpas4		No, next password
	move.w	d3,clevel		Level to load
	rts			Return

pass2pl	move.l	#passinf2,a0	Password address
	bra	passwrt		Return

passcmp	move.l	#passinf3,a0	Password address
	bra	passwrt		Return

checkpas4	cmp.w	#1,mode		Are we on 2player mode?
	beq	pass2pl		Yes, use differant passwords
	cmp.w	#2,mode		Are we on competative mode?
	beq	passcmp		Yes, use differant passwords
	move.l	#passinf,a0	Password address
passwrt	move.w	d3,d4		Make copy of counter
	mulu.w	#12,d4		Find address
	add.w	d4,a0		Find address of password
	add.w	#1,d3		Move up counter
	sub.w	#1,d0		Decrease number to check
	cmp.w	#0,d0		Any more to check
	bne	checkpas2		No, Check next password
	rts			Return

passbox	bsr	clw		Clear the screen
	bsr	scrnswap		Reveal screen
	bsr	inpalt		Get palette
passbox2	bsr	dobox		Draw password box
	move.w	#$ff,-(sp)	Test keyboard
	move.w	#6,-(sp)		Function number
	trap	#1		Call GEMDOS
	addq.l	#4,sp		Correct stack
	tst.w	d0		Charactor arrived?
	bne	addlet		Yes, add letter
addlet2	bsr	checkjoy		Check joystick
	cmp.w	#1,fire		Have we pressed fire
	beq	return		Yes, return
	cmp.w	#0,ymomentum	Have we moved the joystick?
	bne	chngmode		Yes change current mode
	move.w	#0,lock		Unlock controls
moder	move.w	#0,ymomentum	Zero ymomentum
	bra	passbox2		No, check some more		

chngmode	cmp.w	#1,lock		Are controls locked?
	beq	moder		Yes, return
	cmp.w	#0,ymomentum	Moved up or down
	blt	modedown		Moved down
	cmp.w	#0,mode		Are we already at top?
	beq	chngmode2		Yes, no more up
	sub.w	#1,mode		Move mode up
chngmode2	move.w	#0,ymomentum	Reset ymomentum
	move.w	#1,lock		Lock controls
	bra	moder		Return

modedown	cmp.w	#2,mode		Are we already at bottom?
	beq	chngmode2		Yes, no more down
	add.w	#1,mode		Move mode down
	bra	chngmode2		Continue routine

addlet	cmp.w	#8,d0		Is it delete
	beq	dellet		Yes, erase 1 letter
	cmp.w	#90,d0		Is it capital
	bgt	makecaps		No, convert it
makecaps2	cmp.w	#90,d0		Is it in range
	bgt	addlet2		No, return
	cmp.w	#65,d0		Is it in range
	blt	addlet2		No, return
	move.l	#passb,a0		Address of password
	move.w	#1,d1		Reset counter
addlet3	cmp.b	#0,(a0)		Is it a blank space
	beq	addlet4		Yes, exit loop
	add.w	#1,d1		Move up counter
	add.w	#1,a0		Move up pointer
	cmp.w	#11,d1		Are we out of room
	beq	addlet2		Yes, return
	bra	addlet3		No, Check for next space
addlet4	move.b	d0,(a0)		Store letter in space
	bra	addlet2		Return

dellet	move.l	#passb,a0		Address of password
	move.w	#0,d1		Reset counter
dellet2	cmp.b	#0,(a0)		Is it a blnak space
	beq	dellet3		Yes, exit loop
	add.w	#1,d1		Move up counter
	add.w	#1,a0		Move up pointer
	bra	dellet2		Check next space
dellet3	cmp.w	#0,d1		Any letters
	beq	addlet2		No, return
	sub.w	#1,a0		Move back pointer
	move.b	#0,(a0)		Wipe out letter
	bra	addlet2		Return

makecaps	sub.w	#32,d0		Make into capital letter
	bra	makecaps2		Return

logo	movem.l	d0-d7/a0-a6,-(sp)	Preserve registers
	bsr	mode0		Set to low resolution
	bsr	palt		Get colour palette
	move.l	screen_2,a0	Source address
	move.l	screen_1,a1	Destination address
	move.w	#198,d0		Left from
	move.w	#0,d1		Top from
	move.w	#99,d2		Left to
	move.w	#42,d3		Top to
	move.w	#122,d4		Width
	move.w	#39,d5		Height
	move.l	#$03030303,d7	Logical operation
	bsr	blit		Copy it across
	move.w	#158,d1		Top from
	move.w	#72,d5		Height
	move.w	#107,d3		Top to
	bsr	blit		Copy it across
	move.w	#0,d0		Left from
	move.w	#174,d1		Top from
	move.w	#81,d3		Top to
	move.w	#26,d5		Height
	bsr	blit		Copy it across
	movem.l	(sp)+,d0-d7/a0-a6	Restore registers
	rts			Return

dobox	bsr	clw		Clear screeen
	bsr	drawstars		Add on stars
	move.l	screen_3,a0	Source address
	move.l	screen_1,a1	Destination address
	move.w	#0,d0		Left from
	move.w	#128,d1		Top from
	move.w	#80,d2		Left to
	move.w	#64,d3		Top to
	move.w	#159,d4		Width
	move.w	#72,d5		Height
	move.l	#$03030303,d7	Logical operation
	bsr	blit		Copy across graphics
	move.l	#passb,a5		Address of password
	move.w	#154,d2		Left to
	move.w	#116,d3		Top to
	bsr	drawmes		Draw current password
	bsr	drawarrow		What are we selecting?
	bsr	scrnswap		Reveal screen
	rts			Return


pass2i	move.l	#passinf2,a5	2player passwords
	bra	passir		Return

passci	move.l	#passinf3,a5	competative passwords
	bra	passir		Return

drawpb	movem.l	d0-d7/a0-a6,-(sp)	Preserve registers
	move.w	#1,nomome		Disable controls
	bsr	clw		Clear screen
	move.l	screen_3,a0	Source address
	move.l	screen_1,a1	Destination address
	move.w	#161,d0		Left from
	move.w	#128,d1		Top from
	move.w	#80,d2		Left to
	move.w	#64,d3		Top to
	move.w	#159,d4		Width
	move.w	#72,d5		Height
	move.l	#$03030303,d7	Logical operation
	bsr	blit		Copy across graphics
	cmp.w	#1,mode		Are we on two player mode?
	beq	pass2i		Yes, differant passwords
	cmp.w	#2,mode		Are we on competative mode?
	beq	passci		Yes, differant passwords
	move.l	#passinf,a5	Address of passwords
passir	move.w	clevel,d0		What level are we on?
	sub.w	#1,d0		Levels count from zero
	mulu.w	#12,d0		find relative address
	add.w	d0,a5		Find address of password
	move.w	#118,d2		Left to
	move.w	#105,d3		Top to
	bsr	drawmes		Draw message in a5 at d2,d3
	bsr	scrnswap		Swapscreens
drawpb2	bsr	checkjoy		Check for joystick
	cmp.w	#0,fire		Wait for depressing of fire
	bne	drawpb2		If not check again
drawpb3	bsr	checkjoy		Check joystick
	cmp.w	#1,fire		Now wait for it to be pressed
	bne	drawpb3		If not check again
drawpb4	bsr	checkjoy		Check joystick
	cmp.w	#0,fire		Wait for it to be released
	bne	drawpb4		If not check again
	movem.l	(sp)+,d0-d7/a0-a6	Restore registers
	move.w	#0,nomome		Reeanable controls
	rts			Return

freepas	cmp.w	#2,mode		Are we on competative mode?
	bne	return		No, return
	movem.l	d0-d7/a0-a6,-(sp)	Preserve registers
	bsr	clw		Clear screen
	move.l	screen_3,a0	Source address
	move.l	screen_1,a1	Destination address
	move.w	#161,d0		Left from
	move.w	#128,d1		Top from
	move.w	#80,d2		Left to
	move.w	#64,d3		Top to
	move.w	#159,d4		Width
	move.w	#72,d5		Height
	move.l	#$03030303,d7	Logical operation
	bsr	blit		Copy across graphics
	move.l	#passinf3,a5	Address of passwords
	move.w	clevel,d0		What level are we on
	sub.w	#1,d0		Levels count from zero
	mulu.w	#12,d0		find relative address
	add.w	d0,a5		Find address of password
	move.w	#118,d2		Left to
	move.w	#105,d3		Top to
	bsr	drawmes		Draw message in a5 at d2,d3
	movem.l	(sp)+,d0-d7/a0-a6	Restore registers
	rts			Return

prompt	move.w	clevel,levload	Store level to load
	bsr	clw		Clear screen
	bsr	scrnswap		Reveal screen
	bsr	inpalt		Get colour palette
	move.w	#0,slowdowns	Reset counter
prompt2	bsr	clw		Clear screen
	move.w	#116,d2		Left to
	move.w	#80,d3		Top to
	move.l	#wait,a5		Message to draw
	bsr	drawmes		Draw message in a5 at d2,d3
	move.w	levload,d6	Restore level to load
	move.w	#96,d2		Left to
	move.w	#100,d3		Top to
	move.l	#wait2,a5		Message to draw
	clr.w	d5		Clear d5
	move.w	D6,D5		Make copy of block number
	divu.w	#10,d5		Get first digit
	mulu.w	#10,d5		first subtract from
	sub.w	d5,d6		total for second digit
	divu.w	#10,d5		Get first digit again
	add.w	#$30,d5		Convert into asci number
	move.l	#wait3,a0		Address of space for number
	move.b	d5,(a0)+		Store first digit in space
	add.w	#$30,d6		Convert second digit
	move.b	d6,(a0)+		Place second digit in space
	bsr	drawmes		Draw message
	move.w	#94,d0		Top left X coordinate
	move.w	#78,d1		Top left Y coordinate
	move.w	#226,d2		Bottom right X coordinate
	move.w	#118,d3		Bottom right Y coordinate
	bsr	border		Draw border
	bsr	freepas		Password instead?
	bsr	scrnswap		Reveal screen
	add.w	#1,slowdowns	Move up counter
	cmp.w	#2,slowdowns	Is it drawn on both screens?
	bne	prompt2		No, draw it again
	rts			Return

	*d0= top left x
	*d1= top left y
	*d2= bottom right x
	*d3= bottom right y

border	move.l	atable,a0
	sub.w	#3,d3
	movem.w	d0-d3,-(sp)
	move.w	d0,38(a0)
	move.w	d1,40(a0)
	move.w	d2,42(a0)
	move.w	d1,44(a0)
	dc.w	$a003
	move.l	atable,a0
	movem.w	(sp),d0-d3
	move.w	d2,38(a0)
	move.w	d1,40(a0)
	move.w	d2,42(a0)
	move.w	d3,44(a0)
	dc.w	$a003
	move.l	atable,a0
	movem.w	(sp),d0-d3
	move.w	d2,38(a0)
	move.w	d3,40(a0)
	move.w	d0,42(a0)
	move.w	d3,44(a0)
	dc.w	$a003
	move.l	atable,a0
	movem.w	(sp)+,d0-d3
	move.w	d0,38(a0)
	move.w	d3,40(a0)
	move.w	d0,42(a0)
	move.w	d1,44(a0)
	dc.w	$a003
	rts

bits	move.w	#0,24(a0)
	move.w	#1,26(a0)
	move.w	#0,28(a0)
	move.w	#0,30(a0)
	move.w	#$FFFF,34(a0)
	move.w	#0,36(a0)
	move.w	#$FFFF,32(a0)
	rts

drawmes	cmp.b	#0,(a5)		Any message?
	beq	return		No, return
	move.l	#fontlay,a0	Address of font table
	move.w	#238,d0		X source
	move.w	#6,d1		Y source
	move.b	(a5)+,d4		Get letter to draw
	cmp.b	#" ",d4		Is it a space
	beq	space		Yes, don't draw it
drawmes2	move.b	(a0)+,d5		Get letter from font table
	add.w	#8,d0		Move up xcoordinate
	cmp.w	#310,d0		Are we on next line yet
	beq	downmesl		Yes move down on table
drawmes3	cmp.b	d4,d5		Do they match up
	bne	drawmes2		No check next slot
	move.w	#8,d4		Width
	move.w	#12,d5		Height
	move.l	screen_3,a0	Source address
	move.l	screen_1,a1	Destination address
	move.l	#$03030303,d7	Logical operation
	bsr	blit		Copy across letter
space	add.w	#8,d2		Move up xcoordinate
	cmp.b	#0,(a5)		Any more letters?
	bne	drawmes		Yes, draw next letter		
	rts			Return

downmesl	move.w	#246,d0		Move X source back again
	add.w	#13,d1		Move Y source down
	bra	drawmes3		Return

drawmap	movem.l	d0-d7/a0-a6,-(sp)	Preserve registers
	move.w	#1,nomome		Disable controls
	bsr	clw		Clear screen
	move.l	screen_3,a0	Source address
	move.l	screen_1,a1	Destination address
	move.w	#0,d0		Left from
	move.w	#0,d1		Top from
	move.w	#43,d2		Left to
	move.w	#24,d3		Top to
	move.w	#238,d4		Width
	move.w	#126,d5		Height
	move.l	#$03030303,d7	Logical operation
	bsr	blit		Copy across graphics
	move.l	#map4,a0		Address of map
	move.l	intin,a5		Address of intin array
	move.l	ptsin,a4		Address of ptsin array
	add.w	#75,a0		Allow for blank rows
	move.w	#0,d7		Zero counter
	move.w	#104,d5		Set xcoord
	move.w	#40,d6		Set ycoord
	move.w	#1,d4		Set ycounter
	move.w	#0,d3		Set xcounter
drawmap5	move.l	#showmap,a1	Address of mini graphics
	add.w	#1,d3		Move up xcounter
	add.w	#6,d5		Move up xcoord
	cmp.w	#6,d3		Move down yet?
	beq	drawmap6		Yes increase ycounter
drawmap7	move.w	#0,d0		Blank d0
	move.w	#0,d0		Zero d0
	move.b	(a0),d0		Get map block to draw
	cmp.w	#0,d0		Is there a block to draw?
	bne	drawmini		Yes draw it
drawmini3	add.w	#1,a0		Move up map counter
	add.w	#1,d7		Move up counter
	cmp.w	#375,d7		All drawn yet?
	bne	drawmap5		No draw next one
	bsr	scrnswap		Swapscreens
drawmap2	bsr	checkjoy		Check for joystick
	cmp.w	#0,fire		Wait for depressing of fire
	bne	drawmap2		If not check again
drawmap3	bsr	checkjoy		Check joystick
	cmp.w	#1,fire		Now wait for it to be pressed
	bne	drawmap3		If not check again
drawmap4	bsr	checkjoy		Check joystick
	cmp.w	#0,fire		Wait for it to be released
	bne	drawmap4		If not check again
	movem.l	(sp)+,d0-d7/a0-a6	Restore registers
	move.w	#0,nomome		Reenable controls
	rts			Return

drawmap6	move.w	#1,d3		Reset x counter
	sub.w	#30,d5		Move back xcoordinate
	add.w	#1,d4		Move up y counter
	add.w	#6,d6		Move down ycoordinate
	cmp.w	#6,d4		Next level yet?
	beq	drawmap8		Yes move down level
	bra	drawmap7		Return

drawmap8	move.w	#1,d4		Reset y counter
	sub.w	#30,d6		Move back ycoordinate
	add.w	#35,d5		Move up x level coordinate
	cmp.w	#250,d5		Is it too far right?
	bgt	drawmap9		Yes move it back and down
	bra	drawmap7		Return
	
drawmap9	move.w	#110,d5		Move X counter back left
	add.w	#35,d6		Move down Y counter
	bra	drawmap7		Return

drawscrn	cmp.w	#0,mode		Are we on two player mode
	bgt	clwmid		Yes, only clear middle of screen
	BSR	clw		Clear screen
clwmid2	BSR	drawstars		Draw starfield
	MOVE.L	#coord,a6		Address of coordinates
	MOVEM.W	(A6),d4-d7	Retrieve coordinates
	LSL.W	#1,D4		Adjust height (x2)
	MOVE.W	#12,D3		Block Size Variable
	SUB.W	d4,D3		Allow for perspective
	ADD.W	#2,D5		Layer to look at
	MULU.W	#25,D5		Convert to address
	move.w	#0,drawicon	Draw blocks not icons
	BSR	Dolayer		Draw Correct Layer
	BSR	drawmov		Draw moving blocks
	BSR	drawpl2		Draw second player
	SUB.W	#25,D5		Next layer up
	ADD.W	#10,D3		Change Size
	BSR	Dolayer		Draw Correct Layer
	BSR	drawmov		Draw moving blocks
	BSR	drawpl2		Draw second player
	SUB.W	#25,D5		Top layer
	ADD.W	#10,D3		Change Size
	BSR	Dolayer		Draw Last Layer
	BSR	drawmov		Draw moving blocks
	BSR	drawpl2		Draw second player
	cmp.w	#1,blowdyna	Is an explosion happening?
	bgt	seffects		Draw special effects
seffects2	BSR	drawblob		Draw players main charactor
	BSR	drawpaint		Draw amount of remaining paint
	BSR	drawlives		Draw number of remaining lives
	BSR	drawdyna		Draw amount of dynamite
	BSR	drawjetp		Draw number of jet packs
	cmp.w	#1,plyno		Is it player 1?
	beq	pl2stats		Yes, draw extra stats
pl2statsr	cmp.w	#0,mode		Are we on two player mode?
	bgt	copyhalf		Yes, only draw half screen
	BSR	scrnswap		Swap around screens
copyhalfr	cmp.w	#1,blowdyna	Is an explosion happening?
	bgt	seffects3		Draw special effects
seffects4	RTS			Return

pl2stats	cmp.w	#0,mode		Are we on two player mode?
	beq	pl2statsr		No, return
	move.l	screen_1,a0	Destination screen
	add.w	#112,a0		Move to position for line
	move.w	#199,d1		Set up counter
lineloop	or.w	#1,2(a0)		Set first bit plane
	and.w	#65534,(a0)	Second bit plane
	and.w	#65534,4(a0)	Third bit plane
	and.w	#65534,6(a0)	Fourth bit plane
	add.w	#160,a0		Move to next line
	dbf	d1,lineloop	Draw next dot
	cmp.w	#2,mode		Are we on competative mode?
	bne	pl2statsr		No, don't draw time limit
	move.w	#0,d0		Clear d0
	move.b	timelmt,d0	Get time limit in d0
	move.l	#timespace,a0	Space to construct what to draw
	move.w	d0,d1		Make copy of time left
	ext.l	d0		Extend d0
	divu.w	#100,d0		Find first digit of time
	move.w	d0,d2		Store variable
	add.w	#$30,d0		Convert to asc
	move.b	d0,(a0)+		Store first digit
	ext.l	d2		Extend d2
	mulu.w	#100,d2		Convert back
	sub.w	d2,d1		To find second digit
	move.w	d1,d0		Copy digit back
	ext.l	d0		Extend d0
	divu.w	#10,d0		Find second digit of time
	move.w	d0,d2		Store variable
	add.w	#$30,d0		Convert to asc
	move.b	d0,(a0)+		Store second digit
	ext.l	d2		Extend d2
	mulu.w	#10,d2		Convert back
	sub.w	d2,d1		To find last digit
	add.w	#$30,d1		Convert to asc
	move.b	d1,(a0)+		Store third digit
	move.b	#0,(a0)+		Place 0 on end
	move.w	#80,d2		X coordinate
	move.w	#0,d3		Y coordinate
	move.l	#timespace,a5	Address of message
	bsr	drawmes		Draw it
	bra	pl2statsr		Return

copyhalf	move.l	screen_1,a0	Address of source screen
	move.l	screen_2,a1	Destination address
	lea	40(a0),a0		Copy middle of source screen
	move.w	plyno,d0		Player number
	sub.w	#1,d0		Subtract one
	mulu.w	#80,d0		And multiply by 80 for address		
	add.w	d0,a1		Update destination address
	move.w	#199,d0		Set Up counter
copyhalf2	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	move.l	(a0)+,(a1)+	Copy across 1 long
	lea	80(a0),a0		Move to next line
	lea	80(a1),a1		On both screens
	dbf	d0,copyhalf2	All done yet?
	bra	copyhalfr		Return

wipeall	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5
	move.l	d1,a6
	rts

clwmid	move.l	screen_1,a0
	lea	31960(a0),a0
	bsr	wipeall
	move.w	#199,d0
clwmid_l	movem.l	d1-d5/a1-a5,-(a0)
	movem.l	d1-d5/a1-a5,-(a0)
	sub.l	#80,a0
	dbra	d0,clwmid_l
	bra	clwmid2

clw2	move.l	screen_2,a0
	bra	clw3

clw	move.l	screen_1,a0
clw3	lea	32000(a0),a0
	bsr	wipeall
	move.w	#204,d0
cs_loop	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	dbra	d0,cs_loop
	movem.l	d1-d5,-(a0)
	rts

cltop	movem.l	d0-d7/a0-a6,-(sp)
	move.l	shiftbuf,a0
	lea	8132(a0),a0
	bsr	wipeall
	move.w	#51,d0
	bsr	cs_loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts

scrnswap	move.l	screen_1,d0	Address of screen 1
	move.l	screen_2,d1	Address of screen 2
	move.l	d0,screen_2	Swap screen 2
	move.l	d1,screen_1	with screen 1
	move.w	#-1,-(sp)		Don't change screen resolution
	move.l	d0,-(sp)		change physical address
	move.l	d1,-(sp)		change logical address
	move.w	#5,-(sp)		change screen parameters
	trap	#14		Call XBIOS
	lea	12(sp),sp		Correct stack
	move.w	#37,-(sp)		Wait for Vsync
	trap	#14		Call XBIOS
	addq.l	#2,sp		Correct stack
	rts			Return

offset	bsr	boundary		find offset
	LSR.W	#1,d1		Round to nearest 2 pixels
	LSL.W	#3,d1		calculate address
	ADD.W	d1,a1		point to correct offset
	move.l	(a1)+,a2		retrieve block address
	cmp.w	#1,player		Are we drawing a player?
	beq	doplayer		Yes, we are
doplayer2	move.w	(a1)+,d1		retreive width
	move.w	(a1)+,d0		retreive height
	rts			return

doplayer	sub.l	#50000,a2		Point to alternative mask
	bra	doplayer2		Return

graphicno	MOVE.W	#32,d0		Find block graphic number
	SUB.W	d3,d0		By subtracting size from 23
	LSL.W	#5,d0		and then multiplying by 32
	ADD.W	D0,A1		point to correct block
	RTS			return

Dolayer	move.l	#layout,a1	Address of layout data
	bsr	graphicno		Calculate graphic number
	movem.w	d3-d7,-(sp)	Store X,Y,Z coordinates
	move.l	#map,a6		Address of map data
	add.l	d5,a6		Point to correct layer

	move.w	d3,d5		Calculate X offset from middle
	mulu.w	#5,d5		by multiplying block size
	LSR	#1,d5		by 2.5
	muls.w	d3,d7		Find Xcoordinate
	asr.w	#5,d7		In Pixels
	add.w	#160,d7		Convert to screen coord
	sub.w	d5,d7		Calculate starting position

	muls.w	d3,d6		Find Ycoordinate
	asr.w	#5,d6		In Pixels
	add.w	#100,d6		Convert to screen coordinates
	sub.w	d5,d6		Calculate starting position

	move.w	#4,d5		Reset counter 1
	move.w	#4,d4		Reset counter 2
	move.w	d7,-(sp)		Store X coordinate

layer1	move.b	(a6)+,d2		Block to draw
	bsr	drawblck		Draw it
	ADD.W	d3,d7		Move on X coordinate
	dbf	d5,layer1		Do next block
	move.w	#4,d5		Reset counter 1
	move.w	(sp),d7		Restore X coordinate
	add.w	d3,d6		Move on Y coordinate
	dbf	d4,layer1		Do next block
	addq.l	#2,sp		Correct stack
	movem.w	(sp)+,d3-d7	restore X,Y,Z coordinate
	Rts			return	

drawpl2	cmp.w	#0,mode		On two player mode
	beq	return		No, return
	movem.w	d0-d7,-(sp)	Store important variables
	divu.w	#25,d5		Find layer in coordinates
	move.l	#player2,a6	Player 2's varibles
	add.l	#42,a6		Find his coordinates
	move.w	2(a6),d0		Get Z coordinate
	cmp.w	d5,d0		Is it on the right layer?
	bne	drawpl2r		No, Return
	move.w	(a6),d0		Get size
	lsl	#1,d0		Double it
	add.w	d0,d3		Add onto base size
	cmp.w	#32,d3		Is it too big?
	bgt	drawpl2r		Yes don't draw it
	move.l	#layout,a1	Address of layout data
	bsr	graphicno		Work out the graphic number
	move.w	d3,d5		Calculate X offset from middle
	mulu.w	#5,d5		By multiplying player size
	lsr	#1,d5		By 2.5
 	muls	d3,d7		Find X coordinate
	asr.w	#5,d7		In pixels
	add.w	#160,d7		Convert to screen coordinates
	sub.w	d5,d7		Calculate starting position
	muls	d3,d6		Find Y coordinate
	asr.w	#5,d6		In pixels
	add.w	#100,d6		Convert to screen coordinates
	sub.w	d5,d6		Calculate starting position
	move.w	#64,d4		Coordinates are stored backwards
	sub.w	6(a6),d4		Get X coordinate
	mulu.w	d3,d4		Multiply by player size
	asr	#5,d4		And divide by 32
	add.w	d4,d7		To find number to add to X
	move.w	#64,d4		Coordinates are stored backwards
	sub.w	4(a6),d4		Get Y coordinate
	mulu.w	d3,d4		Multiply by block size
	asr	#5,d4		And divide by 32
	add.w	d4,d6		To find number to add to Y
	move.w	#3,d2		Change to other colour
	sub.w	plyno,d2		player to draw
	move.w	#1,player		We are drawing a player
	move.w	#0,drawicon	Not an icon
	bsr	drawblck		Draw it
	move.w	#0,player		We aren't drawing a player
drawpl2r	movem.w	(sp)+,d0-d7	Restore variables
	rts			Return	

drawmov	cmp.w	#0,nummov		Any moving blocks?
	beq	return		No Return
	divu.w	#25,d5		Find layer in coordinates
	move.l	#blcoord,a6	Moving block coordinates
	move.w	#0,d1		Reset counter
drawmov3	move.w	6(a6),d0		Get Zcoordinate
	cmp.w	d5,d0		Is it on the right layer
	beq	drawmov2		Yes draw it
drawmov4	add.w	#1,d1		Move up counter
	add.w	#18,a6		Move up coordinate pointer
	cmp.w	nummov,d1		All moving blocks drawn yet?
	bne	drawmov3		No draw next one
	mulu.w	#25,d5		Convert back to layer data
	rts			Return

drawmov2	movem.w	d0-d7,-(sp)	Store important variables
	move.l	a6,-(sp)		Moving block coordinates
	move.w	8(a6),d0		Get size
	lsl	#1,d0		Double it
	add.w	d0,d3		Add onto base size
	cmp.w	#32,d3		Is it too big?
	bgt	movret		Yes don't draw it
	move.w	(a6),d0		Get block type
	cmp.w	#5,d0		If its a disappearing block
	beq	discheck		Check it needs drawing

discheck2	move.l	#layout,a1	Address of layout data
	bsr	graphicno		Work out the graphic number

	move.w	d3,d5		Calculate X offset from middle
	mulu.w	#5,d5		By multiplying block size
	lsr	#1,d5		By 2.5

 	muls	d3,d7		Find X coordinate
	asr.w	#5,d7		In pixels
	add.w	#160,d7		Convert to screen coordinates
	sub.w	d5,d7		Calculate starting position
		
	muls	d3,d6		Find Y coordinate
	asr.w	#5,d6		In pixels
	add.w	#100,d6		Convert to screen coordinates
	sub.w	d5,d6		Calculate starting position

	move.w	2(a6),d4		Get X coordinates
	mulu.w	d3,d4		Multiply by block size
	lsr	#5,d4		And divide by 32
	add.w	d4,d7		To find number to add to X

	move.w	4(a6),d4		Get Y coordinates
	mulu.w	d3,d4		Multiply by block size
	lsr	#5,d4		And divide by 32
	add.w	d4,d6		To find number to add to Y

	move.w	12(a6),d2		Block type to draw
	bsr	drawblck		Draw it

movret	move.l	(sp)+,a6		Address of moving block variables
	movem.w	(sp)+,d0-d7	Restore variables
	bra	drawmov4		Return	

discheck	move.w	10(a6),d0		Is it there
	cmp.w	#0,d0		If not then
	blt	movret		Quit draw routine
	bra	discheck2		Otherwise return

drawblob	move.w	#144,d7		Xcoordinate
	move.w	#84,d6		Ycoordinate
	move.w	#2,d1		Width
	move.w	#32,d0		Height
	move.w	#1,d2		Line number
	cmp.w	#0,mode		Are we on two player mode?
	bgt	noanim		Sorry, No animations
	cmp.w	#1,death		Are we dead?
	beq	drawdead3		Yes, draw correct sprite
	cmp.w	#0,somerslt	Are we doing a somersault
	bne	dospin		Yes, gosub animation routine
	cmp.w	#0,jetp		Are we using a jetpack
	bne	jetback		Draw jetpack on our back
nospin	bsr	animeyes		Make blob blink occasionally
	move.l	#iconlay,a1	Mask address
	move.w	#1,drawicon	Draw icon, not block
	bsr	drawicn		Draw it
	rts			Return

noanim	move.l	#layout,a1	Address of layout data
	move.w	plyno,d2		Which player to draw
	move.w	#1,player		We are drawing a player
	move.w	#0,drawicon	Not an icon
	bsr	drawblck		Draw it
	move.w	#0,player		We aren't drawing a player
	rts			Return

strtblink	move.w	#0,blinkc		Reset counter
	bra	animeyes2		Return

animeyes	add.w	#1,blinkc		Move up blink counter
	cmp.w	#372,blinkc	At end of table yet?
	beq	strtblink		Yes, go back to start
animeyes2	move.l	#blink,a1		Get blink status
	add.w	blinkc,a1		Point to correct position
	move.b	(a1),d2		Get eyes status
	lsl.w	#3,d2		Convert to address
	move.l	#iconlay1,a1	Icon address
	add.w	d2,a1		Find correct icon
	move.l	a1,iconno		Graphic address
	move.w	#0,d2		Line to draw
	rts

dospin	sub.w	#1,somerslt	Decrease somersault counter
	cmp.w	#3,somerslt	Are we spinning yet?
	bgt	nospin		No, return	
	move.w	#6,d2		Work out position from left
	sub.w	somerslt,d2	Which frame of animation?
	lsl.w	#3,d2		Convert to address
	move.l	#iconlay1,a1	Mask address
	add.w	d2,a1		Find position on line
	move.w	#0,d2		Line number
	move.l	a1,iconno		graphic address
	move.l	#iconlay,a1	Mask address
	move.w	#1,drawicon	Draw icon, not block
	bsr	drawicn		Draw it
	rts			Return

jetback	sub.w	#1,jetp		Decrease jetpack counter
	move.l	#iconlay1,a1	Graphic address
	add.w	#56,a1		Jet pack is seventh along
	move.w	#0,d2		Line number
	move.l	a1,iconno		Store graphic address	
	move.l	#iconlay,a1	Mask address
	add.w	#8,a1		Jet pack is second mask
	move.w	#1,drawicon	Draw icon, not block
	bsr	drawicn		Draw it
	rts			Return

drawdead3	move.l	#iconlay1,a1	Icon address
	add.w	#72,a1		Last block on the line
	move.l	a1,iconno		graphic address
	move.l	#iconlay,a1	Mask address
	move.w	#1,drawicon	Draw icon, not block
	bsr	drawblck		Draw it
	rts			Return

drawpaint	move.w	#140,d6		Ycoordinate
	move.w	#2,d1		Width
	move.w	#40,d0		Height
	move.w	#1,d2		Line number
	move.l	#iconlay,a1	Mask address
	add.w	#16,a1		Paint pot is third mask
	move.l	#iconlay1,a2	Icon address
	move.w	paint,d7		Amount of paint left
	cmp.w	#0,d7		Is it blue paint
	blt	drawbp		Yes, so draw it blue
	cmp.w	#2,d7		Is it on line above
	blt	painttop		Yes go to different routine
drawbp2	sub.w	#2,d7		Values above 2 on line below
	lsl.w	#3,d7		Find address
	add.w	d7,a2		Move up second counter
	move.l	a2,iconno		Pass parameter to routine
	move.w	#1,drawicon	Draw icon, not block
	move.w	#0,d7		Xcoordinate
	cmp.w	#0,mode		Are we on a 2player game
	bgt	icon2pl		Yes draw paint on view
	bsr	drawicn		Draw it
	rts			Return

icon2pl	move.w	#80,d7		Xcoordinate
	bsr	drawicn		Draw it
	rts			return

drawbp	move.w	#0,d7		Zero d7
	sub.w	paint,d7		Turn number into positive
	add.w	#5,d7		Move onto blue paint
	bra	drawbp2		Return

drawlives	cmp.w	#2,mode		On competative mode?
	beq	return		Yes, we don't have lives
	cmp.w	#3,lives		Any lives to draw?
	beq	return		No, there aren't
	move.w	#125,d6		Ycoordinate
	move.w	#2,d1		Width
	move.w	#9,d0		Height
	move.w	#0,d2		Line number
	move.l	#iconlay,a1	Mask address
	move.w	lives,d7		Amount of lives left
	cmp.w	#0,d7		Have we got more than 3?
	blt	liover		Yes, goto overflow routine
liover2	lsl.w	#3,d7		Find address of mask
	add.w	d7,a1		Move up pointer
	add.w	#24,a1		Lives start from fourth mask
	move.l	#iconlay2,a2	Address of icons
	add.w	d7,a2		Move up pointer
	move.w	#0,d7		Xcoordinate
	move.w	#1,drawicon	Draw icon, not block
	move.l	a2,iconno		Pass parameter to routine
	cmp.w	#0,mode		Are we on a 2player game
	bgt	icon2pl		Yes draw paint on view
	bsr	drawicn		Draw it
	rts			Return

liover	move.w	#0,d7		Only draw 3 lives
	bra	liover2		Return

dyover	move.w	#0,d7		Only draw 3 dynamite
	bra	dyover2		Return

jetover	move.w	#0,d7		Only draw 3 jetpacks
	bra	jetover2		Return

drawdyna	cmp.w	#3,dynamite	Any lives to draw?
	beq	return		No, there aren't
	move.w	#114,d6		Ycoordinate
	move.w	#2,d1		Width
	move.w	#9,d0		Height
	move.w	#0,d2		Line number
	move.l	#iconlay,a1	Mask address
	move.w	dynamite,d7	Amount of lives left
	cmp.w	#0,d7		More than 3 dynamite
	blt	dyover		Yes, goto overflow routine
dyover2	add.w	#3,d7		Dynamite is second sprite along
	lsl.w	#3,d7		Find address of mask
	add.w	d7,a1		Move up pointer
	add.w	#24,a1		Dynamite starts from seventh mask
	move.l	#iconlay2,a2	Address of icons
	add.w	d7,a2		Move up pointer
	move.w	#0,d7		Xcoordinate
	move.w	#1,drawicon	Draw icon, not block
	move.l	a2,iconno		Pass parameter to routine
	cmp.w	#0,mode		Are we on a 2player game
	bgt	icon2pl		Yes draw paint on view
	bsr	drawicn		Draw it
	rts			Return

drawjetp	cmp.w	#3,jetpack	Any Jetpacks to draw?
	beq	return		No, there aren't
	move.w	#103,d6		Ycoordinate
	move.w	#2,d1		Width
	move.w	#9,d0		Height
	move.w	#0,d2		Line number
	move.l	#iconlay,a1	Mask address
	move.w	jetpack,d7	Number of jet packs
	cmp.w	#0,d7		More than 3 jetpacks?
	blt	jetover		Yes goto overflow routine
jetover2	add.w	#6,d7		Jetpacks are third sprite along
	lsl.w	#3,d7		Find address of mask
	add.w	d7,a1		Move up pointer
	add.w	#24,a1		Jetpacks start from tenth mask
	move.l	#iconlay2,a2	Address of icons
	add.w	d7,a2		Move up pointer
	move.w	#0,d7		Xcoordinate
	move.w	#1,drawicon	Draw icon, not block
	move.l	a2,iconno		Pass parameter to routine
	cmp.w	#0,mode		Are we on a 2player game
	bgt	icon2pl		Yes draw paint on view
	bsr	drawicn		Draw it
	rts			Return

painttop	move.l	#iconlay1,a2	Icon address
	move.w	#0,d2		Top line
	add.w	#64,a2		Move to start of paint data
	lsl.w	#3,d7		Find address of paint pot
	add.w	d7,a2		Move up second counter
	move.l	a2,iconno		Pass parameter to routine
	move.w	#1,drawicon	Draw icon, not block
	move.w	#0,d7		Xcoordinate
	cmp.w	#0,mode		Are we on a 2player game
	bgt	icon2pl		Yes draw paint on view
	bsr	drawicn		Draw it
	rts			Return

	*******************************************
	*Draw block, draws tile block onto screen *
	*d7 is Xcoordinates, d6 is Ycoordinates   *
	*d1 is width, d2 is graphic number        *
	*d0 is height, a1 contains layout address *
	*******************************************

overflow	move.l	(sp)+,a1		Restore graphics address
	movem.w	(sp)+,d1-d7	Restore registers
	rts			Return

drawblck	cmp.B	#0,d2		Is there a block to draw?
	beq	return		If not return
drawicn	movem.w	d1-d7,-(sp)	Store registers
	move.l	a1,-(sp)		Store graphics address
	bsr	offset		Calculate offset
	move.w	#304,d4		Right edge
	sub.w	d3,d4		Minus Block size
	move.w	#192,d5		Bottom edge
	sub.w	d3,d5		Minus Block size
	cmp.w	#1,drawicon	Turn off overflow on icons
	beq	skipover		Disable overflow checks
	cmp.w	#8,d7		Check for left edge overflow
	blt	overflow		If so don't draw block
	cmp.w	d4,d7		check for right edge overflow
	bgt	overflow		If so don't draw block
	cmp.w	#8,d6		Check for top edge overflow
	blt	overflow		If so don't draw block
	cmp.w	d5,d6		Check for bottom edge overflow
	bgt	overflow		If so don't draw block
skipover	move.l	a2,a3		Store graphic address
	move.l	screen_1,a4	Destination address
	move.w	d2,a0		Store graphic number
	mulu.w	#160,d6		Convert ycoord into address
	add.w	d6,a4		Add onto destination address
	LSR	#1,d7		Convert xcoord into address
 	add.w	d7,a4		Add onto destination address
	move.l	a4,a1		Store destination address
	move.w	d1,d2		calculate width in screen bytes
	lsl.w	#3,d2		by multiplying by 8
	move.w	#160,d3		move down next line
	sub.w	d2,d3		go to start of line
	sub.w	#1,d1		Reduce width
	sub.w	#1,d0		Reduce height
	move.w	d1,d6		Set up counter 1
	move.w	d0,d7		Set up counter 2
startcopy	move.l	(a4),d2		copy across first 2 bit planes
	and.l	(a2)+,d2		Logical operation 'AND'
	move.l	d2,(a4)+		Copy across
	move.l	(a4),d2		Copy across last 2 bit planes
	and.l	(a2)+,d2		Logical operation 'AND'
	move.l	d2,(a4)+		Copy across	
	dbf	d6,startcopy	Copy next part of line
	add.w	d3,a4		Go to start of next line
	move.w	d1,d6		Reset counter 1
	dbf	d7,startcopy	copy next line
	move.w	a0,d2		Which graphic are we using?
	move.l	a3,a2		Restore graphics address
	cmp.w	#1,drawicon	Icons or blocks?
	beq	iconadd		Move down 8K not 50
address	move.l	#blockpos,a0	Address of block table
	cmp.w	#1,player		Are we drawing player graphics?
	beq	pldraw		Yes, we are
	sub.w	#1,d2		Blocks count from zero
	lsl.w	#2,d2		Convert to long word
	add.w	d2,a0		Find place in table
	move.l	(a0),d7		Find offset
	sub.l	d7,a2		Find address of block
addr2	move.l	a1,a4		Restore destination address
	move.w	d1,d6		Set up counter 1
	move.w	d0,d7		Set up counter 2	
copy2	move.l	(a4),d2		Copy across first 2 bit planes
	or.l	(a2)+,d2		Using logical operation 'OR'
	move.l	d2,(a4)+		Copy across
	move.l	(a4),d2		Copy across last 2 bit planes
	or.l	(a2)+,d2		Using logical operation 'OR'
	move.l	d2,(a4)+		Copy across
	dbf	d6,copy2		Draw next part of line
	add.w	d3,a4		Go to start of next line
	move.w	d1,d6		Reset counter 1
	dbf	d7,copy2		copy next line
	move.l	(sp)+,a1		Restore graphic address
	movem.w	(sp)+,d1-d7	Restore Registers
	Rts			return

pldraw	move.l	#0,d6		Zero d6
	move.w	d2,d6		Make copy of d2
	mulu.w	#50000,d6		Find offset
	sub.l	d6,a2		Find place in table
	bra	addr2		Return

iconadd	move.l	iconno,a2		Which icon are we using
	move.l	(a2),a2		Get address of graphic
	cmp.w	#0,d2		Are we on the right row?
	beq	addr2		Yes no need to change it
iconadd2	SUB.L	#8000,a2		Move down 8000 bytes
	SUB.W	#1,d2		Decriminate counter
	CMP.W	#0,d2		Check for end?
	BNE	iconadd2		If not loop around again
	BRA	addr2		return

return	RTS			return

boundary	move.w	d7,d1		Make copy of x offset
	LSR.W	#4,d7		Round down to nearest
	LSL.W	#4,d7		16 pixels
	SUB.W	d7,d1		Find which graphic to use
	rts			Return
	
end	BSR	stopquart		Stop quartet music
	BSR	quitquart		Quit replayer
	BSR	oldrez		Old screen resolution
	BSR	oldpalt		Switch to default palette
	BSR	endjoy		Reset Joystick routines
	CLR.W	-(SP)		Quit program
	TRAP	#1		Call GEMDOS

	******************************************
	*Returns program to old screen resolution*
	******************************************

oldrez	MOVE.W	old_rez,-(SP)	Reset to old screen resolution
	MOVE.L	oldphys,-(SP)	old physical address
	MOVE.L	oldlog,-(SP)	old logical address
	MOVE.W	#5,-(SP)		Change screen parameters
	TRAP	#14		Call XBIOS
	LEA	12(SP),SP		Correct Stack
	RTS			Return

	*************************
	*Find Screen Resoulution*
	* Returns answer in d0  *
	*************************

findmode	MOVE.W	#4,-(SP)		Returns graphics resolution
	TRAP	#14		Call XBIOS
	ADDQ.L	#2,SP		Correct stack
	RTS			Return

	***********************
	*Set to low resolution*
	***********************

mode0	CLR.W	-(SP)		0 = low resolution
	MOVE.L	#-1,-(SP)		Don't change physical address
	MOVE.L	#-1,-(SP)		Don't change logical address
	MOVE.W	#5,-(SP)		Change Screen Parameters
	TRAP	#14		Call XBIOS
	LEA	12(SP),SP		Correct stack
	RTS			Return

	**********************
	*Get Screen Addresses*
	**********************

getscreen	MOVE.W	#2,-(SP)		Return current screen address
	TRAP	#14		Call XBIOS
	ADDQ.L	#2,SP		Correct Stack
	move.l	d0,oldphys	Old physic address
	move.l	d0,oldlog		Old logical address
	MOVE.L	D0,screen_1	Store as screen 1
	sub.w	#32000,d0		Get address for second screen
	move.l	d0,screen_2	This line for normal version
	MOVE.L	#$f0800,d0	Get end of memory
*	move.l	d0,screen_2	This line for Fred The Debugger
	sub.l	#40000,d0		Subtract 40000
	move.l	d0,screen_3	and store as screen 3
	sub.l	#10000,d0		Subtract 10000
	move.l	d0,shiftbuf	and store for preshift buffer
	SUB.L	#4000,d0		Subtract 4000
	move.l	d0,iconmask	and store as icon masks
	SUB.L	#8000,d0		Subtract 8000
	MOVE.L	d0,icons1		And store as icons
	SUB.L	#8000,d0		Subtract 8000
	MOVE.L	d0,icons2		Store for more icons
	SUB.L	#8000,d0		Subtract 8000
	MOVE.L	d0,icons3		Store for last line of icons
	SUB.L	#61000,d0		Subtract 61000
	MOVE.L	D0,samples	and store as samples
	SUB.L	#6000,D0		Subtract 6000
	MOVE.L	d0,music		and store as music
	SUB.L	#2500,D0		Subtract 2500
	MOVE.L	d0,sincos		and store for trig table
	sub.l	#1500,d0		Subtract 1500
	move.l	d0,sincos2	for processing table
	sub.l	#50000,d0		Subtract 50000
	move.l	d0,masks		and store as masks
	RTS			Return

reslide	move.w	#1,d0		Change back to 1
	bra	moveblck2		Return

lift2pl	move.w	#5,d1		Move lifts at half speed
	bra	lift2plr		Return

moveblck	move.w	slide,d0		Do vertical blocks move?
	add.w	#1,d0		Change status
	move.w	#3,d1		How fast do lifts move
	cmp.w	#0,mode		Do they need slowing down?
	bgt	lift2pl		Yes, half speed
lift2plr	cmp.w	d1,d0		Reset counter?
	beq	reslide		Yes we do
moveblck2	move.w	d0,slide		Save variable
	cmp.w	#0,nummov		Any moving blocks?
	beq	return		No, quit routine
	move.w	#0,d0		Reset counter
	move.l	#blcoord,a6	Moving block coordinates
moveblck3	move.w	d0,-(sp)		Store counter
	bra	movbla6		Move the block

movblr	move.w	2(a6),d1		Xcoordinate
	move.w	4(a6),d2		Ycoordinate
	move.w	6(a6),d3		Zcoordinate
	move.w	8(a6),d4		Height adjustment
	move.w	d1,d5		Right edge
	move.w	d2,d6		Bottom edge
	
	clr.w	d0		Clear d0
	add.w	#2,d1		Move to real square
	add.w	#2,d2		Move to real square
	add.w	#30,d5		Move to real square
	add.w	#30,d6		Move to real square
	lsr.w	#5,d1		Divide by 32
	lsr.w	#5,d2		Divide by 32
	lsr.w	#5,d5		Divide by 32
	lsr.w	#5,d6		Divide by 32

	mulu.w	#25,d3		25 pieces of data per level
	mulu.w	#5,d2		5 Pieces of data per row
	mulu.w	#5,d6		5 pieces of data per row

	move.l	#map,a5		Address of map data
	add.w	d3,a5		Find address of level
	move.l	a5,a2		Store address of level
	add.w	d2,a5		Find address of row
	move.l	a5,a4		Store address of row
	add.w	d1,a5		Find address of actual square
	move.b	(a5),d7		Get contents of square
	cmp.b	#0,d7		Have we collided
	bne	collide10		Yes we have

	move.l	a4,a5		Find address of row
	add.w	d5,a5		Find address of actual square
	move.b	(a5),d7		Get contents of square
	cmp.b	#0,d7		Have we collided
	bne	collide10		Yes we have

	move.l	a2,a5		Find address of level
	add.w	d6,a5		Find address of row
	move.l	a5,a4		Store address of row
	add.w	d1,a5		Find address of actual square
	move.b	(a5),d7		Get contents of square
	cmp.b	#0,d7		Have we collided
	bne	collide10		Yes we have

	move.l	a4,a5		Find address of row
	add.w	d5,a5		Find address of actual square
	move.b	(a5),d7		Get contents of square
	cmp.b	#0,d7		Have we collided
	bne	collide10		Yes we have

nocol	move.w	(sp)+,d0		Get counter
	add.w	#1,d0		Move up counter
	add.w	#18,a6		Move up to next block
	cmp.w	nummov,d0		All blocks moved yet?
	bne	moveblck3		No move next one
	rts			Return

collide10	move.w	10(a6),d0		Get direction of movement
	move.w	#0,d1		Zero d1
	sub.w	d0,d1		To find reverse movement
	move.w	d1,10(a6)		Store in table
	cmp.w	#0,d1		Was it going up
	bgt	nocol		No so return
	move.w	(a6),d0		Is it a lift?
	cmp.w	#4,d0		Check variable
	bne	nocol		No so return
	move.w	6(a6),d0		Get Z coordinate
	add.w	#1,d0		Decrease height
	move.w	#4,8(a6)		Top of layer below
	move.w	d0,6(a6)		Store height
	bra	nocol		Return

movbla6	move.w	(a6),d0		Get type of moving block
	cmp.w	#2,d0		Is it a left and right block?
	beq	type2		Yes it is
	cmp.w	#3,d0		Is it an up and down block?
	beq	type3		Yes it is
	cmp.w	#4,d0		Is it an in and out block?
	beq	type4		Yes it is
	cmp.w	#5,d0		Is it a flashing block?
	beq	type5		Yes it is
	bra	movblr		Return

type2	move.w	2(a6),d0		Get x coordinate
	move.w	10(a6),d1		Get direction
	add.w	d1,d0		Change position
	move.w	d0,2(a6)		Store new position
	move.w	d0,d1		Make copy of position
	add.w	#30,d1		Right hand-edge
	cmp.w	#4,d0		Are we off the left
	blt	collide10		Yes we've collided
	cmp.w	#156,d1		Are we off the right
	bgt	collide10		Yes we've collided
	bra	movblr		Return

type3	move.w	4(a6),d0		Get y coordinate
	move.w	10(a6),d1		Get direction
	add.w	d1,d0		Change position
	move.w	d0,4(a6)		Store new position
	move.w	d0,d1		Make copy of position
	add.w	#30,d1		Right hand-edge
	cmp.w	#4,d0		Are we off the top
	blt	collide10		Yes we've collided
	cmp.w	#156,d1		Are we off the bottom
	bgt	collide10		Yes we've collided
	bra	movblr		Return

type4	cmp.w	#2,slide		Does it move this time
	bne	nocol		No it doesn't
	move.w	6(a6),d0		Get Z coordinate
	move.w	8(a6),d1		Get height adjustment
	move.w	10(a6),d2		Get direction
	cmp.w	#0,d2		Check direction
	bgt	moveupp		Move block upwards
	blt	movedown		Move block downwards
type4r	move.w	d0,6(a6)		Store Z coordinate
	move.w	d1,8(a6)		Store height adjustment
	cmp.w	#3,d0		Is it off top
	blt	collide10		Yes it is
	cmp.w	#17,d0		Is it off the bottom
	bgt	collide10		Yes it is
	cmp.w	#0,d1		Are we inbetween levels?
	bne	nocol		Yes so we can't collide
	bra	movblr		Return

moveupp	add.w	#1,d1		Alter height variable
	cmp.w	#4,d1		Is it off top
	bgt	layerup		Yes go up a layer
	bra	type4r		Return

layerup	move.w	#0,d1		Move to bottom of layer
	sub.w	#1,d0		Next layer up
	bra	type4r		Return

movedown	sub.w	#1,d1		Alter height variable
	cmp.w	#0,d1		Is it off bottom
	blt	layerdown		Yes go down a layer
	bra	type4r		Return

layerdown	move.w	#4,d1		Top of layer
	add.w	#1,d0		Next layer down
	bra	type4r		Return

type5	move.w	14(a6),d0		Get flash counter
	add.w	#1,d0		Move up counter
	move.w	d0,14(a6)		Store counter
	move.w	16(a6),d1		Get flash rate
	cmp.w	d1,d0		Does it status change yet?
	bgt	changest		Yes it does
	bra	nocol		Return
	
changest	move.w	#0,14(a6)		Zero flash counter
	move.w	10(a6),d0		Get flash status
	move.w	#0,d1		Zero d1
	sub.w	d0,d1		Reverse flash status
	move.w	d1,10(a6)		Store flash status
	bra	movblr		Return

countblck	move.w	#0,d6		Number of blue blocks
	move.w	#0,d7		Number of purple blocks
	move.l	#map,a0		Address of mapdata
	move.w	#0,d0		Zero counter
count2	cmp.b	#1,(a0)		Is it a blue block?
	beq	addblue		Yes, increase counter
	cmp.b	#3,(a0)		Is it a blue block?
	beq	addblue		Yes, increase counter
	cmp.b	#2,(a0)		Is it a purple block?
	beq	addpurple		Yes, increase counter
	cmp.b	#4,(a0)		Is it a purple block?
	beq	addpurple		Yes, increase counter
count3	add.w	#1,d0		Move up counter
	add.w	#1,a0		Move up map pointer
	cmp.w	#550,d0		All done yet?
	bne	count2		No, check some more
	cmp.w	#0,nummov		Any moving blocks?
	beq	return		No, return
	move.l	#blcoord,a6	Address of block coordinate
	move.w	nummov,d0		Number of moving blocks
count4	cmp.w	#50,6(a6)		Is out of range
	bgt	count5		Yes it is
	cmp.w	#1,12(a6)		Is it a blue block?
	beq	addblue2		Yes, move up counter
	cmp.w	#2,12(a6)		Is it a purple block?
	beq	addpurp2		Yes, move up counter
	cmp.w	#3,12(a6)		Is it a blue block?
	beq	addblue2		Yes, move up counter
	cmp.w	#4,12(a6)		Is it a purple block?
	beq	addpurp2		Yes, move up counter
count5	sub.w	#1,d0		Decrease counter
	add.w	#18,a6		Move up block pointer
	cmp.w	#0,d0		Any more blocks
	bne	count4		Yes, check next one
	rts			Return

addblue2	add.w	#1,d6		Move up blue counter
	bra	count5		Return

addblue	add.w	#1,d6		Move up number of blue blocks
	bra	count3		Return

addpurple	add.w	#1,d7		Move up purple counter
	bra	count3		Return

addpurp2	add.w	#1,d7		Move up purble counter
	bra	count5		Return

chckblue	move.w	#0,won		We haven't won yet
	cmp.w	#2,mode		Are we on competative mode?
	beq	return		Yes, we don't win this way
	add.w	#1,blcont		Don't check every update
	cmp.w	#6,blcont		Check yet?
	bne	return		No, return
	move.w	#0,blcont		Reset counter
	move.l	#map,a0		Address of mapdata
	move.w	#0,d0		Zero counter
chckblue2	cmp.b	#1,(a0)		Is it a blue block?
	beq	return		Yes, we can return
	cmp.b	#3,(a0)		Is it a blue block?
	beq	return		Yes, we can return
	cmp.b	#10,(a0)		Is it a blue block?
	beq	return		Yes, we can return
	cmp.b	#15,(a0)		Is it a blue block?
	beq	return		Yes, we can return
	add.w	#1,d0		Move up counter
	add.w	#1,a0		Move up map pointer
	cmp.w	#550,d0		All done yet?
	bne	chckblue2		No, check some more
	cmp.w	#0,nummov		Any moving blocks?
	beq	chckblue5		No, there aren't	
	move.l	#blcoord,a6	Address of block coordinate
	move.w	nummov,d0		Number of moving blocks
chckblue3	cmp.w	#50,6(a6)		Is out of range
	bgt	chckblue4		Yes it is
	cmp.w	#1,12(a6)		Is it a blue block?
	beq	return		Yes, we can return
	cmp.w	#3,12(a6)		Is it a blue block?
	beq	return		Yes, we can return
	cmp.w	#10,12(a6)	Is it a blue block?
	beq	return		Yes, we can return
	cmp.w	#15,12(a6)	Is it a blue block?
	beq	return		Yes, we can return
chckblue4	sub.w	#1,d0		Decrease counter
	add.w	#18,a6		Move up block pointer
	cmp.w	#0,d0		Any more blocks
	bne	chckblue3		Yes, check next one
chckblue5	move.w	#1,death		We are dead
	move.w	#1,won		Because we have won
	rts			Return

convert	move.l	#map2,a6		Address of mapdata
	move.l	#pullersb,a3	Address of attractor/repellers
	move.l	#map3,a4		Address of block graphic data
	move.l	#blcoord2,a5	Address of moving block coordinates
	move.w	#0,nopull		There aren't any pullers yet
	move.w	#0,d4		Xcoord counter
	move.w	#0,d3		Ycoord counter
	move.w	#0,d2		Zcoord counter
	move.w	#0,d7		Reset counter
	move.w	#0,d5		Counter number of moving blocks
convert4	move.w	#0,d6		Zero D6
	move.w	#0,d0		Zero D0
	move.b	(a6)+,d6		Find type of block
	move.b	(a4)+,d0		Find block graphic
	cmp.w	#13,d0		Is it a repeller block?
	beq	repell		Yes gosub correct routine
	cmp.w	#14,d0		Is it an attractor block?
	beq	attract		Yes gosub correct routine
	cmp.w	#1,d6		Is it a special block?
	bgt	convert2		Yes convert it
convert3	add.w	#1,d7		Move up counter
	add.w	#1,d4		Move up X counter
	cmp.w	#5,d4		Move up Y counter yet?
	beq	ycount		Yes we do
ycount2	cmp.w	#550,d7		Entire map checked yet
	bne	convert4		No convert some more
	move.w	d5,nummov		Store number of special blocks
	bsr	copymov		Copy across moving blocks
	bsr	copymap		Copy across map
	bsr	copypull		Copy attractors/repellers
	move.w	oldfile,-(sp)	File to close
	move.w	#$3e,-(sp)	Close file
	trap	#1		Call GEMDOS
	addq.l	#4,sp		Correct stack
	rts			Return

repell	add.w	#1,nopull		Increase counter
	movem.w	d2-d4,-(sp)	Store coordinates
	bsr	pullcoord		Get coordinates of puller
	move.w	#1,(a3)+		Repeller type block
	movem.w	(sp)+,d2-d4	Restore coordinates
	bra	convert3		Return

pullcoord	lsl.w	#5,d4		Multiply X coord by 32
	sub.w	#64,d4		Subtract 96 for real coordinate
	muls.w	#-1,d4		Coordinates are stored reversed
	move.w	d4,(a3)+		Store coordinate in table
	lsl.w	#5,d3		Multiply Y coord by 32
	sub.w	#64,d3		Subtract 96 for real coordinate
	muls.w	#-1,d3		Coordinates are stored reversed
	move.w	d3,(a3)+		Store coordinate in table
	move.w	d2,(a3)+		Store Z coordinate in table
	rts			Return

attract	add.w	#1,nopull		Increase counter
	movem.w	d2-d4,-(sp)	Store coordinate
	bsr	pullcoord		Get coordinates of puller
	move.w	#2,(a3)+		Attractor type block
	movem.w	(sp)+,d2-d4	Restore coordinates
	bra	convert3		Return

explpull	cmp.w	#0,height		On same level?
	bne	return		No can't explode them
	lsl.w	#5,d7		Convert xcoordinate
	lsl.w	#5,d6		Convert ycoordinate
	move.w	d7,d2		Copy xcoordinate
	move.w	d6,d3		Copy ycoordinate
	sub.w	#97,d7		Find left edge
	sub.w	#97,d6		Find top edge
	sub.w	#31,d2		Find right edge
	sub.w	#31,d3		Find bottom edge
	move.w	#0,d0		Zero counter
	move.l	#pullers,a3	Attractors/repellers coordinates
	move.l	#coord,a2		Our coordinates
	move.w	2(a2),d1		Get Z coordinate
explpull2	cmp.w	4(a3),d1		Are we on the same level?
	bne	explpull3		No we can't explode it
	cmp.w	(a3),d7		Is it in range
	bgt	explpull3		No it isn't
	cmp.w	(a3),d2		Is it in range
	blt	explpull3		No it isn't
	cmp.w	2(a3),d6		Is it in range
	bgt	explpull3		No it isn't
	cmp.w	2(a3),d3		Is it in range
	blt	explpull3		No it isn't
	move.w	#50,4(a3)		Destroy it
explpull3	add.w	#1,d0		Move up counter
	add.w	#8,a3		Move on to next one
	cmp.w	nopull,d0		All checked yet?
	bne	explpull2		No check next one
	bra	explpullr		Return

pullme	cmp.w	#0,nopull		Any attractors/repellers
	beq	return		No, return
	cmp.w	#0,mode		Are we on two player mode?
	bgt	dblepull		Yes, pull both players
	cmp.w	#1,slide		Only half pull
	bne	return		Don't pull this time
dblepullr	move.l	#coord,a4		Get coordinates
	movem.w	(a4),d4-d7	Restore variables
	move.w	#0,d0		Zero counter
	move.l	#pullers,a3	Attractors/repellers coordinates
pullme2	add.w	#1,d0		Move up counter
	movem.w	(a3)+,d1-d4	Get coordinates
	cmp.w	d3,d5		On same level?
	beq	pullme3		Move towards attractor
pullme4	cmp.w	nopull,d0		All checked yet
	bne	pullme2		No check next one
	rts			Return

dblepull	cmp.w	#2,slide		Only half pull
	beq	dblepullr		Pull player 2
	cmp.w	#1,slide		Only half pull
	beq	dblepullr		Pull player 1
	rts			Return


pushme3	cmp.w	d7,d1		Move us right or left
	blt	pushr		Push right
	bra	pushl		Push left
pushme5	cmp.w	d6,d2		Move up or down
	blt	pushd		Push down
	bra	pushu		Push up
	bra	pullme4		Return

pullme3	cmp.w	#1,d4		Is it a repeller
	beq	pushme3		Gosub repeller routine
	cmp.w	d7,d1		Move us right or left
	bgt	pullr		Pull right
	blt	pulll		Pull left
pullme5	cmp.w	d6,d2		Move up or down
	bgt	pulld		Pull down
	blt	pullu		Pull up
	bra	pullme4		Return

pullr	add.w	#1,xmomentum	Increase xmomentum
	bra	pullme5		Return

pushr	add.w	#1,xmomentum	Increase xmomentum
	bra	pushme5		Return

pulll	sub.w	#1,xmomentum	Decrease xmomentum
	bra	pullme5		Return

pushl	sub.w	#1,xmomentum	Decrease xmomentum
	bra	pushme5		Return

pulld	add.w	#1,ymomentum	Increase ymomentum
	bra	pullme4		Return

pushd	add.w	#1,ymomentum	Increase ymomentum
	bra	pullme4		Return

pullu	sub.w	#1,ymomentum	Decrease ymomentum
	bra	pullme4		Return

pushu	sub.w	#1,ymomentum	Decrease ymomentum
	bra	pullme4		Return

nostick1	cmp.w	#0,d4		Is it at the left?
	beq	jamright		Yes, move it right
	cmp.w	#4,d4		Is it at the right?
	beq	jamleft		Yes, move it left
	bra	noprob1		No there aren't any problems

jamright	lsl	#5,d4		Convert X counter
	add.w	#2,d4		Move it right
	move.w	d4,(a5)+		Store X coordinate
	sub.w	#2,d4		Move it back
	lsr	#5,d4		Convert back to counter
	bra	nostick1r		Return

jamleft	lsl	#5,d4		Convert X counter
	sub.w	#2,d4		Move it left
	move.w	d4,(a5)+		Store X coordinate
	add.w	#2,d4		Move it back
	lsr	#5,d4		Convert back to counter
	bra	nostick1r		Return

nostick2	cmp.w	#0,d3		Is it at the top?
	beq	jamdown		Yes, move it down
	cmp.w	#4,d3		Is it at the bottom?
	beq	jamup		Yes, move it up
	bra	noprob2		No there aren't any problems

jamdown	lsl	#5,d3		Convert Y counter
	add.w	#2,d3		Move it down
	move.w	d3,(a5)+		Store Y coordinate
	sub.w	#2,d3		Move it back
	lsr	#5,d3		Convert back to counter
	bra	nostick2r		Return

jamup	lsl	#5,d3		Convert Y counter
	sub.w	#2,d3		Move it up
	move.w	d3,(a5)+		Store Y coordinate
	add.w	#2,d3		Move it back
	lsr	#5,d3		Convert back to counter
	bra	nostick2r		Return

convert2	add.w	#1,d5		Count number of moving blocks
	move.w	d6,(a5)+		Store block type
	cmp.w	#2,d6		Is it a left and right block?
	beq	nostick1		Yes, make sure it doesn't jam
noprob1	lsl	#5,d4		Convert X counter
	move.w	d4,(a5)+		Store X coordinate
	lsr	#5,d4		Convert back to counter
nostick1r	cmp.w	#3,d6		Is it an up and down block?
	beq	nostick2		Yes, make sure it doesn't jam
noprob2	lsl	#5,d3		Convert Y counter
	move.w	d3,(a5)+		Store Y coordinate
	lsr	#5,d3		Convert back to counter
nostick2r	move.w	d2,(a5)+		Store Z coordinate
	move.w	#0,(a5)+		Height starts at Zero
	move.w	#2,(a5)+		Store Timer/direction
	move.w	d0,(a5)+		Store block graphic
	sub.w	#1,a4		Move back block graphic
	move.b	#0,(a4)+		Wipe block of map table
	move.w	#0,(a5)+		Next visibility variable
	cmp.w	#5,d6		Is it a flashing block
	beq	getflash		Yes, find flash rate
	move.w	#5,(a5)+		Store flash rate
	bra	convert3		Return

ycount	move.w	#0,d4		Reset X counter
	add.w	#1,d3		Move up Y counter
	cmp.w	#5,d3		Move up z counter yet?
	beq	zcount		Yes we do
	bra	ycount2		Return

zcount	move.w	#0,d3		Reset Y counter
	add.w	#1,d2		Move up Z counter
	bra	ycount2		Return
	
title	move.w	#1,d0		Quartet tune to load
	BSR	loadtune		Load it in
	move.l	masks,a3		Address to load into
	sub.l	#32000,a3		Don't overwrite masks
	move.l	#pic3,a1		Address of file name
	move.l	#intpal,a2	Address to store palette
	bsr	PI1_load		Subroutine to load PI1 files
	sub.l	#32000,a3		Address to load picture into
	move.l	#pic2,a1		Address of file name
	move.l	#intpal,a2	Address to store palette
	bsr	PI1_load		Subroutine to load PI1 files
	sub.l	#32000,a3		Address to load picture into
	move.l	#pic1,a1		Address of file name
	move.l	#intpal,a2	Address to store palette
	bsr	PI1_load		Subroutine to load PI1 files
	sub.l	#32000,a3		Address to load picture into
	move.l	#pic4,a1		Address of file name
	move.l	#titpal,a2	Address to store palette
	bsr	PI1_load		Subroutine to load PI1 files
	move.l	#blockuse,a4	Address of block usage table	
	move.l	#0,(a4)+		Inform program that some
	move.w	#0,(a4)+		Blocks have been overwritten
	move.w	#1,backstar	Put stars behind picture
	move.w	#1,nomome		Disable controls
noskipt	bsr	checkjoy		Check joystick
	cmp.w	#0,fire		Wait for fire to be depressed
	bne	noskipt		Still waiting
	move.w	#-1,-(sp)		don't change mode
	bsr	clw2		Clear screen 2
	move.l	screen_2,-(sp)	change physical address
	move.l	screen_1,-(sp)	change logical address
	move.w	#5,-(sp)		change screen parameters
	trap	#14		Call XBIOS
	lea	12(sp),sp		Correct stack
	move.w	#37,-(sp)		Wait for Vsync
	trap	#14		Call XBIOS
	addq.l	#2,sp		Correct stack
	bsr	tipalt		Set colour palette
	bsr	playquart		Start quartet music
	move.w	#0,tcount		Reset title screen counter
title2	add.w	#1,tcount		Move up title screen counter
	move.l	masks,a3		Address of graphics
	sub.l	#128000,a3	Address of title screen
	bsr	quickcopy		Copy across title picture
	bsr	drawstars		Draw star field
	bsr	scrnswap		Show screen
	bsr	checkjoy		Check joystick
	cmp.w	#1,fire		Has fire been pressed
	beq	title3		Yes quit title screen
	cmp.w	#200,tcount	Do we do the instructions yet?
	bne	title2		No, keep drawing title screen
htble1	move.w	#0,tcount		Reset counter
	bsr	clw		Clear the screen
	bsr	scrnswap		Show screen
	bsr	inpalt		Get instruction palette
htble2	bsr	clw		Clear the screen
	bsr	showtable		Draw high score table
	bsr	checkjoy		Check joystick
	cmp.w	#1,fire		Has fire been pressed
	beq	title3		Yes quit title screen
	add.w	#1,tcount		Move up counter
	cmp.w	#50,tcount	Do we do the instructions yet?
	bne	htble2		No, keep drawing title screen
inst1	bsr	clw		Clear the screen
	bsr	scrnswap		Show screen
	bsr	inpalt		Get instruction palette
	move.w	#0,scrin		Allow for scroll in
	move.w	#0,tcount		Reset instruction counter
instl	move.l	masks,a3		Address of masks
	sub.l	#96000,a3		Get address of instructions
	move.l	#0,d0		Reset d0
	move.w	tcount,d0		Get position counter
	lsl.w	#2,d0		Multiply by 4
	add.w	tcount,d0		Add original
	lsl.l	#5,d0		Effectively multiply by 160
	add.l	d0,a3		Reposition pointer
	cmp.w	#32000,scrin	Are we still just starting?
	bne	stage1		Yes, just draw bottom
	cmp.l	#64000,d0		Are we ending now?
	bgt	stage2		Yes, just draw top
	bsr	quickcopy		Copy data across
stager	bsr	drawstars		Draw starfield
	bsr	scrnswap		Show screen
	bsr	checkjoy		Check joystick
	cmp.w	#1,fire		Has fire been pressed
	beq	title3		Yes quit title screen
	add.w	#1,tcount		Move up counter
	cmp.w	#600,tcount	Do we do the title screen yet?
	bne	instl		No, more instructions
	bsr	clw		Clear the screen
	bsr	scrnswap		show the screen
	bsr	tipalt		Title screen palette
	move.w	#0,tcount		Reset counter
	bra	title2		Go back to title screen

stage2	move.l	#stager,-(sp)	Fake a subroutine
	cmp.l	#96000,d0		Do we need to draw anything?
	beq	clw		No, we don't
	addq.l	#4,sp		Correct stack
	move.l	d0,d1		Make a copy of d0
	sub.l	#64000,d1		Work out surplus
	lsr.l	#2,d1		In long words
	move.l	#8000,d0		Amount we would normally draw
	sub.l	d1,d0		Minus surplus
	move.l	screen_1,a0	Destination address
	bsr	quick2		Draw what is needed
stage2l	move.l	#0,(a0)+		Copy across blank space
	sub.w	#1,d1		Decrease counter
	cmp.w	#0,d1		All done yet?
	bne	stage2l		No, copy some more
	bra	stager		Return

stage1	move.w	scrin,d0		Get position on screen
	add.w	#160,scrin	Move up scroll counter
	sub.w	#1,tcount		Don't move up picture yet
	move.l	screen_1,a0	Destination address
	move.l	#32000,d1		Find out amount of blank
	sub.l	d0,d1		Which needs to be drawn
	lsr.l	#2,d1		In long words
stage1l	move.l	#0,(a0)+		Copy across blank space
	sub.w	#1,d1		Decrease counter
	cmp.w	#0,d1		All done yet?
	bne	stage1l		No, copy some more
	move.l	#stager,-(sp)	Fake a subroutine
	lsr.w	#2,d0		Calculate amount to draw
	cmp.w	#0,d0		Is there anything to draw
	bne	quick2		Yes there is	
	rts			No, return

title3	bsr	checkjoy		Check joystick
	cmp.w	#0,fire		Wait for fire to be depressed
	bne	title3		Still waiting
	move.w	#0,nomome		Re-enable controls
	bsr	passbox		Bring up password box
	move.w	#0,backstar	Put stars back to normal
	bsr	checkpas		Check for correct passwords
title4	bsr	checkjoy		Check joystick
	cmp.w	#0,fire		Check fire button
	bne	title4		Wait for it to be depressed
	bsr	prompt		Bring up prompt
	move.w	#-1,-(sp)		don't change mode
	move.l	screen_1,-(sp)	change physical address
	move.l	screen_1,-(sp)	change logical address
	move.w	#5,-(sp)		change screen parameters
	trap	#14		Call XBIOS
	lea	12(sp),sp		Correct stack
	move.w	#37,-(sp)		Wait for Vsync
	trap	#14		Call XBIOS
	addq.l	#2,sp		Correct stack
	bsr	stopquart		Stop quartet music
	move.w	#0,lives		Give us our lives back
	move.l	#player2,a1	Address of player 2 variables
	move.w	#0,30(a1)		Give player 2 lives back
	move.l	#0,score		Reset score
	rts			Return

quickcopy	move.w	#8000,d0		Set counter
	move.l	screen_1,a0	Destination address
quick2	move.l	(a3)+,(a0)+	Copy across 4 bytes
	sub.w	#1,d0		Decrease counter
	cmp.w	#0,d0		All done yet?
	bne	quick2		No, copy some more
	rts			Return

loaddeg 	MOVE.L	screen_2,A3	Address to load into
	MOVE.L	#src_file,A1	Address of file name
	MOVE.L	#pic_mode,A2	Address to store mode/palette
	BSR	PI1_load		Subroutine to load PI1 files
	BSR	logo		Draw C&D logo
	move.l	screen_3,a3	Address to load into
	move.l	#cpanel,a1	Address of file name
	move.l	#pic_mode,a2	Address to store mode/palette
	bsr	PI1_load		Subroutine to load PI1 files
	RTS			Return

	**********************************
	*d6 contains block number to load*
	**********************************

loadbl1	MOVE.L	screen_2,A2	Address to load into
	clr.w	d5		Clear d5
	move.w	D6,D5		Make copy of block number
	divu.w	#10,d5		Get first digit
	mulu.w	#10,d5		first subtract from
	sub.w	d5,d6		total for second digit
	divu.w	#10,d5		Get first digit again
	add.w	#$30,d5		Convert into asci number
	move.l	#b1_file2,a0	Address of space for number
	move.b	d5,(a0)+		Store first digit in space
	add.w	#$30,d6		Convert second digit
	move.b	d6,(a0)+		Place second digit in space
	MOVE.L	#b1_file1,a1	Address of file name
	MOVE.w	#6400,d7		Number of bytes to read
	BSR	loaddata		Subroutine to load files
	RTS			Return

	*************************
	* Set the colour palette*
	*************************

palt	PEA	palette		Address of palette
	MOVE.W	#6,-(SP)		Set Screen Palette
	TRAP	#14		Call XBIOS
	ADDQ.L	#6,SP		Correct Stack
	RTS			Return

tipalt	PEA	titpalt		Address of palette
	move.w	#6,-(sp)		Set screen palette
	trap	#14		Call XBIOS
	addq.l	#6,sp		Correct stack
	rts			Return

inpalt	PEA	intpalt		Address of palette
	move.w	#6,-(sp)		Set screen palette
	trap	#14		Call XBIOS
	addq.l	#6,sp		Correct stack
	rts			Return

oldpalt	cmp.w	#1,old_rez	Medium or low palette
	beq	medpalt		Medium resolution
	PEA	lowcolour		Address of default palette
	move.w	#6,-(sp)		Set screen palette
	trap	#14		Call XBIOS
	addq.l	#6,sp		Correct stack
	rts			Return

medpalt	pea	medcolour		Address of default palette
	move.w	#6,-(sp)		Set screen palette
	trap	#14		Call XBIOS
	addq.l	#6,sp		Correct stack
	rts			Return

	**********************************************
	* PI1_load - Loads a Degas PI1 picture file. *
	* A3 - Holds address to load picture data    *
	* A1 - Holds address of file name            *
	* A2 - Holds address to put palette	     *
	**********************************************

PI1_load	MOVE.W	#0,-(SP)		Open for reading
	MOVE.L	A1,-(SP)		File Name to open
	MOVE.W	#$3D,-(SP)	Open file
	TRAP	#1		Call GEMDOS
	ADDQ.L	#8,SP		Correct Stack
	TST.L	D0		Check for errors
	BMI	error		Error Found?
	MOVE.W	D0,handle		Store file handle
	MOVE.L	A2,-(SP)		Where to put palette
	MOVE.L	#34,-(SP)		How many bytes to read
	MOVE.W	D0,-(SP)		Which file?
	MOVE.W	#$3F,-(SP)	Read
	TRAP	#1		Call GEMDOS
	LEA	12(SP),SP		Correct stack
	TST.L	D0		Check for errors
	BMI	error		Error Found?
	MOVE.L	A3,-(SP)		Where to put picture
	MOVE.L	#32000,-(SP)	How many bytes to read
	MOVE.W	handle,-(SP)	Which file?
	MOVE.W	#$3F,-(SP)	Read
	TRAP	#1		Call GEMDOS
	LEA	12(SP),SP		Correct stack
	TST.L	D0		Check for errors
	BMI	error		Error Found?
	move.w	handle,-(sp)	Handle number
	move.w	#$3e,-(sp)	Function number
	trap	#1		Call GEMDOS
	addq.l	#4,sp		Correct stack
	RTS			Return

loadquart	pea	env		Environment
	pea	com		Command line
	pea	fil		Filename
	move.w	#3,-(sp)		Load in data
	move.w	#$4b,-(sp)	Function number
	trap	#1		Call GEMDOS
	lea	16(sp),sp		Correct stack
	move.l	d0,a6		Address of replayer
	add.w	#8,a6		Move to start address
	move.l	(a6),a5		Address of replayer
	move.l	a5,replay		store address
	move.l	#voice,a1		address of file name
	move.l	samples,a2	Where to put data
	move.l	#61000,d7		Number of bytes to read
	bsr	loaddata		Load in data
	rts			Return

delength	sub.w	#6,d0		Load earlier song
	bra	loadtune		Now load it in

loadtune	cmp.w	#7,d0		Check MAX LENGTH
	bgt	delength		Its the wrong song
	move.w	d0,d6		Restore d0 into d6
	clr.w	d5		Clear d5
	move.w	D6,D5		Make copy of block number
	divu.w	#10,d5		Get first digit
	mulu.w	#10,d5		first subtract from
	sub.w	d5,d6		total for second digit
	divu.w	#10,d5		Get first digit again
	add.w	#$30,d5		Convert into asci number
	move.l	#tune2,a0		Address of space for number
	move.b	d5,(a0)+		Store first digit in space
	add.w	#$30,d6		Convert second digit
	move.b	d6,(a0)+		Place second digit in space
	MOVE.L	#tune,a1		Address of file name
	move.l	music,a2		Where to put data
	move.l	#8000,d7		Number of bytes to read
	bsr	loaddata		Load in data
	rts			Return

inverse	moveq.w	#0,d1		Clear d1
	move.b	(a0)+,d1		Get potential negative number
	move.w	#0,d0		And make it into
	sub.w	d1,d0		a real negative number
	bra	star3		Return

min360	sub.w	#360,d7		Subtract 360
	bra	draws2		Return

drawstars	move.w	#10,d3		Set Up counter
	move.l	#starcoord,a6	Address of star table
	move.l	intin,a3		Address of intin arrays
	move.l	ptsin,a4		Address of ptsin arrays
rep1	move.w	(a6),d7		Angle of stars trajectory
	cmp.w	#360,d7		Is it out of range
	bgt	min360		Yes, subtract 360
draws2	move.w	d7,d6		Make copy of angle
	move.l	sincos,a5		Address of trig table
	lsl.w	#2,d7		Multiply by 4 to
	add.w	d7,a5		Find sin of angle
	move.w	(a5),d7		from trig table
	move.w	2(a6),d4		Get distance from centre
	muls.w	d4,d7		and multiply by angle
	divs.w	#80,d7		divide by 80 for x coord
	add.w	#160,d7		add 160 for screen coordinate
	move.l	sincos,a5		Address of trig table
	lsl.w	#2,d6		Multiply by 4 and
	add.w	#2,d6		add 2 to find
	add.w	d6,a5		address in trig table
	move.w	(a5),d6		Get cos of angle
	muls.w	d4,d6		multiply by angle
	asr.w	#7,d6		divide by 128 for y coord
	add.w	#100,d6		add 100 for screen coordinate
	move.w	d7,(a4)		X coordinate
	move.w	d6,2(a4)		Y coordinate
	move.w	4(a6),d2		Get speed
	cmp.w	#20,d2		Check for distant stars
	blt	faint		Yes we've found one
	cmp.w	#1,backstar	Are stars as background
	bne	backs3		No they aren't
	dc.w	$a002		Is it blank already?
	cmp.w	#0,d0		Check for black
	bne	faint2		No, don't draw it
backs3	move.w	#1,(a3)		Draw pixel
	dc.w	$a001		Call Line A routine
faint2	move.w	4(a6),d2		Restore speed
	addq.w	#1,d2		Increase speed
	move.w	d2,4(a6)		Place back in table
	divu.w	#10,d2		Divide by 10
	addq.w	#1,d2		And add 1
	add.w	d2,d4		Increase distance from centre
	move.w	d4,2(a6)		re-enter distance
	cmp.w	#95,d4		Check distance from centre
	bgt	newstar		Is a new star required?
newstar2	add.w	#6,a6		Move to next star
	dbf	d3,rep1		Draw next star
	rts			Return	
	
faint	cmp.w	#10,d2		Check for very faint stars
	blt	vfaint		draw even darker
	cmp.w	#1,backstar	Are stars as background
	bne	backs		No they aren't	
	dc.w	$a002		Is it blank already?
	cmp.w	#0,d0		Check for black
	bne	faint2		No, don't draw it
backs	move.w	#2,(a3)		Colour grey
	dc.w	$a001		Call Line A routine
	bra	faint2		Return

vfaint	cmp.w	#1,backstar	Are stars as background
	bne	backs2		No they aren't
	dc.w	$a002		Is it blank already?
	cmp.w	#0,d0		Check for black
	bne	faint2		No, don't draw it
backs2	move.w	#3,(a3)		Colour dark grey
	dc.w	$a001		Call Line A routine
	bra	faint2		Return

newstar	move.w	#1,d7		Reset to minimum speed
	move.w	#17,-(sp)		Get random number
	trap	#14		Call GEMDOS
	addq.l	#2,sp		Correct stack
	moveq.l	#0,d0		Clear d0
	move.w	d1,d0		Get part of random number
	divu.w	#92,d0		Divide by 92 for angle
	move.w	d0,d6		Store in d6
	move.w	#17,-(sp)		Get random number
	trap	#14		Call GEMDOS
	addq.l	#2,sp		Correct stack
	moveq.l	#0,d0		Clear d0
	move.b	d1,d0		Get part of random number
	divu.w	#3,d0		Divide by 3 for distance
	move.w	d6,(a6)		re-enter angle
	move.w	d0,2(a6)		re-enter distance
	move.w	d7,4(a6)		and re-enter speed
	bra	newstar2		Return

stars	move.l	#trig,a1		address of file name
	move.l	sincos2,a2	Where to put data
	move.l	#1080,d7		Number of bytes to read
	bsr	loaddata		Load in data
	move.l	sincos2,a0	Address of trig table
	move.l	sincos,a1		Destination address
	move.w	#0,d7		Reset counter
star2	moveq.w	#0,d0		Clear d0
	move.b	(a0)+,d0		Get number out of table
	cmp.b	#255,d0		Is it negative
	beq	inverse		Yes it is
star3	move.w	d0,(a1)+		Store it back in table
	add.w	#1,d7		Move up counter
	cmp.w	#724,d7		Are we fully proccessed yet?
	bne	star2		No loop back around
	move.w	#0,d7		Reset counter
	move.l	#starcoord,a6	Address of star table
star4	move.w	#17,-(sp)		Get a random number
	trap	#14		Call GEMDOS
	addq.l	#2,sp		Correct stack
	moveq.l	#0,d0		Clear d0
	move.w	d1,d0		Get part of number
	lsr	#1,d0		Divide by 184 to produce
	divu.w	#92,d0		Number between 0 and 359
	addq.w	#1,d0		between 1 and 360
	move.w	d0,(a6)+		Store in coordinate table
	move.w	#17,-(sp)		Get a random number
	trap	#14		Call GEMDOS
	addq.l	#2,sp		Correct stack
	moveq.l	#0,d0		Clear d0
	move.b	d1,d0		Get part of number
	divu.w	#3,d0		Divide by 3 for number
	addq.w	#1,d0		between 1 and 86
	move.w	d0,(a6)+		Store in coordinate table
	move.w	#17,-(sp)		Get a random number
	trap	#14		Call GEMDOS
	addq.l	#2,sp		Correct stack
	moveq.l	#0,d0		Clear d0
	move.b	d1,d0		Get part of number
	divu.w	#9,d0		Divide by 9 for number
	addq.w	#1,d0		between 1 and 30
	move.w	d0,(a6)+		Store in coordinate table
	addq.w	#1,d7		Move up counter
	cmp.w	#11,d7		check for last star
	bne	star4		If not yet loop around
	rts			Return

playquart	move.l	replay,a5		Address of replayer
	move.l	#0,d0		Initialise replayer
	bsr	playmus		Run replayer
	move.l	#5,d0		Install replayer
	move.l	#0,d1		With code 5,0
	bsr	playmus		Run replayer
	move.l	#1,d0		Start music
	move.l	music,a0		Address of music
	move.l	samples,a1	Address of samples
	bsr	playmus		Run replayer
	rts			Return

stopquart	move.l	replay,a5		Address of replayer
	move.l	#2,d0		Stop music
	bsr	playmus		Run replayer
	rts			Return

quitquart	move.l	#3,d0		De-install player
	bsr	playmus		Run replayer
	rts			Return

playmus	move.l	#retmus,-(sp)	Address to return to
	move.l	a5,-(sp)		Address to gosub
	rts			Gosub it
retmus	rts			Return	

copymap	move.l	#map,a2		Where to put data
	move.l	#map3,a0		Where to get data from
	move.w	#0,d0		Reset counter
copymap2	move.w	(a0)+,(a2)+	Copy across word
	addq.w	#1,d0		Move up counter
	cmp.w	#275,d0		All copied yet?
	bne	copymap2		No, copy some more
	rts			Return

mapmap	move.l	#map4,a2		Where to put data
	move.l	#map3,a0		Where to get data from
	move.w	#0,d0		Reset counter
	bra	copymap2		Copy map across

pl2save	move.w	#1,d3		Set up timer
	bra	pl2saver		Return

savepos	movem.l	d0-d3/a0-a2,-(sp)	Preserve variables
	move.w	#0,d3		Reset timer
	cmp.w	#0,mode		Are we on two player mode?
	bgt	pl2save		Yes, save both positions
pl2saver	move.w	dynamite,odyna	Amount of dynamite
	move.w	jetpack,ojet	Number of jetpacks
	move.l	#map3,a2		Where to put data
	move.l	#map,a0		Where to get data from
	move.w	#0,d0		Reset counter
	bsr	copymap2		Copy map across
	move.l	#blcoord2,a2	Where to put data
	move.l	#blcoord,a0	Where to get data from
	move.w	#0,d0		Reset counter
	bsr	copymov2		Copy moving blocks across
	move.l	#pullersb,a2	Where to put data
	move.l	#pullers,a0	Where to get data from
	move.w	#0,d0		Reset counter
	bsr	copypull2		Copy attractors/repellers across
	move.w	paint,d0		Store amount of paint
	move.w	d0,opaint		In restart variable
	move.w	#1,restart	Set restart variable
	move.l	#coord,a0		Address of coordinates
	move.l	#excoord,a2	Address of saved coordinates
	move.l	(a0)+,(a2)+	Store first two coordinates
	move.l	(a0)+,(a2)+	Store last two coordinates
	cmp.w	#0,mode		Are we on two player mode?
	bgt	otherplay		Yes, save other players vars
oplayr	dbf	d3,pl2saver	Save second players pos
	movem.l	(sp)+,a0-a2/d0-d3	Restore variables
	rts			Return

otherplay	bsr	swapvars		Swap around variables
	bra	oplayr		Return

copymov	move.l	#blcoord,a2	Where to put data
	move.l	#blcoord2,a0	Where to get data from
	move.w	#0,d0		Reset counter
copymov2	move.l	(a0)+,(a2)+	Copy across long word
	addq.w	#1,d0		Move up counter
	cmp.w	#225,d0		All copied yet?
	bne	copymov2		No, copy some more
	rts			Return

copypull	move.l	#pullers,a2	Where to put data
	move.l	#pullersb,a0	Where to get data from
	move.w	#0,d0		Reset counter
copypull2	move.l	(a0)+,(a2)+	Copy across long word
	addq.w	#1,d0		Move up counter
	cmp.w	#50,d0		All copied yet?
	bne	copypull2		No, copy some more
	rts			Return

getstart	move.l	#coord,a2		Where to put data
	move.l	#startp,a0	Where to get data from
	cmp.w	#1,restart	Have we stood on a star?
	beq	scoord		Yes use exact coordinates
gettele	move.w	#0,d0		Clear d0
	move.b	(a0)+,d0		Get Xcoordinate
	lsl.w	#5,d0		Multiply by 32
	sub.w	#96,d0		And subtract 96
	muls.w	#-1,d0		Coordinates are stored reversed
	move.w	d0,6(a2)		To find coordinate to store
	move.w	#0,d0		Clear d0
	move.b	(a0)+,d0		Get Ycoordinate
	lsl.w	#5,d0		Multiply by 32
	sub.w	#96,d0		And subtract 96
	muls.w	#-1,d0		Coordinates are stored reversed
	move.w	d0,4(a2)		To find coordinate to store
	move.w	#0,d0		Clear d0
	move.b	(a0)+,d0		Get Zcoordinate
	add.w	#2,d0		Allow for space at top
	move.w	d0,2(a2)		Store coordinate
	move.w	#0,(a2)		Height is always zero
	move.w	#0,paint		Zero amount of paint
	rts

scoord	move.w	opaint,d0		How much paint do we have?
	move.w	d0,paint		Store in paint variable
	move.l	#excoord,a0	Address of exact coordinates
	move.l	(a0)+,(a2)+	Store first two coordinates
	move.l	(a0)+,(a2)+	Store other two coordinates
	rts			Return

loadtel	move.w	#0,d1		Clear d1
	move.b	numtel,d1		Number of teleporters
	move.l	#lbuffer,a5	Address of load buffer
loadtel2	move.l	#tmap,a4		Address of teleporter map	
	bsr	loadbyte		Load in one byte
	move.w	#0,d2		Clear d2
	move.b	(a5),d2		Get loaded information
	sub.w	#1,d2		Convert to address
	mulu.w	#3,d2		3 pieces of data per square
	add.w	d2,a4		Move up map pointer
	bsr	loadbyte		Load in next byte
	move.w	#0,d2		Clear d2
	move.b	(a5),d2		Get loaded information
	sub.w	#1,d2		Convert to address
	mulu.w	#15,d2		In rows
	add.w	d2,a4		Move up map pointer
	bsr	loadbyte		Load in level of teleporter
	move.w	#0,d2		Clear d2
	move.b	(a5),d2		Get loaded infromation
	add.w	#2,d2		Convert to address
	mulu.w	#75,d2		In levels
	add.w	d2,a4		Move up map pointer
	move.l	a4,-(sp)		Load in data at pointer
	move.l	#3,-(sp)		3 bytes of data
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	sub.w	#1,d1		Decrease counter
	cmp.w	#0,d1		All teleport information loaded?
	bne	loadtel2		No load next teleporter
	bra	loadtelr		Return

loadbyte	move.l	a5,-(sp)		Address to load into
	move.l	#1,-(sp)		How many bytes to read
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	rts			Return

loadps	move.w	#0,-(sp)		open for reading
	pea	passw		address of file name
	move.w	#$3d,-(sp)	open file
	trap	#1		Call GEMDOS
	addq.l	#8,sp		Correct stack
	tst.l	d0		Check for errors
	bmi	error		Error found?
	move.w	d0,handle		Store file handle
	move.l	#passinf,a5	Password table address
	move.l	#numlev,-(sp)	How many levels how there?
	move.l	#1,-(sp)		Read just one byte
	move.w	d0,-(sp)		File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	move.b	numlev,d5		Store number of levels counter
loadps3	move.l	#bbuffer,-(sp)	Find length of password
	move.l	#1,-(sp)		Read just one byte
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	move.b	bbuffer,d7	Set Password counter
	move.b	#0,d6		Reset counter
loadps2	move.l	#bbuffer,-(sp)	Load in 1 letter
	move.l	#1,-(sp)		Read just one byte
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	move.b	bbuffer,d0	Get letter
	add.b	#3,d0		Decode
	move.b	d0,(a5)+		Store letter
	add.b	#1,d6		Move up counter
	cmp.b	d6,d7		All loaded yet?
	bne	loadps2		No load next letter
loadps5	cmp.b	#12,d6		Do we need any blanks?
	beq	loadps4		No we don't	
	move.b	#0,(a5)+		Fill in blank space
	add.b	#1,d6		Move up counter
	bra	loadps5		loop around
loadps4	sub.b	#1,d5		Decrease numlev counter
	cmp.b	#0,d5		Any more levels
	bne	loadps3		Yes, load next password
	move.l	#passinf2,a5	Password table address
	move.l	#numlev2,-(sp)	How many levels how there?
	move.l	#1,-(sp)		Read just one byte
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	move.b	numlev2,d5	Store number of levels counter
loadps23	move.l	#bbuffer,-(sp)	Find length of password
	move.l	#1,-(sp)		Read just one byte
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	move.b	bbuffer,d7	Set Password counter
	cmp.b	#0,d7		Is there a password?
	beq	dudps		No, load dud password
dudps2	move.b	#0,d6		Reset counter
loadps22	move.l	#bbuffer,-(sp)	Load in 1 letter
	move.l	#1,-(sp)		Read just one byte
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	move.b	bbuffer,d0	Get letter
	add.b	#3,d0		Decode
	move.b	d0,(a5)+		Store letter
	add.b	#1,d6		Move up counter
	cmp.b	d6,d7		All loaded yet?
	bne	loadps22		No load next letter
loadps25	cmp.b	#12,d6		Do we need any blanks?
	beq	loadps24		No we don't	
	move.b	#0,(a5)+		Fill in blank space
	add.b	#1,d6		Move up counter
	bra	loadps25		loop around
loadps24	sub.b	#1,d5		Decrease numlev counter
	cmp.b	#0,d5		Any more levels
	bne	loadps23		Yes, load next password
	move.l	#passinf3,a5	Password table address
	move.l	#numlev3,-(sp)	How many levels how there?
	move.l	#1,-(sp)		Read just one byte
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	move.b	numlev3,d5	Store number of levels counter
loadps33	move.l	#bbuffer,-(sp)	Find length of password
	move.l	#1,-(sp)		Read just one byte
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	move.b	bbuffer,d7	Set Password counter
	cmp.b	#0,d7		Is there a password
	beq	dudps3		No load dud password
dudps4	move.b	#0,d6		Reset counter
loadps32	move.l	#bbuffer,-(sp)	Load in 1 letter
	move.l	#1,-(sp)		Read just one byte
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	move.b	bbuffer,d0	Get letter
	add.b	#3,d0		Decode
	move.b	d0,(a5)+		Store letter
	add.b	#1,d6		Move up counter
	cmp.b	d6,d7		All loaded yet?
	bne	loadps32		No load next letter
loadps35	cmp.b	#12,d6		Do we need any blanks?
	beq	loadps34		No we don't	
	move.b	#0,(a5)+		Fill in blank space
	add.b	#1,d6		Move up counter
	bra	loadps35		loop around
loadps34	sub.b	#1,d5		Decrease numlev counter
	cmp.b	#0,d5		Any more levels
	bne	loadps33		Yes, load next password
	move.w	handle,-(sp)	handle number
	move.w	#$3e,-(sp)	function number
	trap	#1		Call GEMDOS
	addq.l	#4,sp		Correct stack
	rts			Return

dudps	move.b	#1,d7		Load dud password
	bra	dudps2		Return

dudps3	move.b	#1,d7		Load dud password
	bra	dudps4		Return

resrvepl2	add.w	#6,d0		Save 3 spaces
	move.w	#255,(a4)+	Reserve space 1
	move.w	#255,(a4)+	Reserve space 2
	move.w	#255,(a4)+	Reserve space 3
	bra	noneed2		Return

noneed	move.l	#map3,a6		Address of map data
	move.w	#0,d7		Zero counter
	move.l	#blockuse,a4	Table of block usage
	move.w	#0,d0		Zero verification counter
	cmp.w	#0,mode		Are we on two player mode?
	bgt	resrvepl2		Reserve space for 2player graphics
noneed2	move.b	(a4),d6		Block to verify
noneed3	cmp.b	(a6)+,d6		Is it used?
	beq	noneed4		Yes it is
	add.w	#1,d7		Move up counter
	cmp.w	#550,d7		All checked yet?
	bne	noneed3		No check more spaces
	move.b	#0,(a4)		It isn't used wipe from table
noneed4	addq.l	#1,a4		Move up table
	add.w	#1,d0		Move up counter 2
	move.w	#0,d7		Zero first counter
	move.l	#map3,a6		Address of map data
	cmp.w	#25,d0		Any more slots to check?
	bne	noneed2		Yes, check next slot
	rts			Return

getflash	movem.l	d0-d7/a0-a4,-(sp)	Be pesimistic
	move.l	#bbuffer,-(sp)	Find flash rate
	move.l	#1,-(sp)		How many bytes to read
	move.w	oldfile,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	move.w	#0,d0		Zero d0
	move.b	bbuffer,d0	Get flash rate
	move.w	d0,(a5)+		Store flash rate
	movem.l	(sp)+,d0-d7/a0-a4	Restore registers
	bra	convert3		Return

loadlev	move.w	mode,d6		Get mode
	lsl.w	#2,d6		Multiply by 4
	move.l	#extend,a0	Get possible extensions
	add.w	d6,a0		Find required extension
	move.l	#ext,a1		Space for extension
	move.b	(a0)+,d6		Get extension
	move.b	d6,(a1)+		Type of file to load
	move.b	(a0)+,d6		Get extension
	move.b	d6,(a1)+		Type of file to load
	move.b	(a0)+,d6		Get extension
	move.b	d6,(a1)+		Type of file to load
	move.b	(a0)+,d6		Get extension
	move.b	d6,(a1)+		Type of file to load
	move.w	#0,-(sp)		open for reading
	move.w	clevel,d6		Restore level to load into d6
	clr.w	d5		Clear d5
	move.w	D6,D5		Make copy of block number
	divu.w	#10,d5		Get first digit
	mulu.w	#10,d5		first subtract from
	sub.w	d5,d6		total for second digit
	divu.w	#10,d5		Get first digit again
	add.w	#$30,d5		Convert into asci number
	move.l	#level2,a0	Address of space for number
	move.b	d5,(a0)+		Store first digit in space
	add.w	#$30,d6		Convert second digit
	move.b	d6,(a0)+		Place second digit in space
	MOVE.L	#level1,-(sp)	Address of file name
	bsr	wipeall		Wipe all registers
	move.w	#$3d,-(sp)	open file
	trap	#1	 	Call GEMDOS
	addq.l	#8,sp		Correct stack
	tst.l	d0		Check for errors
	bmi	error		Error found?
	move.w	d0,handle 	Store file handle
	move.l	#0,startp		Reset starting coordinates
	move.w	#0,opaint		Reset starting paint
	move.w	#0,restart	We haven't stood on restart block
	move.l	#startp,-(sp)	Keep record of start pos
	move.l	#3,-(sp)		How many bytes to read
	move.w	d0,-(sp)		File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	cmp.w	#0,mode		Are we on two player mode?
	bgt	scndstart		Yes, load in other start point
scnd2	move.l	#map3,a2		Where to put data
	add.w	#75,a2		Remember blank space at top
	move.l	a2,-(sp)		Load in map data
	move.l	#375,-(sp)	How many bytes to read
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	bsr	mapmap		Make copy of map
	move.l	#map2,a2		Moving block data
	add.w	#75,a2		Remember blank space at top
	move.l	a2,-(sp)		Load in map data
	move.l	#375,-(sp)	How many bytes to read
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	tst.l	d0		Check for errors
	bmi	error		Error found?
	move.l	#numtel,-(sp)	How many teleporters?
	move.l	#1,-(sp)		Only 1 bytes worth
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	tst.l	d0		Check for errors
	bmi	error		Error found?
	cmp.b	#0,numtel		Any teleporter on this level
	bne	loadtel		Yes load in details
loadtelr	move.w	handle,oldfile	Keep record of old handle
	move.l	#nodud,-(sp)	Address to store duds?
	move.l	#6,-(sp)		6 bytes worth
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	bsr	noneed		Get rid of unneeded blocks
	move.w	#0,d7		Zero counter
	move.l	#map3,a6		Address of map data
	move.w	#4,d6		Make purple block automatic
	addq.l	#1,a6		Move up map pointer
	bra	autopurp		Goto routine
loadlev2	clr.w	d6		Clear d6
	move.b	(A6)+,d6		Get block off map
autopurp	move.l	a6,-(sp)		Store a6
	move.w	d6,bltype		Store block type
	cmp.w	#0,d6		Is it a block
	beq	loadlev3		No get next one
	move.l	#blockpos,a5	Address of block position data
	move.l	#blockuse,a4	Address of block usage data
	move.w	#0,d0		Zero counter
looplev1	move.w	(a4)+,d5		Check block space
	cmp.w	d5,d6		Is current block already defined
	beq	loadlev3		Yes get next block
	add.w	#1,d0		Move up counter
	cmp.w	#25,d0		Have all slots been checked
	bne	looplev1		No check next one
	move.l	#blockuse,a4	Address of block usage data
	moveq.l	#0,d0		Zero counter
looplev2	add.w	#1,d0		Move up counter
	move.w	(a4)+,d5		Find first free space
	cmp.w	#0,d5		Is space free
	bne	looplev2		No look in next space

	sub.w	#2,a4		Move back to last space
	move.w	d6,(a4)		Store current block in space
	sub.w	#1,d6		Blocks count from zero
	mulu.w	#4,d6		Convert block to long word
	add.w	d6,a5		To find block position
	move.w	d7,-(sp)		Store counter
	move.w	d0,d7		Reset counter
	move.l	#0,d0		Blank d0
looplev5	add.l	#50000,d0		Find address offset
	sub.w	#1,d7		Decriminate counter
	cmp.w	#0,d7		At zero yet
	bne	looplev5		No add some more
	move.l	d0,(a5)		Store slot containing block data
	divu.w	#4,d6		Convert back to block number
	add.w	#1,d6		Counting from one
	move.l	masks,a6		Address of mask data
	sub.l	d0,a6		Find address of current block no
	bsr	shftblk		Load in block data
	move.w	(sp)+,d7		Restore counter
	cmp.w	#1,bltype		Is it a blue trampoline?
	beq	autotramp		Yes, load in purple one also
loadlev3	add.w	#1,d7		Move up counter
	move.l	(sp)+,a6		Restore a6
	cmp.w	#550,d7		Has entire level been checked
	bne	loadlev2		No load some more
	rts			Return

autotramp	move.l	(sp)+,a6		Restore a6
	move.w	#2,d6		Purple trampoline
	bra	autopurp		Load it in
	
scndstart	move.l	#player2,a0	Keep record of start pos
	add.l	#22,a0		Find space to store start
	move.l	a0,-(sp)		Address to load into
	move.l	#3,-(sp)		How many bytes to read
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	cmp.w	#2,mode		On competative mode
	bne	scnd2		No, Return
	move.l	#timelmt,-(sp)	Find time limit
	move.l	#1,-(sp)		How many bytes to read
	move.w	handle,-(sp)	File to load
	move.w	#$3f,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	bra	scnd2		Return

loaddata	MOVE.W	#0,-(sp)		open for reading
	MOVE.L	a1,-(sp)		address of file name
	move.w	#$3D,-(sp)	open file
	trap	#1		Call GEMDOS
	addq.l	#8,sp		Correct stack
	tst.l	d0		Check for errors
	bmi	error		Error found?
	move.w	d0,handle		Store file handle
	move.l	a2,-(sp)		Where to put data
	move.l	d7,-(sp)		How many bytes to read
	move.w	d0,-(sp)		File to load
	move.W	#$3F,-(sp)	Read in data
	trap	#1		Call GEMDOS
	lea	12(sp),sp		Correct stack
	TST.L	d0		Check for errors
	bmi	error		error found?
	move.w	handle,-(sp)	handle number
	move.w	#$3e,-(sp)	function number
	trap	#1		Call GEMDOS
	addq.l	#4,sp		Correct stack
	rts			Return

	*********************
	*Print Error Message*
	*********************

error	PEA	err1		Message to print
	MOVE.W	#9,-(SP)		Print String
	TRAP	#1		Call Gemdos
	ADDQ.L	#6,SP		Correct stack
	MOVE.W	#1,-(SP)		Get a keypress
	TRAP	#1		Call GemDos
	ADDQ.L	#2,SP		Correct Stack
	BSR	end		Change back resolution
	CLR.W	-(SP)		End program
	TRAP	#1		Correct stack

	*********************************
	*Preshifts graphics in screen_2 *
	*Using coordinates at 'position'*
	*********************************

shift	MOVE.L	#$03030303,d7	Logical Operation to use
	MOVE.L	screen_2,a0	Address of source screen
	MOVE.L	shiftbuf,a1	Destination screen

	move.w	#133,a5		Masks first
	MOVE.L	masks,a3		Final destination
	move.l	#position,a2	Address of coordinates
	move.w	#16,shifts	All 16 shifts
	move.w	#1,d6		Reset counter
	MOVE.L	#layout,a4	Address to put layout data
	move.w	#1,laytest	Store layout data
	move.w	#1,mask		It is mask data
	BSR	shift1		Convert graphics

	MOVE.W	#0,a5		Top Row
	move.l	iconmask,a3	Final destination
	move.l	#iconpos1,a2	Address of coordinates
	move.w	#1,shifts		Only 1 shift
	move.w	#1,d6		Reset counter
	move.l	#iconlay,a4	Address to put layout data
	bsr	shift1		convert graphics

	move.w	#41,a5		Next line down
	move.l	icons1,a3		Final destinaton
	move.l	#iconpos2,a2	Address of coordinates
	move.w	#1,shifts		Only 1 shift
	move.w	#1,d6		Reset counter
	move.l	#iconlay1,a4	Address to put layout data
	move.w	#0,mask		Not masks any more
	bsr	shift1		convert graphics

	move.w	#82,a5		Next line down
	move.l	icons2,a3		Final destination
	move.l	#iconpos2,a2	Address of coordinates
	move.w	#1,shifts		Only 1 shift
	move.w	#1,d6		Reset counter
	move.w	#0,laytest	No need to store layout data
	bsr	shift1		Convert graphics

	move.w	#123,a5		Last line of icons
	move.l	icons3,a3		Final destination
	move.l	#iconpos3,a2	Address of coordinates
	move.w	#1,shifts		Only 1 shift
	move.w	#1,d6		Reset counter
	move.l	#iconlay2,a4	Address to store layout data
	move.w	#1,laytest	Store layout data
	bsr	shift1		Convert graphics
	rts			return

shftblk	BSR	loadbl1		Load in block graphics
shftblk2	MOVE.L	screen_2,a0	Address of source screen
	MOVE.L	shiftbuf,a1	Destination screen
	move.l	#$03030303,d7	Logical operation
	move.w	#0,a5		Top line
	move.l	a6,a3		Final destination
	move.l	#position,a2	Address of coordinates
	move.w	#16,shifts	All 16 shifts
	move.w	#1,d6		Reset counter
	move.w	#0,laytest	no need for layout data
	move.w	#0,mask		no masks
	bsr	shift1		convert graphics
	RTS			Return

shftmsk2	MOVE.L	screen_2,a0	Address of source screen
	MOVE.L	shiftbuf,a1	Destination screen
	move.l	#$03030303,d7	Logical operation
	move.w	#0,a5		Top line
	move.l	a6,a3		Final destination
	move.l	#position,a2	Address of coordinates
	move.w	#16,shifts	All 16 shifts
	move.w	#1,d6		Reset counter
	move.w	#0,laytest	no need for layout data
	move.w	#1,mask		it is a mask
	bsr	shift1		convert graphics
	RTS			Return

get2pldat	move.l	screen_2,a2	Address to load into
	move.l	#playermsk,a1	Address of file name
	move.w	#6400,d7		Number of bytes to read
	bsr	loaddata		Subroutine to load files
	move.l	masks,a6		Address of mask data
	sub.l	#50000,a6		Address offset
	bsr	shftmsk2		Shift player graphics
	move.l	screen_2,a2	Address to load into
	move.l	#player1,a1	Address of file name
	move.w	#6400,d7		Number of bytes to read
	bsr	loaddata		Subroutine to load files
	move.l	masks,a6		Address of mask data
	sub.l	#100000,a6	Address offset
	bsr	shftblk2		Shift player graphics
	move.l	screen_2,a2	Address to load into
	move.l	#player_2,a1	Address of file name
	move.w	#6400,d7		Number of bytes to read
	bsr	loaddata		Subroutine to load files
	move.l	masks,a6		Address of mask data
	sub.l	#150000,a6	Address offset
	bsr	shftblk2		Shift player graphics
	bra	levwon		Return

shift1	MOVE.W	(a2)+,d0		Left From
	MOVE.W	(a2)+,d1		Top From
	MOVE.W	a5,d2		Find Sprite No
	ADD.W	d2,d1		Add on to height
	MOVE.W	(a2)+,d4		Width
	MOVE.W	(a2)+,d5		Height
	MOVE.W	#0,d2		Left To
	MOVE.W	#0,d3		Top To
shift2	BSR	blit		Copy across graphic
	BSR	store		store graphic
	ADDQ.W	#2,d2		Shift graphics
	cmp.w	#1,shifts		Only 1 shift needed?
	beq	endshift		If so quit now
	CMP.B	#16,d2		Check for end
	BNE	shift2		If not loop back around
endshift	ADDQ.W	#1,d6		Next sprite
	CMP.W	#16,d6		Check for end
	BNE	shift1		Copy next sprite across
	RTS			Return

	*********************************
	*Stores graphics made with shift*
	*********************************

store	MOVEM.L	d0-d7/a0-a2,-(SP)	Preserve registers
	add.w	d4,d2		Add On width to left edge
	bsr	roundup		Don't cut off right edge
	divu.w	#16,d2		In squares
	move.w	d5,d3		Height
	move.l	shiftbuf,a0	Source Address
	move.l	a3,a1		Destination Address
	BSR	blcopy		Store in memory
	BSR	cltop		Clear screen
	move.l	a1,a3		Move On Pointer
	MOVEM.L	(SP)+,d0-d7/a0-a2	Restore registers
	RTS			Return

roundup	move.w	d2,d7		Store it for check at end
	divu.w	#16,d2		Round number down to
	mulu.w	#16,d2		nearest 16
	cmp.w	d7,d2		Check if needs altering
	bne	addword		if so add 16
	rts			return

addword	add.w	#16,d2		Add on 16
	rts			Return

lay_out	move.l	a3,(a4)+		Store graphics address
	move.w	d2,(a4)+		Width
	move.w	d3,(a4)+		Height
	bra	lay1		Return

blcopy	cmp.w	#1,laytest	Is layout data required?
	beq	lay_out		Store layout data
lay1	move.w	d2,d7		Set up counter
	move.w	#0,d6		Measure Width
	move.w	a5,d1		Check for masks
copy1	move.l	(a0)+,d4		Copy across 16 pixels
	cmp.w	#1,mask		Check for masks
	beq	maskit1		If so invert
rt1	move.l	d4,(a1)+		Place in buffer
	move.l	(a0)+,d4		All 4 bitplanes
	cmp.w	#1,mask		Check for masks
	beq	maskit2		If so invert
rt2	move.l	d4,(a1)+		Place in buffer
	addq.w	#8,d6		Count Bytes per line
	sub.w	#1,d7		Decriminate counter
	cmp.w	#0,d7		Check for full width
	bne	copy1		If not reached then loop 
	move.w	d2,d7		Reset counter
	sub.w	d6,a0		Go to start of line
	move.w	#0,d6		Reset width counter
	add.w	#160,a0		Move down to next line
	sub.w	#1,d3		Decrimanate height counter
	cmp.w	#0,d3		Check if another line needed
	bne	copy1		If so then loop back around
	rts			Return

maskit1	not.l	d4		Inverse
	bra	rt1		Return

maskit2	not.l	d4		Inverse
	bra	rt2		Return

get	MOVE.W	#1,-(SP)		Function wait key
	TRAP	#1		Call GemDos
	ADDQ.L	#2,SP		Correct Stack
	RTS			Return

	***********************************
	*Joystick handling routines	    *
	*Cover initilisation, use and exit*
	***********************************

initjoy	move.w	#34,-(sp)		Function Kbdvbase
	trap	#14		Call XBIOS
	addq.l	#2,sp		Correct stack
	move.l	d0,a3		address of system vectors
	move.l	#install_j,-(sp)	Initialise joystick handler
	move.w	#38,-(sp)		In supervisor mode	
	trap	#14		Call XBIOS
	addq.l	#6,sp		Correct stack
	move.w	#$15,-(sp)	Turn off automatic packets
	move.w	#4,-(sp)		Message to IKBD
	move.w	#3,-(sp)		Functon Bconout
	trap	#13		Call BIOS
	addq.l	#6,sp		Correct stack
	rts

checkp2	move.w	j2_event,d3	Store Joystick event
	beq	return		Has it arrived yet?
	bra	checp2r		Return

checkjoy	move.w	#0,fire		Fire button not pressed
	move.w	#$16,-(sp)	Request joystick packet
	move.w	#4,-(sp)		from IKBD
	move.w	#3,-(sp)		Function Bconout
	trap	#13		Call BIOS
	addq.l	#6,sp		Correct stack
	cmp.w	#2,plyno		Is it player two?
	beq	checkp2		Yes, check other joystick
	move.w	j_event,d3	Store Joystick event
	beq	return		Has it arrived yet?
checp2r	cmp.w	#1,nomome		Do we need momentum
	beq	not_right		No, we don't
	btst	#0,d3		Check up
	beq	not_up		None found?
	*Joystick had been pressed up
	add.w	#1,ymomentum	Move player Up
not_up	btst	#1,d3		Check down
	beq	not_down		None found?
	*Joystick had been pressed down
	sub.w	#1,ymomentum	Move player down
not_down	btst	#2,d3		Check left
	beq	not_left		None found?
	*Joystick had been pressed left
	add.w	#1,xmomentum	Move player left
not_left	btst	#3,d3		Check right
	beq	not_right		None found?
	*Joystick had been pressed right
	sub.w	#1,xmomentum	Move player right
not_right	btst	#7,d3		Check fire
	beq	not_fire		None found
	*Joystick fire button has been pressed
	move.w	#1,fire		Store fire status
not_fire	rts			Return

endjoy	move.w	#$8,-(sp)		Turn automatic packets back on
	move.w	#4,-(sp)		Message to IKBD
	move.w	#3,-(sp)		Function Bconout
	trap	#13		Call BIOS
	addq.l	#6,sp		Correct stack
	move.l	#remove_j,-(sp)	remove joystick handler
	move.w	#38,-(sp)		In supervisor mode
	trap	#14		Call XBIOS
	addq.l	#6,sp		Correct stack
	rts			Return

install_j	lea	24(a3),a3		move to joystick vector
	move.l	a3,j_vector	store the address of the vector
	move.l	(a3),oldpacket	store the old vector
	move.l	#j_handler,(a3)	patch in the new one
	rts			return

remove_j	move.l	j_vector,a3	move to joystick vector
	move.l	oldpacket,(a3)	put the old joystick handler back
	rts			return
	
j_handler	move.w	d0,-(sp)		Save original d0
	clr.w	d0		Clear d0
	move.b	1(a0),d0		Store packet in d0
	move.w	d0,j_event	Store in j_event
	clr.w	d0		Clear d0
	move.b	(a0),d0		Store packet in d0
	move.w	d0,j2_event	store in j2_event
	move.w	(sp)+,d0		Restore d0
	add.l	#1,myclock	Move up my clock counter
	rts			Return

*************************************************************************
* BLIT - Perform a blit from screen to screen. Uses, but preserves	  *
* the following registers...					  *
* A0 - Address of screen FROM.				  *
* A1 - Address of screen TO.					  *
* D0 - Left FROM						  *
* D1 - Top FROM				   		  *
* D2 - Left TO						  *
* D3 - Top TO						  *
* D4 - WIDTH						  *
* D5 - HEIGHT					            *
* D6 - unused						  *
* D7 - Logical Operation 					  *
*************************************************************************

blit:	MOVEM.L	D0-D7/A0-A6,-(SP)	Preserve Registers
	LEA	bitblt(PC),A6	Address of blit table
	MOVE.L	A0,18(A6)		Store 'From' address
	MOVE.L	A1,32(A6)		Store 'To' Address
	MOVE.W	D0,14(A6)		Store Left from position
	MOVE.W	D1,16(A6)		Store Top from position
	MOVE.W	D2,28(A6)		Store Left To position
	MOVE.W	D3,30(A6)		Store Top To position
	MOVE.W	D4,0(A6)		Store width. 
	MOVE.W	D5,2(A6)		Store height.
	MOVE.W	#4,4(A6)		Set up Blit variables
	MOVE.W	#8,22(A6)		for Low resolution
	MOVE.W	#8,36(A6)		Place parameter in blit table
	MOVE.L	#0,42(A6)		Set up additional variables
	MOVE.B	D7,10(A6)		Logical Operation
	MOVE.W	#0,6(A6)		More variables
	MOVE.W	#0,8(A6)		More variables
	DC.W	$A007		Do the Blit!
	MOVEM.L	(SP)+,D0-D7/A0-A6	Restore registers
	RTS			return

	************
	*Blit Table*
	************

	EVEN
bitblt	DC.W	0		Width
	DC.W	0		Height
	DC.W	0		No. Planes
	DC.W	0		fg_col
	DC.W	0		bg_col
	DC.B	0,0,0,0		log. ops
	DC.W	0		left source x
	DC.W	0		top source y
	DC.L	0		Source screen top address
	DC.W	8		word in line (8=low 4=med)
	DC.W	160		160 for med/low
	DC.W	2
	DC.W	0		left dest x
	DC.W	0		top dest y
	DC.L	0		dest screen top address
	DC.W	8		word in line
	DC.W	160		line in plane
	DC.W	2
	DC.L	0		Pattern Address
	DC.W	0
	DC.W	0
	DC.W	0
	DS.B	30

	*******************
	*Program Variables*
	*******************

	EVEN
excoord	DS.L	2		Restart position
jetp	DC.W	0		Are we using a jetpack?
blowdyna	DC.W	0		Is the dynamite exploding?
sparevar	DC.L	0		Spare Variable
blinkc	DC.W	0		Blink counter
somerslt	DC.W	0		Somersault counter
opaint	DC.W	0		Amount of paint left at resave
startp	DS.B	4		Space for starting coords
tblock	DC.W	0		Are we on a trampoline?
player	DC.W	0		Are we drawing a player?
lives	DC.W	0		Amount of lives remaining
dynamite	DC.W	3		Amount of dynamite
jetpack	DC.W	3		Number of jet packs
odyna	DC.W	3		Original amount of dynamite
ojet	DC.W	3		Original amount of jetpacks
paint	DC.W	0		Amount of paint remaining
coord	DS.W	4		Space for coordinates
spare	DS.W	4		Space to store coordinates
jump	DC.W	0		are we jumping?
fall	DC.W	0		are we falling?
height	DC.W	0		Height from block below
goingup	DS.W	1		Are we going upwards
fire	DC.W	0		store fire button status
death	DC.W	0		Death status
xmomentum	DC.W	1		X momentum
ymomentum	DC.W	1		Y momentum
crumble	DS.B	26		Data for blocks which will crumble
movcrmb	DS.B	50		Data for moving crumble blocks
ddelay	DC.W	0		Delay for when player dies
crumrate	DC.W	1		Block  Crumble Rate

	EVEN			Prevent Address Errors
player2	DS.L	38		Space for player2's variables

	EVEN
restart	DC.W	0		Have we stood on a restarter?
blckno	DC.W	0		Which block we're looking at
tcount	DC.W	0		Title screen counter
score	DC.L	0		Our score so far
pullers	DS.W	100		Space for attractor/repeller data
pullersb	DS.W	100		Memory for attractors/repellers
nopull	DC.W	0		No of attractors/repellers
range	DS.B	9		Matrix for testing arrays range
	EVEN			Prevent address errors
fontlay	DC.B	"A","B","C","D","E","F","G","H"
	DC.B	"Q","R","S","T","U","V","W","X"
	DC.B	"7","8","9","0",":",".",",","?"
	DC.B	"I","J","K","L","M","N","O","P"
	DC.B	"Y","Z","1","2","3","4","5","6"
	DC.B	"!","-","=","%","œ","<",">","c"
	EVEN			Prevent address errors
lbuffer	DC.W	0		Buffer to load data into
sectbuf	DS.B	512		Space for sector to be stored
numtel	DC.W	0		Number of teleporters
backstar	DC.W	0		Do stars go in front or behind?
blcont	DC.W	0		Check if we have won yet?
mode	DC.W	0		What mode is the game on?
scrin	DC.W	0		Scroll counter for instructions
slide	DS.W	1		Space for slide counter
blockpos	DS.L	25		Where is each block stored
blockuse	DS.W	25		Usage of each block space
blcoord	DS.W	450		Coordinates of moving blocks
blcoord2	DS.W	450		Space for restart data
nummov	DS.W	1		Number of moving blocks
purpwin	DC.W	0		Purple's score
bluewin	DC.W	0		Blue's score
slowdowns	DC.W	0		Counter to slow instructions down
levload	DC.W	0		Level to load
starcoord	DS.W	50		Space for star coordinates
old_rez	DC.W	0		Used to store old screen rez.
intin	DC.L	0		Space for intin array
ptsin	DC.L	0		Space for ptsin array
won	DC.W	0		have we won the level?
nomome	DC.W	0		Disable controls option
numlev	DC.W	0		Number of one player levels
numlev2	DC.W	0		Number of two player levels
numlev3	DC.W	0		Number of competative levels
oldfile	DC.W	0		old handle number
passinf	DS.L	450		buffer to store passwords
passinf2	DS.L	450		buffer to store 2player passwords
passinf3	DS.L	450		buffer for competative passwords
clevel	DC.W	1		Current level number
bbuffer	DC.B	1		Universal 1 byte buffer
	EVEN			Prevent address errors
timelmt	DC.B	1		Space for time limit
	EVEN			Prevent address errors
spin	DC.W	0		star spin data
mask	DC.W	0		mask indicator
myclock	DC.L	0		Space to store clock
oldclock	DC.L	0		Space to store clock last update
plyno	DC.W	0		2player mode control
timespace	DS.W	2		Space for time in asc fromat
keypress	DC.W	0		Key pressed on keyboard
nodud	DS.W	6		Space to store dud data
laytest	DC.W	0		layout indicator
lock	DC.W	0		Slow down mode selector
drawicon	DC.W	0		icons or blocks?
laydata	DC.L	0		Layout data to use
handle	DC.W	0		File Handle
newgame	DC.W	0		Is it a new game?
bltype	DC.W	0		Block type
oldphys	DC.L	0		Old physical address
oldlog	DC.L	0		Old logical address
iconno	DC.L	0		Which icon to draw
screen_1	DC.L	0		Address of the screens
screen_2	DC.L	0		Address of another screen
screen_3	DC.L	0		Address of third screen
masks	DC.L	0		Space for masks
iconmask	DC.L	0		Space for icon masks
icons1	DC.L	0		space for icons
icons2	DC.L	0		space for more icons
icons3	DC.L	0		space for third line of icons
replay	DC.L	0		address of music player
music	DC.L	0		address of music
atable	DC.L	0		address of line a routine table
samples	DC.L	0		address of music samples
sincos	DC.L	0		address for sin and cos table
sincos2	DC.L	0		address for processing table
shiftbuf	DC.L	0		address for preshift buffer
pic_mode	DS.W	1		1 word for picture's mode
palette	DS.W	16		16 words for palette
intpal	DS.W	1		1 word for picture's mode
intpalt	DS.W	16		16 words for palette
titpal	DS.W	1		1 word for picutre's mode
titpalt	DS.W	16		16 words for palette
position	DC.W	0,0,32,32,32,0,32,30
	DC.W	64,0,32,28,96,0,32,26
	DC.W	128,0,32,24,160,0,32,22
	DC.W	192,0,32,20,224,0,32,18
	DC.W	256,0,16,16,272,0,16,14
	DC.W	288,0,16,12,304,0,16,10
	DC.W	0,32,16,8,16,32,16,6
	DC.W	32,32,16,4
iconpos1	DC.W	0,0,32,40,32,0,32,40
	DC.W	64,0,32,40,96,0,32,9
	DC.W	128,0,32,9,160,0,32,9
	DC.W	96,13,32,9,128,13,32,9
	DC.W	160,13,32,9,96,26,32,9
	DC.W	128,26,32,9,160,26,32,9
	DC.W	0,0,1,1,0,0,1,1
	DC.W	0,0,1,1,0,0,1,1
iconpos2	DC.W	0,0,32,40,32,0,32,40
	DC.W	64,0,32,40,96,0,32,40
	DC.W	128,0,32,40,160,0,32,40
	DC.W	192,0,32,40,224,0,32,40
	DC.W	256,0,32,40,288,0,32,40
	DC.W	0,0,1,1,0,0,1,1
	DC.W	0,0,1,1,0,0,1,1
	DC.W	0,0,1,1,0,0,1,1
iconpos3	DC.W	0,0,32,9,32,0,32,9
	DC.W	64,0,32,9,96,0,32,9
	DC.W	128,0,32,9,160,0,32,9
	DC.W	192,0,32,9,224,0,32,9
	DC.W	256,0,32,9,0,0,1,1
	DC.W	0,0,1,1,0,0,1,1
	DC.W	0,0,1,1,0,0,1,1
	DC.W	0,0,1,1,0,0,1,1
blink	DS.B	60
	DC.B	1,2,1
	DS.B	30
	DC.B	1,2,1
	DS.B	120
	DC.B	1,2,1
	DS.B	150
	DC.B	1,2,1
	EVEN
showmap	DC.L	$04040504,$04040505,$05040504,$05040504
	DC.L	$04050404,$04040504,$04000000,$00000000
	DC.L	$0C0C0D0C,$0C0C0D0D,$0D0C0D0C,$0D0C0D0C
	DC.L	$0C0D0C0C,$0C0C0D0C,$0C000000,$00000000
	DC.L	$04040404,$04040404,$04040404,$04040404
	DC.L	$04040404,$04040404,$04000000,$00000000
	DC.L	$0C0C0C0C,$0C0C0C0C,$0C0C0C0C,$0C0C0C0C
	DC.L	$0C0C0C0C,$0C0C0C0C,$0C000000,$00000000
	DC.L	$0C0C0D0C,$0C0C0D0C,$0D0C0C0D,$0D0D0C0C
	DC.L	$0D0C0D0C,$0C0D0D0D,$0C000000,$00000000
	DC.L	$0D0D080D,$0D0D0D08,$0D0D0D0D,$080D0D0D
	DC.L	$0D0D0D0D,$0D0D080D,$0D000000,$00000000
	DC.L	$0B0F0F0F,$0B0F0B0F,$0B0F0F0F,$0B0F0F0F
	DC.L	$0B0F0B0F,$0B0F0F0F,$0B000000,$00000000
	DC.L	$0D0D0D0A,$0A0D0303,$080A0303,$03030D03
	DC.L	$0303030D,$0D03030D,$0D000000,$00000000
	DC.L	$0C0C0C0C,$0C0C0303,$030C0C03,$03030C0C
	DC.L	$0303030C,$0C0C0C0C,$0C000000,$00000000
	DC.L	$04040604,$04040604,$06040406,$06060404
	DC.L	$06040604,$04060606,$04000000,$00000000
	DC.L	$0D0D0D02,$0D0D0D02,$0D0D0D08,$09080D0D
	DC.L	$0809080D,$0D080908,$0D000000,$00000000
	DC.L	$0C0C0D0C,$0C0C0C0D,$0C0C0D0D,$0D0D0D0C
	DC.L	$0C0D0C0C,$0C0C0D0C,$0C000000,$00000000
	DC.L	$0F0F0B0F,$0F0F0B0B,$0B0F0B0B,$0F0B0B0F
	DC.L	$0B0B0B0F,$0F0F0B0F,$0F000000,$00000000
	DC.L	$0B0F0B0F,$0B0F0F0B,$0F0F0B0B,$0F0B0B0F
	DC.L	$0F0B0F0F,$0B0F0B0F,$0B000000,$00000000
	DC.L	$04040504,$04050504,$04040404,$04050405
	DC.L	$04050404,$04040504,$05000000,$00000000
	DC.L	$05050505,$05050F0F,$0505050F,$0F0F0505
	DC.L	$050F0F05,$05050505,$05000000,$00000000
	DC.L	$0C0D0C0C,$0C0D0D0D,$0D0D0C0C,$0C0D0C0D
	DC.L	$0D0D0D0D,$0C0D0C0C,$0C000000,$00000000
	DC.L	$0D030303,$0D0D0303,$030D0D03,$03030D0D
	DC.L	$030D030D,$0D030D03,$0D000000,$00000000
	DC.L	$0D080808,$0D080008,$00080808,$08080808
	DC.L	$08000808,$0D080808,$0D000000,$00000000
	DC.L	$0C0C0D0C,$0C0C0D0D,$0D0C0D0D,$0D0D0D0C
	DC.L	$0D0D0D0C,$0C0C0D0C,$0C000000,$00000000
	DC.L	$0C0C0E0C,$0C0C0C0C,$0E0C0C0C,$0E0C0C0C
	DC.L	$0C0C0C0C,$0C0C0E0C,$0C000000,$00000000

larrow	DC.L	$03020202,$03020202,$03020203,$02030203
	DC.L	$02020202

rarrow	DC.L	$02020302,$03020302,$02030202,$02030202
	DC.L	$02030202

layout	DS.L	240
iconlay	DS.L	240
iconlay1	DS.L	240
iconlay2	DS.L	240
map	DS.B	550
map2	DS.B	550
map3	DS.B	550
map4	DS.B	550
tmap	DS.B	1650
player1	DC.B	"player1.dat",0	File name for player1 graphics
player_2	DC.B	"player2.dat",0	File name for player2 graphics
playermsk	DC.B	"masks.dat",0	File name for mask data
err1	DC.B	27,"E"		Error Message
	DC.B	"Unable to load necessary file",13,10
	DC.B	"Press a key",0
	EVEN			Prevent address errors
src_file	DC.B	"icons.dat",0	Icon picture
	EVEN			Prevent address errors
cpanel	DC.B	"icons2.dat",0	Control panel
	EVEN			Prevent address errors
pic1	DC.B	"intro1.dat",0	Intro screen one
	EVEN			Prevent address errors
pic2	DC.B	"intro2.dat",0	Intro screen two
	EVEN			Prevent address errors
pic3	DC.B	"intro3.dat",0	Intro screen three
	EVEN			Prevent address errors
pic4	DC.B	"title.dat",0	Title screen
	EVEN			Prevent address errors
passb	DS.B	15		Space to type in password
	EVEN			Prevent address erros
b1_file1	DC.B	"block"		Start of file name
b1_file2	DS.B	2		Block to load goes in here
	DC.B	".dat",0		End of file name
	EVEN			Prevent address errors
voice	DC.B	"music.bin",0	Music samples
	EVEN			Prevent address errors
trig	DC.B	"trig.bin",0	File with Cos/Sin table
	EVEN			Prevent address errors
hifile	DC.B	"hiscores.dat",0	File name for hiscore table
	EVEN			Prevent address errors
tune	DC.B	"tune"		File name of tune
tune2	DS.B	2		Place music number here
	DC.B	".sng",0		Music to load in
	EVEN			Prevent address errors
passw	DC.B	"data.bin",0	Passwords filename
	EVEN			Prevent address errors
level1	DC.B	"levels\level"	Start of file name
level2	DS.B	2		Level to load goes here
ext	DC.B	".map",0		End of file name
	EVEN			Prevent address errors
extend	DC.B	".map"		End of file name
	DC.B	".2pl"		End of file name
	DC.B	".cmp"		End of file name
wait	DC.B	"PLEASE WAIT",0	Loading message
	EVEN			Prevent address errors
wait2	DC.B	"LOADING LEVEL "
wait3	DC.B	"01",0
	EVEN			Prevent address errors
cmpscore	DC.B	"SCORES",0
	EVEN
cmpscore2	DC.B	"PURPLE BLOCKS PAINTED : "
cmpscore3	DC.B	"000",0
	EVEN
cmpscore4	DC.B	"BLUE BLOCKS PAINTED : "
cmpscore5	DC.B	"000",0
	EVEN
cmpscore6 DC.B	"GAMES WON BY PLAYER 1 : "
cmpscore7	DC.B	"00",0
	EVEN
cmpscore8	DC.B	"GAMES WON BY PLAYER 2 : "
cmpscore9	DC.B	"00",0
	EVEN
yourscore	DC.B	"GAME OVER",0	Game Over message
	EVEN			Prevent address errors
points	DC.B	"YOU SCORED "	Your score
points2	DC.B	"000000",0	Space for score
	EVEN			Prevent address errors
hiscores	DC.B	"HISCORE TABLE",0
	EVEN	
hiscores2	DC.B	"ANDREW     005000",0
	DC.L	5000
	DC.B	"PAUL       003000",0
	DC.L	3000
	DC.B	"PETER      002000",0
	DC.L	2000
	DC.B	"IAN        001000",0
	DC.L	1000
	DC.B	"TOM        000800",0
	DC.L	800
	DC.B	"DAVID      000500",0
	DC.L	500
	DC.B	"CHARLES    000400",0
	DC.L	400
	DC.B	"HAIRY DUDE 000300",0
	DC.L	300
	DC.B	"JONATHON   000200",0
	DC.L	200
	DC.B	"MARTIN     000100",0
	DC.L	100
tableend	DC.B	0
pause	DC.B	"GAME PAUSED",0
	EVEN
pause2	DC.B	"PRESS ANY KEY",0
	EVEN
won1	DC.B	"CONGRATULATIONS",0
	EVEN
won2	DC.B	"YOU HAVE WON",0
	EVEN
hiscores3	DC.B	"CONGRATULATIONS",0
	EVEN
hiscores4	DC.B	"YOU HAVE A HIGH SCORE",0
	EVEN
hiscores5	DC.B	"PLEASE ENTER YOUR NAME",0
	EVEN
yourname	DS.B	13
	EVEN
ourscore	DC.L	0
lowcolour DC.W	$777,$700,$070,$770,$007,$707,$077,$555,$333
	DC.W	$733,$373,$773,$337,$737,$377,$000
medcolour	DC.W	$777,$700,$070,$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000
exps	DC.W	$000,$100,$200,$300,$400,$500,$600,$700,$710
	DC.W	$720,$730,$731,$732,$733,$733,$744,$755,$766
	DC.W	$777,$666,$555,$444,$333,$222,$000,$000,$000
dud	DC.W	0
shifts	DS.W	1
fil	DC.B	"replay.bin",0
com	DC.B	0
env	DC.W	0
	EVEN
j_vector	DS.L	1
oldpacket	DS.L	1
j_event	DS.W	1
j2_event	DS.W	1
counter	DS.W	1
save_ssp	DS.L	1
	DS.L	100		Save some space for the Stack
stack	DS.L	1		Stacks go backwards