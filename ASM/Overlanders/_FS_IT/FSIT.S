; Author: Herve 'Janek' Durand et Benoit 'RATI' Durand
; Demo Group: Overlanders
; Organization: The Union
; Date (dd/mm/yyyy): 25/09/2016
;
; Objective: Fullscreen in interrupt Timer A or B or C or D.
;
; Type: Library
;
; HOW-TO:
;	- Include this file in your source file
;	- Set TIMER_MFP to timer you want to use: $A for Timer A, $B for Timer B, $C for Timer C, $D for Timer D
;	  In case nothing is specified, TIMER_A is used
;	- jsr FSIT_Start to start the fullscreen
;	- jsr FSIT_Stop to stop the fullscreen
;	- Before a long instruction put a "stop #$2300" that will give you 172 cycles to do what you want (even multiple mulu,div,movem...)
;	- Stop #$2300 halts the program till a interruption above level 3 occurs (VBL or MFP) and so you don't disturb interrupt fullscreen
;	  as Timer is level 6.
;	- It remains around 64000 cycles for the main routine in the same VBL meaning that this fullscreen takes 60% of the VBL.
;	- Do not use the Timer used in this routine in your main program

; How it works:
;	- In VBL: set Timer_Top only when FSIT_Start is called so that VBL can be normally used by main program
;	- In Timer_Top:
;		- Remove top border
;		- Synchronize with electron beam to:
;			- Open right border ---> first line is 204 bytes long
;			- Set next Timer_230Bytes that will occurs just before right border of the next line
;			- Set Stabilizer to avoid bitplane decal
;			- Open Left border
;	- In Timer_230Bytes:
;		- Synchronize with electron beam
;		- Open Right border
;		- Prepare next Timer which could be either Timer_230Bytes or Timer_230Bytes_Bottom
;		- Set Stabilizer
;		- Open Left Border
;		- Details:
;			- A counter of lines is in $40C.w: it follows the SyncSequence in section DATA
;			- $40E points to the right SyncSequence starting at the second line (4)
;			- Synchronization value changes each line by substracting $1A line after line
;			- Code is dynamically modified in:
;				- Timer_230Bytes_3-2 for Synched value
;				- Timer_230Bytes_3+1 for Timer_230Bytes_Bottom and Timer_End
;	- Timer_End:
;		- Stop Timer as there's no more line to display
;		- Setup new Timer for Timer_Top for top border removal (no more VBL)
;
;	- Full sequence description:
;		- Line 1 (204 bytes) 		<--- Timer_Top
;		- Lines 2 to 212 (211 lines)	<--- Timer_230Bytes
;		- Line 213 			<--- Timer_230Bytes_Bottom
;		- Lines 214 to 228 (15 lines)	<--- Timer_230Bytes
;		- Line 229 			<--- Timer_230Bytes_Bottom
;		- Line 230 to 276 (47 lines)	<--- Timer_230Bytes
;		- Line 277 (0 Bytes)		<--- Timer_End
;
; Tips:
;	- When ColorIndicator is set to 1, initial synced value is set to $6A
;	  as move.w #$xxxx,$FFFF8240.w takes 16 cycles each so 32 cycles for both meaning 16 bytes ($10)
;

; ===========================================================
;						SECTION VARIABLES
; ===========================================================
FSIT_ColorIndicator	EQU	1
FSIT_StartSyncByte	EQU	$72-FSIT_ColorIndicator*$10		; $10 as move.w for color indicator uses 32 cycles meaning 16 bytes
FSIT_Timer_Offset	EQU	-FSIT_ColorIndicator*2			; was 3	;;;;

; ===========================================================
;						SECTION INCLUDES
; ===========================================================

	INCLUDE	"TIMER.S"

; ===========================================================
						SECTION TEXT
; ===========================================================
; ----------------------------------------------------
; Interrupt section
; ----------------------------------------------------

FSIT_Start:
	; Set HBL, VBL and Mask of Interrupt
	; HBL must be set to rte so it can't be used in main program
	; SR is the Status Register (16 bits). Low byte is for test flags (Z,C...) and High byte is for System
	; Set MFP to allow Timer that we will start in VBL
	move.w	sr,-(sp)
 	stop	#$2300							; Stop to sync
	move.w	#$2700,sr						; No interrupt to prevent disturbation
	move.b	#TIMER_MFP_IERA_IMRA,$FFFFFA07.w			; MFP_IERA : Timer A or B
	move.b	#TIMER_MFP_IERA_IMRA,$FFFFFA13.w			; MFP_IMRA (Mask of interrupt)
	move.b	#TIMER_MFP_IERB_IMRB,$FFFFFA09.w			; MFP_IERB : No Timer C & D
	move.b	#TIMER_MFP_IERB_IMRB,$FFFFFA15.w			; MFP_IMBR (Mask of interrupt)
	bclr	#3,$FFFFFA17.w						; Automatic end of interrupt
	and.b 	#TIMER_STOP,TIMER_CONTROL.w				; Timer control : Stop Timer http://retrospec.sgn.net/users/tomcat/miodrag/Atari_ST/Atari%20ST%20Internals.htm
	; Set HBL
	move.l	#FSIT_HBL,$68.w
	; Set VBL
	move.l	$70.w,FSIT_BkpVBL					; Backup existing VBL so that VBL can be normally used in main program
	move.l	#FSIT_VBL,$70.w						; Set VBL that will be executed only one time
	; Wait one VBL
	stop	#$2300							; To prevent any disturbation: I force at least one Timer to occur
	rte								; Tip: rte restore status register that we put on the stack at the beginning of the routine
									; This way SR is modified and set to $2300

FSIT_Stop:
	and.b	#TIMER_STOP,TIMER_CONTROL.w				; Stop Timer and so stop Fullscreen
	rts

FSIT_HBL:
	rte								; HBL does nothing. Must be empty.

FSIT_VBL:
	; Set in FSIT_Start and called only the very first time.
	; This one is mandatory to properly set Timer_Top as I need a reference
	; After it's Timer_End that becomes the reference and that will setup Timer_Top to open top border
	; Set Timer_Top to remove top border
	and.b	#TIMER_STOP,TIMER_CONTROL.w				; Timer stop
	move.b	#100,TIMER_DATA.w					; Timer Data
	move.l	#FSIT_Timer_Top,TIMER_VECTOR.w				; Set Timer routine
	ifeq 	TIMER_MFP-$C
		or.b 	#%01000000,TIMER_CONTROL.w 			; Timer control : divider = 50
	else
		or.b 	#%00000100,TIMER_CONTROL.w 			; Timer control : divider = 50
	endc
	; Restore previous VBL as Top border will now be removed from a setup in Timer_End
	move.l	FSIT_BkpVBL,$70.w					; VBL that was in place before calling FSIT_Start
	rte

FSIT_Timer_Top:
	; Timer_Top is started and set in FSIT_VBL the very first time
	; Timer_Top is executed one time per VBL as  I stop it in this routine but I start another one
	; Then Timer_Top is started and set in FSIT_Timer_End
	; The frequency set in VBL for this Timer make it executing in the right line to open the top border (line 34)
	move.w	#$2100,sr						; 0 : 8 cycles
	stop	#$2100							; 8 : 4 cycles : Wait an HBL for synchro <-- stabilization
	move.w	#$2600,sr						; 12 : 8 cycles : Prevent all interrupts (HBL/VBL/MFP)
	movem.l	d0-d1/a0,-(sp)						; 20 : 32 cycles (8+8n) : backup registers used in this routine
	moveq	#0,d0							; 52 : 4 cycles
	and.b 	#TIMER_STOP,TIMER_CONTROL.w				; 16 cycles : Timer Control --> Stop Timer
	lea	$FFFF820A.w,a0						; 72 : 8 cycles : Frequency 0=60Hz, 2=50Hz
	dcb.w	76,$4E71						; 80 : 304 cycles : 76 nop : min=70, max=83, middle=76
	; Open Top border
	move.b	d0,(a0)							; 384 : 8 cycles : 60Hz
	dcb.w	13,$4E71						; 392 : 52 cycles
	move.w	a0,(a0)							; 444 : 8 cycles : 50Hz - $FFFF820B not used so $82 in $FFFF820A but only 2 low bits used so treated like $02 (http://retrospec.sgn.net/users/tomcat/miodrag/Atari_ST/Atari%20ST%20Internals.htm)

	; Electron ray Synchronisation
	moveq	#12,d0							; 452 : Minimum value I saw for synchornization
FSIT_Timer_Top_Sync:
	move.b	$FFFF8209.w,d1						; Video counter
	beq.s	FSIT_Timer_Top_Sync					; Loop till <>0
	sub.b	d1,d0							; Sub to determine the number of decal to synchronize
	lsr.w	d0,d0							; Synchronized. d0 = 0 at the end of this instruction

	; Prepare full sequence for Fullscreen in interrupt Timer
	dcb.w	65-4-5-4-6-5-8,$4E71
	; Set SyncSequence Offset
	move.w	#4,$40E.w						; 16 cycles : Set offset for next sync sequence in $40E.w (part of the 15 long reserved for MFP interrupt)
	; Set Bottom1 routine in test
	move.b	#FSIT_Timer_230Bytes_Bottom-FSIT_Timer_230Bytes_2-2,FSIT_Timer_230Bytes_2+1 ; 20 cycles : initiate test to bottom border removal
	; Set Nb Lines of top part of the screen
	move.w	#211,$40C.w						; 16 cycles : 15 long in $40C.w : Space for reserved logical vector of the MFP
	; Set next routine to be executed by Timer
	move.l	#FSIT_Timer_230Bytes,TIMER_VECTOR.w			; 24 cycles : Normal 230 Bytes lines
	move.b	#FSIT_StartSyncByte,FSIT_Timer_230Bytes_1+3		; 20 cycles: Sync low byte of the second line (204+166=$172 so $72)
	ifne	FSIT_ColorIndicator
	move.w	#$0077,$FFFF8240.w					; 16 cycles
	move.w	#$0000,$FFFF8240.w					; 16 cycles
	else
	dcb.w	8,$4E71							; 32 cycles
	endc
	; Right border
	move.b	d0,(a0)							; 8 cycles : 60Hz
	move.w	a0,(a0)							; 8 cycles : 50Hz
	dcb.w	13-5-5-2-1,$4E71
	; Set Timer for 230 bytes lines so that I arrive just before left border of the current line
	; Timer = 2457600/data/divider = 2457600/23/4=26713Hz
	move.b	#9+FSIT_Timer_Offset,TIMER_DATA.w			;;;;
	ifeq 	TIMER_MFP-$C
		or.b 	#%00100000,TIMER_CONTROL.w 			; 24 cycles : Timer control : divider = 10
	else
		or.b 	#%00000010,TIMER_CONTROL.w 			; 24 cycles : Timer control : divider = 10
	endc
	; Stabilizer
	lea	$FFFF8260.w,a0						; Resolution
	move.w	a0,(a0)							; High Rez
	nop
	move.w	d0,(a0)							; Low Rez
	; Left border
	dcb.w	12,$4E71
	move.w	a0,(a0)							; High Rez
	nop
	move.b	d0,(a0)							; Low Rez
	ifne	FSIT_ColorIndicator
	move.w	#$0777,$FFFF8240.w
	move.w	#$0000,$FFFF8240.w
	endc
	movem.l	(sp)+,d0-d1/a0
	rte

	; Timer interrupt for a normal 230 bytes long line
	; It starts on the right: right border + Stabilizer + Left Border + Setup next Timer interrupt with new sync byte
	; This routine uses 2 registers: d0 and a0
FSIT_Timer_230Bytes:
	opt	o-
	move.w	d0,-(sp)						; 8 cycles
	move.l	a0,usp							; 4 cycles
	; Synchronize electron ray
	lea	$FFFF8209.w,a0						; 8 cycles : Low byte of video counter that has a value that differs for each line
FSIT_Timer_230Bytes_1:							; This label is used to dynamically modify the SyncByte
	move.w	#FSIT_StartSyncByte,d0					; 8 cycles : value is dynamically changed each line. Here we have the sync value for the first line
	sub.b	(a0)+,d0						; 12 cycles : after that d0 contains number of shift to synchronise electron ray
	lsr.b	d0,d0							; 6+2n : electron is now synchronized. d0 now contains 0
	; Stop Timer
	move.b	d0,TIMER_CONTROL.w					; 12 cycles : Stop Timer - In case it's Timer C or D it halts both of them. To be full clean it should be "and.b #TIMER_STOP,TIMER_CONTROL.w" but no other timer can be used so...
	ifne	FSIT_ColorIndicator
	move.w	#$0500,$FFFF8240.w					; 16 cycles
	move.w	#$0000,$FFFF8240.w					; 16 cycles
	else
	dcb.w	8-8,$4E71						; 32 cycles
	endc
	; Open Right border
	move.b	d0,(a0)							; 8 cycles : 60Hz as a3 = $FFFF820A.w after (a3)+ donne above
	move.w	a0,(a0)							; 8 cycles : 50 Hz
	dcb.w	13-5-5-2,$4E71
	; Setup Timer to for interrupt in next line just before right border = 2457600/23/4=26713Hz
	move.b	#9+FSIT_Timer_Offset,TIMER_DATA.w			;;;;
	ifeq 	TIMER_MFP-$C
		move.b 	#%00100000,TIMER_CONTROL.w 			; 20 cycles : Timer control : divider = 10
	else
		move.b 	#%00000010,TIMER_CONTROL.w 			; 20 cycles : Timer control : divider = 10
	endc
	; Stabilizer
	lea	$FFFF8260.w,a0						; 8 cycles : Screen resolution - 0=Low;1=Mid;2=High
	move.w	a0,(a0)							; 8 cycles : High rez - $FFFF8261 not used so $82 in $FFFF8260 but only 2 low bits used so treated like $02 (http://retrospec.sgn.net/users/tomcat/miodrag/Atari_ST/Atari%20ST%20Internals.htm)
	nop								; 4 cycles
	move.b	d0,(a0)							; 8 cycles : Low rez
	dcb.w	12-4-2-6,$4E71						; 0 cycles
	; Line counter
	subq.w	#1,$40C.w						; 16 cycles : sub 1 to counter of lines
FSIT_Timer_230Bytes_2:
	ble.s	FSIT_Timer_230Bytes_Bottom				; 8 cycles branch not taken, 12 cycles branch taken --> Bottom or end. Modified dynamically in Bottom
	; Prepare next synchro
	sub.b	#$1A,FSIT_Timer_230Bytes_1+3				; 24 cycles: sync value for next line will be done with a new value=current one - $1A
	; Left Border
	move.w	a0,(a0)							; 8 cycles : High Rez
	nop								; 4 cycles
	move.b	d0,(a0)							; 8 cycles : Low Rez
Timer_230Bytes_2:
	ifne	FSIT_ColorIndicator
	move.w	#$0700,$FFFF8240.w
	move.w	#$0000,$FFFF8240.w
	endc
	move.w	(sp)+,d0						; 8 cycles
	move.l	usp,a0							; 4 cycles
	opt	o+
	rte

	; This routine is called by Timer_230Bytes in Timer_230Bytes_3
	; It must located here due to the ble.s
	; Purpose of this routine is to set Timer to Timer_Top so that we complete the loop
FSIT_Timer_End;
	ifne	FSIT_ColorIndicator
	move.w	#$0070,$FFFF8240.w
	move.w	#$0000,$FFFF8240.w
	endc
	and.b 	#TIMER_STOP,TIMER_CONTROL.w				; 16 cycles : Timer Control --> Stop Timer (note that "move.b	d0,TIMER_CONTROL.w" also works as there's only one timer possible to not break the FS)
	move.w	(sp)+,d0						; Restore d0 as this routine is called by Timer_230Bytes
	move.l	usp,a0							; Restore a0 as this routine is called by Timer_230Bytes
	; Set Timer_Top to remove top border
	move.b	#111,TIMER_DATA.w					; Timer Data
	ifeq 	TIMER_MFP-$C
		or.b 	#%01000000,TIMER_CONTROL.w 			; 16 cycles : Timer control : divider = 100
	else
		or.b 	#%00000100,TIMER_CONTROL.w 			; 16 cycles : Timer control : divider = 100
	endc
	move.l	#FSIT_Timer_Top,TIMER_VECTOR.w				; Set Timer routine
	rte

	; This routine is called by Timer_230Bytes in Timer_230Bytes_3
	; This routine is called 2 times following the SyncSequence in DATA section
	; for old and new shifter
FSIT_Timer_230Bytes_Bottom:
	; Line BOTTOM
	move.b	d0,TIMER_CONTROL.w					; 12 cycles : Stop Timer - In case it's Timer C or D it halts both of them. To be full clean it should be "and.b #TIMER_STOP,TIMER_CONTROL.w" but no other timer can be used so...
	dcb.w	5-4,$4E71						; 4 cycles : 5 nops as I'm in branch taken (12 cycles instead of 8)
	; Left Border
	move.w	a0,(a0)							; 8 cycles : High Rez : a0=$FFFF8260
	nop								; 4 cycles
	move.b	d0,(a0)							; 8 cycles : Low Rez
	ifne	FSIT_ColorIndicator
	move.w	#$0007,$FFFF8240.w					; 16 cycles
	move.w	#$0000,$FFFF8240.w					; 16 cycles
	else
	dcb.w	8,$4E71							; 32 cycles
	endc
	dcb.w	89-8-5-3-3-4-6-7-2-3-2-8,$4E71
	; Setup (don't start) Timer Data
	move.b	#9+FSIT_Timer_Offset,TIMER_DATA.w		;;;;
	; Set Nb Lines of bottom part of the screen
	lea	FSIT_SyncSequence,a0					; 12 cycles
	move.w	$40E.w,d0						; 12 cycles : current offset
	addq.w	#4,$40E.w						; 16 cycles : next offset
	move.w	0(a0,d0.w),$40C.w					; 24 cycles : nb lines
	; Set Next routine in test: either Timer_230Bytes_Bottom, either Timer_End
	move.b	3(a0,d0.w),FSIT_Timer_230Bytes_2+1			; 28 cycles
	; Right Border
	move.w	#0,d0							; 8 cycles
	move.l	a1,-(sp)						; 12 cycles. I need a1 for performance reason so I backup it in the stack
	lea	$FFFF820A.w,a1						; 8 cycles : Freq 0=60Hz, 2=50Hz
	ifne	FSIT_ColorIndicator
	move.w	#$0007,$FFFF8240.w					; 16 cycles
	move.w	#$0000,$FFFF8240.w					; 16 cycles
	else
	dcb.w	8,$4E71							; 32 cycles
	endc
	move.b	d0,(a1)							; 8 cycles : 60Hz
	move.w	a1,(a1)							; 8 cycles : 50 Hz
	dcb.w	13-5-2,$4E71
	; Start Timer to for interrupt in next line just before right border = 2457600/23/4=26713Hz
	; Exactly at the same position as in Timer_230Bytes to use same value and secure stability
	ifeq 	TIMER_MFP-$C
		move.b 	#%00100000,TIMER_CONTROL.w 			; 20 cycles : Timer control : divider = 10
	else
		move.b 	#%00000010,TIMER_CONTROL.w 			; 20 cycles : Timer control : divider = 10
	endc
	lea	$FFFF8260.w,a0						; 8 cycles
	; Stabilizer
	move.w	a0,(a0)							; 8 cycles : High Rez
	nop								; 4 cycles
	move.b	d0,(a0)							; 8 cycles : Low Rez
	; Bottom Border
	move.b	d0,(a1)							; 8 cycles : 60 Hz
	dcb.w	12-2-6,$4E71						; 32 cycles
	; Prepare next synchro 2 lines later
	sub.b	#$1A*2,FSIT_Timer_230Bytes_1+3				; 24 cycles: Next sync value in Timer_230 Bytes. 2*$1A as I spent a line for the bottom border manually
	; Left Border
	move.w	a0,(a0)							; 8 cycles : High Rez
	nop								; 4 cycles
	move.b	d0,(a0)							; 8 cycles : Low Rez
	; Restore Low Rez to finish bottom Border
	move.w	a1,(a1)							; 8 cycles : Low Rez: bottom removed properly and we're back to 50Hz for 512 cycles lines
	ifne	FSIT_ColorIndicator
	move.w	#$0007,$FFFF8240.w
	move.w	#$0000,$FFFF8240.w
	endc
	; Restore registers
	move.l	(sp)+,a1						; 8 cycles : Restore a1
	move.w	(sp)+,d0						; 8 cycles : Restore d0
	move.l	usp,a0							; 4 cycles : Restore a0
	rte

; ===========================================================
						SECTION DATA
; ===========================================================

FSIT_SyncSequence:
	dc.w	211,FSIT_Timer_230Bytes_Bottom-FSIT_Timer_230Bytes_2-2	; Old shifter in line 212 from the top (line 247)
	dc.w	15,FSIT_Timer_230Bytes_Bottom-FSIT_Timer_230Bytes_2-2	; New shifter in line 228 from the top (line 263)
	dc.w	47,FSIT_Timer_End-FSIT_Timer_230Bytes_2-2		; 47 last lines to line 276 (line 310)

; ===========================================================
						SECTION BSS
; ===========================================================

FSIT_BkpVBL:	ds.l	1						; To restore existing VBL once VBL becomes useless for the routine (end of FSIT_VBL)
