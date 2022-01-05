HSR	equ	$ffe9	;Host Status Register
HRX	equ	$ffeb	;Host Receive Register
HTX	equ	$ffeb	;Host Transmit Register
PBC	equ	$ffe0	;Port B Control register

rec	MACRO	dest
	jclr	#0,x:<<HSR,*
	movep	x:<<HRX,dest
	ENDM

env	MACRO	source
	jclr	#1,x:<<HSR,*
	movep	source,x:<<HTX
	ENDM
		

	org p:$0
	jmp 	START
	
	org	p:$40	
START
	clr	a	#0,x0
	rec	y1
	do	y1,loop0
	rec	x0
	rec	x1
	mac	x0,x1,a
loop0	
	env	a
	nop
	jmp	START

