*************************************************************************
*				ADRENALIN MENU ??			*
*									*
* CODING:MOTIV								*
* ART:????????								*
* MUSIC:??????								*
*									*
* Tidying up and NOT optimising by MSD (I got bored)			*
* MSD code is in lowercase so MOTIV will hate it (Highercase freak!!!)	*
*									*
* THIS CODE WILL DISPLAY TWO PICTURES ONE WHICH IS FADED OUT TO BRING	*
* ON THE NEXT. THE SECOND PICTURE IS ACCOMPANIED BY A RASTER SCROLL AND	*
* MUSIC.								*
*									*
* V 2									*
* RELEASED:								*
*									*
*									*
*************************************************************************
*
* Guidelines by MSD.....
*
* 1) ALWAYS clear the BSS as packers don't
*
* 2) ALWAYS define your screen areas in the BSS so you can see the
*    actual size of your code.
*    Also note that it only takes fractionally longer to assemble if
*    you do define the screen space in the BSS but it will help you
*    to find why the menu crashes on 512K machines!
*
* 3) Don't use any label called TEXT as MONST takes it as the TEXT segment
*
* 4) DBF instr only uses WORD so don't waste time with MOVE.L
*
*

		opt o+,w-

KEYS:
FROM		EQU 	1	;WHAT MENU CHOICES
TO		EQU	3	;TO USE FROM KEYS '1' TO '3'

YES		EQU	1
NO		EQU	0

FINAL		EQU	NO	;IS IT THE FINAL VERSION
				;IF NO SPACE TO EXIT

COLOUR0		EQU	$909	;DARK BLUE


		clr.l	-(sp)
		MOVE.W	#$20,-(SP)
		TRAP	#1			;SUPER MODE
		ADDQ.L	#6,SP
		MOVE.L	D0,OLD_USP		;SAVE USP
		
		BSR	SET_UP			;INITIALISE SYSTEM
		BSR	INIT			;SET UP SCREENS
		BSR	SAVE_INTS		;SAVE INTERUPTS
		BSR	SET_INTS1		;SET UP NEW INTERUPTS
		BSR	TEXT_FORM
		MOVE.B	#2,WHAT_HZ	
		MOVE.B	#2,$FFFF820A.W
		BSR 	CLS	
		MOVEM.L BLANK,D0-7
		MOVEM.L D0-7,$FFFF8240.w
		MOVEM.L D0-7,NEW_PAL
**************************
* DISPLAY ADRENALIN LOGO *		
**************************

MAIN1
		
		
*************
*MAIN SCREEN*
*************		
		BSR	INIT_MUS

INTRO:
		BSR	WAIT_SYNC		;WAIT FOR VBL
		
		BSR	PLAY_MUS
		
		MOVE.B 	W_LINE,D0
		SUB.B 	#1,D0
		CMP.B 	#50,D0
		BEQ	NOT_YET
		MOVE.B	D0,W_LINE
		BRA	INTRO
NOT_YET		BSR	DISPLAY_PIC1
		lea	BLANK,a0
		lea	PIC1+2,A1
		BSR	FADEIN
		move.w	#$1F,D7
.WAITING	BSR	WAIT_SYNC
		MOVE.L	D7,-(SP)
		BSR	PLAY_MUS
		MOVE.L	(SP)+,D7
		DBF	D7,.WAITING
INTRO2		BSR WAIT_SYNC
		BSR PLAY_MUS
		MOVE.B 	W_LINE,D0
		SUB.B 	#1,D0
		CMP.B 	#1,D0
		BEQ	GET_READY
		MOVE.B	D0,W_LINE
		BRA INTRO2

GET_READY:	BSR SET_INTS2		

MAIN		BSR	WAIT_SYNC		;WAIT FOR VBL
;	move.w	#$070,$ffff8240.w
		BSR	PLAY_MUS
		BSR 	BEAM_MOVE
		BSR	BARS
;	clr.w	$ffff8240.w

		move.w	#$3FF,D7
.LIP		DBF D7,.LIP
		BSR	SCROLL_IT
		
		MOVE.B 	W_LINE,D0
		SUB.B 	#1,D0
		CMP.B 	#1,D0
		BEQ	NOTY
		MOVE.B	D0,W_LINE
		
NOTY		CLR.L	D0
		MOVE.B	$FFFFFC02.W,D0
		SUB.B	#1,D0
		CMP.B	#TO,D0
		BGT	NO_KEY
		CMP.B	#FROM,D0
		BLT	NO_KEY
		SUB.B	#1,D0
		LSL.B	#2,D0
		lea	CHOICES,A0
		MOVE.L	(A0,D0.W),A0
		MOVEM.W	(A0),D0-7
		MOVEM.w	D0-7,$200.w
		BRA	LOAD_IT

NO_KEY		tst.w	HZ_TEST
		BNE	NEXT
		CMP.B	#10,D0
		BEQ	HZ
NEXT		
		IFEQ	FINAL
		CMP.B	#$38,D0		;I SUBTRACT ONE FROM ABOVE SO SPACE NOW=$38
		BEQ	LOAD_IT		;JUST THE QUITING PART NOT ACTUALL LOADING
		ENDC
		SUB.W	#1,HZ_TEST
		CMP.W	#0,HZ_TEST
		BGT	MAIN
		MOVE.W	#0,HZ_TEST
		BRA	MAIN		;IF NO SPACE CONTINUE LOOP		
HZ		MOVE.W	#20,HZ_TEST
		CMP.B	D0,D1
		BEQ	MAIN
		EOR.B	#2,WHAT_HZ
		EOR.W	#001,NEW_PAL
		BRA	MAIN
LOAD_IT		
		
		MOVE.W	#$000,BEAM+68
		MOVE.L	#45,D7
.LOOP2		MOVE.L	#34-1,D6
		lea	BEAM,A0
		BSR WAIT_SYNC
		MOVEM.L D0-7/A0-6,-(SP)
		BSR PLAY_MUS
		MOVEM.L (SP)+,D0-7/A0-6
.LOOP1		MOVE.W 2(A0),(A0)+
		DBF D6,.LOOP1
		DBF D7,.LOOP2
		
		BSR SET_INTS1
		MOVE.L #BLANK,A1
		BSR FADEIN
		BSR WAIT_SYNC
		BSR CLS
		BSR PLAY_MUS

INTRO3		BSR WAIT_SYNC
		BSR PLAY_MUS
		MOVE.B 	W_LINE,D0
		ADD.B 	#1,D0
		CMP.B 	#99,D0
		BEQ	GONE
		MOVE.B	D0,W_LINE
		BRA INTRO3

GONE		BSR	STOP_MUS
		BSR	WAIT_SYNC
		MOVE.B	WHAT_HZ,$FFFF820A.W

******************
*END OF MAIN CODE*
******************


END		BSR FLUSH	
		BSR	REST_INTS
		BSR	ENDING		;RESTORE MAIN SYSTEM
		MOVE.L	OLD_USP,-(SP)
		MOVE.W	#$20,-(SP)	;USER MODE
		TRAP	#1
		ADDQ.L #6,SP
		
fin		CLR.W	-(SP)
		TRAP	#1		;QUIT
		


**************************
* MY SUBROUTINES GO HERE *
**************************

INIT_MUS:
		MOVE.W	#1,D0
		JSR	MUSIC
		RTS
PLAY_MUS:
		JSR	MUSIC+8
		RTS
		
STOP_MUS:	
		MOVE.L	#$08080000,$FF8800		clear vol. chan A
		MOVE.L	#$09090000,$FF8800		clear vol. chan B
		MOVE.L	#$0A0A0000,$FF8800		clear vol. chan C
			
		RTS
		
FLUSH:
		BTST.B	#0,$FFFFFC00.W
		BEQ ALL_OK
		MOVE.B $FFFFFC02.W,D0
		BRA.S FLUSH
ALL_OK		RTS

********* very nice fade routine taken DIRECTLY from MSD/POV source code!!!!	
;A0=SOURCE PALETTE 	A1=TARGET PALETTE
FADEIN	MOVE #7,D6
	MOVE.L A1,A2
FADEIN1	LEA	PALREG,A0
	MOVE #14,D7
	ADDQ #2,A0
	ADDQ #2,A1
FADEIN2	BSR	MODIFY
	ADDQ #2,A0
	ADDQ #2,A1
	DBRA D7,FADEIN2
	move.w	#6,D0	;speed at which it fades
	BSR	WAIT
	MOVE.L A2,A1
	DBRA D6,FADEIN1
	RTS

WAIT	BSR.S owvbl
	DBRA D0,WAIT
	RTS

owvbl	
	MOVEM.L D0-7/A0-6,-(SP)
	BSR WAIT_SYNC
	BSR PLAY_MUS
	MOVEM.L (SP)+,D0-7/A0-6
	RTS
	
PALREG	EQU $FF8240


MODIFY	MOVE (A0),D0 ;PALREG
	MOVE (A1),D1 ;TARGET
	MOVE D0,D4 ;NEW COL
	MOVE D0,D2
	MOVE D1,D3
	AND #$7,D2
	AND #$7,D3
	CMP D2,D3
	BEQ.S MOK1
	BMI.S MDN1
	ADDQ #1,D4
	BRA.S MOK1
MDN1	SUBQ #1,D4
MOK1	MOVE D0,D2
	MOVE D1,D3
	AND #$70,D2
	AND #$70,D3
	CMP D2,D3
	BEQ.S MOK2
	BMI.S MDN2
	ADD #$10,D4
	BRA.S MOK2
MDN2	SUB #$10,D4
MOK2	MOVE D0,D2
	MOVE D1,D3
	AND #$700,D2
	AND #$700,D3
	CMP D2,D3
	BEQ.S MOK3
	BMI.S MDN3
	ADD #$100,D4
	BRA.S MOK3
MDN3	SUB #$100,D4
MOK3	MOVE D4,(A0)
	RTS

SCROLL_IT:
		tst.w	STOPER
		BEQ FINE
		SUB.W #1,STOPER
		RTS
FINE		CMP.W #1,SPEED_TST
		BNE FAST
		CMP.B #2,SPEED
		BEQ MAKE_1
		MOVE.B #2,SPEED
		BRA FAST
MAKE_1		MOVE.B #1,SPEED
		RTS
FAST		ADD.W #1,SCROLL_TEST
		CMP.W #6,SCROLL_TEST
		BNE SCROLL_BUF
		MOVE.W #0,SCROLL_TEST
		
		BSR GET_LET
		
		MULU.W #5*15*2,D1
		lea	FONT,A1
		ADD.W D1,A1
		lea	CHR_BUF,A2
		MOVE.w #15-1,D6
.LOOP2		MOVE.w #5-1,D7
.LOOP1		MOVE.W (A1)+,D2
		AND.W COL_SET,D2
		MOVE.W D2,12(A2)
		MOVE.W D2,(A2)+
		DBF D7,.LOOP1
		LEA 14(A2),A2
		DBF D6,.LOOP2
			
SCROLL_BUF	lea	SCR_BUF,A0
		lea	CHR_BUF,A1
		MOVE.w #26,D6
.LOOP2		MOVE.w #32,D7
.LOOP1		MOVE.W 2(A0),(A0)+
		DBF D7,.LOOP1
		MOVE.w (A1),(A0)+
		MOVE.w 2(A1),(A1)+
		MOVE.w 2(A1),(A1)+
		MOVE.w 2(A1),(A1)+
		MOVE.w 2(A1),(A1)+
		MOVE.w 2(A1),(A1)+
		ADDQ.L #2,A1
		DBF D6,.LOOP2
		RTS
		
GET_LET		MOVE.W W_I_T,D0
		lea	ascii,A0
		ADD.W #1,W_I_T
		CLR.L D1
		MOVE.B (A0,D0.W),D1
		CMP.B #'$',D1
		BEQ COLOR_CHG
		CMP.B #$FF,D1
		BNE OK
		CLR.W W_I_T
		CLR.L D1
		BRA GET_LET
OK		RTS
COLOR_CHG	ADD.W #1,W_I_T
		MOVE.B 1(A0,D0.W),D1
		CMP.B #'1',D1
		BNE NEXT1
		MOVE.W #%1111111111110000,COL_SET
		bra	GET_LET
NEXT1		CMP.B #'2',D1
		BNE NEXT2
		MOVE.W #%1111111100001111,COL_SET
		bra	GET_LET
NEXT2		CMP.B #'3',D1
		BNE NEXT3
		MOVE.W #%1111000011111111,COL_SET
		bra	GET_LET
NEXT3		CMP.B #'4',D1
		BNE NEXT4
		MOVE.W #%1111111100000000,COL_SET
		bra	GET_LET
NEXT4		CMP.B #'5',D1
		BNE NEXT5
		MOVE.W #%1111000011110000,COL_SET
		bra	GET_LET
NEXT5		CMP.B #'6',D1
		BNE NEXT6
		MOVE.W #%1111000000001111,COL_SET
		bra	GET_LET
NEXT6		CMP.B #'6',D1
		BNE NEXT7
		MOVE.W #%1111111111111111,COL_SET
		bra	GET_LET
NEXT7		CMP.B	#'0',D1
		BNE	NEXT8
		EOR.W	#1,SPEED_TST
		bra	GET_LET
NEXT8		MOVE.W	#$77,STOPER
		bra	GET_LET
		
TEXT_FORM
		lea	ascii,A0		;CONVERTS THE ASCII
		BSR	UPPER			;TEXT 
		MOVE.L  #ORDER,A0		
		BSR  	UPPER			
		lea	ascii,A0
		MOVE.L  #0,D4
CSTART		MOVE.L  #0,D0
		ADDQ.L	#1,D4
		MOVE.L  #ORDER,A1
		CMP.B   #$FF,(A0)
		BEQ	CEND
CNEXT2		MOVE.B  (A0),D2
CNEXT		MOVE.B	(A1),D1
        	CMP.B #'$',D2
        	BEQ LEAVE
        	CMP.B   D1,D2
		BEQ	CAGAIN
		CMP.B   #$FF,(A1)+
		BEQ	NOT
		ADDQ.L  #1,D0
		BRA     CNEXT
CAGAIN  	MOVE.B  D0,(A0)+
		BRA	CSTART
NOT		MOVE.B	#0,(A0)+	;LOCATION OF SPACE (0 = IST POS)
		BRA	CSTART		;		  (1=SECOND)
LEAVE		ADD.L #2,A0
		BRA CNEXT2
CEND		MOVE.L  D0,COUNT
		RTS

UPPER		CMP.B	#'A',(A0)		;ALTERS LOWER TO UPPER
		BLT	UAGAIN			;LETTERS
		CMP.B   #'Z',(A0)
		BGT	UAGAIN
		ADD.B   #32,(A0)
UAGAIN  	ADDQ.L  #1,A0
		CMP.B	#$FF,(A0)
		BNE	UPPER
		RTS



INIT		MOVE.L	#SCREENS,D0
		CLR.B	D0
		MOVE.L	D0,SCREEN1
		move.l	d0,d1
		ADD.L	#160*248,D0
		MOVE.L	D0,SCREEN2

		move.l	d1,d0		
		LSR.L #8,D0
		MOVE.B D0,$FFFF8203.W	;TELL VIDEO CHIP WHERE 
		LSR.L #8,D0		;NEW SCREEN IS LOCATED
		MOVE.B D0,$FFFF8201.W
		RTS
		
CLS		MOVE.L SCREEN1,A0
		MOVE.L SCREEN2,A1
		MOVE.w #2000-1,D7
.LOOP1		CLR.L (A0)+
		CLR.L (A1)+
		CLR.L (A0)+
		CLR.L (A1)+
		CLR.L (A0)+
		CLR.L (A1)+
		CLR.L (A0)+
		CLR.L (A1)+
		DBF D7,.LOOP1
		RTS

BARS		;shit hot fast VU bars by MSD
		lea	$ffff8800.w,a5
		moveq	#0,d6
		moveq	#-1,d7

		move.l	SCREEN1,a6

		lea	160*196(a6),a0
		move.b	#8,(a5)
		move.b	(a5),d0
		and.w	#%1111,d0
		lsl.w	#2,d0
		move.w	#64,d1
		sub.w	d0,d1
.chan_a_draw	move.w	d7,(a0)
		move.w	d7,8(a0)
		move.w	d7,16(a0)
		move.w	d7,24(a0)
		lea	-320(a0),a0
		dbf	d0,.chan_a_draw
.chan_a_clear	move.w	d6,(A0)
		move.w	d6,8(A0)
		move.w	d6,16(A0)
		move.w	d6,24(A0)
		lea	-320(a0),a0
		dbf	d1,.chan_a_clear
		
		lea	160*196+64+2(a6),a0
		move.b	#9,(a5)
		move.b	(a5),d0
		and.w	#%1111,d0
		lsl.w	#2,d0
		move.w	#64,d1
		sub.w	d0,d1
.chan_b_draw	move.w	d7,(a0)
		move.w	d7,8(A0)
		move.w	d7,16(A0)
		move.w	d7,24(A0)
		lea	-320(a0),a0
		dbf	d0,.chan_b_draw
.chan_b_clear	move.w	d6,(a0)
		move.w	d6,8(a0)
		move.w	d6,16(a0)
		move.w	d6,24(a0)
		lea	-320(a0),a0
		dbf	d1,.chan_b_clear
		
		lea	160*196+128+4(a6),a0
		move.b	#$a,(a5)
		move.b	(a5),d0
		and.w	#%1111,d0
		lsl.w	#2,d0
		move.w	#64,d1
		sub.w	d0,d1
.chan_c_draw	move.w	d7,(a0)
		move.w	d7,8(a0)
		move.w	d7,16(a0)
		move.w	d7,24(a0)
		lea	-320(a0),a0
		dbf	d0,.chan_c_draw
.chan_c_clear	move.w	d6,(a0)
		move.w	d6,8(a0)
		move.w	d6,16(a0)
		move.w	d6,24(a0)
		lea	-320(a0),a0
		dbf	d1,.chan_c_clear
		rts
		


WAIT_SYNC	ST.B	VBL_TEST
.WAIT		TST.B	VBL_TEST
		BNE	.WAIT
		RTS
		


SET_UP		MOVE.W	#$2,-(SP)
		TRAP	#14
		ADDQ.L	#2,SP
		MOVE.L	D0,PHYS		;SAVE OLD PHYSICAL SCREEN
		
		MOVE.W	#$3,-(SP)
		TRAP	#14
		ADDQ.L	#2,SP
		MOVE.L	D0,LOGI		;SAVE OLD LOGICAL SCREEN
		
		MOVE.W	#$4,-(SP)
		TRAP	#14
		ADDQ.L	#2,SP
		MOVE.W	D0,RES		;SAVE OLD RES
		
		MOVE.W	#0,-(SP)
		MOVE.L	#-1,-(SP)	;CLS
		MOVE.L	#-1,-(SP)
		MOVE.W	#$5,-(SP)
		TRAP	#14
		LEA	12(SP),SP
		
		MOVEM.L	$FFFF8240,D0-7
		MOVEM.L	D0-7,OLD_PAL
		MOVEM.L	NEW_PAL,D0-7
		MOVEM.L	D0-7,$FFFF8240
		RTS
		
ENDING:
		MOVE.W	RES,-(SP)
		MOVE.L	PHYS,-(SP)	;REPLACE AND CLEAR SCREENS
		MOVE.L	LOGI,-(SP)
		MOVE.W	#$5,-(SP)
		TRAP	#14
		LEA	12(SP),SP
		
		MOVEM.L	OLD_PAL,D0-7
		MOVEM.L	D0-7,$FFFF8240
		RTS
		
SAVE_INTS
		MOVE.B #$12,$FFFFFC02.W
		MOVE.L	#STORAGE,A0
		MOVE.L	$70.W,(A0)+
		MOVE.L	$118.W,(A0)+
		MOVE.L	$120.W,(A0)+
		MOVE.B	$FFFFFA07.W,(A0)+
		MOVE.B	$FFFFFA09.W,(A0)+
		MOVE.B	$FFFFFA0F.W,(A0)+
		MOVE.B	$FFFFFA11.W,(A0)+
		MOVE.B	$FFFFFA13.W,(A0)+
		MOVE.B	$FFFFFA1B.W,(A0)+
		MOVE.B	$FFFFFA1D.W,(A0)+
		MOVE.B	$FFFFFA21.W,(A0)+
		
		RTS
		
SET_INTS1
		MOVE.W	#$2700,SR
		MOVE.L	#VBL1,$70.W
		MOVE.L	#T1_1,$120.W
		CLR.B	$FFFFFA1B.W
		CLR.B	$FFFFFA1D.W
		AND.B	#$0,$FFFFFA09.W
		AND.B	#$0,$FFFFFA07.W
		ORI.B	#$1,$FFFFFA07.W		
		ORI.B	#$1,$FFFFFA13.W
		BCLR	#$3,$FFFFFA17.W	;auto ISR enable at RTE - MSD
		MOVE.W	#$2300,SR
		RTS		
		
SET_INTS2
		MOVE.W	#$2700,SR
		MOVE.L	#VBL2,$70.W
		MOVE.L	#T2_1,$120.W
		CLR.B	$FFFFFA1B.W
		CLR.B	$FFFFFA1D.W
		MOVE.W	#$2300,SR
		RTS
		
REST_INTS	
		MOVE.W	#$2700,SR
		MOVE.L	#STORAGE,A0
		MOVE.L	(A0)+,$70.W
		MOVE.L	(A0)+,$118.W
		MOVE.L	(A0)+,$120.W
		MOVE.B	(A0)+,$FFFFFA07.W
		MOVE.B	(A0)+,$FFFFFA09.W
		MOVE.B	(A0)+,$FFFFFA0F.W
		MOVE.B	(A0)+,$FFFFFA11.W
		MOVE.B	(A0)+,$FFFFFA13.W
		MOVE.B	(A0)+,$FFFFFA1B.W
		MOVE.B	(A0)+,$FFFFFA1D.W
		MOVE.B	(A0)+,$FFFFFA21.W
		MOVE.W	#$2300,SR
		MOVE.B #$8,$FFFFFC02.W
		RTS

BEAM_MOVE:
		MOVE.L BEAM_COL,A2
		lea	BEAM,A0
		LEA 2(A0),A1
		REPT 33
		MOVE.W (A1)+,(A0)+
		ENDR
		MOVE.W (A2)+,(A0)
		CMP.L #B_COL_END,A2
		BNE END_BEAM
		MOVE.L #B_COL,A2
END_BEAM	MOVE.L A2,BEAM_COL
		RTS
		
		
DISPLAY_PIC1	MOVEM.L PIC1+2,D0-7
		MOVEM.L D0-7,NEW_PAL
		MOVE.w #8000-1,D7
		lea	PIC1+34,A0
		MOVE.L SCREEN1,A1
.LOOP1		MOVE.L (A0)+,(A1)+
		DBF D7,.LOOP1
		RTS


VBL1:		
		MOVEM.L	D0-7,-(SP)
		MOVE.W	O_COL,D0
		MOVE.W	D0,$FFFF8240
		SF.B	VBL_TEST
		CLR.B	$FFFFFA1B.W
		MOVE.B	W_LINE,$FFFFFA21.W	;199 LINE DOWN
		MOVE.L	#T1_1,$120.W
		MOVE.B	#8,$FFFFFA1B.W
		MOVEM.L	(SP)+,D0-7
		RTE
		
VBL2:		
		MOVEM.L	D0-7,-(SP)
		MOVE.W	O_COL,D0
		MOVE.W	D0,$FFFF8240
		SF.B	VBL_TEST
		CLR.B	$FFFFFA1B.W
		MOVE.B	#1,$FFFFFA21.W		;199 LINE DOWN
		MOVE.L	#T2_1,$120.W
		MOVE.B	#8,$FFFFFA1B.W
		MOVEM.L	(SP)+,D0-7
		RTE
		
		
T1_1		CLR.B	$FFFFFA1B.W
		MOVE.W	NEW_PAL,$FFFF8240.w
		MOVEM.L	D0-7/A0-6,-(SP)
	
		CLR.W D2
		MOVE.B	W_LINE,D0
		MOVE.W	#200,D1
		LSL.B	D0
		SUB.B	D0,D2
		ADD.W	D2,D1
		
		MOVE.B	D1,$FFFFFA21.W	
		MOVE.L	#T1_2,$120.W
		
		MOVEM.L (SP)+,D0-7/A0-6
		MOVE.B #8,$FFFFFA1B.W
		RTE
		
		
T1_2		CLR.B	$FFFFFA1B.W
		MOVE.W 	O_COL,$FFFF8240.w
		RTE		
		
T2_1		MOVE.W #$2700,SR
		CLR.B	$FFFFFA1B.W
		MOVEM.L	D0-7/A0-6,-(SP)
	
		lea	$FFFF8209.w,a0
		MOVE.B	#16,D1
.WAIT		MOVE.B (A0),D0
		BEQ .WAIT
		SUB.B D0,D1
		LSL.B D1,D0
	
		MOVE.B	#194,$FFFFFA21.W	
		MOVE.L	#T2_2,$120.W
		
		lea	BEAM,A1
		lea	$FFFF8240.w,A2
		
		REPT 66
		NOP
		ENDR
		
		
		REPT 34
		MOVE.W (A1)+,(A2)
		ENDR
		
		MOVE.B	#8,$FFFFFA1B.W
		clr.w	$FFFF8240.w
		
		lea	SCR_BUF,A0
		MOVE.w	#31,D7		;HEIGHT OF SCROLL
		
		MOVE.B 	SPEED,D1
		LSR.B 	D1,D1
		
		REPT 9
		NOP
		ENDR
		
.LOOP2
		nop
		nop

		REPT	34
		MOVE.W	(A0)+,(A2)
		ENDR
		
		clr.w	$FFFF8240.w
		clr.w	$FFFF8240.w
		clr.w	$FFFF8240.w
		clr.w	$FFFF8240.w
		
		REPT	5
		nop
		ENDR
		
		DBF D7,.LOOP2
		
		MOVE.W NEW_PAL,$FFFF8240.w
		MOVE.W #$2300,SR
		MOVEM.L (SP)+,D0-7/A0-6
		RTE
		
		
T2_2		
		CLR.B	$FFFFFA1B.W
		MOVE.W #$2700,SR
		MOVEM.L	D0-7/A0-6,-(SP)
	
		lea	$FFFF8209.w,A0
		MOVE.B #$10,D1
.WAIT		MOVE.B (A0),D0
		BEQ .WAIT
		SUB.B D0,D1
		LSL.B D1,D0
	
		lea	BEAM,A1
		lea	$FFFF8240.w,A2
		
		REPT 82
		NOP
		ENDR
		
		REPT 34
		MOVE.W (A1)+,(A2)
		ENDR
		MOVE.W 	O_COL,$FFFF8240.w
		MOVE.W 	#$2300,SR
		MOVEM.L (SP)+,D0-7/A0-6
		RTE
		
BEAM_COL	DC.L B_COL
		
B_COL		dc.w	$10f,$90f,$20f,$a0f,$30f,$b0f,$40f,$c0f
		dc.w	$50f,$d0f,$60f,$e0f,$70f,$f0f,$f07,$f0e
		dc.w	$f06,$f0d,$f05,$f0c,$f04,$f0b,$f03,$f0a
		dc.w	$f02,$f09,$f01,$f08,$f00,$f80,$f10,$f90
		dc.w	$f20,$fa0,$f30,$fb0,$f40,$fc0,$f50,$fd0
		dc.w	$f60,$fe0,$f70
		DC.W	$F70,$FE0,$F60
		DC.W	$FD0,$F50,$FC0,$F40,$FB0,$F30,$FA0,$F20
		DC.W	$F90,$F10,$F80,$F00,$F08,$F01,$F09,$F02
		DC.W	$F0A,$F03,$F0B,$F0B,$F0C,$F05,$F0D,$F06
		DC.W	$F0E,$F07,$F0F,$70F,$E0F,$60F,$D0F,$50F
		DC.W	$C0F,$40F,$B0F,$30F,$A0F,$20F,$90F,$10F
		
		

B_COL_END	dc.w	$10f,$90f,$20f,$a0f,$30f,$b0f,$40f,$c0f
		dc.w	$50f,$d0f,$60f,$e0f,$70f,$f0f,$f07,$f0e
		dc.w	$f06,$f0d,$f05,$f0c,$f04,$f0b,$f03,$f0a
		dc.w	$f02,$f09,$f01,$f08,$f00,$f80,$f10,$f90
O_COL		DC.W COLOUR0				;$909
W_LINE		DC.B 99
		EVEN
NEW_PAL		DC.W $000,$700,$600,$500,$400,$300,$200,$100
		DC.W $007,$006,$005,$004,$003,$002,$001,$777
PIC1		INCBIN 	ADRENALN.PI1		 
MUSIC		INCBIN 	MAX19.MUS
FONT		INCLUDE RASTER.FNT
ascii		INCBIN TEXT.TXT
		DC.B $FF
		EVEN
W_I_T		DC.W 0
ORDER		DC.B " ABCDEFGHIJ"
		DC.B "KLMNOPQRST"
		DC.B "UVWXYZ."		;COPY OF FONT
		DC.B ""
		DC.B ""
		
STOPPER		DC.W $FFFF
		EVEN
COUNT		DC.L 0
CHOICES		DC.L EXEC1,EXEC2,EXEC3,EXEC4,EXEC5
EXEC1		DC.B 'PROG1.PRG',0
		EVEN
EXEC2		DC.B 'PROG2.PRG',0
		EVEN
EXEC3		DC.B 'PROG3.PRG',0
		EVEN
EXEC4		DC.B 'PROG4.PRG',0
		EVEN
EXEC5		DC.B 'PROG6.PRG',0
		EVEN
COL_SET		DC.B $1
		EVEN

SPEED		DC.W $0000
SPEED_TST	DC.W 0
***************************
	SECTION BSS
***************************

BEAM		DS.W 34		;RASTER_BEAM
		DS.L 1
SCR_BUF		DS.W 34*32	;SCROLL BUFFER
CHR_BUF		DS.W 6*31

STOPER		DS.L 1
HZ_TEST		DS.W 1
WHAT_HZ		DS.W 1
PHYS		DS.L 1		;OLD PHYSICAL SCREEN
LOGI		DS.L 1		;OLD LOGICAL SCREEN
RES		DS.W 1		;OLD RESOLUTION
OLD_USP		DS.L 1		;OLD USP
OLD_PAL		DS.L 8		;OLD PAL
STORAGE		DS.L 16
VBL_TEST	DS.W 1
SCROLL_TEST	DS.W 1
KEYB		DS.W 1

BLANK		DS.L 8
SCREEN1		DS.L 1
SCREEN2		DS.L 1
		ds.b	256
SCREENS		ds.b	160*248
		ds.b	160*248
