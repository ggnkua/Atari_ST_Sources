;  SIRIUS / MADTRIS 
; YANN GERVAIS 
; 161 TER RUE DE BAYEUX
; 14000 CAEN
;
;	OU BAL MADTRIS SUR R-TEL
;
;
;		UN TETRIS VU PAR LES JOYEUX LOOPHOCKS
;
;                    **********************
;			IDEE PAR PAT CASH  
;			 CODE PAR SIRIUS    
;		      INTRO PIC BY DEGRAFF
;                    **********************
;
;
;		--> VERSION FALCON 030 
;        
;	le source ayant ete fini dans la plus grande precipitation
;	il est tres possible qu'il y ait 1 ou 2 bugs qui aient persistes
;	De plus les commentaires ne se trouvent que dans les proc
;	les plus importantes, certaines de ces proc sont tres mal
;	codes et meriteraient une bonne reecriture ainsi qu'une
;	bonne optimisation..
;
;	De plus bien que ce soit une version FALCON 030 ne vous
;	attendez pas a trouver des instructions specifiques au 030.
;	J' ai juste adapte un ancien code pour me familiariser avec
;	ma nouvelle machine.
;
;	mais j'espere que vous passerez quelques bonnes heures dessus...
;				BON JEU...

		
NB_DEPTT	EQU	8
FINALE		EQU	1

	BRA	BEGIN
	
	DC.B	' what are you doing here ??? '
	DC.B	' The source is FREE so just write me ...'
	DC.B	' My address is in the help part  '
BEGIN:	
	CLR.L	-(SP)		
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,SAVE_SSP

;************* on verif que le fichier avec les highscores existe
	move.w	#1,-(sp)	; fsfirst
	pea	HIGHTYPE
	move.w	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	beq	OK_FOUND	; oui !!
NOT_FOUND:	
	lea	HIGH_TAB0,A0	; non !!
	lea	HIGH_TAB,A1	; alors on met la table de highscore
	MOVE.W	#205,D0		; par d‚faut
FILL_HIGH:
	MOVE.L	(A0)+,(A1)+
	DBRA	D0,FILL_HIGH
	bra	LOADED
	
	
OK_FOUND:	
	move.w	#0,-(sp)	; ouverture fichier high
	move.l	#HIGHTYPE,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	add.l	#12,sp
	tst.w	d0
	bmi	NOT_FOUND

	move.w	d0,d1		; sauve handle
	
	pea	HIGH_TAB	; on lit la table 
	move.l	#822,-(sp)
	move.w	d1,-(sp)
	move.w	#$3f,-(sp)	; et si jamais il se produit un
	trap	#1		; pb durant la lecture alors on fait
	add.l	#12,sp		; comme si le fichier n'existait pas
	tst.w	d0
	bmi	NOT_FOUND
	
	move.w	d1,-(sp)	; on ferme le fichier
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	bmi	NOT_FOUND

LOADED:				; operation chargement highscores finie....
	
	MOVE.B	$484,SAVE_CLAV	; sauvegarde vecteur clavier
	CLR.B	$484

	IFEQ	FINALE
	MOVE.L	#0,-(SP)	; deconnecte souris
	MOVE.L	#0,-(SP)
	CLR.L	-(SP)
	TRAP	#14
	ADD.L	#12,SP
	ENDC
	
	PEA	SAVE_PAL	; sauve pal
	MOVE.W	#16,-(SP)
	MOVE.W	#0,-(SP)
	MOVE.W	#94,-(SP)
	TRAP	#14
	ADD.L	#10,SP


	;  4 bits par pixel 40 col TV PAL oversc off
	;  non entrelac‚
	MOVE.W	#%0000000000100010,-(SP)	; Vsetmode
	MOVE.W	#88,-(SP)			; specif falcon
	TRAP	#14
	ADDQ.L	#4,SP
	MOVE.W	D0,SAVE_MODE_VIDEO


	MOVE.L	#DEG_0,D0	; calcul des adresses des 4 ecrans
	AND.L	#$FFFFFF00,D0
	ADD.L	#256,D0
	MOVE.L	D0,ECRAN1
	
	MOVE.L	#DEG_90,D1
	AND.L	#$FFFFFF00,D1
	ADD.L	#256,D1
	MOVE.L	D1,ECRAN2
	
	MOVE.L	#DEG_180,D2
	AND.L	#$FFFFFF00,D2
	ADD.L	#256,D2
	MOVE.L	D2,ECRAN3
	
	MOVE.L	#DEG_270,D3
	AND.L	#$FFFFFF00,D3
	ADD.L	#256,D3
	MOVE.L	D3,ECRAN4
	
	LEA	DEG_0,A0
	MOVE.W	#(48256/4)-1,D7
PREP_ECR:	CLR.L	(A0)+
	DBRA	D7,PREP_ECR
	
	LEA	ECRAN1,A0	 ; on vient ici et cette routine
	LEA	OLD_SCREEN,A1
	MOVE.B	$FFFFF8201,1(A1)
	MOVE.B	1(A0),$FFFFF8201 ; donne la nouvelle adresse 
	MOVE.B	$FFFFF8203,2(A1)
	MOVE.B	2(A0),$FFFFF8203 ; au shifter
	MOVE.L	ECRAN1,ADR_ECR   ; tout en sauvegardant l'anc adr ecr

	MOVE.B	#2,$FF820A	; 50 hz

	LEA	SYLVAIN,A0	; depack img de presentation
	MOVE.L	ECRAN2,A1
	JSR	DEPACK
	
	MOVE.L	ECRAN2,A0	; met la palette
	ADD.L	#2,A0
	JSR	MET_PALETTE
	
	MOVE.L	ECRAN1,A1	; puis on l'affiche dans l'ecr en cours
	MOVE.L	ECRAN2,A0
	ADD.L	#34,A0
	MOVE.W	#7999,D7
FIRST_PIC:	
	MOVE.L	(A0)+,(A1)+
	DBRA	D7,FIRST_PIC
	
	JSR	WAIT_SPACE

;*****************************************************
;*****************************************************
;*****************************************************
FAIT_CHOIX:

	LEA	PAGE1+2,A0	; page de choix
	JSR	MET_PALETTE
	
	LEA	PAGE1+34,A0
	MOVE.L	ADR_ECR,A1
	MOVE.W	#7999,D7
AFPR:	MOVE.L	(A0)+,(A1)+
	DBRA	D7,AFPR
	
	MOVE.W	#0,HAUT
	
	JSR	INITPRES	; init presentation
	JSR	AFLECHE		; affiche fleche
	
	JSR	TOUCHE_FLECHE	; gere fleche

	MOVE.L	ADR_ECR,A1	; effacement ecran
	MOVE.L	ECRAN1,A2
	MOVE.W	#3999,D7
CLSPR:	
	CLR.L	(A1)+
	CLR.L	(A1)+
	CLR.L	(A1)+
	CLR.L	(A1)+
	DBRA	D7,CLSPR
	
	LEA	PALETTE,A0	; mise en place palette pour le jeu
	JSR	MET_PALETTE

;****************************************************
;****************************************************
;****************************************************
	
	CLR.W	VITESSE
	
	MOVE.W	#0,SCORE
	JSR	INIT_VEC	; mise en place des diff‚rents vecteurs

	MOVE.L	#TAB_MES_DEPTT,SAVE_TMD
	
	
;************************************
	TST.W	MODE_M		; mode normal ou training ?
	BNE	MD
					; on demarre le jeu normalement
	MOVE.L	SAVE_TMD,A0
	MOVE.L	(A0)+,SAVE_MES
	MOVE.L	A0,SAVE_TMD
	
	MOVE.W	#0,FINI_STAGE
	JSR	PRESENTATION		; efface l'ecr et aff le txt
	MOVE.W	#0,FINI_STAGE
	
	MOVE.L	#DEPTT1,SAVE_DEPTT
	MOVE.L	#MES_DEPTT1,SAVE_MES
	
	MOVE.L	#TAB_DEPTT,SAVE_DEPTT2
	MOVE.W	#NB_DEPTT,DEPTT
	MOVE.W	#0,STAGE
	
	MOVE.W	#0,FINI_STAGE
	CLR.W	OUT_OF_TIME
	
	CLR.W	JOUAB			
	CLR.W	JOUAB1
	
	JSR	PRESENTATION		; efface l'ecr et aff le txt
	MOVE.W	#0,FINI_STAGE

	BRA	MD2
MD:
	MOVE.L	#TRAINING,SAVE_DEPTT	;  on choisit le stage training
	MOVE.L	#TRAIN_MES,SAVE_MES
	MOVE.L	#TAB_DEPTT,SAVE_DEPTT2
	MOVE.W	#NB_DEPTT+1,DEPTT
	MOVE.W	#0,STAGE
	MOVE.W	#0,FINI_STAGE
MD2:

RECOMMENCE:
	MOVE.W	STAGE,D0	; on teste si l'on vient
	ADDQ.W	#1,D0		; de finir un department ou un stage	
	CMP.W	#4,D0
	BNE	NO_NEW_DEPTT

	SUBQ.W	#1,DEPTT	; on teste si c'etait le dernier stage
	BEQ	GAME_END	; oui !!! fin du jeu (logique non ??)
	
	MOVE.L	SAVE_DEPTT2,A0
	MOVE.L	(A0)+,SAVE_DEPTT
	MOVE.L	A0,SAVE_DEPTT2
	
	MOVE.L	SAVE_TMD,A0
	MOVE.L	(A0)+,SAVE_MES
	MOVE.L	A0,SAVE_TMD
	
	JSR	PRESENTATION		; efface l'ecr et aff le txt
	MOVE.W	#0,FINI_STAGE

	MOVE.W	#1,D0

NO_NEW_DEPTT:

	MOVE.W	D0,STAGE		; on met en place les param
	MOVE.L	SAVE_DEPTT,A0		; pour le stage
	LEA	SAVE_MES,A1
	MOVE.L	(A0)+,(A1)+
	JSR	PRESENTATION		; efface l'ecr et aff le txt
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.W	(A0)+,(A1)+
	MOVE.L	A0,SAVE_DEPTT

	CLR.W	OUT_OF_TIME
	MOVE.W	GHOST_PAS,GHOST_CMP

	TST.W	QUELLE_PIECE
	BNE	JEUP2
	
JEUP1:
	MOVE.L	#PIECES,GFX_EN_C
	MOVE.L	#DATA_PIECE,JEU_P_EN_C
	MOVE.L	#X_MAX,XM_EN_C
	MOVE.L	#Y_MAX,YM_EN_C
	MOVE.L	#ROTATION,ROT_EN_C
	BRA	JEUP3
JEUP2:
	MOVE.L	#PIECES2,GFX_EN_C
	MOVE.L	#DATA_PIECE2,JEU_P_EN_C
	MOVE.L	#X_MAX2,XM_EN_C
	MOVE.L	#Y_MAX2,YM_EN_C
	MOVE.L	#ROTATION2,ROT_EN_C
JEUP3:

REC2:
	MOVE.W	#0,FINI_STAGE

	TST.W	SOUND_M
	BNE	NO_SOUND

	JSR	INIT_SOUND

NO_SOUND:
	JSR     INIT_ALL	
	
	MOVE.W	#50,VBL_TIME
	
	JSR 	NOUVELLE_PIECE	; on appelle 2 fois nouvelle_piece
	JSR 	NOUVELLE_PIECE  ; pour avoir la piece en cours et 
	JSR	AF_PIECE
	JSR	AFF_NEXT	; la suivante.
	
	MOVE.W	PAS_DEP_PIE,WAIT
	MOVE.W	#0,TPS_DEP
	MOVE.W	PAS_DEP_TOU,WAIT_TOU
	MOVE.W	#0,WAIT_CLAV
	
	MOVE.W	SCORE,D7	; affichage score de d‚part
	JSR	CONVERSION
	JSR	AFFSCORE

	MOVE.W	NB_LIG,D7	; nb de lig d‚ja complet‚es
	JSR	CONVERSION
	JSR	AFFNBLIG

	MOVE.W	COMPT_TIME,D7	; et tps donn‚ pour faire ce stage
	JSR	CONVERSION
	JSR	AFFTIME	
VSYNC:	
	
	TST.W	G_O		; test si game over
	BNE	FINISH
	
	JSR	WAIT_SYNC	; attente de la vbl
	
	TST.W	CHGT_ECR	; y a t-il eu un chgt d'ecran
	BEQ	VSYNC1		; ( par rotation du carre central )

	CMP.W	#1,WAIT		; on ne reaf que si GERE_PIECE
	BEQ	VSYNC1_1	; n'est pas exec dans cette vbl
	
	CLR.W	CHGT_ECR
	
	LEA	INSTRUC,A0	; si l'ecran vient d'etre changer
	MOVE.W	X,(A0)		; on reaf la piece dans cet ecran 
	MOVE.W	Y,2(A0)		; sinon cela provoque un scintillement
	MOVE.W	P_EN_C,4(A0)	; car il faut attendre plusieurs vbl
	MOVE.W	R_EN_C,6(A0)	; pour qu'elle soit reaf avec GERE_PIECE
	MOVE.W	#1,8(A0) 	
	MOVE.L	ADR_ECR,10(A0)
	MOVE.W	VITESSE,14(A0)
	BSR	AFF_PIECE

VSYNC1:
	SUB.W	#1,WAIT	; pour reguler la vitesse d'arrivee  des pieces
	BNE	VSYNC2	; sinon c'est injouable !!

VSYNC1_1:	
	MOVE.W	PAS_DEP_PIE,WAIT

	JSR	GERE_PIECE	; rien a rajouter !
	
	TST.W	FINI_STAGE
	BNE	RECOMMENCE
VSYNC2:	

	JSR	GERE_TOUCHE	;    idem
	
	CMP.B	#$01,$FFFC02	;  s'il y a un esc de presse alors on s'casse
	BNE	VSYNC

VSYNC3:	CMP.B	#$01+$80,$FFFC02
	BNE	VSYNC3

;*************************************
FINISH:		
	CLR.W	TIME		; aie aie aie GAME OVER !!!
	CLR.W	G_O	
	MOVE.W	#1,FINI_STAGE

	TST.W	OUT_OF_TIME		; si on perd a cause du tps
	BEQ	NO_OUT			; affichage du message TIME OUT
	
	MOVE.L	#TIME_OUT_MES,SAVE_MES
	JSR	PRESENTATION
NO_OUT:	CLR.W	OUT_OF_TIME


	JSR	WAIT_SYNC
	MOVE.L	ADR_ECR,A0
	MOVE.W	#2559,D7
CLF:	
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	DBRA	D7,CLF

	JSR	WAIT_SYNC
	JSR	CLEAR_PALETTE
	
	LEA	OVER_PIC,A0	
	MOVE.L	ADR_ECR,A1
	ADD.L	#25*160,A1
	JSR	DEPACK
	
	JSR	WAIT_SYNC
	MOVE.L	ADR_ECR,A0
	ADD.L	#32000+(25*160),A0
	JSR	MET_PALETTE
	REPT	8
	CLR.L	(A0)+
	ENDR

	MOVE.W	SCORE,D7
	JSR	CONVERSION
	
	LEA	YOUR_SCORE,A0
	ADD.L	#22,A0
	LEA	NOMBRE,A1
	
	MOVE.W	#4,D7
Y_S:	
	
	MOVE.W	(A1)+,D6
	ADD.W	#9,D6
Y_S3:	MOVE.W	D6,(A0)+
	DBRA	D7,Y_S

	
	MOVE.L	ADR_ECR,A1
	ADD.L	#3*160+16,A1
	LEA	YOUR_SCORE,A0
	
	MOVE.W	#16,D7
AFF_Y_S:
	LEA	THALION,A2
	ADD.L	#32,A2
	MOVE.W	(A0)+,D6
	MULU.W	#8*16,D6
	ADD.L	D6,A2
	
	MOVE.L	A1,A3
	
	REPT	16
	MOVE.L	(A2)+,(A1)
	MOVE.L	(A2)+,4(A1)
	ADD.L	#160,A1
	ENDR
	
	LEA	8(A3),A1
	DBRA	D7,AFF_Y_S
	
	LEA	GAMOVER,A0
	MOVE.L	ADR_ECR,A1
	ADD.L	#230*160+48,A1
	
	MOVE.W	#8,D7
AFF_G_O:
	LEA	THALION,A2
	ADD.L	#32,A2
	MOVE.W	(A0)+,D6
	MULU.W	#8*16,D6
	ADD.L	D6,A2
	
	MOVE.L	A1,A3
	
	REPT	16
	MOVE.L	(A2)+,(A1)
	MOVE.L	(A2)+,4(A1)
	ADD.L	#160,A1
	ENDR
	
	LEA	8(A3),A1
	DBRA	D7,AFF_G_O

FINISH0:CMPI.B	#$39,$FFFC02		; espace presse
	BNE	FINISH0	

FINISH01:CMPI.B	#$39+$80,$FFFC02	; espace relache
	BNE	FINISH01	

FINISH1:
	JSR	WAIT_SYNC
	LEA	$FF8240,A0
	REPT	8
	CLR.L	(A0)+
	ENDR
				; l… c'est fini	!
	JSR	REMET_VEC	; remise en place des differents vecteurs

;;;
	MOVE.W	#$2700,SR

	LEA	SAUVE_MFP,A0
	MOVE.B	$FFFFFA07,(A0)+
	MOVE.B	$FFFFFA09,(A0)+
	MOVE.B	$FFFFFA0B,(A0)+
	MOVE.B	$FFFFFA0D,(A0)+
	MOVE.B	$FFFFFA13,(A0)+
	MOVE.B	$FFFFFA15,(A0)+
	MOVE.B	$FFFFFA1B,(A0)+
	MOVE.B	$FFFFFA21,(A0)+
	
	MOVE.L	288,SAVE_TIMB
	MOVE.L	#TIMER_B,288
	
	MOVE.B	#%00000000,$FFFFFA09	; IERB	(it enable)
	MOVE.B	#%00100001,$FFFFFA07	; IERA  (it enable)
	
	MOVE.B	#%00000000,$FFFFFA15	; IMRB
	MOVE.B	#%00100001,$FFFFFA13	; IMRA  (mask)
	
	BCLR	#3,$FFFFFA17		; VR
	
	MOVE.B	#%00001000,$FFFFFA1B	; TBCR  (registre de ctrl)
	MOVE.B	#1,$FFFFFA21		; TBDR	(registre de donnees)
	
	MOVE.L	#RAST_EC,EC_RAST
	MOVE.L	EC_RAST,POINT_RAST
	
	MOVE.L	$70,SAVE_RASTVBL
	MOVE.L	#RAST_VBL,$70
	
	MOVE.W	#$2300,SR

	LEA	PAGE1+2,A0
	JSR	MET_PALETTE

	TST.W	MODE_M
	BNE	JUST_AFF
	
	JSR	SAISIE_HIGH		; on regarde s'il y a
					; du highscore dans l'air
JUST_AFF:
	MOVE.L	#RAST_EC2,EC_RAST
	LEA	HIGH_TAB,A1 		
	JSR	HELP			; affichage table highscores

	LEA	HIGHLOGO,A0
	MOVE.L	ADR_ECR,A1
	ADD.L	#360,A1
	MOVE.W	#13,D7
AFFHIGH2:
	REPT	20	
	MOVE.L	(A0)+,(A1)+
	ENDR
	ADD.L	#80,A1
	DBRA	D7,AFFHIGH2

	JSR	WAIT_SPACE	

	MOVE.W	#$2700,SR
	
	MOVE.L	SAVE_RASTVBL,$70
	MOVE.L	SAVE_TIMB,288
	
	LEA	SAUVE_MFP,A0
	MOVE.B	(A0)+,$FFFFFA07
	MOVE.B	(A0)+,$FFFFFA09
	MOVE.B	(A0)+,$FFFFFA0B
	MOVE.B	(A0)+,$FFFFFA0D
	MOVE.B	(A0)+,$FFFFFA13
	MOVE.B	(A0)+,$FFFFFA15
	MOVE.B	(A0)+,$FFFFFA1B
	MOVE.B	(A0)+,$FFFFFA21
	
	MOVE.W	#$2300,SR

	BRA	FAIT_CHOIX
FINISH2:
	; on va maintenant et avant de partir essayer de sauvegarder
	; les scores...

	
	
	TST.W	FLAG_SAVHIGH	; a la condition que la table
	BEQ	NO_SAVE		; ait ete modifie par un nouveau
				; score...
	MOVE.W	#0,D7		
RETRY:			
	move.w	#0,-(sp)	; creation fichier high
	move.l	#HIGHTYPE,-(sp) 
	move.w	#$3C,-(sp)	
	trap	#1
	add.l	#12,sp
	tst.w	d0
	bmi	ERR_SAVE		; s'il se produit un erreur
		; on annule la sauvegarde et puis c'est tout...

	move.w	d0,d1		; sauve handle
	
	pea	HIGH_TAB
	move.l	#822,-(sp)
	move.w	d1,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	tst.w	d0
	bmi	ERR_SAVE

	move.w	d1,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	bmi	ERR_SAVE
	BRA	NO_SAVE
ERR_SAVE:
	TST.W	D7		; on teste d7
	BNE	NO_SAVE		; si =0  -> on affiche
				; si =1 on est deja venu ici alors
	
	MOVE.L	#$FFFF00FF,$FF9804
	LEA	ERR_DISK,A1	; on s'en va
	JSR	HELP
	
	JSR	WAIT_SPACE
	MOVE.W	#1,D7
	BRA	RETRY

NO_SAVE:		;************************ sauvegarde finie	
	IFNE	FINALE	; est ce la version finale du jeu
	
	MOVE.B	SAVE_CLAV,$484	; le vecteur clavier
	
	;MOVE.B	#1,$FF8260
	MOVE.W	SAVE_MODE_VIDEO,-(SP)	; Vsetmode
	MOVE.W	#88,-(SP)
	TRAP	#14
	ADDQ.L	#4,SP

	
	PEA	SAVE_PAL
	MOVE.W	#16,-(SP)
	MOVE.W	#0,-(SP)
	MOVE.W	#93,-(SP)
	TRAP	#14
	ADD.L	#10,SP
	
	MOVE.L	SAVE_SSP,-(SP)	; on repasse en utilisateur
	MOVE.W	#$20,-(SP)	
	TRAP	#1
	ADDQ.L	#6,SP
	
	MOVE.W	#-1,-(SP)	; on retab l'ecran de base
	MOVE.L	OLD_SCREEN,-(SP)
	MOVE.L	OLD_SCREEN,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.L	#12,SP
	
	CLR.L	-(SP)		;   ADIOS !!
	TRAP	#1
	ENDC
	
	IFEQ	FINALE		; la version finale du jeu
BOUCLE:	BRA	BOUCLE		; boucle sur l'image de fin
	ENDC


GAMOVER:	DC.W	26,20,32,24,3
		DC.W	34,41,24,37
YOUR_SCORE:	DC.W	44,34,40,37,50
		DC.W	38,22,34,37,24,19
		DC.W	0,0,0,0,0
		
		
GAME_END:	
	MOVE.L	#MES13,SAVE_MES
	JSR	PRESENTATION

	JSR	CLEAR_PALETTE
	LEA	YAHA1,A0
	MOVE.L	ADR_ECR,A1

	MOVE.W	#499,D7
C_G_E:	CLR.L	(A1)+
	CLR.L	(A1)+
	DBRA	D7,C_G_E
	
	JSR	DEPACK

	MOVE.L	ADR_ECR,A0
	ADD.L	#32000+(25*160),A0
	JSR	MET_PALETTE
	REPT	8
	CLR.L	(A0)+
	ENDR
	
	MOVE.L	ADR_ECR,A1
	ADD.L	#32000+32+(25*160),A1
	MOVE.W	#519,D7
C_G_E2:	CLR.L	(A1)+
	CLR.L	(A1)+
	DBRA	D7,C_G_E2
	
	JSR	WAIT_SPACE
	
	BRA	FINISH1
	
;***********************************************
;***********************************************

WAIT_SPACE:	CMPI.B	#$39,$FFFFFC02	; espace presse
		BNE	WAIT_SPACE
		
WAIT_SPACE2:	CMPI.B	#$39+$80,$FFFFFC02 ; espace relache
		BNE	WAIT_SPACE2
		
		RTS
;********************************
RAST_VBL:
	movem.l	d0-d7/a0-a6,-(sp)
	
	MOVE.L	EC_RAST,POINT_RAST

	CLR.B 	$FFFFFA1B.W		; STOP TIMER
	MOVE.B #1,$FFFFFA21		; 199 DANS REG DE DONNEES
	MOVE.B #8,$FFFFFA1B.W		; MODE EVENT COUNT
	movem.l	(sp)+,d0-d7/a0-a6
	rte

TIMER_B:
	REPT	25	; si on ne met pas ces nop il y a 
	NOP		; une perturbation sur le cote droit de l'ecran
	ENDR		; de toute facon c'est reculer pour mieux sauter
	
	MOVE.L	A0,-(SP)
	MOVE.L	POINT_RAST,A0
	MOVE.L	(A0)+,$FF9800
	MOVE.L	A0,POINT_RAST
	MOVE.L	(SP)+,A0
	
	; car la perturbation n'est que repouss‚e sur la droite	
	BCLR #0,$FFFFFA0F.W	; elle existe toujours...
	RTE				

;*******************************************************
; GESTION TABLE DES HIGHSCORES
;*******************************************************   
SAISIE_HIGH:	MOVEM.L	D0-D7/A0-A6,-(SP)
				
	MOVE.W	SCORE,D7	
	MOVE.W	#10,D2		; lig ou va se trouver le high
	LEA	H_S,A0
	
	MOVE.W	(A0),D5
	CMP.W	D7,D5
	BHI	NO_HIGH
	
	MOVE.W	#1,FLAG_SAVHIGH	; il faudra sauver les scores
Q_H:				; a la fin de la partie
	MOVE.W	(A0),D5
	CMP.W	D7,D5
	BHI	Q_H2
	SUBQ.W	#1,D2
	BEQ	Q_H2
	ADD.W	#2,A0
	BRA	Q_H
Q_H2:	
;***********************************	
	MOVE.W	#15,D5	;X
	MOVE.W	#11,D6	;Y
	
	LEA	HIGH_NAME,A6
	MOVE.L	A6,A5
	REPT	25		; on remplit d'espace
	MOVE.W	#26,(A6)+
	ENDR
	MOVE.L	A5,A6

	LEA	PRES_HIGH,A1
	JSR	HELP
	
	LEA	HIGHLOGO,A0
	MOVE.L	ADR_ECR,A1
	ADD.L	#360,A1
	MOVE.W	#13,D7
AFFHIGH:
	REPT	20	
	MOVE.L	(A0)+,(A1)+
	ENDR
	ADD.L	#80,A1
	DBRA	D7,AFFHIGH

SAISIE:	
	LEA	TAB_CORRESP,A0	; tab corresp est une table
	CLR.L	D0		; qui fait correspondre aux codes
	CLR.L	D1		; clavier le num du carac dans la fonte 
	MOVE.B	$FFFC02,D0	; ce num sera mis dans d1
	MOVE.B	0(A0,D0.W),D1
	
	CMP.B	#$1C,D0		; RETURN POUR SORTIR
	BEQ	SAISIE2	

	CMP.B	#$0E,D0		; BACKSPACE ??
	BNE	SAISIE0
	
	CMP.W	#15,D5		; backspace alors que l'on est
	BEQ	SAISIE		; deja tout au debut --> annul‚
	
	SUB.L	#2,A6
	MOVE.W	#26,(A6)	; on met un espace et on recule
	SUBQ.W	#1,D5
	
	MOVE.W	#26,D7
	JSR	AFF_CAR
	
STOP_BACK:
	CMP.B	#$8E,$FFFFFC02	; attend que la touche backspace
	BNE	STOP_BACK	; soir relach‚e
	
	BRA	SAISIE
SAISIE0:
	CMP.W	#40,D5	; maximum X ???
	BEQ	SAISIE	; oui retour a la case d‚part
	
	TST.B	D1
	BEQ	SAISIE	; si d1 est different de zero
	
	SUBQ.W	#1,D1	; on lui enleve 1 ( car a est a la position 0 )
			; voir prg annexes...
			
	MOVE.W	D1,D7	; affichage et sauvegarde du caractere
	MOVE.W	D1,(A6)+
	JSR	AFF_CAR
	ADDQ.W	#1,D5
	
	ADD.B	#$80,D0
SAISIE1:	
	MOVE.B	$FFFC02,D1 ; attente du relachement de la touche
	CMP.B	D0,D1
	BNE	SAISIE1
	
	BRA	SAISIE
;***************************** on vient d'appuyer sur RETURN	
SAISIE2:   	
	LEA	HIGH_TAB,A5
	
	CMP.W	#9,D2
	BNE	SAISIE3
	
	LEA	H_S-82,A5
	LEA	H_S,A3
	BRA	SAISIE4	
SAISIE3:
	MOVE.W	#8,D3
	SUB.W	D2,D3
	
	MULU.W	#80,D2	; on regarde o— le texte se trouvera
	ADD.W	D2,A5	; dans la table
	LEA	80(A5),A6
	
	LEA	H_S-82,A4
	LEA	H_S,A3
CASE_SCORE:			; on descend tous les scores
	REPT	40		; moins bon de 1
	MOVE.W	-(A4),80(A4)
	ENDR
	MOVE.W	2(A3),(A3)
	ADDQ.L	#2,A3
	DBRA	D3,CASE_SCORE	

SAISIE4:
	MOVE.W	SCORE,(A3)
	LEA	HIGH_NAME,A6	; puis on place notre score
	
	CLR.L	D3
	REPT	25
	OR.W	(A6)+,D3
	ENDR
	LEA	HIGH_NAME,A6
	CMP.W	#26,D3
	BNE	SAISIE5
	LEA	NONAME,A6
SAISIE5:
	MOVE.W	#26,(A5)+	; l'espace de depart
	REPT	25
	MOVE.W	(A6)+,(A5)+
	ENDR

	MOVE.W	SCORE,D7	; on convertit le score en
	JSR	CONVERSION	; 1*1 5*10 3*100 ...
	
	LEA	NOMBRE,A6	; puis on prend les chiffres correspondant	

	ADD.L	#12,A5		; 12 carac + loin que le nom
	MOVE.W	#4,D6
CASE_SCORE2:
	CLR.L	D7
	MOVE.W	(A6)+,D7
	ADD.W	#34,D7
	CMP.W	#34,D7		; le 0 est place a la fin de la serie	
	BNE	CS2_2		; de chiffres --> si 0 on ajoute 10
	MOVE.W	#44,D7
CS2_2:
	MOVE.W	D7,(A5)+
	
	DBRA	D6,CASE_SCORE2	

	MOVE.W	#26,(A5)+
	MOVE.W	#$FF,(A5)+
	MOVE.W	#$FF,(A5)+
	
NO_HIGH:
  	MOVEM.L	(SP)+,D0-D7/A0-A6
   	RTS
;***********************************************
; AFFICHAGE D'UN CARACTERE
;***********************************************
AFF_CAR:	MOVEM.L	D0-D7/A0-A6,-(SP)
	
	MOVE.L	ADR_ECR,A0
	MULU.W	#8*160,D6
	ADD.L	D6,A0
	ADD.L	#160,A0
	
	CLR.L	D6
	BTST	#0,D5
	BEQ	AFF_PAIR
	MOVEQ	#1,D6
AFF_PAIR:	
	LSL.W	#2,D5
	AND.B	#%11111000,D5
	ADD.L	D5,A0
	ADD.L	D6,A0
	
	LEA	HELPFONTE,A1
	MULU.W	#8,D7
	ADD.L	D7,A1
	
	REPT	8
	MOVE.B	(A1)+,(A0)
	ADD.L	#160,A0
	ENDR
	
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

;******************************************************
;******************************************************
INIT_SOUND:
;	ici sont faites toutes les initialisations relatives
;	au son 8 bits mono 1 canal en 16.4khz sur le casque
;	les nouvelles fonctions xbios sont fabuleuses...
;	mais pour ce qui est de l'envoi des sons 
;	j'ai du faire les envois directement dans les
; 	registres DMA sinon ca plante...

; a part cela etant donne la possibilite d'ecouter DESKTRACKER pendant
; le jeu quand on fait les initialisations pour le son on est bien oblige 
; de l'arreter  -> il utilise le timer a d'ou l'obligation de couper 
; celui-ci. Si on ne le faisait pas, les sons seraient jou‚ mais 
; a la frequence utilis‚e par DESKTRACKER (12,25 ou 50khz).  

	move.w	#$2700,sr
	AND.B	#%11011111,$FFFFFA07	; STOP TIMER A
	AND.B	#%11011111,$FFFFFA13	
	move.w	#$2300,sr


	move.w	#1,-(sp)		; reset systeme sonore
	trap	#14
	addq.l	#2,sp

	move.w	#2,-(sp)		; 8 bits mono
	move.w	#132,-(sp)
	trap	#14
	addq.l	#4,sp

	move.w	#0,-(sp)		; 1 piste a jouer
	move.w	#0,-(sp)
	move.w	#133,-(sp)
	trap	#14
	add.l	#6,sp
	
	 ;fonction devconnect --> connecter source & dest dans la matrice...
	move.w	#4,-(sp)	; rejoue a 16.4 khz (enfin j'espere ...)
	clr.w	-(sp)		; utilise horloge interne (27.175mhz)
	move.w	#%1000,-(sp)	; sortie casque+ht parleur
	clr.w	-(sp)		; la source c'est le dma playback evidemment
	move.w	#139,-(sp)
	trap	#14
	add.l	#10,sp

	RTS

GO_DMA_SOUND:
;	routine qui s'occupe de rejouer un sample en dma a
; 	16.4 khz
	
	tst.w	SOUND_M		; on ne rejoue ce son que
	bne	FINI_DMA_S	; si l'on est en mode EFFECT

	move.l	d0,-(sp)
	
	move.b	#%00000000,$ff8901	; replay off
	
	move.l	12(sp),d0		; adresse de debut
	move.b	d0,$ff8907		; du sample
	lsr.l	#8,d0
	move.b	d0,$ff8905
	lsr.l	#8,d0
	move.b	d0,$ff8903

	move.l	8(sp),d0	; puis celle de fin
	move.b	d0,$ff8913
	lsr.l	#8,d0
	move.b	d0,$ff8911
	lsr.l	#8,d0
	move.b	d0,$ff890f
	
	move.b	#%00000001,$ff8901	; replay on --> c'est parti !!!

	move.l	(sp)+,d0
FINI_DMA_S:
	rts
	
CLEAR_PALETTE:	move.l	a0,-(sp)
	lea	$ff9800,a0
	rept	16
	clr.l	(a0)+
	endr
	move.l	(sp)+,a0
	rts

CONVERT_PAL:	movem.l	d0-d7/a0-a6,-(sp)
;		conversion de palette st f/e au format falcon	
;		a0 pointe sur la palette a convertir
;		a1 sur la conversion
	
		clr.l	d0
		clr.l	d1
		clr.l	d2
		clr.l	d3
		lea	CONVERTIT,a1
		move.w	#15,d7
CONVERT_P2
		move.w	(a0)+,d0
		and.w	#%011101110111,d0	; enleve les bits inutiles	
		move.w	d0,d1
		and.w	#%11100000000,d1
		lsr.w	#8,d1
		LSL.W	#5,D1
	
		move.w	d0,d2
		and.w	#%1110000,d2
		lsr.w	#4,d2
		LSL.W	#5,D2
		
		move.w	d0,d3
		and.w	#%111,d3
		LSL.W	#5,D3
		
		move.b	d1,(a1)+			
		move.b	d2,(a1)+			
		clr.b	(a1)+
		move.b	d3,(a1)+			
		dbra	d7,CONVERT_P2
		
		movem.l	(sp)+,d0-d7/a0-a6
		rts
;***************************************************************
VBL:	
	MOVE.W	#1,SYNC		; la vbl indique son depart en mettant 1
				; dans SYNC
	
VBL2_1:
	TST.W	TIME
	BEQ	VBL3

	SUBQ.W	#1,VBL_TIME	; pour decompter le tps
	BNE	VBL3	
	JSR	NEWTIME

	TST.W	FINI_STAGE
	BNE	VBL3
	
	MOVE.L	D7,-(SP)
	MOVE.W	COMPT_TIME,D7
	JSR	CONVERSION
	JSR	AFFTIME	
	MOVE.L	(SP)+,D7
VBL3:	
	RTE			
;***********************************************

WAIT_SYNC:			; on attend la synchro avec la vbl
WAIT_S:
	TST.W	SYNC
	BEQ	WAIT_S
	MOVE.W	#0,SYNC		; ok on est synchro !
	RTS
;**************************************************	
;**************************************************
;**************************************************
	
MET_PALETTE:	
	MOVEM.L	A0-A1,-(SP)
	JSR	CONVERT_PAL
	lea	CONVERTIT,A0
	LEA	$FF9800,A1
	REPT	16
	MOVE.L	(A0)+,(A1)+
	ENDR
	MOVEM.L	(SP)+,A0-A1
	RTS

TOUCHE_FLECHE:	MOVEM.L	D0-D7/A0-A6,-(SP)
	
FLE:	MOVE.B	$FFFFFC02,D0

	CMPI.B	#$50,D0
	BEQ	FLEBAS
	
	CMPI.B	#$48,D0
	BEQ	FLEHAUT
	
	CMPI.B	#$4B,D0
	BEQ	FLESIDE
	
	CMPI.B	#$4D,D0
	BEQ	FLESIDE
	
	
	CMPI.B	#$39,D0
	BEQ	FIN_TOUCHE_FLE
	
	CMPI.B	#$01,D0
	BEQ	AFF_CHIEN

	CMPI.B	#$62,D0
	BEQ	AFF_HELP
	
	BRA	FLE
AFF_HELP:	
	LEA	CHX_HLP,A1	; HELP EN QUELLE LANGUE ??
	JSR	HELP

TST_HELP:	
	MOVE.B	$FFFFFC02,D0
	
	CMPI.B	#$12,D0		; ANGLAIS
	BNE	TST_H1
	LEA	ETEXT,A1
	BRA	TST_H2
	
TST_H1:	CMPI.B	#$21,D0		; FRANCAIS 
	BNE	TST_HELP
	LEA	FTEXT,A1
TST_H2:

	JSR	HELP
	JSR	WAIT_SPACE
	
	
	LEA	PAGE1+2,A0
	JSR	MET_PALETTE
	
	ADD.L	#32,A0
	MOVE.L	ADR_ECR,A1
	MOVE.W	#7999,D7
AFHLP2:	MOVE.L	(A0)+,(A1)+
	DBRA	D7,AFHLP2
	
	JSR	INITPRES
	JSR	AFLECHE
	
	BRA	FLE
	
FLEBAS:
	CMPI.B	#$50+$80,$FFFFFC02
	BNE	FLEBAS
	
	JSR	EFLECHE	
	
	MOVE.W	HAUT,D1
	ADD.W	#1,D1
	CMP.W	#2,D1
	BMI	FLEB2
	MOVE.W	#1,D1
FLEB2:	MOVE.W	D1,HAUT
	
	JSR	AFLECHE
	BRA	FLE

FLEHAUT:
	CMPI.B	#$48+$80,$FFFFFC02
	BNE	FLEHAUT
	
	JSR	EFLECHE	
	
	MOVE.W	HAUT,D1
	SUB.W	#1,D1
	CMP.W	#$FFFF,D1
	BNE	FLEH2
	MOVE.W	#0,D1
FLEH2:	MOVE.W	D1,HAUT
	
	JSR	AFLECHE
	BRA	FLE
;***************************************
FLESIDE:	
	CLR.L	D1
	MOVE.B	D0,D1
	ADD.B	#$80,D1
FLES2:	MOVE.B	$FFFFFC02,D2
	CMP.B	D1,D2
	BNE	FLES2
	
	LEA	TABFLECHE,A0
	MOVE.W	HAUT,D1
	MULU.W	#4,D1
	ADD.L	D1,A0
	MOVE.L	(A0),-(SP)		
	RTS				
	
	BRA	FLE
AFF_CHIEN:	
	JSR	CLEAR_PALETTE
		
	LEA	YAHA2,A0
	MOVE.L	ADR_ECR,A1
	JSR	DEPACK
	
	MOVE.L	ADR_ECR,A0
	ADD.L	#32000,A0
	JSR	MET_PALETTE
AFF_CH:	
	JSR	WAIT_SPACE
	
	BRA	FINISH2
	
FIN_TOUCHE_FLE:	
	MOVE.B	$FFFFFC02,D0
	CMP.B	#$39+$80,D0
	BNE	FIN_TOUCHE_FLE
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS
;*******************************************	
AFLECHE:	
	MOVE.L	ADR_ECR,A0
	ADD.L	#56+160*120,A0
	MOVE.W	HAUT,D0
	MULU.W	#14*160,D0
	ADD.L	D0,A0
	LEA	PAGE2,A1
	
	REPT	10
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	ADD.L	#152,A0
	ENDR
	RTS

EFLECHE:	
	MOVE.L	ADR_ECR,A0
	ADD.L	#56+160*120,A0
	
	MOVE.W	HAUT,D0
	MULU.W	#14*160,D0
	ADD.L	D0,A0
	LEA	PAGE2+80,A1
	
	REPT	10
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	ADD.L	#152,A0
	ENDR
	RTS
	
INITPRES:	
	MOVE.L	ADR_ECR,A0
	ADD.L	#72+160*120,A0
	LEA	NEWPRES,A1
	MOVE.W	SOUND_M,D1
	MULU.W	#32*13,D1
	ADD.L	D1,A1
	
	MOVE.W	#12,D7
INP:
	REPT	2*4
	MOVE.L	(A1)+,(A0)+
	ENDR
	
	ADD.L	#128,A0
	DBRA	D7,INP
	
;***************************
	
	MOVE.L	ADR_ECR,A0
	ADD.L	#72+160*135,A0
	LEA	NEWPRES+(13*32*2),A1
	MOVE.W	MODE_M,D1
	MULU.W	#32*13,D1
	ADD.L	D1,A1
	
	
	MOVE.W	#12,D7
INP2:
	REPT	8
	MOVE.L	(A1)+,(A0)+
	ENDR
	ADD.L	#128,A0
	DBRA	D7,INP2
	
	RTS
	
;********************************************
SOUND:	
	CMPI.B	#$4D,D0
	BNE	S_3
	
	MOVE.W	SOUND_M,D1
	ADD.W	#1,D1
	CMP.W	#2,D1
	BNE	S_2
	MOVE.W	#1,D1
S_2:	MOVE.W	D1,SOUND_M
	BRA	S_A

S_3:
	CMPI.B	#$4B,D0
	BNE	S_END
	
	MOVE.W	SOUND_M,D1
	SUB.W	#1,D1
	CMP.W	#$FFFF,D1
	BNE	S_4
	MOVE.W	#0,D1
S_4:	MOVE.W	D1,SOUND_M

S_A:
	MOVE.L	ADR_ECR,A0
	ADD.L	#72+160*120,A0
	LEA	NEWPRES,A1
	MULU.W	#32*13,D1
	ADD.L	D1,A1
	
	MOVE.W	#12,D7
S_A2:
	REPT	8
	MOVE.L	(A1)+,(A0)+
	ENDR
	
	ADD.L	#128,A0
	DBRA	D7,S_A2


S_END:	BRA	FLE
;************************************************
MODE:	
	CMPI.B	#$4D,D0
	BNE	M_3
	
	MOVE.W	MODE_M,D1
	ADD.W	#1,D1
	CMP.W	#2,D1
	BNE	M_2
	MOVE.W	#1,D1
M_2:	MOVE.W	D1,MODE_M
	BRA	M_A

M_3:
	CMPI.B	#$4B,D0
	BNE	M_END
	
	MOVE.W	MODE_M,D1
	SUB.W	#1,D1
	CMP.W	#$FFFF,D1
	BNE	M_4
	MOVE.W	#0,D1
M_4:	MOVE.W	D1,MODE_M


M_A:
	MOVE.L	ADR_ECR,A0
	ADD.L	#72+160*135,A0
	LEA	NEWPRES+(2*13*32),A1
	MULU.W	#32*13,D1
	ADD.L	D1,A1
	
	MOVE.W	#12,D7
M_A2:
	REPT	8
	MOVE.L	(A1)+,(A0)+
	ENDR
	
	ADD.L	#128,A0
	DBRA	D7,M_A2
M_END:	BRA	FLE
;**********************************************	 
	
HELP:	MOVEM.L	D0-D7/A0-A6,-(SP)


	MOVE.L	ADR_ECR,A0
	MOVE.W	#1999,D7
HELP0:	REPT	8
	CLR.L	(A0)+
	ENDR
	DBRA	D7,HELP0

	LEA	HELPFONTE,A0
	MOVE.L	ADR_ECR,A2
	add.l	#25*160+6,a2
	MOVE.L	A2,A3
	MOVE.L	A2,A4
	
	CLR.L	D0
	CLR.L	D1
	MOVE.W	#1,D0
	MOVE.W	#7,D1

HELP1:	
	MOVE.L	A0,A5
	MOVE.W	(A1)+,D7
	
	CMP.W	#$888,D7
	BNE	HELP1_2

	JSR	WAIT_SPACE
	
	MOVE.L	ADR_ECR,A6
	MOVE.W	#1999,D7
CLR_HELP:	
	CLR.L	(A6)+
	CLR.L	(A6)+
	CLR.L	(A6)+
	CLR.L	(A6)+
	DBRA	D7,CLR_HELP
	
	MOVE.L	ADR_ECR,A2
	ADD.L	#6,A2
	MOVE.L	A2,A3
	MOVE.L	A2,A4
	
	BRA	HELP1
	
	
HELP1_2:CMP.W	#$FF,D7
	BNE	HELP2
	
	ADD.L	#8*160,A4
	
	MOVE.W	#1,D0
	MOVE.W	#7,D1

	MOVE.L	A4,A2
	MOVE.L	A4,A3
	BRA	HELP1
HELP2:
	CMP.W	#$999,D7
	BEQ	HELP4
HELP3:
	MULU.W	#8,D7
	ADD.L	D7,A5
	
	REPT	8
	MOVE.B	(A5)+,(A2)
	ADD.L	#160,A2
	ENDR
	
	ADD.L	D0,A3
	EXG	D0,D1
	MOVE.L	A3,A2
	
	BRA	HELP1

HELP4:	
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS
;*********************************************
INIT_VEC:	
	MOVE.W	#$2700,SR
	
	lea	$ff8282,a0	; sauvegarde des registres du fabuleux
	lea	SAVE_VIDEL,a1	; VIDEL	
	move.w	(a0)+,(a1)+	de	hht->hee
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	

	lea	$ff82a2,a0	de vft->vss
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	
	
	move.w	$ff820e,(a1)+	offset to next line
	move.w	$ff8210,(a1)+	VWRAP	(linewidth in words)
	move.w	$ff8266,(a1)+	SPSHIFT
	move.w	$ff82c2,(a1)+	VCO
	move.w	#57,$ff82a8	(VDB)
	move.w	#657,$ff82aa	(VDE)


	MOVE.L	$70.W,SAVE_VBL		; nouvelle vbl
	MOVE.L	#VBL,$70.W

	MOVE.W	#$2300,SR

FIN_INIT:	RTS
;********************************************
REMET_VEC:
	MOVE.W	#$2700,SR
	
	lea	$ff8282,a1
	lea	SAVE_VIDEL,a0
	move.w	(a0)+,(a1)+	de	hht->hee
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	

	lea	$ff82a2,a1	de vft->vss
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,(a1)+	
	move.w	(a0)+,$ff820e		offset to next line
	move.w	(a0)+,$ff8210		VWRAP	(linewidth in words)
	move.w	(a0)+,$ff8266		SPSHIFT
	move.w	(a0)+,$ff82c2		VCO

	
	MOVE.L	SAVE_VBL,$70.W

	MOVE.W	#$2300,SR

	
	RTS
;******************************************
PRESENTATION:	MOVEM.L	D7/A0-A3,-(SP)

	JSR	WAIT_SYNC

	TST.W	FINI_STAGE	; si fini_stage est a 0 cela signifie
	BEQ	PRES1		; que le jeu n'est pas encore commence
				; et que l'ecran est deja noir
	MOVE.L	ADR_ECR,A0	; --> on n'efface pas parcequ'en +
	MOVE.L	A0,A1		; c'est long de cette facon ( env 128 vbl)
	ADD.L	#40800,A1

	MOVE.W	#127,D7		; ‚cran en cours vite effac‚
PRES:	
	JSR	WAIT_SYNC
	REPT	40
	CLR.L	(A0)+
	ENDR
	ADD.L	#160,A0
	REPT	40
	CLR.L	(A1)+
	ENDR
	SUB.L	#480,A1
	DBRA	D7,PRES
PRES1:
	JSR	AFF_MES		; aff du message de presentation
	
PRES2:	JSR	XBIOS17
	CMPI.B	#$39,$FFFC02	; on attend un espace
	BNE	PRES2
PRES21:	CMPI.B	#$39+$80,$FFFC02  ; et relachement de l'espace
	BNE	PRES21
	
	MOVE.L	ECRAN1,A0	; cls des ecrans
	MOVE.L	ECRAN2,A1
	MOVE.L	ECRAN3,A2
	MOVE.L	ECRAN4,A3

	MOVE.W	#(256*40)-1,D7	; les autres c'est moins grave
PRES3:
	CLR.L	(A0)+
	CLR.L	(A1)+
	CLR.L	(A2)+
	CLR.L	(A3)+
	
	DBRA	D7,PRES3
	
	MOVEM.L	(SP)+,D7/A0-A3
	RTS
;********************************************
AFF_MES:	MOVEM.L	D5/A0-A3,-(SP)
				; routine qui aff le message
	MOVE.L	SAVE_MES,A0	; lettres A-Z
	MOVE.L	ADR_ECR,A1	; 1 --> fin de lig
				; $ff --> fin de message
	MOVE.L	A1,A2		; adresse du message dans save_mes
	LEA	FONTE,A3	
AF1:	
	CLR.L	D5
	MOVE.B	(A0)+,D5

	CMP.B	#32,D5		; espace
	BNE	AF2
	ADD.L	#8,A1		
	BRA	AF1

AF2:	CMP.B	#1,D5		; cr+lf
	BNE	AF3
	ADD.L	#20*160,A2
	MOVE.L	A2,A1
	BRA	AF1
AF3:
	CMP.B	#$FF,D5		; fin du message
	BEQ	FIN_AF

	SUB.B	#65,D5		; on retire 65 (A-65=0)
	MULU.W	#8*16,D5	; et on multiplie par 128 (taille d'un car)
	ADD.L	D5,A3		; a3 pointe sur le carac … aff
	
N	SET	0		; affichage du caractere
	REPT	16
	MOVE.L	(A3)+,N(A1)	
	MOVE.L	(A3)+,N+4(A1)	
N	SET	N+160
	ENDR
	
	LEA	FONTE,A3
	ADD.L	#8,A1
	
	BRA	AF1
FIN_AF:	MOVEM.L	(SP)+,D5/A0-A3
	RTS
;***********************************************
INIT_ALL:	MOVEM.L	D7/A0-A4,-(SP)
	
	MOVE.L	ECRAN1,ADR_ECR	; ecran en cours
	MOVE.W	#1,NUM_ECRAN

	LEA	ADR_ECR,A0	; on vient ici et cette routine
	MOVE.B	1(A0),$FFFFF8201 ; donne la nouvelle adresse 
	MOVE.B	2(A0),$FFFFF8203 ; au shifter
	
;**** affichage des bandes sur le cot‚ de l'ecran	
	
	MOVE.L	ECRAN1,A0	
	MOVE.L	ECRAN2,A1
	MOVE.L	ECRAN3,A2
	MOVE.L	ECRAN4,A3
	
	LEA	DECOR,A4
	MOVE.W	#3,D7
AF_DEC:
	REPT	6
	MOVE.L	(A4),(A0)+
	MOVE.L	(A4),(A1)+
	MOVE.L	(A4),(A2)+
	MOVE.L	(A4)+,(A3)+
	ENDR
	ADD.L	#136,A0
	ADD.L	#136,A1
	ADD.L	#136,A2
	ADD.L	#136,A3
	DBRA	D7,AF_DEC
	
	MOVE.W	#256-8-1,D7	
AF_DEC2:	
	MOVE.L	(A4),(A0)+
	MOVE.L	(A4),(A1)+
	MOVE.L	(A4),(A2)+
	MOVE.L	(A4),(A3)+
	
	
	MOVE.L	4(A4),(A0)+
	MOVE.L	4(A4),(A1)+
	MOVE.L	4(A4),(A2)+
	MOVE.L	4(A4),(A3)+
	
	MOVE.L	8(A4),(A0)+
	MOVE.L	8(A4),(A1)+
	MOVE.L	8(A4),(A2)+
	MOVE.L	8(A4),(A3)+
	
	MOVE.L	12(A4),(A0)+
	MOVE.L	12(A4),(A1)+
	MOVE.L	12(A4),(A2)+
	MOVE.L	12(A4),(A3)+
	
	MOVE.L	16(A4),(A0)+
	MOVE.L	16(A4),(A1)+
	MOVE.L	16(A4),(A2)+
	MOVE.L	16(A4),(A3)+
	
	MOVE.L	20(A4),(A0)+
	MOVE.L	20(A4),(A1)+
	MOVE.L	20(A4),(A2)+
	MOVE.L	20(A4),(A3)+
	
	ADD.L	#136,A0
	ADD.L	#136,A1
	ADD.L	#136,A2
	ADD.L	#136,A3
	
	DBRA	D7,AF_DEC2
	
	ADD.L	#24,A4
	
	MOVE.W	#3,D7
AF_DEC3:
	REPT	6
	MOVE.L	(A4),(A0)+
	MOVE.L	(A4),(A1)+
	MOVE.L	(A4),(A2)+
	MOVE.L	(A4)+,(A3)+
	ENDR
	ADD.L	#136,A0
	ADD.L	#136,A1
	ADD.L	#136,A2
	ADD.L	#136,A3
	DBRA	D7,AF_DEC3

;***********************************************
;***********************************************
				; AF_DEC_ 1,2 et 3 servent a l'affichage
	MOVE.L	ECRAN1,A0	; des cases pour le temps le score et les
	MOVE.L	ECRAN2,A1	; lignes deja faites
	MOVE.L	ECRAN3,A2	;      c'est mal programme mais j'ai pas le temps 
	MOVE.L	ECRAN4,A3	;      de m'creuser la tete
	ADD.L	#160*21,A0
	ADD.L	#160*21,A1
	ADD.L	#160*21,A2
	ADD.L	#160*21,A3
	
	
	LEA	DECOR+(9*24),A4

	MOVE.W	#33,D7
AF_DEC3_1:
	REPT	6
	MOVE.L	(A4),(A0)+
	MOVE.L	(A4),(A1)+
	MOVE.L	(A4),(A2)+
	MOVE.L	(A4)+,(A3)+
	ENDR
	ADD.L	#136,A0
	ADD.L	#136,A1
	ADD.L	#136,A2
	ADD.L	#136,A3
	DBRA	D7,AF_DEC3_1
;**********************************************
	MOVE.L	ECRAN1,A0	
	MOVE.L	ECRAN2,A1
	MOVE.L	ECRAN3,A2
	MOVE.L	ECRAN4,A3
	ADD.L	#160*71,A0
	ADD.L	#160*71,A1
	ADD.L	#160*71,A2
	ADD.L	#160*71,A3
	
	
	LEA	DECOR+(9*24)+(34*24),A4

	MOVE.W	#53,D7
AF_DEC3_2:
	REPT	6
	MOVE.L	(A4),(A0)+
	MOVE.L	(A4),(A1)+
	MOVE.L	(A4),(A2)+
	MOVE.L	(A4)+,(A3)+
	ENDR
	ADD.L	#136,A0
	ADD.L	#136,A1
	ADD.L	#136,A2
	ADD.L	#136,A3
	DBRA	D7,AF_DEC3_2
;********************************************
	MOVE.L	ECRAN1,A0	
	MOVE.L	ECRAN2,A1
	MOVE.L	ECRAN3,A2
	MOVE.L	ECRAN4,A3
	ADD.L	#160*146,A0
	ADD.L	#160*146,A1
	ADD.L	#160*146,A2
	ADD.L	#160*146,A3
	
	
	LEA	DECOR+(9*24)+(34*24)+(54*24),A4

	MOVE.W	#23,D7
AF_DEC3_3:
	REPT	6
	MOVE.L	(A4),(A0)+
	MOVE.L	(A4),(A1)+                      
	MOVE.L	(A4),(A2)+
	MOVE.L	(A4)+,(A3)+
	ENDR
	ADD.L	#136,A0
	ADD.L	#136,A1
	ADD.L	#136,A2
	ADD.L	#136,A3
	DBRA	D7,AF_DEC3_3
;********************************************
;********************************************
	
	LEA	DECOR+(9*24)+(34*24)+(54*24)+(24*24),A4
	MOVE.L	ECRAN1,A0
	MOVE.L	ECRAN2,A1
	MOVE.L	ECRAN3,A2
	MOVE.L	ECRAN4,A3
	MOVE.W	#2,D7
AF_DEC4:	
	MOVE.L	(A4),152(A0)
	MOVE.L	(A4),152(A1)
	MOVE.L	(A4),152(A2)
	MOVE.L	(A4)+,152(A3)
	MOVE.L	(A4),156(A0)
	MOVE.L	(A4),156(A1)
	MOVE.L	(A4),156(A2)
	MOVE.L	(A4)+,156(A3)
	
	ADD.L	#160,A0
	ADD.L	#160,A1
	ADD.L	#160,A2
	ADD.L	#160,A3
	DBRA	D7,AF_DEC4	

	MOVE.W	#248,D7
AF_DEC4_2:	
	MOVE.L	(A4),152(A0)
	MOVE.L	(A4),152(A1)
	MOVE.L	(A4),152(A2)
	MOVE.L	(A4),152(A3)
	MOVE.L	4(A4),156(A0)
	MOVE.L	4(A4),156(A1)
	MOVE.L	4(A4),156(A2)
	MOVE.L	4(A4),156(A3)
	ADD.L	#160,A0
	ADD.L	#160,A1
	ADD.L	#160,A2
	ADD.L	#160,A3
	DBRA	D7,AF_DEC4_2
	
	MOVE.W	#3,D7
AF_DEC4_3:	
	MOVE.L	(A4),152(A0)
	MOVE.L	(A4),152(A1)
	MOVE.L	(A4),152(A2)
	MOVE.L	(A4)+,152(A3)
	MOVE.L	(A4),156(A0)
	MOVE.L	(A4),156(A1)
	MOVE.L	(A4),156(A2)
	MOVE.L	(A4)+,156(A3)
	
	ADD.L	#160,A0
	ADD.L	#160,A1
	ADD.L	#160,A2
	ADD.L	#160,A3
	DBRA	D7,AF_DEC4_3

	
;**********************************
	LEA	DAT_0,A0	; et des repres en memoire
	MOVE.W	#(32*32)-1,D7
LO1:	CLR.L	(A0)+
	DBRA	D7,LO1
	
	JSR	TEST_VIDE
	SUB.W	#100,SCORE
	MOVE.W	SCORE,D7
	JSR	CONVERSION
	JSR	AFFSCORE
	
	MOVEM.L	(SP)+,D7/A0-A4
	RTS

NEWTIME:	
	MOVE.W	#50,VBL_TIME
	SUB.W	#1,COMPT_TIME
	BNE	NEWT2
	MOVE.W	#1,G_O
	MOVE.W	#1,OUT_OF_TIME
	CLR.W	TIME
NEWT2:
	RTS
;********************************************
;	gestion de la piece qui arrive
;********************************************
GERE_PIECE:	
	MOVEM.L	D0-D7/A0-A6,-(SP)
	
	SUB.W	#1,VITESSE	; la variable VITESSE sert a afficher
	BHI	GP1		; la piece qui descend au point pres
	 			; et non a la case pres. 
				; quand vitesse=0 alors on est au debut					 
	CLR.L	D0		; d'une nouvelle case
	CLR.L	D1
	CLR.L	D2
	
	JSR	TEST_SORTIE
	
	MOVE.W	X,D0
	MOVE.W	Y,D1
	
	ADD.W	PAS_X,D0	; est-ce que la piece a la pos suivante
	ADD.W	PAS_Y,D1	; entre en collision avec le 'decor'
	
	MOVE.W	NUM_ECRAN,D2	
	
	MOVE.W	P_EN_C,D3
	MOVE.W	R_EN_C,D4
	
	JSR	TEST_COLLISION	; explication et parametres a envoyer
				; sont au debut de la routine	
	MOVE.L	D0,A2
	MOVE.L	D1,A3
	
	TST.W	D5		; dans d5 on obtient le resultat du test
	BEQ	GE5		; 0 si ok    et     1 si collision
	

	MOVE.W	SCORE_P,D7
	ASR.W	#1,D7
	ADD.W	SCORE,D7
	MOVE.W	D7,SCORE
	JSR	CONVERSION
	JSR	AFFSCORE

	TST.W	SOUND_M
	BNE	GE0

	MOVE.L	#TOUCHE+128,-(SP)	 ; quand une piece touche
	MOVE.L	#TOUCHE+128+2212,-(SP) 	 ; on met un son
	JSR	GO_DMA_SOUND
	ADDQ.L	#8,SP
GE0:
	
	LEA	INSTRUC,A0	; affichage piece a sa derniere pos
	MOVE.W	X,(A0)		; au cas ou elle aurait bouge ou aurait
	MOVE.W	Y,2(A0)		; subit une rotation
	MOVE.W	P_EN_C,4(A0)	
	MOVE.W	R_EN_C,6(A0)	
	MOVE.W	#1,8(A0) 	
	MOVE.L	ADR_ECR,10(A0)
	MOVE.W	#0,14(A0)
	BSR	AFF_PIECE
	
	TST.W	PAS_Y
	BEQ	PAS_DE_Y
	BMI	GE1
	SUB.L	#32,A2		; A2 pointe sur la position qu'aurait
	BRA	PAS_DE_X	; occupe la piece s'il n'y avait pas eu 
GE1:	ADD.L	#32,A2		; collision -> on le remet au bon endroit
	BRA	PAS_DE_X	; selon le pas de x et celui de y
PAS_DE_Y:

	TST.W	PAS_X
	BMI	GE2
	SUB.L	#1,A2
	BRA	PAS_DE_X
GE2:	ADD.L	#1,A2
PAS_DE_X:

	REPT	4
	MOVE.B	(A3)+,D0	; et on met la repres de la piece
	OR.B	D0,(A2)+	; dans celle de l'ecran
	MOVE.B	(A3)+,D0
	OR.B	D0,(A2)+
	MOVE.B	(A3)+,D0
	OR.B	D0,(A2)+
	MOVE.B	(A3)+,D0
	OR.B	D0,(A2)+
	ADD.L	#28,A2
	ENDR

	JSR	AUTRES_ECRANS
	
	JSR	TEST_DISPA
	
	MOVE.W	NUM_ECRAN,D0  ;  ici on ajoute 1 au numero de l'ecran
	ADD.W	#1,NUM_ECRAN  ;  ainsi les colonnes de l'ec precedent
	CMP.W	#5,NUM_ECRAN  ;  deviennent les lignes de cet ecrans
	BNE	GE3	      ;  on a donc pas a reecrire une routine
	MOVE.W	#1,NUM_ECRAN  ;  de test de colonne  (pas bete hein??)
GE3:	JSR	TEST_DISPA    ;  on relance donc le test
	MOVE.W	D0,NUM_ECRAN  ;  et on remet l'ancien numero de l'ecran
	
GE4:	

	TST.W	NB_LIG
	;CMP.W	NB_A_FAIRE,D7
	BNE	PAS_FINI

	MOVE.W	#1,FINI_STAGE
	CLR.W	TIME
	BRA	GP2
		
PAS_FINI:
	JSR	TEST_GAME_OVER

	TST.W	GHOST
	BEQ	GE4_1

	SUB.W	#1,GHOST_CMP
	BNE	GE4_1

	MOVE.W	GHOST_PAS,GHOST_CMP
	JSR	GHOST_BRIQ
GE4_1: 	
	JSR	NOUVELLE_PIECE  ; si collision alors nouvelle piece
	JSR	AF_PIECE
	JSR	AFF_NEXT

	CLR.L	D0
	CLR.L	D1
	CLR.L	D2
	CLR.L	D3
	CLR.L	D4
	MOVE.W	X,D0
	MOVE.W	Y,D1
	
	MOVE.W	NUM_ECRAN,D2	
	
	MOVE.W	P_EN_C,D3
	MOVE.W	R_EN_C,D4
	
	CLR.W	D5
	JSR	TEST_COLLISION	; explication et parametres a envoyer
				; sont au debut de la routine	
	TST.W	D5		; teste si la nouvelle piece en rencontre 
	BNE	FINISH		; une autre. dans ce cas GAME OVER
	
	BRA	GP1
GE5:	
	MOVE.W	PAS_X,D0
	ADD.W	D0,X
	MOVE.W	PAS_Y,D0
	ADD.W	D0,Y
	
	MOVE.W	#8,VITESSE
GP1:	
	LEA	INSTRUC,A0	; affichage piece a sa nouvelle pos
	MOVE.W	X,(A0)	
	MOVE.W	Y,2(A0)	
	MOVE.W	P_EN_C,4(A0)	
	MOVE.W	R_EN_C,6(A0)	
	MOVE.W	#1,8(A0) 	; avec restauration du fond
	MOVE.L	ADR_ECR,10(A0)
	MOVE.W	VITESSE,14(A0)
	BSR	AFF_PIECE
GP2:	
;*************************************
;	MAD OR NOT MAD ???
;*************************************

	TST.W	MAD		; le mode MAD est il on ?
	BEQ	GP3		

	JSR	XBIOS17		;  OUAIS !!
	
	LSR.L	#3,D0
	AND.L	#$000000FF,D0	
	AND.B	#%01111111,D0	

	CMP.W	MAD_VAL,D0	; est-ce que l'on fait quelque chose 
	BNE	GP3		; maintenant ??
;*********	
	JSR	XBIOS17		; RE-OUAIS!!
	MOVE.W	MAD_VAL,D1
	LSR.L	D1,D0
	AND.L	#$000000FF,D0	
	AND.B	#%01111111,D0	
	MOVE.W	D0,MAD_VAL

	JSR	XBIOS17		
	LSR.L	#1,D0
	AND.L	#$0000000F,D0	
	AND.B	#%11,D0	

	
	TST.W	D0		;********** A MODIF
	BEQ	MAD1_1
	
	CMP.W	#1,D0		; on choisit comment on va 
	BEQ	MAD2_1		; emmerder le peuple 

	CMP.W	#2,D0
	BEQ	MAD3_1

	CMP.W	#3,D0
	BEQ	MAD1_1
	
	BRA	GP3

MAD1_1:				; rotation imprevue de l'ecran
	CLR.L	D0		; chiant au possible
	CLR.L	D1	
	CLR.L	D2	
	CLR.L	D3
	CLR.L	D4	
	
	MOVE.W	X,D0
	MOVE.W	Y,D1	
			
	MOVE.W	NUM_ECRAN,D2	
	SUBQ.W	#1,D2
	TST.W	D2
	BNE	MAD1_2
	MOVE.W	#4,D2
MAD1_2:
	MOVE.W P_EN_C,D3
	MOVE.W R_EN_C,D4

	JSR	TEST_COLLISION
	
	TST.W	D5
	BNE	GP3

	MOVEQ.L	#0,D0		; on tourne ds le sens inverse des
	MOVE.W	NUM_ECRAN,D0	; aiguilles d'une montre
	SUBQ.W	#1,D0
	BNE	MAD1_3
	MOVE.W	#4,D0
MAD1_3:	MOVE.W	D0,NUM_ECRAN
	SUBQ.W	#1,D0
	LEA	ECRAN1,A0
	LSL.W	#2,D0
	ADD.L	D0,A0
	MOVE.L	(A0),ADR_ECR	

	JSR	NVEL_ECR

	BRA	GP3
	
MAD2_1:
	CLR.L	D0
	CLR.L	D1	
	CLR.L	D2	
	CLR.L	D3
	CLR.L	D4	
	
	MOVE.W	X,D0
	MOVE.W	Y,D1	
			
	MOVE.W	NUM_ECRAN,D2	
	ADDQ.W	#1,D2
	CMP.W	#5,D2
	BNE	MAD2_2
	MOVE.W	#1,D2
MAD2_2:
	MOVE.W P_EN_C,D3
	MOVE.W R_EN_C,D4

	JSR	TEST_COLLISION
	
	TST.W	D5
	BNE	GP3
	
	MOVEQ.L	#0,D0		; cette fois ci dans le 'bon' sens
	MOVE.W	NUM_ECRAN,D0
	ADDQ.W	#1,D0
	CMPI.W	#5,D0
	BNE	MAD2_3
	
	MOVE.W	#1,D0
	
MAD2_3:	MOVE.W	D0,NUM_ECRAN
	SUBQ.W	#1,D0
	LEA	ECRAN1,A0
	LSL.W	#2,D0
	ADD.L	D0,A0
	
	MOVE.L	(A0),ADR_ECR
	JSR	NVEL_ECR
	
	BRA	GP3
	
MAD3_1:	
	CLR.L	D0	
	CLR.L	D1	
	CLR.L	D2	
	CLR.L	D3
	CLR.L	D4
	CLR.L	D5
			
	MOVE.W	X,D0	
	MOVE.W	X,D6
	MOVE.W	Y,D1	
	MOVE.W	Y,A1	

	MOVE.W	NUM_ECRAN,D2	
	
	MOVE.W P_EN_C,D3
	MOVE.W R_EN_C,D4
	
	SUBQ.W	#1,D4
	BGE	MAD3_2
	MOVE.W	#3,D4
MAD3_2:	
	
	CMPI.W	#29,D0		
	BMI	MAD3_3		
				
	MOVE.L	XM_EN_C,A0
	MOVE.W	D3,D5		
	MULU.W	#8,D5		
	ADD.L	D5,A0
	MOVE.W	D4,D5
	MULU.W	#2,D5
	ADD.L	D5,A0
	CLR.L	D5
	MOVE.W	(A0),D5
	
	CMP.W	D5,D0
	BLE	MAD3_3
	
	MOVE.W	D5,D0
	MOVE.W	D5,D6
	
MAD3_3:
	CMPI.W	#29,D1		
	BMI	MAD3_5		
				
	MOVE.L	YM_EN_C,A0
	MOVE.W	D3,D5		
	MULU.W	#8,D5		
	ADD.L	D5,A0
	MOVE.W	D4,D5
	MULU.W	#2,D5
	ADD.L	D5,A0
	CLR.L	D5
	MOVE.W	(A0),D5
	
	CMP.W	D5,D1
	BLE	MAD3_5
	
	MOVE.W	D5,D1
	MOVE.W	D5,A1

MAD3_5:	CLR.L	D5
	JSR	TEST_COLLISION
	
	TST.W	D5
	BNE	MAD3_6
	MOVE.W	D6,X
	MOVE.W	A1,Y
	MOVE.W	D4,R_EN_C
MAD3_6:	
	
MAD4_1:

GP3:
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS
	
	
GHOST_BRIQ:	MOVEM.L	D0-D7/A0-A6,-(SP)
	
	MOVE.W	#2,D7
GHO1:
	JSR	XBIOS17
	MOVE.L	D0,D1
	LSR.L	#3,D1
	AND.L	#$000000FF,D1
	AND.B	#%00001111,D1	
	ADD.W	#7,D1
	MOVE.W	D1,X
	ADD.W	#1,X


	JSR	XBIOS17
	MOVE.L	D0,D2
	LSR.L	#3,D2
	AND.L	#$000000FF,D2
	AND.B	#%00001111,D2	
	ADD.B	#7,D2
	MOVE.W	D2,Y
	ADD.W	#1,Y
	
	
	MOVE.W	NUM_ECRAN,D6
	SUBQ.W	#1,D6
	
	CMPI.W	#-1,D6
	BNE	GHO1_1
	MOVE.W	#3,D6
GHO1_1:
	MULU.W	#1024,D6
	LEA	DAT_0,A0
	ADD.L	D6,A0
	MULU.W	#32,D2
	ADD.L	D2,A0
	ADD.L	D1,A0
	
	TST.B	(A0)
	BEQ	GHO2
	
	SUBQ	#1,D7
	BEQ	GHOST_END
	
	BRA	GHO1
	
GHO2:
	MOVE.B	#1,(A0)

	MOVE.W	#7,P_EN_C
	MOVE.W	#1,R_EN_C

	TST.W	SOUND_M
	BNE	GHO3
	
	MOVE.L	#PHUNG+128,-(SP)	; appel a la routine 
	MOVE.L	#PHUNG+128+4900,-(SP)	; de playback dma
	JSR	GO_DMA_SOUND
	ADDQ.L	#8,SP

GHO3:

	LEA	INSTRUC,A0	; affichage piece a sa nouvelle pos
	MOVE.W	X,(A0)	
	MOVE.W	Y,2(A0)	
	MOVE.W	#7,4(A0)	
	MOVE.W	#1,6(A0)	
	MOVE.W	#0,8(A0) 	; avec restauration du fond
	MOVE.L	ADR_ECR,10(A0)
	MOVE.W	#0,14(A0)
	BSR	AFF_PIECE

	JSR	AUTRES_ECRANS

GHOST_END:	
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS
	
;***************************************************
;   routine qui affiche le nb de lig en cours      *
;***************************************************
AFFNBLIG:	
	MOVEM.L	D6-D7/A0-A2,-(SP)

	LEA	NOMBRE,A0
	ADD.L	#6,A0
	MOVE.L	ADR_ECR,A2
	ADD.L	#160*150+8,A2
	MOVE.W	#1,D7
AFNB:	
	LEA	CHIFFRE,A1
	CLR.L	D6
	MOVE.W	(A0)+,D6
	MULU.W	#8*8,D6
	ADD.L	D6,A1
	
	REPT	8
	MOVE.L	(A1)+,(A2)+
	MOVE.L	(A1)+,(A2)+
	ADD.L	#152,A2
	ENDR
	CLR.L	(A2)+
	CLR.L	(A2)+
	ADD.L	#152,A2
	DBRA	D7,AFNB

	MOVEM.L	(SP)+,D6-D7/A0-A2
	RTS
;******************************************
AFFTIME:	
	MOVEM.L	D6-D7/A0-A2,-(SP)

	LEA	NOMBRE+4,A0
	MOVE.L	ADR_ECR,A2
	ADD.L	#160*25+8,A2
	MOVE.W	#2,D7
AFFT:	
	LEA	CHIFFRE,A1
	CLR.L	D6
	MOVE.W	(A0)+,D6
	MULU.W	#8*8,D6
	ADD.L	D6,A1
	
	REPT	8
	MOVE.L	(A1)+,(A2)+
	MOVE.L	(A1)+,(A2)+
	ADD.L	#152,A2
	ENDR
	
	CLR.L	(A2)+
	CLR.L	(A2)+
	ADD.L	#152,A2
	
	DBRA	D7,AFFT

	MOVEM.L	(SP)+,D6-D7/A0-A2
	RTS
;***************************************************
;   routine qui affiche le score en cours          *
;***************************************************
AFFSCORE:	
	MOVEM.L	D6-D7/A0-A2,-(SP)

	LEA	NOMBRE,A0
	MOVE.L	ADR_ECR,A2
	ADD.L	#160*75+8,A2
	MOVE.W	#4,D7
REP0:	
	LEA	CHIFFRE,A1
	CLR.L	D6
	MOVE.W	(A0)+,D6
	MULU.W	#8*8,D6
	ADD.L	D6,A1
	
	REPT	8
	MOVE.L	(A1)+,(A2)+
	MOVE.L	(A1)+,(A2)+
	ADD.L	#152,A2
	ENDR
	
	CLR.L	(A2)+
	CLR.L	(A2)+
	ADD.L	#152,A2
	
	DBRA	D7,REP0

	MOVEM.L	(SP)+,D6-D7/A0-A2
	RTS

;***********************************************************
;* routine de conversion d'une valeur pour son affichage   *
;***********************************************************
CONVERSION:	
	MOVEM.L	D7/A0,-(SP)
	
	LEA	NOMBRE,A0	; recoit le nombre a convertir
				; dans d7
	CLR.L	(A0)		; et redonne dans NOMBRE le nb
	CLR.L	4(A0)		; de dizaine de milliers, de 
	CLR.W	8(A0)		; milliers...
	
C1:	CMP.W	#10000,D7
	BMI	C2
	
	SUB.W	#10000,D7	
	ADD.W	#1,(A0)
	BRA 	C1

C2:	CMP.W	#1000,D7
	BMI	C3

	SUB.W	#1000,D7	
	ADD.W	#1,2(A0)
	BRA 	C2
	
C3:	CMP.W	#100,D7
	BMI	C4
	
	SUB.W	#100,D7	
	ADD.W	#1,4(A0)
	BRA 	C3

C4:	CMP.W	#10,D7
	BMI	C5
	
	SUB.W	#10,D7	
	ADD.W	#1,6(A0)
	BRA 	C4

C5:	CMP.W	#1,D7
	BMI	C6
	
	SUB.W	#1,D7	
	ADD.W	#1,8(A0)
	BRA	C5

C6:	
	MOVEM.L	(SP)+,D7/A0
	RTS

;**********************************************************************
;**********************************************************************

NVEL_ECR:	MOVEM.L	D7/A0,-(SP)	; qd il y a un chgt d'ecran

	MOVE.W	#1,CHGT_ECR
	LEA	ADR_ECR,A0		; on vient ici et cette routine
	MOVE.B	1(A0),$FFFFF8201 	; donne la nouvelle adresse 
	MOVE.B	2(A0),$FFFFF8203 	; au shifter

	MOVE.W	COMPT_TIME,D7
	JSR	CONVERSION
	JSR	AFFTIME	

	MOVE.W	SCORE,D7		; on affiche le score en cours
	JSR	CONVERSION		; dans le nvel ecran
	JSR	AFFSCORE

	MOVE.W	NB_LIG,D7		; ainsi que le nb de lig
	JSR	CONVERSION
	JSR	AFFNBLIG

	JSR	AFF_NEXT		; et la piece suivante

	MOVEM.L	(SP)+,D7/A0
	RTS

;**********************************************************************
;**********************************************************************

TEST_SORTIE:	MOVEM.L	D0-D1/A0,-(SP)

	CMP.W	#1,PAS_X	; comme l'indique son nom, cette
	BNE	TST_SO1		; routine teste si la piece en cours
				; est a la limite de l'ecran
	MOVE.W	X,D0		; elle le teste selon le type de 
	MOVE.L	XM_EN_C,A0	; piece en ce qui concerne les cotes
	CLR.L	D1		; droit et bas car cela change 
	MOVE.W	P_EN_C,D1	; d'une piece a l'autre selon leur taille
	MULU.W	#8,D1
	ADD.L	D1,A0
	MOVE.W	R_EN_C,D1		; PAS TRES FRANCAIS TOUT CA
	MULU.W	#2,D1
	ADD.L	D1,A0
	MOVE.W	(A0),D1
	
	CMP.W	D0,D1
	BHI	NO_SORTIE		
	
	BRA	OK_SORTIE
	
TST_SO1:CMP.W	#-1,PAS_X
	BNE	TST_SO2
	
	CMP.W	#1,X
	BEQ	OK_SORTIE
	BRA	NO_SORTIE
	
TST_SO2:CMP.W	#1,PAS_Y
	BNE	TST_SO3
	
	MOVE.W	Y,D0
	MOVE.L	YM_EN_C,A0	
	CLR.L	D1		
	MOVE.W	P_EN_C,D1	
	MULU.W	#8,D1
	ADD.L	D1,A0
	MOVE.W	R_EN_C,D1
	MULU.W	#2,D1
	ADD.L	D1,A0
	MOVE.W	(A0),D1
	
	CMP.W	D0,D1
	BHI	NO_SORTIE		
	
	BRA	OK_SORTIE

TST_SO3: 
	CMP.W	#1,Y
	BEQ	OK_SORTIE

NO_SORTIE:	
	MOVEM.L	(SP)+,D0-D1/A0
	RTS
OK_SORTIE:	
	;JSR	RESTORE_FOND	
	;JSR	NOUVELLE_PIECE  
	;JSR	AF_PIECE
	;JSR	AFF_NEXT
	
	NEG.W	PAS_X		; si collision alors rebond de la piece
	NEG.W	PAS_Y
	CLR.W	SCORE_P		; et effacement du bonus piece 
				;(  faut pas deconner quand meme )
	TST.W	SOUND_M
	BNE	OK_S1
	MOVE.L	#REBOND+128,-(SP)	 ; appel a la routine 
	MOVE.L	#REBOND+128+6000,-(SP)   ; de playback dma
	JSR	GO_DMA_SOUND
	ADDQ.L	#8,SP
OK_S1:
	MOVEM.L	(SP)+,D0-D1/A0
	RTS
	
;**********************************************************************
;*  voici la routine qui teste si l'une des piece est dans les limites*
;*  de la zone de jeu						      *
;**********************************************************************

TEST_GAME_OVER:	MOVEM.L	D0/A0,-(SP)

		LEA	DAT_0,A0	; routine tres simple alors
		;ADD.L	#24,A0		; pas d'explication
		CLR.L	D0
		OR.L	(A0),D0
		OR.L	4(A0),D0
		OR.L	8(A0),D0
		OR.L	12(A0),D0
		OR.L	16(A0),D0
		OR.L	20(A0),D0
		OR.L	24(A0),D0
		OR.L	28(A0),D0
		
		TST.L	D0
		BNE	GAME_OVER
		
		REPT	32
		OR.B	(A0),D0
		OR.B	31(A0),D0
		ADD.L	#32,A0
		ENDR
		
		TST.B	D0
		BNE	GAME_OVER
		
		CLR.L	D0
		LEA	DAT_0,A0
		ADD.L	#31*32,A0
		OR.L	(A0),D0
		OR.L	4(A0),D0
		OR.L	8(A0),D0
		OR.L	12(A0),D0
		OR.L	16(A0),D0
		OR.L	20(A0),D0
		OR.L	24(A0),D0
		OR.L	28(A0),D0
		
		TST.L	D0
		BNE	GAME_OVER
		
		MOVEM.L	(SP)+,D0/A0
		RTS

GAME_OVER:	MOVE.W	#1,G_O
		MOVEM.L	(SP)+,D0/A0
		RTS
		
;**************************************************************
;* routine qui teste si l'ecran apres dispa de lig ou colonne *
;* est vide si oui il rajoute la piece centrale de depart     *
;**************************************************************
TEST_VIDE:	MOVEM.L	D0-D7/A0-A6,-(SP)	
						
	LEA	DAT_0,A0			
						
	CLR.L	D6
	MOVE.W	#31,D7
TST_V:	
	OR.L	(A0)+,D6
	OR.L	(A0)+,D6
	OR.L	(A0)+,D6
	OR.L	(A0)+,D6
	OR.L	(A0)+,D6
	OR.L	(A0)+,D6
	OR.L	(A0)+,D6
	OR.L	(A0)+,D6
	
	TST.L	D6
	BNE	TST_V2
	DBRA	D7,TST_V
TST_V1:
	TST.W	SOUND_M
	BNE	TST_V01
	
	MOVE.L	#VIDE+128,-(SP)	 	; appel a la routine 
	MOVE.L	#VIDE+128+30000,-(SP) 	; de playback dma
	JSR	GO_DMA_SOUND
	ADDQ.L	#8,SP

TST_V01:

	LEA	DAT_0+(15*32)+15,A0	; place la piece en memoire
	MOVE.L	JEU_P_EN_C,A1
	ADD.L	#8*16*4,A1
	;LEA	DATA_PIECE,A1
	REPT	4
	
	MOVE.B	(A1),(A0)+
	MOVE.B	(A1),1023(A0)
	MOVE.B	(A1),2047(A0)
	MOVE.B	(A1)+,3071(A0)
	MOVE.B	(A1),(A0)+
	MOVE.B	(A1),1023(A0)
	MOVE.B	(A1),2047(A0)
	MOVE.B	(A1)+,3071(A0)
	MOVE.B	(A1),(A0)+
	MOVE.B	(A1),1023(A0)
	MOVE.B	(A1),2047(A0)
	MOVE.B	(A1)+,3071(A0)
	MOVE.B	(A1),(A0)+
	MOVE.B	(A1),1023(A0)
	MOVE.B	(A1),2047(A0)
	MOVE.B	(A1)+,3071(A0)
	ADD 	#28,A0
	ENDR
	
	;MOVE.L	GFX_EN_C,A1
	;MOVE.L	#PIECES,GFX_EN_C
			
	LEA	INSTRUC,A0	
	MOVE.W	#16,(A0)	; pos x
	MOVE.W	#16,2(A0)	; pos y
	MOVE.W	#8,4(A0)	; numero piece (premiere piece=0)
	MOVE.W	#0,6(A0)	; rotation piece (pareil rot 1=0)
	MOVE.W	#0,8(A0) 	; restauration de l'ancien fond??
	MOVE.L	ECRAN1,10(A0)
	MOVE.W	VITESSE,14(A0)
	BSR	AFF_PIECE
	
	MOVE.L	ECRAN2,10(A0)	
	BSR	AFF_PIECE	
	
	MOVE.L	ECRAN3,10(A0)
	BSR	AFF_PIECE
	
	MOVE.L	ECRAN4,10(A0)
	BSR	AFF_PIECE

	;MOVE.L	A1,GFX_EN_C
	
	ADD.W	#100,SCORE
	
	MOVE.W	SCORE,D7
	JSR	CONVERSION
	JSR	AFFSCORE
	

TST_V2:	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS
	

;************************************************************
;*      routine qui teste si les lignes disparaissent       *
;************************************************************         

TEST_DISPA:	MOVEM.L	D0-D7/A0-A6,-(SP)	; on sauve ts ici aussi
	
	; cette routine teste si des lignes horizontales comporte
	; plus de huit carres ceux-ci devant tous se toucher
	; pour cela on fait donc une addition des carres qui se touchent 
	
	MOVEQ.L	#0,D0
	MOVE.W	NUM_ECRAN,D0
	SUBQ.W	#1,D0
	LEA	DAT_0,A0
	MULU.W	#1024,D0
	ADD.L	D0,A0

	CLR.L	D4
	MOVE.W	#-1,D4
	
	MOVE.W	#31,D1
TS_0:	
	ADDQ.W	#1,D4		; numero de la lig en cours
	MOVEQ.B	#0,D7		; pas de l'addition
	MOVEQ.B	#0,D6		; addition finale si >=8 alors lig dispa
	
	MOVE.L	A0,A1		; dans a0 on a tjrs le debut de la lig
				; en cours on bosse avec a1
				
	CLR.L	D5
	
	REPT	8		; ici on teste si la lig est vide
	OR.L	(A1)+,D5
	ENDR
	TST.L	D5
	BNE.S	TS_01		; non ! on va en ts_01
	
	ADD.L	#32,A0		; oui ! on passe a la lig suivante
	
	BRA	TS_5
TS_01:	
	MOVE.W	#31,D2
	MOVE.L	A0,A1
	ADD.L	#32,A0
TS_1:	
	MOVE.B	(A1)+,D5	; y a t-il une piece ?
	BEQ.S	TS_3		; y'en a pas --> on va en ts_3
	
	TST.B	D7		; il y a un blanc entre les carres
	BMI	TS_5		; la lig est non conforme
	
	MOVEQ.B	#1,D7		; on commence ou on continue le
	ADDQ.B	#1,D6		; calcul
	BRA.S	TS_4
	
TS_3:	
	TST.B	D7		; si on etait en train de compter des 
	BEQ.S	TS_4		; carre alors on arrete le calcul

	MOVE.W	#-1,D7		; et on regarde si la lig dispa

TS_4:	DBRA	D2,TS_1		; carre suivant
	
TS_4_1:	
	CMP.W	NB_CARRE,D6		; s'il y a + de 8 carres la lig dispa
	BMI.S	TS_5

	TST.W	SOUND_M
	BNE	TS_4_01

	MOVE.L	#EXPLOSE+128,-(SP)	 ; appel a la routine 
	MOVE.L	#EXPLOSE+128+22000,-(SP) ; de playback dma
	JSR	GO_DMA_SOUND
	ADDQ.L	#8,SP
TS_4_01:
	JSR	LIG_DISPA

	ADD.W	#100,SCORE
	TST.W	NB_LIG
	BEQ	TS_4_2
	SUB.W	#1,NB_LIG
TS_4_2:
	SUB.L	#32,A0
	ADDQ.W	#1,D1
	SUBQ.W	#1,D4

TS_5:	DBRA	D1,TS_0		; lig suivante

	JSR	TEST_VIDE
	
	MOVE.W	SCORE,D7
	JSR	CONVERSION
	JSR	AFFSCORE
	
	MOVE.W	NB_LIG,D7
	JSR	CONVERSION
	JSR	AFFNBLIG

	
	MOVE.W	#000,$FF8240
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS
;*********************************************************************
;*    quand le test est positif et que la ligne en cours disparait   *
;*********************************************************************
LIG_DISPA:	MOVEM.L	D0-D7/A0-A6,-(SP)

	MOVEQ.L	#0,D0
	MOVE.W	NUM_ECRAN,D0
	SUBQ.W	#1,D0
	LEA	ECRAN1,A0
	MULU.W	#4,D0
	ADD.L	D0,A0
	MOVE.L	(A0)+,A1
	
	MOVE.L	(A0)+,A6
	
	CMP.W	#15,D4
	BHI	L_BAS

L_HAUT:	
	MOVE.W	NUM_ECRAN,D7
	CLR.L	D1
	MOVE.W	D4,D1	; numero de la ligne
	MOVE.L	A1,A2	; adresse de l'ecran
	JSR	DISP_HAUT

;***********************
	
	MOVE.W	NUM_ECRAN,D7
	ADDQ.W	#1,D7
	CMP.W	#5,D7
	BNE	LH1
	MOVE.W	#1,D7
	
LH1:	MOVE.W	#31,D1	; numero de la col
	SUB.W	D4,D1
	
	LEA	ECRAN1,A1
	MOVE.W	D7,D6
	SUBQ.W	#1,D6
	MULU.W	#4,D6
	ADD.L	D6,A1
	MOVE.L	(A1),A2	; adresse de l'ecran
	JSR	DISP_DROITE
;************
	ADDQ.W	#1,D7
	CMP.W	#5,D7
	BNE	LH2
	MOVE.W	#1,D7
	
LH2:	MOVE.W	#31,D1	; numero de la col
	SUB.W	D4,D1
	
	LEA	ECRAN1,A1
	MOVE.W	D7,D6
	SUBQ.W	#1,D6
	MULU.W	#4,D6
	ADD.L	D6,A1
	MOVE.L	(A1),A2	; adresse de l'ecran
	JSR	DISP_BAS

;**********

	ADDQ.W	#1,D7
	CMP.W	#5,D7
	BNE	LH3
	MOVE.W	#1,D7
	
LH3:		; numero de la col
	CLR.L	D1
	MOVE.W	D4,D1
	;SUBQ.W	#1,D1	;<--
	
	LEA	ECRAN1,A1
	MOVE.W	D7,D6
	SUBQ.W	#1,D6
	MULU.W	#4,D6
	ADD.L	D6,A1
	MOVE.L	(A1),A2	; adresse de l'ecran
	JSR	DISP_GAUCHE

	BRA	FIN_DISP
;***************************************************	
L_BAS:	
	MOVE.W	NUM_ECRAN,D7
	MOVE.W	D4,D1
	MOVE.L	A1,A2
	JSR	DISP_BAS

	ADDQ.W	#1,D7
	CMP.W	#5,D7
	BNE	LB1
	MOVE.W	#1,D7
	
LB1:	MOVE.W	#31,D1	; numero de la col
	;CLR.L	D1
	SUB.W	D4,D1
	
	LEA	ECRAN1,A1
	MOVE.W	D7,D6
	SUBQ.W	#1,D6
	MULU.W	#4,D6
	ADD.L	D6,A1
	MOVE.L	(A1),A2	; adresse de l'ecran
	JSR	DISP_GAUCHE
	
	ADDQ.W	#1,D7
	CMP.W	#5,D7
	BNE	LB2
	MOVE.W	#1,D7
	
LB2:	MOVE.W	#31,D1	; numero de la col
	SUB.W	D4,D1
	
	LEA	ECRAN1,A1
	MOVE.W	D7,D6
	SUBQ.W	#1,D6
	MULU.W	#4,D6
	ADD.L	D6,A1
	MOVE.L	(A1),A2	; adresse de l'ecran
	JSR	DISP_HAUT

;***********************************************

	ADDQ.W	#1,D7
	CMP.W	#5,D7
	BNE	LB3
	MOVE.W	#1,D7
	
LB3:				; numero de la col
	MOVE.W	D4,D1
	
	LEA	ECRAN1,A1
	MOVE.W	D7,D6
	SUBQ.W	#1,D6
	MULU.W	#4,D6
	ADD.L	D6,A1
	MOVE.L	(A1),A2		; adresse de l'ecran
	JSR	DISP_DROITE

	
FIN_DISP:
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

;************************************************
;  	une colonne dispa elle est a gauche
;************************************************
DISP_GAUCHE:

	MOVE.W	D7,D2		; effacement de la col en
	SUBQ.W	#1,D2		; memoire
	LEA	DAT_0,A3
	MULU.W	#1024,D2
	ADD.L	D2,A3
	ADD.L	D1,A3
	
	MOVE.W	#30,D6
DG_0:	
	
	MOVE.W	D1,D5
	
	LEA	32(A3),A4
	ADD.L	#32,A3
	
DG_1:	MOVE.B	-1(A4),(A4)
	SUBQ.W	#1,A4
	DBRA	D5,DG_1
	CLR.B	(A4)
	DBRA	D6,DG_0
;********	
	CLR.L	D0
	MOVE.W	#15,D0
	SUB.W	D1,D0
	
	LSL.W	#2,D0
	LEA	TAB_DEC,A3
	MOVE.L	0(A3,D0.W),A4
	;MOVE.L	#SOR17,A3
	;ADD.L	#2,A3
	;MOVE.L	A4,(A3)
	
	LEA	24(A2),A3	
	MOVE.W	#256,D2
	LEA	DAT_0,A2
	MOVE.W	#1,D1

SOR0:
	SUBQ.W	#1,D1
	BNE	JUMPL
				; ici on teste si la lig dont une col
	CLR.L	D0		; doit dispa est vide si oui 
	REPT	8		;  on passe a la suivante on va pas
	OR.L	(A2)+,D0	; se faire chier a effacer du vide !!
	ENDR
	
	TST.L	D0
	BNE	JUMPL
	
	ADD.L	#8*160,A3
	SUB.W	#8,D2
	BEQ	SOR18
	
	BRA	SOR0
	
JUMPL:
	MOVE.W	#8,D1
	JMP	(A4)

SOR1:	
		MOVE.B	56(A3),57(A3)
		MOVE.B	58(A3),59(A3)
		MOVE.B	60(A3),61(A3)
		MOVE.B	62(A3),63(A3)
SOR2:
		MOVE.B	49(A3),56(A3)
		MOVE.B	51(A3),58(A3)
		MOVE.B	53(A3),60(A3)
		MOVE.B	55(A3),62(A3)
SOR3:
		MOVE.B	48(A3),49(A3)
		MOVE.B	50(A3),51(A3)
		MOVE.B	52(A3),53(A3)
		MOVE.B	54(A3),55(A3)
SOR4:
		MOVE.B	41(A3),48(A3)
		MOVE.B	43(A3),50(A3)
		MOVE.B	45(A3),52(A3)
		MOVE.B	47(A3),54(A3)
SOR5:	
		MOVE.B	40(A3),41(A3)
		MOVE.B	42(A3),43(A3)
		MOVE.B	44(A3),45(A3)
		MOVE.B	46(A3),47(A3)
SOR6:	
		MOVE.B	33(A3),40(A3)
		MOVE.B	35(A3),42(A3)
		MOVE.B	37(A3),44(A3)
		MOVE.B	39(A3),46(A3)
SOR7:	
		MOVE.B	32(A3),33(A3)
		MOVE.B	34(A3),35(A3)
		MOVE.B	36(A3),37(A3)
		MOVE.B	38(A3),39(A3)
SOR8:	
		MOVE.B	25(A3),32(A3)
		MOVE.B	27(A3),34(A3)
		MOVE.B	29(A3),36(A3)
		MOVE.B	31(A3),38(A3)
SOR9:	
		MOVE.B	24(A3),25(A3)
		MOVE.B	26(A3),27(A3)
		MOVE.B	28(A3),29(A3)
		MOVE.B	30(A3),31(A3)
SOR10:	
		MOVE.B	17(A3),24(A3)
		MOVE.B	19(A3),26(A3)
		MOVE.B	21(A3),28(A3)
		MOVE.B	23(A3),30(A3)
SOR11:	
		MOVE.B	16(A3),17(A3)
		MOVE.B	18(A3),19(A3)
		MOVE.B	20(A3),21(A3)
		MOVE.B	22(A3),23(A3)
SOR12:	
		MOVE.B	9(A3),16(A3)
		MOVE.B	11(A3),18(A3)
		MOVE.B	13(A3),20(A3)
		MOVE.B	15(A3),22(A3)
SOR13:	
		MOVE.B	8(A3),9(A3)
		MOVE.B	10(A3),11(A3)
		MOVE.B	12(A3),13(A3)
		MOVE.B	14(A3),15(A3)
SOR14:	
		MOVE.B	1(A3),8(A3)
		MOVE.B	3(A3),10(A3)
		MOVE.B	5(A3),12(A3)
		MOVE.B	7(A3),14(A3)
SOR15:	
		MOVE.B	0(A3),1(A3)
		MOVE.B	2(A3),3(A3)
		MOVE.B	4(A3),5(A3)
		MOVE.B	6(A3),7(A3)
SOR16:	
		CLR.B	0(A3)
		CLR.B	2(A3)
		CLR.B	4(A3)
		CLR.B	6(A3)
		
		ADD.L	#160,A3
		
		SUBQ.W	#1,D2
		BEQ	SOR18
SOR17:		JMP	SOR0

SOR18:
		RTS
		
		
TAB_DEC:	DC.L	SOR1,SOR2,SOR3,SOR4,SOR5,SOR6,SOR7
		DC.L	SOR8,SOR9,SOR10,SOR11,SOR12,SOR13
		DC.L	SOR14,SOR15,SOR16
		
		

;************************************************
;  	une colonne dispa elle est a droite
;************************************************
DISP_DROITE:

	MOVE.W	D7,D2		; effacement de la lig en
	SUBQ.W	#1,D2		; memoire
	LEA	DAT_0,A3
	MULU.W	#1024,D2
	ADD.L	D2,A3
	ADD.L	D1,A3
	
	MOVE.W	#30,D6
DD_0:	
	MOVE.W	#31,D5
	SUB.W	D1,D5
	
	LEA	32(A3),A4
	ADD.L	#32,A3
	
DD_1:	MOVE.B	1(A4),(A4)+
	DBRA	D5,DD_1
	CLR.B	(A4)
	DBRA	D6,DD_0

;******************************

	CLR.L	D0		 ; voici la routine qui efface une
	MOVE.W	D1,D0		 ; col a l'ecran 
	SUB.W	#16,D0		 ; elle a ete assez chiante a ecrire
				 ; car elle devait etre rapide et 
	LSL.W	#2,D0		 ; comprehensible
	LEA	TAB_DEC2,A3
	MOVE.L	0(A3,D0.W),A4
	;MOVE.L	#SOL17,A3
	;ADD.L	#2,A3
	;MOVE.L	A4,(A3)
	
	LEA	88(A2),A3	; --> 64+24
	MOVE.W	#256,D2
	LEA	DAT_0,A2
	MOVE.W	#1,D1

SOL0:
	SUBQ.W	#1,D1
	BNE	JUMPD
	
				; ici on teste si la lig dont une col
	CLR.L	D0		; doit dispa est vide si oui 
	REPT	8		;  on passe a la suivante on va pas
	OR.L	(A2)+,D0	; se faire chier a effacer du vide !!
	ENDR
	
	TST.L	D0
	BNE	JUMPD
	
	ADD.L	#8*160,A3
	SUB.W	#8,D2
	BEQ	SOL18
	
	BRA	SOL0
	
JUMPD:
	MOVE.W	#8,D1
	JMP	(A4)

SOL1:	
	MOVE.B	1(A3),0(A3)
	MOVE.B	3(A3),2(A3)
	MOVE.B	5(A3),4(A3)
	MOVE.B	7(A3),6(A3)
SOL2:	
	MOVE.B	8(A3),1(A3)
	MOVE.B	10(A3),3(A3)
	MOVE.B	12(A3),5(A3)
	MOVE.B	14(A3),7(A3)
SOL3:	
	MOVE.B	9(A3),8(A3)
	MOVE.B	11(A3),10(A3)
	MOVE.B	13(A3),12(A3)
	MOVE.B	15(A3),14(A3)
SOL4:	
	MOVE.B	16(A3),9(A3)
	MOVE.B	18(A3),11(A3)
	MOVE.B	20(A3),13(A3)
	MOVE.B	22(A3),15(A3)
SOL5:	
	MOVE.B	17(A3),16(A3)
	MOVE.B	19(A3),18(A3)
	MOVE.B	21(A3),20(A3)
	MOVE.B	23(A3),22(A3)
SOL6:	
	MOVE.B	24(A3),17(A3)
	MOVE.B	26(A3),19(A3)
	MOVE.B	28(A3),21(A3)
	MOVE.B	30(A3),23(A3)
SOL7:	
	MOVE.B	25(A3),24(A3)
	MOVE.B	27(A3),26(A3)
	MOVE.B	29(A3),28(A3)
	MOVE.B	31(A3),30(A3)
SOL8:	
	MOVE.B	32(A3),25(A3)
	MOVE.B	34(A3),27(A3)
	MOVE.B	36(A3),29(A3)
	MOVE.B	38(A3),31(A3)
SOL9:	
	MOVE.B	33(A3),32(A3)
	MOVE.B	35(A3),34(A3)
	MOVE.B	37(A3),36(A3)
	MOVE.B	39(A3),38(A3)
SOL10:	
	MOVE.B	40(A3),33(A3)
	MOVE.B	42(A3),35(A3)
	MOVE.B	44(A3),37(A3)
	MOVE.B	46(A3),39(A3)
SOL11:	
	MOVE.B	41(A3),40(A3)
	MOVE.B	43(A3),42(A3)
	MOVE.B	45(A3),44(A3)
	MOVE.B	47(A3),46(A3)
SOL12:	
	MOVE.B	48(A3),41(A3)
	MOVE.B	50(A3),43(A3)
	MOVE.B	52(A3),45(A3)
	MOVE.B	54(A3),47(A3)
SOL13:	
	MOVE.B	49(A3),48(A3)
	MOVE.B	51(A3),50(A3)
	MOVE.B	53(A3),52(A3)
	MOVE.B	55(A3),54(A3)
SOL14:	
	MOVE.B	56(A3),49(A3)
	MOVE.B	58(A3),51(A3)
	MOVE.B	60(A3),53(A3)
	MOVE.B	62(A3),55(A3)
SOL15:	
	MOVE.B	57(A3),56(A3)
	MOVE.B	59(A3),58(A3)
	MOVE.B	61(A3),60(A3)
	MOVE.B	63(A3),62(A3)
SOL16:	
	CLR.B	57(A3)
	CLR.B	59(A3)
	CLR.B	61(A3)
	CLR.B	63(A3)
	ADD.L	#160,A3
		
	SUBQ.W	#1,D2
	BEQ	SOL18
SOL17:	JMP	SOL0

SOL18:
		RTS
		
		
TAB_DEC2:	DC.L	SOL1,SOL2,SOL3,SOL4,SOL5,SOL6,SOL7
		DC.L	SOL8,SOL9,SOL10,SOL11,SOL12,SOL13
		DC.L	SOL14,SOL15,SOL16


;*************************************************
;      une lig dispa elle est en haut		 *
;*************************************************
DISP_HAUT:	
	MOVE.W	D1,D0
	MOVE.W	D1,D2
	SUB.L	#8,A2	;  8 ou 16 ?
				; on calcul la position de la lig
	MULU.W	#8*160,D1	; qui doit dispa dans l'ecran
	ADD.L	D1,A2
	LEA	8*160(A2),A3
	
	SUBQ.W	#1,D2
DH:	
	MOVE.W	#7,D3
DH1:
	REPT	32
	MOVE.L	-(A2),-(A3)
	ENDR
	SUB.L	#32,A2
	SUB.L	#32,A3
	
	DBRA	D3,DH1
	DBRA	D2,DH

	MOVE.W	D7,D2		; effacement de la lig en
	SUBQ.W	#1,D2		; memoire
	LEA	DAT_0,A2
	MULU.W	#1024,D2
	ADD.L	D2,A2
	
	MOVE.W	D0,D3
	MULU.W	#32,D3
	ADD.L	D3,A2
	LEA	32(A2),A3
	
	MOVE.W	D0,D2
	SUBQ.W	#1,D2
DH2:	REPT	8
	MOVE.L	-(A2),-(A3)
	ENDR
	DBRA	D2,DH2 
	RTS
	
;**********************************************
;        une lig dispa elle est en bas	      *
;**********************************************

DISP_BAS:	
	MOVE.W	D1,D0
	MOVE.W	#31,D2
	SUB.W	D1,D2
	;SUB.L	#16,A2		; on calcul la position de la lig
	ADD.L	#24,A2
	MULU.W	#8*160,D1	; qui doit dispa dans l'ecran
	ADD.L	D1,A2
	LEA	8*160(A2),A3
	
DB:	
	MOVE.W	#7,D3
DB1:
	REPT	32
	MOVE.L	(A3)+,(A2)+
	ENDR
	ADD.L	#32,A2
	ADD.L	#32,A3
	
	DBRA	D3,DB1
	DBRA	D2,DB

	MOVE.W	D7,D2	; effacement de la lig en
	SUBQ.W	#1,D2		; memoire
	LEA	DAT_0,A2
	MULU.W	#1024,D2
	ADD.L	D2,A2
	
	MOVE.W	D0,D3
	MULU.W	#32,D3
	ADD.L	D3,A2
	LEA	32(A2),A3
	
	MOVE.W	#30,D2
	SUB.W	D0,D2
	
DB2:	REPT	8
	MOVE.L	(A3)+,(A2)+
	ENDR
	DBRA	D2,DB2 
	RTS
;**********************************************************************
;*   affichage de la piece dans les 3 autres ecrans et ds leur repres *
;**********************************************************************
AUTRES_ECRANS:	
	MOVEM.L	D0-D7/A0-A6,-(SP)
	
	CLR.L	D0	; cette partie est peut-etre la plus chiante !
	CLR.L	D1	; quand 1 piece est affichee dans l'ecr en cours
	CLR.L	D2	; il faut l'aff dans les 3 autres avec chaq fois
	CLR.L	D3	; une rotation supplementaire de 90 deg 
	CLR.L	D4
	CLR.L	D5
	CLR.L	D6
	CLR.L	D7
	
	MOVE.W	X,D0
	MOVE.W	#33,D1
	SUB.W	D0,D1
	
	MOVE.W	Y,D2
	MOVE.W	#33,D3
	SUB.W	D2,D3
	
	LEA	AUTRE,A3
	MOVE.W	D3,(A3)+
	MOVE.W	D0,(A3)+
	
	MOVE.W	D1,(A3)+
	MOVE.W	D3,(A3)+
	
	MOVE.W	D2,(A3)+
	MOVE.W	D1,(A3)+
	
	
	MOVE.L	ROT_EN_C,A2
	
	MOVE.W	P_EN_C,D4
	;LSL.W	#6,D4
	MULU.W	#16*4,D4
	ADD.L	D4,A2
	CLR.L	D4
	
	MOVE.W	R_EN_C,D4
	MOVE.W	D4,D6
	;LSL.W	#4,D4
	MULU.W	#16,D4
	ADD.L	D4,A2
	MOVE.W	D6,D4
	
	MOVE.W	NUM_ECRAN,D5
	;SUBQ.W	#1,D5
	MOVE.W	D5,D6
	LEA	ECRAN1,A1
	LSL.W	#2,D5
	ADD.L	D5,A1
	MOVE.W	D6,D5
	
	MOVE.L	D5,D6
	; SUBQ.W	#1,D5
	LEA	DAT_0,A4
	MULU.W	#1024,D5
	ADD.L	D5,A4
	MOVE.L	D6,D5
	
	LEA	AUTRE,A3
	
	;JSR	WAIT_SYNC
	
	MOVE.W	#2,D7
REP_AU:

	ADDQ.W	#1,D4
	CMP.W	#4,D4
	BNE	AU2
	MOVE.W	#0,D4
AU2:
	ADDQ.W	#1,D5
	CMP.W	#5,D5
	BNE	AU3
	MOVE.W	#0,D5
	LEA	DAT_0,A4
	LEA	ECRAN1,A1
AU3:
	
	LEA	INSTRUC,A0	; affichage piece a sa nouvelle pos
	MOVE.W	(A3)+,(A0)	
	MOVE.W	(A2)+,D6
	ADD.W	D6,(A0)
	
	MOVE.W	(A3)+,2(A0)	
	MOVE.W	(A2)+,D6
	ADD.W	D6,2(A0)
	
;********************** l'affichage a l'ecran c'est bien beau mais
;**********************	il faut aussi gerer la repres en memoire
	MOVE.L	A4,A5		; calcul pos x dans la repres de
	ADD.L	#1024,A4	        ; l'ecran concerne
	CLR.L	D1
	MOVE.W	(A0),D1
	SUBQ.W	#1,D1
	ADD.L	D1,A5
	
	MOVE.W	2(A0),D1	; pareil pour le x
	SUBQ.W	#1,D1
	MULU.W	#32,D1
	ADD.L	D1,A5
	
	MOVE.L	JEU_P_EN_C,A6	; quelle piece doit on mettre
	CLR.L	D1
	MOVE.W	P_EN_C,D1	; et quelle rotation ?
	MULU.W	#16*4,D1
	ADD.L	D1,A6
	MOVE.W	D4,D1
	MULU.W	#16,D1
	ADD.L	D1,A6
	
	REPT	4
	
	MOVE.B	(A6)+,D1	; et la on la met 
	OR.B	D1,(A5)+
	
	MOVE.B	(A6)+,D1
	OR.B	D1,(A5)+
	
	MOVE.B	(A6)+,D1
	OR.B	D1,(A5)+
	
	MOVE.B	(A6)+,D1
	OR.B	D1,(A5)+
	
	ADD.L	#28,A5
	ENDR 
;*******************************
	
	MOVE.W	P_EN_C,4(A0)	; et la on l'affiche a l'ecran 
	MOVE.W	D4,6(A0)	
	MOVE.W	#0,8(A0) 	
	MOVE.L	(A1)+,10(A0)
	MOVE.W	#0,14(A0)	; vitesse
	BSR	AFF_PIECE
	
	DBRA	D7,REP_AU
	
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS
		EVEN
ROTATION:	
		; CHAQUE LIG CORRESP A UNE ROTATION DE LA PIECE
		; ON AJOUTE 90 DEG --> 1ER COUPLE = 1 ROT VERS LA DROITE
		
		DC.W	-1,0,-1,-1,0,-1,0,0	; piece n 1
		DC.W	-1,0,-1,-1,0,-1,0,0
		DC.W	-1,0,-1,-1,0,-1,0,0
		DC.W	-1,0,-1,-1,0,-1,0,0
		
		DC.W	-2,0,-1,-2,0,-1,0,0     ; 0 ROT	; piece n 2
		DC.W	-1,0,-2,-1,0,-2,0,0	; 3 ROT
		DC.W	-2,0,-1,-2,0,-1,0,0     ; 2 ROT
		DC.W	-1,0,-2,-1,0,-2,0,0 	; 1 ROT

		DC.W	-2,0,-1,-2,0,-3,0,0	; piece n 3
		DC.W	-1,0,-2,-3,0,-2,0,0
		DC.W	-2,-2,-1,-2,0,-1,0,0
		DC.W	-3,0,-2,-3,2,-2,0,0
	
		DC.W	0,0,-3,0,0,-3,0,0	; piece n 4
		DC.W	-3,0,0,-3,0,0,0,0
		DC.W	0,0,-3,0,0,-3,0,0
		DC.W	-3,0,0,-3,0,0,0,0

						; piece n 5
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0 	

						; piece n 6
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0 	
		
						; piece n 7
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0 	

		DC.W	 0,0,0,0,0,0,0,0	; piece n 8
		DC.W	 0,0,0,0,0,0,0,0	
		DC.W	 0,0,0,0,0,0,0,0	
		DC.W	 0,0,0,0,0,0,0,0	

	
ROTATION2:	
		DC.W	-2,0,-2,-2,0,-2,0,0     ; 0 ROT	
		DC.W	-2,0,-2,-2,0,-2,0,0     ; 3 ROT 
		DC.W	-2,0,-2,-2,0,-2,0,0     ; 2 ROT
		DC.W	-2,0,-2,-2,0,-2,0,0 	; 1 ROT

		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0 	

		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0 	

		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0 	

		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0 	

		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0     
		DC.W	-2,0,-2,-2,0,-2,0,0 	

		DC.W	-3,0,-1,-3,0,-1,0,0     
		DC.W	-1,0,-3,-1,0,-3,0,0     
		DC.W	-3,0,-1,-3,0,-1,0,0     
		DC.W	-1,0,-3,-1,0,-3,0,0     

		DC.W	 0,0,0,0,0,0,0,0	; piece n 8
		DC.W	 0,0,0,0,0,0,0,0	
		DC.W	 0,0,0,0,0,0,0,0	
		DC.W	 0,0,0,0,0,0,0,0	
	
;********************************************
;	quand une nouvelle piece arrive	    *
;********************************************
NOUVELLE_PIECE:
	MOVEM.L	D0-D1/A0,-(SP)

	
	MOVE.W	NE_P_EN_C,P_EN_C	; transfert des donnees
	MOVE.W	NE_R_EN_C,R_EN_C	; sur la piece suivante
	MOVE.W	NE_X,X			; vers la piece en cours
	MOVE.W	NE_Y,Y
	MOVE.W	NE_PAS_X,PAS_X	
	MOVE.W	NE_PAS_Y,PAS_Y	
NO:	
	JSR	XBIOS17
	
	MOVE.L	D0,D1
	LSR.L	#3,D1
	AND.L	#$000000FF,D1	; les 2 premiers bits dans d1
	AND.B	#%00000111,D1	; tirage du type de piece

	TST.B	D1		; on veut un resultat entre 
	BEQ	NO		; 0 et 6 --> si 0 nveau nb au hasard
				; et ensuite on enleve 1
	SUBQ	#1,D1
		
	MOVE.W	D1,NE_P_EN_C		
	CLR.W	NE_R_EN_C		
	
	MOVE.L	D0,D1
	LSR.L	#6,D1
	AND.L	#$000000FF,D1	; les 2 premiers bits dans d1
	AND.B	#%00000011,D1	; tirage de l'endroit  d'ou vient la piece

	MOVE.W	D1,NEXT_DIRECT
	MULU.W	#8,D1
	LEA	PARAM_PIECE,A0
	ADD.L	D1,A0
	
	MOVE.W	(A0)+,NE_X
	MOVE.W	(A0)+,NE_Y
	MOVE.W	(A0)+,NE_PAS_X	
	MOVE.W	(A0)+,NE_PAS_Y
	
	CMP.W	#2,NEXT_DIRECT
	BNE	NO1
	
	MOVE.L	XM_EN_C,A0
	CLR.L	D1		
	MOVE.W	NE_P_EN_C,D1	
	MULU.W	#8,D1
	ADD.L	D1,A0
	MOVE.W	(A0),D1
	SUBQ.W	#1,D1
	MOVE.W	D1,NE_X
	BRA	NO2

NO1:	CMP.W	#3,NEXT_DIRECT
	BNE	NO2
	
	MOVE.L	YM_EN_C,A0	
	CLR.L	D1		
	MOVE.W	NE_P_EN_C,D1	
	MULU.W	#8,D1
	ADD.L	D1,A0
	MOVE.W	(A0),NE_Y
	SUB.W	#1,NE_Y
NO2:
	
	MOVE.W	#8,VITESSE
	CLR.W	SCORE_P
	
	MOVEM.L	(SP)+,D0-D1/A0
	RTS

PARAM_PIECE:	
	DC.W	2,15,1,0	; gauche
	DC.W	15,2,0,1	; haut
	DC.W	0,15,-1,0	; droite
	DC.W	15,0,0,-1	; bas

XBIOS17:			; comment obtenir un nb tres
	MOVE.L	RANDOM,D0	; al‚atoirement
	MULU	#31415,D0
	ADD.L	#$12345,D0
	MOVE.L	D0,RANDOM
	RTS
;**************************************************
AF_PIECE:	MOVE.L	A0,-(SP)
	LEA	INSTRUC,A0	; affichage de la piece
	MOVE.W	X,(A0)	
	MOVE.W	Y,2(A0)	
	MOVE.W	P_EN_C,4(A0)	
	MOVE.W	R_EN_C,6(A0)	
	MOVE.W	#0,8(A0) 	
	MOVE.L	ADR_ECR,10(A0)
	BSR	AFF_PIECE
	
	MOVE.L	(SP)+,A0
	RTS
;***************************************************
AFF_NEXT:	

	TST.W	NEXT_B
	BEQ	AFF_NE_END
	
	MOVEM.L	D7/A0-A1,-(SP)

	MOVE.W	NEXT_DIRECT,D7
	MULU.W	#24*16,D7
	LEA	NEXT_PIECE,A0
	ADD.L	D7,A0
	
	MOVE.L	ADR_ECR,A1
	ADD.L	#32000+20*160,A1
	REPT	16
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	ADD.L	#136,A1
	ENDR
	

	MOVE.W	NE_P_EN_C,D7
	MULU.W	#24*18,D7
	LEA	NEXT_PIECE,A0
	ADD.L	#16*24*4,A0
	ADD.L	D7,A0
	
	MOVE.L	ADR_ECR,A1
	ADD.L	#32000,A1
	REPT	18
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	ADD.L	#136,A1
	ENDR
	MOVEM.L	(SP)+,D7/A0-A1
AFF_NE_END:
	RTS
;************************************
;	gestion des touches	    *
;************************************
GERE_TOUCHE:	
	MOVEM.L	D0-D7/A0-A6,-(SP)
	
	MOVE.B	$FFFC02,D0	; ici on gere si la touche anciennement 
				; pressee a ete relachee si oui on accepte
				; celle qui est nouvellement pressee
				; sinon on attend qu'elle soit relachee
	CMP.B	#$39,D0
	BEQ	PAUSE

	MOVE.B	ANC_TOUCHE,D1
	CMP.B	D0,D1
	BNE	OK_TOUCHE
	
	TST.W	TPS_DEP
	BEQ	OK_TOUCHE	
	SUB.W	#1,TPS_DEP
	BNE	GER0
OK_TOUCHE:	
	MOVE.B	D0,ANC_TOUCHE
	
	CMP.B	#$4B,D0		; les touches flechees <-
	BEQ	G3
	
	CMP.B	#$4D,D0		; ->
	BEQ	G4
	
	CMP.B	#$50,D0		; bas
	BEQ	G5
	
	CMP.B	#$48,D0		; haut
	BEQ	G6

	
	MOVE.W	PAS_DEP_TOU,TPS_DEP ; si on a pas presse de touche de dep
				; on le pourra a la prochaine vbl
GER0:
;*********************************
  	MOVE.B	WAIT_CLAV,D1
  	BEQ	GER
	
	CMP.B	D1,D0
	BEQ	FIN_GERE
	
	MOVE.B	#0,WAIT_CLAV
	
GER:	MOVE.B	D0,WAIT_CLAV

	CMP.B	#$10,D0		; rotation de la piece
	BEQ	G0
	
	CMP.B	#$11,D0		; rotation vers la gauche 
	BEQ	G1		; de l'ecran

	CMP.B	#$12,D0		; cette fois ci vers la droite
	BEQ	G2
	
FIN_GERE:	
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS
	
G0:			; partie qui gere quand il y a 
	CLR.L	D0	; une rotation de piece si cette piece ne
	CLR.L	D1	; rentre pas en collision avec le 'decor'
	CLR.L	D2	; une fois tournee
	CLR.L	D3
	CLR.L	D4
	CLR.L	D5
			
	MOVE.W	X,D0	; s'il y a collision on annule la rotation
	MOVE.W	X,D6
	MOVE.W	Y,D1	
	MOVE.W	Y,A1	; drole de facon de sauvegarder un registre !

	MOVE.W	NUM_ECRAN,D2	; d'apres l'ecran en cours on choisit
	
	MOVE.W P_EN_C,D3
	MOVE.W R_EN_C,D4
	
	SUBQ.W	#1,D4
	BGE	G0_1
	MOVE.W	#3,D4
G0_1:	
	
	CMPI.W	#29,D0		; qd on fait une rotation de la piece
	BMI	G0_3		; il ne faut pas que la rotation
				; suivante sorte de l'ecran 
	MOVE.L	XM_EN_C,A0	; --> on teste si la rotation correspond
	MOVE.W	D3,D5		; avec x max --> si oui ok!
	MULU.W	#8,D5		; sinon on met x max dans x et on teste
	ADD.L	D5,A0
	MOVE.W	D4,D5
	MULU.W	#2,D5
	ADD.L	D5,A0
	CLR.L	D5
	MOVE.W	(A0),D5
	
	CMP.W	D5,D0
	BLE	G0_3
	
	MOVE.W	D5,D0
	MOVE.W	D5,D6
	
G0_3:
	CMPI.W	#29,D1		; qd on fait une rotation de la piece
	BMI	G0_5		; il ne faut pas que la rotation
				; suivante sorte de l'ecran 
	MOVE.L	YM_EN_C,A0	; --> on teste si la rotation correspond
	MOVE.W	D3,D5		; avec y max --> si oui ok!
	MULU.W	#8,D5		; sinon on met y max dans y et on teste
	ADD.L	D5,A0
	MOVE.W	D4,D5
	MULU.W	#2,D5
	ADD.L	D5,A0
	CLR.L	D5
	MOVE.W	(A0),D5
	
	CMP.W	D5,D1
	BLE	G0_5
	
	MOVE.W	D5,D1
	MOVE.W	D5,A1

G0_5:	CLR.L	D5
	JSR	TEST_COLLISION
	
	TST.W	D5
	BNE	G0_6
	MOVE.W	D6,X
	MOVE.W	A1,Y
	MOVE.W	D4,R_EN_C
G0_6:	BRA	FIN_GERE

;******************************************************
	
G1:	
	CLR.L	D0
	CLR.L	D1	
	CLR.L	D2	
	CLR.L	D3
	CLR.L	D4	
	
	MOVE.W	X,D0
	MOVE.W	Y,D1	
			
	MOVE.W	NUM_ECRAN,D2	
	SUBQ.W	#1,D2
	TST.W	D2
	BNE	G1_0
	MOVE.W	#4,D2
G1_0:
	MOVE.W P_EN_C,D3
	MOVE.W R_EN_C,D4

	JSR	TEST_COLLISION
	
	TST.W	D5
	BEQ	G1_1
	MOVE.W	#0,WAIT_CLAV
	BRA	FIN_GERE
	
G1_1:

	MOVEQ.L	#0,D0		; on tourne ds le sens inverse des
	MOVE.W	NUM_ECRAN,D0	; aiguilles d'une montre
	SUBQ.W	#1,D0
	BNE	G1_2
	
	MOVE.W	#4,D0
G1_2:	MOVE.W	D0,NUM_ECRAN
	SUBQ.W	#1,D0		; bcp d'instruc sont inutiles
	LEA	ECRAN1,A0	; mais j'ai pas sp‚cialement 
	LSL.W	#2,D0		; envie de modif quoi
	ADD.L	D0,A0		; que ce soit....

	MOVE.L	(A0),ADR_ECR	
	JSR	NVEL_ECR

;	JSR	WAIT_SYNC
	
	LEA	INSTRUC,A0	; affichage piece a sa derniere pos
	MOVE.W	X,(A0)		; au cas ou elle aurait bouge ou aurait
	MOVE.W	Y,2(A0)		; subit une rotation
	MOVE.W	P_EN_C,4(A0)	
	MOVE.W	R_EN_C,6(A0)	
	MOVE.W	#1,8(A0) 	
	MOVE.L	ADR_ECR,10(A0)
	MOVE.W	#0,14(A0)
	BSR	AFF_PIECE

	;JSR	WAIT_SYNC

	
	BRA	FIN_GERE

;*******************************************
G2:	
	CLR.L	D0
	CLR.L	D1	
	CLR.L	D2	
	CLR.L	D3
	CLR.L	D4	
	
	MOVE.W	X,D0
	MOVE.W	Y,D1	
			
	MOVE.W	NUM_ECRAN,D2	
	ADDQ.W	#1,D2
	CMP.W	#5,D2
	BNE	G2_0
	MOVE.W	#1,D2
G2_0:
	MOVE.W P_EN_C,D3
	MOVE.W R_EN_C,D4

	JSR	TEST_COLLISION
	
	TST.W	D5
	BEQ	G2_1
	MOVE.W	#0,WAIT_CLAV
	BRA	FIN_GERE
G2_1:	
	MOVEQ.L	#0,D0		; cette fois ci dans le 'bon' sens
	MOVE.W	NUM_ECRAN,D0
	ADDQ.W	#1,D0
	CMPI.W	#5,D0
	BNE	G2_2
	
	MOVE.W	#1,D0
	
G2_2:	MOVE.W	D0,NUM_ECRAN
	SUBQ.W	#1,D0
	LEA	ECRAN1,A0
	LSL.W	#2,D0
	ADD.L	D0,A0
	
	
	MOVE.L	(A0),ADR_ECR
	JSR	NVEL_ECR


	LEA	INSTRUC,A0	; affichage piece a sa derniere pos
	MOVE.W	X,(A0)		; au cas ou elle aurait bouge ou aurait
	MOVE.W	Y,2(A0)		; subit une rotation
	MOVE.W	P_EN_C,4(A0)	
	MOVE.W	R_EN_C,6(A0)	
	MOVE.W	#1,8(A0) 	
	MOVE.L	ADR_ECR,10(A0)
	MOVE.W	#0,14(A0)
	BSR	AFF_PIECE

;	JSR	WAIT_SYNC


	BRA	FIN_GERE

;********************************************
G3:	
	TST.W	PAS_X		; gauche 
	BNE	G3_3

	CLR.W	D1
	MOVE.B	JOUAB,D1
	CMP.B	D0,D1		; POUR AMELIORER LA JOUABILITE
	BEQ	G3_0
	MOVE.B	D0,JOUAB
	MOVE.B	#1,JOUAB1
	BRA	G3_01
	
G3_0:	
	CMP.B	#4,JOUAB1	
	BEQ	G3_01
	ADDQ.B	#1,JOUAB1
	MOVE.W	#1,TPS_DEP  
	BRA	FIN_GERE
G3_01:	

	MOVE.B	#0,WAIT_CLAV
	MOVE.W	PAS_DEP_TOU,TPS_DEP
	
	CLR.L	D0	; on veut aller vers la gauche est-ce possible?
	MOVE.W	X,D0	
	
	SUBQ.W	#1,D0
	BNE	G3_1
	
	MOVEQ.W	#1,D6
	BRA	G3_2
G3_1:
	CLR.L	D1	
	CLR.L	D2	
	CLR.L	D3
	CLR.L	D4	
	
	MOVE.W	Y,D1	
			
	MOVE.W	NUM_ECRAN,D2	
	
	MOVE.W P_EN_C,D3
	MOVE.W R_EN_C,D4

	MOVE.W	D0,D6
	JSR	TEST_COLLISION
	
	TST.W	D5
	BEQ	G3_2
	ADDQ.W	#1,D6
G3_2:	MOVE.W	D6,X
G3_2_1:	BRA	FIN_GERE

G3_3:	
	MOVE.W	#1,TPS_DEP  ;prochaine vbl on pourra presser une touche
	
	CMP.W	#-1,PAS_X
	BNE	FIN_GERE
	
	MOVE.W	PAS_DEP_TOU,TPS_DEP  ; si la piece va vers droite
	MOVE.B	#0,WAIT_CLAV	  ; et que l'on veut accelerer
	MOVE.W	#1,VITESSE
	
	ADD.W	#1,SCORE_P	 ;bonus acceleration
	
	BRA	FIN_GERE
	
;******************************************************
G4:	TST.W	PAS_X		  ; droite
	BNE	G4_3

	CLR.W	D1
	MOVE.B	JOUAB,D1
	CMP.B	D0,D1		; POUR AMELIORER LA JOUABILITE
	BEQ	G4_0
	MOVE.B	D0,JOUAB
	MOVE.B	#1,JOUAB1
	BRA	G4_02
	
G4_0:	
	CMP.B	#4,JOUAB1
	BEQ	G4_02
	ADD.B	#1,JOUAB1
	MOVE.W	#1,TPS_DEP              
	BRA	FIN_GERE
G4_02:
	MOVE.B	#0,WAIT_CLAV
	MOVE.W	PAS_DEP_TOU,TPS_DEP
	
	CLR.L	D0	; on veut aller vers la droite est-ce possible?
	MOVE.W	X,D0	
	
	ADDQ.W	#1,D0
	
	CMP.W	#29,D0
	BMI	G4_1
				;********************
	MOVE.L	XM_EN_C,A0	; ici on teste si la piece en allant
	CLR.L	D1		; … droite ne va pas sortir de l'ecran
	MOVE.W	P_EN_C,D1	; et ce selon la piece
	MULU.W	#8,D1
	ADD.L	D1,A0
	CLR.L	D2
	MOVE.W	R_EN_C,D2
	MULU.W	#2,D2
	ADD.L	D2,A0
	
	CLR.L	D1
	MOVE.W	(A0),D1
	
	CMP.W	D1,D0
	BLE	G4_1
	
	MOVE.W	D1,D6
	BRA	G4_2
G4_1:
	CLR.L	D1		; ensuite on teste s'il y a une
	CLR.L	D2		; collision avec le decor
	CLR.L	D3
	CLR.L	D4	
	
	MOVE.W	Y,D1	
			
	MOVE.W	NUM_ECRAN,D2	
	
	MOVE.W P_EN_C,D3
	MOVE.W R_EN_C,D4

	MOVE.W	D0,D6
	JSR	TEST_COLLISION
	
	TST.W	D5
	BEQ	G4_2
	SUBQ.W	#1,D6	; <-- il y a collision
G4_2:	MOVE.W	D6,X	
G4_2_1:
	BRA	FIN_GERE

G4_3:	
	MOVE.W	#1,TPS_DEP  
	
	TST.W	PAS_X
	BMI	FIN_GERE
	
	MOVE.W	PAS_DEP_TOU,TPS_DEP  ; si la piece va vers gauche
	MOVE.B	#0,WAIT_CLAV	  ; et que l'on veut accelerer
	MOVE.W	#1,VITESSE
	
	ADD.W	#1,SCORE_P	 ;bonus acceleration
	BRA	FIN_GERE
;**********************************************
G5:	
	TST.W	PAS_Y
	BNE	G5_3

	CLR.W	D1
	MOVE.B	JOUAB,D1
	CMP.B	D0,D1		; POUR AMELIORER LA JOUABILITE
	BEQ	G5_0
	MOVE.B	D0,JOUAB
	MOVE.B	#1,JOUAB1
	BRA	G5_01
	
G5_0:	
	CMP.B	#4,JOUAB1
	BEQ	G5_01
	ADDQ.B	#1,JOUAB1
	MOVE.W	#1,TPS_DEP  
	BRA	FIN_GERE
G5_01:	


	MOVE.B	#0,WAIT_CLAV
	MOVE.W	PAS_DEP_TOU,TPS_DEP
	
	CLR.L	D1	; on veut aller vers le bas est-ce possible?
	MOVE.W	Y,D1	
	ADDQ.W	#1,D1
	
	CMP.W	#29,D1
	BMI	G5_1
				;***********************************	
	MOVE.L	YM_EN_C,A0	; ici on teste si la piece en allant
	CLR.L	D0		; en bas ne va pas sortir de l'ecran
	MOVE.W	P_EN_C,D0	; et ce selon la piece
	MULU.W	#8,D0
	ADD.L	D0,A0
	CLR.L	D0
	MOVE.W	R_EN_C,D0
	MULU.W	#2,D0
	ADD.L	D0,A0
	
	CLR.L	D0
	MOVE.W	(A0),D0
	
	CMP.W	D0,D1
	BLE	G5_1
	
	MOVE.W	D0,D6
	
	BRA	G5_2
G5_1:
	CLR.L	D0	
	CLR.L	D2	
	CLR.L	D3
	CLR.L	D4	
	
	MOVE.W	X,D0	
	
	MOVE.W	NUM_ECRAN,D2	
	
	MOVE.W P_EN_C,D3
	MOVE.W R_EN_C,D4

	MOVE.W	D1,D6
	JSR	TEST_COLLISION
	
	TST.W	D5
	BEQ	G5_2
	SUBQ.W	#1,D6
G5_2:	MOVE.W	D6,Y
	BRA	FIN_GERE

G5_3:	
	MOVE.W	#1,TPS_DEP
	
	TST.W	PAS_Y
	BMI	FIN_GERE
	
	MOVE.W	PAS_DEP_TOU,TPS_DEP  ; si la piece va vers droite
	MOVE.B	#0,WAIT_CLAV	     ; et que l'on veut accelerer
	MOVE.W	#1,VITESSE
	ADD.W	#1,SCORE_P	 ;bonus acceleration
	BRA	FIN_GERE
;****************************************************
;****************************************************
G6:	
	TST.W	PAS_Y
	BNE	G6_3

	CLR.W	D1
	MOVE.B	JOUAB,D1
	CMP.B	D0,D1		; POUR AMELIORER LA JOUABILITE
	BEQ	G6_0
	MOVE.B	D0,JOUAB
	MOVE.B	#1,JOUAB1
	BRA	G6_02
	
G6_0:	
	CMP.B	#4,JOUAB1
	BEQ	G6_02
	ADD.B	#1,JOUAB1
	MOVE.W	#1,TPS_DEP              
	BRA	FIN_GERE
G6_02:

	MOVE.B	#0,WAIT_CLAV
	MOVE.W	PAS_DEP_TOU,TPS_DEP
	
	CLR.L	D1	; on veut aller vers le haut est-ce possible?
	MOVE.W	Y,D1	
	SUBQ.W	#1,D1
	
	BNE	G6_1
	
	MOVEQ.W	#1,D6
	BRA	G6_2
G6_1:
	CLR.L	D0	
	CLR.L	D2	
	CLR.L	D3
	CLR.L	D4		
	
	MOVE.W	X,D0	
	
	MOVE.W	NUM_ECRAN,D2	
	
	MOVE.W P_EN_C,D3
	MOVE.W R_EN_C,D4

	MOVE.W	D1,D6
	JSR	TEST_COLLISION
	
	TST.W	D5
	BEQ	G6_2
	ADDQ.W	#1,D6
G6_2:	MOVE.W	D6,Y
	BRA	FIN_GERE

G6_3:	
	MOVE.W	#1,TPS_DEP
	
	CMP.W	#-1,PAS_Y
	BNE	FIN_GERE
	
	MOVE.W	PAS_DEP_TOU,TPS_DEP  ; si la piece va vers haut
	MOVE.B	#0,WAIT_CLAV	  ; et que l'on veut accelerer
	MOVE.W	#1,VITESSE
	ADD.W	#1,SCORE_P	 ;bonus acceleration
	BRA	FIN_GERE

PAUSE:	
	MOVE.L	#PAUSE_SON+128,-(SP)	; un petit son
	MOVE.L	#PAUSE_SON+128+13180,-(SP) 	; qd on met une pause
	JSR	GO_DMA_SOUND
	ADDQ.L	#8,SP

PAUSE2:	CMPI.B	#$39+$80,$FFFFFC02
	BNE	PAUSE2
	
	MOVE.W	TIME,D6
	CLR.W	TIME

PAUSE2_1:CMPI.B	#$0E,$FFFFFC02
	BNE	PAUSE3
	
PAUSE2_3:	
	CMPI.B	#$39,$FFFFFC02
	BEQ	PAUSE4
	
	CMPI.B	#$02,$FFFFFC02
	BNE	PAUSE2_3
		
	
	TST.W	NB_LIG
	BEQ	PAUSE3
	
	MOVE.W	NB_LIG,D7		; tiens tiens ??!!
	SUBQ.W	#1,D7
	MOVE.W	D7,NB_LIG
	JSR	CONVERSION
	
	JSR	AFFNBLIG	
	
PAUSE2_2:CMPI.B	#$0E+$80,$FFFFFC02
	BNE	PAUSE2_2
	

PAUSE3:	CMPI.B	#$39,$FFFFFC02
	BNE	PAUSE2_1

PAUSE4:	CMPI.B	#$39+$80,$FFFFFC02
	BNE	PAUSE4

	MOVE.W	D6,TIME

	BRA	FIN_GERE

;**********************************
X_MAX:	DC.W	31,31,31,31	; table donnant le x max qu'une
	DC.W	31,30,31,30	; piece peut avoir si x lui etait
	DC.W	31,30,31,30	; sup elle sortirait de l'ecran
	DC.W	29,32,29,32
	DC.W	30,30,30,31
	DC.W	30,30,30,31
	DC.W	30,30,30,31

Y_MAX:	DC.W	31,31,31,31	; pareil avec le y 
	DC.W	30,31,30,31
	DC.W	30,31,30,29
	DC.W	32,29,32,29
	DC.W	31,30,31,30
	DC.W	31,30,30,30
	DC.W	31,30,30,30
		
X_MAX2:	DC.W	30,30,30,30	; x et y max pour le jeu
	DC.W	30,30,30,30	
	DC.W	30,30,30,30	
	DC.W	30,30,30,30	; de piece 2
	DC.W	30,30,30,30
	DC.W	30,30,30,30
	DC.W	31,29,31,29

Y_MAX2:	DC.W	30,30,30,30
	DC.W	30,30,30,30
	DC.W	30,30,30,30
	DC.W	30,30,30,30
	DC.W	30,30,30,30
	DC.W	30,30,30,30
	DC.W	29,31,29,31
	
		
;*******************************************
;*      test de collision piece-decor      *
;*******************************************
TEST_COLLISION:
	; cette routine test si une piece entre en collision avec le decor
	; pour cela on envoit: 
	;               x dans d0
	;               y dans d1
	;               le numero de l'ecran dans d2
	;		numero de la piece dans d3
	;		rotation de la piece dans d4
	; au retour on a 
	; l'adresse de la piece dans la repres memoire dans d0
	; l'adresse de la repres en memoire de la piece dans d1
	; dans d5 le resultat du test cad  0 si ok  1 si collision
	; voila c'est tout!

	MOVEM.L	D6/A0/A1,-(SP)
				; d'apres l'ecran en cours on choisit
	SUBQ.W	#1,D2		; la repres en memoire
	LEA	DAT_0,A0	
	MULU.W	#1024,D2	; a changer
	ADD.L	D2,A0
	
	CLR.L	D2
	
	MOVE.W	D1,D2		; calcul ligne en memoire
	SUBQ.W	#1,D2
	;ROL.W	#5,D2
	MULU.W	#32,D2
	ADD.L	D2,A0
	SUBQ.W	#1,D0
	ADD.L	D0,A0		; ajout position x
	
	MOVE.L	JEU_P_EN_C,A1
	MOVE.W	D3,D2
	ROL.W	#6,D2
	ADD.L	D2,A1
	MOVE.W	D4,D2
	ROL.W	#4,D2
	ADD.L	D2,A1
	
	MOVE.L	A0,D0
	MOVE.L	A1,D1
	
	MOVE.W	#3,D6
	MOVEQ.L	#0,D5
TC:	
	TST.B	(A1)+
	BEQ	TC1
	TST.B	(A0)
	BEQ	TC1	
	MOVE.W	#1,D5
TC1:	 
	TST.B	(A1)+
	BEQ	TC2
	TST.B	1(A0)
	BEQ	TC2
	MOVE.W	#1,D5
TC2:	
	TST.B	(A1)+
	BEQ	TC3
	TST.B	2(A0)
	BEQ	TC3
	MOVE.W	#1,D5
TC3:	
	TST.B	(A1)+
	BEQ	TC4
	TST.B	3(A0)
	BEQ	TC4	
	MOVE.W	#1,D5
TC4:	
	ADD.L	#32,A0
	DBRA	D6,TC

	TST.W	D5		; y a t-il collision ?
	BNE	TC10		; oui on sort pas la peine de continuer
	
	CMP.W	#3,VITESSE	; 3 pour laisser une marge au joueur pour
				; se deplacer s'il est entre 2 cases
				; ou doit bouger une piece au dernier moment
	BMI	TC10		; est-ce que l'on se trouve entre 2 cases ?
	
	
	MOVE.L	D1,A1		; oui ! alors on teste si la case precedente	
	MOVE.L	D0,A0		; est occupee
	CLR.L	D6
	MOVE.W	PAS_X,D6
	BEQ	TC4_2
	BMI	TC4_1
	SUB.L	#1,A0
	BRA	TC4_2
TC4_1:	ADD.L	#1,A0

TC4_2:	
	MOVE.W	PAS_Y,D6
	BEQ	TC4_4
	BMI	TC4_3
	SUB.L	#32,A0
	BRA	TC4_4
TC4_3:	ADD.L	#32,A0
TC4_4:
	MOVE.W	#3,D6
	MOVEQ.L	#0,D5
TC5:	
	TST.B	(A1)+
	BEQ	TC6
	TST.B	(A0)
	BEQ	TC6
	MOVE.W	#1,D5
TC6:	 
	TST.B	(A1)+
	BEQ	TC7
	TST.B	1(A0)
	BEQ	TC7
	MOVE.W	#1,D5
TC7:	
	TST.B	(A1)+
	BEQ	TC8
	TST.B	2(A0)
	BEQ	TC8
	MOVE.W	#1,D5
TC8:	
	TST.B	(A1)+
	BEQ	TC9
	TST.B	3(A0)
	BEQ	TC9	
	MOVE.W	#1,D5
TC9:	
	ADD.L	#32,A0
	DBRA	D6,TC5
	
			; si oui alors il y a collision 
TC10:	

	MOVEM.L	(SP)+,D6/A0/A1
	RTS

;****************************************************
;	    routine d'affichage d'une piece         *
;   (elle efface si necessaire la piece precedente) *
;****************************************************
RESTORE_FOND:	MOVEM.L	A1/A2,-(SP)

	MOVE.L	ADR_FOND,A1	
	LEA	FOND,A2
	
	REPT	32
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	ADD.L	#136,A1
	ENDR

	MOVEM.L	(SP)+,A1/A2
	RTS
;************************************************
AFF_PIECE:	MOVEM.L	D0-D3/A0-A3,-(SP)

	LEA	INSTRUC,A0
	
	TST.W	8(A0)		; doit on restaurer le fond ??
	BEQ	AF_1	
	
	MOVE.L	ADR_FOND,A1	; oui !!
	LEA	FOND,A2
	
	REPT	32
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	ADD.L	#136,A1
	ENDR

AF_1:	
	MOVE.L	GFX_EN_C,A1	; calcul de la piece a afficher
	MOVE.W	4(A0),D0
	MOVE.W	6(A0),D1
	MULU.W	#32*16*4,D0
	MULU.W	#32*16,D1
	ADD.L	D0,A1
	ADD.L	D1,A1

	MOVE.L	10(A0),A2	; adresse de l'ecran ou l'on affiche
	ADD.L	#24,A2
	
	MOVE.W	(A0),D0		; tout ceci est a optimiser
	SUBQ.W	#1,D0		; de nbx mulu et divu ne sont pas
	MULU.W	#8,D0		; necessaire.
	
	TST.W	PAS_X
	BEQ	AF_1_0
	BMI	AFP_1
	SUB.W	VITESSE,D0
	BRA	AF_1_0
AFP_1:	ADD.W	VITESSE,D0
AF_1_0:	
	DIVU.W	#16,D0
	MOVE.L	D0,D1
	SWAP	D1
	AND.L	#$FFFF,D0
	MULU.W	#8,D0
	ADD.L	D0,A2
	
	MOVEQ.L	#0,D0
	MOVE.W	2(A0),D0
	SUBQ.W	#1,D0
	MULU.W	#8*160,D0
	ADD.L	D0,A2
	
	TST.W	PAS_Y
	BEQ	AF_1_1
	BMI	AFP_2
	
	MOVE.W	VITESSE,D0
	MULU.W	#160,D0
	SUB.L	D0,A2
	BRA	AF_1_1
AFP_2:
	MOVE.W	VITESSE,D0
	MULU.W	#160,D0
	ADD.L	D0,A2
AF_1_1:	
	MOVE.L	A2,ADR_FOND
	LEA	FOND,A3
	
	MOVE.W	#31,D2		; routine d'affichage d'une piece
AF_2:				
	
	MOVE.L	(A2),(A3)+	; sauvegarde du fond
	MOVE.L	4(A2),(A3)+	; avant affichage de la piece
	MOVE.L	8(A2),(A3)+
	MOVE.L	12(A2),(A3)+
	MOVE.L	16(A2),(A3)+
	MOVE.L	20(A2),(A3)+
	
	REPT	8		; et ici on l'affiche
	CLR.L	D3
	MOVE.W	(A1)+,D3
	ROR.L	D1,D3
	OR.W	D3,(A2)+
	SWAP	D3
	OR.W	D3,6(A2)
	ENDR
	ADD.L	#144,A2
	DBRA	D2,AF_2
	
	MOVEM.L	(SP)+,D0-D3/A0-A3
	RTS

*	LEA	packed_file's_address,A0
*	LEA	address_to_depack_to,A1
*	BSR	DEPACK

DEPACK	addq.l	#4,a0
	MOVEA.L	A0,A4
	MOVE.L	(A0)+,D5
	ADDA.L	D5,A1
	ADDA.L	(A0),A0
	SUBA.L	#4,A0

* HAH HAH. Has to do this because it's only here to even out
* the file before saving.

	TST.W	-(A0)			Test if it's a dummy.
	BPL.S	L652BC			NO. Valid data.
	SUBQ.L	#1,A0			Adjust it.

* If first BIT is zero then do REPEATS
* ELSE do junk.
* Doesn't this look familiar. THUNDER packers always use the
* first bit to test for for junk.
   
L652BC	MOVE.B	-(A0),D0
L652BE	LSL.B	#1,D0
	BNE.S	L652C6
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L652C6	BCC.S	L65322			Go do the REPEATS.

* Hey up. What's this! A BYTE table in the packed file.
* TUT TUT. Didn't THUNDER v2.0 first use this technique?

* There's a lot of junk code in this routine. There really
* isn't any need for most of this shit. It's purely a smoke
* screen. It looks clever. What it all boils down to is
* to collect the size of a block of junk. Simple eh!!
* Of course, when you've stolen the routine from elsewhere
* it's best to try and hide the fact!!

	CLR.W	D1			Clear size count.
	LSL.B	#1,D0
	BNE.S	L652D2
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L652D2	BCC.S	L65316			If ZERO then its a 1 byte repeat

	LEA	L6530E(PC),A3		Lower table? BIT sizes.
	MOVEQ	#3,D3			Initial index.
L652DA	CLR.W	D1			Clear size count.
	MOVE.B	0(A3,D3.W),D2		Get the BITsize.
	EXT.W	D2			Clear the crap.
	MOVEQ	#-1,D4			Set all the bits.
	LSL.W	D2,D4			Fill with X zero bits.
	NOT.W	D4			Invert the BITS.
	SUBQ.W	#1,D2			Adjust bit size.

* Now collect D2 many bits.
* Used as an index into the UPPER table. (ADJUSTMENTS).

L652EA	LSL.B	#1,D0
	BNE.S	L652F2
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L652F2	ROXL.W	#1,D1			Collect the size.
	DBF	D2,L652EA

	TST.W	D3			??? No zeroes in the table.
	BEQ.S	L65302
	CMP.W	D1,D4
	DBNE	D3,L652DA
L65302	MOVE.B	4(A3,D3.W),D2		Upper table. ADJUSTMENTS.
	EXT.W	D2			Clear crap.
	ADD.W	D2,D1			Adjust JUNK's count size.
	BRA.s	L65316

L6530E	DC.B	$A,3,2,2,$E,7,4,1

L65316	MOVE.B	-(A0),-(A1)		Transfer BYTES of junk.
	DBF	D1,L65316

L65322	MOVEA.L	A4,A3
	ADDQ.L	#8,A3
	CMPA.L	A3,A0
	BLE	gohome
	LEA	L65368(PC),A3		Little table.
	MOVEQ	#3,D2
L65332	LSL.B	#1,D0
	BNE.S	L6533A
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L6533A	BCC.S	L65340
	DBF	D2,L65332

L65340	CLR.W	D1
	ADDQ.W	#1,D2
	MOVE.B	0(A3,D2.W),D3		Get the BIT size.
	BEQ.S	L6535C			If ZERO no more bit to collect.
	EXT.W	D3			Clear the crap.
	SUBQ.W	#1,D3			Adjust for looping

L6534E	LSL.B	#1,D0
	BNE.S	L65356
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L65356	ROXL.W	#1,D1
	DBF	D3,L6534E

L6535C	MOVE.B	5(A3,D2.W),D3		Get any ADJUSTMENTS.
	EXT.W	D3
	ADD.W	D3,D1
	BRA.s	L65372			Go to normal REPEAT routine.

L65368	DC.B	$A,2,1,0,0,$A,6,4	Little table.
	DC.B	3,2

* This is one way of doing it!!!
* Enters with the REPEATS size in D1.
* If size is 2 then skip routine below and use the small
* table in A3. Else the routine use the big offset table.
* The routine index's 0,1,2 bytes into the offsets in the big table.

L65372	CMPI.W	#2,D1			2byte repeat.
	BEQ.S	rep			Yeh. Use A3's small table.
	LEA	L653AC(PC),A3		ELSE use the big table.
	MOVEQ	#1,D3			Only two bits to collect.
L6537E	LSL.B	#1,D0
	BNE.S	L65386
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0

* If first bit is zero then exit. This stops D3 being decemented
* and allows access to another byte (3rd byte) in the table.

L65386	BCC.S	L6538C			If first bit zero then leave
	DBF	D3,L6537E
L6538C	ADDQ.W	#1,D3			Adjust index into the table.
	CLR.W	D2			UGH!!
	MOVE.B	0(A3,D3.W),D4		Fetch offset's bitsize.
	EXT.W	D4			Clear the crap.

* Now it actually manges to get round to the offset!!
* This time it index's the other half of the BIG offset table.
* The other half of the table contains ADJUSTMENT's to the
* actual offsets. They are accessed via D3. Both tables are aligned.
* If you don't need any adjustments just index the ZERO byte!!
* 6 bytes in lower table.
* 6 bytes in upper table.  The ADJUSTMENT's to the offset.

L65396	LSL.B	#1,D0
	BNE.S	L6539E
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L6539E	ROXL.W	#1,D2			Collect offset.
	DBF	D4,L65396
	LSL.W	#1,D3			Align with upper table.
	ADD.W	4(A3,D3.W),D2		Add the adjustment to the offset.
	BRA.S	L653DC			Go to MAIN repeat routine.

L653AC	DC.B	$B,4,7,0,1,$20		Offset bit sizes.
	DC.B	0,0,0,$20,0,0		Adjustments to the offsets.

					* Repeated strings subroutine.

rep	CLR.W	D2			Clear offset register.
	MOVEQ	#5,D3			SMALL 6bit offset
	CLR.W	D4			Set the ADJUSTER.
	LSL.B	#1,D0
	BNE.S	L653C6
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L653C6	BCC.S	L653CC			If CLEAR then small offset.
	MOVEQ	#8,D3			LARGE 9bit offset.
	MOVEQ	#$40,D4			Set the ADJUSTER.

* Collect the offset.

L653CC	LSL.B	#1,D0
	BNE.S	L653D4
	MOVE.B	-(A0),D0		Reload the data register.
	ROXL.B	#1,D0			and shift first bit.
L653D4	ROXL.W	#1,D2			Collect the offset.
	DBF	D3,L653CC

	ADD.W	D4,D2			Add any ADJUSTER to offset.
L653DC	LEA	0(A1,D2.W),A2		Calc address of repeated string.
	EXT.L	D1			Clear the shit in the LENGTH.
	ADDA.L	D1,A2			LENGTH + address = string end.
	SUBQ.W	#1,D1			Adust LENGTH for looping.
L653E6	MOVE.B	-(A2),-(A1)		Transfer the bytes.
	DBF	D1,L653E6
	BRA	L652BE
gohome	RTS

	SECTION	DATA
PIECES:		INCBIN	"A:\MADTRIS.SRC\PIECES2.DAT"
		INCBIN	"A:\MADTRIS.SRC\START_P.DAT"
PIECES2:	INCBIN  "A:\MADTRIS.SRC\PIECES3_2.DAT"
		INCBIN	"A:\MADTRIS.SRC\START_P.DAT"
DECOR:		INCBIN	"A:\MADTRIS.SRC\TETRIS.DAT"
PALETTE:	INCBIN	"A:\MADTRIS.SRC\TETRIS.PAL"
CHIFFRE:	INCBIN  "A:\MADTRIS.SRC\CHIFFRES.DAT"
		DC.L	0,0
NEXT_PIECE:	INCBIN  "A:\MADTRIS.SRC\NEXT.DAT"
FONTE:		INCBIN  "A:\MADTRIS.SRC\WEAPONS.DAT"

HELPFONTE: 	INCBIN  "A:\MADTRIS.SRC\FONTE1PL.DAT"
FTEXT:		INCBIN  "A:\MADTRIS.SRC\INSTRUCT.DAT"
ETEXT:		INCBIN  "A:\MADTRIS.SRC\INSTRUCE.DAT"
CHX_HLP:	INCBIN 	"A:\MADTRIS.SRC\CHOIXHLP.DAT"

OVER_PIC:	INCBIN 	"A:\MADTRIS.SRC\GAMEOVER.DAT"
SYLVAIN:	INCBIN 	"A:\MADTRIS.SRC\PRES1.PI1"
YAHA1:		INCBIN  "A:\MADTRIS.SRC\END.DAT"
YAHA2:		INCBIN 	"A:\MADTRIS.SRC\YAHA2.DAT"
THALION:	INCBIN 	"A:\MADTRIS.SRC\THALION.DAT"
		DCB.L	32,0
PAGE1:		INCBIN 	"A:\MADTRIS.SRC\PRESENT2.PI1"
PAGE2:		INCBIN 	"A:\MADTRIS.SRC\PRESENT.DAT"
NEWPRES:	INCBIN	"A:\MADTRIS.SRC\NEWPRES.SPR"
EXPLOSE:	INCBIN 	"A:\MADTRIS.SRC\EXPLOSIF.AVR"
PHUNG:		INCBIN 	"A:\MADTRIS.SRC\PHUNG.AVR"
REBOND:		INCBIN	"A:\MADTRIS.SRC\REBOND.AVR"
TOUCHE:		INCBIN	"A:\MADTRIS.SRC\CLICK_1.AVR"
VIDE:		INCBIN	"A:\MADTRIS.SRC\VIDE.AVR"
PAUSE_SON:	INCBIN	"A:\MADTRIS.SRC\BUTTONS2.AVR"

PRES_HIGH:	INCBIN	"A:\MADTRIS.SRC\HIGHSCOR.DAT"
TAB_CORRESP:	INCBIN	"A:\MADTRIS.SRC\CONVERTA.TAB"
HIGHLOGO:	INCBIN	"A:\MADTRIS.SRC\HIGHSCOR.SPR"
HIGHTYPE:	DC.B	'MADTRIS.HGH',0    
FLAG_SAVHIGH:	DC.W	0
NONAME:		INCBIN	"A:\MADTRIS.SRC\NONAME.DAT"
ERR_DISK:	INCBIN	"A:\MADTRIS.SRC\ERRDISK.DAT"
HIGH_TAB0:	INCBIN	"A:\MADTRIS.SRC\HIGH2.DAT"
		DC.W	$999
		DC.W	1000,2000,3000,4000,5000,6000,7000,8000,9000,10000

HAUT:		DC.W	0
TABFLECHE:	DC.L	SOUND,MODE
SOUND_M:	DC.W	1
MODE_M:		DC.W	0

OLD_SCREEN:	DC.L	0

SAVE_MES:	DC.L	0	; l… c'est le message aff au d‚but	
QUELLE_PIECE:	DC.W	0
PAS_DEP_TOU:	DC.W	0	; voici les parametres qui
PAS_DEP_PIE:	DC.W	0	; conditionnent la difficulte
NB_CARRE:	DC.W	0 	; d'un stage
;NB_A_FAIRE:	DC.W	0
NB_LIG:		DC.W	0	; l… le nombre de lignes en cours
TIME:		DC.W	0
COMPT_TIME:	DC.W	0
MAD:		DC.W	0	 
GHOST:		DC.W	0
GHOST_PAS:	DC.W	0
NEXT_B:		DC.W	0

GHOST_CMP:	DC.W	0

MAD_VAL:	DC.W	2

MES_OVER:	DC.B	1
		DC.B    1
		DC.B    '     GAME OVER     ',1
		DC.B	1
		DC.B	$FF

TIME_OUT_MES:	DC.B	1,1,1,1
		DC.B	'     TIME OUT      ',1 
		DC.B    1,1
		DC.B	'    A NEXT TIME    ',1
		DC.B	' TRY TO BE FASTER  ',1
		DC.B	'    IF YOU CAN     ',1
		DC.B	'     AH AH AH      ',1
		DC.B	$FF

;*************************
MES_PRES:	
		DC.B	1
		DC.B	1
		DC.B	'     GOOD  LUCK    ',1
		DC.B	1
		DC.B	1
		DC.B	'     BASH SPACE    ',1
		DC.B	1
		DC.B	'      TO BEGIN     ',1
		DC.B	'                   ',1
		DC.B	$FF
MES_DEPTT1:	
		DC.B	1
		DC.B	1
		DC.B	1
		DC.B	1
		DC.B	'     LITTLE BOY    ',1
		DC.B    1
		DC.B	'     DEPARTMENT    ',1
		DC.B	$FF

MES_DEPTT2:	
		DC.B	1
		DC.B	1
		DC.B	1
		DC.B	'        TIME        ',1
		DC.B	'     DEPARTMENT     ',1
		DC.B	1
		DC.B	'  YOU PLAY AGAINST  ',1
		DC.B	'      THE TIME      ',1
		DC.B	$FF

MES_DEPTT3:	
		DC.B	1
		DC.B	1
		DC.B	1
		DC.B	'       GHOSTS       ',1
		DC.B	'     DEPARTMENT     ',1
		DC.B	1
		DC.B	1
		DC.B	'  CAN YOU BEAT THE  ',1
		DC.B	'    GHOST BLOCKS    ',1
		DC.B	$FF
		
MES_DEPTT4:	DC.B	1
		DC.B	1
	        DC.B	'        FOOL        ',1
		DC.B    1
		DC.B	'     DEPARTMENT     ',1
		DC.B	1
		DC.B	'    OH  YOU  ARE    ',1
		DC.B	'     STILL HERE     ',1
		DC.B	$FF

MES_DEPTT5:	DC.B	'     SECOND SET     ',1
		DC.B	'     OF  BLOCKS     ',1 
		DC.B	1
		DC.B	'     WITH  SAME     ',1
		DC.B    '       LEVELS       ',1
		DC.B	1
		DC.B	'    WHAT ABOUT A    ',1 
		DC.B	'  A TRAINING STAGE  ',1
		DC.B	$FF


TRAIN_MES:	DC.B	1
		DC.B	1
		DC.B	'   TRAINING STAGE   ',1
		DC.B	'      BASH ESC      ',1
		DC.B	1	     
		DC.B	'  TO RETURN TO THE  ',1
		DC.B	'        MENU        ',1
		DC.B	$FF	     
		
MAX_TRAIN_MES:	DC.B	1
		DC.B	1
		DC.B	1
		DC.B	'   SPEED            ',1
		DC.B	'     GHOST          ',1
		DC.B    '       FOOL         ',1
		DC.B	1
		DC.B	1
		DC.B	'    WHO WANTS MORE  ',1
		DC.B	$FF
;*************************
MES1:		
		DC.B	1
		DC.B	1
		DC.B	'     LITTLE BOY     ',1
		DC.B	'     DEPARTMENT     ',1 
		DC.B	1
		DC.B	'     STAGE  ONE     ',1
		DC.B	1
		DC.B	'    BORING STAGE    ',1
		DC.B	1
		DC.B	$FF
	
MES2:		DC.B	1
		DC.B	1
		DC.B	'     LITTLE BOY     ',1
		DC.B	'     DEPARTMENT     ',1 
		DC.B	1
		DC.B	'     STAGE  TWO     ',1
		DC.B	$FF
	
MES3:		DC.B	1
		DC.B	'     LITTLE BOY     ',1
		DC.B	'     DEPARTMENT     ',1 
		DC.B	1
		DC.B	'    STAGE  THREE    ',1
		DC.B    1
		DC.B    ' DO YOU STILL THINK ',1
		DC.B    '   IT IS TOO EASY   ',1
		DC.B	$FF
	
MES4:		
		DC.B	'        TIME        ',1
		DC.B	'     DEPARTMENT     ',1 
		DC.B	1
		DC.B	'     STAGE  ONE     ',1
		DC.B	1
		DC.B	'      YOU HAVE      ',1
		DC.B    '  ONE HUNDRED SECS  ',1
		DC.B	'      TO  MAKE      ',1
		DC.B 	'     TEN  LINES     ',1
		DC.B	1
		DC.B	'   IT IS JUST THE   ',1  
		DC.B	'    FIRST  ROUND    ',1
		DC.B	$FF

MES5:		
		DC.B	'        TIME        ',1
		DC.B	'     DEPARTMENT     ',1 
		DC.B	1
		DC.B	'     STAGE  TWO     ',1
		DC.B	1
		DC.B	'     LESS  TIME     ',1
		DC.B	1
		DC.B	'   GETTING HARDER   ',1
		DC.B	1
		DC.B	$FF
		 
MES6:		
		DC.B	'        TIME        ',1
		DC.B	'     DEPARTMENT     ',1 
		DC.B	1
		DC.B	'    STAGE  THREE    ',1
		DC.B	1
		DC.B	'    THE SAME TIME   ',1
		DC.B	'     BUT NOW YOU    ',1
		DC.B	'     MUST  ALIGN    ',1
		DC.B	'    TEN BLOCKS TO   ',1
		DC.B	'    FINISH A LINE   ',1 
		DC.B	1
		DC.B	'     GOOD  LUCK     ',1  
		DC.B	$FF

MES7:		
		DC.B	'       GHOSTS       ',1
		DC.B	'     DEPARTMENT     ',1 
		DC.B	1
		DC.B	'     STAGE  ONE     ',1
		DC.B	1
		DC.B    '   DON T BE AFRAID  ',1
		DC.B    '   IF YOU SEE SOME  ',1
		DC.B    '    SOME UNWAITED   ',1
		DC.B	'       BLOCKS       ',1    
		DC.B	$FF

MES8:		
		DC.B	'       GHOSTS       ',1
		DC.B	'     DEPARTMENT     ',1 
		DC.B	1
		DC.B	'     STAGE TWO      ',1
		DC.B	1
		DC.B	'   WOULD  YOU LIKE  ',1
		DC.B	'     MORE BLOCKS    ',1
		DC.B	$FF

MES9:		
		DC.B	'       GHOSTS       ',1
		DC.B	'     DEPARTMENT     ',1 
		DC.B	1
		DC.B	'    STAGE  THREE    ',1
		DC.B	1
		DC.B	' FIRSTLY WE DECIDED ',1
		DC.B	' TO PUT MORE BLOCKS ',1
		DC.B	'   BUT YOU D NEVER  ',1
		DC.B	'  FINISH THIS STAGE ',1
		DC.B	$FF
		

MES10:		DC.B	1
		DC.B	1
		DC.B	'        FOOL        ',1
		DC.B	'     DEPARTMENT     ',1 
		DC.B	1
		DC.B	'     STAGE  ONE     ',1
		DC.B    1
		DC.B	'   YOUR  COMPUTER   ',1
		DC.B    '     HATES  YOU     ',1
		DC.B	$FF

MES11:		DC.B	1
		DC.B	'        FOOL        ',1
		DC.B	'     DEPARTMENT     ',1 
		DC.B	1
		DC.B	'     STAGE  TWO     ',1
		DC.B	1
		DC.B	'     YOU THINK      ',1
		DC.B	'  YOU WILL FINISH   ',1
		DC.B	' THIS  POOR  STAGE  ',1
		DC.B	$FF 

MES12:		DC.B	1
		DC.B	'        FOOL        ',1
		DC.B	'     DEPARTMENT     ',1 
		DC.B	1
		DC.B	'    STAGE  THREE    ',1
		DC.B	1
		DC.B	'      GOOD BYE      ',1
		DC.B	$FF 

MES13:		DC.B	1
		DC.B	'  DIS DONC TRICHEUR ',1
		DC.B	'  SI TU EN EST ICI  ',1
		DC.B    '  C EST PAR ABUS DE ',1  
		DC.B	'      CHEAT MODE    ',1
		DC.B	'   PAS D ANIMATION  ',1
		DC.B	'    FULL RAYTRACED  ',1
		DC.B	'  TRACK  TRUE COLOR ',1
		DC.B	'    EN REAL TIME    ',1
		DC.B    ' CODEE EN GFA BASIC ',1
		DC.B	'   VERSION ARMTJL   ',1
		DC.B	1
		DC.B	'     CASSE TOI      ',1  
		DC.B	$FF
		
TAB_DEPTT:	DC.L	DEPTT2,DEPTT3,DEPTT4,DEPTT5,DEPTT6
		DC.L	DEPTT7,DEPTT8
		

TAB_MES_DEPTT:	DC.L	MES_PRES
		DC.L	MES_DEPTT2,MES_DEPTT3,MES_DEPTT4
		DC.L	MES_DEPTT5,MES_DEPTT2,MES_DEPTT3,MES_DEPTT4
		DC.L	MES13

TRAINING:	DC.L	TRAIN_MES
		DC.W	0
		DC.W	3,3,8,49,0,0
		DC.W	0,0,0
		DC.W	1
		
		DC.L	MAX_TRAIN_MES
		DC.W	0
		DC.W	2,2,10,99,0,0
		DC.W	1,1,2
		DC.W	1

		DC.L	MAX_TRAIN_MES
		DC.W	0
		DC.W	1,1,10,99,0,0
		DC.W	1,1,1
		DC.W	1

		DC.L	MAX_TRAIN_MES
		DC.W	0
		DC.W	1,1,10,99,0,0
		DC.W	1,1,1
		DC.W	1

DEPTT1:		
		DC.L	MES1		; stage 1,2 et 3
		DC.W	0
		DC.W	3,3,8,10,0,0
		DC.W	0,0,0
		DC.W	1
		
		DC.L	MES2
		DC.W	0
		DC.W	2,2,8,10,0,0
		DC.W	0,0,0
		DC.W	1
		
		DC.L	MES3
		DC.W	0
		DC.W	2,1,8,10,0,0
		DC.W	0,0,0
		DC.W	1

DEPTT2:		
		DC.L	MES4
		DC.W	0
		DC.W	2,2,8,10,1,100
		DC.W	0,0,0
		DC.W	1
		
		DC.L	MES5
		DC.W	0
		DC.W	2,2,8,10,1,75
		DC.W	0,0,0
		DC.W	1
		
		DC.L	MES6
		DC.W	0
		DC.W	2,1,10,10,1,75
		DC.W	0,0,0
		DC.W	1
		
DEPTT3:		
		DC.L	MES7		
		DC.W	0
		DC.W	2,2,8,15,0,0
		DC.W	0,1,3
		DC.W	1
		
		DC.L	MES8
		DC.W	0
		DC.W	2,2,8,10,0,0
		DC.W	0,1,2
		DC.W	1
		
		DC.L	MES9
		DC.W	0
		DC.W	2,1,8,10,0,0
		DC.W	0,1,2
		DC.W	1
		

DEPTT4:		
		DC.L	MES10
		DC.W	0
		DC.W	2,2,8,15,0,0
		DC.W	1,0,0
		DC.W	1
		
		DC.L	MES11
		DC.W	0
		DC.W	2,2,8,10,0,0
		DC.W	1,0,0
		DC.W	1
		
		DC.L	MES12
		DC.W	0
		DC.W	2,1,8,10,0,0
		DC.W	1,0,0
		DC.W	1

		;  JEU DE PIECE 2
		
DEPTT5:		
		DC.L	MES1		; stage 1,2 et 3
		DC.W	1
		DC.W	3,3,8,10,0,0
		DC.W	0,0,0
		DC.W	0
		
		DC.L	MES2
		DC.W	1
		DC.W	2,2,8,10,0,0
		DC.W	0,0,0
		DC.W	0
		
		DC.L	MES3
		DC.W	1
		DC.W	2,1,8,10,0,0
		DC.W	0,0,0
		DC.W	0

DEPTT6:	
		DC.L	MES4
		DC.W	1
		DC.W	2,2,8,10,1,100
		DC.W	0,0,0
		DC.W	0
		
		DC.L	MES5
		DC.W	1
		DC.W	2,2,8,10,1,75
		DC.W	0,0,0
		DC.W	0
		
		DC.L	MES6
		DC.W	1
		DC.W	2,1,8,15,1,125
		DC.W	0,0,0
		DC.W	0
	
DEPTT7:		
		DC.L	MES7		
		DC.W	1
		DC.W	2,2,8,15,0,0
		DC.W	0,1,3
		DC.W	0
		
		DC.L	MES8
		DC.W	1
		DC.W	2,2,8,10,0,0
		DC.W	0,1,2
		DC.W	0
		
		DC.L	MES9
		DC.W	1
		DC.W	2,1,8,10,0,0
		DC.W	0,1,2
		DC.W	0

DEPTT8:		
		DC.L	MES10		
		DC.W	1
		DC.W	2,2,8,15,0,0
		DC.W	1,0,0
		DC.W	0
		
		DC.L	MES11
		DC.W	1
		DC.W	2,2,8,10,0,0
		DC.W	1,0,0
		DC.W	0
		
		DC.L	MES12
		DC.W	1
		DC.W	2,1,8,10,0,0
		DC.W	1,0,0
		DC.W	0


DATA_PIECE:	
	DC.B	1,1,0,0		; data premiere piece selon
	DC.B	1,1,0,0		; quatre rotation 
	DC.B	0,0,0,0		; 1 piece avec ses 4 rotations = 16 octets
	DC.B	0,0,0,0		; magique non???

	DC.B	1,1,0,0		; ici c'est donc le carre
	DC.B	1,1,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	DC.B	1,1,0,0
	DC.B	1,1,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	DC.B	1,1,0,0
	DC.B	1,1,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	;			et voici la seconde piece 
	DC.B	1,1,0,0
	DC.B	0,1,0,0
	DC.B	0,1,0,0
	DC.B	0,0,0,0
	
	DC.B	0,0,1,0
	DC.B	1,1,1,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	
	DC.B	1,0,0,0
	DC.B	1,0,0,0
	DC.B	1,1,0,0
	DC.B	0,0,0,0
	
	DC.B	1,1,1,0
	DC.B	1,0,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	
	;			la troisieme piece
	DC.B	1,1,0,0
	DC.B	1,0,0,0
	DC.B	1,0,0,0
	DC.B	0,0,0,0

	DC.B	1,1,1,0
	DC.B	0,0,1,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	DC.B	0,1,0,0
	DC.B	0,1,0,0
	DC.B	1,1,0,0
	DC.B	0,0,0,0

	DC.B	0,0,0,0
	DC.B	0,0,0,0
	DC.B	1,0,0,0
	DC.B	1,1,1,0
	
	;			la quatrieme piece			
	DC.B	1,1,1,1
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	
	DC.B	1,0,0,0
	DC.B	1,0,0,0
	DC.B	1,0,0,0
	DC.B	1,0,0,0
	
	DC.B	1,1,1,1
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	
	DC.B	1,0,0,0
	DC.B	1,0,0,0
	DC.B	1,0,0,0
	DC.B	1,0,0,0
	

	DC.B	1,1,1,0		; piece n 5
	DC.B	0,1,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	DC.B	0,0,1,0
	DC.B	0,1,1,0
	DC.B	0,0,1,0
	DC.B	0,0,0,0

	DC.B	0,0,0,0
	DC.B	0,1,0,0
	DC.B	1,1,1,0
	DC.B	0,0,0,0

	DC.B	1,0,0,0
	DC.B	1,1,0,0
	DC.B	1,0,0,0
	DC.B	0,0,0,0

	DC.B	1,1,0,0		; piece n 6
	DC.B	0,1,1,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	DC.B	0,0,1,0		
	DC.B	0,1,1,0
	DC.B	0,1,0,0
	DC.B	0,0,0,0

	DC.B	0,0,0,0
	DC.B	1,1,0,0
	DC.B	0,1,1,0
	DC.B	0,0,0,0

	DC.B	0,1,0,0		
	DC.B	1,1,0,0
	DC.B	1,0,0,0
	DC.B	0,0,0,0
	
	
	DC.B	0,1,1,0		; piece n 7
	DC.B	1,1,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	DC.B	0,1,0,0		
	DC.B	0,1,1,0
	DC.B	0,0,1,0
	DC.B	0,0,0,0

	DC.B	0,0,0,0
	DC.B	0,1,1,0
	DC.B	1,1,0,0
	DC.B	0,0,0,0

	DC.B	1,0,0,0		
	DC.B	1,1,0,0
	DC.B	0,1,0,0
	DC.B	0,0,0,0

	DC.B	1,0,0,0		; PIECE 8
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	DC.B	1,0,0,0		
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	DC.B	1,0,0,0		
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	DC.B	1,0,0,0		
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	DC.B	1,1,0,0
	DC.B	1,1,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

DATA_PIECE2:	
	DC.B	0,1,0,0		; piece 2-1
	DC.B	1,1,1,0
	DC.B	0,1,0,0
	DC.B	0,0,0,0
	
	DC.B	0,1,0,0		
	DC.B	1,1,1,0
	DC.B	0,1,0,0
	DC.B	0,0,0,0
	
	DC.B	0,1,0,0		
	DC.B	1,1,1,0
	DC.B	0,1,0,0
	DC.B	0,0,0,0
	
	DC.B	0,1,0,0		
	DC.B	1,1,1,0
	DC.B	0,1,0,0
	DC.B	0,0,0,0
	
	DC.B	0,1,1,0		; piece 2-2
	DC.B	0,1,0,0
	DC.B	1,1,0,0
	DC.B	0,0,0,0
	
	DC.B	1,0,0,0
	DC.B	1,1,1,0
	DC.B	0,0,1,0
	DC.B	0,0,0,0

	DC.B	0,1,1,0		
	DC.B	0,1,0,0
	DC.B	1,1,0,0
	DC.B	0,0,0,0
	
	DC.B	1,0,0,0
	DC.B	1,1,1,0
	DC.B	0,0,1,0
	DC.B	0,0,0,0

	DC.B	1,1,0,0		; piece 2-3
	DC.B	0,1,0,0
	DC.B	0,1,1,0
	DC.B	0,0,0,0

	DC.B	0,0,1,0
	DC.B	1,1,1,0
	DC.B	1,0,0,0
	DC.B	0,0,0,0
	
	DC.B	1,1,0,0		
	DC.B	0,1,0,0
	DC.B	0,1,1,0
	DC.B	0,0,0,0

	DC.B	0,0,1,0
	DC.B	1,1,1,0
	DC.B	1,0,0,0
	DC.B	0,0,0,0
	

	DC.B	0,1,0,0		; piece 2-4
	DC.B	0,1,0,0
	DC.B	1,1,1,0
	DC.B	0,0,0,0

	DC.B	1,0,0,0
	DC.B	1,1,1,0
	DC.B	1,0,0,0
	DC.B	0,0,0,0

	DC.B	1,1,1,0
	DC.B	0,1,0,0
	DC.B	0,1,0,0
	DC.B	0,0,0,0

	DC.B	0,0,1,0
	DC.B	1,1,1,0
	DC.B	0,0,1,0
	DC.B	0,0,0,0

	DC.B	0,1,0,0		; piece 2-5
	DC.B	1,1,0,0
	DC.B	0,1,1,0
	DC.B	0,0,0,0

	DC.B	0,1,0,0		
	DC.B	1,1,1,0
	DC.B	1,0,0,0
	DC.B	0,0,0,0

	DC.B	1,1,0,0		
	DC.B	0,1,1,0
	DC.B	0,1,0,0
	DC.B	0,0,0,0

	DC.B	0,0,1,0		
	DC.B	1,1,1,0
	DC.B	0,1,0,0
	DC.B	0,0,0,0


	DC.B	0,1,0,0		; piece 2-6
	DC.B	0,1,1,0
	DC.B	1,1,0,0
	DC.B	0,0,0,0
	
	DC.B	1,0,0,0
	DC.B	1,1,1,0
	DC.B	0,1,0,0
	DC.B	0,0,0,0
	
	DC.B	0,1,1,0
	DC.B	1,1,0,0
	DC.B	0,1,0,0
	DC.B	0,0,0,0

	DC.B	0,1,0,0
	DC.B	1,1,1,0
	DC.B	0,0,1,0
	DC.B	0,0,0,0

	
	
	DC.B	1,1,0,0		;  piece 2-7
	DC.B	0,1,0,0
	DC.B	0,1,0,0
	DC.B	0,1,0,0

	DC.B	0,0,0,1
	DC.B	1,1,1,1
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	DC.B	1,0,0,0
	DC.B	1,0,0,0
	DC.B	1,0,0,0
	DC.B	1,1,0,0

	DC.B	1,1,1,1
	DC.B	1,0,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	
	DC.B	1,0,0,0		; PIECE 8
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	DC.B	1,0,0,0		
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	DC.B	1,0,0,0		
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	DC.B	1,0,0,0		
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0

	DC.B	1,1,0,0
	DC.B	1,1,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0


SYNC:	DC.W	0		; utilisee pour la synchro vbl
G_O:	DC.W	0		; et le game over

RAST_EC:	DC.L	$20000000,$30000000,$40000000,$50000000,$60000000
		DC.L	$70000000,$80000000,$80000000,$70000000,$60000000
		DC.L	$50000000,$40000000,$30000000,$20000000
		DCB.L	74,0
		DC.L	$200000,$300000,$400000,$500000,$500000,$400000,$300000,$200000
		DCB.L	124,0
RAST_EC2:	DC.L	$20000000,$30000000,$40000000,$50000000,$60000000
		DC.L	$70000000,$80000000,$80000000,$70000000,$60000000
		DC.L	$50000000,$40000000,$30000000,$20000000
		DC.L	0,0,0,0,0,0,0,0,0,0
		DC.L	$200000,$300000,$400000,$500000,$500000,$400000
		DC.L	$300000,$200000
		DC.L	0,0,0,0,0,0,0,$20,$30,$40,$50,$50,$40,$30,$20
		DC.L	0,0,0,0,0,0,0,0,$20,$30,$40,$50,$50,$40,$30,$20
		DC.L	0,0,0,0,0,0,0,0,$20,$30,$40,$50,$50,$40,$30,$20
		DC.L	0,0,0,0,0,0,0,0,$20,$30,$40,$50,$50,$40,$30,$20
		DC.L	0,0,0,0,0,0,0,0,$20,$30,$40,$50,$50,$40,$30,$20
		DC.L	0,0,0,0,0,0,0,0,$20,$30,$40,$50,$50,$40,$30,$20
		DC.L	0,0,0,0,0,0,0,0,$20,$30,$40,$50,$50,$40,$30,$20
		DC.L	0,0,0,0,0,0,0,0,$20,$30,$40,$50,$50,$40,$30,$20
		DC.L	0,0,0,0,0,0,0,0,$20,$30,$40,$50,$50,$40,$30,$20,0
		DCB.L	24,0
		 
	SECTION BSS

SAVE_SSP:	DS.L	1	; pile utilisateur
SAVE_VBL:	DS.L	1	; ancien vecteur vbl		
SAVE_CLAV:	DS.W	1	;  '  '    '  '  clavier
SAVE_PAL:	DS.B	64	

SAVE_MODE_VIDEO:	DS.W	1	
SAVE_VIDEL:	DS.W	16	; registres du VIDEL

JEU_P_EN_C:	DS.L	1	; quel jeu de piece utilise-t-on
XM_EN_C:	DS.L	1	; en ce moment ?
YM_EN_C:	DS.L	1	; et quel est sa position et sa
ROT_EN_C:	DS.L	1	; rotation
GFX_EN_C:	DS.L	1

CONVERTIT:	DS.L	16	; espace pour la palette convertie
				; au format falcon 
				
SAVE_TIMA:	DS.L	1	; sauvegarde du mfp de depart
SAUVE_MFP:	DS.L	5
SAVE_TIMB:	DS.L	1
SAVE_RASTVBL:	DS.L	1	

POINT_RAST:	DS.L	1	; pointeur sur les rasters de 
EC_RAST:	DS.L	1 	; l'ecran des highscores

HIGH_NAME:	DS.W	25	; table des high en elle meme
HIGH_TAB:	DS.W	401
H_S:		DS.W	10

AUTRE:		DS.W	10	

WAIT:		DS.W	1	; nb de vbl entre chaque affichage
VITESSE:	DS.W	1
WAIT_CLAV:	DS.W	1	; variable pour la gestion du clavier
TPS_DEP:	DS.W	1	; nb de vbl entre chaque deplacement
ANC_TOUCHE:	DS.W	1

JOUAB:		DS.W	1	; param que j'ai rajoute pour
JOUAB1:		DS.W	1	; ameliorer la jouabilite et ca marche...

ADR_ECR:	DS.L	1	; adresse de l'ecran en cours
NUM_ECRAN:	DS.W	1	; et son numero
CHGT_ECR:	DS.W	1		

VBL_TIME:	DS.W	1	; tps 

RANDOM:		DS.L	1	; valeur pour les nombre pseudo aleatoires

OUT_OF_TIME:	DS.W	1	;ici on sait si l'on est g_o a cause du tps	

SAVE_DEPTT:	DS.L	1	; valeurs sur le stage et le departement
SAVE_DEPTT2:	DS.L	1
SAVE_TMD:	DS.L	1
DEPTT:		DS.W	1	; en cours
STAGE:		DS.W	1
FINI_STAGE:	DS.W	1

NOMBRE:		DS.W	5	; buffer pour la conversion des nombres
SCORE:		DS.W	1	; c'est ici que le score est contenu
WAIT_TOU:	DS.W	1	; valeur pour l'attente du relachement
				; d'une touche

SCORE_P:	DS.W	1	; bonus pour acceleration de la piece

INSTRUC:	DS.W	10	; pour les donnees a passer a la ss-routine
ADR_FOND:	DS.L	1	; pour la restauration du fond
FOND:		DS.B	32*32	; buffer ou sera stocke le fond

P_EN_C:		DS.W	1	; toute les infos importantes sur la
R_EN_C:		DS.W	1	; piece en cours
X:		DS.W	1	
Y:		DS.W	1	
PAS_X:		DS.W	1
PAS_Y:		DS.W	1

NE_P_EN_C:	DS.W	1	; toute les infos importantes sur la
NE_R_EN_C:	DS.W	1	; prochaine piece
NE_X:		DS.W	1	
NE_Y:		DS.W	1	
NE_PAS_X:	DS.W	1
NE_PAS_Y:	DS.W	1
NEXT_DIRECT:	DS.W	1

;	adresse des quatre ecrans
ECRAN1:		DS.L	1	
ECRAN2:		DS.L	1
ECRAN3:		DS.L	1
ECRAN4:		DS.L	1

;	representation des ecrans en memoire
;	chaque octet represente une case 
;	0-->vide 1-->pleine

DAT_0:		DS.B	32*32
DAT_90:		DS.B	32*32
DAT_180:	DS.B	32*32
DAT_270:	DS.B	32*32
	
;	les differents ecrans selon les rotations
DEG_0:		DS.B	64256
DEG_90:		DS.B	64256
DEG_180:	DS.B	64256
DEG_270:	DS.B	64256
	END


	


		
	


	



	