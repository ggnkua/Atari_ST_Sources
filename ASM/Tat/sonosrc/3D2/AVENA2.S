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
Morphing_Mode		EQU	0

xmax			EQU	383
ymax			EQU	099

movespeed		equ 16*4
movespeed2		equ $40


ScreenLines		EQU	140*2
BytesPerLine		EQU	320
Lines			EQU	140*2
Pixels			EQU	160

Object_Width		EQU	160
Object_Height		EQU	140*2

Direction		EQU	1		;(Motion Blur)







Back_Colour	EQU	0*$08410841
noscreens	EQU	3
Demo		EQU	0





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
		bsr	Set_res
		RTS

Do_Effects:
		BSR	Calc_Tables
		BSR	Set_Palette
		BSR	ClearScreens

		MOVE.W	#$2300,SR
.infinite:
		MOVE.W	#250-1,D0
		lea	object_a,a0
		BSR	Main_Loop
		;bra	.infinite

		MOVE.W	#34-1,D0
		BSR	Main_Loop2
		JSR	Wait_SendDSP
		MOVE.L	#"RTS",$FFFFA204.W
		RTS

Main_Loop:
		move.l	a0,which_object
		move.l	d0,-(a7)

		init_dsp_routine Dsp_Routine_object,$210.W

		JSR	SendOneOver
	IFNE	Mapping_Mode
		JSR	Send_Texmap
	ENDC

		move.l	which_object,A0
		JSR	Send_Object

	IFNE Animation_Mode
		JSR	Animate_Init
		JSR	Animate_Object		;(once)
	ENDC

	IFNE Morphing_Mode
		JSR	Morph_Init
		JSR	Morph_Object
	ENDC

		move.l	(a7)+,d0
.Main_Loop
		MOVE.W	D0,-(A7)
		BSR	Create_Frame
		MOVE.W	(A7)+,D0
		DBF	D0,.Main_Loop
		RTS

Main_Loop2:
		MOVE.W	D0,-(A7)
		;SUB.L	#10,Viewer_Distance
		;ADD.L	#10,rotadd1
		;ADD.L	#10,rotadd2
		;ADD.L	#20,rotadd3
		BSR	Fade_Table
		BSR	Create_Frame

		MOVE.W	(A7)+,D0
		DBF	D0,Main_Loop2
		RTS

Create_Frame:
		JSR	Spin_Object
		LEA	object_1_Data,A0
		BSR	Start_One_object
		BSR	ClearScreen
		BSR	Draw_object
		;BSR	Draw_Info
		BSR	screen_swap
		RTS



Start_One_object:
		MOVE.L	A0,Current_object

	IFNE Animation_Mode
		BSR	animate_object
	ENDC

	IFNE Morphing_Mode
		BSR	Morph_object
	ENDC

		MOVE.L	Current_object,A0
		BSR	Send_Viewpoint
		BSR	MakeMatrixLight		;Must be done FIRST
		BSR	MakeMatrixObject
		wait_transmit
		MOVE.L	#"CAL",$FFFFA204.W

		MOVE.L	Current_object,A0
		wait_transmit
		MOVE.L	#"HA1",$FFFFA204.W
		wait_transmit
		move.l	Object_number(a0),$ffffa204.w	;go
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

		MOVE.L	Texmap_Buffer,D1
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
rotadd1 = *+2
		ADD.L	#0*5,D0
rotadd2 = *+2
		ADD.L	#0*5,D1
rotadd3 = *+2
		ADD.L	#-3*15,D2
		MOVEM.L	D0/D1/D2,Rotation_X
	ENDC

		MOVEM.L	LightRot_X,D0/D1/D2
		ADD.L	#2*15,D0
		ADD.L	#5*15,D1
		ADD.L	#3*15,D2
		MOVEM.L	D0/D1/D2,LightRot_X

		RTS


MakeMatrixObject:
		MOVEM.L	Rotation_X,D0/D1/D2
		move.l	current_object,a0
		add.l	object_rotx(a0),d0
		add.l	object_roty(a0),d1
		add.l	object_rotz(a0),d2
		MOVE.L	#"MAT",D7
		BRA.S	DoMatrix
MakeMatrixLight:
		MOVEM.L	LightRot_X,D0/D1/D2
		move.l	current_object,a0
		add.l	object_rotx(a0),d0
		add.l	object_roty(a0),d1
		add.l	object_rotz(a0),d2
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










;
;
;
;		TRUE COLOUR ROUTINES
;
;
;








;--------------------------------------------------------------
Handle_Object_World:
		ADD.L	#+BytesPerLine*(Lines/2),A0
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
		include	3dsys\keys.s

			RSRESET
object_X		RS.L	1
object_Y		RS.L	1
object_Z		RS.L	1
object_rotx		rs.l	1
object_roty		rs.l	1
object_rotz		rs.l	1
object_DSpeed	RS.L	1
object_DSize	RS.L	1
object_DOffset	RS.L	1
object_number	RS.L	1

object_1_Data:
		DC.L	0,0,0
		dc.l	0,0,0
		DC.L	14,30,0			;speed,size,offset
		DC.L	0			;number
object_2_Data:
		DC.L	0,0,$600
		dc.l	0,0,0
		DC.L	10,50,0			;speed,size,offset
		DC.L	0


Set_Res:
		INCLUDE	F:\DATA\TDF\RES\3DSYS_TH.S
		and.w #$fffe,$ffff82c2.w
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

;--------------------------------------------------------------
Calc_Tables:
		BSR	Calc_Colour_Table
		RTS

Fade_Table:
		LEA	Texmap_Buffer,A0
		LEA	Colour_Table,A1
		JSR	Wait_SendDsp
		MOVE.L	#"TEX",$FFFFA204.W
		MOVE.L	#64*64,D0
		 wait_transmit
		MOVE.L	D0,$FFFFA204.W

		MOVEQ	#0,D1
		LEA	$FFFFA206.W,A2
		SUBQ.L	#1,D0
.SendPoints:
		MOVE.W	(A0),D1
		MOVE.W	(A1,D1.L*2),D2
		MOVE.W	D2,(A2)
		MOVE.W	D2,(A0)+
		DBF	D0,.SendPoints
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
			DC.W	\1*01,\1*02,\1*03
			DC.W	\1*04,\1*05,\1*06,\1*07
			DC.W	\1*08,\1*09,\1*10,\1*11
			DC.W	\1*12,\1*13,\1*14,\1*15
			DC.W	\1*16,\1*17,\1*18,\1*19
			DC.W	\1*20,\1*21,\1*22,\1*23
			DC.W	\1*24,\1*25,\1*26,\1*27
			DC.W	\1*28,\1*29,\1*30
			DC.W	\1*31,\1*31
		  ENDC
		ENDM
; Should go up slowly, then quicker

Feedback_Table_Red:
		Feed	$0800
Feedback_Table_Green:
		Feed	$0040
Feedback_Table_Blue:
		Feed	$0001
		Feed	$0001



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


;--------------------------------------------------------------
Set_Palette:
	IFNE Bitplane_Mode
		LEA	$FFFF9800.W,A0
		MOVE.L	#$d0B000d0,(A0)+
		MOVE.L	#$D8c200d4,(A0)+
		MOVE.L	#$F8F800e0,(A0)+
		MOVE.L	#$E8e400dc,(A0)+
	ELSE
	ENDC
		LEA	$FFFF9800.W,A0
		MOVE.L	#0,(A0)+
		RTS
;--------------------------------------------------------------

		include	3dsys\view.s
		include	3dsys\animate.s
		;include	3dsys\text.s
		;include	3dsys\morph.s


;--------------------------------------------------------------
			SECTION DATA
;--------------------------------------------------------------

Rotation_X:		DC.L	$1000
Rotation_Y:		DC.L	$0a00
Rotation_Z:		DC.L	$0000
LightRot_X:		DS.L	1
LightRot_Y:		DS.L	1
LightRot_Z:		DS.L	1

Viewer_X:		DS.L	1
Viewer_Y:		DS.L	1
Viewer_Z:		dc.l	$400

camera_x:		dc.l	0
camera_y:		dc.l	0
camera_z:		
Viewer_Distance:	DC.L	$800
Viewer_Size:		DC.L	8000

Current_object:		DC.L	0
which_object		ds.l	1


;--------------------------------------------------------------
;	MISCELLANEOUS DATA
;--------------------------------------------------------------
			CNOP	0,4
SineTable:		INCBIN	f:\data\trailsin.dat
CosTable:		EQU	SineTable+2048*2
			EVEN

;--------------------------------------------------------------
;	DSP ROUTINES
;--------------------------------------------------------------

Dsp_Routine_object:
			INCBIN	F:\Dsp_New\Dsp\Avena.Dsp
			EVEN


;--------------------------------------------------------------
;	3D OBJECTS
;--------------------------------------------------------------

object_a:	INCLUDE c:\_DatA\_Ob3\avena\avena.Ob3
		EVEN

;--------------------------------------------------------------
;	GRAPHICS
;--------------------------------------------------------------

		IFEQ	Bitplane_Mode
Texmap_Buffer		EQU	*+6
			INCBIN	'c:\_data\_gfx\tmap3inv.God'
			;INCBIN	'F:\Data\Tdf\Gfx\Envmap2.God'
			EVEN

		ENDC


;--------------------------------------------------------------
			SECTION	BSS
			CNOP	0,4
Scan_min		DS.L	1
Scan_max		DS.L	1
Screen_Centre		DS.L	1

Colour_Table		DS.W	65536


			DS.L	300
stack

