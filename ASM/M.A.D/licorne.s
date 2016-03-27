iera=$fffa07
ierb=$fffa09
isra=$fffa0f
imra=$fffa13
tbcr=$fffa1b
tbdr=$fffa21

	section text

debut	lea debut(pc),a6
	move.l a7,a5
	move.l 4(a5),d0
	move.l d0,pile
	
	pea intro(pc)
	move.w #$26,-(sp)
	trap #14
	addq.l #6,sp

	 clr.l -(sp)
	 trap #1
		
	move.l pile,a5
	add.l #$500,d0
	move.l d0,d1
	add.l a5,d1
	add.l #-2,d1
	move.l d1,a7
	move.l d0,-(sp)
	move.l a5,-(sp)
	move #0,-(sp)
	move #$4a,-(sp)
	trap #1
	lea 12(sp),sp
	
	pea env
	pea env
	pea fil
	move.w #3,-(sp)
	move.w #$4b,-(sp)
	trap #1
	lea 12(sp),sp
	
	move.l d0,a0
	lea $100(a0),a0
	move.l code,(a0)
	
	rept 3
	move.l d0,-(sp)
	endr
	
	move.w #4,-(sp)
	move.w #$4b,-(sp)
	trap #1
	lea 12(sp),sp
	bra.s fini
	
intro	move.b $ffff8260.w,res
	btst #1,$ffff8260.w
	beq.s cont
	
	pea text(pc)
	move #9,-(sp)
	trap #1
	addq.l #6,sp
	
fini	bra.s fini
	
cont	move.b $fffffa07.w,mfp1
	move.b $fffffa09.w,mfp2
	move.b $fffffa0f.w,mfp3
	move.b $fffffa13.w,mfp4
	move.b $fffffa1b.w,mfp5
	move.b $fffffa21.w,mfp6
	
	sf $fffffa07.w
	sf $fffffa09.w
	
	move.l #buffer,d0
	and.l #$ffffff00,d0
	add.l #256,d0
	move.l d0,ecran
	
	move.l $44e.w,anc_ecr
		
	sf $ffff8260.w
	
	move.l d0,a1
	lea screen,a0
	move.l #((160*185)/4)/4-1,d0
copy	rept 4
	move.l (a0)+,(a1)+
	endr
	dbf d0,copy
	
	lea fontes+(160*128),a0
	move.l #2560/4-1,d0
copy1	rept 4
	move.l (a0)+,(a1)+
	endr
	dbf d0,copy1
	
	movem.l $ffff8240.w,d0-d7
	movem.l d0-d7,anc_pal
	
	move.b ecran+1,$ffff8201.w
	move.b ecran+2,$ffff8203.w
		
	lea music1(pc),a0
	lea $7129c,a1
	move.l #$1e3a,d0
copy3	move.b (a0)+,(a1)+
	dbf d0,copy3
	move.b #$e,$7204c
	
	move.l #scroll1,type_scr+2
	
	move.l #message,mes_pnt
	move.b #4,nb_bit
	
	lea tb_spr(pc),a5
	lea tb_spr1(pc),a3
	moveq #0,d0
	move.l (a5,d0.w),a0
	move.l (a3,d0.w),a2
	move.l (a5,d0.w),a4
	bsr sprites1
	
	move.l $70.w,anc_vbl
	move.l #vbl,$70.w
	move.l $120.w,anc_hbl
	move.l #hbl,$120.w
	
	dc.w $a00a
	move.b #$12,$fffffc02.w
	
	sf $fffffa1b.w
	bset #0,$fffffa07.w
	bset #0,$fffffa13.w
	
loop	move.b vsync,d0
wait	cmp.b vsync,d0
	beq.s wait
	
	cmp.b #$39,$fffffc02.w
	beq cont1
	
	cmp.b #$3b,$fffffc02.w
	bne.s suit
	move.l #pal1,hbl7+4
	
suit	cmp.b #$3c,$fffffc02.w
	bne.s suit1
	move.l #pal2,hbl7+4
	
suit1	cmp.b #$3d,$fffffc02.w
	bne.s suit2
	move.l #pal3,hbl7+4
	
suit2	cmp.b #$3e,$fffffc02.w
	bne.s suit3
	move.l #pal4,hbl7+4
	
suit3	cmp.b #$3f,$fffffc02.w
	bne.s suit4
	move.l #pal5,hbl7+4
	
suit4	cmp.b #$40,$fffffc02.w
	bne.s suit5
	move.l #pal6,hbl7+4

suit5	cmp.b #$41,$fffffc02.w
	bne.s suit6
	move.l #pal7,hbl7+4
	
suit6	bra loop
		
cont1	sf $fffffa07.w
	sf $fffffa09.w

	dc.w $a009
	move.b #8,$fffffc02.w
	
	move.b mfp1,$fffffa07.w
	move.b mfp2,$fffffa09.w
	move.b mfp3,$fffffa0f.w
	move.b mfp4,$fffffa13.w
	move.b mfp5,$fffffa1b.w
	move.b mfp6,$fffffa21.w
	
	move.l anc_vbl,$70.w
	move.l anc_hbl,$120.w
	
	movem.l anc_pal,d0-d7
	movem.l d0-d7,$ffff8240.w
	
	move.b res,$ffff8260.w
	move.b anc_ecr+1,$ffff8201.w
	move.b anc_ecr+2,$ffff8203.w
	
	pea chut(pc)
	move #$20,-(sp)
	trap #14
	addq.l #6,sp
	
	rts
		
*-------------------------------------------------------------------

vbl	sf $fffffa1b
	move.b #5,$fffffa21.w
	move.b #8,$fffffa1b.w
	movem.l pal(pc),d0-d7
	movem.l d0-d7,$ffff8240.w
	bsr scr_txt
musak	jsr $7129c
	not.b vsync
	rte
	
hbl	move #$111,$ffff8240.w
	sf $fffffa1b.w
	move.b #4,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #rage,$120.w
	bclr #0,$fffffa0f.w
	rte
	
rage	move.l #$01110057,$ffff8240.w
	move.l #$00670077,$ffff8244.w
	move.l #$03770477,$ffff8248.w
	sf $fffffa1b.w
	move.b #6,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl1,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl1	move #$222,$ffff8240.w
	sf $fffffa1b.w
	move.b #2,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #rage1,$120.w
	bclr #0,$fffffa0f.w
	rte
	
rage1	move.l #$2220477,$ffff8240.w
	move.l #$5770677,$ffff8244.w
	move.l #$7770202,$ffff8248.w
	sf $fffffa1b.w
	move.b #11,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #rage2,$120.w
	bclr #0,$fffffa0f.w
	rte
	
rage2	move.l #$2220212,$ffff8240.w
	move.l #$2220323,$ffff8244.w
	move.l #$3330434,$ffff8248.w
	sf $fffffa1b.w
	move.b #2,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl2,$120.w
	bclr #0,$fffffa0f.w
	rte
	
	
hbl2	move #$333,$ffff8240.w
	sf $fffffa1b.w
	move.b #3,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #rage3,$120.w
	bclr #0,$fffffa0f.w
	rte
	
rage3	move.l #$3330444,$ffff8240.w
	move.l #$5450555,$ffff8244.w
	move.l #$6560666,$ffff8248.w
	sf $fffffa1b.w
	move.b #17,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl3,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl3	move.l #$4440100,$ffff8240.w
	move.l #$2100321,$ffff8244.w
	move.l #$4320543,$ffff8248.w
	sf $fffffa1b.w
	move.b #25,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl4,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl4	move.l #$5550100,$ffff8240.w
	move.l #$2010312,$ffff8244.w
	move.l #$4230534,$ffff8248.w
	sf $fffffa1b.w
	move.b #31,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl5,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl5	move.l #$6660010,$ffff8240.w
	move.l #$1200231,$ffff8244.w
	move.l #$3420453,$ffff8248.w
	sf $fffffa1b.w
	move.b #35,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl6,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl6	move.l #$7770001,$ffff8240.w
	move.l #$0120123,$ffff8244.w
	move.l #$2340345,$ffff8248.w
	sf $fffffa1b.w
	move.b #43,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl7,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl7	movem.l pal1,d0-d7
	movem.l d0-d7,$ffff8240.w
	sf $fffffa1b.w
	move.b #15,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl8,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl8	lea pal_bar,a6
	move.b #16,compt
	rept 119
	nop
	endr
	sf $ffff820a.w
	rept 8
	nop
	endr
	move.b #2,$ffff820a.w
	sf $fffffa1b.w
	move.b #1,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl9,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl9	subq.b #1,compt
	beq.s hbl10
	move.w (a6)+,$ffff8240.w
	bclr #0,$fffffa0f.w
	rte
	
hbl10	sf $fffffa1b.w
	move.l #hbl,$120.w
	bclr #0,$fffffa0f.w
	rte
	
*-------------------------------------------------------------------
	
scr_txt	moveq #32,d0
	lea car_buf,a5
	move.l ecran,a4
	lea 160*190(a4),a4
type_scr	jmp $ffffffff
	
scroll1	move.b 3(a4),2(a4)
	move.b 10(a4),3(a4)
	move.b 11(a4),10(a4)
	move.b 18(a4),11(a4)
	move.b 19(a4),18(a4)
	move.b 26(a4),19(a4)
	move.b 27(a4),26(a4)
	move.b 34(a4),27(a4)
	move.b 35(a4),34(a4)
	move.b 42(a4),35(a4)
	move.b 43(a4),42(a4)
	move.b 50(a4),43(a4)
	move.b 51(a4),50(a4)
	move.b 58(a4),51(a4)
	move.b 59(a4),58(a4)
	move.b 66(a4),59(a4)
	move.b 67(a4),66(a4)
	move.b 74(a4),67(a4)
	move.b 75(a4),74(a4)
	move.b 82(a4),75(a4)
	move.b 83(a4),82(a4)
	move.b 90(a4),83(a4)
	move.b 91(a4),90(a4)
	move.b 98(a4),91(a4)
	move.b 99(a4),98(a4)
	move.b 106(a4),99(a4)
	move.b 107(a4),106(a4)
	move.b 114(a4),107(a4)
	move.b 115(a4),114(a4)
	move.b 122(a4),115(a4)
	move.b 123(a4),122(a4)
	move.b 130(a4),123(a4)
	move.b 131(a4),130(a4)
	move.b 138(a4),131(a4)
	move.b 139(a4),138(a4)
	move.b 146(a4),139(a4)
	move.b 147(a4),146(a4)
	move.b 154(a4),147(a4)
	move.b 155(a4),154(a4)
	move.b 2(a5),155(a4)
	move.b 3(a5),2(a5)
	move.b 8(a5),3(a5)
	move.b 9(a5),8(a5)
	
	move.b 5(a4),4(a4)
	move.b 12(a4),5(a4)
	move.b 13(a4),12(a4)
	move.b 20(a4),13(a4)
	move.b 21(a4),20(a4)
	move.b 28(a4),21(a4)
	move.b 29(a4),28(a4)
	move.b 36(a4),29(a4)
	move.b 37(a4),36(a4)
	move.b 44(a4),37(a4)
	move.b 45(a4),44(a4)
	move.b 52(a4),45(a4)
	move.b 53(a4),52(a4)
	move.b 60(a4),53(a4)
	move.b 61(a4),60(a4)
	move.b 68(a4),61(a4)
	move.b 69(a4),68(a4)
	move.b 76(a4),69(a4)
	move.b 77(a4),76(a4)
	move.b 84(a4),77(a4)
	move.b 85(a4),84(a4)
	move.b 92(a4),85(a4)
	move.b 93(a4),92(a4)
	move.b 100(a4),93(a4)
	move.b 101(a4),100(a4)
	move.b 108(a4),101(a4)
	move.b 109(a4),108(a4)
	move.b 116(a4),109(a4)
	move.b 117(a4),116(a4)
	move.b 124(a4),117(a4)
	move.b 125(a4),124(a4)
	move.b 132(a4),125(a4)
	move.b 133(a4),132(a4)
	move.b 140(a4),133(a4)
	move.b 141(a4),140(a4)
	move.b 148(a4),141(a4)
	move.b 149(a4),148(a4)
	move.b 156(a4),149(a4)
	move.b 157(a4),156(a4)
	move.b 4(a5),157(a4)
	move.b 5(a5),4(a5)
	move.b 10(a5),5(a5)
	move.b 11(a5),10(a5)
	
	lea 12(a5),a5
	lea 160(a4),a4
	dbf d0,scroll1
	subq.b #1,nb_bit
	beq nextchar
	bra sprites
	
scroll2	move.b 3(a4),2(a4)
	move.b 10(a4),3(a4)
	move.b 160+11(a4),10(a4)
	move.b 160+18(a4),160+11(a4)
	move.b 160*2+19(a4),160+18(a4)
	move.b 160*2+26(a4),160*2+19(a4)
	move.b 160*3+27(a4),160*2+26(a4)
	move.b 160*3+34(a4),160*3+27(a4)
	move.b 160*3+35(a4),160*3+34(a4)
	move.b 160*3+42(a4),160*3+35(a4)
	move.b 160*2+43(a4),160*3+42(a4)
	move.b 160*2+50(a4),160*2+43(a4)
	move.b 160+51(a4),160*2+50(a4)
	move.b 160+58(a4),160+51(a4)
	move.b 59(a4),160+58(a4)
	move.b 66(a4),59(a4)
	move.b 67(a4),66(a4)
	move.b 74(a4),67(a4)
	move.b 160+75(a4),74(a4)
	move.b 160+82(a4),160+75(a4)
	move.b 160*2+83(a4),160+82(a4)
	move.b 160*2+90(a4),160*2+83(a4)
	move.b 160*3+91(a4),160*2+90(a4)
	move.b 160*3+98(a4),160*3+91(a4)
	move.b 160*3+99(a4),160*3+98(a4)
	move.b 160*3+106(a4),160*3+99(a4)
	move.b 160*2+107(a4),160*3+106(a4)
	move.b 160*2+114(a4),160*2+107(a4)
	move.b 160+115(a4),160*2+114(a4)
	move.b 160+122(a4),160+115(a4)
	move.b 123(a4),160+122(a4)
	move.b 130(a4),123(a4)
	move.b 131(a4),130(a4)
	move.b 138(a4),131(a4)
	move.b 160+139(a4),138(a4)
	move.b 160+146(a4),160+139(a4)
	move.b 160*2+147(a4),160+146(a4)
	move.b 160*2+154(a4),160*2+147(a4)
	move.b 160*3+155(a4),160*2+154(a4)
	move.b 2(a5),160*3+155(a4)
	move.b 3(a5),2(a5)
	move.b 8(a5),3(a5)
	move.b 9(a5),8(a5)
	
	move.b 5(a4),4(a4)
	move.b 12(a4),5(a4)
	move.b 160+13(a4),12(a4)
	move.b 160+20(a4),160+13(a4)
	move.b 160*2+21(a4),160+20(a4)
	move.b 160*2+28(a4),160*2+21(a4)
	move.b 160*3+29(a4),160*2+28(a4)
	move.b 160*3+36(a4),160*3+29(a4)
	move.b 160*3+37(a4),160*3+36(a4)
	move.b 160*3+44(a4),160*3+37(a4)
	move.b 160*2+45(a4),160*3+44(a4)
	move.b 160*2+52(a4),160*2+45(a4)
	move.b 160+53(a4),160*2+52(a4)
	move.b 160+60(a4),160+53(a4)
	move.b 61(a4),160+60(a4)
	move.b 68(a4),61(a4)
	move.b 69(a4),68(a4)
	move.b 76(a4),69(a4)
	move.b 160+77(a4),76(a4)
	move.b 160+84(a4),160+77(a4)
	move.b 160*2+85(a4),160+84(a4)
	move.b 160*2+92(a4),160*2+85(a4)
	move.b 160*3+93(a4),160*2+92(a4)
	move.b 160*3+100(a4),160*3+93(a4)
	move.b 160*3+101(a4),160*3+100(a4)
	move.b 160*3+108(a4),160*3+101(a4)
	move.b 160*2+109(a4),160*3+108(a4)
	move.b 160*2+116(a4),160*2+109(a4)
	move.b 160+117(a4),160*2+116(a4)
	move.b 160+124(a4),160+117(a4)
	move.b 125(a4),160+124(a4)
	move.b 132(a4),125(a4)
	move.b 133(a4),132(a4)
	move.b 140(a4),133(a4)
	move.b 160+141(a4),140(a4)
	move.b 160+148(a4),160+141(a4)
	move.b 160*2+149(a4),160+148(a4)
	move.b 160*2+156(a4),160*2+149(a4)
	move.b 160*3+157(a4),160*2+156(a4)
	move.b 4(a5),160*3+157(a4)
	move.b 5(a5),4(a5)
	move.b 10(a5),5(a5)
	move.b 11(a5),10(a5)
	
	lea 12(a5),a5
	lea 160(a4),a4
	dbf d0,scroll2
	subq.b #1,nb_bit
	beq nextchar
	bra sprites
	
scroll3	move.b 3(a4),2(a4)
	move.b 10(a4),3(a4)
	move.b 160+11(a4),10(a4)
	move.b 160*2+18(a4),160+11(a4)
	move.b 160*3+19(a4),160*2+18(a4)
	move.b 160*3+26(a4),160*3+19(a4)
	move.b 160*2+27(a4),160*3+26(a4)
	move.b 160+34(a4),160*2+27(a4)
	move.b 35(a4),160+34(a4)
	move.b 42(a4),35(a4)
	move.b 160+43(a4),42(a4)
	move.b 160*2+50(a4),160+43(a4)
	move.b 160*3+51(a4),160*2+50(a4)
	move.b 160*3+58(a4),160*3+51(a4)
	move.b 160*2+59(a4),160*3+58(a4)
	move.b 160+66(a4),160*2+59(a4)
	move.b 67(a4),160+66(a4)
	move.b 74(a4),67(a4)
	move.b 160+75(a4),74(a4)
	move.b 160*2+82(a4),160+75(a4)
	move.b 160*3+83(a4),160*2+82(a4)
	move.b 160*3+90(a4),160*3+83(a4)
	move.b 160*2+91(a4),160*3+90(a4)
	move.b 160+98(a4),160*2+91(a4)
	move.b 99(a4),160+98(a4)
	move.b 106(a4),99(a4)
	move.b 160+107(a4),106(a4)
	move.b 160*2+114(a4),160+107(a4)
	move.b 160*3+115(a4),160*2+114(a4)
	move.b 160*3+122(a4),160*3+115(a4)
	move.b 160*2+123(a4),160*3+122(a4)
	move.b 160+130(a4),160*2+123(a4)
	move.b 131(a4),160+130(a4)
	move.b 138(a4),131(a4)
	move.b 160+139(a4),138(a4)
	move.b 160*2+146(a4),160+139(a4)
	move.b 160*3+147(a4),160*2+146(a4)
	move.b 160*3+154(a4),160*3+147(a4)
	move.b 160*2+155(a4),160*3+154(a4)
	move.b 2(a5),160*2+155(a4)
	move.b 3(a5),2(a5)
	move.b 8(a5),3(a5)
	move.b 9(a5),8(a5)
	
	move.b 5(a4),4(a4)
	move.b 12(a4),5(a4)
	move.b 160+13(a4),12(a4)
	move.b 160*2+20(a4),160+13(a4)
	move.b 160*3+21(a4),160*2+20(a4)
	move.b 160*3+28(a4),160*3+21(a4)
	move.b 160*2+29(a4),160*3+28(a4)
	move.b 160+36(a4),160*2+29(a4)
	move.b 37(a4),160+36(a4)
	move.b 44(a4),37(a4)
	move.b 160+45(a4),44(a4)
	move.b 160*2+52(a4),160+45(a4)
	move.b 160*3+53(a4),160*2+52(a4)
	move.b 160*3+60(a4),160*3+53(a4)
	move.b 160*2+61(a4),160*3+60(a4)
	move.b 160+68(a4),160*2+61(a4)
	move.b 69(a4),160+68(a4)
	move.b 76(a4),69(a4)
	move.b 160+77(a4),76(a4)
	move.b 160*2+84(a4),160+77(a4)
	move.b 160*3+85(a4),160*2+84(a4)
	move.b 160*3+92(a4),160*3+85(a4)
	move.b 160*2+93(a4),160*3+92(a4)
	move.b 160+100(a4),160*2+93(a4)
	move.b 101(a4),160+100(a4)
	move.b 108(a4),101(a4)
	move.b 160+109(a4),108(a4)
	move.b 160*2+116(a4),160+109(a4)
	move.b 160*3+117(a4),160*2+116(a4)
	move.b 160*3+124(a4),160*3+117(a4)
	move.b 160*2+125(a4),160*3+124(a4)
	move.b 160+132(a4),160*2+125(a4)
	move.b 133(a4),160+132(a4)
	move.b 140(a4),133(a4)
	move.b 160+141(a4),140(a4)
	move.b 160*2+148(a4),160+141(a4)
	move.b 160*3+149(a4),160*2+148(a4)
	move.b 160*3+156(a4),160*3+149(a4)
	move.b 160*2+157(a4),160*3+156(a4)
	move.b 4(a5),160*2+157(a4)
	move.b 5(a5),4(a5)
	move.b 10(a5),5(a5)
	move.b 11(a5),10(a5)
	
	lea 12(a5),a5
	lea 160(a4),a4
	dbf d0,scroll3
	subq.b #1,nb_bit
	beq nextchar
	bra sprites
	
scroll4	move.b 3(a4),2(a4)
	move.b 160+10(a4),3(a4)
	move.b 160*2+11(a4),160+10(a4)
	move.b 160*3+18(a4),160*2+11(a4)
	move.b 160*4+19(a4),160*3+18(a4)
	move.b 160*5+26(a4),160*4+19(a4)
	move.b 160*6+27(a4),160*5+26(a4)
	move.b 160*7+34(a4),160*6+27(a4)
	move.b 160*8+35(a4),160*7+34(a4)
	move.b 160*9+42(a4),160*8+35(a4)
	move.b 160*10+43(a4),160*9+42(a4)
	move.b 160*11+50(a4),160*10+43(a4)
	move.b 160*12+51(a4),160*11+50(a4)
	move.b 160*13+58(a4),160*12+51(a4)
	move.b 160*14+59(a4),160*13+58(a4)
	move.b 160*15+66(a4),160*14+59(a4)
	move.b 160*16+67(a4),160*15+66(a4)
	move.b 160*17+74(a4),160*16+67(a4)
	move.b 160*18+75(a4),160*17+74(a4)
	move.b 160*19+82(a4),160*18+75(a4)
	move.b 160*18+83(a4),160*19+82(a4)
	move.b 160*17+90(a4),160*18+83(a4)
	move.b 160*16+91(a4),160*17+90(a4)
	move.b 160*15+98(a4),160*16+91(a4)
	move.b 160*14+99(a4),160*15+98(a4)
	move.b 160*13+106(a4),160*14+99(a4)
	move.b 160*12+107(a4),160*13+106(a4)
	move.b 160*11+114(a4),160*12+107(a4)
	move.b 160*10+115(a4),160*11+114(a4)
	move.b 160*9+122(a4),160*10+115(a4)
	move.b 160*8+123(a4),160*9+122(a4)
	move.b 160*7+130(a4),160*8+123(a4)
	move.b 160*6+131(a4),160*7+130(a4)
	move.b 160*5+138(a4),160*6+131(a4)
	move.b 160*4+139(a4),160*5+138(a4)
	move.b 160*3+146(a4),160*4+139(a4)
	move.b 160*2+147(a4),160*3+146(a4)
	move.b 160+154(a4),160*2+147(a4)
	move.b 155(a4),160+154(a4)
	move.b 2(a5),155(a4)
	move.b 3(a5),2(a5)
	move.b 8(a5),3(a5)
	move.b 9(a5),8(a5)
	
	move.b 5(a4),4(a4)
	move.b 160+12(a4),5(a4)
	move.b 160*2+13(a4),160+12(a4)
	move.b 160*3+20(a4),160*2+13(a4)
	move.b 160*4+21(a4),160*3+20(a4)
	move.b 160*5+28(a4),160*4+21(a4)
	move.b 160*6+29(a4),160*5+28(a4)
	move.b 160*7+36(a4),160*6+29(a4)
	move.b 160*8+37(a4),160*7+36(a4)
	move.b 160*9+44(a4),160*8+37(a4)
	move.b 160*10+45(a4),160*9+44(a4)
	move.b 160*11+52(a4),160*10+45(a4)
	move.b 160*12+53(a4),160*11+52(a4)
	move.b 160*13+60(a4),160*12+53(a4)
	move.b 160*14+61(a4),160*13+60(a4)
	move.b 160*15+68(a4),160*14+61(a4)
	move.b 160*16+69(a4),160*15+68(a4)
	move.b 160*17+76(a4),160*16+69(a4)
	move.b 160*18+77(a4),160*17+76(a4)
	move.b 160*19+84(a4),160*18+77(a4)
	move.b 160*18+85(a4),160*19+84(a4)
	move.b 160*17+92(a4),160*18+85(a4)
	move.b 160*16+93(a4),160*17+92(a4)
	move.b 160*15+100(a4),160*16+93(a4)
	move.b 160*14+101(a4),160*15+100(a4)
	move.b 160*13+108(a4),160*14+101(a4)
	move.b 160*12+109(a4),160*13+108(a4)
	move.b 160*11+116(a4),160*12+109(a4)
	move.b 160*10+117(a4),160*11+116(a4)
	move.b 160*9+124(a4),160*10+117(a4)
	move.b 160*8+125(a4),160*9+124(a4)
	move.b 160*7+132(a4),160*8+125(a4)
	move.b 160*6+133(a4),160*7+132(a4)
	move.b 160*5+140(a4),160*6+133(a4)
	move.b 160*4+141(a4),160*5+140(a4)
	move.b 160*3+148(a4),160*4+141(a4)
	move.b 160*2+149(a4),160*3+148(a4)
	move.b 160+156(a4),160*2+149(a4)
	move.b 157(a4),160+156(a4)
	move.b 4(a5),157(a4)
	move.b 5(a5),4(a5)
	move.b 10(a5),5(a5)
	move.b 11(a5),10(a5)
	
	lea 12(a5),a5
	lea 160(a4),a4
	dbf d0,scroll4
	subq.b #1,nb_bit
	beq nextchar
	bra sprites

scroll5	move.b 160*19+3(a4),160*20+2(a4)
	move.b 160*18+10(a4),160*19+3(a4)
	move.b 160*17+11(a4),160*18+10(a4)
	move.b 160*16+18(a4),160*17+11(a4)
	move.b 160*15+19(a4),160*16+18(a4)
	move.b 160*14+26(a4),160*15+19(a4)
	move.b 160*13+27(a4),160*14+26(a4)
	move.b 160*12+34(a4),160*13+27(a4)
	move.b 160*11+35(a4),160*12+34(a4)
	move.b 160*10+42(a4),160*11+35(a4)
	move.b 160*9+43(a4),160*10+42(a4)
	move.b 160*8+50(a4),160*9+43(a4)
	move.b 160*7+51(a4),160*8+50(a4)
	move.b 160*6+58(a4),160*7+51(a4)
	move.b 160*5+59(a4),160*6+58(a4)
	move.b 160*4+66(a4),160*5+59(a4)
	move.b 160*3+67(a4),160*4+66(a4)
	move.b 160*2+74(a4),160*3+67(a4)
	move.b 160+75(a4),160*2+74(a4)
	move.b 82(a4),160+75(a4)
	move.b 160+83(a4),82(a4)
	move.b 160*2+90(a4),160+83(a4)
	move.b 160*3+91(a4),160*2+90(a4)
	move.b 160*4+98(a4),160*3+91(a4)
	move.b 160*5+99(a4),160*4+98(a4)
	move.b 160*6+106(a4),160*5+99(a4)
	move.b 160*7+107(a4),160*6+106(a4)
	move.b 160*8+114(a4),160*7+107(a4)
	move.b 160*9+115(a4),160*8+114(a4)
	move.b 160*10+122(a4),160*9+115(a4)
	move.b 160*11+123(a4),160*10+122(a4)
	move.b 160*12+130(a4),160*11+123(a4)
	move.b 160*13+131(a4),160*12+130(a4)
	move.b 160*14+138(a4),160*13+131(a4)
	move.b 160*15+139(a4),160*14+138(a4)
	move.b 160*16+146(a4),160*15+139(a4)
	move.b 160*17+147(a4),160*16+146(a4)
	move.b 160*18+154(a4),160*17+147(a4)
	move.b 160*19+155(a4),160*18+154(a4)
	move.b 2(a5),160*19+155(a4)
	move.b 3(a5),2(a5)
	move.b 8(a5),3(a5)
	move.b 9(a5),8(a5)
	
	move.b 160*19+5(a4),160*20+4(a4)
	move.b 160*18+12(a4),160*19+5(a4)
	move.b 160*17+13(a4),160*18+12(a4)
	move.b 160*16+20(a4),160*17+13(a4)
	move.b 160*15+21(a4),160*16+20(a4)
	move.b 160*14+28(a4),160*15+21(a4)
	move.b 160*13+29(a4),160*14+28(a4)
	move.b 160*12+36(a4),160*13+29(a4)
	move.b 160*11+37(a4),160*12+36(a4)
	move.b 160*10+44(a4),160*11+37(a4)
	move.b 160*9+45(a4),160*10+44(a4)
	move.b 160*8+52(a4),160*9+45(a4)
	move.b 160*7+53(a4),160*8+52(a4)
	move.b 160*6+60(a4),160*7+53(a4)
	move.b 160*5+61(a4),160*6+60(a4)
	move.b 160*4+68(a4),160*5+61(a4)
	move.b 160*3+69(a4),160*4+68(a4)
	move.b 160*2+76(a4),160*3+69(a4)
	move.b 160+77(a4),160*2+76(a4)
	move.b 84(a4),160+77(a4)
	move.b 160+85(a4),84(a4)
	move.b 160*2+92(a4),160+85(a4)
	move.b 160*3+93(a4),160*2+92(a4)
	move.b 160*4+100(a4),160*3+93(a4)
	move.b 160*5+101(a4),160*4+100(a4)
	move.b 160*6+108(a4),160*5+101(a4)
	move.b 160*7+109(a4),160*6+108(a4)
	move.b 160*8+116(a4),160*7+109(a4)
	move.b 160*9+117(a4),160*8+116(a4)
	move.b 160*10+124(a4),160*9+117(a4)
	move.b 160*11+125(a4),160*10+124(a4)
	move.b 160*12+132(a4),160*11+125(a4)
	move.b 160*13+133(a4),160*12+132(a4)
	move.b 160*14+140(a4),160*13+133(a4)
	move.b 160*15+141(a4),160*14+140(a4)
	move.b 160*16+148(a4),160*15+141(a4)
	move.b 160*17+149(a4),160*16+148(a4)
	move.b 160*18+156(a4),160*17+149(a4)
	move.b 160*19+157(a4),160*18+156(a4)
	move.b 4(a5),160*19+157(a4)
	move.b 5(a5),4(a5)
	move.b 10(a5),5(a5)
	move.b 11(a5),10(a5)
	
	lea 12(a5),a5
	lea 160(a4),a4
	dbf d0,scroll5
	subq.b #1,nb_bit
	beq nextchar
	bra sprites

scroll6	move.b 3(a4),2(a4)
	move.b 10(a4),3(a4)
	move.b 11(a4),10(a4)
	move.b 18(a4),11(a4)
	move.b 19(a4),18(a4)
	move.b 26(a4),19(a4)
	move.b 27(a4),26(a4)
	move.b 160*30+34(a4),27(a4)
	move.b 160*30+35(a4),160*30+34(a4)
	move.b 160*30+42(a4),160*30+35(a4)
	move.b 160*30+43(a4),160*30+42(a4)
	move.b 160*30+50(a4),160*30+43(a4)
	move.b 160*30+51(a4),160*30+50(a4)
	move.b 160*30+58(a4),160*30+51(a4)
	move.b 160*30+59(a4),160*30+58(a4)
	move.b 66(a4),160*30+59(a4)
	move.b 67(a4),66(a4)
	move.b 74(a4),67(a4)
	move.b 75(a4),74(a4)
	move.b 82(a4),75(a4)
	move.b 83(a4),82(a4)
	move.b 90(a4),83(a4)
	move.b 91(a4),90(a4)
	move.b 160*30+98(a4),91(a4)
	move.b 160*30+99(a4),160*30+98(a4)
	move.b 160*30+106(a4),160*30+99(a4)
	move.b 160*30+107(a4),160*30+106(a4)
	move.b 160*30+114(a4),160*30+107(a4)
	move.b 160*30+115(a4),160*30+114(a4)
	move.b 160*30+122(a4),160*30+115(a4)
	move.b 160*30+123(a4),160*30+122(a4)
	move.b 130(a4),160*30+123(a4)
	move.b 131(a4),130(a4)
	move.b 138(a4),131(a4)
	move.b 139(a4),138(a4)
	move.b 146(a4),139(a4)
	move.b 147(a4),146(a4)
	move.b 154(a4),147(a4)
	move.b 155(a4),154(a4)
	move.b 2(a5),155(a4)
	move.b 3(a5),2(a5)
	move.b 8(a5),3(a5)
	move.b 9(a5),8(a5)
	
	move.b 5(a4),4(a4)
	move.b 12(a4),5(a4)
	move.b 13(a4),12(a4)
	move.b 20(a4),13(a4)
	move.b 21(a4),20(a4)
	move.b 28(a4),21(a4)
	move.b 29(a4),28(a4)
	move.b 160*30+36(a4),29(a4)
	move.b 160*30+37(a4),160*30+36(a4)
	move.b 160*30+44(a4),160*30+37(a4)
	move.b 160*30+45(a4),160*30+44(a4)
	move.b 160*30+52(a4),160*30+45(a4)
	move.b 160*30+53(a4),160*30+52(a4)
	move.b 160*30+60(a4),160*30+53(a4)
	move.b 160*30+61(a4),160*30+60(a4)
	move.b 68(a4),160*30+61(a4)
	move.b 69(a4),68(a4)
	move.b 76(a4),69(a4)
	move.b 77(a4),76(a4)
	move.b 84(a4),77(a4)
	move.b 85(a4),84(a4)
	move.b 92(a4),85(a4)
	move.b 93(a4),92(a4)
	move.b 160*30+100(a4),93(a4)
	move.b 160*30+101(a4),160*30+100(a4)
	move.b 160*30+108(a4),160*30+101(a4)
	move.b 160*30+109(a4),160*30+108(a4)
	move.b 160*30+116(a4),160*30+109(a4)
	move.b 160*30+117(a4),160*30+116(a4)
	move.b 160*30+124(a4),160*30+117(a4)
	move.b 160*30+125(a4),160*30+124(a4)
	move.b 132(a4),160*30+125(a4)
	move.b 133(a4),132(a4)
	move.b 140(a4),133(a4)
	move.b 141(a4),140(a4)
	move.b 148(a4),141(a4)
	move.b 149(a4),148(a4)
	move.b 156(a4),149(a4)
	move.b 157(a4),156(a4)
	move.b 4(a5),157(a4)
	move.b 5(a5),4(a5)
	move.b 10(a5),5(a5)
	move.b 11(a5),10(a5)
	
	lea 12(a5),a5
	lea 160(a4),a4
	dbf d0,scroll6
	subq.b #1,nb_bit
	beq nextchar
	bra sprites

scroll7	move.b 3(a4),-160+2(a4)
	move.b 160+10(a4),3(a4)
	move.b 160*2+11(a4),160+10(a4)
	move.b 160*3+18(a4),160*2+11(a4)
	move.b 160*4+19(a4),160*3+18(a4)
	move.b 160*5+26(a4),160*4+19(a4)
	move.b 160*6+27(a4),160*5+26(a4)
	move.b 160*7+34(a4),160*6+27(a4)
	move.b 160*8+35(a4),160*7+34(a4)
	move.b 160*9+42(a4),160*8+35(a4)
	move.b 160*10+43(a4),160*9+42(a4)
	move.b 160*11+50(a4),160*10+43(a4)
	move.b 160*12+51(a4),160*11+50(a4)
	move.b 160*13+58(a4),160*12+51(a4)
	move.b 160*14+59(a4),160*13+58(a4)
	move.b 160*15+66(a4),160*14+59(a4)
	move.b 160*16+67(a4),160*15+66(a4)
	move.b 160*17+74(a4),160*16+67(a4)
	move.b 160*18+75(a4),160*17+74(a4)
	move.b 160*19+82(a4),160*18+75(a4)
	move.b 160*20+83(a4),160*19+82(a4)
	move.b 160*21+90(a4),160*20+83(a4)
	move.b 160*22+91(a4),160*21+90(a4)
	move.b 160*23+98(a4),160*22+91(a4)
	move.b 160*24+99(a4),160*23+98(a4)
	move.b 160*25+106(a4),160*24+99(a4)
	move.b 160*26+107(a4),160*25+106(a4)
	move.b 160*27+114(a4),160*26+107(a4)
	move.b 160*28+115(a4),160*27+114(a4)
	move.b 160*29+122(a4),160*28+115(a4)
	move.b 160*30+123(a4),160*29+122(a4)
	move.b 160*31+130(a4),160*30+123(a4)
	move.b 160*32+131(a4),160*31+130(a4)
	move.b 160*32+138(a4),160*32+131(a4)
	move.b 160*32+139(a4),160*32+138(a4)
	move.b 160*32+146(a4),160*32+139(a4)
	move.b 160*32+147(a4),160*32+146(a4)
	move.b 160*32+154(a4),160*32+147(a4)
	move.b 160*32+155(a4),160*32+154(a4)
	move.b 2(a5),160*32+155(a4)
	move.b 3(a5),2(a5)
	move.b 8(a5),3(a5)
	move.b 9(a5),8(a5)
	
	move.b 5(a4),-160+4(a4)
	move.b 160+12(a4),5(a4)
	move.b 160*2+13(a4),160+12(a4)
	move.b 160*3+20(a4),160*2+13(a4)
	move.b 160*4+21(a4),160*3+20(a4)
	move.b 160*5+28(a4),160*4+21(a4)
	move.b 160*6+29(a4),160*5+28(a4)
	move.b 160*7+36(a4),160*6+29(a4)
	move.b 160*8+37(a4),160*7+36(a4)
	move.b 160*9+44(a4),160*8+37(a4)
	move.b 160*10+45(a4),160*9+44(a4)
	move.b 160*11+52(a4),160*10+45(a4)
	move.b 160*12+53(a4),160*11+52(a4)
	move.b 160*13+60(a4),160*12+53(a4)
	move.b 160*14+61(a4),160*13+60(a4)
	move.b 160*15+68(a4),160*14+61(a4)
	move.b 160*16+69(a4),160*15+68(a4)
	move.b 160*17+76(a4),160*16+69(a4)
	move.b 160*18+77(a4),160*17+76(a4)
	move.b 160*19+84(a4),160*18+77(a4)
	move.b 160*20+85(a4),160*19+84(a4)
	move.b 160*21+92(a4),160*20+85(a4)
	move.b 160*22+93(a4),160*21+92(a4)
	move.b 160*23+100(a4),160*22+93(a4)
	move.b 160*24+101(a4),160*23+100(a4)
	move.b 160*25+108(a4),160*24+101(a4)
	move.b 160*26+109(a4),160*25+108(a4)
	move.b 160*27+116(a4),160*26+109(a4)
	move.b 160*28+117(a4),160*27+116(a4)
	move.b 160*29+124(a4),160*28+117(a4)
	move.b 160*30+125(a4),160*29+124(a4)
	move.b 160*31+132(a4),160*30+125(a4)
	move.b 160*32+133(a4),160*31+132(a4)
	move.b 160*32+140(a4),160*32+133(a4)
	move.b 160*32+141(a4),160*32+140(a4)
	move.b 160*32+148(a4),160*32+141(a4)
	move.b 160*32+149(a4),160*32+148(a4)
	move.b 160*32+156(a4),160*32+149(a4)
	move.b 160*32+157(a4),160*32+156(a4)
	move.b 4(a5),160*32+157(a4)
	move.b 5(a5),4(a5)
	move.b 10(a5),5(a5)
	move.b 11(a5),10(a5)
	
	lea 12(a5),a5
	lea 160(a4),a4
	dbf d0,scroll7
	subq.b #1,nb_bit
	beq nextchar
	bra sprites
	
scroll8	move.b 160*32+3(a4),160*32+2(a4)
	move.b 160*32+10(a4),160*32+3(a4)
	move.b 160*32+11(a4),160*32+10(a4)
	move.b 160*32+18(a4),160*32+11(a4)
	move.b 160*32+19(a4),160*32+18(a4)
	move.b 160*32+26(a4),160*32+19(a4)
	move.b 160*32+27(a4),160*32+26(a4)
	move.b 160*31+34(a4),160*32+27(a4)
	move.b 160*30+35(a4),160*31+34(a4)
	move.b 160*29+42(a4),160*30+35(a4)
	move.b 160*28+43(a4),160*29+42(a4)
	move.b 160*27+50(a4),160*28+43(a4)
	move.b 160*26+51(a4),160*27+50(a4)
	move.b 160*25+58(a4),160*26+51(a4)
	move.b 160*24+59(a4),160*25+58(a4)
	move.b 160*23+66(a4),160*24+59(a4)
	move.b 160*22+67(a4),160*23+66(a4)
	move.b 160*21+74(a4),160*22+67(a4)
	move.b 160*20+75(a4),160*21+74(a4)
	move.b 160*19+82(a4),160*20+75(a4)
	move.b 160*18+83(a4),160*19+82(a4)
	move.b 160*17+90(a4),160*18+83(a4)
	move.b 160*16+91(a4),160*17+90(a4)
	move.b 160*15+98(a4),160*16+91(a4)
	move.b 160*14+99(a4),160*15+98(a4)
	move.b 160*13+106(a4),160*14+99(a4)
	move.b 160*12+107(a4),160*13+106(a4)
	move.b 160*11+114(a4),160*12+107(a4)
	move.b 160*10+115(a4),160*11+114(a4)
	move.b 160*9+122(a4),160*10+115(a4)
	move.b 160*8+123(a4),160*9+122(a4)
	move.b 160*7+130(a4),160*8+123(a4)
	move.b 160*6+131(a4),160*7+130(a4)
	move.b 160*5+138(a4),160*6+131(a4)
	move.b 160*4+139(a4),160*5+138(a4)
	move.b 160*3+146(a4),160*4+139(a4)
	move.b 160*2+147(a4),160*3+146(a4)
	move.b 160+154(a4),160*2+147(a4)
	move.b 155(a4),160+154(a4)
	move.b 2(a5),155(a4)
	move.b 3(a5),2(a5)
	move.b 8(a5),3(a5)
	move.b 9(a5),8(a5)
	
	move.b 160*32+5(a4),160*32+4(a4)
	move.b 160*32+12(a4),160*32+5(a4)
	move.b 160*32+13(a4),160*32+12(a4)
	move.b 160*32+20(a4),160*32+13(a4)
	move.b 160*32+21(a4),160*32+20(a4)
	move.b 160*32+28(a4),160*32+21(a4)
	move.b 160*32+29(a4),160*32+28(a4)
	move.b 160*31+36(a4),160*32+29(a4)
	move.b 160*30+37(a4),160*31+36(a4)
	move.b 160*29+44(a4),160*30+37(a4)
	move.b 160*28+45(a4),160*29+44(a4)
	move.b 160*27+52(a4),160*28+45(a4)
	move.b 160*26+53(a4),160*27+52(a4)
	move.b 160*25+60(a4),160*26+53(a4)
	move.b 160*24+61(a4),160*25+60(a4)
	move.b 160*23+68(a4),160*24+61(a4)
	move.b 160*22+69(a4),160*23+68(a4)
	move.b 160*21+76(a4),160*22+69(a4)
	move.b 160*20+77(a4),160*21+76(a4)
	move.b 160*19+84(a4),160*20+77(a4)
	move.b 160*18+85(a4),160*19+84(a4)
	move.b 160*17+92(a4),160*18+85(a4)
	move.b 160*16+93(a4),160*17+92(a4)
	move.b 160*15+100(a4),160*16+93(a4)
	move.b 160*14+101(a4),160*15+100(a4)
	move.b 160*13+108(a4),160*14+101(a4)
	move.b 160*12+109(a4),160*13+108(a4)
	move.b 160*11+116(a4),160*12+109(a4)
	move.b 160*10+117(a4),160*11+116(a4)
	move.b 160*9+124(a4),160*10+117(a4)
	move.b 160*8+125(a4),160*9+124(a4)
	move.b 160*7+132(a4),160*8+125(a4)
	move.b 160*6+133(a4),160*7+132(a4)
	move.b 160*5+140(a4),160*6+133(a4)
	move.b 160*4+141(a4),160*5+140(a4)
	move.b 160*3+148(a4),160*4+141(a4)
	move.b 160*2+149(a4),160*3+148(a4)
	move.b 160+156(a4),160*2+149(a4)
	move.b 157(a4),160+156(a4)
	move.b 4(a5),157(a4)
	move.b 5(a5),4(a5)
	move.b 10(a5),5(a5)
	move.b 11(a5),10(a5)
	
	lea 12(a5),a5
	lea 160(a4),a4
	dbf d0,scroll8
	subq.b #1,nb_bit
	beq nextchar
	bra sprites

scroll9	move.b 3(a4),2(a4)
	move.b 10(a4),3(a4)
	move.b 11(a4),10(a4)
	move.b 18(a4),11(a4)
	move.b 19(a4),18(a4)
	move.b 26(a4),19(a4)
	move.b 27(a4),26(a4)
	move.b 34(a4),27(a4)
	move.b 35(a4),34(a4)
	move.b 42(a4),35(a4)
	move.b 43(a4),42(a4)
	move.b 50(a4),43(a4)
	move.b 51(a4),50(a4)
	move.b 58(a4),51(a4)
	move.b 59(a4),58(a4)
	move.b 66(a4),59(a4)
	move.b 67(a4),66(a4)
	move.b 74(a4),67(a4)
	move.b 75(a4),74(a4)
	move.b 160+82(a4),75(a4)
	move.b 160*2+83(a4),160+82(a4)
	move.b 160*3+90(a4),160*2+83(a4)
	move.b 160*4+91(a4),160*3+90(a4)
	move.b 160*5+98(a4),160*4+91(a4)
	move.b 160*6+99(a4),160*5+98(a4)
	move.b 160*7+106(a4),160*6+99(a4)
	move.b 160*8+107(a4),160*7+106(a4)
	move.b 160*9+114(a4),160*8+107(a4)
	move.b 160*10+115(a4),160*9+114(a4)
	move.b 160*11+122(a4),160*10+115(a4)
	move.b 160*12+123(a4),160*11+122(a4)
	move.b 160*13+130(a4),160*12+123(a4)
	move.b 160*14+131(a4),160*13+130(a4)
	move.b 160*15+138(a4),160*14+131(a4)
	move.b 160*16+139(a4),160*15+138(a4)
	move.b 160*17+146(a4),160*16+139(a4)
	move.b 160*18+147(a4),160*17+146(a4)
	move.b 160*19+154(a4),160*18+147(a4)
	move.b 160*20+155(a4),160*19+154(a4)
	move.b 2(a5),160*20+155(a4)
	move.b 3(a5),2(a5)
	move.b 8(a5),3(a5)
	move.b 9(a5),8(a5)
	
	move.b 5(a4),4(a4)
	move.b 12(a4),5(a4)
	move.b 13(a4),12(a4)
	move.b 20(a4),13(a4)
	move.b 21(a4),20(a4)
	move.b 28(a4),21(a4)
	move.b 29(a4),28(a4)
	move.b 36(a4),29(a4)
	move.b 37(a4),36(a4)
	move.b 44(a4),37(a4)
	move.b 45(a4),44(a4)
	move.b 52(a4),45(a4)
	move.b 53(a4),52(a4)
	move.b 60(a4),53(a4)
	move.b 61(a4),60(a4)
	move.b 68(a4),61(a4)
	move.b 69(a4),68(a4)
	move.b 76(a4),69(a4)
	move.b 77(a4),76(a4)
	move.b 160+84(a4),77(a4)
	move.b 160*2+85(a4),160+84(a4)
	move.b 160*3+92(a4),160*2+85(a4)
	move.b 160*4+93(a4),160*3+92(a4)
	move.b 160*5+100(a4),160*4+93(a4)
	move.b 160*6+101(a4),160*5+100(a4)
	move.b 160*7+108(a4),160*6+101(a4)
	move.b 160*8+109(a4),160*7+108(a4)
	move.b 160*9+116(a4),160*8+109(a4)
	move.b 160*10+117(a4),160*9+116(a4)
	move.b 160*11+124(a4),160*10+117(a4)
	move.b 160*12+125(a4),160*11+124(a4)
	move.b 160*13+132(a4),160*12+125(a4)
	move.b 160*14+133(a4),160*13+132(a4)
	move.b 160*15+140(a4),160*14+133(a4)
	move.b 160*16+141(a4),160*15+140(a4)
	move.b 160*17+148(a4),160*16+141(a4)
	move.b 160*18+149(a4),160*17+148(a4)
	move.b 160*19+156(a4),160*18+149(a4)
	move.b 160*20+157(a4),160*19+156(a4)
	move.b 4(a5),160*20+157(a4)
	move.b 5(a5),4(a5)
	move.b 10(a5),5(a5)
	move.b 11(a5),10(a5)
	
	lea 12(a5),a5
	lea 160(a4),a4
	dbf d0,scroll9
	subq.b #1,nb_bit
	beq nextchar
	bra sprites
	
scroll10	move.b 160*19+3(a4),160*20+2(a4)
	move.b 160*18+10(a4),160*19+3(a4)
	move.b 160*17+11(a4),160*18+10(a4)
	move.b 160*16+18(a4),160*17+11(a4)
	move.b 160*15+19(a4),160*16+18(a4)
	move.b 160*14+26(a4),160*15+19(a4)
	move.b 160*13+27(a4),160*14+26(a4)
	move.b 160*12+34(a4),160*13+27(a4)
	move.b 160*11+35(a4),160*12+34(a4)
	move.b 160*10+42(a4),160*11+35(a4)
	move.b 160*9+43(a4),160*10+42(a4)
	move.b 160*8+50(a4),160*9+43(a4)
	move.b 160*7+51(a4),160*8+50(a4)
	move.b 160*6+58(a4),160*7+51(a4)
	move.b 160*5+59(a4),160*6+58(a4)
	move.b 160*4+66(a4),160*5+59(a4)
	move.b 160*3+67(a4),160*4+66(a4)
	move.b 160*2+74(a4),160*3+67(a4)
	move.b 160+75(a4),160*2+74(a4)
	move.b 82(a4),160+75(a4)
	move.b 83(a4),82(a4)
	move.b 90(a4),83(a4)
	move.b 91(a4),90(a4)
	move.b 98(a4),91(a4)
	move.b 99(a4),98(a4)
	move.b 106(a4),99(a4)
	move.b 107(a4),106(a4)
	move.b 114(a4),107(a4)
	move.b 115(a4),114(a4)
	move.b 122(a4),115(a4)
	move.b 123(a4),122(a4)
	move.b 130(a4),123(a4)
	move.b 131(a4),130(a4)
	move.b 138(a4),131(a4)
	move.b 139(a4),138(a4)
	move.b 146(a4),139(a4)
	move.b 147(a4),146(a4)
	move.b 154(a4),147(a4)
	move.b 155(a4),154(a4)
	move.b 2(a5),155(a4)
	move.b 3(a5),2(a5)
	move.b 8(a5),3(a5)
	move.b 9(a5),8(a5)
	
	move.b 160*19+5(a4),160*20+4(a4)
	move.b 160*18+12(a4),160*19+5(a4)
	move.b 160*17+13(a4),160*18+12(a4)
	move.b 160*16+20(a4),160*17+13(a4)
	move.b 160*15+21(a4),160*16+20(a4)
	move.b 160*14+28(a4),160*15+21(a4)
	move.b 160*13+29(a4),160*14+28(a4)
	move.b 160*12+36(a4),160*13+29(a4)
	move.b 160*11+37(a4),160*12+36(a4)
	move.b 160*10+44(a4),160*11+37(a4)
	move.b 160*9+45(a4),160*10+44(a4)
	move.b 160*8+52(a4),160*9+45(a4)
	move.b 160*7+53(a4),160*8+52(a4)
	move.b 160*6+60(a4),160*7+53(a4)
	move.b 160*5+61(a4),160*6+60(a4)
	move.b 160*4+68(a4),160*5+61(a4)
	move.b 160*3+69(a4),160*4+68(a4)
	move.b 160*2+76(a4),160*3+69(a4)
	move.b 160+77(a4),160*2+76(a4)
	move.b 84(a4),160+77(a4)
	move.b 85(a4),84(a4)
	move.b 92(a4),85(a4)
	move.b 93(a4),92(a4)
	move.b 100(a4),93(a4)
	move.b 101(a4),100(a4)
	move.b 108(a4),101(a4)
	move.b 109(a4),108(a4)
	move.b 116(a4),109(a4)
	move.b 117(a4),116(a4)
	move.b 124(a4),117(a4)
	move.b 125(a4),124(a4)
	move.b 132(a4),125(a4)
	move.b 133(a4),132(a4)
	move.b 140(a4),133(a4)
	move.b 141(a4),140(a4)
	move.b 148(a4),141(a4)
	move.b 149(a4),148(a4)
	move.b 156(a4),149(a4)
	move.b 157(a4),156(a4)
	move.b 4(a5),157(a4)
	move.b 5(a5),4(a5)
	move.b 10(a5),5(a5)
	move.b 11(a5),10(a5)
	
	lea 12(a5),a5
	lea 160(a4),a4
	dbf d0,scroll10
	subq.b #1,nb_bit
	beq.s nextchar
	bra sprites
	
nextchar	move.b #4,nb_bit
	moveq #0,d0
	move.l mes_pnt,a0
	move.b (a0)+,d0
	move.l a0,mes_pnt
	
	cmp.b #-1,d0
	beq again
	
	cmp.b #-3,d0
	beq scr1
	
	cmp.b #-4,d0
	beq scr2
	
	cmp.b #-5,d0
	beq scr3
	
	cmp.b #-6,d0
	beq scr4
	
	cmp.b #-7,d0
	beq scr5
	
	cmp.b #-8,d0
	beq scr6
	
	cmp.b #-9,d0
	beq scr7
	
	cmp.b #-10,d0
	beq scr8
	
	cmp.b #-11,d0
 	beq scr9
	
	cmp.b #-12,d0
	beq scr10
	
	cmp.b #-2,d0
	beq space
	
	cmp.b #29,d0
	bgt.s line4
	
	cmp.b #19,d0
	bgt.s line3
	
	cmp.b #9,d0
	bgt.s line2
	
line1	lea fontes,a1
	bra.s continue
	
line2	lea fontes+160*31,a1
	bra.s continue
	
line3	lea fontes+160*62,a1
	bra.s continue
	
line4	lea fontes+160*93,a1

continue	lsl.l #4,d0
	add.l d0,a1
	
	lea car_buf,a0
	rept 33
	move.l (a1),(a0)+
	move 4(a1),(a0)+
	move.l 8(a1),(a0)+
	move 12(a1),(a0)+
	lea 160(a1),a1
	endr
	bra sprites
	
again	move.l #message,mes_pnt
	bra nextchar
	
scr1	move.l #scroll1,type_scr+2
	bra nextchar
	
scr2	move.l #scroll2,type_scr+2
	bra nextchar
	
scr3	move.l #scroll3,type_scr+2
	bra nextchar

scr4	move.l #scroll4,type_scr+2
	bra nextchar
	
scr5	move.l #scroll5,type_scr+2
	bra nextchar
	
scr6	move.l #scroll6,type_scr+2
	bra nextchar
	
scr7	move.l #scroll7,type_scr+2
	bra nextchar

scr8	move.l #scroll8,type_scr+2
	bra nextchar
	
scr9	move.l #scroll9,type_scr+2
	bra nextchar
	
scr10	move.l #scroll10,type_scr+2
	bra nextchar
	
space	lea car_buf,a0
	rept 99
	clr.l (a0)+
	endr
		
sprites	lea $ffff8800.w,a6
	lea tb_spr(pc),a5
	lea tb_spr1(pc),a3
	moveq #0,d0
	
	move.b #8,(a6)
	move.b (a6),d0
	lsl.l #2,d0
	move.l (a5,d0.w),a0
	
	move.b #9,(a6)
	move.b (a6),d0
	lsl.l #2,d0
	move.l (a3,d0.w),a2
	
	move.b #10,(a6)
	move.b (a6),d0
	lsl.l #2,d0
	move.l (a5,d0.w),a4
	
sprites1	move.l ecran,a1
	move.l a1,a3
	move.l a1,a5
	
	lea 160*64(a1),a1
	lea (160*64)+72(a3),a3
	lea (160*64)+136(a5),a5
	
	moveq #11,d6
	
trans	movem.l (a0),d0-d5
	movem.l d0-d5,(a1)
	movem.l (a2),d0-d5
	movem.l d0-d5,(a3)
	movem.l (a4),d0-d5
	movem.l d0-d5,(a5)
	
	movem.l 160(a0),d0-d5
	movem.l d0-d5,160(a1)
	movem.l 160(a2),d0-d5
	movem.l d0-d5,160(a3)
	movem.l 160(a4),d0-d5
	movem.l d0-d5,160(a5)
	
	movem.l 320(a0),d0-d5
	movem.l d0-d5,320(a1)
	movem.l 320(a2),d0-d5
	movem.l d0-d5,320(a3)
	movem.l 320(a4),d0-d5
	movem.l d0-d5,320(a5)
	
	movem.l 480(a0),d0-d5
	movem.l d0-d5,480(a1)
	movem.l 480(a2),d0-d5
	movem.l d0-d5,480(a3)
	movem.l 480(a4),d0-d5
	movem.l d0-d5,480(a5)
	
	movem.l 640(a0),d0-d5
	movem.l d0-d5,640(a1)
	movem.l 640(a2),d0-d5
	movem.l d0-d5,640(a3)
	movem.l 640(a4),d0-d5
	movem.l d0-d5,640(a5)
	
	movem.l 800(a0),d0-d5
	movem.l d0-d5,800(a1)
	movem.l 800(a2),d0-d5
	movem.l d0-d5,800(a3)
	movem.l 800(a4),d0-d5
	movem.l d0-d5,800(a5)
	
	movem.l 960(a0),d0-d5
	movem.l d0-d5,960(a1)
	movem.l 960(a2),d0-d5
	movem.l d0-d5,960(a3)
	movem.l 960(a4),d0-d5
	movem.l d0-d5,960(a5)
	
	movem.l 1120(a0),d0-d5
	movem.l d0-d5,1120(a1)
	movem.l 1120(a2),d0-d5
	movem.l d0-d5,1120(a3)
	movem.l 1120(a4),d0-d5
	movem.l d0-d5,1120(a5)
	
	movem.l 1280(a0),d0-d5
	movem.l d0-d5,1280(a1)
	movem.l 1280(a2),d0-d5
	movem.l d0-d5,1280(a3)
	movem.l 1280(a4),d0-d5
	movem.l d0-d5,1280(a5)
	
	movem.l 1440(a0),d0-d5
	movem.l d0-d5,1440(a1)
	movem.l 1440(a2),d0-d5
	movem.l d0-d5,1440(a3)
	movem.l 1440(a4),d0-d5
	movem.l d0-d5,1440(a5)
	
	lea 1600(a0),a0
	lea 1600(a1),a1
	lea 1600(a2),a2
	lea 1600(a3),a3
	lea 1600(a4),a4
	lea 1600(a5),a5
	dbf d6,trans
	
clignote	move.b #10,$ffff8800.w
	cmp.b #15,$ffff8800.w
	bne.s off
	
	move.b #$e,$ffff8800.w
	move.b #4,$ffff8802.w
	bra.s fr
	
off	move.b #$e,$ffff8800.w
	move.b #3,$ffff8802.w
	
fr	rts
	
*-------------------------------------------------------------------

	section data
	
pal_bar	dc.w $000,$111,$222,$333,$444,$555,$666,$777
	dc.w $777,$666,$555,$444,$333,$222,$111,$000
pal	dc.w $000,$007,$027,$037,$047,$057,$554,$100
	dc.w $210,$321,$432,$543,$654,$765,$776,$777
pal1	dc.w $000,$222,$456,$222,$345,$222,$234,$222
	dc.w $333,$444,$333,$444,$333,$444,$333,$444
pal2	dc.w $000,$222,$564,$222,$453,$222,$342,$222
	dc.w $333,$444,$333,$444,$333,$444,$333,$444
pal3	dc.w $000,$222,$654,$222,$543,$222,$432,$222
	dc.w $333,$444,$333,$444,$333,$444,$333,$444
pal4	dc.w $000,$222,$645,$222,$534,$222,$423,$222
	dc.w $333,$444,$333,$444,$333,$444,$333,$444
pal5	dc.w $000,$222,$666,$222,$555,$222,$444,$222
	dc.w $333,$444,$333,$444,$333,$444,$333,$444
pal6	dc.w $000,$222,$465,$222,$354,$222,$243,$222
	dc.w $333,$444,$333,$444,$333,$444,$333,$444
pal7	dc.w $000,$222,$546,$222,$435,$222,$324,$222
	dc.w $333,$444,$333,$444,$333,$444,$333,$444

tb_spr	dc.l spr1,spr1+(48/2)
	dc.l spr1+(96/2),spr1+(144/2)
	dc.l spr1+(192/2),spr1+(240/2)
	dc.l spr2,spr2+(48/2)
	dc.l spr2+(96/2),spr2+(144/2)
	dc.l spr2+(192/2),spr2+(240/2)
	dc.l spr3,spr3+(48/2)
	dc.l spr3+(96/2),spr3+(144/2)
	dc.l spr3+(144/2),spr3+(144/2)
tb_spr1	dc.l spr3+(192/2),spr3+(240/2)
	dc.l spr4,spr4+(48/2)
	dc.l spr4+(96/2),spr4+(144/2)
	dc.l spr4+(192/2),spr4+(240/2)
	dc.l spr5,spr5+(48/2)
	dc.l spr5+(96/2),spr5+(144/2)
	dc.l spr5+(192/2),spr5+(240/2)
	dc.l spr6,spr6+(48/2)
	dc.l spr6+(48/2),spr6+(48/2)
chut	dc.b 7,255,6,0,8,0,9,0,10,0
text	dc.b $1b,'EOnly Color Monitor,Sorry...',10,13,10,13
	dc.b 'Press [RESET]...',0
	even
fil	dc.b 'studio.mad',0
	even
env	dc.l 0
message	dc.b -3,0,1,2,3,4,5,6,7,8,9
	dc.b 10,11,12,13,14,15,16,17,18,19
	dc.b 20,21,22,23,24,25,-2,26,27,28,29
	dc.b 30,31,32,33,34,35,-2,36,37,38,39
	dc.b -2,-2,-2,-2,-2,-2,-2,-2,-2,-2
	dc.b -4,0,1,2,3,4,5,6,7,8,9
	dc.b 10,11,12,13,14,15,16,17,18,19
	dc.b 20,21,22,23,24,25,-2,26,27,28,29
	dc.b 30,31,32,33,34,35,-2,36,37,38,39
	dc.b -2,-2,-2,-2,-2,-2,-2,-2,-2,-2
	dc.b -5,0,1,2,3,4,5,6,7,8,9
	dc.b 10,11,12,13,14,15,16,17,18,19
	dc.b 20,21,22,23,24,25,-2,26,27,28,29
	dc.b 30,31,32,33,34,35,-2,36,37,38,39
	dc.b -2,-2,-2,-2,-2,-2,-2,-2,-2,-2
	dc.b -6,0,1,2,3,4,5,6,7,8,9
	dc.b 10,11,12,13,14,15,16,17,18,19
	dc.b 20,21,22,23,24,25,-2,26,27,28,29
	dc.b 30,31,32,33,34,35,-2,36,37,38,39
	dc.b -2,-2,-2,-2,-2,-2,-2,-2,-2,-2
	dc.b -7,0,1,2,3,4,5,6,7,8,9
	dc.b 10,11,12,13,14,15,16,17,18,19
	dc.b 20,21,22,23,24,25,-2,26,27,28,29
	dc.b 30,31,32,33,34,35,-2,36,37,38,39
	dc.b -2,-2,-2,-2,-2,-2,-2,-2,-2,-2
	dc.b -8,0,1,2,3,4,5,6,7,8,9
	dc.b 10,11,12,13,14,15,16,17,18,19
	dc.b 20,21,22,23,24,25,-2,26,27,28,29
	dc.b 30,31,32,33,34,35,-2,36,37,38,39
	dc.b -2,-2,-2,-2,-2,-2,-2,-2,-2,-2
	dc.b -9,0,1,2,3,4,5,6,7,8,9
	dc.b 10,11,12,13,14,15,16,17,18,19
	dc.b 20,21,22,23,24,25,-2,26,27,28,29
	dc.b 30,31,32,33,34,35,-2,36,37,38,39
	dc.b -2,-2,-2,-2,-2,-2,-2,-2,-2,-2
	dc.b -10,0,1,2,3,4,5,6,7,8,9
	dc.b 10,11,12,13,14,15,16,17,18,19
	dc.b 20,21,22,23,24,25,-2,26,27,28,29
	dc.b 30,31,32,33,34,35,-2,36,37,38,39
	dc.b -2,-2,-2,-2,-2,-2,-2,-2,-2,-2
	dc.b -11,0,1,2,3,4,5,6,7,8,9
	dc.b 10,11,12,13,14,15,16,17,18,19
	dc.b 20,21,22,23,24,25,-2,26,27,28,29
	dc.b 30,31,32,33,34,35,-2,36,37,38,39
	dc.b -2,-2,-2,-2,-2,-2,-2,-2,-2,-2
	dc.b -12,0,1,2,3,4,5,6,7,8,9
	dc.b 10,11,12,13,14,15,16,17,18,19
	dc.b 20,21,22,23,24,25,-2,26,27,28,29
	dc.b 30,31,32,33,34,35,-2,36,37,38,39
	dc.b -2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-1
	even
music1	incbin 'a:\wtss.mus'
	even
fontes	incbin 'a:\fontes1.neo'
screen	incbin 'a:\licorne.neo'
spr1	incbin 'a:\sprites1.neo'
spr2	incbin 'a:\sprites2.neo'
spr3 	incbin 'a:\sprites3.neo'
spr4 	incbin 'a:\sprites4.neo'
spr5 	incbin 'a:\sprites5.neo'
spr6 	incbin 'a:\sprites6.neo'
	even
code	dc.l $2c4f2a6f
even
	
	section bss
	
pile	ds.l 1
_ssp	ds.l 1
mfp1	ds.b 1
mfp2	ds.b 1
mfp3	ds.b 1
mfp4	ds.b 1
mfp5	ds.b 1
mfp6	ds.b 1
buffer	ds.b 43000
car_buf	ds.l 99
car_adr	ds.l 1
ecran	ds.l 1
anc_ecr	ds.l 1
anc_vbl	ds.l 1
anc_hbl	ds.l 1
anc_pal	ds.l 8
mes_pnt	ds.l 1
res	ds.b 1
vsync	ds.b 1
nb_bit	ds.b 1
compt	ds.b 1
	even

	end