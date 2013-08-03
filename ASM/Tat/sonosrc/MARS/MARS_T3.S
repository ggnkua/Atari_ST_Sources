






						avena_26_9_96:










;
; a0 = xxxxyyyy where
;      xxxx     - 0 = initialize
;               - 1 = already initialised
;      yyyy	=  how many to display for
;

		include	equates.s
		OUTPUT	c:\_demo\data\mars.prg

overscan	EQU	0

RGB		EQU	1
Flash		EQU	0
VblWait		EQU	0
Keys		EQU	0

Tracker_On	EQU	0

start:
	MOVE.L	A0,-(A7)

	MOVE.L	A0,D0
	SWAP	D0
	CMP.W	#1,D0
	BEQ.S	Display_routine

; Otherwise:
; Set original vectors and screens etc.
	moveq	#T6_GetMusic,d0
	trap	#6
	move.l	A0,music_data

	MOVE.L	#file_end+4000,D0		;top of memory - change!
	SUB.B	D0,D0
	MOVE.L	D0,logic
	ADD.L	#BytesPerLine*ScreenLines,D0
	MOVE.L	D0,physic
	ADD.L	#BytesPerLine*ScreenLines,D0
	MOVE.L	D0,third

; Initialize Screen:
	MOVEQ.L #$0009,D0
	MOVEC	D0,CACR
; Initialize_Dsp
	LEA	Dsp_Routine_Mars,A0
	MOVEQ	#T6_InstallDSP,d0
	TRAP	#6
	LEA	$210.W,A0
	MOVEQ	#T6_RunDSP,d0
	TRAP	#6
	MOVE.W	#$2300,SR

	BSR	clearscreens
	BSR	Calc_Colours
	BSR	Send_Z_Table
	BSR	Send_One_Over_Table
	BSR	Send_Sine_Table

	MOVE.L	(A7)+,D0
	RTS

Display_Routine:
	BSR	Send_Movement
	BSR	Handle_Planet
	BSR	screen_swap
	BSR	set_resolution

	MOVE.L	(A7)+,D0
MAINLOOP:
	MOVE.W	D0,-(A7)
	BSR	Send_Movement
	BSR	Handle_Planet
	BSR	screen_swap
	MOVE.W	(A7)+,D0
	DBF	D0,MAINLOOP
; Done:
	JSR	Wait_SendDSP
	MOVE.L	#"RTS",$FFFFA204.W
	BSR	clearscreens2
	BSR	screen_swap
	RTS


Wait_Vbl2:
.wv	CMP.L	#2,$466.W
	BLT.S	.wv
	CLR.L	$466.W
	RTS

;--------------------------------------------------------------


;--------------------------------------------------------------
;
;
;		FILES AND DATA
;
;
;--------------------------------------------------------------
Wait_Music:
	asl.l	#2,d1			;multiply all by 4
	move.l	Music_Data,a6
	move.l	(a6),a6
.waitloop1:
	cmp.b	aon_pos(a6),d0
	bgt.s	.waitloop1
.waitloop2:
	move.w	aon_patcnt(a6),d2
	and.w	#$3ff,d2
	cmp.w	d2,d1
	bgt.s	.waitloop2
	rts


;-----------------------------------------------------------
;-----------------------------------------------------------
			SECTION DATA
;-----------------------------------------------------------


;-----------------------------------------------------------
			SECTION	BSS
;-----------------------------------------------------------
music_data		ds.l	1
logic			ds.l	1
physic			ds.l	1

;-----------------------------------------------------------
			SECTION	TEXT
;-----------------------------------------------------------
			INCLUDE	F:\SOURCE\TDF\MARS\MARS2_3T.S

			DS.L	50
file_end		equ	*
