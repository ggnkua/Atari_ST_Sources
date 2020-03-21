
; Multiplication 24*24 bits
; r‚sultat sur 48 bits
; (entiers sign‚s)

; (c) 1994 AGOPIAN Mathias pour STMAG


HSR		equ	$ffe9		;Host Status Register
HRX		equ	$ffeb		;Host Receive Register
HTX		equ	$ffeb		;Host Transmit Register


	org	p:$0
	jmp	start
	
	org	p:$40
start	
m24x24	jclr	#0,X:HSR,*
	movep	x:HRX,x0
	jclr	#0,X:HSR,*
	movep	x:HRX,y0
	
	mpy	x0,y0,a
	asr	a
	
	jclr	#1,X:HSR,*
	movep	a0,x:HTX	; poids faible
	jclr	#1,X:HSR,*
	movep	a1,x:HTX	; poids fort
	jmp	m24x24
	rts
	
	