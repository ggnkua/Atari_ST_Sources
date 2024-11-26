	format	0-,1-,2-
	list	+
	
* The Ultimate 1-bit horizontal scroll with 2-bit vertical distort!!!
* Realised by Tony Bennett 08.11.1991
* ( I have a faster method now ....!? )
	list	-


	opt	d+

	clr	-(sp)
	pea	$70000
	pea	$70000
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp
	clr	-(sp)
	pea	$78000
	pea	$78000
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	pea	0.w
	move	#32,-(sp)
	trap	#1
	addq	#6,sp
	
	lea	wave,a0
	lea	wave2,a1
	move	#160/2-1,d0
cw
	move.l	(a0)+,(a1)+
	dbf	d0,cw
	
	move.b	#$12,$fffffc02.w
	
	clr	$ffff8240.w
	move	#-1,$ffff8242.w

	lea	text(pc),a0
cloop
	moveq	#0,d0
	move.b	(a0),d0
	cmpa.l	#textend,a0
	beq.s	cfin
	sub.b	#"A",d0
	move.b	d0,(a0)+
	bra.s	cloop
cfin

*---------
aa
	move	#37,-(sp)
	trap	#14
	addq	#2,sp

	bsr	scroll
	
	lea	n_clsptrs(pc),a4
	move.l	scr2(pc),a5
	lea	160*60(a5),a5
	bsr.s	mb_2pb
	
	move.l	scr2(pc),d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	move	#37,-(sp)
	trap	#14
	addq	#2,sp

	bsr	scroll
	
	lea	n_clsptrs2(pc),a4
	move.l	scr1(pc),a5
	lea	160*60(a5),a5
	bsr.s	mb_2pb
	
	move.l	scr1(pc),d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	cmp.b	#57,$fffffc02.w
	bne.s	aa
	
	move.b	#8,$fffffc02.w
	
	move	#-1,$ffff8240.w
	clr	$ffff8246.w
	
	illegal


*---------
mb_2pb
	move.l	woff(pc),a6
	tst	(a6)
	bpl.s	okay
	move.l	#wave2,woff
	move.l	woff(pc),a6
okay
	subq.l	#2,woff
	
i	set	0
	rept	10
	moveq	#i,d0
	bsr	plot_strip
i	set	i+1
	moveq	#i,d0
	bsr	plot_strip
i	set	i+7
	endr

	rept	10
	move	#i,d0
	bsr.s	plot_strip
i	set	i+1
	move	#i,d0
	bsr.s	plot_strip
i	set	i+7
	endr

	rts


*---------
plot_strip
	movem.l	(a4),a0-a3	;get 1st 4 pixels to clear
	moveq	#0,d7
	move.b	d7,(a0)		;clear 1st 2 pixels
	move.b	d7,160(a0)
	move.b	d7,320(a0)
	move.b	d7,480(a0)
	move.b	d7,1760(a0)
	move.b	d7,1920(a0)
	move.b	d7,2080(a0)
	move.b	d7,2240(a0)
	move.b	d7,(a1)		;clear 2nd 2 pixels
	move.b	d7,160(a1)
	move.b	d7,320(a1)
	move.b	d7,480(a1)
	move.b	d7,1760(a1)
	move.b	d7,1920(a1)
	move.b	d7,2080(a1)
	move.b	d7,2240(a1)
	move.b	d7,(a2)		;clear 3rd 2 pixels
	move.b	d7,160(a2)
	move.b	d7,320(a2)
	move.b	d7,480(a2)
	move.b	d7,1760(a2)
	move.b	d7,1920(a2)
	move.b	d7,2080(a2)
	move.b	d7,2240(a2)
	move.b	d7,(a3)		;clear 4th 2 pixels
	move.b	d7,160(a3)
	move.b	d7,320(a3)
	move.b	d7,480(a3)
	move.b	d7,1760(a3)
	move.b	d7,1920(a3)
	move.b	d7,2080(a3)
	move.b	d7,2240(a3)

	lea	scrbuff(pc),a0	;get font data
	add	d0,a0


	movea.l	a5,a1
	add	(A6)+,a1		;X+Y for 1st 2 pixels
	add	d0,a1
	
	move.l	a1,(a4)+		;save 1st 2 pix pos for cls
	
	move	#%0000000011000000,d7
	
	move.b	(a0),d1
	move.b	160(a0),d2
	move.b	320(a0),d3
	move.b	480(a0),d4
	move.b	640(a0),d5
	move.b	800(a0),d6
	and.b	d7,d1
	and.b	d7,d2
	and.b	d7,d3
	and.b	d7,d4
	and.b	d7,d5
	and.b	d7,d6
	move.b	D1,(a1)
	move.b	D2,160(a1)
	move.b	d3,320(a1)
	move.b	d4,480(a1)
	move.b	d5,640(a1)
	move.b	d6,800(a1)
	move.b	960(a0),d1
	move.b	1120(a0),d2
	move.b	1280(a0),d3
	move.b	1440(a0),d4
	move.b	1600(a0),d5
	move.b	1760(a0),d6
	and.b	d7,d1
	and.b	d7,d2
	and.b	d7,d3
	and.b	d7,d4
	and.b	d7,d5
	and.b	d7,d6
	move.b	d1,960(a1)
	move.b	d2,1120(a1)
	move.b	d3,1280(a1)
	move.b	d4,1440(a1)
	move.b	d5,1600(a1)
	move.b	d6,1760(a1)
	move.b	1920(a0),d1
	move.b	2080(a0),d2
	move.b	2240(a0),d3
	and.b	d7,d1
	and.b	d7,d2
	and.b	d7,d3
	move.b	d1,1920(a1)
	move.b	d2,2080(a1)
	move.b	d3,2240(a1)

	movea.l	a5,a1
	add	(A6)+,a1		;X+Y for 2nd 2 pix
	add	d0,a1
	
	move.l	a1,(a4)+		;save 2nd 2 pix pos for cls
	
	moveq	#%0000000000110000,d7
	
	move.b	(a0),d1
	move.b	160(a0),d2
	move.b	320(a0),d3
	move.b	480(a0),d4
	move.b	640(a0),d5
	move.b	800(a0),d6
	and.b	d7,d1
	and.b	d7,d2
	and.b	d7,d3
	and.b	d7,d4
	and.b	d7,d5
	and.b	d7,d6
	or.b	d1,(a1)
	or.b	d2,160(a1)
	or.b	d3,320(a1)
	or.b	d4,480(a1)
	or.b	d5,640(a1)
	or.b	d6,800(a1)
	move.b	960(a0),d1
	move.b	1120(a0),d2
	move.b	1280(a0),d3
	move.b	1440(a0),d4
	move.b	1600(a0),d5
	move.b	1760(a0),d6
	and.b	d7,d1
	and.b	d7,d2
	and.b	d7,d3
	and.b	d7,d4
	and.b	d7,d5
	and.b	d7,d6
	or.b	d1,960(a1)
	or.b	d2,1120(a1)
	or.b	d3,1280(a1)
	or.b	d4,1440(a1)
	or.b	d5,1600(a1)
	or.b	d6,1760(a1)
	move.b	1920(a0),d1
	move.b	2080(a0),d2
	move.b	2240(a0),d3
	and.b	d7,d1
	and.b	d7,d2
	and.b	d7,d3
	or.b	d1,1920(a1)
	or.b	d2,2080(a1)
	or.b	d3,2240(a1)


	movea.l	a5,a1
	add	(A6)+,a1		;etc ...
	add	d0,a1
	
	move.l	a1,(a4)+
	
	moveq	#%0000000000001100,d7
	
	move.b	(a0),d1
	move.b	160(a0),d2
	move.b	320(a0),d3
	move.b	480(a0),d4
	move.b	640(a0),d5
	move.b	800(a0),d6
	and.b	d7,d1
	and.b	d7,d2
	and.b	d7,d3
	and.b	d7,d4
	and.b	d7,d5
	and.b	d7,d6
	or.b	d1,(a1)
	or.b	d2,160(a1)
	or.b	d3,320(a1)
	or.b	d4,480(a1)
	or.b	d5,640(a1)
	or.b	d6,800(a1)
	move.b	960(a0),d1
	move.b	1120(a0),d2
	move.b	1280(a0),d3
	move.b	1440(a0),d4
	move.b	1600(a0),d5
	move.b	1760(a0),d6
	and.b	d7,d1
	and.b	d7,d2
	and.b	d7,d3
	and.b	d7,d4
	and.b	d7,d5
	and.b	d7,d6
	or.b	d1,960(a1)
	or.b	d2,1120(a1)
	or.b	d3,1280(a1)
	or.b	d4,1440(a1)
	or.b	d5,1600(a1)
	or.b	d6,1760(a1)
	move.b	1920(a0),d1
	move.b	2080(a0),d2
	move.b	2240(a0),d3
	and.b	d7,d1
	and.b	d7,d2
	and.b	d7,d3
	or.b	d1,1920(a1)
	or.b	d2,2080(a1)
	or.b	d3,2240(a1)

	movea.l	a5,a1
	add	(A6)+,a1
	add	d0,a1
	
	move.l	a1,(a4)+
	
	moveq	#%0000000000000011,d7
	
	move.b	(a0),d1
	move.b	160(a0),d2
	move.b	320(a0),d3
	move.b	480(a0),d4
	move.b	640(a0),d5
	move.b	800(a0),d6
	and.b	d7,d1
	and.b	d7,d2
	and.b	d7,d3
	and.b	d7,d4
	and.b	d7,d5
	and.b	d7,d6
	or.b	d1,(a1)
	or.b	d2,160(a1)
	or.b	d3,320(a1)
	or.b	d4,480(a1)
	or.b	d5,640(a1)
	or.b	d6,800(a1)
	move.b	960(a0),d1
	move.b	1120(a0),d2
	move.b	1280(a0),d3
	move.b	1440(a0),d4
	move.b	1600(a0),d5
	move.b	1760(a0),d6
	and.b	d7,d1
	and.b	d7,d2
	and.b	d7,d3
	and.b	d7,d4
	and.b	d7,d5
	and.b	d7,d6
	or.b	d1,960(a1)
	or.b	d2,1120(a1)
	or.b	d3,1280(a1)
	or.b	d4,1440(a1)
	or.b	d5,1600(a1)
	or.b	d6,1760(a1)
	move.b	1920(a0),d1
	move.b	2080(a0),d2
	move.b	2240(a0),d3
	and.b	d7,d1
	and.b	d7,d2
	and.b	d7,d3
	or.b	d1,1920(a1)
	or.b	d2,2080(a1)
	or.b	d3,2240(a1)
	
	rts


*---------
scroll
	tst	charcount
	bne.s	scroll_char
	move	#16,charcount
	
	movea.l	txt_ptr(pC),a0
	moveq	#0,d0
.get_char
	move.b	(a0)+,d0
	cmpa.l	#textend,a0
	bne.s	.no_wrap
	lea	text(pc),a0
	move.b	(a0)+,d0
.no_wrap
	move.l	a0,txt_ptr
	
	cmp.b	#"!"-"A",d0
	bne.s	n1
	lea	font+16*2*27(pc),A0
	bra.s	cchar
n1
	cmp.b	#" "-"A",d0
	bne.s	n2
	lea	font+16*2*30(pc),a0
	bra.s	cchar
n2
	cmp.b	#"."-"A",d0
	bne.s	n3
	lea	font+16*2*26(pc),a0
	bra.s	cchar
n3
	cmp.b	#"("-"A",d0
	bne.s	n4
	lea	font+16*2*28(pc),a0
	bra.s	cchar
n4
	cmp.b	#")"-"A",d0
	bne.s	n5
	lea	font+16*2*29(pc),a0
	bra.s	cchar
n5
	lsl	#5,d0

	lea	font(pc),a0
	add	d0,a0
	
cchar
	lea	charbuff(pc),a1
	
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)


scroll_char
	lea	charbuff(pc),a1
	lea	scrbuff,a2
	moveq	#15-1,d0
.loop
	lsl	(a1)+

i	set	152
	rept	20
	roxl	i(a2)
i	set	i-8
	endr
	
	lea	160(a2),a2
	
	dbf	d0,.loop
	
	subq	#1,charcount

	rts


*---------
txt_ptr	dc.l	text

charcount	dc.w	16

charbuff	ds.w	15*2
	
text	DC.B	"    "
	dc.b	"HOLY SHIT!!!!     THIS IS THE TOTALLY INSANE"
	DC.B	" TWO BIT VERTICAL AND ONE BIT HORIZONTAL BENDY SCROLL.....!!"
	dc.b	"       WROTE BY ME!         "
	DC.B	"LET US WRAP!!!               "
textend
	even


scr1	dc.l	$78000
scr2	dc.l	$70000

n_clsptrs	dcb.l	160,$70000
n_clsptrs2
	dcb.l	160,$78000

woff	dc.l	wave2

	dc.w	-1
wave	dcb.w	40,$1900
	dc.w	$1900,$19A0,$1AE0,$1B80
	dc.w	$1CC0,$1D60,$1EA0,$1F40
	dc.w	$2080,$2120,$21C0,$2300
	dc.w	$23A0,$2440,$2580,$2620
	dc.w	$26C0,$2800,$28A0,$2940
	dc.w	$29E0,$2A80,$2B20,$2BC0
	dc.w	$2C60,$2D00,$2DA0,$2E40
	dc.w	$2E40,$2EE0,$2F80,$2F80
	dc.w	$3020,$30C0,$30C0,$30C0
	dc.w	$3160,$3160,$3160,$3200
	dc.w	$3200,$3200,$3200,$3200
	dc.w	$3200,$3200,$3200,$3160
	dc.w	$3160,$3160,$30C0,$30C0
	dc.w	$30C0,$3020,$2F80,$2F80
	dc.w	$2EE0,$2E40,$2E40,$2DA0
	dc.w	$2D00,$2C60,$2BC0,$2B20
	dc.w	$2A80,$29E0,$2940,$28A0
	dc.w	$2800,$26C0,$2620,$2580
	dc.w	$2440,$23A0,$2300,$21C0
	dc.w	$2120,$2080,$1F40,$1EA0
	dc.w	$1D60,$1CC0,$1B80,$1AE0
	dc.w	$19A0,$1900,$1860,$1720
	dc.w	$1680,$1540,$14A0,$1360
	dc.w	$12C0,$1180,$10E0,$1040
	dc.w	$F00,$E60,$DC0,$C80
	dc.w	$BE0,$B40,$A00,$960
	dc.w	$8C0,$820,$780,$6E0
	dc.w	$640,$5A0,$500,$460
	dc.w	$3C0,$3C0,$320,$280
	dc.w	$280,$1E0,$140,$140
	dc.w	$140,$A0,$A0,$A0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	$A0,$A0,$A0,$140
	dc.w	$140,$140,$1E0,$280
	dc.w	$280,$320,$3C0,$3C0
	dc.w	$460,$500,$5A0,$640
	dc.w	$6E0,$780,$820,$8C0
	dc.w	$960,$A00,$B40,$BE0
	dc.w	$C80,$DC0,$E60,$F00
	dc.w	$1040,$10E0,$1180,$12C0
	dc.w	$1360,$14A0,$1540,$1680
	dc.w	$1720,$1860,$1900,$1900
	dc.w	$1900,$1900,$1900,$19A0
	dc.w	$19A0,$1A40,$1AE0,$1AE0
	dc.w	$1B80,$1C20,$1CC0,$1D60
	dc.w	$1EA0,$1F40,$1FE0,$2080
	dc.w	$21C0,$2260,$23A0,$2440
	dc.w	$2580,$2620,$2760,$2800
	dc.w	$28A0,$29E0,$2A80,$2BC0
	dc.w	$2C60,$2D00,$2DA0,$2E40
	dc.w	$2EE0,$2F80,$3020,$30C0
	dc.w	$30C0,$3160,$3160,$3200
	dc.w	$3200,$3200,$3200,$3200
	dc.w	$3200,$3160,$3160,$30C0
	dc.w	$30C0,$3020,$2F80,$2EE0
	dc.w	$2E40,$2DA0,$2D00,$2C60
	dc.w	$2BC0,$2A80,$29E0,$28A0
	dc.w	$2800,$2760,$2620,$2580
	dc.w	$2440,$23A0,$2260,$21C0
	dc.w	$2080,$1FE0,$1F40,$1EA0
	dc.w	$1D60,$1CC0,$1C20,$1B80
	dc.w	$1AE0,$1AE0,$1A40,$19A0
	dc.w	$19A0,$1900,$1900,$1900
	dc.w	$1900,$1900,$1900,$1900
	dc.w	$19A0,$19A0,$1A40,$1AE0
	dc.w	$1AE0,$1B80,$1C20,$1CC0
	dc.w	$1D60,$1EA0,$1F40,$1FE0
	dc.w	$2080,$21C0,$2260,$23A0
	dc.w	$2440,$2580,$2620,$2760
	dc.w	$2800,$28A0,$29E0,$2A80
	dc.w	$2BC0,$2C60,$2D00,$2DA0
	dc.w	$2E40,$2EE0,$2F80,$3020
	dc.w	$30C0,$30C0,$3160,$3160
	dc.w	$3200,$3200,$3200,$3200
	dc.w	$3200,$3200,$3160,$3160
	dc.w	$30C0,$30C0,$3020,$2F80
	dc.w	$2EE0,$2E40,$2DA0,$2D00
	dc.w	$2C60,$2BC0,$2A80,$29E0
	dc.w	$28A0,$2800,$2760,$2620
	dc.w	$2580,$2440,$23A0,$2260
	dc.w	$21C0,$2080,$1FE0,$1F40
	dc.w	$1EA0,$1D60,$1CC0,$1C20
	dc.w	$1B80,$1AE0,$1AE0,$1A40
	dc.w	$19A0,$19A0,$1900,$1900
	dc.w	$1900,$1900,$1900,$1900
	dc.w	$1900,$1900,$1900,$1900
	dc.w	$1900,$19A0,$19A0,$19A0
	dc.w	$1A40,$1A40,$1AE0,$1B80
	dc.w	$1C20,$1CC0,$1D60,$1E00
	dc.w	$1EA0,$1FE0,$2080,$21C0
	dc.w	$2260,$23A0,$24E0,$2580
	dc.w	$26C0,$2800,$28A0,$29E0
	dc.w	$2B20,$2BC0,$2D00,$2DA0
	dc.w	$2E40,$2F80,$3020,$30C0
	dc.w	$30C0,$3160,$3160,$3200
	dc.w	$3200,$3200,$3200,$3160
	dc.w	$3160,$30C0,$30C0,$3020
	dc.w	$2F80,$2E40,$2DA0,$2D00
	dc.w	$2BC0,$2B20,$29E0,$28A0
	dc.w	$2800,$26C0,$2580,$24E0
	dc.w	$23A0,$2260,$21C0,$2080
	dc.w	$1FE0,$1EA0,$1E00,$1D60
	dc.w	$1CC0,$1C20,$1B80,$1AE0
	dc.w	$1A40,$1A40,$19A0,$19A0
	dc.w	$19A0,$1900,$1900,$1900
	dc.w	$1900,$1900,$1900,$1900
	dc.w	$1900,$1900,$1900,$1900
	dc.w	$1900,$1900,$1860,$1860
	dc.w	$1860,$17C0,$17C0,$1720
	dc.w	$1680,$15E0,$1540,$14A0
	dc.w	$1400,$1360,$1220,$1180
	dc.w	$1040,$FA0,$E60,$D20
	dc.w	$C80,$B40,$A00,$960
	dc.w	$820,$6E0,$640,$500
	dc.w	$460,$3C0,$280,$1E0
	dc.w	$140,$140,$A0,$A0
	dc.w	0,0,0,0
	dc.w	$A0,$A0,$140,$140
	dc.w	$1E0,$280,$3C0,$460
	dc.w	$500,$640,$6E0,$820
	dc.w	$960,$A00,$B40,$C80
	dc.w	$D20,$E60,$FA0,$1040
	dc.w	$1180,$1220,$1360,$1400
	dc.w	$14A0,$1540,$15E0,$1680
	dc.w	$1720,$17C0,$17C0,$1860
	dc.w	$1860,$1860,$1900,$1900
	dc.w	$1900,$1900,$1900,$1900
	dc.w	$1900,$1900,$1900,$1900
	dc.w	$1900,$1860,$1860,$17C0
	dc.w	$1720,$1720,$1680,$15E0
	dc.w	$1540,$14A0,$1360,$12C0
	dc.w	$1220,$1180,$1040,$FA0
	dc.w	$E60,$DC0,$C80,$BE0
	dc.w	$AA0,$A00,$960,$820
	dc.w	$780,$640,$5A0,$500
	dc.w	$460,$3C0,$320,$280
	dc.w	$1E0,$140,$140,$A0
	dc.w	$A0,0,0,0
	dc.w	0,0,0,$A0
	dc.w	$A0,$140,$140,$1E0
	dc.w	$280,$320,$3C0,$460
	dc.w	$500,$5A0,$640,$780
	dc.w	$820,$960,$A00,$AA0
	dc.w	$BE0,$C80,$DC0,$E60
	dc.w	$FA0,$1040,$1180,$1220
	dc.w	$12C0,$1360,$14A0,$1540
	dc.w	$15E0,$1680,$1720,$1720
	dc.w	$17C0,$1860,$1860,$1900
	dc.w	$1900,$1900,$1900,$1900
	dc.w	$1900,$1900,$1860,$1860
	dc.w	$17C0,$1720,$1720,$1680
	dc.w	$15E0,$1540,$14A0,$1360
	dc.w	$12C0,$1220,$1180,$1040
	dc.w	$FA0,$E60,$DC0,$C80
	dc.w	$BE0,$AA0,$A00,$960
	dc.w	$820,$780,$640,$5A0
	dc.w	$500,$460,$3C0,$320
	dc.w	$280,$1E0,$140,$140
	dc.w	$A0,$A0,0,0
	dc.w	0,0,0,0
	dc.w	$A0,$A0,$140,$140
	dc.w	$1E0,$280,$320,$3C0
	dc.w	$460,$500,$5A0,$640
	dc.w	$780,$820,$960,$A00
	dc.w	$AA0,$BE0,$C80,$DC0
	dc.w	$E60,$FA0,$1040,$1180
	dc.w	$1220,$12C0,$1360,$14A0
	dc.w	$1540,$15E0,$1680,$1720
	dc.w	$1720,$17C0,$1860,$1860
	dc.w	$1900,$1900,$1900,$1900
	dc.w	$1900,$1900,$1900,$1900
	dc.w	$1900,$1900,$1900,$1860
	dc.w	$1860,$1860,$17C0,$17C0
	dc.w	$1720,$1680,$15E0,$1540
	dc.w	$14A0,$1400,$1360,$1220
	dc.w	$1180,$1040,$FA0,$E60
	dc.w	$D20,$C80,$B40,$A00
	dc.w	$960,$820,$6E0,$640
	dc.w	$500,$460,$3C0,$280
	dc.w	$1E0,$140,$140,$A0
	dc.w	$A0,0,0,0
	dc.w	0,$A0,$A0,$140
	dc.w	$140,$1E0,$280,$3C0
	dc.w	$460,$500,$640,$6E0
	dc.w	$820,$960,$A00,$B40
	dc.w	$C80,$D20,$E60,$FA0
	dc.w	$1040,$1180,$1220,$1360
	dc.w	$1400,$14A0,$1540,$15E0
	dc.w	$1680,$1720,$17C0,$17C0
	dc.w	$1860,$1860,$1860,$1900
	dc.w	$1900,$1900,$1900,$1900
	dc.w	$1900,$1900,$1900,$1900
	dc.w	$1900,$1900,$1900,$1900
	dc.w	$19A0,$19A0,$19A0,$1A40
	dc.w	$1A40,$1AE0,$1B80,$1C20
	dc.w	$1CC0,$1D60,$1E00,$1EA0
	dc.w	$1FE0,$2080,$21C0,$2260
	dc.w	$23A0,$24E0,$2580,$26C0
	dc.w	$2800,$28A0,$29E0,$2B20
	dc.w	$2BC0,$2D00,$2DA0,$2E40
	dc.w	$2F80,$3020,$30C0,$30C0
	dc.w	$3160,$3160,$3200,$3200
	dc.w	$3200,$3200,$3160,$3160
	dc.w	$30C0,$30C0,$3020,$2F80
	dc.w	$2E40,$2DA0,$2D00,$2BC0
	dc.w	$2B20,$29E0,$28A0,$2800
	dc.w	$26C0,$2580,$24E0,$23A0
	dc.w	$2260,$21C0,$2080,$1FE0
	dc.w	$1EA0,$1E00,$1D60,$1CC0
	dc.w	$1C20,$1B80,$1AE0,$1A40
	dc.w	$1A40,$19A0,$19A0,$19A0
	rept	2
	dc.w	$1900,$1860,$1860,$1860
	dc.w	$1860,$1860,$1860,$1860
	dc.w	$1860,$17C0,$17C0,$17C0
	dc.w	$1720,$1720,$1720,$1680
	dc.w	$1680,$15E0,$15E0,$1540
	dc.w	$1540,$14A0,$1400,$1400
	dc.w	$1360,$1360,$12C0,$1220
	dc.w	$1220,$1180,$10E0,$1040
	dc.w	$1040,$FA0,$F00,$E60
	dc.w	$E60,$DC0,$D20,$C80
	dc.w	$C80,$BE0,$B40,$AA0
	dc.w	$A00,$A00,$960,$8C0
	dc.w	$820,$820,$780,$6E0
	dc.w	$640,$640,$5A0,$500
	dc.w	$500,$460,$460,$3C0
	dc.w	$320,$320,$280,$280
	dc.w	$1E0,$1E0,$140,$140
	dc.w	$140,$A0,$A0,$A0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,$A0,$A0,$A0
	dc.w	$140,$140,$140,$1E0
	dc.w	$1E0,$280,$280,$320
	dc.w	$320,$3C0,$460,$460
	dc.w	$500,$500,$5A0,$640
	dc.w	$640,$6E0,$780,$820
	dc.w	$820,$8C0,$960,$A00
	dc.w	$A00,$AA0,$B40,$BE0
	dc.w	$BE0,$C80,$D20,$DC0
	dc.w	$E60,$E60,$F00,$FA0
	dc.w	$1040,$1040,$10E0,$1180
	dc.w	$1220,$1220,$12C0,$1360
	dc.w	$1360,$1400,$1400,$14A0
	dc.w	$1540,$1540,$15E0,$15E0
	dc.w	$1680,$1680,$1720,$1720
	dc.w	$1720,$17C0,$17C0,$17C0
	dc.w	$1860,$1860,$1860,$1860
	endr
	dc.w	$1900,$1900,$1900,$1900
wave2	ds.w	160


font	incbin	a:\2_pixel\2pixdst2.fon

scrbuff	ds.b	160*15
