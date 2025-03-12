	nolist

PBC	equ	$FFE0
HSR	equ	$FFE9
HTX	equ	$FFEB


	org		p:00
	jmp		Init

	org		x:16

red	dc		100
grn	dc		150
blu	dc		200
one	dc		1
ten	dc		10

	org		y:16

matrix:
	dc		0.299,0.587,0.114
	dc		-.147,-.289,0.437
	dc		0.615,-.515,-.100
	
red_coeff	=	546
grn_coeff	=	504
blu_coeff	=	772
	
imatrix:
	dc		0.14,((1<<31)-1)/red_coeff
	dc		-0.394,-0.581,249,((1<<31)-1)/grn_coeff
	dc		0.028,((1<<31)-1)/blu_coeff

	org		p:64

Init:	bclr		#2,omr
	movep		#1,x:PBC			; enable HOST	
	
Convert:
	move		#matrix,r7
	move		#imatrix,r6
	move		#red,r0
	move		#grn,r1
	move		#blu,r2
	move		#one,r3
	move		#ten,r4

_code	jclr		#0,x:<<HSR,_code
	movep		x:<<HTX,a
	tst		a
	jeq		YUV_RGB

RGB_YUV:

_red	jclr		#0,x:<<HSR,_red
	movep		x:<<HTX,x:(r0)
_grn	jclr		#0,x:<<HSR,_grn
	movep		x:<<HTX,x:(r1)
_blu	jclr		#0,x:<<HSR,_blu
	movep		x:<<HTX,x:(r2)
	move				x:(r0),x0	y:(r7)+,y0
	mpy		x0,y0,a	x:(r1),x0	y:(r7)+,y0
	mac		x0,y0,a	x:(r2),x0	y:(r7)+,y0
	macr		x0,y0,a	x:(r0),x0	y:(r7)+,y0
_Y	jclr		#1,x:<<HSR,_Y
	movep		a,x:<<HTX
	mpy		x0,y0,a	x:(r1),x0	y:(r7)+,y0
	mac		x0,y0,a	x:(r2),x0	y:(r7)+,y0
	macr		x0,y0,a	x:(r0),x0	y:(r7)+,y0
_U	jclr		#1,x:<<HSR,_U
	movep		a,x:<<HTX
	mpy		x0,y0,a	x:(r1),x0	y:(r7)+,y0
	mac		x0,y0,a	x:(r2),x0	y:(r7)+,y0
	macr		x0,y0,a
_V	jclr		#1,x:<<HSR,_V
	movep		a,x:<<HTX
	jmp		Convert

YUV_RGB:

_Y	jclr		#0,x:<<HSR,_Y
	movep		x:<<HTX,b
_U	jclr		#0,x:<<HSR,_U
	movep		x:<<HTX,x:(r1)
_V	jclr		#0,x:<<HSR,_V
	movep		x:<<HTX,x:(r2)
	move		b,a
	move				x:(r2),x0	y:(r6)+,y0
	mac		x0,y0,a			y:(r6)+,y0
	add		x0,a
	move		a,x0
	mpy		x0,y0,a	x:(r1),x0	y:(r6)+,y0
_R	jclr		#1,x:<<HSR,_R
	movep		a,x:<<HTX
	move		b,a
	mac		x0,y0,a	x:(r2),x0	y:(r6)+,y0
	mac		x0,y0,a			y:(r6)+,y0
	add		y0,a				y:(r6)+,y0
	move		a,x0
	mpy		x0,y0,a	x:(r1),x0	y:(r6)+,y0
_G	jclr		#1,x:<<HSR,_G
	movep		a,x:<<HTX
	move		b,a
	add		x0,a
	add		x0,a
	mac		x0,y0,a			y:(r6)+,y0
	move		a,x0
	mpy		x0,y0,a
_B	jclr		#1,x:<<HSR,_B
	movep		a,x:<<HTX
	jmp		Convert

