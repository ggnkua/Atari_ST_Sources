
	lea	amount(pc),a4
	bsr	print



top	bsr	press
	cmp.b	#"1",d0
	bne	two
	move.l	#1000,d1
	bra	put

two	cmp.b	#"2",d0
	bne	three
	move.l	#10000,d1
	bra	put

three	cmp.b	#"3",d0
	bne	four
	move.l	#100000,d1
	bra	put

four	cmp.b	#"4",d0
	bne	five
	move.l	#200000,d1
	bra	put

five	cmp.b	#"5",d0
	bne	top
	move.l	#300000,d1

put	move.l	a6,a5
	add.l	#398992-28,a5
	move.l	d1,(a5)






amount	dc.b	27,"E"
	dc.b	"Choose amount of credits to start the game with",13,10,10,10
	dc.b	"1 - 1000",13,10,10
	dc.b	"2 - 10000",13,10,10
	dc.b	"3 - 100000",13,10,10
	dc.b	"4 - 200000",13,10,10
	dc.b	"5 - 300000",0
	