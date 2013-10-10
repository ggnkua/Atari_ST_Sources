	opt s-
start	lea $80000,sp
	bsr drives
	move.l $70000,$f0.w
	move.l $70004,$f4.w
	move.l $70010,$fc.w
	move.b #$ff,$c8.w
	lea low(pc),a0
	lea $29a.w,a1
.2	move.l (a0)+,(a1)+
	cmp.l #$9816,a1
	bne.s .2
	jmp $96a0
drives	incbin l:\drives
low	incbin l:\robocop.bin

