*
* An Intro Made By The Copy Syndicate Holland.
* 
* All Coding & Logo: AWA Of The CSH
* Font By: ES Of TEX
* Musix By A Lotta People.

* In this demo are routines for:
*
* Tracking Sprites
* Colour Scroller
* Byte Bender
* Stars
* Colour Waver

* This demo was coded in 1989.

* Though you can still contact me:

* E-Mail : Arjen Wagenaar (Only For People With A Modem!)
*	   2:281/801.4

* Home   : Arjen Wagenaar
*	   Dorpsweg 32a
*	   1711rj Hensbroek
*	   The Netherlands

* a6 Is Used In The HBL, So Don't Use It In The Main Program !

SpriteCount	equ	11
SpriteHeight	equ	15
SpriteDistance	equ	3		In Coordinates
SpritePlane	equ	1		Sprite Consist Of One Plane
AllReg		reg	d0-d7/a0-a6
BackgroundFlag	equ	0
CharHeight	equ	18		For The Byte-Bender
ScrLines	equ	16
EOText		equ	128
StarCount	equ	40

FASTMENU
	move.l	4(sp),a5		Reserve Memory
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	pea	(a5)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	clr.l	-(sp)			Super
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,OldStack

	move.b	$ffff8260.w,d0		Get Resolution
	and.w	#3,d0
	move.w	d0,OldRes

	move.l	$44e.w,OldScreen	Get Screen Address

	movem.l	$ffff8240.w,d0-d7	Get Palette
	movem.l	d0-d7,OldColors
	movem.l	NewPalette,d0-d7	Clear Palette
	movem.l	d0-d7,$ffff8240.w

	pea	MOff(pc)		No Mouse
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.w	#8,sp
	dc.w	$a00a

	move.l	#ScreenBuf+256,d0	Reserve Space For 2 Screens
	and.l	#$ffffff00,d0
	move.l	d0,Screen1
	add.l	#32000+(64*160),d0
	move.l	d0,Screen2
	move.l	d0,LogScreen
	move.l	#SpriteBufferListPhys,LogBuffer

	clr.w	-(sp)			Low Res
	move.l	Screen1(pc),-(sp)
	pea	-1.w
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	lea	MainScr(pc),a0		Copy Palette To Buffer
	movem.l	4(a0),d0-d7		Copy Main-Screen To The
	movem.l	d0-d7,NewPalette	Two Screens
	lea	128(a0),a0
	move.l	Screen1(pc),a1
	move.l	Screen2(pc),a2
	move.w	#32000/4-1,d0
.Loop2	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,.Loop2

	lea	SpriteBufferListPhys,a2
	lea	SpriteBufferPhys,a3
	lea	SpriteBufferListLog,a4
	lea	SpriteBufferLog,a5
	moveq	#SpriteCount-1,d0
.Loop1	move.l	a3,(a2)+
	move.l	a5,(a4)+
	IFNE	BackgroundFlag
	lea	4+(8*1*SpriteHeight)(a3),a3	4+4Words*1Plane*15Lines
	lea	4+(8*1*SpriteHeight)(a5),a5	(4=Clear Offset)
	ENDC
	IFEQ	BackgroundFlag
	addq.w	#4,a3
	addq.w	#4,a5
	ENDC
	dbf	d0,.Loop1

	lea	SpritePos,a0
	lea	SpritePosList,a1
	lea	(SpriteCount-1)*SpriteDistance*4(a0),a0
	REPT	3-1
	move.l	a0,(a1)+
	lea	-SpriteDistance*4(a0),a0	First 3 Sprites    (AWA)
	ENDR
	move.l	a0,(a1)+
	lea	2*(-SpriteDistance*4)(a0),a0	The Space ( )
	REPT	2-1
	move.l	a0,(a1)+
	lea	-SpriteDistance*4(a0),a0	The Fourth+Fifth   (OF)
	ENDR
	move.l	a0,(a1)+
	lea	2*(-SpriteDistance*4)(a0),a0	The Space ( )
	REPT	3-1
	move.l	a0,(a1)+
	lea	-SpriteDistance*4(a0),a0	The 6th+7th+8th    (THE)
	ENDR
	move.l	a0,(a1)+
	lea	2*(-SpriteDistance*4)(a0),a0	The Space ( )
	REPT	3-1
	move.l	a0,(a1)+
	lea	-SpriteDistance*4(a0),a0	The Last 3 Sprites (CSH)
	ENDR
	move.l	a0,(a1)+

* PreShift Sprites

	moveq	#SpriteCount-1,d4
	lea	SprShift(pc),a1
	lea	SpriteGraph(pc),a0
	move.l	a0,a3
Shft3	moveq	#0,d7
	move.l	(a1)+,a2
	moveq	#16-1,d5
Shft2	moveq	#SpriteHeight-1,d6
Shft1	moveq	#0,d1
	moveq	#0,d2
	move.w	(a0)+,d1		Get Plane Of Sprite (First 16Pix)
	move.w	(a0)+,d2		Get Plane Of Sprite (Next 16Pix)
	lsl.l	d7,d1			Shift It
	lsl.l	d7,d2
	or.w	d1,2(a2)
	or.w	d2,4(a2)
	swap	d1
	swap	d2
	or.w	d1,(a2)
	or.w	d2,2(a2)
	addq.w	#6,a2
	dbf	d6,Shft1
	addq.w	#1,d7
	move.l	a3,a0
	dbf	d5,Shft2
	lea	4*SpriteHeight(a3),a3
	move.l	a3,a0
	dbf	d4,Shft3

* Scroller Based On A TEX Routine

	move.l	#CharDat,d2
	move.l	d2,Charset
Create	moveq	#10-1,d0		We've Got 10 Characters
	lea	CharTable,a0		Vertically

Line	moveq	#10-1,d1		And 10 Horizontally
Col	move.l	d2,(a0)+		Set Pointer To Character
	addq.l	#4,d2			In Table
	dbf	d1,Col
	add.l	#(CharHeight-1)*40,d2
	dbf	d0,Line

	lea	WasteRelativ,a0
	lea	WasteMusic,a1
	lea	$1c(a1),a1
	move.l	a1,d1
	add.w	(a0)+,a1
	add.l	d1,(a1)
	moveq	#0,d0
Rel0	move.b	(a0)+,d0
	beq.s	Rel2
	cmp.b	#1,d0
	bne.s	Rel1
	lea	254(a1),a1
	bra.s	Rel0
Rel1	add.w	d0,a1
	add.l	d1,(a1)
	bra.s	Rel0
Rel2
	bsr	DrawSprite		Draw The Sprites On The Screen
	bsr	DrawSprite		Set The Clear-Offset
						
	lea	StarTable,a0
	lea	$100.w,a1
	moveq	#StarCount-1,d0
	move.w	d0,(a0)+
	moveq	#6,d1
	move.w	#319,d2
	moveq	#0,d3
InitStars
	move.w	d2,(a0)+
	move.w	d1,(a0)+
	move.b	(a1)+,d3
	add.w	d3,d2
.Nxt2	subq.w	#1,d1
	bne.s	.Nxt1
	moveq	#6,d1
.Nxt1	dbf	d0,InitStars

	st	Speed

	movem.l	NewPalette,d0-d7	Install New Palette
	movem.l	d0-d7,$ffff8240.w

	move.l	$120.w,OldTB
	move.l	$70.w,Old4
	move.l	$118.w,OldKey
	move.b	$fffffa07.w,Old07
	move.b	$fffffa09.w,Old09
	move.b	$fffffa13.w,Old13
	move.b	$fffffa15.w,Old15
	move.b	$fffffa1b.w,Old1b
	move.b	$fffffa17.w,Old17
	and.b	#%11011111,$fffffa09.w	Disable Timer C
	and.b	#%11111110,$fffffa07.w	Disable Timer B
	and.b	#%11110111,$fffffa17.w	Automatic End Of Interrupt
	move.l	#TheCSHColours,$120.w	Timer B Rout
	move.l	#New4,$70.w		New Level 4
	move.l	#NewKey,$118.w		New Key
	or.b	#%00000001,$fffffa07.w	Enable Timer B
	or.b	#%00000001,$fffffa13.w

	move.b	#0,NowPlay
	move.l	#XenonMusic+$112,$4da.w
	jsr	XenonMusic

* Some Scancodes: S=$9f, F1=$bb, 1=$82, SPC=$b9

GetKey	move.w	VblCount(pc),d0
.Same	cmp.w	VblCount(pc),d0
	beq.s	.Same

	moveq	#0,d0
	move.b	$fffffc02.w,d0
	cmp.b	#$9f-128,d0		'S'   Slow Speed
	bne.s	Key_F
	sf	Speed
Key_F	cmp.b	#$a1-128,d0		'F'   Fast Speed
	bne.s	Key_SPC
	st	Speed
Key_SPC	cmp.b	#$b9-128,d0		' '   End Of Demo
	beq	OldVec
Key_1	cmp.b	#$82-128,d0		'1'
	bmi.s	GetKey
	cmp.b	#$84+1-128,d0		'3'
	bpl.s	Key_4
	addq.b	#7,d0
	cmp.b	NowPlay(pc),d0
	beq.s	GetKey
	move.b	d0,NowPlay
	sub.b	#9,d0
	jsr	InitGold
	move.l	#GoldII,$4da.w
	bra.s	GetKey
Key_4	cmp.b	#$85-128,d0		'4'
	bmi.s	GetKey
	cmp.b	#$8b+1-128,d0		'0'
	bpl.s	Key_F1
	add.b	#10,d0
	cmp.b	NowPlay(pc),d0
	beq	GetKey
	move.b	d0,NowPlay
	sub.b	#15,d0
	jsr	InitPlat
	move.l	#Platoon,$4da.w
	bra	GetKey
Key_F1	cmp.b	#$3b,d0			'F1'  Music Nr One
	bmi	GetKey
	cmp.b	#$3d+1,d0		'F3'  Music Nr Three
	bpl.s	Key_F4
	sub.b	#$3b,d0
	cmp.b	NowPlay(pc),d0
	beq	GetKey
	move.b	d0,NowPlay
	move.l	#XenonMusic+$112,$4da.w
	jsr	XenonMusic
	bra	GetKey
Key_F4	cmp.b	#$3e,d0			'F4'
	bmi	GetKey
	cmp.b	#$41+1,d0		'F7'
	bpl.s	Key_F8
	sub.b	#$3b,d0
	cmp.b	NowPlay(pc),d0
	beq	GetKey
	move.b	d0,NowPlay
	subq.b	#3,d0
	move.l	#GenesisMusic+$106,$4da.w
	jsr	GenesisMusic
	bra	GetKey
Key_F8	cmp.b	#$42,d0			'F8'
	bmi	GetKey
	cmp.b	#$43+1,d0		'F9'
	bpl	Key_aa
	sub.b	#$3b,d0
	cmp.b	NowPlay(pc),d0
	beq	GetKey
	move.b	d0,NowPlay
	subq.b	#6,d0
	move.l	#WasteMusic+$12e,$4da.w
	move.b	d0,WasteMusic+$12a
	bra	GetKey
Key_aa	bra	GetKey

OldVec	move.w	sr,-(sp)		No Interrupts
	move.w	#$2700,sr
	move.l	OldTB,$120.w		Old Vectors
	move.l	Old4,$70.w
	move.l	OldKey,$118.w
	clr.l	$4da.w
	move.b	Old07(pc),$fffffa07.w
	move.b	Old09(pc),$fffffa09.w
	move.b	Old13(pc),$fffffa13.w
	move.b	Old15(pc),$fffffa15.w
	move.b	Old1b(pc),$fffffa1b.w
	move.b	Old17(pc),$fffffa17.w
	move.w	(sp)+,sr

	lea	$ffff8800.w,a0
	move.l	#$08080000,(a0)		Shut The Music
	move.l	#$09090000,(a0)
	move.l	#$0a0a0000,(a0)

	move.w	OldRes,-(sp)		Old Resolution And Screen Addresses
	move.l	OldScreen,-(sp)
	move.l	OldScreen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	pea	MOn(pc)			Mouse On
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.w	#8,sp
	dc.w	$a009

	movem.l	OldColors,d0-d7		Old Palette
	movem.l	d0-d7,$ffff8240.w

	move.l	OldStack,-(sp)		Back To User Mode
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp

	clr.w	-(sp)			Adios!
	trap	#1

SpriteVBL
ClearSprite
	moveq	#(SpriteCount-1)*4,d0
ClrNxt	move.l	LogBuffer(pc),a0
	move.l	(a0,d0.w),a0
	move.l	(a0)+,a1		Get Screen Address
	IFNE	BackgroundFlag
	REPT	SpriteHeight-1
	move.w	(a0)+,-8(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,8(a1)
	ENDR
	ENDC
	IFEQ	BackgroundFlag
	REPT	SpriteHeight-1
	clr.w	-8(a1)
	clr.w	(a1)
	clr.w	8(a1)
	lea	160(a1),a1		Next Line
	ENDR
	ENDC
	IFNE	BackgroundFlag
	move.w	(a0)+,-8(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,8(a1)
	ENDC
	IFEQ	BackgroundFlag
	clr.w	-8(a1)
	clr.w	(a1)
	clr.w	8(a1)
	ENDC
	subq.w	#4,d0
	bpl	ClrNxt			Clear Next Sprite
	rts

DrawSprite
	move.l	LogScreen(pc),d4	Install New Screen Address
	lsr.l	#8,d4
	lea	$ffff8201.w,a0
	movep.w	d4,(a0)

	moveq	#0,d4
DrwNxt	move.w	d4,d3
	lsl.w	#2,d3
	lea	SpritePosList,a3	Get Coordinate Pointer
	move.l	a3,a4
	add.w	d3,a4
	move.l	(a4),a3

	move.l	LogBuffer(pc),a2	Get Pointer For Screen Buffer
	move.l	(a2,d3.w),a2

	moveq	#0,d1
	moveq	#0,d6
GetPos	move.w	(a3)+,d0
	move.w	(a3)+,d1
	bpl.s	PosOk
	lea	SpritePos,a3
	bra.s	GetPos
PosOk	move.l	a3,(a4)			Set New Coordinate Pointer
	subq.w	#5,d1
	asl.l	#5,d1			Y*160
	move.l	d1,d2
	asl.l	#2,d1
	add.l	d1,d2
	move.w	d0,d6			X -> AND The Last 4 Bits
	lsr.l	#4,d6			X -> Divide By Two -> Right Start Word
	lsl.l	#3,d6
	move.l	LogScreen(pc),a1
	add.l	d2,a1			Screen+Ypos
	add.w	d6,a1			Screen+Xpos
	add.w	#6+8,a1
	move.l	a1,(a2)+		Mark Address In Clear Buffer
	lea	SprShift,a0
	move.l	(a0,d3.w),a0		Find The Right PreShifted Buffer
	add.w	d6,d6
	sub.w	d6,d0
	moveq	#15,d6
	sub.w	d0,d6
	mulu	#6*SpriteHeight,d6
	add.l	d6,a0
	moveq	#SpriteHeight/2-1,d0
Loop1	
	IFNE	BackgroundFlag
	move.w	-8(a1),(a2)+		Save Background
	move.w	(a1),(a2)+
	move.w	8(a1),(a2)+
	ENDC

	movem.w	(a0)+,d1-d3/d5-d7
	or.w	d1,-8(a1)
	or.w	d2,(a1)
	or.w	d3,8(a1)
	or.w	d5,152(a1)
	or.w	d6,160(a1)
	or.w	d7,168(a1)
	lea	320(a1),a1		Next Line
	dbf	d0,Loop1
	movem.w	(a0),d1-d3
	or.w	d1,-8(a1)
	or.w	d2,(a1)
	or.w	d3,8(a1)
	addq.w	#1,d4
	cmp.w	#SpriteCount,d4
	bne	DrwNxt			Next Sprite

	move.l	LogScreen(pc),d0	Swap The Two Screens
	cmp.l	Screen2(pc),d0		And The Two Buffers
	bne.s	x1
	move.l	Screen1(pc),LogScreen
	move.l	#SpriteBufferListLog,LogBuffer
	rts
x1	move.l	Screen2(pc),LogScreen
	move.l	#SpriteBufferListPhys,LogBuffer	
EOSpr	rts

*************************

Stars	lea	StarTable,a0
	move.w	(a0)+,d7
	move.l	LogScreen(pc),a2
	lea	80*160(a2),a2
	move.l	a2,a1
DrawStar
	move.w	(a0)+,d0
	sub.w	(a0)+,d0
	bpl.s	StarOk1
	move.w	#319,d0
StarOk1	move.w	d0,-4(a0)
	move.w	d0,d1
	lsr.w	#4,d0
	lsl.w	#3,d0
	clr.w	(a1)
	add.w	d0,a1
	clr.w	(a1)
	clr.w	8(a1)
	and.w	#15,d1
	moveq	#16,d4
	sub.w	d1,d4
	moveq	#0,d5
	bset	d4,d5
	or.w	d5,(a1)
	lea	320(a2),a2
	move.l	a2,a1
	dbf	d7,DrawStar
	rts

*************************

New4	movem.l	AllReg,-(sp)
	clr.b	$fffffa1b.w
	move.b	#2-1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#TheCSHColours,$120.w	Install New Timer B

	movem.l	NewPalette,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	#$700,$ffff8250.w	Sprites Colour

	lea	CSHColours,a0
	move.w	(a0),$ffff8244.w
	move.w	(a0)+,$ffff8254.w
	move.l	a0,CSHColourPointer
	move.w	#WaveCount+1,ColourWaveCounter
	subq.w	#1,ColourWaveTime
	bne	Go4
	st	ColourWaveFlag
	addq.w	#1,ColourWaveTime

	lea	ColourWave(pc),a0
	subq.w	#1,ColourOffsetTime
	bpl.s	Cont
	move.w	#1,ColourOffsetTime

	addq.w	#2,ColourWaveOffset
	cmp.w	#(WaveCount*2)*2,ColourWaveOffset
	blt.s	Cont
	move.w	#0,ColourWaveOffset
	sf	ColourWaveFlag
	move.w	#2*50,ColourWaveTime
	move.l	ColourWaveTablePointer(pc),a0	New Colour Wave
	lea	WaveCount*2(a0),a0
	cmp.w	#-1,(a0)
	bne.s	NoEnd
	lea	ColourWaveTable(pc),a0
NoEnd	move.l	a0,ColourWaveTablePointer
	movem.l	(a0)+,d0-d5
	movem.l	d0-d5,ColourWaveReal

Cont	add.w	ColourWaveOffset(pc),a0
	move.w	(a0)+,ColourWaveColour
	move.l	a0,ColourWavePointer
Go4	addq.w	#1,VblCount
	movem.l	(sp)+,AllReg
	rte

NewKey	clr.b	$fffffa11.w
	rte

TheCSHColours
	tst.b	ColourWaveFlag
	beq.s	OnlyCSH

	move.w	ColourWaveColour(pc),$ffff8240.w
*
	move.l	CSHColourPointer(pc),a6
	move.w	(a6),$ffff8244
	move.w	(a6)+,$ffff8254.w
	tst.w	(a6)
	bmi.s	EndCSH
	move.l	a6,CSHColourPointer
*
	move.l	ColourWavePointer(pc),a6
	move.w	(a6)+,ColourWaveColour
	move.l	a6,ColourWavePointer

	subq.w	#1,ColourWaveCounter
	bne.s	EndBoth
	move.w	#WaveCount+1,ColourWaveCounter
	lea	ColourWave(pc),a6
	add.w	ColourWaveOffset(pc),a6
	move.w	(a6)+,ColourWaveColour
	move.l	a6,ColourWavePointer
EndBoth	rte

OnlyCSH	move.l	CSHColourPointer(pc),a6
	move.w	(a6),$ffff8244.w
	move.w	(a6)+,$ffff8254.w
	tst.w	(a6)
	bmi.s	EndCSH
	move.l	a6,CSHColourPointer
	rte

EndCSH	movem.l	AllReg,-(sp)
	lea	$fffffa21.w,a0
	clr.b	$fffffa1b.w
	move.b	#140,(a0)
	move.b	#8,$fffffa1b.w
	move.l	#NewTB1,$120.w
	move.w	$ffff8250.w,d0
	move.w	d0,$ffff8254.w		Plane 2,3 + Sprites(4) -> SpriteColour
	move.w	d0,$ffff8258.w
	move.w	d0,$ffff825c.w
	moveq	#$016,d0
	move.w	d0,$ffff8244.w		8244=Colour Of Bend Scroller
	move.w	#$015,$ffff8248.w	8248=Colour Of Right On Scroller
	move.w	d0,$ffff824c.w		824c=Colour Of Mixed Scroller
	move.b	(a0),d0
.Wait	cmp.b	(a0),d0
	beq.s	.Wait
	dcb.w	4,$4e71
	clr.w	$ffff8240.w
	bsr	ClearSprite		Clear Sprites
	move.w	#$666,$ffff8242.w	8242=Colour Of Stars
	bsr	ByteBenderVBL		Scroller
	move.w	#$555,$ffff8242.w
	bsr	Stars			The Stars
	move.w	#$444,$ffff8242.w
	bsr	DrawSprite		Draw Sprites
*	move.w	#$007,$ffff8240.w
	move.l	$4da.w,a0		And The Music
	jsr	(a0)
*	clr.w	$ffff8240.w
	movem.l	(sp)+,AllReg
	rte

NewTB1	movem.l AllReg,-(sp)		Colour Scroller
	clr.b	$fffffa1b.w
	lea	$fffffa21.w,a2
	move.b	#200,(a2)
	move.b	#8,$fffffa1b.w
	move.w	#$2700,sr
	lea	$ffff8240.w,a0
	lea	$ffff8209.w,a1
	lea	$ffff820a.w,a3
	moveq	#30,d1
	moveq	#0,d2
	move.b	(a2),d0
.Wait1	cmp.b	(a2),d0
	beq.s	.Wait1

	clr.b	(a3)			Open Lower Border
	moveq	#3,d0
.Wait4	nop
	dbf	d0,.Wait4
	move.b	#2,(a3)

.Wait2	move.b	(a1),d0			Sync Lock
	beq.s	.Wait2
	sub.w	d0,d1
	lsl.w	d1,d2

	moveq	#18-1,d0
.Wait3	nop
	dbf	d0,.Wait3

	move.w	(a0),d0
	moveq	#8-1,d1
	moveq	#8-1,d2
	moveq	#8-1,d3
	moveq	#8-1,d4
	moveq	#8-1,d5
	lea	ColorScrollColors,a1
	move.w	(a1)+,d7
	move.w	Scr48,d6
	lsl.l	d6,d6

First	dcb.w	4,$4e71
MoveT1	REPT	55
	move.w	d0,(a0)
	ENDR
	dcb.w	9,$4e71
	move.w	(a1)+,d7
	dbf	d1,First
	bra.s	MoveT2

Second	dcb.w	4,$4e71
MoveT2	REPT	55
	move.w	d0,(a0)
	ENDR
	dcb.w	9,$4e71
	move.w	(a1)+,d7
	dbf	d2,Second
	bra.s	MoveT3

Third	dcb.w	4,$4e71
MoveT3	REPT	55
	move.w	d0,(a0)
	ENDR
	dcb.w	9,$4e71
	move.w	(a1)+,d7
	dbf	d3,Third
	bra.s	MoveT4

Fourth	dcb.w	4,$4e71
MoveT4	REPT	55
	move.w	d0,(a0)
	ENDR
	dcb.w	9,$4e71
	move.w	(a1)+,d7
	dbf	d4,Fourth
	bra.s	MoveT5

Fifth	dcb.w	4,$4e71
MoveT5	REPT	55
	move.w	d0,(a0)
	ENDR
	dcb.w	9,$4e71
	move.w	(a1)+,d7
	dbf	d5,Fifth
	move.w	d0,(a0)
	move.w	#$2500,sr		Interrupts Are Allowed

	tst.w	WaitSet
	beq.s	TstSpd

	subq.w	#1,WaitSet
	bne	Done

TstSpd	tst.b	Speed
	bne.s	Double

	subq.w	#2,Scr48
	bpl	Done
	move.w	#2,Scr48

Double	lea	MoveT1(pc),a6
	movem.l	2(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,(a6)
	movem.l	58(a6),d0-d7/a0-a4
	movem.l	d0-d7/a0-a4,56(a6)
	lea	MoveT2(pc),a6
	movem.l	2(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,(a6)
	movem.l	58(a6),d0-d7/a0-a4
	movem.l	d0-d7/a0-a4,56(a6)
	lea	MoveT3(pc),a6
	movem.l	2(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,(a6)
	movem.l	58(a6),d0-d7/a0-a4
	movem.l	d0-d7/a0-a4,56(a6)
	lea	MoveT4(pc),a6
	movem.l	2(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,(a6)
	movem.l	58(a6),d0-d7/a0-a4
	movem.l	d0-d7/a0-a4,56(a6)
	lea	MoveT5(pc),a6
	movem.l	2(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,(a6)
	movem.l	58(a6),d0-d7/a0-a4
	movem.l	d0-d7/a0-a4,56(a6)

	move.b	BitNr,d1		Have I Done All Bits?
	bne.s	BitLp			No

	moveq	#0,d0			Yes, Get New Character
	moveq	#0,d7
	lea	CharSet,a0
	move.l	TextPointer(pc),a2	Get Character
GetChar	move.b	(a2)+,d0		=>128 -> Control Byte
	blt.s	ResetP
	sub.b	#32,d0			Character-32
	move.w	d0,d7
	lsl.w	#2,d7
	add.w	d0,d0			Mul 6
	add.w	d7,d0
	add.w	d0,a0
	move.b	(a0)+,d1		Get Number Of Bits That
	move.b	d1,BitNr		Character Consists Of
	move.l	a0,TextChar
	move.l	a2,TextPointer
	bra.s	BitLp
ResetP	cmp.b	#128,d0			128=Wait For A Moment
	beq.s	MakeWait
	lea	Text(pc),a2		Else Reset TextPointer
	bra.s	GetChar
MakeWait
	move.b	(a2)+,d7		Get Next Byte And Multiply It
	move.l	a2,TextPointer		With 8
	lsl.w	#3,d7			Wait Byte*1/50*8 Seconds
	move.w	d7,WaitSet
	bra.s	Done

BitLp	move.l	TextChar,a0
	lea	MoveT1+108(pc),a1	First Move.w dx,(a0)
	subq.b	#1,d1
	moveq	#5-1,d2
	move.w	#$3080,d0		d0=move.w d0,(a0)
	move.w	#$3087,d7		d7=move.w d7,(a0)
TstBit	btst	d1,(a0)+		Bit Set In Character Set
	beq.s	BitClr
	move.w	d7,(a1)			Yes, -> move.w d7,(a0)
	bra.s	NextBit
BitClr	move.w	d0,(a1)			No,  -> move.w d0,(a0)
NextBit	lea	144(a1),a1		Next Horizontal Line
	dbf	d2,TstBit
	subq.b	#1,BitNr		One Bit Is Scrolled
Done	movem.l (sp)+,AllReg
	rte

* THE BYTE-BENDER SCROLLER !!!

ByteBenderVBL
	move.w	Nr,d2
	addq.w	#1,Nr
	and.w	#TheAND,Nr		8 Times For 16 Pixels
	asl.w	#2,d2
	lea	IrqTab(pc),a2		Every Buffer Has An Own
	move.l	(a2,d2.w),a2		Routine
	jmp	(a2)

No109	lea	Block1,a6		Show Block 1
	bsr	ShowBend
	lea	Block2,a6		Prepare Next Block
	lea	Buffer2,a5
	bra	ShiftLeft
No210	lea	Block2,a6		Show Block 2
	bsr	ShowBend
	lea	Block3,a6		Prepare Next Block
	lea	Buffer3,a5
	bra	ShiftLeft
No311	lea	Block3,a6		Show Block 3
	bsr	ShowBend
	lea	Block4,a6		Prepare Next Block
	lea	Buffer4,a5
	bra	ShiftLeft

No8	move.w	#8/4,Teil		Second Halve Of The 32
	lea	Block4,a6		Width Character
	bsr	ShowBend
	bsr	AddBuffer 		Make The New Buffers
	lea	Block1,a6
	lea	Buffer1,a5
	bra	ShiftLeft

No0	clr.w	Teil			Left Halve Of The 32 Width Char
	lea	Block4,a6
	bsr	ShowBend
	move.l	TextBendPointer(pc),a0	Pointer To Start Of Text
	lea	CharTable,a1		Pointer To Character Table

Again1 	move.b	(a0)+,d1
	cmp.b	#EOText,d1
	bne.s	Nxt1
	lea	TextBend(pc),a0
	bra.s	Again1
Nxt1	cmp.b	#'b',d1
	bne.s	Nxt2
	move.b	(a0)+,d1
	sub.b	#'0',d1
	move.b	d1,BendOffset
	bra.s	Again1
Nxt2	cmp.b	#'r',d1
	bne.s	Nxt3
	move.b	(a0)+,d1
	sub.b	#'0',d1
	move.b	d1,BendRoutOffset
	bra.s	Again1
Nxt3	move.l	a0,TextBendPointer
	sub.b	#32,d1
	ext.w	d1
	asl.w	#2,d1
	move.l	(a1,d1.w),CharDatP1	Pointer To New Character

Again2	move.b	(a0)+,d1
	cmp.b	#'r',d1
	bne.s	.Nxt1
	move.b	(a0)+,d1
	sub.b	#'0',d1
	move.b	d1,BendRoutOffset
	bra.s	Again2
.Nxt1	cmp.b	#'b',d1
	bne.s	.Nxt2
	move.b	(a0)+,d1
	sub.b	#'0',d1
	move.b	d1,BendOffset
	bra.s	Again2
.Nxt2	cmp.b	#EOText,d1
	bne.s	.Nxt3
	lea	TextBend(pc),a0
	bra.s	Again2
.Nxt3	sub.b	#32,d1
	ext.w	d1
	asl.w	#2,d1
	move.l	(a1,d1.w),CharDatP2	Pointer To Second Character

* Tweede Character Wordt Gekoppeld Aan Het Eerste Character

	bsr	AddBuffer 		Create New Buffer

	lea	Block1,a6		Scroll Block1
	lea	Buffer1,a5		

ShiftLeft
	moveq	#ScrLines-1,d0
.Left	movem.l	2(a6),d1-d7/a0-a2	Copy 40 Bytes
	movem.l	d1-d7/a0-a2,(a6)
	lea	38(a6),a6
	move.w	(a5)+,(a6)+		Add 1 New Word (The Buffer)
	dbf	d0,.Left
	rts				End Of Byte-Bender

ShowBend
	moveq	#0,d0
	lea	BendRoutTable(pc),a0
	move.b	BendRoutOffset(pc),d0
	asl.w	#2,d0
	move.l	(a0,d0.w),a0
*
	moveq	#0,d1
	move.b	BendOffset(pc),d1
	asl.w	#2,d1
	lea	BendPointers(pc),a2
	move.l	(a2,d1.w),a2
	move.l	LogScreen(pc),a4
	lea	100*160(a4),a4
	addq.w	#2,a4
	move.l	a4,a5

	jmp	(a0)
	
BendRoutNormal
	moveq	#20-1,d0
.Loop	moveq	#0,d2
	move.b	(a2)+,d2
	mulu	#160,d2
	add.w	d2,a5
	move.b	40(a6),1*160(a5)
	move.b	80(a6),2*160(a5)
	move.b	120(a6),3*160(a5)
	move.b	160(a6),4*160(a5)
	move.b	200(a6),5*160(a5)
	move.b	240(a6),6*160(a5)
	move.b	280(a6),7*160(a5)
	move.b	320(a6),8*160(a5)
	move.b	360(a6),9*160(a5)
	move.b	400(a6),10*160(a5)
	move.b	440(a6),11*160(a5)
	move.b	480(a6),12*160(a5)
	move.b	520(a6),13*160(a5)
	move.b	560(a6),14*160(a5)
	move.b	600(a6),15*160(a5)
	move.l	a4,a5
	move.b	(a6)+,(a5)+

	moveq	#0,d2
	move.b	(a2)+,d2
	mulu	#160,d2
	add.w	d2,a5
	move.b	40(a6),1*160(a5)
	move.b	80(a6),2*160(a5)
	move.b	120(a6),3*160(a5)
	move.b	160(a6),4*160(a5)
	move.b	200(a6),5*160(a5)
	move.b	240(a6),6*160(a5)
	move.b	280(a6),7*160(a5)
	move.b	320(a6),8*160(a5)
	move.b	360(a6),9*160(a5)
	move.b	400(a6),10*160(a5)
	move.b	440(a6),11*160(a5)
	move.b	480(a6),12*160(a5)
	move.b	520(a6),13*160(a5)
	move.b	560(a6),14*160(a5)
	move.b	600(a6),15*160(a5)
	move.b	(a6)+,(a5)
	addq.w	#8,a4
	move.l	a4,a5
	dbf	d0,.Loop
	rts

BendRoutTwo
	moveq	#20-1,d0
.Loop	moveq	#0,d2
	move.b	(a2)+,d2
	mulu	#160,d2
	add.w	d2,a5
	move.w	40(a6),1*160(a5)
	move.w	80(a6),2*160(a5)
	move.w	120(a6),3*160(a5)
	move.w	160(a6),4*160(a5)
	move.w	200(a6),5*160(a5)
	move.w	240(a6),6*160(a5)
	move.w	280(a6),7*160(a5)
	move.w	320(a6),8*160(a5)
	move.w	360(a6),9*160(a5)
	move.w	400(a6),10*160(a5)
	move.w	440(a6),11*160(a5)
	move.w	480(a6),12*160(a5)
	move.w	520(a6),13*160(a5)
	move.w	560(a6),14*160(a5)
	move.w	600(a6),15*160(a5)
	move.l	a4,a5
	move.w	(a6),(a5)+

	move.w	40(a6),1*160(a5)
	move.w	80(a6),2*160(a5)
	move.w	120(a6),3*160(a5)
	move.w	160(a6),4*160(a5)
	move.w	200(a6),5*160(a5)
	move.w	240(a6),6*160(a5)
	move.w	280(a6),7*160(a5)
	move.w	320(a6),8*160(a5)
	move.w	360(a6),9*160(a5)
	move.w	400(a6),10*160(a5)
	move.w	440(a6),11*160(a5)
	move.w	480(a6),12*160(a5)
	move.w	520(a6),13*160(a5)
	move.w	560(a6),14*160(a5)
	move.w	600(a6),15*160(a5)
	move.w	(a6)+,(a5)
	addq.w	#8,a4
	move.l	a4,a5
	dbf	d0,.Loop
	rts

BendRoutLines1
	moveq	#20-1,d0
.Loop	moveq	#0,d2
	move.b	(a2)+,d2
	mulu	#160,d2
	add.w	d2,a5
	move.b	40(a6),2*160(a5)
	move.b	80(a6),4*160(a5)
	move.b	120(a6),6*160(a5)
	move.b	160(a6),8*160(a5)
	move.b	200(a6),10*160(a5)
	move.b	240(a6),12*160(a5)
	move.b	280(a6),14*160(a5)
	move.b	320(a6),16*160(a5)
	move.b	360(a6),18*160(a5)
	move.b	400(a6),20*160(a5)
	move.b	440(a6),22*160(a5)
	move.b	480(a6),24*160(a5)
	move.b	520(a6),26*160(a5)
	move.b	560(a6),28*160(a5)
	move.b	600(a6),30*160(a5)
	move.l	a4,a5
	move.b	(a6)+,(a5)+

	moveq	#0,d2
	move.b	(a2)+,d2
	mulu	#160,d2
	add.w	d2,a5

	move.b	40(a6),2*160(a5)
	move.b	80(a6),4*160(a5)
	move.b	120(a6),6*160(a5)
	move.b	160(a6),8*160(a5)
	move.b	200(a6),10*160(a5)
	move.b	240(a6),12*160(a5)
	move.b	280(a6),14*160(a5)
	move.b	320(a6),16*160(a5)
	move.b	360(a6),18*160(a5)
	move.b	400(a6),20*160(a5)
	move.b	440(a6),22*160(a5)
	move.b	480(a6),24*160(a5)
	move.b	520(a6),26*160(a5)
	move.b	560(a6),28*160(a5)
	move.b	600(a6),30*160(a5)
	move.b	(a6)+,(a5)
	addq.w	#8,a4
	move.l	a4,a5
	dbf	d0,.Loop
	rts

BendRoutLines2
	moveq	#20-1,d0
.Loop	moveq	#0,d2
	move.b	(a2)+,d2
	mulu	#160,d2
	add.w	d2,a5
	move.w	40(a6),2*160(a5)
	move.w	80(a6),4*160(a5)
	move.w	120(a6),6*160(a5)
	move.w	160(a6),8*160(a5)
	move.w	200(a6),10*160(a5)
	move.w	240(a6),12*160(a5)
	move.w	280(a6),14*160(a5)
	move.w	320(a6),16*160(a5)
	move.w	360(a6),18*160(a5)
	move.w	400(a6),20*160(a5)
	move.w	440(a6),22*160(a5)
	move.w	480(a6),24*160(a5)
	move.w	520(a6),26*160(a5)
	move.w	560(a6),28*160(a5)
	move.w	600(a6),30*160(a5)
	move.l	a4,a5
	move.w	(a6),(a5)+

	move.w	40(a6),2*160(a5)
	move.w	80(a6),4*160(a5)
	move.w	120(a6),6*160(a5)
	move.w	160(a6),8*160(a5)
	move.w	200(a6),10*160(a5)
	move.w	240(a6),12*160(a5)
	move.w	280(a6),14*160(a5)
	move.w	320(a6),16*160(a5)
	move.w	360(a6),18*160(a5)
	move.w	400(a6),20*160(a5)
	move.w	440(a6),22*160(a5)
	move.w	480(a6),24*160(a5)
	move.w	520(a6),26*160(a5)
	move.w	560(a6),28*160(a5)
	move.w	600(a6),30*160(a5)
	move.w	(a6)+,(a5)
	addq.w	#8,a4
	move.l	a4,a5
	dbf	d0,.Loop
	rts

AddBuffer
	move.w	Teil,d6
	moveq	#2,d5
	move.l	CharDatP1,d4
	cmp.w	#2,d6
	bne.s	Buffer0a
	move.l	CharDatP2,d5
	sub.l	d4,d5
Buffer0a
	moveq	#ScrLines-1,d0
	lea	Buffer1,a0
	move.l	d4,a1
	add.w	d6,a1			First Or Last 16 Pix
Buffer0b
	move.w	(a1),(a0)+		Copy It To The First Buffer
	lea	40(a1),a1
	dbf	d0,Buffer0b

	moveq	#3-1,d2			ROL The Last Three buffers
	moveq	#4,d3			ROL 12, ROL 8, ROL 4

	move.l	d4,a1
	move.l	d4,a2	
	add.w	d5,a1
	add.w	d6,a2
Buffer1a
	moveq	#ScrLines-1,d0
Buffer1b
	move.l	(a1),d1			a1=Old Character
	move.w	(a2),d1			a2=New Character
	rol.l	d3,d1
	move.w	d1,(a0)+
	lea	40(a1),a1
	lea	40(a2),a2
	dbf	d0,Buffer1b
	addq.w	#4,d3
	lea	-(ScrLines*40)(a1),a1
	lea	-(ScrLines*40)(a2),a2
	dbf	d2,Buffer1a
	rts

********************************************************************

	Section	Data

LogScreen		ds.l	1
Screen1			ds.l	1
Screen2			ds.l	1
LogBuffer		ds.l	1
VblCount		ds.w	1
Old07			ds.b	1
Old09			ds.b	1
Old13			ds.b	1
Old15			ds.b	1
Old1b			ds.b	1
Old17			ds.b	1
NowPlay			ds.b	1
			even

TextBendPointer	dc.l	TextBend
TextBend
	dc.b	" AND HERE'S ANOTHER DEMO FROM:           b1r2THE COPY SYNDICATE HOLLAND           b2ALL THE PROGRAMMING AND GRAFFIX WERE DONE BY           b;r3-AWA-           "
	dc.b	"b5r3 CONTACT ME BY E-MAIL: 2:281/801.4 !! OR FOR MY HOME ADDRESS SEE BELOW!           "
	dc.b	"b9r1   TRY THE KEYS 'F' FOR FAST SCROLL, 'S' FOR SLOW SCROLL, 'F1' - 'F9' AND '1' - '0' FOR THE MUSIX.  THE MUSIX ARE FROM XENON, RETURN TO GENESIS, "
	dc.b	"FOUNDATION'S WASTE, GOLDRUNNER II AND PLATOON. OKAY NOW IT'S TIME FOR THE GREETINGS. THEY GO TO:           b5r3AENIGMATICA     NEW LIMIT     THE UMEGIAN PRIEST     HENDRY     THE ALLIANCE    AND TO ALL MY CONTACTS           "
	dc.b	"b8r1 "
	dc.b	"   OKAY I'LL SEE YOU           b:r3BYE,  BYE      "
	dc.b	"       ",EOText

* About 16 Character Per Line (0-127 Are Chars)(128=Wait 8*(a2) VBLS)
TextPointer	dc.l	Text
Text
	dc.b	"WELCOME TO ANOTHER DEMO FROM THE COPY "
	dc.b	"SYNDICATE HOLLAND !!!     "
	dc.b	"IF YOU WANT TO CONTACT ME YOU CAN DO THAT BY "
	DC.B	"E-MAIL. WRITE TO: ARJEN WAGENAAR  2:281.801.4     "
	DC.B	"OR WRITE TO: ARJEN WAGENAAR     DORPSWEG 32A    "
	DC.B	"1711RJ   HENSBROEK    THE NETHERLANDS      "
	dc.b	"AND NOW WHAT YOU HAVE BEEN "
	dc.b	"WAITING FOR,  THE GREETINGS !   "
	dc.b	"THEY GO TO (IN NO SPECIAL ORDER): "
	dc.b	"    THE PRIEST ",128,20,"  NEW  LIMIT ",128,20,"  "
	dc.b	"RON, HENDRY, THE ALLIANCE, "
	dc.b	" M.C.A.,  AND EVERYBODY I HAVE FORGOTTEN    "
	dc.b	"SEE YOU AND HAVE FUN       AWA     ",128,30,"  "
	dc.b	" ",-1

MOn		dc.b	$08
MOff		dc.b	$12
		even

SprShift	dc.l	Sprite1,Sprite2,Sprite3,Sprite4,Sprite5,Sprite6
		dc.l	Sprite7,Sprite8,Sprite9,Sprite10,Sprite11
TheAND		equ	8-1
IrqTab		dc.l	No0,No109,No210,No311
		dc.l	No8,No109,No210,No311
BendOffset	dc.b	0
BendPointers	dc.l	NormalBend,WaveBend1,WaveBend2,WaveBend3
		dc.l	WaveBend4,WaveBend5,WaveBend6,WaveBend7
		dc.l	WaveBend8,WaveBend9,WaveBend10,WaveBend11
NormalBend	dcb.b	40,0
WaveBend1	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,14,14,15,15,15
		dc.b	15,15,15,14,14,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
WaveBend2	dc.b	20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
		dcb.b	20,0
WaveBend3	dc.b	0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38
		dcb.b	20,40
WaveBend4	dc.b	0,2,4,6,8,10,10,8,6,4,2,0,0,2,4,6,8,10,10,8
		dc.b	6,4,2,0,0,2,4,6,8,10,10,8,6,4,2,0,0,2,4,6
WaveBend5	dc.b	0,1,2,3,4,5,5,4,3,2,1,0,0,1,2,3,4,5,5,4
		dc.b	3,2,1,0,0,1,2,3,4,5,5,4,3,2,1,0,0,1,2,3
WaveBend6	dc.b	0,2,0,2,0,2,0,2,0,2,0,2,0,2,0,2,0,2,0,2
		dc.b	0,2,0,2,0,2,0,2,0,2,0,2,0,2,0,2,0,2,0,2
WaveBend7	dc.b	0,1,2,1,0,1,2,1,0,1,2,1,0,1,2,1,0,1,2,1
		dc.b	0,1,2,1,0,1,2,1,0,1,2,1,0,1,2,1,0,1,2,1
WaveBend8	dc.b	0,1,2,4,7,11,16,16,11,7,4,2,1,0,0,1,2,4,7,11
		dc.b	16,16,11,7,4,2,1,0,0,1,2,4,7,11,16,16,7,4,2,1
WaveBend9	dc.b	50,47,44,41,38,35,32,29,26,23,20,17,14,11,8,5,2,2,1,1
		dcb.b	20,0
WaveBend10	dc.b	0,0,1,2,4,7,10,14,18,22,27,31,34,36,37,37,37,37,37,37
		dc.b	37,37,37,37,37,37,36,34,31,27,22,18,14,10,7,4,2,1,0,0
WaveBend11	dc.b	40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40
		dcb.b	20,0

BendRoutOffset	dc.b	3
BendRoutTable	dc.l	BendRoutNormal,BendRoutTwo,BendRoutLines1
		dc.l	BendRoutLines2

SpriteGraph	include	"SPRGRAPH.S"

CSHColourPointer	dc.l	CSHColours
CSHColours	
	dc.w	$007,$017,$027,$037,$047,$057,$067,$077,$177,$277
	dc.w	$377,$477,$577,$677,$767,$757,$747,$737,$727 '777
	dc.w	$717,$716,$725,$734,$743,$752,$761,$770,$772 '707
	dc.w	$772,$770,$761,$752,$743,$734,$725,$716,$707,$717
	dc.w	$727,$737,$747,$757,$767,$777,$677,$677,$577,$477
	dc.w	$377,$277,$177,$077,$077,$067,$057,$047,$037,$027
	dc.w	$017,$007
	dc.w	-1			

ScrTimer	dc.w	4-1
ColorScrollColors
	dc.w	$777,$767,$757,$747,$737,$727,$717,$707
	dc.w	$607,$507,$407,$307,$207,$107,$007,$017
	dc.w	$027,$037,$047,$057,$067,$077,$076,$075
	dc.w	$074,$073,$072,$071,$070,$170,$270,$370
	dc.w	$470,$570,$670,$770,$771,$772,$773,$774

ColourWavePointer	dc.l	ColourWave
ColourWaveTime		dc.w	2*50
ColourWaveOffset	dc.w	0
ColourWaveCounter	dc.w	0
ColourWaveFlag		dc.b	0
ColourOffsetTime	dc.w	0
ColourWaveColour	dc.w	0
ColourWave		dcb.w	12,0
ColourWaveReal		dc.w	2,3,4,5,6,7,7,6,5,4,3,2
			dcb.w	12,0

WaveCount		equ	12
ColourWaveTablePointer	dc.l	ColourWaveTable
ColourWaveTable	
	dc.w	$020,$030,$040,$050,$060,$070,$070,$060,$050,$040,$030,$020
	dc.w	$200,$300,$400,$500,$600,$700,$700,$600,$500,$400,$300,$200
	dc.w	$222,$333,$444,$555,$666,$777,$777,$666,$555,$444,$333,$222
	dc.w	$220,$330,$440,$550,$660,$770,$770,$660,$550,$440,$330,$220
	dc.w	$002,$003,$004,$005,$006,$007,$007,$006,$005,$004,$003,$002
	dc.w	$022,$033,$044,$055,$066,$077,$077,$066,$055,$044,$033,$022
	dc.w	$202,$303,$404,$505,$606,$707,$707,$606,$505,$404,$303,$202
	dc.w	-1

SpritePosPointer	dc.l	SpritePos
SpritePos	incbin	"SPRITEPO.A"
		incbin	"SPRITEPO.C"
		incbin	"SPRITEPO.B"
		incbin	"SPRITEPO.D"
		incbin	"SPRITEPO.E"
		dc.w	-1,-1

CharSet		dc.b	4,%00,%00,%00,%00,%00			;SPC
		dc.b	2,%1,%1,%1,%0,%1			;!
		dc.b	4,%101,%101,%000,%000,%000		;"
		dc.b	1,0,0,0,0,0				;œ
		dc.b	1,0,0,0,0,0				;$
		dc.b	1,0,0,0,0,0				'%
		dc.b	1,0,0,0,0,0				'&
		dc.b	3,%01,%10,%00,%00,%00			''
		dc.b	5,%0011,%0100,%0100,%0100,%0011		'(
		dc.b	5,%1100,%0010,%0010,%0010,%1100		')
		dc.b	1,0,0,0,0,0				'*
		dc.b	4,%000,%010,%111,%010,%000		'+
		dc.b	3,%00,%00,%00,%01,%10			',
		dc.b	4,%000,%000,%111,%000,%000		'-
		dc.b	4,%000,%000,%000,%000,%100		'.
		dc.b	1,0,0,0,0,0				'/
		dc.b	5,%0110,%1001,%1001,%1001,%0110		'0
		dc.b	6,%00100,%01100,%00100,%00100,%01110	'1
		dc.b	5,%0111,%1001,%0010,%0100,%1111		'2
		dc.b	5,%0111,%0001,%0010,%0001,%0111		'3
		dc.b	5,%1000,%1010,%1111,%0010,%0010		'4
		dc.b	5,%1111,%1000,%1110,%0010,%1110		'5
		dc.b	5,%1000,%1000,%1111,%1001,%1111		'6
		dc.b	5,%1111,%0001,%0010,%0100,%1000		'7
		dc.b	5,%1111,%1001,%1111,%1001,%1111		'8
		dc.b	5,%1111,%1001,%1111,%0001,%0001		'9
		dc.b	2,%0,%1,%0,%1,%0			':
		dc.b	3,%00,%01,%00,%01,%10			';
		dc.b	1,0,0,0,0,0				'<
		dc.b	4,%000,%111,%000,%111,%000		'=
		dc.b	1,0,0,0,0,0				'>
		dc.b	5,%0110,%1001,%0010,%0000,%0010		'?
		dc.b	1,0,0,0,0,0				'@
		dc.b	5,%0110,%1001,%1111,%1001,%1001		;A
		dc.b	5,%1110,%1001,%1110,%1001,%1110		;B
		dc.b	5,%0111,%1000,%1000,%1000,%0111		;C
		dc.b	5,%1110,%1001,%1001,%1001,%1110		;D
		dc.b	5,%1111,%1000,%1110,%1000,%1111		;E
		dc.b	5,%1111,%1000,%1110,%1000,%1000		;F
		dc.b	5,%0111,%1000,%1011,%1001,%0111		;G
		dc.b	5,%1001,%1001,%1111,%1001,%1001		;H
		dc.b	2,%01,%01,%01,%01,%01			;I
		dc.b	5,%0001,%0001,%0001,%1001,%0110		;J
		dc.b	5,%1001,%1010,%1100,%1010,%1001		;K
		dc.b	5,%1000,%1000,%1000,%1000,%1111		;L
		dc.b	6,%10001,%11011,%10101,%10001,%10001	;M
		dc.b	5,%1001,%1101,%1111,%1011,%1001		;N
		dc.b	5,%0110,%1001,%1001,%1001,%0110		;O
		dc.b	5,%1110,%1001,%1110,%1000,%1000		;P
		dc.b	6,%01110,%10001,%10101,%10011,%01110	;Q
		dc.b	5,%1110,%1001,%1110,%1010,%1001		;R
		dc.b	5,%0111,%1000,%0110,%0001,%1110		;S
		dc.b	6,%11111,%00100,%00100,%00100,%00100	;T
		dc.b	5,%1001,%1001,%1001,%1001,%0110		;U
		dc.b	6,%10001,%10001,%01010,%01010,%00100	;V
		dc.b	6,%10001,%10001,%10101,%11011,%10001	;W
		dc.b	6,%10001,%01010,%00100,%01010,%10001	;X
		dc.b	6,%10001,%01010,%00100,%00100,%00100	;Y
		dc.b	6,%11111,%00011,%01100,%11000,%11111	;Z
		even
CharDat		incbin	"charset.dat"
MainScr		incbin	"ACRONYM1.NEO"
XenonMusic	incbin	"XENON.MUS"
GenesisMusic	incbin	"GENESIS.MUS"
WasteMusic	incbin	"WALLY.MUS"
		even
WasteRelativ	incbin	"WALLY.REL"
		even
InitGold	EQU	*+38
GoldII		EQU	*+266+38
		incbin	"GOLDII.MUS"
		even
InitPlat	equ	*
Platoon		equ	*+354
		incbin	"PLATOON.MUS"
		even

	Section	Bss

OldStack		ds.l	1
OldScreen		ds.l	1
OldTB			ds.l	1
Old4			ds.l	1
OldKey			ds.l	1
Charset			ds.l	1
CharDatP1		ds.l	1
CharDatP2		ds.l	1
ClrScrlP		ds.l	1
Teil			ds.w	1
CharPointer		ds.w	1
Nr			ds.w	1
SpriteBufferListPhys	ds.l	SpriteCount
SpriteBufferListLog	ds.l	SpriteCount
SpritePosList		ds.l	SpriteCount
TextChar		ds.l	1		Idem
Scr48			ds.w	1		Idem
BitNr			ds.w	1		For Colour Scroller
WaitSet			ds.w	1		Idem
OldColors		ds.w	16
OldRes			ds.w	1
NewPalette		ds.w	16
StarTable		ds.w	2+2*StarCount	Count,Xpos,Speed
Sprite1			ds.b	6*SpriteHeight*16
Sprite2			ds.b	6*SpriteHeight*16
Sprite3			ds.b	6*SpriteHeight*16
Sprite4			ds.b	6*SpriteHeight*16
Sprite5			ds.b	6*SpriteHeight*16
Sprite6			ds.b	6*SpriteHeight*16
Sprite7			ds.b	6*SpriteHeight*16
Sprite8			ds.b	6*SpriteHeight*16
Sprite9			ds.b	6*SpriteHeight*16
Sprite10		ds.b	6*SpriteHeight*16
Sprite11		ds.b	6*SpriteHeight*16
Block1			ds.b	ScrLines*40
Block2			ds.b	ScrLines*40
Block3			ds.b	ScrLines*40
Block4			ds.b	ScrLines*40
Buffer1			ds.b	ScrLines*2
Buffer2			ds.b	ScrLines*2
Buffer3			ds.b	ScrLines*2
Buffer4			ds.b	ScrLines*2
CharTable		ds.l	100
			IFEQ	BackgroundFlag
SpriteBufferPhys	ds.b	SpriteCount*4
SpriteBufferLog		ds.b	SpriteCount*4
			ENDC
			IFNE	BackgroundFlag
SpriteBufferPhys	ds.b SpriteCount*((6*1*SpriteHeight)+4)
SpriteBufferLog		ds.b SpriteCount*((6*1*SpriteHeight)+4)
			ENDC
ScreenBuf		ds.b	(32000+(64*160)+256)*2
Speed			ds.b	1
			even