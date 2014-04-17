;
;	Block move of DSP memory to manage subroutine area
;

PBC	equ	$ffe0
BCR	equ	$fffe
HSR	equ	$ffe9
HTX	equ	$ffeb

	org	p:$0
	jmp	start
	org	P:$40
start
	movep 	#1,X:PBC		; Configure for host port
	movep	#0,X:BCR		; 0 wait states

get_command
	jclr	#0,X:HSR,get_command	; if no data jump to the top
	clr	a
	movep	X:HTX,a1		; Get command from host port
	move	#>1,x1
	cmp	x1,a
	jeq	dump_x			; jump to aux a receive routine
	move	#>2,x1
	cmp	x1,a
	jeq	dump_y
	jmp	dump_p

dump_p:
	jclr	#0,X:HSR,dump_p
	movep	X:HTX,r0		; r0 = source location
ploop1:
	jclr	#0,X:HSR,ploop1
	movep	X:HTX,r1		; r1 = count
	do	r1,pendloop1		; Begin block move
	move	P:(r0)+,A1
pxmit	jclr	#1,X:HSR,pxmit
	move	A1,X:HTX
pendloop1
	nop				; Need an instruction before rti???
	jmp	get_command

dump_x:
	jclr	#0,X:HSR,dump_x
	movep	X:HTX,r0		; r0 = source location
xloop1:
	jclr	#0,X:HSR,xloop1
	movep	X:HTX,r1		; r1 = count
	do	r1,xendloop1		; Begin block move
	move	X:(r0)+,A1
xxmit	jclr	#1,X:HSR,xxmit
	move	A1,X:HTX
xendloop1
	nop				; Need an instruction before rti???
	jmp	get_command

dump_y:
	jclr	#0,X:HSR,dump_y
	movep	X:HTX,r0		; r0 = source location
yloop1:
	jclr	#0,X:HSR,yloop1
	movep	X:HTX,r1		; r1 = count
	do	r1,yendloop1		; Begin block move
	move	Y:(r0)+,A1
yxmit	jclr	#1,X:HSR,yxmit
	move	A1,X:HTX
yendloop1
	nop				; Need an instruction before rti???
	jmp	get_command

	end
