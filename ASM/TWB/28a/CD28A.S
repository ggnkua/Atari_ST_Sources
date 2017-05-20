
    ***************************
    *                         *
    *  WILD! CD28 SOURCE CODE *
    *                         *
    *     CODED BY SPIKE      *
    *                         *
    *  BOTTOM BORDER CODE IS  *
    *  UNIVERSAL AS EVER!     *
    *                         *
    ***************************

	move.l 4(a7),a5
	move.l #$100,-(a7)
	move.l a5,-(a7)
	move.l #$4a0000,-(a7)
	trap #1
	add.w #12,a7		; set up bits and pieces

	move.l	#0,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp	; get it into super!

	jsr	hblon		; start up bottom border interrupt

	move.b	#2,$484.w	; stop click but keep repeat

	moveq	#1,d0
	bsr	music		; pump out that muzak

	dc.w	$a00a		; bye bye mousey

	move.w  #2,-(sp)
        trap    #14
        addq.l  #2,a7
        move.l  d0,xdummy	; get screen address

	move.b	#2,$ff820a	; force 50 Hz

	move.l	#$ff8240,a1
	move.l	#piccy+2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)	; set up colours for screen

	move.w	#0,-(sp)
	move.l	#$66000,-(sp)
	move.l	#$66000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp	; set up $66000 as top of screen

	move.l	#piccy+34,a2
	move.w	#7999,d0
	lea	$44e.w,a0
	move.l	(a0),a0
	adda.l	#160,a0
	lea	(a2),a1
nextlc	move.l	(a1)+,(a0)+
	dbf	d0,nextlc	; put pic onto physical screen

	move.l	#1999,d0
clr	move.l	#0,(a0)+
	dbf	d0,clr		; clear bottom border as sometimes shit
				; stays behind

again	move.l  #scroll,wild	; message pointer to start of text
	move.l	#5760,cr1
	move.l	#0,cl1
	move.l	#0,crew+32042
	move.l	#0,crew+32046	; get crew scroller in correct palce

keyprs	move.w	#$ff,-(a7)	; wait for a key press (interrupted)
	move.w	#$06,-(a7)
	trap	#1
	addq.l	#4,a7

	cmp.b	#'1',d0
	beq	Run1
	cmp.b	#'2',d0
	beq	Run2
	cmp.b	#'3',d0
	beq	Run3
	cmp.b	#'4',d0
	beq	Run4
;	cmp.b	#'*',d0
;	beq	star
	cmp.b	#'0',d0
	beq	zero		; which key has been pressed

	*** The Routine to wiggle that WILD! logo ***

l0	moveq	#4,d2
shl0	bsr	shiftl
	dbf	d2,shl0
	bsr	yea
l1	moveq	#4,d2
shl1	bsr	shiftl
	dbf	d2,shl1
	bsr	yea
l2	moveq	#4,d2
shl2	bsr	shiftl
	dbf	d2,shl2
	bsr	yea
l3	moveq	#4,d2
shl3	bsr	shiftl
	dbf	d2,shl3
	bsr	yea
l4	moveq	#4,d2
shl4	bsr	shiftr
	dbf	d2,shl4
	bsr	yea
l5	moveq	#4,d2
shl5	bsr	shiftr
	dbf	d2,shl5
	bsr	yea
l6	moveq	#4,d2
shl6	bsr	shiftr
	dbf	d2,shl6
	bsr	yea
l7	moveq	#4,d2
shl7	bsr	shiftr
	dbf	d2,shl7
	bsr	yea

	bra	ok

	*** The Routine to scroll the WILD! crew members ***

yea	lea	$44e.w,a2
	move.l	(a2),a2
	adda.l	#32160,a2
	move.l	#crew+34,a3
	adda.l	cl1,a3
	move.l	#1199,d2
wc	move.l	(a3)+,(a2)+
	dbf	d2,wc
	add.l	#160,cl1
	cmpi.l	#32000,cl1
	bne	yop
	move.l	#0,cl1
yop	rts

ok	bra	spike
	
shiftl	lea	$44e.w,a2
	move.l	(a2),a2
	adda.l	#1120,a2
	moveq	#36,d0
loop4	moveq	#3,d1
loop5	lsl	(a1)
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
	addq.l	#2,a2
	dbf	d1,loop5
	lea	$98(a2),a2
	dbf	d0,loop4
	bsr	yovbl
	rts

shiftr	lea	$44e.w,a2
	move.l	(a2),a2
	adda.l	#1120,a2
	moveq	#36,d0
loop6	moveq	#3,d1
loop7	lsr	(a1)
	roxr	$38(a2)
	roxr	$40(a2)
	roxr	$48(a2)
	roxr	$50(a2)
	roxr	$58(a2)
	roxr	$60(a2)
	roxr	$68(a2)
	roxr	$70(a2)
	roxr	$78(a2)
	roxr	$80(a2)
	roxr	$88(a2)
	roxr	$90(a2)
	roxr	$98(a2)
	addq.l	#2,a2
	dbf	d1,loop7
	lea	$98(a2),a2
	dbf	d0,loop6
	bsr	yovbl
	rts

yovbl	move.l	$462.w,d0		;vbl frame counter
vbl	cmp.l	$462.w,d0		;wait for vbl
	beq.s	vbl
	rts

spike	jmp	keyprs

music	incbin	'pres_3.mus'
	even

runny	jsr	hbloff
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

star	jsr	hbloff
	move.w	#$777,$ff8240
	move.w	#0,$ff825e
	move.w	#0,$ff8242
	clr.w	-(sp)
	trap	#1			; just for the testing exit

Run1	move.l	#Emp,d5
	move.l	#Prog1,d6
	bra	runny

Run2	move.l	#Emp,d5
	move.l	#Prog2,d6
	bra	runny

Run3	move.l	#Emp,d5
	move.l	#Prog3,d6
	bra	runny

Run4	move.l	#Emp,d5
	move.l	#Prog4,d6
	bra	runny

zero	eori.w	#$400,ch+2
	move.b	(hertz),d0
	tst	d0
	beq	hz50
	move.b	#0,(hertz)
	jmp	spike

hz50	move.b	#2,(hertz)
	jmp	spike		; toggle 50/60Hz

hblon	move.l	$120,oldtb
	move.l	$70,old4
	move.l	$70,new4b+2
	move.b	$fffffa07,old07
	move.b	$fffffa09,old09
	and.b	#$df,$fffa09
	and.b	#$fe,$fffa07
	move.l	#killborder,$120
	move.l	#new4,$70
	or.b	#1,$fffffa07
	or.b	#1,$fffffa13
	rts			; starts the hb interupt

hbloff	move.w	sr,-(sp)
	move.w	#$2700,sr
	move.b	old07(pc),$fffffa07
	move.b	old09(pc),$fffffa09
	move.l	oldtb,$120
	move.l	old4,$70
	move.l	#$8080000,$ff8820
	move.l	#$9090000,$ff8820
	move.l	#$a0a0000,$ff8820
	move.l	#$707ffff,$ff8820
	move.w	(sp)+,sr
	rts			; stops the hb int + clear sound

new4	movem.l	d0-a6,-(sp)
	bsr	(music+8)
	move.l	#$ff8240,a1
	move.l	#piccy+2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	clr.b	$fffffa1b.w
	move.b	#199,$fffffa21
	move.b	#8,$fffffa1b
	move.l	#killborder,$120 ; sets up the bottom border

morepix	move.w	delcon,d0
	subq.w	#1,d0
	beq	mskro
	move.w	d0,delcon
	jmp	endskro
mskro	move.w	_left,d1
	dbf	d1,noneed
        move.l  wild,a0
        clr.l   d0
	move.b  (a0)+,d0
	cmp.b	#254,d0
	bne	gstring
	move.b	(a0)+,d0
	move.w	d0,delcon
	move.l	a0,wild
	jmp	morepix
gstring	cmp.b   #255,d0
        bne     cont
	move.b	#'[',d0
	move.l	#scroll,a0

cont	sub.b   #32,d0
	divu	#10,d0
	move.l	d0,d1
        mulu    #160*32,d0
	swap	d1
	lsl	#4,d1
	add.w	d1,d0
        add.l   #ch+34,d0
	move.l	a0,wild
        move.l  d0,a0
	move.l	#_blk,a1
	move.w	#31,d2
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
noneed	move.w	d1,_left
	move.l	#_blk+3,a1
	sub.w	d1,a1
	move.l	#$66000+17600,a2
	move.w	#0,d0
nexbp	move.l	a2,a0
	lea	2(a2),a2
	move.w	#31,d1

nexln	move.b	1(a0),(a0)
	move.b	1(a0),160(a0)

	move.b	8(a0),1(a0)
	move.b	8(a0),161(a0)

	move.b	9(a0),8(a0)
	move.b	9(a0),168(a0)

	move.b	16(a0),9(a0)
	move.b	16(a0),169(a0)

	move.b	17(a0),16(a0)
	move.b	17(a0),176(a0)

	move.b	24(a0),17(a0)
	move.b	24(a0),177(a0)

	move.b	25(a0),24(a0)
	move.b	25(a0),184(a0)

	move.b	32(a0),25(a0)
	move.b	32(a0),185(a0)

	move.b	33(a0),32(a0)
	move.b	33(a0),192(a0)

	move.b	40(a0),33(a0)
	move.b	40(a0),193(a0)

	move.b	41(a0),40(a0)
	move.b	41(a0),200(a0)

	move.b	48(a0),41(a0)
	move.b	48(a0),201(a0)

	move.b	49(a0),48(a0)
	move.b	49(a0),208(a0)

	move.b	56(a0),49(a0)
	move.b	56(a0),209(a0)

	move.b	57(a0),56(a0)
	move.b	57(a0),216(a0)

	move.b	64(a0),57(a0)
	move.b	64(a0),217(a0)

	move.b	65(a0),64(a0)
	move.b	65(a0),224(a0)

	move.b	72(a0),65(a0)
	move.b	72(a0),225(a0)

	move.b	73(a0),72(a0)
	move.b	73(a0),232(a0)

	move.b	80(a0),73(a0)
	move.b	80(a0),233(a0)

	move.b	81(a0),80(a0)
	move.b	81(a0),240(a0)

	move.b	88(a0),81(a0)
	move.b	88(a0),241(a0)

	move.b	89(a0),88(a0)
	move.b	89(a0),248(a0)

	move.b	96(a0),89(a0)
	move.b	96(a0),249(a0)

	move.b	97(a0),96(a0)
	move.b	97(a0),256(a0)

	move.b	104(a0),97(a0)
	move.b	104(a0),257(a0)

	move.b	105(a0),104(a0)
	move.b	105(a0),264(a0)

	move.b	112(a0),105(a0)
	move.b	112(a0),265(a0)

	move.b	113(a0),112(a0)
	move.b	113(a0),272(a0)

	move.b	120(a0),113(a0)
	move.b	120(a0),273(a0)

	move.b	121(a0),120(a0)
	move.b	121(a0),280(a0)

	move.b	128(a0),121(a0)
	move.b	128(a0),281(a0)

	move.b	129(a0),128(a0)
	move.b	129(a0),288(a0)

	move.b	136(a0),129(a0)
	move.b	136(a0),289(a0)

	move.b	137(a0),136(a0)
	move.b	137(a0),296(a0)

	move.b	144(a0),137(a0)
	move.b	144(a0),297(a0)

	move.b	145(a0),144(a0)
	move.b	145(a0),304(a0)

	move.b	152(a0),145(a0)
	move.b	152(a0),305(a0)

	move.b	153(a0),152(a0)
	move.b	153(a0),312(a0)

	move.b	(a1),153(a0)
	move.b	(a1),313(a0)

	lea	480(a0),a0
	lea	4(a1),a1
	dbf	d1,nexln
	dbf	d0,nexbp

endskro	;eori.w	#$020,$ffff8240.w
	movem.l (sp)+,d0-a6
new4b	jmp	0		; will be set up by prog

killborder
	movem.l	d0-d7/a0-a1,-(sp)
	move.w	#$fa21,a1
	clr.b	-6(a1)
	move.b	#200,(a1)
	move.b	#8,$fffffa1b.w
	move.b	(a1),d0
wait4	cmp.b	(a1),d0
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
	move.w	#$300,$ffff8240.w
	;move.l	#ch+2,a0
	;movem.l	(a0),d0-d7
	;movem.l	d0-d7,($ff8240)
	movem.l	(sp)+,d0-d7/a0-a1
	bclr	#0,$fffffa0f.w
	rte

_left	dc.w	0
_blk	ds.w	256
cr1	dc.l	1
cl1	dc.l	1
delcon	dc.w	2
wild	dc.l	scroll
xdummy	dc.l	0
old4	dc.l	0
oldtb	dc.l	0
old07	dc.b	0
old09	dc.b	0
	
scroll	dc.b	"   YEEAAHHHHH!!!!                WILD! ARE PROUD TO PRESENT COMPACT DISK NUMBER 28.        THIS CD WILL BE IN THREE PARTS (YES, THREE!!), SO MAKE SURE YOU HAVE THEM ALL, OTHERWISE YOU WON'T BE ABLE TO PLAY GOBLINS!!!"
	dc.b	"          SPIKE AT THE KEYBOARD DUDES....        DO YOU LIKE THIS INTRO???    NOT BAD, EH??            RIGHT, FIRST OFF I WOULD LIKE TO TELL YOU ABOUT A FEW GOINGS ON IN OUR CREW.        THE PANFA AND RAW DATA ARE "
	dc.b	"PUTTING TOGETHER A SERIES OF WILD! CD'S CALLED....      THEME DISKS            THESE WILL BE CIRCULATING VERY SHORTLY AND WILL CONTAIN GAMES OR PROGRAMS ON VARIOUS THEMES. (OUR FIRST BEING A LINK-UP DISK!!!)            "
	dc.b	"PLEASE COLLECT THESE AS WELL AS OUR MAIN CD'S AS THEY CAN COME IN VERY HANDY!!!    ALSO, WHY MISS OUT ON SOME EXCELLENT PACKING AND GRAFIX. (DID YOU LIKE THAT EGO-BOOST PANFA AND R.D.???)          SECONDLY, SNAZ IS "
	dc.b	"CONCENTRATING ON DISHING OUT SOME MORE MOD DISKS.    UNFORTUNATELY, SOMEONE HAS GOT ALL THE MODS!! (HAVEN'T THEY RAW DATA!).            HERE'S A QUICK MESSAGE TO SNAZ OF WILD!      WHEN WE THROW A SURPIRSE BIRTHDAY "
	dc.b	"FOR YAS NEXT TIME, DO YOU THINK YOU MIGHT HAVE THE COURTESY TO TURN UP!!!!!!        (SEE I SAID I WOULD TELL EVERYONE ABOUT IT!!)        HERE'S A QUICK QUESTION....        HAS ANYONE PLAYED A GAME CALLED....        "
	dc.b	"BOMBERS???        IT INVOLVES STICKING AS MANY COINS UP YOUR ARSE, WALKING ABOUT 12 FEET, AND THEN RELEASE THEM INTO A CONTAINER!!    THE ONE WITH THE MOST WINS.        WE PLAYED THIS ON BOXING DAY.    WARNING, YOU "
	dc.b	"HAVE TO BE TOTALLY SMASHED TO PLAY THIS, OTHERWISE THE EMBARASSMENT WILL OVERCOME YOU!!!            WELL, THAT'S GOT A COUPLE OF THINGS OUT IN THE OPEN. (AND I HAVEN'T EVEN TOLD YOU ABOUT THE SHEEP YET!!!!)            "
	dc.b	"OK, ENOUGH IS ENOUGH, IT'S TIME TO GIVE THE SALUTATIONS (THAT'S GREETINGS, LAMERS!)            WILD! GREETZ GO TO:-        SPECIAL FX (NICE MEETING AND CHATTING TO YOU SLASHER)        POMPEY PIRATES (DON'T STOP!)        "
	dc.b	"LOW LIFE (HI TDM)        N-SONIC (HI TWITCH)        NOW 5        FACTORY        CYNIX        THE DIRTY TRICKS BRIGADE        SYNDICATE        INSANITY        EVOLUTION        THE BLUES BROTHERS        ADRENALIN (LIKE "
	dc.b	"YOUR FIRST MENU BOYS! AND ALL DOWN TO 12K AS WELL!!)        ICC        NORTHSIDE        ALCHEMY AND ALL MEMBERS OF SPECIAL FX        ORION (HI SPIKE!!)        SUPERIOR (ANYMORE UPDATES ON PACK-ICE AXE??)        CLOCKWORK "
	dc.b	"ORANGE        NEW ORDER        AND ALL OTHER GROUPS THAT KNOW US!! (IF YOU WERE MISSED, THEN LET SNAZ OR ANY MEMBER OF THE CREW KNOW!!)            OK, IT'S TIME TO WRAP THIS CD UP.        HOPE YOU ENJOY GOBLINS AND "
	dc.b	"GET A BIT FURTHER THAT ME!!            WRAPPY DOOOOOO DUDES................            "
	dc.b	255
	ds.l	100
mystack	ds.l	1

	even

ch	incbin	'cd28font.pi1'
	even

piccy	incbin	'wild28a.pi1'
	even

crew	incbin	'wildcrew.pi1'
	ds.l	1200
	even

Emp	dc.b	'a:\',0
Empty	dc.b	0
Prog1	dc.b	'goblins.wld',0
Prog2	dc.b	'desktop',0
Prog3	dc.b	'desktop',0
Prog4	dc.b	'mandel.wld'
hertz	dc.b	2

	even



        