   ******************************************************************
   *                                                                *
   *             COURS D'ASSEMBLEUR 68000 SUR ATARI ST              *
   *                                                                *
   *                 par Le F‚roce Lapin (from 44E)                 *
   *                                                                *
   *                         Seconde s‚rie                          *
   *                                                                *
   *                        Listing num‚ro 2                        *
   *                                                                *
   ******************************************************************
	INCLUDE	"D:\START.S"

	MOVE.L	#MESSAGE,-(SP)	message de pr‚sentation
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP 

TOUCHE	MOVE.W	#7,-(SP)	attente appui sur une touche
	TRAP	#1
	ADDQ.L	#2,SP
	SWAP	D0	pour avoir le scan code
	
	CMP.W	#1,D0	escape ?
	BEQ	FIN	oui donc bye bye
	CMP.W	#$3B,D0	par rapport … F1
	BCS	TOUCHE	en dessous donc pas valable
	CMP.W	#$44,D0 	par rapport … F10
	BHI	TOUCHE	en dessus donc pas valable

* La touche est valable
	ADD.W	#6,D0	pour avoir asci de A,B,C...
	MOVE.W	D0,-(SP)	affiche
	MOVE.W	#2,-(SP)
	TRAP	#1
	ADDQ.L	#4,SP
	BRA	TOUCHE	et on recommence
	
FIN	CLR.W	-(SP)
	TRAP	#1
*--------------------------------------------------*
	SECTION DATA
MESSAGE	DC.B	27,"E","TAPEZ SUR UNE TOUCHE DE FONCTION",13,10
	DC.B	"ESCAPE POUR SORTIR",13,10,0
	SECTION BSS
	DS.L	256
PILE	DS.L	1
	END
