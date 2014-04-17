start	move.l	(a7)+,exitadr	Store exit address
	move.l	(a7)+,samples	Address of samples
	move.l	a7,stackadr	Store stack address
	bsr	initdma		Init dma chip
	bsr	loadquart		Load in quartet replay module
	move.b	#0,$ff8901	Stop DMA chip
	bsr	cls		Clear screen
	bsr	playquart		Start music
	bsr	initjoy		Initialise joystick check routines
titleloop	bsr	showplot		Show plot
	bsr	mbase		Show monsters info
	bra	titleloop		Start title sequence again

showplot	bsr	bpalt		Black palette
	move.l	screen1,a0	Address of screen 1
	move.l	screen2,a1	Address of screen 2
	move.l	#bscreen+34,a2	Address of background screen
	move.w	#1919,d0		Set up a counter
copyscrn1	move.l	(a2),(a0)+	Copy across long word
	move.l	(a2)+,(a1)+	Copy to both screens
	dbf	d0,copyscrn1	Copy next longword
	move.l	#tscreen+34,a2	Address of title screen
	move.w	#4519,d0		Set up a counter
copyscrnb	move.l	(a2),(a0)+	Copy across long word
	move.l	(a2)+,(a1)+	Copy to both screens
	dbf	d0,copyscrnb	Copy next longword
	move.l	#bscreen+34,a2	Address of background screen
	lea	25760(a2),a2	Move to bottom of screen
	move.w	#1559,d0		Set up a counter
copyscrnc	move.l	(a2),(a0)+	Copy across long word
	move.l	(a2)+,(a1)+	Copy to both screens
	dbf	d0,copyscrnc	Copy next longword

	bsr	copyback		Start preparing next screen
	bsr	initspot		Initialise spot lights
	bsr	spotlight		Draw spot lights
	bsr	spotlight		Draw spot lights
	bsr	setpalt		Set palette
	move.l	#plotdata,plottext	Address of plot text
	clr.l	plotxpos		Reset coordinates
spotloop1	bsr	spotlight		Do spot lights
	bsr	drawplot		Draw some more plot
	bsr	checkjoy		Check joystick
	dbf	d5,spotloop1	Loop back around

	move.w	#2,d6		Set up screen counter
scrn2_4	bsr	bpalt		Black palette
	move.l	screen1,a0	Address of screen 1
	move.l	screen2,a1	Address of screen 2
	move.l	#pscreen,a2	Address of plot screen
	move.w	#7999,d0		Set up a counter
copyscrn2	move.l	(a2),(a0)+	Copy across long word
	move.l	(a2)+,(a1)+	Copy to both screens
	dbf	d0,copyscrn2	Copy next longword

	bsr	copyback		Start preparing next screen
	bsr	initspot		Initialise spot lights
	bsr	spotlight		Draw spot lights
	bsr	spotlight		Draw spot lights
	bsr	setpalt		Set palette
	clr.l	plotxpos		Reset coordinates
spotloop2	bsr	spotlight		Do spot lights
	bsr	drawplot		Draw some more plot
	bsr	checkjoy		Check joystick
	dbf	d5,spotloop2	Loop back around
	dbf	d6,scrn2_4	Draw next screen
	rts			Return

initspot	move.l	screen1,a2	Address of spot light 1
	move.l	a2,a3		Address of spot light 2
	move.l	a3,a4		Address of spot light 3
	move.l	a4,a5		Address of spot light 4
	move.w	#199,d5		Set up counter
	rts			Return

copyback	move.l	#bscreen+34,a0	Address of background screen
	move.l	#pscreen,a1	Address of screen buffer
	move.w	#7999,d0		Set up a counter
copybackl	move.l	(a0)+,(a1)+	Copy across long word
	dbf	d0,copybackl	Copy next longword
	rts			Return

drawplot	move.l	plottext,a0	Address of plot text pointer
	move.b	(a0),d2		Get letter to draw
	cmp.b	#" ",d2		Space?
	beq	skipplot1		Yes, don't draw it!
	move.l	#fontlay,a6	Address of font table
	move.l	#tscreen+18266,a1	Address of font
bff1	addq.l	#8,a1		Move up source address
	cmp.b	#"U",(a6)		Next line?
	beq	bfline1		Yes, goto routine
bfline1r	cmp.b	(a6)+,d2		Found font yet?
	bne	bff1		No, check again
	lea	4160(a1),a0	Address of masks

	move.l	#pscreen,a6	Address of screen buffer
	lea	6080(a6),a6	Move to centre of screen
	move.w	plotxpos,d0	Address of x coordinate
	move.w	plotypos,d1	Address of y coordinate
	ext.l	d1		Extend to long word
	add.w	d1,a6		Add on y coordinate
	add.w	d0,a6		Add on x coordinate

	move.w	#12,d1		Set up a counter
biglet1	move.w	(a0)+,d0		Get mask data
	and.w	d0,(a6)		Place on screen
	move.w	(a1)+,d0		Get graphic data
	or.w	d0,(a6)+		Place on screen
	move.w	(a0)+,d0		Get mask data
	and.w	d0,(a6)		Place on screen
	move.w	(a1)+,d0		Get graphic data
	or.w	d0,(a6)+		Place on screen
	lea	156(a0),a0	Move up mask pointer
	lea	156(a1),a1	Move up graphic pointer
	lea	156(a6),a6	Move up screen pointer
	dbf	d1,biglet1	Draw next line

skipplot1	move.l	plottext,a0	Address of plot text potiner
	move.b	1(a0),d2		Get letter to draw
	cmp.b	#" ",d2		Space?
	beq	skipplot2		Yes, don't draw it!
	move.l	#fontlay,a6	Address of font table
	move.l	#tscreen+18266,a1	Address of font
bff2	addq.l	#8,a1		Move up source address
	cmp.b	#"U",(a6)		Next line?
	beq	bfline2		Yes, goto routine
bfline2r	cmp.b	(a6)+,d2		Found font yet?
	bne	bff2		No, check again
	lea	4160(a1),a0	Address of masks

	move.l	#pscreen,a6	Address of screen buffer
	lea	6080(a6),a6	Move to centre of screen
	move.w	plotxpos,d0	Address of x coordinate
	move.w	plotypos,d1	Address of y coordinate
	ext.l	d1		Extend to long word
	add.w	d1,a6		Add on y coordinate
	add.w	d0,a6		Add on x coordinate
	add.w	#1,a6		Move to second half of word

	move.w	#12,d1		Set up a counter
biglet2	move.b	(a0),d0		Get mask data
	and.b	d0,(a6)		Place on screen
	move.b	(a1),d0		Get graphic data
	or.b	d0,(a6)		Place on screen
	move.b	2(a0),d0		Get mask data
	and.b	d0,2(a6)		Place on screen
	move.b	2(a1),d0		Get graphic data
	or.b	d0,2(a6)		Place on screen
	lea	160(a0),a0	Move up mask pointer
	lea	160(a1),a1	Move up graphic pointer
	lea	160(a6),a6	Move up screen pointer
	dbf	d1,biglet2	Draw next line
	
skipplot2	add.l	#2,plottext	Move up plot position
	add.w	#8,plotxpos	Move up x position
	cmp.w	#159,plotxpos	End of line?
	bgt	nextplin		Yes adjust coordinates
	rts			Return

nextplin	clr.w	plotxpos		Move to start of line
	add.w	#2240,plotypos	Move down a line
	rts			Return

bfline1	lea	1920(a1),a1	Move to next line
	bra	bfline1r		Return
bfline2	lea	1920(a1),a1	Move to next line
	bra	bfline2r		Return

spotlight	move.l	screen1,a1	Find screen address
	add.w	ypos,a1		Add on yposition
	move.w	xpos,d0		Find x coordinate
	and.w	#$fff0,d0		Round off to nearest 16
	lsr.w	#1,d0		To find which word
	add.w	d0,a1		Graphics start at
	move.l	a1,slight1	Store address

	move.l	#spot,a0		Get graphics address
	move.w	xpos,d1		Get xposition
	and.w	#$f,d1		Find amount to shift graphics
	move.l	#shiftmsk,a6	Address of end masks
	add.w	d1,a6		Find place in table
	move.w	(a6,d1),d2	Get end mask 1
	move.w	32(a6,d1),d3	Get end mask 2

	move.w	#63,d0		Set up a counter
spot1	move.l	-2(a0),d4		Get first 16 bits of mask
	lsr.l	d1,d4		Shift them
	and.w	d2,d4		Add on endmask
	or.w	d4,4(a1)		Place on screen
	move.l	(a0)+,d4		Get next 16 bits of mask
	lsr.l	d1,d4		Shift them
	or.w	d4,12(a1)		Place on screen
	move.l	-2(a0),d4		Get next 16 bits of mask
	lsr.l	d1,d4		Shift them
	or.w	d4,20(a1)		Place on screen
	move.l	(a0)+,d4		Get next 16 bits of mask
	lsr.l	d1,d4		Shift them
	or.w	d4,28(a1)		Place on screen
	move.l	-2(a0),d4		Get last 16 bits of mask
	lsr.l	d1,d4		Shift them
	and.w	d3,d4		Add on endmask
	or.w	d4,36(a1)		Place on screen
	lea	160(a1),a1	Move to next line
	dbf	d0,spot1		Do next line

	move.l	screen1,a1	Find screen address
	add.w	ypos2,a1		Add on yposition
	move.w	xpos2,d0		Find x coordinate
	and.w	#$fff0,d0		Round off to nearest 16
	lsr.w	#1,d0		To find which word
	add.w	d0,a1		Graphics start at
	move.l	a1,slight2	Store address

	move.l	#spot,a0		Get graphics address
	move.w	xpos2,d1		Get xposition
	and.w	#$f,d1		Find amount to shift graphics
	move.l	#shiftmsk,a6	Address of end masks
	add.w	d1,a6		Find place in table
	move.w	(a6,d1),d2	Get end mask 1
	move.w	32(a6,d1),d3	Get end mask 2

	move.w	#63,d0		Set up a counter
spot2	move.l	-2(a0),d4		Get first 16 bits of mask
	lsr.l	d1,d4		Shift them
	and.w	d2,d4		Add on endmask
	or.w	d4,6(a1)		Place on screen
	move.l	(a0)+,d4		Get next 16 bits of mask
	lsr.l	d1,d4		Shift them
	or.w	d4,14(a1)		Place on screen
	move.l	-2(a0),d4		Get next 16 bits of mask
	lsr.l	d1,d4		Shift them
	or.w	d4,22(a1)		Place on screen
	move.l	(a0)+,d4		Get next 16 bits of mask
	lsr.l	d1,d4		Shift them
	or.w	d4,30(a1)		Place on screen
	move.l	-2(a0),d4		Get last 16 bits of mask
	lsr.l	d1,d4		Shift them
	and.w	d3,d4		Add on endmask
	or.w	d4,38(a1)		Place on screen
	lea	160(a1),a1	Move to next line
	dbf	d0,spot2		Do next line

	move.l	screen1,a1	Find screen address
	add.w	ypos3,a1		Add on yposition
	move.w	xpos3,d0		Find x coordinate
	and.w	#$fff0,d0		Round off to nearest 16
	lsr.w	#1,d0		To find which word
	add.w	d0,a1		Graphics start at
	move.l	a1,slight3	Store address

	move.l	#spot,a0		Get graphics address
	move.w	xpos3,d1		Get xposition
	and.w	#$f,d1		Find amount to shift graphics
	move.l	#shiftmsk,a6	Address of end masks
	add.w	d1,a6		Find place in table
	move.w	(a6,d1),d2	Get end mask 1
	move.w	32(a6,d1),d3	Get end mask 2

	move.w	#63,d0		Set up a counter
spot3	move.l	-2(a0),d4		Get first 16 bits of mask
	lsr.l	d1,d4		Shift them
	and.w	d2,d4		Add on endmask
	or.w	d4,4(a1)		Place on screen
	move.l	(a0)+,d4		Get next 16 bits of mask
	lsr.l	d1,d4		Shift them
	or.w	d4,12(a1)		Place on screen
	move.l	-2(a0),d4		Get next 16 bits of mask
	lsr.l	d1,d4		Shift them
	or.w	d4,20(a1)		Place on screen
	move.l	(a0)+,d4		Get next 16 bits of mask
	lsr.l	d1,d4		Shift them
	or.w	d4,28(a1)		Place on screen
	move.l	-2(a0),d4		Get last 16 bits of mask
	lsr.l	d1,d4		Shift them
	and.w	d3,d4		Add on endmask
	or.w	d4,36(a1)		Place on screen
	lea	160(a1),a1	Move to next line
	dbf	d0,spot3		Do next line

	move.l	screen1,a1	Find screen address
	add.w	ypos4,a1		Add on yposition
	move.w	xpos4,d0		Find x coordinate
	and.w	#$fff0,d0		Round off to nearest 16
	lsr.w	#1,d0		To find which word
	add.w	d0,a1		Graphics start at
	move.l	a1,slight4	Store address

	move.l	#spot,a0		Get graphics address
	move.w	xpos4,d1		Get xposition
	and.w	#$f,d1		Find amount to shift graphics
	move.l	#shiftmsk,a6	Address of end masks
	add.w	d1,a6		Find place in table
	move.w	(a6,d1),d2	Get end mask 1
	move.w	32(a6,d1),d3	Get end mask 2

	move.w	#63,d0		Set up a counter
spot4	move.l	-2(a0),d4		Get first 16 bits of mask
	lsr.l	d1,d4		Shift them
	and.w	d2,d4		Add on endmask
	or.w	d4,6(a1)		Place on screen
	move.l	(a0)+,d4		Get next 16 bits of mask
	lsr.l	d1,d4		Shift them
	or.w	d4,14(a1)		Place on screen
	move.l	-2(a0),d4		Get next 16 bits of mask
	lsr.l	d1,d4		Shift them
	or.w	d4,22(a1)		Place on screen
	move.l	(a0)+,d4		Get next 16 bits of mask
	lsr.l	d1,d4		Shift them
	or.w	d4,30(a1)		Place on screen
	move.l	-2(a0),d4		Get last 16 bits of mask
	lsr.l	d1,d4		Shift them
	and.w	d3,d4		Add on endmask
	or.w	d4,38(a1)		Place on screen
	lea	160(a1),a1	Move to next line
	dbf	d0,spot4		Do next line

	bsr	scrnswap		Reveal screen
	move.w	#37,-(sp)		Wait for video return
	trap	#14		Call XBIOS
	addq.l	#2,sp		Correct stack

	move.w	#63,d0		Set up a counter
killspot1	clr.w	4(a2)		Erase from screen
	clr.w	12(a2)		Erase from screen
	clr.w	20(a2)		Erase from screen
	clr.w	28(a2)		Erase from screen
	clr.w	36(a2)		Erase from screen
	lea	160(a2),a2	Move down a line
	dbf	d0,killspot1	Erase next line

	move.w	#63,d0		Set up a counter
killspot2	clr.w	6(a3)		Erase from screen
	clr.w	14(a3)		Erase from screen
	clr.w	22(a3)		Erase from screen
	clr.w	30(a3)		Erase from screen
	clr.w	38(a3)		Erase from screen
	lea	160(a3),a3	Move down a line
	dbf	d0,killspot2	Erase next line

	move.w	#63,d0		Set up a counter
killspot3	clr.w	4(a4)		Erase from screen
	clr.w	12(a4)		Erase from screen
	clr.w	20(a4)		Erase from screen
	clr.w	28(a4)		Erase from screen
	clr.w	36(a4)		Erase from screen
	lea	160(a4),a4	Move down a line
	dbf	d0,killspot3	Erase next line

	move.w	#63,d0		Set up a counter
killspot4	clr.w	6(a5)		Erase from screen
	clr.w	14(a5)		Erase from screen
	clr.w	22(a5)		Erase from screen
	clr.w	30(a5)		Erase from screen
	clr.w	38(a5)		Erase from screen
	lea	160(a5),a5	Move down a line
	dbf	d0,killspot4	Erase next line

	move.l	slight1,a2	Update spot light 1 address
	move.l	slight2,a3	Update spot light 2 address
	move.l	slight3,a4	Update spot light 3 address
	move.l	slight4,a5	Update spot light 4 address

	move.w	xposd,d0
	add.w	d0,xpos		Update spot-light position
	move.w	yposd,d0
	add.w	d0,ypos		Update spot-light position
	move.w	xpos2d,d0
	add.w	d0,xpos2		Update spot-light position
	move.w	ypos2d,d0
	add.w	d0,ypos2		Update spot-light position
	move.w	xpos3d,d0
	add.w	d0,xpos3		Update spot-light position
	move.w	ypos3d,d0
	add.w	d0,ypos3		Update spot-light position
	move.w	xpos4d,d0
	add.w	d0,xpos4		Update spot-light position
	move.w	ypos4d,d0
	add.w	d0,ypos4		Update spot-light position

	cmp.w	#256,xpos		Off edge?
	bgt	xposbig		Yes, reverse direction
	tst.w	xpos		Off edge?
	blt	xpossmall		Yes, reverse direction
xposr	cmp.w	#21760,ypos	Off edge?
	bgt	yposbig		Yes, reverse direction
	tst.w	ypos		Off edge?
	blt	ypossmall		Yes, reverse direction
yposr	cmp.w	#256,xpos2	Off edge?
	bgt	xpos2big		Yes, reverse direction
	tst.w	xpos2		Off edge?
	blt	xpos2smll		Yes, reverse direction
xpos2r	cmp.w	#21760,ypos2	Off edge?
	bgt	ypos2big		Yes, reverse direction
	tst.w	ypos2		Off edge?
	blt	ypos2smll		Yes, reverse direction
ypos2r	cmp.w	#256,xpos3	Off edge?
	bgt	xpos3big		Yes, reverse direction
	tst.w	xpos3		Off edge?
	blt	xpos3smll		Yes, reverse direction
xpos3r	cmp.w	#21760,ypos3	Off edge?
	bgt	ypos3big		Yes, reverse direction
	tst.w	ypos3		Off edge?
	blt	ypos3smll		Yes, reverse direction
ypos3r	cmp.w	#256,xpos4	Off edge?
	bgt	xpos4big		Yes, reverse direction
	tst.w	xpos4		Off edge?
	blt	xpos4smll		Yes, reverse direction
xpos4r	cmp.w	#21760,ypos4	Off edge?
	bgt	ypos4big		Yes, reverse direction
	tst.w	ypos4		Off edge?
	blt	ypos4smll		Yes, reverse direction
ypos4r	rts			Return

xposbig	move.w	#256,xpos		Place on edge of screen
	neg.w	xposd		Reverse direction
	bra	xposr		Return
xpossmall	clr.w	xpos		Place on edge of screen
	neg.w	xposd		Reverse direction
	bra	xposr		Return
xpos2big	move.w	#256,xpos2	Place on edge of screen
	neg.w	xpos2d		Reverse direction
	bra	xpos2r		Return
xpos2smll	clr.w	xpos2		Place on edge of screen
	neg.w	xpos2d		Reverse direction
	bra	xpos2r		Return
xpos3big	move.w	#256,xpos3	Place on edge of screen
	neg.w	xpos3d		Reverse direction
	bra	xpos3r		Return
xpos3smll	clr.w	xpos3		Place on edge of screen
	neg.w	xpos3d		Reverse direction
	bra	xpos3r		Return
xpos4big	move.w	#256,xpos4	Place on edge of screen
	neg.w	xpos4d		Reverse direction
	bra	xpos4r		Return
xpos4smll	clr.w	xpos4		Place on edge of screen
	neg.w	xpos4d		Reverse direction
	bra	xpos4r		Return

yposbig	move.w	#21760,ypos	Place on edge of screen
	neg.w	yposd		Reverse direction
	bra	yposr		Return
ypossmall	clr.w	ypos		Place on edge of screen
	neg.w	yposd		Reverse direction
	bra	yposr		Return
ypos2big	move.w	#21760,ypos2	Place on edge of screen
	neg.w	ypos2d		Reverse direction
	bra	ypos2r		Return
ypos2smll	clr.w	ypos2		Place on edge of screen
	neg.w	ypos2d		Reverse direction
	bra	ypos2r		Return
ypos3big	move.w	#21760,ypos3	Place on edge of screen
	neg.w	ypos3d		Reverse direction
	bra	ypos3r		Return
ypos3smll	clr.w	ypos3		Place on edge of screen
	neg.w	ypos3d		Reverse direction
	bra	ypos3r		Return
ypos4big	move.w	#21760,ypos4	Place on edge of screen
	neg.w	ypos4d		Reverse direction
	bra	ypos4r		Return
ypos4smll	clr.w	ypos4		Place on edge of screen
	neg.w	ypos4d		Reverse direction
	bra	ypos4r		Return

mbase	bsr	bpalt		New palette
	bsr	cls		Clear screen
	bsr	mpalt		New palette

	bsr	openbox		Open up box
	move.l	#header,a2	Address of title
	bsr	teletype		Display it
	move.l	#mon2,a2		Address of name
	bsr	teletype		Display it
	move.l	#monster1+34,a0	Address of monster graphics
	move.l	screen2,a1	Destination address
	lea	16080(a0),a0	Address of graphic
	move.w	#9,d2		Width
	move.w	#99,d3		Height
	move.w	#78,d0		Destination x
	move.w	#30,d1		Destination y
	bsr	graphic1		Draw graphic
	move.l	#mon2b,a2		Address of info
	bsr	line8		Show it

	bsr	openbox		Open up box
	move.l	#header,a2	Address of title
	bsr	teletype		Display it
	move.l	#mon1,a2		Address of name
	bsr	teletype		Display it
	move.l	#monster1+34,a0	Address of monster graphics
	move.l	screen2,a1	Destination address
	move.w	#9,d2		Width
	move.w	#99,d3		Height
	move.w	#78,d0		Destination x
	move.w	#30,d1		Destination y
	bsr	graphic1		Draw graphic
	move.l	#mon1b,a2		Address of info
	bsr	line7		Show it

	bsr	openbox		Open up box
	move.l	#header,a2	Address of title
	bsr	teletype		Display it
	move.l	#mon3,a2		Address of name
	bsr	teletype		Display it
	move.l	#monster1+34,a0	Address of monster graphics
	move.l	screen2,a1	Destination address
	lea	80(a0),a0		Address of graphic
	move.w	#9,d2		Width
	move.w	#99,d3		Height
	move.w	#78,d0		Destination x
	move.w	#30,d1		Destination y
	bsr	graphic1		Draw graphic
	move.l	#mon3b,a2		Address of info
	bsr	line9		Show it

	bsr	openbox		Open up box
	move.l	#header,a2	Address of title
	bsr	teletype		Display it
	move.l	#mon4,a2		Address of name
	bsr	teletype		Display it
	move.l	#monster1+34,a0	Address of monster graphics
	move.l	screen2,a1	Destination address
	lea	16000(a0),a0	Address of graphic
	move.w	#9,d2		Width
	move.w	#99,d3		Height
	move.w	#78,d0		Destination x
	move.w	#30,d1		Destination y
	bsr	graphic1		Draw graphic
	move.l	#mon4b,a2		Address of info
	bsr	line8		Show it

	bsr	openbox		Open up box
	move.l	#header,a2	Address of title
	bsr	teletype		Display it
	move.l	#mon5,a2		Address of name
	bsr	teletype		Display it
	move.l	#monster2+34,a0	Address of monster graphics
	lea	16000(a0),a0	Move to correct address
	move.l	screen2,a1	Destination address
	move.w	#9,d2		Width
	move.w	#99,d3		Height
	move.w	#78,d0		Destination x
	move.w	#30,d1		Destination y
	bsr	graphic1		Draw graphic
	move.l	#mon5b,a2		Address of info
	bsr	line7		Show it

	bsr	openbox		Open up box
	move.l	#header,a2	Address of title
	bsr	teletype		Display it
	move.l	#mon6,a2		Address of name
	bsr	teletype		Display it
	move.l	#monster2+34,a0	Address of monster graphics
	lea	80(a0),a0		Move to correct address
	move.l	screen2,a1	Destination address
	move.w	#9,d2		Width
	move.w	#99,d3		Height
	move.w	#78,d0		Destination x
	move.w	#30,d1		Destination y
	bsr	graphic1		Draw graphic
	move.l	#mon6b,a2		Address of info
	bsr	line8		Show it

	bsr	openbox		Open up box
	move.l	#header,a2	Address of title
	bsr	teletype		Display it
	move.l	#mon7,a2		Address of name
	bsr	teletype		Display it
	move.l	#monster2+34,a0	Address of monster graphics
	move.l	screen2,a1	Destination address
	move.w	#9,d2		Width
	move.w	#99,d3		Height
	move.w	#78,d0		Destination x
	move.w	#30,d1		Destination y
	bsr	graphic1		Draw graphic
	move.l	#mon7b,a2		Address of info
	bsr	line9		Show it

	bsr	openbox		Open up box
	move.l	#header2,a2	Address of title
	bsr	teletype		Display it
	move.l	#monster2+34,a0	Address of monster graphics
	lea	16080(a0),a0	Move to correct address
	move.l	screen2,a1	Destination address
	move.w	#9,d2		Width
	move.w	#47,d3		Height
	move.w	#78,d0		Destination x
	move.w	#40,d1		Destination y
	bsr	graphic1		Draw graphic
	move.l	#mon8,a2		Address of info
	bsr	line10		Show it

	bsr	openbox		Open up box
	move.l	#header2,a2	Address of title
	bsr	teletype		Display it
	move.l	#monster2+34,a0	Address of monster graphics
	lea	23760(a0),a0	Move to correct address
	move.l	screen2,a1	Destination address
	move.w	#9,d2		Width
	move.w	#47,d3		Height
	move.w	#78,d0		Destination x
	move.w	#40,d1		Destination y
	bsr	graphic1		Draw graphic
	move.l	#mon9,a2		Address of info
	bsr	line10		Show it
	rts

line10	bsr	teletype		Display it
line9	bsr	teletype		Display it
line8	bsr	teletype		Display it
line7	bsr	teletype		Display it
	bsr	teletype		Display it
	bsr	teletype		Display it
	move.w	#$030,$ff825e	Reveal labels
	bsr	teletype		Display it
	bsr	teletype		Display it
	bsr	teletype		Display it
	bsr	teletype		Display it
	bsr	pause		Wait 6 seconds
	bsr	closebox		Close box
	rts			Return

end	move.w	#1,-(sp)		Wait key
	trap	#1		Call GEMDOS
	addq.l	#2,sp		Correct stack
	bsr	stopquart		Stop music
	clr.w	-(sp)		End
	trap	#1		Call GEMDOS

pause	move.w	#550,d6		Wait 11 seconds
pausel	move.w	#37,-(sp)		Wait VBL
	trap	#14		Call XBIOS
	addq.l	#2,sp		Correct stack
	bsr	checkjoy		Check joystick
	dbf	d6,pausel		Wait some more
	rts			Return

fontline	lea	800(a0),a0	Move to next line of fonts
        	bra	fontliner		Return

teletype	bsr	checkjoy		Check joystick
	clr.w	d6		Clear d6
	move.b	(a2)+,d6		Get xposition
	clr.w	d7		Clear d7
	move.b	(a2)+,d7		Get yposition
	move.b	(a2)+,d0		Get first letter

nextlet	cmp.b	#" ",d0		Space?
	beq	skiplet		Yes, don't draw it!
	move.l	#tscreen+26594,a0	Source address
	lea	3512(a0),a0	Move to fonts
	move.l	#fontlay,a1	Address of font table
findfont	addq.l	#8,a0		Move up source address
	cmp.b	#"U",(a1)		Next line?
	beq	fontline		Yes, goto routine
fontliner	cmp.b	(a1)+,d0		Found font yet?
	bne	findfont		No, check again

	clr.w	d2		Width of graphic
	move.w	#5,d3		Height
	move.w	d6,d0		Dest x
	move.w	d7,d1		Dest y
	move.l	screen2,a1	Dest address
	bsr	graphic1		Draw letter
	move.w	#37,-(sp)		Wait VBL
	trap	#14		Call XBIOS
	addq.l	#2,sp		Correct stack

skiplet	add.w	#6,d6		Move up dest x
	move.b	(a2)+,d0		Get next letter?
	tst.b	d0		Any letter to draw?
	bne	nextlet		Yes, draw it
	rts			Return

closebox	move.l	screen2,a0	Source address
	move.l	screen1,a1	Dest address
	move.w	#7999,d0		Set up a counter
cbloop	move.l	(a0)+,(a1)+	Copy across 4 bytes
	dbf	d0,cbloop		Copy entire screen
	move.w	#92,d4		Set up counter
	move.l	#tscreen+27074,a3	Source address
	move.w	#30112,d5		Starting y position
closeboxl	move.l	screen1,a1	Destination address
	add.w	d5,a1		Add on y position
	move.l	a3,a0		Source address
	move.w	#11,d0		Width
	move.w	#14,d1		Height
	bsr	graphic2		Redraw graphic
	sub.w	#320,d5		Move up y position
	bsr	scrnswap		Reveal screen
	move.w	#37,-(sp)		Wait VBL
	trap	#14		Call XBIOS
	addq.l	#2,sp		Correct stack
	bsr	checkjoy		Check joystick
	dbf	d4,closeboxl	Open up box further
	rts			Return

openbox	move.l	#tscreen+26594,a0	Address of box graphic
	move.l	screen1,a1	Destination address
	lea	32(a1),a1		Move to centre of screen
	move.w	#11,d0		Width
	move.w	#13,d1		Height
	bsr	graphic2		Draw box
	move.l	#tscreen+26594,a0	Address of box graphic
	move.l	screen2,a1	Destination address
	lea	32(a1),a1		Move to centre of screen
	move.w	#11,d0		Width
	move.w	#13,d1		Height
	bsr	graphic2		Draw box
	move.w	#90,d4		Set up counter
	move.l	#tscreen+27074,a3	Source address
	move.w	#992,d5		Starting y position
openboxl	move.l	screen1,a1	Destination address
	add.w	d5,a1		Add on y position
	move.l	a3,a0		Source address
	move.w	#11,d0		Width
	move.w	#10,d1		Height
	bsr	graphic2		Redraw graphic
	add.w	#320,d5		Move down y position
	bsr	scrnswap		Reveal screen
	move.w	#37,-(sp)		Wait VBL
	trap	#14		Call XBIOS
	addq.l	#2,sp		Correct stack
	bsr	checkjoy		Check joystick
	dbf	d4,openboxl	Open up box further
	move.w	#$000,$ff825e	Hide labels
	rts			Return

cls	move.l	#$100000,a0	End of screen memory
	move.w	#16383,d0		Setup counter
clrloop	clr.l	-(a0)		Blank out 4 bytes
	dbf	d0,clrloop	Next 4 bytes
	rts			Return

setpalt	pea	palt		New palette
	move.w	#6,-(sp)		Function number
	trap	#14		Call XBIOS
	addq.l	#6,sp		Correct stack
	rts			Return

bpalt	pea	palt2		New palette
	move.w	#6,-(sp)		Function number
	trap	#14		Call XBIOS
	addq.l	#6,sp		Correct stack
	rts			Return

mpalt	move.l	#monster1+34,a0	Address of monster graphics
	sub.l	#32,a0		Find palette
	move.l	a0,-(sp)		New palette
	move.w	#6,-(sp)		Function number
	trap	#14		Call XBIOS
	addq.l	#6,sp		Correct stack
	rts			Return

loadquart	move.l	#replay,a0	Address of program
	move.l	a0,d2		Copy into d2
	add.l	#$1c,d2		Move to end of base page
	lea	$1c(a0),a1	Copy into a1
	move.l	a1,a2		Copy into a2
	add.l	2(a0),a2		Pointer to start of program
	add.l	(a2)+,a1		Store in a1
	add.l	d2,(a1)		Modify start address
reloloop2	tst.b	(a2)		All relocated yet?
	beq	return		Yes, return
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
return	rts			Return

playquart	move.l	#replay,a5	Address of replayer
	move.l	#0,d0		Initialise replayer
	jsr	(a5)		Run replayer
	move.l	#5,d0		Install replayer
	move.l	#4,d1		Select DMA Chip
	jsr	(a5)		Run replayer
	move.l	#1,d0		Start music
	move.l	#music,a0		Address of music
	move.l	samples,a1	Address of samples
	jsr	(a5)		Run replayer
	rts			Return

stopquart	move.l	#replay,a5	Address of replayer
	move.l	#2,d0		Stop music
	jsr	(a5)		Run replayer
	move.l	#3,d0		De-install player
	jsr	(a5)		Run replayer
	rts			Return

initdma	move.b	#0,$ff8907		Start low byte
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

checkjoy	btst	#7,joy0		Pressed fire?
	beq	return		No, return
	bsr	stopquart		Stop quartet music
	bsr	bpalt		Black palette
	move.l	stackadr,a7	Address of stack
	move.l	exitadr,a0	Return address
	jmp	(a0)		Return

	include	"\assembly\routines\video.s"
	include	"\assembly\routines\graphic1.s"
	include	"\assembly\routines\graphic2.s"
	include	"\assembly\routines\joystick.s"

tscreen	incbin	"title1.pi1",0
bscreen	incbin	"title2.pi1",0
monster1	incbin	"monster1.pi1",0
monster2	incbin	"monster2.pi1",0
spot	incbin	"spot.dat",0
music	incbin	"title.4v",0
replay	incbin	"replay.bin",0
	even

samples	dc.l	0
exitadr	dc.l	0
stackadr	dc.l	0

palt	dc.w	$000,$888,$111,$999
	dc.w	$888,$111,$999,$222
	dc.w	$888,$111,$999,$222
	dc.w	$111,$999,$222,$AAA
palt2	ds.w	16

xpos	dc.w	90
ypos	dc.w	43*160
xpos2	dc.w	230
ypos2	dc.w	83*160
xpos3	dc.w	170
ypos3	dc.w	130*160
xpos4	dc.w	15
ypos4	dc.w	12*160

xposd	dc.w	18
yposd	dc.w	12*160
xpos2d	dc.w	-22
ypos2d	dc.w	7*160
xpos3d	dc.w	10
ypos3d	dc.w	15*160
xpos4d	dc.w	12
ypos4d	dc.w	-20*160

plottext	dc.l	0
plotxpos	dc.w	0
plotypos	dc.w	0

slight1	dc.l	0
slight2	dc.l	0
slight3	dc.l	0
slight4	dc.l	0

shiftmsk	dc.w	$ffff,$7fff,$3fff,$1fff,$fff,$7ff,$3ff,$1ff
	dc.w	$ff,$7f,$3f,$1f,$f,$7,$3,$1
shiftmsk2	dc.w	$0,$8000,$c000,$e000,$f000,$f800,$fc00,$fe00
	dc.w	$ff00,$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe

header	dc.b	116,5,"KNOWN ENEMIES:",0
header2	dc.b	137,11,"OBJECTS:",0

mon1	dc.b	122,17,"ROCK MONSTER",0
mon1b	dc.b	80,142,"AN ALIEN RACE CONQUERED BY",0	
	dc.b	74,148,"THE ENTITY DURING AN EARLIER",0
	dc.b	74,154,"ENCOUNTER. THEY HAVE LIMITED",0
	dc.b	86,160,"INTELLIGENCE AND SO WERE",0
	dc.b	86,166,"EASILY CONTROLLED BY THE",0
	dc.b	86,172,"ENTITY, AND WILL READILY",0
	dc.b	98,178,"FIGHT FOR ITS CAUSE.",0

mon2	dc.b	143,17,"ROBOT",0
mon2b	dc.b	86,142,"CREATED BY THE ENTITY AS",0
	dc.b	83,148,"WARRIORS TO CONQUER OTHER",0
	dc.b	86,154,"RACES, AND ACHIEVE TOTAL",0
	dc.b	83,160,"DOMINATION OF THE GALAXY.",0
	dc.b	74,166,"THE ROBOTS ARE EQUIPPED WITH",0
	dc.b	74,172,"A DEADLY LASER CANNON MAKING",0
	dc.b	83,178,"THEM DANGEROUS OPPONENTS.",0
	dc.b	107,184,"DESTROY ON SIGHT.",0

mon3	dc.b	140,17,"BEETLE",0
mon3b	dc.b	77,136,"SOON AFTER THE CONSTRUCTION",0
	dc.b	83,142,"OF THE UNDERGROUND BASES,",0
	dc.b	77,148,"THE HIGH LEVEL OF RADIATION",0
	dc.b	83,154,"FROM MUTATION EXPERIMENTS",0
	dc.b	74,160,"AFFECTED THE AREA, RESULTING",0
	dc.b	77,166,"IN GIANT BEETLES, WHICH NOW",0
	dc.b	92,172,"MOVE THROUGH THE BASES",0
	dc.b	80,178,"ATTACKING ANY INTRUDERS IN",0
	dc.b	125,184,"THEIR PATH.",0

mon4	dc.b	128,17,"GUN TURRET",0
mon4b	dc.b	83,136,"THESE DEFENCE SYSTEMS ARE",0
	dc.b	89,142,"PLACED IN HIGH SECURITY",0
	dc.b	83,148,"AREAS WITHIN THE COMPLEX.",0
	dc.b	104,154,"EQUIPPED WITH HIGH",0
	dc.b	74,160,"TECHNOLOGY INFRA RED SENSORS",0
	dc.b	80,166,"THEY CAN PICK OUT UNWANTED",0
	dc.b	86,172,"VISITORS, AND DISPOSE OF",0
	dc.b	143,178,"THEM.",0

mon5	dc.b	131,17,"GIANT BAT",0
mon5b	dc.b	80,142,"THESE BATS, ALTHOUGH WEAK,",0
	dc.b	80,148,"ARE VERY FAST, AND A SWARM",0
	dc.b	74,154,"CAN BE DEADLY. THEY WILL NOT",0
	dc.b	83,160,"BOTHER YOU IF LEFT ALONE,",0
	dc.b	77,166,"BUT OFTEN YOU WILL FIND YOU",0
	dc.b	95,172,"HAVE NO CHOICE BUT TO",0
	dc.b	119,178,"DISTURB THEM.",0

mon6	dc.b	140,17,"MUTANT",0
mon6b	dc.b	77,142,"THE PRODUCT OF THE ENTITY'S",0
	dc.b	77,148,"EXPERIMENTS ON HUMANS. THEY",0
	dc.b	83,154,"ARE NO LONGER CONSCIOUSLY",0
	dc.b	80,160,"AWARE OF ANYTHING EXCEPT A",0
	dc.b	95,166,"DESIRE TO DESTROY ALL",0
	dc.b	80,172,"INTRUDERS. THEIR INCREASED",0
	dc.b	80,178,"STRENGTH MEANS THEY SHOULD",0
	dc.b	83,184,"BE DESTROYED IMMEDIATELY.",0

mon7	dc.b	113,17,"ENERGY LIFEFORM",0
mon7b	dc.b	89,136,"THIS ENERGY LIFEFORM IS",0
	dc.b	92,142,"SIMILAR TO A GHOST. IT",0
	dc.b	86,148,"CONSISTS OF PURE ENERGY,",0
	dc.b	77,154,"MEANING IT CAN MOVE THROUGH",0
	dc.b	80,160,"WALLS, AND IS RESISTANT TO",0
	dc.b	77,166,"NORMAL WEAPONS. IT CAN ONLY",0
	dc.b	77,172,"BE DAMAGED BY PLASMA ATTACK.",0
	dc.b	74,178,"TOUCHING ONE WILL DRAIN YOUR",0
	dc.b	113,184,"ENERGY RAPIDLY.",0

mon8	dc.b	74,106,"KNIFE: DOES PLENTY OF DAMAGE",0
	dc.b	74,112,"       BUT ONLY SHORT RANGE",0
	dc.b	74,124,"MEDIKIT: RESTORES UP TO 50",0
	dc.b	74,130,"         PERCENT LOST HEALTH",0
	dc.b	74,142,"KEYS: USE TO UNLOCK DOORS",0
	dc.b	74,154,"GRENADE: WILL DETONATE ONCE",0
	dc.b	74,160,"         THROWN, KILLING ANY",0
	dc.b	74,166,"         MONSTERS NEARBY",0
	dc.b	74,178,"MACHINE: RAPID FIRE WEAPON",0
	dc.b	74,184,"  GUN    KILLS QUICKLY",0

mon9	dc.b	74,106,"ROCKET    THE MOST POWERFUL",0
	dc.b	74,112,"LAUNCHER: WEAPON, CAN KILL",0
	dc.b	74,118,"          MULTIPLE MONSTERS",0
	dc.b	74,124,"          WITH JUST 1 SHOT",0
	dc.b	74,136,"MAPPER: AUTOMATICALLY MAPS",0
	dc.b	74,142,"        WHERE YOU GO",0
	dc.b	74,154,"RADAR: WARNS OF APROACHING",0
	dc.b	74,160,"       MONSTERS",0
	dc.b	74,178,"PLASMA  THE ONLY WAY OF",0
	dc.b	74,184,"GUN:    DESTROYING GHOSTS",0

plotdata	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"   AFTER 3 MONTHS OF INTENSE FIGHTING   "
	dc.b	"  BETWEEN THE TERRAN DEFENCE FLEET, AND "
	dc.b	"   EVIL ROBOTS UNDER THE CONTROL OF AN  "
	dc.b	" UNKNOWN ENTITY, THE PLANET HAS FINALLY "
	dc.b	" BEEN DEFEATED, AND A REIGN OF FEAR AND "
	dc.b	"           DESTRUCTION BEGUN.           "        
	dc.b	"                                        "
	dc.b	"                                        "

	dc.b	"     MOST OF THE SURVIVORS HAVE BEEN    "
	dc.b	" CAPTURED, AND FORCED TO FIGHT FOR THE  "
	dc.b	"     ENTITY, OR USED IN EXPERIMENTS     "
	dc.b	"  TO CREATE AN ARMY OF DEADLY MUTANTS.  "
	dc.b	" I AM BEING HELD PRISONER IN ONE OF THE "
	dc.b	" RECENTLY CONSTRUCTED UNDERGROUND BASES."
	dc.b	"   SOON I TOO WILL BE DEPRIVED OF MY    "
	dc.b	"   HUMANITY. IN MY DESPERATION I HAVE   "
	dc.b	"      FORMULATED A PLAN OF ESCAPE.      "
	dc.b	"                                        "

	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"AFTER ASSAULTING ONE OF THE GUARDS, AND "
	dc.b	"   GRABBING A GUN, I MADE A BREAK FOR   "
	dc.b	" FREEDOM. MY PLAN TO MAKE MY WAY TO THE "
	dc.b	"    CENTRE OF THE BASE, OVERTHROW MY    "
	dc.b	"    CAPTORS, AND BLOW UP THE COMPLEX.   "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "

	rept	10
	dc.b	"                                        "
	endr

fontlay	dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,':"
	even

pscreen	ds.b	32000