 	opt	o+

	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l  -(sp)
    	move.w #$20,-(sp)
    	trap   #1
	addq	#6,sp
super:
    	move.w 	#$2700,sr

	move.l	#$07070000,$ffff8200.w
    	
    	moveq	#0,d1
    	move.l	d1,a0
    	movep.l	d1,$fffffa01(a0)
    	movep.l	d1,$fffffa09(a0)
    	movep.l	d1,$fffffa11(a0)
    	movep.l	d1,$fffffa19(a0)
    	move.b	#$48,$fffffa17.w
    	
    	move.b 	#2,$ffff820a.w
    	move.b 	#7,$ffff8800.w
    	move.b 	#-1,$ffff8802.w
    	move.b 	#14,$ffff8800.w
    	move.b 	#7,$ffff8802.w

    	move.b 	#1,$fffffa07.w
    	move.b 	#0,$fffffa09.w
    	move.b 	#1,$fffffa13.w
    	move.b 	#0,$fffffa15.w
    	move.b   #$40,$fffffa17.w
    	clr.b  	-$5e5.w
    	move.l 	#inter,$70.w
    	move.l 	#inter1,$120.w

	moveq	#0,d3
    	lea	$70000,a0
    	move.w	#40000,d1
fun	clr.w	(a0)+
	dbra	d1,fun
	move.w	#$035,$ffff8240.w
	move.w	#$025,$ffff8242.w
	move.w	#$777,$ffff8244.w
	move.w	#$001,$ffff8246.w
	move.w	#$740,$ffff8248.w
	move.l 	#$700a8,a0
    	move.l 	#ecrane+34,a1
    	move.w 	#200,d1
af0:
    	move.l 	a0,a2
    	moveq 	#39,d0
af1:
    	move.l 	(a1)+,(a2)+
    	dbf    	d0,af1
    	lea    	230(a0),a0
    	dbf    	d1,af0
	move.l 	#$700a8+$e6*200,a0
    	move.l 	#pic3,a1
    	move.w 	#100,d1
aaf0:
    	move.l 	a0,a2
    	moveq 	#39,d0
aaf1:
    	move.l 	(a1)+,(a2)+
    	dbf    	d0,aaf1
    	lea    	230(a0),a0
    	dbf    	d1,aaf0
	move.l 	#$70108+$8*8+$e6*40,a0
    	move.l 	#pic,a1
    	move.w 	#40,d1
.aaff0:
	rept	10
	move.l	(a1)+,(a0)+
	endr
	lea	198-8(a0),a0
	dbf	d1,.aaff0
	move.l 	#$70108+$8*8+$e6*80,a0
    	move.l 	#pic,a1
    	move.w 	#40,d1
baaff0:
	rept	10
	move.l	(a1)+,(a0)+
	endr
	lea	198-8(a0),a0
	dbf	d1,baaff0
	move.l 	#$70108+$8*8+$e6*120,a0
    	move.l 	#pic,a1
    	move.w 	#40,d1
caaff0:
	rept	10
	move.l	(a1)+,(a0)+
	endr
	lea	198-8(a0),a0
	dbf	d1,caaff0
	move.l 	#$70108+$8*8+$e6*160,a0
    	move.l 	#pic,a1
    	move.w 	#40,d1
daaff0:
	rept	10
	move.l	(a1)+,(a0)+
	endr
	lea	198-8(a0),a0
	dbf	d1,daaff0
	move.l 	#$70108+$8*8+$e6*200,a0
    	move.l 	#pic,a1
    	move.w 	#40,d1
eaaff0:
	rept	10
	move.l	(a1)+,(a0)+
	endr
	lea	198-8(a0),a0
	dbf	d1,eaaff0
	move.l 	#$70108+$8*8+$e6*240,a0
    	move.l 	#pic,a1
    	move.w 	#40,d1
faaff0:
	rept	10
	move.l	(a1)+,(a0)+
	endr
	lea	198-8(a0),a0
	dbf	d1,faaff0
	move.l 	#$70108+$8*8+$e6*1,a0
    	move.l 	#pic2,a1
    	move.w 	#40,d1
gaaff0:
	rept	10
	move.l	(a1)+,(a0)+
	endr
	lea	198-8(a0),a0
	dbf	d1,gaaff0
	
	move.w 	#$2300,sr
	moveq  	#40,d0
synch0:
    	sf     	flvbl
syn1:
    	tst.b  	flvbl
    	beq.s  	syn1
    	dbf    	d0,synch0
	move.w	#$035,$ffff8240.w
	move.w	#$025,$ffff8242.w
	move.w	#$777,$ffff8244.w
	move.w	#$001,$ffff8246.w
	move.w	#$740,$ffff8248.w

	move.l 	#inter0,$70.w
	move.w	#240,d4
synchr:
    	sf     	flvbl
syn0:
    	tst.b	flvbl
    	beq.s  	syn0
	clr.l  	d7
       	move.l 	#jump,a5
    	move.l 	#$ffff8209,a6
    	cmp.b  	#$39,$fffffc02.w
    	dbra  	d4,synchr
end
gt:
    	move.w  #$2700,sr

    	moveq	#0,d1
    	move.l	d1,a0
    	movep.l	d1,$fffffa01(a0)
    	movep.l	d1,$fffffa09(a0)
    	movep.l	d1,$fffffa11(a0)
    	movep.l	d1,$fffffa19(a0)
    	move.b	#$48,$fffffa17.w

	move.l	#$07070000,$ffff8200.w
	move.l	#newvblmcoder,$70.w
    	move.w  #$2300,sr
	movem.l	pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	bsr	cls

	move.l 	#$70000,a2
	lea	160*80+16(a2),a2
    	move.l 	#ecran2,a1
    	move.w 	#41*40,d1
aaff0:
    	move.l 	(a1)+,(a2)+
    	dbf    	d1,aaff0
	move.l	#90000,d2
jean11	moveq	#55,d3
asma11	dbra	d3,asma11
	dbra	d2,jean11
	movem.l	palet,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	#$70000,a1
	move.l	#imager+34,a2
	move.w	#7999,d2
homo	move.l	(a2)+,(a1)+
	dbra	d2,homo
	move.w	#$000,$ffff8240.w
	move.w	#$700,$ffff8242.w
	move.w	#$700,$ffff8244.w
	move.w	#$700,$ffff8246.w
	move.w	#$700,$ffff8248.w
	move.w	#$000,$ffff824a.w
	move.w	#$700,$ffff824c.w
	move.w	#$700,$ffff824e.w
	bsr	beep
	move.l	#90000,d2
jean	moveq	#22,d3
asma	dbra	d3,asma
	dbra	d2,jean
	move.w	#$700,$ffff8242.w
	move.w	#$700,$ffff8244.w
	move.w	#$700,$ffff8246.w
	move.w	#$700,$ffff8248.w
	move.w	#$700,$ffff824a.w
	move.w	#$700,$ffff824c.w
	move.w	#$700,$ffff824e.w
	bsr	beep
	move.l	#90000,d2
jean2	moveq	#22,d3
asma2	dbra	d3,asma2
	dbra	d2,jean2
	move.w	#$700,$ffff8242.w
	move.w	#$700,$ffff8244.w
	move.w	#$000,$ffff8246.w
	move.w	#$000,$ffff8248.w
	move.w	#$000,$ffff824a.w
	move.w	#$000,$ffff824c.w
	move.w	#$700,$ffff824e.w
	bsr	beep
	move.l	#90000,d2
jean3	moveq	#22,d3
asma3	dbra	d3,asma3
	dbra	d2,jean3

	move.w	#$700,$ffff8242.w
	move.w	#$000,$ffff8244.w
	move.w	#$700,$ffff8246.w
	move.w	#$700,$ffff8248.w
	move.w	#$700,$ffff824a.w
	move.w	#$700,$ffff824c.w
	move.w	#$700,$ffff824e.w
	bsr	beep
	move.l	#90000,d2
jean4	moveq	#22,d3
asma4	dbra	d3,asma4
	dbra	d2,jean4

	move.w	#$700,$ffff8242.w
	move.w	#$000,$ffff8244.w
	move.w	#$700,$ffff8246.w
	move.w	#$700,$ffff8248.w
	move.w	#$000,$ffff824a.w
	move.w	#$700,$ffff824c.w
	move.w	#$700,$ffff824e.w
	bsr	beep
	move.l	#90000,d2
jean5	moveq	#22,d3
asma5	dbra	d3,asma5
	dbra	d2,jean5

	move.w	#$000,$ffff8242.w
	move.w	#$700,$ffff8244.w
	move.w	#$700,$ffff8246.w
	move.w	#$700,$ffff8248.w
	move.w	#$000,$ffff824a.w
	move.w	#$000,$ffff824c.w
	move.w	#$700,$ffff824e.w
	bsr	beep	
	move.l	#90000,d2
jean6	moveq	#22,d3
asma6	dbra	d3,asma6
	dbra	d2,jean6
	move.w	#$700,$ffff8242.w
	move.w	#$700,$ffff8244.w
	move.w	#$700,$ffff8246.w
	move.w	#$000,$ffff8248.w
	move.w	#$000,$ffff824a.w
	move.w	#$700,$ffff824c.w
	move.w	#$700,$ffff824e.w
	bsr	beep
	move.l	#90000,d2
jean7	moveq	#22,d3
asma7	dbra	d3,asma7
	dbra	d2,jean7
	move.w	#$700,$ffff8242.w
	move.w	#$700,$ffff8244.w
	move.w	#$700,$ffff8246.w
	move.w	#$000,$ffff8248.w
	move.w	#$700,$ffff824a.w
	move.w	#$700,$ffff824c.w
	move.w	#$000,$ffff824e.w
	bsr	beep
	move.l	#90000,d2
jean8	moveq	#22,d3
asma8	dbra	d3,asma8
	dbra	d2,jean8
	move.w	#$000,$ffff8242.w
	move.w	#$700,$ffff8244.w
	move.w	#$000,$ffff8246.w
	move.w	#$000,$ffff8248.w
	move.w	#$000,$ffff824a.w
	move.w	#$000,$ffff824c.w
	move.w	#$700,$ffff824e.w
	bsr	beep
	move.l	#90000,d2
jean9	moveq	#22,d3
asma9	dbra	d3,asma9
	dbra	d2,jean9
	move.w	#$700,$ffff8242.w
	move.w	#$700,$ffff8244.w
	move.w	#$000,$ffff8246.w
	move.w	#$700,$ffff8248.w
	move.w	#$700,$ffff824a.w
	move.w	#$700,$ffff824c.w
	move.w	#$700,$ffff824e.w
	bsr	beep
	move.l	#90000,d2
jean10	moveq	#22,d3
asma10	dbra	d3,asma10
	dbra	d2,jean10
	LEA	mus+$C3E,A0
	MOVE.L	#mus-$7D52,D0
	MOVEQ	#4-1,D1
homo2e:	ADD.L	D0,(A0)+
	DBRA	D1,homo2e

	moveq	#2,d0		* Numero de la zik ( 1 - 4 )
	JSR	mus
	jsr	mus+8

	move.l	#buffer+255,d0
	clr.b	d0
	move.l	d0,ecran
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	movem.l	logo+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	ecran,a1
	move.w	#300*40,d2
cop	clr.l	(a1)+
	dbra	d2,cop
	move.l	ecran,a1
	lea	200*160(a1),a1
	move.l	#tsg,a0
	move.w	#40*37,d0
copy2	move.l	(a0)+,(a1)+
	dbf	d0,copy2
	move.l	ecran,a1
	move.l	#logo+34,a0
	move.w	#40*199,d0
aff	move.l	(a0)+,(a1)+
	dbra	d0,aff
	clr.b	$fffffa1b.w
	move.l	#ixion1,$120.w
	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w

        lea 	text,a6
	move.l	#vbl_ir,$70.w
bcl:
	cmp.b	#$39,$fffffc02.w
	bne.s	bcl
	move.b	#8,$fffffc02.w
	jsr	mus+12
	jmp	$500.w			;retour au loader

led
	move.b	#10,$ffff8800.w
	btst	#3,$ffff8800.w
	bne.s	glere
	move.l	#$0e0e0303,$ffff8800.w
	jmp	ok
glere
	move.l	#$0e0e0404,$ffff8800.w
ok	rts
led2
	move.b	#11,$ffff8800.w
	btst	#3,$ffff8800.w
	bne.s	glere2
	move.b	#14,$ffff8800.w
	move.w	#$777,$ffff825c.w
	jmp	ok
glere2	move.b	#14,$ffff8800.w
	move.w	#$444,$ffff825c.w
ok2	rts

vbl_ir
	movem.l	d0-d7/a0-a5,-(sp)
	clr.b	$fffffa1b.w
	move.b	#197,$fffffa21.w
	move.b	#8,$fffffa1b.w
	movem.l	(sp)+,d0-d7/a0-a5
	movem.l	d2/a6,-(sp)
	jsr	mus+4
	movem.l	(sp)+,d2/a6
	move.w	#800,d4
strix	nop
	dbra	d4,strix
	bsr	led
	bsr	led2
	bsr	scroll
	bsr	refresh
	rte
ixion1
	clr.b	$fffffa1b.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#tb2_ir,$120.w
	bclr	#0,$fffffa0f.w
	rte
tb2_ir
	move.b	#0,$ffff820a.w
	rept	122
	nop
	endr
	move.b	#0,$ffff820a.w
	rept	9
	nop
	endr
	move.b	#2,$ffff820a.w
	clr.b	$fffffa1b.w
	move.l	#ixion1,$120.w
	bclr	#0,$fffffa0f.w
	rte
scroll:
 	move.l 	ecran,a2
 	lea 	160*122(a2),a2
 	moveq 	#30,d6
who
 	move.b 	1+160*0(a2),160*0(a2)
 	move.b 	8+160*0(a2),1+160*0(a2)
 	move.b 	9+160*0(a2),8+160*0(a2)
 	move.b 	16+160*0(a2),9+160*0(a2)
 	move.b 	17+160*0(a2),16+160*0(a2)
 	move.b	24+160*0(a2),17+160*0(a2)
 	move.b 	25+160*0(a2),24+160*0(a2)
 	move.b	32(a2),25+160*0(a2)
 	move.b 	33(a2),32(a2)
 	move.b 	40+160*0(a2),33(a2)
 	move.b 	41+160*0(a2),40+160*0(a2)
	move.b 	48+160*0(a2),41+160*0(a2)
 	move.b 	49+160*0(a2),48+160*0(a2)
 	move.b 	56+160*0(a2),49+160*0(a2)
 	move.b 	57+160*0(a2),56+160*0(a2)
 	move.b 	64+160*0(a2),57+160*0(a2)
 	move.b 	65+160*0(a2),64+160*0(a2)
 	move.b 	72+160*0(a2),65+160*0(a2)
 	move.b 	73+160*0(a2),72+160*0(a2)
 	move.b 	80+160*0(a2),73+160*0(a2)
 	move.b 	81(a2),80+160*0(a2)
 	move.b	88(a2),81(a2)
 	move.b 	89+160*0(a2),88(a2)
 	move.b 	96+160*0(a2),89+160*0(a2)
 	move.b 	97+160*0(a2),96+160*0(a2)
 	move.b	104+160*0(a2),97+160*0(a2)
 	move.b 	105+160*0(a2),104+160*0(a2)
 	move.b 	112+160*0(a2),105+160*0(a2)
 	move.b 	113+160*0(a2),112+160*0(a2)
 	move.b 	120+160*0(a2),113+160*0(a2)
 	move.b 	121+160*0(a2),120+160*0(a2)
 	move.b	128+160*0(a2),121+160*0(a2)
 	move.b 	129+160*0(a2),128+160*0(a2)
 	move.b 	136(a2),129+160*0(a2)
 	move.b 	137(a2),136(a2)
 	move.b 	144(a2),137(a2)
 	move.b 	145(a2),144(a2)
 	move.b 	152(a2),145(a2)
 	move.b 	153(a2),152(a2)
 
 	lea 	160(a2),a2
 	dbra 	d6,who
 	rts

refresh
 	clr.w	d2
 	move.b	(a6),d2
 	cmp.b	#$ff,d2
 	bne.s	.nul
 	lea	text,a6
 	move.b	(a6),d2
.nul
 	sub.w 	#32,d2
 	mulu 	#32*16/4,d2

 	lea 	buf,a3
	add	delir,a3
	addq	#1,delir
	and	#3,delir
	bne.s	.refresh
	addq	#1,a6
.refresh
 	add.l 	d2,a3
 	move.l 	ecran,a5
x	set	0
	rept	30
 	move.b	x*4(a3),160*122+152+1+x*160(a5)
x	set	x+1
	endr
 	rts

cls:	lea	$70000,a0
	move	#32000/4-1,d0
	moveq	#0,d1
.1	move.l	d1,(a0)+
	dbra	d0,.1
	rts

beep	move.l	#snd,sound
	rts
newvblmcoder
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	snd_irq
	movem.l	(sp)+,d0-d7/a0-a6
	rte

snd_irq:
	move.l	sound,d0
	beq.s	.fini
	move.l	d0,a0
	move.b	count,d0
	beq.s	.new
	subq.b	#1,count
.fini	rts
.new
	move.b	(a0)+,d0
	bmi.s	.sup8
	move.b	d0,$ffff8800.w
	cmp.b	#7,d0
	bne.s	.1
	move.b	(a0)+,d1
	and	#$3f,d1
	move.b	$ffff8800.w,d0
	and	#$c0,d0
	or	d1,d0
	move.b	d0,$ffff8802.w
	bra.s	.new
.1
	move.b	(a0)+,$ffff8802.w
	bra.s	.new
.sup8
	addq.b	#1,d0
	bpl.s	.2
	cmp.b	#$81,d0
	bne.s	.3
	move.b	(a0)+,inc
	bra.s	.new

.3	cmp.b	#$82,d0
	bne.s	.2

	move.b	(a0)+,$ffff8800.w
	move.b	(a0)+,d0
	add.b	d0,inc
	move.b	(a0)+,d0
	move.b	inc,$ffff8802.w
	cmp.b	inc,d0
	beq.s	.xx
	subq	#4,a0
	bra.s	.xx
.2	move.b	(a0)+,count
	bne.s	.xx
	sub.l	a0,a0
.xx	move.l	a0,sound
	rts
sound:	dc.L	0
inc:	dc.b	0
count:	dc.b	0

inter: 	st 	flvbl
       	rte
inter0:
    	clr.b   -$5e5.w
    	move.b  #$68,-$5df.w
    	move.b  #4,-$5e5.w
    	st      flvbl
    	rte
inter1:
 	rept 	22
 	nop
 	endr
    	clr.b	$ffff820a.w
 	rept 	16
 	nop
 	endr
    	move.b	#2,$ffff820a.w
    	clr.b   -$5e5.w
    	move.b	(a6),d7
    	beq.s   g0
    	rte
g0: 	move.b     (a6),d7
    	beq.s      g0
    	jmp        (a5,d7.w)
jump: 
	dc.l    $4e714e71,$4e714e71,$4e714e71,$4e714e71,$4e714e71,$4e714e71
 	rept 	81
 	nop
 	endr
    	lea     table2,a2
    	lea     $ffff820a.w,a0
    	lea     $ffff8260.w,a1
    	moveq   #0,d0
    	moveq   #2,d1
	move.w	#226,d7
i2:
    	nop
    	move.b	d1,(a1)
    	move.b	d0,(a1)
 	rept 	89
 	nop
 	endr
    	move.b  d0,(a0)
    	move.b  d1,(a0)
 	rept 	13
 	nop
 	endr
    	move.b  d1,(a1)
    	nop
    	move.b  d0,(a1)
 	move.w	(a2)+,$ffff826e.w    
 	rept 	5
 	nop
 	endr	
    	dbf	d7,i2
    	move.b	d1,(a1)
    	move.b	d0,(a1)
 	rept 	89
 	nop
 	endr
    	move.b	d0,(a0)
    	move.b  d1,(a0)
 	rept 	13
 	nop
 	endr
    	move.b  d1,(a1)
    	nop
    	move.b  d0,(a1)
    	move.b  d0,(a0) 
    	move.w  (a2)+,$ffff826e.w
 	rept 5
 	nop
 	endr
	moveq	#44,d7
    	nop
i3:
    	move.b	d1,(a1)
    	move.b	d0,(a1)
    	nop
    	move.b  d1,(a0)
 	rept 	86
 	nop
 	endr
    	move.b  d0,(a0)
    	move.b  d1,(a0)
 	rept 	13
 	nop
 	endr
    	move.b  d1,(a1)
    	nop	
    	move.b  d0,(a1)
    	move.w  (a2)+,$ffff826e.w
 	rept 	6
 	nop
 	endr
    	dbf     d7,i3
    	rte
table2: 
	rept 	100
	dc.w	$000
	endr
       	dc.w	$001,$002,$003,$004,$005,$006,$007,$017,$027,$037,$047,$057,$067,$077,$177,$277,$377,$477,$577,$677,$777
       	dc.w 	$777,$677,$577,$477,$377,$277,$177,$077,$067,$057,$047,$037,$027,$017,$007,$006,$005,$004,$003,$002,$001,$000
	rept 	10
	dc.w	$000
	endr
       	dc.w	$001,$002,$003,$004,$005,$006,$007,$017,$027,$037,$047,$057,$067,$077,$177,$277,$377,$477,$577,$677,$777
       	dc.w 	$777,$677,$577,$477,$377,$277,$177,$077,$067,$057,$047,$037,$027,$017,$007,$006,$005,$004,$003,$002,$001,$000
	rept 	100
	dc.w	$000
	endr
ecrane: 
	incbin 	work.pi1
pic:	
	incbin	blk.bin
pic2:	
	incbin	blk2.bin
pic3:
	incbin	blk4.bin
ecran2: 
	incbin 	no.blk
pal:
	dc.w	$000,$346,$135,$556
	dc.w	$246,$300,$456,$100
	dc.w	$025,$410,$532,$543
	dc.w	$200,$014,$432,$760
imager	incbin	kuartz.pi1
palet	
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000		
snd:	dc.w	$00bf,$0900
	dc.w	$07fe,$080f
	dc.w	$8209,$07ff
	dc.w	$ff00,$0000
	dc.w	$1d22,$1b20
buf: 	incbin NEWFONTE.bin
	even
text 
	DC.B	"      HELLO !!!    SKYRACE FROM HEMOROIDS ISN'T PROUD TO PRESENT HIS VERY LAME INTRO AT THE CODING-PARTY ORGANISED BY THE SERGENT. IT'S 5H40 IN THE MORNING AND WE ARE VERY TIRED. THE CREW WHO ARE AT THE CODING-PARTY ARE : FUZION, "
	DC.B	" MAD-VISION, PENDRAGONS, OVERLANDERS, EQUINOX, PHENIX, THE BLACK CATS AND THE BUSHWACKERS. STRANGLERS (TSG) IS AN ALLIANCE COMPOSED OF HEMOROIDS AND FUZION. CREDITS : BAD CODING BY SKYRACE AND GRAFIX BY WOODY. "
	DC.B	" HEMOROIDS MEMBERS ARE : CKAOS, SKYRACE, GLUEV, PARANOIDS, SINK, SKYHAWK, DOCTOR BIT, WOODY. AND FUZION'S MEMBERS ARE : THE DRAGON, FULCRUM, DOCNO, DARLIGHT, ORION, SPEEDER, SQUAT. "
	DC.B	" WE SEND OUR BEST REGARDS TO : THE EMPIRE ( V8 ), PENDRAGONS, OVERLANDERS, FUZION, PHENIX, MAD-VISION, FUTURE MINDS, FIRE-CRACKERS, ST CONNEXION, EQUINOX, SOFTTRACKS, IMPACT, NEXT, MCODER, RICK, PLAY, JOYDEATH, JOYDEATH, "
	DC.B	"CHED, THE BLACK CATS, ALGERNON, ERENDIL, BLOODY OF OCG, X-RAY AND ALL OTHER I HAVE FORGOTTEN AND NOW A FUCKING MEGA-FUCK TO JERRY OF OCG ( THE BIGGEST LAMERS ON THE ST ). AND NOW I MUST LEAVE YOU .... BYE .... BYE ...."
	DC.B	" CONTACT US ON RTEL BAL : SKYRACE, HEMOROIDS, GLUEV, PARANOIDS, SINK, SKYHAWK ...... BYE ......"
 	DC.B	$FF

	even	
logo:	incbin	"pic.pi1"
	even
mus:	incbin	"chamber2.mus"
	even
tsg:	incbin 	"tsg.blk"
	even
ecran	ds.l	1
delir	dc.w	0
flvbl: 	dc.b 	0
 	even
buffer
