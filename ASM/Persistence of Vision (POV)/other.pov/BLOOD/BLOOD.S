	bra	START
 dc.b	"   HACKER GO AWAY!     "
	even
;		start,   length
sound1	dc.l	sound+0,37093
sound2	dc.l	sound+37393,37174
sound3	dc.l	sound+74776,10020
sound4	dc.l	sound+85024,25818
sound5	dc.l	sound+110888,4518
sound6	dc.l	sound+115504,40804
sound7	dc.l	sound+156472,10154
sound8	dc.l	sound+166720,51358
sound9	dc.l	sound+218184,74660	;74559
sound10	dc.l	sound+292944,26824
sound11	dc.l	sound+319832,37093
sound12	dc.l	sound+356960,17344

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

*	BDOS EQUATES (TRAP #1)

P_TERM_OLD	EQU	0	
F_SUPER		EQU	$20

*	XBOIS EQUATES (TRAP #14)

IKBDWS	EQU	25

*******************************
*      THE MACHINE CODE.      *
*******************************

START	BRA.S	SUPER

SFREQ	DS.L	1	Memory locations.

*****************************************
*           THE PROGRAMME               *
*****************************************
*   SET UP STACK, MEMORY & SUPERVISOR   *
*****************************************

SUPER	MOVEM.L	A0-A6/D0-D7,-(SP) SAVE 'BASIC' SYSTEM

	BSR	KEYSOFF		DISABLE KEYBOARD

	CLR.L	-(SP)		
	MOVE.W	#F_SUPER,-(SP)	GOTO SUPERVISOR
	TRAP	#1
	ADDQ.L	#6,SP
	LEA	VARS(PC),A2	SAVE THE SUPERVISOR STACK POINTER!!
	MOVE.L	D0,STACK(A2)

	lea	pic+2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#0,-(sp)
	move.l	$44e.w,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	movem.l	(sp)+,d0-d7/a0-a6

	move.l	$44e.w,a1
	move.l	a1,screen_base
	lea	pic+34,a0
	move.w	#32000/4-1,d0
draw	move.l	(a0)+,(a1)+
	dbf	d0,draw

	BSR	SAVEMFP		SAVE NATURAL MFP CONDITIONS
	MOVE.W	#$2700,SR	INTERRUPTS OFF
	LEA	INULL(PC),A0
	BSR	SETINT		SET NULL INTERRUPT ADDRESS
	MOVE.L	FREQNCY,D0	SET INITIAL FREQUENCY
	BSR	SETFREQ
	BSR	ENABMFP		SET THE MFP RUNNING
	BSR	SETSND		SET UP SOUND REGISTERS
	
	BSR	INTREGS		SET UP INTERNAL REGISTERS
	move.l	$70.w,old70
	move.l	#new70,$70.w
	move.l	#0,offset
	MOVE.W	#$2300,SR	ENABLE LEVEL 3 INTERRUPTS so we have VBL

loop	lea	sound4,a1
	bsr	do_sample
	lea	sound12,a1
	bsr	do_sample
	lea	sound3,a1
	bsr	do_sample

	lea	sound10,a1
	bsr	do_sample
	lea	sound7,a1
	bsr	do_sample
	lea	sound8,a1
	move.l	#20000,offset
	bsr	do_sample
	lea	sound7,a1
	bsr	do_sample
	lea	sound1,a1
	bsr	do_sample
	lea	sound2,a1
	bsr	do_sample
	lea	sound1,a1
	bsr	do_sample
	lea	sound5,a1
	bsr	do_sample
	lea	sound5,a1
	bsr	do_sample
	lea	sound11,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample

	lea	sound1,a1
	move.l	#8500,offset
	bsr	do_sample
	lea	sound5,a1
	bsr	do_sample
	lea	sound5,a1
	bsr	do_sample
	lea	sound11,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample
	lea	sound7,a1
	bsr	do_sample
	lea	sound8,a1
	move.l	#20000,offset
	lea	sound12,a1
	bsr	do_sample
	lea	sound7,a1
	bsr	do_sample
	lea	sound8,a1
	bsr	do_sample
	lea	sound3,a1
	bsr	do_sample
	lea	sound10,a1
	bsr	do_sample

	lea	sound1,a1
	bsr	do_sample
	lea	sound2,a1
	bsr	do_sample
	lea	sound1,a1
	bsr	do_sample
	lea	sound5,a1
	bsr	do_sample
	lea	sound5,a1
	bsr	do_sample
	lea	sound11,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample
	lea	sound3,a1
	bsr	do_sample
	lea	sound10,a1
	bsr	do_sample
	lea	sound8,a1
	move.l	#40000,offset
	bsr	do_sample
	lea	sound4,a1
	bsr	do_sample
	lea	sound6,a1
	bsr	do_sample
	lea	sound1,a1
	bsr	do_sample

	lea	sound1,a1
	move.l	#20000,offset
	bsr	do_sample
	lea	sound12,a1
	move.l	#5000,offset
	bsr	do_sample
	lea	sound5,a1
	move.l	#2000,offset
	bsr	do_sample
	lea	sound5,a1
	move.l	#2000,offset
	bsr	do_sample
	lea	sound5,a1
	move.l	#2000,offset
	bsr	do_sample
	lea	sound5,a1
	bsr	do_sample
	lea	sound2,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample
	lea	sound9,a1
	bsr	do_sample

	bra	loop
offset	dc.l	0
do_sample
	move.l	(a1)+,a6
	move.l	(a1)+,d6
	add.l	a6,d6
	tst.l	offset
	beq.s	.no_alter
	sub.l	offset,d6
.no_alter
	ST	INUSE(A2)	SIGNAL REPLAY IN USE
	LEA	IREPLAY(PC),A0	SET UP THE OUTPUT CODE ADDRESS
	BSR	SETINT		GO TO IT

*  Now wait for interrupt to do its business.
WAIT	TST.B	INUSE(A2)	SAMPLE FINISHED ?
	BNE.S	WAIT		BR. IF NOT
	clr.l	offset
	rts

new70	move.b	#0,$fffffa1b.w	;timer B
	bsr	scroll
	bsr	scroll
	move.b	#8,$fffffa1b.w
	rte

scroll	tst.w	new_char
	bne.s	.sc
	move.l	scroll_pos,a0
	move.b	(a0)+,D1
	cmp.b	#$FF,D1
	bne.s	.OK
	lea	mess,a0
	move.b	(a0)+,d1
.OK	move.l	a0,scroll_pos

	and.l	#$FF,D1
	sub.b	#32,D1		;rid ourselves of ASCII chains
	mulu	#8,D1		;calc character offset

	lea	FONT,A1
	add.w	D1,A1

	lea	BUFFER,A0
	move.l	(A1)+,(A0)
	move.l	(A1)+,4(A0)
	moveq	#0,d2

.sc	lea	BUFFER,a0
	move.l	screen_base,a1
	add.w	#(199*160)-(8*160),a1
	moveq.l	#7,d3
LINES	move.l	a1,-(sp)
	adda.l	#152,a1
	move.b	(a0),D1
	lsl.b	#1,D1
	move.b	D1,(a0)+
	REPT	20
	move.w	2(a1),D1
	roxl.w	#1,D1		;scroll 2 chars at a time
		;	move.w	D1,(a1)
	move.w	D1,2(a1)
		;	move.w	D1,4(a1)
	move.w	D1,6(a1)
	subq.l	#8,a1	;move back a byte for next position on scrn
	ENDR
	movea.l	(sp)+,a1
	lea	160(a1),a1	;drop down a line
	dbra	d3,LINES

	addq.w	#1,D2
	andi.w	#7,D2	;test the buffer to see if empty?
	bne	.no
	clr.w	new_char
	rts
.no	move.w	#$ffff,new_char
	rts

*  This tidies the system up before leaving back to BASIC.
*
exit	MOVE.W	#$2700,SR	DISABLE INTS.
	move.l	old70,$70.w
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

	clr.w	-(sp)			;exit
	trap	#1


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

IREPLAY
	MOVE.B	(A6)+,D7	READ FROM RAM
	CMP.L	D6,A6		EXCEDED END STOP
	BGT.S	HALTREP		BRANCH IF SO
	JMP	(A5)		ELSE OUTPUT IT

HALTREP	MOVE.W	#$2700,SR	;remove relay interrupt routine
	MOVE.W	SR,D0
	MOVE.W	#$2700,SR
	MOVE.L	#INULL,ISRVEC
	MOVE.W	D0,SR
	SF	INUSE(A2)
	MOVE.W	#$2500,SR
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

***********************************
*     THE SYSTEM SUB-ROUTINES     *
***********************************
*   PRESERVE THE MFP REGISTERS    *
***********************************

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

SETINT
	MOVE.W	SR,D0
	MOVE.W	#$2700,SR
	MOVE.L	A0,ISRVEC
	MOVE.W	D0,SR
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
FREQTAB	DC.W	$0506	0 = 4.9 KHZ
	DC.W	$0505	1 = 7.68 KHZ
	DC.W	$0455	2 = 9.6 KHZ
	DC.W	$2991   3 = 14.985 KHZ
	DC.W	$1F01	4 = 19.2 KHZ
	DC.W	$0802	5 = 30.7 KHZ
	DC.W	$0602	6 = 40.96 KHZ
	DC.W	$0104	7 = 49.152 KHZ

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
*
*  The RS.x command does not reserve space. It simply acts as
*  a dynamically allocated 'EQU'ate for position independance.
*  The RS.x commands must be followed by at least one suitable
*  DS.x command to allocate the necessary memory for the code.
*  Other assmblers not supporting the RS directive must assign
*  labels with suitable equates or replace the RS.x with DS.x.
*  where appropriate.
*
*  Firstly declare the Offsets..
* 
	EVEN
screen_base	ds.l	1
old70		ds.l	1
INUSE	RS.B	1	INTERRUPT IN USE FLAG
OPTION	RS.B	1	INT. OPTION  $FF = SAMPLE
	EVEN
FREQNUM	RS.W	1	FREQUENCY SELECTED
STATUS	RS.W	1	STATUS REGISTER
MFPMEM	RS.B	8	SAVED MFP DATA
STACK	RS.L	1
*
*  Now declare the memory space
*
	EVEN
VARS	DS.B	34

FREQNCY	dc.L	2

	even
new_char	dc.w	0
scroll_pos	dc.l	init_mess
init_mess	dc.b	"                         "
mess
 dc.b "    WHERE IS THE MONEY?             MAC SYS DATA OF P.O.V. "
 dc.b "PRESENTS THE BLOOD MONEY SOUND DEMO.        "
 DC.B "I RECODED THIS DEMO BECAUSE IT DIDN'T WORK ON THE STE (STOS) "
 DC.B "AND BECAUSE THE AUTHOR LEFT THE BASIC SOURCE ON THE DISC SO I "
 dc.b "FOUND OUT WHERE THE 12 SAMPLES LOOPED.                    PERSISTENCE OF VISION "
 DC.B "IS MADE UP OF 3 MEMBERS.....      1: MAC SYS DATA - CODER/"
 DC.B "HACKER/PACKER,                2: BORIS - CODER,                "
 DC.B "3: OZYMANDIAS - GRAPHIC ARTIST.                WE AT P.O.V. "
 DC.B "BELIEVE THAT YOU SHOULD GET AS MUCH PD AS POSSIBLE FOR AS LITTLE "
 DC.B "MONEY AS POSSIBLE, THAT'S WHY WE PACK DEMOS AND CRAM DISCS FULL TO THEIR LIMIT. "
 dc.b "                 YOU MAY NOT "
 DC.B "KNOW IT BUT WE AT P.O.V. WRITE OUR OWN DEMOS, ONE EXAMPLE IS THE 'KINKY "
 DC.B "BOOTS' SAMPLE DEMO - BRILLIANT QUALITY WHICH PLAYS FOR OVER 2 MINUTES.          "
 dc.b "        IF YOU WANT TO KNOW MORE ABOUT P.O.V. "
 DC.B "OR WOULD LIKE TO CONTACT US FOR DEMO/CODE SWAPS, ETC. THEN WRITE "
 DC.B "TO...              P.O.V.,                P.O. BOX 40,                "
 DC.B "THORNTON-CLEVELEYS,                BLACKPOOL,                LANCS.,"
 DC.B "                FY5 3PH,                UK.                     "
 dc.b "WE DO NOT WANT CONTACT WITH PEOPLE WHO ARE INTERESTED IN GAME SWAPS, ETC.     "
 DC.B "                 HERE ARE SOME GREETINGS, A  B I G  HELLO TO:    BILBO OF "
 DC.B "RIPPED OFF,       GEORGE 'BART' SIMPSON (TOWER PD),      "
 DC.B "DR.SYNE (ARE YOU STILL LIVING?),      BORIS,      OZ,      KGB (FRANCE),      "
 DC.B "SLAYTANIC CULTS,      THE SOURCE,      ERIK PLANKTON + BLIND BASTARD      "
 DC.B "AND      THE MOUNTAINS OF PD LIBRARIES THAT DISTRIBUTE OUR DISCS.               "
 DC.B "           THIS DEMO PLAYS THE SAMPLES SLIGHTLY FASTER THAN THE ORIGINAL AS I "
 DC.B "THOUGHT IT SOUNDED BETTER THIS WAY.                      "
 DC.B "RIGHT, I WOULD LIKE TO SEND A PLEA TO ALL DEMO CODERS....   I HAVE "
 DC.B "LOST MY STE NOISETRACKER MODULE REPLAY ROUTINE, AS A RESULT I CAN'T "
 DC.B "WRITE SOME OF THE STE FILLER DEMOS I HAD PLANNED.  IF YOU HAVE THE ROUTINE CAN YOU "
 DC.B "SEND IT TO ME (MAC SYS DATA) VIA THE ADDRESS GIVEN EARLIER.              "
 DC.B "         TO RECODE THIS DEMO I USED THE FOLLOWING PROGRAMS....       "
 DC.B "DEVPAC DEVELOPER V2.23,        CYBERPAINT        AND        "
 DC.B "ST REPLAY 4.        IT HAS BEEN TESTED ON THE FOLLOWING EQUIPMENT....        "
 DC.B "A 4 MEG STE - TOS 1.06,        A 512K STFM - TOS 1.09,        "
 DC.B "A 1 MEG STFM - TOS 0.19        AND      A 2.5 MEG STFM - TOS 1.09.        "
 DC.B "I MUST POINT OUT THAT I TESTED IT ON MY 1 MEG AMIGA BUT IT DIDN'T WORK!!!        "
 DC.B "     TODAY'S DATE IS 3RD OF AUGUST 1991 AND I'M GOING TO SEE "
 DC.B "TERMINATOR 2 AT THE ODEON IN BLACKPOOL (YEAH!).               "
 DC.B "OK, SO YOU'VE SEEN IT ALREADY, SEE IF I CARE.       ANYWAY I'VE SEEN "
 DC.B "P.O.V. 100 AND IT HASN'T BEEN RELEASED YET!!!!!                    "
 DC.B "              BYE.                         WRAP TEXT + SOUND! "
 dc.b	$FF,$FF
	even
BUFFER:	ds.w	8
FONT:	ds.b	8
	incbin	"WAS_SET.IMG'
	even
pic	incbin	pic.pi1
sound	incbin	samples.spl
