**********************************************************************
************** ROUTINE 3D - SEPTEMBRE 1994 - ZANAK *******************
**********************************************************************

	SECTION TEXT
	
**********************************************************************
************** MEMOIRE - ECRANS **************************************
**********************************************************************
	MOVE.L	4(SP),A0
	
	MOVE.L	12(A0),D0	; TAILLE SECTION TEXT	
	ADD.L	20(A0),D0	; TAILLE SECTION DATA
	ADD.L	28(A0),D0	; TAILLE SECTION BSS
	ADDI.L	#256,D0	; TAILLE BASEPAGE
	ADDI.L	#256,D0	; TAILLE ERROR

	MOVE.L	D0,-(SP)	; TAILLE BLOCK ENTIER
	MOVE.L	A0,-(SP)	; ADRESSE BLOCK
	MOVE.W	#0,-(SP)
	MOVE.W	#$4A,-(SP)	; MSHRINK
	TRAP	#1	; CALL GEMDOS
	ADD.L	#12,SP
	
	TST.L	D0	; TESTE SI ERREUR ...
	BMI	BYE	; SI OUI FIN SINON
			; ON CONTINUE ...

**********************************************************************

	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)	; SUPERVISEUR
	TRAP	#1
	ADDQ.L	#6,SP

**********************************************************************
	
	MOVE.L	D0,-(SP)	; OLD REZ 
	LEA	VAR,A6	; VARIABLES

**********************************************************************
	
	MOVE.W	#2,-(SP)	; OU EST L'ECRAN PHYSIQUE ?
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,PSCR(A6)	; IL EST LA ...
	
	MOVE.W	#3,-(SP)	; OU EST L'ECRAN LOGIQUE ?
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,LSCR(A6)	; IL EST LA AUSSI ...
	
	MOVE.W	#-1,-(SP)	; ET LA RESOLUTION ?
	MOVE.W	#88,-(SP)
	TRAP	#14
	ADDQ.L	#4,SP
	MOVE.W	D0,REZ(A6)	; ELLE EST LA ...

**********************************************************************

	MOVE.L	#SIZE1,D0	; TAILLE 1
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN1(A6)	; CONFIG ECRAN1
	
	MOVE.L	#SIZE2,D0	; TAILLE 2
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN2(A6)	; CONFIG ECRAN2
	
**********************************************************************

	MOVE.W	#%100010010,-(SP)	; 16 Couls	
	MOVE.W	#3,-(SP)
	MOVE.L	ECRAN1(A6),-(SP)
	MOVE.L	ECRAN2(A6),-(SP)
	MOVE.W	#5,-(SP)	; VSETMODE
	TRAP	#14
	ADD.L	#14,SP
	
**********************************************************************

	MOVE.L	#MOUSOFF,-(SP)	; COUPE LA SOURIS
	CLR.W	-(SP)
	MOVE.W	#25,-(SP)
	TRAP	#14
	ADDQ	#8,SP
			
**********************************************************************
**********************************************************************

Suite_initialisation:
	bsr	Efface_ecran	
	bsr	Initialisation_3D
		

**********************************************************************
**********************************************************************

BYE	MOVE.L	#MOUSON,-(SP)	; REMET LA SOURIS
	CLR.W	-(SP)
	MOVE.W	#25,-(SP)
	TRAP	#14
	ADDQ.L	#8,SP
	
**********************************************************************

	MOVE.W	REZ(A6),-(SP)	; REMET LA REZ
	MOVE.W	#3,-(SP)
	MOVE.L	PSCR(A6),-(SP)	; REMET ECRAN PHYSIQUE
	MOVE.L	LSCR(A6),-(SP)	; REMET ECRAN LOGIQUE
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.L	#14,SP
	
**********************************************************************

	MOVE.W	#32,-(SP)	; USER	
	TRAP	#1
	ADDQ.L	#6,SP
	
	CLR	-(SP)	; RETOUR AU BUREAU
	TRAP	#1
		
**********************************************************************
* Sous Routines 
**********************************************************************

Efface_ecran:	lea	Ecran1,a0
	move.w	#size1,d0
Efface:	clr.l	(a0)+
	dbf	d0,Efface
	rts
	
Initialisation_3D:
Creation_de_la_table_X:
	lea.l 	table_x,a0		Rempli Table_x
	move.w 	#319,d0
	moveq.w	#0,d1
	move.w	#0,d2
rempli_table_x:
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	addq.w	#1,d2
	cmpi.w	#16,d2
	bne.s	rempli_table_x2
	moveq.w	#0,d2
	addq.w	#8,d1
rempli_table_x2:
	dbf	d0,rempli_table_x
	
Creation_de_la_table_Y:
	lea.l 	table_y,a0
	move.w	#199,d0
	moveq.w	#0,d1
rempli_table_y:	
	move.w	d1,(a0)+
	addi.w	#160,d1
	dbf	d0,rempli_table_y

Creation_de_la_table_Offset:
	lea.l	offset_x,a0

n set 0
 rept 20
	move.l	#code_x+n,(a0)+
	move.l	#code_x1+n,(a0)+
	move.l	#code_x2+n,(a0)+
	move.l	#code_x3+n,(a0)+
	move.l	#code_x4+n,(a0)+
	move.l	#code_x5+n,(a0)+
	move.l	#code_x6+n,(a0)+
	move.l	#code_x7+n,(a0)+
	move.l	#code_x8+n,(a0)+
	move.l	#code_x9+n,(a0)+
	move.l	#code_x10+n,(a0)+
	move.l	#code_x11+n,(a0)+
	move.l	#code_x12+n,(a0)+
	move.l	#code_x13+n,(a0)+
	move.l	#code_x14+n,(a0)+
	move.l	#code_x15+n,(a0)+
 n set n+(code_x17-code_x)
endr

Complete_table_X:
	lea.l	code_x,a0
	lea.l	code_x17,a1
	move.w	#18,d0
rempli_code_x:
rept (code_x17-code_x)
	move.b	(a0)+,(a1)+
endr
	dbf	d0,rempli_code_x

Complete_table_Y:
	lea.l	code_y,a0
	lea.l	code_y2,a1
	move.w	#198,d0
complete_x:
rept (code_y2-code_y)
	move.b	(a0)+,(a1)+
endr
	dbf	d0,complete_x

	lea.l	offset_y,a0
	lea.l	code_y,a1
	move.w	#199,d0
rempli_offset_y:
	move.l	a1,(a0)+
	add.l	#code_y2-code_y,a1
	dbf	d0,rempli_offset_y
	rts

	
**********************************************************************
	SECTION DATA
**********************************************************************

MOUSOFF	DC.B	18,0
MOUSON	DC.B	8,0
		
**********************************************************************
	SECTION BSS
**********************************************************************

SIZE1	DS.W	320*200+128
SIZE2	DS.W	320*200+128

VAR	DS.W	48

PSCR	RS.W	2
LSCR	RS.W	2
REZ	RS.W	1
ECRAN1	RS.W	2
ECRAN2	RS.W	2
		
	END