BCR	equ	$fffe
IPR	equ	$ffff
CRA	equ	$ffec
CRB	equ	$ffed
PCC	equ	$ffe1
PCDDR	equ	$ffe3
SSISR	equ	$ffee
TX	equ	$ffef

; CRA bits------------------------------------------------
; 15 = PS        = 0      : 0=/1, 1=/8, prescalar
; 14-13 = WL1-0  = 10     : 00=8, 01=12, 10=16, 11=24 bits (set to 24-bits now)
; 12-8 = DC4-DC0 = 0 0001 : divider control (normally word transfer rate)
; 7-0 = PM7-0    = $00    : divide by 1-256, 0=fastest (divide by 1)

CRA_BITS	EQU	$4100

; CRB bits --------------------------------------------------
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

CRB_BITS	EQU	$F83C


;	ORG	P:0
;	jmp	Start

START	EQU	$200

	ORG	P:START
Start	ori	#3,mr
	movep	#>$3000,X:<<IPR
	movep	#>0,X:<<BCR
	movep	#>$1ff,X:<<PCC

	movep	#CRA_BITS,X:<<CRA	;see above chart
	movep	#CRB_BITS,X:<<CRB	;see above chart
	btst	#4,X:<<SSISR		;read SSI SR to clear TUE bit
	movep	#>0,X:<<TX

	ori	#4,omr
	move	#$100,r0
	move	#$ff,m0
Loop	movep	#$0,X:<<TX
	movep	#$ffffff,X:<<TX
	jmp	Loop

	END	START
