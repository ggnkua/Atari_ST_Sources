start	move.l	4(a7),d0
		move.l	#vbl,d1
		sub.l	d0,d1
		move.l	d1,-(a7)
		move.l	d0,-(a7)
		move.l	#$4a0000,-(a7)
		trap		#1
		add.w	#$c,a7
		clr.l	-(a7)
		move.w	#$20,-(a7)
		trap		#1
		move.l	$42e.w,d0
		move.l	d0,a7
		cmp.l	#$80000,d0
		bgt.s	loadsamem
		sf		memory
		move.l	#$40004,globxadd
		move.l	#$40004,globxadd+4
loadsamem	bsr		menu
		or		#$fff,sr
		lea		vbl,a7
		move.l	game,d0
		pea		dummy
		pea		dummy
		move.l	d0,-(a7)
		clr.w	-(a7)
		move.w	#$4b,-(a7)
		trap		#1
		add.w	#16,a7
 		clr.w	-(a7)
		trap		#1

menu		bsr		shiftbbc
		bsr		shiftglb
		bsr		splitcirc
		bsr		setscreen
		bsr		music
		move.b	#0,$fffffa1b.w
		move.b	#1,$fffffa07.w
		bset		#0,$fffffa13.w
		move.b	#$0,$fffffa09.w
		move.b	#$12,$fffffc02.w
		lea		scrollp1,a0
		move.w	#$230*$80/4-1,d0
.clrbuf	clr.l	(a0)+
		dbf		d0,.clrbuf
		bsr		bbc
		bsr		vblon
.readkey
		move.b	$fffffc02.w,d0
		cmp.b	#11,d0
		bne.s	.game
		eor.w	#7,bbc_pal
		bra		.readkey
.game	lea		game1,a0
		cmp.b	#2,d0
		beq.s	.play
		lea		game2,a0
		cmp.b	#3,d0
		beq.s	.play
		lea		game3,a0
		cmp.b	#4,d0
		bne.s	.readkey
.play	move.b	$fffffc02.w,d0
		btst		#7,d0
		bne.s	.play
		move.l	a0,game
		bsr		vbloff
		move.w	#$25,-(a7)
		trap		#14
		addq.l	#2,a7
		move.w	#$777,$ff8240
		clr.w	$ff8246
		rts

setscreen	move.w	#2,-(a7)
		trap		#14
		addq.l	#2,a7
		sub.l	#$3000,d0
		move.l	d0,a0
		move.l	d0,screen
		lsr.w	#8,d0
		move.b	d0,$ff8203
		swap		d0
		move.b	d0,$ff8201
		move.w	#$ad00/4-1,d0
.clear	clr.l	(a0)+
		dbf		d0,.clear
		move.l	#grafs+34+32*160,a0
		sub.l	a1,a1		
		move.w	#20*160/4-1,d0
		bsr		scrncopy
		move.l	#grafs+34+52*160,a0
		move.l	#108*160,a1
		move.w	#8*160/4-1,d0
		bsr		scrncopy
		move.l	#grafs+34,a0
		move.l	#124*160,a1
		move.w	#32*160/4-1,d0

scrncopy	add.l	screen,a1
.copy	move.l	(a0)+,(a1)+
		dbf		d0,.copy
		rts


shiftbbc	lea		bbc_posn,a0
		lea		bbcs,a2
		clr.w	d0
		move.w	#$10,d1
shift4	move.l	a2,(a0)+
		lea		bbc_graf,a1
		move.w	#$45,d2
shift3	clr.l	(a2)+
		clr.l	(a2)+
		move.w	#6,D3
shift2	lea		0(a1,d3.w),a3
		lea		0(a2,d3.w),a4
		move.w	(a3),d5
		lsr.w	d0,d5
		move.w	d5,(a4)
		addq.w	#8,a4
		move.w	#$a,d4
shift1	move.w	(a3),d5
		addq.w	#8,a3
		move.w	(a3),d6
		lsl.w	d1,d5
		lsr.w	d0,d6
		or.w		d5,d6
		move.w	d6,(a4)
		addq.w	#8,a4
		dbf		d4,shift1
		move.w	(a3),d5
		lsl.w	d1,d5
		move.w	d5,(a4)
		subq.w	#2,d3
		bpl.s	shift2
		add.w	#$68,a2
		clr.l	(a2)+
		clr.l	(a2)+
		add.w	#$60,a1
		dbf		d2,shift3
		addq.w	#1,d0
		subq.w	#1,d1
		bne		shift4

		lea		bbc_posn,a2
		move.l	60(a2),a0
		lea		$20d0(a0),a0
		move.l	a0,bbc_off
		move.l	a0,bbc_off_pos
		lea		bbc_pts,a1
shiftpts	move.w	(a1)+,d0
		bmi.s	ptsdone
		move.w	d0,d1
		and.w	#$f,d0
		and.w	#$f0,d1
		lsl.w	#2,d0
		move.l	0(a2,d0.w),(a0)+
		lsr.w	#1,d1
		move.w	d1,(a0)+
		move.w	#$98,d0
		sub.w	d1,d0
		move.w	d0,(a0)+
		bra.s	shiftpts		
ptsdone	move.l	#-1,(a0)+
		move.l	a0,globshft
		rts

shiftglb	lea		globshft,a0
		move.l	(a0),a1
		moveq	#0,d7
moreshft	move.l	a1,(a0)+
		move.w	d7,d0
		bsr		shftglbs
		add.w	globxadd,d7
		and.w	#$f,d7
		bne.s	moreshft
		moveq	#3,d7
		tst.b	memory
		beq.s	none
		moveq	#7,d7
none		lea		globmask,a0
		lea		globshft,a2
moremask	move.l	a1,(a0)+
		bsr		calcmask
		dbf		d7,moremask	
		rts

shftglbs	lea		globgraf,a2
		move.w	#32*32-1,d1
shftline	moveq	#6,d2
shftplan	move.w	0(a2,d2.w),d3
		swap		d3
		move.w	8(a2,d2.w),d3
		moveq	#0,d4
		move.w	d3,d4
		swap		d4
		lsr.l	d0,d3
		lsr.l	d0,d4
		move.w	d3,8(a1,d2.w)
		move.w	d4,16(a1,d2.w)
		swap		d3
		move.w	d3,0(a1,d2.w)
		subq.w	#2,d2
		bpl.s	shftplan
		lea		24(a1),a1
		lea		16(a2),a2
		dbf		d1,shftline
		rts

calcmask	move.l	(a2)+,a3
		moveq	#32*3-1,d0
.mask	movem.w	(a3)+,d2-d5
		or.w		d3,d2
		or.w		d4,d2
		or.w		d5,d2
		not.w	d2
		move.w	d2,d3
		swap		d2
		move.w	d3,d2
		move.l	d2,(a1)+
		dbf		d0,.mask
		rts		

splitcirc	move.l	globmask+12,a0
		tst.b	memory
		beq.s	notalot
		move.l	globmask+28,a0
notalot	lea		192*2(a0),a0
		move.l	a0,circs
		lea		grafs+40+60*160,a1
		move.w	#31,d0
makecirc	move.w	(a1),(a0)+
		move.w	8(a1),(a0)+
		move.w	16(a1),(a0)+
		move.w	24(a1),(a0)+
		lea		$a0(a1),a1
		dbf		d0,makecirc
		rts

vblon	move.l	$70,oldvbl
		move.l	#vbl,$70
		clr.b	$ff8260
		movem.l	bbc_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

vbloff	move.l	oldvbl,$70
		move.b	#0,$fffa07
		move.b	$fffa15,$fffa09
		move.b	#8,$ff8800
		clr.b	$ff8802
		move.b	#9,$ff8800
		clr.b	$ff8802
		move.b	#10,$ff8800
		clr.b	$ff8802
		move.b	#8,$fffffc02.w
		move.l	screen,d0
		add.l	#$3000,d0
		move.l	d0,a0
		lsr.w	#8,d0
		move.b	d0,$ffff8203
		swap		d0
		move.b	d0,$ffff8201
		move.w	#$1f3f,d0
.clrscrn	clr.l	(a0)+
		dbf		d0,.clrscrn
		rts


oldvbl	dc.l		0



vbl		movem.l	d0-d7/a0-a6,-(a7)
		move.w	sr,-(a7)
		move		#$2700,sr
		bsr		clrglobe
		moveq	#5,d0
		movem.l	bbc_cont,a0-a2
		bsr		bbc_line
		movem.l	grafs+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.l	#$2e,d0
del1		dbf		d0,del1
		move.b	#$0,$ff820a
		moveq	#3,d0
del2		nop		
		dbf		d0,del2
		move.b	#2,$ff820a
		move.w	(a7)+,sr
		clr.b	$fffffa1b.w
		move.b	#22,$fffffa21.w
		move.l	#mfp1,$120.w
		move.b	#8,$fffffa1b.w
		move.b	#73,$fffffa21.w
		subq.w	#1,wong_del
		bpl.s	no_wong
		move.w	#5,wong_del
		move.w	grafs+4,d0
		add.w	wong_add,d0
		cmp.w	#$100,d0
		beq.s	rev_wong
		cmp.w	#$700,d0
		bne.s	no_rev_w
rev_wong	neg.w	wong_add
no_rev_w	move.w	d0,grafs+4
no_wong	move.w	#30,mfp_cnt
		move.l	mfp_col1,a0
		addq.l	#2,a0
		cmp.l	#mfp_rept,a0
		bne.s	mfp_ok
		lea		mfp_cols,a0
mfp_ok	move.l	a0,mfp_col1
		move.l	a0,mfp_col2
		bsr		globes
		bsr		scroll
		bsr		circles
		bsr		bbc
		bsr		music+$a8
		movem.l	(a7)+,d0-d7/a0-a6
		rte

mfp1		movem.l	d0-d7,-(a7)
		movem.l	bbc_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	(a7)+,d0-d7
		move.b	#30,$fffffa21.w
		move.l	#mfp2,$120.w
		bclr		#0,$fffffa0f.w
		rte

mfp2		movem.l	d0-d7,-(a7)
		movem.l	grafs+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	(a7)+,d0-d7
		move.b	#1,$fffffa21.w
		move.l	#mfp3,$120.w
		bclr		#0,$fffffa0f.w
		rte

mfp3		move.l	a0,-(a7)
		move.l	mfp_col2,a0
		move.w	(a0)+,$ffff8242.w
		move.l	a0,mfp_col2
		move.l	(a7)+,a0
		subq.w	#1,mfp_cnt
		bpl.s	end_mfp
		move.b	#63,$fffffa21.w
		move.l	#mfp4,$120.w
end_mfp	bclr		#0,$fffffa0f.w
		rte

mfp4		movem.l	d0-d7,-(a7)
		movem.l	glob_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	(a7)+,d0-d7
		move.l	#mfp5,$120.w
		move.b	#9,$fffffa21.w
		bclr		#0,$fffffa0f.w
		rte

mfp5		movem.l	d0-d7,-(a7)
		movem.l	char_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	(a7)+,d0-d7
		move.b	#100,$fffffa21.w
		move.l	#mfp6,$120.w
		bclr		#0,$fffffa0f.w
		rte

mfp6		movem.l	d0/a1,-(a7)
		move		#$2700,sr
          move.w  	#$fa21,a1
          move.b  	(a1),d0
wait4     cmp.b   	(a1),d0         	wait last scanline
          beq     	wait4           
          clr.b   	$ffff820a.w     	60 Hz
          moveq   	#4,d0
nopi2     nop                     		wait a while
          dbf     	d0,nopi2
          move.b  	#2,$ffff820a.w  	50 Hz
		movem.l	(a7)+,d0/a1
		move.l	#mfp1,$120.w
          bclr    	#0,$fffffa0f.w  	end of interrupt 
          rte



*********************************
*********  G L O B E S  *********
*********************************

globes	lea		oldglob,a6
		move.w	globxpos,d0
		add.w	globxadd,d0
		tst.w	d0
		beq.s	changedir
		cmp.w	#288,d0
		bne.s	samedir
changedir	neg.w	globxadd
		neg.w	aniadd
samedir	move.w	d0,globxpos
		move.l	globypos,a0
		move.w	(a0)+,d3
		bpl.s	okypos1
		lea		glob_pts,a0
		move.w	(a0)+,d3
okypos1	move.l	a0,globypos
		move.w	globani,d2
		not.w	globspin
		beq.s	spindone
		add.w	aniadd,d2
		cmp.w	#$6000,d2
		bne.s	no_grept
		clr.w	d2
		bra.s	spindone
no_grept	tst.w	d2
		bpl.s	spindone
		move.w	#$5d00,d2	
spindone	move.w	d2,globani

		move.w	d0,d1
		and.w	#$f,d0
		and.w	#$ff0,d1
		tst.b	memory
		beq.s	lamer
		add.w	d0,d0
lamer	lsr.w	#1,d1
		add.w	d3,d1
		lea		globshft,a0		
		move.l	0(a0,d0.w),a0
		add.w	d2,a0
		move.l	screen,a1
		add.w	d1,a1
		move.l	a1,(a6)+
		rept		4
		movem.l	(a0)+,d0-d7/a2-a5
		movem.l	d0-d5,(a1)
		movem.l	d6-d7/a2-a5,160(a1)
		movem.l	(a0)+,d0-d7/a2-a5
		movem.l	d0-d5,320(a1)
		movem.l	d6-d7/a2-a5,480(a1)
		movem.l	(a0)+,d0-d7/a2-a5
		movem.l	d0-d5,640(a1)
		movem.l	d6-d7/a2-a5,800(a1)
		movem.l	(a0)+,d0-d7/a2-a5
		movem.l	d0-d5,960(a1)
		movem.l	d6-d7/a2-a5,1120(a1)
		lea		1280(a1),a1
		endr

		move.w	globxpos+2,d0
		add.w	globxadd+2,d0
		tst.w	d0
		beq.s	change2
		cmp.w	#288,d0
		bne.s	same2
change2	neg.w	globxadd+2
		neg.w	aniadd+2
same2	move.w	d0,globxpos+2
		move.l	globypos+4,a0
		move.w	(a0)+,d3
		bpl.s	okypos2
		lea		glob_pts,a0
		move.w	(a0)+,d3
okypos2	move.l	a0,globypos+4
		move.w	globani+2,d2
		tst.w	globspin
		beq.s	spindone2
		add.w	aniadd+2,d2
		cmp.w	#$6000,d2
		bne.s	no_grept2
		clr.w	d2
		bra.s	spindone2
no_grept2	tst.w	d2
		bpl.s	spindone2
		move.w	#$5d00,d2	
spindone2	move.w	d2,globani+2
		bsr		plotglob

		move.w	globxpos+4,d0
		add.w	globxadd+4,d0
		tst.w	d0
		beq.s	change3
		cmp.w	#288,d0
		bne.s	same3
change3	neg.w	globxadd+4
		neg.w	aniadd+4
same3	move.w	d0,globxpos+4
		move.l	globypos+8,a0
		move.w	(a0)+,d3
		bpl.s	okypos3
		lea		glob_pts,a0
		move.w	(a0)+,d3
okypos3	move.l	a0,globypos+8
		move.w	globani+4,d2
		tst.w	globspin
		beq.s	spindone3
		add.w	aniadd+4,d2
		cmp.w	#$6000,d2
		bne.s	no_grept3
		clr.w	d2
		bra.s	spindone3
no_grept3	tst.w	d2
		bpl.s	spindone3
		move.w	#$5d00,d2	
spindone3	move.w	d2,globani+4
		bsr		plotglob

		move.w	globxpos+6,d0
		add.w	globxadd+6,d0
		tst.w	d0
		beq.s	change4
		cmp.w	#288,d0
		bne.s	same4
change4	neg.w	globxadd+6
		neg.w	aniadd+6
same4	move.w	d0,globxpos+6
		move.l	globypos+12,a0
		move.w	(a0)+,d3
		bpl.s	okypos4
		lea		glob_pts,a0
		move.w	(a0)+,d3
okypos4	move.l	a0,globypos+12
		move.w	globani+6,d2
		tst.w	globspin
		beq.s	spindone4
		add.w	aniadd+6,d2
		cmp.w	#$6000,d2
		bne.s	no_grept4
		clr.w	d2
		bra.s	spindone4
no_grept4	tst.w	d2
		bpl.s	spindone4
		move.w	#$5d00,d2	
spindone4	move.w	d2,globani+6

plotglob	move.w	d0,d1
		and.w	#$f,d0
		and.w	#$ff0,d1
		tst.b	memory
		beq.s	pauper
		add.w	d0,d0 
pauper	lsr.w	#1,d1
		add.w	d3,d1
		lea		globshft,a0		
		move.l	0(a0,d0.w),a0
		add.w	d2,a0
		lea		globmask,a1
		move.l	0(a1,d0.w),a1
		move.l	screen,a2
		add.w	d1,a2
		move.l	a2,(a6)+
		rept		32 
		movem.l	(a1)+,d0-d2
		move.l	a2,a3
		and.l	d0,(a3)+
		and.l	d0,(a3)+
		and.l	d1,(a3)+
		and.l	d1,(a3)+
		and.l	d2,(a3)+
		and.l	d2,(a3)
		movem.l	(a0)+,d0-d5
		or.l		d0,(a2)+
		or.l		d1,(a2)+
		or.l		d2,(a2)+
		or.l		d3,(a2)+
		or.l		d4,(a2)+
		or.l		d5,(a2)
		lea		140(a2),a2
		endr
		rts

***

clrglobe	moveq	#0,d0		
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		lea		oldglob,a0
		move.l	(a0)+,a1
		bsr		clrglob
		move.l	(a0)+,a1
		bsr		clrglob
		move.l	(a0)+,a1
		bsr		clrglob
		move.l	(a0),a1
clrglob	rept		2
		movem.l	d0-d5,(a1)
		movem.l	d0-d5,160(a1)
		movem.l	d0-d5,320(a1)
		movem.l	d0-d5,480(a1)
		movem.l	d0-d5,640(a1)
		movem.l	d0-d5,800(a1)
		movem.l	d0-d5,960(a1)
		movem.l	d0-d5,1120(a1)
		movem.l	d0-d5,1280(a1)
		movem.l	d0-d5,1440(a1)
		movem.l	d0-d5,1600(a1)
		movem.l	d0-d5,1760(a1)
		movem.l	d0-d5,1920(a1)
		movem.l	d0-d5,2080(a1)
		movem.l	d0-d5,2240(a1)
		movem.l	d0-d5,2400(a1)
		lea		2560(a1),a1
		endr
		rts

		
*********************************
************  B B C  ************
*********************************

bbc		move.l	bbc_off_pos,a2
		addq.l	#8,a2
		tst.l	70*8(a2)
		bpl.s	.ok_pos
		move.l	bbc_off,a2
.ok_pos	move.l	a2,bbc_off_pos
		sub.l	a0,a0
		move.l	screen,a1
		lea		25*160-8(a1),a1
		move.w	#28,d0
bbc_line	rept		2
		move.l	a0,a3
		add.l	(a2)+,a3
		add.w	(a2)+,a1
		clr.l	(a1)+
		clr.l	(a1)+
		movem.l	(a3)+,d1-d7/a4-a6
		movem.l	d1-d7/a4-a6,(a1)
		movem.l	(a3)+,d1-d7/a4-a6
		movem.l	d1-d7/a4-a6,$28(a1)
		movem.l	(a3),d1-d7/a4-a5
		movem.l	d1-d7/a4-a6,$50(a1)
		clr.l	$70(a1)
		clr.l	$74(a1)
		lea		$78(a0),a0
		add.w	(a2)+,a1
		endr
		dbf		d0,bbc_line
		movem.l	a0-a2,bbc_cont
		rts

bbc_cont	ds.l		3


*********************************
******** S C R O L L E R ********
*********************************

scroll	subq.w	#4,scrlpos
		move.w	scrlpos,d0
		and.w	#$1f,d0
		jmp		scrltab(pc,d0.w)

scrlpos	dc.w		32
scrloff	dc.w		32
		
scrltab
		bra		scroll1
		bra		scroll2
		bra		scroll3
		bra		scroll4
		bra		scroll5
		bra		scroll6
		bra		scroll7
		bra		scroll8

		
scroll1
		lea		scrollp1+8,a0
		bsr		show
		lea		scrollp1+$23f0,a0
		move.l	chargraf,a1
		add.w	#$100,a1
		moveq	#0,d0
		bsr		addlet
		move.l	messpos,a0
		moveq	#0,d0
		move.b	(a0)+,d0
		bpl.s	okchar
		moveq	#32,d0
		lea		message,a0
okchar	move.l	a0,messpos
		sub.w	#32,d0
		moveq	#9,d1
		lsl.w	d1,d0
		add.l	#charset,d0
		move.l	d0,chargraf
		add.w	#$10,scrloff
		cmp.w	#$130,scrloff
		bne.s	nooffrpt
		move.w	#$20,scrloff
nooffrpt	rts

scroll2
		lea		scrollp2+8,a0
		bsr		show
		lea		scrollp2+$23f0,a0
		move.l	chargraf,a1
		add.w	#$100,a1
		moveq	#4,d0
		bra		addlet
scroll3
		lea		scrollp3+8,a0
		bsr		show
		lea		scrollp3+$23f0,a0
		move.l	chargraf,a1
		add.w	#$100,a1
		moveq	#8,d0
		bra		addlet
scroll4
		lea		scrollp4+8,a0
		bsr		show
		lea		scrollp4+$23f0,a0
		move.l	chargraf,a1
		add.w	#$100,a1
		moveq	#12,d0
		bra		addlet
scroll5
		lea		scrollp1,a0
		bsr		show
		lea		scrollp1+$f0,a0
		move.l	chargraf,a1
		moveq	#0,d0
		bra		addlet
scroll6
		lea		scrollp2,a0
		bsr		show
		lea		scrollp2+$f0,a0
		move.l	chargraf,a1
		moveq	#4,d0
		bra		addlet
scroll7
		lea		scrollp3,a0
		bsr		show
		lea		scrollp3+$f0,a0
		move.l	chargraf,a1
		moveq	#8,d0
		bra		addlet
scroll8
		lea		scrollp4,a0
		bsr		show
		lea		scrollp4+$f0,a0
		move.l	chargraf,a1
		moveq	#12,d0
		bra		addlet

show
		add.w	scrloff,a0
		move.l	screen,a1
		add.l	#220*160,a1
		rept		32
		movem.l	(a0)+,d0-d7/a2-a3
		movem.l	d0-d7/a2-a3,(a1)
		movem.l	(a0)+,d0-d7/a2-a3
		movem.l	d0-d7/a2-a3,40(a1)
		movem.l	(a0)+,d0-d7/a2-a3
		movem.l	d0-d7/a2-a3,80(a1)
		movem.l	(a0)+,d0-d7/a2-a3
		movem.l	d0-d7/a2-a3,120(a1)
		lea		$190(a0),a0
		lea		160(a1),a1
		endr
		rts

addlet	add.w	scrloff,a0
		moveq	#15,d3
addone	rept		4
		moveq	#0,d2
		move.w	(a1)+,d1
		swap		d1
		move.w	6(a1),d1
		move.w	d1,d2
		swap 	d2
		lsr.l	d0,d1
		lsr.l	d0,d2
		move.w	d1,8(a0)
		move.w	d1,8-$110(a0)
		move.w	d2,16(a0)
		move.w	d2,16-$110(a0)
		swap		d1
		or.w		d1,(a0)+
		move.w	-2(a0),-$112(a0)
		endr
		lea		$228(a0),a0
		addq.l	#8,a1
		dbf		d3,addone
		rts


*********************************
********  C I R C L E S  ********
*********************************

circles	move.l	circs,a0
		move.l	screen,a1
		add.l	#220*160+6,a1
		rept		4		
		movem.w	(a0)+,d0-d7/a2-a5
		move.w	d0,(a1)
		move.w	d1,8(a1)
		move.w	d2,144(a1)
		move.w	d3,152(a1)
		move.w	d4,160(a1)
		move.w	d5,168(a1)
		move.w	d6,304(a1)
		move.w	d7,312(a1)
		move.w	a2,320(a1)
		move.w	a3,328(a1)
		move.w	a4,464(a1)
		move.w	a5,472(a1)
		movem.w	(a0)+,d0-d7/a2-a5
		move.w	d0,480(a1)
		move.w	d1,488(a1)
		move.w	d2,624(a1)
		move.w	d3,632(a1)
		move.w	d4,640(a1)
		move.w	d5,648(a1)
		move.w	d6,784(a1)
		move.w	d7,792(a1)
		move.w	a2,800(a1)
		move.w	a3,808(a1)
		move.w	a4,944(a1)
		move.w	a5,952(a1)
		movem.w	(a0)+,d0-d7
		move.w	d0,960(a1)
		move.w	d1,968(a1)
		move.w	d2,1104(a1)
		move.w	d3,1112(a1)
		move.w	d4,1120(a1)
		move.w	d5,1128(a1)
		move.w	d6,1264(a1)
		move.w	d7,1272(a1)
		lea		1280(a1),a1
		endr
		rts

game1	dc.b		'rotor.bbc',0
game2	dc.b		'thunder.bbc',0
game3	dc.b		'btiger.bbc',0
		
		even

screen	dc.l		$f8000
game		dc.l		0
dummy	dc.l		0

memory	dc.w		-1

char_pal	dc.w		0,$220,$330,$440,$550,$660,$770,$555,0,0,0,0,0,0,0,0

chargraf	dc.l		charset
messpos	dc.l		startmess

startmess	dcb.b	10,' '
message	include	'scrltxt1.s'

wong_del	dc.w		7
wong_add	dc.w		$ff00

bbc_off	dc.l		0
bbc_off_pos  dc.l	0
bbc_posn	ds.l		16

circs	dc.l		0

globshft	ds.l		8
globmask	ds.l		8
globspin	dc.w		0
oldglob	dc.l		$100000,$100000,$100000,$100000
globxpos	dc.w		100,80,60,40
globypos	dc.l		glob_pts,glob_pts+20,glob_pts+40,glob_pts+60
globxadd	dc.w		2,2,2,2
globani	dc.w		$300,9*$300,17*$300,25*$300
aniadd	dc.w		-$300,-$300,-$300,-$300
glob_pal	dc.w		0,$111,$222,$333,$444,$555,$666,$777,$600,$34,$13,$543,$432,$321,$763,$761

mfp_cnt	dc.w		31
mfp_col1	dc.l		mfp_cols
mfp_col2	dc.l		mfp_cols
mfp_cols	dc.w		0,$111,$222,$333,$444,$555,$666,$777,$767,$757,$747,$737,$727,$717
		dc.w		$707,$607,$507,$407,$307,$207,$107,6,5,4,3,2,1
mfp_rept	dc.w		0,$111,$222,$333,$444,$555,$666,$777,$767,$757,$747,$737,$727,$717
		dc.w		$707,$607,$507,$407,$307,$207,$107,6,5,4,3,2,1
		dc.w		0,$111,$222,$333,$444,$555,$666,$777,$767,$757,$747,$737,$727,$717

music	incbin	'sapiens.mus'
charset	incbin	'phalanx.dat'
bbc_pal	incbin	'bbc_pal.dat'
bbc_pts	incbin	'bbc_pts.dat'
		dc.w		-1
glob_pts	incbin	'globe_pt.dat'
		dc.w		-1
grafs	incbin	'menu240a.pi1'
bbc_graf	incbin	'bbc.dat'
globgraf	incbin	'globes.dat'

scrollp1	equ		grafs+34
scrollp2	equ		grafs+34+$230*$20
scrollp3	equ		grafs+34+$230*$40
scrollp4	equ		grafs+34+$230*$60
		
bbcs		equ		grafs+34+$230*$80