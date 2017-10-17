	text
	;Convcer ASCII char passsed in D1....
charto_upperc:	cmp.b	#97,d1
		blo.s	.no_conv
		cmp.b	#122,d1
		bhi.s	.no_conv
		sub.b	#32,d1
.no_conv:	rts

charto_lowerc:	cmp.b	#65,d1
		blo.s	.no_conv
		cmp.b	#90,d1
		bhi.s	.no_conv
		add.b	#32,d1
.no_conv:	rts

	