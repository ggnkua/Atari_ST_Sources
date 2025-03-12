init_dsp	MACRO
		ENDM

init_screens	MACRO
		MOVEQ	#T6_GetScreens,D0
		TRAP	#6
		MOVE.L	(A0)+,scrnbase
		MOVE.L	(A0)+,physic
		MOVE.L	(A0)+,logic
		MOVE.L	(A0)+,third
		ENDM

update_screens	MACRO
		MOVE.L	scrnbase,A0
		MOVE.L	physic,A1
		MOVE.L	logic,A2
		MOVE.L	third,A3
		MOVEQ	#T6_UpdateScreens,D0
		TRAP	#6
		ENDM

init_dsp_routine MACRO
		LEA	(\1),A0
		MOVEQ	#T6_InstallDSP,d0
		TRAP	#6
		LEA	(\2).W,A0
		MOVEQ	#T6_RunDSP,d0
		TRAP	#6
		ENDM

install_vbl	MACRO
		move.l	#\1,A0
		moveq	#T6_InstallVBL,d0
		trap	#6
		ENDM


; ---------------------- DEMO STARTUP CODE ----------------
		move.l	a1,sequence_data

		MOVE.L	A0,-(A7)
		MOVE.L	A0,D0
		MOVE.W	D0,D7			;d7 = counter
		SWAP	D0
		CMP.W	#1,D0
		BEQ	Do_Display

; Otherwise:
; Set original vectors and screens etc.
		moveq	#T6_GetMusic,d0
		trap	#6
		move.l	A0,music_data

		MOVE.L	#STACK+4000,D0		;top of memory - change!
		SUB.B	D0,D0
		MOVE.L	D0,logic
		ADD.L	#BytesPerLine*Lines,D0
		MOVE.L	D0,physic
		 IFEQ noscreens-3
		ADD.L	#BytesPerLine*Lines,D0
		MOVE.L	D0,third
		 ENDC

		BSR	Initialize_Routine

		MOVEQ.L #$0009,D0
		MOVEC	D0,CACR

		MOVE.L	(A7)+,A0
		RTS

Do_Display:
		BRA	Display_Routine

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

Wait_Vbl:
		move.l	$466.w,d0
.wait		cmp.l	$466.w,d0
		beq.s	.wait
		rts



		section	bss
scrnbase		ds.l	1
third			ds.l	1
Logic			ds.l	1
physic			ds.l	1

music_data		ds.l	1
sequence_data		ds.l	1

		section	text


