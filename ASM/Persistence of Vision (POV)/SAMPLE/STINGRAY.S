***************************************************************
*       STINGRAY DEMO                                         *
*       -------------                                         *
*                                                             *
* Re-written by MAC SYS DATA of P.O.V.                        *
* GFA BASIC programs will not pack if any loads are used to   *
* load part files!                                            *
*                                                             *
***************************************************************
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

SND_CHP	EQU	$FF8800 CHIP ADDRESS	
SCREG	EQU	0	CHIP REGISTER SELECT
SCDATA	EQU	2	REGISTER DATA

KBDCONT	EQU	$FFFC00
KBDDATA	EQU	KBDCONT+2
MIDCONT	EQU	$FFFC04
MIDDATA	EQU	MIDCONT+2

INPUT	EQU	$FB0001
OUTPUT	EQU	$FA0000

	move.l	a7,a5
	move.l	4(a5),a5	;get basepage
	move.l	$C(a5),d0	;text segment
	add.l	$14(a5),d0	;data segment
	add.l	$1C(a5),d0	;unitialized
	add.l	#$100,d0	;basepage size
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp		;okay that's it memory free & allocated

	bsr	set_super
	dc.w	$a00a		;hide mouse
	bsr	get_screen_base
	lea	black_pal,a0
	bsr	set_palette
	bsr	set_low_rez

	move.w	#$777,$ff825e
	pea	intro_mess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	clr.w	$ff825e

	bsr	load_title
	lea	pic+34,a0
	bsr	show_pic
	lea	pic+2,a0
	bsr	set_palette

	bsr	load_sample

	bsr	load_main_pic
	lea	black_pal,a0
	bsr	set_palette
	lea	pic+34,a0
	bsr	show_pic
	lea	pic+2,a0
	bsr	set_palette

	bra	sample_bit
*******************
* CUSTOM ROUTINES *
*******************
show_pic:
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
.loop:	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts

set_super:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1		;back to user
	addq.l	#6,sp		;correct stack
	move.l	d0,stack_save
	rts

set_palette:	;pal in A0 on entry
	lea	$ff8240,a1
	move.w	#8-1,d0
set_p:	move.l	(a0)+,(a1)+
	dbf	d0,set_p
	rts

get_screen_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base
	rts

set_low_rez:
	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

load_title:
	lea	title,a0
	bsr	f_open	
	move.l	#pic,f_start
	move.l	#32066,f_length
	bsr	f_read
	bsr	f_close
	rts
load_main_pic:
	lea	main,a0
	bsr	f_open	
	move.l	#pic,f_start
	move.l	#32066,f_length
	bsr	f_read
	bsr	f_close
	rts
load_sample:
	lea	f_sample,a0
	bsr	f_open	
	move.l	#pic+32066,f_start
	move.l	#180570,f_length
	bsr	f_read
	bsr	f_close
	rts

f_open:
;	FILENAME IS POINTED TO BY reg. A0
	move.w	#2,-(sp)
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.l	d0,d7
	tst.l	d7
	bmi	err
	rts
f_read:
	move.l	f_start,-(sp)
	move.l	f_length,-(sp)
	move.w	d7,-(sp)
	move.w	#63,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	err
	rts
f_close:
	move.w	d7,-(sp)
	move.w	#62,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	bmi	err
	rts

err:	pea	f_err
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
flash:	sub.w	#1,$ff8240
	bra.s	flash
f_err:	dc.b	27,'E'
	dc.b	"An error has occured during loading.",13,10,10
	dc.b	"Do the following ;-",13,10,10
	dc.b	"1: Turn off/on and try again.",13,10
	dc.b	"2: Get another copy and try again.",13,10
	dc.b	"3: In dire cases phone (0253) 700382 ",13,10
	dc.b	"   ask for Mark and explain what happened",13,10
	dc.b	"   and what machine config. you have.",13,10,10
	dc.b	"Ta- MAC SYS DATA... 1-3-90",13,10,0

****************
* DATA SECTION *
****************
stack_save:	dc.l	0
screen_base	dc.l	0
black_pal:	dcb.w	0,16
f_start:		dc.l	0
f_length:		dc.l	0
title:	dc.b	"TITLE.BUN",0
	even
main:	dc.b	"STINGRAY.FAB",0
	even
f_sample: dc.b	"STINGRAY.SKU",0
	even

sample_bit:
	bsr	KEYSOFF		DISABLE KEYBOARD
	LEA	VARS(PC),A2	SAVE THE SUPERVISOR STACK POINTER!!
	MOVE.L	D0,STACK(A2)
*********** SET UP DATA FOR START, LENGTH AND FREQUENCY ************
loop:
	move.l	#pic+32066,SAMPLE(A2)
	move.l	#180569,LENGTH(A2)
	move.l	#1,FREQNCY(A2)
	bsr	go

	move.l	#pic+68496+32066,SAMPLE(A2)
	move.l	#180569-68496,LENGTH(A2)
	move.l	#1,FREQNCY(A2)
	bsr	go

	move.l	#pic+68496+32066,SAMPLE(A2)
	move.l	#180569-68496,LENGTH(A2)
	move.l	#1,FREQNCY(A2)
	bsr	go

	move.l	#pic+68496+32066,SAMPLE(A2)
	move.l	#180569-68496,LENGTH(A2)
	move.l	#1,FREQNCY(A2)
	bsr	go

	move.l	#pic+68496+32066,SAMPLE(A2)
	move.l	#180569-68496,LENGTH(A2)
	move.l	#1,FREQNCY(A2)
	bsr	go

	bra	loop

********************************************************************
go:
	BSR	SAVEMFP		SAVE NATURAL MFP CONDITIONS
	MOVE.W	#$2700,SR	INTERRUPTS OFF
	LEA	INULL(PC),A0
	BSR	SETINT		SET NULL INTERRUPT ADDRESS
	MOVE.L	FREQNCY(A2),D0	SET INITIAL FREQUENCY
	BSR	SETFREQ
	BSR	ENABMFP		SET THE MFP RUNNING
	BSR	SETSND		SET UP SOUND REGISTERS
	
	SF	XTERNAL(A2)	SET THE MODE FOR INTERNAL ATARI USE
	BSR	INTREGS		SET UP INTERNAL REGISTERS
	MOVE.W	#$2500,SR	ENABLE LEVEL 6 INTERRUPTS

	MOVE.L	SAMPLE(A2),A6	START
	MOVE.L	A6,D6		+ LENGTH
	ADD.L	LENGTH(A2),D6	= END

	ST	INUSE(A2)	SIGNAL REPLAY IN USE
	LEA	IREPLAY(PC),A0	SET UP THE OUTPUT CODE ADDRESS
	BSR	SETINT		GO TO IT
*
*  Now wait for interrupt to do its business.
*
WAIT	TST.B	INUSE(A2)	SAMPLE FINISHED ?
	BNE.S	WAIT		BR. IF NOT
	rts


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
	LEA	INULL(PC),A0	REMOVE REPLAY INT.
	BSR	SETINT
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
*
EXTOUTP	AND.W	#$00FF,D7	REMOVE RUBBISH
	LSL.W	#1,D7		PRESERVE LSB
	MOVE.B	0(A4,D7.W),D7	PLAY OUT BY READING IN !
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

SETINT	MOVE.W	SR,D0
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
DO_IKBD	MOVE.W	#0,-(sp)	1 PARAMETER
	MOVE.W	#$25,-(sp)
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

*****************************************
*     SET UP REGISTERS FOR EXTERNAL     *
*****************************************

EXTREGS	MOVE.W	SR,D0
	MOVE.W	#$2700,SR
	ST	XTERNAL(A2)	TRUE = REPLAY CARTRIDGE IN USE
	LEA	EXTOUTP(PC),A5	GET PORT DRIVER CODE ADDRESS
	MOVE.L	#OUTPUT,A4	SET PORT BASE ADDRESS
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
	DC.W	$0405	2 = 9.6 KHZ
	DC.W	$2901   3 = 14.985 KHZ
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
XTERNAL	RS.B	1	$FF = EXTERNAL O/P SELECTED
INUSE	RS.B	1	INTERRUPT IN USE FLAG
OPTION	RS.B	1	INT. OPTION  $FF = SAMPLE
	EVEN
FREQNUM	RS.W	1	FREQUENCY SELECTED
STATUS	RS.W	1	STATUS REGISTER
MFPMEM	RS.B	8	SAVED MFP DATA
SAMPLE	rs.L	1
LENGTH	rs.L	1
FREQNCY	RS.L	1
STACK	RS.L	1
	EVEN
VARS	DS.B	34
pic:	dc.l	0
intro_mess:
	dc.b	27,'E'
	dc.b	"             STINGRAY DEMO",13,10,10,10
	dc.b	"             Re-written by",13,10,10
	dc.b	"             MAC SYS DATA",13,10,10,10,10
	dc.b	"I re-wrote this demo because SKUNK",13,10
	dc.b	"writes using compiled GFA BASIC and",13,10
	dc.b	"due to his file reading techniques it",13,10
	dc.b	"was virtually impossible for me to",13,10
	dc.b	"pack using normal methods.",13,10,10
	dc.b	"If I use PAMPUK then the demo would",13,10
	dc.b	"be 1 meg ram only.",13,10,10
	dc.b	"Come on SKUNK, either read all the file",13,10
	dc.b	"in one go or make single part demos.",13,10
	dc.b	27,"Y7(","Press a key to continue.",13,10,0