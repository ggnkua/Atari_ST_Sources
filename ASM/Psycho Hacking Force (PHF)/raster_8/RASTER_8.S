* budgie
start	clr.l   -(sp)		supervisor mode on
	move.w  #$20,-(sp)
	trap    #1
	move.l  d0,savereg
	
	move.l	$44e,a0		current physbase
	sub.l	#$2000,a0	go back a bit because our 50-60 hz...
	move.l	a0,physbase	..trick would push us into rom
	move.l	a0,a7		temporary stack

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

	bsr	doit
	move.l	screen,d5
*	add.l	#38*160+158,d5	         line of scroll number 1
	move.l	d5,line_one	
	move.w	#1,speed
	move.l	#text_1,text_address	budgie message in scroll variable

	move.l	#scroll,a5	enable scroll interrupt	
	bsr	enable_vbi
	bsr     hblon		enable my MFP interrupts#

*------------------------------------------------
get	
	bsr	getkey
	cmp.b	#$01,d0		esc
	beq	quit
	bra	get
*-------------------------------------------------
getkey	
	move.w  #$ff,-(sp)	
	move.w	#6,-(sp)
	trap    #1
	addq.l  #4,sp
	swap	d0
	rts
*------------------------------------------------
quit
	move.l	#scroll,a5	cut out message scroll
	bsr	disable_vbi

	bsr     hbloff		disable MFP interrupts

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

	clr.w   -(sp)		quit
	trap    #1

oldrez	dc.w    0
oldscr	dc.l    0
savereg	dc.l    0
screen	dc.l    0
oldpal	ds.w    16
mon	dc.b    8
moff	dc.b    18

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
	move.l  #nobord,$120	new timer B vector
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

old4	dc.l    0
oldtb	dc.l    0
old07	dc.b    0
old09	dc.b    0
old0f	dc.b    0
old11	dc.b    0
old1b	dc.b    0
	even
*------------

; This is the new VBL handler
new4	clr.b   $fffffa1b.w	disable timer B
	move.b  #199,$fffffa21	first raster 36 lines away
	move.b  #8,$fffffa1b	enable timer B
	move.l  #nobord,$120	timer B vector
new4b	jmp     $12345678	pass ontrol to OLD vb vector

nobord	move	#0,($ff8254)
	move	#$007,($ff8256)

	clr.b   $fffffa1b.w	timer stop
	movem.l d0/a1,-(sp)
	move.w  #$fa21,a1
	move.b  #140,(a1)		changing this number had little effect
	move.b  #8,$fffffa1b.w		this line is essential

	move.b  (a1),d0
wait4	cmp.b   (a1),d0			wait last scanline
	beq     wait4		
	clr.b   $ffff820a.w		60 Hz
	moveq   #4,d0
nopi2	nop				wait a while
	dbf     d0,nopi2
	
	move.b  #2,$ffff820a.w		50 Hz
	movem.l (sp)+,d0/a1 
	bclr    #0,$fffffa0f.w	
	rte			 

*------------------------------------------

palette		ds.w	32
		ds.w	10
physbase	dc.l	0
screen_0	dc.l	0
handle		dc.w	0
		ds.w	48
		even


*----------------
*	SET a Sequence of VBI routines  [ C.Maertens ] 20/9/87
* Each routine has to be enabled or disabled separately
* Address of routine expected in A5
* first available slot is usually the second one, first being gem
* move.l #myroutine,$4d2 also does the same job
* see example of TWO vbi's at once in Operation Angelica
enable_vbi
	movem.l	a0-a5,-(sp)
	move.l	$456,a0
enab1	tst.l	(a0)		is is nought? (free)
	beq	enab2
	adda.l	#4,a0
	bra	enab1
enab2	move.l	a5,(a0)		slot in this routine
	movem.l	(sp)+,a0-a5
	rts
*------------
disable_vbi
	movem.l	d0/a0-a5,-(sp)	a5 holds address of routine
	move.l	$456,a0
disab1	cmp.l	(a0),a5		contents of $456 same as routine?
	beq	disab2
disab3	adda.w	#4,a0		try next one
	bra	disab1
disab2	move.l	#0,(a0)		switch it off
	movem.l	(sp)+,d0/a0-a5
	rts


*------------------------------
* message scroller

scroll	tst	vvar1
	bne	tscr18
	cmpi	#16,vvar2
	bls.s	tscr6
	clr	vvar2
tscr3	movea.l	text_address,a0	     scroll variable (holds address of text
	moveq	#0,d0
	move.b	(a0)+,d0
	cmpi.b	#$ff,d0		end of main message?
	beq	tscr11
tscr4	move.l	a0,text_address
	cmp.b	#$20,d0
	ble	tscr12
tscr5	subi.b	#$20,d0
	lea	font,a1		where font is loaded
	lsl	#5,d0
	add	d0,a1
	lea	workspace,a2
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
tscr6	move	speed,d0

tscr7	move.l	screen,d7
	add	#202*160,d7		line of scroll number 2
	
	move.l	d7,old_screen_pos
	move.l	d7,a2  
	lea	workspace,a1
	moveq	#15,d1
tscr8	lsl	(a1)+
	roxl	$98(a2)
	roxl	$90(a2)
	roxl	$88(a2)
	roxl	$80(a2)
	roxl	$78(a2)
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
	roxl	(a2)
	add	#$a0*2,a2
	dbf	d1,tscr8
	addq	#1,vvar2
	dbf	d0,tscr7
	rts

tscr11	lea	text_1,a0	at end of main message, we come..
	move.b	#32,d0		..here again
	bra	tscr4

tscr12	cmp.b	#1,d0		speeds 1 slow  4 fast  5 stop
	beq	tscr13
	cmp.b	#2,d0
	beq	tscr14
	cmp.b	#3,d0
	beq	tscr15
	cmp.b	#4,d0
	beq	tscr16
	cmp.b	#5,d0
	beq	tscr17
	bra	tscr5
tscr13	move.w	#0,speed
	bra	tscr3
tscr14	move.w	#1,speed
	bra	tscr3
tscr15	move.w	#2,speed
	bra	tscr3
tscr16	move.w	#5,speed
	bra	tscr3
tscr17	move.w	#50,vvar1
	move.w	#16,vvar2
	bra	tscr18
tscr18	subi.w	#1,vvar1
	rts


doit	lea	pic+2,a0
	lea	$ff8240,a1
	clr	d0
	move	#15,d0
coll	move	(a0)+,(a1)+
	dbra	d0,coll

	move.l	screen,a1
	clr	d0
	move	#32000/4-1,d0
col2	move.l	(a0)+,(a1)+
	dbra	d0,col2
	rts

* TEXT FOR MESSAGE *
* speed: 1 to 4 (slow-fast)  5 is stop    255 is end
text_1	
	dc.b	4,"   WHATCHA GUYS   AT LAST A BOTTOM BORDER"
	dc.b	" HI TO MIKE AND PHIL    THE MAJORITY OF CODE"
	DC.B	" RIPPED FROM   BUDGIE UK SOURCES BUT NOW IT"
	DC.B	" LOOKS A BIT BETTER   YOOOO     "
	dc.b	"           JOHNNY 99    ",5
	DC.B	"       THE PHF GIVING YOU LOADS"
	DC.B	" OF WHAT FOR           JOHN JOHN IM GONE      "
	DC.B	"    NO BORDER   NO BORER   NO BORDER          "
	DC.B	" WRAP  WRAP  WRAP  WRAP  WRAP FLAP BACK       "
	DC.B	"   LICENCEWARE PHF  ",5
	dc.b	255			
	even

vvar1		ds.w	1
vvar2		ds.w	1
text_address	ds.l	6
workspace	ds.l	69	temp storage for character
speed		ds.w	1
line_one	ds.l	1
old_screen_pos  dc.l 	0
		ds.w	8

font		incbin	"a:\fontish.dat"
pic		incbin	"a:\jack.pi1"
