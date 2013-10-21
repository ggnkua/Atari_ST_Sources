
	globl form_popup
	globl AES_pb
	text
form_popup:
	move.l	AES_pb,a1
	move	#135,(a1)
	move	#2,2(a1)
	move	#1,4(a1)
	move	#1,6(a1)
	move	#0,8(a1)
	move.l	AES_pb+8,a1
	move	d0,(a1)
	move	d1,2(a1)
	move.l	AES_pb+16,a1
	move.l	a0,(a1)
	lea 	AES_pb,a1
	move.l	a1,d1
	move.l	#200,d0
	trap	#2
	move.l	AES_pb+12,a1
	move	(a1),d0
	rts