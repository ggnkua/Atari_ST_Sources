*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*
*                                     *
*  Initialisation pour les programmes *
*  Gem ou Tos (partie system 030)     *
*                                     *
*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*
*  Par Skynet From Fatal Design       *
*  BAUMANN Loic                       *
*  72, Rue du dauphine                *
*  69003 Lyon                         *
*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Tout ce qu'il faut en cas d'execution
; d'un code DSP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	IfNe		Exec_P56
HTX					equ		$ffffa204	; Host Transmit Data
HRX					equ		$ffffa204	; Host Receive Data
IVR					equ		$ffffa203	; Interrupt Vector Register
CVR					equ		$ffffa201	; Command Vector Register
HCP					equ		7				; Host Command Pending
HCR					equ		$ffffa200	; Host Control Register
HF1					equ		4				; Host Flag 1 control‚ par le 030
HF0					equ		3				; Host Flag 0 control‚ par le 030
HTIE					equ		1				; Host Transmit Interrupt Enable
HRIE					equ		0				; Host Receive Interrupt Enable
HSR					equ		$ffffa202	; Host Status Register
HF3					equ		3				; Host Flag 3 control‚ par le DSP
HF2					equ		2				; Host Flag 2 control‚ par le DSP
HTDE					equ		1				; Host Transmit Data Empty
HRDF					equ		0				; Host Receive Data Full

; D‚finition des Macros
Host_Send_Data		Macro
.Host_Request\@
	btst		#HTDE,HSR
	beq.s		.Host_Request\@
	move.l	\1,HTX
	EndM

Host_Get_Data		Macro
.Host_Request\@
	btst		#HRDF,HSR
	beq.s		.Host_Request\@
	move.l	HRX,\1
	EndM

	EndC


	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;			Definition des Macros		  |
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Super	Macro
	move.l	Super_ID,-(sp)
	move.w	#$20,-(sp)
	trap		#1
	addq.l	#6,sp
	move.l	d0,Super_ID
		EndM

Aff_Text	Macro		\1
	pea		\1
	move.w	#$9,-(sp)
	trap		#1
	addq.l	#6,sp
			EndM

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;					Init System				  |
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Init_System

	Super											; on passe en mode Superviseur

		IfNe		StartUp
Make_StartUp
; On recherche et reserve la place memoire necessaire au programme
	move.l	4(sp),a0							; Adresse de la base Page
	move.l	a0,BasePage						; On sauve l'adr de la BasePage
	move.l	$18(a0),a1						; Adr de debut de la zone BSS
	add.l		$1c(a0),a1						; Fin de la zone normale du programme

	sub.l		BasePage,a1						; On obtient ainsi la taille reelle du programme

	move.l	a1,-(sp)							; Zone de memoire a garder
	move.l	BasePage,-(sp)					; A partir de quelle adr on reserve cette zone memoire
	clr.w		-(sp)
	move.w	#$4a,-(sp)						; Fonction gemdos Mshrink : on libere la memoire inutilisee
	Trap		#1
	lea		12(a7),a7						; On reactualise la pile
		EndC

; On sauvegarde l'adresse courante de la pile actuelle
	move.l	SP,Old_Stack_Adr
; On installe la nouvelle pile
	lea		Pile,SP	

		IfNe	EXec_P56
	move.w	#113,-(sp)						; DSP_RequestUniqueAbility
	Trap		#14								; XBios
	addq.l	#2,sp

	move.w	d0,-(sp)							; No Ability
	move.l	#DSP_Code_Size,-(sp)			; Longueur en Mots DSP
	pea		DSP_Code							; Adresse du code binaire
	move.w	#109,-(sp)						; Dsp_ExecProg
	Trap		#14								; XBios
	lea.l		12(sp),sp

	Host_Send_Data		#$4321				; On signale notre presence au DSP
	
.Wait_DSP
	Host_Get_Data		d0
	cmpi.l	#12345678,d0
	Bne.s		.Wait_DSP
	
		EndC

	move.w	#$2700,SR						; On maske toutes les interruptions

Save_System
	lea		Old_System,a0					; Espace de sauvegarde
	movec		CaCr,d0							; Valeur du cache
	move.w	d0,(a0)+							; Sauv‚e !
	move.b	$ffff8007.w,(a0)+				; Configuration 68030
	move.b	$ffff8201.w,(a0)+				; Vid‚o (poids fort)
	move.b	$ffff8203.w,(a0)+				; Vid‚o (poids moyen)
	move.b	$ffff820d.w,(a0)+				; Vid‚o (poids faible)
	move.b	$ffff820a.w,(a0)+				; Synchronisation vid‚o
	move.w	$ffff820e.w,(a0)+				; Offset pour prochaine ligne
	move.w	$ffff8210.w,(a0)+				; Largeur d'une ligne en mots
	move.b	$ffff8260.w,(a0)+				; R‚solution ST
	move.b	$ffff8265.w,(a0)+				; D‚calage Pixel
	move.w	$ffff8266.w,(a0)+				; R‚solution FALCON
	move.w	$ffff8282.w,(a0)+				; HHT-Synchro
	move.w	$ffff8284.w,(a0)+				; Fin du d‚codage de la ligne
	move.w	$ffff8286.w,(a0)+				; D‚but du d‚codage de la ligne
	move.w	$ffff8288.w,(a0)+				; Overscan gauche
	move.w	$ffff828a.w,(a0)+				; Overscan droit
	move.w	$ffff828c.w,(a0)+				; HSS-Synchro
	move.w	$ffff828e.w,(a0)+				; HFS
	move.w	$ffff8290.w,(a0)+				; HEE
	move.w	$ffff82a2.w,(a0)+				; VFT-Synchro
	move.w	$ffff82a4.w,(a0)+				; Fin du d‚codage de l'image
	move.w	$ffff82a6.w,(a0)+				; D‚but du d‚codage de l'image
	move.w	$ffff82a8.w,(a0)+				; Overscan haut
	move.w	$ffff82aa.w,(a0)+				; Overscan bas
	move.w	$ffff82ac.w,(a0)+				; VSS-Synchro
	move.w	$ffff82c0.w,(a0)+				; Reconnaissance ST/FALCON
	move.w	$ffff82c2.w,(a0)+				; Informations r‚solution

	move.w	$ffff8900.w,(a0)+				; Interruptions, Son DMA
	move.b	$ffff8903.w,(a0)+				; Start - High
	move.b	$ffff8905.w,(a0)+				; Start - Med
	move.b	$ffff8907.w,(a0)+				; Start - Low
	move.b	$ffff890f.w,(a0)+				; End - High
	move.b	$ffff8911.w,(a0)+				; End - Med
	move.b	$ffff8913.w,(a0)+				; End - Low
	move.w	$ffff8920.w,(a0)+				; Nb Voies, 8/16, Mono/Stereo
	move.w	$ffff8930.w,(a0)+				; Matrice : Sources
	move.w	$ffff8932.w,(a0)+				; Matrice : Destinations
	move.w	$ffff8934.w,(a0)+				; Prescales d'horloge
	move.w	$ffff8936.w,(a0)+				; Nb Voies Record,source ADDERIN
	move.w	$ffff8938.w,(a0)+				; Source ADC + Volumes entr‚es
	move.w	$ffff893a.w,(a0)+				; Volumes de Sortie

	move.b	$fffffa07.w,(a0)+				; Registre iera
	move.b	$fffffa09.w,(a0)+				; Registre ierb
	move.b	$fffffa13.w,(a0)+				; Registre imra
	move.b	$fffffa15.w,(a0)+				; Registre imrb
	move.b	$fffffa17.w,(a0)+				; Registre vr
	move.b	$fffffa19.w,(a0)+				; Controle Timer A
	move.b	$fffffa1b.w,(a0)+				; Controle Timer B
	move.b	$fffffa1d.w,(a0)+				; Controle Timer C et D
	move.b	$fffffa1f.w,(a0)+				; Donn‚e Timer A
	move.b	$fffffa21.w,(a0)+				; Donn‚e Timer B
	move.b	$fffffa23.w,(a0)+				; Donn‚e Timer C	
	move.b	$fffffa25.w,(a0)+				; Donn‚e Timer D

	move.l	$8.w,(a0)+						; Vecteur Bus error
	move.l	$c.w,(a0)+						; Vecteur Adresse error
	move.l	$10.w,(a0)+						; Vecteur Illegal Instruction
	move.l	$14.w,(a0)+						; Vecteur Div by 0
	move.l	$20.w,(a0)+						; Violation de privilege
	move.l	$38.w,(a0)+						; Erreur de format
	move.l	$68.w,(a0)+						; Vecteur HBL
	move.l	$70.w,(a0)+						; Vecteur VBL
	move.l	$110.w,(a0)+					; Vecteur Timer D
	move.l	$114.w,(a0)+					; Vecteur Timer C
	move.l	$118.w,(a0)+					; Vecteur KeyBoard
	move.l	$11c.w,(a0)+					; Vecteur FDC
	move.l	$120.w,(a0)+					; Vecteur Timer B
	move.l	$134.w,(a0)+					; Vecteur Timer A

		IfNe	Protec_Mode
	move.l	#Bus_Error,$8.w
	move.l	#Adr_Error,$c.w
	IfEq		Debug
	move.l	#Ill_Instr,$10.w
	EndC
	move.l	#Divi_By_0,$14.w
	move.l	#Viol_Priv,$20.w
	move.l	#Fmt_Error,$38.w
		EndC

	lea		$ffff8240.w,a1					; Palette ST
	moveq		#8-1,d0							; 8 longs...
Save_ST_Palette
	move.l	(a1)+,(a0)+						; Sauve 2 couleurs
	Dbf		d0,Save_ST_Palette			; Boucle les 16 mots !

	lea		$ffff9800.w,a1					; Palette FALCON
	move.w	#256-1,d0						; 256 longs...
Save_FALCON_Palette
	move.l	(a1)+,(a0)+						; Sauve 1 couleur
	Dbf		d0,Save_FALCON_Palette		; Boucle les 256 longs !

 	moveq		#0,d0								; Caches activ‚s
		IfNe	Data_Cache
	bset		#8,d0
	bset		#13,d0
		EndC
		IfNe	Instruction_Cache
	bset		#0,d0
		EndC
	movec		d0,cacr							; Nouvelle valeur
	move.b	#5,$ffff8007.w					; 68030 et Blitter … 16 Mhz

		IfEq	Mouse
Mouse_Off
.Wait_Kbd
	btst		#1,$fffffc00.w
	Beq.s		.Wait_Kbd
	move.b	#$12,$fffffc02.w
		EndC
		
		IfEq	Joystick
Joystick_Off
.Wait_Kbd
	btst		#1,$fffffc00.w
	Beq.s		.Wait_Kbd
	move.b	#$1a,$fffffc02.w
		EndC
		
		IfEq	Debug
Init_IT
	clr.b		$fffffa07.w						; Coupe toutes
	clr.b		$fffffa13.w						; les
	clr.b		$fffffa09.w						; Interruptions
	clr.b		$fffffa15.w						; du MFP 68901
	bclr		#3,$fffffa17.w					; Fin interruptions automatique
		EndC
		
	move.w	#$2300,SR						; Autorise les Interruptions

	Bra		Setting

Set_Res
	move.b	#2,$ffff820a.w					; Horloge Interne
	clr.b		$ffff8265.w						; D‚calage Pixel Nul
	addq.l	#4,a0
	move.w	(a0)+,$ffff820e.w				; Offset pour prochaine ligne nul
	move.w	(a0)+,$ffff8210.w				; Largeur d'une ligne en mots
	move.w	(a0)+,d0							; R‚solution ST
	move.w	(a0)+,d1							; R‚solution FALCON

	move.w	d1,$ffff8266.w					; R‚solution FALCON
	tst.w		(a0)+
	Beq.s		FalconRez
	move.b	d0,$ffff8260.w					; R‚solution ST
	move.w	-8(a0),$ffff8210.w			; Largeur d'une ligne en mots
FalconRez
	btst.b	#7,$ffff8006.w					; Ecran VGA ?
	Beq.s		R_Ok								; Si non,saut...
	adda.w	#16*2,a0
R_Ok
	move.w	(a0)+,$ffff8282.w				; HHT-Synchro
	move.w	(a0)+,$ffff8284.w				; Fin du d‚codage de la ligne
	move.w	(a0)+,$ffff8286.w				; D‚but du d‚codage de la ligne
	move.w	(a0)+,$ffff8288.w				; Overscan gauche
	move.w	(a0)+,$ffff828a.w				; Overscan droit
	move.w	(a0)+,$ffff828c.w				; HSS-Synchro
	move.w	(a0)+,$ffff828e.w				; HFS
	move.w	(a0)+,$ffff8290.w				; HEE
	move.w	(a0)+,$ffff82a2.w				; VFT-Synchro
	move.w	(a0)+,$ffff82a4.w				; Fin du d‚codage de l'image
	move.w	(a0)+,$ffff82a6.w				; D‚but du d‚codage de l'image
	move.w	(a0)+,$ffff82a8.w				; Overscan haut
	move.w	(a0)+,$ffff82aa.w				; Overscan bas
	move.w	(a0)+,$ffff82ac.w				; VSS-Synchro
	move.w	(a0)+,$ffff82c0.w				; Indique r‚solution FALCON
	move.w	(a0),$ffff82c2.w				; Informations r‚solution

	Rts

Instal_Screens
	add.l		#256,d0
	clr.b		d0
	subq.w	#1,d1
.Set_Adi
	move.l	d0,(a0)+
	add.l		d2,d0
	Dbf		d1,.Set_Adi

	Rts

Restore_System

	move.w	#$2700,SR
	
	lea		Old_System,a0					; Espace de sauvegarde
	move.w	(a0)+,d0							; Sauv‚e !
	movec		d0,CaCr							; Valeur du cache
	move.b	(a0)+,$ffff8007.w				; Configuration 68030

	move.b	(a0)+,$ffff8201.w				; Vid‚o (poids fort)
	move.b	(a0)+,$ffff8203.w				; Vid‚o (poids moyen)
	move.b	(a0)+,$ffff820d.w				; Vid‚o (poids faible)
	move.b	(a0)+,$ffff820a.w				; Synchronisation vid‚o
	move.w	(a0)+,$ffff820e.w				; Offset pour prochaine ligne
	move.w	(a0)+,$ffff8210.w				; Largeur d'une ligne en mots
	move.b	(a0)+,d0							; R‚solution ST
	move.b	(a0)+,$ffff8265.w				; D‚calage Pixel
	move.w	(a0)+,d1							; R‚solution FALCON
	move.w	(a0)+,$ffff8282.w				; HHT-Synchro
	move.w	(a0)+,$ffff8284.w				; Fin du d‚codage de la ligne
	move.w	(a0)+,$ffff8286.w				; D‚but du d‚codage de la ligne
	move.w	(a0)+,$ffff8288.w				; Overscan gauche
	move.w	(a0)+,$ffff828a.w				; Overscan droit
	move.w	(a0)+,$ffff828c.w				; HSS-Synchro
	move.w	(a0)+,$ffff828e.w				; HFS
	move.w	(a0)+,$ffff8290.w				; HEE
	move.w	(a0)+,$ffff82a2.w				; VFT-Synchro
	move.w	(a0)+,$ffff82a4.w				; Fin du d‚codage de l'image
	move.w	(a0)+,$ffff82a6.w				; D‚but du d‚codage de l'image
	move.w	(a0)+,$ffff82a8.w				; Overscan haut
	move.w	(a0)+,$ffff82aa.w				; Overscan bas
	move.w	(a0)+,$ffff82ac.w				; VSS-Synchro
	move.w	(a0)+,$ffff82c0.w				; Reconnaissance ST/FALCON
	move.w	(a0)+,$ffff82c2.w				; Informations r‚solution
	move.w	d1,$ffff8266.w					; Fixe r‚solution FALCON...
	btst.b	#0,$ffff82c0.w					; R‚solution FALCON ?
	bne.s		Falcon_Rez						; Si oui,saut !
	move.b	d0,$ffff8260.w					; Fixe r‚solution ST...
Falcon_Rez
	move.w	(a0)+,$ffff8900.w				; Interruptions, Son DMA
	move.b	(a0)+,$ffff8903.w				; Start - High
	move.b	(a0)+,$ffff8905.w				; Start - Med
	move.b	(a0)+,$ffff8907.w				; Start - Low
	move.b	(a0)+,$ffff890f.w				; End - High
	move.b	(a0)+,$ffff8911.w				; End - Med
	move.b	(a0)+,$ffff8913.w				; End - Low
	move.w	(a0)+,$ffff8920.w				; Nb Voies, 8/16, Mono/Stereo
	move.w	(a0)+,$ffff8930.w				; Matrice : Sources
	move.w	(a0)+,$ffff8932.w				; Matrice : Destinations
	move.w	(a0)+,$ffff8934.w				; Prescales d'horloge
	move.w	(a0)+,$ffff8936.w				; Nb Voies Record,source ADDERIN
	move.w	(a0)+,$ffff8938.w				; Source ADC + Volumes entr‚es
	move.w	(a0)+,$ffff893a.w				; Volumes de Sortie

	move.b	(a0)+,$fffffa07.w				; Registre iera
	move.b	(a0)+,$fffffa09.w				; Registre ierb
	move.b	(a0)+,$fffffa13.w				; Registre imra
	move.b	(a0)+,$fffffa15.w				; Registre imrb
	move.b	(a0)+,$fffffa17.w				; Registre vr
	move.b	(a0)+,$fffffa19.w				; Controle Timer A
	move.b	(a0)+,$fffffa1b.w				; Controle Timer B
	move.b	(a0)+,$fffffa1d.w				; Controle Timer C et D
	move.b	(a0)+,$fffffa1f.w				; Donn‚e Timer A
	move.b	(a0)+,$fffffa21.w				; Donn‚e Timer B
	addq.l	#1,a0
	;move.b	(a0)+,$fffffa23.w				; Donn‚e Timer C	
	move.b	(a0)+,$fffffa25.w				; Donn‚e Timer D

	move.l	(a0)+,$8.w						; Vecteur Bus error
	move.l	(a0)+,$c.w						; Vecteur Adresse error
	move.l	(a0)+,$10.w						; Vecteur Illegal Instruction
	move.l	(a0)+,$14.w						; Vecteur Div by 0
	move.l	(a0)+,$20.w						; Violation de privilege
	move.l	(a0)+,$38.w						; Erreur de format
	move.l	(a0)+,$68.w						; Vecteur HBL
	move.l	(a0)+,$70.w						; Vecteur VBL
	move.l	(a0)+,$110.w					; Vecteur Timer D
	move.l	(a0)+,$114.w					; Vecteur Timer C
	move.l	(a0)+,$118.w					; Vecteur KeyBoard
	move.l	(a0)+,$11c.w					; Vecteur FDC
	move.l	(a0)+,$120.w					; Vecteur Timer B
	move.l	(a0)+,$134.w					; Vecteur Timer A

	lea		$ffff8240.w,a1					; Palette ST
	moveq		#7,d0								; 8 longs...
Rest_ST_Palette
	move.l	(a0)+,(a1)+						; Rstaure 2 couleurs
	Dbf		d0,Rest_ST_Palette			; Boucle les 16 mots !

	lea		$ffff9800.w,a1					; Palette FALCON
	move.w	#255,d0							; 256 longs...
Rest_FALCON_Palette
	move.l	(a0)+,(a1)+						; Restaure 1 couleur
	Dbf		d0,Rest_FALCON_Palette		; Boucle les 256 longs !

Wait_No_Key
	move.b	$fffffc02.w,d0					; Code clavier
	btst		#0,$fffffc00.w					; Buffer vide ?
	bne.s		Wait_No_Key						; Sinon,on continue...

Joystick_Now_Off
.Wait_Kbd
	btst		#1,$fffffc00.w
	beq.s		.Wait_Kbd
	move.b	#$1a,$fffffc02.w

Mouse_Now_On
.Wait_Kbd
	btst		#1,$fffffc00.w
	beq.s		.Wait_Kbd
	move.b	#$08,$fffffc02.w

	move.w	#$2300,sr

	Rts

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;      AFFICHAGE DU NOMBRE DE VBL     |
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Ifne		VBL_Number
Draw_VBL_Number
		move.w	C_VBL,d0
		subq.w	#1,d0
		cmpi.w	#10,d0
		blt.s		.OK_Number
		lea		Warning_Time,a1
		bra.s		.Warning
.OK_Number		
		lea		Table_Number,a1
		move.l	4(a1,d0.w*4),a1
.Warning
		move.l	Adr_Screen1,a0
		moveq		#8-1,d7
.Draw_Number
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		lea		(320-8)*2(a0),a0
		dbf		d7,.Draw_Number
	Rts
Table_Number
		dc.l		Nul,One,Two,Three,Four,Five,Six,Seven,Eight,Nine

Nul	dc.w		00,00,00,-1,-1,00,00,00
		dc.w		00,00,-1,00,00,-1,00,00
		dc.w		00,00,-1,00,00,-1,-1,00
		dc.w		00,00,-1,00,-1,-1,00,00
		dc.w		00,00,-1,-1,00,-1,00,00
		dc.w		00,-1,-1,00,00,-1,00,00
		dc.w		00,00,-1,00,00,-1,00,00
		dc.w		00,00,00,-1,-1,00,00,00
		
One	dc.w		00,00,00,00,-1,00,00,00
		dc.w		00,00,00,-1,-1,00,00,00
		dc.w		00,00,-1,00,-1,00,00,00
		dc.w		00,00,00,00,-1,00,00,00
		dc.w		00,00,00,00,-1,00,00,00
		dc.w		00,00,00,00,-1,00,00,00
		dc.w		00,00,00,00,-1,00,00,00
		dc.w		00,00,-1,-1,-1,-1,-1,00

Two	dc.w		00,00,00,-1,-1,00,00,00
		dc.w		00,00,-1,00,00,-1,00,00
		dc.w		00,00,00,00,00,-1,00,00
		dc.w		00,00,00,00,00,-1,00,00
		dc.w		00,00,00,00,-1,00,00,00
		dc.w		00,00,00,-1,00,00,00,00
		dc.w		00,00,-1,00,00,00,00,00
		dc.w		00,00,-1,-1,-1,-1,00,00

Three	dc.w		00,00,-1,-1,-1,00,00,00
		dc.w		00,00,00,00,00,-1,00,00
		dc.w		00,00,00,00,00,-1,00,00
		dc.w		00,00,00,-1,-1,00,00,00
		dc.w		00,00,00,00,00,-1,00,00
		dc.w		00,00,00,00,00,-1,00,00
		dc.w		00,00,00,00,00,-1,00,00
		dc.w		00,00,-1,-1,-1,00,00,00
		
Four	dc.w		00,00,00,-1,00,00,00,00
		dc.w		00,00,00,-1,00,00,00,00
		dc.w		00,00,-1,00,00,00,00,00
		dc.w		00,00,-1,00,-1,00,00,00
		dc.w		00,00,-1,-1,-1,-1,-1,00
		dc.w		00,00,00,00,-1,00,00,00
		dc.w		00,00,00,00,-1,00,00,00
		dc.w		00,00,00,00,-1,00,00,00
		
Five	dc.w		00,00,-1,-1,-1,-1,00,00
		dc.w		00,00,-1,00,00,00,00,00
		dc.w		00,00,-1,00,00,00,00,00
		dc.w		00,00,00,-1,-1,00,00,00
		dc.w		00,00,00,00,00,-1,00,00
		dc.w		00,00,00,00,00,-1,00,00
		dc.w		00,00,00,00,00,-1,00,00
		dc.w		00,00,-1,-1,-1,00,00,00

Six	dc.w		00,00,00,-1,-1,-1,00,00
		dc.w		00,00,-1,00,00,00,00,00
		dc.w		00,00,-1,00,00,00,00,00
		dc.w		00,00,-1,00,00,00,00,00
		dc.w		00,00,-1,-1,-1,-1,00,00
		dc.w		00,00,-1,00,00,-1,00,00
		dc.w		00,00,-1,00,00,-1,00,00
		dc.w		00,00,-1,-1,-1,-1,00,00

Seven	dc.w		00,00,-1,-1,-1,-1,-1,00
		dc.w		00,00,00,00,00,00,-1,00
		dc.w		00,00,00,00,00,-1,00,00
		dc.w		00,00,00,00,00,-1,00,00
		dc.w		00,00,00,00,-1,00,00,00
		dc.w		00,00,00,00,-1,00,00,00
		dc.w		00,00,00,-1,00,00,00,00
		dc.w		00,00,00,-1,00,00,00,00
		
Eight
		dc.w		00,00,00,-1,-1,00,00,00
		dc.w		00,00,-1,00,00,-1,00,00
		dc.w		00,00,-1,00,00,-1,00,00
		dc.w		00,00,00,-1,-1,00,00,00
		dc.w		00,00,-1,00,00,-1,00,00
		dc.w		00,00,-1,00,00,-1,00,00
		dc.w		00,00,-1,00,00,-1,00,00
		dc.w		00,00,00,-1,-1,00,00,00
Nine
		dc.w		00,00,00,-1,-1,00,00,00
		dc.w		00,00,-1,00,00,-1,00,00
		dc.w		00,00,-1,00,00,-1,00,00
		dc.w		00,00,00,-1,-1,00,00,00
		dc.w		00,00,00,00,00,-1,00,00
		dc.w		00,00,00,00,00,-1,00,00
		dc.w		00,00,00,00,00,-1,00,00
		dc.w		00,00,-1,-1,-1,00,00,00

Warning_Time
		dc.w		00,00,00,-1,00,00,00,00
		dc.w		00,00,00,-1,00,00,00,00
		dc.w		00,00,-1,00,-1,00,00,00
		dc.w		00,00,-1,00,-1,00,00,00
		dc.w		00,-1,00,00,00,-1,00,00
		dc.w		00,-1,00,-1,00,-1,00,00
		dc.w		-1,00,00,00,00,00,-1,00
		dc.w		-1,-1,-1,-1,-1,-1,-1,00

	EndC


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;		Routine clavier sous Inter  	  |
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Kbd_Rout

	movem.l	d0-d2/a0,-(sp)					; On sauve d0 car on s'en sert et qu'on est sous inter
	lea		Ikbd_2_ASCII,a0
	move.b	$fffffc02.w,d0					; ScanCode de la touche qui a declenche l'inter

	IfEq		Debug								; En mode debug, ya pas de exit_Priority
	IfNe		Exit_Priority
	cmpi.b	#$39+$80,d0						; Test d'un eventuel relachement de barre espace ?
	Bne.s		.No_Space
	move.l	#Restore_It,18(sp)			; Adresse de retour modifiee pour revenir illico
	Bra.s		.End_Kbd
.No_Space
	EndC
	EndC
	
	move.b	d0,d1								; On recopie le ScanCode
	and.w		#$7f,d1							; On inhibe l'eventuel relachement
	moveq		#0,d2								; Par defaut : relachement
	btst		#7,d0								; Alors ??? c Quoi ?
	Bne.s		.Let_Up							; Ben c bien un relachement
	moveq		#-1,d2							; On appuie sur la touche, on active le flag
.Let_Up	

	cmpi.b	#$2a,d1							; Shift Left ?
	Bne.s		.No_Shift_Left
	move.w	d2,Shift_Left
	Bra.s		.End_Kbd
.No_Shift_Left
	cmpi.b	#$36,d1							; Shift Right ?
	Bne.s		.No_Shift_Right
	move.w	d2,Shift_Right
	Bra.s		.End_Kbd
.No_Shift_Right
	cmpi.b	#$1d,d1							; Control ?
	Bne.s		.No_Control
	move.w	d2,Control
	Bra.s		.End_Kbd
.No_Control
	cmpi.b	#$38,d1							; Alternate ?
	Bne.s		.No_Alternate
	move.w	d2,Alternate
	Bra.s		.End_Kbd
.No_Alternate
	cmpi.b	#$3a,d1							; CapsLock ?
	Bne.s		.End_Test_Specials_Key
	move.w	d2,CapsLock
	Bra.s		.End_Kbd
.End_Test_Specials_Key
	
	move.b	d0,Key_ScanCode+1
	
	move.b	(a0,d1.w),d1
	tst.w		d2
	beq.s		.Push
	add.b		#$80,d1
.Push	
	move.b	d1,Key_ASCII+1		; On inscrit le caractere ASCII qui correspond a la touche
.End_Kbd
	movem.l	(sp)+,d0-d2/a0

	IfEq		Debug
	Rte
	ElseIf
	Rts
	EndC

Key_ScanCode	ds.w	1
Key_ASCII		ds.w	1
Shift_Left		ds.w	1
Shift_Right		ds.w	1
Control			ds.w	1
Alternate		ds.w	1
CapsLock			ds.w	1

*                   0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
Ikbd_2_ASCII
				dc.b	$00,$1B,$21,$40,$23,$24,$25,$5E,$26,$2A,$28,$29,$2D,$3D,$08,$09
				dc.b	$41,$5A,$45,$52,$54,$59,$55,$49,$4F,$50,$5B,$5D,$0D,$00,$51,$53
				dc.b	$44,$46,$47,$48,$4A,$4B,$4C,$4D,$27,$60,$00,$5C,$57,$58,$43,$56
				dc.b	$42,$4E,$2C,$3B,$3A,$2F,$00,$00,$00,$20,$00,$00,$00,$00,$00,$00
				dc.b	$00,$00,$00,$00,$00,$00,$00,$37,$38,$00,$2D,$34,$00,$36,$2B,$00
				dc.b	$32,$00,$30,$7F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
				dc.b	$00,$00,$00,$28,$29,$2F,$2A,$37,$38,$39,$34,$35,$36,$31,$32,$33
				dc.b	$30,$2E,$0D,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;			Protec Mode part				  |
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		IfNe		Protec_Mode

Bus_Error
	move.l	#$ff000000,$ffff9800.w
	or.w		#$700,SR							; Maske toutes les interruptions

	bsr		Test_Debug

	move.l	2(sp),d0
	lea		Bus_PC,a0
.Search_EXP	
	cmp.l		(a0),d0
	beq.s		.Same_EXP
	tst.l		(a0)+
	bne.s		.Search_EXP
	move.l	d0,-4(a0)
	sub.l		#Start,d0
	lea		BusText+30,a0
	move.l	#$20202020,(a0)+
	move.l	#$20202020,(a0)+
.Hex_2_Dec
	divul.l	#10,d1:d0
	add.b		#$30,d1
	move.b	d1,-(a0)
	cmpi.w	#10,d0
	bhs.s		.Hex_2_Dec
	add.b		#$30,d0
	move.b	d0,-(a0)

	Aff_Text	BusText

.Same_Exp	
	move.w	#$ff,EXP

	or.w		#$f180,$a(sp)
	move.l	#$4e714e71,$c(sp)
	move.l	#Exception,2(sp)
	move.l	#Exception,$10(sp)
	move.w	#$2700,(sp)
	
	clr.l		$ffff9800.w
	Rte

Adr_Error
	move.l	#$000000ff,$ffff9800.w
	or.w		#$700,SR							; Maske toutes les interruptions

	bsr		Test_Debug

	move.l	2(sp),d0
	lea		Adr_PC,a0
.Search_EXP	
	cmp.l		(a0),d0
	beq.s		.Same_EXP
	tst.l		(a0)+
	bne.s		.Search_EXP
	move.l	d0,-4(a0)
	sub.l		#Start,d0
	lea		AdrText+30,a0
	move.l	#$20202020,(a0)+
	move.l	#$20202020,(a0)+
.Hex_2_Dec
	divul.l	#10,d1:d0
	add.b		#$30,d1
	move.b	d1,-(a0)
	cmpi.w	#10,d0
	bhs.s		.Hex_2_Dec
	add.b		#$30,d0
	move.b	d0,-(a0)

	Aff_Text	AdrText

.Same_Exp	
	move.w	#$ff,EXP

	clr.l		$ffff9800.w
	Rte

Ill_Instr
	move.l	#$ff0000ff,$ffff9800.w
	or.w		#$700,SR							; Maske toutes les interruptions

	bsr		Test_Debug

	move.l	2(sp),d0
	lea		Ill_PC,a0
.Search_EXP	
	cmp.l		(a0),d0
	beq.s		.Same_EXP
	tst.l		(a0)+
	bne.s		.Search_EXP
	move.l	d0,-4(a0)
	sub.l		#Start,d0
	lea		IllText+30,a0
	move.l	#$20202020,(a0)+
	move.l	#$20202020,(a0)+
.Hex_2_Dec
	divul.l	#10,d1:d0
	add.b		#$30,d1
	move.b	d1,-(a0)
	cmpi.w	#10,d0
	bhs.s		.Hex_2_Dec
	add.b		#$30,d0
	move.b	d0,-(a0)

	Aff_Text	IllText

.Same_Exp	
	move.w	#$ff,EXP

		IfNe		Break_Illegal	
	move.l	#Exception,2(sp)
		Else
	addq.l	#2,2(sp)
		EndC
		
	clr.l		$ffff9800.w
	Rte

Divi_By_0
	move.l	#$ffff0000,$ffff9800.w
	or.w		#$700,SR							; Maske toutes les interruptions

	bsr		Test_Debug

	move.l	2(sp),d0
	lea		Div_PC,a0
.Search_EXP	
	cmp.l		(a0),d0
	beq.s		.Same_EXP
	tst.l		(a0)+
	bne.s		.Search_EXP
	move.l	d0,-4(a0)
	sub.l		#Start,d0
	lea		DivText+30,a0
	move.l	#$20202020,(a0)+
	move.l	#$20202020,(a0)+
.Hex_2_Dec
	divul.l	#10,d1:d0
	add.b		#$30,d1
	move.b	d1,-(a0)
	cmpi.w	#10,d0
	bhs.s		.Hex_2_Dec
	add.b		#$30,d0
	move.b	d0,-(a0)

	Aff_Text	DivText

.Same_Exp	
	move.w	#$ff,EXP

		IfNe	Break_Div_By_0
	move.l	#Exception,2(sp)
		EndC

	clr.l		$ffff9800.w
	Rte

Viol_Priv
	move.l	#$00ff0000,$ffff9800.w
	or.w		#$700,SR							; Maske toutes les interruptions

	bsr		Test_Debug

	move.l	2(sp),d0
	lea		Pri_PC,a0
.Search_EXP	
	cmp.l		(a0),d0
	beq.s		.Same_EXP
	tst.l		(a0)+
	bne.s		.Search_EXP
	move.l	d0,-4(a0)
	sub.l		#Start,d0
	lea		PriText+36,a0
	move.l	#$20202020,(a0)+
	move.l	#$20202020,(a0)+
.Hex_2_Dec
	divul.l	#10,d1:d0
	add.b		#$30,d1
	move.b	d1,-(a0)
	cmpi.w	#10,d0
	bhs.s		.Hex_2_Dec
	add.b		#$30,d0
	move.b	d0,-(a0)

	Aff_Text	PriText

.Same_Exp	
	move.w	#$ff,EXP

	move.l	#Exception,2(sp)
	move.w	#$2700,(sp)
	
	clr.l		$ffff9800.w
	Rte

Fmt_Error
	move.l	#$0f000000,$ffff9800.w
	or.w		#$700,SR							; Maske toutes les interruptions

	bsr		Test_Debug

	move.l	2(sp),d0
	lea		Fmt_PC,a0
.Search_EXP	
	cmp.l		(a0),d0
	beq.s		.Same_EXP
	tst.l		(a0)+
	bne.s		.Search_EXP
	move.l	d0,-4(a0)
	sub.l		#Start,d0
	lea		FmtText+32,a0
	move.l	#$20202020,(a0)+
	move.l	#$20202020,(a0)+
.Hex_2_Dec
	divul.l	#10,d1:d0
	add.b		#$30,d1
	move.b	d1,-(a0)
	cmpi.w	#10,d0
	bhs.s		.Hex_2_Dec
	add.b		#$30,d0
	move.b	d0,-(a0)

	Aff_Text	FmtText

.Same_Exp	
	move.w	#$ff,EXP

	clr.l		$ffff9800.w
	Rte

; On rend la main au 030 car le host ne repond plus
Host_Error
	Aff_Text	Welcome
	Aff_Text	HostText

	move.w	#-1,EXP
		
	bra		Exception

Test_Debug
	tst.w		EXP
	bne.s		.ThatsAll
	Aff_Text	Welcome
.ThatsAll
	Rts
		EndC

	Section	BSS
Old_System	ds.w		1200/2

	IfNe		Protec_Mode
Bus_PC		ds.l		20
Adr_PC		ds.l		20
Ill_PC		ds.l		20
Div_PC		ds.l		20
Pri_PC		ds.l		20
Fmt_PC		ds.l		20
	EndC
	
	Section	DATA

		IfNe		Protec_Mode
BusText		dc.b	$a,$d,"Erreur de bus , offset :             ",0
AdrText		dc.b	$a,$d,"Erreur adresse, offset :             ",0
IllText		dc.b	$a,$d,"Instr Illegale, offset :             ",0
DivText		dc.b	$a,$d,"Division par 0, offset :             ",0
PriText		dc.b	$a,$d,"Violation de privilege, offset :            ",0
FmtText		dc.b	$a,$d,"Erreur de format, offset :             ",0
HostText		dc.b	$a,$d," Le Host port de repond plus !!!! Programme DSP bloque",0

Welcome		dc.b	27,69,"*************************************"
				dc.b	$a,$d,"*      Skynet's Protection Mode     *"
				dc.b	$a,$d,"*************************************"
				dc.b	$a,$d,"Toooooo Bad, You got an Error !!!"
				dc.b	$a,$d," Press '*' key for Quit"
				dc.b	$a,$d,0
		Even	
		EndC
EXP			dc.w	0

*************************************************
*                                               *
* LIBRAIRIE DE RESOLUTION EN MODE TRUE-COLOR    *
*                                               *
*************************************************
Videl_320_100_True
		dc.l		320*100*16/8+256					* G‚n‚ral
		dc.w		0,320,0,$100
		dc.w		0										* Flag Ordre

		dc.w		254,203,39,46,143,216,0,0		* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0001							* Double Ligne

Videl_320_200_True
		dc.l		320*200*16/8+256					* G‚n‚ral
		dc.w		0,320,0,$100
		dc.w		0										* Flag Ordre

		dc.w		254,203,39,46,143,216,0,0		* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0000

		dc.w		198,150,15,682,139,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_320_400_True
		dc.l		320*200*16/8+256					* G‚n‚ral
		dc.w		0,320,0,$100
		dc.w		0										* Flag Ordre

		dc.w		254,203,39,46,143,216,0,0		* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0010

		dc.w		198,150,15,682,139,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_640_200_True
		dc.l		640*200*16/8+256					* G‚n‚ral
		dc.w		0,640,0,$100
		dc.w		0										* Flag Ordre

		dc.w		510,409,80,113,290,434,0,0		* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0100

Videl_640_400_True
		dc.l		640*400*16/8+256					* G‚n‚ral
		dc.w		0,640,0,$100
		dc.w		0										* Flag Ordre

		dc.w		510,409,80,113,290,434,0,0		* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0110

Videl_384_128_True
		dc.l		384*128*16/8+256					* G‚n‚ral
		dc.w		0,384,0,$100
		dc.w		0										* Flag Ordre

		dc.w		254,203,39,14,175,216,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0001							* Double Ligne

Videl_768_240_True
		dc.l		768*240*16/8+256					* G‚n‚ral
		dc.w		0,768,0,$100
		dc.w		0										* Flag Ordre

		dc.w		510,409,80,49,354,434,0,0		* RVB
		dc.w		625,613,47,87,567,619
		dc.w		$181,%0100

Videl_768_256_True
		dc.l		768*256*16/8+256					* G‚n‚ral
		dc.w		0,768,0,$100
		dc.w		0										* Flag Ordre

		dc.w		510,409,80,49,354,434,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0100

Videl_768_480_True
		dc.l		768*480*16/8+256					* G‚n‚ral
		dc.w		0,768,0,$100
		dc.w		0										* Flag Ordre

		dc.w		510,409,80,49,354,434,0,0		* RVB
		dc.w		624,613,47,86,566,619
		dc.w		$181,%0110

Videl_768_512_True
		dc.l		768*512*16/8+256					* G‚n‚ral
		dc.w		0,768,0,$100
		dc.w		0										* Flag Ordre

		dc.w		510,409,80,49,354,434,0,0		* RVB
		dc.w		624,613,47,70,582,619
		dc.w		$181,%0110

Videl_384_240_True
		dc.l		384*240*16/8+256					* G‚n‚ral
		dc.w		0,384,0,$100
		dc.w		0										* Flag Ordre

		dc.w		254,203,39,14,175,216,0,0		* RVB
		dc.w		625,613,47,87,567,619
		dc.w		$181,%0000

		dc.w		240,160,0,714,151,200,0,0		* VGA 52.11 Hz
 		dc.w		1207,1300,0,163,1123,1203
		dc.w		$186,%0101

Videl_384_256_True
		dc.l		384*256*16/8+256					* G‚n‚ral
		dc.w		0,384,0,$100
		dc.w		0										* Flag Ordre

		dc.w		254,203,39,14,175,216,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0000

		dc.w		240,160,0,714,151,200,0,0		* VGA 52.11 Hz
 		dc.w		1207,1300,0,131,1155,1203
		dc.w		$186,%0101

Videl_384_480_True
		dc.l		384*480*16/8+256					* G‚n‚ral
		dc.w		0,384,0,$100
		dc.w		0										* Flag Ordre

		dc.w		254,203,39,14,175,216,0,0		* RVB
		dc.w		625,613,47,86,566,619
		dc.w		$181,%0010

		dc.w		240,160,0,714,151,200,0,0		* VGA 50.2 Hz
 		dc.w		1257,1300,0,163,1123,1253
		dc.w		$186,%0100

Videl_384_512_True
		dc.l		384*512*16/8+256					* G‚n‚ral
		dc.w		0,384,0,$100
		dc.w		0										* Flag Ordre

		dc.w		254,203,39,14,175,216,0,0		* RVB
		dc.w		625,613,47,70,582,619
		dc.w		$181,%0010

		dc.w		240,160,0,714,151,200,0,0		* VGA 50.2 Hz
 		dc.w		1257,1300,0,131,1155,1253
		dc.w		$186,%0100

*************************************************
*                                               *
* LIBRAIRIE DE RESOLUTION EN MODE 2 COULEURS    *
*                                               *
*************************************************

Videl_640_200_2
		dc.l		640*200/8+256						* G‚n‚ral
		dc.w		0,40,0,$400
		dc.w		0										* Flag Ordre

		dc.w		510,409,80,1007,160,434,0,0	* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0100

		dc.w		198,141,21,627,80,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001


Videl_640_400_2
		dc.l		640*400/8+256						* G‚n‚ral
		dc.w		0,40,0,$400
		dc.w		0										* Flag Ordre

		dc.w		510,409,80,1007,160,434,0,0	* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0110

		dc.w		198,141,21,627,80,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001

Videl_768_256_2
		dc.l		768*256/8+256						* G‚n‚ral
		dc.w		0,48,0,$400
		dc.w		0										* Flag Ordre

		dc.w		510,409,80,943,224,434,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0100


*************************************************
*                                               *
* LIBRAIRIE DE RESOLUTION EN MODE 4 COULEURS    *
*                                               *
*************************************************

Videl_320_200_4
		dc.l		320*200*2/8+256					* G‚n‚ral
		dc.w		0,40,1,$0
		dc.w		-1										* Flag Ordre

		dc.w		62,48,8,569,18,52,0,0			* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0000

		dc.w		23,18,1,522,9,17,0,0				* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_320_400_4
		dc.l		320*400*2/8+256					* G‚n‚ral
		dc.w		0,40,1,$0
		dc.w		-1										* Flag Ordre

		dc.w		62,48,8,569,18,52,0,0			* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0010

		dc.w		23,18,1,522,9,17,0,0				* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_640_200_4
		dc.l		640*200*2/8+256					* G‚n‚ral
		dc.w		0,80,1,$0
		dc.w		-1										* Flag Ordre

		dc.w		62,48,8,2,32,52,0,0				* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0100

		dc.w		23,18,1,526,13,17,0,0			* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001

Videl_640_400_4
		dc.l		640*400*2/8+256					* G‚n‚ral
		dc.w		0,80,1,$0
		dc.w		-1										* Flag Ordre

		dc.w		62,48,8,2,32,52,0,0				* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0110

		dc.w		23,18,1,526,13,17,0,0			* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001

Videl_384_256_4
		dc.l		384*256*2/8+256					* G‚n‚ral
		dc.w		0,48,1,$0
		dc.w		-1										* Flag Ordre

		dc.w		62,48,8,562,27,52,0,0			* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0000

Videl_768_256_4
		dc.l		768*256*2/8+256					* G‚n‚ral
		dc.w		0,96,1,$0
		dc.w		-1										* Flag Ordre

		dc.w		62,48,8,567,32,52,0,0			* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0100

*************************************************
*                                               *
* LIBRAIRIE DE RESOLUTION EN MODE 16 COULEURS   *
*                                               *
*************************************************

Videl_320_200_16
		dc.l		320*200*4/8+256					* G‚n‚ral
		dc.w		0,80,0,$0
		dc.w		0										* Flag Ordre

		dc.w		254,203,39,12,109,216,0,0		* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0000

		dc.w		198,141,21,650,107,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_320_400_16
		dc.l		320*400*4/8+256					* G‚n‚ral
		dc.w		0,80,0,$0
		dc.w		0										* Flag Ordre

		dc.w		254,203,39,12,109,216,0,0		* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0010

		dc.w		198,141,21,650,107,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_640_200_16
		dc.l		640*200*4/8+256					* G‚n‚ral
		dc.w		0,160,0,$0
		dc.w		0										* Flag Ordre

		dc.w		510,409,80,77,254,434,0,0		* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0100

		dc.w		198,141,21,675,124,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001

Videl_640_400_16
		dc.l		640*400*4/8+256					* G‚n‚ral
		dc.w		0,160,0,$0
		dc.w		0										* Flag Ordre

		dc.w		510,409,80,77,254,434,0,0		* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0110

		dc.w		198,141,21,675,124,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001

Videl_384_256_16
		dc.l		384*256*4/8+256					* G‚n‚ral
		dc.w		0,96,0,$0
		dc.w		0										* Flag Ordre

		dc.w		254,203,39,748,141,216,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0000

Videl_768_256_16
		dc.l		768*256*4/8+256					* G‚n‚ral
		dc.w		0,192,0,$0
		dc.w		0										* Flag Ordre

		dc.w		510,409,80,13,318,434,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0100

*************************************************
*                                               *
* LIBRAIRIE DE RESOLUTION EN MODE 256 COULEURS  *
*                                               *
*************************************************

Videl_320_200_256
		dc.l		320*200+256							* G‚n‚ral
		dc.w		0,160,0,$10
		dc.w		0										* Flag Ordre

		dc.w		254,203,39,28,125,216,0,0		* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0000

		dc.w		198,141,21,666,123,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_320_400_256
		dc.l		320*400+256							* G‚n‚ral
		dc.w		0,160,0,$10
		dc.w		0										* Flag Ordre

		dc.w		254,203,39,28,125,216,0,0		* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0010

		dc.w		198,141,21,666,123,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_640_200_256
		dc.l		640*200+256							* G‚n‚ral
		dc.w		0,320,0,$10
		dc.w		0										* Flag Ordre

		dc.w		510,409,80,93,270,434,0,0		* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0100

		dc.w		198,141,21,683,132,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001

Videl_640_400_256
		dc.l		640*400+256							* G‚n‚ral
		dc.w		0,320,0,$10
		dc.w		0										* Flag Ordre

		dc.w		510,409,80,93,270,434,0,0		* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0110

		dc.w		198,141,21,683,132,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001

Videl_384_256_256
		dc.l		384*256+256							* G‚n‚ral
		dc.w		0,192,0,$10
		dc.w		0										* Flag Ordre

		dc.w		254,203,39,764,157,216,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0000

Videl_768_256_256
		dc.l		768*256+256							* G‚n‚ral
		dc.w		0,384,0,$10
		dc.w		0										* Flag Ordre

		dc.w		510,409,80,29,334,434,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0100
