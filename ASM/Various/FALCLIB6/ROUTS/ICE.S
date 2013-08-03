*
* ICE.S
*
*	@icedecrunch
*
*	Checks if the data is icepacked and possibly unpacks it.
*
* In	a0.l=Data adr.
*


;********************************************* Unpacking routine of PACK-ICE
; a0 = AdTRESs of packed data
; "bsr" or "jsr" to ice_decrunch_2 with register a0 prepared.
@icedecrunch
	link	a3,#-120
	movem.L	d0-a6,-(sp)
	lea	120(a0),a4
	move.L	a4,a6
	bsr	.getinfo
	cmpi.L	#'ICE!',d0
	bne.S	.not_packed
	bsr.s	.getinfo
	lea.L	-8(a0,d0.L),a5
	bsr.s	.getinfo
	move.L	d0,(sp)
	adda.L	d0,a6
	move.L	a6,a1
	moveq	#119,d0
.save	move.B	-(a1),-(a3)
	dbf	d0,.save
	move.L	a6,a3
	move.B	-(a5),d7
	bsr.s	.normal_bytes
	move.L	a3,a5
	bsr	.get_1_bit
	bcc.s	.no_picture
	move.W	#$0f9f,d7
	bsr	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0
	bsr	.get_d0_bits
	move.W	d1,d7
.ice_00	moveq	#3,d6
.ice_01	move.W	-(a3),d4
	moveq	#3,d5
.ice_02	add.W	d4,d4
	addx.W	d0,d0
	add.W	d4,d4
	addx.W	d1,d1
	add.W	d4,d4
	addx.W	d2,d2
	add.W	d4,d4
	addx.W	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.W	d0-d3,(a3)
	dbra	d7,.ice_00
.no_picture
	movem.L	(sp),d0-a3

.move	move.B	(a4)+,(a0)+
	subq.L	#1,d0
	bne.s	.move
	moveq	#119,d0
.TRESt	move.B	-(a3),-(a5)
	dbf	d0,.TRESt
.not_packed	movem.L	(sp)+,d0-a6
	unlk	a3
	rts
.getinfo	moveq	#3,d1
.getbytes	lsl.L	#8,d0
	move.B	(a0)+,d0
	dbf	d1,.getbytes
	rts
.normal_bytes	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.L	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.L	.direkt_tab+20(pc),a1
	moveq.L	#4,d3
.nextgb	move.L	-(a1),d0
	bsr.s	.get_d0_bits
	swap.W	d0
	cmp.W	d0,d1
	dbne	d3,.nextgb
.no_more add.L	20(a1),d1
.copy_direkt	move.B	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end	cmpa.L	a4,a6
	bgt.s	.strings
	rts	
.get_1_bit	add.B	d7,d7
	bne.s	.Bitfound
	move.B	-(a5),d7
	addx.B	d7,d7
.Bitfound	rts	
.get_d0_bits	
	moveq.L	#0,d1
.hole_bit_loop	
	add.B	d7,d7
	bne.s	.on_d0
	move.B	-(a5),d7
	addx.B	d7,d7
.on_d0	addx.W	d1,d1
	dbf	d0,.hole_bit_loop
	rts	
.strings	lea.L	.Length_tab(pc),a1
	moveq.L	#3,d2
.get_length_bit	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit	
	moveq.L	#0,d4
	moveq.L	#0,d1
	move.B	1(a1,d2.W),d0
	ext.W	d0
	bmi.s	.no_Åber
.get_Åber	bsr.s	.get_d0_bits
.no_Åber	move.B	6(a1,d2.W),d4
	add.W	d1,d4
	beq.s	.get_offset_2
	lea.L	.more_offset(pc),a1
	moveq.L	#1,d2
.getoffs	bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.L	#0,d1
	move.B	1(a1,d2.W),d0
	ext.W	d0
	bsr.s	.get_d0_bits
	add.W	d2,d2
	add.W	6(a1,d2.W),d1
	bpl.s	.depack_bytes
	sub.W	d4,d1
	bra.s	.depack_bytes
.get_offset_2	
	moveq.L	#0,d1
	moveq.L	#5,d0
	moveq.L	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.Less_40
	moveq.L	#8,d0
	moveq.L	#$3f,d2
.Less_40 bsr.s	.get_d0_bits
	add.W	d2,d1
.depack_bytes
	lea.L	2(a6,d4.W),a1
	adda.W	d1,a1
	move.B	-(a1),-(a6)
.dep_b	move.B	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes
.direkt_tab	dc.L	$7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.L     270-1,	15-1,	 8-1,	 5-1,	 2-1
.Length_tab	dc.B	9,1,0,-1,-1
	dc.B	8,4,2,1,0
.more_offset	dc.B	  11,   4,   7,  0	; Bits lesen
	dc.W	$11f,  -1, $1f	; Standard Offset
ende_ice_decrunch_2
