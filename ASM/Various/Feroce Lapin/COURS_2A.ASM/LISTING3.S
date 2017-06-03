**********************************************************************
*                                                                    *
*                COURS D'ASSEMBLEUR 68000 SUR ATARI ST               *
*                                                                    *
*                   par Le F‚roce Lapin (from 44E)                   *
*                                                                    *
*                           Seconde s‚rie                            *
*                                                                    *
*                          Listing num‚ro 3                          *
*                                                                    *
**********************************************************************
	INCLUDE	"B:\START.S"

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
	BLO	TOUCHE	en dessous donc pas valable
	CMP.W	#$44,D0 	par rapport … F10
	BHI	TOUCHE	en dessus donc pas valable

* La touche est valable
	LEA	TABLEAU,A0
	SUB.W	#$3B,D0	pour avoir un chiffre de 0 … 9
*	MULU.W	#2,D0	ATTENTION! pourquoi l'‚toile d‚but ??
	MOVE.W	0(A0,D0.W),D1
	MOVE.W	D1,-(SP)
	MOVE.W	#2,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	BRA	TOUCHE

FIN	CLR.W	-(SP)
	TRAP	#1
*--------------------------------------------------*
	SECTION DATA
MESSAGE	DC.B	27,"E","TAPEZ SUR UNE TOUCHE DE FONCTION",13,10
	DC.B	"ESCAPE POUR SORTIR",13,10,0
	EVEN
TABLEAU	DC.W	"A","Z","E","R","T","Y","U","I","O","P"
	SECTION BSS
	DS.L	256
PILE	DS.L	1
	END
