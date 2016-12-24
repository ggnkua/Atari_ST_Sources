
*Eyop Martin... I've done a slight modification to the code so that the
*switch is done exclusively on the VBL when a reset is done.
*I haven't saved this so save it uder WISCROL3 or summat if you want.
*Oh,by the way,I've found out how to do 3430 sprites in a frame
*without having to resort to using ketchup.










* Reset screen for the Inner Circle Decade Demo programmed by:
* THE PHANTOM of Electronic Images.
*
* Music by COUNT ZERO of Electronic Images. (About time, too!)
*
* Phew! Music is now called from the last HBL! (bloody border removal!)
*
* Bloody well hope this vurks on Stewart's machine! Aaaagg!
*
* Now has cosine waves for balls (oo-er!) and tweens between different
* waveforms! Tweens are adjustable, but are set at 6 seconds display per
* waveform AFTER tween (some take longer to tween).
*
* STE timing bugs fixed by The Caped Crusader... 12/04/90
*
* JOSE, Right the lines I had to change are
*
* 716 I removed the .w from the end of $134.w
* 795 Same as line 716
* 
* Right the first nop (at line 787) is now set to 37
* The second nop (at line 791) is now set to 27

demo	equ 0

	opt o+,ow-

	ifeq demo
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	endc

	move.w	#$2700,sr		* Off with all interrupts.
	lea stack(pc),sp
	move.l	#$31415926,$426.w
	lea reset(pc),a0
	move.l a0,$42a.w
	clr.b $fffffa07.w
	clr.b $fffffa09.w
	clr.b $fffffa13.w
	clr.b $fffffa15.w
	lea	screen(pc),a0		* My screen!
	move.l	a0,d0			* Store it in D0 for calcs.
	add.l	#256,d0			* Align address to 256 boundary.
	clr.b	d0			* And take off that crummy byte!
	move.l	d0,scrnpos		* Store address.
	add.l	#32000,d0		* Add 32000 bytes for screen 2.
	move.l	d0,s1
	add.l	#3360,s1
	add.l	#8960*2,d0
	move.l	d0,scrn2		* And store that address.
	add.l	#32000,d0		* Add 32000 bytes for data.
	move.l	d0,s2
	add.l	#3360,s2
	add.l	#8960*2,d0
	move.l	d0,bkadd		* And store that!

	move.l	scrnpos(pc),d0
	lea	erase1(pc),a0
	lea	erase2(pc),a1
	rept	11
	move.l	d0,(a0)+
	move.l	d0,(a1)+
	endr				* Save me crashing!

	move.l	scrnpos(pc),a0
	move.w	#6239,d0
	moveq.l	#0,d1
clean:	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra	d0,clean		* Clear both screens.


	move.l	bkadd(pc),a1
	lea	nasty(pc),a0
	rept	32
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr				* Copy nasty sprite to preshift.
	
	move.l	bkadd,source		* Source of preshift.
	move.l	a1,dest			* Destination of preshift.
	move.w	#3,chunks		* Number of chunks (16 pixel).
	move.w	#32,lines		* Number of lines per chunk.
	move.w	#15,times		* How many preshifts.
	move.w	#1,scroll		* Scroll rate of preshift.
	bsr	pshift			* Preshift nasty.
	move.l	a1,baddr1		* Store end address.

	move.l	bkadd,source		* Source of data (sprite(s)).
	move.l	baddr1,dest		* Destination of masks.
	move.w	#3,chunks		* Number of chunks (16 pixel).
	move.w	#32,lines		* Number of lines per chunk.
	move.w	#16,times		* How many masks (16!).
	bsr	maskit			* Mask nasty/ies.
	move.l	a1,moffs		* Store end address.
	
	move.w	#16-1,d1
	moveq.l	#0,d0
calcoff:move.l	baddr1(pc),a0
	move.l	d0,d2
	mulu	#384,d2
	adda.l	d2,a0
	move.l	a0,(a1)+
	addq.l	#1,d0
	dbra	d1,calcoff		* Calculate offsets for masks.
	move.l	a1,spoffs
	
	move.w	#16-1,d1
	moveq.l	#0,d0
calcof2:move.l	bkadd(pc),a0
	move.l	d0,d2
	mulu	#768,d2
	adda.l	d2,a0
	move.l	a0,(a1)+
	addq.l	#1,d0
	dbra	d1,calcof2		* Calculate offsets for sprites.

	move.l	a1,shifts

	lea	ysin(pc),a0
	move.w	#512-1,d0
premul:	moveq.l	#0,d1
	move.w	(a0),d1
	mulu	#160,d1
	move.w	d1,(a0)+
	dbra	d0,premul		* Pre calculate Y offsets.	
	
*	(a1 contains address stored previously in SHIFTS)
	lea	xsin(pc),a0
	move.w	#512-1,d0
prmlx:	moveq.l	#0,d1
	move.l	d1,d2
	move.w	(a0),d1
	move.w	d1,d2
	and.b	#%11110000,d1
	lsr.w	#1,d1
	move.w	d1,(a0)+
	and.w	#$f,d2
	move.w	d2,(a1)+
	dbra	d0,prmlx		* Pre calculate X offsets.
	ifeq demo
	move.b	$fffa07,sa1
	move.b	$fffa09,sa2
	move.b	$fffa13,sa3
	move.b	$fffa19,sa4
	move.b	$fffa1f,sa5
	move.b	$fffa21,sa6
	move.b	$fffa1b,sa7		* Save necessary MFP regs.
	move.b	$fffa15,sa8
	move.b	$fffa1d,sa9
	move.b	$fffa25,sa10
	move.l	$70.w,oldvbl
	move.l	$120,oldhbl
	move.l	$134,asave
	endc

	bclr.b	#3,$fffffa17.w
	move.l	#vbl,$70.w
	move.l	#a_int,$134
	or.b	#%00100001,$fffffa07.w
	or.b	#%00100001,$fffffa13.w
	clr.b $fffffa19.w
	clr.b $fffffa1b.w
	move.l	#hbl,$120.w
	move.b	#3,$fffffa21.w

	lea	text(pc),a5
	moveq.l	#0,d7
	move.b	(a5)+,d7
	sub.b	#32,d7
	lsl.w	#3,d7
	move.l	d7,savd1
	move.l	d7,savd12
	moveq.l	#0,d6
	move.l	#1,savd6
	move.b	#4,savd5
	move.b	#4,savd52
	move.l	a5,sava5
	move.l	a5,sava52

	movem.l pal(pc),d0-d7
	movem.l d0-d7,$ffff8240.w
	lea brasts(pc),a3
	lea $ffff8240.w,a4
	MOVEQ.L #1,D0
	BSR mus

reset:	move.w	#$2700,sr
	lea stack(pc),sp
	lea	$ffff8240.w,a0
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	lea	init,a0
	bsr	ksend
	move.l	#$31415926,$426.w
	move.l	#reset,$42a.w
	move.l	#vbl2,$70.w
	move.w	#$2300,sr
	move.b	lcount(pc),d0
syncr:	cmp.b	lcount(pc),d0
	beq.s	syncr
	move.b	lcount(pc),d0
syncbl:	cmp.b	lcount(pc),d0
	beq.s	syncbl
	lea	$ffff8240.w,a0
	lea	pal(pc),a1
	rept	8
	move.l	(a1)+,(a0)+
	endr
	move.w	#$2700,sr
	
	lea	$ffff8240.w,a4
	move.l	#vbl,$70.w
	move.w	#$2300,sr

	
key:	move.b	lcount(pc),d0
sync:	cmp.b	lcount(pc),d0
	beq.s	sync			* Wait for VBL signal sync.

*	move.w	#$777,$ff8240		* For timing purposes.

	tst.b	flip
	bne.s	zeroi
	move.b	#1,flip
	bra.s	gonast
zeroi:	move.b	#0,flip
gonast:

	tst.b	flip
	bne.s	pescr2
	lea	erase1(pc),a2
	bra.s	wacko
pescr2:	lea	erase2(pc),a2
wacko:	moveq.l	#0,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	rept	11
	move.l	(a2)+,a0
	movem.l	d1-d6,(a0)
	movem.l	d1-d6,160*1(a0)
	movem.l	d1-d6,160*2(a0)
	movem.l	d1-d6,160*3(a0)
	movem.l	d1-d6,160*4(a0)
	movem.l	d1-d6,160*5(a0)
	movem.l	d1-d6,160*6(a0)
	movem.l	d1-d6,160*7(a0)
	movem.l	d1-d6,160*8(a0)
	movem.l	d1-d6,160*9(a0)
	movem.l	d1-d6,160*10(a0)
	movem.l	d1-d6,160*11(a0)
	movem.l	d1-d6,160*12(a0)
	movem.l	d1-d6,160*13(a0)
	movem.l	d1-d6,160*14(a0)
	movem.l	d1-d6,160*15(a0)
	movem.l	d1-d6,160*16(a0)
	movem.l	d1-d6,160*17(a0)
	movem.l	d1-d6,160*18(a0)
	movem.l	d1-d6,160*19(a0)
	movem.l	d1-d6,160*20(a0)
	movem.l	d1-d6,160*21(a0)
	movem.l	d1-d6,160*22(a0)
	movem.l	d1-d6,160*23(a0)
	movem.l	d1-d6,160*24(a0)
	movem.l	d1-d6,160*25(a0)
	movem.l	d1-d6,160*26(a0)
	movem.l	d1-d6,160*27(a0)
	movem.l	d1-d6,160*28(a0)
	movem.l	d1-d6,160*29(a0)
	movem.l	d1-d6,160*30(a0)
	movem.l	d1-d6,160*31(a0)
	endr


	tst.b	flip
	bne.s	pscr2
	lea	erase1(pc),a2
	bra.s	ccod
pscr2:	lea	erase2(pc),a2

ccod:	move.l	shifts(pc),a5
	move.l	scrn2(pc),a1
	lea	xsin(pc),a6
	move.w	addx(pc),d2
	adda.w	(a6,d2.w),a1
	move.w	(a5,d2.w),d1
	add.w	xinc(pc),d2
	and.w	#%0000001111111111,d2
	move.w	d2,addx
	lea	ysin(pc),a6
	move.w	addy(pc),d2
	adda.w	(a6,d2.w),a1
	add.w	yinc(pc),d2
	and.w	#%0000001111111111,d2
	move.w	d2,addy

	move.w	addx(pc),xstemp
	move.w	addy(pc),ystemp

	tst.b	flip
	bne.s	scr22
	lea	erase1(pc),a2
	bra.s	pnast2
scr22:	lea	erase2(pc),a2
pnast2:

* Put NASTY sprite 1.

	move.l	a1,(a2)+		* Store address for first erase!


puti2:	move.l	spoffs(pc),a0		* Get sprite address.
	lsl.w	#2,d1			* 768 bytes per mask (D1 used).
	move.l	0(a0,d1.w),a0		* Add shift data offset for sprite.
mvadd	set	0
	rept	32
	movem.l	(a0)+,d1-d6		* Get 3 chunks (4 planes each!).
	movem.l	d1-d6,mvadd(a1)		* Put it quickly.
mvadd	set	mvadd+160		* Inc screen address.
	endr

	moveq.w	#10-1,d7

	move.w	addx(pc),xstemp
	move.w	addy(pc),ystemp


nexnast:move.l	scrn2(pc),a1
	move.l	shifts(pc),a5
	lea	xsin(pc),a6
	move.w	addx(pc),d2
	add.w	xsepr(pc),d2
	and.w	#%0000001111111111,d2
	adda.w	(a6,d2.w),a1
	move.w	(a5,d2.w),d0
	move.w	d0,d1
	add.w	xinc(pc),d2
	and.w	#%0000001111111111,d2
	move.w	d2,addx
	lea	ysin(pc),a6
	move.w	addy(pc),d2
	add.w	ysepr(pc),d2
	and.w	#%0000001111111111,d2
	adda.w	(a6,d2.w),a1
	add.w	yinc(pc),d2
	and.w	#%0000001111111111,d2
	move.w	d2,addy


* Put rest of NASTY sprites.

	move.l	a1,(a2)+		* Store address for erase!


	move.l	spoffs(pc),a0		* Get sprite data address in A0.
	add d0,d0
	add d0,d0
	move.l	0(a0,d0.w),a5
	move.l	moffs(pc),a0		* Get mask data address.
	add d1,d1
	add d1,d1
	move.l	0(a0,d1.w),a0		* Add shift data offset for mask.
	rept	32			* 32 lines high.
	movem.l	(a1),d1-d6		* Get 3 chunks (2 planes each!).
	move.l (a0)+,d0
	and.l	d0,d1
	and.l	d0,d2
	or.l	(a5)+,d1
	or.l	(a5)+,d2
	move.l (a0)+,d0
	and.l	d0,d3
	and.l	d0,d4
	or.l	(a5)+,d3
	or.l	(a5)+,d4
	move.l (a0)+,d0
	and.l	d0,d5
	and.l	d0,d6
	or.l	(a5)+,d5
	or.l	(a5)+,d6
	movem.l	d1-d6,(a1)
	lea	160(a1),a1
	endr				* Do for 32 lines.
	
	dbra	d7,nexnast

	move.w	xstemp(pc),addx
	move.w	ystemp(pc),addy

	move.w	#0,d0
	move.b	#%11111111,d1

	tst.b	fscrol
	bne	scnum2

	move.b	#1,fscrol
	move.l	savd62,d6
	move.l	s1,a5
	move.l	a5,a6
	addq.l	#8,a5
	move.b	#8,savd0
nxlin:
woff	set	0
	rept	19
	move.w	woff(a5),d7
	move.w	d7,woff(a6)
	move.w	d7,woff+160(a6)
	move.w	d7,woff+320(a6)
	move.w	d7,woff+480(a6)
woff	set	woff+8
	endr
	lea	640(a5),a5
	lea	640(a6),a6
	subq.b	#1,savd0
	bne	nxlin
	
	move.l	s1,a5
	lea	152(a5),a5
	lea	chars,a6
	adda.l	savd1,a6

	move.b	#8,savd0
nxtln:	move.w	d0,(a5)
	move.w	d0,160(a5)
	move.w	d0,320(a5)
	move.w	d0,480(a5)
	move.b	(a6),d7
	lsl.b	d6,d7
	btst	#7,d7
	beq.s	nol1
	move.b	d1,(a5)
	move.b	d1,160(a5)
	move.b	d1,320(a5)
	move.b	d1,480(a5)
nol1:	btst	#6,d7
	beq.s	nol2
	move.b	d1,1(a5)
	move.b	d1,161(a5)
	move.b	d1,321(a5)
	move.b	d1,481(a5)
nol2:	
	lea	640(a5),a5
	addq.l	#1,a6
	subq.b	#1,savd0
	bne.s	nxtln
	addq.l	#2,d6
	
	subq.b	#1,savd5
	bne	nonew
	move.l	sava5,a5
	tst.b	(a5)
	bne.s	nowrap
	lea	text,a5
nowrap:	moveq.l	#0,d7
	move.b	(a5)+,d7
	sub.b	#32,d7
	lsl.w	#3,d7
	move.l	d7,savd1
	moveq.l	#0,d6
	move.b	#4,savd5
	move.l	a5,sava5
	
nonew:	move.l	d6,savd62
	bra	ohnosc

scnum2:	move.b	#0,fscrol
	move.l	savd6,d6
	move.l	s2,a5
	move.l	a5,a6
	addq.l	#8,a5
	move.b	#8,savd0
nxlin2:
woff	set	0
	rept	19
	move.w	woff(a5),d7
	move.w	d7,woff(a6)
	move.w	d7,woff+160(a6)
	move.w	d7,woff+320(a6)
	move.w	d7,woff+480(a6)
woff	set	woff+8
	endr
	lea	640(a5),a5
	lea	640(a6),a6
	subq.b	#1,savd0
	bne	nxlin2
	
	move.l	s2,a5
	lea	152(a5),a5
	lea	chars,a6
	adda.l	savd12,a6

	move.b	#8,savd0
nxtln2:	move.w	d0,(a5)
	move.w	d0,160(a5)
	move.w	d0,320(a5)
	move.w	d0,480(a5)
	move.b	(a6),d7
	lsl.b	d6,d7
	btst	#7,d7
	beq.s	nol12
	move.b	d1,(a5)
	move.b	d1,160(a5)
	move.b	d1,320(a5)
	move.b	d1,480(a5)
nol12:	btst	#6,d7
	beq.s	nol22
	move.b	d1,1(a5)
	move.b	d1,161(a5)
	move.b	d1,321(a5)
	move.b	d1,481(a5)
nol22:	
	lea	640(a5),a5
	addq.l	#1,a6
	subq.b	#1,savd0
	bne.s	nxtln2
	addq.l	#2,d6
	
	subq.b	#1,savd52
	bne	nonew2
	move.l	sava52,a5
	tst.b	(a5)
	bne.s	nowra2
	lea	text,a5
nowra2:	moveq.l	#0,d7
	move.b	(a5)+,d7
	sub.b	#32,d7
	lsl.w	#3,d7
	move.l	d7,savd12
	
	moveq.l	#1,d6
	move.b	#4,savd52
	move.l	a5,sava52

	lea	chars,a5
	adda.l	d7,a5

	moveq.w	#7,d7
	move.l	s2,a6
	lea	153(a6),a6
donew:	move.b	d0,(a6)
	move.b	d0,160(a6)
	move.b	d0,320(a6)
	move.b	d0,480(a6)
	btst	#7,(a5)
	beq.s	poo
	move.b	d1,(a6)
	move.b	d1,160(a6)
	move.b	d1,320(a6)
	move.b	d1,480(a6)
poo:	lea	640(a6),a6
	addq.l	#1,a5
	dbra	d7,donew

nonew2:	move.l	d6,savd6

ohnosc:

	tst.b	docadd
	bne.s	dotwen			* Do 'tweens' if activated!

	subq.w	#1,frcount
	bne	gkeysp

	move.l	nwvadd(pc),a0
	cmpi.w	#-99,(a0)
	bne.s	netab
	lea	newavs(pc),a0
netab:	move.l	(a0)+,xtot
	move.l	(a0)+,xstot
	move.l	a0,nwvadd
	move.b	#1,docadd
	move.w	#50*6,frcount


dotwen:	move.w	xinc(pc),d0
	move.w	yinc(pc),d1
	move.w	xsepr(pc),d2
	move.w	ysepr(pc),d3

	cmp.w	xtot(pc),d0
	beq.s	xdone
	blt.s	xtad
	subq.w	#2,xinc
	bra.s	xdone
xtad:	addq.w	#2,xinc
xdone:	cmp.w	ytot(pc),d1
	beq.s	ydone
	blt.s	ytad
	subq.w	#2,yinc
	bra.s	ydone
ytad:	addq.w	#2,yinc
ydone:	cmp.w	xstot(pc),d2
	beq.s	xsdone
	blt.s	xstad
	subq.w	#2,xsepr
	bra.s	xsdone
xstad:	addq.w	#2,xsepr
xsdone:	cmp.w	ystot(pc),d3
	beq.s	ysdone
	blt.s	ystad
	subq.w	#2,ysepr
	bra.s	ysdone
ystad:	addq.w	#2,ysepr
ysdone:	cmp.w	xtot(pc),d0
	bne.s	noall
	cmp.w	ytot(pc),d1
	bne.s	noall
	cmp.w	xstot(pc),d2
	bne.s	noall
	cmp.w	ystot(pc),d3
	bne.s	noall

	move.b	#0,docadd

noall:

*	clr.w	$ff8240			* For timing purposes...


gkeysp:	
	ifeq demo
	cmpi.b	#57,$fffffc02.w		* Space scan code?
	bne	key
	endc
	bra key


out:	ifeq demo
	move.w	#$2700,sr
	move.b	sa1(pc),$fffa07
	move.b	sa2(pc),$fffa09
	move.b	sa3(pc),$fffa13
	move.b	sa4(pc),$fffa19
	move.b	sa5(pc),$fffa1f
	move.b	sa6(pc),$fffa21
	move.b	sa7(pc),$fffa1b
	move.b	sa8(pc),$fffa15
	move.b	sa9(pc),$fffa1d
	move.b	sa10(pc),$fffa25
	move.l	oldvbl(pc),$70
	move.l	asave(pc),$134
	move.l	oldhbl(pc),$120
	move.w	#$2300,sr		* Restore MFP vectors & interrupts.


flush:	btst.b	#0,$fffc00
	beq.s	fl_done
	move.b	$fffc02,d0
	bra	flush
fl_done:				* Purge keyboard buffer!

	move.w	#0,$ff8240
	move.w	#$777,$ff8242
	move.w	#$777,$ff8244
	move.w	#$777,$ff8246		* 'Clean up' part of palette!

	moveq.l	#0,d0
	bsr	mus

	clr.w	-(sp)
	trap	#1			* Terminate process. Agggg!
	endc

******** VERTICAL BLANK INTERUPT

vbl:	move.b	#0,$fffffa19.w
	move.l	#a_int,$134.w
	move.b	#99,$fffffa1f.w
	move.b	#4,$fffffa19.w
	
	clr.w	$ffff8240.w
	move.b	scrnpos+1,$ffff8201.w
	move.b	scrnpos+2,$ffff8203.w	* New screen address into shifter.
	move.l	scrnpos(pc),-(sp)
	move.l	scrn2(pc),scrnpos
	move.l	(sp)+,scrn2		* And swap screens.
	addq.b	#1,lcount		* VBL has occured!

	move.b	#0,$fffffa1b.w
	move.l	#hbl,$120.w
	move.b	#3,$fffa21
	lea	brasts(pc),a3
	move.b	#8,$fffffa1b.w
	rte

vbl2:	move.b	scrnpos+1,$ffff8201.w
	move.b	scrnpos+2,$ffff8203.w
	move.l	scrnpos(pc),-(sp)
	move.l	scrn2(pc),scrnpos
	move.l	(sp)+,scrn2

	move.b	#2,$ffff820a.w
	move.b	#0,$fffffa19.w
	move.b	#%1000000,$fffffa17.w
	move.b	#%00100001,$fffffa07.w
	move.b	#%00100001,$fffffa13.w

	move.l	s1(pc),a0
	move.l	s2(pc),a1
	moveq.w	#0,d0
	move.w	#31,d1
wipesc:
cloff	set	0
	rept	20
	move.w	d0,cloff(a0)
	move.w	d0,cloff(a1)
cloff	set	cloff+8
	endr
	lea	160(a0),a0
	lea	160(a1),a1
	dbra	d1,wipesc
	
	move.b	#0,fscrol

	lea	text,a5
	moveq.l	#0,d7
	move.b	(a5)+,d7
	sub.b	#32,d7
	lsl.w	#3,d7
	move.l	d7,savd1
	move.l	d7,savd12
	moveq.l	#0,d6
	move.l	#1,savd6
	move.b	#4,savd5
	move.b	#4,savd52
	move.l	a5,sava5
	move.l	a5,sava52

	addq.b	#1,lcount
	rte

hbl:	move.w	(a3)+,(a4)
	rte


a_int:		clr.b $fffffa19.w
topremove	MOVE.L #quicky,$68.W
		stop #$2100
		stop #$2100
		move #$2700,sr
		dcb.w 86,$4e71
		move.b #0,$ffff820a.w
		dcb.w 18,$4e71
		move.b #2,$ffff820a.w
		rept	8
		nop
		endr
		move.l	#nha,$134               * Jose Removed .w
		move.b	#178,$fffffa1f.w
		move.b	#7,$fffffa19.w
		rte

quicky		RTE

nha:	move.w	#$2500,sr
	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.l	#hbl2,$120.w
	move.b	#8,$fffffa1b.w
	move.b	#0,$fffffa19.w
	rte

	
hbl2:	move.w	#$2700,sr
	move.b	#0,$fffffa1b.w
	move.l	d0,-(sp)
	moveq	#$23,d0
wsix:	dbf	d0,wsix
	move.b	#0,$ff820a
	moveq	#2,d0
wfif:	dbf	d0,wfif
	move.b	#2,$ff820a
	move.l	(sp)+,d0
	MOVEM.L D0-D7/A0-A6,-(a7)
	BSR mus+6
	MOVEM.L (A7)+,D0-D7/A0-A6
	rte
	


************* PRESHIFTER ROUTINE!

pshift:	move.w	lines(pc),d0		* Number of lines in D0.
	move.w	chunks(pc),d1		* Number of chunks in D1.

	move.w	times(pc),d2		* Number of shifts in D2.
	move.w	scroll(pc),d3		* Actual steprate in D3.

	move.l	source(pc),a0		* Source of preshift in A0.
	move.l	dest(pc),a1		* Destination address in A1.


*****************                                       **************
*** This bit puts the end bits that are scrolled off into the buffer.*
*****************                                       **************

nxshft:	move.l	source(pc),a0		* Source of preshift in A0.
nxtlin:	lea	buffer(pc),a3		* Load buffer address in A3.

	moveq.l	#0,d4			* Clear D4.
	move.w	d1,d4			* D4 is now number of chunks.
	subq.l	#1,d4			* Adjust it for multiply.
	add.l	d4,d4
	add.l	d4,d4
	add.l	d4,d4			* Now chunk end (D4 X 8 bytes).
	add.l	d4,a0			* A0 now points to chunk end.
	
	move.w	d3,d5			* Get shift count into D5.
	subq.w	#1,d5			* Adjust for table start.
	add.w	d5,d5			* And make it word access (X2).
	
	rept	4			* 4 PLANES.
	move.w	(a0)+,d7		* Get 1st plane into D7.
	lea	masks(pc),a2		* Load mask address into A2.
	move.w	0(a2,d5.w),d6		* Get mask into D6.
	and.w	d6,d7			* Isolate bit/s in d7.
	lea	reverse(pc),a2		* Load reverse shift address in A2.
	moveq.l	#0,d6			* Make sure only word shifts.
	move.w	0(a2,d5.w),d6		* Get reverse shift count in D6.
	lsl.w	d6,d7			* Reverse shift D7 for wrap.
	move.w	d7,(a3)+		* Store it in wrap buffer.
	endr
	

*****************                                       **************
*** This bit shifts the planes and merges the buffers accordingly.   *
*****************                                       **************

	move.l	source(pc),a0		* Load source into a0.
mainsh:	lea	buffer(pc),a3		* Load buffer address into A3.

	rept	4			* 4 PLANES.
	move.w	(a0)+,d7		* Get 1st plane into D7.
	move.w	d7,d4			* Put it into D4 as well.
	lsr.w	d3,d4			* Scroll that plane in D4.
	move.w	d4,shword		* Store the shifted plane.
	lea	masks(pc),a2		* Load mask address into A2.
	move.w	0(a2,d5.w),d6		* Get mask into D6.
	and.w	d6,d7			* Isolate bit/s.
	lea	reverse(pc),a2		* Load reverse shift address in A2.
	moveq.l	#0,d6			* Make sure d6 is word only.
	move.w	0(a2,d5.w),d6		* get reverse shift count into D6.
	lsl.w	d6,d7			* reverse shift D7 for merge.
	move.w	(a3),d4			* Get previous wrap bit/s.
	or.w	d4,shword		* And merge em in plane.
	move.w	shword,(a1)+		* And write new plane back!
	move.w	d7,(a3)+		* Store D7 in wrap buffer.
	endr

	subq.w	#1,chunks
	bne	mainsh			* Repeat for number of chunks.
	move.w	d1,chunks		* Restore chunk numbers.
	move.l	a0,source		* Increase source address.
	subq.w	#1,lines
	bne	nxtlin			* Repeat for number of lines.
	move.w	d0,lines

	move.l	a1,a2			* Don't smash A1!!
	moveq.l	#0,d7			* Make sure long D7 is clear.
	move.l	d7,d6			* Clear D6 as well.
	move.w	d1,d7			* Number of chunks in d7
	add.w	d7,d7
	add.w	d7,d7
	add.w	d7,d7			* Quick multiply (X8).
	mulu	d0,d7			* Times number of lines.
	sub.l	d7,a2			* Subtract from end of preshift.
	move.l	a2,source		* Make it as source.
	subq.w	#1,times
	bne	nxshft			* Repeat for number of shifts.

	rts				* A1 returns with end of shifts.


************* MASKING ROUTINE!	

maskit:	move.w	lines(pc),d0		* Number of lines in D0.
	move.w	chunks(pc),d1		* Number of chunks in D1.
	move.w	times(pc),d2		* Number of masks in D2.
	move.l	source(pc),a0		* Source of masks in A0.
	move.l	dest(pc),a1		* Destination address in A1.

	
domask:	move.w	(a0)+,d4
	or.w	(a0)+,d4
	or.w	(a0)+,d4
	or.w	(a0)+,d4		* Add all 4 planes together.
	not.w	d4		 	*Invert the masks.
	move.w	d4,(a1)+
	move.w	d4,(a1)+		* Two plane masks (faster put).
	subq.w	#1,chunks		* Repeat for number of chunks.
	bne.s	domask
	move.w	d1,chunks
	subq.w	#1,lines		* Repeat for height.
	bne.s	domask
	move.w	d0,lines
	subq.w	#1,times		* Repeat for number of masks.
	bne.s	domask
	
	rts				* Exit with A1 pointing to end
					* of mask data.


******* KEYBOARD SEND ROUTINE

ksend:	move.b	(a0)+,d0		* Number of bytes to send.
notrdy:	btst.b	#1,$fffffc00.w
	beq.s	notrdy			* Wait for keyboard ready.
	move.b	(a0)+,$fffffc02.w	* Aha! Got you! Here! Take this!
	subq.b	#1,d0
	bne.s	notrdy			* Repeat for number of bytes.
	rts				* Return from this routine.


	ifeq demo
oldvbl:	ds.l	1		* Old VBL vector.
asave:	ds.l	1		* Old timer A vector.
oldhbl:	ds.l	1		* Old timer B vector.
	endc
scrnpos:ds.l	1		* Address of screen 1.
scrn2:	ds.l	1		* Address of screen 2.
lcount:	ds.w	1		* For VBL sync purposes.

shifts:	ds.l	1

s1:	ds.l	1
s2:	ds.l	1

nwvadd:	dc.l	newavs

	*	xin yin xsep ysep
newavs:	dc.w	2*2,3*2,45*2,45*2
	dc.w	1*2,6*2,30*2,50*2
	dc.w	3*2,2*2,10*2,10*2
	dc.w	2*2,3*2,172*2,172*2
	dc.w	3*2,2*2,25*2,25*2
	dc.w	1*2,8*2,45*2,30*2
	dc.w	4*2,3*2,98*2,90*2
	dc.w	2*2,2*2,10*2,100*2
	dc.w	7*2,1*2,30*2,10*2
	dc.w	6*2,1*2,1*2,50*2
	dc.w	5*2,4*2,-5*2,-4*2
	dc.w	1*2,6*2,50*2,1*2

	dc.w	8,16,50,6
	dc.w	6,4,956,98
	dc.w	6,4,600,-2
	dc.w	6,4,600,170
	dc.w	10,-8,1230,226
	dc.w	10,-8,1230,622
	dc.w	10,-8,488,622
	dc.w	10,-8,488,764
	dc.w	10,-8,292,418

	dc.w	10,6,68,60
	dc.w	4,4,14,46
	dc.w	12,8,4,4
	dc.w	24,34,0,0
	dc.w	10,6,80,70
	dc.w	6,18,328,318
*	dc.w	8,10,730,448
	
	dc.w	2*2,5*2,14*2,50*2

	dc.w	-99

xtot:	dc.w	0
ytot:	dc.w	0
xstot:	dc.w	0
ystot:	dc.w	0

erase1:	dc.l	0,0,0,0,0,0,0,0,0,0,0
erase2:	dc.l	0,0,0,0,0,0,0,0,0,0,0

nxcoord:dc.w	100
nycoord:dc.w	10


reverse:dc.w	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1

masks:	dc.w	%0000000000000001	* Masks for bit isolation (15).
	dc.w	%0000000000000011
	dc.w	%0000000000000111
	dc.w	%0000000000001111
	dc.w	%0000000000011111
	dc.w	%0000000000111111
	dc.w	%0000000001111111
	dc.w	%0000000011111111
	dc.w	%0000000111111111
	dc.w	%0000001111111111
	dc.w	%0000011111111111
	dc.w	%0000111111111111
	dc.w	%0001111111111111
	dc.w	%0011111111111111
	dc.w	%0111111111111111


keybyt:	ds.b	1		* If keypress, byte stored here.

joyb1:	ds.b	1		* If joystick, byte stored here.

joyx1:	ds.b	1
joyy1:	ds.b	1

flip:	dc.b	0
	ifeq demo
sa1:	ds.b	1
sa2:	ds.b	1
sa3:	ds.b	1
sa4:	ds.b	1
sa5:	ds.b	1
sa6:	ds.b	1
sa7:	ds.b	1		* MFP register save space.
sa8:	ds.b	1
sa9:	ds.b	1
sa10:	ds.b	1
	endc
nnasts:	dc.b	10

nsprits:dc.b	9		* Number of nasties onscreen at once.

docadd:	dc.b	0		* For doc wave tweening signal.

nasty:	even
	incbin	balls.dat
	even
	
pal:	even
	incbin	balls.pal	* Palette data. 32 bytes.
brasts:	even
	incbin	rasterme.pal


xinc:	even
	dc.w	2*2		* X increment value through table.
yinc:	dc.w	5*2		* Y increment value through table.
	
addx:	dc.w	0		* (storage)
addy:	dc.w	0		* (storage)

xsepr:	dc.w	14*2		* X separation between sprites.
ysepr	dc.w	50*2		* Y separation between sprites.

xstemp:	dc.w	0		* (storage)
ystemp:	dc.w	0		* (storage)

xsin:	even
	incbin	xsin.dat
ysin:	even
	incbin	ysin.dat


mus:	even
	incbin	ic_reset.czi

frcount:dc.w	50*6			* Init frcount at 6 seconds.

init:	dc.b	4
	dc.b	$80,$01,$12,$1a

savd52:	ds.b	1
savd5:	ds.b	1
savd0:	ds.b	1

fscrol:	dc.b	0

	*	o corntrols table allocations from scroller

text:	dc.b	' WHAT,DEMO NOT GOOD ENOUGH FOR YOU?     YOU CAN  *N E V E R*  ESCAPE '
	DC.B    'FROM THE INNER CIRCLE.... (SCARY MUSIC... ECHOING FOOTSTEPS... A WOMAN SCREAMS.... A MAN PANTS IN EXERTION.... THEY GASP.... SHALL WE SMOKE A CIGARETTE..?)    AHEM...   '
	dc.b	'WELL... THERE IT WAS... ALL IN ALL,A RATHER GOOD DEMO OR,IN OTHER WORDS... PERHAPS THE *FUCKING* BEST DEMO YOU''VE SEEN SINCE MRS MIGGIN LIFTED HER SKIRTS.... HEY... BEFORE WE GO ANY FURTHER HOW ABOUT SOME CREDITS...   THIS '
	dc.b	'RESET SCREEN WAS CODED BY THE PHANTOM OF ELECTRONIC IMAGES,BIG-BOUNCY-BALLS BY MASTER OF THE RESISTANCE AND SHIT MUSIX BY COUNT ZERO OF ELECTRONIC IMAGES...   WELL... THERE''S NOTHING MORE TO SAY OTHER THAN WE HOPE YOU '
	dc.b	'ENJOYED THIS MOST BRILLIANT INNER CIRCLE DEMO (BY INNER CIRCLE!) AND IF YOU DID... WHY NOT SEND US LOADS AND LOADS OF MONEY?  JUST THINK... IF EVERYONE WHO LIKED THIS DEMO SENT US A POUND WE WOULD HAVE ENOUGH TO GIVE ARCHIE THAT '
	DC.B	'OPERATION THAT HE ALWAYS WANTED... YOU KNOW... THAT ONE THAT STOPS HIS JOHN THOMAS FROM   -   (OH DEAR... RAN OUT OF TEXT SPACE....)            INNER CIRCLE   -   THE REAL FUCKING BEST!!!!!!                  '
	dc.b	'BUT NOW... THE MASTER OF SCROLLTEXTS... THE MAN HIMSELF... MIKEY BOURNE!!!!!!!         OOOO MY KNOB JUST BANGED IT ON THE CORNER OF THE DESK.... OK OK WHATS ALL THIS.... I GET NO CLUES AS TO HOW THIS TEXT HAS BEEN ENTERED B4 SO '
	dc.b	'I WANT A SHAG AND NOTHING IS HAPPENING ALL THESE GUYS ARE WANTING TO SWING FROM THE CHANDELIERS BUT THIS IS WHAT HAPPENS AFTER 40 TINS OF COKE...IF SHIT IS BROWN WHY IS THE BOG ROLL WHITE ?? TO EMBARASS YOU ?? I JUST BEEN SHOWING MY'
	dc.b	'BOOK OFF ITS A TREAT,IT''S GIGERS ALIEN AND IF YOU LOUSE RIDDEN SONS OF SHITBAGS DONT GO OUT AND BUY IT THEN YOUR DICK WILL PROMPTLY FALL OFF. ARE YOU STILL READING THIS ?? WHY ?? ITS OBVIOUS YOU ARE ALL WAITING FOR MIKEYS SEXUAL '
	dc.b	'TECHNIQUE  SO ... HERE IT COMES . . THPPP THPPP (CUE GRAPHICAL WHITE BLOB) NOW TODAYS SUBJECT IS THE CLITORIS... NOW ALL THE SEXUAL EXPERTS RECKON THIS TO BE A SMALL PENIS IF SO THEN I MUST BE GAY WHICH I CERTAINLY AM NOT YOU CHEEKY'
	dc.b	'FUCKER. . . ON WITH TRICKS AND TIPS RIGHT THEN ALWAYS USE YOUR MIDDLE FINGER IF YOU CAN THIS IS THE ONE THAT MUST STIMULATE THE CLITORIS. DONT THINK YOU CAN FLICK THE SONOFABITCH UP AND DOWN LIKE A LIGHT SWITCH. MAKE SLOW UP AND '
	dc.b	'DOWN SLOWLY WHEN SHE STARTS TO MAKE MOVEMENTS THEN MOVE THE FINGER FURTHER DOWN SO THAT THE TIP (OO-ER) TOUCHES THE OPENING AND THE MIDDLE OF THE FINGER RUBS THE CLITORIS... YOU CAN IF YOU LIKE USE THE THUMB TO MOVE AROUND THE '
	dc.b	'PUBIC AREA. THIS COVERS INTERMEDIATE FOREPLAY WHICH MUST BE MASTERED (DOWN DOWN) BEFORE YOU ATTEMPT ANY KIND OF PENETRATION. NOW THATS THE LATEST IN MIKEYS TIPS FOR SEX... ONTO MIKEYS TIPS FOR VIOLENCE AS SUGGESTED BY A VERY NICE FRIEND'
	dc.b	' OF MINE. . . PHIL... GET SOMEONES HAND REST THE INDEX FINGER ON A TABLE AND GET SOMEONE TO HOLD THE HAND SO THAT THE FINGER CANNOT MOVE THEN YOU GET THE HAMMER AND NAIL AND TOUCH THE NAIL ON THE SECOND KNUCKLE AND SLAM THE HAMMER DOWN '
	dc.b	'ON THE KNUCKLE... YOU SHOULD HEAR A RESOUNDING CRUNCH AS THE METAL SPLITS THE BONE... DONT BE AFRAID TO TRY AGAIN SHOULD YOU GET IT WRONG....BEFORE I FINISH THE HINTS SECTION I MUST ANSWER A QUICK QUESTION REGARDING EJACULATION INTO THE '
	dc.b	'GIRLS MOUTH... TAKE IT ALL BITCH OR PLEASE ACCEPT MY DEPOSIT ARE NOT PHRASES TO BE USED AND NO MATTER WHAT YOU THINK IF YOU HAVE GIVEN AS MUCH AS YOU CAN TO HER SEXUALLY SHE WILL NOT CARE IF YOU SPURTED FIRE FROM YOUR DICK SO TAKE NOTE '
	dc.b	'I WOULD LIKE TO THANK EVERYONE AT THE NICE HOUSE FOR MAKING ME SO WELCOME.... WOULD I FUCK !! THEY WHIPPED ME SENSELESS WITH A LYNX UNTIL I WAS SENSELESS (DIDNT TAKE LONG). IN THE NEXT TEXT I WILL GIVE YOU ALL HINTS ON FORE FOREPLAY '
	dc.b	'THIS IS NOT A MISTAKE.. THIS IS THE PART BEFORE FOREPLAY FOR THE DUMB FUCKS OUT THERE. IT ISN''T FAIR IF MY DICK WASN''T 9 INCHES I WOULD FEEL TOTALLY INSECURE AS EVERYONE INCLUDING THE DOG CAN CODE BETTER THAN ME. SO I AM OFF NOW TO '
	dc.b	'START A FIRE BY SHAGGING A CAR TYRE.... ADIOS TIL NEXT TIME FROM MMM III KKK EEE YYY               INNER CIRCLE      AND TO THE BEGINNING... (WHERE''S OUR LAWYER!) AND TILL THE NEXT TIME YOU PURPLE LOVE BEAST!      '

chars:	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	
	dc.b	%00010000
	dc.b	%00010000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00000000
	dc.b	%00011000
	
	dc.b	%01101100
	dc.b	%00100100
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	
	dc.b	%00100100
	dc.b	%01111110
	dc.b	%00100100
	dc.b	%00100100
	dc.b	%00100100
	dc.b	%01110100
	dc.b	%01111110
	dc.b	%00100100
	
	dc.b	%00011000
	dc.b	%11111110
	dc.b	%10000000
	dc.b	%11111110
	dc.b	%00000110
	dc.b	%00000110
	dc.b	%11111110
	dc.b	%00011000
	
	dc.b	%10000010
	dc.b	%00000100
	dc.b	%00001000
	dc.b	%00010000
	dc.b	%00100000
	dc.b	%01000000
	dc.b	%10000010
	dc.b	%00000000
	
	dc.b	%01111100
	dc.b	%01000000
	dc.b	%01000100
	dc.b	%11111110
	dc.b	%11000100
	dc.b	%11000100
	dc.b	%11000100
	dc.b	%11111100
	
	dc.b	%01100000
	dc.b	%00100000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	
	dc.b	%00110000
	dc.b	%01000000
	dc.b	%01000000
	dc.b	%01000000
	dc.b	%01000000
	dc.b	%01000000
	dc.b	%01000000
	dc.b	%00110000
	
	dc.b	%00011000
	dc.b	%00000100
	dc.b	%00000100
	dc.b	%00000100
	dc.b	%00000100
	dc.b	%00000100
	dc.b	%00000100
	dc.b	%00011000
	
	dc.b	%10010010
	dc.b	%01010100
	dc.b	%00111000
	dc.b	%11111110
	dc.b	%00111000
	dc.b	%01010100
	dc.b	%10010010
	dc.b	%00000000
	
	dc.b	%00010000
	dc.b	%00010000
	dc.b	%00010000
	dc.b	%11111110
	dc.b	%00010000
	dc.b	%00010000
	dc.b	%00010000
	dc.b	%00010000
	
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00100000
	dc.b	%01100000
	
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%11111110
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000

	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00100000
	
	dc.b	%00000010
	dc.b	%00000100
	dc.b	%00001000
	dc.b	%00010000
	dc.b	%00100000
	dc.b	%01000000
	dc.b	%10000000
	dc.b	%00000000
	
	dc.b	%11111110
	dc.b	%11000010
	dc.b	%10100010
	dc.b	%10010010
	dc.b	%10001110
	dc.b	%10000110
	dc.b	%10000110
	dc.b	%11111110
	
	dc.b	%00001000
	dc.b	%00001000
	dc.b	%00001000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	
	dc.b	%11111110
	dc.b	%10000010
	dc.b	%00000010
	dc.b	%11111110
	dc.b	%10000000
	dc.b	%10000000
	dc.b	%10000000
	dc.b	%11111110
	
	dc.b	%11111100
	dc.b	%00000100
	dc.b	%00000100
	dc.b	%11111100
	dc.b	%00000110
	dc.b	%00000110
	dc.b	%00000110
	dc.b	%11111110
	
	dc.b	%11111100
	dc.b	%10000100
	dc.b	%10000100
	dc.b	%11111110
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	
	dc.b	%11111110
	dc.b	%10000000
	dc.b	%10000000
	dc.b	%10000000
	dc.b	%11111110
	dc.b	%00000110 
	dc.b	%10000110
	dc.b	%11111110
	
	dc.b	%11111110
	dc.b	%10000000
	dc.b	%10000000
	dc.b	%10000000
	dc.b	%11111110
	dc.b	%10000110
	dc.b	%10000110
	dc.b	%11111110
	
	dc.b	%11111110
	dc.b	%00000010
	dc.b	%00000010
	dc.b	%00000010
	dc.b	%00000110
	dc.b	%00000110
	dc.b	%00000110
	dc.b	%00000110
	
	dc.b	%01111100
	dc.b	%01000100
	dc.b	%01000100
	dc.b	%01000100
	dc.b	%11111110
	dc.b	%10000110
	dc.b	%10000110
	dc.b	%11111110
	
	dc.b	%11111110
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%11111110
	dc.b	%00000110
	dc.b	%00000110
	dc.b	%00000110
	dc.b	%00000110
	
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00000000
	dc.b	%00000000
	
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00001000
	dc.b	%00000000
	dc.b	%00000000
	
	dc.b	%00000010
	dc.b	%00000100
	dc.b	%00001000
	dc.b	%00010000
	dc.b	%00010000
	dc.b	%00001000
	dc.b	%00000100
	dc.b	%00000010
	
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%01111100
	dc.b	%00000000
	dc.b	%01111100
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	
	dc.b	%10000000
	dc.b	%01000000
	dc.b	%00100000
	dc.b	%00010000
	dc.b	%00010000
	dc.b	%00100000
	dc.b	%01000000
	dc.b	%10000000
	
	dc.b	%11111110
	dc.b	%00000010
	dc.b	%00000010
	dc.b	%11111110
	dc.b	%11000000
	dc.b	%11000000
	dc.b	%00000000
	dc.b	%11000000
	
	dc.b	%11111110
	dc.b	%10000010
	dc.b	%10111010
	dc.b	%10101010
	dc.b	%10100010
	dc.b	%10111110
	dc.b	%10000000
	dc.b	%11111110

	dc.b	%01111100
	dc.b	%01000100
	dc.b	%01000100
	dc.b	%01111110
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010

	dc.b	%01111110
	dc.b	%01000010
	dc.b	%01000010
	dc.b	%11111110
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11111110
	
	dc.b	%11111110
	dc.b	%10000010
	dc.b	%10000000
	dc.b	%11000000
	dc.b	%11000000
	dc.b	%11000000
	dc.b	%11000010
	dc.b	%11111110
	
	dc.b	%11111100
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11111100
	
	dc.b	%11111110
	dc.b	%10000000
	dc.b	%10000000
	dc.b	%11111110
	dc.b	%11000000
	dc.b	%11000000
	dc.b	%11000000
	dc.b	%11111110
	
	dc.b	%11111110
	dc.b	%10000000
	dc.b	%10000000
	dc.b	%11111110
	dc.b	%11000000
	dc.b	%11000000
	dc.b	%11000000
	dc.b	%11000000
	
	dc.b	%11111110
	dc.b	%10000010
	dc.b	%10000000
	dc.b	%11000110
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11111110
	
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%11111110
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	
	dc.b	%00010000
	dc.b	%00010000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	
	dc.b	%00000100
	dc.b	%00000100
	dc.b	%00000110
	dc.b	%00000110
	dc.b	%00000110
	dc.b	%00000110
	dc.b	%10000110
	dc.b	%11111110
	
	dc.b	%10000100
	dc.b	%10000100
	dc.b	%10000100
	dc.b	%11111110
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	
	dc.b	%10000000
	dc.b	%10000000
	dc.b	%11000000
	dc.b	%11000000
	dc.b	%11000000
	dc.b	%11000000
	dc.b	%11000000
	dc.b	%11111110
	
	dc.b	%11111110
	dc.b	%10010010
	dc.b	%10010010
	dc.b	%11010010
	dc.b	%11010010
	dc.b	%11010010
	dc.b	%11010010
	dc.b	%11010010
	
	dc.b	%11111110
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	
	dc.b	%11111110
	dc.b	%10000110
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%11111110
	
	dc.b	%11111110
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%11111110
	dc.b	%11000000
	dc.b	%11000000
	dc.b	%11000000
	dc.b	%11000000
	
	dc.b	%11111110
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%10001110
	dc.b	%11111110
	
	dc.b	%11111100
	dc.b	%10000100
	dc.b	%10000100
	dc.b	%11111110
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	
	dc.b	%11111110
	dc.b	%10000010
	dc.b	%10000000
	dc.b	%11111110
	dc.b	%00000110
	dc.b	%10000110
	dc.b	%10000110
	dc.b	%11111110
	
	dc.b	%11111110
	dc.b	%00010000
	dc.b	%00010000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11111110
	
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%01000010
	dc.b	%01000100
	dc.b	%01000100
	dc.b	%01000100
	dc.b	%01111100
	
	dc.b	%10010010
	dc.b	%10010010
	dc.b	%11010010
	dc.b	%11010010
	dc.b	%11010010
	dc.b	%11010010
	dc.b	%11010010
	dc.b	%11111110
	
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%01111100
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	dc.b	%11000010
	
	dc.b	%10000010
	dc.b	%10000010
	dc.b	%11111110
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	
	dc.b	%11111110
	dc.b	%00000010
	dc.b	%00000010
	dc.b	%11111110
	dc.b	%11000000
	dc.b	%11000000
	dc.b	%11000010
	dc.b	%11111110
	section bss

savd6:	ds.l	1
savd62:	ds.l	1
savd1:	ds.l	1
savd12:	ds.l	1
sava5:	ds.l	1
sava52:	ds.l	1
**** ADRESS SPACES
bkadd:	ds.l	1		* 4 plane nasty (16 of them). 
baddr1:	ds.l	1		* 2 plane nasty masks (16 of them).

moffs:	ds.l	1		* Mask offsets (to save MULS).
spoffs:	ds.l	1		* Sprite offsets (to save MULS).

**** ADDRESSES OF SPRITES AFTER CALCS

nast1:	ds.l	1		* Screen address of nasty after calcs.
nshift1:ds.l	1		* Shift count for preshifts/masks.

source:	ds.l	1			* Address where to grab chunks.
dest:	ds.l	1			* Address where to preshift them.
chunks:	ds.w	1			* Number of chunks of object.
lines:	ds.w	1			* Number of lines of object.
times:	ds.w	1			* How many times to shift it.
scroll:	ds.w	1			* Actual steprate of scroll.

buffer:	ds.w	4			* Buffer space for wrap.

shword:	ds.w	1			* Space for shifted word.

	ds.l 199
stack	ds.l 1
screen:	even			* My screen & other data from here.