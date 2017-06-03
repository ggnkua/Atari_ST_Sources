*       Source pr‚lev‚ dans Floppy num‚ro 5        *
* Affichage d'un ciel ‚toil‚ avec ‚toiles mobiles  *
* Tout d'abord le lanceur basic (juste pour info!) *

*Setcolor 0,0 
*Setcolor 15,7,7,7 
@Mode(0) 
*Open  i ,#1, \PROGRAMM.ES\pixplus.B  
*X$=Input$(Lof(#1),#1) 
*Close 
*A=Varptr(X$) 
*Setcolor 7,7,7,7 
*Setcolor 5,6,6,6 
*Setcolor 3,4,4,4 
*Setcolor 1,3,3,3 
*Hidem 
*Do 
*Vsync 
*X=C:A() 
*Exit If Mousek>0 
*Void Inp(2) 
*Loop 
*@Mode(1) 
*Setcolor 0,7,7,7 
*Edit 
*Procedure Mode(X) 
*Void Xbios(5,L:-1,L:-1,W:X) 
*Return 

* Le programme en assembleur. 


NB      	EQU       40	nombre d'‚toiles
INTIN   	EQU  8 
PTSIN   	EQU  12 

INIT    	EQU  $A000 
SETPIX  	EQU  $A001 
GETPIX  	EQU  $A002 

STAR: 
	DC.W    INIT 
	MOVE.L  INTIN(A0),A5 
	MOVE.L  PTSIN(A0),A6 

	LEA      TABLEX,A3 
	LEA      TABLEY,A2 
	LEA      TABLEV,A4 
	LEA      OLDTABLEX,A1 
	LEA      OLDTABLEY,A0 
	MOVE.L   #NB*2,D3	num‚ro de l'‚toile
	CLR.L    D4 

DRAPEAU1: 		*effacement du pixel courant
	MOVEM.L   D1-A6,-(SP) 
	MOVE.W    (A1,D3),(A6) 
	MOVE.W    (A0,D3),2(A6) 
	MOVE.W    #0,(A5) 
	DC.W      SETPIX 
	MOVEM.L   (SP)+,D1-A6 

* On ajoute le d‚placement au X de l'‚toile courante
	MOVE      (A4,D3),D4 
	ADD.W     D4,(A3,D3) 
	CMP.W          #319,(A3,D3)	sommes nous hors ‚cran?

	BLE     SUITE 
	MOVE.W  #0,(A3,D3)    	X est mis … 0
	ADDQ.W  #2,(A4,D3)     	1 en + pour la vitesse
	CMP.W   #7,(A4,D3)     	modifier la profondeur
	BLE     SUITE 
	MOVE.W  #1,(A4,D3) 

SUITE: 
	MOVEM.L   D1-A6,-(SP) 
	MOVE.W    (A3,D3),(A6) 
	MOVE.W    (A2,D3),2(A6) 
	DC.W      GETPIX               	Test couleur sous le pixel 
	MOVEM.L   (SP)+,D1-A6 
	CMP       #0,D0                  affiche pixel si fond vide 
	BEQ       AFF2 
	MOVE      #600,(A1,D3) 
	MOVE      #600,(A0,D3) 
BRA       FIN 

AFF2: 
	MOVE.W    (A3,D3),(A6)      	lecture coordonn‚es 
	MOVE.W    (A2,D3),2(A6) 
	MOVE.W    D4,(A5) 
	MOVEM.L   D1-A6,-(SP) 
	DC.W      SETPIX            	affichage pixel 
	MOVEM.L   (SP)+,D1-A6 

* On sauve les coordonn‚es pour pouvoir ult‚rieurement effacer
* le pixel.
	MOVE           (A3,D3),(A1,D3)    
	MOVE      (A2,D3),(A0,D3)  

FIN: 
	SUB       #2,D3             	hop, pixel suivant 
	CMP       #0,D3 
	BNE       DRAPEAU1	si on a tout affich‚, fin

	RTS 

TABLEX: 
	DC.W  10,25,45,78,51,24,68,98,41,52 
	DC.W  78,77,52,41,36,45,89,52,45,65 
	DC.W  44,12,11,33,25,48,78,85,55,66 
	DC.W  11,52,58,98,65,74,23,12,54,58 
	DC.W  45,45,45,78,78,51,23,22,33,12 
	DC.W  02,52,85,74,96,36,54,25,0,2 
	DC.W  10,25,45,78,51,24,68,98,41,52 
	DC.W  78,77,52,41,36,45,89,52,45,65 
	DC.W  44,12,11,33,25,48,78,85,55,66 
	DC.W  11,52,58,98,65,74,23,12,54,58 
	DC.W  45,45,45,78,78,51,23,22,33,12 
	DC.W  02,52,85,74,96,36,54,25,0,2 
	DC.W  10,25,45,78,51,24,68,98,41,52 
	DC.W  78,77,52,41,36,45,89,52,45,65 
	DC.W  44,12,11,33,25,48,78,85,55,66 
	DC.W  11,52,58,98,65,74,23,12,54,58 
	DC.W  45,45,45,78,78,51,23,22,33,12 
	DC.W  02,52,85,74,96,36,54,25,0,2 

TABLEY: 
	DC.W  01,05,10,12,15,22,28,35,40,44 
	DC.W  50,55,60 ,65 , 70, 75, 80, 85, 90, 95 
	DC.W  100,105,110,115,120,125,130,135,140,145 
	DC.W  180,182,184,186,188,190,192,194,196,198 
	DC.W  01,05,10,12,15,22,28,35,40,44 
	DC.W  50,55,60 ,65 , 70, 75, 80, 85, 90, 95 
	DC.W  100,105,110,115,120,125,130,135,140,145 
	DC.W  150,155,164,170,108,110,112,114,116,118 
	DC.W  120,122,124,126,128,130,132,134,136,138 
	DC.W  180,182,184,186,188,190,192,194,196,198 
	DC.W  01,05,10,12,15,22,28,35,40,44 
	DC.W  50,55,60 ,65 , 70, 75, 80, 85, 90, 95 
	DC.W  100,105,110,115,120,125,130,135,140,145 
	DC.W  150,155,164,170,108,110,112,114,116,118 
	DC.W  120,122,124,126,128,130,132,134,136,138 
	DC.W  180,182,184,186,188,190,192,194,196,198 
	DC.W  150,155,164,170,108,110,112,114,116,118 
	DC.W  120,122,124,126,128,130,132,134,136,138 
TABLEV: 
	DC.W  1,3,3,5,7,8,1,3,5,6 
	DC.W  1,5,6,8,4,2,3,1,2,5 
	DC.W  1,2,5,8,4,5,2,1,4,5 
	DC.W  5,4,5,8,4,5,8,7,4,5 
	DC.W  7,8,5,4,5,6,2,5,4,5 
	DC.W  7,8,9,8,7,1,5,2,3,1 
	DC.W  1,3,3,5,7,8,1,3,5,6 
	DC.W  1,5,6,8,4,2,3,1,2,5 
	DC.W  1,2,5,8,4,5,2,1,4,5 
	DC.W  5,4,5,8,4,5,8,7,4,5 
	DC.W  7,8,5,4,5,6,2,5,4,5 
	DC.W  7,8,9,8,7,1,5,2,3,1 
	DC.W  1,3,3,5,7,8,1,3,5,6 
	DC.W  1,5,6,8,4,2,3,1,2,5 
	DC.W  1,2,5,8,4,5,2,1,4,5 
	DC.W  5,4,5,8,4,5,8,7,4,5 
	DC.W  7,8,5,4,5,6,2,5,4,5 
	DC.W  7,8,9,8,7,1,5,2,3,1 
OLDTABLEX: 
	DS.W      120 

OLDTABLEY: 
	DS.W      120 

* C'est fini !
