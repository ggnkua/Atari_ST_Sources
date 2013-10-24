****************************************************************************
*                                                                         *
*                COURS D'ASSEMBLEUR 68000 SUR ATARI ST                    *
*                                                                         *
*                    par Le F‚roce Lapin (from 44E)                       *
*                                                                         *
*                  Listing num‚ro 1 / Cours num‚ro 7                      *
*                                                                         *
****************************************************************************

DEBUT	MOVE.L	#MENU,-(SP) passe adresse phrase
	MOVE.W	#9,-(SP)	num‚ro fonction
	TRAP	#1	appel Gemdos
	ADDQ.L	#6,SP      correction pile
* attente appui touche
	MOVE.W	#7,-(SP)	fonction num‚ro 7
	TRAP	#1	du gemdos
	ADDQ.L	#2,SP	correction pile
* test du r‚sultat
	CMP.W	#"Q",D0    q majuscule ?
	BEQ	QUITTER    oui, bye bye
	CMP.W	#"q",D0    q minuscule ?
	BEQ	QUITTER    oui, bye bye
	CMP.W	#"V",D0    v majuscule ?
	BEQ	AFFICHAGE  oui -> affiche le message
	CMP.W	#"v",D0    V minuscule ?
	BNE	DEBUT      non. On a donc une autre lettre
* comme r‚ponse. Ce n'est pas valable donc on recommence au d‚but
AFFICHAGE	MOVE.L	#MESSAGE,-(SP)   adresse de 'coucou'
	MOVE.W	#9,-(SP)	      num‚ro fonction
	TRAP	#1	      appel Gemdos
	ADDQ.L	#6,SP            correction pile
* On attend un appui sur une touche pour contempler
	MOVE.W	#7,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	BRA	DEBUT	      retour au d‚but
	
QUITTER	MOVE.W	#0,-(SP)
	TRAP	#1
	
	SECTION DATA
	
MENU	DC.B	27,"E",27,"p"
	DC.B	"QUITTER (Q) OU VOIR LE MESSAGE (V) ?"
	DC.B	27,"q",13,10,0
	EVEN
MESSAGE	DC.B	"COUCOU",0


	
	