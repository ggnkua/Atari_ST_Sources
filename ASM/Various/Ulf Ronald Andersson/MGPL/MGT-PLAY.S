***********************************************************************
***********										***********
***********										***********
***********		  DSP-Replay MegaTracker v1.1			***********
***********				16/09/1995				***********
***********										***********
***********										***********
***********		  Par Simplet / FATAL DESIGN			***********
***********										***********
***********************************************************************

CPU_Time		equ		1		; Display CPU-Time taken by the Replay
DSP_Buffer	equ		2048		; DSP Sample Buffer Size

		XDef		MGTK_Init_Module_Samples,MGTK_Init_DSP
		XDef		MGTK_Save_Sound,MGTK_Init_Sound,MGTK_Restore_Sound
		XDef		MGTK_Set_Replay_Frequency
		XDef		MGTK_Play_Music,MGTK_Pause_Music,MGTK_Stop_Music
		XDef		MGTK_Previous_Music,MGTK_Next_Music
		XDef		MGTK_Play_Position,MGTK_Previous_Position
		XDef		MGTK_Next_Position,MGTK_Clear_Voices
		XDef		MGTK_Play_FX_Module,MGTK_Play_FX_Sample
		XDef		MGTK_FX_Voices,MGTK_Voices
		XDef		MGTK_Restart_Loop,MGTK_Restart_Done
		XDef		MGTK_Replay_Satured,MGTK_Replay_Problem
		XDef		MGTK_Replay_In_Service,MGTK_Global_Volume
		XDef		MGTK_Master_Volume_Left,MGTK_Master_Volume_Right

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

***********************************************************************
***********				Structures				***********
***********************************************************************

					RsReset

Sample_Name			rs.b		32	* 32 caractŠres

Sample_Start			rs.l		1	* Adresse d‚but du Sample
Sample_Length			rs.l		1	* Taille du sample en unit‚s
Sample_Loop_Start		rs.l		1	* Offset d‚but Boucle en unit‚s
Sample_Loop_Length		rs.l		1	* Taille de la Boucle en unit‚s
Sample_Buffer_Length	rs.l		1	* Taille Minimale du Buffer en unit‚s
Sample_End_Length		rs.l		1	* Taille de la fin du sample aprŠs le buffer

Sample_Base			rs.l		1	* Fr‚quence de Replay pour le DO-4
Sample_Volume			rs.w		1	* Volume par d‚faut de 0 … 1024
Sample_Panoramic		rs.b		2	* Volumes Gauche et Droit de 0 … 255
								* par d‚faut, 0 si y'en a pas
Sample_Attributes		rs.b		1	* bits 0 et 1 : Loop Mode -->
								*  0 = Loop Off,	1 = Forward Loop
								*  2 = Ping-Pong Loop, 3 r‚serv‚
								* bit 2 --> 0 = 8 bits,  1 = 16 bits
								* bit 3 --> 0 = Mono,    1 = Stereo

Sample_Fine_Tune		rs.b		1	* de 0 … 15  =  0 … 7 et -8 … -1

					rs.b		1	* Inutilis‚
Sample_Drum_Note		rs.b		1	* Informations stock‚es
Sample_Drum_Volume		rs.b		1	* par le Tracker
Sample_Drum_Command		rs.b		1	* pour le mode
Sample_Drum_Parameter	rs.w		1	* Drum Edit

Sample_Midi_Note		rs.l		1	* Note au format MIDI
Sample_Reserved		rs.l		1	* 4 octets R‚serv‚s

Sample_Size			rs.b		0	* 80 octets

					RsReset

Voice_Sample_Start			rs.l		1
Voice_Sample_Offset			rs.l		1
Voice_Sample_Position		rs.l		1
Voice_Sample_Length			rs.l		1
Voice_Sample_Loop_Length		rs.l		1
Voice_Sample_End_Length		rs.l		1
Voice_Sample_Base			rs.l		1
Voice_Sample_Volume			rs.w		1
Voice_Sample_Period			rs.l		1
Voice_Sample_Fine_Tune		rs.w		1
						rs.b		1
Voice_Sample_Attributes		rs.b		1
Voice_Left_Volume			rs.b		1
Voice_Right_Volume			rs.b		1

Voice_Start				rs.l		1
Voice_Length				rs.l		1
Voice_Loop_Length			rs.l		1
Voice_End_Length			rs.l		1
Voice_Base				rs.l		1
Voice_Volume				rs.w		1
Voice_Period				rs.l		1
Voice_Attributes			rs.b		1
						rs.b		1

Voice_Note				rs.b		1
Voice_Sample				rs.b		1
Voice_Vol_Command			rs.b		1
Voice_Command				rs.b		1
Voice_Parameter1			rs.b		1
Voice_Parameter2			rs.b		1

Voice_Tone_Port_Period		rs.l		1
Voice_Tone_Port_Speed		rs.l		1
Voice_Tone_Port_Direction	rs.b		1
Voice_Glissando_Control		rs.b		1
Voice_Vibrato_Waveform		rs.b		1
Voice_Vibrato_Speed			rs.b		1
Voice_Vibrato_Depth			rs.w		1
Voice_Vibrato_Position		rs.b		1
Voice_Tremolo_Waveform		rs.b		1
Voice_Tremolo_Depth			rs.w		1
Voice_Tremolo_Speed			rs.b		1
Voice_Tremolo_Position		rs.b		1

Voice_Size				rs.b		0

***********************************************************************
***********										***********
***********	Routines de gestion de Base du Replay :		***********
***********										***********
***********	Fixer Fr‚quence de Replay				***********
***********	Jouer/arrˆter une musique, Position/Musique	***********
***********	pr‚c‚dente/suivante, Saut … une Position	***********
***********	Et gestion de samples suppl‚mentaires (FX)	***********
***********										***********
***********************************************************************

			Section	TEXT

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

; Jouer une musique
; En Entr‚e :
; d0.w = Num‚ro de la musique … jouer

MGTK_Play_Music
		movem.l	d3-d7/a2-a6,-(sp)

		tst.w	d0
		bpl.s	MGTK_Play_Music_1
		moveq.l	#0,d0
MGTK_Play_Music_1
		cmp.w	MGTK_Nb_Musics(pc),d0
		blo.s	MGTK_Play_Music_2
		move.w	MGTK_Nb_Musics(pc),d0
		subq.w	#1,d0
MGTK_Play_Music_2

		move.w	MGTK_Nb_Voices(pc),d1
		add.w	d1,d1
		add.w	#46,d1
		mulu.w	d1,d0
		lea.l	([MGTK_Musics_Adr,pc],d0.w,32.w),a0

		move.l	(a0)+,a1
		adda.l	MGTK_Module_Adr(pc),a1
		move.l	a1,MGTK_Sequence_Adr
		move.w	(a0)+,MGTK_Music_Length
		move.w	(a0)+,MGTK_Music_Restart
		move.b	(a0)+,d0
		move.b	(a0)+,d1
		move.w	(a0)+,MGTK_Global_Volume
		move.b	(a0)+,MGTK_Master_Volume_Left
		move.b	(a0)+,MGTK_Master_Volume_Right

		move.b	d0,MGTK_Initial_Tempo
		move.b	d0,MGTK_Music_Tempo
		move.b	d1,MGTK_Initial_Speed
		move.b	d1,MGTK_Music_Speed	
		move.b	d1,MGTK_Music_Counter

		bsr		MGTK_Search_Values_for_Tempo

		move.w	MGTK_Nb_Voices(pc),d7
		lea.l	MGTK_Voices(pc),a6
		subq.w	#1,d7
MGTK_Play_Music_Panoramics
		move.w	(a0)+,Voice_Left_Volume(a6)
		lea.l	Voice_Size(a6),a6
		dbra		d7,MGTK_Play_Music_Panoramics

		move.w	#-1,MGTK_Music_Position
		move.w	#-2,MGTK_Pattern_Position
		sf		MGTK_Pattern_Loop_Flag
		clr.w	MGTK_Pattern_Loop_Counter
		clr.w	MGTK_Pattern_Loop_Position
		sf		MGTK_Pattern_Break_Flag
		clr.w	MGTK_Pattern_Break_Position
		sf		MGTK_Position_Jump_Flag
		clr.w	MGTK_Position_Jump_Position
		clr.b	MGTK_Pattern_Delay_Time

		bsr		MGTKClearVoices

		sf		MGTK_Replay_In_Service
		sf		MGTK_Replay_Problem
		clr.w	MGTK_Replay_Satured

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
; Gestion des effets sp‚ciaux
;
MGTK_Play_FX_Module
MGTK_Play_FX_Sample
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
; Musique pr‚c‚dente
;
MGTK_Previous_Music
		move.w	MGTK_Music(pc),d0
		subq.w	#1,d0
		bra		MGTK_Play_Music
;
; Musique suivante
;
MGTK_Next_Music
		move.w	MGTK_Music(pc),d0
		addq.w	#1,d0
		bra		MGTK_Play_Music

;
; Remet les voies … z‚ro
;
MGTK_Clear_Voices
		movem.l	d3-d4/d7/a6,-(sp)
		bsr.s	MGTKClearVoices
		movem.l	(sp)+,d3-d4/d7/a6
		rts
				
MGTKClearVoices
		move.l	#8363,d3
		move.l	#256*1700,d4

		lea.l	MGTK_FX_Voices(pc),a6
		moveq.l	#34-1,d7

MGTK_Clear_A_Voice
		clr.l	(a6)+
		clr.l	(a6)+
		clr.l	(a6)+
		clr.l	(a6)+
		clr.l	(a6)+
		clr.l	(a6)+
		move.l	d3,(a6)+
		clr.w	(a6)+
		move.l	d4,(a6)+
		clr.w	(a6)+
		clr.w	(a6)+
		addq.l	#2,a6

		clr.l	(a6)+
		clr.l	(a6)+
		clr.l	(a6)+
		clr.l	(a6)+
		move.l	d3,(a6)+
		clr.w	(a6)+
		move.l	d4,(a6)+
		clr.w	(a6)+

		clr.w	(a6)+
		clr.l	(a6)+

		clr.l	(a6)+
		clr.l	(a6)+
		clr.l	(a6)+
		clr.l	(a6)+
		clr.l	(a6)+
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
;     -1 si problŠme de format
;     -2 si workspace trop petite pour d‚compactage pistes
;     -3 si pas assez de place pour pr‚parer des Samples
;     -4 si pas de samples dans ce module (Song seulement)

MGTK_Init_Module_Samples
		movem.l	d3-d7/a2-a6,-(sp)

		sf		MGTK_Replay_Paused
		st		MGTK_Replay_Stopped

		movea.l	a0,a6
		move.l	a6,MGTK_Module_Adr
		movea.l	a1,a5
		move.l	a5,MGTK_WorkSpace_Adr

; On v‚rifie le format du Module
		move.l	(a0)+,d0
		lsr.l	#8,d0
		cmp.l	#'MGT',d0
		bne		MGTK_Init_Format_Error
		cmp.l	#'½MCS',(a0)+
		bne		MGTK_Init_Format_Error

; Initialise les variables concernant les nombre et adresse de Structures
		lea.l	MGTK_Nb_Voices(pc),a1
		move.w	(a0)+,(a1)+			; Nb Voices
		move.w	(a0)+,(a1)+			; Nb Musics
		addq.l	#4,a0
		move.w	(a0)+,(a1)+			; Nb Tracks
		move.w	(a0)+,d0
		beq		MGTK_Init_No_Sample_Error
		move.w	d0,(a1)+				; Nb Samples

		addq.l	#6,a0				; Attributs Inutilis‚s et 4 octets R‚serv‚s

		moveq.l	#6-1,d7
MGTK_Init_Module_Adresses
		move.l	(a0)+,d0				; Offset Section
		add.l	a6,d0				; + Adresse Module
		move.l	d0,(a1)+				; = Adresse Section
		dbra		d7,MGTK_Init_Module_Adresses

		move.l	(a0)+,(a1)+			; Samples Length
		move.l	(a0)+,(a1)+			; Tailles Pistes D‚pack‚es

; On cherche … savoir si on a assez de place pour d‚packer les pistes
		move.l	([MGTK_Tracks_Ptr,pc]),d0	; Offset 1Šre Piste
		add.l	MGTK_Samples_Length(pc),d0	; + Taille Samples
		add.l	MGTK_Tracks_Length(pc),d0	; + Pistes d‚pack‚es

		move.l	a5,d1				; WorkSpace-Module Begin
		sub.l	a6,d1				; Taille maximale disponible

		cmp.l	d1,d0				; Module Trop Grand ?
		bgt		MGTK_Init_Module_Error

; Calcul Taille du Bloc Pistes+Samples … d‚placer … la fin de la WorkSpace
		movea.l	MGTK_Samples_Data_Adr(pc),a0	; Adresse 1er sample
		adda.l	MGTK_Samples_Length(pc),a0	; + Taille Samples

		move.l	a0,d0					; Fin module
		sub.l	([MGTK_Tracks_Ptr,pc]),d0	; - Offset 1Šre Piste
		sub.l	a6,d0					; - d‚but module

		movea.l	a5,a1				; WorkSpace End
		suba.l	d0,a5				; Adresse du Bloc d'arriv‚e

MGTK_Init_Move
		move.l	-(a0),-(a1)
		move.l	-(a0),-(a1)
		subq.l	#8,d0
		bpl.s	MGTK_Init_Move

; Maintenant on d‚packe les Pistes

		movea.l	MGTK_Tracks_Ptr(pc),a0	; Pointeurs de Pistes
		lea.l	([a0],a6.l),a1			; Adresse 1Šre Piste

		movea.l	a5,a4
		suba.l	(a0),a4
		
		move.w	MGTK_Nb_Tracks(pc),d7
		subq.w	#1,d7
MGTK_Depack_Tracks
		lea.l	([a0],a4.l),a2		; Prend Adresse Piste Pack‚e
		move.l	a1,(a0)+			; Remplace par Adresse Piste D‚pack‚e

		move.w	(a2)+,d6
		move.w	d6,(a1)+				; Nb Lignes Piste
		moveq.l	#0,d5

MGTK_Depack_A_Track
		move.b	(a2)+,d0
		move.b	d0,d1
		and.w	#$3,d1				; Nb Lignes vides
		beq.s	MGTK_Depack_Track_No_Empty_Line

		add.w	d1,d5
		subq.w	#1,d1

MGTK_Depack_Track_Empty_Line
		clr.l	(a1)+
		clr.w	(a1)+
		dbra		d1,MGTK_Depack_Track_Empty_Line

MGTK_Depack_Track_No_Empty_Line
		lsr.b	#2,d0
		moveq.l	#6-1,d2
MGTK_Depack_Track_Note
		moveq.l	#0,d1
		lsr.b	d0
		bcc.s	MGTK_Depack_Track_No_Byte
		move.b	(a2)+,d1
MGTK_Depack_Track_No_Byte
		move.b	d1,(a1)+
		dbra		d2,MGTK_Depack_Track_Note

		addq.w	#1,d5
		cmp.w	d6,d5
		blo.s	MGTK_Depack_A_Track

		dbra		d7,MGTK_Depack_Tracks

; On pr‚pare les samples au bouclage...

		movea.l	MGTK_WorkSpace_Adr(pc),a4
		suba.l	MGTK_Samples_Length(pc),a4
		suba.l	MGTK_Samples_Data_Adr(pc),a4
		adda.l	a6,a4

		movea.l	MGTK_Samples_Infos_Adr(pc),a3
		move.w	MGTK_Nb_Samples(pc),d7
		subq.w	#1,d7

MGTK_Init_Samples
		lea.l	([Sample_Start,a3],a4.l),a0	; Adresse Sample

		clr.l	Sample_Start(a3)			; Pas de sample par d‚faut

		move.l	Sample_Length(a3),d6		; Si longueur nulle
		beq		MGTK_Init_Next_Sample		; passe au suivant

		move.l	a1,d0					; On veut
		addq.l	#1,d0					; adresse
		and.b	#$fe,d0					; paire
		move.l	d0,a1
		move.l	a1,Sample_Start(a3)			; Stocke Nouvelle Adresse

		move.l	Sample_Loop_Start(a3),d2		; D‚but de Boucle
		move.l	Sample_Loop_Length(a3),d3	; Longueur de Boucle
		move.l	Sample_Buffer_Length(a3),d4	; Taille du Buffer
		move.l	Sample_End_Length(a3),d5		; Taille Fin Sample

		btst.b	#2,Sample_Attributes(a3)
		beq.s	MGTK_Sample_8_Bits_1
		lsl.l	d2
		lsl.l	d3
		lsl.l	d4
		lsl.l	d5
		lsl.l	d6
MGTK_Sample_8_Bits_1
		btst.b	#3,Sample_Attributes(a3)
		beq.s	MGTK_Sample_Mono_1
		lsl.l	d2
		lsl.l	d3
		lsl.l	d4
		lsl.l	d5
		lsl.l	d6
MGTK_Sample_Mono_1

		move.l	d6,d0
		bftst	Sample_Attributes(a3){6:2}
		beq.s	MGTK_No_Loop				; Sample boucl‚ ?

		move.l	d2,d0
		add.l	d3,d0					; Fin de Boucle
		move.l	d0,d6					; New Sample Length
MGTK_Loop_Start
		move.b	(a0)+,(a1)+				; Recopie le sample
		subq.l	#1,d0					; jusqu'… la fin
		bne.s	MGTK_Loop_Start			; de la boucle

		movea.l	a1,a2					; Adresse du 
		suba.l	d3,a2					; D‚but de la Boucle
		moveq.l	#0,d1					; Longueur de la Boucle

MGTK_Make_Loop
		cmp.l	d4,d1					; Taille minimale
		bhs.s	MGTK_Loop_Made				; Ateinte ?

		move.l	d3,d0					; Longueur de la Boucle
MGTK_MakeLoop
		move.b	(a2)+,(a1)+				; Recopie
		subq.l	#1,d0					; encore
		bne.s	MGTK_MakeLoop				; la Boucle

		add.l	d3,d1
		bra.s	MGTK_Make_Loop

MGTK_Loop_Made
		move.l	d5,d0					; La Fin du Sample
		beq.s	MGTK_End_Buffer

MGTK_No_Loop
		move.b	(a0)+,(a1)+				; Recopie
		subq.l	#1,d0					; le sample
		bne.s	MGTK_No_Loop				; bˆtement

MGTK_End_Buffer
		clr.l	(a1)+					; Et met
		clr.l	(a1)+					; du vide
		subq.l	#8,d4					; aprŠs
		bpl.s	MGTK_End_Buffer

		cmpa.l	a0,a1
		bhi.s	MGTK_Init_Samples_Error

		btst.b	#2,Sample_Attributes(a3)
		beq.s	MGTK_Sample_8_Bits_2
		lsr.l	d6
MGTK_Sample_8_Bits_2
		btst.b	#3,Sample_Attributes(a3)
		beq.s	MGTK_Sample_Mono_2
		lsr.l	d6
MGTK_Sample_Mono_2
		move.l	d6,Sample_Length(a3)

MGTK_Init_Next_Sample
		lea.l	Sample_Size(a3),a3			; Sample suivant
		dbra		d7,MGTK_Init_Samples

		move.l	a1,MGTK_Module_End_Adr

		bsr		MGTKClearVoices
		movem.l	(sp)+,d3-d7/a2-a6
		moveq.l	#0,d0
		rts

MGTK_Init_No_Sample_Error
		movem.l	(sp)+,d3-d7/a2-a6
		moveq.l	#-4,d0
		rts
MGTK_Init_Samples_Error
		movem.l	(sp)+,d3-d7/a2-a6
		moveq.l	#-3,d0
		rts
MGTK_Init_Module_Error
		movem.l	(sp)+,d3-d7/a2-a6
		moveq.l	#-2,d0
		rts
MGTK_Init_Format_Error
		movem.l	(sp)+,d3-d7/a2-a6
		moveq.l	#-1,d0
		rts

***********************************************************************
***********			   Initialisation DSP			***********
***********************************************************************

; Charge le Loader et Replay DSP et v‚rifie son fonctionnement
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

;
;----------------------------------------------------------------------------
;
MGTK_Replay_Timer
		move.w	#$2700,sr

		move.b	MGTK_IT_Timer_Data(pc),$fffffa1f.w
		move.b	MGTK_IT_Timer_Control(pc),$fffffa19.w

		tst.b	MGTK_Replay_In_Service(pc)
		beq.s	.MGTK_Replay_Not_Satured

		addq.w	#1,MGTK_Replay_Satured
		bclr.b	#5,$fffffa0f.w			; … Cause du mode SEI
		rte

.MGTK_Replay_Not_Satured
; Signale au DSP qu'on veut causer … la routine Soundtracker
		move.b	#$80+$13,$ffffa201.w	; Host User 0, adresse $26

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

; Envoie Global Volume
		move.w	MGTK_Global_Volume(pc),2(a6)

; Envoie le Nombre de Voies pour le mixage (sans les 2 voies FX)
		move.w	MGTK_Nb_Voices(pc),2(a6)

; Pr‚pare le pointeur sur les voies
		move.l	#MGTK_FX_Voices,MGTK_Voices_Ptr

; Autorise interruption de r‚ception en provenance du DSP
		move.l	#MGTK_Replay_Voices,$3fc.w
		move.b	#$ff,-1(a6)			; $ffffa203.w
		bset.b	#0,-4(a6)				; $ffffa200.w

MGTK_Replay_Ret
		movem.l	(sp)+,d0/a6
		bclr.b	#5,$fffffa0f.w			; … Cause du mode SEI
		rte

;
;----------------------------------------------------------------------------
;
; Mixage des Pistes une par une
;
MGTK_Replay_Voices
		movem.l	d0-d3/a0/a5/a6,-(sp)

		lea.l	$ffffa204.w,a6
		bclr.b	#0,-4(a6)			; Inhibe Interruption Rec‚ption
		
;;;;patch 1 start
;;;;patched	move.w	#$2300,sr
	move	7*4(sp),d0	;;;;patch
	bset	#13,d0		;;;;patch
	move	d0,sr		;;;;patch
;;;;patch 1 end
		




MGTK_Replay_Get
		move.w	2(a6),d0			; Flag Nouvelle voie
		beq		MGTK_Replay_No_More_Voices

		movea.l	MGTK_Voices_Ptr(pc),a5	; Pointe sur la voie courante
		add.l	#Voice_Size,MGTK_Voices_Ptr

; Envoie les infos sur la voie
; d'abord la voie est-elle active ?

		tst.l	Voice_Sample_Start(a5)
		bne.s	MGTK_Replay_Sample_Ok

MGTK_Replay_No_Voice
		clr.l	(a6)
		WaitDSPToGet
		bra.s	MGTK_Replay_Get

MGTK_Replay_Sample_Ok
		move.w	Voice_Left_Volume(a5),d0
		beq.s	MGTK_Replay_No_Voice

; Envoie Panoramique + Attributs
		move.b	Voice_Sample_Attributes(a5),d3
		move.w	d3,(a6)
		move.w	d0,2(a6)

; Envoie Volume
		moveq.l	#0,d2
		move.w	Voice_Sample_Volume(a5),d2
		move.l	d2,(a6)

; Envoie fr‚quence relative
; Explication du calcul :
; Fr‚quence de replay d'une note =
; Base du DO-4 * Periode du DO-4 / Periode de la Note
; Nous on veut le rapport avec la fr‚quence de Replay donc / Freq_Replay
; et r‚sultat … virgule pr‚multipli‚ par $800000 pour le DSP

		move.l	#428/2,d1
		moveq.l	#0,d0			; d1:d0=$800000*(428*256)
		move.w	MGTK_Replay_Frequency(pc),d2
		divu.l	d2,d1:d0
		mulu.l	Voice_Sample_Base(a5),d1:d0
		divu.l	Voice_Sample_Period(a5),d1:d0

		move.l	#$800000*70/100,d1	; 70% replay freq

		btst		#3,d3			; Stereo ?
		bne.s	MGTK_Replay_Max_Freq

		tst.b	Voice_Left_Volume(a5)
		beq.s	MGTK_Replay_Mono_Panoramic
		tst.b	Voice_Right_Volume(a5)
		bne.s	MGTK_Replay_Max_Freq

MGTK_Replay_Mono_Panoramic
		move.l	#$800000*80/100,d1	; 80% replay freq

		btst		#2,d3			; 16 bits ?
		bne.s	MGTK_Replay_Max_Freq

		move.l	#$800000*90/100,d1	; 90% replay freq

MGTK_Replay_Max_Freq
		cmp.l	d1,d0
		bhi		MGTK_Replay_030_Voice

		lsr.l	d0
		move.l	d0,(a6)

;
; Si la fr‚quence du sample est inf‚rieure … xx% de la fr‚quence de replay
;

; Recoie longueur du sample jou‚e dans cette frame
		WaitDSPToGet
		move.l	(a6),d0

		movea.l	Voice_Sample_Start(a5),a0	; Adresse Sample
		move.l	Voice_Sample_Position(a5),d1	; Position
		move.l	d1,d2					; Courante
		add.l	d0,d2					; Position d'arriv‚e

		move.b	Voice_Sample_Attributes(a5),d3
		and.b	#%11,d3					; Type de Bouclage
		bne.s	MGTK_Replay_Loop

MGTK_Replay_No_Loop
		move.l	Voice_Sample_Length(a5),d3	; Pas de Boucle
		add.l	Voice_Sample_End_Length(a5),d3
		cmp.l	d3,d2					; A-t'on d‚pass‚ la fin
		blt.s	MGTK_Replay_Pos_Ok			; du Sample ?

		clr.l	Voice_Sample_Start(a5)		; Oui, alors sample
		bra.s	MGTK_Replay_Pos_Ok			; d‚sactiv‚

MGTK_Replay_Loop
		cmp.l	Voice_Sample_Length(a5),d2	; A-t'on d‚pass‚ la
		blt.s	MGTK_Replay_Pos_Ok			; fin de la boucle

		sub.l	Voice_Sample_Loop_Length(a5),d2	; Si oui, reboucle
		bra.s	MGTK_Replay_Loop

MGTK_Replay_Pos_Ok
		move.l	d2,Voice_Sample_Position(a5)	; Nouvelle position

		btst.b	#2,Voice_Sample_Attributes(a5)
		bne.s	MGTK_Replay_16_Bits_Sample

		btst.b	#3,Voice_Sample_Attributes(a5)
		bne.s	MGTK_Replay_16_Bits_Mono_Sample

MGTK_Replay_8_Bits_Mono_Sample
		lea.l	(a0,d1.l),a0
		lsr.w	d0					; Envoi par paquet de deux
		bra.s	MGTK_Replay_Send_Sample

MGTK_Replay_16_Bits_Sample
		btst.b	#3,Voice_Sample_Attributes(a5)
		beq.s	MGTK_Replay_16_Bits_Mono_Sample

MGTK_Replay_16_Bits_Stereo_Sample
		lea.l	(a0,d1.l*2),a0
		lsl.w	d0
		addq.w	#1,d0
		
MGTK_Replay_16_Bits_Mono_Sample
		lea.l	(a0,d1.l*2),a0

MGTK_Replay_Send_Sample
		addq.l	#2,a6				; Port Host en word

MGTK_Send_Samples
		move.w	(a0)+,(a6)
MGTK_Send_Samples_Jump
		dbra		d0,MGTK_Send_Samples

; Autorise interruption de r‚ception en provenance du DSP
		bset.b	#0,-6(a6)				; $ffffa200.w

		movem.l	(sp)+,d0-d3/a0/a5/a6
		rte

;
; Si la fr‚quence du sample est sup‚rieure … xx% de la fr‚quence de replay
;

MGTK_Replay_030_Voice
		clr.l	(a6)

		lsr.l	#7,d0				; Freq_relative * 65536
		swap.w	d0					; Virgule poids fort

		movea.l	Voice_Sample_Start(a5),a0	; Adresse Sample
		move.l	Voice_Sample_Position(a5),d2	; Position Courante

		btst.b	#2,Voice_Sample_Attributes(a5)
		bne.s	MGTK_Replay_030_16_Bits_Sample

		btst.b	#3,Voice_Sample_Attributes(a5)
		bne.s	MGTK_Replay_030_Word_Sample

MGTK_Replay_030_8_Bits_Mono_Sample
		lea.l	(a0,d2.l),a0
		addq.l	#2,a6
		move.w	(a6),d1				; Nb de Packets … envoyer - 1
		moveq.l	#0,d2
		lsr.w	d1
		bcc.s	MGTK_Replay_030_Send_8_Bits_Mono_Sample_Odd

MGTK_Replay_030_Send_8_Bits_Mono_Sample_Loop
		move.w	(a0,d2.w),d3
		addx.l	d0,d2
		move.b	(a0,d2.w),d3
		addx.l	d0,d2
		move.w	d3,(a6)
MGTK_Replay_030_Send_8_Bits_Mono_Sample_Odd
		move.w	(a0,d2.w),d3
		addx.l	d0,d2
		move.b	(a0,d2.w),d3
		addx.l	d0,d2
		move.w	d3,(a6)
		dbra		d1,MGTK_Replay_030_Send_8_Bits_Mono_Sample_Loop
		bra.s	MGTK_Replay_030_Check_Loop


MGTK_Replay_030_16_Bits_Sample
		btst.b	#3,Voice_Sample_Attributes(a5)
		beq.s	MGTK_Replay_030_Word_Sample

MGTK_Replay_030_16_Bits_Stereo_Sample
		lea.l	(a0,d2.l*4),a0
		addq.l	#2,a6
		move.w	(a6),d1				; Nb de Packets … envoyer - 1
		moveq.l	#0,d2

		move.l	a5,-(sp)
		movea.l	a0,a5

		lsr.w	d1
		bcc.s	MGTK_Replay_030_16_Bits_Stereo_Sample_Odd

MGTK_Replay_030_16_Bits_Stereo_Sample_Loop
		move.w	(a5)+,(a6)
		addx.l	d0,d2
		move.w	(a5),(a6)
		lea.l	(a0,d2.w*4),a5
MGTK_Replay_030_16_Bits_Stereo_Sample_Odd
		move.w	(a5)+,(a6)
		addx.l	d0,d2
		move.w	(a5),(a6)
		lea.l	(a0,d2.w*4),a5
		dbra		d1,MGTK_Replay_030_16_Bits_Stereo_Sample_Loop

		movea.l	(sp)+,a5
		bra.s	MGTK_Replay_030_Check_Loop

		
MGTK_Replay_030_Word_Sample
		lea.l	(a0,d2.l*2),a0
		addq.l	#2,a6
		move.w	(a6),d1				; Nb de Packets … envoyer - 1
		moveq.l	#0,d2

		lsr.w	d1
		bcs.s	MGTK_Replay_030_Word_Sample_Even
		move.w	(a0,d2.w*2),(a6)
		addx.l	d0,d2
		subq.w	#1,d1
MGTK_Replay_030_Word_Sample_Even
		lsr.w	d1
		bcc.s	MGTK_Replay_030_Word_Sample_Not_Four

MGTK_Replay_030_Word_Sample_Loop
		move.w	(a0,d2.w*2),(a6)
		addx.l	d0,d2
		move.w	(a0,d2.w*2),(a6)
		addx.l	d0,d2
MGTK_Replay_030_Word_Sample_Not_Four
		move.w	(a0,d2.w*2),(a6)
		addx.l	d0,d2
		move.w	(a0,d2.w*2),(a6)
		addx.l	d0,d2
		dbra		d1,MGTK_Replay_030_Word_Sample_Loop


MGTK_Replay_030_Check_Loop
		and.l	#$ffff,d2
		add.l	Voice_Sample_Position(a5),d2

		move.b	Voice_Sample_Attributes(a5),d3
		and.b	#%11,d3					; Type de Bouclage
		bne.s	MGTK_Replay_030_Loop

MGTK_Replay_030_No_Loop
		move.l	Voice_Sample_Length(a5),d3	; Pas de Boucle
		add.l	Voice_Sample_End_Length(a5),d3
		cmp.l	d3,d2					; A-t'on d‚pass‚ la fin
		blt.s	MGTK_Replay_030_Pos_Ok		; du Sample ?

		clr.l	Voice_Sample_Start(a5)		; Oui, alors sample
		bra.s	MGTK_Replay_030_Pos_Ok		; d‚sactiv‚

MGTK_Replay_030_Loop
		cmp.l	Voice_Sample_Length(a5),d2	; A-t'on d‚pass‚ la
		blt.s	MGTK_Replay_030_Pos_Ok		; fin de la boucle

		sub.l	Voice_Sample_Loop_Length(a5),d2	; Si oui, reboucle
		bra.s	MGTK_Replay_030_Loop

MGTK_Replay_030_Pos_Ok
		move.l	d2,Voice_Sample_Position(a5)	; Nouvelle position

		subq.l	#2,a6					; Port Host en long
		bra		MGTK_Replay_Get

;
; Plus d'autres voies
;

MGTK_Replay_No_More_Voices
		move.b	MGTK_Frequency_Divider+1(pc),$ffff8935.w
		sf		MGTK_Replay_In_Service

; S'occupe de la partition
		move.w	MGTK_IT_Counter(pc),d0
		addq.w	#1,d0
		move.w	d0,MGTK_IT_Counter
		cmp.w	MGTK_IT_Number(pc),d0
		blo.s	MGTK_Replay_Not_Patterns


		clr.w	MGTK_IT_Counter
		movem.l	d4-d7/a1-a4,-(sp)
		bsr.s	MGTK_Play_Patterns
		movem.l	(sp)+,d4-d7/a1-a4

MGTK_Replay_Not_Patterns
		movem.l	(sp)+,d0-d3/a0/a5/a6
		rte

MGTK_Voices_Ptr
		ds.l		1

***********************************************************************
***********				Gestion Patterns			***********
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

		move.b	MGTK_Initial_Speed(pc),MGTK_Music_Speed
		move.b	MGTK_Initial_Tempo(pc),MGTK_Music_Tempo
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
		movea.l	MGTK_Sequence_Adr(pc),a0
		move.w	MGTK_Music_Position(pc),d0
		move.w	MGTK_Nb_Voices(pc),d1
		add.w	d1,d1
		addq.w	#2,d1					; Pattern Length
		mulu.w	(a0,d0.w*2),d1
; Pointe sur num‚ros pistes
		lea.l	([MGTK_Patterns_Adr,pc],d1.l),a4
		move.w	(a4)+,MGTK_Pattern_Length

		lea.l	MGTK_Voices(pc),a6
		move.w	MGTK_Nb_Voices(pc),d7
		subq.w	#1,d7
MGTK_New_Notes_Loop
		bsr.s	MGTK_Play_Voice

		lea.l	Voice_Size(a6),a6
		dbra		d7,MGTK_New_Notes_Loop
		rts


MGTK_Play_Voice
		lea.l	MGTK_Track_0(pc),a0
		move.w	(a4)+,d0
		subq.w	#1,d0
		bmi.s	MGTK_Play_Track

		movea.l	([MGTK_Tracks_Ptr,pc],d0.w*4),a0
		move.w	MGTK_Pattern_Position(pc),d0
		mulu.w	#6,d0
		addq.w	#2,d0				; Track Length
		adda.w	d0,a0

MGTK_Play_Track
		move.b	(a0)+,Voice_Note(a6)
		move.b	(a0)+,Voice_Sample(a6)
		move.b	(a0)+,Voice_Vol_Command(a6)
		move.b	(a0)+,Voice_Command(a6)
		move.w	(a0),Voice_Parameter1(a6)

MGTK_Check_Sample
		moveq.l	#0,d2
		move.b	Voice_Sample(a6),d2
		beq.s	MGTK_Check_Efx_Volume

		subq.w	#1,d2
		mulu.w	#Sample_Size,d2
		lea.l	([MGTK_Samples_Infos_Adr,pc],d2.w),a3
		move.l	Sample_Start(a3),Voice_Start(a6)
		move.l	Sample_Length(a3),Voice_Length(a6)
		move.l	Sample_Loop_Length(a3),Voice_Loop_Length(a6)
		move.l	Sample_End_Length(a3),Voice_End_Length(a6)
		clr.l	Voice_Sample_Offset(a6)
		move.l	Sample_Base(a3),Voice_Base(a6)
		move.b	Sample_Attributes(a3),Voice_Attributes(a6)
		move.w	Sample_Volume(a3),Voice_Volume(a6)
		move.w	Sample_Volume(a3),Voice_Sample_Volume(a6)
		move.w	Sample_Panoramic(a3),d0
		beq.s	MGTK_Check_Sample_No_Panoramic
		move.w	d0,Voice_Left_Volume(a6)
MGTK_Check_Sample_No_Panoramic
		moveq.l	#0,d0
		move.b	Sample_Fine_Tune(a3),d0
		mulu.w	#12*8*4,d0
		move.w	d0,Voice_Sample_Fine_Tune(a6)

MGTK_Check_Efx_Volume
		moveq.l	#0,d0
		move.b	Voice_Vol_Command(a6),d0
		beq.s	MGTK_Check_Efx_0

		move.w	d0,d1
		and.b	#$0f,d0
		lsr.b	#4,d1
		cmp.b	#$6,d1				; Pas de slide
		beq.s	MGTK_Check_Efx_0
		cmp.b	#$7,d1				; au 1er tick
		beq.s	MGTK_Check_Efx_0
		cmp.b	#$f,d1
		beq		MGTK_Vol_Set_Tone_Portamento

		jsr		([Jump_Table_Vol,pc,d1.w*4])

MGTK_Check_Efx_0
		moveq.l	#0,d0
		move.b	Voice_Command(a6),d0
		jsr		([Jump_Table_0,pc,d0.w*4])

MGTK_Check_Note
		moveq.l	#0,d0
		move.b	Voice_Note(a6),d0
		beq.s	MGTK_Check_Efx_1

		sub.b	#12,d0
		lea.l	MGTK_Periods_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.l	(a0,d0.w*4),Voice_Period(a6)

		cmp.b	#$1d,Voice_Command(a6)
		bne.s	MGTK_No_Note_Delay
		tst.b	Voice_Parameter1(a6)
		beq.s	MGTK_No_Note_Delay
		rts

MGTK_No_Note_Delay
		move.l	Voice_Start(a6),Voice_Sample_Start(a6)
		move.l	Voice_Length(a6),Voice_Sample_Length(a6)
		move.l	Voice_Loop_Length(a6),Voice_Sample_Loop_Length(a6)
		move.l	Voice_End_Length(a6),Voice_Sample_End_Length(a6)
		move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)
		move.l	Voice_Base(a6),Voice_Sample_Base(a6)
		move.b	Voice_Attributes(a6),Voice_Sample_Attributes(a6)
		move.l	Voice_Period(a6),Voice_Sample_Period(a6)

		btst.b	#2,Voice_Vibrato_Waveform(a6)
		bne.s	MGTK_Vibrato_No_Reset
		clr.b	Voice_Vibrato_Position(a6)
MGTK_Vibrato_No_Reset

		btst.b	#2,Voice_Tremolo_Waveform(a6)
		bne.s	MGTK_Tremolo_No_Reset
		clr.b	Voice_Tremolo_Position(a6)
MGTK_Tremolo_No_Reset

MGTK_Check_Efx_1
		moveq.l	#0,d0
		move.b	Voice_Command(a6),d0
		jmp		([Jump_Table_1,pc,d0.w*4])


MGTK_No_New_Note
		lea.l	MGTK_Voices(pc),a6
		move.w	MGTK_Nb_Voices(pc),d7
		subq.w	#1,d7
MGTK_No_New_Note_Loop

		moveq.l	#0,d0		
		move.b	Voice_Vol_Command(a6),d0
		beq.s	MGTK_Check_Efx_2

		move.w	d0,d1
		and.b	#$0f,d0
		lsr.b	#4,d1
		jsr		([Jump_Table_Vol,pc,d1.w*4])

MGTK_Check_Efx_2
		moveq.l	#0,d0
		move.b	Voice_Command(a6),d0
		jsr		([Jump_Table_2,pc,d0.w*4])

		lea.l	Voice_Size(a6),a6
		dbra		d7,MGTK_No_New_Note_Loop
		rts


Jump_Table_Vol
		dc.l		MGTK_Return,MGTK_Vol_Change
		dc.l		MGTK_Vol_Change,MGTK_Vol_Change
		dc.l		MGTK_Vol_Change,MGTK_Vol_Maxi
		dc.l		MGTK_Vol_Slide_Down,MGTK_Vol_Slide_Up
		dc.l		MGTK_Vol_Fine_Slide_Down,MGTK_Vol_Fine_Slide_Up
		dc.l		MGTK_Vol_Set_Vibrato_Speed,MGTK_Vol_Vibrato
		dc.l		MGTK_Vol_Set_Panoramic,MGTK_Vol_Pan_Slide_Left
		dc.l		MGTK_Vol_Pan_Slide_Right,MGTK_Tone_Portamento_No_Change

MGTK_Vol_Change
		move.b	Voice_Vol_Command(a6),d0
		sub.b	#$10,d0
		lsl.w	#4,d0
		move.w	d0,Voice_Volume(a6)
		move.w	d0,Voice_Sample_Volume(a6)
		clr.b	Voice_Vol_Command(a6)
		rts

MGTK_Vol_Maxi
		move.w	#$400,Voice_Volume(a6)
		move.w	#$400,Voice_Sample_Volume(a6)
		clr.b	Voice_Vol_Command(a6)
		rts

MGTK_Vol_Slide_Down
		lsl.w	#4,d0
		sub.w	d0,Voice_Volume(a6)
		bpl.s	MGTK_Vol_Slide_Down_Ok

		clr.w	Voice_Volume(a6)
		clr.b	Voice_Vol_Command(a6)

MGTK_Vol_Slide_Down_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		rts

MGTK_Vol_Slide_Up
		lsl.w	#4,d0
		add.w	d0,Voice_Volume(a6)
		cmp.w	#$400,Voice_Volume(a6)
		ble.s	MGTK_Vol_Slide_Up_Ok

		move.w	#$400,Voice_Volume(a6)
		clr.b	Voice_Vol_Command(a6)

MGTK_Vol_Slide_Up_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		rts


MGTK_Vol_Fine_Slide_Down
		lsl.w	#4,d0
		sub.w	d0,Voice_Volume(a6)
		bpl.s	MGTK_Vol_Fine_Slide_Down_Ok
		clr.w	Voice_Volume(a6)

MGTK_Vol_Fine_Slide_Down_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		clr.b	Voice_Vol_Command(a6)
		rts

MGTK_Vol_Fine_Slide_Up
		lsl.w	#4,d0
		add.w	d0,Voice_Volume(a6)
		cmp.w	#$400,Voice_Volume(a6)
		ble.s	MGTK_Vol_Fine_Slide_Up_Ok
		move.w	#$400,Voice_Volume(a6)

MGTK_Vol_Fine_Slide_Up_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		clr.b	Voice_Vol_Command(a6)
		rts


MGTK_Vol_Set_Vibrato_Speed
		move.b	d0,Voice_Vibrato_Speed(a6)
		clr.b	Voice_Vol_Command(a6)
		rts

MGTK_Vol_Vibrato
		lsl.w	#8,d0
		beq		MGTK_Vibrato_2
		move.w	d0,Voice_Vibrato_Depth(a6)
		bra		MGTK_Vibrato_2


MGTK_Vol_Set_Panoramic
		move.w	(MGTK_Panoramics_Table,pc,d0.w*2),Voice_Left_Volume(a6)
		clr.b	Voice_Vol_Command(a6)
		rts


MGTK_Vol_Pan_Slide_Left
		move.b	Voice_Left_Volume(a6),d1
		add.w	d0,d1
		cmp.w	#$ff,d1
		ble.s	MGTK_Vol_Pan_Slide_Left_1
		move.w	#$ff,d1
MGTK_Vol_Pan_Slide_Left_1
		move.b	d1,Voice_Left_Volume(a6)

		move.b	Voice_Right_Volume(a6),d1
		sub.w	d0,d1
		bpl.s	MGTK_Vol_Pan_Slide_Left_2
		moveq.l	#0,d1
MGTK_Vol_Pan_Slide_Left_2
		move.b	d1,Voice_Right_Volume(a6)
		rts

MGTK_Vol_Pan_Slide_Right
		move.b	Voice_Left_Volume(a6),d1
		sub.w	d0,d1
		bpl.s	MGTK_Vol_Pan_Slide_Right_1
		moveq.l	#0,d1
MGTK_Vol_Pan_Slide_Right_1
		move.b	d1,Voice_Left_Volume(a6)

		move.b	Voice_Right_Volume(a6),d1
		add.w	d0,d1
		cmp.w	#$ff,d1
		ble.s	MGTK_Vol_Pan_Slide_Right_2
		moveq.l	#-1,d1
MGTK_Vol_Pan_Slide_Right_2
		move.b	d1,Voice_Right_Volume(a6)
		rts


MGTK_Vol_Set_Tone_Portamento
		lsl.w	#8,d0
		move.l	d0,Voice_Tone_Port_Speed(a6)

		moveq.l	#0,d0
		move.b	Voice_Note(a6),d0
		beq.s	MGTK_Vol_Set_Tone_Portamento_Ret
		sub.w	#12,d0
		lea.l	MGTK_Periods_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.l	(a0,d0.w*4),d0

		move.l	d0,Voice_Tone_Port_Period(a6)
		move.l	Voice_Period(a6),d1
		sf		Voice_Tone_Port_Direction(a6)
		cmp.l	d1,d0
		beq.s	MGTK_Vol_Clear_Tone_Portamento
		bge.s	MGTK_Vol_Set_Tone_Portamento_Ret
		st		Voice_Tone_Port_Direction(a6)

MGTK_Vol_Set_Tone_Portamento_Ret
		rts

MGTK_Vol_Clear_Tone_Portamento
		clr.l	Voice_Tone_Port_Period(a6)
		rts

Jump_Table_0
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Set_Tone_Portamento
		dc.l		MGTK_Return,MGTK_Set_Tone_Portamento
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Sample_Offset
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return

		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Note_Delay
		dc.l		MGTK_Return,MGTK_Return

		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return

		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return

Jump_Table_1
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Panning,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Position_Jump
		dc.l		MGTK_Volume_Change,MGTK_Pattern_Break
		dc.l		MGTK_Period_Nop,MGTK_Set_Speed_Tempo

		dc.l		MGTK_Return,MGTK_Portamento_Up
		dc.l		MGTK_Portamento_Down,MGTK_Set_Glissando_Control
		dc.l		MGTK_Set_Vibrato_Waveform,MGTK_Return
		dc.l		MGTK_Pattern_Loop,MGTK_Set_Tremolo_Waveform
		dc.l		MGTK_Set_Panoramic,MGTK_Note_Retrig_Plus_Volume_Slide
		dc.l		MGTK_Fine_Volume_Slide_Up,MGTK_Fine_Volume_Slide_Down
		dc.l		MGTK_Note_Cut,MGTK_Return
		dc.l		MGTK_Pattern_Delay,MGTK_Return

		dc.l		MGTK_Arpeggio3,MGTK_Period_Nop
		dc.l		MGTK_Arpeggio5,MGTK_Period_Nop
		dc.l		MGTK_Note_Slide,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop

		dc.l		MGTK_Set_Master_Volume,MGTK_Set_Global_Volume
		dc.l		MGTK_Period_Nop,MGTK_Global_Volume_Slide
		dc.l		MGTK_Set_Stereo,MGTK_Period_Nop
		dc.l		MGTK_Stereo_Slide,MGTK_Set_Base
		dc.l		MGTK_Release_Sample,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop

Jump_Table_2
		dc.l		MGTK_Arpeggio,MGTK_Portamento_Up
		dc.l		MGTK_Portamento_Down,MGTK_Tone_Portamento
		dc.l		MGTK_Vibrato,MGTK_Tone_Portamento_Plus_Volume_Slide
		dc.l		MGTK_Vibrato_Plus_Volume_Slide,MGTK_Tremolo
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Volume_Slide,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return

		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Note_Retrig_Plus_Volume_Slide
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Note_Cut,MGTK_Note_Delay
		dc.l		MGTK_Return,MGTK_Return

		dc.l		MGTK_Arpeggio3,MGTK_Arpeggio4
		dc.l		MGTK_Arpeggio5,MGTK_Note_Slide
		dc.l		MGTK_Return,MGTK_Tremor
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return
		dc.l		MGTK_Return,MGTK_Return

		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Global_Volume_Slide,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Stereo_Slide
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop
		dc.l		MGTK_Period_Nop,MGTK_Period_Nop


MGTK_Find_Period
		cmp.l	12*4(a0),d0
		bhs.s	MGTK_Do_Find_Period
		lea.l	12*4(a0),a0
		cmp.l	12*4(a0),d0
		bhs.s	MGTK_Do_Find_Period
		lea.l	12*4(a0),a0
		cmp.l	12*4(a0),d0
		bhs.s	MGTK_Do_Find_Period
		lea.l	12*4(a0),a0
		cmp.l	12*4(a0),d0
		bhs.s	MGTK_Do_Find_Period
		lea.l	12*4(a0),a0
		cmp.l	12*4(a0),d0
		bhs.s	MGTK_Do_Find_Period
		lea.l	12*4(a0),a0
		cmp.l	12*4(a0),d0
		bhs.s	MGTK_Do_Find_Period
		lea.l	12*4(a0),a0
		cmp.l	12*4(a0),d0
		bhs.s	MGTK_Do_Find_Period
		lea.l	12*4(a0),a0

MGTK_Do_Find_Period
		moveq.l	#12-1,d3
MGTK_Find_Period_Loop
		cmp.l	(a0)+,d0
		dbhs		d3,MGTK_Find_Period_Loop
		blo.s	MGTK_Period_Found
		subq.l	#4,a0
MGTK_Period_Found
		rts

MGTK_Period_Nop
		move.b	Voice_Vol_Command(a6),d0
		lsr.b	#4,d0
		cmp.b	#$b,d0		; Vibrato
		beq.s	MGTK_Return
		cmp.b	#$f,d0		; Tone Portamento
		beq.s	MGTK_Return

		move.l	Voice_Period(a6),Voice_Sample_Period(a6)
MGTK_Return
		rts


MGTK_Arpeggio
		move.w	Voice_Parameter1(a6),d1
		beq.s	MGTK_Period_Nop

MGTK_Arpeggio_0
		moveq.l	#0,d0
		move.b	MGTK_Music_Counter(pc),d0

		tst.b	d1
		beq.s	MGTK_Normal_Arpeggio

		add.w	#MGTK_Arpeggio_Table_5-MGTK_Arpeggio_Table_3,d0

MGTK_Normal_Arpeggio
		move.b	MGTK_Arpeggio_Table_3(pc,d0.w),d0
		beq.s	MGTK_Period_Nop
		subq.b	#2,d0
		beq.s	MGTK_Arpeggio_2
		subq.b	#1,d0
		beq.s	MGTK_Arpeggio_3
		subq.b	#1,d0
		beq.s	MGTK_Arpeggio_4

MGTK_Arpeggio_1
		lsr.w	#4,d1
MGTK_Arpeggio_2
		lsr.w	#4,d1
MGTK_Arpeggio_3
		lsr.w	#4,d1
MGTK_Arpeggio_4
		and.w	#$f,d1

		lea.l	MGTK_Periods_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.l	Voice_Period(a6),d0
		bsr		MGTK_Find_Period
		move.l	(a0,d1.w*4),Voice_Sample_Period(a6)
		rts

MGTK_Arpeggio_Table_3
		Rept		(256+3-1)/3
		dc.b		0,1,2
		EndR

MGTK_Arpeggio_Table_5
		Rept		(256+5-1)/5
		dc.b		0,1,2,3,4
		EndR


MGTK_Portamento_Up
		moveq.l	#0,d0
		move.w	Voice_Parameter1(a6),d0
		sub.l	d0,Voice_Period(a6)
		move.l	Voice_Period(a6),d0
		cmp.l	#$1af1,d0
		bhi.s	MGTK_Portamento_Up_Ok
		move.l	#$1af1,Voice_Period(a6)

MGTK_Portamento_Up_Ok
		move.l	Voice_Period(a6),Voice_Sample_Period(a6)
		rts

 
MGTK_Portamento_Down
		moveq.l	#0,d0
		move.w	Voice_Parameter1(a6),d0
		add.l	d0,Voice_Period(a6)
		move.l	Voice_Period(a6),d0
		cmp.l	#$1c5734,d0
		blo.s	MGTK_Portamento_Down_Ok
		move.l	#$1c5734,Voice_Period(a6)

MGTK_Portamento_Down_Ok
		move.l	Voice_Period(a6),Voice_Sample_Period(a6)
		rts


MGTK_Set_Tone_Portamento
		moveq.l	#0,d0
		move.b	Voice_Note(a6),d0
		beq.s	MGTK_Set_Tone_Portamento_Ret
		sub.w	#12,d0
		lea.l	MGTK_Periods_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.l	(a0,d0.w*4),d0

		move.l	d0,Voice_Tone_Port_Period(a6)
		move.l	Voice_Period(a6),d1
		sf		Voice_Tone_Port_Direction(a6)
		cmp.l	d1,d0
		beq.s	MGTK_Clear_Tone_Portamento
		bge.s	MGTK_Set_Tone_Portamento_Ret
		st		Voice_Tone_Port_Direction(a6)

MGTK_Set_Tone_Portamento_Ret
		addq.l	#4,sp
		rts

MGTK_Clear_Tone_Portamento
		clr.l	Voice_Tone_Port_Period(a6)
		addq.l	#4,sp
		rts

MGTK_Tone_Portamento
		moveq.l	#0,d0
		move.w	Voice_Parameter1(a6),d0
		beq.s	MGTK_Tone_Portamento_No_Change
		move.l	d0,Voice_Tone_Port_Speed(a6)
		clr.w	Voice_Parameter1(a6)

MGTK_Tone_Portamento_No_Change
		tst.l	Voice_Tone_Port_Period(a6)
		beq		MGTK_Period_Nop
		move.l	Voice_Tone_Port_Speed(a6),d0
		tst.b	Voice_Tone_Port_Direction(a6)
		bne.s	MGTK_Tone_Portamento_Up

MGTK_Tone_Portamento_Down
		add.l	d0,Voice_Period(a6)
		move.l	Voice_Tone_Port_Period(a6),d0
		cmp.l	Voice_Period(a6),d0
		bgt.s	MGTK_Tone_Portamento_Set_Period
		move.l	Voice_Tone_Port_Period(a6),Voice_Period(a6)
		clr.l	Voice_Tone_Port_Period(a6)
		bra.s	MGTK_Tone_Portamento_Set_Period

MGTK_Tone_Portamento_Up
		sub.l	d0,Voice_Period(a6)
		move.l	Voice_Tone_Port_Period(a6),d0
		cmp.l	Voice_Period(a6),d0
		blt.s	MGTK_Tone_Portamento_Set_Period
		move.l	Voice_Tone_Port_Period(a6),Voice_Period(a6)
		clr.l	Voice_Tone_Port_Period(a6)


MGTK_Tone_Portamento_Set_Period
		move.l	Voice_Period(a6),d0
		tst.b	Voice_Glissando_Control(a6)
		beq.s	MGTK_Glissando_Skip

		lea.l	MGTK_Periods_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		bsr		MGTK_Find_Period
		move.l	(a0),d0

MGTK_Glissando_Skip
		move.l	d0,Voice_Sample_Period(a6)
		rts


MGTK_Vibrato
		move.b	Voice_Parameter1(a6),d0
		lsr.b	#4,d0
		beq.s	MGTK_Vibrato_1
		move.b	d0,Voice_Vibrato_Speed(a6)
MGTK_Vibrato_1
		move.w	Voice_Parameter1(a6),d0
		and.w	#$0fff,d0
		beq.s	MGTK_Vibrato_2
		move.w	d0,Voice_Vibrato_Depth(a6)
MGTK_Vibrato_2

		lea.l	MGTK_Sinus_Table(pc),a3
		move.b	Voice_Vibrato_Position(a6),d0
		lsr.b	#2,d0
		and.w	#$001f,d0
		moveq.l	#0,d2
		move.b	Voice_Vibrato_Waveform(a6),d2
		and.b	#3,d2
		beq.s	MGTK_Vibrato_Sinus

		lsl.b	#3,d0
		cmp.b	#1,d2
		beq.s	MGTK_Vibrato_Ramp_Down
		move.b	#255,d2
		bra.s	MGTK_Vibrato_Set

MGTK_Vibrato_Ramp_Down
		tst.b	Voice_Vibrato_Position(a6)
		bpl.s	MGTK_Vibrato_Ramp_Down_2
		move.b	#255,d2
		sub.b	d0,d2
		bra.s	MGTK_Vibrato_Set
MGTK_Vibrato_Ramp_Down_2
		move.b	d0,d2
		bra.s	MGTK_Vibrato_Set

MGTK_Vibrato_Sinus
		move.b	(a3,d0.w),d2
MGTK_Vibrato_Set
		move.w	Voice_Vibrato_Depth(a6),d0
		mulu.w	d0,d2
		lsr.l	#7,d2
		move.l	Voice_Period(a6),d0
		tst.b	Voice_Vibrato_Position(a6)
		bmi.s	MGTK_Vibrato_Neg
		add.l	d2,d0
		bra.s	MGTK_Vibrato_3
MGTK_Vibrato_Neg
		sub.l	d2,d0
MGTK_Vibrato_3
		move.l	d0,Voice_Sample_Period(a6)

		move.b	Voice_Vibrato_Speed(a6),d0
		lsl.b	#2,d0
		add.b	d0,Voice_Vibrato_Position(a6)
		rts


MGTK_Tone_Portamento_Plus_Volume_Slide
		bsr		MGTK_Tone_Portamento_No_Change
		bra		MGTK_Volume_Slide


MGTK_Vibrato_Plus_Volume_Slide
		bsr.s	MGTK_Vibrato_2
		bra		MGTK_Volume_Slide


MGTK_Tremolo
		move.b	Voice_Parameter1(a6),d0
		lsr.b	#4,d0
		beq.s	MGTK_Tremolo_1
		move.b	d0,Voice_Tremolo_Speed(a6)
MGTK_Tremolo_1
		move.w	Voice_Parameter1(a6),d0
		and.w	#$0fff,d0
		beq.s	MGTK_Tremolo_2
		move.w	d0,Voice_Tremolo_Depth(a6)
MGTK_Tremolo_2

		lea.l	MGTK_Sinus_Table(pc),a3
		move.b	Voice_Tremolo_Position(a6),d0
		lsr.b	#2,d0
		and.w	#$001f,d0
		moveq.l	#0,d2
		move.b	Voice_Tremolo_Waveform(a6),d2
		and.b	#3,d2
		beq.s	MGTK_Tremolo_Sinus

		lsl.b	#3,d0
		cmp.b	#1,d2
		beq.s	MGTK_Tremolo_Ramp_Down
		move.b	#255,d2
		bra.s	MGTK_Tremolo_Set

MGTK_Tremolo_Ramp_Down
		tst.b	Voice_Tremolo_Position(a6)
		bpl.s	MGTK_Tremolo_Ramp_Down_2
		move.b	#255,d2
		sub.b	d0,d2
		bra.s	MGTK_Tremolo_Set
MGTK_Tremolo_Ramp_Down_2
		move.b	d0,d2
		bra.s	MGTK_Tremolo_Set

MGTK_Tremolo_Sinus
		move.b	(a3,d0.w),d2
MGTK_Tremolo_Set
		move.w	Voice_Tremolo_Depth(a6),d0
		mulu.w	d0,d2
		lsr.l	#6,d2
		move.w	Voice_Volume(a6),d0
		tst.b	Voice_Tremolo_Position(a6)
		bmi.s	MGTK_Tremolo_Neg
		add.w	d2,d0
		bra.s	MGTK_Tremolo_3
MGTK_Tremolo_Neg
		sub.w	d2,d0
		bmi.s	MGTK_Tremolo_Nul
MGTK_Tremolo_3
		cmp.w	#$400,d0
		ble.s	MGTK_Tremolo_Ok
		move.w	#$400,d0
		bra.s	MGTK_Tremolo_Ok
MGTK_Tremolo_Nul
		moveq.l	#0,d0
MGTK_Tremolo_Ok
		move.w	d0,Voice_Sample_Volume(a6)

		move.b	Voice_Tremolo_Speed(a6),d0
		lsl.b	#2,d0
		add.b	d0,Voice_Tremolo_Position(a6)
		bra		MGTK_Period_Nop


MGTK_Panning
		move.b	Voice_Parameter1(a6),d0
		move.b	d0,Voice_Right_Volume(a6)
		moveq.l	#-1,d1
		sub.b	d0,d1
		move.b	d1,Voice_Left_Volume(a6)
		rts


MGTK_Sample_Offset
		move.l	Voice_Sample_Offset(a6),d0
		moveq.l	#0,d1
		move.w	Voice_Parameter1(a6),d1
		beq.s	MGTK_Sample_Offset_No_New

		lsl.l	#4,d1
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
		move.b	Voice_Parameter1(a6),d0
		beq.s	MGTK_Volume_Slide_Down

MGTK_Volume_Slide_Up
		add.w	d0,Voice_Volume(a6)
		cmp.w	#$400,Voice_Volume(a6)
		ble.s	MGTK_Volume_Slide_Up_Ok
		move.w	#$400,Voice_Volume(a6)

MGTK_Volume_Slide_Up_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		rts


MGTK_Volume_Slide_Down
		move.b	Voice_Parameter2(a6),d0
		sub.w	d0,Voice_Volume(a6)
		bpl.s	MGTK_Volume_Slide_Down_Ok
		clr.w	Voice_Volume(a6)

MGTK_Volume_Slide_Down_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		rts


MGTK_Position_Jump
*		tst.b	Skip_Position_Jump
*		beq.s	MGTK_Position_Jump_Not_Skipped
*		rts
*
MGTK_Position_Jump_Not_Skipped
		move.w	Voice_Parameter1(a6),d0

		cmp.w	MGTK_Music_Length(pc),d0
		blo.s	MGTK_Position_Jump_Ok
		moveq.l	#0,d0
	
MGTK_Position_Jump_Ok
		move.w	d0,MGTK_Position_Jump_Position
		st		MGTK_Position_Jump_Flag
		rts


MGTK_Volume_Change
		move.w	Voice_Parameter1(a6),d0
		cmp.w	#$400,d0
		ble.s	MGTK_Volume_Change_Ok
		move.w	#$400,d0

MGTK_Volume_Change_Ok
		move.w	d0,Voice_Volume(a6)
		move.w	d0,Voice_Sample_Volume(a6)
		rts


MGTK_Pattern_Break
		move.w	Voice_Parameter1(a6),d0

		cmp.w	MGTK_Pattern_Length(pc),d0
		blo.s	MGTK_Pattern_Break_Ok
		moveq.l	#0,d0
	
MGTK_Pattern_Break_Ok
		move.w	d0,MGTK_Pattern_Break_Position
		st		MGTK_Pattern_Break_Flag
		rts


MGTK_Set_Speed_Tempo
		move.b	Voice_Parameter1(a6),d0
		beq.s	MGTK_No_Speed
		move.b	d0,MGTK_Music_Speed

MGTK_No_Speed
*		tst.b	Skip_Tempos
*		beq.s	MGTK_Tempos_Not_Skipped
*		rts
*
MGTK_Tempos_Not_Skipped
		moveq.l	#0,d0
		move.b	Voice_Parameter2(a6),d0
		bne.s	MGTK_Tempo_Ok
		rts

MGTK_Tempo_Ok
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


MGTK_Set_Glissando_Control
		move.b	Voice_Parameter1(a6),Voice_Glissando_Control(a6)
		rts


MGTK_Set_Vibrato_Waveform
		move.b	Voice_Parameter1(a6),Voice_Vibrato_Waveform(a6)
		rts


MGTK_Set_Fine_Tune
		move.b	Voice_Parameter1(a6),d0
		and.w	#$0f,d0
		mulu.w	#12*8*4,d0
		move.w	d0,Voice_Sample_Fine_Tune(a6)
		rts


MGTK_Pattern_Loop
		move.w	Voice_Parameter1(a6),d0
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


MGTK_Set_Tremolo_Waveform
		move.b	Voice_Parameter1(a6),Voice_Tremolo_Waveform(a6)
		rts


MGTK_Set_Panoramic
		move.b	Voice_Parameter1(a6),d0
		and.w	#$0f,d0
		move.w	(MGTK_Panoramics_Table,pc,d0.w*2),Voice_Left_Volume(a6)
		rts


MGTK_Note_Retrig_Plus_Volume_Slide
		moveq.l	#0,d0
		move.b	Voice_Parameter1(a6),d0
		beq.s	MGTK_No_Note_Retrig_Plus_Volume_Slide

		moveq.l	#0,d1
		move.b	MGTK_Music_Counter(pc),d1
		bne.s	MGTK_Note_Retrig_Plus_Volume_Slide_Skip

		tst.b	Voice_Note(a6)
		bne.s	MGTK_No_Note_Retrig_Plus_Volume_Slide

MGTK_Note_Retrig_Plus_Volume_Slide_Skip
		divu.w	d0,d1
		swap.w	d1
		tst.w	d1
		bne.s	MGTK_No_Note_Retrig_Plus_Volume_Slide

		move.l	Voice_Period(a6),Voice_Sample_Period(a6)
		move.l	Voice_Start(a6),Voice_Sample_Start(a6)
		move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)

		move.b	Voice_Parameter2(a6),d1
		beq.s	MGTK_No_Note_Retrig_Plus_Volume_Slide

		move.w	Voice_Volume(a6),d0
		and.w	#$f,d1
		jsr		([MGTK_NRPVS_Table,pc,d1.w*4])

MGTK_No_Note_Retrig_Plus_Volume_Slide
		rts

MGTK_NRPVS_M100
		sub.w	#$80,d0
MGTK_NRPVS_M80
		sub.w	#$40,d0
MGTK_NRPVS_M40
		sub.w	#$20,d0
MGTK_NRPVS_M20
		sub.w	#$10,d0
MGTK_NRPVS_M10
		sub.w	#$10,d0
		bpl.s	MGTK_NRPVS_Ok
		clr.w	Voice_Volume(a6)
		clr.w	Voice_Sample_Volume(a6)
		rts

MGTK_NRPVS_2_3
		add.w	d0,d0
		divu.w	#3,d0
		bra.s	MGTK_NRPVS_Ok

MGTK_NRPVS_1_2
		lsr.w	d0
		bra.s	MGTK_NRPVS_Ok

MGTK_NRPVS_P100
		add.w	#$80,d0
MGTK_NRPVS_P80
		add.w	#$40,d0
MGTK_NRPVS_P40
		add.w	#$20,d0
MGTK_NRPVS_P20
		add.w	#$10,d0
MGTK_NRPVS_P10
		add.w	#$10,d0
		add.w	#$100,d0
		cmp.w	#$400,d0
		ble.s	MGTK_NRPVS_Ok
		move.w	#$400,d0
MGTK_NRPVS_Ok
		move.w	d0,Voice_Volume(a6)
		move.w	d0,Voice_Sample_Volume(a6)
		rts

MGTK_NRPVS_3_2
		move.w	d0,d1
		lsr.w	d1
		add.w	d1,d0
		bra.s	MGTK_NRPVS_Ok

MGTK_NRPVS_2
		add.w	d0,d0
		bra.s	MGTK_NRPVS_Ok

MGTK_NRPVS_Table
		dc.l		MGTK_Return,MGTK_NRPVS_M10,MGTK_NRPVS_M20,MGTK_NRPVS_M40
		dc.l		MGTK_NRPVS_M80,MGTK_NRPVS_M100,MGTK_NRPVS_2_3,MGTK_NRPVS_1_2
		dc.l		MGTK_Return,MGTK_NRPVS_P10,MGTK_NRPVS_P20,MGTK_NRPVS_P40
		dc.l		MGTK_NRPVS_P80,MGTK_NRPVS_P100,MGTK_NRPVS_3_2,MGTK_NRPVS_2



MGTK_Fine_Volume_Slide_Up
		move.w	Voice_Parameter1(a6),d0
		add.w	d0,Voice_Volume(a6)
		cmp.w	#$400,Voice_Volume(a6)
		ble.s	MGTK_Fine_Volume_Slide_Up_Ok
		move.w	#$400,Voice_Volume(a6)

MGTK_Fine_Volume_Slide_Up_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		bra		MGTK_Period_Nop


MGTK_Fine_Volume_Slide_Down
		move.w	Voice_Parameter1(a6),d0
		sub.w	d0,Voice_Volume(a6)
		bpl.s	MGTK_Fine_Volume_Slide_Down_Ok
		clr.w	Voice_Volume(a6)

MGTK_Fine_Volume_Slide_Down_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		bra		MGTK_Period_Nop


MGTK_Note_Cut
		move.b	Voice_Parameter1(a6),d0
		cmp.b	MGTK_Music_Counter(pc),d0
		bne		MGTK_Period_Nop

		clr.w	Voice_Volume(a6)
		clr.w	Voice_Sample_Volume(a6)
		rts


MGTK_Note_Delay
		move.b	Voice_Parameter1(a6),d0
		cmp.b	MGTK_Music_Counter(pc),d0
		bne		MGTK_Period_Nop
		tst.b	Voice_Note(a6)
		beq		MGTK_Period_Nop

		move.l	Voice_Start(a6),Voice_Sample_Start(a6)
		move.l	Voice_Length(a6),Voice_Sample_Length(a6)
		move.l	Voice_Loop_Length(a6),Voice_Sample_Loop_Length(a6)
		move.l	Voice_End_Length(a6),Voice_Sample_End_Length(a6)
		move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)
		move.l	Voice_Base(a6),Voice_Sample_Base(a6)
		move.b	Voice_Attributes(a6),Voice_Sample_Attributes(a6)
		move.l	Voice_Period(a6),Voice_Sample_Period(a6)
		rts


MGTK_Pattern_Delay
		tst.b	MGTK_Pattern_Delay_Time(pc)
		bne		MGTK_Return

		move.b	Voice_Parameter1(a6),MGTK_Pattern_Delay_Time
		rts


MGTK_Arpeggio3
		move.b	Voice_Parameter1(a6),d1
		beq		MGTK_Period_Nop

		moveq.l	#0,d0
		move.b	MGTK_Music_Counter(pc),d0

		move.b	MGTK_Arpeggio3_Table(pc,d0.w),d0
		beq		MGTK_Period_Nop
		bpl.s	MGTK_Arpeggio3_Plus

		lsr.b	#4,d1
		neg.b	d1
		ext.w	d1
MGTK_Arpeggio3_Plus
		and.w	#$0f,d1

		lea.l	MGTK_Periods_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.l	Voice_Period(a6),d0
		bsr		MGTK_Find_Period
		move.l	(a0,d1.w*4),Voice_Sample_Period(a6)
		rts

MGTK_Arpeggio3_Table
		Rept		(256+3-1)/3
		dc.b		-1,0,1
		EndR


MGTK_Arpeggio4
		move.b	Voice_Parameter1(a6),d1
		beq		MGTK_Period_Nop

		moveq.l	#0,d0
		move.b	MGTK_Music_Counter(pc),d0

		move.b	MGTK_Arpeggio4_Table(pc,d0.w),d0
		beq		MGTK_Period_Nop
		bpl.s	MGTK_Arpeggio4_Plus

		lsr.b	#4,d1
		neg.b	d1
		ext.w	d1
MGTK_Arpeggio4_Plus
		and.w	#$0f,d1

		lea.l	MGTK_Periods_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.l	Voice_Period(a6),d0
		bsr		MGTK_Find_Period
		move.l	(a0,d1.w*4),Voice_Sample_Period(a6)
		rts

MGTK_Arpeggio4_Table
		Rept		256/4
		dc.b		0,1,0,-1
		EndR


MGTK_Arpeggio5
		move.b	Voice_Parameter1(a6),d1
		beq		MGTK_Period_Nop

		moveq.l	#0,d0
		move.b	MGTK_Music_Counter(pc),d0

		move.b	MGTK_Arpeggio5_Table(pc,d0.w),d0
		beq		MGTK_Period_Nop

		and.w	#$0f,d1

		lea.l	MGTK_Periods_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.l	Voice_Period(a6),d0
		bsr		MGTK_Find_Period
		move.l	(a0,d1.w*4),Voice_Sample_Period(a6)
		rts

MGTK_Arpeggio5_Table
		Rept		(256+3-1)/3
		dc.b		1,1,0
		EndR


MGTK_Note_Slide
		moveq.l	#0,d1
		move.b	Voice_Parameter1(a6),d1
		bne.s	MGTK_Note_Slide_Up

MGTK_Note_Slide_Down
		sub.b	Voice_Parameter2(a6),d1

MGTK_Note_Slide_Up
		lea.l	MGTK_Periods_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.l	Voice_Period(a6),d0
		bsr		MGTK_Find_Period
		move.l	(a0,d1.w*4),Voice_Period(a6)
		move.l	(a0,d1.w*4),Voice_Sample_Period(a6)
		rts


MGTK_Tremor
		moveq.l	#0,d0
		move.b	Voice_Parameter1(a6),d0
		add.b	Voice_Parameter2(a6),d0
		beq		MGTK_Return
		moveq.l	#0,d1
		move.b	MGTK_Music_Counter(pc),d1
		divu.w	d0,d1
		swap.w	d1
		cmp.b	Voice_Parameter1(a6),d1
		bhi.s	MGTK_Tremor_Off

MGTK_Tremor_On
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		rts

MGTK_Tremor_Off
		clr.w	Voice_Sample_Volume(a6)
		rts


MGTK_Set_Master_Volume
		move.b	Voice_Parameter1(a6),MGTK_Master_Volume_Left
		move.b	Voice_Parameter2(a6),MGTK_Master_Volume_Right
		rts


MGTK_Set_Global_Volume
		move.w	Voice_Parameter1(a6),MGTK_Global_Volume
		rts


MGTK_Global_Volume_Slide
		move.w	MGTK_Global_Volume(pc),d1
		moveq.l	#0,d0
		move.b	Voice_Parameter1(a6),d0
		beq.s	MGTK_Global_Volume_Slide_Down

MGTK_Global_Volume_Slide_Up
		add.w	d0,d1
		cmp.w	#$400,d1
		ble.s	MGTK_Global_Volume_Slide_Ok

		move.w	#$400,MGTK_Global_Volume
		rts

MGTK_Global_Volume_Slide_Down
		move.b	Voice_Parameter2(a6),d0
		sub.w	d0,d1
		bpl.s	MGTK_Global_Volume_Slide_Ok
		moveq.l	#0,d1
MGTK_Global_Volume_Slide_Ok
		move.w	d1,MGTK_Global_Volume
		rts


MGTK_Set_Base
		moveq.l	#0,d0
		move.w	Voice_Parameter1(a6),d0
		cmp.w	#50066,d0
		ble.s	MGTK_Set_Base_1
		move.l	#50066,Voice_Sample_Base(a6)
		rts
MGTK_Set_Base_1
		cmp.w	#1000,d0
		bhi.s	MGTK_Set_Base_2
		move.w	#1000,d0
MGTK_Set_Base_2
		move.l	d0,Voice_Sample_Base(a6)
		rts


MGTK_Set_Stereo
		move.w	Voice_Parameter1(a6),Voice_Left_Volume(a6)
		rts


MGTK_Stereo_Slide
		moveq.l	#0,d0
		move.b	Voice_Left_Volume(a6),d0
		move.b	Voice_Parameter1(a6),d1
		ext.w	d1
		add.w	d1,d0
		bpl.s	MGTK_Stereo_Slide_Left_1
		moveq.l	#0,d0
		bra.s	MGTK_Stereo_Slide_Left_2
MGTK_Stereo_Slide_Left_1
		cmp.w	#$00ff,d0
		ble.s	MGTK_Stereo_Slide_Left_2
		moveq.l	#-1,d0
MGTK_Stereo_Slide_Left_2
		move.b	d0,Voice_Left_Volume(a6)

		moveq.l	#0,d0
		move.b	Voice_Right_Volume(a6),d0
		move.b	Voice_Parameter2(a6),d1
		ext.w	d1
		add.w	d1,d0
		bpl.s	MGTK_Stereo_Slide_Right_1
		moveq.l	#0,d0
		bra.s	MGTK_Stereo_Slide_Right_2
MGTK_Stereo_Slide_Right_1
		cmp.w	#$00ff,d0
		ble.s	MGTK_Stereo_Slide_Right_2
		moveq.l	#-1,d0
MGTK_Stereo_Slide_Right_2
		move.b	d0,Voice_Left_Volume(a6)
		rts


MGTK_Release_Sample
		and.b	#%11111100,Voice_Sample_Attributes(a6)
		rts

***********************************************************************
***********			   Tables diverses				***********
***********************************************************************

MGTK_Panoramics_Table
		dc.w		$ff00,$ee11,$dd22,$cc33,$bb44,$aa55,$9966,$8080
		dc.w		$8080,$6699,$55aa,$44bb,$33cc,$22dd,$11ee,$00ff

MGTK_Sinus_Table	
		dc.b		0,24,49,74,97,120,141,161,180,197,212,224
		dc.b		235,244,250,253,255,253,250,244,235,224
		dc.b		212,197,180,161,141,120,97,74,49,24

; Table des p‚riodes pour chacune des 12 notes des 7 octaves pour
; les fine tune 0 … 7 et -8 … -1

MGTK_Periods_Table		IncBin	'PERIODS.TAB'

; Piste 0 = piste vide

MGTK_Track_0			dcb.b	6,0

***********************************************************************
***********				Replay DSP				***********
***********************************************************************

MGTK_DSP_Replay_Code
		IncBin	'MGT-PLAY.P56'
MGTK_DSP_Replay_Size	equ		(*-MGTK_DSP_Replay_Code)/3
		Even

***********************************************************************
***********			Variables diverses				***********
***********************************************************************

MGTK_Module_Adr			ds.l		1
MGTK_WorkSpace_Adr			ds.l		1
MGTK_Module_End_Adr			ds.l		1

MGTK_Nb_Voices				ds.w		1
MGTK_Nb_Musics				ds.w		1
MGTK_Nb_Tracks				ds.w		1
MGTK_Nb_Samples			ds.w		1

MGTK_Musics_Adr			ds.l		1
MGTK_Sequences_Adr			ds.l		1
MGTK_Samples_Infos_Adr		ds.l		1
MGTK_Patterns_Adr			ds.l		1
MGTK_Tracks_Ptr			ds.l		1
MGTK_Samples_Data_Adr		ds.l		1
MGTK_Samples_Length			ds.l		1
MGTK_Tracks_Length			ds.l		1

MGTK_Sequence_Adr			ds.w		1
MGTK_Music				ds.w		1
MGTK_Music_Position			ds.w		1
MGTK_Music_Length			ds.w		1
MGTK_Music_Restart			ds.w		1
MGTK_Initial_Tempo			ds.b		1
MGTK_Initial_Speed			ds.b		1
MGTK_Music_Tempo			ds.b		1
MGTK_Music_Speed			ds.b		1
MGTK_Music_Counter			ds.b		1
						ds.b		1

MGTK_Restart_Loop			ds.b		1
MGTK_Restart_Done			ds.b		1
MGTK_Replay_Paused			ds.b		1
MGTK_Replay_Stopped			ds.b		1
MGTK_IT_Timer_Control		ds.b		1
MGTK_IT_Timer_Data			ds.b		1
MGTK_IT_Number				ds.w		1
MGTK_IT_Counter			ds.w		1
MGTK_Frequency_Divider		ds.w		1
MGTK_Replay_Frequency		ds.w		1

MGTK_Replay_Satured			ds.w		1
MGTK_Replay_Problem			ds.b		1
MGTK_Replay_In_Service		ds.b		1

MGTK_Global_Volume			ds.w		1
MGTK_Master_Volume_Left		ds.b		1
MGTK_Master_Volume_Right		ds.b		1

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

						Even
MGTK_FX_Voices				ds.b		2*Voice_Size
MGTK_Voices				ds.b		32*Voice_Size
