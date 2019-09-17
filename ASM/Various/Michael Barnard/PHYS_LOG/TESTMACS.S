
* test macros.

	include	a:\micsmacs.s		macros
	opt	o+			optimise code
	opt	m+			expand macros

******************************************************************************
* MAIN LOOP

start
	bsr.s	init			initialise

	move.l	screenp,-(sp)		clear screenp
	bsr	cls
	addq.l	#4,sp
	
	move.l	screenl,-(sp)		clear screenl
	bsr	cls
	addq.l	#4,sp
	
gl1	getlogbase

	move.l	#mes001,-(sp)		print mes1 to the logical screen
	bsr	printastring
	addq.l	#4,sp

gl2	getlogbase

	bsr	swap			swap the screens

gl3	getlogbase

	move.l	#mes002,-(sp)		print mes2 to the logical screen
	bsr	printastring
	addq.l	#4,sp
	
.loop1
	bsr.s	getkey			get a keypress
	tst.l	d0
	beq.s	.loop1
	
	cmpi.b	#' ',d0			was <space> pressed?
	bne	.loop1			no, branch
	
	term				finished. Yes, I know I havn't reset the
*					rez or addresses yet...

*************************************************************************
* INITIALISE

init
	getrez
	move.w	d0,oldrez
	
	getphysbase
	move.l	d0,screenp
	
	add1screen
	move.l	d0,screenl
	
	setscreen	0,screenp,screenl
	
	rts	

************************************************************************
* GET A KEYPRESS FROM THE BUFFER

getkey
	getkey
	
	rts

************************************************************************
* SCREEN SWAP

swap
	scrnswap
	
	rts

************************************************************************
* PRINT A STRING OF CHARACTERS

printastring
	printastring
	
	rts

************************************************************************
* CLEAR A 32K SCREEN

cls
	cls
	
	rts
	
************************************************************************
* VARIABLE SPACE

* system messages

mes001		dc.b	"This is screen <1>.",0
mes002		dc.b	"This is screen <2>.",0

	bss
	
oldrez		ds.w	1
screenp		ds.l	1
screenl		ds.l	1
screenmem	ds.b	32256

