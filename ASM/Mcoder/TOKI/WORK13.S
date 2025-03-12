	output	.tos
	opt	o+
CALCMASK = 0		;0=CALCUL DU MASQUE !!!
;
; 19/04/90 : nouvelle version avec d‚termination des couleurs utilis‚es
; 19/07/90 :
;	d‚buggage saisie automatique Amiga
;	 plantait quand moins de plans en entr‚e
;
; MOULINETTE DE FICHIERS .WRK
;
; types actuellement impl‚ment‚s
;
; 0=ST
; 1=AMIGA TYPE 1
; 2=AMIGA TYPE 2
; 3=AMIGA TYPE 3
; 4=AMIGA TYPE 4
; 5
; 6
; 7
; 8
; 9=AMIGA automatique
;
; format des fichiers sauv‚s :
;	- fichier entete .S du type :
;		DC.L nom du fichier+aaaaaaaa,bbccddee
;	aaaaaaaa=offset d‚but bitmap
;	bb=taille en X
;	cc=taille en Y
;	dd=d‚calage en X
;	ee=00 pour l'instant (d‚calage en Y)
;	- fichier .DAT (ST) ou .MAP (Amiga) contenant du bitmap pur
;
; le sprite est d‚cal‚ le plus en haut … gauche pour gagner des octets
;
GETKEY:	MACRO
	MOVE	#7,-(SP)
	TRAP	#1
	ADDQ	#2,SP
	ENDM
PRINT:	MACRO
	PEA	\1
	MOVE	#9,-(SP)
	TRAP	#1
	ADDQ	#6,SP
	ENDM
PUTC	MACRO
	MOVE	\1,-(SP)
	MOVE	#2,-(SP)
	TRAP	#1
	ADDQ	#4,SP
	ENDM
;
; message de bienvenue
;
	PRINT	WELLCOME(PC)
restart:
;
; saisie du nom du fichier … mouliner
;
	PRINT	inputname(pc)
	bsr	INPUT
	tst.b	(a0)
	beq	finished		;exit si CR

	PRINT	CR(pc)
;
; rajouter .WRK si pas de suffixe
;
	lea	filename(pc),a0
.end	tst.b	(a0)+
	bne.s	.end

	subq	#5,a0
	move.b	(a0)+,d0
	asl	#8,d0
	move.b	(a0)+,d0
	swap	d0
	move.b	(a0)+,d0
	asl	#8,d0
	move.b	(a0)+,d0
	and.l	#$ffdfdfdf,d0
	cmp.l	#'.WRK',d0
	beq.s	okwrk
	move.b	#'.',(a0)+
	move.b	#'W',(a0)+
	move.b	#'R',(a0)+
	move.b	#'K',(a0)+
	clr.b	(a0)+
okwrk:
;
; on fait la liste de tous les fichiers … mouliner
;
	pea	dta(pc)
	move	#$1a,-(sp)
	trap	#1		;setdta
	addq	#6,sp
	clr	-(sp)
	pea	filename(pc)
	move	#$4e,-(sp)
	trap	#1		;sfirst
	addq	#8,sp
	tst	d0
	bne	notfound
	clr	compte
	move.l	#bufnames,names
getall:
	addq	#1,compte
	lea	dta+30(pc),a0
	move.l	names,a1
copyname:
	move.b	(a0)+,(a1)+
	bne.s	copyname
	move.l	a1,names

	PRINT	dta+30(pc)
	PRINT	CR(pc)

	move	#$4f,-(sp)
	trap	#1		;snext
	addq	#2,sp

	tst.l	d0
	beq.s	getall
;
; directory fini
;
	move.l	#bufnames,names
;
; si un seul fichier -> afficher infos
;
	cmp	#1,compte
	bne.s	.noload
	bsr	loadname
	bsr	getplanes
	clr	compte
.noload
;
; entrer type de moulinette
;
	PRINT	inputtype(pc)
.reget	GETKEY
	sub	#'0',d0
	cmp	#10,d0
	bhs.s	.reget
	move	d0,TYPE

	tst	d0		;type 0=automatique ST
	beq.s	.automatique
	cmp	#9,d0		;type 9=automatique Amiga
	beq.s	.automatique

	moveq	#%1110,d0	;type 1
	cmp	#1,TYPE
	beq.s	.ata
	CMP	#5,TYPE
	beq.s	.ata
	moveq	#%1101,d0	;type 2
	cmp	#2,TYPE
	beq.s	.ata
	CMP	#6,TYPE
	beq.s	.ata
	moveq	#%1011,d0	;type 3
	cmp	#3,TYPE
	beq.s	.ata
	CMP	#7,TYPE
	beq.s	.ata
	moveq	#%0111,d0	;type 4
.ata
	move	d0,PLANOUT

.automatique
	move	TYPE,d0
	add	#'0',d0
	PUTC	d0
	PRINT	CR(pc)

	TST	TYPE
	BNE.S	AMIGATYP
;
; ST: entrer nb de plans … saisir
;
	PRINT	messplanes(pc)
.getit	GETKEY
	sub	#'0',d0
	beq.s	.getit
	cmp	#5,d0
	bhs.s	.getit

	move	d0,NBPLANOUT	;nb plans en sortie
	add	#'0',d0
	PUTC	d0
	PRINT	CR(pc)

	moveq	#%1111,d1

	tst	compte
	bne.s	10$

	move	NBPLANOUT,d0
	cmp	#4,d0
	beq.s	10$

	move	PLANIN,d1
	cmp	NBPLANIN,d0
	bne	errplan
10$	move	d1,PLANOUT

AMIGATYP:
	MOVE	#3,-(SP)
	TRAP	#14
	ADDQ	#2,SP
	MOVE.L	D0,ECRAN
;
; mouliner un fichier
;
boucle:
	PRINT	cursor_off(pc)

	tst	compte
	beq.s	.noload2
	bsr	loadname
	bsr	getplanes
.noload2
;
; ici :
;	PLANIN=configuration binaire en entr‚e
;	NBPLANIN=nb plans en entr‚e
;	PLANOUT=configuration binaire en sortie
;	NBPLANOUT=nb plans en sortie
;
;	move	PLANIN,d0	;plans r‚els
;	LEA	TAMPON,A5
;	and	34(A5),d0	;plans stock‚s
;	move	d0,PLANIN	;donne plans en entr‚e
;
	tst	TYPE
	beq	ata1

	MOVE	#3,NBPLANOUT		;NB PLANS EN SORTIE SUR AMIGA !!!

	cmp	#9,TYPE
	bne.s	.notype9

	move	PLANIN,PLANOUT
	cmp	#3,NBPLANIN
	bhs	ata1
	or	#%1000,PLANIN
	move	PLANIN,d1
	bsr	compteplans
	cmp	#3,d0
	bhs.s	.ata0
	or	#%0100,PLANIN
	move	PLANIN,d1
	bsr	compteplans
	cmp	#3,d0
	bhs.s	.ata0
	or	#%0010,PLANIN
	move	PLANIN,d1
	bsr	compteplans
	cmp	#3,d0
	bhs.s	.ata0
	or	#%0001,PLANIN
	move	PLANIN,d1
	bsr	compteplans
.ata0	MOVE	D0,NBPLANIN
	bra.s	ata1
.notype9
	move	PLANOUT,d0
	and	PLANIN,d0
	cmp	PLANIN,d0
	bne.s	errata2

	move	PLANOUT,PLANIN
	bra.s	ata2
errata2
	LEA	ERROR5(PC),A0
	BRA	ERREUR
ata1:
	move	NBPLANIN,d0
	cmp	NBPLANOUT,d0
	bls.s	ata3

	LEA	ERROR10(PC),A0
	BRA	ERREUR
ata3:
	move	PLANIN,d0
	cmp	PLANOUT,d0
	beq.s	ata2

	PRINT	warning1(pc)
ata2:
	LEA	TAMPON,A5
	MOVE.L	FINBUF,A6

	CLR	(A6)+		;NB DE SPRITES
	CLR	NBSPR
	lea	64(a5),a4
	lea	128(a5),a5	;skippe en tete
	MOVE.L	A6,A3
;
; COMPTE LE NB DE SPRITES
;
	MOVE.L	A4,A0
	moveq	#16-1,d0
COUNT2:
	moveq	#7,d1
COUNT:
	btst	d1,(a0)
	beq.s	NCOUNT
;
; A6=POINTEUR DESTINATION CARACTERISTIQUES
; A3=POINTEUR DESTINATION BITMAP
;
	CLR.L	(A3)+
	CLR.L	(A3)+
NCOUNT:
	dbra	d1,COUNT
	addq	#1,a0
	dbra	d0,COUNT2

	MOVE.L	A3,BITMAP
.amiga
;
; SAISIE LES SPRITES
;
	moveq	#16-1,d0
test2:
	moveq	#7,d1
test:
	btst	d1,(a4)
	beq.s	nospr
;
; A6=POINTEUR DESTINATION CARACTERISTIQUES
; A3=POINTEUR DESTINATION BITMAP
;
	MOVEM.L	D0/D1/A4/A5,-(SP)
	bsr	takesprite
;	move	#-1,d0
;waitt:	dbra	d0,waitt
	MOVEM.L	(SP)+,D0/D1/A4/A5
	lea	64*64/2(a5),a5	;next image
nospr:
	dbra	d1,test
	addq	#1,a4
	dbra	d0,test2

	MOVE.L	A3,A5
	MOVE.L	FINBUF,A4
	MOVE	NBSPR,(A4)
;
; sauvegarde format AMIGA
;
	MOVE.L	A5,CURRENT
	move	(a4)+,d0
	asl	#3,d0
	add	d0,a4		;saute entete

	move.l	names,a0
.end2	tst.b	(a0)+
	bne.s	.end2
	subq	#4,a0
	tst	TYPE
	beq.s	.atar
	move.b	#'M',(a0)+
	move.b	#'A',(a0)+
	move.b	#'P',(a0)+
	bra.s	.zero
.atar
	move.b	#'D',(a0)+
	move.b	#'A',(a0)+
	move.b	#'T',(a0)+
.zero:
	clr.b	(a0)+
	move.l	names,a6
	bsr	SAVEFILE
;
; A4=DEBUT DU FICHIER
; A5=FIN DU FICHIER
; A6=NOM DU FICHIER
;
; GENERATION DU FICHIER .S
;
	MOVE.L	CURRENT,A5
	MOVE.L	FINBUF,A0	;PTR SOURCE
	MOVE	(A0)+,D7

	move.b	#';',(a5)+
	moveq	#0,d0
	move	d7,d0
	bsr	genhexa

	move.b	#'(',(a5)+
	move	d7,d0
	asl	#3,d0
	move.l	CURRENT,a1
	sub.l	FINBUF,a1
	sub	d0,a1
	move.l	a1,d0
	bsr	genhexa
	move.b	#')',(a5)+

;	move.b	#13,(a5)+
	move.b	#10,(a5)+

	move.b	#'I',(a5)+
	move.b	#'M',(a5)+
	move.b	#'A',(a5)+
	move.b	#'G',(a5)+
	move.b	#'E',(a5)+
	MOVE.L	names,a1
.name2	move.b	(a1)+,(a5)+
	bne.s	.name2
	subq	#5,a5
	move.b	#':',(a5)+
	move.b	#10,(a5)+

.NEXT
	MOVE.B	#9,(A5)+
	MOVE.B	#'D',(A5)+
	MOVE.B	#'C',(A5)+
	MOVE.B	#'.',(A5)+
	MOVE.B	#'L',(A5)+
	MOVE.B	#9,(A5)+
	MOVE.L	names,a1
.name	move.b	(a1)+,(a5)+
	bne.s	.name
	subq	#5,a5
	MOVE.B	#'+',(A5)+
	move.l	4(a0),d0
	bsr	genhexa
	move.b	#',',(a5)+

	move.l	(a0),d0
	tst	TYPE
	beq.s	.atari
	cmp	#5,TYPE
	bhs.s	.atari

	moveq	#0,d0
	move.b	(a0),d0
	add	#15,d0
	and	#-16,d0
	swap	d0
	move.b	1(a0),d0
.atari
	bsr	genhexa
;	move.b	#13,(a5)+
	move.b	#10,(a5)+

	addq	#8,a0
	SUBQ	#1,D7
	BNE.S	.NEXT
	move.l	CURRENT,A4

	move.l	names,a0
.end3	tst.b	(a0)+
	bne.s	.end3
	subq	#4,a0
	move.b	#'S',(a0)+
	clr.b	(a0)+
	move.l	names,a6
	bsr	SAVEFILE
	move.l	names,a0
.end4	tst.b	(a0)+
	bne.s	.end4
	st	-(a0)
;
; A4=DEBUT DU FICHIER
; A5=FIN DU FICHIER
; A6=NOM DU FICHIER
;

cont:	tst	compte
	beq.s	end_code
	move.l	names,a0
.searend:tst.b	(a0)+
	bne.s	.searend
	move.l	a0,names
	subq	#1,compte
	bne	boucle
end_code:
	PRINT	cursor_on(pc)
	bra	restart
;	PRINT	another(pc)
;	GETKEY
;	and	#$df,d0
;	cmp	#'O',d0
;	bne.s	finished
;	PUTC	d0
;	PRINT	CR(pc)
;	bra	restart
finished:
	CLR	-(SP)
	TRAP	#1
ERREUR:
	PRINT	(A0)
	PRINT	CR(pc)
	cmp	#1,compte
	bls.s	end_code

	PRINT	cursor_on(pc)
	PRINT	continue(pc)
	GETKEY
	move	d0,-(sp)
	PUTC	d0
	PRINT	CR(pc)
	move	(sp)+,d0
	and	#$df,d0
	cmp	#'O',d0
	bne.s	end_code
	bra	cont

genhexa:
	move.b	#'$',(a5)+
	moveq	#8-1,d1
.hex1
	rol.l	#4,d0
	moveq	#15,d2
	and	d0,d2
	bne.s	.hex2
	dbra	d1,.hex1
	move.b	#'0',(a5)+
	rts
.hex4	rol.l	#4,d0
	moveq	#15,d2
	and	d0,d2
.hex2
	cmp	#10,d2
	blo.s	.hex3
	addq	#7,d2
.hex3	add	#'0',d2
	move.b	d2,(a5)+
	dbra	d1,.hex4
	rts
;
; SAISIT LES SPRITES ET LES DECALE AU MAXIMUM EN HAUT A GAUCHE
;  PUIS LES REPREND ET GENERE LE FICHIER .SPRITE
;
;	FORMAT :
;		.B=NB PIXELS EN X
;		.B=NB PIXELS EN Y
;		.B=DECALAGE EN X
;		.B=DECALAGE EN Y
;		.L=OFFSET DEBUT SPRITE
;
takesprite:
;
; 1) EFFACEMENT DE L'ECRAN (64 premiŠres lignes)
;
	MOVE.L	ECRAN,A0
	MOVE	#64*160/4-1,D0
	MOVEQ	#0,D1
CLS:	MOVE.L	D1,(A0)+
	DBRA	D0,CLS
;
; 2) TRANSFERT DU SPRITE A L'ECRAN
;
	MOVEQ	#64-1,d7
	move.l	a5,a0
	MOVE.L	ECRAN,A1
	MOVEQ	#0,D1
copyspr:
	MOVEQ	#4-1,D3
COPYSPR3:
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	DBRA	D3,COPYSPR3

	LEA	160-32(A1),A1
	dbra	d7,copyspr
;
; 2 BIS EFFACEMENT DE LA LIGNE 64
;
	MOVE.L	ECRAN,A0
	LEA	63*160(A0),A0
	MOVE	#64/2/4-1,D0
	MOVEQ	#0,D1
CLR64:	MOVE.L	D1,(A0)+
	DBRA	D0,CLR64
;
; 3) INITIALISATION DES VARIABLES EN SORTIE
;
	MOVE	#64,NBCOL
	MOVE	#64,NBLIG
	CLR	DECX
	CLR	DECY
;
; 4) CENTRAGE EN HAUT DU SPRITE
;
UP:
	MOVE.L	ECRAN,A0
	MOVE	#160/4-1,D0
	MOVEQ	#0,D1
TSTUP:	OR.L	(A0)+,D1
	DBRA	D0,TSTUP
	TST.L	D1
	BNE.S	NOTUP

	MOVE.L	ECRAN,A0
	LEA	160(A0),A1
	MOVE	#63*160/4-1,D0
COPUP:
	MOVE.L	(A1)+,(A0)+
	DBRA	D0,COPUP
	ADDQ	#1,DECY
	SUBQ	#1,NBLIG
	BNE.S	UP
	LEA	ERROR6(PC),A0
	BRA	ERREUR
NOTUP:
DOWN:
	MOVE	NBLIG,D0
	MULU	#160,D0
	MOVE.L	ECRAN,A0
	ADD	D0,A0
	MOVE	#160/4-1,D0
	MOVEQ	#0,D1
TSTDN:	OR.L	-(A0),D1
	DBRA	D0,TSTDN
	TST.L	D1
	BNE.S	NOTDN
	SUBQ	#1,NBLIG
	BNE.S	DOWN
	LEA	ERROR7(PC),A0
	BRA	ERREUR
NOTDN:
;	CMP	#9,TYPE		;TYPE 9 ???
;	BHS	NOTLF
	cmp	#5,TYPE
	bhs.s	LEFT
	TST	TYPE
	BNE.s	NOTLF
LEFT:
	MOVE.L	ECRAN,A0
	MOVE	NBLIG,D0
	SUBQ	#1,D0
	MOVEQ	#0,D1
TSTLF:	OR	(A0)+,D1
	OR	(A0)+,D1
	OR	(A0)+,D1
	OR	(A0)+,D1
	LEA	160-8(A0),A0
	DBRA	D0,TSTLF
	TST	D1
	BMI.S	NOTLF
;
; SCROLLE A GAUCHE
;
	MOVE.L	ECRAN,A1
	MOVEQ	#4-1,D0
SCR2:
	MOVE.L	A1,A0
	MOVE	NBLIG,D1
	SUBQ	#1,D1
SCR1:
	ASL	24(A0)
	ROXL	16(A0)
	ROXL	8(A0)
	ROXL	(A0)
	LEA	160(A0),A0
	DBRA	D1,SCR1

	ADDQ	#2,A1
	DBRA	D0,SCR2

	ADDQ	#1,DECX
	SUBQ	#1,NBCOL
	BNE.S	LEFT
	LEA	ERROR8(PC),A0
	BRA	ERREUR
NOTLF:
RIGHT:
	MOVE	NBCOL,D0
	SUBQ	#1,D0
	AND	#$FFF0,D0
	LSR	#1,D0
	MOVE.L	ECRAN,A0
	ADD	D0,A0
	MOVE	NBLIG,D0
	SUBQ	#1,D0
	MOVEQ	#0,D1
TSTRG:	OR	(A0)+,D1
	OR	(A0)+,D1
	OR	(A0)+,D1
	OR	(A0)+,D1
	LEA	160-8(A0),A0
	DBRA	D0,TSTRG

;	TST	D1
;	BEQ	BUG		;16 PIXELS GAUCHE VIDES

	MOVE	NBCOL,D0
	SUBQ	#1,D0
	AND	#$F,D0
	EOR	#$F,D0
	BTST	D0,D1
	BNE.S	NORG
	SUBQ	#1,NBCOL
	BEQ.S	BUG1
	BRA.S	RIGHT
BUG1:
	LEA	ERROR9(PC),A0
	BRA	ERREUR
NORG:
	MOVE	NBCOL,D0
	MOVE	NBLIG,D1
	MOVE	DECX,D2
;	MOVE	DECY,D3

	MOVE	TYPE,D3
	BEQ.S	AMIGA1
	cmp	#5,d3
	bhs.s	AMIGA1
	MOVE	D3,D2
AMIGA1:
	CLR	D3
	MOVE.B	D0,(A6)+
	MOVE.B	D1,(A6)+
	MOVE.B	D2,(A6)+
	MOVE.B	D3,(A6)+
	MOVE.L	A3,D0
	SUB.L	BITMAP,D0
	MOVE.L	D0,(A6)+

	ADDQ	#1,NBSPR

	TST	TYPE
	BNE.S	GENAMIGA

	MOVE	NBLIG,D7
	SUBQ	#1,D7
	MOVE	NBCOL,D6
	ADD	#15,D6
	LSR	#4,D6
	SUBQ	#1,D6
	MOVE.L	ECRAN,A0
	MOVE	PLANOUT,D2
TAKE1:
	MOVE	D6,D0
	MOVE.L	A0,A1
TAKE2:
	BTST	#0,D2
	BEQ.S	X0
	MOVE	(A1),(A3)+
X0:
	NOT	(A1)+
	BTST	#1,D2
	BEQ.S	X1
	MOVE	(A1),(A3)+
X1:
	NOT	(A1)+
	BTST	#2,D2
	BEQ.S	X2
	MOVE	(A1),(A3)+
X2:
	NOT	(A1)+
	BTST	#3,D2
	BEQ.S	X3
	MOVE	(A1),(A3)+
X3:
	NOT	(A1)+
	DBRA	D0,TAKE2
	LEA	160(A0),A0
	DBRA	D7,TAKE1

	rts
GENAMIGA:
	MOVE	NBLIG,D7
	SUBQ	#1,D7
	MOVE	NBCOL,D6
	ADD	#15,D6
	LSR	#4,D6

	MOVE	D6,D5
	MULU	NBLIG,D5
	ADD	D5,D5

	MOVE	PLANIN,D4

	SUBQ	#1,D6
	MOVE.L	ECRAN,A0
TAKE3:
	MOVE	D6,D0
	MOVE.L	A0,A1
TAKE4:
	CLR	D3
	BTST	#0,D4
	BEQ.S	T0
	IFEQ	CALCMASK
	OR	(A1),D3
	ENDC
	MOVE	(A1),(A3)
	ADD	D5,A3
	BRA.S	T01
T0:
	IFNE	CALCMASK
	MOVE	(A1),D3
	ENDC
T01:
	NOT	(A1)+
	BTST	#1,D4
	BEQ.S	T1
	IFEQ	CALCMASK
	OR	(A1),D3
	ENDC
	MOVE	(A1),(A3)
	ADD	D5,A3
	BRA.S	T11
T1:
	IFNE	CALCMASK
	MOVE	(A1),D3
	ENDC
T11:
	NOT	(A1)+
	BTST	#2,D4
	BEQ.S	T2
	IFEQ	CALCMASK
	OR	(A1),D3
	ENDC
	MOVE	(A1),(A3)
	ADD	D5,A3
	BRA.S	T21
T2:
	IFNE	CALCMASK
	MOVE	(A1),D3
	ENDC
T21:
	NOT	(A1)+
	BTST	#3,D4
	BEQ.S	T3
	IFEQ	CALCMASK
	OR	(A1),D3
	ENDC
	MOVE	(A1),(A3)
	ADD	D5,A3
	BRA.S	T31
T3:
	IFNE	CALCMASK
	MOVE	(A1),D3
	ENDC
T31:
	NOT	(A1)+

;	IFEQ	CALCMASK
;	NOT	D3		;PAS DE NOT POUR LE MASQUE
;	ENDC
	MOVE	D3,(A3)+
	CMP	#2,NBPLANOUT
	BEQ.S	.2PLANS
.3PLANS	SUB	D5,A3
.2PLANS	SUB	D5,A3
	SUB	D5,A3
	DBRA	D0,TAKE4
	LEA	160(A0),A0
	DBRA	D7,TAKE3
	CMP	#2,NBPLANOUT
	BEQ.S	.2PL
	ADD	D5,A3
.2PL	ADD	D5,A3
	ADD	D5,A3
	rts

INPUT:
	PEA	filename-2(pc)
	move	#$a,-(sp)
	trap	#1
	addq	#6,sp
	lea	filename-1(pc),a0
	clr	d0
	move.b	(a0)+,d0
	clr.b	(a0,d0.w)
	rts

READFILE:
	PRINT	MESS3(PC)		;LOADING FILE
	PRINT	(A6)
	PRINT	CR(PC)
	CLR	-(SP)		;OPEN LECTURE
	PEA	(a6)		;FILENAME
	MOVE	#$3D,-(SP)
	TRAP	#1
	ADDQ	#8,SP
	MOVE.L	D0,D7			;D7=HANDLE
	BMI	ERREUR1
	PEA	(a5)		;ADRESSE
	PEA	200000		;LONGUEUR
	MOVE	d7,-(SP)	;HANDLE
	MOVE	#$3F,-(SP)
	TRAP	#1
	LEA	12(SP),SP
	MOVE.L	D0,D6			;D6=NB BYTES
	BMI	ERREUR1
	ADD.L	D6,A5
	MOVE	d7,-(SP)	;HANDLE
	MOVE	#$3E,-(SP)
	TRAP	#1
	ADDQ	#4,SP
	RTS
;
; A4=DEBUT
; A5=FIN
; A6=NOM DU FICHIER
;
SAVEFILE:
	PRINT	MESS4(PC)		;SAVING FILE
	PRINT	(A6)
	PRINT	CR(PC)
	PEA	(a6)
	MOVE	#$41,-(SP)
	TRAP	#1
	ADDQ	#6,SP
	CLR	-(SP)
	PEA	(a6)
	MOVE	#$3C,-(SP)
	TRAP	#1
	ADDQ	#8,SP
	MOVE.L	D0,D7			;D7=HANDLE
	BMI	ERREUR2
	SUB.L	A4,A5
	PEA	(a4)		;ADRESSE
	PEA	(a5)		;LONGUEUR
	MOVE	d7,-(SP)	;HANDLE
	MOVE	#$40,-(SP)
	TRAP	#1
	LEA	12(SP),SP
	MOVE.L	D0,D6			;D6=NB BYTES
	BMI	ERREUR2
	MOVE	d7,-(SP)	;HANDLE
	MOVE	#$3E,-(SP)
	TRAP	#1
	ADDQ	#4,SP
	RTS
;
loadname:
	move.l	names(PC),A6
	LEA	TAMPON,A5
	BSR	READFILE
	MOVE.L	A5,FINBUF
	rts
getplanes
	LEA	TAMPON,A0
	CMP	#'02',(A0)
	BNE	ERREUR3

	move.l	FINBUF,a5
	lea	128(a0),a0
	moveq	#0,d0
	lea	colors(pc),a1
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+	;clear fr‚quence couleurs

	lea	colors(pc),a4

	cmp.l	a5,a0
	bhs.s	nomorecol

bccol:
	moveq	#16-1,d7
	movem	(a0)+,d0-d3
gencol:
	clr	d4
	add	d3,d3
	addx	d4,d4
	add	d2,d2
	addx	d4,d4
	add	d1,d1
	addx	d4,d4
	add	d0,d0
	addx	d4,d4
	addq.b	#1,(a4,d4.w)
	bne.s	.not0
	subq.b	#1,(a4,d4.w)
.not0
	dbra	d7,gencol
	cmp.l	a5,a0
	blo.s	bccol
nomorecol:
	clr.b	(a4)

	PRINT	messcol(pc)

	moveq	#0,d6		;nb couleurs utilis‚es
	moveq	#0,d7
affcol:
	tst.b	(a4)+
	beq.s	nocolo
	tst	d6
	beq.s	.novirg
	PUTC	<#",">
.novirg
	move	d7,d5		;last color used
	addq	#1,d6

	cmp	#10,d7
	blo.s	.low10
	PUTC	#"1"
.low10
	move	d7,d0
	cmp	#10,d0
	blo.s	.ok9
	sub	#10,d0
.ok9:	add	#'0',d0
	PUTC	d0
nocolo:
	addq	#1,d7
	cmp	#16,d7
	blo.s	affcol
	PRINT	CR(pc)

	cmp	#1,d6		;correction bug monoplan
	bne.s	.paone		;17/07/90

	moveq	#%1000,d6
	and	d5,d6
	bne.s	.onlyone
	moveq	#%100,d6
	and	d5,d6
	bne.s	.onlyone
	moveq	#%10,d6
	and	d5,d6
	bne.s	.onlyone
	moveq	#%1,d6
	and	d5,d6
	bra.s	.onlyone
.paone
	moveq	#%1111,d6

	lea	colors(pc),a0
	bsr	pl0
	lea	colors+1(pc),a0
	bsr	pl0

	lea	colors(pc),a0
	bsr	pl1
	lea	colors+2(pc),a0
	bsr	pl1

	lea	colors(pc),a0
	bsr	pl2
	lea	colors+4(pc),a0
	bsr	pl2

	lea	colors(pc),a0
	bsr	pl3
	lea	colors+8(pc),a0
	bsr	pl3
.onlyone
	move	d6,d4
	move	d6,d1
	bsr	compteplans
	move	d0,d5

	move	d4,PLANIN
	MOVE	D5,NBPLANIN

	MOVEQ	#'0',D0
	ADD	D5,D0
	PUTC	d0
	PRINT	PLANUSED(PC)

	PRINT	USEDPLANES(PC)

	MOVE	PLANIN,D7
	ASL	#4,D7
	MOVEQ	#4-1,D6
.XX	MOVEQ	#'0'/2,D0
	ADD.B	D7,D7
	ADDX	D0,D0
	PUTC	d0
	DBRA	D6,.XX

	PRINT	CR(PC)
	rts
;
; couleurs paires
;
pl0:
	tst.b	(a0)
	bne.s	1$
	tst.b	2(a0)
	bne.s	1$
	tst.b	4(a0)
	bne.s	1$
	tst.b	6(a0)
	bne.s	1$
	tst.b	8(a0)
	bne.s	1$
	tst.b	10(a0)
	bne.s	1$
	tst.b	12(a0)
	bne.s	1$
	tst.b	14(a0)
	bne.s	1$
	bclr	#0,d6
1$	rts
;
pl1:
	tst.b	(a0)
	bne.s	1$
	tst.b	1(a0)
	bne.s	1$
	tst.b	4(a0)
	bne.s	1$
	tst.b	5(a0)
	bne.s	1$
	tst.b	8(a0)
	bne.s	1$
	tst.b	9(a0)
	bne.s	1$
	tst.b	12(a0)
	bne.s	1$
	tst.b	13(a0)
	bne.s	1$
	bclr	#1,d6
1$	rts
;
pl2:
	tst.b	(a0)
	bne.s	1$
	tst.b	1(a0)
	bne.s	1$
	tst.b	2(a0)
	bne.s	1$
	tst.b	3(a0)
	bne.s	1$
	tst.b	8(a0)
	bne.s	1$
	tst.b	9(a0)
	bne.s	1$
	tst.b	10(a0)
	bne.s	1$
	tst.b	11(a0)
	bne.s	1$
	bclr	#2,d6
1$	rts
;
pl3:
	tst.b	(a0)
	bne.s	1$
	tst.b	1(a0)
	bne.s	1$
	tst.b	2(a0)
	bne.s	1$
	tst.b	3(a0)
	bne.s	1$
	tst.b	4(a0)
	bne.s	1$
	tst.b	5(a0)
	bne.s	1$
	tst.b	6(a0)
	bne.s	1$
	tst.b	7(a0)
	bne.s	1$
	bclr	#3,d6
1$	rts

colors:	ds.b	16


	ifeq	1
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	cmp.l	a5,a0
	bhs.s	.findet
.determ
	or	(a0)+,d0
	or	(a0)+,d1
	or	(a0)+,d2
	or	(a0)+,d3
	cmp.l	a5,a0
	blo.s	.determ
.findet
	CLR	D5
	moveq	#0,d4
	tst	d0
	beq.s	1$
	ADDQ	#1,D5
	addq	#1,d4
1$	tst	d1
	beq.s	2$
	addq	#2,d4
	ADDQ	#1,D5
2$	tst	d2
	beq.s	3$
	addq	#4,d4
	ADDQ	#1,D5
3$	tst	d3
	beq.s	4$
	addq	#8,d4
	ADDQ	#1,D5
4$
;	CMP	#4,D5
;	BNE.S	GOODPLA
;
; DETERMINATION DES PLANS ORES
;
	lea	TAMPON+128,a0
	cmp.l	a5,a0
	bhs	GOODPLA
.determ2
	MOVE	(a0)+,d0
	MOVE	(a0)+,d1
	or	(a0)+,d1
	or	(a0)+,d1
	or	d0,d1
	cmp	d0,d1
	beq.s	.11
	not	d1
	CMP	D0,D1
	BNE.S	.findet2
.11	cmp.l	a5,a0
	blo.s	.determ2
	bclr	#0,d4
	beq.s	.findet2
	subq	#1,d5
.findet2
	lea	TAMPON+128,a0
.determ3
	MOVE	(a0)+,d1
	MOVE	(a0)+,d0
	or	(a0)+,d1
	or	(a0)+,d1
	or	d0,d1
	CMP	D0,D1
	beq.s	.12
	not	d1
	CMP	D0,D1
	BNE.S	.findet3
.12	cmp.l	a5,a0
	blo.s	.determ3
	bclr	#1,d4
	beq.s	.findet3
	subq	#1,d5
.findet3
	lea	TAMPON+128,a0
.determ4
	MOVE	(a0)+,d1
	or	(a0)+,d1
	MOVE	(a0)+,d0
	or	(a0)+,d1
	or	d0,d1
	cmp	d0,d1
	beq.s	.13
	not	d1
	CMP	D0,D1
	BNE.S	.findet4
.13	cmp.l	a5,a0
	blo.s	.determ4
	bclr	#2,d4
	beq.s	.findet4
	subq	#1,d5
.findet4
	lea	TAMPON+128,a0
.determ5
	MOVE	(a0)+,d1
	or	(a0)+,d1
	or	(a0)+,d1
	MOVE	(a0)+,d0
	or	d0,d1
	cmp	d0,d1
	beq.s	.14
	not	d1
	CMP	D0,D1
	BNE.S	.findet5
.14	cmp.l	a5,a0
	blo.s	.determ5
	bclr	#3,d4
	beq.s	.findet5
	subq	#1,d5
.findet5
GOODPLA:
	move	d4,PLANIN
	MOVE	D5,NBPLANIN

	MOVEQ	#'0',D0
	ADD	D5,D0
	PUTC	d0
	PRINT	PLANUSED(PC)

	PRINT	USEDPLANES(PC)

	MOVE	PLANIN,D7
	ASL	#4,D7
	MOVEQ	#4-1,D6
.XX	MOVEQ	#'0'/2,D0
	ADD.B	D7,D7
	ADDX	D0,D0
	PUTC	d0
	DBRA	D6,.XX

	PRINT	CR(PC)
	rts
	endc

compteplans:
	CLR	D0		;comptage des plans
.cp3:	tst.b	d1
	BEQ.S	.cp1
	lsr.b	#1,d1
	bcc.s	.cp3
	addq	#1,d0
	bra.s	.cp3
.cp1	rts

notfound:
ERREUR1:
	LEA	ERROR1(PC),A0
	BRA	ERREUR
ERREUR2:
	LEA	ERROR2(PC),A0
	BRA	ERREUR
ERREUR3:
	LEA	ERROR3(PC),A0
	BRA	ERREUR
errplan:
	LEA	ERROR11(PC),A0
	BRA	ERREUR

NBPLANIN:DC.W	0		;nb plans en entr‚e
NBPLANOUT:dc.w	0		;nb plans en sortie
PLANIN:	dc.w	0		;configuration plans en entr‚e
PLANOUT:DC.W	0		;configuration plans en sortie

compte:	dc.w	0		;compteur de fichiers lus
names:	dc.l	0		;ptr nom des fichiers … charger

NBCOL:	DC.W	0
NBLIG:	DC.W	0
DECX:	DC.W	0
DECY:	DC.W	0
TYPE:	dc.w	0
NBSPR:	DC.W	0
ECRAN:	DC.L	0
FINBUF:	DC.L	0
BITMAP:	DC.L	0
CURRENT:DC.L	0
ERROR1:	DC.B	'FILE NOT FOUND...',0
ERROR2:	DC.B	'ERROR DURING WRITING',0
ERROR3:	DC.B	"C'est quoi ce .WRK ???",0
ERROR5:	DC.B	"Cr‚tin ! Mais o— sont les 3 plans ???",0

ERROR6:	DC.B	"ERREUR INTERNE 1",0
ERROR7:	DC.B	"ERREUR INTERNE 2",0
ERROR8:	DC.B	"ERREUR INTERNE 3",0
ERROR9:	DC.B	"ERREUR INTERNE 4",0
ERROR10:DC.B	"Erreur sur les bitplanes",0
ERROR11:DC.B	"Pas assez de plans",0

MESS3:	DC.B	"LOADING FILE ",0
MESS4:	dc.b	"SAVING FILE ",0
CR:	DC.B	13,10,0
WELLCOME:DC.B	27,"EMoulinette .WRK version 1.0",13,10
	dc.b	10,10,0
inputname:dc.b	"Nom du fichier … mouliner (CR=quit):",13,10,0
messcol:dc.b	"Couleurs utilis‚es : ",0
PLANUSED:	DC.B	" plans utilis‚s",13,10,0
USEDPLANES:DC.B	13,"configuration : ",0
inputtype:dc.b	"0->ST",13,10
	DC.B	"1->AMIGA PALETTE 1 (1110)",13,10
	DC.B	"2->AMIGA PALETTE 2 (1101)",13,10
	DC.B	"3->AMIGA PALETTE 3 (1011)",13,10
	DC.B	"4->AMIGA PALETTE 4 (0111)",13,10
	DC.B	"5->TOKI PALETTE 1 (1110)",13,10
	DC.B	"6->TOKI PALETTE 2 (1101)",13,10
	DC.B	"7->TOKI PALETTE 3 (1011)",13,10
	DC.B	"8->TOKI PALETTE 4 (0111)",13,10
	DC.B	"9->AMIGA",13,10
	DC.B	"Quel type (0-9) : ",0

cursor_off:dc.b	27,'f',0
cursor_on:dc.b	27,'e',0
messplanes:dc.b	"Nb plans (1-4) : ",0
warning1:dc.b	7,"Dessin n'utilisant pas les 4 plans",13,10,0
;warning2:dc.b	"Warning : plans enlev‚s",13,10,0
;another:dc.b	"Un autre fichier (Oui) ? ",0
continue:dc.b	'Continuer (O) ? ',0
	EVEN
	dc.b	38,0
filename:
	ds.b	40
	section	bss
dta:	ds.b	50
bufnames:ds.b	5000
TAMPON:
