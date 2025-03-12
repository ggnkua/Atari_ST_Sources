	move.l 4(a7),a5
	move.l #$100,-(a7)
	move.l a5,-(a7)
	move.l #$4a0000,-(a7)
	trap #1
	add.w #12,a7
	
	clr.l	-(a7)
	move.w	#$20,-(a7)		;supervisor mode
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp
	
	;move.l	#reboot,$42a
	;move.l	#$31415926,$426

	move.l	#0,$484.w		;no keyclick
	bsr	on			;start music

	bra	strt

zippy	movem.l d0-a6,-(a7)		;save registers
	bsr	(music+8)		;call playback
	movem.l	(a7)+,d0-a6		;restore registers
	move.l	oldint,-(a7)		;old vbl on sp
	rts				;call old vbl

on	move.l	$70.w,oldint		;save old vbl
	moveq	#4,d0			;music #1
	bsr	music			;call init
	move.l	#zippy,$70.w		;install new vbl
	rts

off	move.l	oldint,$70.w		;restore old vbl
	move.l	#$08080000,$ff8800	;clear vol. chan a
	move.l	#$09090000,$ff8800	;clear vol. chan b
	move.l	#$0a0a0000,$ff8800	;clear vol. chan c
	rts

oldstk	dc.l	0
oldint	dc.l	0

music	incbin	"charts.mus"		;music file

strt	move.w	#4,-(a7)		;get rez
	trap	#14
	addq.l	#2,a7
	move.w	d0,old_rez
	cmpi.w	#2,d0
	beq	quit

	lea	$ffff8240.w,a0
	lea	def_pal,a1
	lea	32(a1),a1		;store colours
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(a1)

	clr.w	-(a7)
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)		;set screen
	trap	#14
	lea	12(a7),a7

	;move.b	#4,def_spd		;default scroll speed
	;move.b	def_spd,speed

	;clr.l	-(a7)
	;move.w	#$20,-(a7)		;supervisor mode
	;trap	#1
	;addq.l	#6,a7
	;move.l	d0,old_sp
	
	dc.w	 $a00a			;kill mouse
	
	move.w	#4,-(a7)		;get rez
	trap	#14
	addq.l	#2,a7
	move.w	d0,old_rez
	cmpi.w	#2,d0
	beq	quit

	lea	$ffff8240.w,a0
	lea	def_pal,a1
	lea	32(a1),a1		;store colours
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(a1)

	lea	$ffff8260.w,a0
	lea	new_pal,a1
	movem.l	(a1)+,d0-d7
	movem.l	d0-d7,-(a0)

	clr.w	-(a7)
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)		;set screen
	trap	#14
	lea	12(a7),a7

	;BRA	showpic

******* ok let's go animation ************

	lea	$44e,a0
	move.l	(a0),a0
	move.l	a0,strtscr	;store top of screen
	adda	#120,a0		;near top of screen
	move.l	a0,tophead	;store top of sprite pos on screen
	move.l	a0,sthead	;store it again

	moveq	#6,d4
	bsr	goanim
	move.l	sthead,a0
	move.l	sthead,tophead
	moveq	#4,d4
	bsr	goanim
	move.l	sthead,a0
	move.l	sthead,tophead
	moveq	#2,d4
	bsr	goanim

scrpix	moveq	#23,d2
shiflem	lea	$44e.w,a2
	move.l	(a2),a2
	moveq	#42,d0
loop2	moveq	#3,d1
loop3	;lsl	(a1)
	;nop
	;nop
	roxl	$90(a2)
	roxl	$88(a2)
	roxl	$80(a2)
	roxl	$78(a2)
	roxl	$70(a2)
	roxl	$68(a2)
	roxl	$60(a2)
	roxl	$58(a2)
	roxl	$50(a2)
	roxl	$48(a2)
	roxl	$40(a2)
	roxl	$38(a2)
	roxl	$30(a2)
	roxl	$28(a2)
	roxl	$20(a2)
	roxl	$18(a2)
	roxl	$10(a2)
	roxl	8(a2)
	;nop
	;addq.l	#2,a1
	addq.l	#2,a2
	dbf	d1,loop3
	;lea	$98(a1),a1
	lea	$98(a2),a2
	dbf	d0,loop2
	dbf	d2,shiflem
	
	bra	showpic

goanim	bsr	walklem
	lea	piccy+34,a1
	bsr	anim
	move.l	a0,turnst
	bsr	turnlem
	rts

walklem	lea	piccy+34,a1
	bsr	anim
	adda	#7200,a1
	bsr	anim
	adda	#7200,a1
	bsr	animls2
	suba	#16,a0
	move.l	a0,tophead
	dbf	d4,walklem
	rts

anim	moveq	#4,d1
ani2	moveq	#42,d0
ani1	move.l	(a1),(a0)
	move.l	4(a1),4(a0)
	move.l	8(a1),8(a0)
	move.l	12(a1),12(a0)
	move.l	16(a1),16(a0)
	move.l	20(a1),20(a0)
	move.l	24(a1),24(a0)
	move.l	28(a1),28(a0)
	adda	#160,a1
	adda	#160,a0
	dbf	d0,ani1
	adda	#32,a1
	bsr	pause
	suba.l	#6880,a1
	move.l	tophead,a0
	dbf	d1,ani2
	rts
	
animls2	moveq	#3,d1
ani4	moveq	#42,d0
ani3	move.l	(a1),(a0)
	move.l	4(a1),4(a0)
	move.l	8(a1),8(a0)
	move.l	12(a1),12(a0)
	move.l	16(a1),16(a0)
	move.l	20(a1),20(a0)
	move.l	24(a1),24(a0)
	move.l	28(a1),28(a0)
	adda	#160,a1
	adda	#160,a0
	dbf	d0,ani3
	adda	#32,a1
	bsr	pause
	suba.l	#6880,a1
	move.l	tophead,a0
	dbf	d1,ani4
	rts

turnlem	lea	piccy+34,a1	;start of sprite screen
	adda	#14848,a1
	bsr	turnani
	bsr	pause
	bsr	pause
	move.l	turnst,a0
	lea	piccy+34,a1
	adda	#22080,a1
	bsr	turnani
	bsr	pause
	bsr	pause
	move.l	turnst,a0
	lea	piccy+34,a1
	adda	#22112,a1
	bsr	turnani
	rts

turnani	moveq	#42,d0
ani5	move.l	(a1),(a0)
	move.l	4(a1),4(a0)
	move.l	8(a1),8(a0)
	move.l	12(a1),12(a0)
	move.l	16(a1),16(a0)
	move.l	20(a1),20(a0)
	move.l	24(a1),24(a0)
	move.l	28(a1),28(a0)
	adda	#160,a1
	adda	#160,a0
	dbf	d0,ani5
	adda	#32,a1
	bsr	pause
	rts

tophead	ds.l	1
sthead	ds.l	1
sta1	ds.l	1
turnst	ds.l	1

******* that's all the animation folks!

*******	show piccy and set scroll speed

showpic	;moveq.l	#3,d0
	;bsr	music
	
	move.w	#8000,d0
	lea	$44e,a0
	move.l	(a0),a0
	move.l	a0,strtscr
	lea	pic+34,a1
nextlb	move.l	(a1)+,(a0)+
	move.l	#300,d1
pl1	dbf	d1,pl1
	dbf	d0,nextlb

	move.b	#8,def_spd		;default scroll speed
	move.b	def_spd,speed
	move.l	#pre,whsc

******* start of scroller code ************************

start	move.l	whsc,a0
scroll	moveq.l	#0,d4
	move.b	(a0),d4			;next letter
	cmpi.b	#']',d4
	bne.s	notp
	bsr	pauses
	adda	#1,a0
	bra.s	scroll
notp 	cmpi.b	#'{',d4
	bne.s	not1
	move.l	#0,sclin
	adda	#1,a0
	bra.s	scroll
not1	cmpi.b	#'~',d4
	bne.s	not2
	move.b	#3,def_spd
	move.b	#3,speed
	move.l	#scrl,whsc
	adda	#1,a0
	bra.s	scroll
not2	cmpi.b	#'}',d4
	bne.s	none
	move.l	#16320,sclin	
	adda	#1,a0
	bra.s	scroll
none	tst.b	(a0)+			;end of scrl?
	bne.s	chr_val
	bra.s	start

chr_val	subi.b	#32,d4			;wheres that character?
	divu.w	#20,d4			;divide	by number of letters per line
	moveq.l	#0,d5
	move.w	d4,d5
	mulu.w	#272,d5			;multiply by 160 (bytes per line) * height
	mulu.w	#10,d5
	clr.w	d4
	swap	d4
	asl	#3,d4			;multiply remainder by (width of char)
	lea	font,a5
	add.w	d5,a5
	add.w	d4,a5
	;add.l	#160,a5

	;move.w	#0,byt	
	move.w	#16,byt1

	;moveq	#1,d3
	moveq.w	#15,d7
	lea	stc_pad,a6		;copy letter to scratch pad
cpy_chr	move.l	(a5),(a6)
	addq.l	#4,a6
	lea	160(a5),a5
	dbf	d7,cpy_chr

sechalf	move.w	byt1,d6			;pixels across
pixels	move.l	$44e.w,a1		;screen address
	lea	11200(a1),a1		;some where near the bottom!
	adda.l	sclin,a1
	lea	stc_pad,a6
	;adda	byt,a6

	moveq.w	#15,d7			;lines to roxl
lines	move.l	(a6),d0
	lsl.l	d0
	move.l	d0,(a6)+

	roxl	152(a1)			;lotsa roxl's
	roxl	144(a1)
	roxl	136(a1)
	roxl	128(a1)
	roxl	120(a1)
	roxl	112(a1)
	roxl	104(a1)
	roxl	96(a1)
	roxl	88(a1)
	roxl	80(a1)
	roxl	72(a1)
	roxl	64(a1)
	roxl	56(a1)
	roxl	48(a1)
	roxl	40(a1)
	roxl	32(a1)
	roxl	24(a1)
	roxl	16(a1)
	roxl	8(a1)
	roxl	(a1)

	;roxl	154(a1)			;roxl plane 2
	;roxl	146(a1)
	;roxl	138(a1)
	;roxl	130(a1)
	;roxl	122(a1)
	;roxl	114(a1)
	;roxl	106(a1)
	;roxl	98(a1)
	;roxl	90(a1)
	;roxl	82(a1)
	;roxl	74(a1)
	;roxl	66(a1)
	;roxl	58(a1)
	;roxl	50(a1)
	;roxl	42(a1)
	;roxl	34(a1)
	;roxl	26(a1)
	;roxl	18(a1)
	;roxl	10(a1)
	;roxl	2(a1)

	;roxl	156(a1)			;roxl plane 3
	;roxl	148(a1)
	;roxl	140(a1)
	;roxl	132(a1)
	;roxl	124(a1)
	;roxl	116(a1)
	;roxl	108(a1)
	;roxl	100(a1)
	;roxl	92(a1)
	;roxl	84(a1)
	;roxl	76(a1)
	;roxl	68(a1)
	;roxl	60(a1)
	;roxl	52(a1)
	;roxl	44(a1)
	;roxl	36(a1)
	;roxl	28(a1)
	;roxl	20(a1)
	;roxl	12(a1)
	;roxl	4(a1)

	;roxl	158(a1)			;roxl plane 4
	;roxl	150(a1)
	;roxl	142(a1)
	;roxl	134(a1)
	;roxl	126(a1)
	;roxl	118(a1)
	;roxl	110(a1)
	;roxl	102(a1)
	;roxl	94(a1)
	;roxl	86(a1)
	;roxl	78(a1)
	;roxl	70(a1)
	;roxl	62(a1)
	;roxl	54(a1)
	;roxl	46(a1)
	;roxl	38(a1)
	;roxl	30(a1)
	;roxl	22(a1)
	;roxl	14(a1)
	;roxl	6(a1)
 
	lea	480(a1),a1		;add 160 (1 line) to screen addr
	dbf	d7,lines

	bsr	vurout

	subq.b	#1,speed
	bne.s	no_wait
	move.l	$462.w,d0		;vbl frame counter
vbl	cmp.l	$462.w,d0		;wait for vbl
	beq.s	vbl
	move.b	def_spd,speed

no_wait	dbf	d6,pixels		;rest of the pixels
	;move.w	#160,byt
	;move.w	#10,byt1
	;dbf	d3,sechalf

	move.w	#$ff,-(a7)		;wait for a key press
	move.w	#$06,-(a7)
	trap	#1
	addq.l	#4,a7

	cmpi.b	#"+",d0
	beq	plus
	cmpi.b	#"-",d0
	beq	minus
	cmpi.b	#"0",d0
	bne.s	g1
	eor.b	#2,hertz
	eor.w	#$706,$ffff8242
	bra	return
g1	cmpi.b	#"1",d0
	bne.s	g2
	move.l	#prog1,game
	bra	loadok
g2	cmpi.b	#"2",d0
	bne.s	g3
	move.l	#prog2,game
	bra	loadok
g3	cmpi.b	#"3",d0
	bne.s	g4
	move.l	#prog3,game
	bra	loadok
g4	;cmpi.b	#"4",d0
	;bne.s	funkey
	;move.l	#prog4,game
	;bra	loadok
funkey	swap	d0
	sub	#$3a,d0
	cmpi.b	#1,d0
	blt	return
	cmpi.b	#4,d0
	bgt	return
	bsr	music

return	bra	scroll

******* end of scroller code ***************************

pause	move.l	#160,d6
l1	move.l	#152,d7
l2	dbf	d7,l2
	dbf	d6,l1
	rts
pauses	;move.w	#$777,$ffff8242.w
	move.l	#600,d6
l1a	move.l	#2000,d7
l2a	dbf	d7,l2a
	bsr	vurout
	dbf	d6,l1a
	rts

vurout	movem.l	d0-d1/a0-a1,stor2

	move.b	#8,$ffff8800.w			
	move.b	$ffff8800.w,ampa
	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,ampb
	move.b	#10,$ffff8800.w
	move.b	$ffff8800.w,ampc

	move.l	#0,a0
	lea	piccy+34,a0
	move.l	a0,strtlem

vum1	move.l	strtlem,a0	;screen address of lemmings
	move.l	strtscr,a1
	adda	#22144,a0	;start of 1st vu lemming
	adda	#1280,a0	;don't need his head
	adda	#8,a1
	adda	#1280,a1	;don't need his head
	move.b	ampa,amp
	bsr	vu_go
	
vum2	move.l	strtlem,a0	;screen address of lemmings
	move.l	strtscr,a1
	adda	#22144,a0	;start of 1st vu lemming
	adda	#1280,a0	;don't need his head
	adda	#40,a1
	adda	#1280,a1	;don't need his head
	move.b	ampb,amp
	bsr	vu_go
	
vum3	move.l	strtlem,a0	;screen address of lemmings
	move.l	strtscr,a1
	adda	#22144,a0	;start of 1st vu lemming
	adda	#1280,a0	;don't need his head
	adda	#72,a1
	adda	#1280,a1	;don't need his head
	move.b	ampc,amp
	bsr	vu_go

	movem.l	stor2,d0-d1/a0-a1
	rts


vu_go	moveq	#0,d0
	move.b	amp,d0
	cmpi.b	#3,d0
	bgt.s	lem2
	bsr	pr_vu
	bra.s	ret
lem2	adda	#16,a0
	cmpi.b	#6,d0
	bgt.s	lem3
	bsr	pr_vu
	bra.s	ret
lem3	adda	#16,a0
	cmpi.b	#9,d0
	bgt.s	lem4
	bsr	pr_vu
	bra.s	ret
lem4	adda	#16,a0
	cmpi.b	#11,d0
	bgt.s	lem5
	bsr	pr_vu
	bra.s	ret
lem5	adda	#16,a0
	cmpi.b	#13,d0
	bgt.s	lem6
	bsr	pr_vu
	bra.s	ret
lem6	adda	#16,a0
	bsr	pr_vu
ret	rts

pr_vu	moveq	#23,d1
vu_lem	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)
	;move.l	16(a0),16(a1)
	;move.l	20(a0),20(a1)
	;move.l	24(a0),24(a1)
	;move.l	28(a0),28(a1)
	adda	#160,a1
	adda	#160,a0
	dbf	d1,vu_lem
	rts

	
	;movem.l	stor2,d0-d1/a0-a1
	;rts

reboot	;lea	$70000,a7
	;eor.b	#2,$ffff820a
	;move.b	#$7,$ffff8201
	;move.b	#$80,$ffff8203

	;move.w	#8000,d0
	;move.l	#$78000,a0
	;move.l	(a0),a0
	;lea	rebpic+34,a1
nextlc	;move.l	(a1)+,(a0)+
	;dbf	d0,nextlc

	;lea	$ffff8260.w,a0
	;lea	reb_pal,a1
	;movem.l	(a1)+,d0-d7
	;movem.l	d0-d7,-(a0)

	;clr.w	-(a7)
	;move.l	#-1,-(a7)
	;move.l	#-1,-(a7)
	;move.w	#5,-(a7)		;set screen
	;trap	#14
	;lea	12(a7),a7

	;clr.l	$426.w
rebloop	;bra.s	rebloop
	
******** speed routines **************************

plus	cmpi.b	#6,def_spd
	bgt	return
	addq.b	#1,def_spd
	bra	return

minus	cmpi.b	#3,def_spd
	blt	return
	subq.b	#1,def_spd
	bra	return

******* end speed routines **************************

getakey	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7

loadok	moveq.l	#6,d0
	bsr	music
	move.w	#2,d0
endl	bsr	pauses
	dbf	d0,endl
	
	move.w	old_rez,-(a7)		;restore rez
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)		;set screen
	trap	#14
	lea	12(a7),a7

	lea	def_pal,a0
	lea	$ffff8260.w,a1		;restore colours
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(a1)
	;move.w	#$777,$ffff8240
	;move.w	#$777,$ffff825e

quit	jsr	off

	clr.l	$426.w
	clr.l	$42a.w
	move.b	hertz,d4
	eor.b	d4,$ff820a

	move.l	old_sp,-(a7)
	move.w	#$20,-(a7)		;user mode
	trap	#1
	addq.l	#6,a7
	
	move.l	game,d4
	clr.l	-(a7)
	move.l	#ct,-(a7)
	move.l	d4,-(a7)
	clr.w	-(a7)
	move.w	#$4b,-(a7)
	trap	#1

	;pea	error(pc)
	;move.w	#9,-(a7)
	;trap	#1		;display message
	;addq.l	#6,a7
	

	;move.w #7,-(a7)		;wait key
	;trap #1			;call gemdos
	;lea 2(a7),a7		;correct stack
	clr.w -(a7)		;terminate
	trap #1			;call gemdos


ct	dc.l	0
hertz	ds.b	1
sclin	ds.l	1
game	ds.l	1
wgam	ds.l	1
prog1	dc.b	"\ronny.spk",0
prog2	dc.b	"\pablo.spk",0
prog3	dc.b	"\desktop",0
prog4	dc.b	"\desktop",0
error	dc.b	"shit !! where's the fucking file !!!",0

pre	dc.b	"                     ~"
scrl	incbin	"cd21.doc"
	dc.b	0

	even

new_pal	dc.w	$000,$603,$334,$445,$257,$556,$557,$667,$765,$036,$050,$500,$223,$770,$024,$050
reb_pal	;dc.w	$000,$777,$775,$763,$752,$742,$632,$522,$410,$300,$556,$223,$754,$112,$334,$700

	even

font	incbin	"font18.dat"
piccy	incbin	"lemfin.pi1"
pic	incbin	"cd21picf.pi1"
rebpic	;incbin	"reboot.pi1"

amp	dc.b	0
ampa	dc.b	0
ampb	dc.b	0
ampc	dc.b	0
whsc	ds.l	1
strtscr	ds.l	1
strtlem	ds.l	1
byt	ds.w	1
byt1	ds.w	1
old_sp	ds.l	1
old_rez	ds.w	1
speed	ds.w	1
def_spd	ds.w	1
def_pal	ds.w	16
stc_pad	ds.l	16
stor2	ds.l	16
fonty	equ	font+34


