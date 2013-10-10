MODE	EQU	$FF8260

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
	
	MOVEA.L	#ANC_MODE,A1	sauve la
	MOVE.B	MODE,(A1)+		rÇsolution
	
	MOVE.B	#0,MODE	basse en basse 
	
* dÇconnecte la souris	
	MOVE.L	#MOUSEOF,-(SP)
	MOVE.W	#0,-(SP)
	MOVE.W 	#25,-(SP)
	TRAP 	#14
	ADDQ.L 	#8,SP
	
	* Creations de 2 buffers *
	* de 32 K pour RAM vidÇo *

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
	
	* installe les couleurs *
	*  de l'image FOND.PI1  *
	
	
	**** INSTAL COLORS ****
	LEA 	PIC_ADR,A0
	ADDQ.L 	#2,A0	saute 2 octets
	LEA 	$FF8240,A1	adresse palette ST
	MOVE.W 	#15,D0	transfäre les couleurs
ICI:	MOVE.W 	(A0)+,(A1)+
	DBF 	D0,ICI
	
	* copie l'image dans les *
	*     deux buffers       *
	
	MOVE.L 	WORKECR,A1
	MOVE.L 	AFFECR,A2
	MOVE.W 	#7999,D0	8000 X 4oct=32000
LA:	MOVE.L 	(A0),(A1)+
	MOVE.L 	(A0)+,(A2)+
	DBF 	D0,LA
	
	* init le pointeur texte *
	
	MOVE.L 	#MES,MESPOINT
	
	* 1er caractäre = espace *
	
	BSR 	SPACE 		;1ER CAR= SPACE
	
	***************************
	*   Routine principale    *
	***************************
	
VROOM	BSR 	SCROLL ; scroll de 2*1 pix
	BSR 	SCROLL ; ( plus si vous voulez)
	BSR 	SWAP	; affiche l'Çcran
	
	MOVE.W	#$B,-(SP)	on a touchÇ
	TRAP	#1	au clavier ?
	ADDQ.L	#2,SP
	TST.W	D0
	BEQ	VROOM
; ici routine de test pour la sortie
	JMP	FIN	oui donc c'est fini!!
	
	***************************
	
SCROLL:	MOVE.W 	#15,D0 	16 lignes
	LEA 	CHAR_DAT,A5	adressse datas
	MOVE.L 	WORKECR,A4		A4=Çcran travail
	ADDA.L 	#160*182,A4 a partir de la ligne 183 
SCROLL1:	ROXL.W 	(A5)+	scroll datas...
	ROXL 	152(A4)
	ROXL 	144(A4)
	ROXL 	136(A4)
	ROXL 	128(A4)
	ROXL 	120(A4)
	ROXL 	112(A4)
	ROXL 	104(A4)	scrolle tous les 1ers
	ROXL 	96(A4)	plans d'une ligne !
	ROXL 	88(A4)
	ROXL 	80(A4)
	ROXL 	72(A4)
	ROXL 	64(A4)
	ROXL 	56(A4)
	ROXL 	48(A4)
	ROXL 	40(A4)
	ROXL 	32(A4)
	ROXL 	24(A4)
	ROXL 	16(A4)
	ROXL 	8(A4)
	ROXL 	(A4)
	ADDA.L 	#160,A4	ligne suivante
*car 160*4=640=codage d'une ligne	
	DBF 	D0,SCROLL1
	ADDQ.B 	#1,NB_BIT
	CMPI.B 	#16,NB_BIT	16 pix scrollÇs ?
	BEQ.S 	NEXTCHAR 	
	RTS
	
NEXTCHAR	CLR.B 	NB_BIT
	CLR.L 	D0
	MOVE.L 	MESPOINT,A0	 A0 = pointeur texte
	MOVE.B 	(A0)+,D0	 D0 = prochain caractäre
	CMPI.B 	#-1,D0	 si D0 = -1 alors on recommence 
*le texte au debut. C'est pour áa que les datas doivent se
*terminer par -1
	BEQ.S 	MESAGAIN
	MOVE.L 	A0,MESPOINT sauve pointeur + 1
	CMPI.B 	#-2,D0	 si D0 = -2 c'est un espace
	BEQ.S 	SPACE
	CMPI.B 	#19,D0	 si D0 > 20 deuxieme rangÇe 
	BGT 	LINE2	 de caractäres dans la page graphique
	MULU 	#8,D0
	LEA 	F_ADR,A1
	ADDA.L 	#34,A1
	ADDA.L 	D0,A1	A1=pointeur datas prochain caractäre
	MOVE.L 	A1,L1
	BSR 	CHAR_LOAD	charge ses datas ...
	RTS
	
LINE2:	SUB.B 	#20,D0	idem mais si on est 
	MULU 	#8,D0	dans la 2Çme ligne
	LEA 	F_ADR,A1	de lettre.
	ADDA.L 	#2594,A1	+ 16 lignes ...
	ADDA.L 	D0,A1
	MOVE.L 	A1,L1
	BSR 	CHAR_LOAD
	RTS
	
	
SPACE:	LEA 	CHAR_DAT,A0	si c'est un espace
	MOVE.W 	#15,D0	 tous les datas sont
SPACE1:	CLR.W 	(A0)+	 Ö zÇro !!
	DBF 	D0,SPACE1
	RTS
	
MESAGAIN:	MOVE.L 	#MES,MESPOINT	 rÇinitialise le pointeur
	BRA 	NEXTCHAR	 au dÇbut.
	
CHAR_LOAD:MOVE.L 	L1,A0	transfert les datas du
	LEA 	CHAR_DAT,A1	caractäre grafik dans
	MOVE.W 	#15,D0	le buffer CHAR_DAT
C_LOAD1:	MOVE.W 	(A0),(A1)+
	ADDA.L 	#160,A0
	DBF 	D0,C_LOAD1
	RTS
	
SWAP:	MOVE.L 	WORKECR,D0 	affiche l'Çcran de travail
	LSR.L 	#8,D0	pendant le transfert !
	MOVE.W 	#$8200,A0
	MOVEP.W 	D0,1(A0)	MOVEP bien pratique!
	MOVE.L 	WORKECR,A0
	ADDA.L 	#160*182,A0
	MOVE.L 	AFFECR,A1
	ADDA.L 	#160*182,A1	si vous avez modifiÇ 
* la hauteur du scroll il faut la modifier ici aussi
	MOVE.W 	#649,D0
COPY:	MOVE.L 	(A0)+,(A1)+	copie les 16 lignes modifiÇes
	DBF 	D0,COPY
	MOVE.W 	#37,-(SP)	; VSYNC...
	TRAP 	#14
	ADDQ.L 	#2,SP
	MOVE.L 	AFFECR,D0  	rÇaffiche l'Çcran logique
	LSR.L 	#8,D0	; (NB : pas de xbios 5 c'est la daube !)
	MOVE.W 	#$8200,A0
	MOVEP.W 	D0,1(A0)
	RTS

* remet la rÇsolution du dÇpart
* rÇ-active la souris, revient
* en utilisateur et bye bye !!
FIN	MOVEA.L	#ANC_MODE,A1
	MOVE.B	(A1)+,MODE

	MOVE.L	#MOUSEON,-(SP)
	MOVE.W	#0,-(SP)
	MOVE.W	#25,-(SP)
	TRAP	#14
	ADDQ.L	#8,SP

	MOVE.L	#ANC_PILE,-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
	MOVE.W	#0,-(SP)
	TRAP	#1
	
	
*Image avec les lettres. Elles doivent Çtre faire
*16 pixels par 16, (en tenant compte du pixel
*de sÇparation). Elles doivent Çtre faites
*dans la couleur 3 (elles vont de 0 Ö 15)
*La premiäre lettre est tout en haut Ö gauche.	
	
F_ADR:	INCBIN FONT_B_U.PI1	inclure l'image


*IMAGE FOND.PI1 CONTIENT L'IMAGE DE FOND AFFICHêE
*LORS DU SCROLL. CE DERNIER (A PARTIR DE LA LIGNE 183)
*DOIT PASSER SUR UNE BANDE FAITE AVEC LA COULEUR DU
*REGISTRE 2 (LE 3EME) SUR L'IMAGE DE FOND.
*VOUS POUVEZ FAIRE DES MOTIFS QUI APPARAITRONT
*EN TRANSPARENCE AVEC LES COULEURS DES REGISTRES
*4 ET 6 (LE 5EME ET LE 7EME)SUR LE FOND.
*LORQUE LE SCROLL PASSERA SUR CES 2 DERNIERES COULEURS
*SERONT AFFICHEES LES COULEURS DES REGISTRES
*5 ET 7 (LE 6EME ET LE 8EME).
*A NOTER: C'EST LA PALETTE DE CETTE IMAGE
*ET PAS CELLE DE FONT.PI1 QUI EST PRISE EN COMPTE
	 
PIC_ADR:	INCBIN FOND_B_U.PI1

*****************************************
* TEXTE CODê SELON VOTRE IMAGE GRAFIK : *
* 1ER CARACTERE EN HAUT A GAUCHE= 0     *
* LE 2EME = 1, LE 3EME = 2 ETC...       *
* ESPACE = -2 (C'EST LA VIE)	       *
* DE 0 A 39 DONC (2 RANGEES DE 20 CAR.  *
* DE PLUS, LE TEXTE DOIT TOUJOURS SE    *
* TERMINER PAR UN -1 !!	       *
*****************************************
	
MES:	DC.B 12,0,23,-2,8,8,-2,4,18,19,-2,7,4,20,17,4,20,23,-2,3,4
	DC.B -2,18,0,11,20,4,17,-2,3,14,20,6,11,0,18,-2,0,21,4,2
	DC.B -2,20,13,-2,18,2,17,14,11,11,8,13,6,-2,19,17,0,13
	DC.B 18,15,0,17,4,13,19,-2,-2,-2,-1
	
MESPOINT:	DS.L 1

ANC_MODE	DC.B	1
CHAR_DAT:	DS.W 	16
AFFECR:	DS.L 	1
WORKECR:	DS.L 	1
NB_BIT:	DS.B 	1
L1:	DS.L 	1
MOUSEOF	DC.B 	18,0
MOUSEON	DC.B	8,0
SCRN:	DS.L 	1
ANC_PILE	DC.L 	0
	DS.L 	128
PILE:	DS.L 	1

