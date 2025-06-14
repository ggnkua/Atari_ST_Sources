; Automation 222 by Guardians of Logik

; hehe one version I found had the labels in

; Shw/D-Bug 2021!

	opt	x+,w-

	movea.l	a7,a5
	movea.l	4(a5),a5
	move.l	12(a5),d0
	add.l	20(a5),d0
	add.l	28(a5),d0
	addi.l	#$100,d0
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	move.w	d0,-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	adda.l	#$c,a7
	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7


	move.l	d0,old_ssp
	lea	ustck,a7
	clr.w	d0
	move.b	$ff8260.l,d0
	move.w	d0,old_rez
	move.l	$44e.l,old_scr
	move.w	#0,-(a7)
	move.l	#$70000,-(a7)
	move.l	#$70000,-(a7)
	move.w	#5,-(a7)
	trap	#$e
	adda.l	#$c,a7
	move.w	#$12,-(a7)
	move.w	#4,-(a7)
	move.w	#3,-(a7)
	trap	#$d
	addq.l	#6,a7
	movem.l	$ff8240.l,d0-d7
	movem.l	d0-d7,old_pal
	move	#$2700,sr
	move.b	$fffa09.l,old_ieb
	move.b	$fffa07.l,old_iea
	move.b	$fffa13.l,old_ima
	move.l	$120.l,old_hbl_vec
	move.l	$70.l,old_vbl_vec
	move.l	#hbl_handler,$120.l
	move.l	#vbl_handler,$70.l
	andi.b	#$df,$fffa09.l
	andi.b	#$de,$fffa07.l
	ori.b	#1,$fffa07.l
	ori.b	#1,$fffa13.l
	bclr	#6,$fffa09.l
	bclr	#7,$fffa07.l
	move	#$2300,sr
	movea.l	$44e.l,a0
	moveq	#0,d7
	move.w	#$1f3f,d0
clr	move.l	d7,(a0)+
	move.l	d7,(a0)+
	dbf	d0,clr
	lea	l004f,a0
	movea.l	$44e.l,a1
	adda.l	#$a0,a1
	move.w	#$40f,d7
coplog	move.l	(a0)+,(a1)+
	dbf	d7,coplog
	movea.l	$44e.l,a1
	adda.l	#$8fc0,a1
	moveq	#$ff,d0
	move.w	#$3bf,d7
fillit	move.w	d0,6(a1)
	addq.w	#8,a1
	dbf	d7,fillit
	lea	back,a0
	lea	$68238,a1
	bsr	unpac
	lea	$682b8,a0
	movea.l	$44e.l,a1
	lea	4640(a1),a1
	move.w	#$1f3f,d7
copper	move.l	(a0)+,(a1)+
	dbf	d7,copper
	move.l	#0,d0
	jsr	music
wait_loop	move.w	frclock,d0
vlop	cmp.w	frclock,d0
	beq.b	vlop
	lea	sline,a1
	bsr	copy1
	tst.w	monswi
	bne	dscrl
	addq.w	#1,scrcnt
	cmpi.w	#5,scrcnt
	blt	ascrl
	clr.w	scrcnt
	eori.w	#1,wosw
	bne	l0006
	movea.l	cpnt,a1
	addq.w	#2,a1
	bsr	plot8
	bra	ascrl
l0006	movea.l	tpnt,a2
	cmpa.l	#tend,a2
	blt	go2
	lea	sctext,a2
go2	clr.l	d0
	move.b	(a2)+,d0
	cmp.b	#$23,d0
	bne	nscc
	move.w	#1,monswi
	move.l	a2,tpnt
	lea	l005a,a0
	clr.w	d0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	move.w	d0,(a0)
	lea	168(a0),a0
	clr.w	wosw
	bra	dscrl
nscc	move.l	a2,tpnt
	movea.l	addr,a1
	subi.w	#$20,d0
	mulu	len,d0
	adda.l	d0,a1
	move.l	a1,cpnt
	bsr	plot8
ascrl	bsr	scroll
	bra	drpc
dscrl	addq.w	#1,paulscnt
	cmpi.w	#$64,paulscnt
	ble.b	drpc
	clr.w	paulscnt
	clr.w	monswi
drpc	lea	$fffc02.l,a0
	move.b	(a0),d0
	clr.b	(a0)
	cmp.b	#$b,d0
	bne.b	k0np
	eori.w	#$111,$6823c
	eori.w	#1,fsswi
k0np	cmp.b	#2,d0
	bne.b	k1np
	move.l	#tend,path
	bra	exec_im
k1np	cmp.b	#3,d0
	bne.b	k2np
	move.l	#file2,path
	bra	exec_im
k2np	cmp.b	#4,d0
	bne.b	k3np
	move.l	#file3,path
	bra	exec_im
k3np	bra	wait_loop
	dc.b	$b0,'<',0,'9f',0,$fe,'D'
exec_im	dc.b	'F',$fc,$27,0,$13,$f9
	dc.l	old_ieb
	dc.b	0,$ff,$fa,9,$13,$f9
	dc.l	old_iea
	dc.b	0,$ff,$fa,7,$13,$f9
	dc.l	old_ima
	dc.b	0,$ff,$fa,$13,'#',$f9
	dc.l	old_hbl_vec
	dc.b	0,0,1,' #',$f9
	dc.l	old_vbl_vec
	dc.b	0,0,0,'p3',$fc,$ff,$ff
	dc.b	0,0,4,$ee,'F',$fc,'#',0
	dc.b	'L',$f9,0,$ff
	dc.l	old_pal
	dc.b	'H',$f9,0,$ff,0,$ff,$82,'@'
	dc.b	'A',$f9,0,$ff,$88,0,$10,$bc
	dc.b	0,7,0,'(',0,'?',0,2
	dc.b	$10,$bc,0,8,$11,'|',0,0
	dc.b	0,2,$10,$bc,0,9,$11,'|'
	dc.b	0,0,0,2,$10,$bc,0,$a
	dc.b	$11,'|',0,0,0,2,$11,$fc
	dc.b	0,0,$82,$a,'Jy'
	dc.l	fsswi
	dc.b	'f',6,$11,$fc,0,2,$82,$a
	dc.b	'/9'
	dc.l	old_ssp
	dc.b	'?<',0,' NA\',$8f
	dc.b	'?<',0,8,'?<',0,4
	dc.b	'?<',0,3,'NM\',$8f
	dc.b	'?9'
	dc.l	old_rez
	dc.b	'/9'
	dc.l	old_scr
	dc.b	'/9'
	dc.l	old_scr
	dc.b	'?<',0,5,'NN',$df,$fc
	dc.b	0,0,0,$c,'Hy'
	dc.l	null
	dc.b	'Hy'
	dc.l	null
	dc.b	'/9'
	dc.l	path
	dc.b	'?<',0,0,'?<',0,'K'
	dc.b	'NA',$df,$fc,0,0,0,$12
	dc.b	'?<',0,0,'NA'
null	dc.b	0,0
path	dcb.w	2
unpac	adda.l	#4,a0
	movea.l	a0,a4
	move.l	(a0)+,d5
	adda.l	d5,a1
	adda.l	(a0),a0
	suba.l	#4,a0
	tst.w	-(a0)
	bpl.b	l0014
	subq.l	#1,a0
l0014	move.b	-(a0),d0
l0015	lsl.b	#1,d0
	bne.b	l0016
	move.b	-(a0),d0
	roxl.b	#1,d0
l0016	bcc.b	l001e
	clr.w	d1
	lsl.b	#1,d0
	bne.b	l0017
	move.b	-(a0),d0
	roxl.b	#1,d0
l0017	bcc.b	l001d
	lea	l001c(pc),a3
	moveq	#3,d3
l0018	clr.w	d1
	move.b	0(a3,d3.w),d2
	ext.w	d2
	moveq	#$ff,d4
	lsl.w	d2,d4
	not.w	d4
	subq.w	#1,d2
l0019	lsl.b	#1,d0
	bne.b	l001a
	move.b	-(a0),d0
	roxl.b	#1,d0
l001a	roxl.w	#1,d1
	dbf	d2,l0019
	tst.w	d3
	beq.b	l001b
	cmp.w	d1,d4
	dbne	d3,l0018
l001b	move.b	4(a3,d3.w),d2
	ext.w	d2
	add.w	d2,d1
	bra	l001d
l001c	dc.b	$a,3,2,2,$e,7,4,1
l001d	move.b	-(a0),-(a1)
	nop
	nop
	nop
	dbf	d1,l001d
l001e	movea.l	a4,a3
	addq.l	#8,a3
	cmpa.l	a3,a0
	ble	l0033
	lea	l0025(pc),a3
	moveq	#3,d2
l001f	lsl.b	#1,d0
	bne.b	l0020
	move.b	-(a0),d0
	roxl.b	#1,d0
l0020	bcc.b	l0021
	dbf	d2,l001f
l0021	clr.w	d1
	addq.w	#1,d2
	move.b	0(a3,d2.w),d3
	beq.b	l0024
	ext.w	d3
	subq.w	#1,d3
l0022	lsl.b	#1,d0
	bne.b	l0023
	move.b	-(a0),d0
	roxl.b	#1,d0
l0023	roxl.w	#1,d1
	dbf	d3,l0022
l0024	move.b	5(a3,d2.w),d3
	ext.w	d3
	add.w	d3,d1
	bra	l0026
l0025	dc.b	$a,2,1,0,0,$a,6,4
	dc.b	3,2
l0026	cmpi.w	#2,d1
	beq.b	l002d
	lea	l002c(pc),a3
	moveq	#1,d3
l0027	lsl.b	#1,d0
	bne.b	l0028
	move.b	-(a0),d0
	roxl.b	#1,d0
l0028	bcc.b	l0029
	dbf	d3,l0027
l0029	addq.w	#1,d3
	clr.w	d2
	move.b	0(a3,d3.w),d4
	ext.w	d4
l002a	lsl.b	#1,d0
	bne.b	l002b
	move.b	-(a0),d0
	roxl.b	#1,d0
l002b	roxl.w	#1,d2
	dbf	d4,l002a
	lsl.w	#1,d3
	add.w	4(a3,d3.w),d2
	bra.b	l0031
l002c	dc.b	$b,4,7,0,1,' ',0,0
	dc.b	0,' ',0,0
l002d	clr.w	d2
	moveq	#5,d3
	clr.w	d4
	lsl.b	#1,d0
	bne.b	l002e
	move.b	-(a0),d0
	roxl.b	#1,d0
l002e	bcc.b	l002f
	moveq	#8,d3
	moveq	#$40,d4
l002f	lsl.b	#1,d0
	bne.b	l0030
	move.b	-(a0),d0
	roxl.b	#1,d0
l0030	roxl.w	#1,d2
	dbf	d3,l002f
	add.w	d4,d2
l0031	lea	0(a1,d2.w),a2
	ext.l	d1
	adda.l	d1,a2
	subq.w	#1,d1
l0032	move.b	-(a2),-(a1)
	dbf	d1,l0032
	bra	l0015
l0033	rts

plot8	lea	sline,a0
	move.l	#$a8,d1
	adda.l	d1,a0
	subq.l	#8,a0
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	move.w	(a1),(a0)
	lea	168(a0),a0
	addq.w	#4,a1
	rts

copy1	move.w	height,d0
	mulu	#$a0,d0
	movea.l	d0,a0
	adda.l	$44e.l,a0
	adda.l	#4,a0
	move.w	cop,d6
makit	move.w	0(a1),0(a0)
	move.w	8(a1),8(a0)
	move.w	16(a1),16(a0)
	move.w	24(a1),24(a0)
	move.w	32(a1),32(a0)
	move.w	40(a1),40(a0)
	move.w	48(a1),48(a0)
	move.w	56(a1),56(a0)
	move.w	64(a1),64(a0)
	move.w	72(a1),72(a0)
	move.w	80(a1),80(a0)
	move.w	88(a1),88(a0)
	move.w	96(a1),96(a0)
	move.w	104(a1),104(a0)
	move.w	112(a1),112(a0)
	move.w	120(a1),120(a0)
	move.w	128(a1),128(a0)
	move.w	136(a1),136(a0)
	move.w	144(a1),144(a0)
	move.w	152(a1),152(a0)
	lea	168(a1),a1
	lea	160(a0),a0
	dbf	d6,makit
	rts

scroll	lea	sline,a0
	move.w	#$13,d1
lines	roxl	160(a0)
	roxl	152(a0)
	roxl	144(a0)
	roxl	136(a0)
	roxl	128(a0)
	roxl	120(a0)
	roxl	112(a0)
	roxl	104(a0)
	roxl	96(a0)
	roxl	88(a0)
	roxl	80(a0)
	roxl	72(a0)
	roxl	64(a0)
	roxl	56(a0)
	roxl	48(a0)
	roxl	40(a0)
	roxl	32(a0)
	roxl	24(a0)
	roxl	16(a0)
	roxl	8(a0)
	roxl	(a0)
	roxl	160(a0)
	roxl	152(a0)
	roxl	144(a0)
	roxl	136(a0)
	roxl	128(a0)
	roxl	120(a0)
	roxl	112(a0)
	roxl	104(a0)
	roxl	96(a0)
	roxl	88(a0)
	roxl	80(a0)
	roxl	72(a0)
	roxl	64(a0)
	roxl	56(a0)
	roxl	48(a0)
	roxl	40(a0)
	roxl	32(a0)
	roxl	24(a0)
	roxl	16(a0)
	roxl	8(a0)
	roxl	(a0)
	roxl	160(a0)
	roxl	152(a0)
	roxl	144(a0)
	roxl	136(a0)
	roxl	128(a0)
	roxl	120(a0)
	roxl	112(a0)
	roxl	104(a0)
	roxl	96(a0)
	roxl	88(a0)
	roxl	80(a0)
	roxl	72(a0)
	roxl	64(a0)
	roxl	56(a0)
	roxl	48(a0)
	roxl	40(a0)
	roxl	32(a0)
	roxl	24(a0)
	roxl	16(a0)
	roxl	8(a0)
	roxl	(a0)
	lea	168(a0),a0
	dbf	d1,lines
	rts

hbl_handler	clr.b	$fffa1b.l
	movem.l	a0-a1,-(a7)
	lea	$6823c,a0
	lea	$ff8240.l,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	movem.l	(a7)+,a0-a1
	move.b	#0,$fffa1b.l
	move.l	#hbl_handler2,$120.l
	move.b	#$c7,$fffa21.l
	move.b	#8,$fffa1b.l
	bclr	#0,$fffa0f.l
	rte

hbl_handler2	movem.l	a0-a6/d0-d7,-(a7)
	movem.l	a1-a6/d0-d5,-(a7)
	movem.l	(a7)+,a1-a6/d0-d5
	movem.l	(a7)+,a0-a6/d0-d7
	andi.b	#$fd,$ff820a.l
	move.w	#$1234,crap
	bclr	#0,$fffa0f.l
	ori.b	#2,$ff820a.l
	move.b	#6,$fffa21.l
	movem.l	a0-a1,-(a7)
	lea	parpal,a0
	lea	$ff8240.l,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	movem.l	(a7)+,a0-a1
	move.b	#0,$fffa1b.l
	move.l	#hbl_handler3,$120.l
	move.b	#1,$fffa21.l
	move.b	#8,$fffa1b.l
	rte

hbl_handler3	clr.b	$fffa1b.l
	move.l	a0,-(a7)
	move.w	#$770,$ffff8240.w
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.w	#$77,$ffff8240.w
	movea.l	(a7)+,a0
	move.b	#1,$fffa21.l
	move.b	#8,$fffa1b.l
	bclr	#0,$fffa0f.l
	rte

vbl_handler	move.w	d0,-(a7)
	nbcd	d0
	clr.w	$ffff8240.w
	move.w	#$432,d0
top_out	nop
	dbf	d0,top_out
	clr.b	$ffff820a.w
	nop
	nop
	nop
	move.b	#2,$ffff820a.w
	move.w	(a7)+,d0
	movem.l	a0-a6/d0-d7,-(a7)
	movem.l	logpal,d0-d7
	movem.l	d0-d7,$ff8240.l
	addq.w	#1,frclock
	move.b	#0,$fffa1b.l
	move.l	#hbl_handler,$120.l
	move.b	#$1c,$fffa21.l
	move.b	#8,$fffa1b.l
	movea.l	$44e.l,a1
	adda.l	#$8fc0,a1
	bsr	bloc_on
	bsr	bloc_on
	bsr	bloc_on
	lea	para,a0
	move.w	#$f,d7
parascrl	move.w	(a0),d0
	roxr.w	#1,d0
	roxr	(a0)+
	move.w	(a0),d0
	roxr.w	#1,d0
	roxr	(a0)+
	dbf	d7,parascrl
	jsr	music+14

	movem.l	(a7)+,a0-a6/d0-d7
	rte

bloc_on	lea	para,a0
	move.w	#$f,d7
parait	move.l	(a0)+,d0
	move.l	d0,(a1)
	move.l	d0,8(a1)
	move.l	d0,16(a1)
	move.l	d0,24(a1)
	move.l	d0,32(a1)
	move.l	d0,40(a1)
	move.l	d0,48(a1)
	move.l	d0,56(a1)
	move.l	d0,64(a1)
	move.l	d0,72(a1)
	move.l	d0,80(a1)
	move.l	d0,88(a1)
	move.l	d0,96(a1)
	move.l	d0,104(a1)
	move.l	d0,112(a1)
	move.l	d0,120(a1)
	move.l	d0,128(a1)
	move.l	d0,136(a1)
	move.l	d0,144(a1)
	move.l	d0,152(a1)
	lea	160(a1),a1
	dbf	d7,parait
	rts

parpal	dc.b	0,0,0,7,7,'w',7,0
	dc.b	7,'P',7,'P',7,'P',7,'P'
	dc.b	0,0,0,7,7,'w',7,0
	dc.b	7,'P',7,'P',7,'P',7,'P'
para	dcb.w	2
	dc.b	$7f,$fe,$1f,$f8,$7f,$fa,$1f,$f8
	dc.b	$7f,$fe,$1f,$f8,$7f,$fe,$1f,$f8
	dc.b	$7f,$fe,$1f,$f8,$7f,$fe,$1f,$f8
	dc.b	$7f,$fe,$1f,$f8,$7f,$fe,0,0
	dc.b	$7f,$fe,0,0,'p',$e,$f,$f0
	dc.b	'v',$e,9,$f0,'v',$e,9,$f0
	dc.b	'v',$e,9,$f0,'p',$e,$f,$f0
	dcb.w	2
frclock	dc.b	0,0
old_vbl_vec	dc.b	0,0,0,1
old_hbl_vec	dcb.w	2
old_ieb	dc.b	0
old_iea	dc.b	0
old_ima	dc.b	0,0
old_ssp	dcb.w	2
old_pal	dcb.w	32
old_scr	dcb.w	2
old_rez	dc.b	0,0
crap	dc.b	0,0
logpal	dc.b	0,0,7,'w',7,0,7,$11
	dc.b	7,'"',7,'3',2,'r',7,'D'
	dc.b	0,0,1,$11,2,'"',3,'3'
	dc.b	4,'D',5,'U',6,'f',2,'B'
	dcb.w	3
	dc.b	7,'w',1,$17,2,$27,3,'7'
	dc.b	4,'G',7,'p',5,'W',7,0
	dc.b	6,0,5,0,4,0,3,0
	dc.b	2,0,7,'@',7,'w  '
	dc.b	'      . '
	dc.b	'  ',$80,$1e,0,0,0,0
	dcb.w	33
l004f	dcb.w	180
	dc.b	$10,0,0,0,0,0,0,0
	dc.b	$10,0,0,0,0,0,0,0
	dc.b	0,1,0,0,0,0,0,0
	dcb.w	8
	dc.b	$80,4,0,0,0,0,0,0
	dcb.w	8
	dc.b	$10,0,0,0,0,0,0,0
	dc.b	$10,0,0,0,0,0,0,0
	dcb.w	4
	dc.b	4,0,0,0,0,0,0,0
	dcb.w	28
	dc.b	1,$fd,1,0,1,5,0,5
	dc.b	$f8,'}',0,0,0,'A',0,'A'
	dc.b	$ff,$ff,0,0,4,0,4,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$87,$df,0,0,4,$10,4,$10
	dc.b	7,$ff,0,0,4,0,4,0
	dc.b	$c0,$fe,0,0,0,0,0,0
	dcb.w	4
	dc.b	0,7,0,0,0,4,0,4
	dc.b	$f8,$1f,0,0,0,$10,0,$10
	dc.b	$f8,$1f,0,0,0,0,0,0
	dc.b	$df,0,0,0,$10,0,$10,0
	dc.b	$fe,0,0,0,0,0,0,0
	dcb.w	28
	dc.b	2,9,3,$f0,2,9,0,9
	dc.b	$10,'E',$e0,'8',0,'A',0,'A'
	dc.b	$a,0,$f1,$ff,2,0,2,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	$84,'P',3,$8f,4,$10,4,$10
	dc.b	$84,0,3,$ff,4,0,4,0
	dc.b	'A',4,$80,$f8,0,0,0,0
	dcb.w	4
	dc.b	0,2,0,1,0,2,0,2
	dc.b	$18,' ',$e0,$1f,0,' ',0,' '
	dc.b	$18,' ',$e0,$1f,0,0,0,0
	dc.b	$91,1,$e,0,$90,0,$90,0
	dc.b	4,0,$f8,0,0,0,0,0
	dcb.w	28
	dc.b	4,$11,7,$e0,4,$11,0,$11
	dc.b	$10,'E',$e0,'8',0,'A',0,'A'
	dc.b	5,0,$f8,$ff,1,0,1,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	'DP',$83,$8f,4,$10,4,$10
	dc.b	'D',0,$83,$ff,4,0,4,0
	dc.b	'"',8,$c1,$f0,0,8,0,8
	dcb.w	4
	dc.b	0,1,0,0,0,1,0,1
	dc.b	4,'@',$f8,'?',0,'@',0,'@'
	dc.b	4,'A',$f8,'>',0,1,0,1
	dc.b	$11,2,$e,1,$10,0,$10,0
	dc.b	8,0,$f0,0,8,0,8,0
	dcb.w	28
	dc.b	$f,$e1,$f,$c0,8,'!',0,'!'
	dc.b	$f0,'}',$e0,'8',0,'A',0,'A'
	dc.b	$fe,$ff,$fc,$7f,0,$80,0,$80
	dc.b	$ff,$ff,$ff,$ff,0,0,0,0
	dc.b	$e7,$df,$c3,$8f,4,$10,4,$10
	dc.b	$e7,$ff,$c3,$ff,4,0,4,0
	dc.b	$f7,$f0,$e3,$e0,0,$10,0,$10
	dc.b	0,0,'?',$ff,'?',$ff,'?',$ff
	dc.b	0,0,$ff,$e0,$ff,$e0,$ff,$e0
	dc.b	$fe,$ff,'|',$7f,$80,$80,$80,$80
	dc.b	$fe,$fe,$fc,'|',0,2,0,2
	dc.b	$1f,7,$e,3,$10,0,$10,0
	dc.b	$f0,0,$e0,0,$10,0,$10,0
	dcb.w	28
	dc.b	$1f,$c1,$1f,$80,$10,'A',0,'A'
	dc.b	$f0,'}',$e0,'8',0,'A',0,'A'
	dc.b	$ff,$7f,$fe,0,0,$7f,0,$7f
	dc.b	$ff,$ff,0,3,$ff,$fc,$ff,$fc
	dc.b	$f7,$df,$e0,$f,7,$d0,7,$d0
	dc.b	$f7,$ff,$e3,$83,4,'|',4,'|'
	dc.b	$ff,$e0,$e7,$c0,0,' ',0,' '
	dc.b	0,0,$7f,$ff,$7f,$ff,'@',0
	dc.b	0,0,$ff,$f0,$ff,$f0,0,$10
	dc.b	$7f,$ff,'>|@',$83,'@',$83
	dc.b	$ff,$fc,'|',$f8,$80,4,$80,4
	dc.b	$1f,$f,0,7,$1f,0,$1f,0
	dc.b	$e0,0,$c0,0,' ',0,' ',0
	dcb.w	28
	dc.b	'  ',0,'?',$81,0,$81
	dc.b	$10,'E',0,0,$e0,'y',0,'A'
	dc.b	$10,$80,0,0,$ff,0,$10,0
	dc.b	0,2,0,0,0,3,0,2
	dc.b	8,$11,0,0,$f0,$1f,0,$11
	dc.b	$c,'B',0,0,$f7,$83,4,2
	dc.b	$10,'@',0,0,$ef,$c0,0,'@'
	dc.b	0,0,$ff,$ff,$ff,$ff,$9f,$fb
	dc.b	0,0,$ff,$f8,$ff,$f8,$ff,$f8
	dc.b	' ',$84,0,0,'?| ',4
	dc.b	'B',8,0,0,'}',$f8,'@',8
	dc.b	0,$10,0,0,0,$f,0,0
	dc.b	'@',0,0,0,$c0,0,'@',0
	dcb.w	28
	dc.b	'A',1,'@',0,$7f,1,1,1
	dc.b	$10,'E',0,0,$e0,'y',0,'A'
	dc.b	$18,'@',0,0,$ef,$80,8,0
	dc.b	0,1,0,0,0,1,0,1
	dc.b	7,$d1,0,0,$f8,$1e,0,$10
	dc.b	$84,'A',0,0,$fb,$81,$80,1
	dc.b	' ',$80,0,1,$df,$81,0,$81
	dc.b	0,0,$e0,$e,$e0,$e,' ',$a
	dcb.w	4
	dc.b	$10,'H',0,0,$1f,$b0,$10,0
	dc.b	'$',$10,0,0,';',$f0,' ',$10
	dc.b	$1f,' ',0,0,$10,$1f,$10,0
	dc.b	$80,0,0,0,$80,0,$80,0
	dcb.w	28
	dc.b	$fe,1,$80,0,$fe,1,2,1
	dc.b	$f0,'}',0,0,$e0,'y',0,'A'
	dc.b	$f7,$e0,0,0,$e7,$c0,4,0
	dc.b	0,' ',0,0,0,0,0,0
	dc.b	$ff,$df,0,0,$fd,$9e,$80,$10
	dc.b	$7f,$c1,0,0,'}@',1
	dc.b	$ff,0,0,3,$bf,3,1,2
	dc.b	0,0,$c0,$e,$c0,$e,'@',$a
	dcb.w	4
	dc.b	$f,$f8,0,0,$f,$d0,8,0
	dc.b	'?',$e2,0,0,'7',$e0,'  '
	dc.b	$1f,$7f,0,0,$1e,'?',$10,1
	dcb.w	28
	dc.b	0,1,0,1,0,1,0,0
	dc.b	$fc,$7f,0,0,$fc,'@',4,'@'
	dc.b	$ff,$ff,0,0,0,'x',0,'@'
	dc.b	$ff,$ff,0,0,3,$e0,2,0
	dc.b	$f0,$7f,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,'~',$80,'@',0
	dc.b	$ff,$c1,0,0,'> ',1
	dc.b	$fe,0,0,1,'~',1,2,1
	dc.b	0,0,$e0,$e,$e0,$e,' ',$a
	dcb.w	4
	dc.b	7,$f8,0,0,7,$e0,4,0
	dc.b	'?',$c7,0,0,'/',$c0,' @'
	dc.b	$ff,$fe,0,0,$1e,'~',$10,2
	dcb.w	28
	dc.b	0,3,0,3,0,3,0,0
	dc.b	$f8,$7f,$f0,'?',$f8,$7f,8,'@'
	dc.b	$ff,$ff,$ff,$bb,$ff,$fb,0,'@'
	dc.b	$ff,$ff,$fe,$f7,$ff,$f7,1,0
	dc.b	$f8,$7f,$f0,'?',$f0,$7f,0,'@'
	dc.b	$ff,$ff,$df,'?',$ff,'? ',0
	dc.b	$ff,$c1,$ef,0,$ff,0,$10,0
	dc.b	$fc,0,$f8,0,$fc,0,4,0
	dc.b	0,0,$f0,$f,$f0,$f,$90,$b
	dc.b	0,0,$ff,0,$ff,0,$ff,0
	dc.b	3,$f8,1,$f0,3,$f0,2,0
	dc.b	'?',$87,$1f,3,$1f,$87,0,$84
	dc.b	$ff,$fc,$ee,$f8,$fe,$fc,$10,4
	dcb.w	28
	dc.b	0,4,0,0,0,4,0,7
	dc.b	$10,'@',0,0,$10,'@',$f0,$7f
	dc.b	0,'D',0,0,0,'@',$ff,$fb
	dc.b	0,$84,0,0,0,$80,$ff,$fb
	dc.b	4,'@',0,0,0,'@',$f8,$7f
	dc.b	$10,'@',0,0,$10,'@',$ff,$ff
	dc.b	8,'B',0,0,8,0,$ff,$81
	dc.b	8,0,0,0,0,0,$f0,0
	dc.b	0,0,'x',$f,'x',$f,'H',8
	dc.b	0,0,$ff,0,$ff,0,1,0
	dc.b	1,4,0,0,0,0,0,$f8
	dc.b	'A',4,0,0,0,4,'>',7
	dc.b	$11,8,0,0,$10,0,$fe,$f0
	dcb.w	28
	dc.b	0,2,0,0,0,2,0,3
	dc.b	8,'@',0,0,0,'@',$f0,$7f
	dc.b	0,'D',0,0,0,'@',$ff,$fb
	dc.b	0,'D',0,0,0,'@',$ff,$fb
	dc.b	2,'@',0,0,0,'@',$fc,$7f
	dc.b	' ',$c0,0,0,0,$80,$df,$bf
	dc.b	4,'A',0,0,4,1,$ff,$81
	dc.b	4,0,0,0,0,0,$f8,0
	dc.b	0,0,'<',$f,'<',$f,'$',$b
	dc.b	0,0,$ff,0,$ff,0,$ff,0
	dc.b	2,8,0,0,0,8,1,$f8
	dc.b	' ',$84,0,0,' ',4,'?',7
	dc.b	$11,4,0,0,$10,0,$fe,$f8
	dcb.w	28
	dc.b	0,1,0,0,0,1,0,1
	dc.b	4,'G',0,0,0,'G',$f8,$7f
	dc.b	$ff,$c7,0,0,$ff,$c3,$ff,$fb
	dc.b	$ff,$c7,0,0,$ff,$c3,$ff,$fb
	dc.b	$c1,'G',0,0,$c0,'G',$fe,$7f
	dc.b	$c1,$7f,0,0,$81,'?',$bf,$bf
	dc.b	$fc,'A',0,0,$fc,1,$ff,$81
	dc.b	$82,0,0,0,$80,0,$fc,0
	dc.b	0,0,$1e,$e,$1e,$e,$12,$a
	dcb.w	4
	dc.b	4,$18,0,0,0,$10,3,$f0
	dc.b	'0D',0,0,'0',4,'?',$87
	dc.b	'q',$82,0,0,'p',$80,$fe,$fc
	dcb.w	32
	dc.b	$fe,'}',0,0,$80,'A',$fc,'y'
	dc.b	$f0,'}',0,0,0,'A',$e0,'y'
	dc.b	$f0,'|',0,0,0,'@',$e0,'x'
	dc.b	'?|',0,0,' @>x'
	dc.b	$ff,$df,0,0,2,$10,$7f,$9e
	dc.b	7,$c1,0,0,4,1,7,$81
	dc.b	$ff,0,0,0,'@',0,$fe,0
	dc.b	0,0,$f,$e,$f,$e,9,$a
	dcb.w	4
	dc.b	$f,$f8,0,0,0,' ',7,$f0
	dc.b	'?',$e7,0,0,'(',4,'?',$c7
	dc.b	$df,$7f,0,0,$10,'@ž~'
	dcb.w	32
	dc.b	$7f,'}',0,0,'@A~y'
	dc.b	$f0,'}',0,0,0,'A',$e0,'y'
	dc.b	$f0,'|',0,0,0,'@',$e0,'x'
	dc.b	$1f,'}',0,0,$10,'@',$1e,'x'
	dc.b	$ff,$df,0,0,4,$10,$ff,$9e
	dc.b	7,$c1,0,0,4,1,7,$81
	dc.b	$ff,$80,0,0,' ',0,$ff,0
	dc.b	0,0,7,$8e,7,$8e,4,$8a
	dcb.w	4
	dc.b	$1f,$f8,0,0,0,'@',$f,$f0
	dc.b	'?',$f7,0,0,'$',4,'?',$e7
	dc.b	$df,'?',0,0,$10,' ž?'
	dc.b	$80,0,0,0,0,0,0,0
	dcb.w	28
	dc.b	' ',$c5,$1f,'8 A?y'
	dc.b	$10,'E',$e0,'8',0,'A',$e0,'y'
	dc.b	$10,'D',$e0,'8',0,'@',$e0,'x'
	dc.b	$11,'F',$e,'9',$10,'@',$1e,'y'
	dc.b	$c,'Q',$f3,$8e,$c,$10,$ff,$9e
	dc.b	4,'A',3,$80,4,1,7,$81
	dc.b	$10,'@',$ef,$80,$10,0,$ff,$80
	dc.b	0,0,3,$ce,3,$ce,2,'J'
	dcb.w	4
	dc.b	' ',$84,$1f,'x',0,$80,$1f,$f8
	dc.b	'B',$c,'=',$f3,'B',4,$7f,$f7
	dc.b	'Q',$10,$8e,$f,$10,$10,$9e,$1f
	dc.b	'@',0,$80,0,0,0,$80,0
	dcb.w	28
	dc.b	$10,'E',$f,$b8,$10,1,$1f,$b9
	dc.b	$1f,$c5,$e0,'8',0,'A',$e0,'y'
	dc.b	$10,'D',$e0,'8',0,'@',$e0,'x'
	dc.b	$11,'D',$e,';',$10,'@',$1e,'{'
	dc.b	$14,'Q',$e3,$8e,$14,$10,$f7,$9e
	dc.b	4,'A',3,$80,4,1,7,$81
	dc.b	$18,' ',$e7,$c0,8,0,$ef,$c0
	dc.b	0,0,1,$ee,1,$ee,1,'*'
	dcb.w	4
	dc.b	'A',$83,'>|',1,$80,'?',$fc
	dc.b	$83,4,'|',$fb,1,0,'}',$fb
	dc.b	'Q',8,$8e,7,$10,8,$9e,$f
	dc.b	' ',0,$c0,0,0,0,$c0,0
	dcb.w	28
	dc.b	$f,$fd,7,$d8,8,1,$f,$d9
	dc.b	$ff,$fd,$ff,$f8,0,1,$ff,$f9
	dc.b	$f0,'|',$e0,'8',0,'@',$e0,'x'
	dc.b	$1f,$7f,$e,'7',$10,'@',$1e,'w'
	dc.b	$e7,$df,$c3,'Ž$',$10,$e7,$9e
	dc.b	7,$c1,3,$80,4,1,7,$81
	dc.b	$f7,$f0,$e3,$e0,4,0,$e7,$e0
	dc.b	0,0,0,$fe,0,$fe,0,$9a
	dcb.w	4
	dc.b	$fe,$ff,'|',$7f,2,$80,'~',$ff
	dc.b	$fe,$ff,$fc,'}',0,$80,$fc,$fd
	dc.b	$df,7,$8e,3,$10,4,$9e,7
	dc.b	$f0,0,$e0,0,0,0,$e0,0
	dcb.w	28
	dc.b	7,$fd,3,$e8,4,1,7,$e9
	dc.b	$ff,$fd,$ff,$f8,0,1,$ff,$f9
	dc.b	$f0,'|',$e0,'8',0,'@',$e0,'x'
	dc.b	$1f,$7f,$e,'/',$10,'@',$1e,'o'
	dc.b	$c7,$df,$83,'ŽD',$10,$c7,$9e
	dc.b	7,$c1,3,$80,4,1,7,$81
	dc.b	$f3,$f8,$e1,$f0,2,0,$e3,$f0
	dc.b	0,0,0,'~',0,'~',0,'J'
	dc.b	0,1,0,0,0,0,0,0
	dc.b	$fc,$7f,$f8,'?',4,'@',$fc,$7f
	dc.b	$fc,$7f,$f8,'>',4,'@',$fc,'~'
	dc.b	$df,3,$8e,1,$10,2,$9e,3
	dc.b	$f8,0,$f0,0,0,0,$f0,0
	dcb.w	28
	dc.b	2,$d,0,0,3,$f1,3,$f1
	dc.b	0,5,0,0,$ff,$f9,$ff,$f9
	dc.b	$10,'D',0,0,$e0,'x',$e0,'x'
	dc.b	$11,'`',0,0,$1e,'_',$1e,'_'
	dc.b	'„Q',0,0,$87,$9e,$87,$9e
	dc.b	4,'A',0,0,7,$81,7,$81
	dc.b	$11,4,0,0,$e1,$f8,$e1,$f8
	dc.b	0,0,0,'>',0,'>',0,'"'
	dc.b	0,2,0,0,0,1,0,1
	dc.b	8,' ',0,0,$f8,'?',$f8,'?'
	dc.b	8,' ',0,0,$f8,'?',$f8,'?'
	dc.b	$d1,1,0,0,$1e,1,$1e,1
	dc.b	4,0,0,0,$f8,0,$f8,0
	dcb.w	28
	dc.b	1,$fd,0,0,1,$fd,1,$fd
	dc.b	$ff,$fd,0,0,$ff,$f9,$ff,$f9
	dc.b	$f0,'|',0,0,$f0,'|',$f0,'|'
	dc.b	$1f,$7f,0,0,$1f,$7f,$1f,$7f
	dc.b	7,$df,0,0,7,$df,7,$df
	dc.b	7,$c1,0,0,7,$c1,7,$c1
	dc.b	$f0,$82,0,0,$f0,$fc,$f0,$fc
	dc.b	0,0,0,$1e,0,$1e,0,$12
	dc.b	0,4,0,0,0,3,0,3
	dc.b	$10,$1f,0,0,$f0,$1f,$f0,$1f
	dc.b	$f0,$1f,0,0,$f0,$1f,$f0,$1f
	dc.b	$df,0,0,0,$df,0,$df,0
	dc.b	$fe,0,0,0,$fe,0,$fe,0
	dcb.w	52
	dc.b	0,'A',0,0,0,'~',0,'~'
	dc.b	0,0,0,$e,0,$e,0,$a
	dc.b	0,8,0,0,0,7,0,7
	dc.b	' ',0,0,0,$e0,0,$e0,0
	dcb.w	40
	dc.b	0,$7f,0,$7f,0,0,0,$7f
	dc.b	$ff,$ff,$ff,$ff,0,0,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,0,0,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,0,0,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,0,0,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,0,0,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,0,0,$ff,$ff
	dc.b	$80,0,0,6,0,6,0,6
	dc.b	0,$1f,0,$f,0,0,0,$f
	dc.b	$ff,$ff,$ff,$ff,0,0,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,0,0,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,0,0,$ff,$ff
	dc.b	$ff,$80,$ff,$80,0,0,$ff,$80
	dcb.w	29
	dc.b	0,'?',0,0,0,'?',0,0
	dc.b	$ff,$ff,0,0,$ff,$ff,0,0
	dc.b	$ff,$ff,0,0,$ff,$ff,0,0
	dc.b	$ff,$ff,0,0,$ff,$ff,0,0
	dc.b	$ff,$ff,0,0,$ff,$ff,0,0
	dc.b	$ff,$ff,0,0,$ff,$ff,0,0
	dc.b	$ff,$ff,0,0,$ff,$ff,'@',0
	dc.b	$80,0,0,0,$80,0,0,' '
	dc.b	0,$1f,0,0,0,$1f,0,0
	dc.b	$ff,$ff,0,0,$ff,$ff,0,0
	dc.b	$ff,$ff,0,0,$ff,$ff,0,0
	dc.b	$ff,$ff,0,0,$ff,$ff,0,0
	dc.b	$ff,$c0,0,0,$ff,$c0,0,0
	dcb.w	27
	dc.b	0,$1f,0,0,0,0,0,$1f
	dc.b	$ff,$ff,0,0,0,0,$ff,$ff
	dc.b	$ff,$ff,0,0,0,0,$ff,$ff
	dc.b	$ff,$ff,0,0,0,0,$ff,$ff
	dc.b	$ff,$ff,0,0,0,0,$ff,$ff
	dc.b	$ff,$ff,0,0,0,0,$ff,$ff
	dc.b	$ff,$ff,0,0,0,0,$ff,$ff
	dc.b	$e0,0,0,0,0,0,$c0,0
	dc.b	0,$7f,0,0,0,0,0,'?'
	dc.b	$ff,$ff,0,0,0,0,$ff,$ff
	dc.b	$ff,$ff,0,0,0,0,$ff,$ff
	dc.b	$ff,$ff,0,0,0,0,$ff,$ff
	dc.b	$ff,$e0,0,0,0,0,$ff,$e0
	dcb.w	31
	dc.b	0,$f,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,$10,0,0,0,0,0
	dc.b	$e0,0,0,$80,0,0,0,0
	dc.b	0,$7f,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$f0,0,0,0,0,0,0
	dcb.w	173
	dc.b	0,$f,0,$f,0,$f,0,$f
	dc.b	$ef,$83,$ef,$83,$ef,$83,$ef,$83
	dc.b	$ef,$bf,$ef,$bf,$ef,$bf,$ef,$bf
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$f8,'>',$f8,'>',$f8,'>',$f8,'>'
	dc.b	$f8,'?',$f8,'?',$f8,'?',$f8,'?'
	dc.b	$fc,7,$fc,7,$fc,7,$fc,7
	dc.b	$f0,0,$f0,0,$f0,0,$f0,0
	dcb.w	8
	dc.b	7,$f7,7,$f7,7,$f7,7,$f7
	dc.b	$c1,$f7,$c1,$f7,$c1,$f7,$c1,$f7
	dc.b	$df,$ff,$df,$ff,$df,$ff,$df,$ff
	dc.b	$ff,$fc,$ff,$fc,$ff,$fc,$ff,$fc
	dc.b	$1f,'|',$1f,'|',$1f,'|',$1f,'|'
	dc.b	$1f,$fe,$1f,$fe,$1f,$fe,$1f,$fe
	dc.b	3,$f8,3,$f8,3,$f8,3,$f8
	dcb.w	12
	dc.b	0,$10,0,$10,0,$10,0,$10
	dc.b	'H',$82,'H',$82,'H',$82,'H',$82
	dc.b	'(P(P(P(P'
	dcb.w	4
	dc.b	4,'"',4,'"',4,'"',4,'"'
	dc.b	'„ „ „ „ '
	dc.b	2,8,2,8,2,8,2,8
	dc.b	' ',0,' ',0,' ',0,' ',0
	dcb.w	8
	dc.b	8,'$',8,'$',8,'$',8,'$'
	dc.b	'A',$14,'A',$14,'A',$14,'A',$14
	dc.b	'(',0,'(',0,'(',0,'(',0
	dc.b	0,2,0,2,0,2,0,2
	dc.b	$11,'B',$11,'B',$11,'B',$11,'B'
	dc.b	$10,1,$10,1,$10,1,$10,1
	dc.b	4,$10,4,$10,4,$10,4,$10
	dcb.w	12
	dc.b	0,' ',0,' ',0,' ',0,' '
	dc.b	$88,$82,$88,$82,$88,$82,$88,$82
	dc.b	'(((((((('
	dcb.w	4
	dc.b	2,'"',2,'"',2,'"',2,'"'
	dc.b	$82,' ',$82,' ',$82,' ',$82,' '
	dc.b	1,$10,1,$10,1,$10,1,$10
	dc.b	'@',0,'@',0,'@',0,'@',0
	dcb.w	8
	dc.b	$10,'D',$10,'D',$10,'D',$10,'D'
	dc.b	'A',$14,'A',$14,'A',$14,'A',$14
	dc.b	$14,0,$14,0,$14,0,$14,0
	dc.b	0,1,0,1,0,1,0,1
	dc.b	$11,'A',$11,'A',$11,'A',$11,'A'
	dc.b	$10,0,$10,0,$10,0,$10,0
	dc.b	$88,' ',$88,' ',$88,' ',$88,' '
	dcb.w	12
	dc.b	0,'A',0,'A',0,'A',0,'A'
	dc.b	8,$82,8,$82,8,$82,8,$82
	dc.b	'(',$14,'(',$14,'(',$14,'(',$14
	dcb.w	4
	dc.b	1,'"',1,'"',1,'"',1,'"'
	dc.b	'    '
	dc.b	0,$a0,0,$a0,0,$a0,0,$a0
	dc.b	$80,0,$80,0,$80,0,$80,0
	dcb.w	8
	dc.b	' „ „ „ „'
	dc.b	'A',$14,'A',$14,'A',$14,'A',$14
	dc.b	$a,0,$a,0,$a,0,$a,0
	dcb.w	4
	dc.b	$91,'@',$91,'@',$91,'@',$91,'@'
	dc.b	$90,0,$90,0,$90,0,$90,0
	dc.b	'P@P@P@P@'
	dcb.w	12
	dc.b	0,$82,0,$82,0,$82,0,$82
	dc.b	8,$82,8,$82,8,$82,8,$82
	dc.b	'(',$b,'(',$b,'(',$b,'(',$b
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$e0,$be,$e0,$be,$e0,$be,$e0,$be
	dc.b	$80,$a3,$80,$a3,$80,$a3,$80,$a3
	dc.b	$e0,$c1,$e0,$c1,$e0,$c1,$e0,$c1
	dcb.w	12
	dc.b	'A',4,'A',4,'A',4,'A',4
	dc.b	'A',$14,'A',$14,'A',$14,'A',$14
	dc.b	5,$ff,5,$ff,5,$ff,5,$ff
	dc.b	$ff,$f0,$ff,$f0,$ff,$f0,$ff,$f0
	dc.b	'_@_@_@_@'
	dc.b	'Q',$f0,'Q',$f0,'Q',$f0,'Q',$f0
	dc.b	'`',$80,'`',$80,'`',$80,'`',$80
	dcb.w	12
	dc.b	1,4,1,4,1,4,1,4
	dc.b	8,$82,8,$82,8,$82,8,$82
	dc.b	'(„(„(„(',$84
	dcb.w	4
	dc.b	$10,'@',$10,'@',$10,'@',$10,'@'
	dc.b	$88,'b',$88,'b',$88,'b',$88,'b'
	dc.b	$10,$82,$10,$82,$10,$82,$10,$82
	dcb.w	12
	dc.b	$82,4,$82,4,$82,4,$82,4
	dc.b	'A',$14,'A',$14,'A',$14,'A',$14
	dc.b	'B',0,'B',0,'B',0,'B',0
	dc.b	0,8,0,8,0,8,0,8
	dc.b	' D D D D'
	dc.b	'1',8,'1',8,'1',8,'1',8
	dc.b	'A',0,'A',0,'A',0,'A',0
	dcb.w	12
	dc.b	2,8,2,8,2,8,2,8
	dc.b	8,$82,8,$82,8,$82,8,$82
	dc.b	'(',$c2,'(',$c2,'(',$c2,'(',$c2
	dcb.w	4
	dc.b	8,'>',8,'>',8,'>',8,'>'
	dc.b	$8c,'"',$8c,'"',$8c,'"',$8c,'"'
	dc.b	9,4,9,4,9,4,9,4
	dcb.w	8
	dc.b	0,1,0,1,0,1,0,1
	dc.b	4,4,4,4,4,4,4,4
	dc.b	'A',$14,'A',$14,'A',$14,'A',$14
	dc.b	'a',0,'a',0,'a',0,'a',0
	dc.b	0,4,0,4,0,4,0,4
	dc.b	$1f,'F',$1f,'F',$1f,'F',$1f,'F'
	dc.b	$11,4,$11,4,$11,4,$11,4
	dc.b	$82,0,$82,0,$82,0,$82,0
	dcb.w	12
	dc.b	4,$10,4,$10,4,$10,4,$10
	dc.b	8,$82,8,$82,8,$82,8,$82
	dc.b	'(',$a1,'(',$a1,'(',$a1,'(',$a1
	dcb.w	4
	dc.b	4,$12,4,$12,4,$12,4,$12
	dc.b	$8a,$12,$8a,$12,$8a,$12,$8a,$12
	dc.b	$a,8,$a,8,$a,8,$a,8
	dcb.w	8
	dc.b	0,2,0,2,0,2,0,2
	dc.b	8,4,8,4,8,4,8,4
	dc.b	'A',$14,'A',$14,'A',$14,'A',$14
	dc.b	'P',$80,'P',$80,'P',$80,'P',$80
	dc.b	0,2,0,2,0,2,0,2
	dc.b	9,'E',9,'E',9,'E',9,'E'
	dc.b	9,5,9,5,9,5,9,5
	dc.b	4,0,4,0,4,0,4,0
	dcb.w	12
	dc.b	8,'#',8,'#',8,'#',8,'#'
	dc.b	$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe
	dc.b	'?',$f0,'?',$f0,'?',$f0,'?',$f0
	dc.b	$ff,$83,$ff,$83,$ff,$83,$ff,$83
	dc.b	$fe,$b,$fe,$b,$fe,$b,$fe,$b
	dc.b	$ff,$a,$ff,$a,$ff,$a,$ff,$a
	dc.b	$c,$10,$c,$10,$c,$10,$c,$10
	dcb.w	8
	dc.b	0,4,0,4,0,4,0,4
	dc.b	$11,$ff,$11,$ff,$11,$ff,$11,$ff
	dc.b	$ff,$1f,$ff,$1f,$ff,$1f,$ff,$1f
	dc.b	$f8,$7f,$f8,$7f,$f8,$7f,$f8,$7f
	dc.b	$c1,$ff,$c1,$ff,$c1,$ff,$c1,$ff
	dc.b	5,$ff,5,$ff,5,$ff,5,$ff
	dc.b	$85,6,$85,6,$85,6,$85,6
	dc.b	8,0,8,0,8,0,8,0
	dcb.w	12
	dc.b	$10,'B',$10,'B',$10,'B',$10,'B'
	dc.b	0,2,0,2,0,2,0,2
	dc.b	' ',8,' ',8,' ',8,' ',8
	dc.b	'@B@B@B@B'
	dc.b	1,6,1,6,1,6,1,6
	dc.b	0,$86,0,$86,0,$86,0,$86
	dc.b	8,' ',8,' ',8,' ',8,' '
	dcb.w	8
	dc.b	0,8,0,8,0,8,0,8
	dc.b	'!',0,'!',0,'!',0,'!',0
	dc.b	1,$10,1,$10,1,$10,1,$10
	dc.b	4,' ',4,' ',4,' ',4,' '
	dc.b	'!',0,'!',0,'!',0,'!',0
	dc.b	$83,0,$83,0,$83,0,$83,0
	dc.b	'C',4,'C',4,'C',4,'C',4
	dc.b	$10,0,$10,0,$10,0,$10,0
	dcb.w	12
	dc.b	' ',$82,' ',$82,' ',$82,' ',$82
	dc.b	0,2,0,2,0,2,0,2
	dc.b	' ',4,' ',4,' ',4,' ',4
	dc.b	' " " " "'
	dc.b	0,$82,0,$82,0,$82,0,$82
	dc.b	0,'B',0,'B',0,'B',0,'B'
	dc.b	$10,'@',$10,'@',$10,'@',$10,'@'
	dcb.w	8
	dc.b	0,$10,0,$10,0,$10,0,$10
	dc.b	'A',0,'A',0,'A',0,'A',0
	dc.b	1,$10,1,$10,1,$10,1,$10
	dc.b	2,$10,2,$10,2,$10,2,$10
	dc.b	$11,0,$11,0,$11,0,$11,0
	dc.b	'A',0,'A',0,'A',0,'A',0
	dc.b	'!',8,'!',8,'!',8,'!',8
	dc.b	' ',0,' ',0,' ',0,' ',0
	dcb.w	12
	dc.b	$10,'B',$10,'B',$10,'B',$10,'B'
	dc.b	0,2,0,2,0,2,0,2
	dc.b	' ',2,' ',2,' ',2,' ',2
	dc.b	' ',$12,' ',$12,' ',$12,' ',$12
	dc.b	1,6,1,6,1,6,1,6
	dc.b	0,'"',0,'"',0,'"',0,'"'
	dc.b	8,' ',8,' ',8,' ',8,' '
	dcb.w	8
	dc.b	0,8,0,8,0,8,0,8
	dc.b	'!',0,'!',0,'!',0,'!',0
	dc.b	1,$10,1,$10,1,$10,1,$10
	dc.b	1,$10,1,$10,1,$10,1,$10
	dc.b	9,0,9,0,9,0,9,0
	dc.b	$83,0,$83,0,$83,0,$83,0
	dc.b	$11,4,$11,4,$11,4,$11,4
	dc.b	$10,0,$10,0,$10,0,$10,0
	dcb.w	12
	dc.b	8,'"',8,'"',8,'"',8,'"'
	dc.b	'?',$fe,'?',$fe,'?',$fe,'?',$fe
	dc.b	'?',$fe,'?',$fe,'?',$fe,'?',$fe
	dc.b	'>',$a,'>',$a,'>',$a,'>',$a
	dc.b	'>',$b,'>',$b,'>',$b,'>',$b
	dc.b	$ff,$e2,$ff,$e2,$ff,$e2,$ff,$e2
	dc.b	$c,$10,$c,$10,$c,$10,$c,$10
	dcb.w	8
	dc.b	0,4,0,4,0,4,0,4
	dc.b	$11,$1f,$11,$1f,$11,$1f,$11,$1f
	dc.b	$ff,$1f,$ff,$1f,$ff,$1f,$ff,$1f
	dc.b	$ff,$1f,$ff,$1f,$ff,$1f,$ff,$1f
	dc.b	5,$1f,5,$1f,5,$1f,5,$1f
	dc.b	5,$ff,5,$ff,5,$ff,5,$ff
	dc.b	$f1,6,$f1,6,$f1,6,$f1,6
	dc.b	8,0,8,0,8,0,8,0
	dcb.w	12
	dc.b	4,$12,4,$12,4,$12,4,$12
	dc.b	'(',$82,'(',$82,'(',$82,'(',$82
	dc.b	'(',$82,'(',$82,'(',$82,'(',$82
	dc.b	'!',$a,'!',$a,'!',$a,'!',$a
	dc.b	'$',$12,'$',$12,'$',$12,'$',$12
	dc.b	$88,'"',$88,'"',$88,'"',$88,'"'
	dc.b	$a,8,$a,8,$a,8,$a,8
	dcb.w	8
	dc.b	0,2,0,2,0,2,0,2
	dc.b	9,$14,9,$14,9,$14,9,$14
	dc.b	'A',$14,'A',$14,'A',$14,'A',$14
	dc.b	'A',$10,'A',$10,'A',$10,'A',$10
	dc.b	$85,$12,$85,$12,$85,$12,$85,$12
	dc.b	9,'D',9,'D',9,'D',9,'D'
	dc.b	$11,5,$11,5,$11,5,$11,5
	dc.b	4,0,4,0,4,0,4,0
	dcb.w	12
	dc.b	2,$a,2,$a,2,$a,2,$a
	dc.b	'(',$82,'(',$82,'(',$82,'(',$82
	dc.b	'(',$82,'(',$82,'(',$82,'(',$82
	dc.b	' ',$8a,' ',$8a,' ',$8a,' ',$8a
	dc.b	'("("("("'
	dc.b	$88,'"',$88,'"',$88,'"',$88,'"'
	dc.b	9,4,9,4,9,4,9,4
	dcb.w	8
	dc.b	0,1,0,1,0,1,0,1
	dc.b	5,$14,5,$14,5,$14,5,$14
	dc.b	'A',$14,'A',$14,'A',$14,'A',$14
	dc.b	'A',$10,'A',$10,'A',$10,'A',$10
	dc.b	'E',$14,'E',$14,'E',$14,'E',$14
	dc.b	$11,'D',$11,'D',$11,'D',$11,'D'
	dc.b	$11,4,$11,4,$11,4,$11,4
	dc.b	$82,0,$82,0,$82,0,$82,0
	dcb.w	12
	dc.b	1,6,1,6,1,6,1,6
	dc.b	'(',$82,'(',$82,'(',$82,'(',$82
	dc.b	'(',$82,'(',$82,'(',$82,'(',$82
	dc.b	' ',$8a,' ',$8a,' ',$8a,' ',$8a
	dc.b	'0b0b0b0b'
	dc.b	$88,'"',$88,'"',$88,'"',$88,'"'
	dc.b	8,$82,8,$82,8,$82,8,$82
	dcb.w	12
	dc.b	$83,$14,$83,$14,$83,$14,$83,$14
	dc.b	'A',$14,'A',$14,'A',$14,'A',$14
	dc.b	'A',$10,'A',$10,'A',$10,'A',$10
	dc.b	'E',$18,'E',$18,'E',$18,'E',$18
	dc.b	'1D1D1D1D'
	dc.b	$11,4,$11,4,$11,4,$11,4
	dc.b	'A',0,'A',0,'A',0,'A',0
	dcb.w	12
	dc.b	0,$82,0,$82,0,$82,0,$82
	dc.b	'(',$fe,'(',$fe,'(',$fe,'(',$fe
	dc.b	'(',$82,'(',$82,'(',$82,'(',$82
	dc.b	' ',$8a,' ',$8a,' ',$8a,' ',$8a
	dc.b	' ',$a2,' ',$a2,' ',$a2,' ',$a2
	dc.b	$88,'"',$88,'"',$88,'"',$88,'"'
	dc.b	8,$c1,8,$c1,8,$c1,8,$c1
	dcb.w	12
	dc.b	'A',$14,'A',$14,'A',$14,'A',$14
	dc.b	$7f,$14,$7f,$14,$7f,$14,$7f,$14
	dc.b	'A',$10,'A',$10,'A',$10,'A',$10
	dc.b	'E',$10,'E',$10,'E',$10,'E',$10
	dc.b	'QDQDQDQD'
	dc.b	$11,4,$11,4,$11,4,$11,4
	dc.b	'`',$80,'`',$80,'`',$80,'`',$80
	dcb.w	12
	dc.b	0,'A',0,'A',0,'A',0,'A'
	dc.b	'(',0,'(',0,'(',0,'(',0
	dc.b	'(',$82,'(',$82,'(',$82,'(',$82
	dc.b	' ',$8a,' ',$8a,' ',$8a,' ',$8a
	dc.b	'A"A"A"A"'
	dc.b	$88,'"',$88,'"',$88,'"',$88,'"'
	dc.b	8,$a0,8,$a0,8,$a0,8,$a0
	dc.b	$80,0,$80,0,$80,0,$80,0
	dcb.w	8
	dc.b	' ” ” ” ',$94
	dc.b	0,$14,0,$14,0,$14,0,$14
	dc.b	'A',$10,'A',$10,'A',$10,'A',$10
	dc.b	'E E E E '
	dc.b	$91,'D',$91,'D',$91,'D',$91,'D'
	dc.b	$11,4,$11,4,$11,4,$11,4
	dc.b	'P@P@P@P@'
	dcb.w	12
	dc.b	0,' ',0,' ',0,' ',0,' '
	dc.b	$a8,0,$a8,0,$a8,0,$a8,0
	dc.b	'(',$82,'(',$82,'(',$82,'(',$82
	dc.b	' ',$8a,' ',$8a,' ',$8a,' ',$8a
	dc.b	$82,'"',$82,'"',$82,'"',$82,'"'
	dc.b	$88,'"',$88,'"',$88,'"',$88,'"'
	dc.b	8,$90,8,$90,8,$90,8,$90
	dc.b	'@',0,'@',0,'@',0,'@',0
	dcb.w	8
	dc.b	$10,'T',$10,'T',$10,'T',$10,'T'
	dc.b	0,$14,0,$14,0,$14,0,$14
	dc.b	'A',$10,'A',$10,'A',$10,'A',$10
	dc.b	'EAEAEAEA'
	dc.b	$11,'D',$11,'D',$11,'D',$11,'D'
	dc.b	$11,4,$11,4,$11,4,$11,4
	dc.b	'H H H H '
	dcb.w	12
	dc.b	0,$10,0,$10,0,$10,0,$10
	dc.b	'h',0,'h',0,'h',0,'h',0
	dc.b	'(',$82,'(',$82,'(',$82,'(',$82
	dc.b	' ',$8b,' ',$8b,' ',$8b,' ',$8b
	dc.b	4,'"',4,'"',4,'"',4,'"'
	dc.b	$88,'"',$88,'"',$88,'"',$88,'"'
	dc.b	8,$88,8,$88,8,$88,8,$88
	dc.b	' ',0,' ',0,' ',0,' ',0
	dcb.w	8
	dc.b	8,'4',8,'4',8,'4',8,'4'
	dc.b	0,$14,0,$14,0,$14,0,$14
	dc.b	'A',$10,'A',$10,'A',$10,'A',$10
	dc.b	'E',$82,'E',$82,'E',$82,'E',$82
	dc.b	$11,'D',$11,'D',$11,'D',$11,'D'
	dc.b	$11,4,$11,4,$11,4,$11,4
	dc.b	'D',$10,'D',$10,'D',$10,'D',$10
	dcb.w	12
	dc.b	0,$f,0,$f,0,$f,0,$f
	dc.b	$ef,$ff,$ef,$ff,$ef,$ff,$ef,$ff
	dc.b	$ef,$83,$ef,$83,$ef,$83,$ef,$83
	dc.b	$e0,$fb,$e0,$fb,$e0,$fb,$e0,$fb
	dc.b	$f8,'>',$f8,'>',$f8,'>',$f8,'>'
	dc.b	$f8,'>',$f8,'>',$f8,'>',$f8,'>'
	dc.b	$f,$84,$f,$84,$f,$84,$f,$84
	dc.b	$10,0,$10,0,$10,0,$10,0
	dcb.w	8
	dc.b	7,$f7,7,$f7,7,$f7,7,$f7
	dc.b	$ff,$f7,$ff,$f7,$ff,$f7,$ff,$f7
	dc.b	$c1,$f0,$c1,$f0,$c1,$f0,$c1,$f0
	dc.b	'}',$fc,'}',$fc,'}',$fc,'}',$fc
	dc.b	$1f,'|',$1f,'|',$1f,'|',$1f,'|'
	dc.b	$1f,7,$1f,7,$1f,7,$1f,7
	dc.b	$c2,8,$c2,8,$c2,8,$c2,8
	dcb.w	36
	dc.b	0,2,0,2,0,2,0,2
	dc.b	8,0,8,0,8,0,8,0
	dcb.w	32
	dc.b	1,4,1,4,1,4,1,4
	dcb.w	12
	dc.b	0,3,0,3,0,3,0,3
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	4,0,4,0,4,0,4,0
	dcb.w	8
	dc.b	1,$ff,1,$ff,1,$ff,1,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$82,$ff,$82,$ff,$82,$ff,$82
	dcb.w	12
	dc.b	0,1,0,1,0,1,0,1
	dcb.w	24
	dc.b	2,0,2,0,2,0,2,0
	dcb.w	8
	dc.b	0,$80,0,$80,0,$80,0,$80
	dcb.w	20
	dc.b	0,1,0,1,0,1,0,1
	dcb.w	16
	dc.b	$80,0,$80,0,$80,0,$80,0
	dcb.w	20
	dc.b	1,0,1,0,1,0,1,0
	dcb.w	8
	dc.b	0,'@',0,'@',0,'@',0,'@'
	dcb.w	24
	dc.b	$80,0,$80,0,$80,0,$80,0
	dcb.w	12
	dc.b	$7f,$ff,$7f,$ff,$7f,$ff,$7f,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$80,$ff,$80,$ff,$80,$ff,$80
	dcb.w	8
	dc.b	0,'?',0,'?',0,'?',0,'?'
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$c0,0,$c0,0,$c0,0,$c0,0
	dcb.w	92
	dc.b	$1f,$ff,$1f,$ff,$1f,$ff,$1f,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$f3,$ff,$f3,$ff,$f3,$ff,$f3
	dc.b	$f8,$f,$f8,$f,$f8,$f,$f8,$f
	dc.b	$f8,$f,$f8,$f,$f8,$f,$f8,$f
	dc.b	$ef,$80,$ef,$80,$ef,$80,$ef,$80
	dc.b	$7f,0,$7f,0,$7f,0,$7f,0
	dcb.w	16
	dc.b	0,$f,0,$f,0,$f,0,$f
	dc.b	$e0,'?',$e0,'?',$e0,'?',$e0,'?'
	dc.b	$e0,'?',$e0,'?',$e0,'?',$e0,'?'
	dc.b	$be,1,$be,1,$be,1,$be,1
	dc.b	$fc,0,$fc,0,$fc,0,$fc,0
	dcb.w	16
	dc.b	8,0,8,0,8,0,8,0
	dcb.w	4
	dc.b	0,9,0,9,0,9,0,9
	dc.b	4,$10,4,$10,4,$10,4,$10
	dc.b	4,$10,4,$10,4,$10,4,$10
	dc.b	'H',$80,'H',$80,'H',$80,'H',$80
	dc.b	$82,0,$82,0,$82,0,$82,0
	dcb.w	16
	dc.b	0,4,0,4,0,4,0,4
	dc.b	$10,'@',$10,'@',$10,'@',$10,'@'
	dc.b	$10,'A',$10,'A',$10,'A',$10,'A'
	dc.b	'"',2,'"',2,'"',2,'"',2
	dc.b	8,0,8,0,8,0,8,0
	dcb.w	16
	dc.b	4,0,4,0,4,0,4,0
	dcb.w	4
	dc.b	0,4,0,4,0,4,0,4
	dc.b	$82,' ',$82,' ',$82,' ',$82,' '
	dc.b	2,' ',2,' ',2,' ',2,' '
	dc.b	$88,$81,$88,$81,$88,$81,$88,$81
	dc.b	4,0,4,0,4,0,4,0
	dcb.w	12
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$82,0,2,0,2,0,2
	dc.b	8,$80,8,$80,8,$80,8,$80
	dc.b	8,$82,8,$82,8,$82,8,$82
	dc.b	'"',4,'"',4,'"',4,'"',4
	dc.b	$10,0,$10,0,$10,0,$10,0
	dcb.w	16
	dc.b	2,0,2,0,2,0,2,0
	dcb.w	4
	dc.b	0,2,0,2,0,2,0,2
	dc.b	'A@A@A@A@'
	dc.b	1,'A',1,'A',1,'A',1,'A'
	dc.b	8,$82,8,$82,8,$82,8,$82
	dc.b	8,0,8,0,8,0,8,0
	dcb.w	8
	dc.b	0,1,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$c1,0,1,0,1,0,1
	dc.b	5,0,5,0,5,0,5,0
	dc.b	5,4,5,4,5,4,5,4
	dc.b	'"',8,'"',8,'"',8,'"',8
	dc.b	' ',0,' ',0,' ',0,' ',0
	dcb.w	16
	dc.b	1,7,1,7,1,7,1,7
	dc.b	$ff,$fe,$ff,$fe,$ff,$fe,$ff,$fe
	dc.b	'?',$ff,'?',$ff,'?',$ff,'?',$ff
	dc.b	' ',$c1,' ',$c1,' ',$c1,' ',$c1
	dc.b	$c1,$82,$c1,$82,$c1,$82,$c1,$82
	dc.b	$f,$84,$f,$84,$f,$84,$f,$84
	dc.b	$10,0,$10,0,$10,0,$10,0
	dcb.w	8
	dc.b	0,3,0,0,0,0,0,0
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	$ff,$e0,0,0,0,0,0,0
	dc.b	$83,7,$83,7,$83,7,$83,7
	dc.b	6,8,6,8,6,8,6,8
	dc.b	'>',$10,'>',$10,'>',$10,'>',$10
	dc.b	'@',0,'@',0,'@',0,'@',0
	dcb.w	16
	dc.b	0,$82,0,$82,0,$82,0,$82
	dc.b	0,2,0,2,0,2,0,2
	dc.b	' ',0,' ',0,' ',0,' ',0
	dc.b	$10,'B',$10,'B',$10,'B',$10,'B'
	dc.b	'!',4,'!',4,'!',4,'!',4
	dc.b	0,8,0,8,0,8,0,8
	dc.b	' ',0,' ',0,' ',0,' ',0
	dcb.w	8
	dc.b	0,7,0,0,0,0,0,0
	dc.b	$80,'8',0,0,0,0,0,0
	dcb.w	4
	dc.b	'A',8,'A',8,'A',8,'A',8
	dc.b	$84,$10,$84,$10,$84,$10,$84,$10
	dc.b	0,' ',0,' ',0,' ',0,' '
	dc.b	$80,0,$80,0,$80,0,$80,0
	dcb.w	16
	dc.b	0,'A',0,'A',0,'A',0,'A'
	dc.b	0,2,0,2,0,2,0,2
	dc.b	' ',0,' ',0,' ',0,' ',0
	dc.b	8,'$',8,'$',8,'$',8,'$'
	dc.b	$12,8,$12,8,$12,8,$12,8
	dc.b	$f,$90,$f,$90,$f,$90,$f,$90
	dc.b	'@',0,'@',0,'@',0,'@',0
	dcb.w	8
	dc.b	0,$f,0,0,0,0,0,0
	dc.b	0,'8',0,0,0,0,0,0
	dcb.w	4
	dc.b	' ',$90,' ',$90,' ',$90,' ',$90
	dc.b	'H H H H '
	dc.b	'>A>A>A>A'
	dcb.w	20
	dc.b	0,' ',0,' ',0,' ',0,' '
	dc.b	$80,2,$80,2,$80,2,$80,2
	dc.b	' ',0,' ',0,' ',0,' ',0
	dc.b	4,$14,4,$14,4,$14,4,$14
	dc.b	$14,$10,$14,$10,$14,$10,$14,$10
	dc.b	8,$a0,8,$a0,8,$a0,8,$a0
	dc.b	$80,0,$80,0,$80,0,$80,0
	dcb.w	8
	dc.b	0,7,0,0,0,0,0,0
	dc.b	$80,'8',0,0,0,0,0,0
	dcb.w	4
	dc.b	$10,'P',$10,'P',$10,'P',$10,'P'
	dc.b	'P@P@P@P@'
	dc.b	'"',$82,'"',$82,'"',$82,'"',$82
	dcb.w	20
	dc.b	0,$10,0,$10,0,$10,0,$10
	dc.b	'@',2,'@',2,'@',2,'@',2
	dc.b	'?',$ff,'?',$ff,'?',$ff,'?',$ff
	dc.b	$82,$c,$82,$c,$82,$c,$82,$c
	dc.b	$18,'#',$18,'#',$18,'#',$18,'#'
	dc.b	$f8,$c1,$f8,$c1,$f8,$c1,$f8,$c1
	dcb.w	12
	dc.b	0,3,0,0,0,0,0,0
	dc.b	$c0,'?',0,0,0,0,0,0
	dc.b	$fc,0,0,0,0,0,0,0
	dc.b	8,'0',8,'0',8,'0',8,'0'
	dc.b	'`',$8f,'`',$8f,'`',$8f,'`',$8f
	dc.b	$e3,4,$e3,4,$e3,4,$e3,4
	dcb.w	20
	dc.b	0,8,0,8,0,8,0,8
	dc.b	' ',2,' ',2,' ',2,' ',2
	dcb.w	4
	dc.b	'A',4,'A',4,'A',4,'A',4
	dc.b	$10,'B',$10,'B',$10,'B',$10,'B'
	dc.b	8,$82,8,$82,8,$82,8,$82
	dcb.w	12
	dc.b	0,1,0,0,0,0,0,0
	dc.b	$e0,'?',0,0,0,0,0,0
	dc.b	$fc,0,0,0,0,0,0,0
	dc.b	4,$10,4,$10,4,$10,4,$10
	dc.b	'A',8,'A',8,'A',8,'A',8
	dc.b	'"',8,'"',8,'"',8,'"',8
	dcb.w	20
	dc.b	0,4,0,4,0,4,0,4
	dc.b	$10,2,$10,2,$10,2,$10,2
	dcb.w	4
	dc.b	' ',$82,' ',$82,' ',$82,' ',$82
	dc.b	' ',$82,' ',$82,' ',$82,' ',$82
	dc.b	8,$84,8,$84,8,$84,8,$84
	dcb.w	16
	dc.b	$f0,'?',0,0,0,0,0,0
	dc.b	$fc,0,0,0,0,0,0,0
	dc.b	2,8,2,8,2,8,2,8
	dc.b	$82,8,$82,8,$82,8,$82,8
	dc.b	'"',$10,'"',$10,'"',$10,'"',$10
	dcb.w	20
	dc.b	0,2,0,2,0,2,0,2
	dc.b	8,2,8,2,8,2,8,2
	dcb.w	4
	dc.b	'A',4,'A',4,'A',4,'A',4
	dc.b	$10,'B',$10,'B',$10,'B',$10,'B'
	dc.b	8,$82,8,$82,8,$82,8,$82
	dcb.w	16
	dc.b	'x8',0,0,0,0,0,0
	dcb.w	4
	dc.b	4,$10,4,$10,4,$10,4,$10
	dc.b	'A',8,'A',8,'A',8,'A',8
	dc.b	'"',8,'"',8,'"',8,'"',8
	dcb.w	20
	dc.b	0,1,0,1,0,1,0,1
	dc.b	4,2,4,2,4,2,4,2
	dc.b	'?',$ff,'?',$ff,'?',$ff,'?',$ff
	dc.b	$82,$c,$82,$c,$82,$c,$82,$c
	dc.b	$18,'"',$18,'"',$18,'"',$18,'"'
	dc.b	'8',$c1,'8',$c1,'8',$c1,'8',$c1
	dcb.w	16
	dc.b	'<8',0,0,0,0,0,0
	dcb.w	4
	dc.b	8,'0',8,'0',8,'0',8,'0'
	dc.b	'`',$88,'`',$88,'`',$88,'`',$88
	dc.b	$e3,4,$e3,4,$e3,4,$e3,4
	dcb.w	24
	dc.b	$82,2,$82,2,$82,2,$82,2
	dc.b	' ',0,' ',0,' ',0,' ',0
	dc.b	4,$14,4,$14,4,$14,4,$14
	dc.b	$14,$12,$14,$12,$14,$12,$14,$12
	dc.b	'(',$a0,'(',$a0,'(',$a0,'(',$a0
	dc.b	$80,0,$80,0,$80,0,$80,0
	dcb.w	12
	dc.b	$1e,'8',0,0,0,0,0,0
	dcb.w	4
	dc.b	$10,'P',$10,'P',$10,'P',$10,'P'
	dc.b	'PHPHPHPH'
	dc.b	$a2,$82,$a2,$82,$a2,$82,$a2,$82
	dcb.w	24
	dc.b	'A',2,'A',2,'A',2,'A',2
	dc.b	' ',0,' ',0,' ',0,' ',0
	dc.b	8,'$',8,'$',8,'$',8,'$'
	dc.b	$12,$a,$12,$a,$12,$a,$12,$a
	dc.b	'(',$90,'(',$90,'(',$90,'(',$90
	dc.b	'@',0,'@',0,'@',0,'@',0
	dcb.w	12
	dc.b	$f,'8',0,0,0,0,0,0
	dcb.w	4
	dc.b	' ',$90,' ',$90,' ',$90,' ',$90
	dc.b	'H(H(H(H('
	dc.b	$a2,'A',$a2,'A',$a2,'A',$a2,'A'
	dcb.w	24
	dc.b	' ',$82,' ',$82,' ',$82,' ',$82
	dc.b	' ',0,' ',0,' ',0,' ',0
	dc.b	$10,'B',$10,'B',$10,'B',$10,'B'
	dc.b	'!',6,'!',6,'!',6,'!',6
	dc.b	'(',$88,'(',$88,'(',$88,'(',$88
	dc.b	' ',0,' ',0,' ',0,' ',0
	dcb.w	12
	dc.b	7,$b8,0,0,0,0,0,0
	dcb.w	4
	dc.b	'A',8,'A',8,'A',8,'A',8
	dc.b	$84,$18,$84,$18,$84,$18,$84,$18
	dc.b	$a2,' ',$a2,' ',$a2,' ',$a2,' '
	dc.b	$80,0,$80,0,$80,0,$80,0
	dcb.w	20
	dc.b	$10,'B',$10,'B',$10,'B',$10,'B'
	dc.b	' ',0,' ',0,' ',0,' ',0
	dc.b	' ',$c1,' ',$c1,' ',$c1,' ',$c1
	dc.b	$c1,$82,$c1,$82,$c1,$82,$c1,$82
	dc.b	'(„(„(„(',$84
	dc.b	$10,0,$10,0,$10,0,$10,0
	dcb.w	12
	dc.b	3,$f8,0,0,0,0,0,0
	dcb.w	4
	dc.b	$83,7,$83,7,$83,7,$83,7
	dc.b	6,8,6,8,6,8,6,8
	dc.b	$a2,$10,$a2,$10,$a2,$10,$a2,$10
	dc.b	'@',0,'@',0,'@',0,'@',0
	dcb.w	20
	dc.b	8,'"',8,'"',8,'"',8,'"'
	dc.b	' ',0,' ',0,' ',0,' ',0
	dc.b	'A@A@A@A@'
	dc.b	1,'A',1,'A',1,'A',1,'A'
	dc.b	'(',$82,'(',$82,'(',$82,'(',$82
	dc.b	8,0,8,0,8,0,8,0
	dcb.w	12
	dc.b	1,$f8,0,0,0,0,0,0
	dc.b	0,1,0,1,0,1,0,1
	dc.b	5,0,5,0,5,0,5,0
	dc.b	5,4,5,4,5,4,5,4
	dc.b	$a2,8,$a2,8,$a2,8,$a2,8
	dc.b	' ',0,' ',0,' ',0,' ',0
	dcb.w	20
	dc.b	4,$12,4,$12,4,$12,4,$12
	dc.b	' ',0,' ',0,' ',0,' ',0
	dc.b	$82,' ',$82,' ',$82,' ',$82,' '
	dc.b	2,' ',2,' ',2,' ',2,' '
	dc.b	$a8,$81,$a8,$81,$a8,$81,$a8,$81
	dc.b	4,0,4,0,4,0,4,0
	dcb.w	12
	dc.b	0,$f8,0,0,0,0,0,0
	dc.b	0,2,0,2,0,2,0,2
	dc.b	8,$80,8,$80,8,$80,8,$80
	dc.b	8,$82,8,$82,8,$82,8,$82
	dc.b	$a2,4,$a2,4,$a2,4,$a2,4
	dc.b	$10,0,$10,0,$10,0,$10,0
	dcb.w	20
	dc.b	2,$a,2,$a,2,$a,2,$a
	dc.b	' ',1,' ',1,' ',1,' ',1
	dc.b	4,$10,4,$10,4,$10,4,$10
	dc.b	4,$10,4,$10,4,$10,4,$10
	dc.b	'h',$80,'h',$80,'h',$80,'h',$80
	dc.b	$82,0,$82,0,$82,0,$82,0
	dcb.w	12
	dc.b	0,'x',0,0,0,0,0,0
	dc.b	0,4,0,4,0,4,0,4
	dc.b	$10,'@',$10,'@',$10,'@',$10,'@'
	dc.b	$10,'A',$10,'A',$10,'A',$10,'A'
	dc.b	$a2,2,$a2,2,$a2,2,$a2,2
	dc.b	8,0,8,0,8,0,8,0
	dcb.w	20
	dc.b	1,6,1,6,1,6,1,6
	dc.b	' ',2,' ',2,' ',2,' ',2
	dc.b	8,$f,8,$f,8,$f,8,$f
	dc.b	$f8,$f,$f8,$f,$f8,$f,$f8,$f
	dc.b	$ef,$80,$ef,$80,$ef,$80,$ef,$80
	dc.b	$7f,0,$7f,0,$7f,0,$7f,0
	dcb.w	12
	dc.b	0,'8',0,0,0,0,0,0
	dc.b	0,8,0,8,0,8,0,8
	dc.b	' ? ? ? ?'
	dc.b	$e0,'?',$e0,'?',$e0,'?',$e0,'?'
	dc.b	$be,1,$be,1,$be,1,$be,1
	dc.b	$fc,0,$fc,0,$fc,0,$fc,0
	dcb.w	20
	dc.b	0,$82,0,$82,0,$82,0,$82
	dc.b	' ',4,' ',4,' ',4,' ',4
	dc.b	$10,0,$10,0,$10,0,$10,0
	dcb.w	24
	dc.b	0,$18,0,0,0,0,0,0
	dc.b	0,$10,0,$10,0,$10,0,$10
	dc.b	'@',0,'@',0,'@',0,'@',0
	dcb.w	32
	dc.b	0,'@',0,'@',0,'@',0,'@'
	dc.b	' ',8,' ',8,' ',8,' ',8
	dc.b	'?',$ff,'?',$ff,'?',$ff,'?',$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$c0,$ff,$c0,$ff,$c0,$ff,$c0
	dcb.w	16
	dc.b	0,' ',0,' ',0,' ',0,' '
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,0,$ff,0,$ff,0,$ff,0
	dcb.w	20
	dc.b	0,' ',0,' ',0,' ',0,' '
	dc.b	' ',$10,' ',$10,' ',$10,' ',$10
	dcb.w	12
	dc.b	0,' ',0,' ',0,' ',0,' '
	dcb.w	16
	dc.b	0,'@',0,'@',0,'@',0,'@'
	dcb.w	12
	dc.b	0,$80,0,$80,0,$80,0,$80
	dcb.w	20
	dc.b	0,$10,0,$10,0,$10,0,$10
	dc.b	'        '
	dcb.w	12
	dc.b	0,$10,0,$10,0,$10,0,$10
	dcb.w	16
	dc.b	0,$80,0,$80,0,$80,0,$80
	dcb.w	12
	dc.b	0,'@',0,'@',0,'@',0,'@'
	dcb.w	20
	dc.b	0,$f,0,$f,0,$f,0,$f
	dc.b	$e0,$7f,$e0,$7f,$e0,$7f,$e0,$7f
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$f8,$ff,$f8,$ff,$f8,$ff,$f8
	dcb.w	16
	dc.b	1,$ff,1,$ff,1,$ff,1,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$e0,$ff,$e0,$ff,$e0,$ff,$e0
	dcb.w	9312
ustck	dcb.w	2
tpnt	dc.l	sctext
cpnt	dc.l	c
wosw	dc.b	0,0
scrcnt	dc.b	0,0
height	dc.b	0,$e9,0,$13,0,$13
cop	dc.b	0,$13
len	dc.b	0,'P',0,4,0,4
addr	dc.l	space
sline	dcb.w	80
l005a	dcb.w	3616
space	dcb.w	40
	dc.b	$7f,0,0,0,$7f,0,0,0
	dc.b	$7f,0,0,0,$7f,0,0,0
	dc.b	$7f,0,0,0,3,0,0,0
	dc.b	3,0,0,0,$7f,0,0,0
	dc.b	$7f,0,0,0,$7f,0,0,0
	dc.b	$7f,0,0,0,$7f,0,0,0
	dc.b	'>',0,0,0,$1c,0,0,0
	dcb.w	2
	dc.b	$1c,0,0,0,'>',0,0,0
	dc.b	$7f,0,0,0,$7f,0,0,0
	dc.b	$7f,0,0,0,0,0,0,0
	dcb.w	238
	dc.b	0,$7f,$80,0,0,$ff,$80,0
	dc.b	1,$ff,$80,0,3,$ff,$80,0
	dc.b	7,$ff,$80,0,0,0,0,0
	dcb.w	2
	dc.b	'?',$c0,0,0,$7f,$80,0,0
	dc.b	$ff,0,0,0,$ff,0,0,0
	dc.b	$7f,$80,0,0,'?',$c0,0,0
	dc.b	$1f,$e0,0,0,$f,$f0,0,0
	dc.b	7,$ff,$80,0,3,$ff,$80,0
	dc.b	1,$ff,$80,0,0,$ff,$80,0
	dc.b	0,$7f,$80,0,0,7,$f8,0
	dc.b	0,7,$fc,0,0,7,$fe,0
	dc.b	0,7,$ff,0,0,7,$ff,$80
	dcb.w	5
	dc.b	$f,$f0,0,0,7,$f8,0,0
	dc.b	3,$fc,0,0,3,$fc,0,0
	dc.b	7,$f8,0,0,$f,$f0,0,0
	dc.b	$1f,$e0,0,0,'?',$c0,0,7
	dc.b	$ff,$80,0,7,$ff,0,0,7
	dc.b	$fe,0,0,7,$fc,0,0,7
	dc.b	$f8,0,0,0,0,0,0,0
	dcb.w	183
	dc.b	8,0,0,0,$1c,0,0,0
	dc.b	'>',0,0,0,$7f,0,0,0
	dc.b	'>',0,0,0,$1c,0,0,0
	dc.b	8,0,0,0,0,0,0,0
	dcb.w	38
	dc.b	'?',$ff,$ff,$f0,$7f,$ff,$ff,$f8
	dc.b	$ff,$ff,$ff,$fc,$7f,$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,0,0,$f,$fc
	dc.b	0,0,'?',$fc,$fc,0,$ff,$fc
	dc.b	$fc,3,$fe,$fc,$fc,$f,$f8,$fc
	dc.b	$fc,'?',$e0,$fc,$fc,$ff,$80,$fc
	dc.b	$ff,$fe,0,$fc,$ff,$f8,0,$fc
	dc.b	$ff,$e0,0,$fc,$ff,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$f8,'?',$ff,$ff,$f0
	dc.b	3,$ff,$fc,0,7,$ff,$fc,0
	dc.b	$f,$ff,$fc,0,7,$ff,$fc,0
	dc.b	3,$ff,$fc,0,0,0,0,0
	dcb.w	2
	dc.b	0,3,$fc,0,0,3,$fc,0
	dc.b	0,3,$fc,0,0,3,$fc,0
	dc.b	0,3,$fc,0,0,3,$fc,0
	dc.b	0,3,$fc,0,0,3,$fc,0
	dc.b	'?',$ff,$ff,$fc,$7f,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,$7f,$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$f0
	dc.b	$7f,$ff,$ff,$f8,$ff,$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$fc,'?',$ff,$ff,$fc
	dcb.w	4
	dc.b	'?',$ff,$ff,$fc,$7f,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$f8
	dc.b	$ff,$ff,$ff,$f0,$fc,0,0,0
	dc.b	$fc,0,0,0,$fc,0,0,0
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,'?',$ff,$ff,$e0
	dc.b	$7f,$ff,$ff,$f0,$ff,$ff,$ff,$f8
	dc.b	$7f,$ff,$ff,$fc,'?',$ff,$ff,$fc
	dcb.w	4
	dc.b	0,$ff,$ff,$f8,1,$ff,$ff,$f0
	dc.b	3,$ff,$ff,$e0,1,$ff,$ff,$f0
	dc.b	0,$ff,$ff,$f8,0,0,1,$fc
	dc.b	0,0,0,$fc,0,0,1,$fc
	dc.b	'?',$ff,$ff,$fc,$7f,$ff,$ff,$f8
	dc.b	$ff,$ff,$ff,$f0,$7f,$ff,$ff,$e0
	dc.b	'?',$ff,$ff,$c0,$fc,7,$e0,0
	dc.b	$fc,7,$e0,0,$fc,7,$e0,0
	dc.b	$fc,7,$e0,0,$fc,7,$e0,0
	dc.b	0,7,$e0,0,0,7,$e0,0
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,0,7,$e0,0
	dc.b	0,7,$e0,0,0,7,$e0,0
	dc.b	0,7,$e0,0,0,7,$e0,0
	dc.b	0,7,$e0,0,0,7,$e0,0
	dc.b	0,7,$e0,0,$ff,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dcb.w	4
	dc.b	$ff,$ff,$ff,$f0,$ff,$ff,$ff,$f8
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,0,0,0,$fc
	dc.b	0,0,0,$fc,0,0,0,$fc
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$f8
	dc.b	$ff,$ff,$ff,$f0,$fe,0,0,0
	dc.b	$fe,0,0,0,$fe,0,0,0
	dc.b	$fe,0,0,0,$fe,0,0,0
	dcb.w	4
	dc.b	$fe,0,0,0,$fe,$7f,$ff,$e0
	dc.b	$fe,$ff,$ff,$f0,$ff,$ff,$ff,$f8
	dc.b	$fe,$ff,$ff,$fc,$fe,$7f,$ff,$fc
	dc.b	$fe,0,0,$fc,$fe,0,0,$fc
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$f8,'?',$ff,$ff,$f0
	dc.b	$1f,$ff,$ff,$e0,'?',$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$fc,'?',$ff,$ff,$fc
	dcb.w	5
	dc.b	$1f,$f0,0,0,'?',$e0,0,0
	dc.b	$7f,$c0,0,0,$ff,$80,0,1
	dc.b	$ff,0,0,3,$fe,0,0,7
	dc.b	$fc,0,0,$f,$f8,0,0,$1f
	dc.b	$f0,0,0,'?',$e0,0,0,$7f
	dc.b	$c0,0,0,$ff,$80,0,1,$ff
	dc.b	0,0,$1f,$ff,$ff,$e0,'?',$ff
	dc.b	$ff,$f0,$7f,$ff,$ff,$f8,$ff,$ff
	dc.b	$ff,$fc,$ff,$ff,$ff,$fc,0,0
	dc.b	0,$fc,0,0,0,$fc,$ff,$ff
	dc.b	$ff,$fc,$7f,$ff,$ff,$f8,'?',$ff
	dc.b	$ff,$f0,$1f,$ff,$ff,$e0,'?',$ff
	dc.b	$ff,$f0,$7f,$ff,$ff,$f8,$fc,0
	dc.b	0,$fc,$fc,0,0,$fc,$ff,$ff
	dc.b	$ff,$fc,$ff,$ff,$ff,$fc,$7f,$ff
	dc.b	$ff,$f8,'?',$ff,$ff,$f0,$1f,$ff
	dc.b	$ff,$e0,$1f,$ff,$ff,$fc,'?',$ff
	dc.b	$ff,$fc,$7f,$ff,$ff,$fc,$ff,$ff
	dc.b	$ff,$fc,$ff,$ff,$ff,$fc,0,0
	dc.b	1,$fc,0,0,1,$fc,$ff,$ff
	dc.b	$ff,$fc,$ff,$ff,$ff,$fc,$7f,$ff
	dc.b	$ff,$fc,'?',$ff,$ff,$fc,$1f,$ff
	dc.b	$ff,$fc,0,0,1,$fc,0,0
	dc.b	1,$fc,0,0,1,$fc,0,0
	dc.b	1,$fc,0,0,1,$fc,0,0
	dc.b	1,$fc,0,0,1,$fc,0,0
	dc.b	1,$fc,0,0,0,0,0,0
	dcb.w	277
	dc.b	'?',$ff,$ff,$fc,$7f,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,$7f,$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,0,0,0,$fc
	dc.b	0,0,0,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',$ff,$ff,$e0,$7f,$ff,$ff,$f0
	dc.b	$ff,$ff,$ff,$f8,$7f,$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,0,0,0,$fc
	dc.b	0,0,0,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$f8,'?',$ff,$ff,$f0
	dc.b	'?',$ff,$ff,$e0,'?',$ff,$ff,$f0
	dc.b	'?',$ff,$ff,$f8,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$f8
	dc.b	'?',$ff,$ff,$f0,'?',$ff,$ff,$e0
c	dc.b	'?',$ff,$ff,$f0,$7f,$ff,$ff,$f8
	dc.b	$ff,$ff,$ff,$fc,$7f,$ff,$ff,$f8
	dc.b	'?',$ff,$ff,$f0,0,0,0,0
	dc.b	$c,0,0,0,$1e,0,0,0
	dc.b	'?',0,0,0,'?',0,0,0
	dc.b	'?',0,0,0,'?',0,0,0
	dc.b	'?',0,0,0,'?',0,0,0
	dc.b	'?',0,0,0,'?',$ff,$ff,$f0
	dc.b	'?',$ff,$ff,$f8,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$f8,'?',$ff,$ff,$f0
	dc.b	'?',$ff,$ff,$e0,$7f,$ff,$ff,$f0
	dc.b	$ff,$ff,$ff,$f8,$7f,$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,0,0,1,$fc
	dc.b	$c,0,0,$fc,$1e,0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,1,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$f8
	dc.b	'?',$ff,$ff,$f0,'?',$ff,$ff,$e0
	dc.b	'?',$ff,$ff,$fc,$7f,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,$7f,$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,0,0,0,0
	dcb.w	2
	dc.b	'?',$ff,$ff,$80,'?',$ff,$ff,$80
	dc.b	'?',$ff,$ff,$80,'?',$ff,$ff,$80
	dc.b	'?',$ff,$ff,$80,'?',0,0,0
	dc.b	'?',0,0,0,'?',0,0,0
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$fc,'?',$ff,$ff,$fc
	dcb.w	4
	dc.b	'?',$ff,$ff,0,'?',$ff,$ff,0
	dc.b	'?',$ff,$ff,0,'?',$ff,$ff,0
	dc.b	'?',$ff,$ff,0,'?',0,0,0
	dc.b	'?',0,0,0,'?',0,0,0
	dc.b	'?',0,0,0,'?',0,0,0
	dc.b	'?',0,0,0,'?',0,0,0
	dc.b	'?',0,0,0,'?',$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$fc,'?',$ff,$ff,$fc
	dcb.w	2
	dc.b	$c,0,0,0,$1e,0,0,0
	dc.b	'?',0,7,$fc,'?',0,$f,$fc
	dc.b	'?',0,$1f,$fc,'?',0,$f,$fc
	dc.b	'?',0,7,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	'?',0,0,$fc,$7f,0,0,$fc
	dc.b	$ff,0,0,$fc,$7f,0,0,$fc
	dc.b	'?',0,0,$fc,0,0,0,$fc
	dc.b	0,0,0,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',$ff,$ff,$f0,$7f,$ff,$ff,$f8
	dc.b	$ff,$ff,$ff,$fc,$7f,$ff,$ff,$f8
	dc.b	'?',$ff,$ff,$f0,0,0,0,0
	dc.b	0,3,0,0,0,7,$80,0
	dc.b	0,$f,$c0,0,0,$f,$c0,0
	dc.b	0,$f,$c0,0,0,$f,$c0,0
	dc.b	0,$f,$c0,0,0,$f,$c0,0
	dc.b	0,$f,$c0,0,'?',$ff,$ff,$f0
	dc.b	$7f,$ff,$ff,$f8,$ff,$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$f8,'?',$ff,$ff,$f0
	dc.b	0,3,$ff,$fc,0,7,$ff,$fc
	dc.b	0,$f,$ff,$fc,0,7,$ff,$fc
	dc.b	0,3,$ff,$fc,0,0,0,0
	dc.b	0,0,0,'`',0,0,0,$f0
	dc.b	0,0,1,$f8,0,0,1,$f8
	dc.b	$fc,0,1,$f8,$fc,0,1,$f8
	dc.b	$fe,0,1,$f8,$ff,0,1,$f8
	dc.b	$7f,$80,1,$f8,'?',$ff,$ff,$f8
	dc.b	$1f,$ff,$ff,$f8,$f,$ff,$ff,$f8
	dc.b	7,$ff,$ff,$f8,3,$ff,$ff,$f8
	dc.b	'?',0,0,'|',$7f,0,0,$fc
	dc.b	$ff,0,1,$fc,$7f,0,3,$fc
	dc.b	'?',0,7,$f8,0,0,$f,$f0
	dc.b	0,0,$1f,$e0,'?',$ff,$ff,$c0
	dc.b	'?',$ff,$ff,$80,'?',$ff,$ff,0
	dc.b	'?',$ff,$ff,0,'?',$ff,$ff,$80
	dc.b	'?',$ff,$ff,$c0,'?',0,$1f,$e0
	dc.b	'?',0,$f,$f0,'?',0,7,$f8
	dc.b	'?',0,3,$fc,'?',0,1,$fc
	dc.b	'?',0,0,$fc,'?',0,0,'|'
	dc.b	$fc,0,0,0,$fc,0,0,0
	dc.b	$fc,0,0,0,$fc,0,0,0
	dc.b	$fc,0,0,0,0,0,0,0
	dcb.w	2
	dc.b	$fc,0,0,0,$fc,0,0,0
	dc.b	$fc,0,0,0,$fc,0,0,0
	dc.b	$fc,0,0,0,$fc,0,0,0
	dc.b	$fc,0,0,0,$fc,0,0,0
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,'?',0,0,$fc
	dc.b	$7f,$80,1,$fc,$ff,$c0,3,$fc
	dc.b	$7f,$e0,7,$fc,'?',$f0,$f,$fc
	dc.b	0,0,$1f,$fc,0,0,'?',$fc
	dc.b	'?',$fe,$7f,$fc,'?',$7f,$fe,$fc
	dc.b	'??',$fc,$fc,'?',$1f,$f8,$fc
	dc.b	'?',$f,$f0,$fc,'?',7,$e0,$fc
	dc.b	'?',3,$c0,$fc,'?',1,$80,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',$80,0,$fc
	dc.b	$7f,$c0,0,$fc,$ff,$e0,0,$fc
	dc.b	$7f,$f0,0,$fc,'?',$f8,0,$fc
	dc.b	0,0,0,$fc,0,0,0,$fc
	dc.b	'?',$ff,0,$fc,'??',$80,$fc
	dc.b	'?',$1f,$c0,$fc,'?',$f,$e0,$fc
	dc.b	'?',7,$f0,$fc,'?',3,$f8,$fc
	dc.b	'?',1,$fc,$fc,'?',0,$fe,$fc
	dc.b	'?',0,$7f,$fc,'?',0,'?',$fc
	dc.b	'?',0,$1f,$fc,'?',0,$f,$fc
	dc.b	'?',0,7,$fc,'?',$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	0,0,0,$fc,0,0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$f0
	dc.b	$7f,$ff,$ff,$f8,$ff,$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	0,0,0,$fc,0,0,0,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$f8
	dc.b	'?',$ff,$ff,$f0,'?',0,0,0
	dc.b	'?',0,0,0,'?',0,0,0
	dc.b	'?',0,0,0,'?',0,0,0
	dc.b	'?',0,0,0,'?',0,0,0
	dc.b	'?',0,0,0,'?',$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	0,0,0,$fc,0,0,0,$fc
	dc.b	'?',0,0,$fc,'?',$7f,$80,$fc
	dc.b	'?',$7f,$c0,$fc,'?',$7f,$e0,$fc
	dc.b	'?',$7f,$f0,$fc,'?',$7f,$f8,$fc
	dc.b	'?',3,$fc,$fc,'?',1,$fe,0
	dc.b	'?',$fc,$ff,$fc,'?',$fe,$7f,$fc
	dc.b	'?',$ff,'?',$fc,'?',$ff,$9f,$fc
	dc.b	'?',$ff,$cf,$fc,'?',$ff,$ff,$e0
	dc.b	$7f,$ff,$ff,$f0,$ff,$ff,$ff,$f8
	dc.b	$7f,$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	0,0,0,$fc,0,0,0,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$f8
	dc.b	'?',$ff,$ff,$f0,'?',$ff,$ff,$e0
	dc.b	'?',$ff,$ff,$f0,'?',0,7,$f8
	dc.b	'?',0,3,$fc,'?',0,1,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',$ff,$ff,$f0
	dc.b	$7f,$ff,$ff,$f8,$ff,$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$f8,'?',$ff,$ff,$f0
	dcb.w	4
	dc.b	$fc,0,0,0,$ff,$ff,$ff,$f0
	dc.b	$ff,$ff,$ff,$f8,$ff,$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	0,0,0,$fc,0,0,0,$fc
	dc.b	'?',$ff,$ff,$fc,$7f,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,$7f,$ff,$ff,$f8
	dc.b	'?',$ff,$ff,$f0,'?',$ff,$ff,$f0
	dc.b	$7f,$ff,$ff,$f8,$ff,$ff,$ff,$fc
	dc.b	$7f,$ff,$ff,$f8,'?',$ff,$ff,$f0
	dcb.w	2
	dc.b	0,3,0,0,0,7,$80,0
	dc.b	0,$f,$c0,0,0,$f,$c0,0
	dc.b	0,$f,$c0,0,0,$f,$c0,0
	dc.b	0,$f,$c0,0,0,$f,$c0,0
	dc.b	0,$f,$c0,0,0,$f,$c0,0
	dc.b	0,$f,$c0,0,0,$f,$c0,0
	dc.b	0,$f,$c0,0,0,$f,$c0,0
	dc.b	'?',0,0,$fc,$7f,0,0,$fc
	dc.b	$ff,0,0,$fc,$7f,0,0,$fc
	dc.b	'?',0,0,$fc,0,0,0,$fc
	dc.b	0,0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',0,0,$fc,'?',0,0,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,'?',$ff,$ff,$fc
	dc.b	'?',0,0,$fc,$7f,0,0,$fc
	dc.b	$ff,0,0,$fc,$7f,0,0,$fc
	dc.b	'?',0,0,$fc,0,0,0,$fc
	dc.b	0,0,0,$fc,'?',0,0,$fc
	dc.b	'?',$80,1,$fc,'?',$c0,3,$fc
	dc.b	$1f,$e0,7,$f8,$f,$f0,$f,$f0
	dc.b	7,$f8,$1f,$e0,3,$fc,'?',$c0
	dc.b	1,$ff,$ff,$80,0,$ff,$ff,0
	dc.b	0,$7f,$fe,0,0,'?',$fc,0
	dc.b	0,$1f,$f8,0,0,$f,$f0,0
	dc.b	'?',0,0,$fc,$7f,0,0,$fc
	dc.b	$ff,0,0,$fc,$7f,0,0,$fc
	dc.b	'?',0,0,$fc,0,1,$80,$fc
	dc.b	0,3,$c0,$fc,'?',7,$e0,$fc
	dc.b	'?',$f,$f0,$fc,'?',$1f,$f8,$fc
	dc.b	'??',$fc,$fc,'?',$7f,$fe,$fc
	dc.b	'?',$fe,$7f,$fc,'?',$fc,'?',$fc
	dc.b	'?',$f8,$1f,$fc,'?',$f0,$f,$fc
	dc.b	'?',$e0,7,$fc,'?',$c0,3,$fc
	dc.b	'?',$80,1,$fc,'?',0,0,$fc
	dc.b	$fe,0,1,$fc,$ff,0,3,$fc
	dc.b	$7f,$80,7,$f8,'?',$c0,$f,$f0
	dc.b	$1f,$e0,$1f,$e0,0,0,'?',$c0
	dc.b	0,0,$7f,$80,3,$ff,$ff,0
	dc.b	1,$ff,$fe,0,0,$ff,$fc,0
	dc.b	0,$ff,$fc,0,1,$ff,$fe,0
	dc.b	3,$ff,$ff,0,7,$f8,$7f,$80
	dc.b	$f,$f0,'?',$c0,$1f,$e0,$1f,$e0
	dc.b	'?',$c0,$f,$f0,$7f,$80,7,$f8
	dc.b	$ff,0,3,$fc,$fe,0,1,$fc
	dc.b	$fe,0,1,$fc,$ff,0,3,$fc
	dc.b	$7f,$80,7,$f8,'?',$c0,$f,$f0
	dc.b	$1f,$e0,$1f,$e0,0,0,'?',$c0
	dc.b	0,0,$7f,$80,3,$ff,$ff,0
	dc.b	1,$ff,$fe,0,0,$ff,$fc,0
	dc.b	0,$7f,$f8,0,0,'?',$f0,0
	dc.b	0,$1f,$e0,0,0,$1f,$e0,0
	dc.b	0,$1f,$e0,0,0,$1f,$e0,0
	dc.b	0,$1f,$e0,0,0,$1f,$e0,0
	dc.b	0,$1f,$e0,0,0,$1f,$e0,0
	dc.b	'?',$ff,$ff,$fc,$7f,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,$7f,$ff,$ff,$fc
	dc.b	'?',$ff,$ff,$fc,0,0,0,0
	dcb.w	2
	dc.b	0,7,$ff,$c0,0,$1f,$ff,0
	dc.b	0,$7f,$fc,0,1,$ff,$f0,0
	dc.b	7,$ff,$c0,0,$1f,$ff,0,0
	dc.b	$7f,$fc,0,0,$ff,$f0,0,0
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc,$ff,$ff,$ff,$fc
	dc.b	$ff,$ff,$ff,$fc
fsswi	dc.b	0,0
paulscnt	dc.b	0,0
monswi	dc.b	0,1

music	incbin	music.bin
back	incbin	back

sctext	dc.b	'  HELLO ONCE AGAIN   THE GUARDIA'
	dc.b	'NS OF LOGIK BRING YOU AUTOMATION'
	dc.b	'dc.b	' CD222 WITH YET SOME MORE WONDERFUL TITLES......'
	dc.b	'WELL HERE GOES PRESS 1 FOR BREACH 2......(PLEASE'
	dc.b	' LEAVE DISK WRITE ENABLED TO CREATE YOUR OWN DAT'
	dc.b	'A BUT DO THIS ONLY ONCE  - YOU HAVE BEEN WARNED '
	dc.b	'-...... PRESS 2 FOR DEEP SPACE...... PRESS 3 FOR'
	dc.b	' DIZZY WIZARD BEFORE WE GO ANY FURTHER I WOULD L'
	dc.b	'IKE TO THANK THE BALD EAGLE FOR PACKING NINETY P'
	dc.b	'ER CENT OF THE GUARDIANS OF LOGIK MENUS EVEN THO'
	dc.b	'UGH HE KEPT ALL THE SOFTWARE TILL HE PACKED IT B'
	dc.b	'EFORE HE GAVE IT TO ANYONE ELSE......HIS MAIN IN'
	dc.b	'TERESTS ARE LEAVING ON THE ORIGINAL INTROS.....('
	dc.b	'BECAUSE HE CANNOT TAKE THEM OFF OR RIP MUSIC OFF'
	dc.b	') IN FACT ALL HE CAN DO IS USE OTHER PEOPLES COD'
	dc.b	'E AND THEN GIVE IT TO ANYONE HE FEELS LIKE (DIO '
	dc.b	'AND EL-SID REALLY APPRECIATED THAT ESPECIALLY WH'
	dc.b	'EN YOU TOOK ALL THE CREDIT FOR THE CODE).......B'
	dc.b	'UT APART FROM THAT THE ONLY GOOD THING ABOUT NEW'
	dc.b	' ORDER IS IF THERE IS NOWT ON TELLY THEN YOU CAN'
	dc.b	' HAVE A GOOD LAUGH AT THEIR MENUS......WELL THAT'
	dc.b	' IS ALL FOLKS.... NOW FOR .....YEP YOU GUESSED S'
	dc.b	'ELF APPRAISAL TIME ..... HI TO ALL THE OTHER MEM'
	dc.b	'BERS OF THE GUARDIANS OF LOGIK   GREETINGS TO TH'
	dc.b	'E REST OF AUTOMATION (I WOULD GREET YOU ALL INDI'
	dc.b	'VIDUALLY BUT I DO NOT KNOW EVERYONE AND I CANNOT'
	dc.b	' BE BOTHERED TYPING YOU ALL IN THANKS TO DEFCON '
	dc.b	'FOR THE INTRO    GREETINGS TO ANYONE WHO KNOWS U'
	dc.b	'S AND A MEGA GREET TO JOBIL SORRY FOR THE DELAY '
	dc.b	'I WILL BE IN TOUCH VERY SOON AND MEGA GREETS GOT'
	dc.b	'O MAL (THE GUY WHO IS NEVER IN!!!!) HEY DACK WE '
	dc.b	'ARE SORRY IT TOOK SO LONG TO DO THESE TWO DISKS '
	dc.b	'BUT WE SHOULD BE FASTER NEXT TIME ANYWAY IT IS N'
	dc.b	'OW 1 AM AND I AM' !)(',$27,'!.!'
	dc.b	'!           I MEAN TIRED SO I AM'
	dc.b	' GOING TO BED NOW BUT BEFORE I G'
	dc.b	'O IS THERE ANYONE OUT THERE WHO '
	dc.b	'IS FASTER THAN DORK MD IF SO YOU'
	dc.b	' KNOW WHERE WE ARE!!!!  NIGHTY N'
	dc.b	'IGHT NOW..............ZZZZZ   ZZ'
	dc.b	'ZZZ    ZZZZZ    ZZZZZ    ZZZZZ  '
	dc.b	'  ZZZZZ        '
tend	dc.b	'\breach_2.dat',0
file2	dc.b	'\deep.gol',0
file3	dc.b	'\dizzy.dat',0
