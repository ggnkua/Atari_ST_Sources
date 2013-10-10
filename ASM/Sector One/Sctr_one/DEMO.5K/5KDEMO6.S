	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	move.l d0,-(sp)
	
	movem.l $ffff8240.w,d0-d7
	movem.l d0-d7,-(sp)
	
	move.l #adfin,d0
	add.l #256,d0
	clr.b d0
	move.l d0,a0
	move.l a0,a1
	lea.l 160+230+13*230+8(a1),a1
	move.l a1,chboot+2
	add.l #184*230,a1
	move.l a1,change2+2
	move.l d0,ec
	
	move.w #7999,d0
	moveq #0,d1
effboot:	move.l d1,(a0)+
	dbf d0,effboot	
	
	move.l #%01010101010101010011001100110011,d6
	move.l #%00001111000011110000000000000000,d7
	
	move.l ec(pc),a0
	lea.l 160+230(a0),a0
	move.w #197,d1
fill1:	moveq #25,d4
fill2:	move.l d6,(a0)+
	move.l d7,(a0)+
	not.l d7
	clr.w d7
	not.l d6
	dbf d4,fill2
	lea.l 22(a0),a0
	dbf d1,fill1

	move.l #databoot,a0
	moveq #25,d0
rcop3:	moveq #0,d7
	moveq #7,d5
rcop1:	moveq #1,d2
	move.w #1,a1
rcop5:	moveq #1,d6
rcop2:	move.w d7,d4
	moveq #7,d3
rcop4:	move.w a1,d1
	mulu.w d4,d1
	move.w d1,(a0)+
	addq.l #1,d4
	cmp.b #8,d4
	bne.s p4p8
	moveq #0,d4
p4p8:	dbf d3,rcop4
	dbf d6,rcop2
	move.w #$10,a1
	dbf d2,rcop5
	addq.l #1,d7
	dbf d5,rcop1
	dbf d0,rcop3
	
	move.w sr,-(sp)
	move.w #$2700,sr
	move.l $fffffa06.w,-(sp)
	clr.l $fffffa06.w
	move.l $70.w,-(sp)
	lea vbl(pc),a0
	move.l a0,$70.w
	move.l $ffff8200.w,-(sp)
	move.b ec+1,$ffff8201.w
	move.b ec+2,$ffff8203.w
	
	move.w #$2300,sr
	
boucle:	cmp.w #$1234,cmpt
	beq.s finboot
	cmp.b #$39,$fffffc02.w
	bne.s boucle

finboot:
	;deb boule***************************************
	
	move.w #$2700,sr
	
	move.l #adfin,d0
	add.l #256,d0
	clr.b d0
	move.l d0,ecr1
	add.l #32000+256,d0
	clr.b d0
	move.l d0,ecr2
	
	move.b ecr1+1,$ffff8201.w
	move.b ecr1+2,$ffff8203.w
	lea.l $ffff8240.w,a0
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	
	move.l ecr1,a0
	move.w #8000*2+300,d0
	moveq #0,d1
remp2:	move.l d1,(a0)+
	dbf d0,remp2	
	
	move.l #vblstart,$70
	
	move.l #pre160,a0
	move.w #200,d0
	move.w #-100,d1
bpre160:	move.w d1,d2
	muls.w #256,d2
	move.w d2,201*2(a0)
	move.w d1,d2
	muls.w #4096,d2
	move.w d2,201*2*2(a0)
	move.w d1,d2
	muls.w #160,d2
	move.w d2,(a0)+
	addq.w #1,d1
	dbf d0,bpre160	
	
	move.l #dimtabx,a0
	move.l #divtab,a1
	moveq #12,d7
pretab:	move.w (a1)+,d6
	move.w #-100,d1
boux:	move.w d1,d2
	ext.l d2
	lsl.l #8,d2
	divs.w d6,d2
	lsl.w #4,d2
	move.w d2,(a0)+
	addq.w #1,d1
	cmp.w #101,d1
	bne.s boux
	
	move.w #-100,d1
bouy:	move.w d1,d2
	ext.l d2
	lsl.l #8,d2
	divs.w d6,d2
	mulu.w #160,d2
	move.w d2,(a0)+
	addq.w #1,d1
	cmp.w #101,d1
	bne.s bouy
	
	dbf d7,pretab
	
	move.l #prerot,a0
	move.w #%0000000000001000,d3
	moveq #-56,d4
	moveq #15,d5
prer2:	move.w #200,d0
	move.w d4,d1
prer:	move.w d3,(a0)
	move.w d1,4(a0)
	lea.l 16(a0),a0
	ror.w #1,d3
	bcc.s d1p0
	addq.w #8,d1
d1p0:	dbf d0,prer
	lea.l 256*4*2*2-201*4*2*2(a0),a0
	ror.w #8,d3
	bcc.s d3p0
	addq.w #8,d4
d3p0:	dbf d5,prer2
	
	move.l #prerot,a2
	move.l #prerot+199*4*2*2,a3
	moveq #15,d0
prot1:	move.l a2,a0
	move.l a3,a1
	move.w #199,d1
prot2:	move.w (a0),2(a1)
	move.w 4(a0),6(a1)
	lea.l 16(a0),a0
	lea.l -16(a1),a1
	dbf d1,prot2
	lea.l 256*4*2*2(a2),a2
	lea.l 256*4*2*2(a3),a3
	dbf d0,prot1
	
	move.l #prerot,a2
	move.l #prerot+8,a3
	moveq #15,d0
nprot1:	move.l a2,a0
	move.l a3,a1
	move.w #200,d1
nprot2:	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	addq.l #8,a0
	addq.l #8,a1
	dbf d1,nprot2
	lea.l 256*4*2*2(a2),a2
	lea.l -256*4*2*2(a3),a3
	cmp.l #prerot+8-256*4*2*2,a3
	bne.s a3prot
	move.l #prerot+8+256*15*4*2*2,a3
a3prot:	dbf d0,nprot1
	
	move.l #premul1,a2
	move.l #premul2,a4
	lea.l chb1(pc),a3
	move.w #-100,d0
pre1:	moveq #3,d7
pre3:	moveq #63,d2
	tst.w d7
	bne.s bd7p0
	move.w tabch+2(pc),(a3)
	move.w tabch+4(pc),chb2-chb1(a3)
	move.w tabch+10(pc),chb3-chb1(a3)
bd7p0:	cmp.w #1,d7
	bne.s bd7p1
	move.w tabch(pc),(a3)
	move.w tabch+6(pc),chb2-chb1(a3)
	move.w tabch+8(pc),chb4-chb1(a3)
bd7p1:	cmp.w #2,d7
	bne.s bd7p2
	move.w tabch+2(pc),(a3)
	move.w tabch+4(pc),chb2-chb1(a3)
	move.w tabch+8(pc),chb3-chb1(a3)
bd7p2:	cmp.w #3,d7
	bne.s bd7p3
	lea.l cos(pc),a0
	lea.l cos+64*2(pc),a1
	move.w tabch(pc),(a3)
	move.w tabch+6(pc),chb2-chb1(a3)
	move.w tabch+10(pc),chb4-chb1(a3)
bd7p3:
pre2:	
chb1:	move.w (a0)+,d1
chb3:	nop
	mulu.w d0,d1
	asr.w #8,d1
	move.b d1,(a2)+
chb2:	move.w -(a1),d1
chb4:	nop
	mulu.w d0,d1
	asr.w #8,d1
	move.b d1,(a4)+
	dbf d2,pre2
	dbf d7,pre3
	addq.l #1,d0
	cmp.w #100,d0
	bne pre1

	move.w #$2300,sr
	
att:	cmp.b #$39,$fffffc02.w
	bne.s att
	
	bra fintot	

finb:
	move.w #$2700,sr
	clr.w cntb
	
	
	lea.l $ffff8240.w,a0
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	
	move.l ecr1,a0
	move.l ecr2,a1
	move.w #7999,d0
	moveq #0,d1
effkef:	move.l d1,(a0)+
	move.l d1,(a1)+
	dbf d0,effkef
	
	movem.l new_pal,d0-d7
	movem.l d0-d7,$ffff8240.w	
	
	lea	premul,a1
	moveq	#59,d4		*nbre iter z
	moveq	#1,d3		*val de division
boucmulz:	move.w	#319,d0		*nbre iter x
	move.w	#-160,d1	*val de depart
boucmul:	move.w	d1,d2
	muls	d2,d2
	divu	d3,d2
	move.b	d2,(a1)+
	addq.w	#1,d1
	dbf.w	d0,boucmul

	addq.w	#1,d3
	dbf.w	d4,boucmulz
	
	lea courbz(pc),a5
	
	move.l #kefvbl,$70
	move.w #$2300,sr
	bra att
	
kefvbl:	
	move.l ecr1,a0
	move.l ecr2,ecr1
	move.l a0,ecr2
	move.b ecr1+1,$ffff8201.w
	move.b ecr1+2,$ffff8203.w

	addq.w #1,cntb
	cmp.w #8*50,cntb
	bne cnt2b
	move.l #fintot,2(sp)
	rte
cnt2b:	
	
	lea	160*8+160+49*160+40(a0),a0	*centre la keftale
	lea	premul,a1
	move.w	(a5)+,d0		*fact de zoom(0 a 59)
	lea	(a1,d0.w),a1		*table de mult centree
	lea	160(a1),a1

	cmp.l	#fcourbz,a5
	blt.s	suit1
	lea	courbz(pc),a5

suit1:	
	move.w	(a6)+,d1		*pos x
	move.w	(a6)+,d0		*pos y
	sub.w	#80,d0
	sub.w	#80,d1
	cmp.l	#fcourbxy,a6
	blt.s	suit2
	lea	courbxy(pc),a6
suit2:	lea	(a1,d0.w),a2
	moveq.l	#99,d0			*taille y
	lea	(a1,d1.w),a4
	
bouc1:	moveq.l	#9,d1			*taille x
	move.l	a4,a3
	move.b	(a2)+,d3
	
bouc2:	
	rept	16
	move.b	(a3)+,d2
	add.b	d3,d2
		
	add.b	d2,d2
	addx.w	d7,d7
	add.b	d2,d2
	addx.w	d6,d6
	add.b	d2,d2
	addx.w	d5,d5
	add.b	d2,d2
	addx.w	d4,d4
	endr
	
	movem.w	d4-d7,(a0)
	addq.l	#8,a0
	dbf	d1,bouc2
	lea	160-160/2(a0),a0
	dbf	d0,bouc1	

	;move.w #$10,$ffff8240
	
	rte

new_pal:
	dc.w	$012,$111,$222,$333,$444,$555,$666,$777
	dc.w	$776,$765,$654,$543,$432,$321,$210,$100

courbz:	rept 59
	dc.w 2*320
	endr
pass:	set 2
	rept 57
	dc.w pass*320
pass:	set pass+1	
	endr

fcourbz:
courbxy:
	dc.w -32,0
fcourbxy:


vblstart:	move.l #vblboul,$70.w
	rte

ecr1:	dc.l 0
ecr2:	dc.l 0
tabch:	move.w (a0)+,d1
	move.w -(a0),d1
	move.w (a1)+,d1
	move.w -(a1),d1
	neg.w d1
	nop

cntb:	dc.w 0

vblboul:	
	addq.w #1,cntb
	cmp.w #50*8,cntb
	bne cntp5
	move.l #finb,2(sp)
	rte
cntp5:	
	
	move.l ecr2(pc),a3
	move.b ecr2+1(pc),$ffff8201.w
	move.b ecr2+2(pc),$ffff8203.w
	move.l ecr1(pc),ecr2
	move.l a3,ecr1
	move.l a3,a0
	
	lea.l 4*160+3*8(a0),a0
	move.l #pal1,nextcol
	
	move.w flagclr(pc),d7
	cmp.w #6,d7
	blt.s d7p2
	move.l #pal4,nextcol
	addq.l #6,a3
	lea.l 14*4(a0),a0
	cmp.w #7,d7
	bne.s d7pf
	moveq #-1,d7
	bra.s d7pf
d7p2:	cmp.w #4,d7
	blt.s d7p3
	move.l #pal3,nextcol
	addq.l #4,a3
	lea.l (100-3)*160(a0),a0
	bra.s d7pf
d7p3:	cmp.w #2,d7
	blt.s d7pf
	move.l #pal2,nextcol
	addq.l #2,a3
	lea.l (100-3)*160+14*4(a0),a0
d7pf:	addq.w #1,d7
	move.w d7,flagclr
	
	move.l a3,ec
	add.l #100*160+80,ec
	
	move.w #199,d0
	moveq #0,d2
effbp1:	
pass:	set 0	
	rept 14
	move.w d2,3*8+pass(a3)
pass:	set pass+8
	endr
	lea.l 160(a3),a3
	dbf d0,effbp1
	
	lea.l ang(pc),a0
	lea.l adang(pc),a1
	movem.w (a1)+,d0-d2
	add.w d0,(a0)+
	add.w d1,(a0)+
	add.w d2,(a0)+
	
	movem.w ang(pc),d0-d2
	lea.l ph1(pc),a0
	move.b d0,3(a0)
	move.b d0,ph2+3-ph1(a0)
	move.b d1,ph5+3-ph1(a0)
	move.b d1,ph6+3-ph1(a0)
	move.b d1,ph7+3-ph1(a0)
	move.b d1,ph8+3-ph1(a0)
	move.b d2,ph9+3-ph1(a0)
	move.b d2,ph10+3-ph1(a0)
	neg.w d0
	neg.w d1
	move.b d0,dph1+3-ph1(a0)
	move.b d0,dph2+3-ph1(a0)
	move.b d1,dph5+3-ph1(a0)
	move.b d1,dph6+3-ph1(a0)
	move.b d2,dph9+3-ph1(a0)
	move.b d2,dph10+3-ph1(a0)

	lea.l coord(pc),a2
	move.l #predist+100*2,a5
	move.l #premul1+100*256,a0
	move.l #premul2+100*256,a4
	move.l #prerot+100*4*2*2,d5
	move.l #pre160+100*2,d6
	
	move.l ec,a6
	move.l #circbase,a3
	move.w #202*2,d4
	
	moveq #29,d7
bou:	move.w (a2)+,d0
	move.w (a2)+,d2
ph1:	move.b (a0,d0.w),d3
ph2:	move.b (a4,d0.w),d0
	ext.w d0
	ext.w d3
	add.w d3,d3
	move.w (a5,d3.w),d3
ph5:	move.b (a0,d3.w),d1
ph6:	move.b (a4,d3.w),d3
ph7:	add.b (a0,d2.w),d3
ph8:	sub.b (a4,d2.w),d1
	ext.w d3
	ext.w d1
	add.w d0,d0
	add.w d3,d3
	move.w (a5,d0.w),d0
ph9:	move.b (a0,d0.w),d0
	move.w (a5,d3.w),d3
ph10:	add.b (a4,d3.w),d0
	ext.w d0
	add.w d0,d0
	add.w d1,d1
	move.w d1,(a3)+
	add.w d1,d1
	move.l d6,a1
	move.w (a1,d0.w),d2
	add.w d4,d0
	move.w d0,(a3)+
	move.l d5,a1
	add.w d1,d1
	add.w d1,d1
	move.l (a1,d1.w),d0
	move.l 4(a1,d1.w),d1
	add.w d2,d1
	or.w d0,(a6,d1.w)
	swap.w d0
	swap.w d1
	sub.w d2,d1
	or.w d0,(a6,d1.w)
	dbf d7,bou
	
	move.l #centre,a3
	move.l #barre,a2
	move.l d6,a6
	moveq #12,d7
dbou:	
	move.w (a2)+,d1
	moveq #0,d0
dph1:	sub.b (a0,d1.w),d0
dph2:	move.b (a4,d1.w),d3
	ext.w d0
	ext.w d3
	add.w d3,d3
	move.w (a5,d3.w),d3
dph5:	move.b (a0,d3.w),d1
dph6:	move.b (a4,d3.w),d3
	ext.w d3
	ext.w d1
	add.w d0,d0
	add.w d3,d3
	move.w (a5,d0.w),d0
dph9:	move.b (a0,d0.w),d0
	move.w (a5,d3.w),d3
dph10:	add.b (a4,d3.w),d0
	ext.w d0
	move.w d1,(a3)+
	add.w d0,d0
	move.w (a6,d0.w),(a3)+
	dbf d7,dbou
	
	move.l #dimtabx+100*2,a1
	move.l #centre,a0
	move.l a0,usp
	move.l #pre4096+100*2,d6
	moveq #12,d5
aff2:
	move.l ec(pc),a3
	move.l a3,a2
	move.l #circbase,a0
	
	move.l usp,a6
	move.w (a6)+,d0
	move.w (a6)+,d3
	move.l a6,usp
	move.w d0,d4
	move.w d3,d7
	neg.w d4
	neg.w d7
	move.w d4,d1
	and.w #-16,d4
	move.w d4,d2
	asr.w #1,d2
	add.w d2,d7
	lea.l (a2,d7.w),a2
	
	move.w d0,d1
	and.w #-16,d0
	move.w d0,d2
	asr.w #1,d2
	add.w d2,d3
	lea.l (a3,d3.w),a3
	
	move.l d6,a6
	moveq #0,d2
	sub.w d0,d1
	add.w d1,d1
	move.w (a6,d1.w),d2
	move.l #prerot+100*4*2*2,a4
	add.l d2,a4
	
	moveq #29,d7
gg:	move.w (a0)+,d1
	move.w (a1,d1.w),d3
	move.w (a0)+,d2
	move.w (a1,d2.w),d4
	movem.l (a4,d3.w),d0-d3
	add.w d4,d1
	or.w d0,(a3,d1.w)
	swap.w d0
	swap.w d1
	sub.w d4,d1
	or.w d0,(a3,d1.w)
	add.w d4,d3
	or.w d2,(a2,d3.w)
	swap.w d2
	swap.w d3
	sub.w d4,d3
	or.w d2,(a2,d3.w)
	dbf d7,gg

	lea.l 201*2*2(a1),a1
	dbf d5,aff2
	
ert:	
	move.l nextcol(pc),a0
	movem.l (a0)+,d0-d7
	movem.l d0-d7,$ffff8240.w
	
	rte

fintot:	
	move.w #$2700,sr
	move.l (sp)+,$ffff8200.w
	move.l (sp)+,$70.w
	move.l (sp)+,$fffffa06.w
	move.w (sp)+,sr
	
	movem.l (sp)+,d0-d7
	movem.l d0-d7,$ffff8240.w
	
	move.l (sp)+,2(sp)
	trap #1
	addq.l #6,sp
	
	clr.w -(sp)
	trap #1
	
vbl:	
	add.w #1,cmpt
	cmp.w #50*8,cmpt
	bne.s cmp5
	move.w #$1234,cmpt
cmp5:	
	move.l #%01010101010101010011001100110011,d6
	move.l #%00001111000011111111111111111111,d7
	move.l d6,d4
	move.l d7,d5
change2:	move.l #$78000+160+230+197*230+8,a0
	lea.l log(pc),a1
	moveq #10,d3
logo3:	move.l (a1)+,d1
	moveq #23,d0
logo:	not.l d4
	not.l d5
	clr.w d5
	btst.l d0,d1
	beq.s endlog
	move.l d6,(a0)
	move.l d7,4(a0)
	not.l d6
	not.l d7
	move.w d2,d7
	move.l d6,8*230(a0)
	move.l d7,8*230+4(a0)
	not.l d6
	not.l d7
	move.w d2,d7
	move.l d4,16*230(a0)
	move.l d5,16*230+4(a0)
endlog:	addq.l #8,a0
	dbf d0,logo
	lea.l 230-24*8+15*230(a0),a0
	dbf d3,logo3

	lea change2+2(pc),a0
chboot:	cmp.l #$78000+160+230+13*230+8,(a0)
	beq.s a0p78
	sub.l #230,(a0)
a0p78:
	lea.l change+2(pc),a0
	add.l #2,(a0)
	cmp.l #databoot+2*8,(a0)
	bne.s cou
	sub.l #2*8,(a0)
cou:	
	lea.l $ffff8209.w,a0
sync:	move.b (a0),d0
	beq.s sync
	neg.w d0
	lsr.l d0,d0
	moveq #2,d0
	moveq #0,d1
	lea.l $ffff8260.w,a0
	lea.l $ffff820a.w,a1
	moveq #15+2+1+1,d2
p3:	dbf d2,p3
change:	move.l #databoot,a5
	move.w #198,d3
over:
	move.b d0,(a0)
	nop
	move.b d1,(a0)
	movem.l a2/a3/a4/a6,$ffff8250.w
	moveq #27-3-2-3-2-3+1+1,d2
p1:	dbf d2,p1
	movem.l (a5),d4-d7
	movem.l 32(a5),a2/a3/a4/a6
	lea.l 32*2(a5),a5
	move.b d1,(a1)
	move.b d0,(a1)
	move.w #1,d2
p4:	dbf d2,p4
	move.l d4,$ffff8240.w
	move.b d0,(a0)
	nop
	move.b d1,(a0)
	movem.l d5-d7,$ffff8244.w
	dbf d3,over

	clr.w $ffff8240.w
	rte

log:	dc.l %111011101110111011101111
	dc.l %100010001000010010101001
	dc.l %111011001000010010101111 
	dc.l %001010001000010010101010
	dc.l %111011101110010011101001
	dc.l %0
	dc.l %000000000001100000000000
	dc.l %000000000011100000000000
	dc.l %000000000001100000000000
	dc.l %000000000001100000000000
	dc.l %000000000011110000000000
cmpt:	dc.w 0

	;data boule************************
cos:	incbin "COS.BIN"
divtab:	dc.w 257,259,263,268,276,287,301,320,347,387,453,587,1152
coord:	incbin 'NEWBOUL2.BIN'
barre:	dc.w 2*256,4*256,6*256,8*256,10*256,12*256,14*256
	dc.w 16*256,18*256,20*256,22*256,24*256,26*256
	;couleurs meerclaw
C1	SET $777
C2	SET $666
C3	SET $555
C4	SET $333 
pal1:	dc.w 0,C1,C4,C1,C3,C1,C3,C1,C2,C1,C2,C1,C2,C1,C2,C1
pal2:	dc.w 0,C2,C1,C1,C4,C2,C1,C1,C3,C2,C1,C1,C3,C2,C1,C1
pal3:	dc.w 0,C3,C2,C2,C1,C1,C1,C1,C4,C3,C2,C2,C1,C1,C1,C1
pal4:	dc.w 0,C4,C3,C3,C2,C2,C2,C2,C1,C1,C1,C1,C1,C1,C1,C1
ang:	dc.w 0,0,0
adang:	dc.w 1,0,1	
flagclr:	dc.w 0

dbss:

nextcol:	= dbss				;.l 1
prerot:	= dbss+8
dimtabx:	= dbss+8+256*16*2*2*4
premul1:	= dbss+8+256*16*2*2*4+201*2*13*2
premul2:	= dbss+8+256*16*2*2*4+201*2*13*2+256*201	;.b 256*201
centre:	= premul2+256*201			;.w 13*2
circbase:	= centre+13*2*2			;.w 120
pre160:	= circbase+120*2			;.w 201
predist:	= pre160+201*2			;.w 201
pre4096:	= predist+201*2			;.w 201

premul:	= premul1

ec:	= dbss+4
databoot:	= dbss+8

adfin:	= dbss+200000