	text
	
	pea hello(pc)
	move #9,-(sp)
	trap #1
	addq.l #6,sp
	
;	move.l #$20002,-(sp)
;	trap #13
;	addq.l #4,sp
	
	clr -(sp)
	trap #1

	data	
	
hello:	dc.b 27,"EHello World !",0

	end