	lea	buffer,a0
	move.l	#815104/4,d0
fill	move.l	#"POV!",(a0)+
	sub.l	#1,d0
	bne.s	fill

	move.w	#2,-(sp)
	pea	filename
	move.w	#$3c,-(sp)
	trap	#1
	add.w	#8,sp
	move.w	d0,d7
	pea	buffer
	move.l	#815104,-(sp)
	move.w	d7,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp

	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	add.w	#4,sp
	clr.w	-(sp)
	trap	#1


filename	dc.b	"a:\POVERTY.ste",0
	even
buffer	dc.w	0
