********* AFFICHAGE IMAGE IFF 320X200 *********
********* ZANAK/ATROCITY - JANV 1994  *********

	OPT	O+

***********************************************	
	SECTION TEXT
***********************************************
	
SUPER	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
** RECHERCHE DU CHECK ID VDAT *****************

	MOVE.L	#IFF,A0	
VDATA	MOVE.L	(A0)+,D0
	CMP.L	#'VDAT',D0
	BNE	VDATA	; VDAT TROUVE ?
	ADDQ.L	#7,A0	; 5 OCTETS APRES VDAT
	CLR.L	D0
	CLR.L	D1

	MOVE.L	#PLAN_1,A1
	BSR	DECOMPRESS

	MOVE.L	#PLAN_2,A1
	BSR	DECOMPRESS

	MOVE.L	#PLAN_3,A1
	BSR	DECOMPRESS

	MOVE.L	#PLAN_4,A1
	BSR	DECOMPRESS

	BSR	AFFICHE
		
** FIN DU PROGRAMME ***************************

BYE	CMP.B	#$39+$80,$FFFFFC02.W
	BNE	BYE
	

	CLR.L	-(SP)
	TRAP	#1

** SUB ROUTINES *******************************

** DECOMPRESSION DE L'IMAGE *******************

DECOMPRESS	MOVE.B	(A0)+,D0

	CMP.B	#$56,D0
	BEQ	TEST
	
	CMP.B	#$0F,D0
	BEQ	TEST	
	
SUITE	CMP.B	#128,D0	; EGAL A '-128' ? 
	BEQ	DECOMPRESS	; SI OUI NOP

	CMP.B	#255,D0	; INFERIEUR OU EGAL A '-1' ?
	BLE	RECOPY	; SI OUI RECOPIER OCTET SUIVANT
			; 1-D0 FOIS ...
			
	CMP.B	#127,D0	; INFERIEUR OU EGAL A '127' ?
	BLE	PRENDRE	; SI OUI PRENDRE DIRECTEMENT
			; D0+1 OCTET(S)

	BRA	DECOMPRESS

FIN	ADDQ.L	#1,A0
	RTS

** RECOPIER L'OCTET SUIVANT 1-D0 FOIS *********

RECOPY	MOVE.B	D0,D1
RECOPY_1	MOVE.B	D0,(A1)+
	DBF	D1,RECOPY_1
	BRA	DECOMPRESS
	
** PRENDRE DEIRECTEMENT D0+1 OCTETS ***********	

PRENDRE	MOVE.B	(A0)+,(A1)+
	DBF	D0,PRENDRE
	BRA	DECOMPRESS
		
** AFFICHER L'IMAGE ***************************

AFFICHE	MOVE.L	#4000,D0
	MOVE.L	$44E,A0
	MOVE.L	#PLAN_1,A1
	MOVE.L	#PLAN_2,A2
	MOVE.L	#PLAN_3,A3
	MOVE.L	#PLAN_4,A4
AFFICHE_1	MOVE.W	(A1)+,(A0)+
	MOVE.W	(A2)+,(A0)+
	MOVE.W	(A3)+,(A0)+
	MOVE.W	(A4)+,(A0)+
	DBF	D0,AFFICHE_1
	RTS
	
** TEST CHECK ID ******************************

TEST	MOVE.B	(A0)+,D0
	
	CMP.B	#$44,D0
	BEQ	FIN
	
	CMP.B	#$9F,D0
	BEQ	FIN
	
	SUBQ.L	#2,A0
	
	BRA	SUITE
	
***********************************************
	SECTION DATA
***********************************************
	
IFF	INCBIN	D:\TEST.IFF	
	EVEN

***********************************************
	SECTION BSS
***********************************************
	
PLAN_1	DS.B	8000
PLAN_2	DS.B	8000
PLAN_3	DS.B	8000
PLAN_4	DS.B	8000

	END
	