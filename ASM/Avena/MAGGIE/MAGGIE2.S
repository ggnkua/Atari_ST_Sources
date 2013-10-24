********************************************
*                  DIGITAL                 *
*      - - --- ------ _ ------ --- - -     *
*       _____ __  __ / \ _____ _____       *
*      / ___// /_/ // . \\  _ \\  __\      *
*     / /__ / __  //  _  \\ \\ \\__  \     *
*    /____//_/ /_//__/ \__\\____\\____\    *
*    \    \\ \ \ \\  \ /  //    //    /    *
*     \    \\ \ \ \\     //    //    /     *
*                                          *
*     A Digital Chaos Production, 1995     *
********************************************



; IMPORTANT NOTE: I have not included any of the graphics data or
; pre-assembled .DSP programs - only the source code and GFA programs
; are included. This is mainly to save space, but also to force you
; to concentrate on the internals of the code and use the parts for
; your own ends... instead of merely ripping it off...


; IMPORTANT NOTE #2:
; None of the files in MAGINTRO.ZIP may be copied without the
; inclusion of the original copy of Maggie 20





wait		EQU	1		;1 = do sync to music
Key		EQU	0
Mouse		EQU	0		;no test mouse-control of objs
Clear		EQU	1
Tracker_On	EQU	1		;1 = music on

ScreenLines	EQU	200		;size of screen data
BytesPerLine	EQU	512
Lines		EQU	200
Pixels		EQU	256
Number_Of_Flat_Colours EQU	360
Number_Of_Gour_Colours EQU	2
Number_Of_Pictures     EQU	8	;(to flash on)



start:
	BRA .silly

	DC.B	"Hello, all this code was ripped from other people, "
	DC.B	"so there. If you don't understand that this is not "
	DC.B	"true then you're German. (Joke!)"
	DC.B	"  Coded by the Easy Rider Assembler School of Coding. "
	DC.B	" Hi Leon!!"
	EVEN
.silly:
	CLR.L -(A7)
	MOVE.W #$20,-(A7)
	TRAP #1
	MOVE.L D0,save_stack
	ADDq.L #6,A7		;use existing stacks

	BSR savevectors
	BRA program_start

	INCLUDE VECTORS.S

program_start:
	BSR	Test_VGA
	TST.W	D0
	BEQ	Monochrome_Monitor

	CMP.W	#2,D0
	BNE.S	.Not_Vga

	MOVE.W	#-1,Vga_Flag
	BRA.S	.cont

.Not_Vga:
	CLR.W	Vga_Flag

.cont:	MOVE.L	#STACK+4000,D0		;top of memory - change!
	SUB.B	D0,D0
	MOVE.L	D0,logic
	ADD.L	#BytesPerLine*ScreenLines,D0
	MOVE.L	D0,physic
	ADD.L	#BytesPerLine*ScreenLines,D0
	MOVE.L	D0,third
	MOVE.L	#Picture_Screen+16,D0
	AND.L	#$FFFFF0,D0
	MOVE.L	D0,Picture_Screen_Addr

ps	JSR	start_tracker
	MOVE.W	#$2700,SR

; Set original vectors and screens etc.
	LEA stack,A7
	LEA mouse_on(PC),A0
	BSR send_ikbd
	MOVE.L	#RTE,$14.W

	MOVE.L	#vbl,$70.W
	MOVE.L	#keyboard,$118.W
	MOVE.L	#$ff20ff40,$fffffA06.W
	MOVE.L	#$ff20ff40,$fffffA12.W	;allow keyboard, timerA
	BCLR	#3,$fffffA17.W 
	MOVE.W	#$2300,SR
	BRA	begin


;---------------------------------------------------------------

begin:
	CLR.L	$FFFF9800.W
	JSR	Calc_Colours_Flat
	JSR	Calc_Colours_Gour
	JSR	Calc_Colours_Shademap

	BSR	clearscreens
	BSR	Wait_Vbl
	JSR	init_rez_torus
	BSR	screen_swap

	MOVE.L	#$0001,D0
	MOVEC	D0,CACR

	ifne	wait
	MOVE.W	#1,D0
	BSR	Wait_Music
; Flat Shaded:
	MOVE.W	#365-16,D0
	BSR	Flat_Loop

	MOVEQ	#0,D0
	MOVEQ	#1,D1
	MOVEQ	#2,D2
	MOVEQ	#3,D3
	BSR	Flash_Pics

; Static Gouraud:
	MOVE.W	#0,RotSpeed_X
	MOVE.W	#0,RotSpeed_Y
	MOVE.W	#0,RotSpeed_Z
	MOVE.W	#0,Rotation_X
	MOVE.W	#0,Rotation_Y
	MOVE.W	#0,Rotation_Z
	MOVE.W	#50,D0
	BSR	Gouraud_Loop

	MOVE.W	#8*6,RotSpeed_X
	MOVE.W	#0,RotSpeed_Y
	MOVE.W	#0,RotSpeed_Z
	MOVE.W	#0,Rotation_X
	MOVE.W	#0,Rotation_Y
	MOVE.W	#0,Rotation_Z
	MOVE.W	#50,D0
	MOVE.W	D0,Frame_Count
	BSR	Gouraud_Loop2

; Moving Gouraud:
	MOVE.W	#6*6,RotSpeed_X
	MOVE.W	#6*4,RotSpeed_Y
	MOVE.W	#6*8,RotSpeed_Z
	MOVE.W	#265+10,D0
	MOVE.W	D0,Frame_Count
	BSR	Gouraud_Loop2

	MOVE.W	#$2700,SR
	JSR	Wait_SendDSP
	MOVE.L	#"RTS",$FFFFA204.W		;quit it this time
	MOVE.W	#$2300,SR

	MOVE.W	#4,D0
	MOVE.W	#5,D1
	MOVE.W	#6,D2
	MOVE.W	#7,D3
	BSR	Flash_Pics
	endc

; Texmap:
	MOVE.W	#7*6,RotSpeed_X
	MOVE.W	#-7*4,RotSpeed_Y
	MOVE.W	#7*8,RotSpeed_Z
	MOVE.W	#365-16,D0		;demo value
	BSR	Texmap_Loop1

HOLD:
; Shaded Texmap:
	MOVE.W	#8*6,RotSpeed_X
	MOVE.W	#-8*4,RotSpeed_Y
	MOVE.W	#8*8,RotSpeed_Z
	MOVE.W	#8*8,LightSpeed_X
	MOVE.W	#-8*10,LightSpeed_Y
	MOVE.W	#-8*12,LightSpeed_Z
	MOVE.W	#185,D0
	BSR	Shademap_Loop

	MOVE.W	#8*6,RotSpeed_X
	MOVE.W	#-8*4,RotSpeed_Y
	MOVE.W	#8*8,RotSpeed_Z
	MOVE.W	#8*8,LightSpeed_X
	MOVE.W	#-8*10,LightSpeed_Y
	MOVE.W	#-8*12,LightSpeed_Z
	MOVE.W	#200,D0
	BSR	Shademap_Loop


; Static Gouraud:
	MOVE.W	#0,RotSpeed_X
	MOVE.W	#21,RotSpeed_Y
	MOVE.W	#0,RotSpeed_Z
	MOVE.W	#1,D0
	BSR	Gouraud_Loop3

	MOVE.W	#8*6,RotSpeed_X
	MOVE.W	#23,RotSpeed_Y
	MOVE.W	#0,RotSpeed_Z
	MOVE.W	#164,D0
	MOVE.W	D0,Frame_Count
	BSR	Gouraud_Loop2

	MOVE.W	#$2700,SR
	JSR	Wait_SendDSP
	MOVE.L	#"RTS",$FFFFA204.W		;quit it this time
	MOVE.W	#$2300,SR

; Flat Shaded:
	MOVE.W	#12,Rotation_X
	MOVE.W	#10,Rotation_Y
	MOVE.W	#5,Rotation_Z
	MOVE.W	#165,D0
	BSR	Flat_Loop

	MOVE.W	#7*6,RotSpeed_X
	MOVE.W	#-7*4,RotSpeed_Y
	MOVE.W	#7*8,RotSpeed_Z
	MOVE.W	#365-16,D0		;demo value
	BSR	Texmap_Loop2

	BRA	HOLD

Monochrome_Monitor:
	BRA	Quit



;--------------------------------------------------------------



;		L O O P S



;--------------------------------------------------------------
Flat_Loop:
	MOVE.W	D0,Frame_Count
	CLR.W	Flat_Fade
	BSR	Wait_Vbl
	JSR	init_rez_torus
	BSR	screen_swap
Do_Flat:
	MOVE.W	#$2700,SR
	LEA	Dsp_Routine_Flat,A0
	BSR	Dsp_Library+4
	LEA	$210.W,A0
	BSR	Dsp_Library+8
	JSR	SendOneOver
	LEA	Torus_Object,A0
	JSR	Send_Object
	MOVE.W	#$2300,SR

	MOVE.W	#16-1,D0
.LOOP3:
	MOVE.W	D0,-(A7)
	BSR	Make_Flat_Frame		;do initial frame
	BSR	screen_swap2
	BSR	wait_vbl2
	ADD.W	#$3FFF/$10,Flat_Fade
	MOVE.W	(A7)+,D0
	DBF	D0,.LOOP3

.LOOP:	BSR	Make_Flat_Frame		;do initial frame
	BSR	screen_swap2
	BSR	wait_vbl2
	SUBQ.W	#1,Frame_Count
	BGT	.LOOP
	MOVE.W	#16,Frame_Count
.LOOP2:
	BSR	Make_Flat_Frame		;do initial frame
	BSR	screen_swap
	BSR	wait_vbl2
	SUB.W	#$3FFF/$10,Flat_Fade
	SUBQ.W	#1,Frame_Count
	BGT	.LOOP2

	MOVE.W	#$2700,SR
	JSR	Wait_SendDSP
	MOVE.L	#"RTS",$FFFFA204.W		;quit it
	MOVE.W	#$2300,SR
	RTS





Gouraud_Loop:
	MOVE.W	D0,Frame_Count

	MOVE.L	#$2909,D0
	MOVEC	D0,CACR

	MOVE.L	#$7FFFFF,Unit_Size
	MOVE.W	#$2700,SR
	LEA	Dsp_Routine_Gour,A0
	BSR	Dsp_Library+4
	LEA	$210.W,A0
	BSR	Dsp_Library+8
	JSR	SendOneOver
	LEA	Torus_Object_Gour,A0
	JSR	Send_Object
	JSR	Send_Colours_Gour
	MOVE.W	#$2300,SR

	MOVE.L	#$0001,D0
	MOVEC	D0,CACR

	MOVE.W	#4,D0
	BSR	Wait_Music

	MOVE.L	#rts,my_vbl
	BSR	Make_Gouraud_Frame		;do initial frame
	BSR	Wait_Vbl
	JSR	init_rez_torus
	BSR	screen_swap

.LOOP:	BSR	Make_Gouraud_Frame
	BSR	screen_swap2
	BSR	wait_vbl2
	SUBQ.W	#1,Frame_Count
	BGT	.LOOP
	RTS

Gouraud_Loop2:
.LOOP:	BSR	Make_Gouraud_Frame
	BSR	screen_swap2
	BSR	wait_vbl2
	SUBQ.W	#1,Frame_Count
	BGT	.LOOP
	RTS


Gouraud_Loop3:
	MOVE.W	D0,Frame_Count

	MOVE.L	#$2909,D0
	MOVEC	D0,CACR

	MOVE.L	#$7FFFFF,Unit_Size
	MOVE.W	#$2700,SR
	LEA	Dsp_Routine_Gour,A0
	BSR	Dsp_Library+4
	LEA	$210.W,A0
	BSR	Dsp_Library+8
	JSR	SendOneOver
	LEA	Torus_Object_Gour,A0
	JSR	Send_Object
	JSR	Send_Colours_Gour
	MOVE.W	#$2300,SR

	MOVE.L	#$0001,D0
	MOVEC	D0,CACR
	MOVE.L	#rts,my_vbl

.LOOP:	BSR	Make_Gouraud_Frame
	BSR	screen_swap2
	BSR	wait_vbl2
	SUBQ.W	#1,Frame_Count
	BGT	.LOOP
	RTS

Texmap_Loop2:
	MOVE.W	D0,Frame_Count

	MOVE.L	#$2909,D0
	MOVEC	D0,CACR

	MOVE.W	#$2700,SR
	LEA	Dsp_Routine_Texmap,A0
	BSR	Dsp_Library+4
	LEA	$210.W,A0
	BSR	Dsp_Library+8
	JSR	SendOneOver
	MOVE.W	#$2300,SR
	MOVE.W	#$2700,SR
	LEA	Torus_Object_Texmap,A0
	JSR	Send_Object
	JSR	Send_Texmap
	MOVE.W	#$2300,SR

	MOVE.L	#$0001,D0
	MOVEC	D0,CACR
	BRA	Do_LoopT


Texmap_Loop1:
	MOVE.W	D0,Frame_Count

	MOVE.L	#$2909,D0
	MOVEC	D0,CACR

	MOVE.W	#$2700,SR
	LEA	Dsp_Routine_Texmap,A0
	BSR	Dsp_Library+4
	LEA	$210.W,A0
	BSR	Dsp_Library+8
	JSR	SendOneOver
	MOVE.W	#$2300,SR
	MOVE.W	#$2700,SR
	LEA	Torus_Object_Texmap,A0
	JSR	Send_Object
	JSR	Send_Texmap
	MOVE.W	#$2300,SR

	MOVE.L	#$0001,D0
	MOVEC	D0,CACR
	BSR	Make_Texmap_Frame

	MOVE.W	#4,D0
	BSR	Wait_Music
	BRA	Do_LoopT

Texmap_Loop:
	MOVE.W	D0,Frame_Count

	MOVE.L	#$2909,D0
	MOVEC	D0,CACR

	MOVE.W	#$2700,SR
	LEA	Dsp_Routine_Texmap,A0
	BSR	Dsp_Library+4
	LEA	$210.W,A0
	BSR	Dsp_Library+8
	JSR	SendOneOver
	MOVE.W	#$2300,SR
	MOVE.W	#$2700,SR
	LEA	Torus_Object_Texmap,A0
	JSR	Send_Object
	JSR	Send_Texmap
	MOVE.W	#$2300,SR

	MOVE.L	#$0001,D0
	MOVEC	D0,CACR
	BSR	Make_Texmap_Frame

	MOVE.W	#4,D0
	BSR	Wait_Music

Do_LoopT
	JSR	init_rez_torus
	BSR	screen_swap

.LOOP:	BSR	Make_Texmap_Frame
	BSR	screen_swap2
	BSR	wait_vbl2
	SUBQ.W	#1,Frame_Count
	BGT	.LOOP

	MOVE.W	#$2700,SR
	JSR	Wait_SendDSP
	MOVE.L	#"RTS",$FFFFA204.W		;quit it
	MOVE.W	#$2300,SR
	RTS


Shademap_Loop:
	MOVE.W	D0,Frame_Count

	MOVE.L	#$2909,D0
	MOVEC	D0,CACR

	MOVE.W	#$2700,SR
	LEA	Dsp_Routine_Shademap,A0
	BSR	Dsp_Library+4
	LEA	$210.W,A0
	BSR	Dsp_Library+8
	JSR	SendOneOver
	MOVE.W	#$2300,SR
	NOP					;try to stop the click...
	MOVE.W	#$2700,SR
	LEA	Torus_Object_Shademap,A0
	JSR	Send_Object
	MOVE.W	#$2300,SR
	NOP					;try to stop the click...
	MOVE.W	#$2700,SR
	JSR	Send_Shademap
	MOVE.W	#$2300,SR

	MOVE.L	#$0001,D0
	MOVEC	D0,CACR
	BSR	Make_Shademap_Frame

	BSR	Wait_Vbl
	JSR	init_rez_torus
	BSR	screen_swap

.LOOP:	BSR	Make_Shademap_Frame
	BSR	screen_swap2
	;BSR	wait_vbl2
	SUBQ.W	#1,Frame_Count
	BGT	.LOOP

	MOVE.W	#$2700,SR
	JSR	Wait_SendDSP
	MOVE.L	#"RTS",$FFFFA204.W		;quit it
	MOVE.W	#$2300,SR
	RTS










Make_Gouraud_Frame:
	BSR	Spin_Object
	BSR	MakeMatrixLight		;Must be done FIRST
	BSR	MakeMatrixObject
	MOVE.W	#$2700,SR
	JSR	Wait_SendDsp
	MOVE.L	#"CAL",$FFFFA204.W
	MOVE.W	#$2300,SR
	BSR	ClearScreen
	BSR	Handle_Object_Gour
	RTS

Make_Flat_Frame:
	;MOVE.L	#-1,$FFFF9800.W
	BSR	Spin_Object
	BSR	MakeMatrixObject
	MOVE.W	#$2700,SR
	JSR	Wait_SendDsp
	MOVE.L	#"CAL",$FFFFA204.W
	MOVE.W	#$2300,SR
	BSR	ClearScreen
	BSR	Handle_Object_Flat
	;MOVE.L	#0,$FFFF9800.W
	RTS


Make_Texmap_Frame:
	BSR	Spin_Object
	BSR	MakeMatrixObject
	MOVE.W	#$2700,SR
	JSR	Wait_SendDsp
	MOVE.L	#"CAL",$FFFFA204.W
	MOVE.W	#$2300,SR
	BSR	ClearScreen
	BSR	Handle_Object_Texmap
	RTS

Make_Shademap_Frame:
	BSR	Spin_Object
	BSR	MakeMatrixLight		;Must be done FIRST
	BSR	MakeMatrixObject
	MOVE.W	#$2700,SR
	JSR	Wait_SendDsp
	MOVE.L	#"CAL",$FFFFA204.W
	MOVE.W	#$2300,SR
	BSR	ClearScreen
	BSR	Handle_Object_Shademap
	RTS

















;--------------------------------------------------------------
Wait_Music:
	IFNE	wait
	CMP.W	DemoFlag,D0
	BNE.S	Wait_Music
	endc
	RTS

;--------------------------------------------------------------
screen_swap2
	cmp.w	#1,vbl_timer
	blt.s	screen_swap2

screen_swap:
	MOVE.L	logic(PC),D0
	MOVE.L	third,logic
	MOVE.L	physic,third
	MOVE.L	D0,physic

	MOVE.L	physic(PC),-(A7)
	MOVE.B	1(A7),$ffff8201.W
	MOVE.B	2(A7),$ffff8203.W
	MOVE.B	3(A7),$ffff820d.W
	ADDQ.L	#4,A7
	RTS


;--------------------------------------------------------------
Wait_Vbl2:
	TST.W	Vga_Flag
	BNE.S	.Vga
	cmp.w	#2,vbl_timer
	blt.s	Wait_Vbl2
.Vga
	clr.w	vbl_timer
	rts


;--------------------------------------------------------------
ClearScreens:
	MOVE.L	physic,A0
	MOVE.L	logic,A1
	MOVE.L	third,A2
	MOVEQ	#0,D0
	MOVE.W	#ScreenLines*BytesPerLine/4-1,D1
.Wipe:	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A1)+
	MOVE.L	D0,(A2)+
	DBF	D1,.Wipe
	RTS



Init_Rez_Flash:
	TST.W	Vga_Flag
	BNE.S	.Vga
	INCLUDE REZ_FLAS.S
	RTS
.Vga:	INCLUDE REZ_FLAV.S
	RTS

Init_Rez_Torus:
	TST.W	Vga_Flag
	BNE.S	.Vga
	INCLUDE REZ_TORU.S
	RTS
.Vga:	INCLUDE REZ_TORV.S
	RTS





















;--------------------------------------------------------------
Torus_Width EQU 154
Torus_Height EQU 154

ReptVal EQU ((Torus_Width*2)/13/4)+1


ClearScreen:
	IFNE	Clear
	MOVE.L	logic,A6
	ADD.L	#(160+Torus_Height)/2*BytesPerLine,A6
	LEA	(2*(Pixels+Torus_Width)/2)(A6),A6

	MOVEQ.L	#0,D1
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
	MOVE.W	#Torus_Height-1,D0
.Wipe:
	REPT	ReptVal
	MOVEM.L	D1-A5,-(A6)
	ENDR

	LEA	-(BytesPerLine)+(13*4*Reptval)(A6),A6
	DBF	D0,.Wipe
	ENDC
	RTS

;--------------------------------------------------------------
Spin_Object:
	MOVEM.W	Rotation_X,D0/D1/D2
	MOVEM.W	RotSpeed_X,D3/D4/D5
	ADD.W	D3,D0
	ADD.W	D4,D1
	ADD.W	D5,D2

	IFNE	mouse
	MOVEQ	#0,d1
	 MOVE.W	mouse_x,D0
	 ASL.W	#4,D0
	MOVE.W	mouse_y,D2
	 ASL.W	#4,D2
	ENDC

	AND.W	#$1FFF,D0
	AND.W	#$1FFF,D1
	AND.W	#$1FFF,D2
	MOVEM.W	D0/D1/D2,Rotation_X

	MOVEM.W	LightRot_X,D0/D1/D2
	MOVEM.W	LightSpeed_X,D3/D4/D5
	ADD.W	D3,D0
	ADD.W	D4,D1
	ADD.W	D5,D2
	AND.W	#$1FFF,D0
	AND.W	#$1FFF,D1
	AND.W	#$1FFF,D2
	MOVEM.W	D0/D1/D2,LightRot_X


	RTS


MakeMatrixObject:
	MOVE.W	#$2700,SR
	MOVEM.W	Rotation_X,D0/D1/D2
	MOVE.L	#"MAT",D7
	BRA.S	DoMatrix

MakeMatrixLight:
	MOVE.W	#$2700,SR
	JSR	Wait_SendDsp
	MOVE.L	#"LIG",$FFFFA204.W
	MOVEM.W	LightRot_X,D0/D1/D2
	BRA	SendMatrix
; Expansion to allow fading using the unit_vector?

DoMatrix:
	JSR	Wait_SendDsp
	MOVE.L	D7,$FFFFA204.W
SendMatrix
	LEA	CosTable,A0
	LEA	SineTable,A1
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
	MOVE.W	#$2300,SR
	RTS
SendInfo:
	EXT.L	D7
	ASL.L	#8,D7
	BSR	Wait_SendDsp
	MOVE.L	D7,$FFFFA204.W
	RTS


























;--------------------------------------------------------------
Handle_Object_Gour:
	MOVE.L	Logic,A0
	ADD.L	#(BytesPerLine/2)+BytesPerLine*(160/2),A0
	MOVE.L	A0,Screen_Centre
	MOVE.L	#$0001,D0
	MOVEC	D0,CACR

	MOVE.W	#$2700,SR
	JSR	Wait_SendDSP
	MOVE.L	#"HAN",$FFFFA204.W
	LEA	$FFFFA206.W,A1
	LEA	$FFFFA202.W,A2

.HandleLoop
	MOVE.W	#$2700,SR
	JSR	Wait_SendDSP
	MOVE.L	#"GET",$FFFFA204.W
.wr2	BTST	#0,(A2)
	BEQ.S	.wr2
	MOVE.W	(A1),D0
	CMP.W	#"ND",D0
	BEQ.S	.Done
	CMP.W	#"OL",D0
	BNE.S	.wr2
.wr3	BTST	#0,(A2)
	BEQ.S	.wr3
	MOVE.W	(A1),D0			;get top_height
	MOVE.L	Screen_Centre,A0
	MULS.W	#BytesPerLine,D0
	ADD.L	D0,A0
	MOVE.W	(A1),D1			;fetch height
	SUBQ.W	#1,D1
	BLT.S	.dontdo
.printpoly:
	MOVE.W	(A1),D2
	LEA	(A0,D2.W*2),A3	
	MOVE.W	(A1),D3
	SUBQ.W	#1,D3
	BMI.S	.next
.PP	MOVE.W	(A1),(A3)+
	DBRA	D3,.PP
.next	LEA	BytesPerLine(A0),A0
	DBF	D1,.printpoly
	MOVE.W	#$2300,SR		;<----- CHANGE!
	BRA.S	.HandleLoop
.Done:
	MOVE.W	#$2300,SR
	RTS

.dontdo	ILLEGAL





Handle_Object_Texmap:
	MOVE.L	Logic,A0
	ADD.L	#(BytesPerLine/2)+BytesPerLine*(160/2),A0
	MOVE.L	A0,Screen_Centre
	MOVE.L	#$0001,D0
	MOVEC	D0,CACR

	MOVE.W	#$2700,SR
	JSR	Wait_SendDSP
	MOVE.L	#"HAN",$FFFFA204.W
	LEA	$FFFFA206.W,A1
	LEA	$FFFFA202.W,A2

.HandleLoop
	MOVE.W	#$2700,SR
	JSR	Wait_SendDSP
	MOVE.L	#"GET",$FFFFA204.W
.wr2	BTST	#0,(A2)
	BEQ.S	.wr2
	MOVE.W	(A1),D0
	CMP.W	#"ND",D0
	BEQ.S	.Done
	CMP.W	#"OL",D0
	BNE.S	.wr2

.wr3	BTST	#0,(A2)
	BEQ.S	.wr3
	MOVE.W	(A1),D0			;get top_height
	MOVE.L	Screen_Centre,A0
	MULS.W	#BytesPerLine,D0
	ADD.L	D0,A0
	MOVE.W	(A1),D1			;fetch height
	SUBQ.W	#1,D1
	BLT.S	.dontdo


.printpoly:

	MOVE.W	(A1),D2
	LEA	(A0,D2.W*2),A3	
	MOVE.W	(A1),D3
	SUBQ.W	#1,D3
	BMI.S	.next

.wr4	BTST	#0,(A2)			;bodge for texmap?
	BEQ.S	.wr4
.PP	MOVE.W	(A1),(A3)+
	DBRA	D3,.PP
.next	LEA	BytesPerLine(A0),A0
	DBF	D1,.printpoly
	MOVE.W	#$2300,SR		;<----- CHANGE!
	BRA.S	.HandleLoop
.Done:	MOVE.W	#$2300,SR
	RTS

.dontdo	ILLEGAL


;--------------------------------------------------------------
Handle_Object_Shademap:
	MOVE.L	Logic,A0
	ADD.L	#(BytesPerLine/2)+BytesPerLine*(160/2),A0
	MOVE.L	A0,A6
	MOVE.L	#BytesPerLine,D6

	MOVE.L	#$0001,D0
	MOVEC	D0,CACR

	MOVE.W	#$2700,SR
	JSR	Wait_SendDSP
	MOVE.L	#"HAN",$FFFFA204.W
	LEA	$FFFFA206.W,A1
	LEA	$FFFFA202.W,A2

.HandleLoop
	MOVE.W	#$2700,SR
	JSR	Wait_SendDSP
	MOVE.L	#"GET",$FFFFA204.W	;send com

.wr2	BTST	#0,(A2)
	BEQ.S	.wr2
	MOVE.W	(A1),D0			;fetch reply
	CMP.W	#"ND",D0
	BEQ.S	.Done
	;CMP.W	#"OL",D0		;assume it's OL
	;BNE.S	.wr2

	MOVE.W	(A1),D0
	MULS.W	D6,D0
	LEA.L	(A6,D0.L),A0
	MOVE.W	(A1),D1
	SUBQ.W	#1,D1
	BLT.S	.dontdo
.printpoly:
	MOVE.W	(A1),D2
	LEA	(A0,D2.W*2),A3	
	MOVE.W	(A1),D3
	SUBQ.W	#1,D3
	BMI.S	.next
.wr	BTST	#0,(A2)
	BEQ.S	.wr
.PP	MOVE.W	(A1),(A3)+
	TRAPF
	DBRA	D3,.PP
.next	ADD.L	D6,A0			;is this quicker?
	DBF	D1,.printpoly
	MOVE.W	#$2300,SR
	BRA.S	.HandleLoop

.Done:	MOVE.W	#$2300,SR
	RTS

.dontdo	ILLEGAL




























;--------------------------------------------------------------
; d0 already equals top height
; Flat-shading routine!

PrintPoly:
	JSR	Wait_ReceiveDSP
	MOVE.L	$FFFFA204.W,D0		;GET HEIGHT
	MOVE.L	Logic,A0
	ADD.L	#(BytesPerLine/2)+BytesPerLine*(160/2),A0
	MULS.W	#BytesPerLine,D0	;fortunate. We've ANDed already
	ADD.L	D0,A0
	JSR	Wait_ReceiveDSP
	MOVE.L	$FFFFA204.W,D1
	SUBQ.W	#1,D1
	BLT.S	.dontdo
	JSR	Wait_ReceiveDSP
	MOVE.L	$FFFFA204.W,D2		;get colour
	MULU.W	#64,D2
	JSR	Wait_ReceiveDSP
	MOVE.L	$FFFFA204.W,D0		; 0-7FFFFF shade value
	ASR.L	#8,D0			; 0-007FFF
	MULS.W	Flat_Fade,D0
	SWAP	D0
	ASR.W	#8,D0
	LEA	Colour_Buffer_Flat,A1
	AND.W	#63,D0
	EXT.L	D0
	ADD.L	D0,D2
	MOVE.W	(A1,D2.L*2),D0
	SWAP	D0
	MOVE.W	(A1,D2.L*2),D0
	LEA	$FFFFA206.W,A1
	JSR	Wait_ReceiveDSP
.printpoly:
	MOVE.W	(A1),D2
	LEA	(A0,D2.W*2),A3	
	MOVE.W	(A1),D3
	SUB.W	D2,D3
	MOVE.W	D3,D4
	ASR.W	#1,D3
	BEQ.S	.lickle
	BMI.S	.next
	SUBQ.W	#1,D3
.PP	MOVE.L	D0,(A3)+
	DBF	D3,.PP
.lickle
	AND.W	#%1,D4
	BEQ.S	.next
	MOVE.W	D0,(A3)+
.next	LEA	BytesPerLine(A0),A0
	DBF	D1,.printpoly
	MOVE.W	#$2300,SR
	BRA.S	HandleLoop

.dontdo	ILLEGAL




;--------------------------------------------------------------
Handle_Object_Flat:
	MOVE.W	#$2700,SR
	JSR	Wait_SendDSP
	MOVE.L	#"HAN",$FFFFA204.W
HandleLoop
	MOVE.W	#$2700,SR
	JSR	Wait_SendDSP
	MOVE.L	#"GET",$FFFFA204.W
	JSR	Wait_ReceiveDSP
	MOVE.L	$FFFFA204.W,D0
	CMP.W	#"ND",D0
	BEQ.S	.Done
	CMP.W	#"OL",D0
	BEQ	PrintPoly
	BRA.S	HandleLoop			;try again
.Done	MOVE.W	#$2300,SR
	RTS


























;--------------------basic i/o routines------------------------
max_width=320
SendOneOver
	LEA	$FFFFA204.W,A6
	BSR	Wait_SendDsp
	MOVEQ	#0,D0
.sendy:	MOVE.L	#$7FFFFF,D1
	TST.W	D0
	BEQ	.skipdiv
	DIVU.L	D0,D1
.skipdiv
 	bSR	WaitTransmit
	MOVE.L	D1,(A6)
	ADDQ.L	#1,D0
	CMP.W	#max_width,D0
	bne.s	.sendy
	RTS

;--------------------------------------------------------------
Send_Object:
	JSR	Wait_SendDsp
	MOVE.L	#"OBJ",$FFFFA204.W
	MOVE.L	(A0)+,D0
	BSR	Wait_SendDsp
	MOVE.L	D0,$FFFFA204.W
	SUBQ.L	#1,D0
.SendPoints:
	BSR	Wait_SendDsp		; not time-critical!
	MOVE.L	(A0)+,$FFFFA204.W
	DBF	D0,.SendPoints
	RTS
;--------------------------------------------------------------
Send_Texmap:
	MOVE.W	#$2700,SR
	LEA	Texmap_Buffer,A0
	JSR	Wait_SendDsp
	MOVE.L	#"TEX",$FFFFA204.W
	MOVE.L	#64*64,D0
	BSR	Wait_SendDsp
	MOVE.L	D0,$FFFFA204.W
	SUBQ.L	#1,D0
.SendPoints:
	BSR	Wait_SendDsp		; not time-critical!
	MOVE.W	(A0)+,$FFFFA206.W
	DBF	D0,.SendPoints

	LEA	Vertex_Buffer,A0
	JSR	Wait_SendDsp
	MOVE.L	#"VER",$FFFFA204.W
	MOVE.L	#16*2,D0
	BSR	Wait_SendDsp
	MOVE.L	D0,$FFFFA204.W
	SUBQ.L	#1,D0
.SendVertices:
	BSR	Wait_SendDsp		; not time-critical!
	MOVE.L	(A0)+,$FFFFA204.W
	DBF	D0,.SendVertices
	RTS

;--------------------------------------------------------------
Send_Shademap:
	MOVE.W	#$2700,SR
	LEA	Shademap_Buffer,A0
	JSR	Wait_SendDsp
	MOVE.L	#"TEX",$FFFFA204.W

	MOVE.L	#64*64,D0
	BSR	Wait_SendDsp
	MOVE.L	D0,$FFFFA204.W
	SUBQ.L	#1,D0
.SendPoints:
	BSR	Wait_SendDsp		; not time-critical!
	MOVE.W	(A0)+,$FFFFA206.W
	DBF	D0,.SendPoints

	MOVE.W	#$2300,SR
	MOVE.W	#$2700,SR
; Send Vertices
	LEA	Vertex_Buffer,A0
	JSR	Wait_SendDsp
	MOVE.L	#"VER",$FFFFA204.W
	MOVE.L	#16*2,D0
	BSR	Wait_SendDsp
	MOVE.L	D0,$FFFFA204.W
	SUBQ.L	#1,D0

.SendVertices:
	BSR	Wait_SendDsp
	MOVE.L	(A0)+,$FFFFA204.W
	DBF	D0,.SendVertices

	MOVE.W	#$2300,SR
	MOVE.W	#$2700,SR
; Send Colours
	LEA	Colour_Buffer_Shademap,A0
	JSR	Wait_SendDsp
	MOVE.L	#"COL",$FFFFA204.W
	MOVE.L	#32*16,D0
	BSR	Wait_SendDsp
	MOVE.L	D0,$FFFFA204.W
	SUBQ.L	#1,D0
.SendCols:
	BSR	Wait_SendDsp
	MOVE.W	(A0)+,$FFFFA206.W
	DBF	D0,.SendCols
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









;--------------------------------------------------------------
Send_Colours_Gour:
	LEA	Colour_Buffer_Gour,A0
	JSR	Wait_SendDsp
	MOVE.L	#"COL",$FFFFA204.W

	MOVE.L	#128*Number_Of_Gour_Colours,D0
	BSR	Wait_SendDsp
	MOVE.L	D0,$FFFFA204.W
	SUBQ.L	#1,D0
.SendPoints:
	BSR	Wait_SendDsp		; not time-critical!
	MOVE.W	(A0)+,$FFFFA206.W
	DBF	D0,.SendPoints
	RTS





Calc_Colours_Flat:
	LEA	Colour_List_Flat,A0
	LEA	Colour_Buffer_Flat,A1

	MOVE.W	#Number_Of_Flat_Colours-1,D7
.Calc_Colour:
	MOVE.L	#0,D0
	MOVE.L	(A0),D1
	MOVE.W	#24,D2		;Colour Span
	BSR	.Calc_Span
	MOVE.L	(A0)+,D0
	MOVE.L	#$FFFF00FF,D1
	MOVE.W	#08,D2
	BSR	.Calc_Span
	MOVE.W	#32-1,D0
.Kill	CLR.W	(A1)+
	DBF	D0,.Kill
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
	DIVU.W	Span_Length,D0
	ADD.W	A3,D0
	MOVE.W	D6,D1
	MULS.W	D4,D1
	DIVU.W	Span_Length,D1
	ADD.W	A4,D1
	MOVE.W	D6,D2
	MULS.W	D5,D2
	DIVU.W	Span_Length,D2
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
	ADDQ.W	#1,D6
	CMP.W	Span_Length,D6
	BNE.S	.Calc
	RTS

Calc_Colours_Gour:
	LEA	Colour_List_Gour,A0
	LEA	Colour_Buffer_Gour,A1
	MOVE.W	#Number_Of_Gour_Colours-1,D7
.Calc_Colour:
	MOVE.L	#$00000000,D0
	MOVE.L	#$00000000,D1
	MOVE.W	#20*2,D2	;D2 = Colour Span
	BSR	.Calc_Span

	MOVE.L	#$00000000,D0
	MOVE.L	(A0),D1
	MOVE.W	#28*2,D2
	BSR	.Calc_Span

	MOVE.L	(A0)+,D0
	MOVE.L	#$DFDF00DF,D1
	MOVE.W	#8*4,D2
	BSR	.Calc_Span
	;LEA	64*2(A1),A1
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
	DIVU.W	Span_Length,D0
	ADD.W	A3,D0
	MOVE.W	D6,D1
	MULS.W	D4,D1
	DIVU.W	Span_Length,D1
	ADD.W	A4,D1
	MOVE.W	D6,D2
	MULS.W	D5,D2
	DIVU.W	Span_Length,D2
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
	ADDQ.W	#1,D6
	CMP.W	Span_Length,D6
	BNE.S	.Calc
	RTS

;--------------------------------------------------
; Calculate 8 levels of the palette

Calc_Colours_Shademap:
	MOVE.W	#16,Span_Max
	LEA	Colour_Buffer_Shademap,A1
	MOVE.W	#0,Span_Shade
.Calc_Pal:
	BSR	Calc_Span1
	ADDQ.W	#1,Span_Shade
	CMP.W	#16,Span_Shade
	BNE.S	.Calc_Pal

	MOVE.W	#16,Span_Max
;	MOVE.W	#0,Span_Shade
;.Calc_Pal2:
;	BSR	Calc_Span2
;	ADDQ.W	#1,Span_Shade
;	CMP.W	#16,Span_Shade
;	BNE.S	.Calc_Pal2
	RTS



Calc_Span1:
	MOVE.L	D0,-(A7)
	LEA	shademap_Palette,A0
	MOVE.W	Span_Shade,D6
	MOVE.W	#32-1,D7
.Calc_Colour
	MOVEQ.L	#0,D0			;from...
	MOVE.L	(A0)+,D1		;...to
	BSR	Calc_Shade
	DBF	D7,.Calc_Colour
	MOVE.L	(A7)+,D0
	RTS

Calc_Span2:
	MOVE.L	D0,-(A7)
	LEA	shademap_Palette,A0
	MOVE.W	Span_Shade,D6
	MOVE.W	#32-1,D7
.Calc_Colour
	MOVE.L	(A0)+,D0
	MOVE.L	#$FFFF00FF,D1
	BSR	Calc_Shade
	DBF	D7,.Calc_Colour
	MOVE.L	(A7)+,D0
	RTS

Calc_Shade:
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
	AND.W	#$FF00,D0
	AND.W	#$FF00,D3

	LSR.W	#8,D0
	LSR.W	#8,D3

	SUB.W	D0,D3
	SUB.W	D1,D4
	SUB.W	D2,D5
	MOVE.W	D0,A3
	MOVE.W	D1,A4
	MOVE.W	D2,A5

	MOVE.W	D6,D0
	MULS.W	D3,D0
	DIVS.W	Span_Max(PC),D0
	ADD.W	A3,D0

	MOVE.W	D6,D1
	MULS.W	D4,D1
	DIVS.W	Span_Max(PC),D1
	ADD.W	A4,D1

	MOVE.W	D6,D2
	MULS.W	D5,D2
	DIVS.W	Span_Max(PC),D2
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
	RTS

Span_Shade:	DC.W	0
Span_Max	DC.W	0


RTE	RTE

;--------------------------------------------------------------
Test_Vga:
	MOVE.W	#$59,-(A7)
	TRAP	#14
	ADDQ.L	#2,A7
	RTS










;--------------------------------------------------------------




;			P I C T U R E S



;--------------------------------------------------------------
Copy_Pic:
	MULU.W	#8000,D0
	LEA	(Picture_1.L,D0.L),A1
	MOVE.L	Picture_Screen_Addr,A0
	LEA	160*20(A0),A0
	MOVE.W	#(8000/4)-1,D0
	MOVEQ	#0,D1
.CopyWord:
	MOVE.W	(A1)+,(A0)+
	MOVE.W	D1,(A0)+
	MOVE.L	D1,(A0)+
	MOVE.W	(A1)+,(A0)+
	MOVE.W	D1,(A0)+
	MOVE.L	D1,(A0)+
	DBF	D0,.CopyWord
	BRA	Set_PicScreen

Copy_Pics:
	MULU.W	#8000,D0
	MULU.W	#8000,D1
	MULU.W	#8000,D2
	MULU.W	#8000,D3
	LEA	(Picture_1.L,D0.L),A1
	LEA	(Picture_1.L,D1.L),A2
	LEA	(Picture_1.L,D2.L),A3
	LEA	(Picture_1.L,D3.L),A4

	MOVE.L	Picture_Screen_Addr,A0
	LEA	160*20(A0),A0
	MOVE.W	#(8000/4)-1,D0
	MOVEQ	#0,D1
.CopyWord:
	MOVE.W	(A1)+,(A0)+
	MOVE.W	(A2)+,(A0)+
	MOVE.W	(A3)+,(A0)+
	MOVE.W	(A4)+,(A0)+
	MOVE.W	(A1)+,(A0)+
	MOVE.W	(A2)+,(A0)+
	MOVE.W	(A3)+,(A0)+
	MOVE.W	(A4)+,(A0)+
	DBF	D0,.CopyWord
; Set Screen:
Set_PicScreen:
	MOVE.L	Picture_Screen_Addr,-(A7)
	MOVE.B	1(A7),$FFFF8201.W
	MOVE.B	2(A7),$FFFF8203.W
	MOVE.B	3(A7),$FFFF820D.W
	ADDQ.L	#4,A7
	RTS


Flash_Pics:
	BSR	Copy_Pics

	MOVE.L	#$2919,D7
	MOVEC	D7,CACR

	MOVE.W	#4,Flash_Speed
	TST.W	Vga_Flag
	BEQ.S	.Rgb
	MOVE.W	#2,Flash_Speed
.Rgb
	MOVE.L	#Do_Palette,my_vbl
	BSR	Init_Rez_Flash
	BSR	Wait_Vbl

	MOVE.W	#2,D0
	BSR	Wait_Music
	LEA	Flash_List_1,A0
	BSR	Start_Flash

	MOVE.W	#3,D0
	BSR	Wait_Music
	LEA	Flash_List_2,A0
	BSR	Start_Flash

	MOVE.W	#2,D0
	BSR	Wait_Music
	LEA	Flash_List_3,A0
	BSR	Start_Flash

	MOVE.W	#3,D0
	BSR	Wait_Music
	LEA	Flash_List_4,A0
	BSR	Start_Flash

	MOVE.L	#$0001,D0
	MOVEC	D0,CACR
	RTS

Start_Flash:
	LEA	Palette,A1
	MOVE.W	#8-1,D1
.Flash	MOVE.W	(A0)+,D2
	MOVE.B	#$F0,(A1,D2.W)
	DBF	D1,.Flash
	RTS

;--------------------------------------------------------------
Do_Palette:
	LEA	Palette+1,A0		;Don't do black!
	LEA	$FFFF9804.W,A1
	MOVEQ	#15-1,D0
.copyit:
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	SUB.W	Flash_Speed,D1
	BPL.S	.moveit
	MOVE.W	#0,D1

.moveit:
	MOVE.B	D1,-1(A0)

	MOVE.B	D1,(A1)+
	MOVE.B	D1,(A1)+
	MOVE.W	D1,(A1)+
	DBF	D0,.copyit
	RTS





;--------------------------------------------------------------
; Plane 1:
Flash_List_1:
	DC.W	1,3,5,7,9,11,13,15
; Plane 2:
Flash_List_2:
	DC.W	%0010
	DC.W	%0011
	DC.W	%0110
	DC.W	%0111
	DC.W	%1010
	DC.W	%1011
	DC.W	%1110
	DC.W	%1111
; Plane 3:
Flash_List_3:
	DC.W	%0100
	DC.W	%0101
	DC.W	%0110
	DC.W	%0111
	DC.W	%1100
	DC.W	%1101
	DC.W	%1110
	DC.W	%1111
; Plane 4:
Flash_List_4:
	DC.W	8,9,10,11,12,13,14,15


		INCLUDE	TRACKER.S



;--------------------------------------------------------------
		SECTION DATA
;--------------------------------------------------------------


Frame_Count	DS.W	1
Flat_Fade	DC.W	0
Flash_Speed	DC.W	0

Rotation_X	DS.W	1
Rotation_Y	DS.W	1
Rotation_Z	DS.W	1

LightRot_X	DS.W	1
LightRot_Y	DS.W	1
LightRot_Z	DS.W	1

RotSpeed_X	DC.W	8*6
RotSpeed_Y	DC.W	6*6
RotSpeed_Z	DC.W	4*6

LightSpeed_X	DC.W	4*8
LightSpeed_Y	DC.W	8*8
LightSpeed_Z	DC.W	6*8

Unit_Size	DC.L	$7FFF00

Scan_min	DS.L	1
Scan_max	DS.L	1
Screen_Centre	DS.L	1
third		DS.L	1
Picture_Screen_Addr
		DS.L	1

Object_Colour	DS.W	1
Span_Length	DS.W	1

Vga_Flag:	DS.W	1


Dsp_Routine_Flat:
		INCBIN	F:\DSP_NEW\DSP\TORFLAT2.DSP
		EVEN
Dsp_Routine_Gour:
		INCBIN	F:\DSP_NEW\DSP\TORGOUR2.DSP
		EVEN
Dsp_Routine_Texmap:
		INCBIN	F:\DSP_NEW\DSP\TORTEX.DSP
		EVEN
; This file is missing!
Dsp_Routine_Shademap:
		INCBIN	F:\DSP_NEW\DSP\TORTEX_S.DSP
		EVEN

;-----------------------------------------------------------


		CNOP	0,4
SineTable:	INCBIN	f:\data\trailsin.dat
CosTable:	EQU	SineTable+2048*2
		EVEN


;-----------------------------------------------------------
; These files can be produced (with difficulty) by using the
; GFA-Basic programs provided. I have no copies of the originals:
; my hard-disk is too small, so I have to wipe out files as I write
; new sourcecode. If anyone is willing to buy me a bigger HD so
; I can fully document the next Maggie intro, let me know.
Torus_Object:
		INCLUDE	F:\DATA\TDF\TORUSFLA.OB2
		EVEN
Torus_Object_Gour:
		INCLUDE	F:\DATA\TDF\TORUSGOU.OB2
		EVEN

Torus_Object_Texmap:
Torus_Object_Shademap:
		INCLUDE	F:\DATA\TDF\TORUSTES.OB2
		EVEN

;--------------------------------------------------------------
; Vertices for texture mapping
Vertex_Buffer:
		DC.L	$7f0000,$7f0000
		DC.L	$7f0000,$010000
		DC.L	$010000,$010000
		DC.L	$010000,$7f0000		;rotated 90degs

		DC.L	$010000,$7f0000
		DC.L	$7f0000,$7f0000
		DC.L	$7f0000,$010000
		DC.L	$010000,$010000

		DC.L	$010000,$010000
		DC.L	$7f0000,$010000
		DC.L	$7f0000,$7f0000
		DC.L	$010000,$7f0000

		DC.L	$7f0000,$010000
		DC.L	$7f0000,$7f0000
		DC.L	$010000,$7f0000
		DC.L	$010000,$010000

; The textures. Use a 64*64 Godpaint file or raw true-colour data
; file here:
Texmap_Buffer	EQU	*+6
		INCBIN F:\DATA\TDF\tunmap.GOD
		EVEN

; The shade-map texture
shademap_Buffer:
		INCBIN F:\DATA\TDF\TEXMAP2.MAP
		EVEN

;--------------------------------------------------------------
; Raw 320*240, 1 bitplane pics to flash on. Not included - too big!

Picture_1:	INCBIN	F:\PICS\1.rat
		EVEN
Picture_2:	INCBIN	F:\PICS\2.rat
		EVEN
Picture_3:	INCBIN	F:\PICS\3.rat
		EVEN
Picture_4:	INCBIN	F:\PICS\4.rat
		EVEN
Picture_5:	INCBIN	F:\PICS\5.rat
		EVEN
Picture_6:	INCBIN	F:\PICS\6.rat
		EVEN
Picture_7:	INCBIN	F:\PICS\7.rat
		EVEN
Picture_8:	INCBIN	F:\PICS\8.rat
		EVEN

Palette:	DCB.L	16,0


Colour_List_Flat:
		INCLUDE F:\DATA\TDF\TORCOL.S
		EVEN

; The colours for the gouraud torus
Colour_List_Gour:
;			 RR  GG      BB
		DC.B	$AF,$AF,$00,$AF
		DC.B	$7F,$7F,$00,$AF

shademap_Palette:
O		SET	0
		REPT	32
F		SET	(O*($eF-$4F)/32)+$4F
		DC.B	F,F,0,$eF
O		SET	O+1
		ENDR






;-----------------------------------------------------------
			SECTION	BSS
;-----------------------------------------------------------
Colour_Buffer_Flat:	DS.W	64*Number_Of_Flat_Colours
Colour_Buffer_Gour:	DS.W	128*Number_Of_Gour_Colours
Colour_Buffer_Shademap	DS.W	32*16


			CNOP	0,4
Polygon_Height		DS.L	1
Polygon_Top_Height	DS.L	1

Picture_Buffer:		DS.L	(Number_Of_Pictures*8000)/4

Picture_Screen		DS.L	4*40*240/4

			DS.L	300
stack:


; There. Don't say I never give you anything.



