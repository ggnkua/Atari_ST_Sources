	opt s-					no symbols
	move.l sp,a5				save sp
	move.l $4(a5),a5			get basepage
	move.l #$200,-(sp)			protect $200
	move.l a5,-(sp)				from basepage
	move.w #$0,-(sp)			dummy
	move.w #$4a,-(sp)			setblock
	trap #1					call dos
	add.l #$c,sp				correct stack
	clr.l -(sp)				dummy
	move.w #$20,-(sp)			super
	trap #1					call dos
	addq.l #6,sp				correct stack
	move.l d0,old				save old sp
	move.l #(music+$86e),(music+$1aa)	relocate
	move.l #(music+$86f),(music+$828)	music
	move.l #(music+$86e),(music+$83c)	to
	move.l #(music+$c4e),(music+$c3e)	play
	move.l #(music+$2cfa),(music+$c42)	at
	move.l #(music+$356a),(music+$c46)	this
	move.l #(music+$416c),(music+$c4a)	address
	clr.l d0				init
	jsr (music+8)				mfp etc
	move.w #17,-(sp)
	trap #14
	addq.l #2,sp
	and.l #3,d0
	addq.l #1,d0
	jsr (music)				call music
	move.l $70.w,oldvbl			save old vbl
	move.l #zippy,$70.w			install my vbl
	pea text(pc)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	move.w #7,-(sp)				wait key
	trap #1					call dos
	addq.l #2,sp				correct stack
	move.l oldvbl,$70.w			restore old vbl
	move.l #$8080000,$ffff8820.w		clear
	move.l #$9090000,$ffff8820.w		sound
	move.l #$a0a0000,$ffff8820.w		chip
	move.l #$707ffff,$ffff8820.w		registers
	jsr (music+12)				restore mfp etc.
	move.b #$e0,$fffffa23.w			new timer c
	move.l old,-(sp)			restore old sp
	move.w #$20,-(sp)			back in user
	trap #1					call dos
	addq.l #6,sp				correct stack
	clr.w -(sp)				terminate
	trap #1					call dos
zippy	movem.l d0-a6,-(sp)			save registers
	move.l $b8.w,$24.w
	move.l $84.w,$10.w
	jsr (music+4)				call music player
	move.l $84.w,$bc.w
	movem.l (sp)+,d0-a6			restore registers
	move.l oldvbl,-(sp)			old vbl on sp
	rts					do old vbl code
oldvbl	dc.l 0
old	dc.l 0
music	incbin 'c:\music\chamber.mus'
text	dc.b 27,'E',27,'f'
	dc.b "Cynix Present",10,13
	DC.B "~~~~~~~~~~~~~",10,10,13
	DC.B "AIR WARRIOR",10,10,13
	DC.B "Supplied by Quaser/Spread by Absu",10,10,10,13
	dc.b "No protection on this little game so",10,13
	dc.b "just have a play with it and make of",10,13
	dc.b "it what you will....",10,13
	dc.b "It doesn't seem to ask for the other 2",10,13
	dc.b "disks but maybe that's all explained in",10,13
	dc.b "one of the doc files..... have a look",10,13
	dc.b "and find out for yourself !!",10,10,13
	dc.b "Greets to those that deserve them (you",10,13
	dc.b "know who you are!), and no greets to all",10,13
	dc.b "the 'hangers-on' who give so little,",10,13
	dc.b "want so much and waste so much valuable",10,13
	dc.b "time and thought !!!"
	even
	dc.w 0
	