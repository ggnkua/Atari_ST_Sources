* SOURCE CODE FOR THE DEMO INCLUDED ON THE DISK BY THE LOST BOYS
* THIS SOURCE IS VERY OLD AND THEREFORE NOT VERY GOOD, BUT IT STILL
* SERVES ITS PURPOUSE. IF YOU CREATE A DEMO USING THIS SOURCE, COULD
* YOU PLEASE SEND IT TO US!!!!
* 							SAMMY JOE OF TLB

	bsr PICTURE
	CLR.W -(A7)
	PEA FILE
	MOVE.W #$3D,-(SP)
	TRAP #1
	ADDQ.L #8,SP
	MOVE.W D0,HANDLE

*********************************************************************
	PEA YELLO0	      Change this to your first sample name	

	MOVE.L #141749,-(SP)  FILE LENGTH 

*			      Change here the amount to load the size 
*			      of all the samples together  
*********************************************************************

	MOVE.W HANDLE,-(SP)
	MOVE.W #$3F,-(SP)
	TRAP #1
	ADD.L #12,SP
	MOVE.W HANDLE,-(SP)
	MOVE.W #$3E,-(SP)
	TRAP #1
	ADDQ.L #4,SP

*	MFP EQUATES
*
MFP	EQU	$FFFA00
IERA	EQU	$07
IERB	EQU	$09
IPRA	EQU	$0B
ISRA	EQU	$0F
IMRA	EQU	$13
IMRB	EQU	$15
VECTOR	EQU	$17
TACR	EQU	$19
TADR	EQU	$1F
ISRVEC	EQU	$134
*
*	THE SOUND CHIP
*
SND_CHP	EQU	$FF8800 CHIP ADDRESS	
SCREG	EQU	0	CHIP REGISTER SELECT
SCDATA	EQU	2	REGISTER DATA
*
*	THE KEYBOARD & MIDI ACIA'S
*
KBDCONT	EQU	$FFFC00
KBDDATA	EQU	KBDCONT+2
MIDCONT	EQU	$FFFC04
MIDDATA	EQU	MIDCONT+2

*	CARTRIDGE PORT ADDRESSES

INPUT	EQU	$FB0001
OUTPUT	EQU	$FA0000

*	BDOS EQUATES (TRAP #1)

P_TERM_OLD EQU	0	
F_SUPER  EQU	$20

*	XBOIS EQUATES (TRAP #14)

IKBDWS	EQU	25

*******************************
*      THE MACHINE CODE.      *
*******************************
		move #2,-(sp)
		trap #14
		addq.l #2,sp

*********************************************************************

		add.l #$5780,d0		position of scroll on screen

*********************************************************************

		move.l d0,phys
		add.l #$500,d0
		move.l d0,phys1
		lea scrolline,a0
		move.b (a0)+,d0
		move.l a0,store

	move.l #SAMPLETAB,SAMPLEPOINT
SUPER	MOVEM.L	A0-A6/D0-D7,-(SP) SAVE 'BASIC' SYSTEM

	BSR	KEYSOFF		DISABLE KEYBOARD

	CLR.L	-(SP)		
	MOVE.W	#F_SUPER,-(SP)	GOTO SUPERVISOR
	TRAP	#1
	ADDQ.L	#6,SP

	LEA	VARS(PC),A2	SAVE THE SUPERVISOR STACK POINTER!!
	MOVE.L	D0,STACK(A2)


	BSR	SAVEMFP		SAVE NATURAL MFP CONDITIONS
	MOVE.W	#$2700,SR	INTERRUPTS OFF
	MOVE.L #VBLHAND,$70
	LEA	INULL(PC),A0
	BSR	SETINT		SET NULL INTERRUPT ADDRESS

*********************************************************************

	MOVE.L	#3,D0	    SET sample FREQUENCY

*********************************************************************

	BSR	SETFREQ
	BSR	ENABMFP		SET THE MFP RUNNING
	BSR	SETSND		SET UP SOUND REGISTERS
	
	BSR	INTREGS		SET UP INTERNAL REGISTERS
FUCK	MOVE.L A1,-(A7)
	move.w #0,sump
	MOVE.L SAMPLEPOINT,A1
	MOVE.L (A1)+,A6
	MOVE.L (A1)+,D6
	MOVE.L A1,SAMPLEPOINT
	CMP.L #0,A6
	BEQ FUCK2
	MOVE.L (A7)+,A1
	move.w #$2300,sr
	LEA	IREPLAY(PC),A0	SET UP THE OUTPUT CODE ADDRESS
	BSR	SETINT		GO TO IT
WAIT	cmp.w #1,sump
	BNE.S	WAIT		BR. IF NOT
	move.w #$2700,sr
	BRA FUCK
FUCK2	MOVE.L #SAMPLETAB,SAMPLEPOINT
	BRA FUCK
sump	ds.w 0
VBLHAND
		nop
		nop
		nop
		nop

		bsr do_scroll
		addq.b #1,count1
		cmp.b #8,count1
		beq nextlet
		RTE
nextlet		clr.b count1
movlet		move.l store,a0
		move.b (a0)+,d0
		cmp.b #$ff,d0
		beq wrap
		subi.b #$20,d0
		move.l a0,store
		move.b d0,b
		move.w a,d0
		mulu #$44,d0
		clr.l a
		move.w d0,c
		add.l #font,a
		sub.l #2,a
		move.l a,a0
		lea data+$9000,a1
		move.w #16,d0
there		move.w 2(a0),6(a1)
		move.w 4(a0),14(a1)

		adda.l #160,a1				
		addq.l #4,a0
		dbf d0,there

		RTE


do_scroll:      move.w  #3,d1  ; the letters are 37 pixels high
dosy		move.w #16,d0
		lea data+$9000,a1
		movea.l phys1,a0
dosy1:           lsl.w   30(a1)  ; scroll 1 pixel to the left
		roxl.w  22(a1)
		roxl.w  14(a1)
                roxl.w  6(a1)   ; the letters are 32 pixels wide
                roxl.w  158(a0) ; scroll the screen
                roxl.w  150(a0) ; steps of -8, scroll one plane
                roxl.w  142(a0)
                roxl.w  134(a0)
                roxl.w  126(a0)
                roxl.w  118(a0)
                roxl.w  110(a0)
                roxl.w  102(a0)
                roxl.w  94(a0)
                roxl.w  86(a0)
                roxl.w  78(a0)
                roxl.w  70(a0)
                roxl.w  62(a0)
                roxl.w  54(a0)
                roxl.w  46(a0)
                roxl.w  38(a0)
                roxl.w  30(a0)
                roxl.w  22(a0)
                roxl.w  14(a0)
                roxl.w  6(a0)
                adda.l  #160,a1 
                adda.l  #160,a0 ; 160 bytes: one screen line down
                dbra    d0,dosy1 ; do the next screen line
		dbra    d1,dosy
                rts             ; end of routine
wrap 		move.b #$20,d0
		lea scrolline,a0
		move.l a0,store
		RTE
*
*  This tidies the system up before leaving back to BASIC.
*
EXIT	MOVE.W	#$2700,SR	DISABLE INTS.
	BSR	OLDMFP		RESTORE ORIGINAL MFP DATA
	BSR	KEYSON		RESTORE KEYBOARD OPERATION
*
*  WE MUST NOW FLUSH ANY CHARACTERS OUT OF THE KEY BUFFER BEFORE
*  RE-ENABLING THE INTERRUPTS SINCE THE FLOOD OF DATA WILL CRASH
*  THE COMPUTER. (USERS WITH A MIDI DEVICE CONNECTED MAY NEED TO 
*  FLUSH THE MIDI ACIA IN A SIMILAR WAY).
*
FLUSH	BTST.B	#0,KBDCONT	IS A CHARACTER WAITING ?
	BEQ.S	INTSON		BR. IF NOT
	MOVE.B	KBDDATA,D0	READ CHARACTER (& IGNORE IT)
	BRA.S	FLUSH		CHECK FOR ANOTHER

INTSON	MOVE.W	#$2000,SR	RESTORE INTS FOR O.S.
	LEA	VARS(PC),A2
	MOVE.L	STACK(A2),-(SP)
	MOVE.W	#F_SUPER,-(SP)	RETURN TO USER MODE
 	TRAP	#1
	ADDQ.L	#6,SP

	MOVEM.L	(SP)+,A0-A6/D0-D7 RESTORE 'BASIC' DATA
	CLR.W -(A7)
	TRAP #1


****************************************
*   THE INTERRUPT SERVICE ROUTINES     *
****************************************
*
*	A6 = POINTER TO BASE OF REPLAY RAM
*	A5 = OUTPUT ROUTINE ADDR
*	A4 = INT. SOUND REG / EXT. PORT ADDR
*	A3 = LOOK UP TABLE ADDRESS
*	A2 = VARIABLE OFFSET REG
*	A1 = UNUSED
*	A0 = UNUSED
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
*       REPLAY FROM MEMORY             *
****************************************

IREPLAY	MOVE.B	(A6)+,D7	READ FROM RAM
	CMP.L	D6,A6		EXCEDED END STOP
	BGT.S	HALTREP		BRANCH IF SO
	JMP	(A5)		ELSE OUTPUT IT

HALTREP	MOVE.W	#$2700,SR
	move.l  a0,-(sp)
	LEA	INULL(PC),A0	REMOVE REPLAY INT.
	BSR	SETINT
	move.l (sp)+,a0
	move.w #1,sump
	MOVE.W	#$2300,SR
	RTE

****************************************
*       THE OUTPUT ROUTINES            *
****************************************
*
INTOUTP	AND.W	#$00FF,D7	MASK OFF RUBBISH
	ADD.B	#$80,D7		SIGN VALUE
	LSL.W	#3,D7		DOUBLE LONG WORD OFFSET
 	MOVE.L	0(A3,D7.W),D5	GET DATA #1
	MOVE.W	4(A3,D7.W),D4	GET DATA #2
	MOVEP.L	D5,0(A4)	PLAY #1
	MOVEP.W	D4,0(A4)	PLAY #2
	RTE

SAVEMFP	MOVE.L	#MFP,A0
	MOVE.B	IERA(A0),MFPMEM(A2)
	MOVE.B	IERB(A0),MFPMEM+1(A2)
	MOVE.B	IMRA(A0),MFPMEM+2(A2)
	MOVE.B	IMRB(A0),MFPMEM+3(A2)
	MOVE.B	TADR(A0),MFPMEM+4(A2)
	MOVE.B	TACR(A0),MFPMEM+5(A2)
	MOVE.B	VECTOR(A0),MFPMEM+6(A2)
	RTS

***********************************
*   RESTORE NATURAL RUNNING MFP   *
***********************************

OLDMFP	MOVE.L	#MFP,A0
	MOVE.B	MFPMEM+6(A2),VECTOR(A0)
	MOVE.B	MFPMEM+5(A2),TACR(A0)
	MOVE.B	MFPMEM+4(A2),TADR(A0)
	MOVE.B	MFPMEM+3(A2),IMRB(A0)
	MOVE.B	MFPMEM+2(A2),IMRA(A0)
	MOVE.B	MFPMEM+1(A2),IERB(A0)
	MOVE.B	MFPMEM(A2),IERA(A0)
	RTS

***********************************
*     CHOOSE INTERRUPT VECTOR     *
***********************************

SETINT 	MOVEM.L A0/D0,-(SP)
	MOVE.W	SR,D0
	MOVE.W	#$2700,SR
	MOVE.L	A0,ISRVEC
	MOVE.W	D0,SR
	MOVEM.L (SP)+,A0/D0
	RTS

******************************
*    IKBD ENABLE/DISABLE     *
******************************

KEYSOFF	PEA	SKBDDIS(PC)
	BRA.S	DO_IKBD
KEYSON	PEA	SKBDEN(PC)
DO_IKBD	MOVE.W	#0,-(SP)	1 PARAMETER
	MOVE.W	#IKBDWS,-(SP)
	TRAP	#14
	ADDQ.L	#8,SP
	RTS

*****************************************
*       SET UP MFP FREQUENCY            *
*****************************************
*
*   SET UP MFP TIMER A TO GENERATE INTERRUPTS
*   ENTER WITH D0.W SET WITH A FREQUENCY NUMBER 0 TO 7
*   E.G. D0.W = $0002 GETS 3RD MFP DATA FROM TABLE
*
SETFREQ	MOVE.L	#MFP,A1
	MOVE.B	#0,TACR(A1)	DISABLE TIMER
	AND.W	#7,D0		ENSURE 0-7
	LEA	FREQTAB(PC),A0	GET THE FREQUENCY XREF ADDR
	LSL.W	#1,D0		CONVERT TO WORD TABLE OFFSET
	MOVE.W	0(A0,D0.W),D0	& GET THE MFP DATA
	MOVE.B	D0,TACR(A1)	LSB = CONTROL REG BYTE
	LSR.W	#8,D0		SHIFT DOWN NEXT BYTE
 	MOVE.B	D0,TADR(A1)	NEXT = DATA REG BYTE
	RTS

***********************************
*       ENABLE THE MFP            *
***********************************

ENABMFP	MOVE.L	#MFP,A0
	MOVE.B	#$20,IMRA(A0)
	MOVE.B	#0,IMRB(A0)
	MOVE.B	#$20,IERA(A0)
	MOVE.B	#0,IERB(A0)
	BCLR.B	#3,VECTOR(A0)
	RTS

*****************************************
*    SET UP THE SOUND CHIP CHANNELS     *
*****************************************

SETSND	MOVE.L	#SND_CHP,A0
	MOVE.B	#0,SCREG(A0)	CHANNEL A
	MOVE.B	#0,SCDATA(A0)
	MOVE.B	#1,SCREG(A0)
	MOVE.B	#0,SCDATA(A0)

	MOVE.B	#2,SCREG(A0)	CHANNEL B
	MOVE.B	#0,SCDATA(A0)
	MOVE.B	#3,SCREG(A0)
	MOVE.B	#0,SCDATA(A0)

	MOVE.B	#4,SCREG(A0)	CHANNEL C
	MOVE.B	#0,SCDATA(A0)
	MOVE.B	#5,SCREG(A0)
	MOVE.B	#0,SCDATA(A0)

	MOVE.B	#7,SCREG(A0)	SET UP CHANNEL MIXING & PORT 'A' I/O
	MOVE.B	#$FF,SCDATA(A0)

	MOVE.B	#8,SCREG(A0)	SET ALL VOLUMES TO ZERO
	MOVE.B	#0,SCDATA(A0)
	MOVE.B	#9,SCREG(A0)
	MOVE.B	#0,SCDATA(A0)
	MOVE.B	#10,SCREG(A0)
	MOVE.B	#0,SCDATA(A0)
	RTS
	
***************************************
*    SET UP REGS. FOR INTERNAL        *
***************************************

INTREGS	MOVE.W	SR,D0
	MOVE.W	#$2700,SR
	SF	XTERNAL(A2)
	LEA.L	INTOUTP(PC),A5	INSTALL OUTPUT ROUTINE
	MOVE.L	#SND_CHP,A4	SOUND CHIP CNTRL REG
	LEA.L	SND_OUT(PC),A3	LOOK UP TABLES
	MOVEQ	#0,D7
	MOVE.W	D0,SR
	RTS

***********************************
*	BLOCK STORAGE AREA        *
***************************************
*    Internal sound lookup table.     *
***************************************
	EVEN
SND_OUT	DC.W	$80C,$90B,$A09,0,$80C,$90B,$A09,0
	DC.W	$80D,$908,$A08,0,$80B,$90B,$A0B,0
	DC.W	$80D,$909,$A05,0,$80C,$90B,$A08,0
	DC.W	$80D,$909,$A02,0,$80D,$908,$A06,0
	DC.W	$80C,$90B,$A07,0,$80D,$907,$A07,0
	DC.W	$80C,$90B,$A06,0,$80C,$90A,$A09,0
	DC.W	$80B,$90B,$A0A,0,$80C,$90B,$A02,0
	DC.W	$80C,$90B,$A00,0,$80C,$90A,$A08,0

	DC.W	$80D,$906,$A04,0,$80D,$905,$A05,0
	DC.W	$80D,$905,$A04,0,$80C,$909,$A09,0
	DC.W	$80D,$904,$A03,0,$80B,$90B,$A09,0
	DC.W	$80C,$90A,$A05,0,$80B,$90A,$A0A,0
	DC.W	$80C,$909,$A08,0,$80B,$90B,$A08,0
	DC.W	$80C,$90A,$A00,0,$80C,$90A,$A00,0
	DC.W	$80C,$909,$A07,0,$80B,$90B,$A07,0
	DC.W	$80C,$909,$A06,0,$80B,$90B,$A06,0

	DC.W	$80B,$90A,$A09,0,$80B,$90B,$A05,0
	DC.W	$80A,$90A,$A0A,0,$80B,$90B,$A02,0
	DC.W	$80B,$90A,$A08,0,$80C,$907,$A07,0
	DC.W	$80C,$908,$A04,0,$80C,$907,$A06,0
	DC.W	$80B,$909,$A09,0,$80C,$906,$A06,0
	DC.W	$80A,$90A,$A09,0,$80C,$907,$A03,0
	DC.W	$80B,$90A,$A05,0,$80B,$909,$A08,0
	DC.W	$80B,$90A,$A03,0,$80A,$90A,$A08,0

	DC.W	$80B,$90A,$A00,0,$80B,$909,$A07,0
	DC.W	$80B,$908,$A08,0,$80A,$90A,$A07,0
	DC.W	$80A,$909,$A09,0,$80C,$901,$A01,0
	DC.W	$80A,$90A,$A06,0,$80B,$908,$A07,0
	DC.W	$80A,$90A,$A05,0,$80A,$909,$A08,0
	DC.W	$80A,$90A,$A02,0,$80A,$90A,$A01,0
	DC.W	$80A,$90A,$A00,0,$809,$909,$A09,0
	DC.W	$80A,$908,$A08,0,$80B,$908,$A01,0

	DC.W	$80A,$909,$A06,0,$80B,$907,$A04,0
	DC.W	$80A,$909,$A05,0,$809,$909,$A08,0
	DC.W	$80A,$909,$A03,0,$80A,$908,$A06,0
	DC.W	$80A,$909,$A00,0,$809,$909,$A07,0
	DC.W	$809,$908,$A08,0,$80A,$908,$A04,0
	DC.W	$809,$909,$A06,0,$80A,$908,$A01,0
	DC.W	$809,$909,$A05,0,$809,$908,$A07,0
	DC.W	$808,$908,$A08,0,$809,$909,$A02,0

	DC.W	$809,$908,$A06,0,$809,$909,$A00,0
	DC.W	$809,$907,$A07,0,$808,$908,$A07,0
	DC.W	$809,$907,$A06,0,$809,$908,$A02,0
	DC.W	$808,$908,$A06,0,$809,$906,$A06,0
	DC.W	$808,$907,$A07,0,$808,$908,$A04,0
	DC.W	$808,$907,$A06,0,$808,$908,$A02,0
	DC.W	$807,$907,$A07,0,$808,$906,$A06,0
	DC.W	$808,$907,$A04,0,$807,$907,$A06,0

	DC.W	$808,$906,$A05,0,$808,$906,$A04,0
	DC.W	$807,$906,$A06,0,$807,$907,$A04,0
	DC.W	$808,$905,$A04,0,$806,$906,$A06,0
	DC.W	$807,$906,$A04,0,$807,$905,$A05,0
	DC.W	$806,$906,$A05,0,$806,$906,$A04,0
	DC.W	$806,$905,$A05,0,$806,$906,$A02,0
	DC.W	$806,$905,$A04,0,$805,$905,$A05,0
	DC.W	$806,$905,$A02,0,$805,$905,$A04,0

	DC.W	$805,$904,$A04,0,$805,$905,$A02,0
	DC.W	$804,$904,$A04,0,$804,$904,$A03,0
	DC.W	$804,$904,$A02,0,$804,$903,$A03,0
	DC.W	$803,$903,$A03,0,$803,$903,$A02,0
	DC.W	$803,$902,$A02,0,$802,$902,$A02,0
	DC.W	$802,$902,$A01,0,$801,$901,$A01,0
	DC.W	$802,$901,$A00,0,$801,$901,$A00,0
	DC.W	$801,$900,$A00,0,$800,$900,$A00,0

	DC.W	$80E,$90D,$A0C,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0

	DC.W	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0
	DC.W	$80E,$90C,$A0C,0,$80E,$90D,$A00,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0

	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	DC.W	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	DC.W	$80D,$90D,$A0C,0,$80D,$90D,$A0C,0
	DC.W	$80E,$90C,$A09,0,$80E,$90C,$A09,0
	DC.W	$80E,$90C,$A05,0,$80E,$90C,$A00,0
	DC.W	$80E,$90C,$A00,0,$80E,$90B,$A0B,0
	DC.W	$80E,$90B,$A0B,0,$80E,$90B,$A0B,0

	DC.W	$80E,$90B,$A0B,0,$80E,$90B,$A0A,0
	DC.W	$80E,$90B,$A0A,0,$80E,$90B,$A0A,0
	DC.W	$80D,$90D,$A0B,0,$80D,$90D,$A0B,0
	DC.W	$80D,$90D,$A0B,0,$80E,$90B,$A09,0
	DC.W	$80E,$90B,$A09,0,$80E,$90B,$A09,0
	DC.W	$80D,$90C,$A0C,0,$80D,$90D,$A0A,0
	DC.W	$80E,$90B,$A07,0,$80E,$90B,$A00,0
	DC.W	$80E,$90B,$A00,0,$80D,$90D,$A09,0

	DC.W	$80D,$90D,$A09,0,$80E,$90A,$A09,0
	DC.W	$80D,$90D,$A08,0,$80D,$90D,$A07,0
	DC.W	$80D,$90D,$A04,0,$80D,$90D,$A00,0
	DC.W	$80E,$90A,$A04,0,$80E,$909,$A09,0
	DC.W	$80E,$909,$A09,0,$80D,$90C,$A0B,0
	DC.W	$80E,$909,$A08,0,$80E,$909,$A08,0
	DC.W	$80E,$909,$A07,0,$80E,$908,$A08,0
	DC.W	$80E,$909,$A01,0,$80C,$90C,$A0C,0

	DC.W	$80D,$90C,$A0A,0,$80E,$908,$A06,0
	DC.W	$80E,$907,$A07,0,$80E,$908,$A00,0
	DC.W	$80E,$907,$A05,0,$80E,$906,$A06,0
	DC.W	$80D,$90C,$A09,0,$80E,$905,$A05,0
	DC.W	$80E,$904,$A04,0,$80D,$90C,$A08,0
	DC.W	$80D,$90B,$A0B,0,$80E,$900,$A00,0
	DC.W	$80D,$90C,$A06,0,$80D,$90C,$A05,0
	DC.W	$80D,$90C,$A02,0,$80C,$90C,$A0B,0

	DC.W	$80C,$90C,$A0B,0,$80D,$90B,$A0A,0
	DC.W	$80D,$90B,$A0A,0,$80D,$90B,$A0A,0
	DC.W	$80D,$90B,$A0A,0,$80C,$90C,$A0A,0
	DC.W	$80C,$90C,$A0A,0,$80C,$90C,$A0A,0
	DC.W	$80D,$90B,$A09,0,$80D,$90B,$A09,0
	DC.W	$80D,$90A,$A0A,0,$80D,$90A,$A0A,0
	DC.W	$80D,$90A,$A0A,0,$80C,$90C,$A09,0
	DC.W	$80C,$90C,$A09,0,$80C,$90C,$A09,0

	DC.W	$80D,$90B,$A06,0,$80C,$90B,$A0B,0
	DC.W	$80C,$90C,$A08,0,$80D,$90B,$A00,0
	DC.W	$80D,$90B,$A00,0,$80C,$90C,$A07,0
	DC.W	$80C,$90C,$A06,0,$80C,$90C,$A05,0
	DC.W	$80C,$90C,$A03,0,$80C,$90C,$A01,0
	DC.W	$80C,$90B,$A0A,0,$80D,$90A,$A05,0
	DC.W	$80D,$90A,$A04,0,$80D,$90A,$A02,0
	DC.W	$80D,$909,$A08,0,$80D,$909,$A08,0

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
 	DC.W	$0106	
	DC.W	$0106

************************************
*     KEYBOARD MESSAGE STRINGS     *
************************************
	EVEN
SKBDDIS	DC.B	$13		STOP DATA
	EVEN
SKBDEN	DC.B	$11		RESTART REPORTING
**************************************
*	DEFINE PROGRAM STORAGE       *
**************************************
	EVEN
VARS
XTERNAL	RS.B	1	$FF = EXTERNAL O/P SELECTED
INUSE	RS.B	1	INTERRUPT IN USE FLAG
OPTION	RS.B	1	INT. OPTION  $FF = SAMPLE
	EVEN
FREQNUM	RS.W	1	FREQUENCY SELECTED
STATUS	RS.W	1	STATUS REGISTER
MFPMEM	RS.B	8	SAVED MFP DATA
SAMPLE	RS.L	1
LENGTH	RS.L	1
FREQNCY	RS.L	1
STACK	RS.L	1
	EVEN
	ds.l 100
PICTURE
	move.l #graphix+2,-(a7)
	move.w #6,-(sp)
	trap #14
	addq.l #6,sp
	move.w #2,-(sp)
	trap #14
	addq.l #2,sp
	move.l d0,a1
	lea graphix,a0
	lea $22(a0),a0
	move.w #$FA0,d6
jere	move.l (a0)+,(a1)+
	MOVE.L (A0)+,(A1)+
	dbf d6,jere
	rts

*********************************************************************
* Here you change the various sample names

graphix	incbin "yello.pi1"

FILE	DC.B "YELLO.SPL",0
	EVEN

*********************************************************************

SAMPLEPOINT	DC.L SAMPLETAB

HANDLE	DS.W 1
	EVEN

*********************************************************************
* Here you give the samples their names
SAMPLED
YELLO0	EQU SAMPLED+47230
YELLO1	EQU YELLO0+48365
YELLO2	EQU YELLO1+46154
*YELLO2	EQU YELLO15+115316     * the following are not used as i only have three
*YELLO3	EQU YELLO2+157100	* different samples
*YELLO4	EQU YELLO3+219048
*YELLO5	EQU YELLO4+76446
*YELLOEND	EQU YELLO5+16943

SAMPLETAB	DC.L YELLO0,YELLO0,YELLO1,YELLO2,YELLO2,YELLO0,YELLO0,YELLO1,YELLO1,YELLO2,YELLO2,0,0,0

*********************************************************************

a dc.b 0
b dc.b 0
c dc.b 0
d dc.b 0
text	dc.b $1b,$45,0
	even
string dc.b $12,$1a
oldssp ds.l 1
phys ds.l 1
phys1 ds.l 1
store ds.l 1
handle ds.w 1
count  dc.b 15
count1 dc.b 7

*********************************************************************
* write your own scrolltext, do not forget the dc.b " ....." and the ,$ff


scrolline	dc.b "       HI EVERYBODY, THIS IS THE SAMPLE SAMPLE DEMO TO SHOW YOU WHAT YOU CAN DO WITH THE YELLO SOURCE CODE, I HOPE THAT IT IS OF SOME USE TO YOU..........",$FF

        even
*********************************************************************

font
	incbin "lost.fon"
data


