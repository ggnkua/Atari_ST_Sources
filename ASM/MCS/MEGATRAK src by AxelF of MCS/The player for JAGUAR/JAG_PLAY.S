************************************************************************************************
*
*	MEGATRACKER REPLAY ROUT POUR JAGUAR V 0.5
*
*	CE SOURCE EST PREVU POUR ETRE EN MODE 800*600 TAB 5
*
************************************************************************************************		
DEBUG					=	1

						include	"includes/jaguar.inc"
						;include	"includes/macros.inc"
						include	"INCLUDES/macro_op.s"
						include	"INCLUDES/macro_ga.s"

ISTACKD					= D_ENDRAM-256-4	; Location of interrupt stack
ADR_DPCODE				= D_RAM			; == DSP Object Processor Interrupt

CLOCK_FREQUENCY			= 26592000
SERIAL_CLOCK_FREQUENCY		= 12
FREQ_REPLAY				= CLOCK_FREQUENCY/32/(2*(SERIAL_CLOCK_FREQUENCY+1))
DIV_TEMPO					= (CLOCK_FREQUENCY/2000/50)-1		; 50 hz
DSP_Buffer				equ	650*2					; DSP Sample Buffer Size
False					= -1
True						= 0
;***********************************************************************************************
;**********				Variables Globales
;***********************************************************************************************
						globl	MGTK_Voices
						globl	CPU_Interrupt
						
;***********************************************************************************************
;**********				Macros
;***********************************************************************************************
MACRO	movel	reg1,reg2
		loadw	(\reg1),\reg2
		addq		#2,\reg1
		shlq		#16,\reg2
		loadw	(\reg1),r25				; r25 TRASHED !
		add		r25,\reg2
ENDM
						
;***********************************************************************************************
;***********				Structures		
;***********************************************************************************************
MGT_Chunk					=	0		;rs.b	3	* "MGT"
MGT_Version				=	3		;rs.b	1	* $11, $xy pour Version x.y
MGT_Copyright				=	4		;rs.b	4	* "½MCS"
MGT_Nb_Voices				=	8		;rs.w	1	* Nombre de Voies
MGT_Nb_Musics				=	10		;rs.w	1	* Nombre de Musiques
MGT_Nb_Orders				=	12		;rs.w	1	* Nombre de Positions
MGT_Nb_Patterns			=	14		;rs.w	1	* Nombre de Patterns
MGT_Nb_Tracks				=	16		;rs.w	1	* Nombre de Pistes sauv‚es (sans la 0)
MGT_Nb_Samples				=	18		;rs.w	1	* Nombre de Samples
MGT_Attributes				=	20		;rs.w	1	* Inutilis‚ pour l'instant
MGT_Reserved				=	22		;rs.l	1	* R‚serv‚ pour le futur

MGT_Musics				=	26		;rs.l	1	* Adresse des Musics
MGT_Sequences				=	30		;rs.l	1	* Adresse des Sequences
MGT_Samples_Infos			=	34		;rs.l	1	* Adresse des Infos Samples
MGT_Patterns				=	38		;rs.l	1	* Adresse des Patterns
MGT_Tracks_Ptr				=	42		;rs.l	1	* Adresse des Pointeurs de Piste
MGT_Samples_Data			=	46		;rs.l	1	* Adresse des Donn‚es Samples
MGT_Samples_Length			=	50		;rs.l	1	* Longueur Totale des Samples
MGT_Tracks_Length			=	54		;rs.l	1	* Longueur des Tracks D‚pack‚es
;***********************************************************************************************

Sample_Name				=	0		;rs.b	32	; 32 caractŠres

Sample_Start				=	32		;rs.l	1	; Adresse d‚but du Sample
Sample_Length				=	36		;rs.l	1	; Taille du sample en unit‚s
Sample_Loop_Start			=	40		;rs.l	1	; Offset d‚but Boucle en unit‚s
Sample_Loop_Length			=	44		;rs.l	1	; Taille de la Boucle en unit‚s
Sample_Buffer_Length		=	48		;rs.l	1	; Taille Minimale du Buffer en unit‚s
Sample_End_Length			=	52		;rs.l	1	; Taille de la fin du sample aprŠs le buffer

Sample_Base				=	56		;rs.l	1	; Fr‚quence de Replay pour le DO-4
Sample_Volume				=	60		;rs.w	1	; Volume par d‚faut de 0 … 1024
Sample_Panoramic			=	62		;rs.b	2	; Volumes Gauche et Droit de 0 … 255
									; 			  par d‚faut, 0 si y'en a pas
Sample_Attributes			=	64		;rs.b	1	; bits 0 et 1 : Loop Mode -->
									;  			  0 = Loop Off,	1 = Forward Loop
									;  			  2 = Ping-Pong Loop, 3 r‚serv‚
									; 			  bit 2 --> 0 = 8 bits,  1 = 16 bits
									; 			  bit 3 --> 0 = Mono,    1 = Stereo

Sample_Fine_Tune			=	65		;rs.b	1	; de 0 … 15  =  0 … 7 et -8 … -1

									;rs.b	1	; Inutilis‚
Sample_Drum_Note			=	67		;rs.b	1	; Informations stock‚es
Sample_Drum_Volume			=	68		;rs.b	1	; par le Tracker
Sample_Drum_Command			=	69		;rs.b	1	; pour le mode
Sample_Drum_Parameter		=	70		;rs.w	1	; Drum Edit

Sample_Midi_Note			=	72		;rs.l	1	; Note au format MIDI
Sample_Reserved			=	76		;rs.l	1	; 4 octets R‚serv‚s

Sample_Size				=	80		
;***********************************************************************************************
Voice_Sample_Start			=	0		;rs.l		1
Voice_Sample_Position		=	4		;rs.l		1
Voice_Sample_Loop_End		=	8		;rs.l		1
Voice_Sample_End			=	12		;rs.l		1
Voice_Sample_Offset			=	16		;rs.l		1
Voice_Sample_Length			=	20		;rs.l		1
Voice_Sample_Loop_Length		=	24		;rs.l		1
Voice_Sample_End_Length		=	28		;rs.l		1
Voice_Sample_Base			=	32		;rs.l		1
Voice_Sample_Period			=	36		;rs.l		1
Voice_Sample_Fraction		=	40		;rs.l		1
Voice_Start				=	44		;rs.l		1
Voice_Length				=	48		;rs.l		1
Voice_Loop_Length			=	52		;rs.l		1
Voice_End_Length			=	56		;rs.l		1
Voice_Base				=	60		;rs.l		1
Voice_Period				=	64		;rs.l		1
Voice_Tone_Port_Period		=	68		;rs.l		1
Voice_Tone_Port_Speed		=	72		;rs.l		1

Voice_Sample_Volume			=	76		;rs.w		1
Voice_Sample_Fine_Tune		=	80		;rs.w		1
Voice_Volume				=	84		;rs.w		1
Voice_Vibrato_Depth			=	88		;rs.w		1
Voice_Total_Volume_Left		=	92		;rs.w		1
Voice_Total_Volume_Right		=	96		;rs.w		1
Voice_Tremolo_Depth			=	100		;rs.w		1

Voice_Sample_Attributes		=	104		;rs.b		1
Voice_Attributes			=	108		;rs.b		1

Voice_Note				=	0		;rs.b		1		; +112
Voice_Sample				=	4		;rs.b		1
Voice_Vol_Command			=	8		;rs.b		1
Voice_Command				=	12		;rs.b		1
Voice_Parameter1			=	16		;rs.b		1
Voice_Parameter2			=	20		;rs.b		1

Voice_Tone_Port_Direction	=	24		;rs.b		1
Voice_Glissando_Control		=	28		;rs.b		1
Voice_Vibrato_Waveform		=	32		;rs.b		1
Voice_Vibrato_Speed			=	36		;rs.b		1
Voice_Vibrato_Position		=	40		;rs.b		1
Voice_Tremolo_Waveform		=	44		;rs.b		1
Voice_Tremolo_Speed			=	48		;rs.b		1
Voice_Tremolo_Position		=	52		;rs.b		1

Voice_Left_Volume			=	56		;rs.b		1
Voice_Right_Volume			=	60		;rs.b		1

Voice_Adr_In_Track			=	64		;rs.l		1
Voice_Nb_Empty_Line			=	68		;rs.w		1
Voice_Len_Track			=	72		;rs.w		1
Voice_Packed_Bits			=	76		;rs.w		1

Voice_Size				=	192		;rs.b		0
;***********************************************************************************************
		TEXT
		.68000
			
		move.l	#INITSTACK,a7			; Stack location = end of ram-4
		
		move.l	#$70007,D_END
		moveq	#0,d0
		move.l	d0,R_I2S
		move.l	d0,L_I2S
		move.w	#$100,JOYSTICK
		move.l	d0,D_CTRL
		move.l	d0,D_FLAGS
		move.l	#SERIAL_CLOCK_FREQUENCY,SCLK
		move.l	#$15,SMODE
		move.w	d0,JPIT2
		move.w	d0,JPIT1
		;move.w	#2000-1,JPIT1
		;move.w	#DIV_TEMPO,JPIT2
		lea		dspcode_start,a0				; address of GPU code in RAM
		lea		D_RAM,a1			
		move.l	#(dspcode_end-dspcode_start)-1,d0
		jsr		gpuload

		move.l	#Module,DSP_New_Module_Adr
		move.l	#INIT,D_PC					; address of GPU code 
		move.l  	#DSPGO,D_CTRL					; Start GPU
		bra		*
;***********************************************************************************************
		move.l	#8363,d3
		move.l	#256*1700,d4

		lea		MGTK_Voices,a6
		moveq.l	#5-1,d7

MGTK_Clear_A_Voice:
		move.l 	#0,(a6)+
		move.l 	#0,(a6)+
		move.l 	#0,(a6)+
		move.l 	#0,(a6)+
		move.l 	#0,(a6)+
		move.l 	#0,(a6)+
		move.l	d3,(a6)+	; Voice_Sample_Base
		move.w 	#0,(a6)+
		move.l	d4,(a6)+  ; Voice_Sample_Period
		move.w 	#0,(a6)+
		move.w 	#0,(a6)+
		addq.l	#2,a6	; Left_Volume

		move.l 	#0,(a6)+
		move.l 	#0,(a6)+
		move.l 	#0,(a6)+
		move.l 	#0,(a6)+
		move.l	d3,(a6)+	; Voice_Base
		move.w 	#0,(a6)+
		move.l	d4,(a6)+	; Voice_Period
		move.w 	#0,(a6)+

		move.w 	#0,(a6)+
		move.l 	#0,(a6)+

		move.l 	#0,(a6)+
		move.l 	#0,(a6)+
		move.l 	#0,(a6)+
		move.l 	#0,(a6)+
		move.l 	#0,(a6)+
		dbra		d7,MGTK_Clear_A_Voice
		rts

;***********************************************************************************************
;***********				Gestion Patterns
;***********************************************************************************************

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

MGTK_Vol_Change:
		move.b	Voice_Vol_Command(a6),d0
		sub.b	#$10,d0
		lsl.w	#4,d0
		move.w	d0,Voice_Volume(a6)
		move.w	d0,Voice_Sample_Volume(a6)
		move.b	#0,Voice_Vol_Command(a6)
		rts

MGTK_Vol_Maxi:
		move.w	#$400,Voice_Volume(a6)
		move.w	#$400,Voice_Sample_Volume(a6)
		move.b	#0,Voice_Vol_Command(a6)
		rts

MGTK_Vol_Slide_Down:
		sub.w	d0,Voice_Volume(a6)
		bpl.s	MGTK_Vol_Slide_Down_Ok

		move.w	#0,Voice_Volume(a6)
		move.b	#0,Voice_Vol_Command(a6)

MGTK_Vol_Slide_Down_Ok:
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		rts

MGTK_Vol_Slide_Up:
		add.w	d0,Voice_Volume(a6)
		cmp.w	#$400,Voice_Volume(a6)
		ble.s	MGTK_Vol_Slide_Up_Ok

		move.w	#$400,Voice_Volume(a6)
		move.b	#0,Voice_Vol_Command(a6)

MGTK_Vol_Slide_Up_Ok:
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		rts


MGTK_Vol_Fine_Slide_Down:
		sub.w	d0,Voice_Volume(a6)
		bpl.s	MGTK_Vol_Fine_Slide_Down_Ok
		move.w	#0,Voice_Volume(a6)

MGTK_Vol_Fine_Slide_Down_Ok:
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		rts

MGTK_Vol_Fine_Slide_Up:
		add.w	d0,Voice_Volume(a6)
		cmp.w	#$400,Voice_Volume(a6)
		ble.s	MGTK_Vol_Fine_Slide_Up_Ok
		move.w	#$400,Voice_Volume(a6)

MGTK_Vol_Fine_Slide_Up_Ok:
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		rts


MGTK_Vol_Set_Vibrato_Speed:
		move.b	d0,Voice_Vibrato_Speed(a6)
		move.b	#0,Voice_Vol_Command(a6)
		rts

MGTK_Vol_Vibrato:
		lsl.w	#8,d0
		move.w	d0,Voice_Vibrato_Depth(a6)
		bra		MGTK_Vibrato_2


MGTK_Vol_Set_Panoramic:
		lea		MGTK_Panoramics_Table,a0
		add.w	d0,d0
		add.w	d0,a0
		move.w	(a0),Voice_Left_Volume(a6)
		move.b	#0,Voice_Vol_Command(a6)
		rts


MGTK_Vol_Pan_Slide_Left:
		move.b	Voice_Left_Volume(a6),d1
		add.w	d0,d1
		cmp.w	#$ff,d1
		ble.s	MGTK_Vol_Pan_Slide_Left_1
		move.w	#$ff,d1
MGTK_Vol_Pan_Slide_Left_1:
		move.b	d1,Voice_Left_Volume(a6)

		move.b	Voice_Right_Volume(a6),d1
		sub.w	d0,d1
		bpl.s	MGTK_Vol_Pan_Slide_Left_2
		moveq.l	#0,d1
MGTK_Vol_Pan_Slide_Left_2:
		move.b	d1,Voice_Right_Volume(a6)
		rts

MGTK_Vol_Pan_Slide_Right:
		move.b	Voice_Left_Volume(a6),d1
		sub.w	d0,d1
		bpl.s	MGTK_Vol_Pan_Slide_Right_1
		moveq.l	#0,d1
MGTK_Vol_Pan_Slide_Right_1:
		move.b	d1,Voice_Left_Volume(a6)

		move.b	Voice_Right_Volume(a6),d1
		add.w	d0,d1
		cmp.w	#$ff,d1
		ble.s	MGTK_Vol_Pan_Slide_Right_2
		moveq.l	#-1,d1
MGTK_Vol_Pan_Slide_Right_2:
		move.b	d1,Voice_Right_Volume(a6)
		rts


MGTK_Vol_Set_Tone_Portamento:
		lsl.w	#8,d0
		move.l	d0,Voice_Tone_Port_Speed(a6)

		moveq.l	#0,d0
		move.b	Voice_Note(a6),d0
		beq.s	MGTK_Vol_Set_Tone_Portamento_Ret
		sub.w	#12,d0
		lea.l	MGTK_Periods_Table,a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		lsl.w	#2,d0
		move.l	(a0,d0.w),d0

		move.l	d0,Voice_Tone_Port_Period(a6)
		move.l	Voice_Period(a6),d1
		sf		Voice_Tone_Port_Direction(a6)
		cmp.l	d1,d0
		beq.s	MGTK_Vol_Clear_Tone_Portamento
		bge.s	MGTK_Vol_Set_Tone_Portamento_Ret
		st		Voice_Tone_Port_Direction(a6)

MGTK_Vol_Set_Tone_Portamento_Ret:
		rts

MGTK_Vol_Clear_Tone_Portamento:
		move.l	#0,Voice_Tone_Port_Period(a6)
		rts




MGTK_Find_Period:
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

MGTK_Do_Find_Period:
		moveq.l	#12-1,d3
MGTK_Find_Period_Loop:
		cmp.l	(a0)+,d0
		dbhs		d3,MGTK_Find_Period_Loop
		blo.s	MGTK_Period_Found
		subq.l	#4,a0
MGTK_Period_Found:
		rts

MGTK_Period_Nop:
		move.b	Voice_Vol_Command(a6),d0
		lsr.b	#4,d0
		cmp.b	#$b,d0		; Vibrato
		beq.s	MGTK_Return
		cmp.b	#$f,d0		; Tone Portamento
		beq.s	MGTK_Return

		move.l	Voice_Period(a6),Voice_Sample_Period(a6)
MGTK_Return:
		rts


MGTK_Arpeggio:
		move.w	Voice_Parameter1(a6),d1
		beq.s	MGTK_Period_Nop

MGTK_Arpeggio_0:
		moveq.l	#0,d0
		move.b	MGTK_Music_Counter,d0

		tst.b	d1
		beq.s	MGTK_Normal_Arpeggio

		add.w	#MGTK_Arpeggio_Table_5-MGTK_Arpeggio_Table_3,d0

MGTK_Normal_Arpeggio:
		move.b	MGTK_Arpeggio_Table_3(pc,d0.w),d0
		beq.s	MGTK_Period_Nop
		subq.b	#2,d0
		beq.s	MGTK_Arpeggio_2
		subq.b	#1,d0
		beq.s	MGTK_Arpeggio_3
		subq.b	#1,d0
		beq.s	MGTK_Arpeggio_4

MGTK_Arpeggio_1:
		lsr.w	#4,d1
MGTK_Arpeggio_2:
		lsr.w	#4,d1
MGTK_Arpeggio_3:
		lsr.w	#4,d1
MGTK_Arpeggio_4:
		and.w	#$f,d1

		lea.l	MGTK_Periods_Table,a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.l	Voice_Period(a6),d0
		bsr		MGTK_Find_Period
		lsl.w	#2,d1
		move.l	(a0,d1.w),Voice_Sample_Period(a6)
		rts

MGTK_Arpeggio_Table_3:
		Rept		(256+3-1)/3
		dc.b		0,1,2
		EndR

MGTK_Arpeggio_Table_5:
		Rept		(256+5-1)/5
		dc.b		0,1,2,3,4
		EndR


MGTK_Portamento_Up:
		moveq.l	#0,d0
		move.w	Voice_Parameter1(a6),d0
		sub.l	d0,Voice_Period(a6)
		move.l	Voice_Period(a6),d0
		cmp.l	#$1af1,d0
		bhi.s	MGTK_Portamento_Up_Ok
		move.l	#$1af1,Voice_Period(a6)

MGTK_Portamento_Up_Ok:
		move.l	Voice_Period(a6),Voice_Sample_Period(a6)
		rts

 
MGTK_Portamento_Down:
		moveq.l	#0,d0
		move.w	Voice_Parameter1(a6),d0
		add.l	d0,Voice_Period(a6)
		move.l	Voice_Period(a6),d0
		cmp.l	#$1c5734,d0
		blo.s	MGTK_Portamento_Down_Ok
		move.l	#$1c5734,Voice_Period(a6)

MGTK_Portamento_Down_Ok:
		move.l	Voice_Period(a6),Voice_Sample_Period(a6)
		rts


MGTK_Set_Tone_Portamento:
		moveq.l	#0,d0
		move.b	Voice_Note(a6),d0
		beq.s	MGTK_Set_Tone_Portamento_Ret
		sub.w	#12,d0
		lea.l	MGTK_Periods_Table,a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		lsl.w	#2,d0
		move.l	(a0,d0.w),d0

		move.l	d0,Voice_Tone_Port_Period(a6)
		move.l	Voice_Period(a6),d1
		sf		Voice_Tone_Port_Direction(a6)
		cmp.l	d1,d0
		beq.s	MGTK_Clear_Tone_Portamento
		bge.s	MGTK_Set_Tone_Portamento_Ret
		st		Voice_Tone_Port_Direction(a6)

MGTK_Set_Tone_Portamento_Ret:
		addq.l	#4,sp
		rts

MGTK_Clear_Tone_Portamento:
		move.l	#0,Voice_Tone_Port_Period(a6)
		addq.l	#4,sp
		rts

MGTK_Tone_Portamento:
		moveq.l	#0,d0
		move.w	Voice_Parameter1(a6),d0
		beq.s	MGTK_Tone_Portamento_No_Change
		move.l	d0,Voice_Tone_Port_Speed(a6)
		move.w	 #0,Voice_Parameter1(a6)

MGTK_Tone_Portamento_No_Change:
		tst.l	Voice_Tone_Port_Period(a6)
		beq		MGTK_Period_Nop
		move.l	Voice_Tone_Port_Speed(a6),d0
		tst.b	Voice_Tone_Port_Direction(a6)
		bne.s	MGTK_Tone_Portamento_Up

MGTK_Tone_Portamento_Down:
		add.l	d0,Voice_Period(a6)
		move.l	Voice_Tone_Port_Period(a6),d0
		cmp.l	Voice_Period(a6),d0
		bgt.s	MGTK_Tone_Portamento_Set_Period
		move.l	Voice_Tone_Port_Period(a6),Voice_Period(a6)
		move.l	#0,Voice_Tone_Port_Period(a6)
		bra.s	MGTK_Tone_Portamento_Set_Period

MGTK_Tone_Portamento_Up:
		sub.l	d0,Voice_Period(a6)
		move.l	Voice_Tone_Port_Period(a6),d0
		cmp.l	Voice_Period(a6),d0
		blt.s	MGTK_Tone_Portamento_Set_Period
		move.l	Voice_Tone_Port_Period(a6),Voice_Period(a6)
		move.l	#0,Voice_Tone_Port_Period(a6)


MGTK_Tone_Portamento_Set_Period:
		move.l	Voice_Period(a6),d0
		tst.b	Voice_Glissando_Control(a6)
		beq.s	MGTK_Glissando_Skip

		lea.l	MGTK_Periods_Table,a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		bsr		MGTK_Find_Period
		move.l	(a0),d0

MGTK_Glissando_Skip:
		move.l	d0,Voice_Sample_Period(a6)
		rts


MGTK_Vibrato:
		move.b	Voice_Parameter1(a6),d0
		lsr.b	#4,d0
		beq.s	MGTK_Vibrato_1
		move.b	d0,Voice_Vibrato_Speed(a6)
MGTK_Vibrato_1:
		move.w	Voice_Parameter1(a6),d0
		and.w	#$0fff,d0
		beq.s	MGTK_Vibrato_2
		move.w	d0,Voice_Vibrato_Depth(a6)
MGTK_Vibrato_2:

		lea.l	MGTK_Sinus_Table,a3
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

MGTK_Vibrato_Ramp_Down:
		tst.b	Voice_Vibrato_Position(a6)
		bpl.s	MGTK_Vibrato_Ramp_Down_2
		move.b	#255,d2
		sub.b	d0,d2
		bra.s	MGTK_Vibrato_Set
MGTK_Vibrato_Ramp_Down_2:
		move.b	d0,d2
		bra.s	MGTK_Vibrato_Set

MGTK_Vibrato_Sinus:
		move.b	(a3,d0.w),d2
MGTK_Vibrato_Set:
		move.w	Voice_Vibrato_Depth(a6),d0
		mulu.w	d0,d2
		lsr.l	#7,d2
		move.l	Voice_Period(a6),d0
		tst.b	Voice_Vibrato_Position(a6)
		bmi.s	MGTK_Vibrato_Neg
		add.l	d2,d0
		bra.s	MGTK_Vibrato_3
MGTK_Vibrato_Neg:
		sub.l	d2,d0
MGTK_Vibrato_3:
		move.l	d0,Voice_Sample_Period(a6)

		move.b	Voice_Vibrato_Speed(a6),d0
		lsl.b	#2,d0
		add.b	d0,Voice_Vibrato_Position(a6)
		rts


MGTK_Tone_Portamento_Plus_Volume_Slide:
		bsr		MGTK_Tone_Portamento_No_Change
		bra		MGTK_Volume_Slide


MGTK_Vibrato_Plus_Volume_Slide:
		bsr.s	MGTK_Vibrato_2
		bra		MGTK_Volume_Slide


MGTK_Tremolo:
		move.b	Voice_Parameter1(a6),d0
		lsr.b	#4,d0
		beq.s	MGTK_Tremolo_1
		move.b	d0,Voice_Tremolo_Speed(a6)
MGTK_Tremolo_1:
		move.w	Voice_Parameter1(a6),d0
		and.w	#$0fff,d0
		beq.s	MGTK_Tremolo_2
		move.w	d0,Voice_Tremolo_Depth(a6)
MGTK_Tremolo_2:

		lea.l	MGTK_Sinus_Table,a3
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

MGTK_Tremolo_Ramp_Down:
		tst.b	Voice_Tremolo_Position(a6)
		bpl.s	MGTK_Tremolo_Ramp_Down_2
		move.b	#255,d2
		sub.b	d0,d2
		bra.s	MGTK_Tremolo_Set
MGTK_Tremolo_Ramp_Down_2:
		move.b	d0,d2
		bra.s	MGTK_Tremolo_Set

MGTK_Tremolo_Sinus:
		move.b	(a3,d0.w),d2
MGTK_Tremolo_Set:
		move.w	Voice_Tremolo_Depth(a6),d0
		mulu.w	d0,d2
		lsr.l	#6,d2
		move.w	Voice_Volume(a6),d0
		tst.b	Voice_Tremolo_Position(a6)
		bmi.s	MGTK_Tremolo_Neg
		add.w	d2,d0
		bra.s	MGTK_Tremolo_3
MGTK_Tremolo_Neg:
		sub.w	d2,d0
MGTK_Tremolo_3:
		bmi.s	MGTK_Tremolo_Nul
		cmp.w	#$400,d0
		ble.s	MGTK_Tremolo_Ok
		move.w	#$400,d0
		bra.s	MGTK_Tremolo_Ok
MGTK_Tremolo_Nul:
		moveq.l	#0,d0
MGTK_Tremolo_Ok:
		move.w	d0,Voice_Sample_Volume(a6)

		move.b	Voice_Tremolo_Speed(a6),d0
		lsl.b	#2,d0
		add.b	d0,Voice_Tremolo_Position(a6)
		bra		MGTK_Period_Nop


MGTK_Panning:
		move.b	Voice_Parameter1(a6),d0
		move.b	d0,Voice_Right_Volume(a6)
		moveq.l	#-1,d1
		sub.b	d0,d1
		move.b	d1,Voice_Left_Volume(a6)
		rts


MGTK_Sample_Offset:
		move.l	Voice_Sample_Offset(a6),d0
		moveq.l	#0,d1
		move.w	Voice_Parameter1(a6),d1
		beq.s	MGTK_Sample_Offset_No_New

		lsl.l	#4,d1
		move.l	d1,d0
MGTK_Sample_Offset_No_New:

		add.l	Voice_Sample_Offset(a6),d0
		cmp.l	Voice_Sample_Length(a6),d0
		ble.s	MGTK_Sample_Offset_Ok
		move.l	Voice_Sample_Length(a6),d0
MGTK_Sample_Offset_Ok:
		move.l	Voice_Start(a6),Voice_Sample_Start(a6)
		move.l	d0,Voice_Sample_Offset(a6)
		move.l	d0,Voice_Sample_Position(a6)
		rts


MGTK_Volume_Slide:
		moveq.l	#0,d0
		move.b	Voice_Parameter1(a6),d0
		beq.s	MGTK_Volume_Slide_Down

MGTK_Volume_Slide_Up:
		add.w	d0,Voice_Volume(a6)
		cmp.w	#$400,Voice_Volume(a6)
		ble.s	MGTK_Volume_Slide_Up_Ok
		move.w	#$400,Voice_Volume(a6)

MGTK_Volume_Slide_Up_Ok:
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		rts


MGTK_Volume_Slide_Down:
		move.b	Voice_Parameter2(a6),d0
		sub.w	d0,Voice_Volume(a6)
		bpl.s	MGTK_Volume_Slide_Down_Ok
		move.w	#0,Voice_Volume(a6)

MGTK_Volume_Slide_Down_Ok:
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		rts


MGTK_Position_Jump:
*		tst.b	Skip_Position_Jump
*		beq.s	MGTK_Position_Jump_Not_Skipped
*		rts
*
MGTK_Position_Jump_Not_Skipped:
		move.w	Voice_Parameter1(a6),d0

		cmp.w	MGTK_Music_Length,d0
		blo.s	MGTK_Position_Jump_Ok
		moveq.l	#0,d0
	
MGTK_Position_Jump_Ok:
		move.w	d0,MGTK_Position_Jump_Position
		st		MGTK_Position_Jump_Flag
		rts


MGTK_Volume_Change:
		move.w	Voice_Parameter1(a6),d0
		cmp.w	#$400,d0
		ble.s	MGTK_Volume_Change_Ok
		move.w	#$400,d0

MGTK_Volume_Change_Ok:
		move.w	d0,Voice_Volume(a6)
		move.w	d0,Voice_Sample_Volume(a6)
		rts


MGTK_Pattern_Break:
		move.w	Voice_Parameter1(a6),d0

		cmp.w	MGTK_Pattern_Length,d0
		blo.s	MGTK_Pattern_Break_Ok
		moveq.l	#0,d0
	
MGTK_Pattern_Break_Ok:
		move.w	d0,MGTK_Pattern_Break_Position
		st		MGTK_Pattern_Break_Flag
		rts


MGTK_Set_Speed_Tempo:
		move.b	Voice_Parameter1(a6),d0
		beq.s	MGTK_No_Speed
		move.b	d0,MGTK_Music_Speed

MGTK_No_Speed:
*		tst.b	Skip_Tempos
*		beq.s	MGTK_Tempos_Not_Skipped
*		rts
*
MGTK_Tempos_Not_Skipped:
		moveq.l	#0,d0
		move.b	Voice_Parameter2(a6),d0
		bne.s	MGTK_Tempo_Ok
		rts

MGTK_Tempo_Ok:
		move.b	d0,MGTK_Music_Tempo




MGTK_Set_Glissando_Control:
		move.b	Voice_Parameter1(a6),Voice_Glissando_Control(a6)
		rts


MGTK_Set_Vibrato_Waveform:
		move.b	Voice_Parameter1(a6),Voice_Vibrato_Waveform(a6)
		rts


MGTK_Set_Fine_Tune:
		move.b	Voice_Parameter1(a6),d0
		and.w	#$0f,d0
		mulu.w	#12*8*4,d0
		move.w	d0,Voice_Sample_Fine_Tune(a6)
		rts


MGTK_Pattern_Loop:
		move.w	Voice_Parameter1(a6),d0
		beq.s	MGTK_Set_Loop_Position

		tst.w	MGTK_Pattern_Loop_Counter
		beq.s	MGTK_Set_Loop_Counter

		subq.w	#1,MGTK_Pattern_Loop_Counter
		beq		MGTK_Return

MGTK_Do_Loop:
		st		MGTK_Pattern_Loop_Flag
		rts
MGTK_Set_Loop_Counter:
		move.w	d0,MGTK_Pattern_Loop_Counter
		bra.s	MGTK_Do_Loop
MGTK_Set_Loop_Position:
		move.w	MGTK_Pattern_Position,MGTK_Pattern_Loop_Position
		rts


MGTK_Set_Tremolo_Waveform:
		move.b	Voice_Parameter1(a6),Voice_Tremolo_Waveform(a6)
		rts


MGTK_Set_Panoramic:
		move.b	Voice_Parameter1(a6),d0
		and.w	#$0f,d0
		lea		MGTK_Panoramics_Table,a0
		add.w	d0,d0
		add.w	d0,a0
		move.w	(a0),Voice_Left_Volume(a6)
		rts


MGTK_Note_Retrig_Plus_Volume_Slide:
		moveq.l	#0,d0
		move.b	Voice_Parameter1(a6),d0
		beq.s	MGTK_No_Note_Retrig_Plus_Volume_Slide

		moveq.l	#0,d1
		move.b	MGTK_Music_Counter,d1
		bne.s	MGTK_Note_Retrig_Plus_Volume_Slide_Skip

		tst.b	Voice_Note(a6)
		bne.s	MGTK_No_Note_Retrig_Plus_Volume_Slide

MGTK_Note_Retrig_Plus_Volume_Slide_Skip:
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
		;jsr		([MGTK_NRPVS_Table,pc,d1.w*4])
		lea		MGTK_NRPVS_Table,a0
		lsl.w	#4,d0
		add.w	d0,a0
		move.l	(a0),a0
		jsr		(a0)
		
MGTK_No_Note_Retrig_Plus_Volume_Slide:
		rts

MGTK_NRPVS_M100:
		sub.w	#$80,d0
MGTK_NRPVS_M80:
		sub.w	#$40,d0
MGTK_NRPVS_M40:
		sub.w	#$20,d0
MGTK_NRPVS_M20:
		sub.w	#$10,d0
MGTK_NRPVS_M10:
		sub.w	#$10,d0
		bpl.s	MGTK_NRPVS_Ok
		move.w	#0,Voice_Volume(a6)
		move.w	#0,Voice_Sample_Volume(a6)
		rts

MGTK_NRPVS_2_3:
		add.w	d0,d0
		divu.w	#3,d0
		bra.s	MGTK_NRPVS_Ok

MGTK_NRPVS_1_2:
		lsr.w	d0
		bra.s	MGTK_NRPVS_Ok

MGTK_NRPVS_P100:
		add.w	#$80,d0
MGTK_NRPVS_P80:
		add.w	#$40,d0
MGTK_NRPVS_P40:
		add.w	#$20,d0
MGTK_NRPVS_P20:
		add.w	#$10,d0
MGTK_NRPVS_P10:
		add.w	#$10,d0
		add.w	#$100,d0
		cmp.w	#$400,d0
		ble.s	MGTK_NRPVS_Ok
		move.w	#$400,d0
MGTK_NRPVS_Ok:
		move.w	d0,Voice_Volume(a6)
		move.w	d0,Voice_Sample_Volume(a6)
		rts

MGTK_NRPVS_3_2:
		move.w	d0,d1
		lsr.w	d1
		add.w	d1,d0
		bra.s	MGTK_NRPVS_Ok

MGTK_NRPVS_2:
		add.w	d0,d0
		bra.s	MGTK_NRPVS_Ok

MGTK_NRPVS_Table:
		dc.l		MGTK_Return,MGTK_NRPVS_M10,MGTK_NRPVS_M20,MGTK_NRPVS_M40
		dc.l		MGTK_NRPVS_M80,MGTK_NRPVS_M100,MGTK_NRPVS_2_3,MGTK_NRPVS_1_2
		dc.l		MGTK_Return,MGTK_NRPVS_P10,MGTK_NRPVS_P20,MGTK_NRPVS_P40
		dc.l		MGTK_NRPVS_P80,MGTK_NRPVS_P100,MGTK_NRPVS_3_2,MGTK_NRPVS_2



MGTK_Fine_Volume_Slide_Up:
		move.w	Voice_Parameter1(a6),d0
		add.w	d0,Voice_Volume(a6)
		cmp.w	#$400,Voice_Volume(a6)
		ble.s	MGTK_Fine_Volume_Slide_Up_Ok
		move.w	#$400,Voice_Volume(a6)

MGTK_Fine_Volume_Slide_Up_Ok:
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		bra		MGTK_Period_Nop


MGTK_Fine_Volume_Slide_Down:
		move.w	Voice_Parameter1(a6),d0
		sub.w	d0,Voice_Volume(a6)
		bpl.s	MGTK_Fine_Volume_Slide_Down_Ok
		move.w	#0,Voice_Volume(a6)

MGTK_Fine_Volume_Slide_Down_Ok:
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		bra		MGTK_Period_Nop


MGTK_Note_Cut:
		move.b	Voice_Parameter1(a6),d0
		cmp.b	MGTK_Music_Counter,d0
		bne		MGTK_Period_Nop

		move.w	#0,Voice_Volume(a6)
		move.w	#0,Voice_Sample_Volume(a6)
		rts


MGTK_Note_Delay:
		move.b	Voice_Parameter1(a6),d0
		cmp.b	MGTK_Music_Counter,d0
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


MGTK_Pattern_Delay:
		tst.b	MGTK_Pattern_Delay_Time
		bne		MGTK_Return

		move.b	Voice_Parameter1(a6),MGTK_Pattern_Delay_Time
		rts


MGTK_Arpeggio3:
		move.b	Voice_Parameter1(a6),d1
		beq		MGTK_Period_Nop

		moveq.l	#0,d0
		move.b	MGTK_Music_Counter,d0

		move.b	MGTK_Arpeggio3_Table(pc,d0.w),d0
		beq		MGTK_Period_Nop
		bpl.s	MGTK_Arpeggio3_Plus

		lsr.b	#4,d1
		neg.b	d1
		ext.w	d1
MGTK_Arpeggio3_Plus:
		and.w	#$0f,d1

		lea.l	MGTK_Periods_Table,a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.l	Voice_Period(a6),d0
		bsr		MGTK_Find_Period
		lsl.w	#2,d1
		move.l	(a0,d1.w),Voice_Sample_Period(a6)
		rts

MGTK_Arpeggio3_Table:
		Rept		(256+3-1)/3
		dc.b		-1,0,1
		EndR


MGTK_Arpeggio4:
		move.b	Voice_Parameter1(a6),d1
		beq		MGTK_Period_Nop

		moveq.l	#0,d0
		move.b	MGTK_Music_Counter,d0

		move.b	MGTK_Arpeggio4_Table(pc,d0.w),d0
		beq		MGTK_Period_Nop
		bpl.s	MGTK_Arpeggio4_Plus

		lsr.b	#4,d1
		neg.b	d1
		ext.w	d1
MGTK_Arpeggio4_Plus:
		and.w	#$0f,d1

		lea.l	MGTK_Periods_Table,a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.l	Voice_Period(a6),d0
		bsr		MGTK_Find_Period
		lsl.w	#2,d1
		move.l	(a0,d1.w),Voice_Sample_Period(a6)
		rts

MGTK_Arpeggio4_Table:
		Rept		256/4
		dc.b		0,1,0,-1
		EndR


MGTK_Arpeggio5:
		move.b	Voice_Parameter1(a6),d1
		beq		MGTK_Period_Nop

		moveq.l	#0,d0
		move.b	MGTK_Music_Counter,d0

		move.b	MGTK_Arpeggio5_Table(pc,d0.w),d0
		beq		MGTK_Period_Nop

		and.w	#$0f,d1

		lea.l	MGTK_Periods_Table,a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.l	Voice_Period(a6),d0
		bsr		MGTK_Find_Period
		lsl.w	#2,d1
		move.l	(a0,d1.w),Voice_Sample_Period(a6)
		rts

MGTK_Arpeggio5_Table:
		Rept		(256+3-1)/3
		dc.b		1,1,0
		EndR


MGTK_Note_Slide:
		moveq.l	#0,d1
		move.b	Voice_Parameter1(a6),d1
		bne.s	MGTK_Note_Slide_Up

MGTK_Note_Slide_Down:
		sub.b	Voice_Parameter2(a6),d1

MGTK_Note_Slide_Up:
		lea.l	MGTK_Periods_Table,a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.l	Voice_Period(a6),d0
		bsr		MGTK_Find_Period
		lsl.w	#2,d1
		move.l	(a0,d1.w),Voice_Period(a6)
		move.l	(a0,d1.w),Voice_Sample_Period(a6)
		rts


MGTK_Tremor:
		moveq.l	#0,d0
		move.b	Voice_Parameter1(a6),d0
		add.b	Voice_Parameter2(a6),d0
		beq		MGTK_Return
		moveq.l	#0,d1
		move.b	MGTK_Music_Counter,d1
		divu.w	d0,d1
		swap.w	d1
		cmp.b	Voice_Parameter1(a6),d1
		bhi.s	MGTK_Tremor_Off

MGTK_Tremor_On:
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		rts

MGTK_Tremor_Off:
		move.w 	#0,Voice_Sample_Volume(a6)
		rts


MGTK_Set_Master_Volume:
		move.b	Voice_Parameter1(a6),MGTK_Master_Volume_Left
		move.b	Voice_Parameter2(a6),MGTK_Master_Volume_Right
		rts


MGTK_Set_Global_Volume:
		move.w	Voice_Parameter1(a6),MGTK_Global_Volume
		rts


MGTK_Global_Volume_Slide:
		move.w	MGTK_Global_Volume,d1
		moveq.l	#0,d0
		move.b	Voice_Parameter1(a6),d0
		beq.s	MGTK_Global_Volume_Slide_Down

MGTK_Global_Volume_Slide_Up:
		add.w	d0,d1
		cmp.w	#$400,d1
		ble.s	MGTK_Global_Volume_Slide_Ok

		move.w	#$400,MGTK_Global_Volume
		rts

MGTK_Global_Volume_Slide_Down:
		move.b	Voice_Parameter2(a6),d0
		sub.w	d0,d1
		bpl.s	MGTK_Global_Volume_Slide_Ok
		moveq.l	#0,d1
MGTK_Global_Volume_Slide_Ok:
		move.w	d1,MGTK_Global_Volume
		rts


MGTK_Set_Base:
		moveq.l	#0,d0
		move.w	Voice_Parameter1(a6),d0
		cmp.w	#50066,d0
		ble.s	MGTK_Set_Base_1
		move.l	#50066,Voice_Sample_Base(a6)
		rts
MGTK_Set_Base_1:
		cmp.w	#1000,d0
		bhi.s	MGTK_Set_Base_2
		move.w	#1000,d0
MGTK_Set_Base_2:
		move.l	d0,Voice_Sample_Base(a6)
		rts


MGTK_Set_Stereo:
		move.w	Voice_Parameter1(a6),Voice_Left_Volume(a6)
		rts


MGTK_Stereo_Slide:
		moveq.l	#0,d0
		move.b	Voice_Left_Volume(a6),d0
		move.b	Voice_Parameter1(a6),d1
		ext.w	d1
		add.w	d1,d0
		bpl.s	MGTK_Stereo_Slide_Left_1
		moveq.l	#0,d0
		bra.s	MGTK_Stereo_Slide_Left_2
MGTK_Stereo_Slide_Left_1:
		cmp.w	#$00ff,d0
		ble.s	MGTK_Stereo_Slide_Left_2
		moveq.l	#-1,d0
MGTK_Stereo_Slide_Left_2:
		move.b	d0,Voice_Left_Volume(a6)

		moveq.l	#0,d0
		move.b	Voice_Right_Volume(a6),d0
		move.b	Voice_Parameter2(a6),d1
		ext.w	d1
		add.w	d1,d0
		bpl.s	MGTK_Stereo_Slide_Right_1
		moveq.l	#0,d0
		bra.s	MGTK_Stereo_Slide_Right_2
MGTK_Stereo_Slide_Right_1:
		cmp.w	#$00ff,d0
		ble.s	MGTK_Stereo_Slide_Right_2
		moveq.l	#-1,d0
MGTK_Stereo_Slide_Right_2:
		move.b	d0,Voice_Left_Volume(a6)
		rts


MGTK_Release_Sample:
		and.b	#%11111100,Voice_Sample_Attributes(a6)
		rts

;***********************************************************************************************
;***********************************************************************************************
;***********************************************************************************************
		TEXT
		phrase
		
dspcode_start:
		.dsp
;-----------------------------------------------------------------------------------------------
rd0					.equr	r0
rd1					.equr	r1
rd2					.equr	r2
rd3					.equr	r3
rd4					.equr	r4
rd5					.equr	r5
rd6					.equr	r6
rd7					.equr	r7
ra0					.equr	r8
ra1					.equr	r9
ra2					.equr	r10
ra3					.equr	r11
ra4					.equr	r12
ra5					.equr	r13
ra6					.equr	r14
raa6					.equr	r15
Rts_Register			.equr	r26
;
;					il reste  r16 … r25 pour les valeurs temporaires
;-----------------------------------------------------------------------------------------------
		org		D_RAM
		movei	#INIT,r29			; INT 0    DSP START
		jump		(r29)
		nop
		nop
		nop
		nop
		
		movei	#_i2s_int,r29		; INT 1    I2S
		jump		(r29)
		nop
		nop
		nop
		nop
		
		movei	#TEMPO_INT,r29
		jump		(r29)
		nop
		
;***********************************************************************************************
;         Mettre Dans 'DSP_New_Module_Adr' l'adresse du Module
;                     'DSP_No_Music'       le numero de zik voulu
INIT:
;***********************************************************************************************

		movei	#D_FLAGS,r1
		load		(r1),r0
		movei	#REGPAGE,r2					; movei	#REGPAGE|D_I2SENA|D_TIM2ENA,r2
		or		r2,r0
		store	r0,(r1)
		nop

		movei	#D_DIVCTRL,r1
		load		(r1),r0
		bset		#0,r0
		store	r0,(r1)
		
		;movei	#428/2,r1
		;movei	#32000,r2
		;movei	#8363,r3
		;movei	#$2cf,r4
		;div		r2,r1
		;load	(r5),r6
		;shrq	#16,r1
		;mult	r3,r1
		;div		r4,r1
		;load	(r5),r1
		;shrq	#7,r1

		

		movei	#MGTK_Replay_Paused,r0
		movei	#False,r1						;  -1 = False
		movei	#MGTK_Replay_Stopped,r2			;   0 = True
		movei	#True,r3
		movei	#MGTK_Replay_Frequency,r4
		movei	#FREQ_REPLAY,r5
		store	r1,(r0)
		store	r3,(r2)
		store	r5,(r4)
		
		movei	#MGTK_Module_Adr,r0
		movei	#DSP_New_Module_Adr,r1
		load		(r0),r2
		load		(r1),r3
		movei	#Deja_Attribue,r4				; Si c'est le meme module
		cmp		r2,r3						; alors on va traiter le No Zik
		jump		eq,(r4)
		nop

		store	r3,(r0)
		move		r3,r0

		movei	#MGTK_Nb_Voices,r1
		addq		#8,r0
		
		loadw	(r0),r10						; r10 = Nb Voices
		addq		#2,r0
		store	r10,(r1)
		addq		#4,r1
		
		loadw	(r0),r10						; r10 = Nb Musics
		addq		#6,r0
		store	r10,(r1)
		addq		#4,r1
		
		loadw	(r0),r10
		addq		#2,r0
		store	r10,(r1)						; r10 = Nb Tracks
		addq		#4,r1
		
		loadw	(r0),r10
		addq		#8,r0
		store	r10,(r1)						; r10 = Nb Samples
		addq		#4,r1
		
		
		movei	#6,r7
		movei	#Loop1,r8
		
Loop1:	load		(r0),r10
		addq		#4,r0
		add		r3,r10
		store	r10,(r1)
		subq		#1,r7
		addq		#4,r1
		cmpq		#0,r7
		jump		ne,(r8)
		nop
		
Deja_Attribue:
		movei	#DSP_No_Music,r0
		load		(r0),r0
		cmpq		#0,r0
		jr		pl,MGTK_Play_Music_1
		nop
		movei	#0,r0
		
MGTK_Play_Music_1:
		movei	#MGTK_Nb_Musics,r1
		load		(r1),r1
		subq		#1,r1
		cmp		r1,r0
		jr		hi,MGTK_Play_Music_2
		move		r1,r0
		
MGTK_Play_Music_2:
		movei	#MGTK_Nb_Voices,r1
		movei	#46,r2
		movei	#32,r3
		load		(r1),r1
		add		r1,r1
		add		r2,r1
		mult		r1,r0
		movei	#MGTK_Musics_Adr,r10
		load		(r10),r10
		add		r3,r10
		add		r0,r10

		movei	#MGTK_Module_Adr,r0
		load		(r10),r11
		load		(r0),r0
		movei	#MGTK_Sequence_Adr,r20
		add		r0,r11
		addq		#4,r10
		store	r11,(r20)
		
		movei	#MGTK_Music_Length,r20
		loadw	(r10),r11
		addq		#2,r10
		store	r11,(r20)
		
		movei	#MGTK_Music_Restart,r20
		loadw	(r10),r11
		addq		#2,r10
		store	r11,(r20)
		
		loadb	(r10),r0
		addq		#1,r10
		loadb	(r10),r1
		addq		#1,r10
		
		movei	#MGTK_Global_Volume,r20
		loadw	(r10),r11
		addq		#2,r10
		store	r11,(r20)

		movei	#MGTK_Master_Volume_Left,r20
		loadb	(r10),r11
		addq		#1,r10
		store	r11,(r20)
		
		movei	#MGTK_Master_Volume_Right,r20
		loadb	(r10),r11
		addq		#1,r10
		store	r11,(r20)
		
		movei	#MGTK_Initial_Tempo,r20
		movei	#MGTK_Music_Tempo,r21
		movei	#MGTK_Initial_Speed,r22
		movei	#MGTK_Music_Speed,r23
		movei	#MGTK_Music_Counter,r24
		store	r0,(r20)
		store	r0,(r21)
		store	r1,(r22)
		store	r1,(r23)
		store	r1,(r24)		


		jr		*
		nop

		movei	#MGTK_Tempo_Rts,r24
		movei	#MGTK_Retour_Variable,r23
		movei	#MGTK_Search_Values_for_Tempo,r25
		store	r24,(r23)
		jump		(r25)
		nop

MGTK_Tempo_Rts:
		movei	#MGTK_Music_Position,r0
		movei	#MGTK_Pattern_Position,r1
		movei	#MGTK_Pattern_Loop_Flag,r2
		movei	#MGTK_Pattern_Loop_Counter,r3
		movei	#MGTK_Pattern_Loop_Position,r4
		movei	#MGTK_Pattern_Break_Flag,r5
		movei	#MGTK_Pattern_Break_Position,r6
		movei	#MGTK_Position_Jump_Flag,r7
		movei	#MGTK_Position_Jump_Position,r8
		movei	#MGTK_Pattern_Delay_Time,r9
		movei	#0,r14
		movei	#-1,r11
		movei	#-2,r12
		movei	#False,r13
		store	r11,(r0)
		store	r12,(r1)
		store	r13,(r2)
		store	r14,(r3)
		store	r14,(r4)
		store	r13,(r5)
		store	r14,(r6)
		store	r13,(r7)
		store	r14,(r8)
		store	r14,(r9)
		movei	#MGTK_Replay_In_Service,r0
		movei	#MGTK_Replay_Problem,r1
		movei	#MGTK_Replay_Satured,r2
		movei	#MGTK_Replay_Paused,r3
		movei	#MGTK_Replay_Stopped,r4
		store	r13,(r0)
		store	r13,(r1)
		store	r14,(r2)
		store	r13,(r3)
		store	r13,(r4)


		
		movei	#End_Voices,r1					; Clear Voice
		movei	#MGTK_Voices,r0
		sub		r0,r1
		movei	#0,r2
		shrq		#2,r1
		
Loop3:	store	r2,(r0)
		subq		#1,r1
		addq		#4,r0
		cmpq		#0,r1
		jr		ne,Loop3
		nop


		
		movei	#MGTK_Voices,r14				; Put default values
		movei	#8363,r3
		movei	#256*1700,r4
		movei	#5,r5
		movei	#Loop4,r6
		
Loop4:	subq		#1,r5
		store	r3,(r14+Voice_Sample_Base/4)
		store	r4,(r14+Voice_Sample_Period/4)
		store	r3,(r14+Voice_Base/4)
		store	r4,(r14+Voice_Period/4)
		cmpq		#0,r5
		jump		ne,(r6)
		nop		



		movei	#MGTK_Nb_Voices,r7					; Put Music Panoramic Values
		movei	#MGTK_Voices+112,raa6
		load		(r7),r7
		movei	#loop2,r26
		
loop2:	loadb	(r10),r20
		subq		#1,r7
		addq		#1,r10
		store	r20,(raa6+Voice_Left_Volume/4)
		
		loadb	(r10),r20
		addq		#1,r10
		store	r20,(raa6+Voice_Right_Volume/4)
		
		cmpq		#0,r7
		jump		ne,(r26)
		nop		
		
		
		movei	#MGTK_Play_Patterns,r25
		jump		(r25)
		nop


		movei	#D_FLAGS,r30
		load		(r31),r28
		load		(r30),r29
		addq		#4,r31
		bclr		#3,r29
		addq		#2,r28
		bset		#9,r29
		
		jump		(r28)
		store	r29,(r30)
		nop
		
;***********************************************************************************************
_i2s_int:								; Sortie du son dans les DAC
;***********************************************************************************************
		movei	#Buffer_Ptr,r30
		movei	#Buffer_End,r27
		load		(r30),r29
		load		(r29),r28
	 	addq		#4,r29
	 	cmp		r29,r27
	 	jr		hi,NoModulo
	 	nop
	 	movei	#Buffer,r29
	 	
NoModulo:	store	r29,(r30)

		movei	#L_I2S+4,r29
		store	r28,(r29)
		shrq		#16,r28
		subq		#4,r29
		store	r28,(r29)



		movei	#D_FLAGS,r30
		load		(r31),r28
		load		(r30),r29
		addq		#4,r31
		bclr		#3,r29
		addq		#2,r28
		bset		#10,r29
		
		jump		(r28)
		store	r29,(r30)
;***********************************************************************************************
;***********************************************************************************************
;				Gestion des Patterns
;***********************************************************************************************
;***********************************************************************************************
TEMPO_INT:
;-----------------------------------------------------------------------------------------------
;		Streching & Mixage des voies
;-----------------------------------------------------------------------------------------------
R_Sample_Start			.equr	r0
R_Sample_Position		.equr	r1
R_Sample_Loop_Length	.equr	r2
R_Sample_Loop_End		.equr	r3
R_Sample_End			.equr	r4
R_Sample_Fraction_Hi	.equr	r5
R_Sample_Fraction_Lo	.equr	r6
R_Sample_Attribute		.equr	r7
R_Volume_Left			.equr	r8
R_Volume_Right			.equr	r9
R_Len_Buffer			.equr	r10
R_Buffer_Ptr			.equr	r11
;-----------------------------------------------------------------------------------------------
MGTK_Streching:

		IF DEBUG
			movei	#Length,r21			; MAJ du Buffer
			load		(r21),r0

			movei	#Old_Adr,r20			; Number of Samples
			load		(r20),r1
		
			movei	#Calc_Adr,r3
			store	r1,(r3)				; to calculate = Current Pos
			movei	#Buffer_Ptr,r7
			load		(r7),r7				
			store	r7,(r20)
			sub		r1,r7				; - Old Position
			jr		pl,Length_Ok
			nop
			movei	#650*4,r1				; Warning Modulo !
			add		r1,r7
		
Length_Ok:
			store	r7,(r21)				; Sample Length

			movei	#0,r2
			load		(r3),r6
			shrq		#2,r7

Clear_Sample_Buffer:
			store	r2,(r6)
			addq		#4,r6
			subq		#1,r7
			jr		ne,Clear_Sample_Buffer
			nop
		
		ENDIF


;-----------------------------------------------------------------------------------------------
		IF DEBUG
			jr	*
			nop
		ENDIF
		
		movei	#MGTK_Voices,r14

Loop:	load		(r14+Voice_Sample_Start/4),R_Sample_Start
		load		(r14+Voice_Sample_Position/4),R_Sample_Position
		load		(r14+Voice_Sample_Loop_Length/4),R_Sample_Loop_Length
		load		(r14+Voice_Sample_Loop_End/4),R_Sample_Loop_End
		load		(r14+Voice_Sample_End/4),R_Sample_End
		load		(r14+Voice_Sample_Fraction/4),R_Sample_Fraction_Hi
		load		(r14+Voice_Sample_Attributes/4),R_Sample_Attribute
		load		(r14+Voice_Total_Volume_Left/4),R_Volume_Left
		load		(r14+Voice_Total_Volume_Right/4),R_Volume_Right

		movei	#Next_Voice,r20
		cmpq		#0,R_Sample_Position
		jump		eq,(r20)
		nop
		
		
		movei	#$ffff0000,r20
		movei	#$0000ffff,r21
		
		move		R_Sample_Fraction_Hi,R_Sample_Fraction_Lo
		and		r20,R_Sample_Fraction_Hi
		and		r21,R_Sample_Fraction_Lo
		shrq		#16,R_Sample_Fraction_Hi
		shlq		#16,R_Sample_Fraction_Lo

		movei	#Len_Buffer,R_Len_Buffer
		movei	#Calc_Adr,R_Buffer_Ptr
		load		(R_Len_Buffer),R_Len_Buffer
		load		(R_Buffer_Ptr),R_Buffer_Ptr
;-----------------------------------------------------------------------------------------------
		movei	#0,r12
		movei	#Boucle,r19
		movei	#Treat_Loop,r22
		movei	#Buffer_End,r23
		
Boucle:	add		R_Sample_Fraction_Lo,r12
		addc		R_Sample_Fraction_Hi,R_Sample_Position
		cmp		R_Sample_Loop_End,R_Sample_Position
		jump		hi,(r22)
		nop

Sortie_Treat_Loop:		
		cmp		R_Sample_Position,r23				;Test modulo
		jr		hi,.ici
		nop
	 	movei	#Buffer,R_Sample_Position			

.ici:	loadb	(R_Sample_Position),r13
		shlq		#24,r13							; Pour ‚tendre le signe
		sharq	#24,r13							; sur 32 Bits
		move		r13,r16
		imult	R_Volume_Left,r13
		imult	R_Volume_Right,r16
		
		load		(R_Buffer_Ptr),r17					; Prend Buffer Voies G et D
		move		r17,r18							; Converti en 2 registres 16 bits
		and		r20,r17							; avec extension de signe
		and		r21,r18
		shlq		#16,r18
		sharq	#16,r17
		sharq	#16,r18
		
		add		r13,r17
		add		r16,r18
		
		shlq		#16,r17
		and		r21,r18
		add		r17,r18
		
		subq		#1,R_Len_Buffer
		store	r18,(R_Buffer_Ptr)
		cmpq		#0,R_Len_Buffer		
		jump		ne,(r19)
		addq		#4,R_Buffer_Ptr

Sortie_De_Boucle:
		store	R_Sample_Position,(r14+Voice_Sample_Position/4)
		
Next_Voice:		
		movei	#Voice_Size,r20
		movei	#End_Voices,r21
		add		r20,r14
		movei	#Loop,r20
		cmp		r21,r14
		jump		ne,(r20)
		nop
		

MGTK_Replay_No_More_Voices:
		movei	#MGTK_Replay_In_Service,r16	;move.b	MGTK_Frequency_Divider+1(pc),$ffff8935.w
		movei	#False,r17				;sf		MGTK_Replay_In_Service
		movei	#MGTK_IT_Counter,r18		;
		movei	#MGTK_IT_Number,r19			;
		
		store	r17,(r16)					;
		load		(r18),rd0					;
		load		(r19),rd1					;
		
		addq		#1,rd0					;move.w	MGTK_IT_Counter(pc),d0
		store	rd0,(r18)					;addq.w	#1,d0
		cmp		rd0,rd1					;addq.w	#1,d0
		jr		hi,MGTK_Replay_Not_Patterns	;cmp.w	MGTK_IT_Number(pc),d0
		nop								;blo.s	MGTK_Replay_Not_Patterns
		
		movei	#0,rd0					;clr.w	MGTK_IT_Counter
		movei	#MGTK_Play_Patterns,r17		;bsr.s	MGTK_Play_Patterns
		movei	#MGTK_Replay_Not_Patterns,Rts_Register
		jump		(r17)					;
		store	rd0,(r18)					;

MGTK_Replay_Not_Patterns:
		movei	#FIN_TEMPO_INT,r17			;rte
		jump		(r17)					;
		nop								;
		
;-----------------------------------------------------------------------------------------------
Treat_Loop:
		btst		#0,R_Sample_Attribute		; Loop ?
		jr		ne,A_Loop
		nop
		movei	#Sortie_De_Boucle,r23
		movei	#0,R_Sample_Position
		jump		(r23)
		nop
		
A_Loop:
		movei	#Sortie_Treat_Loop,r23
		sub		R_Sample_Loop_Length,R_Sample_Position
		jump		(r23)
		nop
;-----------------------------------------------------------------------------------------------
FIN_TEMPO_INT:									;Fin de l'interruption Tempo
;-----------------------------------------------------------------------------------------------
		IF DEBUG
			movei	#TEMPO_INT,r25
			jump		(r25)
			nop
		ENDIF
		
		movei	#D_FLAGS,r30
		load		(r31),r28
		load		(r30),r29
		addq		#4,r31
		bclr		#3,r29
		addq		#2,r28
		bset		#11,r29
		
		jump		(r28)
		store	r29,(r30)
		nop
;-----------------------------------------------------------------------------------------------
		.equrundef	R_Sample_Start
		.equrundef	R_Sample_Position
		.equrundef	R_Sample_Length
		.equrundef	R_Sample_Loop_Length
		.equrundef	R_Sample_End_Length
		.equrundef	R_Sample_Fraction_Hi
		.equrundef	R_Sample_Fraction_Lo
		.equrundef	R_Sample_Attribute
		.equrundef	R_Len_Buffer
		.equrundef	R_Buffer_Ptr
;-----------------------------------------------------------------------------------------------


MGTK_Replay_Timer:
MGTK_Play_Patterns:
		movei	#MGTK_Music_Counter,r16		;addq.b	#1,MGTK_Music_Counter
		movei	#MGTK_Music_Speed,r17		;move.b	MGTK_Music_Counter,d0
		load		(r16),rd0					;cmp.b	MGTK_Music_Speed,d0
		load		(r17),r18					;blo		MGTK_No_New_Note
		addq		#1,rd0					;move.b	#0,MGTK_Music_Counter
		movei	#MGTK_No_New_Note,r19		;
		store	rd0,(r16)					;
		cmp		rd0,r18					;
		jump		hi,(r19)					;
		nop								;
		movei	#0,rd0					;
		store	rd0,(r16)					;
		
		movei	#MGTK_Pattern_Break_Flag,r16	;tst.b	MGTK_Pattern_Break_Flag
		movei	#MGTK_New_Pattern,r18		;bne.s	MGTK_New_Pattern
		load		(r16),r17					;
		cmpq		#0,r17					;
		jump		ne,(r18)					;
		nop								;
		
		movei	#MGTK_Pattern_Delay_Time,r16	;tst.b	MGTK_Pattern_Delay_Time
		movei	#MGTK_No_Pattern_Delay,r18	;beq.s	MGTK_No_Pattern_Delay
		load		(r16),r17					;
		cmpq		#0,r17					;
		jump		ne,(r18)					;
		nop								;

		movei	#MGTK_Pattern_Delay_Time,r16	;subq.b	#1,MGTK_Pattern_Delay_Time
		movei	#MGTK_No_New_Note,r18		;bra	MGTK_No_New_Note
		load		(r16),r17					;
		subq		#1,r17					;
		jump		(r18)					;
		store	r17,(r16)					;

MGTK_No_Pattern_Delay:
		movei	#MGTK_Pattern_Loop_Flag,r16	;tst.b	MGTK_Pattern_Loop_Flag
		movei	#MGTK_No_Pattern_Loop,r18	;beq.s	MGTK_No_Pattern_Loop
		load		(r16),r17					;
		cmpq		#0,r17					;
		jump		ne,(r18)					;
		nop								;

		movei	#MGTK_Pattern_Loop_Position,r16	;move.w	MGTK_Pattern_Loop_Position,MGTK_Pattern_Position
		movei	#MGTK_Pattern_Position,r17		;sf		MGTK_Pattern_Loop_Flag
		movei	#MGTK_Pattern_Loop_Flag,r18		;bra		MGTK_New_Notes
		movei	#MGTK_New_Notes,r19				;
		movei	#False,r20					;
		load		(r16),r21						;
		store	r20,(r18)						;
		jump		(r19)						;
		store	r21,(r17)						;

MGTK_No_Pattern_Loop:
		movei	#MGTK_Position_Jump_Flag,r16		;tst.b	MGTK_Position_Jump_Flag
		movei	#MGTK_New_Line,r18				;beq.s	MGTK_New_Line
		load		(r16),r17						;
		cmpq		#0,r17						;
		jump		ne,(r18)						;
		nop									;

		movei	#MGTK_Position_Jump_Position,r16	;move.w	MGTK_Position_Jump_Position,d0
		movei	#MGTK_Position_Jump_Flag,r17		;sf		MGTK_Position_Jump_Flag
		movei	#MGTK_Pattern_Break_Position,r18	;move.w	#0,MGTK_Pattern_Break_Position
		movei	#MGTK_New_Position,r19			;bra.s	MGTK_New_Position
		movei	#0,r20						;
		movei	#False,r21					;
		load		(r16),rd0						;
		store	r21,(r17)						;
		jump		(r19)						;
		store	r20,(r18)						;

MGTK_New_Line:
		movei	#MGTK_Pattern_Position,r16	;addq.w	#1,MGTK_Pattern_Position
		movei	#MGTK_Pattern_Length,r17		;move.w	MGTK_Pattern_Position,d0
		load		(r16),rd0					;cmp.w	MGTK_Pattern_Length,d0
		movei	#MGTK_New_Notes,r19			;blo.s	MGTK_New_Notes
		addq		#1,rd0					;
		load		(r17),r18					;
		cmp		rd0,r17					;
		jump		hi,(r19)					;
		store	rd0,(r16)					;

MGTK_New_Pattern:
		movei	#MGTK_Music_Position,r16		;move.w	MGTK_Music_Position,d0
		load		(r16),rd0					;addq.w	#1,d0
		addq		#1,rd0					;

MGTK_New_Position:
		movei	#MGTK_Pattern_Break_Position,r16	;move.w	MGTK_Pattern_Break_Position,MGTK_Pattern_Position
		movei	#MGTK_Pattern_Position,r17		;move.w	#0,MGTK_Pattern_Break_Position
		movei	#MGTK_Pattern_Break_Flag,r18		;sf		MGTK_Pattern_Break_Flag
		movei	#0,r19						;
		movei	#False,r20					;
		movei	#MGTK_Music_Length,r22			;
		movei	#MGTK_No_Restart_Tempo,r23		;
		movei	#MGTK_Music_Restart,r25			;
		load		(r16),r21						;
		load		(r22),r24						;
		store	r20,(r18)						;
		store	r19,(r16)						;
		store	r21,(r17)						;
											;
		cmp		rd0,r24						;cmp.w	MGTK_Music_Length,d0
		jump		hi,(r23)						;blo.s	MGTK_No_Restart_Tempo
											;
		load		(r25),rd0						;move.w	MGTK_Music_Restart,d0
		cmpq		#0,rd0						;bne.s	MGTK_No_Restart_Tempo
		jump		ne,(r23)						;
		nop									;
		
		movei	#MGTK_Initial_Speed,r16			;move.b	MGTK_Initial_Speed,MGTK_Music_Speed
		movei	#MGTK_Music_Speed,r17			;move.b	MGTK_Initial_Tempo,MGTK_Music_Tempo
		movei	#MGTK_Initial_Tempo,r18			;bsr		MGTK_Search_Values_for_Tempo
		movei	#MGTK_Music_Tempo,r19			;
		load		(r16),r20						;
		load		(r18),r21						;
		store	r20,(r17)						;
		store	r21,(r19)						;

MGTK_No_Restart_Tempo:
		movei	#MGTK_Music_Position,r16		;move.w	d0,MGTK_Music_Position
		store	rd0,(r16)					;

MGTK_New_Notes:
		movei	#MGTK_Sequence_Adr,r17		;move.l	MGTK_Sequence_Adr,a0
		movei	#MGTK_Music_Position,r16		;move.w	MGTK_Music_Position,d0
		movei	#MGTK_Nb_Voices,r18			;move.w	MGTK_Nb_Voices,d1
		load		(r17),ra0					;add.w	d1,d1
		load		(r18),rd1					;addq.w	#2,d1		; Pattern Length
		load		(r16),rd0					;add.w	d0,d0
		add		rd1,rd1					;mulu.w	(a0,d0.w),d1
		add		rd0,rd0					;
		addq		#2,rd1					;
		add		rd0,ra0					;
		loadw	(ra0),r16					;
		mult		r16,rd1					;
										
										;Pointe sur num‚ros pistes
		movei	#MGTK_Patterns_Adr,r16		;move.l	MGTK_Patterns_Adr,a4
		movei	#MGTK_Pattern_Length,r17		;add.l	d1,a4
		load		(r16),ra4					;move.w	(a4)+,MGTK_Pattern_Length
		add		rd1,ra4					;
		loadw	(ra4),r16					;
		addq		#2,ra4					;
		store	r16,(r17)					;
		
		
		movei	#MGTK_Nb_Voices,rd7			;move.w	MGTK_Nb_Voices,d7
		movei	#MGTK_Voices,ra6			;lea.l	MGTK_Voices,a6
		movei	#112,raa6					;subq.w	#1,d7
		load		(rd7),rd7					;
		add		ra6,raa6					;
										;
MGTK_New_Notes_Loop:						;
		movei	#MGTK_Tracks_Ptr,r17	
		loadw	(ra4),r16
		load		(r17),r17
		addq		#2,ra4

		movei	#MGTK_Do_Track_Vide,r25		
		cmpq		#0,r16						; Track vide ?
		jump		eq,(r25)
		nop
		
		subq		#1,r16
		move		r17,r18
		shlq		#2,r16
		movei	#MGTK_Module_Adr,r24
		add		r16,r18
		load		(r24),r24
		movel	r18,r19
		add		r24,r19
		addq		#1,r19						; Len Track sur 1 word pas toujours
		loadb	(r19),r20						; align‚. Anyway, ne depasse pas $FF
		addq		#1,r19
		store	r20,(raa6+Voice_Len_Track/4)
		
		loadb	(r19),r21
		addq		#1,r19
		movei	#%11,r23
		move		r21,r22
		and		r23,r21
		shrq		#2,r22
		store	r21,(raa6+Voice_Nb_Empty_Line/4)
		store	r22,(raa6+Voice_Packed_Bits/4)
		store	r19,(raa6+Voice_Adr_In_Track/4)
		movei	#MGTK1,r25
		jump		(r25)
		nop
		

MGTK_Do_Track_Vide:
		movei	#0,r20
		movei	#MGTK_Track_0,r21
		store	r20,(raa6+Voice_Len_Track/4)
		store	r20,(raa6+Voice_Nb_Empty_Line/4)
		store	r20,(raa6+Voice_Packed_Bits/4)
		store	r21,(raa6+Voice_Adr_In_Track/4)

MGTK1:	movei	#MGTK_Play_Voice,r25		;bsr.s	MGTK_Play_Voice
		jump		(r25)					;
		nop								;
		
MGTK_New_Notes_Loop_Rts:						;
		movei	#Voice_Size,r25			;lea.l	Voice_Size(a6),a6
		movei	#MGTK_New_Notes_Loop,r24		;dbra	d7,MGTK_New_Notes_Loop
		subq		#1,rd7					;
		add		r25,ra6					;
		add		r25,raa6					;
		cmpq		#0,rd7					;
		jump		ne,(r24)					;
		nop								;
		movei	#FIN_TEMPO_INT,r17			;rts
		jump		(r17)					;
		nop								;
;-----------------------------------------------------------------------------------------------
;         Se deroule en dehors des 'Ticks'
;-----------------------------------------------------------------------------------------------
MGTK_No_New_Note:
		movei	#MGTK_Nb_Voices,rd7			;lea.l	MGTK_Voices,a6
		movei	#MGTK_Voices,ra6			;move.w	MGTK_Nb_Voices,d7
		load		(rd7),rd7					;subq.w	#1,d7
		
MGTK_No_New_Note_Loop:
		load		(ra6+Voice_Vol_Command/4),rd0	;moveq.l	#0,d0		
		movei	#MGTK_Check_Efx_2,Rts_Register ;move.b	Voice_Vol_Command(a6),d0
		cmpq		#0,rd0					;beq.s	MGTK_Check_Efx_2
		jump		eq,(r25)					;
		nop								;
		
		move		rd0,rd1					;move.w	d0,d1
		movei	#$0f,r16					;and.b	#$0f,d0
		shrq		#4,rd1					;lsr.b	#4,d1
		movei	#Jump_Table_Vol,ra0			;lea		Jump_Table_Vol,a0
		shlq		#2,rd1					;lsl.w	#2,d1
		and		r16,rd0					;add.w	d1,a0
		add		rd1,ra0					;move.l	(a0),a0
		load		(ra0),ra0					;jsr		(a0)
		jump		(ra0)					;
		nop								;

MGTK_Check_Efx_2:
		load		(ra6+Voice_Command/4),rd0	;moveq.l	#0,d0
		movei	#Jump_Table_2,ra0			;move.b	Voice_Command(a6),d0
		shlq		#2,rd0					;lea		Jump_Table_2,a0
		add		rd0,ra0					;lsl.w	#2,d0
		load		(ra0),ra0					;add.w	d0,a0
		movei	#MGTK_Rts1,Rts_Register		;move.l	(a0),a0
		jump		(ra0)					;jsr		(a0)
		nop								;bsr		Calc_Volume
MGTK_Rts1:								;
		movei	#Calc_Volume,ra0			;
		movei	#MGTK_Rts2,Rts_Register		;
		jump		(ra0)					;
		nop								;
MGTK_Rts2:								;
		movei	#Voice_Size,r16			;lea.l	Voice_Size(a6),a6
		add		r16,ra6					;dbra	d7,MGTK_No_New_Note_Loop
		add		r16,raa6					;
		movei	#MGTK_No_New_Note_Loop,r17	;
		subq		#1,rd7					;
		jump		ne,(r17)					;
		nop								;
		movei	#FIN_TEMPO_INT,r17			;rts
		jump		(r17)					;
		nop								;
;-----------------------------------------------------------------------------------------------
;				Traite une Voie
;-----------------------------------------------------------------------------------------------
MGTK_Play_Voice:
		movei	#MGTK_Module_Adr,r19
		movei	#0,r25
		load		(r19),r19
		
		load		(raa6+Voice_Packed_Bits/4),rd0
		load		(raa6+Voice_Nb_Empty_Line/4),rd1
		load		(raa6+Voice_Len_Track/4),rd6
		load		(raa6+Voice_Adr_In_Track/4),ra2

		store	r25,(raa6+Voice_Note/4)
		store	r25,(raa6+Voice_Sample/4)
		store	r25,(raa6+Voice_Vol_Command/4)
		store	r25,(raa6+Voice_Command/4)
		store	r25,(raa6+Voice_Parameter1/4)
		store	r25,(raa6+Voice_Parameter2/4)

		subq		#1,rd6
		movei	#MGTK_End_Track,r25
		cmpq		#-1,rd6
		jump		eq,(r25)
		nop		
		
		movei	#MGTK_Depack_Track_No_Empty_Line,r25
		cmpq		#0,rd1
		jump		eq,(r25)
		nop
		
		subq		#1,rd1
		movei	#MGTK_Track_Depacked,r16
		store	rd1,(raa6+Voice_Nb_Empty_Line/4)
		jump		(r16)
		nop
		
MGTK_Depack_Track_No_Empty_Line:
		movei	#6,rd2
		movei	#0,r17
		move		raa6,ra1
MGTK_Depack_Track_Note:
		shrq		#1,rd0
		jr		cc,MGTK_Depack_Track_No_Byte
		move		r17,r16
		loadb	(ra2),r16
		addq		#1,ra2
MGTK_Depack_Track_No_Byte:
		store	r16,(ra1)
		subq		#1,rd2
		addq		#4,ra1
		cmpq		#0,rd2
		jr		ne,MGTK_Depack_Track_Note
		nop
		
		movei	#MGTK_Track_Depacked,r25
		
		loadb	(ra2),r16
		addq		#1,ra2
		movei	#%11,r18
		move		r16,r17
		and		r18,r16
		shrq		#2,r17
		store	r16,(raa6+Voice_Nb_Empty_Line/4)
		store	r17,(raa6+Voice_Packed_Bits/4)
		
		jump		(r25)
		nop
		
MGTK_End_Track:
		movei	#0,rd6		
		
MGTK_Track_Depacked:
		store	rd6,(raa6+Voice_Len_Track/4)
		store	ra2,(raa6+Voice_Adr_In_Track/4)
		
MGTK_Check_Sample:
		
		load		(raa6+Voice_Sample/4),rd2	;moveq.l	#0,d2
		movei	#MGTK_Check_Efx_Volume,r16	;move.b	Voice_Sample(a6),d2
		cmpq		#0,rd2					;beq.s	MGTK_Check_Efx_Volume
		jump		eq,(r16)					;
		nop								;
		
		subq		#1,rd2					;subq.w	#1,d2
		movei	#Sample_Size,r16			;mulu.w	#Sample_Size,d2
		movei	#MGTK_Samples_Infos_Adr,r17	;move.l	MGTK_Samples_Infos_Adr,a3
		mult		r16,rd2					;add.w	d2,a3
		load		(r17),ra3					;
		add		rd2,ra3					;
		
		movei	#Sample_Start,r17			;move.l	Sample_Start(a3),Voice_Start(a6)
		move		ra3,r16					;
		add		r17,r16					;
		movel	r16,r17					;
		add		r19,r17					;
		store	r17,(ra6+Voice_Start/4)		;
		
		movei	#Sample_Length,r17			;move.l	Sample_Length(a3),Voice_Length(a6)
		move		ra3,r16					;
		add		r17,r16					;
		movel	r16,r17					;
		store	r17,(ra6+Voice_Length/4)		;
								
		movei	#Sample_Loop_Length,r17		;move.l	Sample_Loop_Length(a3),Voice_Loop_Length(a6)
		move		ra3,r16					;
		add		r17,r16					;
		movel	r16,r17					;
		store	r17,(ra6+Voice_Loop_Length/4)	;

		movei	#Sample_End_Length,r17		;move.l	Sample_End_Length(a3),Voice_End_Length(a6)
		move		ra3,r16					;
		add		r17,r16					;
		movel	r16,r17					;
		store	r17,(ra6+Voice_End_Length/4)	;
		
		movei	#0,r17					;move.l 	#0,Voice_Sample_Offset(a6)
		store	r17,(ra6+Voice_Sample_Offset/4)
		
		movei	#Sample_Base,r17			;move.l	Sample_Base(a3),Voice_Base(a6)
		move		ra3,r16					;
		add		r17,r16					;
		movel	r16,r17					;
		store	r17,(ra6+Voice_Base/4)		;
		
		movei	#Sample_Attributes,r17		;move.b	Sample_Attributes(a3),Voice_Attributes(a6)
		move		ra3,r16					;
		add		r17,r16					;
		loadb	(r16),r17					;
		store	r17,(ra6+Voice_Attributes/4)	;
		
		movei	#Sample_Volume,r17			;move.w	Sample_Volume(a3),Voice_Volume(a6)
		move		ra3,r16					;
		add		r17,r16					;
		loadw	(r16),r17					;
		store	r17,(ra6+Voice_Volume/4)		;
		store	r17,(ra6+Voice_Sample_Volume/4) ;move.w	Sample_Volume(a3),Voice_Sample_Volume(a6)

		movei	#Sample_Panoramic,r17		;move.w	Sample_Panoramic(a3),d0
		move		ra3,r16					;beq.s	MGTK_Check_Sample_No_Panoramic
		add		r17,r16					;
		loadw	(r16),rd0					;
		cmpq		#0,rd0					;
		jr		eq,MGTK_Check_Sample_No_Panoramic
		nop								;
		
		move		rd0,rd1					 ;
		movei	#$0000ff00,rd2				 ;
		and		rd2,rd1					 ;
		store	rd0,(raa6+Voice_Right_Volume/4);move.w	d0,Voice_Left_Volume(a6)
		shrq		#8,rd1					 ;
		store	rd1,(raa6+Voice_Left_Volume/4) ;
		
MGTK_Check_Sample_No_Panoramic:
		movei	#Sample_Fine_Tune,r17		;moveq.l	#0,d0
		move		ra3,r16					;move.b	Sample_Fine_Tune(a3),d0
		add		r17,r16					;mulu.w	#12*8*4,d0
		movei	#12*8*4,r18				;move.w	d0,Voice_Sample_Fine_Tune(a6)
		loadb	(r16),rd0					;
		mult		r18,rd0					;
		store	rd0,(ra6+Voice_Sample_Fine_Tune/4)



MGTK_Check_Efx_Volume:
		load		(raa6+Voice_Vol_Command/4),rd0 ;moveq.l	#0,d0
		movei	#MGTK_Check_Efx_0,Rts_Register;move.b	Voice_Vol_Command(a6),d0
		cmpq		#0,rd0					;beq.s	MGTK_Check_Efx_0
		jump		eq,(Rts_Register)			;
		nop								;
		
		move		rd0,rd1					;move.w	d0,d1
		movei	#$0f,r17					;and.b	#$0f,d0
		shrq		#4,rd1					;lsr.b	#4,d1
		and		r17,rd0					;
										
		cmpq		#6,rd1					;cmp.b	#$6,d1			; Pas de slide
		jump		eq,(Rts_Register)			;beq.s	MGTK_Check_Efx_0
		nop								;
		cmpq		#7,rd1					;cmp.b	#$7,d1			; au 1er tick
		jump		eq,(Rts_Register)			;beq.s	MGTK_Check_Efx_0
		nop								;
		movei	#MGTK_Vol_Set_Tone_Portamento,r16	;cmp.b	#$f,d1
		cmpq		#$f,rd1					;beq		MGTK_Vol_Set_Tone_Portamento
		jump		eq,(r16)					;VERIFIER L' ADR DE RETOUR
		nop								;
		movei	#Jump_Table_Vol,ra0			;lea		Jump_Table_Vol,a0
		shlq		#2,rd1					;lsl.w	#2,d1
		add		rd1,ra0					;add.w	d1,a0
		load		(ra0),ra0					;move.l	(a0),a0
		;jump		(ra0)					;jsr		(a0)
		nop								;

MGTK_Check_Efx_0:
		load		(raa6+Voice_Command/4),rd0	;moveq.l	#0,d0
		movei	#Jump_Table_0,ra0			;move.b	Voice_Command(a6),d0
		shlq		#2,rd0					;lea		Jump_Table_0,a0
		movei	#MGTK_Check_Note,Rts_Register	;lsl.w	#2,d0
		add		rd0,ra0					;add.w	d0,a0
		load		(ra0),ra0					;move.l	(a0),a0
		;jump		(ra0)					;jsr		(a0)
		nop								;

MGTK_Check_Note:
		load		(raa6+Voice_Note/4),rd0		;moveq.l	#0,d0
		movei	#MGTK_Check_Efx_1,r16		;move.b	Voice_Note(a6),d0
		cmpq		#0,rd0					;beq.s	MGTK_Check_Efx_1
		jump		eq,(r16)					;
		nop								;

		subq		#12,rd0					;sub.b	#12,d0
		movei	#MGTK_Periods_Table,ra0		;lea.l	MGTK_Periods_Table,a0
		load		(ra6+Voice_Sample_Fine_Tune/4),r16 ;adda.w	Voice_Sample_Fine_Tune(a6),a0
		shlq		#2,rd0					;lsl.w	#2,d0
		add		r16,ra0					;move.l	(a0,d0.w),Voice_Period(a6)
		add		rd0,ra0					;
		load		(ra0),ra0					;
		store	ra0,(ra6+Voice_Period/4)		;

		load		(raa6+Voice_Command/4),rd0	;cmp.b	#$1d,Voice_Command(a6)
		movei	#$1d,rd1
		movei	#MGTK_No_Note_Delay,r25		;bne.s	MGTK_No_Note_Delay
		cmp		rd1,rd0					;tst.b	Voice_Parameter1(a6)
		jump		ne,(r25)					;beq.s	MGTK_No_Note_Delay
		nop								;bsr		Calc_Volume
		load		(raa6+Voice_Parameter1/4),rd0	;
		movei	#Calc_Volume,r17			;
		cmpq		#0,rd0					;
		jump		eq,(r25)					;
		nop								;
		movei	#MGTK_Rts_5,Rts_Register		;
		jump		(r17)					;
		nop								;
MGTK_Rts_5:								;
		movei	#MGTK_New_Notes_Loop_Rts,r25	;rts
		jump		(r25)					;
		nop								;
;-----------------------------------------------------------------------------------------------
MGTK_No_Note_Delay:
		load		(ra6+Voice_Start/4),rd0		;move.l	Voice_Start(a6),Voice_Sample_Start(a6)
		load		(ra6+Voice_Length/4),rd1		;move.l	Voice_Length(a6),Voice_Sample_Length(a6)
		load		(ra6+Voice_Loop_Length/4),rd2	;move.l	Voice_Loop_Length(a6),Voice_Sample_Loop_Length(a6)
		load		(ra6+Voice_End_Length/4),rd3	;move.l	Voice_End_Length(a6),Voice_Sample_End_Length(a6)
		load		(ra6+Voice_Sample_Offset/4),rd4 ;move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)
		load		(ra6+Voice_Base/4),rd5		;move.l	Voice_Base(a6),Voice_Sample_Base(a6)
		load		(ra6+Voice_Attributes/4),rd6	;move.b	Voice_Attributes(a6),Voice_Sample_Attributes(a6)
		load		(ra6+Voice_Period/4),r16		;move.l	Voice_Period(a6),Voice_Sample_Period(a6)
		store	rd0,(ra6+Voice_Sample_Start/4)	
		store	rd1,(ra6+Voice_Sample_Length/4)
		store	rd2,(ra6+Voice_Sample_Loop_Length/4)
		store	rd3,(ra6+Voice_Sample_End_Length/4)
		store	rd4,(ra6+Voice_Sample_Offset/4)
		store	rd5,(ra6+Voice_Sample_Base/4)
		store	rd6,(ra6+Voice_Sample_Attributes/4)
		store	r16,(ra6+Voice_Sample_Period/4)
		
		load		(raa6+Voice_Vibrato_Waveform/4),rd0 ;btst.b	#2,Voice_Vibrato_Waveform(a6)
		movei	#0,r16					;bne.s	MGTK_Vibrato_No_Reset
		btst		#2,rd0					;move.b	#0,Voice_Vibrato_Position(a6)
		jr		ne,MGTK_Vibrato_No_Reset		;
		nop								;
		store	r16,(raa6+Voice_Vibrato_Waveform/4)
		
MGTK_Vibrato_No_Reset:
		load		(raa6+Voice_Tremolo_Waveform/4),rd0 ;btst.b	#2,Voice_Tremolo_Waveform(a6)
		btst		#2,rd0					;bne.s	MGTK_Tremolo_No_Reset
		jr		ne,MGTK_Tremolo_No_Reset		;move.b	#0,Voice_Tremolo_Position(a6)
		nop								;
		store	r16,(raa6+Voice_Tremolo_Waveform/4)
		
MGTK_Tremolo_No_Reset:

MGTK_Check_Efx_1:
		load		(raa6+Voice_Command/4),rd0	;moveq.l	#0,d0
		movei	#Jump_Table_1,ra0			;move.b	Voice_Command(a6),d0
		shlq		#2,rd0					;lea		Jump_Table_1,a0
		movei	#MGTK_Rts_3,Rts_Register		;lsl.w	#2,d0
		add		rd0,ra0					;add.w	d0,a0
		load		(ra0),ra0					;move.l	(a0),a0
		;jump		(ra0)					;jsr		(a0)
		nop								;bsr		Calc_Volume
MGTK_Rts_3:								;
		movei	#Calc_Volume,r25			;
		movei	#MGTK_Rts_4,Rts_Register		;
		jump		(r25)					;
		nop								;
MGTK_Rts_4:								;
		movei	#MGTK_New_Notes_Loop_Rts,r25	;rts
		jump		(r25)					;
		nop								;

;-----------------------------------------------------------------------------------------------							
Calc_Volume:
		movei	#MGTK_Master_Volume_Left,rd0		;move.b	MGTK_Master_Volume_Left,d0
		movei	#MGTK_Master_Volume_Right,rd1		;move.b	MGTK_Master_Volume_Right,d1
		movei	#MGTK_Global_Volume,rd5			;move.b	Voice_Left_Volume(a6),d2
		load		(raa6+Voice_Left_Volume/4),rd2	;move.b	Voice_Right_Volume(a6),d3
		load		(raa6+Voice_Right_Volume/4),rd3	;move.w	Voice_Sample_Volume(a6),d4
		load		(ra6+Voice_Sample_Volume/4),rd4	;move.w	MGTK_Global_Volume,d5
		load		(rd0),rd0						;
		load		(rd1),rd1						;
		load		(rd5),rd5						;

		mult		rd0,rd2						;mulu	d0,d2	; 256      8 bits * 8 bits
		mult		rd1,rd3						;lsr.l	#8,d2
		shrq		#8,rd2						;mulu	d4,d2	; 1024    10 bits
		shrq		#8,rd3						;lsr.l	#10,d2
		mult		rd4,rd2						;mulu	d5,d2	; 1024    10 bits
		mult		rd4,rd3						;lsr.l	#10,d2
		shrq		#10,rd2						;move.w	d2,Voice_Total_Volume_Left(a6)	
		shrq		#10,rd3										; Voir s'il ne faut pas
		mult		rd5,rd2										; / par Nb_Voices
		mult		rd5,rd3
		shrq		#10,rd2						;mulu	d1,d3	; 256      8 bits * 8 bits
		shrq		#10,rd3						;lsr.l	#8,d3
		store	rd2,(ra6+Voice_Total_Volume_Left/4) ;mulu	d4,d3	; 1024    10 bits
		store	rd3,(ra6+Voice_Total_Volume_Right/4) ;lsr.l	#10,d3
											;mulu	d5,d3	; 1024    10 bits
											;lsr.l	#10,d3
											;move.w	d3,Voice_Total_Volume_Right(a6)
		
Calc_Voice_addresses:
		load		(ra6+Voice_Sample_Start/4),rd0	;move.l	Voice_Sample_Start(a6),d0
		load		(ra6+Voice_Sample_Loop_Length/4),rd1 ;move.l	Voice_Sample_Loop_Length(a6),d1
		load		(ra6+Voice_Sample_Length/4),rd2	;move.l	d0,Voice_Sample_Loop_End(a6)
		load		(ra6+Voice_Sample_End_Length/4),rd3 ;add.l	d1,Voice_Sample_Loop_End(a6)
		load		(ra6+Voice_Sample_Position/4),rd4
		add		rd0,rd1	
		add		rd0,rd4
		add		rd2,rd3						;move.l	Voice_Sample_Length(a6),d1
		add		rd3,rd0						;add.l	Voice_Sample_End_Length(a6),d1
		store	rd1,(ra6+Voice_Sample_Loop_End/4)	;move.l	d0,Voice_Sample_End(a6)
		store	rd0,(ra6+Voice_Sample_End/4)		;add.l	d1,Voice_Sample_End(a6)
		store	rd4,(ra6+Voice_Sample_Position/4)
		
Calc_Voice_Frequency_Fraction:
		movei	#428/2,rd1
		movei	#MGTK_Replay_Frequency,rd2
		load		(ra6+Voice_Sample_Period/4),rd4
		load		(ra6+Voice_Sample_Base/4),rd3
		load		(rd2),rd2
		shrq		#8,rd4							; /256

		div		rd2,rd1
		or		rd1,rd1
		mult		rd3,rd1
		shrq		#8,rd1
		div		rd4,rd1
		or		rd1,rd1
		shrq		#7,rd1
		
		store	rd1,(ra6+Voice_Sample_Fraction/4)
		jump		(Rts_Register)
		nop
;-----------------------------------------------------------------------------------------------
;		Fonction
;-----------------------------------------------------------------------------------------------
MGTK_Search_Values_for_Tempo:
		movei	#D_DIVCTRL,r1
		load		(r1),r0
		bclr		#0,r0
		store	r0,(r1)

		movei	#MGTK_Music_Tempo,rd0		;movem.l	d0-d3,-(sp)
		movei	#125,rd1					;moveq.l	#0,d0
		movei	#50,r16					;move.b	MGTK_Music_Tempo,d0
		movei	#0,rd3
		movei	#MGTK_Replay_Frequency,r17
		movei	#DSP_Buffer/2,r18
		movei	#MGTK_IT_Number,r19
		movei	#50*256,r20
		movei	#125,r21
		movei	#CLOCK_FREQUENCY/2000*256,r22
		
		load		(r17),r17
		load		(rd0),rd0
		
		mult		r17,rd1
		div		r16,rd1
		or		rd1,rd1
		div		rd0,rd1
		or		rd1,rd1
										;moveq.l	#125,d1				; 125
										;mulu.w	MGTK_Replay_Frequency,d1	; * Frequence Replay
										;divu	#50,d1				; / 50
										;divu	d0,d1				; / Tempo
										;moveq	#0,d3				; = Nb Samples / Tick
MGTK_Search_Length_Loop:
		addq		#1,rd3
		move		rd1,rd2
		div		rd3,rd2
		or		rd2,rd2
		cmp		r18,rd2
		jr		hi,MGTK_Search_Length_Loop
		nop
		store	rd3,(r19)
										;addq.b	#1,d3				; Cherche en
										;move.l	d1,d2				; combien de fois
										;divu	d3,d2				; on peut traiter
										;cmp.w	#DSP_Buffer/2,d2		; un 'tick'
										;bhi.s	MGTK_Search_Length_Loop

										;move.w	d3,MGTK_IT_Number

MGTK_Search_MFP_Divider:
		mult		rd3,rd0
		mult		r20,rd0
		div		r21,rd0
		or		rd0,rd0
		div		rd0,r22
		or		r22,r22
		
		movei	#MGTK_Retour_Variable,r20
		movei	#2000,r21
		movei	#MGTK_IT_Timer_Control,r23
		movei	#MGTK_IT_Timer_Data,r24
		subq		#1,r22
		
		load		(r20),r20
		store	r21,(r23)
		store	r22,(r24)
		
		movei	#D_DIVCTRL,r1
		load		(r1),r0
		bset		#0,r0
		store	r0,(r1)
		
		jump		(r20)
		nop
										;mulu.w	d3,d0				; Tempo*Nb ITs
										;mulu.w	#50*256,d0			; *50/125*256
										;divu	#125,d0				; = Freq Cherch‚e * 256

										;move.l	#2457600/200*256,d2		; Freq Base MFP
										;move.l	d2,d3				; / Prediviseur 200
										;divu	d0,d2				; / Freq donne Diviseur

										;move.b	#7,MGTK_IT_Timer_Control
										;move.b	d2,MGTK_IT_Timer_Data
										;movem.l	(sp)+,d0-d3
										;rts
;-----------------------------------------------------------------------------------------------
		.equrundef	rd0		
		.equrundef	rd1		
		.equrundef	rd2		
		.equrundef	rd3		
		.equrundef	rd4		
		.equrundef	rd5		
		.equrundef	rd6		
		.equrundef	rd7		
		.equrundef	ra0		
		.equrundef	ra1	
		.equrundef	ra2
		.equrundef	ra3
		.equrundef	ra4
		.equrundef	ra5
		.equrundef	ra6
		.equrundef	raa6
		.equrundef	Rts_Register
;-----------------------------------------------------------------------------------------------
					Long
Jump_Table_Vol:
		dc.l		MGTK_Return,MGTK_Vol_Change
		dc.l		MGTK_Vol_Change,MGTK_Vol_Change
		dc.l		MGTK_Vol_Change,MGTK_Vol_Maxi
		dc.l		MGTK_Vol_Slide_Down,MGTK_Vol_Slide_Up
		dc.l		MGTK_Vol_Fine_Slide_Down,MGTK_Vol_Fine_Slide_Up
		dc.l		MGTK_Vol_Set_Vibrato_Speed,MGTK_Vol_Vibrato
		dc.l		MGTK_Vol_Set_Panoramic,MGTK_Vol_Pan_Slide_Left
		dc.l		MGTK_Vol_Pan_Slide_Right,MGTK_Tone_Portamento_No_Change
		
Jump_Table_0:
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

Jump_Table_1:
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

Jump_Table_2:
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

MGTK_Module_Adr:			dc.l		0
MGTK_WorkSpace_Adr:			dc.l		0
MGTK_Module_End_Adr:		dc.l		0

MGTK_Nb_Voices:			dc.l		0
MGTK_Nb_Musics:			dc.l		0
MGTK_Nb_Tracks:			dc.l		0
MGTK_Nb_Samples:			dc.l		0

MGTK_Musics_Adr:			dc.l		0
MGTK_Sequences_Adr:			dc.l		0
MGTK_Samples_Infos_Adr:		dc.l		0
MGTK_Patterns_Adr:			dc.l		0
MGTK_Tracks_Ptr:			dc.l		0
MGTK_Samples_Data_Adr:		dc.l		0
MGTK_Samples_Length:		dc.l		0
MGTK_Tracks_Length:			dc.l		0

MGTK_Sequence_Adr:			dc.l		0
MGTK_Music:				dc.l		0
MGTK_Music_Position:		dc.l		0
MGTK_Music_Length:			dc.l		0
MGTK_Music_Restart:			dc.l		0
MGTK_Initial_Tempo:			dc.l		0
MGTK_Initial_Speed:			dc.l		0
MGTK_Music_Tempo:			dc.l		0
MGTK_Music_Speed:			dc.l		0
MGTK_Music_Counter:			dc.l		0
						dc.l		0

MGTK_Restart_Loop:			dc.l		0
MGTK_Restart_Done:			dc.l		0
MGTK_Replay_Paused:			dc.l		0
MGTK_Replay_Stopped:		dc.l		0
MGTK_IT_Timer_Control:		dc.l		0
MGTK_IT_Timer_Data:			dc.l		0
MGTK_IT_Number:			dc.l		0
MGTK_IT_Counter:			dc.l		0
MGTK_Frequency_Divider:		dc.l		0
MGTK_Replay_Frequency:		dc.l		0

MGTK_Replay_Satured:		dc.l		0
MGTK_Replay_Problem:		dc.l		0
MGTK_Replay_In_Service:		dc.l		0

MGTK_Global_Volume:			dc.l		0
MGTK_Master_Volume_Left:		dc.l		0
MGTK_Master_Volume_Right:	dc.l		0

MGTK_Pattern_Position:		dc.l		0
MGTK_Pattern_Length:		dc.l		0

MGTK_Pattern_Loop_Counter:	dc.l		0
MGTK_Pattern_Loop_Position:	dc.l		0
MGTK_Pattern_Break_Position:	dc.l		0
MGTK_Position_Jump_Position:	dc.l		0
MGTK_Position_Jump_Flag:		dc.l		0
MGTK_Pattern_Loop_Flag:		dc.l		0
MGTK_Pattern_Break_Flag:		dc.l		0
MGTK_Pattern_Delay_Time:		dc.l		0

MGTK_Retour_Variable:		dc.l		0

DSP_New_Module_Adr:			dc.l		0
DSP_No_Music:				dc.l		0

MGTK_Voices:				dcb.b	5*Voice_Size,0
End_Voices:

Len_Buffer:				dc.l		FREQ_REPLAY/(DIV_TEMPO+1)
Length:					dc.l		650
Calc_Adr:					dc.l		Buffer
Old_Adr:					dc.l		Buffer
Buffer_Ptr:				dc.l		Buffer

Buffer:					dc.l		650*2			; 32000 Khz … 50 Hz 16 bits stereo
Buffer_End:
;-----------------------------------------------------------------------------------------------
			.68000
dspcode_end:	
;-----------------------------------------------------------------------------------------------
			data
Data_68000_Start:

MGTK_Panoramics_Table:	dc.w		$ff00,$ee11,$dd22,$cc33,$bb44,$aa55,$9966,$8080
					dc.w		$8080,$6699,$55aa,$44bb,$33cc,$22dd,$11ee,$00ff

MGTK_Sinus_Table:		dc.b		0,24,49,74,97,120,141,161,180,197,212,224
					dc.b		235,244,250,253,255,253,250,244,235,224
					dc.b		212,197,180,161,141,120,97,74,49,24


MGTK_Periods_Table:		IncBin	'INCLUDES/PERIODS.TAB'

MGTK_Track_0:			dcb.b	6,0						; Piste 0 = piste vide
Data_68000_End:

Module:				Incbin	'SOUNDS/TURRIGOL.MGT'
					even
					
					include	"includes/jag_tool.s"
					.print	"Mem Dsp   Taken : ",dspcode_end-dspcode_start
					.print	"Mem 68000 Taken : ",Data_68000_End-Data_68000_Start
		
		
		