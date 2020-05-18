*************************************************
* Une version de CPU_MOD.BIN utilisable en STOS *
*************************************************

	OUTPUT	CPU_MODS.BIN ;C'est son nom !!!

;Rappel:
;	CPU_MOD(Cmd.W,0.W,Mo_St.W,Freq.W,MOD_Ad.L,MOD_Ln.L)
;Offset 	+30   +32 +34	  +36	 +38	  +42
;pour y acc‚der directement
;Pourquoi +30 ? ---> 28 pour la taille du header +2 pour le BRA.S MettreEnPile

	BRA.S	MettreEnPile
	DC.W	0	Cmd	+30
	DC.W	0	0	+32
	DC.W	0	Mo_St	+34
	DC.W	0	Freq	+36
	DC.L	0	MOD_Ad	+38
	DC.L	0	MOD_Ln	+42
PARAMETRES: ;Il seront … l'adresse de CPU_MODS.BIN+Offset

;Ici suit un instantan‚ des sorties des 4 voies
;A lire pour faire par exemple un vu-mˆtre ...
SortieV0:	DC.B	0	+46
SortieV1:	DC.B	0	+47
SortieV2:	DC.B	0	+48
SortieV3:	DC.B	0	+49
SortieVx:	DC.B	0,0

MettreEnPile:
	LEA	PARAMETRES(PC),A0
	MOVE.L	-(A0),-(SP)
	MOVE.L	-(A0),-(SP)
	MOVE	-(A0),-(SP)
	MOVE	-(A0),-(SP)
	MOVE	-(A0),-(SP)
	MOVE	-(A0),-(SP)
	BSR.S	CPU_MOD
	ADDA	#16,SP ;Propret‚ !
	RTS

CPU_MOD:
;Longueurs
ModuleName  =20
SampleInfos =30
SampleName  =22
VoiceInfos  =4

;D‚cal‚s dans le champ sample
SampleLength	  =SampleName		; W
SampleFineTune	  =SampleLength+2	; B
SampleVolume	  =SampleFineTune+1	; B
SampleRepeatStart =SampleVolume+1	; W
SampleRepeatLength=SampleRepeatStart+2	; W

;D‚cal‚s dans les variables g‚n‚rales par voie
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

BufferLengthMaxi=50066*125/33/50 ;le maxi

 TEXT
	BRA	INTERPRET

RetrigSample: ;Initialiser le pointeur
	MOVE.L	VSampleStart(A5),VSamplePointerInt(A5)
	CLR	VSamplePointerFrac(A5)
	MOVE.L	VSampleEnd(A5),VSamplePointerEnd(A5)
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
.1	MOVE	D0,VPitch(A5)
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
	MOVE	VFineTune(A5),D0
	BEQ.S	.3
	MULU	#36*2,D0
.3	LEA	-2(A0,D0),A3
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
.1	MOVE	D0,VVolume(A5)
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
	SF	VNoRetrig(A5)
	BSR	Find_Note
	BSR	SetPitch
.f	RTS

Init_Arpeggio:
	TST	VEffectParameters(A5)
	BEQ	Init_Normal
	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.1
 ;Nouvelle note
	SF	VNoRetrig(A5)
.2	BSR	Find_Note
	BSR	SetPitch
	CLR	VArpeggioPointer(A5)
 ;Note de base
	MOVE	(A3),D0
	MOVE	D0,VArpeggioNote0(A5)
 ;1Šre note d'accord
	MOVE	VEffectParameters(A5),D1
	LSR	#4,D1
	CMP	D3,D1
	BHI.S	.3
	LSL	#1,D1
	MOVE	(A3,D1),D2
.n1	MOVE	D2,VArpeggioNote1(A5)
 ;2Šme note d'accord
	MOVE	VEffectParameters(A5),D1
	ANDI	#$F,D1
	CMP	D3,D1
	BHI.S	.4
	LSL	#1,D1
	MOVE	(A3,D1),D2
.n2	MOVE	D2,VArpeggioNote2(A5)
	RTS

.1	MOVE	VNote(A5),D0
	BRA	.2

.3	MOVE	D0,D2
	BRA	.n1

.4	MOVE	D0,D2
	BRA	.n2

Init_TonePorta:
	TST.B	VNoRetrig(A5)
	BNE.S	.1
 ;Changement de sample ?
	CMP	VSample(A5),D3
	BNE.S	.1
	ST	VNoRetrig(A5)
.1	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.2
	BSR	Find_Note
	MOVE	D0,VTonePortamentoNote(A5)
.2	MOVE	VEffectParameters(A5),D0
	BEQ.S	.f
	MOVE	D0,VTonePortamentoStep(A5)
.f	RTS

Init_Vibrato:
	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.1
 ;Nouvelle note
	SF	VNoRetrig(A5)
 ;Initialiser Pointer
	TST.B	VVibratoControl(A5)
	BNE.S	.2
	CLR	VVibratoPointer(A5)
.2	BSR	Find_Note
	BSR	SetPitch
	MOVE	(A3),VVibratoNote(A5)
 ;Initialiser Amplitude et Step
	MOVE	VEffectParameters(A5),D0
	ANDI	#$F,D0
	BEQ.S	.3
	LSL	#1,D0 ;*2 (0 to 30 step 2)
	MOVE	D0,VVibratoAmplitude(A5)
.3	MOVE	VEffectParameters(A5),D0
	LSR	#4,D0
	BEQ.S	.f
	MOVE	D0,VVibratoStep(A5) ;(0 to 15,amplitude maxi)
.f	RTS

.1	MOVE	VNote(A5),D0
	BRA	.2

Init_TonePorta_VolumeSlide:
	TST.B	VNoRetrig(A5)
	BNE.S	.1
 ;Changement de sample ?
	CMP	VSample(A5),D3
	BNE.S	.1
	ST	VNoRetrig(A5)
.1	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.f
	BSR	Find_Note
	MOVE	D0,VTonePortamentoNote(A5)
.f	RTS

Init_Vibrato_VolumeSlide:
	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.1
 ;Nouvelle note
	SF	VNoRetrig(A5)
 ;Initialiser Pointer
	TST.B	VVibratoControl(A5)
	BNE.S	.2
	CLR	VVibratoPointer(A5)
.2	BSR	Find_Note
	BSR	SetPitch
	MOVE	(A3),VVibratoNote(A5)
	RTS

.1	MOVE	VNote(A5),D0
	BRA	.2

Init_Tremolo:
	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.1
 ;Nouvelle note
	SF	VNoRetrig(A5)
 ;Initialiser Pointer
	TST.B	VTremoloControl(A5)
	BNE.S	.2
	CLR	VTremoloPointer(A5)
.2	BSR	Find_Note
	BSR	SetPitch
	MOVE	VVolume(A5),VTremoloVolume(A5)
 ;Initialiser Amplitude et Step
	MOVE	VEffectParameters(A5),D0
	ANDI	#$F,D0
	BEQ.S	.3
	LSL	#2,D0 ;*4 (0 to 60 step 4)
	MOVE	D0,VTremoloAmplitude(A5)
.3	MOVE	VEffectParameters(A5),D0
	LSR	#4,D0
	BEQ.S	.f
	MOVE	D0,VTremoloStep(A5) ;(0 to 15,amplitude maxi)
.f	RTS

.1	MOVE	VNote(A5),D0
	BRA	.2

Init_PhasorEffect:
	BRA	Init_Normal

Init_SampleOffset:
	MOVEQ	#0,D0
	MOVE	VEffectParameters(A5),D0
	BEQ.S	.1
	MOVE	D0,VSampleOffset(A5)
.1	MOVE	VSampleOffset(A5),D0
	LSL	#8,D0
	MOVE.L	VSampleEnd(A5),D1
	BMI.S	.f
	SUB.L	VSampleStart(A5),D1
	CMP.L	D1,D0
	BHS.S	.f
	ADD.L	D0,VSampleStart(A5)
.f	BRA	Init_Normal

Init_SongPositionJump:
	MOVE	VEffectParameters(A5),D0
 ;Valide ?
	MOVEA.L SONG_AD(PC),A0
	CMP.B	-2(A0),D0
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
	MOVE	VEffectParameters(A5),D0
	BSR	SetVolume
	BRA	Init_Normal

Init_PatternBreak:
	LEA	SONG_POSITION(PC),A0
	MOVE	(A0),D0
	ADDQ	#1,D0
	MOVEA.L SONG_AD(PC),A1
	CMP.B	-2(A1),D0
	BEQ.S	.stop
	MOVE	D0,(A0)
	LEA	PATTERN_POSITION(PC),A0
	MOVE	VEffectParameters(A5),D0
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
	MOVE	VPitch(A5),D0
	MOVE	VEffectParameters(A5),D1
	ANDI	#$F,D1 ;Q
	SUB	D1,D0
	BSR	SetPitch
	BRA	Init_Normal

Init_FinePortamentoDown:
	MOVE	VPitch(A5),D0
	MOVE	VEffectParameters(A5),D1
	ANDI	#$F,D1 ;Q
	ADD	D1,D0
	BSR	SetPitch
	BRA	Init_Normal

Init_TonePortamentoControl:
	MOVE	VEffectParameters(A5),D0
	ANDI	#$F,D0 ;Q
	SNE	VTonePortamentoControl(A5)
	BRA	Init_Normal

Init_VibratoWaveform:
	MOVE	VEffectParameters(A5),D0
	BTST	#2,D0
	SNE	VVibratoControl(A5)
	ANDI	#%11,D0
	MOVE	D0,(VVibratoWaveform)
	BRA	Init_Normal

Init_FineTune:
	MOVE	VEffectParameters(A5),D0
	ANDI	#$F,D0 ;Q
	MOVE	D0,VFineTune(A5)
	BRA	Init_Normal

Init_PatternPositionLoop:
	MOVE	VEffectParameters(A5),D0
	ANDI	#$F,D0 ;Q
	BEQ.S	.setloop
	SUBQ	#1,VPatternPosLoopCounter(A5)
	BMI.S	.1stloop
	BEQ.S	.f
.1	LEA	PATTERN_POSITION(PC),A0
	MOVE	VPatternPosLoopStart(A5),(A0)
	LEA	SONG_BREAK(PC),A0
	ST	(A0)
.f	BRA	Init_Normal

.setloop:
	MOVE	PATTERN_POSITION(PC),VPatternPosLoopStart(A5)
	BRA.S	.f

.1stloop:
	MOVE	D0,VPatternPosLoopCounter(A5)
	BRA	.1

Init_TremoloWaveform:
	MOVE	VEffectParameters(A5),D0
	BTST	#2,D0
	SNE	VTremoloControl(A5)
	ANDI	#%11,D0
	MOVE	D0,(VTremoloWaveform)
	BRA	Init_Normal

Init_Stop:
	BSR	STOP_OPT
	BRA	Init_Normal

Init_NoteRetrig:
	MOVE	VEffectParameters(A5),D0
	ANDI	#$F,D0 ;Q
	MOVE	D0,VNoteRetrigDelay(A5)
	BSR	RetrigSample
	BRA	Init_Normal

Init_FineVolumeUp:
	MOVE	VVolume(A5),D0
	MOVE	VEffectParameters(A5),D1
	ANDI	#$F,D1 ;Q
	ADD	D1,D0
	BSR	SetVolume
	BRA	Init_Normal

Init_FineVolumeDown:
	MOVE	VVolume(A5),D0
	MOVE	VEffectParameters(A5),D1
	ANDI	#$F,D1 ;Q
	SUB	D1,D0
	BSR	SetVolume
	BRA	Init_Normal

Init_NoteCut:
	MOVE	VEffectParameters(A5),D0
	ANDI	#$F,D0 ;Q
	MOVE	D0,VNoteCutDelay(A5)
	BRA	Init_Normal

Init_NoteDelay:
	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.f
	ST	VNoRetrig(A5)
	BSR	Find_Note
	BSR	SetPitch
	MOVE	VEffectParameters(A5),D0
	ANDI	#$F,D0 ;Q
	MOVE	D0,VNotePlayDelay(A5)
	BEQ	Init_Normal
.f	RTS

Init_PatternPositionDelay:
	MOVE	VEffectParameters(A5),D0
	ANDI	#$F,D0 ;Q
	ADDQ	#1,D0
	LEA	PATTERN_POSITION_DELAY(PC),A0
	MOVE	D0,(A0)
	BRA	Init_Normal

Init_InvertRepeatLoop:
	MOVE	VEffectParameters(A5),D0
	ANDI	#$F,D0 ;Q
	LEA	FUNK(PC),A0
	MOVE.B	(A0,D0),VInvertRepeatLoopIncr(A5)
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
	MOVE	VEffectParameters(A5),D0
	LSR	#4,D0 ;P
	LSL	#1,D0
	MOVE	(A0,D0),D0
	LEA	Init_Normal(PC),A0
	JMP	(A0,D0)

Init_SpeedSet:
	MOVE	VEffectParameters(A5),D0
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
	MOVE	VEffect(A5),D0
	LSL	#1,D0
	MOVE	(A0,D0),D0
	LEA	Init_Normal(PC),A0
	JSR	(A0,D0)
	BRA	InvertRepeatLoop

;~~~~~~~~~~~~~~~~ F X ~~~~~~~~~~~~~~~~

NulEffect:
	RTS

Arpeggio: ;Accord simul‚
	TST	VEffectParameters(A5)
	BEQ	NulEffect
 ;Rotation sur 3 notes
	MOVE	VArpeggioPointer(A5),D0
	ADDQ	#1,D0
	CMPI	#2,D0
	BLS.S	.1
	MOVEQ	#0,D0
.1	MOVE	D0,VArpeggioPointer(A5)
	LSL	#1,D0
	MOVE	VArpeggioNote0(A5,D0),D0
	BSR	SetPitch
	RTS

PortamentoUp: ;D‚rive de la fr‚quence ves les aigus
	MOVE	VPitch(A5),D0
	SUB	VEffectParameters(A5),D0
	BSR	SetPitch
	RTS

PortamentoDown: ;D‚rive de la fr‚quence vers les graves
	MOVE	VPitch(A5),D0
	ADD	VEffectParameters(A5),D0
	BSR	SetPitch
	RTS

TonePortamento: ;D‚rive de la fr‚quence … destination d'une note
	MOVE	VPitch(A5),D0
	MOVE	VTonePortamentoNote(A5),D1
	CMP	D1,D0
	BEQ.S	.f ;c'est fini !
	BHI.S	.moins
.plus	ADD	VTonePortamentoStep(A5),D0
	CMP	D1,D0
	BLE.S	.1
.2	MOVE	D1,D0
.1 ;Control ?
	TST.B	VTonePortamentoControl(A5)
	BEQ.S	.3
	BSR	Find_Note
.3	BSR	SetPitch
.f	RTS

.moins	SUB	VTonePortamentoStep(A5),D0
	CMP	D1,D0
	BGE.S	.1 ;sign‚ car risque d'‚tre <0
	BRA	.2

Vibrato: ;Variation de la fr‚quence autour d'une valeur de base
 ;Calcul de l'abcisse
	MOVE	VVibratoPointer(A5),D0
	ANDI	#%11111,D0 ;partie positive
	MOVE	VVibratoWaveform(A5),D1
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

.newfrq MULU	VVibratoAmplitude(A5),D0
	LSR	#8,D0 ;Et hop:ENTIER
 ;A additionner ou soustraire ?
	BTST	#5,VVibratoPointer+1(A5) ; bit de "signe" logique
	BNE.S	.moins
.plus	ADD	VVibratoNote(A5),D0
	BSR	SetPitch
	BRA.S	.next
.moins	SUB	VVibratoNote(A5),D0
	NEG	D0
	BSR	SetPitch
.next	MOVE	VVibratoStep(A5),D0
	ADD	D0,VVibratoPointer(A5)
	RTS

TonePortamento_VolumeSlide:
	BSR	TonePortamento
	BRA.S	VolumeSlide

Vibrato_VolumeSlide:
	BSR	Vibrato
	BRA.S	VolumeSlide

Tremolo: ;Variation de l'amplitude (volume) autour d'une valeur de base
 ;Calcul de l'abcisse
	MOVE	VTremoloPointer(A5),D0
	ANDI	#%11111,D0 ;partie positive
	MOVE	VTremoloWaveform(A5),D1
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

.newvol MULU	VTremoloAmplitude(A5),D0
	LSR	#8,D0 ;Et hop:ENTIER
 ;A additionner ou soustraire ?
	BTST	#5,VTremoloPointer+1(A5) ; bit de "signe" logique
	BNE.S	.moins
.plus	ADD	VTremoloVolume(A5),D0
	BSR	SetVolume
	BRA.S	.next
.moins	SUB	VTremoloVolume(A5),D0
	NEG	D0
	BSR	SetVolume
.next	MOVE	VTremoloStep(A5),D0
	ADD	D0,VTremoloPointer(A5)
	RTS

VolumeSlide: ;D‚rive du volume
	MOVE	VVolume(A5),D0
	MOVE	VEffectParameters(A5),D1
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
	SUBQ	#1,VNoteRetrigDelay(A5)
	BNE.S	.f
	MOVE	VEffectParameters(A5),D0
	ANDI	#$F,D0 ;Q
	MOVE	D0,VNoteRetrigDelay(A5)
 ;Dans le cas ou Q=0 on ne retrige pas
	BSR	RetrigSample
.f	RTS

NoteDelay:
	SUBQ	#1,VNotePlayDelay(A5)
	BNE.S	.f
	BSR	RetrigSample
.f	RTS

NoteCut:
	SUBQ	#1,VNoteCutDelay(A5)
	BNE.S	.f
	CLR	VVolume(A5)
.f	RTS

InvertRepeatLoop:
 ;Appel‚ inconditionnellement
	MOVE.B	VInvertRepeatLoopIncr(A5),D0
	BEQ.S	.f
	MOVE.L	VSampleRepeatEnd(A5),D1
	BMI.S	.f
	ADD.B	D0,VInvertRepeatLoopPtFrc(A5)
	BPL.S	.f
	CLR.B	VInvertRepeatLoopPtFrc(A5)
	MOVE.L	VInvertRepeatLoopPtInt(A5),D0
	BEQ.S	.f
	MOVEA.L D0,A0
	NEG.B	(A0)+
	CMPA.L	D1,A0
	BLO.S	.1
	MOVEA.L VSampleRepeatStart(A5),A0
.1	MOVE.L	A0,VInvertRepeatLoopPtInt(A5)
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
	MOVE	VEffectParameters(A5),D0
	LSR	#4,D0 ;P
	LSL	#1,D0
	MOVE	(A0,D0),D0
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
	MOVE	VEffect(A5),D0
	LSL	#1,D0
	MOVE	(A0,D0),D0
	LEA	NulEffect(PC),A0
	JSR	(A0,D0)
	BRA	InvertRepeatLoop

;~~~~~~~~~~~~~~~~ E X I T ~~~~~~~~~~~~~~~~

Exit_NulEffect:
	RTS

Exit_Arpeggio:
	TST	VEffectParameters(A5)
	BEQ.S	Exit_NulEffect
	MOVE	VArpeggioNote0(A5),D0
	BSR	SetPitch
	RTS

Exit_Vibrato: ;Effets 4&6
	MOVE	VVibratoNote(A5),D0
	BSR	SetPitch
	RTS

Exit_Tremolo:
	MOVE	VTremoloVolume(A5),D0
	BSR	SetVolume
	RTS

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
	MOVE	VEffect(A5),D0
	LSL	#1,D0
	MOVE	(A0,D0),D0
	LEA	Exit_NulEffect(PC),A0
	JMP	(A0,D0)

ANALYSE_VOICE:
;A6=MODULE
;A5=VOICE
;A4=Infos voie
.note	MOVE	(A4),D0
	ANDI	#$FFF,D0
	BEQ.S	.sample
	MOVE	D0,VNote(A5)
.sample MOVE.B	(A4),D0
	ANDI	#$10,D0 ;Dans le cas de MOD … 31 samples
	MOVEQ	#0,D1
	MOVE.B	2(A4),D1
	LSR	#4,D1
	OR	D1,D0
	AND	SAMPLE_NB(PC),D0
	SEQ	VNoRetrig(A5)
	BEQ	.effect
 ;Nouveau sample
	MOVE	VSample(A5),D3 ;Servira … Init_TonePorta
	MOVE	D0,VSample(A5)
	SUBQ	#1,D0
	LEA	SAMPLE_ADS(PC),A0
	LSL	#2,D0
	MOVEA.L (A0,D0),A0
	LSR	#2,D0
	MOVE.L	A0,VSampleStart(A5)
	MULU	#SampleInfos,D0
	LEA	ModuleName(A6,D0),A1
	MOVE	SampleLength(A1),D0 ;le mot sup. est d‚ja … 0
	BEQ.S	.1
	LSL.L	#1,D0
	LEA	(A0,D0.L),A2
	MOVE.L	A2,VSampleEnd(A5)
	MOVEQ	#0,D0
	MOVE	SampleRepeatStart(A1),D0
	LSL.L	#1,D0
	LEA	(A0,D0.L),A2
	MOVE.L	A2,VSampleRepeatStart(A5)
	MOVEQ	#0,D0
	MOVE	SampleRepeatLength(A1),D0
	CMPI	#1,D0
 ;pour ‚viter la perte de puissance il faudrait
 ;‚viter les boucles courtes (<10 par ex.)
	BLS.S	.2
	LSL.L	#1,D0
	LEA	(A2,D0.L),A2
	MOVE.L	A2,VSampleRepeatEnd(A5)
.3	MOVE.B	SampleFineTune(A1),D0
	ANDI	#$F,D0
	MOVE	D0,VFineTune(A5)
	MOVE.B	SampleVolume(A1),D0
	MOVEQ	#64,D1
	CMP	D1,D0
	BLS.S	.4
	MOVE	D1,D0
.4	MOVE	D0,VVolume(A5)

 ;Pour l'effet Invert Repeat Loop
	MOVE.L	VSampleRepeatStart(A5),VInvertRepeatLoopPtInt(A5)
	CLR.B	VInvertRepeatLoopPtFrc(A5)
	BRA.S	.effect

.1	MOVEQ	#-1,D0
	MOVE.L	D0,VSampleEnd(A5)
	MOVE.L	A0,VSampleRepeatStart(A5)
	MOVE.L	D0,VSampleRepeatEnd(A5)
	BRA.S	.3

.2	MOVEQ	#-1,D0
	MOVE.L	D0,VSampleRepeatEnd(A5)
	BRA	.3

.effect BSR	EXIT_EFFECT
	MOVE.B	2(A4),D0
	ANDI	#$F,D0
	MOVE	D0,VEffect(A5)
	MOVE.B	3(A4),D0
	MOVE	D0,VEffectParameters(A5)
	BSR	INIT_EFFECT

.retrig TST.B	VNoRetrig(A5)
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

;~~~ ROUTINES GEN_VOICE ~~~~~~~~~~~~~~~~~~~~~~~~
;O: Open voice , MOVE sur BUFFER_LN ‚chantillons
;A: Add  voice , ADD  sur BUFFER_LN ‚chantillons
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

GEN_VOICE_8_MO_O:
	MOVE.L	VSamplePointerEnd(A5),D0
	MOVEA.L D0,A4
	BEQ.S	.V0 ;Au d‚part=0
	BMI.S	.V0
	MOVE.L	VSamplePointerInt(A5),D6
	MOVE	VSamplePointerFrac(A5),D5
	LEA	INCREMENTS(PC),A0
	MOVE	VPitch(A5),D0
	SUBI	#96,D0
	BMI.S	.V0 ;S‚curit‚
	MOVEQ	#0,D4
	LSL	#2,D0
	MOVE	(A0,D0),D4
	MOVE	2(A0,D0),D3
.lvl	LEA	LEVELS_AD(PC),A0
	ADDA.L	(A0),A0
	MOVE	VVolume(A5),D0
	LSL	#8,D0 ;*256
	LEA	(A0,D0),A3
	BRA.S	.MUSIK4

.V0:	LEA	-1,A4
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.lvl

.MUSIK4	BSR	INSTANT
	MOVEQ	#0,D0 ;Sert sur 16 bits
	MOVE	BUFFER_LN(PC),D7
	LSR	#2,D7
	SUBQ	#1,D7
.4b	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),(A6)+
 ;Au suivant
	ADD	D3,D5
	ADDX.L	D4,D6
 ;Adresse valide ?
.vad1	CMP.L	A4,D6
	BLO.S	.svt1
	MOVE.L	VSampleRepeatEnd(A5),D1
	BMI.S	.V0_1
	SUB.L	A4,D6
	ADD.L	VSampleRepeatStart(A5),D6
	MOVEA.L D1,A4
	BRA	.vad1
.V0_1	MOVEA.L D1,A4 ;=-1
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
.svt1	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),(A6)+
	ADD	D3,D5
	ADDX.L	D4,D6
.svt2	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),(A6)+
	ADD	D3,D5
	ADDX.L	D4,D6
.svt3	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),(A6)+
	ADD	D3,D5
	ADDX.L	D4,D6
.svt4	DBRA	D7,.4b

.pt ;Remettre les pointeurs
	MOVE.L	D6,VSamplePointerInt(A5)
	MOVE	D5,VSamplePointerFrac(A5)
	MOVE.L	A4,VSamplePointerEnd(A5)
	RTS

GEN_VOICE_8_MO_A:
	MOVE.L	VSamplePointerEnd(A5),D0
	MOVEA.L D0,A4
	BEQ.S	.V0 ;Au d‚part=0
	BMI.S	.V0
	MOVE.L	VSamplePointerInt(A5),D6
	MOVE	VSamplePointerFrac(A5),D5
	LEA	INCREMENTS(PC),A0
	MOVE	VPitch(A5),D0
	SUBI	#96,D0
	BMI.S	.V0 ;S‚curit‚
	MOVEQ	#0,D4
	LSL	#2,D0
	MOVE	(A0,D0),D4
	MOVE	2(A0,D0),D3
.lvl	LEA	LEVELS_AD(PC),A0
	ADDA.L	(A0),A0
	MOVE	VVolume(A5),D0
	LSL	#8,D0 ;*256
	LEA	(A0,D0),A3
	BRA.S	.MUSIK4

.V0:	LEA	-1,A4
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.lvl

.MUSIK4	BSR	INSTANT
	MOVEQ	#0,D0 ;Sert sur 16 bits
	MOVE	BUFFER_LN(PC),D7
	LSR	#2,D7
	SUBQ	#1,D7
.4b	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),D1
	ADD.B	D1,(A6)+
	ADD	D3,D5
	ADDX.L	D4,D6
.vad1	CMP.L	A4,D6
	BLO.S	.svt1
	MOVE.L	VSampleRepeatEnd(A5),D1
	BMI.S	.V0_1
	SUB.L	A4,D6
	ADD.L	VSampleRepeatStart(A5),D6
	MOVEA.L D1,A4
	BRA	.vad1
.V0_1	MOVEA.L D1,A4
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
.svt1	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),D1
	ADD.B	D1,(A6)+
	ADD	D3,D5
	ADDX.L	D4,D6
.svt2	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),D1
	ADD.B	D1,(A6)+
	ADD	D3,D5
	ADDX.L	D4,D6
.svt3	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),D1
	ADD.B	D1,(A6)+
	ADD	D3,D5
	ADDX.L	D4,D6
.svt4	DBRA	D7,.4b

.pt ;Remettre les pointeurs
	MOVE.L	D6,VSamplePointerInt(A5)
	MOVE	D5,VSamplePointerFrac(A5)
	MOVE.L	A4,VSamplePointerEnd(A5)
	RTS

GEN_VOICE_8_ST_O:
	MOVE.L	VSamplePointerEnd(A5),D0
	MOVEA.L D0,A4
	BEQ.S	.V0 ;Au d‚part=0
	BMI.S	.V0
	MOVE.L	VSamplePointerInt(A5),D6
	MOVE	VSamplePointerFrac(A5),D5
	LEA	INCREMENTS(PC),A0
	MOVE	VPitch(A5),D0
	SUBI	#96,D0
	BMI.S	.V0 ;S‚curit‚
	MOVEQ	#0,D4
	LSL	#2,D0
	MOVE	(A0,D0),D4
	MOVE	2(A0,D0),D3
.lvl	LEA	LEVELS_AD(PC),A0
	ADDA.L	(A0),A0
	MOVE	VVolume(A5),D0
	LSL	#8,D0 ;*256
	LEA	(A0,D0),A3
	BRA.S	.MUSIK4

.V0:	LEA	-1,A4
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.lvl

.MUSIK4	BSR	INSTANT
	MOVEQ	#0,D0 ;Sert sur 16 bits
	MOVE	BUFFER_LN(PC),D7
	LSR	#2,D7
	SUBQ	#1,D7
.4b	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),(A6)+
	ADDQ	#1,A6 ;Sauter l'autre voie
 ;Au suivant
	ADD	D3,D5
	ADDX.L	D4,D6
 ;Adresse valide ?
.vad1	CMP.L	A4,D6
	BLO.S	.svt1
	MOVE.L	VSampleRepeatEnd(A5),D1
	BMI.S	.V0_1
	SUB.L	A4,D6
	ADD.L	VSampleRepeatStart(A5),D6
	MOVEA.L D1,A4
	BRA	.vad1
.V0_1	MOVEA.L D1,A4 ;=-1
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
.svt1	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),(A6)+
	ADDQ	#1,A6
	ADD	D3,D5
	ADDX.L	D4,D6
.svt2	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),(A6)+
	ADDQ	#1,A6
	ADD	D3,D5
	ADDX.L	D4,D6
.svt3	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),(A6)+
	ADDQ	#1,A6
	ADD	D3,D5
	ADDX.L	D4,D6
.svt4	DBRA	D7,.4b

.pt ;Remettre les pointeurs
	MOVE.L	D6,VSamplePointerInt(A5)
	MOVE	D5,VSamplePointerFrac(A5)
	MOVE.L	A4,VSamplePointerEnd(A5)
	RTS

GEN_VOICE_8_ST_A:
	MOVE.L	VSamplePointerEnd(A5),D0
	MOVEA.L D0,A4
	BEQ.S	.V0 ;Au d‚part=0
	BMI.S	.V0
	MOVE.L	VSamplePointerInt(A5),D6
	MOVE	VSamplePointerFrac(A5),D5
	LEA	INCREMENTS(PC),A0
	MOVE	VPitch(A5),D0
	SUBI	#96,D0
	BMI.S	.V0 ;S‚curit‚
	MOVEQ	#0,D4
	LSL	#2,D0
	MOVE	(A0,D0),D4
	MOVE	2(A0,D0),D3
.lvl	LEA	LEVELS_AD(PC),A0
	ADDA.L	(A0),A0
	MOVE	VVolume(A5),D0
	LSL	#8,D0 ;*256
	LEA	(A0,D0),A3
	BRA.S	.MUSIK4

.V0:	LEA	-1,A4
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.lvl

.MUSIK4	BSR.S	INSTANT
	MOVEQ	#0,D0 ;Sert sur 16 bits
	MOVE	BUFFER_LN(PC),D7
	LSR	#2,D7
	SUBQ	#1,D7
.4b	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),D1
	ADD.B	D1,(A6)+
	ADDQ	#1,A6 ;Sauter l'autre voie
	ADD	D3,D5
	ADDX.L	D4,D6
.vad1	CMP.L	A4,D6
	BLO.S	.svt1
	MOVE.L	VSampleRepeatEnd(A5),D1
	BMI.S	.V0_1
	SUB.L	A4,D6
	ADD.L	VSampleRepeatStart(A5),D6
	MOVEA.L D1,A4
	BRA	.vad1
.V0_1	MOVEA.L D1,A4
	LEA	SAMPLE_NUL(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
.svt1	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),D1
	ADD.B	D1,(A6)+
	ADDQ	#1,A6 ;Sauter l'autre voie
	ADD	D3,D5
	ADDX.L	D4,D6
.svt2	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),D1
	ADD.B	D1,(A6)+
	ADDQ	#1,A6 ;Sauter l'autre voie
	ADD	D3,D5
	ADDX.L	D4,D6
.svt3	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),D1
	ADD.B	D1,(A6)+
	ADDQ	#1,A6 ;Sauter l'autre voie
	ADD	D3,D5
	ADDX.L	D4,D6
.svt4	DBRA	D7,.4b

.pt ;Remettre les pointeurs
	MOVE.L	D6,VSamplePointerInt(A5)
	MOVE	D5,VSamplePointerFrac(A5)
	MOVE.L	A4,VSamplePointerEnd(A5)
	RTS

INSTANT: ;Sert … g‚n‚rer SortieVx
	MOVEA.L	D6,A0
	MOVE.B	(A0),D0
	MOVE.B	(A3,D0),D0
	MOVEQ	#1,D1
	MOVE.B	MODULE_MO_ST(PC),D2
	BNE.S	.reel
	MOVEQ	#2,D1
.reel	LSL	D1,D0
	LEA	SortieVx(PC),A0
	MOVE.B	D0,(A0)
	RTS

MUSIC:
	MOVE.L	A6,-(SP)
 ;prochain FRAME
	LEA	BUFFER_ADS+8+1(PC),A6
	MOVE.B	(A6)+,SND_BH+1
	MOVE.B	(A6)+,SND_BM+1
	MOVE.B	(A6)+,SND_BL+1
	ADDQ	#1,A6
	MOVE.B	(A6)+,SND_EH+1
	MOVE.B	(A6)+,SND_EM+1
	MOVE.B	(A6)+,SND_EL+1
 ;Sauvegarde totale
	MOVEM.L D0-A5,-(SP)
 ;Niveau normal au plus t“t
	BCLR	#7,MFP_ISRA+1
	ANDI	#$FBFF,SR
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
	BRA.S	MFin

.osc:	MOVEA.L BUFFER_ADS+8(PC),A6
	LEA	VOICE0(PC),A5
	LEA	GEN_VOICE0(PC),A0
	MOVEA.L (A0),A0
	JSR	(A0)
					LEA	SortieV0(PC),A0
					MOVE.B	SortieVx(PC),(A0)
	MOVEA.L BUFFER_ADS+8(PC),A6
	ADDA	VOICE_OFFSET(PC),A6
	LEA	VOICE1(PC),A5
	LEA	GEN_VOICE1(PC),A0
	MOVEA.L (A0),A0
	JSR	(A0)
					LEA	SortieV1(PC),A0
					MOVE.B	SortieVx(PC),(A0)
	MOVEA.L BUFFER_ADS+8(PC),A6
	ADDA	VOICE_OFFSET(PC),A6
	LEA	VOICE2(PC),A5
	LEA	GEN_VOICE2(PC),A0
	MOVEA.L (A0),A0
	JSR	(A0)
					LEA	SortieV2(PC),A0
					MOVE.B	SortieVx(PC),(A0)
	MOVEA.L BUFFER_ADS+8(PC),A6
	LEA	VOICE3(PC),A5
	LEA	GEN_VOICE3(PC),A0
	MOVEA.L (A0),A0
	JSR	(A0)
					LEA	SortieV3(PC),A0
					MOVE.B	SortieVx(PC),(A0)
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
	LEA	ModuleName+SampleInfos*31+2+128(A0),A2
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
	LEA	ModuleName+SampleInfos*15+2(A0),A2
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
	MOVE.B	-2(A2),D0
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
	LEA	ModuleName(A0),A0
	LEA	SAMPLE_ADS(PC),A2
	MOVE	SAMPLE_NB(PC),D1
	SUBQ	#1,D1
.3	MOVE.L	D0,(A2)+
	MOVEQ	#0,D2
	MOVE	SampleLength(A0),D2
	ADDA	#SampleInfos,A0
	LSL.L	#1,D2
	ADD.L	D2,D0
	CMP.L	A1,D0
	BHI	mod_inc
	DBF	D1,.3
rep_verif: ;V‚rifier la validit‚ des Repeat Loop et patcher si incoh‚rence
	MOVEA.L MODULE_AD(PC),A0
	LEA	ModuleName(A0),A0
	MOVE	SAMPLE_NB(PC),D0
	SUBQ	#1,D0
.ss	MOVE	SampleLength(A0),D1
	MOVE	SampleRepeatStart(A0),D2
	CMP	D1,D2
	BHS.S	.1
	ADD	SampleRepeatLength(A0),D2
	CMP	D1,D2
	BHI.S	.2
.3	ADDA	#SampleInfos,A0
	DBRA	D0,.ss
	LEA	MODULE_ERROR(PC),A0
	SF	(A0)
	BSR.S	EXPAND ;Sp‚cifique au STE
	RTS

.1	MOVE	#1,SampleRepeatLength(A0)
	BRA	.3

.2	MOVE	D1,D2
	SUB	SampleRepeatStart(A0),D2
	MOVE	D2,SampleRepeatLength(A0)
	BRA	.3

EXPAND: ;pour une zone de 32 octets apr‚s chaque sample
	MOVEM.L D3-D7/A3-A6,-(SP)
;D7=Sample (30-0)(14-0)
;D6=Zone Length (32)
;A6=Sample Infos
;A5=Addr. in SAMPLE_ADS
;A4=New Sample Start
	MOVE	SAMPLE_NB(PC),D7
	SUBQ	#1,D7
	MOVEQ	#32,D6
	MOVEA.L MODULE_AD(PC),A6
	MOVE	D7,D0
	MULU	#SampleInfos,D0
	LEA	ModuleName(A6,D0),A6
	LEA	SAMPLE_ADS(PC),A5
	MOVE	D7,D0
	LSL	#2,D0
	ADDA	D0,A5
	MOVEA.L (A5),A4
.corps	MOVE	D7,D0
	LSL	#5,D0 ;*32
	ADDA	D0,A4
 ;Copions sur Sample Length
	MOVEQ	#0,D0
	MOVE	SampleLength(A6),D0
	BEQ.S	.zone
	LSL.L	#1,D0
	MOVEA.L (A5),A0
	ADDA.L	D0,A0
	LEA	(A4,D0.L),A1
	LSR.L	#1,D0
.b1	MOVE	-(A0),-(A1)
	DBRA	D0,.b1
.zone ;Copier la source born‚e
	;A3=Start
	;A2=End
	MOVEQ	#0,D0
	MOVE	SampleLength(A6),D0
	BEQ.S	.snul
	MOVEQ	#0,D1
	MOVE	SampleRepeatLength(A6),D1
	CMPI	#1,D1
	BLS.S	.rnul
	MOVEQ	#0,D2
	MOVE	SampleRepeatStart(A6),D2
	LSL.L	#1,D2
	LEA	(A4,D2.L),A3
	LSL.L	#1,D1
	LEA	(A3,D1.L),A2

.rz	MOVEA.L A3,A0 ;Source
	MOVEQ	#0,D0
	MOVE	SampleLength(A6),D0
	LSL.L	#1,D0
	LEA	(A4,D0.L),A1 ;Destination
	MOVE	D6,D0
	LSR	#1,D0
	SUBQ	#1,D0
.b2	MOVE	(A0)+,(A1)+
	CMPA.L	A2,A0
	BEQ.S	.ns
.rs	DBRA	D0,.b2
	BRA.S	.svt

.ns	MOVEA.L A3,A0 ;Source
	BRA	.rs

.snul	LEA	SAMPLE_NUL(PC),A3
	LEA	2(A3),A2
	BRA	.rz

.rnul	MOVEA.L A4,A3
	LSL.L	#1,D0
	LEA	(A4,D0.L),A2
	BRA	.rz

.svt	SUBA	#SampleInfos,A6
 ;Et actualiser SAMPLE_ADS
	MOVE.L	A4,(A5)
	MOVEA.L -(A5),A4
	DBRA	D7,.corps
	MOVEM.L (SP)+,D3-D7/A3-A6
	RTS

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
i_voices: ;... et Les variables voies
	LEA	VOICE0(PC),A0
	MOVE	#(VOICE1-VOICE0)*4/2-1,D0
.1	CLR	(A0)+
	DBRA	D0,.1
	RTS

I_BUFFER_ADS: ;Nouvelle longueur tampon
	LEA	BUFFER_LNS(PC),A0
	MOVE	TIMER_BEAT(PC),D0
	SUBI	#33,D0
	LSL	#1,D0
	MOVE	(A0,D0),D0
	LEA	BUFFER_LN(PC),A0
	MOVE	D0,(A0)
	MOVE.B	MODULE_MO_ST(PC),D1
	BEQ.S	.2
	LSL	#1,D0
.2	LEA	BUFFER_ADS(PC),A0
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
	LSL	#2,D0
	LEA	(A1,D0),A1
	MOVEQ	#33,D0
	MOVE	#(255-32)-1,D1
.1	MOVE.L	(A1),D2
	DIVU	D0,D2
	ANDI	#$FFFC,D2 ;S'assurer de la parit‚ et r‚duire le temps machine
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
	MOVE.L	A1,8(A0)
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
	LSL	#2,D0
	LEA	(A1,D0),A1
	MOVEQ	#96,D0
	MOVE	#1024-1,D1
	MOVEM.L  D3-D4,-(SP)
.1 ;R‚aliser la division sur les parties INT et FRAC
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE	(A1),D2
	MOVE	2(A1),D3
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
	LEA	MODULE_MO_ST(PC),A2
	MOVE.L	D3,-(SP)
.8b	ADDA.L	#65*256,A0
	MOVEQ	#7,D0 ;D‚calage … droite pour 1/2 ...
	TST.B	(A2)
	BNE.S	.1
	MOVEQ	#8,D0 ;... ou 1/4 fois la saturation d'une voie
.1	MOVEQ	#65-1,D1 ;65 tables
.3	MOVE	#256-1,D2 ;256 valeurs
.2	MOVE.B	D2,D3
	EXT.W	D3
	MULS	D1,D3
	ASR	D0,D3
	MOVE.B	D3,-(A0)
	DBF	D2,.2
	DBF	D1,.3
.f	MOVE.L	(SP)+,D3
	RTS

I_ROUTS: ;les routines et valeur utiles
	LEA	GEN_VOICE0(PC),A0
	LEA	VOICE_OFFSET(PC),A1
	MOVE.B	MODULE_MO_ST(PC),D0
	BNE.S	.8s

.8m	LEA	GEN_VOICE_8_MO_O(PC),A2
	MOVE.L	A2,(A0)+
	LEA	GEN_VOICE_8_MO_A(PC),A2
	MOVE.L	A2,(A0)+
	MOVE.L	A2,(A0)+
	MOVE.L	A2,(A0)+
	CLR	(A1)
.f	BSR.S	MOINS2
	RTS

.8s	LEA	GEN_VOICE_8_ST_O(PC),A2
	MOVE.L	A2,(A0)+
	MOVE.L	A2,(A0)+
	LEA	GEN_VOICE_8_ST_A(PC),A2
	MOVE.L	A2,(A0)+
	MOVE.L	A2,(A0)+
	MOVE	#1,(A1)
	BRA	.f

MOINS2: ;Si MODULE_FREQ=50 KHz avec STE … 8 MHz on tue 2 voies
	CMPI.B	#2,2 ;si TOS >=2.00 ‡a va
	BHS.S	.f
	MOVE	MODULE_FREQ(PC),D0
	CMPI	#3,D0 ;50 KHz
	BNE.S	.f
	LEA	GEN_VOICE2(PC),A0
	LEA	.f(PC),A1
	MOVE.L	A1,(A0)+
	MOVE.L	A1,(A0)+
.f	RTS

I_F030:
_cookie=$5A0
		MOVE.L	_cookie,D0
		BEQ.S	.f
		MOVEA.L D0,A0
.2		TST.L	(A0)
		BEQ.S	.f
		CMPI.L	#'_MCH',(A0)+
		BEQ.S	.1
		ADDQ	#4,A0
		BRA	.2
.1		CMPI	#3,(A0)
		LEA	F030(PC),A0
		SEQ	(A0)
.f		RTS

S_REGS: ;Sauvegarde
	ORI	#$0700,SR
	LEA	REGS_ORG(PC),A0
	MOVE	SND_CR,D0
		BCLR	#1,SND_CR+1
.pause		BTST	#0,SND_CR+1
		BNE	.pause
	MOVE	SND_MODE1,(A0)+
		LEA	F030(PC),A1
		TST.B	(A1)
		BEQ.S	.1
		MOVE.B	SND_FREQ+1,(A0)+
		ADDQ	#1,A0
.1	MOVE.B	SND_BH+1,(A0)+
	MOVE.B	SND_BM+1,(A0)+
	MOVE.B	SND_BL+1,(A0)+
	MOVE.B	SND_EH+1,(A0)+
	MOVE.B	SND_EM+1,(A0)+
	MOVE.B	SND_EL+1,(A0)+
		TST.B	(A1)
		BEQ.S	.2
		MOVE	SND_XBARIN,(A0)+
		MOVE	SND_XBAROUT,(A0)+
		MOVE.B	SND_MODE2+1,(A0)+
		ADDQ	#1,A0
.2	MOVE.B	MFP_DDR+1,(A0)+
	MOVE.B	MFP_AER+1,(A0)+
	MOVE.B	MFP_IERA+1,(A0)+
	MOVE.B	MFP_IMRA+1,(A0)+
	MOVE	D0,(A0)+
	LEA	I7V_ORG(PC),A0
	MOVE.L	$100+15*4,(A0)
	ANDI	#$FBFF,SR
	RTS

R_REGS: ;Restitution
	ORI	#$0700,SR
	LEA	REGS_ORG(PC),A0
	MOVE	(A0)+,SND_MODE1
		LEA	F030(PC),A1
		TST.B	(A1)
		BEQ.S	.1
		MOVE.B	(A0)+,SND_FREQ+1
		ADDQ	#1,A0
.1	MOVE.B	(A0)+,SND_BH+1
	MOVE.B	(A0)+,SND_BM+1
	MOVE.B	(A0)+,SND_BL+1
	MOVE.B	(A0)+,SND_EH+1
	MOVE.B	(A0)+,SND_EM+1
	MOVE.B	(A0)+,SND_EL+1
		TST.B	(A1)
		BEQ.S	.2
		MOVE	(A0)+,SND_XBARIN
		MOVE	(A0)+,SND_XBAROUT
		MOVE.B	(A0)+,SND_MODE2+1
		ADDQ	#1,A0
.2	MOVE.B	(A0)+,MFP_DDR+1
	MOVE.B	(A0)+,MFP_AER+1
	MOVE.B	(A0)+,MFP_IERA+1
	MOVE.B	(A0)+,MFP_IMRA+1
	MOVE	(A0)+,SND_CR
	MOVE.L	I7V_ORG(PC),$100+15*4
	ANDI	#$FBFF,SR
	RTS

I_REGS: MOVE.B	F030(PC),D0
	BNE.S	I_REGS_F030
 ;Selon le mode demand‚
	ORI	#$0700,SR
 ;DMA
	LEA	SND_MODE1,A0
	MOVE	(A0),D0
	ANDI	#%1111111101111100,D0
	;		  ^	^^
	MOVE.B	MODULE_MO_ST(PC),D1
	BNE.S	.2
	BSET	#7,D0
.2 ;FREQUENCY
	OR	MODULE_FREQ(PC),D0
	MOVE	D0,(A0)
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
   ;Selon le type de moniteur ...
	BTST	D0,MFP_GPIP+1
	BEQ.S	.3 ;MONO
	BSET	D0,MFP_AER+1
.4	BSET	D0,MFP_IERA+1
	BSET	D0,MFP_IMRA+1
	LEA	MUSIC(PC),A0
	MOVE.L	A0,$100+15*4
	ANDI	#$FBFF,SR
	RTS

.3	BCLR	D0,MFP_AER+1
	BRA	.4

I_REGS_F030:
 ;Selon le mode demand‚
	ORI	#$0700,SR
 ;DMA
	LEA	SND_MODE1,A0
	MOVE	(A0),D0
	ANDI	#%1100110000111100,D0
	;		  ^^	^^
	MOVE.B	MODULE_MO_ST(PC),D1
	BNE.S	.2
	BSET	#7,D0
.2 ;FREQUENCY
	OR	MODULE_FREQ(PC),D0
	MOVE	D0,(A0)
 ;DAC avec XBAR et sans ADC
	LEA	SND_MODE2+1,A0
	MOVE.B	(A0),D0
	ANDI.B	#%11111100,D0
	ORI.B	#%00000010,D0
	MOVE.B	D0,(A0)
	CLR.B	SND_FREQ+1
 ;FRAME
	LEA	BUFFER_ADS+1(PC),A0
	MOVE.B	(A0)+,SND_BH+1
	MOVE.B	(A0)+,SND_BM+1
	MOVE.B	(A0)+,SND_BL+1
	ADDQ	#1,A0
	MOVE.B	(A0)+,SND_EH+1
	MOVE.B	(A0)+,SND_EM+1
	MOVE.B	(A0)+,SND_EL+1
 ;XBAR
	LEA	SND_XBARIN,A0
	MOVE	(A0),D0
	ANDI	#%0000111111110000,D0
	ORI	#%1000000000001001,D0
	MOVE	D0,(A0)
 ;CONTROL pour MFP_GPIPb7
	LEA	SND_CR,A0
	MOVE	(A0),D0
	ANDI	#%1111000001001100,D0
	ORI	#%0000000100000000,D0
	MOVE	D0,(A0)
 ;MFP pour MFP_GPIPb7
	MOVEQ	#7,D0
	BCLR	D0,MFP_DDR+1
	BSET	D0,MFP_AER+1
	BSET	D0,MFP_IERA+1
	BSET	D0,MFP_IMRA+1
	LEA	MUSIC(PC),A0
	MOVE.L	A0,$100+15*4
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
	LEA	MODULE_MO_ST(PC),A0
	SF	(A0)
	LEA	MODULE_FREQ(PC),A0
	MOVEQ	#0,D0
	MOVE.B	F030(PC),D1
	BEQ.S	.1
	MOVEQ	#1,D0
.1	MOVE	D0,(A0)
	RTS

INTERPRET: ;Interpr‚tation des paramˆtres
	MOVE	4(SP),D0
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
.pon	BSR	I_F030
	BSR	S_REGS
	BSR	I_PARAMS
	BSR	I_VARS ;pour initialiser TIMER_BEAT
	BSR	I_BUFFERS
	BSR	I_INCREMENTS
	BSR	I_LEVELS
	BSR	I_ROUTS
	BSR	I_REGS
	RTS
.poff	BSR	R_REGS
	RTS

open	BSR	pver
	BSR.S	stop
	LEA	MODULE_AD(PC),A0
	MOVE.L	4+12(SP),(A0)
	LEA	MODULE_LN(PC),A0
	MOVE.L	4+16(SP),(A0)
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
	CMP.B	-2(A1),D1
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
	LSL	#1,D0
	MOVE	(A0,D0),D0
	LEA	powr(PC),A0
	JSR	(A0,D0)

m8_16	BSR	pver
	SF	D2 ;Drapeau pour new_hard

mo_st	MOVE	8(SP),D0
	BEQ.S	freq
	ST	D2
	LEA	MODULE_MO_ST(PC),A0
	NOT.B	(A0)

freq	MOVE	10(SP),D0
	BEQ.S	.1
	ST	D2
	SUBQ	#1,D0
	ANDI	#%11,D0
	LEA	MODULE_FREQ(PC),A0
	MOVE	D0,(A0)
	BNE.S	.1
		MOVE.B	F030(PC),D1
		BEQ.S	.1
		MOVEQ	#1,D0
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
	BSR	I_ROUTS
	BSR	I_REGS
	MOVE	(SP)+,D0
	TST.B	D0
	BEQ.S	.2
	BSR	PLAY
.2	LEA	MODULE_ERROR(PC),A0
	MOVE.B	(A0),D0
	RTS

 DATA

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
	DC.L  15646
	DC.L  31291
	DC.L  62583
	DC.L 125165

GEN_INCREMENTS: ;3579546/DMAFreq (INT16+FRAC16)
	DC.L 37484784
	DC.L 18742392
	DC.L  9371196
	DC.L  4685598

SAMPLE_NUL: ;pour les voies mortes
	DC.W 0

 ;Pour simuler LEVELS(PC)
LEVELS_AD DC.L LEVELS-LEVELS_AD
;**********************************************

;*** PARAMETRES *********************
MODULE_POWER	DC.B 0 ;0:OFF	-1:ON
		DC.B 0
;************************************

 BSS

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
VOICE0: ;Longueur 127 maxi car adress‚e par d(A5)

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
GEN_VOICE0    DS.L 1
GEN_VOICE1    DS.L 1
GEN_VOICE2    DS.L 1
GEN_VOICE3    DS.L 1
VOICE_OFFSET  DS.W 1 ;0 , 1 ou 2 octets
;**************************************

;*** SAUVEGARDE **********************
I7V_ORG  DS.L 1  ;Vecteur I7 d'origine
REGS_ORG DS.W 11 ;Registres  d'origine
;*************************************

;*** PARAMETRES ***********************************
MODULE_AD	DS.L 1 ;Adresse  du *.MOD (0:Vide)
MODULE_LN	DS.L 1 ;Longueur du *.MOD
MODULE_ERROR	DS.B 1 ;0:No error  -1:Error
MODULE_PLAY	DS.B 1 ;0:Pause     -1:Play
MODULE_FAST	DS.B 1 ;0:Normal    -1:Fast
MODULE_REPEAT	DS.B 1 ;0:No repeat -1:Repeat
MODULE_MO_ST	DS.B 1 ;0:Mono	    -1:Stereo
		DS.B 1
MODULE_FREQ	DS.W 1 ;Frequency (0-3)
;**************************************************

;*** MACHINE ***
F030	DS.B 1+1
;***************

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
 ;car pour 2 ou 4 voies.
;*******************************************************************************
	END
