Load_Gpu_Prog
	Lea	G_Ram+Hardware,a1
	Move.w	#$1000,d0
	Lsr.w	#2,d0
	Subq.w	#1,d0
.Loop	Move.l	(a0)+,(a1)+
	Dbra	d0,.Loop
	Rts

Start_Gpu
	Move.l	a0,G_Pc+Hardware
	Move.l	a0,G_Pc+Hardware
	Move.l	#$11,G_Ctrl+Hardware
	Rts
Stop_GPU
	move.l	#$0,G_CTRL+Hardware
	Rts

Wait_For_Gpu
	Move.l	G_Ctrl+Hardware,d0
	And.l	#1,d0
	Bne.s	Wait_For_Gpu
	Rts

;	Nop
;	Nop
