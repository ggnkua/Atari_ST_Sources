
;**************************************************************************
;*
;*      EXTENSION WEST PHASER POUR STOS BASIC
;*
;*      Adaptation au Stos Basic Par Francois Lionet
;*
;*      Stos Basic (c) Mandarin / Jawx
;*
;**************************************************************************

;**************************************************************************

; Adaptation au Stos basic
        bra load
        even
        dc.b $80
tokens: dc.b "phaser end",$80,"phaser x",$81
        dc.b "phaser calibrate",$82,"phaser y",$83
        dc.b "phaser init",$84,"phaser",$85
        dc.b 0
        even
jumps:  dc.w 6
        dc.l PhaEnd,PhaX
        dc.l PhaCal,PhaY
        dc.l PhaIni,PhaKey
        even
welcome:dc.b "West Phaser compatible",0
        dc.b "Compatible West Phaser",0
        dc.b 0
        even
table:  dc.l 0

;**************************************************************************

; Appel lors du chargement
load:   lea 	finprg(pc),a0
        lea	cold(pc),a1
        rts

******* COLD START: INIT PHASER INTERRUPTIONS
cold:   move.l 	a0,table
        lea 	welcome(pc),a0
        lea 	warm(pc),a1
        lea 	tokens(pc),a2
        lea 	jumps(pc),a3
Warm:   rts                     ;depart a chaud: ne fait rien

******* Instruction PHASER END
PhaEnd: lea 	PHD(pc),a0
	move.l	PHASER_SAUVBL-PHD(a0),d0
	beq.s	Rien
	move.l	d0,$70
	clr.l	PHASER_SAUVBL-PHD(a0)
Rien:	rts

******* Instruction PHASER INIT
PhaIni:	movem.l	a3-a6,-(sp)
	bsr	INIT_PHASER
	movem.l	(sp)+,a3-a6
	rts

******* Instruction PHASER_CALIBRATE
PhaCal:	lea	PHD(pc),a0
	tst.l	PHASER_SAUVBL-PHD(a0)
	beq.s	Rien
	movem.l	a3-a6,-(sp)
	bsr	CALIBRATE_PHASER
	movem.l	(sp)+,a3-a6
	rts

******* Fonction =PHASER KEY
PhaKey:	lea	PHD(pc),a0
	move.w	PHASER_FIRE_TYPE-PHD(a0),d3
	ext.l	d3
	beq.s	PhaK1
	move.w	PHASER_X-PHD(a0),OLDPHASER_X-PHD(a0)
	move.w	PHASER_Y-PHD(a0),OLDPHASER_Y-PHD(a0)
	moveq	#-1,d3
PhaK1:	moveq	#0,d2
	rts

******* Fonction =PHASERX
PhaX:	lea	PHD(pc),a0
	move.w	OLDPHASER_X-PHD(a0),d3
	moveq	#0,d2
	rts

******* Fonction =PHASERY
PhaY:	lea	PHD(pc),a0
	move.w	OLDPHASER_Y-PHD(a0),d3
	moveq	#0,d2
	rts

**************************************************************************
**									**
**	PHASER ROUTINE RS232	Version 6.00	30-09-89		**
**									**
**		ATARI ST						**
**									**
**	CONCEPTION : V. BAILLET	   -	REALISATION : Ch. GOMEZ		**
**									**
**	COPYRIGHT	LORICIEL	SEPTEMBER 1989			**
**									**
**	 COPY STRICTLY PROHIBITED WITHOUT WRITTEN APPROVAL		**
**									**
**************************************************************************
**									**
**	CONTENTS:							**
**
**	- INIT_PHASER : THE PHASER INITIALISATION ROUTINE.
**
**		THIS ROUTINE SUPPLIES THE SERIAL PORT WITH CURRENT
**		YOU  HAVE TO INSERT THIS ROUTINE AT THE BEGINNING OF YOUR
**		PROGRAM.
**
**	- CALIBRATE_PHASER : THE CALIBRATION ROUTINE.
**
**		THIS ROUTINE ADJUSTS THE PRECISION OF THE SHOOTING, ACCORDING
**		TO THE DISTANCE BETWEEN THE GUN AND THE SCREEN.
**
**	- PHASER_INT : THE VBL ROUTINE.
**
**		- THIS ROUTINE TESTS THE FIRE, WRITES THE KIND
**		  OF FIRE IN 'PHASER_FIRE_TYPE' IF TRIGGER
**		  OR HAMMER IS PULLED, DETECTS THE SPOT 3 VBL
**		  LATER, WRITES THE X & Y VALUES IN 'PHASER_X'
**		  AND 'PHASER_Y'.
**
**		N.B: THE TYPE OF FIRE IS DETERMINED BY THE MOMENT
**		     BETWEEN THE TIME WHEN THE HAMMER OR THE TRIGGER
**		     HAS BEEN PULLED AND THE ONE WHEN IT HAS BEEN LOOSEN.
**
**	THIS SOFTWARE RUNS IN LOW AND MEDIUM RESOLUTION : IT IS AUTOMATICALLY
**	DETECTED BY THE 'INIT_PHASER' ROUTINE.
**


;---------------------------------------------------
;--
;--	HOW TO USE THE PHASER :
;--
;--		- FIRST YOU HAVE TO CALL THE 'INIT_PHASER' ROUTINE.
;--
;--		- THEN, YOU MUST CALIBRATE YOUR GUN BY USING THE
;--		  'CALIBRATE_PHASER' ROUTINE : THIS ROUTINE CAN BE CALLED
;--		  AT ANY MOMENT.
;--		  BEFORE CALLING IT, YOU HAVE TO LOAD A SCREEN, WHICH
;--		  CONTAINS THE SIGHTING IN THE MIDDLE OF THE SCREEN.
;--		  THE USER WILL HAVE TO SHOOT FIVE TIMES ON THE SIGHTING TO
;--		  ADJUST THE PRECISION.
;--
;--		- IN YOUR MAIN PROGRAM YOU HAVE TO TEST 'PHASER_FIRE_TYPE' :
;--		  IF THIS FLAG IS SET, A FIRE HAS HAPPENED : YOU CAN GET THE
;--		  X & Y VALUES IN 'PHASER_X' AND 'PHASER_Y' AND THE KIND OF FIRE
;--		  IN 'PHASER_FIRE_TYPE' ( IF THE RIGHT INTERRUPTION ROUTINE HAS BEEN
;--		  SELECTED ).
;--
;--		- IF YOU WANT TO DETECT ANOTHER SHOT, YOU ONLY HAVE TO CLEAR THE
;--		  'PHASER_FIRE_TYPE' FLAG.




******************************************************************
**								**
**			PHASER INITIALISATION			**
**								**
******************************************************************

INIT_PHASER:
	move.l	#-1,$F8000
	move.l	#-1,$F8004

	MOVE.W	#4,-(SP)	; GETS THE RESOLUTION
	TRAP	#14
	ADDQ.L	#2,SP
	CMP.W	#0,D0
	BNE.S	.NEXT1

	MOVE.W	#1,RESOLUTION
	MOVE.W	#318,XMAX
	BRA.S	.NEXT2

.NEXT1
	MOVE.W	#2,RESOLUTION
	MOVE.W	#636,XMAX

.NEXT2
	TST.l	PHASER_SAUVBL
	BNE.S	DEJAFAIT
	MOVE.W	SR,D2
	MOVE.W	#$2700,SR

	OR.B	#%01000000,$FFFA07
	AND.B	#%10111111,$FFFA13
	
	MOVE.L	#DET_INT24,$60
	MOVE.L	#$FFFF8800,A0		; PROGRAM THE PSG FOR 24 V
	MOVE.B	#$E,0(A0)			; port A
	MOVE.B	2(A0),D0
	OR.B	#%00010000,d0		; bit 4 ON
	AND.B	#%11110111,d0		; bit 3 OFF
	MOVE.B	D0,2(A0)
	MOVE.L	$70,PHASER_SAUVBL		; INSTALLS THE ROUTINE UNDER VBL INTERRUPTION
	MOVE.W	#-1,PHASER_COUNTER
	MOVE.L	#PHASER_INT,$70		; AND SAVES THE OLD ROUTINE
	MOVE.W	D2,SR
DEJAFAIT
	RTS

DET_INT24:
	RTE


******************************************************************
**								**
**			PHASER CALIBRATION			**
**								**
******************************************************************

CALIBRATE_PHASER:
	move.l	#-1,$F1000
	CLR.L	DECAL_PHASER_X
	MOVEQ.W	#4,D7			; 5 SHOOTINGS
	LEA	PHASER_DATA,A0

.LOOP					; WAITS FOR A SHOOTING

	CMP.W	#0,PHASER_FIRE_TYPE
	BEQ.S	.LOOP

	MOVE.W	PHASER_X,(A0)+
	MOVE.W	PHASER_Y,(A0)+		; SAVES THE X & Y VALUES
	CLR.W	PHASER_FIRE_TYPE
	DBF	D7,.LOOP

	LEA	PHASER_DATA,A0
	CLR.L	D0
	CLR.L	D1
	MOVE.W	#4,D7
.LOOP1
	ADD.W	(A0)+,D0
	ADD.W	(A0)+,D1
	DBF	D7,.LOOP1		; CALCULATES THE AVERAGE VALUES
	DIVU	#5,D0			; OF THE SHOOTINGS
	DIVU	#5,D1
	MOVE.W	XMAX,D2
	LSR.W	#1,D2
	SUB.W	D2,D0
	SUB.W	#99,D1
	MOVE.W	D0,DECAL_PHASER_X
	MOVE.W	D1,DECAL_PHASER_Y
	RTS


******************************************************************
**								**
**	    INTERRUPTION ROUTINE WHICH TESTS THE TRIGGER	**
**								**
**    LOOKS FOR THE SPOT AND DETERMINES THE KIND OF SHOOTING	**
**								**
******************************************************************

PHASER_INT

	MOVE.W	SR,-(SP)
	ORI	#$700,SR
	MOVEM.L	A0-A6/D0-D7,-(SP)

	MOVEA.W	#$FA01,A0		; FFFA01.B -> ADDRESS WHERE DATAS ARE.

	CMP.W	#-1,PHASER_COUNTER	; IS THE GUN ALREADY FIRING ?
	BEQ.S	.TEST_FIRE_PHASER

	SUBQ.W	#1,PHASER_COUNTER	; HAVE THE 3 VBL INTERRUPTIONS
					; ALREADY HAPPENED ?
	BEQ.S	.TEST_SPOT_PHASER	; YES -> LOOK FOR THE SPOT

	BRA	.PHASER_INT_END

.TEST_FIRE_PHASER

	CMP.W	#1,PHASER_FIRING	; HAS THE TRIGGER ALREADY BEEN PULLED ?
	BEQ.S	.TEST_FIRE_OFF

	AND.B	#%00000100,(A0)		; TESTS IF THE TRIGGER IS BEING PULLED
	BEQ	.PHASER_INT_END

	MOVE.W	#1,PHASER_FIRING	; IF YES : INITIALISATION OF THE
	BRA	.PHASER_INT_END		; FIRING COUNTER

.TEST_FIRE_OFF

	ADDQ.W	#1,PHASER_VBL_COUNTER	; INCREASES THE VBL COUNTER
					; TO DIFFERENTIATE 2 KINDS OF FIRE
	
	AND.B	#%00000100,(A0)		; HAS THE TRIGGER BEEN LOOSEN ?
	BNE	.PHASER_INT_END

	MOVE.W	#3,PHASER_COUNTER	; WE WILL LOOK FOR THE SPOT IN 3 VBL
	MOVE.W	#1,PHASER_FIRE
	CMP.W	#$10,PHASER_VBL_COUNTER
	BLE	.PHASER_INT_END

	MOVE.W	#2,PHASER_FIRE		; SITUATION IN WHICH THE HAMMER HAS
	BRA	.PHASER_INT_END		; MANUALLY BEEN PULLED

.TEST_SPOT_PHASER

	MOVE.B	$FFFA07,PHASER_IFA13	; SAVES THE INTERRUPTIONS
	MOVE.B	$FFFA09,PHASER_IFA15	
	AND.B	#%01000000,$FFFA07
	CLR.B	$FFFA09			; CUTS THE INTERRUPTIONS
 
	MOVE.L	#$FF8240,A2		; SAVES THE PALETTE
	LEA	PALETTE_PHASER,A1
	MOVEM.L	(A2),D0-D7
	MOVEM.L	D0-D7,-(A1)
	ADD.L	#32,A1			; MAKES THE SCREEN FLASHING
	MOVEM.L	(A1),D0-D7
	MOVEM.L	D0-D7,(A2)

;			GET THE ADDRESS OF THE PHYSICAL SCREEN
;			AND PUT IT INTO REGISTER D5

	CLR.L	D5
	MOVE.B	$FFFF8203,D5
	MOVE.L	D5,D4
	LSL.W	#8,D4
	ADD.B	#$7D,D5

	MOVE.L	#PHASER_BUFFER,A1
	MOVEA.W	#$8207,A4
	MOVEQ	#6,D2

;		WE FIRST DETERMINE THE APPROXIMATIVE ADDRESS OF THE SPOT
.LOOP1

	REPT	200
	BTST.B	D2,(A0)
	BNE	.LOOP10		; WAITS FOR THE SPOT TO BE DETECTED
	ENDR

	MOVE.B	(A4),D3
	CMP.B	D5,D3
	BNE	.LOOP1

	BRA	.PHASER_INT_END1 ; GETS OUT IF THE SPOT IS OUT OF THE SCREEN

.LOOP10

	MOVEP.W	0(A4),D3

	AND.L	#$FFFF,D3
	SUB.W	D4,D3
	DIVU	#160,D3
	SWAP	D3

.LOOP0_00
	BTST.B	D2,(A0)
	BEQ	.LOOP0_00

	MOVEQ	#-1,D7

	CMP.W	#$30,D3		; TESTS IF THE SPOT IS IN
				; THE RIGHT HAND SIDE OF THE SCREEN
 	BLT	.TEST_SPOT_PHASER2

;	SITUATION WHERE THE SPOT IS IN THE LEFT HAND SIDE OF THE SCREEN

.TEST_SPOT_PHASER1

	BTST.B	D2,(A0)
	BNE	.TEST_SPOT_PHASER1

.LOOP1_0
	REPT	200
	BTST.B	D2,(A0)
	BNE	.LOOP1_01
	ENDR

	BRA.S	.NEXT1_1

.LOOP1_01

;		STOCKS THE SPOT'S ADDRESS

	MOVEP.W	0(A4),D3
	MOVE.W	D3,(A1)+

	ADDQ.W	#1,D7
	CMP.W	#19,D7
	BEQ.S	.NEXT1_1

	MOVE.B	(A4),D0
	CMP.B	D5,D0
	BEQ.S	.NEXT1_1

	BRA	.TEST_SPOT_PHASER1

.NEXT1_1
;			CALCULATES THE X & Y VALUES OF THE SPOT

	CMP.W	#-1,D7
	BEQ	.PHASER_INT_END1
	MOVE.L	#PHASER_BUFFER,A1
	MOVE.W	D7,D6
	MOVE.W	D7,D5

.LOOP1_4	; CHANGES THE ADDRESSES FROM THE SCREEN INTO X & Y VALUES

	CLR.L	D0
	MOVE.W	(A1),D0
	SUB.W	D4,D0
	DIVU	#160,D0
	MOVE.B	D0,(A1)+	; Y VALUE
	SWAP	D0
	CMP.B	#0,D0
	BNE.S	.NEXT1_10

	MOVE.B	#160,D0
	
.NEXT1_10

	MOVE.B	D0,(A1)+	; X VALUE
	DBF	D7,.LOOP1_4


;			CALCULATES THE AVERAGE POSITION
;			FROM SEVERAL SPOTS

	MOVE.L	#PHASER_BUFFER,A1
	CLR.L	D2
	CLR.L	D1

.LOOP1_5

	CLR.L	D0
	CLR.L	D3
	MOVE.B	(A1)+,D0
	MOVE.B	(A1)+,D3
	CMP.B	#$A0,D3
	BNE.S	.NENE1
	SUBQ.W	#1,D5
	CLR.L	D0
	CLR.L	D3
.NENE1
	ADD.L	D0,D2		; Y VALUE
	ADD.L	D3,D1		; X VALUE

	DBF	D6,.LOOP1_5

	CMP.W	#0,D5
	BMI.S	.PHASER_INT_END1

	ADDQ.W	#1,D5
	DIVU	D5,D1
	DIVU	D5,D2
	SUB.W	#48,D1
	BCC.S	.SAVE_COOR_PHASER

	CLR.W	D1

.SAVE_COOR_PHASER

	MOVE.W	RESOLUTION,D0
	LSL.W	D0,D1
	SUB.W	DECAL_PHASER_X,D1
	BMI.S	.PHASER_INT_END1

	CMP.W	XMAX,D1
	BLE.S	.NEXT
	MOVE.W	XMAX,D1

.NEXT

	MOVE.W	D1,PHASER_X
	MOVE.W	D2,PHASER_Y
	MOVE.W	PHASER_FIRE,PHASER_FIRE_TYPE

.PHASER_INT_END1

	MOVE.W	#-1,PHASER_COUNTER
	CLR.W	PHASER_FIRING
	MOVE.L	#$FF8260,A0
	LEA	PALETTE_SAVE,A1
	MOVEM.L	(A1)+,D0-D7
	MOVEM.L	D0-D7,-(A0)
	MOVE.B	PHASER_IFA13,$FFFA07
	MOVE.B	PHASER_IFA15,$FFFA09

.PHASER_INT_END

	MOVEM.L	(SP)+,A0-A6/D0-D7
	MOVE.W	(SP)+,SR
	MOVE.L	PHASER_SAUVBL,-(SP)
	RTS

;		SECOND SITUATION : THE SPOT IS TOO CLOSE FROM THE RIGHT EDGE

.TEST_SPOT_PHASER2

	BTST.B	D2,(A0)
	BNE	.TEST_SPOT_PHASER2

.LOOP2_0

	REPT	200
	BTST.B	D2,(A0)
	BNE	.LOOP2_01
	ENDR

	BRA.S	.NEXT2_1

.LOOP2_01

;		STOCKS THE SPOT'S ADDRESS

	MOVE.W	#24,D3

.LOOP2_3
	DBF	D3,.LOOP2_3

	MOVEP.W	0(A4),D3
	MOVE.W	D3,(A1)+

	ADDQ.W	#1,D7

	CMP.W	#19,D7
	BEQ.S	.NEXT2_1

	MOVE.B	(A4),D0
	CMP.B	D5,D0
	BEQ.S	.NEXT2_1

	BRA	.TEST_SPOT_PHASER2

.NEXT2_1
;			CALCULATES THE X & Y VALUES OF THE SPOT

	CMP.W	#-1,D7
	BEQ	.PHASER_INT_END1
	MOVE.L	#PHASER_BUFFER,A1
	MOVE.W	D7,D6
	MOVE.W	D7,D5

.LOOP2_4
			; MODIFIES SCREEN ADRESSES INTO X & Y VALUES
	CLR.L	D0
	MOVE.W	(A1),D0
	SUB.W	D4,D0
	DIVU	#160,D0
	MOVE.B	D0,(A1)+	; Y VALUE
	SWAP	D0
	CMP.B	#0,D0
	BNE.S	.NEXT2_10

	MOVE.B	#160,D0

.NEXT2_10

	MOVE.B	D0,(A1)+	; X VALUE
	DBF	D7,.LOOP2_4

;			CALCULATES THE AVERAGE POSITION
;			FROM SEVERAL SPOTS

	MOVE.L	#PHASER_BUFFER,A1
	CLR.L	D2
	CLR.L	D1

.LOOP2_5
	CLR.L	D0
	CLR.L	D3
	MOVE.B	(A1)+,D0
	MOVE.B	(A1)+,D3
	CMP.B	#$A0,D3
	BNE.S	.NENE2
	SUBQ.W	#1,D5
	CLR.L	D0
	CLR.L	D3
.NENE2
	ADD.L	D0,D2		; Y VALUE
	ADD.L	D3,D1		; X VALUE

	DBF	D6,.LOOP2_5

	CMP.W	#0,D5
	BMI	.PHASER_INT_END1

	ADDQ.W	#1,D5

	DIVU	D5,D1
	DIVU	D5,D2
	SUB.W	#110,D1
	BCC.S	.NEXT2_3

	ADD.W	#160,D1
	BRA	.SAVE_COOR_PHASER

.NEXT2_3

	MOVE.W	#159,D1
	BRA	.SAVE_COOR_PHASER


*********************** Debut des donnees phaser
PHD:		equ *
*****************************************************************

PALETTE_SAVE
		DC.W	$000
		DCB.W	2,$700
		DC.W	$777
		DCB.W	11,$700
		DC.W	$777

PALETTE_PHASER
		DCB.W	16,$777

RESOLUTION	DC.W	2	; 1 -> LOW RESOLUTION
				; 2 -> MEDIUM RESOLUTION
XMAX		DC.W	0

PHASER_SAUVBL:		DC.L	0
PHASER_FIRE_TYPE:	DC.W	0
PHASER_FIRING:		DC.W	0
PHASER_COUNTER:		DC.W	-1
PHASER_FIRE:		DC.W	0
PHASER_VBL_COUNTER:	DC.W	0
PHASER_X:		DC.W	0
PHASER_Y:		DC.W	0
PHASER_IFA13:		DS.B	1
PHASER_IFA15:		DS.B	1
PHASER_DATA:		DS.W	8
DECAL_PHASER_X:		DC.W	0
DECAL_PHASER_Y:		DC.W	0
OLDPHASER_X:		DC.W	0
OLDPHASER_Y:		DC.W 	0
PHASER_BUFFER:		DS.W	50
LOAD_ADDRESS:

        
;************************************************************************
        dc.l 0
finprg: equ *



