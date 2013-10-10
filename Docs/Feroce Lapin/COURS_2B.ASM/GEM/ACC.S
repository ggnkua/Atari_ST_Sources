**********************************************************************
*                   PETIT EXEMPLE D'ACCESSOIRE                       *
*                          Version 1.00                              *
**********************************************************************

	INCLUDE	"D:\BIBLIO.ASM\GEMMACRO.S"
* Nous voici reparti vers de nouvelles aventures...
START	MOVE.L	#PILE,A7	pas de shrink (.ACC)
	APPL_INIT
	MOVE.W	D0,APP_ID	stocke l'identificateur d'application GEM
* On met le titre de l'accessoire.	
	MENU_REGISTER	APP_ID,#MY_MENU
	TST.W	D0       si -1, plus de place
	BGE	GOOD_MENU   ouf, c'est bon!
	FORM_ALERT	#1,#ALERTE0  donc on pr‚vient
* On quitte mais de toutes fa‡ons ‡a va merder! en fait
* cela permet essentiellement de pr‚venir l'utilisateur!
	BRA	BYE_BYE    et on quitte
GOOD_MENU	MOVE.W	D0,ID_MENU    stoc identif. de l'ACC

* On attend maintenant les ‚v‚nements. On ne teste que
* l'‚vŠnement 40 qui signifie ouverture de l'accessoire.
* Jetez un coup d'oeil sur la structure des messages.
* Dans la cas par exemple des fenˆtres ils fournissent
* de multiples informations. Savoir OU elles sont dans
* les 16 octets est tr‚s utile!!!!
DEBUT	EVNT_MESAG	#MESSAGEBUF
	LEA	MESSAGEBUF,A6
	MOVE.W	(A6),D0	pr‚lŠve le num‚ro du message
	CMP.W	#40,D0	ouverture de notre accessoire ?
	BNE.S	DEBUT	non donc attente
	FORM_ALERT	#1,#ALERTE1  sinon on met une alerte
	BRA	DEBUT	et on recommence...
*--------------------------------------------------------------------------*
* Quitte si plus de place dans le menu
BYE_BYE	APPL_EXIT	indique au GEM qu'on a fini
	CLR.W	-(SP)	et on quitte
	MOVE.W	#$4C,-(SP)
	TRAP	#1	
*--------------------------------------------------------------------------*
	SECTION DATA
MY_MENU:	DC.B	"  ESSAI.ACC",0	nom de l'acc dans le menu
ALERTE0:	DC.B	"[1][Plus de place|dans le menu pour|"
	DC.B	"essai.acc][ OK ]",0
	EVEN
ALERTE1:	DC.B	"[1][Petit essai d'accessoire|en assembleur 68000]"
	DC.B	"[ OK ]",0
	EVEN
*--------------------------------------------------------------------------*
	SECTION BSS
* Variables pour le GEM
APP_ID	DS.W	1
MESSAGEBUF	DS.W	8
ID_MENU	DS.W	1

* Pile pour le programme
	DS.L	256
PILE	DS.L	1	
* On inclus pas le VDI parce qu'on n'en a pas besoin ici!
	INCLUDE	"D:\BIBLIO.ASM\AESLIB.S"
	END
	
