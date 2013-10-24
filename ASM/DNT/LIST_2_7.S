****************************************************************************
*                                                                         *
*                COURS D'ASSEMBLEUR 68000 SUR ATARI ST                    *
*                                                                         *
*                    par Le F‚roce Lapin (from 44E)                       *
*                                                                         *
*                  Listing num‚ro 2 / Cours num‚ro 7                      *
*                                                                         *
****************************************************************************

* Test r‚solution, car si on est en haute et que l'on
* essaye de passer en basse, paf! reset!
	MOVE.W	#4,-(SP)	num‚ro fonction  Getrez()
	TRAP	#14	appel Xbios
	ADDQ.L	#2,SP      correction pile
	CMP.W	#2,D0      haute ?
	BEQ	CHARGE      oui, donc on charge tout de suite
	
* Puisqu'on est pas en haute, on force en basse r‚solution
* on note d'abord en mettant … 1 un drapeau de signalement
	MOVE.W	#1,RESOLUTION
	
	MOVE.W	#0,-(SP)	basse r‚solution
	MOVE.L	#-1,-(SP)  adresse ‚cran inchang‚e	
	MOVE.L	#-1,-(SP)  adresse ‚cran inchang‚e	
	MOVE.W	#5,-(SP)   fonction Setscreen()
	TRAP	#14	du xbios
	ADDA.L	#12,SP	correction
	
* Ouverture du fichier image
CHARGE	MOVE.W	#0,-(SP)	ouverture en lecture
	MOVE.L	#NOM_FICHIER,-(SP)   adr nom du fichier
	MOVE.W	#61,-(SP)  fonction Fopen()
	TRAP	#1	du gemdos	
	ADDQ.L	#8,SP 	correction pile
* D0 contient le Handle ou bien un num‚ro d'erreur n‚gatif
	TST.W	D0	compare … 0
	BLT	ERREUR     inf‚rieur donc erreur
* On sauve le handle du fichier
	MOVE.W	D0,D3

* Saute les 34 octets du d‚but de fichier degas
* (2 octets d'en-t‚te, 32 de couleurs)
	MOVE.W	#0,-(SP)	d‚cale … partir du d‚but de fichier
	MOVE.W	D3,-(SP)	handle du fichier
	MOVE.L	#34,-(SP)	nbr d'octets … sauter
	MOVE.W	#66,-(SP)	fonction fseek()
	TRAP	#1	du gemdos
	ADDA.L	#10,SP	
	TST.W	D0	test D0
	BLT	ERREUR

* D‚termine l'adresse de l'‚cran
	MOVE.W	#2,-(SP)   fonction Physbase()
	TRAP	#14	du xbios
	ADDQ.L	#2,SP	correction pile
	MOVE.L	D0,A5	sauve l'adresse
	
* Charge l'image directement dans l'‚cran
	MOVE.L	A5,-(SP)   adresse destination
	MOVE.L	#32000,-(SP)  nbr octets … lire
	MOVE.W	D3,-(SP)	handle du fichier
	MOVE.W	#63,-(SP)	fonction Fread()
	TRAP	#1	du gemdos
	ADDA.L	#12,SP
	TST.W	D0
	BLT	ERREUR
	
* Chargement de la palette dans notre buffer palette
* D'abord repositionner le pointeur fichier
	MOVE.W	#0,-(SP)	d‚cale … partir du d‚but de fichier
	MOVE.W	D3,-(SP)	handle du fichier
	MOVE.L	#2,-(SP)	nbr d'octets … sauter
	MOVE.W	#66,-(SP)	fonction fseek()
	TRAP	#1	du gemdos
	ADDA.L	#10,SP	
	TST.W	D0	test D0
	BLT	ERREUR
* Puis chargement	
	MOVE.L	#BUFFER_PAL,-(SP)   adresse destination
	MOVE.L	#32,-(SP)  nbr octets … lire
	MOVE.W	D3,-(SP)	handle du fichier
	MOVE.W	#63,-(SP)	fonction Fread()
	TRAP	#1	du gemdos
	ADDA.L	#12,SP
	TST.W	D0
	BLT	ERREUR

* On place maintenant cette palette avec Xbios (6)
	MOVE.L	#BUFFER_PAL,-(SP)	adresse palette noire
	MOVE.W	#6,-(SP)		fonction Setpalette()
	TRAP	#14		du xbios
	ADDQ.L	#6,SP
	
* On referme le fichier
	MOVE.W	D3,-(SP)	handle
	MOVE.W	#62,-(SP)	fonction Fclose()
	TRAP	#1	du gemdos
	ADDQ.L	#4,SP
	
	BRA	FIN	et on se sauve
	
* En cas d'erreur on vient ici	
ERREUR	MOVE.L	#MESSAGE_ERREUR,-(SP) pr‚vient
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP	
	
FIN	MOVE.W	#7,-(SP)   attend un appui touche
	TRAP	#1
	ADDQ.L	#2,SP	
	
	CMP.W	#0,RESOLUTION
	BEQ	NOT_MOYENNE
* Puisqu'on est en basse on reforce en moyenne r‚solution
	MOVE.W	#1,-(SP)	moyenne r‚solution
	MOVE.L	#-1,-(SP)  adresse ‚cran inchang‚e	
	MOVE.L	#-1,-(SP)  adresse ‚cran inchang‚e	
	MOVE.W	#5,-(SP)   fonction Setscreen()
	TRAP	#14	du xbios
	ADDA.L	#12,SP	correction
* Puis on quitte
NOT_MOYENNE
	MOVE.W	#0,-(SP)
	TRAP	#1
*-------------------------------------------------------------*
	SECTION DATA
MESSAGE_ERREUR	DC.B	"D‚sol‚, erreur avec",13,10
		DC.B	"le fichier "
NOM_FICHIER	DC.B	"A:\IMAGE.PI1",0

	SECTION BSS
BUFFER_PAL		DS.W	16
RESOLUTION		DS.W	1
		
	