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

;Size the job and free back to GEM unused memory.
	move.l	A7,A5
	move.l	4(A5),A5	;get basepage
	move.l	$C(A5),D0	;text segment
	add.l	$14(A5),D0	;data segment
	add.l	$1C(A5),D0	;unitialized
	add.l	#$100,D0	;basepage size
M_SHRINK:
	move.l	D0,-(sp)
	move.l	A5,-(sp)
	move.w	D0,-(sp)
	move.w	#$4A,-(sp)
	trap	#1
	add.l	#12,sp		;okay that's it memory free & allocated
	bra	SKIP_TEXT
	dc.b	"Hello nosey, this was written by MAC SYS DATA of P.O.V. "
	dc.b	" If you want any of the routines from this intro then "
	dc.b	"get in touch via the Blackpool club.      "
SKIP_TEXT:
	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)	;GOTO SUPERVISOR
	TRAP	#1
	ADDQ.L	#6,A7
	MOVE.L	D0,OLD_STACK

	dc.w	init	;INITIALISE A_LINE ROUTINES
	dc.w	hide_m	;hide mouse
;depack FONT
	lea 	TUNE(pc),a0	;end of compressed code
	sub.l	#4,a0		;include for POV & LSD packer.
	lea 	$20000,a1	;destination
	bsr 	depak
;depack TUNE
	lea 	PIC(pc),a0	;end of compressed code
	sub.l	#4,a0		;include for POV & LSD packer.
	lea 	$30000,a1	;destination
	bsr 	depak
;depack PIC
	lea 	SET_PALETTE(pc),a0	;end of compressed code
	sub.l	#4,a0		;include for POV & LSD packer.
	lea 	$40000,a1		;destination
	bsr 	depak

	bsr	MENU

;	clr.w	-(sp)
;	move.w	#$4c,-(sp)
;	trap	#1

	lea	F_NAME,a0
	bsr	F_OPEN	
	lea	ROGER,A1
	move.l	A1,F_START
	move.l	#471828,LENGTH
	bsr	F_LOAD
	bsr	F_CLOSE

	move.w	#12,D1
top:	clr.w	D0
nop:	sub.w	#1,D0
	bne.s	nop
	dbra	D1,top


	lea	ROGER,A5
	move.l	#471828,D5
	move.l	#2,D4
	bsr	REPLAY

REPEAT:	lea	ROGER+14148,A5
	MOVE.L	#457680,D5	;D5 CONTAINS LENGTH OF SAMPLE
	MOVE.L	#2,D4		;D4 CONTAINS PLAYBACK SPEED
	bsr	REPLAY

	lea	ROGER+28523,a5
	move.l	#42621-28523,d5
	move.l	#2,d4
	bsr	REPLAY

	move.w	#2-1,d0
loop:	move.w	d0,-(sp)
	lea	ROGER+28523,a5
	move.l	#35551-28523,d5
	move.l	#2,d4
	bsr	REPLAY
	move.w	(sp)+,d0
	dbra	d0,loop

	lea	ROGER+28523,a5
	move.l	#32051-28523,d5
	move.l	#2,d4
	bsr	REPLAY

	lea	ROGER+28523,a5
	move.l	#471828-28523,d5
	move.l	#2,d4
	bsr	REPLAY

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
F_START:	dc.l	0	;Start address to LOAD at.
LENGTH:		dc.l	0	;Number of bytes to LOAD.
HANDLE:		dc.l	0
F_NAME:		DC.B	'a:\UR_THE_1.AHA'
		DC.B	0
	even
OLD_STACK:	DC.L	1	; SUPER BASIC STACK
MFPMEM:	ds.b	8	; SAVED MFP DATA
INUSE:	dc.b	1	; INTERRUPT IN-USE FLAG
	even

MENU:	jsr	GET_BASE
	jSR	GET_REZ
	lea	$40002,A0
	jSR	SET_PALETTE
	move.w	#0,D0
	jsr	SET_REZ

;************************************************************************
;*                           CUSTODIAN                                  *
;*                           ---------                                  *
;* Stolen by: MAC SYS DATA of P.O.V. 27/06/89 23:15                     *
;*      From: AUTOMATION disc 97                                        *
;* Include files:-                                                      *
;*                 CUST.DAT                                             *
;************************************************************************

	clr.b	$484
	move.l	#ISR,$4d2		;use VBL to play tune

;****************************************************************
; There is more than one tune in this code....
; 0=AUTOMATION disc 97 - CUSTODIAN main tune
; 1=intro score table
; 2=title screen
; 3=enter name on high score.
; 4=Jingle
; 5=Jingle
	move.l	#0,D0
	jSR	$30000+$6ca

	move.w	#$FFFF,d0
stop:	nop
	sub.w	#1,d0
	bne.s	stop

	bsr	TRANSFER

START:	lea	MESS,A6
SCROLL:	move.b	(A6)+,D0
	cmp.b	#$FF,D0
	bne.s	OK
	cmp.b	#$FF,(A6)
	beq.s	START
OK:	and.l	#$FF,D0
	sub.b	#32,D0		;rid ourselves of ASCII chains
	mulu	#8,D0		;calc character offset
	lea	$20000,A1
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
	add.w	#160*190,A0
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

WAIT:	clr.l	$4d2		;turn off music
	lea	$FF8800,A0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	move.b	#$2,$484	

	move.l	SCR_ADD,a0	;clear scrolling text area.
	add.l	#160*190,a0
	move.w	#9*160/4-1,d0
clr_row:
	clr.l	(a0)+
	dbra	d0,clr_row
	pea	GOSAMPLE	;print message to bimbos
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts			;return to main to load sample.
ISR:	movem.l	d0-d7/a0-a6,-(sp)
	jsr	$30000+$7f2
	movem.l	(sp)+,d0-d7/a0-a6
	rts
SCR_ADD:	dc.l	0
ORG_REZ:	dc.w	0	;Origional rez. store.
SYNC:		dc.w	0	;SYNC for vertical scrn update
GOSAMPLE:	dc.b	27,"Y8 ","   P.O.V. 'YOU ARE THE ONE' SOUND DEMO  ",0,0
ROGER:
;	screen transfer, pixelly from left to right
TRANSFER
	lea	$40022,A0
	move.l	SCR_ADD,A1
	move.w	#19,D0		;counter words across
pixels:
	move.w	#%1000000000000000,MASK
	move.w	#15,D1		;16 bits in word
bits:	move.l	D1,-(sp)	;****
	move.w	#199,D1
down:	move.l	D1,-(sp)
	move.w	#4-1,D1
again:	move.w	(a0)+,D6
	and.w	MASK,D6
	move.w	D6,(A1)+
	dbra	d1,again
	move.l	(sp)+,D1
	add.w	#152,A1
	add.w	#152,A0
	dbra	d1,down
	sub.w	#31992,A1
	sub.w	#31992,A0
	move.w	MASK,D6
	LSR	#1,D6
	add.w	#%1000000000000000,D6
	move.w	D6,MASK
	sub.w	#8,A0
	sub.w	#8,A1
	move.l	(sp)+,D1
	dbra	d1,bits
	add.w	#8,A0
	add.w	#8,A1
	dbra	d0,pixels
	rts
MASK:	dc.w	0	;mask for pixel transfer
MESS:	dc.b	"   WELCOME TO THE P.O.V. 'YOU ARE THE ONE' SOUND DEMO."
	dc.b	"        RELEASE DATE  11/07/89 18:09                  "
	DC.B	"                      WELL HERE WE ARE AGAIN, AS PROMISED "
	DC.B	"THE A-HA SAMPLED SOUND DEMO. "
	DC.B	"                    THE DEMO WAS PROGRAMMED BY M.S.D.,   THE A-HA "
	dc.b	"LOGO WAS DRAWN BY ALY.                                     "
	dc.b	"THIS DISC IS THE 5TH DISC IN OUR COLLECTION, IF YOU MISSED THE FIRST FOUR "
	dc.b	"THEN TOUGH, GO ASK YOUR MATES IF THEY'VE GOT 'EM. "
	dc.b	"                        THE TUNE IS FROM CUSTODIAN, ORIGINALLY "
	dc.b	"STOLEN BY NIEL OF COR BLIMEY, THEN BY M.S.D. OFF AUTOMATION DISC 97. "
	dc.b	"                            "
	dc.b	"       THE DOOZY FONT WAS STOLEN FROM SAVAGE BY M.S.D. ( WELL IT MAKES A "
	DC.B	"CHANGE FROM THE ONE I STOLE FROM AUTOMATION!!!! )                                  "
	DC.B	"                    WELL, HERE'S THE BIT YOU'VE ALL BEEN WAITING FOR, THE GREETINGS, "
	DC.B	"       HI TO - "
	DC.B	"     NIEL OF COR BLIMEY,     AUTOMATION,     "
	DC.B	"BASHER,     RUSS,     ALAN R.     AND     DR.SYNE.                         "
	DC.B	"WHEN YOU COPY THIS DISC, PLEASE COPY IT 80 TRACKS, 9 SECTORS, DOUBLE SIDED "
	DC.B	"AND UN-PROTECTED.            IF YOU HAVE TO PUT THE COPIER ON PROTECT THEN THE DISC "
	DC.B	"IS CORRUPTED.           I DON'T WANT TO SEE THIS DEMO ON "
	DC.B	"A STUPID FORMAT THAT'S ONLY FIT FOR THE AMIGA TRASH!                                 "
	DC.B	"                           "
	DC.B	"                     ........ THE ADVERTISEMENT SECTION ........         "
	DC.B	"                   WE STILL HAVE ( STACKED ON MY TV ), THE 'IVOR BIGGUN' SAMPLE, WAITING "
	DC.B	"FOR THE GRAFIX FROM ALY.      AS SOON AS I GET THE PICCY, I'LL CODE THE DEMO UP - IT'S GOING "
	DC.B	"TO BE A BIGGY, OO-ER!                       "
	DC.B	"IF SOMEONE WILL LEND US THEIR SAMPLER, WE'LL DO A FEW MORE SAMPLED DEMOS "
	DC.B	"(ARE YOU GETTING THE HINT STEVE????),  OTHERWISE WE MAY HAVE TO WRITE A GRAFIX DEMO WITH "
	DC.B	"LOADS OF COLOURS AND THAT SOUNDS LIKE TOO MUCH HARD WORK).                                         "
	DC.B	"           AT THE MOMENT P.O.V. CONSISTS OF                    MAC SYS DATA, "
	DC.B	"                  ALY                  AND                  DR.SYNE.                    "
	DC.B	"         UNFORTUNATELY, DR.SYNE IS A LITTLE BUSY AT THE MOMENT BUT I HOPE HE'LL BE FREE SOON "
	DC.B	"TO GET US SOME DEMOS FOR US TO IMPROVE OR STICK ON A MENU.                                   "
	DC.B	"                   "
	DC.B	"........ THE TECHNO SECTION ........                    "
	DC.B	"THE SAMPLE RATE FOR THIS DEMO WAS 10KHZ AND WAS SAMPLED BY MAC SYS DATA FROM "
	DC.B	"THE CD.                        THE HARDWARE USED WAS PRO-SOUND,   THE SOFTWARE WAS A MIXTURE OF ST-REPLAY 3 "
	DC.B	"AND ST-REPLAY 4.                                   "
	DC.B	"    THE DEMO WAS PUT TOGETHER MAINLY OVER TWO EVENINGS, WITH THE FINAL TOUCHES "
	DC.B	"BEING DONE OVER ANOTHER TWO NIGHTS.                          "
	DC.B	"   THAT'S ABOUT IT FOR THIS ONE, LOOK OUT FOR THE ALY INTRO COMING SOON!      "
	DC.B	"      BYE, BYE - TAKE CARE.    MAC SYS DATA  11/7/89  18:09 "
	DC.B	"                                                                      "
	DC.B	"                 >> >> >> ",$FF,$FF
BUFFER:	ds.w	8
FONT:	incbin	'SAVAGE.COM'
TUNE:	incbin	"CUST.COM"
PIC:	incbin	"A_HA.COM"
SET_PALETTE:
	move.W	#15,d0
	move.l	#$FF8240,A1
set_col:
	MOVE.W	(A0)+,(A1)+
	dbra	D0,set_col
	RTS
GET_BASE:
	MOVE.W	#3,-(SP)	;Get screen base address
	TRAP	#14
	ADDQ.W	#2,SP
	MOVE.L	D0,SCR_ADD
	rts
GET_REZ:
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
depak:	move.w	$ff8240,-(sp)
	move.l	-(a0),d1
	move.l	-(a0),d5
	move.l 	a1,a2
	adda.l 	d1,a2
	move.l 	-(a0),d0
	eor.l 	d0,d5
l1:	lsr.l 	#1,d0
	bne.s 	l2
	bsr 	l16
l2:	bcs.s 	l9
	moveq 	#8,d1
	moveq 	#1,d3
	lsr.l 	#1,d0
	bne.s 	l3
	bsr 	l16
l3:	bcs.s 	l11
	moveq 	#3,d1
	clr.w 	d4
l4:	bsr 	l17
	move.w 	d2,d3
	add.w 	d4,d3
l5:	moveq 	#7,d1
l6:	lsr.l 	#1,d0
	bne.s 	l7
	bsr 	l16
l7:	roxl.l 	#1,d2
	dbf 	d1,l6
	move.b 	d2,-(a2)
	dbf 	d3,l5
	bra.s 	l13
l8:	moveq 	#8,d1
	moveq 	#8,d4
	bra.s 	l4
l9:	moveq 	#2,d1
	bsr 	l17
	cmpi.b 	#2,d2
	blt.s 	l10
	cmpi.b 	#3,d2
	beq.s 	l8
	moveq 	#8,d1
	bsr.s 	l17
	move.w 	d2,d3
	move.w 	#12,d1
	bra.s 	l11
l10:	move.w 	#9,d1
	add.w 	d2,d1
	addq.w 	#2,d2
	move.w 	d2,d3
l11:	bsr.s 	l17
l12:	subq.w 	#1,a2
	move.b 	0(a2,d2.w),(a2)
	dbf 	d3,l12
l13:	move.w	d0,$ff8240
	cmpa.l 	a2,a1
	blt 	l1
	tst.l 	d5
	bne.s 	l14
fin	move.w	(sp)+,$ff8240
	rts
l14:	nop
l15:	moveq 	#1,d0
	rts
l16:	move.l 	-(a0),d0
	eor.l 	d0,d5
	move.b 	#$10,ccr
	roxr.l 	#1,d0
	rts
l17:	subq.w 	#1,d1
	clr.w	 d2
l18:	lsr.l 	#1,d0
	bne.s	 l19
	move.l 	-(a0),d0
	eor.l 	d0,d5
	move.w	d0,$ff8240
	move.b 	#$10,ccr
	roxr.l 	#1,d0
l19:	roxl.l 	#1,d2
	dbf 	d1,l18
	rts


