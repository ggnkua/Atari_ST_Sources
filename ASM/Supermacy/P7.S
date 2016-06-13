*salut a captain 64...malgre ce que tu va voir apres avoir
* fait assemble et run  cette demo est bordelique !!!
*il faut ke je rajoute des hbl...ca prendra un peu de temps...
*alors je te fais patienter ...si tu veut tu peux changer le text
*du scroll avec les explication que je te donne en bas...
*si tu a a m'envoyer des trucs sur + d'1  d(pour le serveur je pense)
*n'hesite pas je te  rembourserait celle en trop...a++
*                                   zetoun
* Registres du MK68901

IEA	EQU	$FFFA07
IEB	EQU	$FFFA09
ISRA	EQU	$FFFA0F
IMA	EQU	$FFFA13
TBCR	EQU	$FFFA1B
TBDR	EQU	$FFFA21

* Registre de l'‚cran

MODE	EQU	$FF8260

* Registres d'execptions

VBL_VEC	EQU	$70
HBL_VEC	EQU	$120

*---- DEFINITION DE MACRO -------------*
* Cette macro sera utilis‚e dans
* la d‚compression des images PC1
SEPT:MACRO
	ADDQ.B	#1,D3
	MOVE.L	A4,D5
	BTST	#0,D5
	BNE	.RETOUR
	ADD.L	A0,A4
.RETOUR	SUBQ.B	#1,D0
	ENDM
	
*--------------------------------------------*
START:	MOVE.L 	A7,A5
	LEA.L 	PILE,A7
	MOVE.L 	4(A5),A5
	MOVE.L 	12(A5),D0
	ADD.L 	20(A5),D0
	ADD.L 	28(A5),D0
	ADD.L 	#$100,D0
	MOVE.L	D0,-(SP)
           MOVE.L 	A5,-(SP)
	MOVE.W 	#0,-(SP)
	MOVE.W 	#74,-(SP)	M_shrink
	TRAP 	#1
	LEA 	12(A7),A7
		
* passage en superviseur et sauve la pile
	
	CLR.L 	-(SP)
	MOVE.W 	#$20,-(SP)
	TRAP 	#1	
	ADDQ.L 	#6,SP
	MOVEA.L 	#ANC_PILE,A0
	MOVE.L	D0,(A0)

* Teste  r‚solution, et si on est en haute, bye bye!
	CMPI.B	#$02,$FF8260
	BEQ	RAP_FIN
	
	MOVEA.L	#ANC_MODE,A1	sauve la
	MOVE.B	MODE,(A1)+		r‚solution
	
	MOVE.B	#0,MODE	passe en basse 
	
* d‚connecte la souris	
	MOVE.L	#MOUSEOF,-(SP)
	MOVE.W	#0,-(SP)
	MOVE.W 	#25,-(SP)
	TRAP 	#14
	ADDQ.L 	#8,SP

* Coupe le curseur du TOS
	MOVE.W	#0,-(SP)
	MOVE.W	#0,-(SP)
	MOVE.W	#21,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP

* sauvegarde de la palette
* met un Vsync avant
	MOVE.W	#37,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	
	MOVE.W	#000,D0
	LEA	$FF8240,A1
	LEA	ANC_PAL,A0
SAUVE_PAL	MOVE.W	(A1)+,(A0)+
	DBF	D0,SAUVE_PAL
	
* Efface l'‚cran puis met le tour et le fond en noir
	MOVE.L	#MESSAGE1,-(SP)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
	MOVE.W	#$000,$FF8240
	MOVE.W	#$000,$FF825E
	
* On va decompresser les images
* et les recopier ds les buffers.
	BSR	LES_IMAGES	
	BSR	ZIC_ON
	
* initialise les valeurs utilis‚es
* dans les sub routine en interup.
* T_VERT = position du trait vert
* T_ROUGE position du rouge
* BASC_TRAIT Bascule pour savoir si
* le trait monte ou descend
* ROUL_ON Bascule car on ne fait
* pas bouger tout le temps les
* trait en m‚me temps que les
* rouleaux.
* DECAL_PAL1 d‚calage par rapport
* … l'origine de la palette
* rouleaux bleu.
	MOVE.B	#13,T_VERT
	MOVE.B	#2,T_ROUGE
	MOVE.B	#0,BASC_TRAIT
	MOVE.B	#0,ROUL_ON
	MOVE.L	#0,DECAL_PAL1
		
* Sauvegarde des valeurs du syst‚me
	LEA	ANC_IEA,A0
	MOVE.B	IEA,(A0)
	
	LEA	ANC_IEB,A0
	MOVE.B	IEB,(A0)
	
	LEA	ANC_IMA,A0
	MOVE.B	IMA,(A0)
	
	AND.B	#$DF,IEB	arr‚te timer C
	AND.B	#$FE,IEA	arr‚te timer B
	
	LEA	ANC_HBL,A0	sauve ancienne HBL
	MOVE.L	HBL_VEC,(A0)
	
	LEA	HBL_INTER,A0	y met notre
	MOVE.L	A0,HBL_VEC		routine
	
	OR.B	#1,IEA	stop HBL interup.
	OR.B	#1,IMA	(pour le moment!)
	
* Nous allons mettre en place la routine dans la VBL
* (test d'emplacement disponible etc...)

	MOVE.W	$454,D0	combien de VBL disponibles
	SUBQ.W	#1,D0
	MOVEA.L	$456,A0	pointeur sur liste VBL
CHERCHE	TST.L	(A0)+
	BEQ.S	TROUVE
	DBF	D0,CHERCHE
	
TROUVE	SUBQ.L	#4,A0	car on a pass‚ l'endroit
	MOVE.L	A0,SAUVE
	LEA	VBL_INTER,A1
	MOVE.L	A1,(A0)
		
	* init le pointeur texte *
	MOVE.L 	#MES,MESPOINT
	
	* 1er caractŠre = espace *
	BSR 	SPACE 		
	***************************
	*   Routine principale    *
	***************************
* NOTE. Suivant le nombre de plan que l'on 
* scrolle, on peut mettre + ou - de
* BSR SCROLL.Pour 4 plans, 2 BSR 
* c'est le maxi !
* Il n'est pas possible de mettre SCROLL
* et SWAP en interup VBL, c'est trop sacad‚.	
VROOM	BSR 	SCROLL ; scroll de 2*1 pix
	BSR 	SCROLL ; ( plus si vous voulez)
	BSR 	SCROLL ; ( plus si vous voulez)
	BSR 	SWAP	 ; affiche l'‚cran
	
	CMPI.B	#$39,$00FFFC02	barre d'espace ?
	BNE.S	VROOM
	clr.l	$4d2
FIN	MOVE.L	SAUVE,A0	une VBL de plus
	MOVE.L	#0,(A0)	pour les copains.
	MOVE.W	$454,D0
	ADDQ.W	#1,D0

	LEA	ANC_IEA,A0
	MOVE.B	(A0),IEA
	
	LEA	ANC_IEB,A0
	MOVE.B	(A0),IEB
	
	LEA	ANC_IMA,A0
	MOVE.B	(A0),IMA

	LEA	ANC_HBL,A0
	MOVE.L	(A0),HBL_VEC
	
	MOVEA.L	#ANC_MODE,A1	r‚solution de d‚part
	MOVE.B	(A1)+,MODE

	MOVE.W	#15,D0
	LEA	$FF8240,A1
	LEA	ANC_PAL,A0
REND_PAL	MOVE.W	(A0)+,(A1)+
	DBF	D0,REND_PAL

	MOVE.W	#3,-(SP)	o— est xbios(3)?
	TRAP	#14
	ADDQ.L	#2,SP
	
	MOVE.W	#-1,-(SP)	remet un ‚cran correct!
	MOVE.L	D0,-(SP)
	MOVE.L	D0,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADDA.L	#12,SP
	
	MOVE.L	#MOUSEON,-(SP)	remet la souris
	MOVE.W	#0,-(SP)	on ne remet pas le curseur du
	MOVE.W	#25,-(SP)	TOS sinon il clignote tout
	TRAP	#14	le temps...
	ADDQ.L	#8,SP

RAP_FIN	MOVE.L	#ANC_PILE,-(SP)	retour utilisateur
	MOVE.W	#$20,-(SP)
prg	move.l	a7,a5
	move.l	4(a5),a5
	move.l	#20000,-(sp)
	move.L	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp
	pea	text
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	env
	pea	com
	pea	file
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
env	dc.l	0
com	dc.l	0
file	dc.b	'cd15.dat',0
text	dc.b	'CD 15 NOW LOADING',10,13
	DC.B	'PLEASE WAIT',10,10,13,0
	TRAP	#1
	ADDQ.L	#6,SP
	clr.w	-(sp)
	TRAP	#1
********************************************************************
VBL_INTER	MOVE.B	#0,TBCR	arr‚te timer B
	MOVEM.L	D0-D7/A0-A6,-(SP)
	
	LEA	PALETTE2,A3	init pointeur
	MOVE.L	A3,POINT_PAL2	pour rouleau rouge

	LEA	PALETTE3,A3	init pointeur pour
	MOVE.L	A3,POINT_PAL3	pallette verte
	
	LEA	PALETTE,A0	palette rouleaux bleus
* On ne fait pas tout le temps varier les traits verts
* et rouge, pour que la vitesse soit # des rouleaux bleus

	ADDQ.B	#1,ROUL_ON
	CMPI.B	#4,ROUL_ON
	BNE.S	OUT_VBL
	MOVE.B	#0,ROUL_ON
	
	CMPI.B	#0,BASC_TRAIT	pour savoir si les
	BEQ	PLUS	traits montent ou descendent
	
	ADDQ.B	#1,T_VERT
	SUBQ.B	#1,T_ROUGE
	CMPI.B	#2,T_ROUGE
	BNE.S	OUT_VBL
	MOVE.B	#0,BASC_TRAIT
	BRA.S	OUT_VBL
	
PLUS	SUBQ.B	#1,T_VERT
	ADDQ.B	#1,T_ROUGE
	CMPI.B	#13,T_ROUGE
	BNE.S	OUT_VBL		
	MOVE.B	#1,BASC_TRAIT
		
* On augmente le d‚calage par rapport au d‚but
* de la palette bleue. Le motif faisant 28
* ligne, quand on arrive … 28, on remet … 0
OUT_VBL	ADDQ.L	#2,DECAL_PAL1
	MOVE.L	DECAL_PAL1,D0
	CMPI.L	#28,D0
	BNE.S	OUT_2
	MOVE.L	#0,DECAL_PAL1

OUT_2	ADDA.L	D0,A0
	MOVE.L	A0,POINT_PAL
	
	MOVE.B	#1,TBDR	active le timer
	MOVE.B	#8,TBCR

	CLR.B	CMP_LIGNE	init compt. de ligne
	
	MOVEM.L	(SP)+,D0-D7/A0-A6	
	
	RTS

zic_on   st	musik+4730
    MOVEQ	#1,D0
	jsr musik
    MOVE.L	#musik+8,$4d2 
	rts

******************************************************************
HBL_INTER	CLR.B	$00FFFA1B	stop timer B

	MOVEM.L	D0-D7/A0-A6,-(SP)

	MOVEA.L	POINT_PAL,A4	pr‚l‚ve la couleur
	MOVE.W	(A4)+,D3	du rouleau bleu … afficher
	MOVE.L	A4,POINT_PAL

	MOVEA.L	POINT_PAL2,A3	palette rouge
	MOVEA.L	POINT_PAL3,A4	palette verte
	ADDQ.B	#1,CMP_LIGNE	
	MOVE.B	CMP_LIGNE,D2	
	
	MOVE.B	#2,D7	remet timer en route et
	MOVE.B	D7,TBDR	v‚rifie son d‚marrage	
	MOVE.B	#8,TBCR
PAS_ENCOR	CMP.B	TBDR,D7
	BEQ.S	PAS_ENCOR
	
	CMPI.B	#1,D2
	BEQ.S	NOIR
	
	CMPI.B	#000,D2
	BEQ.S	TOUR
	
	CMP.B	T_VERT,D2
	BEQ.S	VERT
	
	CMP.B	T_ROUGE,D2
	BEQ.S	ROUGE

	CMPI.B	#87,D2
	BHI	RED_ROL
	
* tout le reste est en bleu (rouleaux)

	MOVE.W	D3,$FF8240
	MOVE.W	D3,$FF825E
	BRA.S	OUT_HBL
	
TOUR	MOVE.W	#$001,$FF8240
	MOVE.W	#$001,$FF825E
	BRA.S	OUT_HBL
	
ROUGE	MOVE.W	#$500,$FF8240
	MOVE.W	#$500,$FF825E
	BRA.S	OUT_HBL
	
VERT	MOVE.W	#$050,$FF8240
	MOVE.W	#$050,$FF825E
	BRA.S	OUT_HBL

NOIR	MOVE.W	#$000,$FF8240
	MOVE.W	#$000,$FF825E
	BRA.S	OUT_HBL
	
RED_ROL	MOVE.W	(A3),$FF8240
	MOVE.W	(A3)+,$FF825E
	MOVE.W	(A4)+,$FF8240	couleur lettres 
	MOVE.L	A4,POINT_PAL3	sauve pointeur
	MOVE.L	A3,POINT_PAL2	idem.
	
OUT_HBL	MOVEM.L	(SP)+,D0-D7/A0-A6

	BCLR	#0,ISRA
	
	RTE	
*-----------------------------------------------------------*
	
SCROLL:	MOVE.W 	#15,D0 	16 lignes
	LEA 	CHAR_DAT,A5	adressse datas
	MOVE.L 	WORKECR,A4		A4=‚cran travail
	ADDA.L 	#160*180,A4 a partir de la ligne 183 

SCROLL1:	
	ROXL	(A5)+	scrolle plan 1  	
	ROXL	152(A4)		
	ROXL	144(A4)		
	ROXL	136(A4)
	ROXL	128(A4)
	ROXL	120(A4)
	ROXL	112(A4)
	ROXL	104(A4)
	ROXL	96(A4)
	ROXL	88(A4)
	ROXL	80(A4)
	ROXL	72(A4)
	ROXL	64(A4)
	ROXL	56(A4)
	ROXL	48(A4)
	ROXL	40(A4)
	ROXL	32(A4)
	ROXL	24(A4)
	ROXL	16(A4)
	ROXL	8(A4)
	ROXL	(A4)


	ROXL	(A5)+ 	scrolle plan 2
	ROXL	154(A4)
	ROXL	146(A4)
	ROXL	138(A4)
	ROXL	130(A4)
	ROXL	122(A4)
	ROXL	114(A4)
	ROXL	106(A4)
	ROXL	98(A4)
	ROXL	90(A4)
	ROXL	82(A4)
	ROXL	74(A4)
	ROXL	66(A4)
	ROXL	58(A4)
	ROXL	50(A4)
	ROXL	42(A4)
	ROXL	34(A4)
	ROXL	26(A4)
	ROXL	18(A4)
	ROXL	10(A4)
	ROXL	2(A4)
* On saute les 2 suivants pour ne scroller
* que les plans 1 et 2. Si on veux faire
* scroller en + 3 et/ou 4, ne pas oublier
* les modifs plus bas.	
	JMP	PPP

	ROXL	(A5)+  	scrolle plan 3
	ROXL	156(A4)
	ROXL	148(A4)
	ROXL	140(A4)
	ROXL	132(A4)
	ROXL	124(A4)
	ROXL	116(A4)
	ROXL	108(A4)
	ROXL	100(A4)
	ROXL	92(A4)
	ROXL	84(A4)
	ROXL	76(A4)
	ROXL	68(A4)
	ROXL	60(A4)
	ROXL	52(A4)
	ROXL	44(A4)
	ROXL	36(A4)
	ROXL	28(A4)
	ROXL	20(A4)
	ROXL	12(A4)
	ROXL	4(A4)

	
	ROXL	(A5)+  	scrolle plan 4
	ROXL	158(A4)
	ROXL	150(A4)
	ROXL	142(A4)
	ROXL	134(A4)
	ROXL	126(A4)
	ROXL	118(A4)
	ROXL	110(A4)
	ROXL	102(A4)
	ROXL	94(A4)
	ROXL	86(A4)
	ROXL	78(A4)
	ROXL	70(A4)
	ROXL	62(A4)
	ROXL	54(A4)
	ROXL	46(A4)
	ROXL	38(A4)
	ROXL	30(A4)
	ROXL	22(A4)
	ROXL	14(A4)
	ROXL	6(A4)

PPP	ADDA.L 	#160,A4	ligne suivante
*car 160*4=640=codage d'une ligne	
	DBF 	D0,SCROLL1
	ADDQ.B 	#1,NB_BIT
	CMPI.B 	#16,NB_BIT	16 pix scroll‚s ?
	BEQ.S 	NEXTCHAR 	
	RTS
*------------------------------------------------------*	
NEXTCHAR	CLR.B 	NB_BIT
	CLR.L 	D0
	MOVE.L 	MESPOINT,A0	 A0 = pointeur texte
	MOVE.B 	(A0)+,D0	 D0 = prochain caractŠre
	CMPI.B 	#-1,D0	 si D0 = -1 alors on recommence 
*le texte au debut. C'est pour ‡a que les datas doivent se
*terminer par -1
	BEQ 	MESAGAIN
	MOVE.L 	A0,MESPOINT sauve pointeur + 1
	CMPI.B 	#-2,D0	 si D0 = -2 c'est un espace
	BEQ.S 	SPACE
	CMPI.B 	#19,D0	 si D0 > 20 deuxieme rang‚e 
	BGT 	LINE2	 de caractŠres dans la page graphique
	MULU 	#8,D0
	MOVEA.L 	CARACTERE,A1
	ADDA.L 	D0,A1	A1=pointeur datas prochain caractŠre
	MOVE.L 	A1,L1
	BSR 	CHAR_LOAD	charge ses datas ...
	RTS
	
LINE2:	CMPI.B	#39,D0
	BGT	LINE3
	SUB.B 	#20,D0	idem mais si on est 
	MULU 	#8,D0	dans la 2‚me ligne
	MOVEA.L 	CARACTERE,A1	de lettre.
	ADDA.L 	#2560,A1	+ 16 lignes ...
	ADDA.L 	D0,A1
	MOVE.L 	A1,L1
	BSR 	CHAR_LOAD
	RTS
	
LINE3:	SUB.B	#40,D0
	MULU	#8,D0  	pour compter en Byte
	MOVEA.L	CARACTERE,A1
	ADDA.L	#5120,A1
	ADDA.L	D0,A1
	MOVE.L	A1,L1
	BSR	CHAR_LOAD
	RTS
*---------------------------------------------------------------
* ici on met … 0 les 64 mots du buffer de caractŠre	
SPACE:	LEA 	CHAR_DAT,A0	si c'est un espace
	MOVE.W 	#31,D0	 15 pour 1 plan, 31 pour 2 etc..
SPACE1:	CLR.W 	(A0)+	 
	DBF 	D0,SPACE1
	RTS
*-------------------------------------------------------------------
MESAGAIN:	MOVE.L 	#MES,MESPOINT	 r‚initialise le pointeur
	BRA 	NEXTCHAR	 au d‚but.
*------------------------------------------------------------------	
CHAR_LOAD	LEA 	CHAR_DAT,A2	caractŠre grafik dans
	MOVE.W 	#15,D0	le buffer CHAR_DAT
	MOVE.L	#0,D1
C_LOAD	MOVE.L	L1,A0  	pointeur sur d‚but du caractŠre
	ADDA.L	D1,A0	d‚cale pointeur en fonct. de la ligne
	MOVE.W 	(A0)+,(A2)+	plan 1
	MOVE.W 	(A0)+,(A2)+	plan 2
*	MOVE.W 	(A0)+,(A2)+	plan 3 OFF en ce moment
*	MOVE.W 	(A0)+,(A2)+	plan 4 OFF en ce moment
	ADD.L 	#160,D1	une ligne + loin (160 octets)
	DBF 	D0,C_LOAD	on a fait les 16 lignes ?
	RTS
*------------------------------------------------------------------
LES_IMAGES:		
	* Creations de 3 buffers *
	* de 32 K pour RAM vid‚o *

	**** ECRAN DES LETTRES ****
	MOVE.L 	#32512,-(SP)
	MOVE.W 	#72,-(SP)
	TRAP 	#1
	ADDQ.L 	#6,SP
	ADD.L 	#512,D0
	ANDI.L 	#$FFFFFF00,D0
	MOVE.L 	D0,CARACTERE

	**** ECRAN LOGIQUE ****
	MOVE.L 	#32512,-(SP)
	MOVE.W 	#72,-(SP)
	TRAP 	#1
	ADDQ.L 	#6,SP
	ADD.L 	#512,D0
	ANDI.L 	#$FFFFFF00,D0
	MOVE.L 	D0,AFFECR
	
	**** ECRAN DE TRAVAIL ****
	MOVE.L 	#32512,-(SP)
	MOVE.W 	#72,-(SP)
	TRAP 	#1
	ADDQ.L 	#6,SP
	ADD.L 	#512,D0
	ANDI.L 	#$FFFFFF00,D0
	MOVE.L 	D0,WORKECR
	
	**** INSTAL COLORS ****
	LEA 	FONT_ADR,A0
	ADDQ.L 	#2,A0	saute 2 octets
	LEA 	$FF8240,A1	adresse palette ST
	MOVE.W 	#15,D0	transfert les couleurs
ICI:	MOVE.W 	(A0)+,(A1)+
	DBF 	D0,ICI
	
	* D‚compacte les images*
	* et les mets en buffer*

	LEA	FONT_ADR,A0
	ADD.L	#34,A0
	MOVE.L	A0,A5
	MOVEA.L	CARACTERE,A3
	BSR	DECOMP
	
	LEA	PIC_ADR,A0
	ADD.L	#34,A0
	MOVE.L	A0,A5
	MOVEA.L	WORKECR,A3
	BSR	DECOMP
	
	LEA	PIC_ADR,A0
	ADD.L	#34,A0
	MOVE.L	A0,A5
	MOVEA.L	AFFECR,A3
	BSR	DECOMP
	
	RTS
*-------------------------------------------------------*	
SWAP:	MOVE.L 	WORKECR,D0 affiche l'‚cran de travail
	LSR.L 	#8,D0	pendant le transfert !
	MOVE.W 	#$8200,A0
	MOVEP.W 	D0,1(A0)	MOVEP bien pratique!
	MOVE.L 	WORKECR,A0
	ADDA.L 	#160*180,A0
	MOVE.L 	AFFECR,A1
	ADDA.L 	#160*180,A1	si vous avez modifi‚ 
* la hauteur du scroll il faut la modifier ici aussi
	MOVE.W 	#639,D0  		
COPY:	MOVE.L 	(A0)+,(A1)+	copie les 16 lignes modifi‚es
	DBF 	D0,COPY
	MOVE.W 	#37,-(SP)	 VSYNC...
	TRAP 	#14
	ADDQ.L 	#2,SP
	MOVE.L 	AFFECR,D0  	r‚affiche l'‚cran logique
	LSR.L 	#8,D0	(ou avec Xbios5 ???)
	MOVE.W 	#$8200,A0
	MOVEP.W 	D0,1(A0)
	RTS
*----- Routine de d‚compactage ----------*
DECOMP	 MOVE.L      #6,A0        offset de ligne
            MOVE.L      #199,D4
            MOVEQ       #4,D6
            MOVEQ       #40,D7

SAUT1       CLR.B       D1           mise … 0 compteur plan de bits
            MOVE.L      A3,A4        xbios(3) dans A3 et dans A4
BOUT3       MOVE.L      A4,-(SP)     sauve adr plan de bit en cours
            CLR.B       D3           mise … 0 compteur oct par ligne
BOUT2       MOVE.B      (A5)+,D0     1 bit de l'image compress‚e
            TST.B       D0
            BMI         NEGA         si c'est n‚gatif
            ADDQ.B      #1,D0        si c'est positif
*on recopie les D0 octets dans le plan de bit en cours
TITI        MOVE.B      (A5)+,(A4)+
            SEPT                     macro d‚finie au d‚but
            BNE         TITI
            BRA         SAUT
NEGA        NEG.B       D0           compl‚ment … 2
            ADDQ.B      #1,D0
            MOVE.B      (A5)+,D2
*on recopie D0 fois l'octet 2 dans le plan de bit en cours
TOTO        MOVE.B      D2,(A4)+
            SEPT
            BNE         TOTO
SAUT        CMP.B       D7,D3
            BNE         BOUT2        ;on boucle si le nbr
*d'octet par ligne n'est pas complet
            MOVE.L      (SP)+,A4     ;adr ancien plan de bit ds A4
            ADDQ.L      #2,A4        ;adr new plan de bit
            ADDQ.B      #1,D1
            CMP.B       D6,D1
            BNE         BOUT3
            ADD.L       #160,A3
            DBF         D4,SAUT1
	 RTS
           
FONT_ADR	INCBIN "f07.PC1"	inclure les lettres

musik	INCBIN "sowat_03.MUS"

PIC_ADR	INCBIN "cD7.PC1"	inclure le fond


	SECTION DATA

MES:
  DC.B    15,20,11,18,8,14,13,-2,-2,15,17,4,18,4,13,19,-2
  DC.B    19,7,4,-2,-2,12,4,6,0,-2,-2,2,14,12,15,8,11,-2,-2,13,14,-2,-2,26,30,-2
  DC.B    19,7,8,18,-2,-2,8,18,-2,-2,11,8,6,7,19,-2,-2,2,14,17,17,8,3,14,17,-2,-2,0,13,3,-2,-2,6,14,18,19,-2,-2,13,-2,-2,6,14,1,11,8,13,18,-2,-2,0,13,3,-2,-2,1,12,23,-2,-2,18,8,12,20,11,0,19,14,17,-2,-2
  DC.B	  2,17,0,2,10,4,3,-2,-2,1,24,-2,-2,4,12,15,8,17,4,-2
  DC.B	  2,4,-2,-2,9,4,20,-2,-2,2,4,-2,-2,2,14,15,8,4,-2,-2,0,20,-2,-2,5,0,18,19,-2
  DC.B	  12,4,12,1,4,17,18,-2,-2,0,17,4,-2,-2,15,20,11,18,8,14,13,-2,-2,8,18,-2
  DC.B	  7,8,19,2,7,4,17,-2,-2,8,18,-2,-2,2,14,3,4,17,-2,-2,0,13,3,-2
  DC.B	  6,17,0,15,7,8,18,19,4,-2,-2,0,13,3,-2,-2,3,17,4,0,12,-2,-2,22,0,17,17
  DC.B	  8,14,17,-2,-2,8,18,-2,-2,6,17,0,15,7,8,18,19,4,-2,-2,0,13,3,-2,-2,-2,18,22
  DC.B	  0,15,15,4,17,-2,-2,19,4,18,19,0,12,4,13,19,-2,-2,8,18,-2,-2,18,22,0,15,15,4,17,-2,-2
  DC.B	  0,13,3,-2,-2,19,3,22,-2,-2,8,18,-2,-2,2,17,0,2,10,4,17,-2,-2
  DC.B	  19,7,4,-2,-2,12,4,6,0,-2,-2,6,17,4,4,19,8,13,6,18,-2,-2,7,8,-2,-2,19,14,-2,-2
  DC.B    17,4,15,11,8,2,0,13,19,-2,-2,0,13,3,-2,-2,18,19,17,0,13,6,11,4,17,18,-2,-2
  DC.B	  -2,-2,4,18,15,4,2,8,0,11,11,24,-2,-2,5,20,25,8,14,13,-2,-2,0,13,3,-2,-2,0,20,19,14,12,0,19,8,14,13,-2,-2,-2
  DC.B	  -2,14,10,-2,-2,18,4,4,-2,-2,24,14,20,-2,-2,18,14,14,13,-2,-2,-2,-2,-2,-2,-2
  DC.B    -1,0

PALETTE
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

PALETTE3	DC.W	$000,$000,$000,$000,$000,$000
	DC.W	$050,$000,$000,$000,$000,$000
	
PALETTE2	DC.W	$000,$000,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000  

MOUSEOF	DC.B 	18,0
MOUSEON	DC.B	8,0
ANC_PILE	DC.L 	0
MESSAGE1	DC.B	27,"E",0

	SECTION BSS
	
MESPOINT:	DS.L 1

ANC_IEA	DS.B	1
ANC_IEB	DS.B	1
ANC_IMA	DS.B	1
ANC_HBL	DS.L	1
ANC_PAL	DS.W	16
ANC_MODE	DS.B	1
BASC_TRAIT	DS.B	1
T_VERT	DS.B	1
T_ROUGE	DS.B	1
CMP_LIGNE	DS.B	1
ROUL_ON	DS.B	1
POINT_PAL	DS.L	1
POINT_PAL2	DS.L	1	
POINT_PAL3	DS.L	1	
DECAL_PAL1	DS.L	1
SAUVE	DS.L	1
CHAR_DAT	DS.W 	32
* 16 de buffer par plan (16->1,32->2,etc...)
AFFECR:	DS.L 	1
WORKECR:	DS.L 	1
CARACTERE:	DS.L	1
NB_BIT:	DS.B 	1
L1:	DS.L 	1
	DS.L 	128
PILE:	DS.L 	1


 
