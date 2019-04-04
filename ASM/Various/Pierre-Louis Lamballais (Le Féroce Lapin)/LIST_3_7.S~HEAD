****************************************************************************
*                                                                         *
*                COURS D'ASSEMBLEUR 68000 SUR ATARI ST                    *
*                                                                         *
*                    par Le F‚roce Lapin (from 44E)                       *
*                                                                         *
*                  Listing num‚ro 3 / Cours num‚ro 7                      *
*                                                                         *
****************************************************************************

* Efface l'‚cran en affichant escape+E avec gemdos 9
	MOVE.L	#CLS,-(SP)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
	MOVEA.L	#TXT_FINAL,A6   adresse du txt_final dans A6
PROCHAINE	MOVE.B	#255,LETTRE     initialise la lettre
	ADD.B	#1,COLONE       et change de colone
	MOVE.B	(A6)+,D6   pr‚l‚ve une lettre et pointe la suivante
	CMP.B	#0,D6      fin du text … afficher ?
	BEQ	FIN        oui -> fin
	
AFFICHAGE	MOVE.L	#TXT,-(SP) affiche la lettre
	MOVE.W	#9,-(SP)   gemdos 9 car la lettre est incluse
	TRAP	#1     dans un phrase (escape+Y...)
	ADDQ.L	#6,SP
	
	CMP.B	LETTRE,D6  cette lettre c'‚tait la bonne ?
	BEQ	PROCHAINE  oui donc on passe … la suivante
	
	SUB.B	#1,LETTRE   non donc on recommence
	BRA	AFFICHAGE
	
FIN	MOVE.W	#7,-(SP)    attend un appui sur une touche
	TRAP	#1
	ADDQ.L	#2,SP
	
	MOVE.W	#0,-(SP)   et bye bye!
	TRAP	#1
*----------------------------------------------*
	SECTION DATA
CLS	DC.B	27,"E",0     
	EVEN
TXT	DC.B	27,"Y",42
COLONE	DC.B	42
LETTRE	DC.B	0,0
TXT_FINAL	DC.B	"FEROCE LAPIN",0


	
	