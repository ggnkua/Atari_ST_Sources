**********************************************************************
*                                                                    *
*               COURS D'ASSEMBLEUR 68000 SUR ATARI ST                *
*                                                                    *
*                   par Le F‚roce Lapin (from 44E)                   *
*                                                                    *
*                           Seconde s‚rie                            *
*                                                                    *
*                         Listing  num‚ro 5                          *
**********************************************************************

	INCLUDE	"B:\START.S"

	MOVE.L	#MESSAGE,-(SP)	coucou et efface ‚cran
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	DC.W	$A000	initialisation ligne A

	MOVE.W	#1,24(A0)	couleur du premier plan
	CLR.W	26(A0)	couleur du second
	MOVE.W	#2,36(A0)	type d'affichage
	MOVE.W	#50,38(A0)	X1
	MOVE.W	#50,40(A0)	Y1
	MOVE.W	#200,42(A0)	X2
	MOVE.W	#300,44(A0)	Y2
	MOVE.L	#MOTIF,46(A0)	adresse du motif
	MOVE.W	#3,50(A0)	nombre de mots du motif (-1)
	CLR.W	54(A0)	pas de clipping
	DC.W	$A005	appel … la fonction

	MOVE.W	#7,-(SP)	attente appui touche
	TRAP	#1
	ADDQ.L	#4,SP
	MOVE.W	#0,-(SP)	et bye bye
	TRAP	#1
*---------------------------------------*
	SECTION DATA
MESSAGE	DC.B	27,"E","Tracage de rectangle avec ligne A",0
	EVEN
* Motif, en .W Je l'ai ‚crit en binaire pour mieux voir le dessin.*
MOTIF	DC.W	%1100110011001100
	DC.W	%1100110011001100
	DC.W	%0011001100110011
	DC.W	%0011001100110011

	SECTION BSS
	DS.L	100
PILE	DS.L	1
	END
