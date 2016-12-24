	opt	d+			Debug info

; **	Height is used by scroll routine and table creator.
; **	DO NOT ADJUST.  Adjust each routine individually if needed.
; **	Always create fonts within a 32 x 32 block in degas.
	
height	equ	33			Grafix height

; **	Don't forget to deallocate.

efload
	lea	mystack,sp
	move.l	sp,d0

	subi.l	#efload-$0120,d0
	move.l	d0,-(sp)
	pea	efload-$0100(pc)


memory	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	adda.w	#$0c,sp

start1	move.w	#3,-(sp)		Get screen address
	trap	#14
	addq.l	#2,sp
	move.l	d0,clram+2
	sub.l	#16384,d0
	move.l	d0,scradd
	add.l	#160*200,d0		Border position
	move.l	d0,scr2

; **	Get V.U position.

	move.l	scradd,d0		Restore screen
	move.l	#160*195,d0
	move.l	d0,plot			Channel 1
	add.l	#320,d0
	move.l	d0,plot+4		Channel 2
	add.l	#320,d0
	move.l	d0,plot+8		Channel 3
	
	bsr	clram
	bsr	super
	bsr	create			Pre-calculate char table
	bsr	hblon
	bsr	mouseoff
	bsr	musicon
	bsr	savecols
	bsr	setpal
	bsr	setscr
	bsr	movepic
	move.l	$502,salth
	move.l	#alth,$502		turn off alt/help (RTS)

	clr.b	$484

; ** 	Less planes means longer waits between each sync, which
; **	means more speed.

main	addq.w	#1,vcount
	cmpi.w	#3,vcount		Between vsync's	(less planes=less syncs)
	bne.s	nosync		
	move.l	$466,d0
sync	cmp.l	$466,d0			VBL due?
	beq.s	sync			No.
	clr.w	vcount

nosync	bsr	shift			Scroll....
	move.l	#$600ff,-(sp)		Test keypress.
	trap	#1
	addq.l	#4,sp
	
back	cmp.w	#$32,d0			Spaced out man!
	beq	exit
noway	bra	main			Key pressed

shift	tst.w	chrwidth		Finished plotting.
	bne.s	oldlet			NO.
	movea.l	text,a0			YES.Get new char.
	moveq	#0,d0			Clear char reg.  Paranoid eh!
nostop	move.b	(a0)+,d0		Get char.
	bne.s	nxtlet			Last char?
	move.l	#texto,text		YES! repeat message.
	bra.s	shift

nxtlet	move.l	a0,text			Save addr of next char.
	lea	font+34,a0		PI1 font start
	sub.b	#32,d0
	beq.s	zerod
	lea	tabs(pc),a2
	add.w	d0,d0			WORD align into font access table
	move.w	(a2,d0.w),d0
	add.l	d0,a0			add offset to char in font.
zerod	clr.w	bflag
	move.l	a0,graf
		
	move.w	#1,rotter
	move.w	#31,chrwidth		Graphic width.
oldlet	subq.w	#1,chrwidth
	move.l	scr2,a0			Start of scroll area.
	movea.l	graf,a1

	tst.w	bflag
	bne.s	.2
	cmpi.w	#15,chrwidth		are we in 2nd half
	bgt	.1			No still doing top half
	move.w	#1,rotter
	move.w	#255,bflag
.2	addq.l	#8,a1			fix to 2nd half of char
	
.1	moveq.w	#height-1,d7		Graphic height-1
	move.w	rotter,d2

; **	The REPT below should equal the number of planes used.

oloop
iloop	REPT	3			LESS planes=LESS reps=FAST!!
	move.w	(a1)+,d0
	lsl.w	d2,d0
	roxl	$98(a0)
	roxl	$90(a0)
	roxl	$88(a0)
	roxl	$80(a0)
	roxl	$78(a0)
	roxl	$70(a0)
	roxl	$68(a0)
	roxl	$60(a0)
	roxl	$58(a0)
	roxl	$50(a0)
	roxl	$48(a0)
	roxl	$40(a0)
	roxl	$38(a0)
	roxl	$30(a0)
	roxl	$28(a0)
	roxl	$20(a0)
	roxl	$18(a0)
	roxl	$10(a0)
	roxl	$8(a0)
	roxl	(a0)+
	ENDR
planes	addq.l	#2,a0		+0=4 plane,+2=3 plane,+4=2 plane +6=1 plane
	addq.l	#2,a1		      ''         ''       ''        ''
	lea	152(a1),a1
	lea	152(a0),a0	Next line to scroll.
	dbf	d7,oloop
	addq.w	#1,d2
	move.w	d2,rotter
	rts

graf	dc.l	0
bflag	dc.w	0
rotter	dc.w	1
text	dc.l	texto
texto	dc.b	" 89    89    WHOA!!!!!! WERE FINALLY THERE,,,,,,WELCOME TO MENU 1 FROM A NEW CRACKING GROUP CALLED     "
	DC.B 	"THE SPHINCTER MUSCLE'S:-   89   89     WELL BAZZER   67  67  EAT YOUR HEART OUT AS I'M ON MY WAY...... "
	DC.B	"I HAVE BEEN SLOGING AWAY AT ASSEMBLER USING THE BRILLIANT 'DEV PACK' AND AS MANY REFERENCE BOOKS "
	DC.B	"THAT I CAN GET MY GRUBBY HANDS ON.  67  I HAVE SENT YOU SOME SYNCRO SYSTEMS MENUS OF WHICH  CARL (THE PUNTER) IS NOW A MEMBER... "
	DC.B	"HOW IS KEG'S (FROM THE EGO TRIPPER'S) ,,, MAN IS HE A LAMER!!!... BAZ 67 67 I HAVE ALSO SENT YOU GENISIS INC MENU 2.. WHAT A BRILLIANT INTRO"
	DC.B	" IT ALMOST BRINGS WATER TO YOUR EYES, AND THE SLAGGING OFF IS A1"
	DC.B	" I HAVE ALSO SENT ADRENALIN 5 WITH A320 AIR BUS.."
	DC.B	" I HAVE NOT SEEN THIS YET BUT HAVE BEEN TOLD IT'S A GOOD"
	DC.B	" SIM..BAZ 67 67 THIS WILL BE MY 1ST MENU INTRO BUT I HAVE NOT PUT ANY LOADER ROUTS IN YET"
	DC.B	" OR DECIDED WHAT PROGS TO DO...SO YOU ARE PRIVILIGED TO SEE THIS 1ST 89 89 ....PRESS -2- FOR SESK TOP OR AS THEY SAY LETS WRAP>>>>>>>>>   "
	dc.b	0

me	dc.b	'CODE BY DODGY KING!  -  LEAVE THIS IN OR YOU WILL HAVE TO CONTEND WITH DODGY QUEEN!'

****************************************
********     ROUTINES     **************
****************************************

clram	move.l	#0,d0
	lea	finish,a1
	moveq	#0,d1
	sub.l	a1,d0
	lsr.l	#2,d0			quick divide by 4.
.1	move.l	d1,(a1)+
	subq.l	#1,d0
	bne.s	.1
	rts
	
alth	dc.w	$4e75			RTS on alt/help

super	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	move.l	d0,oldsp
	rts

user	move.l	oldsp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	rts

setscr	move.w	#0,-(sp)
	move.l	scradd,-(sp)
	move.l	scradd,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

setpal	move.l	#pic+2,-(sp)
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	rts

restcols	
	move.l	#$ff8240,a1
	move.l	#oldcols,a0
	moveq	#15,d0
loop1	move.w	(a0)+,(a1)+
	dbf	d0,loop1
	rts

savecols	
	move.l	#$ff8240,a0
	move.l	#oldcols,a1
	moveq	#15,d0
loop5	move.w	(a0)+,(a1)+
	dbf	d0,loop5
	rts

mouseoff	
	move.l	#moff,-(sp)	mouse off
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	dc.w	$a00a
	rts

mouseon	move.l	#mon,-(sp)	mouse on
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	dc.w	$a009
	rts

movepic	lea	pic+34,a0
	move.l	scradd,a1
	move.w	#32000-1,d0
plop	move.b	(a0)+,(a1)+
	dbf	d0,plop

; **	Fill border with same grafix as the piccy.

	moveq	#0,d2
	move.l	#160*38/4,d0
.2	move.l	d2,(a1)+
	dbf	d0,.2
	rts

	rts

exit	bsr	hbloff
	bsr	restcols
	bsr	mouseon
	bsr	setscr

	bsr	musicoff
	move.b	#6,$484
	move.l	salth,$502		Restore ALT/HELP
	bsr	user
	clr.w	-(sp)
	trap	#1
***LOADER ROUTS TO GO HERE****
musicoff	
	MOVEA.L	#$FF8800,A0
	MOVE.L	#$8080000,(A0)
	MOVE.L	#$9090000,(A0)
	MOVE.L	#$A0A0000,(A0)
	CLR.L	$4D2			SHADDDUP!!
	clr.l	$4d6			V.U 's off
	rts

; **	Panther music by David Whittaker
; **	1 Tune.

musicon	moveq	#2,d7
	bsr	muz

	move.l	#muz+$e,$4d2
	move.l	#flash,$4d6		V.U Meters
	rts

muz	incbin	'panther.mus'
	
hblon	move.l	$120,oldtb		save old timer B
	move.l	$70,old4		save old hbl
	move.l	$70,new4b+2		install old hbl in new hbl
	move.b	$fffa07,old07		save old int enable A
	move.b	$fffa09,old09		save old int enable B
	move.b	$fffa0f,old0f		save old int in service A
	move.b	$fffa11,old11		save old int in service B
	move.b	$fffa1b,old1b		save old timer B control
	and.b	#$df,$fffa09		switch off timer C
	and.b	#$fe,$fffa07		switch off timer B 
	move.l	#new4,$70		install new hbl 
	or.b	#1,$fffa07		switch on timer B	
	or.b	#1,$fffa13		int mask  reg A 
	rts

hbloff	move.w	sr,-(sp)		tidy up old int
	move.w	#$2700,sr
	move.b	old07(pc),$fffa07
	move.b	old09(pc),$fffa09
	move.b	old0f(pc),$fffa0f
	move.b	old11(pc),$fffa11
	move.b	old1b(pc),$fffa1b
	move.l	oldtb,$120		install old timer B
	move.l	old4,$70		install old hbl
	move.w	(sp)+,sr
	rts

*****     New HBL handler    *****

new4	clr.b	$fffa1b			stop timer B
	move.b	#199,$fffa21		kill the border
	move.l	#killbord,$120		install new timer B vector
	move.b	#8,$fffa1b		enable timer B
new4b	jmp	$12345678		old vbl vector.

killbord	
	clr.b	$fffa1b			stop timer B
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	#$fa21,a1		timer B data reg (counter)
	move.b	#8,$fffa1b		enable int b.
	move.b	(a1),d0
wait4	cmp.b	(a1),d0			wait for next raster line
	beq.s	wait4		

	move.b	#0,$ff820a		60 Hz
	moveq	#3,d0			(3 goes here.. 1 for flash)
nopi2	nop				wait a while between sync change
	dbf	d0,nopi2
	move.b	#2,$ff820a		50 Hz
	move.l	#dummy,$120
	movem.l	(sp)+,d0-d1/a0-a1
	bclr	#0,$fffa0f		end of interrupt
	rte

; **	Seems to stop border flickering.

dummy	clr.b	$fffffa1b.w
	movem.l	d0/a0,-(sp)
	bclr	#0,$fffffa0f.w
	move.b	#8,$fffffa1b.w
	movem.l	(sp)+,d0/a0
	rte

; **	Create table to access font data.
; **	Gotta cut down on those accesses times!
; **	Uses HEIGHT which is EQUated at the top of this source.

create	lea	tabs(pc),a0
	moveq	#0,d2
.1	moveq	#0,d1
	move.w	d2,d0
	divu	#10,d0			Number chars in row.
	move.w	d0,d1			row into D1.
	mulu	#160*height,d1		Block width of rows.
	swap	d0			any Remainder back.
	ext.l	d0			Clear it.
	lsl.l	#4,d0			Multiply by 16
	add.w	d0,d1
	move.w	d1,(a0)+
	addq.w	#1,d2
	cmpi.w	#80,d2			Number of chars in font
	blt.s	.1
	rts

; **	Mini V.U meters.
; **	Lazy technique this, simply invert the screen!!

flash	moveq	#0,d0
	move.l	d0,d2			Use for clearing
	move.b	#8,$ffff8800.w		Select channel 1
	move.b	$ffff8800.w,d0		Read data.
	lea	plot,a1			Get screen tables
	move.l	scradd,a0
	add.l	(a1)+,a0		Get 1st bar

	movea.l	a0,a2			Copy for clearing
	moveq	#0,d2
	REPT	32
	move.b	d2,(a2)+
	ENDR	

	add.w	d0,d0
.3	not.b	(a0)+			Invert the screen
	dbf	d0,.3			Plot it
	
	moveq	#0,d0
	move.b	#9,$ffff8800.w		Select channel 2
	move.b	$ffff8800.w,d0		get DATA
	move.l	scradd,a0
	add.l	(a1)+,a0		Get 2nd bar
	movea.l	a0,a2

	movea.l	a0,a2			Copy for clearing
	moveq	#0,d2
	REPT	32
	move.b	d2,(a2)+
	ENDR	

	add.w	d0,d0
.4	not.b	(a0)+
	dbf	d0,.4

	moveq	#0,d0
	move.b	#10,$ffff8800.w		Select channel 3
	move.b	$ffff8800.w,d0		read the DATA
	move.l	scradd,a0
	add.l	(a1),a0			Get 3rd bar

	movea.l	a0,a2			Copy for clearing
	moveq	#0,d2
	REPT	32
	move.b	d2,(a2)+
	ENDR	

	add.w	d0,d0
.5	not.b	(a0)+
	dbf	d0,.5
	rts

plot	ds.l	4
	
	ds.w	128
mystack	dc.w	10
tabs	ds.w	128

scradd	dc.l	0		physical screen
scr2	dc.l	0
oldsp	dc.l	0		save stack 
oldcols	ds.w	16		save old colours
chrwidth	
	dc.w	0		counter for char width
vcount	dc.w	0		counter for vsync
salth	dc.l	0		old alt/help vector	
sng	dc.l	0		song start
mon	dc.b	$08
moff	dc.b	$12
old4	dc.l	0
oldtb	dc.l	0
old07	dc.b	0
old09	dc.b	0
old0f	dc.b	0
old11	dc.b	0
old1b	dc.b	0
	even

************************************

font	incbin	"a:32.pi1"
pic	incbin	"a:menu.pi1"
finish