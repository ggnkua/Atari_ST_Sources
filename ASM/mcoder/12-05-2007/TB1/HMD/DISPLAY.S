ecran = $60000

	moveq	#0,d3
	lea	ecran,a0
	move.w	#65536/4-1,d1
fun	clr.l	(a0)+
	dbra	d1,fun
	move.l	#ecran+$a8,a0
	move.l	#ecrane+34,a1
	move.w	#200,d1
af0:
	move.l	a0,a2
	moveq	#39,d0
af1:
	move.l	(a1)+,(a2)+
	dbf	d0,af1
	lea	230(a0),a0
	dbf	d1,af0
	move.l	#ecran+$a8+$e6*200,a0
	move.l	#pic3,a1
	move.w	#100,d1
aaf0:
	move.l	a0,a2
	moveq	#39,d0
aaf1:
	move.l	(a1)+,(a2)+
	dbf	d0,aaf1
	lea	230(a0),a0
	dbf	d1,aaf0
	move.l	#ecran+$108+$8*8+$e6*40,a0
	move.l	#pic,a1
	moveq	#40-1,d1
.aaff0:
	rept	10
	move.l	(a1)+,(a0)+
	endr
	lea	198-8(a0),a0
	dbf	d1,.aaff0
	move.l	#ecran+$108+$8*8+$e6*80,a0
	move.l	#pic,a1
	moveq	#40,d1
baaff0:
	rept	10
	move.l	(a1)+,(a0)+
	endr
	lea	198-8(a0),a0
	dbf	d1,baaff0
	move.l	#ecran+$108+$8*8+$e6*120,a0
	move.l	#pic,a1
	moveq	#40-1,d1
caaff0:
	rept	10
	move.l	(a1)+,(a0)+
	endr
	lea	198-8(a0),a0
	dbf	d1,caaff0
	move.l	#ecran+$108+$8*8+$e6*160,a0
	move.l	#pic,a1
	moveq	#40,d1
daaff0:
	rept	10
	move.l	(a1)+,(a0)+
	endr
	lea	198-8(a0),a0
	dbf	d1,daaff0
	move.l	#ecran+$108+$8*8+$e6*200,a0
	move.l	#pic,a1
	moveq	#40,d1
eaaff0:
	rept	10
	move.l	(a1)+,(a0)+
	endr
	lea	198-8(a0),a0
	dbf	d1,eaaff0
	move.l	#ecran+$108+$8*8+$e6*240,a0
	move.l	#pic,a1
	moveq	#40,d1
faaff0:
	rept	10
	move.l	(a1)+,(a0)+
	endr
	lea	198-8(a0),a0
	dbf	d1,faaff0
	move.l	#ecran+$108+$8*8+$e6*1,a0
	move.l	#pic2,a1
	moveq	#40,d1
gaaff0:
	rept	10
	move.l	(a1)+,(a0)+
	endr
	lea	198-8(a0),a0
	dbf	d1,gaaff0
	illegal

ecrane:
	incbin	B:\BUG\work.pi1
pic3:
	incbin	B:\BUG\blk4.bin
pic:
	incbin	B:\BUG\blk.bin
pic2:
	incbin	B:\BUG\blk2.bin
