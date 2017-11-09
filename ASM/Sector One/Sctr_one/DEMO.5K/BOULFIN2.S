	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,stack

	dc.w $a00a

	move.w #2,-(sp)
	trap #14
	addq.l #2,sp
	move.l d0,xb2

	move.w #4,-(sp)
	trap #14
	addq.l #2,sp
	move.w d0,res

	move.l #adfin,d0
	add.l #256,d0
	clr.b d0
	move.l d0,ecr1
	add.l #32000+256,d0
	clr.b d0
	move.l d0,ecr2
	
	clr.w -(sp)
	move.l ecr1,-(sp)
	move.l #-1,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #12,sp

	movem.l $ffff8240,d0-d7
	movem.l d0-d7,color

	move.l ecr1,a0
	move.w #8000*2+300,d0
	moveq #0,d1
remp2:	move.l d1,(a0)+
	dbf d0,remp2	
	
	move.w sr,oldsr
	move.w #$2700,sr
	move.l usp,a0
	move.l a0,oldusp
	move.l $fffffa06,int
	clr.b $fffffa07
	clr.b $fffffa09
	move.l $70,oldvbl
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
	
fin:	move.w #$2700,sr
	move.l oldusp,a0
	move.l a0,usp
	move.l int,$fffffa06
	move.l oldvbl,$70
	move.w oldsr,sr

	move.w res,-(sp)
	move.l xb2,-(sp)
	move.l #-1,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #12,sp

	movem.l color,d0-d7
	movem.l d0-d7,$ffff8240

	move.l stack,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp

	dc.w $a00a

	clr.w -(sp)
	trap #1

vblstart:	move.l #vbl,$70.w
	rte

stack:	dc.l 0
xb2:	dc.l 0
oldusp:	dc.l 0
oldvbl:	dc.l 0
int:	dc.l 0
ecr1:	dc.l 0
ecr2:	dc.l 0
color:	ds.l 8
res:	dc.w 0
oldsr:	dc.w 0
tabch:	move.w (a0)+,d1
	move.w -(a0),d1
	move.w (a1)+,d1
	move.w -(a1),d1
	neg.w d1
	nop

vbl:	
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
ec:	= nextcol+4			;.l 1
prerot:	= dbss+8
dimtabx:	= dbss+8+256*16*2*2*4
premul1:	= dbss+8+256*16*2*2*4+201*2*13*2
premul2:	= dbss+8+256*16*2*2*4+201*2*13*2+256*201	;.b 256*201
centre:	= premul2+256*201			;.w 13*2
circbase:	= centre+13*2*2			;.w 120
pre160:	= circbase+120*2			;.w 201
predist:	= pre160+201*2			;.w 201
pre4096:	= predist+201*2			;.w 201

adfin:	= dbss+200000