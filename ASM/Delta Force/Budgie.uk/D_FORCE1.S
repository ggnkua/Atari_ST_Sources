* sept 21, 1988   feb 1990
* displays a large horizontal scroll (text or redefined graphics)
* uses v/b $70  , mfp $118 (k/board) and mfp $120 (B timer)
* uses SR 2500
* uses chain command
* accesses video chip at $ffff8201/3 direct
* revectors $118 handler
* uses CONSTAT during mfp handler
* use of INCBIN directive
* binary version visible trough Monst2 in Devpac (delta.prg)
* with free ram acc and bicalc acc, this will load at $250b6 to 2831c (rte)
* 28d1e is character set   2d4d2 is closing palette
* 2d551 is musik.dat   2d55d is text   2d86c is colors  2d940 is cycling


m_shrink
	MOVEA.L	A7,A5
	MOVEA.L	4(A5),A5	
	MOVE.L	12(A5),D0
	ADD.L	20(A5),D0	
	ADD.L	28(A5),D0	
	ADDI.L	#$800,D0
	move.l	d0,d1		these 5 lines specific to delta
	add.l	a5,d1		without them, musick.tos
	andi.l	#$fffffffe,d1	loads but doesn't execute
	movea.l	d1,a7		and hangs up
	MOVE.L	D0,-(SP)
	MOVE.L	A5,-(A7)
	CLR.W	-(A7)	
	MOVE.W	#$4A,-(A7)
	TRAP	#1		
	LEA	$0C(A7),A7

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldstack
	move.w	#3,-(sp)
	trap	#$0e
	addq.l	#2,sp
	move.l	d0,logbase
	dc.w	$a00a
	move.b	#%11111110,$ff820a	go 50 hz


	move.l	#dta,-(sp)	set up dta section to find size
	move.w	#$1a,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#0,-(sp)	normal file
	move.l	#name,-(sp)	look up attribute
	move.w	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp

	tst	d0		file found?
	bne	exit		exit

	lea	dta,a0
	move.l	26(a0),d5	size
	move.l	d5,txt_size


* load a file
	MOVE.W	#0,-(A7)	open a file
	pea	name(pc)
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	add.l	#8,sp
	MOVE.W	D0,d7		handle


	MOVE.L	#budgie,-(sp)	load	at this address 
	MOVE.L	d5,-(A7)	size
	MOVE.W	d7,-(A7)	handle
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	ADDA.L	#$C,A7


	MOVE.W 	d7,-(SP)	close
	MOVE.W 	#$3E,-(SP)
	TRAP 	#1
	ADDQ.L 	#4,SP





	bsr	_start
	dc.w	$a009
exit	
	bsr	fred		restore mfp if necessary
	pea	palette		retrieve palette
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	#0,-(sp)	set screen paras
	move.l	logbase,-(sp)
	move.l	logbase,-(sp)
	move.w	#5,-(sp)
	trap	#14
	adda.l	#12,sp
	move.l	oldstack,-(sp)	back user mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

setmedrez
	move.w	#1,-(A7)	0=low res
	MOVE.L	#-1,-(A7)	-1=ignore physbase
	MOVE.L	#-1,-(A7)	-1=ignore logbase
	MOVE.W	#5,-(A7)
	TRAP	#14		
	LEA	$0C(A7),A7	


quit	clr.w	-(sp)
	trap	#1		
*	end
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
_start	
	move.w	#0,l_2d9c8
	move.w	#$ffff,l_2d9ca
	move.w	#1,l_2da22
	move.l	logbase,l_2d9d4
	move.l	#l_2d8e2,l_2da2c  $2D82 is full of $0777's
	move.l	#l_2d940,l_2da32  $2D940 is 00 00 00 01 00 etc
	move.w	#5,l_2da36
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp	get rez
	cmpi.w	#2,d0
	bne	st1
	move.l	#rez_message,d0
	bra	print
st1	move.l	#$40100,-(sp)
	move.w	#$48,-(sp)
	trap	#1		reserve
	addq.l	#6,sp
	tst.l	d0
	bne	st2
	move.l	#mem_message,d0 not enough memory
	bra	print
st2	move.l	d0,l_2d9a0	pointer to start of block
	lsr.l	#8,d0
	addq.w	#1,d0
	ext.l	d0
	lsl.l	#8,d0
	move.l	d0,l_2d9a4	same (/8*8)
	addi.l	#$8000,d0	now $8000 further on
	move.l	d0,l_2d9a8
	addi.l	#$8000,d0
	move.l	d0,l_2d9ac
	addi.l	#$8000,d0
	move.l	d0,l_2d9b0
	addi.l	#$8000,d0
	move.l	d0,l_2d9b4
	addi.l	#$8000,d0
	move.l	d0,l_2d9b8
	addi.l	#$8000,d0
	move.l	d0,l_2d9bc
	addi.l	#$8000,d0
	move.l	d0,l_2d9c0
	move.l	#$1f40,d0	counter
	movea.l	l_2d9a4,a0
st3	clr.l	(a0)+		clear the first section of that block
	dbf	d0,st3
	movea.l	l_2d9a4,a0	start of block again
	lea	budata+34,a1	probably the old degas picture (redo)
	move.l	#1500,d0	counter  (6079 bytes)
st4	move.l	(a1)+,(a0)+	copy data to block
	dbf	d0,st4
	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	adda.l	#$c,sp		set screen
	move.l	#$1f40,d0	counter
	movea.l	l_2d9a4,a0
	movea.l	l_2d9a8,a1
	movea.l	l_2d9ac,a2
	movea.l	l_2d9b0,a3
	movea.l	l_2d9b4,a4
	movea.l	l_2d9b8,a5
	movea.l	l_2d9bc,a6

st5	move.l	(a0),(a1)+
	move.l	(a0),(a2)+
	move.l	(a0),(a3)+
	move.l	(a0),(a5)+
	move.l	(a0),(a6)+
	move.l	(a0)+,(a4)+	copy the first section into the
	dbf	d0,st5		other six

	move.l	#$1f40,d0	that counter again
	movea.l	l_2d9a4,a0	and again with the very...
	movea.l	l_2d9c0,a1	...last section
st6	move.l	(a0)+,(a1)+
	dbf	d0,st6

	lea	datastart,a0	($2831e) not needed? All $000's...
	movea.l	l_2d9a4,a1	start of reserved block again
	move.l	#7,d5		loop 1
st6a	move.l	#$96,d7		loop 2
	adda.l	#$1ea0,a1
st7	move.l	#$27,d6		loop 3
st8	clr.l	(a1)+
	dbf	d6,st8
	suba.l	#$a0,a0
	dbf	d7,st7	
	adda.l	#$a0,a0
	adda.l	#$300,a1
	dbf	d5,st6a
	
	bsr	sub_a (253c2)
	bsr	save_mfp
	move.l	#l_2d87a,l_2da2c contains $0006 0006 etc..
	move.w	#4,l_2d9da
	move.l	#budgie,l_2d9dc
st8a	move.w	l_2d9c8,d0
	ext.l	d0
	lsl.w	#2,d0
	lea	l_2d9a4,a0	a pointer
	move.l	0(a0,d0.l),l_2d9cc
	lsr.l	#2,d0
	addq.w	#1,d0
	cmpi.w	#8,d0
	bne	st9
	move.l	#0,d0
st9	move.w	d0,l_2d9d8
	lsl.w	#2,d0
	move.l	0(a0,d0.l),l_2d9d0
	bsr	sub_b
	move.w	l_2d9d8,l_2d9c8
	lea	l_2d9a4,a0
	move.w	l_2d9c8,d0
	lsl.w	#2,d0
	ext.l	d0
	move.l	0(a0,d0.l),l_2d9d4
	move.l	$466,d0
wait_vb	cmp.l	$466,d0
	beq	wait_vb
	move.w	#$b,-(sp)	CONSTAT if 0 in D0,
	trap	#1		no characters in buffer
	addq.l	#2,sp
	tst.w	d0
	beq	st8a
	move.w	#1,-(sp)	CONIN (getkey) wait for
	trap	#1		1 single charater
	addq.l	#2,sp
	bsr	fred		restore mfp if necessary
	rts
sub_a	pea	l_2d55c		string environment (0,0)
	pea	l_2d55c
	pea	l_2d551		filename
	move.w	#0,-(sp)	CHAIN
	move.w	#$4b,-(sp)
	trap	#1
	adda.l	#$10,sp
	rts
clear_vb
	movea.l	$456,a0
	clr.l	4(a0)	clear first interrupt in queue
	rts
sub_b	subq.w	#4,l_2d9da
	tst.w	l_2d9da
	bne	george
	move.w	#$20,l_2d9da
	movea.l	l_2d9dc,a0
	cmp.b	#"|",(a0)	end marker?
	bne	st10
	lea	budgie,a0	the text
st10	move.b	(a0),d0
	cmp.b	#13,d0
	beq	space
	cmp.b	#10,d0
	beq	space
	cmp.b	#32,d0
	bmi	space
	cmp.b	#90,d0
	bgt	space
	cmp.b	#0,d0
	beq	exit
	bra	okk

space	move.b	#32,d0

okk	addq.l	#1,a0
	move.l	a0,l_2d9dc
	move.w	d0,d2
	move.l	#c_set+34,d1	start of degas pic (c/set) PI3
	subi.b	#$20,d0
	cmpi.b	#$33,d2
	blt	st11
	addi.l	#$960,d1
	subi.b	#$13,d0
	cmpi.b	#$46,d2
	blt	st11
	addi.l	#$960,d1
	subi.b	#$13,d0
	cmpi.b	#$59,d2
	blt	st11
	addi.l	#$960,d1
	subi.l	#$13,d0
st11	ext.w	d0
	ext.l	d0
	lsl.l	#2,d0
	add.l	d0,d1
	move.l	d1,l_2d9e0
george	movea.l	l_2d9e0,a0
	movea.l	l_2d9cc,a1
	adda.l	#$6900,a1
	movea.l	l_2d9d0,a2
	adda.l	#$6900,a2
*----------------------		next section 29 times
* this governs the height of each letter (normally 28 or 29)
* if say 14 is put here only 1/2 a character will be printed
* this section probably copies from c/set memory a character
* on the top section of the screen, taking 29 scans to draw one
* I am now using a loop instead of a 29 repeat
	move.l	#28,d7	
aloop	move.l	#$98,d6		152
	move.l	(a0),d0
	move.w	l_2d9da,d1
	subi.w	#1,d1
	lsr.l	d1,d0
	andi.w	#15,d0
	move	sr,d5
sr1	move.w	d5,sr	
	clr.l	d4
	move.w	0(a1,d6.l),d4
	lsl.l	#4,d4
	or.w	d0,d4
	move.w	d4,0(a2,d6.l)
	swap 	d4
	move.w	d4,d0
	andi.w	#15,d0
	move	sr,d5
	subq.l	#8,d6
	bpl	sr1
	adda.l	#$50,a0	80
	adda.l	#$a0,a1		160
	adda.l	#$a0,a2
	dbra	d7,aloop
	bra	.skip
*----------------------

*----------------------
.skip
	movea.l	l_2d9d0,a0	physbase probably
	adda.l	#27040,a0	now point line already on (bottom one)
	movea.l	l_2d9d0,a1	next three a1/2/3 are still blank..
	adda.l	#20800,a1	..but will all receive a copy.. 
	movea.l	l_2d9d0,a2	.. of this line if required
	adda.l	#14560,a2	.. see next section
	movea.l	l_2d9d0,a3
	adda.l	#8320,a3	6240 gap between each

*------------------------	the next lot is repeated 1116 times!!
* without this section, only one line of text will be shown (bottom)
* each move.l d0,(ax)+	adds one extra line, moving upwards
	move.l	#1116,d1
giant	move.l	(a0)+,d0
	move.l	d0,(a1)+	2nd line
	move.l	d0,(a2)+	3rd line
*	move.l	d0,(a3)+	no time for this one (flicker)
	dbra	d1,giant
	rts
*-----------------------
screen_sub
	movem.l	d1/a0,-(sp)
	move.l	l_2d9d4,d1
	lsr.l	#8,d1
	move.b	d1,$ffff8203	screen low	actually $ffff8203
	lsr.w	#8,d1
	move.b	d1,$ffff8201	screen hi
	subq.w	#1,l_2da36
	bne	st13
	move.w	#2,l_2da36
	addq.l	#2,l_2da32
st13	movea.l	l_2da32,a0
	cmpi.w	#$ffff,(a0)
	bne	st14
	move.l	#l_2d940,l_2da32
	movea.l	#l_2d940,a0
st14	move.w	(a0),$ff825e	palette color 15 ($00ff825e)
	movem.l	(sp)+,d1/a0
	move.w	#$ffff,$4ee	alt/help flag (why?)
	rts
*-----------
print
	move.l	d0,-(sp)
	move.w	#9,-(sp)
	trap	#1	print routine
	addq.l	#6,sp

	move.w	#1,-(sp)
	trap	#1	conin
	addq.l	#2,sp
	bra	exit
getkey	move.w	#1,-(sp)
	trap	#1	conin
	addq.l	#2,sp
	rts
*---------------------
save_mfp
	move.b	$fffa09,l_2d9ee		interr enable B
	move.b	$fffa07,l_2d9ef		interr enable A
	move.b	$fffa13,l_2d9f0		interr mask A
	move.l	$118,l_2d9f2
	move.l	$120,l_2d9f6
	move.l	$70,l_2d9fa
	move.l	$118,nick+2
	move.l	#tony,$118	($23e28) (#$2500,sr)
	andi.b	#$df,$fffa09	interr enable B
	andi.b	#$fe,$fffa07	interr enable A
	move.l	#jack,$120	mfp routine (colours)
	ori.b	#1,$fffa07	interr enable A
	ori.b	#1,$fffa13	interr mask A
	move.l	$70,lou+2
	move.l	#mfp,$070
	move.w	#0,l_2da22
	rts
*----------
fred
	tst.w	l_2da22
	beq	restore_mfp
	rts
restore_mfp
	move.b	l_2d9ee,$fffa09
	move.b	l_2d9ef,$fffa07
	move.b	l_2d9f0,$fffa13
	move.l	l_2d9f2,$118
	move.l	l_2d9f6,$120
	move.l	l_2d9fa,$70
	bsr	clear_vb
	move.l	l_2d9a0,-(sp)	pointer to a block of $40100 bytes...
	move.w	#$49,-(sp)	previously allocated
	trap	#1		now MFREE
	addq.l	#6,sp
	rts
*----------
mfp	move.b	#0,$fffa1b	timer B control (this routine is ..
st15	move.b	#49,$fffa21	timer B data	..slotted in $70)
	cmpi.b	#49,$fffa21	($31)
	bne.s	st15
	move.l	#jack,$120	each v/b, $120 routine is reinstalled
	move.w	#$000,$ff8240	reset all colors
	move.w	#$432,$ff8242
	move.w	#$765,$ff8244
	move.w	#$543,$ff8246
	move.w	#$654,$ff8248
	move.w	#$444,$ff824a
	move.w	#$333,$ff824c
	move.w	#$432,$ff8242
	move.w	#$202,$ff824e
	move.w	#$222,$ff8250
	move.w	#$333,$ff8252
	move.w	#$444,$ff8254
	move.w	#$555,$ff8256
	move.w	#$666,$ff8258
	move.w	#$546,$ff825a
	move.w	#$453,$ff825c
	move.w	#$777,$ff825e
	bsr	screen_sub
	move.l	l_2da2c,l_2da24 #$006006
	move.b	#8,$fffa1b	timer B control
lou	jmp	$00000000	receives $70 address
tony	move.w	#$2500,sr	enable level 6 interrupt
nick	jmp	$00000000	receives $118 address
jack	movem.l	d0/a0,-(sp)
	move.w	#$070,$ff8244	green
	move.w	#$050,$ff8250
	move.w	#$040,$ff8258
	move.l	#sid,$120	after Jack, now Sid
	bra	st16
sid	movem.l	d0/a0,-(sp)
	movea.l	l_2da24,a0
	move.w	(a0),d0
	move.w	d0,$ff8242
	move.w	d0,$ff8246
	move.w	d0,$ff8252
	move.w	d0,$ff825a
	addq.l	#2,l_2da24
st16	move.b	#0,$fffa1b	timer B control
st17	move.b	#3,$fffa21	timer B data
	cmpi.b	#3,$fffa21
	bne.s	st17
	bclr	#0,$fffa0f	interr in service A
	move.b	#8,$fffa1b	timer B control
	movem.l	(sp)+,d0/a0
	rte			
*----------
flash	move.w	#$000,$ff8240
	move.w	#10000,d5
ag	dbra	d5,ag
	move.w	#$070,$ff8240
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
datastart
l_2831e
	dc.w 	$00,$00,$10,$10,$44,$44,$6c,$6c etc... whatever
	dc.w 	$00,$00,$10,$10,$44,$44,$6c,$6c
	
*	ds.l	3000	
	even

c_set	incbin	"a:\delta\delta.set"		(28d1e)
	even
budata	incbin	"a:\delta\budgie.tit"
	even
* l_2b5be ds.l $1888	probably the old picture...

palette	dc.w	$007,$070,$222,$777,$555,$654,$323,$070 on exit
	dc.w	$444,$333,$222,$333,$555,$654,$323,$070

mem_message	dc.b	"not enough memory",0
rez_message	dc.b	"color only",0
	even

l_2d55c		dc.b	0,0	 environment


	even
colors

l_2d86c	dc.w	$707,$606,$505,$404,$303,$202,$101,$006
	dc.w	$777,$444,$555,$666,$555,$444,$333,$007
	dc.w	$707,$444,$555,$232,$765,$707,$407,$007
	dc.w	$707,$444,$555,$232,$765,$707,$407,$007
	dc.w	$707,$444,$555,$232,$765,$707,$407,$007
	dc.w	$707,$444,$555,$232,$765,$707,$407,$007
	dc.w	$707,$444,$555,$232,$765,$707,$407,$007
	dc.w	$707,$444,$555,$232,$765,$707,$407,$007
l_2d87a	dc.w	$006,$006,$555,$232,$765,$707,$407,$007

l_2d940	
	dc.w $000,$001,$002,$003,$004,$005,$006,$007 cycling
	dc.w $017,$027,$037,$047,$057,$067,$077,$177
	dc.w $277,$377,$477,$577,$677,$777,$777,$777
	dc.w $777,$777,$776,$775,$774,$773,$772,$771	
	dc.w $770,$760,$750,$740,$730,$720,$710,$700
	dc.w $600,$500,$400,$300,$200,$100,$000,$ffff

	even
	ds.l	20								
l_2d551		dc.b "lynne_15.prg",0	any chainable file..
	ds.l	20
	even
l_29412		dc.l	0	l
l_2d8e2		dc.l 	0	l



l_2d9a0		dc.l	0	pointer to block of $40000, later m_freed
l_2d9a4		dc.l	0	same but /8*8
l_2d9a8		dc.l	0	same + $8000
l_2d9ac		dc.l	0	same + $8000
l_2d9b0		dc.l	0	same + $8000	
l_2d9b4		dc.l	0	same + $8000
l_2d9b8		dc.l	0	same + $8000
l_2d9bc		dc.l	0	same + $8000
l_2d9c0		dc.l	0	same + $8000
l_2d9ca		dc.w	0	w
l_2d9c8		dc.w	0	w
l_2d9cc		dc.l	0	l
l_2d9d0		dc.l	0	l	top of screen?
l_2d9d4		dc.l	0	l
l_2d9d8		dc.w	0	w
l_2d9da 	dc.w	0	w repeated 29 times
l_2d9dc		dc.l	0	pointer to budgie start 
l_2d9e0		dc.l	0	l

l_2d9ee		dc.b	0	mfp
l_2d9ef		dc.b	0
l_2d9f0		dc.b	0	b mfp
l_2d9f2		dc.l	0	l ($118)
l_2d9f6		dc.l 	0	l ($120)
l_2d9fa		dc.l	0	l ($70)
l_2da24		dc.l	0	l
l_2da22		dc.w	0	w
l_2da2c		dc.l	0	l
l_2da32		dc.l	0	l
l_2da36		dc.w	0	w






oldstack	dc.l 	0
logbase		dc.l	 0 	($295d0)
name	dc.b	"a:\delta\text.asc",0
	even
handle	dc.w	0
txt_size	dc.l	0
dta	ds.b	66
budgie	ds.w	1000	where text will be slotted
	dc.w	0,0