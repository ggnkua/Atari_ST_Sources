	section	text
	move.l	4(sp),a6
	lea	mystack,sp
	move.l	$c(a6),d0
	add.l	$14(a6),d0
	add.l	$1c(a6),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a6,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bne	end

	pea	install(pc)
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	bsr	main

end	clr.w	-(sp)
	trap	#1

install	pea	Trap0(pc)
	move.l	(sp)+,$80.w
	rts

main	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,rez
	move.w	#0,-(sp)
	pea	-1.w
	pea	-1.w
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,-(sp)
	pea	neo
	move.w	#1,-(sp)
	move.w	#4,-(sp)
	trap	#0
	lea	12(sp),sp

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	clr.w	-(sp)
	move.w	#4,-(sp)
	trap	#0
	addq.l	#4,sp

	move.w	rez,-(sp)
	pea	-1.w
	pea	-1.w
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	rts

Trap0	include	\display.neo\neo.s

	section	data
rez	dc.w	0
neo	incbin	\display.neo\glouglou.iff

	section	bss
	ds.l	$400
mystack
