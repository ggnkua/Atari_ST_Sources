;-------- INTERRUPTS ---------------------------

I_RESET		EQU	$0000   ; hardware _RESET
I_STACK 	EQU	$0002   ; stack error
I_SSIRD 	EQU	$000C   ; SSI receive data
I_SSIRDE	EQU	$000E   ; SSI rec exception
I_SSITD		EQU	$0010   ; SSI transmit data
I_SSITDE	EQU	$0012   ; SSI tra exception
 
I_HSTRD		EQU	$0020   ; host receive data
I_HSTTD		EQU	$0022   ; host transmit data
I_HSTCM		EQU	$0024   ; host command

;-------- I/O EQUATES ---------------------------

M_BCR		EQU	$FFFE	; Port A Bus Control Reg
M_PBC		EQU	$FFE0	; Port B Control Register
M_PCC		EQU	$FFE1	; Port C Control Register

HCR			EQU	$FFE8	; Host Control Register
HSR			EQU	$FFE9	; Host Status Register
HRX			EQU	$FFEB	; Host Receive Data Reg
HTX			EQU	$FFEB	; Host Transmit Data Reg

M_RX		EQU	$FFEF	; SSI Receive Data Reg
M_TX		EQU	$FFEF	; SSI Transmit Data Reg
M_CRA		EQU	$FFEC	; SSI Control Register A
M_CRB		EQU	$FFED	; SSI Control Register B
M_SR		EQU	$FFEE	; SSI Status Register
M_TSR		EQU	$FFEE	; SSI Time Slot Register
M_IPR		EQU	$FFFF	; Interrupt Priority Reg
M_UU		EQU	$FFEA

VMAIN		EQU		$0040

;---- Effects -- only use upper 16 bits ---------

tKaraoke	EQU		8
tLevel		EQU		9

;---- RESET VECTOR ------------------------------

	ORG		P:I_RESET
	JMP		VMAIN

;---- STACK ERROR VECTOR ------------------------

	ORG 	P:I_STACK
	JMP 	VSTACKERR

;---- SSI RCV INTERRUPT VECTORS -----------------

	ORG		P:I_SSIRD		; input
	JSR		VLRTEST

	ORG		P:I_SSIRDE		; input error
	JSR		VELRTEST

	ORG		P:I_SSITD		; output
	JSR		VOUTPUT

	ORG		P:I_SSITDE		; short output error
	MOVEP	X:M_SR,X:M_SR

			
;------------------------------------------------
;	Start of Programm code
;------------------------------------------------

	ORG		P:VMAIN
	JMP		DoMain

;------------------------------------------------
;	Clear stack pointer and status
;------------------------------------------------

VSTACKERR
	ORI		#$03,MR	   		; mask interrupts
	MOVE	#>$00,SP
	JMP		VSTACKERR

;------------------------------------------------
;	Receive interrupt routine + error routine
;------------------------------------------------

VELRTEST
	MOVEP	X:M_SR,X:M_UU	; clear status
VLRTEST
	JCLR	#3,X:M_SR,NoFSync
	MOVEP	X:M_RX,X:tDInFirst ; first in temp
	MOVE	#tDataIn+1,R3
	BSET	#0,X:IsSync		; signal frame sync
	RTI						; to main loop
NoFSync
	MOVEP	X:M_RX,X:(R3)+
	RTI

;------------------------------------------------
;	Transmit interrupt routine
;------------------------------------------------

VOUTPUT
	JSET	#2,X:M_SR,OUT_R	; frame sync ?
	MOVEP	X:OutLeft,X:M_TX
	RTI
OUT_R		
	MOVEP	X:OutRight,X:M_TX
	MOVE	X:tRight,Y1		; load next pair
	MOVE	Y1,X:OutRight
	MOVE	X:tLeft,Y1
	MOVE	Y1,X:OutLeft
	RTI


;------------------------------------------------
;	Init DSP
;------------------------------------------------

DoMain
	RESET
	ORI		#$03,MR			; Mask Interrupts

	MOVE	#tDataIn,R3

	MOVEP	#$1,X:M_PBC		; Port B is Host
	MOVEP	#$3000,X:M_IPR	; SSI RCV INT level 2
	MOVEP	#$4100,X:M_CRA	; Set SSI 16 Bit
							; 2 Frames
	MOVEP	#$F800,X:M_CRB	; Set SSI
	MOVEP	#$0000,X:M_PCC	; Individual reset /
							; SSI Port
	MOVEP	#$01F8,X:M_PCC	; Turn on SSI Port.

	MOVEP	X:M_SR,X:M_UU	; Clear status
	MOVEP	X:M_RX,X:M_SR	; Clear status

	ANDI	#$FC,MR		  ; Unmask all interrupts


;------------------------------------------------
;	Start of forever loop
;	This is looped once for each input frame sync
;------------------------------------------------

;	Registers  R3, and Y1 used by Interrupts
;	Do not use them here!

MainLoop

; NOTE: we have to reach this point before
;		start of second time slot.

	ORI		#$03,MR			; Mask Interrupts
	
	MOVE	X:Right,X0		; transmit samples
	MOVE	X0,X:tRight		; from last loop
	MOVE	X:Left,X0		; to output
	MOVE	X0,X:tLeft		; interrupt handler

	MOVE	#DataLvls,R2	; weight 2 channel
	MOVE	#tDataIn,R1		; stereo input
			
	MOVE	X:(R2)+,X0		; mix 2 channels to
							; one channel
	MOVE	X:(R1)+,X1
	MPY		X0,X1,A		X:(R2)+,X0	; left 1
	MOVE	X:(R1)+,X1
	MPY		X0,X1,B		X:(R2)+,X0	; right 1
	MOVE	X:(R1)+,X1
	MACR	X0,X1,A		X:(R2)+,X0	; left 2
	MOVE	X:(R1)+,X1
	MACR	X0,X1,B		A1,X:Left	; right 2

	MOVE	B1,X:Right
	
	MOVE	X:tDInFirst,X0	; we got already
	MOVE	X0,X:tDataIn	; first data
			
	BCLR	#0,X:IsSync		; free for next sync
	
	ANDI	#$FC,MR		  ; Unmask all interrupts
	
; NOTE: we have to reach this point before
;		end of second time slot.

;------------------------------------------------
;	Here you may include more Effects
;------------------------------------------------
			
	JSSET	#tKaraoke,X:Effect,Karaoke

;------------------------------------------------
;	Do we send peek levels to Host ?
;------------------------------------------------

	JSSET	#tLevel,X:Effect,Level
			
;------------------------------------------------
;	While waiting for next frame sync, we
;	check if we get commands from Host
;------------------------------------------------

Wait
	JCLR	#0,X:<<HSR,NoHostCommand
	MOVEP	X:<<HRX,X0			; Get Host 24 bit

    JSET	#7,X0,ReadXmem		; read/write ?
	MOVE	#>$7F,A				; lower 7 bits
	AND		X0,A		#>$7F,X1
	CMP		X1,A		A1,R1
	JNE		XLocation			; #$7F is SSI CRA
	MOVE	#>$FF00,A
	AND		X0,A
	MOVEP	A1,X:M_CRA
	JMP		NoHostCommand
XLocation
	MOVE	#>$FFFF00,A			; mask out
	AND		X0,A				; 7 bit address
	MOVE	A1,X:(R1)			; host value
	JMP		NoHostCommand
ReadXmem
	MOVE	#>$7F,A				; lower 7 bits
	AND		X0,A				; is address
	MOVE	A1,R1
XMIT
	JCLR	#1,X:<<HSR,XMIT		; wait for host
	MOVEP	X:(R1),X:<<HTX		; send x memory
NoHostCommand
	JSET	#0,X:IsSync,MainLoop
	JMP		Wait
			
;------------------------------------------------
;	Karaoke Effect
;------------------------------------------------

Karaoke
	MOVE	X:Left,A
	MOVE	X:Right,X0
	SUB		X0,A			; left - right
	MOVE	A1,X:Left		; left and right
	MOVE	A1,X:Right		; chanal is same
	RTS

;------------------------------------------------
;	Calculate Peek Level
;------------------------------------------------
Level
	MOVE	X:Counter,A		; get peek of
	MOVE	#$100,X0		; #Counter samples
	SUB		X0,A			; Counter is in
	JNE		LCNotZero		; upper 16 bits
			
	MOVE	X:tPeekRight,A1	; ready for host
	MOVE	A1,X:PeekRight
	MOVE	X:tPeekLeft,A1
	MOVE	A1,X:PeekLeft
	MOVE	X:CountMax,A1
	MOVE	#0,X0
	MOVE	X0,X:tPeekLeft
	MOVE	X0,X:tPeekRight
	
LCNotZero
	MOVE	A1,X:Counter	; store new Counter
			
	MOVE	X:tPeekLeft,X0
	MOVE	X:Left,A
	CMPM	X0,A			X:tPeekRight,X0
	JLE		LNext1
	ABS		A
	MOVE	A1,X:tPeekLeft
LNext1
	MOVE	X:Right,A
	CMPM	X0,A
	JLE		LNext2
	ABS		A
	MOVE	A1,X:tPeekRight
LNext2
	RTS
	
;------------------------------------------------
;	Data for Host I/O
;------------------------------------------------
	ORG	X:$0

DataLvls	DC		$3FFF00
			DC		$3FFF00
			DC		$3FFF00
			DC		$3FFF00
Effect		DC		$000300	; Bit map
							; Karaoke + Levels
CountMax	DC		$020000	; sample number
							; only upper 16 bits
PeekLeft	DC		0		; Peek left
PeekRight	DC		0		; Peek right

;------------------------------------------------
; Internal Datas
;------------------------------------------------

IsSync		DC		0	; frame sync indicator
Left		DC		0	; current left
Right		DC		0	; current right

						; the ones by interrupt
OutLeft		DC		0	; left output channel
OutRight	DC		0	; right output channel
tLeft		DC		0	; temp left output
tRight		DC		0	; temp right output

tPeekLeft	DC		0	; temp left peek
tPeekRight	DC		0	; temp right peek
Counter		DC		$000100	; current counter
							; only upper 16 bits
tOutLeft	DC		0	; only for transmit
tOutRight	DC		0	; interrupt.
tDInFirst	DC		0
tDataIn		DS		8	; max. 8 time slots
	
	END
