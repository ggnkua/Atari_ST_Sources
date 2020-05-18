;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~			     *.MOD PLAYER , 100% CPU			     ~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	OUTPUT	CPU_MOD.BIN

;Sub-Program with Program Header , Relocatable , with DATA and BSS , Super mode.
;Reserve 80000 bytes free after the code

;Call TOS-Type:
;Error.B=CPU_MOD(Cmd.W,8_16.W,Mo_St.W,Freq.W,MOD_Ad.L,MOD_Ln.L)
;D0		 SP+4  SP+6   SP+8    SP+10  SP+12    SP+16

;Error= 0:No error
;      -1:Error (Power OFF ? , Incorrect module ? , No module ?)

;Cmd=	0:-
;	1:Power OFF/ON
;	2:Open new module at address=MOD_Ad and length=MOD_Ln
;	3:Pause/Play
;	4:Stop
;	5:Song position Reverse Search
;	6:Song position Forward Search
;	7:Fast Forward OFF/ON
;	8:Repeat mode OFF/ON

;8_16=	0:-
;	1:8 bits/16 bits

;Mo_St= 0:-
;	1:Mono/Stereo

;Freq=	0:-
;	1: 8195 Hz
;	2: 9834 Hz
;	3:12292 Hz
;	4:16390 Hz
;	5:19668 Hz
;	6:24585 Hz
;	7:32780 Hz
;	8:49170 Hz

********************************************************************************

OSC=1 ;for the oscilloscope

********************************************************************************

; 100% CPU yes, but the sound can be greatly enhanced by one of this DSP program :
; INVERSE.PRG ("IN"): no change for CPU_MOD
; MODX4V.PRG  ("M4"): in this case CPU_MOD send the 4 voices 8b separated:
; V0,V1,V2 and V3 in software but 2 voices stereo 8b in hardware.
; Mono mode will be emulated with an inversion of .5 on the 2 parameters.

; Functions for MODX4V.PRG:

*EXIT		   : MODX4V(0)
*INIT		   : MODX4V(1,InversionV0V1,InversionV2V3)
*SET INVERSION V0V1: MODX4V(2,InversionV0V1)
*SET INVERSION V2V3: MODX4V(3,InversionV2V3)

; How to call a DSP function:
; MOVE Parameter,HostPort ... as many as necessary like -(SP)
; then call by Host Command (10:0 11:1 12:2 13:3)

********************************************************************************

;Lengths
ModuleName  =20
SampleInfos =30
SampleName  =22
VoiceInfos  =4

;Offsets in the sample field
SampleLength	  =SampleName		; W
SampleFineTune	  =SampleLength+2	; B
SampleVolume	  =SampleFineTune+1	; B
SampleRepeatStart =SampleVolume+1	; W
SampleRepeatLength=SampleRepeatStart+2	; W

;Offsets for the general variables
VNote			=   0 ; W
VSample 		=   2 ; W
VEffect 		=   4 ; W
VEffectParameters	=   6 ; W
VDisable		=   8 ; B
VSampleStart		=  10 ; L
VSampleEnd		=  14 ; L
VSampleRepeatStart	=  18 ; L
VSampleRepeatEnd	=  22 ; L
VNoRetrig		=  26 ; B
VSamplePointerInt	=  28 ; L
VSamplePointerFrac	=  32 ; W
VSamplePointerEnd	=  34 ; L
VFineTune		=  38 ; W
VPitch			=  40 ; W
VVolume 		=  42 ; W
VArpeggioPointer	=  44 ; W
VArpeggioNote0		=  46 ; W
VArpeggioNote1		=  48 ; W
VArpeggioNote2		=  50 ; W
VTonePortamentoNote	=  52 ; W
VTonePortamentoStep	=  54 ; W
VTonePortamentoControl	=  56 ; B
VVibratoNote		=  58 ; W
VVibratoWaveform	=  60 ; W
VVibratoAmplitude	=  62 ; W
VVibratoStep		=  64 ; W
VVibratoPointer 	=  66 ; W
VVibratoControl 	=  68 ; B
VTremoloVolume		=  70 ; W
VTremoloWaveform	=  72 ; W
VTremoloAmplitude	=  74 ; W
VTremoloStep		=  76 ; W
VTremoloPointer 	=  78 ; W
VTremoloControl 	=  80 ; B
VSampleOffset		=  82 ; W
VPatternPosLoopStart	=  84 ; W
VPatternPosLoopCounter	=  86 ; W
VNoteRetrigDelay	=  88 ; W
VNoteCutDelay		=  90 ; W
VNotePlayDelay		=  92 ; W
VInvertRepeatLoopIncr	=  94 ; B
VInvertRepeatLoopPtFrc	=  95 ; B
VInvertRepeatLoopPtInt	=  96 ; L

BufferLengthMaxi=49170*125/33/50 ;le maxi

	M_
;vvv Here because we must be before the oscilloscope vvv
M_Bottom:
;*** MODULE ********************************************************************
;~~~ CONSTANTES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SAMPLE_NB   DS.W 1  ;15 ou 31
SONG_AD:    DS.L 1  ;ModuleAddress+ModuleName+SampleInfos*15+2 ou
		    ;ModuleAddress+ModuleName+SampleInfos*31+2
PATTERN_AD: DS.L 1  ;ModuleAddress+ModuleName+SampleInfos*15+2+128 ou
		    ;ModuleAddress+ModuleName+SampleInfos*31+2+128+4
SAMPLE_ADS: DS.L 31 ;d'apr‚s SampleInfos

;~~~ VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TIMER_BEAT		DS.W 1 ;(33-255) , 125 par d‚faut
TIMER_COUNT		DS.W 1 ;(1-32)	 ,   6 par d‚faut
TIMER_DELAY		DS.W 1 ;D‚compteur de TIMER_COUNT … 0
PATTERN_POSITION_DELAY	DS.W 1 ;D‚compteur d'analyses de lignes perdues
SONG_POSITION		DS.W 1 ;(0-127)
PATTERN_POSITION	DS.W 1 ;(0-63)
MODULE_BREAK		DS.B 1 ;0:Normal   -1:Stop demand‚
SONG_BREAK		DS.B 1 ;Drap.

;~~~ VARIABLES PAR VOIE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VOICE0: ;Longueur 127 maxi car adress‚e par (A5,d)

 ;Partition
.0	DS.W	1 ;Note (la derniŠre lue <>0)
.2	DS.W	1 ;Sample (le dernier lu <>0)
.4	DS.W	1 ;Effect
.6	DS.W	1 ;Parameters PQ

 ;Moteur
.8	DS.B	1 ;Disable (Non utilis‚)
	DS.B	1 ;0
.10	DS.L	1 ;Sample Start
.14	DS.L	1 ;Sample End (-1:STOP)
.18	DS.L	1 ;Sample Repeat Start
.22	DS.L	1 ;Sample Repeat End (-1:STOP)
.26	DS.B	1 ;No Retrig ( 0: Retrig Sample Pointer)
		  ;	     (-1: No Retrig)
	DS.B	1 ;0
.28	DS.L	1 ;Sample Pointer (INT)
.32	DS.W	1 ;Sample Pointer (FRAC)
.34	DS.L	1 ;Sample Pointer End (-1:STOP)
.38	DS.W	1 ;Fine Tune
.40	DS.W	1 ;Pitch
.42	DS.W	1 ;Volume

 ;Effets
.44	DS.W	1 ;Arpeggio Pointer (0,1,2)
.46	DS.W	1 ;Arpeggio Note0
.48	DS.W	1 ;Arpeggio Note1
.50	DS.W	1 ;Arpeggio Note2
.52	DS.W	1 ;Tone Portamento Note
.54	DS.W	1 ;Tone Portamento Pitch Slide Step
.56	DS.B	1 ;Tone Portamento Control (0:Continu  -1:Sur note)
	DS.B	1 ;0
.58	DS.W	1 ;Vibrato Note
.60	DS.W	1 ;Vibrato Waveform
.62	DS.W	1 ;Vibrato Amplitude
.64	DS.W	1 ;Vibrato Step
.66	DS.W	1 ;Vibrato Pointer
.68	DS.B	1 ;Vibrato Control (0:R‚initialiser  -1:Ne pas r‚initialiser)
	DS.B	1 ;0
.70	DS.W	1 ;Tremolo Volume
.72	DS.W	1 ;Tremolo Waveform
.74	DS.W	1 ;Tremolo Amplitude
.76	DS.W	1 ;Tremolo Step
.78	DS.W	1 ;Tremolo Pointer
.80	DS.B	1 ;Tremolo Control (0:R‚initialiser  -1:Ne pas r‚initialiser)
	DS.B	1 ;0
.82	DS.W	1 ;Sample Offset
.84	DS.W	1 ;Pattern Position Loop Start
.86	DS.W	1 ;Pattern Position Loop Counter
.88	DS.W	1 ;Note Retrig Delay
.90	DS.W	1 ;Note Cut    Delay
.92	DS.W	1 ;Note Play   Delay
	;Invert Repeat Loop n'est pas un effet ordinaire
	;Il est VALIDE EN PERMANENCE si:
	;Invert Repeat Loop Increment <>0
	;De plus les Samples utilis‚s seront MODIFIES IRREMEDIABLEMENT
.94	DS.B	1 ;Invert Repeat Loop Increment
.95	DS.B	1 ;Invert Repeat Loop Pointer (FRAC7b)
.96	DS.L	1 ;Invert Repeat Loop Pointer (INT)
VOICE1: DS.B	100
VOICE2: DS.B	100 ;doit ‚tre coupl‚e … la voie 1
VOICE3: DS.B	100 ;doit ‚tre coupl‚e … la voie 0
;*******************************************************************************

;*** Routines en service **************
VOICE0Routine	DS.L 1
VOICE1Routine	DS.L 1
VOICE2Routine	DS.L 1
VOICE3Routine	DS.L 1
VOICE0Offset	DS.W 1 ;Relatif au d‚but du tampon
VOICE1Offset	DS.W 1
VOICE2Offset	DS.W 1
VOICE3Offset	DS.W 1
;**************************************

;*** SAUVEGARDE **********************
REGS_ORG DS.W 16 ;Registres  d'origine
;*************************************

;*** PARAMETRES ***********************************
MODULE_AD	DS.L 1 ;Adresse  du *.MOD (0:Vide)
MODULE_LN	DS.L 1 ;Longueur du *.MOD
MODULE_ERROR	DS.B 1 ;0:No error  -1:Error
MODULE_PLAY	DS.B 1 ;0:Pause     -1:Play
MODULE_FAST	DS.B 1 ;0:Normal    -1:Fast
MODULE_REPEAT	DS.B 1 ;0:No repeat -1:Repeat
MODULE_8_16	DS.B 1 ;0:8 bits    -1:16 bits
MODULE_MO_ST	DS.B 1 ;0:Mono	    -1:Stereo
MODULE_FREQ	DS.W 1 ;Frequency (0-7)
;**************************************************
MODX4V_Ind:	DS.B 1 ;Indicateur de la pr‚sence de MODX4V.PRG
M_Top:
;^^^ 621 octets ^^^ pour 1000 maxi
	DS.B	1000-(M_Top-M_Bottom)
	P_
	BRA	INTERPRET

RetrigSample: ;Initialiser le pointeur
	MOVE.L	(A5,VSampleStart),(A5,VSamplePointerInt)
	CLR	(A5,VSamplePointerFrac)
	MOVE.L	(A5,VSampleEnd),(A5,VSamplePointerEnd)
	RTS

SetPitch: ;Ecrire le pitch
;E:D0=Pitch (V‚rifier la validit‚)
;E:A5=Voie
	MOVEQ	#96,D1 ;mini
	MOVE	#96+1024-1,D2 ;maxi
	CMP	D1,D0
	BLT.S	.aigu ;sign‚ car D0 peut d‚ja ‚tre <0 … cause d'un SUB
	CMP	D2,D0
	BHI.S	.grave
.1	MOVE	D0,(A5,VPitch)
	RTS

.aigu	MOVE	D1,D0
	BRA	.1

.grave	MOVE	D2,D0
	BRA	.1

Find_Note:
;E/S:D0=Note
;S:D3=Nombre de notes restantes dans la gamme (utile pour Arpeggio)
;S:A3=Note

 ;Rechercher sa position dans la gamme
	LEA	NOTES(PC),A0
	MOVEQ	#36-1,D3
.1	CMP	(A0)+,D0
	DBHS	D3,.1
	TST	D3
	BPL.S	.2
	MOVEQ	#0,D3
.2  ;Tenir compte du FineTune
	MOVE	(A5,VFineTune),D0
	BEQ.S	.3
	MULU	#36*2,D0
.3	LEA	(A0,-2,D0),A3
	MOVE	(A3),D0
	RTS

SetVolume: ;Ecrire le volume
;E:D0=Volume (V‚rifier la validit‚)
;E:A5=Voie
	MOVEQ	#0,D1  ;mini
	MOVEQ	#64,D2 ;maxi
	CMP	D1,D0
	BLT.S	.faible
	CMP	D2,D0
	BHI.S	.fort
.1	MOVE	D0,(A5,VVolume)
	RTS

.faible MOVE	D1,D0
	BRA	.1

.fort	MOVE	D2,D0
	BRA	.1

;~~~~~~~~~~~~~~~~ I N I T ~~~~~~~~~~~~~~~~

Init_Normal:
	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.f
 ;Nouvelle note
	SF	(A5,VNoRetrig)
	BSR	Find_Note
	BSR	SetPitch
.f	RTS

Init_Arpeggio:
	TST	(A5,VEffectParameters)
	BEQ	Init_Normal
	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.1
 ;Nouvelle note
	SF	(A5,VNoRetrig)
.2	BSR	Find_Note
	BSR	SetPitch
	CLR	(A5,VArpeggioPointer)
 ;Note de base
	MOVE	(A3),D0
	MOVE	D0,(A5,VArpeggioNote0)
 ;1Šre note d'accord
	MOVE	(A5,VEffectParameters),D1
	LSR	#4,D1
	CMP	D3,D1
	BHI.S	.3
	MOVE	(A3,D1*2),D2
.n1	MOVE	D2,(A5,VArpeggioNote1)
 ;2Šme note d'accord
	MOVE	(A5,VEffectParameters),D1
	ANDI	#$F,D1
	CMP	D3,D1
	BHI.S	.4
	MOVE	(A3,D1*2),D2
.n2	MOVE	D2,(A5,VArpeggioNote2)
	RTS

.1	MOVE	(A5,VNote),D0
	BRA	.2

.3	MOVE	D0,D2
	BRA	.n1

.4	MOVE	D0,D2
	BRA	.n2

Init_TonePorta:
	TST.B	(A5,VNoRetrig)
	BNE.S	.1
 ;Changement de sample ?
	CMP	(A5,VSample),D3
	BNE.S	.1
	ST	(A5,VNoRetrig)
.1	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.2
	BSR	Find_Note
	MOVE	D0,(A5,VTonePortamentoNote)
.2	MOVE	(A5,VEffectParameters),D0
	BEQ.S	.f
	MOVE	D0,(A5,VTonePortamentoStep)
.f	RTS

Init_Vibrato:
	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.1
 ;Nouvelle note
	SF	(A5,VNoRetrig)
 ;Initialiser Pointer
	TST.B	(A5,VVibratoControl)
	BNE.S	.2
	CLR	(A5,VVibratoPointer)
.2	BSR	Find_Note
	BSR	SetPitch
	MOVE	(A3),(A5,VVibratoNote)
 ;Initialiser Amplitude et Step
	MOVE	(A5,VEffectParameters),D0
	ANDI	#$F,D0
	BEQ.S	.3
	LSL	#1,D0 ;*2 (0 to 30 step 2)
	MOVE	D0,(A5,VVibratoAmplitude)
.3	MOVE	(A5,VEffectParameters),D0
	LSR	#4,D0
	BEQ.S	.f
	MOVE	D0,(A5,VVibratoStep) ;(0 to 15,amplitude maxi)
.f	RTS

.1	MOVE	(A5,VNote),D0
	BRA	.2

Init_TonePorta_VolumeSlide:
	TST.B	(A5,VNoRetrig)
	BNE.S	.1
 ;Changement de sample ?
	CMP	(A5,VSample),D3
	BNE.S	.1
	ST	(A5,VNoRetrig)
.1	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.f
	BSR	Find_Note
	MOVE	D0,(A5,VTonePortamentoNote)
.f	RTS

Init_Vibrato_VolumeSlide:
	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.1
 ;Nouvelle note
	SF	(A5,VNoRetrig)
 ;Initialiser Pointer
	TST.B	(A5,VVibratoControl)
	BNE.S	.2
	CLR	(A5,VVibratoPointer)
.2	BSR	Find_Note
	BSR	SetPitch
	MOVE	(A3),(A5,VVibratoNote)
	RTS

.1	MOVE	(A5,VNote),D0
	BRA	.2

Init_Tremolo:
	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.1
 ;Nouvelle note
	SF	(A5,VNoRetrig)
 ;Initialiser Pointer
	TST.B	(A5,VTremoloControl)
	BNE.S	.2
	CLR	(A5,VTremoloPointer)
.2	BSR	Find_Note
	BSR	SetPitch
	MOVE	(A5,VVolume),(A5,VTremoloVolume)
 ;Initialiser Amplitude et Step
	MOVE	(A5,VEffectParameters),D0
	ANDI	#$F,D0
	BEQ.S	.3
	LSL	#2,D0 ;*4 (0 to 60 step 4)
	MOVE	D0,(A5,VTremoloAmplitude)
.3	MOVE	(A5,VEffectParameters),D0
	LSR	#4,D0
	BEQ.S	.f
	MOVE	D0,(A5,VTremoloStep) ;(0 to 15,amplitude maxi)
.f	RTS

.1	MOVE	(A5,VNote),D0
	BRA	.2

Init_PhasorEffect:
	BRA	Init_Normal

Init_SampleOffset:
	MOVEQ	#0,D0
	MOVE	(A5,VEffectParameters),D0
	BEQ.S	.1
	MOVE	D0,(A5,VSampleOffset)
.1	MOVE	(A5,VSampleOffset),D0
	LSL	#8,D0
	MOVE.L	(A5,VSampleEnd),D1
	BMI.S	.f
	SUB.L	(A5,VSampleStart),D1
	CMP.L	D1,D0
	BHS.S	.f
	ADD.L	D0,(A5,VSampleStart)
.f	BRA	Init_Normal

Init_SongPositionJump:
	MOVE	(A5,VEffectParameters),D0
 ;Valide ?
	MOVEA.L SONG_AD(PC),A0
	CMP.B	(A0,-2),D0
	BHS.S	.stop
	LEA	SONG_POSITION(PC),A0
	MOVE	D0,(A0)
	LEA	PATTERN_POSITION(PC),A0
	CLR	(A0)
	LEA	SONG_BREAK(PC),A0
	ST	(A0)
.f	BRA	Init_Normal

.stop	BSR	STOP_OPT
	BRA	.f

Init_Volume:
	MOVE	(A5,VEffectParameters),D0
	BSR	SetVolume
	BRA	Init_Normal

Init_PatternBreak:
	LEA	SONG_POSITION(PC),A0
	MOVE	(A0),D0
	ADDQ	#1,D0
	MOVEA.L SONG_AD(PC),A1
	CMP.B	(A1,-2),D0
	BEQ.S	.stop
	MOVE	D0,(A0)
	LEA	PATTERN_POSITION(PC),A0
	MOVE	(A5,VEffectParameters),D0
	MOVE	D0,D1
	LSR	#4,D0
	MULU	#10,D0
	ANDI	#$F,D1
	ADD	D1,D0
	ANDI	#64-1,D0
	MOVE	D0,(A0)
	LEA	SONG_BREAK(PC),A0
	ST	(A0)
.f	BRA	Init_Normal

.stop	BSR	STOP_OPT
	BRA	.f

Init_FinePortamentoUp:
	MOVE	(A5,VPitch),D0
	MOVE	(A5,VEffectParameters),D1
	ANDI	#$F,D1 ;Q
	SUB	D1,D0
	BSR	SetPitch
	BRA	Init_Normal

Init_FinePortamentoDown:
	MOVE	(A5,VPitch),D0
	MOVE	(A5,VEffectParameters),D1
	ANDI	#$F,D1 ;Q
	ADD	D1,D0
	BSR	SetPitch
	BRA	Init_Normal

Init_TonePortamentoControl:
	MOVE	(A5,VEffectParameters),D0
	ANDI	#$F,D0 ;Q
	SNE	(A5,VTonePortamentoControl)
	BRA	Init_Normal

Init_VibratoWaveform:
	MOVE	(A5,VEffectParameters),D0
	BTST	#2,D0
	SNE	(A5,VVibratoControl)
	ANDI	#%11,D0
	MOVE	D0,(VVibratoWaveform)
	BRA	Init_Normal

Init_FineTune:
	MOVE	(A5,VEffectParameters),D0
	ANDI	#$F,D0 ;Q
	MOVE	D0,(A5,VFineTune)
	BRA	Init_Normal

Init_PatternPositionLoop:
	MOVE	(A5,VEffectParameters),D0
	ANDI	#$F,D0 ;Q
	BEQ.S	.setloop
	SUBQ	#1,(A5,VPatternPosLoopCounter)
	BMI.S	.1stloop
	BEQ.S	.f
.1	LEA	PATTERN_POSITION(PC),A0
	MOVE	(A5,VPatternPosLoopStart),(A0)
	LEA	SONG_BREAK(PC),A0
	ST	(A0)
.f	BRA	Init_Normal

.setloop:
	MOVE	PATTERN_POSITION(PC),(A5,VPatternPosLoopStart)
	BRA.S	.f

.1stloop:
	MOVE	D0,(A5,VPatternPosLoopCounter)
	BRA	.1

Init_TremoloWaveform:
	MOVE	(A5,VEffectParameters),D0
	BTST	#2,D0
	SNE	(A5,VTremoloControl)
	ANDI	#%11,D0
	MOVE	D0,(VTremoloWaveform)
	BRA	Init_Normal

Init_Stop:
	BSR	STOP_OPT
	BRA	Init_Normal

Init_NoteRetrig:
	MOVE	(A5,VEffectParameters),D0
	ANDI	#$F,D0 ;Q
	MOVE	D0,(A5,VNoteRetrigDelay)
	BSR	RetrigSample
	BRA	Init_Normal

Init_FineVolumeUp:
	MOVE	(A5,VVolume),D0
	MOVE	(A5,VEffectParameters),D1
	ANDI	#$F,D1 ;Q
	ADD	D1,D0
	BSR	SetVolume
	BRA	Init_Normal

Init_FineVolumeDown:
	MOVE	(A5,VVolume),D0
	MOVE	(A5,VEffectParameters),D1
	ANDI	#$F,D1 ;Q
	SUB	D1,D0
	BSR	SetVolume
	BRA	Init_Normal

Init_NoteCut:
	MOVE	(A5,VEffectParameters),D0
	ANDI	#$F,D0 ;Q
	MOVE	D0,(A5,VNoteCutDelay)
	BRA	Init_Normal

Init_NoteDelay:
	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.f
	ST	(A5,VNoRetrig)
	BSR	Find_Note
	BSR	SetPitch
	MOVE	(A5,VEffectParameters),D0
	ANDI	#$F,D0 ;Q
	MOVE	D0,(A5,VNotePlayDelay)
	BEQ	Init_Normal
.f	RTS

Init_PatternPositionDelay:
	MOVE	(A5,VEffectParameters),D0
	ANDI	#$F,D0 ;Q
	ADDQ	#1,D0
	LEA	PATTERN_POSITION_DELAY(PC),A0
	MOVE	D0,(A0)
	BRA	Init_Normal

Init_InvertRepeatLoop:
	MOVE	(A5,VEffectParameters),D0
	ANDI	#$F,D0 ;Q
	LEA	FUNK(PC),A0
	MOVE.B	(A0,D0),(A5,VInvertRepeatLoopIncr)
	BRA	Init_Normal

Tab_Init_ExtendCommand:
	DC.W	0
	DC.W	Init_FinePortamentoUp-Init_Normal
	DC.W	Init_FinePortamentoDown-Init_Normal
	DC.W	Init_TonePortamentoControl-Init_Normal
	DC.W	Init_VibratoWaveform-Init_Normal
	DC.W	Init_FineTune-Init_Normal
	DC.W	Init_PatternPositionLoop-Init_Normal
	DC.W	Init_TremoloWaveform-Init_Normal
	DC.W	Init_Stop-Init_Normal
	DC.W	Init_NoteRetrig-Init_Normal
	DC.W	Init_FineVolumeUp-Init_Normal
	DC.W	Init_FineVolumeDown-Init_Normal
	DC.W	Init_NoteCut-Init_Normal
	DC.W	Init_NoteDelay-Init_Normal
	DC.W	Init_PatternPositionDelay-Init_Normal
	DC.W	Init_InvertRepeatLoop-Init_Normal

Init_ExtendCommand:
	LEA	Tab_Init_ExtendCommand(PC),A0
	MOVE	(A5,VEffectParameters),D0
	LSR	#4,D0 ;P
	MOVE	(A0,D0*2),D0
	LEA	Init_Normal(PC),A0
	JMP	(A0,D0)

Init_SpeedSet:
	MOVE	(A5,VEffectParameters),D0
	BEQ	Init_Stop
	CMPI	 #32,D0
	BHI.S	.timer ;32 n'est pas un mode CIA
	LEA	TIMER_COUNT(PC),A0
	MOVE	D0,(A0)
	LEA	TIMER_DELAY(PC),A0
	MOVE	D0,(A0)
.f	BRA	Init_Normal

.timer	LEA	TIMER_BEAT(PC),A0
	MOVE	D0,(A0)
	BSR	I_BUFFER_ADS
	BRA	.f

Tab_Init_Effect:
	DC.W	Init_Arpeggio-Init_Normal
	DC.W	0
	DC.W	0
	DC.W	Init_TonePorta-Init_Normal
	DC.W	Init_Vibrato-Init_Normal
	DC.W	Init_TonePorta_VolumeSlide-Init_Normal
	DC.W	Init_Vibrato_VolumeSlide-Init_Normal
	DC.W	Init_Tremolo-Init_Normal
	DC.W	Init_PhasorEffect-Init_Normal
	DC.W	Init_SampleOffset-Init_Normal
	DC.W	0
	DC.W	Init_SongPositionJump-Init_Normal
	DC.W	Init_Volume-Init_Normal
	DC.W	Init_PatternBreak-Init_Normal
	DC.W	Init_ExtendCommand-Init_Normal
	DC.W	Init_SpeedSet-Init_Normal

INIT_EFFECT:
	LEA	Tab_Init_Effect(PC),A0
	MOVE	(A5,VEffect),D0
	MOVE	(A0,D0*2),D0
	LEA	Init_Normal(PC),A0
	JSR	(A0,D0)
	BRA	InvertRepeatLoop

;~~~~~~~~~~~~~~~~ F X ~~~~~~~~~~~~~~~~

NulEffect:
	RTS

Arpeggio: ;Accord simul‚
	TST	(A5,VEffectParameters)
	BEQ	NulEffect
 ;Rotation sur 3 notes
	MOVE	(A5,VArpeggioPointer),D0
	ADDQ	#1,D0
	CMPI	#2,D0
	BLS.S	.1
	MOVEQ	#0,D0
.1	MOVE	D0,(A5,VArpeggioPointer)
	MOVE	(A5,VArpeggioNote0,D0*2),D0
	BSR	SetPitch
	RTS

PortamentoUp: ;D‚rive de la fr‚quence ves les aigus
	MOVE	(A5,VPitch),D0
	SUB	(A5,VEffectParameters),D0
	BSR	SetPitch
	RTS

PortamentoDown: ;D‚rive de la fr‚quence vers les graves
	MOVE	(A5,VPitch),D0
	ADD	(A5,VEffectParameters),D0
	BSR	SetPitch
	RTS

TonePortamento: ;D‚rive de la fr‚quence … destination d'une note
	MOVE	(A5,VPitch),D0
	MOVE	(A5,VTonePortamentoNote),D1
	CMP	D1,D0
	BEQ.S	.f ;c'est fini !
	BHI.S	.moins
.plus	ADD	(A5,VTonePortamentoStep),D0
	CMP	D1,D0
	BLE.S	.1
.2	MOVE	D1,D0
.1 ;Control ?
	TST.B	(A5,VTonePortamentoControl)
	BEQ.S	.3
	BSR	Find_Note
.3	BSR	SetPitch
.f	RTS

.moins	SUB	(A5,VTonePortamentoStep),D0
	CMP	D1,D0
	BGE.S	.1 ;sign‚ car risque d'‚tre <0
	BRA	.2

Vibrato: ;Variation de la fr‚quence autour d'une valeur de base
 ;Calcul de l'abcisse
	MOVE	(A5,VVibratoPointer),D0
	ANDI	#%11111,D0 ;partie positive
	MOVE	(A5,VVibratoWaveform),D1
	BEQ.S	.sinus
	CMPI	#1,D1
	BEQ.S	.ramp
	CMPI	#2,D1
	BEQ.S	.square
.rand	LEA	RND(PC),A0
	MOVE.B	(A0,D0),D0
	BRA.S	.newfrq

.sinus	LEA	SINUS(PC),A0
	MOVE.B	(A0,D0),D0
	BRA.S	.newfrq

.ramp	LSL	#3,D0 ;pour fractionnel 8 bits
	BRA.S	.newfrq

.square ST	D0

.newfrq MULU	(A5,VVibratoAmplitude),D0
	LSR	#8,D0 ;Et hop:ENTIER
 ;A additionner ou soustraire ?
	BTST	#5,(A5,VVibratoPointer+1) ; bit de "signe" logique
	BNE.S	.moins
.plus	ADD	(A5,VVibratoNote),D0
	BSR	SetPitch
	BRA.S	.next
.moins	SUB	(A5,VVibratoNote),D0
	NEG	D0
	BSR	SetPitch
.next	MOVE	(A5,VVibratoStep),D0
	ADD	D0,(A5,VVibratoPointer)
	RTS

TonePortamento_VolumeSlide:
	BSR	TonePortamento
	BRA.S	VolumeSlide

Vibrato_VolumeSlide:
	BSR	Vibrato
	BRA.S	VolumeSlide

Tremolo: ;Variation de l'amplitude (volume) autour d'une valeur de base
 ;Calcul de l'abcisse
	MOVE	(A5,VTremoloPointer),D0
	ANDI	#%11111,D0 ;partie positive
	MOVE	(A5,VTremoloWaveform),D1
	BEQ.S	.sinus
	CMPI	#1,D1
	BEQ.S	.ramp
	CMPI	#2,D1
	BEQ.S	.square
.rand	LEA	RND(PC),A0
	MOVE.B	(A0,D0),D0
	BRA.S	.newvol

.sinus	LEA	SINUS(PC),A0
	MOVE.B	(A0,D0),D0
	BRA.S	.newvol

.ramp	LSL	#3,D0 ;pour fractionnel 8 bits
	BRA.S	.newvol

.square ST	D0

.newvol MULU	(A5,VTremoloAmplitude),D0
	LSR	#8,D0 ;Et hop:ENTIER
 ;A additionner ou soustraire ?
	BTST	#5,(A5,VTremoloPointer+1) ; bit de "signe" logique
	BNE.S	.moins
.plus	ADD	(A5,VTremoloVolume),D0
	BSR	SetVolume
	BRA.S	.next
.moins	SUB	(A5,VTremoloVolume),D0
	NEG	D0
	BSR	SetVolume
.next	MOVE	(A5,VTremoloStep),D0
	ADD	D0,(A5,VTremoloPointer)
	RTS

VolumeSlide: ;D‚rive du volume
	MOVE	(A5,VVolume),D0
	MOVE	(A5,VEffectParameters),D1
	MOVE	D1,D2
	LSR	#4,D1
	BEQ.S	.vdown
	ADD	D1,D0
	BSR	SetVolume
.f	RTS

.vdown	ANDI	#$F,D2
	SUB	D2,D0
	BSR	SetVolume
	BRA	.f

NoteRetrig:
	SUBQ	#1,(A5,VNoteRetrigDelay)
	BNE.S	.f
	MOVE	(A5,VEffectParameters),D0
	ANDI	#$F,D0 ;Q
	MOVE	D0,(A5,VNoteRetrigDelay)
 ;Dans le cas ou Q=0 on ne retrige pas
	BSR	RetrigSample
.f	RTS

NoteDelay:
	SUBQ	#1,(A5,VNotePlayDelay)
	BNE.S	.f
	BSR	RetrigSample
.f	RTS

NoteCut:
	SUBQ	#1,(A5,VNoteCutDelay)
	BNE.S	.f
	CLR	(A5,VVolume)
.f	RTS

InvertRepeatLoop:
 ;Appel‚ inconditionnellement
	MOVE.B	(A5,VInvertRepeatLoopIncr),D0
	BEQ.S	.f
	MOVE.L	(A5,VSampleRepeatEnd),D1
	BMI.S	.f
	ADD.B	D0,(A5,VInvertRepeatLoopPtFrc)
	BPL.S	.f
	CLR.B	(A5,VInvertRepeatLoopPtFrc)
	MOVE.L	(A5,VInvertRepeatLoopPtInt),D0
	BEQ.S	.f
	MOVEA.L D0,A0
	NEG.B	(A0)+
	CMPA.L	D1,A0
	BLO.S	.1
	MOVEA.L (A5,VSampleRepeatStart),A0
.1	MOVE.L	A0,(A5,VInvertRepeatLoopPtInt)
.f	RTS

Tab_ExtendCommand:
	DC.W	0
	DC.W	0
	DC.W	0
	DC.W	0
	DC.W	0
	DC.W	0
	DC.W	0
	DC.W	0
	DC.W	0
	DC.W	NoteRetrig-NulEffect
	DC.W	0
	DC.W	0
	DC.W	NoteCut-NulEffect
	DC.W	NoteDelay-NulEffect
	DC.W	0
	DC.W	0 ; Rien:Normal

ExtendCommand:
	LEA	Tab_ExtendCommand(PC),A0
	MOVE	(A5,VEffectParameters),D0
	LSR	#4,D0 ;P
	MOVE	(A0,D0*2),D0
	LEA	NulEffect(PC),A0
	JMP	(A0,D0)

Tab_Effect:
	DC.W	Arpeggio-NulEffect
	DC.W	PortamentoUp-NulEffect
	DC.W	PortamentoDown-NulEffect
	DC.W	TonePortamento-NulEffect
	DC.W	Vibrato-NulEffect
	DC.W	TonePortamento_VolumeSlide-NulEffect
	DC.W	Vibrato_VolumeSlide-NulEffect
	DC.W	Tremolo-NulEffect
	DC.W	0
	DC.W	0
	DC.W	VolumeSlide-NulEffect
	DC.W	0
	DC.W	0
	DC.W	0
	DC.W	ExtendCommand-NulEffect
	DC.W	0

EFFECT: LEA	Tab_Effect(PC),A0
	MOVE	(A5,VEffect),D0
	MOVE	(A0,D0*2),D0
	LEA	NulEffect(PC),A0
	JSR	(A0,D0)
	BRA	InvertRepeatLoop

;~~~~~~~~~~~~~~~~ E X I T ~~~~~~~~~~~~~~~~

Exit_NulEffect:
	RTS

Exit_Arpeggio:
	TST	(A5,VEffectParameters)
	BEQ.S	Exit_NulEffect
	MOVE	(A5,VArpeggioNote0),D0
	BSR	SetPitch
	RTS

Exit_Vibrato: ;Effets 4&6
	MOVE	(A5,VVibratoNote),D0
	BSR	SetPitch
	RTS

Exit_Tremolo:
	MOVE	(A5,VTremoloVolume),D0
	BSR	SetVolume
	RTS

;TOUT CELA SERA PEUT-ETRE UTILE ...
;
;Tab_Exit_Effect_ExtendCommand:
;	DC.W	0
;	DC.W	0
;	DC.W	0
;	DC.W	0
;	DC.W	0
;	DC.W	0
;	DC.W	0
;	DC.W	0
;	DC.W	0
;	DC.W	0
;	DC.W	0
;	DC.W	0
;	DC.W	0
;	DC.W	0
;	DC.W	0
;	DC.W	0
;
;Exit_ExtendCommand:
;	LEA	Tab_Exit_Effect_ExtendCommand(PC),A0
;	MOVE	(A5,VEffectParameters),D0
;	LSR	#4,D0 ;P
;	MOVE	(A0,D0*2),D0
;	LEA	Exit_NulEffect(PC),A0
;	JMP	(A0,D0)

Tab_Exit_Effect:
	DC.W	Exit_Arpeggio-Exit_NulEffect
	DC.W	0
	DC.W	0
	DC.W	0
	DC.W	Exit_Vibrato-Exit_NulEffect
	DC.W	0
	DC.W	Exit_Vibrato-Exit_NulEffect
	DC.W	Exit_Tremolo-Exit_NulEffect
	DC.W	0
	DC.W	0
	DC.W	0
	DC.W	0
	DC.W	0
	DC.W	0
	DC.W	0 ;Rien:NORMAL
	DC.W	0

EXIT_EFFECT:
	LEA	Tab_Exit_Effect(PC),A0
	MOVE	(A5,VEffect),D0
	MOVE	(A0,D0*2),D0
	LEA	Exit_NulEffect(PC),A0
	JMP	(A0,D0)

ANALYSE_VOICE:
;A6=MODULE
;A5=VOICE
;A4=Infos voie
.note	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.sample
	MOVE	D0,(A5,VNote)
.sample MOVE.B	(A4),D0
	ANDI	#$10,D0 ;Dans le cas de MOD … 31 samples
	MOVEQ	#0,D1
	MOVE.B	(A4,2),D1
	LSR	#4,D1
	OR	D1,D0
	AND	SAMPLE_NB(PC),D0
	SEQ	(A5,VNoRetrig)
	BEQ	.effect
 ;Nouveau sample
	MOVE	(A5,VSample),D3 ;Servira … Init_TonePorta
	MOVE	D0,(A5,VSample)
	SUBQ	#1,D0
	LEA	SAMPLE_ADS(PC),A0
	MOVEA.L (A0,D0*4),A0
	MOVE.L	A0,(A5,VSampleStart)
	MULU	#SampleInfos,D0
	LEA	(A6,ModuleName,D0),A1
	MOVE	(A1,SampleLength),D0 ;le mot sup. est d‚ja … 0
	BEQ.S	.1
	LEA	(A0,D0.L*2),A2
	MOVE.L	A2,(A5,VSampleEnd)
	MOVE	(A1,SampleRepeatStart),D0
	LEA	(A0,D0.L*2),A2
	MOVE.L	A2,(A5,VSampleRepeatStart)
	MOVE	(A1,SampleRepeatLength),D0
	CMPI	#1,D0
 ;pour ‚viter la perte de puissance il faudrait
 ;‚viter les boucles courtes (<10 par ex.)
	BLS.S	.2
	LEA	(A2,D0.L*2),A2
	MOVE.L	A2,(A5,VSampleRepeatEnd)
.3	MOVE.B	(A1,SampleFineTune),D0
	ANDI	#$F,D0
	MOVE	D0,(A5,VFineTune)
	MOVE.B	(A1,SampleVolume),D0
	MOVEQ	#64,D1
	CMP	D1,D0
	BLS.S	.4
	MOVE	D1,D0
.4	MOVE	D0,(A5,VVolume)

 ;Pour l'effet Invert Repeat Loop
	MOVE.L	(A5,VSampleRepeatStart),(A5,VInvertRepeatLoopPtInt)
	CLR.B	(A5,VInvertRepeatLoopPtFrc)
	BRA.S	.effect

.1	MOVEQ	#-1,D0
	MOVE.L	D0,(A5,VSampleEnd)
	MOVE.L	A0,(A5,VSampleRepeatStart)
	MOVE.L	D0,(A5,VSampleRepeatEnd)
	BRA.S	.3

.2	MOVEQ	#-1,D0
	MOVE.L	D0,(A5,VSampleRepeatEnd)
	BRA	.3

.effect BSR	EXIT_EFFECT
	MOVE.B	(A4,2),D0
	ANDI	#$F,D0
	MOVE	D0,(A5,VEffect)
	MOVE.B	(A4,3),D0
	MOVE	D0,(A5,VEffectParameters)
	BSR	INIT_EFFECT

.retrig TST.B	(A5,VNoRetrig)
	BNE.S	.f
	BSR	RetrigSample
.f	RTS

ANALYSE_LINE:
	MOVEA.L MODULE_AD(PC),A6
	MOVE.B	MODULE_FAST(PC),D0 ;Option externe
	BNE.S	.ana
	LEA	TIMER_DELAY(PC),A0
	SUBQ	#1,(A0)
	BNE	.effect
	MOVE	TIMER_COUNT(PC),(A0)
	LEA	PATTERN_POSITION_DELAY(PC),A0
	TST	(A0)
	BEQ.S	.ana
	SUBQ	#1,(A0)
	BRA	.effect
.ana ;Adresse du 1er VoiceInfos
	MOVEA.L PATTERN_AD(PC),A4
	MOVEA.L SONG_AD(PC),A0
	MOVE	SONG_POSITION(PC),D0
	MOVEQ	#0,D1
	MOVE.B	(A0,D0),D1
	LSL.L	#8,D1
	LSL.L	#2,D1 ;*1024
	ADDA.L	D1,A4
	MOVE	PATTERN_POSITION(PC),D0
	LSL	#4,D0 ;*16
	ADDA	D0,A4
 ;Pas de fin automatique
	LEA	SONG_BREAK(PC),A0
	SF	(A0)
	LEA	VOICE0(PC),A5
	BSR	ANALYSE_VOICE
	ADDA	#VoiceInfos,A4
	LEA	VOICE1(PC),A5
	BSR	ANALYSE_VOICE
	ADDA	#VoiceInfos,A4
	LEA	VOICE2(PC),A5
	BSR	ANALYSE_VOICE
	ADDA	#VoiceInfos,A4
	LEA	VOICE3(PC),A5
	BSR	ANALYSE_VOICE
 ;Fin automatique ?
	LEA	SONG_BREAK(PC),A0
	TST.B	(A0)
	BNE.S	.f
	LEA	PATTERN_POSITION(PC),A0
	ADDQ	#1,(A0)
	CMPI	#64,(A0)
	BNE.S	.f
 ;pattern suivant
	CLR	(A0)
	LEA	SONG_POSITION(PC),A0
	MOVE	(A0),D0
	ADDQ	#1,D0
	MOVEA.L SONG_AD(PC),A2
	CMP.B	-2(A2),D0
	BHS	STOP_OPT
	MOVE	D0,(A0)
.f	RTS

.effect LEA	VOICE0(PC),A5
	BSR	EFFECT
	LEA	VOICE1(PC),A5
	BSR	EFFECT
	LEA	VOICE2(PC),A5
	BSR	EFFECT
	LEA	VOICE3(PC),A5
	BSR	EFFECT
	BRA	.f

;~~~ ROUTINES VOICE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  D3=Increment (FRAC)
;  D4=Increment (INT)
;  D5=Pointer	(FRAC)
;  D6=Pointer	(INT)
;  D7=Nombre d'‚chantillons
;  A3=Table des niveaux
;  A4=Pointer end
;E:A5=Voice
;E:A6=Track
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

VOICE_8bMonoMove:
	MOVE	BUFFER_LN(PC),D7
	SUBQ	#1,D7
	MOVE.L	(A5,VSamplePointerEnd),D0
	MOVEA.L D0,A4
	BEQ.S	.V0 ;Au d‚part=0
	BMI.S	.V0
	MOVE.L	(A5,VSamplePointerInt),D6
	MOVE	(A5,VSamplePointerFrac),D5
	LEA	INCREMENTS(PC),A0
	MOVE	(A5,VPitch),D0
	SUBI	#96,D0
	BMI.S	.V0 ;S‚curit‚
	MOVEQ	#0,D4
	MOVE	(A0,D0*4),D4
	MOVE	(A0,D0*4,2),D3
.lvl	LEA	LEVELS_AD(PC),A0
	ADDA.L	(A0),A0
	MOVE	(A5,VVolume),D0
	LSL	#8,D0 ;*256
	LEA	(A0,D0),A3
	MOVEQ	#0,D0 ;Sert sur 16 bits
	BRA.S	.MUSIK

.V0:	LEA	-1,A4
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.lvl

.MUSIK: MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),(A6)+
 ;Au suivant
	ADD	D3,D5
	ADDX.L	D4,D6
 ;Adresse valide ?
.vad	CMP.L	A4,D6
	BHS.S	.rep
.svt	DBRA	D7,.MUSIK

 ;Remettre les pointeurs
	MOVE.L	D6,(A5,VSamplePointerInt)
	MOVE	D5,(A5,VSamplePointerFrac)
	MOVE.L	A4,(A5,VSamplePointerEnd)
	RTS

.rep:	MOVE.L	(A5,VSampleRepeatEnd),D1
	BMI.S	.V0bis
	SUB.L	A4,D6
	ADD.L	(A5,VSampleRepeatStart),D6
	MOVEA.L D1,A4
	BRA	.vad

.V0bis: MOVEA.L D1,A4 ;=-1
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.svt

VOICE_8bMonoAdd:
	MOVE	BUFFER_LN(PC),D7
	SUBQ	#1,D7
	MOVE.L	(A5,VSamplePointerEnd),D0
	MOVEA.L D0,A4
	BEQ.S	.V0 ;Au d‚part=0
	BMI.S	.V0
	MOVE.L	(A5,VSamplePointerInt),D6
	MOVE	(A5,VSamplePointerFrac),D5
	LEA	INCREMENTS(PC),A0
	MOVE	(A5,VPitch),D0
	SUBI	#96,D0
	BMI.S	.V0 ;S‚curit‚
	MOVEQ	#0,D4
	MOVE	(A0,D0*4),D4
	MOVE	(A0,D0*4,2),D3
.lvl	LEA	LEVELS_AD(PC),A0
	ADDA.L	(A0),A0
	MOVE	(A5,VVolume),D0
	LSL	#8,D0 ;*256
	LEA	(A0,D0),A3
	MOVEQ	#0,D0 ;Sert sur 16 bits
	BRA.S	.MUSIK

.V0:	LEA	-1,A4
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.lvl

.MUSIK: MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),D1
	ADD.B	D1,(A6)+
 ;Au suivant
	ADD	D3,D5
	ADDX.L	D4,D6
 ;Adresse valide ?
.vad	CMP.L	A4,D6
	BHS.S	.rep
.svt	DBRA	D7,.MUSIK

 ;Remettre les pointeurs
	MOVE.L	D6,(A5,VSamplePointerInt)
	MOVE	D5,(A5,VSamplePointerFrac)
	MOVE.L	A4,(A5,VSamplePointerEnd)
	RTS

.rep:	MOVE.L	(A5,VSampleRepeatEnd),D1
	BMI.S	.V0bis
	SUB.L	A4,D6
	ADD.L	(A5,VSampleRepeatStart),D6
	MOVEA.L D1,A4
	BRA	.vad

.V0bis: MOVEA.L D1,A4 ;=-1
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.svt

VOICE_8bStereoMove:
	MOVE	BUFFER_LN(PC),D7
	SUBQ	#1,D7
	MOVE.L	(A5,VSamplePointerEnd),D0
	MOVEA.L D0,A4
	BEQ.S	.V0 ;Au d‚part=0
	BMI.S	.V0
	MOVE.L	(A5,VSamplePointerInt),D6
	MOVE	(A5,VSamplePointerFrac),D5
	LEA	INCREMENTS(PC),A0
	MOVE	(A5,VPitch),D0
	SUBI	#96,D0
	BMI.S	.V0 ;S‚curit‚
	MOVEQ	#0,D4
	MOVE	(A0,D0*4),D4
	MOVE	(A0,D0*4,2),D3
.lvl	LEA	LEVELS_AD(PC),A0
	ADDA.L	(A0),A0
	MOVE	(A5,VVolume),D0
	LSL	#8,D0 ;*256
	LEA	(A0,D0),A3
	MOVEQ	#0,D0 ;Sert sur 16 bits
	BRA.S	.MUSIK

.V0:	LEA	-1,A4
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.lvl

.MUSIK: MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),(A6)+
	ADDQ	#1,A6 ;Sauter l'autre voie
 ;Au suivant
	ADD	D3,D5
	ADDX.L	D4,D6
 ;Adresse valide ?
.vad	CMP.L	A4,D6
	BHS.S	.rep
.svt	DBRA	D7,.MUSIK

 ;Remettre les pointeurs
	MOVE.L	D6,(A5,VSamplePointerInt)
	MOVE	D5,(A5,VSamplePointerFrac)
	MOVE.L	A4,(A5,VSamplePointerEnd)
	RTS

.rep:	MOVE.L	(A5,VSampleRepeatEnd),D1
	BMI.S	.V0bis
	SUB.L	A4,D6
	ADD.L	(A5,VSampleRepeatStart),D6
	MOVEA.L D1,A4
	BRA	.vad

.V0bis: MOVEA.L D1,A4 ;=-1
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.svt

VOICE_8bStereoAdd:
	MOVE	BUFFER_LN(PC),D7
	SUBQ	#1,D7
	MOVE.L	(A5,VSamplePointerEnd),D0
	MOVEA.L D0,A4
	BEQ.S	.V0 ;Au d‚part=0
	BMI.S	.V0
	MOVE.L	(A5,VSamplePointerInt),D6
	MOVE	(A5,VSamplePointerFrac),D5
	LEA	INCREMENTS(PC),A0
	MOVE	(A5,VPitch),D0
	SUBI	#96,D0
	BMI.S	.V0 ;S‚curit‚
	MOVEQ	#0,D4
	MOVE	(A0,D0*4),D4
	MOVE	(A0,D0*4,2),D3
.lvl	LEA	LEVELS_AD(PC),A0
	ADDA.L	(A0),A0
	MOVE	(A5,VVolume),D0
	LSL	#8,D0 ;*256
	LEA	(A0,D0),A3
	MOVEQ	#0,D0 ;Sert sur 16 bits
	BRA.S	.MUSIK

.V0:	LEA	-1,A4
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.lvl

.MUSIK: MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),D1
	ADD.B	D1,(A6)+
	ADDQ	#1,A6 ;Sauter l'autre voie
 ;Au suivant
	ADD	D3,D5
	ADDX.L	D4,D6
 ;Adresse valide ?
.vad	CMP.L	A4,D6
	BHS.S	.rep
.svt	DBRA	D7,.MUSIK

 ;Remettre les pointeurs
	MOVE.L	D6,(A5,VSamplePointerInt)
	MOVE	D5,(A5,VSamplePointerFrac)
	MOVE.L	A4,(A5,VSamplePointerEnd)
	RTS

.rep:	MOVE.L	(A5,VSampleRepeatEnd),D1
	BMI.S	.V0bis
	SUB.L	A4,D6
	ADD.L	(A5,VSampleRepeatStart),D6
	MOVEA.L D1,A4
	BRA	.vad

.V0bis: MOVEA.L D1,A4 ;=-1
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.svt

VOICE_16bMonoMove:
	MOVE	BUFFER_LN(PC),D7
	SUBQ	#1,D7
	MOVE.L	(A5,VSamplePointerEnd),D0
	MOVEA.L D0,A4
	BEQ.S	.V0 ;Au d‚part=0
	BMI.S	.V0
	MOVE.L	(A5,VSamplePointerInt),D6
	MOVE	(A5,VSamplePointerFrac),D5
	LEA	INCREMENTS(PC),A0
	MOVE	(A5,VPitch),D0
	SUBI	#96,D0
	BMI.S	.V0 ;S‚curit‚
	MOVEQ	#0,D4
	MOVE	(A0,D0*4),D4
	MOVE	(A0,D0*4,2),D3
.lvl	LEA	LEVELS_AD(PC),A0
	ADDA.L	(A0),A0
	MOVE	(A5,VVolume),D0
	LSL	#8,D0 ;*256
	LEA	(A0,D0*2),A3
	MOVEQ	#0,D0 ;Sert sur 16 bits
	BRA.S	.MUSIK

.V0:	LEA	-1,A4
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.lvl

.MUSIK: MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE	(A3,D0*2),(A6)+
	ADDQ	#2,A6 ;Sauter l'autre voie
 ;Au suivant
	ADD	D3,D5
	ADDX.L	D4,D6
 ;Adresse valide ?
.vad	CMP.L	A4,D6
	BHS.S	.rep
.svt	DBRA	D7,.MUSIK

 ;Remettre les pointeurs
	MOVE.L	D6,(A5,VSamplePointerInt)
	MOVE	D5,(A5,VSamplePointerFrac)
	MOVE.L	A4,(A5,VSamplePointerEnd)
	RTS

.rep:	MOVE.L	(A5,VSampleRepeatEnd),D1
	BMI.S	.V0bis
	SUB.L	A4,D6
	ADD.L	(A5,VSampleRepeatStart),D6
	MOVEA.L D1,A4
	BRA	.vad

.V0bis: MOVEA.L D1,A4 ;=-1
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.svt

VOICE_16bMonoAdd:
	MOVE	BUFFER_LN(PC),D7
	SUBQ	#1,D7
	MOVE.L	(A5,VSamplePointerEnd),D0
	MOVEA.L D0,A4
	BEQ.S	.V0 ;Au d‚part=0
	BMI.S	.V0
	MOVE.L	(A5,VSamplePointerInt),D6
	MOVE	(A5,VSamplePointerFrac),D5
	LEA	INCREMENTS(PC),A0
	MOVE	(A5,VPitch),D0
	SUBI	#96,D0
	BMI.S	.V0 ;S‚curit‚
	MOVEQ	#0,D4
	MOVE	(A0,D0*4),D4
	MOVE	(A0,D0*4,2),D3
.lvl	LEA	LEVELS_AD(PC),A0
	ADDA.L	(A0),A0
	MOVE	(A5,VVolume),D0
	LSL	#8,D0 ;*256
	LEA	(A0,D0*2),A3
	MOVEQ	#0,D0 ;Sert sur 16 bits
	BRA.S	.MUSIK

.V0:	LEA	-1,A4
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.lvl

.MUSIK: MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE	(A3,D0*2),D1
	ADD	D1,(A6)
	MOVE	(A6)+,(A6)+ ;Recopier l'autre voie
 ;Au suivant
	ADD	D3,D5
	ADDX.L	D4,D6
 ;Adresse valide ?
.vad	CMP.L	A4,D6
	BHS.S	.rep
.svt	DBRA	D7,.MUSIK

 ;Remettre les pointeurs
	MOVE.L	D6,(A5,VSamplePointerInt)
	MOVE	D5,(A5,VSamplePointerFrac)
	MOVE.L	A4,(A5,VSamplePointerEnd)
	RTS

.rep:	MOVE.L	(A5,VSampleRepeatEnd),D1
	BMI.S	.V0bis
	SUB.L	A4,D6
	ADD.L	(A5,VSampleRepeatStart),D6
	MOVEA.L D1,A4
	BRA	.vad

.V0bis: MOVEA.L D1,A4 ;=-1
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.svt

VOICE_16bStereoMove:
	MOVE	BUFFER_LN(PC),D7
	SUBQ	#1,D7
	MOVE.L	(A5,VSamplePointerEnd),D0
	MOVEA.L D0,A4
	BEQ.S	.V0 ;Au d‚part=0
	BMI.S	.V0
	MOVE.L	(A5,VSamplePointerInt),D6
	MOVE	(A5,VSamplePointerFrac),D5
	LEA	INCREMENTS(PC),A0
	MOVE	(A5,VPitch),D0
	SUBI	#96,D0
	BMI.S	.V0 ;S‚curit‚
	MOVEQ	#0,D4
	MOVE	(A0,D0*4),D4
	MOVE	(A0,D0*4,2),D3
.lvl	LEA	LEVELS_AD(PC),A0
	ADDA.L	(A0),A0
	MOVE	(A5,VVolume),D0
	LSL	#8,D0 ;*256
	LEA	(A0,D0*2),A3
	MOVEQ	#0,D0 ;Sert sur 16 bits
	BRA.S	.MUSIK

.V0:	LEA	-1,A4
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.lvl

.MUSIK: MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE	(A3,D0*2),(A6)+
	ADDQ	#2,A6 ;Sauter l'autre voie
 ;Au suivant
	ADD	D3,D5
	ADDX.L	D4,D6
 ;Adresse valide ?
.vad	CMP.L	A4,D6
	BHS.S	.rep
.svt	DBRA	D7,.MUSIK

 ;Remettre les pointeurs
	MOVE.L	D6,(A5,VSamplePointerInt)
	MOVE	D5,(A5,VSamplePointerFrac)
	MOVE.L	A4,(A5,VSamplePointerEnd)
	RTS

.rep:	MOVE.L	(A5,VSampleRepeatEnd),D1
	BMI.S	.V0bis
	SUB.L	A4,D6
	ADD.L	(A5,VSampleRepeatStart),D6
	MOVEA.L D1,A4
	BRA	.vad

.V0bis: MOVEA.L D1,A4 ;=-1
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.svt

VOICE_16bStereoAdd:
	MOVE	BUFFER_LN(PC),D7
	SUBQ	#1,D7
	MOVE.L	(A5,VSamplePointerEnd),D0
	MOVEA.L D0,A4
	BEQ.S	.V0 ;Au d‚part=0
	BMI.S	.V0
	MOVE.L	(A5,VSamplePointerInt),D6
	MOVE	(A5,VSamplePointerFrac),D5
	LEA	INCREMENTS(PC),A0
	MOVE	(A5,VPitch),D0
	SUBI	#96,D0
	BMI.S	.V0 ;S‚curit‚
	MOVEQ	#0,D4
	MOVE	(A0,D0*4),D4
	MOVE	(A0,D0*4,2),D3
.lvl	LEA	LEVELS_AD(PC),A0
	ADDA.L	(A0),A0
	MOVE	(A5,VVolume),D0
	LSL	#8,D0 ;*256
	LEA	(A0,D0*2),A3
	MOVEQ	#0,D0 ;Sert sur 16 bits
	BRA.S	.MUSIK

.V0:	LEA	-1,A4
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.lvl

.MUSIK: MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE	(A3,D0*2),D1
	ADD	D1,(A6)+
	ADDQ	#2,A6 ;Sauter l'autre voie
 ;Au suivant
	ADD	D3,D5
	ADDX.L	D4,D6
 ;Adresse valide ?
.vad	CMP.L	A4,D6
	BHS.S	.rep
.svt	DBRA	D7,.MUSIK

 ;Remettre les pointeurs
	MOVE.L	D6,(A5,VSamplePointerInt)
	MOVE	D5,(A5,VSamplePointerFrac)
	MOVE.L	A4,(A5,VSamplePointerEnd)
	RTS

.rep:	MOVE.L	(A5,VSampleRepeatEnd),D1
	BMI.S	.V0bis
	SUB.L	A4,D6
	ADD.L	(A5,VSampleRepeatStart),D6
	MOVEA.L D1,A4
	BRA	.vad

.V0bis: MOVEA.L D1,A4 ;=-1
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.svt

VOICE_4V8b:
	MOVE	BUFFER_LN(PC),D7
	SUBQ	#1,D7
	MOVE.L	(A5,VSamplePointerEnd),D0
	MOVEA.L D0,A4
	BEQ.S	.V0 ;Au d‚part=0
	BMI.S	.V0
	MOVE.L	(A5,VSamplePointerInt),D6
	MOVE	(A5,VSamplePointerFrac),D5
	LEA	INCREMENTS(PC),A0
	MOVE	(A5,VPitch),D0
	SUBI	#96,D0
	BMI.S	.V0 ;S‚curit‚
	MOVEQ	#0,D4
	MOVE	(A0,D0*4),D4
	MOVE	(A0,D0*4,2),D3
.lvl	LEA	LEVELS_AD(PC),A0
	ADDA.L	(A0),A0
	MOVE	(A5,VVolume),D0
	LSL	#8,D0 ;*256
	LEA	(A0,D0),A3
	MOVEQ	#0,D0 ;Sert sur 16 bits
	BRA.S	.MUSIK

.V0:	LEA	-1,A4
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.lvl

.MUSIK: MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),(A6)+
	;+++++++++++++++++++++++++++++++++++++++
	ADDQ	#3,A6 ;Sauter les 3 autres voies
	;+++++++++++++++++++++++++++++++++++++++
	;Seule diff‚rence par rapport … VOICE_8bMonoMove
 ;Au suivant
	ADD	D3,D5
	ADDX.L	D4,D6
 ;Adresse valide ?
.vad	CMP.L	A4,D6
	BHS.S	.rep
.svt	DBRA	D7,.MUSIK

 ;Remettre les pointeurs
	MOVE.L	D6,(A5,VSamplePointerInt)
	MOVE	D5,(A5,VSamplePointerFrac)
	MOVE.L	A4,(A5,VSamplePointerEnd)
	RTS

.rep:	MOVE.L	(A5,VSampleRepeatEnd),D1
	BMI.S	.V0bis
	SUB.L	A4,D6
	ADD.L	(A5,VSampleRepeatStart),D6
	MOVEA.L D1,A4
	BRA	.vad

.V0bis: MOVEA.L D1,A4 ;=-1
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.svt

MUSIC:	MOVE.L	A6,-(SP)
 ;prochain FRAME
	LEA	BUFFER_ADS+8+1(PC),A6
	MOVE.B	(A6)+,SND_BH+1
	MOVE.B	(A6)+,SND_BM+1
	MOVE.B	(A6)+,SND_BL+1
	ADDQ	#1,A6
	MOVE.B	(A6)+,SND_EH+1
	MOVE.B	(A6)+,SND_EM+1
	MOVE.B	(A6)+,SND_EL+1
 ;Niveau normal au plus t“t
	BCLR	#7,MFP_ISRA+1
	ANDI	#$FBFF,SR
 ;Sauvegarde totale
	MOVEM.L D0-A5,-(SP)
 ;Fini ?
	MOVE.B	MODULE_PLAY(PC),D0
	BEQ	MFin
 ;Saturation ?
	LEA	BUFFER_F(PC),A0
	TST.B	(A0) ;D‚ja en cours ?
	BNE	MFin
	ST	(A0) ;Interdire les empilages
 ;Lire la partition
	BSR	ANALYSE_LINE

	MOVE.B	MODULE_BREAK(PC),D0
	BEQ.S	.osc
	BSR	PAUSE
	BSR	I_VARS
	BSR	I_BUFFERS
	MOVE.B	MODULE_REPEAT(PC),D0
	BEQ	MFin
	BSR	PLAY
	BRA	MFin

.osc:	IIF OSC INCLUDE OSC.S ;Int‚grer une routine pour l'oscilloscope

	MOVEA.L BUFFER_ADS+8(PC),A6
	ADDA	VOICE0Offset(PC),A6
	LEA	VOICE0(PC),A5
	LEA	VOICE0Routine(PC),A0
	JSR	([A0])
	MOVEA.L BUFFER_ADS+8(PC),A6
	ADDA	VOICE1Offset(PC),A6
	LEA	VOICE1(PC),A5
	LEA	VOICE1Routine(PC),A0
	JSR	([A0])
	MOVEA.L BUFFER_ADS+8(PC),A6
	ADDA	VOICE2Offset(PC),A6
	LEA	VOICE2(PC),A5
	LEA	VOICE2Routine(PC),A0
	JSR	([A0])
	MOVEA.L BUFFER_ADS+8(PC),A6
	ADDA	VOICE3Offset(PC),A6
	LEA	VOICE3(PC),A5
	LEA	VOICE3Routine(PC),A0
	JSR	([A0])
 ;Commutation des tampons
	LEA	BUFFER_ADS(PC),A0
	MOVEM.L (A0),D0-D3
	EXG.L	D0,D2
	EXG.L	D1,D3
	MOVEM.L D0-D3,(A0)
	LEA	BUFFER_F(PC),A0
	SF	(A0)
MFin	MOVEM.L (SP)+,D0-A6
	RTE

PLAY:	LEA	MODULE_PLAY(PC),A0
	ST	(A0)
	ORI.B	#%11,SND_CR+1 ;FEU !!!
	RTS

PAUSE:	BCLR	#1,SND_CR+1 ;plus de mode continu
	LEA	MODULE_PLAY(PC),A0
	SF	(A0)
.1	BTST	#0,SND_CR+1
	BNE	.1
	RTS

STOP_OPT: ;Optionnel
	LEA	MODULE_BREAK(PC),A0
	ST	(A0)
	RTS

mod_inc: ;Module incorrect
	LEA	MODULE_ERROR(PC),A0
	ST	(A0)
	RTS

I_CONS: ;S:MODULE_ERROR
	MOVE.L	MODULE_AD(PC),D0
	BEQ	mod_inc
	MOVEA.L D0,A0 ;Adresse de d‚but
	MOVEA.L A0,A1
	ADDA.L	MODULE_LN(PC),A1 ;Adresse de fin
 ;Type 15 ou 31 samples ?
	MOVEQ	#15,D0
   ;Lire le chunk
	LEA	(A0,ModuleName+SampleInfos*31+2+128),A2
	CMPA.L	A1,A2
	BHS	mod_inc
	MOVE.L	(A2),D1
   ;Comparer avec la liste
	LEA	MODULE_IDS(PC),A2
.2	MOVE.L	(A2)+,D2
	BEQ.S	.1
	CMP.L	D1,D2
	BNE	.2
	MOVEQ	#31,D0
.1	LEA	SAMPLE_NB(PC),A2
	MOVE	D0,(A2)
	LEA	(A0,ModuleName+SampleInfos*15+2),A2
	CMPI	#31,D0
	BNE.S	.3
	ADDA	#SampleInfos*16,A2
.3	MOVE.L	A2,D1
	LEA	SONG_AD(PC),A2
	MOVE.L	D1,(A2)
	ADDI.L	#128,D1
	CMPI	#31,D0
	BNE.S	.4
	ADDQ.L	#4,D1
.4	CMP.L	A1,D1
	BHS	mod_inc
	LEA	PATTERN_AD(PC),A2
	MOVE.L	D1,(A2)
i_sample_ads ;et init SAMPLE_ADS
 ;Recherche du nombre de patterns ...
	MOVEA.L SONG_AD(PC),A2
   ;V‚rif. lg.
	MOVE.B	(A2,-2),D0
	BEQ	mod_inc
	SUBQ.B	#1,D0
	BMI	mod_inc
	MOVEQ	#0,D0
	MOVEQ	#128-1,D1
.1	MOVE.B	(A2)+,D2
	CMPI.B	#63,D2
	BHI	mod_inc
	CMP.B	D2,D0
	DBLO	D1,.1
	BHS.S	.2
	MOVE.B	D2,D0
	SUBQ	#1,D1
	BRA	.1
.2	ADDQ	#1,D0 ;D0 patterns
 ;... pour savoir o— d‚butent les samples
	LSL.L	#8,D0
	LSL.L	#2,D0 ;*1024
	ADD.L	PATTERN_AD(PC),D0
	LEA	(A0,ModuleName),A0
	LEA	SAMPLE_ADS(PC),A2
	MOVE	SAMPLE_NB(PC),D1
	SUBQ	#1,D1
.3	MOVE.L	D0,(A2)+
	MOVEQ	#0,D2
	MOVE	(A0,SampleLength),D2
	ADDA	#SampleInfos,A0
	LSL.L	#1,D2
	ADD.L	D2,D0
	CMP.L	A1,D0
	BHI	mod_inc
	DBF	D1,.3
rep_verif: ;V‚rifier la validit‚ des Repeat Loop et patcher si incoh‚rence
	MOVEA.L MODULE_AD(PC),A0
	LEA	(A0,ModuleName),A0
	MOVE	SAMPLE_NB(PC),D0
	SUBQ	#1,D0
.ss	MOVE	(A0,SampleLength),D1
	MOVE	(A0,SampleRepeatStart),D2
	CMP	D1,D2
	BHS.S	.1
	ADD	(A0,SampleRepeatLength),D2
	CMP	D1,D2
	BHI.S	.2
.3	ADDA	#SampleInfos,A0
	DBRA	D0,.ss
	LEA	MODULE_ERROR(PC),A0
	SF	(A0)
	RTS

.1	MOVE	#1,(A0,SampleRepeatLength)
	BRA	.3

.2	MOVE	D1,D2
	SUB	(A0,SampleRepeatStart),D2
	MOVE	D2,(A0,SampleRepeatLength)
	BRA	.3

I_VARS: ;Les variables g‚n‚rales
	LEA	TIMER_BEAT(PC),A0
	MOVE	#125,(A0)
	LEA	TIMER_COUNT(PC),A0
	MOVE	#6,(A0)
	LEA	TIMER_DELAY(PC),A0
	MOVE	#6,(A0)
	LEA	PATTERN_POSITION_DELAY(PC),A0
	CLR	(A0)
	LEA	SONG_POSITION(PC),A0
	CLR	(A0)
	LEA	PATTERN_POSITION(PC),A0
	CLR	(A0)
	LEA	MODULE_BREAK(PC),A0
	SF	(A0)
	;SONG_BREAK inutile
i_voices: ;... les variables voies
	LEA	VOICE0(PC),A0
	MOVE	#(VOICE1-VOICE0)*4/2-1,D0
.1	CLR	(A0)+
	DBRA	D0,.1
	RTS

I_BUFFER_ADS: ;Nouvelle longueur tampons
	LEA	BUFFER_LNS(PC),A0
	MOVE	TIMER_BEAT(PC),D0
	SUBI	#33,D0
	MOVE	(A0,D0*2),D0
	LEA	BUFFER_LN(PC),A0
	MOVE	D0,(A0)
	MOVE.B	MODX4V_Ind(PC),D1
	BEQ.S	.1
	LSL	#2,D0 ;4 Voies
	BRA.S	.3
.1	MOVE.B	MODULE_8_16(PC),D1
	BEQ.S	.2
	LSL	#2,D0
	BRA.S	.3 ;Pas de Mono en 16b
.2	MOVE.B	MODULE_MO_ST(PC),D1
	BEQ.S	.3
	LSL	#1,D0
.3	LEA	BUFFER_ADS(PC),A0
	MOVEA.L (A0)+,A1
	ADDA	D0,A1
	MOVE.L	A1,(A0)+
	MOVEA.L (A0)+,A1
	ADDA	D0,A1
	MOVE.L	A1,(A0)+
	RTS

I_BUFFERS: ;Table des longueurs de tampon BUFFER_LNS
	LEA	BUFFER_LNS(PC),A0
	LEA	GEN_BUFFER_LNS(PC),A1
	MOVE	MODULE_FREQ(PC),D0
	LEA	(A1,D0*4),A1
	MOVEQ	#33,D0
	MOVE	#(255-32)-1,D1
.1	MOVE.L	(A1),D2
	DIVU	D0,D2
	BCLR	#0,D2 ;S'assurer de la parit‚
	MOVE	D2,(A0)+
	ADDQ	#1,D0
	DBRA	D1,.1
	LEA	BUFFER_F(PC),A0
	SF	(A0)
 ;Tampons physique et logique
	LEA	BUFFER_ADS(PC),A0
	LEA	BUFFER_A(PC),A1
	MOVE.L	A1,(A0)
	LEA	BUFFER_B(PC),A1
	MOVE.L	A1,(A0,8)
	BSR	I_BUFFER_ADS
 ;Effacer les 2 tampons
	LEA	BUFFER_A(PC),A0
	MOVE	#BufferLengthMaxi*2-1,D0
.2	CLR.L	(A0)+
	DBRA	D0,.2
	RTS

I_INCREMENTS: ;Table des incr‚ments
	LEA	INCREMENTS(PC),A0
	LEA	GEN_INCREMENTS(PC),A1
	MOVE	MODULE_FREQ(PC),D0
	LEA	(A1,D0*4),A1
	MOVEQ	#96,D0
	MOVE	#1024-1,D1
	MOVEM.L  D3-D4,-(SP)
.1 ;R‚aliser la division sur les parties INT et FRAC
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE	(A1),D2
	MOVE	(A1,2),D3
	DIVU	D0,D2
	DIVU	D0,D3
 ;Convertir le reste significatif en FRAC
	SWAP	D2
	MOVEQ	#0,D4
	MOVE	D2,D4
	SWAP	D4
	DIVU	D0,D4
	SWAP	D2
 ;Collecter les parties INT et FRAC
	ADD	D3,D4
	MOVEQ	#0,D3
	ADDX	D3,D2
	MOVE	D2,(A0)+
	MOVE	D4,(A0)+
	ADDQ	#1,D0
	DBRA	D1,.1
	MOVEM.L (SP)+,D3-D4
	RTS

I_LEVELS: ;Tables des niveaux
	LEA	LEVELS_AD(PC),A0
	ADDA.L	(A0),A0
	MOVE.L	D3,-(SP) ;pour les calculs complexes ...
 ;D‚terminer l'amplitude:
  ;D0=0 :Pleine amplitude
  ;D0=1 :Demi	amplitude
  ;D0=2 :Quart	amplitude
	MOVEQ	#0,D0
	MOVE.B	MODX4V_Ind(PC),D1
	BNE.S	.8b
	MOVEQ	#1,D0
	MOVE.B	MODULE_MO_ST(PC),D1
	BNE.S	.8_16b
	MOVEQ	#2,D0
.8_16b	MOVE.B	MODULE_8_16(PC),D1
	BNE.S	.16b

.8b	ADDQ	#6,D0 ;Nbre de ASR
	ADDA.L	#65*256,A0
	MOVEQ	#65-1,D1 ;65 tables
.nt8b	MOVE	#256-1,D2 ;256 valeurs
.na8b	MOVE.B	D2,D3
	EXT.W	D3
	MULS	D1,D3
	ASR	D0,D3
	MOVE.B	D3,-(A0)
	DBF	D2,.na8b
	DBF	D1,.nt8b
.f	MOVE.L	(SP)+,D3
	RTS

.16b	SUBQ	#2,D0
	NEG	D0 ;Nbre de ASL
	ADDA.L	#65*256*2,A0
	MOVEQ	#65-1,D1 ;65 tables
.nt16b	MOVE	#256-1,D2 ;256 valeurs
.na16b	MOVE	D2,D3
	CMPI	#128,D3
	BLO.S	.pos
	SUBI	#256,D3 ;sign‚
.pos	MULS	D1,D3
	ASL	D0,D3
	MOVE	D3,-(A0)
	DBF	D2,.na16b
	DBF	D1,.nt16b
	BRA	.f

InitVOICERoutineOffset:
	LEA	VOICE0Routine(PC),A0
	LEA	VOICE0Offset(PC),A1
	MOVE.B	MODX4V_Ind(PC),D0
	BNE	.M4
	MOVE.B	MODULE_8_16(PC),D0
	BNE.S	.16
.8	MOVE.B	MODULE_MO_ST(PC),D0
	BNE.S	.8s

.8m	LEA	VOICE_8bMonoMove(PC),A2
	MOVE.L	A2,(A0)+
	LEA	VOICE_8bMonoAdd(PC),A2
	MOVE.L	A2,(A0)+
	MOVE.L	A2,(A0)+
	MOVE.L	A2,(A0)+
	CLR	(A1)+
	CLR	(A1)+
	CLR	(A1)+
	CLR	(A1)+
.f	RTS

.8s	LEA	VOICE_8bStereoMove(PC),A2
	MOVE.L	A2,(A0)+
	MOVE.L	A2,(A0)+
	LEA	VOICE_8bStereoAdd(PC),A2
	MOVE.L	A2,(A0)+
	MOVE.L	A2,(A0)+
	CLR	(A1)+
	MOVE	#1,(A1)+
	MOVE	#1,(A1)+
	CLR	(A1)+
	BRA	.f

.16	MOVE.B	MODULE_MO_ST(PC),D0
	BNE.S	.16s

.16m	LEA	VOICE_16bMonoMove(PC),A2
	MOVE.L	A2,(A0)+
	LEA	VOICE_16bMonoAdd(PC),A2
	MOVE.L	A2,(A0)+
	MOVE.L	A2,(A0)+
	MOVE.L	A2,(A0)+
	CLR	(A1)+
	CLR	(A1)+
	CLR	(A1)+
	CLR	(A1)+
	BRA	.f

.16s	LEA	VOICE_16bStereoMove(PC),A2
	MOVE.L	A2,(A0)+
	MOVE.L	A2,(A0)+
	LEA	VOICE_16bStereoAdd(PC),A2
	MOVE.L	A2,(A0)+
	MOVE.L	A2,(A0)+
	CLR	(A1)+
	MOVE	#2,(A1)+
	MOVE	#2,(A1)+
	CLR	(A1)+
	BRA	.f

.M4	LEA	VOICE_4V8b(PC),A2
	MOVE.L	A2,(A0)+
	MOVE.L	A2,(A0)+
	MOVE.L	A2,(A0)+
	MOVE.L	A2,(A0)+
	CLR	(A1)+
	MOVE	#1,(A1)+
	MOVE	#2,(A1)+
	MOVE	#3,(A1)+
	BRA	.f

	INCLUDE	M4.S

S_REGS: ;Sauvegarde
	ORI	#$0700,SR
	MOVE	SND_CR,D0
		BCLR	#1,SND_CR+1
.pause		BTST	#0,SND_CR+1
		BNE	.pause
	LEA	REGS_ORG(PC),A0
	MOVE	SND_XBARIN,(A0)+
	MOVE	SND_XBAROUT,(A0)+
	MOVE	SND_MODE1,(A0)+
	MOVE	SND_MODE2,(A0)+
	MOVE	SND_FREQ,(A0)+
	CLR.B	(A0)+
	MOVE.B	SND_BH+1,(A0)+
	MOVE.B	SND_BM+1,(A0)+
	MOVE.B	SND_BL+1,(A0)+
	CLR.B	(A0)+
	MOVE.B	SND_EH+1,(A0)+
	MOVE.B	SND_EM+1,(A0)+
	MOVE.B	SND_EL+1,(A0)+
	MOVE	MFP_DDR,(A0)+
	MOVE	MFP_AER,(A0)+
	MOVE	MFP_IERA,(A0)+
	MOVE	MFP_IMRA,(A0)+
	MOVE	D0,(A0)+
	MOVE.L	$100+15*4,(A0)+
	ANDI	#$FBFF,SR
	BSR	TestM4
	PW	#InversionV2V3ParDef
	PW	#InversionV0V1ParDef
	PW	#1
	BSR	MODX4V
	ADDQ	#6,SP
	RTS

R_REGS: ;Restitution
	ORI	#$0700,SR
	LEA	REGS_ORG(PC),A0
	MOVE	(A0)+,SND_XBARIN
	MOVE	(A0)+,SND_XBAROUT
	MOVE	(A0)+,SND_MODE1
	MOVE	(A0)+,SND_MODE2
	MOVE	(A0)+,SND_FREQ
	ADDQ	#1,A0
	MOVE.B	(A0)+,SND_BH+1
	MOVE.B	(A0)+,SND_BM+1
	MOVE.B	(A0)+,SND_BL+1
	ADDQ	#1,A0
	MOVE.B	(A0)+,SND_EH+1
	MOVE.B	(A0)+,SND_EM+1
	MOVE.B	(A0)+,SND_EL+1
	MOVE	(A0)+,MFP_DDR
	MOVE	(A0)+,MFP_AER
	MOVE	(A0)+,MFP_IERA
	MOVE	(A0)+,MFP_IMRA
	MOVE	(A0)+,SND_CR
	MOVE.L	(A0)+,$100+15*4
	ANDI	#$FBFF,SR
	PW	#0
	BSR	MODX4V
	ADDQ	#2,SP
	RTS

I_REGS: ;Selon le mode demand‚
	ORI	#$0700,SR
 ;XBAR
	LEA	SND_XBARIN,A0
	MOVE	(A0),D0
	ANDI	#%0000111111110000,D0
	ORI	#%1000000000001001,D0
	MOVE	D0,(A0)
* Laissons tomber SND_XBAROUT
*	LEA	SND_XBAROUT,A0
*	MOVE	(A0),D0
*	ANDI	#%0000111111111111,D0
*	ORI	#%1001000000000000,D0
*	MOVE	D0,(A0)
 ;DMA
	LEA	SND_MODE1,A0
	MOVE	(A0),D0
	ANDI	#%1100110000111100,D0
		;	 ~~~
	MOVE.B	MODX4V_Ind(PC),D1
	BEQ.S	.1
	BSET	#8,D0 ; 2 voies
	MOVE	D0,(A0)
 ;Initialiser MODX4V:
 ;Cr‚er un mode mono artificiel si mono demand‚
 ;sinon st‚r‚o avec valeurs par d‚faut
	MOVE	#InversionV0V1ParDef,D0
	MOVE	#InversionV2V3ParDef,D1
	MOVE.B	MODULE_MO_ST(PC),D2
	BNE.S	.m4
	MOVE	#InversionMono,D0
	MOVE	D0,D1
.m4	PW	D1
	PW	D0
	PW	#2
	BSR	MODX4V
	ADDQ	#4,SP
	PW	#3  ;Tordu non ?
	BSR	MODX4V
	ADDQ	#4,SP
	BRA.S	.sm2

.1	MOVE.B	MODULE_8_16(PC),D1
	BEQ.S	.2
	BSET	#6,D0
	BRA.S	.em1
.2	MOVE.B	MODULE_MO_ST(PC),D1
	BNE.S	.em1
	BSET	#7,D0
.em1	MOVE	D0,(A0)
 ;DAC avec XBAR et sans ADC
.sm2	LEA	SND_MODE2+1,A0
	MOVE.B	(A0),D0
	ANDI.B	#%11111100,D0
	ORI.B	#%00000010,D0
	MOVE.B	D0,(A0)
 ;FREQUENCY
	LEA	FREQ_DIV(PC),A0
	MOVE	MODULE_FREQ(PC),D0
	MOVE.B	(A0,D0),SND_FREQ+1
 ;FRAME
	LEA	BUFFER_ADS+1(PC),A0
	MOVE.B	(A0)+,SND_BH+1
	MOVE.B	(A0)+,SND_BM+1
	MOVE.B	(A0)+,SND_BL+1
	ADDQ	#1,A0
	MOVE.B	(A0)+,SND_EH+1
	MOVE.B	(A0)+,SND_EM+1
	MOVE.B	(A0)+,SND_EL+1
 ;MFP pour MFP_GPIPb7
	MOVEQ	#7,D0
	BCLR	D0,MFP_DDR+1
	BSET	D0,MFP_AER+1
	BSET	D0,MFP_IERA+1
	BSET	D0,MFP_IMRA+1
	LEA	MUSIC(PC),A0
	MOVE.L	A0,$100+15*4
 ;CONTROL pour MFP_GPIPb7 + divers
	LEA	SND_CR,A0
	MOVE	(A0),D0
	ANDI	#%1111000001001100,D0
	ORI	#%0000000100000000,D0
	MOVE	D0,(A0)
	ANDI	#$FBFF,SR
	RTS

I_PARAMS:
	LEA	MODULE_AD(PC),A0
	CLR.L	(A0)
	;MODULE_LN inutile
	LEA	MODULE_ERROR(PC),A0
	SF	(A0)
	LEA	MODULE_PLAY(PC),A0
	SF	(A0)
	LEA	MODULE_FAST(PC),A0
	SF	(A0)
	LEA	MODULE_REPEAT(PC),A0
	SF	(A0)
	LEA	MODULE_8_16(PC),A0
	SF	(A0)
	LEA	MODULE_MO_ST(PC),A0
	SF	(A0)
	LEA	MODULE_FREQ(PC),A0
	CLR	(A0)
	RTS

INTERPRET: ;Interpr‚tation des paramˆtres
	MOVE	(SP,4),D0
	BNE	cmd
	BRA	m8_16

pver	LEA	MODULE_POWER(PC),A0
	TST.B	(A0)
	BEQ.S	.err
	RTS

.err	ST	D0
	ADDQ	#4,SP ;Pop !
	RTS

tab_cmd:DC.W	0
	DC.W	open-powr
	DC.W	play-powr
	DC.W	stop-powr
	DC.W	sgrs-powr
	DC.W	sgfs-powr
	DC.W	fast-powr
	DC.W	rept-powr

powr	LEA	MODULE_POWER(PC),A0
	NOT.B	(A0)
	BEQ.S	.poff
.pon	BSR	S_REGS
	BSR	I_PARAMS
	BSR	I_VARS ;pour initialiser TIMER_BEAT
	BSR	I_BUFFERS
	BSR	I_INCREMENTS
	BSR	I_LEVELS
	BSR	InitVOICERoutineOffset
	BSR	I_REGS
	RTS
.poff	BSR	R_REGS
	RTS

open	BSR	pver
	BSR.S	stop
	LEA	MODULE_AD(PC),A0
	MOVE.L	(SP,4+12),(A0)
	LEA	MODULE_LN(PC),A0
	MOVE.L	(SP,4+16),(A0)
	BSR	I_CONS
	RTS

play	BSR	pver
	LEA	MODULE_ERROR(PC),A0
	TST.B	(A0)
	BNE.S	.f
	MOVE.L	MODULE_AD(PC),D0
	SEQ	(A0)
	BEQ.S	.f
	MOVE.B	MODULE_PLAY(PC),D0
	BNE.S	.pause
.play	BSR	PLAY
.f	RTS

.pause	BSR	PAUSE
	BRA	.f

stop	BSR	pver
	BSR	PAUSE
	BSR	I_VARS
	BSR	I_BUFFERS
	RTS

sgrs	BSR	pver
	LEA	MODULE_ERROR(PC),A0
	TST.B	(A0)
	BNE.S	.f
	MOVE.L	MODULE_AD(PC),D0
	SEQ	(A0)
	BEQ.S	.f
	MOVE.B	MODULE_PLAY(PC),D0
	MOVE	D0,-(SP)
	BSR	PAUSE
	LEA	SONG_POSITION(PC),A0
	MOVE	(A0),D1
	SUBQ	#1,D1
	BMI.S	.1
	MOVE	D1,(A0)
	LEA	PATTERN_POSITION(PC),A0
	CLR	(A0)
.1	MOVE	(SP)+,D0
	TST.B	D0
	BEQ.S	.f
	BSR	PLAY
.f	RTS

sgfs	BSR	pver
	LEA	MODULE_ERROR(PC),A0
	TST.B	(A0)
	BNE.S	.f
	MOVE.L	MODULE_AD(PC),D0
	SEQ	(A0)
	BEQ.S	.f
	MOVE.B	MODULE_PLAY(PC),D0
	MOVE	D0,-(SP)
	BSR	PAUSE
	LEA	SONG_POSITION(PC),A0
	MOVE	(A0),D1
	ADDQ	#1,D1
	MOVEA.L SONG_AD(PC),A1
	CMP.B	(A1,-2),D1
	BHS.S	.1
	MOVE	D1,(A0)
	LEA	PATTERN_POSITION(PC),A0
	CLR	(A0)
.1	MOVE	(SP)+,D0
	TST.B	D0
	BEQ.S	.f
	BSR	PLAY
.f	RTS

fast	BSR	pver
	LEA	MODULE_FAST(PC),A0
	NOT.B	(A0)
	RTS

rept	BSR	pver
	LEA	MODULE_REPEAT(PC),A0
	NOT.B	(A0)
	RTS

cmd	SUBQ	#1,D0
	ANDI	#%111,D0
	LEA	tab_cmd(PC),A0
	MOVE	(A0,D0*2),D0
	LEA	powr(PC),A0
	JSR	(A0,D0)

m8_16	BSR	pver
	SF	D2 ;Drapeau pour new_hard
	MOVE	(SP,6),D0
	BEQ.S	mo_st
	ST	D2
	LEA	MODULE_8_16(PC),A0
	NOT.B	(A0)

mo_st	MOVE	(SP,8),D0
	BEQ.S	freq
	ST	D2
	LEA	MODULE_MO_ST(PC),A0
	NOT.B	(A0)

freq	MOVE	(SP,10),D0
	BEQ.S	.1
	ST	D2
	SUBQ	#1,D0
	ANDI	#%111,D0
	LEA	MODULE_FREQ(PC),A0
	MOVE	D0,(A0)

.1	TST.B	D2
	BEQ.S	.2
 ;new_hard , en marche ?
	MOVE.B	MODULE_PLAY(PC),D0
	MOVE	D0,-(SP)
	BSR	PAUSE
	BSR	I_BUFFERS
	BSR	I_INCREMENTS
	BSR	I_LEVELS
	BSR	InitVOICERoutineOffset
	BSR	I_REGS
	MOVE	(SP)+,D0
	TST.B	D0
	BEQ.S	.2
	BSR	PLAY
.2	LEA	MODULE_ERROR(PC),A0
	MOVE.B	(A0),D0
	RTS

	D_
;*** MODULE *******************************************************
;Listes des identificateurs de modules 31 samples
MODULE_IDS: DC.L 'M.K.','M!K!','M&K&','FLT4','FLT6','FLT8',0 ;0:fin

NOTES:
; Tuning 0 , Normal
	DC.W 856,808,762,720,678,640,604,570,538,508,480,453
	DC.W 428,404,381,360,339,320,302,285,269,254,240,226
	DC.W 214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	DC.W 850,802,757,715,674,637,601,567,535,505,477,450
	DC.W 425,401,379,357,337,318,300,284,268,253,239,225
	DC.W 213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	DC.W 844,796,752,709,670,632,597,563,532,502,474,447
	DC.W 422,398,376,355,335,316,298,282,266,251,237,224
	DC.W 211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	DC.W 838,791,746,704,665,628,592,559,528,498,470,444
	DC.W 419,395,373,352,332,314,296,280,264,249,235,222
	DC.W 209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	DC.W 832,785,741,699,660,623,588,555,524,495,467,441
	DC.W 416,392,370,350,330,312,294,278,262,247,233,220
	DC.W 208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	DC.W 826,779,736,694,655,619,584,551,520,491,463,437
	DC.W 413,390,368,347,328,309,292,276,260,245,232,219
	DC.W 206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	DC.W 820,774,730,689,651,614,580,547,516,487,460,434
	DC.W 410,387,365,345,325,307,290,274,258,244,230,217
	DC.W 205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	DC.W 814,768,725,684,646,610,575,543,513,484,457,431
	DC.W 407,384,363,342,323,305,288,272,256,242,228,216
	DC.W 204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	DC.W 907,856,808,762,720,678,640,604,570,538,508,480
	DC.W 453,428,404,381,360,339,320,302,285,269,254,240
	DC.W 226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	DC.W 900,850,802,757,715,675,636,601,567,535,505,477
	DC.W 450,425,401,379,357,337,318,300,284,268,253,238
	DC.W 225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	DC.W 894,844,796,752,709,670,632,597,563,532,502,474
	DC.W 447,422,398,376,355,335,316,298,282,266,251,237
	DC.W 223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	DC.W 887,838,791,746,704,665,628,592,559,528,498,470
	DC.W 444,419,395,373,352,332,314,296,280,264,249,235
	DC.W 222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	DC.W 881,832,785,741,699,660,623,588,555,524,494,467
	DC.W 441,416,392,370,350,330,312,294,278,262,247,233
	DC.W 220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	DC.W 875,826,779,736,694,655,619,584,551,520,491,463
	DC.W 437,413,390,368,347,328,309,292,276,260,245,232
	DC.W 219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	DC.W 868,820,774,730,689,651,614,580,547,516,487,460
	DC.W 434,410,387,365,345,325,307,290,274,258,244,230
	DC.W 217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	DC.W 862,814,768,725,684,646,610,575,543,513,484,457
	DC.W 431,407,384,363,342,323,305,288,272,256,242,228
	DC.W 216,203,192,181,171,161,152,144,136,128,121,114

;Pour le Vibrato et le Tremolo
SINUS:	;Fractionnel 8 bits
	DC.B   0, 24, 49, 74, 97,120,141,161
	DC.B 180,197,212,224,235,244,250,253
	DC.B 255,253,250,244,235,224,212,197
	DC.B 180,161,141,120, 97, 74, 49, 24

RND:	;Fractionnel 8 bits
	DC.B 180, 28, 36,196, 76,252,108,204
	DC.B 156,212,164, 44,140,100, 20, 60
	DC.B 124,220, 92,148,  4,228,244,172
	DC.B 132, 84, 12, 68,236, 52,188,116

;Pour l'effet Funk
FUNK:	;Fractionnel 7 bits
	DC.B   0,  5,  6,  7,  8, 10, 11, 13
	DC.B  16, 19, 22, 26, 32, 43, 64,128
;******************************************************************

;*** MOTEUR ***********************************
GEN_BUFFER_LNS:;DMAFreq*125/50
	DC.L  20488
	DC.L  24585
	DC.L  30731
	DC.L  40975
	DC.L  49170
	DC.L  61463
	DC.L  81950
	DC.L 122925

GEN_INCREMENTS: ;3579546/DMAFreq (INT16+FRAC16)
	DC.L 28625888
	DC.L 23854904
	DC.L 19083924
	DC.L 14312944
	DC.L 11927452
	DC.L  9541962
	DC.L  7156472
	DC.L  4770981

SAMPLE_NUL: ;pour les voies mortes
	DC.W 0

 ;Pour simuler LEVELS(PC)
LEVELS_AD DC.L LEVELS-LEVELS_AD
;**********************************************

;*** PARAMETRES *********************
MODULE_POWER	DC.B 0 ;0:OFF	-1:ON
		DC.B 0
FREQ_DIV	DC.B 11,9,7,5,4,3,2,1
;************************************

	M_
;*** MOTEUR ********************************************************************
;A la fin car il comporte des tables trop encombrantes qui
;rendent impossible l'acc‚s(PC)


;Table des longueurs de tampons en enregistrements
;Length = DMAFreq*(125/PQ)/50
;avec 33=< PQ =<255
BUFFER_LNS DS.W (255-32)
BUFFER_LN  DS.W 1 ;la longueur courante
BUFFER_F   DS.B 1 ;Interdit l'‚criture dans les tampons
	   DS.B 1
BUFFER_ADS DS.L 4 ;PhysiqueDeb,PhysiqueFin,LogiqueDeb,LogiqueFin

INCREMENTS: DS.L 1024
	;Cette table d'incr‚ments (INT16+FRAC16) du pointeur de lecture
	;dans un sample permet d'‚muler un g‚n‚rateur de fr‚quence
	;similaire … celui de l'Amiga:(3579546 Hz)/NotePeriod=PAULAFreq
	;Incr‚ment=PAULAFreq/DMAFreq=(3579546/NotePeriod)/DMAFreq
	;Avec 108 =< NotePeriod =< 907	     , sans effet
	;et    96 =< NotePeriod =< 96+1024-1 , avec effet

BUFFER_A:  DS.W BufferLengthMaxi*2 ;Tampon A … lire en DMA
BUFFER_B:  DS.W BufferLengthMaxi*2 ;Tampon B … lire en DMA

LEVELS: DS.W 65*256
 ;65 tables de niveaux (Volume variant de 0 … 64) de 256 valeurs
 ;Contenu de chacune:
 ;si X=[0 … 127]   ---> Y=[0	    … +127*VOL]
 ;si X=[128 … 255] ---> Y=[-128*VOL …	-1*VOL]
 ;N.B. = Tenir compte des possibilit‚s d'amplitude pour ‚viter la saturation
 ;dans le cas ou on fusionne 2 ou 4 voies.
;*******************************************************************************

 END
