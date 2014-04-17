*******************************
* EXAMPLES OF REPLAY ROUTINES *
*******************************
*
*  THIS FILE CONTAINS A COPY OF THE BASIC INTERRUPT AND CONTROL
*  ROUTINES USED WITHIN THE EDITOR/SAMPLER PROGRAMME SUPPLIED
*  WITH THIS PACKAGE. THESE SHOW HOW TO CHANGE THE INTERRUPT
*  ROUTINE IN USE AND HOW TO ALTER SAMPLE/REPLAY FREQUENCY ETC...
*
*  PLEASE FEEL FREE TO USE/MODIFY THE ROUTINES AS APPROPRIATE.
*  ANY USE OF REPLAY FOR COMMERCIAL PURPOSES DOES REQUIRE
*  THAT THE AUTHOR SHOULD ACKNOWLEDGE '2-BIT SYSTEMS REPLAY'
*  SOMEWHERE WITHIN THE PROGRAM AND DOCUMENTAION... USUSALLY
*  A TITLE PAGE OR CREDITS COLUMN.
*
*  OUR THANKS GO TO ANDY BEVERIDGE FOR THE NEW SOUND TABLES USED
*  HERE, WITHIN REPLAY, DIGIDRUM AND THE ECHO PROGRAMME.
*
*  THIS CODE IS COMPATIBLE WITH THE HI-SOFT DEVPAC ASSEMBLER.
* 
*  NOTE:-  ALL REFERENCES TO CURSRLO & CURSRHI ARE TO 2 POINTERS
*          WHICH MARK THE BOTTOM & TOP OF THE REPLAY BUFFER RAM.
*	   XTERNAL = $FF IF REPLAY PORT ACTIVE..  $00 = INTERNAL
*	   INUSE   = $FF IF REPLAY INTERRUPT ACTIVE,  $00 = NULL
*	   OPTION  = $FF IF SAMPLING, $00 = IF MONITOR OR REPLAY
*	   THESE STATUS FLAGS MAY EASILY BE REMOVED AS REQUIRED.
*	   THEY ACT ONLY TO GIVE SYSTEM PRIORITY STATUS.
*
*		TONY RACINE   22/2/87   2-BIT SYSTEMS
*
***********************************************************************
*
* Warning:   Although the frequencies of 40 & 50 Khz are now available,
*    They must only be used when playing samples out through the REPLAY
*    cartridge output.   Failure to observe this MAY cause the computer
*    to crash !!  It will at LEAST cause them to play at reduced speed.
*
***********************************************************************
*
*	MFP EQUATES
*
MFP	EQU	$FFFA00
IERA	EQU	MFP+$07
IERB	EQU	MFP+$09
IPRA	EQU	MFP+$0B
ISRA	EQU	MFP+$0F
IMRA	EQU	MFP+$13
IMRB	EQU	MFP+$15
VECTOR	EQU	MFP+$17
TACR	EQU	MFP+$19
TADR	EQU	MFP+$1F
ISRVEC	EQU	$134
*
*	THE SOUND CHIP
*
SCREG	EQU	$FF8800	CHIP REGISTER SELECT
SCDATA	EQU	$FF8802	REGISTER DATA

*	BDOS EQUATES (TRAP #1)

P_TERM_OLD EQU	0	
F_SUPER  EQU	$20

*	BIOS EQUATES (TRAP #13)

GETMPB	 EQU	0
BCONSTAT EQU	1
BCONIN	 EQU	2
BCONOUT	 EQU	3

*	CARTRIDGE PORT ADDRESSES

INPUT	EQU	$FB0001
OUTPUT	EQU	$FA0000

*****************************************
*           THE PROGRAMME               *
*****************************************
*****************************************
*   SET UP STACK, MEMORY & SUPERVISOR   *
*****************************************

SUPER	PEA	STACKST		USER STACK IN SUPER MODE
	MOVE.W	#F_SUPER,-(SP)	GOTO SUPERVISOR
	TRAP	#1

	BSR	SAVEMFP		SAVE NATURAL MFP CONDITIONS
	MOVE.W	#$2700,SR
	LEA	INULL,A0
	BSR	SETINT		SET NULL INTERRUPT ADDRESS
	MOVEQ	#2,D0		SET INITIAL FREQUENCY
	BSR	SETFREQ
	BSR	ENABMFP		SET THE MFP RUNNING
	BSR	SETSND		SET UP SOUND REGISTERS
	
	SF	XTERNAL		SET THE MODE FOR INTERNAL ATARI USE
	BSR	INTREGS		SET UP INTERNAL REGISTERS
	MOVE.W	#$2500,SR	ENABLE THE INTERRUPTS

*
*  CONTROL/PROGRAM CODE CAN GO HERE
*

*  BLAH, BLAH BLAH.


*
*  THIS TIDIES UP THE SYSTEM BEFORE LEAVING BACK TO GEM
*
EXIT	MOVE.W	#$2700,SR	DISABLE INTS.
	BSR	OLDMFP		RESTORE ORIGINAL MFP DATA

	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)	RETURN TO USER MODE
	TRAP	#1
	ADDQ.L	#6,SP

	MOVE.W	#P_TERM_OLD,-(SP) AND GOTO DESKTOP
	TRAP	#1		GOODBYE CRUEL WORLD !

****************************************
*   THE INTERRUPT SERVICE ROUTINES     *
****************************************
*
*	A6 = POINTER TO BASE OF REPLAY RAM
*	A5 = OUTPUT ROUTINE ADDR
*	A4 = INT. SOUND REG / EXT. PORT ADDR
*	A3 = EXT. SND LOOK UP TABLE
*	A2 = NOT USED
*	A1 = NOT USED
*	A0 = RESERVED FOR MAIN PROG.
*	D7 = BYTE FROM PORT /  OUT TO PORT
*	D6 = POINTER TO END OF REPLAY RAM
*	D5 = SOUND CHIP DATA
*	D4 = SOUND CHIP DATA
*	D3 = UNUSED
*	D2 = UNUSED
*	D1 = UNUSED
*	D0 = RESERVED FOR MAIN PROG. 
*
****************************************
*     THE NULL INTERRUPT ROUTINE       *
****************************************

INULL	RTE

****************************************
*       INPUT MONITOR ROUTINE          *
****************************************

IMONIT	
	MOVE.B	INPUT,D7	GET INPUT
	JMP	(A5)

****************************************
*       SAMPLE FROM PORT               *
****************************************

ISAMPLE	MOVE.B	INPUT,D7	GET SAMPLE
	MOVE.B	D7,(A6)+	& SAVE
	CMP.L	D6,A6		ARE WE AT END OF STRECH ?
	BGT.S	HALTSAM		BRANCH IF SO
	JMP	(A5)		ELSE OUTPUT SAMPLE

HALTSAM	MOVE.W	#$2700,SR	STOP INTS
	LEA	INULL,A0	REMOVE SAMPLE INTERRUPT
	BSR	SETINT
	SF	OPTION
	SF	INUSE
	MOVE.W	#$2500,SR
	RTE

****************************************
*       REPLAY FROM MEMORY             *
****************************************

IREPLAY	MOVE.B	(A6)+,D7	READ FROM RAM
	CMP.L	D6,A6		EXCEDED END STOP
	BGT.S	HALTREP		BRANCH IF SO
	JMP	(A5)		ELSE OUTPUT IT

HALTREP	MOVE.W	#$2700,SR
	LEA	INULL,A0	REMOVE REPLAY INT.
	BSR	SETINT
	SF	INUSE
	MOVE.W	#$2500,SR
	RTE

****************************************
*       THE OUTPUT ROUTINES            *
****************************************
*
*  The following code plays the sounds out through the GI sound chip.
*  We use 'A3' as the base pointer to the look up table. This is easy
*  to use here since it is spare. Position independant writers may
*  replace 'A3' with 'PC'. This relieves an extra register but the
*  table must be located within 256 BYTES of the code for it to work.
*  Our Thanks to Andy Beveridge for the improved sound tables & code.
*
INTOUTP	AND.W	#$00FF,D7	MASK OFF RUBBISH
	ADD.B	#$80,D7		COMPLENT VALUE
	LSL.W	#3,D7		DOUBLE LONG WORD OFFSET
	MOVE.L	0(A3,D7.W),D5	GET DATA #1
	MOVE.W	4(A3,D7.W),D4	GET DATA #2
	MOVEP.L	D5,0(A4)	PLAY #1
	MOVEP.W	D4,0(A4)	PLAY #2
	RTE
*
*  The following code plays the sounds out through the REPLAY port.
*  Simply get the byte, multiply by 2 and read from the output port
*  indexed by the WORD in D7. This actually places the data to be
*  written on the address bus of the 68000. Don't forget that the
*  68000 does not have an address line AD0 as such, hence the LSL
*  (we would lose the least significant BIT otherwise !!).
*
EXTOUTP	AND.W	#$00FF,D7	REMOVE RUBBISH
	LSL.W	#1,D7		PRESERVE L.S.B.
	MOVE.B	0(A4,D7.W),D7	PLAY OUT BY READING IN !!
	RTE

*****************************************
*       THE SYSTEM SUB-ROUTINES         *
*****************************************
*****************************************
*       PRESERVE THE MFP REGISTERS      *
*****************************************

SAVEMFP	MOVE.B	IERA,MFPMEM	PUSH CURRENT MFP DATA
	MOVE.B	IERB,MFPMEM+1
	MOVE.B	IMRA,MFPMEM+2
	MOVE.B	IMRB,MFPMEM+3
	MOVE.B	TADR,MFPMEM+4
	MOVE.B	TACR,MFPMEM+5
	MOVE.B	VECTOR,MFPMEM+6
	RTS

*****************************************
*   REPLACE NATURAL RUNNING MFP VALUES  *
*****************************************

OLDMFP	MOVE.B	MFPMEM+6,VECTOR	RESTORE OLD MFP VALS
	MOVE.B	MFPMEM+5,TACR
	MOVE.B	MFPMEM+4,TADR
	MOVE.B	MFPMEM+3,IMRB
	MOVE.B	MFPMEM+2,IMRA
	MOVE.B	MFPMEM+1,IERB
	MOVE.B	MFPMEM,IERA
	RTS

*****************************************
*	CHOOSE INTERRUPT VECTOR         *
*****************************************
*
*   SET UP SELECTED INTERRUPT WITH A0.L
*   CONTAINING THE NEW ROUTINE VECTOR.
*
SETINT	MOVE.W	SR,D0		SAVE SYSTEM STATUS
	MOVE.W	#$2700,SR	INTERRUPTS OFF

	MOVE.L	A0,ISRVEC	INSTALL NEW ROUTINE

	MOVE.W	D0,SR		RE-ASSERT OLD STATUS
	RTS

*****************************************
*       SET UP MFP FREQUENCY            *
*****************************************
*
*   SET UP MFP TIMER A TO GENERATE INTERRUPTS
*   ENTER WITH D0.W SET WITH A FREQUENCY NUMBER 0 TO 7
*   E.G. D0.W = $0002 GETS 3RD MFP DATA FROM TABLE
*
SETFREQ	MOVE.B	#0,TACR		DISABLE TIMER
	AND.W	#7,D0		ENSURE 0-7
	MOVE.W	D0,FREQNUM	SAVE FOR PROSPERITY
	LEA	FREQTAB,A0	GET THE FREQUENCY XREF ADDR
	LSL.W	#1,D0		CONVERT TO WORD TABLE OFFSET
	MOVE.W	0(A0,D0.W),D0	& GET THE MFP DATA
	MOVE.B	D0,TACR		LSB = CONTROL REG BYTE
	LSR.W	#8,D0		SHIFT DOWN NEXT BYTE
 	MOVE.B	D0,TADR		NEXT = DATA REG BYTE
	RTS

***********************************
*       ENABLE THE MFP            *
***********************************

ENABMFP	MOVE.B	#$20,IMRA
	MOVE.B	#0,IMRB
	MOVE.B	#$20,IERA
	MOVE.B	#0,IERB
	BCLR.B	#3,VECTOR
	RTS

*****************************************
*    SET UP THE SOUND CHIP CHANNELS     *
*****************************************

SETSND	MOVE.B	#0,SCREG	CHANNEL A
	MOVE.B	#0,SCDATA
	MOVE.B	#1,SCREG
	MOVE.B	#0,SCDATA

	MOVE.B	#2,SCREG	CHANNEL B
	MOVE.B	#0,SCDATA
	MOVE.B	#3,SCREG
	MOVE.B	#0,SCDATA

	MOVE.B	#4,SCREG	CHANNEL C
	MOVE.B	#0,SCDATA
	MOVE.B	#5,SCREG
	MOVE.B	#0,SCDATA

	MOVE.B	#7,SCREG	SET UP CHANNEL MIXING & PORT 'A' I/O
	MOVE.B	#$FF,SCDATA

	MOVE.B	#8,SCREG	SET ALL VOLUMES TO ZERO
	MOVE.B	#0,SCDATA
	MOVE.B	#9,SCREG
	MOVE.B	#0,SCDATA
	MOVE.B	#10,SCREG
	MOVE.B	#0,SCDATA
	RTS
	
***************************************
*    SET UP REGS. FOR INTERNAL        *
***************************************

INTREGS	MOVE.W	SR,D0
	MOVE.W	#$2700,SR
	SF	XTERNAL
	LEA.L	INTOUTP,A5	INSTALL OUTPUT ROUTINE
	MOVE.L	#SCREG,A4	SOUND CHIP CNTRL REG
	LEA.L	SND_OUT,A3	LOOK UP TABLES
	MOVEQ	#0,D7
	MOVE.W	D0,SR
	RTS

*****************************************
*     SET UP REGISTERS FOR EXTERNAL     *
*****************************************

EXTREGS	MOVE.W	SR,D0
	MOVE.W	#$2700,SR
	ST	XTERNAL		TRUE = REPLAY CARTRIDGE IN USE
	LEA	EXTOUTP,A5	GET PORT DRIVER CODE ADDRESS
	MOVE.L	#OUTPUT,A4	SET PORT BASE ADDRESS
	MOVEQ	#0,D7
	MOVE.W	D0,SR
	RTS

****************************************
* DECODE TURNS KEY CODES INTO COMMANDS *
* FOR THE INTERRUPT ROUTINE.           *
****************************************
*
* TO PREVENT BOREDOM.. I HAVE ONLY SHOWN HOW I INITIATE
* THE IMPORTANT BITS FOR PEOPLE WHO WISH TO PROGRAM FOR
* THE REPLAY HARDWARE.
*
DECODE	CMP.B	#$01,D0		STOP ALL ?
	BNE.S	TMONTOR		BRANCH IF NOT
	LEA	INULL,A0	ELSE LOAD THE NULL INTERRUPT
	BSR	SETINT		SET IT UP
	TST.B	OPTION		WERE WE SAMPLING ?
	BEQ.S	NOTSAMP		BRANCH IF NOT
	SUBQ.L	#1,A6		CORRECT FOR POST INC MODE IN SAMPLING
	MOVE.L	A6,CURSRHI	SET END POINTER WHEN HALTED
NOTSAMP	SF	INUSE		SIGNAL ALL CLEAR
	BRA	DECEXIT		LEAVE NOW

TMONTOR	CMP.B	#$42,D0		MONITOR ?
	BNE.S	TSAMPLE
	ST	INUSE		SHOW INTS IN USE
	SF	OPTION		WE ARE NOT SAMPLING
	LEA	IMONIT,A0	GET MONITORING
	BSR	SETINT
	BRA	DECEXIT

TSAMPLE	CMP.B	#$43,D0
	BNE.S	TREPLAY
	MOVE.L	CURSRLO,A6	START OF SECTION
	MOVE.L	CURSRHI,D6	TO END OF SAMPLE MEM
	ST	INUSE		FLAG INTERRUPTS IN USE
	ST	OPTION		SHOW WE ARE SAMPLING
	LEA	ISAMPLE,A0	SET UP ROUTINE
	BSR	SETINT		..GO TO IT!
	BRA	DECEXIT

TREPLAY	CMP.B	#$44,D0
	BNE.S	SWAPOUT
	MOVE.L	CURSRLO,A6	PASS START OF REPLAY
	MOVE.L	CURSRHI,D6	& END
	ST	INUSE		FLAG INTS IN USE
	SF	OPTION		WE ARE NOT SAMPLING
	LEA	IREPLAY,A0	SET UP THE ROUTINE
	BSR	SETINT		AND DO IT
	BRA	DECEXIT

SWAPOUT	CMP.B	#$38,D0		TOGGLE OUTPUT
	BNE.S	F1
	TST.B	XTERNAL
	BNE.S	INTERNL		IF EXT MAKE INT
	BSR	EXTREGS
	BRA	DECEXIT
INTERNL	BSR	INTREGS
	BRA	DECEXIT

F1	CMP.B	#$3B,D0		5 KHZ
	BNE.S	F2
	MOVE.W	#0,D0
	BSR	SETFREQ
	BRA	DECEXIT

F2	CMP.B	#$3C,D0		7.5 KHZ
	BNE.S	F3
	MOVE.W	#1,D0
	BSR	SETFREQ
	BRA	DECEXIT

F3	CMP.B	#$3D,D0		10 KHZ
	BNE.S	F4
	MOVE.W	#2,D0
	BSR	SETFREQ
	BRA	DECEXIT

F4	CMP.B	#$3E,D0		20 KHZ
	BNE.S	F5
	MOVE.W	#3,D0
	BSR	SETFREQ
	BRA	DECEXIT

F5	CMP.B	#$3F,D0		31 KHZ
	BNE.S	CHKINTS
	MOVE.W	#4,D0
	BSR	SETFREQ
	BRA	DECEXIT
*
* THE FOLLOWING NOT ALLOWED DURING INTERRUPTS
*
CHKINTS	TST.B	INUSE		INTS RUNNING ?
	BNE	DECEXIT		LEAVE NOW IF YES

*	ETC...ETC

DECEXIT	RTS


***********************************
*	BLOCK STORAGE AREA        *
***************************************
*    Internal sound lookup table.     *
***************************************
	EVEN
SND_OUT	dc.w	$80c,$90b,$a09,0,$80c,$90b,$a09,0
	dc.w	$80d,$908,$a08,0,$80b,$90b,$a0b,0
	dc.w	$80d,$909,$a05,0,$80c,$90b,$a08,0
	dc.w	$80d,$909,$a02,0,$80d,$908,$a06,0
	dc.w	$80c,$90b,$a07,0,$80d,$907,$a07,0
	dc.w	$80c,$90b,$a06,0,$80c,$90a,$a09,0
	dc.w	$80b,$90b,$a0a,0,$80c,$90b,$a02,0
	dc.w	$80c,$90b,$a00,0,$80c,$90a,$a08,0

	dc.w	$80d,$906,$a04,0,$80d,$905,$a05,0
	dc.w	$80d,$905,$a04,0,$80c,$909,$a09,0
	dc.w	$80d,$904,$a03,0,$80b,$90b,$a09,0
	dc.w	$80c,$90a,$a05,0,$80b,$90a,$a0a,0
	dc.w	$80c,$909,$a08,0,$80b,$90b,$a08,0
	dc.w	$80c,$90a,$a00,0,$80c,$90a,$a00,0
	dc.w	$80c,$909,$a07,0,$80b,$90b,$a07,0
	dc.w	$80c,$909,$a06,0,$80b,$90b,$a06,0

	dc.w	$80b,$90a,$a09,0,$80b,$90b,$a05,0
	dc.w	$80a,$90a,$a0a,0,$80b,$90b,$a02,0
	dc.w	$80b,$90a,$a08,0,$80c,$907,$a07,0
	dc.w	$80c,$908,$a04,0,$80c,$907,$a06,0
	dc.w	$80b,$909,$a09,0,$80c,$906,$a06,0
	dc.w	$80a,$90a,$a09,0,$80c,$907,$a03,0
	dc.w	$80b,$90a,$a05,0,$80b,$909,$a08,0
	dc.w	$80b,$90a,$a03,0,$80a,$90a,$a08,0

	dc.w	$80b,$90a,$a00,0,$80b,$909,$a07,0
	dc.w	$80b,$908,$a08,0,$80a,$90a,$a07,0
	dc.w	$80a,$909,$a09,0,$80c,$901,$a01,0
	dc.w	$80a,$90a,$a06,0,$80b,$908,$a07,0
	dc.w	$80a,$90a,$a05,0,$80a,$909,$a08,0
	dc.w	$80a,$90a,$a02,0,$80a,$90a,$a01,0
	dc.w	$80a,$90a,$a00,0,$809,$909,$a09,0
	dc.w	$80a,$908,$a08,0,$80b,$908,$a01,0

	dc.w	$80a,$909,$a06,0,$80b,$907,$a04,0
	dc.w	$80a,$909,$a05,0,$809,$909,$a08,0
	dc.w	$80a,$909,$a03,0,$80a,$908,$a06,0
	dc.w	$80a,$909,$a00,0,$809,$909,$a07,0
	dc.w	$809,$908,$a08,0,$80a,$908,$a04,0
	dc.w	$809,$909,$a06,0,$80a,$908,$a01,0
	dc.w	$809,$909,$a05,0,$809,$908,$a07,0
	dc.w	$808,$908,$a08,0,$809,$909,$a02,0

	dc.w	$809,$908,$a06,0,$809,$909,$a00,0
	dc.w	$809,$907,$a07,0,$808,$908,$a07,0
	dc.w	$809,$907,$a06,0,$809,$908,$a02,0
	dc.w	$808,$908,$a06,0,$809,$906,$a06,0
	dc.w	$808,$907,$a07,0,$808,$908,$a04,0
	dc.w	$808,$907,$a06,0,$808,$908,$a02,0
	dc.w	$807,$907,$a07,0,$808,$906,$a06,0
	dc.w	$808,$907,$a04,0,$807,$907,$a06,0

	dc.w	$808,$906,$a05,0,$808,$906,$a04,0
	dc.w	$807,$906,$a06,0,$807,$907,$a04,0
	dc.w	$808,$905,$a04,0,$806,$906,$a06,0
	dc.w	$807,$906,$a04,0,$807,$905,$a05,0
	dc.w	$806,$906,$a05,0,$806,$906,$a04,0
	dc.w	$806,$905,$a05,0,$806,$906,$a02,0
	dc.w	$806,$905,$a04,0,$805,$905,$a05,0
	dc.w	$806,$905,$a02,0,$805,$905,$a04,0

	dc.w	$805,$904,$a04,0,$805,$905,$a02,0
	dc.w	$804,$904,$a04,0,$804,$904,$a03,0
	dc.w	$804,$904,$a02,0,$804,$903,$a03,0
	dc.w	$803,$903,$a03,0,$803,$903,$a02,0
	dc.w	$803,$902,$a02,0,$802,$902,$a02,0
	dc.w	$802,$902,$a01,0,$801,$901,$a01,0
	dc.w	$802,$901,$a00,0,$801,$901,$a00,0
	dc.w	$801,$900,$a00,0,$800,$900,$a00,0

	dc.w	$80e,$90d,$a0c,0,$80f,$903,$a00,0
	dc.w	$80f,$903,$a00,0,$80f,$903,$a00,0
	dc.w	$80f,$903,$a00,0,$80f,$903,$a00,0
	dc.w	$80f,$903,$a00,0,$80e,$90d,$a0b,0
	dc.w	$80e,$90d,$a0b,0,$80e,$90d,$a0b,0
	dc.w	$80e,$90d,$a0b,0,$80e,$90d,$a0b,0
	dc.w	$80e,$90d,$a0b,0,$80e,$90d,$a0b,0
	dc.w	$80e,$90d,$a0a,0,$80e,$90d,$a0a,0

	dc.w	$80e,$90d,$a0a,0,$80e,$90d,$a0a,0
	dc.w	$80e,$90c,$a0c,0,$80e,$90d,$a00,0
	dc.w	$80d,$90d,$a0d,0,$80d,$90d,$a0d,0
	dc.w	$80d,$90d,$a0d,0,$80d,$90d,$a0d,0
	dc.w	$80d,$90d,$a0d,0,$80d,$90d,$a0d,0
	dc.w	$80e,$90c,$a0b,0,$80e,$90c,$a0b,0
	dc.w	$80e,$90c,$a0b,0,$80e,$90c,$a0b,0
	dc.w	$80e,$90c,$a0b,0,$80e,$90c,$a0b,0

	dc.w	$80e,$90c,$a0b,0,$80e,$90c,$a0b,0
	dc.w	$80e,$90c,$a0a,0,$80e,$90c,$a0a,0
	dc.w	$80e,$90c,$a0a,0,$80e,$90c,$a0a,0
	dc.w	$80d,$90d,$a0c,0,$80d,$90d,$a0c,0
	dc.w	$80e,$90c,$a09,0,$80e,$90c,$a09,0
	dc.w	$80e,$90c,$a05,0,$80e,$90c,$a00,0
	dc.w	$80e,$90c,$a00,0,$80e,$90b,$a0b,0
	dc.w	$80e,$90b,$a0b,0,$80e,$90b,$a0b,0

	dc.w	$80e,$90b,$a0b,0,$80e,$90b,$a0a,0
	dc.w	$80e,$90b,$a0a,0,$80e,$90b,$a0a,0
	dc.w	$80d,$90d,$a0b,0,$80d,$90d,$a0b,0
	dc.w	$80d,$90d,$a0b,0,$80e,$90b,$a09,0
	dc.w	$80e,$90b,$a09,0,$80e,$90b,$a09,0
	dc.w	$80d,$90c,$a0c,0,$80d,$90d,$a0a,0
	dc.w	$80e,$90b,$a07,0,$80e,$90b,$a00,0
	dc.w	$80e,$90b,$a00,0,$80d,$90d,$a09,0

	dc.w	$80d,$90d,$a09,0,$80e,$90a,$a09,0
	dc.w	$80d,$90d,$a08,0,$80d,$90d,$a07,0
	dc.w	$80d,$90d,$a04,0,$80d,$90d,$a00,0
	dc.w	$80e,$90a,$a04,0,$80e,$909,$a09,0
	dc.w	$80e,$909,$a09,0,$80d,$90c,$a0b,0
	dc.w	$80e,$909,$a08,0,$80e,$909,$a08,0
	dc.w	$80e,$909,$a07,0,$80e,$908,$a08,0
	dc.w	$80e,$909,$a01,0,$80c,$90c,$a0c,0

	dc.w	$80d,$90c,$a0a,0,$80e,$908,$a06,0
	dc.w	$80e,$907,$a07,0,$80e,$908,$a00,0
	dc.w	$80e,$907,$a05,0,$80e,$906,$a06,0
	dc.w	$80d,$90c,$a09,0,$80e,$905,$a05,0
	dc.w	$80e,$904,$a04,0,$80d,$90c,$a08,0
	dc.w	$80d,$90b,$a0b,0,$80e,$900,$a00,0
	dc.w	$80d,$90c,$a06,0,$80d,$90c,$a05,0
	dc.w	$80d,$90c,$a02,0,$80c,$90c,$a0b,0

	dc.w	$80c,$90c,$a0b,0,$80d,$90b,$a0a,0
	dc.w	$80d,$90b,$a0a,0,$80d,$90b,$a0a,0
	dc.w	$80d,$90b,$a0a,0,$80c,$90c,$a0a,0
	dc.w	$80c,$90c,$a0a,0,$80c,$90c,$a0a,0
	dc.w	$80d,$90b,$a09,0,$80d,$90b,$a09,0
	dc.w	$80d,$90a,$a0a,0,$80d,$90a,$a0a,0
	dc.w	$80d,$90a,$a0a,0,$80c,$90c,$a09,0
	dc.w	$80c,$90c,$a09,0,$80c,$90c,$a09,0

	dc.w	$80d,$90b,$a06,0,$80c,$90b,$a0b,0
	dc.w	$80c,$90c,$a08,0,$80d,$90b,$a00,0
	dc.w	$80d,$90b,$a00,0,$80c,$90c,$a07,0
	dc.w	$80c,$90c,$a06,0,$80c,$90c,$a05,0
	dc.w	$80c,$90c,$a03,0,$80c,$90c,$a01,0
	dc.w	$80c,$90b,$a0a,0,$80d,$90a,$a05,0
	dc.w	$80d,$90a,$a04,0,$80d,$90a,$a02,0
	dc.w	$80d,$909,$a08,0,$80d,$909,$a08,0

**************************************
*       MFP/FREQUENCY TABLE          *
**************************************
	EVEN
FREQTAB	DC.W	$0506	4.9 KHZ
	DC.W	$0505	7.68 KHZ
	DC.W	$0405	9.6 KHZ
	DC.W	$2901	14.99 KHZ
	DC.W	$1F01	19.8 KHZ
	DC.W	$0802	30.7 KHZ
	DC.W	$0602	40.96 KHZ
	DC.W	$0106	49.152 KHZ

**************************************
*	DEFINE PROGRAM STORAGE       *
**************************************
	EVEN
XTERNAL	DS.B	1	$FF = EXTERNAL O/P SELECTED
INUSE	DS.B	1	INTERRUPT IN USE FLAG
OPTION	DS.B	1	INT. OPTION  $FF = SAMPLE
	EVEN
FREQNUM	DS.W	1	FREQUENCY SELECTED
MFPMEM	DS.B	8	SAVED MFP DATA

**************************************
*      USER PROGRAM STACK HERE.      *
**************************************
	EVEN
STEND	DS.L	512	RESERVE USER STACK
STACKST

**************************************
*       START OF REPLAY BUFFER       *
**************************************

REPBUFF	EQU	*
