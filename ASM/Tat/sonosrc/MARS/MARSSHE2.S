








						avena_26_9_96:








;
;	Plasma Planet / Mars-2
;
;
; MARS2_3 - movement forwards/backwards added
;           send 6*128 lines of data, only use 1 in 8
;           then start with 0-7, send an additional absolute Z
;           position for the sine waves


RGB		EQU	1
Flash		EQU	0
VblWait		EQU	0
Keys		EQU	1
Tracker_On	EQU	0
Demo		EQU	0

	INCLUDE EQUATES.S


start:
	;INCLUDE F:\SOURCE\TDF\HEADER.S

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

	LEA stack,A7
	MOVE.W #$2700,sr
	LEA mouse_on(PC),A0
	BSR send_ikbd

	MOVE.L	#RTE,$14.W

	MOVE.L	#STACK+4000,D0		;top of memory - change!
	SUB.B	D0,D0
	MOVE.L	D0,logic
	ADD.L	#BytesPerLine*ScreenLines,D0
	MOVE.L	D0,physic
	ADD.L	#BytesPerLine*ScreenLines,D0
	MOVE.L	D0,third


	MOVE.W	#$2300,SR

	MOVE.L #vbl,$70.W
	MOVE.L #keyboard,$118.W
	MOVE.L #$ff00ff40,$fffffA06.W
	MOVE.L #$ff00ff40,$fffffA12.W

	BCLR	#3,$fffffA17.W 
	BRA	begin

		IFNE	RGB
my_resolution	DC.W	$4+$20+$40
		ELSE
my_resolution	DC.W	$4+$110
		ENDC

;---------------------------------------------------------------

begin:
	MOVE.W	#$2700,SR
; Initialize DSP:
	IFNE	Tracker_On
	 JSR	start_tracker
	ELSE
	 JSR	Dsp_Library
	ENDC

	LEA	Dsp_Routine_Mars,A0
	JSR	Dsp_Library+4
	LEA	$210.W,A0
	JSR	Dsp_Library+8
	MOVE.W	#$2300,SR

	CLR.L	$FFFF9800.W
	BSR	set_resolution
	BSR	clearscreens
	;move.l	logic,a0
	;move.l	#-1,160(a0)
	BSR	screen_swap

	BSR	Calc_Colours
	BSR	Send_One_Over_Table
	BSR	Send_Sine_Table

	MOVE.W	#0,COUNTER
MAINLOOP:
	BSR	Send_Z_Table
	BSR	Send_Movement
	BSR	Handle_Planet

	IFNE	VblWait
	 BSR	wait_vbl
	ENDC

	BSR	screen_swap

HOLDUP
	;TST.B	keyboard_matrix+1
	;BEQ	HOLDUP			;only go when pressed

	ADDQ.W	#1,COUNTER
	BRA	MAINLOOP

	JSR	Wait_SendDSP
	MOVE.L	#"RTS",$FFFFA204.W

	ILLEGAL

	INCLUDE	F:\SOURCE\TDF\MARS\MARS2_3u.S

COUNTER			DS.W	1
			DS.L	300
stack:






