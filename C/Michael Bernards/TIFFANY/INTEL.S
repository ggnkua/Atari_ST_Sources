		.export intel,lintel,add_hilo
		.import	itl

intel:	tst.w	itl
		beq.b	i_exit
		ror.w	#8,d0
i_exit:	rts
lintel:	tst.w	itl
		beq.b	l_exit
		ror.w	#8,d0
		swap	d0
		ror.w	#8,d0
l_exit:	rts
add_hilo:
		move.w	d0,d1
		swap	d0
		add.w	d1,d0
		rts
