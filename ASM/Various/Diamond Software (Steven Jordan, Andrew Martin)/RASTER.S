***************************************************************************
*									  * 															 
*                     A FAIRLY SIMPLE RASTER ROUTINE			  *
*								          *
*		 Written By Steven Jordan And Andrew Martin		  *
*		        (c) Diamond Software 1993!			  *
*									  *
* If your felling adventurous then you can change it so that it scolls	  *
* up or down the screen. Or how about bouncing it up and down or even	  *
* side to side. (It's not too hard - it just needs a bit of imagination!  *
*								 	  *
* 		 This routine can be used in your own demo		  *
*	   All I ask is that you say hi to me (Steven Jordan)		  *								
*									  *
*  HAS ANBODY GOT ANY ROUTINES FOR : A PLASMA SCREEN & A BIG SCROLLER?	  *
*            								  *
***************************************************************************


ok_lets_start	

	clr.l   -(sp)			supervisor mode on
	move.w  #$20,-(sp)
	trap    #1
	move.l  d0,savereg
	
	move.l	$44e,a0			current physbase
	sub.l	#$2000,a0		go back a bit because our 50-60 hz...
	move.l	a0,physbase		..trick would push us into rom

	lea	stack,a7		stack needed later

	move.l  #moff,-(sp)		mouse off
	clr.w   -(sp)			clear
	move.w  #25,-(sp)		set mouse?
	trap    #14			XBOIS
	addq.l  #8,sp			adjust stack
	dc.w    $a00a			timer A

	move.w  #4,-(sp)		get res    
	trap    #14			call XBOIS
	addq.l  #2,sp			adjust stack
	move.w  d0,oldrez		save old res
	move.l  $44e,oldscr		save old screen
	move.l  physbase,screen		move phys to drawing screen

	movem.l $ffff8240.w,d0-d7	get system cols
	movem.l d0-d7,oldpal		store 'em

	move.w  #0,-(sp)		low res
	move.l  screen(pc),-(sp)	phys	
	move.l  screen(pc),-(sp)	log
	move.w  #5,-(sp)		setscreen
	trap    #14			call XBIOS
	add.l   #12,sp			adjust stack

	bsr     hblon			inttall interrupts

***************************************************************************
* THIS IS OUR MAIN LOOP - WE LOOP UNTIL ESC IS PRESSED			  *
***************************************************************************

again	
	move.w  #7,-(sp)		wait for a key - no echo
	trap    #1			call GEMDOS
	addq.l  #2,sp			adjust stack
	swap	d0			swap d0/sp/a7
	cmp.b	#$01,d0			ESC ?  if so quit
	bne	again			NO, try again

***************************************************************************
* IF WE EVER GET TO HERE THEN THE ESC KEY HAS BEEN PRESSED.		  *
* NOW WE CAN RESTORE ALL THT WE CHANGED 			          *
***************************************************************************

	bsr     hbloff			disable interrupts

	movem.l oldpal,d0-d7		get old system cols
	movem.l d0-d7,$ffff8240		get 'em

	move.w  oldrez,-(sp)		old res
	move.l  oldscr,-(sp)		old phys
	move.l  oldscr,-(sp)		old log
	move.w  #5,-(sp)		set screen
	trap    #14			call XBOIS
	add.l   #12,sp			adjust stack

	move.l  #mon,-(sp)		mouse on
	clr.w   -(sp)			clear
	move.w  #25,-(sp)		set mouse?
	trap    #14			XBOIS
	addq.l  #8,sp			adjust stack
	dc.w    $a009			time A

	move.l  savereg,-(sp)		leave supervisor
	move.w  #$20,-(sp)
	trap    #1
	addq.l  #6,sp

	clr.w   -(sp)			quit
	trap    #1

***************************************************************************
* NOW FOLLOWS ALL OUR NEW TIMER B STUFF AND VBL STUFF ...            	  *
***************************************************************************

hblon	move.l  $120,oldtimer		save old timer B vector
	move.l  $70,oldvbl		save old vb vector
	move.l  $70,vbl+2		now, new vbl routine will jump to
;					old one afterwards
	move.b  $fffffa07,old07		timer B enable
	move.b  $fffffa09,old09		timer C enable
	move.b  $fffffa0f,old0f		timer B in-service
	move.b  $fffffa11,old11		timer C in-service
	move.b  $fffffa1b,old1b		timer B control
	and.b   #$df,$fffa09		disable timer C
	and.b   #$fe,$fffa07		disable timer B 
	move.l  #timer1,$120		new timer B vector
	move.l  #newvbl,$70		new vb vector
	or.b    #1,$fffffa07		enable timer B
	or.b    #1,$fffffa13		set timer B mask
	rts

***************************************************************************

hbloff	move.w  sr,-(sp)
	move.w  #$2700,sr		
	move.b  old07(pc),$fffffa07 	
	move.b  old09(pc),$fffffa09
	move.b  old0f(pc),$fffffa0f
	move.b  old11(pc),$fffffa11
	move.b  old1b(pc),$fffffa1b
	move.l  oldtimer,$120
	move.l  oldvbl,$70
	move.w  (sp)+,sr
	rts

***************************************************************************
* THIS IS OUR NEW VBL ROUTINE FOR OUR RASTERS ...			  *
***************************************************************************

newvbl	clr.b   $fffffa1b.w		disable timer B
	move.b  #1,$fffffa21		first raster 1 line away
	move.b  #8,$fffffa1b		enable timer B
	move.l  #timer1,$120		timer B vector
vbl	jmp     $12345678		skip the magic number (this has no effect when you change it!)

***************************************************************************

timer1	clr.b   $fffffa1b.w		stop timer
	movem.l d0-d7/a0-a1,-(sp)  	save from corruption
	move.w  #$fa21,a1		timer B scanline
	move.b  #12,(a1)		next interrupt at line X
	move.l  #newtb2,$120		set our new timer B vector
	move.b  #8,$fffffa1b.w		let timer B continue 

	move.w  #198-1,d2		set repeat (no. colours)
	move.l  #pal1,a0 		get our palette
	add.l   #44*9,a0		add 44*9 words
loop	move.b  (a1),d0			get value of timer B
wait1	cmp.b   (a1),d0			wait one scanline 
	beq     wait1			keep looping until 1 scanline reached
	move.w  -(a0),$ff8240 		set our colours backwards!
	dbra    d2,loop			keep looping until all cols done

	movem.l	palette,d1-d7/a0	get the palette
loopx	move.b	(a1),d0			get the value of timer B
wait2	cmp.b	(a1),d0			wait another scanline
	beq	wait2			until we have 	
	movem.l	d1-d7/a0,$ff8240	restore the palette
                
	movem.l (sp)+,d0-d7/a0-a1	restore all things changed
	bclr    #0,$fffffa0f		end of our interrupt
	rte

***************************************************************************

newtb2	clr.b   $fffffa1b.w		stop timer B
	movem.l d0-d7/a0-a1,-(sp)	store registers
	move.w  #$fa21,a1		
	move.b  #76,(a1)		our next interrupt 
	move.b  #8,$fffffa1b.w		timer B
	movem.l (sp)+,d0-d7/a0-a1	restore old registers
	bclr    #0,$fffffa0f.w		end our interrupt
	rte

***************************************************************************


pal1    rept	2
	dc.w 	$710,$720,$730,$740,$750,$760,$770,$670,$570,$470,$370
	dc.w 	$270,$170,$70,$71,$72,$73,$74,$75,$76,$77,$67,$57,$47,$37
	dc.w 	$27,$17,$7,$107,$207,$307,$407,$507,$607,$707,$706,$705
	dc.w 	$704,$703,$702,$701,$700,$710,$720,$730,$740,$750,$760
	dc.w 	$770,$670,$570,$470,$370,$270,$170,$70,$71,$72,$73,$74
	dc.w 	$75,$76,$77,$67,$57,$47,$37,$27,$17,$7,$107,$207,$307
	dc.w 	$407,$507,$607,$707,$706,$705,$704,$703,$702,$701,$700
	dc.w 	$710,$720,$730,$740,$750,$760,$770,$670,$570,$470,$370
	dc.w 	$270,$170,$70,$71,$72,$73,$74,$75,$76,$77,$67,$57,$47
	dc.w 	$37,$27,$17,$7,$107,$207,$307,$407,$507,$607,$707,$706
	dc.w 	$705,$704,$703,$702,$701,$700
	endr

 	
palette		ds.w	32
		ds.w	310

stack		dc.l	0
physbase	dc.l	0
screen_0	dc.l	0
handle		dc.w	0
oldrez          dc.w    0
oldscr          dc.l    0
savereg         dc.l    0
screen          dc.l    0
oldpal          ds.w    16
mon             dc.b    $08
moff            dc.b    $12
oldvbl          dc.l    0
oldtimer        dc.l    0
old07           dc.b    0
old09           dc.b    0
old0f           dc.b    0
old11           dc.b    0
old1b           dc.b    0





