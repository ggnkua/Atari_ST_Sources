;
;	From NEXT dsp book page 7-4, take input, shift right, send it out
;

PBC	equ	$ffe0
HSR	equ	$ffe9
HTX	equ	$ffeb

	org	p:$0
	jmp	start

	org	P:$2000

start	movep	#1,X:PBC		; configure for host port
	jclr	#0,X:HSR,start		; wait for data from host
	move	X:HTX,A1
	lsr	A			; right-shift one place
;
;	Stick in a delay loop to make host process more sane
;
	do	#5,delay2
	do	#4090,delay1
	lsl	b
	nop
	nop
	nop
delay1
	nop
delay2

xmit	jclr	#1,X:HSR,xmit
	move	A1,X:HTX
	jmp	start
	end
