* Comment planter la machine sur une routine
* afin de la tracer...
* Ici il y a un illegal sur Fwrite(-3).

DEPART:	BRA	START	PRG r‚sident donc tˆte en bas!

	DC.B	"XBRA"
	DC.B	"KILL"			identificateur
ANC_TRAP:	
	DC.L	0
NEW_TRAP:	
	LEA	8(A7),A0	charge PILE
	BTST.B	#5,(A7)			super ou user ?
	BNE.S	SUPER
	MOVE	USP,A0			charge pile Utilisateur
SUPER:    	
	CMPI.W	#64,(A0)	appel … FWrite()?
	BNE.S	JMP_OLD
	CMPI.W	#-3,2(A0)		sur l'imprimante?
	BNE.S	JMP_OLD			non donc bye bye...
* Fwrite sur imprimante => plantage pour passer sous d‚buggeur
	ILLEGAL

JMP_OLD    
	MOVEA.L	ANC_TRAP(PC),A0 
	JMP	(A0)
*-----------------------------------------------------------------------*
* Installation: aucun test, ce genre de petit programme est …
* usage de d‚buggage uniquement! Ne pas diffuser aux utilisateurs!
START:	MOVEA.L	A7,A5
	MOVEA.L	4(A5),A5
	MOVE.L	$C(A5),D0
	ADD.L	$14(A5),D0
	ADD.L	$1C(A5),D0
	ADD.L	#$500,D0
	MOVE.L	D0,D1
	ADD.L	A5,D1
	AND.L	#$FFFFFFFE,D1 
	MOVEA.L	D1,SP
	MOVE.L	D0,-(SP)
	MOVE.L	A5,-(SP)
	CLR.W	-(SP)
	MOVE.W	#$4A,-(SP)
	TRAP	#1
	ADDA.L	#12,SP
* Passage en mode superviseur
  	CLR.L	-(SP)
  	MOVE.W  #$20,-(SP)
  	TRAP   	#1 
  	ADDQ.L 	#6,SP 
  	MOVE.L 	D0,ANC_PILE 

* Nous installons notre routine dans le TRAP #1
MISE_EN_PLACE:
	MOVE.L	$84,ANC_TRAP
	MOVE.L	#NEW_TRAP,$84

       	MOVE.L	ANC_PILE,-(SP)
  	MOVE.W	#$20,-(SP)
  	TRAP	#1
  	ADDQ.L	#6,SP
* Et nous quittons en restant r‚sidant...
	CLR.W	-(SP)
	MOVE.L	#START,D0	fin … laisser r‚sident
	SUB.L   #DEPART,D0	d‚but … laisser r‚sident
	ADD.L	#256,D0
	MOVE.L	D0,-(SP)
	MOVE.W	#49,-(SP)
	TRAP	#1
*-----------------------------------------------------------------*
	SECTION BSS
ANC_PILE:	
	DS.L	1
	END
	