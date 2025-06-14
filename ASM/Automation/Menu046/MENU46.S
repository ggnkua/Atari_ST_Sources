	move.l 	a7,a5
	move.l 	$4(a5),a5
	move.l 	$c(a5),d0
	add.l 	$14(a5),d0
	add.l 	$1c(a5),d0
	add.l 	#$100,d0
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
	MOVE.L	#$160D2,$4d2
	MOVE.B	#$7,$1D826
	
	clr.b 	$484
	
	lea 	$ff8240,a0
	lea 	$77fe0,a1
	moveq.l 	#15,d0
setcol	move.w 	(a1)+,(a0)+
	dbf 	d0,setcol
	clr.w 	$ff8240
	move.b 	#2,zero2
restart	lea 	message,a6
	cmp.b	#4,$424.w
	bne.s	nextlet
	lea	message2,a6 
nextlet	move.b 	(a6)+,d0
	cmp.b 	#$ff,d0
	bne.s 	notend
	cmp.b	#$ff,(a6)
	beq.s	restart
	lea	message3,a6
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
	cmp.b	#4,$424.w
	beq.s	cont
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
	cmp.b 	#3,d0
	bcc.s 	cont
	bra.s 	load
hz	eor.b 	#2,$ff820a
	bra.s 	cont
exo	clr.w 	-(a7)
	trap 	#1
load	
;   TURN MUSIC OFF THEN LOAD
	MOVE.L	#$FF8800,A0
	MOVE.L	#$8080000,(A0)
	MOVE.L	#$9090000,(A0)
	MOVE.L	#$A0A0000,(A0)
	CLR.L	$4d2
	
	move.l 	#games,a0
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
	cmp.b	#4,$424.w
	bne.s	loadsaram
	lea	piv2(pc),a0
loadsaram	bsr.s	depack1
	lea	$1d100,a1
	lea	MUS2(PC),A0
	bsr.s	depack1
	lea	$160d2,a1
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
games	dc.b "menace.lsd",$0,$0,$0
	dc.b "rtype.lsd",$0,$0,$0,$0
	even

**** MESSAGE FOR 1MB+ ST's ****

message	DC.B "   "
	DC.B "LUCKY YOU, YOU'VE GOT ENOUGH RAM TO PLAY THESE TWO "
	DC.B "GREAT GAMES (BOTH ARE SINGLE PART 1MB+ VERSIONS).  "
	DC.B "PLEASE NOTE:   MENACE SAVES SCORES TO "
	DC.B "TRACK 0 SECTOR 6.     HIT  '0'  TO TOGGLE  50/60 hz.     "
	dc.b $FF,0

**** MESSAGE FOR 512K SUCCERS ****

message2	DC.B "  "
	DC.B "SORRY!! IT SEEMS THAT YOUR ST HAS ONLY 512K RAM "
	DC.B "AVAILABLE, WHICH UNFORTUNATELY IS NOT ENOUGH TO "
	DC.B "RUN THE TWO GAMES ON THIS DISK (R-TYPE & MENACE). "
	DC.B "HOWEVER, YOU CAN STILL READ THE SCROLL, ADMIRE THE "
	DC.B "PICTURE AND LISTEN TO THE MUSIC, IT MAY NOT BE AS "
	DC.B "GOOD, BUT IT'S ALL YOUR GETTIN'  "
	DC.B $FF,0	

**** MESSAGE FOR EVERYONE ****

message3	DC.B "    ON WITH THE NORMAL SCROLL  ---->>>>>>          "
	DC.B "LATER IN THIS SCROLL, WE WILL TELL YOU WHAT WE THINK OF "
	DC.B "'HACKERS', GIVE YOU TIPS ON HOW TO WRITE YOUR OWN PACKER "
	DC.B "('CAUSE YOU SURE AS HELL AINT GETTIN' OURS!!), AND OF "
	DC.B "COURSE HAVE THE ALL IMPORTANT GREETINGS, BUT FIRST SOME "
	DC.B "NEWS...........       OK, OZZ HERE AND THE FIRST NEWS "
	DC.B "IS NOT SO GOOD, BY THE TIME YOU READ THIS, THERE WILL "
	DC.B "BE ONLY THREE PEOPLE LEFT IN L.S.D.  THE FOURTH HAS "
	DC.B "BEEN FOUND TO BE UNRELIABLE FAR TOO OFTEN, HAS GOT "
	DC.B "HIMSELF INTO SERIOUS DEBT WITH FRIENDS OF THE GROUP, "
	DC.B "PROVED UNWILLING TO SHARE THE EXPENSES OF OUR SOCIAL "
	DC.B "MEETINGS AND IN GENERAL HAS NOT BEEN AN ACTIVE PARTICIPENT "
	DC.B "IN THE CRACKING/PACKING OR SWAPPING, WHICH IS (LET'S "
	DC.B "FACE IT,) WHAT THE GROUP IS ALL ABOUT.  THIS FOURTH "
	DC.B "MEMBER IS (AS SOME OF YOU WILL HAVE GUESSED NOW,) NEIL.L. "
	DC.B "SORRY NEIL, YOU MAY HAVE BEEN USEFUL AS A DRIVER, BUT WE "
	DC.B "NEED A BIT MORE FROM OUR MEMBERS.          "

	DC.B "ONTO A HAPPIER NOTE,  IT'S GOOD TO SEE THAT THE MENUS "
	DC.B "ARE GOING DOWN WELL WITH EVERYONE.  I HOPE YOU "
	DC.B "LIKE THE CUTE GRAPHIX (DONE BY MARL) IN THIS ONE.     "
	DC.B "IT'S DISSAPOINTING TO SEE THAT THE GAUNTLET THROWN DOWN "
	DC.B "BY US STILL HASN'T BEEN TAKEN UP SERIOUSLY BY ANYONE, IS "
	DC.B "THE 'PAMPUK' SYSTEM THE ONLY COMPETITION AROUND,  IF SO "
	DC.B "THEN IT CERTAINLY IS A ONE HORSE RACE (THE HAPPY PACKER "
	DC.B "ONLY COUNTS AS A MULE  HE HE!)   COME ON 'S.T.C.S' WE "
	DC.B "KNOW 'PAMPUK' IS HELD TOGETHER WITH 'HAPPY' ROUTINES.  "
	DC.B "I'M SURE YOU CAN DO BETTER, AND THE REST OF YOU 'HACKERS' "
	DC.B "SHOULD STOP WRITING, ASKING FOR OUR PACKER. GO DEVELOP ONE "
	DC.B "OF YOUR OWN.  AND WHILE WE'RE ON THE SUBJECT, YOU GUYS REALLY "
	DC.B "SHOULD LEAVE 'RAID' ALONE AND GET INTO SOME SERIOUS UTILS "
	DC.B "LIKE DEVPAC 2, MUCH EASIER TO 'CRACK' WITH.     "
	DC.B "IN THE WORD OF OLD 'WAS' HIMSELF....     'CRACKING THE "
	DC.B "GAMES IS EASY, COMPACTING THEM INTO A SESIBLE FORM TAKES "
	DC.B "A LOT MORE TIME AND SKILL'.   AND HE SHOULD KNOW, HE "
	DC.B "SPENDS ENOUGH TIME AT IT (OO'ER).  ANYONE WHO'S WROTE AN INTRO "
	DC.B "CAN WRITE A PACKER, TAKE IT FROM US, THEY'RE NOT AS "
	DC.B "COMPLICATED AS YOU FIRST THINK.  START SIMPLE AND BUILD "
	DC.B "ON THE IDEA AS YOU GO ON.  HERE'S A CLUE TO START YOU OFF "
	DC.B "'THERE ARE ONLY 256 DIFFERENT PERMUTATIONS OF THE COMMON "
	DC.B "'BYTE', AND 63356 PERMUTATIONS OF THE 'WORD', SOME OF THESE "
	DC.B "PERMUTATIONS MUST OCCUR MORE THAN ONCE, SO LOOK FOR THE LARGEST "
	DC.B "QUANTITIES OF THE SMALLEST UNIT (BYTE)'.   EASY EH!   IF YOU "
	DC.B "STILL HAVEN'T GOT IT YET HERE'S ONE OF MARLS HEAVY ANALAGIES "
	DC.B "   'IF YOU TOOK 100 COINS OF MIXED DENOMINATIONS AND STACKED THEM "
	DC.B " INTO PILES, YOU WOULDN'T MAKE 100 PILES OF ONE COIN EACH, YOU WOULD "
	DC.B "FIND A WAY TO GROUP THEM!!'   REMEMBER YOU CAN DO WHAT YOU WANT "
	DC.B "TO A PROGRAM TO STORE IT ON DISK, AS LONG AS YOU PUT IT BACK THE "
	DC.B "WAY IT WAS WHEN YOU LOAD IT INTO MEMORY!.     END OF LECTURE.   "

	DC.B "OK HERE ARE A FEW GREETINGS TO PEOPLE WE THINK DESERVE IT:-    "
	DC.B "     CLIMAX, SPECIAL FX, A-HA, SERVO, THE ELITE SQUAD, THE POWERS "
	DC.B "THAT BE,  AND LAST BUT NOT LEAST, ROB'S BLACK AND WHITE CAT!!!!  "
	DC.B "AND REMEMBER, ANY PROBLEMS WITH OUR COMPACTIONS (THAT WEREN'T IN "
	DC.B "THE ORIGINAL GAME) AND LET US KNOW, WE'LL PUT IT RIGHT STRAIGHT AWAY!        " 
		
	DC.B "RIGHT,                    THATS ALL FOLKS                    "
	DC.B "                              COME ON GUYS, THAT REALLY WAS THE END."
	DC.B "                                           YOU ARE BEING AWKWARD NOW"
	DC.B "                                           STILL THERE?             "
	DC.B "                              STATUS                               "
	DC.B "                              CRASH LANDED ON TARG                    "
	DC.B "                              <<<--- WHAT????                      "
	DC.B "                              RIGHT THATS IT, CLEAR OFF THE LOT OF YOU "
	DC.B "                              GO ON SCRAM!!                        "
	DC.B "                                                               "
	DC.B "OK THEN YOU ASKED FOR IT, WE'LL START AGAIN...........            "
	dc.b $ff,$FF
	even

MUS1		INCBIN	"160D2.DAT"
MUS2		INCBIN	"1D100.DAT"
font1		INCBIN	"OZZ.FNT"
piv		INCBIN	"MENPIC.DAT"
piv2		INCBIN	"MENPIC2.DAT"

;	DC.B "OF L.S.D., THIS IS DUE TO HIS UNRELIABILITY AND "
;	DC.B "REFUSAL TO PAY HIS DEBTS!   HE ALSO REFUSED TO BUY "
;	DC.B "A ROUND OF DRINKS!!  SO, THE L.S.D. NOW ONLY CONSISTS "
;	DC.B "OF MYSELF (OZZ) , MARL AND REBEL, ONTO NICER THINGS, "

;	DC.B "IS A ONE HORSE RACE. COME ON 'STCS' STOP RIPPING THE "
;	DC.B "HAPPY CRUNCHER OFF, I AM SURE YOU CAN DO BETTER.    " 
;	DC.B "ANYWAY, ANY COMPLAINTS TO THE USUAL ADDRESS, OK!    "
;	DC.B "I SHOULD DO THE GREETINGS NOW, BUT I THINK I WILL "
;	DC.B "GIVE THEM A MISS, 'WAS' GREETS EVERYBODY WHO WRITES "
;	DC.B "TO HIM, WE THINK YOU SHOULD EARN A GREETING.   "
;	DC.B "      A MESSAGE TO EVERYBODY WHO WANTS THE COMPACTOR "
;	DC.B ", WRITE YOUR OWN, WE DID!!!!      OK, I WILL DO A "
