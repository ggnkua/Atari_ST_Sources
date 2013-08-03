************************************************************************************************
*	MEGATRACKER REPLAY ROUT POUR JAGUAR V 0.5
*
*	CE SOURCE EST PREVU POUR ETRE EN MODE 800*600 TAB 8
*
************************************************************************************************
		include	"includes/jaguar.inc"

ISTACKD			= D_ENDRAM-256-4	; Location of interrupt stack
ADR_DPCODE		= D_RAM			; == DSP Object Processor Interrupt

SERIAL_CLOCK_FREQUENCY	= 12
FREQ_REPLAY		= 26592000/32/(2*(SERIAL_CLOCK_FREQUENCY+1))

*-----------------------------------------------------------------------------------------------
		text
*-----------------------------------------------------------------------------------------------

		.68000
sndinit:
		moveq	#0,d0
		move.l	d0,R_I2S
		move.l	d0,L_I2S
		move.w	#$100,JOYSTICK
		
		move.l	d0,D_CTRL
		move.l	d0,D_FLAGS
		
		move.l	#SERIAL_CLOCK_FREQUENCY,SCLK		*	31961 Hz
		move.l	#$15,SMODE
		
		move.w	d0,JPIT2
		move.w	d0,JPIT1
		
		lea	dspcode_start,a0	; address of GPU code in RAM
		lea	D_RAM,a1			
		move.l	#(dspcode_end-dspcode_start)-1,d0
		bsr	gpuload
		
		move.l	#_dspcode,D_PC		; address of GPU code 
		move.l  #DSPGO,D_CTRL		; Start GPU
		rts
************************************************************************************************
		dsp
		
		phrase
		
dspcode_start:
		org	D_RAM
		
		movei	#INIT,r0		* INT 0    DSP START
		jump	(r0)
		nop
		nop
		nop
		nop
		
		movei	#_i2s_int,r29		* INT 1    I2S
		jump	(r29)
		nop
		nop
		nop
		nop
		
		movei	#TEMPO,r29
		jump	(r29)
		nop
		
_dspcode:	movei	#ISTACKD,r31

		movei	#D_FLAGS,r1
		load	(r1),r0
		movei	#REGPAGE|D_I2SENA,r2
		or	r2,r0
		store	r0,(r1)
		nop
		nop


************************************************************************************************
*************  INITIALISATION ET RELOGEMENT  ***************************************************
*************          DU PLAYER             ***************************************************
************************************************************************************************
* R0 = No OF THE ZIK			*
* R1 = ADRESS OF THE MODULE		*
					*
INIT:	MOVEI	#NO_MUS,R2		* STORE LE No DE ZIK CHOISI
	STOREW	R0,(R2)			*
					*
	MOVEI	#ADDMOD,R2		* STORE L'ADRESSE DU MODULE
	STORE	R1,(R2)			*
					*
	MOVEI	#DEJA,R2		* VERIFIE SI ON A DEJA RELOGE LE MODULE
	MOVEI	#RELOGE,R0		*
	LOADB	(R0),R0			*
	CMPQ	#1,R0			*
	JUMP	EQ,(R2)			* SI OUI ON PASSE AU TRAITEMENT DU No DE ZIK
*-----------------------------------------------------------------------------------------------
	MOVEI	#NBVOICE,R0		* CALCUL LA LONGUEUR D'1 PATT
	MOVE	R1,R2			* EN FONCTION DU NOMBRE DE VOIES
	ADD	#S_NBVOICE,R2		*
	LOADW	(R2),R2			*
	SUBQ	#1,R2			*
	STOREW	R2,(R0)			*
	ADD	R2,R2			*
	ADDQ	#2,R2			*
	MOVEI	#LEN_ONE_PATT,R0	*
	STOREW	R2,(R0)			*
					*
	MOVEI	#LEN_ONE_MUS,R0		* CALCUL LA LONGUEUR D'UNE MUS
	MOVE	R1,R2			* EN FONCTION DU NOMBRE DE VOIES
	ADD	#S_NBVOICE,R2		*
	LOADW	(R2),R2			*
	ADD	R2,R2			*
	ADD	#I_MASTERVOL_MUS,R2	*
	STOREW	R2,(R0)			*
					*
	MOVEI	#TABLE_DIGINOTE,R2	* RETROUVE LA TABLE DES NOTES
	MOVEI	#DIGINOTE1,R3		*
	MOVEI	#16,R1			*
.ULP	STORE	R3,(R2)			*
	ADDQ	#4,R2			*
	ADDQ	#192,R3			*
	SUBQ	#1,R1			*
	JR	NE,ULP			*
*-----------------------------------------------------------------------------------------------
DEJA:	MOVEI	#ADDMOD,R31		*
	LOAD	(R31),R31		* R31 = ADD DEB MOD (POUR LA RELOCATION)
					*
	MOVEI	#NO_MUS,R0		*
	LOADW	(R0),R0			* R0  = No MUSIQUE
					*
	MOVE	R31,R1			*
	ADDQ	#S_NBMUS,R1		*
	LOADW	(R1),R1			*
	SUBQ	#1,R1			*
	CMP	R1,R0			* REGARDE SI No OF ZIK PAS PLUS GRAND QUE
	JUMP	GE,FIN_INIT		* LE NOMBRE DE ZIK DU MODULE
					*
REINIT_TEMPO				*
	MOVEI	#TEMPO,R0		*
	STOREB	#125,(R0)		*
	MOVEI	#SPEED,R0		*
	STOREW	#6,(R0)			*
	MOVEI	#TICK,R0		*
	STOREW	#0,(R0)			*
	MOVEI	#TIMER_CONTROL,R0	*
	STOREB	#5,(R0)			*
	MOVEI	#TIMER_DATA,R0		*
	STOREB	#192,(R0)		*
	MOVEI	#CODE_SAMPLE_LENGHT,R0	*
	STOREW	#FREQ_REPLAY/50,(R0)	*
	MOVEI	#SAMPLE_LENGHT,R0	*
	STOREW	#FREQ_REPLAY/50,(R0)	*
					*
	MOVEI	#CURMUS,R1		*
	STOREB	R0,(R1)			* SAUVE LE No DE ZIK COURANTE
	MOVEI	#LEN_ONE_MUS,R2		*
	LOADW	(R2),R2			*
	MULT	R0,R2			*
	LOAD	(R31+S_DEBMUS),R30	*
	ADD	R30,R2			* R2 = ADD DEB DE LA MUS COURANTE DANS LE MOD
	ADD	R31,R2			*
	MOVEI	#ADDCURSEQ,R3		*
	LOAD	(R2+#ADDDEB_MUS),R29	*
	ADD	R31,R29			*
	STORE	R29,(R3)		* SAUVE ADD DEB DE LA SEQ COURANTE
					*
	MOVEI	#CURPOS,R3		* REINIT POSITION COURANTE DANS LA SEQ COURANTE
	MOVEI	#0,R4			*
	STOREW	R4,(R3)			*
					*
	MOVEI	#MASTER_VOL_LEFT,R3	* PREND LE MASTER VOLUME INITIAL
	MOVE	R2,R4			*
	ADDQ	#I_MASTERVOL_MUS,R4	*
	LOADW	(R4),R4			*
	STOREW	R4,(R3)			*
					*
	MOVEI	#SPEED+1,R3		* PREND LE SPEED INITIAL
	MOVE	R2,R4			*
	ADDQ	#I_SPEED_MUS,R4		*
	LOADB	(R4),R4			*
	STORE	R4,(R3)			*
					*
	MOVEI	#TEMPO+1,R3		* PREND LE TEMPO INITIAL
	MOVE	R2,R4			*
	ADDQ	#I_TEMPO_MUS,R4		*
	LOADB	(R4),R4			*
	STORE	R4,(R3)			*
					*
	MOVEI	#CURLEN,R3		* PREND LA LONGUEUR DE LA ZIK COURANTE
	MOVE	R2,R4			*
	ADDQ	#LEN_MUS,R4		*
	LOADW	(R4),R4			*
	ADDQ	#1,R4			*
	STOREB	R4,(R3)			*
					*
	MOVEI	#CURLOP,R3		* PREND LA POSITION DE LOOP DE LA SEQUENCE COURANTE
	MOVE	R2,R4			*
	ADDQ	#RESTART_MUS,R4		*
	LOADW	(R4),R4			*
	STOREB	R4,(R3)			*
					*
	MOVEI	#ADDCURSEQ,R3		* RECHERCHE L'ADD DEB
	LOADW	(R3),R8			* DE LA PATT COURANTE (LA 1ere)  =  R8
	MOVEI	#CURPATT,R3		*
	STOREW	R8,(R3)			*
	MOVEI	#LEN_ONE_PATT,R3	*
	LOADW	(R3),R4			*
	MULT	R4,R8			*
	LOAD	(R31+#S_DEBPATT),R9	*
	ADD	R31,R8			*
	ADD	R9,R8			*
	ADD	R31,R8			*
	MOVEI	#ADDCURPATT,R3		*
	STORE	R8,(R3)			*
					*
	MOVEI	#LENCURPATT,R3		*
	LOADW	(R8),R4			*
	STOREW	R4,(R3)			*
	ADDQ	#2,R8			*
*-----------------------------------------------------------------------------------------------	
* 	ICI ON VA PREPARER LES DONNêES CONCERNANT LES VOIES
*-----------------------------------------------------------------------------------------------	
	MOVEI	#PILEVOIE,R3		* LEA		PILEVOIE,A3
	LOAD	(R31+S_DEBTABTRACK),R5	* MOVE.L	S_DEBTABTRACK(A1),A5
	MOVEI	#NBVOICE,R10		* MOVE.W	S_NBVOICE(A1),D0
	LOADW	(R10),R10		*
	MOVE	R2,R1			* LEA		I_VOL_MUS(A2),A1
	ADD	#I_VOL_MUS,R1		*
					*					
.MM	LOAD	(R3),R4			* MOVE.L	(A3)+,A4	
	ADDQ	#4,R3			*
					*
	LOADW	(R8),R11		* MOVE.W	(A0)+,D1
	ADDQ	#2,R8			*
					*
	MOVE	R4,R20			* MOVE.W	D1,NBCURTRACK(A4)
	ADDQ	#NBCURTRACK,R20		*
	STOREW	R11,(R20)		*
					*
	MOVE	R5,R20			* MOVE.L	(A5,D1.L*4),A6
	MULT	#4,R11			*
	ADD	R11,R20			*
	MOVE	(R20),R20		*
					*
	MOVEW	(R20),R21		* MOVE.W	(A6)+,LENCURTRACK(A4)
	ADDQ	#2,R20			*
	MOVE	R4,R22			*
	ADDQ	#LENCURTRACK,R22	*	
	STOREW	R21,(R22)		*
					*
	MOVE	R4,R22			* MOVE.L	A6,ADDCURTRACK(A4)
	ADD	#ADDCURTRACK,R22	*
	STORE	R20,(R22)		*
					*
	MOVE	R4,R22			* MOVE.L	A6,INPATT2(A4)
	ADD	#INPATT2,R22		*
	STORE	R20,(R22)		*
					*
	MOVE	R4,R22			* MOVE.W	(A1)+,LEFT_VOL(A4)
	ADD	#LEFT_VOL,R22		*
	LOADW	(R1),R23		*
	ADDQ	#2,R1			*
	STOREW	R23,(R22)		*
					*
	MOVE	R4,R22			* BSET.B	#0,KIND_VOICE(A4)
	ADD	#KIND_VOICE,R22		*
	LOADW	(R22),R23		*
	BSET	#0,R23			*
	STOREW	R23,(R22)		*
					*
	MOVE	R4,R22			* MOVE.W	#0,EMPTY_LINE(A4)
	ADD	#EMPTY_LINE,R22		*
	MOVEI	#0,R23			*
	STOREW	R23,(R22)		*
					*
	SUBQ	#1,R10			* SUBQ.W	#1,D0
	JUMP	NE,.MM			* BNE.S		.MM
					*
	MOVEI	#INPATT,R3		*
	STOREW	R23,(R3)		*
					*	
FIN_INIT:				*
	MOVEI	FIN_INIT,R17		*
	JUMP	(R17)			*
	NOP				*
					*
					*
************************************************************************************************
* 	ROUTINE QUI DOIT ETRE JOUE DANS LE TIMER 2   (EN TEMPO)
*
* 	REGISTRES UTILISES:
*
* 	R31 = ADD DEB DU MODULE (POUR LA RELOCATION)
*	R30 = ADD DE RETOUR POUR SIMULER UN JSR/BSR
************************************************************************************************
TEMPO:	MOVEI	#ADDMOD,R29		*
	LOAD	(R29),R31		*
					*
	MOVEI	#VOICE0,R6		* R6 = DATA SUR LA VOIE No 0
	MOVEI	#ACTIVE_VOICE_0,R29	*
	MOVEI	#RTS_ACTIVE_VOICE_0,R30	*
	JUMP	(R29)			*
	NOP				*
RTS_ACTIVE_VOICE_0:			*
	MOVEI	#MIX_VOICE_0,R29	*
	MOVEI	#RTS_MIX_VOICE_0,R30	*
	JUMP	(R29)			*
	NOP				*
					*
RTS_MIX_VOICE0:				*
	MOVEI	#LECTURE_PATTERN,R29	*
	MOVEI	#RTS_LECTURE_PATTERN,R30
	JUMP	(R29)			*
	NOP				*
RTS_LECTURE_PATTERN:			*
	MOVEI	#WAIT,R29		*
WAIT	JUMP	(R29)			*
	NOP				*
*-----------------------------------------------------------------------------------------------
*	ON JOUE AU MOINS UNE VOIE, MEME SI VIDE, POUR VIDER LE DOUBLE BUFFER CIRCULAIRE
*
*	R0 = POINTEUR DANS LE SAMPLE A TRAITER
*-----------------------------------------------------------------------------------------------
ACTIVE_VOICE_0:				*
	MOVEI	#NIET_ACTIVE_0,R29	*
	MOVEI	#CHOIX_0,R28		*
					*
	MOVE	R6,R7			* TEST SI LA VOIE EST ACTIVE (ZIK OU BRUIT)
	ADDQ	#KIND_VOICE,R7		*
	LOADB	(R7),R8			*
	JUMP	EQ,(R29)		*
					*
	MOVE	R6,R7			* TEST SI LE PANORAMIQUE EST NUL
	ADDQ	#LEFT_VOL,R7		*
	LOADW	(R7),R8			*
	JUMP	EQ,(R29)		*
					*
	LOAD	(R7+#SPL_POINTER),R0	* TEST SI LA VOIE EST VIDE
	JUMP	EQ,(R29)		* R0 = POINTEUR DANS LE SAMPLE A TRAITER
					*
	MOVE	R6,R7			* TEST SI LE VOLUME EST NUL
	ADDQ	#PATT_VOL,R7		*
	LOADW	(R7),R3			* R3 = VOLUME
	JUMP	NE,(R28)		*
					*
NIET_VOICE_0:				*
	MOVEI	#.AA,R29		*
	MOVE	R6,R7			*
	ADDQ	#FREQUENCY,R7		*
	LOADW	(R7),R8			*
	JUMP	EQ,(R29)		*
	MOVEI	#1712,R27		*
	STOREW	R27,(R7)		*
					*
.AA	MOVEI	#.BB,R29		*
	MOVE	R6,R7			*
	ADDQ	#BASE_SPL,R7		*
	LOADW	(R7),R8			*
	JUMP	EQ,(R29)		*
	MOVEI	#8000,R27		*
	STOREW	R27,(R7)		*
	JUMP	(R28)			*
					*
NIET_ACTIVE_0:				*
	MOVE	R6,R7			*
	ADDQ	#FREQUENCY,R7		*
	MOVEI	#1712,R27		*
	STOREW	R27,(R7)		*
	MOVEI	#0,R0			*
	MOVEI	#0,R27			*
	STORE	R27,(R6+#SPL_POINTER)	*
	JUMP	(R28)			*
*-----------------------------------------------------------------------------------------------
CHOIX_0:				*
	MOVEI	MASTER_VOL_LEFT,R15	*
	LOADB	(R15),R5		*
	MOVEI	MASTER_VOL_RIGHT,R16	*
	LOADB	(R16),R6		*
					*
	MOVE	R6,R7			*
	ADDQ	#LEFT_VOL,R7		*
	LOADB	(R7),R20		*
	MULT	R3,R20			*
	MULT	R5,R20			* R20 = VOLUME GAUCHE
					*
	ADDQ	#1,R7			*
	LOADB	(R7),R21		*
	MULT	R3,R21			*
	MULT	R6,R21			* R21 = VOLUME DROIT
					*
					*
	MOVE	R6,R7			*
	ADDQ	#FREQUENCY,R7		*
	LOADW	(R7),R22		*
	MOVE	R6,R7			*
	ADDQ	#BASE_SPL,R7		*
	LOADW	(R7),R5			*
	MULT	R5,R22			*
	MOVEI	#428,R5			*
	DIV	R5,R22			*
	MOVEI	#FREQ_REPLAY,R5		*
	DIV	R5,R22			* R22 = PARTIE ENTIERE  DE LA FREQUENCE
	MOVEI	#D_REMAIN,R24		*
	LOAD	(R24),R23		* R23 = PARTIE DECIMALE DE LA FREQUENCE
					*
	MOVE	R6,R7			*
	ADDQ	#BITS,R7		*
	LOADB	(R7),R26		* R26 = BITS D'ETAT (8/16 BITS, BOUCLE ON/OFF...)
					*
	LOAD	(R6+#LOOP_BEGIN),R24	* R24 = ADD DU DEBUT DE LA BOUCLE
	LOAD	(R6+#LOOP_END),R25	* R25 = ADD DE LA FIN DE LA BOUCLE
					*
	MOVEI	#SAMPLE_LENGHT,R7	*
	LOADW	(R7),R27		* R27 = Nb D'ITERATIONS
					*
	MOVEI	#BUFFER_SAMPLE,R7	* R18 = ADD Oó PLACER LES SAMPLES DANS
	LOAD	(R7),R18		*       LE BUFFER CIRULAIRE
	MOVE	R18,R19			* R18 = GAUCHE
	ADDQ	#2,R19			* R19 = DROITE
					*
	MOVEI	#0,R1			*
	MOVEI	#0,R2			*
	MOVEI	#BCL,R17		*
	MOVEI	#CONT,R16		*
	MOVEI	#TREAT_LOOP,R15		*
					*
BCL:	ADD	R23,R1			*
	ADDC	R22,R2			*
	ADD	R2,R0			*
	CMP	R0,R25			*
	JUMP	GE,(R15)		*
CONT:	LOADB	(R0),R3			*
	LOADB	(R0),R4			*
	MULT	R20,R3			*
	MULT	R21,R4			*
	STOREW	R3,(R18)		*
	STOREW	R4,(R19)		*
	ADDQ	#4,R3			*
	ADDQ	#4,R4			*
	SUBQ	#1,R27			*
	JUMP	NE,(R17)		*
	NOP				*
	STORE	R0,(R7+#SPL_POINTER)	*
	JUMP	(R30)			* RTS
	NOP				*
					*	
TREAT_LOOP:				*
	MOVEI	#0,R1			*
	MOVEI	#0,R2			*
	BTST	#2,R26			*
	JR	NE,NO_LOOP		*
	JUMP	(R16)			*
	MOVE	R24,R0			*
NO_LOOP:				*
	MOVEI	#RIEN,R0		* "RIEN" EST UN BUFFER VIDE DE 128 OCTETS
	MOVEI	#RIEN,R24		*
	JUMP	(R16)			*
	MOVEI	#RIEN+128,R25		*
************************************************************************************************
LECTURE_PATTERN:			*
	MOVEI	#TREAT_EFFECT,R28	* RTS EN RTS_TREAT_VOICE
	MOVEI	#TICK,R0		*
	MOVEI	#SPEED,R1		*
	LOADW	(R0),R2			*
	LAODW	(R1),R3			*
	ADDQ	#1,R2			*
	CMPQ	R2,R3			*
	JUMP	NE,(R28)		*
					*
	MOVEI	#INPATT,R1		*
	LOADW	(R1),R3			*
	MOVEI	#0,R2			*
	ADDQ	#1,R3			*
	STOREW	R2,(R0)			*
	STOREW	R3,(R1)			*
					*
	MOVEI	#SONG1,R29		*
	JUMP	(R29)			*
	NOP				*
RTS_SONG1:				*
	MOVEI	#TREAT_VOICE,R29	*
	BSR	TREAT_VOICE		*
	JUMP	(R29)			*
	NOP				*
					*
RTS_TREAT_VOICE:			*
	JUMP	(R30)			*
	NOP				*
*-----------------------------------------------------------------------------------------------	
SONG1:	MOVEI	#LENCURPATT,R2		*
	LOADW	(R1),R10		*
	LOADW	(R2),R11		*
	CMP	D0,D1			*
	JR	GE,sng1			*
	MOVEI	#RTS_SONG1,R29		*
	JUMP	(R29)			*
	NOP				*
	
sng1	MOVE.W	#0,INPATT
	BSR	RESET_INPATT2
sng2	MOVEM.L	RIEN,D0-D3
	MOVE.W	CURPOS,D0
sng3	MOVE.W	CURLEN,D1
	SUBQ.W	#1,D1
	CMP.W	D0,D1
	BEQ.S	finsong
	ADDQ.W	#1,D0
LLOP	MOVE.W	D0,CURPOS

	MOVEQ	#0,D0
	MOVEQ	#0,D3
	MOVE.W	CURPOS,D0
	MOVE.L	ADDCURSEQ,A0
	MOVE.W	(A0,D0.W*2),D3
	CMP.W	#-1,D3
	BEQ.S	sng1
	MOVE.W	D3,CURPATT

	BSR.S	PATT_TRACK
	RTS
finsong 
	MOVE.W	CURLOP,D0
	BRA	LLOP
*-----------------------------------------------------------------------------------------------	
*	D3 = No PATT DESIRE
PATT_TRACK:
	MOVE.L	ADDMOD,A0
	MOVE.L	S_DEBPATT(A0),A0
	MULU	LEN_ONE_PATT,D3
	LEA	(A0,D3.L),A0
	
	MOVE.L	A0,ADDCURPATT
	MOVE.W	(A0)+,LENCURPATT
	LEA	PILEVOIE,A1
	MOVE.L	ADDMOD,A5
	MOVE.L	S_DEBTABTRACK(A5),A5
	MOVE.W	NBVOICE,D0
	
.MM	MOVE.L	(A1)+,A3
	MOVEQ	#0,D1
	MOVE.W	(A0)+,D1
	MOVE.W	D1,NBCURTRACK(A3)
	MOVE.L	(A5,D1.L*4),A4
	MOVE.W	(A4)+,LENCURTRACK(A3)
	MOVE.L	A4,ADDCURTRACK(A3)
	MOVE.L	A4,INPATT2(A3)
	MOVE.W	#0,EMPTY_LINE(A3)
	DBF	D0,.MM
	RTS
************************************************************************************************
TREAT_VOICE:
	MOVEQ	#0,D0
	MOVE.L	ADDMOD,A4
	
.BB	LEA	CUR_VOICE,A1
	ADDQ.W	#1,(A1)
	MOVE.W	(A1),D0
	CMP.W	S_NBVOICE(A4),D0
	BEQ.S	.AA
	LEA	PILEVOIE,A1
	MOVE.L	(A1,D0.W*4),A1
	BSR.S	TREAT_ONE_VOICE
	BRA.S	.BB
	
.AA	MOVE.W	#-1,(A1)
	TST.B	PATTDELTIME
	BEQ.S	.NO_PATT_DELAY
	SUBQ.B	#1,PATTDELTIME
	BNE.S	.NO_PATT_DELAY
	SUBQ.W	#1,INPATT
	BSR	RECHERCHE_INPATT2
	
.NO_PATT_DELAY
	RTS
************************************************************************************************
TREAT_ONE_VOICE:			*
	MOVE	R1,R7			* SI VOIE SOUNDTRACK (ONLY)
	ADDQ	#KIND_VOICE,R7		*
	LOADB	(R7),R6			*
	BTST	#0,R6			*
	JUMP	EQ,(NO_EFFECT)		*
	NOP				*
					*
	MOVE	R1,R7			*
	ADDQ	#PATT_LINE,R7		*
	MOVEI	#0,R8			*
	STORE	R8,(R7)			*
	STORE	R8,(R7+#2)		*
					*
	MOVE	R1,R7			*
	ADDQ	#EMPTY_LINE,R7		*
	LOADW	(R7),R8			*
	JR	EQ,.HH			*
	SUBQ	#1,R8			*
	STOREW	R8,(R7)			*
	JUMP	(GG)			*
					*
					*
.HH	LOAD	(R1+#INPATT2),R0	*
	JUMP	EQ,VOL_OK		*
	NOP				*
	LOADB	(R0),R10		*
	ADDQ	#1,R0			*
	MOVE	R10,R11			*
	AND	#3,R11			*
	JR	EQ,PAS_VIDE		*
	STOREW	R11,(R7)		*
					*
PAS_VIDE:				*
	BTST	#2,R10			* DECOMPACTE UNE LIGNE DE LA VOIE COURANTE
	JR	EQ,F1			*
	MOVE	R1,R7			*
	LOADB	(R0),R3			*
	ADDQ	#PATT_LINE,R7		*
	ADDQ	#1,R0			*
	MOVEB	R3,(R7)			* NOTE
F1:	BTST	#3,R10			*
	JR	EQ,F2			*
	MOVE	R1,R7			*
	LOADB	(R0),R3			*
	ADDQ	#PATT_LINE+1,R7		*
	ADDQ	#1,R0			*
	MOVEB	R3,(R7)			* INSTRUMENT
F2:	BTST	#4,R10			*
	JR	EQ,F3			*
	MOVE	R1,R7			*
	LOADB	(R0),R3			*
	ADDQ	#PATT_LINE+5,R7		*
	ADDQ	#1,R0			*
	MOVEB	R3,(R7)			* VOLUME
F3:	BTST	#5,R10			*
	JR	EQ,F4			*
	MOVE	R1,R7			*
	LOADB	(R0),R3			*
	ADDQ	#PATT_LINE+2,R7		*
	ADDQ	#1,R0			*
	MOVEB	R3,(R7)			* EFFECT
F4:	BTST	#6,R10			*
	JR	EQ,F5			*
	MOVE	R1,R7			*
	LOADB	(R0),R3			*
	ADDQ	#PATT_LINE+3,R7		*
	ADDQ	#1,R0			*
	MOVEB	R3,(R7)			* PARAM 1
F5:	BTST	#7,R10			*
	JR	EQ,FF			*
	MOVE	R1,R7			*
	LOADB	(R0),R3			*
	ADDQ	#PATT_LINE+4,R7		*
	ADDQ	#1,R0			*
	MOVEB	R3,(R7)			* PARAM 2
					*
FF	STORE	R0,(R1+#INPATT2)	*
************************************************************************************************
			.AUTOEVEN
NO_MUS			DC.W	0
ADDMOD			DC.L	0
RELOGE			DC.B	0
LEN_ONE_PATT		DC.W	0
LEN_ONE_MUS		DC.W	0
TEMPO			DC.B	0
SPEED			DC.W	0
TICK			DC.W	0
TIMER_CONTROL		DC.B	0
TIMER_DATA		DC.B	0
CODE_SAMPLE_LENGHT	DC.W	0
SAMPLE_LENGHT		DC.W	0
CURMUS			DC.B	0
CURPOS			DC.W	0
CURLEN			DC.W	0
CURLOP			DC.W	0
CURPATT			DC.W	0
LENCURPATT		DC.W	0
ADDCURSED		DC.L	0
ADDCURPATT		DC.L	0
MASTER_VOL_LEFT		DC.B	0
MASTER_VOL_RIGHT	DC.B	0

VOICE0			DS.L	VOICE_SIZE
VOICE1			DS.L	VOICE_SIZE
VOICE2			DS.L	VOICE_SIZE
VOICE3			DS.L	VOICE_SIZE
VOICE4			DS.L	VOICE_SIZE

VOICETAB		DC.L	VOICE0,VOICE1,VOICE2,VOICE3,VOICE4
			DC.L	-1
************************************************************************************************
						* Entete du module
S_ENTETE	EQU	0			* RS.L	2
S_NBVOICE	EQU	8			* RS.W	1
S_NBMUS		EQU	10			* RS.W	1
S_NBSEQ		EQU	12			* RS.W	1
S_NBPATT	EQU	14			* RS.W	1
S_NBTRK		EQU	16			* RS.W	1
S_NBSPL		EQU	18			* RS.W	1
S_DEBMUS	EQU	20			* RS.L	1
S_DEBSPLDATA	EQU	24			* RS.L	1
S_DEBSEQ	EQU	28			* RS.L	1
S_DEBPATT	EQU	32			* RS.L	1
S_DEBTABTRACK	EQU	36			* RS.L	1
S_DEBSPL	EQU	40			* RS.L	1
S_LENSPL	EQU	44			* RS.L	1
S_LEN_BUF_SPL	EQU	48			* RS.L	1
S_LEN_DEPACKED_TRACKS	EQU	52		* RS.L	1

LEN_S		EQU	56			* RS.L	1
************************************************************************************************
						* SAMPLE
NAME_MGT	EQU	0			* RS.B	32

DEB_MGT		EQU	32			* RS.L	1
LEN_MGT		EQU	36			* RS.L	1
LOOP_DEB_MGT	EQU	40			* RS.L	1
LEN_LOOP_MGT	EQU	44			* RS.L	1
LEN_BUF_MGT	EQU	48			* RS.W	1
LEN_FIN_MGT	EQU	50			* RS.L	1

BASE_MGT	EQU	54			* RS.W	1
PANO_MGT	EQU	56			* RS.W	1	* PANORAMIQUE
VOL_MGT		EQU	58			* RS.W	1
BIT1_MGT	EQU	60			* RS.W	1

VIDE_MGT	EQU	62			* RS.B	1
F_TUNE_MGT	EQU	63			* RS.B	1
NOTE_MGT	EQU	64			* RS.B	1
COMMAND_MGT	EQU	65			* RS.B	1
PARAM_MGT	EQU	66			* RS.W	1
RESERVE_MGT	EQU	68			* RS.L	2

LEN_SAMPLE_MGT	EQU	76			* RS.B	1
************************************************************************************************
						* VOICE IN REPLAY ROUT
FREQUENCY	EQU	0			* RS.W	1	* PERIODE OF REPLAY
SPL_POINTER	EQU	2			* RS.L	1
SPL_BEGIN	EQU	6			* RS.L	1
LOOP_BEGIN	EQU	10			* RS.L	1
LOOP_END	EQU	14			* RS.L	1
VOL1		EQU	18			* RS.W	1
BIT_LOOP	EQU	20			* RS.B	1	* LOOP OR NOT
KIND_VOICE	EQU	21			* RS.B	1
BUSY		EQU	22			* RS.B	1
VOIE_BRUIT	EQU	23			* RS.B	1

PATT_NOTE1	EQU	24			* RS.W	1	* (PERIODE)
PATT_NOTE2	EQU	26			* RS.B	1	* (LITTERAL)
PATT_INSTR	EQU	27			* RS.B	1	*
PATT_COMM	EQU	28			* RS.B	1	* LIGNE DANS LA PATT
PATT_VIDE	EQU	29			* RS.B	1
PATT_PARAM	EQU	30			* RS.W	1	*
PATT_VOL	EQU	32			* RS.W	1	*
PATT_LINE	EQU	34			* RS.B	6	* LIGNE PATT DECOMPRESSE
INPATT2		EQU	40			* RS.L	1	* ADD RELATIVE DANS LA PATT
EMPTY_LINE	EQU	44			* RS.W	1	* NB DE LIGNE VIDE RESTANTE

VOL2		EQU	46			* RS.B	1
BITS		EQU	47			* RS.B	1	* SAMPLE 8/16 BITS
VIB_COMM	EQU	48			* RS.B	1
VIB_POS		EQU	49			* RS.B	1
SPL_OFFSET	EQU	50			* RS.B	1	* .W
TREM_COMM	EQU	51			* RS.B	1
TREM_POS	EQU	52			* RS.B	1
WAVE_CONTROL	EQU	53			* RS.B	1

VOL_COMM	EQU	54			* RS.B	1	* VOLUME COMMAND
VOL_PARAM	EQU	55			* RS.B	1	* VOLUME PARAMATER

GLISS_FUNK	EQU	56			* RS.B	1
FUNK_OFFSET	EQU	57			* RS.B	1
WAVE_ST		EQU	58			* RS.B	1
FINE_TUNE	EQU	59			* RS.B	1
TONE_PORT_DIR	EQU	60			* RS.B	1
WANTED_PERIOD	EQU	62			* RS.W	1	
TONE_PORT_SPD	EQU	64			* RS.W	1
NOTE		EQU	65			* RS.W	1	* LITTERAL	*.B NORMALEMENT

LEFT_VOL	EQU	66			* RS.B	1
RIGHT_VOL	EQU	67			* RS.B	1
BASE_SPL	EQU	68			* RS.W	1
ADDCURTRACK	EQU	70			* RS.L	1
LENCURTRACK	EQU	74			* RS.W	1
NBCURTRACK	EQU	76			* RS.W	1

VOICE_SIZE	EQU	78			* RS.L	1
************************************************************************************************
