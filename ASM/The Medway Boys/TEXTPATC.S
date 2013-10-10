	opt s-
start	lea $80000,sp
	pea text(pc)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	clr.w -(sp)
	trap #1
text	dc.b 27,'E',27,'f'
	dc.b "Fixed for Half-Meg by Absu/Cynix"
	dc.b 0
	