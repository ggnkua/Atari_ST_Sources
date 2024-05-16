
L012A	MACRO
	add.b	d2,d2
	bset	#0,d2
	bcc.s	\@
	move.b	d2,(a2)+
	moveq	#1,d2
\@:
	ENDM

L012C	MACRO
	add.b	d2,d2
	bcc.s	\@
	move.b	d2,(a2)+
	moveq	#1,d2
\@:
	ENDM

	TEXT
Begin:	move.l	4(a7),a3
	lea	l007c(pc),a7
	move.l	12(a3),d0
	add.l	20(a3),d0
	add.l	28(a3),d0
	addi.l	#$100,d0
	move.l	d0,-(a7)
	move.l	a3,-(a7)
	clr	-(a7)
	move	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7
	bsr	l005b
	move	#2,l0196
	moveq	#$a,d0
	bsr	l01a0
	move	d0,l007a
	moveq	#$4d,d0
	bsr	l01a0
	move	d0,l0070
	bsr	l0057
	move	#0,l01a7
	moveq	#$4e,d0
	bsr	l01a0
	bsr	l005a
	move.l	#l007b,l01b2
	moveq	#$6e,d0
	bsr	l01a0
	tst	d0
	beq	l005d
	moveq	#0,d0
	bsr	l0027
	move.l	a0,l0075
	moveq	#1,d0
	bsr	l0027
	move.l	a0,l0028
	move.l	l0075,l01b2
	moveq	#$36,d0
	bsr	l01a0
	moveq	#0,d0
	bsr	l0036
	move.l	#$1000,-(a7)
	move	#$48,-(a7)
	trap	#1
	addq.l	#6,a7
	bmi	l00ad
	move.l	d0,d4
	addi.l	#$c8,d0
	move.l	d0,l019b
	move.l	#-1,-(a7)
	move	#$48,-(a7)
	trap	#1
	addq.l	#6,a7
	bmi	l00ad
	add.l	d0,d4
	move.l	d4,l00ea
	bsr	l00e7
	move	#$19,-(a7)
	trap	#1
	addq	#2,a7
	move	d0,d7
	moveq	#$12,d0
	add	d7,d0
	bsr	l001b
	bsr	l000a
	moveq	#$22,d0
	bsr	l0063
	move.l	a0,l0188
	moveq	#$23,d0
	bsr	l0063
	move.l	a0,l0187
	moveq	#$24,d0
	bsr	l0063
	addq.l	#1,a0
	move.l	a0,l0189
	moveq	#$25,d0
	bsr	l0063
	addq.l	#1,a0
	move.l	a0,l018a
	moveq	#$26,d0
	bsr	l0063
	move.l	a0,l018b
	moveq	#$27,d0
	bsr	l0063
	move.l	a0,l018c
	moveq	#$28,d0
	bsr	l0063
	move.l	a0,l018d
	moveq	#$29,d0
	bsr	l0063
	move.l	a0,l018e
	moveq	#$16,d0
	bsr	l0063
	move.l	a0,l018f
	moveq	#8,d0
	bsr	l0063
	move.l	a0,l0190
	move.l	#$4ee,l0145
	lea	l0143(pc),a3
	bsr	l0140
	move.l	a3,l0147
	lea	l00ef(pc),a3
	bsr	l0140
	move.l	a3,l0148
	bsr	l00e7
	move.l	l0028,a0
	move	#6,d0
	bsr	l0064
	move.l	a0,l0029
l0000:	move.l	l0075,l01b2
	move	#0,l01a7
	move	#$29,l01a8
	move	l0076(pc),l01a9
	move	l0077(pc),l01aa
	move	l0079(pc),l01ab
	move	l0078(pc),l01ac
	moveq	#$2a,d0
	bsr	l01a0
l0001:	move.l	l0075(pc),l01b2
	move	#0,l01a7
	moveq	#$32,d0
	bsr	l01a0
	move	d0,l0071
	bsr	l000a
	move	l0071(pc),d0
	bsr	l0019
	move	l0071(pc),d0
	bsr	l002e
	move	l0071(pc),d0
	cmpi	#1,d0
	beq	l0037
	cmpi	#9,d0
	beq	l0021
	cmpi	#2,d0
	beq.s	l0002
	cmpi	#$a,d0
	beq	l0038
	cmpi	#$17,d0
	beq	l0020
	cmpi	#$2a,d0
	beq	l003c
	cmpi	#$2d,d0
	beq	l0022
	cmpi	#$2e,d0
	beq	l0172
	bra.s	l0001
l0002:	moveq	#$c,d0
	bsr	l001c
	beq.s	l0003
	move	#$fff,l0115
	bra.s	l0006
l0003:	moveq	#$f,d0
	bsr	l001c
	beq.s	l0004
	move	#$1fff,l0115
	bra.s	l0006
l0004:	moveq	#$d,d0
	bsr	l001c
	beq.s	l0005
	move	#$2fff,l0115
	bra.s	l0006
l0005:	move	#$7fff,l0115
l0006:	moveq	#$1a,d0
	bsr	l001c
	beq.s	l0007
	move	#-1,l00fc
	bra.s	l0008
l0007:	clr	l00fc
l0008:	moveq	#$1e,d0
	bsr	l001c
	beq.s	l0009
	clr	l00fb
	bra	l0012
l0009:	move	#-1,l00fb
	bra	l0012
l000a:	move.b	l0089,d2
	moveq	#$12,d0
	bsr	l001c
	beq.s	l000c
	cmpi.b	#$41,d2
	bne.s	l000b
	rts
l000b:	move.l	#'A:\*',l0089
	move	#'.*',l008b
	clr	l008c
	rts
l000c:	move	#$13,d0
	bsr	l001c
	beq.s	l000e
	cmpi.b	#$42,d2
	bne.s	l000d
	rts
l000d:	move.l	#'B:\*',l0089
	move	#'.*',l008b
	clr	l008c
	rts
l000e:	move	#$14,d0
	bsr	l001c
	beq.s	l0010
	cmpi.b	#$46,d2
	bne.s	l000f
	rts
l000f:	move.l	#'F:\*',l0089
	move	#'.*',l008b
	clr	l008c
	rts
l0010:	move	#$15,d0
	bsr	l001c
	cmpi.b	#$44,d2
	bne.s	l0011
	rts
l0011:	move.l	#$443a5c2a,l0089
	move	#$2e2a,l008b
	clr	l008c
	rts
l0012:	moveq	#4,d0
	bsr	l001c
	beq.s	l0013
	clr	l0196
	clr	l00fd
	move	#-1,l00fe
	bra.s	l0015
l0013:	moveq	#5,d0
	bsr	l001c
	beq.s	l0014
	move	#-1,l0196
	clr	l0195
	clr	l00fd
	clr	l00fe
	move	#-1,l00fc
	bra.s	l0015
l0014:	moveq	#6,d0
	bsr	l001c
	beq.s	l0015
	move	#-1,l00fd
	clr	l0196
	clr	l00fe
	move	#-1,l00fc
	clr.b	l0089
	bsr	l000a
	clr.b	l008a
	clr	l0195
l0015:	move	#$22,d0
	bsr	l001c
	beq.s	l0016
	move	#$22,d0
	bsr.s	l0019
	move	#-1,l0192
	move	#$22,d0
	bsr	l001e
	bra.s	l0017
l0016:	clr	l0192
	move	#$22,d0
	bsr.s	l001d
l0017:	move	#$23,d0
	bsr.s	l001c
	beq.s	l0018
	move	#$23,d0
	bsr.s	l0019
	move	#-1,l0193
	move	#$23,d0
	bsr.s	l001e
	bra	l007d
l0018:	clr	l0193
	move	#$23,d0
	bsr.s	l001d
	bra	l007d
l0019:	move	d0,l0071
	move.l	l0075,a0
l001a:	mulu	#$18,d0
	add.l	d0,a0
	lea	10(a0),a0
	bclr	#0,1(a0)
	rts
l001b:	bsr.s	l001f
	bset	#0,1(a0)
	rts
l001c:	bsr.s	l001f
	btst	#0,1(a0)
	rts
l001d:	move	d0,l0071
	bsr.s	l001f
	bclr	#3,1(a0)
	rts
l001e:	move	d0,l0071
	bsr.s	l001f
	bset	#3,1(a0)
	rts
l001f:	move.l	l0075(pc),a0
	mulu	#$18,d0
	add.l	d0,a0
	lea	10(a0),a0
	rts
l0020:	bsr	l0066
	bra	l0001
l0021:	bsr	l0057
	move.l	l0028,l01b2
	moveq	#$36,d0
	bsr	l01a0
	move.l	l0028,l01b2
	move	#0,l01a7
	move	#6,l01a8
	move	l002a,l01a9
	move	l002b,l01aa
	move	l002d,l01ab
	move	l002c,l01ac
	moveq	#$2a,d0
	bsr	l01a0
	move.l	l0028,l01b2
	move	#0,l01a7
	moveq	#$32,d0
	bsr	l01a0
	move	d0,l0071
	move.l	l0028,a0
	bsr	l0057
	bsr	l001a
	bra	l0000
l0022:	move.l	l019b,l0191
	bsr	l00e6
	bsr	l00e8
	move	#3,l01a7
	move.l	#l0101,l01b2
	moveq	#$34,d0
	bsr	l01a0
	cmpi	#1,d0
	beq.s	l0023
	cmpi	#2,d0
	beq.s	l0025
	bra	l0001
l0023:	lea	l00f5(pc),a0
	bsr	l0065
	tst	d0
	beq	l00b0
	bsr	l00e6
	bsr	l00e2
	bsr	l00e8
	pea	l00f5
	move	#$41,-(a7)
	trap	#1
	addq.l	#6,a7
l0024:	bsr	l00aa
	bra	l0001
l0025:	lea	l00f5(pc),a0
	bsr	l0065
	tst	d0
	beq	l00b0
	bsr	l00e6
	bsr	l00e2
	bsr	l00e8
	lea	l00f5(pc),a0
	lea	l00f7(pc),a1
	movem.l	a1,-(a7)
l0026:	move.b	(a0)+,(a1)+
	bne.s	l0026
	movem.l	(a7)+,a0
	bsr	l0065
	tst	d0
	beq	l00b0
	pea	l00f7
	pea	l00f5
	clr	-(a7)
	move	#$56,-(a7)
	trap	#1
	lea	12(a7),a7
	bra.s	l0024
l0027:	move	#0,l01a7
	move	d0,l01a8
	move.l	#$700002,l01a3
	move.l	#$10000,l01a4
	move	#1,l01a5
	move.l	#l01a1,d1
	move	#$c8,d0
	trap	#2
	move	l01b0,d0
	move.l	l01b4,a0
	rts
l0028:	dcb	2,0
l0029:	dcb	2,0
l002a:	dcb	1,0
l002b:	dcb	1,0
l002c:	dcb	1,0
l002d:	dcb	1,0
l002e:	move.l	l0075,l01b2
	move	d0,l01a7
	move	d0,l01a8
	move	l0076,l01a9
	move	l0077,l01aa
	move	l0079,l01ab
	move	l0078,l01ac
	moveq	#$2a,d0
	bsr	l01a0
	rts
l002f:	movem.l	a0-a6/d0-d7,-(a7)
	bsr	l0057
	move.l	l0075,l01b2
	move	#0,l01a7
	move	#$29,l01a8
	move	l0076,l01a9
	move	l0077,l01aa
	move	l0079,l01ab
	move	l0078,l01ac
	moveq	#$2a,d0
	bsr	l01a0
	movem.l	(a7)+,a0-a6/d0-d7
	rts
l0030:	lea	l0186,a1
	moveq	#$30,d1
	moveq	#3,d2
l0031:	move.l	(a1)+,a0
	moveq	#6,d0
	bsr.s	l0033
	dbf	d2,l0031
	lea	l018d(pc),a0
	moveq	#2,d0
	bsr.s	l0033
	lea	l0189(pc),a1
	moveq	#$5f,d1
	moveq	#1,d2
l0032:	move.l	a1,a0
	moveq	#$c,d0
	bsr.s	l0033
	addq.l	#4,a1
	dbf	d2,l0032
	moveq	#$21,d0
	bra	l002e
l0033:	move.l	(a0),a0
l0034:	move.b	d1,(a0)+
	subq	#1,d0
	bne.s	l0034
	rts
l0035:	lea	l018e(pc),a0
	moveq	#6,d0
	moveq	#$30,d1
	bsr.s	l0033
	moveq	#$29,d0
	bra	l002e
l0036:	move	d0,l01a7
	clr	l01a8	;z
	clr	l01a9
	move	#9,l01aa
	clr	l01ab
	move	l0076,l01ac
	move	l0077,l01ad
	move	l0078,l01ae
	move	l0079,l01af
	moveq	#$33,d0
	bsr	l01a0
	rts
l0037:	moveq	#3,d0
	bsr.s	l0036
	moveq	#$13,d0
	bsr	l01a0
	move.l	l0147,a3
	bsr	l014a
	move.l	l0148,a3
	bsr	l014a
	clr	-(a7)
	move	#$4c,-(a7)
	trap	#1
l0038:	move	#-1,l0194
	moveq	#$22,d0
	bsr	l0019
	moveq	#$23,d0
	bsr	l0019
	bsr	l00e6
	move.l	#$2a2e2a00,d0
	move.l	d0,l00f5
	move.l	d0,l00f7
	tst	l006d
	bne.s	l0039
	clr	l0089
	bsr	l000a
	move	#-1,l006d
l0039:	moveq	#0,d0
	move.l	#l00f5,a0
	bsr	l0065
	tst	d0
	beq	l0001
	move.l	l019b,l019e
	bsr	l00e6
	bsr	l00e2
	bsr	l00d9
	tst.l	d0
	bmi	l005e
	move.l	l019e,a0
	moveq	#0,d0
	moveq	#0,d1
	add.l	d6,a0
	subq.l	#4,a0
	move.l	a0,a4
	movep	0(a0),d0
	movep	1(a0),d1
	add.l	d0,d1
	cmpi	#-$6067,d1
	beq.s	l003a
	subq.l	#4,a0
	move.l	a0,a4
	movep	0(a0),d0
	movep	1(a0),d1
	add.l	d0,d1
	cmpi	#-$6067,d1
	beq.s	l003a
	bra	l005c
l003a:	bsr	l003d
	bsr	l0030
	move.l	d6,a0
	move.l	l018c,a2
	bsr	l00cb
	moveq	#$2a,d0
	bsr	l001d
	move.l	l0189(pc),a0
	lea	l00f5(pc),a1
l003b:	move.b	(a1)+,(a0)+
	bne.s	l003b
	moveq	#$21,d0
	bsr	l002e
	bsr	l0066
	bra	l0001
l003c:	lea	l00f5(pc),a0
	bsr	l0065
	tst	d0
	beq	l0001
	clr	-(a7)
	pea	l00f5(pc)
	move	#$3c,-(a7)
	trap	#1
	addq	#8,a7
	move	d0,l0100
	tst	d0
	bmi	l005e
	pea	(a4)
	move.l	d6,-(a7)
	move	l0100(pc),-(a7)
	move	#$40,-(a7)
	trap	#1
	lea	12(a7),a7
	move	l0100(pc),-(a7)
	move	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	moveq	#$2a,d0
	bsr	l001e
	bsr	l0030
	moveq	#$21,d0
	bsr	l002e
	bra	l0001
l003d:	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1
	move.l	d0,2(a7)
	move.l	a4,a0
	lea	4(a4),a2
	move.l	-(a0),d6
	move.l	-(a0),d2
	sub.l	d2,a2
	move.l	a2,a4
	add.l	d6,a2
	moveq	#0,d0
	lea	$ffff8240.w,a6
	move	(a6),d7
l003e:	move.b	-(a0),d0
	beq.s	l003e
l003f:	moveq	#0,d2
	cmp.l	a2,a0
	bgt	l005f
	bsr	l004c
	bcs.s	l0042
	move.b	-(a0),d2
l0040:	move.b	d2,-(a2)
	bra.s	l0044
l0041:	moveq	#$f,d4
	moveq	#2,d3
	bsr	l004f
	bne.s	l004a
	move	d4,d2
	bra.s	l0040
l0042:	bsr.s	l004c
	bcc.s	l0046
	bsr.s	l004c
	bcc.s	l0041
	bsr.s	l004c
	bcs.s	l0043
	moveq	#1,d1	;2
	bsr	l0052bis
	exg	d2,d1
	addq	#1,d2
	bset	d1,d2
	bra.s	l0040
l0043:	bsr.s	l004c
	bcs.s	l0045
	moveq	#$f,d4
	move	#3,d3
	bsr.s	l004f
	bne.s	l004a
	move.b	(a2),-(a2)
l0044:	neg	(a6)
	move	d7,(a6)
	cmp.l	a2,a4
	blt.s	l003f
	move	d7,(a6)
	trap	#1
	addq	#6,a7
	rts
l0045:	moveq	#4,d3
	bra.s	l0049
l0046:	bsr.s	l004c
	bcs	l0056	;z
	moveq	#1,d1
l0047:	lsr.b	#1,d0
	bne.s	l0048
	move.b	-(a0),d0
	roxr.b	#1,d0
l0048:	addx	d2,d2
	dbf	d1,l0047
	move	d2,d1
	beq.s	l0055
	addq	#1,d1
	subq	#1,d1
	bsr.s	l0052
	move	d2,d3
l0049:	bsr.s	l004e
l004a:	move.l	a2,a1
	add.l	d2,a1
l004b:	move.b	-(a1),-(a2)
	dbf	d3,l004b
	bra.s	l0044
l004c:	lsr.b	#1,d0
	bne.s	l004d
	move.b	-(a0),d0
	roxr.b	#1,d0
l004d:	rts

l004e:	moveq	#0,d4
l004f:	moveq	#0,d2

	lsr.b	#1,d0
	bne.s	l0050
	move.b	-(a0),d0
	roxr.b	#1,d0
l0050:	addx	d2,d2

	lsr.b	#1,d0
	bne.s	l0051
	move.b	-(a0),d0
	roxr.b	#1,d0
l0051:	addx	d2,d2

	move	d2,d1
	addq	#1,d1
	add	d1,d1
	add	d1,d1
	subq	#1,d1
	eor.b	d1,d4
	beq.s	end52
	moveq	#3,d1
l0052:	moveq	#0,d2
l0053:
	lsr.b	#1,d0
	bne.s	l0054
	move.b	-(a0),d0
	roxr.b	#1,d0
l0054:	addx	d2,d2

l0052bis:	lsr.b	#1,d0
	bne.s	l0054bis
	move.b	-(a0),d0
	roxr.b	#1,d0
l0054bis:	addx	d2,d2

	dbf	d1,l0053
end52	rts

l0055:	bsr.s	l004e
	move	d2,d3
	moveq	#1,d2
	bra.s	l004a

l0056:	moveq	#1,d3
	move.b	-(a0),d2
	bra.s	l004a
Cls_txt:	dc.b	$1b,'E',0
	even
l0057:	bsr.s	l005b
	movem.l	a0/d0-d1,-(a7)
	pea	Cls_txt(pc)
	move	#9,-(a7)
	trap	#1
	addq	#6,a7
	bsr.s	l005a
	movem.l	(a7)+,d0-d1/a0
	rts
l005a:	movem.l	d0-d2/a0-a3,-(a7)
	dc.w	$A000
	dc.b	' h'
	dc.b	$00,$08,'BP'
	dc.w	$A009
	dc.b	'L',$DF
	dc.b	$0F,$07,'Nu'
l005b:	dc.b	'H',$E7
	asr	10(a0,a2.w)
	movem.l	(a7)+,a0-a3/d0-d2
	rts
l005c:	move	#1,l01a7
	move.l	#l0072,l01b2
	moveq	#$34,d0
	bsr	l01a0
	bra	l0001
l005d:	move	#1,l01a7
	move.l	#l0073,l01b2
	moveq	#$34,d0
	bsr	l01a0
	bra	l0037
l005e:	move	l0100(pc),-(a7)
	move	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	move	#1,l01a7
	move.l	#l0102,l01b2
	moveq	#$34,d0
	bsr	l01a0
	cmpi.b	#1,d0
	beq	l0038
	bra	l0001
l005f:	move	d7,(a6)
	trap	#1
	addq.l	#6,a7
	move	#1,l01a7
	move.l	#l0074,l01b2
	moveq	#$34,d0
	bsr	l01a0
	bra	l0001
l0060:	movem.l	a0-a2/d0-d4,-(a7)
	moveq	#0,d3
	moveq	#0,d1
	moveq	#$30,d2
	lea	l006f(pc),a1
	move	d0,d1
	lsl	#2,d1
	add.l	d1,a1
	moveq	#0,d1
l0061:	moveq	#0,d4
	subq.l	#4,a1
	move.l	(a1),d3
	move.b	(a0),d4
	beq.s	l0062
	sub	d2,d4
	mulu	d3,d4
	add.l	d4,d1
	addq	#1,a0
	subq	#1,d0
	bne.s	l0061
l0062:	move.l	d1,l006e
	lea	l0190(pc),a0
	moveq	#4,d0
	moveq	#$30,d1
	bsr	l0033
	movem.l	(a7)+,a0-a2/d0-d4
	rts
l0063:	move.l	l0075(pc),a0
l0064:	mulu	#$18,d0
	add.l	d0,a0
	lea	12(a0),a0
	move.l	(a0),a1
	move.l	(a1),a0
	rts
l0065:	bsr	l00e8
	move.l	#l0089,l01b2
	move.l	a0,l01b3
	moveq	#$5a,d0
	bsr	l01a0
	bsr	l002f
	move	l01b1,d0
	rts
l0066:	move.b	l0089(pc),d0
	subi.b	#$40,d0
	ext	d0
	move	d0,-(a7)
	bsr.s	l006a
l0067:	dcb	4,0
l0068:	dcb	2,0
l0069:	dcb	2,0
l006a:	move	#$36,-(a7)
	trap	#1
	addq.l	#8,a7
	move.l	l0069(pc),d0
	move.l	l0068(pc),d1
	mulu	d1,d0
	move.l	l0067(pc),d1
	mulu	d1,d0
	move.l	d0,a0
	movem.l	d0,-(a7)
	move.l	l018f(pc),a2
	moveq	#8,d7
	bsr	l00cc
	moveq	#$16,d0
	bsr	l002e
	movem.l	(a7)+,d0
	rts
l006b:	movem.l	a0-a6/d0-d7,-(a7)
	move.l	l019b(pc),a0
	move.l	l00ea(pc),d0
	sub.l	a0,d0
	lsr.l	#3,d0
	subq.l	#4,d0
	moveq	#0,d1
l006c:	move.l	d1,(a0)+
	move.l	d1,(a0)+
	subq.l	#1,d0
	bne.s	l006c
	movem.l	(a7)+,a0-a6/d0-d7
	rts
l006d:	dcb	1,0
l006e:	dcb	2,0
l006f:	dcb	1,0
	dc.b	$00,$01,$00,$00,$00,$0a,$00,$00
	dc.b	$00,'d',$00,$00,$03,$E8,$00,$00
	dc.b	$27,$10,$00,$01,$86,$a0
l0070:	dcb	1,0
l0071:	dcb	1,0
	dc.b	$1B,'E',0
	dc.b	'[1] The Pompey Pirates Packer | | The FINAL Version 1.0 | |100% m/code by J.P.M 1990 | |][ WOW ]',0
l0072:	dc.b	'[1][This file is not packed | with the POMPEY PACKER][ Ughh ]',$00
	dc.b	'[2] Do you wish to save | the unpacked file.][ YES | NO ]',$00
	dc.b	'[2] Use the old | filename.][ YES | NO ]',0
l0073:	dc.b	'[2] Resource file missing! | Please rectify this. ][ OKAY ]',$00
l0074:	dc.b	'[3] Whoops.  That file is bad. |It collided with depack data.][ Damn ]',$00
l0075:	DCB	2,0
l0076:	dc.b	$00,'x'
l0077:	dc.b	$00,'('
l0078:	dc.b	$00,$0A
l0079:	DCB	1,0
l007a:	DCB	1,0
l007b:	dc.b	'pompey2.rsc',0
	even
	dcb	255,0
l007c:	dcb	1,0
l007d:	move	#$2a,d0
	bsr	l001e
	clr	l0194
	clr	l006d
	clr.l	l00f1
	clr.l	l00f3
	move.l	l019b(pc),l0191
	move.l	l0190(pc),a0
	moveq	#4,d0
	bsr	l0060
	move.l	l006e(pc),l00f8
	bsr	l006b
	move	#-1,l00fa
l007e:	bsr	l00e6
	bsr	l00e8
	tst	l00fe
	bne	l0087
	tst	l00fd
	bne	l008d
	move	#-1,l00fc
	clr	l0195
	move.l	l019b(pc),l0191
	move.l	l019b(pc),l0198
	bsr	l0057
l007f:	bsr	l00e8
	lea	l00f5(pc),a0
	move.l	#l0089,l01b2
	move.l	a0,l01b3
	moveq	#$5a,d0
	bsr	l01a0
	move	l01b1,d0
	bsr	l0057
	tst	d0
	beq.s	l0082
	move.l	l0198(pc),a0
	lea	l0089(pc),a1
l0080:	move.b	(a1)+,d0
	move.b	d0,(a0)+
	cmpi.b	#$2a,d0
	bne.s	l0080
	lea	l00f5(pc),a1
l0081:	move.b	(a1)+,(a0)+
	bne.s	l0081
	move.l	a0,l0198
	addq	#1,l0197
	bra.s	l007f
l0082:	clr.l	l00f1
	clr.l	l00f3
	bsr	l002f
	addq	#1,l0197
	move.l	l0198,d0
	btst	#0,d0
	beq.s	l0083
	addq.l	#1,d0
l0083:	move.l	d0,l019b
	move.l	l0191(pc),l0198
l0084:	subq	#1,l0197
	tst	l0197
	beq	l00a9
	move.l	l0198(pc),a1
	lea	l0089(pc),a0
l0085:	move.b	(a1)+,d0
	move.b	d0,(a0)+
	cmpi.b	#$2a,d0
	bne.s	l0085
	move.b	#$2e,(a0)
	move.b	#$2a,1(a0)
	clr.b	2(a0)
	lea	l00f5(pc),a0
l0086:	move.b	(a1)+,(a0)+
	bne.s	l0086
	move.l	a1,l0198
	bsr	l00e6
	bsr	l00e2
	clr	-(a7)
	pea	l00f5(pc)
	move	#$4e,-(a7)
	trap	#1
	addq	#8,a7
	tst	d0
	bmi	l00a9
	bsr	l00e7
	bsr	l00b1
	bsr	l009e
	bsr	l00aa
	bsr	l006b
	bra.s	l0084
l0087:	lea	l00f5(pc),a0
	bsr	l0065
	tst	d0
	beq	l00b0
	bsr	l00e6
	bsr	l00e2
	clr	-(a7)
	pea	l00f5(pc)
	move	#$4e,-(a7)
	trap	#1
	addq.l	#8,a7
	tst	d0
	bmi	l00a9
	bsr	l00e7
	lea	l00f7(pc),a0
	lea	l00f5(pc),a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	bsr	l00e6
	bsr	l00e2
	bsr	l00b1
	tst	l0195
	bne	l00a9
	tst	l00fb
	bne.s	l0088
	clr.l	l00f8
l0088:	clr.l	l00f1
	clr.l	l00f3
	bsr	l009e
	bra	l00a9
l0089:	dc.b	'A:\'
l008a:	dc.b	'*'
l008b:	dc.b	'.*'
l008c:	DCB	31,0
l008d:	clr.l	l00f1
	clr.l	l00f3
	moveq	#0,d0
	move.l	d0,l00f8
	bsr	l00c1
	bsr	l00aa
	move.l	l019b(pc),a0
	move.l	a0,l009d
	bsr	l009c
	bmi	l009b
	move.l	l0199,a4
	lea	30(a4),a4
	move.l	l009d,a0
	move.l	a0,a2
	bra.s	l0091
l008e:	move.l	a4,a3
	move.l	l0089(pc),d0
	lsr	#8,d0
	move.b	d0,(a0)+
	swap	d0
	move.b	d0,(a0)+
	lsr	#8,d0
	move.b	d0,(a0)+
l008f:	move.b	(a3)+,(a0)+
	bne.s	l008f
	move.b	#$5c,-1(a0)
	clr.b	(a0)+
	move.l	a0,a2
l0090:	move	#$4f,-(a7)
	trap	#1
	addq.l	#2,a7
l0091:	tst	d0
	bne.s	l0092
	btst	#4,-9(a4)
	beq.s	l0090
	move.l	a2,a0
	bra.s	l008e
l0092:	lea	l0089(pc),a1
	move.b	(a1)+,(a2)+
	move.b	(a1)+,(a2)+
	move.b	(a1)+,(a2)+
	move.b	(a1)+,(a2)+
	move.b	#$2a,(a2)
	move.l	l0191(pc),a0
	move.l	a0,l009d
	move.l	a2,d0
	addq.l	#6,d0
	btst	#0,d0
	beq.s	l0093
	addq.l	#1,d0
l0093:	move.l	d0,l019b
	bsr.s	l0099
	tst	d7
	beq.s	l0094
	bsr.s	l0097
l0094:	bsr	l00aa
	bsr	l00b7
	tst	l00f9
	beq.s	l0096
l0095:	bsr.s	l0097
	tst	d7
	bne.s	l0095
	bra.s	l0094
l0096:	bsr	l009e
	bsr	l006b
	bra.s	l0094
l0097:	clr	l00f9
	move.l	l009d(pc),a0
l0098:	move.b	(a0)+,d0
	bne.s	l0098
	cmpi.b	#$2a,(a0)
	beq.s	l009b
	move.l	a0,l009d
l0099:	move.l	a0,-(a7)
	move	#$3b,-(a7)
	trap	#1
	addq.l	#6,a7
	tst	d0
	bmi.s	l009a
	bsr	l00e8
	clr	-(a7)
	pea	l010b(pc)
	move	#$4e,-(a7)
	trap	#1
	addq.l	#8,a7
	tst	d0
	bne.s	l009a
	moveq	#0,d7
	move	#-1,l00fa
	rts
l009a:	move	#-1,d7
	rts
l009b:	clr.b	l008a
	bsr	l00aa
	bra	l00a9
l009c:	bsr	l00e8
	move	#$10,-(a7)
	pea	l010b(pc)
	move	#$4e,-(a7)
	trap	#1
	addq.l	#8,a7
	tst	d0
	rts
l009d:	dcb	2,0
l009e:	bsr	l00e9
	bsr	l00d9
	cmpi	#3,d0
	bne.s	l009f
	rts
l009f:	tst.l	d0
	bmi	l00af
	bsr	l005b
	bsr	l010d
	bsr	l005a
	tst	l0146
	bne	l00a9
	bsr	l00eb
	move.l	a2,d0
	addi.l	#$c,d0
	move.l	l019f(pc),a0
	move.l	d0,l019d
	sub.l	l00f8(pc),d0
	move.l	d0,(a0)+
	move.l	l019c(pc),d0
	sub.l	l00f8(pc),d0
	move.l	d0,(a0)+
	move.l	#$504f5049,(a0)+
	move.l	l019d(pc),d6
	cmpi	#0,l00fc
	bne.s	l00a1
	lea	l00f6(pc),a1
	move.l	l018a(pc),a2
l00a0:	move.b	(a1)+,(a2)+
	bne.s	l00a0
	moveq	#$25,d0
	bsr	l002e
l00a1:	move.l	l019d(pc),a0
	move.l	l018c(pc),a2
	bsr	l00cb
	moveq	#$27,d0
	bsr	l002e
	move.l	l019d(pc),d0
	move.l	l019c(pc),d2
	bsr	l00c3
	bpl.s	l00a2
	moveq	#0,d1
l00a2:	move.l	d1,a0
	move.l	l018d(pc),a2
	moveq	#2,d7
	bsr	l00cc
	moveq	#$28,d0
	bsr	l002e
	move.l	l019d(pc),d0
	move.l	l019c(pc),d1
	cmp.l	d0,d1
	bgt.s	l00a3
	rts
l00a3:	bsr	l0066
	tst	l00fc
	bne.s	l00a4
	move.l	l019d(pc),d1
	cmp.l	d0,d1
	blt.s	l00a5
	move	#1,l01a7
	move.l	#l0106,l01b2
	moveq	#$34,d0
	bsr	l01a0
	cmpi.b	#2,d0
	beq.s	l00a3
	rts
l00a4:	clr	-(a7)
	pea	l00f5(pc)
	bra.s	l00a6
l00a5:	clr	-(a7)
	pea	l00f6(pc)
l00a6:	move	#$3c,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.l	d0
	bmi	l00ae
	move	d0,l0100
	move	d0,d6
	move.l	l019d,d1
	tst	l00fb
	bne.s	l00a7
	lea	l014b,a0
	move.l	#$1ce,d0
	move.l	l019c,d2
	sub.l	d1,d2
	move.l	d0,l014c
	move.l	d1,l014d
	move.l	d2,l014e
	subi.l	#$1c,2(a0)
	bsr	l00ab
	tst.l	d0
	bmi	l00af
	move.l	l019b,a0
	move.l	d1,d0
	bsr	l00ab
	tst.l	d0
	bmi	l00af
	lea	l010c(pc),a0
	moveq	#4,d0
	bsr	l00ab
	tst.l	d0
	bmi	l00af
	bra.s	l00a8
l00a7:	move.l	l019b(pc),a0
	move.l	d1,d0
	move.l	a0,a1
	bsr	l00ab
	tst.l	d0
	bmi	l00af
l00a8:	move	l0100(pc),-(a7)
	move	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	bmi	l00af
	rts
l00a9:	clr.l	l00f8
	clr	l0197
	clr	l00fa
	clr	l00fc
	clr	l00f9
	clr	l00fe
	clr	l0146
	clr	l0195
	move.l	l0191(pc),l019b
	bsr	l0030
	move	#$22,d0
	bsr	l001d
	move	#$23,d0
	bsr	l001d
	bsr	l0035
	bra	l0000
l00aa:	clr.l	d0
	lea	l00f5(pc),a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	lea	l00f6(pc),a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	#$2a2e2a00,l00f5
	move.l	#$2a2e2a00,l00f7
	bra	l0030
l00ab:	move.l	a0,-(a7)
	btst	#0,d0
	beq.s	l00ac
	addq.l	#1,d0
l00ac:	move.l	d0,-(a7)
	move	d6,-(a7)
	move	#$40,-(a7)
	trap	#1
	lea	12(a7),a7
	rts
l00ad:	move	#1,l01a7
	move.l	#l0105,l01b2
	moveq	#$34,d0
	bsr	l01a0
	bra.s	l00af
	move	#1,l01a7
	move.l	#l0104,l01b2
	moveq	#$34,d0
	bsr	l01a0
	bra.s	l00af
	bra.s	l00af
l00ae:	move	#1,l01a7
	move.l	#l0103,l01b2
	moveq	#$34,d0
	bsr	l01a0
l00af:	move	l0100(pc),-(a7)
	move	#$3e,-(a7)
	trap	#1
	addq	#4,a7
	move	#1,l01a7
	move.l	#l0102,l01b2
	moveq	#$34,d0
	bsr	l01a0
	cmpi.b	#1,d0
	beq	l007e
	bra	l00a9
l00b0:	move	#1,l01a7
	move.l	#l0107,l01b2
	moveq	#$34,d0
	bsr	l01a0
	bra	l00a9
l00b1:	lea	l00f5,a2
	lea	l010a,a0
	move.l	a0,a1
l00b2:	cmpi.b	#$2e,(a2)+
	bne.s	l00b2
	moveq	#0,d1
	moveq	#0,d1
	movep	0(a2),d1
	movep	1(a2),d0
	add.l	d0,d1
	moveq	#2,d0
l00b3:	cmp	(a0)+,d1
	beq.s	l00b4
	dbf	d0,l00b3
	bra.s	l00b5
l00b4:	clr	l00fb
	bra.s	l00b6
l00b5:	move	#-1,l00fb
l00b6:	rts
l00b7:	movem.l	a0-a6/d0-d7,-(a7)
l00b8:	tst	l00fa
	bne.s	l00b9
	bsr	l00e8
	move	#$4f,-(a7)
	trap	#1
	addq.l	#2,a7
	tst	d0
	bpl.s	l00b9
	move	#-1,l00f9
	bra.s	l00c0
l00b9:	lea	l00f5,a1
	lea	l00f7,a3
	move.l	a1,a2
	move.l	l0199,a0
	lea	30(a0),a0
l00ba:	move.b	(a0),(a1)+
	move.b	(a0)+,(a3)+
	bne.s	l00ba
	lea	l010a,a0
	move.l	a0,a1
l00bb:	cmpi.b	#$2e,(a2)+
	bne.s	l00bb
	moveq	#0,d0
	moveq	#0,d1
	movep	0(a2),d1
	movep	1(a2),d0
	add	d0,d1
	cmpi.l	#$9f50,d1
	bne.s	l00bc
	clr	l00fa
	bra.s	l00b8
l00bc:	moveq	#2,d0
l00bd:	cmp	(a0)+,d1
	beq.s	l00be
	dbf	d0,l00bd
	bra.s	l00bf
l00be:	clr	l00fb
	bra.s	l00c0
l00bf:	move	#-1,l00fb
l00c0:	clr	l00fa
	movem.l	(a7)+,a0-a6/d0-d7
	rts
l00c1:	pea	l0089(pc)
	move	#$3b,-(a7)
	trap	#1
	addq.l	#6,a7
	tst	d0
	beq.s	l00c2
	move	#1,l01a7
	move.l	#l00e5,l01b2
	moveq	#$34,d0
	bsr	l01a0
	moveq	#3,d0
l00c2:	rts
l00c3:	move.l	d2,-(a7)
	moveq	#$64,d1
	move	d0,d2
	move	d1,d3
	swap	d0
	swap	d1
	mulu	d2,d1
	mulu	d3,d0
	mulu	d3,d2
	add	d1,d0
	swap	d0
	clr	d0
	add.l	d2,d0
	move.l	(a7)+,d1
	bsr.s	l00c4
	moveq	#$64,d1
	sub.l	d0,d1
	rts
l00c4:	cmp.l	#$ffff,d1
	bls.s	l00c9
	cmp.l	d0,d1
	beq.s	l00c5
	bls.s	l00c6
	move.l	d0,d1
	moveq	#0,d0
	rts
l00c5:	moveq	#0,d1
	moveq	#1,d0
	rts
l00c6:	move.l	d1,d2
	clr	d2
	swap	d2
	addq.l	#1,d2
	move.l	d0,d3
	move.l	d1,d4
	move.l	d2,d1
	bsr.s	l00c9
	move.l	d4,d1
	divu	d2,d1
	divu	d1,d0
	andi.l	#$ffff,d0
l00c7:	move.l	d4,d1
	move.l	d4,d2
	swap	d2
	mulu	d0,d1
	mulu	d0,d2
	swap	d2
	add.l	d2,d1
	sub.l	d3,d1
	bhi.s	l00c8
	neg.l	d1
	cmp.l	d1,d4
	bhi.s	l00ca
	addq.l	#1,d1
	bra.s	l00c7
l00c8:	subq.l	#1,d1
	bra.s	l00c7
l00c9:	movem	d2/d0,-(a7)
	clr	d0
	swap	d0
	divu	d1,d0
	move	d0,d2
	move	(a7)+,d0
	divu	d1,d0
	swap	d0
	moveq	#0,d1
	move	d0,d1
	move	d2,d0
	swap	d0
	move	(a7)+,d2
l00ca:	rts

l00cb:	moveq	#6,d7
l00cc:	movem.l	a0-a3/d0-d7,-(a7)
	bsr.s	l00cf
	lea	l00ce(pc),a0
	move	l00cd(pc),d0
	beq.s	Endx
	add.l	d7,a2
	sub	d0,d7
	subq	#1,d0
	moveq	#0,d1
Loopx:	move.b	0(a0,d0),d1
	add	#'0',d1
	move.b	d1,-(a2)
	dbf	d0,Loopx
	moveq	#$30,d1
	subq	#1,d7
	ble.s	Endx
Loopy:	move.b	d1,-(a2)
	dbf	d7,Loopy
Endx:	movem.l	(a7)+,a0-a3/d0-d7
	rts

l00cd:	dcb	1,0
l00ce:	dcb	5,0
l00cf:	moveq	#0,d2
	move.l	d2,d3
	move	d2,l00cd
	move.l	d2,d1
	lea	l00ce(pc),a1
	move.l	d2,(a1)
	move.l	d2,4(a1)
	move.l	a0,d0
	cmpi.l	#$f4240,d0
	blt.s	l00d2
l00d0:	subi.l	#$f4240,d0
	bmi.s	l00d1
	addq	#1,d1
	move.l	d0,a0
	bra.s	l00d0
l00d1:	moveq	#0,d0
	move	d1,d0
	divu	#$a,d0
	bsr.s	l00d3
	swap	d0
	bsr.s	l00d3
	move.l	a0,d0
l00d2:	divu	#$2710,d0
	andi.l	#$ffff,d0
	divu	#$a,d0
	bsr.s	l00d3
	clr	d0
	swap	d0
	bsr.s	l00d3
	move.l	a0,d0
	divu	#$2710,d0
	clr	d0
	swap	d0
	divu	#$3e8,d0
	bsr.s	l00d3
	clr	d0
	swap	d0
	divu	#$64,d0
	bsr.s	l00d3
	clr	d0
	swap	d0
	divu	#$a,d0
	bsr.s	l00d3
	swap	d0
l00d3:	move.b	d0,d0
	beq.s	l00d4
	moveq	#1,d2
	bra.s	l00d5
l00d4:	move.b	d2,d2
	beq.s	l00d6
l00d5:	move.b	d0,(a1)+
	addq	#1,l00cd
l00d6:	rts

l00d9:	clr	-(a7)
	pea	l00f5
	move	#$3d,-(a7)
	trap	#1
	addq	#8,a7
	tst.l	d0
	bmi	l00de
	move	d0,l0100
	move.l	l019e(pc),-(a7)
	move.l	#$ffffff,-(a7)
	move	l0100(pc),-(a7)
	move	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7
	tst.l	d0
	bmi	l00de
	move.l	d0,d6
	move.l	l019e(pc),a0
	add.l	d0,a0
	move.l	a0,l019a
	move	l0100(pc),-(a7)
	move	#$3e,-(a7)
	trap	#1
	addq	#4,a7
	bmi	l00de
	cmp.l	l00f8(pc),d6
	ble	l00e0
	move.l	d6,l019c
	tst	l0194
	bne.s	l00da
	move.l	l019e(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	add.l	d6,a0
	subq.l	#4,a0
	movep	0(a0),d0
	movep	1(a0),d1
	add.l	d0,d1
	cmpi	#-$6067,d1
	beq.s	l00df
	subq.l	#4,a0
	movep	0(a0),d0
	movep	1(a0),d1
	add.l	d0,d1
	cmpi	#-$6067,d1
	beq.s	l00df
l00da:	lea	l00f5(pc),a0
	move.l	l0189(pc),a1
l00db:	move.b	(a0)+,(a1)+
	bne.s	l00db
	move.l	l018b(pc),a2
	move.l	l019c(pc),a0
	bsr	l00cb
	moveq	#$26,d0
	bsr	l002e
	moveq	#$24,d0
	bsr	l002e
	lea	l00f5(pc),a0
	lea	l00f6(pc),a1
l00dc:	move.b	(a0)+,(a1)+
	cmpi.b	#$2e,(a0)
	beq.s	l00dd
	cmpi.b	#0,(a0)
	bne.s	l00dc
l00dd:	move.l	#$70702e6f,d0
	movep	d0,0(a1)
	swap	d0
	movep	d0,1(a1)
	moveq	#0,d0
l00de:	rts
l00df:	moveq	#3,d0
	rts
l00e0:	move	#1,l01a7
	move.l	#l00e1,l01b2
	moveq	#$34,d0
	bsr	l01a0
	bra	l0000

l00e1:	dc.b	'[1][The file is smaller |than  the offset!!][ OKAY ]',$00,$00
l00e2:	lea	l0089(pc),a0
l00e3:	cmpi.b	#$2a,(a0)+
	bne.s	l00e3
	clr.b	-1(a0)
	move.l	a0,a4
	pea	l0089(pc)
	move	#$3b,-(a7)
	trap	#1
	addq.l	#6,a7
	tst	d0
	beq.s	l00e4
	move	#1,l01a7
	move.l	#l00e5,l01b2
	moveq	#$34,d0
	bsr	l01a0
	moveq	#3,d0
l00e4:	move.b	#$2a,-1(a4)
	rts
l00e5:	dc.b	'[1][ Cannot find the correct PATH | Check the disc...][ HAR HAR ]',$00
l00e6:	movem.l	a0-a6/d0-d7,-(a7)
	move.b	l0089(pc),d0
	subi.b	#$41,d0
	ext	d0
	move	d0,-(a7)
	move	#$e,-(a7)
	trap	#1
	addq	#4,a7
	movem.l	(a7)+,a0-a6/d0-d7
	rts
l00e7:	movem.l	a0-a6/d0-d7,-(a7)
	move	#$2f,-(a7)
	trap	#1
	addq	#2,a7
	move.l	d0,l0199
	movem.l	(a7)+,a0-a6/d0-d7
	rts
l00e8:	movem.l	a0-a6/d0-d7,-(a7)
	move.l	l0199(pc),-(a7)
	move	#$1a,-(a7)
	trap	#1
	addq	#6,a7
	movem.l	(a7)+,a0-a6/d0-d7
	rts
l00e9:	move.l	l00ea(pc),a1
	move.l	l0199(pc),a0
	sub.l	26(a0),a1
	lea	-$150(a1),a1
	move.l	a1,d0
	bclr	#0,d0
	move.l	d0,a1
	move.l	d0,l019e
	rts
l00ea:	dcb	2,0
l00eb:	movem.l	a0-a6/d0-d6,-(a7)
	bsr.s	l00ed
	moveq	#2,d0
	move.l	l018e(pc),a0
	lea	l00ff(pc),a1
l00ec:	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	addq.l	#1,a1
	dbf	d0,l00ec
	moveq	#$29,d0
	bsr	l002e
	movem.l	(a7)+,a0-a6/d0-d6
	rts

l00ed:	lea	l00ff(pc),a3
	moveq	#0,d1
	move	l00f4(pc),d1
	bsr.s	l00ee
	moveq	#0,d1
	move	l00f3(pc),d1
	bsr.s	l00ee
	moveq	#0,d1
	move	l00f2(pc),d1
l00ee:	divu	#$a,d1
	addi.b	#'0',d1
	move.b	d1,(a3)+
	swap	d1
	addi.b	#'0',d1
	move.b	d1,(a3)+
	move.b	#':',(a3)+
	rts

l00ef:	addq	#1,l00f1
	cmpi	#' ',l00f1
	blt.s	l00f0
	clr	l00f1
	addq	#1,l00f2
	cmpi	#'<',l00f2
	blt.s	l00f0
	clr	l00f2
	addq	#1,l00f3
	cmpi	#'<',l00f3
	blt.s	l00f0
	clr	l00f3
	addq	#1,l00f4
	cmpi	#$c,l00f4
	blt.s	l00f0
	clr	l00f4
l00f0:	rts
l00f1:	dcb	1,0
l00f2:	dcb	1,0
l00f3:	dcb	1,0
l00f4:	dcb	1,0
l00f5:	dcb	7,0
l00f6:	dcb	7,0
l00f7:	dcb	7,0
l00f8:	dcb	2,0
l00f9:	dcb	1,0
l00fa:	dcb	1,0
l00fb:	dcb	1,0
l00fc:	dcb	1,0
l00fd:	dcb	1,0
l00fe:	dcb	1,0
l00ff:	dcb	4,0
l0100:	dcb	1,0
l0101:	dc.b	'[1][Choose wether you want to| REName or DELete a file.  |Or leave.][ DEL | REN | Oops ]',0
l0102:	dc.b	'[2][FILE error,you just blew it!|   Wanna try again][ Yes | No ]',0
l0103:	dc.b	'[1][ Open out error.|How did you manage that!][Dunno]',0
l0104:	dc.b	'[1][Disk error. That was| clumsy of you.][Aaargh]',0
l0105:	dc.b	'[1][Not enough memory for|file selector.][Drat]',0
l0106:	dc.b	'[1][Not enough room on the disc.|Gimme a blank or quit.][ JESUS | RETRY ]',$00
l0107:	dc.b	'[1][JPM 1990 come on|snap out of it.][Okay]',0
l0108:	dc.b	'[2][ Please insert a disc into| drive '
l0109:	dc.b	'A.][ FORMAT | CANCEL ]',0,0
l010a:	dc.b	$A2,'G',$A3,'S',$A8,'P'
l010b:	dc.b	'*.*'
l010c:	dc.b	$00,$00,$00,$06,$00
l010d:	move.l	l019e(pc),a0
	move.l	l019a(pc),a1
	move.l	l019b(pc),a2
	move.l	l00f8(pc),d0
	beq.s	l010f
	subq	#1,d0
l010e:	move.b	(a0)+,(a2)+
	dbf	d0,l010e
l010f:	moveq	#1,d2
	moveq	#0,d1
l0110:	tst	l0146
	bne.s	l0113
	;cmpi	#1,d5
	;beq.s	l0111

	addq.b	#2,Count
	bne.s	Skip
	movem.l	a0-a6,-(a7)
	sub.l	l019e(pc),a0
	move.l	l0188(pc),a2
	bsr	l00cb
	moveq	#$22,d0
	bsr	l002e
	movem.l	(a7)+,a0-a6
	bsr.s	l0114
	movem.l	a0-a6,-(a7)
	move.l	a2,a0
	sub.l	l019b(pc),a0
	move.l	l0187(pc),a2
	bsr	l00cb
	moveq	#$23,d0
	bsr	l002e
	movem.l	(a7)+,a0-a6
;	bra.s	l0112
Skip:
	bsr.s	l0114

l0112:	cmp.l	a0,a1
	bgt.s	l0110
l0113:	bsr	l013e
	move.l	a2,d0
	move.l	a2,l019f
	sub.l	l019b,d0
	move.l	d0,l0149
	move.l	d0,a2
	rts

l0114:
	lea	$3fff(a0),a3
l0115	equ	l0114+2
;
; compression chaine de caractŠres...
;
	cmp.l	a1,a3
	ble.s	l0116
	move.l	a1,a3
l0116:	move.l	l019a(pc),d7
	sub.l	a0,d7
	moveq	#1,d5
	lea	1(a0),a5
l0117:	move.b	(a0),d3
	move.b	1(a0),d4

	move.l	a3,d0
	sub.l	a5,d0
Loop0:	cmp.b	(a5)+,d3
	dbeq	d0,Loop0
	bne.s	l011e
	cmp.b	(a5),d4
	dbeq	d0,Loop0
	bne.s	l011e

;	subq	#1,a5
;	move.l	a0,a4
	lea	2(a0),a4
	addq	#1,a5

	move.l	a3,d0
	sub.l	a5,d0
loop1:	cmp.b	(a4)+,(a5)+
	dbne	d0,loop1
;
; saisie du record
;
	move.l	a4,d3
	sub.l	a0,d3
	subq.l	#1,d3
	cmp.l	d3,d5
	bge.s	l011d
	move.l	a5,d4
	sub.l	a0,d4
	sub.l	d3,d4
	subq.l	#1,d4
	move.l	d3,d5
	move.l	d4,l0131
l011d:	cmp.l	a5,a3
	bgt.s	l0117

l011e:	cmp.l	#1,d5		;record ?
	beq.s	l0121
	move.l	l0131(pc),d3	;oui->on code la chaine
	cmpi	#1,d3
	beq	l0130
	cmp.l	d7,d5
	ble.s	l011f
	move.l	d7,d5

l011f:	cmpi	#2,d5		;codage de la chaine
	beq	l0128
	cmpi	#3,d5
	beq	l0129
	cmpi	#4,d5
	beq	l012e
	cmpi	#5,d5
	beq	l012f

	move.l	l0131(pc),d3
	bsr	l0134
	cmpi	#$100,d5
	blt.s	l0120
	move	#$ff,d5
l0120:	move.l	d5,d3
	subq	#1,d3
	bsr	l0139
	add.l	d5,a0
	L012C
	L012C
	L012A
	rts
;
; on ne peut mettre une chaine
;
l0121:	moveq	#0,d3
	move.b	(a0)+,d3	;c'est un z‚ro ?
	beq	l0126		;oui->on le code en moins de bits
	cmp.b	(a0),d3		;c'est un octet r‚p‚t‚ 2 fois ?
	beq	l0127		;oui->nouveau codage

	lea	l0125(pc),a6
	moveq	#7,d0
l0122:	cmp.b	(a6)+,d3	;est-ce une puissance de 2 ?
	dbeq	d0,l0122
	beq.s	l0124		;oui->on le code en puissance de 2

	move.b	d3,(a2)+	;non->on fait des stocks
	add.b	d2,d2
	bcc.s	l0123
	move.b	d2,(a2)+
	moveq	#1,d2
l0123:	rts

l0124:	moveq	#7,d3		;codage puissance de 2
	eor	d0,d3
	bsr	Set3
	moveq	#$e,d3
	bra	Set4

Set18:	lsr.l	#1,d3
	addx.b	d2,d2
	bcc.s	Set17
	move.b	d2,(a2)+
	moveq	#1,d2
Set17:	lsr.l	#1,d3
	addx.b	d2,d2
	bcc.s	Set16
	move.b	d2,(a2)+
	moveq	#1,d2
Set16:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set15
	move.b	d2,(a2)+
	moveq	#1,d2
Set15:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set14
	move.b	d2,(a2)+
	moveq	#1,d2
Set14:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set13
	move.b	d2,(a2)+
	moveq	#1,d2
Set13:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set12
	move.b	d2,(a2)+
	moveq	#1,d2
Set12:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set11
	move.b	d2,(a2)+
	moveq	#1,d2
Set11:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set10
	move.b	d2,(a2)+
	moveq	#1,d2
Set10:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set9
	move.b	d2,(a2)+
	moveq	#1,d2
Set9:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set8
	move.b	d2,(a2)+
	moveq	#1,d2
Set8:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set7
	move.b	d2,(a2)+
	moveq	#1,d2
Set7:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set6
	move.b	d2,(a2)+
	moveq	#1,d2
Set6:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set5
	move.b	d2,(a2)+
	moveq	#1,d2
Set5:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set4
	move.b	d2,(a2)+
	moveq	#1,d2
Set4:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set3
	move.b	d2,(a2)+
	moveq	#1,d2
Set3:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set2
	move.b	d2,(a2)+
	moveq	#1,d2
Set2:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set1
	move.b	d2,(a2)+
	moveq	#1,d2
Set1:	lsr	#1,d3
	addx.b	d2,d2
	bcc.s	Set0
	move.b	d2,(a2)+
	moveq	#1,d2
Set0:	rts

l0125:	dc.b	$01,$02,$04,$08
	dc.b	$10,$20,$40,$80

l0126:	moveq	#$1b,d3
	bra.s	Set5

l0127:	moveq	#$7b,d3
	bra.s	Set7

l0128:	move.l	l0131(pc),d3
	cmpi.l	#$ff,d3
	bgt	l0121
	move.b	d3,(a2)+
	L012A
	L012C
	L012A
	addq	#2,a0
	rts

l0129:	move.l	l0131(pc),d3
	cmpi.l	#$fff,d3
	bgt	l0121
	bsr.s	l0134
	L012C

	addq	#3,a0
	L012A
	L012A
	rts

l012e:	move.l	l0131(pc),d3
	cmpi.l	#$fff,d3
	bgt	l0121
	bsr.s	l0134
	addq	#4,a0
	moveq	#$1e,d3
	bra	Set5

l012f:	bsr.s	l0134
	addq	#5,a0
	moveq	#$1f,d3
	bra	Set5

l0131:	dcb	2,0
l0130:	move	d5,d3
	subq	#1,d3
	bsr.s	l0134
	add.l	d5,a0
	moveq	#$10,d3
	bra	Set5

l0134:	cmpi	#$f,d3
	bgt.s	l0135
	bsr	Set4
	moveq	#0,d3
	bra	Set2

l0135:	cmpi	#$ff,d3
	bgt.s	l0136
	bsr	Set8
	moveq	#1,d3
	bra	Set2

l0136:	cmpi	#$fff,d3
	bgt.s	l0137
	bsr	Set12
	moveq	#2,d3
	bra	Set2

l0137:	bsr	Set16
	moveq	#3,d3
l0138:	bra	Set2

l0139:	cmpi	#%00000011,d3
	ble	Set4
	cmpi	#%0000001111,d3
	bgt.s	.1
	or	#%0000010000,d3
	bra	Set6
.1:	cmpi	#%0000111111,d3
	bgt.s	.2
	or.l	#%0010000000,d3
	bra	Set8
.2:	or.l	#%1100000000,d3
	bra	Set10

l013e:	move.b	d2,(a2)+
	move.l	a2,d0
;	btst	#0,d0
;	beq.s	l013f
	lsr	#1,d0
	bcc.s	l013f
	clr.b	(a2)+
l013f:	rts

l0140:	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
	move.l	d0,-(a7)
	move.l	$456.w,a0
	moveq	#7,d0
l0141:	tst.l	(a0)+
	beq.s	l0142
	dbf	d0,l0141
l0142:	move.l	a3,-(a0)
	move.l	a0,a3
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
	rts
l0143:	movem.l	a1/d0,-(a7)
	move.l	l0145,a1
	tst	(a1)
	bne.s	l0144
	move	#-1,l0146
	move	#-1,(a1)
l0144:	move.b	#$fe,$fffffa0f.w
	movem.l	(a7)+,a1/d0
	rts
l0145:	dcb	2,0
l0146:	dcb	1,0
l0147:	dcb	2,0
l0148:	dcb	2,0
l0149:	dcb	2,0
l014a:	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1
	move.l	d0,2(a7)
	clr.l	(a3)
	trap	#1
	addq.l	#6,a7
	rts
;	move.l	l019b,a2
;	move.l	l019f,a4
;	lea	12(a4),a4
;	bra.s	l014f

l014b:	dc.b	$60,$1a
l014c:	dcb	2,0
l014d:	dcb	2,0
l014e:	dcb	9,0
	move.l	4(a7),a5
	move.l	#0,a2
	add.l	#$1b2,a2
;l014f:
	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1
	move.l	d0,2(a7)
	move.l	a4,a0
	move.l	a2,a3
	subq.l	#4,a0
	add.l	-(a0),a2
	move.l	a2,a4
	subq.l	#4,a0
	lea	$ffff8240.w,a6
	move	(a6),d5
l0150:	move.b	-(a0),d0
	beq.s	l0150
l0151:	moveq	#0,d2
	bsr	l015e
	bcs.s	l0154
	move.b	-(a0),d2
l0152:	move.b	d2,-(a2)
	bra.s	l0156
l0153:	moveq	#$f,d4
	moveq	#2,d3
	bsr.s	l0161
	bne.s	l015c
	move	d4,d2
	bra.s	l0152

l0154:	bsr.s	l015e
	bcc.s	l0158
	bsr.s	l015e
	bcc.s	l0153
	bsr.s	l015e
	bcs.s	l0155
	moveq	#2,d1
	bsr	l0164
	exg	d2,d1
	addq	#1,d2
	bset	d1,d2
	bra.s	l0152
l0155:	bsr.s	l015e
	bcs.s	l0157
	moveq	#$f,d4
	move	#3,d3
	bsr.s	l0161
	bne.s	l015c
	move.b	(a2),-(a2)
l0156:	neg	(a6)
	move	d5,(a6)
	cmp.l	a2,a3
	blt.s	l0151
	bra	l0169

l0157:	moveq	#4,d3
	bra.s	l015b

l0158:	bsr.s	l015e
	bcs.s	l0168
	moveq	#1,d1
l0159:	lsr.b	#1,d0
	bne.s	l015a
	move.b	-(a0),d0
	roxr.b	#1,d0
l015a:	addx	d2,d2
	dbf	d1,l0159
	move	d2,d1
	beq.s	l0167
	addq	#1,d1
	add	d1,d1
	subq	#1,d1
	bsr.s	l0164
	move	d2,d3
l015b:	bsr.s	l0160
l015c:	move.l	a2,a1
	add.l	d2,a1
l015d:	move.b	-(a1),-(a2)
	dbf	d3,l015d
	bra.s	l0156

l015e:	lsr.b	#1,d0
	bne.s	l015f
	move.b	-(a0),d0
	roxr.b	#1,d0
l015f:	rts

l0160:	moveq	#0,d4
l0161:	moveq	#1,d1
	moveq	#0,d2
l0162:	lsr.b	#1,d0
	bne.s	l0163
	move.b	-(a0),d0
	roxr.b	#1,d0
l0163:	addx	d2,d2
	dbf	d1,l0162
	move	d2,d1

	addq	#1,d1
	lsl	#2,d1
	subq	#1,d1

	eor.b	d1,d4
	bne.s	l0164
	rts

;	moveq	#7,d1
l0164:	moveq	#0,d2
l0165:	lsr.b	#1,d0
	bne.s	l0166
	move.b	-(a0),d0
	roxr.b	#1,d0
l0166:	addx	d2,d2
	dbf	d1,l0165
	rts

l0167:	bsr.s	l0160
	move	d2,d3
	moveq	#1,d2
	bra.s	l015c
l0168:	moveq	#1,d3
	move.b	-(a0),d2
	bra.s	l015c

l0169:	move	d5,(a6)
	trap	#1
	addq	#6,a7
	move.l	2(a3),a0
	add.l	6(a3),a0
	add.l	14(a3),a0
	lea	$1c(a0),a0
	add.l	a3,a0
	move.l	8(a5),d0
	lea	$1c(a3),a3
	move.l	a3,a6
	tst.l	(a0)
	beq.s	l016d
	add.l	(a0)+,a3
l016a:	add.l	d0,(a3)
	moveq	#0,d1
l016b:	move.b	(a0)+,d1
	beq.s	l016d
	cmp.b	#1,d1
	bne.s	l016c
	lea	$fe(a3),a3
	bra.s	l016b
l016c:	add	d1,a3
	bra.s	l016a
l016d:	addq	#2,a2
	move.l	(a2),12(a5)
	add.l	(a2),d0
	move.l	d0,16(a5)
	move.l	4(a2),20(a5)
	add.l	4(a2),d0
	move.l	d0,24(a5)
	move.l	8(a2),28(a5)
	move.l	a7,a0
	lea	-$100(a0),a0
	move.l	a0,-(a7)
	lea	l016f(pc),a1
	moveq	#$2b,d0
l016e:	move.b	(a1)+,(a0)+
	dbf	d0,l016e
	rts
l016f:	move.l	12(a5),d0
	add.l	20(a5),d0
	lsr.l	#2,d0
	addq.l	#2,d0
	lea	$100(a5),a5
	move.l	a5,a3
l0170:	move.l	(a6)+,(a5)+
	subq.l	#1,d0
	bne.s	l0170
	move.l	4(a7),a5
	move.l	24(a5),a0
l0171:	move.l	d0,(a0)+
	cmp.l	a4,a0
	blt.s	l0171
	jmp	(a3)
l0172:	bsr	l006b
	move.b	l0089(pc),d0
	cmpi.b	#$46,d0
	bne.s	l0173
	bra	l0001
l0173:	cmpi.b	#$44,d0
	bne.s	l0174
	bra	l0001
l0174:	move.b	l0089(pc),d0
	move.b	d0,l0109
	subi.b	#$41,d0
	ext	d0
	move	d0,l0182
	move	#2,l01a7
	move.l	#l0108,l01b2
	moveq	#$34,d0
	bsr	l01a0
	cmpi	#1,d0
	beq.s	l0175
	bra	l0001
l0175:	clr	l017d
	move	l017e(pc),-(a7)
	move.l	l017f(pc),-(a7)
	move	l0180(pc),-(a7)
	clr	-(a7)
	move	l017d(pc),-(a7)
	move	l0181(pc),-(a7)
	move	l0182(pc),-(a7)
	clr.l	-(a7)
	move.l	l019b(pc),-(a7)
l0176:	move	#$a,-(a7)
	trap	#$e
	addq	#2,a7
	tst	d0
	bmi	l017a
	tst	14(a7)
	bne.s	l0177
	move	#1,14(a7)
	bra.s	l0176
l0177:	clr	14(a7)
	addq	#1,12(a7)
	cmpi	#$50,12(a7)
	blt.s	l0176
	lea	24(a7),a7
	move.l	l019b,a0
	moveq	#0,d0
	move.l	d0,d1
	move	#$2710,d1
l0178:	move.l	d0,(a0)+
	dbf	d1,l0178
	moveq	#1,d0
	moveq	#0,d1
l0179:	moveq	#0,d2
	bsr	l017c
	moveq	#1,d2
	bsr	l017c
	dbf	d0,l0179
	move	#$11,-(a7)
	trap	#$e
	addq	#2,a7
	move.l	d0,l0183
	move	l0184(pc),-(a7)
	move	l0185(pc),-(a7)
	move.l	l0183(pc),-(a7)
	move.l	l019b(pc),-(a7)
	move	#$12,-(a7)
	trap	#$e
	lea	14(a7),a7
	move.l	l019b,a0
	move.l	#'POMP',2(a0)
	move	#'EY',6(a0)
	move	#$a00,24(a0)
	move.b	#$40,19(a0)
	move.b	#6,20(a0)
	move	#1,-(a7)
	clr	-(a7)
	move	#0,-(a7)
	move	#1,-(a7)
	move	l0182,-(a7)
	clr.l	-(a7)
	move.l	l019b,-(a7)
	move	#9,-(a7)
	trap	#$e
	lea	20(a7),a7
	tst.l	d0
	bmi.s	l017b
	bra	l0001
l017a:	lea	24(a7),a7
l017b:	not.l	d0
	move	d0,l01a7
	moveq	#$35,d0
	bsr	l01a0
	bra	l0001
l017c:	movem.l	a0-a2/d0-d7,-(a7)
	move	d1,-(a7)
	move.l	l017f,-(a7)
	move	l0180,-(a7)
	move	d2,-(a7)
	move	d0,-(a7)
	move	l0181,-(a7)
	move	l0182,-(a7)
	clr.l	-(a7)
	move.l	l019b,-(a7)
	move	#$a,-(a7)
	trap	#$e
	lea	26(a7),a7
	movem.l	(a7)+,a0-a2/d0-d7
	rts

l017d:	dcb	1,0
l017e:	dc.b	$e5,$e5
l017f:	dc.b	$87,'eC!'
l0180:	dc.b	$00,$01,$00,$00,$00,'O'
l0181:	dc.b	$00,$0a
l0182:	dcb	1,0
l0183:	dcb	2,0
l0184:	dcb	1,0
l0185:	dc.b	$00,$03
l0186:	dc.l	l0187
	dc.l	l0188
	dc.l	l018b
	dc.l	l018c
l0187:	dcb	2,0
l0188:	dcb	2,0
l0189:	dcb	2,0
l018a:	dcb	2,0
l018b:	dcb	2,0
l018c:	dcb	2,0
l018d:	dcb	2,0
l018e:	dcb	2,0
l018f:	dcb	2,0
l0190:	dcb	2,0
l0191:	dcb	2,0
l0192:	dcb	1,0
l0193:	dcb	1,0
l0194:	dcb	1,0
l0195:	dcb	1,0
l0196:	dcb	1,0
l0197:	dcb	1,0
l0198:	dcb	22,0
l0199:	dcb	2,0
l019a:	dcb	2,0
l019b:	dcb	4,0
l019c:	dcb	2,0
l019d:	dcb	2,0
l019e:	dcb	2,0
l019f:	dcb	2,0
l01a0:	lea	l01a3(pc),a1
	move	d0,(a1)+
	subi	#$a,d0
	lea	l01a2(pc),a0
	add	d0,a0
	add	d0,d0
	add	d0,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	move	d0,(a1)+
	move.b	(a0)+,d0
	move	d0,(a1)+
	move.b	(a0)+,d0
	move	d0,(a1)+
	clr	(a1)
	move.l	#l01a1,d1
	move	#$c8,d0
	trap	#2
	move	l01b0(pc),d0
	rts

	DATA
Count:	dc.b	-2
	even
l01a1:	dc.l	l01a3
	dc.l	l01a6
	dc.l	l01a7
	dc.l	l01b0
	dc.l	l01b2
	dc.l	l01b4
l01a2:	dc.b	$00,$01,$00,$02,$01,$01,$02,$01
	dc.b	$01,$00,$01,$01,$02,$01,$01,$01
	dc.b	$01,$01,$00,$00,$00,$00,$00,$00
	dcb	2,0
	dc.b	$01,$00,$00,$01,$00,$03,$05,$00
	dc.b	$05,$05,$00,$00,$01,$01,$02,$01
	dc.b	$00,$10,$07,$01,$02,$01,$00,$00
	dcb	4,0
	dc.b	$01,$01,$01,$02,$01,$01,$02,$01
	dc.b	$01,$02,$01,$01,$01,$01,$02,$01
	dc.b	$01,$01,$00,$00,$00,$00,$00,$00
	dcb	3,0
	dc.b	$02,$01,$01,$01,$01,$01,$06,$01
	dc.b	$01,$04,$01,$01,$01,$03,$01,$02
	dc.b	$01,$01,$04,$02,$01,$08,$01,$01
	dcb	3,0
	dc.b	$01,$01,$01,$09,$01,$00,$01,$01
	dc.b	$01,$01,$01,$00,$00,$05,$01,$00
	dcb	22,0
	dc.b	$04,$03,$00,$08,$03,$00,$06,$01
	dc.b	$00,$08,$01,$00,$08,$01,$00,$04
	dc.b	$01,$01,$03,$01,$01,$00,$05,$00
	dc.b	$01,$01,$01,$00,$05,$00,$00,$01
	dc.b	$01,$00,$01,$01,$00,$00,$00,$00
	dcb	10,0
	dc.b	$00,$02,$02,$00,$02,$03,$00,$00
	dcb	11,0
	dc.b	$05,$01,$00,$05,$01,$00,$01,$01
	dc.b	$00,$01,$01,$00,$02,$05,$00,$06
	dc.b	$01,$00,$02,$01,$00,$01,$01,$00
	dc.b	$06,$05,$00,$00,$00,$00,$00,$01
	dc.b	$01,$00,$01,$00,$02,$01,$00,$02
	dc.b	$01,$01,$01,$01,$01,$00,$00,$00
	dcb	6,0
	dc.b	$00,$01,$02,$03,$01,$02,$01,$01
	dc.b	$01,$01,$01,$01,$00,$01,$01,$00
	dc.b	$01,$03

	BSS

Zuend:	ds.b	100
l01a3	equ	Zuend+0
l01a4	equ	Zuend+4
l01a5	equ	Zuend+8
l01a6	equ	Zuend+$a
l01a7	equ	Zuend+$26
l01a8	equ	Zuend+$28
l01a9	equ	Zuend+$2a
l01aa	equ	Zuend+$2c
l01ab	equ	Zuend+$2e
l01ac	equ	Zuend+$30
l01ad	equ	Zuend+$32
l01ae	equ	Zuend+$34
l01af	equ	Zuend+$36
l01b0	equ	Zuend+$46
l01b1	equ	Zuend+$48
l01b2	equ	Zuend+$54
l01b3	equ	Zuend+$58
l01b4	equ	Zuend+$60
