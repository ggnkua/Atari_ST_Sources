***************************************************************************
*							    *
*   STFM Overscan V2.0  - Source code (c) Diamond Software 1994	    *
*   Source Code	    - Steven J				    *
*   Graphics	    - Juvis				    *
*							    *
*		    - Set your tabs to 10			    *
*		    - Assemble with GENST V2+ 		    *
*		    - Does not work on STEs (Thanks Nik B!)	    *
*							    *
*  For my 4-bit hardware scrolling in full-screen,  you have to switch    *
*  to med res after the high res switch (-left border-), and then wait    *
*  for either 0,4,8,12 cycles before you swtich back to low res.  This    *
*  delays the picture being displayed by a multiple of 500	nanoseconds,  *
*  which results in an effective shift in the picture!		    *
*							    *
***************************************************************************

	bsr	Setup		setup picture, screen etc
MainLoop	cmp.b	#57,$fffffc02	is space pressed?...
	bne	MainLoop		no. keep looping
	bra	Exit		yes, quit

***************************************************************************
* EXIT						  	    *
* Restore all that was changed				    *
***************************************************************************

Exit	bsr	MfpOff		restore old interupts
	move.w	oldres,-(sp)	set old resolution
	move.l	oldscr,-(sp)	set old physical screen address
	move.l	oldscr,-(sp)	set old logical screen address
	move.w	#5,-(sp)		set screen
	trap	#14		call xbios
	add.l	12,sp		adjust stack

	bsr       ResetPal    	reset the old palette

	move.l	#mon,-(sp)	mouse on
	clr.w	-(sp)		keep old
	move.w	#25,-(sp)		
	trap	#14		call xbios
	addq.l	#8,sp		adjust the stack

	move.l    oldsp,-(sp)         reset old stack address
	move.w    #32,-(sp) 	set in supervisor mode 
	trap      #1        	call gemdos
	addq.l    #6,sp     	adjust the stack

	clr.l     -(sp)     	quit
	trap	#1		

***************************************************************************
* SETUP						  	    *
* Setup the screens, resolution, picture etc...			    *
***************************************************************************
	
Setup	clr.l     -(sp)		keep old stack
	move.w    #32,-(sp)		call supervisor
	trap      #1		call gemdos
	addq.l    #6,sp		adjust the stack
	move.l    d0,oldsp		save old supervisor

	bsr	SetScreen		setup the screens and res
	bsr	MouseOff		turn the mouse off
	bsr	SavePal		save and set the palette
	bsr	DrawBackgrnd	draw the full screen ictari picture
	bsr	MfpOn		save and install interupts
	
	rts

***************************************************************************
* SETUP THE SCREENS AND RESOLUTION IF WE CAN		  	    *
***************************************************************************

SetScreen	move.w	#4,-(sp)		get screen res
	trap	#14		call xbios
	addq.l	#2,sp		adjust stack

	cmp.b	#2,d0		are we in high res?
	beq	High		yes, quit
	move.w	d0,oldres		save old res

	move.w	#3,-(sp)		get screen address
	trap	#14		call xbios
	addq.l	#2,sp		adjust stack
	move.l	d0,oldscr		save old screen

	move.l	#screens,d0
	clr.b	d0
	move.l	d0,screen
	move.l	d0,d1
	add.l	#64000,d1
	eor.l	d0,d1
	move.l	d1,scr_xor

	move.w	#0,-(sp)		low resolution
	move.l	screen,-(sp)	physical screen address
	move.l	screen,-(sp)	logical screen address
	move.w	#5,-(sp)		set screen
	trap	#14		call xbios
	add.l	#12,sp		adjust stack

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
* WE'RE IN HIGH REZ					 	    *
***************************************************************************

High	move.l	#high_mess,-(sp)	get the high res message
	move.w	#9,-(sp)		print it to the screen
	trap	#1		gemdos
	addq.l	#6,sp		restore stack

	move.w	#8,-(sp)		wait for a key
	trap	#1		gemdos
	addq.l	#2,sp		restore stack

	clr.l	-(sp)		quit
	trap	#1		gemdos

***************************************************************************
* TURN THE MOUSE OFF				 	    *
***************************************************************************

MouseOff	move.l	#moff,-(sp)	mouse off
	clr.w	-(sp)		keep old
	move.w	#25,-(sp)		
	trap	#14		call xbios
	addq.l	#8,sp		adjust the stack

	rts			

***************************************************************************
* RESET OLD PALETTE                                                       *
***************************************************************************

ResetPal  movem.l	oldpal,d0-d7	get our old palette
	movem.l	d0-d7,$ffff8240	set it

	move.w	#$777,$fff8240	white border colour
	move.w	#$000,$fff8246	black text colour

	rts

***************************************************************************
* SAVE THE PALETTE 						    *                                                       *
***************************************************************************

SavePal	movem.l   $ffff8240,d0-d7     get entire palette
          movem.l   d0-d7,oldpal      	save palette

	movem.l	pal,d0-d7		get new palette
	movem.l	d0-d7,$fff8240	set palette
	
	rts			

***************************************************************************
* SAVE AND INSTALL INTERUPTS 					    *
***************************************************************************

MfpOn	move.l	$120,oldtb	save old timer B vector
	move.l	$70,old4		save old vb vector
	move.l	$134,oldtimera	old timer A
          move.b    $fffffa07,timera1   interupt enable a
          move.b    $fffffa13,timera2   interupt mask a
          move.b    $fffffa19,timera3   timer a control
          move.b    $fffffa1f,timera4   timer a data
	move.b	$fffffa07,old07	timer B enable
	move.b  	$fffffa09,old09	timer C enable
	move.b  	$fffffa0f,old0f	timer B in-service
	move.b  	$fffffa11,old11	timer C in-service
	move.b  	$fffffa1b,old1b	timer B control
	and.b   	#$df,$fffa09	disable timer C
	and.b   	#$fe,$fffa07	disable timer B 
          clr.b     $fffffa19 	empty timer a data
          move.b    #$21,$fffffa07      disable interupt a
          move.b    #$21,$fffffa13      set mask a
          bclr      #3,$fffffa17        reset vector base
	move.l  	#NewVbl,$70	new vb vector
	move.l	#Overscan,$120	timer b overscan routine
	or.b    	#1,$fffffa07	enable timer B
	or.b    	#1,$fffffa13	set timer B mask
	rts

***************************************************************************
* RESET INTERUPTS                                                         *
***************************************************************************

MfpOff	move.w  	sr,-(sp)		save 
	move.w  	#$2700,sr		cut out all interrupts
	move.b  	old07,$fffffa07 	restore all old vectors
	move.b  	old09,$fffffa09	timer c enable
	move.b  	old0f,$fffffa0f	timer b in-service
	move.b  	old11,$fffffa11	timer c in-service
	move.b  	old1b,$fffffa1b	timer b control
          move.b    timera1,$fffffa07   interupt enable a
          move.b    timera2,$fffffa13   interupt mask a
          move.b    timera3,$fffffa19   timer a control
          move.b    timera4,$fffffa1f   timer a data
          move.l    oldtimera,$134      timer a interupt
	move.l  	oldtb,$120	old timer b
	move.l  	old4,$70		old vbl
	move.w  	(sp)+,sr		retore
	rts			return

***************************************************************************
* VBLANK ROUTINE                                                          *
***************************************************************************

NewVbl	
	dcb.w	4,$4e71		wait for a bit
	move.w	#1432-1,d0	pause for correct place
.top_wait	dbf	d0,.top_wait	paused?
	clr.b     $ffff820a		set 60HZ
	dcb.w	10,$4e71		wait to fool video shifter
	move.b    #2,$ffff820a	set 50hz

	clr.b	$fffffa1b		stop timer b
	move.b	#7,$fffffa21	scan line
	move.l	#Overscan,$120	timer B rout
	move.b 	#8,$fffffa1b	start timer B again	

	rte			return from interupt

***************************************************************************
* REMOVE THE LEFT, RIGHT AND LOWER BORDERS			    *
***************************************************************************

Overscan
	clr.b	$fffffa1b.w	stop timer B
	lea	$fffffa21.w,a0	timer b data (scanline)
	moveq.b	#0,d0		clear data register
	move.b	#16,d1		used for the clock cycle delay
	move.b	#10,(a0)		any number > 0
	move.b	#8,$fffffa1b.w	start timer B
	move.b	(a0),d0		get scanline
.wait1	cmp.b	(a0),d0		are we at the start of it?
	beq.s	.wait1		no, keep on trying
	lea	$ffff8209.w,a0	get number of bytes drawn on a scanline ("low byte of video address counter")
.Wait2	move.b	(a0),d0		make sure we start on right line
	beq.s	.Wait2		if not, keep trying...
	sub.b	d0,d1		subract start from cycle delay
	lsl.b	d1,d1		clock cycle with the electronic beam
	clr.b	$fffffa1b.w	stop timer b

	lea	sky,a0		sky colours
	lea	$ffff8240.w,a1	palette address (border)
	move.w	#219-1,d0		set number lines to overscan

	dcb.w	80,$4e71		wait until we're in the border
.Overscan1
	dcb.w	1,$4e71		move into the left border
	move.b	#2,$ffff8260.w	set high res
	move.b	#0,$ffff8260.w	set low res (no left border)
	dcb.w	87,$4e71		move into the right border
	move.b	#0,$ffff820a.w	set 60Hz
	move.b	#2,$ffff820a.w	set 50Hz (no right border)
	dcb.w	8,$4e71		move into far right border
	move.b	#1,$ffff8260.w	set medium res
	move.b	#0,$ffff8260.w	set low res (to close the border)
	move.w	(a0)+,(a1)	set the sky colour
	dcb.w	2,$4e71		move into the left border
	dbra	d0,.Overscan1	next scan line

	move.b	#2,$ffff8260.w	set high res
	move.b	#0,$ffff8260.w	set low res (no left border)
	dcb.w	87,$4e71		move to the right border
	move.b	#0,$ffff820a.w	set 60Hz
	move.b	#2,$ffff820a.w	set 50Hz (no right border)
	dcb.w	6-1,$4e71		move into far right border
	move.b	#0,$ffff820a.w	set 60Hz (for lower border)
	move.b	#1,$ffff8260.w	set medium res
	move.b	#0,$ffff8260.w	set low res (to close the border)

	dcb.w	10,$4e71		move to the left border

	move.b	#2,$ffff8260.w	set high res
	move.b	#0,$ffff8260.w	set low res (no left border)
	move.b	#2,$ffff820a.w	set 50Hz (no lower border)
	dcb.w	84,$4e71		move to the right border
	move.b	#0,$ffff820a.w	set 60Hz
	move.b	#2,$ffff820a.w	set 50Hz (no right border)
	dcb.w	7,$4e71		move to the far right border
	move.b	#1,$ffff8260.w	set medium res (close the border)
	move.b	#0,$ffff8260.w	set low res (close the border)
	dcb.w	5,$4e71		move to the left border

	move.w	#40-1,d0		no. lines in the bottom border
.Overscan2
	move.b	#2,$ffff8260.w	set high res
	move.b	#0,$ffff8260.w	set low res (no left border)
	dcb.w	87,$4e71		move to the right border
	move.b	#0,$ffff820a.w	set 60Hz
	move.b	#2,$ffff820a.w	set 50Hz (no right border)
	dcb.w	8,$4e71		move to far right border
	move.b	#1,$ffff8260.w	set medium res (close the border)
	move.b	#0,$ffff8260.w	set low res (close the border)
	dcb.w	6,$4e71		move to the left border
	dbra	d0,.Overscan2	next scan line (4 nops)

	bclr	#0,$ffffa0f
	rte

***************************************************************************
* DRAW THE BACKGROUND 					    *
***************************************************************************

pos	equ	230*0+8

DrawBackgrnd
	move.l	#landscape,a2	draw landscape
	add.l	#pos,a2		get the position on the pic
	move.l	screen,a0		screen to draw on
	add.l	#160*9,a0		add 9 normal scanlines
	move	#221-1,d1		number of lines
	bsr	Draw		draw the picture

	move.l	#landscape,a2	draw landscape
	add.l	#pos,a2		get the position on the pic
	add.l	#230*220,a2	get pos to go into the lower border
	move.l	screen,a0		screen to draw on
	add.l	#(230*220)+(160*10),a0
	add.l	#8*3+2,a0		shift the planes over
	move	#40-1,d1		number of lines
	bsr	Draw		draw the picture

	rts

***************************************************************************
* DRAWING ROUTINE						    *
***************************************************************************

Draw
.l1
i	set	0		set to 0
	rept	26		repeat chunks (1 chunk=16 pixels)
	move.l	i(a2),i(a0)	draw plane 1 & 2
	move.l	i+4(a2),i+4(a0)	draw plane 3 & 4
i	set	i+8		next chunk
	endr			end of copying chunks
	add.l	#230,a0		next scanline line for logical
	add.l	#230,a2		next scanline line for picture
	dbf	d1,.l1		end of copying lines
	rts

***************************************************************************

num	equ	7
sky	dcb.w	num,$001
	dcb.w	num,$102
	dcb.w	num,$103
	dcb.w	num,$204
	dcb.w	num,$205
	dcb.w	num,$305
	dcb.w	num,$315
	dcb.w	num,$425
	dcb.w	num,$525
	dcb.w	num,$535
	dcb.w	num,$635
	dcb.w	num,$645
	dcb.w	num,$756
	dcb.w	num,$766
	dcb.w	num,$767
	dcb.w	num,$777
	rept	219-(num*16)
	dc.w	$000
	endr

landscape	incbin	"a:\assembly\overscan.v2\landscap.ful"
pal	dc.w	$0204,$0460,$0430,$0320,$0210,$0120,$0231,$FBCA
	dc.w	$0112,$0223,$0334,$0445,$0556,$0667,$0777,$F888

high_mess	dc.b	27,"E",27,"p"	cls, inverse on
	dc.b	"Sorry but this program needs more than two colours..."
	dc.b	27,"q",0		inverse off, null
	even
mon	dc.b    	8		code for mouse on
moff	dc.b    	18		code for mouse off
old4	dc.l	0		old interupts
oldtb	dc.l	0
old07	dc.b	0
old09	dc.b	0
old0f	dc.b	0
old11	dc.b	0
old1b	dc.b	0
oldtimera	dc.l	0
timera1	dc.l	0
timera2	dc.l	0
timera3	dc.l	0
timera4	dc.l	0

	section bss

oldres	ds.b	2		old resolution
oldscr	ds.l	4		old screen address
oldpal	ds.b	32		old palette
screen	ds.l	1		drawing scr
	ds.l	1
scr_xor	ds.l	1
oldsp    	ds.l	1		old stack pointer
	ds.l	100	
screens	ds.b	64000		space for physical screen
	ds.b	64000		space for logical screen

