	move.l	4(a7),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	move.w	#0,-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	add.w	#12,a7
	
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
	moveq	#1,d0			;music #1
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

music	incbin	"b:\max14.mus"		;music file

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

	move.w	#8000,d0
	lea	$44e,a0
	move.l	(a0),a0
	lea	piccy+34,a1
nextlb	move.l	(a1)+,(a0)+
	dbf	d0,nextlb

	move.b	#5,def_spd		;default scroll speed
	move.b	def_spd,speed

******* start of scroller code ************************

start	lea	scrl,a0
scroll	moveq.l	#0,d4
	move.b	(a0),d4			;next letter
	cmpi.b	#']',d4
	bne.s	notp
	bsr	pause
	adda	#1,a0
	bra.s	scroll
notp 	cmpi.b	#'{',d4
	bne.s	not1
	move.l	#0,sclin
	move.w	#480,wid+2
	adda	#1,a0
	bra.s	scroll
not1	cmpi.b	#'}',d4
	bne.s	not2
	move.l	#2400,sclin
	move.w	#320,wid+2
	adda	#1,a0
	bra.s	scroll
not2	cmpi.b	#'~',d4
	bne.s	none
	move.l	#4800,sclin	
	move.w	#160,wid+2
	adda	#1,a0
	bra.s	scroll
none	tst.b	(a0)+			;end of scrl?
	bne.s	chr_val
	bra	start

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
	lea	24480(a1),a1		;some where near the bottom!
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

wid	lea	160(a1),a1		;add 160 (1 line) to screen addr
	dbf	d7,lines

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
	;cmpi.b	#"0",d0
	;bne.s	g1
	;eor.b	#2,hertz
	;eor.w	#$706,$ffff8242
	;bra	return
g1	cmpi.b	#"a",d0
	bne.s	g2
	move.l	#prog1,game
	bra	loadok
g2	cmpi.b	#"b",d0
	bne.s	g3
	move.l	#prog2,game
	bra	loadok
g3	cmpi.b	#"c",d0
	bne.s	g4
	move.l	#prog3,game
	bra	loadok
g4	cmpi.b	#"d",d0
	bne.s	g5
	move.l	#prog4,game
	bra	loadok
g5	cmpi.b	#"e",d0
	bne.s	g6
	move.l	#prog5,game
	bra	loadok
g6	cmpi.b	#"f",d0
	bne.s	g7
	move.l	#prog6,game
	bra	loadok
g7	cmpi.b	#"g",d0
	bne.s	g8
	move.l	#prog7,game
	bra	loadok
g8	cmpi.b	#"h",d0
	bne.s	g9
	move.l	#prog8,game
	bra	loadok
g9	cmpi.b	#"i",d0
	bne.s	g10
	move.l	#prog9,game
	bra	loadok
g10	cmpi.b	#"j",d0
	bne.s	g11
	move.l	#prog10,game
	bra	loadok
g11	cmpi.b	#"k",d0
	bne.s	g12
	move.l	#prog11,game
	bra	loadok
g12	cmpi.b	#"l",d0
	bne.s	g13
	move.l	#prog12,game
	bra	loadok
g13	cmpi.b	#"m",d0
	bne.s	g14
	move.l	#prog13,game
	bra	loadok
g14	cmpi.b	#"n",d0
	bne.s	g15
	move.l	#prog14,game
	bra	loadok
g15	cmpi.b	#"o",d0
	bne.s	g16
	move.l	#prog15,game
	bra	loadok
g16	cmpi.b	#"p",d0
	bne.s	g17
	move.l	#prog16,game
	bra	loadok
g17	cmpi.b	#"q",d0
	bne.s	g18
	move.l	#prog17,game
	bra	loadok
g18	cmpi.b	#"r",d0
	bne.s	g19
	move.l	#prog18,game
	bra	loadok
g19	cmpi.b	#"s",d0
	bne.s	g20
	move.l	#prog19,game
	bra	loadok
g20	cmpi.b	#"t",d0
	bne.s	g21
	move.l	#prog20,game
	bra	loadok
g21	cmpi.b	#"u",d0
	bne.s	g22
	move.l	#prog21,game
	bra	loadok
g22	cmpi.b	#"v",d0
	bne.s	return
	move.l	#prog22,game
	bra	loadok

return	bra	scroll

******* end of scroller code ***************************

pause	move.l	#300,d6
l1	move.l	#5000,d7
l2	dbf	d7,l2
	dbf	d6,l1
	rts

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

plus	cmpi.b	#12,def_spd
	bgt.s	return
	addq.b	#1,def_spd
	bra.s	return

minus	cmpi.b	#4,def_spd
	blt	return
	subq.b	#1,def_spd
	bra	return

******* end speed routines **************************

loadok	move.w	#1,-(a7)		;restore rez
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)		;set screen
	trap	#14
	lea	12(a7),a7

	lea	def_pal,a0
	lea	$ffff8260.w,a1		;restore colours
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(a1)
	move.w	#$777,$ffff8240
	move.w	#$000,$ffff825e

	dc.w	 $a009			;show mouse

quit	jsr	off

	;clr.l	$426.w
	;clr.l	$42a.w
	;move.b	hertz,d4
	;eor.b	d4,$ff820a

	move.l	old_sp,-(a7)
	move.w	#$20,-(a7)		;user mode
	trap	#1
	addq.l	#6,a7
	
	move.l	game,d4

	move.l	#ct+1,-(a7)
	move.l	#ct,-(a7)
	move.l	d4,-(a7)
	clr.w	-(a7)
	move.w	#$4b,-(a7)
	trap	#1

	pea	error(pc)
	move.w	#9,-(a7)
	trap	#1		;display message
	addq.l	#6,a7
	

	move.w #7,-(a7)		;wait key
	trap #1			;call gemdos
	lea 2(a7),a7		;correct stack
	clr.w -(a7)		;terminate
	trap #1			;call gemdos


hertz	ds.b	1
sclin	ds.l	1
game	ds.l	1
wgam	ds.l	1
prog1	dc.b	"\jampack4\jampack4.prg",0
prog2	dc.b	"\pack_ice.24\ice_2_4.prg",0
prog3	dc.b	"\pack_ice.231\ice_2_3.prg",0
prog4	dc.b	"\firepack.2_0\fire_2_0.prg",0
prog5	dc.b	"\atomik.33\atom_v33.prg",0
prog6	dc.b	"\desktop",0
prog7	dc.b	"\cheetah3.prg",0
prog8	dc.b	"\easyrid2.prg",0
prog9	dc.b	"\edhak20r.prg",0
prog10	dc.b	"\fcopy3.prg",0
prog11	dc.b	"\fcopypro.prg",0
prog12	dc.b	"\ficedepa.prg",0
prog13	dc.b	"\desktop",0
prog14	dc.b	"\genst2.prg",0
prog15	dc.b	"\hyperco.prg",0
prog16	dc.b	"\locksmif.prg",0
prog17	dc.b	"\medway_4.prg",0
prog18	dc.b	"\monst2.prg",0
prog19	dc.b	"\mutil21.prg",0
prog20	dc.b	"\rsced_12.prg",0
prog21	dc.b	"\boot_2bl.tos",0
prog22	dc.b	"\boot_2wh.tos",0

error	dc.b	"Where's the file ???",0

scrl	dc.b	"~WELL, HERE IT IS PEOPLES.......        YES, THE WILD! BOYS UTILITIES DISK NUMBER 2!!          CHANGE FONT SIZE ]                  }AH YEAH!!!    THAT'S MUCH BETTER......"
	dc.b	"I KNOCKED THIS CODE TOGETHER IN JUST 1 NIGHT!        PRETTY GOOD EH?        WHAT DO YOU MEAN NO!!!            IF YOU HAD TO DRAW THE PIC, TYPE THE SCROLLER AND CODE THE WHOLE "
	dc.b	"MENU, THEN YOU WOULD THINK IT WAS PRETTY GOOD!!          CHANGE FONT SIZE ]                  {AHA, I BET YOU THOUGHT THE FONT WOULD GO BACK TO THE ORIGINAL SIZE, "
	dc.b	"DIDN'T YA!!!          IF YOU FIND THIS DIFFICULT TO READ (I.E. IT'S TOO FAST THEN PRESS    + OR - FOR SPEED ]                  }PLEASE NOTE THAT WHEN YOU QUIT FROM THE "
	dc.b	"UTILITY YOU ARE USING, YOU WILL NOT, I REPEAT NOT COME BACK TO THIS MENU....        I KNOW THIS IS A REAL PAIN, BUT SOME OF THESE UTILS HAVE 2 OR 3 PROGS TO BE RUN WITH THEM. "
	dc.b	"SO IT WAS IMPOSSIBLE.        SORRY!!!                   {HOWEVER, WE BRING YOU SOME OF THE LATEST PACKERS AND UTLITIES TO BE FOUND ON THE ST.        I HAVE INCLUDED 1 OR 2 SLIGHTLY "
	dc.b	"UNUSUAL UTILS...  (EG. THE RESOURCE EDITOR AND EASY RIDER 2).                   ~EASY RIDER 2 IS A LAMER'S DREAM COME TRUE....     IT WILL DIS-ASSEMBLE .PRG'S AND RE-ASSEMBLE THEM INTO A "
	dc.b	"FORMAT UNDERSTOOD BY ASSEMBLERS SUCH AS DEVPAC!!        BUT, SOME ALTERATIONS MAY NEED TO BE MADE, SO IT'S NOT 100%!!!        OK, IT'S TIME TO PASS ON....        (ARE YOU GOING TO "
	dc.b	"CROAK IT SPIKE ?? - RAW)        NO, YA DAFT PUDD'N!!    I MEAN PASS THE SCROLLER ONTO THAT CHAP....    YOU KNOW....    YES, IT'S....                   {SNAZ       ]                   ~"
	incbin	"a:\util2.doc"
	dc.b	0

new_pal	dc.w	$000,$777,$760,$600,$111,$222,$333,$444,$012,$777,$114,$777,$124,$777,$235,$777
reb_pal	dc.w	$000,$777,$775,$763,$752,$742,$632,$522,$410,$300,$556,$223,$754,$112,$334,$700

	even

font	incbin	"a:\font18.dat"
piccy	incbin	"a:\utilpicf.pi1"
rebpic	;incbin	"a:\reboot.pi1"

byt	ds.w	1
byt1	ds.w	1
old_sp	ds.l	1
old_rez	ds.w	1
speed	ds.w	1
def_spd	ds.w	1
def_pal	ds.w	16
stc_pad	ds.l	16
ct	dc.l	0
	
 