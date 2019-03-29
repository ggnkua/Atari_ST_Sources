**********************************************************************
*                                                                    *
*               COURS D'ASSEMBLEUR 68000 SUR ATARI ST                *
*                                                                    *
*                   par Le F‚roce Lapin (from 44E)                   *
*                                                                    *
*                           Seconde s‚rie                            *
*                                                                    *
*                         Listing  num‚ro 4                          *
**********************************************************************
* Automodification de programme
	INCLUDE	"B:\START.S"	routine de d‚marrage
	MOVE.L	#MESSAGE1,-(SP)	on pr‚sente
	MOVE.W	#9,-(SP)	le programme
	TRAP	#1
	ADDQ.L	#6,SP
DEBUT	MOVE.W	#7,-(SP)	attend un appui touche
	TRAP	#1
	ADDQ.L	#2,SP
	CMP.W	#" ",D0	espace ?
	BEQ	FIN	oui donc bye bye
	MOVE.W	#$4E71,VARIANTE	place un NOP (par d‚faut)
	CMP.W	#"A",D0	appui sur 'A'?
	BNE	ICI	non
	BSR	ROUTINE	oui donc sub-routine longue
	BRA	DEBUT	et on recommence
ICI	MOVE.W	#$4E75,VARIANTE	place un RTS … la place
	BSR	ROUTINE	du NOP et va … sub-routine
	BRA	DEBUT	puis recommence

FIN	MOVE.W	#0,-(SP)
	TRAP	#1
*--------------------------------------------*
ROUTINE	MOVE.L	#MESSAGE2,-(SP)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
VARIANTE	NOP
	MOVE.L	#MESSAGE3,-(SP)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	RTS
*--------------------------------------------*
	SECTION DATA
MESSAGE1	DC.B	27,"E","A pour un grand message,",13,10
	DC.B	"espace pour sortir, autre touche",13,10
	DC.B	"pour un message plus court",13,10,0
	EVEN
MESSAGE2	DC.B	13,10,"Voila le petit message...",0
	EVEN
MESSAGE3	DC.B	"Oups, non, c'est le long!!!",0
	EVEN
	SECTION BSS
	DS.L	100
PILE	DS.L	1
	END
