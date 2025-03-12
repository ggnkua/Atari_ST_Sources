	OPT	O+
	OUTPUT	a:NORTH.PRG
FINAL = 1
DEBUG = 1
PLAN3D = 3
PLANSCROLL = 2
;
; dans le cas d'une droite presque horizontale,
;  le ADD aprŠs le SUB a 1 chance sur 2.5 d'etre ex‚cut‚
;  (statistique sur les 9 objets)
;
ABS_DRAW	EQU	$800
;
; AMELIORATIONS A APPORTER :
;	- CALCULER LE MAXIMUM D'ECRANS EN MEMOIRE (8 ???)
;	   ET COMMUTER LES ECRANS EN VBL PENDANT CALCUL !!!
;	- OPTIMISER EFFACEMENT EN N'EFFACANT QUE CE QUI EST REMPLI
;	   PAR LE PROGRAMME APRES 1 HEURE DE DEMO
;	- F1,F2... ROTATION DE L'OBJET
;	- 1-9 CHANGEMENT DE L'OBJET
;	- CALCUL PSEUDO MULTITACHE DU CHANGEMENT DE L'OBJET
;	   (calcul incr‚mental)
;	- ENLEVER SOUS-PROGRAMMES
;	- AMELIORER CALCUL SINUS/COSINUS
;	- ROUTINES DRAW VERTICAL ET HORIZONTAL
;
;
CPU	MACRO
	IFNE	FINAL
	CMP.B	#$F,$FFFFFC02.W		;TAB ??
	BNE.S	\@
	MOVE	#\1,$FFFF8240.W
\@
	ENDC
	ENDM
;NBSEG	EQU	$108		;264 SEGMENTS
NBPTS	EQU	$90		;9*16=144 POINTS
XMILIEU	EQU	160
YMILIEU	EQU	100
NBLIGNES	EQU	165	;NB LIGNES A AFFICHER AU TOTAL
NBCOLS		EQU	192	;NB PIXELS DE LARGEUR
;
; VALEUR MAXIMALE DE DELTAX: $29
; VALEUR MAXIMALE DE DELTAY: $27
;
ECRAN0	EQU	$70000		;ECRAN 0
ECRAN1	EQU	$78000		;ECRAN 1
;
	OFFSET	$800+12000
STARTOFF
SYNC	DS.W	1
ECRAN	DS.L	1
L2D1B4	DS.W	3*NBPTS
L2D514	DS.W	3*NBPTS
L18	DS.W	9

L44	DS.L	NBPTS		;COORDONNEES X ET Y
	DS.W	10
MULY	DS.W	NBLIGNES+10	;BUFFER OFFSETS ECRAN
NEW	DS.B	9
lastkey:ds.b	1
	EVEN
;
; variables pour scroller
;
LASTECRAN:DS.L	1
CURTEXT:DS.L	1
SHIFT1:	DS.W	1
L5E9A:	DS.W	1
BUFSCR:	DS.L	1
L5EA6:	DS.W	1
LETTRE1:DS.L	1
LETTRE2:DS.L	1
PTRTXT:	DS.L	1

ENDOFF
	SECTION	TEXT
;
	IFNE	FINAL
	MOVE	SR,D0
	AND	#$2000,D0
	BNE.S	SUPER
	CLR.L	-(SP)
	MOVE	#$20,-(SP)
	TRAP	#1
	ADDQ	#6,SP
SUPER:
	MOVE	#$2700,SR
	MOVEM.L	MOVER(PC),D0-D7
	MOVEM.L	D0-D7,-(SP)
	LEA	CODE(PC),A0
	LEA	$8000,A1
	MOVE	#65536/4-1,D0
	JMP	(SP)
MOVER:
.MOVE	MOVE.L	(A0)+,(A1)+
	DBRA	D0,.MOVE
	JMP	$8000
CODE:
	ORG	$8000
	ENDC

	MOVE	#$2700,SR

	MOVEQ	#0,D0
	MOVE.L	D0,A0
	MOVEP.L	D0,$FFFFFA01(A0)
	MOVEP.L	D0,$FFFFFA09(A0)
	MOVEP.L	D0,$FFFFFA11(A0)
	MOVEP.L	D0,$FFFFFA19(A0)

	IFEQ	DEBUG
	LEA	ECRAN0,SP
	jsr	initreset
	ENDC

	LEA	DRAW_IT,A0
	LEA	ABS_DRAW.W,A1
	LEA	ENDDRAW,A2
MOVEIT	MOVE	(A0)+,(A1)+
	CMP.L	A2,A0
	BLO.S	MOVEIT
	LEA	-6(A1),A7		;NOUVEAU POINTEUR DE PILE !!!

.CLEARALL
	CLR.L	(A1)+
	CMP.L	#ENDOFF,A1
	BLO.S	.CLEARALL

	moveq	#8,d0
	bsr	INITMUSIC

	BSR	INITSCROLL
	MOVE.L	#ECRAN1,LASTECRAN\W
	MOVE.L	#ECRAN0,ECRAN\W

	LEA	ECRAN0,A0
	MOVE	#($80000-ECRAN0)/8-1,D0
	MOVEQ	#0,D2
BIGCLS:	MOVE.L	D2,(A0)+
	MOVE.L	D2,(A0)+
	DBRA	D0,BIGCLS
;
; INSTALLATION DES COULEURS
;
	LEA	ECRAN0+(200-TAILLE)*160,A0
	LEA	ECRAN1+(200-TAILLE)*160,A1
	LEA	ECRAN0+199*160,A2
	LEA	ECRAN1+199*160,A3
	MOVEQ	#0,D7
.SETCOL
	MOVE	D7,D0
	LSR	#1,D0
	SUBX.L	D1,D1
	LSR	#1,D0
	SUBX	D1,D1
	MOVEQ	#0,D2
	MOVEQ	#160/8-1,D0
.FILL	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A1)+
	MOVE.L	D2,(A0)+
	MOVE.L	D2,(A1)+
	MOVE.L	D2,-(A2)
	MOVE.L	D2,-(A3)
	MOVE.L	D1,-(A2)
	MOVE.L	D1,-(A3)
	DBRA	D0,.FILL

	ADDQ	#1,D7
	AND	#3,D7
	BNE.S	.SETCOL

	MOVE.L	#VBL2,$70.W
	MOVE	#$2300,SR
	CLR	SYNC\W
WAITSYNC
	TST	SYNC\W
	BEQ.S	WAITSYNC
	CLR.B	$FFFF8260.W
	MOVE.B	#2,$FFFF820A.W
	movem.l	palette,d0-d7
	movem.l	d0-d7,$ffff8240.w

	MOVE.L	#VBL,$70.W
;
; PRECALCULE LA TABLE DE MULTIPLICATION
;
; PRECALCUL DE LA BIG TABLE DE MUL
;
; ACCELERATION : LE POIDS FAIBLE EST TOUJOURS PAIR...
;
	LEA	L48000,A0
	CLR	D0
	CLR	D1
	clr	d4
L2CCD8
	MOVE	D0,D2
	MULS	D1,D2
	asr	#7,D2
	EXT	D2
	MOVE	D2,(A0,D4.W)
	addq	#2,d4
	ADDQ.B	#2,D1
	EXT	D1
	BNE.S	L2CCD8
	ADDQ.B	#1,D0
	EXT	D0
	BNE.S	L2CCD8
;
; PRECALCULE LES OFFSETS ECRAN
;
	LEA	MULY\W,A0
	MOVE	#NBLIGNES-1,D0
	MOVEQ	#NBCOLS/16,D1
L2CDDE	MOVE	D1,(A0)+
	ADD	#NBCOLS/8,D1
	DBF	D0,L2CDDE
	MOVEQ	#2-1,D0
	LEA	MULY\W,A1
1$	MOVE	D1,(A0)+	;POUR TAPER DANS LE CODE !!!
	MOVE	D1,-(A1)
	DBRA	D0,1$
;
; PRECALCUL DE TOUS LES Z POSSIBLES
;
	MOVE	#$FA+$16,D0
	LEA	L5E000,A0
L2CB6A	MOVE.L	#$7CFF06,D1
	DIVS	D0,D1
	MOVE	D1,(A0)+
	ADDQ	#1,D0
	CMP.L	#FIN5E000,A0
	BLO.S	L2CB6A

Y3D = 35/2
;
; g‚nŠre la recopie d'‚cran 3D
;
genscroll:
	lea	recopie,a0
	move	#Y3D*160+32+PLAN3D*2,d6
	move	#NBLIGNES-1,d7
.copy
	move	d6,d5
	moveq	#12-1,d4
.col
	move	#$3358,(a0)+	;move (a0)+,d(a1)
	move	d5,(a0)+
	addq	#8,d5
	dbra	d4,.col
	add	#160,d6
	dbra	d7,.copy

	move	#$4ED2,(a0)+
	cmp.l	#finrecopie,a0
	beq.s	.ok
	illegal
.ok
BOUCLE
	CLR	SYNC\W
;
; EFFACEMENT DE L'ECRAN
;
	MOVE.L	#RETR,$80.W
	MOVEQ	#0,D0
	MOVE.L	D0,D1
	MOVE.L	D0,D2
	MOVE.L	D0,D3
	MOVE.L	D0,D4
	MOVE.L	D0,D5
	MOVE.L	D0,D6
	MOVE.L	D0,D7
	MOVE.L	D0,A0
	MOVE.L	D0,A1
	MOVE.L	D0,A2
	MOVE.L	D0,A3
	MOVE.L	D0,A4
	MOVE.L	D0,A5
	MOVE.L	D0,A6

	MOVE	#$300,SR
	LEA	END_OF_BITPLANE,SP
X	SET	0
	REPT	NBCOLS/8*NBLIGNES/60
	MOVEM.L	D0-D7/A0-A6,-(SP)
X	SET	X+60
	ENDR

	IFNE	X-NBCOLS/8*NBLIGNES
	LIST
	DC.L	NBCOLS/8*NBLIGNES-X
	FAIL
	ENDC

	TRAP	#0
;
; CHANGE LES TRAJECTOIRES DES POINTS
;
; LA ROUTINE SUIVANTE EST PRATIQUEMENT OPTIMALE
;  (ON PEUT GAGNER AVEC UN SUBQ AU LIEU D'UN ADDQ)
;
	LEA	L2D874(PC),A3
	ADDQ	#1,(A3)
	CMP	#$C0,(A3)
	BEQ	L2D8F4
	CMP	#$80,(A3)
	BHS	L2D904
	LEA	L2D1B4\W,A1
	LEA	L2D514\W,A2
;
; LA ROUTINE SUIVANTE INTRODUIT UNE LEGERE DISTORTION
;   INDECELABLE A L'OEIL !!
;
	REPT	NBPTS*3/16
	MOVEM.L	(A1)+,D0-D7
	ADD.L	D0,(A2)+
	ADD.L	D1,(A2)+
	ADD.L	D2,(A2)+
	ADD.L	D3,(A2)+
	ADD.L	D4,(A2)+
	ADD.L	D5,(A2)+
	ADD.L	D6,(A2)+
	ADD.L	D7,(A2)+
	ENDR
	BRA	L2D904
L2D8F4	CLR	(A3)
	MOVE.L	L2D877(PC),A0
	MOVE.L	(A0)+,D0
	BNE.S	L2D8C2
	LEA	L2D87A(PC),A0
	MOVE.L	(A0)+,D0
L2D8C2
	MOVE.L	A0,L2D877
	MOVE.L	D0,A0
	LEA	L2D514\W,A2
	LEA	L2D1B4\W,A1
;
; L'EXTENSION APRES ADDITION NE MARCHE PAS...
;
x	set	0
	REPT	NBPTS*3
	MOVE.B	(A0)+,D1
	EXT	D1
	MOVE.B	x(A2),D2
	EXT	D2
	SUB	D2,D1
	ADD	D1,D1
	MOVE	D1,(A1)+
x	set	x+2
	ENDR
L2D904

NXTANG	MACRO
	ADD.B	\1(PC),D0
	MOVE.B	D0,\1
	ADD	D0,D0
	ADD	D0,D0
	MOVEM	(A0,D0.W),\2
	ENDM
;
; CALCUL DE LA MATRICE CONSTANTE DE PROJECTION
;
; CHANGE L'ANGLE DE ROTATION ET CALCULE LES SINUS ET COSINUS ASSOCIES
;
; SX=SIN/COS ANGLE X,SY=SIN/COS ANGLE Y,SZ=SIN/COS ANGLE Z
; ROTX,ROTY,ROTZ=ANGLES COURANTS
;
SX	EQUR	D2
CX	EQUR	D3
SY	EQUR	D4
CY	EQUR	D5
SZ	EQUR	D6
CZ	EQUR	D7

	LEA	SINCOS(PC),A0
	MOVEQ	#2,D0
	NXTANG	ROTX,SX/CX	;SX
	MOVEQ	#1,D0
	NXTANG	ROTY,SY/CY	;SY
	MOVEQ	#3,D0
	NXTANG	ROTZ,SZ/CZ	;SZ
;
; CALCULE LA MATRICE DE PROJECTION
;
	LEA	L18\W,A0

	MOVE	CY,D0
	MULS	CZ,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(A0)+

	MOVE	SY,(A0)+

	MOVE	CY,D0
	MULS	SZ,D0
	ADD.L	D0,D0
	SWAP	D0
	NEG	D0
	MOVE	D0,(A0)+

	MOVE	SX,D1
	MULS	SZ,D1
	MOVE	CX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	CZ,D0
	SUB.L	D0,D1
	ADD.L	D1,D1
	SWAP	D1
	MOVE	D1,(A0)+

	MOVE	CX,D0
	MULS	CY,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(A0)+	;$10

	MOVE	SX,D1
	MULS	CZ,D1
	MOVE	CX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	SZ,D0
	ADD.L	D1,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(A0)+	;$14

	MOVE	CX,D1
	MULS	SZ,D1
	MOVE	SX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	CZ,D0
	ADD.L	D1,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(A0)+	;$18

	MOVE	SX,D0
	MULS	CY,D0
	ADD.L	D0,D0
	SWAP	D0
	NEG	D0
	MOVE	D0,(A0)+	;$1C

	MOVE	CX,D1
	MULS	CZ,D1
	MOVE	SX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	SZ,D0
	SUB.L	D0,D1
	ADD.L	D1,D1
	SWAP	D1
	MOVE	D1,(A0)+	;$20
;
; REAJUSTEMENT POUR ROUTINE DE DRAW
;
	LEA	NEW\W,A4
x	SET	0
	REPT	9
	MOVEQ	#-2,D0
	AND.B	L18+x\W,D0
	MOVE.B	D0,(A4)+
x	SET	x+2
	ENDR
;
; CALCUL OPTIMISE DES POINTS PROJETES
;
	LEA	L44\W,A0
	LEA	L2D514\W,A2
	LEA	L48000,A3
	LEA	L5E000+$80*2,A5
	LEA	NEW\W,A6
;
; REGISTRES UTILISES :
;	A0-A6 SAUF A1
;	A2 PEUT ETRE LIBERE
;
; 	D1-D7 SAUF D4
;
; registres libres :
;
;	A1,D0,D4
;
FAST	MACRO
	MOVE.B	(A4)+,\1
	MOVE	(A3,\1.W),\2
	ENDM

ADDFAST	MACRO
	MOVE.B	(A4)+,\1
	ADD	(A3,\1.W),\2
	ENDM

	REPT	NBPTS
	MOVE.L	A6,A4
	MOVEM	(A2)+,D1/D2/D3

	FAST	D1,D6		;Y
	ADDFAST	D2,D6
	ADDFAST	D3,D6

	FAST	D1,D7		;X
	ADDFAST	D2,D7
	ADDFAST	D3,D7

	FAST	D1,D5		;Z
	ADDFAST	D2,D5
	ADDFAST	D3,D5

	ADD	D5,D5
	MOVE	(A5,D5.W),D5
	MULS	D5,D7
	MULS	D5,D6

	ADD.L	D7,D7
	ADD.L	D6,D6
	SWAP	D6
	MOVE	D6,D7

	MOVE.L	D7,(A0)+
	ENDR
;
; TRACAGE DES SEGMENTS
;
DRAW	MACRO
	IFEQ	\2-\1-1
	MOVEM	(L44-4+\1*4).W,D0-D3
	ELSEIF
	MOVEM	(L44-4+\1*4).W,D0/D1
	MOVEM	(L44-4+\2*4).W,D2/D3
	ENDC
	LEA	\@(PC),A6
	JMP	(A5)
\@
	ENDM
L2CDEA
	LEA	MULY+80*2\W,A1		;Y minimum=-80 !!!
	LEA	BITPLANE,A0
	MOVE.L	A0,USP
	LEA	ABS_DRAW+$B2\W,A5
	MOVE	#$4ED7,D6		;=JMP (A7)
;
; A2 LIBRE !!!
;
	CMP.B	#$62,lastkey\w	;HELP
	BEQ	F1
	DRAW	1,2
	DRAW	2,3
	DRAW	3,4
	DRAW	4,5
	DRAW	5,6
	DRAW	6,7
	DRAW	7,8
	DRAW	8,9
	DRAW	9,$A
	DRAW	$A,$B
	DRAW	$B,$C
	DRAW	$D,$E
	DRAW	$E,$F
	DRAW	$F,$10
	DRAW	$10,$11
	DRAW	$11,$12
	DRAW	$12,$13
	DRAW	$13,$14
	DRAW	$14,$15
	DRAW	$15,$16
	DRAW	$16,$17
	DRAW	$17,$18
	DRAW	$19,$1A
	DRAW	$1A,$1B
	DRAW	$1B,$1C
	DRAW	$1C,$1D
	DRAW	$1D,$1E
	DRAW	$1E,$1F
	DRAW	$1F,$20
	DRAW	$20,$21
	DRAW	$21,$22
	DRAW	$22,$23
	DRAW	$23,$24
	DRAW	$25,$26
	DRAW	$26,$27
	DRAW	$27,$28
	DRAW	$28,$29
	DRAW	$29,$2A
	DRAW	$2A,$2B
	DRAW	$2B,$2C
	DRAW	$2C,$2D
	DRAW	$2D,$2E
	DRAW	$2E,$2F
	DRAW	$2F,$30
	DRAW	$31,$32
	DRAW	$32,$33
	DRAW	$33,$34
	DRAW	$34,$35
	DRAW	$35,$36
	DRAW	$36,$37
	DRAW	$37,$38
	DRAW	$38,$39
	DRAW	$39,$3A
	DRAW	$3A,$3B
	DRAW	$3B,$3C
	DRAW	$3D,$3E
	DRAW	$3E,$3F
	DRAW	$3F,$40
	DRAW	$40,$41
	DRAW	$41,$42
	DRAW	$42,$43
	DRAW	$43,$44
	DRAW	$44,$45
	DRAW	$45,$46
	DRAW	$46,$47
	DRAW	$47,$48
	DRAW	$49,$4A
	DRAW	$4A,$4B
	DRAW	$4B,$4C
	DRAW	$4C,$4D
	DRAW	$4D,$4E
	DRAW	$4E,$4F
	DRAW	$4F,$50
	DRAW	$50,$51
	DRAW	$51,$52
	DRAW	$52,$53
	DRAW	$53,$54
;	CMP.B	#$3D,key\w	;F3 ?
;	BEQ	F3
	DRAW	$55,$56
	DRAW	$56,$57
	DRAW	$57,$58
	DRAW	$58,$59
	DRAW	$59,$5A
	DRAW	$5A,$5B
	DRAW	$5B,$5C
	DRAW	$5C,$5D
	DRAW	$5D,$5E
	DRAW	$5E,$5F
	DRAW	$5F,$60
	DRAW	$61,$62
	DRAW	$62,$63
	DRAW	$63,$64
	DRAW	$64,$65
	DRAW	$65,$66
	DRAW	$66,$67
	DRAW	$67,$68
	DRAW	$68,$69
	DRAW	$69,$6A
	DRAW	$6A,$6B
	DRAW	$6B,$6C
	DRAW	$6D,$6E
	DRAW	$6E,$6F
	DRAW	$6F,$70
	DRAW	$70,$71
	DRAW	$71,$72
	DRAW	$72,$73
	DRAW	$73,$74
	DRAW	$74,$75
	DRAW	$75,$76
	DRAW	$76,$77
	DRAW	$77,$78
	DRAW	$79,$7A
	DRAW	$7A,$7B
	DRAW	$7B,$7C
	DRAW	$7C,$7D
	DRAW	$7D,$7E
	DRAW	$7E,$7F
	DRAW	$7F,$80
	DRAW	$80,$81
	DRAW	$81,$82
	DRAW	$82,$83
	DRAW	$83,$84
	DRAW	$85,$86
	DRAW	$86,$87
	DRAW	$87,$88
	DRAW	$88,$89
	DRAW	$89,$8A
	DRAW	$8A,$8B
	DRAW	$8B,$8C
	DRAW	$8C,$8D
	DRAW	$8D,$8E
	DRAW	$8E,$8F
	DRAW	$8F,$90
	CMP.B	#$61,lastkey\w	;UNDO
	BEQ	F2
F1:	DRAW	1,$D
	DRAW	$D,$19
	DRAW	$19,$25
	DRAW	$25,$31
	DRAW	$31,$3D
	DRAW	$3D,$49
	DRAW	$49,$55
	DRAW	$55,$61
	DRAW	$61,$6D
	DRAW	$6D,$79
	DRAW	$79,$85
	DRAW	2,$E
	DRAW	$E,$1A
	DRAW	$1A,$26
	DRAW	$26,$32
	DRAW	$32,$3E
	DRAW	$3E,$4A
	DRAW	$4A,$56
	DRAW	$56,$62
	DRAW	$62,$6E
	DRAW	$6E,$7A
	DRAW	$7A,$86
	DRAW	3,$F
	DRAW	$F,$1B
	DRAW	$1B,$27
	DRAW	$27,$33
	DRAW	$33,$3F
	DRAW	$3F,$4B
	DRAW	$4B,$57
	DRAW	$57,$63
	DRAW	$63,$6F
	DRAW	$6F,$7B
	DRAW	$7B,$87
	DRAW	4,$10
	DRAW	$10,$1C
	DRAW	$1C,$28
	DRAW	$28,$34
	DRAW	$34,$40
	DRAW	$40,$4C
	DRAW	$4C,$58
	DRAW	$58,$64
	DRAW	$64,$70
	DRAW	$70,$7C
	DRAW	$7C,$88
	DRAW	5,$11
	DRAW	$11,$1D
	DRAW	$1D,$29
	DRAW	$29,$35
	DRAW	$35,$41
	DRAW	$41,$4D
	DRAW	$4D,$59
	DRAW	$59,$65
	DRAW	$65,$71
	DRAW	$71,$7D
	DRAW	$7D,$89
	DRAW	6,$12
	DRAW	$12,$1E
	DRAW	$1E,$2A
	DRAW	$2A,$36
	DRAW	$36,$42
	DRAW	$42,$4E
	DRAW	$4E,$5A
	DRAW	$5A,$66
	DRAW	$66,$72
	DRAW	$72,$7E
	DRAW	$7E,$8A
	DRAW	7,$13
	DRAW	$13,$1F
	DRAW	$1F,$2B
	DRAW	$2B,$37
	DRAW	$37,$43
	DRAW	$43,$4F
	DRAW	$4F,$5B
	DRAW	$5B,$67
	DRAW	$67,$73
	DRAW	$73,$7F
	DRAW	$7F,$8B
	DRAW	8,$14
	DRAW	$14,$20
	DRAW	$20,$2C
	DRAW	$2C,$38
	DRAW	$38,$44
	DRAW	$44,$50
	DRAW	$50,$5C
	DRAW	$5C,$68
	DRAW	$68,$74
	DRAW	$74,$80
	DRAW	$80,$8C
	DRAW	9,$15
	DRAW	$15,$21
	DRAW	$21,$2D
	DRAW	$2D,$39
	DRAW	$39,$45
	DRAW	$45,$51
	DRAW	$51,$5D
	DRAW	$5D,$69
	DRAW	$69,$75
	DRAW	$75,$81
	DRAW	$81,$8D
	DRAW	$A,$16
	DRAW	$16,$22
	DRAW	$22,$2E
	DRAW	$2E,$3A
	DRAW	$3A,$46
	DRAW	$46,$52
	DRAW	$52,$5E
	DRAW	$5E,$6A
	DRAW	$6A,$76
	DRAW	$76,$82
	DRAW	$82,$8E
	DRAW	$B,$17
	DRAW	$17,$23
	DRAW	$23,$2F
	DRAW	$2F,$3B
	DRAW	$3B,$47
	DRAW	$47,$53
	DRAW	$53,$5F
	DRAW	$5F,$6B
	DRAW	$6B,$77
	DRAW	$77,$83
	DRAW	$83,$8F
	DRAW	$C,$18
	DRAW	$18,$24
	DRAW	$24,$30
	DRAW	$30,$3C
	DRAW	$3C,$48
	DRAW	$48,$54
	DRAW	$54,$60
	DRAW	$60,$6C
	DRAW	$6C,$78
	DRAW	$78,$84
	DRAW	$84,$90
F2:
F3:

	CPU	$700
;
; RECOPIE DE L'ECRAN
;
	LEA	BITPLANE,A0
	MOVE.L	ECRAN\W,A1
	LEA	.RET(PC),A2
	JMP	recopie
.RET
	MOVE.L	ECRAN\W,D0	;CHANGE L'ADRESSE ECRAN
	MOVE.L	D0,LASTECRAN\W
	LSR	#8,D0
	MOVE.L	D0,$FFFF8200.W
	EOR.L	#ECRAN0^ECRAN1,ECRAN\W
	CPU	$007
WSYNC
	CMP	#2,SYNC\W
	BLO.S	WSYNC
	CLR	$FFFF8240.W
	BRA	BOUCLE
VBL:
	movem.l	d0-d7/a0-a6,-(sp)

	clr	d0
	move.b	$fffffc02.w,d0
	cmp.b	lastkey.w,d0
	beq.s	.samekey
	move.b	d0,lastkey.w
	sub.b	#$3b,d0
	cmp.b	#8,d0
	bhs.s	.samekey
	addq.b	#1,d0
	bsr	INITMUSIC
	bra.s	.finvb
.samekey:
	bsr	PLAYMUSIC
.finvb
	MOVE.L	LASTECRAN\W,A2
	BSR	SCROLLER
	movem.l	(sp)+,d0-d7/a0-a6
VBL2:
	ADDQ	#1,SYNC\W
	RTE

RETR:	RTR			;ASTUCE POUR MODE SUPERVISEUR RAPIDE

L2D874	DC.W	$BF
L2D877	DC.L	FSTOBJ
L2D87A	DC.L	OBJ6
	DC.L	OBJ4
	DC.L	OBJ2
	DC.L	OBJ1
	DC.L	OBJ4
	DC.L	OBJ3
	DC.L	OBJ5
	DC.L	OBJ4
FSTOBJ	DC.L	OBJ1
	DC.L	0
;
; ANGLES DE ROTATION, ETC...
;
ROTX	DC.B	$20
ROTY	DC.B	$20
ROTZ	DC.B	$20
	EVEN

SINCOS		;TABLE DE SINUS/COSINUS
	dc.w	$0,$7FFF,$324,$7FF5,$647,$7FD7,$96A,$7FA6
	dc.w	$C8B,$7F61,$FAB,$7F08,$12C7,$7E9C,$15E1,$7E1C
	dc.w	$18F8,$7D89,$1C0B,$7CE2,$1F19,$7C29,$2223,$7B5C
	dc.w	$2527,$7A7C,$2826,$7989,$2B1E,$7883,$2E10,$776B
	dc.w	$30FB,$7640,$33DE,$7503,$36B9,$73B5,$398C,$7254
	dc.w	$3C56,$70E1,$3F16,$6F5E,$41CD,$6DC9,$447A,$6C23
	dc.w	$471C,$6A6C,$49B3,$68A5,$4C3F,$66CE,$4EBF,$64E7
	dc.w	$5133,$62F1,$539A,$60EB,$55F4,$5ED6,$5842,$5CB3
	dc.w	$5A81,$5A81,$5CB3,$5842,$5ED6,$55F4,$60EB,$539A
	dc.w	$62F1,$5133,$64E7,$4EBF,$66CE,$4C3F,$68A5,$49B3
	dc.w	$6A6C,$471C,$6C23,$447A,$6DC9,$41CD,$6F5E,$3F16
	dc.w	$70E1,$3C56,$7254,$398C,$73B5,$36B9,$7503,$33DE
	dc.w	$7640,$30FB,$776B,$2E10,$7883,$2B1E,$7989,$2826
	dc.w	$7A7C,$2527,$7B5C,$2223,$7C29,$1F19,$7CE2,$1C0B
	dc.w	$7D89,$18F8,$7E1C,$15E1,$7E9C,$12C7,$7F08,$FAB
	dc.w	$7F61,$C8B,$7FA6,$96A,$7FD7,$647,$7FF5,$324
	dc.w	$7FFF,$0,$7FF5,$FCDB,$7FD7,$F9B8,$7FA6,$F695
	dc.w	$7F61,$F374,$7F08,$F054,$7E9C,$ED38,$7E1C,$EA1E
	dc.w	$7D89,$E707,$7CE2,$E3F4,$7C29,$E0E6,$7B5C,$DDDC
	dc.w	$7A7C,$DAD8,$7989,$D7D9,$7883,$D4E1,$776B,$D1EF
	dc.w	$7640,$CF04,$7503,$CC21,$73B5,$C946,$7254,$C673
	dc.w	$70E1,$C3A9,$6F5E,$C0E9,$6DC9,$BE32,$6C23,$BB85
	dc.w	$6A6C,$B8E3,$68A5,$B64C,$66CE,$B3C0,$64E7,$B140
	dc.w	$62F1,$AECC,$60EB,$AC65,$5ED6,$AA0B,$5CB3,$A7BD
	dc.w	$5A81,$A57E,$5842,$A34C,$55F4,$A129,$539A,$9F14
	dc.w	$5133,$9D0E,$4EBF,$9B18,$4C3F,$9931,$49B3,$975A
	dc.w	$471C,$9593,$447A,$93DC,$41CD,$9236,$3F16,$90A1
	dc.w	$3C56,$8F1E,$398C,$8DAB,$36B9,$8C4A,$33DE,$8AFC
	dc.w	$30FB,$89BF,$2E10,$8894,$2B1E,$877C,$2826,$8676
	dc.w	$2527,$8583,$2223,$84A3,$1F19,$83D6,$1C0B,$831D
	dc.w	$18F8,$8276,$15E1,$81E3,$12C7,$8163,$FAB,$80F7
	dc.w	$C8B,$809E,$96A,$8059,$647,$8028,$324,$800A
	dc.w	$0,$8001,$FCDB,$800A,$F9B8,$8028,$F695,$8059
	dc.w	$F374,$809E,$F054,$80F7,$ED38,$8163,$EA1E,$81E3
	dc.w	$E707,$8276,$E3F4,$831D,$E0E6,$83D6,$DDDC,$84A3
	dc.w	$DAD8,$8583,$D7D9,$8676,$D4E1,$877C,$D1EF,$8894
	dc.w	$CF04,$89BF,$CC21,$8AFC,$C946,$8C4A,$C673,$8DAB
	dc.w	$C3A9,$8F1E,$C0E9,$90A1,$BE32,$9236,$BB85,$93DC
	dc.w	$B8E3,$9593,$B64C,$975A,$B3C0,$9931,$B140,$9B18
	dc.w	$AECC,$9D0E,$AC65,$9F14,$AA0B,$A129,$A7BD,$A34C
	dc.w	$A57E,$A57E,$A34C,$A7BD,$A129,$AA0B,$9F14,$AC65
	dc.w	$9D0E,$AECC,$9B18,$B140,$9931,$B3C0,$975A,$B64C
	dc.w	$9593,$B8E3,$93DC,$BB85,$9236,$BE32,$90A1,$C0E9
	dc.w	$8F1E,$C3A9,$8DAB,$C673,$8C4A,$C946,$8AFC,$CC21
	dc.w	$89BF,$CF04,$8894,$D1EF,$877C,$D4E1,$8676,$D7D9
	dc.w	$8583,$DAD8,$84A3,$DDDC,$83D6,$E0E6,$831D,$E3F4
	dc.w	$8276,$E707,$81E3,$EA1E,$8163,$ED38,$80F7,$F054
	dc.w	$809E,$F374,$8059,$F695,$8028,$F9B8,$800A,$FCDB
	dc.w	$8001,$FFFF,$800A,$324,$8028,$647,$8059,$96A
	dc.w	$809E,$C8B,$80F7,$FAB,$8163,$12C7,$81E3,$15E1
	dc.w	$8276,$18F8,$831D,$1C0B,$83D6,$1F19,$84A3,$2223
	dc.w	$8583,$2527,$8676,$2826,$877C,$2B1E,$8894,$2E10
	dc.w	$89BF,$30FB,$8AFC,$33DE,$8C4A,$36B9,$8DAB,$398C
	dc.w	$8F1E,$3C56,$90A1,$3F16,$9236,$41CD,$93DC,$447A
	dc.w	$9593,$471C,$975A,$49B3,$9931,$4C3F,$9B18,$4EBF
	dc.w	$9D0E,$5133,$9F14,$539A,$A129,$55F4,$A34C,$5842
	dc.w	$A57E,$5A81,$A7BD,$5CB3,$AA0B,$5ED6,$AC65,$60EB
	dc.w	$AECC,$62F1,$B140,$64E7,$B3C0,$66CE,$B64C,$68A5
	dc.w	$B8E3,$6A6C,$BB85,$6C23,$BE32,$6DC9,$C0E9,$6F5E
	dc.w	$C3A9,$70E1,$C673,$7254,$C946,$73B5,$CC21,$7503
	dc.w	$CF04,$7640,$D1EF,$776B,$D4E1,$7883,$D7D9,$7989
	dc.w	$DAD8,$7A7C,$DDDC,$7B5C,$E0E6,$7C29,$E3F4,$7CE2
	dc.w	$E707,$7D89,$EA1E,$7E1C,$ED38,$7E9C,$F054,$7F08
	dc.w	$F374,$7F61,$F695,$7FA6,$F9B8,$7FD7,$FCDB,$7FF5

;	rsreset

off22 = 0	;rs.l	1	;ptr courant dans pattern
off0 = 4	;rs.l	1	;ptr base patterns
off34 = 8	;rs.l	1	;ptr fin musique

off4 = 12	;rs.w	1	;ptr patterns (.W au lieu de .L)
offa = 14	;rs.l	1	;ptr base modulation volume
offe = 18	;rs.w	1	;ptr modulation volume (.W au lieu de .L)
off12 = 20	;rs.l	1	;ptr base modulation fr‚quence
off30 = 24	;rs.w	1	;ptr modulation fr‚quence (.W au lieu de .L)

off38 = 26	;rs.l	1	;incr‚ment pour crescendo

off8 = 30	;rs.b	1
off9 = 31	;rs.b	1

off16 = 32	;rs.b	1
off17 = 33	;rs.b	1
off18 = 34	;rs.b	1
off19 = 35	;rs.b	1
off1a = 36	;rs.b	1
off1b = 37	;rs.b	1
off1c = 38	;rs.b	1
off1d = 39	;rs.b	1
off1e = 40	;rs.b	1
off1f = 41	;rs.b	1
off21 = 42	;rs.b	1

off26 = 43	;rs.b	1
off27 = 44	;rs.b	1
off28 = 45	;rs.b	1	;15-volume sonore de la voix
off2a = 46	;rs.b	1	;0,1 ou 2=type de son
off2b = 47	;rs.b	1
off2c = 48	;rs.b	1
off2d = 49	;rs.b	1	;volume sonore calcul‚
off2e = 50	;rs.b	1
off3c = 52	;equ	(__RS+1)&-2

INITMUSIC:
	LEA	MUZAK,A0
;
; init musique
;
; entr‚e :
;	A0=pointe sur le texte 'COSO'
;	D0=num‚ro de la musique … jouer
;
	TST	D0		;musique=0 -> cut mus
	BEQ	LCA
	subq	#1,d0

	LEA	PSGREG(PC),A6
	MOVE.L	A0,L934-PSGREG(A6)
	MOVE.L	4(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L938-PSGREG(A6)
	MOVE.L	8(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L93C-PSGREG(A6)
	MOVE.L	$C(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L91A-PSGREG(A6)
	MOVE.L	$10(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L916-PSGREG(A6)
	MOVE.L	$14(A0),A1
	ADD.L	A0,A1
	ADD	D0,D0
	MOVE	D0,D1
	ADD	D0,D0
	ADD	D1,D0
	ADD	D0,A1
	MOVEQ	#$C,D7
	MULU	(A1)+,D7	;PREMIER PATTERN
	MOVE	(A1)+,D6
	ADDQ	#1,D6
	MULU	#$C,D6		;DERNIER PATTERN
	MOVE	(A1)+,D0
	MOVE.B	D0,L810-PSGREG(A6)

	MOVEQ	#0,D0
	LEA	voice0(PC),A0
	LEA	L7C6(PC),A1
L658:	MOVE.L	A1,offa(a0)
	clr	offe(a0)
	CLR.B	off2d(A0)
	CLR.B	off8(a0)
	CLR.B	off9(a0)
	MOVE.L	A1,off12(A0)
	clr	off30(a0)
	MOVE.B	#1,off17(A0)
	MOVE.B	#1,off18(A0)
	CLR.B	off19(A0)
	clr.b	off1a(a0)
	clr.b	off1b(a0)
	clr.b	off1c(a0)
	clr.b	off1d(a0)
	clr.b	off1e(A0)
	clr.b	off1f(a0)
	move.l	d0,d3
	MOVE.B	d3,off21(A0)
	ADD	D3,D3
	ADD	D3,D3
	MOVE.L	L916(PC),d1
	add.l	D7,d1
	add.l	D3,d1
	move.l	d1,off0(A0)
	move.l	d1,a3
	MOVE.L	L916(PC),d1
	add.l	d6,d1
	add.l	d3,d1
	move.l	d1,off34(A0)
	move	#$C,off4(a0)
	moveq	#0,d1
	move.b	(A3)+,D1
	ADD	D1,D1
	MOVE.L	L91A(PC),A4
	MOVE	(A4,D1.W),A4
	ADD.L	L934(PC),A4
	MOVE.L	A4,off22(A0)
	clr.b	off26(A0)
	clr.b	off27(A0)
	MOVE.B	#2,off2a(A0)
	move.b	(A3)+,off2c(A0)
	CLR.B	off2b(A0)
	move.b	(A3)+,off16(A0)
	moveq	#$10,d1
	add.B	(A3),D1
	bcs.s	L712
	moveq	#0,d1
L712:
	MOVE.B	D1,off28(A0)
	CLR.L	off38(A0)
	lea	off3c(a0),A0
	addq	#1,d0
	cmp	#3,d0
	blo	L658
	MOVE.B	#1,L80E-PSGREG(A6)
	CLR	L812-PSGREG(A6)

	clr.B	$22(A6)
	clr.B	$26(A6)
	clr.B	$2A(A6)
	MOVEM.L	$1C(A6),D0-D3
	MOVEM.L	D0-D3,$FFFF8800.W
	RTS
LCA:	LEA	L812(PC),A0
	ST	(A0)
PLAYMUSIC:
	LEA	PSGREG(PC),A6
	TST.B	L812-PSGREG(A6)
	BEQ.S	L160
	TAS	L813-PSGREG(A6)
	BNE.S	L15E
	clr.B	$22(A6)
	clr.B	$26(A6)
	clr.B	$2A(A6)
	MOVEM.L	$1C(A6),D0-D3
	MOVEM.L	D0-D3,$FFFF8800.W
L15E:	RTS
L160:	SUBQ.B	#1,L80E-PSGREG(A6)
	BNE.S	L180
	MOVE.B	L810-PSGREG(A6),L80E-PSGREG(A6)
	MOVEQ	#0,D5
	LEA	voice0(PC),A0
	BSR.s	L25C
	LEA	voice1(PC),A0
	BSR.s	L25C
	LEA	voice2(PC),A0
	BSR.s	L25C
L180:	move.b	#$C0,$1E(A6)
	LEA	voice0(PC),A0
	BSR	L39A
	move	d0,6(A6)
	MOVE.B	D0,2(A6)
	MOVE.B	D1,$22(A6)
	LEA	voice1(PC),A0
	BSR	L39A
	move	d0,$E(A6)
	MOVE.B	D0,$A(A6)
	MOVE.B	D1,$26(A6)
	LEA	voice2(PC),A0
	BSR	L39A
	move	D0,$16(A6)
	MOVE.B	D0,$12(A6)
	MOVE.B	D1,$2A(A6)

	MOVEM.L	(A6),D0-D7/A0-A2
	MOVEM.L	D0-D7/A0-A2,$FFFF8800.W
L25A:	RTS

;
; calcule nouvelle note
;

L25C:	SUBQ.B	#1,off26(A0)
	BPL.S	L25A
	MOVE.B	off27(A0),off26(A0)
	MOVE.L	off22(A0),A1
L26C:	MOVE.B	(A1)+,D0
	CMP.B	#$FF,D0
	BNE.S	L2E2
	MOVE.L	off0(a0),a1
	add	off4(a0),a1
	cmp.l	off34(a0),a1
	blo.S	L288
	move	d5,off4(a0)
	MOVE.L	off0(a0),a1
L288:	MOVEQ	#0,D1
	move.b	(a1)+,D1
	move.b	(a1)+,off2c(A0)
	move.b	(a1)+,off16(A0)
	moveq	#$10,d0
	add.b	(a1)+,D0
	bcc.s	L2B4
	move.b	d0,off28(A0)		;F0-FF=volume … soustraire
	BRA.S	L2C4
L2B4:	add.b	#$10,d0
	bcc.S	L2C4
	move.B	d0,L810-PSGREG(A6)	;E0-EF=vitesse
L2C4:	ADD	D1,D1
	MOVE.L	L91A(PC),A1
	MOVE	(A1,D1.W),A1
	ADD.L	L934(PC),A1
	MOVE.L	A1,off22(A0)
	add	#$C,off4(a0)
	BRA.s	L26C
L2E2:	CMP.B	#$FE,D0
	BNE.S	L2F4
	MOVE.B	(A1)+,d0
	move.b	d0,off27(A0)
	MOVE.B	d0,off26(A0)
	BRA.s	L26C
L2F4:	CMP.B	#$FD,D0
	BNE.S	L308
	MOVE.B	(A1)+,d0
	move.b	d0,off27(A0)
	MOVE.B	d0,off26(A0)
	MOVE.L	A1,off22(A0)
	RTS
L308:	MOVE.B	D0,off8(a0)
	MOVE.B	(A1)+,D1
	MOVE.B	D1,off9(a0)
	AND	#$E0,D1			;d1=off9&$E0
	BEQ.S	L31C
	MOVE.B	(A1)+,off1f(A0)
L31C:	MOVE.L	A1,off22(A0)
	MOVE.L	D5,off38(A0)
	TST.B	D0
	BMI.S	L398
	MOVE.B	off9(a0),D0
	eor.b	d0,d1			;d1=off9&$1F
	ADD.B	off16(A0),D1

	MOVE.L	L93C(PC),a1
	ADD	D1,D1
	MOVE	(a1,D1.W),a1
	ADD.L	L934(PC),a1
	move	d5,offe(A0)
	MOVE.B	(a1)+,d1
	move.b	d1,off17(A0)
	MOVE.B	d1,off18(A0)
	MOVEQ	#0,D1
	MOVE.B	(a1)+,D1
	MOVE.B	(a1)+,off1b(A0)
;	MOVE.B	#$40,off2e(A0)
	clr.b	off2e(a0)
	MOVE.B	(a1)+,D2
	MOVE.B	D2,off1c(A0)
	MOVE.B	D2,off1d(A0)
	MOVE.B	(a1)+,off1e(A0)
	MOVE.L	a1,offa(A0)
	add.b	d0,d0			;test bit 6
	bpl.s	L37A
	MOVE.B	off1f(A0),D1
L37A:	MOVE.L	L938(PC),a1
	ADD	D1,D1
	MOVE	(a1,D1.W),a1
	ADD.L	L934(PC),a1
	MOVE.L	a1,off12(A0)
	move	d5,off30(A0)
	MOVE.B	D5,off1a(A0)
	MOVE.B	D5,off19(A0)
L398:	RTS

;
; calcul de la note … jouer
;

L39A:	MOVEQ	#0,D7
	MOVE	off30(a0),d6
L3A0:	TST.B	off1a(A0)
	BEQ.S	L3AE
	SUBQ.B	#1,off1a(A0)
	BRA	L4C01
L3AE:	MOVE.L	off12(A0),A1
	add	d6,a1
L3B6:	move.b	(a1)+,d0
	cmp.b	#$E1,d0
	BEQ	L4C01
	cmp.b	#$E0,d0
	BNE.S	L3D8
	moveq	#$3f,d6
	and.B	(A1),D6
	MOVE.L	off12(A0),A1
	add	d6,A1
	move.b	(a1)+,d0
L3D8:	cmp.b	#$E2,d0
	BNE.S	L3EE
	clr	offe(a0)
	MOVE.B	#1,off17(A0)
	addq	#1,d6
	bra.s	L3B6
L3EE:	cmp.b	#$E9,d0
	BNE.s	L422
	MOVE.B	#$B,$FFFF8800.W
	move.b	(A1)+,$FFFF8802.W
	move.l	#$0C0C0000,$FFFF8800.W
	move.l	#$0D0D0A0A,$FFFF8800.W
	addq	#2,d6
	bra.s	L3B6
L422:	cmp.b	#$E7,d0
	BNE.S	L44A
	clr	d0
	move.b	(A1),D0
	ADD	D0,D0
	MOVE.L	L938(PC),A1
	MOVE	(A1,D0.W),A1
	ADD.L	L934(PC),A1
	MOVE.L	A1,off12(A0)
	clr	d6
	BRA.s	L3B6
L44A:	cmp.b	#$E8,d0
	BNE.S	L45E
	move.b	(A1)+,off1a(A0)
	addq	#2,d6
	BRA	L3A0
L45E:	cmp.b	#$E4,d0
	BNE.S	L474
	clr.b	off2a(A0)
	MOVE.B	(A1)+,d7
	addq	#2,d6
	BRA.S	L4AE
L474:	cmp.b	#$E5,d0
	BNE.S	L488
	MOVE.B	#1,off2a(A0)
	addq	#1,d6
	BRA	L3B6
L488:	cmp.b	#$E6,d0
	BNE.S	L49A
	MOVE.B	#2,off2a(A0)
	addq	#1,d6
	BRA.S	L4AE
L49A:	cmp.b	#$E3,d0
	BNE.S	L4B0
	addq	#3,d6
	move.b	(A1)+,off1b(A0)
	move.b	(A1)+,off1c(A0)
L4AE:	move.b	(a1)+,d0
L4B0:
	MOVE.B	d0,off2b(A0)
	addq	#1,d6
L4C01:	move	d6,off30(a0)
;
; modulation volume
;
	move	offe(a0),d6
L4C0:	TST.B	off19(A0)
	BEQ.S	L4CC
	SUBQ.B	#1,off19(A0)
	BRA.S	L51A
L4CC:	SUBQ.B	#1,off17(A0)
	BNE.S	L51A
	MOVE.B	off18(A0),off17(A0)

	MOVE.L	offa(A0),A1
	add	d6,a1
	move.b	(A1)+,D0
	CMP.B	#$E0,D0
	BNE.S	L512
	moveq	#$3f,d6
	and.b	(A1),D6
	subq	#5,D6
	move.l	offa(a0),a1
	add	d6,a1
	move.b	(a1)+,d0
L512:
	CMP.B	#$E8,D0
	BNE.S	L4F4
	addq	#2,d6
	move.b	(A1)+,off19(A0)
	BRA.S	L4C0
L4F4:	CMP.B	#$E1,D0
	BEQ.S	L51A
	MOVE.B	d0,off2d(A0)
	addq	#1,d6
L51A:	move	d6,offe(a0)

	clr	d5
	MOVE.B	off2b(A0),D5
	BMI.S	L528
	ADD.B	off8(a0),D5
	ADD.B	off2c(A0),D5
L528:
	LEA	L94E(PC),A1
	add.b	D5,D5
	MOVE	(A1,d5.w),D0

	move.b	off2a(A0),D2	;0,1 ou 2
	beq.S	L57E

	MOVE.B	off21(A0),D3
	ADDQ	#3,D3

	subq.b	#1,D2
	BNE.S	L578
	subq	#3,d3
	MOVE.B	off2b(A0),D7
	bclr	#7,d7
	bne.s	L578
	add.b	off8(a0),d7
L578:	BSET	D3,$1E(A6)
L57E:
	tst.b	d7
	BEQ.S	L594
	not.b	d7
	and.b	#$1F,D7
	MOVE.B	D7,$1A(A6)
L594:
	MOVE.B	off2e(A0),d6
	TST.B	off1e(A0)
	BEQ.S	L5A4
	SUBQ.B	#1,off1e(A0)
	BRA.S	L5FA
L5A4:
	clr	d4
	MOVE.B	off1c(A0),D4
	clr	d1
	MOVE.B	off1d(A0),D1
	tst.b	d6
	bmi.S	L5CE
	SUB.B	off1b(A0),D1
	BCC.S	L5DC
	tas	d6
	MOVEQ	#0,D1
	BRA.S	L5DC
L5CE:	ADD.B	off1b(A0),D1
	ADD.B	D4,D4
	CMP.B	D4,D1
	BCS.S	L5DA
	bclr	#7,d6
	MOVE.B	D4,D1
L5DA:	lsr.b	#1,d4
L5DC:	MOVE.B	D1,off1d(A0)
L5E0:
	sub	D4,D1

	ADD.B	#$A0,D5
	BCS.S	L5F8
	moveq	#$18,d4

	add	d1,d1
	add.b	d4,d5
	bcs.s	L5F8
	add	d1,d1
	add.b	d4,d5
	bcs.s	L5F8
	add	d1,d1
	add.b	d4,d5
	bcs.s	L5F8
	add	d1,d1
L5F8:	ADD	D1,D0
L5FA:	EOR.B	#1,d6
	MOVE.B	d6,off2e(A0)
	BTST	#5,off9(a0)
	BEQ.s	L628
	moveq	#0,D1
	MOVE.B	off1f(A0),D1
	EXT	D1
	swap	d1
	lsr.l	#4,d1		;asr.l #4,d1 corrige bug ???
	add.l	d1,off38(a0)
	SUB	off38(a0),D0
L628:	MOVE.B	off2d(A0),D1
	SUB.B	off28(A0),D1
	BPL.S	L634
	MOVEQ	#0,D1
L634:
	RTS

L94E:	DC.W	$EEE,$E17,$D4D,$C8E
	DC.W	$BD9,$B2F,$A8E,$9F7
	DC.W	$967,$8E0,$861,$7E8
	DC.W	$777,$70B,$6A6,$647
	DC.W	$5EC,$597,$547,$4FB
	DC.W	$4B3,$470,$430,$3F4
	DC.W	$3BB,$385,$353,$323
	DC.W	$2F6,$2CB,$2A3,$27D
	DC.W	$259,$238,$218,$1FA
	DC.W	$1DD,$1C2,$1A9,$191
	DC.W	$17B,$165,$151,$13E
	DC.W	$12C,$11C,$10C,$FD
	DC.W	$EE,$E1,$D4,$C8
	DC.W	$BD,$B2,$A8,$9F
	DC.W	$96,$8E,$86,$7E
	DC.W	$77,$70,$6A,$64
	DC.W	$5E,$59,$54,$4F
	DC.W	$4B,$47,$43,$3F
	DC.W	$3B,$38,$35,$32
	DC.W	$2F,$2C,$2A,$27
	DC.W	$25,$23,$21,$1F
	DC.W	$1D,$1C,$1A,$19
	DC.W	$17,$16,$15,$13
	DC.W	$12,$11,$10,$F
L7C6:	DC.B	1,0,0,0,0,0,0,$E1
PSGREG:	DC.W	0,0,$101,0
	DC.W	$202,0,$303,0
	DC.W	$404,0,$505,0
	DC.W	$606,0,$707,$FFFF
	DC.W	$808,0,$909,0
	DC.W	$A0A,0

L80E:	DC.B	4
L810:	DC.B	4
L812:	DC.B	-1
L813:	DC.B	0

voice0:	ds.B	off3c
voice1:	ds.B	off3c
voice2:	ds.B	off3c
L916:	DC.L	0
L91A:	DC.L	0
L934:	DC.L	0
L938:	DC.L	0
L93C:	DC.L	0

	SECTION	DATA
palette:dc.w	0	;%000
	dcb.w	3,0
;	dcb.w	4,$007
	dc.w	$044,$055,$066,$077
	dcb.w	8,$740

;
; LISTE DE TOUS LES POINTS (X,Y,Z) -EN 7 BITS SIGNES-
;
OBJ1	DC.B	6,$A3,$EA,$10,$A3,$F0,$16,$A3
	DC.B	$FA,$16,$A3,6,$10,$A3,$10,6
	DC.B	$A3,$16,$FA,$A3,$16,$F0,$A3,$10
	DC.B	$EA,$A3,6,$EA,$A3,$FA,$F0,$A3
	DC.B	$F0,$FA,$A3,$EA,$C,$AB,$D5,$20
	DC.B	$AB,$E0,$2B,$AB,$F4,$2B,$AB,$C
	DC.B	$20,$AB,$20,$C,$AB,$2B,$F4,$AB
	DC.B	$2B,$E0,$AB,$20,$D5,$AB,$C,$D5
	DC.B	$AB,$F4,$E0,$AB,$E0,$F4,$AB,$D5
	DC.B	$11,$B8,$C2,$2D,$B8,$D3,$3E,$B8
	DC.B	$EF,$3E,$B8,$11,$2D,$B8,$2D,$11
	DC.B	$B8,$3E,$EF,$B8,$3E,$D3,$B8,$2D
	DC.B	$C2,$B8,$11,$C2,$B8,$EF,$D3,$B8
	DC.B	$D3,$EF,$B8,$C2,$14,$C9,$B4,$38
	DC.B	$C9,$C8,$4C,$C9,$EC,$4C,$C9,$14
	DC.B	$38,$C9,$38,$14,$C9,$4C,$EC,$C9
	DC.B	$4C,$C8,$C9,$38,$B4,$C9,$14,$B4
	DC.B	$C9,$EC,$C8,$C9,$C8,$EC,$C9,$B4
	DC.B	$17,$DC,$A9,$40,$DC,$C0,$57,$DC
	DC.B	$E9,$57,$DC,$17,$40,$DC,$40,$17
	DC.B	$DC,$57,$E9,$DC,$57,$C0,$DC,$40
	DC.B	$A9,$DC,$17,$A9,$DC,$E9,$C0,$DC
	DC.B	$C0,$E9,$DC,$A9,$19,$F3,$A4,$43
	DC.B	$F3,$BD,$5C,$F3,$E7,$5C,$F3,$19
	DC.B	$43,$F3,$43,$19,$F3,$5C,$E7,$F3
	DC.B	$5C,$BD,$F3,$43,$A4,$F3,$19,$A4
	DC.B	$F3,$E7,$BD,$F3,$BD,$E7,$F3,$A4
	DC.B	$19,$D,$A4,$43,$D,$BD,$5C,$D
	DC.B	$E7,$5C,$D,$19,$43,$D,$43,$19
	DC.B	$D,$5C,$E7,$D,$5C,$BD,$D,$43
	DC.B	$A4,$D,$19,$A4,$D,$E7,$BD,$D
	DC.B	$BD,$E7,$D,$A4,$17,$24,$A9,$40
	DC.B	$24,$C0,$57,$24,$E9,$57,$24,$17
	DC.B	$40,$24,$40,$17,$24,$57,$E9,$24
	DC.B	$57,$C0,$24,$40,$A9,$24,$17,$A9
	DC.B	$24,$E9,$C0,$24,$C0,$E9,$24,$A9
	DC.B	$14,$37,$B4,$38,$37,$C8,$4C,$37
	DC.B	$EC,$4C,$37,$14,$38,$37,$38,$14
	DC.B	$37,$4C,$EC,$37,$4C,$C8,$37,$38
	DC.B	$B4,$37,$14,$B4,$37,$EC,$C8,$37
	DC.B	$C8,$EC,$37,$B4,$11,$48,$C2,$2D
	DC.B	$48,$D3,$3E,$48,$EF,$3E,$48,$11
	DC.B	$2D,$48,$2D,$11,$48,$3E,$EF,$48
	DC.B	$3E,$D3,$48,$2D,$C2,$48,$11,$C2
	DC.B	$48,$EF,$D3,$48,$D3,$EF,$48,$C2
	DC.B	$C,$55,$D5,$20,$55,$E0,$2B,$55
	DC.B	$F4,$2B,$55,$C,$20,$55,$20,$C
	DC.B	$55,$2B,$F4,$55,$2B,$E0,$55,$20
	DC.B	$D5,$55,$C,$D5,$55,$F4,$E0,$55
	DC.B	$E0,$F4,$55,$D5,6,$5D,$EA,$10
	DC.B	$5D,$F0,$16,$5D,$FA,$16,$5D,6
	DC.B	$10,$5D,$10,6,$5D,$16,$FA,$5D
	DC.B	$16,$F0,$5D,$10,$EA,$5D,6,$EA
	DC.B	$5D,$FA,$F0,$5D,$F0,$FA,$5D,$EA
OBJ2	DC.B	$A8,$A3,0,$B8,$A3,0,$C8,$A3
	DC.B	0,$D8,$A3,0,$E8,$A3,0,$F8
	DC.B	$A3,0,8,$A3,0,$18,$A3,0
	DC.B	$28,$A3,0,$38,$A3,0,$48,$A3
	DC.B	0,$58,$A3,0,$A8,$AB,0,$B8
	DC.B	$AB,$F,$C8,$AB,$F,$D8,$AB,$F
	DC.B	$E8,$AB,$F,$F8,$AB,$F,8,$AB
	DC.B	$F,$18,$AB,$F,$28,$AB,$F,$38
	DC.B	$AB,$F,$48,$AB,$F,$58,$AB,0
	DC.B	$A8,$B8,0,$B8,$B8,$F,$C8,$B8
	DC.B	$1E,$D8,$B8,$1E,$E8,$B8,$1E,$F8
	DC.B	$B8,$1E,8,$B8,$1E,$18,$B8,$1E
	DC.B	$28,$B8,$1E,$38,$B8,$1E,$48,$B8
	DC.B	$F,$58,$B8,0,$A8,$C9,0,$B8
	DC.B	$C9,$F,$C8,$C9,$1E,$D8,$C9,$2D
	DC.B	$E8,$C9,$2D,$F8,$C9,$2D,8,$C9
	DC.B	$2D,$18,$C9,$2D,$28,$C9,$2D,$38
	DC.B	$C9,$1E,$48,$C9,$F,$58,$C9,0
	DC.B	$A8,$DC,0,$B8,$DC,$F,$C8,$DC
	DC.B	$1E,$D8,$DC,$2D,$E8,$DC,$3C,$F8
	DC.B	$DC,$3C,8,$DC,$3C,$18,$DC,$3C
	DC.B	$28,$DC,$2D,$38,$DC,$1E,$48,$DC
	DC.B	$F,$58,$DC,0,$A8,$F3,0,$B8
	DC.B	$F3,$F,$C8,$F3,$1E,$D8,$F3,$2D
	DC.B	$E8,$F3,$3C,$F8,$F3,$4B,8,$F3
	DC.B	$4B,$18,$F3,$3C,$28,$F3,$2D,$38
	DC.B	$F3,$1E,$48,$F3,$F,$58,$F3,0
	DC.B	$A8,$D,0,$B8,$D,$F,$C8,$D
	DC.B	$1E,$D8,$D,$2D,$E8,$D,$3C,$F8
	DC.B	$D,$4B,8,$D,$4B,$18,$D,$3C
	DC.B	$28,$D,$2D,$38,$D,$1E,$48,$D
	DC.B	$F,$58,$D,0,$A8,$24,0,$B8
	DC.B	$24,$F,$C8,$24,$1E,$D8,$24,$2D
	DC.B	$E8,$24,$3C,$F8,$24,$3C,8,$24
	DC.B	$3C,$18,$24,$3C,$28,$24,$2D,$38
	DC.B	$24,$1E,$48,$24,$F,$58,$24,0
	DC.B	$A8,$37,0,$B8,$37,$F,$C8,$37
	DC.B	$1E,$D8,$37,$2D,$E8,$37,$2D,$F8
	DC.B	$37,$2D,8,$37,$2D,$18,$37,$2D
	DC.B	$28,$37,$2D,$38,$37,$1E,$48,$37
	DC.B	$F,$58,$37,0,$A8,$48,0,$B8
	DC.B	$48,$F,$C8,$48,$1E,$D8,$48,$1E
	DC.B	$E8,$48,$1E,$F8,$48,$1E,8,$48
	DC.B	$1E,$18,$48,$1E,$28,$48,$1E,$38
	DC.B	$48,$1E,$48,$48,$F,$58,$48,0
	DC.B	$A8,$55,0,$B8,$55,$F,$C8,$55
	DC.B	$F,$D8,$55,$F,$E8,$55,$F,$F8
	DC.B	$55,$F,8,$55,$F,$18,$55,$F
	DC.B	$28,$55,$F,$38,$55,$F,$48,$55
	DC.B	$F,$58,$55,0,$A8,$5D,0,$B8
	DC.B	$5D,0,$C8,$5D,0,$D8,$5D,0
	DC.B	$E8,$5D,0,$F8,$5D,0,8,$5D
	DC.B	0,$18,$5D,0,$28,$5D,0,$38
	DC.B	$5D,0,$48,$5D,0,$58,$5D,0
OBJ3	DC.B	$A8,$40,0,$B8,$3B,0,$C8,$36
	DC.B	0,$D8,$31,0,$E8,$2C,0,$F8
	DC.B	$27,0,8,$22,0,$18,$1D,0
	DC.B	$28,$18,0,$38,$13,0,$48,$E
	DC.B	0,$58,9,0,$A8,$37,$E0,$B8
	DC.B	$33,$E2,$C8,$2F,$E5,$D8,$2A,$E8
	DC.B	$E8,$26,$EA,$F8,$22,$EC,8,$1D
	DC.B	$EF,$18,$19,$F1,$28,$15,$F4,$38
	DC.B	$10,$F6,$48,$C,$F9,$58,7,$FC
	DC.B	$A8,$20,$C9,$B8,$1E,$CD,$C8,$1B
	DC.B	$D1,$D8,$18,$D6,$E8,$16,$DA,$F8
	DC.B	$14,$DE,8,$11,$E3,$18,$F,$E7
	DC.B	$28,$C,$EB,$38,$A,$F0,$48,7
	DC.B	$F4,$58,4,$F9,$A8,0,$C0,$B8
	DC.B	0,$C5,$C8,0,$CA,$D8,0,$CF
	DC.B	$E8,0,$D4,$F8,0,$D9,8,0
	DC.B	$DE,$18,0,$E3,$28,0,$E8,$38
	DC.B	0,$ED,$48,0,$F2,$58,0,$F7
	DC.B	$A8,$E0,$C9,$B8,$E2,$CD,$C8,$E5
	DC.B	$D1,$D8,$E8,$D6,$E8,$EA,$DA,$F8
	DC.B	$EC,$DE,8,$EF,$E3,$18,$F1,$E7
	DC.B	$28,$F4,$EB,$38,$F6,$F0,$48,$F9
	DC.B	$F4,$58,$FC,$F9,$A8,$C9,$E0,$B8
	DC.B	$CD,$E2,$C8,$D1,$E5,$D8,$D6,$E8
	DC.B	$E8,$DA,$EA,$F8,$DE,$EC,8,$E3
	DC.B	$EF,$18,$E7,$F1,$28,$EB,$F4,$38
	DC.B	$F0,$F6,$48,$F4,$F9,$58,$F9,$FC
	DC.B	$A8,$C0,0,$B8,$C5,0,$C8,$CA
	DC.B	0,$D8,$CF,0,$E8,$D4,0,$F8
	DC.B	$D9,0,8,$DE,0,$18,$E3,0
	DC.B	$28,$E8,0,$38,$ED,0,$48,$F2
	DC.B	0,$58,$F7,0,$A8,$C9,$20,$B8
	DC.B	$CD,$1E,$C8,$D1,$1B,$D8,$D6,$18
	DC.B	$E8,$DA,$16,$F8,$DE,$14,8,$E3
	DC.B	$11,$18,$E7,$F,$28,$EB,$C,$38
	DC.B	$F0,$A,$48,$F4,7,$58,$F9,4
	DC.B	$A8,$E0,$37,$B8,$E2,$33,$C8,$E5
	DC.B	$2F,$D8,$E8,$2A,$E8,$EA,$26,$F8
	DC.B	$EC,$22,8,$EF,$1D,$18,$F1,$19
	DC.B	$28,$F4,$15,$38,$F6,$10,$48,$F9
	DC.B	$C,$58,$FC,7,$A8,0,$40,$B8
	DC.B	0,$3B,$C8,0,$36,$D8,0,$31
	DC.B	$E8,0,$2C,$F8,0,$27,8,0
	DC.B	$22,$18,0,$1D,$28,0,$18,$38
	DC.B	0,$13,$48,0,$E,$58,0,9
	DC.B	$A8,$20,$37,$B8,$1E,$33,$C8,$1B
	DC.B	$2F,$D8,$18,$2A,$E8,$16,$26,$F8
	DC.B	$14,$22,8,$11,$1D,$18,$F,$19
	DC.B	$28,$C,$15,$38,$A,$10,$48,7
	DC.B	$C,$58,4,7,$A8,$37,$20,$B8
	DC.B	$33,$1E,$C8,$2F,$1B,$D8,$2A,$18
	DC.B	$E8,$26,$16,$F8,$22,$14,8,$1D
	DC.B	$11,$18,$19,$F,$28,$15,$C,$38
	DC.B	$10,$A,$48,$C,7,$58,7,4
OBJ4	DC.B	$A8,$40,0,$B8,$40,0,$C8,$40
	DC.B	0,$D8,$40,0,$E8,$40,0,$F8
	DC.B	$40,0,8,$40,0,$18,$40,0
	DC.B	$28,$40,0,$38,$40,0,$48,$40
	DC.B	0,$58,$40,0,$A8,$37,$E0,$B8
	DC.B	$37,$E0,$C8,$37,$E0,$D8,$37,$E0
	DC.B	$E8,$37,$E0,$F8,$37,$E0,8,$37
	DC.B	$E0,$18,$37,$E0,$28,$37,$E0,$38
	DC.B	$37,$E0,$48,$37,$E0,$58,$37,$E0
	DC.B	$A8,$20,$C9,$B8,$20,$C9,$C8,$20
	DC.B	$C9,$D8,$20,$C9,$E8,$20,$C9,$F8
	DC.B	$20,$C9,8,$20,$C9,$18,$20,$C9
	DC.B	$28,$20,$C9,$38,$20,$C9,$48,$20
	DC.B	$C9,$58,$20,$C9,$A8,0,$C0,$B8
	DC.B	0,$C0,$C8,0,$C0,$D8,0,$C0
	DC.B	$E8,0,$C0,$F8,0,$C0,8,0
	DC.B	$C0,$18,0,$C0,$28,0,$C0,$38
	DC.B	0,$C0,$48,0,$C0,$58,0,$C0
	DC.B	$A8,$E0,$C9,$B8,$E0,$C9,$C8,$E0
	DC.B	$C9,$D8,$E0,$C9,$E8,$E0,$C9,$F8
	DC.B	$E0,$C9,8,$E0,$C9,$18,$E0,$C9
	DC.B	$28,$E0,$C9,$38,$E0,$C9,$48,$E0
	DC.B	$C9,$58,$E0,$C9,$A8,$C9,$E0,$B8
	DC.B	$C9,$E0,$C8,$C9,$E0,$D8,$C9,$E0
	DC.B	$E8,$C9,$E0,$F8,$C9,$E0,8,$C9
	DC.B	$E0,$18,$C9,$E0,$28,$C9,$E0,$38
	DC.B	$C9,$E0,$48,$C9,$E0,$58,$C9,$E0
	DC.B	$A8,$C0,0,$B8,$C0,0,$C8,$C0
	DC.B	0,$D8,$C0,0,$E8,$C0,0,$F8
	DC.B	$C0,0,8,$C0,0,$18,$C0,0
	DC.B	$28,$C0,0,$38,$C0,0,$48,$C0
	DC.B	0,$58,$C0,0,$A8,$C9,$20,$B8
	DC.B	$C9,$20,$C8,$C9,$20,$D8,$C9,$20
	DC.B	$E8,$C9,$20,$F8,$C9,$20,8,$C9
	DC.B	$20,$18,$C9,$20,$28,$C9,$20,$38
	DC.B	$C9,$20,$48,$C9,$20,$58,$C9,$20
	DC.B	$A8,$E0,$37,$B8,$E0,$37,$C8,$E0
	DC.B	$37,$D8,$E0,$37,$E8,$E0,$37,$F8
	DC.B	$E0,$37,8,$E0,$37,$18,$E0,$37
	DC.B	$28,$E0,$37,$38,$E0,$37,$48,$E0
	DC.B	$37,$58,$E0,$37,$A8,0,$40,$B8
	DC.B	0,$40,$C8,0,$40,$D8,0,$40
	DC.B	$E8,0,$40,$F8,0,$40,8,0
	DC.B	$40,$18,0,$40,$28,0,$40,$38
	DC.B	0,$40,$48,0,$40,$58,0,$40
	DC.B	$A8,$20,$37,$B8,$20,$37,$C8,$20
	DC.B	$37,$D8,$20,$37,$E8,$20,$37,$F8
	DC.B	$20,$37,8,$20,$37,$18,$20,$37
	DC.B	$28,$20,$37,$38,$20,$37,$48,$20
	DC.B	$37,$58,$20,$37,$A8,$37,$20,$B8
	DC.B	$37,$20,$C8,$37,$20,$D8,$37,$20
	DC.B	$E8,$37,$20,$F8,$37,$20,8,$37
	DC.B	$20,$18,$37,$20,$28,$37,$20,$38
	DC.B	$37,$20,$48,$37,$20,$58,$37,$20
OBJ5	DC.B	$A8,$A8,0,$B8,$A8,0,$C8,$A8
	DC.B	0,$D8,$A8,0,$E8,$A8,0,$F8
	DC.B	$A8,0,8,$A8,0,$18,$A8,0
	DC.B	$28,$A8,0,$38,$A8,0,$48,$A8
	DC.B	0,$58,$A8,0,$A8,$B8,0,$B8
	DC.B	$B8,0,$C8,$B8,0,$D8,$B8,0
	DC.B	$E8,$B8,0,$F8,$B8,0,8,$B8
	DC.B	0,$18,$B8,0,$28,$B8,0,$38
	DC.B	$B8,0,$48,$B8,0,$58,$B8,0
	DC.B	$A8,$C8,0,$B8,$C8,0,$C8,$C8
	DC.B	0,$D8,$C8,0,$E8,$C8,0,$F8
	DC.B	$C8,0,8,$C8,0,$18,$C8,0
	DC.B	$28,$C8,0,$38,$C8,0,$48,$C8
	DC.B	0,$58,$C8,0,$A8,$D8,0,$B8
	DC.B	$D8,0,$C8,$D8,0,$D8,$D8,0
	DC.B	$E8,$D8,0,$F8,$D8,0,8,$D8
	DC.B	0,$18,$D8,0,$28,$D8,0,$38
	DC.B	$D8,0,$48,$D8,0,$58,$D8,0
	DC.B	$A8,$E8,0,$B8,$E8,0,$C8,$E8
	DC.B	0,$D8,$E8,0,$E8,$E8,0,$F8
	DC.B	$E8,0,8,$E8,0,$18,$E8,0
	DC.B	$28,$E8,0,$38,$E8,0,$48,$E8
	DC.B	0,$58,$E8,0,$A8,$F8,0,$B8
	DC.B	$F8,0,$C8,$F8,0,$D8,$F8,0
	DC.B	$E8,$F8,0,$F8,$F8,0,8,$F8
	DC.B	0,$18,$F8,0,$28,$F8,0,$38
	DC.B	$F8,0,$48,$F8,0,$58,$F8,0
	DC.B	$A8,8,0,$B8,8,0,$C8,8
	DC.B	0,$D8,8,0,$E8,8,0,$F8
	DC.B	8,0,8,8,0,$18,8,0
	DC.B	$28,8,0,$38,8,0,$48,8
	DC.B	0,$58,8,0,$A8,$18,0,$B8
	DC.B	$18,0,$C8,$18,0,$D8,$18,0
	DC.B	$E8,$18,0,$F8,$18,0,8,$18
	DC.B	0,$18,$18,0,$28,$18,0,$38
	DC.B	$18,0,$48,$18,0,$58,$18,0
	DC.B	$A8,$28,0,$B8,$28,0,$C8,$28
	DC.B	0,$D8,$28,0,$E8,$28,0,$F8
	DC.B	$28,0,8,$28,0,$18,$28,0
	DC.B	$28,$28,0,$38,$28,0,$48,$28
	DC.B	0,$58,$28,0,$A8,$38,0,$B8
	DC.B	$38,0,$C8,$38,0,$D8,$38,0
	DC.B	$E8,$38,0,$F8,$38,0,8,$38
	DC.B	0,$18,$38,0,$28,$38,0,$38
	DC.B	$38,0,$48,$38,0,$58,$38,0
	DC.B	$A8,$48,0,$B8,$48,0,$C8,$48
	DC.B	0,$D8,$48,0,$E8,$48,0,$F8
	DC.B	$48,0,8,$48,0,$18,$48,0
	DC.B	$28,$48,0,$38,$48,0,$48,$48
	DC.B	0,$58,$48,0,$A8,$58,0,$B8
	DC.B	$58,0,$C8,$58,0,$D8,$58,0
	DC.B	$E8,$58,0,$F8,$58,0,8,$58
	DC.B	0,$18,$58,0,$28,$58,0,$38
	DC.B	$58,0,$48,$58,0,$58,$58,0
OBJ6	DC.B	$C1,$C1,0,$CA,$B9,0,$D3,$B2
	DC.B	0,$DF,$AE,0,$EC,$AA,0,$F8
	DC.B	$A8,0,8,$A8,0,$14,$AA,0
	DC.B	$21,$AE,0,$2D,$B2,0,$36,$B9
	DC.B	0,$3F,$C1,0,$B9,$CA,0,$CC
	DC.B	$CC,0,$D4,$C2,0,$DF,$BE,0
	DC.B	$EC,$BA,0,$F8,$B8,0,8,$B8
	DC.B	0,$14,$BA,0,$21,$BE,0,$2C
	DC.B	$C2,0,$34,$CC,0,$47,$CA,0
	DC.B	$B2,$D3,0,$C2,$D4,0,$D3,$D3
	DC.B	0,$DE,$CF,0,$EC,$CB,0,$F8
	DC.B	$C8,0,8,$C8,0,$14,$CB,0
	DC.B	$22,$CF,0,$2D,$D3,0,$3E,$D4
	DC.B	0,$4E,$D3,0,$AE,$DF,0,$BE
	DC.B	$DF,0,$CF,$DE,0,$DF,$DF,0
	DC.B	$EC,$DB,0,$F8,$D8,0,8,$D8
	DC.B	0,$14,$DB,0,$21,$DF,0,$31
	DC.B	$DE,0,$42,$DF,0,$52,$DF,0
	DC.B	$AA,$EC,0,$BA,$EC,0,$CB,$EC
	DC.B	0,$DB,$EC,0,$EA,$EA,0,$F8
	DC.B	$E8,0,8,$E8,0,$16,$EA,0
	DC.B	$25,$EC,0,$35,$EC,0,$46,$EC
	DC.B	0,$56,$EC,0,$A8,$F8,0,$B8
	DC.B	$F8,0,$C8,$F8,0,$D8,$F8,0
	DC.B	$E8,$F8,0,$F8,$F8,0,8,$F8
	DC.B	0,$18,$F8,0,$28,$F8,0,$38
	DC.B	$F8,0,$48,$F8,0,$58,$F8,0
	DC.B	$A8,8,0,$B8,8,0,$C8,8
	DC.B	0,$D8,8,0,$E8,8,0,$F8
	DC.B	8,0,8,8,0,$18,8,0
	DC.B	$28,8,0,$38,8,0,$48,8
	DC.B	0,$58,8,0,$AA,$14,0,$BA
	DC.B	$14,0,$CB,$14,0,$DB,$14,0
	DC.B	$EA,$16,0,$F8,$18,0,8,$18
	DC.B	0,$16,$16,0,$25,$14,0,$35
	DC.B	$14,0,$46,$14,0,$56,$14,0
	DC.B	$AE,$21,0,$BE,$21,0,$CF,$22
	DC.B	0,$DF,$21,0,$EC,$25,0,$F8
	DC.B	$28,0,8,$28,0,$14,$25,0
	DC.B	$21,$21,0,$31,$22,0,$42,$21
	DC.B	0,$52,$21,0,$B2,$2D,0,$C2
	DC.B	$2C,0,$D3,$2D,0,$DE,$31,0
	DC.B	$EC,$35,0,$F8,$38,0,8,$38
	DC.B	0,$14,$35,0,$22,$31,0,$2D
	DC.B	$2D,0,$3E,$2C,0,$4E,$2D,0
	DC.B	$B9,$36,0,$CC,$34,0,$D4,$3E
	DC.B	0,$DF,$42,0,$EC,$46,0,$F8
	DC.B	$48,0,8,$48,0,$14,$46,0
	DC.B	$21,$42,0,$2C,$3E,0,$34,$34
	DC.B	0,$47,$36,0,$C1,$3F,0,$CA
	DC.B	$47,0,$D3,$4E,0,$DF,$52,0
	DC.B	$EC,$56,0,$F8,$58,0,8,$58
	DC.B	0,$14,$56,0,$21,$52,0,$2D
	DC.B	$4E,0,$36,$47,0,$3F,$3F,0

MUZAK	INCBIN	THAL7.PAK
;
; IMPLEMENTER ICI ALGORITHME DE TRACAGE DE DROITES POTABLE
;
DRAW_IT
	INCBIN	DRAW12.BIN
ENDDRAW
	IFEQ	DEBUG
initreset	incbin	debugger.bin
	ENDC
	SECTION	BSS
recopie:
	DS.B	12*4*NBLIGNES+2
finrecopie:
	DS.B	32768
L48000	DS.B	32768		;BUFFER CALCUL DES MULTIPLICATIONS
L5E000	DS.W	$80+$81		;BUFFER CONTIENT LES DIFFERENTES PROFONDEURS
FIN5E000
BITPLANE
	DS.B	NBCOLS/8*NBLIGNES
END_OF_BITPLANE
	DS.B	NBCOLS/8
	SECTION	TEXT
LONGFONTE = 376+8
;
TAILLE = 8		;HAUTEUR DU SCROLLER
STEP = 2		;PAS DU SCROLLER
;
INITSCROLL:
;
; PREDECALE LA FONTE
;
	MOVEQ	#32,D1
	LEA	PREDEC,A1
NXTDEC:
	LEA	FONTE,A0
NXTCAR:
	MOVEQ	#8-1,D7
DECAL:
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	SWAP	D0
	ROR.L	D1,D0
	MOVE.L	D0,(A1)+
	DBRA	D7,DECAL

	CMP.L	#FINFONTE,A0
	BLO.S	NXTCAR

	SUBQ	#STEP,D1
	BHI.S	NXTDEC

	CMP.L	#FINPREDEC,A1
	BLS.S	L1
	ILLEGAL
L1:
	LEA	TEXTE,A0
	MOVE.L	A0,CURTEXT\W
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	ASL	#5,D0
	ADD.L	#PREDEC,D0
	MOVE.L	D0,LETTRE1.w
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	ASL	#5,D0
	ADD.L	#PREDEC,D0
	MOVE.L	D0,LETTRE2.w
	MOVE.L	A0,PTRTXT.w

	CLR	SHIFT1.w
	CLR	L5E9A.w
	MOVE.L	#L6ECC,BUFSCR.w
	CLR	L5EA6.w

	LEA	L6ECC,A0
	MOVEQ	#0,D0
	MOVE	#(16/STEP)*TAILLE*80/4-1,D1
L84C8:	MOVE.L	D0,(A0)+
	DBF	D1,L84C8
	RTS
;
; A2=ADRESSE ECRAN
;
SCROLLER:
;
; SCROLLEUR 1 PLAN !!!!
;
	MOVE	SHIFT1.w,D0
	ADD	#(LONGFONTE)*16,D0
	MOVE.L	LETTRE1.w,A0		;PTR FONTE PREMIERE LETTRE
	ADD	D0,A0
	MOVE.L	LETTRE2.w,A3		;PTR FONTE SECONDE LETTRE
	ADD	SHIFT1.w,A3

	MOVE.L	BUFSCR.w,A1
	ADD	L5E9A.w,A1

xx	set	PLANSCROLL*2
Z	SET	32

Y	SET	(200-TAILLE)*160
X	SET	0
	REPT	TAILLE*152/8

	MOVE	(A1)+,X+Y+xx(A2)
X	SET	X+8

	IFEQ	X-X/160*160-152

	MOVE.L	(A0)+,D0
	OR.L	(A3)+,D0
	OR	(A1),D0
	MOVE	D0,X+Y+xx(A2)
	SWAP	D0
	MOVE.L	D0,-40(A1)
	MOVE.L	D0,(A1)
X	SET	X+8

	IFNE	X-TAILLE*160
	LEA	40-2+4(A1),A1
	ENDC

	ENDC
	ENDR

	ADD.L	#TAILLE*80,BUFSCR.w
	ADD	#(LONGFONTE)*4,SHIFT1.w
	CMP	#(LONGFONTE)*4*(16/STEP),SHIFT1.w	;SCROLLER 4 EN 4
	BLO.S	L5102
	CLR	SHIFT1.w
	MOVE.L	#L6ECC,BUFSCR.w

	ADDQ	#2,L5E9A.w
	CMP	#40,L5E9A.w
	BNE.S	L50BC
	CLR	L5E9A.w
L50BC:
	MOVE.L	PTRTXT.w,A0
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BPL.S	L50F8
	MOVE.L	CURTEXT\W,A0
	MOVE.B	(A0)+,D0
L50F8:
	ASL	#5,D0
	ADD.L	#PREDEC,D0
	MOVE.L	D0,LETTRE1.w
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BPL.S	L50F82
	MOVE.L	CURTEXT\W,A0
	MOVE.B	(A0)+,D0
L50F82:
	ASL	#5,D0
	ADD.L	#PREDEC,D0
	MOVE.L	D0,LETTRE2.w
	MOVE.L	A0,PTRTXT.w
L5102:
	RTS
	SECTION	DATA
TEXTE:	INCBIN	MESSAGE.BIN
	even
FONTE:	DS.B	8
fonte:	incbin	fonte1.bin
FINFONTE:
	section	bss
PREDEC:	DS.B	2*4*(16/STEP)*(LONGFONTE)
FINPREDEC:
L6ECC:	DS.B	(16/STEP)*TAILLE*80	;BUFFER POUR SCROLLER
