* Now pic is grabbed from address (contents of grabbit). Pic is prevoiusly
* copied to address in grabbit.

	opt o+,ow-

demo	equ 0

	ifeq demo
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	move.l	d0,oldsp             * Set supervisor mode

	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	move.b	#0,$ff8260   * Low resolution
	endc

	move.w	#$2700,sr
	move.l sp,oldsp
	lea stack,sp
	move #$8240,a0
	rept 8
	clr.l (a0)+
	endr
	move.w	#192,mus+28
	move.w	#192,mus+2+28
	move.w	#179,mus+4+28
	move.w	#192,mus+6+28
	
	moveq.l	#1,d0
	bsr	mus+8+28

	
	move.b	$fffffa07.w,sa1
	move.b	$fffffa09.w,sa2
	move.b	$fffffa13.w,sa3
	move.b	$fffffa19.w,sa4
	move.b	$fffffa1f.w,sa5
	move.b	$fffffa21.w,sa6
	move.b	$fffffa1b.w,sa7
	clr.b $fffffa07.w
	clr.b $fffffa09.w
	
	bclr.b	#3,$fffffa17.w
	
	move.l	$134.w,asave
	move.l	#a_int,$134.w
	or.b	#%00100000,$fffffa07.w
	or.b	#%00100000,$fffffa13.w
	move.b	#0,$fffffa19.w
	
	lea	lcount(pc),a6
	clr.b	$fffffa1b.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w          * Set up HBL routine
	move.l	$120.w,oldhbl
	move.l	#hbl,$120.w

	move.l $70.w,oldvbl
	move.l $68.w,oldphbl
	
	
	lea	fart+256,a0
	move.l	a0,d0
	clr.b d0
	move.l	d0,scrnpos
	
	move.b	scrnpos+1(pc),$ffff8201.w
	move.b	scrnpos+2(pc),$ffff8203.w
	
	move.l	scrnpos(pc),a0
	move.w	#2499,d0
ctop:	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbra	d0,ctop
	move.l	a0,grabbit
	move.l	scrnpos(pc),a0
	lea	pic,a1
	move.w	#1599,d0
clean:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,clean
	
	bra	fuck
	
	dc.b	'Oi!  If you''re wondering why I have loads of MOVE.L''s instead of MOVEM''S then fuck you I couldn''t be fucked to make this two screens and my '
	dc.b	'byte bender is a real pain in the arse to make two screens and fuck you this looks nice and even tho MOVEM''s would give me about 60% more CPU '
	dc.b	'time I CAN''T BE BLOODY FUCKED YA BASTARD! (Nice hacking tho to get past Griff''s protection!(even though its crap the packer is a bastard...) '
	even
	
fuck:	lea	pic,a0
	move.l	a0,swap1
	move.l	a0,secpic
	move.l	grabbit(pc),a1
	move.w	#1599,d0
cgrab:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,cgrab
	
	move.l	scrnpos(pc),a0
	move.l	a0,addr
	move.l	a0,bkaddr
	move.l	grabbit(pc),a0
	move.l	a0,addr2
	move.l	a0,bkaddr2
	lea	pic2,a0
	move.l	a0,swap2
	move.l	#pic3,swap3
	move.l	#pic4,swap4
	
	move.w	#500,pcount
	
	lea	btable(pc),a4
	lea	btable2(pc),a3
	moveq.l	#0,d1
	moveq.l	#0,d4
	
	move.l	#norm,taddr
	moveq.w	#6,d2

	move.l	#firstvbl,$70.w
	stop #$2300
	stop #$2300

reset:	lea	text(pc),a0
	bra	backon
	
lines:	movem.l	d0-d3/a0-a2,-(sp)
	move.b	(a6),d0
sync:	cmp.b	(a6),d0
	beq.s	sync
*	move.w	#$777,$ff8240
	move.l	last(pc),d1
	move.l	scrnpos(pc),a1
	move.l	grabbit(pc),a0
	adda.l	d1,a1
	adda.l	d1,a0
	rept	160
	move.l	(a0)+,(a1)+
	endr
	adda.l	#(45-4)*160,a0
	adda.l	#(45-4)*160,a1
	rept	160
	move.l	(a0)+,(a1)+
	endr
	move.l	last2(pc),d4
	move.l	scrnpos(pc),a1
	move.l	grabbit(pc),a0
	adda.l	d4,a1
	adda.l	d4,a0
	rept	80
	move.l	(a0)+,(a1)+
	endr
	adda.l	#(45-4)*160,a0
	adda.l	#(45-4)*160,a1
	rept	80
	move.l	(a0)+,(a1)+
	endr
	tst.w	two
	bne	ntwo
	
	tst.w	pcount
	beq.s	erasit
	subq.w	#1,pcount
	bne	endie2
	
erasit:	move.l	addr(pc),a0
	move.l	addr2(pc),a1
	move.l	secpic(pc),a2
	rept	40
	move.l	(a2),(a0)+
	move.l	(a2)+,(a1)+
	endr
	move.l	a0,addr
	move.l	a1,addr2
	move.l	a2,secpic
	subq.w	#1,nlines
	bne	endie2
	move.w	#156,nlines
	move.w	#500,pcount
	move.l	swap1(pc),a0
	move.l	swap2(pc),swap1
	move.l	swap3(pc),swap2
	move.l	swap4(pc),swap3
	move.l	a0,swap4
	move.l	swap1(pc),secpic
	add.l	#24960,secpic
	move.w	#1,two
	bra	endie2

ntwo:	tst.w	pcount
	beq.s	erasit2
	subq.w	#1,pcount
	bne	endie2
	
erasit2:move.l	addr(pc),a0
	move.l	addr2(pc),a1
	move.l	secpic(pc),a2
	rept	40
	move.l	-(a2),-(a0)
	move.l	(a2),-(a1)
	endr
	move.l	a0,addr
	move.l	a1,addr2
	move.l	a2,secpic
	subq.w	#1,nlines
	bne.s	endie2
	move.w	#156,nlines
	move.w	#500,pcount
	move.l	swap1(pc),a0
	move.l	swap2(pc),swap1
	move.l	swap3(pc),swap2
	move.l	swap4(pc),swap3
	move.l	a0,swap4
	move.l	swap1(pc),secpic
	clr.w	two
endie2:	


	cmpi.l	#-99,(a4)
	bne.s	addit
	lea	btable(pc),a4
addit:	add.l	(a4)+,d1
	move.l	d1,last
	move.l	scrnpos(pc),a1
	adda.l	d1,a1

	lea	bartab(pc),a2
	moveq.w	#44,d3
barrel:	move.l	grabbit(pc),a0
	adda.l	d1,a0
	adda.l	(a2)+,a0
	rept	40
	move.l	(a0)+,(a1)+
	endr
	dbra	d3,barrel
	
	cmpi.l	#-99,(a3)
	bne.s	addit2
	lea	btable2(pc),a3
addit2:	add.l	(a3)+,d4
	move.l	d4,last2
	move.l	scrnpos(pc),a1
	adda.l	d4,a1
	
	lea	bartab(pc),a2
	moveq.w	#44,d3
barrel2:move.l	grabbit(pc),a0
	adda.l	d4,a0
	adda.l	(a2)+,a0
	rept	40
	move.l	(a0)+,(a1)+
	endr
	dbra	d3,barrel2

	movem.l	(sp)+,d0-d3/a0-a2

	tst.b	sbyte
	beq.s	naah
	subq.l	#1,delay
	bne	key
	bra	backon
naah:	lea	chars(pc),a1
	adda.l	d3,a1
	add.l	d1,a1
	move.l	a0,-(sp)
	move.l	a1,-(sp)
	movea.l	scrnpos(pc),a0
	adda.l	#28320,a0
	move.l	a0,a1
	moveq.w	#19,d0
	move.l	taddr(pc),a2
cwav:	adda.l	(a2)+,a1
	adda.l	(a2)+,a0
	addq.l	#1,a0
	move.b	(a0),(a1)
	move.b	160(a0),160(a1)
	move.b	320(a0),320(a1)
	move.b	480(a0),480(a1)
	move.b	640(a0),640(a1)
	move.b	800(a0),800(a1)
	move.b	960(a0),960(a1)
	move.b	1120(a0),1120(a1)
	move.b	1280(a0),1280(a1)
	move.b	1440(a0),1440(a1)
	move.b	1600(a0),1600(a1)
	move.b	1760(a0),1760(a1)
	move.b	1920(a0),1920(a1)
	move.b	2080(a0),2080(a1)
	move.b	2240(a0),2240(a1)
	move.b	2400(a0),2400(a1)
	move.b	2560(a0),2560(a1)
	move.b	2720(a0),2720(a1)
	move.b	2880(a0),2880(a1)
	move.b	3040(a0),3040(a1)
	move.b	3200(a0),3200(a1)
	move.b	3360(a0),3360(a1)
	move.b	3520(a0),3520(a1)
	move.b	3680(a0),3680(a1)
	move.b	3840(a0),3840(a1)
	move.b	4000(a0),4000(a1)
	move.b	4160(a0),4160(a1)
	move.b	4320(a0),4320(a1)
	move.b	4480(a0),4480(a1)
	move.b	4640(a0),4640(a1)
	move.b	4800(a0),4800(a1)
	move.b	4960(a0),4960(a1)
	move.b	5120(a0),5120(a1)
	move.b	5280(a0),5280(a1)
	move.b	5440(a0),5440(a1)
	move.b	5600(a0),5600(a1)
	suba.l	-8(a2),a1
	suba.l	-4(a2),a0
	move.l	a0,a1
	adda.l	-4(a2),a1
	addq.l	#7,a0
	adda.l	(a2),a0
	move.b	(a0),(a1)
	move.b	160(a0),160(a1)
	move.b	320(a0),320(a1)
	move.b	480(a0),480(a1)
	move.b	640(a0),640(a1)
	move.b	800(a0),800(a1)
	move.b	960(a0),960(a1)
	move.b	1120(a0),1120(a1)
	move.b	1280(a0),1280(a1)
	move.b	1440(a0),1440(a1)
	move.b	1600(a0),1600(a1)
	move.b	1760(a0),1760(a1)
	move.b	1920(a0),1920(a1)
	move.b	2080(a0),2080(a1)
	move.b	2240(a0),2240(a1)
	move.b	2400(a0),2400(a1)
	move.b	2560(a0),2560(a1)
	move.b	2720(a0),2720(a1)
	move.b	2880(a0),2880(a1)
	move.b	3040(a0),3040(a1)
	move.b	3200(a0),3200(a1)
	move.b	3360(a0),3360(a1)
	move.b	3520(a0),3520(a1)
	move.b	3680(a0),3680(a1)
	move.b	3840(a0),3840(a1)
	move.b	4000(a0),4000(a1)
	move.b	4160(a0),4160(a1)
	move.b	4320(a0),4320(a1)
	move.b	4480(a0),4480(a1)
	move.b	4640(a0),4640(a1)
	move.b	4800(a0),4800(a1)
	move.b	4960(a0),4960(a1)
	move.b	5120(a0),5120(a1)
	move.b	5280(a0),5280(a1)
	move.b	5440(a0),5440(a1)
	move.b	5600(a0),5600(a1)
	suba.l	(a2),a0
	move.l	a0,a1
	dbra	d0,cwav
	move.l	(sp)+,a1
	move.l	scrnpos(pc),a0
	adda.l	#28320+153,a0
	adda.l	-4(a2),a0
	move.b	(a1),(a0)
	move.b	6(a1),160(a0)
	move.b	12(a1),320(a0)
	move.b	18(a1),480(a0)
	move.b	24(a1),640(a0)
	move.b	30(a1),800(a0)
	move.b	36(a1),960(a0)
	move.b	42(a1),1120(a0)
	move.b	48(a1),1280(a0)
	move.b	54(a1),1440(a0)
	move.b	60(a1),1600(a0)
	move.b	66(a1),1760(a0)
	move.b	72(a1),1920(a0)
	move.b	78(a1),2080(a0)
	move.b	84(a1),2240(a0)
	move.b	90(a1),2400(a0)
	move.b	96(a1),2560(a0)
	move.b	102(a1),2720(a0)
	move.b	108(a1),2880(a0)
	move.b	114(a1),3040(a0)
	move.b	120(a1),3200(a0)
	move.b	126(a1),3360(a0)
	move.b	132(a1),3520(a0)
	move.b	138(a1),3680(a0)
	move.b	144(a1),3840(a0)
	move.b	150(a1),4000(a0)
	move.b	156(a1),4160(a0)
	move.b	162(a1),4320(a0)
	move.b	168(a1),4480(a0)
	move.b	174(a1),4640(a0)
	move.b	180(a1),4800(a0)
	move.b	186(a1),4960(a0)
	move.b	192(a1),5120(a0)
	move.b	198(a1),5280(a0)
	move.b	204(a1),5440(a0)
	move.b	210(a1),5600(a0)
	move.l	(sp)+,a0
	
	subq.w	#1,d2
	beq.s	backon
	addq.l	#1,d1
	bra	key
backon:	moveq.w	#6,d2
	moveq.l	#0,d1
rescan:	tst.b	(a0)
	bne.s	poo
	lea	text(pc),a0
poo:	moveq.l	#0,d3
	cmpi.b	#'t',(a0)
	bne.s	n1
	move.l	#b2,taddr
	addq.l	#1,a0
	clr.b	sbyte
	bra.s	rescan
n1:	cmpi.b	#'o',(a0)
	bne.s	n2
	move.l	#btab,taddr
	addq.l	#1,a0
	clr.b	sbyte
	bra.s	rescan
n2:	cmpi.b	#'n',(a0)
	bne.s	n3
	move.l	#norm,taddr
	addq.l	#1,a0
	clr.b	sbyte
	bra.s	rescan
n3:	cmpi.b	#'r',(a0)
	bne.s	n4
	move.l	#b3,taddr
	addq.l	#1,a0
	clr.b	sbyte
	bra.s	rescan
n4:	cmpi.b	#'p',(a0)
	bne.s	n5
	move.l	#50,delay
	move.b	#1,sbyte
	addq.l	#1,a0
	bra.s	key
n5:	cmpi.b	#'c',(a0)
	bne.s	n6
	clr.b	cbyte
	addq.l	#1,a0
	clr.b	sbyte
	bra	rescan
n6:	cmpi.b	#'s',(a0)
	bne.s	n7
	move.b	#1,cbyte
	addq.l	#1,a0
	clr.b	sbyte
	bra	rescan
n7:	move.b	(a0)+,d3
	sub.l	#32,d3
	mulu	#216,d3
	clr.b	sbyte
key:	
*	clr.w	$ff8240
	
tspace:	cmpi.b	#57,$fffc02
	bne	lines


out:	move.w	#$2700,sr
	move.b	sa1(pc),$fffffa07.w
	move.b	sa2(pc),$fffffa09.w
	move.b	sa3(pc),$fffffa13.w
	move.b	sa4(pc),$fffffa19.w
	move.b	sa5(pc),$fffffa1f.w
	move.b	sa6(pc),$fffffa21.w
	move.b	sa7(pc),$fffffa1b.w
	move.l	oldphbl(pc),$68.w
	move.l	oldvbl(pc),$70.w
	move.l	oldhbl(pc),$120.w
	move.l	asave(pc),$134.w
	move.w	#$2300,sr

	moveq.l	#0,d0
	bsr	mus+8+28

flush:	btst.b	#0,$fffffc00.w
	beq.s	fl_done
	move.b	$fffffc02.w,d0
	bra	flush
fl_done:				* Purge keyboard buffer!
	ifeq demo
	move.w	#$777,$ff8240

	move.l	oldsp(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp

	clr.w	-(sp)
	trap	#1
	endc
	move.l oldsp,sp
	rts
firstvbl move.l	#vbl,$70.w
	rte

vbl:	clr.b $fffffa19.w
	move.l #a_int,$134.w
	move.b	#99,$fffffa1f.w
	move.b	#4,$fffffa19.w
	clr.b	$fffffa1b.w
	movem.l d0-d7,-(sp)
	movem.l	pal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l (sp)+,d0-d7
	lea	lcount(pc),a6
	clr.b	(a6)
	move.l	#hbl,$120.w
	move.b	#161,$fffffa21.w
	move.b	#8,$fffffa1b.w
	tst.b	cbyte
	bne.s	v2
	lea.l	cols(pc),a5
	bra.s	evbl
v2:	lea.l	cols2(pc),a5
evbl:	rte

a_int	clr.b $fffffa19.w
topremove	MOVE.L #quicky,$68.W
	stop #$2100
	stop #$2100
	move #$2500,sr
	dcb.w 86,$4e71
	move.b #0,$ffff820a.w
	dcb.w 18,$4e71
	move.b #2,$ffff820a.w
	bsr	mus+14+28
	RTE

quicky		RTE

hbl:	clr.b	$fffffa1b.w
	move.l	#hbl2,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

hbl2:	move.l	(a5)+,$ffff8240.w
	addq.b	#1,(a6)
	rte

oldphbl:ds.l	1

lcount:	ds.w	1
oldvbl:	ds.l	1
oldhbl:	ds.l	1
asave:	ds.l	1
oldsp:	ds.l	1
scrnpos:ds.l	1
grabbit:ds.l	1

addr:	ds.l	1
addr2:	ds.l	1
bkaddr:	ds.l	1
bkaddr2:ds.l	1

secpic:	ds.l	1

swap1:	ds.l	1
swap2:	ds.l	1
swap3:	ds.l	1
swap4:	ds.l	1

two:	dc.w	0

last:	ds.l	1
last2:	ds.l	1

pcount:	dc.w	500
nlines:	dc.w	156

bartab:	dc.l	0,480
	dc.l	800,1120,1440
	dc.l	1600,1760,1920,2080
	dc.l	2240,2240,2400,2400,2560,2560
	dc.l	2720,2720,2720,2880,2880,2880
	dc.l	3040,3040,3040
	dc.l	3200,3200,3200,3360,3360,3360
	dc.l	3520,3520,3680,3680,3840,3840
	dc.l	4000,4160,4320,4480
	dc.l	4800,5120,5440
	dc.l	5920,6400

btable2:rept	54
	dc.l	320
	endr
	dc.l	160
	dc.l	160
	dc.l	0
	rept	54
	dc.l	-320
	endr
	dc.l	-160
	dc.l	-160
	dc.l	0
	dc.l	-99
btable:	dc.l	0,0,160,160,160,160,320,320,320,320,320,320,320,320,320,320,320, 640,640,640,640,640,640,640,640,640,640,640,640, 640,640,640,640,640,640,640,640,640
	dc.l	-640,-640,-640,-640,-640,-640,-640,-640,-640
	dc.l	-640,-640,-640,-640,-640,-640,-640,-640,-640,-640,-640,-640,-320,-320,-320,-320,-320,-320,-320,-320,-320,-320,-320,-160,-160,-160,-160,0,0
	dc.l	-99

text:	even
		***** Control bytes:    o ------ Wavy.
		*			t ------ Up 'n' down.
		*			r ------ Chilly.
		*			n ------ Straight.
		*			p ------ Pause.
		*			c ------ Normal rasters.
		***** For scroller.	s ------ White foreground.
	
	dc.b	' nsTHE STORY OF HOW ELECTRONIC IMAGES WAS FORMED! (QUICK! RUN FOR COVER!)       coA LONG,LONG TIME AGO (ABOUT THE SIZE OF OUR CHOPPERS - PRETTY LONG!) GIZMO AND THE PHANTOM DECIDED TO FORM A GROUP. SO THEY BOTH WENT TO THE LOCAL COCKFIGHT'
	dc.b	' TO PONDER OVER THE NAME TO BE GIVEN TO THE GROUP...       tAFTER AN HOUR THEY BOTH HAD TO LEAVE,SINCE THEIR KNOBS WERE SORE. (DRUM ROLL)  THEY STILL DIDN''T COME UP WITH ANYTHING...       rBUT,FINALLY,ON A COLD WINTERS'' DAY WHILST '
	dc.b	'THEY WERE HOLDING UP A BANK GIZMO SAID "SHIT,PHANTOM,WHAT ABOUT THE NAME?" THE PHANTOM THEN SAID "NO,I DON''T LIKE ''SHIT,PHANTOM'' FOR A NAME"       nAFTER THEY GOT OUT OF PRISON THEY FINALLY CAME UP WITH THE NAME - ELECTRONIC IMAGES! '
	dc.b	' HOW? OURS IS NOT TO QUESTION WHY... BUT WE MUST SAY THAT THE PHANTOM COULD NEVER CROSS HIS LEGS AGAIN,WHILE GIZMO IS SOMEWHERE WITH A SNIPER''S RIFLE TO BL *BLAM*                 ...        SORRY ABOUT THAT! A .22 CALIBRE BULLET JUST '
	dc.b	'HIT THE PHANTOM IN THE HEAD.  HOW DO YOU FEEL,PHANTOM?   "DUUUUUUUUUUUUHHH!"   WE GUESS THAT MEANS: ''QUITE ALLRIGHT,BUT THE BANDAGES DON''T LET ME SEE''   HMM... OH,YEAH! THE OTHER TWO MEMBERS,COUNT ZERO AND NIGHTOWL,JOINED LATER ON,'
	dc.b	'WHEN GIZMO AND THE PHANTOM BUMPED INTO THEM; THEY WERE DOING A REPORT ON HOW TO REMOVE Y-FRONTS WITHOUT SNEEZING...       tOH,FUCK THIS!  AND NOW,FOR OUR NEXT TRICK,WE ARE GOING TO PUT THE SCROLLTEXT WHICH THE PHANTOM WROTE IN THE '
	dc.b	'COPY PARTY,WHILE HE WAS PISSED OUT OF HIS BRAIN! HERE GOES:          ns'

	dc.b	'IT''S FUCKING 1.15 IN THE FUCKING MORNING ON THE FUCKING SUNDAY FUCKING NEW YEARS EVE IN THE FUCKING "DEVELOPMENT" PLACE OF THE FUCKING INNER CIRCLE NEW YEAR FUCKING DEMO.  CUNTS. CAN''T CATCH A FUCKING WINK OF SLEEP,WITH THE '
	dc.b	'FUCKING MUSIC PLAYING AT FUCKING 100000 WATTS AND I FEEL LIKE SHIT (NO,YOU FUCKING CUNTS,IT WASN''T WHAT I FUCKING DRANK)...  RIGHT NOW THEY''RE DISCUSSING THIS PIECE OF MUSIC AND SOME OTHER FUCKING MATTER.  OH,WHATSIT MATRIXX '
	dc.b	'GOT HIS FUCKING  TWIST SCROLL WORKING.  CONGRAT-U-FUCKING-LATIONS!   OH,SHIT.  I''M GONNA ATTEMPT TO SLEEP NOW AND IF ANY (OH,WHATSIT THE *** (CAN''T RECALL THEIR NAME) ARE COMING AT 9.00 TODAY,CUNTS!) ONE PERSON WAKES ME UP I''M '
	dc.b	'GONNA BREAK THEIR FUCKING LEGS... GOODNIGHT AND SEE IF I CAN TYPE SOME MORE AFTER I GET SOME GOOD KIP (HANDY TIP - NEVER DRINK 48 PERCENT ''AGUARDIENTE'' WHEN YOU HAVEN''T SLEPT FOR 2 DAYS,IT''S FUCKING... SOMETHING... BUT IT FUCKS '
	dc.b	'ANYWAY!) SO MAYBE I''LL SEE IF I CAN TYPE SOME MORE SHIT LATER ... SAVING THIS TEXT NOW... (C.U. SOON?)          ctWELL! YOU SAW IT FIRST! AHEM! *BLUSH*  ERM,WE THINK IT''S TIME TO LOOP!       LOOP!         NO.... NOT YET IT ISN''T'
	DC.B	'...   THIS IS COUNT ZERO BUTTING IN TO SAY HI AND TO INFORM THE GENERAL PUBLIC THAT DRUMS ON THE 200HZ MUSIC YOU HEAR ARE THE ONES I THINK ARE SHIT BUT PHANTOM LIKES... IT''S HIS SCREEN SO I PUT THEM IN BUT I STILL THINK '
	DC.B	'THAT THEY''RE A LOAD OF '
	DC.B	'DINGO''S KIDNEYS....  HMM... IT''S BLOODY 9.00 IN THE MORNING,NO-ONE HAS SLEPT ALL NIGHT,THE DEMO IS SUPPOSED TO BE RELEASED IN 4 DAYS TIME AND THREE OF THE SCREENS ARE FINISHED....  *HOLY SHIT!!*    BUT FEAR NOT.. I WILL MAKE '
	DC.B	'THESE LAZY BASTARDS FINISH IT ALL IN TIME FOR YOUR PLEASURE... NOW I''M OFF TO KICK PHANTOM OFF MY MACHINE SO I CAN ATTEMPT TO FINISH SOME SHIT I HAVE TO DO.... GLURP.... SEE YOU IN THE NEXT DEMO...       LOOOOOOOOOOOOOOOOOOOOO'
	DC.B	'OOOOOOOOOOOP!            AAARGH... THAT BASTARD PHANTOM WON''T GET OFF MY FUCKING MACHINE... I''LL HAVE TO GET SOME PLIERS,THE CARBON FILAMENT RE-ENFORCED WIRE,THE SCRUBBING PADS,THE KNIVES AND THE KY JELLY.... GRRRRRRR            '
	dc.b	'PHANTOM HERE...  FAKK OFF COUNT!! FAKK OFF I LIKE DOSE 200HZ DRUMS SO FAAAAAAAAAARKKKKKKK ORRRRRRFFFFFFF!   FAKK FAK FAKKKK FACKKKKKKK OOOOOOOUUUFFF!  (BTW COUNT IS CACKLING LOUDLY IN THE BACKGROUND AND MASTER IS SHOVING AND EAR INTO '
	dc.b	'HIS MOUTH)   OH WELL  HAHAHAHAHAHAH 4 DAYS RELEASE!! HAHAHAHA! PULL THE OTHER ONE (AND I''LL PAY FOR IT TOO)   ...   ...   ...  OH,WELL MITE AS WELL WRAP SO THEN I''LL HAVE SOME TIME TO SLAP MY SALAMI...     LOOOP...           YUP.... '
	dc.b	'LOOP...   YES...    LOOOP...               NICE WORD LOOP...               MASTER CAN''T HOLD HIS WATER            LOOP               MY BUM IS PERT                 LOOP              CAPTAIN PEGO IS MY HERO                 LOOP        '
	dc.b	'             AROUND SOMEONE''S NECK            LOOP                    POTATO                   PLIERS AROUND MY KNOB                 COUNT ZERO STEALS MUSIC                HAHAHAA          (FAAAAAAAAAKK OFFFFFFFFFFF (COUNT ZERO ('
	DC.B	'MR ENORMOUS)))                  MR TINY IF YOU ASK ME                LOOP              OH MY WILLIE HAS BEEN SET ON FIRE              OH LOOK A FLYING TURNIP             LOOP             ',0
	
sa1:	ds.b	1
sa2:	ds.b	1
sa3:	ds.b	1
sa4:	ds.b	1
sa5:	ds.b	1
sa6:	ds.b	1
sa7:	ds.b	1

sbyte:	even
	ds.b	1
cbyte:	dc.b	1
delay:	even
	ds.l	1
cols:	even
	* $ff82  40   42

	dc.w	$100,$047
	dc.w	$300,$037
	dc.w	$400,$037
	dc.w	$500,$027
	dc.w	$600,$027
	dc.w	$700,$017
	dc.w	$700,$017
	dc.w	$700,$007
	dc.w	$700,$007
	dc.w	$701,$017
	dc.w	$701,$017
	dc.w	$701,$027
	dc.w	$701,$027
	dc.w	$702,$037
	dc.w	$702,$037
	dc.w	$702,$047
	dc.w	$703,$047
	dc.w	$704,$057
	dc.w	$704,$057
	dc.w	$704,$067
	dc.w	$704,$067
	dc.w	$705,$077
	dc.w	$705,$077
	dc.w	$705,$067
	dc.w	$705,$067
	dc.w	$706,$057
	dc.w	$706,$057
	dc.w	$706,$047
	dc.w	$706,$047
	dc.w	$707,$037
	dc.w	$707,$037
	dc.w	$707,$027
	dc.w	$707,$027
	dc.w	$706,$017
	dc.w	$706,$017
	dc.w	$706,$007
	dc.w	$706,$007
	dc.w	$705,$017
	dc.w	$705,$017
	dc.w	$705,$027
	dc.w	$705,$027
	dc.w	$704,$037
	dc.w	$704,$037
	dc.w	$704,$047
	dc.w	$704,$047
	dc.w	$703,$057
	dc.w	$703,$057
	dc.w	$703,$067
	dc.w	$703,$067
	dc.w	$702,$077
	dc.w	$702,$077
	dc.w	$702,$067
	dc.w	$702,$067
	dc.w	$701,$057
	dc.w	$701,$057
	dc.w	$701,$047
	dc.w	$701,$047
	dc.w	$700,$037
	dc.w	$700,$037
	dc.w	$700,$027
	dc.w	$700,$027
	dc.w	$600,$017
	dc.w	$500,$017
	dc.w	$400,$007
	dc.w	$300,$007
	dc.w	$200,$017
	dc.w	$100,$017
	dc.w	$000,$777

cols2:	even
	* $ff82  40   42
	dc.w	$000,$000
	dc.w	$000,$000
	dc.w	$700,$000
	dc.w	$700,$110
	dc.w	$700,$110
	dc.w	$600,$220
	dc.w	$600,$220
	dc.w	$600,$330
	dc.w	$500,$330
	dc.w	$500,$440
	dc.w	$500,$440
	dc.w	$400,$000
	dc.w	$400,$001
	dc.w	$400,$002
	dc.w	$300,$003
	dc.w	$300,$004
	dc.w	$300,$005
	dc.w	$200,$006
	dc.w	$200,$007
	dc.w	$200,$017
	dc.w	$100,$027
	dc.w	$100,$037
	dc.w	$100,$047
	dc.w	$101,$057
	dc.w	$302,$067
	dc.w	$403,$077			* Top
	dc.w	$504,$177
	dc.w	$605,$277
	dc.w	$706,$377
	dc.w	$707,$477
	dc.w	$717,$577
	dc.w	$727,$677
	dc.w	$737,$777
	dc.w	$747,$000
	dc.w	$737,$000
	dc.w	$727,$100
	dc.w	$717,$100
	dc.w	$707,$210
	dc.w	$606,$210
	dc.w	$505,$310
	dc.w	$404,$310
	dc.w	$303,$420
	dc.w	$202,$420
	dc.w	$101,$532
	dc.w	$001,$532
	dc.w	$001,$643
	dc.w	$001,$643
	dc.w	$002,$754
	dc.w	$002,$754
	dc.w	$002,$765
	dc.w	$003,$765
	dc.w	$003,$766
	dc.w	$003,$766
	dc.w	$004,$550
	dc.w	$004,$550
	dc.w	$004,$440
	dc.w	$005,$440
	dc.w	$005,$330
	dc.w	$005,$330
	dc.w	$006,$220
	dc.w	$006,$220
	dc.w	$006,$110
	dc.w	$007,$110			* Bottom.
	dc.w	$007,$550
	dc.w	$007,$000
	dc.w	$000,$000
	dc.w	$000,$000
	dc.w	$000,$000
		ds.l 129
stack		ds.l 1	
taddr:	ds.l	1
	
btab:	even
	dc.l	160,320,480,480,320,160,0,-160,-320,-480,-480,-320,-160,0,160,320,480,480,320,160,0,-160,-320,-480,-480,-320,-160,0,160,320,480,480,320,160,0,-160,-320,-480,-480,-320
b2:	even
	dc.l	0,320,640,960,1280,1600,1920,1920,1600,1280,960,640,320,0,-320,-640,-960,-1280,-1600,-1920,-1920,-1600,-1280,-960,-640,-320,0,320,640,960,1280,1600,1920,1920,1600,1280,960,640,320,0
b3:	even
	dc.l	0,-160,0,160,0,-160,0,160,0,-160,0,160,0,-160,0,160,0,-160,0,160,0,-160,0,160,0,-160,0,160,0,-160,0,160,0,-160,0,160,0,-160,0,160,0,-160,0,160,0,-160,0,160,0,-160,0,160,0,-160,0,160,0,-160,0,160,0,-160,0
norm:	even
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mus:	incbin	willy.czi

pal:	incbin	bartest.pal

chars:	incbin	charset.dat

pic:	incbin	bartest.dat
pic2:	incbin	tiger.dat
pic3:	incbin	house.dat
pic4:	incbin	bike.dat
	section bss
fart:	ds.b 256

	even