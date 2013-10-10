;************************************************************************
;
;                       JAPANESE WAY OF LIFE !!!
;
;************************************************************************
;
;
;  Code'n gfxs by ZAPPY of HOLOCAUST - Music by JESS of OVERLANDERS
;
; A la question: "Quel est votre ‚cran pr‚f‚r‚ dans la Choice?", 99%
; des personnes interrog‚es ont r‚pondu sans h‚sitation:
;
;                     "JAPANESE WAY OF LIFE !!!!!!!!"
;
; A vrai dire, ‡a ne m'‚tonne pas du tout. C'est pourquoi je vous mijote
; un JAPANESE WAY OF LIFE 2 absolument titanesque!! D‚mesur‚!! Vertigineux!
; Voire un trackdisk complet.........
;
; ( Pour le border bas qui plante, je sais, je sais. Mais vous comprenez,
; moi, mon ST est sur une sale TV non r‚glable et je vois … peu prŠs 20
; lignes de border bas. Alors bon.... )

DEBUT:	
	LEA.L 	D_PILE,A7
	PEA	0.W
	MOVE 	#$20,-(SP)
	TRAP 	#1
	ADDQ.L 	#6,SP

	MOVEQ	#1,D0
	JSR	ZIK

	MOVE.L	#FIN,$008.W
	MOVE.L	#FIN,$00C.W
	MOVE.L	#FIN,$010.W
	MOVE.L	#FIN,$014.W
	
	MOVE.L	#INTER_RTE,$68.W
	CLR.B	$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	CLR.B	$FFFFFA13.W
	CLR.B	$FFFFFA15.W

	LEA	DATA_HS,A0
	MOVE.L	A0,POIT
		
	CLR.W 	-(SP)
	PEA	-1.W
	PEA	-1.W
	MOVE 	#5,-(SP)
	TRAP 	#14
	LEA.L 	12(SP),SP

	move.l	#BUFFERSCR,d0
	CLR.B	D0
	move.l	d0,SCREEN1		
	add.l	#64000,d0		
	move.l	d0,SCREEN2

	move.l	SCREEN1,d0	
	lsr.l	#8,d0		
	move.l	#$ffff8201,a0
	movep	d0,(a0)

******
	LEA	PART1+34,A0
	MOVE.L	SCREEN1,A1
	LEA	1600(A1),A1
	MOVE	#199,D7
AFF_Y	MOVE	#(112/4)-1,D6
AFF_X	MOVE.L	(A0)+,(A1)+
	DBF	D6,AFF_X
	LEA	48(A0),A0
	LEA	70+48(A1),A1
	DBF	D7,AFF_Y
******
	LEA	PART2+34,A0
	MOVE.L	SCREEN1,A1
	LEA	1600+112(A1),A1
	MOVE	#199,D7
AFF_Y2	MOVE	#(112/4)-1,D6
AFF_X2	MOVE.L	(A0)+,(A1)+
	DBF	D6,AFF_X2
	LEA	48(A0),A0
	LEA	70+48(A1),A1
	DBF	D7,AFF_Y2
******
	LEA	PART3+34,A0
	MOVE.L	SCREEN1,A1
	LEA	1600(A1),A1
	LEA	230*100(A1),A1
	LEA	230*99(A1),A1
	MOVE	#199,D7
AFF_Y3	MOVE	#(112/4)-1,D6
AFF_X3	MOVE.L	(A0)+,(A1)+
	DBF	D6,AFF_X3
	LEA	48(A0),A0
	LEA	70+48(A1),A1
	DBF	D7,AFF_Y3
******
	LEA	PART4+34,A0
	MOVE.L	SCREEN1,A1
	LEA	1600+112(A1),A1
	LEA	230*100(A1),A1
	LEA	230*99(A1),A1
	MOVE	#199,D7
AFF_Y4	MOVE	#(112/4)-1,D6
AFF_X4	MOVE.L	(A0)+,(A1)+
	DBF	D6,AFF_X4
	LEA	48(A0),A0
	LEA	70+48(A1),A1
	DBF	D7,AFF_Y4
******
	LEA	PART5+34,A0
	MOVE.L	SCREEN1,A1
	LEA	1600(A1),A1
	LEA	230*100(A1),A1
	LEA	230*100(A1),A1
	LEA	230*99(A1),A1
	LEA	230*95(A1),A1
	MOVE	#199,D7
AFF_Y5	MOVE	#(112/4)-1,D6
AFF_X5	MOVE.L	(A0)+,(A1)+
	DBF	D6,AFF_X5
	LEA	48(A0),A0
	LEA	70+48(A1),A1
	DBF	D7,AFF_Y5
******
	LEA	PART6+34,A0
	MOVE.L	SCREEN1,A1
	LEA	1600+112(A1),A1
	LEA	230*100(A1),A1
	LEA	230*100(A1),A1
	LEA	230*99(A1),A1
	LEA	230*95(A1),A1
	MOVE	#199,D7
AFF_Y6	MOVE	#(112/4)-1,D6
AFF_X6	MOVE.L	(A0)+,(A1)+
	DBF	D6,AFF_X6
	LEA	48(A0),A0
	LEA	70+48(A1),A1
	DBF	D7,AFF_Y6
******


	MOVE.L	#VBLR_IR,$70.W
	MOVE.L	#TB0_IR,$120.W
	
	MOVE.B	#$12,$FFFFFC02.W
	
	CLR.B	$FFFFFA1B.W
	BSET	#0,$FFFFFA07.W
	BSET	#0,$FFFFFA13.W

BOUCLE	JMP	BOUCLE
NUMERO_LIGNE	DC	0
INIT	DC	260
VBLR_IR
	CLR.B	$FFFFFA1B.W
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVEQ	#0,D7
	MOVEM.L	D0-D7,$FFFF8240.W

;	TST	INIT
;	BGE.S	ROULE
;	MOVE	#1,NUMERO_LIGNE
;	BRA.S	ROULE2
ROULE	MOVE	INIT,NUMERO_LIGNE
;ROULE2
	MOVE.B	#0,$FFFFFA19.W
	MOVE.B	#99,$FFFFFA1F.W		; BORDER HAUT
	MOVE.B	#4,$FFFFFA19.W
	BCLR	#3,$FFFFFA17.W
	MOVE.L	#INTER_TMA,$134.W
	ORI.B	#$20,$FFFFFA13.W
	ORI.B	#$20,$FFFFFA07.W
	JSR	ZIK+8

	CMPI.L	#8,NB_PART
	BNE	SUITV0
	BSR	TEST_LET
	CLR.L	NB_PART
SUITV0	BSR	SCROLL
	BSR	SCROLL

	LEA	PAL2,A0
INTER_RTE	RTE

INTER_TMA:	CLR.B	$FFFFFA07.W		; ARRET DU MFP POUR NE PAS
	CLR.B	$FFFFFA09.W		; ETRE GENE
	MOVE	#$2100,SR		; ON AUTORISE LA HBL
full
	LEA	$FFFF8209,A3
	LEA	$FFFF8260,A6
	LEA	$FFFF820A,A5

	MOVEQ	#0,D0
	MOVEQ	#2,D1

	STOP	#$2100		; ATTENTE DE LA PROCHAINE HBL
				; (FIXE A 16 CYCLES PRES ENVIRONS)
	MOVE	#$2700,SR		; ON COUPE TOUTE LES ITs
	MOVE	#$2300,(SP)		; AU RETOUR LE VBL SERA AUTORISEE

	MOVEQ	#29,D2		; ON ATTEND LE BON MOMENT
SYNCHROA:	DBF	D2,SYNCHROA
	NOP

	MOVE.B	D0,(A5)		; ET HOP! PLUS DE BORDER HAUT
	REPT	6
	NOP
	ENDR
	MOVE.B	D1,(A5)

*******

	MOVEA.L	POIT,A2

	;MOVE.L	A6,USP
	MOVE.L	#$FFFF8209,A6
	MOVE.L	#$FFFF8260,A4
	MOVE.L	#$FFFF820A,A3
	MOVEQ	#0,D1		
	MOVEQ	#$10,D6
	MOVE.L	#228-12+2-1-1,D0
;	MOVE	#$2700,SR

SYNCHRO	MOVE.B	(A6),D7     * SYNCHRO
	BEQ.S	SYNCHRO
	SUB.W	D7,D6		
	LSL.W	D6,D1		
	;MOVE.L	USP,A6
	DCB	97-3-4,$4E71

	REPT	9
	MOVE.L	(A2)+,A1	*3
	JSR	(A1)		*4
	ENDR
	
	DCB	7,$4E71
	
	MOVE	a4,(A4)
	MOVE.B	#0,(A4)
MOD_PAL	EQU	*+4
	MOVEM.L	PAL1,D1-D7/A1
	MOVEM.L	D1-D7/A1,$FFFF8240.W
	DCB	88-41-21-20+1,$4E71
	JSR	GERE_PAL
	MOVE.b	#0,(A3)
	MOVE	a4,(A3)
	DCB	13,$4E71
	MOVE	a4,(A4)
	MOVE.B	#0,(A4)
	DCB	12-1,$4E71


FULLSCREEN	NOP
;	REPT	228-12+2
	MOVE	a4,(A4)
	MOVE.B	#0,(A4)
	DCB	88-41,$4E71
	JSR	GERE_PAL
	MOVE.b	#0,(A3)
	MOVE	a4,(A3)
	DCB	13,$4E71
	MOVE	a4,(A4)
	MOVE.B	#0,(A4)
	DCB	12-4,$4E71
	DBF	D0,FULLSCREEN
;	ENDR
;	JMP	SUITE

	MOVE	A4,(A4)
	MOVE.B	#0,(A4)
	DCB	88-41,$4E71
	JSR	GERE_PAL
	MOVE.b	#0,(A3)
	MOVE	a4,(A3)
	DCB	13,$4E71
	MOVE	a4,(A4)
	MOVE.B	#0,(A4)
	;	ICI=116	NOPS

	CLR.B	$FFFF820A.W 
	DCB	8,$4E71

	MOVE	A4,(A4)
	MOVE.B	#0,(A4)
	MOVE	A4,(A3)
	DCB	88-2-41,$4E71
	JSR	GERE_PAL
	MOVE.b	#0,(A3)
	MOVE	a4,(A3)
	DCB	13,$4E71
	MOVE	a4,(A4)
	MOVE.B	#0,(A4)
	DCB	12,$4E71
;	JMP	SUITE
	
	REPT	42
	MOVE	A4,(A4)
	MOVE.B	#0,(A4)
	DCB	88-41,$4E71
	JSR	GERE_PAL
	MOVE.b	#0,(A3)
	MOVE	a4,(A3)
	DCB	13,$4E71
	MOVE	a4,(A4)
	MOVE.B	#0,(A4)
	DCB	12,$4E71
	ENDR
SUITE

	CMPI.B	#$50,$FFFFFC02.W
	BNE.S	PAS_HAUT
	CMPI.L	#230*200,Y_VALUE
	BEQ.S	PAS_HAUT
	ADD.L	#230,Y_VALUE
	SUBQ	#1,INIT
PAS_HAUT	CMPI.B	#$48,$FFFFFC02.W
	BNE.S	PAS_BAS
	TST.L	Y_VALUE
	BEQ.S	PAS_BAS
	SUB.L	#230,Y_VALUE
	ADDQ	#1,INIT
PAS_BAS
	MOVE.L	#PAL1,MOD_PAL
	TST	INIT
	BGT.S	LETZ_GO
	MOVE.L	#PAL2,MOD_PAL
LETZ_GO


	MOVEQ	#0,D0	
	MOVE.L	Y_VALUE,D0
	
	LSR	#8,D0
	MOVE	D0,D1
	LSL	#8,D1
	
	MOVE.L	Y_VALUE,D0
	SUB.L	D1,D0

	LEA	DATA_HS,A0

	TST	D0
	BNE.S	DEJ
	LEA	RIEN,A0
	MOVE.L	A0,POIT
	BRA.S	OKAY
DEJ	SUBQ.L	#2,D0
	MULU	#18,D0
	ADDA.L	D0,A0
	MOVE.L	A0,POIT
		
OKAY	move.l	SCREEN1,d0
;	move.l	SCREEN2,SCREEN1		
;	move.l	d0,SCREEN2

	move.l	SCREEN1,d0
	ADD.L	D1,D0
	lsr.l	#8,d0
	LEA	$FFFF8201.W,A0
	movep	d0,(a0)

	CMPI.B	#$39,$FFFFFC02.W
	BEQ	FIN
	RTE
Y_VALUE	DC.L	0

TB0_IR	RTE


FIN:	MOVE.L	4.W,A0
	JMP	(A0)

GERE_PAL	SUBQ	#1,NUMERO_LIGNE	5
	BEQ.S	CHANGE_COL		3/2
	DCB	4*6-3+1,$4E71
	BRA.S	RETOUR		3
CHANGE_COL	MOVE.L	(A0)+,$FFFF8240.W	6
	MOVE.L	(A0)+,$FFFF8244.W	6
	MOVE.L	(A0)+,$FFFF8248.W	6
	MOVE.L	(A0)+,$FFFF824C.W	6
RETOUR	RTS			4
SCROLL	MOVE.L	SCREEN1,A0
	LEA	1600+230*10+6(A0),A0
	LEA	BUF_LET,A1
	REPT	8
	ROXL	(A1)
	ROXL	224(A0)
	ROXL	216(A0)
	ROXL	208(A0)
	ROXL	200(A0)
	ROXL	192(A0)
	ROXL	184(A0)
	ROXL	176(A0)
	ROXL	168(A0)
	ROXL	160(A0)
	ROXL	152(A0)
	ROXL	144(A0)
	ROXL	136(A0)
	ROXL	128(A0)
	ROXL	120(A0)
	ROXL	112(A0)
	ROXL	104(A0)
	ROXL	96(A0)
	ROXL	88(A0)
	ROXL	80(A0)
	ROXL	72(A0)
	ROXL	64(A0)
	ROXL	56(A0)
	ROXL	48(A0)
	ROXL	40(A0)
	ROXL	32(A0)
	ROXL	24(A0)
	ROXL	16(A0)
	ROXL	8(A0)
	ROXL	(A0)
	LEA	230(A0),A0
	ADDQ.L	#2,A1
	ENDR
	ADDI.L	#1,NB_PART
	RTS


TEST_LET	MOVEQ	#0,D0
	LEA	TEXT1,A0	
	ADDA.L	POINT,A0
	LEA	FONT8_8,A1
	CMPI.B	#$FF,(A0)
	BNE	SUITTST
	CLR.L	POINT
	LEA	TEXT1,A0
SUITTST	MOVE.B	(A0),D0	
	SUBI.B	#32,D0	
	LSL.W	#3,D0	
	ADDA.L	D0,A1	
	LEA	BUF_LET,A2
	MOVE.B	(A1)+,(A2)
	MOVE.B	(A1)+,2(A2)
	MOVE.B	(A1)+,4(A2)
	MOVE.B	(A1)+,6(A2)
	MOVE.B	(A1)+,8(A2)
	MOVE.B	(A1)+,10(A2)
	MOVE.B	(A1)+,12(A2)
	MOVE.B	(A1)+,14(A2)
	ADDI.L	#1,POINT
	RTS

H0	
	DCB	128-4-3-4,$4E71
	RTS

H70
	MOVE	A4,(A4)
	MOVE.B	#0,(A4)
	DCB	3+17*5,$4E71
	MOVE.b	#0,(A3)
	MOVE	a4,(A3)
	DCB	13,$4E71
	MOVE	a4,(A4)
	MOVE.B	#0,(A4)
	NOP
	RTS	=4 NOPS
H44
	DCB	3+18*5,$4E71
	MOVE.b	#0,(A3)
	MOVE	a4,(A3)
	DCB	13,$4E71
	MOVE	a4,(A4)
	MOVE.B	#0,(A4)
	NOP
	RTS	=4 NOPS
H24
	MOVE	A4,(A4)
	MOVE.B	#0,(A4)
	DCB	1+17*5,$4E71
	MOVE.b	#0,(A3)
	MOVE	a4,(A3)
	DCB	13,$4E71
	MOVE	a4,(A4)
	MOVE.B	#0,(A4)
	REPT	3
	NOP
	ENDR
	RTS	=4 NOPS
H2
	NOP
	DCB	18*5,$4E71
	MOVE.b	#0,(A3)
	MOVE	a4,(A3)
	DCB	13,$4E71
	MOVE	a4,(A4)
	MOVE.B	#0,(A4)
	REPT	3
	NOP
	ENDR
	RTS	=4 NOPS
H80
	MOVE	A4,(A4)
	MOVE.B	#0,(A4)
	DCB	7*5,$4E71
	MOVE	A4,(A4)
	MOVE.B	#0,(A4)
	DCB	3+9*5,$4E71

	MOVE.b	#0,(A3)
	MOVE	a4,(A3)
	DCB	13,$4E71
	MOVE	a4,(A4)
	MOVE.B	#0,(A4)
	NOP
	RTS
	 
	DATA
NB_PART	DC.L	8
TEXT1
 DC.B "                           "
 dc.b " Bon, je suis enerve.              Zappy au clavier.           Je suis enerve."
 dc.b "        Alors j'ai decide de taper un texte pour tous vous casser."
 dc.b " Je n'epargerai personne. Vous allez tous me hair apres ca, mais tant pis: je suis enerve. "
 dc.b " Alors vous allez tous vous en prendre plein dans la tete pour pas un rond. ( Oui, vous avez pu"
 dc.b " remarquer que mon style etait legerement moins recherche que celui auquel mes"
 dc.b " fabuleux messages sur STMag, Gen4 et Rtel vous ont habitue. Mais c'est normal: je suis enerve. )"
 dc.b " Tiens, parlons en de Rtel... Rtel: le serveur maudit. "
 dc.b "  Je rappelle a nos amis etrangers qui auraient suivi l'idee saugrenue venue se loger dans les trefonds de leur labyrinthique cerveau, idee selon laquelle lire ce texte defilant ( scrolltext ) serait quelque chose a ne pas omettre de faire,"
 dc.b " que STMag, Gen4 et Rtel sont 3 serveurs accessibles via minitel. Ce qui n'empeche pas"
 dc.b " Rtel d'etre un infame repaire de cretinoides boutonneux"
 dc.b " ou se retrouvent tous les plus grands abrutis que la Terre ait jamais eu a supporter. Il y a plusieurs races de cretins, sur Rtel, attention, c'est bien range. "
 dc.b "Tout d'abord, et bien que ce ne soit pas inherent a Rtel, mais plutot au monde telematique en general, il y a les DEBILES PURS"
 dc.b " dont la preoccupation principale est de barbouiller meticuleusement l'ecran avec des memos RIDICULES, tout ca pour impressionner la galerie, qui, en regle generale, et puisque la nature est mal faite, n'en a strictement rien a foutre. "
 dc.b "Je les hais. Je les meprise. J'ai envie de leur cracher dessus, parfois.             Souvent.             Tout le temps.             "
 dc.b "Je peux pas les blairer. Non mais faut etre PRETENTIEUX, quand meme. Grrrr!              "
 dc.b " Deuxieme categorie de trouduculs astronomiques: les demandeurs de news...  J'arrive a me connecter sur Rtel1 apres des efforts demesurement titanesques, j'arrive peniblement jusqu'a ma bal, je presse delicatement Envoi pour repondre a mon "
 dc.b "cher et precieux correspondant, quand... paf! Ah, un contact. Bon, ok, Sommaire, je repondrai plus tard, autant voir tout de suite de quoi il s'agit des fois que ce soit important.        Contact: NUDGE: 'ta des news?'                 ... "
 dc.b "    Primaire.          Bon, je reponds: 'Non.'          ...        Contact: NUDGE: 'connar'      .............     Dans ces moments la, on a envie de tuer.         NON SEULEMENT CET ABRUTI SIDERAL "
 dc.b "-QUE JE NE CONNAIS PAS- M'AGRESSE, ME DIT MEME PAS BONJOUR, ME "
 dc.b "PRECISE MEME PAS SA MACHINE POUR QUE JE LUI REPONDE, MAIS EN PLUS IL M'INSULTE EN FAISANT DES FAUTES D'ORTHOGRAPHE..!!        ... J'ai du mal a me maitriser, quelquefois... Alors je tape mon frere, faute de mieux.    JE LES HAIS AUSSI, CES "
 dc.b "SALES MOMES! Des news, pfff, lamentable. Pays de sauvages.                     Troisieme categorie de desagreables: ceux qui parlent de... Pin's...       maman, aide moi. Je reve.        Y'a rien de plus ridiculement inutile qu'un Pin's. "
 dc.b "Il y en a qui COLLECTIONNENT les Pin's !! MAIS JE REVE!  Il faut vraiment etre d'une stupidite VERTIGINEUSE pour payer 500 balles un PIN'S!   Vous me direz: y'a bien des collectionneurs de timbres.  Oui, mais non.  C'est pas pareil.  Les"
 dc.b " Pin's, on les collectionne PARCE QUE ca s'appelle des Pin's, parce que c'est une vulgaire mode, et je la hais. Les Pin's existaient bien avant qu'on ait entendu parler des Pin's, seulement tout le monde s'en tapait le popotin avec un balai "
 dc.b "a chiottes parce que ca ne s'appelait pas encore des Pin's.  Grrr!   Je hais les Pin's.              "
 dc.b " Beaucoup de choses m'enervent, je sais. D'habitude je ne dis rien. Mais la je suis enerve. Il faut que je me calme, alors paf! Un scroll.            "
 dc.b "      Certains d'entre vous ( les plus hideux ) ont du remarquer que cette demo n'etait absolument pas protegee.  Sur Rtel, en club Demo ( pass Demo ), j'ai lu a propos de certaines demos dont je tairai les noms par pure charite pour leurs "
 dc.b "auteurs, que celles ci avaient pris des mois de retard a cause de lamentables problemes de protection...    C'est grave, quand meme. PROTEGER une demo. PUERIL!   Comme si les routines developpees dans les demos ST etaient des "
 dc.b "chefs d'oeuvres.  L'interet d'une routine de demo est tellement minusculissime que j'attacherais plus d'importance a un documentaire sur les papillons sous alimentes du Guatemala.  Admettons qu'un 'ripper' ( ripper, ahah! ) vienne jeter un "
 dc.b "oeil humide et fatigue sur vos ridicules petits bouts de code. MAIS QU'EST CE QUE CA PEUT BIEN VOUS FOUTRE!?  Raaaaaaaaaah! Un flingue, pretez moi un flingue!                          "
 dc.b " Grompf..       En fait, je sais ce qui m'enerve: c'est d'etre dans un groupe de MERDE, avec un nom d'apocalypse post-nucleaire.       Un groupe nul, avec des individus grotesques et pretentieux.  "
 dc.b " Par exemple, Elric.                      ...                         "
 dc.b " PFFFFFAHAHAHAHAHAHAHAHA!!!                  Hum.                     "
 dc.b "Je ne tenterai pas ici de vous donner la liste de ses defauts, je suis limite a 523K de memoire, mais il y en a tout de meme quelques uns flagrants:   "
 dc.b " Elric est pretentieux. Il n'arrete pas de me les briser avec ses routines pseudo-recherchees que n'importe quel programmeur pondrait en deux temps trois mouvements pour peu qu'il s'y mette pour de bon. Il va dire que je dis ca par jalousie,"
 dc.b " etc, et que tout ca est faux. Mais dites lui, vous: J'EN AI RIEN A SECOUER, DE SES ROUTINES MINABLES!!! "

 dc.b "   Et puis alors ce qui me gonfle encore plus, c'est son jeu.     Deja, le nom: 'Ultimate Fight'.                   .....                  "
 dc.b "  Quel nom ridicule.              Et encore.  Au debut, c'etait en Francais: 'L'Ultime Attaque'.... Pfahaha! Voir sur son ecran un logo avec ce nom la, c'est vraiment tres drole. Surtout quand on voit en immense dans les credits:"
 dc.b " 'Special thanks to GENERATION4'..     On ferait trois fois le tour des 2 hemispheres, on trouverait pas plus leche-cul !!!           "
 dc.b " Bon, ca encore, ca me derange pas trop.  Mais a entendre Elric, ce jeu est la 8eme merveille du Monde, attention! Enfin la 9eme: il aurait lui meme pris la 8eme position...    Il n'arrete pas de me rebattre les oreilles avec, c'est "
 dc.b "horrible.  En plus c'est un jeu a la Mach 3, et je HAIS les jeux a la Mach 3/Space Harrier. Et puis Bruno, puisque Hubert ne te le dit pas en face, je le dis pour lui: tes graphismes sont hideux. Merci Hubert.                           "
 dc.b " Mais le tour d'Hubert viendra, j'en suis toujours a Elric...   Il ne va pas s'en tirer a si bon compte.  Il faut aussi que je vous dise qu'Elric n'est JAMAIS a l'heure. Ca m'enerve. A un moment, il avait 9 ( NEUF ) heures de retard a un "
 dc.b "rendez-vous. ( Avec moi, comme par hasard. )   ...et ne comptez pas sur lui pour s'excuser, ca lui ecorcherait la tronche. Qu'il a tres laide. Si, si: tres tres laide, meme. Et puis il est tout petit. Tiens, voila: c'est un nain. Elric est "
 dc.b "un nain, autant physiquement qu'intellectuellement. Paf. Revelation.                 Dire que c'est dans le meme groupe que moi. C'est repugnant.                                  "
 dc.b " Bon, assez parle d'Elric, a force d'y penser j'ai envie de vomir.                 "


 dc.b "             ...                "
 dc.b " J'avais pense vous parler de tous les membres d'Holocaust, un a un, de dire que Dan Nato, Zerioul, None et Blyzard etaient 4 gros flemmards et que Sledge dessinait comme une savate, mais finalement, apres reflexion, c'etait surtout Elric "
 dc.b "que je visais.      Les autres sont supportables.    Et etant donne qu'Elric a lu le debut de ce texte, je compte sur lui pour ne pas me louper dans un autre ecran...  Donc pas question de faire mon auto-critique.   ( Quoique, c'est vite"
 dc.b " fait: Zappy/Holocaust: la perfection existe. Fini. )                               Mais non, je plaisante.                            "
 dc.b " La perfection existe PRESQUE.    Toujours modeste, c'est ma devise.                                          "
 dc.b " J'ai une meilleure idee, je vais parler de LEADER.                 Caisse?          Pardon: qu'est-ce?           Eh bien ma foi, c'est un RTC.            ...             Ca vous avance pas beaucoup, hein les incultes.           Reseau "
 dc.b "Telephonique Commute, si vous preferez.                   Certes, entends-je au loin.             L'equivalent d'un serveur 361X, mais fait par un particulier, et accessible via le numero de telephone du dit particulier. "
 dc.b " Dans le cas present, le numero est 34.66.03.57 et le particulier s'appelle Oxygene. Non, pas le groupe nul, hein. ( Nul, oui. Salut les copains! )          Leader est un RTC excellent. Parce qu'il est rapide, "
 dc.b "deja. Pas comme Rtel ou on attend 3 heures l'affichage de 3 pixels.  La c'est fast et nickel.  Bon, on y rencontre quelques tetes de pioche ( Salut, Slight, ca boume? ) et quelques rigolos ( Coucou ODC, j'aime tes routines de 80 droites,"
 dc.b " si, si, vraiment. ) mais en regle generale, les personnes qui y deambulent sont tout-a-fait recommandables. ( Y'a un certain Zappy, par exemple, tres cool, tres bien. )                       "
 dc.b "    Tiens, je vais lancer un petit concours. Les reponses devront etre donnees dans ma bal sur Leader exclusivement. Le gagnant gagnera ( si si, le gagnant gagnera, promis... )... je disais donc: le gagnant gagnera le source assembleur de"
 dc.b " l'ecran de son choix dans cette demo. Je precise: le source tel qu'il est sur mes disks, c'est-a-dire non commente, et pas forcement clair. Mais c'est comme ca. Voila donc la question:          quelle est mon actrice preferee?              "
 dc.b "     Dur dur, hein.         Oui, je sais.          Les habitues du serveur maudit pourront peut etre trouver l'inspiration sur mon repondeur, mais.......        J'en dis trop.               Indice:  ce n'est ni Marthe Villalonga, ni Rosy "
 dc.b "Varte.          Hop, a vous de jouer.             Ce concours est tres serieux, quoi qu'il en soit.                           "
 DC.B "               Bon!      Allez, maintenant je suis calme.  "
 dc.b "  Parlons un peu serieusement. Il va de soi que tout ce que j'ai"
 dc.b " dit avant, c'etait pour rire, pour que le contenu du scroll soit"
 dc.b " un peu marrant, pour une fois.  ( Apparemment, vu la reaction d'Elric, c'est reussi... ) "
 dc.b "   Tout ce que j'ai raconte est faux, bien entendu. Elric n'est pas un nain, Sledge ne dessine pas comme une savate, les graphs de Bruno sont excellents, et Oxygene n'est pas un groupe plus nul que nous. "
 dc.b "          Encore que.         Rtel, c'est vraiment le lieu de rendez-vous de toute la racaille informatique de la planete.       "
 dc.b " Et je conserve mes positions par rapport aux Pin's...               "
 dc.b "  Bon, ok, j'arrete.            Question: quels sont ceux parmi vous qui sont en train de lire ce texte?       "
 dc.b " J'ai des doutes.         Vu ce que j'apercois en dessous, je crois qu'ils sont fondes.         ...          "
 dc.b " Vous avez essaye les fleches HAUT et BAS?    ...   Hehe.      Ils n'avaient pas essaye les fleches HAUT et BAS.          "
 dc.b "   J'ai longtemps hesite avant de me decider a utiliser cet ecran...          Qu'est-ce qu'on va penser d'Holocaust, apres ca?    "
 dc.b "J'ai peur, tout d'un coup: imaginez que Mascot/Delta Force tombe nez-a-nez avec ce... enfin euh... cette chose, ci-dessous...    Je n'oserai plus la regarder en face si ca arrivait...    "
 dc.b "   Bof.          Apres tout, rien a foutre.            Parlons un peu de cette Choice Of Gods...         Vous pouvez aller lire les premiers secteurs du disk 2 si vous voulez quelques infos sur ce titre... "
 dc.b "   Pour l'instant, je vais plutot vous parler des ecrans.        "
 dc.b "    On commence par AROUND THE EARTH.       Euh.       Non, en fait, j'ai rien a dire sur cet ecran. Sympa, sans plus. Ah si, le logo au debut est de MIC. MIC?  Ben oui, son pseudo, c'est MIC. Je sais meme pas dans quel groupe il est..."
 dc.b "  Je l'ai vu a la CP de Dune/Fantasy. Il fait p'tet partie de Dune/Fantasy?  .........             INVERTED LANDSCAPES: voila un ecran qu'il est bien qu'il est beau.   Bon, c'est un coup a etre ecoeure de la 3D ( y'a que ca ) mais bon, c'est"
 dc.b " quand meme un vachte de chouette ecran. Quoi, le vert du cube est a vomir? Et alors, j'ai le droit, je fais ce que je veux.   Je dedicace cet ecran a Tom Awak ( ca s'ecrit comme ca? ) qui avait l'air de l'apprecier. Hop!             "
 dc.b " ELRIC FULL SPRITES: dans le genre artillerie lourde, on fait pas mieux. Au debut, il y avait une routine de sprite en code genere par Elric. Aux essais, on a reussi a mettre 5 sprites 80*80 dans une Vbl, on etait content. Mais il restait"
 dc.b " quelques lignes de temps machine inutilisees. Alors je me suis permis de remanier tout ca a ma facon en rajoutant le full... Notez cependant qu'Elric a ameliore ses routines, depuis. Elles sont encore plus rapides maintenant...          "
 dc.b " MY SOCKS ARE ATOMIC FLAME THROWERS: un titre qui a beaucoup fait rire Elric...  croyez-moi, s'il y a eu UN ecran CHIANT a programmer, c'est bien celui la. Quel bordel, pour faire tenir ca dans un 520... ( oui, vous avez remarque, c'est tout"
 dc.b " precalcule. )  Le graph vient d'un manga achete chez DEESSE, 8 rue Cochin, 75005 PARIS... Tout comme celui ci-dessous.         Ain't that cute, fellows?             Le logo Zappy vient d'un bouquin de Rodney Matthews appele In Search Of"
 dc.b " Forever.  L'idee du cube avec les textes dans les faces vient de la Elysium de Sanity. Pom pom.          THE FACE IN THE ABYSS:  ...un ecran pour lequel je me suis pas foule. J'ai pris 3 sources qui trainaient, je les ai mis bout-a-bout, "
 dc.b "j'ai rajoute quelques textes, j'ai assemble, et zou! Fini.    J'aime assez les rasters verticaux, meme s'ils commencent a dater. Le zoom est a chier, je trouve.  Enfin non, c'est sympa, sans plus.                     FLEXI-KILLER-SCROLLER:"
 dc.b " la 1ere version du FlexiScroller est TRES, TRES vieille. Elle a ete faite par Dan Nato juste apres la sortie de la DECADE DEMO de Inner Circle, dans laquelle etait presente le 1er flexiscroller. Mais comme Dan Nato est un gros flemmard "
 dc.b "( mais si, Laurent, tu es un flemmard, promis. Sans problemes. ) le flexi utilisait toujours la Line A apres 2 ans. Il fallait donc que quelqu'un reprenne tout a zero pour pouvoir avoir une version utilisable dans une demo, ou la Line A est "
 dc.b "exclue a partir du moment ou on reloge tout en $500.  Et devinez qui s'est tape tout le boulot, pour changer? Eh ben c'est moi, bien sur! Pfff. Un groupe de flemmards, je vous dis. J'en ai donc profite pour rajouter quelques petits"
 dc.b " trucs par ci par la, histoire d'enjoliver un peu les choses. Enfin bref.         DEVIL'S BALLS: n'existe que parce qu'il me restait quelques routines a utiliser, plus quelques gfxs. C'est un 'disk-filler', donc.    Certes, il y a de la"
 dc.b " 3D en full, mais bon... Faut le dire vite.           LIGHT SEEDS: paf! Encore un exemple frappant: Zerioul fait des routines de droites et de polygones. Et...? Ben rien, il ne les utilise pas. Qui c'est qui doit encore tout faire? Vous "
 dc.b "avez devine. Bon c'est pas un ecran genial, mais si vous saviez a quel point ca me gonfle de le modifier...   dans la derniere partie avec le Flexi-Scroller en 3 couleurs, appuyez donc sur les fleches du curseur... y'a quelques bugs"
 dc.b " dans cet ecran, mais"
 dc.b " vous n'allez pas chipoter.   Oh.   Faut pas pousser non plus.                 ATTACK OF INDIGESTION: un screen tres marrant, vous ne trouvez pas? Pour ceux qui seraient un peu stupides sur les bords, le titre suggere que des ecrans avec "
 dc.b "Megascrollers et/ou backgrounds a la TCB/ULM, on en a ras la banane. ON EN A TROP BOUFFE!  Alors merci, arretez d'en programmer.              AMBITION: le seul ecran entierement programme par Elric le nain.    Euh, oops.  Par Elric le"
 dc.b " Grand Sorcier.   Ahem.   Je ne me prononcerai pas a ce propos...            "
 dc.b " JAPANESE WAY OF LIFE: cet ecran, donc. Il doit contenir le seul scrolltext plus ou moins interessant dans toute la demo... Enfin interessant est un bien grand mot, mais par rapport aux autres scrolls de la demo, son emploi est tout-a-fait "
 dc.b "justifie. J'ai honte de le dire, mais le graph est de moi.  Inutile de vous dire que dessiner en full sur 6 PI1, c'est vraiment pas la joie. Notons quand meme que j'ai trouve le gfx original dans un bouquin d'Elric...   Comme quoi, les"
 dc.b " reputations..........                  Hihihi.                  Je vais me faire arracher les yeux avec une fourchette a huitres, moi, si je continue comme ca.      Ahahah!                "
 dc.b " Ah, je signale tout de meme que la musique est de JESS/OVERLANDERS. Voila, c'est fait.                     "
 dc.b " ...HIDDEN SCREENS...     hey hey...  puisque vous avez eu le courage d'attendre jusqu'ici ( enfin je ne me fais pas d'illusions, le scroll n'y est pour rien... )"
 dc.b " voila comment acceder aux Hidden Screens...   Il suffit de taper dans le menu soit: HOLOCAUST FOREVER, soit: I WANNA SEE IT.     Original, hein ?      "
 dc.b "Au fait, puisqu'on parle du menu... vous avez du remarquer qu'il etait... euh... sobre!   Oui, parce que je viens de recevoir la Snork, la. Ben le menu en 3D, ok, mais alors le temps qu'on attend entre chaque demo, pitie, non!    Moi je "
 dc.b "prefere avoir quelque chose de vraiment primaire au niveau code, et passer plus de temps sur les ecrans eux-memes qu'entre le menu et eux. ( Ce qui se passe dans la Snork....... )             "
 dc.b " Avec les menus Snorkiesques, on ne sait meme pas si on a pas par hasard oublie une demo ( ou un univers, carrement. )     La c'est clair et net, au moins.            "
 dc.b " Bon, assez parle de nous.          "
 dc.b "   Ca va finir par confiner a la pretention, tout ca.              "
 dc.b "   Moi, Zappy, de Holocaust, je vais maintenant distribuer allegrement quelques petits 'greetings'.     Pas envers Legacy ou TCB, nononon, eux ils en ont tout le temps. Je vais saluer mes copains que j'ai rencontre au fil de mes annees"
 dc.b " telematiques.  Vous ne devez pas les connaitre, donc.   Conclusion: vous pouvez presser ESPACE pour quitter maintenant, la suite ne va pas vous interesser...                       "
 dc.b " C'est parti!           Greetings to...       CUCKATOOS!  ...qui ne lira jamais ce texte, bien entendu, mais c'est pas grave. Il est tres sympa quand meme. Euh, dis... a propos. Je crois que j'ai encore ton bouquin de Douglas Adams...  "
 dc.b "   ...   Hehe. Ca fait loin, hein?           MEGA1!  Lui, par contre, il lira ce texte.    Enfin j'espere.    Embrasse Isa de ma part!           TOUBAB!  Aaah, Toubab... ...et ses data-disks pour FlapsII qui doivent encore trainer quelque "
 dc.b "part sur mon bureau...  Kookoo Toubab, j'espere que ca baigne pour toi!           SULLY!   Alors lui, pas de problemes, il ne verra jamais ce texte, donc je passe au suivant:         NCC 1701! Il y a peu de chances pour que ce cher NCC lise"
 dc.b " un jour un scroll de demo, mais bon. Il se laissera peut etre influencer par l'image?           VULPES! ...que je remercie car il m'a procure la version ST des Neuf Princes d'Ambre. Eh oui les jeunes! Ca existe en jeu sur ST!! Teste dans..."
 dc.b " Gen4 numero 1!          ROCKSTAR!  ...qui n'a pas donne de nouvelle de lui depuis un bon moment. Tant pis.          RICK(ST)!  A qui je dedicace le gfx ci-dessous, je suis sur qu'il aimera. Hehehe.           IO!  Bon, Julien, je craque, je"
 dc.b " te le dis: ton pseudo est vraiment nul. Mais c'est pas grave, y'a pire:             MED L'AVENTURIER!  Voila pire. ( C'est un copain de Rockstar. )  Mais non je plaisante, ils sont tres biens vos pseudos.               OXYGENE! Bon, toi, je"
 dc.b " t'ai fait assez de pub comme ca, ca suffit.          ELENDIR! Qui ne lira pas ce texte non plus. Zou!            DARKNESS! ...un copain du lycee...  je me demande si tu as deja demenage ou non. Faut que je te telephone, tiens. "
 dc.b "       PANZERBOY!  Un vrai, un pur, un dur...   pourquoi?   Parce qu'il joue a Chaos Strikes Back, bien sur!           SCARECROW! Qui habite Briancon, donc c'est un copain. Surtout qu'il connait Nevache, alors eh. ( Jamais vu un coin plus"
 dc.b " paume. Et dire que j'y passais mes vacances... )             KILLER D! ...que je ne vois plus sur Rtel/STMag, c'est bien dommage. Kid, tu as un caractere de cochon(ne), mais on s'y habitue tres bien, et apres ca manque. La vie est mal "
 dc.b "faite.         WATSIT! Qui m'a toujours donne de bons conseils en assembleur.            PIRATEAL!  Qui m'a aide a debuter en assembleur, et que je remercie grandement. Dommage qu'on ne le voie plus non plus.            WILL! ... que je"
 dc.b " vais me faire un plaisir de detruire publiquement, puisqu'il n'arrete pas de me gonfler en m'appelant Pizza... Will?  Hum? T'es la? Tu ecoutes, hein?  Ok: JE TE HAIS!   Voila, c'est tout, retourne dormir. ( Je rigole, bien entendu. )"
 dc.b " ( Inutile de s'enerver. ) ( Lache cette hache. ) ( Merci. )             IKI! Kookoo Iki! Ca roule? Merci pour les videos!           JINX! En voila un comme les vendeurs de Pin's: il a tout compris. Comment reussir a se faire du fric en"
 dc.b " vendant n'importe quoi. Hihihi. ( C'est l'auteur du DCK... )  Acheter un truc servant a faire des choses inutiles, ca, c'est intelligent. Hehe. Bravo, Jinx.               ZOCH! Que je ne connais pas trop, mais tant pis, salut quand meme!"
 dc.b "              ROBOCAMP! De Vmax. Quoi de neuf chez toi?              MARCO POLO! Euh... Ben j'ai rien de special a dire sur toi, desole. T'as du bol...           JUDAS/SLIDE NEUROX! Salut!                 NULLOS! Salut aussi!             "
 dc.b " OYA SHIVO! Salut encore!             SARAYAN! Quand est-ce que tu nous ponds un chef-d'oeuvre?                KHELT! Desole pour tes gfxs, mais on a du terminer la demo en 4eme vitesse, en fait...       ( Ce qui est la veritable excuse"
 dc.b " par rapport a la nullite absolue du main menu! )                  MAJOR FATAL! Salut... desole d'avoir critique 'Magic Rasters'. Mais j'aime pas, c'est comme ca! No hard feelings.             CREATEUR! Ti veux les sources? Ti demandes!  "
 dc.b "       BRAIN!  Que les 4 vents sement des fleurs sur son passage! Sans lui, je serais encore a me demander comment marche le DMA...                 R-BOY! Un grand swapper, si! Je lui enverrai la Choice Of Gods rien que pour qu'il la "
 dc.b "distribue!              Bon, c'est tout, stop, y'en a marre. J'ai oublie du monde, je sais, mais c'est comme ca, et pas autrement.  Ma bal est ouverte pour les reclamations.          De toute maniere je HAIS les listes de greetings, c'est "
 dc.b "vraiment LE truc bete et mechant quand on est en panne d'idee pour remplir un scroll.                        "
 dc.b "    Ah, j'y pense. Ca n'a rien a voir mais tant pis: allez plutot voir l'Arme Fatale 3 que Alien 3. ( Alien Cube, comme ils disent. )      Mon frere a vu Alien3, il parait que ca vaut meme pas le 2.          C'etait un conseil desinteresse. "
 dc.b "      Ah ben tant que j'y suis a donner des conseils, je vais vous recommander quelques bouquins... dans la serie Science-Fiction, je me permets de vous conseiller de lire la serie des NEUF PRINCES D'AMBRE. C'est de Roger Zelazny, chez Denoe"
 dc.b "l, il y a 9 volumes pour l'instant, et c'est absolument genialissime. C'est assez subjectif, comme avis, je sais. Mais toutes les personnes l'ayant lu sont du meme avis. Donc ca doit etre plus ou moins vrai. A en juger par les pseudos de"
 dc.b " certains connectes de Rtel ( Dara, Corwin, Dworkin, Oberon, Bleys, etc ), les fans sont deja tres nombreux. C'est une de mes sagas preferees, quoi qu'il en soit.     J'ai lu aussi la serie des Elric, je trouve ca beaucoup moins bien."
 dc.b " Ca devient vite lassant, Elric.  ( Je signale au passage que Elric-le-type-de-Holocaust n'a PAS lu Elric-la-serie-de-bouquins. C'est honteux. ) "
 dc.b " Quoi d'autre... Vance! Tres bien, Vance. La Geste des Princes-Demons, Les Chroniques de Durdane, etc: Vance ne m'a jamais decu. Miam!          Asimov, j'aime bien aussi, mais a plus petites doses. Ceci dit, lisez Fondation. On adore ou on"
 dc.b " deteste, mais ca ne laisse pas indifferent.   Moi j'adore.            Et puis alors evidemment, vous DEVEZ lire l'incontournable Guide du Routard Galactique de Douglas Adams!   J'ose esperer que c'est deja fait.   C'est dans cette trilogie"
 dc.b " que j'ai trouve mon pseudo, tout de meme. Enfin je dis trilogie, euh... enfin les connaisseurs m'ont compris.       Si vous ne connaissez pas du tout.... eh bien ma foi, reparez cette erreur au plus vite!    Je rappelle que dans ce bouquin,"
 dc.b " Zappy est le president du gouvernement imperial Galactique, et que sur les 10 annees de son mandat, il en a deja passe 2 en prison pour fraude. Zappy est pretentieux, flemmard, vaniteux, completement stupide, a ete elu 7 fois consecutives"
 dc.b " 'l'Etre le Plus Mal Fagote de Tout l'Univers Connu'"
 dc.b " et ne pense qu'a boire de"
 dc.b " l'arrache-boyaux pan-galactique, dont il est d'ailleurs l'inventeur. Zappy, dit 'le Grand Z', a egalement deux tetes et trois bras, je cite, 'pour ameliorer sa technique de boxe.'       Il est en tout cas completement malade.               "
 dc.b " Vous comprenez pourquoi j'ai pris ce pseudo. C'est tout-a-fait moi.    Ecoutez-moi ca:       "
 dc.b $22,"Il ( Zappy ) avait contemple l'immensite de l'Univers, s'etendant a l'infini tout autour de lui - dans sa totalite. Et avec elle etait venue l'extraordinaire et limpide certitude qu'il etait l'objet le plus important qui fut en son sein."
 dc.b " Posseder un moi vaniteux est une chose. Se voir confirmer par une machine le bien-fonde d'une telle attitude en est une autre.",$22
 dc.b "             J'adore.            Ca met tout de suite a l'aise. J'adore.                           ...                            "
 dc.b " Bon, ok,ok,ok, laissons tomber la SF.    Vous preferez 'Hasard et Chaos', l'excellent bouquin de David Ruelle ? Je suis d'accord, c'est bien aussi. Essayez aussi 'Un miroir turbulent' de Briggs et Peat... c'est moins technique, mais ca "
 dc.b "reste tres interessant. Rien que pour la fractale de couverture... Qui est assez wow.                  Bon bon ok, j'arrete.                      "
 dc.b " Vivement Octobre, que j'achete le nouveau XIII ( 'Pour Maria' ).  Dire qu'il faut attendre Novembre 93 pour le suivant! ( 'El Cascador' )            Gmblbl. Grompf.             "
 DC.B "  Quoi, j'aime bien XIII, j'ai le droit.         Mais ca ne veut rien dire, j'aime aussi Achille Talon, alors vous voyez.            Et puis Valerian. Et Thorgal, Blake et Mortimer, La quete de l'oiseau du temps, Hardboiled, et le reste.   "
 dc.b " Et Philemon. Sans oublier l'excellentissime Moebius. L'Incal, bien sur. John Difool, Zappy Bibicy, meme combat.   Hey hey.                        "
 dc.b " Lord, I've an idea!      Voila l'adresse d'une librairie tres bien: ca s'appelle IMPRESSIONS, 3 rue du marche, 95880 ENGHIEN.      Pour ceux qui habitent dans la banlieue nord, donc. Je leur fais de la pub, parce qu'ils sont tres sympas.  "
 dc.b " D'ailleurs, si vous habitez Enghien ou Montmorency, signalez-vous!  ( Moi j'habite Montmorency. )   "
 dc.b "  Sinon y'en a une pas mal pres de la place de la Nation.      ...       Vous vous en foutez?        "
 dc.b " Bon, d'accord, on oublie la BD.                   "
 dc.b " Tiens, je viens de recevoir la derniere demo d'Equinox/Keops ( 'Eat my Bollocks', merci Createur! ).  Je dois dire que j'admire.  Pas au point de vue technique ou design, non, restons serieux, mais personnellement j'aurais pas eu la force "
 dc.b "de me taper autant de trajectoires/transformations 3D. ( Vous voyez Light Seeds... AHEM! )        Ca merite un greeting, allez: kookookinox! kookookeops!                       "
 dc.b " Vivement la Froggies Over The Fence, tiens.                           "
 dc.b " Pour l'instant, je vais vous laisser.        Felicitations si vous avez tout lu.            Let's gloop!                           "
 dc.b "                                                                                    "
 dc.b "                                                                                    "
 dc.b "                                                                                    "
 DC.B "               ",$FF
	even
 
FONT8_8	
font:   	dc.l	$00000000,$00000000,$00181818,$18001800,$00666666 
	dc.l	$00000000,$0066FF66,$66FF6600,$183E603C,$067C1800 
	dc.l	$00666C18,$30664600,$1C361C38,$6F663B00,$00181818 
	dc.l	$00000000,$000E1C18,$181C0E00,$00703818,$18387000 
	dc.l	$00663CFF,$3C660000,$0018187E,$18180000,$00000000 
	dc.l	$00181830,$0000007E,$00000000,$00000000,$00181800 
	dc.l	$00060C18,$30604000,$003C666E,$76663C00,$00183818 
	dc.l	$18187E00,$003C660C,$18307E00,$007E0C18,$0C663C00 
	dc.l	$000C1C3C,$6C7E0C00,$007E607C,$06663C00,$003C607C 
	dc.l	$66663C00,$007E060C,$18303000,$003C663C,$66663C00 
	dc.l	$003C663E,$060C3800,$00001818,$00181800,$00001818 
	dc.l	$00181830,$060C1830,$180C0600,$00007E00,$007E0000 
	dc.l	$6030180C,$18306000,$003C660C,$18001800,$003C666E 
	dc.l	$6E603E00,$00183C66,$667E6600,$007C667C,$66667C00 
	dc.l	$003C6660,$60663C00,$00786C66,$666C7800,$007E607C 
	dc.l	$60607E00,$007E607C,$60606000,$003E6060,$6E663E00 
	dc.l	$0066667E,$66666600,$007E1818,$18187E00,$00060606 
	dc.l	$06663C00,$00666C78,$786C6600,$00606060,$60607E00 
	dc.l	$0063777F,$6B636300,$0066767E,$7E6E6600,$003C6666 
	dc.l	$66663C00,$007C6666,$7C606000,$003C6666,$666C3600 
	dc.l	$007C6666,$7C6C6600,$003C603C,$06063C00,$007E1818 
	dc.l	$18181800,$00666666,$66667E00,$00666666,$663C1800 
	dc.l	$0063636B,$7F776300,$0066663C,$3C666600,$0066663C 
	dc.l	$18181800,$007E0C18,$30607E00,$001E1818,$18181E00 
	dc.l	$00406030,$180C0600,$00781818,$18187800,$00081C36 
	dc.l	$63000000,$00000000,$0000FF00,$00183C7E,$7E3C1800 
	dc.l	$00003C06,$3E663E00,$0060607C,$66667C00,$00003C60 
	dc.l	$60603C00,$0006063E,$66663E00,$00003C66,$7E603C00 
	dc.l	$000E183E,$18181800,$00003E66,$663E067C,$0060607C 
	dc.l	$66666600,$00180038,$18183C00,$00060006,$0606063C 
	dc.l	$0060606C,$786C6600,$00381818,$18183C00,$0000667F 
	dc.l	$7F6B6300,$00007C66,$66666600,$00003C66,$66663C00 
	dc.l	$00007C66,$667C6060,$00003E66,$663E0606,$00007C66 
	dc.l	$60606000,$00003E60,$3C067C00,$00187E18,$18180E00 
	dc.l	$00006666,$66663E00,$00006666,$663C1800,$0000636B 
	dc.l	$7F3E3600,$0000663C,$183C6600,$00006666,$663E0C78 
	dc.l	$00007E0C,$18307E00,$00183C7E,$7E183C00,$18181818 
	dc.l	$18181818,$007E787C,$6E660600,$08183878,$38180800 
	even

DATA_HS
 DC.L H44,H44,H2,H2,H2,H80,H0,H0,H0
 DC.L H44,H44,H2,H2,H80,H0,H0,H0,H0
 DC.L H44,H44,H2,H80,H0,H0,H0,H0,H0
 DC.L H44,H44,H80,H0,H0,H0,H0,H0,H0
 DC.L H44,H24,H24,H2,H80,H0,H0,H0,H0
 DC.L H44,H24,H24,H80,H0,H0,H0,H0,H0
 DC.L H24,H2,H2,H2,H2,H2,H0,H0,H0
 DC.L H24,H2,H2,H2,H2,H0,H0,H0,H0
 DC.L H24,H2,H2,H2,H0,H0,H0,H0,H0
 DC.L H24,H2,H2,H0,H0,H0,H0,H0,H0
 DC.L H24,H2,H0,H0,H0,H0,H0,H0,H0
 DC.L H24,H0,H0,H0,H0,H0,H0,H0,H0
 DC.L H70,H44,H24,H24,H24,H80,H80,H0,H0
 DC.L H70,H44,H2,H2,H2,H80,H0,H0,H0
 DC.L H70,H44,H2,H2,H80,H0,H0,H0,H0
 DC.L H70,H44,H2,H80,H0,H0,H0,H0,H0
 DC.L H44,H2,H2,H2,H2,H2,H0,H0,H0
 DC.L H44,H2,H2,H2,H2,H0,H0,H0,H0
 DC.L H44,H2,H2,H2,H0,H0,H0,H0,H0
 DC.L H44,H2,H2,H0,H0,H0,H0,H0,H0
 DC.L H44,H2,H0,H0,H0,H0,H0,H0,H0
 DC.L H44,H0,H0,H0,H0,H0,H0,H0,H0
 DC.L H24,H24,H2,H0,H0,H0,H0,H0,H0
 DC.L H24,H24,H0,H0,H0,H0,H0,H0,H0
 DC.L H44,H44,H44,H2,H80,H0,H0,H0,H0
 DC.L H44,H44,H44,H80,H0,H0,H0,H0,H0
 DC.L H70,H70,H2,H2,H2,H80,H0,H0,H0
 DC.L H70,H70,H2,H2,H80,H0,H0,H0,H0
 DC.L H70,H70,H2,H80,H0,H0,H0,H0,H0
 DC.L H44,H24,H2,H2,H2,H2,H0,H0,H0
 DC.L H44,H24,H2,H2,H2,H0,H0,H0,H0
 DC.L H44,H24,H2,H2,H0,H0,H0,H0,H0
 DC.L H44,H24,H2,H0,H0,H0,H0,H0,H0
 DC.L H44,H24,H0,H0,H0,H0,H0,H0,H0
 DC.L H70,H0,H0,H0,H0,H0,H0,H0,H0
 DC.L H24,H24,H24,H0,H0,H0,H0,H0,H0
 DC.L H70,H44,H44,H2,H2,H80,H0,H0,H0
 DC.L H70,H44,H44,H2,H80,H0,H0,H0,H0
 DC.L H70,H44,H44,H80,H0,H0,H0,H0,H0
 DC.L H44,H24,H24,H2,H80,H70,H0,H0,H0
 DC.L H70,H44,H24,H24,H80,H0,H0,H0,H0
 DC.L H44,H44,H2,H2,H0,H0,H0,H0,H0
 DC.L H44,H44,H2,H0,H0,H0,H0,H0,H0
 DC.L H44,H44,H0,H0,H0,H0,H0,H0,H0
 DC.L H70,H24,H2,H2,H0,H0,H0,H0,H0
 DC.L H70,H24,H2,H0,H0,H0,H0,H0,H0
 DC.L H70,H24,H0,H0,H0,H0,H0,H0,H0
 DC.L H24,H24,H24,H24,H0,H0,H0,H0,H0
 DC.L H70,H70,H44,H2,H2,H2,H80,H0,H0
 DC.L H70,H70,H44,H2,H2,H80,H0,H0,H0
 DC.L H70,H70,H44,H2,H80,H0,H0,H0,H0
 DC.L H70,H44,H2,H2,H2,H2,H2,H0,H0
 DC.L H70,H44,H2,H2,H2,H2,H0,H0,H0
 DC.L H70,H44,H2,H2,H2,H0,H0,H0,H0
 DC.L H70,H44,H2,H2,H0,H0,H0,H0,H0
 DC.L H70,H44,H2,H0,H0,H0,H0,H0,H0
 DC.L H70,H44,H0,H0,H0,H0,H0,H0,H0
 DC.L H24,H24,H24,H24,H24,H2,H2,H0,H0
 DC.L H24,H24,H24,H24,H24,H2,H0,H0,H0
 DC.L H24,H24,H24,H24,H24,H0,H0,H0,H0
 DC.L H70,H44,H44,H44,H80,H0,H0,H0,H0
 DC.L H70,H70,H70,H2,H2,H2,H80,H0,H0
 DC.L H70,H70,H70,H2,H2,H80,H0,H0,H0
 DC.L H70,H70,H70,H2,H80,H0,H0,H0,H0
 DC.L H70,H44,H24,H2,H2,H2,H2,H0,H0
 DC.L H44,H44,H44,H0,H0,H0,H0,H0,H0
 DC.L H70,H44,H24,H2,H2,H0,H0,H0,H0
 DC.L H70,H44,H24,H2,H0,H0,H0,H0,H0
 DC.L H70,H44,H24,H0,H0,H0,H0,H0,H0
 DC.L H70,H70,H0,H0,H0,H0,H0,H0,H0
 DC.L H24,H24,H24,H70,H0,H0,H0,H0,H0
 DC.L H70,H70,H44,H44,H2,H2,H80,H0,H0
 DC.L H70,H70,H44,H44,H2,H80,H0,H0,H0
 DC.L H70,H70,H44,H44,H80,H0,H0,H0,H0
 DC.L H70,H70,H44,H24,H24,H2,H80,H0,H0
 DC.L H70,H44,H44,H2,H2,H2,H0,H0,H0
 DC.L H70,H44,H44,H2,H2,H0,H0,H0,H0
 DC.L H70,H44,H44,H2,H0,H0,H0,H0,H0
 DC.L H70,H44,H44,H0,H0,H0,H0,H0,H0
 DC.L H70,H70,H24,H2,H2,H0,H0,H0,H0
 DC.L H70,H70,H24,H2,H0,H0,H0,H0,H0
 DC.L H70,H70,H24,H0,H0,H0,H0,H0,H0
 DC.L H70,H24,H24,H24,H24,H0,H0,H0,H0
 DC.L H24,H24,H24,H24,H24,H24,H24,H0,H0
 DC.L H70,H70,H70,H44,H2,H2,H80,H0,H0
 DC.L H44,H44,H44,H44,H2,H2,H0,H0,H0
 DC.L H44,H44,H44,H44,H2,H0,H0,H0,H0
 DC.L H44,H44,H44,H44,H0,H0,H0,H0,H0
 DC.L H70,H70,H44,H2,H2,H2,H0,H0,H0
 DC.L H70,H70,H44,H2,H2,H0,H0,H0,H0
 DC.L H70,H70,H44,H2,H0,H0,H0,H0,H0
 DC.L H70,H70,H44,H0,H0,H0,H0,H0,H0
 DC.L H70,H44,H24,H24,H24,H0,H0,H0,H0
 DC.L H70,H70,H24,H24,H0,H0,H0,H0,H0
 DC.L H70,H70,H44,H44,H44,H80,H2,H0,H0
 DC.L H70,H70,H44,H44,H44,H80,H0,H0,H0
 DC.L H70,H70,H70,H44,H24,H2,H2,H80,H0
 DC.L H44,H44,H44,H44,H24,H2,H2,H0,H0
 DC.L H44,H44,H44,H44,H24,H2,H0,H0,H0
 DC.L H44,H44,H44,H44,H24,H0,H0,H0,H0
 DC.L H70,H44,H44,H44,H0,H0,H0,H0,H0
 DC.L H70,H70,H70,H2,H2,H2,H0,H0,H0
 DC.L H70,H70,H70,H2,H2,H0,H0,H0,H0
 DC.L H70,H70,H70,H2,H0,H0,H0,H0,H0
 DC.L H70,H70,H70,H0,H0,H0,H0,H0,H0
 DC.L H24,H70,H70,H24,H24,H0,H0,H0,H0
 DC.L H70,H24,H24,H24,H24,H24,H24,H0,H0
 DC.L H44,H44,H44,H44,H44,H2,H2,H0,H0
 DC.L H44,H44,H44,H44,H44,H2,H0,H0,H0
 DC.L H44,H44,H44,H44,H44,H0,H0,H0,H0
 DC.L H70,H70,H44,H44,H2,H2,H2,H0,H0
 DC.L H70,H70,H44,H44,H2,H2,H0,H0,H0
 DC.L H70,H70,H44,H44,H2,H0,H0,H0,H0
 DC.L H70,H70,H44,H44,H0,H0,H0,H0,H0
 DC.L H70,H44,H44,H24,H24,H24,H0,H0,H0
 DC.L H70,H70,H70,H24,H2,H0,H0,H0,H0
 DC.L H70,H70,H70,H24,H0,H0,H0,H0,H0
 DC.L H24,H24,H24,H24,H70,H70,H0,H0,H0
 DC.L H44,H44,H44,H44,H44,H24,H2,H2,H2
 DC.L H44,H44,H44,H44,H44,H24,H2,H2,H0
 DC.L H70,H44,H44,H44,H44,H2,H2,H0,H0
 DC.L H70,H44,H44,H44,H44,H2,H0,H0,H0
 DC.L H70,H44,H44,H44,H44,H0,H0,H0,H0
 DC.L H70,H44,H44,H44,H24,H24,H2,H0,H0
 DC.L H70,H70,H70,H44,H2,H2,H0,H0,H0
 DC.L H70,H70,H70,H44,H2,H0,H0,H0,H0
 DC.L H70,H70,H70,H44,H0,H0,H0,H0,H0
POINT	DC.L	0
BUF_LET	DCB.B	16,0

RIEN	REPT	9
	DC.L	H0
	ENDR

PART1	INCBIN	P1B.PI1
PART2	INCBIN	P2B.PI1
PART3	INCBIN	P3B.PI1
PART4	INCBIN	P4B.PI1
PART5	INCBIN	P5B.PI1
PART6	INCBIN	P6B.PI1
ZIK	INCBIN	RESET.MUS

PAL1	DC	$000,$037,$007,$004,$777,$600,$500,$400
	DC	$210,$421,$532,$643,$754,$765,$213,$212

PAL2	DC	$000,$734,$623,$512,$777,$412,$301,$324
	DC	$210,$421,$532,$643,$754,$765,$213,$212
 	SECTION BSS

F_PILE	DS.L 	128	
D_PILE	DS.L 	1	
POIT	DS.L	1
SCREEN1	DS.L	1
SCREEN2	DS.L	1
	DS.B	256
BUFFERSCR	DS.B	64000*2
