; rasters
;
; create some nice rasters
; ST NEWS 4.3   adapted by Budgie UK   Nov 1, 1989
; courtesy Stefan Posthuma
; A Digital Insanity creation

	clr.l   -(sp)		supervisor mode on
	move.w  #$20,-(sp)
	trap    #1
	move.l  d0,savereg
	
	move.l	$44e,a0		current physbase
	sub.l	#$2000,a0	go back a bit because our 50-60 hz...
	move.l	a0,physbase	..trick would push us into rom
	move.l	a0,a7

	move.l  #moff,-(sp)	mouse off
	clr.w   -(sp)
	move.w  #25,-(sp)
	trap    #14
	addq.l  #8,sp
	dc.w    $a00a

	move.w  #4,-(sp)		get resolution        
	trap    #14
	addq.l  #2,sp
	move.w  d0,oldrez		and save it
	move.l  $44e,oldscr
	move.l  physbase,screen

	movem.l $ffff8240.w,d0-d7	save colors...
	movem.l d0-d7,oldpal		..quickly

	move.w  #0,-(sp)		set low res
	move.l  screen(pc),-(sp)	phys	
	move.l  screen(pc),-(sp)	log
	move.w  #5,-(sp)
	trap    #14
	add.l   #12,sp

*	bra	hi			avoid loading degas pic

* load a degas picture at a specific address 
	move.w	#0,-(sp)
	move.l	#pic_name,-(sp)	open file	
	move.w	#$3D,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,handle

	move.l	screen,d0	load direct to current screen
	sub.l	#34,d0
	sub.l	#1*160,d0	hide the palette data
	move.l	d0,-(sp) 
	move.l	#34,-(A7)	read it
	move.w	handle,-(A7)
	move.w	#$3F,-(A7)
	trap	#1
	adda.l	#12,A7

	move.l	screen,d0	load direct to current screen
	add.l	#40*160,d0	push the picture 40 lines DOWN
;				inside the bottom border!
	move.l	d0,-(sp) 
	move.l	#32000,-(A7)	read picture
	move.w	handle,-(A7)
	move.w	#$3F,-(A7)
	trap	#1
	adda.l	#12,A7

	move.w 	handle,-(SP)
	move.w 	#$3E,-(SP)
	trap 	#1		close file
	addq.l 	#4,SP

	move.l	screen,a0
	sub.l	#192,a0		locate palette's origin
	lea	palette,a1	destination
	move.l	#16-1,d0
paloop	move.w	(a0)+,(a1)+	save it
	dbra	d0,paloop

hi
*-----------------------------------------------

	bsr     hblon		enable my interrupts#

*------------------------------------------------

again	
	move.w  #7,-(sp)	wait for a key  no echo
	trap    #1
	addq.l  #2,sp
	swap	d0
	cmp.b	#$01,d0		ESC ?  if so quit
	bne	again
*------------------------------------------------

	bsr     hbloff		disable interrupts

	movem.l oldpal,d0-d7	old colors back
	movem.l d0-d7,$ffff8240.w
	move.w  oldrez,-(sp)	old resolution back
	move.l  oldscr,-(sp)
	move.l  oldscr,-(sp)
	move.w  #5,-(sp)
	trap    #14
	add.l   #12,sp

	move.l  #mon,-(sp)	mouse on
	clr.w   -(sp)
	move.w  #25,-(sp)
	trap    #14
	addq.l  #8,sp
	dc.w    $a009

	move.l  savereg,-(sp)	leave supervisor
	move.w  #$20,-(sp)
	trap    #1
	addq.l  #6,sp

	clr.w   -(sp)		sayonara!
	trap    #1

oldrez:         dc.w    0
oldscr:         dc.l    0
savereg:        dc.l    0
screen:         dc.l    0
oldpal:         ds.w    16
mon:            dc.b    $08
moff:           dc.b    $12

                even

*-------------------------------------------------------

; see the article for comments about these addresses

hblon	move.l  $120,oldtb	save old timer B vector
	move.l  $70,old4	save old vb vector
	move.l  $70,new4b+2	now, new vb routine will jump to
;				old one afterwards
	move.b  $fffffa07,old07	timer B enable
	move.b  $fffffa09,old09	timer C enable
	move.b  $fffffa0f,old0f	timer B in-service
	move.b  $fffffa11,old11	timer C in-service
	move.b  $fffffa1b,old1b	timer B control
	and.b   #$df,$fffa09	disable timer C
	and.b   #$fe,$fffa07	disable timer B 
	move.l  #newtb1,$120	new timer B vector
	move.l  #new4,$70	new vb vector
	or.b    #1,$fffffa07	enable timer B
	or.b    #1,$fffffa13	set timer B mask
	rts

hbloff	move.w  sr,-(sp)
	move.w  #$2700,sr	cut out all interrupts
	move.b  old07(pc),$fffffa07 restore all old vectors
	move.b  old09(pc),$fffffa09
	move.b  old0f(pc),$fffffa0f
	move.b  old11(pc),$fffffa11
	move.b  old1b(pc),$fffffa1b
	move.l  oldtb,$120
	move.l  old4,$70
	move.w  (sp)+,sr
	rts

old4:           dc.l    0
oldtb:          dc.l    0
old07:          dc.b    0
old09:          dc.b    0
old0f:          dc.b    0
old11:          dc.b    0
old1b:          dc.b    0

	even

; This is the new VBL handler
new4	clr.b   $fffffa1b.w	disable timer B
	move.b  #36,$fffffa21	first raster 36 lines away
	move.b  #8,$fffffa1b	enable timer B
	move.w  #$644,$ff8240	initial border (beige)
	move.l  #newtb1,$120	timer B vector
new4b	jmp     $12345678	pass ontrol to OLD vb vector

newtb1	clr.b   $fffffa1b.w	timer stop
	movem.l d0-d7/a0-a1,-(sp)  save from corruption
	move.w  #$fa21,a1	timer B data register (ie scanline!)
	move.b	#22,(a1)	put 22 in it : second interrupt at line 58
	move.l  #newtb2,$120	set new timer B vector
	move.b  #8,$fffffa1b.w	allow timer B again

	moveq.w #22-1,d2	number of colors in table
; change above figure to 48 and we'll get 48 lines with different
; colors BUT, next interrupt further down will be unstable..
	move.l  #pal1,a0 	pal1: color table
; I am now randomly modifying A0 to point ANYWHERE in memory
	move.l	$466,d3		random value
	lsl.l	#1,d3		make it even
	move.l	d3,a0		point to it
	add.l	#44,a0		add 22 words

; we can now clearly see these 22 lines grouped at the top of picture
; from line 36 onwards (22 different random colors)

loop	move.b  (a1),d0		get value of timer B
wait	cmp.b   (a1),d0		wait one scanline !
	beq     wait
	move.w  -(a0),$ff8240 	use those randoms colors (backwards)

;	move.w  (a0)+,d1
;	move.w	d1,$ff8240	set colors
;	move.w	d1,$ff8242
;	move.w	d1,$ff8244
;	move.w	d1,$ff8246
;	move.w	d1,$ff8248
;	move.w	d1,$ff824a
;	move.w	d1,$ff824c
;	move.w	d1,$ff824e
	dbra    d2,loop

	movem.l	palette,d1-d7/a0
loopx	move.b	(a1),d0		more waiting for...
waitx	cmp.b	(a1),d0		... next scanline
	beq	waitx
	movem.l	d1-d7/a0,$ff8240
                
	movem.l (sp)+,d0-d7/a0-a1
	bclr    #0,$fffffa0f.w	end of interrupt
	rte

newtb2	clr.b   $fffffa1b.w	timer stop
	movem.l d0-d7/a0-a1,-(sp)
	move.w  #$fa21,a1
	move.b  #76,(a1)	third one will be at line 58+40=98
	move.l  #newtb3,$120
	move.b  #8,$fffffa1b.w

; now follows the second lot of lines from location 58 to 80
	move.w  #22-1,d1	raster is 22 scanlines deep
	move.l	$466,d2		get a random number
	lsl.l	#1,d2		make sure it's even
	move.l  d2,a0		that's where we'll get our colors from!
loop2	move.b  (a1),d0
wait2	cmp.b   (a1),d0		see if scanline has moved on
	beq     wait2
	move.w  (a0)+,$ff8240   now use those totally random colors
	dbra    d1,loop2

	movem.l	palette,d1-d7/a0	restore original palette
	move.b	(a1),d0
waity	cmp.b	(a1),d0
	beq	waity
	movem.l	d1-d7/a0,$ff8240
                
	movem.l (sp)+,d0-d7/a0-a1
	bclr    #0,$fffffa0f.w	end of interrupt
	rte

newtb3	clr.b   $fffffa1b.w	timer stop
	movem.l d0-d7/a0-a1,-(sp)
	move.w  #$fa21,a1
	move.b  #64,(a1)	kill border at line 199 (101+98)
	move.l  #killborder,$120
	move.b  #8,$fffffa1b.w

; now we have the third group of colors, again random
	move.w  #21-1,d1	number of scanlines wanted
	move.l  #pal1,a0	where colors are stored
loop3	move.b  (a1),d0
wait3	cmp.b   (a1),d0
	beq     wait3
	move.w  (a0)+,$ff8242		the Budgie logo this time
	dbra    d1,loop3

	movem.l	palette,d1-d7/a0	again restore original palette
	move.b	(a1),d0
waitz	cmp.b	(a1),d0
	beq	waitz
	movem.l	d1-d7/a0,$ff8240
                
	movem.l (sp)+,d0-d7/a0-a1
	bclr    #0,$fffffa0f.w	end of interrupt
	rte

killborder
	clr.b   $fffffa1b.w	timer stop
*	bra	bill		jumping to bill will skip the 50-60 hz bit
	movem.l d0-d1/a0-a1,-(sp)
	move.w  #$fa21,a1
	move.b  #140,(a1)	changing this number had little effect
	move.b  #8,$fffffa1b.w	this line is essential

	move.b  (a1),d0
wait4	cmp.b   (a1),d0		wait last scanline
	beq     wait4		
	clr.b   $ffff820a.w	60 Hz
	moveq   #4,d0
nopi2	nop			wait a while
	dbf     d0,nopi2
	move.b  #2,$ffff820a.w	50 Hz
	movem.l (sp)+,d0-d1/a0-a1 
bill      
	bclr    #0,$fffffa0f.w	end of interrupt
	rte			final exit 

*------------------------------------------

pal1	dc.w    $026,$237,$247,$257,$256,$255,$254,$162
	dc.w	$560,$653,$750,$740,$730,$600,$530,$600
	dc.w	$730,$740,$750,$760,$653,$560,$162,$254
 	
palette		ds.w	32
		ds.w	10

physbase	dc.l	0
screen_0	dc.l	0
handle		dc.w	0
pic_name	dc.b "a:\budgie.mfp\queen5.pi1",0
		even
		ds.w	48

	even

