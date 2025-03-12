****************************************************************
* Download test program.


	include	sttx1.s


	org	$80000

Code_Start
Exec_Addr
	move.l	#100000,d0
.Loop
	move.w	#$777,$ffff8240.w
	move.w	#$770,$ffff8240.w
	move.w	#$700,$ffff8240.w
	move.w	#$000,$ffff8240.w
	subq.l	#1,d0
	bne.s	.Loop
	trap	#0



Code_End
Code_Length	equ	Code_End-Code_Start


	end
