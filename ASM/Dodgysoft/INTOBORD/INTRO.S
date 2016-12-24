	opt	d+

; **	Don't forget to DE-ALLOCATE MEMORY 1ST !!

start1	move.l	#mystack,a7
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	sub.l	#32000,d0		Make room for border.
	move.l	d0,screen
	
start	bsr	super
	
	bsr	mouseoff
	clr.b	$484			All off
	bsr	savecols
	bsr	hblon
	bsr	setscr			Log it on
	bsr	playmus
	jsr	movepic1
setcols	move.l	#pic1+2,a0		pallette
 	bsr	setpal
	bsr	vsync
	
	bsr	strung			Remove this if using STEWS prog
	move.w	#15,rotter		Set to let routine pickup 1st char
	
  ***** scroll prog  ******

main	move.l	#$600ff,-(sp)		Test keypress.
	trap	#1
	addq.l	#4,sp
	tst.b	d0
	bne	exit			Who pressed a key!
	bsr	vsync
					
; **	A6 - Is current graphic pointer and must be preserved throughout
; **	     the plotting of a WHOLE character.

shift	cmp.w	#15,rotter		Finished plotting.
	blt.s	oldlet			NO.
.nextch	movea.l	text,a0			YES.Get new char.
 	clr.w	rotter			Reset plot & rotation counter.
	move.b	(a0)+,d0		Get a character.
	bne.s	nxtlet			If last char
	move.l	#texto,text
	bra.s	.nextch

nxtlet	move.l	a0,text			Save addr of next char.
	lea	nfont,a0		Use pre-shifted grafix font.
	andi.l	#$ff,d0			Clear rubbish.
	sub.l	#32,d0			get rid of ASCII coding.
	beq.s	zerod			Space is 1st char , no calc
	asl.w	#7,d0			Size of grafix string (128 bytes).

	add.l	d0,a0			The grafix chars address.
zerod	move.l	a0,a6			Save it for later.

oldlet	move.l	border,a0		Start of scroll area.
	movea.l	a6,a1			Get current grafix addr.
	
	moveq.w	#15,d7			Graphic height
	addq.w	#1,rotter		Update rotation & plot counter.
	move.w	rotter,d2		Get it ready for rotating.

iloop	REPT	4
	move.w	(a1)+,d0		Get graphic WORD.
	lsl.w	d2,d0			Rotate D2 times.
	roxl	$98(a0)
	roxl	$90(a0)
	roxl	$88(a0)
	roxl	$80(a0)
	roxl	$78(a0)
	roxl	$70(a0)
	roxl	$68(a0)
	roxl	$60(a0)
	roxl	$58(a0)
	roxl	$50(a0)
	roxl	$48(a0)
	roxl	$40(a0)
	roxl	$38(a0)
	roxl	$30(a0)
	roxl	$28(a0)
	roxl	$20(a0)
	roxl	$18(a0)
	roxl	$10(a0)
	roxl	8(a0)
	roxl	(a0)+
	ENDR
	lea	$98(a0),a0		Next pixel line to scroll.
	dbf	d7,iloop
	bra	main
		
text	dc.l	texto
texto	dc.b	131,132,133,134,135,136,137,138,139
	dc.b	"            For GANDALF , BITBOX , MAVERICK       "
	dc.b	" This was coded by J.P.M   1990    "
	dc.b	"       GOOD LUCK GUY'S           "
	dc.b	" Hey Jason look no mouse!!         "
	dc.b	0

****** Back to desktop *********

exit	andi.w	#$df,d0			Force to uppercase
	bsr	hbloff
	bsr	mouseon
	bsr	restcols
	dc.w	$a009
	clr.l	$4d2			Remove music program
	bsr	musicoff		Kill P.S.G
	bsr	user	
	clr.w	-(sp)
	trap	#1

********************************
*           ROUTINES           *
********************************

vsync	addq.w	#1,vcount
	cmpi.w	#3,vcount		2=slow / 3=medium /4=fast.
	blt.s	.exit
	clr.w	vcount
	move.l	$462,d0
.1	cmp.l	$462,d0
	beq.s	.1
.exit	rts

vcount	dc.w	0
	
hblon	move.l  $120,oldtb
	move.l  $70,old4
	move.l  $70,new4b+2
	move.b  $fffffa07,old07
	move.b  $fffffa09,old09
	move.b  $fffffa0f,old0f
	move.b  $fffffa11,old11
	move.b  $fffffa1b,old1b
	move.l	$456,oldvblq
	and.b   #$df,$fffa09
	and.b   #$fe,$fffa07 
	move.l	#killb,$120
	move.l  #new4,$70
	or.b    #1,$fffffa07
	or.b    #1,$fffffa13
	rts

hbloff	move.w  sr,-(sp)
	move.w  #$2700,sr
	move.b  old07(pc),$fffffa07
	move.b  old09(pc),$fffffa09
	move.b  old0f(pc),$fffffa0f
	move.b  old11(pc),$fffffa11
	move.b  old1b(pc),$fffffa1b
	move.l	oldvblq,$456
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
oldvblq	dc.l	0
	EVEN

; **	This is the VBL handler

new4	clr.b   $fffffa1b.w
	move.b  #199,$fffa21		kill the border
	move.b  #8,$fffffa1b
	move.l  #killb,$120		Timer B vector
new4b	jmp	$12345678		Old vbl vector.

; **	The HBL routine for the border.

killb	clr.b   $fffffa1b.w     	timer stop
	movem.l d0-d1/a0-a1,-(sp)
	move.w  #$fa21,a1		Timer b reg
	move.b  #8,$fffffa1b.w		enable timer b.

	move.b  (a1),d0
wait4	cmp.b   (a1),d0			wait last scanline
	beq     wait4		
	clr.b   $ffff820a.w     	60 Hz
	moveq   #3,d0
nopi2	nop				wait a while
	dbf     d0,nopi2
	move.b  #2,$ffff820a.w  	50 Hz
	movem.l (sp)+,d0-d1/a0-a1
	move.l	#blank,$120
	bclr    #0,$fffffa0f.w  	end of interrupt
	rte

blank	move.b  #8,$fffffa1b.w		enable timer b.
	bclr    #0,$fffffa0f.w  	end of interrupt
	rte

super	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	move.l	d0,oldsp
	rts
user	move.l	#oldsp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	rts

; **	Starting : foreground screen is scr1=f8000
; **	         : background   ''   is scr2=e8600

setscr	move.w	#0,-(sp)
	move.l	screen,-(sp)
	move.l	screen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.l	screen,a0
	add.l	#160*200,a0
	move.l	a0,border
	rts

setpal	move.l	a0,-(sp)
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	rts
restcols	
	move.l	#$ff8240,a1
	move.l	#oldcols,a0
	move.w	#15,d0
loop1	move.w	(a0)+,(a1)+
	dbf	d0,loop1
	rts
savecols	
	move.l	#$ff8240,a0
	move.l	#oldcols,a1
	move.w	#15,d0
loop5	move.w	(a0)+,(a1)+
	dbf	d0,loop5
	rts
movepic1	
	move.l	#pic1+34,a0
	move.l	screen,a1
	move.l	#$7d00-1,d0
loop	move.b	(a0)+,(a1)+
	dbf	d0,loop

	move.w	#5120,d1		Border size
	move.l	screen,a0
	move.l	(a0),d0			Fetch screen contents
	add.l	#160*200,a0		point to the border
m2lp	move.l	d0,(a0)+		move screen background to border
	dbf	d1,m2lp
	rts
musicoff
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)		clear psg channel a,
	move.l	#$9090000,(a0)		b...
	move.l	#$a0a0000,(a0)		and c.
	move.b	#6,$484.w		keyclick back
	rts

; **	Turn the graphic data in a continous string.
; **	Speeds up data access. Used to reduce instruction count
; **	during the horrendously slow scroll loop.
; **	Only use with 16x16 font and make sure to create the
; **	font in ASCII order for quicker access.

strung	movem.l	d0-d7/a0-a6,-(sp)
	lea	nfont,a0		Start of strung out data.
	lea	font+34,a3		Start of graphic data.
	moveq	#5,d4			Number of rows of chars.
outlp	moveq	#19,d5			Chars across.
	movea.l	a3,a1			Save start of row for later.	
	movea.l	a1,a2			Save row start.
midlp0	moveq	#15,d3			Grafix height 16.
midlp	moveq	#3,d6			Words in char width.
inlp	move.w	(a1)+,(a0)+
	dbf	d6,inlp
	lea	152(a1),a1		Next graphic row - 8.
	dbf	d3,midlp		Do whole graphic 16x16.
	addq.l	#8,a2			Next grafix block.
	movea.l	a2,a1			Next char along the row.
	dbf	d5,midlp0		Do all 20 char in this row.
	lea	$a00(a3),a3		Next graphics row.
	dbf	d4,outlp		All 6 rows.
	movem.l	(sp)+,d0-d7/a0-a6
	rts
mouseoff	move.l	#moff,-(sp)	mouse off
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	dc.w	$a00a
	rts

mouseon	move.l	#mon,-(sp)	mouse on
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	dc.w	$a009
	rts

	include	'a:\intobord\music.s'
		
********************************
*            data              *
********************************

moff	dc.b	$12	
mon	dc.b	$8
border	dc.l	0

screen	dc.l	$f8000
oldsp	dc.l	0	
oldcols	ds.w	16
chrsize	dc.w	0
rotter	dc.w	0
graff	dc.l	0

nfont	ds.w	5120

font	incbin	"a:\font.pi1"
pic1	incbin	"a:\pic.pi1"

	ds.l	510
mystack	dc.w	0
	EVEN
finish
