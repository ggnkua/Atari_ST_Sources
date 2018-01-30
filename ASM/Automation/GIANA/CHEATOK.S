	clr.w -(sp)
	move.l #$78000,-(sp)
	move.l #$78000,-(sp)
	move.w #5,-(sp)
	trap #14
	clr.w $60000
	pea t1
	move.w #9,-(sp)
	trap #1
key	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	clr.b $9ffd
	cmp.b #$d,d0
	bne.s notd
	move.w #$30,-(sp)
	move.w #2,-(sp)
	trap #1
	move.w #$31,-(sp)
	move.w #2,-(sp)
	trap #1
	bra hhh
notd	cmp.b #$2f,d0
	ble.s key
	cmp.b #$34,d0
	bge.s key
	move.b d0,$60000
not34	move.w d0,-(sp)
	move.w #2,-(sp)
	trap #1
key2	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	cmp.b #$2f,d0
	ble.s key2
	cmp.b #$3a,d0
	bge.s key2
	move.b $60000,d1
	cmp.b #$30,d1
	bne.s v
	cmp.b #$30,d0
	beq.s key2
v	cmp.b #$33,d1
	bne.s l40
	cmp.b #$33,d0
	bge.s key2
l40	move.b d0,$60001
	move.w d0,-(sp)
	move.w #2,-(sp)
	trap #1
	clr.w $9ffe
	clr.l d0
	sub.b #$30,$60000
	move.b $60000,d0
	mulu #$10,d0
	move.b d0,$9fff
n2	sub.b #$30,$60001
	move.b $60001,d0
	add.b d0,$9fff
	move.b $60000,d0
	mulu #$a,d0
	move.b d0,$9ffe
	move.b $60001,d0
	add.b d0,$9ffe
	sub.b #1,$9ffe
	move.b #1,$9ffd
hhh	lea $80000,a7
	clr.l -(sp)
	move.w #32,-(sp)
	trap #1
	lea $7fd00,a0
	move.l #last,a1
	moveq.l #$7f,d0
ww	move.l (a1)+,(a0)+
	dbf d0,ww
	clr.w $ff8240
	move.w #$777,$ff825e
	pea text
	move.w #9,-(sp)
	trap #1
	move.w #$14,-(sp)
	move.l #$30004,-(sp)
	trap #13
	move.w #$12,-(sp)
	move.l #$30004,-(sp)
	trap #13
	clr.w -(sp)
	pea file
	move.w #$3d,-(sp)
	trap #1
	move.l #$623be,d6
	bsr load
	clr.w -(sp)
	pea file2
	move.w #$3d,-(sp)
	trap #1
	move.l #$10000,d6
	bsr load
	clr.w -(sp)
	pea file3
	move.w #$3d,-(sp)
	trap #1
	move.l #$48000,d6
	bsr load
	clr.w -(sp)
	pea file4
	move.w #$3d,-(sp)
	trap #1
	move.l #$16b28,d6
	bsr load
	lea $11a66,a0
	lea $16b28,a2
	move.l #$fb6c,d4
	jsr $7fd1e
	lea $215d4,a0
	lea $25000,a1
lppp	clr.l (a0)+
	cmpa.l a0,a1
	bne.s lppp
	clr.w -(sp)
	pea file5
	move.w #$3d,-(sp)
	trap #1
	move.l #$64000,d6
	bsr load
	cmp.b #0,$9ffd
	beq.s yes0
	move.w #$4e71,$6d852
	move.w #$4eb9,$64102
	move.l #$3f00,$64104
	lea $64108,a0
	move.w #$4e71,d0
	lea $6416e,a1
ii	move.w d0,(a0)+
	cmpa.l a0,a1
	bne.s ii
yes0	clr.w -(sp)
	pea file6
	move.w #$3d,-(sp)
	trap #1
	move.l #$25000,d6
	bsr load
	move.w #$2700,sr
	move.w $9ffe,$3efe
	move.w #$66,$16
	lea $20,a0
	lea $100,a1
lkp	clr.l (a0)+
	cmpa.l a0,a1
	bgt.s lkp
	move.l #$400,d1
	lea $100,a0
	moveq.l #$f,d0
loo	move.l d1,(a0)+
	dbf d0,loo
	lea $80,a0
	lea $623c0,a1
	moveq.l #$f,d0
kj	move.l (a1)+,(a0)+
	dbf d0,kj
	move.b #$7,$ff8201
	move.b #$80,$ff8203
	clr.b $ffff8260
	move.l #$402,$70
	move.l d1,$78
	move.l d1,$68
	move.l #$10054,$114
	move.l $b8,$118
	clr.b $fffffa07
	move.b #$60,$fffffa09
	move.l #$11a66,$11a0c
	move.l #$197e6,$11a10
	move.b #$3e,$101b4
	move.w #$43f9,$101ae
	move.w #$4e71,d0
	move.w d0,$10038
	move.w d0,$10048
	move.w d0,$1004c
	move.w d0,$62636
	move.w d0,$6263a
	clr.b $64049
miss	move.b #1,$62565
	clr.b $62567
	move.w #$6026,$6256e
	move.b #9,$6260d
	move.l #$4e714e71,$64266
	move.l #$7fd00,$10050
rw	lea $62bd0,a0
	move.l #$49f90000,(a0)+
	move.l #$2000b03c,(a0)+
	move.l #$0000673a,(a0)+
	move.l #$b03c0001,(a0)+
	move.l #$66fe7000,(a0)+
	move.l #$4e4823fc,(a0)+
	move.l #$00000045,(a0)+
	move.l #$00000cd6,(a0)+
	move.l #$70014e48,(a0)+
	move.l #$23fc0000,(a0)+
	move.l #$da660000,(a0)+
	move.l #$0d0213fc,(a0)+
	move.l #$00010000,(a0)+
	move.l #$0cdd7006,(a0)+
	move.l #$4e4823fc,(a0)+
	move.l #$00000f4e,(a0)+
	move.l #$00000d02,(a0)+
	move.l #$601c203c,(a0)+
	move.l #$000000a2,(a0)+
	move.l #$4e4349f9,(a0)+
	move.l #$00002000,(a0)+
	move.l #$4bf90000,(a0)+
	move.l #$da667059,(a0)+
	move.l #$1adc51c8,(a0)+
	move.w #$fffc,(a0)
	move.b #$32,$66c44
	move.b #$60,$66c48
	move.w #$4e75,$6753a
	move.l #r3f,a0
	lea $3f00,a1
	move.l #128,d0
pp	move.w (a0)+,(a1)+
	dbf d0,pp
	clr.l $8
	move.l #$1a1c2e1f,$18
	bra.s rob
wait	pea tex2
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	rts
rob	lea $623be,a0
	lea $3be,a1
	move.l #$1000/4,d0
mo4	move.l (a0)+,(a1)+
	dbf d0,mo4
	lea $7fffe,a7
	trap #2
runit	lea $64000,a0
	lea $4000,a1
	move.l #$9be6/4,d0
mo5	move.l (a0)+,(a1)+
	dbf d0,mo5
	jmp $10028
load	move.w d0,d5
	move.l d6,-(sp)
	move.l #$1ffff,-(sp)
	move.w d5,-(sp)
	move.w #$3f,-(sp)
	trap #1
	move.w d5,-(sp)
	move.w #$3e,-(sp)
	trap #1
	add.l #$10,sp
	bra wait
file	dc.b "003be",$0
file2	dc.b "10000",$0
file3	dc.b "48000",$0
file4	dc.b "11a67",$0
file5	dc.b "04000",$0
file6	dc.b "1e681",$0
r3f	move.b #$91,$82f6
	move.b #$90,$8316
	move.b #$90,$8317
	move.b $3eff,$82fa
	move.b $3eff,$8314
	move.b $3eff,$8315
	clr.w d0
	move.b $3efe,d0
	move.w d0,$7c4a
	move.w d0,$7c4c
	move.w d0,$7c48
	clr.w $806e
	clr.w $8070
	clr.w $806c
	clr.w $7bf6
	clr.w $7bf8
	clr.w $7bf4
	clr.l $830c
	clr.l $8310
	clr.l $82e8
	rts
text	dc.b $d,$a,$d,$a,"Cracked by Was (Not Was).",$d,$a,$d,$a
	dc.b "I am the best.If you don't agree",$d,$a
	dc.b "then I shall wait for your cracked",$d,$a
	dc.b "version of GIANA SISTERS.",$d,$a,$0
tex2	dc.b $d,$a,"and wait ...",$d,$a,$0
	even
last	lea $1e680,a0
	lea $25000,a2
	move.l #$1b3b4,d4
	jsr $7fd1e
	jmp $4000
m7fd22  clr.l d6
	clr.l d7
l1	bsr.s nine
	move.b d5,d0
l2	bsr.s nine
	move.b d5,d1
	cmp.b d0,d1
	beq.s equal
	move.b d0,$0(a0,d7.l)
	addq.l #1,d7
	cmp.l d4,d7
	bgt.s done
	move.b d1,d0
	bra.s l2
equal	clr.l d3
	bsr.s nine
	move.b d5,d3
	cmp.b #0,d3
	beq.s done
l3	move.b d0,$0(a0,d7.l)
	addq.l #1,d7
	subq.l #1,d3
	cmp.l #0,d3
	beq.s l1
	cmp.l d4,d7
	bgt.s done
	bra.s l3
nine	move.b (a2)+,d5
done	rts
t1	dc.b "Press RETURN for standard game.",$d,$a,$d,$a
	dc.b "Enter starting level (01 - 32).",$d,$a
	dc.b "Note:- I will disable Hi-score save",$d,$a
	dc.b "routine if not standard game!",$d,$a
	dc.b "START LEVEL = ",$0
