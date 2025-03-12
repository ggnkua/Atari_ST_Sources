	.text
	.globl	_c2p
	/* in	a0	chunky
		a1	screen */

_c2p:
	movel	8(sp),c2p_source
	movel	4(sp),c2p_destination
	
	moveml	d0-d7/a0-a6,sp@-
	movel	c2p_source,a0
	movel	c2p_destination,a1



/*	movel	#63000,d0
loop:	moveb	(a0)+,(a1)+
	dbra	d0,loop
	
	moveml	sp@+,d0-d7/a0-a6

	rts*/
	
	
	
	
	move.l	a0,a2
	addl	#64000,a2
	movel	#0x0f0f0f0f,d4
	movel	#0x00ff00ff,d5
	movel	#0x55555555,d6

	movel	(a0)+,d0
	movel	(a0)+,d1
	movel	(a0)+,d2
	movel	(a0)+,d3

	/* a7a6a5a4a3a2a1a0 b7b6b5b4b3b2b1b0 c7c6c5c4c3c2c1c0 d7d6d5d4d3d2d1d0
	   e7e6e5e4e3e2e1e0 f7f6f5f4f3f2f1f0 g7g6g5g4g3g2g1g0 h7h6h5h4h3h2h1h0
	   i7i6i5i4i3i2i1i0 j7j6j5j4j3j2j1j0 k7k6k5k4k3k2k1k0 l7l6l5l4l3l2l1l0
	   m7m6m5m4m3m2m1m0 n7n6n5n4n3n2n1n0 o7o6o5o4o3o2o1o0 p7p6p5p4p3p2p1p0
	*/

	movel	d1,d7
	lsrl	#4,d7
	eorl	d0,d7
	andl	d4,d7
	eorl	d7,d0
	lsll	#4,d7
	eorl	d7,d1
	movel	d3,d7
	lsrl	#4,d7
	eorl	d2,d7
	andl	d4,d7
	eorl	d7,d2
	lsll	#4,d7
	eorl	d7,d3

	/* a7a6a5a4e7e6e5e4 b7b6b5b4f7f6f5f4 c7c6c5c4g7g6g5g4 d7d6d5d4h7h6h5h4
	   a3a2a1a0e3e2e1e0 b3b2b1b0f3f2f1f0 c3c2c1c0g3g2g1g0 d3d2d1d0h3h2h1h0
	   i7i6i5i4m7m6m5m4 j7j6j5j4n7n6n5n4 k7k6k5k4o7o6o5o4 l7l6l5l4p7p6p5p4
	   i3i2i1i0m3m2m1m0 j3j2j1j0n3n2n1n0 k3k2k1k0o3o2o1o0 l3l2l1l0p3p2p1p0
	*/


	movel	d2,d7
	lsrl	#8,d7
	eorl	d0,d7
	andl	d5,d7
	eorl	d7,d0
	lsll	#8,d7
	eorl	d7,d2
	movel	d3,d7
	lsrl	#8,d7
	eorl	d1,d7
	andl	d5,d7
	eorl	d7,d1
	lsll	#8,d7
	eorl	d7,d3
	
	/* a7a6a5a4e7e6e5e4 i7i6i5i4m7m6m5m4 c7c6c5c4g7g6g5g4 k7k6k5k4o7o6o5o4
	   a3a2a1a0e3e2e1e0 i3i2i1i0m3m2m1m0 c3c2c1c0g3g2g1g0 k3k2k1k0o3o2o1o0
	   b7b6b5b4f7f6f5f4 j7j6j5j4n7n6n5n4 d7d6d5d4h7h6h5h4 l7l6l5l4p7p6p5p4
	   b3b2b1b0f3f2f1f0 j3j2j1j0n3n2n1n0 d3d2d1d0h3h2h1h0 l3l2l1l0p3p2p1p0
	*/


	bras	start
pix16:	
	movel	(a0)+,d0
	movel	(a0)+,d1
	movel	(a0)+,d2
	movel	(a0)+,d3

	/* a7a6a5a4a3a2a1a0 b7b6b5b4b3b2b1b0 c7c6c5c4c3c2c1c0 d7d6d5d4d3d2d1d0
	   e7e6e5e4e3e2e1e0 f7f6f5f4f3f2f1f0 g7g6g5g4g3g2g1g0 h7h6h5h4h3h2h1h0
	   i7i6i5i4i3i2i1i0 j7j6j5j4j3j2j1j0 k7k6k5k4k3k2k1k0 l7l6l5l4l3l2l1l0
	   m7m6m5m4m3m2m1m0 n7n6n5n4n3n2n1n0 o7o6o5o4o3o2o1o0 p7p6p5p4p3p2p1p0
	*/


	movel	d1,d7
	lsrl	#4,d7
	movel	a3,(a1)+
	eorl	d0,d7
	andl	d4,d7
	eorl	d7,d0
	lsll	#4,d7
	eorl	d7,d1
	movel	d3,d7
	lsrl	#4,d7
	eorl	d2,d7
	andl	d4,d7
	eorl	d7,d2
	movel	a4,(a1)+
	lsll	#4,d7
	eorl	d7,d3

	/* a7a6a5a4e7e6e5e4 b7b6b5b4f7f6f5f4 c7c6c5c4g7g6g5g4 d7d6d5d4h7h6h5h4
	   a3a2a1a0e3e2e1e0 b3b2b1b0f3f2f1f0 c3c2c1c0g3g2g1g0 d3d2d1d0h3h2h1h0
	   i7i6i5i4m7m6m5m4 j7j6j5j4n7n6n5n4 k7k6k5k4o7o6o5o4 l7l6l5l4p7p6p5p4
	   i3i2i1i0m3m2m1m0 j3j2j1j0n3n2n1n0 k3k2k1k0o3o2o1o0 l3l2l1l0p3p2p1p0
	*/


	movel	d2,d7
	lsrl	#8,d7
	eorl	d0,d7
	andl	d5,d7
	eorl	d7,d0
	movel	a5,(a1)+
	lsll	#8,d7
	eorl	d7,d2
	movel	d3,d7
	lsrl	#8,d7
	eorl	d1,d7
	andl	d5,d7
	eorl	d7,d1
	movel	a6,(a1)+
	lsll	#8,d7
	eorl	d7,d3
	
	/* a7a6a5a4e7e6e5e4 i7i6i5i4m7m6m5m4 c7c6c5c4g7g6g5g4 k7k6k5k4o7o6o5o4
	   a3a2a1a0e3e2e1e0 i3i2i1i0m3m2m1m0 c3c2c1c0g3g2g1g0 k3k2k1k0o3o2o1o0
	   b7b6b5b4f7f6f5f4 j7j6j5j4n7n6n5n4 d7d6d5d4h7h6h5h4 l7l6l5l4p7p6p5p4
	   b3b2b1b0f3f2f1f0 j3j2j1j0n3n2n1n0 d3d2d1d0h3h2h1h0 l3l2l1l0p3p2p1p0
	*/

start:
	movel	d2,d7
	lsrl	#1,d7
	eorl	d0,d7
	andl	d6,d7
	eorl	d7,d0
	addl	d7,d7
	eorl	d7,d2
	movel	d3,d7
	lsrl	#1,d7
	eorl	d1,d7
	andl	d6,d7
	eorl	d7,d1
	addl	d7,d7
	eorl	d7,d3

	/* a7b7a5b5e7f7e5f5 i7j7i5j5m7n7m5n5 c7d7c5d5g7h7g5h5 k7l7k5l5o7p7o5p5
	   a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1
	   a6b6a4b4e6f6e4f4 i6j6i4j4m6n6m4n4 c6d6c4d4g6h6g4h4 k6l6k4l4o6p6o4p4
	   a2b2a0b0e2f2e0f0 i2j2i0j0m2n2m0n0 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0
	*/

	movew	d2,d7
	movew	d0,d2
	swap	d2
	movew	d2,d0
	movew	d7,d2
	movew	d3,d7
	movew	d1,d3
	swap	d3
	movew	d3,d1
	movew	d7,d3

	/* a7b7a5b5e7f7e5f5 i7j7i5j5m7n7m5n5 a6b6a4b4e6f6e4f4 i6j6i4j4m6n6m4n4
	   a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 a2b2a0b0e2f2e0f0 i2j2i0j0m2n2m0n0
	   c7d7c5d5g7h7g5h5 k7l7k5l5o7p7o5p5 c6d6c4d4g6h6g4h4 k6l6k4l4o6p6o4p4
	   c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0
	*/

	movel	d2,d7
	lsrl	#2,d7
	eorl	d0,d7
	andl	#0x33333333,d7
	eorl	d7,d0
	lsll	#2,d7
	eorl	d7,d2
	movel	d3,d7
	lsrl	#2,d7
	eorl	d1,d7
	andl	#0x33333333,d7
	eorl	d7,d1
	lsll	#2,d7
	eorl	d7,d3

	/* a7b7c7d7e7f7g7h7 i7j7k7l7m7n7o7p7 a6b6c6d6e6f6g6h6 i6j6k6l6m6n6o6p6
	   a3b3c3d3e3f3g3h3 i3j3k3l3m3n3o3p3 a2b2c2d2e2f2g2h2 i2j2k2l2m2n2o2p2
	   a5b5c5d5e5f5g5h5 i5j5k5l5m5n5o5p5 a4b4c4d4e4f4g4h4 i4j4k4l4m4n4o4p4
	   a1b1c1d1e1f1g1h1 i1j1k1l1m1n1o1p1 a0b0c0d0e0f0g0h0 i0j0k0l0m0n0o0p0
	*/
	
	swap	d0
	swap	d1
	swap	d2
	swap	d3

	movel	d0,a6
	movel	d2,a5
	movel	d1,a4
	movel	d3,a3

	cmpl	a0,a2
	bne	pix16

	movel	a3,(a1)+
	movel	a4,(a1)+
	movel	a5,(a1)+
	movel	a6,(a1)+

	moveml	sp@+,d0-d7/a0-a6

	rts

	.data
	.even
	.comm	c2p_source,4
	.comm	c2p_destination,4
