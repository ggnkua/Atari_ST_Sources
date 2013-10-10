* TRACK ROUT BY SIMPLET/AST

; 0 for VBL Rout in RVB 50 Hz Only
; 1 for universal Timer A Rout with CIA-Tempos

*VBL_Timer	EQU		1

	Section	TEXT

	clr.l	-(sp)
	move.w	#$20,-(sp)				; SUPER
	trap	#1						; Gemdos
	addq.l 	#6,sp

	bsr.s	Init_Music
*	bmi.s	Error

*	IfNe	VBL_Timer
	bsr.s	Init_Music_IT
*	Else
*	move.l	$70.w,Old_VBL
*	move.l	#New_VBL,$70.w
*	EndC

BOUCLE:
	CMPI.B	#57,$FFFFFC02.W
	BNE.S	BOUCLE

*	IfNe	VBL_Timer
	bsr.s	Stop_Music_IT
*	Else
*	move.l	Old_VBL,$70.w
*	EndC

	bsr.s	Stop_Music

Error	clr.w 	-(sp)					; PTerm
	trap 	#1						; Gemdos

*New_VBL	move.w	#25000,d7
*	dbra	d7,*
*
*	bsr	SndTrack_IT
*	rte

	Include	C:\UTILS\CODE_UTI.LS\GEN_ASM\DSP_MOD.AST\TRACKER.S

	Section	DATA

Module	IncBin	D:DEPACK\CD2PART0.MOD		; LAST OF THE DATA SECTION

	Section	BSS

Old_VBL	ds.l		1
