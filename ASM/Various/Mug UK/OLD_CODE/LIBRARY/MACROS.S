;
; Macro Test Program
;
; by Mike Mee

	opt	o-	
	
	bra	start
	include "d:\programs.b_b\library\routines.s"
	even

start	super
	st_pal
	new_pal	proggy
	getrez
	mode	0
	cls
	ink	7
	print	intro
	print	normal
	move.w	#$2700,sr		;interrupts off
	for	#52000
	bsr	colours
	bsr	colours
	next
	move.w	#$2300,sr		;restore interrupts
*	getkey	
	mode	1
exit	rs_pal
	user
	clr.w	-(sp)
	trap	#1

colours	border	$100
	border	$200
	border	$300
	border	$400
	border	$500
	border	$600
	border	$700
	border	$777
	border	$700
	border	$600
	border	$500
	border	$400
	border	$300
	border	$200
	border	$100
	border	$000
	rts

intro	dc.b	"Well hello there fans - How are you !!!",13,10,13,10,0

normal	dc.b	"Press any key to exit",0

proggy	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$100,$200,$300,$400,$500,$600,$700,$777

