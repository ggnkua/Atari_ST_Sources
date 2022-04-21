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
	jmp 	start
	
	org p:$200
start		
	and	#%11110011,mr
	movep	#1,x:<<PBC
	jsr	receive_coul
encore
	move	#>pa1,r4
	do	#12,_loop
	rec	x:(r4)+
_loop
	ori	#4,OMR	
	move	#$ff,m0
	move	#$ff,m1
	move	#$ff,m2
	move	#$ff,m3
	move	#-1,M4
	move	#128-1,m5
	move	#>coul1,r6	
	move	x:X1_BASE,r0
	move	x:Y1_BASE,r1
	move	x:X2_BASE,r2
	move	x:Y2_BASE,r3
	
	move	x:pa1,n0
	move	x:pa2,n1
	move	x:pa3,n2
	move	x:pa4,n3
	
	move	(r0)+n0
	move	(r1)+n1
	move	(r2)+n2
	move	(r3)+n3
	move	r0,x:X1_BASE
	move	r0,x:X1_LIGNE
	move	r1,x:Y1_BASE
	move	r1,x:Y1_LIGNE
	move	r2,x:X2_BASE
	move	r2,x:X2_LIGNE
	move	r3,x:Y2_BASE
	move	r3,x:Y2_LIGNE
		
again
	do	#120,EN_TOUT		

	move	x:X1_LIGNE,r0
	move	x:Y1_LIGNE,r1
	move	x:X2_LIGNE,r2
	move	x:Y2_LIGNE,r3

	move	x:pa5,n0
	move	x:pa6,n1
	move	x:pa7,n2
	move	x:pa8,n3

	move	(r0)+n0
	move	(r1)+n1
	move	(r2)+n2
	move	(r3)+n3
	move	r0,x:X1_LIGNE
	move	r1,x:Y1_LIGNE
	move	r2,x:X2_LIGNE
	move	r3,x:Y2_LIGNE

	move	x:pa9,n0
	move	x:pa10,n1
	move	x:pa11,n2
	move	x:pa12,n3

	move	#>127,y0
	move	#coul1,r4
	move	y:(r0)+n0,y1
	do	#384/2,EN_X
	mpy	y0,y1,a		y:(r2)+n2,y1
	mpy	y0,y1,b		a,x0	y:(r1)+n1,y1
	mpy	x0,y1,a		b,x0  	y:(r3)+n3,y1
	mpy	x0,y1,b		y:(r0)+n0,y1
	cmp	a,b		#coul2,r5
	tgt	a,b		r4,r5
	abs	b
	move	b,n5
	nop
	env	y:(r5+n5)
EN_X
	nop
EN_TOUT
	movec	#0,omr
	jsr	receive_coul
	jmp	encore


receive_coul
	move	#coul1,r4
	do	#256,_loop
	rec	y:(r4)+
_loop
	rts
	
	
	
	
	org	x:0
X1_BASE		dc	$100
Y1_BASE		dc	$140
X2_BASE		dc	$100
Y2_BASE		dc	$140
X1_LIGNE	dc	0
Y1_LIGNE	dc	0
X2_LIGNE	dc	0
Y2_LIGNE	dc	0
pa1		dc	$ffff
pa2		dc	0
pa3		dc	0
pa4		dc	0
pa5		dc	0
pa6		dc	0
pa7		dc	0
pa8		dc	0
pa9		dc	0
pa10		dc	0
pa11		dc	0
pa12		dc	0
	org	y:$1000
coul1		ds	128
coul2		ds	128

	
	