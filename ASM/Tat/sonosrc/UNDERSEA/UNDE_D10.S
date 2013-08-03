








				avena_1_9_96:




Tracker_On	EQU	0

ScreenLines	EQU	100
BytesPerLine	EQU	768
Lines		EQU	100
Pixels		EQU	384

Object_Width	EQU	384
Object_Height	EQU	100
Number_Of_Colours EQU	4
Back_Colour	EQU	-1

xmax		EQU	383
ymax		EQU	099
Keys		EQU	0
Direction	EQU	0


; Setups for init-files:
noscreens	EQU	3
Demo		EQU	1
max_scanlines	equ	5000





start:

	IFNE	Demo
		INCLUDE	F:\Source\Tdf\Main\Equates.S
		output	c:\_demo\data\fish.prg
		opt	nodebug
	ENDC



	IFEQ	Demo
		INCLUDE EQUATES.S
		INCLUDE	TOSSTART.I
	ELSE
		INCLUDE	DEMSTART.I
	ENDC


;--------------------------------------------------------------
Initialize_Routine:
		jsr	Calc_Colours_Gouraud
		bsr	Calc_Blur_Tables
		RTS

Display_Routine:
loop:
	IFNE Demo
		init_screens
	ENDC
		LEA	Fish_Sequence_1,A0
		JSR	Init_Sequencer
		BSR	Do_Effects

		MOVEQ	#-1,D1
		BSR	ClearScreen
		BSR	screen_swap

	IFEQ	Demo
		bra	loop
		ILLEGAL
	ELSE
	IFNE Demo
		update_screens
	ENDC
		MOVE.L	(A7)+,A0		;restore stack info
		RTS
	ENDC


;--------------------------------------------------------------



MyScreenSize	equ	BytesPerLine*ScreenLines
ReptVal     	equ	(MyScreenSize/13/4/16)
Remainder	equ	(MyscreenSize-(ReptVal*13*4*16))/4

ClearScreen:
		move.l	logic,A6
		add.l	#MyScreenSize,a6

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



;--------------------------------------------------------------------
Do_Effects:
		MOVE.W	#$2300,SR
		JSR	Sequencer

main_loop:
	ifeq Demo
		tst.b	keyboard_matrix+$1
		bne.s	.nodraw
		jsr	([sequence_routine.l])
		bra.s	.skipvbl
.nodraw:
		bsr	wait_vbl
.skipvbl:
	else
		jsr	([sequence_routine.l])
	endc
		JSR	Sequencer		;aha!
		tst.w	sequence_end_flag
		beq	main_loop
		RTS




;--------------------------------------------------------------
Init_Routine:
		MOVE.W	#$2300,SR
		BSR	clearscreens
		BSR	screen_swap
		bsr	wait_vbl
		bsr	Set_res
		OR.W	#$1,$FFFF82C2.W
		RTS

;--------------------------------------------------------------




Init_Normal_Routine:
		move.l	#$3fff,Viewer_Distance
		MOVE.L	#150000,Viewer_Size

		init_dsp_routine Dsp_Routine_Fish,$210

		JSR	SendOneOver
		LEA	Texmap_Buffer,A0
		JSR	Send_Texmap

		LEA	Clipping_Data_Normal,A0
		JSR	Send_Clipping
		bsr	init_bubbles

		LEA	Fish_Object_Normal,A0
		JSR	Send_Object
		bsr	init_rays
		
		BSR	Init_Routine
		RTS

Init_Dolphin_Routine:
		move.l	#$3fff,Viewer_Distance
		MOVE.L	#150000,Viewer_Size

		init_dsp_routine Dsp_Routine_Fish,$210
		JSR	SendOneOver

		;LEA	Texmap_Buffer_2,A0
		LEA	Texmap_Buffer,A0
		JSR	Send_Texmap

		LEA	Clipping_Data_Normal,A0
		JSR	Send_Clipping

		LEA	Dolphin_Object_Normal,A0
		JSR	Send_Object
		
		;BSR	Init_Routine		; screen already clear
		RTS

Init_Blur_Routine:
		MOVEQ	#9,D0
		MOVEC	D0,CACR

		MOVE.L	#$00040004,D1
		BSR	ClearScreen
		BSR	screen_swap
		MOVE.L	#$00040004,D1
		BSR	ClearScreen
		BSR	screen_swap
		MOVE.L	#$00040004,D1
		BSR	ClearScreen
		BSR	screen_swap

		move.l	#$7fff,Viewer_Distance
		MOVE.L	#150000/2,Viewer_Size
		init_dsp_routine Dsp_Routine_FishBlur,$210
		JSR	SendOneOver

		LEA	Fish_Object_Blur,A0
		JSR	Send_Object

		jsr	Send_Colours_Gouraud

		LEA	Clipping_Data_Blur,A0
		JSR	Send_Clipping
		RTS



Do_Normal_Routine:
; set res
		CLR.W	$FFFF820E.W

		MOVE.W	#$2300,SR
		;MOVE.L	#Back_Colour,D1
		;BSR	ClearScreen

		MOVE.w	sequence_ray_pos,D0
		BSR	do_rays
		BSR	display_rays

		LEA	Draw_Fish,A1
		LEA	Fish_1_Data,A0
		MOVEQ	#6-1,D0
		BSR	Draw_Fishes
		MOVE.L	#16*$8400840,D0
		BSR	do_bubbles
		BSR	screen_swap
		RTS

Do_Dolphin_Routine:
		MOVE.W	#$2300,SR
		MOVE.w	sequence_ray_pos,D0
		BSR	do_rays
		BSR	display_rays

		LEA	Draw_Fish,A1
		LEA	Fish_3_Data,A0
		MOVEQ	#1-1,D0
		BSR	Draw_Fishes

		MOVE.L	#16*$8400840,D0
		BSR	do_bubbles
		BSR	screen_swap
		RTS




Do_Blur_Routine:
		MOVE.W	#$2300,SR

		LEA	Draw_Blur_Fish,A1
		LEA	Fish_2_Data,A0
		MOVEQ	#20-1,D0		;was 15-1
		BSR	Draw_Fishes

		BSR	MotionBlurScreen
		BSR	screen_swap
		move.l	sequence_zoom,d0
		sub.l	D0,Viewer_Distance
		RTS

;--------------------------------------------------------------
Draw_Fishes:
		MOVE.L	A1,Fish_Draw_Routine
		MOVE.L	#scanlines,scanline_pointer
.fishloop:
		MOVEM.L	D0/A0,-(A7)
		BSR	Start_One_Fish
		JSR	([Fish_Draw_Routine.l])
		MOVEM.L	(A7)+,D0/A0
		LEA	Fish_Data_Length(A0),A0
		DBF	D0,.fishloop

; Make sure bottom scanline is included in possible bubble
; positions

;		move.l	scanline_pointer,a6
;		move.l	logic,d1
;		add.l	#BytesPerLine*(Lines-1),d1
;
;		move.w	#(Pixels/2-1),d0
;.copy		move.l	d1,(a6)+
;		addq.l	#4,d1			;next pixel!
;		dbf	d0,.copy
;
;		move.l	a6,scanline_pointer

		RTS
;--------------------------------------------------------------





Start_One_Fish:
		MOVE.L	A0,Current_Fish

		BSR	Send_Fish_Colour
		MOVE.L	Current_Fish,A0
		BSR	Animate_Fish

		MOVE.L	Current_Fish,A0
		BSR	Send_Viewpoint

		BSR	MakeMatrixLight		;Must be done FIRST
		BSR	MakeMatrixObject
		wait_transmit
		MOVE.L	#"CAL",$FFFFA204.W
		wait_transmit
		MOVE.L	#"HAN",$FFFFA204.W
		RTS

;--------------------------------------------------------------

Draw_Fish:
		MOVE.L	Logic,A0
		BSR	Handle_Object_World
		RTS

Draw_Blur_Fish:
		MOVE.L	logic,A0
		BSR	Handle_Object_Blur
		RTS

;--------------------------------------------------------------

MakeMatrixObject:
		MOVEM.L	Rotation_X,D0/D1/D2
		MOVE.L	#"MAT",D7
		BRA.S	DoMatrix
MakeMatrixLight:
		;MOVEM.L	LightRot_X,D0/D1/D2
		MOVEM.L	Rotation_X,D0/D1/D2
		MOVE.L	#"LIG",D7
; Expansion to allow fading using the unit_vector?

DoMatrix:
		AND.L	#$1FFF,D0
		AND.L	#$1FFF,D1
		AND.L	#$1FFF,D2
		LEA	CosTable,A0
		LEA	SineTable,A1
		wait_transmit
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
; This version saves a pointer to the lhs of every scanline!!!
; Assumes < 26K scanlines done

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
		MOVE.L	scanline_pointer,A6
.HandleLoop
		wait_transmit
		MOVE.L	#"GET",$FFFFA204.W
.wr2:
		wait_receive
		 MOVE.W	(A1),D0
		 BMI .Done		;assume envmap
.get_texmap:
		 wait_receive
		 MOVE.W	(A1),D6		;get top_height
		 MULS.W	D7,D6
		 LEA	(A4,D6.L),A0
		 MOVE.W	(A1),D1
		 SUBQ.W	#1,D1
		 BMI.S	.Dontdo
.printpoly2:
		wait_receive
		MOVE.W	(A1),D2
		LEA	(A0,D2.W*2),A3	
		move.l	a3,(a6)+		;save scanline
		wait_receive
		MOVE.W	(A1),D3
		SUBQ.W	#1,D3
		BMI.S	.next2
		wait_receive
.PP2	   	MOVE.W	(A1),(A3)+
		DBRA	D3,.PP2
.next2	  	ADD.L	D7,A0
		DBF	D1,.printpoly2
.Dontdo
		BRA	.HandleLoop

.Done:
		MOVE.L	A6,scanline_pointer
		MOVE.L	#$1919,D0
		MOVEC	D0,CACR
		RTS


;--------------------------------------------------------------
Handle_Object_Blur:
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
		MOVE.L	scanline_pointer,A6
.HandleLoop
		wait_transmit
		MOVE.L	#"GET",$FFFFA204.W
.wr2:
		wait_receive
		 MOVE.W	(A1),D0
		 BMI .Done
		 JMP .polylist(PC,D0.W*4)
.polylist:
		BRA.W	.get_gouraud		;2
		BRA.W	.get_gouraud		;2
		BRA.W	.get_gouraud		;2
		BRA.W	.get_texmap		;3
.get_gouraud:
		 wait_receive
		 MOVE.W	(A1),D6		;get top_height
		 MULS.W	D7,D6
		 LEA	(A4,D6.L),A0
		 MOVE.W	(A1),D1
		 SUBQ.W	#1,D1
		 BMI.S	.Dontdo
.printpoly:
		  wait_receive
		  MOVE.W (A1),D2
		  LEA (A0,D2.W*4),A3
			;move.l	a3,(a6)+
		  MOVE.W (A1),D3
		  SUBQ.W #1,D3
		  BMI.S	.next
		  wait_receive

.PP	   	MOVE.W (A1),D0
		   ADD.W D0,(A3)
		   ADDQ.L #4,A3
		  DBRA	D3,.PP

.next	  	ADD.L D7,A0
		 DBF	D1,.printpoly
.dontdo	BRA	.HandleLoop

.get_texmap:
;		 wait_receive
;		 MOVE.W	(A1),D6		;get top_height
;		 MULS.W	D7,D6
;		 LEA	(A4,D6.L),A0
;		 MOVE.W	(A1),D1
;		 SUBQ.W	#1,D1
;		 BMI.S	.Dontdo2
;.printpoly2:
;		  wait_receive
;		  MOVE.W (A1),D2
;		  LEA (A0,D2.W*4),A3
;			move.l	a3,(a6)+
;		  MOVE.W (A1),D3
;		  SUBQ.W #1,D3
;		  BMI.S	.next2
;		  wait_receive
;.PP2
;		   MOVE.W (A1),D0
;		   ADD.W D0,(A3)
;		   ADDQ.L #4,A3
;		  DBRA	D3,.PP2
;
;.next2	  ADD.L D7,A0
;.Dontdo2: DBF	D1,.printpoly2
		BRA	.HandleLoop

.Done:
		MOVE.L	a6,scanline_pointer
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
		wait_transmit
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
Send_Texmap:
		wait_transmit
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


;--------------------------------------------------------------
Send_Clipping:
		wait_transmit
		MOVE.L	#"CLI",$FFFFA204.W
		MOVEQ.L	#4-1,D0
.SendPoints:
		wait_transmit		; not time-critical!
		MOVE.L	(A0)+,$FFFFA204.W
		DBF	D0,.SendPoints
		RTS


;--------------------------------------------------------------
Animate_Fish:
		wait_transmit
		MOVE.L	#"FIS",$FFFFA204.W		;calc fish distort
		wait_transmit
		MOVE.L	Fish_DOffset(A0),$FFFFA204.W	;send distort
		wait_transmit
		MOVE.L	Fish_DSize(A0),$FFFFA204.W
		MOVE.L	Fish_DSpeed(A0),D0		;update offset
		ADD.L	D0,Fish_DOffset(A0)
		AND.L	#$FF,Fish_DOffset(A0)
		RTS

;--------------------------------------------------------------
Send_Fish_Colour:
		wait_transmit
		MOVE.L	#"FCO",$FFFFA204.W
		wait_transmit
		MOVE.L	Fish_Colour(A0),$FFFFA204.W	;send distort
		RTS

;--------------------------------------------------------------



Set_Res:
		INCLUDE	F:\DATA\TDF\RES\3DSYS3.S
		RTS

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





;--------------------------------------------------------------
Send_Blur_Texmap:
		LEA	Texmap_Buffer,A0
		wait_transmit
		MOVE.L	#"TEX",$FFFFA204.W
		MOVE.L	#64*64,D0
		wait_transmit
		MOVE.L	D0,$FFFFA204.W
		SUBQ.L	#1,D0
.SendPoints:
		MOVE.W	(A0)+,D1
		LSR.W	#2,D1
		AND.W	#%0011100111100111,D1
		wait_transmit		; not time-critical!
		MOVE	D1,$FFFFA206.W
		DBF	D0,.SendPoints
		RTS

;--------------------------------------------------------------
Send_Colours_Gouraud:
		LEA	Colour_Table_Gouraud,A0
		wait_transmit
		MOVE.L	#"COL",$FFFFA204.W

		MOVE.L	#128*Number_Of_Colours,D0
		wait_transmit
		MOVE.L	D0,$FFFFA204.W
		SUBQ.L	#1,D0
.SendPoints:
		MOVE.W	(A0)+,d1
		LSR.W	#3,D1
		AND.W	#%0001100011100011,D1
		wait_transmit		; not time-critical!
		MOVE.W	D1,$FFFFA206.W
		DBF	D0,.SendPoints
		RTS


;--------------------------------------------------------------
Calc_Blur_Tables:
		BSR	Calc_Colour_Table
		BSR	Calc_Colour_Table2
		RTS

;--------------------------------------------------------------
; We can do the tables in a much easier manner:
Calc_Colour_Table:
		LEA	Colour_Table,A0
		MOVEQ	#32-1,D7		;red count
		LEA	Blurring_Table_Red,A1
.CalcLoop1:
		MOVE.W	(A1)+,D1
		MOVEQ	#32-1,D6		;green count
		LEA	Blurring_Table_Green,A2
.CalcLoop2:
		MOVE.W	(A2)+,D2
		OR.W	D1,D2
		MOVEQ	#64-1,D5		;blue count * 2...green bottom not used!
		LEA	Blurring_Table_Blue,A3
.CalcLoop3:
		MOVE.W	(A3)+,D3
		OR.W	D2,D3
		MOVE.W	D3,(A0)+
		DBF	D5,.CalcLoop3
		DBF	D6,.CalcLoop2
		DBF	D7,.CalcLoop1
		RTS

Calc_Colour_Table2:
		LEA	Colour_Table_2,A0
		MOVEQ	#32-1,D7		;red count
		LEA	Blurring_Table_Red2,A1
.CalcLoop1:
		MOVE.W	(A1)+,D1
		MOVEQ	#32-1,D6		;green count
		LEA	Blurring_Table_Green2,A2
.CalcLoop2:
		MOVE.W	(A2)+,D2
		OR.W	D1,D2
		MOVEQ	#64-1,D5		;blue count * 2...green bottom not used!
		LEA	Blurring_Table_Blue2,A3
.CalcLoop3:
		MOVE.W	(A3)+,D3
		OR.W	D2,D3
		MOVE.W	D3,(A0)+
		DBF	D5,.CalcLoop3
		DBF	D6,.CalcLoop2
		DBF	D7,.CalcLoop1
		RTS

;--------------------------------------------------------------
Calc_Colours_Gouraud:
		LEA	Colour_List_Gouraud,A0
		LEA	Colour_Table_Gouraud,A1
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
		AND.W	#%0000011111000000,D1
		AND.W	#%0000000000011111,D2
		OR.W	D0,D2
		OR.W	D1,D2
		MOVE.W	D2,(A1)+
		ADDQ.W	#1,D6
		CMP.W	(a7),D6
		BNE.S	.Calc

		move.w	(a7)+,d2
		RTS

;--------------------------------------------------------------
MotionBlurScreen:
		MOVE.L	#$0019,D0
		MOVEC	D0,CACR

		MOVE.L	third,A0
		MOVE.L	logic,A1

		add.l	#BytesPerLine*0,a0
		add.l	#BytesPerLine*0+4,a1

		LEA.L	Colour_Table,A2
		TST.W	sequence_fade
		beq.s	.ok1
		LEA.L	Colour_Table_2,A2
.ok1
		MOVE.L	#$00040004,D5
		MOVE.W	#100-1,D0
		MOVEQ	#0,D4
.Blurringloop1:
		MOVE.W	#(192/4)-1,D3
		MOVE.L	d5,D2
.Blurringloop2:
		REPT	4
		 move.w	(a1),d4
		 MOVE.W	(A2,D4.L*2),D2
		 MOVE.L	D2,(A0)+
		 SWAP	D2
		 ADDQ.L	#4,a1
		ENDR
		DBF	D3,.Blurringloop2
		DBF	D0,.Blurringloop1
		RTS







		INCLUDE	3DSYS\VIEW.S
		include	seq.s
		include	und_bac2.s



		SECTION DATA

* 3d labels:
Rotation_X	DC.L	$0000
Rotation_Y	DC.L	$0000
Rotation_Z	DC.L	$0000

LightRot_X	DS.L	1
LightRot_Y	DS.L	1
LightRot_Z	DS.L	1

Viewer_x	DS.L	1
Viewer_y	DS.L	1
Viewer_z	DS.L	1

Camera_X	dc.l	0
Camera_Y	dc.l	0
Camera_Z:
Viewer_Distance	DC.L	$3FF0
Viewer_Size	DC.L	150000

Current_Fish:	DC.L	0

Dsp_Routine_Fish:
		INCBIN	F:\Dsp_New\Dsp\Undersea.Dsp
		EVEN
Dsp_Routine_FishBlur:
		INCBIN	F:\Dsp_New\Dsp\UnderBlu.Dsp
		EVEN


		CNOP	0,4
SineTable:	INCBIN	f:\data\trailsin.dat
CosTable:	EQU	SineTable+2048*2
		EVEN

;-----------------------------------------------------------
Fish_Object_Normal:
		INCLUDE c:\_data\_ob3\Fish_Env.Ob3
Dolphin_Object_Normal:
		INCLUDE c:\_data\_ob3\Dol_Env.Ob3
Fish_Object_Blur:
		INCLUDE c:\_data\_ob3\Fish_Gou.Ob3
		EVEN

Texmap_Buffer	EQU	*+6
		INCBIN f:\DATA\tdf\gfx\envmap5.god
		;INCBIN c:\_data\_gfx\tmap6.god
		EVEN

Texmap_Buffer_2	;EQU	*+6
		;INCBIN C:\_DATA\_gfx\env_sea.god
		;EVEN


Colour_List_Gouraud:
		DC.W	4		;total number
		DC.W	3
		DC.L	48,$f0f000f0,$F0F000b0	;black --> yellow
		DC.L	32,$F0F000b0,$b0F000b0	;yellow--> green
		DC.L	48,$b0F000b0,$F0F000F0	;green  --> white

		DC.W	3
		DC.L	48,$f0f000f0,$c0c000f0	;white --> lblue
		DC.L	32,$c0c000f0,$f0b000b0	;lblue --> pink
		DC.L	48,$f0b000b0,$F0F000F0	;pink  --> white
		DC.W	3
		DC.L	48,$f0f000f0,$c0c000c0	;white --> grey
		DC.L	32,$c0c000c0,$b0b000b0	;grey  --> dgrey
		DC.L	48,$b0b000b0,$F0F000F0	;dgrey  --> white
		DC.W	3
		DC.L	48,$f0f000f0,$b0b000b0	;white --> red
		DC.L	32,$f0b000b0,$f0b000b0	;red   --> blue
		DC.L	48,$f0b000F0,$F0F000F0	;blue  --> white

;--------------------------------------------------------------
Feed	MACRO
		DC.W	\1*00
		DC.W	\1*00,\1*00		;,\1*00,\1*00
		DC.W	\1*01,\1*02,\1*03,\1*04
		DC.W	\1*05,\1*06,\1*07,\1*08
		DC.W	\1*09,\1*10,\1*11,\1*12
		DC.W	\1*13,\1*14,\1*15,\1*16
		DC.W	\1*17,\1*18,\1*19,\1*20
		DC.W	\1*21,\1*22,\1*23,\1*24
		DC.W	\1*24,\1*24,\1*24,\1*24
		DC.W	\1*24		;,\1*24		;,\1*21	;,\1*23
		ENDM

FeedBlue MACRO
		DC.W	\1*04
		DC.W	\1*04,\1*04		;,\1*00,\1*00
		DC.W	\1*04,\1*04,\1*04,\1*04
		DC.W	\1*05,\1*06,\1*07,\1*08
		DC.W	\1*09,\1*10,\1*11,\1*12
		DC.W	\1*13,\1*14,\1*15,\1*16
		DC.W	\1*17,\1*18,\1*19,\1*20
		DC.W	\1*21,\1*22,\1*23,\1*24
		DC.W	\1*24,\1*24,\1*24,\1*24
		DC.W	\1*24		;,\1*24		;,\1*21	;,\1*23
		ENDM

Feed2 MACRO
		DC.W	\1*01
		DC.W	\1*02,\1*03
		DC.W	\1*04,\1*05,\1*06,\1*07
		DC.W	\1*08,\1*09,\1*10,\1*11
		DC.W	\1*12,\1*13,\1*14,\1*15
		DC.W	\1*16,\1*17,\1*18,\1*19
		DCb.W	13,\1*20
		ENDM


Blurring_Table_Red:	Feed	$0800
Blurring_Table_Green:	Feed	$0040
Blurring_Table_Blue:	FeedBlue $0001
			FeedBlue $0001		;twice wegen greenscales

Blurring_Table_Red2:	Feed2	$0800
Blurring_Table_Green2:	Feed2	$0040
Blurring_Table_Blue2:	Feed2	$0001
			Feed2	$0001		;twice wegen greenscales

Clipping_Data_Normal:	DC.L	-192,+191,-50,+50
Clipping_Data_Blur:	DC.L	-096,+095,-50,+50




;--------------------------------------------------------------


randomise		MACRO
\1			SET	((\1*\2)+1)&$FFFFFFFF
			ENDM

o			set	"Tat!"

random3			MACRO
			DC.L	(o&\1)-(\1/2)
			randomise o,257
			DC.L	(o&\1)-(\1/2)
			randomise o,257
			DC.L	(o&\1)-(\1/2)
			randomise o,257
			ENDM

random2			MACRO
			DC.L (o&$f)+$8		;speed
			randomise o,17
			DC.L (o&$3f)+$1f	;size
			randomise o,17
			DC.L 0			;offset
			ENDM



Fish_1_Data:
		REPT	10
			random3	$7ff
			random2
			dc.l	0
		ENDR

col		SET	0
Fish_2_Data:
			dc.l	20,0,0		;must be central!
			dc.l	$f,$1F,0
			DC.L	col
col			SET	((col+1)&%11)

		REPT	19
			random3	$fff
			random2
			DC.L	col
col			SET	((col+1)&%11)
		ENDR

Fish_3_Data:
			DC.L	0,0,0
			DC.L	0,0,0		;speed size offset
			DC.L	0


;--------------------------------------------------------------
		RSRESET
Fish_X		RS.L	1
Fish_Y		RS.L	1
Fish_Z		RS.L	1
Fish_DSpeed	RS.L	1
Fish_DSize	RS.L	1
Fish_DOffset	RS.L	1
Fish_Colour	RS.L	1
Fish_Data_Length RS.B 1



;--------------------------------------------------------------
; Non-Blurred section:
Fish_Sequence_1:
		dc.w	seq_set_rout,0,0
		dc.w	seq_init_rout,0
		dc.w	seq_set_rays,rays_norm,4
					 ;fade rays down - quick
		dc.w	0

	;ifne 0
		dc.w	seq_set_rot,$000,$000,-$800
		dc.w	0
		dc.w	seq_set_rotmov,4,+(14*256)/80,+(14*256)/80
		dc.w	0
		dc.w	seq_set_view,+1400,+700,0
		dc.w	0
		dc.w	seq_set_viewmov,-1400/70,-700/70,0
		dc.w	70
		dc.w	seq_set_viewmov,-20,0,0
		dc.w	120
	;endc
		dc.w	seq_close,0

;Fish_Sequence_1:
; Dolphin section:
		dc.w	seq_set_rout,2
		dc.w	0
		dc.w	seq_init_rout
		dc.w	0
	;ifne 0
		dc.w	seq_set_rot,$100,$0,0
		dc.w	0
		dc.w	seq_set_view,-$980,0,0
		dc.w	0
		dc.w	seq_set_rotmov,0,-12,0	 ;slow rotation
		dc.w	0
		dc.w	seq_set_viewmov,+$18*2,0,0
		dc.w	140/2

		dc.w	seq_set_viewmov,+$18,0,0
		dc.w	0
		dc.w	seq_set_rotmov,-16*2,-24,4  ;slow rotation
		dc.w	10
		dc.w	seq_set_rotmov,-16*2,-26,0  ;slow rotation
		dc.w	10
		dc.w	seq_set_rotmov,-16*2,-28,-4  ;slow rotation
		dc.w	10
		dc.w	seq_set_rotmov,-16*2,-30,-8  ;slow rotation
		dc.w	10
		dc.w	seq_set_rotmov,-16*2,-32,-16  ;slow rotation
		dc.w	128-128
		dc.w	seq_set_rays,rays_off,1	 ;fade rays down
		dc.w	128
	;endc
; Go...
		dc.w	seq_close,0

; Blurred section:
		dc.w	seq_set_rout,1
		dc.w	0
		dc.w	seq_init_rout
		dc.w	0
		dc.w	seq_set_rot,$800,$0,-$800 ; upwards
		dc.w	0
		dc.w	seq_set_rotmov,0,-7,16	  ;slow rotation
		dc.w	0
		dc.w	seq_set_lrot,$0,$0,$0
		dc.w	0
		dc.w	seq_set_lrotmov,40,+20,0  ;shade stays central
		dc.w	0
		dc.w	seq_set_view,+$d00,256*0,0
		dc.w	0
		dc.w	seq_set_viewmov,-$d,-1*0,0
		dc.w	256-$40
		dc.w	seq_set_zoom,$4000/$40
		dc.w	0
		dc.w	seq_set_rotmov,0,-7*2,16*2  ;slow rotation
		dc.w	$40
		dc.w	seq_set_fade
		dc.w	32
; Go...
		dc.w	seq_close,0
		dc.w	seq_end,500

;--------------------------------------------------------------
			SECTION	BSS

			;CNOP	0,4
scanline_pointer	DS.L	1
Scan_min		DS.L	1
Scan_max		DS.L	1
Screen_Centre		DS.L	1
Fish_Draw_Routine	DS.L	1

Colour_Table_Gouraud:	DS.W	128*Number_Of_Colours
scanlines		ds.l	max_scanlines
check_empty:

Colour_Table:		DS.W	65536
Colour_Table_2:		DS.W	65536

			DS.L	300
stack:





