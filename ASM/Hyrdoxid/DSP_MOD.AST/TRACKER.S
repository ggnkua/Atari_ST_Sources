***********************************************************************
***********										***********
***********										***********
***********		   DSP SoundTracker Replay			***********
***********										***********
***********	   Runs with most 4/6/8 Voices .MOD		***********
***********										***********
***********		    by Simplet / ABSTRACT			***********
***********										***********
***********										***********
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

Voice_Sample_Start			rs.l		1
Voice_Sample_Offset			rs.l		1
Voice_Sample_Position		rs.l		1
Voice_Sample_Length			rs.l		1
Voice_Sample_Repeat_Length	rs.l		1
Voice_Sample_Volume			rs.w		1
Voice_Sample_Period			rs.w		1
Voice_Sample_Fine_Tune		rs.w		1

Voice_Start				rs.l		1
Voice_Length				rs.l		1
Voice_Repeat_Length			rs.l		1
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
Voice_Funk_Speed			rs.b		1
Voice_Funk_Offset			rs.b		1
Voice_Funk_Position			rs.l		1
Voice_Funk_Start			rs.l		1

Voice_Size				rs.b		1

***********************************************************************
***********				Initialisations			***********
***********************************************************************

		Section	TEXT

Init_Music
		bsr		Init_Module
		bra		Init_Sound

Init_Music_IT
		clr.b	$fffffa19.w			; Coupe Timer
		move.l	#SndTrack_Timer,$134.w	; Installe Vecteur
		bset.b	#5,$fffffa07.w			; Autorise Timer
		bset.b	#5,$fffffa13.w			; D‚Maske Timer
		move.b	Simplet_IT_Timer_Data(pc),$fffffa1f.w
		move.b	Simplet_IT_Timer_Control(pc),$fffffa19.w
		rts

Stop_Music_IT
		clr.b	$fffffa19.w			; Coupe Timer
		bclr.b	#5,$fffffa07.w			; Autorise Timer
		bclr.b	#5,$fffffa13.w			; D‚Maske Timer
		rts

Stop_Music
		move.b	#%11,$ffff8937.w		; Revalide Yamaha PSG
		move.b	#$80+$14,$ffffa201.w	; Host User 1, adresse $28
		rts

Play_Music
		move.b	#%10,$ffff8937.w		; Seulement Matrice
		move.b	#$80+$15,$ffffa201.w	; Host User 1, adresse $2a
		rts

***********************************************************************
***********	   Interruptions du Replay Soundtracker		***********
***********************************************************************

SndTrack_Timer
		ror.w	SndTrack_Timer_Cmpt
		bcc.s	SndTrack_Timer_Ret

		move.b	Simplet_IT_Timer_Data(pc),$fffffa1f.w
		move.b	Simplet_IT_Timer_Control(pc),$fffffa19.w
		move.w	Simplet_IT_Sample_Length(pc),Code_Sample_Length
		bsr.s	SndTrack_IT

SndTrack_Timer_Ret
		bclr.b	#5,$fffffa0f.w		; … Cause du mode SEI
		rte

SndTrack_Timer_Cmpt
		dc.w		%0001000100010001


SndTrack_IT
*		move.l	$ffff9800.w,-(sp)
*		move.l	#$ff000000,$ffff9800.w

		movem.l	d0-d7/a0-a6,-(sp)

; Signale au DSP qu'on veut causer … la routine Soundtracker
		move.b	#$80+$13,$ffffa201.w	; Host User 0, adresse $26

; Port Host
		lea.l	$ffffa204.w,a6

; On balance le nombre de samples … calculer (code automodifi‚)
SplLen	move.l	#984,(a6)

Code_Sample_Length	equ	SplLen+4


		moveq.l	#0,d7
		move.w	Simplet_Voices_Nb(pc),d7
		subq.w	#2,d7
		lsr.w	d7
		move.l	d7,(a6)	; Nombre de paires de voies suppl‚mentaires

; Envoie les samples au DSP

		lea.l	Simplet_Voices(pc),a5		; Gauche
		bsr.s	Play_Voice
		lea.l	Voice_Size(a5),a5			; Droite
		bsr.s	Play_Voice

		subq.w	#1,d7

Play_All_Voices
		adda.w	Increment_Voice_1(pc),a5
		bsr.s	Play_Voice
		adda.w	Increment_Voice_2(pc),a5
		bsr.s	Play_Voice

		subq.w	#1,d7
		bmi.s	No_More_Voices

		adda.w	Increment_Voice_3(pc),a5
		bsr.s	Play_Voice
		adda.w	Increment_Voice_4(pc),a5
		bsr.s	Play_Voice

		subq.w	#1,d7
		bpl.s	Play_All_Voices


; S'occupe de la partition

No_More_Voices
		bsr		Simplet_Play_Patterns

		movem.l	(sp)+,d0-d7/a0-a6

*		move.l	(sp)+,$ffff9800.w
		rts

; S'occupe d'une voie : envoie volume, fr‚quence et les samples

Play_Voice
; Envoie volume
		moveq.l	#0,d0
		move.w	Voice_Sample_Volume(a5),d0
		mulu.l	#$7fffff/64*2,d0
		moveq.l	#0,d1
		move.w	Simplet_Voices_Nb(pc),d1
		divu.l	d1,d0
		move.l	d0,(a6)

; Envoie fr‚quence relative
		move.l	#$800000/49169*428*8363,d0
		moveq.l	#0,d1
		move.w	Voice_Sample_Period(a5),d1
		divu.l	d1,d0
		move.l	d0,(a6)

; Explication du calcul :
; Fr‚quence de replay d'une note =
; Periode de la Note * Base du DO-2 / Periode du DO-2
; Nous on veut le rapport avec la fr‚quence de Replay donc / 49169
; et r‚sultat … virgule pr‚multipli‚ par $800000 pour le DSP

; Recoie longueur du sample … envoyer
WaitDSP	btst.b	#0,$ffffa202.w
		beq.s	WaitDSP
		move.l	(a6),d0

		movea.l	Voice_Sample_Start(a5),a0
		move.l	Voice_Sample_Position(a5),d2
		adda.l	d2,a0				; Adresse courante
		add.l	d0,d2				; Nouvelle position d'arriv‚e

		cmp.l	Voice_Sample_Length(a5),d2	; A-t'on d‚pass‚ la fin ?
		blt.s	No_Repeat					; Si Non pas de probleme

		sub.l	Voice_Sample_Repeat_Length(a5),d2	; Si Oui, boucle

No_Repeat	move.l	d2,Voice_Sample_Position(a5)	; Nouvelle position

		ext.l	d0
		divu.l	#6,d0				; Envoi par paquet de 6 un
		addq.w	#1,d0				; de + car on tombe pas pile
		move.l	d0,(a6)				; Nombre de paquets

		subq.w	#1,d0				; pour le dbra
		subq.l	#1,a0				; Cale les samples

Send_Samples
		move.l	(a0),(a6)
		move.l	3(a0),(a6)
		addq.l	#6,a0
		dbra		d0,Send_Samples
		rts

***********************************************************************
***********		   Initialisations Son et DSP			***********
***********************************************************************

Init_Sound
* Stoppe la lecture DMA au cas o—...
		clr.b	$ffff8901.w

* DAC sur piste 0 (quartet fort)
		move.b	#$0f,$ffff8920.w

* Source DSP-Xmit sur Horloge Interne 25.175 MHz, DSP connect‚ (Enable)
* Source DMA-Play sur Horloge Interne 25.175 MHz
		move.w	#%10010001,$ffff8930.w

* Destinations DAC, DMA-Record et External OutPut
* connect‚es … Source DSP-Xmit, Handshaking On
* Destination DSP-Rec connect‚e sur DMA-Play, DSP connect‚ (Enable)
		move.w	#%0010001000010011,$ffff8932.w

* Fr‚quence 49169 Hz
		move.b	#1,$ffff8935.w

* Seulement Matrice et pas le PSG-Yamaha
		move.b	#%10,$ffff8937.w

* Programme DSP
		move.w	#113,-(sp)				; DSP_RequestUniqueAbility
		trap		#14						; XBios
		addq.l	#2,sp

		move.w	d0,-(sp)					; No Ability
		move.l	#(DSP_End-DSP_Code)/3,-(sp)	; Longueur en Mots DSP
		pea.l	DSP_Code(pc)				; Adresse du code binaire
		move.w	#109,-(sp)				; Dsp_ExecProg
		trap		#14						; XBios
		lea.l	12(sp),sp


Connect	move.l	#87654321,$ffffa204.w
		moveq.l	#0,d0

Conct_Get	btst.b	#0,$ffffa202.w
		bne.s	DSP_Test
		addq.l	#1,d0
		cmp.l	#100000,d0
		beq.s	DSP_Error
		bra.s	Conct_Get

DSP_Test	move.l	$ffffa204.w,d0
		cmp.l	#12345678,d0
		beq.s	DSP_Ok

DSP_Error	moveq.l	#-1,d0
DSP_Ok	rts

***********************************************************************
***********			Initialisations du Module		***********
***********************************************************************

Init_Module
		lea.l	Module,a0

		lea.l	20+31*30+2(a0),a1		; Par d‚faut
		lea.l	4+128(a1),a2			; Type
		moveq.l	#31,d0				; 31 instruments
		moveq.l	#64,d2				; 64 lignes par pattern
		sf		Simplet_Old_Module

		move.b	#125,Simplet_Tempo		; Tempo par d‚faut
		move.b	#6,Simplet_Speed		; Vitesse par d‚faut
		move.b	#5,Simplet_IT_Timer_Control
		move.b	#192,Simplet_IT_Timer_Data
		move.w	#984,Simplet_IT_Sample_Length

		move.l	$438(a0),d3			; ModFile Chunk

; Formats 4 voies
		moveq.l	#4,d1

		cmp.l	#"M.K.",d3
		beq.s	Format_Ok
		cmp.l	#"M!K!",d3
		beq.s	Format_Ok
		cmp.l	#"M&K&",d3
		beq.s	Format_Ok
		cmp.l	#"FA04",d3
		beq.s	Format_Digital
		cmp.l	#"FLT4",d3
		beq.s	Format_Ok

; Formats 6 voies
		moveq.l	#6,d1

		cmp.l	#"FA06",d3
		beq.s	Format_Digital
		cmp.l	#"6CHN",d3
		beq.s	Format_Ok
		cmp.l	#"FLT6",d3
		beq.s	Format_Ok

; Formats 8 voies
		moveq.l	#8,d1

		cmp.l	#"FA08",d3
		beq.s	Format_Digital
		cmp.l	#"8CHN",d3
		beq.s	Format_Ok
		cmp.l	#"CD81",d3
		beq.s	Format_Ok
		cmp.l	#"FLT8",d3
		beq.s	Format_Ok
		cmp.l	#"OCTA",d3
		beq.s	Format_Ok

; Si rien de sp‚cial alors c'est un ancien module 15 instruments
		lea.l	20+15*30+2(a0),a1
		lea.l	128(a1),a2
		moveq.l	#15,d0
		moveq.l	#4,d1
		st		Simplet_Old_Module
		bra.s	Format_Ok

Format_Digital
		move.w	(a2)+,d2
		addq.l	#2,a2

Format_Ok	move.l	a1,Simplet_Sequence_Adr	; Adresse de la s‚quence
		move.l	a2,Simplet_Patterns_Adr	; Adresse des patterns
		move.w	d0,Simplet_Samples_Nb	; Nombre d'instruments
		move.w	d1,Simplet_Voices_Nb	; Nombre de voies
		move.w	d2,Simplet_Pattern_Length

		lsl.w	#2,d1
		move.w	d1,Simplet_Line_Size	; Taille d'une 'ligne'
		mulu.w	d2,d1
		move.w	d1,Simplet_Pattern_Size	; Taille d'un pattern

		move.b	-2(a1),d0
		move.w	d0,Simplet_Song_Length	; Longueur du module
		move.b	-1(a1),d2
		cmp.b	d0,d2				; le Restart
		blo.s	Simplet_Restart_Ok		; est-il coh‚rent ?
		moveq.l	#0,d2				; si non, Restart = 0
Simplet_Restart_Ok
		move.w	d2,Simplet_Song_Restart

		subq.w	#1,d0				; Parcours la s‚quence
		moveq.l	#0,d1				; jusqu'… la derniŠre
Simplet_Sequence_Loop					; position
		move.b	(a1)+,d2				; No Pattern
		cmp.b	d1,d2				; Plus grand
		blo.s	Simplet_Seq_No_Max		; que le maximum ?
		move.b	d2,d1				; alors Nouveau maximum
Simplet_Seq_No_Max
		dbra		d0,Simplet_Sequence_Loop


		addq.w	#1,d1					; Nombre de patterns
		mulu.w	Simplet_Pattern_Size(pc),d1	; Taille totale

		move.l	Simplet_Patterns_Adr(pc),a1	; Adresse du d‚but
		lea.l	(a1,d1.l),a1				; Des samples

		lea.l	20(a0),a2				; Pointe sur Sample 1
		moveq.l	#0,d2
		move.w	Simplet_Samples_Nb(pc),d0
		subq.w	#1,d0

Simplet_Total_Length
		move.w	Amiga_Length(a2),d3		; Longueur
		ext.l	d3					; du sample
		add.l	d3,d3				; * 2 car stock‚ en words
		add.l	d3,d2				; Ajoute au total
		lea.l	Amiga_Size(a2),a2		; Instrument suivant
		dbra		d0,Simplet_Total_Length	; Calcule longueur totale


; Recopie les samples … la fin de la zone de travail temporaire
; pour justement pouvoir travailler dessus, les pr‚parer au bouclage
		lea.l	WorkSpace,a2

		move.l	a1,a3
		add.l	d2,a1

Simplet_Move_Samples
		move.l	-(a1),-(a2)
		move.l	-(a1),-(a2)
		subq.l	#8,d2
		bpl.s	Simplet_Move_Samples


; Maintenant, on bosse sur les samples
		lea.l	20(a0),a0					; Pointe sur 1er Sample
		lea.l	Simplet_Samples_Adr(pc),a1	; Adresse des samples

		move.w	Simplet_Samples_Nb(pc),d0
		subq.w	#1,d0

Simplet_Next_Sample
		move.l	a3,(a1)+					; Note Adresse

		move.w	Amiga_Length(a0),d3			; Longueur Nulle ?
		beq		Simplet_NextSample			; Alors pas d'instrument

		move.w	Amiga_Repeat_Length(a0),d4	; Longueur de Boucle
		cmp.w	#1,d4					; sup‚rieure … 1 ?
		bhi.s	Simplet_Repeat_Length		; Alors il y a bouclage


Simplet_No_Repeat_Length
		move.w	d3,d1				; Longueur
		subq.w	#1,d1
Simplet_Copy_1
		move.w	(a2)+,(a3)+			; Recopie simplement
		dbra		d1,Simplet_Copy_1		; le sample

		move.w	#1400-1,d2
Simplet_Copy_2
		clr.w	(a3)+				; et met du vide aprŠs
		dbra		d2,Simplet_Copy_2		; car ne boucle pas

		move.w	#1400,d1				; Repeat Length pour
		bra.s	Simplet_Sample_Ok		; boucler dans le vide


Simplet_Repeat_Length
		tst.w	Amiga_Repeat_Start(a0)	; Y'a t'il un d‚but de boucle?
		bne.s	Simplet_Repeat_Start	; Oui


		move.l	a3,a4				; Note le d‚but du sample

		move.w	d3,d1				; Longueur
		subq.w	#1,d1
Simplet_Copy_3
		move.w	(a2)+,(a3)+			; Recopie le sample jusqu'…
		dbra		d1,Simplet_Copy_3		; La fin de la boucle
		bra.s	Simplet_No_Repeat_Start


Simplet_Repeat_Start
		move.w	Amiga_Repeat_Start(a0),d1	; On prend le sample
		move.w	d1,d3					; jusqu'au d‚but de la
		move.l	a2,a4					; boucle

		subq.w	#1,d1
Simplet_Copy_4
		move.w	(a4)+,(a3)+
		dbra		d1,Simplet_Copy_4

		add.w	Amiga_Length(a0),a2
		add.w	Amiga_Length(a0),a2

Simplet_No_Repeat_Start
		move.l	a3,a5
		moveq.l	#0,d1

Simplet_Too_Small
		move.l	a4,a6
		move.w	d4,d2
		subq.w	#1,d2

Simplet_Copy_5
		move.w	(a6)+,(a3)+
		addq.w	#2,d1
		dbra		d2,Simplet_Copy_5

		cmp.w	#1400,d1
		blo.s	Simplet_Too_Small

		move.w	#1400/2-1,d2
Simplet_Copy_6
		move.w	(a5)+,(a3)+
		dbra		d2,Simplet_Copy_6


Simplet_Sample_Ok
		lsl.w	d3
		move.w	d3,Amiga_Length(a0)
		move.w	d1,Amiga_Repeat_Length(a0)
		clr.w	Amiga_Repeat_Start(a0)

Simplet_NextSample
		lea.l	Amiga_Size(a0),a0
		dbra		d0,Simplet_Next_Sample


		move.b	Simplet_Speed(pc),Simplet_Counter
		move.w	#-1,Simplet_Pattern_Position
		clr.w	Simplet_Song_Position
		clr.w	Simplet_Pattern_Break_Position
		sf		Simplet_Pattern_Break_Flag
		sf		Simplet_Position_Jump_Flag
		sf		Simplet_Pattern_Loop_Flag
		clr.b	Simplet_Pattern_Delay_Time


		lea.l	WorkSpace,a0
		move.l	#1000,d1
		move.l	#500,d2
		move.w	#2345,d4
		moveq.l	#0,d5

		lea.l	Simplet_Voices(pc),a6
		moveq.l	#8-1,d7

Init_A_Voice
		clr.l	Voice_Sample_Offset(a6)
		clr.l	Voice_Sample_Position(a6)
		move.l	a0,Voice_Sample_Start(a6)
		move.l	d1,Voice_Sample_Length(a6)
		move.l	d2,Voice_Sample_Repeat_Length(a6)
		move.w	d4,Voice_Sample_Period(a6)
		move.w	d5,Voice_Sample_Volume(a6)
		move.l	a0,Voice_Start(a6)
		move.l	d1,Voice_Length(a6)
		move.l	d2,Voice_Repeat_Length(a6)
		move.w	d4,Voice_Period(a6)
		move.w	d5,Voice_Volume(a6)
		move.l	a0,Voice_Funk_Start(a6)

		clr.l	Voice_Tone_Port_Direction(a6)
		clr.l	Voice_Vibrato_Position(a6)
		clr.b	Voice_Tremolo_Control(a6)
		clr.w	Voice_Funk_Speed(a6)
		clr.l	Voice_Funk_Position(a6)

		lea.l	Voice_Size(a6),a6
		dbra		d7,Init_A_Voice
		rts

***********************************************************************
***********			Remet les voies … z‚ro			***********
***********************************************************************

Clear_Voices
		lea.l	WorkSpace,a0
		move.l	#1000,d1
		move.l	#500,d2
		move.w	#2345,d4
		moveq.l	#0,d5

		lea.l	Simplet_Voices(pc),a6
		moveq.l	#8-1,d7

Clear_A_Voice
		clr.l	Voice_Sample_Offset(a6)
		clr.l	Voice_Sample_Position(a6)
		move.l	a0,Voice_Sample_Start(a6)
		move.l	d1,Voice_Sample_Length(a6)
		move.l	d2,Voice_Sample_Repeat_Length(a6)
		move.w	d4,Voice_Sample_Period(a6)
		move.w	d5,Voice_Sample_Volume(a6)
		move.l	a0,Voice_Start(a6)
		move.l	d1,Voice_Length(a6)
		move.l	d2,Voice_Repeat_Length(a6)
		move.w	d4,Voice_Period(a6)
		move.w	d5,Voice_Volume(a6)

		lea.l	Voice_Size(a6),a6
		dbra		d7,Clear_A_Voice
		rts

***********************************************************************
***********			Gestion du Soundtrack			***********
***********************************************************************

Simplet_Play_Patterns
		addq.b	#1,Simplet_Counter
		move.b	Simplet_Counter(pc),d0
		cmp.b	Simplet_Speed(pc),d0
		blo		Simplet_No_New_Note

		clr.b	Simplet_Counter

		tst.b	Simplet_Pattern_Break_Flag(pc)
		bne.s	Simplet_New_Pattern

		tst.b	Simplet_Pattern_Delay_Time(pc)
		beq.s	Simplet_No_Delay

		subq.b	#1,Simplet_Pattern_Delay_Time
		bra		Simplet_No_New_Note

Simplet_No_Delay
		tst.b	Simplet_Pattern_Loop_Flag(pc)
		beq.s	Simplet_No_Pattern_Loop

		move.w	Simplet_Pattern_Loop_Position(pc),Simplet_Pattern_Position
		sf		Simplet_Pattern_Loop_Flag
		bra.s	Simplet_New_Notes

Simplet_No_Pattern_Loop
		tst.b	Simplet_Position_Jump_Flag(pc)
		beq.s	Simplet_New_Line

		move.w	Simplet_Position_Jump_Pos(pc),d0
		sf		Simplet_Position_Jump_Flag
		bra.s	Simplet_New_Position

Simplet_New_Line
		addq.w	#1,Simplet_Pattern_Position
		move.w	Simplet_Pattern_Position(pc),d0
		cmp.w	Simplet_Pattern_Length(pc),d0
		blo.s	Simplet_New_Notes

Simplet_New_Pattern
		move.w	Simplet_Song_Position(pc),d0
		addq.w	#1,d0

Simplet_New_Position
		move.w	Simplet_Pattern_Break_Position(pc),Simplet_Pattern_Position
		clr.w	Simplet_Pattern_Break_Position
		sf		Simplet_Pattern_Break_Flag

		cmp.w	Simplet_Song_Length(pc),d0
		blo.s	Simplet_No_Restart
		move.w	Simplet_Song_Restart(pc),d0
		bne.s	Simplet_No_Restart

		move.b	#125,Simplet_Tempo
		move.b	#6,Simplet_Speed
		move.b	#5,Simplet_IT_Timer_Control
		move.b	#192,Simplet_IT_Timer_Data
		move.w	#984,Simplet_IT_Sample_Length

Simplet_No_Restart
		move.w	d0,Simplet_Song_Position


Simplet_New_Notes
		lea.l	Module+20,a5		; Pointe sur infos samples
		movea.l	Simplet_Sequence_Adr(pc),a0
		move.w	Simplet_Song_Position(pc),d1
		moveq.l	#0,d0
		move.b	(a0,d1.w),d0
		mulu.w	Simplet_Pattern_Size(pc),d0
		movea.l	Simplet_Patterns_Adr(pc),a4
		adda.l	d0,a4				; Pointe sur le Pattern
		move.w	Simplet_Pattern_Position(pc),d0
		mulu.w	Simplet_Line_Size(pc),d0
		adda.w	d0,a4				; Pointe sur la Bonne Ligne


		lea.l	Simplet_Voices(pc),a6
		move.w	Simplet_Voices_Nb(pc),d7
		subq.w	#1,d7
Simplet_New_Notes_Loop
		bsr.s	Simplet_Play_Voice

		lea.l	Voice_Size(a6),a6
		dbra		d7,Simplet_New_Notes_Loop
		rts


Simplet_No_New_Note
		lea.l	Simplet_Voices(pc),a6
		move.w	Simplet_Voices_Nb(pc),d7
		subq.w	#1,d7
Simplet_No_New_Note_Loop
		bsr		Simplet_Check_Efx_2

		lea.l	Voice_Size(a6),a6
		dbra		d7,Simplet_No_New_Note_Loop
		rts


Simplet_Play_Voice
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

		moveq.l	#0,d2
		move.b	Voice_Sample(a6),d2
		beq.s	Simplet_No_New_Sample

		subq.w	#1,d2
		lea.l	Simplet_Samples_Adr(pc),a1
		move.l	(a1,d2.w*4),Voice_Start(a6)
		clr.l	Voice_Sample_Offset(a6)
		mulu.w	#Amiga_Size,d2
		moveq.l	#0,d0
		move.w	Amiga_Length(a5,d2.w),d0
		move.l	d0,Voice_Length(a6)
		move.w	Amiga_Repeat_Length(a5,d2.w),d0
		move.l	d0,Voice_Repeat_Length(a6)
		moveq.l	#0,d0
		move.b	Amiga_Volume(a5,d2.w),d0
		move.w	d0,Voice_Volume(a6)
		move.w	d0,Voice_Sample_Volume(a6)
		move.b	Amiga_Fine_Tune(a5,d2.w),d0
		mulu.w	#12*3*2,d0
		move.w	d0,Voice_Sample_Fine_Tune(a6)

		move.w	Amiga_Repeat_Start(a5,d2.w),d0
		add.l	Voice_Start(a6),d0
		move.l	d0,Voice_Funk_Start(a6)

Simplet_No_New_Sample
		tst.w	Voice_Note(a6)
		beq		Simplet_Check_Efx_1

		move.w	Voice_Command(a6),d0
		and.w	#$0ff0,d0
		cmp.w	#$0e50,d0
		beq.s	Simplet_Do_Set_Fine_Tune

		move.b	Voice_Command(a6),d0
		subq.b	#3,d0				; 3 = Tone Portamento
		beq		Simplet_Set_Tone_Portamento
		subq.b	#2,d0				; 5 = Tone Porta + Vol Slide
		beq		Simplet_Set_Tone_Portamento
		subq.b	#4,d0				; 9 = Sample Offset
		bne.s	Simplet_Set_Period

		bsr		Simplet_Sample_Offset
		bra.s	Simplet_Set_Period

Simplet_Do_Set_Fine_Tune
		bsr		Simplet_Set_Fine_Tune

Simplet_Set_Period
		lea.l	Simplet_Period_Table(pc),a0
		move.w	Voice_Note(a6),d0
		bsr		Simplet_Find_Period
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.w	(a0),Voice_Period(a6)


		move.w	Voice_Command(a6),d0
		and.w	#$0ff0,d0
		cmp.w	#$0ed0,d0
		bne.s	Simplet_No_Note_Delay
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		beq.s	Simplet_No_Note_Delay
		rts

Simplet_No_Note_Delay
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		move.l	Voice_Start(a6),Voice_Sample_Start(a6)
		move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)
		move.l	Voice_Length(a6),d0
		move.l	Voice_Repeat_Length(a6),d1
		add.l	d1,d0
		move.l	d0,Voice_Sample_Length(a6)
		move.l	d1,Voice_Sample_Repeat_Length(a6)


		btst.b	#2,Voice_Vibrato_Control(a6)
		bne.s	Simplet_Vibrato_No_Reset
		clr.b	Voice_Vibrato_Position(a6)
Simplet_Vibrato_No_Reset

		btst.b	#2,Voice_Tremolo_Control(a6)
		bne.s	Simplet_Tremolo_No_Reset
		clr.b	Voice_Tremolo_Position(a6)
Simplet_Tremolo_No_Reset


Simplet_Check_Efx_1
		bsr		Simplet_Funk_Update
		moveq.l	#0,d0
		move.b	Voice_Command(a6),d0
		jmp		([Jump_Table_1,d0.w*4])

Jump_Table_1
		dc.l		Simplet_Period_Nop,Simplet_Period_Nop
		dc.l		Simplet_Period_Nop,Simplet_Period_Nop
		dc.l		Simplet_Period_Nop,Simplet_Period_Nop
		dc.l		Simplet_Period_Nop,Simplet_Period_Nop
		dc.l		Simplet_Period_Nop,Simplet_Period_Nop
		dc.l		Simplet_Period_Nop,Simplet_Position_Jump
		dc.l		Simplet_Volume_Change,Simplet_Pattern_Break
		dc.l		Simplet_E_Commands_1,Simplet_Set_Speed

Simplet_E_Commands_1
		move.b	Voice_Parameters(a6),d0
		and.w	#$f0,d0
		lsr.w	#4,d0
		jmp		([Jump_Table_E1,d0.w*4])

Jump_Table_E1
		dc.l		Simplet_Return,Simplet_Fine_Portamento_Up
		dc.l		Simplet_Fine_Portamento_Down,Simplet_Set_Glissando_Control
		dc.l		Simplet_Set_Vibrato_Control,Simplet_Return
		dc.l		Simplet_Pattern_Loop,Simplet_Set_Tremolo_Control
		dc.l		Simplet_Return,Simplet_Retrig_Note
		dc.l		Simplet_Volume_Fine_Up,Simplet_Volume_Slide_Down
		dc.l		Simplet_Note_Cut,Simplet_Return
		dc.l		Simplet_Pattern_Delay,Simplet_Funk_It


Simplet_Check_Efx_2
		bsr		Simplet_Funk_Update
		moveq.l	#0,d0
		move.b	Voice_Command(a6),d0
		jmp		([Jump_Table_2,d0.w*4])

Jump_Table_2
		dc.l		Simplet_Arpeggio,Simplet_Portamento_Up
		dc.l		Simplet_Portamento_Down,Simplet_Tone_Portamento
		dc.l		Mt_Vibrato,Simplet_Tone_Portamento_Plus_Volume_Slide
		dc.l		Simplet_Vibrato_Plus_Volume_Slide,Mt_Tremolo
		dc.l		Simplet_Return,Simplet_Return
		dc.l		Simplet_Volume_Slide,Simplet_Return
		dc.l		Simplet_Return,Simplet_Return
		dc.l		Simplet_E_Commands_2,Simplet_Return

Simplet_E_Commands_2
		move.b	Voice_Parameters(a6),d0
		and.w	#$f0,d0
		lsr.w	#4,d0
		jmp		([Jump_Table_E2,d0.w*4])

Jump_Table_E2
		dc.l		Simplet_Return,Simplet_Return
		dc.l		Simplet_Return,Simplet_Return
		dc.l		Simplet_Return,Simplet_Return
		dc.l		Simplet_Return,Simplet_Return
		dc.l		Simplet_Return,Simplet_Retrig_Note
		dc.l		Simplet_Return,Simplet_Return
		dc.l		Simplet_Note_Cut,Simplet_Note_Delay
		dc.l		Simplet_Return,Simplet_Return


Simplet_Find_Period
		cmp.w	12*2(a0),d0
		bhs.s	Simplet_Do_Find_Period
		lea.l	12*2(a0),a0
		cmp.w	12*2(a0),d0
		bhs.s	Simplet_Do_Find_Period
		lea.l	12*2(a0),a0

Simplet_Do_Find_Period
		moveq.l	#12-1,d3
Simplet_Find_Period_Loop
		cmp.w	(a0)+,d0
		dbhs		d3,Simplet_Find_Period_Loop
		blo.s	Simplet_Period_Found
		subq.l	#2,a0
Simplet_Period_Found
		rts


Simplet_Period_Nop
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)

Simplet_Return
		rts

Simplet_Arpeggio_Table
		dc.b		0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
		dc.b		1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

Simplet_Arpeggio
		move.b	Voice_Parameters(a6),d1
		beq.s	Simplet_Period_Nop

		moveq.l	#0,d0
		move.b	Simplet_Counter(pc),d0
		move.b	Simplet_Arpeggio_Table(pc,d0.w),d0
		beq.s	Simplet_Period_Nop
		subq.b	#2,d0
		beq.s	Simplet_Arpeggio_2

Simplet_Arpeggio_1
		lsr.w	#4,d1
Simplet_Arpeggio_2
		and.w	#$f,d1

		lea.l	Simplet_Period_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.w	Voice_Period(a6),d0
		bsr.s	Simplet_Find_Period
		move.w	(a0,d1.w*2),Voice_Sample_Period(a6)
		rts


Simplet_Portamento_Up
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0

Simplet_Portamento_Up2
		sub.w	d0,Voice_Period(a6)
		move.w	Voice_Period(a6),d0
		cmp.w	#113,d0
		bhi.s	Simplet_Portamento_Up_Ok
		move.w	#113,Voice_Period(a6)

Simplet_Portamento_Up_Ok
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		rts

 
Simplet_Portamento_Down
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
Simplet_Portamento_Down2
		add.w	d0,Voice_Period(a6)
		move.w	Voice_Period(a6),d0
		cmp.w	#856,d0
		blo.s	Simplet_Portamento_Down_Ok
		move.w	#856,Voice_Period(a6)

Simplet_Portamento_Down_Ok
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		rts


Simplet_Set_Tone_Portamento
		lea.l	Simplet_Period_Table(pc),a0
		move.w	Voice_Note(a6),d0
		bsr		Simplet_Find_Period
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.w	(a0),d0

		move.w	d0,Voice_Wanted_Period(a6)
		move.w	Voice_Period(a6),d1
		sf		Voice_Tone_Port_Direction(a6)
		cmp.w	d1,d0
		beq.s	Simplet_Clear_Tone_Portamento
		bge		Simplet_Period_Nop
		st		Voice_Tone_Port_Direction(a6)
		rts

Simplet_Clear_Tone_Portamento
		clr.w	Voice_Wanted_Period(a6)
		rts

Simplet_Tone_Portamento
		move.b	Voice_Parameters(a6),d0
		beq.s	Simplet_Tone_Portamento_No_Change
		move.b	d0,Voice_Tone_Port_Speed(a6)
		clr.b	Voice_Parameters(a6)

Simplet_Tone_Portamento_No_Change
		tst.w	Voice_Wanted_Period(a6)
		beq		Simplet_Period_Nop
		moveq.l	#0,d0
		move.b	Voice_Tone_Port_Speed(a6),d0
		tst.b	Voice_Tone_Port_Direction(a6)
		bne.s	Simplet_Tone_Portamento_Up

Simplet_Tone_Portamento_Down
		add.w	d0,Voice_Period(a6)
		move.w	Voice_Wanted_Period(a6),d0
		cmp.w	Voice_Period(a6),d0
		bgt.s	Simplet_Tone_Portamento_Set_Period
		move.w	Voice_Wanted_Period(a6),Voice_Period(a6)
		clr.w	Voice_Wanted_Period(a6)
		bra.s	Simplet_Tone_Portamento_Set_Period

Simplet_Tone_Portamento_Up
		sub.w	d0,Voice_Period(a6)
		move.w	Voice_Wanted_Period(a6),d0
		cmp.w	Voice_Period(a6),d0
		blt.s	Simplet_Tone_Portamento_Set_Period
		move.w	Voice_Wanted_Period(a6),Voice_Period(a6)
		clr.w	Voice_Wanted_Period(a6)


Simplet_Tone_Portamento_Set_Period
		move.w	Voice_Period(a6),d0
		tst.b	Voice_Glissando_Control(a6)
		beq.s	Simplet_Glissando_Skip

		lea.l	Simplet_Period_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		bsr		Simplet_Find_Period
		move.w	(a0),d0

Simplet_Glissando_Skip
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
		lea.l	Simplet_Sinus_Table(pc),a3
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

Simplet_Tone_Portamento_Plus_Volume_Slide
		bsr		Simplet_Tone_Portamento_No_Change
		bra		Simplet_Volume_Slide


Simplet_Vibrato_Plus_Volume_Slide
		bsr.s	Mt_Vibrato2
		bra		Simplet_Volume_Slide

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
		lea.l	Simplet_Sinus_Table(pc),a3
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
		bra		Simplet_Period_Nop


Simplet_Sample_Offset
		move.l	Voice_Sample_Offset(a6),d1
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
		beq.s	Simplet_Sample_Offset_No_New

		lsl.w	#8,d0
		move.l	d0,d1
Simplet_Sample_Offset_No_New

		move.l	Voice_Sample_Offset(a6),d0
		add.l	d1,d0
		cmp.l	Voice_Length(a6),d0
		ble.s	Simplet_Sample_Offset_Ok
		move.l	Voice_Length(a6),d0
Simplet_Sample_Offset_Ok
		move.l	d0,Voice_Sample_Offset(a6)
		move.l	d0,Voice_Sample_Position(a6)
		rts


Simplet_Volume_Slide
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
		lsr.w	#4,d0
		beq.s	Simplet_Volume_Slide_Down

Simplet_Volume_Slide_Up
		add.w	d0,Voice_Volume(a6)
		cmp.w	#$40,Voice_Volume(a6)
		ble.s	Simplet_Volume_Slide_Up_Ok
		move.w	#$40,Voice_Volume(a6)

Simplet_Volume_Slide_Up_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		bra		Simplet_Period_Nop


Simplet_Volume_Slide_Down
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0

Simplet_Volume_Slide_Down2
		sub.w	d0,Voice_Volume(a6)
		bpl.s	Simplet_Volume_Slide_Down_Ok
		clr.w	Voice_Volume(a6)

Simplet_Volume_Slide_Down_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		bra		Simplet_Period_Nop


Simplet_Position_Jump
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0

		move.w	d0,Simplet_Position_Jump_Pos
		st		Simplet_Position_Jump_Flag
		rts


Simplet_Volume_Change
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
		cmp.b	#$40,d0
		ble.s	Simplet_Volume_Change_Ok
		moveq.l	#$40,d0

Simplet_Volume_Change_Ok
		move.w	d0,Voice_Volume(a6)
		move.w	d0,Voice_Sample_Volume(a6)
		rts


Simplet_Pattern_Break
		moveq.l	#0,d0

		tst.b	Simplet_Old_Module(pc)
		bne.s	Simplet_Pattern_Break_Ok

		move.b	Voice_Parameters(a6),d0

		move.w	d0,d2			; Codage en BCD
		lsr.w	#4,d0			; premier chiffre
		mulu.w	#10,d0			; les dizaines
		and.w	#$0f,d2			; deuxiŠme chiffre
		add.w	d2,d0			; les unit‚s

		cmp.w	Simplet_Pattern_Length(pc),d0
		blo.s	Simplet_Pattern_Break_Ok
		moveq.l	#0,d0
	
Simplet_Pattern_Break_Ok
		move.w	d0,Simplet_Pattern_Break_Position
		st		Simplet_Pattern_Break_Flag
		rts


Simplet_Set_Speed
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
		beq.s	Simplet_End
		cmp.b	#32,d0
		bhi.s	Simplet_Set_Tempo
		move.b	d0,Simplet_Speed
Simplet_End
		rts

Simplet_Set_Tempo
		move.b	d0,Simplet_Tempo
		sub.b	#32,d0
		lea.l	Simplet_Tempo_Table(pc),a2
		move.w	(a2,d0.w*4),Simplet_IT_Sample_Length
		move.b	2(a2,d0.w*4),Simplet_IT_Timer_Control
		move.b	3(a2,d0.w*4),Simplet_IT_Timer_Data
		rts


Simplet_Fine_Portamento_Up
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		bra		Simplet_Portamento_Up2
 
Simplet_Fine_Portamento_Down
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		bra		Simplet_Portamento_Down2


Simplet_Set_Glissando_Control
		move.b	Voice_Parameters(a6),Voice_Glissando_Control(a6)
		rts

Simplet_Set_Vibrato_Control
		move.b	Voice_Parameters(a6),Voice_Vibrato_Control(a6)
		rts

Simplet_Set_Fine_Tune
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		mulu.w	#12*3*2,d0
		move.w	d0,Voice_Sample_Fine_Tune(a6)
		rts

Simplet_Pattern_Loop
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		beq.s	Simplet_Set_Loop_Position

		tst.w	Simplet_Pattern_Loop_Counter(pc)
		beq.s	Simplet_Set_Loop_Counter

		subq.w	#1,Simplet_Pattern_Loop_Counter
		beq		Simplet_Return

Simplet_Do_Loop	
		st		Simplet_Pattern_Loop_Flag
		rts
Simplet_Set_Loop_Counter
		move.w	d0,Simplet_Pattern_Loop_Counter
		bra.s	Simplet_Do_Loop
Simplet_Set_Loop_Position
		move.w	Simplet_Pattern_Position(pc),Simplet_Pattern_Loop_Position
		rts


Simplet_Set_Tremolo_Control
		move.b	Voice_Parameters(a6),Voice_Tremolo_Control(a6)
		rts


Simplet_Retrig_Note
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		beq.s	Simplet_No_Retrig_Note

		moveq.l	#0,d1
		move.b	Simplet_Counter(pc),d1
		bne.s	Simplet_Retrig_Note_Skip

		tst.w	Voice_Note(a6)
		bne.s	Simplet_No_Retrig_Note

Simplet_Retrig_Note_Skip
		divu.w	d0,d1
		swap.w	d1
		tst.w	d1
		bne.s	Simplet_No_Retrig_Note

		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)

Simplet_No_Retrig_Note
		rts


Simplet_Volume_Fine_Up
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		bra		Simplet_Volume_Slide_Up


Simplet_Note_Cut
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		cmp.b	Simplet_Counter(pc),d0
		bne		Simplet_Return
		clr.w	Voice_Volume(a6)
		clr.w	Voice_Sample_Volume(a6)
		rts

Simplet_Note_Delay
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		cmp.b	Simplet_Counter(pc),d0
		bne		Simplet_Return
		tst.w	Voice_Note(a6)
		beq		Simplet_Return

		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		move.l	Voice_Start(a6),Voice_Sample_Start(a6)
		move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)
		move.l	Voice_Length(a6),d0
		move.l	Voice_Repeat_Length(a6),d1
		add.l	d1,d0
		move.l	d0,Voice_Sample_Length(a6)
		move.l	d1,Voice_Sample_Repeat_Length(a6)
		rts


Simplet_Pattern_Delay
		tst.b	Simplet_Pattern_Delay_Time(pc)
		bne		Simplet_Return
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		move.b	d0,Simplet_Pattern_Delay_Time
		rts


Simplet_Funk_It
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		move.b	d0,Voice_Funk_Speed(a6)
		beq		Simplet_Return

Simplet_Funk_Update
		moveq.l	#0,d0
		move.b	Voice_Funk_Speed(a6),d0
		beq		Simplet_Return

		lea.l	Simplet_Funk_Table(pc),a0
		move.b	(a0,d0.w),d0
		add.b	d0,Voice_Funk_Offset(a6)
		btst.b	#7,Voice_Funk_Offset(a6)
		beq		Simplet_Return

		clr.b	Voice_Funk_Offset(a6)

		movea.l	Voice_Funk_Position(a6),a0
		addq.w	#1,a0
		cmpa.l	Voice_Repeat_Length(a6),a0
		blo.s	Simplet_Funk_Ok
		movea.w	#0,a0
Simplet_Funk_Ok
		move.l	a0,Voice_Funk_Position(a6)
		add.l	Voice_Funk_Start(a6),a0
		moveq.l	#-1,d0
		sub.b	(a0),d0
		move.b	d0,(a0)
		rts		


Simplet_Sinus_Table	
		dc.b		0,24,49,74,97,120,141,161,180,197,212,224
		dc.b		235,244,250,253,255,253,250,244,235,224
		dc.b		212,197,180,161,141,120,97,74,49,24

Simplet_Funk_Table
		dc.b		0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128


Simplet_Period_Table
; Tuning 0, Normal
		dc.w 856,808,762,720,678,640,604,570,538,508,480,453
		dc.w 428,404,381,360,339,320,302,285,269,254,240,226
		dc.w 214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
		dc.w 850,802,757,715,674,637,601,567,535,505,477,450
		dc.w 425,401,379,357,337,318,300,284,268,253,239,225
		dc.w 213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
		dc.w 844,796,752,709,670,632,597,563,532,502,474,447
		dc.w 422,398,376,355,335,316,298,282,266,251,237,224
		dc.w 211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
		dc.w 838,791,746,704,665,628,592,559,528,498,470,444
		dc.w 419,395,373,352,332,314,296,280,264,249,235,222
		dc.w 209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
		dc.w 832,785,741,699,660,623,588,555,524,495,467,441
		dc.w 416,392,370,350,330,312,294,278,262,247,233,220
		dc.w 208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
		dc.w 826,779,736,694,655,619,584,551,520,491,463,437
		dc.w 413,390,368,347,328,309,292,276,260,245,232,219
		dc.w 206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
		dc.w 820,774,730,689,651,614,580,547,516,487,460,434
		dc.w 410,387,365,345,325,307,290,274,258,244,230,217
		dc.w 205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
		dc.w 814,768,725,684,646,610,575,543,513,484,457,431
		dc.w 407,384,363,342,323,305,288,272,256,242,228,216
		dc.w 204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
		dc.w 907,856,808,762,720,678,640,604,570,538,508,480
		dc.w 453,428,404,381,360,339,320,302,285,269,254,240
		dc.w 226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
		dc.w 900,850,802,757,715,675,636,601,567,535,505,477
		dc.w 450,425,401,379,357,337,318,300,284,268,253,238
		dc.w 225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
		dc.w 894,844,796,752,709,670,632,597,563,532,502,474
		dc.w 447,422,398,376,355,335,316,298,282,266,251,237
		dc.w 223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
		dc.w 887,838,791,746,704,665,628,592,559,528,498,470
		dc.w 444,419,395,373,352,332,314,296,280,264,249,235
		dc.w 222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
		dc.w 881,832,785,741,699,660,623,588,555,524,494,467
		dc.w 441,416,392,370,350,330,312,294,278,262,247,233
		dc.w 220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
		dc.w 875,826,779,736,694,655,619,584,551,520,491,463
		dc.w 437,413,390,368,347,328,309,292,276,260,245,232
		dc.w 219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
		dc.w 868,820,774,730,689,651,614,580,547,516,487,460
		dc.w 434,410,387,365,345,325,307,290,274,258,244,230
		dc.w 217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
		dc.w 862,814,768,725,684,646,610,575,543,513,484,457
		dc.w 431,407,384,363,342,323,305,288,272,256,242,228
		dc.w 216,203,192,181,171,161,152,144,136,128,121,114


; Table qui contient les paramŠtres pour l'interruption Timer
; et le nombre de samples … calculer en fonction du Tempo

Simplet_Tempo_Table			IncBin	'C:\UTILS\CODE_UTI.LS\GEN_ASM\DSP_MOD.AST\TEMPODSP.TAB'

; Variables de gestion

							ds.b		1
Simplet_Old_Module				ds.b		1
Simplet_Sequence_Adr			ds.l		1
Simplet_Patterns_Adr			ds.l		1
Simplet_Line_Size				ds.w		1
Simplet_Pattern_Size			ds.w		1
Simplet_Samples_Adr				ds.l		31

Simplet_Voices_Nb				ds.w		1
Simplet_Samples_Nb				ds.w		1

Simplet_Song_Position			ds.w		1
Simplet_Song_Length				ds.w		1
Simplet_Song_Restart			ds.w		1

Simplet_Pattern_Position			ds.w		1
Simplet_Pattern_Length			ds.w		1

Simplet_Pattern_Loop_Counter		ds.w		1
Simplet_Pattern_Loop_Position		ds.w		1
Simplet_Pattern_Break_Position	ds.w		1
Simplet_Position_Jump_Pos		ds.w		1
Simplet_Pattern_Loop_Flag		ds.b		1
Simplet_Pattern_Break_Flag		ds.b		1
Simplet_Position_Jump_Flag		ds.b		1
Simplet_Pattern_Delay_Time		ds.b		1
Simplet_Tempo					ds.b		1
Simplet_Speed					ds.b		1
Simplet_Counter				ds.b		1

Simplet_IT_In_Service			ds.b		1
Simplet_IT_Timer_Control			ds.b		1
Simplet_IT_Timer_Data			ds.b		1
Simplet_IT_Sample_Length			ds.w		1

Simplet_Voices					ds.b		8*Voice_Size

; Pour un enchainement st‚r‚o Amiga  L R R L L R R L
Increment_Voice_1			dc.w		2*Voice_Size
Increment_Voice_2			dc.w		-Voice_Size
Increment_Voice_3			dc.w		2*Voice_Size
Increment_Voice_4			dc.w		Voice_Size

; Pour un enchainement st‚r‚o simple L R L R L R L R
*Increment_Voice_1			dc.w		Voice_Size
*Increment_Voice_2			dc.w		Voice_Size
*Increment_Voice_3			dc.w		Voice_Size
*Increment_Voice_4			dc.w		Voice_Size

***********************************************************************
***********				Routine DSP				***********
***********************************************************************

DSP_Code		IncBin	'C:\UTILS\CODE_UTI.LS\GEN_ASM\DSP_MOD.AST\TRACKER.P56'
DSP_End		Even

***********************************************************************
***********				Section BSS				***********
***********************************************************************

			Section	BSS

			ds.l		100*1024/4	; WorkSpace variable suivant modules
WorkSpace		ds.l		1000/4		; premier de la section BSS
