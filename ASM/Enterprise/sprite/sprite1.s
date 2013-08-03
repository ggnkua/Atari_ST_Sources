;Sprite tutorial number 1


;Source code listing for the Untouchables disk magazine.
;Coded by the Ninja of the Enterprise on the 23rd August '91.
;Ball sprite by the Re-animator

;Neither the Untouchables or myself take any responsibility for
;the accuracy or effiecency of this source code listing.
;It does exactly what it was designed to do and it is possible to write
;a faster method but this was designed to teach the basics of
;sprite handling to those who have no knowledge of that topic.
;If you require further help then please write to either myself
;or the Untochables and they will forward the letter to me.
;I hope you can learn something from my work and thanks for
;being interested in it.


;(for you people out there that understand the technical side
;of things, this is a program that will:
;shift a 32x32 sprite of data format (48x32 4 plane)
;along the x-axis unmasked onto a blank background.
;Using line clearing rather than block clearing...)



;set the sytem up for supervisor mode...
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack

	bsr	store_and_install_screen_setup


;everything upto this point should have been staright
;forward and easy to understand (that also includes the contents
;of 'the store_and_install_screen_setup' subroutine).
;So now we move onto the tutorial bit...

;As there is an article in the magazine I won't go into
;to much detail but I will explain the actual routines...

;First we need to set up the ball buffers (see article for why...).
	bsr	setup_ball_buffers


;So we now have evrything ready to go, so here comes the main loop...

main_loop
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp			wait for the vbl

	move.l	other,d0
	move.l	current,other		swap the screen buffers
	move.l	d0,current		around.

        lsr.w   #8,d0			and now move it directly into
        move.l  d0,$ffff8200.w		the screen hardware registers.

	bsr	clear_old_sprite	these routines are obvious,
	bsr	draw_new_sprite		arn't they!?!

	cmp.b	#$39,$fffffc02.w	'Space' key been pressed yet?...
	bne	main_loop		If not loop again....


;So now I close down the program and restore everything
;back to what it was before this program was executed....

;First the screen address and resolution
	move.w	screen_resolution,-(sp)
	move.l	logical_screen,-(sp)
	move.l	physical_screen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

;restore the palette
	movem.l	palette_store,d0-7
	movem.l	d0-7,$ff8240


;return to user mode
	move.l	stack,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

  
;and terminate the program.
	clr.w	-(sp)
	trap	#1







store_and_install_screen_setup
;store the current screen state...
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,physical_screen
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,logical_screen
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,screen_resolution

;and also store the palette...
	movem.l	$ff8240,d0-7
	movem.l	d0-7,palette_store


;and now I can set the ST to low resolution and my own screen
;buffer at the end of the program...

	move.l	#end_of_program,d0
	add.l	#256,d0			set d0 to a 256 boundary
	clr.b	d0			after the end of the program.

	move.l	d0,current
	move.l	d0,other
	add.l	#$8000,other

	move.l	d0,a0
	move.w	#$4000,d1		ensure that the new screens
.wipe	move.l	#0,(a0)+		buffer is clean.
	dbf	d1,.wipe

	clr.w	-(sp)
	move.l	d0,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)		make the resolution and
	trap	#14			screen address changes.
	lea	12(sp),sp

;and install my new palette...
	movem.l	ball_palette,d0-7
	movem.l	d0-7,$ff8240

	rts



setup_ball_buffers
	lea	ball_sprite_map,a2
	moveq	#15-1,d0		I need 15 'new' sprites

shift_ball
;get the start of the sprite to be copied and shifted...
	move.l	(a2)+,a0
;get the start of where the 'new' sprite will be writen...
	move.l	(a2),a1

	moveq	#32-1,d1		the sprite is 32 rows high.
do_next_line
	moveq	#4-1,d2			the sprite has 4 planes.
do_next_plane
	move	(a0),(a1)		copy the 1st 16 pixels in plane.
	move	8(a0),8(a1)		copy the 2nd 16 pixels in plane.
	move	16(a0),16(a1)		copy the 3rd 16 pixels in plane.
	roxr	(a1)			shift the 1st 16 pixels in plane.
	roxr	8(a1)			shift the 2nd 16 pixels in plane.
	roxr	16(a1)			shift the 3rd 16 pixels in plane.

	addq	#2,a0			next plane of source sprite.
	addq	#2,a1			next plane of destination sprite.
	dbf	d2,do_next_plane
	lea	16(a0),a0		next line of source sprite.
	lea	16(a1),a1		next line of destination sprite.

	dbf	d1,do_next_line		do the next line...
	dbf	d0,shift_ball		make another ball...
	rts


clear_old_sprite
;this is a VERY simple and crap way of clearing the screen.
;In fact it is so slow it will only be used this once
;and will be replaced by much faster routines in later articles.
;But for now as screen clearing isn't what you are supposed to be
;learning about, this will do....
 
	move.l	other,a0		get the old screen
	add.l	#20*160,a0		move to the offset
	move.w	#32-1,d0		set a loop for 32 lines
.wipe	rept	40
	move.l	#0,(a0)+
	endr
	dbf	d0,.wipe		wipe em...
	rts

draw_new_sprite
;once again this is a simple routine but it will be expanded on
;in future articles, so learn the basics now and you won't get lost...

	move.l	other,a1		get the new screen
	add.l	#20*160,a1		move to the offset
	move.l	x_map_pos,a2		get x-axis map position
	cmp.w	#-1,(a2)		check for the end of the x map
	bne	x_value_okay		if its not then thats okay
	lea	x_map,a2		restart the x map
x_value_okay
	clr.l	d0
	move.w	(a2)+,d0		get the x-axis co-ordinate
	move.l	a2,x_map_pos		store x-axis map position

	move.w	d0,d4			duplicate the x-axis co-ord.
;decide which of the 16 sprites I will need...
	and	#$f,d4			only want the 1st 4 bits.
;Get the 16 bit boundary offset...
	and.w	#$fff0,d0		don't want the 1st 4 bits.

;the x-axis map is made up of co-ordinates that an artist would use,
;in other words, range 0 to 319.  They are no good to us coders as we
;need them in a range of 0 to 159. So divide by 2...
	ror	d0

;As you will have read in the article sprites need to be on a
;16 pixel boundary.  d0 now has this 16 bit boundary...
	lea	(a1,d0.w),a1
;so a1 now has the correct screen co-ordinate to draw the sprite at.
;but this co-ord is rounded down to the nearest 16 boundary.
;That is why we made the 16 'different' sprites.
;They are used as follows...

;d4 has a range of 0 to 15 and we have sprites in the same range,
;however the lookup table goes up in steps of 4 so...
	lsl.w	#2,d4			quick multiply by 4
	lea	ball_sprite_map,a0	a0 now points to the table
	move.l	0(a0,d4.w),a0		a0 now points to the sprite.

;the above 30 or so lines will not chane much as things progress in later
;articles but the next bit is just a quick draw routine on the same lines
;as I did a quick clear routine.  Its crap but serves its purpose...

	move.w	#32-1,d0		32 lines to a sprite
.shift_a_line
	move.l	(a0)+,(a1)		planes 1&2 of left block
	move.l	(a0)+,4(a1)		planes 3&4 of left block
	move.l	(a0)+,8(a1)		planes 1&2 of middle block
	move.l	(a0)+,12(a1)		planes 3&4 of middle block
	move.l	(a0)+,16(a1)		planes 1&2 of right block
	move.l	(a0)+,20(a1)		planes 3&4 of right block
	lea	160(a1),a1		move to next screen line
	dbf	d0,.shift_a_line	 		
		
	rts
	



;the variables....

stack			dc.l	0
physical_screen		dc.l	0
logical_screen		dc.l	0
screen_resolution	dc.w	0
palette_store		ds.w	16
current			dc.l	0
other			dc.l	0

x_map_pos	dc.l	x_map
x_map
	dc.w	1,2,3,4,6,8,10,12,15,18,21,24,28,32,36,40,45,50,55,60
	dc.w	64,68,72,76,79,82,85,88,90,92,94,96,97,98,99,100
	dc.w	100,99,98,97,96,94,92,90,88,85,82,79,76,72,68,64
	dc.w	60,55,50,45,40,36,32,28,24,21,18,15,12,10,8,6,4,3,2,1
	dc.w	-1
ball_palette	dc.w	0,$777,$70,$770,7,$707,$77,$537
		dc.w	$335,$100,$200,$300,$400,$500,$600,$700
ball_sprite_map
	dc.l	ball0,ball1,ball2,ball3,ball4,ball5,ball6,ball7
	dc.l	ball8,ball9,ball10,ball11,ball12,ball13,ball14,ball15
ball_data
ball0
	dc.w	$13,$10,$F,$1F,$C800,$800,$F000,$F800,0,0,0,0
	dc.w	$7C,$1F,$7F,$7F,0,$FC00,$FE00,$FE00,0,0,0,0
	dc.w	$1E0,$7F,$1FF,$1FF,0,$FF00,$FF80,$FF80,0,0,0,0
	dc.w	$380,$1FF,$3FF,$3FF,0,$FF80,$FFC0,$FFC0,0,0,0,0
	dc.w	$600,$3FF,$7FF,$7FF,$1540,$EA80,$FFE0,$FFE0,0,0,0,0
	dc.w	$C02,$7FD,$FFF,$FFF,$AFE0,$5000,$FFF0,$FFF0,0,0,0,0
	dc.w	$1805,$FFA,$1FFF,$1FFF,$FFF0,0,$FFF8,$FFF8,0,0,0,0
	dc.w	$302B,$1FD4,$3FFF,$3FFF,$FFF8,0,$FFFC,$FFFC,0,0,0,0
	dc.w	$305F,$1FA0,$3FFF,$3FFF,$FFA8,0,$FFFC,$FFFC,0,0,0,0
	dc.w	$60BF,$3F40,$7FFF,$7FFF,$F554,0,$FFFE,$FFFE,0,0,0,0
	dc.w	$617F,$3E80,$7FFF,$7FFF,$AAA8,0,$FFFE,$FFFE,0,0,0,0
	dc.w	$C0FF,$FF00,$7FFF,$FFFF,$5555,1,$FFFE,$FFFF,0,0,0,0
	dc.w	$C1FA,$FE00,$7FFF,$FFFF,$A809,1,$FFFE,$FFFF,0,0,0,0
	dc.w	$42F5,$7D00,$FFFF,$FFFF,$4004,0,$FFFF,$FFFF,0,0,0,0
	dc.w	$85FA,$7A00,$FFFF,$FFFF,$8000,0,$FFFF,$FFFF,0,0,0,0
	dc.w	$83F5,$7C00,$FFFF,$FFFF,0,0,$FFFF,$FFFF,0,0,0,0
	dc.w	$87EA,$7800,$FFFF,$FFFF,0,0,$FFFF,$FFFF,0,0,0,0
	dc.w	$83D4,$7C00,$FFFF,$FFFF,0,0,$FFFF,$FFFF,0,0,0,0
	dc.w	$7E8,$7800,$FFFF,$FFFF,0,0,$FFFF,$FFFF,0,0,0,0
	dc.w	$8BD0,$F400,$7FFF,$FFFF,1,1,$FFFE,$FFFF,0,0,0,0
	dc.w	$87A8,$F800,$7FFF,$FFFF,1,1,$FFFE,$FFFF,0,0,0,0
	dc.w	$8FD0,$7000,$7FFF,$FFFF,1,0,$FFFE,$FFFF,0,0,0,0
	dc.w	$7A0,$3800,$7FFF,$7FFF,0,0,$FFFE,$FFFE,0,0,0,0
	dc.w	$FD0,$7000,$3FFF,$7FFF,0,2,$FFFC,$FFFE,0,0,0,0
	dc.w	$7A0,$1800,$3FFF,$3FFF,0,0,$FFFC,$FFFC,0,0,0,0
	dc.w	$2F50,0,$1FFF,$3FFF,4,0,$FFF8,$FFFC,0,0,0,0
	dc.w	$7A0,$1000,$FFF,$1FFF,0,8,$FFF0,$FFF8,0,0,0,0
	dc.w	$350,$800,$7FF,$FFF,0,$10,$FFE0,$FFF0,0,0,0,0
	dc.w	$1A8,$400,$3FF,$7FF,0,$20,$FFC0,$FFE0,0,0,0,0
	dc.w	$254,0,$1FF,$3FF,$40,0,$FF80,$FFC0,0,0,0,0
	dc.w	0,$80,$7F,$FF,0,$100,$FE00,$FF00,0,0,0,0
	dc.w	$38,$18,7,$3F,$1C00,$1800,$E000,$FC00,0,0,0,0
ball1	ds.w	12*32
ball2	ds.w	12*32
ball3	ds.w	12*32
ball4	ds.w	12*32
ball5	ds.w	12*32
ball6	ds.w	12*32
ball7	ds.w	12*32
ball8	ds.w	12*32
ball9	ds.w	12*32
ball10	ds.w	12*32
ball11	ds.w	12*32
ball12	ds.w	12*32
ball13	ds.w	12*32
ball14	ds.w	12*32
ball15	ds.w	12*32
end_of_program


