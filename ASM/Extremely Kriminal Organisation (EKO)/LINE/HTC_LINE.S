*******************************************************************************
*  Ex Routines de Lignes Rasters Horizontales au Timer-B pour How to Code 2!  *
*                            Initialisation + Code par                        *
*                                 J.R. FROM E.K.O                             *
*******************************************************************************

; Debut Programme Principal

DEBUT:

		CLR.L 	-(SP)		
		MOVE.W 	#$20,-(SP)	* Passage en Superviseur
		TRAP 	#1		
		ADDQ.L 	#6,SP	
		LEA	SAUVE,A0	* Sauvegarde 
		MOVE.L 	D0,(A0)

		BSR	SAVEREGISTER	* Appel procedure de sauvegarde hard	

		BSR	DEFINESCR	*  "       "      d'initiation ecrans
	
		BSR	SET_REZ         *  "       "      met en place resol

		BSR	SCR_CLEAN	*  "       "      efface les ecrans
		
	* Programme de creation des degrades
	
		BSR	PAUVBOULE
		MOVE.L	#COULEUR_THREE,GMALOCOUILLE
		BSR	PAUVBOULE
		MOVE.L	#COULEUR_TWO,GMALOCOUILLE
		BSR	PAUVBOULE
		MOVE.L	#COULEUR_ONE,GMALOCOUILLE
		BSR	PAUVBOULE

		BSR	SAVESYSTEM	* Sauvegarde des timers
	
		BSR	EXECUTE_VBL	* Excecution vbl

PLK:	
		BRA.S	PLK

END:
	
		BSR	OLDSYSTEM	* remet timers
		
		MOVE.B	ANC_VCOUNTHI,$FFFF8205.W	
		MOVE.B	ANC_VCOUNTMI,$FFFF8207.W	
		MOVE.B	ANC_VCOUNTLO,$FFFF8209.W
		MOVE.B	ANC_VCOUNTHO,$FFFF8265.W
		MOVE.B	ANC_VCOUNTVO,$FFFF820F.W

		BSR	PUT_OLDREZ	* ancienne resol
	
		MOVE.L	SAUVE,-(SP)	
		MOVE.W 	#$20,-(SP)	
		TRAP 	#1		
		ADDQ.L 	#6,SP		
	
		CLR.L	-(SP)		* fin
		TRAP	#1
	
; End Program Principal

PUT_OLDREZ:
		MOVE.W	OLD_RES,-(sp)		* Set rez
		MOVE.W	#3,-(sp)
		MOVE.L	OLD_PBAS,-(sp)
		MOVE.L	OLD_PBAS,-(sp)
		MOVE.W	#5,-(sp)
		TRAP	#14
		LEA	14(A7),A7
		DC.W	$A009			* tend mouse
		RTS

SAVEREGISTER:	
		MOVE.B	$FFFF8205.W,ANC_VCOUNTHI	
		MOVE.B	$FFFF8207.W,ANC_VCOUNTMI	
		MOVE.B	$FFFF8209.W,ANC_VCOUNTLO
		MOVE.B	$FFFF8265.W,ANC_VCOUNTHO
		MOVE.B	$FFFF820F.W,ANC_VCOUNTVO
		RTS	

DEFINESCR:
		MOVE.L	#BUF_SCR,D0	* Rend l'ecran multiple de 512
		ANDI.L	#$FFFFFF00,D0	
		ADD.L	#512,D0		
		LEA	ECRAN,A0
		MOVE.L	D0,(A0)
		RTS

SCR_CLEAN:
		MOVEA.L	ECRAN,A0			CLEAR SCREEN AREA
		MOVE.W #(32000)/4-1,D0
CL:		CLR.L (A0)+
		DBF D0,CL
		RTS

SET_REZ:
		DC.W	$A00A			* coupe Souris			

		MOVE.W	#2,-(SP)
		TRAP	#14
		ADDQ.L	#2,SP
		MOVE.L	D0,OLD_PBAS
	
		MOVE.W	#-1,-(SP)		* Save rez
		MOVE.W	#$58,-(SP)
		TRAP	#14
		ADDQ.L	#4,SP
		MOVE.W	D0,OLD_RES

		MOVE.W	#%00100010,-(SP)	* Set rez
		MOVE.W	#3,-(SP)
		MOVE.L	ECRAN,-(SP)
		MOVE.L	ECRAN,-(SP)
		MOVE.W	#5,-(SP)
		TRAP	#14
		LEA	14(A7),A7
		
		RTS

EXECUTE_VBL:
		CLR.B	$FFFFFA15.W		* Coupe interruption
		AND.B 	#$DF,$FFFFFA09.W	
		AND.B 	#$FE,$FFFFFA07.W
		MOVE.L  #VBL,$70.W	* Execute vbl
		MOVE.L 	#HBL_LINE,$120.W	* Execute hbl
		OR.B 	#1,$FFFFFA07.W
		OR.B 	#1,$FFFFFA13.W
		RTS

PAUVBOULE:
		MOVEA.L	GMALOCOUILLE,a0	
	
		MOVE.B	#0,D0		* R
		MOVE.B	#0,D1		* V
		MOVE.B	#0,D2		* B
		MOVE.B	#4,D3		* Inc R
		MOVE.B	#0,D4		* Inc V
		MOVE.B	#0,D5		* Inc B
		BSR	DEG
		MOVE.B	#-1,D0		* R
		MOVE.B	#0,D1		* V
		MOVE.B	#0,D2		* B
		MOVE.B	#0,D3		* Inc R
		MOVE.B	#4,D4		* Inc V
		MOVE.B	#0,D5		* Inc B
		BSR	DEG
		MOVE.B	#-1,D0		* R
		MOVE.B	#-1,D1		* V
		MOVE.B	#0,D2		* B
		MOVE.B	#-4,D3		* Inc R
		MOVE.B	#0,D4		* Inc V
		MOVE.B	#0,D5		* Inc B
		BSR	DEG
		MOVE.B	#0,D0		* R
		MOVE.B	#-1,D1		* V
		MOVE.B	#0,D2		* B
		MOVE.B	#0,D3		* Inc R
		MOVE.B	#-4,D4		* Inc V
		MOVE.B	#0,D5		* Inc B
		BSR	DEG
		RTS
	
DEG:
		MOVE.W	#64-1,D7
Deg_loopz:
		MOVE.B	D0,(A0)+
		MOVE.B	D1,(A0)+
		CLR.B	(A0)+
		MOVE.B	D2,(A0)+
		ADD.B	D3,D0
		ADD.B	D4,D1
		ADD.B	D5,D2
		DBF	D7,Deg_loopz
		RTS
	* Part des sauvegardes timers et interuptions
SAVESYSTEM:
		LEA	$FFFFFA01.W,A0
		MOVE.B	6(A0),OLDIERA
		MOVE.B	8(A0),OLDIERB
		MOVE.B	18(A0),OLDIMRA
		MOVE.B	20(A0),OLDIMRB
		MOVE.B	24(A0),OLDTACR
		MOVE.B	26(A0),OLDTBCR
		MOVE.B	28(A0),OLDTDCR
		MOVE.B	30(A0),OLDTADR
		MOVE.B	32(A0),OLDTBDR
		MOVE.B	34(A0),OLDTCDR
		MOVE.B	36(A0),OLDTDDR
		MOVE.L	$70.W,OLDVBL
		MOVE.L	$68.W,OLDHBL
		MOVE.L	$78.W,OLDVMFP
		MOVE.L	$134.W,OLDTIMA
		MOVE.L	$120.W,OLDTIMB
		MOVE.L	$114.W,OLDTIMC
		MOVE.L	$110.W,OLDTIMD
		MOVE.L	$118.W,OLDKEYB
		RTS
OLDSYSTEM:
		MOVE.W	#$2700,SR
		MOVE.L	OLDVBL(PC),$70.W
		MOVE.L	OLDHBL(PC),$68.W
		MOVE.L	OLDVMFP(PC),$78.W
		MOVE.L	OLDTIMA(PC),$134.W
		MOVE.L	OLDTIMB(PC),$120.W
		MOVE.L	OLDTIMC(PC),$114.W
		MOVE.L	OLDTIMD(PC),$110.W
		MOVE.L	OLDKEYB(PC),$118.W
		LEA	$FFFFFA01.W,A0
		MOVE.B	OLDIMRA(PC),18(A0)
		MOVE.B	OLDIMRB(PC),20(A0)
		MOVE.B	OLDTACR(PC),24(A0)
		MOVE.B	OLDTBCR(PC),26(A0)
		MOVE.B	OLDTDCR(PC),28(A0)
		MOVE.B	OLDTADR(PC),30(A0)
		MOVE.B	OLDTBDR(PC),32(A0)
		MOVE.B	OLDIERA(PC),6(A0)
		MOVE.B	OLDIERB(PC),8(A0)
		MOVE.W	#$2300,SR
		RTS
; SPACES POUR LA SAUVGARDE DES REGISTRES         
OLDVBL:		DS.L	1
OLDHBL:		DS.L	1
OLDVMFP:	DS.L	1
OLDTIMA:	DS.L	1
OLDTIMB:	DS.L	1
OLDTIMC:	DS.L	1
OLDTIMD:	DS.L	1
OLDKEYB:	DS.L	1
OLDIERA:	DS.B	1
OLDIERB:	DS.B	1
OLDIMRA:	DS.B	1
OLDIMRB:	DS.B	1
OLDTACR:	DS.B	1
OLDTBCR:	DS.B	1
OLDTDCR:	DS.B	1
OLDTADR:	DS.B	1
OLDTBDR:	DS.B	1
OLDTCDR:	DS.B	1
OLDTDDR:	DS.B	1
KBUFF:		DC.W 	0
		EVEN

; End Procedure du principal

***********************************************************************
*              		   Programme de la demo                       *
***********************************************************************
	
VBL:
		MOVEM.L	D0-A6,-(SP)	* Sauve registres
		MOVE.B 	#0,$FFFFFA1B.W	* coupure timer b	
		MOVE.B 	#1,$FFFFFA21.W	* Ligne d'affichage 1ere ligne raster
		MOVE.B 	#8,$FFFFFA1B.W  * et hop
		MOVE.L 	#HBL_LINE,$120.W	* let's go
		CMP.B	#$39,$FFFFFC02.W	* Test touche espace pour quitter
		BEQ	END
		MOVEM.L	(SP)+,D0-A6	; Remet registres
		ADDQ.W 	#1,VP		; Compteur vsync
		RTE

TURNOFFHBL:
		BCLR 	#0,$FFFFFA0F.W	; Fin hbl
		RTE

HBL_LINE:
		MOVE.B 	#0,$FFFFFA1B.W	* timer b out		
        	MOVEM.L A0-A2/D0,-(A7)	* sauvegarde registres utilises 
        	MOVEA.L TAB_TWO,A0	*met l'adr contenu dans tab_two ds a0
        	LEA     $FFFF9800.W,A1  * Registre hard couleur
        	LEA     $FFFFFA21.W,A2	* ligne d'affichage
        	BCLR    #0,-18(A2)
        	MOVE.L  #HBL_LINE2,$120.W 	* Appel seconde ligne 
        	MOVE.B  #196,(A2) 	  	* en ligne numero 196
        	MOVE.B  #8,-6(A2) 
        	MOVE.B  (A2),D0		  	* perte de temps
LINE:   	CMP.B   (A2),D0 
        	BEQ.S   LINE
        	REPT	43		 	* variables selon synchro
        	NOP	
        	ENDR
		REPT	45			* Nbre de deplacement sur la ligne
        	MOVE.L  (A0)+,(A1)	        * Met couleur degrades sur ligne
		ENDR
        	MOVE.L  #0,(A1)			* Couleur du fond a 0
        	MOVEM.L (A7)+,A0-A2/D0		* Remet registres utilises
        	ADDQ.L  #4,TAB_ONE		* additionne nouvelle adresse du
        	CMPI.L  #COULEUR_THREE,TAB_ONE	* pointeur couleur
        	BNE.S   LINE_END 		* Teste si la fin du degrade a ete 
        	MOVE.L  #COULEUR_TWO,TAB_ONE	* trouve
LINE_END:  
		RTE 
				* Commentaires identiques 
				* Sauf que le deplacement est contraire -(a0)
HBL_LINE2:
		MOVE.B 	#0,$FFFFFA1B.W		
        	MOVEM.L A0-A2/D0-D1,-(SP) 
        	MOVEA.L TAB_TWO,A0
        	LEA     $FFFF9800.W,A1 
        	LEA     $FFFFFA21.W,A2
        	BCLR    #0,-18(A2)
        	MOVE.L  #TURNOFFHBL,$120.W 
        	MOVE.B  #3,(A2) 
        	MOVE.B  #8,-6(A2) 
        	MOVE.B  (A2),D0 
LINE2:  	CMP.B   (A2),D0 
        	BEQ.S   LINE2
		REPT	44
		NOP
		ENDR
		REPT	45
       	 	MOVE.L  -(A0),(A1)
		ENDR
        	MOVE.L  #0,(A1)
        	MOVEM.L (SP)+,A0-A2/D0-D1
        	ADDQ.L  #4,TAB_TWO
        	CMPI.L  #COULEUR_THREE,TAB_TWO
        	BNE.S   LINE_END2 
        	MOVE.L  #COULEUR_TWO,TAB_TWO
LINE_END2:  
		RTE
	
WAITVSYNC:
		MOVE.W 	VP,D0	; test vsync
LO:		CMP.W 	VP,D0	; ne sert a rien ici
		BEQ.S 	LO
		RTS

	SECTION	BSS
DEBUT_BSS
ECRAN:		DS.L 	1		
ANC_VCOUNTHI:	DS.B	1
ANC_VCOUNTMI:	DS.B	1
ANC_VCOUNTVO:	DS.B	1
ANC_VCOUNTLO:	DS.B	1
ANC_VCOUNTHO:	DS.B	1		
SAUVE:		DS.L	1
OLD_RES:	DS.W	1
OLD_PBAS:	DS.L	1
GPASDESEXE:
		ds.l	256
COULEUR_TWO:
		ds.l	256
COULEUR_ONE:
		ds.l	256
COULEUR_THREE:
		ds.l	256
BUF_SCR:	
		DS.B	32512	;(160*200) 4 plans ; (320*200) 8 plans
END_BSS:
	SECTION	DATA
VP:		DC.W 0
		EVEN
TAB_ONE:
      		DC.L    COULEUR_TWO 
TAB_TWO:
      		DC.L    COULEUR_ONE 
TAB_THREE:
		DC.L    COULEUR_THREE 
		EVEN
GMALOCOUILLE:
		DC.L	GPASDESEXE
		EVEN
		
* Vla c'est tout! 
* Je signale qu'un article sur les timers est present sur ce disk
* lisez le avant de passer a cette applications pour mieux comprendre
* la coupure du timerb et la synchronisation du programme

* Suivant les resolutions ce programme est desynchronise, il suffit donc
* de rajouter des nops ou d'en retirer ou encore d'augmenter le nombre de deplacement

* Bon vla, je vous laisse a+ Hi to Alexis, Cedric, David, Boris, Pablo, et Lionnel bras casse!

* Eh hop vive E.K.O 