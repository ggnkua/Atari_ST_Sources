;
;	From NEXT dsp book page 7-4, take input, shift right, send it out
;

PBC	equ	$ffe0
HSR	equ	$ffe9
HTX	equ	$ffeb

	org	p:$0
	jmp	load

	org	P:$40
load
	move	#$ffff,m0
	move	#$37f,r0
	move	#$12d45f,y0
	move	y0,y:(r0)

nb_aleat:
;--------
	move	#13017,r2
	move	#$37f,r0
	move	#$4b17f3,x0
	move	y:(r0),x1
	mpy	x0,x1,a
	asr	a
	move	r2,x0
	add	x,a
	
	move	a1,y:(r0)

	move	a0,a1
	move	#0,a0
	move	#0,a2
	jmp	nb_aleat	
