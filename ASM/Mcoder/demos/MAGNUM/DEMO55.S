	opt	o+,t-
MUSIX	equ	0		;1=pas de musique
LOGO	equ	0		;1=pas de logo
SPRITES	equ	0		;1=pas de sprites
CPU	equ	1		;1=pas de tps CPU
TAB	equ	0		;0=touche TAB valide
PRG	equ	0		;0=programme .prg
ESC	equ	1		;0=touche ESC valide
;
; OPTIMISATIONS ET BUGS :
;
; - revoir fontes
; - effets graphiques dans scrolling
; - ON PEUT AMELIORER LE SCROLLING !!!
;	1) EN AMELIORANT LE TRANSFERT DE 2 LONGS
;	2) EN UTILISANT A7 EN MODE UTILISATEUR
;		MOVE.L	USP,A0
;		MOVE.L	A0,ADECRAN
;		JMP	(SCROLL)
;		MOVE	#$300,SR
;		SCROLL
;		ILLEGAL		;POUR REVENIR AU PROGRAMME
;	PRG:	LEA	PILE\W,SP
;		MOVE.L	ADECRAN,A0
;		MOVE.L	A0,USP
;
; coordonn‚e Y du logo qui se d‚forme
;
ylogo	equ	200-35-14
;
; smooth scrolling horizontal
;
height	equ	16
nbcoul	equ	11+9
;
; color0,color11,color13,color14 et color15 disparaissent
;
nblig	equ	8*height
nbcar	equ	45
;
; adresses fixes !!!
; en partant du haut de la m‚moire
;
; voir PILE … la fin !!!
;
; ancien ordre :
; ramtop,ecran1,ecran0,scrollbase,baselogo,font,coordx,buffer
; nouvel ordre :
; ramtop,ecran1,ecran0,buffer,baselogo,font,coordx,scrollbase
;
ramtop		equ	$80000
ecran1		equ	$78300				;ramtop-$7d00 (32000)
ecran0		equ	$70600				;ecran1-$7d00
buffer		equ	ecran0-(168*nblig*8)
finlogo		equ	buffer
baselogo	equ	finlogo-(20*80*35)		;$437ac
finfont		equ	baselogo
font		equ	finfont-(nbcar*8*height*8)
fincoordx	equ	font
coordx		equ	fincoordx-(15*320*4)
finscroll	equ	coordx
scrollbase	equ	finscroll-$1f394		;$5126c
basemfp		equ	$80			;vecteurs MFP en $80.w

	OUTPUT	DEMO.TOS
;
; header de la demo
;
	OPT	P+
start
;
; CODE LE MESSAGE
;
	lea	DEBUTCODE+(mess1-DEBUT)(PC),a0
	moveq	#0,d0
code1	move.b	(a0)+,d0
	beq.s	codefin
	bpl.s	code2
	sub.b	#$94,d0		;skip Pattern ???
	cmp.b	#$fc-$94,d0
	bhs.s	code1
	addq	#1,a0
	bra.s	code1
code2
;	cmp.b	#$20,d0
;	blo.s	code1
;	cmp.b	#'Z',d0
;	bhi.s	code1
	move.b	tabcode-32(pc,d0.w),-1(a0)
	bra.s	code1

tabcode
	dc.b	0		;espace
	dc.b	38*2		;!
	dc.b	0		;"
	dc.b	0,0,0,0
	dc.b	41*2		;'
	dc.b	39*2,40*2	;()
	dc.b	0,0
	dc.b	45*2		;,
	dc.b	43*2		;-
	dc.b	44*2		;.
	dc.b	0
	dc.b	36*2,27*2	;01
	dc.b	28*2,29*2,30*2	;234
	dc.b	31*2,32*2	;56
	dc.b	33*2,34*2,35*2	;789
	dc.b	42*2		;:
	dc.b	45*2		;;
	dc.b	0,0,0
	dc.b	37*2		;?
	dc.b	0
	dc.b	1*2,2*2,3*2,4*2,5*2		;ABCDE
	dc.b	6*2,7*2,8*2,9*2,10*2		;FGHIJ
	dc.b	11*2,12*2,13*2,14*2,15*2	;KLMNO
	dc.b	16*2,17*2,18*2,19*2,20*2	;PQRST
	dc.b	21*2,22*2,23*2,24*2,25*2	;UVWXY
	dc.b	26*2		;Z

	even
codefin
	st.b	-(a0)		;$ff

	IFEQ	PRG
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#4,sp
	move	#$2700,sr

	moveq	#0,d0
	move.l	d0,$ffff8240.w		;tout gris
	move.l	d0,$ffff8244.w
	move.l	d0,$ffff8248.w
	move.l	d0,$ffff824c.w
	move.l	d0,$ffff8250.w
	move.l	d0,$ffff8254.w
	move.l	d0,$ffff8258.w
	move.l	d0,$ffff825c.w

	movem.l	trans(pc),d0-d7		;32 octets transf‚r‚s
	movem.l	d0-d7,$300.w		;en $300

	lea	DEBUT\w,a0
	LEA	codes(pc),A6
	move.l	start-$100+$18(pc),a5	;a5=adresse d‚but BSS !!
	jmp	$300.w
MONST
	opt	p-
	lea	$40000+DEBUT,a0
	opt	p+
	LEA	codes(pc),A6
	move.l	start-$100+$18(pc),a5	;a5=adresse d‚but BSS !!

trans	movem.l	(a6)+,d0-d7	;octets … transf‚rer en $300.w
	movem.l	d0-d7,(a0)
	lea	32(a0),a0
	cmp.l	a5,a6		;longueur : 22 octets !!
	blo.s	trans

	opt	p-
	jmp	startup		;jump en startup (autodestruction)
	opt	p+
codes
	ELSEIF
	INCLUDE COMP17.S
	ENDC
	OPT	P-
DEBUTCODE
;
	ORG	$430
DEBUT
;
; tables dispos‚es ici afin de gagner du temps ...
;
;
; TABLES DE MOUVEMENT
;
mvtdeb
	ifeq	SPRITES
	INCBIN	DELTA2.IMG		;TABLE DE WORDS !!!
	endc
mvtfin	equ	mvtdeb+106

tablog
	ifeq	LOGO
	INCBIN	DELTAX.IMG		;table de words !!!
	endc
tabfin


mess1
	DC.B	"YO ! BOYZ... WELCOME TO "
	DC.B	"THE "
	DC.B	" MAGNUM FORCE DEMO  "
	DC.B	$FD
	DC.B	" (THE FIRST ONE, IN FACT) "
	DC.B	"SO, GUY, WHAT ABOUT THIS SCROLL ? "
	DC.B	"YOU DON'T SEEM SATISFIED... "
	DC.B	"OKEY, LET'S ACTIVATE SOME THINGS : "
	DC.B	"HERE WE BRING YOU A FEW COLOURS... "

	DC.B	$82

	DC.B	"RIGHT NOW ? MAYBE A FEW STARS COULD IMPROVE IT... "
mess2
	DC.B	"AND WHAT ABOUT... SPRITES ? "
mess3
	DC.B	"COME ON, LET'S SWING... "
mess5
	DC.B	"BETTER NOW... COOL SCROLL, NO ? YEAH, IT'S THE BIGGEST ONE ON THE "
	DC.B	"FOUR PLANES... DON'T YOU BELIEVE US ? SO JUST HAVE A LOOK AT THIS... "

	DC.B	'ONE SCROLL '
	DC.B	$84
	DC.B	'TWO SCROLLS '
	DC.B	$86
	DC.B	'THREE SCROLLS '
	DC.B	$88
	DC.B	'FOUR SCROLLS '
	DC.B	$8A
	DC.B	'FIVE SCROLLS '
	DC.B	$8C
	DC.B	'SIX SCROLLS '
	DC.B	$8E
	DC.B	'SEVEN SCROLLS '
	DC.B	$90
	DC.B	'EIGHT SCROLLS !!! '

	DC.B	"CRAZY, ISN'T IT ? "
	DC.B	"AND OF COURSE IT HAS BEEN DONE BY THE "
	DC.B	$94,%01111111,'M'
;	DC.B	$94,%11111111,'M'
	DC.B	$90,'M'
	DC.B	$94,%01110000,'M'
	DC.B	$94,%00111000,'M'
	DC.B	$94,%00111000,'M'
	DC.B	$94,%01110000,'M'
;	DC.B	$94,%11111111,'M'
	DC.B	$90,'M'
	DC.B	$94,%01111111,'M'
	DC.B	'  '

	DC.B	$94,%00000011,'A'
	DC.B	$94,%00000111,'A'
	DC.B	$94,%00001110,'A'
	DC.B	$94,%00011110,'A'
	DC.B	$94,%00111010,'A'
	DC.B	$94,%01110010,'A'
;	DC.B	$94,%11111111,'A'
	DC.B	$90,'A'
	DC.B	$94,%01111111,'A'
	DC.B	'  '

	DC.B	$94,%00000111,'G'
	DC.B	$94,%00001111,'G'
	DC.B	$94,%00011111,'G'
	DC.B	$94,%00111011,'G'
	DC.B	$94,%01110011,'G'
	DC.B	$94,%11100011,'G'
	DC.B	$94,%11001111,'G'
	DC.B	$94,%10001111,'G'
	DC.B	'  '

	DC.B	$94,%01111111,'N'
;	DC.B	$94,%11111111,'N'
	DC.B	$90,'N'
	DC.B	$94,%01110000,'N'
	DC.B	$94,%00111000,'N'
	DC.B	$94,%00011100,'N'
	DC.B	$94,%00001110,'N'
;	DC.B	$94,%11111111,'N'
	DC.B	$90,'N'
;	DC.B	$94,%11111111,'N'
	DC.B	$90,'N'
	DC.B	'  '

	DC.B	$94,%00011110,'U'
	DC.B	$94,%00111111,'U'
	DC.B	$94,%01110011,'U'
	DC.B	$94,%11100011,'U'
	DC.B	$94,%11000011,'U'
	DC.B	$94,%00000011,'U'
;	DC.B	$94,%11111111,'U'
	DC.B	$90,'U'
	DC.B	$94,%11111110,'U'
	DC.B	'  '

	DC.B	$94,%01111111,'M'
;	DC.B	$94,%11111111,'M'
	DC.B	$90,'M'
	DC.B	$94,%01110000,'M'
	DC.B	$94,%00111000,'M'
	DC.B	$94,%00111000,'M'
	DC.B	$94,%01110000,'M'
;	DC.B	$94,%11111111,'M'
	DC.B	$90,'M'
	DC.B	$94,%01111111,'M'
	DC.B	'  '

	DC.B	'    '

	DC.B	$94,%11000000,'F'
	DC.B	$94,%11100000,'F'
	DC.B	$94,%11110000,'F'
	DC.B	$94,%10111000,'F'
	DC.B	$94,%10111100,'F'
	DC.B	$94,%10101110,'F'
	DC.B	$94,%10100111,'F'
	DC.B	$94,%10000011,'F'
	DC.B	'  '

	DC.B	$94,%00001110,'O'
	DC.B	$94,%00011111,'O'
	DC.B	$94,%00111011,'O'
	DC.B	$94,%01110011,'O'
	DC.B	$94,%11100011,'O'
	DC.B	$94,%11000011,'O'
;	DC.B	$94,%11111111,'O'
	DC.B	$90,'O'
	DC.B	$94,%01111110,'O'
	DC.B	'  '

	DC.B	$94,%01111111,'R'
;	DC.B	$94,%11111111,'R'
	DC.B	$90,'R'
	DC.B	$94,%11000100,'R'
	DC.B	$94,%01100100,'R'
	DC.B	$94,%00110100,'R'
	DC.B	$94,%00011110,'R'
	DC.B	$94,%00001111,'R'
	DC.B	$94,%00000101,'R'
	DC.B	'  '

	DC.B	$94,%00000111,'C'
	DC.B	$94,%00001111,'C'
	DC.B	$94,%00011111,'C'
	DC.B	$94,%00111011,'C'
	DC.B	$94,%01110011,'C'
	DC.B	$94,%11100011,'C'
	DC.B	$94,%11000011,'C'
	DC.B	$94,%10000011,'C'
	DC.B	'  '

	DC.B	$94,%00000111,'E'
	DC.B	$94,%00001111,'E'
	DC.B	$94,%00011111,'E'
	DC.B	$94,%00111011,'E'
	DC.B	$94,%01111011,'E'
	DC.B	$94,%11101011,'E'
	DC.B	$94,%11001011,'E'
	DC.B	$94,%10000011,'E'
	DC.B	$90,'  '

;	DC.B	$90

	DC.B	"BUT DON'T LEAVE NOW, COZ THERE'S MORE EFFECTS TO COME !!! "
	DC.B	"FOR EXAMPLE, TRY THE KEYS F1 TO F10, HELP AND UNDO "
	DC.B	"FOR DIFFERENT MUSIX, "
	DC.B	"AND 1 TO 9 TO SET UP THE VOLUME... "

	DC.B	"YOU REMEMBER WE'VE JUST SPOKEN ABOUT EFFECTS, SO HERE IS ONE MORE !!! "
mess4
	DC.B	"YEAHHH.... "
	DC.B	"MAGNUM FORCE IS PRESENTLY COMPOSED OF "
	DC.B	"    TERMINATOR X    "
	DC.B	$FE
	DC.B	" DESIGNER, "
	DC.B	"      TRASHER       "
	DC.B	$FE
	DC.B	" GRAPHIX HELP, "
	DC.B	"AND "
	DC.B	"    THE RESIDENT    "
	DC.B	$FE
	DC.B	" CODER... "
	DC.B	"WELL, AS IN ALL DEMOS YOU'VE SEEN SINCE NOW, THE TIME FOR THE GREETINGS "
	DC.B	"IS COMING. "
	dc.b	"FIRST, MEGA GREETZ TO : "
	dc.b	"     "
	dc.b	$96,%00101010
	DC.B	" E "
	DC.B	"ESW"
	DC.B	"QPE"
	DC.B	"UER"
	DC.B	"ICE"
	DC.B	"NIW"
	DC.B	"OAO"
	DC.B	"XLL"
	DC.B	" LF"
	DC.B	" Y "
	dc.b	$90
	dc.b	"     "
	DC.B	$FD

;	DC.B	"EQUINOX (ESPECIALLY WEREWOLF), "
	dc.b	"     "
	DC.B	"LES NULS"
	dc.b	" (ESPECIALLY LES "
;
; pour debuggage !!!
;
;mess1	dc.b	$90," "
	dc.b	$92,"JOYEUSES"
	dc.b	$90," "
	dc.b	$92," COPINES"
	dc.b	$90," "
	DC.B	"BLOOD ET SHIMROD, "
	dc.b	"AND TWILIGHTS OF GOD. "
	DC.B	$96,%10000001,"H "
	DC.B	$96,%01000010,"E "
	DC.B	$96,%00100100,", "
	DC.B	$96,%00011000,"  "
	DC.B	$96,%00011000,"ML"
	DC.B	$96,%00100100,"EE"
	DC.B	$96,%01000010," S"
	DC.B	$96,%10000001,"T "
	DC.B	$96,%10000001,"RF"
	DC.B	$96,%01000010,"AI"
	DC.B	$96,%00100100,"NL"
	DC.B	$96,%00011000,"SL"
	DC.B	$96,%00011000,"EC"
	DC.B	$96,%00100100,"SE"
	DC.B	$96,%01000010,",N"
	DC.B	$96,%10000001," D"
	DC.B	$96,%10000001,"VE"
	DC.B	$96,%01000010,"OE"
	DC.B	$96,%00100100,"SE"
	DC.B	$96,%00011000," E"
	DC.B	$96,%00011000,"NI"
	DC.B	$96,%00100100,"NN"
	DC.B	$96,%01000010,"NT"
	DC.B	$96,%10000001,"TR"
	DC.B	$96,%10000001," O"
	DC.B	$96,%10000001," S"
;
;	dc.b	"HE, LES FILLES, VOS INTROS "
;	dc.b	"    ME TRANSCENDEEEENNNT   "
;
	DC.B	$90," !!!), "
	dc.b	$94,%11100111
	dc.b	"AXE (C64), "
	dc.b	$94,%01100110
	dc.b	"LOOPING THE MEGA BUG "
	dc.b	$94,%10101010
	dc.b	"(J'PEUX T'FILER UNE "
	dc.b	$94,%01010101,"D"
	DC.B	$94,%10101010,"I"
	dc.b	$94,%01010101,"S"
	DC.B	$94,%10101010,"Q"
	dc.b	$94,%01010101,"U"
	DC.B	$94,%10101010,"E"
	dc.b	$94,%01010101,"T"
	DC.B	$94,%10101010,"T"
	dc.b	$94,%01010101,"E"
	dc.b	" POUR QU'TU M'COPIES...), "
	DC.B	$94,%11000011
	DC.B	"JOY STILL, "
	DC.B	$94,%00111100,"ST MAD "
	dc.b	$94,%11000000,"("
	dc.b	$94,%01100000,"A"
	dc.b	$94,%00110000,"C"
	dc.b	$94,%00011000,"I"
	dc.b	$94,%00001100,"I"
	dc.b	$94,%00000110,"I"
	dc.b	$94,%00000011,"I"
	dc.b	$94,%00000011,"I"
	dc.b	$94,%00000110,"I"
	dc.b	$94,%00001100,"I"
	dc.b	$94,%00011000,"I"
	dc.b	$94,%00110000,"D"
	dc.b	$94,%01100000," "
	dc.b	$94,%11000000,"!"
	dc.b	$94,%11000000," "
	dc.b	$94,%01100000,"Q"
	dc.b	$94,%00110000,"U"
	dc.b	$94,%00011000,"E"
	dc.b	$94,%00001100," "
	dc.b	$94,%00000110,"L"
	dc.b	$94,%00000011,"E"
	dc.b	$94,%00000011," "
	dc.b	$94,%00000110,"S"
	dc.b	$94,%00001100,"P"
	dc.b	$94,%00011000,"A"
	dc.b	$94,%00110000,"G"
	dc.b	$94,%01100000,"H"
	dc.b	$94,%11000000,"E"
	dc.b	$94,%11000000,"T"
	dc.b	$94,%01100000,"T"
	dc.b	$94,%00110000,"I"
	dc.b	$94,%00011000," "
	dc.b	$94,%00001100,"Q"
	dc.b	$94,%00000110,"U"
	dc.b	$94,%00000011,"I"
	dc.b	$94,%00000011," "
	dc.b	$94,%00000110,"P"
	dc.b	$94,%00001100,"E"
	dc.b	$94,%00011000,"N"
	dc.b	$94,%00110000,"D"
	dc.b	$94,%01100000," "
	dc.b	$94,%11000000,"A"
	dc.b	$94,%11000000," "
	dc.b	$94,%01100000,"L"
	dc.b	$94,%00110000,"A"
	dc.b	$94,%00011000," "
	dc.b	$94,%00001100,"B"
	dc.b	$94,%00000110,"O"
	dc.b	$94,%00000011,"U"
	dc.b	$94,%00000011,"C"
	dc.b	$94,%00000110,"H"
	dc.b	$94,%00001100,"E"
	dc.b	$94,%00011000," "
	dc.b	$94,%00110000,"D"
	dc.b	$94,%01100000,"U"
	dc.b	$94,%11000000," "
	dc.b	$94,%11000000,"M"
	dc.b	$94,%01100000,"E"
	dc.b	$94,%00110000,"C"
	dc.b	$94,%00011000," "
	dc.b	$94,%00001100,"A"
	dc.b	$94,%00000110,"U"
	dc.b	$94,%00000011,"X"
	dc.b	$94,%00000011," "
	dc.b	$94,%00000110,"G"
	dc.b	$94,%00001100,"R"
	dc.b	$94,%00011000,"O"
	dc.b	$94,%00110000,"S"
	dc.b	$94,%01100000,"S"
	dc.b	$94,%11000000,"E"
	dc.b	$94,%11000000,"S"
	dc.b	$94,%01100000," "
	dc.b	$94,%00110000,"L"
	dc.b	$94,%00011000,"U"
	dc.b	$94,%00001100,"N"
	dc.b	$94,%00000110,"E"
	dc.b	$94,%00000011,"T"
	dc.b	$94,%00000011,"T"
	dc.b	$94,%00000110,"E"
	dc.b	$94,%00001100,"S"
	dc.b	$94,%00011000," "
	dc.b	$94,%00110000,"C"
	dc.b	$94,%01100000,"A"
	dc.b	$94,%11000000,"R"
	dc.b	$94,%11000000,"R"
	dc.b	$94,%01100000,"E"
	dc.b	$94,%00110000,"E"
	dc.b	$94,%00011000,"S"
	dc.b	$94,%00001100," "
	dc.b	$94,%00000110,"D"
	dc.b	$94,%00000011,"E"
	dc.b	$94,%00000011,"S"
	dc.b	$94,%00000110," "
	dc.b	$94,%00001100,"S"
	dc.b	$94,%00011000,"A"
	dc.b	$94,%00110000,"T"
	dc.b	$94,%01100000,"E"
	dc.b	$94,%11000000,"L"
	dc.b	$94,%11000000,"L"
	dc.b	$94,%01100000,"I"
	dc.b	$94,%00110000,"T"
	dc.b	$94,%00011000,"E"
	dc.b	$94,%00001100,"S"
	dc.b	$94,%00000110," "
	dc.b	$94,%00000011,"S"
	dc.b	$94,%00000011,"O"
	dc.b	$94,%00000110,"I"
	dc.b	$94,%00001100,"T"
	dc.b	$94,%00011000," "
	dc.b	$94,%00110000,"A"
	dc.b	$94,%01100000,"V"
	dc.b	$94,%11000000,"E"
	dc.b	$94,%11000000,"C"
	dc.b	$94,%01100000," "
	dc.b	$94,%00110000,"T"
	dc.b	$94,%00011000,"O"
	dc.b	$94,%00001100,"I"
	dc.b	$94,%00000110,"."
	dc.b	$94,%00000011,"."
	dc.b	$94,%00000011,"."
	dc.b	$94,%00000110,")"

	DC.B	$90," "
;	DC.B	"(ACIIIIIIIID ! QUE LE SPAGHETTI QUI PEND A LA BOUCHE DU MEC AUX GR"
;	DC.B	"OSSES LUNETTES CARREES DES SATELLITES SOIT AVEC TOI...),"
	dc.b	" AND... AND"
	DC.B	"... OK, JUST LET'S GO FOR THE NORMAL HELLOS, WHICH ARE GOING TO TH"
	DC.B	"E FOLLOWING FOLKS : "
	dc.b	$94,%00011000
	dc.b	"TCB (THE BEST DEMO-WRITERS), "
	dc.b	$94,%00100100
	DC.B	"THE EXCEPTIONS, "
	dc.b	$94,%01000010
	dc.b	"THE REPLICANTS (GREAT CRACKERS, BUT YOUR LAST INTRO'"
	DC.B	"S NOT SO GOOD...), "
	dc.b	$94,%10000001
	dc.b	"S.T.C.S.(CE N'EST QU'UN AU REVOIR, MES FRERES...), "
	dc.b	$94,%01000010
	DC.B	"EVERYBODY FROM THE UNION (THE MOST POWERFUL DUDES ON ST), "
	dc.b	$94,%00100100
	dc.b	"ALL IN THE BLADE RUNNERS (TIME TO WAKE UP, GUYS !), "
	dc.b	$94,%00011000
	dc.b	"AND THAT'S ALL FOR THE"
	DC.B	" MOMENT. SO, WHAT IS MISSING ?     "
	dc.b	$90
	DC.B	"YEAH, THE FUCKING GREETINGS, SENT TO : "
	dc.b	$94,%00011000
	DC.B	"THE HACKER'S CLUB KING (TRY TO CHANGE THIS SCROLL, SUCKERS !), "
	dc.b	$94,%00111100
	DC.B	"ALL THE BAD CRACKERS (SORRY, WOLVERINE...), "
	dc.b	$94,%01111110
	DC.B	"ALL VIRUS-WRITERS, "
	dc.b	$90
	dc.b	"ALL TEXT-CHANGERS "
	dc.b	$94,%01111110
	dc.b	"AND ALL BOYS (AND GIRLS) "
	dc.b	$94,%00111100
	dc.b	"WHO HAVE A JOYSTICK INSTEAD OF THEIR HEAD "
	dc.b	$94,%00011000
	dc.b	"(SOME FREAKS WILL SURELY RECOGNIZE THEMSELVES...) "
	dc.b	$90
	DC.B	"THOSE GREETINGS SURE DOES LOOK SHORT, BUT IT ALLOWS US TO GO ON"
	DC.B	" WITH THE SCROLLTEXT OF THIS DEMO... ENJOY ! "

	DC.B	$FC

	DC.B	$90
	DC.B	"AND, NOW LET'S TALK THE CODER : "
	DC.B	"HELLO GUYS, I'M SURE YOU'RE SAYING THAT THIS DEMO "
	DC.B	"IS QUITE EASY TO CODE, BUT LET ME TELL YOU MORE ABOUT IT... "
	DC.B	"THIS SCROLL IS THE BIGGEST HORIZONTAL SMOOTH SCROLL "
	DC.B	"EVER MADE ON FOUR PLANES (IF YOU DON'T BELIEVE ME, "
	DC.B	"LOOK AT THE 88 COLOURS !!!) WITH BIG SPRITES, STARS, "
	DC.B	"A BIG DISTORTING LOGO AND TWELVE GREAT DAVID "
	DC.B	"WHITTAKER'S MUSIX (SPEEDBALL, STARRAY, "
	DC.B	"COSMIC PIRATE, ZOMBI, GENESIS, LEATHERNECK, "
	DC.B	"RAMPAGE, ENDURO RACER, ICE PALACE, GOLDRUNNER 2 "
	DC.B	"AND XENON !!!)"
	DC.B	$FC
	DC.B	$90,"SEE YOU SOON..."
	DC.B	$FC

mesfin	DC.B	0
	even
;
	ifeq	LOGO
vbl2
	move.l	#$04750777,$ffff8242.w
	clr.b	$fffffa1b.w
	addq.b	#1,timer2\w
yvb	move.b	#0,$fffffa21.w
yvbl	equ	yvb+3
	move	#hb1,(basemfp+$22).w
	move.b	#8,$fffffa1b.w
;	move.b	#1,$fffffa07.w
;	move.b	#1,$fffffa13.w
	rte
	endc
vbl
	move.l	#$00040104,$ffff8242.w
	move.l	#$02040304,$ffff8246.w
	move.l	#$04040405,$ffff824a.w
	move.l	#$05040505,$ffff824e.w
	move.l	#$06040605,$ffff8252.w
	move	#$0704,$ffff8258.w
	clr.b	$fffffa1b.w
	move.b	#16,$fffffa21.w
	move	#hbl1,(basemfp+$22).w
	move.b	#8,$fffffa1b.w
	move	#vblbis,$72.w
	rte
vblbis
	move.l	#$00040104,$ffff8242.w
	move.l	#$02040304,$ffff8246.w
	move.l	#$04040503,$ffff824a.w
	move.l	#$05040603,$ffff824e.w
	move.l	#$06040703,$ffff8252.w
	move	#$0704,$ffff8258.w
	clr.b	$fffffa1b.w
	move.b	#16,$fffffa21.w
	move	#hbm1,(basemfp+$22).w
	move.b	#8,$fffffa1b.w
	move	#vbl,$72.w
	rte
hbm1
; hbm4
	move.l	#$00470147,$ffff8242.w
	move.l	#$02470347,$ffff8246.w
	move.l	#$04470447,$ffff824a.w
	move.l	#$05470547,$ffff824e.w
	move.l	#$06470647,$ffff8252.w
	move	#$0747,$ffff8258.w
	move	#hbm2,(basemfp+$22).w
	bra.s	hbk1
hbl1
; hbl4
	move.l	#$00470147,$ffff8242.w
	move.l	#$02470347,$ffff8246.w
	move.l	#$04470546,$ffff824a.w
	move.l	#$05470637,$ffff824e.w
	move.l	#$06470737,$ffff8252.w
	move	#$0747,$ffff8258.w
	move	#hbl2,(basemfp+$22).w
hbk1
	clr.b	$fffffa1b.w
	move.b	#17,$fffffa21.w
	move.b	#8,$fffffa1b.w
setscreen
	move.b	#0,$ffff8203.w		;automodifiable
adecran	equ	setscreen+3
	addq.b	#1,timer\w
	rte
;
hbl4
; hbl1
	move.l	#$04040414,$ffff8242.w
	move.l	#$04240434,$ffff8246.w
	move.l	#$04440353,$ffff824a.w
	move.l	#$04540363,$ffff824e.w
	move.l	#$04640666,$ffff8252.w
	move	#$0474,$ffff8258.w
	move	#hbl5,(basemfp+$22).w
	rte
hbm4
; hbm1
	move.l	#$04040414,$ffff8242.w
	move.l	#$04240434,$ffff8246.w
	move.l	#$04440545,$ffff824a.w
	move.l	#$04540555,$ffff824e.w
	move.l	#$04640272,$ffff8252.w
	move	#$0474,$ffff8258.w
	move	#hbm5,(basemfp+$22).w
	rte
hbm3
; hbm2
	move.l	#$00440144,$ffff8242.w
	move.l	#$02440344,$ffff8246.w
	move.l	#$04430444,$ffff824a.w
	move.l	#$05430544,$ffff824e.w
	move.l	#$06430644,$ffff8252.w
	move	#$0744,$ffff8258.w
	move	#hbm4,(basemfp+$22).w
	rte
hbl3
; hbl2
	move.l	#$00440144,$ffff8242.w
	move.l	#$02440344,$ffff8246.w
	move.l	#$03450444,$ffff824a.w
	move.l	#$04450544,$ffff824e.w
	move.l	#$05450644,$ffff8252.w
	move	#$0744,$ffff8258.w
	move	#hbl4,(basemfp+$22).w
	rte
;
hbl2
; hbl3
	move.l	#$00070017,$ffff8242.w
	move.l	#$00270037,$ffff8246.w
	move.l	#$00470057,$ffff824a.w
	move.l	#$00570066,$ffff824e.w
	move.l	#$00670077,$ffff8252.w
	move	#$0077,$ffff8258.w
	move	#hbl3,(basemfp+$22).w
	rte
hbm2
; hbm3
	move.l	#$00070017,$ffff8242.w
	move.l	#$00270037,$ffff8246.w
	move.l	#$00470056,$ffff824a.w
	move.l	#$00570067,$ffff824e.w
	move.l	#$00670076,$ffff8252.w
	move	#$0077,$ffff8258.w
	move	#hbm3,(basemfp+$22).w
	rte
hbl6
; hbl5
	move.l	#$00770076,$ffff8242.w
	move.l	#$00760075,$ffff8246.w
	move.l	#$00750074,$ffff824a.w
	move.l	#$00740073,$ffff824e.w
	move.l	#$00720071,$ffff8252.w
	move	#$0070,$ffff8258.w
	move	#hbl7,(basemfp+$22).w
	rte
hbm6
; hbm5
	move.l	#$00770077,$ffff8242.w
	move.l	#$00760076,$ffff8246.w
	move.l	#$00750075,$ffff824a.w
	move.l	#$00740073,$ffff824e.w
	move.l	#$00720071,$ffff8252.w
	move	#$0070,$ffff8258.w
	move	#hbm7,(basemfp+$22).w
	rte
hbl5
; hbl6
	move.l	#$00740174,$ffff8242.w
	move.l	#$02740374,$ffff8246.w
	move.l	#$04740476,$ffff824a.w
	move.l	#$05740576,$ffff824e.w
	move.l	#$06740676,$ffff8252.w
	move	#$0774,$ffff8258.w
	move	#hbl6,(basemfp+$22).w
	rte
hbm5
; hbm6
	move.l	#$00740174,$ffff8242.w
	move.l	#$02740374,$ffff8246.w
	move.l	#$04740572,$ffff824a.w
	move.l	#$05740672,$ffff824e.w
	move.l	#$06740772,$ffff8252.w
	move	#$0774,$ffff8258.w
	move	#hbm6,(basemfp+$22).w
	rte
hbl7
; hbl7
	move.l	#$07700760,$ffff8242.w
	move.l	#$06600750,$ffff8246.w
	move.l	#$06500740,$ffff824a.w
	move.l	#$06400730,$ffff824e.w
	move.l	#$07200710,$ffff8252.w
	move	#$0700,$ffff8258.w
	clr.b	$fffffa1b.w
	move.b	#17*8-7*17,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move	#hbx,(basemfp+$22).w
	rte
hbm7
; hbm7
	move.l	#$07700760,$ffff8242.w
	move.l	#$07500750,$ffff8246.w
	move.l	#$07400740,$ffff824a.w
	move.l	#$07300730,$ffff824e.w
	move.l	#$07200710,$ffff8252.w
	move	#$0700,$ffff8258.w
	clr.b	$fffffa1b.w
	move.b	#17*8-7*17,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move	#hbx,(basemfp+$22).w
	rte
;
; couleurs du logo en bas
;
hbx	move.l	#$04750777,$ffff8242.w
	clr.b	$fffffa1b.w
	move.b	#ylogo+2-17*8-1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move	#hb1,(basemfp+$22).w
	rte
hb1	move	#$465,$ffff8246.w
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move	#hb2,(basemfp+$22).w
	move.b	#8,$fffffa1b.w
	rte
hb2	move	#$455,$ffff8242.w
	move	#hb3,(basemfp+$22).w
	rte
hb3	move	#$445,$ffff8246.w
	move	#hb4,(basemfp+$22).w
	rte
hb4	move	#$435,$ffff8242.w
	move	#hb5,(basemfp+$22).w
	rte
hb5	move	#$425,$ffff8246.w
	move	#hb6,(basemfp+$22).w
	rte
hb6	move	#$405,$ffff8242.w
	move	#hb7,(basemfp+$22).w
	rte
hb7	move	#$111,$ffff8246.w
	clr.b	$fffffa1b.w
	move.b	#2,$fffffa21.w
	move	#hb8,(basemfp+$22).w
	move.b	#8,$fffffa1b.w
	rte
hb8	move	#$222,$ffff8242.w
	move	#hb9,(basemfp+$22).w
	rte
hb9	move	#$333,$ffff8246.w
	move	#hb10,(basemfp+$22).w
	rte
hb10	move	#$444,$ffff8242.w
	move	#hb11,(basemfp+$22).w
	rte
hb11	move	#$555,$ffff8246.w
	move	#hb12,(basemfp+$22).w
	rte
hb12	move	#$666,$ffff8242.w
	move	#hb13,(basemfp+$22).w
	rte
hb13	move	#$777,$ffff8246.w
	move	#hb14,(basemfp+$22).w
	rte
hb14	move	#$666,$ffff8242.w
	move	#hb15,(basemfp+$22).w
	rte
hb15	move	#$555,$ffff8246.w
	move	#hb16,(basemfp+$22).w
	rte
hb16	move	#$444,$ffff8242.w
	move	#hb17,(basemfp+$22).w
	rte
hb17	move	#$333,$ffff8246.w
	move	#hb18,(basemfp+$22).w
	rte
hb18	move	#$222,$ffff8242.w
	move	#hb19,(basemfp+$22).w
	rte
hb19	move	#$111,$ffff8246.w
	clr.b	$fffffa1b.w
	rte

	ifeq	MUSIX
	include	MUSIX22.S
	EVEN
	endc
;
; gestion d'‚toiles en 2 plans
;
; toutes les 2 lignes
;
; a0=adresse ‚cran
; a1=liste des coordonn‚es X
; a2=liste des d‚placements
;
; 1er ‚l‚ment=d‚placement
; 2Šme ‚l‚ment=registre offset
; 3Šme ‚l‚ment=masque
star	macro
	lea	0(a5,\2.w),a6
	ifeq	\1-1
	or	\3,(a6)+
	or	\3,(a6)+
	or	\3,(a6)+
	or	\3,(a6)
	endc
	ifeq	\1-2
	or	\3,(a6)+
	not	\3
	and	\3,(a6)+
	not	\3
	or	\3,(a6)+
	or	\3,(a6)
	endc
	ifeq	\1-3
;	not	\3
	and	\3,(a6)+
	not	\3
	or	\3,(a6)+
	or	\3,(a6)+
	or	\3,(a6)
	endc
	endm

RESET
	MOVE	#$2700,SR
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	move.l	d0,a1
	move.l	d0,a4

	movem.l	d0-d5/a1/a4,$ffff8240.w	;tout noir

	lea	$fffffa21.w,a0
	move.b	d0,$fffffa1b.w
	move.b	#$f0,(a0)
	move.b	#8,$fffffa1b.w

verif2	move.b	(a0),d7
	move	#$267,d6
verif3	cmp.b	(a0),d7
	bne.s	verif2
	dbra	d6,verif3
	move.b	$ffff8001.w,d7		;memconf
;	and	#$f,d7			;4 bits significatifs
	reset
	move.b	d7,$ffff8001.w		;memconf
	move.b	#2,$ffff820a.w		;50 Hz
	move.b	d0,$ffff8260.w		;320*200

	move.l	#$0707C0C0,$ffff8800.w	;define ports A & B to output
	move.l	#$07078383,$ffff8200.w	;l'ecran est en $78300
	move.l	#$0E0E0707,$FFFF8800.W	;deselect drives

	lea	$fffffa01.w,a0
	movep.l	d0,0(a0)		;impossible autrement ???
	movep.l	d0,8(a0)		;(pas avec MOVEM.L)
	movep.l	d0,16(a0)

	move.b	#$20,$fffffa17.w	;define MFP vector

; vector=AEI (bit clear‚ automatiquement)
; basemfp=$80

	lea	$fffffc00.w,a2
	move.b	#%11,(a2)		;keyboard ACIA control
	move.b	#%10+$94,(a2)		;keyboard ACIA control
	moveq	#1,d6
	lea	$fffffc02.w,a3
;
; balance un reset au clavier
;
ikput1	btst	d6,(a2)			;keyboard ACIA control
	beq.s	ikput1
	move.b	#$80,(a3)		;balance un reset au clavier
ikput2	btst	d6,(a2)
	beq.s	ikput2
	move.b	d6,(a3)			;keyboard ACIA data
;
; perte de temps (plus de 300 ms !!!)
;  pour processeur clavier
;
	lea	ramtop,a0		;derriere l'ecran
	move	#((32000*2)+(168*8*nblig))/128-1,d7
zap
	movem.l	d0-d5/a1/a4,-(a0)	;efface les buffers et les ecrans !!
	movem.l	d0-d5/a1/a4,-(a0)
	movem.l	d0-d5/a1/a4,-(a0)
	movem.l	d0-d5/a1/a4,-(a0)
	dbra	d7,zap

	ifeq	CPU
	cmp.l	#buffer,a0
bug5	bne.s	bug5
	endc

	ifeq	LOGO
	move	#vbl2,$72.w		;vertical blank interrupt
	elseif
	move	#vbl,$72.w
	endc
;					;(niveau=4)
ikput3	btst	d6,(a2)
	beq.s	ikput3
	move.b	#$12,(a3)		;keyboard ACIA data
ikput4	btst	d6,(a2)
	beq.s	ikput4
	move.b	#$1A,(a3)		;keyboard ACIA data

; initialise les couleurs constantes
	move	#$0666,$ffff8256.w
	move	#$0446,$ffff825a.w
	move.l	#$05560336,$ffff825c.w	;couleurs des ‚toiles

; autoriser le timer B
	move.b	d6,$fffffa07.w
	move.b	d6,$fffffa13.w

	LEA	PILE\w,SP

	move.b	d1,spaces\w
	move.b	d1,bloque\w
	move.l	#ecran0,a0
	move.l	a0,usp
	move.b	#$06,adecran\w
	move.l	d1,mode\w		;efface mode\w et couleur\w

; initialise les coordonn‚es X du logo
; initialise les coordonn‚es Y des sprites
	move.l	#mess1*65536+lastcord2,message\w
;	move	#mess1,message\w
;	move	#lastcord2,ptrdef\w
	move.l	#mvtdeb*65536+mvtdeb,d0
	move.l	d0,lastcord1\w
	move.l	d0,lastcord2\w
	move.l	#mvtdeb*65536+tablog,coords\w
;	move	#tablog,deforme0\w
;	move	d0,coords\w

	move.l	#coordx,ptrstar\w

	ifeq	LOGO
	move	d1,lasty\w
	move.l	d1,lasty0\w	;ici d1=0,d2=0
tombe
	addq	#1,d1

	add	d1,d2
	cmp	#ylogo,d2
	bls.s	tombe2
	move	#ylogo,d2
	neg	d1
	beq.s	tombe2
	addq	#1,d1
tombe2
	movem	d1/d2,vy\w	;‚crit vy et y2 en meme temps !!!

	move	lasty\w,d0
	mulu	#160,d0
	move.l	USP,a6
	lea	0(a6,d0.w),a0
	moveq	#0,d1
	move	#35*20-1,d0
aff4	move.l	d1,(a0)+
	addq	#4,a0
	dbra	d0,aff4

	mulu	#160,d2		;d2=y2\w !!!
	add	d2,a6
	lea	baselogo+800,a0		;on rafraichit
	moveq	#35-1,d1
affl2	moveq	#20-1,d0
affl1	move.l	(a0)+,(a6)+
	addq	#4,a6
	dbra	d0,affl1
	lea	20*80-4*20(a0),a0
	dbra	d1,affl2

	move	y2\w,d0
	move.b	adecran\w,d1
	move.b	d1,$ffff8203.w
	eor.b	#$83^$06,adecran\w
	subq.b	#$06,d1
	bne.s	pax0

	move	d0,lasty1\w
	move	lasty0\w,lasty\w
	LEA	ecran1,A0
	bra.s	waitx0
pax0
	move	d0,lasty0\w
	move	lasty1\w,lasty\w
	LEA	ecran0,A0
waitx0
	move.l	a0,usp
	addq	#2-1,d0
	move.b	d0,yvbl\w

	MOVE	#$2300,SR		;revalide interruptions pour synchro
	ifeq	MUSIX
	bsr	playmus			;avant synchro
	endc
	ifeq	CPU
	move	#$777,$ffff8240.w	;blanc
	endc
waitx4	moveq	#0,d0
timer2	equ	waitx4+1
	beq.s	waitx4
	clr.b	timer2\w
	ifeq	CPU
	clr	$ffff8240.w
	endc

	movem	vy\w,d1/d2	;lit vy et y2 en meme temps
	cmp	#ylogo,d2
	bne	tombe
	tst	d1
	bne	tombe
	move	#vbl,$72.w
	elseif
	move	#$2300,sr
	endc
;
; ici :
;	d1 bits 31 … 16=compteur\w
;	d1 bits 15 …  0=decale\w
;	d1=0
;
bcl
	move	d1,compteur\w
	swap	d1
bcl2
	move	d1,decale\w
bloc1
	lea	pivot2(PC),a0		;1) transfere le buffer
	move.l	ofbuf-pivot2(a0,d1.w),a5
	move.l	a5,a4
	swap	d1
	add	buffer1-pivot2(a0,d1.w),a5
	add	d1,d1
	move.l	table-pivot2(a0,d1.w),a0
	move.l	usp,a6
	jsr	(a0)

	IFEQ	CPU
	MOVE	#$777,$FFFF8240.W
	ENDC
;
; initialise les caractŠres … afficher
;
	moveq	#0,d7		;d7=code du caractŠre
spac	moveq	#0,d0
spaces	equ	spac+1
	bne.s	asci2
	move	message\w,a3
okboy
	move.b	(a3)+,d7
	bpl.s	asci2
	cmp.b	#$fc,d7
	blo.s	ascii
	not.b	d7			;$ff ???
	beq.s	asci2
	subq.b	#3,d7
	beq.s	setspc
	move.b	blocad+3-1(pc,d7.w),bloque\w
	bra.s	nopat
blocad	dc.b	200,50
setspc
	move.b	#80,spaces\w
	move	d7,mode\w		;d7=0 !!!
	move	a3,message\w
	bra.s	asci2
ascii
	add.b	d7,d7
	move	d7,mode\w
	cmp.b	#$14*2,d7
	blo.s	nopat
	move.b	(a3)+,pattern\w
nopat
	move	a3,message\w
	move.b	(a3)+,d7
asci2
; a3=message\w
; d7=(a3)+.B
	bsr	refresh
;
; dispatch
;
;stars
	ifeq	CPU
	move	#$070,$ffff8240.w	;vert
	endc

	move.l	usp,a5		;constant pendant 500 lignes !!!!

	cmp	#mess2,message\w
	blo	nostar
;	move.l	ptrstar\w,a4
starf	lea	0.L,a4			;automodifiable !!!
ptrstar	equ	starf+2
;
; 1er octet=couleur et vitesse
; 2eme octet=coordonn‚e Y
;
	movem	(a4)+,d0-a3
	star	3,d6,d0		;1
	star	3,d7,d1		;2
	star	2,a0,d2		;3
	star	2,a1,d3		;4
	star	2,a2,d4		;5
	star	3,a3,d5		;6
	movem	(a4)+,d0-a3
	star	1,d6,d0		;7
	star	1,d7,d1		;8
	star	3,a0,d2		;9
	star	1,a1,d3		;10
	star	2,a2,d4		;11
	star	2,a3,d5		;12
	movem	(a4)+,d0-d5
	star	3,d3,d0		;13
	star	3,d4,d1		;14
	star	1,d5,d2		;15
	cmp.l	#fincoordx,a4
	blo.s	settar
	lea	coordx,a4
settar	move.l	a4,ptrstar\w
nostar
;
; sprite
;
	ifeq	SPRITES
	ifeq	CPU
	move	#$007,$ffff8240.w
	endc
	INCLUDE	EXTRA.S
	endc
;
; affichage du logo
;
;	pendant la synchro pour gagner un peu de temps...
;afflogo
	ifeq	LOGO

	ifeq	CPU
	move	#$770,$ffff8240.w
	endc

affline	macro
	move	(a3)+,d0
	cmp	(a6)+,d0
;	CMPM	(A6)+,(A3)+
	beq.s	\@			;tester ici si rafraichissement

	lea	baselogo+z,a0		;on rafraichit
	add	d0,a0
;	ADD	-2(A3),A0
	movem.l	(a0)+,d0-d7/a1-a2
	move.l	d0,y(a5)
	move.l	d1,y+8(a5)
	move.l	d2,y+16(a5)
	move.l	d3,y+24(a5)
	move.l	d4,y+32(a5)
	move.l	d5,y+40(a5)
	move.l	d6,y+48(a5)
	move.l	d7,y+56(a5)
	move.l	a1,y+64(a5)
	move.l	a2,y+72(a5)
	movem.l	(a0),d0-d7/a1-a2
	move.l	d0,y+80(a5)
	move.l	d1,y+88(a5)
	move.l	d2,y+96(a5)
	move.l	d3,y+104(a5)
	move.l	d4,y+112(a5)
	move.l	d5,y+120(a5)
	move.l	d6,y+128(a5)
	move.l	d7,y+136(a5)
	move.l	a1,y+144(a5)
	move.l	a2,y+152(a5)
\@					;si non
	endm

	move	ptrdef\w,a6		;ici a5=adecran\w
	move	2(a6),a6
	move	deforme0\w,a3

y	set	ylogo*160
z	set	0
	rept	35
	affline
y	set	y+160
z	set	z+20*80
	endr
nologo
	endc

	ifeq	CPU
	move	#$700,$ffff8240.w	;rouge
	endc

	cmp.b	#$06,adecran\w
	bne.s	pae0

;	move.b	#$83,adecran\w		;ecran1
	move.l	coords\w,lastcord2\w
;	move	deforme0\w,deforme2\w
	subq	#lastcord2-lastcord1,ptrdef\w
;	move	#lastcord1,ptrdef\w
	lea	$78300,a0
	bra.s	wait0
pae0
;	move.b	#$06,adecran\w		;ecran0
	move.l	coords\w,lastcord1\w
;	move	deforme0\w,deforme1\w
	addq	#lastcord2-lastcord1,ptrdef\w
;	move	#lastcord2,ptrdef\w
	lea	$70600,a0
wait0
	move.l	a0,usp
	move	message\w,a0
	cmp	#mess5,a0
	blo.s	notfin

	addq	#2,coords\w
	cmp	#mvtfin-22,coords\w
	blo.s	notfin
	move	#mvtdeb+24,coords\w
notfin
	cmp	#mess4,a0
	blo.s	pamov
	cmp	#mesfin,a0
	blo.s	pajh
	cmp	#tablog,deforme0\w
	beq.s	pamov
pajh
	addq	#2,deforme0\w
	cmp	#tabfin-70,deforme0\w
	blo.s	pamov
	move	#tablog,deforme0\w
pamov
	ifeq	MUSIX
	bsr	playmus			;avant synchro
	endc
	ifeq	CPU
	move	#$777,$ffff8240.w	;blanc
	endc

	move.l	compteur\w,d1		;avant synchro (gain de cycles)
	addq	#2*2,d1

	ifeq	ESC
	cmp.b	#$01,$fffffc02.w
	bne.s	paesc
	jmp	(a7)			;reset cold
paesc
	endc

	ifeq	TAB
	cmp.b	#$0F,$fffffc02.w
	seq	d0
	ext	d0
	move	d0,$ffff8240.w
	endc

wait4	moveq	#0,d0			;automodify
timer	equ	wait4+1
	beq.s	wait4
	clr.b	timer\w
	eor.b	#$83^$06,adecran\w

	ifeq	CPU&TAB
	clr	$ffff8240.w		;noir
	endc
blocq	moveq	#0,d0
bloque	equ	blocq+1
	beq.s	pabloc
	subq.b	#1,bloque\w
	beq.s	pabloc
	cmp	#16*2,d1
	blo	bloc1
	clr	d1
	bra	bloc1
pabloc
	cmp	#16*2,d1
	blo	bcl2

	clr	d1

	move	mode\w,d0
	jsr	chmode(pc,d0.w)

	swap	d1
	addq	#2,d1
	cmp	#21*2,d1
	blo	bcl
	moveq	#0,d1
	bra	bcl
;
; ATTENTION :
;
; les routines suivantes ne doivent pas utiliser d1 !!!!
;
; ici d1.w=0
;
chmode	bra.w	chmode0
	bra.w	chmode1
	bra.w	chmode2
	bra.w	chmode3
	bra.w	chmode4
	bra.w	chmode5
	bra.w	chmode6
	bra.w	chmode7
	bra.w	chmode8
	bra.w	chmode9
	bra.w	chmode10
	bra.w	chmode11

encorspc
	subq.b	#1,spaces\w
	rts
chmode0
	tst.b	spaces\w
	bne.s	encorspc
	cmp	#mesfin,message\w
	bhs.s	pach0
	addq	#1,message\w
retc0	rts
pach0	cmp	#tablog,deforme0\w
	bne.s	retc0
	move	#mess1,message\w
	clr.l	mode\w			;efface mode\w et couleur\w
;	move	#tablog,deforme0\w
;	move	#mvtdeb,coords\w
	move.l	#mvtdeb*65536+tablog,coords\w
	rts
chmode1
chmode2
chmode3
chmode4
chmode5
chmode6
chmode7
chmode8
chmode10
	addq	#1,message\w
chgcol
	move	couleur\w,d0
	addq	#2,d0
	cmp	#nbcoul*2,d0
	bhs.s	okcol0
	move	d0,couleur\w
	rts
okcol0	move	d1,couleur\w
	rts
chmode9
	addq	#8,message\w
	bra.s	chgcol
chmode11

setpat	moveq	#0,d7
pattern	equ	setpat+1
	moveq	#0,d0
	add.b	d7,d7		;compte les bits … 1 de D7
cont	addx.b	d1,d0
	add.b	d7,d7
	bne.s	cont
	addx.b	d1,d0
	add	d0,message\w
	bra.s	chgcol

color8
	addq	#6,a1
	addq	#6,a2
	bra.s	color01
color4
	addq	#4,a1
	addq	#4,a2
	bra.s	color01
color2
	addq	#2,a1
	addq	#2,a2
color01
	lea	color1\w,a5
color1
	movem.l	(a0)+,d0-d7
	or	d0,(a2)
	or	d1,(a1)
	or	d2,168(a2)
	or	d3,168(a1)
	or	d4,168*2(a2)
	or	d5,168*2(a1)
	or	d6,168*3(a2)
	or	d7,168*3(a1)
	movem.l	(a0)+,d0-d7
	or	d0,168*4(a2)
	or	d1,168*4(a1)
	or	d2,168*5(a2)
	or	d3,168*5(a1)
	or	d4,168*6(a2)
	or	d5,168*6(a1)
	or	d6,168*7(a2)
	or	d7,168*7(a1)
	movem.l	(a0)+,d0-d7
	or	d0,168*8(a2)
	or	d1,168*8(a1)
	or	d2,168*9(a2)
	or	d3,168*9(a1)
	or	d4,168*10(a2)
	or	d5,168*10(a1)
	or	d6,168*11(a2)
	or	d7,168*11(a1)
	movem.l	(a0),d0-d7
	or	d0,168*12(a2)
	or	d1,168*12(a1)
	or	d2,168*13(a2)
	or	d3,168*13(a1)
	or	d4,168*14(a2)
	or	d5,168*14(a1)
	or	d6,168*15(a2)
	or	d7,168*15(a1)
	rts

color12
	addq	#4,a1
	addq	#4,a2
	bra.s	color03
color6
	addq	#2,a1
	addq	#2,a2
color03
	lea	color3\w,a5
color3
	movem.l	(a0)+,d0-d7
	or.l	d0,(a2)
	or.l	d1,(a1)
	or.l	d2,168(a2)
	or.l	d3,168(a1)
	or.l	d4,168*2(a2)
	or.l	d5,168*2(a1)
	or.l	d6,168*3(a2)
	or.l	d7,168*3(a1)
	movem.l	(a0)+,d0-d7
	or.l	d0,168*4(a2)
	or.l	d1,168*4(a1)
	or.l	d2,168*5(a2)
	or.l	d3,168*5(a1)
	or.l	d4,168*6(a2)
	or.l	d5,168*6(a1)
	or.l	d6,168*7(a2)
	or.l	d7,168*7(a1)
	movem.l	(a0)+,d0-d7
	or.l	d0,168*8(a2)
	or.l	d1,168*8(a1)
	or.l	d2,168*9(a2)
	or.l	d3,168*9(a1)
	or.l	d4,168*10(a2)
	or.l	d5,168*10(a1)
	or.l	d6,168*11(a2)
	or.l	d7,168*11(a1)
	movem.l	(a0),d0-d7
	or.l	d0,168*12(a2)
	or.l	d1,168*12(a1)
	or.l	d2,168*13(a2)
	or.l	d3,168*13(a1)
	or.l	d4,168*14(a2)
	or.l	d5,168*14(a1)
	or.l	d6,168*15(a2)
	or.l	d7,168*15(a1)
	rts

color10
	lea	color5\w,a5
	addq	#2,a1
	addq	#2,a2
color5
	movem.l	(a0)+,d0-d7
	or	d0,(a2)
	or	d0,4(a2)
	or	d1,(a1)
	or	d1,4(a1)
	or	d2,168*1(a2)
	or	d2,168*1+4(a2)
	or	d3,168*1(a1)
	or	d3,168*1+4(a1)
	or	d4,168*2(a2)
	or	d4,168*2+4(a2)
	or	d5,168*2(a1)
	or	d5,168*2+4(a1)
	or	d6,168*3(a2)
	or	d6,168*3+4(a2)
	or	d7,168*3(a1)
	or	d7,168*3+4(a1)
	movem.l	(a0)+,d0-d7
	or	d0,168*4(a2)
	or	d0,168*4+4(a2)
	or	d1,168*4(a1)
	or	d1,168*4+4(a1)
	or	d2,168*5(a2)
	or	d2,168*5+4(a2)
	or	d3,168*5(a1)
	or	d3,168*5+4(a1)
	or	d4,168*6(a2)
	or	d4,168*6+4(a2)
	or	d5,168*6(a1)
	or	d5,168*6+4(a1)
	or	d6,168*7(a2)
	or	d6,168*7+4(a2)
	or	d7,168*7(a1)
	or	d7,168*7+4(a1)
	movem.l	(a0)+,d0-d7
	or	d0,168*8(a2)
	or	d0,168*8+4(a2)
	or	d1,168*8(a1)
	or	d1,168*8+4(a1)
	or	d2,168*9(a2)
	or	d2,168*9+4(a2)
	or	d3,168*9(a1)
	or	d3,168*9+4(a1)
	or	d4,168*10(a2)
	or	d4,168*10+4(a2)
	or	d5,168*10(a1)
	or	d5,168*10+4(a1)
	or	d6,168*11(a2)
	or	d6,168*11+4(a2)
	or	d7,168*11(a1)
	or	d7,168*11+4(a1)
	movem.l	(a0),d0-d7
	or	d0,168*12(a2)
	or	d0,168*12+4(a2)
	or	d1,168*12(a1)
	or	d1,168*12+4(a1)
	or	d2,168*13(a2)
	or	d2,168*13+4(a2)
	or	d3,168*13(a1)
	or	d3,168*13+4(a1)
	or	d4,168*14(a2)
	or	d4,168*14+4(a2)
	or	d5,168*14(a1)
	or	d5,168*14+4(a1)
	or	d6,168*15(a2)
	or	d6,168*15+4(a2)
	or	d7,168*15(a1)
	or	d7,168*15+4(a1)
	rts
color7
	movem.l	(a0)+,d0-d7
	or.l	d0,(a2)
	or	d0,4(a2)
	or.l	d1,(a1)
	or	d1,4(a1)
	or.l	d2,168(a2)
	or	d2,168+4(a2)
	or.l	d3,168(a1)
	or	d3,168+4(a1)
	or.l	d4,168*2(a2)
	or	d4,168*2+4(a2)
	or.l	d5,168*2(a1)
	or	d5,168*2+4(a1)
	or.l	d6,168*3(a2)
	or	d6,168*3+4(a2)
	or.l	d7,168*3(a1)
	or	d7,168*3+4(a1)
	movem.l	(a0)+,d0-d7
	or.l	d0,168*4(a2)
	or	d0,168*4+4(a2)
	or.l	d1,168*4(a1)
	or	d1,168*4+4(a1)
	or.l	d2,168*5(a2)
	or	d2,168*5+4(a2)
	or.l	d3,168*5(a1)
	or	d3,168*5+4(a1)
	or.l	d4,168*6(a2)
	or	d4,168*6+4(a2)
	or.l	d5,168*6(a1)
	or	d5,168*6+4(a1)
	or.l	d6,168*7(a2)
	or	d6,168*7+4(a2)
	or.l	d7,168*7(a1)
	or	d7,168*7+4(a1)
	movem.l	(a0)+,d0-d7
	or.l	d0,168*8(a2)
	or	d0,168*8+4(a2)
	or.l	d1,168*8(a1)
	or	d1,168*8+4(a1)
	or.l	d2,168*9(a2)
	or	d2,168*9+4(a2)
	or.l	d3,168*9(a1)
	or	d3,168*9+4(a1)
	or.l	d4,168*10(a2)
	or	d4,168*10+4(a2)
	or.l	d5,168*10(a1)
	or	d5,168*10+4(a1)
	or.l	d6,168*11(a2)
	or	d6,168*11+4(a2)
	or.l	d7,168*11(a1)
	or	d7,168*11+4(a1)
	movem.l	(a0),d0-d7
	or.l	d0,168*12(a2)
	or	d0,168*12+4(a2)
	or.l	d1,168*12(a1)
	or	d1,168*12+4(a1)
	or.l	d2,168*13(a2)
	or	d2,168*13+4(a2)
	or.l	d3,168*13(a1)
	or	d3,168*13+4(a1)
	or.l	d4,168*14(a2)
	or	d4,168*14+4(a2)
	or.l	d5,168*14(a1)
	or	d5,168*14+4(a1)
	or.l	d6,168*15(a2)
	or	d6,168*15+4(a2)
	or.l	d7,168*15(a1)
	or	d7,168*15+4(a1)
	rts

color9
	movem.l	(a0)+,d0-d7
	or	d0,(a2)
	or	d0,6(a2)
	or	d1,(a1)
	or	d1,6(a1)
	or	d2,168(a2)
	or	d2,168+6(a2)
	or	d3,168(a1)
	or	d3,168+6(a1)
	or	d4,168*2(a2)
	or	d4,168*2+6(a2)
	or	d5,168*2(a1)
	or	d5,168*2+6(a1)
	or	d6,168*3(a2)
	or	d6,168*3+6(a2)
	or	d7,168*3(a1)
	or	d7,168*3+6(a1)
	movem.l	(a0)+,d0-d7
	or	d0,168*4(a2)
	or	d0,168*4+6(a2)
	or	d1,168*4(a1)
	or	d1,168*4+6(a1)
	or	d2,168*5(a2)
	or	d2,168*5+6(a2)
	or	d3,168*5(a1)
	or	d3,168*5+6(a1)
	or	d4,168*6(a2)
	or	d4,168*6+6(a2)
	or	d5,168*6(a1)
	or	d5,168*6+6(a1)
	or	d6,168*7(a2)
	or	d6,168*7+6(a2)
	or	d7,168*7(a1)
	or	d7,168*7+6(a1)
	movem.l	(a0)+,d0-d7
	or	d0,168*8(a2)
	or	d0,168*8+6(a2)
	or	d1,168*8(a1)
	or	d1,168*8+6(a1)
	or	d2,168*9(a2)
	or	d2,168*9+6(a2)
	or	d3,168*9(a1)
	or	d3,168*9+6(a1)
	or	d4,168*10(a2)
	or	d4,168*10+6(a2)
	or	d5,168*10(a1)
	or	d5,168*10+6(a1)
	or	d6,168*11(a2)
	or	d6,168*11+6(a2)
	or	d7,168*11(a1)
	or	d7,168*11+6(a1)
	movem.l	(a0),d0-d7
	or	d0,168*12(a2)
	or	d0,168*12+6(a2)
	or	d1,168*12(a1)
	or	d1,168*12+6(a1)
	or	d2,168*13(a2)
	or	d2,168*13+6(a2)
	or	d3,168*13(a1)
	or	d3,168*13+6(a1)
	or	d4,168*14(a2)
	or	d4,168*14+6(a2)
	or	d5,168*14(a1)
	or	d5,168*14+6(a1)
	or	d6,168*15(a2)
	or	d6,168*15+6(a2)
	or	d7,168*15(a1)
	or	d7,168*15+6(a1)
	rts

table
	ds.l	21
pivot2
ofbuf
	dc.l	0*168*nblig+buffer
	dc.l	1*168*nblig+buffer
	dc.l	2*168*nblig+buffer
	dc.l	3*168*nblig+buffer
	dc.l	4*168*nblig+buffer
	dc.l	5*168*nblig+buffer
	dc.l	6*168*nblig+buffer
	dc.l	7*168*nblig+buffer

fonte
	dc.l	nbcar*0*height*8+font,nbcar*1*height*8+font
	dc.l	nbcar*2*height*8+font,nbcar*3*height*8+font
	dc.l	nbcar*4*height*8+font,nbcar*5*height*8+font
	dc.l	nbcar*6*height*8+font,nbcar*7*height*8+font

pivot
; pointeurs pour refresh
buffer3
; pointeurs sur cote gauche
	dc.w	0
buffer4
buffer1
; pointeurs sur cote droit
	dc.w	8
	dc.w	16
	dc.w	24
	dc.w	32
	dc.w	40
	dc.w	48
	dc.w	56
	dc.w	64
	dc.w	72
	dc.w	80
	dc.w	88
	dc.w	96
	dc.w	104
	dc.w	112
	dc.w	120
	dc.w	128
	dc.w	136
	dc.w	144
	dc.w	152
	dc.w	160
	dc.w	0
masque
	DC.L	$00000000,$00030003,$000F000F,$003F003F
	DC.L	$00FF00FF,$03FF03FF,$0FFF0FFF,$3FFF3FFF

colors				;coefficients d'affichage
;	dc.w	color1		;2
;	dc.w	color7		;5
;	dc.w	color2		;2
;	dc.w	color3		;3
;	dc.w	color5		;4
;	dc.w	color4		;2
;	dc.w	color9		;4
;	dc.w	color6		;3
;	dc.w	color8		;2
;	dc.w	color10		;4
;	dc.w	color12		;3
	dc.w	color1,color2,color3,color4
	dc.w	color5,color6,color7,color8
	dc.w	color9,color10,color12
	dc.w	color10,color9,color8,color7
	dc.w	color6,color5,color4,color3
	dc.w	color2
ofbuf2
	dc.l	0*168*nblig+buffer+4
	dc.l	1*168*nblig+buffer+4
	dc.l	2*168*nblig+buffer+4
	dc.l	3*168*nblig+buffer+4
	dc.l	4*168*nblig+buffer+4
	dc.l	5*168*nblig+buffer+4
	dc.l	6*168*nblig+buffer+4
	dc.l	7*168*nblig+buffer+4

refresh
;
; a3 contient message\w
; d7 contient le premier code ascii a afficher
; rafraichissement en fonction du caractŠre et decale
;
	lea	pivot(PC),a6

	movem.l	mode\w,d0/d1
;	move.l	mode\w,d0		;d0.w=couleur\w
;	move.l	compteur\w,d1		;d1.w=decale\w

	move.l	ofbuf2-pivot(a6,d1.w),a1
	move.l	fonte-pivot(a6,d1.w),a4	;a4=debut fonte
;
; masque pour effacement de la colonne concernee
;
	move.l	masque-pivot(a6,d1.w),d4
	move.l	d4,d5
	not.l	d5

	move	colors-pivot(a6,d0.w),a5	;a5=routine affichage

	swap	d1			;d1.w=compteur\w
	move.l	a1,a2
	add	d1,a6				;8 cycles
	add	(a6)+,a1			;12 cycles(buffer3)
	add	(a6),a2				;12 cycles(buffer4)

;	add	buffer3-pivot(a6,d1.w),a1	;18 cycles
;	add	buffer4-pivot(a6,d1.w),a2	;18 cycles

	swap	d0			;d0.w=mode\w

	and.l	d4,(a2)
	and.l	d4,-(a2)
;	and.l	d4,4(a2)
	and.l	d5,(a1)
	and.l	d5,-(a1)
;	and.l	d5,4(a1)

x	set	168
	rept	height*8-1
	and.l	d4,x(a2)
	and.l	d4,x+4(a2)
	and.l	d5,x(a1)
	and.l	d5,x+4(a1)
x	set	x+168
	endr

	lea	(caractere-2)\w,a6

	tst	d7			;d7=caractere a afficher
	jmp	modes(pc,d0.w)

modes
	bra.w	mode0
	bra.w	mode1
	bra.w	mode2
	bra.w	mode3
	bra.w	mode4
	bra.w	mode5
	bra.w	mode6
	bra.w	mode7
	bra.w	mode8
	bra.w	mode9
	bra.w	mode10
	bra.w	mode11

iny	macro
	lea	168*height(a1),a1
	lea	168*height(a2),a2
	endm
gosub	macro
	ext	d7
	move.l	a4,a0
	add	(a6,d7.w),a0
	jsr	(a5)
	endm
goto	macro
	ext	d7
	move.l	a4,a0
	add	(a6,d7.w),a0
	jmp	(a5)
	endm

mode0
mode1
	beq.s	space
	move.l	a4,a0
	add	(a6,d7.w),a0
	jmp	(a5)
mode2
	beq.s	sp2
	add	(a6,d7.w),a4
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jmp	(a5)
mode3
	beq.s	sp2
	add	(a6,d7.w),a4
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jmp	(a5)
mode4
	beq.s	sp2
	add	(a6,d7.w),a4
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jmp	(a5)
space
sp2	rts
mode5
	beq.s	sp2
	add	(a6,d7.w),a4
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jmp	(a5)

mode6
	beq.s	sp2
	add	(a6,d7.w),a4
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jmp	(a5)

mode7
	beq.s	sp4
	add	(a6,d7.w),a4
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jmp	(a5)

sp4	rts
mode8
	beq.s	sp4
	add	(a6,d7.w),a4
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jsr	(a5)
	iny
	move.l	a4,a0
	jmp	(a5)

mode9
	beq.s	noj1
	gosub
noj1	iny
	move.b	(a3)+,d7
	beq.s	noj2
	gosub
noj2	iny
	move.b	(a3)+,d7
	beq.s	noj3
	gosub
noj3	iny
	move.b	(a3)+,d7
	beq.s	noj4
	gosub
noj4	iny
	move.b	(a3)+,d7
	beq.s	noj5
	gosub
noj5	iny
	move.b	(a3)+,d7
	beq.s	noj6
	gosub
noj6	iny
	move.b	(a3)+,d7
	beq.s	noj7
	gosub
noj7	iny
	move.b	(a3),d7
	beq.s	sp3
	goto
sp3	rts

mode10
	beq.s	sp3
	add	(a6,d7.w),a4

	tst.b	pattern\w
	bpl.s	md1
	move.l	a4,a0
	jsr	(a5)
md1	iny
	btst	#6,pattern\w
	beq.s	md2
	move.l	a4,a0
	jsr	(a5)
md2	iny
	btst	#5,pattern\w
	beq.s	md3
	move.l	a4,a0
	jsr	(a5)
md3	iny
	btst	#4,pattern\w
	beq.s	md4
	move.l	a4,a0
	jsr	(a5)
md4	iny
	btst	#3,pattern\w
	beq.s	md5
	move.l	a4,a0
	jsr	(a5)
md5	iny
	btst	#2,pattern\w
	beq.s	md6
	move.l	a4,a0
	jsr	(a5)
md6	iny
	btst	#1,pattern\w
	beq.s	md7
	move.l	a4,a0
	jsr	(a5)
md7	iny
	btst	#0,pattern\w
	beq.s	md8
	move.l	a4,a0
	jmp	(a5)
md8	rts

mode11
	subq	#1,a3
	tst.b	pattern\w
	bpl.s	td1
	move.b	(a3)+,d7
	beq.s	td1
	gosub
td1	iny
	btst	#6,pattern\w
	beq.s	td2
	move.b	(a3)+,d7
	beq.s	td2
	gosub
td2	iny
	btst	#5,pattern\w
	beq.s	td3
	move.b	(a3)+,d7
	beq.s	td3
	gosub
td3	iny
	btst	#4,pattern\w
	beq.s	td4
	move.b	(a3)+,d7
	beq.s	td4
	gosub
td4	iny
	btst	#3,pattern\w
	beq.s	td5
	move.b	(a3)+,d7
	beq.s	td5
	gosub
td5	iny
	btst	#2,pattern\w
	beq.s	td6
	move.b	(a3)+,d7
	beq.s	td6
	gosub
td6	iny
	btst	#1,pattern\w
	beq.s	td7
	move.b	(a3)+,d7
	beq.s	td7
	gosub
td7	iny
	btst	#0,pattern\w
	beq.s	td8
	move.b	(a3),d7
	beq.s	td8
	goto
td8	rts

gencode
;
; g‚n‚rateur de scrolling en MOVEM.L
;
; Version 1.2 (hyperoptimis‚)
;
; g‚nŠre le scrolling qui se termine en $70600
;
nblig2	equ	135

ld7	equr	d7	;ok
ld6	equr	d6	;ok
ld4	equr	d4	;ok
ld3	equr	d3	;ok
ld2	equr	a1	;ok
ld1	equr	d1	;ok
ld0	equr	d0	;ok
la1	equr	d5	;gain de 4 cycles par addition !!!
la2	equr	d2
la3	equr	a3
la4	equr	a4
la5	equr	a5

	lea	table\w,a0
	lea	scrollbase(pc),a6
	moveq	#0,ld7		;i*8
nexti
	move.l	a6,(a0)+

	sub.l	la4,la4		;x=0
	move.l	la4,la5		;y=0
	moveq	#nblig-1,ld6
rept
	moveq	#0,la1		;off%

	move	#160,ld3	;160-i*8
	sub	ld7,ld3
	sub	la3,la3		;la3=0 (registre a5)
	bsr	gen
	move	ld7,ld3
	addq	#1,la3		;la3=1
	bsr	gen

	lea	160(la4),la4	;x=x+160

	tst	ld7
	beq.s	ok2
	cmp	#20*8,ld7
	beq.s	ok2
	lea	168(la5),la5	;y=y+168

	move	ld7,ld0
	sub	#64,ld0
	cmp	#96-64,ld0
	bls.s	no2		;64<=d7<=96
ok2
	cmp	#nblig2*160,la4	;x=nblig2*160 ?
	beq.s	no2

	tst	ld7
	beq.s	no4
	cmp	#20*8,ld7
	beq.s	no7

	cmp	#64,ld7
	bhs.s	no3		;160-d7<=96 ?
	move	#$4BED,(A6)+	; lea 8+i*8(a5),a5
	move	ld7,ld0
	addq	#8,ld0
	move	ld0,(a6)+
no3	cmp	#96,ld7
	bls.s	no2
	move	#$49EC,(A6)+	; lea 168-i*8(a4),a4
	move	#168,ld0
	sub	ld7,ld0
	move	ld0,(a6)+
	bra.s	no2
no7	move	#$504C,(A6)+	; addq #8,a4
	bra.s	no2
no4	move	#$504D,(A6)+	; addq #8,a5
no2
	move.l	la4,ld0
	sub	#2560,ld0
	blo.s	no6
	divu	#2720,ld0	;si (x-2560) mod 2720=0 -> skip une ligne
	swap	ld0
	tst	ld0
	bne.s	no6
	lea	160(la4),la4	;x=x+160
no6
	dbra	ld6,rept
	move	#$4E75,(A6)+	;RTS
	addq	#8,ld7
	cmp	#20*8,ld7
	bls	nexti

	ifeq	CPU
	cmp.l	#finscroll,a6
bug7	bne.s	bug7
	endc
;
; attend arret du moteur du drive
;
	move	#$80,$ffff8606.w
wait	move	$ffff8604.w,d0
	tst.b	d0
	bmi.s	wait
	MOVE.L	#$31415926,$426.W

	lea	RESET\w,a0
	MOVE.L	a0,$42A.W
	jmp	(a0)
gen
;
; entr‚e ld3=a%
;	 la3=a$ (0 ou 1)
;	 la5=y
;	 la4=x
;	 la1=off
;	 la2=y%
;
	moveq	#0,ld4		;clr flag%
	moveq	#0,la2		;clr y%

	cmp	#96,ld3		;a%<=96
	bhi.s	gen1
	tst	ld7		;i<>0
	beq.s	n3
	cmp	#20*8,ld7	;i<>20
	beq.s	n1
	moveq	#1,ld4		;flag=1
	bra.s	m2
;
; optimisation crade !!!
;
opt1	move	#$48D6,(A6)+	;MOVEM.L REGS,(A6)
	move	ld0,(A6)+
	rts
opt2
	move	#$4CEC+1,ld2
	sub	la3,ld2
	move	ld2,(A6)+	;MOVEM.L
	move	ld0,(A6)+	;REGS
	move	ld1,(A6)+	;OFFSET
	bra.s	xoff
FLAG2	move	#$4CDC+1,ld1	;MOVEM.L (An)+,
xoff2	sub	la3,ld1
	move	ld1,(A6)+
	move	ld0,(A6)+	;REGS
;
; optimise si x+off=0
;
xoff	move	la4,ld1
	add	la1,ld1
	beq.s	opt1
	move	#$48EE,(A6)+	;MOVEM.L REGS,X+OFFSET(A6)
	move	ld0,(A6)+
	move	ld1,(A6)+
	rts
;
; optimise si y+Y%=0
;
flag	tst	ld4
	beq.s	FLAG2
	move	la2,ld1		;y+Y%
	add	la5,ld1
	bne.s	opt2
	move	#$4CD4+1,ld1	;MOVEM.L (An),REGS
	bra.s	xoff2
;
gen1	cmp	#20*8,ld7
	bne.s	m1
n1
	cmp	#52,ld3
	blo.s	m2
n2
	move	#$2FFF,ld0	;MOVEM.L (An)+,D0-D7/A0-A3/A5
	BSR.S	FLAG2

	moveq	#52,ld0
	sub	ld0,ld3
	add	ld0,la1
	cmp	ld0,ld3
	bhs.s	n2
m1
	tst	ld7
	bne.s	m2
n3
	cmp	#52,ld3
	blo.s	m2
n4
	move	#$1FFF,ld0
	BSR.S	FLAG2

	moveq	#52,ld0
	sub	ld0,ld3
	add	ld0,la1
	cmp	ld0,ld3
	bhs.s	n4
m2
	cmp	#48,ld3
	blo.s	m3
n5
	move	#$0FFF,ld0	;D0-D7/A0-A3
	bsr.s	flag

	moveq	#48,ld0
	sub	ld0,ld3
	add	ld0,la2
	add	ld0,la1
	cmp	ld0,ld3
	bhs.s	n5
m3
	cmp	#44,ld3
	blo.s	m4

	move	#$07FF,ld0
	bsr.s	flag
	moveq	#44,ld0
	sub	ld0,ld3
	add	ld0,la1
	add	ld0,la2
m4
	cmp	#40,ld3
	blo.s	m5

	move	#$03FF,ld0
	bsr.s	flag
	moveq	#40,ld0
	sub	ld0,ld3
	add	ld0,la1
	add	ld0,la2
m5
	cmp	#36,ld3
	blo.s	m6

	move	#$01FF,ld0
	bsr	flag
	moveq	#36,ld0
	sub	ld0,ld3
	add	ld0,la1
	add	ld0,la2
m6
	cmp	#32,ld3
	blo.s	m7

	move	#$00FF,ld0
	bsr	flag
	moveq	#32,ld0
	sub	ld0,ld3
	add	ld0,la1
	add	ld0,la2
m7
	cmp	#28,ld3
	blo.s	m8

	moveq	#$007F,ld0
	bsr	flag
	moveq	#28,ld0
	sub	ld0,ld3
	add	ld0,la1
	add	ld0,la2
m8
	cmp	#24,ld3
	blo.s	m9

	moveq	#$003F,ld0
	bsr	flag
	moveq	#24,ld0
	sub	ld0,ld3
	add	ld0,la1
	add	ld0,la2
m9
	cmp	#20,ld3
	blo.s	m10

	moveq	#$001f,ld0
	bsr	flag
	moveq	#20,ld0
	sub	ld0,ld3
	add	ld0,la2
	add	ld0,la1
m10
	cmp	#16,ld3
	blo.s	m11

	moveq	#$000f,ld0
	bsr	flag
	moveq	#16,ld0
	sub	ld0,ld3
	add	ld0,la1
	add	ld0,la2
m11
	cmp	#12,ld3
	blo.s	m12
	moveq	#$0007,ld0
	bsr	flag
	moveq	#12,ld0
	sub	ld0,ld3
	add	ld0,la1
	add	ld0,la2
m12
	cmp	#8,ld3
	blo.s	m13

	moveq	#$0003,ld0
	bsr	flag
	subq	#8,ld3
	addq	#8,la1
	addq	#8,la2
m13
	tst	ld3
	beq.s	m14
	move	#$2D5C+1,ld0
	sub	la3,ld0
	move	ld0,(A6)+	;MOVE.L (An)+,d(An)
	move	la4,ld0
	add	la1,ld0
	move	ld0,(a6)+
	addq	#4,la1
m14	rts

startup
;
; transfŠre le reboot code (56 octets !!!)
;
	lea	PILE\W,sp
	movem.l	plante(pc),D0-D7/A0-A5/A6	;ICI A6=8 !!!!
	movem.l	D0-D7/A0-A5,(sp)

	moveq	#62-1,d0		;ici A6=8 !!!!
sei	move.l	a7,(a6)+		;mise en place des vecteurs
	dbra	d0,sei			;d'interruption
;
; g‚nŠre tout ce qu'il faut...
;
;
; pr‚calcul des coordonn‚es X
;
star2	macro
	move	(a0),d2
	addq	#\1,d2
	cmp	d4,d2
	blo.s	\@
	sub	d4,d2
\@	move	d2,(a0)+
	move	d2,d1
	and	d3,d2
	EOR	D2,D1
	eor	d3,d2

	ifeq	\1-3
	moveq	#-1,d0
	bclr	d2,d0
	elseif
	moveq	#0,d0
	bset	d2,d0
	endc

	lsr	#1,d1
	add	#\2*160,d1
	endm

	ifeq	CPU
	move	#$700,$ffff8240.w
	endc

	moveq	#$0F,d3
	move	#$140,d4
	move	#320-1,d7
	lea	coordx,a1
genstar
	lea	tabx(pc),a0
	star2	3,5		;1
	move	d0,(a1)
	move	d1,12(a1)
	star2	3,14		;2
	move	d0,2(a1)
	move	d1,14(a1)
	star2	2,23		;3
	move	d0,4(a1)
	move	d1,16(a1)
	star2	2,32		;4
	move	d0,6(a1)
	move	d1,18(a1)
	star2	2,41		;5
	move	d0,8(a1)
	move	d1,20(a1)
	star2	3,51		;6
	move	d0,10(a1)
	move	d1,22(a1)
	star2	1,59		;7
	move	d0,24(a1)
	move	d1,36(a1)
	star2	1,68		;8
	move	d0,26(a1)
	move	d1,38(a1)
	star2	3,77		;9
	move	d0,28(a1)
	move	d1,40(a1)
	star2	1,86		;10
	move	d0,30(a1)
	move	d1,42(a1)
	star2	2,95		;11
	move	d0,32(a1)
	move	d1,44(a1)
	star2	2,104		;12
	move	d0,34(a1)
	move	d1,46(a1)
	star2	3,113		;13
	move	d0,48(a1)
	move	d1,54(a1)
	star2	3,122		;14
	move	d0,50(a1)
	move	d1,56(a1)
	star2	1,131		;15
	move	d0,52(a1)
	move	d1,58(a1)
	lea	60(a1),a1
	dbra	d7,genstar

	ifeq	CPU
	cmp.l	#fincoordx,a1
bug2	bne.s	bug2
	endc
;
; DECALE LA FONTE
;
	ifeq	CPU
	cmp.l	#font,a1
bug8	bne.s	bug8
	move	#$070,$ffff8240.w
	endc
;	lea	font,a1
	moveq	#0,d6		;decalages
decal2
	lea	font2(pc),a0		;source
	move	#nbcar*height-1,d7	;nb caracteres de la fonte*nb pixels
carac
	moveq	#0,d0
	move	(a0)+,d0
	asl.l	d6,d0

	move	d0,(a1)+
	move	d0,(a1)+
	swap	d0
	move	d0,(a1)+
	move	d0,(a1)+
	dbra	d7,carac

	addq	#2,d6
	cmp	#16,d6
	blo.s	decal2

	ifeq	CPU
	cmp.l	#finfont,a1
bug1	bne.s	bug1
	endc

	lea	caractere\w,a0
	moveq	#0,d0
	moveq	#nbcar-1,d1
setcl	move	d0,(a0)+
	add	#8*height,d0
	dbra	d1,setcl

	ifeq	LOGO
;
; pr‚d‚cale le logo
;
	ifeq	CPU
	cmp.l	#baselogo,a1
bug6	bne.s	bug6
	move	#$007,$ffff8240.w
	endc
;	lea	baselogo,a1

	moveq	#35-1,d7
	lea	logo0(pc),a2
logo1	moveq	#20-1,d4
logo2	moveq	#20-1,d6
	moveq	#0,d0
	moveq	#0,d1
	move.l	a2,a0
logo3
	move	(a0),d0		;d‚cale le premier plan
	move	d0,(a1)+
	lsr.l	#1,d0
	move	d0,(a0)+
	addx	d0,d0
	swap	d0

	move	(a0),d1		;d‚cale le deuxiŠme plan
	move	d1,(a1)+
	lsr.l	#1,d1
	move	d1,(a0)+
	addx	d1,d1
	swap	d1
	dbra	d6,logo3
	dbra	d4,logo2
	move.l	a0,a2
	dbra	d7,logo1

	ifeq	CPU
	cmp.l	#finlogo,a1
bug	bne.s	bug
	MOVE	#$777,$FFFF8240.W
	endc

	endc

	bra	gencode
;
; pr‚calcul des coordonn‚es des ‚toiles
;
tabx	dc.w	283,14,268,256,182,251,202,146,284,276
	dc.w	243,146,169,248,1
;
; le processeur n'atterrit ici que s'il plante
; ‚videmment il est recommand‚ de n'utiliser cette routine
; que pour le d‚buggage
;
plante
	move	#$2700,sr
	move.l	#'m‚m‚',$300.w
	movem.l	d0-d7/a0-a7,$304.w
	move.l	usp,a0
	move.l	a0,$344.w
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,$348.w
	lea	$400.w,a0
	move	#($10000-$400)/4-1,d0
	moveq	#0,d1
clr40	move.l	d1,(a0)+	;cleare la page $400 pour eviter plantage ROM
	dbra	d0,clr40
	move.l	4.w,a0
	jmp	(a0)		;reboot
finplan	DC.L	8		;PETITE PROTECTION CONTRE TRACE !!!

PILE	equ	$400-finplan+plante	;pour gagner un peu de place

font2
	INCBIN	FONTE4.IMG

	ifeq	LOGO
logo0
	INCBIN	LOGO3.IMG
	endc

	IFNE	PRG
;
; PETIT MESSAGE DE BIENVENUE AUX DESASSEMBLEURS !!!
;
	DC.B	"IF YOU CAN READ THIS, I SUPPOSE THAT YOU ARE NOT SO BAD, "
	DC.B	"SO LET ME TELL YOU MORE ABOUT THIS DEMO. "
	DC.B	"ORIGINALLY, I WANTED TO SCROLL THE BIGGEST PART OF THE SCREEN "
	DC.B	"AND I FOUND A TECHNIQUE, SO THIS DEMO IS ONLY A DEMONSTRATION "
	DC.B	"OF MY STRENGTH IN 68000 !!! "
	DC.B	"YET, IT TAKES 5 MONTHS TO CODE (SO PLEASE, DON'T STEAL MY WORK !!!) "
	DC.B	"IT MEANS 200 HOURS AT LEAST OF HARD WORK !!! "
	DC.B	"AND THE CODE IS EXTREMELY OPTIMIZED (THE BEST POSSIBLE ???), "
	DC.B	"BUT IF YOU FIND ANY IMPROVEMENT -OR IF YOU WANT TO CONTACT ME- "
	DC.B	"CALL JEAN-CHARLES AT (16-1)60296219 "
	DC.B	"IN FRANCE (SEINE ET MARNE). "
	DC.B	"A LITTLE TRICK NOW : WHEN YOU PRESS TAB, "
	DC.B	"THE FREE CPU-TIME IS DISPLAYED !!! "
	DC.B	"I HAVE USED THE FOLLOWING TOOLS : "
	DC.B	"DEVPAC ST 2.08 (THE FUCKING NON-OPTIMISING ASSEMBLER, "
	DC.B	"BUT ALSO THE FASTEST !!!), SEKA 1.6 (USEFUL FOR LITTLE "
	DC.B	"ROUTINES WHICH DON'T USE THE EXTRA-SUPER-MARVELLOUS GEM "
	DC.B	"-BEEUURK-), ACOPY 1.2K (FOR ITS FORMAT OPTION WHICH "
	DC.B	"SPEEDS UP NORMAL DISKS, MOST OF THE FASTDISKS ARE BUGGED...) "
	DC.B	"AND GFABASIC 3.0 (THE 'BEST' BASIC EVER MADE). "
	DC.B	"PS : DAMNED, I'VE JUST DISCOVERED A NEW SCROLLING'S METHOD "
	DC.B	"7% FASTER THAN THIS ONE !!! "
	DC.B	"(PERHAPS FOR MY NEXT DEMO -OR GAME-) "
	EVEN
FINCODE
LONGCODE	EQU	FINCODE-DEBUT
	ENDC

	offset	$100

;ptrstar	ds.l	1
;pattern	ds.b	1	;d‚composition binaire du scrolling
;adecran	ds.b	1	;pointeur adresse ecran (gestion 3 ecrans)
;	even
;
; ne pas toucher a l'ordre des suivants !!!!
;
;
mode		ds.w	1
couleur		ds.w	1
compteur	ds.w	1	;varie de 0 … 21*2 step 2
decale		ds.w	1	;varie de 0 … 7*2 step 2
;
; pointeurs pour sprites et logo
;
message		ds.w	1	;pointeur 16 bits sur texte !!!
ptrdef		ds.w	1	;pointeur 16 bits pour latches
coords		ds.w	1	;pointeur 16 bits pour coordonn‚es sprites
deforme0	ds.w	1	;‚tat r‚el de chaque ligne du logo
lastcord1	ds.w	1	;pour effacement des sprites ecran0
deforme1	ds.w	1	;etat de chaque ligne ‚cran0
lastcord2	ds.w	1	;pour effacement des sprites ecran1
deforme2	ds.w	1	;etat de chaque ligne ‚cran1
;
; variables en trop mais inutile d'optimiser !!!
;
vy	ds.w	1
y2	ds.w	1
;
lasty	ds.w	1
lasty0	ds.w	1
lasty1	ds.w	1

	IFEQ	MUSIX
CHAN_A	DS.B	OFF30-1
L760	DS.B	1
CHAN_B	DS.B	OFF30-1
	DS.B	1
CHAN_C	DS.B	OFF30-1
	EVEN
	ENDC

caractere
	ds.w	nbcar
