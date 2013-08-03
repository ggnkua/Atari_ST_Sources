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
Texmap_Mode		EQU	1
Motion_Blur_Mode	EQU	0
Animation_Mode		EQU	0
Morphing_Mode		EQU	1
Shademap_Mode		EQU	0
Shademap_Mode2		EQU	0
Sequence_Mode		equ	1

xmax			EQU	383
ymax			EQU	099


ScreenLines		EQU	100
BytesPerLine		EQU	768
Lines			EQU	100
Pixels			EQU	384

Object_Width		EQU	384
Object_Height		EQU	100

Back_Colour		EQU	($4+$40*4)
noscreens		EQU	3
Demo			EQU	1





start:

	IFNE	Demo
		INCLUDE	F:\Source\Tdf\Main\Equates.S
		output	c:\_demo\data\MHed.prg
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
	IFNE	Shademap_Mode
		JSR	Calc_Textures
	ENDC

		RTS


Do_Effects:
		move.l	#$3000,viewer_distance
		ifne	demo		
		init_screens
		endc

		init_dsp_routine Dsp_Routine_object,$210.W
		JSR	SendOneOver

		LEA	object_Object,A0
		JSR	Send_Object
		lea	envmap_buffer,a0
		jsr	send_texmap


	IFNE	Sequence_Mode
	IFNE	Demo
		move.l	sequence_data,A0
	ELSE
		lea	test_sequence,A0
	ENDC
		bsr	Init_Sequencer
		bsr	sequencer
		bsr	sequence_update_movement
	ENDC

		JSR	Morph_Init

		BSR	Create_Frame
		bsr	wait_vbl
		clr.l	$ffff9800.w
		bsr	Set_res

		BSR	Main_Loop

		wait_transmit
		MOVE.L	#"RTS",$FFFFA204.W

		ifne	demo		
		update_screens
		endc
		RTS

Main_Loop:
		BSR	Create_Frame
		tst.w	sequence_end_flag
		beq	Main_Loop
		RTS

Create_Frame:
	IFNE	Sequence_Mode
		BSR	Sequencer
		BSR	Sequence_Update_Movement
	ENDC

		LEA	object_1_Data,A0
		BSR	Start_One_object
		BSR	ClearScreen
		BSR	Draw_object

		BSR	screen_swap
		RTS



Start_One_object:
		MOVE.L	A0,Current_object
		JSR	Morph_Object
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

MyScreenSize	equ	BytesPerLine*ScreenLines
ReptVal     	equ	(MyScreenSize/13/4/16)
Remainder	equ	(MyscreenSize-(ReptVal*13*4*16))/4

ClearScreen:
		move.l	logic,A6
		add.l	#MyScreenSize,a6

		MOVE.L	#Back_Colour*$10001,D1
._1
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

		MOVE.L	#$0009,D0
		MOVEC	D0,CACR

		MOVE.W	#ReptVal-1,D0
.Wipe:
		rept	16
		movem.l d1-a5,-(A6)
		endr
		DBF	D0,.Wipe

		rept	Remainder
		move.l	d1,-(a6)
		endr
		rts
	ENDC


;--------------------------------------------------------------
;
;
;		TRUE COLOUR ROUTINES
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
	;------------------------------------------------------


		include	3dsys\matrix.s
		include	3dsys\object.s
		include	3dsys\texmap.s

;--------------------------------------------------------------

Set_Res:
		INCLUDE	F:\DATA\TDF\RES\3DSYS3.S
		OR.W	#$1,$FFFF82C2.W
		RTS


;--------------------------------------------------------------
Init_DSP_Calc:
		BSR	MakeMatrixLight		;Must be done FIRST
		BSR	MakeMatrixObject
		wait_transmit
		MOVE.L	#"CAL",$FFFFA204.W
		wait_transmit
		MOVE.L	#"HAN",$FFFFA204.W
		RTS





		RSRESET
object_X	RS.L	1
object_Y	RS.L	1
object_Z	RS.L	1
object_DSpeed	RS.L	1
object_DSize	RS.L	1
object_DOffset	RS.L	1

object_1_Data:
		DC.L	0,0,0
		DC.L	14,30,0			;speed,size,offset
object_2_Data:
		DC.L	$200,0,0
		DC.L	10,50,0			;speed,size,offset
object_3_Data:
		DC.L	$100,$100,0
		DC.L	-16,-70,0		;speed,size,offset


		include	sequence\seq.s		;included anyway!


;--------------------------------------------------------------

		include	3dsys\morph.s

;--------------------------------------------------------------

Viewer_Size		dc.l	10000

Morph_List:
		DC.L	Morph_Points_1
		DC.L	Morph_Points_1
		DC.L	Morph_Points_2
		DC.L	Morph_Points_10
		DC.L	Morph_Points_3
		DC.L	Morph_Points_11
		DC.L	Morph_Points_4
		DC.L	Morph_Points_10
		DC.L	Morph_Points_9
		DC.L	Morph_Points_11
		DC.L	Morph_Points_5
		DC.L	Morph_Points_6
		DC.L	Morph_Points_10
		DC.L	Morph_Points_7
		DC.L	Morph_Points_10
		DC.L	Morph_Points_8
		DC.L	Morph_Points_1
		DC.L	Morph_Points_1
		DC.L	Morph_Points_1
		DC.L	Morph_Points_1
		DC.L	Morph_Points_1
		DC.L	Morph_Points_1
		DC.L	Morph_Points_1

Morph_Points_1:	INCLUDE	c:\_data\_ob3\Mhed1.Ext
Morph_Points_2:	INCLUDE	c:\_data\_ob3\Mhed2.Ext
Morph_Points_3:	INCLUDE	c:\_data\_ob3\Mhed3.Ext
Morph_Points_4:	INCLUDE	c:\_data\_ob3\Mhed4.Ext
Morph_Points_5:	INCLUDE	c:\_data\_ob3\Mhed5.Ext
Morph_Points_6:	INCLUDE	c:\_data\_ob3\Mhed6.Ext
Morph_Points_7:	INCLUDE	c:\_data\_ob3\Mhed7.Ext
Morph_Points_8:	INCLUDE	c:\_data\_ob3\Mhed8.Ext
Morph_Points_9:	INCLUDE	c:\_data\_ob3\Mhed9.Ext
Morph_Points_10: INCLUDE c:\_data\_ob3\Mhed10.Ext
Morph_Points_11: INCLUDE c:\_data\_ob3\Mhed11.Ext

	IFNE	Sequence_Mode
	IFEQ	Demo
test_sequence:
	s_setrot	0,0,0
	s_setrotmov	($c0+20*+$10)/$20,(20*+$10)/$20,$200/$20
	s_setcamera	0,0,$800
	s_setcameramov	0,0,+$1200/$20
	s_wait		$20

	;s_setrot	$c0+20*+$10,20*+$10,$200
	;s_setcamera	0,0,$1800

	rept	 3
	s_setcameramov	0,0,+$10
	s_setrotmov	$0,-$10,0
	s_wait		40
	s_setcameramov	-4,0,-$20
	s_setrotmov	-$10,0,-4
	s_wait		40
	s_setcameramov	0,0,+$10
	s_setrotmov	4,+$10,0
	s_wait		40
	s_setrotmov	+$10,0,4
	s_wait		40
	endr

	s_setrotmov	-($c0+20*+$10)/$20,-(20*+$10)/$20,-$200/$20
	s_setcameramov	0,0,-$1200/$20
	s_wait		$20
	s_end
	s_close

	ENDC
	ENDC
























;--------------------------------------------------------------
			SECTION DATA
;--------------------------------------------------------------

Current_object:		DC.L	0
which_object:		dc.l	0


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
			INCBIN	F:\Dsp_New\Dsp\Morph2.Dsp
			EVEN

;--------------------------------------------------------------
;	3D OBJECTS
;--------------------------------------------------------------

object_Object:
			INCLUDE F:\DATA\TDF\Ob3\TexMhed.Ob3
			EVEN

;--------------------------------------------------------------
;	GRAPHICS
;--------------------------------------------------------------

Envmap_Buffer
			INCBIN	'C:\_Data\_Gfx\Tmap6.God'
			;INCBIN	'f:\Data\tdf\Gfx\Envmap5.God'


;--------------------------------------------------------------
			SECTION	BSS
			CNOP	0,4
Scan_min		DS.L	1
Scan_max		DS.L	1
Screen_Centre		DS.L	1

			EVEN

			DS.L	300
stack

