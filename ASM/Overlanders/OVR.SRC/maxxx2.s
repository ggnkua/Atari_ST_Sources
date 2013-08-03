	pea	main
	move	#$26,-(sp)
	trap	#14
	lea	6(sp),sp
	
	clr	-(sp)
	trap	#1
	
main	moveq	#1,d0
	bsr	musix
	
	move.l	#musix+8,$4e2
	move	#7,-(sp)
	trap	#1
	lea	2(sp),sp
	clr.l	$4e2
	move.l	#$8080000,$ffff8800.w
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w
	rts

musix	incbin	\bofdemo\musics\maxxx2.mus
