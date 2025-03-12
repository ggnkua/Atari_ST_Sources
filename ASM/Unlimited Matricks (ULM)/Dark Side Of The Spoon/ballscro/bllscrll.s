; The ball scroller by Gunstick from Unlimited Matricks.  As usual a big fuck to Fire Crackeres and Hemoroids (shit groups with even more shitty names) for spreading and using other people routines. So if you read this: You are LAMERS !!!
													HMD: on est de nouveau copins...
def_version	equ	10
d0_for_mcp	equ	0
mcp_adr		equ	$500
keyboard	set	10

scrollhigh	equ	8

test	equ	10

	ifeq	def_version
	opt	d-
	org	$2500
keyboard	set	0
	endc

	section	text
x:
	ifne	def_version
	pea	start(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1
	endc

start:
	lea	oldcpu(pc),a0
	move.l	sp,(a0)+
	lea	my_stack,sp
	move.w	sr,(a0)+
	move.w	#$2700,sr
	move.l	usp,a1
	move.l	a1,(a0)+

	ifne	def_version
	moveq	#$12,d0
	bsr	ikbd_wrt
	moveq	#$1a,d0
	bsr	ikbd_wrt

	move.l	$408.w,old_408
	move.l	#exit_with_408,$408.w
	endc

	lea	oldvideo(pc),a0
	move.b	$ffff8260.w,(a0)+
	move.b	$ffff820a.w,(a0)+
	move.l	$ffff8200.w,(a0)+
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)

	movem.l	black(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	oldvectors(pc),a0
	move.l	$68.w,(a0)+
	move.l	$70.w,(a0)+
	move.l	$114.w,(a0)+
	move.l	$118.w,(a0)+
	move.l	$120.w,(a0)+
	move.l	$134.w,(a0)+
	move.l	#nix,$68.w
	move.l	#nix,$70.w
	move.l	#nix,$114.w
	ifeq	keyboard
	move.l	#nix,$118.w
	endc
	move.l	#nix,$120.w
	move.l	#nix,$134.w

	lea	oldmfp(pc),a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$fffffa19.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa1d.w,(a0)+

	bclr	#3,$fffffa17.w
	clr.b	$fffffa07.w
	ifeq	keyboard
	clr.b	$fffffa09.w
	endc
	ifne	keyboard
	move.b	#%01000000,$fffffa09.w
	endc

	bsr	waitvbl1
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w

	bsr	psginit

	bsr	mfp_test

	bra	screen
back:

	lea	my_stack,sp

	bsr	psginit

	lea	oldmfp(pc),a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa19.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa1d.w

	lea	oldvectors(pc),a0
	move.l	(a0)+,$68.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$114.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.l	(a0)+,$134.w

	move.b	#2,$ffff820a.w
	bsr.s	waitvbl1
	move.b	#0,$ffff820a.w
	bsr.s	waitvbl1
	move.b	#2,$ffff820a.w
	bsr.s	waitvbl1

	lea	oldvideo(pc),a0
	move.b	(a0)+,$ffff8260.w
	move.b	(a0)+,$ffff820a.w
	move.l	(a0)+,$ffff8200.w
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	ifne	def_version
	moveq	#$14,d0
	bsr.s	ikbd_wrt
	moveq	#$8,d0
	bsr.s	ikbd_wrt
	endc

	lea	oldcpu(pc),a0
	move.l	(a0)+,sp
	move.w	(a0)+,sr
	move.l	(a0)+,a1
	move.l	a1,usp

	ifne	def_version
	move.l	old_408(pc),$408.w

	rts
	endc

	ifeq	def_version
	moveq	#d0_for_mcp,d0
	jsr	mcp_adr.w
	endc

psginit:
	moveq	#10,d0
	lea	$ffff8800.w,a0
nextinit:
	move.b	d0,(a0)
	move.b	#0,2(a0)
	dbf	d0,nextinit
	move.b	#7,(a0)
	move.b	#$7f,2(a0)
	move.b	#14,(a0)
	move.b	#$26,2(a0)
	rts

waitvbl1:
	move.w	#9000,d0
waitvbl2:
	dbf	d0,waitvbl2
waitvbl:
	lea	$ffff8209.w,a0
	movep.w	-8(a0),d0
waitvbl3:
	tst.b	(a0)
	bne.s	waitvbl3
	movep.w	-4(a0),d1
	cmp.w	d0,d1
	bne.s	waitvbl3
	rts

ikbd_wrt:
	lea	$fffffc00.w,a0
ik_wait:
	move.b	(a0),d1
	btst	#1,d1
	beq.s	ik_wait
	move.b	d0,2(a0)
	rts

mfp_test:
	move.w	#$2700,sr

	bsr.s	waitvbl
	bsr.s	waitvbl

	move.b	#0,$fffffa19.w
	move.b	#255,$fffffa1f.w
	move.b	#$20,$fffffa07.w
	move.b	#0,$fffffa13.w

	moveq	#30,d1
	lea	$ffff8209.w,a0
check_mfp_s1:
	move.b	(a0),d0
	beq.s	check_mfp_s1
	sub.w	d0,d1
	lsl.w	d1,d1
	move.b	#0,$fffffa0b.w
	move.b	#1,$fffffa19.w

	moveq	#-1,d0
mfp_test_loop:
	dbf	d0,mfp_test_loop

	moveq	#0,d0
	move.b	$fffffa1f.w,d0
	move.b	#0,$fffffa19.w
	cmp.w	#$9b,d0
	ble.s	mfp_of_my_st
	move.w	#-1,mfp_type
mfp_of_my_st:
	rts

	ifne	def_version
	dc.l	'XBRA'
	dc.l	'TFSY'
old_408:
	dc.l	0
exit_with_408:
	bsr.s	exit
	move.l	old_408(pc),a0
	jmp	(a0)
	endc

exit:
	movem.l	black(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	bra	back

nix:
	rte

oldcpu:		ds.w	4
oldvideo:	ds.w	19
oldvectors:	ds.l	6
oldmfp:		ds.w	5
mfp_type:	ds.w	1
black:		ds.l	16


	;this part is the real screen...

screen:
	lea	bss_start,a0
	lea	bss_end,a1
	movem.l	black,d1-d7/a2-a6
clear_loop:
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	d1-d7/a2-a6,24*4(a0)
	lea	36*4(a0),a0
	cmp.l	a0,a1
	bpl.s	clear_loop

	move.l	#screenmem,d0
	add.l	#255,d0
	and.l	#$ffff00,d0
	move.l	d0,screenad2
	ror.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)

	move.l	#sourcegrafix+60-19*80,sourcead
	move.l	screenad2,screenad1
	add.l	#32000+256*8,screenad2
	moveq	#4,d0
	jsr	music

	lea	fond,a0
	move.l	screenad1,a1
	move.l	screenad2,a2
	lea	3*8(a1),a1
	lea	3*8(a2),a2
	move.w	#199,d0
mkfond:
	rept	3
	movem.l	(a0)+,d1-d7
	movem.l	d1-d7,(a1)
	movem.l	d1-d7,(a2)
	lea	28(a1),a1
	lea	28(a2),a2
	endr

	movem.l	(a0)+,d1-d5/a3-a4
	movem.l	d1-d5/a3-a4,(a1)
	movem.l	d1-d5/a3-a4,(a2)
	lea	76(a1),a1
	lea	76(a2),a2

	dbf	d0,mkfond

	movem.l	grafik,d2-d3
	move.w	#7,d1
	lea	4+16(a1),a1
	lea	4+16(a2),a2
mkovs:
	move.w	#25,d0
mkovsline:
	movem.l	d2-d3,(a1)
	movem.l	d2-d3,(a2)
	addq.l	#8,a1
	addq.l	#8,a2
	dbf	d0,mkovsline
	lea	22(a1),a1
	lea	22(a2),a2
	dbf	d1,mkovs
	

	lea	sourcegrafixend,a0
	lea	sourcegrafix2end,a1
	move.l	#(sourcegrafiklen)/2,d0
mkbyteshift:
	move.w	-(a0),d1
;	rol.w	#4,d1
	move.w	d1,d2
	and.w	#$f,d2
	add.w	d2,d2
	move.w	nibbletab(pc,d2.w),-(a1)
	ror.w	#4,d1
	move.w	d1,d2
	and.w	#$f,d2
	add.w	d2,d2
	move.w	nibbletab(pc,d2.w),-(a1)
	ror.w	#4,d1
	move.w	d1,d2
	and.w	#$f,d2
	add.w	d2,d2
	move.w	nibbletab(pc,d2.w),-(a1)
	ror.w	#4,d1
	move.w	d1,d2
	and.w	#$f,d2
	add.w	d2,d2
	move.w	nibbletab(pc,d2.w),-(a1)
	subq.l	#1,d0
	bne.s	mkbyteshift

	bra.s	continue
nibbletab:
	dc.w	$0000,$1111,$2222,$3333,$4444,$5555,$6666,$7777
	dc.w	$8888,$9999,$aaaa,$bbbb,$cccc,$dddd,$eeee,$ffff
continue:
	lea	sourcegrafix2,a0
	lea	sourcegrafix2end,a1
	move.l	#150*80,d0
mkpanikbuffer:
	move.l	(a0)+,(a1)+
	dbf	d0,mkpanikbuffer
	ifeq	test
	move.l	#1000,d0
testpanikbuf:
	move.l	#$ffffffff,(a1)+
	dbf	d0,testpanikbuf
	endc

	;insert overscan
	lea	do_project+36820,a0	;piffometer
serarch_nocrash:
	cmp.w	#$c642,(a0)+		;look for "and.w d2,d3"
	bne.s	serarch_nocrash
	move.w	#$4ed3,-2(a0)		;replace with jmp (a3)
	move.l	a0,afteroverscan	

	add.l	#8*23+6,sourcead

	bsr	waitvbl
loop:

	move.b	$fffffc02.w,d0
	tst.w	$1f0.w
	bmi.s	nodemo
	subq.w	#1,$1f0.w
	beq	exit
nodemo:

	cmp.b	#57,d0
	beq	exit
;	tst.w	gotkey
;	beq.s	keyreleased
;	cmp.b	#$80,d0
;	blo.s	no_key
;	clr.w	gotkey
keyreleased:
	subq.w	#1,hz25
	bpl.s	no_key
	move.w	#2,hz25



	cmp.b	#72,d0	;cursor up
	bne.s	notup
	add.l	#80*4,sourceadder
;	move.w	#-1,gotkey
notup:
	cmp.b	#75,d0	;cursor left
	bne.s	notleft
	add.l	#2,sourceadder
;	move.w	#-1,gotkey
notleft:
	cmp.b	#77,d0	;cursor right
	bne.s	notright
	sub.l	#2,sourceadder
;	move.w	#-1,gotkey
notright:
	cmp.b	#80,d0	;cursor down
	bne.s	notdown
	sub.l	#80*4,sourceadder
;	move.w	#-1,gotkey
notdown:


no_key:
	move.l	sourceadder,d0
	cmp.l	#sourcegrafiklen*4,d0
	bmi.s	adder1ok
	sub.l	#sourcegrafiklen*4,d0
adder1ok:
	cmp.l	#-sourcegrafiklen*4,d0
	bpl.s	adder2ok
	add.l	#sourcegrafiklen*4,d0
adder2ok:
	move.l	sourcead,a0
	move.l	d0,sourceadder
	add.l	d0,a0
	ifeq	0	test
	cmp.l	#sourcegrafixmiddle,a0
	bmi.s	nohops
	sub.l	#sourcegrafiklen*4,a0
nohops:
	cmp.l	#sourcegrafix,a0
	bpl.s	nohops2
	add.l	#sourcegrafiklen*4,a0
nohops2
	endc
	move.l	a0,sourcead
	
;	not.w	$ffff8240.w

	;********************************************


nachschub:
	subq.w	#1,letterpos
	bpl.s	letternotend
	cmp.w	#-2,letterpos
	bpl.s	autospace
	move.w	#7,letterpos
	move.l	scrolltextpos,a0
	moveq	#0,d0
wraaaaaaaaap:
	move.b	(a0)+,d0
	cmp.b	#-1,d0
	bne.s	scrolltextnochnichtamende
	lea	scrolltext,a0
	bra.s	wraaaaaaaaap
autospace:
	move.l	#autospacedat,letteradr
;	add.w	#1,letterpos
	bra.s	letternotend
scrolltextnochnichtamende:
	move.l	a0,scrolltextpos
	lsl.w	#3,d0
	move.l	#font,letteradr
	add.l	d0,letteradr
letternotend:

	subq.w	#1,buffcnt
	bhs.s	nobuffwrap
	move.l	buffpos,d0
	move.l	d0,oldbuffpos
	add.l	#scrollhigh*2,d0
	sub.w	#1,rightcolums
	cmp.l	#scrollhigh*52,d0
	bne.s	nocpyroutwrap
	moveq	#0,d0
	move.w	#25,rightcolums
nocpyroutwrap:
	move.l	d0,buffpos
	move.w	#15,buffcnt
	move.l	#scrollbuff,a1
	move.l	a1,actbuff
;	lea	font,a0
	move.l	letteradr,a0
	lea	0*scrollhigh(a1),a2	;wir wollen doch am ende wurschteln
	lea	(a2,d0),a1
	add.l	oldbuffpos,a2
	move.b	(a0)+,d0		;lese BITkolonne im font
	move.w	#scrollhigh-1,d2
preshift2:
	move.w	(15*52)*scrollhigh(a2),d1	;lese letztes word
	add.b	d0,d0			;bit raus
	addx.w	d1,d1			;bit rein
	move.w	d1,(a1)+		;schreibe neues word
	addq.w	#2,a2
	dbf	d2,preshift2

	bra.s	buffwrapped
nobuffwrap:
	move.l	letteradr,a0
	move.l	actbuff,a1
	lea	0*scrollhigh(a1),a2	;wir wollen doch am ende wurschteln
	add.l	buffpos,a1
;	lea	(a2,d0),a1
;	add.l	oldbuffpos,a2
	
	move.b	(a0)+,d0		;lese BITkolonne im font
	move.w	#scrollhigh-1,d2
preshift:
	move.w	-52*scrollhigh(a1),d1	;lese letztes word
	add.b	d0,d0			;bit raus
	addx.w	d1,d1			;bit rein
	move.w	d1,(a1)+		;schreibe neues word
	dbf	d2,preshift
			
buffwrapped:
	move.l	a0,letteradr		


	;********************************************

	move.l	screenad1,a0
	lea	32042(a0),a0
	move.l	actbuff,a1
	add.l	buffpos,a1
	move.w	rightcolums,d0		;26 colonnen
cpyscrllbegin:

vpos set 0
	rept	scrollhigh
	move.w	(a1)+,230*vpos(a0)	;1 colonne
vpos set vpos+1
	endr

	addq.l	#8,a0

	dbf	d0,cpyscrllbegin


	move.l	actbuff,a1
;	add.l	buffpos,a1
	moveq	#25,d0
	sub.w	rightcolums,d0		;26 colonnen
cpyscrllend:

vpos set 0
	rept	scrollhigh
	move.w	(a1)+,230*vpos(a0)	;1 colonne
vpos set vpos+1
	endr

	addq.l	#8,a0

	dbf	d0,cpyscrllend




	ifeq	test
	move.l	actbuff,a0
	lea	scrollhigh*2(a0),a0
	move.w	#(scrollhigh*50)/(4*4)-1,d0
rotbuff:
	movem.l	(a0)+,d1-d4
	movem.l	d1-d4,-scrollhigh*2-4*4(a0)
	dbf	d0,rotbuff
	endc

	add.l	#52*scrollhigh,actbuff


	movem.l	palette,d0-d7
	movem.l	d0-d7,$ffff8240.w

;	not.w	$ffff8240.w

	lea	$ffff8209.w,a0
	moveq	#30,d2
sync:
	move.b	(a0),d0
	beq.s	sync
 	sub.w	d0,d2
	lsl.l	d2,d2
;	not.w	$ffff8240.w
	nop
	nop
	nop
	nop
	move.l	sourcead,d1
	move.l	screenad2,a1
	move.l	screenad1,screenad2
	move.l	a1,screenad1
	move.l	screenad1,d0
	lsr.l	#8,d0
	lea	$ffff8201.w,a2
	movep.w	d0,(a2)
	move.l	d1,a0
	add.l	#$8000,a0
	move.l	a0,a2
	add.l	#$10000,a2
	addq.l	#6,a1		;plane adjust
	lea	overscanrout(pc),a3
	bsr	do_project
	jsr	music+8


	bra	loop

overscanrout:
	lea	scrollcols-2,a6
	move.w	(a6),d4
	addq.w	#2,d4
	move.w	d4,(a6)+
	andi.w	#%1110,d4
	add.w	d4,a6
;	nop
;	nop
	dcb	22-15-4,$4e71
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movem.l	d4-d7,$ffff8240.w
	move.l	(a6)+,d4
	move.l	(a6)+,d5
	move.b	#0,$ffff820a.w
	move.b	#0,$ffff820a.w
	movem.l	(a6)+,d6-d7
	dcb	8-7,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d4-d6,$ffff8250.w
;	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.l	d7,$ffff825c.w
	move.b	#2,$ffff820a.w
	ifeq	0;test
	dcb	83-4-2-11,$4e71
	lea	16(a6),a6
	movem.l	(a6)+,d4-d7
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d4-d6,$ffff8250.w
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.l	d7,$ffff825c.w

	rept	scrollhigh-2
	dcb	87-4-13,$4e71
	lea	16(a6),a6
	movem.l	(a6)+,d4-d7
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d4-d6,$ffff8250.w
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.l	d7,$ffff825c.w
	endr

	dcb	87-21-4,$4e71
	movem.l	black,d4-d7/a3-a6
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	endc

	movem.l	d4-d7/a3-a6,$ffff8240.w
	dcb	87-20,$4e71
	move.b	#0,$ffff820a.w
	dcb	20,$4e71
	move.b	#2,$ffff820a.w
;	not.w	$ffff8240.w
	move.w	#10,d7
ovs:	dbf	d7,ovs
;	not.w	$ffff8240.w
	and.w	d2,d3
afteroverscan:	equ	*+2
	jmp	0

;here starts the data section
	section	data

do_project
	incbin	proj_4n.bin
;	incbin	proj_m.bin
;	incbin	ball.bin
	rts
palette:
	dc.w	$000,$01,$2,$3,$4,$5,$6,$7
	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
music:
	incbin	e:\musix\tfmx\dragonf1.bin
	even
grafik:
	dc.w	%0101010101010101
	dc.w	%0011001100110011
	dc.w	%0000111100001111
	dc.w	%1111111111111111

	dc.w	0	;megadist position
scrollcols:
;	rept	8
;	dc.w	$777,$777,$777,$777,$777,$777,$777,$777
;	dc.w	$777,$777,$777,$777,$777,$777,$777,$777
;	endr
	incbin	back.bin
;	incbin	back3.bin
;	incbin	back31.bin
;	incbin	back4.bin

scrolltext:
	incbin	text.bin
	dc.b	-1
	even
font:

	incbin	font.bin
autospacedat:
	dc.w	$ffff
letterpos:	dc.w	0
letteradr:	dc.l	font
scrolltextpos	dc.l	scrolltext
buffcnt:	dc.w	0
actbuff:	dc.l	scrollbuff
fontpos:	dc.l	font	
buffpos:	dc.l	0
rightcolums:	dc.w	25
;	begin of scrunched data section
sourcegrafix:
sourcegrafix2:
sourcegrafixmiddle:	equ	*+150*80
;	ds.l	32000/4
;	incbin	pic1.doo
	incbin	final.dat
;	incbin	test1.doo
sourcegrafixend:
fond:
	incbin	fond.bin
;end of data section
dataend:
sourcegrafiklen:	equ	sourcegrafixend-sourcegrafix
schrott:	equ	sourcegrafiklen-((dataend-sourcegrafix)/4)
	section	bss
;please leave all section indications unchanged...
bss_start:		;here starts the bss
	ds.l	schrott	;piclen in bytes = len in longs
sourcegrafix2end:
	ds.l	150*80	;for panic buffer (ball is 145 lines high)
	ds.l	10000
hz25:		ds.w	1
stack:		ds.l	1
screenad1:	ds.l	1
screenad2:	ds.l	1
sourcead:	ds.l	1
sourceadder:	ds.l	1
oldbuffpos:	ds.l	1
gotkey		ds.w	1
scrollbuff:
		ds.w	26*16*scrollhigh
screenmem:		
 		ds.l	32000/4
		ds.l	32000/4
		ds.l	230*20
		ds.l	64
		ds.l	100
my_stack:
bss_end:		;here ends the bss
	end

