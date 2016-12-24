********************************************
* MENU CODE BY DODGY KING TWIN PIC + MUSIC *
********************************************

	opt	d+

stack	move.l 	$4(a7),a5
	move.l	4(a5),scradd		Screen address.
	move.l 	#$100,d0
	move.l 	d0,-(a7)
	move.l 	a5,-(a7)
	add.l	#$100,a5			Start of prog.
	move.l 	#$4a0000,-(a7)
	trap 	#1
	add.l 	#$c,a7
	
	dc.w	$a00a			Hide mouse
	bsr	setup	
	clr.l	-(sp)			Into super
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp			Save old super stack
	and.b	#$fe,$484		Keyclick off.

	lea	music,a0			music is outrun
	move.l	#$33462,a2		must go here
	move.w	#5000,d0			size of music

sloop:	move.b	(a0)+,(a2)+		shift it
	dbf	d0,sloop
	jsr	$33462			music maestro
	move.w	#$ffff,d0		pause for a moment

fxlp:	dbf	d0,fxlp

	bsr	setscr			Initialise the screen.
	move.l	#text,a0			Start of scroll text.
	bsr	start			Initialise graphics and text.

main1	bsr	main			Scroll routine.
	move.l	#$600ff,-(sp)		Test keypress.
	trap	#1
	addq.l	#4,sp
	tst.b	d0
	beq.s	main1			No key. Keep looping.

keys:	sub.w	#$30,d0			Strip off ASCII code.
	beq	hertz			ZERO to chnage hertz.
	bmi.s	main1			NO keys below zero.
	cmpi.b	#5,d0			Five games only.
	bge.s	main1			Anything above 5 is no good.
	subq.w	#1,d0			Adjustment for looping.
	move.w	d0,d6			Copy the keycode.
	bsr	fade			end menu

	clr.l	$4da			clear VBL list
	moveq	#$b,d0			reset sound chip
	lea	moff,a0

mlp:	move.b	d0,$ffff8800
	move.b	(a0)+,$ffff8802
	dbf	d0,mlp

; **	Clear the screen

	move.l	scradd,a0
	move.w	#$7d00,d0
lp2:	clr.b	(a0)+
	dbf	d0,lp2

; **	Restore old colors.

	lea	oldcols(pc),a1
	move.l	#$ff8240,a0
	move.w	#7,d0
lp1:	move.l	(a1)+,(a0)+
	dbf	d0,lp1
	
	move.w	d6,d0			Copy keycode selection.
	cmpi.w	#1,d0			Game 1 is inside a folder.
	bne.s	super			Not 1 so skip SET PATHNAME.
	lea	folders,a0		Address of folder names.
	move.l	a0,-(sp)
path:	move.w	#$3b,-(sp)		Set pathname.
	trap	#1
	addq.l	#4,sp

super	move.l	oldsp,-(sp)		Back to user mode.
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

; **	The 1st game (keycode zero) is a GEM game so re-enable the
; **	mouse.

	move.w	d6,d6			Quick test for zero.
	bne.s	scont		
	dc.w	$a009			mouse is on.

scont	bsr	setup

gaming:	lea	games-12,a0		Address of games names-12 for the ADD.L #12,A0
gloop:	add.l	#12,a0
	dbf	d6,gloop			Loop through all names until keycode is zero.

; **	Okay , got the game name. Now LOAD and RUN.

	move.l	#$50000,-(sp)
	move.l	#$50000,-(sp)
	pea	(a0)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
invade:	clr.w	-(sp)			Reset RUNS next file in the AUTO folder.
	trap	#1
hertz:	eori.b	#$fe,$ff820a		Toggle 50/60 hertz.
	bra	main1

; **	Set screen resolution and screen addresses.

setup	move.w	#0,-(sp)			Screen mode.
	move.l	#$ffffffff,-(sp)
	move.l	#$ffffffff,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

folders	dc.b	"pento\",0

setscr:	movem.l	$ff8240,d0-d7		Fast color pickup (all 16).
	movem.l	d0-d7,oldcols		Save them for later.
	move.l	scradd,d0		Get screen address
	add.l	#$7260,d0		Add offset to scroll area.
	move.l	d0,screen		Save it for the scroller.
	move.l	d0,oldlet+2		Insert scroll area into scroll routine.
	movem.l	pic+2,d0-d7		Get picture colors.
	movem.l	d0-d7,$ff8240		Set the colors.
	move.l	#pic+34,a0		Address of picture.
	bsr	setscr2			Drop the screen.
	rts

setscr2	clr.w	-(sp)
	move.l	#$f8000,-(sp)
	move.l	#$f8000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

movepic2	move.l	#piccy2,a0
	move.l	#$f8000,a1
	bsr	inpic

mess	move.w	#15,d1

outloop	move.l	scradd,a3
	move.w	#$3e8e,d0

loop1	ror	(a3)+
	dbf	d0,loop1
	dbf	d1,outloop

mess2	move.w	#15,d1

outloop3	move.l	scradd,a3
	move.w	#$3e8e,d0

loop3	rol	(a3)+
	dbf	d0,loop3
	dbf	d1,outloop3
 
outloop2	move.l	#$f8000,a0
	move.l	#pic+34,a3
	move.l	a0,a1
	move.l	#$7d00,d0
	move.l	a3,a2
	add.l	d0,a1
	add.l	d0,a2
	move.w	#$3e80,d0

loop2	rept	7
	lsl	(a3)
	roxl	(a0)
	lsl	(a2)
	roxl	(a1) 
	endr
	lsl	-(a2)
	roxl	-(a1)
	lsl	(a3)+
	roxl	(a0)+
	dbf	d0,loop2
	rts

inpic:	add.l	#34,a0
	move.l	#$7d00,d0

loop	move.b	(a0)+,(a1)+
	dbf	d0,loop
	rts

moff	dc.b	0,0,0,0,$f8,0,0,0,0,0,0,7

start	move.l	a0,texto			Text start.
	bsr	strung
	move.w	#15,rotter		Make it change char.
	rts
	
  ***** scroll prog  ******

main	addq.w	#1,vcount
	cmpi.w	#4,vcount		No of syncs between writes.
	bne.s	shift
	move.l	$462,d0
vsync	cmp.l	$462,d0			VBL due?
	beq.s	vsync			No.
	clr.w	vcount

; **	A6 - Is current graphic pointer and must be preserved.

shift	cmp.w	#15,rotter		Finished plotting.
	blt.s	oldlet			NO.
	movea.l	texto,a0			YES.Get new char.
 	clr.w	rotter			Reset plot & rotation counter.
	move.b	(a0)+,d0			Get a character.
	bne.s	nxtlet			If last char
	move.l	#text,texto		Then repeat message.
	bra.s	shift

nxtlet	move.l	a0,texto			Save addr of next char.

	cmpi.b	#$ff,d0
	bne.s	nopaws			No pause.
	swap	d1
	move.w	#10,d1
lp11:	move.w	#$ffff,d0
lp12:	dbf	d0,lp12
	dbf	d1,lp11
	swap	d1
	bra.s	main

nopaws	move.l	nfont,a0			Use PRE-SHIFTED font.
	andi.l	#$ff,d0			Clear rubbish.
	sub.l	#32,d0			Subtract ASCII code.
	beq.s	zerod			If SPACE no need to calculate.
	mulu	#128,d0			Size of grafix string.

	add.l	d0,a0			The grafix chars address.
zerod	move.l	a0,a6			Save it for later.

; **	Setscrn initialise the address below to the scroll area.

oldlet	move.l	#$ff260,a0		Start of scroll area.
	movea.l	a6,a1			Get current grafix addr.
	
	moveq.w	#15,d7			Graphic height
	addq.w	#1,rotter		Update rotation & plot counter.
	move.w	rotter,d2		Get it ready for rotating.
oloop	moveq	#3,d6			4 words of grafix
iloop	move.w	(a1)+,d0			Get graphic WORD.
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
	dbf	d6,iloop
	lea	$98(a0),a0		Next pixel line to scroll.
	dbf	d7,oloop
	rts

; **	Turn the graphic data in a continous string.
; **	Speeds up data access.

strung	move.l	nfont,a0			Start of strung out data.
	lea	font+34,a3		Start of graphic data.
	moveq	#5,d4			Number of rows of chars.
outlp	move.w	#19,d5			Chars across.
	movea.l	a3,a1			Save start of row for later.	
	movea.l	a1,a2			Save row start.
midlp0	moveq	#15,d3			Grafix height 16.
midlp	move.w	#3,d6			Words in char width.
inlp	move.w	(a1)+,(a0)+
	dbf	d6,inlp
	add.l	#152,a1			Next graphic row - 8.
	dbf	d3,midlp			Do whole graphic 16x16.
	addq.l	#8,a2			Next grafix block.
	movea.l	a2,a1			Next char along the row.
	dbf	d5,midlp0		Do all 20 char in this row.
	add.l	#$a00,a3			Next graphics row.
	dbf	d4,outlp			All 6 rows.
	rts
	
	EVEN	
vcount	dc.w	0			Vsync counter
rotter	dc.w	0			Counter for grafix plotting
texto	dc.l	0			Points to next character in message
screen	dc.l	$7f39a			Screen address , set to scroll area later.
scrpos	dc.l	0	
build	ds.l	64			Old build buffer for grafix
	EVEN

; **	Each game CAN BE 12 characters long. So FILENAMES are padded
; **	with zeros to make them all 12 characters long. Makes calculating
; **	FILENAMES to use easier.  Just move through them in STEPS of 12.

games	dc.b	"wildlife.prg"
	dc.b	"clown.prg",0,0,0

fade	movem.l	d0-d6/a0,-(sp)
fade1	clr.l	d0
	lea	$ff8240,a0			colour registers
	move.w	#$f,d6				sixteen colours
mloop	move.w	(a0),d1
	and.w	#$777,d1
	cmp.w	#$777,d1
	beq.s	putback
	move.w	#$700,d2
	moveq	#2,d3
ilp	move.w	d1,d4
	and.w	d2,d4
	move.w	#$777,d5
	and.w	d2,d5
	cmp.w	d5,d4
	beq.s	divit
	move.w	d2,d4
	and.w	#$111,d4
	add.w	d4,d1
	moveq	#1,d0
divit	lsr.w	#4,d2
	dbf	d3,ilp
putback	move.w	d1,(a0)+
	dbf	d6,mloop
	move.w	#$ff00,d1
pause	dbf	d1,pause
	tst.l	d0
	movem.l	(sp)+,d0-d6/a0
	rts


oldsp	dc.l	0
text	dc.b	"YES IT'S      MENU 36      FROM DODGYSOFT                       CREDITS:-          CODE BY     DODGY KING AND ROYAL JESTER,     GRAPHICS BY    BROKEN LANCE,     FONT BY     DODGY KING,     MUSIC RIPPED BY      DODGY KING          "
	DC.B	"NOW THATS OVER WE WILL GO TO THE GREETINGS,          PERSONAL HI TO        FRED,     KEI,     BROKEN LANCE,     ACE,     MARTIN.....                    "
	DC.B	"NORMAL GREET'S GO TO:-           POMPEY PIRATES,     THE MEDWAY BOYS,     AUTOMATION,     BBC,     HOTLINE,     FCC     AND     YOU.....              "
	DC.B	"DODGYSOFT CONSISTS OF      DODGY QUEEN,     DODGY KING     AND     ROYAL JESTER.....                WELL THATS ABOUT IT FOR NOW, WATCH OUT FOR OUR NEXT MENU                                  "
	DC.B	"IT'S COMING ROUND AGAIN     >>>>>     >>>>>     >>>>>     >>>>>                                                                            "
	dc.b	" ",0
	EVEN

******** DATA ********

oldcols	ds.l	8
scradd	dc.l	0			Screen address.
chrsize	dc.w	0			Grafix height.
cmask	ds.w	16

font	incbin	"a:\font.pi1",0
music	incbin	"a:\x.bin",0
	EVEN
scrbuf	ds.b	0
pic	incbin	"a:\pic.pi1",0		;menu pic
piccy2	incbin	"a:\pic2.pi1",0		;first pic on show
	EVEN
nfont	dc.l	$50000

