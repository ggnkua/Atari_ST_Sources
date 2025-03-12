	nolist

PBC	equ	$FFE0
HSR	equ	$FFE9
HTX	equ	$FFEB


	org		p:00
	jmp		Init

	org		x:0

rdat	ds		256

red	ds		1
green	ds		1
blue	ds		1

count	ds		1

	org		y:0

gbdat	ds		256*2

	org		p:64

Init:	bclr		#2,omr
	movep		#1,x:PBC			; enable HOST	
	
Load:	move		#>rdat,r0
	move		#>gbdat,r1

_num	jclr		#0,x:<<HSR,_num
	movep		x:<<HTX,a
	do		a,_get
_red	jclr		#0,x:<<HSR,_red
	movep		x:<<HTX,x:(r0)+
_grn	jclr		#0,x:<<HSR,_grn
	movep		x:<<HTX,y:(r1)+
_blu	jclr		#0,x:<<HSR,_blu
	movep		x:<<HTX,y:(r1)+
_get	move		a,x:count

Search:
_red	jclr		#0,x:<<HSR,_red
	movep		x:<<HTX,x:red
_grn	jclr		#0,x:<<HSR,_grn
	movep		x:<<HTX,x:green
_blu	jclr		#0,x:<<HSR,_blu
	movep		x:<<HTX,x:blue

	move		#0,r6
	move		#0,n7
	move		#>$100000,y1
	move		#>rdat,r0
	move		#>gbdat,r1
	move		x:(r0)+,a
	move		x:count,b
	do		b,_Clop
	move		x:red,x0
	sub		x0,a		r6,n6
	move		a,x0		y:(r1)+,a
	mpy		x0,x0,b	x:green,x0	
	sub		x0,a		(r6)+
	move		a,x0		y:(r1)+,a
	mac		x0,x0,b	x:blue,x0	
	sub		x0,a
	move		a,x0
	mac		x0,x0,b	y1,a
	move		b0,b
	cmp		a,b		x:(r0)+,a
	jge		_Skip
	move		b,y1
	move		n6,n7
_Skip	nop
_Clop	clr		a
	move		n7,a
	jclr		#1,x:<<HSR,_Clop
	movep		a,x:<<HTX
	jmp		Search

