
**************************************************************************

;HITS AND TIPS III FOR STAMPEDE ATARI ST JULY ISSUE 1990.
;Compiled by Stew.

;This requires a full working version of Devpac to run

;the following code is aimed at new comers to the 68000.
;all the routines below may be freely used and we hope that
;you find the comments very useful.

;this months issue is designed to show you how data tables work.
;the program features coloured blocks which fade

;next month we will show you how to fade the screen colors

;If you don't fully understand the code but are trying to learn, I
;would suggest purchasing books like the ATARI ST INTERNALS published
;by Abacus Software, and/or SYBEX Programming The 68000.

;first lets assign some variables using the EQUate function.

lowres	equ	0
medres	equ	1
hires	equ	2

;now the code begins. the entire program has been split up
;into routines which are called using BSR (branch to subroutine)
;and the routine is finished using RTS (return from subroutine)

codego	dc.w	$a00a	;turn off mouse
	bsr	supermode
	bsr	mypalette	;set screen colors
	bsr	getscreenbase
	bsr	savemode	;save current screen mode
	bsr	setmode	;low res screen
	bsr	clearscreen	;erase all the data
	bsr	message
	bsr	drawblocks
	bsr	tableroutine
	bsr	restorepalette	;restore gem palette
	bsr	restoremode	;back to old screen mode
exittogem	clr.w	-(sp)	;function 0-terminate program
	trap	#1	;now go back to gem

;as we wish to access the hardware in the st (the color pallete)
;we must put the 68000 into supervisor mode. this is done using
;the following routine

supermode	clr.l	-(sp)
	move.w	#$0020,-(sp)	;trap 1-function $20
	trap	#1
	addq.w	#6,sp
	rts

;change the palette to out own colours

mypalette	pea	clearpal	;palette address
	move.w	#6,-(sp)
	trap	#14
	addq.w	#6,sp
	rts

;the following routines simply set the st's screen
;colours using trap #14, function 6. the colours are
;actually placed into the hardware locations $ffff8240.

restorepalette
	move.l	#gempal,-(sp)	;address of palette in memory
	move.w	#$0006,-(sp)	;function 6-setpalette
	trap	#14	;set the palette
	addq.w	#6,sp
	rts

;as the st has more than 1 mode and we wish to use mode 0, low res,
;we must save the current screen mode (a number between 0 and 2)
;in a variable for resetting later. Trap 14, function 4, gets the
;mode number and returns it in d0

savemode	move.w	#4,-(sp)
	trap	#14
	addq.w	#2,sp
	move.w	d0,oldrez
	rts

;now we set the screen mode using function 5-trap 14. this also
;allows us to set where the st fetches the data for the screen.

setmode	move.w	#lowres,-(sp)	;place mode required on stack
	move.l	#-1,-(sp)	;dont effect screen address
	move.l	#-1,-(sp)	;dont effect screen address
	move.w	#$0005,-(sp)	;function 5-setscreen
	trap	#14	;set the screen resolution
	add.w	#12,sp
	rts

;now that the program has finished we must restore the screenmode
;to its original mode using trap 14, function 5, setscreen.
;the mode is pulled from the variable oldscreenmode.

restoremode	move.w	oldrez,-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
	rts

;now that the file has been loaded, we can display the data on the
;screen. the first thing to do is to get the address in memory
;of the screen. this is not fixed. 520 st's have a different
;screen location to 1040 st's. trap #14 function 2 returns the
;screen address in d0

getscreenbase	move.w	#2,-(sp)
	trap	#14
	addq.w	#2,sp
	move.l	d0,screenbase
	rts

;before we write to the screen we must clear out all the data. this
;is done using a small routine which simply loops for all the
;data on the screen. a0 is pointed to the start of the block in
;memory where the screen is and then d7 is used to loop for
;all the data on screen.

clearscreen	move.l	screenbase,a0	;start of screen
	move.w	#32000-1,d7
clearloop	clr.l	(a0)+
	dbra	d7,clearloop
	rts

;display the main message string on the screen using printline

message	pea	messagetx	;address of string
	move.w	#9,-(sp)	;function 9
	trap	#1	;print string
	addq.w	#6,sp	;correct stack
	rts

;this routine display all the blocks on the screen
;there are 16 blocks which are display in colours 0-15
;each block is 16 pixels high

drawblocks	move.l	screenbase,a0	;where to place
	add.w	#(2*8)+(92*160),a0 ;position on screen
	lea	blockdata,a1	;data to place on screen
	moveq	#0,d7	;loop counter
allblocks	movem.w	(a1)+,d0-d3	;grab plane data
	moveq	#0,d5	;offset
	moveq	#16-1,d6	;loop for height of block
height	movem.w	d0-d3,0(a0,d5.w) ;put data on screen
	add.l	#160,d5	;down a screen line
	dbra	d6,height	;do all block
	addq.w	#8,a0	;across screen
	addq.w	#1,d7	;next block
	cmp.w	#16,d7	;16 colours
	bne.s	allblocks	;loop for all of them
	rts

;this routine simply sets up the register a0 with the pallete colour
;required and the calls the fader routine to do the actual fade

tableroutine	lea	temppal,a0
	moveq	#16-1,d7
clearpalloop	clr.w	(a0)+
	dbra	d7,clearpalloop
	lea	pal1,a0
	bsr	fader
	lea	clearpal,a0
	bsr	fader

	lea	pal1,a0
	bsr	fader
	lea	whites,a0
	bsr	fader
	lea	reds,a0
	bsr	fader
	lea	greens,a0
	bsr	fader
	lea	blues,a0
	bsr	fader
	lea	yellows,a0
	bsr	fader
	lea	cyans,a0
	bsr	fader

	lea	clearpal,a0
	bsr	fader
	rts

;this routine fades the current screen pallete to the colours
;specified in the table at (a0)+. the pallete is 32 bytes long.
;the vbl routine is called so that the colour transfer is
;smooth (the colour is changed off the visible screen area)

fader	move.l	a0,fadeaddr	;save the address for later
fadego	clr.w	counter	;setup counter
fadedelay	bsr	vbl	;wait for top of screen
	addq.w	#1,counter	;adjust counter
	cmp.w	#5,counter	;delayed for a second
	bne.s	fadedelay	;if not, delay for fader
	bsr	adjustcolours	;change color
	bsr	copycols	;set pallete values
	move.l	fadeaddr,a0	;start of destination pallete
	lea	temppal,a1	;current pallete
	moveq	#16-1,d7	;number of colours
checkloop	move.w	(a0)+,d0	;dest colour
	cmp.w	(a1)+,d0	;reached required colour
	bne.s	fadego	;no, go again
	dbra	d7,checkloop
	rts

;this is the heart of the fader. the rgb colours are adjusted either
;up or down.

adjustcolours	move.l	fadeaddr,a0
	lea	temppal,a1
	moveq	#16-1,d7	;16 colour pallete
fadeloop	moveq	#$01,d0
	moveq	#$07,d1
	moveq	#3-1,d6	;rgb loop
adjustloop	move.w	(a0),d2	;pull current colour
	move.w	(a1),d3	;destination colour
	and.w	d1,d2	;issolate blue/green/red
	and.w	d1,d3
	cmp.w	d2,d3	;reached value ?
	beq.s	gotcolour
	blt.s	addtocolour
	sub.w	d0,(a1)
	bra.s	gotcolour
addtocolour	add.w	d0,(a1)
gotcolour	lsl.w	#4,d0	;move through bgr
	lsl.w	#4,d1
	dbra	d6,adjustloop
	addq.w	#2,a0
	addq.w	#2,a1
	dbra	d7,fadeloop
	rts

;this routine is very simple. it copies the pallete values
;in memory into the actual pallete. this is prefered over
;directly changing the pallete colours at location $ffff8240
;as this is a hardware register which may not always return
;the correct value when read.
;the MOVEMultiple instructions are very useful, they allow
;large chucks of memory to be read directly into registers
;rather than doing several moves.

copycols	movem.l	temppal,d0-d7	;setup pallete
	movem.l	d0-d7,$ffff8240
	rts

;wait until the raster beam hits the top of the screen

vbl	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp
	rts

**************************************************************************

;reserved space for variables

;the data for each block is stored in the table below.
;there are 4 words which make up the 4 bit planes for the color.
;e.g. color 13 is %1101

blockdata	dc.w	$0000,$0000,$0000,$0000	;0
	dc.w	$ffff,$0000,$0000,$0000	;1
	dc.w	$0000,$ffff,$0000,$0000	;2
	dc.w	$ffff,$ffff,$0000,$0000	;3
	dc.w	$0000,$0000,$ffff,$0000	;4
	dc.w	$ffff,$0000,$ffff,$0000	;5
	dc.w	$0000,$ffff,$ffff,$0000	;6
	dc.w	$ffff,$ffff,$ffff,$0000	;7
	dc.w	$0000,$0000,$0000,$ffff	;8
	dc.w	$ffff,$0000,$0000,$ffff	;9
	dc.w	$0000,$ffff,$0000,$ffff	;10
	dc.w	$ffff,$ffff,$0000,$ffff	;11
	dc.w	$0000,$0000,$ffff,$ffff	;12
	dc.w	$ffff,$0000,$ffff,$ffff	;13
	dc.w	$0000,$ffff,$ffff,$ffff	;14
	dc.w	$ffff,$ffff,$ffff,$ffff	;15

gempal	dc.w	$777,$700,$070,$000,$111,$222,$333,$444
	dc.w	$555,$000,$001,$010,$100,$200,$020,$002

pal1	dc.w	$000,$003,$005,$007,$030,$050,$070,$333
	dc.w	$555,$777,$300,$500,$700,$330,$550,$770
clearpal	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
whites	dc.w	$000,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777
reds	dc.w	$000,$700,$700,$700,$700,$700,$700,$700
	dc.w	$700,$700,$700,$700,$700,$700,$700,$700
greens	dc.w	$000,$070,$070,$070,$070,$070,$070,$070
	dc.w	$070,$070,$070,$070,$070,$070,$070,$070
blues	dc.w	$000,$007,$007,$007,$007,$007,$007,$007
	dc.w	$007,$007,$007,$007,$007,$007,$007,$007
purples	dc.w	$000,$707,$707,$707,$707,$707,$707,$707
	dc.w	$707,$707,$707,$707,$707,$707,$707,$707
yellows	dc.w	$000,$770,$770,$770,$770,$770,$770,$770
	dc.w	$770,$770,$770,$770,$770,$770,$770,$770
cyans	dc.w	$000,$077,$077,$077,$077,$077,$077,$077
	dc.w	$077,$077,$077,$077,$077,$077,$077,$077

temppal	ds.w	16

counter	dc.w	0
oldrez	dc.w	0
screenbase	dc.l	0
fadeaddr	dc.l	0

messagetx	dc.b	"   STAMPEDE HINTS AND TIPS-JULY ISSUE",13,10
	dc.b	"            * COLOUR FADER *",0
	even

	end
