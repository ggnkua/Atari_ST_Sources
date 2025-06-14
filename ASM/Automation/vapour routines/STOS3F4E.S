		opt c+,d-
;3f,4e command only
;Stos params
;*.bin,cr0,cr1,cr2,exa,env   pack whole
;*.bas,*.mbs  header=$4e
;*.neo header is $80
;*.mbk header is $12
;also view psycho pig src	

;header means remove from front of file (header size)
;save rest of file out and pack whole.then put the header
;back onto the front of the file.this means that the files
;will be depacked from the 3f command without using a lump packer
;see headremo & headrepl.s for making these files.
;you need to know how the files are loaded so use print*.s to help you find out 
main	MOVEA.L	4(A7),A5
	move.l $c(a5),d0
	add.l $14(a5),d0
	add.l $1c(a5),d0
	add.l #$100,d0
	move.l d0,-(sp)
	move.l a5,-(sp)
	move.l #$4a0000,-(sp)
	trap #1
	lea $c(a7),a7
CHEAT	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#$01
	MOVE.L	D0,2(A7)
	MOVE.L	$84.W,tr1
	MOVE.L	#T1,$84.W
	TRAP	#$01
	ADDQ.L	#6,A7
	clr.w -(sp)
	pea $ffffffff
	move.l (a7),-(sp)
	move.w #5,-(sp)
	trap #14
	lea $c(a7),a7
	pea text
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
stkk	clr.l $60000
	pea $60000
	move.l (a7),-(sp)
	move.l #gam,-(sp)
	move.l #$4b0000,-(sp)
	trap #1
	lea $10(a7),a7
	clr.w -(sp)
	trap #1


T1		movem.l	a0-a6/d0-d7,reg
		movea.l	a7,a1
		addq.l 	#6,a1
		move.w 	(a7),d0
		btst 	#$d,d0
		bne.s 	ok1
		move.l 	usp,a1
ok1		nop
next1		bra.s notopen
open		movem.l 	reg,a0-a6/d0-d7
bye		dc.w 	$4ef9
tr1		dc.l 	$0
loadit		dc.l 	$0
quitt		move.l tr1,$84.w
		bra.s open
notopen		cmp.w #0,(a1)
		beq.s quitt	
		cmp.w #$4e,(a1)
		beq is4e
		cmpi.w 	#$3f,(a1)
		bne.s 	open
		move.l 	$8(a1),loadit
		move.l $2(a7),ex3f
		move.l #cls,$2(a7)
		bra.s open
siz2		dc.l 0
cls		movem.l d0-d7/a0-a6,-(sp)
		move.l d0,siz2
		BSR.s close
		movem.l (a7)+,d0-d7/a0-a6
		move.l siz2,d0
		dc.w $4ef9
ex3f		dc.l 0
flg		dc.w 0
close		move.l loadit,a0
		cmp.w #$ffff,flg
		beq.S ret
		cmp.b #$53,(a0)
		bne.S ret
		cmp.b #$50,$1(a0)
		bne.S ret
		cmp.b #$76,$2(a0)
		bne.S ret
		cmp.b #$33,$3(a0)
		bne.S ret
		move.l $C(a0),siz2
		bsr	DEPACK
ret		rts
reg		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
is4e		move.l 2(a7),ex4e
		move.l #is4e2,2(a7)
		move.l 2(a1),name
		bra open
name		dc.l 0
is4e2
		movem.l a0-a6/d0-d7,-(sp)
		MOVE.W #$FFFF,flg
		clr.w -(sp)
		move.l name,-(sp)
		move.w #$3d,-(sp)
		trap #1
		addq.l #8,sp
		move.w d0,d5
		tst.w d0
		bmi.s exi4e
		pea bup
		pea $5e
		move.w d5,-(sp)
		move.w #$3f,-(sp)
		trap #1
		lea 12(sp),sp
		move.w d5,-(sp)
		move.w #$3e,-(sp)
		trap #1
		addq.l #4,sp
		lea bup(pc),a0
		cmp.l #$53507633,(a0)
		bne.s nst
		move.l 12(a0),d7
		bra.s gotsp
nst		cmp.l #$53507633,$4e(a0)
		bne.s exi4e
		move.l $5a(a0),d7
		clr.l (a0)
		clr.l $4e(a0)
gotsp		move.w #$2f,-(sp)
		trap #1
		addq.l #2,sp
		move.l d0,a0
		move.l d7,$1a(a0)
exi4e		clr.w flg
end		movem.l (a7)+,a0-a6/d0-d7
		dc.w $4ef9
ex4e		dc.l 0

DEPACK		

unpack:	moveq	#0,d0
	movem.l	d0-a6,-(sp)
	lea	sp3_53(pc),a6
	movea.l	a0,a1
	TST.l	(a1)+
	tst.w	(a1)
	bne.s	sp3_02
	move.l	(a1)+,d5
	move.l	(a1)+,d0
	move.l	(a1)+,(sp)
	movea.l	a0,a2
	adda.l	d0,a0
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	adda.l	(sp),a1
	lea	sp3_58-sp3_53(a6),a3
	moveq	#128-1,d0
sp3_01:	move.l	(a2)+,(a3)+
	dbf	d0,sp3_01
	suba.l	a2,a3
	move.l	a3,-(sp)
	bsr.s	sp3_03
	bsr	sp3_21
	move.b	-(a0),d0
	adda.l	(sp)+,a0
	move.b	d0,(a0)+
	lea	sp3_58-sp3_53(a6),a2
	bsr	sp3_22
	bsr	sp3_15
sp3_02:	movem.l	(sp)+,d0-a6
	rts
sp3_03:	
;	move.w	SR,d1
;	andi.w	#$2000,d1
;	beq.s	sp3_04
;	move.w	$FFFF8240.W,2(a6)
;	btst	#1,$FFFF8260.W
;	bne.s	sp3_04
;	swap	d5
sp3_04:	clr.w	d5
	move.w	-(a0),d6
	lea	sp3_54-sp3_53(a6),a3
	move.b	d6,(a3)+
	moveq	#1,d3
	moveq	#6,d4
sp3_05:	cmp.b	d6,d3
	bne.s	sp3_06
	addq.w	#2,d3
sp3_06:	move.b	d3,(a3)+
	addq.w	#2,d3
	dbf	d4,sp3_05
	moveq	#$10,d4
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),d4
	move.w	d4,(a6)
	lea	sp3_57-sp3_53(a6),a5
	move.b	-(a0),d4
	lea	1(a5,d4.w),a3
sp3_07:	move.b	-(a0),-(a3)
	dbf	d4,sp3_07
	move.b	-(a0),-(a3)
	beq.s	sp3_08
	suba.w	d4,a0
sp3_08:	moveq	#0,d2
	move.b	-(a0),d2
	move.w	d2,d3
	move.b	-(a0),d7
sp3_09:	bsr.s	sp3_10
	bsr.s	sp3_10
	dbf	d2,sp3_09
	rts
sp3_10:	not.w	d4
	add.b	d7,d7
	bne.s	sp3_11
	move.b	-(a0),d7
	addx.b	d7,d7
sp3_11:	bcs.s	sp3_12
	move.w	d2,d0
	subq.w	#1,d3
	sub.w	d3,d0
	add.w	d0,d0
	add.w	d4,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,-(a3)
	rts
sp3_12:	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	beq.s	sp3_13
	move.b	d0,-(a3)
	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	move.b	d0,-(a3)
	rts
sp3_13:	moveq	#2,d1
	bsr	sp3_44
	move.w	sp3_55-sp3_53(a6),d1
	add.w	d0,d0
	beq.s	sp3_14
	move.w	sp3_55+2-sp3_53(a6),d1
sp3_14:	or.w	d1,d0
	move.w	d0,-(a3)
	rts
sp3_15:	
;	move.w	SR,d1
;	andi.w	#$2000,d1
;	beq.s	sp3_16
;	move.w	2(a6),$FFFF8240.W
sp3_16:	tst.w	d6
	bpl.s	sp3_20
	movea.l	a1,a2
	movea.l	a1,a3
	adda.l	4(sp),a3
sp3_17:	moveq	#3,d6
sp3_18:	move.w	(a2)+,d0
	moveq	#3,d5
sp3_19:	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,sp3_19
	dbf	d6,sp3_18
	cmpa.l	a2,a3
	blt.s	sp3_20
	movem.w	d1-d4,-8(a2)
	cmpa.l	a2,a3
	bne.s	sp3_17
sp3_20:	rts
sp3_21:	move.b	-(a0),-(a1)
sp3_22:	swap	d5
;	beq.s	sp3_23
;	move.w	d5,$FFFF8240.W
sp3_23:	lea	sp3_56+2-sp3_53(a6),a3
	cmpa.l	a0,a2
	blt.s	sp3_25
	rts
sp3_24:	adda.w	d3,a3
sp3_25:	add.b	d7,d7
	bcc.s	sp3_28
	beq.s	sp3_27
sp3_26:	move.w	(a3),d3
	bmi.s	sp3_24
	bra.s	sp3_29
sp3_27:	move.b	-(a0),d7
	addx.b	d7,d7
	bcs.s	sp3_26
sp3_28:	move.w	-(a3),d3
	bmi.s	sp3_24
sp3_29:	ext.w	d3
	jmp	sp3_30(pc,d3.w)
sp3_30:	bra.s	sp3_30
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_37
	bra.s	sp3_36
	bra.s	sp3_32
	bra.s	sp3_33
	bra.s	sp3_31
	bra.s	sp3_34
	bra.s	sp3_21
sp3_31:	move.b	(a5),-(a1)
	bra.s	sp3_22
sp3_32:	bsr.s	sp3_43
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_33:	bsr.s	sp3_43
	add.w	(a6),d0
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_34:	moveq	#3,d1
	bsr.s	sp3_44
	lsr.w	#1,d0
	bcc.s	sp3_35
	not.w	d0
sp3_35:	move.b	(a1),d1
	add.w	d0,d1
	move.b	d1,-(a1)
	bra.s	sp3_22
sp3_36:	lea	sp3_52-2-sp3_53(a6),a4
	bsr.s	sp3_48
	addi.w	#16,d0
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
	move.b	-(a3),-(a1)
	bra	sp3_22
sp3_37:	moveq	#3,d1
	bsr.s	sp3_44
	tst.w	d0
	beq.s	sp3_38
	addq.w	#5,d0
	bra.s	sp3_40
sp3_38:	move.b	-(a0),d0
	beq.s	sp3_39
	addi.w	#20,d0
	bra.s	sp3_40
sp3_39:	moveq	#13,d1
	bsr.s	sp3_44
	addi.w	#276,d0
sp3_40:	move.w	d0,d3
	add.w	d3,d3
sp3_41:	lea	sp3_52-sp3_53(a6),a4
	bsr.s	sp3_48
	lsr.w	#1,d3
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
sp3_42:	move.b	-(a3),-(a1)
	dbf	d3,sp3_42
	bra	sp3_22
sp3_43:	moveq	#0,d1
	move.b	(a3),d1
sp3_44:	moveq	#0,d0
	cmpi.w	#7,d1
	bpl.s	sp3_47
sp3_45:	add.b	d7,d7
	beq.s	sp3_46
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_46:	move.b	-(a0),d7
	addx.b	d7,d7
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_47:	move.b	-(a0),d0
	subq.w	#8,d1
	bpl.s	sp3_45
	rts
sp3_48:	moveq	#0,d1
	move.b	(a3),d1
	adda.w	d1,a4
	move.w	(a4),d1
	bsr.s	sp3_44
	tst.b	d6
	beq.s	sp3_51
	move.w	d0,d4
	andi.w	#$FFF0,d4
	andi.w	#$000F,d0
	beq.s	sp3_50
	lsr.w	#1,d0
	beq.s	sp3_49
	roxr.b	#1,d7
	bcc.s	sp3_50
	move.b	d7,(a0)+
	moveq	#-128,d7
	bra.s	sp3_50
sp3_49:	moveq	#2,d1
	bsr.s	sp3_44
	add.w	d0,d0
	or.w	d4,d0
	bra.s	sp3_51
sp3_50:	lea	sp3_54-sp3_53(a6),a3
	or.b	(a3,d0.w),d4
	move.w	d4,d0
sp3_51:	add.w	18(a4),d0
	rts

	DC.W	3
sp3_52:	DC.W	4,5,7,8,9,10,11,12
	DC.W	-16
	DC.W	0,32,96,352,864,1888,3936,8032

sp3_53:	DS.L	1
sp3_54:	DS.B	8
sp3_55:	DS.W	2*64
sp3_56:	DS.W	2
	DS.B	1
sp3_57:	DS.B	1
	DS.B	2*64
sp3_58:	DS.B	512

bup	ds.b	94


gam		dc.b "main",0
text		dc.b "78 RPM OF D-BUG PRESENTS",13,10
		DC.B 'HENRIETTA''S BOOK OF SPELLS',13,10
		DC.B 'SUPPLIED BY THE BOG BROTHERS'
		DC.B 0
EVEN
