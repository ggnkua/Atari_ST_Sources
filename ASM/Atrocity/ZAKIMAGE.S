
	pea	0.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	pea	image
	
	clr	-(sp)
	trap	#1
	
	section data
	
image	incbin	d:\divers\images\atrocity.tpi
	end
	