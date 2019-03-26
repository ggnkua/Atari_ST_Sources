	opt	o+,x-,s-,w-
	bra.s	boot_prog
	ds.l	14
boot_prog
	pea	msg(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
msg	dc.b	"Personalise your boot sectors!",10,13,10,13
	dc.b	" The ultimate in program for all",10,13
	dc.b	"budding boffins is here!",0