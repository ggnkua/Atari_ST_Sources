;alternative ste check (check cookie jar)

	move.l	$5a0.w,d0	;cookie jar address
	tst.l	d0		;enpty???
	beq.s	no_cookie_jar
	move.l	d0,a0
get	move.l	(a0),d0		;get cookie id
	cmp.l	#'_SND',d0	;DMA sound?
	beq.s	yes_dma
	addq.l	#8,a0
	tst.l	d0
	bne.s	get

no_cookie_jar
	clr.w	ste_flag
exit
yes_dma	move.w	#-1,ste_flag


ste_flag	ds.w	0
