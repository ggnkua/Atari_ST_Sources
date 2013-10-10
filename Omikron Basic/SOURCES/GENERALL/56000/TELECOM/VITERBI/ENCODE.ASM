
;This is a convolutional encoder for the V.32 which takes
;it's input from a file and and tests the output for all
;states as well as well as inputs. 
locate	equ 	$ee
statemem	equ	60
output	equ	50
input	equ	40
start	equ	$40
	org	p:start
	move 	#statemem,r3
	do	#104,code
	move 	#input+3,r2
	move	#locate,r6
	move	#output,r5
	move 	y:(r6),a
	move	#>$1,x0
	do	#4,loop
	and	x0,a	a,x1
	move	a1,x:(r2)-
	move	x1,a
	asr  	a
loop
	jsr	encode
	move	#locate+1,r6
	move	#input,r2
	clr	b
	clr	a	y:(r4),b0
	addl	b,a
	do	#4,loop2
	move	x:(r2)+,b0
	addl	b,a
loop2
	move	a0,y:(r6)
code
encode
	move	#input,r0
	move	#output,r4
	move	#statemem,r1
	move	x:(r0)+,x1
	move	x:(r1)+,a
	move	a,y:(r4)
	and	x1,a	x:(r0),x0
	move	x:(r1)-,b
	eor	x0,b	a,y0
	eor	y0,b	b,y1 
	move 	b,x:(r1)+	y:(r4),b
	and	y1,b	x0,a
	move	(r1)+
	eor	x1,a	x:(r1),x0
	eor	x0,a	y:(r4),y1
	move   	b,y0
	eor	y0,a	y1,x:(r1)-
	move	a,x:(r1)+
	rts
	end




	

