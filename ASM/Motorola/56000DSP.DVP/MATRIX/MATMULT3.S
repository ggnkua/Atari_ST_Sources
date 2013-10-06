
;	MATMULT3.S56 Matrix multiplication for the Atari Falcon
;	part of the HiSoft DevpacDSP tutorial.
;	(c) Copyright HiSoft 1993
;  	All rights reserved.
;
HSR	equ	$ffe9
HTX	equ	$ffeb

N	equ 	4

	org	P:$40
start

; first set the modulo registers corresponding to all the
; R registers we are going to use to disable modulo addresssing
	move	#-1,M0
	move	#-1,M1
	move	M0,M4
	move	M0,M5
	move	M0,M6
	move	#bbuffer,R5
	move	#cbuffer,R6
	move	#N,N0	
	move	#N,N5
	do	#N,iloop
	move	#abuffer,R1	
	do	#N,jloop
	move	R5,R4		
	clr	a		R1,R0
	do	#N,kloop
	move	X:(R0)+N0,X0	Y:(R4)+,Y0
	mac	x0,y0,A
kloop
	move	(R1)+
; Now store A in two DSP words
	move	A2,Y:(R6)+		
	move	A1,Y:(R6)+
jloop
	lua	(R5)+N5,R5
iloop

	move	#cbuffer,R6
	DO	#N*N*2,sendloop
	move	Y:(R6)+,Y0
pxmit	jclr	#1,X:HSR,pxmit
	movep	Y0,X:HTX
sendloop	

forever	jmp	forever	;		just hang

	org 	X:$40
abuffer	dc	 .07483626,.184443,.7055502,.1768224 
	dc	 .5215743,.6521941,.4704354,.455802 
	dc	 .8373808,.519858,.09587825,.379077 
	dc	 .371908,.3766014,.202421,.8229417 


	org	Y:$1000
bbuffer
	dc	 .1410046,.1712484,.3422694,.3676988 
	dc	 .807768,.6713575,.7668441,.2701154 
	dc	 .7455041,.7600289,.6523577,.9965845 
	dc	 .9586045,.6935848,.911911,.528457 

; the results
cbuffer	ds	N*N*2
	end
