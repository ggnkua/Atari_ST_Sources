Start	Lea	S,a0
	Lea	A,a1
	Move.w	#41-1,d7
.Loop	Move.w	#320-1,d6
.Loop1	Move.b	(a0)+,(a1)+
	Dbra	d6,.LOOP1
	Clr.l	(a1)+
	Clr.l	(a1)+
	Clr.l	(a1)+
	Clr.l	(a1)+
	Dbra	d7,.Loop
	RTS


S	Incbin	E:\JUNK\MAIN\Terminal\Panel.Img
E
	
A	Ds.b	41*336
B