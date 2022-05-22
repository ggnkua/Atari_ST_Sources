; Inner Circle 'Intro to intro demoscreen'
; (C) 1990 Electronic Images.

	OPT O+,OW-

demo	EQU 0

	ifeq demo
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	move.b	#0,$ffff8260.w		* Low resolution pleez!
	endc

	move.w	#$2700,sr
	MOVEM.L bpal(PC),D0-D7
	MOVEM.L D0-D7,$FFFF8240.W


	lea	text(pc),a5
	lea	buff(pc),a1
	
	moveq.l	#0,d5
	moveq.l	#0,d4
	
dochars:tst.b	(a5)
	beq	elist
redo:	moveq.l	#0,d6
	move.b	(a5)+,d6
	cmpi.b	#$a,d6
	bne.s	achar
	moveq.l	#0,d5
	add.l	#448,d4
	bra	redo
achar:	sub.b	#32,d6
	lsl.w	#3,d6
	
	lea	chars(pc),a4
	adda.l	d6,a4
	lea	buff(pc),a1
	adda.l	d5,a1
	adda.l	d4,a1
	move.b	(a4)+,(a1)
	move.b	(a4)+,56(a1)
	move.b	(a4)+,112(a1)
	move.b	(a4)+,168(a1)
	move.b	(a4)+,224(a1)
	move.b	(a4)+,280(a1)
	move.b	(a4)+,336(a1)
	move.b	(a4)+,392(a1)
	
	tst.b	(a5)
	beq	elist
redo2:	moveq.l	#0,d6
	move.b	(a5)+,d6
	cmpi.b	#$a,d6
	bne.s	achar2
	moveq.l	#0,d5
	add.l	#448,d4
	bra	redo2
achar2:	sub.b	#32,d6
	lsl.w	#3,d6
	
	lea	chars(pc),a4
	adda.l	d6,a4
	lea	buff(pc),a1
	adda.l	d5,a1
	adda.l	d4,a1
	move.b	(a4)+,1(a1)
	move.b	(a4)+,57(a1)
	move.b	(a4)+,113(a1)
	move.b	(a4)+,169(a1)
	move.b	(a4)+,225(a1)
	move.b	(a4)+,281(a1)
	move.b	(a4)+,337(a1)
	move.b	(a4)+,393(a1)
	addq.l	#2,d5
	
	bra	dochars
	
elist:

	lea	buff(pc),a1
	lea 11200(a1),a1

	move.l	#buff,source		* Source of preshift.
	move.l	a1,dest			* Destination of preshift.
	move.w	#28,chunks		* Number of chunks (16 pixel).
	move.w	#200,lines		* Number of lines per chunk.
	move.w	#15,times		* How many preshifts.

	bsr	pshift			* Now do preshifts.

	sub.l	#8,a1
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+

	move.l	a1,back
	lea	block(pc),a0
	rept	20
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr
	move.l	back,source		* Source of preshift.
	move.l	a1,dest			* Destination of preshift.
	move.w	#2,chunks		* Number of chunks (16 pixel).
	move.w	#20,lines		* Number of lines per chunk.
	move.w	#32,times		* How many preshifts.

	bsr	pshif2			* Now do preshifts.

	move.l	a1,diroffs

	moveq.l	#0,d4		* d4 addx
	move.w	#%0000001111111111,d5
	lea	multab(pc),a5

	move.w	#256-1,d7	* Calculate 2048 bytes of disting.
calcwob:
	lea	xsin(pc),a6
	and.w	d5,d4
	add.w	d4,a6
	move.w	(a6),d0
	addq.w	#4,d4

	move.w	d0,d1
	and.w	#$f,d0
	add.w	d0,d0
	add.w	d0,d0
	and.l	#%00000000000000000000000011110000,d1
	lsr.w	#3,d1
	move.l	(a5,d0.w),d3
	sub.l	d1,d3
	move.l	d3,(a1)+
	dbra	d7,calcwob

	move.l	a1,d0
	add.w	#256,d0
	move.b	#0,d0
	move.l	d0,scrnpos
	add.l	#32000,d0
	move.l	d0,scrn2

	move.l	scrnpos(pc),a0
	move.w	#3999,d0
clean:	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbra	d0,clean		* Clear screen.
	ifeq demo
	move.b	$fffffa07.w,sa1
	move.b	$fffffa09.w,sa2
	move.b	$fffffa13.w,sa3
	move.b	$fffffa19.w,sa4
	move.b	$fffffa1f.w,sa5
	move.b	$fffffa21.w,sa6
	move.b	$fffffa1b.w,sa7		* Save necessary MFP regs.
	move.b	$fffffa15.w,sa8
	move.b	$fffffa1d.w,sa9
	move.b	$fffffa25.w,sa10
	endc
	clr.b 	$fffffa07.w
	clr.b 	$fffffa09.w
	clr.b 	$fffffa13.w
	clr.b 	$fffffa15.w
	bclr.b	#3,$fffffa17.w		* Software End Of Interrupt mode.

	moveq.l	#1,d0
	bsr	mus

	lea	$ffff8246.w,a4
	move.l	$70.w,oldvbl		* Save old VBL.
	move.l	#vbl,$70.w		* Install my VBL.

	move.b	#0,$fffffa1b.w
	move.l	$120.w,oldhbl
	move.l	#hbl,$120.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w

	move.w	#$2300,sr

	moveq.l	#0,d1	
	moveq.l	#0,d2
	move.l	diroffs(pc),a2
	move.w	#%0000001111111111,d4
	lea	buff+(11200*15),a0
	move.l	a0,d5
	
key:	move.b	lcount(pc),d0
sync:	cmp.b	lcount(pc),d0
	beq.s	sync			* Wait for beam flyback.

	move.l	scrnpos(pc),a1

	addq.w	#4,d1
	and.w	d4,d1
	move.w	d1,d2
	move.l	d5,a0
	sub.l	(a2,d1.w),a0

soff	set	0	
	rept	20
	move.w	(a0)+,soff(a1)
soff	set	soff+8
	endr
	lea	16(a0),a0
	lea	160(a1),a1

	move.w	#199-1,d7
	moveq.l	#56,d3
	move.l	d3,d6

puwob:	addq.w	#4,d1
	and.w	d4,d1
	move.l	d5,a0
	add.l	d3,a0
	sub.l	(a2,d1.w),a0

soff	set	0	
	rept	20
	move.w	(a0)+,soff(a1)
soff	set	soff+8
	endr
	lea	16(a0),a0
	lea	160(a1),a1
	
	add.l	d6,d3
	
	dbra	d7,puwob
	
	move.w	d2,d1

	movem.l	d0-d1,-(sp)

	move.l	back(pc),a0
	move.l	naddr(pc),a1
	cmpi.l	#-99,(a1)
	bne.s	preph
	lea	nicbum(pc),a1
preph:	adda.l	(a1)+,a0
	move.l	a1,naddr
	move.l	scrnpos(pc),a1
	addq.l	#2,a1
	move.w	#20-1,d7
penus:	move.l	(a0)+,d0
	move.l	(a0)+,d1
knob	set	0
	rept	10
	move.l	d0,knob(a1)
	move.l	d1,knob+8(a1)
	move.l	d0,knob+3200(a1)
	move.l	d1,knob+3208(a1)
	move.l	d0,knob+6400(a1)
	move.l	d1,knob+6408(a1)
	move.l	d0,knob+9600(a1)
	move.l	d1,knob+9608(a1)
	move.l	d0,knob+12800(a1)
	move.l	d1,knob+12808(a1)
	move.l	d0,knob+16000(a1)
	move.l	d1,knob+16008(a1)
	move.l	d0,knob+19200(a1)
	move.l	d1,knob+19208(a1)
	move.l	d0,knob+22400(a1)
	move.l	d1,knob+22408(a1)
	move.l	d0,knob+25600(a1)
	move.l	d1,knob+25608(a1)
	move.l	d0,knob+28800(a1)
	move.l	d1,knob+28808(a1)
knob	set	knob+16
	endr
	lea	160(a1),a1
	dbra	d7,penus
	
	movem.l	(sp)+,d0-d1
	btst.b #0,$fffffc00.w
	beq key
	cmpi.b	#$39,$fffffc02.w
	bne	key			* Repeat if spacebar not pressed.
	
	
flush:	btst.b	#0,$fffffc00.w
	beq.s	fl_done
	move.b	$fffffc02.w,d0
	bra.s	flush
fl_done					* Flush keyboard.
	move.w	#$2700,sr
	ifeq demo
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
	move.l	oldvbl(pc),$70.w	* Re-install old VBL.
	move.l	oldhbl(pc),$120.w	* And old HBL.
	moveq.l	#0,d0
	bsr	mus
	move.w	#$2300,sr
	move.w	#$000,$ffff8240.w
	move.w	#$777,$ffff8242.w
	move.w	#$777,$ffff8244.w	
	move.w	#$777,$ffff8246.w	* Set colours to 'normal'.
	move.l	oldsp(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp			* Old stack & mode.
	clr.w	-(sp)
	trap	#1			* ... Terminate program.
	endc
	rts

vbl:	move.b	#0,$fffffa1b.w
	move.b	#8,$fffffa21.w
	move.b	scrn2+1(pc),$ffff8201.w
	move.b	scrn2+2(pc),$ffff8203.w
	move.l	scrnpos,-(sp)
	move.l	scrn2(pc),scrnpos
	move.l	(sp)+,scrn2
	bsr	mus+6
	lea	pal(pc),a3
	move.w	54(a3),-6(a4)
	move.w	(a3),(a4)
	move.w	(a3),4(a4)
	move.w	(a3)+,8(a4)
*	move.w	(a3)+,12(a4)
	move.b	#8,$fffffa1b.w
	addq.b	#1,lcount		* Signal flyback has occured.
	rte

hbl:	move.w	(a3),(a4)
	move.w	(a3),4(a4)
	move.w	(a3)+,8(a4)
*	move.w	(a3)+,12(a4)
	rte


******** PRESHIFTER ROUNTINE.

pshift:	move.w	lines(pc),d0		* Number of lines in D0.
	move.w	chunks(pc),d1		* Number of chunks in D1.

	move.l	source(pc),a0		* Source of preshift in A0.
	move.l	dest(pc),a1		* Destination address in A1.


*** This bit puts the end bits that are scrolled off into the buffer.*

nxshft:	move.l	source(pc),a0		* Source of preshift in A0.
nxtlin:	addq.l	#2,a0			* A0 now points to chunk end.
	
*** This bit shifts the planes and merges the buffers accordingly.   *
	
	move.l	source(pc),a0		* Load source into a0.
	move chunks(pc),d2
	subq #1,d2
mainsh:	move.w	(a0)+,d4		* Get 1st plane into D7.
	roxr.w	d4			* Scroll that plane in D4.
	move.w d4,(a1)+
	dbf d2,mainsh
	move.w	d1,chunks		* Restore chunk numbers.
	move.l	a0,source		* Increase source address.
	subq.w	#1,lines
	bne	nxtlin			* Repeat for number of lines.
	move.w	d0,lines

	move.l	a1,a2			* Don't smash A1!!
	moveq.l	#0,d7			* Make sure long D7 is clear.
	move.l	d7,d6			* Clear D6 as well.
	move.l	d7,d4			* Clear d4 too!
	moveq.w	#2,d4			* Get number of planes in D4.
	move.w	d1,d7			* Number of chunks in d7
	mulu	d4,d7			* Adjust end of chunk.
	mulu	d0,d7			* Times number of lines.
	sub.l	d7,a2			* Subtract from end of preshift.
	move.l	a2,source		* Make it as source.
	subq.w	#1,times
	bne	nxshft			* Repeat for number of shifts.
	rts				* Returns with A1 pointing to end


******** PRESHIFTER ROUNTINE.

pshif2:	move.w	lines(pc),d0		* Number of lines in D0.
	move.w	chunks(pc),d1		* Number of chunks in D1.

	move.w	times(pc),d2		* Number of shifts in D2.

	move.l	source(pc),a0		* Source of preshift in A0.
	move.l	dest(pc),a1		* Destination address in A1.


*** This bit puts the end bits that are scrolled off into the buffer.*

nxshf2:	move.l	source(pc),a0		* Source of preshift in A0.
nxtli2:	lea	buffer(pc),a3		* Load buffer address in A3.

	moveq.l	#0,d4			* Clear D4.
	move.l	d4,d7			* Clear D7.
	moveq.w	#2,d7			* Get planes into D7.
	add.w	d7,d7			* Now byte offset for planes.
	move.w	d1,d4			* D4 is now number of chunks.
	subq.l	#1,d4			* Adjust it for multiply.
	moveq.l	#4,d4			* Now chunk end (D4 X planes).
	add.l	d4,a0			* A0 now points to chunk end.
	
	rept	2
	move.w	(a0)+,d7		* Get 1st plane into D7.
	and.w	#1,d7			* Isolate bit/s in d7.
	moveq.l	#15,d6			* Make sure only word shifts.
	lsl.w	d6,d7			* Reverse shift D7 for wrap.
	move.w	d7,(a3)+		* Store it in wrap buffer.
	endr
	

*** This bit shifts the planes and merges the buffers accordingly.   *

	move.l	source(pc),a0		* Load source into a0.
mains2:	lea	buffer(pc),a3		* Load buffer address into A3.

	rept	2
	move.w	(a0)+,d7		* Get 1st plane into D7.
	move.w	d7,d4			* Put it into D4 as well.
	roxr.w	d4			* Scroll that plane in D4.
	move.w	d4,d5			* Store the shifted plane.
	and.w	#1,d7			* Isolate bit/s.
	moveq.l	#15,d6			* Make sure d6 is word only.
	lsl.w	d6,d7			* reverse shift D7 for merge.
	move.w	(a3),d4			* Get previous wrap bit/s.
	or.w	d4,d5			* And merge em in plane.
	move.w	d5,(a1)+		* And write new plane back!
	move.w	d7,(a3)+		* Store D7 in wrap buffer.
	endr

	subq.w	#1,chunks
	bne	mains2			* Repeat for number of chunks.
	move.w	d1,chunks		* Restore chunk numbers.
	move.l	a0,source		* Increase source address.
	subq.w	#1,lines
	bne	nxtli2			* Repeat for number of lines.
	move.w	d0,lines

	move.l	a1,a2			* Don't smash A1!!
	moveq.l	#0,d7			* Make sure long D7 is clear.
	move.l	d7,d6			* Clear D6 as well.
	move.l	d7,d4			* Clear d4 too!
	moveq.w	#2,d4			* Get number of planes in D4.
	add.w	d4,d4			* Chunk offset for planes.
	move.w	d1,d7			* Number of chunks in d7
	mulu	d4,d7			* Adjust end of chunk.
	mulu	d0,d7			* Times number of lines.
	sub.l	d7,a2			* Subtract from end of preshift.
	move.l	a2,source		* Make it as source.
	subq.w	#1,times
	bne	nxshf2			* Repeat for number of shifts.

	rts				* Returns with A1 pointing to end
					* of preshift data.

source:	ds.l	1			* Address where to grab chunks.
dest:	ds.l	1			* Address where to preshift them.
chunks:	ds.w	1			* Number of chunks of object.
lines:	ds.w	1			* Number of lines of object.
times:	ds.w	1			* How many times to shift it.

buffer:	ds.w	2

reverse:dc.w	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
					* Shift values for wraparound.

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

					* of preshift data.

oldsp:	ds.l	1			* Space for old stack address.
oldvbl:	ds.l	1			* Space for old VBL address.
oldhbl:	ds.l	1

back:	ds.l	1

scrnpos:ds.l	1			* Screen position (crafty place!).
scrn2:	ds.l	1

diroffs:ds.l	1

linoff:	dc.w	0

naddr:	dc.l	nicbum
nicbum:	
mangle	set	0
	rept	32
	dc.l	mangle
mangle	set	mangle+160
	endr
	dc.l	-99

addx:	dc.w	0
xstemp:	dc.w	0

chars:	even
	incbin	8font.dat

xsin:	even
	incbin	xsin.dat

pal:	even
	incbin	wobble.pal
block:	even
	incbin	block.dat
mus:	even
	incbin	ploddish.czi
	
bpal:	even
	dc.w	$000,$777,$102,$777,$203,$777,$304,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777

lcount:	dc.b	0
	ifeq demo
sa1:	ds.b	1
sa2:	ds.b	1
sa3:	ds.b	1
sa4:	ds.b	1
sa5:	ds.b	1
sa6:	ds.b	1
sa7:	ds.b	1
sa8:	ds.b	1
sa9:	ds.b	1
sa10:	ds.b	1
	endc

text:	even
*	dc.b	'S------------------------------------------------------E',$a
	dc.b	'        WELCOME TO THE INNER CIRCLE DECADE DEMO!        ',$a
	dc.b	'              Members of Inner Circle are:              ',$a
	dc.b	'                   ELECTRONIC IMAGES                    ',$a
	dc.b	'                    THE RESISTANCE                      ',$a
	dc.b	'                    THE FINGERBOBS                      ',$a
        dc.b	'                   THE RED HERRINGS                     ',$a
	dc.b	'                        HOTLINE                         ',$a
	dc.b	'                       ST SQUAD                         ',$a
	dc.b	'                                                        ',$a
	dc.b	'      This demo is public domain and has NOTHING to     ',$a
	dc.b	'        do with Budgie UK.  Sorry but we couldn''t       ',$a
	dc.b	'            handle the bit about no swearing.           ',$a
	dc.b	'                                                        ',$a
	dc.b	'      This disk is a 10 sector double sided format.     ',$a
	dc.b	'      To copy the disk use a good copier like Acopy     ',$a
	dc.b	'                    or Fastcopy 3.                      ',$a
	dc.b	'                                                        ',$a
	dc.b	'         ~ This Screen By Electronic Images ~           ',$a
	dc.b	'              Coding : The Phantom (E.I)                ',$a
	dc.b	'              Grafix : Master (Resistance)              ',$a
	dc.b	'               Music : Count Zero (E.I)                 ',$a
	dc.b	'                                                        ',$a
	dc.b	'     DMA Loader and files by Griff of The Resistance    ',$a
	dc.b	'       This demo will boot from an external drive!      ',$a
	dc.b	'         INNER CIRCLE ~~~~ USES NO RIPPED CODE!         ',$a
	dc.b	0
	even

multab:	
moff	set	0
	rept	16
	dc.l	moff
moff	set	moff+11200
	endr

buff:	even