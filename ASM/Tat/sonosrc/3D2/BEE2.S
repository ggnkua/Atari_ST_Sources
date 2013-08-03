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
Shademap_Mode2		EQU	1
Sequence_Mode		equ	1

xmax			EQU	383
ymax			EQU	099


ScreenLines		EQU	100
BytesPerLine		EQU	768
Lines			EQU	140
Pixels			EQU	384

Object_Width		EQU	384
Object_Height		EQU	100


Back_Colour		EQU	0
noscreens		EQU	3
Demo			EQU	1



start:

	IFNE	Demo
		INCLUDE	F:\Source\Tdf\Main\Equates.S
		output	c:\_demo\data\Bee.prg
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

		jsr	send_shademap
	IFNE Animation_Mode
		JSR	Animate_Init
		JSR	Animate_Object		;(once)
	ENDC

		bsr	Animate_Bee
		install_vbl	Animate_Bee
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
		clr.l	$ffff9800.w
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
		JSR	Spin_Object
	ENDC

		LEA	object_1_Data,A0
		BSR	Start_One_object
		BSR	ClearScreen

		BSR	Draw_object
		BSR	Draw_Cracks
	IFNE Keys
		BSR Draw_Info
		bsr	handle_keyboard
	ENDC

		BSR	screen_swap_three
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
		ADD.L	#(Pixels/2)*2+BytesPerLine*(100/2),A0
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
Spin_Object:
		MOVEM.L	Rotation_X,D0/D1/D2
		MOVEM.L	D0/D1/D2,LightRot_X

	IFNE Keys
		BSR	Handle_Keyboard
	ELSE
		MOVEM.L	Rotation_X,D0/D1/D2
		ADD.L	#25*3,D0
		ADD.L	#5*3,D1
		ADD.L	#6*3,D2
		MOVEM.L	D0/D1/D2,Rotation_X
	ENDC

		RTS



;--------------------------------------------------------------
screen_swap_three:
		move.l	physic,d0
		move.l	logic,physic
		move.l	third,logic
		move.l	d0,third
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
	s_setview	$0,$0,$0
	s_setcamera	$0,-$1000,$3000
	s_setcameramov	$0,+$80,0

	s_setrot	$d00,$0,$0		;upside down
	s_setrotmov	$0,+$50,0		;here he should drop down dazed
	;s_waitmusic	beat1+6,$30
	s_wait	900
	s_end
	ENDC



;--------------------------------------------------------------

	IFNE Animation_Mode
Animate_Data_1:	EQU	Sequence_misc_data+bee_wings


Animate_Init:
		LEA	$FFFFA204.W,A0
		 wait_transmit
		MOVE.L	#"A_I",(A0)

		LEA	Bee_Points_1,A1
		bsr	.Send_Morph

		bsr	.Send_Morph			;now normals too
		rts

.Send_Morph:
		MOVE.L	(A1)+,D0		;must be less than
						;maximum_points
		 wait_transmit
		MOVE.L	D0,(A0)			;point count

		SUBQ.W	#1,D0			;(for dbf)
.mo_loop:
		 wait_transmit
		MOVE.L	(A1)+,(A0)
		 wait_transmit
		MOVE.L	(A1)+,(A0)
		 wait_transmit
		MOVE.L	(A1)+,(A0)
		DBF	D0,.mo_loop
		RTS


Animate_Object:
		LEA	$FFFFA204.W,A0
		 wait_transmit
		MOVE.L	#"A_O",(A0)
		 wait_transmit
		MOVE.L	Animate_Data_1,(A0)
		RTS
	ENDC



;--------------------------------------------------------------
	IFNE	Shademap_Mode
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
.makeloop:
		MOVE.W	D7,-(A7)

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

Viewer_Size		dc.l	10000
























;--------------------------------------------------------------
			include	3dsys\linedraw.s
;--------------------------------------------------------------
crack_count		equ	sequence_misc_data+bee_cracks

Draw_Cracks:
		lea	crack_data,a0
		move.l	crack_count,d7
;		cmp.l	#crack_len,d7
;		beq.s	.done
;		addq.l	#1,crack_count
;.done
		subq.l	#1,d7
		bmi.s	.nodraw
.drawloop:
		movem.l	(a0)+,d0/d1
		move.w	(a0)+,d5
		movem.l	d7/a0,-(a7)
		bsr	Line_Draw
		movem.l	(a7)+,d7/a0
		dbf	d7,.drawloop
.nodraw:	rts

col1		equ	$841*31
col2		equ	$841*23
col3		equ	$841*16
col4		equ	$841*7

;--------------------------------------------------------------
crack_data:
		dc.w	192,50,220,40,col1
		dc.w	192,50,130,48,col1
		dc.w	192,50,202,71,col1

		dc.w	220,40,230,25,col2
		dc.w	220,40,275,38,col2
		dc.w	130,48,88,39,col2
		dc.w	130,48,123,51,col2	;"bend"
		dc.w	123,51,120,67,col2
		dc.w	202,71,193,95,col2
		dc.w	202,71,234,87,col2
; Third stage
		dc.w	230,25,228,13,col3
		dc.w	230,25,254,15,col3
		dc.w	275,38,310,28,col3
		dc.w	275,38,356,36,col3
		dc.w	88,39,56,23,col3	;"bend"
		dc.w	56,23,23,30,col3

		dc.w	88,39,70,44,col3	;"bend"
		dc.w	70,44,36,59,col3
;level 4:
		dc.w	234,87,240,99,col4
		dc.w	228,13,229,0,col4

crack_len	= (*-crack_data)/10

screenshake	equ	sequence_misc_data+bee_screenshake
shakedata	dc.l	0

;--------------------------------------------------------------
Animate_Bee:
		ADDQ.L	#1,Animate_Data_1
; Do screen shake:
		moveq	#0,d7
		;eor.l	#-1,shakedata
		tst.l	screenshake
		ble.s	.ok


; Find a random value between 0 and "screenshake"
		bsr	get_random
		and.l	#$ffff,d0
		move.l	screenshake,d1
		ext.l	d1
		divu	d1,d0
		swap	d0			;get modulus
		muls.l	#BytesPerLine,d0
		move.l	d0,d7
; do x coord too
		bsr	get_random
		and.l	#$ffff,d0
		move.l	screenshake,d1
		ext.l	d1
		divu	d1,d0
		swap	d0			;get modulus
		ext.l	d0
		add.l	d0,d0
		add.l	d0,d0
		add.l	d0,d7
		;and.l	shakedata,d7

		subq.l	#1,screenshake		;do this last!!
.ok:
; Now set the screen
		add.l	physic,d7
		move.l	d7,-(a7)
		MOVE.B	1(A7),$ffff8201.W
		MOVE.B	2(A7),$ffff8203.W
		MOVE.B	3(A7),$ffff820d.W
		addq.l	#4,a7
		RTS


;--------------------------------------------------------------

Bee_Points_1:	INCLUDE	c:\_data\_ob3\Bee2.Ext

;--------------------------------------------------------------
;						get_random
get_random:	movem.w	random_seed,d0/d1/d2
		add.w	d1,d0
		add.w	#1,d0
		mulu.w	#259,d0
		mulu.w	#59,d1
		add.w	#17,d1
		mulu.w	#9,d2
		add.w	#7,d2
		movem.w	d0/d1/d2,random_seed
		rts

random_seed:	dc.w	0,0,0

	IFNE Keys
		include	3dsys\text.s
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
			INCBIN	F:\Dsp_New\Dsp\Bee.Dsp
			EVEN

;--------------------------------------------------------------
;	3D OBJECTS
;--------------------------------------------------------------

object_Object:
			INCLUDE F:\DATA\TDF\Ob3\TexBee.Ob3
			EVEN

;--------------------------------------------------------------
;	GRAPHICS
;--------------------------------------------------------------

Texmap_Data		EQU	*+6
			INCBIN	'd:\Texture1.Dat'
Texmap_Data_2		EQU	*+6
			INCBIN	'd:\Texture2.Dat'
Texmap_Palette_Data	INCBIN	'd:\Texture5.Pal'
Texmap_Palette_Data_2	INCBIN	'd:\Texture2.Pal'
Texmap_Palette_Data_3	INCBIN	'd:\Texture3.Pal'
			EVEN

	IFNE	Shademap_Mode2
Shademap_Buffer		INCBIN	'C:\_Data\_Map\Envmap2.Map'
	ENDC


;--------------------------------------------------------------
			SECTION	BSS
			CNOP	0,4
Scan_min		DS.L	1
Scan_max		DS.L	1
Screen_Centre		DS.L	1
Texmap_Palette_2	DS.W	256*16
Texmap_Buffer		DS.W	64*64*16*4
			EVEN

			DS.L	300
stack

