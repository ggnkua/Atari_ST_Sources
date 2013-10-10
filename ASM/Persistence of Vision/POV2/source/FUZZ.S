;	MFP EQUATES
MFP:	EQU	$FFFA00
IERA:	EQU	MFP+$7
IERB:	EQU	MFP+$9
IPRA:	EQU	MFP+$B
ISRA:	EQU	MFP+$F
IMRA:	EQU	MFP+$13
IMRB:	EQU	MFP+$15
VECTOR:	EQU	MFP+$17
TACR:	EQU	MFP+$19
TADR:	EQU	MFP+$1F
ISRVEC:	EQU	$134

;	THE SOUND CHIP
;
SCREG:	EQU	$FF8800	;CHIP REGISTER SELECT
SCDATA:	EQU	$FF8802	;REGISTER DATA

;	BDOS EQUATES 

SUPER: 	EQU	$20
IKBDWS:	EQU	$19

init:	equ	$A000		;A-LINE variables
hide_m:	equ	init+10
show_m:	equ	init+9

	bra	skip_mess
	dc.b	"Hey Dr.Syne, look a text changer. Look LAMER, you slimy "
	dc.b	"piece of SHIT, just p*ss off and write your own "
	dc.b	"stuff instead of putting your name on other peoples programs. "
skip_mess:
	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)	;GOTO SUPERVISOR
	TRAP	#1
	ADDQ.L	#6,A7
	MOVE.L	D0,OLD_STACK

	dc.w	init	;INITIALISE A_LINE ROUTINES
	dc.w	hide_m	;hide mouse

	bsr	MENU

	lea	F_NAME,a0
	bsr	F_OPEN	
	lea	ROGER,A1
	move.l	A1,F_START
	move.l	#638393,LENGTH
	bsr	F_LOAD
	bsr	F_CLOSE

	move.w	#12,D1
top:	clr.w	D0
nop:	sub.w	#1,D0
	bne.s	nop
	dbra	D1,top

REPEAT:
	move.w	#4-1,D0
loop1:	move.w	D0,-(sp)
	lea	ROGER,A5
	move.l	#36008,D5
	move.l	#2,D4
	bsr	REPLAY
	move.w	(sp)+,D0
	dbra	D0,loop1

	move.w	#2-1,D0
bigloop:
	move.w	D0,-(sp)
	lea	ROGER+36008,A5
	MOVE.L	#602385,D5	;D5 CONTAINS LENGTH OF SAMPLE
	MOVE.L	#2,D4		;D4 CONTAINS PLAYBACK SPEED
	bsr	REPLAY

	move.w	#2-1,D0
loop2:	move.w	D0,-(sp)
	lea	ROGER+606198,A5	;A5 CONTAINS FIRST ADDRESS OF SAMPLE
	MOVE.L	#8891,D5	;D5 CONTAINS LENGTH OF SAMPLE
	MOVE.L	#2,D4		;D4 CONTAINS PLAYBACK SPEED
	BSR	REPLAY
	move.w	(sp)+,D0
	dbra	D0,loop2

	move.w	#2-1,D0
loop3:	move.w	D0,-(sp)
	lea	ROGER+606198,A5
	move.l	#4441,D5
	move.l	#2,D4
	bsr	REPLAY
	move.w	(sp)+,D0
	dbra	D0,loop3

	move.w	#4-1,D0
loop4:	move.w	D0,-(sp)
	lea	ROGER+606198,A5
	move.l	#2250,D5
	move.l	#2,D4
	bsr	REPLAY
	move.w	(sp)+,D0
	dbra	D0,loop4

	move.w	(sp)+,D0
	dbra	D0,bigloop

	bra	REPEAT


;THE PROGRAM
REPLAY:	MOVE.W	#$2700,SR	;ALL INTERRUPTS OFF
	LEA	INULL,A0
	BSR	SETINT		;SET NULL INTERRUPT ADDRESS
	BSR	SETFREQ	 	;SET INITIAL FREQUENCY
	BSR	DISMOUS	 	;SWITCH MOUSE REPORTING OFF
	BSR	ENABMFP		;SET THE MFP RUNNING
	BSR	SETSND		;SET UP SOUND REGISTERS
	BSR	REGSINT	 	;SET OUTPUT THROUGH SPEAKER
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
	MOVE.W	#IKBDWS,-(A7)
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
	MOVE.L	A0,ISRVEC	; INSTALL NEW ROUTINE
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
	MOVE.B	#0,TACR		; DISABLE TIMER
	AND.W	#7,D4		; ENSURE 0-7
	LEA	FREQTAB,A0 	; GET FREQ TABLE ADDR
	LSL.W	#1,D4		; CONVERT TO WORD TABLE OFFSET
	MOVE.W	0(A0,D4.W),D4	; GET THE MFP DATA
	MOVE.B	D4,TACR		; LSB = CONTROL REG BYTE
	LSR.W	#8,D4		; SHIFT DOWN NEXT BYTE
 	MOVE.B	D4,TADR		; NEXT = DATA REG BYTE
	RTS

;******************
;  ENABLE THE MFP *
;******************

ENABMFP:
	MOVE.B	#$20,IMRA
	MOVE.B	#0,IMRB
	MOVE.B	#$20,IERA
	MOVE.B	#0,IERB
	BCLR	#3,VECTOR
	RTS

;***********************************
;  SET UP THE SOUND CHIP CHANNELS  *
;***********************************

SETSND:	MOVE.B	#0,SCREG	; CHANNEL A
	MOVE.B	#0,SCDATA
	MOVE.B	#1,SCREG
	MOVE.B	#0,SCDATA

	MOVE.B	#2,SCREG	; CHANNEL B
	MOVE.B	#0,SCDATA
	MOVE.B	#3,SCREG
	MOVE.B	#0,SCDATA

	MOVE.B	#4,SCREG	; CHANNEL C
	MOVE.B	#0,SCDATA
	MOVE.B	#5,SCREG
	MOVE.B	#0,SCDATA

	MOVE.B	#7,SCREG	; SET UP CHANNEL MIXING
	MOVE.B	#$FF,SCDATA

	MOVE.B	#8,SCREG	; SET ALL VOLUMES TO ZERO
	MOVE.B	#0,SCDATA
	MOVE.B	#9,SCREG
	MOVE.B	#0,SCDATA
	MOVE.B	#10,SCREG
	MOVE.B	#0,SCDATA
	RTS

;**************************************
;    SET UP REGS. FOR INTERNAL        *
;**************************************

REGSINT:
	MOVE.W	SR,D0
	MOVE.W	#$2700,SR
	MOVE.L	#SCREG,A4	; SOUND CHIP CNTRL REG
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
	DC.W	$405	; (6) = SPARE
	DC.W	$405	; (7) = SPARE

;***************************
; KEYBOARD MESSAGE STRINGS *
;***************************

SKBDDIS:	DC.B	$12,$1A	; DISABLE MOUSE AND JYSTKS
SKBDEN:	DC.B	$8		; RESET KBD

;*************************
; DEFINE PROGRAM STORAGE *
;*************************
	even
F_OPEN:
;	FILENAME IS POINTED TO BY reg. A0
;	Set file for read/write     F_OPEN
	MOVE.W	#2,-(SP)
	MOVE.L	A0,-(SP)
	MOVE.W	#$3D,-(SP)
	TRAP	#1
	ADDQ.W	#8,SP	; File Handle is now in D0
	MOVE.L	D0,HANDLE
	RTS
F_LOAD:			; Load file
	MOVE.L	F_START,-(SP)
	MOVE.L	LENGTH,-(SP)
	MOVE.L	HANDLE,D0
	MOVE.W	D0,-(SP)	;PUT HANDLE ON STACK
	MOVE.W	#63,-(SP)
	TRAP	#1
	ADDA.W	#12,SP
	RTS
F_CLOSE:		; Close file
	MOVE.L	HANDLE,D0
	MOVE.W	D0,-(SP)
	MOVE.W	#62,-(SP)
	TRAP	#1
	ADDQ.W	#4,SP
	RTS
F_START:	dc.l	1	;Start address to LOAD at.
LENGTH:		dc.l	1	;Number of bytes to LOAD.
HANDLE:		dc.l	1
F_NAME:		DC.B	'A:\FUZZBOX.SPL'
		DC.B	0
	even
OLD_STACK:	DC.L	1	; SUPER BASIC STACK
MFPMEM:	ds.b	8	; SAVED MFP DATA
INUSE:	dc.b	1	; INTERRUPT IN-USE FLAG
	even

MENU:	jsr	GET_BASE
	jSR	GET_REZ
	jSR	GET_PALETTE
	lea	PALETTE,A0
	jSR	SET_PALETTE
	move.w	#0,D0
	jsr	SET_REZ

;************************************************************************
;* play THUNDERCATS music                                               *
;************************************************************************
	move.b	#0,$484		;no keyclick
	move.l	#ISR,$4d2
	bsr	TUNE

;EXPAND ROUTINE
	lea	SCRN,A0
	move.l	#26069,A1
	add.l	A1,A0		;A0 points to end of compressed data

	move.l	SCR_ADD,A1
	add.w	#32000,A1	;go to end of screen
	move.w	$FF8240,-(sp)
LOOP:	lea	SCRN,A2
	cmp.l	A2,A0	;detect end of source
	ble.s	END_EXPAND
	move.b	-(A0),D0	;get source data
	move.b	D0,D2
	roxl.w	#2,D2
	move.w	D2,$FF8240	;change colour 0
	cmp.b	#128,D0	;if -128 then ignore
	beq.s	LOOP
	and.l	#$FF,D0
	btst	#7,D0
	bne.s	NEGATIVE
POSITIVE:	;copy the next N number of bytes as they appear
	cmp.b	#127,D0
	beq.s	TRAP_ER
CARRY_ON:
	jsr	PAUSE
	move.b	-(A0),D4
	move.b	D4,-(A1)
	move.w	D4,D5
	roxl.w	#5,D4
	move.w	D4,$FF8240
	sub.b	#1,D0
	bne.s	CARRY_ON
	bra.s	LOOP
TRAP_ER:
	bra.s	CARRY_ON
NEGATIVE: ;The number was found to be a negative.
	move.b	-(A0),D1	;get next byte. (the byte to fill with)
	sub.b	#128,D0
	and.l	#$FF,D0
NEG:	move.b	D1,-(A1)
	sub.b	#1,D0
	bne.s	NEG
	bra.s	LOOP
END_EXPAND:
	move.w	(sp)+,$FF8240
	bra.s	START

ISR:	movem.l	D0-D7/A0-A6,-(sp)
	bsr	TUNE+$64
	movem.l	(sp)+,D0-D7/A0-A6
	rts
MASK:	dc.w	1	;mask for pixel transfer

START:	lea	MESS,A6
SCROLL:	move.b	(A6)+,D0
	cmp.b	#$FF,D0
	bne.s	OK
	cmp.b	#$FF,(A6)
	beq.s	START
OK:	and.l	#$FF,D0
	sub.b	#32,D0		;rid ourselves of ASCII chains
	mulu	#8,D0		;calc character offset
	lea	FONT,A1
	add.w	D0,A1
	lea	BUFFER,A2
	move.l	(A1)+,(A2)+
	move.l	(A1)+,(A2)+

TEST:	tst.w	SYNC
	bne.s	DEC
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	move.w	#2,SYNC
DEC:	sub.w	#1,SYNC
W_KEY:	move.l	#$600ff,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	D0
	bne.s	WAIT
CONT:	clr.l	D0
	lea	BUFFER,A5
	move.l	SCR_ADD,A0
	add.w	#160*192,A0
	moveq.l	#7,D7
LINES:	move.l	A0,-(sp)
	adda.l	#152,A0
	move.b	(A5),D1
	lsl.b	#1,D1
	move.b	D1,(A5)+
	moveq.l	#20-1,D6	;40 characters across scrn
COLUMN:	move.w	(A0),D1
	roxl.w	#1,D1		;scroll 2 chars at a time
	move.w	D1,(A0)
	move.w	D1,2(A0)
	move.w	D1,4(A0)
	move.w	D1,6(A0)
	subq.l	#8,A0	;move back a byte for next position on scrn
	dbf	D6,COLUMN
	movea.l	(sp)+,A0
	adda.l	#160,A0	;drop down a line
	dbra	D7,LINES
	addq.w	#1,D5
	andi.w	#7,D5	;test the buffer to see if empty?
	bne	TEST
	bra	SCROLL

WAIT:
	clr.l	$4d2		;turn off music
	lea	$FF8800,A0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	move.b	#$2,$484	

	pea	GOSAMPLE
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
PAUSE:	move.w	D0,-(sp)
	move.w	#50,D0
PAU:	nop
	dbra	D0,PAU
	move.w	(Sp)+,D0
	rts
EVEN
SCR_ADD:	dc.L	0
ORG_REZ:	dc.W	0	;Origional rez. store.
SYNC:		DC.W	0	;SYNC for vertical scrn update
	EVEN
GOSAMPLE:	dc.b	27,"Y8 "," P.O.V. INTERNATIONAL RESCUE SOUND DEMO ",0,0
PALETTE: DC.W      $000,$055,$070,$650,$740,$730,$720,$710
	 DC.W	   $700,$712,$014,$735,$513,$505,$770,$777
OLD_PAL:	ds.w	16
ROGER:
MESS:	dc.b	"   WELCOME TO THE P.O.V 'INTERNATIONAL RESCUE' SOUND DEMO."
	dc.b	"   RELEASE DATE  22/4/89 10:30                  "
	dc.b	"               5          4          3          2"
	DC.B	"          1          0          IN A FLASH, TINA AND JO "
	DC.B	"BURST INTO THE WELL-WICKED DURAN DURAN PSYCHEDELIC TORTURE "
	DC.B	"CHAMBER AND SHOOT IT OUT. OFCOURSE, FUZZBOX ARE VICTORIOUS "
	DC.B	"AND ALL FOUR ESCAPE ACROSS THE UNIVERSE IN A GIANT "
	DC.B	"INTERPLANETARY EFFECTS PEDAL...   THREE GALAXIES, A "
	DC.B	"ZILLION LIGHT YEARS AND MANY ZANY ADVENTURES LATER "
	DC.B	"THE FOUR NEAR THE EARTH AND DECIDE TO FORM A POP GROUP "
	DC.B	"AND HAVE ENORMOUSLY HUGE BIG MASSIVE GLOBAL SUCCESS! "
	DC.B	"         WE'VE GOT A FUZZBOX AND WE'RE GONNA USE IT! "
	DC.B	"                        "
	DC.B	"    WOW! P.O.V. HAVE GOT OFF THEIR BACKSIDES (WELL ONE "
	DC.B	"OF THEM HAS!) TO BRING YOU, DIRECT FROM BLACKPOOL, "
	DC.B	"THE FUZZBOX SOUND DEMO.         IF YOU "
	DC.B	"HAVN'T HEARD OF P.O.V. BEFORE THEN LET ME INTRODUCE "
	DC.B	"OUR MERRY BAND...       WELL IT'S MSD ON THE KEYBOARD IN "
	DC.B	"CHARGE OF PROGRAMMING/HACKING AND BASICALLY PUTTING "
	DC.B	"IT ALL TOGETHER, "
	dc.b	"   THERE'S DR.SYNE WHO DOES SOME OF "
	DC.B	"THE ARTWORK/FONTS, DISTRIBUTES OUR DEMOS AND GENERALLY "
	DC.B	"GIVES SUGGESTIONS ON WHAT TO DO NEXT     AND "
	DC.B	"FINALLY THERE'S ALLY "
	DC.B	"HE DOES THE MAIN PICTURES ON OUR DEMOS (WHEN HE'S NOT "
	DC.B	"DOING HIS HOMEWORK!!).                  "
	DC.B	"  RIGHT, "
	DC.B	"NOW FOR THE MOST READ NAMES IN HISTORY, HI TO -"
	DC.B	"     AUTOMATION,    A-HA,   "
	DC.B	"TEX,    BASHER,    BLADERUNNERS (ALL),    THE UNION,    "
	DC.B	"A.B.C MAN,   "
	DC.B	"007,    KAM,    XXX INTERNATIONAL,    THE REPLICANTS,"
	DC.B	"    ROB HUBBARD (FOR THE THUNDERCATS "
	dc.b	"TUNE) AND ALL THE DATA COMM GUYS "
	DC.B	"IN THE WORLD!!!            OH YEH,"
	DC.B	"I SUPPOSE I MUST SAY THANKS TO STEVE C. FOR THE VERY SHORT "
	DC.B	"LOAN OF HIS ST-REPLAY 4!  --  A MESSAGE FROM DR.SYNE, "
	DC.B	"'HI TO ALAN R.'            "
	DC.B	"        WHAT'S ALL THIS TALK ON THE GRAPEVINE ABOUT ROB.C "
	DC.B	"GOING ONTO THE AMIGAAAAAARRRRRGGGHHHH? (YUK!). "
	DC.B	"                              "
	dc.b	"I'M SORRY ABOUT THE NOT TOO PERFECT SAMPLE OF THIS MEGA "
	DC.B	"HIT BUT I SAMPLED IT FROM THE 12 INCH RECORD AT 10KHZ, AND WAS "
	DC.B	"DESPARATELY TRYING TO GET IT FINISHED BEFORE STEVE "
	DC.B	"ARRIVED TO RECLAIM HIS SAMPLER.            "
	DC.B	"WELL THAT'S ALL FOR THIS SCROLLER, WHY DON'T YOU PRESS "
	DC.B	"A KEY AND LOAD THE SAMPLE?                     "
	dc.b	"                                                    "
	DC.B	"       OKAY, DON'T PRESS A KEY AND BE AWKWARD!     "
	dc.b	"                                                   "
	DC.B	"               I WONDER HOW LONG YOU'RE PREPARED TO "
	DC.B	"SIT IN FRONT OF YOUR MONITOR TO READ THIS GARBAGE. "
	dc.b	"                                        "
	DC.B	"                    IMAGINE,  A HOT CUP OF COFFEE!"
	dc.b	"                                        "
	DC.B	"                    A BIG PIZZA!                "
	dc.b	"                                      "
	DC.B	" A COOL PINT OF LAGER! "
	dc.b	"               EH, WHAT?  A PINT OF LAGER..      "
	DC.B	"  RIGHT, YOU WIN, I'M GOING FOR A BEER......      "
	DC.B	"  BYE, BYE.                    "
	DC.B	"                                                       "
	dc.b	"                               "
	DC.B	". . . . .... RIGHT, HAVE THE LAMERS GONE?           "
	DC.B	"               INFO TIME:-  THIS DISC IS FORMATTED "
	DC.B	"TO 80 TRACKS, 9 SECTORS AND IS DOUBLE SIDED. THAT MEANS "
	DC.B	"(FOR THE NON-TECHNICAL MINDED PEOPLE) THAT YOU CAN COPY "
	DC.B	"IT WITH THE DESKTOP COPIER.     THE SAMPLE IN THIS DEMO "
	DC.B	"WAS THE FIRST I MADE (DUE TO PRESSURE FROM STEVE), JUST "
	DC.B	"THINK WHAT THE QUALITY COULD BE LIKE IF I HAVE MORE TIME "
	DC.B	"TO EXPERIMENT....                                 "
	DC.B	"    ANY PLEBS WITH 1/2 MEG OUT THERE CAN NOW RESET THEIR "
	DC.B	"MACHINES, 'COS THIS DEMO IS 1 MEG ONLY (HA,HA,HA), GET "
	DC.B	"YOURSELF AN UPGRADE!!!!                      "
	DC.B	"   BYE (FINALLY) "
	DC.B	"                                 >> >> >> ",$FF,$FF
BUFFER:	ds.w	8
FONT:	ds.b	8
	incbin	'WAS_SET.IMG'
TUNE:	incbin	"T_CATS.IMG"
SCRN:	incbin	"pic.img"
	even
GET_PALETTE:
	move.W	#15,d0
	move.l	#$FF8240,A0
	LEA	OLD_PAL,A2
GET_COL:
	MOVE.W	(A0)+,(A2)+
	dbra	D0,GET_COL
	RTS
SET_PALETTE:
	move.W	#15,d0
	move.l	#$FF8240,A1
set_col:
	MOVE.W	(A0)+,(A1)+
	dbra	D0,set_col
	RTS
GET_BASE:
;	Get screen base address
	MOVE.W	#3,-(SP)
	TRAP	#14
	ADDQ.W	#2,SP
	MOVE.L	D0,SCR_ADD
	rts
GET_REZ:
;	Get rez.	_GETREZ
	MOVE.W	#4,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.W	D0,ORG_REZ	
	rts
SET_REZ:
	MOVE.W	D0,-(SP)	; Set Res.
	MOVE.L	SCR_ADD,D0
	MOVE.L	D0,-(SP)	; PHYSBASE
	MOVE.L	D0,-(SP)	; LOGBASE
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.l	#12,SP
	rts
	even