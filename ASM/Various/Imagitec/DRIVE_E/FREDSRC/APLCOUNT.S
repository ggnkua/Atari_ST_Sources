
Staty	Lea	Map_Data+8(pc),a0
	Lea	Block_Array(pc),a1
.Loop	Cmp.l	#Map_datae,a0
	Beq.s	.Exit
	Move.w	(a0)+,d0
	Ror.w	#8,d0
	Addq.w	#1,(a1,d0*2)
	Bra.s	.Loop
	
.Exit	Lea	Block_Array(pc),a0
	Move.w	#799,d0
	Moveq	#0,d1
.Loop1	Tst.w	(a0)+
	Beq.s	.Dec
	Addq.w	#1,d1
.Dec	Dbra	d0,.Loop1
	Clr.l	-(sp)
	Trap	#1

Map_Data	Incbin	A:Lev1.Map
Map_Datae


Block_Array
	Ds.w	800