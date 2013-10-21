***********************************************************************
		output	e:\psp.prg
		Section	TEXT

CPU_Time		equ		0	; Display CPU-Time taken by the Replay
DSP_Buffer	equ		2048		; DSP Sample Buffer Size for 49.17 KHz

		XDef		MGTK_Init_Module_Samples,MGTK_Set_Replay_Frequency
		XDef		MGTK_Init_DSP,MGTK_P56_Loader
		XDef		MGTK_Save_Sound,MGTK_Init_Sound,MGTK_Restore_Sound
		XDef		MGTK_Play_Music,MGTK_Pause_Music,MGTK_Stop_Music
		XDef		MGTK_Play_Position,MGTK_Previous_Position
		XDef		MGTK_Next_Position,MGTK_Clear_Voices
		XDef		MGTK_Play_FX_Module,MGTK_Play_FX_Sample
		XDef		MGTK_FX_Voices,MGTK_Voices
		XDef		MGTK_Master_Volume_Left,MGTK_Master_Volume_Right
		XDef		MGTK_Restart_Loop,MGTK_Restart_Done
		XDef		MGTK_Replay_In_Service
		XDef		MGTK_Replay_Satured,MGTK_Replay_Problem

***********************************************************************
***********					Macros				***********
***********************************************************************

WaitDSPToSend	Macro
WaitDSPS\@	btst.b	#1,$ffffa202.w			; Attend que le DSP
			beq.s	WaitDSPS\@			; puisse recevoir
			EndM

WaitDSPToGet	Macro
WaitDSPG\@	btst.b	#0,$ffffa202.w			; Attend que le DSP
			beq.s	WaitDSPG\@			; ait envoy‚ une donn‚e
			EndM

SaveColor		Macro
			Ifne		CPU_Time
				move.l	$ffff9800.w,-(sp)
			EndC
			EndM

RestoreColor	Macro
			Ifne		CPU_Time
				move.l	(sp)+,$ffff9800.w
			EndC
			EndM

CPUTimeColor	Macro
			Ifne		CPU_Time
				move.l	\1,$ffff9800.w
			EndC
			EndM

***********************************************************************
***********				Structures				***********
***********************************************************************

				RsReset

Amiga_Name		rs.b		22
Amiga_Length		rs.w		1	* Taille cod‚e en words
Amiga_Fine_Tune	rs.b		1	* de 0 … 15  =  0 … 7 et -8 … -1
Amiga_Volume		rs.b		1	* de 0 … 64
Amiga_Repeat_Start	rs.w		1
Amiga_Repeat_Length	rs.w		1

Amiga_Size		rs.b		1	* 30 octets


				RsReset

Voice_Next				rs.l		1
Voice_Sample_Start			rs.l		1
Voice_Sample_Offset			rs.l		1
Voice_Sample_Position		rs.l		1
Voice_Sample_Length			rs.l		1
Voice_Sample_Loop_Length		rs.l		1
Voice_Sample_Volume			rs.w		1
Voice_Sample_Period			rs.w		1
Voice_Sample_Fine_Tune		rs.w		1

Voice_Start				rs.l		1
Voice_Volume				rs.w		1
Voice_Period				rs.w		1
Voice_Wanted_Period			rs.w		1

Voice_Note				rs.w		1
Voice_Sample				rs.b		1
Voice_Command				rs.b		1
Voice_Parameters			rs.b		1

Voice_Tone_Port_Direction	rs.b		1
Voice_Tone_Port_Speed		rs.b		1
Voice_Glissando_Control		rs.b		1
Voice_Vibrato_Command		rs.b		1
Voice_Vibrato_Position		rs.b		1
Voice_Vibrato_Control		rs.b		1
Voice_Tremolo_Command		rs.b		1
Voice_Tremolo_Position		rs.b		1
Voice_Tremolo_Control		rs.b		1

Voice_Size				rs.b		1

***********************************************************************
***********										***********
***********	Routines de gestion de Base du Replay :		***********
***********										***********
***********	Fixer Fr‚quence de Replay				***********
***********	Jouer/arrˆter le module, Position			***********
***********	pr‚c‚dente/suivante, Saut … une Position	***********
***********	Et gestion de samples suppl‚mentaires (FX)	***********
***********										***********
***********************************************************************

; Fixer la fr‚quence de Replay
; En Entr‚e :
; d0.w = Valeur du diviseur d'Horloge
;	1 : 49170 Hz, 2 : 32780 Hz, 3 : 24585 Hz, 4 : 19668 Hz
;	5 : 16380 Hz, 7 : 12292 Hz, 9 : 9834 Hz, 11 : 8195 Hz

MGTK_Set_Replay_Frequency
		move.w	d0,MGTK_Frequency_Divider
		move.l	#25175000/256+1,d1
		addq.w	#1,d0
		divu.w	d0,d1
		move.w	d1,MGTK_Replay_Frequency
		rts

; Jouer le module

MGTK_Play_Music
		movem.l	d3-d7/a2-a6,-(sp)

		move.b	#125,MGTK_Music_Tempo
		move.b	#6,MGTK_Music_Speed	
		move.b	#6,MGTK_Music_Counter

		bsr		MGTK_Search_Values_for_Tempo

		move.w	#0,MGTK_Music_Position
		move.w	#-1,MGTK_Pattern_Position
		sf		MGTK_Pattern_Loop_Flag
		clr.w	MGTK_Pattern_Loop_Counter
		clr.w	MGTK_Pattern_Loop_Position
		sf		MGTK_Pattern_Break_Flag
		clr.w	MGTK_Pattern_Break_Position
		sf		MGTK_Position_Jump_Flag
		clr.w	MGTK_Position_Jump_Position
		clr.b	MGTK_Pattern_Delay_Time

		bsr		MGTKClearVoices

		sf		MGTK_Replay_Paused
		sf		MGTK_Replay_Stopped

		movem.l	(sp)+,d3-d7/a2-a6
		bra		MGTK_Init_IT

;
; Met la Musique en Pause
;
MGTK_Pause_Music
		tst.b	MGTK_Replay_Stopped(pc)
		bne.s	MGTK_Pause_Music_Ret
		tst.b	MGTK_Replay_Paused(pc)
		seq		MGTK_Replay_Paused
		tst.b	MGTK_Replay_Paused(pc)
		bne		MGTK_Stop_IT
		bra		MGTK_Init_IT
MGTK_Pause_Music_Ret
		rts
;
; Stoppe la musique
;
MGTK_Stop_Music
		sf		MGTK_Replay_Paused
		st		MGTK_Replay_Stopped
		bra		MGTK_Stop_IT

; Sauter … une position particuliŠre
; En Entr‚e :
; d0.w = Num‚ro de la position

MGTK_Play_Position
		cmp.w	MGTK_Music_Length(pc),d0
		blo.s	MGTK_Play_Position_Ok
		moveq.l	#0,d0
MGTK_Play_Position_Ok
		move.w	d0,MGTK_Position_Jump_Position
		st		MGTK_Position_Jump_Flag
		rts
;
; Position pr‚c‚dente
;
MGTK_Previous_Position
		move.w	MGTK_Music_Position(pc),d0
		beq.s	MGTK_Previous_Position_Skip
		subq.w	#1,d0
MGTK_Previous_Position_Skip
		move.w	d0,MGTK_Position_Jump_Position
		st		MGTK_Position_Jump_Flag
		rts
;
; Position suivante
;
MGTK_Next_Position
		move.w	MGTK_Music_Position(pc),d0
		cmp.w	MGTK_Music_Length,d0
		beq.s	MGTK_Next_Position_Skip
		addq.w	#1,d0
MGTK_Next_Position_Skip
		move.w	d0,MGTK_Position_Jump_Position
		st		MGTK_Position_Jump_Flag
		rts

;
; Gestion des effets sp‚ciaux
;
MGTK_Play_FX_Module
MGTK_Play_FX_Sample
		rts

;
; Remet les voies … z‚ro
;
MGTK_Clear_Voices
		movem.l	d3-d4/d7/a5-a6,-(sp)
		bsr.s	MGTKClearVoices
		movem.l	(sp)+,d3-d4/d7/a5-a6
		rts
				
MGTKClearVoices
		lea.l	MGTK_Panoramics(pc),a5
		move.w	#1234,d4

		lea.l	MGTK_FX_Voices(pc),a6
		moveq.l	#(32+4)-1,d7

MGTK_Clear_A_Voice
		move.l	(a5)+,(a6)+
		clr.l	(a6)+
		clr.l	(a6)+
		clr.l	(a6)+
		clr.l	(a6)+
		clr.l	(a6)+
		clr.w	(a6)+
		move.w	d4,(a6)+
		clr.w	(a6)+

		clr.l	(a6)+
		clr.w	(a6)+
		move.w	d4,(a6)+
		clr.w	(a6)+

		clr.l	(a6)+
		clr.l	(a6)+
		clr.l	(a6)+
		clr.w	(a6)+
		dbra		d7,MGTK_Clear_A_Voice
		rts

***********************************************************************
***********	Initialisations du Module et des Samples	***********
***********************************************************************

; En Entr‚e :
; a0 = Adresse du Module
; a1 = Adresse de la fin de la zone de Travail (WorkSpace)
;
; En Sortie :
; d0 = 0 si tout c'est bien pass‚
;     -3 si pas assez de place pour pr‚parer des Samples

MGTK_Init_Module_Samples
		movem.l	d3-d7/a2-a6,-(sp)

		sf		MGTK_Replay_Paused
		st		MGTK_Replay_Stopped
		move.w	#$ffff,MGTK_Master_Volume_Left
		move.w	#$ffff,MGTK_Master_Volume_Right

		move.l	a0,MGTK_Module_Adr
		move.l	a1,MGTK_WorkSpace_Adr

		lea.l	20+31*30+2(a0),a5		; Par d‚faut
		lea.l	4+128(a5),a6			; Type
		moveq.l	#31,d0				; 31 instruments
		moveq.l	#64,d2				; 64 lignes par pattern
		sf		MGTK_Old_Module

		move.l	$438(a0),d3			; ModFile Chunk

; Formats 4 voies
		moveq.l	#4,d1
		cmp.l	#'M.K.',d3
		beq		MGTK_Format_Ok
		cmp.l	#'M!K!',d3
		beq		MGTK_Format_Ok
		cmp.l	#'M&K&',d3
		beq		MGTK_Format_Ok
		cmp.l	#'FA04',d3
		beq.s	MGTK_Format_Digital
		cmp.l	#'FLT4',d3
		beq.s	MGTK_Format_Ok
		cmp.l	#'RASP',d3
		beq.s	MGTK_Format_Ok

; Formats 6 voies
		moveq.l	#6,d1
		cmp.l	#'FA06',d3
		beq.s	MGTK_Format_Digital
		cmp.l	#'6CHN',d3
		beq.s	MGTK_Format_Ok

; Formats 8 voies
		moveq.l	#8,d1
		cmp.l	#'FA08',d3
		beq.s	MGTK_Format_Digital
		cmp.l	#'8CHN',d3
		beq.s	MGTK_Format_Ok
		cmp.l	#'CD81',d3
		beq.s	MGTK_Format_Ok
		cmp.l	#'FLT8',d3
		beq.s	MGTK_Format_Ok
		cmp.l	#'OCTA',d3
		beq.s	MGTK_Format_Ok

; Formats xxCH xx voies
		cmp.w	#'CH',d3
		bne.s	MGTK_Format_Old

		sub.l	#'00'*65536,d3
		rol.l	#8,d3
		move.b	d3,d1
		ext.w	d1
		mulu.w	#10,d1
		rol.l	#8,d3
		add.b	d3,d1		
		bra.s	MGTK_Format_Ok

; Si rien de sp‚cial alors c'est un ancien module 15 instruments
MGTK_Format_Old
		lea.l	20+15*30+2(a0),a5
		lea.l	128(a5),a6
		moveq.l	#15,d0
		moveq.l	#4,d1
		st		MGTK_Old_Module
		bra.s	MGTK_Format_Ok

MGTK_Format_Digital
		move.w	(a6)+,d2
		addq.l	#2,a6

MGTK_Format_Ok
		move.l	a5,MGTK_Sequence_Adr	; Adresse de la s‚quence
		move.l	a6,MGTK_Patterns_Adr	; Adresse des patterns
		move.w	d0,MGTK_Nb_Samples		; Nombre d'instruments
		move.w	d1,MGTK_Nb_Voices		; Nombre de voies
		move.w	d2,MGTK_Pattern_Length

		lsl.w	#2,d1
		move.w	d1,MGTK_Line_Size		; Taille d'une 'ligne'
		mulu.w	d2,d1
		move.w	d1,MGTK_Pattern_Size	; Taille d'un pattern

		move.b	-2(a5),d0
		move.w	d0,MGTK_Music_Length	; Longueur du module
		move.b	-1(a5),d2
		cmp.b	d0,d2				; le Restart
		blo.s	MGTK_Restart_Ok		; est-il coh‚rent ?
		moveq.l	#0,d2				; si non, Restart = 0
MGTK_Restart_Ok
		move.w	d2,MGTK_Music_Restart

		subq.w	#1,d0				; Parcours la s‚quence
		moveq.l	#0,d1				; jusqu'… la derniŠre
MGTK_Sequence_Loop						; position
		move.b	(a5)+,d2				; No Pattern
		cmp.b	d1,d2				; Plus grand
		blo.s	MGTK_Seq_No_Max		; que le maximum ?
		move.b	d2,d1				; alors Nouveau maximum
MGTK_Seq_No_Max
		dbra		d0,MGTK_Sequence_Loop

		addq.w	#1,d1				; Nombre de patterns
		mulu.w	MGTK_Pattern_Size(pc),d1	; Taille totale

		movea.l	MGTK_Patterns_Adr(pc),a1	; Adresse du d‚but
		lea.l	(a1,d1.l),a1			; Des samples

		lea.l	20(a0),a2				; Pointe sur Infos Samples
		moveq.l	#0,d1
		move.w	MGTK_Nb_Samples(pc),d7
		subq.w	#1,d7

MGTK_Total_Length
		moveq.l	#0,d3				; Longueur
		move.w	Amiga_Length(a2),d3		; du sample
		add.l	d3,d3				; * 2 car stock‚ en words
		add.l	d3,d1				; Ajoute au total
		lea.l	Amiga_Size(a2),a2		; Instrument suivant
		dbra		d7,MGTK_Total_Length	; Calcule longueur totale


; Recopie les samples … la fin de la zone de travail temporaire
; pour justement pouvoir travailler dessus, les pr‚parer au bouclage

		movea.l	MGTK_WorkSpace_Adr(pc),a4
		lea.l	(a1,d1.l),a3			; Adresse fin des samples
MGTK_Move_Samples
		move.w	-(a3),-(a4)
		subq.l	#2,d1
		bne.s	MGTK_Move_Samples

; Maintenant, on bosse sur les samples
		lea.l	20(a0),a0				; Pointe sur 1er Sample
		lea.l	MGTK_Samples_Adr(pc),a2	; Adresse des samples

		move.w	MGTK_Nb_Samples(pc),d7
		subq.w	#1,d7

MGTK_Init_Samples
		clr.l	(a2)+					; Adresse Nulle par d‚faut
		move.w	Amiga_Length(a0),d3			; Longueur Nulle ?
		beq.s	MGTK_Init_Next_Sample		; Alors pas d'instrument

		move.l	a1,-4(a2)					; Sinon Note Adresse

		move.w	Amiga_Repeat_Length(a0),d5	; Longueur de Boucle
		cmp.w	#1,d5					; sup‚rieure … 1 ?
		bhi.s	MGTK_Repeat_Length			; Alors il y a bouclage

MGTK_No_Repeat_Length
		subq.w	#1,d3
MGTK_Copy_Sample_Loop
		move.w	(a4)+,(a1)+				; Recopie simplement
		dbra		d3,MGTK_Copy_Sample_Loop		; le sample

		move.w	#672/4-1,d0
MGTK_Clear_End_Sample_Loop					; et met du vide aprŠs
		clr.l	(a1)+					; car ne boucle pas
		dbra		d0,MGTK_Clear_End_Sample_Loop

		clr.w	Amiga_Repeat_Start(a0)
		clr.w	Amiga_Repeat_Length(a0)
		bra.s	MGTK_Init_Next_Sample


MGTK_Repeat_Length
		move.w	Amiga_Repeat_Start(a0),d4	; D‚but de boucle ?
		beq.s	MGTK_No_Repeat_Start		; Si Non, Jump

		move.w	d4,d0
		subq.w	#1,d0
MGTK_Copy_Sample_Start
		move.w	(a4)+,(a1)+				; Recopie la partie
		dbra		d0,MGTK_Copy_Sample_Start	; avant la boucle

MGTK_No_Repeat_Start
		movea.l	a1,a3					; Note d‚but de Boucle
		move.w	d5,d0					; Longueur de la Boucle
		subq.w	#1,d0
MGTK_Copy_First_Loop
		move.w	(a4)+,(a1)+				; Recopie la boucle
		dbra		d0,MGTK_Copy_First_Loop		; une premiŠre fois

		move.w	#672/2-1,d0
MGTK_Make_Loop_Buffer
		move.w	(a3)+,(a1)+				; Fait le buffer
		dbra		d0,MGTK_Make_Loop_Buffer		; de bouclage

		sub.w	d5,d3
		sub.w	d4,d3				; Saute la partie aprŠs
		lea.l	(a4,d3.w*2),a4			; la boucle qui ne sert … rien

		add.w	d5,d4
		move.w	d4,Amiga_Length(a0)
		move.w	d5,Amiga_Repeat_Length(a0)

MGTK_Init_Next_Sample
		cmpa.l	a4,a1
		bhi.s	MGTK_Init_Samples_Error

		lea.l	Amiga_Size(a0),a0
		dbra		d7,MGTK_Init_Samples

		move.l	a1,MGTK_Module_End_Adr

		bsr		MGTKClearVoices
		movem.l	(sp)+,d3-d7/a2-a6
		moveq.l	#0,d0
		rts

MGTK_Init_Samples_Error
		movem.l	(sp)+,d3-d7/a2-a6
		moveq.l	#-3,d0
		rts

***********************************************************************
***********			   Initialisation DSP			***********
***********************************************************************

; Charge le Programme DSP et v‚rifie son fonctionnement
; En Sortie:
; d0 = 0 si tout c'est bien pass‚
;     -1 si le programme DSP n'a pu ˆtre charg‚

MGTK_Init_DSP
		pea.l	(a2)
		pea.l	MGTKInitDSP(pc)
		move.w	#38,-(sp)			; Supexec
		trap		#14				; XBios
		addq.l	#6,sp
		movea.l	(sp)+,a2
		move.l	MGTK_DSP_Ok(pc),d0
		rts
MGTKInitDSP
		move.w	#113,-(sp)			; DSP_RequestUniqueAbility
		trap		#14					; XBios
		addq.l	#2,sp

		move.w	d0,-(sp)				; No Ability
		pea.l	MGTK_DSP_Replay_Size.w	; Longueur en Mots DSP
		pea.l	MGTK_DSP_Replay_Code(pc)	; Adresse du code binaire
		move.w	#109,-(sp)			; Dsp_ExecProg
		trap		#14					; XBios
		lea.l	12(sp),sp

MGTK_Connect
		move.l	#87654321,$ffffa204.w
		moveq.l	#0,d0

MGTK_Connect_Get
		btst.b	#0,$ffffa202.w
		bne.s	MGTK_DSP_Test
		addq.l	#1,d0
		cmp.l	#100000,d0
		beq.s	MGTK_DSP_Error
		bra.s	MGTK_Connect_Get

MGTK_DSP_Test
		move.l	$ffffa204.w,d0
		cmp.l	#12345678,d0

		move.l	#0,MGTK_DSP_Ok
		rts

MGTK_DSP_Error
		move.l	#-1,MGTK_DSP_Ok
		rts

MGTK_DSP_Ok
		ds.l		1

***********************************************************************
***********				Loader de P56				***********
***********		A appeler en mode superviseur !		***********
***********************************************************************

; Permet de lancer un nouveau programme DSP en plus du SoundTrack
; En Entr‚e :
; a0 pointe sur le programme DSP au format binaire
; d0 contient la taille du programme en words DSP
;

MGTK_P56_Loader
		lea.l	$ffffa204.w,a1
		move.b	#$80+$12,-3(a1)	; Host User Command, adresse $24
MGTK_P56_Loader_Wait1
		tst.b	-3(a1)
		bmi.s	MGTK_P56_Loader_Wait1
MGTK_P56_Loader_Wait2
		WaitDSPToGet
		move.l	(a1),d1
		and.l	#$00ffffff,d1
		cmp.l	#'P56',d1
		bne.s	MGTK_P56_Loader_Wait2
		subq.w	#1,d0
MGTK_P56_Loader_Loop
		moveq.l	#0,d1
		move.b	(a0)+,d1
		swap.w	d1
		move.w	(a0)+,d1
		WaitDSPToSend
		move.l	d1,(a1)
		dbra		d0,MGTK_P56_Loader_Loop
		WaitDSPToSend
		move.l	#-1,(a1)
		rts

***********************************************************************
***********		Initialisations SystŠme Sonore		***********
***********************************************************************

MGTK_Init_Sound
		pea.l	(a2)
		pea.l	MGTKInitSound(pc)
		move.w	#38,-(sp)			; Supexec
		trap		#14				; XBios
		addq.l	#6,sp
		movea.l	(sp)+,a2
		rts
MGTKInitSound
* Stoppe la lecture DMA au cas o—...
		clr.b	$ffff8901.w

* DAC sur piste 0 (quartet fort)
		move.b	#$0f,$ffff8920.w

* Source External Input sur Horloge Interne 25.175 MHz, Handshaking Off
* Source ADC Input sur Horloge Interne 25.175 MHz, Handshaking Off
		move.b	#%00010001,$ffff8930.w

* Source DSP-Xmit sur Horloge Interne 25.175 MHz, DSP Tristated, Handshaking Off
* Source DMA-Play sur Horloge Interne 25.175 MHz
		move.b	#%00010001,$ffff8931.w

* Destination External Output connect‚e … Source DSP-Xmit, Handshaking Off
* Destination DAC Output connect‚ … DSP-Xmit, Handshaking Off
		move.b	#%00110011,$ffff8932.w
* Destination DMA Record connect‚e … Source DSP-Xmit, Handshaking Off
* Destination DSP-Rec connect‚ … DMA-Play, Handshaking Off, Tristated
		move.b	#%00010011,$ffff8933.w

* Seulement Matrice et pas le PSG-Yamaha
		move.b	#%10,$ffff8937.w
		rts

MGTK_Save_Sound
		pea.l	(a2)
		pea.l	MGTKSaveSound(pc)
		move.w	#38,-(sp)			; Supexec
		trap		#14				; XBios
		addq.l	#6,sp
		movea.l	(sp)+,a2
		rts
MGTKSaveSound
		lea.l	MGTK_Old_Sound_System(pc),a0
		move.w	$ffff8900.w,(a0)+		; Interruptions, Son DMA
		bclr.b	#7,$ffff8901.w			; Registres PlayBack
		move.b	$ffff8903.w,(a0)+		; Start - High
		move.b	$ffff8905.w,(a0)+		; Start - Med
		move.b	$ffff8907.w,(a0)+		; Start - Low
		move.b	$ffff890f.w,(a0)+		; End - High
		move.b	$ffff8911.w,(a0)+		; End - Med
		move.b	$ffff8913.w,(a0)+		; End - Low
		bset.b	#7,$ffff8901.w			; Registres Record
		move.b	$ffff8903.w,(a0)+		; Start - High
		move.b	$ffff8905.w,(a0)+		; Start - Med
		move.b	$ffff8907.w,(a0)+		; Start - Low
		move.b	$ffff890f.w,(a0)+		; End - High
		move.b	$ffff8911.w,(a0)+		; End - Med
		move.b	$ffff8913.w,(a0)+		; End - Low

		move.w	$ffff8920.w,(a0)+		; Nb Voies, 8/16, Mono/Stereo
		move.w	$ffff8930.w,(a0)+		; Matrice : Sources
		move.w	$ffff8932.w,(a0)+		; Matrice : Destinations
		move.w	$ffff8934.w,(a0)+		; Prescales d'horloge
		move.w	$ffff8936.w,(a0)+		; Nb Voies Record,source ADDERIN
		move.w	$ffff8938.w,(a0)+		; Source ADC + Volumes entr‚es
		move.w	$ffff893a.w,(a0)+		; Volumes de Sortie
		rts

MGTK_Restore_Sound
		pea.l	(a2)
		pea.l	MGTKRestoreSound(pc)
		move.w	#38,-(sp)			; Supexec
		trap		#14				; XBios
		addq.l	#6,sp
		movea.l	(sp)+,a2
		rts
MGTKRestoreSound
		lea.l	MGTK_Old_Sound_System(pc),a0
		move.w	(a0)+,d0
		bclr.b	#7,$ffff8901.w			; Registres PlayBack
		move.b	(a0)+,$ffff8903.w		; Start - High
		move.b	(a0)+,$ffff8905.w		; Start - Med
		move.b	(a0)+,$ffff8907.w		; Start - Low
		move.b	(a0)+,$ffff890f.w		; End - High
		move.b	(a0)+,$ffff8911.w		; End - Med
		move.b	(a0)+,$ffff8913.w		; End - Low
		bset.b	#7,$ffff8901.w			; Registres Record
		move.b	(a0)+,$ffff8903.w		; Start - High
		move.b	(a0)+,$ffff8905.w		; Start - Med
		move.b	(a0)+,$ffff8907.w		; Start - Low
		move.b	(a0)+,$ffff890f.w		; End - High
		move.b	(a0)+,$ffff8911.w		; End - Med
		move.b	(a0)+,$ffff8913.w		; End - Low
		move.w	d0,$ffff8900.w			; Interruptions, Son DMA

		move.w	(a0)+,$ffff8920.w		; Nb Voies, 8/16, Mono/Stereo
		move.w	(a0)+,$ffff8930.w		; Matrice : Sources
		move.w	(a0)+,$ffff8932.w		; Matrice : Destinations
		move.w	(a0)+,$ffff8934.w		; Prescales d'horloge
		move.w	(a0)+,$ffff8936.w		; Nb Voies Record,source ADDERIN
		move.w	(a0)+,$ffff8938.w		; Source ADC + Volumes entr‚es
		move.w	(a0)+,$ffff893a.w		; Volumes de Sortie

		move.b	#$80+$14,$ffffa201.w	; Efface Buffer Sample DSP
		rts

***********************************************************************
***********		Sauvegardes systŠme sonore			***********
***********************************************************************

MGTK_Old_Sound_System
			ds.w		1			; Interruptions, Son DMA
			ds.b		3			; Playback Start
			ds.b		3			; Playback End
			ds.b		3			; Record Start
			ds.b		3			; Record End
			ds.w		1			; Nb Voies, 8/16, Mono/Stereo
			ds.w		1			; Matrice : Sources
			ds.w		1			; Matrice : Destinations
			ds.w		1			; Prescales d'horloge
			ds.w		1			; Nb Voies Record,source ADDERIN
			ds.w		1			; Source ADC + Volumes entr‚es
			ds.w		1			; Volumes de Sortie

***********************************************************************
***********		   Controle des Interruptions			***********
***********************************************************************

; Installe l'interruption Timer A du Player
; Connecte le DSP … la matrice sonore

MGTK_Init_IT
		pea.l	(a2)
		pea.l	MGTK_Replay_Timer(pc)		; Adresse Vecteur
		moveq.l	#0,d0
		move.b	MGTK_IT_Timer_Data(pc),d0
		move.w	d0,-(sp)
		move.b	MGTK_IT_Timer_Control(pc),d0
		move.w	d0,-(sp)
		clr.w	-(sp)					; Timer No 0
		move.w	#31,-(sp)					; Xbtimer
		trap		#14						; XBios
		lea.l	12(sp),sp
		pea.l	MGTKDSPSoundOn(pc)
		move.w	#38,-(sp)					; Supexec
		trap		#14						; XBios
		addq.l	#6,sp
		movea.l	(sp)+,a2
		rts
MGTKDSPSoundOn
		bset.b	#7,$ffff8931.w				; DSP Enabled
		rts

; EnlŠve l'interruption Timer A du Player
; D‚connecte le DSP de la matrice sonore

MGTK_Stop_IT
		pea.l	(a2)
		clr.l	-(sp)
		clr.l	-(sp)					; Stoppe le
		clr.w	-(sp)					; Timer A
		move.w	#31,-(sp)					; Xbtimer
		trap		#14						; XBios
		lea.l	12(sp),sp
		pea.l	MGTKDSPSoundOff(pc)
		move.w	#38,-(sp)					; Supexec
		trap		#14						; XBios
		addq.l	#6,sp
		movea.l	(sp)+,a2
		rts
MGTKDSPSoundOff
		bclr.b	#7,$ffff8931.w				; DSP Tristated
		rts

***********************************************************************
***********	   Interruptions du Replay Soundtracker		***********
***********************************************************************

MGTK_Replay_Timer
		move.w	#$2700,sr

		move.b	MGTK_IT_Timer_Data(pc),$fffffa1f.w
		move.b	MGTK_IT_Timer_Control(pc),$fffffa19.w

MGTK_Replay_IT
		tst.b	MGTK_Replay_In_Service(pc)
		beq.s	MGTK_Replay_Not_Satured

		st		MGTK_Replay_Satured
		bclr.b	#5,$fffffa0f.w			; … Cause du mode SEI
		rte

MGTK_Replay_Not_Satured
; Signale au DSP qu'on veut causer … la routine Soundtracker
		move.b	#$80+$13,$ffffa201.w	; Host User 0, adresse $26

		SaveColor
		CPUTimeColor		#$dd550088
		movem.l	d0/a6,-(sp)
		lea.l	$ffffa204.w,a6			; Port Host

; DSP es-tu l… ?
		move.l	(a6),d0
		cmp.l	#'MGT',d0
		beq.s	MGTK_Replay_No_Problem

		st		MGTK_Replay_Problem
		bra.s	MGTK_Replay_Ret

MGTK_Replay_No_Problem
		st		MGTK_Replay_In_Service

; Envoie Master Volumes
		clr.w	(a6)
		move.w	MGTK_Master_Volume_Left(pc),2(a6)
		move.w	MGTK_Master_Volume_Right(pc),2(a6)

; Envoie le Nombre de Voies pour le mixage (sans les 4 voies FX)
		move.w	MGTK_Nb_Voices(pc),2(a6)

; Pr‚pare le pointeur sur les voies
		move.l	#MGTK_FX_Voices,MGTK_Voices_Ptr

; Autorise interruption de r‚ception en provenance du DSP
		move.l	#MGTK_Replay_Voices,$3fc.w
		move.b	#$ff,-1(a6)			; $ffffa203.w
		bset.b	#0,-4(a6)				; $ffffa200.w

MGTK_Replay_Ret
		movem.l	(sp)+,d0/a6
		RestoreColor
		bclr.b	#5,$fffffa0f.w			; … Cause du mode SEI
		rte

;
; Mixage des Pistes une par une
;
MGTK_Replay_Voices
		SaveColor
		CPUTimeColor		#0
		movem.l	d0-d3/a0/a5/a6,-(sp)

		lea.l	$ffffa204.w,a6
		bclr.b	#0,-4(a6)			; Inhibe Interruption Rec‚ption

MGTK_Replay_Get
		move.w	2(a6),d0			; Flag Nouvelle voie
		beq		MGTK_Replay_No_More_Voices

		movea.l	MGTK_Voices_Ptr(pc),a5	; Pointe sur la voie courante
		move.l	Voice_Next(a5),d0
		add.l	d0,MGTK_Voices_Ptr

; Envoie les infos sur la voie
; d'abord la voie est-elle active ?

		tst.l	Voice_Sample_Start(a5)
		bne.s	MGTK_Replay_Sample_Ok

MGTK_Replay_No_Voice
		clr.l	(a6)
		WaitDSPToGet
		bra.s	MGTK_Replay_Get

MGTK_Replay_Sample_Ok
		moveq.l	#0,d0
		move.w	Voice_Sample_Volume(a5),d0
		beq.s	MGTK_Replay_No_Voice

; Envoie Volume
		move.l	d0,(a6)

; Envoie fr‚quence relative
		move.l	#428*8363/256/2,d1
		moveq.l	#0,d0			; d1:d0=$800000*(428*8363)
		move.w	MGTK_Replay_Frequency(pc),d2
		mulu.w	Voice_Sample_Period(a5),d2
		divu.l	d2,d1:d0
		lsr.l	d0
		move.l	d0,(a6)

; Explication du calcul :
; Fr‚quence de replay d'une note =
; Base du DO-2 * Periode du DO-2 / Periode de la Note
; Nous on veut le rapport avec la fr‚quence de Replay donc / Freq_Replay
; et r‚sultat … virgule pr‚multipli‚ par $800000 pour le DSP

; Recoie longueur du sample jou‚e dans cette frame
		WaitDSPToGet
		move.l	(a6),d0

		movea.l	Voice_Sample_Start(a5),a0	; Adresse Sample
		move.l	Voice_Sample_Position(a5),d1	; Position
		move.l	d1,d2					; Courante
		add.l	d0,d2					; Position d'arriv‚e

		tst.l	Voice_Sample_Loop_Length(a5)
		bne.s	MGTK_Replay_Loop

MGTK_Replay_No_Loop
		cmp.l	Voice_Sample_Length(a5),d2	; A-t'on d‚pass‚ la fin
		blt.s	MGTK_Replay_Pos_Ok			; du Sample ?

		clr.l	Voice_Sample_Start(a5)		; Oui, alors sample
		bra.s	MGTK_Replay_Pos_Ok			; d‚sactiv‚

MGTK_Replay_Loop
		cmp.l	Voice_Sample_Length(a5),d2	; A-t'on d‚pass‚ la
		blt.s	MGTK_Replay_Pos_Ok			; fin de la boucle ?

		sub.l	Voice_Sample_Loop_Length(a5),d2	; Si oui, reboucle
		bra.s	MGTK_Replay_Loop				; tant qu'il faut

MGTK_Replay_Pos_Ok
		move.l	d2,Voice_Sample_Position(a5)	; Nouvelle position

; Envoi du sample
		lea.l	(a0,d1.l),a0
		lsr.w	d0					; Envoi par paquet de deux

		CPUTimeColor		#$dd550088
		addq.l	#2,a6				; Port Host en word

MGTK_Send_Samples
		move.w	(a0)+,(a6)
MGTK_Send_Samples_Jump
		dbra		d0,MGTK_Send_Samples

; Autorise interruption de r‚ception en provenance du DSP
		bset.b	#0,-6(a6)				; $ffffa200.w

		movem.l	(sp)+,d0-d3/a0/a5/a6
		RestoreColor
		rte


MGTK_Replay_No_More_Voices
		move.b	MGTK_Frequency_Divider+1(pc),$ffff8935.w
		sf		MGTK_Replay_In_Service

; S'occupe de la partition
		move.w	MGTK_IT_Counter(pc),d0
		addq.w	#1,d0
		move.w	d0,MGTK_IT_Counter
		cmp.w	MGTK_IT_Number(pc),d0
		blo.s	MGTK_Replay_Not_Patterns

		CPUTimeColor		#$99990099

		clr.w	MGTK_IT_Counter
		movem.l	d4-d7/a1-a4,-(sp)
		bsr.s	MGTK_Play_Patterns
		movem.l	(sp)+,d4-d7/a1-a4

MGTK_Replay_Not_Patterns
		movem.l	(sp)+,d0-d3/a0/a5/a6
		RestoreColor
		rte

MGTK_Voices_Ptr
		ds.l		1

***********************************************************************
***********			Gestion du Soundtrack			***********
***********************************************************************

MGTK_Play_Patterns
		addq.b	#1,MGTK_Music_Counter
		move.b	MGTK_Music_Counter(pc),d0
		cmp.b	MGTK_Music_Speed(pc),d0
		blo		MGTK_No_New_Note

		clr.b	MGTK_Music_Counter

		tst.b	MGTK_Pattern_Break_Flag(pc)
		bne.s	MGTK_New_Pattern

		tst.b	MGTK_Pattern_Delay_Time(pc)
		beq.s	MGTK_No_Pattern_Delay

		subq.b	#1,MGTK_Pattern_Delay_Time
		bra		MGTK_No_New_Note

MGTK_No_Pattern_Delay
		tst.b	MGTK_Pattern_Loop_Flag(pc)
		beq.s	MGTK_No_Pattern_Loop

		move.w	MGTK_Pattern_Loop_Position(pc),MGTK_Pattern_Position
		sf		MGTK_Pattern_Loop_Flag
		bra		MGTK_New_Notes

MGTK_No_Pattern_Loop
		tst.b	MGTK_Position_Jump_Flag(pc)
		beq.s	MGTK_New_Line

		move.w	MGTK_Position_Jump_Position(pc),d0
		sf		MGTK_Position_Jump_Flag
		clr.w	MGTK_Pattern_Break_Position
		bra.s	MGTK_New_Position

MGTK_New_Line
		addq.w	#1,MGTK_Pattern_Position
		move.w	MGTK_Pattern_Position(pc),d0
		cmp.w	MGTK_Pattern_Length(pc),d0
		blo.s	MGTK_New_Notes

MGTK_New_Pattern
		move.w	MGTK_Music_Position(pc),d0
		addq.w	#1,d0

MGTK_New_Position
		move.w	MGTK_Pattern_Break_Position(pc),MGTK_Pattern_Position
		clr.w	MGTK_Pattern_Break_Position
		sf		MGTK_Pattern_Break_Flag

		cmp.w	MGTK_Music_Length(pc),d0
		blo.s	MGTK_No_Restart

		move.w	MGTK_Music_Restart(pc),d0
		bne.s	MGTK_No_Restart_Tempo

		move.b	#125,MGTK_Music_Tempo
		move.b	#6,MGTK_Music_Speed
		bsr		MGTK_Search_Values_for_Tempo

MGTK_No_Restart_Tempo
		tst.b	MGTK_Restart_Loop(pc)
		bne.s	MGTK_No_Restart

		st		MGTK_Restart_Done
		sf		MGTK_Replay_Paused
		st		MGTK_Replay_Stopped
		clr.b	$fffffa19.w			; Coupe Timer
		bclr.b	#5,$fffffa07.w			; D‚sautorise Timer
		bclr.b	#5,$fffffa13.w			; D‚Maske Timer
		bclr.b	#7,$ffff8931.w			; DSP Tristated

MGTK_No_Restart
		move.w	d0,MGTK_Music_Position

MGTK_New_Notes
		movea.l	MGTK_Module_Adr(pc),a5
		adda.w	#20,a5				; Pointe sur infos samples
		movea.l	MGTK_Sequence_Adr(pc),a0
		move.w	MGTK_Music_Position(pc),d1
		moveq.l	#0,d0
		move.b	(a0,d1.w),d0
		mulu.w	MGTK_Pattern_Size(pc),d0
		movea.l	MGTK_Patterns_Adr(pc),a4
		adda.l	d0,a4				; Pointe sur le Pattern
		move.w	MGTK_Pattern_Position(pc),d0
		mulu.w	MGTK_Line_Size(pc),d0
		adda.w	d0,a4				; Pointe sur la Bonne Ligne

		lea.l	MGTK_Voices(pc),a6
		move.w	MGTK_Nb_Voices(pc),d7
		subq.w	#1,d7
MGTK_New_Notes_Loop
		bsr.s	MGTK_Play_Voice

		lea.l	Voice_Size(a6),a6
		dbra		d7,MGTK_New_Notes_Loop
		rts


MGTK_No_New_Note
		lea.l	MGTK_Voices(pc),a6
		move.w	MGTK_Nb_Voices(pc),d7
		subq.w	#1,d7
MGTK_No_New_Note_Loop

		moveq.l	#0,d0
		move.b	Voice_Command(a6),d0
		jsr		([Jump_Table_2,d0.w*4])

		lea.l	Voice_Size(a6),a6
		dbra		d7,MGTK_No_New_Note_Loop
		rts


MGTK_Play_Voice
		move.w	(a4)+,d1
		move.b	(a4)+,d2
		move.b	(a4)+,Voice_Parameters(a6)

		move.w	d1,d0
		and.w	#$0fff,d0
		move.w	d0,Voice_Note(a6)
		and.w	#$f000,d1
		lsr.w	#8,d1
		move.b	d2,d0
		lsr.b	#4,d0
		add.b	d1,d0
		move.b	d0,Voice_Sample(a6)
		and.b	#$0f,d2
		move.b	d2,Voice_Command(a6)

MGTK_Check_Sample
		moveq.l	#0,d2
		move.b	Voice_Sample(a6),d2
		beq.s	MGTK_No_New_Sample

		subq.w	#1,d2
		lea.l	MGTK_Samples_Adr(pc),a1
		move.l	(a1,d2.w*4),Voice_Start(a6)
		clr.l	Voice_Sample_Offset(a6)
		mulu.w	#Amiga_Size,d2
		moveq.l	#0,d0
		move.w	Amiga_Length(a5,d2.w),d0
		lsl.l	d0
		move.l	d0,Voice_Sample_Length(a6)
		move.w	Amiga_Repeat_Length(a5,d2.w),d0
		lsl.l	d0
		move.l	d0,Voice_Sample_Loop_Length(a6)
		moveq.l	#0,d0
		move.b	Amiga_Volume(a5,d2.w),d0
		move.w	d0,Voice_Volume(a6)
		move.w	d0,Voice_Sample_Volume(a6)
		move.b	Amiga_Fine_Tune(a5,d2.w),d0
		and.w	#$0f,d0
		mulu.w	#12*3*2,d0
		move.w	d0,Voice_Sample_Fine_Tune(a6)

MGTK_No_New_Sample
		tst.w	Voice_Note(a6)
		beq		MGTK_Check_Efx_1

MGTK_Check_Efx_0
		move.w	Voice_Command(a6),d0
		and.w	#$0ff0,d0
		cmp.w	#$0e50,d0
		beq.s	MGTK_Do_Set_Fine_Tune

		move.b	Voice_Command(a6),d0
		subq.b	#3,d0				; 3 = Tone Portamento
		beq		MGTK_Set_Tone_Portamento
		subq.b	#2,d0				; 5 = Tone Porta + Vol Slide
		beq		MGTK_Set_Tone_Portamento
		subq.b	#4,d0				; 9 = Sample Offset
		bne.s	MGTK_Set_Period

		bsr		MGTK_Sample_Offset
		bra.s	MGTK_Set_Period

MGTK_Do_Set_Fine_Tune
		bsr		MGTK_Set_Fine_Tune

MGTK_Set_Period
		lea.l	MGTK_Period_Table(pc),a0
		move.w	Voice_Note(a6),d0
		bsr		MGTK_Find_Period
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.w	(a0),Voice_Period(a6)

		move.w	Voice_Command(a6),d0
		and.w	#$0ff0,d0
		cmp.w	#$0ed0,d0
		bne.s	MGTK_No_Note_Delay
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		beq.s	MGTK_No_Note_Delay
		rts

MGTK_No_Note_Delay
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		move.l	Voice_Start(a6),Voice_Sample_Start(a6)
		move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)

		btst.b	#2,Voice_Vibrato_Control(a6)
		bne.s	MGTK_Vibrato_No_Reset
		clr.b	Voice_Vibrato_Position(a6)
MGTK_Vibrato_No_Reset

		btst.b	#2,Voice_Tremolo_Control(a6)
		bne.s	MGTK_Tremolo_No_Reset
		clr.b	Voice_Tremolo_Position(a6)
MGTK_Tremolo_No_Reset


MGTK_Check_Efx_1
		moveq.l	#0,d0
		move.b	Voice_Command(a6),d0
		jmp		([Jump_Table_1,d0.w*4])

Jump_Table_1
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Position_Jump
		dc.l		MGTK_Volume_Change,MGTK_Pattern_Break
		dc.l		MGTK_E_Commands_1,MGTK_Set_Speed

MGTK_E_Commands_1
		move.b	Voice_Parameters(a6),d0
		and.w	#$f0,d0
		lsr.w	#4,d0
		jmp		([Jump_Table_E1,d0.w*4])

Jump_Table_E1
		dc.l		MGTK_Return,MGTK_Fine_Portamento_Up
		dc.l		MGTK_Fine_Portamento_Down,MGTK_Set_Glissando_Control
		dc.l		MGTK_Set_Vibrato_Control,MGTK_Return
		dc.l		MGTK_Pattern_Loop,MGTK_Set_Tremolo_Control
		dc.l		MGTK_Return,MGTK_Retrig_Note
		dc.l		MGTK_Volume_Fine_Up,MGTK_Volume_Slide_Down
		dc.l		MGTK_Note_Cut,MGTK_Return
		dc.l		MGTK_Pattern_Delay,MGTK_Return

Jump_Table_2
		dc.l		MGTK_Arpeggio,MGTK_Portamento_Up
		dc.l		MGTK_Portamento_Down,MGTK_Tone_Portamento
		dc.l		Mt_Vibrato,MGTK_Tone_Portamento_Plus_Volume_Slide
		dc.l		MGTK_Vibrato_Plus_Volume_Slide,Mt_Tremolo
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Volume_Slide,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_E_Commands_2,MGTK_Return

MGTK_E_Commands_2
		move.b	Voice_Parameters(a6),d0
		and.w	#$f0,d0
		lsr.w	#4,d0
		jmp		([Jump_Table_E2,d0.w*4])

Jump_Table_E2
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Retrig_Note
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Note_Cut,MGTK_Note_Delay
		dc.l		MGTK_Return,MGTK_Return


MGTK_Find_Period
		cmp.w	12*2(a0),d0
		bhs.s	MGTK_Do_Find_Period
		lea.l	12*2(a0),a0
		cmp.w	12*2(a0),d0
		bhs.s	MGTK_Do_Find_Period
		lea.l	12*2(a0),a0

MGTK_Do_Find_Period
		moveq.l	#12-1,d3
MGTK_Find_Period_Loop
		cmp.w	(a0)+,d0
		dbhs		d3,MGTK_Find_Period_Loop
		blo.s	MGTK_Period_Found
		subq.l	#2,a0
MGTK_Period_Found
		rts


MGTK_Period_Nop
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)

MGTK_Return
		rts

MGTK_Arpeggio_Table
		dc.b		0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
		dc.b		1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

MGTK_Arpeggio
		move.b	Voice_Parameters(a6),d1
		beq.s	MGTK_Period_Nop

		moveq.l	#0,d0
		move.b	MGTK_Music_Counter(pc),d0
		move.b	MGTK_Arpeggio_Table(pc,d0.w),d0
		beq.s	MGTK_Period_Nop
		subq.b	#2,d0
		beq.s	MGTK_Arpeggio_2

MGTK_Arpeggio_1
		lsr.w	#4,d1
MGTK_Arpeggio_2
		and.w	#$f,d1

		lea.l	MGTK_Period_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.w	Voice_Period(a6),d0
		bsr.s	MGTK_Find_Period
		move.w	(a0,d1.w*2),Voice_Sample_Period(a6)
		rts


MGTK_Portamento_Up
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0

MGTK_Portamento_Up2
		sub.w	d0,Voice_Period(a6)
		move.w	Voice_Period(a6),d0
		cmp.w	#113,d0
		bhi.s	MGTK_Portamento_Up_Ok
		move.w	#113,Voice_Period(a6)

MGTK_Portamento_Up_Ok
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		rts

 
MGTK_Portamento_Down
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
MGTK_Portamento_Down2
		add.w	d0,Voice_Period(a6)
		move.w	Voice_Period(a6),d0
		cmp.w	#856,d0
		blo.s	MGTK_Portamento_Down_Ok
		move.w	#856,Voice_Period(a6)

MGTK_Portamento_Down_Ok
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		rts


MGTK_Set_Tone_Portamento
		lea.l	MGTK_Period_Table(pc),a0
		move.w	Voice_Note(a6),d0
		bsr		MGTK_Find_Period
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.w	(a0),d0

		move.w	d0,Voice_Wanted_Period(a6)
		move.w	Voice_Period(a6),d1
		sf		Voice_Tone_Port_Direction(a6)
		cmp.w	d1,d0
		beq.s	MGTK_Clear_Tone_Portamento
		bge		MGTK_Period_Nop
		st		Voice_Tone_Port_Direction(a6)
		rts

MGTK_Clear_Tone_Portamento
		clr.w	Voice_Wanted_Period(a6)
		rts

MGTK_Tone_Portamento
		move.b	Voice_Parameters(a6),d0
		beq.s	MGTK_Tone_Portamento_No_Change
		move.b	d0,Voice_Tone_Port_Speed(a6)
		clr.b	Voice_Parameters(a6)

MGTK_Tone_Portamento_No_Change
		tst.w	Voice_Wanted_Period(a6)
		beq		MGTK_Period_Nop
		moveq.l	#0,d0
		move.b	Voice_Tone_Port_Speed(a6),d0
		tst.b	Voice_Tone_Port_Direction(a6)
		bne.s	MGTK_Tone_Portamento_Up

MGTK_Tone_Portamento_Down
		add.w	d0,Voice_Period(a6)
		move.w	Voice_Wanted_Period(a6),d0
		cmp.w	Voice_Period(a6),d0
		bgt.s	MGTK_Tone_Portamento_Set_Period
		move.w	Voice_Wanted_Period(a6),Voice_Period(a6)
		clr.w	Voice_Wanted_Period(a6)
		bra.s	MGTK_Tone_Portamento_Set_Period

MGTK_Tone_Portamento_Up
		sub.w	d0,Voice_Period(a6)
		move.w	Voice_Wanted_Period(a6),d0
		cmp.w	Voice_Period(a6),d0
		blt.s	MGTK_Tone_Portamento_Set_Period
		move.w	Voice_Wanted_Period(a6),Voice_Period(a6)
		clr.w	Voice_Wanted_Period(a6)


MGTK_Tone_Portamento_Set_Period
		move.w	Voice_Period(a6),d0
		tst.b	Voice_Glissando_Control(a6)
		beq.s	MGTK_Glissando_Skip

		lea.l	MGTK_Period_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		bsr		MGTK_Find_Period
		move.w	(a0),d0

MGTK_Glissando_Skip
		move.w	d0,Voice_Sample_Period(a6)
		rts


Mt_Vibrato
		move.b	Voice_Parameters(a6),d0
		beq.s	Mt_Vibrato2
		move.b	Voice_Vibrato_Command(a6),d2
		and.b	#$0f,d0
		beq.s	Mt_VibSkip
		and.b	#$f0,d2
		or.b		d0,d2
Mt_VibSkip
		move.b	Voice_Parameters(a6),d0
		and.b	#$f0,d0
		beq.s	Mt_vibskip2
		and.b	#$0f,d2
		or.b		d0,d2
Mt_vibskip2
		move.b	d2,Voice_Vibrato_Command(a6)
Mt_Vibrato2
		move.b	Voice_Vibrato_Position(a6),d0
		lea.l	MGTK_Sinus_Table(pc),a3
		lsr.w	#2,d0
		and.w	#$001f,d0
		moveq.l	#0,d2
		move.b	Voice_Vibrato_Control(a6),d2
		and.b	#$3,d2
		beq.s	Mt_Vib_Sine
		lsl.b	#3,d0
		cmp.b	#1,d2
		beq.s	Mt_Vib_RampDown
		move.b	#255,d2
		bra.s	Mt_Vib_Set
Mt_Vib_RampDown
		tst.b	Voice_Vibrato_Position(a6)
		bpl.s	Mt_Vib_RampDown2
		move.b	#255,d2
		sub.b	d0,d2
		bra.s	Mt_Vib_Set
Mt_Vib_RampDown2
		move.b	d0,d2
		bra.s	Mt_Vib_Set
Mt_Vib_Sine
		move.b	(a3,d0.w),d2
Mt_Vib_Set
		move.b	Voice_Vibrato_Command(a6),d0
		and.w	#15,d0
		mulu.w	d0,d2
		lsr.w	#7,d2
		move.w	Voice_Period(a6),d0
		tst.b	Voice_Vibrato_Position(a6)
		bmi.s	Mt_VibratoNeg
		add.w	d2,d0
		bra.s	Mt_Vibrato3
Mt_VibratoNeg
		sub.w	d2,d0
Mt_Vibrato3
		move.w	d0,Voice_Sample_Period(a6)
		move.b	Voice_Vibrato_Command(a6),d0
		lsr.w	#2,d0
		and.w	#$003c,d0
		add.b	d0,Voice_Vibrato_Position(a6)
		rts

MGTK_Tone_Portamento_Plus_Volume_Slide
		bsr		MGTK_Tone_Portamento_No_Change
		bra		MGTK_Volume_Slide


MGTK_Vibrato_Plus_Volume_Slide
		bsr.s	Mt_Vibrato2
		bra		MGTK_Volume_Slide

Mt_Tremolo
		move.b	Voice_Parameters(a6),d0
		beq.s	Mt_Tremolo2
		move.b	Voice_Tremolo_Command(a6),d2
		and.b	#$0f,d0
		beq.s	Mt_treskip
		and.b	#$f0,d2
		or.b		d0,d2
Mt_treskip
		move.b	Voice_Parameters(a6),d0
		and.b	#$f0,d0
		beq.s	Mt_treskip2
		and.b	#$0f,d2
		or.b		d0,d2
Mt_treskip2
		move.b	d2,Voice_Tremolo_Command(a6)
Mt_Tremolo2
		move.b	Voice_Tremolo_Position(a6),d0
		lea.l	MGTK_Sinus_Table(pc),a3
		lsr.w	#2,d0
		and.w	#$001f,d0
		moveq.l	#0,d2
		move.b	Voice_Tremolo_Control(a6),d2
		and.b	#$3,d2
		beq.s	Mt_tre_sine
		lsl.b	#3,d0
		cmp.b	#1,d2
		beq.s	Mt_tre_rampdown
		move.b	#255,d2
		bra.s	Mt_tre_set
Mt_tre_rampdown
		tst.b	Voice_Tremolo_Position(a6)
		bpl.s	Mt_tre_rampdown2
		move.b	#255,d2
		sub.b	d0,d2
		bra.s	Mt_tre_set
Mt_tre_rampdown2
		move.b	d0,d2
		bra.s	Mt_tre_set
Mt_tre_sine
		move.b	(a3,d0.w),d2
Mt_tre_set
		move.b	Voice_Tremolo_Command(a6),d0
		and.w	#15,d0
		mulu.w	d0,d2
		lsr.w	#6,d2
		moveq.l	#0,d0
		move.w	Voice_Volume(a6),d0
		tst.b	Voice_Tremolo_Position(a6)
		bmi.s	Mt_TremoloNeg
		add.w	d2,d0
		bra.s	Mt_Tremolo3
Mt_TremoloNeg
		sub.w	d2,d0
Mt_Tremolo3
		bpl.s	Mt_TremoloSkip
		clr.w	d0
Mt_TremoloSkip
		cmp.w	#$40,d0
		bls.s	Mt_TremoloOk
		move.w	#$40,d0
Mt_TremoloOk
		move.w	d0,Voice_Sample_Volume(a6)
		move.b	Voice_Tremolo_Command(a6),d0
		lsr.w	#2,d0
		and.w	#$003c,d0
		add.b	d0,Voice_Tremolo_Position(a6)
		bra		MGTK_Period_Nop


MGTK_Sample_Offset
		move.l	Voice_Sample_Offset(a6),d0
		moveq.l	#0,d1
		move.b	Voice_Parameters(a6),d1
		beq.s	MGTK_Sample_Offset_No_New

		lsl.w	#8,d1
		move.l	d1,d0
MGTK_Sample_Offset_No_New

		add.l	Voice_Sample_Offset(a6),d0
		cmp.l	Voice_Sample_Length(a6),d0
		ble.s	MGTK_Sample_Offset_Ok
		move.l	Voice_Sample_Length(a6),d0
MGTK_Sample_Offset_Ok
		move.l	Voice_Start(a6),Voice_Sample_Start(a6)
		move.l	d0,Voice_Sample_Offset(a6)
		move.l	d0,Voice_Sample_Position(a6)
		rts


MGTK_Volume_Slide
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
		lsr.w	#4,d0
		beq.s	MGTK_Volume_Slide_Down

MGTK_Volume_Slide_Up
		add.w	d0,Voice_Volume(a6)
		cmp.w	#$40,Voice_Volume(a6)
		ble.s	MGTK_Volume_Slide_Up_Ok
		move.w	#$40,Voice_Volume(a6)

MGTK_Volume_Slide_Up_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		bra		MGTK_Period_Nop


MGTK_Volume_Slide_Down
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0

MGTK_Volume_Slide_Down2
		sub.w	d0,Voice_Volume(a6)
		bpl.s	MGTK_Volume_Slide_Down_Ok
		clr.w	Voice_Volume(a6)

MGTK_Volume_Slide_Down_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		bra		MGTK_Period_Nop


MGTK_Position_Jump
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0

		move.w	d0,MGTK_Position_Jump_Position
		st		MGTK_Position_Jump_Flag
		rts


MGTK_Volume_Change
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
		cmp.b	#$40,d0
		ble.s	MGTK_Volume_Change_Ok
		moveq.l	#$40,d0

MGTK_Volume_Change_Ok
		move.w	d0,Voice_Volume(a6)
		move.w	d0,Voice_Sample_Volume(a6)
		rts


MGTK_Pattern_Break
		moveq.l	#0,d0

		tst.b	MGTK_Old_Module(pc)
		bne.s	MGTK_Pattern_Break_Ok

		move.b	Voice_Parameters(a6),d0

		move.w	d0,d2			; Codage en BCD
		lsr.w	#4,d0			; premier chiffre
		mulu.w	#10,d0			; les dizaines
		and.w	#$0f,d2			; deuxiŠme chiffre
		add.w	d2,d0			; les unit‚s

		cmp.w	MGTK_Pattern_Length(pc),d0
		blo.s	MGTK_Pattern_Break_Ok
		moveq.l	#0,d0
	
MGTK_Pattern_Break_Ok
		move.w	d0,MGTK_Pattern_Break_Position
		st		MGTK_Pattern_Break_Flag
		rts


MGTK_Set_Speed
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
		beq.s	MGTK_End
		cmp.b	#32,d0
		bhi.s	MGTK_Set_Tempo
		move.b	d0,MGTK_Music_Speed
MGTK_End	rts

MGTK_Set_Tempo
		move.b	d0,MGTK_Music_Tempo

MGTK_Search_Values_for_Tempo
		movem.l	d0-d3,-(sp)
		moveq.l	#0,d0
		move.b	MGTK_Music_Tempo(pc),d0

		moveq.l	#125,d1					; 125
		mulu.w	MGTK_Replay_Frequency(pc),d1	; * Frequence Replay
		divu.l	#50,d1					; / 50
		divu.l	d0,d1					; / Tempo
		moveq.l	#0,d3					; = Nb Samples / Tick
MGTK_Search_Length_Loop
		addq.b	#1,d3					; Cherche en
		move.l	d1,d2					; combien de fois
		divu.w	d3,d2					; on peut traiter
		cmp.w	#DSP_Buffer/2,d2			; un 'tick'
		bhi.s	MGTK_Search_Length_Loop

		move.w	d3,MGTK_IT_Number

MGTK_Search_MFP_Divider
		mulu.w	d3,d0					; Tempo*Nb ITs
		mulu.w	#50*256,d0				; *50/125*256
		divu.l	#125,d0					; = Freq Cherch‚e * 256

		move.l	#2457600/200*256,d2			; Freq Base MFP
		move.l	d2,d3					; / Prediviseur 200
		divu.l	d0,d2					; / Freq donne Diviseur

		move.b	#7,MGTK_IT_Timer_Control
		move.b	d2,MGTK_IT_Timer_Data
		movem.l	(sp)+,d0-d3
		rts

MGTK_Fine_Portamento_Up
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		bra		MGTK_Portamento_Up2
 
MGTK_Fine_Portamento_Down
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		bra		MGTK_Portamento_Down2


MGTK_Set_Glissando_Control
		move.b	Voice_Parameters(a6),Voice_Glissando_Control(a6)
		rts

MGTK_Set_Vibrato_Control
		move.b	Voice_Parameters(a6),Voice_Vibrato_Control(a6)
		rts

MGTK_Set_Fine_Tune
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		mulu.w	#12*3*2,d0
		move.w	d0,Voice_Sample_Fine_Tune(a6)
		rts

MGTK_Pattern_Loop
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		beq.s	MGTK_Set_Loop_Position

		tst.w	MGTK_Pattern_Loop_Counter(pc)
		beq.s	MGTK_Set_Loop_Counter

		subq.w	#1,MGTK_Pattern_Loop_Counter
		beq		MGTK_Return

MGTK_Do_Loop	
		st		MGTK_Pattern_Loop_Flag
		rts
MGTK_Set_Loop_Counter
		move.w	d0,MGTK_Pattern_Loop_Counter
		bra.s	MGTK_Do_Loop
MGTK_Set_Loop_Position
		move.w	MGTK_Pattern_Position(pc),MGTK_Pattern_Loop_Position
		rts


MGTK_Set_Tremolo_Control
		move.b	Voice_Parameters(a6),Voice_Tremolo_Control(a6)
		rts


MGTK_Retrig_Note
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		beq.s	MGTK_No_Retrig_Note

		moveq.l	#0,d1
		move.b	MGTK_Music_Counter(pc),d1
		bne.s	MGTK_Retrig_Note_Skip

		tst.w	Voice_Note(a6)
		bne.s	MGTK_No_Retrig_Note

MGTK_Retrig_Note_Skip
		divu.w	d0,d1
		swap.w	d1
		tst.w	d1
		bne.s	MGTK_No_Retrig_Note

		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)

MGTK_No_Retrig_Note
		rts


MGTK_Volume_Fine_Up
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		bra		MGTK_Volume_Slide_Up


MGTK_Note_Cut
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		cmp.b	MGTK_Music_Counter(pc),d0
		bne		MGTK_Return
		clr.w	Voice_Volume(a6)
		clr.w	Voice_Sample_Volume(a6)
		rts

MGTK_Note_Delay
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		cmp.b	MGTK_Music_Counter(pc),d0
		bne		MGTK_Return
		tst.w	Voice_Note(a6)
		beq		MGTK_Return

		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		move.l	Voice_Start(a6),Voice_Sample_Start(a6)
		move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)
		rts


MGTK_Pattern_Delay
		tst.b	MGTK_Pattern_Delay_Time(pc)
		bne		MGTK_Return
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		move.b	d0,MGTK_Pattern_Delay_Time
		rts

***********************************************************************
***********			   Tables diverses				***********
***********************************************************************

MGTK_Sinus_Table	
		dc.b		0,24,49,74,97,120,141,161,180,197,212,224
		dc.b		235,244,250,253,255,253,250,244,235,224
		dc.b		212,197,180,161,141,120,97,74,49,24

MGTK_Period_Table
; Tuning 0, Normal
		dc.w		856,808,762,720,678,640,604,570,538,508,480,453
		dc.w		428,404,381,360,339,320,302,285,269,254,240,226
		dc.w		214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
		dc.w		850,802,757,715,674,637,601,567,535,505,477,450
		dc.w		425,401,379,357,337,318,300,284,268,253,239,225
		dc.w		213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
		dc.w		844,796,752,709,670,632,597,563,532,502,474,447
		dc.w		422,398,376,355,335,316,298,282,266,251,237,224
		dc.w		211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
		dc.w		838,791,746,704,665,628,592,559,528,498,470,444
		dc.w		419,395,373,352,332,314,296,280,264,249,235,222
		dc.w		209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
		dc.w		832,785,741,699,660,623,588,555,524,495,467,441
		dc.w		416,392,370,350,330,312,294,278,262,247,233,220
		dc.w		208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
		dc.w		826,779,736,694,655,619,584,551,520,491,463,437
		dc.w		413,390,368,347,328,309,292,276,260,245,232,219
		dc.w		206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
		dc.w		820,774,730,689,651,614,580,547,516,487,460,434
		dc.w		410,387,365,345,325,307,290,274,258,244,230,217
		dc.w		205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
		dc.w		814,768,725,684,646,610,575,543,513,484,457,431
		dc.w		407,384,363,342,323,305,288,272,256,242,228,216
		dc.w		204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
		dc.w		907,856,808,762,720,678,640,604,570,538,508,480
		dc.w		453,428,404,381,360,339,320,302,285,269,254,240
		dc.w		226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
		dc.w		900,850,802,757,715,675,636,601,567,535,505,477
		dc.w		450,425,401,379,357,337,318,300,284,268,253,238
		dc.w		225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
		dc.w		894,844,796,752,709,670,632,597,563,532,502,474
		dc.w		447,422,398,376,355,335,316,298,282,266,251,237
		dc.w		223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
		dc.w		887,838,791,746,704,665,628,592,559,528,498,470
		dc.w		444,419,395,373,352,332,314,296,280,264,249,235
		dc.w		222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
		dc.w		881,832,785,741,699,660,623,588,555,524,494,467
		dc.w		441,416,392,370,350,330,312,294,278,262,247,233
		dc.w		220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
		dc.w		875,826,779,736,694,655,619,584,551,520,491,463
		dc.w		437,413,390,368,347,328,309,292,276,260,245,232
		dc.w		219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
		dc.w		868,820,774,730,689,651,614,580,547,516,487,460
		dc.w		434,410,387,365,345,325,307,290,274,258,244,230
		dc.w		217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
		dc.w		862,814,768,725,684,646,610,575,543,513,484,457
		dc.w		431,407,384,363,342,323,305,288,272,256,242,228
		dc.w		216,203,192,181,171,161,152,144,136,128,121,114

***********************************************************************
***********		Routines DSP : Loader et Replay		***********
***********************************************************************

MGTK_DSP_Replay_Code
		IncBin	'e:\restrack\AMIGADSP.P56'
MGTK_DSP_Replay_Size	equ		(*-MGTK_DSP_Replay_Code)/3
		Even

***********************************************************************
***********		Positions St‚r‚o des voies			***********
***********************************************************************

; Le DSP mixe dans l'ordre Gauche-Droite-Gauche-etc...
; Cette Table donne pour chaque voie l'offset … la Voie suivante
MGTK_Panoramics
; les Voies FX L-R-L-R
		dc.l		+1*Voice_Size,+1*Voice_Size,+1*Voice_Size,+1*Voice_Size
; les Voies Normales L-R-R-L
; 1 + 1 -> 2 + 2 -> 4 - 1 -> 3 + 2 -> 5
		Rept		8
		dc.l		+1*Voice_Size,+2*Voice_Size,+2*Voice_Size,-1*Voice_Size
		EndR

***********************************************************************
***********			Variables diverses				***********
***********************************************************************

MGTK_Module_Adr			ds.l		1
MGTK_WorkSpace_Adr			ds.l		1
MGTK_Module_End_Adr			ds.l		1

MGTK_Nb_Voices				ds.w		1
MGTK_Nb_Samples			ds.w		1

MGTK_Sequence_Adr			ds.l		1
MGTK_Patterns_Adr			ds.l		1
MGTK_Samples_Adr			ds.l		31
MGTK_Line_Size				ds.w		1
MGTK_Pattern_Size			ds.w		1

MGTK_Music_Position			ds.w		1
MGTK_Music_Length			ds.w		1
MGTK_Music_Restart			ds.w		1
MGTK_Music_Tempo			ds.b		1
MGTK_Music_Speed			ds.b		1
MGTK_Music_Counter			ds.b		1

MGTK_Restart_Loop			ds.b		1
MGTK_Restart_Done			ds.b		1
MGTK_Replay_Paused			ds.b		1
MGTK_Replay_Stopped			ds.b		1
MGTK_Replay_Satured			ds.b		1
MGTK_Replay_Problem			ds.b		1
MGTK_Replay_In_Service		ds.b		1
MGTK_IT_Timer_Control		ds.b		1
MGTK_IT_Timer_Data			ds.b		1
MGTK_IT_Number				ds.w		1
MGTK_IT_Counter			ds.w		1
MGTK_Frequency_Divider		ds.w		1
MGTK_Replay_Frequency		ds.w		1

MGTK_Master_Volume_Left		ds.w		1
MGTK_Master_Volume_Right		ds.w		1

MGTK_Pattern_Position		ds.w		1
MGTK_Pattern_Length			ds.w		1

MGTK_Pattern_Loop_Counter	ds.w		1
MGTK_Pattern_Loop_Position	ds.w		1
MGTK_Pattern_Break_Position	ds.w		1
MGTK_Position_Jump_Position	ds.w		1
MGTK_Position_Jump_Flag		ds.b		1
MGTK_Pattern_Loop_Flag		ds.b		1
MGTK_Pattern_Break_Flag		ds.b		1
MGTK_Pattern_Delay_Time		ds.b		1

MGTK_Old_Module			ds.b		1

						Even
MGTK_FX_Voices				ds.b		4*Voice_Size
MGTK_Voices				ds.b		32*Voice_Size
