	output	.ro

	text
mediach:
	move.w	#$47e,a1
	move.l	(a1),save_mediach
	lea	my_mediach(pc),a0
	move.l	a0,(a1)
	rts

my_mediach:
	move.l	save_mediach(pc),$47e.w
	moveq	#2,d0
	rts

	bss
save_mediach:
	ds.l	1
	end
