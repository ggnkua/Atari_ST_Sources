* Degas Elite unpack source.
* By Niclas Pennskog (Jason/Unit #17)
* 02-02-91
*
* The palette is at offset 2...
*

unpack_degas
	add.l	#2+32,a0		* a0=picture
	lea	32000(a1),a2
unp_loop	move.b	(a0)+,d0		* a1=vram
	bpl.s	positive
not_127	cmp.b	#-128,d0
	beq.s	unp_loop
	neg	d0
	ext	d0
	move.b	(a0)+,d1
p_loop0	move.b	d1,(a1)+
	dbra	d0,p_loop0
	bra.s	check_end
positive	ext	d0
p_loop1	move.b	(a0)+,(a1)+
	dbra	d0,p_loop1
check_end	cmp.l	a2,a1
	bls.s	unp_loop
	rts
