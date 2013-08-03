
;Sprite tutorial number 2

;Source code listing for the Untouchables disk magazine.
;Coded by Ninja of the Enterprise on the 9th November '91
;Sprite font by Technotron

;Neither the Untouchables or myself take any responsibility for the
;accuracy or efficiency of this source code listing.
;It does exactly what it was designed to do and it is possible to
;write a faster method but this was designed to teach the basics
;of sprite masking to those who have no knowledge of that topic.
;If you require further help then please write to either myself
;or the Untouchables and they will forward the letter to me.  I
;hope you can learn something from my work and thanks for being
;interested in it.

;Well here goes for some equates that make my routines sprite
;indipendant... just change these values.. (see article for how.)

no_blocks = 8
length_in_words = no_blocks*4
height = 29

;Note: The first section of this code is identical to my last article.
;This is because it is a standard 'demo' initalize method I always use.
;Feel free to use it in your own code, its a compliment after all!



;Set the system up for supervisor mode...
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack
	
	bsr	store_and_install_screen_setup

	pea	screen_note
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move.l	current,a0
	move.l	other,a1
	move.w	#8000,d1		ensure that the both screens
shift	move.l	(a0)+,(a1)+		have the screen note.
	dbf	d1,shift
	

;everything upto this point should have been staright
;forward and easy to understand (that also includes the contents
;of 'the store_and_install_screen_setup' subroutine).
;So now we move onto the tutorial bit...

;As there is an article in the magazine I won't go into
;to much detail but I will explain the actual routines...

;First we need to set up both the logo and mask buffers...
	bsr	setup_logo_buffers
	bsr	setup_mask_buffers

;So we now have everything ready to go, so here comes the main loop...

main_loop
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp			wait for the vbl

	move.l	other,d0
	move.l	current,other		swap the screen buffers
	move.l	d0,current		around.

        lsr.w   #8,d0			and now move it directly into
        move.l  d0,$ffff8200.w		the screen hardware registers

	bsr	draw_new_sprite		a bit obvious!?!

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
	movem.l	logo_palette,d0-7
	movem.l	d0-7,$ff8240

	rts



setup_logo_buffers
	lea	logo_sprite_map,a2
	moveq	#15-1,d0		I need 15 'new' sprites

shift_logo
;get the start of the sprite to be copied and shifted...
	move.l	(a2)+,a0
;get the start of where the 'new' sprite will be writen...
	move.l	(a2),a1

	moveq	#height-1,d1		the sprite is 'height' rows high.
do_next_line
	moveq	#4-1,d2			the sprite has 4 planes.
do_next_plane


bc	set	0
	rept	no_blocks
	move	bc(a0),bc(a1)		copy the 'bc' 16 pixels in plane.
bc	set	bc+8
	endr
	
bs	set	0
	rept	no_blocks
	roxr	bs(a1)			shift the 'bs' 16 pixels in plane.
bs	set	bs+8
	endr


	addq	#2,a0			next plane of source sprite.
	addq	#2,a1			next plane of destination sprite.
	dbf	d2,do_next_plane
	lea	(no_blocks-1)*8(a0),a0	next line of source sprite.
	lea	(no_blocks-1)*8(a1),a1	next line of destination sprite.

	dbf	d1,do_next_line		do the next line...
	dbf	d0,shift_logo		make another logo...
	rts





setup_mask_buffers
	lea	logo_sprite_map,a3
	lea	logo_mask_map,a2
	moveq	#16-1,d0		I need 16 masks

.mask_a_buffer
;get the start of the sprite to generate the mask...
	move.l	(a3)+,a0
;get the start of where the mask will be written...
	move.l	(a2)+,a1

	moveq	#height-1,d1		the sprite is 'height' rows high.
.do_next_line
	move.w	#no_blocks-1,d3		the number of blocks in a line.
.do_the_next_block
	clr.l	d6
	move.w	(a0),d6			get plane 1
	or.w	2(a0),d6		or plane 2
	or.w	4(a0),d6		or plane 3
	or.w	6(a0),d6		or plane 4
	swap	d6
	move.w	(a0)+,d6		get plane 1		
	or.w	(a0)+,d6		or plane 2
	or.w	(a0)+,d6		or plane 3
	or.w	(a0)+,d6		or plane 4
	not.l	d6			flip the bits
	move.l	d6,(a1)+		store a mask block
	dbf	d3,.do_the_next_block	
	dbf	d1,.do_next_line	

	dbf	d0,.mask_a_buffer	
	rts


draw_new_sprite
;First, I need to update the X and Y pointers...
	move.l	x_map_pos,a0
	move.w	(a0)+,x_coord
	cmp.l	#xend,a0
	bls	x_okay
	move.l	#xnew,a0
x_okay	move.l	a0,x_map_pos
	move.l	y_map_pos,a0
	move.w	(a0)+,y_coord
	cmp.l	#yend,a0
	bls	y_okay
	move.l	#ynew,a0
y_okay	move.l	a0,y_map_pos
	bsr	display_sprite
	rts
		

display_sprite
	move.l	other,a1	get the new screen
	add.l	#26*160,a1	move to the offset

;unlike last time, the X and Y co-ords are already known, so I can
;remove a section of the code from the previuos article.

	move.w	x_coord,d0
	add.w	#16,d0
	move.w	d0,d4			duplicate the x-axis co-ord.

;decide which of the 16 sprites and masks I will need...
	and	#$f,d4			only want the 1st 4 bits.
;Get the 16 bit boundary offset...
	and.w	#$fff0,d0		don't want the 1st 4 bits.

;convert x co-ord from an artist co-ord to a coder co-ord..
	ror	d0

;add new x co-ord to the screen..
	lea	(a1,d0.w),a1

;This time, we are going to use the y co-ord also...
	move.w	y_coord,d0
	muls.w	#160,d0			160 bytes to a line remember!?!
	lea	(a1,d0.w),a1


;select the sprite from the buffer
	lsl.w	#2,d4			quick multiply by 4
	lea	logo_sprite_map,a0	a0 now points to the table
	move.l	0(a0,d4.w),a0		a0 now points to the sprite.

;select the mask from the buffer
	lea	logo_mask_map,a2	a2 now points to the table
	move.l	0(a2,d4.w),a2		a2 now points to the mask.


;So, here comes the bit you've all been waiting for...
;Yes!! The mask to the screen routine!!!!

	move.w	#height-1,d0		'height' number of lines
shift_a_line
	rept	no_blocks
	move.l	(a1),d1			read planes 1 & 2 from the screen.
	and.l	(a2),d1			and the block mask into the above.
	or.l	(a0)+,d1		or sprite planes 1 & 2 as above.
	move.l	d1,(a1)+		write new planes 1 & 2 to screen.

	move.l	(a1),d1			read planes 3 & 4 from the screen.
	and.l	(a2)+,d1		and the block mask into the above.
	or.l	(a0)+,d1		or sprite planes 3 & 4 as above.
	move.l	d1,(a1)+		write new planes 3 & 4 to screen.
	endr
	add.l	#160-(8*no_blocks),a1	goto the offset on the next line.
	dbf	d0,shift_a_line

	rts
	
		



;the variables....

stack			dc.l	0
physical_screen		dc.l	0
logical_screen		dc.l	0
screen_resolution	dc.w	0
palette_store		ds.w	16
current			dc.l	0
other			dc.l	0


screen_note
	dc.b	"The 'NINJA' sprite is being masked onto",10,13
	dc.b	"the old copies of itself.",10,13
	dc.b	"Press 'Space' to finish.",10,13
	dc.b	10,10,10,10,10,10,10,10,10,10
	dc.b	10,10,10,10,10,10,10,10,10,10
	dc.b	"Coded by the Ninja of the Enterprise",10,13
	dc.b	"Sprite font by Technotron"
	dc.b	0
x_map
	dc.w	-1
logo_palette
	dc.w	0,$555,$444,$333,$222,0,0,0
	dc.w	0,0,0,0,0,0,0,$777

ynew	dc.w	0,1,2,3,4,5,7,9,$B,$D,$F,$12,$15,$18,$1B,$1E
	dc.w	$22,$26,$2A,$2E,$32,$37,$3C,$41,$46,$4B,$4F,$53
	dc.w	$57,$5B,$5F,$62,$65,$68,$6B,$6E,$70,$72,$74,$76
	dc.w	$78,$79,$7A,$7B,$7C,$7D,$7C,$7B,$7A,$79,$78,$76
	dc.w	$74,$72,$70,$6E,$6B,$68,$65,$62,$5F,$5B,$57,$53
	dc.w	$4F,$4B,$46,$41,$3C,$37,$32,$2E,$2A,$26,$22,$1E
	dc.w	$1B,$18,$15,$12,$F,$D,$B,9,7,5,4,3,2,1
yend	dc.w	0

xnew	dc.w	1,2,3,4,5,7,9,$B,$D,$F,$12,$15,$18,$1B,$1E,$22
	dc.w	$26,$2A,$2E,$32,$37,$3C,$41,$46,$4B,$51,$57,$5D
	dc.w	$63,$69,$6E,$73,$78,$7D,$82,$86,$8A,$8E,$92,$96
	dc.w	$99,$9C,$9F,$A2,$A5,$A7,$A9,$AB,$AD,$AF,$B0,$B1
	dc.w	$B2,$B3,$B4,$B3,$B2,$B1,$B0,$AF,$AD,$AB,$A9,$A7
	dc.w	$A5,$A2,$9F,$9C,$99,$96,$92,$8E,$8A,$86,$82,$7D
	dc.w	$78,$73,$6E,$69,$63,$5D,$57,$51,$4B,$46,$41,$3C
	dc.w	$37,$32,$2E,$2A,$26,$22,$1E,$1B,$18,$15,$12,$F
	dc.w	$D,$B,9,7,5,4,3,2
xend	dc.w	1



y_map_pos  dc.l    ynew+30
x_map_pos  dc.l    xnew+20

x_coord	dc.w	0
y_coord	dc.w	0


logo_sprite_map
	dc.l	logo0,logo1,logo2,logo3,logo4,logo5,logo6,logo7
	dc.l	logo8,logo9,logo10,logo11,logo12,logo13,logo14,logo15

logo_mask_map
	dc.l	mask0,mask1,mask2,mask3,mask4,mask5,mask6,mask7
	dc.l	mask8,mask9,mask10,mask11,mask12,mask13,mask14,mask15


logo_data
logo0
data_buf
;line 1
	dc.w	$FC01,0,0,0,$F87E,0,0,0,$1F80,0,0,0,$3F00,0,0,0
	dc.w	$F,0,0,0,$C001,0,0,0,$F800,0,0,0,0,0,0,0
;line 2
	dc.w	$F801,$8601,0,0,$F07C,$842,0,0,$1F00,$10C0,0,0,$3E00,$2100,0,0
	dc.w	$F,8,0,0,$8001,$4001,0,0,$F000,$800,0,0,0,0,0,0
;line 3
	dc.w	$F001,$CE01,0,0,$E078,$9866,0,0,$1E00,$19C0,0,0,$3C00,$3300,0,0
	dc.w	$F,$C,0,0,1,$C001,0,0,$E000,$9800,0,0,0,0,0,0
;line 4
	dc.w	$E001,$FF01,0,0,$C070,$F87E,0,0,$1C00,$1FE0,0,0,$3800,$3F00,0,0
	dc.w	$E,$F,0,0,3,$C003,0,0,$A000,$FC00,0,0,0,0,0,0
;line 5
	dc.w	$E001,$FF01,0,0,$C070,$F87E,0,0,$1C00,$1FE0,0,0,$3800,$3F00,0,0
	dc.w	$E,$F,0,0,3,$C003,0,0,$A000,$FC00,0,0,0,0,0,0
;line 6
	dc.w	$E001,$FF81,0,0,$C070,$F87E,0,0,$1C00,$1FF0,0,0,$3800,$3F00,0,0
	dc.w	$E,$F,0,0,3,$C003,0,0,$A000,$FC00,0,0,0,0,0,0
;line 7
	dc.w	$E001,$FF81,0,0,$C070,$F87E,0,0,$1C00,$1FF0,0,0,$3800,$3F00,0,0
	dc.w	$E,$F,0,0,7,$C007,0,0,$3000,$FE00,0,0,0,0,0,0
;line 8
	dc.w	$E001,$FDC1,$200,0,$C070,$F87E,0,0,$1C00,$1FB8,$40,0,$3800,$3F00,0,0
	dc.w	$E,$F,0,0,7,$C007,0,0,$3000,$FE00,0,0,0,0,0,0
;line 9
	dc.w	$E001,$FDC1,$200,0,$C070,$F87E,0,0,$1C00,$1FB8,$40,0,$3800,$3F00,0,0
	dc.w	$E,$F,0,0,7,$C007,0,0,$3000,$FE00,0,0,0,0,0,0
;line 10
	dc.w	$E001,$FCE1,$300,0,$C070,$F87E,0,0,$1C00,$1F9C,$60,0,$3800,$3F00,0,0
	dc.w	$E,$F,0,0,$E,$C00F,0,0,$3800,$FF00,0,0,0,0,0,0
;line 11
	dc.w	$E001,$FCE1,$300,0,$C070,$F87E,0,0,$1C00,$1F9C,$60,0,$3800,$3F00,0,0
	dc.w	$E,$F,0,0,$E,$C00F,0,0,$3800,$FF00,0,0,0,0,0,0
;line 12
	dc.w	$E001,$FC71,$380,0,$C070,$F87E,0,0,$1C00,$1F8E,$70,0,$3800,$3F00,0,0
	dc.w	$E,$F,0,0,$E,$C00F,0,0,$3800,$FF00,0,0,0,0,0,0
;line 13
	dc.w	$E001,$FC71,$380,0,$C070,$F87E,0,0,$1C00,$1F8E,$70,0,$3800,$3F00,0,0
	dc.w	$E,$F,0,0,$1C,$C01F,0,0,$1C00,$9F80,0,0,0,0,0,0
;line 14
	dc.w	$E001,$FC39,$1C0,0,$C070,$F87E,0,0,$1C00,$1F87,$38,0,$3800,$3F00,0,0
	dc.w	$E,$F,0,0,$1C,$C01F,0,0,$1C00,$9F80,0,0,0,0,0,0
;line 15
	dc.w	$E001,$FC39,$1C0,0,$C070,$F87E,0,0,$1C00,$1F87,$38,0,$3800,$3F00,0,0
	dc.w	$E,$F,0,0,$1C,$C01F,0,0,$1C00,$9F80,0,0,0,0,0,0
;line 16
	dc.w	$E001,$FC1D,$E0,0,$C070,$F87E,0,0,$1C00,$1F83,$1C,0,$3800,$BF00,0,0
	dc.w	$E,$F,0,0,$38,$C03F,0,0,$E00,$FC0,0,0,0,0,0,0
;line 17
	dc.w	$E001,$FC1D,$E0,0,$C070,$F87E,0,0,$1C00,$1F83,$1C,0,$380F,$BF00,0,0
	dc.w	$C00E,$F,0,0,$3B,$C03C,0,0,$FE00,$3C0,0,0,0,0,0,0
;line 18
	dc.w	$E001,$FC0F,$70,0,$C070,$F87E,0,0,$1C00,$1F81,$E,0,$380F,$FF08,0,0
	dc.w	$800E,$400F,0,0,$77,$C078,0,0,$FF00,$1E0,0,0,0,0,0,0
;line 19
	dc.w	$E001,$FC0F,$70,0,$C070,$F87E,0,0,$1C00,$1F81,$E,0,$380F,$FF0C,0,0
	dc.w	$E,$C00F,0,0,$7F,$C070,0,0,$FF00,$E0,0,0,0,0,0,0
;line 20
	dc.w	$E001,$FC07,$38,0,$C070,$F87E,0,0,$1C00,$1F80,7,0,$380E,$FF0F,0,0
	dc.w	$E,$C00F,0,0,$70,$C070,$F,0,0,$E0,$FF00,0,0,0,0,0
;line 21
	dc.w	$E001,$FC07,$38,0,$C070,$F87E,0,0,$1C00,$1F80,7,0,$380E,$FF0F,0,0
	dc.w	$E,$C00F,0,0,$E0,$C0F0,$F,0,$80,$F0,$FF00,0,0,0,0,0
;line 22
	dc.w	$E001,$FC03,$1C,0,$C070,$F87E,0,0,$1C00,$1F80,3,0,$380E,$7F0F,$8000,0
	dc.w	$E,$C00F,0,0,$E0,$C0F8,7,0,$180,$1F0,$FE00,0,0,0,0,0
;line 23
	dc.w	$E001,$FC03,$1C,0,$C070,$F87E,0,0,$1C00,$1F80,3,0,$380E,$7F0F,$8000,0
	dc.w	$E,$C00F,0,0,$E0,$C0FC,0,0,$380,$3F0,0,0,0,0,0,0
;line 24
	dc.w	$E001,$FC01,$E,0,$C070,$F87E,0,0,$1C00,$1F80,1,0,$380E,$3F0F,$C000,0
	dc.w	$7FFE,$800F,0,0,$1C0,$C1F8,0,0,$1C0,$1F8,0,0,0,0,0,0
;line 25
	dc.w	$E001,$FC01,$E,0,$C070,$F87E,0,0,$1C00,$1F80,1,0,$380E,$3F0F,$C000,0
	dc.w	$FFFE,7,0,0,$1C0,$C1F8,0,0,$1C0,$1F8,0,0,0,0,0,0
;line 26
	dc.w	$E001,$FC01,6,0,$C070,$F87E,0,0,$1C00,$1F80,0,0,$380F,$3F0E,$C000,0
	dc.w	$FFFE,3,0,0,$1C0,$C1F8,0,0,$1C0,$1F8,0,0,0,0,0,0
;line 27
	dc.w	$C001,$CC01,$3006,0,$8060,$9866,$6018,0,$1800,$1980,$600,0,$300C,$330C,$CC03,0
	dc.w	0,0,$FFFF,0,$300,$C338,$C0,0,$C0,$CC,$30,0,0,0,0,0
;line 28
	dc.w	$8001,$8401,$7802,0,$40,$842,$F03C,0,$1000,$1080,$F00,0,$2008,$2108,$5E07,0
	dc.w	0,0,$FFFF,0,$200,$4210,$81E0,0,$80,$84,$78,0,0,0,0,0
;line 29
	dc.w	0,0,$FC03,0,0,0,$F87E,0,0,0,$1F80,0,0,0,$7F0F,0
	dc.w	0,0,$FFFF,0,0,0,$C3F0,0,0,0,$FC,0,0,0,0,0


logo1	ds.w	length_in_words*height
logo2	ds.w	length_in_words*height
logo3	ds.w	length_in_words*height
logo4	ds.w	length_in_words*height
logo5	ds.w	length_in_words*height
logo6	ds.w	length_in_words*height
logo7	ds.w	length_in_words*height
logo8	ds.w	length_in_words*height
logo9	ds.w	length_in_words*height
logo10	ds.w	length_in_words*height
logo11	ds.w	length_in_words*height
logo12	ds.w	length_in_words*height
logo13	ds.w	length_in_words*height
logo14	ds.w	length_in_words*height
logo15	ds.w	length_in_words*height


mask_data
mask0	ds.l	no_blocks*height
mask1	ds.l	no_blocks*height
mask2	ds.l	no_blocks*height
mask3	ds.l	no_blocks*height
mask4	ds.l	no_blocks*height
mask5	ds.l	no_blocks*height
mask6	ds.l	no_blocks*height
mask7	ds.l	no_blocks*height
mask8	ds.l	no_blocks*height
mask9	ds.l	no_blocks*height
mask10	ds.l	no_blocks*height
mask11	ds.l	no_blocks*height
mask12	ds.l	no_blocks*height
mask13	ds.l	no_blocks*height
mask14	ds.l	no_blocks*height
mask15	ds.l	no_blocks*height

end_of_program


