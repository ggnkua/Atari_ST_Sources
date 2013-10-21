***********************************************************************
***********										***********
***********										***********
***********		 Resident DSP Replay Routine			***********
***********										***********
***********										***********
***********		  By Simplet / FATAL DESIGN			***********
***********										***********
***********************************************************************

			OutPut	RES-PLAY.TOS
			OPT		O+,OW-

***********************************************************************
***********				Inits TOS					***********
***********************************************************************

		Section	TEXT

Start_Up	movea.l	4(sp),a5				; BasePage Adress - Prg
		move.l	a5,BasePage

		movea.l	12(a5),a0				; Text
		adda.l	20(a5),a0				; + Data
		adda.l	28(a5),a0				; + BSS
		adda.w	#256,a0				; + BasePage
		pea.l	(a0)					; Length
		pea.l	(a5)					; Adress
		pea.l	$4a0000				; 0 + Mshrink
		trap		#1					; Gemdos
		lea.l	12(sp),sp

***********************************************************************
***********				It begins here				***********
***********************************************************************

; Welcome Message
		lea.l	Message(pc),a0
		bsr		Print

; Swap into Supervisor Mode
		clr.l	-(sp)
		move.w	#$20,-(sp)			; SUPER
		trap		#1					; Gemdos
		addq.l 	#6,sp

; What is the largest memory bloc size ?
		pea.l	-1.w
		move.w	#$48,-(sp)			; Malloc
		trap		#1					; Gemdos
		addq.l	#6,sp

; Let 64Ko to the system
		lea.l	Error_Memory(pc),a0
		sub.l	#64*1024,d0
		bmi		Error
		move.l	d0,d7				; Bloc Size

; Reserve this bloc
		move.l	d7,-(sp)
		move.w	#$48,-(sp)			; Malloc
		bsr		BP_Bidouille
		trap		#1					; Gemdos
		bsr		BP_Bidouille
		addq.l	#6,sp
		movea.l	d0,a6
		move.l	d0,Mod_Adr

; Opens the module's file
		clr.w	-(sp)				; Read Only Mode
		pea.l	Mod_Name(pc)			; FileName
		move.w	#$3d,-(sp)			; Fopen
		trap		#1					; Gemdos
		addq.l	#8,sp

		lea.l	Error_File(pc),a0
		move.w	d0,d6				; File's Handle
		bmi		Error

; Loads the module
		pea.l	(a6)					; Address
		pea.l	1000000				; Arbitrary Greater Length
		move.w	d6,-(sp)				; Handle
		move.w	#$3f,-(sp)			; FRead
		trap		#1					; Gemdos
		lea.l	12(sp),sp

; Closes the file
		move.w	d6,-(sp)				; Handle
		move.w	#$3e,-(sp)			; FClose
		trap		#1					; Gemdos
		addq.l	#4,sp

; Initialize module and samples
		movea.l	a6,a0				; Module address
		lea.l	(a0,d7.l),a1			; End of WorkSpace address
		bsr		MGTK_Init_Module_Samples

		lea.l	Error_Memory(pc),a0
		tst.w	d0
		bmi		Error

; Keep only the necessary memory
		movea.l	MGTK_Module_End_Adr(pc),a0
		suba.l	a6,a0
		pea.l	(a0)					; Length
		pea.l	(a6)					; Address
		pea.l	$4a0000				; 0 + Mshrink
		bsr		BP_Bidouille
		trap		#1					; Gemdos
		bsr		BP_Bidouille
		lea.l	12(sp),sp

; Initializes DSP, sound and play module
		bsr		MGTK_Init_DSP

		lea.l	Error_DSP(pc),a0
		tst.w	d0
		bmi		Error

		bsr		MGTK_Save_Sound
		bsr		MGTK_Init_Sound

		moveq.l	#1,d0				; 49.17 KHz
		bsr		MGTK_Set_Replay_Frequency
		
		sf		MGTK_Restart_Loop		; Loop Off

		bsr		MGTK_Play_Music		; Start Music

; Finally Provide access to the Stop Program
		move.l	#Player_Structure,$74.w

		clr.w	-(sp)
		pea.l	(Resident_End-Start_Up+256).w
		move.w 	#$31,-(sp)			; Ptermres
		trap 	#1					; Gemdos

***********************************************************************
***********			   If an error occurs			***********
***********************************************************************

Error	bsr.s	Print

		move.w	#7,-(sp)					; Crawin
		trap		#1						; Gemdos
		addq.l	#2,sp

		clr.w 	-(sp)					; PTerm
		trap 	#1						; Gemdos

***********************************************************************
***********				Sub-Routines				***********
***********************************************************************

Print	pea.l	(a0)
		move.w	#9,-(sp)			; Cconws
		trap		#1				; GemDos
		addq.l	#6,sp
		rts

; Routine venant de ntk4_pub par Megar/Binaris
;****************************************************
; Bidouille de la basepage pour que le m‚chant
; Gemdos ne nous confisque pas notre bloc
; DŠs qu'on a le (MS)dos tourn‚ ...
;****************************************************
BP_Bidouille
	movem.l	d0-d1/a0-a2,-(sp)
	lea.l	S_run(pc),a0
;en a0: zone de sauvegarde de 132 octets.
	lea	$51e.w,a1		;adresse new basepage
	move.l	a1,a2
	move.w	#$2700,sr		;pas b“ mais indispensable
	moveq	#32-1,d0
.loop:	move.l	(a0),d1		;echange ...
	move.l	(a1),(a0)+
	move.l	d1,(a1)+
	dbf	d0,.loop
	move.l	$4f2.w,a1
	move.l	40(a1),a1		;a1=_run
	cmp.l	(a1),a2		;basepage = zone de sauvegarde ?
	beq.s	.same
	move.l	(a1),(a0)+	;sauve vraie basepage
	move.l	a2,(a1)		;fause basepage install‚e
.end:	movem.l	(sp)+,d0-d1/a0-a2
	rts
.same:	move.l	(a0)+,(a1)	;remet vraie basepage
	move.w	#$2300,sr		;r‚autorise BIOS
	movem.l	(sp)+,d0-d1/a0-a2
	rts

		Include	'AMIGADSP.S'

		Section	DATA

Player_Structure
		dc.l		'MGTK'
BasePage	dc.l		0
Mod_Adr	dc.l		0
		dc.l		MGTK_Stop_Music
		dc.l		MGTK_Restore_Sound

Message	dc.b		27,'E'
		dc.b		"Resident Amiga DSP-Replay Routine by Simplet / FATAL DESIGN",13,10
		dc.b		"-----------------------------------------------------------",13,10,10,0

Error_DSP	dc.b		7
		dc.b		"Error, the DSP program couldn't be loaded.",13,10
		dc.b		"Press any key...",13,10,0
Error_Memory
		dc.b		7
		dc.b		"Not enough memory.",13,10
		dc.b		"Press any key...",13,10,0
Error_File
		dc.b		7
		dc.b		"Error, the module couldn't be loaded.",13,10
		dc.b		"Press any key...",13,10,0

Mod_Name	dc.b		'RES-PLAY.MOD',0

Resident_End

		Section	BSS

S_run	ds.b		134
