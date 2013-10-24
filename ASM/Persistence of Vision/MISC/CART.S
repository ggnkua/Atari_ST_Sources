*--------------- check for cartridges
		cmp.l	#$fa52235f,$fa0000	; diagnostix cart (multiface)
		beq.s	a_cart
		cmp.l	#$abcdef42,$fa0000	; user cart
		beq.s	a_cart
		bra.s	no_cart
a_cart						; cart connected
		move	#1,cart_flag		; so set flag!
no_cart
