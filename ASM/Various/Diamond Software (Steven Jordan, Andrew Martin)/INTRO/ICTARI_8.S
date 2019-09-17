***************************************************************************
*							    *
*   Ictari Intro #8     - Source code (c) Diamond Software 1993	    *
*   Graphics            - Steven Jordan & The Demon X (TWB)		    *
*   Programming         - Steven Jordan			              *
*   Nice Music	    - Mad Max				    *
*							    *
*		    - Set your tabs to 10			    *
*		    - Assemble with GENST V2+ 		    *
*							    *
* This intro was coded about a year ago. It was originaly going to be for *
* Ictari #8, but it never got released for some reason or another.        *
* The code is nothing special, but you might find it usefull.             *
* Note: The left and right border don't work on STE's (Thanks Nik)        *
*							    *
***************************************************************************

wait	macro	\1		;define the wait macro
	movem.l	d5-d6,-(sp)	;save registers 
	move.w	#\1,d6		;parameter 1 in D6 
loop\@	move.l	$466,d5		;wait vbl 
same\@	cmp.l	$466,d5		;done it?
	beq	same\@		;na.
	dbra	d6,loop\@		;yep, but loop again!
	movem.l	(sp)+,d5-d6	;restore register
	endm			;finished the macro
	
scan1	equ	160		;left & right borders on
scan2	equ	230		;left & right borders off
scan3	equ	180		;left/right border on

	bsr	set_super		;set supervisor mode
	bsr	mouse_off		;turn the mouse off
	bsr	get_base		;get screen
	bsr	set_up		;create new screen space
	move.l	screen,a0		;go for low rez
	bsr	set_low_rez	;set for low rez!
	bsr	set_screen	;set screen to new position
	bsr	init_music	;initalise the music
	bsr	set_small		;initalise the small scroller
	bsr	save_pal		;save the palette	
	movem.l	black,d0-d7	;get our palette
	movem.l	d0-d7,$ffff8240	;set it

	bsr	set_screen	;flip screen
	bsr	draw_credits	;draw the credits
	bsr	draw_grass	;draw the grass
	bsr	draw_ictari	;draw the Ictari pic

	bsr       mfp_on     	;turn on all interupts

***************************************************************************

loop_01	cmp.b	#57,$fffffc02	;is space pressed?...
	bne	loop_01		;no. keep looping
	
	bra	exit		;yes. exit

***************************************************************************
* EXIT - RESTORE ALL THAT WE CHANGED			  	    *
***************************************************************************

exit	bsr       mfp_off    	;turn off all interupts
	bsr	stop_music	;stop the music
	move.l	old_base,a0	;set for new res
	bsr	set_med_rez	;set new res!
          bsr       resetoldpal    	;reset the old palette
	move.l	#mon,-(sp)	;mouse on
	clr.w	-(sp)		;zip
	move.w	#25,-(sp)		;
	trap	#14		;
	addq.l	#8,sp		;

          move.l    oldsp,-(sp)         ;reset old stack address
          move.w    #32,-(sp) 	;set in supervisor mode 
          trap      #1        	;call gamdos
          addq.l    #6,sp     	;adjust the stack

          clr.l     -(sp)     	;PTERM (Quit)
	trap	#1

***************************************************************************
* SET SUPERVISOR MODE	                                            *
***************************************************************************

set_super
	clr.l     -(sp)		;get old
          move.w    #32,-(sp)		;call supervisor
          trap      #1		;call gemdos
          addq.l    #6,sp		;adjust the stack
          move.l    d0,oldsp		;save old supervisor

	rts			;return

***************************************************************************
* SAVE THE PALETTE 						    *                                                       *
***************************************************************************

save_pal
	movem.l   $ffff8240,d0-d7     ;get entire palette
          movem.l   d0-d7,old_pal      	;save palette

	rts			;return

***************************************************************************
* RESET OLD PALETTE                                                       *
***************************************************************************

resetoldpal  
	movem.l	old_pal,d0-d7	;get our old palette
	movem.l	d0-d7,$ffff8240	;set it

          rts     			;return  

***************************************************************************
* TURN THE MOUSE OFF				 	    *
***************************************************************************

mouse_off	
	move.l	#moff,-(sp)	;mouse off
	clr.w	-(sp)		;
	move.w	#25,-(sp)		;
	trap	#14		;
	addq.l	#8,sp		;

	rts			;return

***************************************************************************
* INIT MUSIC                                                              *
* Setup the mad (And very hairy) max music 			    * 
***************************************************************************

init_music
	moveq	#1,d0		;music number one
	jsr	music		;setup music for playing

	rts			;return

***************************************************************************
* STOP MUSIC                                                              *
***************************************************************************

stop_music	
	moveq	#0,d0		;music zero
	jsr	music		;setup music 
	move.b	#8,$ffff8800	;channel A...
	clr.b	$ffff8802		;no volume
	move.b	#9,$ffff8800	;channel B...
	clr.b	$ffff8802		;no volume
	move.b	#10,$ffff8800	;channel C...
	clr.b	$ffff8802		;no volume
	
	rts			;return

***************************************************************************
* WE ARE USING THE CHUNK METHOD BECAUSE IT'S EASY!		    *
* 1 CHUNK=16 PIXELS.  2 CHUNKS=32 PIXELS ETC...			    *
***************************************************************************

draw_grass1
	moveq	#72-1,d1		;72 lines for the pic
d1
i	set	0		;set to 0
	rept	20		;repeat for 20 chunks (320 pixles)
	move.l	i(a2),i(a0)	;copy one plane
	move.l	i+4(a2),i+4(a0)	;copy the rest
i	set	i+8		;next chunk
	endr			;end of copying chunks
	add.l	#scan2,a0		;next line for screen
	add.l	#scan1,a2		;next line for piccy
	dbf	d1,d1		;end of copying lines

	rts			;return

***************************************************************************
* DRAW THE GRASS IN THE RIGHT BORDER			              *
***************************************************************************

draw_grass2
	moveq	#72-1,d1		;73 lines to copy
dl4
i	set	0		;set to 0
	rept	5		;repeat for chunks 
	move.l	i(a2),i(a0)	;copy one-plane 
	move.l	i+4(a2),i+4(a0)	;copy the rest
i	set	i+8		;next chunk
	endr			;end of copying chunks
	add.l	#scan2,a0		;next line for screen
	add.l	#scan1,a2		;next line for pic
	dbf	d1,dl4		;end of copying lines
	rts			;return

***************************************************************************
* DRAW THE DIAMOND SOFTWARE PICTURE (NOT OUT LOGO!)	              *
***************************************************************************

draw_diamond
	move.l	#diamond,a2	;get the picture
	move.l	screen,a0		;copy it to the screen
	add.l	#233*scan1,a0	;no. lines down
	add.l	#16-6,a0		;go back 3 planes and 16 pixels

	moveq	#22-1,d1		;22 lines to copy
dia
i	set	0		;set to 0
	rept	20		;repeat for chunks 
	move.l	i(a2),i(a0)	;copy one-plane
	move.l	i+4(a2),i+4(a0)	;copy the rest
i	set	i+8		;next chunk
	endr			;end of copying chunks
	add.l	#scan1,a0		;next line for screen
	add.l	#scan1,a2		;next line for picture
	dbf	d1,dia		;end of copying lines
	rts			;return

***************************************************************************
* DRAW THE ICTARI LOGO				              *
***************************************************************************

draw_ictari
	move.l	screen,a0		;copy to the screen...
	add.l	#scan1*4,a0	;lines down...
	move.l	#ictari,a2	;get the ictari
	moveq	#95-1,d1		;95 lines to copy
ic1
i	set	0		;set to 0
	rept	20		;repeat for 20 chunks 
	move.l	i(a2),i(a0)	;copy one-plane 
	move.l	i+4(a2),i+4(a0)	;copy the rest
i	set	i+8		;next chunk
	endr			;end of copying chunks
	add.l	#scan1,a0		;next line for screen
	add.l	#scan1,a2		;next line for pic
	dbf	d1,ic1		;end of copying lines
	rts			;return

***************************************************************************
* DRAW THE CREDITS ON THE SCREEN AND IN THE LEFT AND RIGHT BORDERS 	    *
***************************************************************************

draw_grass
	move.l	screen,a0		;copy to the screen...
	add.l	#scan1*120,a0
	add.l	#2,a0
	sub.l	#8*8,a0
	move.l	#grass_pic1,a2	;get the grass pic
	bsr	draw_grass1	;draw in the right & centre borders

	move.l	screen,a0		;copy to the screen...
	add.l	#scan1*121+2,a0
	sub.l	#8*8,a0
	move.l	#grass_pic2,a2	;get the grass pic
	bsr	draw_grass2	;draw in the left & centre borders

	rts			;return

***************************************************************************
* THE STRAIT SCROLLER					    *
***************************************************************************

strait	
	move.l	screen,a1		;get the screen to draw on
	add.l	#scan1*121,a1	;121 normal lines down...
	add.l	#scan2*35,a1	;then left & right border ones!!!
	move.l	#font_offsets2,a2	;get the font codes
	move.l	#font2,a3		;get the font file
	move.l	scroll_pointer2,a4	;the pointer in the text
	move.l	a4,a5		;move the pointer

	move.w	#0,d4		;clear
	moveq	#51,d5		;no accross
	move.w	char_offset2,d6	;get the char offsets
next_char2
	move.b	(a5),d7		;get the current letter
	sub.b	#32,d7		;minus 32 because we only
	ext.w	d7		;want valid characters

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#23*4,d0		;height of font * 4 bytes 
	add.w	d0,a0
	move.w	d6,d0
	mulu	#23,d0		
	add.w	d0,a0

.column2
OFF2	set	0		;err...
	REPT	23		;repeat for size of font
	move.b	(a0)+,OFF2(a1)	;draw the font on screen
OFF2	set	OFF2+scan2	;230 goto to the screen line
	endr			;finished drawing

	subq.w	#1,d5		;minus one
	beq.s	.finish2		

	addq.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip2		;if byte_toggle=0 then do next word
	addq.w	#6,a1		;else goto next word on screen
.skip2	not.w	d4
	addq.w	#1,d6		;get character offset
	and.w	#3,d6		
	bne	.column2

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is it the end of the text?
	bpl	next_char2	;no
	lea	scroll_text2,a5	;yes. reset scrolline
	bra	next_char2	;go all the way back

.finish2
	addq.w	#1,char_offset2
	and.w	#3,char_offset2
	bne.s	.end2
	addq.w	#1,a4

	tst.b	(a4)
	bpl.s	.end2
	lea	scroll_text2,a4
.end2	move.l	a4,scroll_pointer2

	rts

***************************************************************************
* SETUP ONE OF THE SMALL SCROLLERS				    *
***************************************************************************

set_small
	move.w	#4,speed		 ;speed=4
	move.l	#text_1,text_address ;message in scroll variable

	rts			 ;return

***************************************************************************
* THIS IS THE MAIN MESSAGE SCROLLER  				          *
***************************************************************************

small_scroll
	cmpi.w	#16,vvar2		;have we scrolled the letter in
				;the workspace?
	bls.s	scr6		;no. scroll the next pixel then
	clr.w	vvar2		;yes. reset the position through
				;the workspace
scr3	movea.l	text_address,a0	;get the scroll-text
	moveq	#0,d0		;clear register
	move.b	(a0)+,d0		;get the text and increment to
				;get the next letter
	cmpi.b	#$ff,d0		;end of text?
	beq	scr11		;yes. start again
scr4	move.l	a0,text_address	;no. store the letter
	cmp.b	#$20,d0		;do we have a speed
	ble	scr12		;yes. change the speed then!
scr5	subi.b	#32,d0		;get the correct ascii code
	move.l	#font,a1		;where font is loaded
	lsl.l	#5,d0		;find the character in the font
	adda.l	d0,a1		;add it to the font to get it!
	move.l	#workspace,a2	;copy to workspace
	move.l	(a1)+,(a2)+	;copy line 1
	move.l	(a1)+,(a2)+	; "    "   2 
	move.l	(a1)+,(a2)+	; "    "   3
	move.l	(a1)+,(a2)+	; "    "   4
	move.l	(a1)+,(a2)+	; "    "   5
	move.l	(a1)+,(a2)+	; "    "   6
	move.l	(a1)+,(a2)+	; "    "   7
	move.l	(a1)+,(a2)+	; "    "   8
scr6	move.w	speed,d0		;get the speed for scrolling
scr7	move.l	screen,a2		;the screen to copy on
	add.l	#235*scan1,a2	;the pos 
	add.l	#16-6,a2		;go back 3 planes, 16 pixles
	move.l	#workspace,a1	;the screen where our character
				;font is held
	moveq	#15,d1		;no. lines to scroll
scr8	lsl	(a1)+		;shift the character font to get
				;the next pixel
	roxl	$98(a2)		;scroll the screen
	roxl	$90(a2)		;from the right to
	roxl	$88(a2)		;the left.
	roxl	$80(a2)		;one-pane only
	roxl	$78(a2)		;scroll in 8 pixles
	roxl	$70(a2)		
	roxl	$68(a2)		
	roxl	$60(a2)
	roxl	$58(a2)
	roxl	$50(a2)
	roxl	$48(a2)
	roxl	$40(a2)
	roxl	$38(a2)
	roxl	$30(a2)
	roxl	$28(a2)
	roxl	$20(a2)
	roxl	$18(a2)
	roxl	$10(a2)
	roxl	8(a2)
	roxl	(a2)		;the far left
	add.l	#scan1,a2		;goto next line of screen
	dbf	d1,scr8		;scroll the next line
	addq.w	#1,vvar2		;add one so I know what posision
				;we are through the font
	dbf	d0,scr7		;scroll again according to the speed!
scr9	rts			;return

scr11	lea	text_1,a0		;at end of text, we come here 
	move.b	#32,d0		;scroll a space!
	bra	scr4		;get and scroll the space

* This was the speed, but it now contains the routines to start
* some of the routines. e.g. the rasters, picture etc...

scr12	cmp.b	#1,d0		;was it 1?
	beq	scr13		;yes. Do the rasters
	cmp.b	#2,d0		;was it 2?
	beq	scr14		;yes. Do the Ictari scroller
	cmp.b	#3,d0		;was it 3?
	beq	scr15		;yes. Play the music
	cmp.b	#4,d0		;was it 4?
	beq	scr16		;yes. Scroll this scroller!
	cmp.b	#5,d0		;was it 5?
	beq	and		;yes. draw AND pic
	cmp.b	#6,d0		;was it 6?
	beq	steven		;yes. fraw STEVEN pic
	cmp.b	#7,d0		;was it 7?
	beq	andrew		;yes. draw ANDREW pic
	cmp.b	#8,d0		;was it 8?
	beq	lighty		;yes. set disk light on stat
	cmp.b	#9,d0		;was it 9?
	beq	diamonds		;yes. draw then diamond then.
	bra	scr5		;go back 

* Here are the routines for setting the flags...

scr13	move.w	#1,colour_scroll	;1 is rasters on
	bra	scr3		
scr14	move.w	#1,scroll_eh	;1 is Ictari scroll on
	bra	scr3
scr15	move.w	#1,mus_play	;1 is music on
	bra	scr3
scr16	move.w	#4,speed		;4 is for scrolling this
	bra	scr3
diamonds	bsr	draw_diamond	;draw the diamond pic
	bra	scr3
lighty	move.w	#1,light_on	;1 is disk light on
	bra	scr3

* These routine never made it to the intro. They was going to 
* draw our names every 10 second, but I never included it. Perhaps
* you can have a go??

and				;this draws the AND pic
*	bsr	draw_and
	bra	scr3		
steven				;this draw the STEVEN pic
*	bsr	draw_steven	
	bra	scr3		
andrew				;and this one does the ANDREW pic
*	bsr	draw_andrew	
	bsr	scr3		

***************************************************************************
* THE DISK DRIVE LIGHT BOPPER!				    *
***************************************************************************

light:	movem.l	a0/a1,-(sp)	;save registers
	move.l	#$ffff8800,a0	;stick soundchip regsters
	move.l	#$ffff8802,a1	;in address registers
	move.b	#$08,(a0)
	btst	#$03,(a0)		;is the music on?
	beq	.off		;no. turn light off
.on	move.b	#$0e,(a0)		;yes. turn on the light
	move.b	#$02,(a1)
	bra	.exit		;exit now
.off	move.b	#$0e,(a0)		;turn the light off
	move.b	#$40,(a1)
.exit	movem.l	(sp)+,a0/a1	;restore registers

	rts			;return

***************************************************************************
* THE VU BARS						    *
***************************************************************************

* Removed because i did'nt like them. They used to go in the upper border,
* but i've also taken that out because it was'nt needed anymore!
*              -{ Stop complaning and do it yourself }-		    	

***************************************************************************
* SAVE AND INSTALL INTERUPTS 					    *
***************************************************************************

mfp_on:	move.l  	$120,oldtb	;save old timer B vector
	move.l  	$70,old4		;save old vb vector
	move.l  	$134,oldtimera	;old timer A
	move.b  	$fffffa07,old07	;timer B enable
	move.b  	$fffffa09,old09	;timer C enable
	move.b  	$fffffa0f,old0f	;timer B in-service
	move.b  	$fffffa11,old11	;timer C in-service
	move.b  	$fffffa1b,old1b	;timer B control
	and.b   	#$df,$fffa09	;disable timer C
	and.b   	#$fe,$fffa07	;disable timer B 
          move.b    $fffffa07,timera1   ;interupt enable a
          move.b    $fffffa13,timera2   ;interupt mask a
          move.b    $fffffa19,timera3   ;timer a control
          move.b    $fffffa1f,timera4   ;timer a data
          clr.b     $fffffa19 	;empty timer a data
          move.b    #$21,$fffffa07      ;disable interupt a
          move.b    #$21,$fffffa13      ;set mask a
          bclr      #3,$fffffa17        ;reset vector base
	move.l  	#new_vbl,$70	;new vb vector
	move.l	#left_n_right,$120	;new timer B 
	or.b    	#1,$fffffa07	;enable timer B
	or.b    	#1,$fffffa13	;set timer B mask
	rts

***************************************************************************
* RESET INTERUPTS                                                         *
***************************************************************************

mfp_off: 	move.w  	sr,-(sp)		;save 
	move.w  	#$2700,sr		;cut out all interrupts
	move.b  	old07,$fffffa07 	;restore all old vectors
	move.b  	old09,$fffffa09	;timer c enable
	move.b  	old0f,$fffffa0f	;timer b in-service
	move.b  	old11,$fffffa11	;timer c in-service
	move.b  	old1b,$fffffa1b	;timer b control
          move.b    timera1,$fffffa07   ;interupt enable a
          move.b    timera2,$fffffa13   ;interupt mask a
          move.b    timera3,$fffffa19   ;timer a control
          move.b    timera4,$fffffa1f   ;timer a data
          move.l    oldtimera,$134      ;timer a interupt
	move.l  	oldtb,$120	;old timer b
	move.l  	old4,$70		old vbl
	move.w  	(sp)+,sr		;retore
	rts			;return

***************************************************************************
* VBLANK ROUTINE                                                          *
***************************************************************************

new_vbl	
	clr.b	$fffffa1b 	;stop timer b
	move.b	#(8*15)-1,$fffffa21 ;scan line is in the border
	move.l	#left_n_right,$120  ;timer B's no border! 
	move.b 	#8,$fffffa1b        ;start timer B agian	

no_draw	move.w	mus_play,d0	;get music status
	cmp.w	#0,d0		;should we start it?
	ble.s	no_play		;no
	jsr	music+8		;yes. play music

no_play	move.w	light_on,d0	;get light status
	cmp.w	#0,d0		;should we light it?!
	ble.s	no_light		;no
	bsr	light		;do the disk light thing

no_light	move.w	scroll_eh,d0	;get the status of scrolling
	cmp.w	#0,d0		;if it's 0 then don't scroll
	ble.s	no_scroll		;scroll
	bsr	strait		;do scroller in borders
no_scroll	bsr	small_scroll

end_vbl	rte			;return from interupt

***************************************************************************
* KILL THE LEFT AND RIGHT BORDERS 				    *
* See text file to see how they work...				    *
***************************************************************************

left_n_right
	movem.l	pall,d0-d7	;get the grass palette
	movem.l	d0-d7,$fff8240	;set all the colours

	clr.b	$fffffa1b		;stop timer B
	move.w	#$2700,sr		;cut out all interupts
	move.l	#$ffff8209,a0    	;Lowbyte of video address counter
	move.l	#$ffff8260,a1    	;Picture resolution
	move.l	#$fffffa21,a3	;Timer B's data (line no.)

	moveq.w	#0,d0		;clear 
	moveq.w	#0,d1		; "
	moveq.w	#16,d2		;timer
	moveq.w	#2,d3
	moveq.w	#0,d4
	move.b	#100,(a3)		
	move.b	#8,$fffffa1b.w	
	move.b	(a3),d5
.l1	cmp.b	(a3),d5
	beq	.l1		;repeat for borders
.l2	move.b	(a0),d0
	beq.s	.l2
	sub.w	d0,d2
	lsl.w	d2,d1
	clr.b	$fffffa1b.w	;stop timer B (ohh)
	rept	87		;lots of nop's
	nop			;nop!
	endr			;no more nop's
	lea	$ffff820a.w,a0
	move.w	#70,d0		;number of lines to zap
.l3	nop			;one clycle
	move.b	d3,(a1)
	move.b	d4,(a1)
	rept	89		;ohh, more nop's
	nop			;nop!!!!
	endr			;no more nop's
	move.b	d4,(a0)
	move.b	d3,(a0)

	rept	13
	nop			;and another
	endr
	move.b	d3,(a1)
	nop
	move.b	d4,(a1)
	rept	9		;not so many nop's!
	nop			;gues what?
	endr			;no more nop's (phew)
	dbf	d0,.l3		;end of repeat
	bclr	#0,$fffffa0f.w	;up and running timer B

	movem.l	diamond_pal,d0-d7	;set the diamond software
	movem.l	d0-d7,$fff8240	;palette

	clr.b	$fffffa1b 	;stop timer b
	move.b	#7,$fffffa21 	;scan line is in the border
	move.l	#bottom1,$120  	;timer B's no border! 
	move.b 	#8,$fffffa1b        ;start timer B agian	

	rte			;return from interupt

***************************************************************************
* BOTTOM BORDER REMOVING ROUTINE                                          *
***************************************************************************

bottom1	
	clr.b 	$fffffa1b.w	;stop timer b
	movem.l 	d0/a0,-(a7)	;save registers
	move.w 	#$fa21,a0		;data
	move.b 	#2,(a0)		;any number 
	move.b 	#8,$fffffa1b.w	;start timer b
	move.b 	(a0),d0		;load
	move.l 	#bottom3,$120.w	;other timer b...
.l1	cmp.b 	(a0),d0		;wait for scanline 
	beq 	.l1		;finished
	clr.b 	$fffff820a.w	;60 hz
	moveq.w 	#3-1,d0		;wait a while
.l2	nop			;pause
	dbf 	d0,.l2		;done
	move.b 	#2,$fffff820a.w	;50hz removes the lower border
	clr.b 	$fffffa1b.w	;stop timer b
	move.b 	#2,$fffffa21.w	;data
	move.b 	#8,$fffffa1b.w	;start timer b
	movem.l 	(a7)+,d0/a0	;retore registers	
	bclr 	#0,$fffffa0f.w	;clear timer b in-service
	rte			;return (from interupt) 

bottom3	
	move.w	colour_scroll,d0	;get raster status
	cmp.w	#0,d0		;if it's zero then...
	ble.s	no_colour		;don't do any raster cols
	move.l	#text_col0,$120  	;timer B's no border! 
	bclr 	#0,$fffffa0f	;clear
	rte			;back we go

no_colour	
	move.w	diamond_pal+2,$ffff8242
	move.w	diamond_pal+2,$ffff8246
	move.w	diamond_pal+2,$fff824a
	move.w	diamond_pal+2,$fff824e
	move.w	diamond_pal+2,$fff8252
	clr.b	$fffffa1b 	;stop timer b
	move.b	#23,$fffffa21 	;next timer B 20 lines down for...
	move.l	#text_col9,$120	;restoring the Ictari palette
	move.b 	#8,$fffffa1b        ;start timer B agian	
	bclr 	#0,$fffffa0f	;clear timer B
	rte			;return


***************************************************************************
* THE COLOURS FOR THE SCROLL TEXT                                         *
* The colours have to be copied to more than one colour because of the    *
* Diamond Software picture.					    * 
***************************************************************************

text_col0	move.w	pal1,$fff8242	;copy pal to colour 1 
	move.w	pal1,$fff8246	;copy pal to colour 3 
	move.w	pal1,$fff824a	;copy pal to colour 5 
	move.w	pal1,$fff824e	;copy pal to colour 7 
	move.w	pal1,$fff8252	;copy pal to colour 9 
	move.l 	#text_col1,$120	;goto next raster
	bclr 	#0,$fffffa0f	;clear timer B
	rte			;return from interupt

text_col1	move.w	pal1+2,$ffff8242	;all this is just the same
	move.w	pal1+2,$ffff8246	;as above apart from i'm
	move.w	pal1+2,$fff824a	;geting the next raster
	move.w	pal1+2,$fff824e	;colour. 
	move.w	pal1+2,$fff8252
	move.l 	#text_col2,$120
	bclr 	#0,$fffffa0f
	rte

text_col2	move.w	pal1+4,$ffff8242
	move.w	pal1+4,$ffff8246
	move.w	pal1+4,$fff824a
	move.w	pal1+4,$fff824e
	move.w	pal1+4,$fff8252
	move.l 	#text_col3,$120
	bclr 	#0,$fffffa0f
	rte

text_col3	move.w	pal1+6,$ffff8242
	move.w	pal1+6,$ffff8246
	move.w	pal1+6,$fff824a
	move.w	pal1+6,$fff824e
	move.w	pal1+6,$fff8252
	move.l 	#text_col4,$120
	bclr 	#0,$fffffa0f
	rte

text_col4	move.w	pal1+8,$ffff8242
	move.w	pal1+8,$ffff8246
	move.w	pal1+8,$fff824a
	move.w	pal1+8,$fff824e
	move.w	pal1+8,$fff8252
	move.l 	#text_col5,$120
	bclr 	#0,$fffffa0f
	rte

text_col5	move.w	pal1+10,$ffff8242
	move.w	pal1+10,$ffff8246
	move.w	pal1+10,$fff824a
	move.w	pal1+10,$fff824e
	move.w	pal1+10,$fff8252
	move.l 	#text_col6,$120
	bclr 	#0,$fffffa0f
	rte

text_col6	move.w	pal1+12,$ffff8242
	move.w	pal1+12,$ffff8246
	move.w	pal1+12,$fff824a
	move.w	pal1+12,$fff824e
	move.w	pal1+12,$fff8252
	move.l 	#text_col7,$120
	bclr 	#0,$fffffa0f
	rte

text_col7	move.w	pal1+14,$ffff8242
	move.w	pal1+14,$ffff8246
	move.w	pal1+14,$fff824a
	move.w	pal1+14,$fff824e
	move.w	pal1+14,$fff8252
	move.l 	#text_col8,$120
	bclr 	#0,$fffffa0f
	rte

text_col8	move.w	pal1+16,$ffff8242
	move.w	pal1+16,$ffff8246
	move.w	pal1+16,$fff824a
	move.w	pal1+16,$fff824e
	move.w	pal1+16,$fff8252
	move.l 	#text_col9,$120
	bclr 	#0,$fffffa0f
	rte

text_col9	move.w	pal1+18,$ffff8242
	clr.b	$fffffa1b 	;stop timer b
	move.b	#5,$fffffa21 	;next timer B 10 lines down
	move.l	#restore_pal,$120   ;restore Ictari palette
	move.b 	#8,$fffffa1b        ;start timer B agian	
	bclr 	#0,$fffffa0f	;clear timer B
	rte			;return

restore_pal
	movem.l	ictari_pal,d0-d7	;get the Ictari pal
	movem.l	d0-d7,$fff8240	;set all the colours
	bclr 	#0,$fffffa0f	;clear timer B
	rte			;return

***************************************************************************
* DRAW THE CREDITS PICTURE - 42 LINE HIGH			    *
***************************************************************************

draw_cred
	moveq	#42-1,d1		;lines
drl1
i	set	0		;set to 0
	rept	20		;repeat for chunks
	move.l	i(a0),i(a1)	;copy 1st half of a chunk (logical)
	move.l	i+4(a0),i+4(a1)	;copy 2nd half a chunk (logical)
i	set	i+8		;next chunk
	endr			;end of copying chunks
	add.l	#160,a0		;next line for logical
	add.l	#160,a1		;next line for piccy
	dbf	d1,drl1		;end of copying lines

	rts

***************************************************************************
* DRAW THE CREDITS FOR THE INTRO				    *
***************************************************************************

pause	equ	40		;delay time for each credit

draw_credits
	move.l	#pc1_credits,a0	;get our PC1 piccy
	move.l	#out_pal,a1	;the output palette
	move.l	#out_pic,a2	;the output piccy
 	bsr	unpack_pc1	;unpack piccy

i	set	0
	rept	3

	move.l	#black,a6
	move.l	#2,d6
	bsr	fade
	bsr	cls

	move.l	#out_pic,a0	
	add.l	#160*i,a0		
	move.l	screen,a1
	add.l	#85*160,a1
	bsr	draw_cred

	move.l	#cred_pal1,a6
	move.l	#2,d6
	bsr	fade
	wait	pause/2
	move.l	#cred_pal2,a6
	move.l	#2,d6
	bsr	fade

	wait	pause

i	set	i+43
	endr

	move.l	#black,a6
	move.l	#2,d6
	bsr	fade
	bsr	cls

	rts

***************************************************************************
* CLEAR THE SCREEN						    *
***************************************************************************

cls
	move.w	#16000-1,d0	;set up a loop counter
	move.l	screen,a0		;get the screen
.cls_loop	move.w	#0,(a0)+		;put a nought in that location, 
				;then increment
	dbra	d0,.cls_loop	;repeat 16000 times

	rts			;return

***************************************************************************
* UNPACKING PC1 ROUTINE BY THE HIGHLANDER!			    *
***************************************************************************

unpack_pc1
	addq.l	#2,a0		;skip resolution of pic.
	move.l	(a0)+,(a1)+	;copy over palette.
	move.l	(a0)+,(a1)+	;should use movem, but...
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

; now the picture area to be uncompressed.

; 0 <=n<=127	;n>=0 and n<=127 then no rept for n+1
; -127<=n<=-1	;n>=-127 and n<=-1 then rept for -n+1
; n=-128 		;no operation.

	move.w	#199,d7		;lines 
.UNCOMP0:	moveq.w	#3,d6
.UNCOMP1:	move.l	#_DEGASBUFF,a3
.UNCOMP2:	move.b	(a0)+,d0
	ext.w	d0
	cmp.b	#-128,d0		;ignore.
	beq	.UNCOMP2
	cmp.b	#-1,d0
	ble	.REPT
.LOOP1:	move.b	(a0)+,(a3)+	;no repeat.
	dbra	d0,.LOOP1
	cmp.l	#_DEGASBUFF+40,a3
	blt	.UNCOMP2
	bra	.DUMP_SCANLINE
.REPT:	neg.w	d0
	move.b	(a0)+,d1
.LOOP2:	move.b	d1,(a3)+		;repeat.
	dbra	d0,.LOOP2
	cmp.l	#_DEGASBUFF+40,a3
	blt	.UNCOMP2

.DUMP_SCANLINE:	
	move.l	#_DEGASBUFF,a3	;dump completed 
	move.l	a2,a6		;uncompressed scan line
	REPT	20		;copy 20 chunks (320 pixels)
	move.w	(a3)+,(a2)+
	addq.l	#6,a2
	ENDR
	lea	2(a6),a2
	dbra	d6,.UNCOMP1
	add.l	#152,a2
	dbra	d7,.UNCOMP0

	rts

***************************************************************************
* COLOUR FADING - A6=PALETTE / D6=SPEED				    *
* This is by Poweman of The Wild Boys (nice demos)		    *
***************************************************************************

fade
	move.l 	$70.w,-(a7)
	move.w 	sr,-(a7)
	move.w 	#$2300,sr
	move.l 	#fade_vbl,$70.w
	moveq.w 	#8-1,d0					
.l1	moveq.w 	#16-1,d1		;16 colours
	move.l 	#$ffff8240,a0
	move.l 	a6,a5
.l2	move.w 	(a0),d2
	andi.w 	#%0000011101110111,d2
	move.w 	(a5)+,d7
	bsr 	fade_d2_to_d7
	move.w 	d2,(a0)+
	dbf 	d1,.l2
	move.w 	d6,d5
.l3	bsr 	wait_vbl
	dbf 	d5,.l3
	dbf 	d0,.l1	
	move.w 	(a7)+,sr
	move.l 	(a7)+,$70.w
	rts

fade_d2_to_d7	
	movem.l 	d0-d1,-(a7)
	move.w 	d2,d3
	andi.w 	#$f,d2
	lsr.w 	#4,d3
	move.w 	d3,d4
	andi.w 	#$f,d3
	lsr.w 	#4,d4	;d2,d3,d4=r,g,b values of old colour
	andi.w 	#$f,d4
	move.w 	d7,d0
	andi.w 	#$f,d7
	lsr.w 	#4,d0
	move.w 	d0,d1
	andi.w 	#$f,d0
	lsr.w 	#4,d1	;d7,d0,d1=r,g,b values of new colour
	andi.w 	#$f,d1

	cmp.w 	d2,d7
	beq 	.l2
	blt 	.l1
	addq.w 	#1,d2
	bra 	.l2
.l1	subq.w 	#1,d2	
.l2	cmp.w 	d3,d0
	beq 	.l22
	blt 	.l11
	addq.w 	#1,d3
	bra 	.l22
.l11	subq.w 	#1,d3	
.l22	cmp.w 	d4,d1
	beq 	.l222
	blt 	.l111
	addq.w 	#1,d4
	bra 	.l222
.l111	subq.w 	#1,d4	
.l222	lsl.w 	#4,d3
	lsl.w 	#8,d4
	or.w 	d3,d2
	or.w 	d4,d2		
	movem.l 	(a7)+,d0-d1
	rts		

wait_vbl	clr.b 	vbl_flag
.l1	tst.b 	vbl_flag
	beq 	.l1	
	rts

vbl_flag	ds.w 	1
fade_vbl	st 	vbl_flag	
	rte  

***************************************************************************
* CLEAR THE KEYBOARD 							    *
***************************************************************************

flush	btst.b	#0,$fffffc00	;clear keyboard buffer
	beq.s	flush2		;wait until it's cleared
	move.b	$fffffc02,d0		
	bra.s	flush
flush2	rts

***************************************************************************
* SET-UP SCREEN						    *
***************************************************************************

set_up	move.l	#screens,d0
	clr.b	d0
	move.l	d0,screen
	move.l	d0,d1
	add.l	#41984,d1
	eor.l	d0,d1
	move.l	d1,scr_xor
	rts

***************************************************************************
* NOW SET THE SCREEN PROPER					    *
***************************************************************************

set_screen
	move.l	#screen,a6
	move.l	(a6),d6
	move.l	d6,4(a6)
	move.l	scr_xor,d0
	eor.l	d0,d6
	move.l	d6,screen
	lsr.l	#8,d6
	move.l	#$ffff8201,a5
	movep.w	d6,(a5)
	rts

***************************************************************************
* GET THE OLD BASE!						    *
***************************************************************************

get_base
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts

***************************************************************************
* SET MEDIUM RES						    *
***************************************************************************

set_med_rez
	move.w	#1,-(sp)		;1 is medium
	bra.s	set_rez

set_low_rez
	clr.w	-(sp)		;zero is low
set_rez	move.l	a0,-(sp)		;get the screen
	move.l	a0,-(sp)		; "
	move.w	#5,-(sp)		;get rez
	trap	#14		;call XBIOS
	add.l	#12,sp		;adjust stack

	rts			;return


***************************************************************************
* DIAMOND SOFTWARE'S INTRO SCROLLER 		    		    *
* ----------------------------------------------------------------------- *
* 1 - START COLOURS IN BOTTOM BORDER SCROLL TEXT			    *
* 2 - START SCROLLER IN LEFT AND RIGHT BORDERS			    *
* 3 - START CHIP MUSIC AND DISK LIGHT BOPPER			    *
* 4 - SCROLL THE ER, SCROLL-TEXT				    *
* 5 - DRAW THE AND PICCY *					    *
* 6 - DRAW THE STEVEN PICCY *					    *
* 7 - DRAW THE ANDREW PICCY *					    *
* 8 - START DISK LIGHT BOPPER					    *
* 9 - DRAW THE DIAMOND SOFTWARE PICCY				    *
***************************************************************************

text_1	DC.B	4,"              URRRH... THIS INTRO IS UGLY.. "
	DC.B	"                   ",3,"                 NI"
	DC.B	"CE MUSIC, BUT WHAT ABOUT A BIT OF CO"
	DC.B	"LOUR IN THIS SCROLL-TEXT?           "
	DC.B	"     ",1,"        HMM,  IT'S LOOKING"
	DC.B	" GOOD.    I SUPOSE YOU'RE WONDERING "
	DC.B	"WHO CODED THIS INTRO?    WELL, IT WA"
	DC.B	"S CODED BY ..                   ",9
	DC.B	"            OK, LETS DO THIS MONTHS "
	DC.B	"ICTARI SCROLL-TEXT............      "
	DC.B	"   ",2,"            "
	DC.B	"   STILL HERE?  OK, LETS DO THE CRED"
	DC.B	"ITS FOR THIS INTRO.... CODING : STEV"
	DC.B	"EN JORDAN.... MUSIC : MAD MAX.... GR"
	DC.B	"APHICS : STEVEN JORDAN AND THE DEMON"
	DC.B	" X                "
	DC.B	"THIS INTRO TOOK ABOUT TWO WEEKS"
	DC.B	" TO CODE!! THIS WAS BECAUSE I'M SOO L"
	DC.B	"AZZY!  AND THEN IN STEVEN JORDAN'S ST"
	DC.B	"YLE - I CHANGED IT FOR FASTER SPEED A"
	DC.B	"ND MORE PROCESSOR TIME TO DO OTHER TH"
	DC.B	"INGS LIKE - VU METERS, FIVE PALETTE S"
	DC.B	"WITHCHES AND ALL COLOUR RASTER IN ABO"
	DC.B	"UT TWENTY LINES INSTEAD OF 50!       "
	DC.B	" I WAS GOING TO INCLUDE ONE OF MY VER"
	DC.B	"Y OWN SINE-WAVING BARREL ROLLERS, BUT"
	DC.B	" I THOUGHT THAT I'D KEED IT FOR ANOTH"
	DC.B	"ER TIME.             "

	DC.B	"OK, I'VE GOT TO GO NOW BECAUSE I HAVE"
	DC.B	" TO GO ON THE PLANE FOR MY HOLIDAY.  "
	DC.B	"  SEE YA SOON.         STEVEN J      "
	DC.B	"               "
	DC.B	"  LETS WRAP                         "

	DC.B	$FF

***************************************************************************
* DIAMOND SOFTWARE'S SCROLLER					    *
***************************************************************************

scroll_pointer2	dc.l	scroll_text2
scroll_text2
	DC.B	"               "
	DC.B	"HI, WELCOME TO THE ICTARI INTRO CODED "
	DC.B	"BY DIAMOND SOFTWARE.     "
	DC.B	"                                      "
 	DC.B 	$FF

***************************************************************************

pc1_credits	incbin	"a:\assembly\intro\credits1.pc1"
* pc1_names	incbin	"a:\assembly\intro\names.pc1"
ictari		incbin	"a:\assembly\intro\ictari.obj"
grass_pic1	incbin	"a:\assembly\intro\leftgras.obj"
grass_pic2	incbin	"a:\assembly\intro\rit_gras.obj"
diamond		incbin	"a:\assembly\intro\diamond3.obj"
music		incbin	"a:\assembly\intro\reset.mus"

diamond_pal
	dc.w	$0000,$0707,$0777,$0707,$0555,$0707,$0444,$0707
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0777
ictari_pal
	dc.w	$0000,$0313,$0212,$0700,$0720,$0600,$0002,$0003
	dc.w	$0004,$0111,$0222,$0333,$0444,$0555,$0500,$0766
pall	dc.w	$0000,$0777,$0010,$0777,$0020,$0777,$0021,$0777
	dc.w	$0031,$0777,$0141,$0777,$0050,$0777,$0152,$0777
black	dc.w	$000,$000,$000,$000,$000,$000,$000,$00
	dc.w	$000,$000,$000,$000,$000,$000,$000,$00
white	dc.w	$000,$777,$777,$777,$777,$777,$777,$777	
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777	
pal1	dc.w	$400,$500,$600,$700,$701,$712,$723,$734,$735
cred_pal1	dc.w	$0000,$0210,$0321,$0432,$0543,$0654,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
cred_pal2	dc.w	$0000,$0210,$0321,$0432,$0543,$0654,$0000,$0000
	dc.w	$0000,$0000,$0210,$0321,$0432,$0543,$0654,$0777

mus_play	dc.w	0
scroll_eh	dc.w	0
light_on	dc.w	0
vu_on	dc.w	0
diamond_on	dc.w	0
colour_scroll	dc.w	0

***************************************************************************
* THIS PART SAVES DISK SPACE					    *
***************************************************************************

	section bss

out_pal		ds.b	32
out_pic		ds.b	32000
_DEGASBUFF	ds.b	40
old_pal:		ds.b	32		;old palette
screen		ds.l	1
		ds.l	1
scr_xor		ds.l	1
oldsp    		ds.l	1		;old stack pointer
zero_counter	ds.w	1
counter		ds.b	1
		ds.l	100
ustack		ds.l	1
		ds.b	256
screens		ds.b	41984
		ds.b	41984

	section	data


***************************************************************************

old_base	dc.l	0		;old base
mon	dc.b    	8		;code for mouse on
moff	dc.b    	18		;code for mouse off
old4:    	dc.l    	0
oldtb:   	dc.l    	0
old07:   	dc.b    	0
old09:    dc.b    	0
old0f:    dc.b    	0
old11:    dc.b    	0
old1b:    dc.b    	0
oldtimera	dc.l	0
timera1:  dc.l    	0
timera2:  dc.l    	0
timera3:  dc.l    	0
timera4:  dc.l    	0	
char_offset2	dc.w	0	
font2		dcb.b	23*4,0
		incbin	"a:\assembly\intro\font.dat"

font_offsets2
 dc.b	0,44,43,00,45,00,42,51,46,47,00,00,49,00,48,29
 dc.b	41,31,32,33,34,35,36,37,38,39,59,58,00,00,00,43,00
 dc.b	01,02,03,04,05,06,07,08,09,11,12,13,14,15,16,17,18
 dc.b	19,21,22,23,24,25,26,27,28,46,00,47,00,47,00,01,02,03
 dc.b	04,05,06,07,08,09,11,12,13,14,15,16,17,18,19,21,22,23
 dc.b	24,25,26,27,28,46,00,47,00

handle		dc.w	0

		ds.w	48

vvar2		ds.w	1
text_address	ds.l	6
workspace		ds.l	8	dummy screen for 2 scrollers
speed		ds.w	1
mus		ds.w	2

line_one	ds.l	1
old_screen_pos  	dc.l 	0
		ds.w	8

font		incbin	"a:\assembly\intro\font_02.dat",0
		ds.w	24	spare

 	format 	0-,1-,2-
 	list 	+

***************************************************************************
*							    *
*   Ictari Intro #8     - Source code (c) Diamond Software 1993	    *
*   Graphics            - Steven Jordan & The Demon X (TWB)		    *
*   Programming         - Steven Jordan			              *
*   Nice Music	    - Mad Max				    *
*							    *
***************************************************************************

	list	-



