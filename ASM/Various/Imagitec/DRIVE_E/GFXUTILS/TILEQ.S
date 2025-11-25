
Start	Lea	T+$13A2,a0
	Lea	Dest1,a1
	Move.w	#47,d0
.Loop0	Move.w	#47,d1
	Move.w	#$8000,d6
.Loop1	Move.b	(a0)+,d2
	Moveq	#3,d7
.Loop2	Lsr.b	#1,d2
	Bcc.s	.Skip
	Or.w	d6,(a1)
.Skip	Addq.l	#2,a1
	Dbra	d7,.Loop2
	Subq.l	#8,a1
	Ror.w	#1,d6
	Bcc.s	.Skip2
	Addq.l	#8,a1
.Skip2	Dbra	d1,.Loop1
	Dbra	d0,.Loop0
	Lea	dest1,a0
	Lea	dest2,a1
	Moveq	#47,d0
.Xloop	
	Rept	3	
	Move.w	#-1,(a1)+
	Move.w	(a0)+,(a1)+
	Move.w	(a0)+,(a1)+
	Move.w	(a0)+,(a1)+
	Move.w	(a0)+,(a1)+
	Endr
	Dbra	d0,.Xloop
	Rts

T	Incbin	A:Temp.spt
Dest1	Ds.b	1152

Dest2	Ds.b	1152+288
