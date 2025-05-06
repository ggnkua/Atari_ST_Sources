*************************************************************
*                                                           *
* CORRECTION DU BUG DE FWRITE(-3) SOUS TOS 4.02 ET TOS 4.04 *
*                                                           *
*               PARX - 1993 pour ATARI France               *
*                                                           *
*************************************************************

* INFORMATION SUR "THE FWRITE -3 BUG"
* Le GEMDOS autorise des acc‚s … la console (CON:), au port
* RS232 (AUX:) et … l'imprimante (PRN:) comme si c'‚taient
* des fichiers.
* Pour ‚crire sur ces "p‚riph‚riques … caractŠres" on utilise
* des "handles" particuliers cod‚s sur des MOTS NEGATIFS;
* -1 pour CON:
* -2 pour AUX:
* -3 pour PRN:
*
* Dans le TOS 4.02 et le 4.04, le test de validit‚ de ce handle 
* dans la fonction GEMDOS(64) FWrite() n'est pas bon.
* Au lieu de faire:
* Si Handle inf‚rieur … -3 alors ERREUR
* on trouve dans la ROM:
* Si Handle inf‚rieur ou ‚gal … -3 alors ERREUR,
* ce qui rend impossible une sortie imprimante par FWrite().
* Le Comptable2 (LOGISOFT) imprimant ainsi, l'impression ne
* se fait pas (seul les codes d'‚jection de feuilles sont
* trait‚s car ils sont envoy‚s par une autre focntion).
*
* Ce PRG r‚sident corrige ce bug en remplacant cette sortie
* par une boucle BIOS(3) BConout().
*
* A noter que pour installer un r‚sident "XBRA" il faut 
* se m‚fier lors du test. En effet le GEMDOS poss‚de
* un "XBRA _DOS" en ROM dont l'adresse de vecteur 
* pr‚c‚dent est NUL.

DEPART:	BRA	START	PRG r‚sident donc tˆte en bas!

	DC.B	"XBRA"
	DC.B	"FW-3"			identificateur
ANC_TRAP:	DC.L	0
NEW_TRAP:	LEA	8(A7),A0	charge PILE
	BTST.B	#5,(A7)			super ou user ?
	BNE.S	SUPER
	MOVE	USP,A0			charge pile Utilisateur
SUPER:    	CMPI.W	#64,(A0)	appel … FWrite()?
	BNE.S	JMP_OLD
	CMPI.W	#-3,2(A0)		sur l'imprimante?
	BNE.S	JMP_OLD			non donc bye bye...
* Sortie d'un fichier sur l'imprimante...
	MOVEM.L	D1-A6,-(SP)		sauve tout!
	MOVE.L	4(A0),D7		nbr de caractŠres
	MOVE.L	D7,D6			le sauve
	MOVE.L	8(A0),A6		adresses des caractŠres
* Nous bouclons avec la fonction BConout(),
* en commencant par tester s'il y a bien des
* caractŠres … imprimer car il arrive qu'on recoivent
* une chaŒne de... 0 caractŠres!
LOOP	TST.L	D7		il reste des caractŠres?
	BEQ.S	OUT_FWRITE
	MOVEQ	#0,D5
	MOVE.B	(A6)+,D5	pr‚l‚ve le caractŠre
	MOVE.W	D5,-(SP)	… sortir
	MOVE.W	#0,-(SP)	sur l'imprimante
	MOVE.W	#3,-(SP)	avec Fonction 3
	TRAP	#13		du Bios
	ADDQ.L	#6,SP
	SUBQ.L	#1,D7		d‚compte ce caractŠre
	BRA.S	LOOP
* Retour en D0 le nombre de caractŠres trait‚s
OUT_FWRITE:
	MOVE.L	D6,D0
	MOVEM.L	(SP)+,D1-A6
	RTE			et bye bye...

	ILLEGAL
JMP_OLD    
	MOVEA.L	ANC_TRAP(PC),A0 
	JMP	(A0)
*-----------------------------------------------------------------------*
START:	MOVEA.L	A7,A5
	MOVEA.L	4(A5),A5
	MOVE.L	$C(A5),D0
	ADD.L	$14(A5),D0
	ADD.L	$1C(A5),D0
	ADD.L	#$500,D0
	MOVE.L	D0,D1
	ADD.L	A5,D1
	AND.L	#$FFFFFFFE,D1 
	MOVEA.L	D1,SP
	MOVE.L	D0,-(SP)
	MOVE.L	A5,-(SP)
	CLR.W	-(SP)
	MOVE.W	#$4A,-(SP)
	TRAP	#1
	ADDA.L	#12,SP
* Passage en mode superviseur
  	CLR.L	-(SP)
  	MOVE.W  #$20,-(SP)
  	TRAP   	#1 
  	ADDQ.L 	#6,SP 
  	MOVE.L 	D0,ANC_PILE 
* Pr‚l‚ve le num‚ro de version du TOS
	MOVE.L	$4F2,A0
	MOVE.W	2(A0),D0
	CMP.W	#$0400,D0
	BHS	GOOD_TOS
* C'est un "vieux" TOS, le patch n'est pas utile!
	MOVE.L	#OLD_TOS,-(SP)
	BRA	BAD_TOS	
* V‚rifions si nous sommes d‚j… l…...  
GOOD_TOS:	
	MOVEA.L	$84.W,A6	vecteur TRAP #1
	
ENCORE:	CMPI.L	#"XBRA",-12(a6)
	BNE.S	MISE_EN_PLACE
* Il y a d‚j… quelque chose dans ce vecteur...
	CMPI.L	#"_DOS",-8(A6)	XBRA des ROMs?
	BEQ.S	MISE_EN_PLACE
	CMPI.L	#"FW-3",-8(A6)
	MOVEA.L	-4(A6),A6	passe au suivant...
	BNE.S	ENCORE
* Nous sommes d‚j… install‚...
    	MOVE.L	#DEJA_LA,-(SP)
BAD_TOS:
   	MOVE.W	#9,-(SP)
  	TRAP	#1
  	ADDQ.L	#6,SP
* Retour en utilisateur...
       	MOVE.L	ANC_PILE,-(SP)
  	MOVE.W	#$20,-(SP)
  	TRAP	#1
  	ADDQ.L	#6,SP

	CLR.W	-(SP)	bye bye...
	TRAP	#1
*-----------------------------------------------------------------*  
* Nous installons notre routine dans le TRAP #1
MISE_EN_PLACE:
	MOVE.L	$84,ANC_TRAP
	MOVE.L	#NEW_TRAP,$84
* Nous pr‚venons...
	MOVE.L	#EN_PLACE,-(SP)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
* Retour en utilisateur...
       	MOVE.L	ANC_PILE,-(SP)
  	MOVE.W	#$20,-(SP)
  	TRAP	#1
  	ADDQ.L	#6,SP
* Et nous quittons en restant r‚sidant...
	CLR.W	-(SP)
	MOVE.L	#START,D0	fin … laisser r‚sident
	SUB.L   #DEPART,D0	d‚but … laisser r‚sident
	ADD.L	#256,D0
	MOVE.L	D0,-(SP)
	MOVE.W	#49,-(SP)
	TRAP	#1
*-----------------------------------------------------------------*
	SECTION DATA
OLD_TOS:	DC.B	13,10
	DC.B	"Le patch FWRITE(-3) est",13,10
	DC.B	"inutile sur ce TOS.",13,10,0
	EVEN
EN_PLACE:	DC.B	13,10,27,"p"
	DC.B	"       ",13,10
  	DC.B	"  FWRITE(-3)  BUG-FIX  ",13,10
  	DC.B	" FALCON  TOS 4.02/4.04 ",13,10
	DC.B	"       ",13,10
	DC.B	"  PARX / ATARI France  ",13,10
	DC.B	"       ",13,10
  	DC.B	27,"q",13,10,0
	EVEN
DEJA_LA:	DC.B	13,10,27,"p"
  	DC.B	" FWRITE(-3)  BUG-FIX ",13,10
	DC.B	" d‚j… en place...    ",13,10
	DC.B	27,"q",13,10,0
	EVEN
*-----------------------------------------------------------------*
	SECTION BSS
ANC_PILE:	DS.L	1
	END
	