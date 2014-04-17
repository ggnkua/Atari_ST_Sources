*************************************
* SECOND PROTECTION FOR MY DEMO !!! *
*************************************
	*OPT	X+
	lea	Åber(pc),a0
	lea	$60000,a1
	move.w	#2779,d7
Åberx	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d7,Åberx

	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.w	#6,a7
	lea	$140.w,a0
	lea	PROGRAM(pc),a1
	moveq	#10,d7
Zab	rept	6
	move.l	(a1)+,(a0)+
	endr
	dbf	d7,Zab
Lajt	move.l	a0,a0
	move.l	a1,a1
	move.l	a2,a2
	move.l	a3,a3
	move.l	a4,a4
	move.l	a5,a5
	move.l	a6,a6
	move.l	a7,a7
	dbf	d7,Lajt
	jmp	$140.w
PROGRAM
	move.b	#2,$ffff8260.w
	moveq	#0,d0
	move.l	d0,$fffffa06.w
	move.l	d0,$fffffa12.w
L152	clr.l	$400.w
	clr.l	$426.w
	clr.b	$42a.w
	move.b	#$12,$fffffc02.w
	move.b	#$13,$fffffc02.w
	clr.b	$ffff8260.w
	move.l	$462.w,d0
	addq.w	#3,d0
Syncuj	cmp.l	$462.w,d0
	bne.s	Syncuj
	move.w	#$2300,sr
	move.b	#2,$ffff820a.w
	move.l	$466.w,d0
	addq.w	#3,d0
Syncuj2	cmp.l	$466.w,d0
	bne.s	Syncuj2
	lea	$60000,a0
	move.w	#2779,d7
	lea	$ffff8209.w,a1
Ntw	move.b	(a1),d0
	beq.s	Ntw
	not.w	d0
	lsl.w	d0,d0
L196	clr.l	$26.w
	move.w	$1a6.w,d0
	move.b	(a1),d1
	add.b	(a1),d1
	add.b	(a1)+,d1
	add.w	d1,d1
	lsl.w	#2,d1
	moveq	#$10,d2
	add.w	$7e1c(a1),d1
	exg	d2,a1
	add.w	d0,d1
	move.l	(a1),$234.w
	move.l	#$232,(a1)
	move.w	sr,d0
	or.b	-$607(a1),d0
	add.w	d1,d0
	move.w	d0,d2
	abcd	d1,d2
	ror.w	#8,d2
	sbcd	d1,d2
	muls	d2,d2
	swap	d0
	move.w	d2,d0
	and.w	#$ab0f,sr
Zakod
	move.l	(a0),d2
	eor.l	d0,d2
	move.l	d2,(a0)+
	add.l	$16(a1),d1
	move.w	sr,d3
	swap	d3
	move.w	sr,d3
	add.l	d3,d1
	move.l	(a0),d2
	eor.l	d1,d2
	move.l	d2,(a0)+
	move.b	d1,-$7e06(a1)
	dbf	d7,Zakod
	move.b	#2,-$7e06(a1)
	stop	#$2300
loop	nop
	bra.s	loop
	dc.l	$01234567,$89abcdef
	dc.l	$01234567,$89abcdef
	dc.l	$01234567,$89abcdef
	dc.l	$01234567,$89abcdef
Vbel	add.l	#$BE0DEAD,$400.w
	rte


Åber	lea	File(pc),a0
	bsr	ice_decrunch_2
Reloc_s
	lea	File(pc),a0 ;L23C86
	lea	28(a0),a1   ;L23CA2
	add.l	2(a0),a1
	lea	(File+28)(pc),a0
	move.l	a0,d0
	add.l	(a1)+,a0
	moveq	#0,d1
K__6E	add.l	d0,(a0)
K__70	move.b	(a1)+,d1
	beq.s	Reloc_e
	cmp.b	#1,d1
	bne.s	K__80
	add.w	#$FE,A0
	bra.s	K__70
K__80	add.l	D1,A0
	moveq	#0,d1
	bra.s	K__6E
Reloc_e
	jmp	(File+28)(pc)

ice_decrunch_2:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4
	move.l	a4,a6
	bsr	.getinfo
	cmpi.l	#'a\AK',d0
	bne	.not_packed
	bsr.s	.getinfo
	lea.l	-8(a0,d0.l),a5
	bsr.s	.getinfo
	move.l	d0,(sp)
	adda.l	d0,a6
	move.l	a6,a1

	moveq	#119,d0
.save:	move.b	-(a1),-(a3)
	dbf	d0,.save
	move.l	a6,a3
	move.b	-(a5),d7
	bsr.s	.normal_bytes
	move.l	a3,a5


	bsr	.get_1_bit
	bcc.s	.no_picture
	move.w	#$0f9f,d7
	bsr	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0
	bsr	.get_d0_bits
	move.w	d1,d7
.ice_00:	moveq	#3,d6
.ice_01:	move.w	-(a3),d4
	moveq	#3,d5
.ice_02:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.w	d0-d3,(a3)
	dbra	d7,.ice_00
.no_picture
	movem.l	(sp),d0-a3

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0
.rest	move.b	-(a3),-(a5)
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

.getinfo: moveq	#3,d1
.getbytes: lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.l	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more: add.l	20(a1),d1
.copy_direkt:	
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end:	
	cmpa.l	a4,a6
	bgt.s	.strings
	rts	

.get_1_bit:
	add.b	d7,d7
	bne.s	.bitfound
	move.b	-(a5),d7
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1
.hole_bit_loop:	
	add.b	d7,d7
	bne.s	.on_d0
	move.b	-(a5),d7
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1
	dbf	d0,.hole_bit_loop
	rts	


.strings: lea.l	.length_tab(pc),a1
	moveq.l	#3,d2
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.no_Åber
.get_Åber:
	bsr.s	.get_d0_bits
.no_Åber:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.get_offset_2


	lea.l	.more_offset(pc),a1
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.get_d0_bits
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.depack_bytes
	sub.w	d4,d1
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1
	moveq.l	#5,d0
	moveq.l	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.less_40
	moveq.l	#8,d0
	moveq.l	#$3f,d2
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1

.depack_bytes:
	lea.l	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.dep_b:	move.b	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1

.length_tab:
	dc.b 9,1,0,-1,-1
	dc.b 8,4,2,1,0

.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset
ende_ice_decrunch_2:
	even
;************************************************** end of unpacking routine
File	incbin	\quast_6d.ice
	ds.l	1000
