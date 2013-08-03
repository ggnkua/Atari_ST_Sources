;
;	Mars effect - with rotation.
;	Plus a thorough cleaing up of the original code!
;
;
;
;
;	Program will send ztable each frame!
;	Also now must send rowcentre_z for calculation
;
;
;
;	New format of ztable:
;
;	WORD/WORD	rowcentre_z (absolute value for colourcalc)
;	WORD		rowcentreoffset_y_screen
;	WORD/WORD	xstep
;	WORD/WORD	xstart
;	WORD		y_scale_rotated
;
;	- Makes 8 words in all
;




Sky_Width	EQU	192		;was 318
Sky_Height	EQU	49
ScreenLines	EQU	100
BytesPerLine	EQU	Sky_Width*2*2
Lines		EQU	100
Pixels		EQU	384
z_levels	EQU	8
Max_H		EQU	$10000
Max_H2		EQU	$4000
z_gap		EQU	10

;--------------------------------------------------------------
screen_swap:
	MOVE.L	logic,D0
	MOVE.L	third,logic
	MOVE.L	physic,third
	MOVE.L	D0,physic
; Add X Position:
	;ADD.L	X_Screen_Offset,D0

	MOVE.L	D0,-(A7)
	MOVE.B	1(A7),$ffff8201.W
	MOVE.B	2(A7),$ffff8203.W
	MOVE.B	3(A7),$ffff820d.W
	ADDQ.L	#4,A7
	RTS

;--------------------------------------------------------------
ClearScreens2:
	MOVE.l	#$00040004,D0
	bra	cl2

ClearScreens:
	MOVEQ	#0,D0
cl2
	MOVE.L	physic,A0
	MOVE.L	logic,A1
	MOVE.L	third,A2
	MOVE.W	#ScreenLines*BytesPerLine/4-1,D1
.Wipe:	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A1)+
	MOVE.L	D0,(A2)+
	DBF	D1,.Wipe
	RTS


;--------------------------------------------------------------
Handle_Planet:
	MOVE.W	#$2300,SR
	ifne keys
	bsr handle_keyboard
	endc

	JSR	Wait_SendDsp
	MOVE.L	#"CAL",$FFFFA204.W

	MOVE.L	Logic,A0
	ADD.L	#BytesPerLine*(Lines/2),A0
	;ADD.L	X_Screen_Offset,A0

	MOVE.L	#$0909,D0
	MOVEC	D0,CACR

	LEA	Colour_Table+64*2,A5
	LEA	$FFFFA206.W,A1
	LEA	$FFFFA204.W,A2
	LEA	$FFFFA202.W,A3
	MOVE.L	#BytesPerLine,D7
	MOVE.L	#"END",D6
.HandleLoop
	 wait_receive
	MOVE.L	(A2),D0
	CMP.L	D6,D0
	BEQ.S	.Done
	MOVE.W	(A1),D1
	LEA	(A0,D0.L*4),A4
	 ;wait_receive
	SUBQ.W	#1,D1

	MOVE.W	(A1),D2
	EXT.L	D2
	ASL.L	#8,D2
	SWAP	D2

	MOVE.W	(A1),D3
	EXT.L	D3
	ASL.L	#8,D3
	SWAP	D3
.printpoly:
	MOVE.L	(A5,D2.W*2),(A4)
	ADDX.L	D3,D2
	ADD.L	D7,A4
	DBF	D1,.printpoly
.skipcol:
	BRA	.HandleLoop


;--------------------------------------------------------------
.Done:	BSR	Swap_Delta

	MOVE.L	#$0009,D0			;data cache off
	MOVEC	D0,CACR

	MOVE.L	logic,A0

	MOVE.L	Delta_List,A2

	ADD.L	#BytesPerLine*(Lines/2),A0

	MOVE.W	#192-1,D0
	MOVEQ.l	#0,D7
	MOVE.L	#BytesPerLine,D6
.loop2:
	wait_receive
	MOVE.W	(A1),D1			; d1 new height
	MOVE.W	(A2),D2			; d2 old height
	MOVE.W	D1,(A2)+		; replace old
; New value (D1) greater than before?
	CMP.W	D2,D1
	BLE.S	.dontdo2
	SUB.W	D2,D1
	MOVE.W	D2,D3
	MULS.W	#BytesPerLine,D2
	LEA	(A0,D2.L),A4
	MULS.W	#Sky_Width*2,D3
	LEA	(A3,D3.L),A5
	SUBQ.W	#1,D1
.loop3	MOVE.L	D7,(A4)
	ADD.L	D6,A4
	DBF	D1,.loop3
.dontdo2
	ADDQ.L	#2,A3			;next pixel along in gfx
	ADDQ.L	#4,A0
	DBF	D0,.loop2

	RTS

.dontdo	ILLEGAL

;--------------------------------------------------------------

Swap_Delta:
	MOVEM.L	Delta_List,D0/D1/d2
	MOVE.L	D1,Delta_List
	MOVE.L	D0,Delta_List+8
	MOVE.L	D2,Delta_List+4
	RTS

;--------------------------------------------------------------
; Movement:
Send_Movement:
	IFNE	Keys
	 TST.B	keyboard_matrix+2
	 BEQ.S	.no1
	 SUB.L	#$200,X_Position
.no1	 TST.B	keyboard_matrix+3
	 BEQ.S	.no2
	 ADD.L	#$200,X_Position
.no2	 TST.B	keyboard_matrix+4
	 BEQ.S	.no3
	 SUB.L	#$2,Z_Position
.no3	 TST.B	keyboard_matrix+5
	 BEQ.S	.no4
	 ADD.L	#$2,Z_Position
.no4	 TST.B	keyboard_matrix+$4a	;-	;-/+ Height
	 BEQ.S	.no5
	 SUB.L	#$10000,Y_Position
.no5	 TST.B	keyboard_matrix+$4e	;+
	 BEQ.S	.no6
	 ADD.L	#$10000,Y_Position
.no6
	ELSE

	 SUBQ.L	#1,Z_Position
; Do Y Movement Anyway:
	 MOVE.W	Y_Sine,D0
	 ADD.W	#90/6,D0			;slowish
	 AND.W	#$0FFF,D0
	 MOVE.W	D0,Y_Sine
	 MOVE.W	(Sine_Table+1.L,D0.W*4),D0	;get sine value
	 MULS.W	#$4E*2,D0			;make it go
						;underwater..
	 ADD.L	#$3E0000/2,D0
	 MOVE.L	D0,Y_Position

; Do X Movement Anyway:
	 MOVE.W	X_Sine,D0
	 ADD.W	#15/4,D0
	 AND.W	#$0FFF,D0
	 MOVE.W	D0,X_Sine
	 MOVE.W	(Sine_Table+1.L,D0.W*4),D0	;get sine value
	 EXT.L	D0
	 ASL.L	#2,D0				;nice'n'wide
	 MOVE.L	D0,X_Position
	ENDC

; Do Y Size:
	 CMP.L	#$7F0000,Y_Size
	 BGE.S	.dont_inc_ysize
	 ADD.L	#$C000,Y_Size
.dont_inc_ysize

	JSR	Wait_SendDsp
	MOVE.L	#"MOV",$FFFFA204.W
	LEA	Movement_Data,A0
	MOVEQ	#12-1,D0
.loop:
	MOVEM.W	(A0)+,D1/D2
	ADD.W	D2,D1
	MOVE.W	D1,-4(A0)
	AND.W	#$0FFF,D1
	ADD.W	#$1000,D1
	EXT.L	D1
	wait_transmit
	MOVE.L	D1,$FFFFA204.W
	DBF	D0,.loop

; Send X Offset:
	MOVE.L	X_Position,D1
	wait_transmit
	MOVE.L	D1,$FFFFA204.W
; Send Y Offset:
	MOVE.L	Y_Position,D1
	wait_transmit
	MOVE.L	D1,$FFFFA204.W

; Now send z Offsets
	MOVE.L	Z_Position,D1
	MULS	#-$8c,D1		;increment
	wait_transmit
	MOVE.L	D1,$FFFFA204.W

	moveq #0,d1
	MOVE.L	Z_Position,D1
	AND.L	#%111,D1
	MULU.W	#6,D1
	wait_transmit
	MOVE.L	D1,$FFFFA204.W
; Send Y Size:
	MOVE.L	Y_Size,D1
	wait_transmit
	MOVE.L	D1,$FFFFA204.W
	RTS



;--------------------basic i/o routines------------------------
Send_Sine_Table
	JSR	Wait_SendDsp
	MOVE.L	#"SIN",$FFFFA204.W

	LEA	Sine_Table,A0
	MOVE.W	#$0FFF,D1
.sendy:
	MOVE.L	(A0)+,D0
	BSR	Wait_SendDsp
	MOVE.L	D0,$ffffa204.w
	DBF	D1,.sendy
	RTS

;--------------------------------------------------------------
;
;	New sending of z table
;
;
;

Send_Z_Table:
	and.w	#$fff,theta
	;move.w	#$200,theta
	move.w	theta,d0

	move.w	(Sine_Table+1.L,D0.W*4),d1
	add.w	d1,d1
	move.w	d1,Sin_Theta

	add.w	#$400,d0
	and.w	#$fff,d0

	move.w	(Sine_Table+1.L,D0.W*4),d1
	add.w	d1,d1
	move.w	d1,Cos_Theta

; First, set eye position and angle settings:


	JSR	Wait_SendDsp
	MOVE.L	#"ZTA",$FFFFA204.W

	MOVE.W	#16-1,D7
	MOVE.w	#-0,D0
	LEA	Test_Table,A0

.SendPoints:
		MOVE.W	D7,-(A7)
		move.l	#0,rowcentre_x
		move.l	#0,rowcentre_y
		move.l	d0,rowcentre_z
	
		BSR	Calc_Row_Data
		BSR	Send_Row_Data

; Next one:
		ADD.W	#300,D0
		MOVE.W	(A7)+,D7
	DBF	D7,.SendPoints
	RTS


Calc_Row_Data:
		movem.l	rowcentre_x,d1/d2/d3
		sub.l	eye_x,d1
		sub.l	eye_y,d2
		sub.l	eye_z,d3
		movem.w	d1/d2/d3,rowcentreoffset_x

; Trying to get x,y and z values of similar widths now!

; First, we want to get the y and z value of the rotated
;    rowcentre point.

; rowcentre_y_rotated
;     = (rowcentreoffset_y)*cos(theta) - (rowcentreoffset_z)*sin(theta)

; Should start off small, get bigger as sin_theta increases
		move.w	rowcentreoffset_y,d1
		muls.w	Cos_Theta,d1

		move.w	rowcentreoffset_z,d2
		muls.w	Sin_Theta,d2
		sub.l	d2,d1
		add.l	d1,d1			;double for fractional

; rowcentre_z_rotated
;     = (rowcentreoffset_y)*sin(theta) + (rowcentreoffset_z)*cos(theta)
		move.w	rowcentreoffset_y,d2
		muls.w	Sin_Theta,d2

		move.w	rowcentreoffset_z,d3
		muls.w	Cos_Theta,d3
		add.l	d3,d2
		add.l	d2,d2			;double for fractional

; Keep both stored as longword for the moment
		move.l	d1,rowcentre_y_rotated
		move.l	d2,rowcentre_z_rotated

; Now calculate y_scale:
		swap	d2
		tst.w	d2
		bge	.ok
		moveq	#1,d2
		move.l	#0,y_Scale
		move.l	#0,y_Scale2
		bra	.ok2
.ok:
		ext.l	d2
		move.l	#7000*10,d3
		divs.l	d2,d3
		move.l	d3,y_scale

		move.l	#7000*300,d3
		divs.l	d2,d3
		move.l	d3,y_scale2
.ok2:
; Xstep = K * Z_Distance
		move.l	d2,d3
		muls.w	#2,d3
		move.l	d3,xstep

; Xstart = (-96 * Xstep) + rowcentre_x:
		muls.l	#-96,d3

		move.w	rowcentre_x,d4
		asl.l	#8,d4
		asl.l	#8,d4
		add.l	d4,d3
		move.l	d3,xstart

; Y_Scale_Rotated = y_scale * cos(theta)
		move.l	Y_Scale,d3
		muls.w	Cos_Theta,d3
		add.l	d3,d3
		swap	d3
		move.w	d3,Y_Scale_Rotated

; rowcentre_y_screen = rowcentre_y_rotated * Y_Scale
		move.l	Y_Scale2,d3
		muls.w	rowcentre_y_rotated,d3
		add.l	d3,d3
		swap	d3
		move.w	d3,Rowcentre_y_screen
		rts


Send_Row_Data:
		lea	$ffffa204.w,a0
; rowcentre_z
		move.l	rowcentre_z,d1
		muls	#20,d1
		 wait_transmit
		move.l	d1,(a0)
; y_scale_rotated
		move.w	y_scale_rotated,d1
		ext.l	d1
		 wait_transmit
		move.l	d1,(a0)
; rowcentre_y_screen
		move.w	rowcentre_y_screen,d1
		ext.l	d1
		 wait_transmit
		move.l	d1,(a0)
; xstart:
		 wait_transmit
		move.l	xstart,(a0)
; xstep:
		 wait_transmit
		move.l	xstep,(a0)
		rts





;--------------------------------------------------------------
Send_One_Over_Table:
	JSR	Wait_SendDsp
	MOVE.L	#"ONE",$FFFFA204.W
	MOVEQ	#0,D0
	MOVE.W	#200-1,D1
.SendPoints:
	MOVE.L	#$7FffFF,D2
	DIVU.L	D0,D2
	BSR	Wait_SendDsp		; not time-critical!
	MOVE.L	D2,$FFFFA204.W
	ADDQ.L	#1,D0
	DBF	D1,.SendPoints
	RTS

;--------------------------------------------------------------
Wait_SendDsp:
	BTST	#1,$FFFFA202.W
	BEQ	Wait_SendDsp
	RTS
;--------------------------------------------------------------
Wait_ReceiveDsp:
	BTST	#0,$FFFFA202.W
	BEQ	Wait_ReceiveDsp
	RTS



Calc_Colours:
	LEA	Colour_List_Mars,A0
	LEA	Colour_Table,A1
	MOVE.W	(A0)+,D7
	SUBQ.W	#1,D7

.Calc_Colour:
	MOVE.W	(A0)+,D0
	SUBQ.W	#1,D0
.Calc2:
	MOVE.W	D0,-(A7)
	MOVE.L	(A0)+,D2
	MOVE.L	(A0)+,D0
	MOVE.L	(A0)+,D1
	BSR	.Calc_Span
	MOVE.W	(A7)+,D0
	DBF	D0,.Calc2

	DBF	D7,.Calc_Colour
	RTS

.Calc_Span:
	MOVE.W	D2,Span_Length
	MOVE.L	D1,D3
	MOVE.L	D1,D4
	MOVE.L	D1,D5
	MOVE.L	D0,D1
	MOVE.L	D0,D2
	AND.L	#$FF000000,D0
	AND.L	#$FF000000,D3
	AND.W	#$00FF,D2		; This could be much
	AND.W	#$00FF,D5		;  more efficient!
	SWAP	D1
	SWAP	D4
	AND.W	#$00FF,D1
	AND.W	#$00FF,D4
	SWAP	D0
	SWAP	D3
	LSR.W	#8,D0
	LSR.W	#8,D3
	SUB.W	D0,D3
	SUB.W	D1,D4
	SUB.W	D2,D5

	MOVE.W	D0,A3
	MOVE.W	D1,A4
	MOVE.W	D2,A5
	MOVEQ	#0,D6
.Calc:
	MOVE.W	D6,D0
	MULS.W	D3,D0
	DIVS.W	Span_Length,D0
	ADD.W	A3,D0
	MOVE.W	D6,D1
	MULS.W	D4,D1
	DIVS.W	Span_Length,D1
	ADD.W	A4,D1
	MOVE.W	D6,D2
	MULS.W	D5,D2
	DIVS.W	Span_Length,D2
	ADD.W	A5,D2
	LSL.W	#8,D0
	LSL.W	#3,D1
	LSR.W	#3,D2
	AND.W	#%1111100000000000,D0
	AND.W	#%0000011111000000,D1
	AND.W	#%0000000000011111,D2
	OR.W	D0,D2
	OR.W	D1,D2
	MOVE.W	D2,(A1)+
	;MOVE.W	D2,-(A2)
	ADDQ.W	#1,D6
	CMP.W	Span_Length,D6
	BNE.S	.Calc
	RTS


RTE	RTE

	IFNE	Tracker_On
	INCLUDE	F:\SOURCE\TDF\TRACKERC.S
	ELSE
Dsp_Library:INCLUDE F:\SOURCE\TDF\NEW_OS3.S
	ENDC

Set_Resolution:
	INCLUDE	F:\DATA\TDF\RES\MARS2.S
	MOVE.W	#(BytesPerLine-384*2)/2,$FFFF820E.W
	RTS

	IFNE Keys
Handle_Keyboard:
		LEA	Keyboard_Tests,A0
.loop		MOVE.L	(A0)+,D0
		BMI.S	.done
		MOVE.L	(A0)+,D1		;val to add
		MOVE.L	(A0)+,A1		;address
		TST.B	(Keyboard_Matrix.L,D0.w)
		BEQ.S	.nochange
		ADD.L	D1,(A1)			;along longword values
.nochange:
		BRA.S	.loop
.done:	RTS

Keyboard_Tests:
		DC.L	$02,+8,thetalong
		DC.L	$03,-8,thetalong
		DC.L	$04,+16,eye_y
		DC.L	$05,-16,eye_y
		DC.L	-1

	ENDC


;--------------------------------------------------------------
		SECTION DATA
Movement_Data:
		DC.W	0,16*2	;z, height
		DC.W	0,19*2
		DC.W	0,-13*2

		DC.W	0,15	;z, colour
		DC.W	0,-27
		DC.W	0,-9

		DC.W	0,10*2	;x, height
		DC.W	0,-20*2
		DC.W	0,30*2

		DC.W	0,-34	;x, colour
		DC.W	0,28
		DC.W	0,-23


X_Position		DC.L	0
Y_Position		DC.L	$000000		;mix $1e5000
Z_Position		DC.L	0
Y_Size			DC.L	0
	;-------------------------------------


Delta_List		DC.L	Delta_1,Delta_2,Delta_3
			DCB.W	Sky_Width*2,-30
Delta_1			DCB.W	Sky_Width*2,-30
Delta_2			DCB.W	Sky_Width*2,-30
Delta_3			DCB.W	Sky_Width*2,-30

Colour_List_Mars:
			DC.W	1			;total number
			DC.W	5
			DC.L	96/2,$fcfc00fc,$00400080
			DC.L	32/2,$00400080,$00000020
			DC.L	16/2,$00000020,$00000020
			DC.L	80/2,$00000020,$BCBC00FC
			DC.L	32/2,$BCBC00FC,$00000010

;--------------------------------------------------------------
Dsp_Routine_Mars:	INCBIN	F:\Dsp_New\Dsp\Mars2_5.Dsp
							;old routine
			EVEN

			CNOP	0,4
Sine_Table:		INCBIN	F:\Data\Marssine.Dat
			EVEN

			EVEN

eye_x			dc.l	0
eye_y			dc.l	-800
eye_z			dc.l	-000


;--------------------------------------------------------------
			SECTION	BSS
thetalong		ds.w	1
theta			ds.w	1

rowcentre_x		ds.l	1
rowcentre_y		ds.l	1
rowcentre_z		ds.l	1

rowcentreoffset_x	ds.w	1
rowcentreoffset_y	ds.w	1
rowcentreoffset_z	ds.w	1

y_distance		ds.l	1
z_distance		ds.l	1

Sin_Theta		ds.w	1
Cos_Theta		ds.w	1

rowcentre_y_rotated	ds.l	1
y_scale			ds.l	1
y_scale2		ds.l	1
rowcentre_z_rotated	ds.l	1

y_scale_rotated		ds.w	1
rowcentre_y_screen	ds.l	1
xstart			ds.l	1
xstep			ds.l	1

X_Sine			DS.W	1
Y_Sine			DS.W	1
Y_Size_Sine		DS.W	1
X_Screen_Offset		DS.L	1
third			DS.L	1
Span_Length		DS.W	1


Test_Table		DS.L	z_levels*8
Colour_Table:		DS.W	256*2
