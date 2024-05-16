
	; in	a0	chunky
	;	a1	screen

c2p1x1_4_falcon:
	movem.l	d2-d7/a2-a6,-(sp)
	move.l	a0,a2
	add.l	#BPLSIZE*4,a2
	move.l	#$0f0f0f0f,d4
	move.l	#$00ff00ff,d5
	move.l	#$55555555,d6

	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	and.l	d4,d0
	and.l	d4,d2
	and.l	d4,d1
	and.l	d4,d3
	lsl.l	#4,d0
	lsl.l	#4,d1
	or.l	d2,d0
	or.l	d3,d1
	bra.s	.start
.pix16:	
	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	and.l	d4,d0
	and.l	d4,d2
	move.l	a5,(a1)+
	and.l	d4,d1
	and.l	d4,d3
	move.l	a6,(a1)+
	lsl.l	#4,d0
	lsl.l	#4,d1
	or.l	d2,d0
	or.l	d3,d1
.start:
	; a3a2a1a0e3e2e1e0 b3b2b1b0f3f2f1f0 c3c2c1c0g3g2g1g0 d3d2d1d0h3h2h1h0
	; i3i2i1i0m3m2m1m0 j3j2j1j0n3n2n1n0 k3k2k1k0o3o2o1o0 l3l2l1l0p3p2p1p0

	move.l	d1,d7
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d1

	; a3a2a1a0e3e2e1e0 i3i2i1i0m3m2m1m0 c3c2c1c0g3g2g1g0 k3k2k1k0o3o2o1o0
	; b3b2b1b0f3f2f1f0 j3j2j1j0n3n2n1n0 d3d2d1d0h3h2h1h0 l3l2l1l0p3p2p1p0

	move.l	d1,d7
	lsr.l	#1,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	add.l	d7,d7
	eor.l	d7,d1

	; a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1
	; a2b2a0b0e2f2e0f0 i2j2i0j0m2n2m0n0 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0

	move.w	d1,d7
	move.w	d0,d1
	swap	d1
	move.w	d1,d0
	move.w	d7,d1

	; a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 a2b2a0b0e2f2e0f0 i2j2i0j0m2n2m0n0
	; c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0

	move.l	d1,d7
	lsr.l	#2,d7
	eor.l	d0,d7
	and.l	#$33333333,d7
	eor.l	d7,d0
	lsl.l	#2,d7
	eor.l	d7,d1

	; a3b3c3d3e3f3g3h3 i3j3k3l3m3n3o3p3 a2b2c2d2e2f2g2h2 i2j2k2l2m2n2o2p2
	; a1b1c1d1e1f1g1h1 i1j1k1l1m1n1o1p1 a0b0c0d0e0f0g0h0 i0j0k0l0m0n0o0p0

	swap	d0
	swap	d1

	move.l	d1,a5
	move.l	d0,a6

	cmp.l	a0,a2
	bne.s	.pix16

	move.l	a5,(a1)+
	move.l	a6,(a1)+
	
	movem.l	(sp)+,d2-d7/a2-a6
	rts
