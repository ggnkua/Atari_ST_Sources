Start	Lea	$200000.L,A7
	Lea	File,a0
	Lea	Filee,a1
	Lea	$4000.w,a2
.Loop	Move.b	(a0)+,(a2)+
	Cmp.l	a0,a1
	Bne.s	.Loop
	Pea	Relocate(pc)
	Move.l	(sp)+,$80.w
	Lea	$4000.w,a1
	Trap	#0
	Illegal

	Include	Relo.s
File
	Incbin	Fred.PRG
Filee
