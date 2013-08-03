	lea font+34,a0
	move.l #($7d00/8)-1,d0
	lea buffer(pc),a1
loop	move.w (a0),(a1)+
	lea 8(a0),a0
	dbra d0,loop
	nop
	nop
	illegal

font	incbin a:\armyfont.pi1

	section bss
buffer	ds.b 8000