* The Amazing(!) 1-bit horizontal scroll with 2-bit vertical distort.
* Fastly Coded by Tony B of The UNT (took just a couple of hours).
* It's the intro for Ledgers Vol. 6
* Stars by Manikin of TLB!
* Music by LAP, ripped by me!
*
* It will only run from AUTO folder on the diskversion!!
* If this is trouble then assemble to disk as devpac version!!
*
* This is the source to give away on Ledgers 6
* (uses my old startup codes!).
*
* You could save about 16 scanlines by preshifting the scroll!!!
*
* Have fun with it ...



diskversion	=	0	;0 = diskversion, -1 = devpac


	opt	o+,ow-

	IIF	diskversion	opt	x+



	movea.l	4(sp),a5
	pea	$200.w
	pea	(a5)
	pea	$4a0000
	trap	#1
	lea	12(sp),sp

	pea	0.w
	move	#32,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,oldstk+2
	
	bsr	setup		;screen display/protec.
	
	move.l	$44e.w,a0
	lea	-32000(a0),a1
cls_scr
	move	#7999,d3
	moveq	#0,d2
.cls_scr
	move.l	d2,(a1)+
	move.l	d2,(a0)+
	dbf	d3,.cls_scr
	
	move.l	$44e.w,a0
	move.l	a0,scr1
	lea	-32000(a0),a0
	move.l	a0,scr2
	
	moveq	#6,d7
fadein
	bsr	vsync
	bsr	vsync
	bsr	vsync
	bsr	vsync
	sub	#$111,$ffff8240.w
	dbf	d7,fadein
	
	bsr	black_out

*-------------------
	bsr	make_checks	;for carts/ste/meg!
*-------------------

	lea	wave,a0
	lea	wave2,a1
	move	#159,d0
cw
	move	(a0)+,(a1)+
	dbf	d0,cw
	
	movem.l	logo+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
*-------------------
	bsr	make_up_stars
*-------------------

	moveq	#1,d0
	bsr	music
	
	lea	logo+34,a2
	move.l	scr1,a0
	lea	8*7+800(a0),a0
	move.l	scr2,a1
	lea	8*7+800(a1),a1
	
	moveq	#36-1,d1
dl
i	set	0
	rept	7
	move.l	i(a2),i(a0)
	move.l	i+4(a2),i+4(a0)
	move.l	i(a2),i(a1)
	move.l	i+4(a2),i+4(a1)
i	set	i+8
	endr
	
	lea	160(a0),a0
	lea	160(a1),a1
	lea	160(a2),a2
	
	dbf	d1,dl


	bsr	set_ints		;save/install interrupts
	
		
*-------------------
scan
	bsr	vsync
	
	move.l	scr2(pc),logbase
	lea	old_stars(pc),a0
	movea.l	a0,a5

	bsr	erase_stars
	
	bsr	plot_stars

	bsr	scroll
	
	lea	n_clsptrs(pc),a4
	move.l	scr2(pc),a5
	lea	160*70(a5),a5
	bsr	mb_2pb
	
	bsr	music+$22
	
	move.l	scr2(pc),d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	bsr	vsync

	move.l	scr1(pc),logbase
	lea	old_stars2(pc),a0
	movea.l	a0,a5

	bsr	erase_stars
	
	bsr	plot_stars
	
	bsr	scroll
	
	lea	n_clsptrs2(pc),a4
	move.l	scr1(pc),a5
	lea	160*70(a5),a5
	bsr	mb_2pb
	
	bsr	music+$22
	
	move.l	scr1(pc),d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	
	cmp.b	#%111,bailflag
	beq	bailout	

	cmp.b	#57,kbuff
	bne	scan


*-------------------
	bsr	rem_ints		;remove interrupts

exit
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)

	move.l	$44e.w,a0
	lea	-32000(a0),a1

	move	#7999,d3
	moveq	#0,d2
.cls_scr
	move.l	d2,(a1)+
	move.l	d2,(a0)+
	dbf	d3,.cls_scr

	moveq	#6,d7
fadeout
	bsr.s	vsync
	bsr.s	vsync
	bsr.s	vsync
	bsr.s	vsync
	add	#$111,$ffff8240.w
	dbf	d7,fadeout
	
	bsr	old_setup		;install old vectors
	

oldstk	lea	0.l,sp


	ifne	diskversion
	clr	-(sp)
	move	#11,-(sp)
	trap	#13		;Alt-X cure!
	addq	#4,sp
	endc

	clr	-(sp)
	trap	#1



*-------------------
vsync
	move	$468.w,d0
.vsync
	cmp	$468.w,d0
	beq.s	.vsync
	rts


*------------------- new key handler!!!
newkey
	move	#$2500,sr
	clr.b	kbuff

	move.l	d2,-(sp)
	pea	(a2)
	
	lea	$fffffc02.w,a2
	move.b	-2(a2),d2
	btst	#7,d2
	beq.s	.exit
	btst	#0,d2
	beq.s	.clear
	
	bsr.s	.getbyte
	move.b	(a2),kbuff
.clear
	and.b	#$20,d2
	beq.s	.exit
	move.b	(a2),d2
.exit
	move.l	(sp)+,a2
	move.l	(sp)+,d2
	
	bclr	#6,$fffffa11.w
*	btst	#4,$fffffa01.w
*	beq.s	newkey
	
	rte

.getbyte
	cmp.b	#$2a,(a2)		;left shift pressed?
	bne.s	.shft0
	bset	#0,bailflag
	rts
.shft0
	cmp.b	#$aa,(a2)		;left shift depressed?
	bne.s	.shft1
	bclr	#0,bailflag
	rts
.shft1
	cmp.b	#$1d,(a2)		;ctrl pressed?
	bne.s	.ctrl0
	bset	#1,bailflag
	rts
.ctrl0
	cmp.b	#$9d,(a2)		;ctrl depressed?
	bne.s	.ctrl1
	bclr	#1,bailflag
	rts
.ctrl1
	cmp.b	#$61,(a2)		;undo pressed?
	bne.s	.hlp0
	bset	#2,bailflag
	rts
.hlp0
	cmp.b	#$e1,(a2)		;undo depressed?
	bne.s	.hlp1
	bclr	#2,bailflag
.hlp1
	rts


*-------------------
vbi
	move	#$2700,sr
	
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.l	#timer_b,$120.w
	move.b	#8,$fffffa1b.w
	
	move	#$766,$ffff8242.w

	addq	#2,co
	cmp	#42*2,co
	ble.s	ok1
	clr	co
ok1
	subq	#2,co2
	tst	co2
	bge.s	ok2
	move	#42*2,co2
ok2
	move.l	#colscroll,coloff
	
	move.b	#66,scl

	addq	#1,$468.w
	
	rte


*------------------- first raster beam
timer_b
	clr.b	$fffffa1b.w
	pea	(A0)
	lea	cols(pc),a0
	add	co(pc),a0
	rept	28
	move	(a0)+,$ffff8240.w
	endr
	clr	$ffff8240.w
	move.l	(sp)+,a0
	move.l	#timer_b2,$120.w
	move.b	#66,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

*------------------- the scroll rasters
timer_b2
	pea	(A0)
	
	subq.b	#1,scl
	tst.b	scl
	beq.s	l1
	
	clr.b	$fffffa1b.w
	
	move.l	coloff(pc),a0
	move	(a0)+,$ffff8242.w
	move.l	a0,coloff
	move.l	(sp)+,a0
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

* the bottom beam -they are very jerky, hope no one noticed?
l1
	pea	(a1)
	move	d0,-(sp)
	
	move.b	#240,$fffffa21.w
	
	lea	cols(pc),a0
	add	co2(pc),a0
	lea	$ffff8240.w,a1
	
	move.b	$fffffa21.w,d0
sink
	cmp.b	$fffffa21.w,d0
	beq.s	sink
	
	move	(sp)+,d0
	
	clr.b	$fffffa1b.w
	
	rept	42
	move	(a0)+,(a1)
	endr
	
	clr	(a1)
	
	move.l	(sp)+,a1
	move.l	(sp)+,a0

null_irq
	rte


*-------------------
make_checks
	move.l	#"FUCK",$80000	;meg?
	cmp.l	#"FUCK",$80000
	bne.s	.not_meg
	st	megflag
.not_meg
	cmp.l	#$e00000,$4.w	;ste?
	bge.s	.not_ste
	st	steflag
.not_ste
	cmp.l	#$fa52235f,$fa0000	;diagnostix cartridge?
	beq.s	.cartridge
	cmp.l	#$abcdef42,$fa0000	;user cartridge?
	bne.s	.no_cartridge
.cartridge
	bra	reset
	
.no_cartridge
	rts

	
*-------------------
setup
	ifeq	diskversion
	move.l	#$31415926,$426.w
	move.l	#reset,$42a.w
	endc
	
	movem.l	$8.w,d0-d7
	movem.l	d0-d7,old_vex
	movem.l	new_vex(pc),d0-d7
	movem.l	d0-d7,$8.w

	moveq	#$1a,d1
	bsr	ikbdsend
	
	moveq	#$12,d1
	bsr	ikbdsend
	
	clr.b	$484.w
	
	move.l	$44e.w,old44e+2
	move.b	$ffff8260.w,oldres+3
	
	tst.b	megflag
	beq.s	halfmeg
	move.l	#$f8000,$44e.w
	bra.s	mega
halfmeg
	move.l	#$78000,$44e.w
mega
	bsr	vsync
	clr.b	$ffff8260.w
	move.b	$44f.w,$ffff8201.w
	move.b	$450.w,$ffff8203.w
	move.b	#2,$ffff820a.w
	
	rts

	rts


*-------------------
old_setup
	ifeq	diskversion
	clr.l	$42a.w
	clr.l	$426.w
	endc

	movem.l	old_vex(pc),d0-d7
	movem.l	d0-d7,$8.w

	moveq	#$14,d1
	bsr	ikbdsend
	
	moveq	#8,d1
	bsr	ikbdsend
	
	move.b	#-1,$484.w
	
old44e	move.l	#0,$44e.w
	clr.b	$ffff820a.w
	bsr	vsync
oldres	move.b	#0,$ffff8260.w
	move.b	$44f.w,$ffff8201.w
	move.b	$450.w,$ffff8203.w
	move.b	#2,$ffff820a.w

	movem.l	gempal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts


*------------------- here come the star routs.
erase_stars
	move.l	logbase(pc),a1
	lea	160(a1),a1
	
	moveq	#0,d0
	
	rept	14		;clear 100 stars
	movem	(a0)+,d1-d7
	move	d0,(a1,d1.w)
	move	d0,(a1,d2.w)
	move	d0,(a1,d3.w)
	move	d0,(a1,d4.w)
	move	d0,(a1,d5.w)
	move	d0,(a1,d6.w)
	move	d0,(a1,d7.w)
	endr
	move	(a0)+,d1
	move	(a0)+,d2
	move	d0,(a1,d1.w)
	move	d0,(a1,d2.w)

	rts

*------------------- plot 100 stars
plot_stars
	lea	stars(pc),a0
	move.l	logbase(pc),a1
	lea	160(a1),a1
	
	moveq	#100-1,d0
	moveq	#-1,d1
drawstar
	move.l	(a0)+,a2

	move	(a2)+,d2		;get the offset
	cmp	d1,d2
	bne.s	cont
	move.l	(a0),-(a0)
	bra.s	drawstar
cont
	move	(a2)+,d3
	move.l	a2,-(a0)
	addq.l	#8,a0
	tst	(a1,d3.w)		;hey! neat idea Tony..?!
	bne.s	qw		;means i don't have to re-draw
				;the logo every vbl!!!!
	or	d2,(a1,d3.w)	;plot with screen
	move	d3,(a5)+		;keep star pos for erase next time!
qw	dbf	d0,drawstar
	rts


*------------------- construct stars
make_up_stars
	lea	stars(pc),a0
	moveq	#0,d0
	moveq	#85,d1
	
mk_lp	move.l	(a0),a1
	add.l	d0,a1
	move.l	a1,(a0)
	addq.l	#8,a0
	move.l	(a0),a1
	add.l	d0,a1
	move.l	a1,(a0)
	addq.l	#8,a0
	addq.l	#4,d0
	dbf	d1,mk_lp

	moveq	#0,d0
	moveq	#28-1,d1

mk_lp2	move.l	(a0),a1
	add.l	d0,a1
	move.l	a1,(a0)
	addq.l	#8,a0
	add.l	#12,d0
	dbf	d1,mk_lp2
	rts



*------------------- so here is the mega twisty-bendy-scrolly-shite!
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


*------------------- it should be fairly obvious ..!?
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


*------------------- the slow way, but it'll do ...
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
	
	cmp.b	#"!",d0
	bne.s	n1
	lea	font+16*2*27(pc),A0
	bra.s	cchar
n1
	cmp.b	#" ",d0
	bne.s	n2
	lea	font+16*2*30(pc),a0
	bra.s	cchar
n2
	cmp.b	#".",d0
	bne.s	n3
	lea	font+16*2*26(pc),a0
	bra.s	cchar
n3
	cmp.b	#"(",d0
	bne.s	n4
	lea	font+16*2*28(pc),a0
	bra.s	cchar
n4
	cmp.b	#")",d0
	bne.s	n5
	lea	font+16*2*29(pc),a0
	bra.s	cchar
n5
	sub.b	#"A",d0
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


*------------------- kick ass mr CPU
set_ints
	move	sr,save_sr
	move	#$2700,sr
	move.b	$fffffa07.w,mfp7+3
	move.b	$fffffa09.w,mfp9+3
	move.b	$fffffa13.w,mfp13+3
	move.b	$fffffa15.w,mfp15+3
	move.b	$fffffa17.w,mfp17+3
	move.b	$fffffa1b.w,mfp1b+3
	move.b	$fffffa21.w,mfp21+3
	move.l	$68.w,oldhbl+2
	move.l	$70.w,oldvbi+2
	move.l	$120.w,oldtimerb+2
	move.l	$118.w,oldkey+2
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	move.l	#newkey,$118.w
	bset	#6,$fffffa09.w
	move.l	#null_irq,$68.w
	move.l	#vbi,$70.w
	bclr	#3,$fffffa17.w
	move.l	#timer_b,$120.w
	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w
	move	save_sr(pc),sr
	rts


*------------------- safe again ....!!
rem_ints
	move	#$2700,sr
mfp7	move.b	#0,$fffffa07.w
mfp9	move.b	#0,$fffffa09.w
mfp13	move.b	#0,$fffffa13.w
mfp15	move.b	#0,$fffffa15.w
mfp17	move.b	#0,$fffffa17.w
mfp1b	move.b	#0,$fffffa1b.w
mfp21	move.b	#0,$fffffa21.w
oldhbl	move.l	#0,$68.w
oldvbi	move.l	#0,$70.w
oldtimerb	move.l	#0,$120.w
oldkey	move.l	#0,$118.w
	move	save_sr(pc),sr
	rts


*------------------- usual clear memory reset thingy!
reset
	ifeq	diskversion

	move	#$2700,sr
	move.l	$42e.w,sp
	
	lea	$ffff8240.w,a0
	rept	8
	clr.l	(a0)+
	endr

here	move.l	$42e.w,a0
	suba.l	#(reloc_end-reloc),a0
	movea.l	a0,a2
	lea	reloc(pc),a1
.reloc
	move.b	(a1)+,(a0)+
	cmpa.l	#reloc_end,a1
	blt.s	.reloc
	jmp	(a2)

reloc	move.l	$42e.w,a0
	sub.l	#(reloc_end-reloc),a0
.cls
	clr.l	-(a0)
	clr.l	-(a0)
	cmp.l	#8,a0
	bhi.s	.cls
reloc_end

	endc


*-------------------
black_out
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movem.l	d0-d7,$ffff8240.w
	rts


*------------------- byte in D1
ikbdsend
	lea	$fffffc00.w,a0
.ikbd
	move.b	(a0),d2
	btst	#1,d2
	beq.s	.ikbd
	move.b	d1,2(a0)
	rts


*------------------- guru exception handler!!
bombs	
	rept	8
	addq	#4,errno
	endr
bailout	
	bsr	rem_ints

	move	#1,-(sp)
	move.l	$44e.w,-(sp)
	move.l	$44e.w,-(sp)
	move	#5,-(sp)
	trap	#14

	clr	$ffff8240.w
	move	#$444,$ffff8246.w
	
	pea	gurumes(pc)
	move	#9,-(sp)
	trap	#1
	
	lea	errs(pc),a0
	add	errno(pc),a0
	move.l	(a0),a0
	
	move.l	a0,-(sp)
	move	#9,-(sp)
	trap	#1

	pea	butmes(pc)
	move	#9,-(sp)
	trap	#1
	lea	30(sp),sp
	
.wait
	cmp.b	#57,$fffffc02.w
	bne.s	.wait
	
	move	save_sr(pc),sr
	bra	exit


*---------

co	dc.l	cols
co2	dc.l	cols

cols	dc.w	0,1,2,3
	dc.w	4,5,6,7
	dc.w	$107,$207,$307,$407
	dc.w	$507,$607,$707,$706
	dc.w	$705,$704,$703,$702
	dc.w	$701,$700,$710,$720
	dc.w	$730,$740,$750,$760
	dc.w	$770,$670,$570,$470
	dc.w	$370,$270,$170,$70
	dc.w	$60,$50,$40,$30
	dc.w	$20,$10
	dc.w	0,1,3,4,5
	dc.w	6,7,$107,$207
	dc.w	$307,$407,$507,$607
	dc.w	$707,$706,$705,$704
	dc.w	$703,$702,$701,$700
	dc.w	$710,$720,$730,$740
	dc.w	$750,$760,$770,$670
	dc.w	$570,$470,$370,$270
	dc.w	$170,$70,$60,$50
	dc.w	$40,$30,$20,$10

coloff	dc.l	colscroll

colscroll	dc.w	2,3,4,5,6,7
	dc.w	$107,$207,$307,$407,$407
	dc.w	$507,$607,$707,$707,$706
	dc.w	$705,$704,$704,$703,$702
	dc.w	$701,$700,$700,$710,$720
	dc.w	$730,$740,$750,$750,$760
	dc.w	$770,$770,$670,$570,$470
	dc.w	$370,$370,$270,$170,$70,$70
	dc.w	$60,$50,$40,$30,$30,$20,$10

*---------guru text & shit!
errno	dc.w	0

errs	dc.l	bailmes
	dc.l	trcerr
	dc.l	priverr
	dc.l	trpverr
	dc.l	chkerr
	dc.l	diverr
	dc.l	illerr
	dc.l	addrerr
	dc.l	buserr


new_vex	dc.l	bombs
	dc.l	bombs+6
	dc.l	bombs+12
	dc.l	bombs+18
	dc.l	bombs+24
	dc.l	bombs+30
	dc.l	bombs+36
	dc.l	bombs+42

gurumes	dc.b	27,69,"     Guru: Software Failure!",10,10,13,0
butmes	dc.b	10,10,13,"     Bash space bar ...",0
bailmes	dc.b	"     ?? :Bailout Keys Pressed",0
buserr	dc.b	"     08 :Bus Error",0
addrerr	dc.b	"     0C :Address Error",0
illerr	dc.b	"     10 :Illegal Instruction",0
diverr	dc.b	"     14 :Division by Zero Error",0
chkerr	dc.b	"     18 :CHK Instruction",0
trpverr	dc.b	"     1C :TRAPV Instruction",0
priverr	dc.b	"     20 :Privilege Violation Error",0
trcerr	dc.b	"     24 :Trace",0
	even

gempal	dc.w	$777,$700,$070,$000,$007,$707,$077,$555
	dc.w	$333,$733,$373,$773,$337,$737,$377,$000

txt_ptr	dc.l	text

charcount	dc.w	16
	
text
	DC.B 	" WELCOME TO THE LEDGERS DISK MAGAZINE VOLUME SIX  CREATED BY THE UNTOUCHABLES OF THE ENTERPRISE AND FRIENDS .. "
	dc.b	" LOOK OUT FOR THE UNTOUCHABLES .. LIGHT SPEED DEMO .. RELEASED WITH THIS MAGAZINE (HOPEFULLY !)  "
	dc.b	" THE ONE BIT HORIZONTAL SCROLL WITH TWO BIT VERTICAL DISTORT WAS CODED BY TONY B OF THE UNTOUCHABLES !     "
	dc.b	" AND THE EVER POPULAR STARS WERE CODED BY MANIKIN OF THE LOST BOYS !     "
	DC.B	" YOU CAN FIND THE SOURCE CODE FOR THIS SCREEN SOMEWHERE ON THE DISK .."
	DC.B	"           "
        DC.B    " MY NAME IS MAT AND I PRODUCED THIS ISSUE OF THE LEDGERS SO LET ME TELL YOU A BIT ABOUT IT .. "
	DC.B	" I WOKE UP THIS MORNING TO FIND THIS INTRO KNOCKING ON THE DOOR BEGGING ME TO PUT IT ON THE DISK BUT"
	DC.B	" IT NEEDED AN SCROLL TEXT SO HERE I AM .. THIS ISSUE SHOULD HOPEFULLY BE RELEASED ON THE SEVENTH OF"
	DC.B	" DECEMBER AT THE COMPUTER SHOPPER SHOW  (IT HAS TO BE RELEASED EARLY OR IT WILL NEVER GET SPREAD IN"
	DC.B	" THE CHRISTMAS POST) .. IF YOU ARE READING THIS AND CHRISTMAS HAS BEEN AND GONE THEN SORRY BUT IF"
	DC.B	" YOU HAD SUBSCRIBED TO US THIS ISSUE WOULD HAVE ARRIVED IN PLENTY OF TIME !"
	DC.B	" THE LIGHT SPEED DEMO SHOULD BE RELEASED WITH THIS ISSUE OF THE MAGAZINE SO IF YOU HAVNT SEEN IT FIND"
	DC.B	" OUT WHY AND MAKE SURE SOMEONE GETS HURT !"
	DC.B	"           "
	DC.B	" NOTABLE STUFF ON THIS ISSUE IS .. A COUPLE OF ARTICLES THAT HIGHLANDER FROM THE PIXEL TWINS SENT WHICH"
	DC.B	" EXPLAIN ALL ABOUT EVERY KIND OF PICTURE STORAGE METHOD YOU WILL EVER NEED AND THE HOW THE INFORMATION"
	DC.B	" IN A MOD FILE IS SAVED ! .. THERE IS ALSO THE FUNNIEST ARTICLE EVER WHICH COMPARES THE LATEST LAPTOP"
	DC.B	" COMPUTERS TO THE UZI 9MM (JUST READ IT !) .. I HAVE NOT PUT ALL THE THINGS ON THIS ISSUE YET SO THERE"
	DC.B	" WILL CERTAINLY BE SOME OTHER COOL STUFF FOR YOU TO READ AND USE .. THE MAIN MENU IS ALMOST READY AND"
	DC.B	" USES THE SPRITES FROM MAGIC POCKETS WHICH HAVE BEEN SERIOUSLY EDITED TO ADD A SEASONAL ATMOSPHERE TO"
	DC.B	" MAGAZINE ASWELL AS THE LOST BOYS MINDBOMB MAIN MENU CODE AGAIN .. "
	DC.B	"           "
	DC.B	" IF YOU ARE TRAPPED HERE NOT KNOWING WHAT TO DO JUST PRESS SPACE TO GO TO THE DESKTOP (OR I MAY LINK"
	DC.B	" SEVERAL INTROS TOGETHER HERE .. IT DEPENDS HOW MANY INTROS I GET SENT BY THE TIME THIS DISK IS"
	DC.B	" RELEASED !"
	DC.B	"           "
	DC.B	" THIS VERSION EATS UP C.P.U. TIME IN A BIG WAY!!  IT COULD BE SPEEDED UP"
	DC.B	" BY PRESHIFTING THE SCROLL.  WHO GIVES A FUCK ANYWAY  IT WORKS DOESNT IT !!!!    "
	DC.B	" SO ............................. SMASH SPACE !             SMASH SPACE !              SMASH SPACE !"

	DC.B	"OK LETS GO FOR THE ...                      "
	DC.B	"RRRRRRRRRRRRRRRRRRRRAP!                                     "
textend
	even

scr1	ds.l	1
scr2	ds.l	1

n_clsptrs	dcb.l	160,$70000
n_clsptrs2
	ICE!  Ä  3lxB˝HEORY OF DARK¨?òUCKERS˙ÓØÅ=ó@ nSõ’ïJ+ÁPanûmlü¨œY@©é[±[Ãˆ 7˛sŒÄ
HÙäÂS)°‰Ö¶F›yZÔbÒÂwm›˚ijBã∆fÒ∞‚VÎÔW.-Zõ}”8f]Àr%;p1e·’ÇJ»ˆVÌÃ e∑’Y	wX1@∞Í8Øg&3Rùë∆8i-Îh¸ñ≥
€Ä˜nÄ7±ÁPÛÊ.≥“°ˇAíÓÔ"‡KâÕnu·´˝Wì-;‡ç¿GJÕ„ñ‰÷¡˜SylvÌ$iÒfÎw≠îW§f˛ù	O¿ª§5„Ëº‡J
..Y x O	ŒÖ‡ ºJπE5#!d©ﬂE´9∆Duqæb|l·ûå®õç◊Z≥qÇ)Äûéw ¢ÀQoH<Îíqj„@|ù=úv∆Î SomÆK7UºUÀÏio¿∂ä$qf∫dEvÄ N÷°∂&„éd%À∏ÅY49N_lÓƒrä6b≥lb|à·–ûåcµx»10d9˜Æ]q}Ù;nU/¿À‹‡ﬂL5ú9ßN¿pc.à9f\ı‰Á\¿ÎÄ1x! xıpÓ:÷π¬Éz›*º1:o‹ÖÆª1¿c‹x±Çe|¿õæŸŒ∞à$w»ûòë)‡Â“Õá hq¿ÃJg8}Nofi{Î«Ÿl≠5X6”°7∏>ôAåY,‚≤ºıñW3Æx' á£•œ9BY0ãîÉ„qˆO¿Û¿£€qÑ|.o¥
a8Îém—êÑç[¢C¢€N¿cÀsÀ¥»¿ﬂ°‹Ç√»}∆É= Öù5∑™[ ºŒÎm≠´ÍbeôOk]®q„ÿuéÎ%ùuÈÀæÕÚ«È◊Õïﬁa ‡A‘πR™¡·b*— äqÃ∏éÖWÌ¿”ÆxÑrÛÇq˙·/]Qõ:!¿uÎOd¯C∏&ö-à71s:œ5?é„‡q¶0303MéS£€ Ì¨-8GTF≠Û8Ä˜ﬂ3EXÛÓ…3“„m=f±27≥˚_á03ùx≤∫ŒïV-,sôµÏ
V*¨±sXˇÊäñ®∂)S3sne3ãôÑ“ìA8óXMuSO⁄Óan∂pi0oÇAˆ¡Ï7∆E‡ô¡ºß∏5çÉx% x	=a; ≥åY∆©ouàŸt›Ö‚åL‘uiÅXÂπ∏+∏Õ√	º∏y–“d ﬁ®-|Ω·¡∏¥]∂ÓfûxsyÎ¿É”¯pEÀ§ÈÕE)Vπï¨\ìtx.è¯€L'≈Xÿ1ä™g÷-ÀÓó*idÊ|ú=ÊløfVcöQk%9ãÜw≠pØÓœ	˛åéÿgaâπÃIg<ÀÕ/;∆9Œ-ñÕ∏yñà≥Lau»õ%2»ÂÅﬂuãEˆ¥KûÈÎåçœp¬of∫c√⁄3‡fIì7Nª,’êp’®xV~Qî’
3k*ﬂ6`AëDûs¿€Å¿É¢ΩÕ|HÚ∫!9◊ƒePP\xÂ≤‚vπÃ.âLS¿L¯/2úUzV¬∑»8'n7
åõwìf¥ œ»o∆pG◊°XÈb⁄Mt≠Á‰ñVÄ7)T1€6{78Ç±¨·‹l¿3“Yåƒä^?¿sÉıÜp∑aÇ(Àêñ‹4XÁÇ≠√:%æ•Ãmùdr!í€Ã¢bÁ-QfÀq+áqå∂Ó‡MœçLno&f≤pzM˙ÆOõÂ¬Ï_f´µaZ…t∏∑2ËXµƒ»ÿﬁ@cdUΩôÓÕdÑŸf∆µ¨M≈å≠bpÍ|KBc&¡"îcéÉ”˙¯T‹¿ã'üÿÄWKÖ7∏ÈŸÃM6Õ¸È‹æzéÄK‚¢¯ùv.¿ÎáqVÒŒå‡}¿©◊9º{åﬁŒÌ¬ÕfﬂAÕexamp‡1‰`ifÄìf”vA÷ëÿäÉx™6é$‡ƒo,‘Ã"bAÃ9_Yy0Î“uYhÍ⁄wpwp˚Ø[á$(Hasib€nä’I+g¬o5–88ª,în.‰,√%?QO°vKêcXxõ÷Ÿtw˘G∑Ã3)Ã¿ÜÏ“ûòv!Ä7v≥ma1≤@ØÖÁZà∆Z≤√óÄ
›«7ÅÀ
∆-‹îôúï[ç†x-0Cée€hôYÈ9$yw
aSÄÃ:`g6WŒxS7.F‡—“Û¨∂πΩ¡π¬lõ¨['ﬂh◊#fÿ´q+∞hf ^ïåá’(d‚ numõ[,D%/‡°ÕMNf%„DÊ‹%NeycnÜx˚≤ oÑn≈éfπ∞r1–∞¿CñRg≥&ËÄ` OlΩ—bµàV!≈8.^hÑquÄÕgIÃ8rn-fuå≤!∏‚mØ2f"aÙFñobUpdƒ≠BŒA÷UVs›B»üf]ÚÄ7!ôm›|bju›8ß!∑·nyu≥ú6£°xÑÔÉnw≥WÑ`](‹|a^ú/ˆö|·ffubms[»+j¨O##Å∑Ä’HìÃBÈúF£%H˝¨cÄabÂ6sëc%)8(ª+15≤\ï^Çt—Ì—:—ôÈÕeg2ÖÙ√Ì
£Å•$Ç≤ídqÕÃÑnnå6b≥◊B8∑
y©	L+7Ã§ÊF,¥dˆ50À=úk%( Çò)Qei 3Å;fW±nöuÆ)ñu,·X.éd9EuoìGrÎÖSÚ¿;´Åœ∫‘Äófvi3„…Mo<C-îníÅog‚E1¿alÃÎÄx`uPKizZûÑõùKî€&;+ V‹ b∞ﬁ3!ÙB@Iº≥¿cC§U9KŒ%»pm;8≠!f/p£áõ¿+àwhenÅZ/∞aZÃ‚Ä£ñúÃL&Ã`Ù–öí°¡ƒ‘Á8›‹h©Xaf,K–BìõáëÉVA¨≈ÙÎ8]‰áh{Vg´óLb_rÃ≤*\Pï	A¡r`¡¢iÏÿ¨äX1“Ö ï€Hm9eM-e˘v¯"4L(h®ÄÜ\‰Dä· n^\X&≤R(ÀusÕ9sTP; Nd≥áb))";w∑!mãÄI'ffb‰Që†Yh÷Ô†`Q“riÃGAî¨`ù$ÕH»h:à¿∏ÕkY9¡k‹»n~b¨IôEk
≠]∏a97-ó0a¶3h{tt7J≠ÜÇ}⁄Ω“á√è|∞î¬xe¡mJ∂dAœ*2Gsºœ2„Ü[õ6émŒÖTH¨´∞.Jå§5¨% p l2'ãOp^èåL¿n∏üR>v≤Z‰Æb‹ú4≈!d.é4i`Spad‘@…Ld{p)!‡Vpid”?“ÆÕ»“°óf¢ù ;7öóoŸyXê¸gpl"ñå5"D∑/0Ô?‡°I®4Ñ1wl‚ú#îÂWLºsawly≠´ Oi˚À4∆A¬∏3go9o…Z◊8(ZsŸ§$¶p.)!ó¿MŒëi’vV Cx^†s¿úµâÄõ‹<'e0.C4‹âÅnuÂ™©Xq{†;ªo/]à¿¢rJêOº?ò}[*‹ärawÓ$“Ô`∏h§0 n	N Gg!b≥5ª3ç¬ ∆t5l√7Œ`AieCDÅábbÉ1ãDLhûYP<MÛ -°√πÈô z–B‰êaÕwÖ,V$HaC67¨W<igú∞¿‰R3rñ	b9)Ú#ÿ6ÇcÖsejpã¡Tl‰Ø–aüÖS2öbje™níîoccup >árspacwXé‡añi"‹D y2ˆnobfeeûnôÉ
Uà9Ue,1ÿ cà…ÂB\se5¶è`t‚*3logicalÿOoPAsFâÜHŸ	Ãf≈
ëJan≈ighΩ POvK las>A+Lê ‡)‡movemy∞Sê.ãWh¬9iTBtby-˙pDqcêofb s?<ﬂHA	agaÍJ
TòAfopád»Ü¨+ gen,eAÖd_H its`_operation, ÿ_ckï≥dk f£m the surrounding area.

˛‡~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |  |
        ...:::///  THE ANCIENT HISTORY OF THE COWS  \\\:::...

             Part 5 of the 5-part COMPLETE GUIDE TO COWS!
                  ___________________________
         (__)    /                           \      * OFFICIAL EDITION *
         (oo)   ( Remember when I was a calf? )
  /-------\/  --'\___________________________/     * SUMMER 1991 ISSUE! *
 / |     ||
*  ||----||             Edited by David A. Bader
   ^^    ^^             Please send your submissions to:
     Cow                dbader@scarecrow.csee.lehigh.edu

=  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =

                      THE BIRTH OF THE COWS
           (in the words of Stephen L. Schultz, the Creator)

=  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =

Now, as for how it all started.  Well, I ICE!  ®  ]Ë»]x: TpÆ◊[øG¨Z‘† xÅ	=ºïMr◊hS¸lÜŒÆGe…g≥öi√ç4∆¿ –l2”2£€àxb≥7î2#™Yûl÷:Ù∏a}#”G∑
efBç«-™f¿¥D+8V-î;Ä«,7KÏ´aÅb3ë Sxct,ùp”…ïJaP¨Xy1Éõ€Õ`Ubt€aî6éy∆ŸhåYÈ¿ì†Tô©¿M÷˝ƒÏEõ¨¿õÖ	x 0ÇÛ0ÑâYÈ∂¥f5nH˙∏)yP≈ò·–daÚûîr»üöPÉd5‡Br8∆e≠ö≈Ö„ˆ ≤mhÛ-ËAG¿≥—P±R∫˛˙Ä˜A"WøF‡∆ Iº›uNf·≤÷d•¬≠òñéÃHei ‡E¿fj/*D„∆ÃÌ÷´ ‡”L\ŒgfÄÁ
¥4B ÉWÎCnò„0+è's£…~ Ñ¶ff'∂ËúOúrã'c2À™õ¿KôqYxû`’“Éwm0ÆW∆5◊iz8[h\,˜6Á|Ì“·Y›‡õY◊∫bó!vÙ;6 o2n’µœä3ÄÂ;ÁgÜiOZâick:ëgcfbSﬁY—9vDj*„pl\xK¯frJBÅwn?:f!<Ï€ÃLnÜzb5í“©õn¨X`‚ Ö˜¿ÀâdŸ'∫Ä◊á°≈Ç+Ç¡¢erﬁ‘ºMQÇq¡µ∂`&If∑±Ó@UÕËeEÁst‹"â≤äµ`ôµÕlÏtlb”eôomèı42N^Œ]⁄™ÉxHtîR0J¨AÆ∑‡YÕLåH‡ÇbﬁC•´[TÃoIáå£2á3πö=¬öâx±u≤Ao>«ç5n*dam~¬∂	gof¶qˇ≤î©VëÜ§I¿9Ga zipÕ˚pí!YÜ0agÛbÉÇ±Ç (	el0	àu3f,Üy¶•ypK~úµ–`]äå»†ú=Ã∏h∂7ÀZQXçÀLõÖ€‡mîÉ√ùqEft„lÒáqﬂ$´ùµ*¨T*ÂRÃrFfRB°a'√a^Ñ¿´«la∂!ö4s†1(F≥≠kD°uFe≥)‡V O2√ÄqjqÓâ˚Çs:tÓö(`∂≥™9¶.)ô∆±xÜxi0s{56≥ `Uka⁄7aìÅ,¿N"ë≥¥´>bVB∏1ÔÉbrñ˚	R∆—√LZŒ!abptà˙Ò.Ö(·vE	H4o∆˝√Ïçq;ÑyáÔI:R¶f¨õ§s õc·√<,r,ØÃ†Ì'VVl4K,·lµÅo˝†£o‚œ£∆ã1Õ8"wY≥l\V(å;‘æ˙tc¡(≤)ÎÄ÷becausŸ{ dí9Êb63)yedíNavyˆ±ò% ßngÓìU⁄ah6GfqÓ∆Õk@0ÀÉïB≤"eR)í£@soar5XÂ\/Ãewif√geòedÜq∞±™‡A]!ò% =QÑÅòÖêµÌY‡gÒ#'x2c÷l§∆ï¡πr <Sª2¢'¢Xk-S∞bld,[ËNo,'§t  ≥L≈2bˆ	W,G%bWv{‡îË¢bHÖwôîXª£Œbñ1is⁄`fclub∆KÛ\ŸW’Ñôn≠Ñs'&wæaÌãV,T	(9!r±‡.Är>'q3ö+X0œÅ‡∞q¡8`Üe-"ÿc<ºòc˝recidiJßÎ…bl!âaF Di€§bmîDÅuïáÇo¢}putÌ•ÃH÷aâ<ZïÈiYfirn&X. ÿ.åh®;«†x‰seÔÃ±Xëº#wasg◊`Ulk‚9Ae.Ã&AfÏr %Dãâ‹&s@ñhH.L»‹HY∞Sy»"Ñe$)y£¶ can'¯^™¡4Ïd∞iqîê$"rwƒç,$åXbp"¸XAmÄgÇEsÍmak·û*one*·+!¥Br¿es”ädùkn0CâçnI'm ‘"¥†eighteenhe?"QõH∏`,ã"!flagll!;."Ê¿  Thaºwoul¡5bîjust my luck,ÈO I said to HELL with golf.A·ÄDave Crowley
ˇ¿-
æ¿ued to
make up more.

Meanwhile, unbeknownst to me, Adam Stein, a house member who was cooping
at Xerox, took copies of them and posted them to rec.humor there.
Because at the time, CSH did not have a full news feed, and only got
incoming news, nothing went back out.  Adam one day forwarded me some
letters of people praising the cows. wãdp7¥ ldÀœZ-ºXAa2#î$¯iqnL‘sixöà^$â‡·—"ÕFÈÜC)∞lÃl[”‘f…d‹2D^
P4c±Å‡aH)çòõ	Ãf
œ2ÉÖpJ—‰ΩQ-JB‹ÓYhPb¨¥ÈH"àÀ¨Kö6a« Dâ
Fa÷ôÅgoô1?O±Ñ‹Nô"•(ñî∞ba∞eDocl+HQk-°ƒ√‡M¬clíà‹Œ‰F/hT:—≥z∞>wªv≤eR¨ìá't∆‘¯ÃD$"VÅêBLookXßìπt5> hº.d-boN2ëeggl ôCUÉ5C@V†ñLduíYF^∆m-Ársur∑”∏»åM¨ HitÚüX€ÿöƒ?(C Cm:ƒNod(b)Ik÷Ã%U÷ÉÕ'¨’Ä»íA¨S˛±ÃBeƒ∞FZËrìÒ of1ª¶ïπÌ¿Öå,zà˘ìunõ·Ëd®nfu4L¿SïŸÜhi3.∏≠∏ ô¬vö.{±ÓcŸ≈8S∏1¡˙°YÄ7ãOÓ
n1ìê≥`í¢Òëlï;ghf–ã[.ÊQ|`H|¿√A¿ìÑı0ª"fÎ_,‚fX4,>å¸M y^ó8Äw@p±`N}Å[[,bÀ¿0Xâ}ƒà•9€'“Çí∞ÁALgƒ90ÉWXioÎéz:kX2ÿöi§É%AπÛ m´Ñ&:‰`’ëƒî("OpjMnp?$+≥"˜Çì.tr32q‡bUÅá	√záï!ÑvÃÉUk
Œz0Tº¢'Dc/'úƒ,€ o|rt«"Œ%GlsË)2nú¿¬Üï'¥c#ul–mKhSE∑b7	"&òxçÚ+M¡C´rk‡<ò‡µääXìÕ$â7©¬L√BnwWËõÈv√+coXf£g1Çb3ïía¿#'ÜñÇV&∞n3’Pp§+]âå»y°.e“H&mwYR[Ç"s§ xﬂDe“åÿuse.È%FÊPxa!c`Cm“P20-]n")-ol‘ps2X,R‡˝∞n¢ï§£1m ´simpnaD! $åkÙ0Òa∂b†EaV ‡wµhouhgetÜNmosvÅit2hy‘Çî¿is·fr+ cap¯é—of mrect-dialêøg Ok¿awa‘+:d prob˙yÍa°	Ã In€not¢pyear, he'll bÙ'ablËto order magazine subscriptions.

àäˇÄople.  It really is
kind of neat.

Who'd of thunked it? :)

                                                - Steve
ough some people like to customize their cows:


         (__)                                               \
         (oo)                                                \
  /-------\/                                  (__)            \__)
 / |     ||        /---_  (__)                (oo)            (oo)
*  ||----||       / |   -_(oo)     /-----------\[]    /--------\/
  OOO    OOO     *  ||-_  |\/     / |         |[]    /|=======||     *    U
 O   O  O   O       ||  -_||     *  ||--------||    * ||------||(     \---V
  OOO    OOO        OO    OO  