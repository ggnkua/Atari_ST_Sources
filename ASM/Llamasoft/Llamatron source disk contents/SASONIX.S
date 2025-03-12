; opt habs
; section code
; org $10000

* This is the sample driver. Based on the example code provided
* with Replay but with a lot of hacks to make it faster. The
* main service routine is utterly changed from the original but
* now it only uses two registers.


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
_reverse: dc.w 0
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

oh_goaty: move.l #inull,$120
 bsr init_sample
oh_g2: bsr play_sample
oh_g1: tst.b inuse
 bne oh_g1
 bra oh_g2
 
play_sample:	MOVE.L	CURSRLO,sa_pt	PASS START OF REPLAY
	MOVE.L	CURSRHI,d6	& END
	ST	INUSE		FLAG INTS IN USE
	SF	OPTION		WE ARE NOT SAMPLING
 	tst _reverse		;backsamples
	bne do_revr
	LEA	IREPLAY,A0	SET UP THE ROUTINE
	Bra	SETINT		AND DO IT


do_revr:	LEA	IREPLAYr,A0	SET UP THE ROUTINE
	Bra	SETINT		AND DO IT

cursrlo: dc.l sample
cursrhi: dc.l samend
;sa_pt equ asap+2
init_sample:
 move.l #sample,a0
 move.l #samend,d0
ayyak: move.b (a0),d1
 add.b #$80,d1
; asr.b #1,d1
 move.b d1,(a0)+
 cmp.l a0,d0
 bne ayyak		;prescan sample

isamp: move.w sr,d1
 move d1,-(a7)
 and #%0101100011100000,d1
 or.W #$2700,d1
 move d1,sr
	LEA	INULL,A0
	BSR	SETINT		SET NULL INTERRUPT ADDRESS
;	MOVEQ	#0,D0		SET INITIAL FREQUENCY
;	BSR	SETFREQ
	BSR	ENABMFP		SET THE MFP RUNNING
	BSR	SETSND		SET UP SOUND REGISTERS
	
	SF	XTERNAL		SET THE MODE FOR INTERNAL ATARI USE
	BSR	INTREGS		SET UP INTERNAL REGISTERS
;	MOVE.W	#$3200,SR	ENABLE THE INTERRUPTS
 move (a7)+,d1
 move d1,sr
	rts


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
*       REPLAY FROM MEMORY             *
****************************************

*** As you can see it is self modifying. Turn off cache on a TT
*** to make it work properly.

ireplay: movem.l d0/a0,-(a7) 
	clr d0
asap:	move.b ireplay,d0
sped:	addq.l #1,sa_pt
irep:	lea snd_out(pc),A0
	lsl #3,D0			;DOUBLE LONG WORD OFFSET
	move 4(a0,d0.w),irek+2	;was d4
	move.l	0(a0,D0.W),D0		;GET DATA #1
	lea screg,a0	
	MOVEP.l	D0,0(A0)		;PLAY #1
irek: 	move #0,d0
	MOVEP.W	d0,0(A0)		;PLAY #2
	movem.l (a7)+,d0/a0
	RTE

IREPLAYr: movem.l d0/a0,-(a7) 
	move.l sa_pt(pc),a0
	clr d0
	move.b (a0),d0
	lea -1(a0),a0
 	move.l a0,sa_pt
	bra irep

trp: dc.w 0
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

HALTREP move sr,d0
 move d0,-(a7)
 and #%0101100011100000,d0
 or.W #$2700,d0
 move d0,sr
	LEA	INULL,A0	REMOVE REPLAY INT.
	BSR	SETINT
	SF	INUSE
	move (a7)+,d0
	MOVE.W	d0,SR
	movem.l (a7)+,d0-d1/a0
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
INTOUTP AND.W	#$00FF,D7	MASK OFF RUBBISH
	ADD.B	#$80,D7		COMPLENT VALUE
	LSL.W	#3,D7		DOUBLE LONG WORD OFFSET
	MOVE.L	0(A3,D7.W),D5	GET DATA #1
	MOVE.W	4(A3,D7.W),D4	GET DATA #2
	MOVEP.L	D5,0(A4)	PLAY #1
	MOVEP.W	D4,0(A4)	PLAY #2
	movem.l (a7)+,d0-d7/a0-a6
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
*	CHOOSE INTERRUPT VECTOR         *
*****************************************
*
*   SET UP SELECTED INTERRUPT WITH A0.L
*   CONTAINING THE NEW ROUTINE VECTOR.
*
SETINT 	MOVE.W	SR,D0		SAVE SYSTEM STATUS
	move d0,-(a7)
 and #%0101100011100000,d0
 or.W #$2700,d0
 move d0,sr
;	MOVE.W	#$2700,SR	INTERRUPTS OFF

	MOVE.L	A0,ISRVEC	INSTALL NEW ROUTINE
	move (a7)+,d0
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
SETFREQ 
	MOVE.B	#0,TACR		DISABLE TIMER
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

ENABMFP
	MOVE.B	#$20,IMRA
;	MOVE.B	#0,IMRB		;comment these 2 lines out
	MOVE.B	#$20,IERA	
;	MOVE.B	#0,IERB		;if you are running HBL
	BCLR.B	#3,VECTOR
	RTS

*****************************************
*    SET UP THE SOUND CHIP CHANNELS     *
*****************************************

SETSND 	MOVE.B	#0,SCREG	CHANNEL A
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
;	move.b #$cf,scdata
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

INTREGS MOVE.W	SR,D0
 move d0,-(a7)
 and #%0101100011100000,d0
 or.W #$2700,d0
 move d0,sr
;	MOVE.W	#$2700,SR
	SF	XTERNAL
	LEA.L	INTOUTP,A5	INSTALL OUTPUT ROUTINE
	MOVE.L	#SCREG,A4	SOUND CHIP CNTRL REG
	LEA.L	SND_OUT,A3	LOOK UP TABLES
	MOVEQ	#0,D7
	move (a7)+,d0
	MOVE.W	D0,SR
	RTS

*****************************************
*     SET UP REGISTERS FOR EXTERNAL     *
*****************************************

EXTREGS
	RTS

*
* THE FOLLOWING NOT ALLOWED DURING INTERRUPTS
*
CHKINTS TST.B	INUSE		INTS RUNNING ?
	BNE	DECEXIT		LEAVE NOW IF YES

*	ETC...ETC

DECEXIT	RTS


***********************************
*	BLOCK STORAGE AREA        *
***************************************
*    Internal sound lookup table.     *
***************************************
	EVEN


**************************************
*       MFP/FREQUENCY TABLE          *
************************************** 0506  
	EVEN
FREQTAB dc.w $0507	;REAL slow
	DC.W	$0506	4.9 KHZ
	DC.W	$0505	7.68 KHZ
	DC.W	$0404	9.6 KHZ
	DC.W	$1F01	19.8 KHZ
	DC.W	$0802	30.7 KHZ
	DC.W	$0106	
	DC.W	$0106

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

**************************************
*       START OF REPLAY BUFFER       *
**************************************


sampri: dc.w 0
rsonic:  cmp sampri,d2
 bmi arsse
 move #1,_reverse
 bra osonic
sonic:
;
; pass d0=sample # (SAMTAB holds address and length data)
; and d1=replay speed 0=slowest (v. slow!); d2=priority (0 low)

; cmp #30,d0
; bne fix1m
; move #32,d0
fix1m: cmp sampri,d2
 bmi arsse
 move #0,_reverse
osonic:
; move #0,sampri
; rts

; sub #1,d1
; bpl fix1mo	;only for halfmeg
; move #0,d1
fix1mo: tst sonon
 bne arsse
 move d2,sampri
; cmp #18,d0
; bne oso1
; move #15,d0
oso1: lea samtab,a0
 asl #3,d0
 move.l 0(a0,d0.w),d2
 asr.l #1,d2		;1 for 1meg
 add.l #sample,d2
 tst _reverse
 bne izzrev
 move.l d2,cursrlo 
 move.l 4(a0,d0.w),d0
 asr.l #1,d0		;1 for 1meg
 add.l d0,d2
 move.l d2,cursrhi
izzia: move.b #$52,sped	;default spd. =1 (52 for 1meg)
 move d1,d0
 cmp #5,d0	;3 for 1meg
 blt izzia2			;means is speed 0 or 1, leave it
 move #1,d1	;1 for 1meg
 sub #1,d0		;1 for 1meg (2)
 asl #1,d0
 or.b #$50,d0		;make the addQ.l
 and.b #$5e,d0
 move.b d0,sped
izzia2: move d1,d0
 jsr setfreq
 jmp play_sample
izzrev: move.l d2,cursrhi
 move.l 4(a0,d0.w),d0
 asr.l #1,d0	;#1 for 1meg
 add.l d0,d2
 move.l d2,cursrlo
 bra izzia
arsse: rts


samtab: 
;
;table of samples: asddress, then length

 dc.l 0,10602
 dc.l 11160,1116
 dc.l 12276,5580
 dc.l 17856,3069
 dc.l 20646,1953
 dc.l 22599,8091
 dc.l 30690,12555
 dc.l 43245,9207
 dc.l 52452,8928
 dc.l 61380,2511
 dc.l 63891,3906	;10
 dc.l 67797,3627
 dc.l 71424,2232
 dc.l 73656,1116
 dc.l 75051,1116
 dc.l 76167,6417
 dc.l 82584,10044
 dc.l 92628,21483
 dc.l 114111,10323
 dc.l 124434,7812
 dc.l 132246,20367	;20
 dc.l 152613,12276
 dc.l 164840,43058
 dc.l 82676*2,6329*2	;baaa
 dc.l 103628*2,4788*2
 dc.l 89037*2,9589*2	;25 ohyeah
 dc.l 99118*2,4510*2	;ooOOoo
 dc.l 103628*2,4788*2	;'mooOOoo'
 dc.l 108383*2,7703*2	;'i love u'
 dc.l 116056*2,10679*2	;'oh f*ck'
 dc.l 126639*2,30270*2	;'aaaaagghh'	30
 dc.l 120297*2,6435*2	;'f*ck'
 dc.l 116113*2,4155*2	;oh

sa_pt equ asap+2

sample: incbin f:\sonix2.spl
	even
samend: dc.w 0

