;
;  test scoping of order-of-definition
;
	dc.l	three,two,one

one::	dc.l	two
two::	dc.l	three
three:	dc.l	one
four:	dc.l	four

	.extern	foo
	dc.l	foo
	.comm	bar,42
