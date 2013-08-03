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
Keys			EQU	1
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

Direction		EQU	1		;(Motion Blur)
numframes		equ	25






Back_Colour	EQU	0*$08410841
noscreens	EQU	3
Demo		EQU	0




start:

	IFNE	Demo
		INCLUDE	F:\Source\Tdf\Main\Equates.S
		output	c:\_demo\data\avena.prg
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
		RTS

Do_Effects:
		;init_screens

		bsr	Set_res

	; init the dsp routine first
		init_dsp_routine Dsp_Routine_object,$210.W
		JSR	SendOneOver

		move.w	#-1,Texmap_Buffer_1+64*2*32+32*2

		MOVE.W	#$2300,SR
.hang
		MOVE.W	#numframes-1,D0
		lea	object_a,a0
		lea	texmap_buffer_1,a1
		BSR	Main_Loop
		bra.s	.hang
		RTS

Main_Loop:
		move.l	a0,which_object
		move.l	a1,which_texture

		move.l	d0,-(a7)

		move.l	#$800,object_2_data+object_z

		move.l	which_object,A0
		JSR	Send_Object
		move.l	which_texture,a0
		JSR	Send_Texmap

		move.l	(a7)+,d0
.Main_Loop
		MOVE.W	D0,-(A7)
		BSR	Create_Frame
		MOVE.W	(A7)+,D0
		DBF	D0,.Main_Loop
		RTS


Create_Frame:
		JSR	Spin_Object
		LEA	Object_1_Data,A0
		BSR	Start_One_object
		BSR	Draw_object
		;LEA	object_2_Data,A0
		;add.l	#$2,object_roty(a0)
		;sub.l	#$40,object_rotz(a0)
		;sub.l	#$40,object_z(a0)
		;BSR	Start_One_object
		;BSR	Draw_object

		BSR	screen_swap
		RTS



Start_One_object:
		MOVE.L	A0,Current_object

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
Spin_Object:
		MOVEM.L	LightRot_X,D0/D1/D2
		ADD.L	#0*15,D0
		ADD.L	#1*15,D1
		SUB.L	#3*15,D2
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
;		 JMP .polylist(PC,D0.W*4)
;.polylist:
;		BRA.W	get_flat		;0
;		BRA.W	get_flat		;1
;		BRA.W	get_gouraud		;2
;		BRA.W	get_texmap		;3

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
object_DSpeed		RS.L	1
object_DSize		RS.L	1
object_DOffset		RS.L	1
object_number		RS.L	1

object_1_Data:
		DC.L	0,0,0
		dc.l	0,0,0
		DC.L	14,30,0			;speed,size,offset
		DC.L	0
object_2_Data:
		DC.L	0,0,$600
		dc.l	0,0,0
		DC.L	10,50,0			;speed,size,offset
		DC.L	0


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

;--------------------------------------------------------------


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

		include	3dsys\view.s

;--------------------------------------------------------------
			SECTION DATA
;--------------------------------------------------------------

Rotation_X:		DC.L	$0000
Rotation_Y:		DC.L	$0000
Rotation_Z:		DC.L	$0000
LightRot_X:		DS.L	1
LightRot_Y:		DS.L	1
LightRot_Z:		DS.L	1

Viewer_X:		DS.L	1
Viewer_Y:		DS.L	1
Viewer_Z:		ds.L	1

camera_x:		dc.l	0
camera_y:		dc.l	0
camera_z:		
Viewer_Distance:	DC.L	$200
Viewer_Size:		DC.L	8000

Current_object:		DC.L	0
which_object		ds.l	1
which_texture		ds.l	1


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
		IFNE Bitplane_Mode
			;INCBIN	F:\Dsp_New\Dsp\Gen_3pl.Dsp
			INCBIN	F:\Dsp_New\Dsp\In_Room.Dsp
		ELSE
			INCBIN	F:\Dsp_New\Dsp\GEN_OBJ.Dsp
		ENDC
			EVEN


;--------------------------------------------------------------
;	3D OBJECTS
;--------------------------------------------------------------

object_a:	INCLUDE f:\DatA\tdf\Ob3\envtool.Ob3
		EVEN

;--------------------------------------------------------------
;	GRAPHICS
;--------------------------------------------------------------

Texmap_Buffer_1		EQU	*+6
			INCBIN	'c:\_data\_gfx\test2.God'
			EVEN
Texmap_Buffer_2		EQU	*+6
			incbin	f:\data\tdf\gfx\envmap5.god
			;INCBIN	'c:\_data\_gfx\ntmap5.God'
			;INCBIN	'c:\_data\_gfx\tmap6.God'
			EVEN


;--------------------------------------------------------------
			SECTION	BSS
			CNOP	0,4
Scan_min		DS.L	1
Scan_max		DS.L	1
Screen_Centre		DS.L	1

		IFNE	Bitplane_Mode
Screen_Buffer		DS.L	9600
		ENDC

			DS.L	300
stack

