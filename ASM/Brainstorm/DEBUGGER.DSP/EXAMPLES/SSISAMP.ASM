M_BCR   EQU     $FFFE           ; Port A Bus Control Register
M_HTX   EQU     $FFEB           ; Host Transmit Data Register
M_HSR	EQU	$ffe9		; Host status register
M_RX    EQU     $FFEF           ; Serial Receive Data Register
M_TX    EQU     $FFEF           ; Serial Transmit Data Register
M_TSR	equ	$ffee		; don't care skip register
M_CRA   EQU     $FFEC           ; SSI Control Register A
M_CRB   EQU     $FFED           ; SSI Control Register B
M_SR    EQU     $FFEE           ; SSI Status Register
M_RDF   EQU     7               ; Receive Data Register Full
M_TDE	equ	6		; Transmit data empty
M_TFS	equ	2		; Transmit sync flag
M_RFS	equ	3		; Receive sync flag
M_IPR   EQU     $FFFF           ; Interrupt Priority Register
M_PCC   EQU     $FFE1           ; Port C Control Register
M_PCDDR EQU     $FFE3           ; Port C Data Direction Register

;	org	X:0 
;		dc	1	; left channel data
;		dc	1	; right channel data


;	org	Y:0
;		dc	1	; left channel data
;		dc	1	; right channel data


	org	P:$0
	jmp	start

	org	p:$000c		;Receive interrupt
	movep	X:M_RX,X:(r0)+

	org	p:$0010		;Transmit interrupt
	movep	Y:(r1)+,X:M_TX
	
	org	p:$40

start
	move	#0,r3
	clr	a
	do	#2,clearloop
	move	a,Y:(r3)+
clearloop
	movep	#0,X:M_BCR		; 0 wait states
	movep	#$3000,X:M_IPR		; set interrupt priority 3 for ssi	
	move	#0,r0		;The receive interrupt uses r0
	move	#0,r1		;The transmit interrupt uses r1
	move	#1,m0		;The receive interrupt wraps at 2 entries
	move	#1,m1		;The transmit interrupt wraps at 2 entries
	jsr	setupssi
	andi	#$fc,MR			; unmask interrupts

; Now that the interrupts are setup the only work needed is to move the 
; receive data from its buffer to the transmit data buffer.  This is done
; here in a full blast loop that pays no attention to what is needed.

deadloop
	move	#0,r3
	nop
	move	X:(r3),x1
	move	x1,Y:(r3)+		; Move over left data
	
	move	X:(r3),x1
	move	x1,Y:(r3)		; Move over right data
	jmp	deadloop
	
	
;
;
;    Initialize SSI Port

; CRA bits------------------------------------------------
; 15 = PS        = 0      : 0=/1, 1=/8, prescalar
; 14-13 = WL1-0  = 10     : 00=8, 01=12, 10=16, 11=24 bits (set to 24-bits now)
; 12-8 = DC4-DC0 = 0 0001 : divider control (normally word transfer rate)
; 7-0 = PM7-0    = $00    : divide by 1-256, 0=fastest (divide by 1)

CRA_BITS	EQU	$4100

; SSI CRB bits --------------------------------------------------
; CRB determines the serial modes
; 15 = RIE	= 1 : 0=disable, 1=enable receive interrupt
; 14 = TIE	= 1 : 0=disable, 1=enable transmit interrupt
; 13 = RE	= 1 : 0=disable, 1=enable receive
; 12 = TE	= 1 : 0=disable, 1=enable transmit

; 11 = MODE	= 1 : 0=normal, 1=network
; 10 = GCK	= 0 : 0=continuous, 1=gated
;  9 = SYN	= 0 : 0=asynchronous, 1=synchronous, transmit and receive
;  8 = FSL0	= 0 : 0=word, 1=bit length, Frame Sync clock

;  7 = FSL1	= 0 : 0=TX and RX same length, 1=different
;  6 = SHFD	= 0 : 0=MSB first, 1=LSB first
;  5 = SCKD	= 0 : 0=external, 1=internal bit clock
;  4 = SCD2	= 0 : 0=input, 1=output on SC2, transmit frame sync

;  3 = SCD1	= 0 : 0=input, 1=output on SC1, receive frame sync
;  2 = SCD0	= 0 : 0=input, 1=output on SC0, receive clock
;  1 = OF1	= 0 :
;  0 = OF0	= 0 : OF0 not to SC0 ; must match SCKD

CRB_BITS	EQU	$F800

;***************************************************************************
setupssi
	movep	#$01F8,X:M_PCC		;set port c to SSI + SCI
	movep	#CRA_BITS,X:M_CRA	;see above chart
	movep	#CRB_BITS,X:M_CRB	;see above chart

	btst	#4,X:M_SR		;read SSI SR to clear TUE bit

; this starts the whole process by causing the first transmit interrupt
	movep	X:(r1)+,X:M_TX		; send out first sample

	rts
