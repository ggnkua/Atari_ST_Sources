		globl	get_cookie

get_cookiex:
		movem.l	a0/d0/d4,-(sp)
		move.l	$5a0,d0
		beq.s	no_cookie
		move.l	d0,a0
		move.l	cookie,d0
cookie_loop:
		move.l	(a0),d4
		beq.s 	no_cookie
		cmp.l 	d0,d4
		beq.s 	cookie_found
		addq.l 	#8,a0
		bra.s 	cookie_loop
cookie_found:
		addq.l 	#4,a0
		move.l 	(a0),value		; Cookie-Wert zurÅck
		movem.l	(sp)+,a0/d0/d4
		rts
		
no_cookie:
		clr.l	value
		movem.l	(sp)+,a0/d0/d4
		rts

cookie:	dc.l	0
value:	dc.l	0

get_cookie:
		movem.l	d0-d7/a0-a6,-(sp)
		move.l	D0,cookie
		move.l	#get_cookiex,-(sp)
		move.w	#$26,-(sp)
		trap	#14
		addq.l	#6,sp
		movem.l	(sp)+,d0-d7/a0-a6
		move.l	value,d0
		rts