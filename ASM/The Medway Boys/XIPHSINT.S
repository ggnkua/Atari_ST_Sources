		opt d-,s-
		move.l 4(a7),a0
		pea $200
		pea (a0)
		pea $4a0000
		trap #1
		add.l #12,sp 
		clr.l -(sp)
		move.w #$20,-(sp)
		trap #1
		addq.l #6,sp
		move.l d0,oldstack
		lea $4fffe,sp
		lea $50000,a0
cl1		move.l #0,(a0)+
		move.l #0,(a0)+
		move.l #0,(a0)+
		move.l #0,(a0)+
		cmp.l #$7fff0,a0
		blt cl1
		eor.b #3,$484.w
		bsr calc
		move.w #$12,-(sp)
		move.w #4,-(sp)
		move.w #3,-(sp)
		trap #13
		addq.l #6,sp
		move.l $70,oldvbl
		move.w #2,-(sp)
		trap #14
		addq.l #2,sp
		move.l d0,oldscreen
		move.w #0,-(sp)
		pea $70000
		pea $70000
		move.w #5,-(sp)
		trap #14
		add.l #12,sp
		move.l #(text-1),textptr
		move.l #mess,messpt
		move.w #0,count
		move.w #9,letsp
		lea music,a0
		lea $60000,a1
mcup		move.l (a0)+,(a1)+
		cmp.l #pic,a0
		blt mcup
		moveq #1,d0
		jsr $60000
		jsr $60004
		bsr hbon
		move.l #int,$70.w
		lea (pic+2),a0
		move.w #3,d0
sd		move.l (a0)+,$c(a0)
		dbf d0,sd
		move.w #$777,$c(a0)
		lea (pic+2),a0
		lea $8240.w,a1
		move.w #7,d0
pall		move.l (a0)+,(a1)+
		dbf d0,pall
		lea (pic+34+$30c0),a0
		lea $52000,a1
		move.w #1,d2
cul2		move.w #19,d1
cul1		move.w #11,d0
cul0		move.l (a0),(a1)+
		move.w 4(a0),(a1)+
		move.l #$ffff,(a0)
		move.w #$ffff,4(a0)
		lea $a0(a0),a0
		dbf d0,cul0
		sub.l #$778,a0
		dbf d1,cul1
		add.l #$780,a0
		dbf d2,cul2
		lea $70000,a0
		lea (pic+$22)(pc),a1
fff		move.l (a1)+,(a0)+
		move.l (a1)+,(a0)+
		cmp.l #$77d00,a0
		blt fff
		lea $721c6,a6
		move.w #16,d6
ver		move.w #9,d7
hor		moveq #0,d5
		move.w #17,-(sp)
		trap #14
		addq.l #2,sp
		move.l d0,d1
		and.l #$f,d1
		bset d1,d5
		move.w d5,(a6)
		moveq #0,d5
		ror.l #8,d0
		and.l #$f,d0
		bset d0,d5
		move.w d5,$288(a6)
		lea 16(a6),a6
		dbf d7,hor
		lea $460(a6),a6
		dbf d6,ver

key		lea $77446,a0
		lea $50000,a1
		move.w (a0),(a1)+
		move.w 8(a0),(a1)+
		move.w $10(a0),(a1)+
		move.w $18(a0),(a1)+	
		move.w $20(a0),(a1)+
		move.w $28(a0),(a1)+	
		move.w $30(a0),(a1)+
		move.w $38(a0),(a1)+	
		move.w $40(a0),(a1)+
		move.w $48(a0),(a1)+	
		move.w $50(a0),(a1)+
		move.w $58(a0),(a1)+	
		move.w $60(a0),(a1)+
		move.w $68(a0),(a1)+	
		move.w $70(a0),(a1)+
		move.w $78(a0),(a1)+	
		move.w $80(a0),(a1)+
		move.w $88(a0),(a1)+	
		move.w $90(a0),(a1)+
		move.w $98(a0),(a1)+
		lea $771c6,a0
		clr.w wait
ppp		tst.w wait
		beq ppp
		move.w #33,d0
sf1		move.b (a0),$280(a0)
		move.b $141(a0),$281(a0)
		move.b $1(a0),$141(a0)

		move.b $8(a0),$288(a0)
		move.b $149(a0),$289(a0)
		move.b $9(a0),$149(a0)

		move.b $10(a0),$290(a0)
		move.b $151(a0),$291(a0)
		move.b $11(a0),$151(a0)

		move.b $18(a0),$298(a0)
		move.b $159(a0),$299(a0)
		move.b $19(a0),$159(a0)

		move.b $20(a0),$2a0(a0)
		move.b $161(a0),$2a1(a0)
		move.b $21(a0),$161(a0)

		move.b $28(a0),$2a8(a0)
		move.b $169(a0),$2a9(a0)
		move.b $29(a0),$169(a0)

		move.b $30(a0),$2b0(a0)
		move.b $171(a0),$2b1(a0)
		move.b $31(a0),$171(a0)

		move.b $38(a0),$2b8(a0)
		move.b $179(a0),$2b9(a0)
		move.b $39(a0),$179(a0)

		move.b $40(a0),$2c0(a0)
		move.b $181(a0),$2c1(a0)
		move.b $41(a0),$181(a0)

		move.b $48(a0),$2c8(a0)
		move.b $189(a0),$2c9(a0)
		move.b $49(a0),$189(a0)

		move.b $50(a0),$2d0(a0)
		move.b $191(a0),$2d1(a0)
		move.b $51(a0),$191(a0)

		move.b $58(a0),$2d8(a0)
		move.b $199(a0),$2d9(a0)
		move.b $59(a0),$199(a0)

		move.b $60(a0),$2e0(a0)
		move.b $1a1(a0),$2e1(a0)
		move.b $61(a0),$1a1(a0)

		move.b $68(a0),$2e8(a0)
		move.b $1a9(a0),$2e9(a0)
		move.b $69(a0),$1a9(a0)

		move.b $70(a0),$2f0(a0)
		move.b $1b1(a0),$2f1(a0)
		move.b $71(a0),$1b1(a0)

		move.b $78(a0),$2f8(a0)
		move.b $1b9(a0),$2f9(a0)
		move.b $79(a0),$1b9(a0)

		move.b $80(a0),$300(a0)
		move.b $1c1(a0),$301(a0)
		move.b $81(a0),$1c1(a0)

		move.b $88(a0),$308(a0)
		move.b $1c9(a0),$309(a0)
		move.b $89(a0),$1c9(a0)

		move.b $90(a0),$310(a0)
		move.b $1d1(a0),$311(a0)
		move.b $91(a0),$1d1(a0)

		move.b $98(a0),$318(a0)
		move.b $1d9(a0),$319(a0)
		move.b $99(a0),$1d9(a0)

		lea -$280(a0),a0
		dbf d0,sf1

		lea $50000,a0
		lea $721c6,a1
		move.w (a0)+,(a1)
		move.w (a0)+,8(a1)
		move.w (a0)+,$10(a1)
		move.w (a0)+,$18(a1)
		move.w (a0)+,$20(a1)
		move.w (a0)+,$28(a1)
		move.w (a0)+,$30(a1)
		move.w (a0)+,$38(a1)
		move.w (a0)+,$40(a1)
		move.w (a0)+,$48(a1)
		move.w (a0)+,$50(a1)
		move.w (a0)+,$58(a1)
		move.w (a0)+,$60(a1)
		move.w (a0)+,$68(a1)
		move.w (a0)+,$70(a1)
		move.w (a0)+,$78(a1)
		move.w (a0)+,$80(a1)
		move.w (a0)+,$88(a1)
		move.w (a0)+,$90(a1)
		move.w (a0)+,$98(a1)

		bsr scroll
		tst.w count
		bne nonew
		addq.l #1,textptr
		move.w #4,count
		moveq #0,d0
	   	move.l textptr,a1
		move.b (a1),d0
		cmp.b #$ff,d0
		bne notend
		move.l #(text-1),textptr
		move.w #0,count
		bra lets
notend		sub.b #32,d0
		lsl.w #2,d0
		lea chartab,a2
		move.l $0(a2,d0.w),a1
		move.l a1,charptr
nonew		lea $77d99,a0
		move.l charptr,a1
		move.w #15,d1
nexl		movep.l (a1),d0
		movep.l d0,(a0)
		movep.l $a0(a1),d0
		movep.l d0,$a0(a0)
		lea $140(a0),a0
		lea $140(a1),a1
		dbf d1,nexl
		addq.l #1,charptr
		cmp.w #3,count
		bne endscl
		addq.l #6,charptr
endscl		subq.w #1,count

lets		moveq #0,d0
		move.l d0,d1
		move.l d0,d3
		move.l messpt,a0
		lea $52000,a1
		lea $72620,a2
		move.w textx,d0
		move.w texty,d1
		add.w d0,a0
		add.w d1,a0
		lsl.l #3,d0
		move.l d1,d2
		lsl.l #4,d1
		sub.l d2,d1
		lsl.l #3,d1
		add.l d1,d0
		add.l d0,a2
		subq.w #1,letsp
		beq displet
		lea $52ab0,a1
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		bra readkey
displet		move.w #9,letsp
		move.b (a0),d3
		cmp.b #64,d3
		bgt asclet
		cmp.b #47,d3
		bgt ascnum
		cmp.b #'!',d3
		beq pling
		cmp.b #'.',d3
		beq fullst
		move.b #39,d3
		bra gotlet
fullst		move.b #37,d3
		bra gotlet
pling		move.b #36,d3
		bra gotlet
ascnum		sub.b #22,d3
		bra gotlet
asclet		sub.b #'A',d3
gotlet		move.l d3,d4
		lsl.l #6,d3
		lsl.l #3,d4
		add.l d4,d3
		add.l d3,a1
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		lea $a0(a2),a2
		move.l (a1)+,(a2)
		move.w (a1)+,4(a2)
		addq.w #1,textx
		cmp.w #20,textx
		bne readkey
		clr.w textx
		add.w #20,texty
		cmp.w #160,texty
		bne readkey
		clr.w texty
		add.l #160,messpt
		cmp.l #endmess,messpt
		bne readkey
		move.l #mess,messpt

readkey		move.w #$ff,-(sp)
		move.w #6,-(sp)
		trap #1
		addq.l #4,sp
		tst.w d0
		beq key
		cmp.b #'1',d0
		bne not1
		lea file1,a6
		bra go
not1		cmp.b #'2',d0
		bne not2
		lea file2,a6
		bra go
not2		cmp.b #'3',d0
		bne key
		lea file3,a6

go		lea $50000,a0
clsl		move.l #0,(a0)+
		move.l #0,(a0)+
		move.l #0,(a0)+
		move.l #0,(a0)+
		cmp.l #$77e00,a0
		blt clsl
		eor.b #3,$484.w
		move.l oldvbl,$70
		bsr hboff
		move.w #0,-(sp)
		move.l oldscreen,-(sp)
		move.l oldscreen,-(sp)
		move.w #5,-(sp)
		trap #14
		add.l #12,sp
		move.w 	#8,-(sp)
		move.w	#4,-(sp)
		move.w	#3,-(sp)
		trap	#13
		addq.l	#6,sp
		move.w #7,-(sp)
		move.w #2,-(sp)
		trap #1
		addq.l #4,sp
		move.l oldstack,-(sp)
		move.w #$20,-(sp)
		trap #1
		addq.l #6,sp
		pea env
		pea com
		pea (a6)
		move.w #0,-(sp)
		move.w #$4b,-(sp)
		trap #1
		add.l #16,sp
		clr.w -(sp)
		trap #1

int	move.w #1,wait
	movem.l d0-d7/a0-a6,-(sp)
	movem.l (pic+2),d0-d7
	movem.l d0-d7,$8240.w
	move.b #0,$fa1b.w
	move.b #4,$fa21.w
	move.l #rast1,$120.w
	move.b #8,$fa1b.w
	move.w #4,bars
	bsr (music+8)
	movem.l (sp)+,d0-d7/a0-a6
	rte

rast1	move.b #0,$fa1b.w
	move.w #$334,$8240.w
	move.l #rast2,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast2	move.b #0,$fa1b.w
	move.w #$445,$8240.w
	move.l #rast3,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast3	move.b #0,$fa1b.w
	move.w #$556,$8240.w
	move.l #rast4,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast4	move.b #0,$fa1b.w
	move.w #$667,$8240.w
	move.l #rast5,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast5	move.b #0,$fa1b.w
	move.w #$777,$8240.w
	move.l #rast6,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast6	move.b #0,$fa1b.w
	move.w #$667,$8240.w
	move.l #rast7,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast7	move.b #0,$fa1b.w
	move.w #$556,$8240.w
	move.l #rast8,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast8	move.b #0,$fa1b.w
	move.w #$445,$8240.w
	move.l #rast9,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast9	move.b #0,$fa1b.w
	move.w #$334,$8240.w
	move.l #rast10,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast10	move.b #0,$fa1b.w
	move.w (pic+2),$8240.w
	subq.w #1,bars
	tst.w bars
	bmi nomore
	bne topb
	move.b #136,$fa21.w
	bra bot
topb	move.b #4,$fa21.w
bot	move.l #rast1,$120.w
endhbl	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

nomore	move.b #2,$fa21.w
	move.l #noborder,$120.w
	bra endhbl

noborder	move.b #0,$fa1b.w
		movem.l d0-d7/a0,-(sp)
		movem.l (font+2),d0-d7
		movem.l d0-d7,$8240.w
		lea $fa21.w,a0
		move.b #200,(a0)
		move.b #8,$fa1b.w
		move.b (a0),d0
llk1		cmp.b (a0),d0
		beq llk1
		move.b #$fc,$820a.w
		move.w #2,d0
lab1		nop
		dbf d0,lab1
		move.b #$fe,$820a.w
		movem.l (sp)+,d0-d7/a0
		move.w #3,bars
		move.b #0,$fa1b.w
		move.l #rast1a,$120.w
		move.b #2,$fa21.w
		move.b #8,$fa1b.w
		bclr #0,$fa0f.w
                rte

rast1a	move.b #0,$fa1b.w
	move.w #$334,$8240.w
	move.l #rast2a,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast2a	move.b #0,$fa1b.w
	move.w #$445,$8240.w
	move.l #rast3a,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast3a	move.b #0,$fa1b.w
	move.w #$556,$8240.w
	move.l #rast4a,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast4a	move.b #0,$fa1b.w
	move.w #$667,$8240.w
	move.l #rast5a,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast5a	move.b #0,$fa1b.w
	move.w #$556,$8240.w
	move.l #rast6a,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast6a	move.b #0,$fa1b.w
	move.w #$445,$8240.w
	move.l #rast7a,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast7a	move.b #0,$fa1b.w
	move.w #$334,$8240.w
	move.l #rast8a,$120.w
	move.b #1,$fa21.w
	move.b #8,$fa1b.w
	bclr #0,$fa0f.w
	rte

rast8a	move.b #0,$fa1b.w
	move.w (font+2),$8240.w
	subq.w #1,bars
	tst.w bars
	beq endras
	move.b #4,$fa21.w
	move.l #rast1a,$120.w
	move.b #8,$fa1b.w
endras	bclr #0,$fa0f.w
	rte

hbon            move.b  $fa07.w,old07
                move.b  $fa09.w,old09
                move.b  $fa0f.w,old0f
                move.b  $fa11.w,old11
                move.b  $fa13.w,old13
                move.b  $fa1b.w,old1b
                and.b   #$df,$fa09.w
                and.b   #$fe,$fa07 .w
		move.l $120.w,oldtb
		move.l  #hret,$120.w
                or.b    #1,$fa07.w
                or.b    #1,$fa13.w
                rts

hret		rte

hboff           move.w  sr,-(sp)
                move.w  #$2700,sr
                move.b  old07,$fa07.w
                move.b  old09,$fa09.w
                move.b  old0f,$fa0f.w
                move.b  old11,$fa11.w
                move.b  old13,$fa13.w
                move.b  old1b,$fa1b.w
                move.l  oldtb,$120.w
                rte

scroll		lea $77d00,a0
		move.w #31,d7
scroll1		movep.l $01(a0),d0
		movep.l d0,(a0)
		movep.l $08(a0),d0
		movep.l d0,$01(a0)
		movep.l $09(a0),d0
		movep.l d0,$08(a0)
		movep.l $10(a0),d0
		movep.l d0,$09(a0)
		movep.l $11(a0),d0
		movep.l d0,$10(a0)
		movep.l $18(a0),d0
		movep.l d0,$11(a0)
		movep.l $19(a0),d0
		movep.l d0,$18(a0)
		movep.l $20(a0),d0
		movep.l d0,$19(a0)
		movep.l $21(a0),d0
		movep.l d0,$20(a0)
		movep.l $28(a0),d0
		movep.l d0,$21(a0)
		movep.l $29(a0),d0
		movep.l d0,$28(a0)
		movep.l $30(a0),d0
		movep.l d0,$29(a0)
		movep.l $31(a0),d0
		movep.l d0,$30(a0)
		movep.l $38(a0),d0
		movep.l d0,$31(a0)
		movep.l $39(a0),d0
		movep.l d0,$38(a0)
		movep.l $40(a0),d0
		movep.l d0,$39(a0)
		movep.l $41(a0),d0
		movep.l d0,$40(a0)
		movep.l $48(a0),d0
		movep.l d0,$41(a0)
		movep.l $49(a0),d0
		movep.l d0,$48(a0)
		movep.l $50(a0),d0
		movep.l d0,$49(a0)
		movep.l $51(a0),d0
		movep.l d0,$50(a0)
		movep.l $58(a0),d0
		movep.l d0,$51(a0)
		movep.l $59(a0),d0
		movep.l d0,$58(a0)
		movep.l $60(a0),d0
		movep.l d0,$59(a0)
		movep.l $61(a0),d0
		movep.l d0,$60(a0)
		movep.l $68(a0),d0
		movep.l d0,$61(a0)
		movep.l $69(a0),d0
		movep.l d0,$68(a0)
		movep.l $70(a0),d0
		movep.l d0,$69(a0)
		movep.l $71(a0),d0
		movep.l d0,$70(a0)
		movep.l $78(a0),d0
		movep.l d0,$71(a0)
		movep.l $79(a0),d0
		movep.l d0,$78(a0)
		movep.l $80(a0),d0
		movep.l d0,$79(a0)
		movep.l $81(a0),d0
		movep.l d0,$80(a0)
		movep.l $88(a0),d0
		movep.l d0,$81(a0)
		movep.l $89(a0),d0
		movep.l d0,$88(a0)
		movep.l $90(a0),d0
		movep.l d0,$89(a0)
		movep.l $91(a0),d0
		movep.l d0,$90(a0)
		movep.l $98(a0),d0
		movep.l d0,$91(a0)
		movep.l $99(a0),d0
		movep.l d0,$98(a0)
		lea $a0(a0),a0
		dbf d7,scroll1
		rts

calc		lea chartab,a0
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$3c70),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$5020),(a0)+
		move.l #(font+34+$3c90),(a0)+
		move.l #(font+34+$5000),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$5030),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$3c80),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$2860),(a0)+
		move.l #(font+34+$2870),(a0)+
		move.l #(font+34+$2880),(a0)+
		move.l #(font+34+$2890),(a0)+
		move.l #(font+34+$3c00),(a0)+
		move.l #(font+34+$3c10),(a0)+
		move.l #(font+34+$3c20),(a0)+
		move.l #(font+34+$3c30),(a0)+
		move.l #(font+34+$3c40),(a0)+
		move.l #(font+34+$3c50),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$5040),(a0)+
		move.l #(font+34+$5050),(a0)+
		move.l #(font+34+$5060),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34),(a0)+
		move.l #(font+34+$10),(a0)+
		move.l #(font+34+$20),(a0)+
		move.l #(font+34+$30),(a0)+
		move.l #(font+34+$40),(a0)+
		move.l #(font+34+$50),(a0)+
		move.l #(font+34+$60),(a0)+
		move.l #(font+34+$70),(a0)+
		move.l #(font+34+$80),(a0)+
		move.l #(font+34+$90),(a0)+
		move.l #(font+34+$1400),(a0)+
		move.l #(font+34+$1410),(a0)+
		move.l #(font+34+$1420),(a0)+
		move.l #(font+34+$1430),(a0)+
		move.l #(font+34+$1440),(a0)+
		move.l #(font+34+$1450),(a0)+
		move.l #(font+34+$1460),(a0)+
		move.l #(font+34+$1470),(a0)+
		move.l #(font+34+$1480),(a0)+
		move.l #(font+34+$1490),(a0)+
		move.l #(font+34+$2800),(a0)+
		move.l #(font+34+$2810),(a0)+
		move.l #(font+34+$2820),(a0)+
		move.l #(font+34+$2830),(a0)+
		move.l #(font+34+$2840),(a0)+
		move.l #(font+34+$2850),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$5010),(a0)+
		move.l #(font+34+$5010),(a0)+
		rts

oldscreen	dc.l 0
bars		dc.w 0
textptr		dc.l 0
count		dc.w 0
charptr		dc.l 0
old07		dc.w 0
old09		dc.w 0
old0f		dc.w 0
old11		dc.w 0
old13		dc.w 0
old1b		dc.w 0
oldtb		dc.l 0
oldstack	dc.l 0
screen		dc.l 0
wait		dc.l 0
oldvbl		dc.l 0
textx		dc.w 0
texty		dc.w 0
letsp		dc.w 0
messpt		dc.l 0
chartab		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
text		dc.b "   OK GUYS, IT'S ZIPPY HERE AGAIN WITH A COUPLE OF NEW GAMES FOR YOU TO TAKE A LOOK AT.....   "
		DC.B "      THIS TIME WE HAVE XIPHOS AND MULTI PLAYER FOOTBALL MANAGER           PRESS 1 FOR XIPHOS, 2 FOR FOOTBALL MANAGER OR 3 FOR THE COMPLETE XIPHOS DOCS........       "
		DC.B "      I HEAR THAT THE PROTECTION ON SPEEDBALL 2 IS CAUSING PROBLEMS FOR SOME PEOPLE......  I'M GETTING AN ORIGINAL ON MONDAY SO EXPECT TO SEE IT CRACKED BY TUESDAY !!!         "
		DC.B "        IF YOU ARE HAVING PROBLEMS WITH 'ULTIMATE RIDE' AND YOU HAVE ON OLD TOS )1.08( THEN TRY UNPLUGGING YOUR EXTERNAL DRIVE AND THAT SHOULD SORT THINGS OUT             " 
		DC.B "      THIS IS NOT EXACTLY A GREAT INTRO, BUT I WAS PLAYING ABOUT WITH A MOVEP.L SCROLLER AND THOUGHT I MIGHT AS WELL"
		DC.B " ADD THE 'STARFIELD' ROUTINE FROM MENU 97 AND A TEXT ROUTINE AND SEE HOW IT TURNED OUT......   IT'S NOT SO BAD IS IT !!     "
		DC.B "       IF YOU'RE LOOKING FOR GREETINGS THEN LOOK AT THE TEXT ABOVE..........   I'VE EVEN MENTIONED AUTOMATION  )WELL, IT IS THE SEASON OF GOODWILL ISN'T IT !!(        "
		DC.B "     ONLY ABOUT 10 DAYS TO GO UNTIL CHRISTMAS, AND STILL ONLY A FEW GOOD GAMES HAVE APPEARED )LIKE BATTLE COMMAND AND POWER MONGER("
		DC.B "       WHAT HAPPENED TO TOTAL RECALL AND HARD DRIVIN' 2         MOST OF THE NEW STUFF IS UTTER SHIT, ESPECIALLY 'LINE OF FIRE'"
		DC.B " WHICH HAS TO BE THE CLASSIC EXAMPLE OF A CHRISTMAS CASH IN ON A BIG NAME TITLE         "
		DC.B "  OK, IT'S NOW 00 37 ON 15TH DECEMBER AND IT'S TIME FOR ME TO LEAVE YOU    )IS JAMES WHALE ON TV TONIGHT OR WHAT(            JUST ONE LAST"
		DC.B " THING....  IF YOU ARE INTO THRASH,DEATH,HARDCORE METAL )CALL IT WHAT YOU WILL( THEN I CAN RECOMMEND THE ALBUM 'SLAUGHTER IN THE VATICAN'"
		DC.B " BY EXHORDER.......  IMAGINE AN INTENSE COMBINATION OF DARK ANGEL, SLAYER AND SACRED REICH.....  BUY OR DIE !!!!               "
		DC.B "       OH YEAH, MERRY CHRISTMAS            WARP....        "
		dc.b $ff
mess		dc.b "  THE MEDWAY BOYS   "
		dc.b "                    "
		dc.b "     BRING YOU      "
		dc.b "                    "
		dc.b "1. XIPHOS           "
		dc.b "2. MULTI PLAYER     "
		dc.b "   FOOTBALL MANAGER "
		dc.b "3. XIPHOS DOCS      "

		dc.b " XIPHOS ORIGINAL BY "
		dc.b "                    "
		dc.b "   ASIF THE DREAD   "
		dc.b "   AND DEREK M.D.   "
		dc.b "                    "
		dc.b "FOOTBALL ORIGINAL BY"
		dc.b "                    "
		dc.b "  BILL AND WIZPOP   "

		dc.b " MEGA GREETINGS TO  "
		dc.b "                    "
		dc.b "     REPLICANTS     "
		dc.b "       EMPIRE       "
		dc.b "        BBC         "
		dc.b "        MCA         "
		dc.b "   POMPEY PIRATES   "
		dc.b "SUB HUMANS IN TURKEY"

		dc.b "    GREETINGS TO    "
		dc.b "                    "
		dc.b "      DELIGHT       "
		dc.b "     AUTOMATION     "
		dc.b "  FLAME OF FINLAND  "
		dc.b "   SEWER SOFTWARE   "
		dc.b "     LOST BOYS      "
		dc.b "        NEXT        "
endmess		dc.b 0
	even
		dc.w $ffff
env		dc.l 0
com		dc.l 0
file1		dc.b " ",0
file2		dc.b "LOAD.PRG",0,0
file3		dc.b "DOC.PRG",0

music		incbin 'c:\music\tune6.mus'
pic		incbin 'c:\art_prog.s\degas\pictures\title.pi1'
font		incbin 'c:\art_prog.s\degas\pictures\font_4.pi1'
