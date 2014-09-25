
;Constant Offsets from start of DRIVER.BIN
_Install equ	$0000		sets up timer A & C vectors & installs
_DeInstall equ	$0004		restores old vectors etc
_Start	equ	$0008		start playing tune (_SongAddr,_VoiceAddr)
_Stop	equ	$000C		stop playing current tune
_Restart equ	$0010		restart playing current tune
_SongAddr equ	$002C	.l	holds address of song
_VoiceAddr equ	$0030	.l	holds address of 20-voice kit
_IRQmask equ	$0038	.w	holds normal IRQ mask to write to MFP
_SoundType equ	$003a	.w	holds low level sound driver type number

;case of _SoundType.w=
	;[0] => internal
	;[1] => Replay 8-bit
	;[2] => Replay 12-bit 
	;[3] => Playbackint
	;[4] => STE sample hardware 


	move.l	4(a7),a3
	move.l	#mystack,a7
	move.l	$c(a3),d0
	add.l	$14(a3),d0
	add.l	$1c(a3),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp	; set up the stack

	move.l	#0,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp	; free mem
	
	move.l	#0,$484.w		;no keyclick

	pea	mess(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

	move.w	#0,$ffff8240.w
	move.w	#$777,$ffff8242.w
	move.w	#$777,$ffff825e.w

getkey	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7

	cmp.w	#'1',d0
	blt.s	getkey
	cmp.w	#'5',d0
	bgt.s	getkey

	sub.w	#$31,d0
	move.w	d0,outype

	bra	strt

zippy	movem.l d0-a6,-(sp)		;save registers
	bsr	(music+8)		;call playback
	movem.l	(sp)+,d0-a6		;restore registers
	move.l	oldint,-(sp)		;old vbl on sp
	rts				;call old vbl

on	move.l	$70.w,oldint		;save old vbl
	moveq	#1,d0			;music #1
	bsr	music			;call init
	move.l	#zippy,$70.w		;install new vbl
	rts

off	move.l	oldint,$70.w		;restore old vbl
	move.l	#$08080000,$ff8800	;clear vol. chan A
	move.l	#$09090000,$ff8800	;clear vol. chan B
	move.l	#$0a0a0000,$ff8800	;clear vol. chan C
	rts

oldstk	dc.l	0
oldint	dc.l	0

music	incbin	'thalion.mus'	;change this filename !!

strt	dc.w	$a00a		; disable mouse

	move.w  #2,-(sp)
        trap    #14
        addq.l  #2,a7
        move.l  d0,xdummy	; find screen address

	move.b	#2,$ff820a	; 50 Hz

	move.w	#0,-(sp)
	move.l	#$76000,-(sp)
	move.l	#$76000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp	; set up $76000 as top of screen

	bsr	on

	move.l	#int1+2,a2
	bsr	putpal
	move.l	#int1+34,a2
	bsr	putpic

	bsr	pause
	bsr	pause

	move.l	#int2+2,a2
	bsr	putpal
	move.l	#int2+34,a2
	bsr	putpic

	bsr	pause
	bsr	pause

	moveq	#6,d0
	bsr	music

	bsr	pause

	moveq	#8,d0
	bsr	music

	move.l	#FromScreen+2,a2
	bsr	putpal
	move.l	#FromScreen+34,a2
	bsr	putpic

	bsr	pause

	bsr	off

	bra	again

putpic	move.w	#7999,d0
	lea	$44e.w,a0
	move.l	(a0),a0
	lea	(a2),a1
nextlc	move.l	(a1)+,(a0)+
	dbf	d0,nextlc
	rts

putpal	move.l	#$ff8240,a1
	lea	(a2),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)	; set up colours for screen
	rts

again:  move.l  #line,mespt	; message pointer to start of text
	jsr	hblon
	jsr	install
	jsr	play

keyprs:	move.w	#7,-(sp)
	trap	#1
	lea	2(sp),sp	; wait for key

	cmp.b	#'1',d0
	beq	Run1
	cmp.b	#'2',d0
	beq	Run2
	cmp.b	#'3',d0
	beq	Run3
	;cmp.b	#'*',d0
	;beq	star
	cmp.b	#'0',d0
	beq	zero		; selection

aszdf	jmp	keyprs

RunProg
	jsr	hbloff
	move.w	#0,-(sp)
	move.l	xdummy,-(sp)
	move.l	xdummy,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	move.b	(hertz),$ff820a
	move.l	d5,-(sp)
	move.w	#$3b,-(sp)
	trap	#1
	addq.l	#6,a7
	move.l	#Empty,-(sp)
	move.l	#Empty,-(sp)
	move.l	d6,-(sp)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(a7),a7

	clr.w	-(sp)
	trap	#1

Run1:
	jsr	deinstall
	move.l	#Emp,d5
	move.l	#Prog1,d6
	bra	RunProg
Run2:
	jsr	deinstall
	move.l	#Emp,d5
	move.l	#Prog2,d6
	bra	RunProg
Run3:
	jsr	deinstall
	move.l	#Emp,d5
	move.l	#Prog3,d6
	bra	RunProg
;star:
;	jsr	deinstall
;	jsr	hbloff
;	;move.l	#$07770000,$ff8240
;	;move.l	#0,$ff8244
;	clr.w	-(sp)
;	trap	#1			; just for the testing exit
zero:
	eori.w	#$400,ch+2
	move.b	(hertz),d0
	tst	d0
	beq	hz50
	move.b	#0,(hertz)
	jmp	aszdf

hz50	move.b	#2,(hertz)
	jmp	aszdf		; toggle 50/60Hz

pause	move.l	#2000,d4
pl0	move.l	#1200,d3
pl1	dbf	d3,pl1
	dbf	d4,pl0
	rts

hblon:	move.l	$120,oldtb
	move.l	$70,old4
	move.l	$70,new4b+2
	move.b	$fffffa07,old07
	move.b	$fffffa09,old09
        move.b 	$fffffa0f,old0f
        move.b 	$fffffa11,old11
        move.b 	$fffffa1b,old1b
	and.b	#$df,$fffa09
	and.b	#$fe,$fffa07
	move.l	#killborder,$120
	move.l	#new4,$70
	or.b	#1,$fffffa07
	or.b	#1,$fffffa13
	rts			; starts the hb interupt

hbloff:	move.w	sr,-(sp)
	move.w	#$2700,sr
	move.b	old07(pc),$fffffa07
	move.b	old09(pc),$fffffa09
        move.b 	old0f(pc),$fffffa0f
        move.b 	old11(pc),$fffffa11
        move.b 	old1b(pc),$fffffa1b
	move.l	oldtb,$120
	move.l	old4,$70
	move.w	(sp)+,sr
	rts			; stops the hb int + clear sound

old4	dc.l	0
oldtb	dc.l	0
old07	dc.b	0
old09	dc.b	0
old0f:  dc.b   	0
old11:  dc.b   	0
old1b:  dc.b   	0

        even

new4:	movem.l	d0-a6,-(sp)
	move.l	#$ff8240,a1
	move.l	#FromScreen+2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	clr.b	$fffffa1b.w
	move.b	#199,$fffffa21
	move.b	#8,$fffffa1b
	move.l	#killborder,$120 ; sets up the bottom border

******* start of scroll routine

morepix:
	move.w	delcon,d0
	subq.w	#1,d0
	beq	mskro
	move.w	d0,delcon
	jmp	endskro
mskro	move.w	_left,d1
	dbf	d1,noneed
        move.l  mespt,a0
        clr.l   d0
	move.b  (a0)+,d0
	cmp.b	#254,d0
	bne	gstring
	move.b	(a0)+,d0
	move.w	d0,delcon
	move.l	a0,mespt
	jmp	morepix
gstring	cmp.b   #255,d0
        bne     cont
	move.b	#'[',d0
	move.l	#line,a0
cont	sub.b   #32,d0
	divu	#10,d0
	move.l	d0,d1
        mulu    #160*32,d0
	swap	d1
	lsl	#4,d1
	add.w	d1,d0
        add.l   #ch+34,d0
	move.l	a0,mespt
        move.l  d0,a0
	move.l	#_blk,a1
	move.w	#31,d2		;lines of font
loup1	move.w	2(a0),128(a1)
	move.w	10(a0),130(a1)
	move.w	4(a0),256(a1)
	move.w	12(a0),258(a1)
	move.w	6(a0),384(a1)
	move.w	14(a0),386(a1)
	move.w	(a0),(a1)+
	move.w	8(a0),(a1)+
	add.l	#160,a0
	dbf	d2,loup1
	move.w	#3,d1
noneed:	move.w	d1,_left
	move.l	#_blk+3,a1
	sub.w	d1,a1
	move.l	#$76000+32160,a2
	move.w	#0,d0
nexbp	move.l	a2,a0
	lea	2(a2),a2
	move.w	#31,d1
nexln	move.b	1(a0),(a0)
	move.b	8(a0),1(a0)
	move.b	9(a0),8(a0)
	move.b	16(a0),9(a0)
	move.b	17(a0),16(a0)
	move.b	24(a0),17(a0)
	move.b	25(a0),24(a0)
	move.b	32(a0),25(a0)
	move.b	33(a0),32(a0)
	move.b	40(a0),33(a0)
	move.b	41(a0),40(a0)
	move.b	48(a0),41(a0)
	move.b	49(a0),48(a0)
	move.b	56(a0),49(a0)
	move.b	57(a0),56(a0)
	move.b	64(a0),57(a0)
	move.b	65(a0),64(a0)
	move.b	72(a0),65(a0)
	move.b	73(a0),72(a0)
	move.b	80(a0),73(a0)
	move.b	81(a0),80(a0)
	move.b	88(a0),81(a0)
	move.b	89(a0),88(a0)
	move.b	96(a0),89(a0)
	move.b	97(a0),96(a0)
	move.b	104(a0),97(a0)
	move.b	105(a0),104(a0)
	move.b	112(a0),105(a0)
	move.b	113(a0),112(a0)
	move.b	120(a0),113(a0)
	move.b	121(a0),120(a0)
	move.b	128(a0),121(a0)
	move.b	129(a0),128(a0)
	move.b	136(a0),129(a0)
	move.b	137(a0),136(a0)
	move.b	144(a0),137(a0)
	move.b	145(a0),144(a0)
	move.b	152(a0),145(a0)
	move.b	153(a0),152(a0)
	move.b	(a1),153(a0)
	lea	160(a0),a0
	lea	4(a1),a1
	dbf	d1,nexln
	dbf	d0,nexbp

putlogo	move.l	#logos+34,a0
	move.l	bfl,a2
	cmpi.l	#$ffffffff,(a2)
	bne	contblo
	move.l	#coblo,bfl
	bra	endskro	
contblo	adda.l	(a2),a0
	lea	$44e.w,a1
	move.l	(a1),a1
	adda.l	#1224,a1
	moveq	#65,d1
l2	moveq	#11,d0
l1	move.l	(a0)+,(a1)+
	dbf	d0,l1
	adda.l	#112,a0
	adda.l	#112,a1
	dbf	d1,l2
	add.l	#4,bfl
endskro
	movem.l (sp)+,d0-a6

;protim	eori.w	#$003,$ffff8240.w

new4b:	jmp	0		; will be set up by prog

******* end of scroll routine

killborder
	movem.l	d0-d7/a0-a1,-(sp)
	move.w	#$fa21,a1
	clr.b	-6(a1)
	move.b	#200,(a1)
	move.b	#8,$fffffa1b.w
	move.b	(a1),d0
wait4:	cmp.b	(a1),d0
	beq	wait4
	clr.b	$ffff820a.w
	REPT	16
	nop
	ENDR
	move.b	#2,$ffff820a.w
	move.l	#$ff8240,a0
	move.b	(a1),d0		; bottom border now away
del	cmp.b	(a1),d0
	beq	del
	move.l	#ch+2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,($ff8240)
	movem.l	(sp)+,d0-d7/a0-a1
	bclr	#0,$fffffa0f.w

	rte

coblo	dc.l	0,0,0,0
	dc.l	48,48,48,48
	dc.l	96,96,96,96
	dc.l	10720,10720,10720,10720
	dc.l	10768,10768,10768,10768
	dc.l	10816,10816,10816,10816
	dc.l	21440,21440,21440,21440
	dc.l	21488,21488,21488,21488
	dc.l	21536,21536,21536,21536
	dc.l	21536,21536,21536,21536
	dc.l	21488,21488,21488,21488
	dc.l	21440,21440,21440,21440
	dc.l	10816,10816,10816,10816
	dc.l	10768,10768,10768,10768
	dc.l	10720,10720,10720,10720
	dc.l	96,96,96,96
	dc.l	48,48,48,48
	dc.l	0,0,0,0
	
	dc.l	$ffffffff

bfl	dc.l	coblo

_left	dc.w	0
_blk	ds.w	256
delcon	dc.w	2
mespt	dc.l	preline
xdummy	dc.l	0
hertz	dc.b	2
outype	ds.w	1
old_sp	ds.l	1

mess	dc.b	27,'E',27,'e',"PLEASE SELECT OUTPUT FOR MENU MUSIC...."
	dc.b	13,10,13,10
	dc.b	"1. MONITOR SPEAKER",13,10
	dc.b	"2. REPLAY CARTRIDGE (8 BIT)",13,10
	dc.b	"3. REPLAY CARTRIDGE (12 BIT)",13,10
	dc.b	"4. PLAYBACK CARTRIDGE (STEREO!)",13,10
	dc.b	"5. STE REAR PORTS (STEREO!)",13,10,10
	dc.b	"WHAT'S YA CHOOSING DUDE? --==> "
	dc.b	0

preline	dc.b 	254,255,254,50

line	dc.b	"YAAAAA HOOOOO!!!!        RAW DATA SIGNING ON.    I'VE FINALLY BEEN LET LOOSE ON THE KEYBOARD!!    BUT, ONLY UNDER THE CLOSE ATTENTION OF THE REST OF THE CREW!!!        OK, FIRST "
	dc.b	"UP....    MERRY XMAS,    SORRY CHRISTMAS!! (THAT'S BETTER - SNAZ)....    SECONDLY....    X-BOOT.    PUT X-BOOT.PRG INTO AN AUTO FOLDER AS THE FIRST .PRG! "
	dc.b	"   THEN, PUT THE OTHER THREE X-BOOT FILES INTO A FOLDER ON THE ROOT DIRECTORY.    FINALLY, I HAD BETTER GET OFF, AS I'M SOBERING UP!!!!        OH, HAPPY DAYS!! "
	dc.b	"       RAW DATA HAS HAD HIS SAY ON A WILD! MENU!!!    NOW YOU'VE READ THE DRIVEL HE COMES OUT WITH, YOU NOW SEE WHY HE'S NEVER SAID ANYTHING BEFORE!!! "
	dc.b	"       THIS IS SPIKE OF THE WILD! BOYS NOW HITTING YOU WITH ANOTHER MEGA MENU!!!        HERE'S A QUICK MESSAGE TO RAW DATA....    STOP PLAYING WITH THE "
	dc.b	"KEYBOARD AND LET ME FINISH MY TYPING!!!!    NO, YOU CAN'T HAVE ANOTHER GO UNTIL SNAZ HAS HAD HIS SAY.    OK, I'LL GET BACK TO YAS SHORTLY, BUT FOR NOW "
	dc.b	"HERE'S........    SNAZ (SNITCH TO HIS CONTAX!   HO HO HO!)            HELLO AND WELCOME TO OUR MEGA MENU 25.    WELL, HERE WE ARE AT THE WILD! CHRISTMAS EVE GET "
	dc.b	"TOGETHER.    WHAT A CO-INCIDENCE THAT THIS IS OUR 25TH DISK AND IT IS THE 25TH OF DECEMBER IN A FEW MINUTES TIME!!    WE ARE ALL TOTALLY WRECKED AS USUAL!!        "
	dc.b	"    TWO MAJOR POINTS TO TELL YOU ABOUT....        FIRST UP....    IT'S CHRISTMAS!!    WHERE'S THE SNOW???        HERE IT IS!!    OH NO, IT'S NOT SNOW,    IT'S "
	dc.b	"SPIKE COMBING HIS HAIR OVER MY KEYBOARD AGAIN!!!        SECOND UP....        THE COLLABORATION IS NO MORE A COLLECTION OF TODAYS BEST GROUPS!!    INFACT, IT'S "
	dc.b	"NOT A COLLECTION OF ANY GROUPS!!!        YES, IT'S DEAD!!        WE WILL GIVE YOU MORE INFO WHEN IT COMES THROUGH!!        ANYWAY, HERE'S A FEW CHRISTMAS GREETINGS "
	dc.b	"THAT ARE SHOVED OUT TO....        SPECIAL FX (HI SLASHER)         THE POMPEY PIRATES (HI JUGGLER)        NORTHSIDE (HI MANI)        EVOLUTION (HI MANIX) "
	dc.b	"       CRIME (HI BRADLY)       BLUES BROTHERS (HI GRIM REEPER)        LOW-LIFE (HI TDM)        INSANITY (HI ICE-MAN  WHY NO REPLY?)        TIMEWARP "
	dc.b	"       CYNIX         NOW 5        FACTORY         THE PANFA        VOODOOO         WELL, THAT'S IT FOR NOW....    HERE'S RAW DATA        A BIG HI TO....    THE "
	dc.b	"PANFA AND TRACEY    ALEC AND CO    WRAITH    MALT    LEO (THE AMIGA OWNER)    FAT BOY (GRIZZLER)    SHAUN AND ALISON    RAW SINGING OFF 'WE WISH YOU A MERRY "
	dc.b	"CHRISTMAS, WE WISH YOU A (SHUT UP WILL YAS - SPIKE, SNAZ)        OK, SPIKE BACK TO WRAP THE CRAP!!        I PROMISE NO MORE SINGING FROM RAW DATA OR ANY "
	dc.b	"RUSTLING OF TOFFEE PAPERS FROM SNAZ!!!    (YOU'LL GET FAT SNAZ!!)        I THINK THAT I'LL....    ( BONG    BONG    BONG    BONG    BONG    BONG    BONG "
	dc.b	"   BONG    BONG    BONG    BONG    BONG )        YEAAAHHHH!!!!        IT'S FINALLY CHRISTMAS DAY, AND I'M OFF TO UNWRAP MY PRESSIES AND TO WRAP THIS UP!!! "
	dc.b	"           TIME FOR US TO GO....        THIS IS....        SPIKE....        RAW DATA....        SNAZ....        SIGNING OFF....        OOPS, JUST REMEMBERED, "
	dc.b	"SNAZ WANTS ANY HELP HE CAN GET, AS HE'S HAVING GREAT PROBLEMS WITH A MEGA 4 AND A HARD DRIVE (IT GIVES LOADSA PROBS MAN!!)            WRAPPY CHRSTMAS DUDES!!!! "
	dc.b	"           ROLL ON THE NEXT 25 WILD! CD'S........                         "

	dc.b	255

	ds.l	100	;stack goes backwards!!
mystack	ds.l	1

Emp	dc.b '\',0
Empty	dc.b 0
Prog1	dc.b '\lotus.spk',0
Prog2	dc.b '\desktop',0
Prog3	dc.b '\desktop',0

	EVEN

	even

*********************************
*       quartet routines        *
*********************************

install:
	lea	keydat,a0
	move.b	#$12,(a0)
	bsr	keysend

	lea	sing_s,a6		get playback routine start address
	move.w	#$1f64,_IRQmask(a6)	; stick $40 in for keyboard only
	move.w	outype,_SoundType(a6)	default, ie internal sound
	jsr	_Install(a6)

	lea	song_s,a5		address of song to play ->A5
	move.l	a5,_SongAddr(a6)	inform system of where song is
	lea	voice_s,a5		address of voiceset to use ->A5
	move.l	a5,_VoiceAddr(a6)	...and where current kit is!
	rts
;---------------------------------------------------------------------
play:	lea	sing_s,a6
	jsr	_Start(a6)		let's go!
	rts
;---------------------------------------------------------------------
deinstall:
	lea	sing_s,a6
	jsr	_DeInstall(a6)
	lea	keydat,A0
	move.b	#$8,(a0)
	bsr	keysend
	rts
;---------------------------------------------------------------------
keysend:
	pea	keydat
	move.w	#0,-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

keydat	dc.w	0
;----------------------------------------------------------------------
stopsong
	lea	sing_s,a6
	jmp	_Stop(a6)		stop!
	rts
;-------------------------------------------------------------------
restartsong
	;should have started (& stopped) a song before calling this!
	;but the program double-checks anyway
	lea	sing_s,a6
	jmp	_Restart(a6)		restart!
	rts

;-------------------------------------------------------------------

	SECTION DATA

int1	incbin	'intro1.pi1'

int2	incbin	'intro2.pi1'

ch	incbin	'cd25font.pi1'

FromScreen
	incbin	'cd25pic.pi1'

logos	incbin	'cd25anim.pi1'

sing_s	incbin	'rob5.bin'
	even

song_s	incbin	'zonk.4v'
	even

voice_s	incbin	'zonk.set'
	even


