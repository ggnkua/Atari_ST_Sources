;  Vector intro coded by Griff of E.I in 1991.
;  Main menu coding by Ruthless in 1991
;  Gold font by Lee the lamer now using my old handle of Magnum!

;
; This is set-up for Awesome Menu #6
;

	OPT O+,OW-

NUMFILES EQU	6

MADMAX	EQU	1
WINGS	EQU	1			; MUSIC TYPE
SDREAM	EQU	1			; ALL OTHERS TO 1!
SDRELO	EQU	1
TALE	EQU	0

RELADD	EQU	$70000	                ; CHANGE TO $60000 FOR SDREAM3
HOTLINE	EQU	RELADD+$94		; DELETE +$94 ALSO.

TUNENO	EQU	1


	BRA start

ENV	DC.L	0

start	MOVE.L	4(A7),A5
	LEA	STACK,A7
	MOVE.L	#300,-(SP)
	MOVE.L	A5,-(SP)
	MOVE.L	#$4A0000,-(SP)
	TRAP	#1
	LEA	12(SP),SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,OLDSP
	MOVE.L USP,A0
	MOVE.L A0,OLDUSP
	MOVE.B	#2,$FF820A
	MOVE.W	#4,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	CMP.W	#2,D0
	BEQ	EXIT
	MOVE.W	D0,OLDRES
	CLR.W -(SP)
	PEA -1.W
	PEA -1.W
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.L	#12,SP
	MOVEM.L	$FF8240,D0-D7
	MOVEM.L	D0-D7,OLDPAL
	IFEQ	SDRELO		; AT BEGINNING
	JSR	RELOMUS
	ENDC

	JSR Genstars
	MOVE #$777,D7			; fade down screen
.lp1	MOVEQ #2,D6
.lp	MOVE #37,-(SP)
	TRAP #14
	ADDQ.L #2,SP
	DBF D6,.lp
	MOVE.W D7,$FFFF8240.W
	SUB #$111,D7
	BPL.S .lp1
	MOVE #$2700,SR
	BSR clearpal
	LEA $FFFFFA00.W,A1
	LEA old_stuff(PC),A0
	MOVE.B $07(A1),(A0)+
	MOVE.B $09(A1),(A0)+
	MOVE.B $13(A1),(A0)+
	MOVE.B $15(A1),(A0)+		; Save mfp registers 
	MOVE.B $1B(A1),(A0)+		
	MOVE.B $1D(A1),(A0)+
	MOVE.B $21(A1),(A0)+
	MOVE.B $25(A1),(A0)+
	MOVE.L $70.W,(A0)+
	MOVE.L $110.W,(A0)+
	MOVE.L $114.W,(A0)+
	MOVE.L $120.W,(A0)+
	MOVE.L $134.W,(A0)+
	MOVE.L $FFFF8200.W,(A0)+
	JSR Initscreens
	JSR create160tb
	BSR flush
	MOVEQ #$12,D0
	BSR Write_ikbd
	CLR.B $FFFFFA07.W
	CLR.B $FFFFFA09.W
	CLR.B $FFFFFA13.W
	CLR.B $FFFFFA15.W
	BCLR.B #3,$fffffa17.W
	MOVE.L #vect_vbl,$70.W
	MOVE.L #star_pal,pal_ptr
	MOVEQ #1,D0
	BSR music+4
	BSR music+8
	MOVE #$2300,SR			; go for first intro

vbwait1st
	BTST.B #0,$fffffc00.w
	BEQ.S vbwait1st
	MOVE.B $fffffc02.w,d0
	CMP.B #$39+$80,d0		; space bar exits first intro
	BNE.S vbwait1st
	MOVE.W #8,fadeingO
.waitfadedown
	TST fadeingO			; wait for fade out...
	BNE.S .waitfadedown

; Second part starts around about here!

	MOVE #$2700,SR
	MOVE.B #8,$FFFFF8800.W
	CLR.B $FFFF8802.W 
	MOVE.B #9,$FFFFF8800.W
	CLR.B $FFFF8802.W 
	MOVE.B #10,$FFFFF8800.W
	CLR.B $FFFF8802.W 
	MOVE.B #7,$FFFF8800.W
	MOVE.B #-1,$FFFF8802.W
	move.l #300000,d0
.delay	subq.l #1,d0
	bne.s .delay
	MOVE.L	#SCREENS+256,D0
	CLR.B	D0
	MOVE.L	D0,SCREEN1
	MOVE.L	D0,D1
	LSR	#8,D1
	MOVE.L	D1,$FF8200
	ADD.L	#42240,D0
	MOVE.L	D0,SCREEN2

	MOVE.L	SCREEN1,SCRADD
	MOVE.L	SCREEN2,BAKADD

	MOVE.L	SCREEN1,A0
	MOVE.W	#(43000*2)/16-1,D7
CLP	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	DBRA	D7,CLP

	MOVE.L	SCRADD,A1
	MOVE.L	BAKADD,A2
	MOVE.L	#BACKPIC+34,A0
	MOVE.W	#160*183/4/4-1,D7
DLP	MOVE.L	(A0),(A1)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0),(A1)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0),(A1)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0),(A1)+
	MOVE.L	(A0)+,(A2)+
	DBRA	D7,DLP

	MOVEM.L	(BACKPIC+2),D0-D7
	MOVEM.L	D0-D7,$FF8240

	JSR	HBLON
	MOVE #$2300,SR

MLOOP	MOVE.B	$469.W,D0
VBL	CMP.B	$469.W,D0
	BEQ.S	VBL
	MOVE.L	SCRADD,D1
	LSR.W	#8,D1
	MOVE.L	D1,$FF8200
	JSR	SCROLLER1

	MOVE.L	SCRADD,A0
	MOVE.L	BAKADD,A1
	MOVE.L	A1,SCRADD
	MOVE.L	A0,BAKADD

	MOVE.B	$469.W,D0
VBL2	CMP.B	$469.W,D0
	BEQ.S	VBL2
	MOVE.L	SCRADD,D1
	LSR.W	#8,D1
	MOVE.L	D1,$FF8200

	JSR	SCROLLER2

	MOVE.L	SCRADD,A0
	MOVE.L	BAKADD,A1
	MOVE.L	A1,SCRADD
	MOVE.L	A0,BAKADD

KEYS	BTST.B #0,$fffffc00.w
	BEQ MLOOP
	MOVE.B	$FFFFFC02.W,D0
	CMP.B	OLD,D0
	BEQ	MLOOP
	MOVE.B	D0,OLD

	TST.B	D0
	BEQ	MLOOP

TKEYS	CMP.B	#11,D0
	BNE	NUM
	MOVE.W	#$777,$FF8240
	EORI.B	#2,HZ

NUM	SUB.B	#1,D0
	CMPI.B	#1,D0
	BGE.S	MAX
	BRA	MLOOP
MAX	CMPI.B	#NUMFILES,D0
	BLE.S	OKNUM
	BRA	MLOOP
OKNUM	MOVE.B	D0,FILE+1

QUIT	MOVE #$2700,SR

STOP	IFEQ	WINGS		; REST-MFP-ING
	JSR	MUSIC+12
	ENDC

	IFEQ	SDREAM
	MOVE.B	#$FF,D0
	JSR	MUSIC
	JSR	MUSIC+22
	ENDC

	IFEQ	SDRELO
	MOVEQ	#0,D0
	JSR	HOTLINE
	JSR	HOTLINE+12
	ENDC

	IFEQ	TALE
	MOVE.L	S114,$114
	MOVE.B	#$51,$FFFA1D
	MOVE.B	#$F0,$FFFA23
	MOVE.L	#$1E0064,$FFFA12
	MOVE.L	#$1E0064,$FFFA06
	BSET	#3,$FFFA17
	CLR.L	$FFFA0E
	MOVE.L	#$0700FF00,$FFFF8840.W
	MOVE.L	#$08000000,$FFFF8840.W
	MOVE.L	#$09000000,$FFFF8840.W
	MOVE.L	#$0A000000,$FFFF8840.W
	ENDC

	LEA old_stuff(PC),A0
	MOVE.B (A0)+,$FFFFFA07.W
	MOVE.B (A0)+,$FFFFFA09.W
	MOVE.B (A0)+,$FFFFFA13.W
	MOVE.B (A0)+,$FFFFFA15.W
	MOVE.B (A0)+,$FFFFFA1B.W
	MOVE.B (A0)+,$FFFFFA1D.W
	MOVE.B (A0)+,$FFFFFA21.W
	MOVE.B (A0)+,$FFFFFA25.W
	MOVE.L (A0)+,$70.W
	MOVE.L (A0)+,$110.W
	MOVE.L (A0)+,$114.W
	MOVE.L (A0)+,$120.W
	MOVE.L (A0)+,$134.W
	MOVE.L (A0)+,$FFFF8200.W
	MOVE.B #$C0,$FFFFFA23.W
	BSET.B #3,$FFFFFA17.W
	BSR flush
	MOVEQ #$8,D0
	BSR Write_ikbd

	MOVE.B #8,$FFFFF8800.W
	CLR.B $FFFF8802.W 
	MOVE.B #9,$FFFFF8800.W
	CLR.B $FFFF8802.W 
	MOVE.B #10,$FFFFF8800.W
	CLR.B $FFFF8802.W 
	MOVE.B #7,$FFFF8800.W
	MOVE.B #-1,$FFFF8802.W
	MOVE.B	HZ,$FFFF820A.W
	BSR flush
	MOVE #$2300,SR
	MOVEM.L	OLDPAL,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W
	MOVE.W	OLDRES,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.L	#12,SP
	MOVE.L OLDUSP,A0
	MOVE.L A0,USP
	MOVE.L	OLDSP,-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	MOVE.W	FILE,D0
	MOVEQ	#0,D1
	MOVE.W	D0,D1
	SUBQ.W	#1,D1
	LSL	#2,D1
	LEA	NAMES,A0
	MOVE.L	(A0,D1.L),A6
	PEA	ENV
	PEA	ENV
	MOVE.L	A6,-(SP)
	MOVE.L	#$4B0000,-(SP)
	TRAP	#1
	LEA	16(SP),SP
EXIT	CLR -(SP)
	TRAP #1

HBLON	MOVE.L	#NEWVBL,$70.W
	MOVE.L	#NEWHBL,$120.W
	MOVE.B	#1,$FFFFFA07.W
	MOVE.B	#0,$FFFFFA09.W
	MOVE.B	#1,$FFFFFA13.W
	MOVE.B	#0,$FFFFFA15.W
	CLR.B $FFFFFA1B.W
	CLR.B $FFFFFA21.W

INTMUS	MOVEQ	#TUNENO,D0	; WHEN STORING MFP STUFF

	IFEQ	MADMAX
	JSR	MUSIC
	ENDC

	IFEQ	WINGS
	JSR	MUSIC+4
	JSR	MUSIC+8
	ENDC

	IFEQ	SDREAM
	MOVEQ	#TUNENO-1,D0
	JSR	MUSIC
	JSR	MUSIC+18       
	ENDC

	IFEQ	SDRELO
	JSR	HOTLINE
	JSR	HOTLINE+4      
	ENDC

	IFEQ	TALE
	MOVE.B #6,$484
	MOVE.L $114,S114
	move.l #(MUSIC+$B52),(MUSIC+$1E)
	move.l #(MUSIC+$1C10),(MUSIC+$9E)
	move.l #(MUSIC+$8E8),(MUSIC+$106)
	jsr MUSIC
	BCLR #3,$FFFA17
	MOVEQ #1,D0
	jsr MUSIC+8
	ENDC
	RTS

S114	DC.L 0

NEWVBL	CLR.B	$FFFA1B
	MOVE.L	(BACKPIC+2),$FF8240
	MOVE.L	(BACKPIC+6),$FF8244
	MOVE.L	(BACKPIC+10),$FF8248
	MOVE.L	(BACKPIC+14),$FF824C

	MOVE.L	#NEWHBL,$120.W
	MOVE.B	#183,$FFFA21
	MOVE.B	#8,$FFFA1B

	MOVEM.L	D0-D7/A0-A6,-(SP)

PLAY	IFEQ	WINGS		; IN VBL
	JSR	MUSIC
	ENDC

	IFEQ	MADMAX
	JSR	MUSIC+8
	ENDC

	IFEQ	SDREAM
	JSR	MUSIC+26
	ENDC

	IFEQ	SDRELO
	JSR	HOTLINE+8
	ENDC

	IFEQ	TALE
	JSR	MUSIC+4
	ENDC

	MOVEM.L	(SP)+,D0-D7/A0-A6
	ADDQ.L #1,$466.W
	RTE

NEWHBL	MOVE.W	#$2700,SR
	CLR.B	$FFFA1B
	MOVE.L	(FONTBIN+2),$FF8240
	MOVE.L	(FONTBIN+6),$FF8244
	MOVE.L	(FONTBIN+10),$FF8248
	MOVE.L	(FONTBIN+14),$FF824C
	MOVE.L	#HBL2,$120
	MOVE.B	#16,$FFFA21
	MOVE.B	#8,$FFFA1B
	BCLR	#0,$FFFA0F
	MOVE.W	#$2300,SR
	RTE

HBL2	MOVE.W	#$2700,SR
	MOVEM.L	A0/D0,-(SP)
	LEA	$FFFA21,A0
	MOVE.B	(A0),D0
WLIN	CMP.B	(A0),D0
	BEQ.S	WLIN	

	REPT	6
	NOP
	ENDR
	BCHG	#1,$FF820A
	REPT	6
	NOP
	ENDR
	BCHG	#1,$FF820A

	CLR.B	$FFFA1B
	BCLR	#0,$FFFA0F
	MOVEM.L	(SP)+,A0/D0
	MOVE.W	#$2300,SR
	RTE

* 48*48 4 PLANE SCROLLER

YPOS	EQU	184

SCROLLER1	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.L	SCREEN2,A0
	LEA	160*YPOS(A0),A0
	MOVE.L	A0,A1
	ADDQ.L	#8,A0

	REPT 160*48/4
	MOVE.L (A0)+,(A1)+
	ENDR

	MOVE.L	SCRADD,A0
	LEA	160*YPOS(A0),A0
	MOVE.L	SCREEN2,A1
	LEA	160*YPOS(A1),A1
ADD	SET	152
	REPT	48
	MOVEP.L	ADD+1(A0),D0
	MOVEP.L D0,ADD(A1)
ADD	SET	ADD+160
	ENDR

	TST.W	CCNT
	BGT.S	NOTNEW
	JSR	NEWCHAR
NOTNEW	SUBQ.W	#1,CCNT

	MOVE.L	CHARAD,A0
	MOVE.L	SCREEN2,A1
	LEA	160*YPOS+152(A1),A1
i	SET 0
	REPT	48
	MOVEP.L i(A0),D0
	MOVEP.L D0,i+1(A1)
i	SET i+160
	ENDR
	RTS

SCROLLER2	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.L	SCREEN1,A0
	LEA	160*YPOS(A0),A0
	MOVE.L	A0,A1
	ADDQ.L	#8,A0

	REPT 160*48/4
	MOVE.L (A0)+,(A1)+
	ENDR

	MOVE.L	CHARAD,A0
	ADDQ.L	#8,CHARAD
	MOVE.L	SCREEN1,A1
	LEA	160*YPOS+152(A1),A1
	REPT	48
	MOVE.L	(A0),(A1)
	MOVE.L	4(A0),4(A1)
	LEA	160(A0),A0
	LEA	160(A1),A1
	ENDR
	RTS

NEWCHAR	MOVE.L	MPOS,A0
	MOVE.B	(A0)+,D1
	MOVE.B	D1,D0
	SUB.B	#32,D1
	LEA	CHARDAT,A1
	LSL	#2,D1
	MOVE.L	(A1,D1),A1
	MOVE.L	A1,CHARAD
	CMP.B	#$1,(A0)
	BNE.S	NOTEND
	CMP.B	#$2,1(A0)
	BNE.S	NOTEND
	CMP.B	#$3,2(A0)
	BNE.S	NOTEND
	CMP.B	#$4,3(A0)
	BNE.S	NOTEND
	CMP.B	#$FF,4(A0)
	BNE.S	NOTEND
	MOVE.L	#MESSAGE,A0
NOTEND	MOVE.L	A0,MPOS
	MOVE.W	#3,CCNT
	CMP.B	#'!',D0
	BNE	A1
	MOVE.W	#2,CCNT
A1	CMP.B	#'I',D0
	BNE	A2
	MOVE.W	#2,CCNT
A2	CMP.B	#'1',D0
	BNE	A3
	MOVE.W	#2,CCNT
A3	CMP.B	#',',D0
	BNE	A4
	MOVE.W	#1,CCNT
A4	CMP.B	#'.',D0
	BNE	A5
	MOVE.W	#1,CCNT
A5	CMP.B	#':',D0
	BNE	A6
	MOVE.W	#2,CCNT
A6	CMP.B	#'"',D0
	BNE	A7
	MOVE.W	#2,CCNT
A7	CMP.B	#"'",D0
	BNE	A8
	MOVE.W	#1,CCNT
A8	RTS

MPOS	DC.L	MESSAGE
MESSAGE	DC.B      '                                        '
	DC.B      ' A WARM WELCOME TO AWESOME MENU NUMER 6.'
	DC.B      '     YOUR HOST FOR THIS MENU IS RUTHLESS'
	DC.B      '.     NO I DIDNT MAKE THE DEADLINE, WHIC'
	DC.B      'H WAS TO DO 3 MENUS IN ONE DAY!     IT I'
	DC.B      'S NOW SUNDAY THE 14TH OF JULY AND I COMP'
	DC.B      'LETED 2 MENUS YESTERDAY AND NOW THIS IS '
	DC.B      'MY THIRD IN THE SPACE OF TWO DAYS!!    C'
	DC.B      'REDITS FOR THIS MENU GOTO.....    INTRO '
	DC.B      'CODING BY:- GRIFF OF E.I     MAIN MENU C'
	DC.B      'ODING BY:- RUTHLESS AND MAGNUM     DIGI-'
	DC.B      'CHIP MUSIC BY:- JOLLY JOCHEN HIPPEL (RIP'
	DC.B      'PED FROM A PREHISTORIC TALE BY ZELDA!)  '
	DC.B      '   AND     GRAPHIX BY:- HERMAN, WITH THE'
	DC.B      ' LOGO BY BENNY THE DRUNK!      THE ONLY '
	DC.B      'GAMES THAT I HAVE LEFT OVER NOW FOR A ME'
	DC.B      'NU ARE, SWITCHBLADE 2 AND THE SECOND WOR'
	DC.B      'LD, BUT THE SECOND WORLD IS IN FRENCH WH'
	DC.B      'ICH IS NOT REALLY VERY USER FRIENDLY IF '
	DC.B      'YOU DONT ACTUALLY UNDERSTAND FRENCH (LIK'
	DC.B      'E ME!).     MONSTER BUISNESS IS A REALLY'
	DC.B      ' BRILLIANT GAME AND BEFORE THE LOST BOYS'
	DC.B      ' START MOANING AND SAYING, OH LOOK AWESO'
	DC.B      'ME HAVE CRACKED OUR GAME - WE DID NOT TH'
	DC.B      'E ELITE DID SO DONT BOTHER MOANING AT US'
	DC.B      '.     ANYWAY AS I SAY MONSTER BUISNESS I'
	DC.B      'S A GOOD GAME AND IF YOU CAN AFFORD TO B'
	DC.B      'UY ORIGINALS BUY IT, BECAUSE ITS SUCH FU'
	DC.B      'N, BUT NO GAME IS WORTH 25 QUID WHOEVER '
	DC.B      'IT IS WRITTEN BY, WITH MAYBE THE INCY-WI'
	DC.B      'NCY EXCEPTION OF ENCHANTED LANDS BY THAL'
	DC.B      'ION!!      MEMBERS OF AWESOME ARE:-   RU'
	DC.B      'THLESS (ME),   ZELDA (KEEP UP THE GOOD W'
	DC.B      'ORK!),   THE SCORPION,   PHOENIX (ARE YO'
	DC.B      'U DEAD? - SEND ME YOUR LATEST GRAPHIX MA'
	DC.B      'TEY!),   DEMON-X (GET OFF YOUR ASS PLEAS'
	DC.B      'E AND DO SOME MORE DIGI-CHIP MUSIC)   AN'
	DC.B      'D FINALLY   THE EDITMAN (UP-LOAD OR NO-U'
	DC.B      'PLOAD? - COME ON MARTIN PULL YOUR WAIT!)'
	DC.B      '.....     IF YOU WANT TO CONTACT AWESOME'
	DC.B      ' THEN EITHER ASK YOUR CONTACTS OR POSSIB'
	DC.B      'LY LOOK AROUND IN PLACES!    HEY SCORPIO'
	DC.B      'N, HOW WAS THE INXS CONCERT?    WHY DONT'
	DC.B      ' YOU SAVE YOUR MONEY AND GO SEE SOMEONE '
	DC.B      'DECENT LIKE 808-STATE?!!    BUT SERIOUSL'
	DC.B      'Y, HOWS THE DEMO COMING ALONG?!    ENOUG'
	DC.B     'H CRAP NOW LETS DO THE GREETINGS!     GR'
	DC.B      'EETZ ONLY GOING TO THE FEW PEOPLE WHO DE'
	DC.B      'SERVE IT WHO ARE:-   THE REST OF AWESOME'
	DC.B      ',   THE MEDWAY BOYS(ESP. GINO AND ZIPPY '
	DC.B      '- MEGA HI TO ALAN W. FROM JAMES P.!),   '
	DC.B      'THE POMPEY PIRATES (ESP. GENIE, ALIEN AN'
	DC.B      'D PACMAN),   THE AVENGER OF F.O.F.T,   T'
	DC.B      'HE INNER CIRCLE (ESP. GRIFF, THE MASTER,'
	DC.B      ' COUNT ZERO AND THE PHANTOM),   THE SYND'
	DC.B      'ICATE (ESP. ONIXUS AND FLOSSY - YO ONIXU'
	DC.B      'S THE MUSIC IS COOL!),   MAGNUM,   THE S'
	DC.B      'OURCE (ESP. FROSTY AND KALAMAZOO),   ALA'
	DC.B      'N B,   BLOODANGEL,   MUG-UK,   B.B.C (ES'
	DC.B      'P. ANDY AND LAW),   DEREK M.D (HOW ARE T'
	DC.B      'HE KITTENS?!),   THE HIGHLANDER (SEND ME'
	DC.B      ' YOUR SCROLLTEXT),   LOTUS (YOUR MUSIC I'
	DC.B      'S BRILL!),   ANIMAL (DAVE SAYS HI),   BE'
	DC.B      'NNY (KEEP IN TOUCH),   THE ELITE (ESP. H'
	DC.B      'OTLINE),   THE REPLICANTS (ESP. ILLEGAL)'
	DC.B      ', MAD VISION (ESP. SPY 3 - ROB SAYS HI),'
	DC.B      '   TATTOO (ROB SAYS HI),   HAL (ROB SAYS'
	DC.B      ' THANX FOR LENDING HIM THE MODEM!),   PE'
	DC.B      'TER OF BAD BOYS,   TITANIC TARZAN FROM I'
	DC.B      'CELAND,   JASON ELITE OF EVIL FORCE (GIG'
	DC.B      'A-THANX FOR THE CALL!),   NOW 5 (ESP. ST'
	DC.B      'ORMLORD, SKIPPY AND REMEREZ),   JOE,   T'
	DC.B      'HE RADICAL BANDITS (ESP. THE RUDE DUDE),'
	DC.B      '   SUPERIOR (ESP. AXE),   CARL B,   RAEG'
	DC.B      'UN,   THE MONSTER BEETLE (AT LAST!),   T'
	DC.B      'HE VAMPIRE (25 QUID, WHAT A JOKE!),   IM'
	DC.B      'PACT (ESP. TOXIC),   WIL FROM COBRA,   T'
	DC.B      '.S.B   AND   NEW POWER GENERATION.......'
	DC.B      '.     MEGA APOLOGIES TO ANYONE I FORGOT!'
	DC.B      '     SO UNTIL MENU NUMBER 7 THIS IS RUTH'
	DC.B      'LESS LOVING AND LEAVING YOU...        LE'
	DC.B      'TS WRAP!       BYE! BYE!                '
	DC.B      '                                    '

FONTPOS	
	DCB.B	20,$20
	DC.B	$1,$2,$3,$4,$FF

		EVEN

; Set all cols to zero and reset fade rout.

clearpal	lea $ffff8240.w,a0
		lea curr_pal,a1
		moveq #0,d0
		moveq #7,d1
.lp		move.l d0,(a0)+
		move.l d0,(a1)+
		dbf d1,.lp
		move.w #7,fadeing
		move.w #4,fadeing1
		clr.w scrlflag
		rts

; Write D0 to IKBD

Write_ikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S Write_ikbd
		MOVE.B D0,$FFFFFC02.W
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

old_stuff	DS.L 18
music		incbin wings_od.mus
		even

Initscreens	lea log_base(pc),a1
		move.l #screens+256,d0
		clr.b d0
		move.l d0,(a1)+
		add.l #32000,d0
		move.l d0,(a1)+
		move.l log_base(pc),a0
		bsr clear_screen
		move.l phy_base(pc),a0
		bsr clear_screen
		move.l log_base(pc),d0
		lsr #8,d0
		move.l d0,$ffff8200.w
		rts

; Clear screen ->A0

clear_screen	moveq #0,d0
		move #(32000/16)-1,d1
.cls		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		dbf d1,.cls
		rts

; Vbl for little vector intro

no_strs		EQU 131

vect_vbl	MOVE.L D0,-(SP)
		MOVEM.L curr_pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		LEA log_base(PC),A0
		MOVEM.L (A0)+,D0-D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D1
		MOVE.L D1,$FFFF8200.W
		BSR Fade_in
		BSR Fade_out
		JSR music
		BSR Clearstars
		BSR Plotstars
		BSR clear1plscreen
		LEA AWESOME,A5
		JSR Show_obj	
		MOVE.L (SP)+,D0
		RTE

star_pal	DC.W $000,$777,$555,$000,$333,$000,$000,$000
		DC.W $777,$777,$777,$777,$777,$777,$777,$777

; Clear last plane of screen - reasonably quickly...

clear1plscreen	MOVE.L log_base(PC),A0
		ADDQ.L #6,A0
		MOVEQ #0,D1
		MOVEQ #24,D0
i		SET 0
.lp		REPT 160
		MOVE.W D1,i(A0)
i		SET i+8
		ENDR
		LEA 1280(A0),A0
		DBF D0,.lp
		RTS

; Clear the stars.

Clearstars	MOVE.L log_base(PC),A0
		MOVEQ #0,D0
		NOT frameswitch
		BNE .cse2
.cse1		MOVE.L #.a1,which_old
.a1	
		REPT no_strs
		MOVE.W D0,2(A0)
		ENDR
		RTS
.cse2		MOVE.L #.b1,which_old
.b1	
		REPT no_strs
		MOVE.W D0,2(A0)
		ENDR
		RTS

; Plot those darn stars!

Plotstars	MOVE.L log_base(PC),A0
		LEA offsets,A1
		MOVE.L which_old(PC),A5
		MOVE.L (A5),D5
draw1		MOVE.L (A1),A2		
		MOVE.W (A2)+,D5		
		BGE.S .restart
		MOVE.L no_strs*4(A1),A2	
		MOVE.W (A2)+,D5		
.restart	MOVE.W (A2)+,D4
		OR.W D4,(A0,D5)
		MOVE.L A2,(A1)+		
		MOVE.L D5,(A5)+		
enddraw1	DS.B (no_strs-1)*(enddraw1-draw1)
		RTS

; This bit generates a big table of numbers which are co-ords
; for every star position. Memory wasting but quite fast. 

Genstars	LEA big_buf,A0
		LEA stars,A1		star co-ords
		LEA offsets,A2
		LEA res_offsets,A3
		MOVE #no_strs-1,D7
genstar_lp	MOVE.L A0,(A3)+			save reset offset
		MOVE.L A0,(A2)+			save curr offset
		MOVEM.W (A1)+,D4-D6		get x/y/z
		EXT.L D4			extend sign
		EXT.L D5
		ASL.L #8,D4
		ASL.L #8,D5
thisstar_lp	MOVE.L D4,D0 
		MOVE.L D5,D1
		MOVE.L D6,D2
		SUBQ #3,D6			z=z-3 (perspect)
		DIVS D2,D0			x/z(perspect)
		DIVS D2,D1			y/z(perspect)
		ADD #160,D0			add offsets
		ADD #100,D1			
		CMP #319,D0
		BHI.S Star_off
		CMP #199,D1
		BHI.S Star_off
		MOVE D0,D3
		MULU #160,D1
		LSR #1,D0
		AND.W #$FFF8,D0
		ADD.W D0,D1
		MOVE.W D1,(A0)+
		NOT D3
		AND #15,D3
		MOVEQ #0,D1
		BSET D3,D1
		MOVE.W D1,(A0)+
		ASR #6,D2
		TST D2
		BLE.S white
		CMP #1,D2
		BEQ.S white
		CMP #2,D2
		BEQ.S c2
c1		ADDQ #4,-4(A0)
		BRA thisstar_lp
white		BRA thisstar_lp
c2		ADDQ #2,-4(A0)
		BRA thisstar_lp
Star_off	MOVE.L #-1,(A0)+
		DBF D7,genstar_lp
Randoffsets	LEA offsets,A0
		LEA seed,A2
		MOVE #no_strs-2,D7
rands		MOVEM.L (A0),D0/D1
		SUB.L D0,D1
		DIVU #4,D1
		MOVEQ #0,D2
		MOVE (A2),D2		
		ROL #1,D2			
		EOR #54321,D2
		SUBQ #1,D2		
		MOVE D2,(A2)	
		DIVU D1,D2						
		CLR.W D2
		SWAP D2
		MULU #4,D2
		ADD.L D2,D0
		MOVE.L D0,(A0)+
		DBF D7,rands			
Repeatrout	LEA draw1(PC),A0
		LEA enddraw1(PC),A1
		MOVE #no_strs-2,D7
.lp1		MOVE #(enddraw1-draw1)-1,D6
.lp2		MOVE.B (A0)+,(A1)+
		DBF D6,.lp2
		DBF D7,.lp1
		RTS

frameswitch	DC.W 0
which_old	DC.L 0
stars		INCBIN rand_131.xyz
seed		DC.W $9753

Fade_in		TST fadeing
		BEQ nofade
		SUBQ #1,fadeing1
		BNE nofade
		MOVE #4,fadeing1
		SUBQ #1,fadeing
		LEA curr_pal(PC),A0
		MOVE.L pal_ptr(PC),A1
		MOVEQ #15,D4
col_lp		MOVE (A0),D0		reg value
		MOVE (A1)+,D1		dest value
		MOVE D0,D2
		MOVE D1,D3
		AND #$700,D2
		AND #$700,D3
		CMP D2,D3		
		BLE.S R_done
		ADD #$100,D0
R_done		MOVE D0,D2
		MOVE D1,D3
		AND #$070,D2
		AND #$070,D3
		CMP D2,D3
		BLE.S G_done
		ADD #$010,D0
G_done 		MOVE D0,D2
		MOVE D1,D3
		AND #$007,D2
		AND #$007,D3
		CMP D2,D3
		BLE.S B_done
		ADDQ #$001,D0
B_done		MOVE D0,(A0)+
		DBF D4,col_lp
		RTS
nofade		MOVE #-1,scrlflag
		RTS

pal_ptr		DC.L 0
curr_pal	DS.W 16
fadeing		DC.W 7
fadeing1	DC.W 4
scrlflag	DC.W 0

; Fade out rout

Fade_out	TST fadeingO
		BEQ nofade
		SUBQ #1,fadeingO1
		BNE nofade
		MOVE #4,fadeingO1
		SUBQ #1,fadeingO
		LEA curr_pal(PC),A0
		MOVE #$700,D5
		MOVEQ #$070,D6
		MOVEQ #$007,D1
		MOVEQ #15,D4
.col_lp		MOVE (A0),D0		reg value
		MOVE D0,D2
		AND D5,D2
		BEQ.S .R_done
		SUB #$100,D0
.R_done		MOVE D0,D2
		AND D6,D2
		BEQ.S .G_done
		SUB #$010,D0
.G_done 	MOVE D0,D2
		AND D1,D2
		BEQ.S .B_done
		SUBQ #$001,D0
.B_done		MOVE D0,(A0)+
		DBF D4,.col_lp
.nofade		RTS

fadeingO	DC.W 0
fadeingO1	DC.W 4

log_base	DC.L 0
phy_base	DC.L 0
switch		DC.W 0

Show_obj	LEA seqdata(PC),A3
		SUBQ #1,seq_timer(A3)
		BNE.S .nonew
		MOVE.L seq_ptr(A3),A1
		TST (A1)
		BPL.S .notendseq
		MOVE.L restart_ptr(A3),A1 
.notendseq	MOVE.W (A1)+,seq_timer(A3)
		MOVE.W (A1)+,addangx(A3)
		MOVE.W (A1)+,addangy(A3)
		MOVE.W (A1)+,addangz(A3)	; store new incs..
		MOVE.W (A1)+,zspeed
		MOVE.L A1,seq_ptr(A3)
.nonew		LEA trig_tab,A0		; sine table
		LEA 512(A0),A2			; cosine table
		MOVEM.W (A5)+,D5-D7    		; get current x,y,z ang	
		ADD addangx(A3),D5
		ADD addangy(A3),D6		; add increments
		ADD addangz(A3),D7
		AND #$7FE,D5
		AND #$7FE,D6
		AND #$7FE,D7
		MOVEM.W D5-D7,-6(A5)   	
		MOVE (A0,D5),D0			sin(xd)
		MOVE (A2,D5),D1			cos(xd)
		MOVE (A0,D6),D2			sin(yd)
		MOVE (A2,D6),D3			cos(yd)
		MOVE (A0,D7),D4			sin(zd)
		MOVE (A2,D7),D5			cos(zd)
		LEA M11+2(PC),A1
* sinz*sinx(used twice) - A3
		MOVE D0,D6			sinx
		MULS D4,D6			sinz*sinx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A3
* sinz*cosx(used twice) - A4
		MOVE D1,D6			cosx
		MULS D4,D6			sinz*cosx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A4
* Matrix(1,1) cosy*cosx-siny*sinz*sinx
		MOVE D3,D6			cosy
		MULS D1,D6			cosy*cosx
		MOVE A3,D7			sinz*sinx
		MULS D2,D7			siny*sinz*sinx					
		SUB.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,(A1)
* Matrix(2,1) siny*cosx+cosy*sinz*sinx 
		MOVE D2,D6
		MULS D1,D6			siny*cosx
		MOVE A3,D7			sinz*sinx
		MULS D3,D7			cosy*sinz*sinx			
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,M21-M11(A1)
* Matrix(3,1) -cosz*sinx
		MOVE D5,D6			cosz
		MULS D0,D6			cosz*sinx
		ADD.L D6,D6
		SWAP D6
		NEG D6				-cosz*sinx
		MOVE D6,M31-M11(A1)
* Matrix(1,2) -siny*cosz
		MOVE D2,D6			siny
		MULS D5,D6			siny*cosz
		ADD.L D6,D6
		SWAP D6
		NEG D6				-siny*cosz
		MOVE D6,M12-M11(A1)
* Matrix(2,2) cosy*cosz		
		MOVE D3,D6			cosy
		MULS D5,D6			cosy*cosz
		ADD.L D6,D6
		SWAP D6
		MOVE D6,M22-M11(A1)
* Matrix(3,2) sinz 
		MOVE D4,M32-M11(A1)
* Matrix(1,3) cosy*sinx+siny*sinz*cosx
		MOVE D3,D6			cosy
		MULS D0,D6			cosy*sinx
		MOVE A4,D7			sinz*cosx
		MULS D2,D7
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6				siny*(sinz*cosx)
		MOVE D6,M13-M11(A1)
* Matrix(2,3) siny*sinx-cosy*sinz*cosx
		MULS D0,D2			siny*sinx
		MOVE A4,D7
		MULS D3,D7
		SUB.L D7,D2 
		ADD.L D2,D2
		SWAP D2
		MOVE D2,M23-M11(A1)
* Matrix(3,3) cosz*cosx
		MULS D1,D5 
		ADD.L D5,D5
		SWAP D5				cosz*cosx
		MOVE D5,M33-M11(A1)

; Transform and perspect co-ords.
; A5 -> x,y,z.w offsets for co-ords,D7 source co-ords x,y,z.w
; A1 -> to a storage place for the resultant x,y co-ords.
; D0-D7/A0-A4 smashed.

		MOVE (A5)+,D7			get no of verts
		LEA new_coords(PC),A1		storage place new x,y co-ords
		MOVE.L zspeed(PC),D6
Trans_verts	MOVE.L (A5)+,addoffx+2
		MOVE.L (A5)+,addoffy+2
		ADD.L D6,(A5)
		MOVE.L (A5)+,addoffz+2		(after this a5-> d7 x,y,z co-ords
		MOVEA #160,A3			centre x
		MOVEA #100,A4			centre y
		SUBQ #1,D7				verts-1
trans_lp	MOVEM.W (A5)+,D0-D2		x,y,z
		MOVE D0,D3	
		MOVE D1,D4				dup
		MOVE D2,D5
; Calculate x co-ordinate		
M11		MULS #0,D0			
M21		MULS #0,D4				mat mult
M31		MULS #0,D5
		ADD.L D4,D0
		ADD.L D5,D0
		MOVE D3,D6
		MOVE D1,D4
		MOVE D2,D5
; Calculate y co-ordinate		
M12		MULS #0,D3
M22		MULS #0,D1				mat mult
M32		MULS #0,D5
		ADD.L D3,D1
		ADD.L D5,D1
; Calculate z co-ordinate
M13		MULS #0,D6
M23		MULS #0,D4				mat mult
M33		MULS #0,D2
		ADD.L D6,D2
		ADD.L D4,D2
; Combine and Perspect
addoffx		ADD.L #0,D0
addoffy		ADD.L #0,D1
addoffz		ADD.L #0,D2
		ADD.L D2,D2
		SWAP D2
		ASR.L #8,D0
		ASR.L #8,D1
		DIVS D2,D0
		DIVS D2,D1
		ADD A3,D0				x scr centre
		ADD A4,D1				y scr centre
		MOVE D0,(A1)+			new x co-ord
		MOVE D1,(A1)+			new y co-ord
		DBF D7,trans_lp
; A5 -> total no of lines to draw. 
drawlines	MOVE (A5)+,D7
		SUBQ #1,D7
; A5 -> line list
		MOVE.L log_base,A1
		LEA bit_offs(PC),A2
		LEA mul_tab,A3
		LEA new_coords(PC),A6		co-ords
drawline_lp	MOVE (A5)+,D1			;1st offset to vertex list
		MOVE (A5)+,D2			;2nd offset to vertex list
		MOVEM (A6,D1),D0-D1		;get x1,y1
		MOVEM (A6,D2),D2-D3		;"  x2,y2

xmax		EQU 319
ymax		EQU 199

Drawline	MOVE.L A1,A0
clipony		CMP.W D1,D3			; y2>=y1?(Griff superclip)!
		BGE.S y2big
		EXG D1,D3			; re-order
		EXG D0,D2
y2big		TST D3				; CLIP ON Y
		BLT	nodraw			; totally below window? <ymin
		CMP.W #ymax,D1
		BGT	nodraw			; totally above window? >ymax
		CMP.W #ymax,D3			; CLIP ON YMAX
		BLE.S okmaxy			; check that y2<=ymax 
		MOVE #ymax,D5
		SUB.W	D3,D5			; ymax-y
		MOVE.W D2,D4
		SUB.W	D0,D4			; dx=x2-x1
		MULS	D5,D4			; (ymax-y)*(x2-x1)
		MOVE.W D3,D5
		SUB.W	D1,D5			; dy
		DIVS	D5,D4			; (ymax-y)*(x2-x1)/(y2-y1)
		ADD.W	D4,D2
		MOVE #ymax,D3			; y1=0
okmaxy		TST.W	D1			; CLIP TO YMIN
		BGE.S cliponx
		MOVEQ #0,D5
		SUB.W	D1,D5			; ymin-y
		MOVE.W D2,D4
		SUB.W	D0,D4			; dx=x2-x1
		MULS	D5,D4			; (ymin-y1)*(x2-x1)
		MOVE.W D3,D5
		SUB.W	D1,D5			; dy
		DIVS	D5,D4			; (ymin-y)*(x2-x1)/(y2-y1)
		ADD.W	D4,D0
		MOVEQ #0,D1			; y1=0
cliponx		CMP.W	D0,D2			; CLIP ON X				
		BGE.S	x2big
		EXG	D0,D2			; reorder
		EXG	D1,D3
x2big		TST.W	D2			; totally outside <xmim
		BLT	nodraw
		CMP.W #xmax,D0			; totally outside >xmax
		BGT	nodraw
		CMP.W #xmax,D2			; CLIP ON XMAX
		BLE.S	okmaxx	
		MOVE.W #xmax,D5
		SUB.W	D2,D5			; xmax-x2
		MOVE.W D3,D4
		SUB.W	D1,D4			; y2-y1
		MULS D5,D4			; (xmax-x1)*(y2-y1)
		MOVE.W D2,D5
		SUB.W	D0,D5			; x2-x1
		DIVS D5,D4			; (xmax-x1)*(y2-y1)/(x2-x1)
		ADD.W	D4,D3
		MOVE.W #xmax,D2
okmaxx		TST.W	D0
		BGE.S	.gofordraw
		MOVEQ #0,D5			; CLIP ON XMIN
		SUB.W	D0,D5			; xmin-x
		MOVE.W D3,D4
		SUB.W	D1,D4			; y2-y1
		MULS D5,D4			; (xmin-x)*(y2-y1)
		MOVE.W D2,D5
		SUB.W	D0,D5			; x2-x1
		DIVS D5,D4			; (xmin-x)*(y2-y1)/(x2-x1)
		ADD.W	D4,D1
		MOVEQ #0,D0			; x=xmin
.gofordraw	MOVE.W D2,D4
		SUB.W	D0,D4			; dx
		MOVE.W D3,D5
		SUB.W	D1,D5			; dy
		ADD D2,D2
		ADD D2,D2
		MOVE.L (A2,D2),D6		; mask/chunk offset
		ADD D3,D3
		ADD (A3,D3),D6			; add scr line
		ADDA.W D6,A0			; a0 -> first chunk of line
		SWAP D6				; get mask
		MOVE.W #-160,D3
		TST.W	D5			; draw from top to bottom?
		BGE.S	bottotop
		NEG.W	D5			; no so negate vals
		NEG.W	D3
bottotop	CMP.W	D4,D5			; dy>dx?
		BLT.S	dxbiggerdy

dybiggerdx	MOVE.W D5,D1			; yes!
		BEQ nodraw			; dy=0 nothing to draw(!)
		ASR.W	#1,D1			; e=2/dy
		MOVE.W D5,D2
		SUBQ.W #1,D2			; lines to draw-1(dbf)
.lp		OR.W D6,(A0)
		ADDA.W D3,A0
		SUB.W	D4,D1
		BGT.S	.nostep
		ADD.W	D5,D1
		ADD.W	D6,D6
		DBCS D2,.lp
		BCC.S .drawn
		SUBQ.W #8,A0
		MOVEQ	#1,D6
.nostep		DBF D2,.lp
.drawn		OR.W	D6,(A0)
nodraw		DBF D7,drawline_lp
		RTS

dxbiggerdy	CLR.W	D2
		MOVE.W D4,D1
		ASR.W	#1,D1			; e=2/dx
		MOVE.W D4,D0
		SUBQ.W #1,D0
.lp		OR.W	D6,D2
		SUB.W	D5,D1
		BGE.S	.nostep
		OR.W D2,(A0)
		ADDA.W D3,A0
		ADD.W	D4,D1
		CLR.W	D2
.nostep		ADD.W	D6,D6
		DBCS	D0,.lp
		BCC.S	.drawn
.wrchnk		OR.W	D2,(A0)
		SUBQ.W #8,A0
		CLR.W	D2
		MOVEQ	#1,D6
		DBF	D0,.lp
.drawn		OR.W D6,D2
		OR.W	D2,(A0)
		DBF D7,drawline_lp
		RTS

i		SET 6
bit_offs	REPT 20
		DC.W $8000,i
		DC.W $4000,i
		DC.W $2000,i
		DC.W $1000,i
		DC.W $0800,i
		DC.W $0400,i
		DC.W $0200,i
		DC.W $0100,i
		DC.W $0080,i
		DC.W $0040,i
		DC.W $0020,i
		DC.W $0010,i
		DC.W $0008,i
		DC.W $0004,i
		DC.W $0002,i
		DC.W $0001,i
i		SET i+8
		ENDR

new_coords	DS.W 200

zspeed		dc.l 0

; Sequence data 
		
		RSRESET

seq_timer	RS.W 1
seq_ptr		RS.L 1
addangx		RS.W 1
addangy		RS.W 1
addangz		RS.W 1
restart_ptr	RS.L 1

seqdata		DC.W 1
		DC.L sequence 
		DS.W 3
		DC.L restart

sequence	DC.W 140,8,0,0,-30
restart		DC.W 128,12,0,0,0
		DC.W 256,12,0,12,0
		DC.W 512,12,2,12,0
		DC.W -1

AWESOME		Dc.W 0,1024,0
		DC.W 31
		DC.L 0,0,$1200*65536
.aP		DC.W -700,-100,0
		DC.W -500,100,0
		DC.W -500,-100,0
		DC.W -500,0,0  
		DC.W -600,0,0
.wP		DC.W -440,-100,0
		DC.W -400,0,0
		DC.W -360,-100,0
		DC.W -300,100,0
.eP		DC.W -100,100,0
		DC.W -300,40,0
		DC.W -200,0,0
		DC.W -300,-40,0
		DC.W -100,-100,0
.sP		DC.W 100,-40,0
		DC.W -100,40,0
		DC.W 100,100,0
.oP		DC.W 100,0,0
		DC.W 200,100,0
		DC.W 300,0,0
		DC.W 200,-100,0		 
.mP		DC.W 300,-100,0
		DC.W 360,100,0
		DC.W 400,0,0
		DC.W 440,100,0
		DC.W 500,-100,0
.eEP		DC.W 500,100,0
		DC.W 540,100,0
		DC.W 500,0,0
		DC.W 600,0,0
		DC.W 700,-100,0
		DC.W 26
.al		DC.W 00*4,01*4 
		DC.W 01*4,02*4
		DC.W 03*4,04*4
.wl		DC.W 01*4,05*4
		DC.W 05*4,06*4
		DC.W 06*4,07*4
		DC.W 07*4,08*4
.el		DC.W 09*4,10*4
		DC.W 10*4,11*4
		DC.W 11*4,12*4
		DC.W 12*4,13*4
.sl		DC.W 13*4,14*4
		DC.W 14*4,15*4
		DC.W 15*4,16*4
.ol		DC.W 17*4,18*4
		DC.W 18*4,19*4
		DC.W 19*4,20*4
		DC.W 20*4,17*4
.ml		DC.W 21*4,22*4
		DC.W 22*4,23*4
		DC.W 23*4,24*4
		DC.W 24*4,25*4
.eEl		DC.W 25*4,26*4
		DC.W 26*4,27*4
		DC.W 28*4,29*4
		DC.W 25*4,30*4

; Create *160 table

create160tb	LEA mul_tab,A0
		MOVEQ #0,D0					;create *160 table
		MOVE #199,D1
mke_t160_lp	MOVE D0,(A0)+
		ADD #160,D0
		DBF D1,mke_t160_lp
		RTS

RELOMUS	LEA	MUSIC,A0		
	MOVE.L	#RELADD,A1
RELP	MOVE.L	(A0)+,(A1)+
	CMP.L	#MUSEND,A0
	BLT.S	RELP
	RTS

		SECTION DATA

mul_tab		DS.W 200
trig_tab	dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
		dc.w	$0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3 
		dc.w	$0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200 
		dc.w	$12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833 
		dc.w	$18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56 
		dc.w	$1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467 
		dc.w	$2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61 
		dc.w	$2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041 
		dc.w	$30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603 
		dc.w	$36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4 
		dc.w	$3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120 
		dc.w	$41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674 
		dc.w	$471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D 
		dc.w	$4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097 
		dc.w	$5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F 
		dc.w	$55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3 
		dc.w	$5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F 
		dc.w	$5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271 
		dc.w	$62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656 
		dc.w	$66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC 
		dc.w	$6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61 
		dc.w	$6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082 
		dc.w	$70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E 
		dc.w	$73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3 
		dc.w	$7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F 
		dc.w	$7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41 
		dc.w	$7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7 
		dc.w	$7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61 
		dc.w	$7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E 
		dc.w	$7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C 
		dc.w	$7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD 
		dc.w	$7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE 
		dc.w	$7FFF,$7FFE,$7FFC,$7FF9,$7FF5,$7FEF,$7FE8,$7FE0 
		dc.w	$7FD7,$7FCD,$7FC1,$7FB4,$7FA6,$7F96,$7F86,$7F74 
		dc.w	$7F61,$7F4C,$7F37,$7F20,$7F08,$7EEF,$7ED4,$7EB9 
		dc.w	$7E9C,$7E7E,$7E5E,$7E3E,$7E1C,$7DF9,$7DD5,$7DB0 
		dc.w	$7D89,$7D61,$7D38,$7D0E,$7CE2,$7CB6,$7C88,$7C59 
		dc.w	$7C29,$7BF7,$7BC4,$7B91,$7B5C,$7B25,$7AEE,$7AB5 
		dc.w	$7A7C,$7A41,$7A04,$79C7,$7989,$7949,$7908,$78C6 
		dc.w	$7883,$783F,$77F9,$77B3,$776B,$7722,$76D8,$768D 
		dc.w	$7640,$75F3,$75A4,$7554,$7503,$74B1,$745E,$740A 
		dc.w	$73B5,$735E,$7306,$72AE,$7254,$71F9,$719D,$7140 
		dc.w	$70E1,$7082,$7022,$6FC0,$6F5E,$6EFA,$6E95,$6E30 
		dc.w	$6DC9,$6D61,$6CF8,$6C8E,$6C23,$6BB7,$6B4A,$6ADB 
		dc.w	$6A6C,$69FC,$698B,$6919,$68A5,$6831,$67BC,$6745 
		dc.w	$66CE,$6656,$65DD,$6562,$64E7,$646B,$63EE,$6370 
		dc.w	$62F1,$6271,$61F0,$616E,$60EB,$6067,$5FE2,$5F5D 
		dc.w	$5ED6,$5E4F,$5DC6,$5D3D,$5CB3,$5C28,$5B9C,$5B0F 
		dc.w	$5A81,$59F3,$5963,$58D3,$5842,$57B0,$571D,$5689 
		dc.w	$55F4,$555F,$54C9,$5432,$539A,$5301,$5268,$51CE 
		dc.w	$5133,$5097,$4FFA,$4F5D,$4EBF,$4E20,$4D80,$4CE0 
		dc.w	$4C3F,$4B9D,$4AFA,$4A57,$49B3,$490E,$4869,$47C3 
		dc.w	$471C,$4674,$45CC,$4523,$447A,$43D0,$4325,$4279 
		dc.w	$41CD,$4120,$4073,$3FC5,$3F16,$3E67,$3DB7,$3D07 
		dc.w	$3C56,$3BA4,$3AF2,$3A3F,$398C,$38D8,$3824,$376F 
		dc.w	$36B9,$3603,$354D,$3496,$33DE,$3326,$326D,$31B4 
		dc.w	$30FB,$3041,$2F86,$2ECC,$2E10,$2D54,$2C98,$2BDB 
		dc.w	$2B1E,$2A61,$29A3,$28E5,$2826,$2767,$26A7,$25E7 
		dc.w	$2527,$2467,$23A6,$22E4,$2223,$2161,$209F,$1FDC 
		dc.w	$1F19,$1E56,$1D93,$1CCF,$1C0B,$1B46,$1A82,$19BD 
		dc.w	$18F8,$1833,$176D,$16A7,$15E1,$151B,$1455,$138E 
		dc.w	$12C7,$1200,$1139,$1072,$0FAB,$0EE3,$0E1B,$0D53 
		dc.w	$0C8B,$0BC3,$0AFB,$0A32,$096A,$08A1,$07D9,$0710 
		dc.w	$0647,$057E,$04B6,$03ED,$0324,$025B,$0192,$00C9 
		dc.w	$0000,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4A,$FA82 
		dc.w	$F9B9,$F8F0,$F827,$F75F,$F696,$F5CE,$F505,$F43D 
		dc.w	$F375,$F2AD,$F1E5,$F11D,$F055,$EF8E,$EEC7,$EE00 
		dc.w	$ED39,$EC72,$EBAB,$EAE5,$EA1F,$E959,$E893,$E7CD 
		dc.w	$E708,$E643,$E57E,$E4BA,$E3F5,$E331,$E26D,$E1AA 
		dc.w	$E0E7,$E024,$DF61,$DE9F,$DDDD,$DD1C,$DC5A,$DB99 
		dc.w	$DAD9,$DA19,$D959,$D899,$D7DA,$D71B,$D65D,$D59F 
		dc.w	$D4E2,$D425,$D368,$D2AC,$D1F0,$D134,$D07A,$CFBF 
		dc.w	$CF05,$CE4C,$CD93,$CCDA,$CC22,$CB6A,$CAB3,$C9FD 
		dc.w	$C947,$C891,$C7DC,$C728,$C674,$C5C1,$C50E,$C45C 
		dc.w	$C3AA,$C2F9,$C249,$C199,$C0EA,$C03B,$BF8D,$BEE0 
		dc.w	$BE33,$BD87,$BCDB,$BC30,$BB86,$BADD,$BA34,$B98C 
		dc.w	$B8E4,$B83D,$B797,$B6F2,$B64D,$B5A9,$B506,$B463 
		dc.w	$B3C1,$B320,$B280,$B1E0,$B141,$B0A3,$B006,$AF69 
		dc.w	$AECD,$AE32,$AD98,$ACFF,$AC66,$ABCE,$AB37,$AAA1 
		dc.w	$AA0C,$A977,$A8E3,$A850,$A7BE,$A72D,$A69D,$A60D 
		dc.w	$A57F,$A4F1,$A464,$A3D8,$A34D,$A2C3,$A23A,$A1B1 
		dc.w	$A12A,$A0A3,$A01E,$9F99,$9F15,$9E92,$9E10,$9D8F 
		dc.w	$9D0F,$9C90,$9C12,$9B95,$9B19,$9A9E,$9A23,$99AA 
		dc.w	$9932,$98BB,$9844,$97CF,$975B,$96E7,$9675,$9604 
		dc.w	$9594,$9525,$94B6,$9449,$93DD,$9372,$9308,$929F 
		dc.w	$9237,$91D0,$916B,$9106,$90A2,$9040,$8FDE,$8F7E 
		dc.w	$8F1F,$8EC0,$8E63,$8E07,$8DAC,$8D52,$8CFA,$8CA2 
		dc.w	$8C4B,$8BF6,$8BA2,$8B4F,$8AFD,$8AAC,$8A5C,$8A0D 
		dc.w	$89C0,$8973,$8928,$88DE,$8895,$884D,$8807,$87C1 
		dc.w	$877D,$873A,$86F8,$86B7,$8677,$8639,$85FC,$85BF 
		dc.w	$8584,$854B,$8512,$84DB,$84A4,$846F,$843C,$8409 
		dc.w	$83D7,$83A7,$8378,$834A,$831E,$82F2,$82C8,$829F 
		dc.w	$8277,$8250,$822B,$8207,$81E4,$81C2,$81A2,$8182 
		dc.w	$8164,$8147,$812C,$8111,$80F8,$80E0,$80C9,$80B4 
		dc.w	$809F,$808C,$807A,$806A,$805A,$804C,$803F,$8033 
		dc.w	$8029,$8020,$8018,$8011,$800B,$8007,$8004,$8002 
		dc.w	$8001,$8002,$8004,$8007,$800B,$8011,$8018,$8020 
		dc.w	$8029,$8033,$803F,$804C,$805A,$806A,$807A,$808C 
		dc.w	$809F,$80B4,$80C9,$80E0,$80F8,$8111,$812C,$8147 
		dc.w	$8164,$8182,$81A2,$81C2,$81E4,$8207,$822B,$8250 
		dc.w	$8277,$829F,$82C8,$82F2,$831E,$834A,$8378,$83A7 
		dc.w	$83D7,$8409,$843C,$846F,$84A4,$84DB,$8512,$854B 
		dc.w	$8584,$85BF,$85FC,$8639,$8677,$86B7,$86F8,$873A 
		dc.w	$877D,$87C1,$8807,$884D,$8895,$88DE,$8928,$8973 
		dc.w	$89C0,$8A0D,$8A5C,$8AAC,$8AFD,$8B4F,$8BA2,$8BF6 
		dc.w	$8C4B,$8CA2,$8CFA,$8D52,$8DAC,$8E07,$8E63,$8EC0 
		dc.w	$8F1F,$8F7E,$8FDE,$9040,$90A2,$9106,$916B,$91D0 
		dc.w	$9237,$929F,$9308,$9372,$93DD,$9449,$94B6,$9525 
		dc.w	$9594,$9604,$9675,$96E7,$975B,$97CF,$9844,$98BB 
		dc.w	$9932,$99AA,$9A23,$9A9E,$9B19,$9B95,$9C12,$9C90 
		dc.w	$9D0F,$9D8F,$9E10,$9E92,$9F15,$9F99,$A01E,$A0A3 
		dc.w	$A12A,$A1B1,$A23A,$A2C3,$A34D,$A3D8,$A464,$A4F1 
		dc.w	$A57F,$A60D,$A69D,$A72D,$A7BE,$A850,$A8E3,$A977 
		dc.w	$AA0C,$AAA1,$AB37,$ABCE,$AC66,$ACFF,$AD98,$AE32 
		dc.w	$AECD,$AF69,$B006,$B0A3,$B141,$B1E0,$B280,$B320 
		dc.w	$B3C1,$B463,$B506,$B5A9,$B64D,$B6F2,$B797,$B83D 
		dc.w	$B8E4,$B98C,$BA34,$BADD,$BB86,$BC30,$BCDB,$BD87 
		dc.w	$BE33,$BEE0,$BF8D,$C03B,$C0EA,$C199,$C249,$C2F9 
		dc.w	$C3AA,$C45C,$C50E,$C5C1,$C674,$C728,$C7DC,$C891 
		dc.w	$C947,$C9FD,$CAB3,$CB6A,$CC22,$CCDA,$CD93,$CE4C 
		dc.w	$CF05,$CFBF,$D07A,$D134,$D1F0,$D2AC,$D368,$D425 
		dc.w	$D4E2,$D59F,$D65D,$D71B,$D7DA,$D899,$D959,$DA19 
		dc.w	$DAD9,$DB99,$DC5A,$DD1C,$DDDD,$DE9F,$DF61,$E024 
		dc.w	$E0E7,$E1AA,$E26D,$E331,$E3F5,$E4BA,$E57E,$E643 
		dc.w	$E708,$E7CD,$E893,$E959,$EA1F,$EAE5,$EBAB,$EC72 
		dc.w	$ED39,$EE00,$EEC7,$EF8E,$F055,$F11D,$F1E5,$F2AD 
		dc.w	$F375,$F43D,$F505,$F5CE,$F696,$F75F,$F827,$F8F0 
		dc.w	$F9B9,$FA82,$FB4A,$FC13,$FCDC,$FDA5,$FE6E,$FF37 
		dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
		dc.w	$0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3 
		dc.w	$0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200 
		dc.w	$12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833 
		dc.w	$18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56 
		dc.w	$1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467 
		dc.w	$2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61 
		dc.w	$2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041 
		dc.w	$30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603 
		dc.w	$36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4 
		dc.w	$3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120 
		dc.w	$41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674 
		dc.w	$471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D 
		dc.w	$4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097 
		dc.w	$5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F 
		dc.w	$55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3 
		dc.w	$5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F 
		dc.w	$5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271 
		dc.w	$62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656 
		dc.w	$66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC 
		dc.w	$6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61 
		dc.w	$6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082 
		dc.w	$70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E 
		dc.w	$73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3 
		dc.w	$7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F 
		dc.w	$7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41 
		dc.w	$7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7 
		dc.w	$7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61 
		dc.w	$7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E 
		dc.w	$7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C 
		dc.w	$7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD 
		dc.w	$7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE 

CHARDAT	DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
	DC.L	FONTDAT2+(160*48*2)+(24*4)	;!
	DC.L	FONTDAT2+(160*48*2)+(24*5)	;"
	DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
	DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
	DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
	DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
	DC.L	FONTDAT2+(160*48*2)+(24*6)	;'
	DC.L	FONTDAT2+(160*48*3)+(24*0)	;(
	DC.L	FONTDAT2+(160*48*3)+(24*1)	;)
	DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
	DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
	DC.L	FONTDAT2+(160*48*2)+(24*0)	;,
	DC.L	FONTDAT2+(160*48*2)+(24*1)	;-
	DC.L	FONTDAT2+(160*48*1)+(24*5)	;.
	DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
	DC.L	FONTDAT2+(160*48*3)+(24*4)	;0 (ACTUALLY O)
	DC.L	FONTDAT2+(160*48*0)+(24*2)	;1
	DC.L	FONTDAT2+(160*48*0)+(24*3)	;2
	DC.L	FONTDAT2+(160*48*0)+(24*4)	;3
	DC.L	FONTDAT2+(160*48*0)+(24*5)	;4
	DC.L	FONTDAT2+(160*48*1)+(24*0)	;5
	DC.L	FONTDAT2+(160*48*1)+(24*1)	;6
	DC.L	FONTDAT2+(160*48*1)+(24*2)	;7
	DC.L	FONTDAT2+(160*48*1)+(24*3)	;8
	DC.L	FONTDAT2+(160*48*1)+(24*4)	;9
	DC.L	FONTDAT2+(160*48*2)+(24*2)	;:
	DC.L	FONTDAT2+(160*48*2)+(24*3)	;;
	DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
	DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
	DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
	DC.L	FONTDAT2+(160*48*3)+(24*3)	;?
	DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
ADD	SET	0			;LETTERS A-X
	REPT	4
	DC.L	FONTDAT+ADD
	DC.L	FONTDAT+ADD+24
	DC.L	FONTDAT+ADD+48
	DC.L	FONTDAT+ADD+72
	DC.L	FONTDAT+ADD+96
	DC.L	FONTDAT+ADD+120
ADD	SET	ADD+160*48
	ENDR
	DC.L	FONTDAT2			;Y
	DC.L	FONTDAT2+24		;Z

FPOS	DC.L	FONTDAT
CCNT	DC.W	0
CHARAD	DC.L	0
FONTBIN	INCBIN	EXLFONT1.PI1
	INCBIN	EXLFONT2.PI1
	EVEN
FONTDAT	EQU	FONTBIN+34
FONTDAT2	EQU	FONTBIN+32066+34

SCREEN1	DC.L	0
SCREEN2	DC.L	0
OLDPAL	DS.L	8
OLDSP	DS.L 1
OLDUSP	DS.L 1
OLDRES	DC.W 0
SCRADD	DC.L	0
BAKADD	DC.L	0
SDT_VAR	DS.L	1
HZ	DC.B	2
OLD	DC.B	0
BACKPIC	INCBIN	MENU6.PI1

FILE	DC.W	0
	EVEN
FILE1	DC.B	'FG',0		;Slot file names of programs
	EVEN
FILE2	DC.B	'FH',0		;into these spaces.
	EVEN
FILE3	DC.B	'CLICK',0
	EVEN
FILE4	DC.B	'CLICK',0		;Leave any unused as '',0
	EVEN
FILE5	DC.B	'CLICK',0		;not 'FILEx',0
	EVEN
FILE6	DC.B	'CLICK',0
	EVEN
FILE7	DC.B	'FILE7',0
	EVEN
FILE8	DC.B	'FILE8',0
	EVEN
FILE9	DC.B	'FILE9',0
	EVEN
NAMES	DC.L	FILE1
	DC.L	FILE2
	DC.L	FILE3
	DC.L	FILE4
	DC.L	FILE5
	DC.L	FILE6
	DC.L	FILE7
	DC.L	FILE8
	DC.L	FILE9

;-----------------------------------------------------------------------;
MUSIC	INCBIN	tale.mus
MUSEND	EVEN
	DS.B	512                                          
	EVEN

		SECTION BSS
		DS.L	200
STACK		DS.L	1
offsets		DS.L no_strs
res_offsets	DS.L no_strs
big_buf		DS.B 40000
screens		DS.B 256
SCREENS		DS.B 42240*2
