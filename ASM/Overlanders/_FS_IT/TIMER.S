; Author: Herve 'Silver' Durand et Benoit 'Crystar' Durand
; Demo Group: The Overlanders
; Organization: The Union
; Date (dd/mm/yyyy): 21/10/2016

; Objective: Set Timer to use between A, B or D

; HOW-TO:
;	- In your main program set TIMER_MFP to timer you want to use:
;		  TIMER_MFP	EQU	$A for Timer A or $B for Timer B or $C for Timer C or $D for Timer D
;	  In case nothing is specified, TIMER_A is used
;	- By default, Timer A is selected as it has the top priority
;	  Timer B can also be selected
;	  Timer C
;	  Timer D is at a very low level as after Timer B and Keyboard so you should not use it
;
; Important:
;	- Timer C can't be selected as it is a 200Hz clock timer which does not fit with what we're doing
;	- Keep in mind the MFP interrupt priorities listed below:
;		Priority	Description
;		15 (HIGHEST)    Monochrome monitor detect
;		14              RS232 ring indicator
;		13              System clock (timer A)						<---- Timer A at the top so the default one
;		12              RS232 receive buffer full
;		11              RS232 receive error
;		10              RS232 transmit buffer empty
;		9               RS232 transmit buffer full
;		8               Horizontal blanking counter (MFP timer B)	<---- Timer B
;		7               Disk drive controller						<---- FDC lower that Timer A & B
;		6               Keyboard and MIDI (ACIA)
;		5               MFP timer C									<---- Timer C unused
;		4               RS232 baud rate generator (MFP timer D)		<---- Timer D: really low as after Timer B and Keyboard
;		3               GPU operation done
;		2               RS232 Clear To Send (CTS)
;		1               RS232 Data Carrier Detect (DCD)
;		0 (LOWEST)      Centronics busy

	ifnd	TIMER_MFP	; In case TIMER_MFP is not set, Timer A is selected by default
TIMER_MFP		EQU	$A
	endc

	ifeq	TIMER_MFP-$B
TIMER_A			EQU	0
TIMER_B			EQU	1
TIMER_C			EQU	0
TIMER_D			EQU	0
	endc

	ifeq	TIMER_MFP-$C
TIMER_A			EQU	0
TIMER_B			EQU	0
TIMER_C			EQU	1
TIMER_D			EQU	0
	endc

	ifeq	TIMER_MFP-$D
TIMER_A			EQU	0
TIMER_B			EQU	0
TIMER_C			EQU	0
TIMER_D			EQU	1
	endc

	ifnd	TIMER_A		; In case there is an error (TIMER_MFP set to something else than $A/$B/$D), Timer A is selected by default
TIMER_A			EQU	1
TIMER_B			EQU	0
TIMER_C			EQU	0
TIMER_D			EQU	0
	endc

	ifnd 	MFP_VR_BASE
MFP_VR_BASE		EQU	$40
	endc

TIMER_MFP_IERA_IMRA	EQU	0+(TIMER_A*%00100000)+(TIMER_B*%00000001)
TIMER_MFP_IERB_IMRB	EQU	0+(TIMER_C*%00100000)+(TIMER_D*%00010000)
TIMER_CONTROL		EQU	(TIMER_A*$FFFFFA19)+(TIMER_B*$FFFFFA1B)+(TIMER_C*$FFFFFA1D)+(TIMER_D*$FFFFFA1D)
TIMER_DATA		EQU	(TIMER_A*$FFFFFA1F)+(TIMER_B*$FFFFFA21)+(TIMER_C*$FFFFFA23)+(TIMER_D*$FFFFFA25)
TIMER_VECTOR		EQU	(TIMER_A*$134)+(TIMER_B*$120)+(TIMER_C*$114)+(TIMER_D*$110)-$100+MFP_VR_BASE*4
TIMER_STOP		EQU	(TIMER_A*%00000000)+(TIMER_B*%00000000)+(TIMER_C*%00001111)+(TIMER_D*%11110000)	; and.b to stop the related timer (Timers C&D) share the same control register ($FFFFFA1D)
