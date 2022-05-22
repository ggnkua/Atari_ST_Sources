		moveq	#32,d1
		lea	test(pc),a6
		bfextu	(a6){8:d1},d0
		


test		dc.b	"griff woz ere"