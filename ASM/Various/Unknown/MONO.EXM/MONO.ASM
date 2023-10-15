	org	x:$0020
in_l	dc	$000001			; reserve space for sample data
in_r	dc	$000001
out_l	dc	$000001
out_r	dc	$000001
temp1	dc	$000001
temp2	dc	$000001
inflag	dc	$000001
outflag	dc	$000001

	org	p:$0000			; for start up...
	jmp	start

	org	p:$000C			; put routines in vectors
	jsr	<datain
	nop
	org	p:$0010
	jsr	<dataout
	nop

	org	p:$0200
start
	movep	x:$ffeb,x0		; set up the SSI interface
	movec	#0,sp
	movep	#$4100,x:$ffec
	movep	#$1f8,x:$ffe1
	btst	#4,x:$ffee
	movep	#$f800,x:$ffed
	movep	#0,x:$fffe
	movep	#$3000,x:$ffff

	andi	#$fc,mr			; set I/O interupts

; Put your routine here (with a loop)
; input data can be found at x:<in_l and x:<in_r
; data should be output to x:<out_l and x:<out_r

	move	x:<in_r,x0
	move	x:<in_l,x1
	move	x0,a			; (very) simple MONO - OUT = L+R
	add	x1,a
	move	a,x1
	move	x1,x:<out_l
	move	x1,x:<out_r
	jmp	start

datain	move	x0,x:<temp1		; transfer from SSI
	move	x1,x:<temp2
	jclr	#0,x:<inflag,do_leftin
do_rightin	movep	x:$ffef,x1	; do the right channel
	move	x1,x:<in_r
	bclr	#0,x:<inflag
	move	x:<temp1,x0
	move	x:<temp2,x1
	rti

do_leftin	movep	x:$ffef,x0	; or do the left
	move	x0,x:<in_l
	bset	#0,x:<inflag
	move	x:<temp1,x0
	move	x:<temp2,x1
	rti


dataout	move	x0,x:<temp1		; transfer to the SSI
	move	x1,x:<temp2
	jclr	#0,x:<outflag,do_leftout
do_rightout	move	x:<out_r,x1	; do the right channel
	movep	x1,x:$ffef
	bclr	#0,x:<outflag
	move	x:<temp1,x0
	move	x:<temp2,x1
	rti

do_leftout	move	x:<out_l,x0	; or the left
	movep	x0,x:$ffef
	bset	#0,x:<outflag
	move	x:<temp1,x0
	move	x:<temp2,x1
	rti
