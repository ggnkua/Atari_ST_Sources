* Source code for Motion Pac
* by Eddies Cat Un-Interactive 1997
* Read the article in Maggie for a fuller explanation.


START	
* first we get the original setting of the computer so we can
* restore them when we exit the program

	move.w	#4,-(sp)			getrez
	trap	#14
	add.l	#2,sp
	move.w	d0,original_res

	move.w	#2,-(sp)			physbase
	trap	#14
	add.l	#2,sp
	move.l	d0,original_physic
	move.l	d0,display_screen
	
	move.w	#0,-(sp)			setscreen (low res)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	move.l	#0,-(sp)			Super (supervisor mode)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	a7,original_stack
	move.l	#my_stack,a7
	
	movem.l	$ffff8240,d0-d7		Stash palette
	movem.l	d0-d7,original_palette

	move.l	#picture+2,-(sp)		setpalette	
	move	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	
	move.l	#newscreen,d0	form first new screen
	add.l	#256,d0		set d0 to a 256 byte boundary
	clr.b	d0		with these two instructions	
	move.l	d0,work_screen	

	move.b	#$12,$fffffc02.w	turn off mouse

*draw background onto both screens
	lea	picture+34,a0
	move.l	display_screen,a1
	add.w	#(160*25),a1
	move.l	work_screen,a2
	add.w	#(160*25),a2
	move.w	#((160*152)/2)-1,d0
drawloop
	move.w	(a0),(a1)+
	move.w	(a0)+,(a2)+
	dbra	d0,drawloop		
	


mainloop
*clear the background bitplanes where pacman is drawn onto
	move.l	work_screen,a2
	add.w	#4,a2
	move.w	#(32000/32)-1,d0
	move.w	#8,d1
	moveq	#0,d2
picloop
	REPT	4		i.e. the assembler repeats this
	move.l	d2,(a2)		section 4 times (saves typing!)
	add.w	d1,a2
	ENDR			end repeat section
	dbra	d0,picloop	

*here's pacman!
	move.l	old_pac_image,sprad		last image for blur
	move.w	old_pacx,d1		xpos
	move.w	old_pacy,d2		ypos
	move.w	#4,d4			bitplane offset
	bsr	SPRITE

	move.l	pac_image,sprad		present image
	move.w	pacx,d1			xpos
	move.w	pacy,d2			ypos
	move.w	#6,d4			bitplane offset
	bsr	SPRITE

	bsr	SHOW			switch screens to display it
	
	move.w	pacx,old_pacx		present image goes into last image
	move.w	pacy,old_pacy
	move.l	pac_image,old_pac_image

	cmp.w	#4,frame_count		only update pac animation
	blt	its_ok			every "x" frames

	clr.w	frame_count
	lea	pac_lookup,a0
	move.w	pac_pointer,d0
	move.l	(a0,d0.w),pac_image		new animation frame

	add.w	#4,pac_pointer
	cmp.w	#4*4,pac_pointer
	bne	its_ok
	clr.w	pac_pointer		reset animation
its_ok
	add.w	#1,frame_count

	move.w	xdir,d0			directions to move in
	add.w	d0,pacx
	move.w	ydir,d0
	add.w	d0,pacy

*elasticity
	cmp.w	#1,ydir			make movement bouncy
	bne	other
	move.w	pacy,d0
	lsr.w	#4,d0			divide y by 16
	add.w	d0,pacy			and add to y 
other	
	cmp.w	#-1,ydir
	bne	the_other
	move.w	pacy,d0
	lsr.w	#4,d0			as above but for upward movement
	sub.w	d0,pacy
the_other	
	

*bounce off screen edges
	cmp.w	#270,pacx
	blt	check_x_low
	move.w	#-2,xdir
check_x_low	
	cmp.w	#20,pacx
	bgt	check_y_high
	move.w	#2,xdir
check_y_high	
	cmp.w	#135,pacy
	blt	check_y_low
	move.w	#-1,ydir
check_y_low
	cmp.w	#10,pacy
	bgt	end_check
	move.w	#1,ydir
end_check

	cmp.b	#$39,$fffffc02		if space bar is not pressed
	bne	mainloop			goto mainloop


*exit program 
	move.b	#$8,$fffffc02.w	Turn on mouse


	move	original_res,-(sp)		setscreen, back to original
	move.l	original_physic,-(sp)
	move.l	#-1,-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp

	move.l	#original_palette,-(sp)	setpalette, restore colours
	move	#6,-(sp)
	trap	#14
	addq.l	#6,sp


	move.l	original_stack,a7
	move.l	#0,-(sp)		Back to User mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#0,-(sp)		Pterm (0) i.e. Exit
	move.w	#76,-(sp)
	trap	#1

*---SUBROUTINES---------------------------------------------------*

SHOW	 
	movem.l	work_screen,d0-d1	Double buffered screen display
	exg.l	d0,d1		swap the screen buffers
	movem.l	d0-d1,work_screen	around.

	lsr.w   	#8,d1		get into right format for hardware registers		
        	move.l  	d1,$ffff8200.w	high & med. bytes of screen	

	move	#37,-(sp)		vsync, which waits for the vertical blank
	trap	#14
	addq.l	#2,sp

	rts


	
SPRITE
* 1 bitplane, no masking
* there is NO offscreen clipping in this, so if anypart of the
* sprite image goes offscreen, the computer will crash. Beware!
*	d1.w=xpos
*	d2.w=ypos
*	d4.w=bitplane offset

	movem.l	d0-d7/a0-a2,-(sp)
	
	move.l	work_screen,a1	draw on workscreen for screen switching

	move.w	d1,d0
	and.w	#$fff0,d1	
	lsr.w	#1,d1		D1 is now word offset
	move.w	d1,d7
	and.w	#$000f,d0		D0 is now bitshift offset		
	
	mulu	#160,d2		D2 is start line of screen address
	adda.l	d2,a1
	ext.l	d1
	adda.l	d1,a1		screen address for sprite


	move.w	#3-1,d2		WIDTH
	move.l	sprad,a0		SPRITE IMAGE
lineloop
	move.w	#47-1,d1		LENGTH
vertloop

	clr.l	d3
	move.w	4(a0),d3
	ror.l	d0,d3
	or.w	d3,(a1,d4.w)	puts first half of image on screen	
	swap	d3
	or.w	d3,8(a1,d4.w)	second half of image on screen
	

	lea	160(a0),a0	next line down in sprite data
	lea	160(a1),a1	next line down on screen
* (the above two lines are quicker forms of adda.l #160,a0)

	dbra	d1,vertloop	

	suba.w	#47*160-8,a0	sprite data back to top +16 pixels
	suba.w	#47*160-8,a1	screen pos back to top +16 pixels

	dbra	d2,lineloop

	movem.l	(sp)+,d0-d7/a0-a2
	rts





	SECTION 	BSS
* (variables or data that sarts off with the value 0)

original_stack	ds.l	1
original_res	ds.w	1
original_physic	ds.l	1
work_screen	ds.l	1
display_screen	ds.l	1

pac_pointer	ds.w	1
xpos		ds.w	1
ypos		ds.w	1
sprad		ds.l	1
frame_count	ds.w	1

original_palette	ds.w	16

		ds.w	512
my_stack		ds.l	0	stacks always go backwards		

newscreen		ds.b	512
		ds.b	32000
	
	SECTION DATA
* (variables/data that isn't =0 at the start of the program)

pacx		dc.w	100
pacy		dc.w	70
old_pacx		dc.w	100
old_pacy		dc.w	70
xdir		dc.w	2
ydir		dc.w	1

pac_image		dc.l	picture+34+(160*153),sprad	first values
old_pac_image	dc.l	picture+34+(160*153),sprad

pac_lookup
		dc.l	picture+34+(160*153)
		dc.l	picture+34+(160*153)+24
		dc.l	picture+34+(160*153)+48
		dc.l	picture+34+(160*153)+24
	

picture	incbin	motion.pi1
*alter the above path to where you keep your picture file
	
