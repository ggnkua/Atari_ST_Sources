* Play a .TUN file

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,save_sp

	move.l	#1,d0
	jsr	muzak

	move.l	#muzak+16,$4d2

	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7

	move.l	#0,$4d2

	move.l	save_sp,-(a7)
	clr.l	-(a7)
	trap	#1
	addq.l	#6,a7

	clr.w	-(a7)
	trap	#1

save_sp	ds.l	1

muzak	incbin	d:\blipblop.per\new_mdrv.rpl
	incbin	bioload1.tun
	even

	end
