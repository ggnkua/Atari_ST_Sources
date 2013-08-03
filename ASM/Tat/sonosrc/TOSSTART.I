init_dsp	MACRO
		JSR	dsp_library+0
		ENDM

init_dsp_routine MACRO
		LEA	(\1),A0
		JSR	dsp_library+4
		LEA	(\2).W,A0
		JSR	dsp_library+8
		ENDM

install_vbl	MACRO
		move.l	#\1,my_vbl
		ENDM


		CLR.L -(A7)
		MOVE.W #$20,-(A7)
		TRAP #1
		MOVE.L D0,save_stack
		ADDq.L #6,A7		;use existing stacks
		BSR savevectors
		BRA program_start

		INCLUDE F:\SOURCE\TDF\VECTORS.S

program_start:
; Set original vectors and screens etc.

		LEA	stack,A7
		MOVE.W	#$2700,sr
		LEA	mouse_on(PC),A0
		BSR	send_ikbd

;---------------------------------------------------------------
		MOVE.L	#STACK+4000,D0		;top of memory - change!
		SUB.B	D0,D0
		MOVE.L	D0,logic
		ADD.L	#BytesPerLine*Lines,D0
		MOVE.L	D0,physic
		 IFEQ noscreens-3
		ADD.L	#BytesPerLine*Lines,D0
		MOVE.L	D0,third
		 ENDC
		MOVE.W	#$2300,SR

		MOVE.L	#vbl,$70.W
		MOVE.L	#keyboard,$118.W
		MOVE.L	#$ff00ff40,$fffffA06.W
		MOVE.L	#$ff00ff40,$fffffA12.W
		BCLR	#3,$fffffA17.W 

begin:
		init_dsp
		BSR	ClearScreens
		BSR	Initialize_Routine
		move.w	#-1,d7			;do 65535 frames ;)
		JSR	Display_Routine
		ILLEGAL


; Utility routines:
;--------------------------------------------------------------
screen_swap:
	IFEQ	noscreens-3
		MOVE.L	logic,D0
		MOVE.L	third,logic
		MOVE.L	physic,third
		MOVE.L	D0,physic
	ELSE
		MOVE.L	logic,D0
		MOVE.L	physic,logic
		MOVE.L	D0,physic
	ENDC
		MOVE.L	physic,-(A7)
		MOVE.B	1(A7),$ffff8201.W
		MOVE.B	2(A7),$ffff8203.W
		MOVE.B	3(A7),$ffff820d.W
		ADDQ.L	#4,A7
		RTS

;--------------------------------------------------------------
ClearScreens:
		MOVE.L	physic,A0
		MOVE.L	logic,A1
	IFEQ	noscreens-3
		MOVE.L	third,A2
	ENDC
		MOVE.L	#Back_Colour,D0
		MOVE.L	#ScreenLines*BytesPerLine/4,D1
.Wipe:		MOVE.L	D0,(A0)+
		MOVE.L	D0,(A1)+
	IFEQ	noscreens-3
		MOVE.L	D0,(A2)+
	ENDC
		SUBQ.L	#1,D1
		BNE.S	.Wipe
		RTS

;Wait_Vbl:
;		move.l	vbl_timer,d0		;already defined
;.wait		cmp.l	vbl_timer,d0
;		beq.s	.wait
;		rts



		section	bss
		IFEQ	noscreens-3
third			ds.l	1
		ENDC






		SECTION	DATA

		IFNE	Tracker_On
		INCLUDE	F:\SOURCE\TDF\TRACKERC.S
		ELSE
Dsp_Library:INCLUDE F:\SOURCE\TDF\NEW_OS3.S
		ENDC

		SECTION	TEXT

