***************************************************************************
* -THE FINK-                .SPL SAMPLE SOUND REPLAYER                    *
***************************************************************************
* IT TOOK ME AGES TO GET THIS RUNNING BECAUSE THE SOURCE CODE GIVEN WITH  *
* REPLAY v4.4 WOULD NOT ACTUALLY REPLAY THE SAMPLE, IT WAS JUST A LIST OF *
* ROUTINES TO DO VARIUS THINGS, SO YOU HAD TO PUT THE ONES YOU WANTED TO  *
* RUN TOGETHER YOURSELF. THE MAIN PROBLEM I HAD WAS THAT I HAVE NEVER USED*
* THE TIMER A INTERRUPT SO ADDRESSING IT WAS RATHER COMPLICATED, BUT AFTER*
* SEVERAL ATEMPTS AND SEVERAL STUPID MISTAKES I GOT IT RUNNNING SO HERE IT*
* IS.........                                                             *
***************************************************************************
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
	LEA	IREPLAY,A0
	BSR	SETINT		SET NULL INTERRUPT ADDRESS
	CLR.L	D0
	MOVEQ	#1,D0		SET INITIAL FREQUENCY
	BSR	SETFREQ
	BSR	ENABMFP		SET THE MFP RUNNING
	BSR	SETSND		SET UP SOUND REGISTERS
	
	SF	XTERNAL		SET THE MODE FOR INTERNAL ATARI USE
	BSR	INTREGS		SET UP INTERNAL REGISTERS
	MOVE.W	#$2500,SR	ENABLE THE INTERRUPTS
******************************************************

FINK	

	BRA	FINK
	
*******************************************************
*  THIS TIDIES UP THE SYSTEM BEFORE LEAVING BACK TO GEM
*******************************************************
EXIT	MOVE.W	#$2700,SR	DISABLE INTS.
	BSR	OLDMFP		RESTORE ORIGINAL MFP DATA

	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)	RETURN TO USER MODE
	TRAP	#1
	ADDQ.L	#6,SP

	MOVE.W	#P_TERM_OLD,-(SP) AND GOTO DESKTOP
	TRAP	#1		GOODBYE CRUEL WORLD !

****************************************
*     THE NULL INTERRUPT ROUTINE       *
****************************************

INULL	RTE

****************************************
*       REPLAY FROM MEMORY             *
****************************************

IREPLAY	MOVE.B	(A6)+,D7	READ FROM RAM
	CMP.L	D6,A6		EXCEDED END STOP
	BGT.S	HALTREP		BRANCH IF SO
	Jmp	(A5)		ELSE OUTPUT IT
	
HALTREP	MOVE.W	#$2700,SR
	LEA	INULL,A0	REMOVE REPLAY INT.
	BSR	SETINT
	SF	INUSE
	MOVE.W	#$2500,SR
	BRA	EXIT

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
*	bra	ireplay
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
	lea.l	playit,a6
	move.l	plat,d6
	MOVEQ	#0,D7
	MOVE.W	D0,SR
	RTS
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
playit	incbin	"b:\found_me.spl"
endit
cursrhi	dc.l	0
cursrlo	dc.l	0
plat	dc.l	(endit)
