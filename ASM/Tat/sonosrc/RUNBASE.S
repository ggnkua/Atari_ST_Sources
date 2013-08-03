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
		include	equates.s
		;OUTPUT	c:\_demo\data\tunr.prg

overscan	EQU	0

PixelsPerLine	EQU	384
Lines		EQU	100
ScreenLines	EQU	100

BytesPerLine	EQU	PixelsPerLine*2
Tracker_On	EQU	0


start:
	MOVE.L	A0,-(A7)
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

	MOVE.L	#$0001,D0		;DATA CACHE MUST BE OFF
	MOVEC	D0,CACR
	MOVE.W	#$2300,SR

; Initialize Screen:
	BSR	Clear_Screens
	BSR	Screen_Swap
	BSR	Set_Resolution
	RTS

;--------------------------------------------------------------
screen_swap:
	MOVE.W	SR,-(A7)
	MOVE.W	#$2700,SR
	MOVE.L	logic,-(A7)
	MOVE.B	1(A7),$ffff8201.W
	MOVE.B	2(A7),$ffff8203.W
	MOVE.B	3(A7),$ffff820d.W
	ADDQ.L	#4,A7
	MOVE.L	logic,D0
	move.l	third,logic
	move.l	physic,third
	MOVE.L	D0,physic
	MOVE.W	(A7)+,SR
	RTS

;--------------------------------------------------------------
Clear_Screens:
	MOVE.L	physic,A0
	MOVE.L	logic,A1

	MOVEQ	#0,D0
	MOVE.W	#ScreenLines*BytesPerLine/4-1,D2
.Wipe:	MOVE.L	D0,(A0)+		; SET TO #$f0
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A1)+
	MOVE.L	D0,(A1)+
	MOVE.L	D0,(A1)+
	MOVE.L	D0,(A1)+
	DBF	D2,.Wipe
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
Set_Resolution:
	lea	tunnel_res,a0
	moveq	#T6_SetRes,D0
	trap	#6
	rts

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
Tunnel_Res		INCBIN	F:\DATA\TDF\RES\TUNNELR.SCP


;-----------------------------------------------------------
			SECTION	BSS
;-----------------------------------------------------------
music_data		ds.l	1
logic			ds.l	1
physic			ds.l	1

file_end		equ	*
