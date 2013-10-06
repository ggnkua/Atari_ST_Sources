;
;	MATMULT5.S56 Matrix multiplication as a subroutine
;	part of the HiSoft DevpacDSP tutorial.
;	(c) Copyright HiSoft 1993
;  	All rights reserved.

HSR	equ	$ffe9
HRX	equ	$ffeb

abuffer	equ	$3f00		; subroutine workspace
bbuffer	equ	$3f00
N	equ 	4
	org	P:0
start
; disable modulo arithmetic
	move	#-1,M0
	move	#-1,M1
	move	M0,M2
	move	M0,M4
	move	M0,M5

	movep	X:<<HRX,R0
	
	move	#<Fixed-1,N1
	move	R0,R1
	move	#Fixer+1,N0
	move	(R1)+N1
	movem	R1,P:(R0+N0)
	
	move	#>FixTable,N0
	NOP
	LUA	(R0)+N0,R2	;point to fix up table
Fixer
	Do	#(FixEnd-FixTable)/2,Fixed
	Movem	P:(R2)+,N1
	move	R0,R1
	movem	P:(R2)+,N0
	move	(R1)+N1
	movem	R1,P:(r0+n0)
Fixed	
		
; read in the A array from the host port
	move	#abuffer,R0
RefFirstloop
	DO	#N*N,firstloop
; what until a word is ready
get_first
	jclr	#0,X:HSR,get_first
	movep	X:HRX,X0
	move	X0,X:(R0)+
firstloop	

; read in the B array from the host port
	move	#bbuffer,R0
RefSecondLoop
	DO	#N*N,secondloop
get_second
	jclr	#0,X:HSR,get_second	; if no data jump to the top
	movep	X:HRX,X0
	move	X0,Y:(R0)+
secondloop	

; do sums here
	move	#bbuffer,R5
	move	#N,N0	
	move	#N,N5
Refiloop
	do	#N,iloop
	move	#abuffer,R1	
Refjloop
	do	#N,jloop
	move	R5,R4
	clr	a		 R1,R0	
Refkloop
	do	#N,kloop
	move	X:(R0)+N0,X0	Y:(R4)+,Y0
	mac	x0,y0,A
kloop
	move	(R1)+
; Now send A	- first A2 then A1	
pxmit	jclr	#1,X:HSR,pxmit

	movep	A2,X:HRX
pxmit2	jclr	#1,X:HSR,pxmit2

	movep	A1,X:HRX
jloop
	lua	(R5)+N5,R5
iloop
	rti
				; Get command from host port

FixTable
	dc	firstloop-1,RefFirstloop+1
	dc	get_first,get_first+1
	dc	secondloop-1,RefSecondloop+1
	dc	get_second,get_second+1
	dc	iloop-1,Refiloop+1
	dc	jloop-1,Refjloop+1
	dc	kloop-1,Refkloop+1
	dc	pxmit,pxmit+1
	dc	pxmit2,pxmit2+1
FixEnd		
	end
