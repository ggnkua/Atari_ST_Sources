; Author: Herve 'Silver' Durand et Benoit 'Crystar' Durand
; Demo Group: Overlanders
; Organization: The Union
; Date (dd/mm/yyyy): 21/09/2016
;
; Set of tools
;

; ===========================================================
			SECTION TEXT
; ===========================================================

; -----------------------------------------------------------
;			USEFULL MACROS
; -----------------------------------------------------------

; Shrink memmory to adapt to the PRG
; To call at the start of a PRG
; Argument:
; 	\1: Size of the stack
TOOLS_InitPrg 	MACRO
	move.l  4(sp),a5                ; address to basepage
    	move.l  $0c(a5),d0              ; length of text segment
    	add.l   $14(a5),d0              ; length of data segment
	add.l   $1c(a5),d0              ; length of bss segment
    	add.l   #\1,d0               	; length of stackpointer passed in argument
	add.l   #$100,d0                ; length of basepage
	move.l  a5,d1                   ; address to basepage
	add.l   d0,d1                   ; end of program
	and.l   #-2,d1                  ; make address even
	move.l  d1,sp                   ; new stackspace
	move.l  d0,-(sp)                ; mshrink()
	move.l  a5,-(sp)
	move.w  d0,-(sp)
	move.w  #$4a,-(sp)		; Command mshrink
	trap    #1			; Gemdos
	lea 	12(sp),sp
	ENDM

	; Init the music
	; Argument:
	; \1:Label of the music
	; \2:tune number to play
TOOLS_Music_Init	MACRO
	moveq	#\2,d0				;music number two
	jsr	\1				;call music program
	ENDM

	; Stop the music
	; Argument: Label of the music
TOOLS_Music_Stop	MACRO
	moveq	#0,d0				;music zero
	jsr	\1				;setup music
	move.b	#8,$FFFF8800.w			;channel A...
	clr.b	$FFFF8802.w			;no volume
	move.b	#9,$FFFF8800.w			;channel B...
	clr.b	$FFFF8802.w			;no volume
	move.b	#10,$FFFF8800.w			;channel C...
	clr.b	$FFFF8802.w			;no volume
	ENDM

	; Play the music
	; Argument: Label of the music
TOOLS_Music_Play	MACRO
	jsr	\1+8
	ENDM

; -----------------------------------------------------------
;			USEFULL FUNCTIONS
; -----------------------------------------------------------

TOOLS_Super:
	; BkpUser is initialized to 0 so the first time I enter I switch to Super mode
	; The second time I enter, BkpUser is set and so I quit Super mode
	move.l	TOOLS_BkpUser,d0
	move.l	d0,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,TOOLS_BkpUser
	rts

TOOLS_Mouse_Hide:
	dc.w	$A00A				; Line A command to make mouse disappearing
	move.b	#$12,$fffffc02.w		; Mouse movement disabled
	rts

TOOLS_Mouse_Show:
	dc.w	$A009				; Line A command to make mouse appearing
	move.b	#$8,$FFFFFC02.w			; Mouse movement enable
	rts

TOOLS_Context_Backup:
	move.w	#$2700,sr
	move.l	usp,a0				; Backup USP so that we can use usp
	move.l	a0,TOOLS_BkpUSP
	move.w	SR,TOOLS_BkpSR
	move.l 	$10.w,TOOLS_BkpIllegal
	move.l 	$20.w,TOOLS_BkpPrivilege
	move.l 	$28.w,TOOLS_BkpLineA
	move.l 	$2C.w,TOOLS_BkpLineF
	move.l	$68.w,TOOLS_BkpHBL
	move.l	$70.w,TOOLS_BkpVBL
	move.l 	$80.w,TOOLS_BkpTrap0
	move.l	$110.w,TOOLS_BkpTimerD
	move.l	$114.w,TOOLS_BkpTimerC
	move.l	$118.w,TOOLS_BkpACIA
	move.l	$120.w,TOOLS_BkpTimerB
	move.l	$134.w,TOOLS_BkpTimerA
	move.l	$11C.w,TOOLS_BkpFDC
	move.l	#TOOLS_RTE_Interrupt,$70.w
	move.l	#TOOLS_RTE_Interrupt,$68.w
	move.l	#TOOLS_RTE_Interrupt,$134.w
	move.l	#TOOLS_RTE_Interrupt,$120.w
	move.l	#TOOLS_RTE_Interrupt,$114.w
	move.l	#TOOLS_RTE_Interrupt,$110.w
	move.l	#TOOLS_RTE_Interrupt,$118.w
	move.l	$FFFF8200.w,TOOLS_BkpScreenAddress
	move.b	$FFFF820A.w,TOOLS_Bkp820A
	move.b	$FFFF8260.w,TOOLS_Bkp8260
	move.w	$FFFFFA00.w,TOOLS_BkpFA00
	move.l	$FFFFFA06.w,TOOLS_BkpFA06
	move.b	$FFFFFA07.w,TOOLS_BkpFA07
	move.b	$FFFFFA09.w,TOOLS_BkpFA09
	move.b	$FFFFFA13.w,TOOLS_BkpFA13
	move.b	$FFFFFA15.w,TOOLS_BkpFA15
	move.b	$FFFFFA17.w,TOOLS_BkpFA17
	move.b	$FFFFFA19.w,TOOLS_BkpFA19
	move.b	$FFFFFA1B.w,TOOLS_BkpFA1B
	move.b	$FFFFFA1D.w,TOOLS_BkpFA1D
	move.b	$FFFFFA1F.w,TOOLS_BkpFA1F
	move.b	$FFFFFA21.w,TOOLS_BkpFA21
	move.b	$FFFFFA25.w,TOOLS_BkpFA25
	movem.l	$FFFF8240.w,d0-d7
	movem.l	d0-d7,TOOLS_BkpColors
	clr.b	$FFFFFA07.w
	clr.b	$FFFFFA13.w
	clr.b	$FFFFFA09.w
	clr.b	$FFFFFA15.w
	move.b  $484.w,TOOLS_BkpKeyMode
	move.l	$8.w,TOOLS_BkpBusError
	move.l	$C.w,TOOLS_BkpAddressError
	move.l	$14.w,TOOLS_BkpDivideBy0Error
	move.b 	#14,$ffff8800.w 		; PSG port A
	move.b 	$ffff8800.w,TOOLS_BkpPSGPortA
	move.w	#$2300,sr
	rts

TOOLS_Context_Restore:
	move.w	#$2700,sr			; Prevent all interruption
	clr.b	$FFFFFA19.w			; Stop Timer A
	clr.b	$FFFFFA1B.w			; Stop Timer B
	clr.b	$FFFFFA19.w			; Timer A Control: Stop
	clr.b	$FFFFFA1B.w			; Timer B Control: Stop
	move.l	TOOLS_BkpBusError,$8.w
	move.l	TOOLS_BkpAddressError,$C.w
	move.l	TOOLS_BkpDivideBy0Error,$14.w
	move.l 	TOOLS_BkpIllegal,$10.w
	move.l 	TOOLS_BkpPrivilege,$20.w
	move.l 	TOOLS_BkpLineA,$28.w
	move.l 	TOOLS_BkpLineF,$2C.w
	move.l	TOOLS_BkpUSP,a0			; Restore User Stack pointer
	move.l	a0,usp				; Used when we exit superuser mode
	move.w	TOOLS_BkpSR,SR
	move.l	TOOLS_BkpHBL,$68.w
	move.l	TOOLS_BkpVBL,$70.w
	move.l 	TOOLS_BkpTrap0,$80.w
	move.l	TOOLS_BkpTimerB,$120.w
	move.l	TOOLS_BkpTimerA,$134.w
	move.l	TOOLS_BkpTimerC,$114.w
	move.l	TOOLS_BkpTimerD,$110.w
	move.l	TOOLS_BkpACIA,$118.w
	move.l	TOOLS_BkpFDC,$11C.w
	move.b	TOOLS_BkpFA25,$FFFFFA25.w
	move.b	TOOLS_BkpFA21,$FFFFFA21.w
	move.b	TOOLS_BkpFA1F,$FFFFFA1F.w
	move.b	TOOLS_BkpFA1D,$FFFFFA1D.w
	move.b	TOOLS_BkpFA1B,$FFFFFA1B.w
	move.b	TOOLS_BkpFA19,$FFFFFA19.w
	move.b	TOOLS_BkpFA17,$FFFFFA17.w
	move.b	TOOLS_BkpFA15,$FFFFFA15.w
	move.b	TOOLS_BkpFA13,$FFFFFA13.w
	move.b	TOOLS_BkpFA09,$FFFFFA09.w
	move.b	TOOLS_BkpFA07,$FFFFFA07.w
	move.l	TOOLS_BkpFA06,$FFFFFA06.w
	move.w	TOOLS_BkpFA00,$FFFFFA00.w
	clr.b	$FFFFFA1B.w
	move.b	TOOLS_BkpKeyMode,$484.w
	move.l	TOOLS_BkpScreenAddress,$FFFF8200.w
	movem.l	TOOLS_BkpColors,d0-d7
	movem.l	d0-d7,$FFFF8240.w
	move.b	TOOLS_Bkp8260,$FFFF8260.w
	move.b	#0,$FFFF820A.w			; Recalibrate bit plans
	move.b 	#14,$ffff8800.w 		; PSG port A
	move.b 	TOOLS_BkpPSGPortA,$ffff8802.w
	move.w 	#$2300,sr
	stop	#$2300
	move.b	TOOLS_Bkp820A,$FFFF820A.w
	rts

TOOLS_RTE_Interrupt:
	rte

	; Detect WakeState of the machine:
	;	- Store WakeState in TOOLS_WakeState (byte)
	; WS is very important for any routine requiring synchronization like Fullscreen or SyncScroll
	; This routine is 100% issued from the code of Troed/SYNC that you can find in here: https://github.com/troed/WSDETECT
TOOLS_DetectWakeState:
	movem.l d0-d7/a0-a1,-(sp)
	; Save
	lea	._sres(pc),a0			; Resolution...
	move.b 	$ffff8260.w,3(a0)		; ... in restore code
	lea 	._sfreq(pc),a0			; Frequency...
	move.b 	$ffff820a.w,3(a0)		; ... in restore code
	lea 	._ssr(pc),a0			; SR...
	move.w 	sr,2(a0)			; ... in restore code
	lea 	._svbl(pc),a0			; VBL...
	move.l 	$70.w,2(a0)			; ... in restore code
	; Set VBL
	move.w 	#$2300,sr
	lea 	._vbl(pc),a0
	move.l 	a0,$70.w
	; Set VBL and wait for vbl to just happen
	lea 	._vsync(pc),a0
	sf 	(a0)
._vwait:
	tst.b 	(a0)				; When VBL happens it set a0 to true
	beq.s 	._vwait
	; Here is the magic:
	; We are at the top of the screen and so we start detection
	; Must be run just after VBL - expects to lock onto first line.
	;
	; HI/LO back at cycle 4	 = left border (short) open on STE
	; 60/50 back at cycle 54 = 60Hz line start (+2) in WS1/WS3
	; HI/LO at cycle 168	 = early (mono) screen end in WS2
	; HI/LO at cycle 378	 = right border open in WS3/WS4/WS2
	; = 180 byte line, STE
	;    54 byte line, WS2
	;   206 byte line, WS3
	;   204 byte line, WS4
	;   162 byte line, WS1
	move.w 	#$2700,sr
	lea 	$ffff820a,a0			; a0=freq
	lea 	$ffff8260,a1			; a1=rez
	; run tests in low res & 50 hz
	move.b 	#0,(a1)				; Low rez
	move.b 	#2,(a0)				; 50Hz
	; skip line
.l0:
	move.b 	$ffff8209.w,d0			; Low byte of address counter
	cmp.b 	$ffff8209.w,d0
	bne.s 	.l0				; When the line is displayed, the counter is changing
	; skip border, then lock		; The counter does not change so we are in the right border
	moveq 	#0,d0
.sync:
	move.b 	$ffff8209.w,d0
	cmp.b 	$ffff8209.w,d0
	beq.s 	.sync				; While we are in the border, the counter does not change
	move.b 	$ffff8209.w,d0			; We leaved the loop so we just pass the left border and are in the displayed screen
	not.w 	d0
	lsr.w 	d0,d0				; Synchronization is now done - We are at the start of the first line after left border
	; Synchronization done
	; Initialize registers to 0
	moveq 	#0,d0				; 1 nop
	moveq 	#0,d2				; 1 nop
	moveq 	#0,d3				; 1 nop
	moveq 	#0,d4				; 1 nop
	moveq 	#0,d5				; 1 nop
	moveq 	#20-1,d7			; 1 nop
.d1:	dbf 	d7,.d1				; 20x3+1 nop (+1 when I exit)
	or.l 	d0,d0				; 2 nop
	; Get screen address at start
	move.b 	$ffff8207.w,d2			; 3 nop
	move.b 	$ffff8209.w,d3			; 3 nop
	; cycle 508
	move.w 	a0,(a1)				; 2 nop: HI			508->4
	; HI/LO back at cycle 4 will open a short left border on STE
	move.b 	d0,(a1)				; 2 nop: LO 			4->12
	moveq 	#1-1,d7				; 1 nop: 			12->16
.d2	dbf 	d7,.d2				; 1*3+1 nop: 			16->32
	or.l 	d0,d0				; 2 nop: 			32->40
	move.b 	d0,(a0)				; 2 nop: 60HZ 			40->48
	exg 	d0,d0				; 1,5 nop 			if WS1/WS3 48->54 or 2 nop if WS2/WS4 48->56
	; cycle 54 - back to 50Hz will cause +2 in WS1/WS3 but not WS2/WS4
	move.w 	a0,(a0)				; 2 nop: 50HZ 			if WS1/WS3 54-62 or 56-64 if WS2/WS4
	; cycle 64
	moveq 	#8-1,d7				; 1 nop				64->68
.d3	dbf 	d7,.d3				; 8x3+1 nop			68->168
	; HI/LO at cycle 168 will cause screen stop in WS2
	move.w 	a0,(a1)				; 2 nop: HI			168->176
	move.b 	d0,(a1)				; 2 nop: LO			176->184
	moveq 	#15-1,d7			; 1 nop				184->188
.d4	dbf 	d7,.d4				; 15*3+1 nop			188->372
	exg 	d0,d0				; 1,5 nop			if WS2/WS3/WS4 372->378 if WS1 372->380
	; cycle 378 - right border RES WS2/WS3/WS4 position
	move.w 	a0,(a1)				; 2 nop: HI			if WS2/WS3/WS4 378->386 if WS1 380->388
	move.b 	d0,(a1)				; 2 nop: LO			if WS2/WS3/WS4 386->394 if WS1 388->396
	moveq 	#7-1,d7				; 1 nop				if WS2/WS3/WS4 394->398 if WS1 396->400
.d5	dbf 	d7,.d5				; 7*3+1 nop			if WS2/WS3/WS4 398->486 if WS1 400->488
	; cycle 488 - safe to read video address at end
	move.b 	$ffff8207.w,d4			; 3 nop				488->500
	move.b 	$ffff8209.w,d5			; 3 nop				500->512=0
	; cycle 0 - clear shifter using Level 16 stabilizer
	moveq 	#30-1,d7			; 1 nop				0->4
.d6	dbf 	d7,.d6				; 30*3+1 nop			4->368
	or.l 	d0,d0				; 2 nop				368->376
	move.b 	d0,(a0)				; 2 nop: 60HZ			376->384
	move.w 	a0,(a0)				; 2 nop: 50HZ			384->392
	moveq 	#3-1,d7				; 1 nop				392->396
.d7	dbf 	d7,.d7				; 3*3+1 nop			396->436
	or.l 	d0,d0				; 2 nop				436->444
	move.w 	a0,(a1)				; 2 nop: HI			444->452
	nop					; 1 nop				452->456
	move.b 	d0,(a1)				; 2 nop: LO			456->464
	; time to do math
	; if d4d5-d2d3 == 54 then we're in WS2
	; else if d4d5-d2d3 == 206 we're in WS3
	; else if d4d5-d2d3 == 204 we're in WS4
	; else if d4d5-d2d3 == 162 we're in WS1
	; else if d4d5-d2d3 == 180 we're on STE
	; else .. well should not happen
	lsl.w 	#8,d2
	or.b 	d3,d2				; d2=d2d3
	lsl.w 	#8,d4
	or.b 	d5,d4				; d4=d4d5
	sub.w 	d2,d4				; d4=length of the line in bytes
.ws2:	cmp.w 	#54,d4
	bne.s 	.ws3
	move.b	#2,TOOLS_WakeState		; WS2: line is 54 bytes length: line without left border stopped at cycle 168
	bra.s	.done
.ws3:	cmp.w 	#206,d4
	bne.s 	.ws4
	move.b	#3,TOOLS_WakeState		; WS3: line is 206 bytes length: 2 bytes small left border + 160 bytes main page + 44 bytes right border
	bra.s	.done
.ws4:	cmp.w 	#204,d4
	bne.s 	.ws1
	move.b	#4,TOOLS_WakeState		; WS4: line is 204 bytes length: no left boder + 160 bytes main page + 44 bytes right border
	bra.s	.done
.ws1:	cmp.w 	#162,d4
	bne.s 	.ste
	move.b	#1,TOOLS_WakeState		; WS1: line is 162 bytes length: 2 bytes small left border + 160 bytes main page + no right border
	bra.s	.done
.ste:	move.b	#0,TOOLS_WakeState		; STE: line is 180 bytes length: 20 bytes left border + 160 bytes main image
.done
	move.w 	#$2300,sr
	; Detection completed
	lea 	._vsync(pc),a0
	sf 	(a0)
._vwat2	tst.b (a0)
	beq.s 	._vwat2
	; Restore initial resolution and frequency as well as VBL and SR
._sres:	move.b 	#0,$ffff8260.w			; Resolution
._sfreq:move.b 	#0,$ffff820a.w			; Frequency
._svbl:	move.l 	#0,$70.w			; VBL
._ssr:	move.w 	#0,sr				; SR
	; Restore used registers
	movem.l (sp)+,a0-a1/d0-d7
	rts
	; VBL routine used to know when VBL just occured
	; assumes _vsync in a0
._vbl:	st 		(a0)
	rte
	; Save VBL address
._vsync: ds.w 1					; Save of vsync pointer

TOOLS_CleanKeyboardExit:
	btst	#5,$fffffc00.w			; Keyboard ACIA control
	beq.s	.noerror
	tst.b	$fffffc02.w			; Keyboard ACIA data
	bra.s	TOOLS_CleanKeyboardExit
.noerror:
	btst	#0,$fffffc00.w			; Keyboard ACIA control
	beq.s	.emptybuff			; Buffer is empty
	tst.b	$fffffc02.w
	bra.s	TOOLS_CleanKeyboardExit
.emptybuff:
	rts

; ===========================================================
			SECTION BSS
; ===========================================================

; ----------------------------------------------------
; Backup section
; ----------------------------------------------------
	even
TOOLS_BkpFA25:		ds.b	1		; MFP_TimerD_Data
TOOLS_BkpFA21:		ds.b	1		; MFP_TimerB_Data
TOOLS_BkpFA1F:		ds.b	1		; MFP_TimerA_Data
TOOLS_BkpFA1D:		ds.b	1		; MFP_TimerC&D_Control
TOOLS_BkpFA1B:		ds.b	1		; MFP_TimerB_Control
TOOLS_BkpFA19:		ds.b	1		; MFP_TimerA_Control
TOOLS_BkpFA17:		ds.b	1		; MFP_VR
TOOLS_BkpFA15:		ds.b	1		; MFP_IMRB
TOOLS_BkpFA13:		ds.b	1		; MFP_IMRA
TOOLS_BkpFA09:		ds.b	1		; MFP_IERB
TOOLS_BkpFA07:		ds.b	1		; MFP_IERA
TOOLS_BkpKeyMode	ds.b 	1		; Keymode
	even
TOOLS_BkpSR:		ds.w	1		; Status Register. Bits 8, 9, 10 fo rmask of interrupt
TOOLS_BkpUSP:		ds.l	1		; User Stack Pointer
TOOLS_BkpUser:		ds.l	1		; Required to come back to non-super
TOOLS_BkpVBL:		ds.l	1		; $70
TOOLS_BkpHBL:		ds.l	1		; $68
TOOLS_BkpTimerD:	ds.l	1		; $110
TOOLS_BkpTimerC:	ds.l	1		; $114
TOOLS_BkpACIA:		ds.l	1		; $118
TOOLS_BkpTimerB:	ds.l	1		; $120
TOOLS_BkpTimerA:	ds.l	1		; $134
TOOLS_BkpFDC:		ds.l	1		; $11C
TOOLS_BkpFA06:		ds.l	1		; MFP
TOOLS_BkpFA00:		ds.w	1		; I/O port du MFP
TOOLS_Bkp820A:		ds.b	1		; Fr�quence de l'�cran - 2=50Hz, 0=60Hz
TOOLS_Bkp8260:		ds.b	1		; R�solution de l'�cran - 0=Low;1=Mid;2=High
TOOLS_BkpColors:	ds.w	16		; 1 word per color and 16 colors
TOOLS_BkpScreenAddress:	ds.l	1		; Screen address. Low byte is always 0
						; (High byte in $FFFF8201, Medium in $FFFF8203, Low byte in $FFFF8205 = $00)
TOOLS_BkpBusError:	ds.l	1		; $8 Bus error vector
TOOLS_BkpAddressError:	ds.l 	1		; $C Address error vector
TOOLS_BkpDivideBy0Error: ds.l	1		; $14 Divide by zero error vector
		; WakeState variables
TOOLS_WakeState:	ds.b	1		; 0=STE, 1=WS1, 2=WS2, 3=WS3, 4=WS4
TOOLS_BkpPSGPortA	ds.b 	1		; PSG Port A
	even
TOOLS_BkpIllegal	ds.l 	1
TOOLS_BkpPrivilege	ds.l 	1
TOOLS_BkpLineA		ds.l 	1
TOOLS_BkpLineF		ds.l 	1
TOOLS_BkpTrap0		ds.l 	1
