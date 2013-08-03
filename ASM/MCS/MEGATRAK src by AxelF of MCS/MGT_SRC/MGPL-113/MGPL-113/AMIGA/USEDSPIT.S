***********************************************************************
***********										***********
***********										***********
***********		    DSP Julia Fractal Set			***********
***********		under DSP interrupt SoundTrack		***********
***********										***********
***********										***********
***********		  By Simplet / FATAL DESIGN			***********
***********										***********
***********************************************************************

Dep_X	equ		-4194304			; -2/4 * 2^23
Dep_Y	equ		-2621440			; -1.25/4 * 2^23
Incr		equ		26214			; 2.5/200/4 * 2^23
C_Re		equ		-1310720			; -0.625/4 * 2^23
C_Im		equ		-1310720			; -0.625/4 * 2^23

			OutPut	USEDSPIT.TOS
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

		lea.l	Module(pc),a0
		lea.l	WorkSpace,a1
		bsr		MGTK_Init_Module_Samples	; Initialise tout le bordel

		lea.l	Error_Memory(pc),a0
		tst.w	d0
		bmi		Error

		lea.l	Error_DSP(pc),a0
		bsr		MGTK_Init_DSP
		tst.w	d0
		bmi		Error

		bsr		MGTK_Save_Sound
		bsr		MGTK_Init_Sound

		moveq.l	#2,d0				; 32.78 KHz
		bsr		MGTK_Set_Replay_Frequency
		
		st		MGTK_Restart_Loop		; Loop On
		bsr		MGTK_Play_Music

		lea.l	Msg_Rout(pc),a0
		bsr		Print

		move.w	#7,-(sp)				; Crawin
		trap		#1					; Gemdos
		addq.l	#2,sp


		clr.l	-(sp)				; Swap into Supervisor Mode
		move.w	#$20,-(sp)			; SUPER
		trap		#1					; Gemdos
		addq.l 	#6,sp

		bsr		Save_Video
		bsr		Init_Falcon_Palette

		lea.l	Videl_320_200_True,a0
		lea.l	Adr_Screen1,a1
		lea.l	Screens,a2
		moveq.l	#2-1,d0
		bsr		Init_Video

		lea.l	DSP_Code(pc),a0
		moveq.l	#DSP_Size,d0
		bsr		MGTK_P56_Loader

***********************************************************************
***********	Calcule et Affiche l'Ensemble de Julia		***********
***********************************************************************

Julia_Loop
		move.l	Adr_Screen1,d0				; Flipping
		move.l	Adr_Screen2,Adr_Screen1		; Ecrans
		move.l	d0,Adr_Screen2				; Physique
		lsr.w	#8,d0					; /
		move.l	d0,$ffff8200.w				; Logique

		lea.l	$ffffa204.w,a6
		lea.l	$ffffa206.w,a5
		lea.l	$ffffa202.w,a4

		sub.l	#3000,Cst_Re
		add.l	#10500,Cst_Im

Wait_Loop	btst.b	#1,(a4)
		beq.s	Wait_Loop

		move.l	#Dep_X,(a6)
		move.l	#Dep_Y,(a6)
		move.l	#Incr,(a6)
		move.l	Cst_Re(pc),(a6)
		move.l	Cst_Im(pc),(a6)

		movea.l	Adr_Screen1,a0
		move.w	#100-1,d7
Line_Loop	move.w	#320-1,d6
Pixel_Loop
		btst.b	#0,(a4)
		beq.s	Pixel_Loop
		move.w	(a5),(a0)+
		dbra		d6,Pixel_Loop
		dbra		d7,Line_Loop

		movea.l	a0,a1
		move.w	#320*100/16-1,d7
Copy_Loop
		Rept		16
			move.w	-(a0),(a1)+
		EndR
		dbra		d7,Copy_Loop

		move.w	#11,-(sp)				; Cconis
		trap		#1					; Gemdos
		addq.l	#2,sp
		tst.b	d0
		beq		Julia_Loop

		move.w	#7,-(sp)				; Crawin
		trap		#1					; Gemdos
		addq.l	#2,sp

***********************************************************************
***********		It's Finished, Restore All			***********
***********************************************************************

		bsr		Restore_Video

		bsr		MGTK_Stop_Music
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

		Include	'AMGDSPIT.S'
		Include	'VIDEO.S'

***********************************************************************
***********				The Module				***********
***********************************************************************

		Section	DATA

Cst_Re	dc.l		C_Re
Cst_Im	dc.l		C_Im

Msg_Rout	dc.b		27,'E'
		dc.b		"This is just a little example",13,10
		dc.b		"of DSP Program with a soundtrack",13,10
		dc.b		"replayed under DSP interrupt..",13,10,10
		dc.b		"Simplet / FATAL Design 1995",13,10,10
		dc.b		"Press any key...",13,10,0

Error_DSP	dc.b		7,27,'E'
		dc.b		"Error, the DSP program couldn't be loaded.",13,10
		dc.b		"Press any key...",0
Error_Memory
		dc.b		7,27,'E'
		dc.b		"Error, the workspace isn't big enough.",13,10
		dc.b		"Press any key...",0

DSP_Code	IncBin	'JULMORPH.P56'
DSP_Size	equ		(*-DSP_Code)/3

		Even
		IncDir	'E:\SNDTRACK\DEPACK\'
Module	IncBin	'ELEKFUNK.MOD'		; last of the DATA section

***********************************************************************
***********				BSS Section				***********
***********************************************************************

		Section	BSS

; Adresses Ecrans
Adr_Screen1	ds.l		1
Adr_Screen2	ds.l		1
; Place pour Ecrans
Screens		ds.b		2*((320*200*2)+256)
; La Pile
End_Stack	ds.l		64
Stack	ds.l		1
