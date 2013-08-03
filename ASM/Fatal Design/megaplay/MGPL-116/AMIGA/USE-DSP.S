***********************************************************************
***********										***********
***********										***********
***********	  De l'utilisation du Replay DSP Amiga		***********
***********										***********
***********		Of Use of the Amiga DSP-Replay		***********
***********										***********
***********										***********
***********		  By Simplet / FATAL DESIGN			***********
***********										***********
***********************************************************************

			OutPut	USE-DSP.TOS
			OPT		O+,OW-

***********************************************************************
***********				Inits TOS					***********
***********************************************************************

		Section	TEXT

Start_Up	movea.l	4(sp),a5				; BasePage Adress - Prg
		lea.l	Stack,sp				; Nouvelle Pile
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

		lea.l	Msg_Rout(pc),a0
		bsr		Print

		lea.l	Module(pc),a0
		lea.l	WorkSpace,a1
		bsr		MGTK_Init_Module_Samples

		lea.l	Error_Memory(pc),a0
		tst.w	d0
		bmi		Error

		bsr		MGTK_Init_DSP

		lea.l	Error_DSP(pc),a0
		tst.w	d0
		bmi		Error

		lea.l	Msg_Ok,a0
		bsr		Print

		bsr		MGTK_Save_Sound
		bsr		MGTK_Init_Sound

		moveq.l	#1,d0				; 49.17 KHz
		bsr		MGTK_Set_Replay_Frequency
		
		st		MGTK_Restart_Loop		; Loop On
		bsr		MGTK_Play_Music

***********************************************************************
***********			Main Waiting Loop				***********
***********************************************************************

Main_Loop	move.w	#11,-(sp)				; Cconis
		trap		#1					; Gemdos
		addq.l	#2,sp
		tst.b	d0
		beq.s	Main_Loop

		move.w	#7,-(sp)				; Crawin
		trap		#1					; Gemdos
		addq.l	#2,sp

		cmp.b	#' ',d0
		beq.s	Quit

		cmp.b	#'/',d0
		bne.s	No_PF

		move.w	MGTK_Frequency_Divider,d0
		subq.w	#1,d0
		beq.s	Main_Loop

		bsr		MGTK_Set_Replay_Frequency
		bra.s	Main_Loop

No_PF	cmp.b	#'*',d0
		bne.s	No_NF

		move.w	MGTK_Frequency_Divider,d0
		addq.w	#1,d0
		cmp.w	#4,d0
		beq.s	Main_Loop

		bsr		MGTK_Set_Replay_Frequency
		bra.s	Main_Loop

No_NF	cmp.b	#'-',d0
		bne.s	No_PP

		bsr		MGTK_Previous_Position
		bra.s	Main_Loop

No_PP	cmp.b	#'+',d0
		bne.s	No_NP

		bsr		MGTK_Next_Position
		bra.s	Main_Loop

No_NP
		bclr		#5,d0		; Upper-Case

		cmp.b	#'L',d0
		bne.s	No_Play

		moveq.l	#1,d0
		bsr.s	MGTK_Play_Music
		bra.s	Main_Loop

No_Play	cmp.b	#'S',d0
		bne.s	No_Stop

		bsr		MGTK_Stop_Music
		bra.s	Main_Loop

No_Stop	cmp.b	#'P',d0
		bne		Main_Loop

		bsr		MGTK_Pause_Music
		bra		Main_Loop

***********************************************************************
***********		It's Finished, Restore All			***********
***********************************************************************

Quit		bsr		MGTK_Stop_Music
		bsr		MGTK_Restore_Sound

Exit		clr.w 	-(sp)					; PTerm
		trap 	#1						; Gemdos

Error	bsr.s	Print

		move.w	#7,-(sp)
		trap		#1
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

		Section	BSS

		ds.l		20832/4				; WorkSpace, Maxi 20832 octets
WorkSpace	ds.l		1					; first of the BSS section

		Include	'AMIGADSP.S'

***********************************************************************
***********				The Module				***********
***********************************************************************

		Section	DATA

Msg_Rout	dc.b		27,'E'
		dc.b		"Amiga 4/6/8 voices & xxCH DSP-Replay Routine by Simplet / FATAL DESIGN",13,10
		dc.b		"----------------------------------------------------------------------",13,10,10
		dc.b		"The CPU-Time taken is appearing in Pink.",13,10
		dc.b		"The Grey corresponds to the patterns management.",13,10
		dc.b		"You can use the following keys :",13,10
		dc.b		"  - or + for previous or next music position",13,10
		dc.b		"  / or * for previous or next replay frequency",13,10
		dc.b		"  L for play, P for pause, S for stop",13,10
		dc.b		"  Space to quit",13,10,10
		dc.b		"Initialisating Samples.......",0

Msg_Ok	dc.b		"Ok..",13,10,0

Error_DSP	dc.b		7,13,10
		dc.b		"Error, the DSP program couldn't be loaded.",13,10
		dc.b		"Press any key...",0
Error_Memory
		dc.b		7,13,10
		dc.b		"Error, the workspace isn't big enough.",13,10
		dc.b		"Press any key...",0

		Even
		IncDir	'E:\SNDTRACK\DEPACK\'
Module	IncBin	'GUITAR-S.MOD'		; last of the DATA section

***********************************************************************
***********				BSS Section				***********
***********************************************************************

		Section	BSS

End_Stack	ds.l		64
Stack	ds.l		1
