*********************************************************************
*                         IVOR BIGGUN DEMO                          *
*                         ----------------                          *
*                                                                   *
*********************************************************************

	dc.w	$a00a
	jsr	set_super
	bsr	wait_for_drive
	jsr	set_low_rez
	lea	roger+2,a0
	jsr	set_palette
	jsr	transfer
	jsr	load

REPEAT:
	lea	roger,A5	;start
	move.l	#702402,D5	;length
	move.l	#2,D4		;speed
	bsr	REPLAY

	lea	roger,A5	;start
	move.l	#37542,D5	;length
	move.l	#2,D4		;speed
	bsr	REPLAY

	lea	roger+31202,A5	;start
	move.l	#37542-31202,D5	;length
	move.l	#2,D4		;speed
	bsr	REPLAY

	lea	roger+31672,A5	;start
	move.l	#2848,D5	;length
	move.l	#2,D4		;speed
	bsr	REPLAY

	lea	roger+31672,A5	;start
	move.l	#2848,D5	;length
	move.l	#2,D4		;speed
	bsr	REPLAY

	lea	roger+31672,A5	;start
	move.l	#2848,D5	;length
	move.l	#2,D4		;speed
	bsr	REPLAY

	lea	roger+31672,A5	;start
	move.l	#2848,D5	;length
	move.l	#2,D4		;speed
	bsr	REPLAY

	lea	roger+31202,A5	;start
	move.l	#260895-31202,D5	;length
	move.l	#2,D4		;speed
	bsr	REPLAY

	lea	roger+254801,A5	;start
	move.l	#260895-254801,D5	;length
	move.l	#2,D4		;speed
	bsr	REPLAY

	lea	roger+254801,A5	;start
	move.l	#260895-254801,D5	;length
	move.l	#2,D4		;speed
	bsr	REPLAY

	lea	roger+254801,A5	;start
	move.l	#260895-254801,D5	;length
	move.l	#2,D4		;speed
	bsr	REPLAY

	lea	roger+260895,A5	;start
	move.l	#702402-260895,D5	;length
	move.l	#2,D4		;speed
	bsr	REPLAY

	bra	REPEAT

REPLAY:	MOVE.W	#$2700,SR	;ALL INTERRUPTS OFF
	LEA	INULL,A0
	BSR	SETINT		;SET NULL INTERRUPT ADDRESS
	BSR	SETFREQ	 	;SET INITIAL FREQUENCY
	BSR	DISMOUS	 	;SWITCH MOUSE REPORTING OFF
	BSR	ENABMFP		;SET THE MFP RUNNING
	BSR	SETSND		;SET UP SOUND REGISTERS
	BSR	REGSINT	 	;SET OUTPUT THROUGH spEAKER
;CALCULATE THE SAMPLE END ADDRESS
	ADD.L	A5,D5	; START + LENGTH = END
; SET UP INTERRUPT AND START REPLAYING
	LEA	IREPLAY,A0	; ROUTINE ADDRESS
	BSR	SETINT		; INSTALL
	ST	INUSE		; FLAG INTERRUPT ACTIVE
	MOVE.W	#$2500,SR	; & ACTIVATE
IDLE:	
	TST.B	INUSE	; WAIT HERE UNTIL DONE
	BNE.S	IDLE
	rts
;***************************************
;   THE INTERRUPT SERVICE ROUTINES     *
;***************************************
;	A6 = NOT USED
;	A5 = POINTER TO BASE OF REPLAY RAM
;	A4 = G.I. CHIP ADDRESS
;	A3 = INT. SND LOOK UP TABLE
;	A2 = NOT USED
;	A1 = NOT USED
;	A0 = RESERVED FOR MAIN PROG.
;	D7 = BYTE TO BE OUTPUT
;	D6 = NOT USED
;	D5 = POINTER TO END OF REPLAY RAM
;	D4 = NOT USED
;	D3 = SOUND CHIP DATA
;	D2 = SOUND CHIP DATA
;	D1 = NOT USED
;	D0 = NOT USED 

;***************************************
;     THE NULL INTERRUPT ROUTINE       *
;***************************************

INULL:	RTE

;***************************************
;       REPLAY FROM MEMORY             *
;***************************************

IREPLAY:
	MOVE.B	(A5)+,D7	; READ FROM RAM
	CMP.L	D5,A5		; EXCEDED END STOP
	BGE.S	HALTREP		; BRANCH IF SO

	AND.W	#$FF,D7		; MASK OFF RUBBISH
	ADD.B	#$80,D7		; COMPLENT VALUE
	LSL.W	#3,D7		; DOUBLE LONG WORD OFFSET
	MOVE.L	0(A3,D7.W),D3	; GET DATA #1
	MOVE.W	4(A3,D7.W),D2	; GET DATA #2
	MOVEP.L	D3,0(A4)	; PLAY #1
	MOVEP.W	D2,0(A4)	; PLAY #2
	RTE

HALTREP:
	MOVE.W	#$2700,SR
	LEA	INULL,A0	;REMOVE REPLAY INT.
	BSR	SETINT
	SF	INUSE
	MOVE.W	#$2500,SR
	RTE

;**************************
; THE SYSTEM SUB-ROUTINES *
;**************************
;************************
;  IKBD ENABLE/DISABLE  *
;************************

DISMOUS:
	PEA	SKBDDIS
	MOVE.W	#1,-(A7)	; 2 PARAMETERS
	BRA.S	DO_IKBD
ENMOUSE:
	PEA	SKBDEN
	MOVE.W	#0,-(A7)	; 1 PARAMETER
DO_IKBD:
	MOVE.W	#$19,-(A7)
	TRAP	#14
	ADDQ.L	#8,A7
	RTS
	
;****************************
;  CHOOSE INTERRUPT VECTOR  *
;****************************

;   SET UP SELECTED INTERRUPT WITH A0.L
;   CONTAINING THE NEW ROUTINE VECTOR
;
SETINT:	MOVE.W	SR,D0
	MOVE.W	#$2700,SR
	MOVE.L	A0,$134	; INSTALL NEW ROUTINE
	MOVE.W	D0,SR
	RTS

;************************
;  SET UP MFP FREQUENCY *
;************************

;   SET UP MFP TIMER 'A' TO GENERATE INTERRUPTS.
;   ENTER WITH D4.W SET WITH A FREQUENCY NUMBER 0 TO 7
;   D4.W = $2, GETS 3RD MFP DATA FROM TABLE (10 KHZ)
;
SETFREQ:
	MOVE.B	#0,$FFFA19	; DISABLE TIMER
	AND.W	#7,D4		; ENSURE 0-7
	LEA	FREQTAB,A0 	; GET FREQ TABLE ADDR
	LSL.W	#1,D4		; CONVERT TO WORD TABLE OFFSET
	MOVE.W	0(A0,D4.W),D4	; GET THE MFP DATA
	MOVE.B	D4,$FFFA19	; LSB = CONTROL REG BYTE
	LSR.W	#8,D4		; SHIFT DOWN NEXT BYTE
 	MOVE.B	D4,$FFFA1F		; NEXT = DATA REG BYTE
	RTS

;******************
;  ENABLE THE MFP *
;******************

ENABMFP:
	MOVE.B	#$20,$FFFA13
	MOVE.B	#0,$FFFA15
	MOVE.B	#$20,$FFFA07
	MOVE.B	#0,$FFFA09
	BCLR	#3,$FFFA17
	RTS

;***********************************
;  SET UP THE SOUND CHIP CHANNELS  *
;***********************************

SETSND:	MOVE.B	#0,$ff8800	; CHANNEL A
	MOVE.B	#0,$ff8802
	MOVE.B	#1,$ff8800
	MOVE.B	#0,$ff8802

	MOVE.B	#2,$ff8800	; CHANNEL B
	MOVE.B	#0,$ff8802
	MOVE.B	#3,$ff8800
	MOVE.B	#0,$ff8802

	MOVE.B	#4,$ff8800	; CHANNEL C
	MOVE.B	#0,$ff8802
	MOVE.B	#5,$ff8800
	MOVE.B	#0,$ff8802

	MOVE.B	#7,$ff8800	; SET UP CHANNEL MIXING
	MOVE.B	#$FF,$ff8802

	MOVE.B	#8,$ff8800	; SET ALL VOLUMES TO ZERO
	MOVE.B	#0,$ff8802
	MOVE.B	#9,$ff8800
	MOVE.B	#0,$ff8802
	MOVE.B	#10,$ff8800
	MOVE.B	#0,$ff8802
	RTS

;**************************************
;    SET UP REGS. FOR INTERNAL        *
;**************************************

REGSINT:
	MOVE.W	SR,D0
	MOVE.W	#$2700,SR
	MOVE.L	#$ff8800,A4	; SOUND CHIP CNTRL REG
	LEA	SND_OUT,A3	; LOOK UP TABLES
	MOVEQ	#0,D7
	MOVE.W	D0,SR
	RTS

;**************************************
;    INTERNAL SOUND LOOKUP TABLE.     *
;**************************************
	EVEN
SND_OUT:
	DC.W	$80C,$90B,$A09,0,$80C,$90B,$A09,0
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

;**********************
; MFP/FREQUENCY TABLE *
;**********************
	EVEN
FREQTAB:
	DC.W	$506	; (0) = 4.9 KHZ
	DC.W	$505	; (1) = 7.68 KHZ
	DC.W	$405	; (2) = 9.6 KHZ
	DC.W	$2901	; (3)	= 15  KHZ
	DC.W	$1F01	; (4) = 19.8 KHZ
	DC.W	$802	; (5) = 30.7 KHZ
	DC.W	$405	; (6) = spARE
	DC.W	$405	; (7) = spARE

	EVEN
;***************************
; KEYBOARD MESSAGE STRINGS *
;***************************

SKBDDIS:	DC.B	$12,$1A	; DISABLE MOUSE AND JYSTKS
SKBDEN:	DC.B	$8		; RESET KBD
	even
MFPMEM:	ds.b	8	; SAVED MFP DATA
INUSE:	ds.b	1	; INTERRUPT IN-USE FLAG
	even
load:	lea	F_NAME,a0
	bsr	F_OPEN	
	move.l	#roger,F_START
	move.l	#800000,LENGTH
	bsr	F_LOAD
	bsr	F_CLOSE
	rts
F_OPEN:
;	FILENAME IS POINTED TO BY reg. A0
;	Set file for read/write     F_OPEN
	move.w	#2,-(sp)
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	ADDQ.l	#8,sp	; File Handle is now in D0
	MOVE.L	D0,HANDLE
	RTS
F_LOAD:			; Load file
	MOVE.L	F_START,-(sp)
	MOVE.L	LENGTH,-(sp)
	MOVE.L	HANDLE,D0
	MOVE.W	D0,-(sp)	;PUT HANDLE ON STACK
	MOVE.W	#63,-(sp)
	TRAP	#1
	add.l	#12,sp
	RTS
F_CLOSE:		; Close file
	MOVE.L	HANDLE,D0
	MOVE.W	D0,-(sp)
	MOVE.W	#62,-(sp)
	TRAP	#1
	ADDQ.l	#4,sp
	RTS
wait_for_drive
	move.w	$ff8604,d0
	btst	#7,d0
	bne.s	wait_for_drive
	rts
F_START:	dc.l	0	;Start address to LOAD at.
LENGTH:		dc.l	0	;Number of bytes to LOAD.
HANDLE:		dc.l	0
	even
roger:	incbin	"e:\ivor\ivor.pi1"
OLD_STACK:	DC.L	1
screen_base:	dc.l	0
F_NAME:		DC.B	"wanker.spl"
		DC.B	0
	even

pause:	move.w	d0,-(sp)
	move.w	#2000,d0
pau:	nop
	dbf	d0,pau
	move.w	(sp)+,d0
	rts

set_super:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,OLD_STACK
	rts

set_palette:
	lea	$FF8240,A1
	move.w	#16-1,d0
set_col:
	move.w	(a0)+,(a1)+
	dbf	d0,set_col
	rts

set_low_rez:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base
	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts
transfer:
	move.l	screen_base,a1
	lea	roger+34,a0
	move.w	#32000/4-1,d0
.loop:	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts

	EVEN

