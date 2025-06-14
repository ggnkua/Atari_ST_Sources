	move.l 	a7,a5
	move.l 	$4(a5),a5
	move.l 	#$1000,d0
	move.l 	d0,-(a7)
	move.l 	a5,-(a7)
	move.l 	#$4a0000,-(a7)
	trap 	#1
	dc.w 	$a00a
	add.l 	#$c,a7
	
	clr.l	-(a7)
	move.w 	#$20,-(a7)
	trap 	#1
	addq.l 	#6,a7
	move.l 	d0,savea7
	move.b	#'!',$1000	
go	move.l 	#defpal,a1
	lea 	$FFFF8240,a0
	moveq.l 	#15,d0
loopp	move.w 	(a0)+,(a1)+
	dbf 	d0,loopp
	
	lea 	$80000,a7
	clr.w 	-(a7)
	move.l 	#$78000,-(a7)
	move.l 	#$78000,-(a7)
	move.w 	#5,-(a7)
	trap 	#14
	add.l 	#$c,a7
	
	lea 	$ff8240,a0
	moveq.l 	#15,d0
ooo	clr.w 	(a0)+
	dbf 	d0,ooo
	
	bsr 	depack

; START THE MUSIC
	move.l	#vbl,$4d2
	move.w	#$1,D0
	JSR	$2C4D2

	clr.b 	$484
	lea 	$ff8240,a0
	lea 	$77fe0,a1
	moveq.l 	#15,d0
setcol	move.w 	(a1)+,(a0)+
	dbf 	d0,setcol
	clr.w 	$ff8240
	move.b 	#2,zero2
restart	lea 	message,a6
nextlet	move.b 	(a6)+,d0
	cmp.b 	#$ff,d0
	bne.s 	notend
	cmp.b	#$ff,(a6)
	beq.s	restart
	lea	message,a6
	bra.s 	nextlet
notend	clr.w 	d5
	andi.l 	#$ff,d0
	lea 	$30000,a1
	adda.l 	d0,a1
	lea 	build,a2
	moveq.l 	#7,d7
allchar	move.b 	(a1),(a2)+
	adda.l 	#$100,a1
	dbf 	d7,allchar
test0	cmpi.b 	#0,zero2
	bne.s 	sub1
	move.w 	#37,-(a7)
	trap 	#14
	addq.l	#2,a7
	move.b 	#2,zero2
sub1	subq.b 	#1,zero2
key	move.l 	#$600ff,-(a7)
	trap 	#1
	addq.l 	#4,a7
	tst.w 	d0
	bne.s 	keyhit
cont	moveq.l 	#0,d0
	lea 	build,a5
	lea 	$7f6C0,a0
	moveq.l 	#7,d7
lines	move.l 	a0,-(a7)
	adda.l 	#$138,a0
	move.b 	(a5),d1
	lsl.b 	#1,d1
	move.b 	d1,(a5)+
	moveq.l 	#$13,d6
cols	move.w 	(a0),d1
	roxl.w 	#1,d1
	move.w 	d1,(a0)
	move.w 	d1,$2(a0)
	move.w 	d1,$4(a0)
	move.w 	d1,$6(a0)
	subq.l 	#8,a0
	dbf 	d6,cols
	movea.l 	(a7)+,a0
	adda.l 	#$a0,a0
	dbf 	d7,lines
	addq.w 	#1,d5
	andi.w 	#7,d5
	bne 	test0
	bra 	nextlet
keyhit	nop
	sub.b 	#$30,d0
	cmp.b 	#0,d0
	bcs.s 	cont
	beq.s 	hz
	cmp.b	#2,d0
	bne.s	next2
	move.w	d0,d6
	pea	trakpath
	move.w	#$3b,-(a7)
	trap	#$1
	addq.l	#6,a7
	move.w	d6,d0
	bra	load
next2	cmp.b	#5,d0
	bne.s	next1
	move.b	#$ff,gembit
	bra.s	endmus
next1	cmp.b 	#6,d0
	bcc 	cont
	bra.s 	load
hz	eor.b 	#2,$ff820a
	bra 	cont
exo	clr.w 	-(a7)
	trap 	#1
load	
;   TURN MUSIC OFF THEN LOAD
endmus	MOVE.L	#$FF8800,A0
	MOVE.L	#$8080000,(A0)
	MOVE.L	#$9090000,(A0)
	MOVE.L	#$A0A0000,(A0)
	CLR.L	$4d2
	cmp.b	#$ff,gembit
	bne.s	loadme
	clr.l	-(a7)
	trap	#$1
	
loadme	move.l 	#games,a0
notfo	subq.b 	#1,d0
	beq.s 	found
	add.l 	#$d,a0
	bra.s 	notfo
found	move.l 	a0,-(a7)
dp	lea 	$ff8240,a0
	move.l 	#defpal,a1
	moveq.l 	#15,d0
lo	move.w 	(a1)+,(a0)+
	dbf 	d0,lo
	move.l 	(a7)+,a0
	move.l 	a0,fadd+2
	clr.w 	-(a7)
	move.l 	#$ffffffff,-(a7)
	move.l 	#$ffffffff,-(a7)
	move.w 	#5,-(a7)
	trap 	#14
	add.l	#$c,a7
	move.l 	savea7,-(a7)
	move.w 	#$20,-(a7)
	trap 	#1
	addq.l 	#6,a7
user	lea 	$80000,a7
loadit	move.l 	#$60000,-(a7)
	move.l 	#$60000,-(a7)
fadd	move.l 	#0,-(a7)
	move.l 	#$4b0000,-(a7)
	trap 	#1
	add.l 	#$10,a7
wait	bra.s wait
depack	lea 	font1(pc),a0
	lea 	$30000,a1
	bsr.s 	depack1
	lea 	$77fde,a1
	lea 	piv(pc),a0
loadsaram	bsr.s	depack1
	lea	$2c000,a1
	lea	MUS1(PC),A0
depack1	movem.l 	(a0)+,d0-d1/d5
	movea.l 	a1,a2
	adda.l 	d0,a0
	adda.l 	d1,a2
	move.l 	-(a0),d0
	eor.l 	d0,d5
l1	lsr.l 	#1,d0
	bne.s 	l2
	bsr 	l16
l2	bcs.s 	l9
	moveq 	#8,d1
	moveq 	#1,d3
	lsr.l 	#1,d0
	bne.s 	l3
	bsr 	l16
l3	bcs.s 	l11
	moveq 	#3,d1
	clr.w 	d4
l4	bsr 	l17
	move.w 	d2,d3
	add.w 	d4,d3
l5	moveq 	#7,d1
l6	lsr.l 	#1,d0
	bne.s 	l7
	bsr 	l16
l7	roxl.l 	#1,d2
	dbf 	d1,l6
	move.b 	d2,-(a2)
	dbf 	d3,l5
	bra.s 	l13
l8	moveq 	#8,d1
	moveq 	#8,d4
	bra.s 	l4
l9	moveq 	#2,d1
	bsr 	l17
	cmpi.b 	#2,d2
	blt.s 	l10
	cmpi.b 	#3,d2
	beq.s 	l8
	moveq 	#8,d1
	bsr.s 	l17
	move.w 	d2,d3
	move.w 	#12,d1
	bra.s 	l11
l10	move.w 	#9,d1
	add.w 	d2,d1
	addq.w 	#2,d2
	move.w 	d2,d3
l11	bsr.s 	l17
l12	subq.w 	#1,a2
	move.b 	0(a2,d2.w),(a2)
	dbf 	d3,l12
l13	cmpa.l 	a2,a1
	blt 	l1
	tst.l 	d5
	bne.s 	l14
	rts
l14	nop
l15	moveq 	#1,d0
	rts
l16	move.l 	-(a0),d0
	eor.l 	d0,d5
	move.b 	#$10,ccr
	roxr.l 	#1,d0
	rts
l17	subq.w 	#1,d1
	clr.w	 d2
l18	lsr.l 	#1,d0
	bne.s	 l19
	move.l 	-(a0),d0
	eor.l 	d0,d5
	move.b 	#$10,ccr
	roxr.l 	#1,d0
l19	roxl.l 	#1,d2
	dbf 	d1,l18
	rts

vbl		jsr	$2c028
		move.w	#$ffff,$4ee
		rts
		

trakpath	dc.b	"traksuit",0
elfpath	dc.b	"elf",0
gembit	dc.b	0

defpal	dc.l $0,$0,$0,$0,$0,$0,$0,$0
zero2	dc.w $0
sizeup	dc.l $0
toggle	dc.w $0
savea7	dc.l $0
moff	dc.w $1201
mon	dc.w $801
joff	dc.w $1a01
jon	dc.w $1401
build	dc.l $0,$0,$0,$0
games	dc.b "fizz.lsd",$0,$0,$0,$0,$0
	dc.b "traksuit.lsd",$0
	dc.b "rugby.lsd",$0,$0,$0,$0
	dc.b "elf.lsd",$0,$0,$0,$0,$0,$0
	even

**** MESSAGE FOR 1MB+ ST's ****

message	DC.B "   "
	DC.B "<<<< WEEEEE <<<<  HERE WE ARE AGAIN.....           "
	DC.B "CONGRATULATIONS GO TO FINAL FOR HIS FIRST HACK:-   "
	DC.B "'TRACKSUIT MANAGER', WE HOPE THIS IS THE START OF "
	DC.B "SOMETHING BIG (OOER).   A MESSAGE TO ALL OUR FANS, "
	DC.B "ONLY 2 MORE L.S.D. DISKS TO GO, YES, DISK 50 WILL "
	DC.B "BE OUR LAST.  HOW WILL YOU EVER MANAGE WITHOUT LSD "
	DC.B "COMPILATION DISKS?     WHAT WILL WE BE DOING NOW?  "
	DC.B "   WHY IS DISK 50 THE LAST ONE?       FOR THE ANSWER "
	DC.B "TO THESE AND MANY MORE QUESTIONS, CHECK OUT DISKS 49 "
	DC.B "AND 50.     HOW MANY OF OUR 50 DISKS WILL YOU HAVE "
	DC.B "WHEN WE HAVE DONE?   A WORTHWHILE SET FOR EVERYONE "
	DC.B "BETTER THAN COLLECTING STAMPS.                     "
	DC.B "TRANSCONTINENTAL GREETINGS GO TO OUR NEW FRIENDS IN "
	DC.B "AUSTRALIA (G'DAY COBBERS, PASS THE XXXX).           "
	DC.B "WE HOPE TO SEE YOU ALL AT THE ARCADE SHOW IN FEBRUARY, "
	DC.B "HUNDREDS OF UP TO THE MINUTE ARCADE MACHINES, TOP OF "
	DC.B "THE RANGE CABINETS, ALL FREEEEE    JUST TROT ALONG TO "
	DC.B "BLACKPOOL, OF COURSE YOUR BIGGEST PROBLEM IS HOW TO "
	DC.B "GET IN, AS IT'S A TRADE ONLY DO (BET YOU DIDN'T KNOW "
	DC.B "HACKIN' WAS A TRADE DID YOU?).                    "
	DC.B "COMING SOON:-        (MAYBE!)      BAAL, BATMAN, "
	DC.B "CRAZY CARS II, KENNEDY APPROACH, BARBARIAN II, "
	DC.B "PURPLE SATURN DAY, GHOSTS & GOBLINS, WIERD DREAMS "
	DC.B "AND L.E.D. STORM,      ALL WE HAVE TO DO NOW IS "
	DC.B "FIGURE OUT HOW TO GET ALL THESE ONTO OUR LAST 2 "
	DC.B "DISKS,  WHICH ONES WILL COME ON WHICH DISK?    "
	DC.B "PLACE YOUR BETS NOW!!!!                        "
	DC.B "HERE'S A RAVE FROM THE GRAVE, A MESSAGE FROM "
	DC.B "DAYS GONE BY:-               "
	DC.B "'BEWARE OF KEVIN FROM WAKEFIELD'   AND HERE'S "
	DC.B "A COUPLE OF NEW ONES:-                "
	DC.B "'YOU CAN'T BE TOO CAREFUL WITH ABC MAN' (AKA "
	DC.B "UNCLE PERVO),          'BUY AN AMIGA NOW'     "
	DC.B "        'THX-1138 IS A COMPLETE PLEB'  (WHO IS "
	DC.B "DANGEROUSLY CLOSE TO MEETING HIS MAKER (MECHANO)) "
	DC.B "                'IT IS, WE ARE, NEIL.L IS NOT!!!'    "
	DC.B "           !!TSENOH YZARC TON M'I                 "
	DC.B "THAT'S ALL FOR THIS WEEK,   TUNE IN NEXT WEEK...  "
	DC.B "SAME TIME, SAME CHANNEL!!                         "
	DC.B "                                                  "
	DC.B "NA NE NA NA    NA NE NA NA    NA NE NA NA    NA NE NA NA "
	DC.B "           YOU ARE ABOUT TO ENTER THE TWILIGHT ZONE "
	DC.B "                                                    "
	DC.B "MESSAGE TO COMPUTER WIZ KIDS (GET A PEN READY):-    "
	DC.B "          5           4         3          2           1"
	DC.B "          $49  $46  $20  $59  $4F  $55  $27  $52  $45  "
	DC.B "$20  $41  $53  $20  $53  $4D  $41  $52  $54  $20  $41  "
	DC.B "$53  $20  $59  $4F  $55  $20  $54  $48  $49  $4E  $4B  "
	DC.B "$20  $59  $4F  $55  $20  $41  $52  $45  $2C  $20  $57  "
	DC.B "$48  $59  $20  $41  $52  $45  $20  $59  $4F  $55  $20  "
	DC.B "$44  $45  $43  $4F  $44  $49  $4E  $47  $20  $54  $48  "
	DC.B "$49  $53  $20  $49  $4E  $53  $54  $45  $41  $44  $20  "
	DC.B "$4F  $46  $20  $43  $52  $41  $43  $4B  $49  $4E  $47  "
	DC.B "$20  $50  $52  $4F  $54  $45  $43  $54  $49  $4F  $4E  "
	DC.B "$20  $53  $59  $53  $54  $45  $4D  $53  $20  $28  $48  "
	DC.B "$45  $20  $48  $45  $29  $2E                           "
	DC.B "AND IF YOU CAN READ THAT, YOU SHOULDN'T BE!!!!         "
	DC.B "BYE....          MARL               LSD                "
	DC.B "                                                       "
	DC.B ">>>>>>>>>>>>>>> SCROLL RESTART IMMINENT >>>>>>>>>>>>>>"
	DC.B "                        THE PASSWORD IS:-              "
	DC.B "'A WET FISH ON A PINK BATH MAT'                        "
	DC.B "MIKE XMW HATES THE S.T.    THAT'S WHY HE'S GETTIN' ONE!"
	DC.B "                             HOW'S THE SOUP GUMMO      "
	DC.B "               O<--<   STICK MAN SUNBATHING!!!         "
	DC.B " +-----====   KEVIN SUNBATHING                         "
	DC.B "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	DC.B "                                                       "
	dc.b $ff,$FF
	even

MUS1		INCBIN	"2c000.DAT"
font1		INCBIN	"OZZ.FNT"
piv		INCBIN	"MENPIC.DAT"

