
	move.l	#stack,sp
	clr.w	-(sp)
	pea	filename
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,d7
	pea	buffer
	move.l	#500000,-(sp)
	move.w	d7,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	move.l	d0,d6
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp

	move.w	#0,-(sp)	
	pea	new_file
	move.w	#$3c,-(sp)
	trap	#1
	add.l	#8,sp
	move.l	d0,d7

	pea	buffer
	move.l	d6,-(sp)
	move.w	d7,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp

	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	
	clr.w	-(sp)
	trap	#1

filename	dc.b	"a:\trav.msg",0
	even
new_file	dc.b	"j:\trav.msg",0
	dc.b	0
	even
	ds.b	500
stack	dc.l	0
buffer	dc.l	0