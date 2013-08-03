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
Animation_Mode		EQU	1
Morphing_Mode		EQU	0
Shademap_Mode		EQU	1
Sequence_Mode		EQU	1

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

Direction	EQU	0		;(Motion Blur)


Back_Colour	EQU	-1
noscreens	EQU	3
Demo		EQU	1





start:

	IFNE	Demo
		INCLUDE	F:\Source\Tdf\Main\Equates.S
		output	c:\_demo\data\tree.prg
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
	IFNE	Demo
		init_screens
	endc
		init_dsp_routine Dsp_Routine_object,$210.W
		JSR	SendOneOver
		LEA	object_Object,A0
		JSR	Send_Object

	IFNE Animation_Mode
		JSR	Animate_Init
		JSR	Animate_Object		;(once)
	ENDC

	IFNE Morphing_Mode
		JSR	Morph_Init
		JSR	Moprh_Object
	ENDC

	IFNE Bitplane_Mode
		BSR	Set_Palette
	ENDC
		bsr	Animate_Tree
		install_vbl	Animate_Tree
		MOVE.W	#$2300,SR

	IFNE	Sequence_Mode
		IFEQ	Demo
		lea	test_sequence,A0
		ELSE
		move.l	sequence_data,A0
		ENDC
		bsr	Init_Sequencer
	ENDC
		BSR	Create_Frame
		bsr	wait_vbl
		bsr	Set_res
		BSR	Main_Loop

		install_vbl 0
		wait_transmit
		MOVE.L	#"RTS",$FFFFA204.W
	IFNE	Demo
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
	ELSE
		JSR	Handle_Keyboard
	ENDC

		LEA	object_1_Data,A0
		BSR	Start_One_object
		BSR	ClearScreen
		BSR	Draw_object
		;BSR	Draw_Logo
		;BSR	Draw_Info

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

	IFNE Morphing_Mode
		BSR	Morph_object
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
		BRA.W	get_offsets		;4
	;------------------------------------------------------
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

	;------------------------------------------------------
get_gouraud:
		BRA	HandleLoop
	;------------------------------------------------------
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
		  ;wait_receive
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
	;------------------------------------------------------

Dontdo		ILLEGAL







		include	3dsys\matrix.s
		include	3dsys\object.s
		include	3dsys\texmap.s

		ifne keys
		include	3dsys\text.s
		endc

;--------------------------------------------------------------
		IFNE	Keys
movespeed	equ	$40
movespeed2	equ	$40

		include	3dsys\keys.s

		ENDC


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
		wait_transmit
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


		;include 3dsys\colourt.s
		;include 3dsys\motion2.s
		;include 3dsys\motion.s
		;include 3dsys\text.s

		include	sequence\seq.s		;included anyway!

	IFNE	Sequence_Mode
test_sequence:
	s_setrot	0,0,$200
	s_setview	0,-$500,0
	s_setrotmov	$0,-$30,0

	rept 100
	s_setcamera	$0,$0,$1000
	s_setcameramov	$0,$0,-$40
	s_wait		40
	endr

	s_end
	s_close

	ENDC



;--------------------------------------------------------------

	IFNE Animation_Mode
Animate_Init:
		LEA	$FFFFA204.W,A0
		 wait_transmit
		MOVE.L	#"A_I",(A0)
		MOVE.L	#244,D0			;must be less than
						;maximum_points
		 wait_transmit
		MOVE.L	D0,(A0)			;point count

		MULU.W	#3,D0			;x,y,z
		SUBQ.W	#1,D0			;(for dbf)
		MOVEQ	#4,D1
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
		 wait_transmit
		MOVE.L	Animate_Data_2(PC),(A0)		;size
		RTS

Animate_Data_1:	DC.L	0
Animate_Data_2:	DC.L	$7FFFFF

Animate_Tree:
; 8192/(6*64)
		lea	sequence_misc_data,a1
		MOVE.L	Tree_Data_1(a1),D0
		add.L	Tree_Speed_1(a1),D0
		AND.L	#$1FFF,D0
		MOVE.L	D0,Tree_Data_1(a1)
		MOVE.W	(SineTable.l,D0.W*2),D0
		MULS.W	#35,D0
		MOVE.L	d0,Animate_Data_1

		MOVE.L	Tree_Data_2(a1),D0
		add.L	Tree_Speed_2(a1),D0
		AND.L	#$1FFF,D0
		MOVE.L	D0,Tree_Data_2(a1)

		MOVE.W	(SineTable.l,D0.W*2),D0
		MULS.W	#$20,D0
		ADD.L	#$400000,D0
		MOVE.L	#$7fffff,Animate_Data_2
		RTS
	ENDC


;--------------------------------------------------------------
	IFNE	Shademap_Mode
Calc_Textures:
		LEA	Texmap_Buffer+0*(2*64*64*16),A0
		LEA	Texmap_Data,A1
		LEA	Texmap_Palette_Data,A2
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

		MOVE.L	(A2),D0
		MOVE.l	#$00000000,D1
		MOVEQ	#8,D2			;span length!
		bsr	calc_Span

		MOVE.l	#$FFFF00FF,D0
		MOVE.L	(A2)+,D1
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

Viewer_Size		dc.l	10000
Current_object:		DC.L	0
which_object:		dc.l	0



;--------------------------------------------------------------
;	MISCELLANEOUS DATA
;--------------------------------------------------------------
			CNOP	0,4
SineTable:		INCBIN	f:\data\trailsin.dat
CosTable:		EQU	SineTable+2048*2
			even


;--------------------------------------------------------------
;	DSP ROUTINES
;--------------------------------------------------------------

Dsp_Routine_object:
			INCBIN	F:\Dsp_New\Dsp\Tree2.Dsp
			even

;--------------------------------------------------------------
;	3D OBJECTS
;--------------------------------------------------------------

object_Object:
			INCLUDE F:\DATA\TDF\Ob3\TexTree2.Ob3
			EVEN

;--------------------------------------------------------------
;	GRAPHICS
;--------------------------------------------------------------

Texmap_Data		EQU	*+6
			INCBIN	'd:\Texture2.Dat'

Texmap_Palette_Data	INCBIN	'd:\Texture3.Pal'

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
Texmap_Buffer		DS.W	64*64*16
			EVEN

			DS.L	300
stack

