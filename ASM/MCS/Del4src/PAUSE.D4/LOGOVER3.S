	OPT	O+
TEXT
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	MOVE.W	#$2700,SR
	
	CLR.B	$FFFF8260.W

	LEA	PAL,A0
	LEA	$FFFF8240.W,A1
	MOVEM.L	(A0),D0-D7
	MOVEM.L	D0-D7,(A1)

	move.w  #240,D0      * LARGEUR DU SPRITE EN PIXELS
        move.w  #74,D1          * HAUTEUR DU SPRITE
        lea     MCS,A0	        * SOURCE
        lea     ROUTINE,A1      * ADRESSE ROUTINES
        lea     TAB_ROUT,A2     * TABLE DES ROUTINES
        bsr     CALC_SPRITE     * GENERE LE CODE

	MOVE.L	A1,D1
	ADD.L	#256*100,D1
	AND.L	#$FFFFFF00,D1
	MOVE.L	D1,SCREEN1
	ADD.L	#160*270,D1
	AND.L	#$FFFFFF00,D1
	MOVE.L	D1,SCREEN2

	LEA	IMAGE,A0
	MOVE.L	SCREEN1,A1
	MOVE.L	SCREEN2,A2
	MOVE.L	#7999,D0
COPY	MOVE.L	(A0),(A1)+
	MOVE.L	(A0)+,(A2)+
	DBF	D0,COPY
	
	MOVE.L	SCREEN1,A1
	MOVE.L	SCREEN2,A2
	LEA	160*200(A1),A1
	LEA	160*200(A2),A2
	MOVE.W	#40*40-1,D1
	MOVEQ	#0,D0
EFF_BAS
	MOVE.L	D0,(A1)+
	MOVE.L	D0,(A2)+
	DBRA	D1,EFF_BAS
	
	MOVEQ	#1,D0
	JSR	ZIK

	LEA	SAVE,A0
	MOVE.L	$70.W,(A0)+
	MOVE.L	$120.W,(A0)+
	MOVE.B	$FFFA07,(A0)+
	MOVE.B	$FFFA09,(A0)+
	MOVE.B	$FFFA13,(A0)+
	MOVE.B	$FFFA17,(A0)+
	MOVE.B	$FFFA1B,(A0)+
	MOVE.B	$FFFA21,(A0)+
	CLR.B	$FFFA09
	MOVE.B	#1,$FFFA07
	MOVE.B	#1,$FFFA13
	BCLR	#3,$FFFA17
	MOVE.L	#VBL,$70.W
	MOVE.W	#$2300,SR

NIET
	BRA.S	NIET

FIN_DEMO
	MOVE.W	#$2700,SR
	
	LEA	SAVE,A0
	MOVE.L	(A0)+,$70.W
	MOVE.L	(A0)+,$120.W
	MOVE.B	(A0)+,$FFFA07
	MOVE.B	(A0)+,$FFFA09
	MOVE.B	(A0)+,$FFFA13
	MOVE.B	(A0)+,$FFFA17
	MOVE.B	(A0)+,$FFFA1B
	MOVE.B	(A0)+,$FFFA21

	MOVEQ	#0,D0
	JSR	ZIK

	ILLEGAL

VBL
	CLR.B	$FFFF8260.W
	CMP.B	#$39,$FFFC02
	BEQ.S	FIN_DEMO

	CLR.B	$FFFA1B
	MOVE.B	#199,$FFFA21
	MOVE.B	#8,$FFFA1B
	MOVE.L	#OVR_BAS,$120.W

	MOVEM.L	D0-A6,-(A7)

	MOVEM.L	PAL,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W

	JSR	ZIK+8

	MOVE.L	FOND2,FOND3
	MOVE.L	FOND,FOND2
	MOVE.L	SCREEN1,D0
	MOVE.L	SCREEN2,SCREEN1
	MOVE.L	D0,SCREEN2
	move.b	SCREEN1+1,$ffff8201.w
	move.b	SCREEN1+2,$ffff8203.w	
	BSR	RESTORE
	MOVE.L	POS,A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.W	(A0)+,D0		* X
	MOVE.W	(A0)+,D1		* Y
	CMP.W	#-1,(A0)
	BNE.S	GO
	LEA	XY,A0
GO	
	MOVE.L	A0,POS
	MOVE.L	SCREEN1,A0
	MOVE.L	#TAB_ROUT,A1
	MOVE.L	(A1,D0.W),A3
	MOVE.L	4(A1,D0.W),D2
	ADD.W	D2,A0
	ADD.W	D1,A0
	ADD.W	D1,D2
	MOVE.L	D2,FOND
	JSR	(A3)
	JSR	SCROL
	MOVEM.L	(A7)+,D0-A6
	RTE
OVR_BAS
	move.w	#$2700,sr
	MOVEM.L	D0-D7/A0,-(SP)
	lea	$fffffa21.w,a0
	move.b	(a0),d0
sync	cmp.b	(a0),d0
	beq.s	sync
	bclr	#1,$ff820a
	rept	10
	nop
	endr
	bset	#1,$ff820a
	MOVEM.L	PAL2,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W
	movem.l	(sp)+,d0-D7/a0
	MOVE.W	#$2300,SR
	RTE

RESTORE	MOVE.L	SCREEN1,A0
	MOVE.L	#IMAGE,A1
	ADD.L	FOND3,A0
	ADD.L	FOND3,A1
M	SET	0
	REPT	77
	MOVEM.L	M(A1),D0-D7/A2-A6		* 13 / 30
	MOVEM.L	D0-D7/A2-A6,M(A0)
	MOVEM.L	M+52(A1),D0-D7/A2-A6		* 26 / 30
	MOVEM.L	D0-D7/A2-A6,M+52(A0)
	MOVEM.L	M+104(A1),D0-D3			* 30 / 30
	MOVEM.L	D0-D3,M+104(A0)
M	SET	M+160
	ENDR
	RTS	

*************** ROUTINE DE GENERATION DES SPRITES ******************


CALC_SPRITE:
                move.l  A0,SOURCE
                move.l  A0,SOURCE2

                move.w  D0,D7
                and.w   #$FFF0,D7
                lsr.w   #1,D7
                move.w  D7,MAGNUM       * LARGEUR EN OCTETS

                and.w   #$FFF0,D0
                lsr.w   #4,D0
                subq.w  #1,D0
                move.w  D0,LARG         * NOMBRE DE FOIS 4 PLANS

                subq.w  #1,D1           * HAUTEUR-1
                move.w  D1,HAUT

                moveQ  #15,D7          * 16 POSITIONS
SEIZE_POS:
                move.w  #0,OFFSET       * DEPART A 0
                movea.w D7,A4
                movea.l SOURCE2,A0
                move.l  A0,SOURCE
                move.l  A1,(A2)+
                move.l  #0,(A2)+
                move.w  HAUT,D1
CALC_IT:
                movea.w OFFSET,A5
                moveq   #0,D0
                move.w  LARG,D0
CALC_LIG:
                move.w  (A0),D3         * PLAN 1
                move.w  2(A0),D4        * PLAN 2
                move.w  4(A0),D5        * PLAN 3
                move.w  6(A0),D6        * PLAN 4

                move.w  D3,D7
                or.w    D4,D7
                or.w    D5,D7
                or.w    D6,D7

                not.w   D7              * D7=MASQUE
                tst.w   D7
                beq     MOVES

                cmp.w   #$FFFF,D7       * MASK=$FFFF ??
                beq     MAG_02          * PAS DE AND

                movea.w OFFSET,A6

                move.w  #$02A8,(A1)+    * AND.L D7
                move.w  D7,(A1)+
                move.w  D7,(A1)+
                move.w  A6,(A1)+

                addq.w  #4,A6

                move.w  #$02A8,(A1)+    * AND.L D7
                move.w  D7,(A1)+
                move.w  D7,(A1)+
                move.w  A6,(A1)+

                movea.w OFFSET,A6

                tst.w   D3
                beq.s   D3_NUL
                tst.w   D4
                beq.s   ORW_D3

                move.w  #$A8,(A1)+
                move.w  D3,(A1)+
                move.w  D4,(A1)+
                move.w  A6,(A1)+
                bra.s   D4_NUL
ORW_D3:
                move.w  #$68,(A1)+
                move.w  D3,(A1)+
                move.w  A6,(A1)+
D3_NUL:

                movea.w OFFSET,A6
                addq.w  #2,A6
                tst.w   D4
                beq.s   D4_NUL

                move.w  #$68,(A1)+
                move.w  D4,(A1)+
                move.w  A6,(A1)+
D4_NUL:
                movea.w OFFSET,A6
                addq.w  #4,A6
                tst.w   D5
                beq.s   D5_NUL
                tst.w   D6
                beq.s   ORW_D5

                move.w  #$A8,(A1)+
                move.w  D5,(A1)+
                move.w  D6,(A1)+
                move.w  A6,(A1)+
                bra.S     D6_NUL
ORW_D5:
                move.w  #$68,(A1)+
                move.w  D5,(A1)+
                move.w  A6,(A1)+
D5_NUL:
                movea.w OFFSET,A6
                addq.w  #6,A6
                tst.w   D6
                beq.s   D6_NUL

                move.w  #$68,(A1)+
                move.w  D6,(A1)+
                move.w  A6,(A1)+
D6_NUL:
                bra.S     MAG_02
MOVES:
                movea.w OFFSET,A6
                move.w  #$217C,(A1)+
                move.w  D3,(A1)+
                move.w  D4,(A1)+
                move.w  A6,(A1)+
                addq.w  #4,A6
                move.w  #$217C,(A1)+
                move.w  D5,(A1)+
                move.w  D6,(A1)+
                move.w  A6,(A1)+

MAG_02:
                lea     8(A0),A0
                addi.w  #8,OFFSET
                dbra    D0,CALC_LIG

                movea.l SOURCE,A0
                moveq   #0,D7
                move.w  MAGNUM,D7
                adda.l  D7,A0
                move.l  A0,SOURCE
                adda.l  #160,A5
                move.w  A5,OFFSET
                dbra    D1,CALC_IT
                move.w  #$4E75,(A1)+    * RTS

                movem.l D0-A6,-(SP)
                bsr.S     ROX_GFX
                movem.l (SP)+,D0-A6

                move.w  A4,D7
                dbra    D7,SEIZE_POS
	MOVE	A1,USP
                bsr.S     CALC_TABLE
	MOVE	USP,A1
                rts

CALC_TABLE:
                lea     TAB_ROUT,A0
                lea     128(A0),A1
                move.w  #303,D7
CALC_TAB:
                movea.l (A0)+,A2
                move.l  (A0)+,D1
                addq.l  #8,D1
                move.l  A2,(A1)+
                move.l  D1,(A1)+
                dbra    D7,CALC_TAB
                rts

ROX_GFX:
                movea.l SOURCE2,A0
                movea.l A0,A1
                move.w  HAUT,D1
COL_ROX:
                move    #0,CCR
                move.w  LARG,D0
LIG_ROX1:
                roxr.w  (A0)
                lea     8(A0),A0
                dbra    D0,LIG_ROX1

                movea.l A1,A0
                move    #0,CCR
                move.w  LARG,D0
LIG_ROX2:
                roxr.w  2(A0)
                lea     8(A0),A0
                dbra    D0,LIG_ROX2

                movea.l A1,A0
                move    #0,CCR
                move.w  LARG,D0
LIG_ROX3:
                roxr.w  4(A0)
                lea     8(A0),A0
                dbra    D0,LIG_ROX3

                movea.l A1,A0
                move    #0,CCR
                move.w  LARG,D0
LIG_ROX4:
                roxr.w  6(A0)
                lea     8(A0),A0
                dbra    D0,LIG_ROX4

                adda.w  MAGNUM,A1
                movea.l A1,A0
                dbra    D1,COL_ROX
                rts
SCROL	JSR ROUT1
	RTS

ROUT1	MOVE.L #BUF4,A1
	BSR.S AFFB
	MOVE.L #BUF1,A1
	BSR DECAL
	MOVE.L #ROUT2,SCROL+2
	RTS
ROUT2	MOVE.L #BUF1,A1
	BSR.S AFFB
	MOVE.L #BUF2,A1
	BSR DECAL
	MOVE.L #ROUT3,SCROL+2
	RTS
ROUT3	MOVE.L #BUF2,A1
	BSR.S AFFB
	MOVE.L #BUF3,A1
	BSR DECAL
	MOVE.L #ROUT4,SCROL+2
	RTS
ROUT4	MOVE.L #BUF3,A1
	BSR.S AFFB
	MOVE.L #BUF4,A1
	BSR DECAL
	BSR ADLET
	MOVE.L #ROUT1,SCROL+2
	RTS

AFFB	MOVE.L SCREEN1,A0
	ADD.L	#160*204,A0
	REPT 16
	MOVEM.L	(A1),D0-D7/A2-A6
	MOVEM.L	D0-D7/A2-A6,(A0)
	MOVEM.L	52(A1),D0-D7/A2-A6
	MOVEM.L	D0-D7/A2-A6,52(A0)
	MOVEM.L	104(A1),D0-D7/A2-A6
	MOVEM.L	D0-D7/A2-A6,104(A0)
	MOVE.L	156(A1),156(A0)
	LEA	160(A0),A0
	LEA 	168(A1),A1
	ENDR
	RTS
DECAL
	LEA 8(A1),A0
	REPT 16
	MOVEM.L 	(A0),D0-D7/A2-A6
	MOVEM.L 	D0-D7/A2-A6,(A1)
	MOVEM.L	52(A0),D0-D7/A2-A6
	MOVEM.L 	D0-D7/A2-A6,52(A1)
	MOVEM.L	104(A0),D0-D7/A2-A6
	MOVEM.L 	D0-D7/A2-A6,104(A1)
	MOVE.L	156(A0),156(A1)
	LEA	168(A0),A0
	LEA	168(A1),A1
	ENDR
	RTS
ADLET
PEKM	MOVE.L #MESS,A0
	MOVEQ	#0,D1
	MOVE.B (A0),D1
	SUB.B #' ',D1
	ADD.W D1,D1
	ADD.W D1,D1
	MOVE.L #TABLET,A0
	MOVE.L (A0,D1.W),A1
	MOVE.L #BUF2+160,A2
	MOVE.L #BUF1+160,A3
	MOVE.L #BUF3+160,A4
	MOVE.L #BUF4+160,A5
	MOVEQ	#0,D1

	REPT 16
	MOVEQ	#0,D0
	MOVE.W	(A1),D0
	MOVE.W	D0,(A3)
	LSL.L	#4,D0
	MOVE.W	D0,(A2)
	SWAP	D0
	OR.W	D0,-8(A2)
	SWAP	D0

	LSL.L	#4,D0
	MOVE.W	D0,(A4)
	SWAP	D0
	OR.W	D0,-8(A4)
	SWAP	D0

	LSL.L	#4,D0
	MOVE.W	D0,(A5)
	SWAP	D0
	OR.W	D0,-8(A5)
	SWAP	D0

	MOVEQ	#0,D0
	MOVE.W	2(A1),D0
	MOVE.W	D0,2(A3)
	LSL.L	#4,D0
	MOVE.W	D0,2(A2)
	SWAP	D0
	OR.W	D0,-6(A2)
	SWAP	D0

	LSL.L	#4,D0
	MOVE.W	D0,2(A4)
	SWAP	D0
	OR.W	D0,-6(A4)
	SWAP	D0

	LSL.L	#4,D0
	MOVE.W	D0,2(A5)
	SWAP	D0
	OR.W	D0,-6(A5)
	SWAP	D0

	MOVEQ	#0,D0
	MOVE.W	4(A1),D0
	MOVE.W	D0,4(A3)
	LSL.L	#4,D0
	MOVE.W	D0,4(A2)
	SWAP	D0
	OR.W	D0,-4(A2)
	SWAP	D0

	LSL.L	#4,D0
	MOVE.W	D0,4(A4)
	SWAP	D0
	OR.W	D0,-4(A4)
	SWAP	D0

	LSL.L	#4,D0
	MOVE.W	D0,4(A5)
	SWAP	D0
	OR.W	D0,-4(A5)
	SWAP	D0
	MOVEQ	#0,D0
	MOVE.W	6(A1),D0
	MOVE.W	D0,6(A3)
	LSL.L	#4,D0
	MOVE.W	D0,6(A2)
	SWAP	D0
	OR.W	D0,-2(A2)
	SWAP	D0

	LSL.L	#4,D0
	MOVE.W	D0,6(A4)
	SWAP	D0
	OR.W	D0,-2(A4)
	SWAP	D0

	LSL.L	#4,D0
	MOVE.W	D0,6(A5)
	SWAP	D0
	OR.W	D0,-2(A5)
	SWAP	D0

	LEA	160(A1),A1
	LEA	168(A2),A2
	LEA	168(A3),A3
	LEA	168(A4),A4
	LEA	168(A5),A5
	ENDR
	ADDQ.L #1,PEKM+2
	CMP.L #FINM,PEKM+2
	BNE.S FSC
	MOVE.L #MESS,PEKM+2
FSC	RTS

FNT
	INCBIN	COPYB1.IMG

TABLET
M	SET	0
	REPT	20
	DC.L	FNT+M
M	SET	M+8
	ENDR
M	SET	160*16
	REPT	20
	DC.L	FNT+M
M	SET	M+8
	ENDR
M	SET	160*32
	REPT	20
	DC.L	FNT+M
M	SET	M+8
	ENDR

BUFD	DC.L 0
BUF1	DS.B 168*16
BUF2	DS.B 168*16
BUF3	DS.B 168*16
BUF4	DS.B 168*16
MESS	
	DC.B	"                "
	DC.B	"   HELLO LEMMINGS FANS...   "
	DC.B	" MAGNUM STRIKES ONCE AGAIN WITH THIS LAME"
	DC.B	" SCREEN.  ALL CODING BY MAGNUM (SORRY AXEL BUT I HAD"
	DC.B	" TO CHANGE THE ONLY BITS YOU MADE), GFX BY MARIO,"
	DC.B	" MUSIC BY MADMAX.  IT WAS FIRST CODED BY AXEL,"
	DC.B	" BUT I MADE THE SPRITE ROUT, THE SCROLL ROUT, I"
	DC.B	" RIPPED THE MUSAX, AND I TYPED THE SCROLLTEXT.."
	DC.B	"  JE M'APPELLE ROGER. ROGER CAGEOT ! J'AI TOUJOURS"
	DC.B	" MON VELO ET AVEC MES CAGEOTS, Y A PAS A FOURRER SON"
	DC.B	" NEZ LA DEDANS. SINON JE TE LACHE MES CHIENS. AH TU"
	DC.B	" CONNAIS PAS ROGER CAGEOT TOI ! MON VELO ET MA REMORQUE"
	DC.B	" C'EST COMME TA MAISON. ET MES TREIZE CHIEN ILS PISSENT"
	DC.B	" DANS TON JARDIN ! AIE AIE AIE AH ! Y A PLUS D'AMOUR DANS"
	DC.B	" LES FOYERS. LE SANG VA COULER DANS LE CANIVEAU ! AH TU ME"
	DC.B	" CONNAIS PAS. VAS PAS FOUILLER DANS MES AFFAIRES."
	DC.B	" MES CAGEOTS C'EST MES AFFAIRES. J'AI TOUS MES JOURNAUX"
	DC.B	" DE LA DERNIERE GUERRE DEDANS. ET SI TU VEUX TATER DE MES CLEBARDS,"
	DC.B	" AVISES-TOI DE FOUILLER DANS MES AFFAIRES. AS YOU CAN SEE I AM A"
	DC.B	" MANO NEGRA FAN...  TIME 23:00, STRANGE NIGHT FOR A SCROLLTEXT."
	DC.B	" MOON IS FULL, SKY IS DARK, WOLVES ARE CRYING AND BLOOD IS ON THE WALLS."
	DC.B	" BEER IS HOT, OVERLANDERS RULE AND AMIGA IS BETTER THAN ATARI !"
	DC.B	" NO I'M NOT DRUNK, BUT THE END OF THE WORLD IS COMING FAST..."
	DC.B	" ONLY MCS KNOWS, WE ARE THE ONLY ONES WHO CAN SAVE YOUR SOULS."
	DC.B	" DEVIL IS EVERYWHERE, GOD MADE US TO FIGHT HIM. "
	DC.B	"BUT SATAN MADE A LOTSA THINGS AGAINST US. HE INVENTED SPORTS,"
	DC.B	" WATER, OVERLANDERS AND AMIGA. IF YOU LIKE SPORT, WATER OR OVERLANDERS, "
	DC.B	"YOU SHOULD CALL AN EXORCIST. HEY DELTA FORCE, YOU'RE NOW CONTAMINATED."
	DC.B	" CALL US FOR MORE INFORMATIONS... I MUST CHANGE SUBJECT COZ IF I GO ON"
	DC.B	" I COULD BE TOOK BY THE DEVIL. "
	DC.B	"I WROTE A TEXT ON A DISK AND I SENT IT TO POLICE (JUST IN CASE I DIE SUDDENTLY !). "
	DC.B	" THIS IS PERHAPS MY LAST SCROLLTEXT, SO BE VERY CAREFULL, AND IF YOU WANNA"
	DC.B	" HELP US TO SAVE THE WHOLE WORLD FROM DESTRUCTION, SWAP THIS DEMO, FUCK THE OVERLANDERS, "
	DC.B	"DRINK BEER AND ALCOHOLS, THROW THE AMIGAS THROUGH THE WINDOWS, STOP THE SPORT. "
	DC.B	"THIS IS THE ONLY WAY ! "
	DC.B	" NOW LET'S PRAY FOR OUR SOULS...    GUINNESS   PELFORTH   KILLIANS   COURAGE   ADELSCOTT"
	DC.B	"   CHIMAY   ORVAL   TRAPPE   ST-SIXTUS   FISCHER   JENLAIN   HOEGAARDEN   LOWENBRAU   CARLSBERG   ROYAL VIKING"
	DC.B	"  SMITHWICKS   GORDON   MAC EWANS   LOBURG   STELLA ARTOIS   BUSH BEER   WITHBREAD   KILKENNY   PAULANER   MUTZIG   "
	DC.B	"KRONEMBORG   DUCASSE   HEINEKEN   COREFF   SETZ BRAU   KANTERBRAU   LUTECE   MURPHY'S"
	DC.B	"   SAMUEL SMITH'S   JOHN MARTIN   BASS   EKU   NEUFANG   SCHLOSS   FRANZISKANER   "
	DC.B	"WARSTEINER   KARLSBRAU   MONSCHOFF   ERDINGER   FURSTENBERG   MAES   BECK'S   DAB   "
	DC.B	"RODENBACH   ZULTE   BRIGAND   WATOU   KWAK   GRIMBERGEN   AFFLIGEM   "
	DC.B	"LEFFE   DUVEL   DUIVELS   MONINGER   BAILEY'S   VODKA   GIN   WHISKY   "
	DC.B	"WINE   SAKE   SOHO   MALIBU   MCS   MAY THE FORCE BE WITH YOU LUKE !"
	DC.B	" I KNOW WHAT YOU'RE THINKING. IS IT FIVE OR SIX BULLETS THAT I SHOT ?"
	DC.B	" WE DON'T AGREE. WE ? YES, ME SMITH AND WESSON ! AMIGA IN THE TOILETS, OVERLANDERS IN"
	DC.B	" A JAIL... PUTAS FEVER KING KONG FIVE PATCHANKA TOMATO KETCHUP MAGNUM FORCE. "
	DC.B	"YOU MUST SAY THIS EVERY DAY TO ESCAPE THE DEVIL !!!   AND DON'T FORGET : "
	DC.B	" THEY HATE LIGHTS, NEVER PUT THEM IN WATER. BUT THE MOST IMPORTANT THING : DON'T FEED THEM AFTER MIDNIGHT. "
	DC.B	" I FELL STRANGE, IS IT THE BEGINING OF THE END ???  ARGHHH I SEE SHADOWS MOVING ON THE WALLS."
	DC.B	" THEY SAW ME !!! THEY COME TO TAKE ME. I MUST ESCAPE... AGHJKSDF                     THEY DIDN'T"
	DC.B	" GOT ME. I ESCAPED. WE CAN'T DIE, WE ARE ON MISSION FROM GOD (WHERE HAVE I HEARD THIS BEFORE ?)."
	DC.B	" MCS WILL ALWAYS LIVE TO FIGHT DEVILS. HEY YOU READING, BEWARE, YOU COULD BE THE AIM OF THE"
	DC.B	" OVERMINATOR. HE'S PROGRAMMED TO KILL, NOTHING CAN STOP HIM. NOHING EXCEPT US. "
	DC.B	" J'AI COMME ENVIE DE TOURNER LE GAZ. COMME ENVIE DE ME FAIRE SAUTER LES PLOMBS."
	DC.B	" COMME ENVIE D'EXPLIQUER COMME CA. TON INDIFFERENCE NE ME TOUCHE PAS. "
	DC.B	"JE PEUX  TRES BIEN ME PASSER DE TOI. COMME ENVIE DE SANG SUR LES MURS, COMME ENVIE D'ACCIDENTS DE VOITURES."
	DC.B	" COMME ENVIE D'EXPLIQUER COMME CA. TON INDIFFERENCE NE ME TOUCHE PAS. "
	DC.B	"JE PEUX  TRES BIEN ME PASSER DE TOI. J'AI COMME ENVIE DE N'IMPORTE QUOI."
	DC.B	" COMME ENVIE DE CREVER TON CHAT. COMME ENVIE DE TOUT CASSER CHEZ TOI."
	DC.B	" COMME ENVIE D'EXPLIQUER COMME CA. TON INDIFFERENCE NE ME TOUCHE PAS. "
	DC.B	"JE PEUX  TRES BIEN ME PASSER DE TOI. COMME ENVIE D'UNE FEMME TORRIDE, COMME ON EN VOIT QU'AU CINEMA."
	DC.B	" J'AI COMME ENVIE QUE CE SOIT TERRIBLE, ET QUE CA SE PASSE JUSTE EN BAS DE CHEZ TOI."
	DC.B	" JE PEUX  TRES BIEN ME PASSER DE TOI.. AHH MY BRAIN, I'M BECOMING MAD, I SEE SPIDERS EATING MY STOMAC."
	DC.B	" HAAAAAAA.........      YEEAAAHH !!!! ZORG ON THE KEYBOARD!! HEY MEN ! THE APOCALYPSE IS NEAR BUT ,"
	DC.B	"AS MAGNUM WROTE IT!! BUT HERE I AM :THE FURYO EX-TERMINATOR ...KYLE REESE WAS MY FATHER,AND MY REAL "
	DC.B	" AIM IN THAT WORLD IS TO:1-SERVE THE PUBLIC TRUST..2- PROTECT THE INNOCENT..3- UFFOLD THE LAW.."
	DC.B	"4- SAUVER L'HORLOGE DE L'HOTEL DE VILLE...  I DIDNT BUILT THE TIME MACHINE TO GAIN AT GAMES,I BUILT IT"
	DC.B	"TO TRAVEL IN TIME !! NOM DE ZEUS!!!  TRUST ME !!WHEN LIFE HAS COME TO ITS END ,WHEN NO HOPES IS POSSIBLE,"
	DC.B	" THERE CAN BE ONLY ONE :M.C.S.  YOU KNOW WHAT ? A WAR WILL BEGIN. A WAR BETWEEN MACHINES AND HUMANS. "
	DC.B	" BUT THE WAR WON'T TAKE PLACE THERE, IT'LL BE THIS EVENING. WE COME FROM THE FUTURE. "
	DC.B	"YOU CAN'T IMAGINE HOW COMPUTERS ARE IN 3572 ! ONLY ONE KEY, ON-OFF. NO MONITORS, ONLY HOLOGRAMS."
	DC.B	" SPEED OF THE COMPUTERS ARE NOW 7GHZ. MORE THAN 500 MILLIONS OF COLORS. AND I ONLY TALK YOU ABOUT THE WORST"
	DC.B	" COMPUTER. BUT IF YOU GO ON TRUSTING OVERLANDERS, FUTURE WILL BE SAD, EVERIDOBY WILL HAVE A ZX81. KILL OVR."
	DC.B	" DRINK MONEY, AND SEND US BEER.. VIVE LA CHOUCROUTE, LES SAUCISSES, LE CASSOULET. I MUST GO NOW, KING ARTHUR IS WAITING"
	DC.B	" FOR ME. HASTA LA VISTA LEMMINGS FAN.              OK IF YOU THINK THAT'S ALL, YOU'RE SO WRONG..."
	DC.B	"  BULLSHIT IS OUR JOB, BEER IS OUR DRINK.  HEY ST OWNERS, BE VERY CAREFULL COZ SOMETHING NEW IS COMING. "
	DC.B	"IT COMES FROM THE DARKNESS, IT RISES FROM DEATH ONCE AGAIN, IT'S IMPOSSIBLE TO AVOID IT. IT MORE POWERFULL THAN"
	DC.B	" LASER GUNS, MORE NICE THAN EARTH. AND IT'S CALLED MCS... THEY HAVE A POWERFULL SECRET GUN, IT'S CALLED MAGNUM. "
	DC.B	" THE ONLY ONE, THE BEST ONE. SO IF YOU MEET A GUY WITH A MCS TSHIRT, IF THERE'S MAGNUM WRITTEN ON IT, RUN AWAY BEFORE HE SEE YOU !"
	DC.B	" IF YOU LOOK HIS EYES, YOU'LL BECOME MAD ! AVOID HIM.    HE'S A LEMMINGS KILLER. NEVER WEAR BLUE CLOTHES WITH A GREEN HAT, OR HE'LL DESTROY YOU."
	DC.B	"   NOW IT'S THE END OF THIS TEXT, AND PERHAPS THE END OF THE WORLD SO GOODBYE LEMMINGS FANS...        "
	DC.B	"    (C) MAGNUM  M.C.S./  FRENCH ALLIANCE                   "
FINM	DC.B 	0
	EVEN
ZIK
	INCBIN	MADMAX2.MUS
	EVEN
X	DC.W	0
Y	DC.W	0
INCX	DC.W	2
INCY	DC.W	2
PAL2
	DC.W	$0000,$0776,$0654,$0543,$0431,$0321,$0210,$0001
	DC.W	$0002,$0003,$0004,$0005,$0006,$0007,$0000,$0FFF
PAL	DC.W	$0000,$0FFF,$07F7,$0EFE,$06FE,$0DF6,$05FD,$0CF5
	DC.W	$0BFC,$03F4,$0AFB,$02F3,$09FA,$01FA,$08F2,$00F9
FOND	DC.L	0
FOND2	DC.L	0
FOND3	DC.L	0
POS	DC.L	XY
XY	INCBIN	MCS2.XY
	DC.L	-1,-1
IMAGE	INCBIN  FONDVERT.IMG
SCREEN1	DC.L	$60000
SCREEN2 	DC.L	$70000
SOURCE:   DC.L 0
SOURCE2:  DC.L 0
LARG:     DC.W 0
HAUT:     DC.W 0
MAGNUM:   DC.W 0
OFFSET:	DC.W 0
SAVE
	DS.L	5
TAB_ROUT:
                REPT 320
                DC.L 0
                DC.L 0
                ENDR
MCS:	INCBIN	LOGOVERT.IMG
ROUTINE: