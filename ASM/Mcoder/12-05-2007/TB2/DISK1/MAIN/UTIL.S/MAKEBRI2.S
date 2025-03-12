
vsync:	macro
	move.l	$466.w,d0
.lo\@:
	cmp.l	$466.w,d0
	beq.s	.lo\@
	endm


	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp


	lea	briques+34,a0
	lea	dest,a1

	move.w	#2,d1
loop2:
	move.w	#15,d0
loop1:
	move.l	(a0),(a1)+
	move.l	4(a0),(a1)+
	lea	160(a0),a0
	dbf	d0,loop1

	lea	-160*16(a0),a0

	lea	8(a0),a0

	dbf	d1,loop2


	illegal

main:
	cmp.b	#$39,$fffffc02.w
	bne.s	main

	clr.w	-(sp)
	trap	#1

	section	data

briques:
	incbin	"pat2.pi1"
	even

	section	bss

dest:
	ds.b	8*16*3
fdest:
	end