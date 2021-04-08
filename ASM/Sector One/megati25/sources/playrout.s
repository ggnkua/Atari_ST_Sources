*************************************
*                                   *
*        MEGATIZER version 2.5      *
*         single playroutine        *
*        =====================      *
*                                   *
*    Coded by Jedi of Sector One    *
*  from The Heavy Killers on 07/92  *
*                                   *
*************************************

speed=0

datazz  bra init
	bra stop
	bra vbl	
init	movem.l d0-a6,-(sp)
	bsr stop
	lea relac(pc),a0
	lea reloc(pc),a1
	lea (a1),a2
lopp	movea.l (a0)+,a3
	cmpa.l #-1,a3
	beq.s xitlopp
	lea (a2,a3.l),a4
	movea.l (a1)+,a3
	lea (a2,a3.l),a5
	move.l a5,(a4)
	bra.s lopp
suzuki	cmpi.b #-1,(a0)+
	bne.s suzuki
	cmpi.b #"T",(a0)
	bne.s suzuki
	addq.l #1,a0
	cmpi.b #"H",(a0)
	bne.s suzuki
	addq.l #1,a0
	rts	
xitlopp	lea song(pc),a0
	lea pntinst(pc),a6
	move.l a0,(a6)+
wood2	bsr.s suzuki
	cmpi.b #"?",(a0)
	beq.s audio
	cmpi.b #"K",(a0)
	bne.s wood2
	addq.l #1,a0
	move.l a0,(a6)+
	bra.s wood2
audio	addq.l #1,a0
	lea ler1+2(pc),a6
	move.l a0,ler0-ler1(a6)
wood0	bsr.s suzuki
	cmpi.b #"K",(a0)
	bne.s wood0
	addq.l #1,a0
	move.l a0,(a6)
wood1	bsr.s suzuki
	cmpi.b #"K",(a0)
	bne.s wood1
	addq.l #1,a0
	move.l a0,ler2-ler1(a6)
	
	move.b #13,$ffff8800.w
	move.b #10,$ffff8802.w
	lea vol1(pc),a0
	lea volume+240(pc),a1
	move.l a1,(a0)+
	move.l a1,(a0)+
	move.l a1,(a0)
	movea.l ler0+2(pc),a0
	movea.l pntinst(pc),a1
	movea.l ler1+2(pc),a2
	lea (a1),a3
	movea.l ler2+2(pc),a4
	lea (a3),a5
	moveq #0,d0
	moveq #0,d1
	moveq #0,d2
	moveq #0,d3
	moveq #0,d4
	moveq #0,d5
	moveq #0,d6
	moveq #0,d7
	bclr #0,$484.w
	bra vantage
stop	pea (a0)
	lea $ffff8800.w,a0
	clr.l (a0)
	move.l #$1010000,(a0)
	move.l #$2020000,(a0)
	move.l #$3030000,(a0)
	move.l #$4040000,(a0)
	move.l #$5050000,(a0)
	move.l #$6060000,(a0)
	move.l #$707ffff,(a0)
	move.l #$8080000,(a0)
	move.l #$9090000,(a0)
	move.l #$a0a0000,(a0)
	move.l #$b0b0000,(a0)
	move.l #$c0c0000,(a0)
	move.l #$d0d0000,(a0)
	movea.l (sp)+,a0
	rts
vbl	movem.l d0-a6,-(sp)
	movem.l cntx(pc),d0-a5
	lea brrr0(pc),a6
	sf (a6)
	tst d0
	bne fou0
rkrkrk	moveq #0,d1
	lea por1(pc),a6
	move #-1,slide1-por1(a6)
	clr rop1-por1(a6)
	sf (a6)
krkrkr	move.b (a0)+,d1
	movea.l s40c(pc),a1
	cmpi.b #251,d1
	blo pleff51 
	move.l #255,d6
	sub.b d1,d6
	lsl.w #2,d6
	move.l liste1(pc,d6.l),d7
	jmp pleff01(pc,d7.l)	
liste1	dc.l pleff41-pleff01,pleff31-pleff01,pleff21-pleff01,pleff11-pleff01,pleff01-pleff01	
pleff01	moveq #0,d7
	move.b (a0)+,d6
	move.b (a0)+,d7
	move.b (a0),d1
	lea nslide1(pc),a6
	move.b d7,(a6)
	cmp.b d1,d7
	blo.s kcb1
	neg.b d6
kcb1	lea por1(pc),a6
	move.b d6,(a6)
	lea freakie(pc),a6
	add d7,d7
	move (a6,d7),d7	
	lea slide1(pc),a6
	move d7,(a6)
	bra.s krkrkr
pleff11	lea volume(pc),a6
	moveq #0,d1
	move.b (a0)+,d1
	asl.w #4,d1
	lea (a6,d1),a6
rel0	move.l a6,0
	bra.s krkrkr
pleff21	move.b (a0)+,d1
	neg.b d1
	lea por1(pc),a6
	move.b d1,(a6)
	bra krkrkr
pleff31 lea pntinst(pc),a6
	move.b (a0)+,d1
	add d1,d1
	add d1,d1
rel1	move.l (a6,d1),0
	bra rkrkrk
pleff41	
ler0	lea 0,a0
	bra rkrkrk
pleff51	moveq #0,d0
	move.b (a0)+,d0
	mulu #speed+1,d0
fou0	subq.w #1,d0
	cmpi.b #$ff,(a1)
	beq wayout
	lea regs(pc),a6
glibou	move.b (a1)+,d7 
	cmpi.b #243,d7
	blo enfect1 
	move.l #254,d6
	sub.b d7,d6
	lsl.w #2,d6
	move.l eliste1(pc,d6.l),d7
	jmp efect01(pc,d7.l)	
eliste1	dc.l efect01-efect01,efect11-efect01,efect21-efect01,efect31-efect01,efect41-efect01,efect51-efect01,efect61-efect01,efect71-efect01,efect81-efect01,efect91-efect01
	dc.l 'Jedi',wvchg1-efect01	
efect01	bset #3,7(a6)
	bclr #0,7(a6)
	bra.s glibou
wvchg1	move.b #13,$ffff8800.w
	move.b (a1)+,$ffff8802.w
	bra.s glibou
efect11	bset #0,7(a6)
	bclr #3,7(a6)
	bra.s glibou
efect21	andi.b #246,7(a6)
	bra.s glibou
efect91 ori.b #9,7(a6)
	bra glibou
efect31	move.b (a1)+,6(a6)
	bra glibou
efect41 moveq #0,d7
	move.b (a1),d7
	movea.l s40c(pc),a1
	adda.l d7,a1
	bra glibou	
efect51	
rel2	st 0
	move.b (a1)+,11(a6)
	sf 12(a6)
	move.b (a1)+,d7
	lsl.w #8,d7
	move.b (a1)+,d7
	rol.w #8,d7
rel3 	move d7,0
	sf 8(a6)
	bra jedi
efect61 lea brrfrq1(pc),a6
	st brrr0-brrfrq1(a6)
	move.b (a1)+,1(a6)
	move.b (a1)+,(a6)
	lea freakie(pc),a6
	move d1,d7
	add.b (a1)+,d7
	add d7,d7
	move (a6,d7),d7
	lea regs+11(pc),a6
	sf 8-11(a6)
	move.b d7,(a6)+
	lsr.w #8,d7
	move.b d7,(a6)
	bra jedi
efect71 lea regs+11(pc),a6
	sf 8-11(a6)
	st (brrr0-(regs+11))(a6)
	move.b (a1)+,1(a6)
	move.b (a1)+,(a6)
	move d1,d7
	add.b (a1)+,d7
	add d7,d7
	lea freakie(pc),a6
	move (a6,d7),d7
	lea brrfrq1(pc),a6
	move.b d7,(a6)+
	lsr.w #8,d7
	move.b d7,(a6)
	bra jedi
efect81 lea freakie(pc),a6
	st brrr0-freakie(a6)
	sf regs+8-freakie(a6)
	moveq #0,d7
	move d1,d7
	add.b (a1)+,d7
	add d7,d7
	move (a6,d7),d7
	lea brrfrq1(pc),a6
	move d7,d6
	move.b d6,(a6)
	lsr.w #8,d6
	move.b d6,1(a6)
	moveq #0,d6
	move.b (a1)+,d6
	ror.l d6,d7
	bcc.s odc1
	addq.w #1,d7
odc1	move.b d7,regs+11-brrfrq1(a6)
	lsr.w #8,d7
	move.b d7,regs+12-brrfrq1(a6)
	bra jedi
enfect1 movea.l vol1(pc),a6
	ext.w d7
rel4	move.b (a6,d7),0
	move.b (a1)+,d7
	ext.w d7
ways	move d1,-(sp)
	lea freakie(pc),a6
	add d1,d1
	move (a6,d1),d1
	add d7,d1
	move.b por1(pc),d7
	ext.w d7
	lea rop1(pc),a6
	add d7,(a6)
	add (a6),d1
	move slide1(pc),d6
	cmpi.w #-1,d6
	beq.s nolo1
	tst d7
	bmi.s olon1
	cmp.w d6,d1
	blo.s nolo1
olo1	move d6,d1
	move.b nslide1(pc),1(sp)
	clr (a6)
	sf por1-rop1(a6)
	bra.s nolo1
olon1	cmp.w d6,d1
	bcc.s nolo1
	bra.s olo1
nolo1	move (sp),d1
	lea freakie(pc),a6
	add.b (a1)+,d1
	add d1,d1
	move (a6,d1),d1
	move.b -2(a1),d7
	ext.w d7
	add d7,d1
	move.b por1(pc),d7
	ext.w d7
	lea rop1(pc),a6
	add d7,(a6)
	add (a6),d1
	lea regs(pc),a6
sector	move.b d1,(a6)
	lsr.w #8,d1
	move.b d1,1(a6)
	move (sp)+,d1
	bra.s jedi
wayout	lea regs(pc),a6
	move (a6),d1
	rol.w #8,d1
	move.b por1(pc),d7
	ext.w d7
	add d7,d1
	move d1,-(sp) 
	bra.s sector

jedi	lea brrrm(pc),a6
	sf (a6)
	tst d2
	bne fou0m
rkrkrkm	lea por2(pc),a6
	move #-1,slide2-por2(a6)
	clr rop2-por2(a6)
	sf (a6)
krkrkrm	moveq #0,d3
	move.b (a2)+,d3
	movea.l s414(pc),a3
	cmpi.b #251,d3
	blo pleff52
	move.l #255,d6
	sub.b d3,d6
	lsl.w #2,d6
	move.l liste2(pc,d6.l),d7
	jmp pleff02(pc,d7.l)	
liste2	dc.l pleff42-pleff02,pleff32-pleff02,pleff22-pleff02,pleff12-pleff02,pleff02-pleff02	
pleff02	moveq #0,d7
	move.b (a2)+,d6
	move.b (a2)+,d7
	move.b (a2),d3
	lea nslide2(pc),a6
	move.b d7,(a6)
	cmp.b d3,d7
	blo.s kcb2
	neg.b d6
kcb2	lea por2(pc),a6
	move.b d6,(a6)
	lea freakie(pc),a6
	add d7,d7
	move (a6,d7),d7	
	lea slide2(pc),a6
	move d7,(a6)
	bra.s krkrkrm	
pleff12	lea volume(pc),a6
	moveq #0,d3
	move.b (a2)+,d3
	asl.w #4,d3
	lea (a6,d3),a6
rel5	move.l a6,0
	bra.s krkrkrm
pleff22	move.b (a2)+,d3
	neg.b d3
	lea por2(pc),a6
	move.b d3,(a6)
	bra krkrkrm
pleff32	lea pntinst(pc),a6
	move.b (a2)+,d3
	add d3,d3
	add d3,d3
rel6	move.l (a6,d3),0
	bra rkrkrkm
pleff42	
ler1	lea 0,a2
	bra rkrkrkm
pleff52	moveq #0,d2
	move.b (a2)+,d2 
	mulu #speed+1,d2
fou0m	subq.w #1,d2
	cmpi.b #$ff,(a3)
	beq wayoutm
	lea regs+9(pc),a6
gliboum	move.b (a3)+,d7 
	cmpi.b #243,d7
	blo enfect2
	move.l #254,d6
	sub.b d7,d6
	lsl.w #2,d6
	move.l eliste2(pc,d6.l),d7
	jmp efect02(pc,d7.l)	
eliste2	dc.l efect02-efect02,efect12-efect02,efect22-efect02,efect32-efect02,efect42-efect02,efect52-efect02,efect62-efect02,efect72-efect02,efect82-efect02,efect92-efect02
	dc.l 'Jedi',wvchg2-efect02
efect02	bset #4,-2(a6)
	bclr #1,-2(a6)
	bra.s gliboum
wvchg2	move.b #13,$ffff8800.w
	move.b (a3)+,$ffff8802.w
	bra.s gliboum	
efect12	bset #1,-2(a6)
	bclr #4,-2(a6)
	bra.s gliboum
efect22	andi.b #237,-2(a6)
	bra.s gliboum
efect92 ori.b #18,-2(a6)
	bra gliboum
efect32	move.b (a3)+,6-9(a6)
	bra gliboum
efect42	moveq #0,d7
	move.b (a3),d7
	movea.l s414(pc),a3
	adda.l d7,a3
	bra gliboum	
efect52	
rel7	st 0
	move.b (a3)+,2(a6)
	sf 3(a6)
	move.b (a3)+,d7
	lsl.w #8,d7
	move.b (a3)+,d7
	rol.w #8,d7
rel8	move d7,0
	sf (a6)
	bra jedim
efect62	lea brrfrq2(pc),a6
	st brrrm-brrfrq2(a6)
	move.b (a3)+,1(a6)
	move.b (a3)+,(a6)
	lea freakie(pc),a6
	move d3,d7
	add.b (a3)+,d7
	add d7,d7
	move (a6,d7),d7
	lea regs+11(pc),a6
	sf 9-11(a6)
	move.b d7,(a6)+
	lsr.w #8,d7
	move.b d7,(a6)
	bra jedim
efect72 lea regs+11(pc),a6
	sf 9-11(a6)
	st (brrrm-(regs+11))(a6)
	move.b (a3)+,1(a6)
	move.b (a3)+,(a6)
	move d3,d7
	add.b (a3)+,d7
	add d7,d7
	lea freakie(pc),a6
	move (a6,d7),d7
	lea brrfrq2(pc),a6
	move.b d7,(a6)+
	lsr.w #8,d7
	move.b d7,(a6)
	bra jedim
efect82 lea freakie(pc),a6
	st brrrm-freakie(a6)
	sf regs+9-freakie(a6)
	moveq #0,d7
	move d3,d7
	add.b (a3)+,d7
	add d7,d7
	move (a6,d7),d7
	lea brrfrq2(pc),a6
	move d7,d6
	move.b d6,(a6)
	lsr.w #8,d6
	move.b d6,1(a6)
	moveq #0,d6
	move.b (a3)+,d6
	ror.l d6,d7
	bcc.s odc2
	addq.w #1,d7
odc2	move.b d7,regs+11-brrfrq2(a6)
	lsr.w #8,d7
	move.b d7,regs+12-brrfrq2(a6)
	bra jedim
enfect2 movea.l vol2(pc),a6
	ext.w d7
rel9	move.b (a6,d7),0	
	move.b (a3)+,d7
	ext.w d7
waysm	move d3,-(sp)
	lea freakie(pc),a6
	add d3,d3
	move (a6,d3),d3
	add d7,d3
	move.b por2(pc),d7
	ext.w d7
	lea rop2(pc),a6
	add d7,(a6)
	add (a6),d3
	move slide2(pc),d6
	cmpi.w #-1,d6
	beq.s nolo2
	tst d7
	bmi.s olon2
	cmp.w d6,d3
	blo.s nolo2
olo2	move d6,d3
	move.b nslide2(pc),1(sp)
	clr (a6)
	sf por2-rop2(a6)
	bra.s nolo2
olon2	cmp.w d6,d3
	bcc.s nolo2
	bra.s olo2
nolo2	move (sp),d3
	lea freakie(pc),a6
	add.b (a3)+,d3
	add d3,d3
	move (a6,d3),d3
	move.b -2(a3),d7
	ext.w d7
	add d7,d3
	move.b por2(pc),d7
	ext.w d7
	lea rop2(pc),a6
	add d7,(a6)
	add (a6),d3
	lea regs+2(pc),a6
sectorm	move.b d3,(a6)
	lsr.w #8,d3
	move.b d3,1(a6)
	move (sp)+,d3
	bra.s jedim
wayoutm	lea regs+2(pc),a6
	move (a6),d3
	rol.w #8,d3
	move.b por2(pc),d7
	ext.w d7
	add d7,d3
	move d3,-(sp) 
	bra.s sectorm

jedim	lea brrr1(pc),a6
	sf (a6)
	tst d4
	bne fou0d
rkrkrkd	lea por3(pc),a6
	move #-1,slide3-por3(a6)
	clr rop3-por3(a6)
	sf (a6)
krkrkr3	moveq #0,d5
	move.b (a4)+,d5
	movea.l s410(pc),a5
	cmpi.b #251,d5
	blo pleff53
	move.l #255,d6
	sub.b d5,d6
	lsl.w #2,d6
	move.l liste3(pc,d6.l),d7
	jmp pleff03(pc,d7.l)	
liste3	dc.l pleff43-pleff03,pleff33-pleff03,pleff23-pleff03,pleff13-pleff03,pleff03-pleff03	
pleff03	moveq #0,d7
	move.b (a4)+,d6
	move.b (a4)+,d7
	move.b (a4),d5
	lea nslide3(pc),a6
	move.b d7,(a6)
	cmp.b d5,d7
	blo.s kcb3
	neg.b d6
kcb3	lea por3(pc),a6
	move.b d6,(a6)
	lea freakie(pc),a6
	add d7,d7
	move (a6,d7),d7	
	lea slide3(pc),a6
	move d7,(a6)
	bra.s krkrkr3
pleff13	lea volume(pc),a6
	moveq #0,d5
	move.b (a4)+,d5
	asl.w #4,d5
	lea (a6,d5),a6
rel10	move.l a6,0
	bra.s krkrkr3
pleff23	move.b (a4)+,d5
	neg.b d5
	lea por3(pc),a6
	move.b d5,(a6)
	bra krkrkr3
pleff33	lea pntinst(pc),a6
	move.b (a4)+,d5
	add d5,d5
	add d5,d5
rel11	move.l (a6,d5),0
	bra rkrkrkd
pleff43	
ler2	lea 0,a4
	bra rkrkrkd
pleff53	moveq #0,d4
	move.b (a4)+,d4 
	mulu #speed+1,d4
fou0d	subq.w #1,d4
	cmpi.b #$ff,(a5)
	beq wayoutd
	lea regs+10(pc),a6
glibou2	move.b (a5)+,d7 
	cmpi.b #243,d7
	blo enfect3
	move.l #254,d6
	sub.b d7,d6
	lsl.w #2,d6
	move.l eliste3(pc,d6.l),d7
	jmp efect03(pc,d7.l)	
eliste3	dc.l efect03-efect03,efect13-efect03,efect23-efect03,efect33-efect03,efect43-efect03,efect53-efect03,efect63-efect03,efect73-efect03,efect83-efect03,efect93-efect03
	dc.l 'Jedi',wvchg3-efect03
efect03	bset #5,-3(a6)
	bclr #2,-3(a6)
	bra.s glibou2
wvchg3	move.b #13,$ffff8800.w
	move.b (a5)+,$ffff8802.w
	bra.s glibou2
efect13	bset #2,-3(a6)
	bclr #5,-3(a6)
	bra.s glibou2
efect23	andi.b #219,-3(a6)
	bra.s glibou2
efect93 ori.b #36,-3(a6)
	bra glibou2
efect33	move.b (a5)+,6-10(a6)
	bra glibou2
efect43	moveq #0,d7
	move.b (a5),d7
	movea.l s410(pc),a5
	adda.l d7,a5
	bra glibou2
efect53	
rel12	st 0
	move.b (a5)+,1(a6)
	sf 2(a6)
	move.b (a5)+,d7
	lsl.w #8,d7
	move.b (a5)+,d7
	rol.w #8,d7
rel13	move d7,0
	sf (a6)
	bra jedid
efect63 lea brrfrq3(pc),a6
	st brrr1-brrfrq3(a6)
	move.b (a5)+,1(a6)
	move.b (a5)+,(a6)
	lea freakie(pc),a6
	move d5,d7
	add.b (a5)+,d7
	add d7,d7
	move (a6,d7),d7
	lea regs+11(pc),a6
	sf 10-11(a6)
	move.b d7,(a6)+
	lsr.w #8,d7
	move.b d7,(a6)
	bra jedid
efect73 lea regs+11(pc),a6
	sf 10-11(a6)
	st (brrr1-(regs+11))(a6)
	move.b (a5)+,1(a6)
	move.b (a5)+,(a6)
	move d5,d7
	add.b (a5)+,d7
	add d7,d7
	lea freakie(pc),a6
	move (a6,d7),d7
	lea brrfrq3(pc),a6
	move.b d7,(a6)+
	lsr.w #8,d7
	move.b d7,(a6)
	bra jedid
efect83 lea freakie(pc),a6
	st brrr1-freakie(a6)
	sf regs+10-freakie(a6)
	moveq #0,d7
	move d5,d7
	add.b (a5)+,d7
	add d7,d7
	move (a6,d7),d7
	lea brrfrq3(pc),a6
	move d7,d6
	move.b d6,(a6)
	lsr.w #8,d6
	move.b d6,1(a6)
	moveq #0,d6
	move.b (a5)+,d6
	ror.l d6,d7
	bcc.s odc3
	addq.w #1,d7
odc3	move.b d7,regs+11-brrfrq3(a6)
	lsr.w #8,d7
	move.b d7,regs+12-brrfrq3(a6)
	bra jedid
enfect3	movea.l vol3(pc),a6
	ext.w d7
rel14	move.b (a6,d7),0
	move.b (a5)+,d7
	ext.w d7
waysd	move d5,-(sp)
	lea freakie(pc),a6
	add d5,d5
	move (a6,d5),d5
	add d7,d5
	move.b por3(pc),d7
	ext.w d7
	lea rop3(pc),a6
	add d7,(a6)
	add (a6),d5
	move slide3(pc),d6
	cmpi.w #-1,d6
	beq.s nolo3
	tst d7
	bmi.s olon3
	cmp.w d6,d5
	blo.s nolo3
olo3	move d6,d5
	move.b nslide3(pc),1(sp)
	clr (a6)
	sf por3-rop3(a6)
	bra.s nolo3
olon3	cmp.w d6,d5
	bcc.s nolo3
	bra.s olo3
nolo3	move (sp),d5
	lea freakie(pc),a6
	add.b (a5)+,d5
	add d5,d5
	move (a6,d5),d5
	move.b -2(a5),d7
	ext.w d7
	add d7,d5
	move.b por3(pc),d7
	ext.w d7
	lea rop3(pc),a6
	add d7,(a6)
	add (a6),d5
	lea regs+4(pc),a6
sectord	move.b d5,(a6)
	lsr.w #8,d5
	move.b d5,1(a6)
	move (sp)+,d5
	bra.s jedid
wayoutd	lea regs+4(pc),a6
	move (a6),d5
	rol.w #8,d5
	move.b por3(pc),d7
	ext.w d7
	add d7,d5
	move d5,-(sp) 
	bra.s sectord
jedid
	lea regs+8(pc),a6
	bclr #4,(a6)
	tst.b brrr0-(regs+8)(a6)
	beq.s poad1
	move brrfrq1(pc),-8(a6)
	bset #4,(a6)
poad1	bclr #4,1(a6)
	tst.b brrrm-(regs+8)(a6)
	beq.s poad2
	move brrfrq2(pc),-6(a6)
	bset #4,1(a6)
poad2	bclr #4,2(a6)
	tst.b brrr1-(regs+8)(a6)
	beq.s poad
	move brrfrq3(pc),-4(a6)
	bset #4,2(a6)
poad	moveq #12,d7
	lea regf(pc),a6
outer	move.b d7,$ffff8800.w
	move.b -(a6),$ffff8802.w
	dbf d7,outer
vantage	lea cntx(pc),a6
	movem.l d0-a5,(a6)
	movem.l (sp)+,d0-a6
	rts
	
regs	dc.b 0,0,0,0,0,0,0,%11111000,0,0,0,0,0
regf
	even
cntx	ds.l 15
s40c	dc.l 0
s410	dc.l 0
s414	dc.l 0
brrr0	dc.b 0
brrr1	dc.b 0
brrrm	dc.b 0
por1	dc.b 0
por2	dc.b 0
por3	dc.b 0
	even
rop1	dc.w 0
rop2	dc.w 0
rop3	dc.w 0	
agaga	dc.b 'Muzak-driver',0,'done',0,'by',0,'Sector',0,'One',0,'from',0,'The',0,'Heavy',0,'Killers'	
	
nslide1=agaga
nslide2=agaga+1
nslide3=agaga+2
vol1=agaga+4
vol2=agaga+8
vol3=agaga+12
	even
	
freakie	dc.l $EEE0E18,$D4D0C8E,$BDA0B2F,$A8F09F7,$96808E1,$86107E9,$777070C,$6A70647,$5ED0598,$54704FC,$4B40470,$43103F4
	dc.l $3BC0386,$3530324,$2F602CC,$2A4027E,$25A0238,$21801FA,$1DE01C3,$1AA0192,$17B0166,$152013F,$12D011C,$10C00FD
	dc.l $EF00E1,$D500C9,$BE00B3,$A9009F,$96008E,$86007F,$770071,$6A0064,$5F0059,$540050,$4B0047,$43003F
	dc.l $3C0038,$350032,$2F002D,$2A0028,$260024,$220020,$1E001C,$1B0019,$180016,$150014,$130012,$110010

volume  dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b 0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1
	dc.b 0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,2
	dc.b 0,0,0,1,1,1,1,1,2,2,2,2,2,3,3,3
	dc.b 0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4
	dc.b 0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5
	dc.b 0,0,1,1,2,2,2,3,3,4,4,4,5,5,6,6
	dc.b 0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7
	dc.b 0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8
	dc.b 0,1,1,2,2,3,4,4,5,5,6,7,7,8,8,9
	dc.b 0,1,1,2,3,3,4,5,5,6,7,7,8,9,9,10
	dc.b 0,1,1,2,3,4,4,5,6,7,7,8,9,10,10,11
	dc.b 0,1,2,2,3,4,5,6,6,7,8,9,10,10,11,12
	dc.b 0,1,2,3,3,4,5,6,7,8,9,10,10,11,12,13
	dc.b 0,1,2,3,4,5,6,7,7,8,9,10,11,12,13,14
	dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	even
	
brrfrq1	dc.b 'Fanou',0,'I',0,'love',0,'ya',0,'!',0,'-',0,'Jedi',0,'-',0,'for',0,'my',0,'baby...'
brrfrq2=brrfrq1+2
brrfrq3=brrfrq1+4
slide1=brrfrq1+6
slide2=brrfrq1+8
slide3=brrfrq1+10

reloc	dc.l vol1-reloc,s40c-reloc,brrr0-reloc,brrfrq1-reloc,regs+8-reloc,s414-reloc,brrrm-reloc
	dc.l brrfrq2-reloc,regs+9-reloc,s410-reloc,brrr1-reloc,brrfrq3-reloc,regs+10-reloc,vol2-reloc,vol3-reloc,-1

relac	dc.l rel0-reloc+2,rel1-reloc+4,rel2-reloc+2,rel3-reloc+2,rel4-reloc+4,rel6-reloc+4,rel7-reloc+2
	dc.l rel8-reloc+2,rel9-reloc+4,rel11-reloc+4,rel12-reloc+2,rel13-reloc+2,rel14-reloc+4,rel5-reloc+2,rel10-reloc+2,-1

	even
pntinst	ds.l 100
song	
	