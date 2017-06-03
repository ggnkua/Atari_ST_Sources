**************************************************************
* Petit programme d'essai pour JOHNNI 5, par Le F‚roce Lapin *
*                V 2.00      Le 14/09/1991                   *
**************************************************************

*
* D'abord les ‚quivalences. Le fichier vient de l'‚diteur de
* ressource. Il porte normalement l'extention .H et demande
* … ˆtre modifi‚ pour ˆtre accept‚ en assembleur.
* resource set indicies for ESSAI

* resource set indicies for ESSAI
LEMENU     EQU 0	/* menu tree */
TITRE1     EQU 3	/* TITLE in tree LEMENU */
TITRE2     EQU 4	/* TITLE in tree LEMENU */
TITRE3     EQU 5	/* TITLE in tree LEMENU */
COPYRIGH   EQU 8	/* STRING in tree LEMENU */
PETESSAI   EQU 17	/* STRING in tree LEMENU */
QUITTER    EQU 19	/* STRING in tree LEMENU */
ICHECK     EQU 21	/* STRING in tree LEMENU */
TEXTE      EQU 22	/* STRING in tree LEMENU */

COPYFORM   EQU 1	/* form/dialog */
OUTCOPY    EQU 4	/* BUTTON in tree COPYFORM */

CHOIX      EQU 2	/* form/dialog */
OKFORM     EQU 13	/* BUTTON in tree CHOIX */
ANULFORM   EQU 14	/* BUTTON in tree CHOIX */

	SECTION TEXT
	INCLUDE	"D:\BIBLIO.ASM\MACRO\GEMMACRO.S"

* ROUTINE DE DEMARRAGE DES PROGRAMMES
  	MOVE.L 	A7,A5
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

	APPL_INIT		init pour le GEM
	MOVE.W	D0,APP_ID
	RSRC_LOAD	#NOM_RSC	chargement ressource
	TST.W	D0	ressource trouv‚e ?
	BNE.S	OK_RSC	oui c'est bon...
	FORM_ALERT	#1,#ALERTE1	non donc alerte
	BRA	END_PRG		et bye bye...
* La ressource ‚tant trouv‚, on cherche l'adresse du menu,
* on le met en place, on met la souris en flŠche, puis
* on tombe dans une boucle de test de messages commes pour
* l'accessoire.
OK_RSC:	RSRC_GADDR	#0,#LEMENU		cherche adresse menu
	MOVE.L	ADDR_OUT,MENU_PTR	sauve adresse menu
	
	MENU_BAR	MENU_PTR,#1	mettre le menu en place
	GRAF_MOUSE	#0		souris en flŠche
	CLR.W	FLAG_QUITTER	par d‚faut on ne quitte pas
	CLR.W	FLAG_CHECK
	CLR.W	FLAG_TEXTE
* Boucle d'attente avec evnt_mesag
DEBUT	EVNT_MESAG	#MESSAGEBUF	
	LEA	MESSAGEBUF,A0
	CMP.W	#10,(A0)	message menu ?
	BNE.S	DEBUT	non donc attente
* Nous avons re‡u un message menu. Le 3‚me mot c'est l'index
* de titre (donc son num‚ro) et le 4‚me c'est l'article
* (donc le nu‚mro du choix dans le menu). En fait on utilise
* les ‚quivalences (le fichier avec les EQU qui est au d‚but
* du listing) pour faire des tests avec les noms et pas 
* les num‚ros, c'est plus simple.
	MOVE.W	6(A0),D6	pr‚l‚ve le titre
	MOVE.W	D6,-(SP)	sauve le titre
	MOVE.W	8(A0),D7	pr‚l‚ve l'article
* On compare maintenant pour savoir vers quelle sub-routine aller
	CMP.W	#COPYRIGH,D7
	BNE.S	NO_1
	BSR	AFFICHE_COPYRIGHT
	BRA	END_MENU
	
NO_1	CMP.W	#PETESSAI,D7
	BNE.S	NO_2
	BSR	AFFICHE_ESSAI
	BRA	END_MENU
	
NO_2	CMP.W	#QUITTER,D7
	BNE.S	NO_3
	BSR	DEMANDE_QUITTER
	BRA	END_MENU
	
NO_3	CMP.W	#ICHECK,D7
	BNE.S	NO_4
	BSR	CHECK_MENU
	BRA	END_MENU
	
NO_4	CMP.W	#TEXTE,D7
	BNE.S	END_MENU
	BSR	CHANGE_TEXTE
* Nous avons ‚t‚ vers la routine correspondant au menu choisi
* il faut maintenant remettre le menu en normal.
END_MENU:	MOVE.W	(SP)+,D6	r‚cupŠre le titre
* Remet le menu en normal
	MENU_TNORMAL	MENU_PTR,D6,#1
* Peut-ˆtre devons nous quitter ?	
	TST.W	FLAG_QUITTER
	BEQ	DEBUT	non, on reste !

* Nous quittons le programme donc retrait menu, etc...
	MENU_BAR	MENU_PTR,#0	retirer le menu
	RSRC_FREE		lib‚re place ressource
END_PRG	APPL_EXIT		quitte pour le GEM
	MOVE.W	#0,-(SP)	et fin totale
	TRAP	#1	
*--------------------------------------------------------------------------*	 

* Les Sub-routines appel‚es par le menu...
AFFICHE_COPYRIGHT:
	WIND_UPDATE	#3	je controle tout!
	RSRC_GADDR	#0,#COPYFORM	adresse formulaire
	MOVE.L	ADDR_OUT,A3
	FORM_CENTER	A3	centrage des coordonn‚es
	MOVEM.W	INT_OUT+2,D4-D7	r‚cupŠre coord. centr‚es
* On r‚serve la zone ‚cran. En fait ce n'est pas une r‚servation
* mais simplement une indication de la zone qui va ˆtre abim‚e.
	FORM_DIAL	#0,#0,#0,#0,#0,D4,D5,D6,D7
* Comme nous avons les coordonn‚es X,Y, la largeur et la
* hauteur du formulaire, nous calculons les coord. de son centre.
	MOVE.W	D6,D0
	ASR.W	#1,D0
	ADD.W	D4,D0			=x+w/2
	MOVE.W	D7,D1
	ASR.W	#1,D1
	ADD.W	D5,D1			=y+h/2
* Nous dessinons un rectangle en expansion
	FORM_DIAL	#1,D0,D1,#0,#0,D4,D5,D6,D7
* Puis dessin du formulaire
	OBJC_DRAW	A3,#0,#10,D4,D5,D6,D7
* et gestion (nous devons passer en paramŠtre l'index
* du premier champ ‚ditable. Il n'y en a pas donc
* nous passons 0).
	FORM_DO	A3,#0
	MOVE.W	D0,D3	sauve le r‚sultat
* Nous n'avons pas … tester le bouton de sortie puisque
* celui-ci est obligatoirement "OK".
	MOVE.W	D6,D0
	ASR.W	#1,D0
	ADD.W	D4,D0			=x+w/2
	MOVE.W	D7,D1
	ASR.W	#1,D1
	ADD.W	D5,D1			=y+h/2
* Rectangle en contraction
	FORM_DIAL	#2,D0,D1,#0,#0,D4,D5,D6,D7
* Puis lib‚ration de la zone abim‚e
	FORM_DIAL	#3,#0,#0,#0,#0,D4,D5,D6,D7
* Le bouton est s‚lectionn‚, nous le remettons en 'normal'
	MULU	#24,D3	un objet=24 octets
	LEA	0(A3,D3.W),A3	adresse objet
	BCLR	#0,11(A3)
	WIND_UPDATE	#2	je rend le contr“le
	RTS
*--------------------------------------------------------------------------*	 

* Seul diff‚rence par rapport au copyright, nous testons
* le bouton de sortie.
AFFICHE_ESSAI:	
	WIND_UPDATE	#3
	RSRC_GADDR	#0,#CHOIX	adresse formulaire
	MOVE.L	ADDR_OUT,A3
	FORM_CENTER	A3	centrage des coordonn‚es
	MOVEM.W	INT_OUT+2,D4-D7	r‚cupŠre coord. centr‚es
* On r‚serve la zone ‚cran.
	FORM_DIAL	#0,#0,#0,#0,#0,D4,D5,D6,D7
* Nous calculons les coord. du centre du formulaire.
	MOVE.W	D6,D0
	ASR.W	#1,D0
	ADD.W	D4,D0			=x+w/2
	MOVE.W	D7,D1
	ASR.W	#1,D1
	ADD.W	D5,D1			=y+h/2
* Nous dessinons un rectangle en expansion
	FORM_DIAL	#1,D0,D1,#0,#0,D4,D5,D6,D7
	OBJC_DRAW	A3,#0,#10,D4,D5,D6,D7
	FORM_DO	A3,#0
	MOVE.W	D0,D3	sauve le r‚sultat
	MOVE.W	D6,D0
	ASR.W	#1,D0
	ADD.W	D4,D0			=x+w/2
	MOVE.W	D7,D1
	ASR.W	#1,D1
	ADD.W	D5,D1			=y+h/2
* Rectangle en contraction
	FORM_DIAL	#2,D0,D1,#0,#0,D4,D5,D6,D7
* Puis lib‚ration de la zone abim‚e
	FORM_DIAL	#3,#0,#0,#0,#0,D4,D5,D6,D7
* Nous remetons … 0 le bit d'OBJ_STATE qui indique que
* l'objet est en inverse vid‚o pour que l'objet soit
* en normal au prochain affichage.
	MOVE.W	D3,D0
	MULU	#24,D0	un objet=24 octets
	LEA	0(A3,D0.W),A3	adresse objet
	BCLR	#0,11(A3)
	WIND_UPDATE	#2
* Nous allons maintenant tester le r‚sultat qui est toujours
* en D3 pour mettre une boŒte d'alerte correspondante
	CMPI.W	#OKFORM,D3
	BNE.S	.ICI
	FORM_ALERT	#1,#ALERTE3	choix OK
	BRA.S	END_CHOIX
.ICI	FORM_ALERT	#1,#ALERTE4	choix ANNULER
END_CHOIX	RTS
*--------------------------------------------------------------------------*	 

DEMANDE_QUITTER:
	FORM_ALERT	#2,#ALERTE2
	CMPI.W	#1,D0	quitter ?
	BNE.S	.ICI
	MOVE.W	#$FFFF,FLAG_QUITTER indique qu'on veut quitter!
.ICI	RTS
*--------------------------------------------------------------------------*	 

* Nous mettons un 'tick' devant l'entr‚e du menu
* Nous utilisons une bascule ¶ L'AIDE DE BCHG
CHECK_MENU:
	BCHG	#0,FLAG_CHECK
	MENU_ICHECK	MENU_PTR,#ICHECK,FLAG_CHECK
	RTS
*--------------------------------------------------------------------------*	 

* L… encore nous utilisons une bascule pour changer
* le texte de cet article du menu
CHANGE_TEXTE:
	LEA	NEW_TEXTE1,A0
	BCHG	#0,FLAG_TEXTE
	BEQ	.ICI
	LEA	NEW_TEXTE2,A0
.ICI	MENU_TEXT	MENU_PTR,#TEXTE,A0
	RTS
*--------------------------------------------------------------------------*	 

	SECTION DATA
* Les textes pour les boŒtes d'alertes
ALERTE1:	DC.B	"[1][Ressource introuvable][Quitter]",0
	EVEN
ALERTE2:	DC.B	"[2][Voulez-vous quitter ?][Oui|Non]",0
	EVEN
ALERTE3:	DC.B	"[3][Vous avez choisi|Confirmer][Ben oui!]",0
	EVEN
ALERTE4:	DC.B	"[3][Vous avez choisi|Annuler][Ben oui!]",0
	EVEN
NOM_RSC:	DC.B	"A:\ESSAI.RSC",0
	EVEN
NEW_TEXTE1:	DC.B	"  TEXTE Nø1",0
	EVEN	
NEW_TEXTE2:	DC.B	"  TEXTE Nø2",0
*--------------------------------------------------------------------------*	 

	SECTION BSS
APP_ID:	DS.W	1
MENU_PTR:	DS.L	1	
MESSAGEBUF:	DS.W	8
FLAG_QUITTER:	DS.W	1
FLAG_CHECK:	DS.W	1
FLAG_TEXTE:	DS.W	1
* La pile recule (on fait -(sp) ) donc on met le label
* et le DS avant.
	DS.L	256
PILE:	DS.L	1
	INCLUDE	"D:\BIBLIO.ASM\MACRO\AESLIB.S"
	END

