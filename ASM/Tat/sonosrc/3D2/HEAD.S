;
;
;
;
;	New general 3d2 testing routines, Sep 96 onwards
;
;
;
;
;
;
;
;
;
;
;
;
;

RGB			EQU	1
Flash			EQU	0
VblWait			EQU	0
Keys			EQU	0
Tracker_On		EQU	0

Number_Of_Colours 	EQU	1

Bitplane_Mode		EQU	0
Mapping_Mode		EQU	1
Motion_Blur_Mode	EQU	0
Animation_Mode		EQU	0

xmax			EQU	383
ymax			EQU	099


		IFNE	Bitplane_Mode
ScreenLines		EQU	200
BytesPerLine		EQU	192
Lines			EQU	200
Pixels			EQU	384
		ELSE
ScreenLines		EQU	100
BytesPerLine		EQU	768
Lines			EQU	100
Pixels			EQU	384

Object_Width		EQU	384
Object_Height		EQU	100
		ENDC

Direction		EQU	0		;(Motion Blur)







Back_Colour	EQU	0
noscreens	EQU	3
Demo		EQU	1





start:

	IFNE	Demo
		INCLUDE	F:\Source\Tdf\Main\Equates.S
		output	c:\_demo\data\Room.prg
		opt	nodebug
	ENDC


	IFEQ	Demo
		INCLUDE EQUATES.S
		INCLUDE	TOSSTART.I
	ELSE
		INCLUDE	DEMSTART.I
	ENDC


;--------------------------------------------------------------

Display_Routine:
		BSR	Do_Effects
	IFEQ	Demo
		ILLEGAL
	ELSE
		MOVE.L	(A7)+,D0
		RTS
	ENDC


Initialize_Routine:

		init_dsp_routine Dsp_Routine_object,$210.W

		JSR	SendOneOver
	IFNE	Mapping_Mode
		JSR	Send_Texmap
	ENDC

		LEA	object_Object,A0
		JSR	Send_Object

	IFNE Animation_Mode
		JSR	Animate_Init
		JSR	Animate_Object		;(once)
	ENDC
		bsr	Set_res
		RTS


Do_Effects:
	IFNE Bitplane_Mode
		BSR	Set_Palette
	ENDC
		BSR	ClearScreens

		MOVE.W	#$2300,SR
		;MOVE.L	#0,Animate_Data_1

		MOVE.W	#210-1,D0
		BSR	Main_Loop
		;MOVE.L	#120,Animate_Data_1

.infinite:
		MOVE.W	#210-1,D0
		BSR	Main_Loop
		bra	.infinite

		JSR	Wait_SendDSP
		MOVE.L	#"RTS",$FFFFA204.W
		RTS

Main_Loop:
		MOVE.W	D0,-(A7)
		BSR	Create_Frame
		MOVE.W	(A7)+,D0
		DBF	D0,Main_Loop
		RTS

Create_Frame:
	IFEQ Bitplane_Mode
		JSR	Spin_Object
		LEA	object_1_Data,A0
		BSR	Start_One_object
		BSR	ClearScreen
		BSR	Draw_object
		;BSR	Draw_Info
	ELSE
		JSR	Spin_Object
		LEA	object_1_Data,A0
		BSR	Start_One_object
; Do intermediary stuff here:
		BSR	Draw_World_Bitplane
		BSR	Fetch_Bitplane_Screen	;...now fetch the next.
	ENDC
		BSR	screen_swap
	IFNE	VblWait
		BSR	wait_vbl
	ENDC
		RTS



Start_One_object:
		MOVE.L	A0,Current_object

	IFNE Animation_Mode
		BSR	animate_object
	ENDC
		MOVE.L	Current_object,A0
		BSR	Send_Viewpoint
		BSR	MakeMatrixLight		;Must be done FIRST
		BSR	MakeMatrixObject
		wait_transmit
		MOVE.L	#"CAL",$FFFFA204.W
		wait_transmit
		MOVE.L	#"HAN",$FFFFA204.W
		RTS


Draw_object:
		MOVE.L	Logic,A0
		BSR	Handle_Object_World
		RTS


;--------------------------------------------------------------

	IFEQ Bitplane_Mode
ReptVal EQU ((Object_Width*2)/13/4)+1

ClearScreen:
		MOVE.L	logic,A6
		ADD.L	#(Lines+Object_Height-1)/2*BytesPerLine,A6
		LEA	(2*(Pixels+Object_Width)/2)(A6),A6

		MOVE.L	#$08410841*0,D1
		MOVE.L	D1,D2
		MOVE.L	D1,D3
		MOVE.L	D1,D4
		MOVE.L	D1,D5
		MOVE.L	D1,D6
		MOVE.L	D1,D7
		MOVE.L	D1,A0
		MOVE.L	D1,A1
		MOVE.L	D1,A2
		MOVE.L	D1,A3
		MOVE.L	D1,A4
		MOVE.L	D1,A5

		MOVE.L	#$0001,D0
		MOVEC	D0,CACR

		MOVE.W	#Object_Height-1,D0
.Wipe:		REPT	ReptVal
		MOVEM.L	D1-A5,-(A6)
		ENDR
		LEA	-(BytesPerLine)+(13*4*Reptval)(A6),A6
		DBF	D0,.Wipe

		MOVE.L	#$1919,D0
		MOVEC	D0,CACR
		RTS
	ENDC

;--------------------------------------------------------------
Spin_Object:
	IFNE Keys
		BSR	Handle_Keyboard
	ELSE
		MOVEM.L	Rotation_X,D0/D1/D2
		ADD.L	#0*1,D0
		ADD.L	#65*1,D1
		ADD.L	#0*1,D2
		MOVEM.L	D0/D1/D2,Rotation_X
	ENDC

		RTS


MakeMatrixObject:
		MOVEM.L	Rotation_X,D0/D1/D2
		MOVE.L	#"MAT",D7
		BRA.S	DoMatrix
MakeMatrixLight:
		MOVEM.L	Rotation_X,D0/D1/D2
		;MOVEM.L	LightRot_X,D0/D1/D2
		MOVE.L	#"LIG",D7
; Expansion to allow fading using the unit_vector?

DoMatrix:
		AND.L	#$1FFF,D0
		AND.L	#$1FFF,D1
		AND.L	#$1FFF,D2
		LEA	CosTable,A0
		LEA	SineTable,A1
		JSR	Wait_SendDsp
		MOVE.L	D7,$FFFFA204.W
		MOVEQ	#0,D7
		MOVE.W	(A0,D0.W*2),D7
		BSR.S	SendInfo
		MOVE.W	(A1,D0.W*2),D7
		BSR.S	SendInfo
		MOVE.W	(A0,D1.W*2),D7
		BSR.S	SendInfo
		MOVE.W	(A1,D1.W*2),D7
		BSR.S	SendInfo
		MOVE.W	(A0,D2.W*2),D7
		BSR.S	SendInfo
		MOVE.W	(A1,D2.W*2),D7
		BSR.S	SendInfo
		RTS
SendInfo:
		EXT.L	D7
		ASL.L	#8,D7
		 wait_transmit
		MOVE.L	D7,$FFFFA204.W
		RTS

Send_Viewpoint:
		LEA	$FFFFA204.W,A1
		LEA	viewer_x,A2
		 wait_transmit
		MOVE.L	#"VIE",(A1)
		MOVEQ	#3-1,D0			;for view pos
.loop:
		MOVE.L	(A0)+,D1
		ADD.L	(A2)+,D1
		wait_transmit
		MOVE.L	D1,(A1)

		DBF	D0,.loop

		 wait_transmit
		MOVE.L	Viewer_Distance,(A1)
		 wait_transmit
		MOVE.L	Viewer_Size,(A1)
		RTS










;
;
;		BITPLANE ROUTINES
;
;
;

	IFNE	Bitplane_Mode
;--------------------------------------------------------------
	ifne 0
Fetch_Bitplane_Screen:
		MOVE.L	#$0009,D0
		MOVEC	D0,CACR
		wait_transmit
		MOVE.L	#"SCR",$FFFFA204.W	;already done

		LEA	$FFFFA206.W,A3
		MOVE.L	logic,A2
		MOVEQ	#0,D2
		MOVE.W	#(9600/16)/2-1,D7

		wait_receive
		 MOVE.W	(A3),D0		;dummy
		wait_receive

O		SET	0
Loop1:
		REPT	16
		MOVE.W	(A3),(A2)+
		MOVE.W	(A3),(A2)+
		NOP
		MOVE.W	(A3),(A2)+
		ADDQ.L #2,A2
		ENDR
		DBF	D7,Loop1
		RTS
;
;; Whack on screen
;Draw_World_Bitplane:
;		RTS
	endc

Fetch_Bitplane_Screen:
		MOVE.L	#$0009,D0
		MOVEC	D0,CACR
		wait_transmit
		MOVE.L	#"SCR",$FFFFA204.W	;already done

		LEA	$FFFFA204.W,A1
		LEA	$FFFFA206.W,A3
		LEA	screen_buffer,A2
		MOVEQ	#0,D2
		MOVE.W	#(Lines*2)-1,D7
.Loop1
		wait_receive
		REPT	384/8/2
		 MOVE.L	(A1),(A2)+
		 nop
		ENDR
		DBF	D7,.Loop1
		RTS

; Whack on screen
Draw_World_Bitplane:
		MOVE.L	#$0009,D0
		MOVEC	D0,CACR
		MOVE.L	Logic,A0
		SUBQ.L	#2,A0			; convert to 00xxyyzz
						; of MOVEP transfer
		LEA	screen_buffer,A1
		MOVEQ	#0,D2
		MOVE.W	#Lines*2-1,D7
.Loop1
o		SET	0
		REPT	(384/8/4)/2
		 MOVEM.L (A1)+,D0/D1/D2/D3
		 MOVEP.L D0,o(A0)
		 MOVEP.L D1,o+1(A0)
		 MOVEP.L D2,o+8(A0)
		 MOVEP.L D3,o+9(A0)
O		SET O+16
		ENDR
		LEA	BytesPerLine/2(A0),A0

		DBF	D7,.Loop1
		;MOVE.L	#$1919,D0
		;MOVEC	D0,CACR
		RTS

	ENDC






;
;
;
;		TRUE COLOUR ROUTINES
;
;
;








;--------------------------------------------------------------
Handle_Object_World:
		ADD.L	#(Pixels/2)*2+BytesPerLine*(Lines/2),A0
		MOVE.L	A0,Screen_Centre
		MOVE.L	#$0009,D0
		MOVEC	D0,CACR

		LEA	$FFFFA206.W,A1
		LEA	$FFFFA202.W,A2
		MOVE.L	#BytesPerLine,D7
		MOVE.L	Screen_Centre,A4
		MOVEQ	#0,D0
		MOVEQ	#0,D2
HandleLoop
		wait_transmit
		MOVE.L	#"GET",$FFFFA204.W
.wr2:
		wait_receive
		 MOVE.W	(A1),D0
		 BMI Done
		 JMP .polylist(PC,D0.W*4)
.polylist:
		BRA.W	get_flat		;0
		BRA.W	get_flat		;1
		BRA.W	get_gouraud		;2
		BRA.W	get_texmap		;3
get_flat:
		 wait_receive
		 MOVE.W	(A1),D6			;get top_height
		 MULS.W	D7,D6
		 LEA	(A4,D6.L),A0

		 wait_receive
		 MOVE.W	(A1),D1
		 SUBQ.W	#1,D1			;poly height
		 BLT	Dontdo

		 wait_receive
		 MOVE.W	(A1),D4			;D4 - colour
		 MOVE.W	D5,D4
		 SWAP	D4
		 MOVE.W	D5,D4
.printpoly2:
		  MOVE.W (A1),D2
		  LEA	(A0,D2.W*2),A3
		  MOVEQ	#0,D5
		  MOVE.W (A1),D3
		  ASR.W	#1,D3
		  BCC.S	.next3
		  MOVE.W D4,(A3)+
.next3	  	SUBQ.W #1,D3
		  BMI.S	.next2
.PP2		   MOVE.L D4,(A3)+
		  DBRA	D3,.PP2
.next2		  ADD.L D7,A0
		 DBF	D1,.printpoly2
		BRA	HandleLoop

get_gouraud:
		BRA	HandleLoop

get_texmap:
		 wait_receive
		 MOVE.W	(A1),D6			;get top_height
		 MULS.W	D7,D6
		 LEA	(A4,D6.L),A0
		 MOVE.W	(A1),D1
		 SUBQ.W	#1,D1
		 BMI.S	.Dontdo
.printpoly:
		  wait_receive
		  MOVE.W (A1),D2
		  LEA (A0,D2.W*2),A3	
		  MOVE.W (A1),D3
		  SUBQ.W #1,D3
		  BMI.S	.next
		  wait_receive
.PP	   	MOVE.W (A1),(A3)+
		  DBRA	D3,.PP
.next	  	ADD.L D7,A0
		 DBF	D1,.printpoly
.dontdo		BRA	HandleLoop
Done:
		MOVE.L	#$1919,D0
		MOVEC	D0,CACR
		RTS
Dontdo		ILLEGAL










;--------------------basic i/o routines------------------------
max_width=384

SendOneOver
		LEA	$FFFFA204.W,A6
		 wait_transmit
		MOVEQ	#0,D0
.sendy:
		MOVE.L	#$7FFFFF,D1
		TST.W	D0
		BEQ	.skipdiv
		DIVU.L	D0,D1
.skipdiv
		 wait_transmit
		MOVE.L	D1,(A6)
		ADDQ.L	#1,D0
		CMP.W	#max_width,D0
		bne.s .sendy
		RTS

;--------------------------------------------------------------
Send_Object:
		JSR	Wait_SendDsp
		MOVE.L	#"OBJ",$FFFFA204.W

		MOVE.L	(A0)+,D0
		 wait_transmit
		MOVE.L	D0,$FFFFA204.W
		SUBQ.L	#1,D0
.SendPoints:
		 wait_transmit		; not time-critical!
		MOVE.L	(A0)+,$FFFFA204.W
		DBF	D0,.SendPoints
		RTS

;--------------------------------------------------------------
	IFNE	Mapping_Mode
Send_Texmap:
		LEA	Texmap_Buffer,A0
		JSR	Wait_SendDsp
		MOVE.L	#"TEX",$FFFFA204.W
		MOVE.L	#64*64,D0
		 wait_transmit
		MOVE.L	D0,$FFFFA204.W
		SUBQ.L	#1,D0
.SendPoints:
		 wait_transmit		; not time-critical!
		MOVE.W	(A0)+,$FFFFA206.W
		DBF	D0,.SendPoints
		RTS
	ENDC

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

;--------------------------------------------------------------
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

movespeed	equ 16*2
movespeed2	equ $40

Keyboard_Tests:
		DC.L	$02,+movespeed2,viewer_x
		DC.L	$03,-movespeed2,viewer_x

		DC.L	$67,+movespeed,rotation_x
		DC.L	$6a,-movespeed,rotation_x
		DC.L	$68,+movespeed,rotation_y
		DC.L	$6B,-movespeed,rotation_y
		DC.L	$69,+movespeed,rotation_z
		DC.L	$6C,-movespeed,rotation_z

		DC.L	$4E,+movespeed2,Viewer_Distance
		DC.L	$4A,-movespeed2,Viewer_Distance
		DC.L	-1

	ENDC

			RSRESET
object_X		RS.L	1
object_Y		RS.L	1
object_Z		RS.L	1
object_DSpeed	RS.L	1
object_DSize	RS.L	1
object_DOffset	RS.L	1

object_1_Data:
		DC.L	0,0,$200
		DC.L	14,30,0			;speed,size,offset
object_2_Data:
		DC.L	$200,0,0
		DC.L	10,50,0			;speed,size,offset
object_3_Data:
		DC.L	$100,$100,0
		DC.L	-16,-70,0		;speed,size,offset


Set_Res:
	IFNE	Bitplane_Mode
		INCLUDE	F:\DATA\TDF\RES\3DSYS_3P.S
	ELSE
		INCLUDE	F:\DATA\TDF\RES\3DSYS3.S
		OR.W	#$1,$FFFF82C2.W
	ENDC
		RTS


;--------------------------------------------------------------


;--------------------------------------------------------------
screen_swap_three:
		move.l	physic,d0
		move.l	logic,physic
		move.l	third,logic
		move.l	d0,third

		MOVE.L	physic,-(A7)
		MOVE.B	1(A7),$ffff8201.W
		MOVE.B	2(A7),$ffff8203.W
		MOVE.B	3(A7),$ffff820d.W
		ADDQ.L	#4,A7
		RTS




;--------------------------------------------------------------
Init_DSP_Calc:
		BSR	MakeMatrixLight		;Must be done FIRST
		BSR	MakeMatrixObject
		JSR	Wait_SendDsp
		MOVE.L	#"CAL",$FFFFA204.W
		wait_transmit
		MOVE.L	#"HAN",$FFFFA204.W
		RTS




;
;
;
;	MOTION BLUR SECTION
;
;
;
;

	IFNE	Motion_Blur_Mode

MoveAndFade
		BSR	Init_DSP_Calc
		BSR	MotionBlurScreen
		BSR	Handle_Object_World
		BSR	screen_swap
		RTS

Handle_Object_Blur:
		MOVE.L	third,A0
		ADD.L	#192*2+BytesPerLine*(Lines/2),A0
		MOVE.L	A0,Screen_Centre
		MOVE.L	#$0019,D0
		MOVEC	D0,CACR

		LEA	$FFFFA206.W,A1
		LEA	$FFFFA202.W,A2
		MOVE.L	#BytesPerLine,D7
		MOVE.L	Screen_Centre,A4
		MOVEQ	#0,D0
		MOVEQ	#0,D2
.HandleLoop
		wait_transmit
		MOVE.L	#"GET",$FFFFA204.W
.wr2:
		wait_receive
		 MOVE.W	(A1),D0
		 BMI Done
		 JMP .polylist(PC,D0.W*4)
.polylist:
		BRA.W	.get_flat		;0
		BRA.W	.get_flat		;1
		BRA.W	.get_gouraud		;2
		BRA.W	.get_texmap		;3
.get_gouraud:
.get_flat:
		BRA	HandleLoop
; Routine does not appear to be getting *enough* data out
.get_texmap:
		 wait_receive
		 MOVE.W	(A1),D6			;get top_height
		 MULS.W	D7,D6
		 LEA	(A4,D6.L),A0
		 MOVE.W	(A1),D1
		 SUBQ.W	#1,D1
		 ;BMI.S	Dontdo
.printpoly:
		  wait_receive
		  MOVE.W (A1),D2
		  LEA (A0,D2.W*4),A3
		  MOVE.W (A1),D3
		  SUBQ.W #1,D3
		  BMI.S	.next
		  wait_receive
.PP	  MOVE.W (A1),D0
		  ADD.W	D0,(A3)
		  ADDQ.L #4,A3
		  DBRA	D3,.PP
.next	  ADD.L D7,A0
		 DBF	D1,.printpoly
.dontdo	BRA	.HandleLoop
.Done:
		RTS


;--------------------------------------------------------------

Send_Blur_Texmap:
		LEA	Texmap_Buffer,A0
		JSR	Wait_SendDsp
		MOVE.L	#"TEX",$FFFFA204.W
		MOVE.L	#64*64,D0
		 wait_transmit
		MOVE.L	D0,$FFFFA204.W
		SUBQ.L	#1,D0
.SendPoints:
		 wait_transmit		; not time-critical!
		MOVE.W	(A0)+,D1
		LSR.W	#2,D1
		AND.W	#%0011100111100111,D1
		MOVE	D1,$FFFFA206.W
		DBF	D0,.SendPoints
		RTS

;--------------------------------------------------------------
Calc_Tables:
		BSR	Calc_Colour_Table
		RTS

;--------------------------------------------------------------
; We can do the tables in a much easier manner:
Calc_Colour_Table:
		LEA	Colour_Table,A0
		MOVEQ	#32-1,D7		;red count
		LEA	Feedback_Table_Red,A1
.CalcLoop1:
		MOVE.W	(A1)+,D1
		MOVEQ	#32-1,D6		;green count
		LEA	Feedback_Table_Green,A2
.CalcLoop2:
		MOVE.W	(A2)+,D2
		OR.W	D1,D2
		MOVEQ	#64-1,D5		;blue count * 2...green bottom not used!
		LEA	Feedback_Table_Blue,A3
.CalcLoop3:
		MOVE.W	(A3)+,D3
		OR.W	D2,D3
		MOVE.W	D3,(A0)+
		DBF	D5,.CalcLoop3
		DBF	D6,.CalcLoop2
		DBF	D7,.CalcLoop1
		RTS

;--------------------------------------------------------------
Feed	MACRO
		  IFEQ Direction
			DC.W	\1*00,\1*00		;,\1*00,\1*00
			DC.W	\1*01,\1*02,\1*03,\1*04
			DC.W	\1*05,\1*06,\1*07,\1*08
			DC.W	\1*09,\1*10,\1*11,\1*12
			DC.W	\1*13,\1*14,\1*15,\1*16
			DC.W	\1*17,\1*18,\1*19,\1*20
			DC.W	\1*21,\1*22,\1*23,\1*23
			DC.W	\1*23,\1*23,\1*23,\1*23
			DC.W	\1*23,\1*23		;,\1*23
		  ELSE	
			DC.W	\1*12,\1*12
			DC.W	\1*12,\1*12,\1*12,\1*12
			DC.W	\1*12,\1*12,\1*12,\1*12
			DC.W	\1*12,\1*13,\1*14,\1*15
			DC.W	\1*16,\1*17,\1*18,\1*19
			DC.W	\1*20,\1*21,\1*22,\1*23
			DC.W	\1*24,\1*24,\1*25,\1*26
			DC.W	\1*27,\1*28,\1*29,\1*30
			DC.W	\1*30,\1*30		;,\1*31,\1*31
		  ENDC
		ENDM


Feedback_Table_Red:
		Feed	$0800
Feedback_Table_Green:
		Feed	$0040
Feedback_Table_Blue:
		Feed	$0001
		Feed	$0001

;--------------------------------------------------------------
MotionBlurScreen:
		MOVE.L	#$0019,D0
		MOVEC	D0,CACR

		MOVE.L	third,A0
		MOVE.L	logic,A1

		add.l	#BytesPerLine*2,a0
		add.l	#BytesPerLine*2+4,a1

		LEA.L	Colour_Table,A2

		MOVE.W	#100-4-1,D0
		MOVEQ	#0,D4
.Feedbackloop1:
		MOVE.W	#(192/4)-1,D3
		Ifeq	Direction
		 MOVEQ	#0,D2
		Else
		 MOVEQ	#-1,D2
		Endc
.Feedbackloop2:
		REPT	4
		 move.w	(a1),d4
		 MOVE.W	(A2,D4.L*2),D2
		 MOVE.L	D2,(A0)+
		 SWAP	D2
		 ADDQ.L	#4,a1
		ENDR
		DBF	D3,.Feedbackloop2
		DBF	D0,.Feedbackloop1
		RTS

	ENDC

;
;
;
;
;			INFO PRINT SECTION
;
;
;
;
;


	IFEQ	Bitplane_Mode
Draw_Logo:
		MOVE.L	Logic,A0
		LEA	Logo,A1
		MOVEQ	#5-1,D0
.loop1:		MOVEQ	#(32)-1,D1
.loop2:
		MOVE.W	(A1)+,D2
		OR.W	D2,(A0)+
		DBF	D1,.loop2
		LEA	BytesPerLine-32*2(A0),A0
		DBF	D0,.loop1
		RTS





Draw_Hex_Number:
		moveq	#8-1,d7
.hexloop:	
		rol.l	#4,d0
		move.l	d7,-(a7)
		bsr	Draw_Hex_Byte
		move.l	(a7)+,d7
		dbf	d7,.hexloop
		rts


Draw_Hex_Byte:
		movem.l	d0/d1/d2,-(a7)
		and.w	#$f,d0

		mulu.w	#BytesPerLine*6,d2
		move.l	logic,a0
		add.l	d2,a0
		lea	(a0,d1.w*2),a0

		mulu.w	#3*5*2,d0
		lea	(Numbers_Data.l,d0.l),a1

		bsr	draw_3x5

		movem.l	(a7)+,d0/d1/d2
		addq.w	#4,d1			;x coord
		rts

draw_3x5:
		MOVEQ	#5-1,D0
.loop1:		MOVEQ	#3-1,D1
.loop2:		MOVE.W	(A1)+,D2
		OR.W	D2,(A0)+
		DBF	D1,.loop2
		LEA	BytesPerLine-3*2(A0),A0
		DBF	D0,.loop1
		RTS


Draw_Info:
		lea	info_list,a0
.info_loop:
		movem.l	(a0)+,d0/d1/d2
		tst.l	d0
		bmi.s	.done

		move.l	d0,a1
		move.l	(a1),d0

		pea	(a0)
		bsr	Draw_Hex_Number
		move.l	(a7)+,a0
		bra	.info_loop
.done:		rts

info_list:
		dc.l	Viewer_X,$0000,$0001
		dc.l	Viewer_Y,$0000,$0002
		dc.l	Viewer_Z,$0000,$0003

		dc.l	Viewer_Distance,$0000,$0005

		dc.l	Rotation_X,$0000,$0006
		dc.l	Rotation_Y,$0000,$0007
		dc.l	Rotation_Z,$0000,$0008
		dc.l	-1
	ENDC


;--------------------------------------------------------------
	IFNE	Bitplane_Mode
Set_Palette:
		LEA	$FFFF9800.W,A0
		MOVE.L	#$d0B000d0,(A0)+
		MOVE.L	#$D8c200d4,(A0)+
		MOVE.L	#$F8F800e0,(A0)+
		MOVE.L	#$E8e400dc,(A0)+
		RTS
	ENDC
;--------------------------------------------------------------

	IFNE Animation_Mode
Animate_Init:
		LEA	$FFFFA204.W,A0
		 wait_transmit
		MOVE.L	#"A_I",(A0)
		MOVE.L	#200,D0			;must be less than
						;maximum_points
		MOVEQ	#0,D1
		 wait_transmit
		MOVE.L	D0,(A0)			;point count

		MULU.W	#3,D0			;x,y,z
		SUBQ.W	#1,D0			;(for dbf)
.ai_loop:
		 wait_transmit
		MOVE.L	D1,(A0)
		ADDQ.L	#1,D1
		CMP.L	#9,D1
		BLT.S	.no
		MOVEQ	#-9,D1
.no:		DBF	D0,.ai_loop
		RTS

Animate_Object:
		LEA	$FFFFA204.W,A0
		 wait_transmit
		MOVE.L	#"A_O",(A0)
		 wait_transmit
		MOVE.L	Animate_Data_1(PC),(A0)		;size
		RTS

Animate_Data_1:	DC.L	0
	ENDC
;--------------------------------------------------------------
			SECTION DATA
;--------------------------------------------------------------

Rotation_X:		DC.L	$0200
Rotation_Y:		DC.L	$0000
Rotation_Z:		DC.L	$0000
LightRot_X:		DS.L	1
LightRot_Y:		DS.L	1
LightRot_Z:		DS.L	1

Viewer_X:		DS.L	1
Viewer_Y:		DS.L	1
Viewer_Z:		ds.L	1
Viewer_Distance:	DC.L	$80000
Viewer_Size:		DC.L	200000

Current_object:		DC.L	0




;--------------------------------------------------------------
;	MISCELLANEOUS DATA
;--------------------------------------------------------------
			CNOP	0,4
SineTable:		INCBIN	f:\data\trailsin.dat
CosTable:		EQU	SineTable+2048*2
			EVEN

	IFEQ	Bitplane_Mode
Numbers_Data:		INCLUDE	F:\SOURCE\TDF\NUMBER.S
			EVEN
	ENDC

;--------------------------------------------------------------
;	DSP ROUTINES
;--------------------------------------------------------------

Dsp_Routine_object:
		IFNE Bitplane_Mode
			;INCBIN	F:\Dsp_New\Dsp\Gen_3pl.Dsp
			INCBIN	F:\Dsp_New\Dsp\In_Room.Dsp
		ELSE
			INCBIN	F:\Dsp_New\Dsp\Gen_Obj.Dsp
		ENDC
			EVEN


;--------------------------------------------------------------
;	3D OBJECTS
;--------------------------------------------------------------

object_Object:
		IFNE Bitplane_Mode
			INCLUDE F:\DATA\TDF\inroom.Ob3
		ELSE
			INCLUDE F:\DATA\TDF\newh.Ob3
		ENDC
			EVEN

;--------------------------------------------------------------
;	GRAPHICS
;--------------------------------------------------------------

	IFEQ	Bitplane_Mode
Texmap_Buffer		EQU	*+6
			INCBIN	'F:\Data\Tdf\Gfx\Envmap2.God'
			EVEN

Logo:			EQU	*+6
			INCBIN	'F:\Data\Tdf\Gfx\Avena.God'
	ENDC


;--------------------------------------------------------------
			SECTION	BSS
			CNOP	0,4
Scan_min		DS.L	1
Scan_max		DS.L	1
Screen_Centre		DS.L	1

		IFNE	Bitplane_Mode
Screen_Buffer		DS.L	9600
		ENDC

		IFNE	Motion_Blur_Mode
Colour_Table		DS.W	65536
		ENDC

			DS.L	300
stack:





