* if you search for the word CHANGE this will show what will
* have to be changed in this scroller (if you want to change it)

* if you search for the word DELETE this will show any code that
* should be deleted for a final menu ( the code to exit on the
* press of the * )

* ALL CODING BY G-STRING
* FONT BY THE OMEN RIPPED BY G-STRING
* the rest is up to you!!!!!!

* look in the folder "FOR_KOPI.TE" FOR SMALL GFA BASIC PROGRAMS
* TO RIP A FONT FROM A PICTURE AND ONE TO RIP A NEW SPRITE TO
* WOBBLE . THE SPRITE HAS TO BE IN THE TOP LEFT OF THE PICTURE
* AND BE THE SIZE 144 pixel ACROSS AND 32 pixels VERTICALLY
* 
* PS YOU DONT NEED THE GFA BASIC AS THE PROGRAMS ARE COMPILED 
*    IF YOU WANT THE SOURCE CODE THEN JUST ASK ME .

* REMEMBER TO CHANGE ASSEMBLE OPTIONS FROM "EXTENDED" TO "NONE"


start	move.l	4(a7),a3		base page
	move.l	#mystack,a7
	move.l	$c(a3),d0		text len
	add.l	$14(a3),d0		data len
	add.l	$1c(a3),d0		BSS len
	add.l	#$100,d0		basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	move.l	#0,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	move.b	#2,$ff820a ; 50Hz
	move.l	#$ff8240,a1
	move.l	#Oldcolours,a0
	movem.l	(a1),d0-d7
	movem.l	d0-d7,(a0)
	move.l	#FromScreen,a0
	add.l	#2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)

	move.l	$44e,Oldscreen
*****display area
	move.l	#512+32000+50*160,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,screenst
	move.l	d0,a0
	add.l	#511,d0
	and.l	#$fffffe00,d0
	move.l	d0,screen
	move.l	d0,a1
	move.l	#(512+32000+50*160)/4-1,d0
scrclr	clr.l	(a0)+
	dbf	d0,scrclr

	move.w	#0,-(sp)
	move.l	a1,-(sp)
	move.l	a1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.l	screen,a1
	move.l	#FromScreen+34,a0
	move.l	#7999,d0
copypicture:
	move.l	(a0)+,(a1)+
	dbf	d0,copypicture

	moveq	#1,d0  ****CHANGE IF ANY OTHERS IN BLOCK
	move.l	runmusic,a0
	move.l	(a0),a0
	jsr	(a0)

	movem.l	(FromScreen+2),d0-d7
	movem.l	d0-d7,(HoldColours)
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	movem.l	d0-d7,(FromScreen+2)

	jsr	hblon

	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	move.w	#15,d0
clicks:
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	#3,d2 ****** CHANGE speed of fade on
anotherblank:
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	dbf	d2,anotherblank
	movem.l	(sp)+,d0-d1/a0-a1

	move.w	#15,d1
	move.l	#FromScreen+2,a0
	move.l	#HoldColours,a1
regcount:
	move.w	(a0)+,d2
	move.w	(a1)+,d3
	move.w	d2,d4
	move.w	d3,d5
	and.w	#$F,d4
	and.w	#$f,d5
	cmp.w	d4,d5
	ble	ok1
	add.w	#1,-2(a0)
ok1	move.w	d2,d4
	move.w	d3,d5
	and.w	#$F0,d4
	and.w	#$f0,d5
	cmp.w	d4,d5
	ble	ok10
	add.w	#$10,-2(a0)
ok10	move.w	d2,d4
	move.w	d3,d5
	and.w	#$F00,d4
	and.w	#$f00,d5
	cmp.w	d4,d5
	ble	okt
	add.w	#$100,-2(a0)
okt	dbf	d1,regcount
	dbf	d0,clicks

****** set up the memory for preshift
	move.l	#chend-ch,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,shift1
	move.l	#chend-ch,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,shift2
	move.l	#chend-ch,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,shift3
	move.l	#chend-ch,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,shift4
**** set up the preshift
	move.w	#((chend-ch)/2)-1,d0
	move.l	#ch,a0
	move.l	shift1,a1
	move.l	shift2,a2
	move.l	shift3,a3
	move.l	shift4,a4
presetup:
	move.w	(a0)+,d6
	move.w	d6,d1
	move.w	d6,d2
	move.w	d6,d3
	move.w	d6,d4
	and.w	#$000f,d1
	and.w	#$00f0,d2
	and.w	#$0f00,d3
	and.w	#$f000,d4
	lsr.w	#4,d2
	lsr.w	#8,d3
	lsr.w	#8,d4
	lsr.w	#4,d4

	move.w	d1,d6
	lsl.w	#4,d6
	add.w	d1,d6
	lsl.w	#4,d6
	add.w	d1,d6
	lsl.w	#4,d6
	add.w	d1,d6
	move.w	d6,(a1)+
	move.w	d2,d6
	lsl.w	#4,d6
	add.w	d2,d6
	lsl.w	#4,d6
	add.w	d2,d6
	lsl.w	#4,d6
	add.w	d2,d6
	move.w	d6,(a2)+
	move.w	d3,d6
	lsl.w	#4,d6
	add.w	d3,d6
	lsl.w	#4,d6
	add.w	d3,d6
	lsl.w	#4,d6
	add.w	d3,d6
	move.w	d6,(a3)+
	move.w	d4,d6
	lsl.w	#4,d6
	add.w	d4,d6
	lsl.w	#4,d6
	add.w	d4,d6
	lsl.w	#4,d6
	add.w	d4,d6
	move.w	d6,(a4)+
	dbf	d0,presetup
*****memory for scroll area (21 chars , each 16 * 4 words)
	move.l	#21*16*8,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,scrollarea
	move.l	d0,a0
	move.l	#21*16*2-1,d0
clear1	clr.l	(a0)+
	dbf	d0,clear1
****************************NOW SET UP MEMORY FOR SPRITE
	move.w	#15,d1
	move.l	#SpriteList,a0
nextsprite:
	move.l	#2560,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,(a0)+
	dbf	d1,nextsprite
***********************NOW SET UP SPRITES
	move.l	DisplaySprite,a0
	add.l	#32,a0
	jsr	makesprite
	move.b	#0,(Rasters) ; to switch on rasters

again:
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	move.w	#255,-(sp)
	move.w	#6,-(sp)
	trap	#1
	lea	4(sp),sp

	cmp.b	#'s',d0
	beq	nextscroller

	cmp.b	#'m',d0
	beq	nextmusic

	cmp.b	#'*',d0 ****DELETE
	beq	desktop ****DELETE

	cmp.b	#'1',d0 *******CHANGE
	beq	run1
	cmp.b	#'2',d0
	beq	run2

	jsr	scrollroute
	jmp	again

RunProg	MACRO	
	move.l #\1,Folder
	move.l #\2,File
	jmp	Loadaway
	ENDM

run1	RunProg	Emp,Prog1 ********CHANGE
run2	RunProg Emp,Prog2

restore:
	jsr	hbloff
	move.l	#$ff8240,a1
	move.l	#Oldcolours,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	move.l	Oldscreen,a1
	move.w	#0,-(sp)
	move.l	a1,-(sp)
	move.l	a1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	move.l	shift1,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	shift2,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	shift3,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	shift4,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	screenst,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#15,d1
	move.l	#SpriteList,a0
RSTnextsprite:
	move.l	(a0)+,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	dbf	d1,RSTnextsprite
	rts
***********************LOADING CODE
Loadaway:
	jsr	restore
	move.l	Folder,-(sp)
	move.w	#$3b,-(sp)
	trap	#1
	addq.l	#6,a7
	move.l	#Empty,-(sp)
	move.l	#Empty,-(sp)
	move.l	File,-(sp)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(a7),a7

	clr.w	-(sp)
	trap	#1

desktop:*******DELETE
	jsr	restore ***DELETE
	clr.w	-(sp) ***DELETE
	trap	#1 ***DELETE

******************** Create a sprite that has a pointer in a0
makesprite
	move.l	(SpriteList),a1
	move.l	#31,d0
copyline:
	movem.l	(a0)+,d1-d7
	movem.l	d1-d7,(a1)
	movem.l	(a0)+,d1-d7
	movem.l	d1-d7,28(a1)
	movem.l	(a0)+,d1-d4
	movem.l	d1-d4,56(a1)
	move.l	#0,72(a1)
	move.l	#0,76(a1)
	lea	80(a1),a1
	dbf	d0,copyline
	move.l	(SpriteList),a0
	move.w	#14,d0
	move.l	#SpriteList,a1
nextblock:
	move.l	(a1)+,a2
	move.l	(a1),a3
	move.w	#(2560/4)-1,d1
zap	move.l	(a2)+,(a3)+
	dbf	d1,zap
	move.l	(a1),a0
	jsr	scrollblock
	dbf	d0,nextblock
	rts
****************************sprite now setup

***************code to change scrollers , Sprite , Rasters
nextscroller
	move.l	nexttext,a0
	cmp.l	#-1,12(a0)
	bne	oknextscroll
	move.l	#linelist-12,a0
oknextscroll
	lea	12(a0),a0
	move.l	a0,nexttext
	move.l	(a0),chrptr
	move.w	#0,chrneed
	move.w	#1,_delay
	move.l	8(a0),CurrentRastList
	move.l	4(a0),a0
	move.l	a0,DisplaySprite
	add.l	#32,a0
	jsr	makesprite
	move.l	scrollarea,a0
	move.l	#21*16*2-1,d0
clearc	clr.l	(a0)+
	dbf	d0,clearc
	jsr	scrollroute
	jmp	again
***************code to change music
nextmusic
	move.l	runmusic,a0
	cmp.l	#-1,4(a0)
	bne	oknextmusic
	move.l	#musiclist-4,a0
oknextmusic
	lea	4(a0),a0
	move.l	a0,runmusic
	move.l	(a0),a0
	moveq	#1,d0
	jsr	(a0)
	jsr	scrollroute
	jmp	again
*******************************subroutine to scroll the sprite in a0
scrollblock:
	movem.w	d0-d1,-(sp)
	move.w	#31,d0
nextline:
	move.w	#3,d1
rotateagain:
	lsr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	roxr.w	64(a0)
	roxr.w	72(a0)
	lea	2(a0),a0
	dbf	d1,rotateagain
	lea	72(a0),a0
	dbf	d0,nextline
	movem.w	(sp)+,d0-d1
	rts

*******************************start of scroll routine
scrollroute:
	move.l	screen,a0
	add.l	#32000,a0
	move.w	#33,d0
	moveq.l	#0,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5
quikclr	movem.l	d1-d7/a1-a5,(a0)
	movem.l	d1-d7/a1-a5,48(a0)
	movem.l	d1-d7/a1-a5,96(a0)
	movem.l	d1-d4,144(a0)
	lea	160(a0),a0
	dbf	d0,quikclr
*********scroll area now clear and will insert sprite
spriterun
	moveq.w	#0,d0
	move.l	CurrentSprite,a0
	move.b	(a0)+,d0

	cmp.b	#253,d0
	bne	trymark
	move.w	SpriteDelay,d0
	tst.w	d0
	blt	getdelayvalue
	beq	skipdelay
	sub.w	#1,SpriteDelay
	move.l	MarkSprite,CurrentSprite
	jmp	spriterun
getdelayvalue
	move.w	#0,d0
	move.b	(a0),d0
	move.w	d0,SpriteDelay
	move.l	MarkSprite,CurrentSprite
	jmp	spriterun
skipdelay
	lea	1(a0),a0
	jmp	oksprite

trymark	cmp.b	#254,d0
	bne	tryend
	move.l	a0,MarkSprite
	move.w	#-1,SpriteDelay
	jmp	oksprite

tryend	cmp.b	#255,d0
	bne	oksprite
	move.l	#SpriteTable,a0

oksprite:
	move.w	SpriteDelay,TspriteDelay
	move.l	MarkSprite,TmarkSprite
	move.l	a0,CurrentSprite
	move.l	a0,a2
	move.l	screen,a1
	add.l	#32160,a1
	move.w	#31,d0
nextspriline:
	moveq.l	#0,d1
	move.b	(a2)+,d1
	cmp.b	#253,d1
	bne	Xtrymark
	move.w	TspriteDelay,d2
	tst.w	d2
	blt	Xgetdelayvalue
	beq	Xskipdelay
	sub.w	#1,TspriteDelay
	move.l	TmarkSprite,a2
	jmp	nextspriline
Xgetdelayvalue
	move.w	#0,d2
	move.b	(a2),d2
	move.w	d2,TspriteDelay
	move.l	TmarkSprite,a2
	jmp	nextspriline
Xskipdelay
	lea	1(a2),a2
	jmp	nextspriline

Xtrymark:
	cmp.b	#254,d1
	bne	Xtryend
	move.l	a2,TmarkSprite
	move.w	#-1,TspriteDelay
	jmp	nextspriline

Xtryend	cmp.b	#255,d1
	bne	spr2
	move.l	#SpriteTable,a2
	move.b	(a2),d1
spr2:
	move.l	d1,d7
	and.w	#$000f,d1
	roxl.w	#2,d1
	move.l	#SpriteList,a0
	add.l	d1,a0
	move.l	(a0),a0
	move.w	#31,d1
	sub.w	d0,d1
	asl.w	#4,d1
	add.w	d1,a0
	asl.w	#2,d1
	add.w	d1,a0
	move.l	a1,a3
	and.w	#$fff0,d7
	ror.w	#1,d7
	add.w	d7,a3

	movem.l	(a0)+,d1-d7
	movem.l	d1-d7,(a3)
	movem.l	(a0)+,d1-d7
	movem.l	d1-d7,28(a3)
	movem.l	(a0)+,d1-d6
	movem.l	d1-d6,56(a3)
	lea	160(a1),a1
	dbf	d0,nextspriline

*******************start scroller
	move.w	_delay,d2
	dbf	d2,displaystart
	move.w	chrneed,d0
	dbf	d0,noneed
*********need new char
	moveq.l	#0,d0
	move.l	chrptr,a0
readchr	move.b	(a0)+,d0
	cmp.b	#254,d0
	bne	nodelay
	moveq.l	#0,d2
	move.b	(a0)+,d2
	move.l	a0,chrptr
	jmp	displaystart
nodelay	cmp.b	#255,d0
	bne	notend
	move.l	nexttext,a0
	move.l	(a0),a0
	bra	readchr
notend	move.l	a0,chrptr
	sub.b	#' ',d0
	move.l	shift4,a1
	move.l	shift3,a2
	move.l	shift2,a3
	move.l	shift1,a4
	lsl.l	#5,d0
	add	d0,a1
	add	d0,a2
	add	d0,a3
	add	d0,a4
	moveq.l	#0,d0
	move.w	insert,d0
	lsl.l	#7,d0
	move.l	scrollarea,d1
	add.l	d1,d0
	move.l	d0,a0
	move.w	#7,d1
copyag	move.l	(a1)+,(a0)+
	move.l	(a2)+,28(a0)
	move.l	(a3)+,60(a0)
	move.l	(a4)+,92(a0)
	dbf	d1,copyag
	move.w	insert,d0
	addq.w	#1,d0
	cmp.w	#20,d0
	ble	insok
	move.w	#0,d0
insok	move.w	d0,insert
	move.w	#3,d0
noneed
	move.w	d0,chrneed
*********display on screen now
	moveq.w	#0,d2
displaystart:
	move.w	d2,_delay
	move.l	screen,a0
	add.l	#32166,a0
	moveq.l	#0,d4
	move.w	insert,d4
	lsl.l	#7,d4
	move.l	scrollarea,a1
	add.l	d4,a1
	moveq.l	#3,d4
	sub.w	chrneed,d4
	lsl.l	#5,d4
	add.l	d4,a1
	move.l	sinpt,a2
	lea	1(a2),a2
	cmp.b	#255,(a2)
	bne	oksin
	move.l	#sintab,a2
oksin	move.l	a2,sinpt
	move.l	scrollarea,a3
	add.l	#20*16*8+3*32,a3
	
	move.w	#19,d7
next	movem.l	(a1)+,d0-d3
	move.l	#$f000f000,d6
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	moveq.l	#0,d5
	move.b	(a2)+,d5
	cmp.b	#255,(a2)
	bne	keepon
	move.l	#sintab,a2
keepon	lsl.l	#5,d5
	move.l	a0,a4
	add.l	d5,a4
	lsl.l	#2,d5
	add.l	d5,a4
	move.w	d0,160(a4)
	swap	d0
	move.w	d0,(a4)
	move.w	d1,480(a4)
	swap	d1
	move.w	d1,320(a4)
	move.w	d2,800(a4)
	swap	d2
	move.w	d2,640(a4)
	move.w	d3,1120(a4)
	swap	d3
	move.w	d3,960(a4)
	movem.l	(a1)+,d0-d3
	cmp.l	a1,a3
	bge	noreset
	move.l	scrollarea,a1
noreset	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	move.w	d0,1440(a4)
	swap	d0
	move.w	d0,1280(a4)
	move.w	d1,1760(a4)
	swap	d1
	move.w	d1,1600(a4)
	move.w	d2,2080(a4)
	swap	d2
	move.w	d2,1920(a4)
	move.w	d3,2400(a4)
	swap	d3
	move.w	d3,2240(a4)
***********************************
	movem.l	(a1)+,d0-d3
	move.l	#$0f000f00,d6
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	moveq.l	#0,d5
	move.b	(a2)+,d5
	cmp.b	#255,(a2)
	bne	keepon2
	move.l	#sintab,a2
keepon2	lsl.l	#5,d5
	move.l	a0,a4
	add.l	d5,a4
	lsl.l	#2,d5
	add.l	d5,a4
	or.w	d0,160(a4)
	swap	d0
	or.w	d0,(a4)
	or.w	d1,480(a4)
	swap	d1
	or.w	d1,320(a4)
	or.w	d2,800(a4)
	swap	d2
	or.w	d2,640(a4)
	or.w	d3,1120(a4)
	swap	d3
	or.w	d3,960(a4)
	movem.l	(a1)+,d0-d3
	cmp.l	a1,a3
	bge	norese2
	move.l	scrollarea,a1
norese2	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	or.w	d0,1440(a4)
	swap	d0
	or.w	d0,1280(a4)
	or.w	d1,1760(a4)
	swap	d1
	or.w	d1,1600(a4)
	or.w	d2,2080(a4)
	swap	d2
	or.w	d2,1920(a4)
	or.w	d3,2400(a4)
	swap	d3
	or.w	d3,2240(a4)
***********************************
	movem.l	(a1)+,d0-d3
	move.l	#$00f000f0,d6
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	moveq.l	#0,d5
	move.b	(a2)+,d5
	cmp.b	#255,(a2)
	bne	keepon3
	move.l	#sintab,a2
keepon3	lsl.l	#5,d5
	move.l	a0,a4
	add.l	d5,a4
	lsl.l	#2,d5
	add.l	d5,a4

	or.w	d0,160(a4)
	swap	d0
	or.w	d0,(a4)
	or.w	d1,480(a4)
	swap	d1
	or.w	d1,320(a4)
	or.w	d2,800(a4)
	swap	d2
	or.w	d2,640(a4)
	or.w	d3,1120(a4)
	swap	d3
	or.w	d3,960(a4)
	movem.l	(a1)+,d0-d3
	cmp.l	a1,a3
	bge	norese3
	move.l	scrollarea,a1
norese3	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	or.w	d0,1440(a4)
	swap	d0
	or.w	d0,1280(a4)
	or.w	d1,1760(a4)
	swap	d1
	or.w	d1,1600(a4)
	or.w	d2,2080(a4)
	swap	d2
	or.w	d2,1920(a4)
	or.w	d3,2400(a4)
	swap	d3
	or.w	d3,2240(a4)
***********************************
	movem.l	(a1)+,d0-d3
	move.l	#$000f000f,d6
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	moveq.l	#0,d5
	move.b	(a2)+,d5
	cmp.b	#255,(a2)
	bne	keepon4
	move.l	#sintab,a2
keepon4	lsl.l	#5,d5
	move.l	a0,a4
	add.l	d5,a4
	lsl.l	#2,d5
	add.l	d5,a4

	or.w	d0,160(a4)
	swap	d0
	or.w	d0,(a4)
	or.w	d1,480(a4)
	swap	d1
	or.w	d1,320(a4)
	or.w	d2,800(a4)
	swap	d2
	or.w	d2,640(a4)
	or.w	d3,1120(a4)
	swap	d3
	or.w	d3,960(a4)
	movem.l	(a1)+,d0-d3
	cmp.l	a1,a3
	bge	norese4
	move.l	scrollarea,a1
norese4	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	or.w	d0,1440(a4)
	swap	d0
	or.w	d0,1280(a4)
	or.w	d1,1760(a4)
	swap	d1
	or.w	d1,1600(a4)
	or.w	d2,2080(a4)
	swap	d2
	or.w	d2,1920(a4)
	or.w	d3,2400(a4)
	swap	d3
	or.w	d3,2240(a4)
	lea	8(a0),a0
	dbf	d7,next
	move.l	sinpt,a0
	lea	1(a0),a0
	cmp.b	#255,(a0)
	bne	zzk
	move.l	#sintab,a0
zzk	move.l	a0,sinpt
	rts
***************************************************end of scroll routine

******************start horizontal blank
hblon:          move.l  $120,oldtb
                move.l  $70,old4
                move.l  $70,new4b+2
                move.b  $fffffa07,old07
                move.b  $fffffa09,old09
                and.b   #$df,$fffa09
                and.b   #$fe,$fffa07 
                move.l  #killborder,$120
                move.l  #new4,$70
                or.b    #1,$fffffa07
                or.b    #1,$fffffa13
                rts

******************stop horizontal blank
hbloff:         move.w  sr,-(sp)
                move.w  #$2700,sr
                move.b  old07(pc),$fffffa07
                move.b  old09(pc),$fffffa09
                move.l  oldtb,$120
                move.l  old4,$70
                move.w  (sp)+,sr
                rts

new4:           movem.l	d0-d7/a0-a6,-(sp)
		move.l	(runmusic),a0
		move.l	(a0),a0
		addq.l	#8,a0
		jsr	(a0)
		clr.b   $fffffa1b.w
                move.b  #199,$fffffa21
                move.b  #8,$fffffa1b
                move.l  #killborder,$120
		movem.l	(FromScreen+2),d0-d7
		movem.l	d0-d7,$ff8240
		movem.l	(sp)+,d0-d7/a0-a6
new4b:          jmp     $12345678

killborder      clr.b   $fffffa1b.w
                movem.l d0-d3/a0-a1,-(sp)
                move.w  #$fa21,a1
                move.b  #200,(a1)
                move.b  #8,$fffffa1b.w

                move.b  (a1),d0
wait4:          cmp.b   (a1),d0
                beq     wait4		
                clr.b   $ffff820a.w
		REPT	15
		nop			; wait a while
                ENDR
                move.b  #2,$ffff820a.w  ;50 Hz
		move.l	DisplaySprite,a0
		move.l	(a0),$ff8240
		move.l	4(a0),$ff8244
		move.l	8(a0),$ff8248
		move.l	12(a0),$ff824c
		move.l	CurrentRast,a0
		move.w	(a0)+,d2
		cmp.w	#$ffff,d2
		bne	okraster
		move.l	CurrentRastList,a0
		move.w	(a0),d2
okraster	move.l	a0,CurrentRast
		move.w	d2,d3
		swap	d2
		move.w	d3,d2
		move.l	d2,$ff8250
		move.l	d2,$ff8254
		move.l	d2,$ff8258
		move.l	d2,$ff825c
		cmp.b	#1,(Rasters)
		beq	norastersyet
		move.w	#14,d1
againras        move.b  (a1),d0
wait4b          cmp.b   (a1),d0
                beq     wait4b
                move.b  (a1),d0
wait4c          cmp.b   (a1),d0
                beq     wait4c
		move.w	(a0)+,d2
		cmp.w	#$ffff,d2
		bne	okrasterb
		move.l	CurrentRastList,a0
		move.w	(a0),d2
okrasterb	move.w	d2,d3
		swap	d2
		move.w	d3,d2
		move.l	d2,$ff8250
		move.l	d2,$ff8254
		move.l	d2,$ff8258
		move.l	d2,$ff825c
		dbf	d1,againras
norastersyet	movem.l (sp)+,d0-d3/a0-a1       
                bclr    #0,$fffffa0f.w  ;end of interrupt
                rte


line1 ********CHANGE
 dc.b '  A QUICK WORD ..... SEARCH FOR LINELIST AND LOOK TO CHANGE '
 dc.b 'THE SPRITE .... IT GIVES A DELAY BEFORE BUT THIS IS THE'
 dc.b ' ONLY WAY IT WILL WORK ..............'
 dc.b ' HELLO WORLD  THIS IS A BLOODY SHIT LOOKING MENU ..... PRESS'
 DC.B ' M TO CHANGE THE MUSIC AND S TO CHANGE THE SCROLLER .... IN EACH SCROLLER'
 DC.B ' I WILL EXPLAIN A PART OF THIS MENU SOURCE ..... SO DO IT NOW ....'
 DC.B '.... G STRING .....',254,200,'      .... WARP ....',255
line2
 dc.b ' THIS IS THE FUNCTIONS IN THE SPRITE WOBBLE TABLE      '
 DC.B ' 254 WILL MARK THE START OF A BLOCK      '
 DC.B ' 253 FOLLOWED BY A NUMBER WILL MARK THE END OF A BLOCK '
 DC.B ' AND REPEAT THE BLOCK BY "NUMBER"        '
 DC.B ' 255 WILL FINISH THE LIST ALL OTHER VALUES ARE BETWEEN '
 DC.B ' 0 AND 180 (APPROX) FOR THE NUMBER OF PIXELS ACROSS    '
 DC.B '.... G STRING .....',254,200,'      .... WARP ....',255
line3
 dc.b ' IF YOU LOOK AT THE SOURCE AT THE BOTTOM OF SEARCH FOR '
 DC.B 'THE ****CHANGE IN THE SOURCE YOU WILL FIND THE LISTS THAT '
 DC.B 'YOU CAN EASILY CHANGE AND THE TEXT BLOCKS ...'
 DC.B '.... G STRING .....',254,200,'      .... WARP ....',255
line4
 dc.b ' THIS IS A BIT DULL .... I THINK I WILL TRY TO FIND A '
 DC.B 'NEW LOGO TO MOVE AND IF I HAVE TIME TONIGHT I WILL TRY'
 DC.B ' TO GET A DECENT SPRITE WOBBLE LIST .... '
 DC.B '.... G STRING .....',254,200,'      .... WARP ....',255
 EVEN
linelist
 dc.l	line1,Sprite1,RastList1 ****CHANGE add as many as you want
 dc.l	line2,Sprite2,RastList2
 dc.l	line3,Sprite2,RastList3
 dc.l	line4,Sprite1,RastList2
 dc.l	-1
runmusic	dc.l	musiclist
musiclist	dc.l	music1,music2,music3,music4,music5,-1 ****CHANGE add as many as you want SEE BELOW OF THE INCBINS

		ds.l	100			stack space
mystack		ds.l	0			(stacks go backwards)

sinpt		dc.l	sintab
insert		dc.w	0
chrptr		dc.l	line1
chrneed		dc.w	0
nexttext	dc.l	linelist
_delay		dc.w	1
old4		dc.l	0
oldtb		dc.l	0
old07		dc.b	0
old09		dc.b	0
shift1		dc.l	0
shift2		dc.l	0
shift3		dc.l	0
shift4		dc.l	0
scrollarea	dc.l	0
screenst	dc.l	0
screen		dc.l	0
DisplaySprite	dc.l	Sprite1
SpriteList	ds.l	16
CurrentSprite	dc.l	SpriteTable
SpriteDelay	dc.w	0
TspriteDelay	dc.w	0
MarkSprite	dc.l	SpriteTable
TmarkSprite	dc.l	0
CurrentRast	dc.l	RastList1
Oldcolours	ds.l	8
Oldscreen	dc.l	0
Folder		dc.l	0
File		dc.l	0
HoldColours	ds.l	8
CurrentRastList	dc.l	RastList1
sintab******CHANGE any value from 0 to 18
 dc.b 0,0,0,0,1,1,1,2,2,3,4,5,5,6,7,9,10,11,11,12,13,14,14,15,15,15,16,16,16
 dc.b 16,16,16,15,15,15,14,14,13,12,11,11,10,9,7,6,5,5,4,3,2,2,1,1,1,0,0,0,255
SpriteTable ******CHANGE any value from 0 to 180

 dc.b 90,80,70,60,50,40,30,20,10,0

 dc.b 254 **** mark as start of the block

 dc.b 0,0,0,0,1,1,1,2,2,3,4,5,5,6,7,9,10,11,11,12,13,14,14,15,15,15,16,16,16
 dc.b 16,16,16,15,15,15,14,14,13,12,11,11,10,9,7,6,5,5,4,3,2,2,1,1,1,0,0,0

 dc.b 253,5 **** mark end of block and repeat 5 times

 dc.b 0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90

 dc.b 255 *** end of list
 
Rasters	dc.b 1
Emp	dc.b 'A:\'
Empty	dc.b 0
	EVEN

RastList1 *********CHANGE
 dc.w $000,$100,$200,$300,$400,$500,$600,$700,$600,$500,$400,$300,$200,$100,$ffff
RastList2
 dc.w $000,$010,$020,$030,$040,$050,$060,$070,$060,$050,$040,$030,$020,$010,$ffff
RastList3
 dc.w 0,1,2,3,4,5,6,7,5,3,1,$ffff


Sprite1		INCBIN	'a:\other_bi.ts\gforce.ady'******CHANGE
	even
Sprite2		INCBIN	'a:\other_bi.ts\gstring.ady'
	even

FromScreen	INCBIN	'a:\pictures\horn_god.pi1' ******CHANGE

ch		INCBIN	'a:\fonts\medfnt.161'      ******CHANGE
chend
music1	incbin	'a:\music\sowhat.mus'
	even
music2	incbin	'a:\music\sowhat1.mus'
	even
music3	incbin	'a:\music\sowhat2.mus'
	even
music4	incbin	'a:\music\sowhat3.mus'
	even
music5	incbin	'a:\music\sowhat4.mus'
	even

Prog1	dc.b 'degas.prg',0		******CHANGE
Prog2	dc.b 'adytool.tos',0