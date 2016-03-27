***************************************************************************
******* QUARTET MUSIC + PLAYER RIPPED FROM P.PIRATES BY -DAZZER- ********** 
************************** SCROLLER BY -J.F.B- ****************************
*********************** SHIT PICTURE BY -DAZZER- **************************
**************************  FOR THE INTRUDER  *****************************

start	bsr	super
	bsr	savecols
	bsr	setscr
	bsr	setpal
	bsr	putpic
	bsr	quartet		-start quartet music-

************* Main loop **************
main	bchg	#1,flag
	bsr	scroller
	cmp.b	#$39,$fffc02
	bne	main	
	bra	exit

*********** Scroller *************
scroller	tst.w	chrsize		Finished plotting.
	bne	oldlet		NO.
	movea.l	textpnt,a3		YES.Get new char.
nostop	move.b	(a3)+,d7
	bne.s	nxtlet		If last char
	move.l	#text,textpnt	Then repeat message.
 	bra.s	scroller
nxtlet	move.l	a3,textpnt		Save addr of next char.
	lea	font+34,a3
	lea	build,a5
	andi.l	#$ff,d7		Clear rubbish.
	sub.l	#32,d7		Sub start of grphcs
	beq.s	zerod
	divu	#20,d7		Number chars in row.
	move.w	d7,sav		Num rows into D1.
	swap	d7		Remainder back.
	ext.l	d7		Clear it.
	lsl.l	#3,d7		Multiply by 8.
	add.l	d7,a3
	move.w	sav,d7
	mulu	#$a00,d7		Width of rows.
	add.l	d7,a3
zerod	move.w	#15,d7		Graphic height
bloop	move.l	(a3)+,(a5)+	Move char into buffer.
	move.l	(a3)+,(a5)+
	add.l	#152,a3		Next line.
	dbf	d7,bloop
	move.w	#16,chrsize	Grafix width.
oldlet	subq.w	#1,chrsize
	lea	build,a5
	cmp.b	#2,flag
	beq	rollbott
	bsr	vsync
rollbott	move.l	poss,a3
	move.w	#15,d7		Graphic height
oloop	nop
	rept	3
	move.b	#0,ccr		clear extend bit.
	roxl	(a5)+		Get graphic bit.
	roxl	152(a3)
	roxl	144(a3)
	roxl	136(a3)
	roxl	128(a3)
	roxl	120(a3)
	roxl	112(a3)
	roxl	104(a3)
	roxl	96(a3)
	roxl	88(a3)
	roxl	80(a3)
	roxl	72(a3)
	roxl	64(a3)
	roxl	56(a3)
	roxl	48(a3)
	roxl	40(a3)
	roxl	32(a3)
	roxl	24(a3)
	roxl	16(a3)
	roxl	8(a3)
	roxl	(a3)+
	endr
	add.l	#2,a3
	add.l	#2,a5
;	dbf	d6,iloop
	lea	152(a3),a3	Next line to scroll.
	dbf	d7,oloop
;	movem.l	(sp)+,d0-d7/a0-a7			
	rts

**************** Routines *****************
super	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	rts

vsync	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

setscr	move.w	#0,-(sp)
	move.l	screen,-(sp)
	move.l	screen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

setpal	move.l	#pink+2,-(sp)
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	rts

putpic	move.l	#$7d00-1,d0
	move.l	#pink+34,a0
	move.l	#$f8000,a1
.1	move.b	(a0)+,(a1)+
	dbf	d0,.1
	rts

restcols	movem.l	oldcols,d0-d7
	movem.l	d0-d7,$ff8240
	rts

savecols	movem.l	$ff8240,d0-d7
	movem.l	d0-d7,oldcols
	rts

exit	jsr	singsong+$1c+8
	bsr	restcols
	clr.w	-(sp)
	trap	#1

quartet	lea	singsong,a0	
	move.l	2(a0),d0
	move.l	a0,a1
	lea	$1f(a1),a1
	add.l	d0,a1
	lea	$1c(a0),a0
	move.l	a0,d7
	moveq	#0,d0
rel1	move.b	(a1)+,d0
	beq.s	end
	cmp.b	#1,d0
	bne.s	rel2
	lea	$fe(a0),a0
	bra.s	rel1
rel2	add.l	d0,a0
	add.l	d7,(a0)
	bra.s	rel1
end
	lea	singsong+$1c,a0
	move.l	#song,$c(a0)
	move.l	#inst,$10(a0)
	jsr	4(a0)
	rts

************** Data ****************
textpnt	dc.l	text
text	dc.b	"THIS ONE IS FOR THE INTRUDER"
	dc.b	$ff				-terminator-

flag	dc.l	0
sav	dc.l	0
poss	dc.l	$f8000+160*185		-scroller position-
screen	dc.l	$f8000 
chrsize	dc.w	0
oldcols	ds.w	16
build	ds.b	128
	ds.b	128

font	incbin	"font.pi1"
singsong	incbin	"source\player.bin"
song	incbin	"rtune19.4v"
inst	incbin	"v7.set"
pink	incbin	"darkcyrs.pi1"	-any pi1 picture-



