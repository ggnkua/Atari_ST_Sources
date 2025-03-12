****************************************************************
* ST downloader test program.


	include	"transmit.s"


	org	$20000

Code_Start
Exec_Addr
	lea	Stack(pc),sp
.Loop
	move.w	#$000,$ffff8240.w
	move.w	#$100,$ffff8240.w
	move.w	#$200,$ffff8240.w
	move.w	#$300,$ffff8240.w
	move.w	#$400,$ffff8240.w
	move.w	#$500,$ffff8240.w
	move.w	#$600,$ffff8240.w
	move.w	#$700,$ffff8240.w
	move.w	#$740,$ffff8240.w
	trap	#0
	move.w	#$700,$ffff8240.w
	move.w	#$600,$ffff8240.w
	move.w	#$500,$ffff8240.w
	move.w	#$400,$ffff8240.w
	move.w	#$300,$ffff8240.w
	move.w	#$200,$ffff8240.w
	move.w	#$100,$ffff8240.w
	move.w	#$000,$ffff8240.w
	trap	#0
	nop
	bra.s	.Loop

	ds.l	10
Stack


Code_End
Code_Length	equ	Code_End-Code_Start



	end
