*	Il faut, avant de lancer le loader (dans la demo)
*	detecter si c'est un mega,si c'est un STE et si on a 2 drives.
*	Pour un simple drive et/ou pour un 520,
*	le menu sera sur les 2 disks,au meme endroit.
*	Le bootsecteur : BOOT+2 = 'DISK1'
*	                     ou = 'DISK2'
*
*					Axel F.

*       SALUT ALTAIR. J'AI PASSE DEUX JOURS A ESSAYER DE
* DEBUGGER CE PUTAIN DE LOADER (QUI EST UNE MERDE).
* CA A ETE CODE PAR UN PORC, COMME UN PORC. SI TU ARRIVE A
* METTRE LE SOUNDTRACK STF ! SINON TE FAIS PAS CHIER, REPROGRAMMES EN
* UN, JE CROIS QUE CA IRA PLUS VITE.
*  		BONNE CHANCE.
*                                                 MAGNUM


		OPT	O+,D-

                clr.l   -(SP)
                move.w  #32,-(SP)
                trap    #1
                addq.l  #6,SP


		move.w	#0,ste

		CMP.W	#1,DEJA_PASSE
		BEQ	DACCORD
		CMP.W	#1,STE
		BNE.S	STF
		MOVE.W	#$F00,FIRSTCOL+2
		MOVE.W	#2,COUNT+2
		MOVE.L	#RAST2+2,PLACE_RASTER+12
		MOVE.L	#RAST2,PLACE_RASTER+20
		MOVE.B	#99,PLACE_RASTER+31
STF
		LEA	$FF8240,A0
		MOVEQ	#0,D0
		REPT	8
		MOVE.L	D0,(A0)+
		ENDR
		MOVE.L	#$70000,SCREEN
		MOVE.L	#IMAGE,A1
		MOVE.L	#$70000,A0
		ADD.L	#32000,A0
		ADD.L	#32000,A1
		MOVE.L	#(32000/4)-1,D0
COPY1		MOVE.L	-(A1),-(A0)
		DBF	D0,COPY1
		MOVE.W	#1,DEJA_PASSE
		
DACCORD
	MOVEQ	#0,D2
	TST.W	STE
	BEQ.S	TRACK_STF
	MOVEQ	#9,D2
TRACK_STF
	lea VariableOffset,a6
	move.l #Module,20(a6)	Pointer to start of module
	move.l #ModuleEnd,24(a6)	
	move D2,36(a6)
	move.b #1,38(a6)
	move.b #1,39(a6)
	move.b #61,40(a6)
	jsr (a6)	
	lea VariableOffset,a6
	jsr 4(a6)
	bsr	inter
	MOVE.L	SCREEN,D0
	MOVE.B	#0,$FF8260
	LSR.L	#8,D0
	MOVE.B	D0,$FF8203
	LSR.L	#8,D0
	MOVE.B	D0,$FF8201
	LEA	$FF8240,A2
	LEA	PALETTE,A3
	REPT	8
	MOVE.L	(A3)+,(A2)+
	ENDR

ERROR		LEA	PIC_LOAD,A0
		BSR	AFF_LOGO
		LEA	ARC_NORM,A0
		BSR	AFF_ARC
		MOVE.W	#35,X_FLECHE
		MOVEQ	#0,D0
		MOVE.W	X_FLECHE,D0
		ADD.L	D0,D0
		ADD.L	D0,D0				; = MULU #8
		ADD.L	D0,D0
		MOVE.L	SCREEN,A0
		ADD.L	#160*129,A0
		MOVE.L	#TAB_PUT,A1
		MOVE.L	(A1,D0.W),D2
		MOVE.L	4(A1,D0.W),A3
		ADD.W	D2,A0
		BSR	SAVEFOND
		JSR	(A3)
		MOVEQ	#0,D0
		MOVEQ	#0,D1
		MOVEQ	#0,D2
		MOVEQ	#0,D3
		MOVEQ	#0,D4
		MOVE.W	NUMERO,D0
		LSL.W	#3,D0
		LEA	TABLEAU,A0
		ADD.W	D0,A0
		MOVE.W	(A0)+,D0		* 1 er SECTEUR
		MOVE.W	(A0)+,D1		* NB DE SECTEURS A LIRE
		MOVE.W	(A0)+,D2		* LECTEUR 	2=A , 4=B
		MOVE.W	(A0)+,D3		* FACE		0
		LEA	SEC,A0			* ADRESSE OU CHARGER
		CMP.W	#1,TWODRIVE		* A-T-ON 2 DRIVES ?
		BEQ.S	GUTE
		BSR	TEST_DRIVE
GUTE		;BSR	WAIT_KEY
		BSR	FDC_DMA
		CMP.W	#-1,D4
		BNE.S	NOERROR
		BSR	RESITU
		BRA	ERROR
NOERROR		MOVE.W	#0,TEMPO
		MOVE.W	#2,ETAT
		LEA	PIC_DECRU,A0
		BSR	AFF_LOGO
		LEA	SEC,A0
		BSR	depack			* depack
		;LEA	SEC,A0
		;BSR	RELOGE			* reloge, si besoin est
		BSR	WAIT_KEY
FIN		MOVE.W	#0,ETAT
		MOVE.W	#$2700,SR
		move.l 	s120,$120.W
		move.l 	s70,$70.W
		move.b 	sa21,$fffa21
		move.b 	sa1b,$fffa1b
		move.b 	sa07,$fffa07
 		move.b 	sa13,$fffa13
		move.b 	sa09,$fffa09
		move.w	#0,$ff8240
		MOVE.W	#$2300,SR
		;JMP	SEC

		lea VariableOffset,a6	DeInstall
		jsr 8(a6)

		clr.l   -(SP)
                	trap    #1

VBL		
		CLR.B	$FFFF8260.W
		MOVEM.L	D0-D7/A0-A6,-(A7)
		ADDQ.W	#1,SYNC_VBL
		TST.W	STE
		BEQ.S	AXEL_F_IS_LAME
 		clr.b 	$fffa1b
COUNT		move.b 	#2,$fffa21
		move.b 	#8,$fffa1b
		MOVE.L	#I1,$120.W
FIRSTCOL		MOVE.W	#$F00,$FFFF8240.W
		BSR	PLACE_RASTER
AXEL_F_IS_LAME
		CMP.W	#0,ETAT
		BEQ.S	FINVBL
		CMP.W	#1,ETAT
		BEQ.S	LOADING
		CMP.W	#2,ETAT
		BEQ.S	DECRUNCHING
		BRA.S	FINVBL
LOADING		BSR	AFF_FLECHE
		BSR.S	CHANGE_TETE
		BRA.S	FINVBL
DECRUNCHING	BSR	CHANGE_TETE2
FINVBL		MOVEM.L	(A7)+,D0-D7/A0-A6
*		jmp	replaycode+7646
NULL
		RTE

CHANGE_TETE	ADDQ.W	#1,TEMPO
		CMP.W	#5,TEMPO
		BNE.S	RETOUR
		MOVE.W	#0,TEMPO
		MOVE.L	SUITETE,A0
		MOVE.L	(A0)+,A1
		CMP.L	#-1,A1
		BNE.S	BON
		MOVE.L	#DATA_TETE,A0
		MOVE.L	#PLEUR2,A1
BON		MOVE.L	A0,SUITETE
		MOVE.L	A1,A0
		BSR	AFF_TETE
RETOUR		RTS
TEMPO		DC.W	0
SUITETE		DC.L	DATA_TETE
DATA_TETE	DC.L	PLEUR1,PLEUR2,PLEUR3,PLEUR3,PLEUR3
		DC.L	PLEUR3,PLEUR3,PLEUR1,PLEUR2,PLEUR1
		DC.L	PLEUR2,PLEUR3,PLEUR3,PLEUR3,PLEUR3,-1

CHANGE_TETE2	ADDQ.W	#1,TEMPO
		CMP.W	#7,TEMPO
		BNE.S	RETOUR
		MOVE.W	#0,TEMPO
		MOVE.L	SUITETE2,A0
		MOVE.L	(A0)+,A1
		CMP.L	#-1,A1
		BNE.S	BON2
		MOVE.L	#DATA_TETE2,A0
		MOVE.L	#SOUFFLE1,A1
BON2		MOVE.L	A0,SUITETE2
		MOVE.L	A1,A0
		BSR	AFF_TETE
		RTS
SUITETE2	DC.L	DATA_TETE2
DATA_TETE2	DC.L	SOUFFLE1,SOUFFLE1,SOUFFLE2,SOUFFLE2,SOUFFLE2,-1

PLACE_RASTER:	BCHG	#0,COULEUR
		BNE.S	COL2
		LEA	RAST2+2,A0
		BRA.S	COL1
COL2		LEA	RAST2,A0
COL1		LEA	I1+2,A1
		MOVEQ	#100-1,D0
PLACE		MOVE.W	(A0)+,(A1)
		ADD.W	#16,A1
		DBF	D0,PLACE
		RTS
COULEUR		DC.W	0

inter
	MOVE.W	#$2700,SR
	move.l $120.W,s120
	move.l $70.W,s70
	move.b $fffa21,sa21
	move.b $fffa1b,sa1b
	move.b $fffa07,sa07 
 	move.b $fffa13,sa13
	move.b $fffa09,sa09
	MOVE.L	#VBL,$70.W
*	MOVE.L	#NULL,$110.W
	TST.W	STE
	BEQ.S	PAS_HBL_MERDE_PUTAIN_GUILLAUME_TU_FAIS_CHIER_A_CODER_COMME_UN_PORC
	ORI.B	#1,$FFFA07
	ORI.B	#1,$FFFA13
	CLR.B	$FFFA09
	BCLR	#3,$FFFA17
PAS_HBL_MERDE_PUTAIN_GUILLAUME_TU_FAIS_CHIER_A_CODER_COMME_UN_PORC
	MOVE.W	#$2300,SR
	rts

WAIT_KEY		
		CMP.B	#$39,$FFFC02
		BNE.S	WAIT_KEY
		RTS

AFF_FLECHE	MOVEM.L	D0-A6,-(A7)
		BSR	RESITU
		MOVEQ	#0,D0
		MOVE.W	X_FLECHE,D0
		ADD.L	D0,D0
		ADD.L	D0,D0				; = MULU #8
		ADD.L	D0,D0
		MOVE.L	SCREEN,A0
		ADD.L	#160*129,A0
		MOVE.L	#TAB_PUT,A1
		MOVE.L	(A1,D0.W),D2
		MOVE.L	4(A1,D0.W),A3
		ADD.W	D2,A0
		BSR.S	SAVEFOND
		JSR	(A3)
		MOVEM.L	(A7)+,D0-A6
		RTS

SAVEFOND	MOVEM.L	D0-A3,-(A7)
		LEA	FOND,A1
		MOVE.L	A0,ADDFOND
M		SET	0
N		SET	0
		REPT	6
		MOVEM.L	M(A0),D0-D7
		MOVEM.L	D0-D7,N(A1)
M		SET	M+160
N		SET	N+40
		ENDR
		MOVEM.L	(A7)+,D0-A3
		RTS

RESITU		MOVEM.L	D0-A3,-(A7)
		MOVE.L	ADDFOND,A0
		LEA	FOND,A1
M		SET	0
N		SET	0
		REPT	6
		MOVEM.L	M(A1),D0-D7
		MOVEM.L	D0-D7,N(A0)
M		SET	M+40
N		SET	N+160
		ENDR
		MOVEM.L	(A7)+,D0-A3
		RTS

OCCUP_FLECHE	MOVEM.L	D0-A6,-(A7)
		BSR.S	RESITU
		ADD.W	#35,X_FLECHE
		LEA	ARC_LANCE,A0
		BSR.S	AFF_ARC
		MOVEQ	#0,D0
		MOVE.W	X_FLECHE,D0
		ADD.L	D0,D0
		ADD.L	D0,D0				; = MULU #8
		ADD.L	D0,D0
		MOVE.L	SCREEN,A0
		ADD.L	#160*129,A0
		MOVE.L	#TAB_PUT,A1
		MOVE.L	(A1,D0.W),D2
		MOVE.L	4(A1,D0.W),A3
		ADD.W	D2,A0
		BSR	SAVEFOND
		JSR	(A3)
		MOVEM.L	(A7)+,D0-A6
		RTS

AFF_TETE	MOVEM.L	A0-A1/D0-D1,-(A7)
		MOVE.L	SCREEN,A1
		ADD.L	#(160-16)+100*160,A1
		MOVEQ	#$1C,D0
COPY4		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,D1
		MOVE.L	(A0)+,D1
		LEA	160-16+8(A1),A1
		DBF	D0,COPY4
		MOVEM.L (A7)+,A0-A1/D0-D1
		RTS

AFF_ARC		MOVEM.L A0-A1/D0-D1,-(A7)
		MOVE.L	SCREEN,A1
		ADD.L	#97*160,A1
		MOVEQ	#$3E-1,D0
COPY3		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,D1
		MOVE.L	(A0)+,D1
		LEA	128(A1),A1
		DBF	D0,COPY3
		MOVEM.L (A7)+,A0-A1/D0-D1
		RTS


AFF_LOGO	MOVEM.L A0-A1/D0,-(A7)
		MOVE.L	SCREEN,A1
		ADD.L	#32+10*160,A1
		
		MOVEQ	#7000/88-2,D0
COPY2
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		LEA	160-88(A1),A1
		DBF	D0,COPY2
		MOVEM.L (A7)+,A0-A1/D0
		RTS
***********************************************************************
TEST_DRIVE
		MOVEM.L D0-D7/A0-A6,-(A7)
		CMP.W	#0,NUMERO		* SI C'EST LE MENU ET PUISQU'
		BEQ.S	RIGHT			* IL EST SUR LES 2 DISKS
		CMP.W	CURENTDRIVE,D2
		BNE.S	NOT_WELL	
		MOVEM.L	(A7)+,D0-D7/A0-A6
		RTS
NOT_WELL	LEA	PIC_CHANGE,A0
		BSR.S	AFF_LOGO
		LEA	PILARCHER1,A2
		BSR	AFF_ARCHER
		BSR.S	WAIT_DISK
		LEA	PILARCHER2,A2
		BSR	AFF_ARCHER
		LEA	PIC_LOAD,A0
		BSR	AFF_LOGO
RIGHT		MOVEM.L	(A7)+,D0-D7/A0-A6
		MOVE.W	#2,D2
		RTS
WAIT_DISK
		CMP.W	#4,D2
		BNE.S	DISK2
		MOVE.B	#'2',SEARCH
		BRA.S	DISK1
DISK2		MOVE.B	#'1',SEARCH
DISK1		MOVE.L	#0,BOOT+2
		MOVEQ	#2,D2
		BSR	SETDRIVE
		MOVEQ	#0,D3
		BSR	SETSIDE
AGAIN		BSR	CHANGE_BULL
		ADDQ.W	#1,DSK		* En version finale
		CMP.W	#10,DSK		* Ceci est a virer
		BEQ.S	THERE		*
		MOVEQ	#0,D4
		LEA	BOOT,A1
		MOVEQ	#1,D1
		BSR   READ_SECTOR
		CMP.W	#-1,D4
		BEQ.S	AGAIN
		CMP.L	#'DISK',BOOT+2
		BNE.S	AGAIN
		MOVE.B	SEARCH,D2
		CMP.B	BOOT+6,D2
		BNE.S	AGAIN
THERE		BSR	EFF_BULL
		MOVE.W	#0,DSK
		RTS
SEARCH		DC.B	0
		EVEN
***********************************************************************
AFF_ARCHER	MOVE.L	SCREEN,A1
		ADD.L	#97*160,A1
		MOVE.L	(A2)+,A0
		CMP.L	#-1,A0
		BEQ.S	AR_RT
		MOVEQ	#$1E,D0
CC1		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+	
		MOVE.L	(A0)+,(A1)+	
		MOVE.L	(A0)+,(A1)+	
		MOVE.L	(A0)+,(A1)+	
		MOVE.L	(A0)+,(A1)+
		LEA	160-24(A1),A1
		DBF	D0,CC1
		MOVE.W	#0,SYNC_VBL
NOT_YET		CMP.W	#4,SYNC_VBL
		BNE.S	NOT_YET
		BRA.S	AFF_ARCHER
AR_RT		RTS
SYNC_VBL	DC.W	0
PILARCHER1	DC.L	ARCHER1,ARCHER2,ARCHER3,ARCHER4,ARCHER5,-1
PILARCHER2	DC.L	ARCHER5,ARCHER4,ARCHER3,ARCHER2,ARCHER1,-1
BUL		DC.L	0
AR		DC.L	0
DSK		DC.W	0
***********************************************************************
CHANGE_BULL
		MOVE.W	#0,SYNC_VBL
NOT_YET2	CMP.W	#50,SYNC_VBL
		BNE.S	NOT_YET2
		CMP.L	#HEYMAN,BUL
		BNE.S	B1
		MOVE.L	#HURRYUP,BUL
		BRA.S	B2
B1		MOVE.L	#HEYMAN,BUL
B2		CMP.L	#ARCHER5,AR
		BNE.S	B3
		MOVE.L	#ARCHER4,AR
		BRA.S	B4
B3		MOVE.L	#ARCHER5,AR
B4		MOVE.L	BUL,A0
		MOVE.L	SCREEN,A1
		ADD.L	#60*160,A1
		MOVEQ	#32,D0
BB1		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+
		LEA	160-32(A1),A1
		DBF	D0,BB1

		MOVE.L	SCREEN,A1
		ADD.L	#97*160,A1
		MOVE.L	AR,A0
		MOVEQ	#$1E,D0
CC3		MOVE.L	(A0)+,(A1)+
		MOVE.L	(A0)+,(A1)+	
		MOVE.L	(A0)+,(A1)+	
		MOVE.L	(A0)+,(A1)+	
		MOVE.L	(A0)+,(A1)+	
		MOVE.L	(A0)+,(A1)+
		LEA	160-24(A1),A1
		DBF	D0,CC3
		RTS

EFF_BULL	MOVE.L	SCREEN,A1
		ADD.L	#60*160,A1
		MOVEQ	#32,D0
		MOVEQ	#0,D1
BB2		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		LEA	160-32(A1),A1
		DBF	D0,BB2
		RTS
***********************************************************************
CALC_VITESSE_FLECHE
		MOVEM.L	D1-D2,-(A7)
		DIVU	#$A,D2
		AND.L	#$FFFF,D2
		MOVE.L	#170,D1			* 170 PIXELS
		DIVU	D2,D1
		MOVE.W	D1,ADDITIONNE_FLECHE		
		MOVEM.L	(A7)+,D1-D2
		RTS
ADDI_FLECHE	MOVE.W	ADDITIONNE_FLECHE,D0
		ADD.W	D0,X_FLECHE
		RTS
ADDITIONNE_FLECHE
		DC.W	0			* VITESSE DE LA FLECHE
X_FLECHE	DC.W	35			* COORD X DE LA FLECHE
**********************************************************************
FDC_DMA
		BSR	SETDRIVE
		BSR	SETSIDE
		MOVE.L	A0,A1
		MOVE.W  D1,D2 
      		SUBQ.W  #1,D2 
      		BMI.S   PAS_SECTEUR
		BSR.S	CALC_VITESSE_FLECHE
      		EXT.L   D0
      		DIVU    #$A,D0
      		MOVE.L  D0,D1 
      		SWAP    D1
      		ADDQ.W  #1,D1 
      		BSR.S   SEEK_TRACK
		BSR	OCCUP_FLECHE

		MOVE.W	#1,ETAT

CONTINU		BSR.S   READ_SECTOR
      		TST.W   D4
      		BNE.S   PRBM
		ADD.L	#512,A1
      		ADDQ.W  #1,D1 
      		CMP.W   #$A,D1
      		BLE.S   NO_PRBM
      		MOVEQ   #1,D1 
      		ADDQ.W  #1,D0 
		BSR.S	ADDI_FLECHE
		BSR.S	STEPIN
NO_PRBM		DBF     D2,CONTINU
PRBM		;BSR     MOTOR_OFF
      		RTS 
PAS_SECTEUR	MOVEQ	#-1,D4
		RTS

;***********************  Restore FDC ****************************

RESTORE:

                move.w  #$80,$FFFF8606.W  ; S‚lection du Command-Reg.
                move.w  #1,D7		; Command => Restore
                bsr   WRT1772         ; Envoi de la commande
                bsr   FDCWAIT         ; Attente jusqu'… ce que FDC soit prˆt
                rts

;***********************  SEEK TRACK  ****************************

SEEK_TRACK:

                move.w  #$86,$FFFF8606.W  ; S‚lection du registre de donn‚es
                move.w  D0,D7           ; Tracknr. dans d7
                bsr   WRT1772         ; Ecrire Tracknr.
                move.w  #$80,$FFFF8606.W  ; S‚lection du Command-Reg.
                move.w  #$11,D7         ; Command => Seek
                bsr   WRT1772         ; Ecrire commande
                bsr   FDCWAIT         ; Attente jusqu'… ce que FDC soit prˆt
                rts

;*************************  Step in  *****************************

STEPIN:

                move.w  #$80,$FFFF8606.W  ; S‚lection du FDC-Commandreg.
                move.w  #$51,D7 	; Command => Step in
                bsr   WRT1772         ; Ecrire commande
                bsr   FDCWAIT         ; Attente jusqu'… ce que FDC soit prˆt
                rts

;***********************  Force Interrupt  ***********************

FORCE:

                move.w  #$D0,D7  ; Command => Force Interrupt
                bsr   WRT1772         ; Ecrire commande
                move.w  #$0100,D7       ; Boucle de temporisation
WTFRC:
                dbra    D7,WTFRC
                rts

;*********************  READ SECTOR(S)  **************************

READ_SECTOR:

                move.l  A1,D7           ; DMA-Adress sur tampon de secteur
                bsr   SETDMA

      MOVE.W  #$90,$FF8606
      MOVE.W  #$190,$FF8606
      MOVE.W  #$90,$FF8606
      MOVE.W  #1,$FF8604
      MOVE.W  #$80,$FF8606
      MOVE.W  #$80,$FF8604

                move.w  #$84,$FFFF8606.W  ; S‚lectionner Sector-Reg.
                move.w  D1,D7           ; Sektor-Nr. dans d7
                bsr   WRT1772         ; Ecrire Sektor-Nr.

                move.w  #$80,$FFFF8606.W  ; S‚lection du Command-Reg.
                move.w  #$84,D7         ; Command => Read multiple Sectors
                bsr     WRT1772         ; Ecrire commande

                bsr   FDCWAIT         ; attente jusqu'… ce que FDC soit prˆt
                bsr.s   READSTAT        ; Lire ‚tat et nbr d'octets
                rts

;*********************  WRITE SECTOR(S)  *************************

WRITESECTOR:

                move.l  32(A5),D7       ; DMA-Adress sur Sector-Buffer
                bsr.s   SETDMA
                move.w  #$190,$FFFF8606.W  ; DMA-R/W toggel
                move.w  #$90,$FFFF8606.W
                move.w  #$190,$FFFF8606.W  ; S‚lection du DMA-Sectorcount
                move.w  #$0C,D7         ; charger avec 12  (correspond …  6ko)
                bsr.s   WRT1772         ; Ecrire DMA-Scnt
                move.w  #$184,$FFFF8606.W  ; S‚lectionner Sector-Reg.
                move.w  6(A5),D7        ; Sektornr. dans d7
                bsr.s   WRT1772         ; Ecrire Sektor-Reg.

                move.w  #$180,$FFFF8606.W  ; S‚lectionner Command-Reg.
                move.w  #$B0,D7  ; Command => Write multiple Sectors
                bsr.s   WRT1772         ; Ecrire commande
                bsr.s   FDCWAIT         ; Attente jusqu'… ce que FDC soit prˆt
                bsr.s   READSTAT        ; Lire l'‚tat et le nombre d'octets
                rts

                rts

;********************  Set DMA-Transfer Adress  *****************

SETDMA:

                move.l  D7,ADD_DEB       ; Mettre Start-Adress dans FDC-Array
                move.b  D7,$FFFF860D.W       ; Ecrire d'abord  Low-Byte
                lsr.l   #8,D7
                move.b  D7,$FFFF860B.W       ; puis Mid-Byte
                lsr.l   #8,D7
                move.b  D7,$FFFF8609.W      ; et enfin  High-Byte

                move.l  ADD_DEB,D7       ; R‚cup‚ration de la Start-Adress
                moveq   #0,D6
		move.w	#512,d6
                add.l   D6,D7           ; Addition des deux
                move.l  D7,ADD_FIN       ; =Adresse de fin attendue
                rts

;*** Lecture du DMA-Status; calcul des octets … transf‚rer  ***

READSTAT:

                move.w  $FFFF8606.W,D5      ; Lecture du DMA-Status
                and.w   #$07,D5         ; Prendre seulement les 3 bits inf‚rieurs
                move.w  D5,14(A5)       ; ert aprŠs fdcout

                moveq   #0,D5           ; Lecture de la DMA-Endadress
                move.b  $FFFF8609.W,D5
                lsl.l   #8,D5
                move.b  $FFFF860B.W,D5
                lsl.l   #8,D5
                move.b  $FFFF860D.W,D5

                move.l  D5,24(A5)       ; End-Adress dans Array
                sub.l   20(A5),D5       ; End-Adr. moins Start-Adr.
                move.w  D5,18(A5)       ; =Nombre d'octets
                rts

;*****************    Ecriture du FDC-Register    *******************

WRT1772:

                bsr   WAIT
                move.w  D7,$FFFF8604.W      ; Ecrire FDC-Reg. ou DMA-Sectorcount
                bsr   WAIT
                rts

;*****************     Lecture du FDC-Register      ********************

READ1772:

                bsr   WAIT
                move.w  $FFFF8604.W,D5      ; Lire FDC-Reg. ou DMA-Sectorcount
                bsr   WAIT
                rts

;****************    Attente jusqu'… ce que FDC soit prˆt *****************

FDCWAIT:

                move.l  #$0180,D5       ; Attendre un peu jusqu'… ce Busy soit positionn‚
LITLWT:         dbra    D5,LITLWT
                move.l  #$040000,D5     ; d5 sert de compteur Timeout

READMFP         btst    #5,$FFFFFA01.W          ; Commande finie ?
                beq.s   FDCREADY        ; oui
                subq.l  #1,D5           ; non, D‚cr‚menter compteur Timeout
                beq.s   TIMEOUT         ; Si arriv‚ … la fin
                BRA.S   READMFP         ; non, Continuer le test
                move.b  $FFFF8609.W,ADD_FIN+1 ; C'est la  DMA-Endadress attendue
                move.b  $FFFF860B.W,ADD_FIN+2 ; d‚j… atteinte ?
                move.b  $FFFF860D.W,ADD_FIN+3
                move.l  ADD_FIN,D7
                cmp.l   ADD_END,D7
                blt.s   READMFP         ; non, continuer … tester
                bsr   FORCE           ; Si oui, interrompre la commande
                bra.s     FDCREADY        ; et quitter normalement la routine
TIMEOUT:
                move.w  $FFFF8604.W,D5      ; Lire l'‚tat avant l'interruption
                and.w   #$FF,D5         ; Masquer l'octet de poids fort
                move.w  D5,STATUS	;12(A5)       ; Et mettre dans l'Array
                bsr   FORCE           ; ArrŠter la commande
		MOVEQ	#-1,D4		* PROBLEME
                rts
FDCREADY:
                move.w  $FFFF8604.W,D5      ; Lire l'‚tat
                and.w   #$FF,D5         ; Masquer l'octet de poids fort
                move.w  D5,STATUS	;12(A5)       ; et mettre dans le FDC-Array	*ICI
                rts

;************  Attendre jusqu'… ce que le moteur soit arrŠt‚ ************

MOTOR_OFF:

                move.w  #$80,$FFFF8606.W  ; S‚lection du Statusreg.
TEST:
                bsr     READ1772        ; et lecture
                btst    #7,D5           ; Motor-on positionn‚
                bne.s   TEST            ; oui, continuer l'attente
                rts

;*************************    Wait   *****************************

WAIT:
                move    SR,-(SP)        ; Sauvegarder Status
                move.w  #$20,D5         ; d5 sert de compteur
WT2:
                dbra    D5,WT2
                move    (SP)+,SR        ; R‚cup‚rer Status
                rts

;*****************  SELECTION DE LA FACE  *******************************

SETSIDE
      MOVE    SR,-(A7)
      ORI.W   #$700,SR
      MOVE.B  #$E,$FFFF8800.W
      MOVE.B  $FFFF8800.W,D7 
      CMP.B   #0,D3
      BNE.S   FACE1
      BSET    #0,D7
      BRA.S   O.K.
FACE1 BCLR    #0,D7
O.K.  MOVE.B  D7,$FFFF8802.W 
      MOVE    (A7)+,SR
      RTS 


;*****************  S‚lection du lecteur et de la piste  ****************

SETDRIVE:

		cmp.b	#0,d2
                bne.s   SET
                bsr.s   MOTOR_OFF        ; Si 0, d'abord d‚selectionner quand motor OFF
SET:
                eori.b  #7,D2           ; Inverser les Bits pour le  Hardware
                and.b   #7,D2           ; Seuls les 3 Low-Bits sont modifi‚s
                move    SR,-(SP)        ; Sauvegarder Status
                ori     #$0700,SR       ; D‚sactiver Interruptions
                move.b  #$0E,$FFFF8800.W   ; S‚lectionner Port A du Sound-Chips
                move.b  $FFFF8800.W,D5     ; Lire Port A
                and.b   #$F8,D5         ; Effacer Bits 0-2
                or.b    D5,D2           ; Positionner nouveaux bits
                move.b  D2,$FFFF8802.W  ; Et ‚crire sur  Port A
                move    (SP)+,SR        ; restore Status
		bsr	RESTORE
                rts

;***************************** FIN ******************************
ADD_DEB		DC.L	0
ADD_FIN		DC.L	0
ADD_END		DC.L	0
STATUS		DC.W	0

*****************************************************************
I1	move.w	#$700,$FFFF8240.W
	move.l #I2,$120.w
	rte
I2	move.w	#$701,$FFFF8240.W
	move.l #I3,$120.w
	rte
I3	move.w	#$702,$FFFF8240.W
	move.l #I4,$120.w
	rte
I4	move.w	#$703,$FFFF8240.W
	move.l #I5,$120.w
	rte
I5	move.w	#$704,$FFFF8240.W
	move.l #I6,$120.w
	rte
I6	move.w	#$705,$FFFF8240.W
	move.l #I7,$120.w
	rte
I7	move.w	#$706,$FFFF8240.W
	move.l #I8,$120.w
	rte
I8	move.w	#$707,$FFFF8240.W
	move.l #I9,$120.w
	rte
I9	move.w	#$607,$FFFF8240.W
	move.l #I10,$120.w
	rte
I10	move.w	#$507,$FFFF8240.W
	move.l #I11,$120.w
	rte
I11	move.w	#$407,$FFFF8240.W
	move.l #I12,$120.w
	rte
I12	move.w	#$307,$FFFF8240.W
	move.l #I13,$120.w
	rte
I13	move.w	#$207,$FFFF8240.W
	move.l #I14,$120.w
	rte
I14	move.w	#$107,$FFFF8240.W
	move.l #I15,$120.w
	rte
I15	move.w	#7,$FFFF8240.W
	move.l #I16,$120.w
	rte
I16	move.w	#6,$FFFF8240.W
	move.l #I17,$120.w
	rte
I17	move.w	#5,$FFFF8240.W
	move.l #I18,$120.w
	rte
I18	move.w	#4,$FFFF8240.W
	move.l #I19,$120.w
	rte
I19	move.w	#3,$FFFF8240.W
	move.l #I20,$120.w
	rte
I20	move.w	#2,$FFFF8240.W
	move.l #I21,$120.w
	rte
I21	move.w	#1,$FFFF8240.W
	move.l #I22,$120.w
	rte
I22	move.w	#1,$FFFF8240.W
	move.l #I23,$120.w
	rte
I23	move.w	#1,$FFFF8240.W
	move.l #I24,$120.w
	rte
I24	move.w	#1,$FFFF8240.W
	move.l #I25,$120.w
	rte
I25	move.w	#1,$FFFF8240.W
	move.l #I26,$120.w
	rte
I26	move.w	#1,$FFFF8240.W
	move.l #I27,$120.w
	rte
I27	move.w	#1,$FFFF8240.W
	move.l #I28,$120.w
	rte
I28	move.w	#1,$FFFF8240.W
	move.l #I29,$120.w
	rte
I29	move.w	#1,$FFFF8240.W
	move.l #I30,$120.w
	rte
I30	move.w	#1,$FFFF8240.W
	move.l #I31,$120.w
	rte
I31	move.w	#1,$FFFF8240.W
	move.l #I32,$120.w
	rte
I32	move.w	#1,$FFFF8240.W
	move.l #I33,$120.w
	rte
I33	move.w	#1,$FFFF8240.W
	move.l #I34,$120.w
	rte
I34	move.w	#1,$FFFF8240.W
	move.l #I35,$120.w
	rte
I35	move.w	#1,$FFFF8240.W
	move.l #I36,$120.w
	rte
I36	move.w	#1,$FFFF8240.W
	move.l #I37,$120.w
	rte
I37	move.w	#1,$FFFF8240.W
	move.l #I38,$120.w
	rte
I38	move.w	#1,$FFFF8240.W
	move.l #I39,$120.w
	rte
I39	move.w	#1,$FFFF8240.W
	move.l #I40,$120.w
	rte
I40	move.w	#1,$FFFF8240.W
	move.l #I41,$120.w
	rte
I41	move.w	#1,$FFFF8240.W
	move.l #I42,$120.w
	rte
I42	move.w	#1,$FFFF8240.W
	move.l #I43,$120.w
	rte
I43	move.w	#1,$FFFF8240.W
	move.l #I44,$120.w
	rte
I44	move.w	#1,$FFFF8240.W
	move.l #I45,$120.w
	rte
I45	move.w	#1,$FFFF8240.W
	move.l #I46,$120.w
	rte
I46	move.w	#1,$FFFF8240.W
	move.l #I47,$120.w
	rte
I47	move.w	#1,$FFFF8240.W
	move.l #I48,$120.w
	rte
I48	move.w	#1,$FFFF8240.W
	move.l #I49,$120.w
	rte
I49	move.w	#1,$FFFF8240.W
	move.l #I50,$120.w
	rte
I50	move.w	#1,$FFFF8240.W
	move.l #I51,$120.w
	rte
I51	move.w	#1,$FFFF8240.W
	move.l #I52,$120.w
	rte
I52	move.w	#1,$FFFF8240.W
	move.l #I53,$120.w
	rte
I53	move.w	#1,$FFFF8240.W
	move.l #I54,$120.w
	rte
I54	move.w	#1,$FFFF8240.W
	move.l #I55,$120.w
	rte
I55	move.w	#1,$FFFF8240.W
	move.l #I56,$120.w
	rte
I56	move.w	#1,$FFFF8240.W
	move.l #I57,$120.w
	rte
I57	move.w	#1,$FFFF8240.W
	move.l #I58,$120.w
	rte
I58	move.w	#1,$FFFF8240.W
	move.l #I59,$120.w
	rte
I59	move.w	#1,$FFFF8240.W
	move.l #I60,$120.w
	rte
I60	move.w	#1,$FFFF8240.W
	move.l #I61,$120.w
	rte
I61	move.w	#1,$FFFF8240.W
	move.l #I62,$120.w
	rte
I62	move.w	#1,$FFFF8240.W
	move.l #I63,$120.w
	rte
I63	move.w	#1,$FFFF8240.W
	move.l #I64,$120.w
	rte
I64	move.w	#1,$FFFF8240.W
	move.l #I65,$120.w
	rte
I65	move.w	#1,$FFFF8240.W
	move.l #I66,$120.w
	rte
I66	move.w	#1,$FFFF8240.W
	move.l #I67,$120.w
	rte
I67	move.w	#1,$FFFF8240.W
	move.l #I68,$120.w
	rte
I68	move.w	#1,$FFFF8240.W
	move.l #I69,$120.w
	rte
I69	move.w	#1,$FFFF8240.W
	move.l #I70,$120.w
	rte
I70	move.w	#1,$FFFF8240.W
	move.l #I71,$120.w
	rte
I71	move.w	#1,$FFFF8240.W
	move.l #I72,$120.w
	rte
I72	move.w	#1,$FFFF8240.W
	move.l #I73,$120.w
	rte
I73	move.w	#1,$FFFF8240.W
	move.l #I74,$120.w
	rte
I74	move.w	#1,$FFFF8240.W
	move.l #I75,$120.w
	rte
I75	move.w	#1,$FFFF8240.W
	move.l #I76,$120.w
	rte
I76	move.w	#1,$FFFF8240.W
	move.l #I77,$120.w
	rte
I77	move.w	#1,$FFFF8240.W
	move.l #I78,$120.w
	rte
I78	move.w	#1,$FFFF8240.W
	move.l #I79,$120.w
	rte
I79	move.w	#1,$FFFF8240.W
	move.l #I80,$120.w
	rte
I80	move.w	#1,$FFFF8240.W
	move.l #I81,$120.w
	rte
I81	move.w	#1,$FFFF8240.W
	move.l #I82,$120.w
	rte
I82	move.w	#1,$FFFF8240.W
	move.l #I83,$120.w
	rte
I83	move.w	#1,$FFFF8240.W
	move.l #I84,$120.w
	rte
I84	move.w	#1,$FFFF8240.W
	move.l #I85,$120.w
	rte
I85	move.w	#1,$FFFF8240.W
	move.l #I86,$120.w
	rte
I86	move.w	#1,$FFFF8240.W
	move.l #I87,$120.w
	rte
I87	move.w	#1,$FFFF8240.W
	move.l #I88,$120.w
	rte
I88	move.w	#1,$FFFF8240.W
	move.l #I89,$120.w
	rte
I89	move.w	#1,$FFFF8240.W
	move.l #I90,$120.w
	rte
I90	move.w	#1,$FFFF8240.W
	move.l #I91,$120.w
	rte
I91	move.w	#1,$FFFF8240.W
	move.l #I92,$120.w
	rte
I92	move.w	#1,$FFFF8240.W
	move.l #I93,$120.w
	rte
I93	move.w	#1,$FFFF8240.W
	move.l #I94,$120.w
	rte
I94	move.w	#1,$FFFF8240.W
	move.l #I95,$120.w
	rte
I95	move.w	#1,$FFFF8240.W
	move.l #I96,$120.w
	rte
I96	move.w	#1,$FFFF8240.W
	move.l #I97,$120.w
	rte
I97	move.w	#1,$FFFF8240.W
	move.l #I98,$120.w
	rte
I98	move.w	#1,$FFFF8240.W
	move.l #I99,$120.w
	rte
I99	move.w	#1,$FFFF8240.W
	move.l #I100,$120.w
	rte
I100	move.w	#0,$FFFF8240.W
	clr.b	$fffa1b
	clr.b	$fffa21
	rte
*****************************************************************
;decrunch source code of ATOMIK by ALTAIR	;je tiens a preciser
;A0=packed code		;que j'ai entierement
;call it by bsr		;ecris ce compacteur
			;environnement compris.
DEC_MARGE:	equ	$10	;min=0 , max=126 (pair!)
RESTORE_M:	equ	1	;argh j'ai plant‚ pendant
			;10 jours sur TOTAL RECALL
			;a cause de ca!!!!!
PIC_ALGO:	equ	1	;PIC_ALGO=1,RESTORE_M=0 ; lenght=$18e
depack:	movem.l	d0-a6,-(a7)	;PIC_ALGO=0,RESTORE_M=0 ; lenght=$146
	cmp.l	#"ATOM",(a0)+	;RESTORE_M=1 ; lenght=lenght+
	bne	no_crunched	;DEC_MARGE+$32
	move.l	(a0)+,d0
	move.l	d0,-(a7)
	lea	DEC_MARGE(a0,d0.l),a5
	ifne	RESTORE_M
	move.l	a5,a4
	lea	buff_marg(pc),a3
	moveq	#DEC_MARGE+9,d0
.save_m:	move.b	-(a4),(a3)+
	dbf	d0,.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.l	(a0)+,d0	
	lea	0(a0,d0.l),a6
	move.b	-(a6),d7
	bra	make_jnk
tablus:	lea	tablus_table(pc),a4
	moveq	#1,d6
	bsr.s	get_bit2
	bra.s	tablus2
decrunch:	moveq	#6,d6
take_lenght:	add.b	d7,d7
	beq.s	.empty1
.cont_copy:	dbcc	d6,take_lenght
	bcs.s	.next_cod
	moveq	#6,d5
	sub	d6,d5
	bra.s	.do_copy
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#6,d5
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15+6,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_copy
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15+6,d5
.do_copy:	move	d5,-(a7)
	bne.s	bigger
	lea	decrun_table2(pc),a4
	moveq	#2,d6
	bsr.s	get_bit2
	cmp	#5,d5
	blt.s	contus
	addq	#2,a7
	subq	#6,d5
	bgt.s	tablus
	move.l	a5,a4
	blt.s	.first4
	addq	#4,a4
.first4:	moveq	#1,d6
	bsr.s	get_bit2
tablus2:	move.b	0(a4,d5.w),-(a5)	
	bra.s	make_jnk
get_bit2:	clr	d5
.get_bits:	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger:	lea	decrun_table(pc),a4
cont:	moveq	#2,d6
	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	bsr.s	get_bit2
	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move	(a7)+,d5
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d5,.copy_same
make_jnk:	moveq	#11,d6
	moveq	#11,d5
take_jnk:	add.b	d7,d7
	beq.s	empty
cont_jnk:	dbcc	d6,take_jnk
	bcs.s	next_cod
	sub	d6,d5
	bra.s	copy_jnk1
next_cod:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#8,d5
	addq	#3,d5
	bra.s	copy_jnk1
.next_cod1:	moveq	#2,d6
	bsr.s	get_bit2
	swap	d5
	moveq	#15,d6
	bsr.s	get_bit2
	addq.l	#8,d5
	addq.l	#3,d5	
copy_jnk1:	subq	#1,d5
	bmi.s	.end_word
	moveq	#1,d6
	swap	d6
.copy_jnk:	move.b	-(a6),-(a5)
	dbf	d5,.copy_jnk
	sub.l	d6,d5
	bpl.s	.copy_jnk
.end_word:	cmp.l	a6,a0
.decrunch:	bne	decrunch
	cmp.b	#$80,d7
	bne.s	.decrunch
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	bsr.s	decod_picture
	endc
	ifne	RESTORE_M
	movem.l	(a7)+,a3-a4
	endc
	move.l	(a7)+,d0
	bsr	copy_decrun
	ifne	RESTORE_M
	moveq	#DEC_MARGE+9,d0
.restore_m:	move.b	-(a3),(a4)+
	dbf	d0,.restore_m
	endc
no_crunched:	movem.l	(a7)+,d0-a6
 	rts
empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	cont_jnk
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	4,5,7,8,9,10,11,12
decrun_table2:	dc.w	32,32+64,32+64+128,32+64+128+256
	dc.w	32+64+128+256+512,32+64+128+256+512*2
	dc.w	32+64+128+256+512*3
	dc.b	4,5,6,7,8,8
tablus_table:	dc.b	$60,$20,$10,$8
	ifne	PIC_ALGO
decod_picture:	move	-(a0),d7
	clr	(a0)
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	clr.l	(a0)
	lea	0(a5,d0.l),a1
	lea	$7d00(a1),a2
.next_planes:	moveq	#3,d6
.next_word:	move	(a1)+,d0
	moveq	#3,d5
.next_bits:	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc
copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	ifne	RESTORE_M
buff_marg:	dcb.b	DEC_MARGE+10,0
	endc
*****************************************************************
SCREEN		DC.L	0

PIC_LOAD		INCBIN	PICLOAD.IMG
PIC_CHANGE	INCBIN	PICDISK.IMG
PIC_DECRU		INCBIN	PICDECRU.IMG
ARC_LANCE		INCBIN	ARCLANCE.IMG
ARC_NORM		INCBIN	ARCNORM.IMG
PLEUR1		INCBIN	PLEUR1.IMG
PLEUR2		INCBIN	PLEUR2.IMG
PLEUR3		INCBIN	PLEUR3.IMG
SOUFFLE1		INCBIN	SOUFFLE1.IMG
SOUFFLE2		INCBIN	SOUFFLE2.IMG
FLECHE		INCBIN	FLECHE.BIN
HEYMAN		INCBIN	HEYMAN.IMG
HURRYUP		INCBIN	HURRYUP.IMG
ARCHER1		INCBIN	ARCHER1.IMG
ARCHER2		INCBIN	ARCHER2.IMG
ARCHER3		INCBIN	ARCHER3.IMG
ARCHER4		INCBIN	ARCHER4.IMG
ARCHER5		INCBIN	ARCHER5.IMG

		EVEN
TAB_PUT:
M	SET	0
	REPT	20
	DC.L	M
          DC.L  FLECHE+0
	DC.L	M
          DC.L  FLECHE+322
	DC.L	M
          DC.L  FLECHE+692
	DC.L	M
          DC.L  FLECHE+1062
	DC.L	M
          DC.L  FLECHE+1432
	DC.L	M
          DC.L  FLECHE+1802
	DC.L	M
          DC.L  FLECHE+2172
	DC.L	M
          DC.L  FLECHE+2542
	DC.L	M
          DC.L  FLECHE+2912
	DC.L	M
          DC.L  FLECHE+3282
	DC.L	M
          DC.L  FLECHE+3652
	DC.L	M
          DC.L  FLECHE+3998
	DC.L	M
          DC.L  FLECHE+4350
	DC.L	M
          DC.L  FLECHE+4808
	DC.L	M
          DC.L  FLECHE+5394
	DC.L	M
          DC.L  FLECHE+5920
M	SET	M+8
	ENDR

ADDFOND		DC.L	0
FOND		DS.L	70
STE		DC.W	1		* 0 = STF   1 = STE
MEGA		DC.W	1		* 0 = 512   1 = 1 MEGA
BOOT		DS.B	512		* BOOT SECTEUR
TWODRIVE	DC.W	2		* 1 = OUI  2 = NON
CURENTDRIVE	DC.W	2               * DRIVE ACTUEL (2=A , 4=B)
DEJA_PASSE	DC.W	0		* SI = 1 ALORS ON A DEJA TOUT PREPARE
ETAT		DC.W	0		* 0 = RIEN
					* 1 = LOADING
					* 2 = DECRUNCHING
s120	dc.l 0
s70	dc.l 0
sa21	dc.l 0
sa1b	dc.l 0
sa07	dc.l 0
sa13	dc.l 0
sa09	dc.l 0
 
NUMERO		DC.W	1		* NUMERO DE LA DEMO CHOISI
					* dans ce cas 0 = disk1
					*             1 = disk2
					* cela me sert pour mes essais
					* (NUMERO , TABLEAU)

*		1 er SECTEUR,NOMBRE DE SECTEURS,DRIVE,FACE

TABLEAU		DC.W	11,100,2,0		* DEMO 1
		DC.W	11,100,4,0		* DEMO 2  ETC

RAST1		DC.W	$700,$700,$701,$701,$702,$702,$703,$703,$704,$704
		DC.W	$705,$705,$706,$706,$707,$707,$607,$607,$507,$507
		DC.W	$407,$407,$307,$307,$207,$207,$107,$107
		DC.W	7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		DC.W	$10,$10,$20,$20,$30,$30,$40,$40,$50,$50,$60,$60,$70,$70
		DS.W	20
RAST2		DC.W	$F00,$F00,$F08,$F08,$F01,$F01,$F09,$F09,$F02,$F02
		DC.W	$F0A,$F0A,$F03,$F03,$F0B,$F0B,$F04,$F04,$F0C,$F0C
		DC.W	$F05,$F05,$F0D,$F0D,$F06,$F06,$F0E,$F0E,$F07,$F07
		DC.W	$F0F,$F0F,$70F,$70F,$E0F,$E0F,$60F,$60F,$D0F,$D0F
		DC.W	$50F,$50F,$C0F,$C0F,$40F,$40F,$B0F,$B0F,$30F,$30F
		DC.W	$A0F,$A0F,$20F,$20F,$90F,$90F,$10F,$10F
		DC.W	$F,$F,7,7,$E,$E,6,6,$D,$D,5,5,$C,$C,4,4,$B,$B,3,3,$A,$A,2,2,9,9,1
		DC.W	$80,$80,$10,$10,$90,$90,$20,$20,$A0,$A0,$30,$30
		DC.W	$B0,$B0,$40,$40,$C0,$C0
PALETTE		dc.w	$0000,$0020,$0131,$0242,$0253,$0364,$0555,$0200
		dc.w	$0322,$0433,$0544,$0655,$0766,$0660,$0333,$0000
								   * $0444
IMAGE		INCBIN	D4LOAD.IMG
		DS.L	64
__NB_SAMPLES	equ 8
Module	
	incbin 	short.mod	The Module Itself
ModuleEnd	
	ds 	512*__NB_SAMPLES	Free space for buffers in between samples
ReplayCode	
	incbin 	cyber.b		The ReplayCode
VariableOffset	equ ReplayCode+28	Pointer to variable basepage
SEC	EQU	*+44*1024