; Author: Herve 'Janek' Durand et Benoit 'RATI' Durand
; Demo Group: Overlanders
; Organization: The Union
; Date (dd/mm/yyyy): 25/09/2016
;
; Objective: Demonstration of Fullscreen in Timer A or B or C or D
;
; Type: Main program
;
; Main principles:
;	- Include "FSIT.S" your source (this file)
;	- Set TIMER_MFP to timer you want to use: $A for Timer A, $B for Timer B, $C for Timer C, $D for Timer D
;	  In case nothing is specified, TIMER_A is used
;	- jsr FSIT_Start to start the fullscreen
;	- jsr FSIT_Stop to stop the fullscreen
;	- Before a long instruction put a "stop #$2300" that will give you 172 cycles to do what you want (even multiple mulu,div,movem...)
;	- Stop #$2300 halts the program till an interruption above level 3 occurs (VBL or MFP) and so you don't disturb interrupt fullscreen
;	  as MFP is level 6.
;	- It remains around 64000 cycles for the main routine (_Main_Prg) in the same VBL meaning that this fullscreen takes 60% of the VBL.

; ===========================================================
						SECTION TEXT
; ===========================================================

; ----------------------------------------------------
; Variables section
; ----------------------------------------------------
_DEBUG		EQU 	0
_WithPicture	EQU	1							; 1=With Picture; 0=Without Picture
_Zik		EQU	1							; 1=Play music; 0=No music
TIMER_MFP	EQU	$C							; $A for Timer A, $B for Timer B, $C for Timer C, $D for Timer D

	ifne	_DEBUG
	opt 	x+
	endc

	bra	_Start								; Go to the real start of the program after includes section

; ===========================================================
;						SECTION INCLUDES
; ===========================================================

	INCLUDE	"TOOLS.S"
	INCLUDE	"FSIT.S"

; ===========================================================
						SECTION TEXT
; ===========================================================

; ----------------------------------------------------
; Start routine
; ----------------------------------------------------
_Start:
	; Initialization
	TOOLS_InitPrg $1000							; Shrink memory to adapt memory/stack (length in argument) to the PRG
	jsr	TOOLS_Super							; Enter Super mode
	jsr	TOOLS_Mouse_Hide						; Hide Mouse pointer
	jsr	TOOLS_Context_Backup						; Backup Context
	bsr	TOOLS_DetectWakeState						; Set _WakeState with the WS status
	bsr.s	_SetScreen							; Set Screen Address
	ifne	_WithPicture
	bsr	_SetPicture							; Copy picture in the screen
	endc
	ifne	_Zik
	TOOLS_Music_Init	_Music,2					; Start the music
	endc
	bsr	_SetVBL								; Set VBL
	jsr	FSIT_Start							; Start Fullscreen

	; Main Prg
	bsr	_Main_Prg

	; Restore
	ifne	_Zik
	TOOLS_Music_Stop	_Music						; Stop Music
	endc
	jsr	FSIT_Stop							; Stop Fullscreen
	jsr	TOOLS_Context_Restore						; Restore Context
	jsr	TOOLS_Mouse_Show						; Restore mouse pointer
	jsr 	TOOLS_CleanKeyboardExit						; To avoid frozen mouse/keyboard when exit
	jsr	TOOLS_Super							; Quit Super mode

	; Quit program
	clr.w	-(sp)
	trap	#1

; ----------------------------------------------------
; Screen section
; ----------------------------------------------------
	; Set ScreenAddress and ScreenAddressWork
	; Low byte must be equal to $00
_SetScreen:
	; Set screen address
	lea	_Screen1,a0
	move.l	a0,d0
	add.l	#$100,d0
	move.b	#$00,d0
	move.l	d0,_ScreenAddress						; Screen that is displayed
	lea	_Screen2,a0
	move.l	a0,d0
	add.l	#$100,d0
	move.b	#$00,d0
	move.l	d0,_ScreenAddressWork						; Screen on which we work on
	; Set Screen pointer
	lea	_ScreenAddress,a0						; I can access bytes by offset 1 & 2
	move.b	1(a0),$FFFF8201.w						; High byte
	move.b	2(a0),$FFFF8203.w						; Medium byte
	; Clean 256 first bytes
	moveq	#(256/4)-1,d0
	moveq	#0,d1
	lea	_Screen1,a0
	lea	_Screen2,a1
_SetScreen1:
	move.l	d1,(a0)+
	move.l	d1,(a1)+
	dbf	d0,_SetScreen1
	rts

	; Copy Picture in both ScreenAddress and ScreenAddressWork
	; Set colors
_SetPicture:
	; PI1 format:
	;	- Word 0 = 00
	;	- Word 1 to 16 : colors
	;	- Word 17 to the end : picture with all plans interlaced
	opt	o-								; To prevent warning that are useless in here
	lea	_Picture,a0
	; Set Low Rez
	move.b	#0,$FFFF8260.w
	; Set colors
	movem.l	2(a0),d0-d7
	movem.l	d0-d7,$FFFF8240.w
	; Move picture in screen
	add.l	#34,a0
	move.l	_ScreenAddress,a1
	move.l	_ScreenAddressWork,a2
	add.l	#204,a1								; First line is 204 bytes long and must remain empty
	add.l	#204,a2
	move.l	#(276-1)-1,d0							; 275 lines as first line is black -1 as dbf stop at -1
_SetPicture1:
	move.l	#(208/4)-1,d1							; 208 bytes per line for my picture
_SetPicture2:
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d1,_SetPicture2
	add.l	#230-208,a1
	add.l	#230-208,a2
	dbf	d0,_SetPicture1
	opt	o+
	rts

_SwapScreens:
	lea	_ScreenAddress,a0
	move.l	(a0),d0
	move.l	4(a0),(a0)
	move.l	d0,4(a0)
	move.b	1(a0),$FFFF8201.w						; High byte
	move.b	2(a0),$FFFF8203.w						; Medium byte
	rts

; ----------------------------------------------------
; Interrupt section
; ----------------------------------------------------

_SetVBL:
	move.l	#_VBL,$70.w
	rts

_VBL:
	move.b	#1,_VSync							; 20 cycle : Set flag to indicate VBL just start

	; Save registers
	movem.l d0-d7/a0-a6,-(sp)

	; Music
	ifne	_Zik
	TOOLS_Music_Play	_Music						; Play the music
	endc

	; Restore registers
	movem.l (sp)+,d0-d7/a0-a6
	rte

; ----------------------------------------------------
; Main Program section
; ----------------------------------------------------
_Main_Prg:
	move.b	_VSync,d0							; While VSync = 0, we loop. VSync is set to 1 at the start of the VBL
	beq.s	_Main_Prg
	clr.b	_VSync								; We set the flag back to 0 and start our main routine

	; Main routine to be put in here

	; Set background color with _WakeState
	cmp.b	#1,TOOLS_WakeState
	bne.s	.ws2
	move.w	#$0700,$FFFF8240.w
	bra.s	.wsEnd
.ws2:	cmp.b	#2,TOOLS_WakeState
	bne.s	.ws3
	move.w	#$0070,$FFFF8240.w
	bra.s	.wsEnd
.ws3:	cmp.b	#3,TOOLS_WakeState
	bne.s	.ws4
	move.w	#$0007,$FFFF8240.w
	bra.s	.wsEnd
.ws4:	cmp.b	#4,TOOLS_WakeState
	bne.s	.wsSTE
	move.w	#$0077,$FFFF8240.w
	bra.s	.wsEnd
.wsSTE:	move.w	#$0770,$FFFF8240.w
.wsEnd

	; Go down in the picture
	rept	100
	stop	#$2300
	endr

	; Example of code with:
	; . long and unstable instructions: mul and div
	; . use of Bcc without ensuring the CPU consumption is always consistent whatever the the path
_Main_Prg_MulDiv:
	move.w	#$0770,$FFFF8240.w
	; Let's get audio chanels value so that I have different values at each VBL
	; . Volume channel A
	moveq	#0,d3
	move.b 	#8,$FFFF8800.w			; reg 8 = volume channel A
	move.b 	$FFFF8800.w,d3
	and.w 	#$000F,d3
	cmp.w 	#0,d3
	bne.s	_Main_Prg_MulDiv2
	move.w 	#3,d3
_Main_Prg_MulDiv2:
	; . Volume channel B
	moveq	#0,d4
	move.b 	#9,$FFFF8800.w			; reg 9 = volume channel B
	move.b 	$FFFF8800.w,d4
	and.w 	#$000F,d4
	cmp.w 	#0,d4
	bne.s	_Main_Prg_MulDiv3
	move.w 	#17,d4
_Main_Prg_MulDiv3:
	;  Volume channel C
	moveq	#0,d5
	move.b 	#10,$FFFF8800.w			; reg 10 = volume channel C
	move.b 	$FFFF8800.w,d5
	and.w 	#$000F,d5
	cmp.w 	#0,d5
	bne.s	_Main_Prg_MulDiv4
	move.w 	#71,d5
_Main_Prg_MulDiv4:
	moveq	#5,d2
_Main_Prg_MulDiv1:
	stop	#$2300
	move.w	#$0700,$FFFF8240.w
	mulu	d3,d4								; Yeah MUL: max 70 cycles
	move.w	#$0070,$FFFF8240.w
	mulu	d4,d5								; Note there's no stop because I have time for 2 successive mul
	move.w	#$0007,$FFFF8240.w
	stop	#$2300								; If you remove this stop, you may go outside of the time you have to execute a mul so better to secure with this stop
	mulu	d5,d4
	move.w	#$0077,$FFFF8240.w
	stop	#$2300
	divu	d3,d5								; Yeah DIV: max 158 cycles
	move.w	#$0077,$FFFF8240.w
	dbf	d2,_Main_Prg_MulDiv1

	move.w	#$0000,$FFFF8240.w

	; End of routine, we swap screens
	bsr	_SwapScreens

_Main_Prg_Kbd:
	; Keyboard test
	; In case space bar is pressed, we quit the program
	move.b	$FFFFFC02.w,d0							; Keyboard data
	and.b	#$7F,d0								; Bit 8 to 0 as it is for parity
	cmp.b	#$39,d0								; Space key
	bne	_Main_Prg

	rts

; ===========================================================
						SECTION DATA
; ===========================================================

_Picture:
	ifeq	_WithPicture
	dcb.b	208*276,0							; Remove ; to see colors changes of Main_Prg
	else
	incbin	"CATfsit.PI1"				; 416px x 276px : 208 bytes lines
	endc
	ifne	_Zik
_Music:		INCBIN	"MUSIC5.DAT"			; Mad Max music
	endc
	even

; ===========================================================
						SECTION BSS
; ===========================================================

_VSync:		ds.b	1							; We could also use $468.w
	even
_ScreenAddress:	ds.l	1							; Screen that is displayed
_ScreenAddressWork:ds.l	1							; Screen we work on
	; 2 screens for screen swapping as usual
_Screen1:	ds.b	276*230+256						; Low byte equals 0 so I add 256 bytes
_Screen2:	ds.b	276*230+256						; Low byte equals 0 so I add 256 bytes

	END
