***********************************************************************
***********										***********
***********										***********
***********  Routine de Test avec un module fait … la main	***********
***********										***********
***********										***********
***********		  Par Simplet / FATAL DESIGN			***********
***********										***********
***********************************************************************

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
		bsr		MGTK_Init_Module_Samples	; Initialise tout le bordel
		bpl.s	No_Error

		lea.l	Error_Format(pc),a0
		cmp.b	#-1,d0
		beq		Error
		lea.l	Error_Memory(pc),a0
		bra		Error

No_Error	bsr		MGTK_Init_DSP
		bpl.s	DSP_Ok

		lea.l	Error_DSP(pc),a0
		bra		Error

DSP_Ok	lea.l	Msg_Ok(pc),a0
		bsr		Print

		bsr		MGTK_Save_Sound
		bsr		MGTK_Init_Sound
		moveq.l	#1,d0
		bsr		MGTK_Set_Replay_Frequency
		moveq.l	#0,d0
		bsr		MGTK_Play_Music

***********************************************************************
***********			Main Waiting Loop				***********
***********************************************************************

		move.w	#7,-(sp)				; Crawin
		trap		#1					; Gemdos
		addq.l	#2,sp

***********************************************************************
***********		It's Finished, Restore All			***********
***********************************************************************

Quit		bsr		MGTK_Stop_Music
		bsr		MGTK_Restore_Sound

Exit		clr.w 	-(sp)					; PTerm
		trap 	#1						; Gemdos

Error	bsr		Print

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

		ds.l		150*1024/4			; WorkSpace
WorkSpace	ds.l		1					; premier de la section BSS

		Include	'MGT-PLAY.S'

***********************************************************************
***********				Section DATA				***********
***********************************************************************

		Section	DATA

Msg_Rout	dc.b		27,'E'
		dc.b		"MegaTracker¿ v1.1 DSP-Replay Routine by Simplet / FATAL DESIGN",13,10
		dc.b		"--------------------------------------------------------------",13,10,10
		dc.b		"The CPU-Time taken by sending samples to the DSP is appearing in Black + Pink.",13,10
		dc.b		"The Grey corresponds to the patterns management.",13,10
		dc.b		"Initialisations (depacking tracks and initialising samples).....",0

Msg_Ok	dc.b		"Ok..",13,10,0

Error_DSP	dc.b		7,13,10
		dc.b		"Error, the DSP program couldn't be loaded.",13,10
		dc.b		"Press any key...",0
Error_Format
		dc.b		7,13,10
		dc.b		"Error, the Module is not to the MegaTracker¿ format.",13,10
		dc.b		"Press any key...",0
Error_Memory
		dc.b		7,13,10
		dc.b		"Error, the workspace isn't big enough.",13,10
		dc.b		"Press any key...",0

***********************************************************************
***********				The Module				***********
***********************************************************************

		Even

Module	dc.b		'MGT',$11,'½MCS'
		dc.w		20,1,1,1,1,2,0,0,0
		dc.l		Music-Module,Sequence-Module,Samples_Infos-Module
		dc.l		Patterns-Module,Tracks_Ptr-Module,Samples_Data-Module
		dc.l		Samples_Data_End-Samples_Data,1*6*64

Music	dc.b		'Module de Test fait … la main...'
		dc.l		Sequence-Module
		dc.w		1,0
		dc.b		125*60/50,6		; Tempo 60 Hz, Speed 6
		dc.w		1024,$2020		; Global Volume 1024
		dc.w		$ff00,$00ff,$ff00,$00ff
		dc.w		$ff00,$00ff,$ff00,$00ff
		dc.w		$ff00,$00ff,$ff00,$00ff
		dc.w		$ff00,$00ff,$ff00,$00ff
		dc.w		$ff00,$00ff,$ff00,$00ff
		dc.w		$ff00,$00ff,$ff00,$00ff
		dc.w		$ff00,$00ff,$ff00,$00ff
		dc.w		$ff00,$00ff,$ff00,$00ff

Sequence	dc.w		0,0,0,0

Samples_Infos
		dc.b		'Ceci est le Sample Num‚ro 1.....'
		dc.l		Sample1-Module,(Sample2-Sample1)/2,0,0
		dc.l		16000*4/50,0,40000
		dc.w		1024,0
		dc.b		%0100,0,0,0		; 16 Bits Mono
		dc.l		0,0,0

		dc.b		'O— sont les femmes ?............'
		dc.l		Sample2-Module,(Samples_Data_End-Sample2)/1,0,0
		dc.l		22000*4/50,0,40000
		dc.w		1024,0
		dc.b		%0000,0,0,0		; 8 Bits Mono
		dc.l		0,0,0

Patterns	dc.w		64
		dcb.w	32,1

Tracks_Ptr
		dc.l		Track1-Module		

Track1	dc.w		64
		dc.b		%11111100,60,2,0,0,0,0	; 60 = DO-4
		dc.b		2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3

Samples_Data
Sample1	IncBin	'E:\SNDTRACK\SAMPLES\BOOT.RAW'
Sample2	IncBin	'E:\SNDTRACK\SAMPLES\JUVET.RAW'
Samples_Data_End

***********************************************************************
***********				BSS Section				***********
***********************************************************************

		Section	BSS

End_Stack	ds.l		64
Stack	ds.l		1
