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
	
go	move.l 	#defpal,a1
	lea 	$FFFF8240,a0
	moveq.l 	#15,d0
loopp	move.w 	(a0)+,(a1)+
	dbf 	d0,loopp
	
	pea	mouseoff
	move.l	#$190002,-(a7)
	trap	#14
	addq.l	#8,a7
	
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
	move.l	#$11fca,$4d6
	move.w	#$1,d0
	jsr	$13152

	clr.b 	$484
	lea 	$ff8240,a0
	lea 	$77fe0,a1
	moveq.l 	#15,d0
setcol	move.w 	(a1)+,(a0)+
	dbf 	d0,setcol
	move.w	#$f,d0
lp2	move.w	#$ffff,d1
lp1	dbf	d1,lp1
	dbf	d0,lp2
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
	lea 	$78000,a0
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
	cmp.b	#3,d0
	bne.s	next2
	move.b	#$ff,gembit
	bra	load
next2	cmp.b	#4,d0
	bne.s	next3
	move.w	d0,d6
	pea	addpath
	move.w	#$3b,-(a7)
	trap	#$1
	addq.l	#6,a7
	move.w	d6,d0
	bra	load
next3	cmp.b	#6,d0
	bne.s	next1
	move.b	#$ff,gembit
	bra.s	endmus
next1	cmp.b 	#8,d0
	bcc 	cont
	bra.s 	load
hz	eor.b 	#2,$ff820a
	bra 	cont
exo	clr.w 	-(a7)
	trap 	#1
load	
;   TURN MUSIC OFF THEN LOAD
endmus	move.l	d0,d7
	MOVE.L	#$FF8800,A0
	MOVE.L	#$8080000,(A0)
	MOVE.L	#$9090000,(A0)
	MOVE.L	#$A0A0000,(A0)
	CLR.L	$4D2
	CLR.L	$4D6
	pea	mouseon
	move.l	#$190002,-(a7)
	trap	#14
	addq.l	#8,a7

dp	lea 	$ff8240,a0
	move.l 	#defpal,a1
	moveq.l 	#15,d0
lo	move.w 	(a1)+,(a0)+
	dbf 	d0,lo

	cmp.b	#$ff,gembit
	bne.s	loadme
	clr.l	-(a7)
	trap	#$1
	
loadme	move.l 	#games,a0
notfo	subq.b 	#1,d7
	beq.s 	found
	add.l 	#$d,a0
	bra.s 	notfo
found	move.l 	a0,-(a7)
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
	lea	$11fa2,a1
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

vbl	move.l	d0,-(a7)
	move.w	#$1000,d0
vbl1	dbf	d0,vbl1
	move.l	(a7)+,d0
	rts	

addpath	DC.B	"ADDICTAB.ALL",0
gembit	dc.b	0
mouseoff	dc.b	$12,$1a,$01
mouseon	dc.b	$14,$08,$01

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
games	dc.b "BATMAN_A.LSD",$0
	dc.b "BATMAN_B.LSD",$0
	dc.b "            ",$0
	dc.b "addicta.lsd",$0,$0
	dc.b "warhawk.was",$0,$0
	dc.b "            ",$0
	dc.b "info.aut",$0
	even

**** MESSAGE FOR 1MB+ ST's ****

message	DC.B "   ----->     "
	DC.B "WELCOME TO DISK 50  -  THE FINAL ONE!          "
	DC.B "FIRST AN IMPORTANT MESSAGE TO ALL ST HACKERS AND "
	DC.B "SWAPPERS  -  BEWARE OF A.B.C.MAN (AKA UNCLE PERVO)  -"
	DC.B "  FOR THIS MAN HAS BEEN SHOWN TO BE EXTREMELY DODGY "
	DC.B "TO DEAL WITH, BE WARNED!! "
	DC.B "     ONTO CHEERIER THINGS, FIRST OF ALL WE MUST "
	DC.B "SAY A BIG HELLO TO OUR NEW FRIENDS IN AUSTRALIA "
	DC.B "- PIRASOFT/ACU, HOWS IT GOING GUYS?    "
	DC.B "ALSO HI TO  SERVO(WOT NO LIGGIE), SCS , SPECIAL FX, "
	DC.B "THE ELITE SQUAD, POWERS THAT BE       A FEW MENTIONS "
	DC.B "TO OTHER COMPACTION PEOPLE    SHARAZ JEK(NOW TEAMING "
	DC.B "UP WITH US),   THE UN-NAMABLES(YOU'RE GETTING THERE "
	DC.B "BOYS, SHAME ABOUT THE DODGY FORMATS) AND THE MEDWAY BOYS "
	DC.B "      OTHER ASSORTED HELLO'S MUST GO TO   TEX, SUB HUMANS IN TURKEY, "
	DC.B "THE ANGELS OF MERCY AND ALL AT THE SWINTON CLUB "
	
	DC.B "               WELL WE HAVE MADE IT TO DISK 50, A LOT "
	DC.B "OF PEOPLE DID NOT THINK WE WOULD MAKE IT, WE WERE NOT "
	DC.B "SO SURE AT TIMES.    FROM DISK 51 WE WILL BE KNOWN AS "
	DC.B "'AUTOMATION'.    WHY,  BECAUSE WE ARE EXPANDING AND "
	DC.B "CHANGING THE WAY THAT WE WORK.   'AUTOMATION' WILL "
	DC.B "BE MADE UP OF WAS(NOT WAS), L.S.D., SHARAZ JEK, BOB.M, "
	DC.B "IAN.C AND WHEN HE IS NOT MOANING ABOUT MAKING ANOTHER "
	DC.B "CUP OF COFFEE  RAMEESH!       GOSH WHAT A MOUTHFUL. "
	DC.B "         AS YOU KNOW BY NOW WAS(NOT WAS) HAS STOPPED "
	DC.B "WORKING FOR THE POST OFFICE, HE HAS GIVEN ALL THE MAIL "
	DC.B "HE HAD 'STORED' IN HIS CUPBOARD BACK AND HAD THE BLACK "
	DC.B "AND WHITE CAT SHOT!           MEOOOOOOOWWWWWWWW!             BANG!"
	DC.B "                WHAT THIS MEANS IS DO NOT SEND ANYTHING "
	DC.B "TO THE ADDRESS GIVEN IN EARLIER MENU,S.             OH, BY "
	DC.B "THE WAY 'WAS' WHAT DOES 'ANYONEONE' MEAN?         YOU CAN'T "
	DC.B "BLAME MARL FOR THAT ONE, AT LEAST I ONLY MISSED ONE LETTER, "
	DC.B "YOU SEEM TO HAVE DOUBLE VISION, LET RAMEESH TAKE CONTROL!       "
	DC.B "                  ANY WAY WATCH THIS SPACE FOR MORE INTERESTING "
	DC.B "WORDS AND ALL NEW SPELLING MYSTEAKS.        < ---- "
	DC.B "IS THIS GUY FOR REAL OR WHAT?           SOMETHING I HAVE JUST "
	DC.B "RECEIVED IS A LETTER FROM SOMEBODY WHO ABC MAN HAS RIPPED OFF, "
	DC.B "WELL WHAT A SUPRISE, ONLY THE FIFTH THIS WEEK!                 "
	DC.B "MUST GO,    SEE YA ALL AT THE ARCADE SHOW  22/2/89, TODAYS DATE "
	DC.B "IS  10/2/89, HOPE YOU HAVE ALL GOT YOUR TICKETS?? "
	DC.B "                                                  "
	DC.B "           YOU AGAIN, EH?                         "
	DC.B "                           GOOD HERE INNIT?        "
	DC.B "                                                    "
	DC.B "   BY THE WAY DID YOU DECODE THE HEX MESSAGE ON MENU 48 "
	DC.B "        IF NOT WHY NOT, YOU DIDN'T?          OK THEN HERE IT IS AGAIN      "
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
	DC.B "          WHAT DO YOU MAKE OF THAT THEN                "
	DC.B "               TEXT BY OZZ, HEX BY MARL, PHONEBILL BY WAS(NOT WAS), "
	DC.B "COFFEE BY RAMEESH, DISK NICKED BY NEIL.L, BULLSHIT BY ABC MAN, "
	DC.B "UGLINESS BY NEILBULUS, SOUP EATEN BY GUMMO.                  "
	DC.B "A MESSAGE FROM REBEL   -   WHAT KIND OF A GINGER HAIRED NIGGER "
	DC.B "IS THAT THEN?                           TO GET TO LEVEL 5 "
	DC.B "TYPE 'GONZO' ON THE HIGH SCORE TABLE!                      "
	DC.B "                             FUTURE PREDICTION TIME  -  ON DISK 1000 "
	DC.B "WE WILL HAVE DALEY THOMPSONS PENSION DAY, ANOTHER GAME THAT LOOKS LIKE XENON FROM THE "
	DC.B "BITMAP BROTHERS, ANOTHER STEVE BAK GAME WITH NAFF JOYSTICK ROUTINES, "
	DC.B "NEWS AT TEN(LICENSED BY US GOLD), MORE PARADOX(SOFTWARE HORIZONS) PAP, YET ANOTHER "
	DC.B "UNCRACKABLE PSYGNOSIS GAME('NOT ANOTHER ONE').                                 "
	DC.B "                OH,WELL TIME TO START AGAIN ----- >                         "
	dc.b $ff,$FF
	even

MUS1		INCBIN	"A:\out.DAT"
font1		INCBIN	"A:\OZZ.FNT"
piv		INCBIN	"A:\LSD50C.DAT"

