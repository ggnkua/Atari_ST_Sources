	opt	o+
	opt	ow-

**********************************************************************
*                  ACCESSOIRE DE LECTURE DE TEXTE                    *
*                          Version 1.00                              *
**********************************************************************

*  Cet  accessoire est fourni avec les cours d'assembleur  du F‚roce La-
* pin. Il vous permettra de visualiser un texte  pendant que vous utili-
* serez un autre programme.
*
* Cet accessoire n'est pas compatible avec le protocole de communication
* GEM, afin  de  ne  pas  le surcharger, son source ‚tant destin‚ … ˆtre
* ‚tudi‚. Il  serait  excellent  comme  exercice de le rendre compatible
* protocole.
*
* On  peut  imaginer  cet accessoire avec un menu d‚roulant par exemple,
* g‚r‚  par  le  programme principale, ou bien avec la s‚rie de messages
* 300, d'envoyer le texte charg‚ par cet accessoire vers un autre acces-
* soire.
*
* Note  du  F‚roce  Lapin: y a un bug !!!! ‡a plante quand on utilise ce
* soft  puis  qu'on  lance  un prg ensuite. Pourquoi? Ah l…, j'ai pas eu
* trop le temps de voir, … vous de jouer les gars!!!

* Macro pour calculer l'adresse d'un objet

OBJECT	macro	tree,object,result,scratchreg
	move.w	\2,\4
	mulu	#24,\4
	lea	0(\1,\4),\3
	endm

* PROGRAMME  vaut 0 pour un assemblage comme programme, sinon l'assem-
* blage a lieu comme accessoire.
* Cette ruse d'assemblage est bien pratique durant la phase de mise au
* point. En  effet un accessoire ne peut pas ˆtre lanc‚, et n'a pas de
* fin ! Avec  cette option, on simule un accessoire alors que l'assem-
* blage  a  donn‚ un programme. Lorsque la mise au point est termin‚e,
* il  suffit  de donner une autre valeur que 0 … PROGRAMME (en faisant
* PROGRAMME EQU 1) et d'assembler sur disque avec l'extension ACC.

PROGRAMME	EQU	0

	INCLUDE	"D:\BIBLIO.ASM\GEMMACRO.S"

* Nous voici repartis vers de nouvelles aventures...

	ifeq	PROGRAMME	* si c'est un PRG
START	INCLUDE	"D:\BIBLIO.ASM\START.S"
	APPL_INIT
	MOVE.W	D0,APP_ID	stocke l'identificateur d'application GEM
	elseif
START	MOVE.L	#PILE,A7	pas de shrink (.ACC)
	APPL_INIT
	MOVE.W	D0,APP_ID	stocke l'identificateur d'application GEM

* On met le titre de l'accessoire.

	MENU_REGISTER	APP_ID,#MY_MENU
	TST.W	D0	si -1, plus de place
	BGE	GOOD_MENU	ouf, c'est bon!
	FORM_ALERT	#1,#ALERTE0	donc on pr‚vient
	BRA	BYE_BYE1	et on quitte
GOOD_MENU	MOVE.W	D0,ID_MENU	stocke identif. de l'ACC
	endc

* Partie commune … l'acc ou au prg

	BSR	INIT_ACC

* Puis, maintenant, une partie diff‚rente suivant
* qu'il s'agit d'un accessoire ou d'un programme.

	ifeq	PROGRAMME
DEBUT	TST.W	ACT_WIND	la fenˆtre est ouverte ?
	BNE	DEBUT0	oui donc on la g‚re...

	MOVE.L	#ESSAI_TXT1,-(SP)	affiche un message
	MOVE.W	#9,-(SP)	de bienvenue
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.W	#7,-(SP)	et attend un appui touche
	TRAP	#1
	ADDQ.L	#2,SP
	MOVE.W	D0,D7
	MOVE.L	#ESSAI_TXT2,-(SP)	et l'efface...(plus propre!)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

* [A] quitter, autre touche= ouvrir

	CMP.W	#"A",D7	faut bien trouver un moyen de quitter!
	BEQ	BYE_BYE2
	MOVE.W	#40,D0	simule ouverture menu...
	BRA	popof0
	elseif

* On va maintenant attendre les ‚v‚nements, mais cette attente
* d‚pend de l'‚tat d'activit‚ des fenˆtres.

DEBUT
	endc

* On se repŠre … un flag pour savoir si la fenˆtre
* est ouverte ou non.

* On teste les ‚v‚nements message 40, 41, fenˆtre et clavier pour d‚pla-
* cer le texte avec touches fl‚ch‚es avec shift en plus si on veut).

DEBUT0

BUF,#1

	BTST	#4,D0	‚v‚nement MESSAGE ?
	BEQ	NO_MESSAGE

* Ev‚nement message: on  teste lequel. On prend ici en compte le message
* 40 ET  LE 41 !!!!! Ce message indique la fermeture d'un ACC. Cela peut
* paraŒtre  stupide  mais il faut savoir qu'un accessoire va recevoir un
* tel  message  lorsqu'un  programme va ˆtre lanc‚ ou quitt‚. Comme nous
* avons une fenˆtre GEM, nous pouvons donc ouvrir cette fenˆtre, activer
* une  autre  fenˆtre  du bureau et lancer un programme. Le GEM va alors
* syst‚matiquement d‚truire toutes les fenˆtre affich‚es, dont la n“tre!
* Nous  pourrons  le  savoir  car nous recevrons un message 41. Si on ne
* teste  pas  ce message, on reste persuad‚ que la fenˆtre est active et
* c'est la pagaille !!!  Faites  l'exp‚rience avec les accessoires ayant
* une fenˆtre, de lancer un PRG en laissant la fenˆtre de l'ACC ouverte.
* Si  le  lancement r‚ussit, essayez de rouvrir l'ACC. Vous vous rendrez
* compte que dans beaucoup d'ACC c'est impossible! 

	LEA	MESSAGEBUF,A6
	MOVE.W	(A6),D0	r‚cupŠre le num‚ro de message

* On travaille avec une liste (voir cours sur les tableaux)
* vous pourrez ainsi rajouter les messages 300, 400 et 500 !!!

popof0	LEA	COD_MESS0,A0	liste des codes messages
	LEA	ROUT_MESS0,A1	liste des adr. routines
.AGAIN	MOVE.W	(A0)+,D1	pr‚lŠve code
	CMP.W	#$FFFF,D1	fin du tableau ?
	BEQ	MAYBE_WIND	oui donc tente les fenˆtres...
	MOVE.L	(A1)+,A5	pr‚lŠve adr routine
	CMP.W	D0,D1	c'est le bon code ?
	BNE.S	.AGAIN	non donc on boucle
	JSR	(A5)	oui donc saut dans la routine...
	BRA	DEBUT	et on recommence l'attente

* On  poursuit  avec  la  liste des messages relatifs aux fenˆtres. Le
* fait de diff‚rencier les messages fenˆtre des autres nous permet ici
* de traiter le clipping. Il s'agit d'une instruction GEM qui va d‚li-
* miter la zone dans laquelle se feront les op‚rations graphiques.

MAYBE_WIND	LEA	COD_MESS1,A0	liste des codes
	LEA	ROUT_MESS1,A1	liste adr des routines
.AGAIN	MOVE.W	(A0)+,D1	pr‚lŠve un code
	CMP.W	#$FFFF,D1	fin du tableau ?
	BEQ	DEBUT	oui donc bye bye...
	MOVE.L	(A1)+,A5	pr‚lŠve adr. routine
	CMP.W	D0,D1	c'est le bon code ?
	BNE.S	.AGAIN	non donc on boucle

* Avant de sauter … la routine, on regarde si cela concerne bien no-
* tre fenˆtre!

	MOVE.W	6(A6),D0	handle de la fenˆtre indiqu‚e
	CMP.W	W_HANDLE,D0	c'est la n“tre ?
	BNE	DEBUT	non donc bye bye...
	JSR	(A5)	oui donc traitement...
	BRA	DEBUT	et on recommence l'attente

* Ev‚nement clavier, on test lequel.

NO_MESSAGE BTST	#0,D0	 ‚vŠnement clavier ?
	BEQ	DEBUT	non, donc on recommence l'attente
	MOVE.W	INT_OUT+10,D7	r‚cupŠre code clavier et ASCII

* Normalement, le GEM ne doit nous envoyer les codes clavier  que si
* nous avons une fenˆtre active. Nous testons quand mˆme, c'est plus
* prudent...

	TST.W	ACT_WIND	la fenˆtre est active ?
	BEQ	DEBUT	non donc attente...

* D'aprŠs le code clavier, on s‚lectionne la routine.
* Pour les adr. de routine on reprend TAB_ARROW.

	LEA	COD_CLAV,A0	liste des codes claviers
	LEA	TAB_ARROW,A1	adr des routines
AGAIN01	MOVE.W	(A0)+,D1	pr‚lŠve le code...
	CMP.W	#$FFFF,D1	fin du tableau ?
	BEQ	DEBUT	oui donc code invalide, bye bye...
	MOVE.L	(A1)+,A6
	CMP.W	D7,D1
	BNE.S	AGAIN01

* si la fenˆtre est hors ‚cran, nous ne pourrons faire que des
* affiches totales.  Cela sera test‚ dans les routines pouvant
* faire des vro_cpy, ces routines ‚tant les seules concern‚es.

	V_HIDE_C		retire la souris
.ICI1	JSR	(A6)
	V_SHOW_C	#0
	BRA	DEBUT	et on recommence...
*----------------------------------------------------------------*

* BYE BYE, routine sp‚ciale si on a appuy‚ sur A dans le menu PRG
* ou si on quitte car erreur.

BYE_BYE2:	V_CLSVWK		ferme la station de travail GEM
BYE_BYE21	RSRC_FREE		quitte durant INIT_ACC

* Quitte si plus de place dans le menu

BYE_BYE1	APPL_EXIT	indique au GEM qu'on a fini
	CLR.W	-(SP)	et on quitte
	MOVE.W	#$4C,-(SP)
	TRAP	#1
*----------------------------------------------------------------*
* Fabrication fenˆtre, initalisation diverses etc...

INIT_ACC:	GRAF_HANDLE	recherche du handle VDI
	MOVE.W	D0,CURRENT_HANDLE	du desktop

* On ouvre une station de travail virtuelle
* Voir livre du GEM de MICRO-APP page 79 pour un exemple...

	LEA	INTIN,A0
	MOVE.W	#9,D0	cmp pour 10 fois
.FILL	MOVE.W	#1,(A0)+	la plupart des paramŠtres sont … 1
	DBF	D0,.FILL
	MOVE.W	#2,(A0)+	utilise le systŠme de coordonn‚es raster

	V_OPNVWK		ouverture station de travail
	GRAF_MOUSE	#0	souris en fl‚che svp

* Cherche surface disponible pour le desktop

	WIND_GET	#0,#4
	MOVEM.W	INT_OUT+2,D0-D3	sauve r‚sultat
	MOVEM.W	D0-D3,XDESKTOP

* On proc‚de … l'initialisation de diverses variables

	CLR.W	ACT_WIND
	CLR.W	FULL_WIND
	CLR.L	PTR_TEXTE
	MOVE.W	#3,-(SP)	cherche l'adresse ‚cran
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,AFFECR

* Recherche de la dimension des caractŠres.

	VQT_ATTRIBUTES
	MOVE.W	PTSOUT+4,LARG_CASE
	MOVE.W	PTSOUT+6,HAUT_CASE

* On fabrique avec tout ‡a, la structure FDB
* En fait comme on scrolle l'‚cran on la remplit avec 0
* et le VDI en d‚duira que c'est l'‚cran dont il s'agit,
* et se d‚brouillera pour trouver les bons paramŠtres.

	LEA	ECRAN_FDB,A0
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+

* On calcule les coordonn‚es d'ouverture initiale de la fenˆtre.
* On va centrer la fenˆtre  en lui imposant comme dimension
* d'ouverture la moiti‚ de l'‚cran en largeur et en hauteur.

	MOVE.W	HDESKTOP,D0	hauteur surface travail
	LSR.W	#1,D0	divise par 2
	MOVE.W	D0,HWIND	et donne H fenˆtre

* Puis position Y

	LSR.W	#1,D0	pour avoir le haut et le bas
	ADD.W	YDESKTOP,D0	faut ˆtre sous le menu!!!
	MOVE.W	D0,YWIND

* Pour la largeur de la fenˆtre, on teste car on doit pouvoir mettre
* 33 caractŠres.  Or, avec le calcul simple, en basse r‚solution sur
* ST (par exemple) on obtient une fenˆtre qui n'est pas assez large.

	MOVE.W	LARG_CASE,D4
	MULU.W	#33,D4	largeur mini hautoris‚e
	MOVE.W	D4,MINIWIND

* La largeur de la fenˆtre

	MOVE.W	WDESKTOP,D0
	LSR.W	#1,D0
	CMP.W	D4,D0
	BHI	.OK	‡a va, c'est assez large
	MOVE.W	D4,D0	non donc on impose larg. mini
.OK	MOVE.W	D0,WWIND

* Et enfin position X

	MOVE.W	WDESKTOP,D1
	SUB.W	D0,D1
	LSR.W	#1,D1
	MOVE.W	D1,XWIND
	RTS
*----------------------------------------------------------------*
* Ouverture de l'accessoire. Nous avons re‡u un message 40.  Si la fe-
* nˆtre  est  ouverte  nous  ne  faisons rien. Si elle est ferm‚e mais
* qu'il  n'y a pas eu de texte de charg‚, on demande chargement ou bye
* bye. Si  elle  est  ferm‚e mais qu'il y a un texte de charg‚, on de-
* mande remplacement du texte/visualisation de l'actuel ou bye bye

OPEN_ACC:	TST.W	ACT_WIND	fenˆtre ouverte ?
	BNE	END_OP_ACC	oui donc bye bye...

* Il y a d‚j… un texte de charg‚ ou non ?

	TST.L	PTR_TEXTE	d‚j… un texte ?
	BNE	.ICI	oui donc alerte 3 choix
	FORM_ALERT	#1,#ALERTE2	charger ou annuler ?
	CMP.W	#2,D0	annuler ?
	BEQ	END_OP_ACC	oui donc bye bye
	BRA	LOAD_TEXTE
.ICI	FORM_ALERT	#2,#ALERTE3	remplacer, voir, 
	CMP.W	#3,D0	annuler ?
	BEQ	END_OP_ACC	oui donc bye bye
	CMP.W	#2,D0	seulement voir ?
	BEQ	VOIR_TEXTE

* Comme on veut charger un texte, on vide le Malloc()

	MOVE.L	PTR_TEXTE,-(SP)
	MOVE.W	#73,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	CLR.L	PTR_TEXTE

* Chargement d'un texte

LOAD_TEXTE	MOVE.L	#CHEMIN,-(SP)
	MOVE.L	#NOM,-(SP)
	BSR	SELECTEUR
	ADDQ.L	#8,SP
	TST.W	D0
	BEQ	END_OP_ACC

* Le chemin du fichier est en TAMPON

	CLR.W	COLONNE_INVI
	CLR.W	LIGNE_INVI
	CLR.W	NBR_LIGNE
	CLR.W	LONG_LIGNE

* On va v‚rifier l'existence de ce fichier.

	MOVE.W	#47,-(SP)	Fgetdta()
	TRAP	#1
	ADDQ.L	#2,SP
	MOVE.L	D0,A6	et sauve l'adresse de la DTA

	LEA	TAMPON,A0
	MOVE.W	#0,-(SP)	quel que soit son attribut
	MOVE.L	A0,-(SP)
	MOVE.W	#78,-(SP)	Fsfirst()
	TRAP	#1
	ADDQ.L	#8,SP
	TST.W	D0	on trouve le fichier?
	BMI	END_OP_ACC	non donc bye bye!
	MOVE.L	26(A6),D7	pr‚lŠve taille fichier

* On tente de r‚server un buffer pour charger ce texte

	MOVE.L	D7,-(SP)
	MOVE.W	#72,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	TST.L	D0
	BPL	.ICI

* Pas assez de place, alerte et bye bye...

	FORM_ALERT	#1,#ALERTE4
	BRA	END_OP_ACC

* Le Malloc est fait, on le sauve et on charge le fichier...

.ICI	MOVE.L	D0,PTR_TEXTE
	MOVE.W	#0,-(SP)	ouvre en lecture
	MOVE.L	#TAMPON,-(SP)
	MOVE.W	#61,-(SP)
	TRAP	#1	Fopen()
	ADDQ.L	#8,SP
	TST.W	D0	correct?
	BMI	END_OP_ACC	non, bye bye
	MOVE.W	D0,D6	sauve handle

	MOVE.L	PTR_TEXTE,-(SP)	adr destination
	MOVE.L	D7,-(SP)	taille … lire
	MOVE.W	D6,-(SP)	handle
	MOVE.W	#63,-(SP)	Fread()
	TRAP	#1
	ADDA.L	#12,SP

	MOVE.W	D6,-(SP)
	MOVE.W	#62,-(SP)
	TRAP	#1	Fclose()
	ADDQ.L	#4,SP

* Chargement termin‚, on cherche divers trucs

	BSR	FIND_NBRLIGNE

* et on affiche la fenˆtre

VOIR_TEXTE	BSR	OPEN_WINDOW

END_OP_ACC	RTS

*----------------------------------------------------------------*
* Routine de gestion de s‚lecteur de fichier.

* Routine  ind‚pendante, le  texte  de sa boŒte d'alerte (problŠme m‚-
* moire, impossible  g‚rer s‚lecteur) est inclus dedans.-Le GEM attend
* pour  le  s‚lecteur 2 adresses. La 1Šre pour le chemin qui sera ins-
* crit  en haut du s‚lecteur, la 2Šme pour le nom de fichier pr‚s‚lec-
* tionn‚. Malheureusement, en retour chemin peut avoir chang‚.
* 
* On peut en effet avoir fourni:  A:\*.*
* 
* et r‚cup‚rer C:\DOSSIER1\COMPTA.DOC\*.DOC.
* 
* Or, le  GEM  va remettre ce nouveau chemin dans l'ancien, en l'‚cra-
* sant. Il fera de mˆme avec le nom. J'ai donc pr‚f‚r‚ prendre un TAM-
* PON  de  130 octets  (je le mets dans tous mes programmes et je m'en
* sers  de  buffer temporaire). Au d‚part, je recopie le chemin dedans
* et en retour de la routine c'est donc dans TAMPON que sera le r‚sul-
* tat: Routine  de  s‚lecteur  de  fichier. (CHEMIN puis NOM dans sp).
* ATTENTION  on doit sp‚cifier en section data d'abord le chemin puis,
* IMMEDIATEMENT APRES le nom du fichier.Au retour si D0=$FFFF c'est OK

SELECTEUR	MOVEM.L	D1-A6,-(SP)
	WIND_UPDATE #3	bloque l'AES
	MOVE.L	60(SP),A5	adresse nom fichier
	MOVE.L	64(SP),A0	adresse chemin

* On transfŠre le chemin dans TAMPON

	LEA	TAMPON,A6
	MOVE.L	A6,A1
.ICI	MOVE.B	(A0)+,D0
	MOVE.B	D0,(A1)+
	TST.B	D0
	BEQ.S	GO_SELECT
	BRA.S	.ICI
GO_SELECT:	FSEL_INPUT A6,A5
	TST.W	D0	assez de place m‚moire?
	BNE	.SELECT1	oui
	FORM_ALERT #1,#SELECT_ALRT
	CLR.W	D0	flag … z‚ro
	BRA	END_SELECT	et bye bye

.SELECT1	MOVE.W	INT_OUT+2,D0	cancel ou ok ?
	TST.W	D0	cancel?
	BEQ	END_SELECT	oui donc bye bye

* On teste si c'est OK avec un nom de fichier nul

	TST.B	(A5)	ok mais sans fichier?
	BNE	.SELECT2	non
	CLR.W	D0	pr‚vient
	BRA	END_SELECT	et bye bye

* On fabrique le chemin complet (chemin+nom)

.SELECT2	MOVE.B	(A6)+,D0	avance sur le chemin
	BEQ	SELECT4	0 donc fin du chemin revenue
	CMP.B	#"\",D0
	BNE.S	.SELECT2
	MOVE.L	A6,A4	sauve adresse du backslash
	BRA.S	.SELECT2

* A4 indique donc l'adresse potentielle o— doit ˆtre ins‚r‚ le nom-1
* car on est sur le \

SELECT4	MOVE.B	(A5)+,D0
	TST.B	D0	fin du nom
	BEQ.S	SELECT5
	MOVE.B	D0,(A4)+	non donc on insŠre
	BRA.S	SELECT4
SELECT5	MOVE.W	#$FFFF,D0	pr‚vient que tout est OK

END_SELECT	MOVE.W	D0,-(SP)	sauve pendant d‚blocage
	WIND_UPDATE #2	d‚bloque l'AES
	MOVE.W	(SP)+,D0
	MOVEM.L	(SP)+,D1-A6	et bye bye
	RTS
SELECT_ALRT	DC.B	"[3][ProblŠme m‚moire...|"
	DC.B	"Gestion du s‚lecteur|fichier impossible][Gloups!]",0	
	EVEN

*----------------------------------------------------------------*
* ROUTINES DE GESTION DE LA FENETRE.
*----------------------------------------------------------------*
* Ouverture de fenˆtre 
* (donc cr‚ation puisqu'on la d‚truit … chaque fois).

OPEN_WINDOW:
	MOVE.W	#$FFFF,ACT_WIND	indique fenˆtre ouverte	
	MOVEM.W	XDESKTOP,D0-D3	taille maxi

* Cr‚ation fenˆtre texte, avec tous les ‚l‚ments sauf infos...

	WIND_CREATE  #%111111101111,D0,D1,D2,D3
	TST.W	D0	Bien cr‚‚ ?
	BMI	BAD_OPEN2

* Mise en place du titre et ouverture de la fenˆtre

	MOVE.W	D0,W_HANDLE	sauve le handle fenˆtre menu
	MOVE.L	#WIND_NAME,INT_IN+4
	WIND_SET	W_HANDLE,#2	2->titre fenˆtre
	MOVEM.W	XWIND,D0-D3	taille d'init
	WIND_OPEN	W_HANDLE,D0,D1,D2,D3
	TST.W	D0	bonne ouverture ?
	BMI	BAD_OPEN2

* Ayant ouvert la fenˆtre, il va y avoir automatiquement  un ordre de
* redraw du GEM donc on s'en va!

	BRA.S	END_OPEN

* Erreur fenˆtre on avertit et bye bye...

BAD_OPEN2	FORM_ALERT	#1,#ALERTE1	problŠme de cr‚ation 
fenˆtre
	WIND_CLOSE	W_HANDLE
	WIND_DELETE	W_HANDLE
	CLR.W	ACT_WIND	indique ouverture rat‚e
END_OPEN	RTS
*----------------------------------------------------------------*
* Fermeture (et donc destruction) de la fenˆtre.

CLOSE_WINDOW:
	WIND_GET	W_HANDLE,#5	emplacement fenˆtre svp
	MOVEM.W	INT_OUT+2,D0-D3
	MOVEM.W	D0-D3,XWIND	et sauve pour tout … l'heure
	WIND_CLOSE	W_HANDLE
	WIND_DELETE	W_HANDLE

* Un message 41  est survenue  alors que nous ‚tions ouvert,  il y a
* donc destruction de la fenˆtre.

CLOSE_ACC:	CLR.W	ACT_WIND	indication de fermeture
	RTS
*----------------------------------------------------------------*
* On arrive sur UPDATEIT avec un message du GEM ou aprŠs on sizeit,
* si W et H ont diminu‚, et aussi aprŠs fullit
* (r‚tr‚cissement de la fenˆtre)

UPDATEIT:	WIND_GET	W_HANDLE,#4	demande surface et position
	MOVEM.W	INT_OUT+2,D4-D7
	SUBQ.W	#1,D6	… cause du Vbar
	SUBQ.W	#1,D7
	MOVEM.W	D4-D7,XWORK	et sauve

* Calcule la position id‚al en X (* de 8) pour le texte

	MOVE.W	LARG_CASE,D0
	DIVU.W	D0,D4	combien de bloc de lettre … gauche?
	MOVE.W	D4,D1	sauve le quotient
	SWAP	D4	un nombre juste? (test le reste)
	TST.W	D4
	BEQ.S	.ICI
	ADDQ.W	#1,D1	donc une colonne de +
.ICI	MULU.W	D0,D1	on mulu par largeur lettre
	MOVE.W	D1,ST_COLONNE

* Place les nouvelles positions pour le texte en Y

	MOVE.W	D5,ST_LIGNE

* Calcule combien de caractŠres on peut mettre en largeur.

	MOVEQ	#0,D2	… cause du divu!!!
	MOVEQ	#0,D3	… cause du divu!!!
	MOVE.W	D6,D2	largeur fenˆtre
	ADD.W	XWORK,D2	donc maintenant coord c“t‚ droit
	SUB.W	D1,D2	largeur utile
	MOVE.W	D2,D3	la recopie (pour plus bas)
	DIVU.W	D0,D2	divise par largeur grande lettre
	MOVE.W	D2,LARG_VISI

* Calcule ‚galement combien de caractŠres on peut mettre en hauteur.

	MOVE.W	HAUT_CASE,D0
	DIVU	D0,D7
	MOVE.W	D7,HAUT_VISI

* AprŠs v‚rification, on ne doit pas s'occuper du fait que notre fenˆ-
* tre soit active ou non.  On utilise  toujours le systŠme des rectan-
* gles.  Si notre fenˆtre est active, il n'y en aura qu'un!

	VST_ALIGNMENT #0,#5
	VSF_COLOR	#0
	V_HIDE_C		cache la souris
	WIND_UPDATE	#1	bloque la liste des rectangles
	WIND_GET	W_HANDLE,#11	demande premier rectangle
TST_RECT	TST.W	INT_OUT+6	teste la largeur
	BEQ	END_RECT	nulle donc plus de rectangle

* La routine INTERSECT pr‚lŠve dans le messagebuf dont l'adresse est
* en A6, les coords voulues pour la fenˆtre et dans IN_OUT celles du
* rectangle obtenu par Wind_get #11

	BSR	INTERSECT	calcul l'intersection
	TST.W	D0	il y en a une ?
	BEQ	NEXT_RECT	non --> rectangle suivant

* On place un clipping et on r‚affiche puis on d‚-clip

	VS_CLIP	#1,D4,D5,D6,D7	active le clipping
	BSR	AFFICHE_TEXTE
	VS_CLIP	#0,D4,D5,D6,D7	d‚sactive le clipping
NEXT_RECT	WIND_GET	W_HANDLE,#12	rectangle suivant
	BRA	TST_RECT
END_RECT	WIND_UPDATE	#0	d‚bloque la liste des rectangles
	V_SHOW_C	#0
	BSR	PUT_VSLIDER	remet en place
	BSR	PUT_HSLIDER	les 2 sliders
	RTS
*---------------------------------------------------------------*

* Calcul de l'intersection des rectangles. Retourne 0 en D0 s'il n'y a
* pas  d'intersection. En  A6, on a l'adresse du buffer de message. En
* INT_OUT+2, +4, +6, +8, les coord X,Y,W,H du rectangle. Au retour les
* coord  … clipper sont en D4-D7 Cette routine est int‚gralement reco-
* pi‚e  du  Livre  du Developpeur de chez MICRO-APP. Pourquoi chercher
* quand on l'a tout fait sous la main, n'est ce pas ?

INTERSECT:	MOVE.W	INT_OUT+2,D1
	CMP.W	8(A6),D1	travaille avec les X
	BGT.S	IS1
	MOVE.W	8(A6),D4
	BRA.S	IS2
IS1	MOVE.W	D1,D4

IS2	MOVE.W	INT_OUT+4,D2
	CMP.W	10(A6),D2	idem avec les Y
	BGT.S	IS3
	MOVE.W	10(A6),D5
	BRA.S	IS4
IS3	MOVE.W	D2,D5

IS4	MOVE.W	8(A6),D0	car on a X,Y,W,H et on veut
	ADD.W	12(A6),D0	travailler avec X,Y,X',Y'
	ADD.W	INT_OUT+6,D1
	CMP.W	D1,D0
	BLT.S	IS5
	MOVE.W	D1,D6
	BRA.S	IS6
IS5	MOVE.W	D0,D6
IS6	SUBQ.W	#1,D6

	MOVE.W	10(A6),D0
	ADD.W	14(A6),D0
	ADD.W	INT_OUT+8,D2
	CMP.W	D2,D0
	BLT.S	IS7
	MOVE.W	D2,D7
	BRA.S	IS8
IS7	MOVE.W	D0,D7
IS8	SUBQ.W	#1,D7

	CLR.W	D0	test: intersection ?
	CMP.W	D4,D6	X2<X1 ?
	BLT.S	ISRTS	oui donc erreur et D0 reste … 0
	CMP.W	D5,D7	Y2<Y1 ?
	BLT.S	ISRTS	oui donc erreur et D0 reste … 0
	MOVE.W	#$FFFF,D0	indique intersection OK
ISRTS	RTS

*---------------------------------------------------------------*
* Activation de la fenˆtre.  Le test pour savoir si c'est bien notre
* fenˆtre a d‚j… ‚t‚ fait.

TOPPED:	WIND_SET	W_HANDLE,#10
	RTS

*----------------------------------------------------------------*
* Mise en taille maxi de la fenˆtre.

FULLIT:	BCHG	#0,FULL_WIND	inverse le flag de full
	BEQ.S	FULL_ON	on agrandit

* On remet la fenˆtre aux anciennes dimensions

	WIND_GET	W_HANDLE,#6	anciennes dimensions, svp
	MOVEM.W	INT_OUT+2,D0-D3
	MOVEM.W	D0-D3,INT_IN+4
	WIND_SET	W_HANDLE,#5	impose nouvelles tailles

* Toutes les dimensions sont plus petites mais pourtant dans ce cas,
* le GEM va poster un redraw. Inutile donc de faire un BRA UPDATEIT.

	BRA	END_FULLIT

* On met la fenˆtre en pleine taille, cela d‚clenche un redraw.

FULL_ON	MOVEM.W	XDESKTOP,D0-D3
	MOVEM.W	D0-D3,INT_IN+4
	WIND_SET	W_HANDLE,#5
END_FULLIT	RTS
*----------------------------------------------------------------*

* Changement de la taille de la fenˆtre.   Si la taille demand‚e est
* totalement, plus petite que la taille pr‚c‚dente, le GEM ne va pas
* poster de message de redraw, il faut donc imposer un redraw.
* Le message buffer est en A6

SIZEIT:	MOVEM.W	8(A6),D0-D3	X,Y,W et H voulues

* On v‚rifie si la largeur voulue (en d2)  est sup‚rieure … la lar-
* geur mini autoris‚e.

	MOVE.W	MINIWIND,D5
	CMP.W	D5,D2	assez large ?
	BHI.S	.ICI	oui, en route...
	MOVE.W	D5,D2	non, donc impose D5

* Attention, comme nous imposons D5,  cela signifie que les dimensions
* voulues (pr‚sentes dans Messagebuf) ne sont plus valables.
* Or, updateit  va  les pr‚lever dans Messagebuf. Il faut donc artifi-
* ciellement corriger celui-ci.

	MOVEM.W	D0-D3,MESSAGEBUF+8

.ICI	MOVEM.W	D0-D3,-(SP)	pour passer le wind_set
	MOVEM.W	D0-D3,INT_IN+4
	WIND_SET	W_HANDLE,#5	impose nouvelles dimensions

* Faut-il forcer un Update ?

	WIND_GET	W_HANDLE,#6	anciennes coord SVP
	MOVEM.W	INT_OUT+6,D0-D1	W et H seulement
	MOVEM.W	(SP)+,D2-D5	X,Y,W et H
	CMP.W	D0,D4	ancienne W et nouvelle
	BHI	END_SIZEIT	nouvelle > donc pas de re-draw forc‚
	CMP.W	D1,D5	ancienne H et nouvelle
	BHI	END_SIZEIT	nouvelle > donc pas de re-draw forc‚
	BRA	UPDATEIT	sinon, on force un re-draw!
END_SIZEIT	RTS
*----------------------------------------------------------------*
* D‚placement d'un fenˆtre . On en d‚duit les nouvelles externes et
* internes.

MOVEIT:	MOVEM.W	8(A6),D1-D4	X,Y,W et H voulues
	MOVEM.W	D1-D4,INT_IN+4
	MOVEM.W	D1-D4,XWIND	sauve coord ext‚rieures
	WIND_SET	W_HANDLE,#5	et les impose
	WIND_GET	W_HANDLE,#4	demande coord int‚rieures
	MOVEM.W	INT_OUT+2,D0-D3	pr‚lŠve r‚sultat
	MOVEM.W	D0-D3,XWORK	et le sauve

* Comme notre fenˆtre contient du texte, on force un redraw
* pour aligner le texte sur 8 pixesls (1 byte).

	BSR	UPDATEIT	on r‚affiche l'agenda
END_MOVEIT 
	RTS

***********************************************************************
* Routines concernant l'affichage du texte dans la fenˆtre et les
* mouvements sur celui-ci.
**********************************************************************
**********************************************************************

* Cherche le nombre de ligne du texte et va stocker cela en NBR_LIGNE
* On en profite ‚galement pour chercher LONG_LIGNE qui est la longueur
* de la plus grande ligne du texte.

FIND_NBRLIGNE:
	MOVEM.L	D0-D2/A0,-(SP)
	CLR.W	D1 
	CLR.W	D2
	MOVE.L	PTR_TEXTE,A0
ST_FIND	MOVE.B	(A0)+,D0
	TST.B	D0
	BEQ	END_FNBR
	ADDQ.W	#1,D1	compte ce caractŠre
	CMP.B	#13,D0
	BNE.S	ST_FIND
	MOVE.B	(A0)+,D0
	CMP.B	#10,D0
	BNE.S	ST_FIND
	ADD.W	#1,NBR_LIGNE

* Le nombre de caract. (en D1)  est-il sup‚rieur au plus grand que
* nous ayons trouv‚ ? Si oui, il prend sa place.

	CMP.W	D1,D2
	BCC.S	ICI	D2 est toujours le plus grand	
	MOVE.W	D1,D2	D1 est le + grand, on l'impose donc
.ICI	CLR.W	D1
	BRA	ST_FIND	et on recommence

* On est … la fin du texte, on recommence le test D1/D2

END_FNBR	CMP.W	D1,D2
	BCC.S	.ICI0
	MOVE.W	D1,D2
.ICI0	ADD.W	#10,D2	pour plus de s‚curit‚ et de confort
	MOVE.W	D2,LONG_LIGNE
	MOVEM.L	(SP)+,D0-D2/A0
	RTS

*----------------------------------------------------------------------*
* Action sur une des flŠches de la fenˆtre.

ARROW:	MOVE.W	8(A6),D0	pr‚lŠve le code de l'action
	LEA	TAB_ARROW,A6
	LSL.W	#2,D0	mulu par 4 car longs mots
	MOVE.L	(A6,D0.W),A6

* Nous avons en A6 l'adresse de la routine … d‚clencher.

	V_HIDE_C		retire la souris
.ICI1	JSR	(A6)
	V_SHOW_C	#0	remet la souris
	RTS
*-----------------------------------------------------------------------
*
* Scrolling d'une page vers le haut

PAGE_UP:	MOVE.W	LIGNE_INVI,D0
	TST.W	D0
	BNE.S	.ICI
	BSR	BING	plus de ligne invi. donc bing
	BRA	PAGE_UP0
.ICI	MOVE.W	HAUT_VISI,D1
	CMP.W	D1,D0
	BHI.S	.ICI0
	MOVE.W	#0,LIGNE_INVI
	BRA.S	PAGE_UP1
.ICI0	SUB.W	D1,D0
	MOVE.W	D0,LIGNE_INVI

* Comme il est possible d'activer cette routine avec une partie de
* la fenˆtre hors de l'‚cran, on est oblig‚ de clipper.

PAGE_UP1	BSR	CLIP_TEXTE
	BSR	PUT_VSLIDER	seulement le slider vertical
PAGE_UP0	RTS
*----------------------------------------------------------------------*
* Scrolling d'une page vers le bas

PAGE_DOWN:	MOVE.W	LIGNE_INVI,D0
	MOVE.W	HAUT_VISI,D1
	ADD.W	D1,D0
	CMP.W	NBR_LIGNE,D0
	BCS.S	.ICI
	BSR	BING
	BRA	PAGE_DOWN0
.ICI	ADD.W	D1,LIGNE_INVI

* Tout comme pour  PAGE_UP,  il est possible d'activer cette routine
* avec une partie de la fenˆtre hors ‚cran. On clippe donc.

	BSR	CLIP_TEXTE
	BSR	PUT_VSLIDER
PAGE_DOWN0	RTS

*----------------------------------------------------------------------*

* Routine de scrolling d'une ligne vers le haut

UP_ONE:	CMP.W	#0,LIGNE_INVI
	BNE	UP2	pas au d‚but, on scrolle
	BSR	BING
	BRA	END_UP_ONE

* La, il y a un cas bien vicieux !! En effet il est possible de scrol-
* ler par vro-cpy  (c'est … dire par une copie de blocs du GEM : c'est
* rapide!)  puisque  l'on prend une zone en haut de la fenˆtre pour la
* recopier en bas.  Nous ne risquons donc jamais d'avoir des salet‚s …
* l'‚cran.  Par contre, nous courrons l'‚norme risque de recopier SOUS
* l'‚cran, c'est  … dire dans une zone m‚moire peut-ˆtre d‚j… occup‚e!
* Nous devons donc tester si le vro-cpy est possible ou non!

UP2	SUB.W	#1,LIGNE_INVI
	MOVE.W	YWORK,D0
	ADD.W	HWORK,D0	position la plus basse de la fenˆtre
	MOVE.W	YDESKTOP,D1
	ADD.W	HDESKTOP,D1
	CMP.W	D1,D0
	BLO.S	ICI
	BSR	CLIP_TEXTE
	BSR	PUT_VSLIDER
	BRA	END_UP_ONE

* OK c'est possible par vro-cpy

.ICI	LEA	PTSIN,A0
	MOVE.W	ST_COLONNE,D1	point de d‚part
	MOVE.W	D1,(A0)	X1 source
	MOVE.W	D1,8(A0)	X1 destination
	MOVE.W	D1,D4	pour ONELINE

	MOVE.W	LARG_CASE,D2
	MOVE.W	LARG_VISI,D3
	MULU.W	D2,D3	largeur visible en pixels
	ADD.W	D3,D1
	MOVE.W	D1,4(A0)	X2 source
	MOVE.W	D1,12(A0)	X2 destination

* Puis les dimensions verticales

	MOVE.W	ST_LIGNE,D0
	MOVE.W	D0,2(A0)	Y1 source
	MOVE.W	D0,D5 	pour ONELINE
	MOVE.W	D0,D1
	MOVE.W	HAUT_CASE,D3
	ADD.W	D3,D1
	MOVE.W	D1,10(A0)	Y1 destination
	MOVE.W	HAUT_VISI,D2
	SUBQ.W	#1,D2	car on copie 1 ligne de -
	MULU.W	D3,D2	pour avoir hauteur en pixels
	ADD.W	D2,D0
	MOVE.W	D0,6(A0)	Y2 source
	ADD.W	D2,D1
	MOVE.W	D1,14(A0)	Y2 destination

* La premiŠre ligne c'est quand on fabrique soit mˆme la structure
* MFDB. La seconde c'est s–r de marcher!!!

	VRO_CPYFM	#3,#ECRAN_FDB,#ECRAN_FDB

* On r‚affiche maintenant la ligne du haut

	MOVE.W	LIGNE_INVI,-(SP)
	BSR	FIND_START
	ADDQ.L	#2,SP
	MOVE.L	A0,-(SP)
	MOVE.W	#2,-(SP)	vbar et affichage total
	MOVE.W	D4,-(SP)	position X
	MOVE.W	D5,-(SP)	position Y
	BSR	ONE_LINE
	ADDA.L	#10,SP

* On replace le curseur.

	BSR	PUT_VSLIDER	seulement le slider vertical
END_UP_ONE
	RTS
*--------------------------------------------------------------------*
* Routine de scrolling d'une ligne vers le bas.

* C'est une routine utilisant VRO_CPY,  pour des raisons de rapidit‚.
* Cependant,  si la fenˆtre sort de l'‚cran,  le systŠme de  vro-copy
* n'est plus op‚rationnel. Nous testons donc si VRO_COPY est possible
* ou bien si nous faisons un affichage total du texte.

DOWN_ONE:	MOVE.W	LIGNE_INVI,D0
	ADD.W	HAUT_VISI,D0
	CMP.W	NBR_LIGNE,D0
	BCS	DOWN1	blo
	BSR	BING
	BRA	END_DOWN_ONE

* Testons si c'est possible par vro_cpy

DOWN1	MOVE.W	YWORK,D0
	ADD.W	HWORK,D0	position la plus basse de la fenˆtre
	MOVE.W	YDESKTOP,D1
	ADD.W	HDESKTOP,D1
	CMP.W	D1,D0
	BLO.S	.ICI	
	ADD.W	#1,LIGNE_INVI
	BSR	CLIP_TEXTE
	BSR	PUT_VSLIDER
	BRA	END_DOWN_ONE

* Oui, nous scrollons par vro_cpy

.ICI	LEA	PTSIN,A0
	MOVE.W	ST_COLONNE,D1	point de d‚part
	MOVE.W	D1,(A0)	X1 source
	MOVE.W	D1,8(A0)	X1 destination
	MOVE.W	D1,D4	pour ONELINE

	MOVE.W	LARG_CASE,D2
	MOVE.W	LARG_VISI,D3
	MULU.W	D2,D3	largeur visible en pixels
	ADD.W	D3,D1
	MOVE.W	D1,4(A0)	X2 source
	MOVE.W	D1,12(A0)	X2 destination

* On passe aux dimensions verticales.

	MOVE.W	HAUT_CASE,D3
	MOVE.W	ST_LIGNE,D1	st_ligne c'est le haut des lettres
	MOVE.W	D1,10(A0)	Y1 destination
	MOVE.W	D1,D2
	ADD.W	D3,D2	calcul source
	MOVE.W	D2,2(A0)	Y1 source

* On met haut_visi en D0 mais on retire 1 car graphiquement on reco-
* une ligne de moins

	MOVE.W	HAUT_VISI,D0
	SUBQ.W	#1,D0
	MULU.W	D3,D0	hauteur visible en pixel
	ADD.W	D0,D1	ajoute au Y1 destination
	MOVE.W	D1,14(A0)	Y2 destination
	ADD.W	D0,D2      et au Y1 source	
	MOVE.W	D2,6(A0)	Y2 source	

	MOVE.W	D1,D5	pour ONE LINE
	VRO_CPYFM	#3,#ECRAN_FDB,#ECRAN_FDB

* On calcule d'abord le ptn ligne qui doit pointer sur la ligne sous
* la fenˆtre.

	MOVE.W	LIGNE_INVI,D0
	ADD.W	HAUT_VISI,D0
	MOVE.W	D0,-(SP)
	BSR	FIND_START
	ADDQ.L	#2,SP	
	MOVE.L	A0,-(SP)
	MOVE.W	#2,-(SP)	vbar total et affiche toute la ligne
	MOVE.W	D4,-(SP)	position X 
	MOVE.W	D5,-(SP)	position Y 
	BSR	ONE_LINE
	ADDA.L	#10,SP

* On replace le curseur.

	ADD.W	#1,LIGNE_INVI
	BSR	PUT_VSLIDER	seulement le slider vertical
END_DOWN_ONE
	RTS
*----------------------------------------------------------------------*
* Routine de scrolling d'un caractŠre vers la gauche

LEFT_ONE:	CMP.W	#0,COLONNE_INVI
	BNE.S	LEFT_ONE3
	BSR	BING
	BRA	END_LEFT_ONE

* On est pas tout … gauche, donc on scrolle. Avec le d‚placement par
* l'ascenceur horizontal,  il est possible  que nous ayons moins  de
* 10 colonnes invisibles. Avant d'essayer d'en soustraire 10, il faut
* tester!

LEFT_ONE3	CMP.W	#10,COLONNE_INVI
	BHI.S	.ICI	
	MOVE.W	#10,COLONNE_INVI  impose 10, qui sera mis … 0
.ICI	SUB.W	#10,COLONNE_INVI

* Tout comme pour PAGE_UP, il est possible d'activer cette routine
* avec une partie de la fenˆtre hors ‚cran. On clippe donc.

	BSR	CLIP_TEXTE
	BSR	PUT_HSLIDER	seulement le slider horizontal
END_LEFT_ONE
	RTS
*---------------------------------------------------------------------*

* Routine de scrolling d'un caractŠre vers la droite.

RIGHT_ONE:	MOVE.W	COLONNE_INVI,D0
	ADD.W	LARG_VISI,D0
	CMP.W	LONG_LIGNE,D0	par rapport … la ligne la + grande
	BLO.S	RIGHT_ONE1
	BSR	BING	on butte donc cling et bye bye
	BRA.S	END_RIGHT_ONE
RIGHT_ONE1	ADD.W	#10,COLONNE_INVI

* Tout comme pour PAGE_UP,   il est possible d'activer cette routine
* avec une partie de la fenˆtre hors ‚cran. On clippe donc.

	BSR	CLIP_TEXTE
	BSR	PUT_HSLIDER	seulement le slider horizontal
END_RIGHT_ONE
	RTS
*-------------------------------------------------------------------*
* Routine  permettant  de  trouver un pointeur.  On lui passe sur la
* pile le nombre de ligne … sauter. Renvoie en A0 un pointeur sur le 
* d‚but de la ligne suivante.

FIND_START:
	MOVEM.L	D0/D1,-(SP)
	MOVE.L	PTR_TEXTE,A0	adresse de d‚but de texte
	MOVE.W	12(SP),D1	nombre de lignes … sauter
	BEQ	FIND1	si d1=0 pas de ligne invisible
	SUBQ.W	#1,D1	car DBF

.ICI	CMP.B	#13,(A0)+
	BNE.S	.ICI
	MOVE.B	(A0)+,D0	avance sur le 10
	DBF	D1,.ICI

FIND1	MOVEM.L	(SP)+,D0/D1
	RTS
*--------------------------------------------------------------------*
* Un coup de clochette si jamais on est en bout de texte!!!

BING:	MOVEM.L	D0-D4/A0-A4,-(SP)
	MOVE.W	#7,-(SP)	bell
	MOVE.W	#2,-(SP)
	TRAP	#1
	ADDQ.L	#4,SP
	MOVEM.L	(SP)+,D0-D4/A0-A4
	RTS
*--------------------------------------------------------------------*
* On affiche une seule ligne.

ONE_LINE:	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	70(SP),A6	adresse de d‚but d'affichage
	MOVE.W	68(SP),D0	code de l'action … entreprendre
	MOVE.W	66(SP),D4	position X
	MOVE.W	64(SP),D5	position Y
	MOVE.W	LARG_VISI,D3	nombre de caractŠres
	MOVE.W	COLONNE_INVI,D2

* Travail d'abord avec VBAR

	MOVE.W	HAUT_CASE,D0
	MOVE.W	D5,D7	D5=Y1
	ADD.W	D0,D7	Y2=une lettre plus bas
	MOVE.W	LARG_CASE,D0
	MULU.W	D3,D0
	MOVE.W	D4,D6
	ADD.W	D0,D6
	V_BAR	D4,D5,D6,D7

* Affichage du texte. On saute les colonnes invisibles

ONELINE2	TST.W	D2	colonne invisible
	BEQ	ONELINE3	pas de colonne invisible
	SUB.W	#1,D2
.ICI2	CMP.B	#13,(A6)
	BEQ	ONELINE4	On tombe d‚j… sur 13 donc byebye
	TST.B	(A6)+	et un 0 ?
	BEQ	ONELINE4
	DBF	D2,.ICI2

* On a pass‚ les colonnes, on va donc afficher en comptant D qui
* qui contient le nombre de caractŠres.

ONELINE3	SUBQ.W	#1,D3	car on fait du dbf
	LEA	INTIN,A0	tableau de r‚ception
	MOVEQ.L	#0,D2	init
.ICI3	CLR.W	D0
	MOVE.B	(A6)+,D0	pr‚lŠve en byte
	BEQ	ONELINE5	fin du texte
	CMP.W	#13,D0	retour chariot
	BEQ	ONELINE5
	ADDQ.B	#1,D2	on compte les lettres
	MOVE.W	D0,(A0)+	transfert dans INTIN (en word)
	DBF	D3,.ICI3

ONELINE5	MOVE.W	D4,PTSIN	position X
	MOVE.W	D5,PTSIN+2	position Y
	MOVE.W	D2,CONTRL3	nombre de lettres
	MOVE.W	#1,CONTRL1
	MOVE.W	CURRENT_HANDLE,CONTRL6
	MOVE.W	#8,CONTRL
	MOVE.L	#VDI_PARAMS,D1
	MOVE.W	#$73,D0
	TRAP	#2
ONELINE4	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS
*--------------------------------------------------------------------*
* Affichage de la totalit‚ du texte, avec V_GTEXT rempli … la main.
* Le clipping est r‚alis‚ tout au d‚but,  avant l'envoi vers cette
* routine, ainsi que la disparition de la souris.

AFFICHE_TEXTE:
	MOVEM.L	D0/A6,-(SP)	prudence...

* V_BAR est au format X1,Y1,X2,Y2 et pas XYWH

	MOVEM.W	XWORK,D0-D3
	ADD.W	D0,D2
	ADD.W	D1,D3
	V_BAR	D0,D1,D2,D3

* Lieu d'affichage initial

	MOVE.W	ST_LIGNE,D7	en pixel
	MOVE.W	HAUT_VISI,D5	en ligne
	SUBQ.W	#1,D5	car on va bosser en DBF

* D'abord on va pointer au d‚but de la premiŠre ligne visible

	MOVE.W	LIGNE_INVI,-(SP)
	BSR	FIND_START
	ADDQ.L	#2,SP
	MOVE.L	A0,A6	ptn ligne en A0

* On affiche … partir du haut … gauche de la fenˆtre.
* On saute les colonnes invisibles.

AFF_ON	MOVE.W	COLONNE_INVI,D6
	BEQ	NO_COLONNE	pas de colonne invisible
	SUBQ.W	#1,D6
.ICI2	CMP.B	#13,(A6)+
	BEQ	OUT3	On tombe d‚j… sur 13 donc byebye
	DBF	D6,.ICI2

* On a pass‚ les colonnes, on va donc afficher en comptant LARG_VISI
* qui contient le nombre de caractŠres. On ne se pr‚occupe pas du cas
* cas des grands ‚crans car notre tableau INTIN est bien assez grand!

NO_COLONNE	MOVE.W	ST_COLONNE,X_AFFICHE	par d‚faut on affiche … 
gauche
	MOVE.W	LARG_VISI,D6
NEXT_AFF	SUBQ.W	#1,D6	car on va compter en DBF
	LEA	INTIN,A0	tableau de r‚ception
	MOVEQ.L	#0,D2	init
	MOVEQ.L	#0,D4	init le flag
.ICI3	CLR.W	D0
	MOVE.B	(A6)+,D0	pr‚lŠve en bytes
	BEQ	OUT1	fin du texte pr‚vient par flag
	CMP.W	#13,D0	retour chariot
	BEQ	OUT2
	ADDQ.B	#1,D2	on compte les lettres
	MOVE.W	D0,(A0)+	transfert dans INTIN (en word)
	DBF	D6,.ICI3
	BRA	PUT_TXT

* On est rendu … la fin du texte

OUT1	MOVE.W	#$FFFF,D4	flag pour pr‚venir de fin de texte
	BRA	PUT_TXT
OUT2	MOVE.W	#$EEEE,D4	flag pour pr‚venir trouv‚ CR
PUT_TXT	MOVE.W	X_AFFICHE,PTSIN	position X
	MOVE.W	D7,PTSIN+2	position Y
	MOVE.W	D2,CONTRL3	nombre de lettres
	MOVE.W	#1,CONTRL1
	MOVE.W	CURRENT_HANDLE,CONTRL6
	MOVE.W	#8,CONTRL
	MOVE.L	#VDI_PARAMS,D1
	MOVE.W	#$73,D0
	TRAP	#2

	CMP.W	#$FFFF,D4
	BEQ	OUT_TOTAL	tout est affich‚
	CMP.W	#$EEEE,D4
	BEQ.S	OUT3

* L'affichage de la ligne est fini, il faut maintenant rechercher
* le prochain #13 pour que A6 d‚signe le d‚but de la suivante

.ICI4	MOVE.B	(A6)+,D0
	BEQ.S	OUT_TOTAL
	CMP.B	#13,D0
	BNE.S	.ICI4

* On est tomb‚ sur un #13 en avan‡ant sur les colonnes!

OUT3	MOVE.B	(A6)+,D0	avance sur le 10
	TST.B	(A6)	si 0, le texte est fini
	BEQ	OUT_TOTAL
	ADD.W	HAUT_CASE,D7	Sinon, passe … la ligne suivante

* On passe … la ligne suivante

	DBF	D5,AFF_ON

* Tout le texte est affich‚

OUT_TOTAL	MOVEM.L	(SP)+,D0/A6
	RTS
*-------------------------------------------------------------------*

* Etant  donn‚ que nous pouvons sortir la fenˆtre de l'‚cran,  il faut
* parfois  clipper sur les coord. maxi de celui-ci,  afin d'‚viter par
* exemple de voir r‚apparaŒtre le texte sur le c“t‚ oppos‚ de l'‚cran.
* Etant donn‚ que cela a lieu plusieurs fois, c'est mis en subroutine.

CLIP_TEXTE:
	MOVE.W	YDESKTOP,D7
	ADD.W	HDESKTOP,D7
	VS_CLIP	#1,XDESKTOP,YDESKTOP,WDESKTOP,D7
	BSR	AFFICHE_TEXTE
	VS_CLIP	#0,XDESKTOP,YDESKTOP,WDESKTOP,D7
	RTS
*--------------------------------------------------------------------*
* On a d‚plac‚ le slider vertical, on repositionne le texte en fonction

MOVE_VSLIDE:
	MOVE.W	8(A6),D0	nouvelle position du slider

* La position du slider est en D0

.ICI	MOVEQ.L	#0,D1
	MOVEQ.L	#0,D2
	MOVE.W	NBR_LIGNE,D1
	MOVE.W	HAUT_VISI,D2
	SUB.W	D2,D1
	DIVU.W	#1000,D1
	MOVE.L	D1,D2	sauve r‚sultat op‚ration

* Traite d'abord le quotient

	MULU.W	D0,D1
	DIVU.W	#1000,D1

* Puis le reste

	SWAP	D2
	MULU.W	D0,D2
	DIVU.W	#1000,D2

* Et en d‚duit ligne_invisibles

	ADD.W	D1,D2
	MOVE.W	D2,LIGNE_INVI

	V_HIDE_C

* Tout comme pour PAGE_UP, il est possible d'activer cette routine
* avec une partie de la fenˆtre hors ‚cran. On clippe donc.

	BSR	CLIP_TEXTE
	BSR	PUT_VSLIDER
	V_SHOW_C	#0
	RTS
*--------------------------------------------------------------------*
* On a d‚plac‚ le slider horizontal,
* on repositionne le texte en fonction

MOVE_HSLIDE:
	MOVE.W	8(A6),D0	nouvelle position du slider

* La position du slider est en D0

.ICI	MOVEQ.L	#0,D1
	MOVEQ.L	#0,D2
	MOVE.W	LONG_LIGNE,D1
	MOVE.W	LARG_VISI,D2
	SUB.W	D2,D1
	DIVU.W	#1000,D1
	MOVE.L	D1,D2	sauve r‚sultat op‚ration

* Traite d'abord le quotient

	MULU.W	D0,D1
	DIVU.W	#1000,D1

* Puis le reste

	SWAP	D2
	MULU.W	D0,D2
	DIVU.W	#1000,D2

* Et en d‚duit ligne_invisibles

	ADD.W	D1,D2
	MOVE.W	D2,COLONNE_INVI

	V_HIDE_C

* Tout comme pour PAGE_UP, il est possible d'activer cette routine
* avec une partie de la fenˆtre hors ‚cran. On clippe donc.

	BSR	CLIP_TEXTE
	BSR	PUT_HSLIDER
	V_SHOW_C	#0
	RTS
*--------------------------------------------------------------------*
* R‚glage du slider vertical

PUT_VSLIDER:

* Position du slider vertical

	MOVEQ.L	#0,D7	par d‚faut, tout en haut
	MOVEQ.L	#0,D0
	MOVE.W	LIGNE_INVI,D0
	BEQ.S	VSLID1	on laisse D7 … 1
	MOVE.W	NBR_LIGNE,D1
	SUB.W	HAUT_VISI,D1
	MULU.W	#100,D0
	DIVU.W	D1,D0
	MOVE.W	D0,D7
	MULU.W	#10,D7
	ADD.W	#1,D7
VSLID1	MOVE.W	D7,INT_IN+4
	WIND_SET	W_HANDLE,#9

* Taille du slider vertical

	MOVE.L	#100,D7	impose par d‚faut taille maxi
	MOVEQ.L	#0,D1
	MOVE.W	NBR_LIGNE,D1
	TST.W	D1
	BEQ	PUT_VSLID	pas de ligne de txt donc slider maxi
	MOVEQ.L	#0,D0
	MOVE.W	HAUT_VISI,D0
	MULU.W	#100,D0
	DIVU.W	D1,D0
	CMP.W	D7,D0
	BCC.S	PUT_VSLID	pas valable, on prend D7
	MOVE.W	D0,D7	sinon on impose D0
PUT_VSLID	MULU.W	#10,D7	remet la valeur correcte (0-1000)
	MOVE.W	D7,INT_IN+4
	WIND_SET	W_HANDLE,#16	r‚gle l'ascenceur vertical
	RTS
*--------------------------------------------------------------------*
* R‚glage du slider horizontal

PUT_HSLIDER:

* Position de ce slider

	MOVEQ.L	#0,D7	par d‚faut, tout en haut
	MOVEQ.L	#0,D0
	MOVE.W	COLONNE_INVI,D0
	BEQ.S	HSLID1	on laisse D7 … 1
	MOVE.W	LONG_LIGNE,D1
	SUB.W	LARG_VISI,D1
	MULU.W	#100,D0
	DIVU.W	D1,D0
	MOVE.W	D0,D7
	MULU.W	#10,D7
	ADD.W	#1,D7
HSLID1	MOVE.W	D7,INT_IN+4
	WIND_SET	W_HANDLE,#8

* Taille du slider horizontal

	MOVEQ.L	#0,D7
	MOVE.W	#100,D7	impose par d‚faut taille maxi
	MOVEQ.L	#0,D1
	MOVE.W	LONG_LIGNE,D1	longueur de la plus grande ligne
	TST.W	D1
	BEQ	PUT_HSLID	pas de ligne de txt donc slider maxi
	MOVEQ.L	#0,D0
	MOVE.W	LARG_VISI,D0
	MULU.W	#100,D0
	DIVU.W	D1,D0
	CMP.W	D7,D0
	BCC.S	PUT_HSLID	pas valable, on prend D7
	MOVE.W	D0,D7	sinon on impose D0
PUT_HSLID	MULU.W	#10,D7	valeur correcte entre 0 et 1000
	MOVE.W	D7,INT_IN+4
	WIND_SET	W_HANDLE,#15	rŠgle l'ascenceur horizontal
	RTS
*--------------------------------------------------------------------*
* Temporairement, ce genre de 'routine' est commode!  Cela permet de
* pr‚parer les tableaux, et de faire tranquillement les routines par
* la suite.

JRTS:	RTS
*--------------------------------------------------------------------*
	SECTION DATA

essai_txt1  dc.b	27,"Y",32,32,"[A] = quitter",0
	even
essai_txt2  dc.b	27,"Y",32,32,"             ",0
	even

* Les  textes pour les boites d'alertes.  Au d‚but, j'essayais de don-
* ner des noms en rapport avec le texte mais,  je me suis rendu compte
* que cela ne servait … rien !  Mieux vaut avoir une feuille de papier
* sur  laquelle  on  note,  au fur et … mesure,  les textes des boŒtes
* d'alertes.

ALERTE0:	DC.B  "[1][Plus de place dans |le menu pour ST_AIDE.ACC][ Abandon ]",0
	EVEN
ALERTE1:	DC.B	"[1][Impossible d'ouvrir|cette fenˆtre !|"
	DC.B	"Trop d'ouvertes ?][OK]",0
	EVEN
ALERTE2:	DC.B	"[2][Vision 1.00|Chargement d'un texte ?]"
	DC.B	"[ OK |Annuler]",0
	EVEN
ALERTE3:	DC.B	"[2][Vision 1.00|Remplacement ou|"
	DC.B	"visualisation du texte ?][Charger|Voir|Annuler] ,0
	EVEN
ALERTE4:	DC.B	"[1][Pas assez de m‚moire|pour charger ce fichier][ OK ]",0
	EVEN

* Titre du menu: Vision 1.00 (le num‚ro de version est en fonte computer)

MY_MENU:	DC.B	"  Vision ",17,46,16,16,0
	EVEN
WIND_NAME: DC.B	" Vision ",189," F‚roce Lapin ",17,25,25,17," ",0
	EVEN

* Codes et adresses de routines, sauf pour la fenˆtre.

COD_MESS0:  DC.W	40,41,$FFFF
ROUT_MESS0: DC.L	OPEN_ACC,CLOSE_ACC

* Codes et adresses de routines pour la fenˆtre.

COD_MESS1: DC.W	20,21,22,23,24
	DC.W	25,26,27,28,29
	DC.W	$FFFF
ROUT_MESS1: DC.L	UPDATEIT,TOPPED,CLOSE_WINDOW,FULLIT,ARROW
	DC.L	MOVE_HSLIDE,MOVE_VSLIDE,SIZEIT,MOVEIT,TOPPED

* Routines d‚clench‚es par clic sur les flŠches de la fenˆtre ou les
* clics dans les ascenceurs.

TAB_ARROW:	DC.L	PAGE_UP,PAGE_DOWN,UP_ONE,DOWN_ONE
	DC.L	LEFT_ONE,RIGHT_ONE,LEFT_ONE,RIGHT_ONE

* Codes claviers et routines correspondantes.

COD_CLAV:	DC.W	$4838,$5032,$4800,$5000
	DC.W	$4D36,$4B34,$4D00,$4B00,$FFFF

* Chemin et nom par d‚faut du s‚lecteur de fichier

CHEMIN:	DC.B	"A:\*.*",0
	EVEN
*--------------------------------------------------------------------*
	SECTION BSS
TAMPON:	DS.B	130
NOM	DS.B	14	13	lettres + octet nul
PTR_TEXTE:	DS.L	1	pointeur sur le texte

* Variables pour la fenˆtre.

XDESKTOP:	DS.W	1	dimensions pour full
YDESKTOP:	DS.W	1
WDESKTOP:	DS.W	1
HDESKTOP:	DS.W	1
XWIND:	DS.W	1	dimensions actuelles
YWIND:	DS.W	1
WWIND:	DS.W	1
HWIND:	DS.W	1
XWORK:	DS.W	1	dimensions int‚rieures (pour test clic)
YWORK:	DS.W	1
WWORK:	DS.W	1
HWORK:	DS.W	1
W_HANDLE:	DS.W	1	handle fenˆtre
FULL_WIND: DS.W	1	bascule pour full
MINIWIND:	DS.W	1	largeur ext‚rieur mini

* Variables pour l'affichage

HEIGHT	DS.W	1	hauteur fonte
LARG_CASE: DS.W	1	et sa largeur de lettre
HAUT_CASE: DS.W	1	et leur hauteur
AFFECR:	DS.L	1	adresse d'xbios(3)
ST_COLONNE:	DS.W	1
ST_LIGNE:	DS.W	1
LONG_LIGNE:	DS.W	1
NBR_LIGNE:		DS.W	1
HAUT_VISI:		DS.W	1
LARG_VISI:		DS.W	1
LIGNE_INVI: DS.W	1
COLONNE_INVI: DS.W	1
X_AFFICHE: DS.W	1	temporaire dans AFFICHE_TEXTE

* Variables pour le GEM

APP_ID	DS.W	1
MESSAGEBUF DS.W	8
ECRAN_FDB	DS.W	10
ID_MENU	DS.W	1
ACT_WIND:	DS.W	1	fenˆtre existante ou non

* Pile pour le programme

	DS.L	256
PILE	DS.L	1

	INCLUDE	"D:\BIBLIO.ASM\AESLIB.S"
	INCLUDE	"D:\BIBLIO.ASM\VDILIB.S"
	END

