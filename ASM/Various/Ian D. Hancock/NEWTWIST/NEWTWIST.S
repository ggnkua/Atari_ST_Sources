* Serial number: 0359477910

 **********************************************
*        The twist scroll	(Low Rez)	       *
*     Coding January 1989 by manikin           *
*	  of the lost boys                   *
*		    		       *
*  To contact us:	12 Cambridge Rd	       *
*		Teddington	       *
*		Middx		       *
*		TW11 8DR		       *
*				       *  
*    Set TABS to 10			       *
 **********************************************
* Adjusted for medium resolution by            *
*         I.D.Hancock                          *
*                                              *
* Now loads message from text file. SCROLL.TXT *
* (Sorry about the 2 spaces for a CR-LF but    *
* I got bored. I tried a piccy in the backgrnd *
* but The Lost Boys use XOR to show the scroll *
* so I changed my mind. Just lazy really :(  ) *
* Which should be less than 10k, unless you    *
* change the last line of this code !          *
* Uses screen memory from the program and not  *
* fixed screen memory. Simplifies the screen   *
* swap routine which was well lame before :)   *
* Restores the colours which it changes.       *
* Should work on any config of ST ? not tested *
*                                              *
* Alterations made for iCTARi in 1994          *
* Written on 4Mb STE using Devpac 2.25         *
 **********************************************
start	
	dc.w 	$a00a		lose mouse

	clr.l 	-(sp)		set supervisor
	move 	#$20,-(sp)
	trap 	#1
	add.l 	#6,sp
	move.l 	d0,oldssp

* Sort out the scrolls text
* pad start of scroll with spaces
	movea.l	#scrolline,a1	start of scroll address
	move.w	#21,d0		loop counter for 22 spaces
spaceloop
	move.b	#$20,(a1)+
	dbra	d0,spaceloop
	
* load in the text file "scroll.txt"
	move.w	#0,-(sp)	  	load a file
	move.l	#fname,-(sp)	with file name
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	
	move.l	d0,d2		file handle
	
	move.l	#thescroll,-(sp)	data start address
	move.l	#maxlength,-(sp)	max data length in bytes
	move.w	d2,-(sp)		file handle
	move.w	#$3f,-(sp)	load block to memory
	trap	#1
	add.l	#12,sp

* Remove all CR LF's and replace with spaces and
* pad end of message with gaps and put a $ff at the end	
	movea.l	#thescroll,a0	get message w/o spaces in a0
	move.l	a0,a1		and in a1
	add.l	d0,a1		end of the text in a1
	
replaceloop
	cmp.b	#$0d,(a0)
	bne	not_crlf
	
	move.b	#$20,(a0)+
	move.b	#$20,(a0)
not_crlf
	addq.l	#1,a0
	
	cmp.l	a1,a0
	bls	replaceloop
	
* do the padding
	move.w	#21,d0		counter for space padding
spaceloop2
	move.b	#$20,(a1)+
	dbra	d0,spaceloop2
	
	move.b	#$ff,(a1)		put an ff at the end of the text
	
	move.w	d2,-(sp)		close file, file handle
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp

* Sort out the screen resolution	
* get current resolution
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	
	cmp.w	#1,d0		are we in medium res
	bne	cur_lo_res	already in low res
	
* go into lo res
	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	move.w	#1,(old_res)	flag medium res originally
	bra	res_sorted

cur_lo_res
	move.w	#-1,(old_res)	flag low res originally
*				ie. don't change to med on exit
res_sorted

* calculate the screen addresses. STFM needs them to be 256 byte
* boundary aligned :(
	move.l	#screenspace,d0
	clr.b	d0
	move.l	d0,screen
	add.l	#32000,d0
	move.l	d0,screen1
* screens calculated.

	bsr 	makefonts		make up the fonts

	move 	#2,-(sp)		get physbase
	trap 	#14	
	add.l 	#2,sp
	move.l 	d0,savescrn

* set up some colours
	move.l	$ff8240,colpal1	remember some old colors
	move.l	$ff8244,colpal2	"
	
*                     bRGBlRGB	background,letter_foreground
	move.l 	#$00000070,$ff8240	set a few colors
	
*                     lRGBcRGB	let_background,let_crossover
	move.l 	#$07770070,$ff8244

 ****************************
*     the main loop          *
 ****************************

vbloop	
* swap the screens
	move.l 	screen1,d0	screen1=physbase
	move.l 	screen,screen1	swap screens. NB:screen=logbase
	move.l	d0,screen		complete swap
	
	move 	#-1,-(sp)		set screens using xbios 5
	move.l 	screen1,-(sp)	phys
	move.l 	screen,-(sp)	log
	move 	#5,-(sp)
	trap 	#14
	add.l 	#12,sp

	move 	#2,-(sp)		any keys waiting
	move 	#1,-(sp)
	trap 	#13
	addq.l 	#4,sp
	tst 	d0		test for key
	bne	twistend		yes then exit the twist scroll

	move 	#37,-(sp)		wait for vbl
	trap 	#14
	add.l 	#2,-(sp)

	add.l	#8640,fonttype	take the next font
	cmp.l 	#fontend,fonttype	is it past the last font?
	bne 	cont		if no then continue
	move.l 	#font1,fonttype	else reset font pointer to first font
	add.l 	#1,scrollpnt	advance scrolline by 1 character
	move.l 	scrollpnt,a6	get scroll
	clr.l 	d6
	move.b 	(a6)+,d6			
	cmp.b 	#$ff,21(a6)	test for end of scrolline
	bne 	cont		no then continue
	move.l 	#scrolline,scrollpnt	else restart scroll

 ********************************************************
* Well this is the actual scrolline. each character is   *
* is put on the screen by its own little routine.        *
* which puts its character to a particular point in the  *
* buffer. The first part of the character is added to    *
* the screen while the second part is moved straight to  *
* the screen. ie first word added second word moved      *
* this is done (in general) for the first 29 lines but   *
* as each character is 8 lines lower than the last the   *
* last 8 lines would be added to themselves as the       *
* previous character would not have cleared the screen   *
* with its own character.       If you can understand    *
* this bit then you have the key to the twist scroll.    *
* take your time it will all become clear.	       *
* The scroll was worked out very carefully originally    *
* so that where a character extends over the bottom of   *
* the buffer it is drawn over at the top. This is done   *
* in the dbra loops so you'll have to study them         *
* carefully to see where.			       *
 ********************************************************

cont	move.l 	scrollpnt,a6	get scroll pointer
	move.l 	fonttype,a0	get fonttype
	clr.l 	d6
	move.b 	(a6)+,d6		get character
	sub.b 	#32,d6
	mulu 	#144,d6		get offset for this character in font
	add.l 	d6,a0
	move.l 	screen,a1		
	add.l 	#32,a0
	move 	#29-1,d0		do 29 lines
f_draw	add.l 	#2,a0		this is the first character
	move 	(a0)+,(a1)	so only the second half is drawn 
	add.l 	#160,a1		on the screen.
	dbra 	d0,f_draw

	move.l 	fonttype,a0	as above
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	move 	#28,d0		do 29 lines
f_draw1c	move 	(a0)+,d5		
	add 	d5,(a1)		add to screen
	move 	(a0)+,8(a1)	move to screen 
	add.l 	#160,a1
	dbra 	d0,f_draw1c
	
	move 	#7,d0		do another 8 lines
f_draw1d	move 	(a0)+,(a1)	move to screen
	move 	(a0)+,8(a1)	add to screen
	add.l 	#160,a1
	dbra 	d0,f_draw1d

 ***********************************************
* Construction of buffer continues as above     *
* with appropriate offsets etc                  *
 ***********************************************

	move 	#28,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#1288,a1
f_draw1	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw1
	
	move 	#7,d0
f_draw1b	move 	(a0)+,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw1b
	
	move 	#28,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#2576,a1
f_draw2	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw2
	
	move 	#7,d0
f_draw2b	move 	(a0)+,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw2b
	
	move 	#28,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#3864,a1
f_draw3	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw3
	
	move 	#7,d0
f_draw3b	move 	(a0)+,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw3b
	
	move 	#28,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#5152,a1
f_draw4	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw4
	
	move 	#7,d0
f_draw4b	move 	(a0)+,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw4b
	
	move 	#28,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#6440,a1
f_draw5	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw5
	
	move 	#7,d0
f_draw5b	move 	(a0)+,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw5b
	
	move 	#28,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#7728,a1
f_draw6	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw6
	
	move 	#2,d0
f_draw6b	move 	(a0)+,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw6b
	
	move 	#4,d0
f_draw6c	move 	(a0)+,-12800(a1)
	move 	(a0)+,-12792(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw6c
	
	move 	#23,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#9016,a1
f_draw7	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw7
	
	move 	#4,d0
f_draw7c	move 	(a0)+,d5
	add 	d5,-12800(a1)
	move 	(a0)+,-12792(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw7c
	
	move 	#7,d0
f_draw7b	move 	(a0)+,-12800(a1)
	move 	(a0)+,-12792(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw7b
	
	move 	#15,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#10304,a1
f_draw8c	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw8c
	
	move 	#12,d0
f_draw8	move 	(a0)+,d5
	add 	d5,-12800(a1)
	move 	(a0)+,-12792(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw8
	
	move 	#7,d0
f_draw8b	move 	(a0)+,-12800(a1)
	move 	(a0)+,-12792(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw8b
	
	move 	#7,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#11592,a1
f_draw9	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw9
	
	move 	#20,d0
f_draw9b	move 	(a0)+,d5
	add 	d5,-12800(a1)
	move 	(a0)+,-12792(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw9b
	
	move 	#7,d0
f_draw9c	move 	(a0)+,-12800(a1)
	move 	(a0)+,-12792(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw9c
	
	move 	#28,d0
	move.l 	fonttype,a0
	clr.l 	d6	
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#80,a1
f_draw10	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw10
	
	move 	#7,d0
f_draw10c	move 	(a0)+,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw10c
	
	move 	#28,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#1368,a1
f_draw11	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw11
	
	move 	#7,d0
f_draw11b	move 	(a0)+,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw11b
	
	move 	#28,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#2656,a1
f_draw12	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw12
	
	move 	#7,d0
f_draw12b	move 	(a0)+,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw12b
	
	move 	#28,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#3944,a1
f_draw13	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw13
	
	move 	#7,d0
f_draw13b	move 	(a0)+,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw13b
	
	move 	#28,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#5232,a1
f_draw14	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw14
	
	move 	#7,d0
f_draw14b	move 	(a0)+,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw14b
	
	move 	#28,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#6520,a1
f_draw15	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw15
	
	move 	#7,d0
f_draw15b	move 	(a0)+,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw15b
	
	move 	#28,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#7808,a1
f_draw16	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw16
	
	move 	#2,d0
f_draw16b	move 	(a0)+,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw16b
	
	move 	#4,d0
f_draw16c	move 	(a0)+,-12800(a1)
	move 	(a0)+,-12792(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw16c
	
	move 	#23,d0
	move.l 	fonttype,a0
	clr.l 	d6	
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#9096,a1
f_draw17	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw17
	
	move 	#4,d0
f_draw17c	move 	(a0)+,d5
	add 	d5,-12800(a1)
	move 	(a0)+,-12792(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw17c
	
	move 	#7,d0
f_draw17b	move 	(a0)+,-12800(a1)
	move 	(a0)+,-12792(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw17b
	
	move 	#15,d0
	move.l 	fonttype,a0
	clr.l 	d6
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#10384,a1
f_draw18	move 	(a0)+,d5
	add 	d5,(a1)
	move 	(a0)+,8(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw18
	
	move 	#12,d0
f_draw18c	move 	(a0)+,d5
	add 	d5,-12800(a1)
	move 	(a0)+,-12792(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw18c
	
	move 	#7,d0
f_draw18b	move 	(a0)+,-12800(a1)
	move 	(a0)+,-12792(a1)
	add.l 	#160,a1
	dbra 	d0,f_draw18b
	
	move 	#7,d0		the last character is added 
	move.l 	fonttype,a0	only to the first word
	clr.l 	d6		the second is discarded.
	move.b 	(a6)+,d6
	sub.b 	#32,d6
	mulu 	#144,d6
	add.l 	d6,a0
	move.l 	screen,a1
	add.l 	#11672,a1
f_draw19	move 	(a0)+,d5
	add 	d5,(a1)
	add.l 	#2,a0
	add.l 	#160,a1
	dbra 	d0,f_draw19
	
	move 	#20,d0
f_draw19c	move 	(a0)+,d5
	add 	d5,-12800(a1)
	add.l 	#2,a0
	add.l 	#160,a1
	dbra 	d0,f_draw19c
	
	move 	#7,d0
f_draw19b	move 	(a0)+,-12800(a1)
	add.l 	#2,a0
	add.l 	#160,a1
	dbra 	d0,f_draw19b
	
	bsr 	construct
	bra	vbloop

 *******************************************
* Now this is where the scroll is actually  *
* constructed. this is done by copying the  *
* the buffer to the screen once the right   *
* way up in plane 1 then upside down and    *
* in plane 2 to the screen. A table tells   *
* the routine how many times to display     *
* each line of the buffer. By missing or    *
* or displaying some lines twice it is easy *
* to give the appearance of wrapping the    *
* scroll around a bar.                      *
 *******************************************

construct	move.l 	screen,a1
	move.l 	a1,a0
	add.l 	#16000,a1		start scroll 100 lines down screen
	move.l 	a1,a3
	add.l 	#10722,a3		start the upside down bit further down and in plane2
	move.l 	#addtab,a2	the addtable (for controlling the drawing of scroll)
	move 	#67,d0		do 68 lines
cnstruct1	move	(a0),(a1)	copy buffer to screen
	move 	8(a0),8(a1)
	move 	16(a0),16(a1)
	move 	24(a0),24(a1)
	move 	32(a0),32(a1)
	move 	40(a0),40(a1)
	move 	48(a0),48(a1)
	move 	56(a0),56(a1)
	move 	64(a0),64(a1)
	move 	72(a0),72(a1)
	move 	80(a0),80(a1)
	move 	88(a0),88(a1)
	move 	96(a0),96(a1)
	move 	104(a0),104(a1)
	move 	112(a0),112(a1)
	move 	120(a0),120(a1)
	move 	128(a0),128(a1)
	move 	136(a0),136(a1)
	move 	144(a0),144(a1)
	move 	152(a0),152(a1)
	move 	(a0),(a3)		move buffer to plane 2 
	move 	8(a0),8(a3)
	move 	16(a0),16(a3)
	move 	24(a0),24(a3)
	move 	32(a0),32(a3)
	move 	40(a0),40(a3)
	move 	48(a0),48(a3)
	move 	56(a0),56(a3)
	move 	64(a0),64(a3)
	move 	72(a0),72(a3)
	move 	80(a0),80(a3)
	move 	88(a0),88(a3)
	move 	96(a0),96(a3)
	move 	104(a0),104(a3)
	move 	112(a0),112(a3)
	move 	120(a0),120(a3)
	move 	128(a0),128(a3)
	move 	136(a0),136(a3)
	move 	144(a0),144(a3)
	move 	152(a0),152(a3)
	add.l 	#160,a1		add one line to first pointer
	sub.l 	#160,a3		sub one line from second pointer
	move 	(a2)+,d1		take value from add table for how
	add 	d1,a0		many lines to advance through buffer
	dbra 	d0,cnstruct1
	rts

 ****************************************
* the exit routine. if you've finished   *
* gawping at our amazing scroll then you *
* are free to leave!!!!!!!!!!!!!!!!!!!!  *
 ****************************************

twistend	move.l 	colpal1,$ff8240	reset some colors
	move.l 	colpal2,$ff8244
	move.l 	oldssp,-(sp)	back to user mode
	move  	#$20,-(sp)
	trap  	#1
	add.l 	#6,sp	

	move.w	old_res,d0	get old res in d0
	
	move.w 	d0,-(sp)		reset screen pointer+original res
	move.l 	savescrn,-(sp)
	move.l 	savescrn,-(sp)
	move 	#5,-(sp)
	trap 	#14
	add.l 	#12,sp	

	clr 	-(sp)		good bye cruel world!!!
	trap 	#1		aaaarrghhhhhhh!!!!!!!


 **************************************
*  These routines are for making the   *
*  special fonts which this scroll     *
*  uses to make the diagonal scroll    *
*  each copy of the original font is   *
*  shifted left by 2 pixels and        *
*  moved up by one from the previous   *
*  thus when all 8 copies are animated *
*  they appear to move diagonally      *
 **************************************

makefonts	lea 	mainfont,a0	take original font
	lea 	font1,a1		first copy
	move 	#32,d0		start 8 lines in to char		
	move 	#0,d4		shift left by 1 pixel
	bsr 	movefont
	
	lea 	mainfont,a0	take original font
	lea 	font2,a1		second copy
	move 	#28,d0		start 7 lines in to char
	move 	#2,d4		shift left by 3 pixels
	bsr 	movefont	
	
	lea 	mainfont,a0	take original font
	lea 	font3,a1		third copy
	move 	#24,d0		start 6 line s in to char
	move 	#4,d4		shift left by 5 pixels
	bsr 	movefont
	
	lea 	mainfont,a0	etc
	lea 	font4,a1
	move 	#20,d0		etc
	move 	#6,d4
	bsr 	movefont
	
	lea 	mainfont,a0
	lea 	font5,a1
	move 	#16,d0
	move 	#8,d4
	bsr 	movefont
	
	lea 	mainfont,a0
	lea 	font6,a1
	move 	#12,d0
	move 	#10,d4
	bsr 	movefont
	
	lea 	mainfont,a0
	lea 	font7,a1
	move 	#8,d0
	move 	#12,d4
	bsr 	movefont
	
	lea 	mainfont,a0	take original font 
	lea 	font8,a1		eigth copy
	move 	#4,d0		start on 2nd line
	move 	#14,d4		shift left by 15 pixels
	bsr 	movefont
	
	rts


movefont	move 	#59,d1		60 characters
movefont1	move.l 	a1,a2		first move font to copy 
	add 	d0,a2		add line offset
	move 	#35,d3		36 lines high
	move.l 	a2,a3
movefont2	clr 	(a2)+		blank 1 word
	move 	(a0)+,(a2)+	move font to 2nd word
	dbra 	d3,movefont2	loop
	
	move 	d4,d5		move amount to shift to d5
movefont3	move.l 	a3,a4
	move 	#35,d3		now shift font over (36 lines)
movefont4	lsl 	2(a4)		shift 1st word 	
	roxl 	(a4)		2nd word taking shifted bit from first
	add.l 	#4,a4
	dbra 	d3,movefont4
	
	dbra 	d5,movefont3
	
	add.l 	#144,a1
	dbra 	d1,movefont1
	rts

 ************************************
* The table for wrapping the scroll  *
* around the imaginary bar. Numbers  *
* correspond to numbers of bytes in  *
* the buffer, 160= 1 line,320= 2line *
 ************************************

addtab	dc.w 	800,640,480,320,320,320,320,160,320,160,320,160,160,160,0,160,160,0
	dc.w	160,160,0,160,160,0,160,0,160,0,160,0,160,0,160,0
	dc.w 	0,160,0,160,0,160,0,160,0,160,0,160,160,0,160,160
	dc.w	0,160,160,0,160,160,160,320,160,320,160,320,320,320,480,320,640,800
oldssp	dc.l 	0
savescrn	dc.l 	0	
fonttype	dc.l	font1
screen1	dc.l 	0		the two screens
screen	dc.l 	0
scrollpnt	dc.l 	scrolline		pointer to scrolline

colpal1	ds.l	1		colour palette info
colpal2	ds.l	1		saved for clean exit
	even
fname	dc.b	"scroll.txt"	scroll text file name
	even
old_res	ds.w	1		holds the original resolution
text	dc.b 	$1b,$45,0,0	text for clearing screen

 ********************************************
* The font is made up of 1 plane characters  *
* which are 36 lines high and 1 word wide    *
* the bottom 8 lines must be blank to allow  *
* for the special format of characters!!     *
* to make a font draw a series of characters *
* 15 pixels wide (1 blank for space between  *
* letters) and 28 lines high. you could draw *
* them with a slant like I did to improve    *
* the diagonal effect.                       *
 ********************************************
	even
mainfont	incbin	"twist.dat"
 ********************************************
* The incbin instruction is used by genst    *
* to include a binary file into an assembled *
* file. If the assembler you use does not    *
* have this instruction then either convert  *
* the twist.dat file into dc.w statements or *
* add an additional piece of code to load    *
* the file to this part of the program.      *
 ********************************************

* Requires Devpac 2 for this bit !!!!!
* Remove 'section bss' if it causes a problem - NOTE your PRG file
* will be massive now. Because of 64000k for the screens and 256 for
* rounding down ! 
section	bss	* don't store in the file

	even
	ds.b	256		allow for fixing to a 256 bound
screenspace ds.b	32000		first screen
	ds.b	32000		second screen

* Font stores 

font1	ds.b	8640*9		allocate space for fonts
font2	equ 	font1+8640
font3 	equ 	font2+8640
font4	equ 	font3+8640
font5	equ 	font4+8640
font6	equ 	font5+8640
font7	equ 	font6+8640
font8	equ 	font7+8640
fontend	equ 	font8+8640

scrolline	ds.b	22		room for 22 padded spaces
thescroll
maxlength	equ	10000		maximum of 10k scroll text file