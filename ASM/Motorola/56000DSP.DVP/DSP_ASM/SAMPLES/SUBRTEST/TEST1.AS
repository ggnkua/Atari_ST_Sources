;
;	Place $123456 into the output register
;

PBC	equ	$ffe0
HSR	equ	$ffe9
HTX	equ	$ffeb

	org	p:$0
	jmp	start

	org	P:$40

start	movep 	#1,X:PBC
	move	#>2,X0
loop:
	movep	X:HSR,A
	and	X0,A
	jeq	loop
	movep	#$123456,X:HTX
loop1
	jmp	loop1
	end
