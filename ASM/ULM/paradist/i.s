overscan:equ 0
; Double Megadistorter by Gunstick   (c) ULM 1990
; we know! it's long, but it works ! And it's from ULM !!!

parallax	equ	0
parallay	equ	0

bus	equ	10



	pea	start(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

noswreset:
	rts
start:
	move	#$2700,sr
	move.l	#noswreset,$46e.w
	bsr	waitvbl

	lea	$ffff8240.w,a2
	lea	oldpal,a3

	movem.l (a2),d0-d7
	movem.l d0-d7,(a3)
	movem.l hwpalette,d0-d7
	movem.l d0-d7,(a2)

	lea	$ffff8201.w,a0
	movep.w 0(a0),d0
	lea	screenad1,a2
	move.w	d0,(a2)

	move.l	#screen,d0
	add.l	#255,d0
	and.l	#$ffff00,d0
	lea	screenad2,a2
	move.l	d0,(a2)
	movea.l d0,a2
	ror.l	#8,d0
	movep.w d0,0(a0)

	move.w	#0,-(sp)
	move.l	a2,-(sp)
	move.l	a2,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.l	screenad2,d0
	sub.l	#160*6,d0
	move.l	d0,screenadr
;	addi.l	#8*5-64,screenadr

	movea.l screenad2,a0
	move.l	#9999,d0
clear_loop:
	clr.l	(a0)+
	dbra	d0,clear_loop

	movea.l screenad2,a0
;	movem.l graphic,d6-d7
	movem.l black,d6-d7
	move.w	#285,d2
allline:
	ifne overscan
	move.w	#20,d1
	endc
	ifeq overscan
	move.w	#27,d1
	endc

alles:
	move.l	d6,(a0)+
	move.l	d7,(a0)+
	dbra	d1,alles
	ifeq overscan
	addq.l	#6,a0
	endc

	dbra	d2,allline

	pea	message
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp

	bsr	psginit

	lea	oldres,a0
	move.b	$ffff8260.w,(a0)
	bsr	waitvbl
	move.b	#0,$ffff8260.w

	move.b	#18,$fffffc02.w
	bsr	waitvbl
	move.b	#26,$fffffc02.w

	move.l	usp,a0
	move.l	a0,savusp
	bsr	screen2
	move.l	savusp,a0
	move.l	a0,usp

	move.b	#20,$fffffc02.w
	bsr.s	waitvbl
	move.b	#8,$fffffc02.w

	bsr.s	waitvbl
	move.b	#2,$ffff820a.w
	bsr.s	waitvbl
	move.b	#2,$ffff820a.w
	move.b	oldres,$ffff8260.w
	lea	$ffff8201.w,a0
	moveq	#0,d0
	move.w	screenad1,d0
	movep.w d0,0(a0)
	lsl.l	#8,d0

	move.w	#0,-(sp)
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	bsr.s	psginit

	lea	oldpal,a0
	lea	$ffff8240.w,a1
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)

	bsr.s	waitvbl
	move	#$2300,sr

	rts
savusp:	ds.l	1

waitvbl:

	move.b	$ffff8203.w,d0
	lsl.w	#8,d0
	lea	$ffff8207.w,a0
no_vbl:
	movep.w 0(a0),d1
	cmp.w	d0,d1
	bne.s	no_vbl

	rts

psginit:
	lea	psginittab,a0
nextinit:
	move.b	(a0)+,d0
	cmp.b	#$ff,d0
	beq.s	initend
	move.b	(a0)+,d1
	move.b	d0,$ffff8800.w
	move.b	d1,$ffff8802.w
	bra.s	nextinit
initend:
	rts

	;--------------------------------------------------------

screen2:

;free d0 d1 d2 d3 d4 d5 d6 d7 a0 a1 a2 a3 a4 a5 a6    usp
	move	sr,-(sp)
	move	#$2700,sr
	move.l	sp,stack
;	clr.b	lowbyte

	move.w	#5000,d0
aaa	dbf	d0,aaa

loop:
	not.w	$ffff8240.w

	move.b	#0,$fffffa19.w	;stop timer
	move.b	#245,$fffffa1f.w	;244
asd	equ	7
	move.b	#32,$fffffa07.w
	move.b	#0,$fffffa0b.w	;clr pending
	not.w	$ffff8240.w

	dcb	$4e71,87
	move.b	#asd,$fffffa19.w


	btst	#0,$fffffc00.w
	beq	no_key

	move.b	$fffffc02.w,d0

	cmpi.b	#57,d0
	bne.s	no_key

	movea.l stack,sp
	move	(sp)+,sr
	rts

no_key:

	move.b	#0,$fffffa0b.w	;clr pending
no_int:
	btst	#5,$fffffa0b.w
	beq.s	no_int

	bra	loop


prt:
	dc.b 27,"Y",32+20,32+1,"     000"
str:	dc.b "0    ",0



	even
psginittab:dc.b 0,$ff,1,$ff,2,$ff,3,$ff,4,$ff,5,$ff,6,0
	dc.b 7,$7f,8,7,9,7,10,7,$ff,0
	even
hwpalette:
	dc.w $0700,$0707,$0474,$0777,$0606,$0505,$0404,$303
	dc.w $777,$666,$555,$444,$333,$222,$111,$002 
graphic:
	dc.w $d555,$3333,$0f0f,$ff
message:
	dc.b "Mfp clock detektor:",13,10,"by gunstick from U L M",13,10
	dc.b "The line should move",13,10,"this way : --->",13,10
	dc.b "with bytespeed",13,10,"and down one line after",13,10
	dc.b "each passage on the screen.",13,10,"Some flickering if a key",13,10
	dc.b "is pressed is normal",13,10,"Exit with space",13,10,13,10
	dc.b "Mfp clock detektor:",13,10,"by gunstick from U L M",13,10
	dc.b "The line should move",13,10,"this way : --->",13,10
	dc.b "with bytespeed",13,10,"and down one line after",13,10
	dc.b "each passage on the screen.",13,10,"Some flickering if a key",13,10
	dc.b "is pressed is normal",13,10,"Exit with space",13,10,13,10
	dc.b "Mfp clock detektor:",13,10,"by gunstick from U L M",13,10
	dc.b "The line should move",13,10,"this way : --->",13,10
	dc.b "with bytespeed",13,10,"and down one line after",13,10
	dc.b "each passage on the screen.",13,10,"Some flickering if a key",13,10
	dc.b "is pressed is normal",13,10,"Exit with space",13,10,0
	even
lowbyte:
	dc.b 0

	
hwscrolldat:			

	even
black:
	ds.l 8

	section	bss
stack:	ds.l 1
oldpal: ds.w 16
oldres: ds.w 1
screenad1:ds.w 1
screenad2:ds.l 1
screenadr:ds.l 1
logbase:	ds.l	1	;screen where to put scroll
tabentry:
	ds.l	1	;for hwscroll
cpybufdest:
	ds.l	1	;copy from (this+4buffers-1scroll) to (this) 
shiftcnt:
	ds.w	1	;counter for shifter
count:
	ds.l	1	;for some dbf without register
nextscrn:	
	ds.l	1	;points to next screenadress to be used
distcalc:
	ds.w	1
distwaveptr:
	ds.l	1	;pointer in one distwave
wavetabptr:
	ds.l	1	;pointer to the next wave to be played

disttableptr:
	ds.l	1	;pointer to scrolldisttable
disttable:
	ds.w	20*2	;scrolldisttable


mdistadjustptr:
	ds.l	1	;pointer to the distorter adjust table
mdistadjust:
	ds.w	300*2	;adjusttable for the two distorters

linebuffbegin:
textptr:
	ds.l	1	;letter not completly copied into buffer (forward)
bufptr:
	ds.l	1	;pos where graphic is added in preshift 0
bufcnt:
	ds.w	1	;which one of the 26 routs to be used to copy
shift:
	ds.w	1	;which preshift to copy
buffer:
	ds.l	2*26*16	;16 shifts of the 1st line of the scrolling
linebuffend:
screen:
	ds.l	8000
	end