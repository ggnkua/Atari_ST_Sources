
l0005

;	move	sr,d0
;	cmpi.w	#$22ff,d0
;	bgt.s	l0006
	bsr	l026d
l0006
	move.b	#6,$484.l
	move.b	$ff8209.l,d0
	andi.b	#7,d0
	move.b	d0,$59815
	movea.l	#$5ee76,a0
	bsr	l028a
	movea.l	#$5ee84,a0
	bsr	l028a
	movea.l	#$5ee92,a0
	bsr	l028a
	bsr	l0234
	bsr	l0245
	bsr	l023a
	clr.w	$58c20
	move.l	#$79680,$58838
	bsr	l0227
l0007
	lea	$59a27,a0
	lea	$59b27,a1
	bsr	l026e
l0008
	bsr	l0214
	clr.w	$58c24
	move.l	#$50000,$58008
	bsr	l0240
l0009
	lea	$58d98,a1
	bsr	l021e
	move.w	#$19,d0
	bsr	l0241
	lea	$ff8242.l,a0
	lea	$58dba,a1
l000a
	addq.b	#1,$59815
	move.b	$59815,d0
	andi.b	#7,d0
	tst.b	d0
	beq	l0015
	cmpi.b	#1,d0
	beq	l0018
	cmpi.b	#2,d0
	beq	l001b
	cmpi.b	#3,d0
	beq	l0013
	cmpi.b	#4,d0
	beq.s	l000e
	cmpi.b	#5,d0
	beq.s	l000b
	bra.s	l000a
l000b
	move.w	#$e,d1
l000c
	move.w	(a1)+,d7
	move.w	#6,d6
l000d
	bsr	l0231
	andi.w	#$777,d0
	move.w	d0,(a0)
	cmp.w	d0,d7
	bne.s	l000d
	dbf	d6,l000d
	addq.w	#2,a0
	dbf	d1,l000c
	bra	l0026
l000e
	movea.l	$58008,a6
	adda.l	#$7c60,a6
	move.w	#$62,$58d70
l000f
	bsr	l0243
	lea	$58d9a,a0
	lea	$ff8242.l,a1
	move.w	#$e,d0
l0010
	move.w	(a0)+,(a1)+
	dbf	d0,l0010
	movea.l	#$ff8207,a0
l0011
	movep.w	0(a0),d1
	cmp.w	a6,d1
	blt.s	l0011
	lea	$58dba,a0
	lea	$ff8242.l,a1
	move.w	#$e,d0
l0012
	move.w	(a0)+,(a1)+
	dbf	d0,l0012
	suba.l	#$140,a6
	subq.w	#1,$58d70
	bne.s	l000f
	bra	l0026
l0013
	bsr	l0231
	move.w	d0,d2
	ori.w	#$444,d2
	move.w	#$e,d1
l0014
	move.w	d2,(a0)
	move.w	#1,d0
	bsr	l0242
	move.w	#$777,(a0)
	move.w	#1,d0
	bsr	l0242
	move.w	(a1)+,(a0)+
	dbf	d1,l0014
	bra	l0026
l0015
	move.w	#$e,d7
l0016
	move.w	#2,d6
l0017
	bsr	l0243
	bsr	l001d
	dbf	d6,l0017
	addq.w	#2,a0
	addq.w	#2,a1
	dbf	d7,l0016
	move.w	#$190,d0
	bsr	l0241
	tst.w	d0
	bpl	l0028
	bsr	l023a
	bsr	l021a
	clr.w	$58b1c
	move.w	#$a,$58b3c
	lea	$59edf,a4
	bsr	l0263
	move.w	#$190,d0
	bsr	l0241
	tst.w	d0
	bpl	l0028
	bsr	l0214
	bra	l0008
l0018
	move.w	#2,d6
l0019
	lea	$ff8242.l,a0
	lea	$58dba,a1
	move.w	#$e,d7
l001a
	bsr	l0243
	bsr.s	l001d
	addq.w	#2,a0
	addq.w	#2,a1
	dbf	d7,l001a
	move.w	#$14,d0
	bsr	l0242
	dbf	d6,l0019
	bra	l0026
l001b
	move.w	#$10,d1
l001c
	bsr	l0216
	move.w	d1,d0
	bsr	l0242
	bsr	l0215
	move.w	#$10,d0
	sub.w	d1,d0
	bsr	l0242
	subq.w	#2,d1
	bne.s	l001c
	bra.s	l0026
l001d
	move.w	(a0),d0
	move.w	(a1),d1
	move.w	d0,d4
	move.w	d0,d2
	move.w	d1,d3
	andi.w	#7,d2
	andi.w	#7,d3
	cmp.w	d2,d3
	beq.s	l001f
	bmi.s	l001e
	addq.w	#1,d4
	bra.s	l001f
l001e
	subq.w	#1,d4
l001f
	move.w	d0,d2
	move.w	d1,d3
	andi.w	#$70,d2
	andi.w	#$70,d3
	cmp.w	d2,d3
	beq.s	l0021
	bmi.s	l0020
	addi.w	#$10,d4
	bra.s	l0021
l0020
	subi.w	#$10,d4
l0021
	move.w	d0,d2
	move.w	d1,d3
	andi.w	#$700,d2
	andi.w	#$700,d3
	cmp.w	d2,d3
	beq.s	l0023
	bmi.s	l0022
	addi.w	#$100,d4
	bra.s	l0023
l0022
	subi.w	#$100,d4
l0023
	move.w	d4,(a0)
	rts

l0024
	move.w	#$1f40,d0
l0025
	move.l	(a0)+,(a1)+
	dbf	d0,l0025
	rts

l0026
	bsr	l0215
	move.w	#$1f4,$58d70
l0027
	bsr	l0243
	btst	#7,$59818
	bne.s	l0028
	subq.w	#1,$58d70
	bne.s	l0027
	lea	$58e9c,a1
	bsr	l021e
	bra	l0009
l0028
	bsr	l0214
	bsr	l023a
	movea.l	#$59f34,a4
	move.w	#$10,$58b3c
	clr.w	$58b1c
	bsr	l0263
	bsr	l0217
	move.b	$59818,$5981b
	movea.l	$58838,a5
l0029
	movea.l	a5,a6
	bsr	l00a5
	bsr	l021a
	adda.l	#$1400,a6
	bsr	l00a5
	bsr	l0217
	bsr	l0243
	move.b	$59818,d0
	cmp.b	$5981b,d0
	beq.s	l0029
	move.b	d0,$5981b
	btst	#7,d0
	bne.s	l002b
	btst	#0,d0
	bne.s	l002a
	btst	#1,d0
	beq.s	l0029
	cmpi.w	#4,$58c20
	bcc.s	l0029
	addq.w	#1,$58c20
	adda.l	#$1400,a5
	bra.s	l0029
l002a
	tst.w	$58c20
	beq.s	l0029
	subq.w	#1,$58c20
	suba.l	#$1400,a5
	bra.s	l0029
l002b
	move.l	a5,$58838
	clr.w	$58d72
	bsr	l0214
	tst.w	$58c20
	beq	l002c
	cmpi.w	#2,$58c20
	beq	l002c
	move.w	#1,$58d72
l002c
	clr.w	$58d76
	clr.w	$58d74
	bsr	l0285
	move.w	#1,$58c32
	movea.l	#$68000,a0
	movea.l	#$38000,a1
	bsr	l0024
l002d
	lea	$58fac,a0
	lea	$59808,a1
	lea	$58fd0,a2
	move.w	#1,d1
	move.w	#7,d0
l002e
	move.b	(a1)+,(a0)+
	move.w	#-1,$10(a2)
	move.w	d1,(a2)+
	addq.w	#1,d1
	dbf	d0,l002e
	move.w	#$38,$58fe2
	move.w	#$38,$58fe4
	move.w	#4,$58fc4
	clr.b	$59817
	clr.b	$59818
	move.b	#5,$58fca
	move.w	#8,$58ff0
	clr.w	$58fc6
	move.w	#2,$58fc8
	move.w	#6,d0
	lea	$58fa4,a0
l002f
	move.b	#$5b,(a0)+
	dbf	d0,l002f
	clr.l	$58fcc
	move.w	#7,d0
	lea	$58fb4,a0
l0030
	clr.w	(a0)+
	dbf	d0,l0030
l0031
	move.l	#$78000,$58008
	bsr	l0214
	bsr	l0150
	bsr	l0240
	move.w	$58d74,d0
	addi.w	#$5c,d0
	move.b	d0,$59fce
	move.b	d0,$59fb4
	movea.l	#$59fb6,a4
	move.w	#$58,$58b1c
	move.w	#$50,$58b3c
	bsr	l0263
	bsr	l021a
l0032
	move.w	#$1e,d0
	bsr	l0242
	tst.w	$484.l
	beq	l0032
	bsr	l0034
	bra	l0043
l0033
	bsr.s	l0034
	bsr	l0048
	move.l	#$78000,$58008
	movea.l	#$38000,a0
	movea.l	#$78000,a1
	bsr	l0024
	bsr	l0256
	move.w	#1,$58c24
	lea	$58e38,a1
	bsr	l021f
	move.w	#$1c,$58c3c
	move.l	#0,$582b0
	move.l	#$41198,$580b0
	move.w	#$26,$58b5e
	move.w	#$a0,$58b1e
	move.w	#$36,$58b3e
	bra	l004d
l0034
	clr.w	$58d4a
	move.w	#$f,d0
	movea.l	#$58df8,a1
	movea.l	#$58e38,a0
l0035
	move.w	(a1)+,(a0)+
	dbf	d0,l0035
	movea.l	#$58e78,a1
	movea.l	#$58e90,a0
	move.w	#5,d0
l0036
	move.w	(a1)+,(a0)+
	dbf	d0,l0036
	move.w	$58fc6,d0
	move.w	d0,d1
	asl.w	#2,d0
	lea	$5897c,a5
	move.l	0(a5,d0.w),d0
	move.l	d0,$58978
	move.w	$58fc6,d0
	asl.w	#1,d0
	lea	$58fd0,a5
	move.w	0(a5,d0.w),$58c2c
	move.w	$10(a5,d0.w),d2
	move.w	d2,$58c48
	tst.w	d2
	bmi	l0037
	beq	l0037
	subq.w	#1,d2
	andi.w	#7,d2
	addq.w	#1,d2
l0037
	move.w	d2,$58c46
	lea	$58fb4,a0
	move.w	0(a0,d0.w),$58d7a
	asl.w	#2,d0
	lea	$58938,a0
	lea	$58e3a,a1
	lea	$58e90,a2
	clr.w	d1
l0038
	cmp.w	$58d7a,d1
	beq.s	l0039
	move.w	0(a0,d0.w),(a1)
	move.w	(a1)+,(a2)+
	addq.w	#1,d1
	addq.w	#2,d0
	bra.s	l0038
l0039
	move.w	0(a0,d0.w),$58e42
	move.w	0(a0,d0.w),$58e02
	asl.w	#1,d0
	lea	$588b8,a0
	move.l	0(a0,d0.w),$588b4
	move.l	#$38000,$58008
	move.l	#$40fd8,$580bc
	move.l	#$40fe8,$580c0
	move.l	#$40ff8,$580c4
	move.l	#$41008,$580c8
	move.w	#$28,$58b50
	clr.w	$58b10
	move.w	#$ad,$58b30
	bsr	l01d8
	addi.w	#$20,$58b10
	bsr	l01d8
	addi.w	#$20,$58b10
	bsr	l01d8
	move.w	#$120,$58b10
	bsr	l01d8
	move.l	$58fcc,$588b0
	clr.l	$58fcc
	move.w	#2,$58c54
l003a
	move.w	$58c54,d5
	lea	$58fcc,a0
	lea	$588b0,a1
	move.b	0(a1,d5.w),d0
	cmp.b	0(a0,d5.w),d0
	beq	l003b
	bsr	l013c
	bra	l003a
l003b
	subq.w	#1,$58c54
	bpl	l003a
	move.w	$58fc6,d1
l003c
	cmpi.w	#3,d1
	bcs.s	l003d
	subq.w	#3,d1
	bra.s	l003c
l003d
	move.w	d1,$58c54
	asl.w	#3,d1
	addq.w	#8,d1
	lea	$58040,a0
	lea	$58340,a1
	move.w	#7,d7
l003e
	move.l	(a1)+,d2
	add.w	d1,d2
	move.l	d2,(a0)+
	dbf	d7,l003e
	adda.w	#$10,a1
	adda.w	#$10,a0
	move.w	#1,d7
l003f
	move.l	(a1)+,d2
	add.w	d1,d2
	move.l	d2,(a0)+
	dbf	d7,l003f
	move.w	#-$8000,d0
	movea.l	#$10000,a0
	move.l	a0,$58008
l0040
	clr.l	(a0)+
	dbf	d0,l0040
	clr.w	$58b50
	clr.w	$58b10
	clr.w	$58b30
	clr.l	d6
	move.w	$58fc6,d6
	asl.w	#4,d6
	addi.l	#$48000,d6
	move.l	d6,$58018
	move.w	#3,d6
l0041
	move.w	#3,d7
l0042
	bsr	l01b9
	addi.w	#$31,$58b10
	dbf	d7,l0042
	addi.l	#$8000,$58008
	move.w	$58b10,d0
	andi.w	#$f,d0
	move.w	d0,$58b10
	dbf	d6,l0041
	move.w	$58fc6,d0
	addq.w	#2,d0
	lsr.w	#2,d0
	addq.w	#3,d0
	move.w	d0,$58d6e
	rts

l0043
	bsr	l0214
	bsr	l023a
	clr.w	$58d68
	clr.w	$58d5a
	clr.w	$58d54
	clr.w	$58d52
	clr.w	$58c2e
	cmpi.w	#2,$58c20
	blt.s	l0045
	tst.w	$58d74
	beq	l0044
	cmpi.w	#3,$58c20
	beq	l0045
l0044
	move.w	#1,$58c2e
l0045
	clr.w	$58d8c
	clr.w	$58d4a
	move.w	#7,d0
	lea	$59800,a0
	lea	$58fac,a1
l0046
	move.b	(a1)+,(a0)+
	dbf	d0,l0046
	move.l	#$79228,$58808
	move.l	#$38000,$58008
	bsr	l025e
	move.w	#8,$58c22
	cmpi.w	#3,$58fc6
	bge	l0047
	move.w	#8,$58c46
	move.w	#8,$58c48
	move.w	#-$8000,$58c2c
	move.b	#$5b,$59044
	move.b	#$63,$59045
l0047
	bsr	l025b
	bsr.s	l0048
	bsr	l0219
	move.l	#$78000,$58008
	bsr	l0240
	bsr	l01e2
	movea.l	#$38000,a0
	movea.l	#$78000,a1
	bsr	l0024
	move.w	#$c,$58c38
	bra	l004d
l0048
	bsr	l023a
	move.l	#$38000,$58008
	lea	$58418,a0
	move.w	#$17c,d0
l0049
	move.w	#-1,(a0)+
	dbf	d0,l0049
	lea	$58cd6,a0
	lea	$58718,a1
	lea	$58c96,a2
	move.w	#$f,d0
l004a
	move.l	#-1,(a0)+
	move.w	#-1,(a1)+
	move.w	#-1,(a2)+
	dbf	d0,l004a
	bsr	l0149
	clr.b	$59816
	tst.w	$58d68
	bne	l004c
l004b
	bsr	l0231
	dc.b	2,'@',3,$ff,6,'@',0,'0'
	move.w	d0,$58bb0
	move.w	d0,$58c4e
	move.w	d0,$58c4c
	move.w	d0,d1
	andi.w	#$f,d1
	move.w	d1,$58d8a
	movea.l	$58978,a0
	andi.w	#-$1f,d0
	lsr.w	#3,d0
	tst.b	$14(a0,d0.w)
	bne.s	l004b
	tst.b	$10(a0,d0.w)
	bne.s	l004b
	tst.b	$18(a0,d0.w)
	bne.s	l004b
	bsr	l01a7
	bsr	l00c4
	bsr	l0147
l004c
	bsr	l012c
	move.w	#$e3,$58b1c
	move.w	#$b3,$58b3c
	move.w	$58fc6,d0
	addi.w	#$5c,d0
	bsr	l0266
	rts

l004d
	bsr	l0219
	movea.l	#$70000,a1
	movea.l	#$38000,a0
	bsr	l0024
	bsr	l0149
	move.l	#$78000,$58008
	lea	$58b60,a0
	move.w	#7,d0
l004e
	move.w	#-1,(a0)+
	dbf	d0,l004e
	bsr	l00cb
	bsr	l00a7
	move.w	#1,$58b52
	clr.w	$58b12
	move.w	#$3a,$58b32
	move.w	#2,$58b50
	move.l	#$e,$58220
	move.w	#$a0,$58b10
	move.w	#$42,$58b30
	move.w	#$108,$58d4e
	clr.w	$58b90
	clr.w	$58d82
	clr.w	$58d88
	clr.w	$58d6c
	clr.w	$58d96
	clr.w	$58d50
	clr.w	$58d84
	clr.w	$58d90
	clr.w	$58d92
	clr.w	$58c4a
	clr.w	$58c36
	move.w	#1,$58d7c
	bsr	l00b6
	bsr	l024f
	clr.w	$58d80
	clr.w	$58d58
	move.l	#$e,$58518
	bsr	l0123
l004f
	bsr	l0233
	tst.w	d0
	bne	l004f
l0050
	bsr	l0244
	bsr	l023d
	bsr	l00b8
	bsr	l0251
	bsr	l00ac
	bsr	l01d5
	bsr	l01ab
	bsr	l01b0
	bsr	l020f
	move.w	$58bb0,d0
	move.w	d0,$58c4c
	add.w	$58d88,d0
	bpl.s	l0051
	clr.w	$58d88
	clr.w	d0
l0051
	cmpi.w	#$700,d0
	bmi.s	l0052
	move.w	#$700,d0
	clr.w	$58d88
l0052
	move.w	d0,$58bb0
	move.w	d0,$58c4e
	andi.w	#$f,d0
	move.w	d0,$58d8a
	bsr	l01a7
	bsr	l00a8
	bsr	l0152
	bsr	l01eb
	bsr	l00c4
	bsr	l01be
	bsr	l0201
	bsr	l020a
	bsr	l01c9
	bsr	l00e1
	bsr	l0147
	bsr	l01a3
l0053
	tst.w	$58d80
	beq	l0053
	bsr	l00ae
	bsr	l0240
	bsr	l00bd
	tst.w	$58d4a
	beq	l0071
	bmi	l0007
	cmpi.w	#1,$58d4a
	beq	l005b
	move.w	#7,d0
	lea	$58b60,a0
l0054
	cmpi.w	#9,(a0)+
	bcc	l0055
	subq.w	#1,$58c48
l0055
	dbf	d0,l0054
	bsr	l025a
	lea	$58fd0,a5
	move.w	$58fc6,d0
	asl.w	#1,d0
	move.w	$58c2c,0(a5,d0.w)
	move.w	$58c48,$10(a5,d0.w)
	cmpi.w	#3,$58d4a
	beq	l0073
	move.l	#$5998b,d7
	bsr	l0286
	clr.w	$58d80
	move.w	#$10,$58c30
l0056
	bsr	l023d
	bsr	l0244
	bsr	l01d5
	bsr	l01b0
	bsr	l01ab
	bsr	l020f
	bsr	l01a7
	bsr	l00c4
	addq.w	#1,$58b30
	cmpi.w	#$f,$58c30
	bcc.s	l0057
	subq.l	#1,$58220
l0057
	bsr	l01d8
	bsr	l00e1
	bsr	l01a3
	bsr	l0147
l0058
	tst.w	$58d80
	beq	l0058
	bsr	l0240
	bsr	l00ae
	subq.w	#1,$58c30
	bne.s	l0056
	bsr	l0250
	lea	$58e9c,a1
	clr.w	$ff8240.l
	bsr	l021e
	movea.l	#$38000,a1
	movea.l	#$70000,a0
	bsr	l0024
	move.w	$58fc6,d0
	addq.w	#1,d0
	move.b	$59814,d1
	cmpi.b	#-$40,d1
	bgt.s	l0059
	subq.w	#2,d0
l0059
	cmp.w	$58fc8,d0
	bgt.s	l005a
	move.w	d0,$58fc6
l005a
	bra	l0033
l005b
	tst.b	$59807
	bne	l005c
	subi.w	#$28,$58c26
	clr.w	$58d4a
	bra	l0050
l005c
	bsr	l0250
	bsr	l00b6
	subq.w	#1,$58fc4
	bsr	l025d
	movea.l	#$38000,a1
	movea.l	#$70000,a0
	bsr	l0024
	bsr	l01e0
	tst.w	$58fc4
	bne	l006e
l005d
	bsr	l0150
	movea.l	#$59f9c,a4
	move.w	#$58,$58b1c
	move.w	#$50,$58b3c
	bsr	l0263
	move.w	#$46,d0
	bsr	l0242
	bsr	l0150
	lea	$59a27,a0
	lea	$59b27,a1
	bsr	l026e
	lea	$59e4b,a0
	lea	$58fa5,a1
	clr.w	$58bd0
l005e
	move.w	$58bd0,d0
	asl.w	#5,d0
	clr.w	d1
l005f
	move.b	0(a0,d0.w),d2
	cmp.b	0(a1,d1.w),d2
	beq.s	l0060
	bcc.s	l0061
	bra.s	l0062
l0060
	addq.w	#1,d0
	addq.w	#1,d1
	cmpi.w	#5,d1
	bne.s	l005f
l0061
	addq.w	#1,$58bd0
	cmpi.w	#5,$58bd0
	bcs.s	l005e
	move.w	#-1,$58bd0
	bra	l0067
l0062
	lea	$59eaa,a2
	move.w	#3,d0
	sub.w	$58bd0,d0
	bmi.s	l0065
l0063
	move.w	#$12,d1
l0064
	move.b	0(a2,d1.w),$20(a2,d1.w)
	dbf	d1,l0064
	suba.l	#$20,a2
	dbf	d0,l0063
l0065
	move.w	$58bd0,d0
	asl.w	#5,d0
	move.w	#4,d1
	addq.w	#4,d0
l0066
	move.b	0(a1,d1.w),0(a0,d0.w)
	subq.w	#1,d0
	dbf	d1,l0066
	addi.w	#$b,d0
	move.w	#$20,d1
	move.b	d1,0(a0,d0.w)
	move.b	d1,1(a0,d0.w)
	move.b	d1,2(a0,d0.w)
	move.b	d1,3(a0,d0.w)
	move.b	d1,4(a0,d0.w)
	move.b	d1,5(a0,d0.w)
	move.b	d1,6(a0,d0.w)
	move.b	d1,7(a0,d0.w)
l0067
	move.w	d0,d3
	movea.l	a0,a3
	bsr	l0217
	movea.l	#$59e1f,a4
	move.w	#4,$58b3c
	clr.w	$58b1c
	bsr	l0263
	movea.l	#$59e4a,a4
	clr.w	$58b1c
	move.w	#$34,$58b3c
	bsr	l0263
	tst.b	$58bd0
	bmi	l006c
	move.w	$58bd0,d0
	lsl.w	#5,d0
	addi.w	#$34,d0
	move.w	d0,$58b3c
	move.w	#$b0,$58b1c
	move.w	#7,d2
l0068
	bsr	l0233
	tst.b	d0
	bne.s	l0068
l0069
	bsr	l0243
	bsr	l0233
	tst.b	d0
	beq.s	l0069
	cmpi.b	#$d,d0
	beq.s	l006d
	cmpi.b	#8,d0
	bne.s	l006a
	cmpi.w	#7,d2
	beq.s	l0069
	subi.w	#$10,$58b1c
	move.w	#$20,d0
	bsr	l0266
	subi.w	#$10,$58b1c
	addq.w	#1,d2
	subq.w	#1,d3
	move.b	#$20,0(a3,d3.w)
	bra.s	l0069
l006a
	tst.b	d2
	bmi.s	l0069
	cmpi.b	#$20,d0
	beq.s	l006b
	andi.l	#$df,d0
	cmpi.b	#$41,d0
	bcs.s	l0069
	cmpi.b	#$5b,d0
	bcc.s	l0069
l006b
	move.b	d0,0(a3,d3.w)
	bsr	l0266
	addq.b	#1,d3
	subq.w	#1,d2
	bra.s	l0069
l006c
	move.w	#$c8,d0
	bsr	l0241
l006d
	tst.w	$58d72
	beq	l0008
	clr.w	$58d72
	bsr	l0285
	bra	l006f
l006e
	tst.w	$58d72
	beq	l0031
	bsr	l025e
l006f
	eori.w	#$110,$58d76
	eori.w	#1,$58d74
	lea	$58fa4,a0
	lea	$58ff4,a1
	move.w	#$13,d1
l0070
	move.l	(a1),d0
	move.l	(a0),(a1)+
	move.l	d0,(a0)+
	dbf	d1,l0070
	tst.w	$58c32
	beq	l0031
	clr.w	$58c32
	bra	l002d
l0071
	bra	l0050
l0072
	move.b	$59818,d0
	tst.b	d0
	bne.s	l0072
	bsr	l0238
	bsr	l0243
	bsr	l0243
	bsr	l0243
	bra	l023b
l0073
	move.w	#$a,$58c30
	movea.l	#$58fa7,a0
	move.w	#2,d0
	bsr	l024b
	bsr	l0250
	move.w	#1,$58d68
	clr.w	$ff8240.l
l0074
	move.w	#5,$58d70
	eori.w	#$777,$ff8240.l
l0075
	bsr	l0243
	subq.w	#1,$58d70
	bne.s	l0075
	subq.w	#1,$58c30
	bne.s	l0074
	bsr	l014e
	lea	$59c1b,a0
	lea	$59c81,a1
	bsr	l026e
	movea.l	#$59fd0,a4
	move.w	#$4e,$58b1c
	move.w	#$64,$58b3c
	bsr	l0263
	bsr	l00b7
	bsr	l0219
	move.w	#$64,d0
	bsr	l0242
	lea	$58418,a0
	move.w	#$17c,d0
l0076
	move.w	#-1,(a0)+
	dbf	d0,l0076
	lea	$58cd6,a0
	lea	$58718,a1
	lea	$58c96,a2
	move.w	#$f,d0
l0077
	move.l	#-1,(a0)+
	move.w	#-1,(a1)+
l0078	equ	*-2
	move.w	#-1,(a2)+
	dbf	d0,l0077
	lea	$58b60,a0
	move.w	#7,d0
l0079
	move.w	#-1,(a0)+
	dbf	d0,l0079
	clr.w	$58d4a
	clr.w	$58b90
	clr.w	$58d82
	clr.w	$58d88
	clr.w	$58d50
	clr.w	$58d84
	clr.w	$58d90
	clr.w	$58d92
	bsr	l0214
	movea.l	#$70000,a0
	movea.l	#$38000,a1
	move.l	a1,$58008
	bsr	l0024
	bsr	l014e
	bsr	l019a
	movea.l	#$38000,a0
	movea.l	#$70000,a1
	bsr	l0024
	movea.l	#$38000,a0
	movea.l	#$78000,a1
	move.l	a1,$58008
	bsr	l0024
	bsr	l00a7
	bsr	l0123
	clr.w	$58c46
	clr.w	$58d26
	move.w	#1,$58c1e
	move.w	#1,$58d48
	bsr	l0219
	move.w	#8,$58c22
	move.w	#1,$58b52
	clr.w	$58b12
	clr.w	$58c3c
	clr.w	$58c4a
	move.w	#$1f4,d0
	move.w	d0,$58bb0
	move.w	d0,$58c4e
	move.w	d0,$58c4c
	move.b	#$5b,$5a016
	move.b	#$5b,$5a017
	move.b	#$5b,$5a018
	move.w	#-1,$58c2a
	move.w	#$37,$58b32
	move.w	#2,$58b50
	move.l	#$e,$58220
	move.w	#$a0,$58b10
	move.w	#$42,$58b30
	move.w	#$108,$58d4e
	clr.w	$58d80
	bsr	l00b6
	move.w	$58d54,$58d56
	clr.w	$58d54
	bsr	l019d
	bsr	l023d
	bsr	l019d
l007a
	bsr	l023d
	bsr	l00b8
	bsr	l019c
	bsr	l01af
	bsr	l020f
	bsr	l019d
	bsr	l0152
	bsr	l0197
	bsr	l01eb
	bsr	l01be
	bsr	l0201
	bsr	l020a
	bsr	l0174
	bsr	l01d8
	bsr	l01cf
	bsr	l00e1
	bsr	l0147
	bsr	l01a3
	bsr	l00ae
l007b
	tst.w	$58d80
	beq	l007b
	bsr	l0240
	bsr	l0244
	clr.w	$ff8240.l
	tst.w	$58d4a
	beq	l007a
	bmi	l0007
	tst.b	$59807
	bne	l007c
	clr.w	$58d4a
	subi.w	#$28,$58c26
	bra	l007a
l007c
	bsr	l014e
	movea.l	#$59feb,a4
	clr.w	$58b1c
	move.w	#$58,$58b3c
	bsr	l0263
	move.w	#$14,d0
	bsr	l0242
	clr.w	$58d68
	subq.w	#1,$58c2a
	bmi	l007e
l007d
	lea	$5a018,a0
	bsr	l024a
	movea.l	#$5a016,a4
	move.w	#$90,$58b1c
	move.w	#$58,$58b3c
	bsr	l0263
	lea	$58fa9,a0
	move.w	#4,d0
	bsr	l024b
	clr.w	$58d58
	bsr	l0250
	move.w	#4,d0
	bsr	l0242
	subq.w	#1,$58c2a
	bpl	l007d
l007e
	bsr	l0285
	move.w	#$28,d0
	bsr	l0242
	move.w	$58d56,$58d54
	bsr	l0214
	clr.b	$5981d
	movea.l	#$70000,a0
	movea.l	#$38000,a1
	bsr	l0024
	move.l	#$38000,$58008
	bsr	l012b
	movea.l	#$3a120,a0
	movea.l	#$6a120,a1
	move.w	#$1260,d0
l007f
	move.l	(a1)+,(a0)+
	dbf	d0,l007f
	movea.l	#$38000,a0
	movea.l	#$70000,a1
	bsr	l0024
	movea.l	#$38000,a0
	movea.l	#$78000,a1
	move.l	a1,$58008
	bsr	l0024
	bsr	l00a7
	move.l	$58808,$5880c
	move.w	$58d8c,$58d8e
	move.l	#$79238,$58808
	move.w	#1,$58d8c
	bsr	l0123
	clr.w	$58bd0
	lea	$58418,a0
	move.w	#$17c,d0
l0080
	move.w	#-1,(a0)+
	dbf	d0,l0080
	move.w	#$f,d0
	lea	$58b50,a0
l0081
	move.w	#-1,(a0)+
	dbf	d0,l0081
	move.w	#$be,$58b14
	move.w	#$60,$58b34
	clr.w	$58b94
	move.w	#$34,$58b50
	move.w	#$92,$58b10
	move.w	#$97,$58b30
	move.w	#3,d7
	lea	$58b16,a0
l0082
	move.w	#$91,$20(a0)
	move.w	#$e8,(a0)+
	dbf	d7,l0082
	move.w	#$14,$58d50
	lea	$58df8,a1
	bsr	l021f
	move.l	#$599af,d7
	bsr	l0286
	clr.w	$58d70
	clr.w	$58d64
l0083
	bsr	l009f
	bsr	l023d
	bsr	l01b4
	bsr	l0243
	bsr	l0090
	bsr	l0240
	bsr	l0243
	addq.w	#1,$58d70
	cmpi.w	#$c3,$58d70
	bne.s	l0083
	tst.w	$58d64
	bne.s	l0084
	move.w	$58fc6,d0
	addq.w	#1,d0
	movea.l	#$58fa7,a0
	bsr	l024b
l0084
	bsr	l0250
	move.w	$58fc6,d0
	asl.w	#1,d0
	lea	$58fb4,a0
	addq.w	#1,0(a0,d0.w)
	cmpi.w	#3,0(a0,d0.w)
	bne	l008e
	movea.l	#$58fa7,a0
	move.w	#7,d0
	bsr	l024b
	movea.l	#$58fa8,a0
	move.w	#5,d0
	bsr	l024b
	bsr	l0250
	clr.w	$58d54
	clr.w	$58d56
	clr.w	$58bb0
	move.l	#$598e1,d7
	bsr	l0286
	lea	$58ebc,a1
	bsr	l021e
	move.w	#1,$58d68
	bsr	l0034
	bsr	l0048
	bsr	l0147
	move.l	#$78000,$58008
	movea.l	#$38000,a0
	movea.l	#$78000,a1
	bsr	l0024
	movea.l	#$38000,a0
	movea.l	#$70000,a1
	bsr	l0024
	move.w	#1,$58c24
	lea	$58e38,a1
	bsr	l021f
	lea	$59bd7,a0
	lea	$59bf9,a1
	bsr	l026e
	clr.w	$58d80
l0085
	bsr	l023d
	bsr	l01ab
	move.w	$58bb0,d0
	addq.w	#5,d0
	move.w	d0,$58bb0
	move.w	d0,$58c4e
	andi.w	#$f,d0
	move.w	d0,$58d8a
	bsr	l01a7
	bsr	l00c4
	move.w	#$30,$58b1c
	move.w	#$60,$58b3c
	movea.l	#$59fdc,a4
	bsr	l0263
	bsr	l0147
l0086
	tst.w	$58d80
	beq	l0086
	bsr	l0240
	bsr	l0244
	cmpi.w	#$640,$58bb0
	blt	l0085
	bsr	l0285
	cmpi.w	#7,$58fc6
	beq	l0087
	move.w	$58fc6,d0
	asl.w	#1,d0
	lea	$58fe0,a0
	move.w	#-1,0(a0,d0.w)
l0087
	move.w	$58fc6,d0
	addq.w	#3,d0
	cmp.w	$58fc8,d0
	blt	l0088
	cmpi.w	#7,d0
	bgt	l0089
	move.w	d0,$58fc8
l0088
	move.w	d0,$58fc6
	asl.w	#1,d0
	lea	$58fe0,a0
	move.w	#$38,0(a0,d0.w)
l0089
	subq.w	#1,$58ff0
	bne	l008e
	lea	$59d13,a0
	lea	$59d6b,a1
	bsr	l026e
	clr.w	$58fc4
	bsr	l025d
	movea.l	#$38000,a1
	movea.l	#$70000,a0
	bsr	l0024
	bsr	l0214
	bsr	l0150
	clr.w	$58b1c
	clr.w	$58b3c
	movea.l	#$5a01a,a4
	bsr	l0263
	movea.l	#$58df8,a1
	bsr	l021f
	move.w	#$1c2,d0
	bsr	l0242
	movea.l	#$58e9c,a1
	bsr	l021f
	bsr	l0150
	clr.w	$58b1c
	move.w	#$10,$58b3c
	movea.l	#$5a0a7,a4
	bsr	l0263
	movea.l	#$58df8,a1
	bsr	l021f
	move.w	#$1c2,d0
	bsr	l0242
	movea.l	#$58e9c,a1
	bsr	l021f
	bsr	l0150
	move.w	#$33,$58b50
	move.w	#$a0,$58b10
	move.w	#$7c,$58b30
	bsr	l01d8
	move.w	#$36,$58b50
	move.w	#$b0,$58b10
	move.w	#$a0,$58b30
	bsr	l01d8
	lea	$58e58,a1
	bsr	l021f
	move.l	#$4c040,$580a8
	move.l	#7,$581a8
	move.l	#$16,$582a8
	move.l	#$4c040,$583a8
	move.w	#8,d6
	move.w	#$7d,d5
	move.w	#6,d7
l008a
	move.w	d6,$58b10
	move.w	#$a0,$58b30
	move.w	#$24,$58b50
	move.w	d5,$58b90
	move.w	#$64,$58b70
l008b
	bsr	l01d8
	bsr	l0243
	subq.w	#1,$58b90
	addq.w	#1,$58b70
	move.w	$58b90,d0
	cmpi.w	#$64,d0
	bgt	l008c
	subq.w	#2,$58b70
l008c
	lsr.w	#1,d0
	sub.w	d0,$58b30
	addi.w	#$32,$58b30
	move.w	$58b70,d0
	lsr.w	#1,d0
	add.w	d0,$58b10
	subi.w	#$32,$58b10
	cmpi.w	#$a1,$58b30
	bcs	l008b
	move.w	d7,d0
	lsr.w	#1,d0
	add.w	d0,d6
	addi.w	#8,d6
	subq.w	#1,d5
	addi.l	#$10,$580a8
	move.w	d7,d0
	andi.w	#1,d0
	beq	l008d
	addi.l	#$ee0,$580a8
l008d
	dbf	d7,l008a
	move.w	#$19a,d0
	bsr	l0242
	lea	$58e9c,a1
	bsr	l021f
	bsr	l0150
	bsr	l021a
	bsr	l0285
	bra	l005d
l008e
	cmpi.w	#$c,$58c38
	bcc.s	l008f
	move.w	#$c,$58c38
l008f
	clr.w	$58d52
	movea.l	#$70000,a0
	movea.l	#$38000,a1
	bsr	l0024
	bsr	l0229
	move.l	#$598e1,d7
	bsr	l0286
	lea	$58ebc,a1
	bsr	l021e
	move.l	$5880c,$58808
	move.w	$58d8e,$58d8c
	bsr	l00b6
	move.w	$58d56,$58d54
	clr.w	$58d68
	bra	l0033
l0090
	cmpi.w	#$14,$58d70
	bmi	l009c
	cmpi.w	#$3f,$58d70
	bpl	l0091
	move.w	#2,$58b54
	addq.w	#1,$58b94
	move.w	$58b94,d0
	lsr.w	#2,d0
	subq.w	#4,d0
	add.w	d0,$58b34
	addq.w	#1,$58b14
	move.w	$58d50,d0
	addq.w	#4,d0
	andi.l	#$3f,d0
	move.w	d0,$58d50
	asl.w	#1,d0
	andi.w	#$f8,d0
	addi.l	#$412c0,d0
	move.l	d0,$58020
	bra	l009c
l0091
	cmpi.w	#$4a,$58d70
	beq	l0093
	bmi	l009c
	cmpi.w	#$6e,$58d70
	beq	l0095
	cmpi.w	#$59,$58d70
	beq	l0096
	bpl	l0097
	move.w	$58d50,d0
	addq.w	#1,d0
	andi.l	#$3f,d0
	move.w	d0,$58d50
	andi.w	#$f8,d0
	addi.l	#$42c20,d0
	move.l	d0,$58020
	addq.l	#4,$582dc
	subq.w	#4,$58b32
	move.w	#3,d7
	movea.l	#$58b16,a0
l0092
	move.w	#$35,$40(a0)
	sub.w	d7,$20(a0)
	bsr	l0231
	andi.w	#2,d0
	subq.w	#1,d0
	add.w	d0,(a0)+
	dbf	d7,l0092
	bra	l009c
l0093
	move.w	#$e0,$58b12
	move.w	#$31,$58b52
	move.w	#$9c,$58b32
	move.l	#2,$582dc
	move.w	#4,$58d50
	move.l	#$599c5,d7
	bsr	l0286
	bra	l009c
l0094
	move.l	#-1,$58b56
	move.l	#-1,$58b5a
	bra	l0097
l0095
	tst.b	$59803
	bne	l0094
	move.w	#$90,$58b36
	move.w	#$30,$58b16
	move.w	#$37,$58b56
	move.l	#$599c5,d7
	bsr	l0286
	bra	l0097
l0096
	tst.b	$59803
	bne	l0094
	move.w	#$92,$58b38
	move.w	#$92,$58b3a
	move.w	#$30,$58b18
	move.w	#$40,$58b1a
	move.w	#-1,$58b5c
	move.w	#-1,$58b56
l0097
	cmpi.w	#$91,$58d70
	beq	l0099
	bpl	l009a
	move.w	$58b52,d0
	move.w	$58d70,d1
	andi.w	#3,d1
	bne	l0098
	addq.w	#1,d0
	cmpi.w	#$33,d0
	blt	l0098
	move.w	#$31,d0
l0098
	move.w	d0,$58b52
	subq.w	#1,$58b12
	bra	l009c
l0099
	move.l	#$599d9,d7
	bsr	l0286
	move.w	#-1,$58b58
	move.w	#-1,$58b5a
l009a
	move.w	$58d70,d1
	andi.w	#1,d1
	bne	l009c
	bsr	l0142
	bsr	l0231
	move.w	d0,$ff824a.l
	move.w	$58d70,d1
	andi.w	#3,d1
	bne	l009c
	move.w	$58b52,d0
	addq.w	#1,d0
	cmpi.w	#$34,d0
	blt	l009b
	move.w	#$32,d0
l009b
	move.w	d0,$58b52
	move.w	$58d70,d1
	andi.w	#7,d1
	bne	l009c
	eori.w	#1,$58b56
l009c
	bsr	l0231
	andi.l	#$30,d0
	beq	l009c
	addi.l	#$43200,d0
	cmp.l	$580e8,d0
	beq	l009c
	move.l	d0,$580e8
	move.l	$580ec,d0
	addi.l	#$8c0,d0
	cmpi.l	#$65958,d0
	blt	l009d
	move.l	#$647d8,d0
l009d
	move.l	d0,$580ec
	addi.l	#$1a40,d0
	move.l	d0,$583ec
	clr.w	d0
l009e
	bsr	l01d9
	addq.w	#1,d0
	cmpi.w	#6,d0
	bne	l009e
	rts

l009f
	tst.w	$58d64
	bne	l00a2
	move.b	$59818,d7
	tst.b	d7
	beq	l00a3
	tst.w	$58bd0
	bne.s	l00a2
	btst	#7,d7
	bne.s	l00a4
	btst	#2,d7
	bne.s	l00a0
	btst	#3,d7
	beq.s	l00a3
	bsr	l0128
	dc.b	6,$b9,0,0,0,$10,0,5
	dc.b	$88,8
	addq.w	#1,$58d8c
	cmpi.w	#6,$58d8c
	bne.s	l00a1
	move.l	#$79238,$58808
	move.w	#1,$58d8c
	bra.s	l00a1
l00a0
	bsr	l0128
	dc.b	4,$b9,0,0,0,$10,0,5
	dc.b	$88,8
	subq.w	#1,$58d8c
	bne.s	l00a1
	move.l	#$79278,$58808
	move.w	#5,$58d8c
l00a1
	bsr	l0123
l00a2
	move.w	#1,$58bd0
	rts

l00a3
	clr.w	$58bd0
	rts

l00a4
	move.w	$58d8c,d0
	lea	$58fac,a0
	move.b	0(a0,d0.w),d1
	beq.s	l00a2
	subq.b	#1,d1
	move.b	d1,0(a0,d0.w)
	bsr	l012f
	bsr	l0127
	move.w	#1,$58d64
	move.l	#$5983d,d7
	bsr	l0286
	bra.s	l00a2
l00a5
	movea.l	#$ff8207,a0
l00a6
	movep.w	0(a0),d1
	cmp.w	a6,d1
	bmi.s	l00a6
	rts

l00a7
	move.w	#$22,$58b50
	move.w	#$54,$58b10
	clr.w	$58b30
	bra	l01d8
l00a8
	tst.w	$58c3c
	beq.s	l00ab
	subq.w	#1,$58c3c
	beq.s	l00ab
	cmpi.w	#$e,$58c3c
	bcs.s	l00a9
	addq.l	#2,$582b0
	subi.l	#$140,$580b0
	bra.s	l00aa
l00a9
	subq.l	#2,$582b0
	addi.l	#$140,$580b0
l00aa
	move.w	#7,d0
	bsr	l01d9
l00ab
	rts

l00ac
	tst.l	$58434
	bmi.s	l00ab
	movea.l	$58434,a0
	move.l	$582b0,d0
	addq.w	#2,d0
l00ad
	clr.l	(a0)+
	clr.l	(a0)
	lea	$9c(a0),a0
	dbf	d0,l00ad
	move.l	#-1,$58434
	rts

l00ae
	tst.w	$58d68
	bne	l00b4
	cmpi.w	#8,$58c2c
	bne.s	l00b0
	subq.w	#1,$58d62
	bne	l00af
	neg.w	$58d5e
	move.w	#$f,$58d62
l00af
	move.w	$58d5c,d0
	sub.w	$58d5e,d0
	move.w	d0,$58d5c
	move.b	#4,$ff8800.l
	move.b	d0,$ff8802.l
	lsr.w	#8,d0
	move.b	#5,$ff8800.l
	move.b	d0,$ff8802.l
	move.b	#$a,$ff8800.l
	move.b	#$f,$ff8802.l
	rts

l00b0
	tst.b	$59807
	bne.s	l00b2
	subq.w	#1,$58d7c
	bne.s	l00b1
	move.w	$58c26,d0
	lsr.w	#6,d0
	addq.w	#1,d0
	move.w	d0,$58d7c
l00b1
	move.b	#$a,$ff8800.l
	move.w	$58d7c,d0
	eori.w	#$f,d0
	move.b	d0,$ff8802.l
	lea	$58ee4,a0
	move.b	#4,$ff8800.l
	move.b	(a0),$ff8802.l
	move.b	#5,$ff8800.l
	move.b	1(a0),$ff8802.l
	rts

l00b2
	subq.w	#1,$58d7c
	bpl.s	l00b5
	bsr	l0231
	dc.b	2,'@',0,$1f,6,'@',0,' '
	move.b	d0,$59810
	move.w	#4,$58d7c
l00b3
	lsl.w	#1,d0
	lea	$58ee4,a0
	move.b	#4,$ff8800.l
	move.b	1(a0,d0.w),$ff8802.l
	move.b	#5,$ff8800.l
	move.b	0(a0,d0.w),$ff8802.l
l00b4
	rts

l00b5
	clr.w	d0
	addi.b	#$c,$59810
	move.b	$59810,d0
	bra.s	l00b3
l00b6
	move.b	#$a,$ff8800.l
	move.b	#7,$ff8802.l
	move.w	#1,$58d7c
	rts

l00b7
	move.b	#$a,$ff8800.l
	move.b	#0,$ff8802.l
	rts

l00b8
	tst.w	$58d54
	beq.s	l00b9
	clr.l	$58e84
	clr.w	$58e88
l00b9
	tst.b	$59807
	bne.s	l00ba
	subq.w	#1,$58c26
	bpl.s	l00ba
	bsr.s	l00b6
	move.b	#1,$59807
	move.w	#7,d0
	move.w	#1,d1
	movea.l	#$79298,a0
	move.l	#$5983d,d7
	bsr	l0286
	bsr	l0132
l00ba
	tst.b	$59806
	bne.s	l00bb
	subq.w	#1,$58c28
	beq.s	l00bc
	bsr	l0231
	andi.w	#$111,d0
	sub.w	d0,$ff8240.l
l00bb
	rts

l00bc
	clr.w	$ff8240.l
	move.b	#1,$59806
	move.w	#6,d0
	move.w	#1,d1
	movea.l	#$79288,a0
	move.l	#$5983d,d7
	bsr	l0286
	bsr	l0132
	rts

l00bd
	bsr	l0233
	cmpi.b	#$20,d0
	bne.s	l00c1
l00be
	btst	#7,$59818
	bne.s	l00be
	bsr	l00b7
l00bf
	bsr	l0233
	andi.b	#$5f,d0
	cmpi.b	#$51,d0
	beq.s	l00c3
	btst	#7,$59818
	beq.s	l00bf
l00c0
	bsr	l00b6
l00c1
	rts

	move.w	#1,$58ff0
	lea	$58fb4,a0
	move.w	$58fc6,d0
	asl.w	#1,d0
	move.w	#2,0(a0,d0.w)
	move.w	#4,$58fc4
l00c2
	bsr	l013c
	move.w	$58c54,d0
	lea	$58fcc,a0
	cmpi.b	#$19,0(a0,d0.w)
	blt	l00c2
	bra	l00c0
l00c3
	clr.l	$58fa4
	clr.w	$58fa8
	move.w	#-1,$58d4a
	rts

l00c4
	move.w	$58d8a,d0
	eori.w	#$f,d0
	move.w	d0,d5
	andi.l	#$c,d5
	swap	d5
	lsr.l	#3,d5
	movea.l	d5,a6
	andi.l	#3,d0
	asl.w	#3,d0
	adda.w	d0,a6
	asl.w	#1,d0
	adda.w	d0,a6
	adda.l	#$10000,a6
	movea.l	$58008,a5
	adda.w	#$2760,a5
	lea	$58458,a3
	move.w	$58c4e,d2
	move.w	d2,d0
	andi.w	#$10,d0
	lsr.w	#1,d0
	suba.w	d0,a5
	andi.w	#-$1f,d2
	lsr.w	#3,d2
	move.w	d2,$58c34
	clr.l	d6
	movea.l	$58978,a4
	move.w	#9,d6
l00c5
	move.w	#3,d7
l00c6
	clr.w	d0
	move.b	0(a4,d2.w),d0
	beq.s	l00c8
	andi.w	#$f,d0
	asl.w	#2,d0
	movea.l	d0,a0
	adda.l	#$58754,a0
	movea.l	(a0),a1
	adda.l	a6,a1
	movea.l	a5,a0
	move.l	a5,(a3)+
	move.l	#$17,d4
l00c7
	move.l	(a1)+,d1
	move.w	(a1),d0
	eori.w	#-1,d0
	and.w	d0,2(a0)
	or.w	d1,2(a0)
	swap	d1
	and.w	d0,(a0)
	or.w	d1,(a0)
	addq.w	#4,a1
	addq.w	#8,a0
	move.l	(a1)+,d1
	move.w	(a1),d0
	eori.w	#-1,d0
	and.w	d0,2(a0)
	or.w	d1,2(a0)
	swap	d1
	and.w	d0,(a0)
	or.w	d1,(a0)
	addq.w	#4,a1
	addq.w	#8,a0
	move.l	(a1)+,d1
	move.w	(a1),d0
	eori.w	#-1,d0
	and.w	d0,2(a0)
	or.w	d1,2(a0)
	swap	d1
	and.w	d0,(a0)
	or.w	d1,(a0)
	lea	$90(a0),a0
	lea	$8c(a1),a1
	dbf	d4,l00c7
l00c8
	lea	$f00(a5),a5
	addq.w	#1,d2
	dbf	d7,l00c6
	lea	-$3bf0(a5),a5
	dbf	d6,l00c5
l00c9
	cmpa.l	#$58494,a3
	bcc.s	l00ca
	move.l	#-1,(a3)+
	bra.s	l00c9
l00ca
	rts

l00cb
	move.w	#$770,$ff8252.l
	lea	$58b20,a0
	lea	$58b80,a1
	lea	$58bc0,a2
	bsr	l0231
	andi.w	#1,d0
	addq.w	#1,d0
	move.w	d0,d6
	tst.w	$58d88
	bpl.s	l00cd
l00cc
	move.w	$58bb0,d1
	subi.w	#$c8,d1
	cmpi.w	#$8c,d1
	bmi.s	l00cd
	bra.s	l00ce
l00cd
	move.w	$58bb0,d1
	addi.w	#$12c,d1
	cmpi.w	#$5dc,d1
	bpl.s	l00cc
	neg.w	d6
l00ce
	move.w	$58c2c,d0
	andi.w	#$ff,d0
	cmpi.w	#2,d0
	blt.s	l00d0
	asl.w	#2,d0
	lea	$58770,a5
	move.l	0(a5,d0.w),d3
	move.l	$30(a5,d0.w),d4
	move.l	$60(a5,d0.w),d5
	movea.l	#$580f8,a5
	movea.l	#$583f8,a6
	move.w	#7,d0
l00cf
	move.l	d3,(a5)+
	move.l	d4,(a6)+
	add.w	d5,d4
	addq.w	#8,d3
	dbf	d0,l00cf
l00d0
	move.w	$58c46,d7
	subq.w	#1,d7
	bmi	l00e0
	move.w	#$69,$58d6a
l00d1
	bsr	l0231
	dc.b	2,'@',0,'?',6,'@',0,'<'
	move.w	d0,$20(a0)
	move.w	#-$64,(a0)
	clr.w	$20(a1)
	move.w	d6,(a1)
	tst.w	$58c2c
	beq	l00db
	bpl.s	l00d3
	clr.w	(a1)
	move.w	#9,$40(a0)
l00d2
	bsr	l0231
	bsr	l0231
	dc.b	2,'@',3,$ff,6,'@',0,$f0
	move.w	d0,d1
	sub.w	$58bb0,d0
	cmpi.w	#$140,d0
	bcs.s	l00d2
	movea.l	$58978,a5
	move.w	d1,d0
	andi.w	#-$1f,d0
	lsr.w	#3,d0
	tst.b	2(a5,d0.w)
	bne.s	l00d2
	tst.b	6(a5,d0.w)
	bne	l00d2
	bra	l00df
l00d3
	cmpi.w	#1,$58c2c
	beq	l00dc
	cmpi.w	#2,$58c2c
	bne.s	l00d4
	move.w	#-1,$58c1e
l00d4
	cmpi.w	#3,$58c2c
	bne.s	l00d5
	move.w	#1,$58c1e
l00d5
	bsr	l0231
	dc.b	2,'@',0,$1f,6,'@',0,'U'
	move.w	d0,$20(a0)
	cmpi.w	#6,$58c2c
	bpl.s	l00d6
	move.w	$58c1e,d0
	asl.w	#4,d0
	add.w	d0,$20(a0)
l00d6
	bsr	l0231
	dc.b	2,'@',0,7,6,'@',0,'8'
	move.w	d0,$40(a0)
	cmpi.w	#$a,$58c2c
	beq	l00da
	cmpi.w	#9,$58c2c
	beq	l00d9
	cmpi.w	#4,$58c2c
	bne	l00de
	bsr	l0231
	andi.w	#7,d0
	addq.w	#1,d0
	move.w	d0,$20(a1)
l00d7
	bsr	l0231
	andi.w	#2,d0
	addq.w	#2,d0
	tst.w	(a1)
	bpl.s	l00d8
	neg.w	d0
l00d8
	move.w	d0,(a1)
	bra.s	l00de
l00d9
	bsr	l0231
	andi.w	#3,d0
	move.w	d0,$20(a1)
	bsr	l0231
	bra	l00d7
l00da
	move.w	d7,d0
	asl.w	#2,d0
	addq.w	#1,d0
	move.w	d0,$c0(a0)
	bra	l00de
l00db
	clr.w	(a1)
	move.w	#9,$40(a0)
	bra.s	l00de
l00dc
	move.w	#$a,$40(a0)
	subq.w	#4,d1
	move.w	$58d6a,$20(a0)
	move.w	d7,$20(a1)
	tst.w	$58c1e
	bmi	l00dd
	sub.w	d7,$58d6a
	bra	l00de
l00dd
	neg.w	$20(a1)
	add.w	d7,$58d6a
l00de
	addi.w	#$12,d1
l00df
	move.w	d1,(a2)+
	addq.l	#2,a1
	addq.l	#2,a0
	dbf	d7,l00d1
l00e0
	rts

l00e1
	subq.w	#1,$58d4c
	bne	l00e7
	move.w	#2,$58d4c
	move.l	$5803c,d0
	addq.w	#8,d0
	cmpi.l	#$41c60,d0
	bcs.s	l00e2
	move.l	#$41c20,d0
l00e2
	move.l	d0,$5803c
	addi.w	#$aa0,d0
	move.l	d0,$5833c
	cmpi.b	#2,$59802
	beq.s	l00e5
	cmpi.l	#$e,$58518
	beq.s	l00e3
	move.l	$58098,d0
	addq.w	#8,d0
	cmpi.l	#$41ca0,d0
	bcs.s	l00e4
l00e3
	move.l	#$41c80,d0
l00e4
	move.l	d0,$58098
	addi.l	#$20,d0
	move.l	d0,$5809c
	addi.l	#$6e0,d0
	move.l	d0,$5839c
	subi.l	#$20,d0
	move.l	d0,$58398
l00e5
	move.l	$5801c,d0
	addq.w	#8,d0
	cmpi.l	#$40098,d0
	bcs.s	l00e6
	move.l	#$40078,d0
l00e6
	move.l	d0,$5801c
l00e7
	addq.w	#1,$58d6c
	tst.w	$58d68
	beq	l00e8
	cmpi.w	#$28,$58d6c
	bge	l00e9
l00e8
	tst.w	$58c46
	bne	l00f2
l00e9
	cmpi.w	#7,$58fc6
	beq	l00ea
	cmpi.w	#3,$58d7a
	beq	l00f2
l00ea
	tst.b	$59806
	beq	l00f2
	move.w	#-$14,$58d6c
	move.w	#8,$58c46
	tst.w	$58d68
	bne	l00ec
	tst.w	$58d5a
	bne	l00ef
	bsr	l00b6
	bsr	l0231
	andi.w	#2,d0
	subq.w	#1,d0
	move.w	d0,$58c1e
	bsr	l0231
	andi.w	#$f,d0
	add.w	$58fc6,d0
	cmpi.w	#9,d0
	bgt.s	l00eb
	move.w	#1,d0
	bra	l00f0
l00eb
	bsr	l0231
	andi.w	#7,d0
	cmp.w	$58c2c,d0
	beq.s	l00eb
	bra	l00f0
l00ec
	move.w	$58d26,d1
	lea	$58d28,a0
	addq.w	#2,$58d26
	cmpi.w	#$20,$58d26
	blt	l00ee
	bgt	l00ed
	move.w	#1,$58c46
	bra	l00ee
l00ed
	bsr	l025c
	clr.w	$58d26
	clr.w	d1
	addq.w	#1,$58d68
	addq.w	#2,$58d6e
l00ee
	move.w	0(a0,d1.w),d0
	move.w	$58d48,$58d88
	neg.w	$58d48
	neg.w	$58c1e
	bra	l00f0
l00ef
	move.w	#8,d0
	move.w	#$800,$58d5c
	move.w	#$46,$58d5e
	move.w	#$f,$58d62
l00f0
	move.w	d0,$58c2c
	clr.w	$58d5a
	tst.w	$58c48
	bne.s	l00f1
	move.b	#$60,$59044
	move.b	#$61,$59045
	move.w	#2,$58d58
	move.w	#$38,$58c48
	clr.w	$58d54
	move.l	$58e90,$58e84
	move.w	$58e94,$58e88
	move.l	#$5996f,d7
	bsr	l0286
l00f1
	bsr	l00cb
	bra	l011f
l00f2
	move.w	#7,d1
	lea	$58b2e,a2
	lea	$58454,a3
l00f3
	move.w	$40(a2),d6
	tst.w	d6
	bmi	l0122
	cmpi.w	#9,d6
	beq	l0114
	bcc.s	l00f4
	cmpi.w	#3,d6
	beq	l0114
	cmpi.w	#2,$58d4c
	bne	l0114
	subq.w	#1,d6
	move.w	d6,$40(a2)
	tst.w	$58d68
	bne	l0114
	clr.w	$60(a2)
	bra	l0114
l00f4
	cmpi.w	#$38,d6
	bcc	l00fb
	cmpi.w	#$2e,d6
	bcc	l010d
	cmpi.w	#$18,d6
	bcc.s	l00fa
	cmpi.w	#$16,d6
	bcc	l010c
	cmpi.w	#$e,d6
	bcs	l010e
	cmpi.w	#1,$58d4c
	bne.s	l00f6
	addq.w	#1,d6
	cmpi.w	#$12,d6
	bne.s	l00f5
	move.w	#$e,d6
	bra.s	l00f6
l00f5
	cmpi.w	#$16,d6
	bne.s	l00f6
	move.w	#$12,d6
l00f6
	clr.w	$60(a2)
	move.w	$20(a2),d0
	move.w	$80(a2),d4
	cmpi.w	#$a,d4
	bcs.s	l00f7
	move.w	#$a,d4
l00f7
	addq.w	#1,d4
	move.w	d4,$80(a2)
	lsr.w	#2,d4
	add.w	d4,d0
	cmpi.w	#$96,d0
	bcs.s	l00f9
	move.w	#$96,d0
	cmpi.w	#$12,d6
	bcs.s	l00f8
	move.w	#$2e,d6
	bra.s	l00f9
l00f8
	move.w	#$16,d6
l00f9
	move.w	d0,$20(a2)
	bra	l0113
l00fa
	clr.w	$60(a2)
	addq.w	#1,d6
	cmpi.w	#$20,d6
	bcs	l0113
	bra	l0121
l00fb
	cmpi.w	#1,$58d4c
	bne.s	l00fc
	addq.w	#1,d6
	andi.w	#7,d6
	addi.w	#$38,d6
l00fc
	cmpi.w	#4,$58c2c
	bcs	l0110
	beq	l0109
	cmpi.w	#9,$58c2c
	beq	l0109
	bcc	l0103
	cmpi.w	#5,$58c2c
	beq	l0107
	move.w	$e0(a2),d3
	subq.w	#1,$c0(a2)
	bpl.s	l0101
	move.w	#2,$c0(a2)
	addq.w	#1,d3
	andi.w	#$f,d3
	bne.s	l00ff
	cmpi.w	#8,$58c2c
	bne.s	l00fe
	move.w	#$a,$c0(a2)
	move.w	#2,$60(a2)
	move.w	$58bb0,d0
	addi.w	#$96,d0
	cmp.w	$a0(a2),d0
	bcc.s	l00fd
	neg.w	$60(a2)
l00fd
	bsr	l0135
l00fe
	bsr	l0136
l00ff
	cmpi.w	#$b,$58c2c
	beq	l0100
	cmpi.w	#7,$58c2c
	bne.s	l0101
l0100
	bsr	l0231
	cmpi.b	#-$24,d0
	bcs.s	l0101
	andi.w	#$f,d0
	move.w	d0,d3
l0101
	move.w	d3,$e0(a2)
	asl.w	#1,d3
	lea	$58c56,a0
	move.w	0(a0,d3.w),d7
	tst.w	$60(a2)
	bpl.s	l0102
	neg.w	d7
l0102
	add.w	d7,$a0(a2)
	move.w	$20(a0,d3.w),d7
	add.w	d7,$20(a2)
	bra	l0109
l0103
	tst.w	$c0(a2)
	bne	l0104
	bra	l0109
l0104
	subq.w	#1,$c0(a2)
	bne	l011e
	bsr	l0231
	dc.b	2,'@',0,$ff,6,'@',0,' '
	move.w	#2,$60(a2)
	cmpi.w	#$9b,d0
	bmi	l0105
	neg.w	$60(a2)
l0105
	add.w	$58bb0,d0
	move.w	d0,$a0(a2)
	move.w	#$9b,$20(a2)
	move.w	#-2,$80(a2)
	bsr	l0231
	andi.w	#1,d0
	beq	l0106
	move.w	#$32,$20(a2)
	move.w	#1,$80(a2)
l0106
	bra	l0109
l0107
	subq.w	#1,$c0(a2)
	bpl.s	l0109
	move.w	#$c,$c0(a2)
	bsr	l0136
	bsr	l0231
	andi.w	#1,d0
	beq.s	l0108
	clr.w	$80(a2)
	bsr	l0231
	andi.w	#4,d0
	subq.w	#2,d0
	add.w	$58c1e,d0
	move.w	d0,$60(a2)
	bra.s	l0109
l0108
	clr.w	$60(a2)
	bsr	l0231
	andi.w	#4,d0
	subq.w	#2,d0
	move.w	d0,$80(a2)
l0109
	move.w	$20(a2),d0
	move.w	$80(a2),d4
	add.w	d4,d0
	cmpi.w	#$3a,d0
	bcs.s	l010a
	cmpi.w	#$96,d0
	bcs.s	l010b
	move.w	#$96,d0
	neg.w	d4
	bra.s	l010b
l010a
	move.w	#$3b,d0
	neg.w	d4
l010b
	move.w	d0,$20(a2)
	move.w	d4,$80(a2)
	bra.s	l0113
l010c
	cmpi.w	#1,$58d4c
	bne.s	l0113
	addq.w	#1,d6
	cmpi.w	#$18,d6
	bne.s	l0113
	bra	l0121
l010d
	cmpi.w	#1,$58d4c
	bne.s	l0113
	addq.w	#1,d6
	cmpi.w	#$30,d6
	bne.s	l0113
	bra	l0121
l010e
	cmpi.w	#2,$58d4c
	bne.s	l0110
	tst.w	d4
	bpl.s	l010f
	addq.w	#1,d6
	cmpi.w	#$e,d6
	bcs.s	l0110
l010f
	move.w	#$a,d6
l0110
	move.w	$20(a2),d0
	move.w	$80(a2),d4
	add.w	$58c1e,d4
	move.w	d4,d5
	add.w	d4,d0
	cmpi.w	#$3a,d0
	bcs.s	l0111
	cmpi.w	#$92,d0
	bcs.s	l0112
	move.w	#$92,d0
	neg.w	d4
	subq.w	#1,d4
	bra.s	l0112
l0111
	move.w	#$3b,d0
	neg.w	d4
l0112
	move.w	d0,$20(a2)
	move.w	d4,$80(a2)
l0113
	move.w	d6,$40(a2)
l0114
	move.w	$a0(a2),d0
	add.w	$60(a2),d0
	bmi	l0115
	cmpi.w	#$73a,d0
	bmi	l0116
	clr.w	d0
	bra.s	l0116
l0115
	move.w	#$730,d0
l0116
	move.w	d0,$a0(a2)
	sub.w	$58c4e,d0
	move.w	d0,(a2)
	cmpi.w	#$12c,d0
	bcc	l0120
	clr.w	$58d6c
	cmpi.w	#9,d6
	bcs.s	l0117
	tst.b	$59806
	beq	l011c
l0117
	sub.w	$58b10,d0
	addi.w	#$10,d0
	cmpi.w	#$1c,d0
	bcc	l011d
	move.w	$20(a2),d0
	sub.w	$58b30,d0
	addi.w	#$10,d0
	cmpi.w	#$20,d0
	bcc	l011d
	cmpi.w	#9,d6
	bcs.s	l0119
	beq.s	l0118
	cmpi.w	#$38,d6
	bcc.s	l0118
	cmpi.w	#$e,d6
	bcc.s	l011d
l0118
	move.w	d6,d0
	bsr	l01f8
	move.w	d0,$40(a2)
	move.w	#1,$58d4a
	bra.s	l011d
l0119
	tst.w	$58d8c
	beq.s	l011a
	bsr	l0128
l011a
	addi.l	#$10,$58808
	addq.w	#1,$58d8c
	cmpi.w	#8,$58d8c
	bcs.s	l011b
	move.w	#1,$58d8c
	move.l	#$79238,$58808
l011b
	bsr.s	l0123
	lea	$58fa8,a0
	bsr	l024a
	move.l	#$59825,d7
	bsr	l0286
	bra.s	l0121
l011c
	cmpi.w	#$a,$58c2c
	beq	l0117
	move.w	d6,d0
	bsr	l01f8
	move.w	d0,$40(a2)
l011d
	move.w	d1,d0
	addq.w	#8,d0
	bsr	l01d9
l011e
	subq.l	#2,a2
	subq.l	#4,a3
	dbf	d1,l00f3
l011f
	rts

l0120
	cmpi.w	#9,d6
	bcc.s	l0122
l0121
	move.w	#-1,$40(a2)
	subq.w	#1,$58c46
	bsr	l0254
l0122
	move.l	#-1,(a3)
	bra.s	l011e
l0123
	tst.w	$58d8c
	beq	l0125
	movea.l	$58808,a0
	move.w	#$16,d0
l0124
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	lea	$90(a0),a0
	dbf	d0,l0124
l0125
	rts

l0126
	move.l	$589a0,d0
	andi.l	#$7fff,d0
	add.l	$58008,d0
	movea.l	d0,a0
	bra.s	l0129
l0127
	move.l	$58808,d0
	eori.l	#$8000,d0
	movea.l	d0,a0
	bsr.s	l0129
l0128
	movea.l	$58808,a0
	move.l	a0,d0
	eori.l	#$8000,d0
	movea.l	d0,a4
l0129
	move.w	#$16,d0
l012a
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	lea	$90(a0),a0
	lea	$90(a4),a4
	dbf	d0,l012a
	rts

l012b
	lea	$58fac,a5
	bra.s	l012d
l012c
	lea	$59800,a5
l012d
	movea.l	$58008,a6
	adda.l	#$1228,a6
	move.w	#1,d7
l012e
	move.w	d7,d0
	move.b	0(a5,d0.w),d1
	bsr.s	l012f
	adda.w	#$10,a6
	movea.l	a6,a0
	bsr.s	l0129
	addq.w	#1,d7
	cmpi.w	#8,d7
	bne.s	l012e
	rts

l012f
	movea.l	#$46030,a4
	asl.w	#4,d0
	adda.w	d0,a4
	tst.b	d1
	bne.s	l0130
	movea.l	#$43b60,a4
	bra.s	l0131
l0130
	andi.b	#1,d1
	beq.s	l0131
	adda.l	#$e60,a4
l0131
	rts

l0132
	cmp.w	$58d8c,d0
	beq	l0134
	bsr.s	l012f
	movea.l	a4,a5
	movea.l	a0,a6
	bsr	l0129
	movea.l	a5,a4
	movea.l	a6,a0
l0133
	move.l	a0,d0
	eori.l	#$8000,d0
	movea.l	d0,a0
	bra	l0129
l0134
	bsr	l012f
	bra	l0133
l0135
	movem.l	a0/d0,-(a7)
	bra	l0137
l0136
	movem.l	a0/d0,-(a7)
	bsr	l0231
	andi.w	#$3f,d0
	add.w	$58fc6,d0
	cmpi.b	#$3c,d0
	bmi	l013b
l0137
	lea	$58ca2,a0
	move.w	#1,d0
l0138
	tst.w	(a0)
	bmi.s	l0139
	addq.w	#2,a0
	dbf	d0,l0138
	bra.s	l013b
l0139
	move.w	(a2),d0
	addq.w	#6,d0
	move.w	d0,(a0)
	move.w	$58d6e,$20(a0)
	cmp.w	$58b10,d0
	ble	l013a
	neg.w	$20(a0)
l013a
	move.w	$20(a2),d0
	addi.w	#7,d0
	move.w	d0,$10(a0)
	move.w	#4,$30(a0)
	cmp.w	$58b30,d0
	ble	l013b
	neg.w	$30(a0)
l013b
	movem.l	(a7)+,a0/d0
	rts

l013c
	move.w	$58c54,d0
	lea	$58fcc,a0
	move.w	d0,d1
	asl.w	#5,d1
	move.w	d1,d6
	move.b	0(a0,d0.w),d1
	cmpi.b	#$19,d1
	bcc.s	l013e
	bsr.s	l013f
	move.w	$58c54,d0
	lea	$58fcc,a0
	lea	$588b4,a1
	move.b	0(a0,d0.w),d1
	cmp.b	0(a1,d0.w),d1
	bgt.s	l013e
	move.w	#3,d0
	lea	$58fcc,a0
	move.b	0(a0,d0.w),d1
	cmpi.b	#$18,d1
	bcs.s	l013d
	move.w	#3,$58d4a
l013d
	move.w	#$120,d6
	bsr.s	l013f
l013e
	rts

l013f
	addq.b	#1,d1
	move.b	d1,0(a0,d0.w)
	move.w	#$c6,d7
	sub.b	d1,d7
	asl.w	#2,d0
	lea	$580bc,a2
	subi.l	#$a0,0(a2,d0.w)
	movea.l	0(a2,d0.w),a1
l0140
	bsr	l0239
	move.l	(a1),(a0)
	move.l	4(a1),4(a0)
	move.l	8(a1),8(a0)
	move.l	$c(a1),$c(a0)
	cmpi.l	#$38000,$58008
	beq	l0141
	exg	a0,d0
	eori.l	#$8000,d0
	exg	a0,d0
	move.l	(a1),(a0)
	move.l	4(a1),4(a0)
	move.l	8(a1),8(a0)
	move.l	$c(a1),$c(a0)
l0141
	rts

l0142
	clr.w	d0
	lea	$58fcc,a0
	lea	$588b4,a2
l0143
	tst.b	0(a2,d0.w)
	bne.s	l0144
	addq.w	#1,d0
	cmpi.w	#3,d0
	bcs.s	l0143
	bra.s	l0145
l0144
	subq.b	#1,0(a2,d0.w)
	move.b	0(a0,d0.w),d1
	subq.b	#1,0(a0,d0.w)
	move.w	d0,d3
	asl.w	#5,d3
	move.w	d3,d6
	bsr.s	l0146
	lea	$58fcc,a0
	move.w	#3,d0
	move.b	0(a0,d0.w),d1
	move.w	#$120,d6
	subq.b	#1,0(a0,d0.w)
	bsr.s	l0146
l0145
	rts

l0146
	move.w	#$c6,d7
	sub.b	d1,d7
	asl.w	#2,d0
	lea	$580bc,a2
	movea.l	0(a2,d0.w),a1
	addi.l	#$a0,0(a2,d0.w)
	asl.w	#2,d0
	suba.w	d0,a1
	suba.w	#$10,a1
	bra	l0140
l0147
	movea.l	$58008,a0
	adda.w	#$2398,a0
	move.w	#$68,d0
l0148
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	lea	$90(a0),a0
	dbf	d0,l0148
	rts

l0149
	move.l	#$38000,$58008
	bsr	l014e
	bsr	l019a
	bsr	l014b
	move.w	#$10,$58b10
	move.w	#$23,$58b50
	move.w	#$8b,$58b30
	move.w	#$11,d5
l014a
	bsr	l01d8
	addi.w	#$10,$58b10
	dbf	d5,l014a
	move.w	#2,$58c36
	bsr	l0251
	rts

l014b
	lea	$589a8,a0
	lea	$589fc,a1
	lea	$58a50,a2
	lea	$58a90,a3
	lea	$58ad0,a4
	move.w	#$24,$58b50
	move.w	$58fc6,d1
	asl.w	#3,d1
	move.w	#3,d7
l014c
	move.w	0(a2,d1.w),d0
	tst.w	d0
	bmi	l014d
	asl.w	#2,d0
	move.w	0(a3,d1.w),$58b10
	move.w	0(a4,d1.w),$58b30
	move.l	0(a0,d0.w),$580a8
	move.w	0(a1,d0.w),$582aa
	move.w	2(a1,d0.w),$581aa
	bsr	l01d8
	addq.w	#2,d1
	dbf	d7,l014c
l014d
	rts

l014e
	movea.l	$58008,a0
	adda.l	#$2080,a0
	move.w	#$12bf,d0
l014f
	clr.l	(a0)+
	dbf	d0,l014f
	rts

l0150
	movea.l	$58008,a0
	move.w	#$1f40,d0
l0151
	clr.l	(a0)+
	dbf	d0,l0151
	rts

l0152
	cmpi.w	#$e,$58c3c
	bcc	l0173
	addq.w	#1,$58d90
	tst.w	$58d82
	beq.s	l0154
	bmi.s	l0153
	move.w	#1,$58c42
	bra.s	l0154
l0153
	clr.w	$58c42
l0154
	move.w	$58d84,$58d86
	move.b	$59818,d7
	tst.b	$59803
	bne.s	l0155
	tst.w	$58c2e
	bne.s	l0155
	cmpi.w	#6,$58d94
	bpl.s	l0156
l0155
	btst	#2,d7
	bne.s	l0157
	btst	#3,d7
	bne.s	l0158
l0156
	tst.b	$59801
	bne.s	l0159
	tst.w	$58d84
	beq.s	l0159
	bmi.s	l0158
l0157
	subq.w	#1,$58d84
	cmpi.w	#-$14,$58d84
	bpl.s	l0159
	move.w	#-$14,$58d84
	bra.s	l0159
l0158
	addq.w	#1,$58d84
	cmpi.w	#$14,$58d84
	bmi.s	l0159
	move.w	#$14,$58d84
l0159
	move.w	$58d84,d0
	addi.w	#$1c,d0
	lsr.w	#2,d0
	subi.w	#7,d0
	move.w	d0,$58d82
	add.w	$58d50,d0
	andi.l	#$3f,d0
	move.w	d0,$58d50
	asl.w	#1,d0
	andi.w	#$f8,d0
	addi.l	#$412c0,d0
	move.l	d0,$58020
	move.w	$58b30,d1
	move.w	d1,$58c50
	cmpi.b	#2,$59801
	bcc.s	l015a
	move.w	$58d82,d0
	move.w	d0,$58d88
l015a
	tst.b	$59801
	bne.s	l0162
	move.w	$58b90,d2
	tst.b	$59803
	bne.s	l015b
	cmpi.w	#6,$58d94
	bpl.s	l015c
l015b
	btst	#0,d7
	bne.s	l015e
	btst	#1,d7
	bne.s	l015d
l015c
	cmpi.w	#0,d2
	beq.s	l015f
	bpl.s	l015e
l015d
	addq.w	#1,d2
	cmpi.w	#5,d2
	bmi.s	l015f
	move.w	#5,d2
	bra.s	l015f
l015e
	subq.w	#1,d2
	cmpi.w	#-5,d2
	bpl.s	l015f
	move.w	#-5,d2
l015f
	move.w	d2,$58b90
	add.w	d2,d1
	cmpi.w	#$3a,d1
	bcc.s	l0160
	move.w	#$3a,d1
l0160
	cmpi.w	#$91,d1
	bcs.s	l0161
	move.w	#$91,d1
l0161
	move.w	d1,$58b30
	bra.s	l0164
l0162
	move.w	$58b90,d0
	addq.w	#1,d0
	move.w	$58d4e,d1
	move.w	d1,$58c52
	add.w	d0,d1
	cmpi.w	#$230,d1
	bcs.s	l0163
	move.w	#$230,d1
	move.w	#-$19,d0
	move.w	$58d82,d2
	move.w	d2,$58d88
l0163
	move.w	d0,$58b90
	move.w	d1,$58d4e
	lsr.w	#2,d1
	move.w	d1,$58b30
l0164
	move.w	$58b30,d7
	move.w	$58b10,d6
	bsr	l0239
	move.l	a0,$58418
	move.l	(a0),$5889c
	move.l	$280(a0),$588a0
	move.l	$500(a0),$588a4
	move.l	$780(a0),$588a8
	move.l	$960(a0),$588ac
	tst.w	$58c4a
	beq.s	l0165
	subq.w	#1,$58c4a
l0165
	btst	#7,$59818
	beq	l016c
	addq.w	#1,$58d94
	move.b	$59805,d0
	andi.w	#1,d0
	beq	l0166
	lea	$58b10,a1
	bsr	l0193
l0166
	tst.w	$58c4a
	bne	l016b
	lea	$58c96,a0
	move.w	#1,d0
	sub.b	$59804,d0
l0167
	tst.w	(a0)
	bmi.s	l0168
	addq.w	#2,a0
	dbf	d0,l0167
	bra.s	l016b
l0168
	move.w	#4,$58c4a
	lea	$58b10,a1
	move.w	$20(a1),d0
	addi.w	#7,d0
	move.w	d0,$10(a0)
	clr.w	$30(a0)
	move.l	#$59873,d7
	bsr	l0286
	move.w	(a1),d0
	addq.w	#6,d0
	move.w	d0,(a0)
	move.w	#$a,$20(a0)
	tst.b	$59802
	bne.s	l0169
	move.w	$58c3e,d0
	eori.w	#1,d0
	move.w	d0,$58c3e
	bne.s	l016a
	bra.s	l016b
l0169
	move.w	$58c42,$58c3e
	tst.w	$58c42
	bne.s	l016b
l016a
	neg.w	$20(a0)
	nop
l016b
	bra.s	l016d
l016c
	clr.w	$58d94
l016d
	cmpi.w	#5,$58d92
	bcs	l0173
	tst.w	$58d8c
	beq	l0173
	lea	$59800,a0
	move.w	$58d8c,d0
	move.b	0(a0,d0.w),d1
	tst.b	d1
	beq	l0173
	subq.b	#1,d1
	move.b	d1,0(a0,d0.w)
	bne.s	l016f
	cmpi.w	#1,d0
	bne.s	l016e
	clr.w	$58b90
l016e
	move.l	#$43ba0,$589a4
	bra.s	l0170
l016f
	move.l	#$43b60,$589a4
l0170
	cmpi.w	#6,d0
	bne.s	l0171
	move.w	#-$6667,d7
	bsr	l0286
	move.w	#$28,$58c28
	bsr	l0231
	dc.b	2,'@',3,'3',6,'@',4,'D'
	move.w	d0,$ff8240.l
	move.w	#6,d0
	bra.s	l0172
l0171
	cmpi.w	#7,d0
	bne.s	l0172
	move.w	#$320,$58c26
	move.w	#7,d0
l0172
	bsr	l012f
	move.l	a4,$5899c
	move.l	$58808,$589a0
	move.w	#6,$58d96
	clr.w	$58d92
	move.l	#$5983d,d7
	bsr	l0286
	clr.w	$58d8c
	move.l	#$79228,$58808
l0173
	rts

l0174
	movem.l	a0-a2/d0-d1,-(a7)
	tst.b	$59803
	bne	l0191
	tst.w	$58d52
	beq.s	l0175
	bsr	l0231
	andi.w	#$f,d0
	move.w	d0,d7
	bra.s	l0177
l0175
	tst.w	$58c2e
	beq.s	l0176
	move.b	$59817,d7
	bra.s	l0177
l0176
	move.b	$59818,d7
	cmpi.w	#$a,$58d94
	bmi.s	l017c
l0177
	move.b	d7,d0
	andi.b	#$f,d0
	beq.s	l017c
	move.w	$58b12,d1
	move.w	$58b32,d2
	btst	#1,d7
	beq.s	l0178
	cmpi.w	#$96,d2
	bcc.s	l0179
	addq.w	#4,d2
l0178
	btst	#0,d7
	beq.s	l0179
	cmpi.w	#$38,d2
	bcs.s	l0179
	subq.w	#4,d2
l0179
	btst	#3,d7
	beq.s	l017a
	move.w	#1,$58c44
	cmpi.w	#$11c,d1
	bcc.s	l017b
	addq.w	#4,d1
l017a
	btst	#2,d7
	beq.s	l017b
	clr.w	$58c44
	cmpi.w	#$14,d1
	bcs.s	l017b
	subq.w	#4,d1
l017b
	move.w	d1,$58b12
	move.w	d2,$58b32
	bra	l0182
l017c
	move.w	$58c42,$58c44
	move.w	$58b32,d0
	sub.w	$58b30,d0
	subq.w	#2,d0
	beq.s	l017e
	bmi.s	l017d
	lsr.w	#2,d0
	addq.w	#1,d0
	sub.w	d0,$58b32
	bra.s	l017e
l017d
	neg.w	d0
	lsr.w	#2,d0
	addq.w	#1,d0
	add.w	d0,$58b32
l017e
	move.w	$58b10,d0
	subi.w	#$14,d0
	tst.w	$58c42
	bne	l017f
	addi.w	#$28,d0
l017f
	cmp.w	$58b12,d0
	beq	l0182
	move.w	d0,d1
	sub.w	$58b12,d0
	cmpi.w	#4,d0
	bgt	l0180
	cmpi.w	#-4,d0
	blt	l0181
	move.w	d1,$58b12
	bra	l0182
l0180
	addq.w	#4,$58b12
	bra	l0182
l0181
	subq.w	#4,$58b12
l0182
	move.w	#1,d0
	bsr	l01d9
	btst	#7,d7
	beq	l0186
	move.b	$59805,d0
	cmpi.b	#-2,d0
	beq	l0183
	andi.w	#1,d0
	bne	l0183
	lea	$58b12,a1
	bsr	l0193
l0183
	tst.w	$58c9a
	bpl	l0186
	move.w	$58b32,d0
	addi.w	#5,d0
	move.w	d0,$58caa
	clr.w	$58cca
	move.l	#$59873,d7
	bsr	l0286
	move.w	$58b12,d0
	addq.w	#6,d0
	move.w	d0,$58c9a
	move.w	#$a,$58cba
	tst.b	$59802
	bne	l0184
	move.w	$58c40,d0
	eori.w	#1,d0
	move.w	d0,$58c40
	bne.s	l0185
	bra.s	l0186
l0184
	move.w	$58c44,$58c40
	tst.w	$58c44
	bne.s	l0186
l0185
	neg.w	$58cba
l0186
	lea	$58b20,a0
	move.w	#7,d1
l0187
	move.w	$40(a0),d6
	cmpi.w	#9,d6
	bmi	l0190
	move.w	(a0),d0
	sub.w	$58b12,d0
	addi.w	#$10,d0
	cmpi.w	#$20,d0
	bcc	l0190
	move.w	$20(a0),d0
	sub.w	$58b32,d0
	addi.w	#8,d0
	cmpi.w	#$18,d0
	bcc	l0190
	move.w	d6,d0
	cmpi.w	#$16,d0
	bcc	l018f
	cmpi.w	#$e,d0
	bcs	l018f
	move.w	#-1,$40(a0)
	cmpi.w	#$12,d0
	bcs.s	l018d
	tst.w	$58c1c
	bne.s	l0188
	bsr	l025c
l0188
	cmpi.w	#1,$58c1c
	bne.s	l0189
	move.w	#$7f,$58c38
l0189
	cmpi.w	#2,$58c1c
	bne.s	l018a
	move.w	#1,$58d54
l018a
	cmpi.w	#3,$58c1c
	bne.s	l018b
	move.w	#1,$58d52
l018b
	cmpi.w	#4,$58c1c
	bne.s	l018c
	move.w	#1,$58d5a
l018c
	bra.s	l018e
l018d
	bsr	l013c
l018e
	subq.w	#1,$58c46
	bsr	l0254
	movea.l	#$58fa8,a0
	bsr	l024a
	movea.l	#$58fa9,a0
	move.w	#5,d0
	bsr	l024b
	bra.s	l0191
l018f
	move.w	$40(a0),d0
	bsr	l01f8
	cmp.w	$40(a0),d0
	beq.s	l0190
	move.w	d0,$40(a0)
	tst.b	$59807
	beq.s	l0190
	move.w	#-$66af,d7
	bsr	l0286
	subq.w	#1,$58c38
	bne.s	l0190
	bsr	l0192
	bra.s	l0191
l0190
	addq.w	#2,a0
	dbf	d1,l0187
l0191
	movem.l	(a7)+,a0-a2/d0-d1
	rts

l0192
	move.b	#1,$59803
	move.w	#3,d0
	move.w	#1,d1
	movea.l	#$79258,a0
	bsr	l0132
	clr.w	$58d52
	move.w	#$c,$58c38
	clr.w	$58b12
	move.w	#$37,$58b32
	rts

l0193
	lea	$58c9c,a0
	tst.w	(a0)
	bpl	l0196
	tst.w	2(a0)
	bpl	l0196
	tst.w	4(a0)
	bpl	l0196
	eori.w	#1,$58d66
	move.w	#-4,d1
l0194
	move.w	(a1),d0
	addi.w	#6,d0
	move.w	d0,(a0)
	move.w	#-6,$30(a0)
	move.w	$20(a1),d0
	subq.w	#2,d0
	tst.w	$58d66
	beq	l0195
	addi.w	#$e,d0
	neg.w	$30(a0)
l0195
	move.w	d0,$10(a0)
	move.w	d1,$20(a0)
	addq.w	#2,a0
	addq.w	#4,d1
	cmpi.w	#8,d1
	bne	l0194
	move.l	#$59873,d7
	bsr	l0286
l0196
	rts

l0197
	move.w	$58b10,d0
	add.w	$58d88,d0
	cmpi.w	#$11e,d0
	ble	l0198
	move.w	#$11e,d0
l0198
	cmpi.w	#$10,d0
	bge	l0199
	move.w	#$10,d0
l0199
	move.w	d0,$58b10
	move.w	#$1f4,$58bb0
	move.w	#$1f4,$58c4e
	move.w	#$1f4,$58c4c
	rts

l019a
	move.l	$58894,-(a7)
	move.l	#$23456789,$58894
	clr.w	$58c1a
	move.w	#$1e,$58d70
l019b
	bsr	l01a0
	subq.w	#1,$58d70
	bne	l019b
	move.l	(a7)+,$58894
	rts

l019c
	addq.w	#1,$58c1a
	bsr	l019e
	subq.w	#1,$58c1a
	rts

l019d
	subq.w	#1,$58c1a
l019e
	move.w	#$c,$58d70
	move.l	$58894,-(a7)
l019f
	move.l	#$3456789a,$58894
	bsr	l01a0
	subq.w	#1,$58d70
	bne	l019b
	move.l	(a7)+,$58894
	rts

l01a0
	bsr	l0231
	andi.w	#$ff,d0
	move.w	d0,d6
	bsr	l0231
	andi.w	#$7f,d0
	add.w	d0,d6
	add.w	$58c1a,d6
l01a1
	bsr	l0231
	dc.b	2,'@',0,$7f,6,'@',0,'<'
	cmpi.w	#$a0,d0
	bcc	l01a1
	move.w	d0,d7
	bsr	l0239
	clr.w	d1
	eori.w	#$f,d0
	bset	d0,d1
	eor.w	d1,2(a0)
	bsr	l0231
	btst	#1,d0
	beq	l01a2
	eor.w	d1,(a0)
l01a2
	rts

l01a3
	tst.w	$58d96
	beq.s	l01a6
	subq.w	#1,$58d96
	cmpi.w	#2,$58d96
	bcc.s	l01a4
	movea.l	$5899c,a4
	bra.s	l01a5
l01a4
	addi.l	#$10,$589a4
	movea.l	$589a4,a4
l01a5
	bsr	l0126
l01a6
	rts

l01a7
	clr.l	d0
	move.w	$58bb0,d3
	asr.w	#1,d3
	move.w	d3,d2
	asr.w	#1,d2
	move.w	d2,d4
	movea.l	#$40140,a0
	movea.l	$58008,a2
	adda.w	#$5828,a2
	move.w	#0,d1
	bsr.s	l01a8
	move.w	d3,d2
	move.w	#1,d1
	bsr.s	l01a8
	add.w	d4,d2
	move.w	#1,d1
	bsr.s	l01a8
	move.w	$58d8a,d2
	move.w	#2,d1
	bsr.s	l01a8
	adda.w	#$820,a2
	adda.w	#$820,a0
	add.w	d3,d2
	move.w	#5,d1
	bsr.s	l01a8
	rts

l01a8
	andi.w	#$f,d2
l01a9
	move.w	(a0),d6
	rol.w	d2,d6
	swap	d6
	move.w	2(a0),d7
	rol.w	d2,d7
	move.w	d7,d6
	move.l	#$11,d0
l01aa
	move.l	d6,(a2)+
	addq.w	#4,a2
	dbf	d0,l01aa
	lea	$10(a2),a2
	lea	$a0(a0),a0
	dbf	d1,l01a9
	rts

l01ab
	lea	$58458,a6
l01ac
	movea.l	(a6)+,a0
	cmpa.l	#0,a0
	bmi.s	l01ae
	move.w	#5,d4
	move.l	a0,d0
	andi.l	#$7fff,d0
	addi.l	#$38000,d0
	movea.l	d0,a1
l01ad
	move.l	(a1),(a0)
	move.l	8(a1),8(a0)
	move.l	$10(a1),$10(a0)
	lea	$a0(a0),a0
	lea	$a0(a1),a1
	move.l	(a1),(a0)
	move.l	8(a1),8(a0)
	move.l	$10(a1),$10(a0)
	lea	$a0(a0),a0
	lea	$a0(a1),a1
	move.l	(a1),(a0)
	move.l	8(a1),8(a0)
	move.l	$10(a1),$10(a0)
	lea	$a0(a0),a0
	lea	$a0(a1),a1
	move.l	(a1),(a0)
	move.l	8(a1),8(a0)
	move.l	$10(a1),$10(a0)
	lea	$a0(a0),a0
	lea	$a0(a1),a1
	dbf	d4,l01ad
	bra.s	l01ac
l01ae
	rts

l01af
	lea	$58418,a6
	bra	l01b1
l01b0
	lea	$5841c,a6
l01b1
	movea.l	(a6)+,a0
	cmpa.l	#0,a0
	bmi.s	l01b3
	move.w	#$10,d4
	move.l	a0,d0
	andi.l	#$7fff,d0
	addi.l	#$38000,d0
	movea.l	d0,a1
l01b2
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1),(a0)
	lea	$94(a0),a0
	lea	$94(a1),a1
	dbf	d4,l01b2
l01b3
	cmpa.l	#$58458,a6
	bcs.s	l01b1
	rts

l01b4
	lea	$58418,a6
l01b5
	move.l	$100(a6),d4
	movea.l	(a6)+,a0
	move.l	a0,d0
	tst.l	d0
	bmi.s	l01b8
	andi.l	#$7fff,d0
	addi.l	#$38000,d0
	movea.l	d0,a1
l01b6
	movea.l	a1,a3
	movea.l	a0,a2
	move.w	#$b,d3
	asr.w	#1,d3
l01b7
	move.l	(a3)+,(a2)+
	dbf	d3,l01b7
	lea	$a0(a0),a0
	lea	$a0(a1),a1
	dbf	d4,l01b6
l01b8
	cmpa.l	#$58458,a6
	bcs.s	l01b5
	rts

l01b9
	clr.l	d0
	movem.l	a0-a5/d0-d7,-(a7)
	lea	$58b10,a3
	move.w	(a3),d6
	move.w	$20(a3),d7
	move.w	$40(a3),d0
	tst.w	d0
	bmi	l01bd
	asl.w	#2,d0
	movea.l	d0,a0
	adda.l	#$58018,a0
	movea.l	(a0),a1
	move.l	#1,d3
	move.l	#$c7,d4
	bsr	l0239
l01ba
	move.w	d3,d1
	movea.l	a0,a3
	movea.l	a1,a4
l01bb
	clr.l	d6
	move.w	(a4)+,d6
	ror.l	d0,d6
	move.l	d6,d5
	or.w	d6,(a3)+
	swap	d6
	or.w	d6,6(a3)
	clr.l	d6
	move.w	(a4)+,d6
	ror.l	d0,d6
	or.l	d6,d5
	or.w	d6,(a3)+
	swap	d6
	or.w	d6,6(a3)
	clr.l	d6
	move.w	(a4)+,d6
	ror.l	d0,d6
	or.l	d5,d6
	or.w	d6,(a3)+
	swap	d6
	or.w	d6,6(a3)
	addq.w	#2,a3
	addq.w	#2,a4
	dbf	d1,l01bb
	lea	$a0(a0),a0
	lea	$a0(a1),a1
	dbf	d4,l01ba
l01bc
	movem.l	(a7)+,a0-a5/d0-d7
	rts

l01bd
	move.l	#-1,(a4)
	bra.s	l01bc
l01be
	cmpi.w	#$e,$58c3c
	bcc	l01cd
	movea.l	$58418,a0
	move.l	$960(a0),d0
	move.l	$588ac,d1
	eor.l	d1,d0
	andi.l	#$3c003c0,d0
	bne.s	l01bf
	move.l	$588a4,d0
	move.l	$500(a0),d1
	eor.l	d1,d0
	move.l	d0,d1
	andi.l	#-$ff0100,d0
	bne	l01c2
	andi.l	#$ff00ff,d1
	bne	l01c3
	move.l	(a0),d0
	move.l	$5889c,d1
	eor.l	d1,d0
	andi.l	#$3c003c0,d0
	bne	l01c4
	move.l	$280(a0),d0
	move.l	$588a0,d1
	eor.l	d1,d0
	move.l	d0,d1
	andi.l	#-$ff0100,d0
	bne	l01c2
	andi.l	#$ff00ff,d1
	bne	l01c3
	move.l	$780(a0),d0
	move.l	$588a8,d1
	eor.l	d1,d0
	move.l	d0,d1
	andi.l	#-$ff0100,d0
	bne.s	l01c2
	andi.l	#$ff00ff,d1
	bne	l01c3
	bra	l01c8
l01bf
	tst.w	$58b90
	ble.s	l01c1
	move.w	$58bb0,d2
	andi.w	#$1f,d2
	cmpi.w	#$1d,d2
	bcc.s	l01c1
	cmpi.w	#$10,d2
	bcs.s	l01c1
	move.w	$58c34,d2
	movea.l	$58978,a6
	move.w	$58b30,d0
	subi.w	#$29,d0
l01c0
	addq.w	#1,d2
	subi.w	#$18,d0
	bpl.s	l01c0
	move.b	$13(a6,d2.w),d1
	bpl.s	l01c1
	move.b	d1,$59814
	move.w	#2,$58d4a
	bra	l01c8
l01c1
	tst.w	$58b90
	ble.s	l01c6
	bra.s	l01c5
l01c2
	tst.w	$58d88
	bge.s	l01c5
	bra.s	l01c6
l01c3
	tst.w	$58d88
	ble.s	l01c5
	bra.s	l01c6
l01c4
	tst.w	$58b90
	bge.s	l01c6
l01c5
	neg.w	$58b90
	move.w	$58c52,$58d4e
	move.w	$58c50,$58b30
	bra.s	l01c7
l01c6
	neg.w	$58d82
	neg.w	$58d84
	move.w	$58c4c,$58bb0
l01c7
	move.w	$58d82,$58d88
	tst.w	$58d54
	beq.s	l01c8
	move.l	$58e90,$58e84
	move.w	$58e94,$58e88
l01c8
	rts

l01c9
	cmpi.w	#$e,$58c3c
	bcc	l01cd
	bsr	l0174
	tst.w	$58b50
	bmi	l01cd
	lea	$58020,a0
	movea.l	(a0),a1
	movea.l	$300(a0),a2
	movea.l	$58418,a0
	move.l	#$e,d4
	move.l	d4,$58518
	bsr	l01ce
	tst.w	$58d94
	beq.s	l01cc
	cmpi.b	#2,$59802
	beq.s	l01cc
	cmpi.w	#$3a,$58b30
	bcs.s	l01cc
	movea.l	$5809c,a1
	movea.l	$5839c,a2
	move.w	#$a,d4
	bsr.s	l01ce
	suba.l	#$1720,a0
	movea.l	$58098,a1
	movea.l	$58398,a2
	move.w	#$a,d4
	cmpi.w	#$3f,$58b30
	bcc.s	l01cb
	move.w	#$3f,d0
	sub.w	$58b30,d0
l01ca
	lea	$a0(a0),a0
	lea	$a0(a1),a1
	lea	$a0(a2),a2
	subq.w	#1,d4
	dbf	d0,l01ca
l01cb
	move.l	a0,$58418
	bsr.s	l01ce
	move.l	#$24,$58518
l01cc
	rts

l01cd
	move.l	#-1,$58418
	rts

l01ce
	move.l	(a2)+,d0
	eori.l	#-1,d0
	move.l	(a0),d1
	and.l	d0,d1
	or.l	(a1)+,d1
	move.l	d1,(a0)+
	move.l	(a0),d1
	and.l	d0,d1
	or.l	(a1),d1
	move.l	d1,(a0)
	lea	$9c(a0),a0
	lea	$9c(a1),a1
	lea	$9c(a2),a2
	dbf	d4,l01ce
	rts

l01cf
	tst.w	$58d94
	beq	l01d2
	cmpi.b	#2,$59802
	beq	l01d2
	move.w	#$21,$58b54
	move.w	$58b10,$58b14
	move.w	$58b30,d0
	addi.w	#$f,d0
	move.w	d0,$58b34
	move.w	#2,d0
	bsr	l01d9
	move.l	$58098,-(a7)
	move.l	$58398,-(a7)
	move.w	#$20,$58b56
	move.w	$58b10,$58b16
	move.w	$58b30,d0
	subi.w	#$b,d0
	move.w	d0,$58b36
	move.l	#$a,d4
	cmpi.w	#$3f,$58b30
	bcc.s	l01d1
	move.w	#$3f,d0
	sub.w	$58b30,d0
l01d0
	addi.l	#$a0,$58098
	addi.l	#$a0,$58398
	addq.w	#1,$58b36
	subq.w	#1,d4
	dbf	d0,l01d0
l01d1
	move.l	d4,$58298
	move.w	#3,d0
	bsr	l01d9
	move.l	(a7)+,$58398
	move.l	(a7)+,$58098
	move.l	#$24,$58518
l01d2
	rts

	bsr	l01ce
	suba.l	#$1720,a0
	movea.l	$58098,a1
	movea.l	$58398,a2
	move.w	#$a,d4
	cmpi.w	#$3e,$58b30
	bcc.s	l01d4
	move.w	#$3e,d0
	sub.w	$58b30,d0
l01d3
	lea	$a0(a0),a0
	lea	$a0(a1),a1
	lea	$a0(a2),a2
	subq.w	#1,d4
	dbf	d0,l01d3
l01d4
	move.l	a0,$58418
	bsr	l01ce
	rts

l01d5
	movea.l	$58418,a0
	cmpa.l	#0,a0
	bmi.s	l01d7
	move.l	a0,d0
	andi.l	#$7fff,d0
	addi.l	#$38000,d0
	movea.l	d0,a1
	move.l	$58518,d4
l01d6
	move.l	(a1)+,(a0)+
	move.l	(a1),(a0)
	lea	$9c(a0),a0
	lea	$9c(a1),a1
	dbf	d4,l01d6
l01d7
	rts

l01d8
	clr.l	d0
l01d9
	movem.l	a0-a5/d0-d7,-(a7)
	andi.l	#$ff,d0
	asl.w	#1,d0
	movea.l	d0,a3
	adda.l	#$58b10,a3
	asl.w	#1,d0
	movea.w	d0,a4
	adda.l	#$58418,a4
	move.w	(a3),d6
	move.w	$20(a3),d7
	move.w	$40(a3),d0
	tst.w	d0
	bmi	l01dc
	asl.w	#2,d0
	movea.l	d0,a0
	adda.l	#$58018,a0
	movea.l	(a0),a1
	move.l	$100(a0),d3
	move.l	d3,$80(a4)
	lsr.b	#2,d3
	move.l	$200(a0),d4
	move.l	d4,$100(a4)
	movea.l	$300(a0),a2
	bsr	l0239
	move.l	a0,(a4)
	cmpi.w	#8,d0
	bgt	l01dd
l01da
	move.w	d3,d1
	movea.l	a0,a3
	movea.l	a1,a4
	movea.l	a2,a5
l01db
	clr.l	d7
	move.w	(a5),d7
	eori.l	#-1,d7
	ror.l	d0,d7
	move.l	d7,d2
	swap	d2
	clr.l	d6
	move.w	(a4)+,d6
	ror.l	d0,d6
	and.w	d7,(a3)
	or.w	d6,(a3)+
	swap	d6
	and.w	d2,6(a3)
	or.w	d6,6(a3)
	clr.l	d6
	move.w	(a4)+,d6
	ror.l	d0,d6
	and.w	d7,(a3)
	or.w	d6,(a3)+
	swap	d6
	and.w	d2,6(a3)
	or.w	d6,6(a3)
	clr.l	d6
	move.w	(a4)+,d6
	ror.l	d0,d6
	and.w	d7,(a3)
	or.w	d6,(a3)+
	swap	d6
	and.w	d2,6(a3)
	or.w	d6,6(a3)
	clr.l	d6
	move.w	(a4)+,d6
	ror.l	d0,d6
	and.w	d7,(a3)
	or.w	d6,(a3)+
	swap	d6
	and.w	d2,6(a3)
	or.w	d6,6(a3)
	addq.w	#8,a5
	dbf	d1,l01db
	lea	$a0(a0),a0
	lea	$a0(a1),a1
	lea	$a0(a2),a2
	dbf	d4,l01da
	movem.l	(a7)+,a0-a5/d0-d7
	rts

l01dc
	move.l	#-1,(a4)
	movem.l	(a7)+,a0-a5/d0-d7
	rts

l01dd
	eori.w	#$f,d0
	addq.w	#1,d0
l01de
	move.w	d3,d1
	movea.l	a0,a3
	movea.l	a1,a4
	movea.l	a2,a5
l01df
	clr.l	d7
	move.w	(a5),d7
	eori.l	#-1,d7
	rol.l	d0,d7
	move.l	d7,d2
	swap	d7
	clr.l	d6
	move.w	(a4)+,d6
	rol.l	d0,d6
	and.w	d2,8(a3)
	or.w	d6,8(a3)
	swap	d6
	and.w	d7,(a3)
	or.w	d6,(a3)+
	clr.l	d6
	move.w	(a4)+,d6
	rol.l	d0,d6
	and.w	d2,8(a3)
	or.w	d6,8(a3)
	swap	d6
	and.w	d7,(a3)
	or.w	d6,(a3)+
	clr.l	d6
	move.w	(a4)+,d6
	rol.l	d0,d6
	and.w	d2,8(a3)
	or.w	d6,8(a3)
	swap	d6
	and.w	d7,(a3)
	or.w	d6,(a3)+
	clr.l	d6
	move.w	(a4)+,d6
	rol.l	d0,d6
	and.w	d2,8(a3)
	or.w	d6,8(a3)
	swap	d6
	and.w	d7,(a3)
	or.w	d6,(a3)+
	addq.w	#8,a5
	dbf	d1,l01df
	lea	$a0(a0),a0
	lea	$a0(a1),a1
	lea	$a0(a2),a2
	dbf	d4,l01de
	movem.l	(a7)+,a0-a5/d0-d7
	rts

l01e0
	move.l	#$5992f,d7
	bsr	l0286
	clr.w	d6
l01e1
	bsr.s	l01e4
	addq.w	#1,d6
	cmpi.w	#4,d6
	bcs.s	l01e1
	rts

l01e2
	move.l	#$59909,d7
	bsr	l0286
	move.w	#3,d6
l01e3
	bsr.s	l01e4
	subq.w	#1,d6
	bpl.s	l01e3
	rts

l01e4
	move.w	d6,d2
	asl.w	#1,d2
	lea	$58edc,a0
	move.w	0(a0,d2.w),d7
	bsr	l023d
	move.l	#1,d3
	asl.w	d6,d3
	asl.w	#1,d3
	subq.w	#1,d3
	movea.l	#$38000,a0
	movea.l	$58008,a1
l01e5
	move.w	#$4f,d4
	movea.l	a1,a2
l01e6
	move.w	(a0)+,d1
	and.w	d7,d1
	beq.s	l01e8
	move.w	#1,d5
	move.w	d6,d2
l01e7
	move.w	d1,d0
	asl.w	d5,d1
	add.w	d0,d1
	asl.w	#1,d5
	dbf	d2,l01e7
l01e8
	move.w	d1,(a1)+
	dbf	d4,l01e6
	move.w	d3,d2
l01e9
	move.w	#$4f,d4
l01ea
	move.w	(a2)+,(a1)+
	dbf	d4,l01ea
	lea	$a0(a0),a0
	dbf	d2,l01e9
	cmpa.l	#$3fb00,a0
	bcs.s	l01e5
	bsr	l0240
	bsr	l0243
	bsr	l0243
	rts

l01eb
	lea	$58c96,a2
	lea	$58b10,a1
	lea	$58b70,a5
	lea	$58718,a3
	lea	$58d16,a4
l01ec
	move.w	(a2),d6
	tst.w	d6
	bmi	l01f3
	move.w	$10(a2),d7
	add.w	$20(a2),d6
	cmpi.w	#$12c,d6
	bcc	l01f7
	cmpi.w	#$10,d6
	bcs	l01f7
	add.w	$30(a2),d7
	tst.w	$58d68
	bne	l01ed
	cmpi.w	#$8a,d7
	bcc	l01f7
l01ed
	cmpi.w	#$a0,d7
	bcc	l01f7
	cmpi.w	#$34,d7
	bcs	l01f7
	move.w	d6,(a2)
	move.w	d7,$10(a2)
	cmpa.l	#$58ca2,a2
	bge	l01f0
	move.w	#7,d2
	move.w	#$10,d1
l01ee
	tst.w	$40(a1,d1.w)
	bmi.s	l01ef
	move.w	0(a1,d1.w),d0
	sub.w	d6,d0
	addi.w	#$10,d0
	cmpi.w	#$14,d0
	bcc.s	l01ef
	move.w	$20(a1,d1.w),d0
	sub.w	d7,d0
	addi.w	#$e,d0
	cmpi.w	#$12,d0
	bcs	l01f6
l01ef
	addq.w	#2,d1
	dbf	d2,l01ee
	bra	l01f2
l01f0
	move.w	(a1),d0
	sub.w	d6,d0
	addi.w	#$10,d0
	cmpi.w	#$14,d0
	bcc	l01f1
	move.w	$20(a1),d0
	sub.w	d7,d0
	addi.w	#$e,d0
	cmpi.w	#$12,d0
	bcs.s	l01f5
l01f1
	move.w	2(a1),d0
	sub.w	d6,d0
	addi.w	#$10,d0
	cmpi.w	#$14,d0
	bcc	l01f2
	move.w	$22(a1),d0
	sub.w	d7,d0
	addi.w	#6,d0
	cmpi.w	#$a,d0
	bcs.s	l01f4
l01f2
	bsr	l0239
	move.l	a0,(a3)
	move.l	(a0),$20(a3)
	move.w	d0,(a4)
l01f3
	addq.l	#4,a3
	addq.l	#2,a4
	addq.l	#2,a2
	cmpa.l	#$58ca6,a2
	blt	l01ec
	rts

l01f4
	tst.b	$59807
	beq	l01f7
	subq.w	#1,$58c38
	bne	l01f7
	bsr	l0192
	bra	l01f7
l01f5
	tst.b	$59807
	beq	l01f7
	move.w	#1,$58d4a
	bra	l01f7
l01f6
	move.w	$40(a1,d1.w),d0
	bsr.s	l01f8
	move.w	d0,$40(a1,d1.w)
l01f7
	move.w	#-1,(a2)
	move.l	#-1,(a3)
	bra.s	l01f3
l01f8
	movem.l	a0-a6/d1-d7,-(a7)
	cmpi.w	#9,d0
	beq	l0200
	bmi	l01ff
	cmpi.w	#$38,d0
	bge	l01fc
	cmpi.w	#$e,d0
	bge	l01ff
	lea	$58fa8,a0
	bsr	l024a
	tst.w	$58d68
	bne	l01fd
	move.w	$ff8252.l,d0
	andi.w	#$777,d0
	cmpi.w	#$770,d0
	bne.s	l01f9
	bsr	l0231
	cmpi.b	#-$10,d0
	bcc.s	l01fa
l01f9
	move.w	#$e,d0
	bra	l01ff
l01fa
	bsr	l0231
	andi.w	#7,d0
	cmpi.w	#5,d0
	bcc.s	l01fa
	cmp.w	$58c1c,d0
	beq.s	l01fa
	cmpi.w	#4,d0
	bne.s	l01fb
	cmpi.w	#6,$58fc4
	bcc.s	l01fa
l01fb
	move.w	d0,$58c1c
	asl.w	#1,d0
	lea	$58c10,a0
	move.w	0(a0,d0.w),$ff8252.l
	move.w	#$12,d0
	bra.s	l01ff
l01fc
	cmpi.w	#9,$58c2c
	beq	l01ff
	move.w	#3,d0
	lea	$58fa8,a0
	bsr	l024b
l01fd
	move.l	#$598c5,d7
	bsr	l0286
	move.w	#$18,d0
	subq.w	#1,$58c22
	bne.s	l01fe
	move.w	#8,$58c22
	move.w	#4,d0
l01fe
	addq.w	#1,$58c2a
l01ff
	movem.l	(a7)+,a0-a6/d1-d7
	rts

l0200
	lea	$58fa9,a0
	bsr	l024a
	move.w	#8,d0
	bra.s	l01ff
l0201
	lea	$58718,a0
	lea	$58d16,a2
	lea	$58cd6,a3
	lea	$58c96,a4
l0202
	movea.l	(a0),a1
	cmpa.l	#0,a1
	bmi	l0204
	move.w	(a2),d0
	move.l	#-$1000000,d3
	lsr.l	d0,d3
	swap	d3
	move.l	$20(a0),d1
	move.l	(a1),d2
	eor.l	d2,d1
	and.w	d3,d1
	bne.s	l0203
	swap	d1
	and.w	d3,d1
	bne.s	l0203
	addq.w	#6,a1
	move.l	a1,(a3)
	move.l	d3,$20(a0)
	bra.s	l0204
l0203
	move.l	#-1,(a0)
	move.w	#-1,(a4)
l0204
	addq.l	#2,a2
	addq.l	#2,a4
	addq.l	#4,a0
	addq.l	#4,a3
	cmpa.l	#$58738,a0
	blt	l0202
	cmpi.l	#$e,$58518
	beq	l0209
	lea	$58b20,a1
	move.w	#7,d2
l0205
	tst.w	$40(a1)
	bmi.s	l0208
	move.w	(a1),d0
	sub.w	$58b10,d0
	addi.w	#$10,d0
	cmpi.w	#$20,d0
	bcc.s	l0208
	move.w	$20(a1),d0
	sub.w	$58b30,d0
	bmi.s	l0206
	subi.w	#$f,d0
	cmpi.w	#$b,d0
	bcc.s	l0208
	bra.s	l0207
l0206
	addi.w	#$1a,d0
	bcc.s	l0208
l0207
	move.w	$40(a1),d0
	bsr	l01f8
	move.w	d0,$40(a1)
l0208
	addq.w	#2,a1
	dbf	d2,l0205
l0209
	rts

l020a
	addi.l	#$280,$580d8
	cmpi.l	#$62668,$580d8
	ble	l020b
	move.l	#$60868,$580d8
l020b
	lea	$58718,a0
	lea	$58c96,a4
l020c
	movea.l	(a0),a1
	cmpa.l	#0,a1
	bmi	l020e
	cmpa.l	#$58c9c,a4
	bcs.s	l020d
	move.w	(a4),$58b1a
	move.w	$10(a4),$58b3a
	move.w	#$30,$58b5a
	move.w	#5,d0
	bsr	l01d9
	bra	l020e
l020d
	move.l	$20(a0),d3
	addq.w	#6,a1
	move.w	(a1),d1
	or.w	d3,d1
	move.w	d1,(a1)
	move.w	$a0(a1),d1
	or.w	d3,d1
	move.w	d1,$a0(a1)
	swap	d3
	move.w	8(a1),d1
	or.w	d3,d1
	move.w	d1,8(a1)
	move.w	$a8(a1),d1
	or.w	d3,d1
	move.w	d1,$a8(a1)
l020e
	addq.l	#2,a4
	addq.l	#4,a0
	cmpa.l	#$58738,a0
	blt	l020c
	move.l	#-1,$5842c
	rts

l020f
	lea	$58cd6,a0
l0210
	cmpa.l	#$58ce2,a0
	bge	l0211
	move.l	(a0),d1
	movea.l	d1,a2
	tst.l	d1
	bmi.s	l0213
	andi.l	#$7fff,d1
	addi.l	#$38000,d1
	movea.l	d1,a1
	move.w	(a1),(a2)
	move.w	8(a1),8(a2)
	move.w	$a0(a1),$a0(a2)
	move.w	$a8(a1),$a8(a2)
	bra	l0213
l0211
	movea.l	(a0),a6
	cmpa.l	#0,a6
	bmi.s	l0213
	subq.w	#6,a6
	move.w	#3,d4
	move.l	a6,d0
	andi.l	#$7fff,d0
	addi.l	#$38000,d0
	movea.l	d0,a1
l0212
	move.l	(a1)+,(a6)+
	move.l	(a1)+,(a6)+
	move.l	(a1)+,(a6)+
	move.l	(a1),(a6)
	lea	$94(a6),a6
	lea	$94(a1),a1
	dbf	d4,l0212
l0213
	addq.l	#4,a0
	cmpa.l	#$58cf6,a0
	bcs	l0210
	rts

	move.l	#$78000,$58008
	bra	l0240
l0214
	lea	$58e9c,a0
	clr.l	$58e84
	clr.l	$58e88
	clr.l	$58e8c
	bra.s	l021b
l0215
	lea	$58db8,a0
	bra.s	l021b
l0216
	lea	$58d98,a0
	bra.s	l021b
l0217
	lea	$58dd8,a0
	bra.s	l021b
l0218
	lea	$58e18,a0
	bra	l021b
l0219
	lea	$58e38,a0
	move.l	$58e90,$58e84
	move.l	$58e94,$58e88
	move.l	$58e98,$58e8c
	move.w	#1,$58c24
	bra.s	l021c
l021a
	lea	$58df8,a0
l021b
	clr.w	$58c24
l021c
	lea	$ff8240.l,a1
	move.w	#$f,d0
l021d
	move.w	(a0)+,(a1)+
	dbf	d0,l021d
	rts

l021e
	movea.l	a1,a3
	bra	l0220
l021f
	lea	$58e90,a3
l0220
	move.w	#6,d6
	movea.l	a1,a2
l0221
	lea	$ff8240.l,a0
	move.w	#$f,d7
l0222
	bsr	l001d
	addq.w	#2,a0
	addq.w	#2,a1
	dbf	d7,l0222
	movea.l	a3,a1
	lea	$58e84,a0
	move.w	#5,d7
l0223
	bsr	l001d
	addq.w	#2,a0
	addq.w	#2,a1
	dbf	d7,l0223
	move.w	#4,d0
	bsr	l0242
	movea.l	a2,a1
	dbf	d6,l0221
	rts

l0224
	movea.l	$58008,a0
	adda.l	#$28,a0
	move.w	#$c7,d1
l0225
	move.w	#8,d0
l0226
	clr.l	(a0)+
	clr.l	(a0)+
	dbf	d0,l0226
	lea	$58(a0),a0
	dbf	d1,l0225
	rts

l0227
	cmpi.l	#$80000,$42e.l
	beq	l022b
	lea	$b0000,a0
	movea.l	#$10000,a1
	move.w	#$6000,d0
l0228
	move.l	(a1)+,(a0)+
	dbf	d0,l0228
	bra	l022b
l0229
	cmpi.l	#$80000,$42e.l
	beq	l0230
	lea	$b0000,a0
	movea.l	#$10000,a1
	move.w	#$6000,d0
l022a
	move.l	(a0)+,(a1)+
	dbf	d0,l022a
l022b
	bsr	l0214
	bsr	l0150
	bsr	l019a
	bsr	l023d
	bsr	l0150
	bsr	l019a
	lea	$59dd3,a0
	lea	$59ded,a1
	bsr	l026e
	move.w	#$50,$58b10
	move.w	#$1e,$58b30
	move.w	#$24,$58b50
	move.w	#$7e,$58b12
	move.w	#$4b,$58b32
	move.w	#$24,$58b52
	clr.w	$58bd0
l022c
	bsr	l0224
	move.w	$58bd0,d0
	cmpi.w	#8,d0
	ble	l022d
	move.w	#8,d0
l022d
	asl.w	#2,d0
	lea	$58810,a0
	move.l	0(a0,d0.w),$580a8
	addi.l	#$10f00,$580a8
	move.l	#$10000,$583a8
	move.l	#$23,$581a8
	move.l	#$a9,$582a8
	bsr	l01d8
	cmpi.w	#8,$58bd0
	blt	l022e
	subi.w	#$10,$58b32
	cmpi.w	#-$a,$58b32
	bmi	l022e
	move.l	#$20050,$580a8
	move.l	#$20068,$583a8
	move.l	#$b,$581a8
	move.l	#$26,$582a8
	move.w	#1,d0
	bsr	l01d9
	bra	l022f
l022e
	bsr	l0243
l022f
	bsr	l0240
	bsr	l023d
	bsr	l0243
	bsr	l0218
	addq.w	#1,$58bd0
	cmpi.w	#$15,$58bd0
	blt	l022c
	move.w	#$8c,$58b10
	move.w	#$4c,$58b30
	move.l	#3,$581a8
	move.l	#$14,$582a8
	move.l	#$218c8,$583a8
	move.l	#$218b0,$580a8
	bsr	l01d8
	bsr	l0240
	move.w	#$12,d0
	bsr	l0242
l0230
	rts

l0231
	move.l	d1,-(a7)
	tst.l	$58894
	bne.s	l0232
	move.l	$4ba.l,d0
	move.l	#$10,d1
	asl.l	d1,d0
	or.l	$4ba.l,d0
	move.l	d0,$58894
l0232
	move.l	#-$44bf19d3,d0
	move.l	$58894,d1
	mulu	d0,d1
	move.l	d1,$58894
	asr.l	#8,d1
	andi.l	#$fff,d1
	move.l	d1,d0
	move.l	(a7)+,d1
	rts

l0233
	move.w	#$ff,-(a7)
	move.w	#6,-(a7)		;crawio
	trap	#1
	addq.l	#4,a7
	rts

l0234
	move.w	#$14,-(a7)
	move.w	#4,-(a7)
	move.w	#3,-(a7)		;bconout
	trap	#$d
	addq.l	#6,a7
	move.w	#$22,-(a7)		;kbdvbase
	trap	#$e
	addq.l	#2,a7
	movea.l	d0,a0
	adda.l	#$18,a0
	lea	$58010,a1
	move.l	(a0),(a1)
	lea	$5e4d6,a1
	move.l	a1,(a0)
	clr.b	$59817
	clr.b	$59818
	rts

	movem.l	a0-a1/d0-d1,-(a7)
	lea	$59817,a1
	move.b	1(a1),d0
	move.b	1(a0),(a1)
	move.b	2(a0),d1
	move.b	d1,1(a1)
	eor.b	d1,d0
	andi.b	#$c,d0
	beq.s	l0237
	cmpi.w	#3,$58d90
	bcc.s	l0235
	addq.w	#1,$58d92
	bra.s	l0236
l0235
	clr.w	$58d92
l0236
	clr.w	$58d90
l0237
	movem.l	(a7)+,a0-a1/d0-d1
	rts

l0238
	move.w	#$22,-(a7)		;kbdvbase
	trap	#$e
	addq.l	#2,a7
	movea.l	d0,a0
	adda.l	#$18,a0
	move.l	$58010,(a0)
	move.w	#$80,-(a7)
	move.w	#4,-(a7)
	move.w	#3,-(a7)		;bconout
	trap	#$d
	addq.l	#6,a7
	move.w	#1,-(a7)
	move.w	#4,-(a7)
	move.w	#3,-(a7)		;bconout
	trap	#$d
	addq.l	#6,a7
	rts

l0239
	move.w	d6,d0
	andi.w	#$f,d0
	andi.w	#-$10,d6
	asr.w	#1,d6
	asl.w	#5,d7
	movea.l	$58008,a0
	adda.w	d7,a0
	asl.w	#2,d7
	adda.w	d7,a0
	adda.w	d6,a0
	rts

l023a
	move.l	#$78000,$58008
	move.w	#0,-(a7)
	move.l	$58008,-(a7)
	move.l	$58008,-(a7)
	move.w	#5,-(a7)		;setscreen
	trap	#$e
	adda.l	#$c,a7
	rts

l023b
	movem.l	a0-a6/d0-d7,-(a7)
	bsr	l0246
	bsr	l023c
	movem.l	(a7)+,a0-a6/d0-d7
	rts

l023c
	move.w	#1,-(a7)
	move.l	#$f8000,-(a7)
	move.l	#$f8000,-(a7)
	move.w	#5,-(a7)		;setscreen
	trap	#$e
	adda.l	#$c,a7
	move.w	#0,$ff8246.l
	move.w	#$666,$ff8240.l
	move.b	#7,$484.l
	rts

l023d
	move.l	$58008,d0
	eori.l	#$8000,d0
	move.l	d0,$58008
	move.w	#$5f,d0
	lea	$58418,a0
	lea	$58598,a1
l023e
	move.l	(a1),d1
	move.l	(a0),(a1)+
	move.l	d1,(a0)+
	dbf	d0,l023e
	move.w	#7,d0
	lea	$58cd6,a0
	lea	$58cf6,a1
l023f
	move.l	(a1),d1
	move.l	(a0),(a1)+
	move.l	d1,(a0)+
	dbf	d0,l023f
	rts

l0240
	move.b	$5800a,$ff8203.l
	move.b	$58009,$ff8201.l
	rts

l0241
	bsr.s	l0243
	btst	#7,$59818
	dbne	d0,l0241
	rts

l0242
	bsr.s	l0243
	dbf	d0,l0242
	rts

l0243
	movem.l	a0-a2/d0-d2,-(a7)
	move.w	#$25,-(a7)		;vsync
	trap	#$e
	addq.l	#2,a7
	movem.l	(a7)+,a0-a2/d0-d2
	rts

l0244
	cmpi.w	#2,$58d80
	blt.s	l0244
	clr.w	$58d80
	rts

l0245
	andi.b	#-2,$fffa07.l
	move.l	$120.l,$5883c
	move.l	#$5e6f8,$120.l
	ori.b	#1,$fffa07.l
	ori.b	#1,$fffa13.l
	move.l	$70.l,$5e770
	move.l	#$5e702,$70.l
	rts

l0246
	move.b	#0,$fffa1b.l
	move.l	$5e770,$70.l
	move.l	$5883c,$120.l
	rts

	move.l	$58e8a,$ff8242.l
	move.w	$58e8e,$ff8246.l
	move.b	#0,$fffa1b.l
	bclr	#0,$fffa0f.l
	rte

	move.b	#0,$fffa1b.l
	tst.w	$58c24
	bne.s	l0247
	move.l	#$5e6f8,$120.l
	bra.s	l0249
l0247
	move.l	#$5e6dc,$120.l
	move.l	$58e84,$ff8242.l
	move.w	$58e88,$ff8246.l
l0248
	move.b	#-$58,$fffa21.l
	cmpi.b	#-$58,$fffa21.l
	bne.s	l0248
	move.b	#8,$fffa1b.l
l0249
	addq.w	#1,$58d80
	bsr	l026f
	dc.b	'S9',0,5,$98,$16,'j',6
	dc.b	'B9',0,5,$98,$16,'N',$f9
	dc.b	$ff,$ff,$ff,$ff
l024a
	move.w	#1,d0
l024b
	tst.w	$58d68
	bne	l024e
	add.b	(a0),d0
	move.b	d0,(a0)
	cmpi.w	#$65,d0
	bcs.s	l024c
	subi.b	#$a,d0
	move.b	d0,(a0)
	subq.l	#1,a0
	bra.s	l024a
l024c
	cmpa.l	#$58fa5,a0
	bne.s	l024d
	bsr	l025c
l024d
	move.w	#2,$58c36
l024e
	rts

l024f
	move.w	#2,$58d58
l0250
	move.w	#2,$58c36
	bsr.s	l0251
	bsr	l023d
	bsr.s	l0251
	bra	l023d
l0251
	tst.w	$58d58
	beq.s	l0252
	subq.w	#1,$58d58
	bsr	l025b
l0252
	tst.w	$58c36
	beq.s	l0253
	move.w	$58d76,$58b1c
	move.w	#$2a,$58b3c
	move.w	#$27,$58b5c
	movea.l	#$58fa5,a4
	bsr	l0260
	subq.w	#1,$58c36
l0253
	rts

l0254
	move.l	a4,-(a7)
	movea.l	#$59044,a4
	subq.b	#1,1(a4)
	cmpi.b	#$5b,1(a4)
	bpl.s	l0255
	move.b	#$64,1(a4)
	subq.b	#1,(a4)
l0255
	subq.w	#1,$58c48
	move.w	#2,$58d58
	movea.l	(a7)+,a4
	rts

l0256
	move.b	#$5b,$59044
	move.w	$58c48,d0
	tst.w	d0
	bmi	l0258
l0257
	cmpi.w	#$a,d0
	blt	l0259
	addq.b	#1,$59044
	subi.w	#$a,d0
	bra	l0257
l0258
	clr.w	d0
l0259
	addi.w	#$5b,d0
	move.b	d0,$59045
l025a
	bsr.s	l025b
	bsr	l023d
	bsr.s	l025b
	bsr	l023d
	clr.w	$58d58
	rts

l025b
	movea.l	#$59044,a4
	move.w	$58d76,$58b1c
	addi.w	#$20,$58b1c
	move.w	#$20,$58b3c
	move.w	#$27,$58b5c
	bsr.s	l0260
	move.l	#-1,$58430
	rts

l025c
	move.l	a0,-(a7)
	addq.w	#1,$58fc4
	move.l	#$5988f,d7
	bsr	l0286
	bsr	l025d
	movea.l	(a7)+,a0
	rts

l025d
	bsr.s	l025e
	bsr	l023d
	bsr.s	l025e
	bsr	l023d
	rts

l025e
	move.w	$58d76,$58b1c
	addi.w	#$10,$58b1c
	move.w	#$20,$58b3c
	move.w	#$27,$58b5c
	move.w	$58fc4,d0
	cmpi.w	#$b,d0
	bmi.s	l025f
	subi.w	#$a,d0
l025f
	addi.w	#$5b,d0
	bsr.s	l0262
	move.l	#-1,$58430
	rts

l0260
	move.b	(a4)+,d0
	tst.b	d0
	beq.s	l0261
	bsr	l0262
	bra.s	l0260
l0261
	move.l	#-1,$58430
	rts

l0262
	andi.l	#$7f,d0
	subi.w	#$5b,d0
	asl.w	#3,d0
	addi.l	#$60000,d0
	move.l	d0,$580b4
	move.w	#6,d0
	bsr	l01d9
	addq.w	#8,$58b1c
	rts

l0263
	movem.l	a0/d0,-(a7)
l0264
	clr.l	d0
	move.b	(a4)+,d0
	tst.b	d0
	beq.s	l0265
	bsr	l0266
	bra.s	l0264
l0265
	movem.l	(a7)+,a0/d0
	move.l	#-1,$58430
	rts

l0266
	andi.l	#$7f,d0
	cmpi.b	#$41,d0
	bcs.s	l026b
l0267
	subi.b	#$41,d0
	asl.w	#3,d0
	cmpi.w	#$a0,d0
	bcs.s	l0268
	addi.w	#$960,d0
l0268
	addi.l	#$63480,d0
	move.l	d0,$580cc
	move.w	#$2d,$58b5c
	move.w	#6,d0
	bsr	l01d9
l0269
	addi.w	#$10,$58b1c
	rts

l026a
	move.w	#$67,d0
	bra.s	l0267
l026b
	cmpi.b	#$20,d0
	beq.s	l026a
	cmpi.b	#$a,d0
	bne.s	l026c
	addi.w	#$10,$58b3c
	rts

l026c
	cmpi.b	#$d,d0
	bne.s	l0269
	clr.w	$58b1c
	rts

l026d
	clr.l	-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
	move.l	d0,$58834
	rts

	move.l	$58834,-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	adda.l	#6,a7
	rts

l026e
	move.b	#1,$5981c
	clr.b	$59816
	clr.b	$5981d
	clr.b	$59820
	clr.b	$59821
	move.b	#$c,$59822
	move.l	a0,$58844
	move.l	#$5884c,$5884c
	move.l	a1,$58848
	move.l	#$58870,$58870
	move.b	#1,$5981e
	move.b	#1,$5981f
	move.l	#$599ed,d7
	bsr	l0286
	move.b	#2,$59824
	clr.b	$5981c
	rts

l026f
	movem.l	a0/d7/d0,-(a7)
	tst.b	$5981c
	bne	l0284
	subq.b	#1,$59824
	bne	l0284
	move.b	#2,$59824
	move.b	#1,$59823
	subq.b	#1,$5981e
	tst.b	$5981e
	bne	l0275
l0270
	movea.l	$58844,a0
	move.b	1(a0),d0
	tst.b	d0
	beq	l0275
	bpl.s	l0274
	addq.l	#2,$58844
	cmpi.b	#-2,d0
	beq	l0271
	bcc.s	l0273
	cmpi.b	#-3,d0
	bne	l0270
	bsr	l0285
	bra	l0284
l0271
	movea.l	$5884c,a0
	subq.l	#1,$10(a0)
	beq	l0272
	move.l	(a0),$58844
	bra.s	l0270
l0272
	subq.l	#4,$5884c
	bra	l0270
l0273
	addq.l	#4,$5884c
	clr.l	d0
	move.b	(a0),d0
	movea.l	$5884c,a0
	move.l	d0,$10(a0)
	move.l	$58844,(a0)
	bra	l0270
l0274
	addq.l	#2,$58844
	move.b	d0,$5981e
	clr.l	d0
	move.b	(a0),d0
	tst.b	d0
	beq.s	l0275
	add.b	$59820,d0
	lsl.w	#1,d0
	lea	$58ee4,a0
	move.b	0(a0,d0.w),$59a02
	move.b	1(a0,d0.w),$59a00
	move.b	#$10,$59a04
	clr.b	$59823
	bra.s	l0276
l0275
	clr.b	$59a04
l0276
	subq.b	#1,$5981f
	beq.s	l0277
	tst.b	$59a0a
	beq	l0282
	cmpi.b	#2,$5981f
	beq	l0280
	bcs	l0282
	bra	l0283
l0277
	movea.l	$58848,a0
	move.b	1(a0),d0
	tst.b	d0
	beq	l0282
	bpl	l027f
	addq.l	#2,$58848
	cmpi.b	#-5,d0
	beq	l027d
	cmpi.b	#-4,d0
	beq	l027b
	cmpi.b	#-2,d0
	beq	l0278
	bcc.s	l027a
	bsr	l0285
	bra	l0284
l0278
	movea.l	$58870,a0
	subq.l	#1,$10(a0)
	beq	l0279
	move.l	(a0),$58848
	bra.s	l0277
l0279
	subq.l	#4,$58870
	bra	l0277
l027a
	addq.l	#4,$58870
	clr.l	d0
	move.b	(a0),d0
	movea.l	$58870,a0
	move.l	d0,$10(a0)
	move.l	$58848,(a0)
	bra	l0277
l027b
	move.b	(a0),d7
	bpl	l027c
	bsr	l0231
	move.b	$59821,d7
	andi.w	#3,d0
	asl.w	#2,d0
	add.b	d0,d7
	asl.w	#1,d0
	add.b	d0,d7
	cmp.b	$59822,d7
	beq	l027b
l027c
	move.b	d7,$59822
	bra	l0277
l027d
	cmpi.w	#$a,$59820
	bpl	l027e
	addq.b	#2,$59820
	addq.b	#2,$59821
	addq.b	#2,$59821
	bra	l0277
l027e
	clr.b	$59820
	clr.b	$59821
	move.b	#$c,$59822
	bra	l0277
l027f
	addq.l	#2,$58848
	move.b	d0,$5981f
	clr.l	d0
	move.b	(a0),d0
	tst.b	d0
	beq.s	l0282
	add.b	$59821,d0
	lsl.w	#1,d0
	lea	$58ee4,a0
	move.b	0(a0,d0.w),$59a08
	move.b	1(a0,d0.w),$59a06
	add.b	$59822,d0
	add.b	$59822,d0
	move.b	0(a0,d0.w),$59a0e
	move.b	1(a0,d0.w),$59a0c
	cmpi.b	#2,$5981f
	bcc.s	l0281
	bra	l0280
l0280
	move.b	#$10,$59a0a
	clr.b	$59823
	bra.s	l0283
l0281
	move.b	#$f,$59a0a
	clr.b	$59823
	bra.s	l0283
l0282
	clr.b	$59a0a
l0283
	move.b	$59a0a,$59a10
	tst.b	$59823
	bne.s	l0284
	move.l	#$599fd,d7
	bsr	l0286
l0284
	movem.l	(a7)+,a0/d7/d0
	rts

l0285
	move.b	#1,$5981c
	move.l	#$59a1b,d7
	bra	l0286
l0286
	movem.l	a0-a2/d0-d2,-(a7)
	movea.l	d7,a0
	tst.b	$59816
	beq.s	l0287
	move.b	$5981d,d0
	cmp.b	(a0),d0
	bcc.s	l0288
l0287
	move.b	(a0),$5981d
	move.b	1(a0),$59816
	addq.l	#2,d7
	move.l	d7,-(a7)
	move.w	#$20,-(a7)		;dosound
	trap	#$e
	addq.l	#6,a7
l0288
	movem.l	(a7)+,a0-a2/d0-d2
	rts

l0289
	movea.l	#$5ee16,a0
	bsr	l028a
	movea.l	#$5ee28,a0
	bsr	l028a
	movea.l	#$5ee38,a0
	bsr	l028a
	movea.l	#$5ee48,a0
	bsr	l028a
	movea.l	#$5ee58,a0
	bsr	l028a
	movea.l	#$5ee66,a0
	bsr	l028a
	rts

	bsr	l0289
	bra	l0005
l028a
	move.l	(a0)+,$5ee12
	move.w	#2,-(a7)
	move.l	a0,-(a7)
	move.w	#$3d,-(a7)		;fopen
	trap	#1
	addq.l	#8,a7
	tst.w	d0
	bmi.s	l028b
	move.w	d0,$5ee10
	move.l	$5ee12,-(a7)
	move.l	#$7d80,-(a7)
	move.w	d0,-(a7)
	move.w	#$3f,-(a7)		;fread
	trap	#1
	adda.l	#$c,a7
	tst.l	d0
	bmi.s	l028b
	move.w	$5ee10,-(a7)
	move.w	#$3e,-(a7)		;fclose
	trap	#1
	addq.l	#4,a7
	tst.w	d0
	bmi.s	l028b
	rts

l028b
	dc.b	'D',$80,'J',$fc,0,7,0,6
	dc.b	$7f,$de,0,3,$ff,$de,'wi'
	dc.b	'zsprit.p'
	dc.b	'i1',0,0,0,4,$7f,$de
	dc.b	'wizobj.p'
	dc.b	'i1',0,0,0,4,$ff,$de
	dc.b	'WIZTIT.P'
	dc.b	'I1',0,0,0,2,$ff,$de
	dc.b	'WBACKS.P'
	dc.b	'I1',0,0,0,5,$ff,$de
	dc.b	'TEXT.PI1'
	dc.b	0,0,0,6,$7f,$de,'WI'
	dc.b	'ZLAB.PI1'
	dcb.w	2
	dc.b	$ff,$de,'WIZP1.'
	dc.b	'PI1',0,0,1,$7f,$de
	dc.b	'WIZP2.PI'
	dc.b	'1',0,0,1,$ff,$de,'WI'
	dc.b	'ZP3.PI1',0
	dc.b	'J',$fc,0,0,0,8,$ff,$de
	dc.b	'WIZP1.PI'
	dc.b	'1',0,0,9,$7f,$de,'WI'
	dc.b	'ZP2.PI1',0
	dc.b	0,9,$ff,$de,'WIZP'
	dc.b	'3.PI1',0,'J',$fc
	dcb.w	2185
	dc.b	2,'"',3,'3',6,'f',0,5
	dc.b	7,5,0,'W',1,'Q',7,'w'
	dc.b	7,'p',3,'s',0,'0',3,'7'
	dc.b	3,0,5,0,7,0,0,0
	dcb.w	2
	dc.b	'<',0,0,0,0,0,0,0
	dc.b	$18,0,0,0,0,0,0,0
	dc.b	'<',0,0,0,0,0,0,0
	dc.b	'<',0,0,0,0,0,0,0
	dc.b	$c,0,0,0,0,0,0,0
	dc.b	'~',0,0,0,0,0,2,0
	dc.b	'>',0,0,0,0,0,0,0
	dc.b	'~',0,0,0,0,0,0,0
	dc.b	'<',0,0,0,0,0,4,0
	dc.b	'<',0,$ff,0,$ff,0,$ff,0
	dc.b	$ff,0,0,0,6,0,7,$e0
	dc.b	1,$e0,0,0,0,0,0,0
	dcb.w	9
	dc.b	0,' ',7,$e0,0,' ',7,$c0
	dc.b	0,0,6,0,7,$e0,1,$e0
	dc.b	0,0,6,0,7,$e0,1,$e0
	dc.b	0,0,6,0,7,$e0,1,$e0
	dcb.w	7
	dc.b	'f',0,0,0,0,0,0,0
	dc.b	'8',0,0,0,0,0,0,0
	dc.b	'F',0,0,0,0,0,' ',0
	dc.b	'f',0,0,0,0,0,0,0
	dc.b	$1c,0,0,0,0,0,0,0
	dc.b	'`',0,0,0,0,0,0,0
	dc.b	'b',0,0,0,'@',0,'@',0
	dc.b	'&',0,0,0,0,0,0,0
	dc.b	'b',0,0,0,0,0,2,0
	dc.b	'f',0,$ff,0,$ff,0,$ff,0
	dc.b	$ff,0,0,0,$1e,0,$1f,$f8
	dc.b	1,$f8,0,0,0,0,0,0
	dcb.w	9
	dc.b	7,$f8,$1f,$f8,7,$f8,$18,0
	dc.b	0,0,$1f,0,$1f,$f8,0,$f8
	dc.b	0,0,$1f,0,$1f,$f8,0,$f8
	dc.b	0,0,$1c,0,$1f,$f8,3,$f8
	dcb.w	5
	dc.b	'f',0,$e7,0,$81,0,0,0
	dc.b	$18,0,$18,0,0,0,0,0
	dc.b	'&',0,'&',0,0,0,0,0
	dc.b	6,0,6,0,0,0,0,0
	dc.b	'<',0,'<',0,0,0,0,0
	dc.b	'|',0,'|',0,0,0,0,0
	dc.b	'`',0,'`',0,0,0,0,0
	dc.b	$c,0,$c,0,0,0,0,0
	dc.b	'r',0,'r',0,0,0,0,0
	dc.b	'f',0,'f',0,0,0,$ff,0
	dc.b	$ff,0,$ff,0,$ff,0,0,0
	dc.b	'&',0,$27,$fc,$19,$fc,0,0
	dcb.w	11
	dc.b	$1f,$fc,'?',$fc,$1f,$fc,' ',0
	dc.b	0,0,$27,0,$27,$fc,$18,$fc
	dc.b	0,0,$27,0,$27,$fc,$18,$fc
	dc.b	0,0,'$',0,'&|',$1a,$fc
	dcb.w	6
	dc.b	$e7,0,$e7,0,0,0,0,0
	dc.b	$18,0,$18,0,0,0,0,0
	dc.b	$c,0,$c,0,0,0,0,0
	dc.b	$c,0,$c,0,0,0,0,0
	dc.b	'l',0,'l',0,0,0,0,0
	dc.b	6,0,6,0,0,0,0,0
	dc.b	'|',0,'|',0,0,0,0,0
	dc.b	$18,0,$18,0,0,0,0,0
	dc.b	'<',0,'<',0,0,0,0,0
	dc.b	'>',0,'>',0,$ff,0,$ff,0
	dc.b	$ff,0,$ff,0,0,0,'N',0
	dc.b	'O',$fe,'1',$fc,0,0,6,0
	dc.b	7,$e0,1,$e0,2,'@',1,$80
	dc.b	3,$c0,3,$c0,2,$80,1,0
	dc.b	3,$80,3,$80,'>~}',$be
	dc.b	'?',$fe,'C',$c0,0,0,'O',0
	dc.b	'O',$fe,'0',$fc,0,0,'O',0
	dc.b	'O',$fe,'0',$fc,0,0,'L',0
	dc.b	'L~3',$fc,0,0,0,0
	dcb.w	3
	dc.b	'f',0,$e7,0,$81,0,0,0
	dc.b	$18,0,$18,0,0,0,0,0
	dc.b	'0',0,'0',0,0,0,0,0
	dc.b	6,0,6,0,0,0,0,0
	dc.b	$fe,0,$fe,0,0,0,0,0
	dc.b	6,0,6,0,0,0,0,0
	dc.b	'f',0,'f',0,0,0,0,0
	dc.b	$18,0,$18,0,0,0,0,0
	dc.b	'N',0,'N',0,0,0,0,0
	dc.b	6,0,6,0,0,0,$ff,0
	dc.b	$ff,0,$ff,0,$ff,0,0,0
	dc.b	$1e,0,$1f,$fe,'a',$fc,0,0
	dc.b	$1e,0,$1f,$fc,'!',$fc,9,$d0
	dc.b	5,$e0,$d,$f0,$f,$f0,9,$a0
	dc.b	5,$c0,$d,$e0,$f,$e0,'9',$de
	dc.b	'u',$ee,'=',$fe,'O',$f0,0,0
	dc.b	$1e,0,$1f,$fe,'a',$fc,0,0
	dc.b	$1e,0,$1f,$fe,'a',$fc,0,0
	dc.b	$1e,0,$1f,$fe,'a',$fc,0,0
	dcb.w	6
	dc.b	'f',0,0,0,0,0,0,0
	dc.b	$18,0,0,0,0,0,0,0
	dc.b	'b',0,0,0,0,0,' ',0
	dc.b	'f',0,0,0,0,0,0,0
	dc.b	$c,0,0,0,0,0,0,0
	dc.b	'F',0,0,0,0,0,0,0
	dc.b	'f',0,0,0,0,0,0,0
	dc.b	'0',0,0,0,0,0,0,0
	dc.b	'F',0,0,0,0,0,2,0
	dc.b	'F',0,$ff,0,$ff,0,$ff,0
	dc.b	$ff,0,0,0,$be,0,$bf,$ff
	dc.b	'A',$fc,0,0,'>',0,'?',$fe
	dc.b	'A',$fc,3,$e8,$b,$f0,$b,$f8
	dc.b	$f,$f8,3,$c0,$1b,$f0,$b,$e0
	dc.b	$1f,$f0,'s',$ef,$fb,$ff,'{',$ff
	dc.b	$8f,$f0,3,$80,$bf,$80,$bc,$7f
	dc.b	'C',$fc,0,0,$be,0,$bf,$ff
	dc.b	'A',$fc,0,0,$be,0,$bf,$ff
	dc.b	'A',$fc,0,0,0,0,0,0
	dcb.w	4
	dc.b	'<',0,0,0,0,0,'B',0
	dc.b	'~',0,0,0,2,0,2,0
	dc.b	'|',0,0,0,0,0,0,0
	dc.b	'<',0,0,0,0,0,0,0
	dc.b	$1e,0,0,0,'@',0,'@',0
	dc.b	'<',0,0,0,0,0,0,0
	dc.b	'<',0,0,0,0,0,0,0
	dc.b	'0',0,0,0,0,0,0,0
	dc.b	'<',0,0,0,0,0,'D',0
	dc.b	'|',0,$ff,0,$ff,0,$ff,0
	dc.b	$ff,0,0,0,$fc,0,$ff,$ff
	dc.b	3,$fc,0,0,$fc,0,$ff,$ff
	dc.b	3,$fc,$17,$e8,$f,$f0,$1f,$f8
	dc.b	$1f,$f8,$17,$d0,'o',$ee,$1f,$f0
	dc.b	$7f,$fe,'w',$ef,$ef,$f7,$7f,$ff
	dc.b	$9f,$f8,$1e,'p',$ff,$f0,$e1,$8f
	dc.b	$1f,$fc,0,0,$fc,0,$ff,$ff
	dc.b	3,$fc,0,0,$fc,0,$ff,$ff
	dc.b	3,$fc,0,0,0,0,0,0
	dcb.w	46
	dc.b	$f8,0,$ff,$ff,4,'x',0,0
	dc.b	$f8,0,$ff,$ff,7,$f8,$17,$e8
	dc.b	$f,$f0,$1f,$f8,$1f,$f8,$17,$d8
	dc.b	$ef,$ef,$1f,$f8,$ff,$f7,$f7,$ef
	dc.b	$ef,$f7,$ff,$fb,$1f,$fc,'s',$ce
	dc.b	$ff,$fe,$8f,$f1,$7f,$fe,0,0
	dc.b	$f8,0,$ff,$ff,7,$f8,0,0
	dc.b	$f8,0,$ff,$ff,7,$f8,0,0
	dcb.w	19
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,1,0,1,0,0,0
	dcb.w	2
	dc.b	1,0,0,0,1,0,0,0
	dc.b	0,0,1,0,0,0,0,0
	dcb.w	7
	dc.b	'p',$80,$fe,$ff,$8c,'x',0,0
	dc.b	'p',0,$ff,$ff,$8f,$f8,7,$ff
	dc.b	$ff,$ff,7,$f8,$f8,7,7,$f8
	dc.b	$ff,$fe,$8f,$f9,$7f,$e6,$f7,$ef
	dc.b	$ef,$f7,$ff,$fb,$1f,$fc,$f7,$ef
	dc.b	$ef,$f7,$1f,$f8,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,0,0
	dc.b	'p',0,$ff,$ff,$8f,$f8,0,0
	dcb.w	3
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,7,$c0,0,0
	dcb.w	2
	dc.b	7,$c0,0,0,1,0,1,0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,0,0,0,0,0,0
	dc.b	1,0,0,0,1,0,0,0
	dc.b	0,0,1,0,'<',0,'<',0
	dc.b	'<',0,'<',0,0,0,0,0
	dcb.w	3
	dc.b	3,$80,$ff,$ff,$fc,'p',0,0
	dc.b	0,0,$ff,$ff,$ff,$f0,0,0
	dc.b	0,0,$ff,$ff,$ff,$f0,1,$e0
	dc.b	$ff,$f0,$e1,$ef,$1f,$1c,$f7,$ef
	dc.b	$ef,$f7,$ff,$f9,$1f,$fe,'w',$ee
	dc.b	'o',$f6,$1f,$f8,$7f,$fe,$17,$e8
	dc.b	$f,$f0,$1f,$f8,$1f,$f8,0,0
	dc.b	0,0,$ff,$ff,$ff,$f0,0,0
	dcb.w	3
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$19,$e0,$19,$f0,$19,$f0,$1f,$f0
	dc.b	$18,$f0,$19,$f0,$18,$e0,7,$10
	dcb.w	2
	dc.b	$19,$f0,7,0,1,0,1,0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,0,0,0,0,0,0
	dc.b	1,0,0,0,1,0,0,0
	dc.b	0,0,1,0,$ff,0,$ff,0
	dc.b	$ff,0,$ff,0,0,0,0,0
	dcb.w	4
	dc.b	$ff,$ff,$ff,$f0,0,0,0,0
	dc.b	$ff,$ff,$ff,$f0,0,0,0,0
	dc.b	$ff,$ff,$ff,$f0,0,0,3,$80
	dc.b	$fc,$7f,$ff,$f0,$f7,$af,$ff,$bf
	dc.b	$ff,$b1,$f,$fe,$17,$a0,$1f,$b0
	dc.b	$f,$b0,$1f,$f0,7,$a0,$f,$b0
	dc.b	$f,$b0,$f,$f0,0,0,0,0
	dc.b	$7f,$fe,$7f,$f0,0,0,0,0
	dcb.w	2
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'7',$f0,'7',$f8,'7',$f8,'?',$f8
	dc.b	'!',$f8,'7',$f8,'!',$f0,$1e,8
	dcb.w	2
	dc.b	'7',$f8,$1e,0,3,$80,3,$80
	dc.b	3,$80,3,$80,2,$80,2,$80
	dc.b	2,$80,3,$80,2,$80,2,$80
	dc.b	2,$80,1,0,0,0,0,0
	dc.b	2,$80,1,0,2,$80,0,0
	dc.b	0,0,3,$80,$ff,0,$ff,0
	dc.b	$ff,0,$ff,0,0,0,0,0
	dcb.w	4
	dc.b	$7f,$fe,$7f,$e0,0,0,0,0
	dc.b	$7f,$fe,$7f,$e0,0,0,0,0
	dc.b	$7f,$fe,$7f,$e0,0,0,0,0
	dc.b	$7f,$fe,$7f,$e0,'{',$de,'w',$ee
	dc.b	$7f,$f0,$f,$fe,$b,$d0,7,$e0
	dc.b	$f,$f0,$f,$f0,$b,$d0,7,$e0
	dc.b	$f,$f0,$f,$f0,0,0,0,0
	dc.b	'?',$fc,'?',$e0,0,0,0,0
	dcb.w	2
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f0,'?',$f8,'?',$f8,'?',$f8
	dc.b	$27,$f8,'?',$f8,$27,$f0,$18,8
	dcb.w	2
	dc.b	'?',$f8,$18,0,3,$80,3,$80
	dc.b	3,$80,3,$80,2,$80,2,$80
	dc.b	2,$80,3,$80,2,$80,2,$80
	dc.b	2,$80,1,0,0,0,0,0
	dc.b	2,$80,1,0,2,$80,0,0
	dc.b	0,0,3,$80,'<',0,'<',0
	dc.b	'<',0,'<',0,0,0,0,0
	dcb.w	4
	dc.b	$7f,$fe,$7f,$c0,0,0,0,0
	dc.b	$7f,$fe,'|@',0,0,0,0
	dc.b	$7f,$fe,$7f,$c0,0,0,0,0
	dc.b	$7f,$fe,$7f,$c0,'~~}',$be
	dc.b	$7f,$c0,3,$fe,2,'@',1,$80
	dc.b	3,$c0,3,$c0,2,'@',1,$80
	dc.b	3,$c0,3,$c0,0,0,0,0
	dc.b	7,$e0,7,$80,0,0,0,0
	dcb.w	2
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	'?',$f4,$7f,$f8,$7f,$fc,$7f,$fc
	dc.b	$7f,$fc,$7f,$fc,'?',$f0,'@',$c
	dcb.w	2
	dc.b	$7f,$fc,0,0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,5,$c0,5,$c0
	dc.b	5,$c0,7,$c0,5,$c0,5,$c0
	dc.b	5,$c0,2,0,0,0,0,0
	dc.b	5,$c0,2,0,5,$c0,0,0
	dc.b	0,0,7,$c0,0,0,$18,0
	dc.b	$18,0,$18,0,0,0,0,0
	dcb.w	4
	dc.b	'?',$fc,'?',$80,0,0,0,0
	dc.b	'>',$fc,'<',$80,0,0,0,0
	dc.b	'?',$fc,'?',$80,0,0,0,0
	dc.b	'?',$fc,'?',$80,'?',$fc,'?',$fc
	dc.b	'>',0,1,$fc,0,0,0,0
	dcb.w	14
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$7f,$e0,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$7f,$fc,$7f,$fc,$7f,$e0,0,$1c
	dcb.w	2
	dc.b	$7f,$fc,0,0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,5,$c0,5,$c0
	dc.b	5,$c0,7,$c0,5,$c0,5,$c0
	dc.b	5,$c0,2,0,0,0,0,0
	dc.b	5,$c0,2,0,5,$c0,0,0
	dc.b	0,0,7,$c0,'f',0,'$',0
	dc.b	'f',0,'~',0,0,0,0,0
	dcb.w	4
	dc.b	$1f,$f8,$e,0,0,0,0,0
	dc.b	$1f,$f8,$f,$80,0,0,0,0
	dc.b	$1f,$f8,$e,0,0,0,0,0
	dc.b	$1f,$f8,$f,0,$1f,$f8,$1f,$f8
	dc.b	$1f,$80,0,'x',0,0,0,0
	dcb.w	14
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	'?',$e4,$7f,$f8,$7f,$fc,$7f,$fc
	dc.b	$7f,$fc,$7f,$fc,'?',$e0,'@',$1c
	dcb.w	2
	dc.b	$7f,$fc,0,0,$f,$e0,$f,$e0
	dc.b	$f,$e0,$f,$e0,$b,$c0,$b,$e0
	dc.b	$b,$e0,$f,$e0,$b,$e0,$b,$e0
	dc.b	$b,$c0,4,' ',0,0,0,0
	dc.b	$b,$e0,4,0,$b,$e0,0,0
	dc.b	0,0,$f,$e0,'f',0,'$',0
	dc.b	'f',0,'~',0,0,0,0,0
	dcb.w	4
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,7,$e0,7,$e0
	dc.b	7,$e0,0,0,0,0,0,0
	dcb.w	14
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$c0,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f8,'?',$f8,'?',$c0,0,'8'
	dcb.w	2
	dc.b	'?',$f8,0,0,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$c0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$1f,$c0,0,'0',0,0,0,0
	dc.b	$1f,$f0,0,0,$1f,$f0,0,0
	dc.b	0,0,$1f,$f0,0,0,$18,0
	dc.b	$18,0,$18,0,0,0,0,0
	dcb.w	2
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dcb.w	12
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dcb.w	4
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	$f,$10,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$e8,'?',$f8,$f,0,'0',$f8
	dcb.w	2
	dc.b	'?',$f8,0,$10,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$17,$80,$17,$f0
	dc.b	$17,$f0,$1f,$f0,$17,$f0,$17,$f0
	dc.b	$17,$80,8,'p',0,0,0,0
	dc.b	$17,$f0,8,0,$1b,$f0,0,0
	dc.b	0,0,$1f,$f0,'$',0,$18,0
	dc.b	'<',0,'<',0,0,0,0,0
	dcb.w	2
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dcb.w	12
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dcb.w	4
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	0,0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,0,0,$1f,$f0
	dcb.w	2
	dc.b	$1f,$f0,0,0,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$e,0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$e,0,$11,$f0,0,0,0,0
	dc.b	$1f,$f0,0,0,$1f,$f0,0,0
	dc.b	0,0,$1f,$f0,$a5,0,'f',0
	dc.b	$e7,0,$ff,0,0,0,0,0
	dcb.w	2
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dcb.w	12
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dcb.w	4
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	0,0,7,$c0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,0,0,7,$c0
	dcb.w	2
	dc.b	7,$c0,0,0,$f,$e0,$f,$e0
	dc.b	$f,$e0,$f,$e0,0,0,$f,$e0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	0,0,$f,$e0,0,0,0,0
	dc.b	$f,$e0,0,0,$f,$e0,0,0
	dc.b	0,0,$f,$e0,$a5,0,'f',0
	dc.b	$e7,0,$ff,0,0,0,0,0
	dcb.w	2
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dcb.w	4
	dc.b	3,$80,3,$80,3,$80,3,$80
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dcb.w	20
	dc.b	3,$80,3,$80,3,$80,3,$80
	dc.b	0,0,3,$80,3,$80,3,$80
	dc.b	3,$80,3,$80,0,0,3,$80
	dcb.w	2
	dc.b	3,$80,0,0,3,$80,0,0
	dc.b	0,0,3,$80,'$',0,$18,0
	dc.b	'<',0,'<',0,0,0,0,0
	dcb.w	2
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	3,$c0,3,$c0,3,$c0,3,$c0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dcb.w	4
	dc.b	3,$80,3,$80,3,$80,3,$80
	dc.b	3,$80,3,$80,3,$80,3,$80
	dc.b	3,$80,3,$80,3,$80,0,0
	dcb.w	2
	dc.b	3,$80,0,0,1,0,1,0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,0,0,0,0,0,0
	dc.b	1,0,0,0,1,0,0,0
	dc.b	0,0,1,0,$18,0,0,0
	dc.b	$18,0,$18,0,0,0,0,0
	dcb.w	2
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$f,$f0,$f,$f0,$f,$f0,$f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dcb.w	4
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$f,$c0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$d,$e0,$f,$e0,$d,$c0,2,' '
	dcb.w	2
	dc.b	$f,$e0,3,0,1,0,1,0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,0,0,0,0,0,0
	dc.b	1,0,0,0,1,0,0,0
	dc.b	0,0,1,0,'B',0,'$',0
	dc.b	'f',0,'~',0,0,0,0,0
	dcb.w	2
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$f,$f8,$f,$f8,$f,$f8,$f,$f8
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dcb.w	4
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$19,$e0,$19,$f0,$19,$f0,$1f,$f0
	dc.b	$18,$f0,$19,$f0,$18,$e0,7,$10
	dcb.w	2
	dc.b	$19,$f0,7,0,3,$80,3,$80
	dc.b	3,$80,3,$80,3,$80,3,$80
	dc.b	3,$80,3,$80,3,$80,3,$80
	dc.b	3,$80,0,0,0,0,0,0
	dc.b	3,$80,0,0,3,$80,0,0
	dc.b	0,0,3,$80,'B',0,'$',0
	dc.b	'f',0,'~',0,0,0,0,0
	dcb.w	2
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dcb.w	4
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$17,$e0,$17,$f0,$17,$f0,$1f,$f0
	dc.b	$11,$f0,$17,$f0,$11,$e0,$e,$10
	dcb.w	2
	dc.b	$17,$f0,$e,0,3,$80,3,$80
	dc.b	3,$80,3,$80,2,$80,2,$80
	dc.b	2,$80,3,$80,2,$80,2,$80
	dc.b	2,$80,1,0,0,0,0,0
	dc.b	2,$80,1,0,2,$80,0,0
	dc.b	0,0,3,$80,$18,0,0,0
	dc.b	$18,0,$18,0,0,0,0,0
	dcb.w	2
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dcb.w	4
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$e0,'?',$f8,'?',$f8,'?',$f8
	dc.b	'7',$f8,'?',$f8,'7',$e0,8,$18
	dcb.w	2
	dc.b	'?',$f8,$18,0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,5,$c0,5,$c0
	dc.b	5,$c0,7,$c0,5,$c0,5,$c0
	dc.b	5,$c0,2,0,0,0,0,0
	dc.b	5,$c0,2,0,5,$c0,0,0
	dc.b	0,0,7,$c0,0,0,$18,0
	dc.b	$18,0,$18,0,0,0,0,0
	dcb.w	2
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dcb.w	4
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$e0,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f8,'?',$f8,'?',$e0,0,$18
	dcb.w	2
	dc.b	'?',$f8,0,0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,5,$c0,5,$c0
	dc.b	5,$c0,7,$c0,5,$c0,5,$c0
	dc.b	5,$c0,2,0,0,0,0,0
	dc.b	5,$c0,2,0,5,$c0,0,0
	dc.b	0,0,7,$c0,'$',0,$81,0
	dc.b	$a5,0,$bd,0,0,0,0,0
	dcb.w	2
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dcb.w	4
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$e0,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f8,'?',$f8,'?',$e0,0,$18
	dcb.w	2
	dc.b	'?',$f8,0,0,$f,$e0,$f,$e0
	dc.b	$f,$e0,$f,$e0,$b,$e0,$b,$e0
	dc.b	$b,$e0,$f,$e0,$b,$e0,$b,$e0
	dc.b	$b,$e0,4,0,0,0,0,0
	dc.b	$b,$e0,4,0,$b,$e0,0,0
	dc.b	0,0,$f,$e0,'$',0,$81,0
	dc.b	$a5,0,$bd,0,0,0,0,0
	dcb.w	2
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$f,$f0,$f,$f0,$f,$f0,$f,$f0
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dcb.w	4
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$c0,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f8,'?',$f8,'?',$c0,0,'8'
	dcb.w	2
	dc.b	'?',$f8,0,0,$f,$e0,$f,$e0
	dc.b	$f,$e0,$f,$e0,$b,$c0,$b,$e0
	dc.b	$b,$e0,$f,$e0,$b,$e0,$b,$e0
	dc.b	$b,$c0,4,' ',0,0,0,0
	dc.b	$b,$e0,4,0,$b,$e0,0,0
	dc.b	0,0,$f,$e0,0,0,$18,0
	dc.b	$18,0,$18,0,0,0,0,0
	dcb.w	2
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	3,$80,3,$80,3,$80,3,$80
	dc.b	3,$c0,3,$c0,3,$c0,3,$c0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dcb.w	4
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$c0,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f8,'?',$f8,'?',$c0,0,'8'
	dcb.w	2
	dc.b	'?',$f8,0,0,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$c0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$1f,$c0,0,'0',0,0,0,0
	dc.b	$1f,$f0,0,0,$1f,$f0,0,0
	dc.b	0,0,$1f,$f0,0,0,0,0
	dc.b	$18,0,0,0,0,0,0,0
	dcb.w	2
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dcb.w	16
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$1f,$80,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$80,0,'p'
	dcb.w	2
	dc.b	$1f,$f0,0,0,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1b,$80,$1b,$f0
	dc.b	$1b,$f0,$1f,$f0,$1b,$f0,$1b,$f0
	dc.b	$1b,$80,4,'p',0,0,0,0
	dc.b	$1b,$f0,4,0,$1b,$f0,0,0
	dc.b	0,0,$1f,$f0,0,0,0,0
	dc.b	'f',0,'<',0,0,0,0,0
	dcb.w	2
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dcb.w	16
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$e,' ',$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$1f,$d0,$1f,$f0,$e,0,$11,$f0
	dcb.w	2
	dc.b	$1f,$f0,0,' ',$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$e,0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$e,0,$11,$f0,0,0,0,0
	dc.b	$1f,$f0,0,0,$1f,$f0,0,0
	dc.b	0,0,$1f,$f0,0,0,0,0
	dc.b	'f',0,'<',0,0,0,0,0
	dcb.w	2
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dcb.w	16
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	0,0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$f,$e0,$f,$e0,0,0,$f,$e0
	dcb.w	2
	dc.b	$f,$e0,0,0,$f,$e0,$f,$e0
	dc.b	$f,$e0,$f,$e0,0,0,$f,$e0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	0,0,$f,$e0,0,0,0,0
	dc.b	$f,$e0,0,0,$f,$e0,0,0
	dc.b	0,0,$f,$e0,0,0,0,0
	dc.b	$18,0,0,0,0,0,0,0
	dcb.w	4
	dc.b	3,$c0,0,0,0,0,0,0
	dc.b	3,$c0,0,0,0,0,0,0
	dc.b	3,$c0,0,0,0,0,0,0
	dc.b	3,$c0,0,0,0,0,0,0
	dc.b	3,$c0,3,$c0,0,0,0,0
	dc.b	3,$c0,0,0,0,0,0,0
	dc.b	3,$c0,0,0,0,0,0,0
	dc.b	3,$c0,0,0,3,$c0,3,$c0
	dc.b	3,$c0,3,$c0,3,$80,3,$80
	dc.b	3,$80,3,$80,0,0,3,$80
	dc.b	3,$80,3,$80,3,$80,3,$80
	dc.b	0,0,3,$80,0,0,0,0
	dc.b	3,$80,0,0,3,$80,3,$80
	dc.b	3,$80,3,$80,0,0,3,$80
	dc.b	3,$80,3,$80,3,$80,3,$80
	dc.b	0,0,3,$80,0,0,0,0
	dc.b	3,$80,0,0,3,$80,0,0
	dc.b	0,0,3,$80,0,0,0,0
	dc.b	'<',0,$18,0,0,0,0,0
	dcb.w	4
	dc.b	4,' ',0,0,0,0,0,0
	dc.b	6,' ',4,0,0,0,4,0
	dc.b	7,$e0,2,0,0,0,6,0
	dc.b	7,$e0,1,0,0,0,4,' '
	dc.b	4,' ',3,$c0,0,0,0,'`'
	dc.b	7,$e0,1,$80,0,0,0,' '
	dc.b	7,$e0,0,$c0,0,0,0,0
	dc.b	4,'`',0,' ',7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,0,0,0,0
	dcb.w	14
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,1,0,1,0,0,0
	dcb.w	2
	dc.b	1,0,0,0,1,0,0,0
	dc.b	0,0,1,0,0,0,'$',0
	dc.b	$e7,0,'Z',0,0,0,0,0
	dcb.w	4
	dc.b	4,' ',0,0,0,0,4,0
	dc.b	7,' ',0,0,0,0,$e,0
	dc.b	$f,$e0,1,0,0,0,9,0
	dc.b	9,$e0,6,$80,0,0,0,0
	dc.b	8,$10,$f,$f0,0,0,0,$90
	dc.b	7,$90,3,'`',0,0,0,'p'
	dc.b	7,$f0,1,$80,0,0,0,' '
	dc.b	4,$e0,0,0,$f,$f0,$f,$f0
	dc.b	$f,$f0,$f,$f0,0,0,0,0
	dcb.w	14
	dc.b	3,$80,3,$80,3,$80,3,$80
	dc.b	3,$80,3,$80,3,$80,3,$80
	dc.b	3,$80,3,$80,3,$80,0,0
	dcb.w	2
	dc.b	3,$80,0,0,3,$80,0,0
	dc.b	0,0,3,$80,0,0,'$',0
	dc.b	$e7,0,'Z',0,0,0,0,0
	dcb.w	4
	dc.b	4,' ',0,0,0,0,4,0
	dc.b	7,' ',0,0,0,0,$a,0
	dc.b	$b,$e0,5,0,0,0,0,$80
	dc.b	0,$e0,$f,0,0,0,0,0
	dc.b	8,$10,$f,$f0,0,0,1,0
	dc.b	7,0,2,$f0,0,0,0,'P'
	dc.b	7,$d0,1,$a0,0,0,0,' '
	dc.b	4,$e0,0,0,$f,$f0,$f,$f0
	dc.b	$f,$f0,$f,$f0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,3,$80,7,$c0
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	3,$80,4,'@',0,0,0,0
	dc.b	7,$c0,0,0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,6,$c0,6,$c0
	dc.b	6,$c0,7,$c0,6,$c0,6,$c0
	dc.b	6,$c0,1,0,0,0,0,0
	dc.b	6,$c0,1,0,6,$c0,0,0
	dc.b	0,0,7,$c0,0,0,0,0
	dc.b	'<',0,$18,0,0,0,0,0
	dcb.w	4
	dc.b	4,' ',0,0,0,0,4,0
	dc.b	7,' ',0,0,0,0,$e,0
	dc.b	$f,$e0,1,0,0,0,9,0
	dc.b	9,$e0,6,$80,0,0,0,0
	dc.b	8,$10,$f,$f0,0,0,0,$90
	dc.b	7,$90,3,'`',0,0,0,'p'
	dc.b	7,$f0,1,$80,0,0,0,' '
	dc.b	4,$e0,0,0,$f,$f0,$f,$f0
	dc.b	$f,$f0,$f,$f0,'?',$f0,'?',$f0
	dc.b	'?',$f0,'?',$f0,'?',$f8,'?',$f0
	dc.b	'?',$f8,'?',$f8,';',$f8,'?',$f8
	dc.b	';',$f0,4,8,0,0,0,0
	dc.b	'?',$f8,4,0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,4,$c0,4,$c0
	dc.b	4,$c0,7,$c0,4,$c0,4,$c0
	dc.b	4,$c0,3,0,0,0,0,0
	dc.b	4,$c0,3,0,4,$c0,0,0
	dc.b	0,0,7,$c0,0,0,$18,0
	dc.b	$18,0,0,0,0,0,0,0
	dcb.w	4
	dc.b	4,' ',0,0,0,0,0,0
	dc.b	6,' ',4,0,0,0,4,0
	dc.b	7,$e0,2,0,0,0,6,0
	dc.b	7,$e0,1,0,0,0,4,' '
	dc.b	4,' ',3,$c0,0,0,0,'`'
	dc.b	7,$e0,1,$80,0,0,0,' '
	dc.b	7,$e0,0,$c0,0,0,0,0
	dc.b	4,'`',0,' ',7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,$7f,$fc,$7f,$fc
	dc.b	$7f,$fc,$7f,$fc,'g',$f8,'g',$fc
	dc.b	'g',$fc,$7f,$fc,'c',$fc,'g',$fc
	dc.b	'c',$f8,$1c,4,0,0,0,0
	dc.b	'g',$fc,$1c,0,$f,$e0,$f,$e0
	dc.b	$f,$e0,$f,$e0,$d,$e0,$d,$e0
	dc.b	$d,$e0,$f,$e0,$d,$e0,$d,$e0
	dc.b	$d,$e0,2,0,0,0,0,0
	dc.b	$d,$e0,2,0,$d,$e0,0,0
	dc.b	0,0,$f,$e0,0,0,'$',0
	dc.b	$e7,0,'Z',0,0,0,0,0
	dcb.w	4
	dc.b	6,'`',4,0,0,0,0,0
	dc.b	6,'`',4,0,0,0,0,0
	dc.b	7,$e0,4,0,0,0,0,0
	dc.b	7,$e0,4,0,0,0,0,0
	dc.b	7,$e0,4,0,0,0,0,0
	dc.b	7,$e0,4,0,0,0,0,0
	dc.b	7,$e0,4,0,0,0,0,0
	dc.b	6,'`',4,0,3,$c0,3,$c0
	dc.b	3,$c0,3,$c0,$ff,$fe,$ff,$fe
	dc.b	$ff,$fe,$ff,$fe,$df,$f8,$df,$fe
	dc.b	$df,$fe,$ff,$fe,$8f,$fe,$df,$fe
	dc.b	$8f,$f8,'p',6,0,0,0,0
	dc.b	$df,$fe,'8',0,$f,$e0,$f,$e0
	dc.b	$f,$e0,$f,$e0,9,$e0,9,$e0
	dc.b	9,$e0,$f,$e0,9,$e0,9,$e0
	dc.b	9,$e0,6,0,0,0,0,0
	dc.b	9,$e0,6,0,9,$e0,0,0
	dc.b	0,0,$f,$e0,0,0,'$',0
	dc.b	$e7,0,'Z',0,0,0,0,0
	dcb.w	4
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,$ff,$fe,$ff,$fe
	dc.b	$ff,$fe,$ff,$fe,$ff,$f8,$ff,$fe
	dc.b	$ff,$fe,$ff,$fe,$9f,$fe,$ff,$fe
	dc.b	$9f,$f8,'`',6,0,0,0,0
	dc.b	$ff,$fe,' ',0,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1b,$f0,$1b,$f0
	dc.b	$1b,$f0,$1f,$f0,$1b,$f0,$1b,$f0
	dc.b	$1b,$e0,4,$10,0,0,0,0
	dc.b	$1b,$f0,4,0,$1b,$f0,0,0
	dc.b	0,0,$1f,$f0,0,0,$18,0
	dc.b	$18,0,0,0,0,0,0,0
	dcb.w	4
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,$f,$f0,$f,$f0
	dc.b	$f,$f0,$f,$f0,$ff,$fe,$ff,$fe
	dc.b	$ff,$fe,$ff,$fe,$ff,$f0,$ff,$fe
	dc.b	$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe
	dc.b	$ff,$f0,0,$e,0,0,0,0
	dc.b	$ff,$fe,0,0,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$c0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$1f,$c0,0,'0',0,0,0,0
	dc.b	$1f,$f0,0,0,$1f,$f0,0,0
	dc.b	0,0,$1f,$f0,0,0,0,0
	dc.b	$18,0,$18,0,0,0,0,0
	dcb.w	4
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,0,0,0,0
	dc.b	$f,$f0,$c,0,$f,$f0,$f,$f0
	dc.b	$f,$f0,$f,$f0,$7f,$fc,$7f,$fc
	dc.b	$7f,$fc,$7f,$fc,$7f,$d0,$7f,$fc
	dc.b	$7f,$fc,$7f,$fc,$7f,$ec,$7f,$fc
	dc.b	$7f,$c0,0,'<',0,0,0,0
	dc.b	$7f,$fc,0,$10,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1b,$c0,$1b,$f0
	dc.b	$1b,$f0,$1f,$f0,$1b,$f0,$1b,$f0
	dc.b	$1b,$c0,4,'0',0,0,0,0
	dc.b	$1b,$f0,4,0,$1b,$f0,0,0
	dc.b	0,0,$1f,$f0,0,0,0,0
	dc.b	$a5,0,$18,0,0,0,0,0
	dcb.w	4
	dc.b	$f,$f0,8,0,0,0,0,0
	dc.b	$f,$f0,8,0,0,0,0,0
	dc.b	$f,$f0,8,0,0,0,0,0
	dc.b	$f,$f0,8,0,0,0,0,0
	dc.b	$f,$f0,8,0,0,0,0,0
	dc.b	$f,$f0,8,0,0,0,0,0
	dc.b	$f,$f0,8,0,0,0,0,0
	dc.b	$f,$f0,8,0,$f,$f0,$f,$f0
	dc.b	$f,$f0,$f,$f0,'?',$f0,'?',$f0
	dc.b	'?',$f0,'?',$f0,$1f,8,'?',$f0
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	$1f,0,' ',$f8,0,0,0,0
	dc.b	'?',$f8,0,0,$f,$e0,$f,$e0
	dc.b	$f,$e0,$f,$e0,$f,$80,$f,$e0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$f,$80,0,'`',0,0,0,0
	dc.b	$f,$e0,0,0,$f,$e0,0,0
	dc.b	0,0,$f,$e0,0,0,0,0
	dc.b	$a5,0,$18,0,0,0,0,0
	dcb.w	4
	dc.b	$1e,'x',$19,$80,0,0,0,0
	dc.b	$1e,'x',$19,$80,0,0,0,0
	dc.b	$1e,'x',$19,$80,0,0,0,0
	dc.b	$1e,'x',$19,$80,0,0,0,0
	dc.b	$1e,'x',$19,$80,0,0,0,0
	dc.b	$1e,'x',$19,$80,0,0,0,0
	dc.b	$1e,'x',$19,$80,0,0,0,0
	dc.b	$1e,'x',$19,$80,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,4,'@',3,$80
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	0,0,7,$c0,0,0,0,0
	dc.b	7,$c0,0,0,$f,$e0,$f,$e0
	dc.b	$f,$e0,$f,$e0,7,0,$f,$e0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	7,0,8,$e0,0,0,0,0
	dc.b	$f,$e0,0,0,$f,$e0,0,0
	dc.b	0,0,$f,$e0,0,0,0,0
	dc.b	$18,0,$18,0,0,0,0,0
	dcb.w	4
	dc.b	$c,'0',3,$c0,0,0,0,0
	dc.b	$c,'0',3,$c0,0,0,0,0
	dc.b	$c,'0',3,$c0,0,0,0,0
	dc.b	$c,'0',3,$c0,0,0,0,0
	dc.b	$c,'0',3,$c0,0,0,0,0
	dc.b	$c,'0',3,$c0,0,0,0,0
	dc.b	$c,'0',3,$c0,0,0,0,0
	dc.b	$c,'0',3,$c0,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,0,0,0,0
	dcb.w	14
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	0,0,7,$c0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,0,0,7,$c0
	dcb.w	2
	dc.b	7,$c0,0,0,7,$c0,0,0
	dc.b	0,0,7,$c0,$18,0,$18,0
	dc.b	0,0,$18,0,0,0,0,0
	dcb.w	4
	dc.b	'2L!',$84,0,0,0,0
	dc.b	'2L!',$84,0,0,0,0
	dc.b	'2L!',$84,0,0,0,0
	dc.b	'2L!',$84,0,0,0,0
	dc.b	'2L!',$84,0,0,0,0
	dc.b	'2L!',$84,0,0,0,0
	dc.b	'2L!',$84,0,0,0,0
	dc.b	'2L!„?',$fc,'?',$fc
	dc.b	'?',$fc,'?',$fc,0,0,0,0
	dcb.w	14
	dc.b	3,$80,3,$80,3,$80,3,$80
	dc.b	0,0,3,$80,3,$80,3,$80
	dc.b	3,$80,3,$80,0,0,3,$80
	dcb.w	2
	dc.b	3,$80,0,0,3,$80,0,0
	dc.b	0,0,3,$80,'B',0,'f',0
	dc.b	0,0,'~',0,0,0,0,0
	dcb.w	4
	dc.b	$1f,$f8,0,0,0,0,0,0
	dc.b	$1f,$f8,0,0,0,0,0,0
	dc.b	$1f,$f8,0,0,0,0,0,0
	dc.b	$1f,$f8,0,0,0,0,0,0
	dc.b	$1f,$f8,0,0,0,0,0,0
	dc.b	$1f,$f8,0,0,0,0,0,0
	dc.b	$1f,$f8,0,0,0,0,0,0
	dc.b	$1f,$f8,0,0,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,0,0,0,0
	dcb.w	14
	dc.b	1,0,1,0,1,0,1,0
	dcb.w	4
	dc.b	1,0,1,0,1,0,0,0
	dcb.w	2
	dc.b	1,0,0,0,1,0,0,0
	dc.b	0,0,1,0,'B',0,'f',0
	dc.b	0,0,'~',0,0,0,0,0
	dcb.w	4
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,0,0,0,0
	dcb.w	34
	dc.b	$18,0,$18,0,0,0,$18,0
	dcb.w	4
	dc.b	2,$80,1,0,3,$80,3,$80
	dcb.w	12
	dc.b	2,$80,1,0,3,$80,3,$80
	dc.b	4,'@',3,$80,7,$c0,7,$c0
	dc.b	5,'@',3,$80,7,$c0,7,$c0
	dc.b	4,'@',3,$80,7,$c0,7,$c0
	dc.b	3,$e0,3,$e0,3,$e0,3,$e0
	dcb.w	16
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,1,0,1,0,0,0
	dcb.w	2
	dc.b	1,0,0,0,1,0,0,0
	dc.b	0,0,1,0,'<',0,'<',0
	dc.b	$18,0,'$',0,0,0,0,0
	dcb.w	2
	dc.b	5,'@',3,$80,7,$c0,7,$c0
	dc.b	1,0,0,0,1,0,1,0
	dcb.w	4
	dc.b	1,0,0,0,1,0,1,0
	dc.b	5,'@',3,$80,7,$c0,7,$c0
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	7,$f0,7,$f0,7,$f0,7,$f0
	dcb.w	16
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,1,0,1,0,0,0
	dcb.w	2
	dc.b	1,0,0,0,1,0,0,0
	dc.b	0,0,1,0,$c3,0,$e7,0
	dc.b	'B',0,$bd,0,0,0,0,0
	dcb.w	2
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	6,$c0,1,0,7,$c0,7,$c0
	dcb.w	4
	dc.b	6,$c0,1,0,7,$c0,7,$c0
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	$f,$f8,$f,$f8,$f,$f8,$f,$f8
	dcb.w	16
	dc.b	3,0,3,0,3,0,3,0
	dc.b	3,0,3,0,3,0,3,0
	dc.b	3,0,3,0,3,0,0,0
	dcb.w	2
	dc.b	3,0,0,0,3,0,0,0
	dc.b	0,0,3,0,$c3,0,$e7,0
	dc.b	'B',0,$bd,0,0,0,0,0
	dcb.w	2
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	$19,'0',7,$c0,$1f,$f0,$1f,$f0
	dc.b	1,0,0,0,1,0,1,0
	dc.b	$19,'0',7,$c0,$1f,$f0,$1f,$f0
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	$f,$f8,$f,$f8,$f,$f8,$f,$f8
	dcb.w	16
	dc.b	$13,$88,$13,$88,$13,$88,$13,$88
	dc.b	$13,$88,$13,$88,$13,$88,$13,$88
	dc.b	$13,$88,$13,$88,$13,$80,0,8
	dcb.w	2
	dc.b	$13,$88,0,0,$13,$88,0,0
	dc.b	0,0,$13,$88,'<',0,'<',0
	dc.b	$18,0,'$',0,0,0,0,0
	dcb.w	2
	dc.b	'*',$a8,$1b,$b0,';',$b8,'?',$f8
	dc.b	'&',$c8,$1e,$f0,'>',$f8,'?',$f8
	dc.b	'>',$f8,1,0,'?',$f8,'?',$f8
	dc.b	'&',$c8,$1e,$f0,'>',$f8,'?',$f8
	dc.b	'*',$a8,$1b,$b0,';',$b8,'?',$f8
	dc.b	'+',$a8,$1a,$b0,';',$b8,'?',$f8
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	'+',$a8,$1a,$b0,';',$b8,'?',$f8
	dc.b	$1f,$fc,$1f,$fc,$1f,$fc,$1f,$fc
	dcb.w	16
	dc.b	1,'@',1,'@',1,'@',1,'@'
	dc.b	1,'@',1,'@',1,'@',1,'@'
	dc.b	1,'@',1,'@',1,'@',0,0
	dcb.w	2
	dc.b	1,'@',0,0,1,'@',0,0
	dc.b	0,0,1,'@',$18,0,$18,0
	dc.b	$18,0,0,0,0,0,0,0
	dcb.w	2
	dc.b	'UT6',$d8,'w',$dc,$7f,$fc
	dc.b	'Y498y<',$7f,$fc
	dc.b	'A',4,'?',$f8,$7f,$fc,$7f,$fc
	dc.b	'Y498y<',$7f,$fc
	dc.b	'UT6',$d8,'w',$dc,$7f,$fc
	dc.b	'+',$a8,$1a,$b0,';',$b8,'?',$f8
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	'+',$a8,$1a,$b0,';',$b8,'?',$f8
	dc.b	'?',$fe,'?',$fe,'?',$fe,'?',$fe
	dcb.w	16
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,7,$c0,0,0
	dcb.w	2
	dc.b	7,$c0,0,0,7,$c0,0,0
	dc.b	0,0,7,$c0,$c3,0,$e7,0
	dc.b	'B',0,$bd,0,0,0,0,0
	dcb.w	2
	dc.b	$aa,$aa,'ll',$ee,$ee,$fe,$fe
	dc.b	$a6,$ca,'f',$cc,$e6,$ce,$fe,$fe
	dc.b	$be,$fa,'~',$fc,$fe,$fe,$ff,$fe
	dc.b	$a6,$ca,'f',$cc,$e6,$ce,$fe,$fe
	dc.b	$aa,$aa,'ll',$ee,$ee,$fe,$fe
	dc.b	'UT6',$d8,'w',$dc,$7f,$fc
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	'UT6',$d8,'w',$dc,$7f,$fc
	dc.b	$7f,$ff,$7f,$ff,$7f,$ff,$7f,$ff
	dcb.w	16
	dc.b	'-h-h-h-h'
	dc.b	'-H-h-h-h'
	dc.b	'-h-h-`',0,8
	dcb.w	2
	dc.b	'-h',0,0,'-h',0,0
	dc.b	0,0,'-h',$c3,0,$e7,0
	dc.b	'B',0,$bd,0,0,0,0,0
	dcb.w	2
	dc.b	'TU',$d8,'6',$dc,'w',$fc,$7f
	dc.b	'X4',$d8,'6',$d8,'6',$f8,'>'
	dc.b	'@',4,$c0,6,$c0,6,$ff,$fe
	dc.b	'X4',$d8,'6',$d8,'6',$f8,'>'
	dc.b	'TU',$d8,'6',$dc,'w',$fc,$7f
	dc.b	'UT6',$d8,'w',$dc,$7f,$fc
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	'UT6',$d8,'w',$dc,$7f,$fc
	dc.b	$7f,$ff,$7f,$ff,$7f,$ff,$7f,$ff
	dcb.w	16
	dc.b	$17,$b0,$17,$b0,$17,$b0,$17,$b0
	dc.b	$17,$80,$17,$b0,$17,$b0,$17,$b0
	dc.b	$17,$b0,$17,$b0,$17,$a0,0,$10
	dcb.w	2
	dc.b	$17,$b0,0,0,$17,$b0,0,0
	dc.b	0,0,$17,$b0,$18,0,$18,0
	dc.b	$18,0,0,0,0,0,0,0
	dcb.w	2
	dc.b	$aa,$aa,'ll',$ee,$ee,$fe,$fe
	dc.b	$a6,$ca,'f',$cc,$e6,$ce,$fe,$fe
	dc.b	$be,$fa,'~',$fc,$fe,$fe,$ff,$fe
	dc.b	$a6,$ca,'f',$cc,$e6,$ce,$fe,$fe
	dc.b	$aa,$aa,'ll',$ee,$ee,$fe,$fe
	dc.b	'UT6',$d8,'w',$dc,$7f,$fc
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	'UT6',$d8,'w',$dc,$7f,$fc
	dc.b	$7f,$ff,$7f,$ff,$7f,$ff,$7f,$ff
	dcb.w	16
	dc.b	$17,$e0,$17,$e0,$17,$e0,$17,$e0
	dc.b	6,0,$17,$e0,$17,$e0,$17,$e0
	dc.b	$17,$e0,$17,$e0,6,0,$11,$e0
	dcb.w	2
	dc.b	$17,$e0,0,0,$17,$e0,0,0
	dc.b	0,0,$17,$e0,$18,0,$18,0
	dc.b	$18,0,0,0,0,0,0,0
	dcb.w	2
	dc.b	'UT6',$d8,'w',$dc,$7f,$fc
	dc.b	'Y498y<',$7f,$fc
	dc.b	'A',4,'?',$f8,$7f,$fc,$7f,$fc
	dc.b	'Y498y<',$7f,$fc
	dc.b	'UT6',$d8,'w',$dc,$7f,$fc
	dc.b	'+',$a8,$1a,$b0,';',$b8,'?',$f8
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	'+',$a8,$1a,$b0,';',$b8,'?',$f8
	dc.b	'?',$fe,'?',$fe,'?',$fe,'?',$fe
	dcb.w	16
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	0,0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$f,$e0,$f,$e0,0,0,$f,$e0
	dcb.w	2
	dc.b	$f,$e0,0,0,$f,$e0,0,0
	dc.b	0,0,$f,$e0,$a5,0,$a5,0
	dc.b	0,0,$bd,0,0,0,0,0
	dcb.w	2
	dc.b	'*',$a8,$1b,$b0,';',$b8,'?',$f8
	dc.b	'&',$c8,$1e,$f0,'>',$f8,'?',$f8
	dc.b	'>',$f8,1,0,'?',$f8,'?',$f8
	dc.b	'&',$c8,$1e,$f0,'>',$f8,'?',$f8
	dc.b	'*',$a8,$1b,$b0,';',$b8,'?',$f8
	dc.b	'+',$a8,$1a,$b0,';',$b8,'?',$f8
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	'+',$a8,$1a,$b0,';',$b8,'?',$f8
	dc.b	$1f,$fc,$1f,$fc,$1f,$fc,$1f,$fc
	dcb.w	16
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	0,0,7,$c0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,0,0,7,$c0
	dcb.w	2
	dc.b	7,$c0,0,0,7,$c0,0,0
	dc.b	0,0,7,$c0,$a5,0,$a5,0
	dc.b	0,0,$bd,0,0,0,0,0
	dcb.w	2
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	$19,'0',7,$c0,$1f,$f0,$1f,$f0
	dc.b	1,0,0,0,1,0,1,0
	dc.b	$19,'0',7,$c0,$1f,$f0,$1f,$f0
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	$f,$f8,$f,$f8,$f,$f8,$f,$f8
	dcb.w	36
	dc.b	$18,0,$18,0,$18,0,0,0
	dcb.w	4
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	6,$c0,1,0,7,$c0,7,$c0
	dcb.w	4
	dc.b	6,$c0,1,0,7,$c0,7,$c0
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	$f,$f8,$f,$f8,$f,$f8,$f,$f8
	dcb.w	44
	dc.b	5,'@',3,$80,7,$c0,7,$c0
	dcb.w	12
	dc.b	5,'@',3,$80,7,$c0,7,$c0
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	7,$f0,7,$f0,7,$f0,7,$f0
	dcb.w	16
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	1,0,1,0,1,0,0,0
	dcb.w	2
	dc.b	1,0,0,0,1,0,0,0
	dc.b	0,0,1,0,0,0,0,0
	dcb.w	6
	dc.b	2,$80,1,0,3,$80,3,$80
	dcb.w	12
	dc.b	2,$80,1,0,3,$80,3,$80
	dc.b	4,'@',3,$80,7,$c0,7,$c0
	dc.b	5,'@',3,$80,7,$c0,7,$c0
	dc.b	4,'@',3,$80,7,$c0,7,$c0
	dc.b	3,$e0,3,$e0,3,$e0,3,$e0
	dcb.w	92
	dc.b	0,1,0,1,0,1,0,1
	dc.b	$10,9,$10,9,$10,9,$10,9
	dc.b	$10,9,$10,9,$10,9,$10,9
	dc.b	$10,9,$10,9,$10,9,0,0
	dcb.w	2
	dc.b	$10,9,0,0,$10,8,0,0
	dc.b	0,0,$10,8,0,0,0,0
	dcb.w	6
	dc.b	3,$80,3,$80,3,$80,3,$80
	dcb.w	12
	dc.b	3,$80,3,$80,3,$80,3,$80
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	3,$e0,3,$e0,3,$e0,3,$e0
	dcb.w	44
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	1,0,1,0,1,0,1,0
	dcb.w	4
	dc.b	1,0,1,0,1,0,1,0
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	7,$f0,7,$f0,7,$f0,7,$f0
	dcb.w	44
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dcb.w	4
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$f,$f8,$f,$f8,$f,$f8,$f,$f8
	dcb.w	16
	dc.b	'(((((((('
	dc.b	'(',$a,'(*(*(*'
	dc.b	'((((((',0,0
	dcb.w	2
	dc.b	'((',0,0,'((',0,0
	dc.b	0,0,'((',0,0,0,0
	dcb.w	6
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$f,$f8,$f,$f8,$f,$f8,$f,$f8
	dcb.w	16
	dc.b	$94,$b0,$94,$b0,$94,$b0,$94,$b0
	dc.b	$94,$80,$94,$b0,$94,$b0,$94,$b0
	dc.b	$94,$b0,$94,$b0,$94,$a0,0,$10
	dcb.w	2
	dc.b	$94,$b0,0,0,$94,$b0,0,0
	dc.b	0,0,$94,$b0,0,0,0,0
	dcb.w	6
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	$1f,$fc,$1f,$fc,$1f,$fc,$1f,$fc
	dcb.w	16
	dc.b	3,'@',3,'@',3,'@',3,'@'
	dc.b	2,0,3,'@',3,'@',3,'@'
	dc.b	3,'@',3,'@',3,'@',0,0
	dcb.w	2
	dc.b	3,'@',0,0,3,'@',0,0
	dc.b	0,0,3,'@',0,0,0,0
	dcb.w	6
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$fe,'?',$fe,'?',$fe,'?',$fe
	dcb.w	16
	dc.b	'DhDhDhDh'
	dc.b	'@',8,'DhDhDh'
	dc.b	'DhDhD',8,0,'`'
	dcb.w	2
	dc.b	'Dh',0,0,'Dh',0,0
	dc.b	0,0,'Dh',0,0,0,0
	dcb.w	6
	dc.b	$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe
	dc.b	$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe
	dc.b	$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe
	dc.b	$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe
	dc.b	$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dcb.w	16
	dc.b	6,$80,6,$80,6,$80,6,$80
	dc.b	0,0,6,$80,6,$80,6,$80
	dc.b	6,$80,6,$80,0,0,6,$80
	dcb.w	2
	dc.b	6,$80,0,0,6,$80,0,0
	dc.b	0,0,6,$80,0,0,0,0
	dcb.w	6
	dc.b	$fc,$7f,$fc,$7f,$fc,$7f,$fc,$7f
	dc.b	$f8,'>',$f8,'>',$f8,'>',$f8,'>'
	dc.b	$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe
	dc.b	$f8,'>',$f8,'>',$f8,'>',$f8,'>'
	dc.b	$fc,$7f,$fc,$7f,$fc,$7f,$fc,$7f
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dcb.w	44
	dc.b	$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe
	dc.b	$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe
	dc.b	$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe
	dc.b	$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe
	dc.b	$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dcb.w	44
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	$7f,$fc,$7f,$fc,$7f,$fc,$7f,$fc
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$fe,'?',$fe,'?',$fe,'?',$fe
	dcb.w	44
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	'?',$f8,'?',$f8,'?',$f8,'?',$f8
	dc.b	$1f,$fc,$1f,$fc,$1f,$fc,$1f,$fc
	dcb.w	44
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$f,$f8,$f,$f8,$f,$f8,$f,$f8
	dcb.w	44
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dcb.w	4
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	$f,$f8,$f,$f8,$f,$f8,$f,$f8
	dcb.w	44
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dcb.w	12
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	$f,$e0,$f,$e0,$f,$e0,$f,$e0
	dc.b	7,$f0,7,$f0,7,$f0,7,$f0
	dcb.w	44
	dc.b	3,$80,3,$80,3,$80,3,$80
	dcb.w	12
	dc.b	3,$80,3,$80,3,$80,3,$80
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	3,$e0,3,$e0,3,$e0,3,$e0
	dcb.w	242
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	$80,0,0,0,0,0,0,0
	dcb.w	36
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	4,'@',7,$c0,0,0,0,0
	dc.b	0,0,$7f,$e0,0,0,0,0
	dc.b	$e,'p',7,$cc,0,0,0,' '
	dc.b	0,' ',$7f,$c0,0,0,0,0
	dc.b	0,0,$7f,$fc,0,0,0,0
	dc.b	0,0,$7f,$fc,0,0,0,0
	dc.b	$e,'p',7,$cc,0,0,0,0
	dc.b	0,0,'||',0,0,0,0
	dc.b	0,0,$1f,$e0,0,0,0,0
	dc.b	0,0,3,$fc,0,0,0,0
	dc.b	0,0,$ff,'>',0,0,0,0
	dc.b	0,0,'?',$c0,0,0,0,0
	dc.b	0,0,$fc,'~',0,0,0,0
	dc.b	0,0,$fe,'~',0,0,4,'@'
	dc.b	4,'@',3,$80,0,0,0,0
	dc.b	0,$10,$7f,$e0,0,0,0,0
	dc.b	$c,$e0,$b,$80,0,0,0,0
	dc.b	0,$10,$7f,$e0,0,0,0,0
	dc.b	0,0,$1f,$e8,0,0,0,0
	dc.b	0,0,$7f,$fe,0,0,0,0
	dc.b	0,' ',7,$c0,0,0,0,0
	dc.b	'3',$c0,$1e,'8',0,0,0,0
	dc.b	$18,$12,$f,$fc,0,0,0,'H'
	dc.b	3,$c8,'<0',0,0,0,0
	dc.b	3,$f2,'<',$1c,0,0,0,0
	dc.b	3,$f2,'<',$1c,0,0,0,0
	dc.b	$18,$12,$f,$fc,0,0,0,0
	dc.b	'FF||',0,0,0,0
	dc.b	$c,$f0,7,$80,0,0,0,0
	dc.b	1,$9e,0,$f0,0,0,0,0
	dc.b	'g',$87,'<',$18,0,0,0,0
	dc.b	$19,$e0,$f,0,0,0,0,0
	dc.b	6,3,'x<',0,0,0,0
	dc.b	3,$27,'<',$18,0,0,0,0
	dc.b	$11,$10,$1e,$f0,0,0,0,0
	dc.b	'3',$e4,$1e,'8',0,0,0,0
	dc.b	'0',$18,$1f,$f0,0,0,0,0
	dc.b	'3',$c4,$1e,'8',0,0,0,0
	dc.b	1,$c4,'>8',0,0,0,0
	dc.b	'<=c',$c6,0,0,5,$c0
	dc.b	$f,$e0,2,0,0,0,$c,$1c
	dc.b	$1f,$1c,$12,0,0,0,$1c,$1c
	dc.b	'?',$fe,2,' ',0,0,$18,'8'
	dc.b	'><$',0,0,0,'<',4
	dc.b	'>',$1e,0,8,0,0,'<',4
	dc.b	'>',$1e,0,8,0,0,$1c,$1c
	dc.b	'?',$fe,2,' ',0,0,'88'
	dc.b	'>>',0,0,0,0,3,0
	dc.b	7,$e0,4,$80,0,0,0,'`'
	dc.b	0,$fc,0,$90,0,0,$18,'0'
	dc.b	'?<$',0,0,0,6,0
	dc.b	$f,$c0,9,0,0,0,'x<'
	dc.b	'|>',0,0,0,0,'>',$18
	dc.b	'>',$1c,0,0,0,0,'88'
	dc.b	'?',$f8,0,0,0,0,$c,$1c
	dc.b	$1f,$9c,$12,0,0,0,'88'
	dc.b	$7f,$fc,4,'@',0,0,$c,$1c
	dc.b	$1f,$9c,$12,0,0,0,'<',8
	dc.b	'?',$1c,0,$10,0,0,'C',$c2
	dc.b	'{',$e7,0,0,0,0,0,0
	dc.b	$a,'0',$d,$e0,0,0,0,0
	dc.b	$13,2,$1e,$1c,0,0,0,0
	dc.b	7,$12,'<',$1c,0,0,'$$'
	dc.b	'&$',$18,$18,0,0,0,0
	dc.b	2,$a,'<',4,0,0,0,0
	dc.b	2,$a,'<',4,0,0,0,0
	dc.b	7,$12,'<',$1c,0,0,0,0
	dc.b	4,4,'88',0,0,0,0
	dc.b	4,$c0,7,$80,0,0,0,0
	dc.b	0,$98,0,$f0,0,0,0,0
	dc.b	'&',$18,'<`',0,0,0,0
	dc.b	9,$80,$f,0,0,0,0,0
	dc.b	0,2,'||',0,0,0,0
	dc.b	1,4,'>',$18,0,0,0,0
	dc.b	$c,' p',$1c,0,0,0,0
	dc.b	$13,2,$1e,$1c,0,0,0,0
	dc.b	$f,' x<',0,0,0,0
	dc.b	$13,2,$1e,$1c,0,0,0,0
	dc.b	2,$c,'<',0,0,0,0,0
	dc.b	'2aC',$c2,0,0,0,0
	dc.b	2,$10,$d,$e0,0,0,0,0
	dc.b	$13,2,$1e,$1c,0,0,0,0
	dc.b	'N',$a,'8',4,0,0,'$$'
	dc.b	'&&',$18,$18,0,0,0,0
	dc.b	2,6,'<',$80,0,0,0,0
	dc.b	2,6,'<',$80,0,0,0,0
	dc.b	'N',$a,'8',4,0,0,0,0
	dc.b	4,4,'88',0,0,0,0
	dc.b	4,$c0,7,$80,0,0,0,0
	dc.b	0,$98,0,$f0,0,0,0,0
	dc.b	'&0<',$c0,0,0,0,0
	dc.b	9,$80,$f,0,0,0,0,0
	dc.b	2,2,'||',0,0,0,0
	dc.b	8,4,'7',$18,0,0,$10,$10
	dc.b	$18,$12,'`',$c,0,0,0,0
	dc.b	$13,2,$1e,$1c,0,0,0,0
	dc.b	$9c,$12,'p',$c,0,0,0,0
	dc.b	$13,2,$1e,$1c,0,0,0,0
	dc.b	0,0,'>',0,0,0,0,0
	dc.b	'"a',3,$c0,0,0,$d,$e0
	dc.b	$f,$f0,0,0,0,0,$c,'8'
	dc.b	$1f,'>',$12,0,0,0,'p',0
	dc.b	'|',6,0,0,0,0,$18,$18
	dc.b	'>>$$',0,0,'<',$80
	dc.b	'>',$c2,0,0,0,0,'<',$80
	dc.b	'>',$c2,0,0,0,0,'p',0
	dc.b	'|',6,0,0,0,0,'88'
	dc.b	'<<',0,0,0,0,3,0
	dc.b	7,$c0,4,$80,0,0,0,'`'
	dc.b	0,$f8,0,$90,0,0,$19,$c0
	dc.b	'?',$e0,'$',0,0,0,6,0
	dc.b	$f,$80,9,0,0,0,'~',$fc
	dc.b	'~',$fe,0,0,0,0,'7',$18
	dc.b	'?',$9c,0,0,0,0,$e0,$e
	dc.b	$f8,$1e,0,0,0,0,$c,$1c
	dc.b	$1f,$1e,$12,0,0,0,$e0,$e
	dc.b	$f8,$e,0,0,0,0,$c,'<'
	dc.b	$1f,'>',$12,0,0,0,$1f,0
	dc.b	$1f,$80,0,$80,0,0,3,$c0
	dc.b	3,$e0,0,0,0,0,0,0
	dc.b	$1e,$f8,$18,$f0,0,0,0,0
	dc.b	$1f,$fc,$1f,$f0,0,0,0,0
	dc.b	'x',2,'p',0,0,0,0,0
	dc.b	'>><<',0,0,0,0
	dc.b	'?',$c0,'?',$80,0,0,0,0
	dc.b	'?',$c0,'?',$80,0,0,0,0
	dc.b	'x',0,'p',0,0,0,0,0
	dc.b	'?',$fc,'?',$f8,0,0,0,0
	dc.b	7,$c0,7,$80,0,0,0,0
	dc.b	0,$f8,0,$f0,0,0,0,0
	dc.b	'?',$e0,'?',$c0,0,0,0,0
	dc.b	$f,$80,$f,0,0,0,0,0
	dc.b	$7f,$fe,'v',$dc,0,0,0,0
	dc.b	';',$9c,'3',$98,0,0,0,0
	dc.b	$f0,$f,$e0,$e,0,0,0,0
	dc.b	$1f,$fe,$1f,$f8,0,0,0,0
	dc.b	$f0,$f,$e0,$e,0,0,0,0
	dc.b	$1f,$fe,$1f,$f8,0,0,0,0
	dc.b	$f,$e0,$f,$e0,0,0,0,0
	dc.b	3,$e0,3,$c0,0,0,0,0
	dc.b	$1c,$f8,$18,$f0,0,0,0,0
	dc.b	$1f,$f8,$1e,'8',0,0,0,0
	dc.b	'x',0,'p',0,0,0,0,0
	dc.b	'>><<',0,0,0,0
	dc.b	'?',$c0,'<',$80,0,0,0,0
	dc.b	'?',$c0,'<',$80,0,0,0,0
	dc.b	'x',$fe,'p',$fe,0,0,0,0
	dc.b	'?',$fc,'88',0,0,0,0
	dc.b	7,$c0,7,$80,0,0,0,0
	dc.b	0,$f8,0,$f0,0,0,0,0
	dc.b	'?',$e0,'>',$e0,0,0,0,0
	dc.b	$f,$80,$f,0,0,0,0,0
	dc.b	$7f,$fe,'w',$dc,0,0,0,0
	dc.b	';',$dc,'3',$98,0,0,0,0
	dc.b	$f0,$f,$e0,$e,0,0,0,0
	dc.b	$1f,$fc,$1f,$e0,0,0,0,0
	dc.b	$f3,$8f,$e3,$8e,0,0,0,0
	dc.b	$1f,$fc,$1f,$e0,0,0,0,0
	dc.b	7,$f0,1,$f0,0,0,0,0
	dc.b	3,$e0,3,$c0,0,0,$1f,$f0
	dc.b	$1f,$f8,0,0,0,0,$c,$1c
	dc.b	$1f,$1c,$12,0,0,0,'p',0
	dc.b	'x',0,0,0,0,0,$18,$18
	dc.b	'>>$$',0,0,'<',$80
	dc.b	'>',$c0,0,0,0,0,'<',$80
	dc.b	'>',$c0,0,0,0,0,'p',$1c
	dc.b	'x',$7f,0,0,0,0,'88'
	dc.b	'<<',0,0,0,0,3,0
	dc.b	7,$c0,4,$80,0,0,0,'`'
	dc.b	0,$f8,0,$90,0,0,$18,'`'
	dc.b	'?p$',0,0,0,6,0
	dc.b	$f,$80,9,0,0,0,'w',$dc
	dc.b	$7f,$fe,0,0,0,0,'1',$d8
	dc.b	'9',$dc,0,0,0,0,$e0,$e
	dc.b	$f0,$f,0,0,0,0,$c,0
	dc.b	$1f,$f0,$12,0,0,0,$e0,$ce
	dc.b	$f1,$cf,0,0,0,0,$c,'p'
	dc.b	$1f,$f0,$12,0,0,0,0,'x'
	dc.b	1,$f8,0,0,0,0,3,$c0
	dc.b	3,$e0,0,0,0,0,'0x'
	dc.b	'?',$fc,8,0,0,0,$c,$1c
	dc.b	$1f,$1e,$12,0,0,0,'0',$c
	dc.b	'x',$c,8,0,0,0,$18,$18
	dc.b	'>>$$',0,0,'<',0
	dc.b	'>@',0,0,0,0,'<',0
	dc.b	'>@',0,0,0,0,'0',$1c
	dc.b	'|',$1e,8,0,0,0,'88'
	dc.b	'<<',0,0,0,0,3,0
	dc.b	7,$c0,4,$80,0,0,$18,'p'
	dc.b	$18,$f8,0,$80,0,0,$18,'p'
	dc.b	'>p$',0,0,0,6,0
	dc.b	$f,$80,9,0,0,0,'s',$9c
	dc.b	'{',$fe,0,0,0,0,'1',$d8
	dc.b	'9',$fc,0,0,0,0,'p',$1c
	dc.b	'x',$1f,0,0,0,0,$c,0
	dc.b	$1f,0,$12,0,0,0,'`|'
	dc.b	$f0,$7f,$10,0,0,0,$c,'p'
	dc.b	$1f,'x',$12,0,0,0,' ',0
	dc.b	' D',0,'8',0,0,3,$c0
	dc.b	3,$e0,0,0,0,0,0,0
	dc.b	$c,4,'0x',0,0,0,0
	dc.b	$13,2,$1e,$1c,0,0,0,0
	dc.b	4,$16,'<',$1c,0,0,'$$'
	dc.b	'&&',$18,$18,0,0,0,0
	dc.b	2,8,'<',4,0,0,0,0
	dc.b	2,0,'<',0,0,0,0,0
	dc.b	4,$12,'<',$1c,0,0,0,0
	dc.b	4,4,'88',0,0,0,0
	dc.b	4,$c0,7,$80,0,0,'$',0
	dc.b	'$',$98,$18,$e0,0,0,0,0
	dc.b	'&',8,'<0',0,0,0,0
	dc.b	9,$80,$f,0,0,0,0,0
	dc.b	8,'Bs',$9c,0,0,0,0
	dc.b	8,4,'0',$f8,0,0,0,0
	dc.b	8,2,'p',$1c,0,0,0,0
	dc.b	$13,0,$1e,0,0,0,0,0
	dc.b	8,'&x8',0,0,0,$a
	dc.b	$13,'J',$1e,'0',0,0,0,0
	dc.b	0,4,'08',0,0,0,0
	dc.b	2,'`',3,$c0,0,0,'`<'
	dc.b	'x>',0,0,0,0,0,0
	dc.b	$13,2,$1e,$1c,0,0,0,0
	dc.b	'"&',$1e,'8',0,0,'$',0
	dc.b	'&',6,$18,'8',0,0,0,0
	dc.b	2,$1a,'<',$c,0,0,0,0
	dc.b	2,0,'<',0,0,0,0,0
	dc.b	'""',$1e,'<',0,0,'88'
	dc.b	'<<',0,0,0,0,0,0
	dc.b	4,$c0,7,$80,0,0,'$',0
	dc.b	'&',$90,$18,$e0,0,0,0,0
	dc.b	'&',0,'<8',0,0,0,0
	dc.b	9,$88,$f,4,0,0,0,0
	dc.b	8,$c2,'q',$1c,0,0,0,0
	dc.b	8,4,'0',$f8,0,0,0,0
	dc.b	4,6,'88',0,0,0,0
	dc.b	$13,0,$1e,0,0,0,0,0
	dc.b	'DD<x',0,0,0,0
	dc.b	$13,5,$1e,':',0,0,0,'H'
	dc.b	0,'L80',0,0,3,$c0
	dc.b	3,$e0,0,0,0,0,0,0
	dc.b	'P',3,'`<',0,0,$e,'8'
	dc.b	$1f,'>',$10,0,0,0,$f,$f0
	dc.b	$1f,$fe,0,8,0,0,'<p'
	dc.b	'>|',0,8,0,0,'<',$c
	dc.b	'>>',0,$10,0,0,'<',0
	dc.b	'>',0,0,0,0,0,$f,$fc
	dc.b	$1f,$fe,0,0,0,0,0,0
	dc.b	'DD||',0,0,3,0
	dc.b	$f,$c0,4,$80,0,0,$19,$c0
	dc.b	$1f,$f0,0,0,0,0,$18,$18
	dc.b	'~',$1c,'$',0,0,0,6,0
	dc.b	$1f,$9a,9,$c,0,0,'q',$1c
	dc.b	'y',$9e,0,0,0,0,'0x'
	dc.b	'8|',0,0,0,0,$1e,$f0
	dc.b	$1e,$fc,0,0,0,0,$c,0
	dc.b	'?',0,$12,0,0,0,$1f,$fe
	dc.b	'?',$fe,0,0,0,0,$c,$1e
	dc.b	$1f,'?',$12,0,0,0,'?',$f0
	dc.b	'?',$fc,0,0,0,0,0,0
	dc.b	6,'`',3,$c0,0,0,0,0
	dc.b	$80,3,$f0,'~',0,0,0,0
	dc.b	0,$1c,$7f,$e0,0,0,0,0
	dc.b	4,'<',3,$e0,0,0,0,' '
	dc.b	0,'<',$7f,$c0,0,0,0,0
	dc.b	0,2,$7f,$fc,0,0,0,0
	dc.b	0,0,'~',0,0,0,0,0
	dc.b	4,':',3,$e4,0,0,0,0
	dc.b	2,2,'||',0,0,0,0
	dc.b	0,$10,$1f,$e0,0,0,8,$80
	dc.b	8,$e0,7,0,0,0,0,0
	dc.b	0,0,$ff,'>',0,0,0,0
	dc.b	0,2,'?',$fc,0,0,0,0
	dc.b	0,$80,$f8,'>',0,4,0,4
	dc.b	0,0,$fc,'x',0,0,4,'@'
	dc.b	$c,'x',3,$80,0,0,0,0
	dc.b	0,0,$7f,$80,0,0,0,0
	dc.b	8,'y',7,$c6,0,0,0,0
	dc.b	0,3,$7f,$8c,0,0,4,' '
	dc.b	$1c,'8#',$c0,0,0,0,0
	dc.b	0,$10,7,$e0,0,0,0,0
	dc.b	'x?',0,0,0,0,0,0
	dc.b	'?',$f0,0,0,0,0,0,0
	dc.b	1,$f0,0,0,0,0,0,0
	dc.b	'?',$f0,0,0,0,0,0,0
	dc.b	'?',$fe,0,0,0,0,0,0
	dc.b	'?',0,0,0,0,0,0,0
	dc.b	1,$f2,0,0,0,0,0,0
	dc.b	'>>',0,0,0,0,0,0
	dc.b	$f,$f0,0,0,0,0,0,0
	dc.b	7,$c0,0,0,0,0,0,0
	dc.b	$7f,$9f,0,0,0,0,0,0
	dc.b	$1f,$fe,0,0,0,0,0,0
	dc.b	'|',$1f,0,0,0,0,0,0
	dc.b	'~>',0,0,0,0,0,0
	dc.b	3,$e0,0,0,0,0,0,0
	dc.b	'?',$c0,0,0,0,0,0,0
	dc.b	7,$e3,0,0,0,0,0,0
	dc.b	'?',$c6,0,0,0,0,0,0
	dc.b	$17,$f0,0,0,0,0,0,0
	dc.b	3,$f0,0,0,0,0,0,0
	dcb.w	76
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	0,0,'~',$1e,0,0,0,0
	dc.b	0,0,'|>',0,0,0,0
	dc.b	0,0,$f8,'>',0,0,0,0
	dc.b	0,0,$fc,'?',0,0,0,0
	dc.b	0,0,$fc,$f,0,0,0,0
	dc.b	0,0,$7f,$f8,0,0,4,'@'
	dc.b	4,'@',3,$80,0,0,0,0
	dc.b	0,0,1,$c0,0,0,0,0
	dc.b	0,0,$f,$e0,0,0,0,0
	dc.b	0,0,7,$e0,0,0,0,0
	dc.b	0,0,0,'p',0,0,0,0
	dc.b	0,0,$f,$fc,0,0,2,0
	dc.b	6,0,1,$f8,0,0,0,0
	dc.b	0,0,$18,'8',0,0,4,8
	dc.b	$c,8,$b,$f0,0,0,0,0
	dc.b	0,0,7,$e0,0,0,0,0
	dcb.w	10
	dc.b	' ',0,0,0,' ',0,0,0
	dcb.w	2
	dc.b	'C',3,'|',$e,0,0,0,0
	dc.b	'F#|>',0,0,0,0
	dc.b	'L',7,'q',$1c,0,0,0,0
	dc.b	6,$13,'x',$c,0,0,0,0
	dc.b	6,1,'x',6,0,0,0,0
	dc.b	'?',$e4,'`8',0,0,0,0
	dc.b	$11,$10,$1e,$f0,0,0,0,0
	dc.b	0,' ',3,$c0,0,0,0,0
	dc.b	7,$80,$18,'x',0,0,0,0
	dc.b	3,$80,$c,'x',0,0,0,0
	dc.b	0,8,0,$f0,0,0,0,0
	dc.b	0,$e,$f,$f0,0,0,8,0
	dc.b	9,$e0,6,$1c,0,0,0,0
	dc.b	0,4,'?',$f8,0,0,3,0
	dc.b	$13,$f0,$1c,$c,0,0,0,0
	dc.b	3,$80,$c,'x',0,0,0,0
	dcb.w	10
	dc.b	4,0,4,0,4,$10,4,0
	dc.b	0,0,'<',$c,'>',$f,0,0
	dc.b	0,0,'8',$1c,'>',$1f,0,0
	dc.b	0,0,'0',$18,'xžA',4
	dc.b	0,0,'<',$18,'<',$1e,0,0
	dc.b	0,0,'<',$c,'<',$f,0,0
	dc.b	0,0,'@8p|',0,'@'
	dc.b	0,0,'88?',$f8,0,0
	dc.b	0,0,5,$c0,7,$e0,2,0
	dc.b	0,0,'0<<<',0,0
	dc.b	0,0,0,'<',6,'<',$18,0
	dc.b	0,0,1,$f0,1,$f8,0,0
	dc.b	0,0,$c,0,$f,$f8,0,0
	dc.b	0,0,$c,$c,$1f,$e,$10,0
	dc.b	0,0,$27,$d0,'?',$fc,0,8
	dc.b	0,0,$1e,6,$1f,$8e,0,0
	dc.b	0,0,$18,'<',$1e,'<',0,0
	dcb.w	12
	dc.b	4,0,$e,$10,$e,'8',$e,0
	dcb.w	2
	dc.b	2,2,'<',$c,0,0,0,0
	dc.b	4,2,'8',$1c,0,0,0,0
	dc.b	'H',6,'s',$9c,0,0,0,0
	dc.b	0,$c,$1e,'0',0,0,0,0
	dc.b	0,6,$1e,$18,0,0,0,0
	dc.b	' ',$8c,0,$f0,0,0,0,0
	dc.b	$c,0,'p',$1c,0,0,0,0
	dc.b	2,' ',$d,$c0,0,0,0,0
	dc.b	0,2,'8',$1c,0,0,0,0
	dc.b	0,2,$1c,$1c,0,0,0,0
	dc.b	0,$88,3,'p',0,0,0,0
	dc.b	2,0,$1c,0,0,0,0,0
	dc.b	6,6,$18,0,0,0,0,0
	dc.b	$13,$cc,0,'0',0,0,0,0
	dc.b	1,1,$1e,6,0,0,0,0
	dc.b	4,2,$18,$1c,0,0,0,0
	dcb.w	10
	dc.b	$1b,0,$1b,0,$1b,$10,$1f,0
	dcb.w	2
	dc.b	2,2,'<',$c,0,0,0,0
	dc.b	4,2,'8',$1c,0,0,0,0
	dc.b	'HFs',$9c,0,0,0,0
	dc.b	0,$18,$f,'`',0,0,0,0
	dc.b	0,$c,$f,'0',0,0,0,0
	dc.b	1,$18,1,$e0,0,0,$10,$10
	dc.b	$18,$12,'`',$c,0,0,0,0
	dc.b	6,' ',1,$c0,0,0,0,0
	dc.b	$c,2,$10,$1c,0,0,0,0
	dc.b	6,2,8,$1c,0,0,0,0
	dc.b	1,$88,6,'p',0,0,0,0
	dc.b	6,0,$18,0,0,0,0,0
	dc.b	'$',0,'8',0,0,0,0,0
	dc.b	0,$18,0,'`',0,0,0,0
	dc.b	$11,3,$1e,6,0,0,0,0
	dc.b	4,$10,$18,$1e,0,0,0,0
	dcb.w	10
	dc.b	4,0,$e,0,$e,0,$e,0
	dc.b	0,0,'<',$c,'>',$e,0,0
	dc.b	0,0,'8',$1c,'<',$1e,0,0
	dc.b	0,0,'3',$98,'{',$de,'@',4
	dc.b	0,0,7,$c0,7,$f0,0,0
	dc.b	0,0,7,$e0,7,$f8,0,0
	dc.b	0,0,1,$c0,3,$f0,2,0
	dc.b	0,0,$e0,$e,$f8,$e,0,0
	dc.b	0,0,1,$c0,1,$e0,0,0
	dc.b	0,0,0,'<',$c,'>',0,0
	dc.b	0,0,0,'8',6,'<',0,0
	dc.b	0,0,$c,'p',$f,'x',0,0
	dc.b	0,0,$1f,$e0,$1f,$f0,0,$10
	dc.b	0,0,';',$f0,'?',$f0,0,0
	dc.b	0,0,0,$e0,0,$f0,0,0
	dc.b	0,0,$f,$c,$f,$f,0,0
	dc.b	0,0,$18,$e,$1c,$1f,0,$10
	dcb.w	12
	dc.b	4,0,4,0,4,0,4,0
	dcb.w	2
	dc.b	'>',$e,'<',$c,0,0,0,0
	dc.b	'<',$1e,'8',$1c,0,0,0,0
	dc.b	$7f,$de,'w',$dc,0,0,0,0
	dc.b	3,$e0,3,$c0,0,0,0,0
	dc.b	3,$f0,3,$c0,0,0,0,0
	dc.b	7,$e0,7,$80,0,0,0,0
	dc.b	$f0,$f,$e0,$e,0,0,0,0
	dc.b	1,$e0,1,$c0,0,0,0,0
	dc.b	0,'~',0,'x',0,0,0,0
	dc.b	0,'x',0,'p',0,0,0,0
	dc.b	$1e,'x',$18,'p',0,0,0,0
	dc.b	$1f,$f8,$1f,$f8,0,0,0,0
	dc.b	'?',$f8,'<8',0,0,0,0
	dc.b	1,$f0,1,$c0,0,0,0,0
	dc.b	7,$fe,7,$f8,0,0,0,0
	dc.b	$c,'?',$c,'>',0,0,0,0
	dcb.w	10
	dc.b	0,'@',0,0,0,0,0,'@'
	dcb.w	2
	dc.b	'>',$e,'<',$c,0,0,0,0
	dc.b	'<',$1e,'8',$1c,0,0,0,0
	dc.b	'?',$fe,'6',$d8,0,0,0,0
	dc.b	3,$e0,3,$c0,0,0,0,0
	dc.b	1,$e0,1,$c0,0,0,0,0
	dc.b	$f,$c0,$f,0,0,0,0,0
	dc.b	$f0,$f,$e0,$e,0,0,0,0
	dc.b	1,$e0,1,$c0,0,0,0,0
	dc.b	1,$fc,1,$e0,0,0,0,0
	dc.b	0,'8',0,'8',0,0,0,0
	dc.b	'<x0p',0,0,0,0
	dc.b	$f,$fc,0,'<',0,0,0,0
	dc.b	'>',$1c,'8',$1c,0,0,0,0
	dc.b	1,$e0,1,$c0,0,0,0,0
	dc.b	7,$fc,7,$fc,0,0,0,0
	dc.b	7,$ff,7,$ee,0,0,0,0
	dcb.w	12
	dc.b	'@',0,0,0,0,0,'<',$c
	dc.b	'>',$e,0,0,0,0,$1c,'8'
	dc.b	$1e,'>',0,0,0,0,'6',$d8
	dc.b	'?',$fc,0,0,0,0,3,$e0
	dc.b	3,$e0,0,0,0,0,1,$c0
	dc.b	1,$e0,0,0,0,0,$e,0
	dc.b	$1f,$80,$10,0,0,0,$e0,$e
	dc.b	$f0,$f,0,0,0,0,1,$c0
	dc.b	1,$e0,0,0,0,0,7,$80
	dc.b	7,$f0,0,0,0,0,0,$1c
	dc.b	0,$1c,0,0,0,0,'?',$f8
	dc.b	'?',$f8,0,0,0,0,0,$1c
	dc.b	0,'>',0,0,0,0,'8',$1c
	dc.b	'<',$1e,0,0,0,0,1,$80
	dc.b	3,$e0,2,0,0,0,$c,'>'
	dc.b	$f,$fe,0,0,0,0,0,$e
	dc.b	3,$ff,0,0,0,0,0,0
	dcb.w	15
	dc.b	$1c,$c,'>',$e,' ',0,0,0
	dc.b	$1c,'8',$1e,'<',0,0,0,0
	dc.b	'4X?',$fc,8,' ',0,0
	dc.b	6,$f0,7,$f0,0,0,0,0
	dc.b	1,$c0,1,$e0,0,0,0,0
	dc.b	$1c,0,'?',0,' ',0,0,0
	dc.b	'p',$1c,'x',$1f,0,0,0,0
	dc.b	1,$c0,1,$e0,0,0,0,0
	dc.b	$e,0,$f,$c0,0,0,0,0
	dc.b	8,$1c,8,$1e,0,0,0,0
	dc.b	'?',$f8,'?',$fc,0,0,0,0
	dc.b	8,$1c,8,$1e,0,0,0,0
	dc.b	$18,$1c,'<',$1e,' ',0,0,0
	dc.b	3,$80,3,$c0,0,0,0,0
	dc.b	$18,$1e,$1c,'?',0,0,0,0
	dc.b	8,$c,8,$f,0,0,0,0
	dcb.w	11
	dc.b	' ',0,' ',0,' ',0,0,0
	dcb.w	2
	dc.b	2,2,$1c,$c,0,0,0,0
	dc.b	1,$c,$e,'p',0,0,0,0
	dc.b	2,4,'<x',0,0,0,0
	dc.b	3,0,$c,'x',0,0,0,0
	dc.b	0,' ',1,$c0,0,0,0,0
	dc.b	'F',0,'x',0,0,0,0,0
	dc.b	8,2,'p',$1c,0,0,0,0
	dc.b	0,' ',1,$c0,0,0,0,0
	dc.b	3,0,$1c,4,0,0,0,0
	dc.b	0,2,$1c,$1c,0,0,0,0
	dc.b	$1f,$8c,0,'p',0,0,0,0
	dc.b	0,2,$1c,$1c,0,0,0,4
	dc.b	0,6,$1c,$18,0,0,4,0
	dc.b	4,'@',3,$80,0,0,0,0
	dc.b	4,1,$18,$1e,0,0,0,0
	dc.b	0,$12,$1c,$1c,0,0,0,0
	dc.b	0,0,1,$80,0,0,0,0
	dc.b	0,0,0,$c0,0,0,0,0
	dcb.w	2
	dc.b	'P',4,'q',4,'P',4,' ',4
	dc.b	0,0,$10,0,$10,2,$e,$1c
	dcb.w	2
	dc.b	0,$18,7,$e0,0,0,0,0
	dc.b	6,'D88',0,0,0,0
	dc.b	6,0,$18,'<',0,0,0,0
	dc.b	0,' ',1,$c0,0,0,0,0
	dc.b	$c,$10,'p',8,0,0,0,0
	dc.b	4,6,'88',0,0,0,0
	dc.b	0,' ',1,$c0,0,0,0,0
	dc.b	4,2,$1b,$c4,0,0,0,0
	dc.b	6,6,$18,'8',0,0,0,0
	dc.b	0,8,0,'p',0,0,0,0
	dc.b	6,2,$1c,$1c,0,0,$12,0
	dc.b	$12,6,$c,'8',0,0,0,0
	dc.b	0,'@',7,$80,0,0,0,0
	dc.b	4,1,$18,$1e,0,0,0,0
	dc.b	6,6,$18,$18,0,0,0,0
	dc.b	0,0,3,$c0,0,0,0,0
	dc.b	0,0,1,$e0,0,0,0,0
	dcb.w	2
	dc.b	'"',$80,' ',0,' ',0,1,0
	dc.b	0,0,7,$f8,$f,$fe,8,0
	dc.b	0,0,3,$c0,3,$f0,0,0
	dc.b	0,0,'88<<',0,0
	dc.b	0,0,'0',$1e,'<',$1e,0,0
	dc.b	0,0,1,$c0,1,$e0,0,0
	dc.b	0,0,'`',8,'x<',0,$10
	dc.b	0,0,$1e,$f0,$1e,$fc,0,0
	dc.b	0,0,3,$e0,7,$f0,4,$10
	dc.b	0,0,'?',$fc,'?',$fe,0,0
	dc.b	0,0,$c,'x',$e,'|',0,0
	dc.b	0,0,0,'p',0,'x',0,0
	dc.b	0,0,$c,'8',$1e,'>',$12,0
	dc.b	0,0,$f,$f0,$f,$fc,0,8
	dc.b	0,0,7,$80,7,$c0,0,0
	dc.b	0,0,$c,'<',$1c,'?',0,0
	dc.b	0,0,$c,'8',$e,'|',0,'@'
	dc.b	0,0,0,$c0,0,$e0,0,0
	dc.b	0,0,1,$e0,1,$f0,0,0
	dcb.w	5
	dc.b	4,'@',0,0,3,$80,0,0
	dc.b	2,' ',6,'<',1,$c0,0,0
	dc.b	0,0,0,'`',1,$80,0,0
	dc.b	0,0,$c,4,'0',$18,0,0
	dcb.w	2
	dc.b	$f8,'?',0,0,0,0,0,0
	dc.b	7,$f0,0,0,0,0,0,4
	dc.b	$7f,$f8,0,0,4,'@',$c,'x'
	dc.b	3,$80,0,0,0,0,0,0
	dc.b	$1f,$fc,0,0,0,0,7,$c6
	dc.b	'88',0,0,0,0,0,$1c
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	0,$f8,0,0,0,0,8,$1c
	dc.b	$f,$e0,0,0,0,0,4,$1c
	dc.b	3,$e0,0,0,0,0,0,$c0
	dc.b	3,0,0,0,4,0,$c,$e
	dc.b	3,$f0,0,0,0,0,4,$1c
	dc.b	3,$e0,0,0,0,0,0,'`'
	dc.b	0,$80,0,0,0,0,0,'0'
	dc.b	0,$c0,0,0,0,0,0,0
	dc.b	0,0,2,$80,0,0,0,0
	dc.b	1,0,0,0,0,0,1,$f0
	dcb.w	3
	dc.b	0,$c0,0,0,0,0,0,0
	dc.b	$18,$c,0,0,0,0,0,0
	dc.b	'|',$1f,0,0,0,0,0,0
	dc.b	3,$f8,0,0,0,0,0,0
	dc.b	'?',$fc,0,0,0,0,0,0
	dc.b	3,$e0,0,0,0,0,0,0
	dc.b	$f,$fe,0,0,0,0,0,0
	dc.b	$1c,$1c,0,0,0,0,0,0
	dc.b	3,$f0,0,0,0,0,0,0
	dc.b	0,'|',0,0,0,0,0,0
	dc.b	7,$f0,0,0,0,0,0,0
	dc.b	1,$f0,0,0,0,0,0,0
	dc.b	1,$80,0,0,0,0,0,0
	dc.b	7,$f8,0,0,0,0,0,0
	dc.b	3,$f0,0,0,0,0,0,0
	dc.b	0,'@',0,0,0,0,0,0
	dc.b	0,'`',0,0,0,0,0,0
	dcb.w	3
	dc.b	1,0,0,0,0,0,0,0
	dc.b	1,$e0,1,$e0,6,0,0,0
	dc.b	1,$e0,1,$e0,6,0,0,0
	dc.b	1,$e0,1,$e0,6,0,0,0
	dc.b	1,$e0,1,$e0,6,0,0,0
	dc.b	1,$e0,1,$e0,6,0,0,0
	dc.b	1,$e0,1,$e0,6,0,0,0
	dc.b	1,$e0,1,$e0,6,0,0,0
	dc.b	3,$e0,3,$e0,4,0,0,0
	dcb.w	45
	dc.b	0,'8',0,$10,0,0,7,0
	dc.b	7,$f8,$18,$f8,0,0,7,0
	dc.b	7,$f8,$18,$f8,0,0,7,0
	dc.b	7,$f8,$18,$f8,0,0,7,0
	dc.b	7,$f8,$18,$f8,0,0,7,0
	dc.b	7,$f8,$18,$f8,0,0,7,0
	dc.b	7,$f8,$18,$f8,0,0,7,0
	dc.b	7,$f8,$18,$f8,0,0,7,0
	dc.b	7,$f8,$18,$f8,0,0,0,0
	dcb.w	44
	dc.b	0,'l',0,'8',0,0,$1c,0
	dc.b	$1f,'|#',$f4,0,0,$14,'@'
	dc.b	$17,$fc,'+',$b8,0,0,$1c,' '
	dc.b	$1d,$fc,'#',$dc,0,0,$1c,$10
	dc.b	$1e,$fc,'#',$ec,0,0,$1c,0
	dc.b	$1f,'|#',$f4,0,0,$1c,'@'
	dc.b	$1f,$fc,'#',$b8,0,0,$1c,' '
	dc.b	$1f,$fc,'#',$d8,0,0,$1c,$10
	dc.b	$1f,$fc,'#',$ec,0,0,0,0
	dcb.w	10
	dc.b	0,2,0,2,5,0,1,2
	dcb.w	2
	dc.b	$10,'P',0,$10,$c,0,8,0
	dc.b	$c,8,$c,0,8,$a0,0,$80
	dc.b	8,$a0,8,$a0,0,$10,0,$10
	dc.b	8,$10,0,$10,0,0,0,0
	dc.b	5,'@',4,'@',4,0,4,0
	dc.b	0,8,4,0,$c,$b0,$c,$b0
	dc.b	4,$10,8,$a0,4,0,4,0
	dc.b	4,'8',4,$10,0,0,'8',0
	dc.b	'?',$fe,'G',$fe,0,0,'8',0
	dc.b	'?',$fe,'G',$de,0,0,'8',0
	dc.b	'?',$fe,'G',$ee,0,0,'8',0
	dc.b	'?',$fe,'G',$f6,0,0,'8',0
	dc.b	'?',$fe,'G',$fe,0,0,'8',0
	dc.b	'?',$fe,'G',$de,0,0,'8',0
	dc.b	'?',$fe,'G',$ee,0,0,'8',0
	dc.b	'?',$fe,'G',$fe,0,0,0,0
	dcb.w	10
	dc.b	0,8,0,8,')',8,0,0
	dcb.w	2
	dc.b	3,'4',0,0,'a',$80,0,0
	dc.b	'a',$82,'a',$82,5,'(',4,8
	dc.b	5,'(',5,'(',0,4,0,4
	dc.b	'V',4,4,4,0,0,0,0
	dc.b	$c,$d0,0,0,'c',$80,'c',$80
	dc.b	'"',9,'A',$89,1,$e0,1,$e0
	dc.b	0,$80,1,'`',0,0,0,0
	dcb.w	3
	dc.b	'0',$10,';',$fe,'O',$ec,0,0
	dc.b	'2',0,'?',$fe,'M',$fe,0,0
	dc.b	'!',0,'/',$fe,'^',$fe,0,0
	dc.b	'0@;',$fe,'O',$be,0,0
	dc.b	'0 =',$fe,'O',$de,0,0
	dc.b	'1',$10,'?',$fe
	jmp	0(a6)
	dc.b	'0',$88,'?',$fe,'Ov',0,0
	dc.b	'0@?',$fe,'O',$ba,0,0
	dcb.w	11
	dc.b	0,4,0,4,7,$80,4,$84
	dcb.w	2
	dc.b	8,'|',0,4,'_',0,'I',0
	dc.b	'_',$14,'_',0,8,'x',0,' '
	dc.b	8,'x',8,'x',0,9,0,0
	dc.b	$27,9,'!',9,0,0,0,0
	dc.b	1,$e4,1,'$',$1e,0,$1e,0
	dc.b	$10,$14,$e,4,8,'X',8,'X'
	dc.b	0,8,8,'P',0,'@',0,0
	dc.b	0,0,0,'@',0,0,'p@'
	dc.b	$7f,$ff,$8f,$b6,0,0,'p',$10
	dc.b	$7f,$ff,$8f,$ee,0,0,'p',8
	dc.b	$7f,$ff,$8f,$f6,0,0,'p',0
	dc.b	$7f,$ff,$8f,$fa,0,0,'p',0
	dc.b	$7f,$ff,$8f,$fc,0,0,'p',0
	dc.b	$7f,$ff,$8f,'t',0,0,'p',0
	dc.b	'{',$ff,$8f,$ba,0,0,'p',0
	dc.b	'}',$ff,$8f,$de,0,0,0,0
	dcb.w	10
	dc.b	0,$b,0,$8b,$17,$c2,1,'I'
	dc.b	'j',0,' ',8,'j8j',$10
	dc.b	'j',0,7,$80,'o',$8d,'o',$80
	dc.b	0,$c,0,'4',0,'=',0,'<'
	dc.b	0,7,1,5,$f,$87,2,$87
	dc.b	'x',0,'x P',$f0,'(P'
	dc.b	'm',$80,'o',$80,5,$8d,'j',0
	dc.b	0,'8',0,'8',0,'1',0,8
	dc.b	0,$a0,0,0,'@',0,0,$e0
	dc.b	0,0,$e0,0,$ff,$ff,$1f,$de
	dc.b	0,0,$e0,0,$f7,$ff,$1f,$f6
	dc.b	0,0,$e4,0,$ff,$ff,$1b,$fa
	dc.b	0,0,'a',0,$7f,$ff,$9e,$fe
	dc.b	0,0,'`@',$7f,$ff,$9f,$be
	dc.b	0,0,'`',$10,$7f,$ff,$9f,$ee
	dc.b	0,0,'`',0,$7f,$ff,$9f,$f6
	dc.b	0,0,'`',0,$7f,$ff,$9f,$fa
	dcb.w	12
	dc.b	0,5,0,'E',5,$c0,0,$85
	dc.b	'9',$80,6,0,'?',$bc,'?',$98
	dc.b	'5',$c0,'#',$80,'7',$ce,'7',$c2
	dc.b	0,'X',0,'0,x',4,'x'
	dc.b	0,$a,0,$80,$8b,$8a,$89,$a
	dc.b	$fe,0,$fe,' ',$18,$f0,$e6,'@'
	dc.b	'V@W',$c0,'B',$e,$15,$c2
	dc.b	0,'h',0,'x,!',0,'Y'
	dc.b	0,'@@',0,$e0,0,0,'@'
	dc.b	0,0,$e2,0,$ff,$ff,$1d,$fc
	dc.b	0,0,$e0,$80,$ff,$ff,$1f,'|'
	dc.b	0,0,$e0,' ',$ff,$ff,$1f,$dc
	dc.b	0,0,'`',0,$7f,$ff,$9f,$ec
	dc.b	0,0,$c0,0,$df,$ff,'?',$f4
	dc.b	0,0,$e0,0,$ef,$ff,$1f,$f4
	dc.b	0,0,$e0,0,$f7,$ff,$1f,$fc
	dc.b	0,0,$e4,0,$ff,$ff,$1b,$fc
	dcb.w	12
	dc.b	0,$e,0,'N',0,$e4,0,'*'
	dc.b	'=',2,$17,$f2,'?',$f8,'?',$c2
	dc.b	0,$80,3,$c0,3,$df,3,$c9
	dc.b	0,$14,2,'p_',$f4,'M',$f4
	dc.b	0,$17,0,$8c,1,$df,0,'_'
	dc.b	'k',$a,$7f,$c0,$b,$ea,'t',$a
	dc.b	3,'@',3,$c0,3,'_',0,$88
	dc.b	0,'d',2,'t_',$e0,$d,$94
	dc.b	' ',0,' ',0,'`',0,0,0
	dc.b	0,0,$c0,$10,$ef,$ff,'?',$ec
	dc.b	0,0,$c8,0,$ff,$ff,'7',$b4
	dc.b	0,0,$c4,0,$ef,$ff,';',$e8
	dc.b	0,0,$c9,0,$ff,$ff,'6',$fc
	dc.b	0,0,$c4,'@',$ff,$ff,';',$bc
	dc.b	0,0,$c1,$10,$ff,$ff,'>',$ec
	dc.b	0,0,$c0,'@',$ff,$ff,'?',$b4
	dc.b	0,0,$c0,0,$ff,$ff,'=',$e8
	dcb.w	12
	dc.b	$a,$9b,1,$9f,$b,$ba,$b,'e'
	dc.b	'<',$80,'#',$a0,'?',$b0,'?',$d0
	dc.b	0,'@',1,'H',7,'|',2,$94
	dc.b	0,'8',3,' ?;',$14,$ba
	dc.b	$17,$b,$17,'=',3,$7f,$14,$ff
	dc.b	'~',1,'~N',$c1,'1A'
	dc.b	0,'@',1,'H',7,'~',6,$94
	dc.b	0,'X',3,'x?C',4,$ba
	dc.b	'P',0,'p',0,0,0,'p',0
	dc.b	0,0,$c0,0,$ff,$ff,'?',$f0
	dc.b	0,0,$c0,0,$ff,$ff,'?',$f8
	dc.b	0,0,$c0,0,$ff,$ff,'=',$f8
	dc.b	0,0,$c0,0,$ff,$ff,'?x'
	dc.b	0,0,$c0,0,$ff,$ff,'?',$f8
	dc.b	0,0,$c0,0,$ff,$ff,'?p'
	dc.b	0,0,$c0,0,$ff,$ff,'?',$d8
	dc.b	0,0,$c0,0,$ff,$ff,'?',$f8
	dcb.w	12
	dc.b	'+',6,7,$1e,'/',4,'/',$fa
	dc.b	'@',$1f,1,$1f,'C',$11,'B',$ee
	dc.b	0,0,$c,'0<9',$13,$c8
	dc.b	0,$10,0,0,$a6,$12,$83,$d0
	dc.b	'X7^<',8,'?W',$ff
	dc.b	0,'x',4,'@',$c,'x',$b,$b8
	dc.b	0,0,$c,'0',$1c,'=',$13,$c8
	dc.b	0,'0',0,'0',$a6,'2',3,$c0
	dc.b	$88,4,$d8,4,$88,4,'p',4
	dc.b	0,0,'@',0,$7f,$fe,'?',$f8
	dc.b	0,0,'@',0,$7f,$fe,'?',$f8
	dc.b	0,0,'@',0,$7f,$fe,'?',$f8
	dcb.w	2
	dc.b	'?',$fe,$7f,$f8,0,0,'@',0
	dc.b	'_',$fe,'?',$f8,0,0,'@',0
	dc.b	'o',$fe,'?',$f8,0,0,'H',0
	dc.b	$7f,$fe,'7',$f8,0,0,'D',0
	dc.b	$7f,$fe,';',$f8,0,0,0,0
	dcb.w	10
	dc.b	$15,':',$f,':',$1f,$b8,$1e,$c2
	dc.b	'05#=7',$b4,'0I'
	dc.b	1,2,$13,'B',$7f,'p(',$a2
	dc.b	2,0,2,'@BY',0,$b0
	dc.b	'6T>`',$97,'t',$a9,$b4
	dc.b	'@&L',$f2,$e,$f6,'A',$f6
	dc.b	1,2,$13,'@',$7f,'z(',$b2
	dc.b	0,0,3,'@CY',3,$b0
	dc.b	'P',$e,'p',$e,0,$e,'p',$e
	dc.b	0,0,$11,0,$7f,$fe,'n',$f0
	dc.b	0,0,8,$80,$7f,$fe,'w`'
	dc.b	0,0,4,'@',$7f,$fe,'{',$b0
	dc.b	0,0,2,0,$7f,$fe,'}',$d0
	dc.b	0,0,1,0,$7f,$fe,'~',$e0
	dc.b	0,0,0,$80,$7f,$fe,$7f,'p'
	dcb.w	2
	dc.b	$7f,$fe,'{',$b0,0,0,0,0
	dc.b	$7f,$fe,'}',$d0,0,0,0,0
	dcb.w	10
	dc.b	'Z',0,$14,'@^',$e0,'^',$a0
	dc.b	0,'>',2,'>',7,$1c,4,'"'
	dc.b	2,$e0,3,$e0,$f0,$c0,$13,' '
	dc.b	$b,$81,$b,$b1,3,$be,8,$d
	dc.b	'<',0,'<',$80,')',$c0,$15,'@'
	dc.b	0,$89,8,'p',$1c,$f9,$10,$f9
	dc.b	3,' ',3,$e0,'1',$c0,$13,$e0
	dc.b	8,0,3,$b0,$b,$bf,$b,$8c
	dc.b	'!',4,'!',4,' ',4,0,4
	dcb.w	2
	dc.b	'?',$fc,'7@',0,0,0,0
	dc.b	'?',$fc,';',$80,0,0,0,0
	dc.b	'?',$fc,'=',$c0,0,0,0,0
	dc.b	'?',$fc,'>',$c0,0,0,0,0
	dc.b	'?',$fc,'?@',0,0,0,0
	dc.b	'?',$fc,'?',$80,0,0,0,0
	dc.b	'?',$fc,'?',$c0,0,0,0,0
	dc.b	'?',$fc,'?',$c0,0,0,0,0
	dcb.w	10
	dc.b	'T',0,'P@TuT '
	dc.b	0,$d,2,$d,$e,5,4,8
	dc.b	0,$b4,1,$f4,'P',$a0,'AT'
	dc.b	4,$80,7,$80,0,$1e,7,$8c
	dc.b	'h',0,'h',$80,'@',$ea,'(@'
	dc.b	0,'m',8,$19,$18,'}',$10,'}'
	dc.b	1,'U',1,$e1,$d1,$f5,1,$f5
	dc.b	7,$80,3,0,7,$9f,7,$99
	dcb.w	6
	dc.b	$1f,$f8,$1f,0,0,0,0,0
	dc.b	$1f,$f8,$1f,0,0,0,0,0
	dc.b	$1f,$f8,$1f,0,0,0,0,0
	dc.b	$1f,$f8,$1f,0,0,0,0,0
	dc.b	$1f,$f8,$1f,0,0,0,0,0
	dc.b	$1f,$f8,$1f,0,0,0,0,0
	dc.b	$1f,$f8,$1f,0,0,0,0,0
	dc.b	$1f,$f8,$1f,0,0,0,0,0
	dcb.w	10
	dc.b	$12,0,2,' ',$12,'|',$12,'P'
	dc.b	0,2,0,2,$a,$80,2,2
	dc.b	3,'b',3,$e2,' @#',$a2
	dc.b	$f,$a2,$f,$a2,3,0,$c,$a2
	dc.b	'0',0,'0@',$10,$fd,' %'
	dc.b	0,$a,0,2,':',$a,$10,$a
	dc.b	3,$a2,0,$c0,$83,$e2,3,$e2
	dc.b	$c,$a0,3,0,$f,$a2,$f,$a2
	dcb.w	6
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dcb.w	10
	dc.b	',',0,8,0,',=,$'
	dcb.w	2
	dc.b	6,'(',0,8,0,'x',0,'x'
	dc.b	'H',8,0,'p',$a,$c8,$a,$c8
	dc.b	8,0,2,$c8,'H',0,'H',0
	dc.b	0,'rH@',0,0,0,0
	dc.b	$1c,$80,4,0,0,$fd,0,$15
	dc.b	'@',$fd,0,$fd,2,$e8,2,' '
	dc.b	2,$e8,2,$e8,0,0,0,0
	dcb.w	46
	dc.b	$10,0,$10,0,$10,$18,$10,8
	dcb.w	2
	dc.b	9,$80,0,$80,0,'P',0,'P'
	dc.b	' @ ',$10,1,' ',1,' '
	dc.b	0,0,1,' ',0,0,0,0
	dc.b	0,'(',0,8,0,0,0,0
	dc.b	'%',0,1,0,0,'x',0,'('
	dc.b	0,'x',0,'x',1,$a8,0,$88
	dc.b	1,$a8,1,$a8,4,0,4,0
	dc.b	4,$10,4,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,7,$e0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	0,0,7,$e0,0,0,7,$e0
	dc.b	0,0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,0,0,7,$e0,0,0
	dc.b	0,0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,0,0,7,$e0
	dc.b	7,$e0,7,$e0,0,0,0,0
	dcb.w	42
	dc.b	$e,0,$e,0,$e,0,$e,0
	dcb.w	2
	dc.b	$1f,$f8,0,0,0,0,$1f,$f8
	dc.b	$1f,$f8,0,0,0,0,0,0
	dc.b	0,0,$1f,$f8,0,0,$1f,$f8
	dc.b	0,0,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,0,0,$1f,$f8,0,0
	dc.b	0,0,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,0,0,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,0,0,0,0
	dcb.w	42
	dc.b	4,'@',4,0,4,0,4,'@'
	dcb.w	2
	dc.b	'<<',0,0,0,0,'<<'
	dc.b	'<<',0,0,0,0,0,0
	dc.b	0,0,'<<',0,0,'<<'
	dc.b	0,0,'<<<<<<'
	dc.b	'<<',0,0,'<<',0,0
	dc.b	0,0,'<<<<<<'
	dc.b	'<<<<',0,0,'<<'
	dc.b	'<<<<',0,0,0,0
	dcb.w	10
	dc.b	4,2,4,2,4,2,4,2
	dc.b	$10,'@',$10,'@',$10,'@',$10,'@'
	dc.b	4,8,4,8,4,8,4,8
	dc.b	8,' ',8,' ',8,' ',8,' '
	dc.b	8,0,8,0,8,0,8,0
	dc.b	1,0,1,0,1,0,1,0
	dc.b	4,8,4,8,4,8,4,8
	dc.b	8,' ',8,' ',8,' ',8,' '
	dc.b	0,$a0,0,0,'@',0,0,$e0
	dcb.w	2
	dc.b	'p',$e,0,0,0,0,'p',$e
	dc.b	'p',$e,0,0,0,0,0,0
	dc.b	0,0,'p',$e,0,0,'p',$e
	dc.b	0,0,'p',$e,'p',$e,'p',$e
	dc.b	'p',$e,0,0,'p',$e,0,0
	dc.b	0,0,'p',$e,'p',$e,'p',$e
	dc.b	'p',$e,'p',$e,0,0,'p',$e
	dc.b	'p',$e,'p',$e,0,0,0,0
	dcb.w	10
	dc.b	')',0,')',0,')',0,')',0
	dc.b	3,'4',3,'4',3,'4',3,'4'
	dc.b	'a',$80,'a',$80,'a',$80,'a',$80
	dc.b	1,' ',1,' ',1,' ',1,' '
	dc.b	'R',0,'R',0,'R',0,'R',0
	dc.b	$c,$d0,$c,$d0,$c,$d0,$c,$d0
	dc.b	'a',$80,'a',$80,'a',$80,'a',$80
	dc.b	1,' ',1,' ',1,' ',1,' '
	dc.b	1,$10,0,0,$e0,0,'A',$f0
	dcb.w	2
	dc.b	'`',6,0,0,0,0,'`',6
	dc.b	'`',6,0,0,0,0,0,0
	dc.b	0,0,'`',6,0,0,'`',6
	dc.b	0,0,'`',6,'`',6,'`',6
	dc.b	'`',6,0,0,'`',6,0,0
	dc.b	0,0,'`',6,'`',6,'`',6
	dc.b	'`',6,'`',6,0,0,'`',6
	dc.b	'`',6,'`',6,0,0,0,0
	dcb.w	10
	dc.b	3,$84,3,$84,3,$84,3,$84
	dc.b	8,'x',8,'x',8,'x',8,'x'
	dc.b	$1e,$14,$1e,$14,$1e,$14,$1e,$14
	dc.b	8,'X',8,'X',8,'X',8,'X'
	dc.b	7,9,7,9,7,9,7,9
	dc.b	1,$e0,1,$e0,1,$e0,1,$e0
	dc.b	$1e,$14,$1e,$14,$1e,$14,$1e,$14
	dc.b	8,'X',8,'X',8,'X',8,'X'
	dc.b	0,$a0,0,0,$b0,0,$e0,$e0
	dcb.w	2
	dc.b	$e0,7,0,0,0,0,$e0,7
	dc.b	$e0,7,0,0,0,0,0,0
	dc.b	0,0,$e0,7,0,0,$e0,7
	dc.b	0,0,$e0,7,$e0,7,$e0,7
	dc.b	$e0,7,0,0,$e0,7,0,0
	dc.b	0,0,$e0,7,$e0,7,$e0,7
	dc.b	$e0,7,$e0,7,0,0,$e0,7
	dc.b	$e0,7,$e0,7,0,0,0,0
	dcb.w	10
	dc.b	$17,$c9,$17,$c9,$17,$c9,$17,$c9
	dc.b	'J8J8J8J8'
	dc.b	'o',$8d,'o',$8d,'o',$8d,'o',$8d
	dc.b	0,'9',0,'9',0,'9',0,'9'
	dc.b	$f,$82,$f,$82,$f,$82,$f,$82
	dc.b	'(',$e0,'(',$e0,'(',$e0,'(',$e0
	dc.b	'o',$8d,'o',$8d,'o',$8d,'o',$8d
	dc.b	0,'9',0,'9',0,'9',0,'9'
	dc.b	0,'@',0,0,$e0,0,'@@'
	dcb.w	2
	dc.b	$c0,3,0,0,0,0,$c0,3
	dc.b	$c0,3,0,0,0,0,0,0
	dc.b	0,0,$c0,3,0,0,$c0,3
	dc.b	0,0,$c0,3,$c0,3,$c0,3
	dc.b	$c0,3,0,0,$c0,3,0,0
	dc.b	0,0,$c0,3,$c0,3,$c0,3
	dc.b	$c0,3,$c0,3,0,0,$c0,3
	dc.b	$c0,3,$c0,3,0,0,0,0
	dcb.w	10
	dc.b	5,$c5,5,$c5,5,$c5,5,$c5
	dc.b	'?',$bc,'?',$bc,'?',$bc,'?',$bc
	dc.b	$17,$cc,$17,$cc,$17,$cc,$17,$cc
	dc.b	',x,x,x,x'
	dc.b	$b,$8a,$b,$8a,$b,$8a,$b,$8a
	dc.b	$fe,$f0,$fe,$f0,$fe,$f0,$fe,$f0
	dc.b	$17,$cc,$17,$cc,$17,$cc,$17,$cc
	dc.b	',x,x,x,x'
	dc.b	0,4,0,4,'@',4,0,4
	dcb.w	2
	dc.b	$c0,3,0,0,0,0,$c0,3
	dc.b	$c0,3,0,0,0,0,0,0
	dc.b	0,0,$c0,3,0,0,$c0,3
	dc.b	0,0,$c0,3,$c0,3,$c0,3
	dc.b	$c0,3,0,0,$c0,3,0,0
	dc.b	0,0,$c0,3,$c0,3,$c0,3
	dc.b	$c0,3,$c0,3,0,0,$c0,3
	dc.b	$c0,3,$c0,3,0,0,0,0
	dcb.w	10
	dc.b	0,$ee,0,$ee,0,$ee,0,$ee
	dc.b	'?',$fa,'?',$fa,'?',$fa,'?',$fa
	dc.b	3,$df,3,$df,3,$df,3,$df
	dc.b	'_',$f4,'_',$f4,'_',$f4,'_',$f4
	dc.b	1,$df,1,$df,1,$df,1,$df
	dc.b	$7f,$ea,$7f,$ea,$7f,$ea,$7f,$ea
	dc.b	3,$df,3,$df,3,$df,3,$df
	dc.b	'_',$f4,'_',$f4,'_',$f4,'_',$f4
	dc.b	' ',4,' ',$e,' ',$e,0,$e
	dcb.w	2
	dc.b	$c0,3,0,0,0,0,$c0,3
	dc.b	$c0,3,0,0,0,0,0,0
	dc.b	0,0,$c0,3,0,0,$c0,3
	dc.b	0,0,$c0,3,$c0,3,$c0,3
	dc.b	$c0,3,0,0,$c0,3,0,0
	dc.b	0,0,$c0,3,$c0,3,$c0,3
	dc.b	$c0,3,$c0,3,0,0,$c0,3
	dc.b	$c0,3,$c0,3,0,0,0,0
	dcb.w	10
	dc.b	$b,$ff,$b,$ff,$b,$ff,$b,$ff
	dc.b	$1f,$f0,$1f,$f0,$1f,$f0,$1f,$f0
	dc.b	7,$fc,7,$fc,7,$fc,7,$fc
	dc.b	'?',$b9,'?',$b9,'?',$b9,'?',$b9
	dc.b	$17,$fe,$17,$fe,$17,$fe,$17,$fe
	dc.b	'?',$c0,'?',$c0,'?',$c0,'?',$c0
	dc.b	7,$fc,7,$fc,7,$fc,7,$fc
	dc.b	'?',$b9,'?',$b9,'?',$b9,'?',$b9
	dc.b	0,$1b,1,$1b,0,$1b,0,$1f
	dcb.w	2
	dc.b	$e0,7,0,0,0,0,$e0,7
	dc.b	$e0,7,0,0,0,0,0,0
	dc.b	0,0,$e0,7,0,0,$e0,7
	dc.b	0,0,$e0,7,$e0,7,$e0,7
	dc.b	$e0,7,0,0,$e0,7,0,0
	dc.b	0,0,$e0,7,$e0,7,$e0,7
	dc.b	$e0,7,$e0,7,0,0,$e0,7
	dc.b	$e0,7,$e0,7,0,0,0,0
	dcb.w	10
	dc.b	'/',$fe,'/',$fe,'/',$fe,'/',$fe
	dc.b	'C',$fe,'C',$fe,'C',$fe,'C',$fe
	dc.b	'?',$f9,'?',$f9,'?',$f9,'?',$f9
	dc.b	$a7,$d2,$a7,$d2,$a7,$d2,$a7,$d2
	dc.b	'_',$ff,'_',$ff,'_',$ff,'_',$ff
	dc.b	$f,$f8,$f,$f8,$f,$f8,$f,$f8
	dc.b	$1f,$f9,$1f,$f9,$1f,$f9,$1f,$f9
	dc.b	$a7,$d2,$a7,$d2,$a7,$d2,$a7,$d2
	dc.b	1,4,3,$8e,0,$e,0,$e
	dcb.w	2
	dc.b	'`',6,0,0,0,0,'`',6
	dc.b	'`',6,0,0,0,0,0,0
	dc.b	0,0,'`',6,0,0,'`',6
	dc.b	0,0,'`',6,'`',6,'`',6
	dc.b	'`',6,0,0,'`',6,0,0
	dc.b	0,0,'`',6,'`',6,'`',6
	dc.b	'`',6,'`',6,0,0,'`',6
	dc.b	'`',6,'`',6,0,0,0,0
	dcb.w	10
	dc.b	$1f,$fa,$1f,$fa,$1f,$fa,$1f,$fa
	dc.b	$13,$fd,$13,$fd,$13,$fd,$13,$fd
	dc.b	$7f,$f2,$7f,$f2,$7f,$f2,$7f,$f2
	dc.b	'B',$f9,'B',$f9,'B',$f9,'B',$f9
	dc.b	'?',$f4,'?',$f4,'?',$f4,'?',$f4
	dc.b	'O',$f4,'O',$f4,'O',$f4,'O',$f4
	dc.b	$7f,$f2,$7f,$f2,$7f,$f2,$7f,$f2
	dc.b	'B',$f9,'B',$f9,'B',$f9,'B',$f9
	dc.b	0,4,1,4,0,4,0,4
	dcb.w	2
	dc.b	'p',$e,0,0,0,0,'p',$e
	dc.b	'p',$e,0,0,0,0,0,0
	dc.b	0,0,'p',$e,0,0,'p',$e
	dc.b	0,0,'p',$e,'p',$e,'p',$e
	dc.b	'p',$e,0,0,'p',$e,0,0
	dc.b	0,0,'p',$e,'p',$e,'p',$e
	dc.b	'p',$e,'p',$e,0,0,'p',$e
	dc.b	'p',$e,'p',$e,0,0,0,0
	dcb.w	10
	dc.b	'^',$e0,'^',$e0,'^',$e0,'^',$e0
	dc.b	7,'.',7,'.',7,'.',7,'.'
	dc.b	$f3,$e0,$f3,$e0,$f3,$e0,$f3,$e0
	dc.b	$b,$bf,$b,$bf,$b,$bf,$b,$bf
	dc.b	'=',$c0,'=',$c0,'=',$c0,'=',$c0
	dc.b	$1c,$f9,$1c,$f9,$1c,$f9,$1c,$f9
	dc.b	'3',$e0,'3',$e0,'3',$e0,'3',$e0
	dc.b	$b,$bf,$b,$bf,$b,$bf,$b,$bf
	dcb.w	6
	dc.b	'<<',0,0,0,0,'<<'
	dc.b	'<<',0,0,0,0,0,0
	dc.b	0,0,'<<',0,0,'<<'
	dc.b	0,0,'<<<<<<'
	dc.b	'<<',0,0,'<<',0,0
	dc.b	0,0,'<<<<<<'
	dc.b	'<<<<',0,0,'<<'
	dc.b	'<<<<',0,0,0,0
	dcb.w	10
	dc.b	$14,'u',$14,'u',$14,'u',$14,'u'
	dc.b	6,9,6,9,6,9,6,9
	dc.b	'Q',$f4,'Q',$f4,'Q',$f4,'Q',$f4
	dc.b	7,$9e,7,$9e,7,$9e,7,$9e
	dc.b	'(',$ea,'(',$ea,'(',$ea,'(',$ea
	dc.b	$18,'t',$18,'t',$18,'t',$18,'t'
	dc.b	$d1,$f5,$d1,$f5,$d1,$f5,$d1,$f5
	dc.b	7,$9e,7,$9e,7,$9e,7,$9e
	dc.b	4,$10,4,$10,4,$10,4,$10
	dcb.w	2
	dc.b	$1f,$f8,0,0,0,0,$1f,$f8
	dc.b	$1f,$f8,0,0,0,0,0,0
	dc.b	0,0,$1f,$f8,0,0,$1f,$f8
	dc.b	0,0,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,0,0,$1f,$f8,0,0
	dc.b	0,0,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,0,0,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,0,0,0,0
	dcb.w	10
	dc.b	$10,'|',$10,'|',$10,'|',$10,'|'
	dc.b	$a,$82,$a,$82,$a,$82,$a,$82
	dc.b	3,$e2,3,$e2,3,$e2,3,$e2
	dc.b	$f,$a2,$f,$a2,$f,$a2,$f,$a2
	dc.b	' ',$f8,' ',$f8,' ',$f8,' ',$f8
	dc.b	'*',8,'*',8,'*',8,'*',8
	dc.b	$83,$e2,$83,$e2,$83,$e2,$83,$e2
	dc.b	$f,$a2,$f,$a2,$f,$a2,$f,$a2
	dc.b	$e,'8',$e,'8',$e,'8',$e,'8'
	dcb.w	2
	dc.b	7,$e0,0,0,0,0,7,$e0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	0,0,7,$e0,0,0,7,$e0
	dc.b	0,0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,0,0,7,$e0,0,0
	dc.b	0,0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,0,0,7,$e0
	dc.b	7,$e0,7,$e0,0,0,0,0
	dcb.w	10
	dc.b	'$9$9$9$9'
	dc.b	6,' ',6,' ',6,' ',6,' '
	dc.b	'HxHxHxHx'
	dc.b	2,$c8,2,$c8,2,$c8,2,$c8
	dc.b	'HrHrHrHr'
	dc.b	$18,$80,$18,$80,$18,$80,$18,$80
	dc.b	'@',$fd,'@',$fd,'@',$fd,'@',$fd
	dc.b	2,$c8,2,$c8,2,$c8,2,$c8
	dc.b	$1f,$10,$1f,$10,$1f,$10,$1f,$10
	dcb.w	44
	dc.b	0,$10,0,$10,0,$10,0,$10
	dc.b	9,0,9,0,9,0,9,0
	dc.b	0,$10,0,$10,0,$10,0,$10
	dc.b	1,' ',1,' ',1,' ',1,' '
	dc.b	0,' ',0,' ',0,' ',0,' '
	dc.b	'$',0,'$',0,'$',0,'$',0
	dc.b	0,'x',0,'x',0,'x',0,'x'
	dc.b	1,' ',1,' ',1,' ',1,' '
	dc.b	$e,0,$e,0,$e,0,$e,0
	dc.b	7,$e0,7,$e0,3,$c0,4,' '
	dc.b	7,$e0,7,$e0,3,$c0,4,' '
	dc.b	7,'`',7,$e0,3,'@',4,$a0
	dc.b	7,$e0,7,$e0,3,$c0,4,' '
	dc.b	7,$e0,7,$e0,3,$c0,4,' '
	dc.b	7,$e0,7,$e0,3,$c0,4,' '
	dc.b	7,'`',7,$e0,3,'@',4,$a0
	dc.b	7,$e0,7,$e0,3,$c0,4,' '
	dcb.w	44
	dc.b	4,0,4,0,4,0,4,0
	dc.b	$18,'x',$1f,$f8,8,'p',$17,$88
	dc.b	$18,'x',$1f,$f8,8,'p',$17,$88
	dc.b	$18,$b8,$1f,$f8,8,'0',$17,$c8
	dc.b	$18,'x',$1f,$f8,8,'p',$17,$88
	dc.b	$18,'x',$1f,$f8,8,'p',$17,$88
	dc.b	$18,'x',$1f,$f8,8,'p',$17,$88
	dc.b	$18,$b8,$1f,$f8,8,'0',$17,$c8
	dc.b	$18,'x',$1f,$f8,8,'p',$17,$88
	dcb.w	12
	dc.b	2,$80,1,0,3,$80,3,$80
	dcb.w	14
	dc.b	3,$80,1,0,4,'@',3,$80
	dc.b	7,$c0,7,$c0,1,'@',1,$80
	dc.b	7,$c0,3,$c0,4,'@',3,$80
	dc.b	7,$c0,7,$c0,0,'@',0,'@'
	dc.b	0,'@',0,'@=',$fc,'?',$fc
	dc.b	$11,$c8,'.4!',$fc,'?',$fc
	dc.b	1,'8>',$c4,'1',$fc,'?',$fc
	dc.b	$11,'x.„3',$f4,'?',$fc
	dc.b	$11,$f0,'.',$c,'3',$fc,'?',$fc
	dc.b	$10,'8/',$c4,'!',$fc,'?',$fc
	dc.b	1,$b8,'>D1',$fc,'?',$fc
	dc.b	$11,'x.„3',$e4,'?',$fc
	dc.b	$10,$e0,'/',$1c,0,0,0,0
	dcb.w	10
	dc.b	5,'@',3,$80,7,$c0,7,$c0
	dc.b	1,0,0,0,1,0,1,0
	dcb.w	6
	dc.b	1,0,0,0,0,0,1,0
	dc.b	7,$c0,2,$80,8,' ',2,$c0
	dc.b	$e,$e0,$d,'`',0,$a0,2,$c0
	dc.b	$e,$e0,5,$e0,$a,$a0,6,$c0
	dc.b	$e,$e0,$f,$e0,'@',0,'@',0
	dc.b	'@',0,'@',0,'i',$e6,'{',$ee
	dc.b	'!',$c4,'Z*[ž',$7f,$be
	dc.b	3,$1c,'|',$a2,'e^',$7f,'~'
	dc.b	'$',$1c,'[bgž',$7f,$fe
	dc.b	'#„\zg',$fe,$7f,$fe
	dc.b	$27,$fc,'X',2,'l',$fe,$7f,$fe
	dc.b	' ',$dc,'_"e^',$7f,'~'
	dc.b	'$',$1c,'[bfZ~',$fe
	dc.b	'$@Z',$be,0,0,0,0
	dcb.w	10
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	6,$c0,1,0,7,$c0,7,$c0
	dcb.w	6
	dc.b	7,$c0,1,0,0,0,2,$80
	dc.b	$e,$e0,5,'@',0,$10,5,'`'
	dc.b	$1d,'p',$a,$b0,0,$a0,2,$c0
	dc.b	$e,$e0,5,$e0,$15,'P',$d,'`'
	dc.b	$1d,'p',$1f,$f0,0,0,0,0
	dcb.w	2
	dc.b	'X',$e,$7f,$fe,'X',$c,$27,$f2
	dc.b	'D',$be,'w',$fe,'@',$bc,'7B'
	dc.b	']^',$7f,'~\',$10,'#n'
	dc.b	'^V',$7f,$de,'V',4,')',$da
	dc.b	'\>',$7f,$fe,'\<#',$c2
	dc.b	'K~{',$fe,'@l;',$92
	dc.b	'}^',$7f,'~L',$1c,'3b'
	dc.b	'^6',$7f,$fe,'^',4,'!',$fa
	dcb.w	12
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	$19,'0',7,$c0,$1f,$f0,$1f,$f0
	dc.b	1,0,0,0,1,0,1,0
	dc.b	0,0,1,0,$1f,$f0,6,$c0
	dc.b	0,0,5,'@',$1d,'p',$a,$a0
	dc.b	0,$10,5,'`',$1d,'p',$a,$b0
	dc.b	0,$a0,2,$c0,$e,$e0,5,$e0
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	' ',0,' ',0,' ',0,' ',0
	dc.b	$c3,$c7,$ff,$ff,'@',4,$bf,$fb
	dc.b	$cb,$7f,$fb,$ff,'@d',$bb,$9b
	dc.b	$da,')',$fe,';H',0,$b6,';'
	dc.b	$dd,$f,$ff,$1f,'L',$c,$b3,$13
	dc.b	$c3,$c7,$ff,$ff,'@',4,$bf,$fb
	dc.b	$d0,$bf,$f8,$ff,'P4',$a8,$cb
	dc.b	$e2,'/',$ee,'?@',8,$ae,'7'
	dc.b	$fe,$d7,$ff,$df,'N',4,$b1,$db
	dcb.w	12
	dc.b	'*',$a8,$1b,$b0,';',$b8,'?',$f8
	dc.b	'&',$c8,$1e,$f0,'>',$f8,'?',$f8
	dc.b	'>',$f8,1,0,'?',$f8,'?',$f8
	dc.b	0,0,6,$c0,'>',$f8,$19,'0'
	dc.b	0,0,$a,$a0,';',$b8,$15,'P'
	dc.b	1,8,$a,$b0,';',$b8,$15,'X'
	dc.b	0,$a0,2,$c0,$e,$e0,5,$e0
	dc.b	'+',$a8,$1a,$b0,';',$b8,'?',$f8
	dc.b	'q',4,'q',4,'q',4,'q',4
	dc.b	$bc,'=',$fc,'?',$a0,4,'\;'
	dc.b	$b8,$b3,$f8,$f7,$b0,' H',$d7
	dc.b	$ba,'+',$fe,'?',$a8,8,'V7'
	dc.b	$ba,'/',$fe,'?',$98,$c,'f3'
	dc.b	$bc,'=',$fc,'?',$a0,4,'\;'
	dc.b	$b4,$1f,$fc,'?',$b0,$18,'L',$27
	dc.b	$aa,'/',$fe,'?',$a8,8,'V7'
	dc.b	$a5,'7',$ef,'?',$84,4,'k;'
	dcb.w	12
	dc.b	'UT6',$d8,'w',$dc,$7f,$fc
	dc.b	'Y498y<',$7f,$fc
	dc.b	'A',4,'?',$f8,$7f,$fc,$7f,$fc
	dc.b	0,0,$19,'0y<&',$c8
	dc.b	0,0,$14,'Pw',$dc,'*',$a8
	dc.b	1,8,$a,$b0,';',$b8,$15,'X'
	dc.b	0,$a0,2,$c0,$e,$e0,5,$e0
	dc.b	'+',$a8,$1a,$b0,';',$b8,'?',$f8
	dc.b	'#',$80,'#',$80,'#',$80,'#',$80
	dc.b	'`',6,$e0,7,0,0,$e0,7
	dc.b	$b0,'W',$f8,$7f,$b0,$10,'Ho'
	dc.b	$ba,'/',$fe,'?',$a8,8,'V7'
	dc.b	$b4,'_',$fc,$7f,$b0,0,'L',$7f
	dc.b	'`',6,$e0,7,0,0,$e0,7
	dc.b	$ba,'/',$fe,'?',$b8,8,'F7'
	dc.b	$ba,'/',$fe,'?',$b8,8,'F7'
	dc.b	$aa,'/',$fe,'?',$a8,8,'V7'
	dcb.w	12
	dc.b	$aa,$aa,'ll',$ee,$ee,$fe,$fe
	dc.b	$a6,$ca,'f',$cc,$e6,$ce,$fe,$fe
	dc.b	$be,$fa,'~',$fc,$fe,$fe,$ff,$fe
	dc.b	0,0,'&',$c8,$e6,$ce,'X4'
	dc.b	0,0,'((',$ee,$ee,'TT'
	dc.b	0,4,$14,'Xw',$dc,'*',$ac
	dc.b	0,$a0,2,$c0,$e,$e0,5,$e0
	dc.b	'UT6',$d8,'w',$dc,$7f,$fc
	dc.b	7,$c0,7,$c0,7,$c0,7,$c0
	dc.b	$bc,'=',$fc,'?',$a0,4,'\;'
	dc.b	$f4,'/',$fc,'?',$d0,8,',7'
	dc.b	$fa,'/',$fe,'?',$e8,8,$16,'7'
	dc.b	$f0,$b3,$f8,$f7,$f0,' ',8,$d7
	dc.b	$bc,'=',$fc,'?',$a0,4,'\;'
	dc.b	$fd,$f,$ff,$1f,$cc,8,'3',$17
	dc.b	$fa,'/',$fe,'?',$f8,8,6,'7'
	dc.b	$f4,'_',$fc,$7f,$f0,$18,$c,'g'
	dcb.w	12
	dc.b	'TU',$d8,'6',$dc,'w',$fc,$7f
	dc.b	'X4',$d8,'6',$d8,'6',$f8,'>'
	dc.b	'@',4,$c0,6,$c0,6,$ff,$fe
	dc.b	0,0,'X4',$d8,'6',$a0,$a
	dc.b	0,0,'P',$14,$dc,'w',$a8,'*'
	dc.b	0,4,$14,'Xw',$dc,'*',$ac
	dc.b	1,'P',5,'`',$1d,'p',$b,$f0
	dc.b	'UT6',$d8,'w',$dc,$7f,$fc
	dc.b	3,$80,3,$80,3,$80,3,$80
	dc.b	$e3,$c7,$ff,$ff,'`',0,$9f,$ff
	dc.b	$fa,$1f,$fe,$1f,'h',$10,$96,$f
	dc.b	$fa,'/',$fe,'?h',0,$96,'?'
	dc.b	$eb,'w',$fb,$ff,'`t',$9b,$8b
	dc.b	$e3,$c7,$ff,$ff,'`',0,$9f,$ff
	dc.b	$e6,$87,$ef,$8f,'F',0,$a9,$8f
	dc.b	$fa,'/',$fe,'?H',0,$b6,'?'
	dc.b	$f4,$bf,$fc,$ff,'p0',$8c,$cf
	dcb.w	12
	dc.b	$aa,$aa,'ll',$ee,$ee,$fe,$fe
	dc.b	$a6,$c8,'f',$cc,$e6,$ce,$fe,$fc
	dc.b	0,0,'>',$f8,$fe,$fe,'A',4
	dc.b	0,0,'&',$c8,$e6,$ce,'X4'
	dc.b	0,0,'((',$ee,$ee,'TT'
	dc.b	0,4,$14,'Xw',$dc,'*',$ac
	dc.b	0,$a0,2,$c0,$e,$e0,5,$e0
	dc.b	'UT6',$d8,'w',$dc,$7f,$fc
	dc.b	1,0,1,0,1,0,1,0
	dc.b	'|>',$7f,$fe,'x',0,7,$fe
	dc.b	'}',$96,$7f,'žt',0,$b,$9e
	dc.b	'}X',$7f,'z|',0,3,'z'
	dc.b	'e',$fe,'w',$fe,'``',$17,$9e
	dc.b	'|>',$7f,$fe,'p',0,$f,$fe
	dc.b	'o.',$7f,$ee,'o',0,$10,$ee
	dc.b	'e^o~D',0,'+~'
	dc.b	'k~{',$fe,'``',$1b,$9e
	dcb.w	12
	dc.b	'UT6',$d8,'w',$dc,$7f,$fc
	dc.b	$19,'098y<?',$f8
	dc.b	0,0,1,0,$7f,$fc,'>',$f8
	dc.b	0,0,$19,'0y<&',$c8
	dc.b	0,0,$14,'Pw',$dc,'*',$a8
	dc.b	0,8,$a,$b0,';',$b8,$14,'X'
	dc.b	0,$a0,2,$c0,$e,$e0,5,$e0
	dc.b	'+',$a8,$1a,$b0,';',$b8,'?',$f8
	dc.b	0,'8',0,'8',0,'8',0,'8'
	dc.b	$7f,$fe,$7f,$fe,'<',0,'C',$fe
	dc.b	$7f,$be,$7f,$fe,';„Dz'
	dc.b	'}Z',$7f,'~<',0,'C~'
	dc.b	'[>',$7f,'~',2,' }^'
	dc.b	'y',$e6,'{',$ee,'1',$c0,'J.'
	dc.b	$7f,$ca,$7f,$fe,'<',$c0,'C>'
	dc.b	'm^',$7f,'~,',0,'S~'
	dc.b	'x',$fe,$7f,$fe,' ',$c0,'_>'
	dcb.w	12
	dc.b	'*',$a8,$1b,$b0,';',$b8,'?',$f8
	dc.b	6,$c0,$1e,$f0,'>',$f8,$1f,$f0
	dcb.w	2
	dc.b	'?',$f8,1,0,0,0,6,$c0
	dc.b	'>',$f8,$19,'0',0,0,$a,$a0
	dc.b	';',$b8,$15,'P',0,8,$a,$b0
	dc.b	';',$b8,$14,'X',0,$a0,2,$c0
	dc.b	$e,$e0,5,$e0,'+',$a8,$1a,$b0
	dc.b	';',$b8,'?',$f8,0,'|',0,'|'
	dc.b	0,'|',0,'|?',$fc,'?',$fc
	dc.b	$e,0,'1',$fc,'?',$d4,'?',$fc
	dc.b	$c,$10,'3',$ec,'?',$fc,'?',$fc
	dc.b	$f,'@0',$bc,$27,'|?',$fc
	dc.b	6,'`9',$9c,';',$ec,'?',$fc
	dc.b	0,0,'?',$fc,'>d>',$fc
	dc.b	$c,0,'2',$fc,'?',$fc,'?',$fc
	dc.b	$f,'@0',$bc,'/',$fc,'?',$fc
	dc.b	$e,0,'1',$fc,0,0,0,0
	dcb.w	10
	dc.b	$15,'P',$d,'`',$1d,'p',$1f,$f0
	dc.b	1,0,7,$c0,$1f,$f0,7,$c0
	dcb.w	2
	dc.b	1,0,0,0,0,0,1,0
	dc.b	$1f,$f0,6,$c0,0,0,5,'@'
	dc.b	$1d,'p',$a,$a0,0,$10,5,'`'
	dc.b	$1d,'p',$a,$b0,0,$a0,2,$c0
	dc.b	$e,$e0,5,$e0,$15,'P',$d,'`'
	dc.b	$1d,'p',$1f,$f0,4,'8',4,'8'
	dc.b	4,'8',4,'8',$1f,$f8,$1f,$f8
	dc.b	0,0,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	0,0,$1f,$f8,$1e,$b8,$1f,$f8
	dc.b	0,0,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	0,0,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	0,0,$1f,$f8,$1e,$f8,$1f,$f8
	dc.b	0,$80,$1f,'x',$1e,$b8,$1f,$f8
	dc.b	0,0,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	0,0,$1f,$f8,0,0,0,0
	dcb.w	10
	dc.b	$a,$a0,6,$c0,$e,$e0,$f,$e0
	dc.b	0,0,1,0,7,$c0,1,0
	dcb.w	6
	dc.b	7,$c0,1,0,0,0,2,$80
	dc.b	$e,$e0,5,'@',0,$10,5,'`'
	dc.b	$1d,'p',$a,$b0,0,$a0,2,$c0
	dc.b	$e,$e0,5,$e0,$15,'P',$d,'`'
	dc.b	$1d,'p',$1f,$f0,0,0,0,0
	dcb.w	2
	dc.b	7,$e0,7,$e0,0,0,7,$e0
	dc.b	7,$e0,7,$e0,0,0,7,$e0
	dc.b	7,'`',7,$e0,0,0,7,$e0
	dc.b	7,$e0,7,$e0,0,0,7,$e0
	dc.b	7,$e0,7,$e0,0,0,7,$e0
	dc.b	7,$e0,7,$e0,0,0,7,$e0
	dc.b	7,'`',7,$e0,0,0,7,$e0
	dc.b	7,$e0,7,$e0,0,0,7,$e0
	dcb.w	12
	dc.b	5,'@',3,$80,7,$c0,7,$c0
	dcb.w	13
	dc.b	1,0,7,$c0,2,$80,8,' '
	dc.b	2,$c0,$e,$e0,$d,'`',0,$a0
	dc.b	2,$c0,$e,$e0,5,$e0,$a,$a0
	dc.b	6,$c0,$e,$e0,$f,$e0,0,'@'
	dc.b	0,'@',0,'@',0,'@',0,0
	dcb.w	43
	dc.b	2,$80,1,0,3,$80,3,$80
	dcb.w	14
	dc.b	3,$80,1,0,4,'@',1,$80
	dc.b	7,$c0,7,$c0,1,'@',1,$80
	dc.b	7,$c0,3,$c0,4,'@',3,$80
	dc.b	7,$c0,7,$c0,'@',$e0,'@',$e0
	dc.b	'@',$e0,'@',$e0,0,0,0,0
	dcb.w	2
	dc.b	5,$e0,2,'@',7,$e0,7,$e0
	dc.b	5,$e0,2,'@',7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	0,'`',7,$e0,7,$e0,7,$e0
	dc.b	0,'`',7,$e0,7,$e0,7,$e0
	dc.b	7,$a0,0,'`',7,$e0,7,$e0
	dc.b	0,$e0,0,0,0,$e0,0,$e0
	dcb.w	44
	dc.b	$e0,'@',$e0,'@',$e0,'@',$e0,'@'
	dc.b	7,$e0,0,0,7,$e0,7,$e0
	dc.b	8,$18,$17,$e0,$1f,$f8,$1f,$f8
	dc.b	8,$18,$17,$e0,$1f,$f8,$1f,$f8
	dc.b	8,$18,$1f,$e8,$1f,$e8,$1f,$f8
	dc.b	0,'8',$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$18,0,$e8,$1f,$e8,$1f,$f8
	dc.b	$18,$c8,0,'8',$18,$f8,$18,$f8
	dc.b	0,' ',0,$18,0,'8',0,'8'
	dcb.w	44
	dc.b	'`',0,'`',0,'`',0,'`',0
	dc.b	$18,$18,7,$e0,$1f,$f8,$1f,$f8
	dc.b	' ',$84,$1b,'x;|?',$fc
	dc.b	'!',4,$1e,$f8,'>',$fc,'?',$fc
	dc.b	0,$8c,'?|?|?',$fc
	dc.b	$f,$1c,'0',$fc,'?',$fc,'?',$fc
	dc.b	'8',$8c,0,'|8',$fc,'8',$fc
	dc.b	'"d',0,$1c,'"|"|'
	dc.b	0,$10,0,$c,0,$1c,0,$1c
	dcb.w	13
	dc.b	6,0,6,$e0,6,0,2,0
	dc.b	4,0,6,$e0,6,'`',4,0
	dc.b	0,0,4,'`',4,0,0,0
	dc.b	0,0,0,'`',0,0,0,0
	dcb.w	3
	dc.b	2,0,4,0,6,0,6,0
	dcb.w	2
	dc.b	7,$c0,6,0,6,0,0,0
	dc.b	7,$e0,6,0,'p',0,'p',0
	dc.b	'p',0,'p',0,'"$',$1f,$f8
	dc.b	'?',$fc,'?',$fc,7,$b2,$7f,$ac
	dc.b	$7f,$ae,$7f,$fe,$17,$b2,'o',$ac
	dc.b	'o',$ae,$7f,$fe,'9',$16,'F',$ea
	dc.b	'~',$ea,$7f,$fe,'e',$9e,4,'~'
	dc.b	'e~e',$fe,'`',$c6,0,$ba
	dc.b	'`',$fa
l028c
	bra.s	l028c
	dc.b	0,'&',0,$1a,0,':',0,'>'
	dc.b	0,$1a,0,6,0,$1e,0,$1e
	dcb.w	12
	dc.b	$18,0,$18,8,$18,$18,$18,$10
	dc.b	0,0,$18,0,$18,'8',$18,$18
	dc.b	8,0,$10,0,$18,$18,$18,$18
	dc.b	0,0,$10,0,$10,$18,$10,8
	dcb.w	5
	dc.b	$18,0,$18,0,$18,0,8,0
	dc.b	$c,0,$c,$18,$1c,0,$c,0
	dc.b	$10,'@',$1c,$d8,$1c,' ',$f8,4
	dc.b	$f8,4,$f8,4,$f8,4,',',$84
	dc.b	$1b,'x;|?',$fc,'O',$fa
	dc.b	't<t>',$7f,$fe,'G',$fa
	dc.b	'|',$bc,'|',$be,$7f,$fe,'<',$ee
	dc.b	'C',$1a,$7f,$1a,$7f,$fe,'@',$fe
	dc.b	0,'*@',$ea,'@',$fe,0,'N'
	dc.b	0,':',0,'z',0,'~',0,'6'
	dc.b	0,$e,0,'>',0,'>',0,$a
	dc.b	0,6,0,$e,0,$e,0,0
	dcb.w	11
	dc.b	' ',0,'$',$c,'$<<',$10
	dc.b	0,0,' ',0,' T0$'
	dc.b	0,0,' ',0,' ',$c,' ',4
	dc.b	' ',0,0,0,' ',4,' ',0
	dcb.w	4
	dc.b	$10,0,'0',0,'0',0,'0',0
	dc.b	$10,0,'4',0,'4',4,$1c,4
	dc.b	$c,0,'0@<',$d4,'<8'
	dc.b	'p',$e,'p',$e,'p',$e,'p',$e
	dc.b	'G',$d2,'?',$bc,$7f,$be,$7f,$fe
	dc.b	'>|',$d8,$f,$d8,$f,$ff,$ff
	dc.b	$1e,'u',$fa,$f,$fa,$f,$ff,$ff
	dc.b	$7f,$9f,$80,$d,$fc,$d,$ff,$ff
	dc.b	'A',$ff,0,'AA',$c1,'A',$ff
	dc.b	'@_',0,'=@}@',$7f
	dc.b	0,'/',0,$9d,0,$bd,0,$bf
	dc.b	0,$b,0,7,0,$f,0,$f
	dcb.w	13
	dc.b	'Z',0,'Zn^:',0,0
	dc.b	'@',0,'@',$a2,'@B',0,0
	dc.b	'@',0,'@6@',$a,0,0
	dc.b	0,0,0,$e,0,4,0,0
	dcb.w	3
	dc.b	$1c,0,'H',0,'\',4,'\',0
	dc.b	$14,0,'v',2,'v',$a,'~',4
	dc.b	4,0,'hLl',$ce,'|0'
	dc.b	'!',4,'!',4,'!',4,'!',4
	dc.b	'O',$f2,':|z~',$7f,$fe
	dc.b	$94,'4p',7,$f0,7,$ff,$ff
	dc.b	$95,'5p',$16,$f0,$17,$ff,$ff
	dc.b	$7f,$f,$80,1,$f6,1,$ff,$ff
	dc.b	5,$f3,0,0,1,$80,5,$ff
	dc.b	0,$bf,0,'q',0,$f1,0,$ff
	dc.b	0,$7f,0,$19,0,'y',0,$7f
	dc.b	0,$1b,0,5,0,$1d,0,$1f
	dcb.w	13
	dc.b	'J',0,'J',$da,'Np@',0
	dc.b	0,0,'@',$a2,'@@@',0
	dc.b	0,$10,'@z@"',0,0
	dc.b	0,0,0,$e,0,2,4,0
	dc.b	6,0,6,0,6,0,$8a,0
	dc.b	0,0,$8a,$18,$8e,$10,$14,0
	dc.b	'6',0,'vv~',$a,'B',0
	dc.b	',(n',$ee,'~',$10,0,0
	dcb.w	3
	dc.b	'_b?\',$7f,'^',$7f,$fe
	dc.b	$dc,$1c,'0',7,$b0,7,$ff,$ff
	dc.b	$cc,$1d,'$',6,$a4,7,$ff,$ff
	dc.b	'~',1,$80,0,$fc,0,$ff,$ff
	dc.b	1,$e1,0,'@',1,$c0,1,$ff
	dc.b	2,$b1,2,'`',2,$e0,2,$ff
	dc.b	0,'Y',0,'0',0,'p',0,$7f
	dc.b	0,$19,0,4,0,$1c,0,$1f
	dcb.w	13
	dc.b	'F',0,'F',$b1,'F`',0,0
	dc.b	0,'@',$80,$e1,0,0,$80,0
	dc.b	0,0,$80,'1',$80,1,0,0
	dc.b	0,0,0,1,0,0,0,0
	dc.b	5,0,5,0,7,0,5,0
	dc.b	0,0,5,'`',7,'`',$a,0
	dc.b	$1b,0,$1b,$c9,$1f,'0 ',0
	dc.b	$12,'P',$b2,$d9,'> ',0,0
	dcb.w	3
	dc.b	'O',$ea,'5|u~',$7f,$fe
	dc.b	$98,$1c,'p',3,$f0,3,$ff,$ff
	dc.b	$98,$1c,'p',$b,$f0,$b,$ff,$ff
	dc.b	'~',1,$80,0,$fc,0,$ff,$ff
	dc.b	3,$e1,2,0,3,$80,3,$ff
	dc.b	0,$b1,0,'`',0,$e0,0,$ff
	dc.b	0,'Y',0,'0',0,'p',0,$7f
	dc.b	0,$19,0,4,0,$1c,0,$1f
	dcb.w	12
	dc.b	$81,$80,1,$80,$81,$e0,$81,$80
	dc.b	1,$80,1,$80,$87,$c0,1,$80
	dc.b	1,$80,1,$80,1,$81,1,$80
	dc.b	1,$80,1,$80,$81,$81,1,$81
	dc.b	1,$80,3,$80,$83,$80,3,$80
	dc.b	3,$80,1,$c0,3,$c0,3,$80
	dc.b	5,$80,$d,$80,$d,$b1,$f,$c0
	dc.b	$11,$80,$d,$a0,$9d,$b1,$1f,$c0
	dcb.w	4
	dc.b	'G',$ce,'?',$b4,$7f,$b6,$7f,$fe
	dc.b	$dc,'<p',7,$f0,7,$ff,$ff
	dc.b	$cd,'=d',6,$e4,7,$ff,$ff
	dc.b	$7f,$f,$80,1,$fa,1,$ff,$ff
	dc.b	1,$f3,0,'@',1,'@',1,$ff
	dc.b	0,$bf,0,'q',0,$f1,0,$ff
	dc.b	0,$7f,2,$19,2,'y',2,$7f
	dc.b	0,$1b,0,5,0,$1d,0,$1f
	dcb.w	12
	dc.b	1,$80,1,$80,1,$e0,1,$80
	dc.b	1,$80,1,$80,7,$c0,1,$80
	dc.b	1,$81,1,$81,$81,$80,1,$81
	dc.b	1,$80,1,$80,$8f,$81,1,$81
	dc.b	1,$80,1,$80,$83,$80,1,$80
	dc.b	3,$80,1,$c0,3,$c0,3,$80
	dc.b	3,'@',3,$80,3,$c0,3,$c0
	dc.b	3,'@',3,$80,3,$c1,3,$c0
	dc.b	4,$10,4,$10,4,$10,4,$10
	dc.b	'O',$e2,'>',$fc,'~',$fe,$7f,$fe
	dc.b	$1a,'Px',7,'x',7,$ff,$ff
	dc.b	$1b,'Qy',$e,'y',$f,$ff,$ff
	dc.b	$7f,$9f,$80,5,$fe,5,$ff,$ff
	dc.b	'A',$ff,0,'AA',$c1,'A',$ff
	dc.b	'D_',0,'=D}D',$7f
	dc.b	0,'/',0,$1d,0,'=',0,'?'
	dc.b	0,$b,0,7,0,$f,0,$f
	dcb.w	12
	dc.b	0,$c0,1,'@',1,$80,1,$c0
	dc.b	0,$e1,1,'a',$85,$81,3,$e0
	dc.b	0,$e1,1,'a',$b5,$c0,$b,$a1
	dc.b	0,$f0,$1b,'p',$bb,$81,$85,$f0
	dc.b	0,$81,1,1,$85,$80,3,$81
	dc.b	0,$81,1,1,$81,$80,1,$81
	dc.b	0,$80,1,0,1,$80,1,$80
	dc.b	0,$c0,1,'@',1,$80,1,$c0
	dc.b	$e,0,$e,0,$e,0,$e,0
	dc.b	')',$d4,$17,$b8,'7',$bc,'?',$fc
	dc.b	$9f,$be,'l',$1c,$ec,$1e,$ff,$fe
	dc.b	$8f,$fe,'t\',$f4,'^',$ff,$fe
	dc.b	'>',$fe,'A',$a,'w',$a,$7f,$fe
	dc.b	'H',$fe,8,'*H',$ea,'H',$fe
	dc.b	0,'N',0,':',0,'z',0,'~'
	dc.b	0,'6',0,$8e,0,$be,0,$be
	dc.b	0,$a,0,6,0,$e,0,$e
	dcb.w	12
	dc.b	$81,'@',1,'@',$80,0,$81,$c0
	dc.b	0,$9c,4,$8d,$e,$10,0,$ed
	dc.b	1,$b1,1,$b1,$92,$a0,$d,'Q'
	dc.b	0,$b9,'$',$b9,$e7,$10,$18,$e9
	dc.b	0,'1',0,'1',$8d,0,2,'1'
	dc.b	0,1,0,1,$8e,0,4,1
	dc.b	0,1,0,$81,0,0,0,$81
	dc.b	1,'@',1,'@',0,0,1,$c0
	dc.b	4,'@',4,'@',4,'@',4,'@'
	dc.b	'"',4,$1f,$f8,'?',$fc,'?',$fc
	dc.b	'G',$fa,':4z6',$7f,$fe
	dc.b	'C',$f2,'>',$ac,'~',$ae,$7f,$fe
	dc.b	'=&B',$da,'~',$da,$7f,$fe
	dc.b	'q',$9e,0,'~p',$fe,'q',$fe
	dc.b	'`F',0,':`z`~'
	dc.b	0,'&',0,$1a,0,':',0,'>'
	dc.b	0,$1a,0,6,0,$1e,0,$1e
	dcb.w	12
	dc.b	1,'B',1,'B',0,0,1,$c2
	dc.b	0,$e0,0,$82,$c,'`',8,$9e
	dc.b	0,$da,0,$da,'lP',$10,$aa
	dc.b	0,$ce,'X',$ce,'\',8,' ',$f6
	dc.b	0,'*',0,':R',2,'L8'
	dc.b	0,$12,8,$12,'\',0,'@',$12
	dc.b	0,$92,0,$92,'D',$80,'@',$12
	dc.b	1,'@',1,'@',0,0,1,$c0
	dc.b	'@',$e0,'@',$e0,'@',$e0,'@',$e0
	dc.b	$18,'X',7,$e0,$1f,$f8,$1f,$f8
	dc.b	'!',$c4,$1d,'x=|?',$fc
	dc.b	'!',$c4,$1d,'x=|?',$fc
	dc.b	$18,$c,$27,$fc,'?',$fc,'?',$fc
	dc.b	$f,'<0',$dc,'?',$dc,'?',$fc
	dc.b	'8',$8c,0,'|8',$fc,'8',$fc
	dc.b	' d',0,$1c,' | |'
	dc.b	0,$10,0,$c,0,$1c,0,$1c
	dcb.w	12
	dc.b	3,'"',3,'"',0,0,3,$e2
	dc.b	0,'l',0,'J',0,'$',0,'Z'
	dc.b	0,$da,0,$da,'PR`',$a8
	dc.b	0,'v`vx6',0,'H'
	dc.b	0,$14,' ',$16,'l',4,'P',$1a
	dc.b	0,2,' ',6,'h',2,'P',$c
	dc.b	0,'J',0,'JX',2,8,'H'
	dc.b	0,$82,0,$82,0,0,0,$c2
	dc.b	$e1,$f0,$e1,$f0,$e1,$f0,$e1,$f0
	dc.b	7,$e0,0,0,7,$e0,7,$e0
	dc.b	$10,$18,$f,$e0,$1f,$f8,$1f,$f8
	dc.b	$10,$18,$f,$e0,$1f,$f8,$1f,$f8
	dc.b	$a,'X',$1d,$a8,$1d,$a8,$1f,$f8
	dc.b	1,'8',$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$18,0,$e8,$1f,$e8,$1f,$f8
	dc.b	$18,$c8,0,'8',$18,$f8,$18,$f8
	dc.b	0,' ',0,$18,0,'8',0,'8'
	dcb.w	12
	dc.b	2,$d4,2,$d4,0,0,3,$f4
	dc.b	0,'4',0,'$',0,$14,0,'('
	dc.b	0,'d',0,'l $ X'
	dc.b	0,'8 < ',8,0,'4'
	dc.b	0,8,'0',$c,'0',8,0,4
	dc.b	0,4,' ',$c,'0',4,$10,8
	dc.b	0,0,0,4,'8',0,'0',4
	dc.b	0,'L',0,'L ',8,0,'D'
	dc.b	$f0,$e0,$f0,$e0,$f0,$e0,$f0,$e0
	dcb.w	4
	dc.b	2,$e0,5,'@',7,$e0,7,$e0
	dc.b	2,$e0,5,'@',7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	0,'`',7,$e0,7,$e0,7,$e0
	dc.b	0,'`',7,$e0,7,$e0,7,$e0
	dc.b	7,$a0,0,'`',7,$e0,7,$e0
	dc.b	0,$e0,0,0,0,$e0,0,$e0
	dcb.w	12
	dc.b	$1a,$a8,$1a,$a8,0,'(',$1b,$90
	dc.b	0,0,0,$18,0,0,0,$18
	dc.b	0,' ',0,'0',$18,' ',0,$18
	dc.b	0,$18,0,$18,$18,8,8,$10
	dc.b	0,$10,0,$18,$18,$10,$18,8
	dc.b	0,$18,$10,$18,$18,8,8,$10
	dc.b	0,$18,0,$18,$18,8,$10,$10
	dc.b	0,$18,0,$18,$10,0,0,$18
	dc.b	$e0,'@',$e0,'@',$e0,'@',$e0,'@'
	dcb.w	4
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	0,$e0,0,$e0,0,$e0,0,$e0
	dcb.w	12
	dc.b	5,$e0,5,$e0,5,0,2,$e0
	dc.b	2,$e0,2,$e0,0,' ',2,$c0
	dc.b	0,$e0,0,$e0,4,' ',0,$c0
	dc.b	0,'`',0,'`',6,0,0,'`'
	dc.b	0,'`',0,'`',6,0,0,'`'
	dc.b	0,' ',0,' ',6,0,0,' '
	dc.b	0,'@',0,'@',4,0,0,'@'
	dcb.w	4
	dc.b	'@',4,'@',4,'@',4,'@',4
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$18,$f8,$18,$f8,$18,$f8,$18,$f8
	dc.b	0,'8',0,'8',0,'8',0,'8'
	dcb.w	44
	dc.b	' ',$e,' ',$e,' ',$e,' ',$e
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	'8',$fc,'8',$fc,'8',$fc,'8',$fc
	dc.b	'"|"|"|"|'
	dc.b	0,$1c,0,$1c,0,$1c,0,$1c
	dcb.w	13
	dc.b	7,$80,7,$e0,0,'`',0,0
	dc.b	7,$80,7,$e0,0,'`',0,0
	dc.b	7,$80,7,$e0,0,'`',0,0
	dc.b	7,$80,7,$e0,0,'`',0,0
	dc.b	7,$80,7,$e0,0,'`',0,0
	dc.b	7,$80,7,$e0,0,'`',0,0
	dc.b	7,$80,7,$e0,0,'`',0,0
	dc.b	7,$80,7,$e0,0,'`',1,$1f
	dc.b	1,$1f,1,$1f,1,$1f,'?',$fc
	dc.b	'?',$fc,'?',$fc,'?',$fc,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,'e',$fe
	dc.b	'e',$fe,'e',$fe,'e',$fe
l028d
	bra.s	l028d
l028e
	bra.s	l028e
l028f
	bra.s	l028f
l0290
	bra.s	l0290
	dc.b	0,'>',0,'>',0,'>',0,'>'
	dc.b	0,$1e,0,$1e,0,$1e,0,$1e
	dcb.w	13
	dc.b	$18,0,$1f,$f8,7,$f8,0,0
	dc.b	$1c,0,$1f,$f8,3,$f8,0,0
	dc.b	$1c,0,$1f,$f8,3,$f8,0,0
	dc.b	$1c,0,$1f,$f8,3,$f8,0,0
	dc.b	$18,0,$1f,$f8,7,$f8,0,0
	dc.b	$18,0,$1f,$f8,7,$f8,0,0
	dc.b	$18,0,$1f,$f8,7,$f8,0,0
	dc.b	$18,0,$1f,$f8,7,$f8,3,$8e
	dc.b	3,$8e,3,$8e,3,'Ž?',$fc
	dc.b	'?',$fc,'?',$fc,'?',$fc,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,'@',$fe
	dc.b	'@',$fe,'@',$fe,'@',$fe,0,'~'
	dc.b	0,'~',0,'~',0,'~',0,'>'
	dc.b	0,'>',0,'>',0,'>',0,$e
	dc.b	0,$e,0,$e,0,$e,0,0
	dcb.w	12
	dc.b	' ',0,'?',$fc,$10,$c,0,0
	dc.b	'0',0,'?',$fc,$f,$fc,0,0
	dc.b	'0',0,'?',$fc,$f,$fc,0,0
	dc.b	'0',0,'?',$fc,$f,$fc,0,0
	dc.b	' ',0,'?',$fc,$10,$c,0,0
	dc.b	' ',0,'?',$fc,$10,$c,0,0
	dc.b	' ',0,'?',$fc,$10,$c,0,0
	dc.b	' ',0,'?',$fc,$10,$c,1,4
	dc.b	1,4,1,4,1,4,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,'A',$ff
	dc.b	'A',$ff,'A',$ff,'A',$ff,'@',$7f
	dc.b	'@',$7f,'@',$7f,'@',$7f,0,$bf
	dc.b	0,$bf,0,$bf,0,$bf,0,$f
	dc.b	0,$f,0,$f,0,$f,0,0
	dcb.w	11
	dc.b	4,' ',4,' d._',$f2
	dc.b	0,0,'`',0,$7f,$fe,$1c,'>'
	dc.b	0,0,'`',0,$7f,$fe,$1f,$fe
	dc.b	0,0,'`',0,$7f,$fe,$1c,'>'
	dc.b	4,$a0,4,$a0,'t',$ae,'O',$f2
	dc.b	4,$80,4,$80,'tŽO',$f2
	dc.b	4,$a0,4,$a0,'d',$ae,'_',$f2
	dc.b	4,0,4,' d._',$f2
	dcb.w	4
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	5,$ff,5,$ff,5,$ff,5,$ff
	dc.b	0,$ff,0,$ff,0,$ff,0,$ff
	dc.b	0,$7f,0,$7f,0,$7f,0,$7f
	dc.b	0,$1f,0,$1f,0,$1f,0,$1f
	dcb.w	12
	dc.b	')',$80,'+',$c0,'i',$82,'>|'
	dc.b	0,0,'@',0,'|>#',$c6
	dc.b	0,0,'@',0,$7f,$fe,'?',$fe
	dc.b	0,0,'@',0,'|>#',$c6
	dc.b	'!',$80,'#',$c0,'a',$82,'>|'
	dc.b	'&',8,'/',8,'f',$a,'9',$fc
	dc.b	')',$80,'+',$c0,'i',$82,'>|'
	dc.b	'*`*',$f0,'jb?',$9c
	dcb.w	4
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	1,$ff,1,$ff,1,$ff,1,$ff
	dc.b	2,$ff,2,$ff,2,$ff,2,$ff
	dc.b	0,$7f,0,$7f,0,$7f,0,$7f
	dc.b	0,$1f,0,$1f,0,$1f,0,$1f
	dcb.w	12
	dc.b	3,$e0,$17,$e4,$93,$e5,'|',$1e
	dc.b	3,$e0,$87,$e0,$f3,$ef,'L',$12
	dc.b	0,0,$c0,0,$ff,$ff,'?',$ff
	dc.b	3,$e0,$87,$e0,$f3,$ef,'L',$12
	dc.b	$13,$e0,$17,$e4,$93,$e5,'|',$1e
	dc.b	$f,$90,$1f,$90,$8f,$91,'p~'
	dc.b	$13,$e4,$17,$e4,$93,$e5,'|',$1e
	dc.b	$1c,$f8,$1d,$f8,$98,$f9,'{',6
	dcb.w	4
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	3,$ff,3,$ff,3,$ff,3,$ff
	dc.b	0,$ff,0,$ff,0,$ff,0,$ff
	dc.b	0,$7f,0,$7f,0,$7f,0,$7f
	dc.b	0,$1f,0,$1f,0,$1f,0,$1f
	dcb.w	12
	dc.b	6,'a',$e,'s',6,'c',$f8,$1f
	dc.b	6,'p',$e,'p',$e6,'w',$98,9
	dc.b	0,0,$80,0,$7f,$ff,$ff,$ff
	dc.b	6,'p',$e,'p',$e6,'w',$98,9
	dc.b	6,'`',$e,'s',6,'c',$f8,$1f
	dc.b	$19,$83,'9',$c3,$19,$83,$e0,$7f
	dc.b	6,'c',$e,'s',6,'c',$f8,$1f
	dc.b	$d,$99,$f,$9d,1,$99,$f2,7
	dcb.w	4
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	1,$ff,1,$ff,1,$ff,1,$ff
	dc.b	0,$ff,0,$ff,0,$ff,0,$ff
	dc.b	2,$7f,2,$7f,2,$7f,2,$7f
	dc.b	0,$1f,0,$1f,0,$1f,0,$1f
	dcb.w	12
	dc.b	$c,'0',$c,'4',$c,'4',$f1,$f
	dc.b	$c,'0',$c,'4',$cc,'71',$c
	dcb.w	2
	dc.b	$ff,$ff,0,0,$c,'0',$c,'4'
	dc.b	$cc,'71',$c,$c,'0',$c,'4'
	dc.b	$c,'4',$f1,$f,'0',$d0,'0',$d4
	dc.b	'0',$d4,$c4,'?',$c,'4',$c,'4'
	dc.b	$c,'4',$f1,$f,$f,$c,$f,$c
	dc.b	$b,$c,$f8,'C',0,0,0,0
	dcb.w	2
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	'A',$ff,'A',$ff,'A',$ff,'A',$ff
	dc.b	'D',$7f,'D',$7f,'D',$7f,'D',$7f
	dc.b	0,'?',0,'?',0,'?',0,'?'
	dc.b	0,$f,0,$f,0,$f,0,$f
	dcb.w	12
	dc.b	$c,'0',$c,'0',$c,$10,$f0,'/'
	dc.b	$c,'0',$c,'0',$c,$10,$f0,'/'
	dcb.w	2
	dc.b	$ff,$ff,$ff,$ff,$c,'0',$c,'0'
	dc.b	$c,$10,$f0,'/',$c,'0',$c,'0'
	dc.b	$c,$10,$f0,'/2',$c0,'0',$cb
	dc.b	'2K',$c2,$bf,$c,'0',$c,'0'
	dc.b	$c,$10,$f0,'/',$1f,$c,$1f,$c
	dc.b	$13,4,$f0,$b,0,0,0,0
	dcb.w	2
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe
	dc.b	$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	'H',$fe,'H',$fe,'H',$fe,'H',$fe
	dc.b	0,'~',0,'~',0,'~',0,'~'
	dc.b	0,$be,0,$be,0,$be,0,$be
	dc.b	0,$e,0,$e,0,$e,0,$e
	dcb.w	12
	dc.b	'F`NpF',0,$f8,$7f
	dc.b	6,'`',$ce,'q',$c6,1,'8~'
	dc.b	0,0,$ff,$ff,$ff,$ff,0,0
	dc.b	6,'`',$ce,'q',$c6,1,'8~'
	dc.b	'F`NpF',0,$f8,$7f
	dc.b	$19,$80,'9',$c0,$18,0,$e1,$ff
	dc.b	$16,'`',$1e,'p',$16,0,$f8,$7f
	dc.b	$1d,$98,$1f,$9d,$11,$81,$f2,$1f
	dcb.w	4
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	$7f,$fe,$7f,$fe,$7f,$fe,$7f,$fe
	dc.b	'q',$fe,'q',$fe,'q',$fe,'q',$fe
	dc.b	'`~`~`~`~'
	dc.b	0,'>',0,'>',0,'>',0,'>'
	dc.b	0,$1e,0,$1e,0,$1e,0,$1e
	dcb.w	12
	dc.b	7,$e0,$27,$e4,$a7,'%x',$de
	dc.b	7,$e0,$27,$e6,$e7,$27,'X',$d8
	dcb.w	2
	dc.b	$ff,$ff,$7f,$fe,7,$e0,$27,$e6
	dc.b	$e7,$27,'X',$d8,$27,$e0,$27,$e4
	dc.b	$a7,'%x',$de,$1f,$80,$1f,$8e
	dc.b	$9c,$8f,'c|',$27,$e0,$27,$e4
	dc.b	$a7,'%x',$de,'-',$f8,'-',$f8
	dc.b	$a9,$c9,'z6',0,0,0,0
	dcb.w	2
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	'?',$fc,'?',$fc,'?',$fc,'?',$fc
	dc.b	'8',$fc,'8',$fc,'8',$fc,'8',$fc
	dc.b	' | | | |'
	dc.b	0,$1c,0,$1c,0,$1c,0,$1c
	dcb.w	12
	dc.b	1,$80,'#',$d4,'a',$96,$1e,'x'
	dc.b	1,$80,$13,$d8,'qž.t'
	dcb.w	2
	dc.b	$7f,$fe,'?',$fc,1,$80,$13,$d8
	dc.b	'qž.t',1,$80,'#',$d4
	dc.b	'a',$96,$1e,'x',6,0,'/D'
	dc.b	'fF',$19,$f8,1,$80,'#',$d4
	dc.b	'a',$96,$1e,'x',2,'`"',$f4
	dc.b	'bf',$1f,$98,0,0,0,0
	dcb.w	2
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$1f,$f8,$1f,$f8,$1f,$f8,$1f,$f8
	dc.b	$18,$f8,$18,$f8,$18,$f8,$18,$f8
	dc.b	0,'8',0,'8',0,'8',0,'8'
	dcb.w	13
	dc.b	$14,$18,'t',$1e,'/',$f4,0,0
	dc.b	$c,'0|>3',$cc,0,0
	dc.b	0,0,$7f,$fe,'?',$f8,0,0
	dc.b	$c,'0|>3',$cc,4,0
	dc.b	$14,'(t./',$f4,0,0
	dc.b	$10,$88,'pŽ/',$f4,4,0
	dc.b	$14,'(t./',$f4,4,0
	dc.b	$14,8,'t',$e,'/',$f4,0,0
	dcb.w	7
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	7,$e0,7,$e0,7,$e0,7,$e0
	dc.b	0,$e0,0,$e0,0,$e0,0,$e0
	dcb.w	13
	dc.b	$f,$f0,'?',$fc,$10,0,0,0
	dc.b	3,$c0,'?',$fc,$1c,'0',0,0
	dc.b	0,0,'?',$fc,$1f,$f0,0,0
	dc.b	3,$c0,'?',$fc,$1c,'0',0,0
	dc.b	$f,$f0,'?',$fc,$10,$c,0,0
	dc.b	$f,$f0,'?',$fc,$10,$c,0,0
	dc.b	$f,$f0,'?',$fc,$10,$c,0,0
	dc.b	$f,$f0,'?',$fc,$10,$c,0,0
	dcb.w	49
	dc.b	$1f,$f8,$f,$80,0,0,0,0
	dc.b	$1f,$f8,$f,$80,0,0,0,0
	dc.b	$1f,$f8,$f,$80,0,0,0,0
	dc.b	$1f,$f8,$f,$80,0,0,0,0
	dc.b	$1f,$f8,$f,$e0,0,0,0,0
	dc.b	$1f,$f8,$f,$e0,0,0,0,0
	dc.b	$1f,$f8,$f,$e0,0,0,0,0
	dc.b	$1f,$f8,7,$e0,0,0,0,0
	dcb.w	48
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dc.b	7,$e0,0,0,0,0,0,0
	dcb.w	243
	dc.b	0,4,0,8,0,$c,0,3
	dc.b	0,7,0,$b,0,$f,0,1
	dc.b	0,1,0,1,0,1,0,$80
	dc.b	0,'T',0,'*',0,0,0,0
	dcb.w	352
	dc.b	2,'"',3,'3',6,'f',0,3
	dc.b	7,5,0,'W',1,'Q',7,'w'
	dc.b	7,'p',3,'s',0,'0',3,'7'
	dc.b	3,0,5,0,7,0,0,0
	dc.b	0,0,$1f,$ff,0,0,0,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	0,0,$ff,$f8,0,0,0,0
	dcb.w	7
	dc.b	0,'?',0,$7f,0,$7f,0,$7f
	dc.b	$ff,$fc,$ff,$fc,$ff,$fc,$ff,$fc
	dcb.w	14
	dc.b	0,7,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$f8,0,0,$1f,$ff,$1f,$ff
	dc.b	$7f,$ff,$1f,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$f0,$ff,$f0
	dc.b	$ff,$fc,$ff,$f0,$7f,$e0,$ff,$e0
	dc.b	$ff,$e0,$ff,$e0,0,$1f,0,$1f
	dc.b	0,$1f,0,$1f,$f0,'?',$f0,$7f
	dc.b	$f0,$7f,$f0,$7f,$ff,$fe,$ff,$fd
	dc.b	$ff,$ff,$ff,$ff,$ff,$e0,$ff,$e0
	dc.b	$ff,$e0,$ff,$e0,$7f,$c7,$7f,$c7
	dc.b	$7f,$c7,$7f,$c7,$fc,'?',$fc,'?'
	dc.b	$fc,'?',$fc,'?',$e1,3,$e1,$83
	dc.b	$e1,$8f,$e1,$83,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$f8,$ff,$f8
	dc.b	$ff,$fe,$ff,$f8,' ',0,' ',0
	dc.b	$7f,$ff,' ',0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$f8,0,0,'?',$f0,$ff,$e0
	dc.b	$ff,$f0,$ff,$f0,0,$f,0,$1f
	dc.b	0,$1f,0,$1f,$ff,$df,$ef,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$fd,$ff,$fb
	dc.b	$ff,$ff,$ff,$ff,$ff,$e0,$ff,$f8
	dc.b	$ff,$f8,$ff,$f8,$7f,$c7,$7f,$c7
	dc.b	$7f,$c7,$7f,$c7,$fc,'?',$fc,'?'
	dc.b	$fc,'?',$fc,'?',$e3,0,$e3,$80
	dc.b	$e3,$87,$e3,$80,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,4,0,4
	dc.b	$ff,$fe,0,4,'@',0,'@',0
	dc.b	$f0,0,'@',0,0,0,0,0
	dcb.w	18
	dc.b	$1f,$f3,$ff,$c3,$ff,$f3,$ff,$f3
	dc.b	$ff,$f,$ff,$1f,$ff,$1f,$ff,$1f
	dc.b	$ff,$c0,$df,$e0,$ff,$e0,$ff,$ff
	dc.b	0,7,0,3,0,7,$ff,$ff
	dc.b	$ff,$f8,$ff,$fc,$ff,$fc,$ff,$fc
	dc.b	'?',$83,$7f,$c7,$7f,$c7,$7f,$c7
	dc.b	$f8,$1f,$fc,'?',$fc,'?',$fc,'?'
	dc.b	$c3,0,$e3,$c0,$e3,$c0,$e3,$c0
	dcb.w	20
	dc.b	0,2,0,2,0,$f,0,2
	dc.b	'@',0,'@',0,$e0,0,'@',0
	dcb.w	20
	dc.b	0,'3',$f0,3,$f0,'3',$ff,$f3
	dc.b	$ff,0,$ff,'0',$ff,'0',$ff,'?'
	dc.b	' @',$10,' 0o',$ff,$f0
	dc.b	$10,4,0,0,$bf,'4',0,$8f
	dc.b	0,'0',0,'>',0,'>',$ff,$fe
	dc.b	0,0,$e0,$e6,$e0,$e6,$ff,$e7
	dc.b	0,0,$c,'0',$c,'0',$fc,'?'
	dc.b	6,0,'f',$c0,'f',$c0,$e7,$c0
	dcb.w	20
	dc.b	0,2,0,2,0,7,0,2
	dc.b	'@',0,'@',0,$e0,0,'@',0
	dcb.w	2
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$f8,0,0,0,0,0,0,0
	dcb.w	2
	dc.b	0,'9p',3,'w',$bb,'x{'
	dc.b	$ff,$80,$fe,'0',$ff,$b7,$ff,$b8
	dc.b	'$B',$14,'"',$b5,'n|',$f2
	dc.b	0,4,'@',0,$ff,$95,0,$e
	dc.b	' ',1,0,$1e,$bf,$df,0,'?'
	dc.b	0,0,$c1,'f',$c3,'f',$e0,$e7
	dc.b	$a0,4,',0',$ec,'5<8'
	dc.b	'<',$7f,'|~}',$7f,$fe,$ff
	dcb.w	10
	dc.b	$f,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$8f,$e0,0,0,0,2,0,2
	dc.b	0,7,0,2,'@',0,'@',0
	dc.b	$e0,1,'@',0,0,0,0,0
	dc.b	$ff,$ff,'ww',0,0,0,0
	dc.b	$ff,$ff,'ww',0,0,0,0
	dc.b	$ff,$ff,']',$c7,0,0,0,0
	dc.b	$fc,0,'P',0,0,0,0,0
	dcb.w	2
	dc.b	0,$18,'p',6,'w',$de,'x?'
	dc.b	1,$80,0,'b',1,$ef,$ff,$f0
	dc.b	'!@',$10,' ',$b7,'ox',$f0
	dc.b	1,4,0,0,$fe,'U',1,$e
	dc.b	0,1,0,'N',$7f,$cf,0,$1f
	dc.b	$10,0,$c0,'f',$dd,'f',$e0,$e7
	dc.b	0,0,$c,'0',$cc,'2',$1c,'8'
	dc.b	0,6,'@',0,'A',6,$fc,'~'
	dcb.w	10
	dc.b	$1f,$ff,$e,$ee,0,0,0,0
	dc.b	$ff,$ff,$bb,$bb,0,0,0,0
	dc.b	$df,$f0,$8e,$a0,0,2,0,2
	dc.b	0,7,0,2,'@',0,'@',0
	dc.b	$e0,1,'@',0,0,0,$11,'T'
	dc.b	$99,$dc,$ee,$ab,0,0,$15,0
	dc.b	$9d,$aa,$ea,$ff,0,0,5,1
	dc.b	$a7,'9',$fa,$ee,0,0,0,0
	dc.b	$ac,0,$f8,0,0,0,0,0
	dcb.w	2
	dc.b	1,$18,'q',6,'w',$de,'y?'
	dc.b	1,$80,0,'`',$8d,$ed,3,$f0
	dc.b	' @',$10,' 6`x',$ff
	dc.b	0,4,0,0,0,$94,$fe,'.'
	dc.b	0,3,0,4,$e0,'W',$1e,$f
	dc.b	4,0,$c4,'f',$dc,'f',$e4,$e7
	dc.b	0,0,$c,'0',$ec,'7',$1c,'8'
	dc.b	'"',$c,'@',0,'o',$ec,$f0,$1c
	dcb.w	9
	dc.b	2,8,'3',$19,$1d,$f7,0,0
	dc.b	' ',$80,'d',$c4,$df,$7f,0,0
	dc.b	$82,0,$f3,'X]',$f0,0,2
	dc.b	0,2,0,7,0,2,'@',0
	dc.b	'@',0,$e0,1,'@',0,0,0
	dc.b	0,0,$aa,$ab,$ff,$ff,0,0
	dc.b	0,0,$aa,$88,$ff,$ff,0,0
	dc.b	0,0,$aa,$fa,$ff,$cf,0,0
	dc.b	0,0,$ac,0,$f8,0,0,0
	dcb.w	3
	dc.b	0,$18,'8',6,';ž<?'
	dc.b	1,$80,0,'`',$9d,$e5,'#',$f0
	dc.b	'`_',$10,' p',$7f,$f9,$ff
	dc.b	$f8,$c,0,0,$fb,$ad,$fc,$1e
	dc.b	$e,7,0,0,'.',$f7,'_',$f
	dc.b	0,0,$80,'6',$bf,$b6,$c0,'w'
	dc.b	0,4,$c,'4',$ac,'4\='
	dc.b	'08@',$80,'w',$b8,$f8,'x'
	dcb.w	10
	dc.b	'5w',$1f,$ff,0,0,0,0
	dc.b	']]',$ff,$ff,0,0,0,0
	dc.b	'uX',$df,$f0,0,2,0,2
	dc.b	0,7,0,2,'@',0,'@',0
	dc.b	$e0,1,'@',0,0,0,$11,0
	dc.b	$99,$aa,$ee,$ff,0,0,$10,0
	dc.b	$98,$aa,$ef,$ff,0,0,0,1
	dc.b	$aa,$b9,$ff,$ee,0,0,'P',0
	dc.b	$dc,0,$a8,0,0,0,0,0
	dcb.w	2
	dc.b	0,8,'8',4,':',$cd,'=',$1e
	dc.b	0,$80,0,'@',$96,$d5,1,$e2
	dc.b	'`',$7f,$10,0,'w',$7f,$f8,$ff
	dc.b	$e0,$1c,$10,0,$f5,$dc,$fa,'>'
	dc.b	8,2,1,1,'i;',$19,$87
	dc.b	0,0,$80,'6',$b3,'6',$c0,'w'
	dc.b	0,0,$c,'0',$ac,'5',$1c,'8'
	dc.b	0,0,'p0t',$b0,$fb,'p'
	dcb.w	9
	dc.b	0,$a,'5;',$1f,$f5,0,0
	dc.b	0,0,'UM',$ff,$ff,0,0
	dc.b	2,$a0,'s',$b8,$dd,'P',0,2
	dc.b	0,2,0,7,0,2,'@',0
	dc.b	'@',0,$e0,1,'@',0,0,0
	dc.b	0,0,$ba,$aa,$ff,$ff,0,0
	dc.b	0,0,$aa,$aa,$ff,$ff,0,0
	dc.b	0,0,$aa,$ba,$ff,$ef,0,0
	dc.b	0,0,$dc,0,$f0,0,0,0
	dc.b	0,$10,0,$10,0,$10,0,8
	dc.b	'8',4,';l<',$1e,0,$80
	dc.b	0,'@',$fa,$db,1,$e4,'`',$7f
	dc.b	$10,0,'u',$7f,$fa,$ff,$80,'8'
	dc.b	'`',4,$ef,$bc,$f0,$7f,8,$12
	dc.b	3,$11,$eb,'{',$1b,$97,9,0
	dc.b	$80,'6',$9e,$b6,$e1,'w',$80,0
	dc.b	$c,'0L7',$9c,'8',3,0
	dc.b	'`',$18,'c',$18,$ff,$f8,0,0
	dcb.w	9
	dc.b	'5}',$1f,$ef,0,0,0,0
	dc.b	'U]',$ff,$ff,0,0,0,0
	dc.b	'u',$b8,$de,$e0,0,2,0,2
	dc.b	0,7,0,2,'@',0,'@',0
	dc.b	$e0,1,'@',0,0,0,0,'U'
	dc.b	$ba,$dd,$ef,$aa,0,0,0,0
	dc.b	$aa,$aa,$ff,$ff,0,0,1,'A'
	dc.b	$ab,'y',$fe,$ae,0,0,0,0
	dc.b	$d8,0,$f0,0,0,$c,0,$1c
	dc.b	0,$1c,0,$1c,0,8,$1c,'D'
	dc.b	$1d,$ed,$1e,$1e,$90,$80,$80,'@'
	dc.b	$ec,$da,$91,$e1,$c0,'`0',0
	dc.b	$f5,'`',$f8,$e0,2,'`',$c0,$c
	dc.b	$dd,'m',$e2,$ee,$e,2,6,1
	dc.b	'n',$db,$1f,7,0,0,$80,'>'
	dc.b	$af,$be,$c0,$7f,0,0,$c,'0'
	dc.b	$ec,'1',$1c,'8',$f,$c4,'@',8
	dc.b	'O',$cc,$ff,$fc,0,0,0,0
	dcb.w	7
	dc.b	2,2,'3',$13,$1d,$fd,0,0
	dc.b	'(',0,'mD',$d7,$ff,0,0
	dc.b	$82,0,$f3,$b0,'\',$e0,0,2
	dc.b	0,2,0,7,0,2,'@',0
	dc.b	'@',0,$e0,1,'@',0,0,0
	dc.b	0,0,$ff,$ff,'Ew',0,0
	dc.b	0,0,$ff,$ff,'UU',0,0
	dc.b	0,0,$ff,$ff,'U',$c7,0,0
	dc.b	0,0,$f8,0,' ',0,0,3
	dc.b	0,$1f,0,$1f,0,$1f,$18,0
	dc.b	$1c,0,$1d,$83,$1e,$1c,2,8
	dc.b	0,8,$f7,':',0,$c9,$c2,'`'
	dc.b	'2',1,$f7,'a',$fa,$e1,0,$e0
	dc.b	$80,$c,$9e,$ed,$c1,$ee,0,6
	dc.b	'@',1,$c1,$a7,$1e,$f,0,0
	dc.b	0,$1e,$7f,$de,$80,'?@',2
	dc.b	$c,'0',$ec,'5',$1c,':<p'
	dc.b	'@',4,'|t',$fc,'|',0,0
	dcb.w	5
	dc.b	0,$7f,0,0,0,0,0,0
	dc.b	$ff,$ff,$e,$ee,0,0,0,0
	dc.b	$ff,$ff,$ba,$bb,0,0,0,0
	dc.b	$ff,$ff,'Ž@',0,2,0,2
	dc.b	$fc,7,0,2,'@',0,'@',0
	dc.b	$e0,0,'@',0,0,0,0,0
	dc.b	$ff,$ff,'{',$bb,0,0,0,0
	dc.b	$ff,$ff,$b8,$ee,0,0,0,0
	dc.b	$ff,$ff,$ae,$ee,0,0,0,0
	dc.b	$f0,0,$e0,0,0,1,0,$f
	dc.b	0,$f,0,$f,$f4,0,$f0,0
	dc.b	$f5,$b3,$fe,$c,0,0,0,0
	dc.b	$cf,'>',0,$c1,$c0,'`0',3
	dc.b	$f4,'c',$f8,$e3,'!',$c1,' ',$d
	dc.b	'}',$cd,$a3,$cf,0,6,0,1
	dc.b	'o7',0,$cf,0,0,0,$1e
	dc.b	'[',$9e,$a4,'?',0,0,$c,'0'
	dc.b	'L7',$1c,'8',$10,$1c,'`',2
	dc.b	'p',$1e,$f0,$1e,0,0,0,0
	dcb.w	4
	dc.b	0,$ff,0,'w',0,0,0,0
	dc.b	$ff,$ff,'w]',0,0,0,0
	dc.b	$ff,$ff,'9',$dd,0,0,0,0
	dc.b	$ff,$ff,$dd,']',0,2,0,2
	dc.b	$fe,7,$dc,2,'@',0,'@',0
	dc.b	$e0,0,'@',0,0,0,8,0
	dc.b	$cc,'Dw',$ff,0,0,8,$a
	dc.b	'O',$1b,$f5,$f5,0,0,2,$8a
	dc.b	'S',$9b,$fd,'u',0,0,' ',0
	dc.b	'8',0,$c0,0,0,0,0,$e
	dc.b	0,$e,0,$f,'f',0,'`',0
	dc.b	'f',$dc,$ff,0,0,1,$80,0
	dc.b	$86,$fd,'0',3,$c2,'`0',6
	dc.b	$f5,'f',$fa,$e7,3,$80,$10,$c
	dc.b	$fb,$8d,7,$8e,0,$e,0,1
	dc.b	$cf,'o',$10,$1f,4,$80,4,$1e
	dc.b	'E',$de,'Ž?@',0,'L4'
	dc.b	'l7\8',0,2,'`',0
	dc.b	'`',2,$e0,2,0,0,0,0
	dcb.w	3
	dc.b	0,'@',1,$c8,0,$bf,0,0
	dc.b	$14,4,$9c,$a6,$eb,$fb,0,0
	dc.b	1,$14,$c7,'6',$fe,$eb,0,0
	dc.b	0,$14,'"',$b6,$ff,$eb,0,2
	dc.b	'@',2,'c',7,$be,2,'@',0
	dc.b	'@',0,$e0,0,'@',0,0,0
	dc.b	0,0,$d5,$ed,$7f,$ff,0,0
	dc.b	0,0,$d7,$d5,'|',$ff,0,0
	dc.b	0,0,'Uu',$ff,$ff,0,0
	dc.b	0,0,'X',0,$f0,0,0,0
	dc.b	0,6,0,6,0,7,6,'@'
	dc.b	0,0,$96,'ho',2,0,9
	dc.b	2,0,$ce,$b5,'0',$b,$80,'`'
	dc.b	'0',$c,$b2,'l',$b8,$ee,$87,0
	dc.b	0,$c,$f7,$d,$f,$e,' ',4
	dc.b	0,3,'A',$b7,'>',$f,0,0
	dc.b	0,$1e,0,$1e,'Ž?',0,0
	dc.b	$c,'0',$cc,'6',$1c,'8',0,0
	dc.b	'`',0,'`',0,$e0,0,0,0
	dcb.w	5
	dc.b	1,$bb,0,$ff,0,0,0,0
	dc.b	$ab,$aa,$ff,$ff,0,0,0,0
	dc.b	$de,$ea,$fb,$ff,0,0,0,0
	dc.b	$f6,$aa,$df,$ff,0,2,0,2
	dc.b	$af,7,$fc,2,'@',0,'@',0
	dc.b	$e0,0,'@',0,0,0,8,0
	dc.b	$cc,$ec,'w',$bf,0,0,8,0
	dc.b	$cf,$d5,$f1,$ff,0,0,0,$a0
	dc.b	$15,$b5,$ff,'_',0,0,0,0
	dc.b	'X',0,$f0,0,0,0,0,7
	dc.b	0,7,0,7,2,0,0,0
	dc.b	'r}',$87,0,0,1,'0',0
	dc.b	'3-x',$83,$82,'`0',$18
	dc.b	$b7,'y',$b8,$fc,$d,$f0,3,$fc
	dc.b	$ef,$fd,$1f,$fe,$e,0,0,2
	dc.b	'n',$c2,$9f,$f,' ',0,' ',$e
	dc.b	'>',$ee,'!',$1f,1,$c0,$f,$f0
	dc.b	$cf,$f1,$1f,$f8,$1f,$c0,$7f,$e0
	dc.b	$7f,$e0,$ff,$e0,0,0,0,0
	dcb.w	3
	dc.b	0,'P',1,$d9,0,$af,0,0
	dc.b	5,0,$ad,$a6,$fa,$ff,0,0
	dc.b	1,'@',$cf,'j',$fa,$bf,0,0
	dc.b	0,0,'v',$a2,$df,$ff,0,2
	dc.b	'@',2,'g',7,$bc,2,'@',0
	dc.b	'@',0,$e0,0,'@',0,0,0
	dc.b	0,0,$dd,$ed,$7f,$ff,0,0
	dc.b	0,0,$d7,'U}',$ff,0,0
	dc.b	0,0,'U',$d5,$ff,$ff,0,0
	dc.b	0,0,'X',0,$f0,0,0,0
	dc.b	0,3,0,3,0,3,$10,$11
	dc.b	$91,0,$bd,'O',$d3,$90,0,'#'
	dc.b	'0',0,'7',$eb,'x',7,$80,'`'
	dc.b	'0',$10,$b6,'w',$b8,$f8,$13,$f0
	dc.b	$f,$fc,'_',$fd,'?',$fe,8,0
	dc.b	1,2,$e9,$a,$19,$97,0,0
	dc.b	0,$e,$f5,$ee,8,$1f,3,$e0
	dc.b	$f,$f0,$8f,$f4,'_',$fa,'?',$80
	dc.b	$7f,$e0,$7f,$e0,$ff,$e0,0,0
	dcb.w	5
	dc.b	1,$eb,0,$7f,0,0,0,0
	dc.b	$ae,$aa,$ff,$ff,0,0,0,0
	dc.b	$df,$aa,$f9,$ff,0,0,0,0
	dc.b	$f6,'*',$9f,$ff,0,2,0,2
	dc.b	$af,7,$fc,2,'@',0,'@',0
	dc.b	$e0,0,'@',0,0,0,0,0
	dc.b	$dc,'lw',$ff,0,0,0,$aa
	dc.b	'W',$bb,$fd,'U',0,0,0,'*'
	dc.b	'U;',$ff,$d5,0,0,0,0
	dc.b	'X',0,$f0,0,0,3,0,3
	dc.b	0,3,0,3,0,0,3,0
	dc.b	'{u',$87,$82,1,3,'1',0
	dc.b	'5',$eb,'y',7,0,'B1 '
	dc.b	'3i8',$f2,0,0,0,4
	dc.b	0,5,$7f,$fe,8,0,'C',2
	dc.b	$cb,'J',$1b,$87,' @',0,'N'
	dc.b	$1f,'n _',7,$f0,$f,$f0
	dc.b	$af,$f5,$1f,$f8,$7f,0,$7f,$e0
	dc.b	$7f,$e0,$ff,$e0,0,0,0,0
	dcb.w	3
	dc.b	0,$10,1,$98,0,$ef,0,0
	dc.b	1,4,$a9,$a6,$fe,$fb,0,0
	dc.b	0,'TFv',$ff,$ab,0,0
	dc.b	0,0,$f6,$aa,$9f,$ff,0,2
	dc.b	0,2,$a3,7,$fe,2,'@',0
	dc.b	'@',0,$e0,0,'@',0,0,0
	dc.b	0,0,$ff,$ff,$27,$93,0,0
	dc.b	0,0,$ff,$ff,$a8,$ee,0,0
	dc.b	0,0,$ff,$ff,$aa,$ee,0,0
	dc.b	0,0,$f8,0,$a0,0,0,7
	dc.b	0,7,0,7,0,7,6,0
	dc.b	1,0,$17,'s',$ef,$80,0,3
	dc.b	'x',0,'y{',$fc,7,0,'@'
	dc.b	'0 7l8',$f0,0,$81
	dc.b	0,4,$db,'%',4,$ce,$e,0
	dc.b	6,0,'N',$f8,$1f,7,0,0
	dc.b	0,6,$c0,$e6,$1f,$f,0,4
	dc.b	0,$10,'@',$13,$9f,$fc,0,0
	dc.b	0,$e0,0,$e0,$ff,$e0,0,0
	dcb.w	5
	dc.b	0,$ff,0,'w',0,0,0,0
	dc.b	$ff,$ff,'W]',0,0,0,0
	dc.b	$ff,$ff,$b9,$dd,0,0,0,0
	dc.b	$ff,$ff,9,'U',0,2,0,2
	dc.b	$fe,7,$1c,2,'@',0,'@',0
	dc.b	$e0,0,'@',0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$f0,0,0,0,0,6,0,6
	dc.b	0,6,0,7,$e6,0,1,$90
	dc.b	$e7,$99,$ff,$c0,0,7,'x',0
	dc.b	'{',$97,$fc,$f,2,'@2 '
	dc.b	'6c:',$f0,' ',0,' ',4
	dc.b	$fc,$e5,' ',$e,0,' ',0,4
	dc.b	$e0,$f5,$1e,$e,$1f,4,0,'"'
	dc.b	$df,'v?',$8f,0,0,1,$10
	dc.b	$df,$97,0,'8 ',0,' ',$e0
	dc.b	'2',$e0,'!',$e0,0,0,0,0
	dcb.w	4
	dc.b	0,$7f,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,2,0,2
	dc.b	$fc,7,0,2,'@',0,'@',0
	dc.b	$e0,0,'@',0,0,0,0,0
	dcb.w	14
	dc.b	0,$f,0,$c,0,$f,0,$f
	dc.b	$e4,0,$13,$80,$f7,$ba,$ff,$c5
	dc.b	0,6,$ec,0,$ed,$e6,$ee,$e
	dc.b	0,'@0 7m8',$f2
	dc.b	0,'@',8,4,$ba,$f5,1,$e
	dc.b	0,0,0,4,'v',$d5,0,$e
	dc.b	$1f,4,0,2,'_',$16,'?',$cf
	dc.b	$10,0,'@',$10,$f7,$d2,0,'8'
	dc.b	0,0,2,$e0,$fe,$e0,1,$e0
	dcb.w	20
	dc.b	0,2,0,2,0,7,0,2
	dc.b	'@',0,'@',0,$f0,0,'@',0
	dcb.w	16
	dc.b	0,$f,0,8,0,$f,0,$f
	dc.b	$e4,0,$19,$80,$fd,$80,$fd,$ff
	dc.b	0,6,$ec,0,$ec,6,$ef,$fe
	dc.b	0,'@0 7`8',$ff
	dc.b	0,0,0,4,0,5,$ff,$fe
	dc.b	'B',8,2,0,$bb,'KB<'
	dc.b	$1e,0,1,2,$df,'j?',$87
	dc.b	'"',0,' ',$10,$ed,$d5,'":'
	dc.b	'D',0,4,$e0,$fc,$e0,5,$e0
	dcb.w	20
	dc.b	0,2,0,2,0,$f,0,2
	dc.b	' ',0,' ',0,$7f,$ff,' ',0
	dcb.w	2
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,$1f,0,$10
	dc.b	$fe,$1f,0,$1f,4,'?',$19,$c0
	dc.b	$1d,$ff,$1d,$ff,1,$fe,$c6,0
	dc.b	$c7,$fe,$c7,$fe,0,'_0 '
	dc.b	'0',$7f,'?',$ff,$ff,$f8,0,4
	dc.b	$ff,$fc,$ff,$ff,0,'8',0,0
	dc.b	0,'8',$ff,$ff,'8',0,1,$82
	dc.b	'9',$82,$f9,$ff,0,0,0,$10
	dc.b	0,$10,$ff,$ff,0,0,0,$e0
	dc.b	0,$e3,$ff,$e0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,4,0,4
	dc.b	$ff,$fe,0,4,$1f,$ff,$1f,$ff
	dc.b	$7f,$ff,$1f,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$fc,$18,$fc,0
	dc.b	$ff,$18,$fc,$18,4,$7f,8,$80
	dc.b	$c,$ff,$c,$ff,$83,$fc,'D',0
	dc.b	$c7,$fc,$c7,$fc,$f,$ff,'0',0
	dc.b	'?',$ff,'?',$ff,$ff,$fb,0,4
	dc.b	$ff,$ff,$ff,$ff,$ff,$f7,0,8
	dc.b	$ff,$ff,$ff,$ff,$f8,'}',1,$82
	dc.b	$f9,$ff,$f9,$ff,$ff,$ef,0,$10
	dc.b	$ff,$ff,$ff,$ff,$ff,1,0,$e1
	dc.b	$ff,$e7,$ff,$e1,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$f8,$ff,$f8
	dc.b	$ff,$fe,$ff,$f8,0,0,0,0
	dc.b	$1f,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$fe,0,0,0,0,$ff,6,0
	dc.b	6,$ff,6,$ff,$83,$fc,'D',0
	dc.b	$c7,$fc,$c7,$fc,$1f,$ff,' ',0
	dc.b	'?',$ff,'?',$ff,$ff,$f7,0,8
	dc.b	$ff,$ff,$ff,$ff,$ff,$ef,0,$10
	dc.b	$ff,$ff,$ff,$ff,$f0,$ff,0,0
	dc.b	$f0,$ff,$f0,$ff,$ff,$df,0,' '
	dc.b	$ff,$ff,$ff,$ff,$ff,$80,0,'`'
	dc.b	$ff,$e3,$ff,$e0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$f8,0,0,0,0,0,0
	dcb.w	30
	dc.b	'?',$e0,0,0,'?',$e0,'?',$e0
	dc.b	0,$1f,0,0,0,$1f,0,$1f
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$f0,$7f,0,0,$f0,$7f,$f0,$7f
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$c0,0,0,$ff,$c0,$ff,$c0
	dcb.w	185
	dc.b	$ff,$ff,0,0,$ff,$ff,0,0
	dc.b	$ff,$ff,0,0,$ff,$ff,0,0
	dc.b	$ff,$fe,0,0,$ff,$fe,0,0
	dcb.w	56
	dc.b	$7f,$ff,0,0,$7f,$ff,0,0
	dc.b	$ff,$ff,0,0,$ff,$ff,0,0
	dc.b	$ff,$ff,0,0,$ff,$ff,0,0
	dcb.w	162
	dc.b	$18,0,0,0,0,0,0,0
	dcb.w	64
	dc.b	'<',0,0,0,0,0,0,0
	dc.b	$c,0,0,0,0,0,0,0
	dc.b	'<<',0,0,0,0,0,0
	dc.b	'8',0,0,0,0,0,0,0
	dcb.w	64
	dc.b	'F',0,0,0,0,0,0,0
	dc.b	$1c,0,0,0,0,0,0,0
	dc.b	'fb',0,0,$18,0,$18,0
	dc.b	1,0,0,0,0,0,0,0
	dcb.w	62
	dc.b	'&',0,'&',0,0,$80,0,0
	dc.b	'<',0,'<',0,0,0,0,0
	dc.b	'fr',$e7,'r',$81,0,0,0
	dc.b	0,0,$18,0,$18,0,0,0
	dcb.w	65
	dc.b	$c,0,$c,0,0,0,0,0
	dc.b	'l',0,'l',0,0,0,0,0
	dc.b	$e7,'<',$e7,'<',0,0,$18,0
	dc.b	$18,0,1,0,0,0,0,0
	dcb.w	63
	dc.b	'0',0,'0',0,0,$80,0,0
	dc.b	$fe,0,$fe,0,0,0,0,0
	dc.b	'fN',$e7,'N',$81,0,0,0
	dcb.w	2
	dc.b	$18,0,0,0,0,0,0,0
	dcb.w	64
	dc.b	'b',0,0,0,0,0,0,0
	dc.b	$c,0,0,0,0,0,0,0
	dc.b	'fF',0,0,0,0,'B',0
	dc.b	'~',0,0,0,0,0,0,0
	dcb.w	62
	dc.b	2,0,2,0,'|',0,0,0
	dcb.w	2
	dc.b	$1e,0,0,0,0,0,0,0
	dc.b	'<<',0,0,0,0,0,0
	dcb.w	308
	dc.b	'<<',0,0,0,0,0,0
	dc.b	'<<',0,0,0,0,0,0
	dc.b	'<<',0,0,0,0,0,0
	dcb.w	68
	dc.b	'ff',0,0,0,0,0,0
	dc.b	'ff',0,0,0,0,0,0
	dc.b	'ff',0,0,0,0,0,0
	dcb.w	66
	dc.b	'ff',$e7,$e7,$81,$81,0,0
	dc.b	'ff',$e7,$e7,$81,$81,0,0
	dc.b	'ff',$e7,$e7,$81,$81,0,0
	dcb.w	69
	dc.b	$e7,$e7,$e7,$e7,0,0,0,0
	dc.b	$e7,$e7,$e7,$e7,0,0,0,0
	dc.b	$e7,$e7,$e7,$e7,0,0,0,0
	dcb.w	67
	dc.b	'ff',$e7,$e7,$81,$81,0,0
	dc.b	'ff',$e7,$e7,$81,$81,0,0
	dc.b	'ff',$e7,$e7,$81,$81,0,0
	dcb.w	70
	dc.b	'ff',0,0,0,0,0,0
	dc.b	'ff',0,0,0,0,0,0
	dc.b	'ff',0,0,0,0,0,0
	dcb.w	68
	dc.b	'<<',0,0,0,0,0,0
	dc.b	'<<',0,0,0,0,0,0
	dc.b	'<<',0,0,0,0,0,0
	dcb.w	157
	dc.b	$ff,$ff,$ff,$ff,0,0,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,0,0,$ff,$ff
	dc.b	$ff,$fe,$ff,$fe,0,0,$ff,$fe
	dcb.w	56
	dc.b	$7f,$ff,$7f,$ff,0,0,$7f,$ff
	dc.b	$ff,$ff,$ff,$ff,0,0,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,0,0,$ff,$ff
	dcb.w	57
	dc.b	$80,0,$80,0,$80,0,0,0
	dcb.w	19
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$f1,$e0,0,0,$f1,$e0,$f1,$e0
	dc.b	'G',$8a,0,$d,'G',$80,'G',$80
	dc.b	'~',$f0,$80,0,0,$f0,0,$f0
	dc.b	'Z',$bb,$a5,'D',0,0,0,0
	dc.b	$b0,$ff,'N',0,0,$ff,0,$ff
	dc.b	$f6,$f1,0,4,$f6,$f1,$f6,$f1
	dc.b	0,'&',3,$d9,0,0,0,0
	dc.b	$ff,8,0,$f7,0,0,0,0
	dc.b	$e3,'W',$1c,$a0,0,7,0,7
	dc.b	$fc,'+',1,$d4,$fc,0,$fc,0
	dc.b	$cf,$1b,'0',$e4,0,0,0,0
	dc.b	$e4,$f0,$1b,8,0,0,0,0
	dc.b	'u',$fc,4,3,'q',$ff,'q',$ff
	dc.b	$ff,$e1,0,$e,$ff,$e0,$ff,$e0
	dc.b	1,'D',$fe,$bb,0,0,0,0
	dc.b	$d,$ec,$e0,$b,$d,$e0,$d,$e0
	dc.b	' ',$18,$df,0,0,$18,0,$18
	dc.b	$df,$f8,0,0,$df,$f8,$df,$f8
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$1f,$ff,0,0,$1f,$ff,$1f,$ff
	dc.b	$fe,$16,0,0,$fe,$16,$fe,$16
	dc.b	$ec,'q',0,0,$ec,'p',$ec,'p'
	dc.b	$8c,$f5,'r',0,0,$f5,0,$f5
	dc.b	1,$86,'~y',0,0,0,0
	dc.b	$90,$7f,'o',0,0,$7f,0,$7f
	dc.b	$f8,'z',0,2,$f8,'x',$f8,'x'
	dc.b	$b4,$b2,3,'M',$b4,0,$b4,0
	dc.b	$7f,$e3,$80,$1c,0,0,0,0
	dc.b	$87,$e7,'x',$10,0,7,0,7
	dc.b	$fc,$e6,1,$19,$fc,0,$fc,0
	dc.b	'^',$b8,$a1,'G',0,0,0,0
	dc.b	$90,'Eo',$b8,0,5,0,5
	dc.b	$eb,$f3,8,4,$e3,$f7,$e3,$f7
	dc.b	$ff,$c6,0,$19,$ff,$c0,$ff,$c0
	dc.b	'I',$a9,$b6,'V',0,0,0,0
	dc.b	'E',$e6,$80,9,5,$e0,5,$e0
	dc.b	$b0,$8d,'H',0,0,$8d,0,$8d
	dc.b	$8f,$87,0,0,$8f,$87,$8f,$87
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$81,$ff,$80,0,1,$ff,1,$ff
	dc.b	$ff,$e0,0,0,$ff,$e0,$ff,$e0
	dc.b	'F',$c6,0,0,'F',$c6,'F',$c6
	dc.b	'6x',9,0,0,'x',0,'x'
	dc.b	'Z',$b1,'-N',0,0,0,0
	dc.b	2,$1f,$fd,$80,0,$1f,0,$1f
	dc.b	$fe,$e0,0,0,$fe,$e0,$fe,$e0
	dc.b	0,$8c,1,'s',0,0,0,0
	dc.b	'`"',$9f,$dd,0,0,0,0
	dc.b	0,$17,$ff,$e0,0,7,0,7
	dc.b	$fc,5,1,$fa,$fc,0,$fc,0
	dc.b	'Y',$ea,$a6,$15,0,0,0,0
	dc.b	$fe,' ',1,$d0,0,0,0,0
	dc.b	$e7,$e7,0,$18,$e7,$ff,$e7,$ff
	dc.b	$ff,$b,0,'4',$ff,0,$ff,0
	dc.b	0,'D',$ff,$bb,0,0,0,0
	dc.b	'k',$c9,$80,$16,'+',$c0,'+',$c0
	dc.b	$c7,$d8,0,0,7,$d8,7,$d8
	dc.b	$d8,$7f,0,0,$d8,$7f,$d8,$7f
	dc.b	$ff,$f8,0,0,$ff,$f8,$ff,$f8
	dc.b	$c8,$f,$f0,0,0,$f,0,$f
	dc.b	$ff,$f6,0,0,$ff,$f6,$ff,$f6
	dc.b	$ac,'h',0,0,$ac,'h',$ac,'h'
	dc.b	$c7,'a',4,0,$c0,'a',$c0,'a'
	dc.b	$8f,$80,'0',$7f,$80,0,$80,0
	dc.b	$e,7,$f1,$e0,0,7,0,7
	dc.b	$ff,'7',0,0,$ff,'7',$ff,'7'
	dc.b	$b4,$13,1,$ec,$b4,0,$b4,0
	dc.b	$14,$c2,$eb,'=',0,0,0,0
	dc.b	'p',7,$8f,$f0,0,7,0,7
	dc.b	$fc,'j',1,$95,$fc,0,$fc,0
	dc.b	$ff,'K',0,$b4,0,0,0,0
	dc.b	'z',5,$85,$f0,0,5,0,5
	dc.b	$df,$9f,0,' ',$df,$bf,$df,$bf
	dc.b	$fc,8,0,$f7,$fc,0,$fc,0
	dc.b	'P$',$af,$db,0,0,0,0
	dc.b	0,'V',$80,8,0,'@',0,'@'
	dc.b	'8',$8d,0,0,'8',$8d,'8',$8d
	dc.b	$c7,$ff,0,0,$c7,$ff,$c7,$ff
	dc.b	$ff,0,0,0,$ff,0,$ff,0
	dc.b	',',0,$d7,0,0,0,0,0
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$c2,$c5,0,0,$c2,$c5,$c2,$c5
	dc.b	$f9,$b4,0,0,$f8,'4',$f8,'4'
	dc.b	$1f,'d ',$9b,0,0,0,0
	dc.b	't#',$8b,$d8,0,3,0,3
	dc.b	$ff,$c3,0,0,$ff,$c3,$ff,$c3
	dc.b	$d4,3,1,$fc,$d4,0,$d4,0
	dc.b	'Q',$a,$ae,$f5,0,0,0,0
	dc.b	0,3,$ff,$f0,0,3,0,3
	dc.b	$f9,'$',0,$db,$f8,0,$f8,0
	dc.b	1,$84,$fe,'{',0,0,0,0
	dc.b	0,'K',$ff,$b0,0,$b,0,$b
	dc.b	$7f,'?',0,$c0,$7f,$ff,$7f,$ff
	dc.b	$f8,0,3,$ff,$f8,0,$f8,0
	dc.b	$16,$d7,$e9,'(',0,0,0,0
	dc.b	'*',$b1,0,0,'**',$81
	dc.b	$1d,$dc,0,0,$1d,$dc,$1d,$dc
	dc.b	'?',$ff,0,0,'?',$ff,'?',$ff
	dc.b	$f0,2,0,$d,$f0,0,$f0,0
	dc.b	$10,0,$ff,$c,0,0,0,0
	dc.b	7,$ff,0,0,7,$ff,7,$ff
	dc.b	$fe,$e8,0,0,$fe,$e8,$fe,$e8
	dc.b	$88,'!',0,0,$88,'!',$88,'!'
	dc.b	'V',$83,9,'|@',0,'@',0
	dc.b	0,$80,$ff,'|',0,0,0,0
	dc.b	$ff,$f6,0,0,$ff,$f6,$ff,$f6
	dc.b	'&3',1,$cc,'&',0,'&',0
	dc.b	9,'P',$f6,$af,0,0,0,0
	dc.b	'V',$83,$a9,'x',0,3,0,3
	dc.b	$f8,0,3,$ff,$f8,0,$f8,0
	dc.b	4,$cd,$fb,'2',0,0,0,0
	dc.b	' ',0,$df,$f0,0,0,0,0
	dc.b	$fc,$ff,1,0,$fd,$ff,$fd,$ff
	dc.b	$e0,0,7,$ff,$e0,0,$e0,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	$b0,$f,0,0,$b0,$f,$b0,$f
	dc.b	$b8,$e3,0,0,$b8,$e3,$b8,$e3
	dc.b	$ff,$fe,0,0,$ff,$fe,$ff,$fe
	dc.b	0,0,3,$f,0,0,0,0
	dc.b	0,$80,$ff,'_',0,0,0,0
	dc.b	'@',$7f,$e0,0,0,$7f,0,$7f
	dc.b	$ff,$85,0,0,$ff,$85,$ff,$85
	dc.b	$dd,$d6,0,0,$dd,$d6,$dd,$d6
	dc.b	$e,$ca,$11,'5',0,0,0,0
	dc.b	$1a,'$',$e5,$db,0,0,0,0
	dc.b	'?',$fb,0,0,'?',$fb,'?',$fb
	dc.b	'r!',1,$de,'r',0,'r',0
	dc.b	$10,8,$ef,$f7,0,0,0,0
	dc.b	' ',3,$df,$f8,0,3,0,3
	dc.b	$f8,'r',3,$8d,$f8,0,$f8,0
	dc.b	$9c,'Bc',$bd,0,0,0,0
	dc.b	'R',$db,$ad,' ',0,$b,0,$b
	dc.b	$f9,$ff,2,0,$fb,$ff,$fb,$ff
	dc.b	$80,4,$1f,$ff,$80,0,$80,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	$a,$91,0,0,$a,$91,$a,$91
	dc.b	$1d,$1f,0,0,$1d,$1f,$1d,$1f
	dc.b	$ff,$e0,0,0,$ff,$e0,$ff,$e0
	dc.b	4,$94,$7f,$ab,0,0,0,0
	dc.b	$10,$e,$e6,$1b,0,0,0,0
	dc.b	'"',$f,$dc,0,0,$f,0,$f
	dc.b	$ff,$f8,0,0,$ff,$f8,$ff,$f8
	dc.b	8,$81,0,0,8,$81,8,$81
	dc.b	'@',0,0,0,'@',0,'@',0
	dcb.w	4
	dc.b	$f,$fc,0,0,$f,$fc,$f,$fc
	dc.b	4,0,0,0,4,0,4,0
	dcb.w	4
	dc.b	0,3,0,0,0,3,0,3
	dc.b	$f8,0,0,0,$f8,0,$f8,0
	dcb.w	4
	dc.b	0,7,0,0,0,7,0,7
	dc.b	$e3,$fe,$c,0,$ef,$fe,$ef,$fe
	dcb.w	8
	dc.b	$a0,$bb,0,0,$a0,$bb,$a0,$bb
	dc.b	$a1,$ff,0,0,$a1,$ff,$a1,$ff
	dc.b	$ff,0,0,7,$ff,0,$ff,0
	dc.b	0,'0',$ef,$87,0,0,0,0
	dc.b	'm',$90,$92,$f,0,0,0,0
	dc.b	',',0,$d3,$80,0,0,0,0
	dc.b	$7f,$ff,0,0,$7f,$ff,$7f,$ff
	dc.b	$dd,$d0,0,0,$dd,$d0,$dd,$d0
	dc.b	$1f,$ff,0,0,$1f,$ff,$1f,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$f7,$ff,0,0,$f7,$ff,$f7,$ff
	dc.b	'o',$ff,0,0,'o',$ff,'o',$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$fb,0,0,$ff,$fb,$ff,$fb
	dc.b	$fb,$ff,0,0,$fb,$ff,$fb,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$cf,$fd,$10,0,$df,$fd,$df,$fd
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$d,$11,0,0,$d,$11,$d,$11
	dc.b	$1f,$ff,0,0,$1f,$ff,$1f,$ff
	dc.b	$e0,0,0,$1f,$e0,0,$e0,0
	dc.b	8,'-',$f7,$90,0,0,0,0
	dc.b	$e9,$b,$14,$14,0,0,0,0
	dc.b	$d6,0,')_',0,0,0,0
	dc.b	7,$ff,$80,0,7,$ff,7,$ff
	dc.b	$f1,$88,0,0,$f1,$88,$f1,$88
	dc.b	'_',$ff,0,0,'_',$ff,'_',$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$f9,$ff,0,0,$f9,$ff,$f9,$ff
	dc.b	$87,$ff,0,0,$87,$ff,$87,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$fb,0,0,$ff,$fb,$ff,$fb
	dc.b	$fb,$ff,0,0,$fb,$ff,$fb,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$1f,$f3,'`',0,$7f,$f3,$7f,$f3
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	8,$ba,0,0,8,$ba,8,$ba
	dc.b	$ff,$fe,0,0,$ff,$fe,$ff,$fe
	dc.b	0,$90,$1f,$af,0,0,0,0
	dc.b	4,'7',$fb,$80,0,0,0,0
	dc.b	0,'J',0,$15,0,0,0,0
	dc.b	$e2,0,4,$1f,0,0,0,0
	dc.b	' ?',$d8,0,0,'?',0,'?'
	dc.b	$fe,'R',0,0,$fe,'R',$fe,'R'
	dc.b	$df,$ff,0,0,$df,$ff,$df,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$fe,$7f,0,0,$fe,$7f,$fe,$7f
	dc.b	$ef,$ff,0,0,$ef,$ff,$ef,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$fb,0,0,$ff,$fb,$ff,$fb
	dc.b	$fb,$ff,0,0,$fb,$ff,$fb,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$fe,0,0,$ff,$fe,$ff,$fe
	dc.b	$7f,$cf,$80,0,$ff,$cf,$ff,$cf
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	']',$8f,0,0,']',$8f,']',$8f
	dc.b	$ff,$c0,0,1,$ff,$c0,$ff,$c0
	dc.b	4,'8',$ff,$86,0,0,0,0
	dc.b	$81,'?>',$80,0,0,0,0
	dc.b	0,2,0,1,0,0,0,0
	dc.b	$e,4,$b1,$9b,0,0,0,0
	dc.b	'@',1,$bf,$80,0,1,0,1
	dc.b	$ff,$c8,0,0,$ff,$c8,$ff,$c8
	dc.b	'_',$ff,0,0,'_',$ff,'_',$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$bf,0,0,$ff,$bf,$ff,$bf
	dc.b	$f3,$ff,0,0,$f3,$ff,$f3,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$fb,0,0,$ff,$fb,$ff,$fb
	dc.b	$fb,$ff,0,0,$fb,$ff,$fb,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$f8,0,3,$ff,$fb,$ff,$fb
	dc.b	$ff,$bf,0,0,$ff,$bf,$ff,$bf
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	8,$7f,0,0,8,$7f,8,$7f
	dc.b	$f8,2,0,$1f,$f8,0,$f8,0
	dc.b	0,'#',$fe,$84,0,0,0,0
	dc.b	'&?',$d9,$80,0,0,0,0
	dc.b	$aa,$c,0,'p',$aa,'|',$aa,'|'
	dc.b	5,$1a,$10,7,0,0,0,0
	dc.b	$d0,'D/',$c,0,0,0,0
	dc.b	7,$fe,0,0,7,$fe,7,$fe
	dc.b	$df,$ff,0,0,$df,$ff,$df,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$cf,0,0,$ff,$cf,$ff,$cf
	dc.b	$fd,$ff,0,0,$fd,$ff,$fd,$ff
	dc.b	$fe,$ff,0,0,$fe,$ff,$fe,$ff
	dc.b	$ff,$fb,0,0,$ff,$fb,$ff,$fb
	dc.b	$fb,$ff,0,0,$fb,$ff,$fb,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$f3,0,4,$ff,$f7,$ff,$f7
	dc.b	$fe,$7f,0,0,$fe,$7f,$fe,$7f
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	'W',$fc,0,0,'W',$fc,'W',$fc
	dc.b	1,$10,2,'/',0,0,0,0
	dc.b	0,'=',$ff,$82,0,0,0,0
	dc.b	'#',8,$d0,0,0,0,0,0
	dc.b	0,'p',0,$f,0,$7f,0,$7f
	dc.b	' ',4,$c0,$1b,$e0,0,$e0,0
	dc.b	$c0,$84,'&',$1b,0,0,0,0
	dc.b	'(',0,$c0,0,0,0,0,0
	dcb.w	49
	dc.b	0,1,0,0,0,0,8,')'
	dc.b	$7f,$86,0,0,0,0,$c4,'/'
	dc.b	';',$80,0,0,0,0,$f3,0
	dcb.w	3
	dc.b	$aa,$7f,0,0,$aa,$7f,$aa,$7f
	dc.b	$c1,2,'>',5,$ff,0,$ff,0
	dc.b	'G',0,$b0,$9f,0,0,0,0
	dc.b	' ',5,$df,$1b,0,0,0,0
	dc.b	' ',2,$d6,$1f,0,0,0,0
	dc.b	$b,2,$fd,$1f,0,0,0,0
	dc.b	'h',$1c,$97,$1f,0,0,0,0
	dc.b	'i',$10,$9f,$1f,0,0,0,0
	dc.b	$16,8,$eb,$1f,0,0,0,0
	dc.b	3,0,$ff,$1f,0,0,0,0
	dc.b	$a,9,$ff,$1d,0,0,0,0
	dc.b	2,8,$ff,$17,0,0,0,0
	dc.b	2,0,$fd,$1f,0,0,0,0
	dc.b	',',2,$db,$1f,0,0,0,0
	dc.b	4,2,$fb,$1f,0,0,0,0
	dc.b	$80,0,$ff,$1f,0,0,0,0
	dc.b	'@',8,$bf,$1f,0,0,0,0
	dc.b	'(5',$d7,$88,0,0,0,0
	dc.b	'@7',$8f,$80,0,0,0,0
	dc.b	$90,2,'@',$7f,0,0,0,0
	dc.b	0,$7f,0,0,0,$7f,0,$7f
	dc.b	$fe,8,1,$f0,$ff,$f8,$ff,$f8
	dc.b	$a,$10,$14,$f,0,0,0,0
	dc.b	$e2,1,$1c,$be,0,0,0,0
	dc.b	1,$a,$fe,$b1,0,0,0,0
	dc.b	$ef,' 0',$bf,0,0,0,0
	dc.b	9,'!',$f6,$be,0,0,0,0
	dc.b	1,3,$fe,$bc,0,0,0,0
	dc.b	$c9,$1d,'6',$b6,0,0,0,0
	dc.b	9,$b2,$f6,'=',0,0,0,0
	dc.b	'!',$f,'~',$b0,0,0,0,0
	dc.b	$89,' v',$ff,0,0,0,0
	dc.b	')',1,$f6,$be,0,0,0,0
	dc.b	1,'#',$fe,$bc,0,0,0,0
	dc.b	$eb,8,'4',$b7,0,0,0,0
	dc.b	3,0,$fc,$bf,0,0,0,0
	dc.b	3,$14,$fc,$ab,0,0,0,0
	dc.b	0,$d,$ff,$82,0,0,0,0
	dc.b	'o',$18,$90,0,0,0,0,0
	dc.b	1,'X',$e,$a5,0,0,0,0
	dc.b	$aa,$7f,0,0,$aa,$7f,$aa,$7f
	dc.b	$ff,$f0,0,$f,$ff,$ff,$ff,$ff
	dc.b	0,$92,$c0,$1d,$c0,0,$c0,0
	dc.b	'#',4,$d4,';',0,0,0,0
	dc.b	'E',$1d,$b8,'2',0,0,0,0
	dc.b	$1e,'"',$e0,$1d,0,0,0,0
	dc.b	'#',$9f,$dc,' ',0,0,0,0
	dc.b	$83,$80,'|?',0,0,0,0
	dc.b	$b3,$80,'L/',0,0,0,0
	dc.b	$8b,$aa,'t5',0,0,0,0
	dc.b	'#',$b1,$dc,$e,0,0,0,0
	dc.b	$a3,'b\',$1d,0,0,0,0
	dc.b	'#',$9f,$dc,' ',0,0,0,0
	dc.b	$83,$84,'|?',0,0,0,0
	dc.b	$b3,$ab,'L',$14,0,0,0,0
	dc.b	3,$80,$fc,'?',0,0,0,0
	dc.b	'C',$bd,$bc,2,0,0,0,0
	dc.b	0,'/',$ff,$80,0,0,0,0
	dc.b	$bf,4,'@',3,0,0,0,0
	dc.b	0,$13,$ff,$ec,0,0,0,0
	dc.b	0,$7f,0,0,0,$7f,0,$7f
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$c1,1,'>',6,$ff,0,$ff,0
	dc.b	$90,$b1,$27,$e,0,0,0,0
	dc.b	'>',$98,$c1,$27,0,0,0,0
	dc.b	'p',$94,$87,'+',0,0,0,0
	dc.b	$b5,$bf,'B',0,0,0,0,0
	dc.b	$fc,$83,3,'<',0,0,0,0
	dc.b	$be,$80,'A?',0,0,0,0
	dc.b	$d1,$86,6,'9',0,0,0,0
	dc.b	'8',$90,$c7,'/',0,0,0,0
	dc.b	$b8,$94,'Gk',0,0,0,0
	dc.b	$b5,$bf,'B',0,0,0,0,0
	dc.b	$fc,$83,3,'<',0,0,0,0
	dc.b	$be,$ac,'A',$13,0,0,0,0
	dc.b	$10,$81,$c7,'>',0,0,0,0
	dc.b	'x',$a1,$87,$1c,0,0,0,0
	dc.b	'0?O',$80,0,0,0,0
	dc.b	0,$c,0,$f7,0,0,0,0
	dc.b	'(',$11,$f7,$ee,0,0,0,0
	dc.b	$a2,1,1,0,$a3,1,$a3,1
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$fe,0,1,$f8,$ff,$f8,$ff,$f8
	dc.b	'o',$84,$90,';',0,0,0,0
	dc.b	$c7,$85,'(:',0,0,0,0
	dc.b	$9f,$ac,'`3',0,0,0,0
	dc.b	$83,$bf,'h',0,0,0,0,0
	dc.b	$91,$84,'n9',0,0,0,0
	dc.b	$b7,$a5,'H:',0,0,0,0
	dc.b	$b7,$88,'H7',0,0,0,0
	dc.b	$fb,$aa,0,$15,0,0,0,0
	dc.b	$d7,$ac,'(s',0,0,0,0
	dc.b	$83,$bf,'h',0,0,0,0,0
	dc.b	$9b,$84,'`9',0,0,0,0
	dc.b	$b7,$91,'H.',0,0,0,0
	dc.b	$d7,$88,'(',$27,0,0,0,0
	dc.b	$86,'9h',2,0,0,0,0
	dc.b	'/',$18,$d0,0,0,0,0,0
	dc.b	0,0,$1f,$ff,0,0,0,0
	dc.b	2,'^',$fd,'!',0,0,0,0
	dc.b	$a,0,1,0,$b,0,$b,0
	dc.b	5,$ff,0,0,5,$ff,5,$ff
	dc.b	$ff,$f8,0,7,$ff,$ff,$ff,$ff
	dc.b	$f6,$86,0,$19,0,0,0,0
	dc.b	$af,$8b,0,'0',0,0,0,0
	dc.b	$9f,$9c,0,'!',0,0,0,0
	dc.b	$7f,$98,0,'@',0,0,0,0
	dc.b	$f1,$13,$e,'(',0,0,0,0
	dc.b	'{',$86,0,'9',0,0,0,0
	dc.b	$ed,$9f,0,' ',0,0,0,0
	dc.b	$fb,7,0,'8',0,0,0,0
	dc.b	$b7,$9c,0,'a',0,0,0,0
	dc.b	$7f,$98,0,'@',0,0,0,0
	dc.b	$ff,$13,0,'(',0,0,0,0
	dc.b	'{',$9d,0,' ',0,0,0,0
	dc.b	$d6,$91,0,'(',0,0,0,0
	dc.b	$fd,$9d,0,0,0,0,0,0
	dc.b	'<',4,0,3,0,0,0,0
	dc.b	5,0,$ea,$ff,0,0,0,0
	dc.b	1,$bf,'~@',0,0,0,0
	dc.b	$a2,'y',1,0,$a3,'y',$a3,'y'
	dc.b	$90,$1f,0,0,$90,$1f,$90,$1f
	dc.b	$ff,$fc,0,2,$ff,$fe,$ff,$fe
	dc.b	'5',$1f,0,0,0,0,0,0
	dc.b	'Z',$8f,0,0,0,0,0,0
	dc.b	$fd,$18,0,0,0,0,0,0
	dc.b	$bf,0,'@',0,0,0,0,0
	dc.b	0,$e,7,0,0,0,0,0
	dc.b	$eb,$1f,0,0,0,0,0,0
	dc.b	$bf,$1e,'@',0,0,0,0,0
	dc.b	'=',$13,'@',0,0,0,0,0
	dc.b	':',$18,'@',0,0,0,0,0
	dc.b	$bf,0,'@',0,0,0,0,0
	dc.b	$f,$e,0,0,0,0,0,0
	dc.b	$eb,$13,0,0,0,0,0,0
	dc.b	$1f,$d,'@',0,0,0,0,0
	dc.b	$ff,$1e,0,0,0,0,0,0
	dc.b	$81,$18,'B',$f7,0,0,0,0
	dc.b	0,4,$fb,'{',0,0,0,0
	dc.b	8,'x',$97,$83,0,0,0,0
	dc.b	$aa,'6',1,0,$ab,'6',$ab,'6'
	dc.b	$f9,'@',0,0,$f9,'@',$f9,'@'
	dc.b	$7f,$fc,0,2,$7f,$fe,$7f,$fe
	dc.b	0,0,$80,0,0,0,0,0
	dcb.w	8
	dc.b	'<',0,0,0,0,0,0,0
	dc.b	0,0,1,$c0,0,0,0,0
	dcb.w	16
	dc.b	'<',0,0,0,0,0,0,0
	dc.b	0,0,0,$c0,0,0,0,0
	dcb.w	12
	dc.b	0,$90,$1f,'o',0,0,0,0
	dc.b	$b,$80,$f4,$7f,0,0,0,0
	dc.b	$da,'?$',0,0,0,0,0
	dc.b	2,$7f,1,0,3,$7f,3,$7f
	dc.b	$eb,$c2,0,0,$eb,$c2,$eb,$c2
	dc.b	1,$fc,0,2,1,$fe,1,$fe
	dc.b	0,4,'O;',0,0,0,0
	dc.b	$a,'p',$17,$8f,0,0,0,0
	dc.b	0,';',$1f,$d8,0,0,0,0
	dc.b	$d8,0,0,0,0,0,0,0
	dc.b	0,0,0,'o',0,0,0,0
	dc.b	0,'F',$cf,$bb,0,0,0,0
	dc.b	$12,' ',$1f,$de,0,0,0,0
	dc.b	4,$d0,$1b,$aa,0,0,0,0
	dc.b	0,'c',$1f,$98,0,0,0,0
	dc.b	$d8,0,0,0,0,0,0,0
	dc.b	0,'.',0,$af,0,0,0,'@'
	dc.b	4,'@',$cf,$bf,0,0,0,0
	dc.b	0,'$',$1d,$cb,0,0,0,0
	dc.b	9,0,$17,$9f,0,0,0,0
	dc.b	$1c,'H#',$95,0,0,0,0
	dc.b	$11,' ',$ee,$df,0,0,0,0
	dc.b	'A',$80,0,0,0,0,0,0
	dc.b	$aa,$7f,1,0,$ab,$7f,$ab,$7f
	dc.b	$ee,$ee,0,0,$ee,$ee,$ee,$ee
	dc.b	'D',6,0,0,'D',6,'D',6
	dc.b	$80,7,$1b,$b8,0,0,0,0
	dc.b	$93,$1d,$c,$e2,0,0,0,0
	dc.b	$90,$b,'?',$f4,0,0,0,0
	dc.b	$e0,0,0,0,0,0,0,0
	dc.b	0,$12,0,$1d,0,0,0,0
	dc.b	2,$d0,$fc,'.',0,0,0,0
	dc.b	$a,$ee,$b5,'1',0,1,0,1
	dc.b	0,'Q',$bf,$ae,0,0,0,0
	dc.b	$88,$b,'7',$f4,0,0,0,0
	dc.b	$e0,0,0,0,0,0,0,0
	dc.b	0,$12,0,$1d,0,0,0,0
	dc.b	2,0,$fd,$ff,0,0,0,0
	dc.b	8,$11,$b5,$ee,0,0,0,0
	dc.b	$81,0,'>',$bf,0,0,0,0
	dc.b	'>',5,$81,$fa,0,0,0,0
	dc.b	$a1,$f8,'\',0,0,0,0,0
	dc.b	'7',7,0,3,0,0,0,0
	dc.b	2,$7f,1,'`',3,$1f,3,$7f
	dc.b	$ff,$fe,0,0,$ff,$fe,$ff,$fe
	dc.b	' @',0,0,' @ @'
	dc.b	'B',$16,$9d,$a8,0,0,0,0
	dc.b	8,$95,'4h',0,0,0,0
	dc.b	$84,'o',$b,$90,0,0,0,0
	dc.b	$e0,0,0,0,0,0,0,0
	dc.b	0,$e,0,$f,0,0,0,$10
	dc.b	$c4,$c7,'?8',0,0,0,0
	dc.b	$be,$f8,'1',6,0,2,0,2
	dc.b	0,7,$bf,$f8,$80,0,$80,0
	dc.b	$86,$ef,'9',$10,0,0,0,0
	dc.b	$e0,0,0,0,0,0,0,0
	dc.b	0,$c,0,$f,0,0,0,$10
	dc.b	$c2,$12,'=',$ed,0,0,0,0
	dc.b	$c,$e7,$b3,$18,0,0,0,0
	dc.b	0,0,'/',$bf,0,0,0,0
	dc.b	$89,$81,$16,'^',0,0,0,0
	dc.b	7,3,$90,0,0,0,0,0
	dc.b	's',$9e,0,$b,3,$80,3,$80
	dc.b	$aa,$7f,1,'`',$ab,$1f,$ab,$7f
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ea,$a4,0,2,$ea,$a6,$ea,$a6
	dc.b	$c0,$97,$1f,0,0,0,0,0
	dc.b	'-=',2,$c2,0,0,0,0
	dc.b	';',$b7,4,'H',0,0,0,0
	dc.b	$c0,0,0,0,0,0,0,0
	dc.b	0,7,0,7,0,0,0,8
	dc.b	$d4,$b8,'+G',0,0,0,0
	dc.b	$11,9,'.',$c6,0,4,0,4
	dc.b	$a4,$bc,'K',3,'@',0,'@',0
	dc.b	$90,$f7,'/',8,0,0,0,0
	dc.b	$c0,0,0,0,0,0,0,0
	dc.b	0,7,0,7,0,0,0,8
	dc.b	$d4,$85,'+z',0,0,0,0
	dc.b	$19,',',$a6,$c2,0,0,0,0
	dc.b	$9d,$1a,'"',$a5,0,0,0,0
	dc.b	'4',$aa,$82,$10,0,0,0,0
	dc.b	$e0,$be,0,0,0,0,0,0
	dc.b	$ff,$9f,0,' ',$ff,$80,$ff,$80
	dc.b	2,$7f,1,'~',3,3,3,'}'
	dc.b	$f0,$7f,0,0,$ff,$ff,$f0,$7f
	dc.b	$e0,4,0,2,$e0,6,$e0,6
	dc.b	'@6',$1f,$88,0,0,0,0
	dc.b	$9c,$cf,'# ',0,0,0,0
	dc.b	5,$cf,': ',0,0,0,0
	dc.b	$80,'$',0,'f',0,0,0,$18
	dc.b	0,3,0,3,0,0,0,4
	dc.b	$80,'W',$ff,'(',0,0,0,0
	dc.b	$94,$b5,'+H',0,8,0,8
	dc.b	$80,$df,'?  ',0,' ',0
	dc.b	$80,$8f,'?`',0,0,0,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	0,3,0,3,0,0,0,4
	dc.b	$80,$a6,$ff,'Y',0,0,0,0
	dc.b	$12,$8f,$ad,'`',0,0,0,0
	dc.b	$9e,$8a,'!5',0,0,0,0
	dc.b	$1f,$ac,$80,'@',0,0,0,0
	dc.b	$17,$7f,0,0,0,$7f,0,$7f
	dc.b	$ff,$bb,0,4,$ff,$80,$ff,$80
	dc.b	$aa,'f',1,'g',$ab,$1b,$ab,'e'
	dc.b	' ',$7f,$e0,'x',$e1,$8f,$e0,'w'
	dc.b	$ea,$a4,0,2,$ea,$a6,$ea,$a6
	dc.b	$84,$ad,$19,0,0,0,0,0
	dc.b	$95,$bf,'(',0,0,0,0,0
	dc.b	$bf,$bf,0,0,0,0,0,0
	dc.b	0,' ',0,$a9,0,0,0,'V'
	dc.b	0,1,0,1,0,0,0,2
	dc.b	$f7,$ff,$88,0,0,0,0,0
	dc.b	$a6,$e3,$19,$10,0,$10,0,$10
	dc.b	$82,$ff,'9',0,$10,0,$10,0
	dc.b	$ab,$ff,0,0,0,0,0,0
	dcb.w	4
	dc.b	0,1,0,1,0,0,0,2
	dc.b	'u',$ec,$88,$13,0,0,0,0
	dc.b	$12,$b6,$a9,0,0,0,0,0
	dc.b	$8a,2,'0',$11,0,0,0,0
	dc.b	9,$80,$80,0,0,0,0,0
	dc.b	$9f,$ff,0,0,$1f,$ff,$1f,$ff
	dc.b	$ff,$b3,0,$c,$ff,$80,$ff,$80
	dc.b	2,'g',1,'f',3,$1a,3,'d'
	dc.b	$a0,$18,'`xy',$ef,'xp'
	dc.b	$a0,4,0,2,$e0,6,$a0,6
	dc.b	$e,$17,0,0,0,0,0,0
	dc.b	7,$ff,0,0,0,0,0,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	0,$81,0,$81,0,0,0,'~'
	dc.b	0,1,0,1,0,0,0,2
	dc.b	$df,$f5,$e0,0,0,0,0,0
	dc.b	$f,$8f,0,'`',0,' ',0,' '
	dc.b	$17,$bf,8,'@',8,0,8,0
	dc.b	$1f,$ff,0,0,0,0,0,0
	dcb.w	4
	dc.b	0,1,0,1,0,0,0,2
	dc.b	$df,$bf,$e0,'@',0,0,0,0
	dc.b	$1f,$bd,0,'@',0,0,0,0
	dc.b	$17,$9c,0,0,0,0,0,0
	dc.b	0,'!',0,0,0,1,0,1
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$c1,$b9,0,4,$c1,$80,$c1,$80
	dc.b	$aa,'g',1,'f',$ab,$1a,$ab,'d'
	dc.b	$a0,$18,'`xy',$e9,'xp'
	dc.b	'(',$a4,$b8,2,$de,$a6,$b8,$a6
	dc.b	$80,0,$c0,0,0,0,0,0
	dcb.w	4
	dc.b	0,$1e,0,0,0,0,0,0
	dc.b	0,'(',0,'*',0,0,0,$d5
	dcb.w	3
	dc.b	0,1,$e0,0,$e0,0,0,0
	dcb.w	2
	dc.b	0,'@',0,'@',0,'@',0,0
	dc.b	4,0,4,0,4,0,0,$1e
	dcb.w	10
	dc.b	0,1,$e0,0,$e0,0,0,0
	dcb.w	9
	dc.b	2,8,'?>',0,0,0,0
	dc.b	$ff,$f0,0,0,$ff,$f0,$ff,$f0
	dc.b	$d,$bf,0,0,$d,$80,$d,$80
	dc.b	2,'g',1,'f',3,$1a,3,'d'
	dc.b	$a0,$18,'`xy',$e9,'xp'
	dc.b	'<',4,$ac,2,$ce,6,$a8,6
	dc.b	0,0,$fd,$1f,0,0,0,0
	dc.b	'F',9,$b3,$16,0,0,0,0
	dc.b	$a9,$c6,'V',0,0,0,0,0
	dc.b	0,$c1,0,$c1,0,0,0,'>'
	dcb.w	3
	dc.b	0,1,$83,7,$8f,$1f,0,0
	dc.b	0,0,$8b,$1a,$ff,$9f,0,$80
	dc.b	0,$80,$89,$18,$ff,$1f,2,0
	dc.b	2,0,$80,6,$df,0,0,0
	dcb.w	8
	dc.b	0,1,$80,'0',$8f,$f,0,0
	dc.b	0,0,'i',0,$9e,$1f,0,0
	dc.b	0,0,'N',4,$a3,$1b,0,0
	dc.b	0,0,'šd%',$9a,0,0
	dc.b	0,0,$fc,0,0,0,$fc,0
	dc.b	$fc,0,$dd,$bf,0,0,$dd,$80
	dc.b	$dd,$80,$aa,'g',1,'f',$ab,$1a
	dc.b	$ab,'d',$a0,$18,'`xy',$e9
	dc.b	'xp<',$f4,$ac,$f2,$ce,$16
	dc.b	$a8,$e6,1,'>',$fe,1,0,0
	dc.b	0,0,$91,9,'f',$b6,0,0
	dc.b	0,0,$1f,$b0,$e0,' ',0,0
	dcb.w	2
	dc.b	0,$9b,0,0,0,'d',0,0
	dcb.w	3
	dc.b	'!0>',$bf,0,0,0,0
	dc.b	0,0,$ff,$bf,1,0,1,0
	dc.b	0,' ',$ff,$bf,1,0,1,0
	dc.b	7,'p',$f8,$e0,0,0,0,0
	dcb.w	8
	dc.b	'1',$10,'>',$af,0,0,0,0
	dc.b	5,$87,$f8,'8',0,0,0,0
	dc.b	$f1,$10,4,$f,0,0,0,0
	dc.b	8,$e6,$f7,$98,0,0,0,0
	dc.b	$c0,$1f,0,0,$c0,$1f,$c0,$1f
	dc.b	$dd,$9e,0,0,$dd,$80,$dd,$80
	dc.b	2,'g',1,'f',3,$1a,3,'d'
	dc.b	$a0,$18,'`xy',$e9,'xp'
	dc.b	'=',$f4,$ad,$f2,$ce,$16,$a9,$e6
	dc.b	1,$1d,$fc,$a2,0,0,0,0
	dc.b	'_',$a8,0,$17,0,0,0,0
	dc.b	$9f,$f8,'`',4,0,0,0,0
	dc.b	0,'$',0,'f',0,0,0,$18
	dcb.w	4
	dc.b	's',$b4,'|?',0,0,0,0
	dc.b	1,$94,$fe,'?',2,0,2,0
	dc.b	3,'4',$fc,$bf,0,$80,0,$80
	dc.b	'3',$f8,$cc,4,0,0,0,0
	dcb.w	8
	dc.b	'c',$b8,'|',7,0,3,0,3
	dc.b	0,1,$ff,$fe,$ff,$fe,$ff,$fe
	dc.b	'k',$90,$84,$27,0,0,0,0
	dc.b	3,$ee,$fc,$10,0,0,0,0
	dc.b	$c3,$df,0,0,$c3,$df,$c3,$df
	dc.b	$bd,$90,0,0,$bd,$80,$bd,$80
	dc.b	$aa,'g',1,'f',$ab,$1a,$ab,'d'
	dc.b	$a0,$18,'`xy',$e9,'xp'
	dc.b	'=',$f4,$ad,$e2,$ce,'6',$a9,$d6
	dc.b	'I',$bf,$a6,0,0,0,0,0
	dc.b	'i',$27,$86,$18,0,0,0,0
	dc.b	$96,$b0,'AL',0,0,0,0
	dcb.w	8
	dc.b	'H',$80,'w?',0,0,$80,0
	dc.b	'8',$80,$c7,'?',4,0,4,0
	dc.b	'8',$80,$c7,$7f,0,'@',0,'@'
	dc.b	'0p',$c7,$c,0,0,0,0
	dcb.w	8
	dc.b	'H',$a1,'w',$1e,0,3,$80,3
	dc.b	$ff,$ff,0,0,$ff,$fe,$ff,$fe
	dc.b	$f9,'3',6,$c,0,0,0,0
	dc.b	$ab,'LT',$b0,0,0,0,0
	dc.b	$cf,$df,0,0,$cf,$df,$cf,$df
	dc.b	$bd,$8a,0,'+',$bd,$80,$bd,$80
	dc.b	2,1,1,0,3,0,3,0
	dc.b	$a0,$18,'`xy',$e9,'xp'
	dc.b	'=',$f4,$ad,$e2,$ce,'6',$a9,$d6
	dc.b	'L',$9f,$b1,' ',0,0,0,0
	dc.b	$fd,$97,0,'(',0,0,0,0
	dc.b	'w',$f0,8,'L',0,0,0,0
	dcb.w	8
	dc.b	'w',$80,'x?',0,0,$80,0
	dc.b	$80,0,'`',0,0,0,$1f,$bf
	dc.b	0,0,0,$f,0,0,$ff,$f0
	dc.b	$b5,$f0,'H',$c,0,0,0,0
	dcb.w	8
	dc.b	'w',$bd,'x',2,0,3,$80,3
	dc.b	'm',$b7,0,0,'m',$b6,'m',$b6
	dc.b	'3',1,'H',$12,0,0,0,0
	dc.b	$f,'n',$d0,$90,0,0,0,0
	dc.b	$cf,$df,0,0,$cf,$df,$cf,$df
	dc.b	'y',$b6,0,'=y',$80,'y',$80
	dc.b	$aa,'~',1,0,$ab,'~',$ab,'~'
	dc.b	0,$18,0,$18,0,9,0,$10
	dc.b	'=',$f4,$ad,$c2,$ce,'v',$a9,$b6
	dc.b	$7f,$83,$80,'8',0,0,0,0
	dc.b	$bb,$97,0,'(',0,0,0,0
	dc.b	$df,$f0,0,$c,0,0,0,0
	dcb.w	8
	dc.b	$cf,$86,$f0,'9',0,0,0,0
	dc.b	$bf,$ff,$7f,$ff,'@',0,'@',0
	dc.b	$ff,$e2,$ff,$fd,0,$c,0,$c
	dc.b	$ff,$fc,0,0,0,0,0,0
	dcb.w	8
	dc.b	'O',$bd,'p',2,0,3,$80,3
	dc.b	$ff,$fe,0,1,$ff,$fe,$ff,$fe
	dc.b	$e5,$96,0,0,0,0,0,0
	dc.b	$7f,'v',0,0,0,0,0,0
	dc.b	$cf,$df,0,0,$cf,$df,$cf,$df
	dc.b	'q',$be,0,5,'q',$80,'q',$80
	dc.b	2,'@',1,0,3,'@',3,'@'
	dc.b	$ff,$e0,0,0,$ff,$e0,$ff,$e0
	dc.b	1,$f4,1,$c2,0,'v',1,$b6
	dc.b	$df,$97,' ',0,0,0,0,0
	dc.b	$ff,$1f,0,0,0,0,0,0
	dc.b	$f7,$10,0,',',0,0,0,0
	dcb.w	7
	dc.b	0,' ',$cf,$1f,$e0,0,0,0
	dc.b	0,0,$a0,0,'_',$ff,0,0
	dc.b	0,0,0,7,$ff,$e0,0,0
	dc.b	0,0,$b7,$10,'@,',0,0
	dcb.w	9
	dc.b	$8f,$1f,$e0,0,0,0,0,0
	dc.b	$bd,$1f,'@',0,0,0,0,0
	dc.b	$f7,'?',0,0,0,0,0,0
	dc.b	'p',0,0,0,0,0,0,0
	dc.b	$cf,$de,0,0,$cf,$de,$cf,$de
	dc.b	$f5,$9b,0,'$',$f5,$80,$f5,$80
	dc.b	$aa,1,1,0,$ab,1,$ab,1
	dc.b	0,$1f,0,0,0,$1f,0,$1f
	dc.b	$fc,4,0,2,$fc,6,$fc,6
	dc.b	1,0,0,0,0,0,0,0
	dcb.w	4
	dc.b	0,'4',0,8,0,0,0,0
	dcb.w	8
	dc.b	$c0,0,$80,0,0,0,0,0
	dc.b	$f,$ff,$f,$ff,0,0,0,0
	dc.b	$ff,$f0,$ff,$f0,0,0,0,0
	dc.b	0,'4',0,8,0,0,0,0
	dcb.w	4
	dc.b	' ',0,0,0,0,0,0,0
	dc.b	$c0,0,$80,0,0,0,0,0
	dcb.w	8
	dc.b	0,8,7,$f0,0,0,0,0
	dc.b	$cf,$de,0,0,$cf,$de,$cf,$de
	dc.b	$e5,$b3,0,$c,$e5,$80,$e5,$80
	dc.b	2,'6',1,0,3,'6',3,'6'
	dcb.w	4
	dc.b	2,4,1,$f2,3,$f6,3,$f6
	dc.b	8,$f,$8a,'0',0,0,0,0
	dc.b	$10,'5',$f,$cb,0,0,0,0
	dc.b	$a,$8c,$1f,$c0,0,0,0,0
	dcb.w	8
	dc.b	$8f,$83,$bf,$ff,0,0,0,0
	dc.b	$11,'[',$10,0,0,0,$e,$a4
	dc.b	'u',$83,0,7,0,0,$8a,'p'
	dc.b	$1b,$8c,$1f,$c0,0,0,0,0
	dcb.w	5
	dc.b	' ',0,0,0,0,0,$8e,$90
	dc.b	$bf,$ff,0,0,0,0,$10,$80
	dc.b	$1f,$ff,0,0,0,0,0,0
	dc.b	$1f,$8f,0,0,0,0,4,'r'
	dc.b	$1b,$8e,0,0,0,0,$cf,$fd
	dc.b	0,0,$cf,$fd,$cf,$fd,$ed,$b7
	dc.b	0,8,$ed,$80,$ed,$80,$aa,'o'
	dc.b	1,0,$ab,'o',$ab,'ov',$f8
	dc.b	0,0
	moveq	#-8,d3
	moveq	#-8,d3
	ori.b	#2,d4
	ori.b	#6,d6
	sub.b	d0,(a7)
	jsr	0(a0)
	dc.b	0,0,'$',$d3,$9b,',',0,0
	dc.b	0,0,$87,$e0,'<p',0,0
	dcb.w	4
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	0,0,'4!',$7f,$fe,0,0
	dc.b	0,0,'0',$d3,$b0,0,0,0
	dc.b	$f,',u',$81,0,6,0,0
	dc.b	$8a,'p',$10,'0',$bf,$c0,0,0
	dcb.w	4
	dc.b	$80,0,' ',0,' ',0,0,0
	dc.b	0,0,'4',4,$7f,$ff,0,0
	dc.b	0,0,4,$19,$bf,$e6,0,0
	dc.b	0,0,9,0,$b6,$bf,0,0
	dc.b	0,0,$18,'2',$a7,$cc,0,0
	dc.b	0,0,$cf,$fd,0,0,$cf,$fd
	dc.b	$cf,$fd,$cd,$ba,0,5,$cd,$80
	dc.b	$cd,$80,2,'}',1,0,3,'}'
	dc.b	3,'}',$de,'[',0,0,$de,'['
	dc.b	$de,'[',$a8,4,0,2,$a8,6
	dc.b	$a8,6,$cf,$81,$10,'<',0,0
	dc.b	0,0,$b5,$de,$1a,' ',0,0
	dc.b	0,0,$98,0,'7',$f0,0,0
	dcb.w	9
	dc.b	'D',3,$7f,$fc,0,0,$80,0
	dc.b	$b0,0,'0',0,0,0,$f,$ff
	dc.b	0,3,0,4,0,0,$ff,$f0
	dc.b	$b0,'0?',$c0,0,0,0,0
	dcb.w	4
	dc.b	$88,0,'P',0,0,0,' ',0
	dc.b	'D',0,$7f,$ff,0,0,$80,0
	dc.b	0,1,$bf,$fc,0,0,0,0
	dc.b	$a0,$a0,$15,$1f,0,0,0,0
	dc.b	'/',$d4,$80,'(',0,0,0,0
	dc.b	$cf,$fb,0,0,$cf,$fb,$cf,$fb
	dc.b	$dd,$bf,0,0,$dd,$80,$dd,$80
	dc.b	$aa,$7f,1,0,$ab,$7f,$ab,$7f
	dc.b	$ff,$eb,0,0,$ff,$eb,$ff,$eb
	dc.b	$aa,4,0,2,$aa,6,$aa,6
	dc.b	'A',$9b,$9e,4,0,0,0,0
	dc.b	$ae,$ea,$11,5,0,0,0,0
	dc.b	$9c,'H#',$b4,0,0,0,0
	dcb.w	8
	dc.b	'p8O',$c7,0,0,$80,0
	dc.b	$80,0,'0',0,0,0,$f,$fc
	dc.b	0,0,0,7,0,0,'?',$f0
	dc.b	$80,'x?',$84,0,0,0,0
	dcb.w	4
	dc.b	' ',0,' ',0,0,0,0,0
	dc.b	$f0,'B',$cf,$bd,0,0,0,0
	dc.b	6,$a2,$b9,'E',0,0,0,0
	dc.b	$a5,$80,$a,'?',0,0,0,0
	dc.b	7,$dc,$98,' ',0,0,0,0
	dc.b	$cf,$f7,0,0,$cf,$f7,$cf,$f7
	dc.b	$9d,$bf,0,0,$9d,$80,$9d,$80
	dc.b	2,$7f,1,0,3,$7f,3,$7f
	dc.b	3,$fe,0,0,$ff,$fe,3,$fe
	dc.b	$e0,4,$1c,2,$e0,6,$e2,6
	dc.b	$d0,'=',$f,$80,0,0,0,0
	dc.b	'6',$ff,')',0,0,0,0,0
	dc.b	$b0,$ac,'/P',0,0,0,0
	dcb.w	8
	dc.b	$80,$97,$ff,'h',0,0,0,0
	dc.b	$a0,3,'0',3,0,3,$f,$f3
	dc.b	$c3,7,$c0,0,$c0,0,$cc,$f0
	dc.b	$80,'<?@',0,0,0,0
	dcb.w	5
	dc.b	' ',0,0,0,0,0,$80,$a0
	dc.b	$ff,'_',0,0,0,0,$82,$bd
	dc.b	'=@',0,0,0,0,0,1
	dc.b	'/6',0,0,0,0,$f,$ce
	dc.b	$80,'0',0,0,0,0,$cf,$f7
	dc.b	0,0,$cf,$f7,$cf,$f7,$bd,$80
	dc.b	0,0,$bd,$80,$bd,$80,$aa,'~'
	dc.b	1,1,$ab,$7f,$ab,$7f,$a,$ff
	dc.b	$ff,$80,$ff,$ff,$ff,$ff,$c0,$a4
	dc.b	'"',2,$c0,$a6,$c1,$a6,$c6,$af
	dc.b	$19,0,0,0,0,0,$92,$ff
	dc.b	')',0,0,0,0,0,$bf,$fc
	dcb.w	11
	dc.b	$f4,$ff,$c9,0,0,0,0,0
	dc.b	$80,$f,'0',$f,0,$f,$f,$ef
	dc.b	$f0,7,$f0,0,$f0,0,$f7,$f0
	dc.b	$86,$fc,'9',0,0,0,0,0
	dcb.w	4
	dc.b	' ',0,0,0,0,0,0,0
	dc.b	$f4,$ed,$c9,$12,0,0,0,0
	dc.b	5,$f6,$b8,0,0,0,0,0
	dc.b	$a4,$ac,$19,$13,0,0,0,0
	dc.b	'?',$f8,$80,0,0,0,0,0
	dc.b	$cf,$ef,0,0,$cf,$ef,$cf,$ef
	dc.b	'=',$99,0,$1f,'=',$80,'=',$80
	dc.b	2,'~',1,1,3,$7f,3,$7f
	dc.b	$a,$ff,$ff,$c0,$ff,$ff,$ff,$bf
	dc.b	$80,4,'A',$82,$80,6,$80,6
	dc.b	$8a,$bf,1,0,0,0,0,0
	dc.b	$1e,$7f,0,0,0,0,0,0
	dc.b	$f,$fc,0,0,0,0,0,0
	dcb.w	8
	dc.b	$fb,$bf,$80,'@',0,0,0,0
	dc.b	$10,$1f,0,$1f,0,$1f,$f,$df
	dc.b	$f8,7,$f8,0,$f8,0,$fb,$f0
	dc.b	$17,$fc,0,0,0,0,0,0
	dcb.w	8
	dc.b	$fb,$ff,$80,0,0,0,0,0
	dc.b	$1d,$bb,0,'@',0,0,0,0
	dc.b	$17,$ad,0,$10,0,0,0,0
	dc.b	$16,$16,0,0,0,0,0,0
	dc.b	$cf,$ef,0,0,$cf,$ef,$cf,$ef
	dc.b	'}',$a7,0,$18,'}',$80,'}',$80
	dc.b	$aa,'~',1,1,$ab,$7f,$ab,$7f
	dc.b	$a,$f8,$ff,$c0,$ff,$ff,$ff,$b8
	dc.b	0,'$P',$82,$80,'&',0,'&'
	dc.b	1,$80,0,0,0,0,0,0
	dcb.w	4
	dc.b	0,8,0,0,0,0,0,0
	dcb.w	3
	dc.b	0,$80,0,0,0,0,0,0
	dc.b	0,0,$e0,0,$80,0,0,0
	dc.b	0,0,0,$1f,0,$1f,0,$1f
	dc.b	$f,$df,$f8,0,$f8,0,$f8,0
	dc.b	$fb,$f0,0,8,0,0,0,0
	dcb.w	9
	dc.b	$c0,0,$80,0,0,0,0,0
	dcb.w	4
	dc.b	0,'0',0,0,0,0,0,0
	dc.b	0,4,0,'`',0,0,0,0
	dc.b	$cd,$de,0,0,$cd,$de,$cd,$de
	dc.b	'}',$b8,0,7,'}',$80,'}',$80
	dc.b	2,'@',1,'?',3,'?',3,'?'
	dc.b	$a,$f8,$ff,$e0,$ff,$bf,$ff,$d8
	dc.b	0,4,'H',$82,$80,6,0,6
	dc.b	$86,$12,$f8,$d,0,0,0,0
	dc.b	$bc,2,'C',$1f,0,0,0,0
	dc.b	$8b,' ',$ff,'0',0,0,0,0
	dcb.w	8
	dc.b	$8b,1,$1f,$1f,0,0,0,0
	dc.b	$80,$1f,$f0,$1f,0,$1f,$f,$df
	dc.b	$f8,7,$f8,7,$f8,0,$fb,$f0
	dc.b	$b,'0',$ff,' ',0,0,0,0
	dcb.w	8
	dc.b	$b9,$10,'?',$1f,0,0,0,0
	dc.b	'!',$18,$df,7,0,0,0,0
	dc.b	'$',1,$db,$e,0,0,0,0
	dc.b	'P',0,$af,'x',0,0,0,0
	dc.b	$cd,$de,0,0,$cd,$de,$cd,$de
	dc.b	$fd,$bf,0,0,$fd,$80,$fd,$80
	dc.b	$aa,$7f,1,0,$ab,0,$ab,$f
	dc.b	$ca,$f0,'?',$e0,'?',$bf,$ff,$d0
	dc.b	$c0,$a4,'!',2,$c0,$a6,$c0,$a6
	dc.b	$11,$1b,$ee,'4',0,0,0,0
	dc.b	$d3,$c,',',$b7,0,0,0,0
	dc.b	'i@',$b6,$fc,0,0,0,0
	dcb.w	8
	dc.b	'Q$~',$bf,0,0,$80,0
	dc.b	' ',1,$f0,1,0,1,$f,$c1
	dc.b	$c0,4,$c0,7,$c0,0,$c3,$f0
	dc.b	'!',$1c,$fe,$e0,0,0,0,0
	dcb.w	8
	dc.b	'q',$10,'~',$af,0,0,$80,0
	dc.b	'C',$8e,$bc,'1',0,0,0,0
	dc.b	$81,$84,'v',$1b,0,0,0,0
	dc.b	$80,'P',$ff,$ae,0,0,0,0
	dc.b	$cd,$bc,0,0,$cd,$bc,$cd,$bc
	dc.b	$fd,$a3,0,$1c,$fd,$80,$fd,$80
	dc.b	2,$7f,1,$7f,3,0,3,$7f
	dc.b	$a,$f0,$ff,$f0,$ff,$9f,$ff,$e0
	dc.b	$e0,4,$1e,2,$e0,6,$e0,6
	dc.b	3,$a,$fc,$b5,0,0,0,0
	dc.b	$d8,$8a,'$5',0,0,0,0
	dc.b	'k',$c0,$94,'|',0,0,0,0
	dcb.w	8
	dc.b	'c”|?',0,0,$80,0
	dc.b	0,$1e,$f0,0,0,0,$f,$9e
	dc.b	$10,4,$10,7,'8',0,$10,$f0
	dc.b	0,$dc,$fc,'`',0,0,0,0
	dcb.w	8
	dc.b	's',$b8,'|',7,0,0,$80,0
	dc.b	3,$88,$fc,'7',0,0,0,0
	dc.b	$c5,$bd,'8',2,0,0,0,0
	dc.b	'`b',$9f,$9c,0,0,0,0
	dc.b	$cd,$bd,0,0,$cd,$bd,$cd,$bd
	dc.b	$fd,$bf,0,0,$fd,$80,$fd,$80
	dc.b	$aa,'@',1,0,$ab,'?',$ab,0
	dc.b	$a,$f1,'?',$f0,$ff,$9e,'?',$e0
	dc.b	$e0,'$',0,2,$1f,$e6,0,'&'
	dc.b	$11,$85,$e6,':',0,0,0,0
	dc.b	$1f,'(',$c0,$17,0,0,0,0
	dc.b	':',$80,$c5,'|',0,0,0,0
	dcb.w	8
	dc.b	'H',$80,'w?',0,0,$80,0
	dc.b	'0n',$c0,'`',0,'`',$f,$e
	dc.b	' ',0,' ',7,'7',0,$a0,'p'
	dc.b	'8',$98,$c7,'d',0,0,0,0
	dcb.w	8
	dc.b	$c8,$a3,$f7,$1c,0,0,0,0
	dc.b	$b1,'šF%',0,0,0,0
	dc.b	'"',$b9,$c5,4,0,0,0,0
	dc.b	$e1,$c2,$1e,'<',0,0,0,0
	dc.b	$cd,'y',0,0,$cd,'y',$cd,'y'
	dc.b	$fd,$bf,0,0,$fd,$80,$fd,$80
	dc.b	2,'@',1,0,3,'?',3,0
	dc.b	$a,$f9,'?',$f8,$ff,'Ž?',$f0
	dc.b	$e0,4,0,2,$1f,$c6,0,6
	dc.b	'F',$a0,$b1,$1f,0,0,0,0
	dc.b	0,'M',$ff,$ff,0,0,0,0
	dc.b	$ff,$c0,$f8,'|',0,0,0,0
	dcb.w	8
	dc.b	$b6,$a0,$f8,'?',0,0,0,0
	dc.b	$90,$f0,'`',$f0,0,$f0,$e,1
	dc.b	0,0,0,7,$f,$80,$c0,'0'
	dc.b	$95,$c0,'h|',0,0,0,0
	dcb.w	7
	dc.b	0,$80,$b6,$bd,$f8,2,0,0
	dc.b	0,0,7,$be,$e8,'!',0,0
	dc.b	0,0,'_- ',$12,0,0
	dc.b	0,0,'3&',$cc,$d8,0,0
	dc.b	0,0,$cc,$f3,0,0,$cc,$f3
	dc.b	$cc,$f3,$fd,$9f,0,0,$fd,$80
	dc.b	$fd,$80,$aa,$7f,1,$7f,$ab,0
	dc.b	$ab,$7f,$8a,$fb,$ff,$f8,$7f,$8e
	dc.b	$ff,$f2,$ff,$e4,$f,$c2,$f,$e6
	dc.b	0,'&',$7f,$88,$80,'0',0,0
	dcb.w	5
	dc.b	$f,$94,8,'h',0,0,0,0
	dcb.w	7
	dc.b	1,0,$ef,$86,$f0,'9',0,0
	dc.b	0,0,$f0,$fc,0,$fc,0,$fc
	dc.b	$e,0,0,6,0,1,$1f,$80
	dc.b	0,'0',$df,$94,0,'h',0,0
	dcb.w	9
	dc.b	$ef,$9f,$f0,0,0,0,0,0
	dc.b	$f7,$ba,0,1,0,0,0,0
	dc.b	$ff,$bf,0,0,0,0,0,0
	dc.b	$fe,'l',1,$90,0,0,0,0
	dc.b	$cc,$f7,0,0,$cc,$f7,$cc,$f7
	dc.b	$fd,$97,0,0,$fd,$80,$fd,$80
	dc.b	2,0,1,0,3,0,3,0
	dcb.w	4
	dc.b	0,4,0,2,0,6,0,6
	dc.b	$df,'š ',1,0,0,0,0
	dc.b	0,0,$ff,$1f,0,0,0,0
	dc.b	$f,'4',$c8,8,0,0,0,0
	dcb.w	8
	dc.b	'O',$1f,0,0,0,0,0,0
	dc.b	$b0,$fd,'@',$fc,0,$fd,$e,1
	dc.b	$c0,7,0,0,$df,$80,$c0,'0'
	dc.b	$bf,'4@',8,0,0,0,0
	dcb.w	8
	dc.b	$7f,$1f,$10,0,0,0,0,0
	dc.b	$bf,$d,'@',0,0,0,0,0
	dc.b	$f3,'7',0,0,0,0,0,0
	dc.b	$ff,'Z',0,0,0,0,0,0
	dc.b	$cd,$e7,0,0,$cd,$e7,$cd,$e7
	dc.b	$fd,$88,0,8,$fd,$80,$fd,$80
	dc.b	$aa,$7f,1,0,$ab,$7f,$ab,$7f
	dc.b	$ff,$f0,0,$f,$ff,$ff,$ff,$ff
	dc.b	$10,4,$ef,$f2,$ff,$f6,$ff,$f6
	dc.b	3,2,0,0,0,1,0,1
	dcb.w	2
	dc.b	$c9,1,$c9,1,0,8,8,0
	dc.b	$e0,0,$e0,0,0,0,0,0
	dcb.w	6
	dc.b	'@',0,'`',0,0,0,$80,0
	dc.b	0,$fd,0,$fc,0,$fd,$e,1
	dc.b	$c0,0,0,0,$df,$80,$c0,'0'
	dc.b	0,8,0,0,0,0,0,0
	dcb.w	3
	dc.b	0,2,0,0,0,0,0,0
	dc.b	0,0,'@',0,'@',0,0,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	0,0,0,8,0,0,0,0
	dc.b	0,0,0,4,0,0,0,0
	dc.b	0,0,$cd,$ef,0,0,$cd,$ef
	dc.b	$cd,$ef,'}',$9d,0,'?}',$80
	dc.b	'}',$80,2,0,1,0,3,0
	dc.b	3,0,0,0,0,0,0,0
	dc.b	0,0,0,4,0,2,0,6
	dc.b	0,6,$80,$a,$8c,'0',0,1
	dc.b	0,0,'"',$f0,'"',$f0,$c9,1
	dc.b	$14,$e,2,$a8,$f,$f8,$e0,0
	dc.b	' ',0,0,0,0,0,0,0
	dc.b	0,2,0,0,0,0,0,0
	dc.b	0,0,'h',$a,$7f,$ff,0,0
	dc.b	$80,0,$10,$fd,$10,$fc,0,$fd
	dc.b	$e,1,$c0,1,0,7,$df,$80
	dc.b	$c0,'0',$1b,$a8,$1f,$f0,0,0
	dcb.w	9
	dc.b	'o',$16,$7f,$ff,0,0,$80,0
	dc.b	$10,'d',$1f,$9b,0,0,0,0
	dc.b	$10,$80,$f,7,0,0,0,0
	dc.b	0,$b0,$1f,'x',0,0,0,0
	dc.b	$cb,$cf,0,0,$cb,$cf,$cb,$cf
	dc.b	'}',$86,0,'=}',$80,'}',$80
	dc.b	$aa,'[',1,0,$ab,'[',$ab,'['
	dc.b	$bd,$fb,0,0,$bd,$fb,$bd,$fb
	dc.b	$aa,$84,0,2,$aa,$86,$aa,$86
	dc.b	$80,':_',$80,0,1,0,0
	dc.b	$16,'T4',$aa,$c9,1,0,0
	dc.b	3,'H',$c,$f4,$e0,0,0,0
	dcb.w	8
	dc.b	'T!',$7f,$fe,0,0,$80,0
	dc.b	'0~',$b0,'~',0,'~',$f,0
	dc.b	$80,1,0,6,$bf,0,$80,'p'
	dc.b	$14,'X',$bf,$e4,0,0,0,0
	dcb.w	8
	dc.b	'TA',$7f,$ff,0,0,$80,0
	dc.b	$88,2,$b7,$fc,0,0,0,0
	dc.b	0,$82,$bf,'=',0,0,0,0
	dc.b	$14,'"',$ab,$de,0,0,0,0
	dc.b	$cb,$df,0,0,$cb,$df,$cb,$df
	dc.b	'}',$a2,0,$1d,'}',$80,'}',$80
	dc.b	2,'~',1,0,3,'~',3,'~'
	dc.b	$ef,$de,0,0,$ef,$de,$ef,$de
	dc.b	$e0,4,0,2,$e0,6,$e0,6
	dc.b	$c1,3,$1e,$b9,0,1,0,1
	dc.b	$f9,'G',$f6,$ba,$f0,2,$f0,2
	dc.b	$e0,$c,$ef,$f0,$e0,0,$e0,0
	dcb.w	8
	dc.b	$e0,3,$df,$fc,0,0,0,0
	dc.b	$b0,$1e,'0',$1e,0,$1e,$f,$80
	dc.b	0,3,0,4,'<',0,0,$f0
	dc.b	$a0,$1c,'?',$e0,0,0,0,0
	dcb.w	8
	dc.b	$e4,5,$df,$ff,0,0,0,0
	dc.b	4,1,$bf,$fc,0,0,0,0
	dc.b	$89,'06',$8f,3,0,3,0
	dc.b	'>',$92,$81,'l',0,0,0,0
	dc.b	$c7,$9f,0,0,$c7,$9f,$c7,$9f
	dc.b	'}',$a7,0,$1c,'}',$80,'}',$80
	dc.b	$aa,'o',1,0,$ab,'o',$ab,'o'
	dc.b	$fe,$fb,0,0,$fe,$fb,$fe,$fb
	dc.b	$ea,$a4,0,2,$ea,$a6,$ea,$a6
	dc.b	$c0,';',$1f,$80,0,1,0,1
	dc.b	8,$f9,$f8,$fb,$f0,2,$f7,6
	dc.b	'(d',$e7,$98,$e0,0,$e0,0
	dcb.w	8
	dc.b	$d0,'8',$af,$c7,0,0,0,0
	dc.b	$83,0,'0',0,0,0,$c,$e1
	dc.b	0,'`',0,7,0,0,$c3,$90
	dc.b	$80,'|?',$80,0,0,0,0
	dcb.w	8
	dc.b	$d0,'@',$af,$bf,0,0,0,0
	dc.b	8,'y',$b7,$86,0,0,0,0
	dc.b	$90,$e,'.',$b1,2,0,2,0
	dc.b	'2',$96,$8d,'h',0,0,0,0
	dc.b	$c7,$bf,0,0,$c7,$bf,$c7,$bf
	dc.b	'}',$b5,0,$a,'}',$80,'}',$80
	dc.b	2,$7f,1,0,3,$7f,3,$7f
	dc.b	$f7,$ff,0,0,$f7,$ff,$f7,$ff
	dc.b	$e0,4,0,2,$e0,6,$e0,6
	dc.b	'B',$1b,$9d,' ',0,1,0,1
	dc.b	$fc,$b7,3,'H',$f0,2,$f0,2
	dc.b	$e8,$9c,7,'`',$e0,0,$e0,0
	dcb.w	8
	dc.b	$e0,$97,$9f,'h',0,0,0,0
	dc.b	$80,0,'0',0,0,0,$f,$ff
	dc.b	0,7,0,0,0,0,$ff,$f0
	dc.b	$a0,$9c,'?`',0,0,0,0
	dcb.w	8
	dc.b	$e0,$a0,$9f,'_',0,0,0,0
	dc.b	$82,$9e,$bd,'`',0,0,0,0
	dc.b	$90,$80,'.',$1f,2,0,2,0
	dc.b	$a9,6,$16,$f8,0,0,0,0
	dc.b	$cf,'?',0,0,$cf,'?',$cf,'?'
	dc.b	'}',$ac,0,$13,'}',$80,'}',$80
	dc.b	$aa,'^',1,0,$ab,'^',$ab,'^'
	dc.b	$ff,$df,0,0,$ff,$df,$ff,$df
	dc.b	$aa,$a4,0,2,$aa,$a6,$aa,$a6
	dc.b	$c7,$bb,$18,1,0,1,0,0
	dc.b	$bb,$ff,$80,$1f,$80,$1f,0,0
	dc.b	$ee,$f8,$e1,0,$e0,0,0,0
	dcb.w	8
	dc.b	'6',$ff,9,0,0,0,0,0
	dc.b	$80,0,'0',0,0,0,$f,$ff
	dc.b	0,7,0,0,0,0,$ff,$f0
	dc.b	$86,$f8,'9',0,0,0,0,0
	dcb.w	8
	dc.b	'v',$ec,9,$13,0,0,0,0
	dc.b	$e,$fe,$b1,0,0,0,0,0
	dc.b	$90,' ,',$13,4,0,4,0
	dc.b	'?',$9c,$80,'`',0,0,0,0
	dc.b	$cf,$7f,0,0,$cf,$7f,$cf,$7f
	dc.b	'}',$bc,0,3,'}',$80,'}',$80
	dc.b	2,$7f,1,0,3,$7f,3,$7f
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$e0,4,0,2,$e0,6,$e0,6
	dc.b	$cf,$bb,$10,1,0,0,0,1
	dc.b	$fe,'?',$fe,'?',0,0,$81,$df
	dc.b	$ef,$a8,$e0,0,' ',0,$c0,0
	dcb.w	8
	dc.b	'_',$bf,'@@',0,0,$80,0
	dc.b	$11,']',0,0,0,0,$e,$a2
	dc.b	$b5,7,0,0,0,0,'J',$f0
	dc.b	$1f,$a8,0,0,0,0,0,0
	dcb.w	8
	dc.b	'?',$bf,0,0,0,0,$80,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	$18,$97,4,0,4,0,4,0
	dc.b	'?',$fe,$80,0,0,0,0,0
	dc.b	$de,$7f,0,0,$de,$7f,$de,$7f
	dc.b	'}',$bf,0,0,'}',$80,'}',$80
	dc.b	$aa,$7f,1,0,$ab,$7f,$ab,$7f
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ea,$a4,0,2,$ea,$a6,$ea,$a6
	dc.b	$80,3,0,1,0,0,0,1
	dc.b	$80,$1f,$80,$1f,0,0,$80,$1f
	dc.b	$e8,$1c,$e0,$1c,0,0,$e0,0
	dcb.w	8
	dc.b	'`',0,'`',0,0,0,$80,0
	dc.b	0,$a4,0,0,0,0,$f,'['
	dc.b	'W',0,0,0,0,0,$a8,$f0
	dc.b	0,$1c,0,0,0,0,0,0
	dcb.w	8
	dc.b	'@',0,'@',0,0,0,$80,0
	dcb.w	5
	dc.b	4,0,4,0,4,0,$15,$a
	dcb.w	3
	dc.b	$de,$ff,0,0,$de,$ff,$de,$ff
	dc.b	'}',$80,0,0,'}',$80,'}',$80
	dc.b	2,'y',1,$e,3,'q',3,'q'
	dc.b	$fc,$1f,$83,$e0,'|',$1f,'|',$1f
	dc.b	0,4,$f0,2,0,6,0,6
	dc.b	0,2,$f,$18,0,1,0,1
	dc.b	0,$13,1,$1f,$fe,0,$fe,0
	dc.b	$a,'P',7,'|',$e0,0,$e0,0
	dcb.w	8
	dc.b	'h',$1f,$7f,$1f,0,0,$80,0
	dc.b	$80,0,$f0,0,0,0,$f,$ff
	dc.b	0,7,0,7,0,0,$ff,$f0
	dc.b	$8b,'X',$ff,'t',0,0,0,0
	dcb.w	8
	dc.b	'k',$18,$7f,$1f,0,0,$80,0
	dc.b	2,8,$ff,$1f,0,0,0,0
	dc.b	$80,0,'}',$1f,4,0,4,0
	dc.b	0,'(',$a,'@',0,0,0,0
	dc.b	$dc,$ff,0,0,$dc,$ff,$dc,$ff
	dc.b	'}',$80,0,0,'}',$80,'}',$80
	dc.b	$aa,'{',1,5,$ab,'z',$ab,'z'
	dc.b	$fe,$ff,1,'@',$fe,$bf,$fe,$bf
	dc.b	$ea,$a4,' ',2,$8a,$a6,$8a,$a6
	dc.b	3,$12,$fc,$b8,0,1,0,0
	dc.b	1,$8f,1,$8f,$fe,0,0,'p'
	dc.b	9,'P',6,$fc,$e0,0,' ',0
	dcb.w	3
	dc.b	'@',0,0,0,0,0,0,0
	dc.b	0,0,$91,$14,$fe,$bf,0,0
	dc.b	0,0,$1f,$ff,$ff,$ff,' ',0
	dc.b	' ',0,$ff,$e0,$ff,$ef,0,$c
	dc.b	0,$1c,'!X',$fe,$e4,0,0
	dcb.w	4
	dc.b	'@',0,0,0,0,0,0,0
	dc.b	0,0,$11,$10,'~',$af,0,0
	dc.b	$80,0,$83,$18,$fc,$b7,0,0
	dc.b	0,0,$81,$10,'|',$8f,4,0
	dc.b	4,0,2,$12,$fd,$de,0,0
	dc.b	0,0,$dd,$ff,0,0,$dd,$ff
	dc.b	$dd,$ff,'}',$9b,0,$1f,'}',$80
	dc.b	'}',$80,2,'{',1,5,3,'z'
	dc.b	3,'z',$fe,$ff,1,'@',$fe,$bf
	dc.b	$fe,$bf,'p',4,$90,2,'`',6
	dc.b	'`',6,2,$82,$fc,'8',0,1
	dc.b	0,0,1,$a0,0,'?',$fe,0
	dc.b	0,0,$b,$84,4,'x',$e0,0
	dcb.w	9
	dc.b	$b3,$84,$fc,'?',0,0,0,0
	dc.b	$f,$ff,$f0,0,0,0,0,0
	dc.b	$ff,$f4,0,7,0,0,0,0
	dc.b	3,$84,$fc,'x',0,0,0,0
	dcb.w	8
	dc.b	$b3,$b8,$fc,7,0,0,0,0
	dc.b	3,$82,$fc,'=',0,0,0,0
	dc.b	$89,$98,'t',7,$c,0,$c,0
	dc.b	1,2,$ff,$fc,0,0,0,0
	dc.b	$c0,0,0,0,$c0,0,$c0,0
	dc.b	1,$91,0,'.',1,$80,1,$80
	dc.b	$aa,'{',1,5,$ab,'z',$ab,'z'
	dc.b	$fd,$7f,2,' ',$fd,'_',$fd,$df
	dc.b	'Z',$a4,$90,2,'J',$a6,'j',$a6
	dc.b	8,$83,$f7,'9',0,1,0,1
	dc.b	$fd,$97,$c2,'/',$c0,7,$c0,7
	dc.b	$ea,$c4,$e5,'x',$e0,0,$e0,0
	dcb.w	8
	dc.b	8,$80,$f7,'?',0,0,0,0
	dc.b	'0',0,$c0,0,0,0,0,0
	dc.b	0,0,0,7,0,0,0,0
	dc.b	'8',$c4,$c7,'x',0,0,0,0
	dcb.w	8
	dc.b	'H',$a3,$f7,$1c,0,0,0,0
	dc.b	$b8,$b4,'G',$b,0,0,0,0
	dc.b	'0',$8b,$c9,4,8,0,8,0
	dc.b	8,'J',$f7,$b4,0,0,0,0
	dc.b	$df,$ff,0,0,$df,$ff,$df,$ff
	dc.b	$fd,$bb,0,4,$fd,$80,$fd,$80
	dc.b	2,'v',1,9,3,'v',3,'v'
	dc.b	'}~',2,'!}^',$fd,$de
	dc.b	$d8,4,8,2,$d0,6,$f0,6
	dc.b	$1f,$93,$e0,'(',0,1,0,1
	dc.b	'?',$e0,$ff,$e7,$c0,7,$c0,$1f
	dc.b	'/',$94,$e0,'h',$e0,0,$e0,0
	dcb.w	8
	dc.b	$d7,$a0,$b8,'?',0,0,0,0
	dc.b	$97,$a0,'h?',0,0,0,0
	dc.b	$97,$a0,'h?',0,0,0,0
	dc.b	$97,$94,'hh',0,0,0,0
	dcb.w	8
	dc.b	$d7,$bd,$b8,2,0,0,0,0
	dc.b	$17,$b4,$e8,'+',0,0,0,0
	dc.b	$d3,$8d,'(',2,8,0,8,0
	dc.b	$80,$e,$7f,$f0,0,0,0,0
	dc.b	$df,$ff,0,0,$df,$ff,$df,$ff
	dc.b	$fd,$a7,0,$18,$fd,$80,$fd,$80
	dc.b	$aa,'v',1,9,$ab,'v',$ab,'v'
	dc.b	'{',$ff,4,$10,'{',$ee,$fb,$ee
	dc.b	$fa,$a4,8,2,$f2,$a6,$f2,$a6
	dc.b	'O',$83,$b0,'8',0,1,0,1
	dc.b	$ff,$87,0,'8',$c0,7,$c0,7
	dc.b	$ef,$b8,0,0,$e0,0,$e0,0
	dcb.w	8
	dc.b	$8f,$86,'p9',0,0,0,0
	dc.b	$ff,$86,0,'9',0,0,0,0
	dc.b	$ff,$86,0,'9',0,0,0,0
	dc.b	$ff,$b8,0,0,0,0,0,0
	dcb.w	8
	dc.b	$cf,$bf,'p',0,0,0,0,0
	dc.b	$ff,$8e,0,'1',0,0,0,0
	dc.b	$f2,$8a,8,0,8,0,8,0
	dc.b	'(l',$d7,$90,0,0,0,0
	dc.b	$df,$ff,0,0,$df,$ff,$df,$ff
	dc.b	$fd,$bb,0,4,$fd,$80,$fd,$80
	dc.b	2,'`',1,$10,3,'o',3,'`'
	dc.b	$7f,$ff,$c0,$11,';',$ed,';',$ed
	dc.b	$fc,4,$fc,2,$f8,6,$f8,6
	dc.b	$7f,$8b,$80,0,0,0,0,0
	dc.b	$bf,$1f,'@',0,0,0,0,0
	dc.b	$af,0,'@',3,0,0,0,0
	dc.b	'^',$80,$df,$80,0,0,0,$7f
	dc.b	' ',2,' ',3,0,0,$9f,$fc
	dc.b	$f,$1f,'p',0,0,0,0,0
	dc.b	$bf,$1f,'@',0,0,0,0,0
	dc.b	$bf,$1f,'@',0,0,0,0,0
	dc.b	$bf,0,'@',3,0,0,0,0
	dc.b	'_',$80,$df,$80,0,0,0,$7f
	dc.b	0,3,' ',3,0,0,$9f,$fc
	dc.b	$f,$1f,'p',0,0,0,0,0
	dc.b	$bf,$1f,'@',0,0,0,0,0
	dc.b	$b3,'/H',0,8,0,8,0
	dc.b	$ee,'j',$11,$90,0,0,0,0
	dc.b	$df,$ff,0,0,$df,$ff,$df,$ff
	dc.b	$fd,$bd,0,2,$fd,$80,$fd,$80
	dc.b	$aa,'p',1,0,$ab,'o',$ab,'`'
	dc.b	$7f,$ff,'G',$f9,$b0,5,'7',$f5
	dc.b	$fc,4,$fc,2,$f8,6,$f8,6
	dc.b	$d0,2,' ',0,0,0,0,0
	dcb.w	4
	dc.b	8,0,0,7,0,0,0,0
	dc.b	$fe,$ff,$bf,$ff,0,0,0,0
	dc.b	$bf,$ff,$bf,$ff,0,0,0,0
	dc.b	$80,0,$80,0,0,0,0,0
	dcb.w	9
	dc.b	0,7,0,0,0,0,$ff,$f6
	dc.b	$bf,$ff,0,0,0,0,$bd,'c'
	dc.b	$bf,$ff,0,0,0,0,$80,0
	dc.b	$84,0,0,0,0,0,0,0
	dcb.w	4
	dc.b	8,0,8,0,8,0,$b5,$16
	dc.b	'@ ',0,0,0,0,$c0,0
	dc.b	0,0,$c0,0,$c0,0,1,$bf
	dc.b	0,0,1,$80,1,$80,2,'`'
	dc.b	1,0,3,'_',3,'@?',$f9
	dc.b	$27,$f8,$d0,0,$17,$f0,$80,4
	dc.b	$7f,$e2,7,$e6,7,$e6,0,2
	dc.b	$f,'y',0,'y',0,'y',0,0
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,8,7
	dc.b	$e7,$ff,$e7,$ff,$e7,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$f5,$96
	dc.b	$ff,$df,$f0,0,$f0,0,$c,1
	dc.b	$ff,$ff,0,0,0,0,$13,$88
	dc.b	$1f,$ff,0,0,0,0,$1a,9
	dc.b	$1f,$ff,0,0,0,0,$13,$8a
	dc.b	$1f,$ff,0,0,0,0,'7',9
	dc.b	'?',$ff,0,0,0,0,0,$99
	dc.b	$bf,$df,0,0,0,0,$ca,'7'
	dc.b	$ff,$ff,0,0,0,0,$1c,$80
	dc.b	$1f,$ff,0,0,0,0,$10,$8c
	dc.b	$b,$83,$18,0,$18,0,0,'('
	dc.b	$a,0,0,0,0,0,$cf,$df
	dc.b	0,0,$cf,$df,$cf,$df,$dd,$9f
	dc.b	0,0,$dd,$80,$dd,$80,$aa,'`'
	dc.b	1,0,$ab,'_',$ab,'@',6,0
	dc.b	'!',$ff,$c0,$f,0,$f,0,4
	dc.b	$fc,2,$fc,6,$fc,6,0,0
	dc.b	$bf,$e0,'?',$e0,'?',$e0,0,0
	dcb.w	4
	dc.b	1,$ff,1,$ff,1,$ff,0,0
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,'t!'
	dc.b	$cf,$fe,$f0,0,$f0,0,'$!'
	dc.b	$bf,$fe,0,0,0,0,'0!'
	dc.b	$bf,$fe,0,0,0,0,'4!'
	dc.b	$bf,$fe,0,0,0,0,4,1
	dc.b	$bf,$fe,0,0,0,0,$10,$85
	dc.b	$af,$ff,0,0,0,0,$90,$80
	dc.b	$af,$ff,0,0,0,0,$10,$85
	dc.b	$af,$ff,0,0,0,0,'0',3
	dc.b	$bf,$fc,0,0,0,0,'*',$1c
	dc.b	$b1,$a3,$18,0,$18,0,0,'"'
	dc.b	$1f,$de,0,0,0,0,$cf,$df
	dc.b	0,0,$cf,$df,$cf,$df,$bd,$80
	dc.b	0,0,$bd,$80,$bd,$80,2,$18
	dc.b	1,7,3,0,3,0,0,0
	dc.b	$ff,$f0,'?',$f0,'?',$f0,3,$f4
	dc.b	0,2,3,$f6,3,$f6,0,0
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,0,0
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,0,0
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,0,3
	dc.b	$ff,$fe,$ff,$ff,$ff,$ff,$c4,3
	dc.b	'?',$fc,$c0,0,$c0,0,$b0,3
	dc.b	'?',$fc,0,0,0,0,$a4,3
	dc.b	'?',$fc,0,0,0,0,$94,3
	dc.b	'?',$fc,0,0,0,0,$a4,$8b
	dc.b	'?t',0,0,0,0,$b8,1
	dc.b	7,$ff,0,0,0,0,$b8,1
	dc.b	$87,$ff,0,0,0,0,'8',0
	dc.b	$87,$ff,0,0,0,0,'0',6
	dc.b	$bf,$f8,0,0,0,0,$85,4
	dc.b	'2',$b3,$14,0,$14,0,$18,2
	dc.b	$a7,$dc,0,0,0,0,$cf,$df
	dc.b	0,0,$cf,$df,$cf,$df,$bd,$ab
	dc.b	0,'?',$bd,$80,$bd,$80,$aa,0
	dc.b	1,'~',$ab,'~',$ab,'~',0,$f
	dc.b	0,0,0,$f,0,$f,$fe,4
	dc.b	0,2,$fe,6,$fe,6,$ff,$ff
	dc.b	0,0,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	0,0,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	0,0,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	0,0,$ff,$ff,$ff,$ff,0,'8'
	dc.b	$bf,$c7,0,0,0,0,$80,'8'
	dc.b	'?',$c7,0,0,0,0,$80,'8'
	dc.b	'?',$c7,0,0,0,0,$80,'8'
	dc.b	'?',$c7,0,0,0,0,$91,$ba
	dc.b	'.E',0,0,0,0,$a3,$80
	dc.b	$1c,$7f,0,0,0,0,'#',$80
	dc.b	$9c,$7f,0,0,0,0,'#',$80
	dc.b	$9c,$7f,0,0,0,0,0,'>'
	dc.b	$bf,$c1,0,0,0,0,$80,6
	dc.b	'7',$b9,$10,0,$10,0,'0',$e
	dc.b	$8f,$f0,0,0,0,0,$cf,$df
	dc.b	0,0,$cf,$df,$cf,$df,'y',$b8
	dc.b	0,7,'y',$80,'y',$80,2,1
	dc.b	1,0,3,1,3,1,$ff,$f0
	dc.b	0,0,$ff,$f0,$ff,$f0,1,4
	dc.b	0,2,1,6,1,6,$ff,$ff
	dc.b	0,0,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	0,0,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	0,0,$ff,$ff,$ff,$ff,$ff,$fd
	dc.b	0,2,$ff,$fc,$ff,$fc,$80,$97
	dc.b	'?h',0,0,0,0,$a0,$97
	dc.b	'?h',0,0,0,0,$80,$97
	dc.b	'?h',0,0,0,0,$80,$97
	dc.b	'?h',0,0,0,0,$94,$b7
	dc.b	'+H',0,0,0,0,$bd,' '
	dc.b	2,$df,0,0,0,0,$bd,' '
	dc.b	$82,$df,0,0,0,0,$bd,' '
	dc.b	$82,$df,0,0,0,0,$80,$97
	dc.b	$bf,'h',0,0,0,0,$81,$a4
	dc.b	'6',$13,$10,0,$10,0,'+',$8c
	dc.b	$94,'p',0,0,0,0,$cf,$df
	dc.b	0,0,$cf,$df,$cf,$df,'q',$8e
	dc.b	0,'5q',$80,'q',$80,$aa,'~'
	dc.b	1,0,$ab,'~',$ab,'~',0,$a
	dc.b	0,0,0,$a,0,$a,$a2,$a4
	dc.b	0,2,$a2,$a6,$a2,$a6,0,0
	dcb.w	11
	dc.b	0,3,0,4,0,4,0,4
	dc.b	$86,$ff,'9',0,0,0,0,0
	dc.b	$86,$ff,'9',0,0,0,0,0
	dc.b	$86,$ff,'9',0,0,0,0,0
	dc.b	$86,$ff,'9',0,0,0,0,0
	dc.b	$86,$ff,'9',0,0,0,0,0
	dc.b	$bf,$ec,0,$13,0,0,0,0
	dc.b	'?',$ec,$80,$13,0,0,0,0
	dc.b	'?',$ec,$80,$13,0,0,0,0
	dc.b	6,$ff,$b9,0,0,0,0,0
	dc.b	$a6,'.',$11,$11,$10,0,$10,0
	dc.b	'=',$1e,$82,$e0,0,0,0,0
	dc.b	$cf,$de,0,0,$cf,$de,$cf,$de
	dc.b	$f1,$84,0,'?',$f1,$80,$f1,$80
	dc.b	2,0,1,0,3,0,3,0
	dc.b	$ff,'|',0,0,$ff,'|',$ff,'|'
	dc.b	'`',4,0,2,'`',6,'`',6
	dc.b	$ef,$ff,0,0,$ef,$ff,$ef,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ee,'C',1,4,$ef,'D',$ef,'D'
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	6,$bb,'0',0,'0',0,'0',0
	dc.b	'?',$8a,$80,'p',0,0,0,0
	dc.b	$cf,$dd,0,0,$cf,$dd,$cf,$dd
	dc.b	$e5,$81,0,'>',$e5,$80,$e5,$80
	dc.b	$aa,'u',1,0,$ab,'u',$ab,'u'
	dc.b	'U',$ef,0,0,'U',$ef,'U',$ef
	dc.b	'j',$a4,0,2,'j',$a6,'j',$a6
	dc.b	$ef,$ff,0,0,$ef,$ff,$ef,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ee,'8',1,4,$ef,'<',$ef,'<'
	dcb.w	36
	dc.b	$10,'4 ',0,'0',0,'0',0
	dc.b	$1f,$de,0,' ',0,0,0,0
	dc.b	$cf,$dd,0,0,$cf,$dd,$cf,$dd
	dc.b	$ed,$ac,0,$13,$ed,$80,$ed,$80
	dc.b	2,'?',1,0,3,'?',3,'?'
	dc.b	$dd,$7f,3,$80,$dc,$7f,$dc,$7f
	dc.b	$f0,4,'0',2,$c0,6,$c8,6
	dc.b	$ef,0,$10,1,$f0,0,$f0,0
	dc.b	'4',0,$8b,$1f,0,0,0,0
	dc.b	'd',0,$8b,$1f,0,0,0,0
	dc.b	'~:',$81,7,$f,'<',$f,'<'
	dc.b	2,$10,$ff,$1f,0,0,0,0
	dc.b	$a,3,$ff,$1f,0,0,0,0
	dc.b	$a,$1f,$ff,$1f,0,0,0,0
	dc.b	$8a,$15,$ff,$1f,0,0,0,0
	dc.b	$8b,$19,$ff,$1f,0,0,0,0
	dc.b	2,6,$ff,$1f,0,0,0,0
	dc.b	$82,1,$ff,$1f,0,0,0,0
	dc.b	0,$13,$ff,$1f,0,0,0,0
	dc.b	$8a,$c,$ff,$1f,0,0,0,0
	dc.b	4,2,$e3,9,' ',0,' ',0
	dc.b	0,$14,0,' ',0,0,0,0
	dc.b	$cd,$fb,0,0,$cd,$fb,$cd,$fb
	dc.b	$cd,$bd,0,2,$cd,$80,$cd,$80
	dc.b	$aa,']',1,0,$ab,']',$ab,']'
	dc.b	$fb,$fb,4,'@',$fb,$bb,$fb,$bb
	dc.b	$a2,$a4,'@',2,0,$a6,$1c,$a6
	dc.b	$ef,'#',$10,$80,$f0,2,$f0,2
	dc.b	$dd,$b,' ',$b4,0,0,0,0
	dc.b	$da,$83,' <',0,0,0,0
	dc.b	$de,'8!',$87,$f,'<',$f,'<'
	dc.b	'!',$14,$fe,$bf,0,0,0,0
	dc.b	'!0',$fe,$bf,0,0,0,0
	dc.b	'!',$10,$fe,$bf,0,0,0,0
	dc.b	'!',$14,$fe,$bf,0,0,0,0
	dc.b	1,$14,$fe,$bf,0,0,0,0
	dc.b	1,'0',$fe,$bf,0,0,0,0
	dc.b	'!',0,$fe,$bf,0,0,0,0
	dc.b	'! ',$fe,$bf,0,0,0,0
	dc.b	1,'1',$fe,$be,0,0,0,0
	dc.b	$8f,6,'`™(',0,'(',0
	dc.b	0,' ',$ff,'@',0,0,0,0
	dc.b	$cd,$fb,0,0,$cd,$fb,$cd,$fb
	dc.b	$dd,$bf,0,0,$dd,$80,$dd,$80
	dc.b	2,$7f,1,0,3,$7f,3,$7f
	dc.b	'w',$7f,8,' w^w',$de
	dc.b	2,4,$e0,2,0,6,$14,6
	dc.b	$ec,'=',$10,$82,$f0,$1e,$f0,$1e
	dc.b	$ef,$83,0,'4',0,0,0,0
	dc.b	$ff,$8b,0,'4',0,0,0,0
	dc.b	$be,$b8,1,7,$f,'<',$f,'<'
	dc.b	3,$80,$fc,'?',0,0,0,0
	dc.b	$8b,$80,'t?',0,0,0,0
	dc.b	3,$a0,$fc,'?',0,0,0,0
	dc.b	3,$90,$fc,'?',0,0,0,0
	dc.b	3,$94,$fc,'?',0,0,0,0
	dc.b	3,$b0,$fc,'?',0,0,0,0
	dc.b	3,$80,$fc,'?',0,0,0,0
	dc.b	$8b,$90,'t?',0,0,0,0
	dc.b	3,$87,$fc,'<',0,0,0,0
	dc.b	'A',$ba,$ac,5,' ',0,' ',0
	dc.b	0,0,$ff,'^',0,0,0,0
	dc.b	$cd,$f7,0,0,$cd,$f7,$cd,$f7
	dc.b	$9d,$9f,0,0,$9d,$80,$9d,$80
	dc.b	$aa,'7',1,0,$ab,'7',$ab,'7'
	dc.b	$ef,$bf,$10,' ',$ef,$9e,$ef,$de
	dc.b	'`',$a4,$80,2,0,$a6,$1e,$a6
	dc.b	$ef,$bd,$10,2,$f0,$1e,$f0,$1e
	dc.b	$fd,$bd,0,0,0,0,0,0
	dc.b	$fd,'>',0,0,0,0,0,0
	dc.b	$fe,$b8,1,7,$f,'<',$f,'<'
	dc.b	'8',$91,$c7,'.',0,0,0,0
	dc.b	$ba,$80,'E?',0,0,0,0
	dc.b	'8',$80,$c7,'?',0,0,0,0
	dc.b	'8',$80,$c7,'?',0,0,0,0
	dc.b	'8',$80,$c7,'?',0,0,0,0
	dc.b	'8',$80,$c7,'?',0,0,0,0
	dc.b	'8',$91,$c7,'.',0,0,0,0
	dc.b	$ba,$80,'E?',0,0,0,0
	dc.b	'8',$84,$c7,';',0,0,0,0
	dc.b	'L',$b5,$a3,8,' ',0,' ',0
	dc.b	'@"',$bf,$fc,0,0,0,0
	dc.b	$cd,$ef,0,0,$cd,$ef,$cd,$ef
	dc.b	'=',$80,0,0,'=',$80,'=',$80
	dc.b	2,$7f,1,0,3,$7f,3,$7f
	dc.b	$df,$bf,' ',$10,$df,$af,$df,$ef
	dc.b	$c0,4,6,2,0,6,'8',6
	dc.b	$e7,'<',$10,2,$f0,$1e,$f0,$1e
	dc.b	'9',$b,0,' ',0,0,0,0
	dc.b	$fb,$9d,0,' ',0,0,0,0
	dc.b	$fe,$b8,1,7,$f,'<',$f,'<'
	dc.b	$97,$94,'h+',0,0,0,0
	dc.b	$b7,$a0,'H?',0,0,0,0
	dc.b	$94,'6h',$7f,0,0,3,$80
	dc.b	'`',0,$80,7,0,0,0,0
	dc.b	$97,$a0,'h?',0,0,0,0
	dc.b	$97,$a0,'h?',0,0,0,0
	dc.b	$97,$94,'h+',0,0,0,0
	dc.b	$b7,$a0,'H?',0,0,0,0
	dc.b	$97,$80,'h?',0,0,0,0
	dc.b	$87,$9f,'h',0,'`',0,'`',0
	dc.b	0,8,$7f,$f4,0,0,0,0
	dc.b	$cd,$ef,0,0,$cd,$ef,$cd,$ef
	dc.b	'}',$9a,0,$1b,'}',$80,'}',$80
	dc.b	$aa,$7f,1,0,$ab,$7f,$ab,$7f
	dc.b	$bf,$ff,'@',$10,$bf,$ef,$bf,$ef
	dc.b	$82,$a4,0,2,2,$a6,'~',$a6
	dc.b	$e6,'<',$10,2,$f0,$1e,$f0,$1e
	dc.b	$ff,'?',0,0,0,0,0,0
	dc.b	'n',$9f,$10,' ',0,0,0,0
	dc.b	$be,$ba,1,5,$f,'<',$f,'<'
	dc.b	$ff,$86,0,'9',0,0,0,0
	dc.b	$ff,$86,0,'9',0,0,0,0
	dc.b	$fe,0,0,0,0,0,0,0
	dc.b	0,6,0,9,0,0,0,0
	dc.b	$ff,$86,0,'9',0,0,0,0
	dc.b	$ff,$86,0,'9',0,0,0,0
	dc.b	$ff,$86,0,'9',0,0,0,0
	dc.b	$ff,$86,0,'9',0,0,0,0
	dc.b	$ff,$86,0,'9',0,0,0,0
	dc.b	$96,$98,'@',0,'P',0,'P',0
	dc.b	$10,'J',$ef,$b0,0,0,0,0
	dc.b	$cd,$de,0,0,$cd,$de,$cd,$de
	dc.b	'}',$bf,0,0,'}',$80,'}',$80
	dc.b	2,$7f,1,0,3,$7f,3,$7f
	dc.b	'p',$f,$8f,$f0,$7f,$ef,'p',$f
	dc.b	$d8,4,$18,2,$c0,6,$e0,6
	dc.b	$ec,$9d,$10,2,$f0,$1e,$f0,$1e
	dc.b	$b8,$1f,0,0,0,0,0,0
	dc.b	$ff,7,0,0,0,0,0,0
	dc.b	$fe,';',1,4,$f,'<',$f,'<'
	dc.b	$bf,$1f,'@',0,0,0,0,0
	dc.b	$bf,$1f,'@',0,0,0,0,0
	dc.b	$bf,0,'@',0,0,0,0,0
	dc.b	0,$f,0,$10,0,0,0,0
	dc.b	$bf,$1f,'@',0,0,0,0,0
	dc.b	$bf,$1f,'@',0,0,0,0,0
	dc.b	$bf,$1f,'@',0,0,0,0,0
	dc.b	$bf,$1f,'@',0,0,0,0,0
	dc.b	$bf,$1f,'@',0,0,0,0,0
	dc.b	$9b,'6@',0,'P',0,'P',0
	dc.b	$ee,'&',$11,$d8,0,0,0,0
	dc.b	$cd,$de,0,0,$cd,$de,$cd,$de
	dc.b	$fd,$b9,0,6,$fd,$80,$fd,$80
	dc.b	$aa,'~',1,1,$ab,'~',$ab,'~'
	dc.b	$f0,'?',7,$c0,$e7,$df,$e0,$1f
	dc.b	$88,4,8,2,$80,6,$b0,6
	dc.b	$e4,$1c,$10,2,$f0,$1e,$f0,$1e
	dcb.w	8
	dc.b	$e,'8',1,4,$f,'<',$f,'<'
	dcb.w	8
	dc.b	0,$80,0,0,0,0,0,0
	dcb.w	24
	dc.b	$10,$16,'@',0,'P',0,'P',0
	dc.b	$be,'TA',$a0,0,0,0,0
	dc.b	$cd,$bc,0,0,$cd,$bc,$cd,$bc
	dc.b	$fd,$bf,0,0,$fd,$80,$fd,$80
	dc.b	2,'}',1,2,3,'}',3,'}'
	dc.b	$f0,' ',7,$c0,$97,$c0,$90,0
	dc.b	0,4,3,$c2,3,$c6,$7f,$c6
	dc.b	$e0,'<',$1a,3,$f0,$1e,$f0,$1e
	dc.b	0,'4',$1f,$ca,0,0,0,0
	dc.b	0,'t',$1f,$8b,0,0,0,0
	dc.b	$e,'x',$11,$87,$f,'<',$f,'<'
	dc.b	$10,9,$1f,$ff,0,0,0,0
	dc.b	0,$88,$1f,$ff,0,0,0,0
	dc.b	$1f,$c0,$1f,$c0,0,0,0,0
	dc.b	0,3,0,$7f,0,0,0,0
	dc.b	$b,$a5,$1f,$db,0,0,0,0
	dc.b	$12,0,$1f,$ff,0,0,0,0
	dc.b	8,9,$1f,$ff,0,0,0,0
	dc.b	$10,$8a,$1f,$ff,0,0,0,0
	dc.b	$16,'#',$1f,$df,0,0,0,0
	dc.b	0,2,'_',$89,'@',0,'@',0
	dc.b	'!:',0,0,0,0,0,0
	dc.b	$cd,'|',0,0,$cd,'|',$cd,'|'
	dc.b	$fd,$a7,0,$18,$fd,$80,$fd,$80
	dc.b	$aa,'{',1,4,$ab,'z',$ab,'z'
	dc.b	$fc,'@',3,$9f,'{',$9f,'x',$1f
	dc.b	0,'4',$80,2,$80,'6',$f8,'6'
	dc.b	$e3,$bd,$1c,2,$f0,$1e,$f0,$1e
	dc.b	$81,'^6',$a0,0,0,0,0
	dc.b	$81,$d7,'< ',0,0,0,0
	dc.b	$8e,$f9,'1',6,$f,'<',$f,'<'
	dc.b	0,1,$bf,$fe,0,0,0,0
	dc.b	4,1,$bf,$fe,0,0,0,0
	dc.b	'0',0,$bf,$c0,0,0,0,0
	dc.b	0,1,0,'~',0,0,0,0
	dc.b	'4',$95,$bf,'j',0,0,0,0
	dc.b	0,'!',$bf,$fe,0,0,0,0
	dc.b	'$',1,$bf,$fe,0,0,0,0
	dc.b	$10,'!',$bf,$fe,0,0,0,0
	dc.b	'0',3,$bf,$fc,0,0,0,0
	dc.b	0,3,$df,$bc,'@',0,'@',0
	dc.b	0,' ',$1e,0,0,0,0,0
	dc.b	$cd,'z',0,0,$cd,'z',$cd,'z'
	dc.b	$fd,$be,0,1,$fd,$80,$fd,$80
	dc.b	2,'w',1,8,3,'q',3,'q'
	dc.b	3,$80,0,'|',0,'|',0,'|'
	dc.b	$f,$84,0,2,$f,$86,$f,$86
	dc.b	$e3,$bd,$1c,2,$f0,$1e,$f0,$1e
	dc.b	$18,$27,'$',0,0,0,0,0
	dc.b	$a,$fb,'4',0,0,0,0,0
	dc.b	$8e,$fb,'1',4,$f,'<',$f,'<'
	dc.b	$80,$b,'?',$f4,0,0,0,0
	dc.b	$80,$8b,'?t',0,0,0,0
	dc.b	$84,0,'?',$80,0,0,0,4
	dc.b	0,3,4,'<',0,0,0,0
	dc.b	$b5,$13,'>',$ec,0,0,0,0
	dc.b	$80,$8b,'?t',0,0,0,0
	dc.b	$a5,7,'>',$f8,0,0,0,0
	dc.b	$b0,$13,'?',$ec,0,0,0,0
	dc.b	$9d,'36',$cc,0,0,0,0
	dc.b	1,$bb,$de,4,$c0,0,$c0,0
	dc.b	$90,'P',$8f,$8e,0,0,0,0
	dc.b	$cc,$f2,0,0,$cc,$f2,$cc,$f2
	dc.b	$fd,$bf,0,0,$fd,$80,$fd,$80
	dc.b	$aa,'H',1,$10,$ab,'@',$ab,'@'
	dc.b	0,3,$ff,0,$ff,3,$ff,3
	dc.b	$f0,4,0,2,$f0,6,$f0,6
	dc.b	$ea,$bd,$14,2,$f0,$1e,$f0,$1e
	dc.b	$1b,$fb,0,0,0,0,0,0
	dc.b	'=',$fe,0,0,0,0,0,0
	dc.b	$ae,$f8,$11,7,$f,'<',$f,'<'
	dc.b	$80,'8?',$c7,0,0,0,0
	dc.b	$91,$ba,'.E',0,0,0,0
	dc.b	$80,'&?F',0,0,0,0
	dc.b	0,$18,$c,7,0,0,0,0
	dc.b	$80,'8?',$c7,0,0,0,0
	dc.b	$91,$ba,'.E',0,0,0,0
	dc.b	$80,'9?',$c6,0,0,0,0
	dc.b	$80,'|?',$83,0,0,0,0
	dc.b	$90,'8/',$c7,0,0,0,0
	dc.b	7,$9b,$b8,'$',$80,0,$80,0
	dc.b	$b9,2,6,$dc,0,0,0,0
	dc.b	$cc,$f6,0,0,$cc,$f6,$cc,$f6
	dc.b	$fd,$9f,0,0,$fd,$80,$fd,$80
	dc.b	2,0,1,'?',3,'?',3,'?'
	dc.b	0,$fe,$c0,0,$c0,$fe,$c0,$fe
	dc.b	0,4,0,2,0,6,0,6
	dc.b	$ef,'=',$10,2,$f0,$1e,$f0,$1e
	dc.b	$ba,$fd,0,0,0,0,0,0
	dc.b	$9b,$f7,' ',0,0,0,0,0
	dc.b	$9e,$fb,'!',4,$f,'<',$f,'<'
	dc.b	$81,$97,'>h',0,0,0,0
	dc.b	$94,$b7,'+H',0,0,0,0
	dc.b	$82,'J<',$f3,0,0,0,0
	dc.b	8,7,$f0,8,0,0,0,0
	dc.b	$80,$9f,'?`',0,0,0,0
	dc.b	$b4,$b7,'+H',0,0,0,0
	dc.b	$80,$d7,'?(',0,0,0,0
	dc.b	$80,$d7,'?(',0,0,0,0
	dc.b	$80,$97,'?h',0,0,0,0
	dc.b	$18,$b9,'g',6,0,0,$80,0
	dc.b	'9',$e,6,$f0,0,0,0,0
	dc.b	$cd,$e6,0,0,$cd,$e6,$cd,$e6
	dc.b	$fd,$97,0,0,$fd,$80,$fd,$80
	dc.b	$aa,0,1,'p',$ab,'p',$ab,'p'
	dc.b	'?',$c1,0,0,'?',$c1,'?',$c1
	dc.b	$aa,$a4,0,2,$aa,$a6,$aa,$a6
	dc.b	$ed,$bd,$10,2,$f0,$1e,$f0,$1e
	dc.b	'?',$9b,0,'D',0,0,0,0
	dc.b	$9f,'_ ',0,0,0,0,0
	dc.b	$be,$fb,1,4,$f,'<',$f,'<'
	dc.b	$86,$ff,'9',0,0,0,0,0
	dc.b	$86,$ff,'9',0,0,0,0,0
	dc.b	$85,'A9',$80,0,0,0,0
	dc.b	$f0,$f,0,0,0,0,0,0
	dc.b	$a6,$ff,$19,0,0,0,0,0
	dc.b	$86,$ff,'9',0,0,0,0,0
	dc.b	$a6,$ff,$19,0,0,0,0,0
	dc.b	$86,$ff,'9',0,0,0,0,0
	dc.b	$86,$ff,'9',0,0,0,0,0
	dc.b	'"',$ab,$98,$14,$a0,0,$a0,0
	dc.b	'?',$e8,0,$16,0,0,0,0
	dc.b	$c9,$ee,0,0,$c9,$ee,$c9,$ee
	dc.b	$fd,$a0,0,'(',$fd,$80,$fd,$80
	dc.b	2,$f,1,0,3,$f,3,$f
	dc.b	$f0,';',0,0,$f0,';',$f0,';'
	dc.b	$e0,4,0,2,$e0,6,$e0,6
	dc.b	$ed,'=',$10,2,$f0,$1e,$f0,$1e
	dc.b	$12,$eb,0,0,0,0,0,0
	dc.b	$d,$bb,0,0,0,0,0,0
	dc.b	$1e,$fb,1,4,$f,'<',$f,'<'
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	$19,'@',1,$80,0,0,0,0
	dc.b	0,$27,0,0,0,0,0,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	$1f,$bf,0,'@',0,0,0,0
	dc.b	'=',$ad,'@',$12,' ',0,$a0,0
	dc.b	$bf,$12,0,$e8,0,0,0,0
	dc.b	$cb,$ce,0,0,$cb,$ce,$cb,$ce
	dc.b	$fd,$9e,0,'?',$fd,$80,$fd,$80
	dc.b	$aa,'|',1,0,$ab,'|',$ab,'|'
	dc.b	3,$de,0,0,3,$de,3,$de
	dc.b	$ea,$a4,0,2,$ea,$a6,$ea,$a6
	dc.b	$e4,$9c,$10,2,$f0,$1e,$f0,$1e
	dcb.w	8
	dc.b	$e,'8',1,4,$f,'<',$f,'<'
	dcb.w	8
	dc.b	2,$80,3,0,0,0,0,0
	dc.b	0,'p',0,' ',0,0,0,0
	dcb.w	17
	dc.b	0,1,0,0,0,0,' &'
	dc.b	$c0,0,$a0,0,$a0,0,'?',$cc
	dc.b	0,'0',0,0,0,0,$c7,$df
	dc.b	0,0,$c7,$df,$c7,$df,$fd,$9d
	dc.b	0,'&',$fd,$80,$fd,$80,2,0
	dc.b	1,0,3,0,3,0,$7f,$7f
	dc.b	0,0,$7f,$7f,$7f,$7f,'`',4
	dc.b	0,2,'`',6,'`',6,$e8,$1c
	dc.b	$12,3,$f0,$1e,$f0,$1e,'t',0
	dc.b	$8b,$1f,0,0,0,0,'d',4
	dc.b	$8b,$1b,0,0,0,0,'~9'
	dc.b	$81,7,$f,'<',$f,'<',0,2
	dc.b	$ff,$1f,0,0,0,0,$8a,$a
	dc.b	$ff,$1f,0,0,0,0,$8a,$80
	dc.b	$fb,0,0,0,0,0,0,'"'
	dc.b	0,1,0,0,0,0,1,4
	dc.b	$ff,$1f,0,0,0,0,$87,0
	dc.b	$fb,$1f,0,0,0,0,6,1
	dc.b	$fb,$1f,0,0,0,0,$b,1
	dc.b	$ff,$1f,0,0,0,0,$11,$14
	dc.b	$ef,$1f,0,1,0,1,'@',0
	dc.b	$bf,9,$c0,0,$c0,0,7,$de
	dc.b	0,' ',0,0,0,0,$c7,$bf
	dc.b	0,0,$c7,$bf,$c7,$bf,$fd,$8e
	dc.b	0,'5',$fd,$80,$fd,$80,$aa,$1e
	dc.b	1,0,$ab,$1e,$ab,$1e,$db,$f7
	dc.b	0,0,$db,$f7,$db,$f7,$ea,$a4
	dc.b	0,2,$ea,$a6,$ea,$a6,$ee,'='
	dc.b	$11,2,$f0,$1e,$f0,$1e,$de,$b
	dc.b	' 4',0,0,0,0,$9f,$a8
	dc.b	' ',$14,0,0,0,0,$de,':'
	dc.b	'!',$85,$f,'<',$f,'<',1,4
	dc.b	$fe,$bf,0,0,0,0,1,'1'
	dc.b	$fe,$be,0,0,0,0,'%',0
	dc.b	$f6,0,0,0,0,0,0,0
	dc.b	0,3,0,0,0,0,'!',4
	dc.b	$fe,$bf,0,0,0,0,1,8
	dc.b	$fe,$b7,0,0,0,0,$d5,$a1
	dc.b	'*>',0,0,0,0,'A',$a0
	dc.b	$be,'?',0,0,0,0,1,'2'
	dc.b	$fe,$bd,0,3,0,3,$27,$84
	dc.b	$d8,$1b,' ',0,' ',0,'a:'
	dc.b	$98,0,0,0,0,0,$cf,'?'
	dc.b	0,0,$cf,'?',$cf,'?',$dd,$8b
	dc.b	0,'4',$dd,$80,$dd,$80,2,'k'
	dc.b	1,0,3,'k',3,'k',$ff,$ff
	dc.b	0,0,$ff,$ff,$ff,$ff,$e0,4
	dc.b	0,2,$e0,6,$e0,6,$ef,$9d
	dc.b	$10,2,$f0,$1e,$f0,$1e,$7f,$8b
	dc.b	0,'4',0,0,0,0,$bf,$99
	dc.b	0,'$',0,0,0,0,$fe,$b8
	dc.b	1,7,$f,'<',$f,'<',$a3,$90
	dc.b	'\?',0,0,0,0,'3',$ac
	dc.b	$cc,'7',0,0,0,0,5,0
	dc.b	$f6,0,0,0,0,0,0,3
	dcb.w	3
	dc.b	$b,$84,$f4,'?',0,0,0,0
	dc.b	3,$aa,$fc,'5',0,0,0,0
	dc.b	3,$a4,$fc,'?',0,0,0,0
	dc.b	3,$80,$fc,'?',0,0,0,0
	dc.b	3,$be,$fc,'5',0,3,0,3
	dc.b	$a3,$b5,'\',$a,$e0,0,$e0,0
	dc.b	$f8,' ',6,0,0,0,0,0
	dc.b	$df,$7f,0,0,$df,$7f,$df,$7f
	dc.b	$dd,$a7,0,$18,$dd,$80,$dd,$80
	dc.b	$aa,'?',1,0,$ab,'?',$ab,'?'
	dc.b	$bf,$ff,0,0,$bf,$ff,$bf,$ff
	dc.b	$ea,$a4,0,2,$ea,$a6,$ea,$a6
	dc.b	$ef,$bc,$10,2,$f0,$1e,$f0,$1e
	dc.b	'k',$bd,0,0,0,0,0,0
	dc.b	$dc,$af,0,0,0,0,0,0
	dc.b	$de,$b8,1,7,$f,'<',$f,'<'
	dc.b	'8',$92,$c7,'-',0,0,0,0
	dc.b	'8',$80,$c7,'?',0,0,0,0
	dc.b	'*',0,$c4,0,0,0,0,0
	dc.b	0,3,0,0,0,0,0,0
	dc.b	'8',$90,$c7,'/',0,0,0,0
	dc.b	'9',$80,$c6,'?',0,0,0,0
	dc.b	'x',$88,$87,'7',0,0,0,0
	dc.b	'8',$a0,$c7,$1f,0,0,0,0
	dc.b	'9',$96,$c6,'(',0,6,0,6
	dc.b	$fb,'9',4,6,$e0,0,$e0,0
	dc.b	' ',$1e,$1f,$c0,0,0,0,0
	dc.b	$de,$7f,0,0,$de,$7f,$de,$7f
	dc.b	$dd,$be,0,1,$dd,$80,$dd,$80
	dc.b	2,$7f,1,0,3,$7f,3,$7f
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$e0,4,0,2,$e0,6,$e0,6
	dc.b	$ed,$bd,$10,2,$f0,$1e,$f0,$1e
	dc.b	$fa,$1f,0,' ',0,0,0,0
	dc.b	$8f,$17,0,' ',0,0,0,0
	dc.b	$de,$b9,1,6,$f,'<',$f,'<'
	dc.b	$d7,$80,'(?',0,0,0,0
	dc.b	$97,$80,'h?',0,0,0,0
	dc.b	$84,0,'h',0,0,0,0,0
	dc.b	0,$11,0,0,0,0,0,0
	dc.b	$97,$a0,'h?',0,0,0,0
	dc.b	$f7,$a0,8,'?',0,0,0,0
	dc.b	$97,$a8,'h7',0,0,0,0
	dc.b	$d7,$a0,'(?',0,0,0,0
	dc.b	$9f,$ac,'`0',0,$c,0,$c
	dc.b	$bf,$a3,'@',$1c,$e0,0,$e0,0
	dc.b	'^',6,1,$f8,0,0,0,0
	dc.b	$de,$ff,0,0,$de,$ff,$de,$ff
	dc.b	$dd,$be,0,1,$dd,$80,$dd,$80
	dc.b	$aa,'o',1,0,$ab,'o',$ab,'o'
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ea,$a4,0,2,$ea,$a6,$ea,$a6
	dc.b	$ed,$1d,$10,2,$f0,$1e,$f0,$1e
	dc.b	$f7,$8f,0,0,0,0,0,0
	dc.b	$ff,$bf,0,0,0,0,0,0
	dc.b	$fe,$ba,1,5,$f,'<',$f,'<'
	dc.b	$ff,$a6,0,$19,0,0,0,0
	dc.b	$ff,$86,0,'9',0,0,0,0
	dc.b	$e0,0,8,0,0,0,0,0
	dc.b	1,$11,0,8,1,0,1,0
	dc.b	$ff,$96,0,')',0,0,0,0
	dc.b	$ff,$a7,0,$18,0,0,0,0
	dc.b	$ff,$86,0,'9',0,0,0,0
	dc.b	$ff,$86,0,'9',0,0,0,0
	dc.b	$ff,$9c,0,'!',0,$1d,0,$1d
	dc.b	$af,$bf,0,0,$a0,0,$a0,0
	dc.b	$c,$10,3,$ec,0,0,0,0
	dc.b	$dc,$ff,0,0,$dc,$ff,$dc,$ff
	dc.b	$dd,$9d,0,0,$dd,$80,$dd,$80
	dc.b	2,$7f,1,0,3,$7f,3,$7f
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$e0,4,0,2,$e0,6,$e0,6
	dc.b	$ec,$9d,$10,2,$f0,$1e,$f0,$1e
	dc.b	$fd,$1f,0,0,0,0,0,0
	dc.b	$af,$17,0,0,0,0,0,0
	dc.b	$be,';',1,4,$f,'<',$f,'<'
	dc.b	$bf,$1f,'@',0,0,0,0,0
	dc.b	$bf,$1f,'@',0,0,0,0,0
	dc.b	$88,8,'`',0,0,8,0,8
	dc.b	0,$13,0,8,0,0,0,0
	dc.b	$97,$1f,'h',0,0,0,0,0
	dc.b	$be,$f,'A',$10,0,0,0,0
	dc.b	$bf,$1f,'@',0,0,0,0,0
	dc.b	$af,$1f,'P',0,0,0,0,0
	dc.b	$bf,'p@',0,0,'p',0,'p'
	dc.b	$af,'>',0,0,$a0,0,$a0,0
	dc.b	$cf,$18,0,$e6,0,0,0,0
	dc.b	$dd,$ff,0,0,$dd,$ff,$dd,$ff
	dc.b	$dd,$84,0,0,$dd,$80,$dd,$80
	dc.b	$aa,$7f,1,0,$ab,$7f,$ab,$7f
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ea,$a4,0,2,$ea,$a6,$ea,$a6
	dc.b	$ef,$1c,0,2,$e0,$1e,$e0,$1e
	dcb.w	8
	dc.b	$e,'8',1,0,$f,'8',$f,'8'
	dcb.w	12
	dc.b	0,$10,0,8,0,0,0,0
	dcb.w	16
	dc.b	0,$c2,0,2,0,$c0,0,$c0
	dc.b	$80,$1f,0,0,$80,0,$80,0
	dc.b	3,6,0,$f0,0,0,0,0
	dc.b	$c3,$ff,0,0,$c3,$ff,$c3,$ff
	dc.b	$dd,$88,0,8,$dd,$80,$dd,$80
	dc.b	2,$7f,1,0,3,$7f,3,$7f
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$e0,4,0,2,$e0,6,$e0,6
	dc.b	$e1,$ff,$10,0,$f0,$1c,$f0,$1c
	dc.b	$fe,$fc,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$fe,$80,1,$1f,$f,0,$f,0
	dc.b	0,1,$ff,$fe,0,0,0,0
	dc.b	$f0,0,7,$ff,0,0,0,0
	dc.b	'8',$c0,$c2,0,2,$c0,2,$c0
	dc.b	0,'#',8,$10,8,0,8,0
	dc.b	$ff,$fc,0,1,0,0,0,0
	dc.b	0,3,$ff,$fc,0,0,0,0
	dc.b	$ff,$80,0,$1f,0,0,0,0
	dc.b	6,$ff,$f9,0,0,0,0,0
	dc.b	$f1,$8a,0,2,0,8,0,8
	dc.b	$f,$f1,0,0,0,0,0,0
	dc.b	$8a,$ec,1,$10,0,0,0,0
	dc.b	$fc,$f,0,0,$fc,$f,$fc,$f
	dc.b	$dd,$bf,0,$13,$dd,$80,$dd,$80
	dc.b	$aa,$7f,1,0,$ab,$7f,$ab,$7f
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ea,$a4,0,2,$ea,$a6,$ea,$a6
	dc.b	$ef,$ff,$10,0,$f0,0,$f0,0
	dc.b	$ff,$d3,0,0,0,0,0,0
	dc.b	$bb,$ff,0,0,0,0,0,0
	dc.b	$fe,'?',1,'@',$f,0,$f,0
	dc.b	$ff,$ed,0,$12,0,0,0,0
	dc.b	$e5,$7f,$a,$80,0,0,0,0
	dc.b	'x',0,$80,$10,0,$10,0,$10
	dc.b	' g',0,$10,' ',0,' ',0
	dc.b	$ff,$ee,0,$10,0,0,0,0
	dc.b	'~',$ff,$81,0,0,0,0,0
	dc.b	$ef,$c7,$10,' ',0,0,0,0
	dc.b	$ef,$ef,$10,$10,0,0,0,0
	dc.b	$ee,2,$10,',',0,$e,0,$e
	dc.b	$b,$ff,$80,0,0,0,0,0
	dc.b	5,'2',8,0,0,0,0,0
	dc.b	$ff,$f0,0,0,$ff,$f0,$ff,$f0
	dc.b	$1d,$bb,0,4,$1d,$80,$1d,$80
	dc.b	2,$7f,1,0,3,$7f,3,$7f
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$e0,6,0,0,$e0,6,$e0,6
	dc.b	$ef,$fb,$10,0,$f0,0,$f0,0
	dc.b	$ff,$8f,0,0,0,0,0,0
	dc.b	$7f,$ef,$80,0,0,0,0,0
	dc.b	$fe,$7f,1,$80,$f,0,$f,0
	dc.b	$fb,$ff,4,0,0,0,0,0
	dc.b	$8b,$f7,'T',8,0,0,0,0
	dc.b	$fc,0,0,0,0,0,0,0
	dc.b	0,$c7,0,' ',0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	'?',$ff,'@',0,0,0,0,0
	dc.b	$fb,$f9,4,0,0,0,0,0
	dc.b	$ff,$fe,0,1,0,0,0,0
	dc.b	$f7,$c0,8,4,0,0,0,0
	dc.b	0,$1b,$c0,0,'@',0,'@',0
	dc.b	$ec,$1c,2,0,0,0,0,0
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$e1,$b9,0,6,$e1,$80,$e1,$80
	dc.b	$aa,$7f,1,0,$ab,$7f,$ab,$7f
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$e0,1,0,0,$e0,0,$e0,0
	dc.b	$f5,$f7,0,0,$e0,0,$e0,0
	dc.b	$ec,'}',$10,0,0,0,0,0
	dc.b	$fb,$df,4,0,0,0,0,0
	dc.b	$ef,'f',0,$99,$e,0,$e,0
	dc.b	$f7,$fd,8,2,0,0,0,0
	dc.b	$bf,$fa,0,5,0,0,0,0
	dc.b	'v',$9e,$88,$98,0,$98,0,$9e
	dc.b	$93,$8a,$90,5,$90,0,$90,0
	dc.b	$ff,$bf,0,'@',0,0,0,0
	dc.b	$be,$ef,1,$10,0,0,0,0
	dc.b	$df,$f6,' ',8,0,0,0,0
	dc.b	'{',$ff,4,0,0,0,0,0
	dc.b	$ff,$f0,0,8,0,0,0,0
	dc.b	$c2,$1c,' ',0,$c0,0,$c0,0
	dc.b	$7f,$f0,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,$7f,$ff,$7f,$ff
	dc.b	$ff,$a6,0,$19,$ff,$80,$ff,$80
	dc.b	2,$7f,1,0,3,$7f,3,$7f
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$f,$ef,0,0,0,0,0,0
	dc.b	$ff,$fb,0,4,0,0,0,0
	dc.b	$f3,$ff,0,0,0,0,0,0
	dc.b	$f7,$bf,0,0,0,0,0,0
	dc.b	$9f,$ed,0,$12,0,0,0,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	0,0,$7f,$ff,0,0,0,0
	dc.b	$f8,$d8,4,$c8,0,$c8,0,$d8
	dc.b	$b1,7,$b0,0,$b0,0,$b1,0
	dc.b	$bf,$fb,'@',4,0,0,0,0
	dc.b	$de,$ff,1,0,0,0,0,0
	dc.b	$f8,0,7,$ff,0,0,0,0
	dc.b	0,0,$9f,$ff,0,0,0,0
	dc.b	$f,$df,$f0,' ',0,0,0,0
	dc.b	$12,$ae,1,1,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$81,$ff,0,0,1,$ff,1,$ff
	dc.b	$ff,$bb,0,4,$ff,$80,$ff,$80
	dc.b	$aa,$7f,1,0,$ab,$7f,$ab,$7f
	dc.b	$ff,$e0,0,0,$c7,$e0,$c7,$e0
	dcb.w	28
	dc.b	1,'~',0,$fe,0,'~',0,'~'
	dc.b	'#`!',0,'!@#@'
	dcb.w	28
	dc.b	0,$f,0,0,0,$f,0,$f
	dc.b	$ff,$be,0,1,$ff,$80,$ff,$80
	dc.b	2,$7f,1,0,3,$7f,3,$7f
	dc.b	$fe,0,'@?',$c2,0,$82,0
	dc.b	0,'@',$ff,$80,0,'8',0,$27
	dc.b	8,$80,'7',$fe,'p',0,$80,0
	dc.b	'@',0,'?',$ff,0,0,0,0
	dc.b	0,0,$ff,$f9,0,0,0,0
	dc.b	$1c,$d2,$ff,$ff,0,0,0,0
	dc.b	'~',$c1,$ff,$fd,0,0,0,0
	dc.b	$fd,$a0,$ff,$ff,0,0,0,0
	dc.b	'!',$ff,$c0,$fa,0,$fa,0,$ff
	dc.b	'/p3',0,'#@/@'
	dc.b	'@',0,$bf,$ff,0,0,0,0
	dc.b	$17,$a0,$e7,$ff,0,0,0,0
	dc.b	3,$1f,$ff,$ff,0,0,0,0
	dc.b	'!',$a3,$f9,$ff,0,0,0,0
	dc.b	$fc,$10,$ff,$ef,0,0,0,0
	dc.b	4,0,$f8,$7f,0,0,0,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	0,'p',$ff,$80,0,0,0,0
	dc.b	$7f,$9f,0,0,$7f,$80,$7f,$80
	dc.b	$aa,$7f,1,0,$ab,'G',$ab,'G'
	dc.b	$ff,$ff,'g',$80,$a3,$80,$c4,0
	dc.b	$e7,$80,$18,0,0,'`',0,'_'
	dc.b	7,$c1,8,'8',$18,0,$f0,0
	dc.b	$fe,$ff,1,0,0,0,0,0
	dc.b	$f3,$a3,$c,'D',0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	'@',0,$bf,$fb,0,0,0,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	'c?',$80,'5',0,'=',0,'?'
	dc.b	'?',$f8,'>',0,'>',0,'>',0
	dc.b	$ff,$7f,0,$80,0,0,0,0
	dc.b	$fb,$ff,2,0,0,0,0,0
	dc.b	$de,0,'!',$ff,0,0,0,0
	dc.b	0,0,$fe,$7f,0,0,0,0
	dc.b	0,'>',$ff,$c1,0,0,0,0
	dc.b	$ff,$83,0,$1c,0,0,0,0
	dc.b	$ff,$fd,0,2,0,0,0,0
	dc.b	$df,$ff,' ',0,0,0,0,0
	dc.b	$81,$9f,0,0,1,$80,1,$80
	dc.b	2,'~',1,'@',3,'B',3,2
	dc.b	$7f,$df,$7f,$ec,$10,$cc,'o '
	dc.b	$7f,0,$80,0,0,'x',0,'G'
	dc.b	4,$e,3,$c0,'x',0,$88,0
	dc.b	$fb,$ff,4,0,0,0,0,0
	dc.b	$ef,$1f,$10,$80,0,0,0,0
	dc.b	$7f,$fd,$80,2,0,0,0,0
	dc.b	$e0,4,$1f,$f7,0,0,0,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	'7',$fd,$c0,0,0,'!',0,'='
	dc.b	'/',$fd,'(',0,'(',0,'/',0
	dc.b	$ff,$eb,0,$14,0,0,0,0
	dc.b	$fc,'z',1,$85,0,0,0,0
	dc.b	$fd,$90,2,'o',0,0,0,0
	dc.b	0,$10,$ff,$9f,0,0,0,0
	dc.b	0,7,$ff,$f8,0,0,0,0
	dc.b	$ff,$f0,0,3,0,0,0,0
	dc.b	$7f,$ff,$80,0,0,0,0,0
	dc.b	$ff,$ef,0,$10,0,0,0,0
	dc.b	$fe,7,0,0,0,0,0,0
	dc.b	$aa,$7f,1,'g',$ab,'#',$ab,'D'
	dc.b	$87,$fb,$87,$fc,$80,'8',7,$c0
	dc.b	$fd,$80,2,0,0,$7f,0,'@'
	dc.b	2,'}',$c,0,$f0,0,0,0
	dc.b	$ff,$f7,0,8,0,0,0,0
	dc.b	$fe,'7',0,'H',0,0,0,0
	dc.b	$fe,$ff,1,0,0,0,0,0
	dc.b	$f1,0,$f,$ef,0,0,0,0
	dc.b	2,0,$ff,$ff,0,0,0,0
	dc.b	7,$ff,$f8,0,0,0,0,0
	dc.b	'>',$bd,1,'B',$c,0,$c,0
	dc.b	'o',$f9,$90,6,0,0,0,0
	dc.b	$fe,$7f,0,$80,0,0,0,0
	dc.b	'~',$e0,$81,$1f,0,0,0,0
	dc.b	0,0,$ff,$e7,0,0,0,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	$ff,$ee,0,$10,0,0,0,0
	dc.b	$f,$ff,'p',0,0,0,0,0
	dc.b	$fb,$ff,4,0,0,0,0,0
	dc.b	$ff,$d0,0,' ',0,0,0,0
	dc.b	2,$7f,1,$7f,3,$10,3,'o'
	dc.b	$fc,'u',$ec,'r',$ec,$10,0,'`'
	dc.b	$ef,$80,$10,0,0,'?',0,0
	dc.b	1,$fd,0,2,$f0,0,0,0
	dc.b	$bf,$fe,'@',1,0,0,0,0
	dc.b	$f1,$ff,8,0,0,0,0,0
	dc.b	'=',$ff,$c2,0,0,0,0,0
	dc.b	$f8,0,7,$df,0,0,0,0
	dc.b	0,1,$ff,$ff,0,0,0,0
	dc.b	'C',$ff,$bc,0,0,0,0,0
	dc.b	'7',$ff,'H',0,0,0,0,0
	dc.b	$b5,$ff,'J',0,0,0,0,0
	dc.b	$ff,$7f,0,'@',0,0,0,0
	dc.b	$9f,$fc,'`',3,0,0,0,0
	dc.b	0,0,$ff,$f9,0,0,0,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	$1f,$ff,$e0,0,0,0,0,0
	dc.b	$c0,$dd,$f,'"',0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$aa,7,1,7,$ab,0,$ab,7
	dc.b	$ff,$8f,$fc,0,'|',0,$80,0
	dc.b	$ff,$c0,0,0,0,$f,0,0
	dc.b	$f,$ff,0,0,$c0,0,0,0
	dc.b	$fb,$fb,4,4,0,0,0,0
	dc.b	$e7,$fe,0,1,0,0,0,0
	dc.b	$fd,'~',2,$81,0,0,0,0
	dc.b	$fc,0,3,$bf,0,0,0,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	1,$ff,$fe,0,0,0,0,0
	dc.b	'?',$ff,'@',0,0,0,0,0
	dc.b	$df,$ff,' ',0,0,0,0,0
	dc.b	$df,$9f,'  ',0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	0,0,$ff,$fe,0,0,0,0
	dc.b	0,0,$7f,$ff,0,0,0,0
	dc.b	1,$ff,$fe,0,0,0,0,0
	dc.b	$f8,$1f,0,$e0,0,0,0,0
	dc.b	$ff,$fb,0,4,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	2,'x',1,0,3,0,3,0
	dc.b	$7f,$ef,'x',$10,$18,0,'`',0
	dc.b	$fb,$f2,4,0,0,0,0,0
	dc.b	'?',$ff,0,0,0,0,0,0
	dc.b	$f7,$ff,8,0,0,0,0,0
	dc.b	$9f,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$fe,0,1,$7f,0,0,0,0
	dc.b	$80,0,$ff,$ff,0,0,0,0
	dc.b	0,$7f,$ff,$80,0,0,0,0
	dc.b	'/',$ef,'P',$10,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$f7,$cf,8,$10,0,0,0,0
	dc.b	$ff,$ef,0,$10,0,0,0,0
	dc.b	$c0,0,'?',$ff,0,0,0,0
	dc.b	0,0,$9f,$ff,0,0,0,0
	dc.b	0,$1f,$ff,$e0,0,0,0,0
	dc.b	$ff,3,0,$1c,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$df,$fb,' ',4,0,0,0,0
	dc.b	$aa,$7f,0,0,$aa,0,$aa,0
	dc.b	$8f,$ff,0,0,0,0,0,0
	dc.b	$fb,$e1,4,$18,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$fe,0,0,0,0,0,0
	dc.b	$7f,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$fe,0,0,$ff,0,0,0,0
	dc.b	0,8,$ff,$ff,0,0,0,0
	dc.b	0,'?',$ff,$c0,0,0,0,0
	dc.b	'6',$bf,'I@',0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$a7,0,'H',0,0,0,0
	dc.b	$ff,$f7,0,8,0,0,0,0
	dc.b	$e0,0,$1f,$ff,0,0,0,0
	dc.b	0,0,$f7,$ff,0,0,0,0
	dc.b	0,1,$ff,$fe,0,0,0,0
	dc.b	$fe,$e0,1,3,0,0,0,0
	dc.b	$7f,$ff,$80,0,0,0,0,0
	dc.b	$f7,$fe,8,0,0,0,0,0
	dc.b	1,$ff,0,0,0,0,0,0
	dc.b	$ff,$f7,0,8,0,0,0,0
	dc.b	$ff,$87,0,'`',0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$fd,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$fc,$80,1,$7f,0,0,0,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	0,$1f,$ff,$e0,0,0,0,0
	dc.b	'?',$ff,'@',0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$f3,0,4,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$f8,0,7,$ff,0,0,0,0
	dc.b	2,0,$f9,$ff,0,0,0,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	'?',$fc,$c0,0,0,0,0,0
	dc.b	$9f,$ff,'`',0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dcb.w	188
	dc.b	0,3,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$b,$c8,$ff,$ff,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$fe,0,0,0,0,0,0,0
	dcb.w	56
	dc.b	0,$c,0,0,0,0,0,0
	dcb.w	16
	dc.b	1,$80,0,0,0,0,0,0
	dcb.w	56
	dc.b	0,$10,0,0,0,0,0,0
	dcb.w	17
	dc.b	0,'@',0,0,0,0,0,0
	dcb.w	4
	dc.b	'?',$ff,'?',$ff,0,0,0,0
	dc.b	$f0,0,$f0,0,0,0,0,0
	dcb.w	43
	dc.b	0,'#',0,0,0,0,0,0
	dc.b	$ff,$da,0,'%',0,0,0,0
	dc.b	1,'?',$ff,$ff,0,0,0,0
	dc.b	$b0,$b,$b0,$b,0,0,'O',$f4
	dc.b	$e8,9,$ff,$f6,0,0,0,0
	dc.b	$be,0,'@ ',0,0,0,0
	dcb.w	5
	dc.b	'@',0,'@',0,'?',$ff,0,0
	dc.b	8,0,8,0,$f0,0,0,0
	dcb.w	43
	dc.b	0,'$',0,0,0,0,0,0
	dcb.w	16
	dc.b	1,'0',0,' ',0,0,0,0
	dcb.w	5
	dc.b	$bf,$ff,$bf,$ff,'@',0,0,0
	dc.b	$f4,0,$f4,0,8,0,0,0
	dcb.w	43
	dc.b	0,'H',0,0,0,0,0,1
	dcb.w	3
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,$a0,0,0,0,0
	dc.b	$fc,$10,0,0,0,1,0,1
	dcb.w	2
	dc.b	'`',0,$7f,$ff,$80,0,0,0
	dc.b	$1a,0,$fe,0,0,0,0,0
	dcb.w	43
	dc.b	0,'H',0,0,0,0,0,3
	dcb.w	3
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,$90,0,$10,0,0
	dc.b	$fe,0,0,0,0,1,0,1
	dcb.w	2
	dc.b	'@',0,'p',0,$80,0,0,0
	dc.b	'*',0,'.',0,$10,0,0,0
	dcb.w	43
	dc.b	0,'H',0,0,0,0,0,3
	dc.b	2,' ',4,$10,0,0,$f8,$f
	dc.b	8,$80,$10,'@',0,0,$e0,'?'
	dc.b	'"',1,'A',1,0,0,$80,$fe
	dc.b	$8c,$c,4,8,0,0,0,$10
	dc.b	$c0,$80,'@',$10,0,0,'>',0
	dc.b	0,0,0,1,0,1,0,0
	dc.b	0,0,'@',0,'`',0,$80,0
	dc.b	0,0,$a,0,$e,0,$10,0
	dcb.w	44
	dc.b	0,'@',0,8,0,0,0,3
	dc.b	8,8,3,$e0,3,$f0,$f4,$17
	dc.b	'  ',$f,$80,$f,$c0,$d0,'_'
	dc.b	$80,$82,'>',0,$7f,1,'A}'
	dc.b	0,$10,$fb,$d3,$fd,$c7,4,4
	dc.b	' ',$10,$a0,$80,$80,0,'^',0
	dc.b	0,0,0,1,0,1,0,0
	dc.b	0,0,'@',0,'`',0,$80,0
	dc.b	0,0,$a,0,$e,0,$10,0
	dcb.w	44
	dc.b	0,'@',0,8,0,0,0,3
	dc.b	0,0,$f,$f8,$f,$f8,$e0,3
	dc.b	0,0,'?',$e0,'?',$e0,$80,$e
	dc.b	0,4,$ff,$83,$ff,$83,0,'8'
	dc.b	2,$10,$fb,$ef,$f9,$cf,4,0
	dc.b	'0',$10,$d0,$80,$c0,0,$e,0
	dc.b	0,0,0,1,0,1,0,0
	dc.b	0,0,'@',0,'`',0,$80,0
	dc.b	0,0,$a,0,$e,0,$10,0
	dcb.w	44
	dc.b	0,'H',0,8,0,0,0,3
	dc.b	0,0,' ',2,$1f,$fc,$df,$fd
	dc.b	0,0,$80,0,$7f,$f1,$7f,$f5
	dcb.w	2
	dc.b	$ff,$c7,$ff,$d7,0,0,0,0
	dc.b	$ff,$df,$ff,$ff,$10,$90,0,$80
	dc.b	$e0,0,$ee,0,0,0,0,1
	dc.b	0,1,0,0,0,0,'@',0
	dc.b	'`',0,$80,0,0,0,$a,0
	dc.b	$e,0,$10,0,0,0,0,0
	dcb.w	42
	dc.b	0,'@',0,0,0,0,0,$b
	dc.b	'@',0,'@',0,$1e,'<ž='
	dcb.w	2
	dc.b	'x',$f1,'x',$f5,0,0,0,$10
	dc.b	$e3,$ef,$e3,$c7,0,0,0,' '
	dc.b	$c7,$f1,$c7,$d1,0,$10,0,0
	dc.b	$e0,0,$ee,$80,0,0,0,1
	dc.b	0,1,0,0,0,0,'@',0
	dc.b	'`',0,$80,0,0,0,$a,0
	dc.b	$e,0,$10,0,0,0,0,0
	dcb.w	42
	dc.b	0,'H',0,8,0,0,0,3
	dc.b	'@',0,1,'@<',$1e,$80,$80
	dc.b	0,0,5,0,$f0,3,2,0
	dc.b	$14,0,1,0,$c1,$ef,$a,0
	dc.b	0,0,'(',$c,$83,$c0,$10,0
	dc.b	0,$10,0,0,$e0,0,$e,$80
	dc.b	0,0,0,1,0,1,0,0
	dc.b	0,0,'@',0,'`',0,$80,0
	dc.b	0,0,$a,0,$e,0,$10,0
	dcb.w	44
	dc.b	0,'@',0,0,0,0,0,$b
	dcb.w	2
	dc.b	'<',$1e,$81,$c0,0,0,0,0
	dc.b	$f0,3,7,$f8,0,0,2,0
	dc.b	$ff,$ef,5,0,0,0,0,$12
	dc.b	$83,$80,'8',$c,0,$10,0,0
	dc.b	$e0,0,$e,$80,0,0,0,1
	dc.b	0,1,0,0,0,0,'@',0
	dc.b	'`',0,$80,0,0,0,$a,0
	dc.b	$e,0,$10,0,0,0,0,0
	dcb.w	42
	dc.b	0,'@',0,0,0,0,0,$b
	dcb.w	3
	dc.b	$81,$c0,0,0,0,0,0,0
	dc.b	7,$f8,0,0,0,0,0,0
	dc.b	0,0,'D',0,'8',0,'8',0
	dc.b	0,$1e,0,$10,0,0,0,0
	dc.b	$e,$80,0,0,0,1,0,1
	dcb.w	2
	dc.b	'@',0,'`',0,$80,0,0,0
	dc.b	$a,0,$e,0,$10,0,0,0
	dcb.w	43
	dc.b	0,'@',0,3,0,3,0,8
	dc.b	2,0,$81,$c0,$81,$c0,0,0
	dc.b	8,0,7,0,7,0,0,0
	dc.b	' ',0,$1f,$e0,$1f,$e0,0,0
	dc.b	0,0,'D',$1e,0,$1e,0,0
	dc.b	0,$10,$e,0,$e,0,0,$80
	dc.b	0,0,0,1,0,1,0,0
	dc.b	0,0,'@',0,'`',0,$80,0
	dc.b	0,0,$a,0,$e,0,$10,0
	dcb.w	44
	dc.b	0,'H',0,8,0,0,0,3
	dc.b	0,0,2,' ',0,0,$80,0
	dc.b	0,0,8,$80,0,0,0,0
	dc.b	0,0,'"',0,0,0,0,0
	dc.b	'(',0,'(',0,0,0,$10,$1e
	dc.b	0,$90,0,$80,0,0,$e,0
	dc.b	0,0,0,1,0,1,0,0
	dc.b	0,0,'@',0,'`',0,$80,0
	dc.b	0,0,$a,0,$e,0,$10,0
	dcb.w	44
	dc.b	0,'H',0,$b,0,3,0,0
	dc.b	0,0,$c1,'A',$c0,1,0,$80
	dc.b	5,0,5,4,0,4,2,0
	dc.b	$14,0,$14,$10,0,$10,8,0
	dc.b	0,0,0,$1e,0,$1e,0,0
	dc.b	0,$90,$e,$80,$e,0,0,0
	dc.b	0,0,0,1,0,1,0,0
	dc.b	0,0,'@',0,'`',0,$80,0
	dc.b	0,0,$a,0,$e,0,$10,0
	dcb.w	44
	dc.b	0,'H',0,8,0,3,0,3
	dcb.w	2
	dc.b	$e0,3,$e0,3,0,0,0,0
	dc.b	$80,$e,$80,$e,0,0,0,0
	dc.b	0,'8',0,'8',0,0,0,0
	dc.b	0,$1e,0,$1e,0,$90,0,$80
	dc.b	$e,0,$e,0,0,0,0,1
	dc.b	0,1,0,0,0,0,'@',0
	dc.b	'`',0,$80,0,0,0,$a,0
	dc.b	$e,0,$10,0,0,0,0,0
	dcb.w	42
	dc.b	0,'@',0,$b,0,3,0,0
	dc.b	0,0,$f0,7,$f0,7,0,0
	dc.b	0,0,$c0,$1f,$c0,$1f,0,0
	dc.b	0,0,0,'|',0,'|',0,0
	dc.b	0,0,0,$1e,0,$1e,0,0
	dc.b	0,$10,$e,$80,$e,0,0,0
	dc.b	0,0,0,1,0,1,0,0
	dc.b	0,0,'@',0,'`',0,$80,0
	dc.b	0,0,$a,0,$e,0,$10,0
	dcb.w	44
	dc.b	0,'H',0,0,0,3,0,3
	dcb.w	2
	dc.b	$f8,$f,$f8,$f,0,0,0,0
	dc.b	$e0,'?',$e0,'?',0,0,0,0
	dc.b	$80,$fe,$80,$fe,0,0,0,0
	dc.b	2,$1e,2,$1e,0,$10,0,$80
	dc.b	$e,0,$e,0,0,0,0,1
	dc.b	0,1,0,0,0,0,'@',0
	dc.b	'`',0,$80,0,0,0,$a,0
	dc.b	$e,0,$10,0,0,0,0,0
	dcb.w	42
	dc.b	0,'H',0,0,0,3,0,3
	dcb.w	2
	dc.b	$ff,$ff,$fc,$1f,0,0,0,0
	dc.b	$ff,$ff,$f0,$7f,0,0,0,0
	dc.b	$ff,$ff,$c1,$ff,0,0,0,0
	dc.b	$ff,$ff,6,$1e,0,$90,0,0
	dc.b	$fe,0,$e,0,0,0,0,1
	dc.b	0,1,0,0,0,0,'@',0
	dc.b	'`',0,$80,0,0,0,$a,0
	dc.b	$e,0,$10,0,0,0,0,0
	dcb.w	42
	dc.b	0,'H',0,0,0,1,0,1
	dcb.w	2
	dc.b	$ff,$ff,$f8,$f,0,0,0,0
	dc.b	$ff,$ff,$e0,$1f,0,0,0,0
	dc.b	$ff,$ff,0,'~',0,0,0,0
	dc.b	$ff,$ff,0,$1e,0,$90,0,0
	dc.b	$fc,0,$c,0,0,0,0,1
	dc.b	0,1,0,0,0,0,'@',0
	dc.b	'p',0,$80,0,0,0,'*',0
	dc.b	'.',0,$10,0,0,0,0,0
	dcb.w	42
	dc.b	0,'$',0,0,0,0,0,0
	dcb.w	16
	dc.b	1,' ',0,0,0,0,0,0
	dc.b	0,0,0,1,0,1,0,0
	dc.b	0,0,'@',0,'`',0,$bf,$ff
	dc.b	0,0,$12,0,$1e,0,$e8,0
	dcb.w	44
	dc.b	0,'#',0,0,0,0,0,0
	dc.b	$ec,$80,$13,$7f,0,0,0,0
	dc.b	'OR',$ff,$d2,0,0,0,'-'
	dc.b	0,$b,0,$b,0,0,$ff,$f4
	dc.b	$f3,'"',$ff,$fd,0,0,0,0
	dc.b	$fe,' ',0,0,0,0,0,0
	dcb.w	5
	dc.b	$bf,$ff,$ff,$ff,'@',0,0,0
	dc.b	$e4,0,$fc,0,$10,0,0,0
	dcb.w	43
	dc.b	0,$10,0,0,0,0,0,0
	dcb.w	16
	dc.b	0,'@',0,0,0,0,0,0
	dcb.w	5
	dc.b	'@',0,$7f,$ff,0,0,0,0
	dc.b	8,0,$f8,0,0,0,0,0
	dcb.w	43
	dc.b	0,$c,0,0,0,0,0,0
	dcb.w	16
	dc.b	1,$80,0,0,0,0,0,0
	dcb.w	5
	dc.b	'?',$ff,'?',$ff,0,0,0,0
	dc.b	$f0,0,$f0,0,0,0,0,0
	dcb.w	43
	dc.b	0,3,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$fe,0,0,0,0,0,0,0
	dcb.w	29
	dc.b	0,4,0,8,0,$c,0,3
	dc.b	0,7,0,$b,0,$f,0,1
	dc.b	0,1,0,1,0,1,0,$80
	dc.b	0,'T',0,'*',0,0,0,0
	dcb.w	80
	dc.b	0,$f,0,0,0,$f,0,$80
	dc.b	$ff,$80,0,0,$ff,$80,0,0
	dcb.w	71
	dc.b	0,1,0,$7f,0,0,0,$7f
	dc.b	0,$10,$ff,$f0,0,0,$ff,$f0
	dcb.w	73
	dc.b	1,$ff,0,0,1,$ff,8,4
	dc.b	$ff,$fc,0,0,$ff,$fc,0,0
	dcb.w	72
	dc.b	7,$ff,0,0,7,$ff,0,$11
	dc.b	$ff,$ff,0,0,$ff,$ff,0,0
	dcb.w	39
zuend	end
