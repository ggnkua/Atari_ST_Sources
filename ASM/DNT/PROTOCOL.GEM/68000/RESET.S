********************************************************
*           EXTRAIT DE LA BIBLIOTHEQUE TUBE GEM        *
*                  FICHIER "RESET.S"                   *
*              VERSION 2.00 (10 Avril 1991)            *
********************************************************
* Cette routine sert … d‚tourner le reset afin de mettre
* … 0 le contenu de l'adresse $5A0, au cas o— l'ACC
* s'ex‚cuterait sur un STF (Cookie-Jar non-impl‚ment‚)
* Cette routine est ex‚cut‚e en mode superviseur avec
* Xbios ($26) (Supexec())

PUT_RESET:	MOVE.L	$426,OLD_RESETV	sauve ancien magique
	MOVE.L	$42A,OLD_RESETR	sauve ancienne routine
	MOVE.L	#$31415926,$426	nouveau magique
	MOVE.L	#NEW_RESET,$42A	nouvelle routine
	RTS
* Nouvelle routine de RESET
NEW_RESET:	CLR.L	$5A0		Nettoyer pour cookie-jar	
	MOVE.L	OLD_RESETV,$426	remettre ancienne valeur
	MOVE.L	OLD_RESETR,$42A
	JMP	(A6)		retour … la ROM
*--------------------------------------------------------------------------*
