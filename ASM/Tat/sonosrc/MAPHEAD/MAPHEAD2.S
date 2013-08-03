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
Texmap_Mode		EQU	0
Motion_Blur_Mode	EQU	0
Animation_Mode		EQU	0
Morphing_Mode		EQU	0
Shademap_Mode		EQU	1
Shademap_Mode2		EQU	1
Sequence_Mode		equ	1

xmax			EQU	383
ymax			EQU	099


ScreenLines		EQU	100
BytesPerLine		EQU	768
Lines			EQU	100
Pixels			EQU	384

Object_Width		EQU	384
Object_Height		EQU	100

Direction		EQU	0		;(Motion Blur)


Back_Colour		EQU	0
noscreens		EQU	3
Demo			EQU	1





start:

	IFNE	Demo
		INCLUDE	F:\Source\Tdf\Main\Equates.S
		output	c:\_demo\data\maphead.prg
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
		init_screens
		BSR	Do_Effects
	IFEQ	Demo
		ILLEGAL
	ELSE
		update_screens
		MOVE.L	(A7)+,D0
		RTS
	ENDC

Initialize_Routine:
		JSR	Calc_Textures
		RTS




Do_Effects:

	; Send DSP routine in...
		init_dsp_routine Dsp_Routine_object,$210.W
	; Send 1/x table...
		JSR	SendOneOver

		lea	shademap_buffer,a0
		JSR	Send_Shademap

		move.l	sequence_data,a0
		bsr	Init_Sequencer
		bsr	sequencer

		LEA	object_Object,A0
		JSR	Send_Object

		BSR	Create_Frame
		bsr	Set_res

		BSR	Main_Loop

		 wait_transmit
		MOVE.L	#"RTS",$FFFFA204.W
		RTS

Main_Loop:
		BSR	Create_Frame
		tst.w	sequence_end_flag
		beq.s	Main_Loop
		RTS

Create_Frame:
		JSR	Spin_Object
		LEA	object_1_Data,A0
		BSR	Start_One_object
		BSR	ClearScreen
		BSR	Draw_object
		bsr	sequencer
		bsr	sequence_update_movement
		BSR	screen_swap
		RTS



Start_One_object:
		MOVE.L	A0,Current_object

		;MOVE.L	Current_object,A0
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
Spin_Object:
		MOVEM.L	Rotation_X,D0/D1/D2
		ADD.L	#25*3,D0
		ADD.L	#5*3,D1
		ADD.L	#6*3,D2
		MOVEM.L	D0/D1/D2,Rotation_X
		RTS


MakeMatrixObject:
		MOVEM.L	Rotation_X,D0/D1/D2
		MOVE.L	#"MAT",D7
		BRA.S	DoMatrix
MakeMatrixLight:
		MOVEM.L	Rotation_X,D0/D1/D2
		;ADD.L	LightRot_X,D2
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

		;include	3dsys\texmap.s
		include	3dsys\view.s
		include	sequence\seq.s






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

	;------------------------------------------------------
get_offsets:
		 wait_receive
		 MOVEQ	#0,D6
		 MOVE.W	(A1),D6			;get top_height
		 SWAP	D6			;*$10000
		 LEA	(Texmap_Buffer,D6.L*2),A5
		 ;wait_receive
		 MOVE.W	(A1),D6			;get top_height
		 MULS.W	D7,D6
		 LEA	(A4,D6.L),A0
		 MOVE.W	(A1),D1
		 SUBQ.W	#1,D1
		 BMI	.Dontdo
.printpoly:
		  wait_receive
		  MOVE.W (A1),D2
		  LEA (A0,D2.W*2),A3
		  MOVEQ #0,D2	
		  MOVE.W (A1),D3
		  SUBQ.W #1,D3
		  bmi.s .next
		  wait_receive
.PP:	   	   MOVE.W (A1),D2
		   MOVE.w (A5,D2.L*2),(A3)+
		   trapf
	  	   DBRA	D3,.PP
.next	  	 ADD.L D7,A0
		 DBF	D1,.printpoly

.dontdo		BRA	HandleLoop
Done		rts
	;------------------------------------------------------








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
	IFNE	Texmap_Mode
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

	ifeq demo
;--------------------------------------------------------------
movespeed	equ	$40
movespeed2	equ	$40
		include	3dsys\keys.s
	endc


			RSRESET
object_X		RS.L	1
object_Y		RS.L	1
object_Z		RS.L	1
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





;--------------------------------------------------------------

	IFNE	Shademap_Mode+Shademap_Mode2
Calc_Textures:
		LEA	Texmap_Buffer+0*(2*64*64*16),A0
		LEA	Texmap_Data_2,A1
		LEA	Texmap_Palette_Data_3,A2
		BSR	Calc_Texture

		LEA	Texmap_Buffer+1*(2*64*64*16),A0
		LEA	Texmap_Data_2,A1
		LEA	Texmap_Palette_Data_2,A2
		BSR	Calc_Texture

		LEA	Texmap_Buffer+2*(2*64*64*16),A0
		LEA	Texmap_Data,A1
		LEA	Texmap_Palette_Data_3,A2
		BSR	Calc_Texture
		RTS


Calc_Texture:
		MOVEM.L	A0-A2,-(A7)
		BSR	.Make_Palette
		MOVEM.L	(A7)+,A0-A2

		MOVE.L	A0,A2
		MOVE.L	A1,A6			;save graphic addr

		LEA	Texmap_Palette_2,A1
		MOVE.W	#16-1,D7
.shadeloop:	MOVE.W	D7,-(A7)
		MOVE.L	A6,A0			;graphic data
		BSR	.make_pattern
		ADDQ.L	#2,A1			;next palette level
		MOVE.W	(A7)+,D7
		DBF	D7,.shadeloop
		RTS

.make_pattern:
		MOVE.W	#(64*64)-1,D0
.makepatt:	MOVEQ	#0,D1
		MOVE.B	(A0)+,D1
		LSL.W	#4,D1			;mult of 16
		MOVE.W	(A1,D1.W*2),(A2)+
		DBF	D0,.makepatt
		RTS


.Copy_Tex:
		LEA	Texmap_Buffer,A1
		MOVE.W	#(64*64*2/4)-1,D0
.copy		MOVE.L	(A1)+,(A0)+
		DBF	D0,.copy
		RTS

.Make_Palette:
		LEA	Texmap_Palette_2,A1
		MOVE.W	#256-1,D7
.makeloop:	MOVE.W	D7,-(A7)

		MOVE.l	#$00000000,D0
		MOVE.L	(A2),D1
		MOVEQ	#8,D2			;span length!
		bsr	calc_Span

		MOVE.L	(A2)+,D0
		MOVE.l	#$FFFF00FF,D1
		MOVEQ	#8,D2
		bsr	calc_Span
		MOVE.W	(A7)+,D7
		DBF	D7,.makeloop
		RTS
	
Calc_Span:
		MOVE.W	D2,-(a7)
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
		DIVS.W	(a7),D0
		ADD.W	A3,D0
		MOVE.W	D6,D1
		MULS.W	D4,D1
		DIVS.W	(a7),D1
		ADD.W	A4,D1
		MOVE.W	D6,D2
		MULS.W	D5,D2
		DIVS.W	(a7),D2
		ADD.W	A5,D2
		LSL.W	#8,D0
		LSL.W	#3,D1
		LSR.W	#3,D2
		AND.W	#%1111100000000000,D0
		AND.W	#%0000011111100000,D1
		AND.W	#%0000000000011111,D2
		OR.W	D0,D2
		OR.W	D1,D2
		MOVE.W	D2,(A1)+
		ADDQ.W	#1,D6
		CMP.W	(a7),D6
		BNE.S	.Calc
		tst.w	(a7)+
		RTS


	ENDC
;--------------------------------------------------------------
			SECTION DATA
;--------------------------------------------------------------
Viewer_Size:		DC.L	10000

Current_object:		DC.L	0

	IFNE	Shademap_Mode2
Send_Shademap:
		LEA	Shademap_Buffer,A0
		 wait_transmit		; not time-critical!
		MOVE.L	#"TEX",$FFFFA204.W
		MOVE.L	#64*64,D0
		 wait_transmit
		MOVE.L	D0,$FFFFA204.W
		SUBQ.L	#1,D0
.SendPoints:
		 wait_transmit		; not time-critical!
		MOVE.W	(A0)+,D1
		ASL.L	#8,D1
		MOVE.L	D1,$FFFFA204.W
		DBF	D0,.SendPoints
		RTS
	ENDC


;--------------------------------------------------------------
;	MISCELLANEOUS DATA
;--------------------------------------------------------------
			CNOP	0,4
SineTable:		INCBIN	f:\data\trailsin.dat
CosTable:		EQU	SineTable+2048*2
			EVEN
which_object		ds.l	1

;--------------------------------------------------------------
;	DSP ROUTINES
;--------------------------------------------------------------

Dsp_Routine_object:
		IFNE Bitplane_Mode
			;INCBIN	F:\Dsp_New\Dsp\Gen_3pl.Dsp
			INCBIN	F:\Dsp_New\Dsp\In_Room.Dsp
		ELSE
			INCBIN	F:\Dsp_New\Dsp\Gen_Tex3.Dsp
		ENDC
			EVEN


;--------------------------------------------------------------
;	3D OBJECTS
;--------------------------------------------------------------

object_Object:
		IFNE Bitplane_Mode
			INCLUDE F:\DATA\TDF\ob3\inroom.Ob3
		ELSE
			INCLUDE F:\DATA\TDF\Ob3\TexHEad.Ob3
		ENDC
			EVEN

;--------------------------------------------------------------
;	GRAPHICS
;--------------------------------------------------------------

	IFEQ	Bitplane_Mode
Texmap_Data		EQU	*+6
			INCBIN	'd:\Texture1.Dat'
Texmap_Data_2		EQU	*+6
			INCBIN	'd:\Texture2.Dat'

Texmap_Palette_Data	INCBIN	'd:\Texture5.Pal'
Texmap_Palette_Data_2	INCBIN	'd:\Texture2.Pal'
Texmap_Palette_Data_3	INCBIN	'd:\Texture3.Pal'
			EVEN

Logo:			EQU	*+6
			INCBIN	'F:\Data\Tdf\Gfx\Avena.God'
	ENDC

	IFNE	Shademap_Mode2
Shademap_Buffer		INCBIN	'C:\_Data\_Map\Under.Map'
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

Texmap_Palette_2	DS.W	256*16
Texmap_Buffer		DS.W	64*64*16*3
			EVEN

			DS.L	300
stack

