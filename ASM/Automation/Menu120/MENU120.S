start
	pea		$500.w
	move.l	8(a7),-(a7)
	move.l	#$4a0000,-(a7)
	trap		#1
	add.w	#12,a7

	clr.w -(a7)
	pea $78000
	pea $78000
	move.w #5,-(a7)
	trap #14

	lea $2000,a7

	move.w	#2,-(a7)
	trap		#14
	addq.l	#2,a7
	move.l	d0,screen
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap		#1
	move.l	$42e.w,a7
	move.l	d0,oldstack
	move		#$2700,sr

	clr.b	$ff8260
	move.b	#$12,$fffc02
	move.b	#0,$fffa1b
	move.b	#1,$fffa07
	bset		#0,$fffa13
	move.b	#$40,$fffa09
	move.l	$70.w,oldvbl
	move.l	#vbl,$70.w
	move.l	#mfp1,$120.w


;******** Pre-shift for character set ************
	lea		charset,a0
	lea		charset2,a1
	move.w	#$c75,d0
shifter
	move.b	1(a0),(a1)
	move.b	3(a0),2(a1)
	move.b	5(a0),4(a1)
	move.b	7(a0),6(a1)
	move.b	8(a0),1(a1)
	move.b	10(a0),3(a1)
	move.b	12(a0),5(a1)
	move.b	14(a0),7(a1)
	move.b	9(a0),8(a1)
	move.b	11(a0),10(a1)
	move.b	13(a0),12(a1)
	move.b	15(a0),14(a1)
	move.b	(a0),9(a1)
	move.b	2(a0),11(a1)
	move.b	4(a0),13(a1)
	move.b	6(a0),15(a1)
	add.w	#16,a0
	add.w	#16,a1
	dbf		d0,shifter

;All pre-shifted!!!!

	movem.l	picture+2,d0-d7
	movem.l	d0-d7,$ff8240

	lea		picture+34,a0
	move.l	screen,a1
	move.w	#7999,d0
copypic
	move.l	(a0)+,(a1)+
	dbf		d0,copypic

	bsr		music

	move.w	#$2300,sr			Initialised

	move.l	#$9,d0
wait_first
	bsr		wait10vbl
	dbf		d0,wait_first

	move.w	#320,d2
init_loop
	sf		vbldone
wait_vbl1
	tst.w	vbldone
	beq.s	wait_vbl1
	move.l	screen,a1
	add.w	#105*160,a1		Border
	move.w	#68,d0			16 high
scroll_line
	move.w	#3,d1			4 bit planes
scroll_bit_plane
	move		#0,ccr
	roxr.w	(a1)
	roxr.w	8(a1)
	roxr.w	16(a1)
	roxr.w	24(a1)
	roxr.w	32(a1)
	roxr.w	40(a1)
	roxr.w	48(a1)
	roxr.w	56(a1)
	roxr.w	64(a1)
	roxr.w	72(a1)
	roxr.w	80(a1)
	roxr.w	88(a1)
	roxr.w	96(a1)
	roxr.w	104(a1)
	roxr.w	112(a1)
	roxr.w	120(a1)
	roxr.w	128(a1)
	roxr.w	136(a1)
	roxr.w	144(a1)
	roxr.w	152(a1)
	addq.l	#2,a1
	dbf		d1,scroll_bit_plane
	add.w	#$98,a1
	dbf		d0,scroll_line
	dbf		d2,init_loop

	st		music_on
	bsr		wait10vbl
	move.w	#$223,mfp2+2
	move.w	#$223,mfp3+2
	move.w	#$223,mfp4+2
	move.w	#$223,mfp5+2
	move.w	#$223,mfp6+2
	bsr		wait10vbl
	move.w	#$112,mfp3+2
	move.w	#$112,mfp4+2
	move.w	#$112,mfp5+2
	bsr 		wait10vbl
	clr.w	mfp4+2
	st		scroller_on

main_loop
	sf		vbldone
wait_vbl2
	tst.w	vbldone
	beq.s	wait_vbl2
	move.w	#7,-(a7)
	trap		#1
	addq.l	#2,a7
	cmp.b	#'0',d0
	bne.s	nohertz
	bchg		#1,$ff820a
	bra.s	main_loop
nohertz
	lea		file1,a6
	cmp.b	#'1',d0
	beq.s	loader
	lea		file2,a6
	cmp.b	#'2',d0
	beq.s	loader
	lea		file3,a6
	cmp.b	#'3',d0
	bne.s	main_loop
loader
	move.l	oldvbl,$70.w
	move.b	#$8,$ff8800
	clr.b	$ff8802
	move.b	#$9,$ff8800
	clr.b	$ff8802
	move.b	#$a,$ff8800
	clr.b	$ff8802
	move.b	#8,$fffc02
	move.b	$fffa15,$fffa09
	bclr		#0,$fffa13
	move.b	$fffa13,$fffa07
	move.l	screen,a0
	move.w	#7999,d0
clrscr
	clr.l	(a0)+
	dbf		d0,clrscr
	clr.w	$ff8240
	move.w	#$777,$ff825e
	move.l	oldstack,-(a7)
	move.w	#32,-(a7)
	trap		#1
	addq.l	#6,a7
	lea		start+$400,a7
	pea		dummy
	pea		dummy
	move.l	a6,-(a7)
	move.l	#$4b0000,-(a7)
	trap		#1
	add.w	#16,a7
	clr.w	-(a7)
	trap		#1

dummy
	dc.l		0



;*******************************************************************
;********************** S C R O L L E R ****************************
;*******************************************************************
;*Fast scroller,8 pixels at a time,only 1 pre-shifting required!!!!*
;*******************************************************************

scroller
	move.l	screen,a1
	add.w	#112*160,a1
	addq.w	#4,scrollpos
	move.w	scrollpos,d0
	lea		jmptable,a0
	jmp		0(a0,d0.w)

jmptable
	bra		jmptable
	bra		p8
	bra		p16
	bra		p24
	bra		p32

p8
	move.l	char1,a0
	add.l	#charset2-charset,a0
	move.l	a1,a2
	rept		4
	movem.l	(a0)+,d0-d7
	movem.l	d0-d3,(a2)
	movem.l	d4-d7,160(a2)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d3,320(a2)
	movem.l	d4-d7,480(a2)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d3,640(a2)
	movem.l	d4-d7,800(a2)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d3,960(a2)
	movem.l	d4-d7,1120(a2)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d3,1280(a2)
	movem.l	d4-d7,1440(a2)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d3,1600(a2)
	movem.l	d4-d7,1760(a2)
	add.w	#1920,a2
	endr
	movem.l	(a0)+,d0-d7
	movem.l	d0-d3,(a2)
	movem.l	d4-d7,160(a2)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d3,320(a2)
	movem.l	d4-d7,480(a2)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d3,640(a2)
	movem.l	d4-d7,800(a2)
	movem.l	(a0)+,d0-d3
	movem.l	d0-d3,960(a2)

	addq.w	#8,a1
	move.l	char2,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char3,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char4,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char5,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char6,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char7,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char8,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char9,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char10,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char11,a0
	rept		11
	movem.w	(a0),d1-d4
	move.b	d1,1(a1)
	move.b	d2,3(a1)
	move.b	d3,5(a1)
	move.b	d4,7(a1)
	movem.w	16(a0),d1-d4
	move.b	d1,161(a1)
	move.b	d2,163(a1)
	move.b	d3,165(a1)
	move.b	d4,167(a1)
	movem.w	32(a0),d1-d4
	move.b	d1,321(a1)
	move.b	d2,323(a1)
	move.b	d3,325(a1)
	move.b	d4,327(a1)
	movem.w	48(a0),d1-d4
	move.b	d1,481(a1)
	move.b	d2,483(a1)
	move.b	d3,485(a1)
	move.b	d4,487(a1)
	movem.w	64(a0),d1-d4
	move.b	d1,641(a1)
	move.b	d2,643(a1)
	move.b	d3,645(a1)
	move.b	d4,647(a1)
	add.w	#80,a0
	add.w	#800,a1
	endr
	rts


p16
	move.l	char1,a0
	move.l	a1,a2
	move.w	#54,d0
p16_loop1
	move.l	8(a0),(a2)
	move.l	12(a0),4(a2)
	add.w	#16,a0
	add.w	#160,a2
	dbf		d0,p16_loop1
	addq.w	#8,a1

	move.l	char2,a0
	bsr		plotchar1
	move.l	char3,a0
	bsr		plotchar1
	move.l	char4,a0
	bsr		plotchar1
	move.l	char5,a0
	bsr		plotchar1
	move.l	char6,a0
	bsr		plotchar1
	move.l	char7,a0
	bsr		plotchar1
	move.l	char8,a0
	bsr		plotchar1
	move.l	char9,a0
	bsr		plotchar1
	move.l	char10,a0
	bsr		plotchar1
	move.l	char11,a0
	move.w	#54,d0
p16_loop2
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	add.w	#16,a0
	add.w	#160,a1
	dbf		d0,p16_loop2
	rts



p24
	move.l	char1,a0
	add.l	#charset2-charset,a0
	move.l	a1,a2
	move.w	#10,d0
p24_loop1
	move.l	8(a0),(a2)
	move.l	12(a0),4(a2)
	move.l	16*1+8(a0),160(a2)
	move.l	16*1+12(a0),164(a2)
	move.l	16*2+8(a0),320(a2)
	move.l	16*2+12(a0),324(a2)
	move.l	16*3+8(a0),480(a2)
	move.l	16*3+12(a0),484(a2)
	move.l	16*4+8(a0),640(a2)
	move.l	16*4+12(a0),644(a2)
	add.w	#80,a0
	add.w	#800,a2
	dbf		d0,p24_loop1

	move.l	char2,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char3,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char4,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char5,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char6,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char7,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char8,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char9,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char10,a0
	add.l	#charset2-charset,a0
	bsr		plotchar2
	move.l	char11,a0
	add.l	#charset2-charset,a0
	
	rept		11
	movem.w	(a0)+,d0-d7
	move.b	d4,1(a1)
	move.b	d5,3(a1)
	move.b	d6,5(a1)
	move.b	d7,7(a1)
	movem.w	d0-d3,8(a1)
	movem.w	(a0)+,d0-d7
	move.b	d4,161(a1)
	move.b	d5,163(a1)
	move.b	d6,165(a1)
	move.b	d7,167(a1)
	movem.w	d0-d3,168(a1)
	movem.w	(a0)+,d0-d7
	move.b	d4,321(a1)
	move.b	d5,323(a1)
	move.b	d6,325(a1)
	move.b	d7,327(a1)
	movem.w	d0-d3,328(a1)
	movem.w	(a0)+,d0-d7
	move.b	d4,481(a1)
	move.b	d5,483(a1)
	move.b	d6,485(a1)
	move.b	d7,487(a1)
	movem.w	d0-d3,488(a1)
	movem.w	(a0)+,d0-d7
	move.b	d4,641(a1)
	move.b	d5,643(a1)
	move.b	d6,645(a1)
	move.b	d7,647(a1)
	movem.w	d0-d3,648(a1)
	add.w	#800,a1
	endr

	rts
			

p32
	move.l	char2,char1
	move.l	char3,char2
	move.l	char4,char3
	move.l	char5,char4
	move.l	char6,char5
	move.l	char7,char6
	move.l	char8,char7
	move.l	char9,char8
	move.l	char10,char9
	move.l	char11,char10
	
	clr.w	scrollpos
	move.l	messpos,a0
	clr.w	d0
	move.b	(a0)+,d0
	bne.s	okchar
	lea		message,a0
	move.b	(a0)+,d0
okchar
	move.l	a0,messpos
	sub.w	#' ',d0
	mulu		#$370,d0
	add.l	#charset,d0
	move.l	d0,char11
	
	move.l	char1,a0
	bsr		plotchar1
	move.l	char2,a0
	bsr		plotchar1
	move.l	char3,a0
	bsr		plotchar1
	move.l	char4,a0
	bsr		plotchar1
	move.l	char5,a0
	bsr		plotchar1
	move.l	char6,a0
	bsr		plotchar1
	move.l	char7,a0
	bsr		plotchar1
	move.l	char8,a0
	bsr		plotchar1
	move.l	char9,a0
	bsr		plotchar1
	move.l	char10,a0
;    bsr		plotchar1
;	rts
	
plotchar1
	move.l	a1,a2
	move.w	#10,d0
pc1
	movem.l	(a0)+,d1-d4
	movem.l	d1-d4,0*160(a2)
	movem.l	(a0)+,d1-d4
	movem.l	d1-d4,1*160(a2)
	movem.l	(a0)+,d1-d4
	movem.l	d1-d4,2*160(a2)
	movem.l	(a0)+,d1-d4
	movem.l	d1-d4,3*160(a2)
	movem.l	(a0)+,d1-d4
	movem.l	d1-d4,4*160(a2)
	add.w	#800,a2
	dbf		d0,pc1
	add.w	#16,a1
	rts

plotchar2
	move.l	a1,a2
	rept		11
	movem.w	(a0)+,d0-d7
	move.b	d4,1(a2)
	move.b	d5,3(a2)
	move.b	d6,5(a2)
	move.b	d7,7(a2)
	movem.w	d0-d7,8(a2)
	movem.w	(a0)+,d0-d7
	move.b	d4,161(a2)
	move.b	d5,163(a2)
	move.b	d6,165(a2)
	move.b	d7,167(a2)
	movem.w	d0-d7,168(a2)
	movem.w	(a0)+,d0-d7
	move.b	d4,321(a2)
	move.b	d5,323(a2)
	move.b	d6,325(a2)
	move.b	d7,327(a2)
	movem.w	d0-d7,328(a2)
	movem.w	(a0)+,d0-d7
	move.b	d4,481(a2)
	move.b	d5,483(a2)
	move.b	d6,485(a2)
	move.b	d7,487(a2)
	movem.w	d0-d7,488(a2)
	movem.w	(a0)+,d0-d7
	move.b	d4,641(a2)
	move.b	d5,643(a2)
	move.b	d6,645(a2)
	move.b	d7,647(a2)
	movem.w	d0-d7,648(a2)
	add.w	#800,a2
	endr
	add.w	#16,a1
	rts

		

;***************************
load
wait10vbl
	move.l	#startcols,colstart
	move.w	#9,d1
w10a
	sf		vbldone
w10b
	tst.w	vbldone
	beq.s	w10b
	dbf		d1,w10a
	rts


vbl
	movem.l	d0-d7/a0-a6,-(a7)
	tst.b	music_on
	beq.s	nocolsyet
	move.b	#71,$fffa21
	move.b	#8,$fffa1b
	move.b	#1,$fffa21
	move.w	#34,colcount
	move.l	colstart,a0
	move.w	(a0)+,d0
	bpl.s	nocolrpt
	lea		colours,a0
nocolrpt
	move.l	a0,colstart
	move.l	a0,colpos
	
nocolsyet
	tst.b	scroller_on
	beq.s	noscroll
	bsr		scroller
noscroll
	tst.b	music_on
	beq.s	nomuse
	bsr		music+$9c
nomuse
	st		vbldone
	movem.l	(a7)+,d0-d7/a0-a6
	rte


key
	tst.b	-$3fe.w		($fffc02)
	tst.b	-$3fa.w		($fffc06)
	bclr		#6,-$5ef.w	($fffa11)
	rte

mfp1
	move.l	a0,-(a7)
	move.l	colpos,a0
	move.w	(a0)+,$ff824e
	move.l	a0,colpos
	subq.w	#1,colcount
	bne.s	endmfp1
	move.b	#2,$fffa21
	move.l	#mfp2,$120.w
endmfp1
	move.l	(a7)+,a0
	bclr		#0,$fffa0f
	rte
	
mfp2
     move.l	#$03340222,$ff8240
	move.l	#$04440555,$ff8244
	move.l	#$06660700,$ff8248
	move.l	#$07220744,$ff824c
	move.l	#$00600272,$ff8250
	move.l	#$07070770,$ff8254
	move.l	#$03370007,$ff8258
	move.l	#$00040777,$ff825c
	move.l	#mfp3,$120.w
	bclr		#0,$fffa0f
	rte

mfp3
	move.w	#$334,$ff8240
	move.l	#mfp4,$120.w
	move.b	#60,$fffa21
	bclr		#0,$fffa0f
	rte

mfp4
	move.w	#$334,$ff8240
	move.l	#mfp5,$120.w
	move.b	#2,$fffa21
	bclr		#0,$fffa0f
	rte

mfp5
	move.w	#$334,$ff8240
	move.l	#mfp6,$120.w
	bclr		#0,$fffa0f
	rte

mfp6
	move.w	#$334,$ff8240
	move.l	#mfp7,$120.w
	bclr		#0,$fffa0f
	rte

mfp7
	move.l	picture+2,$ff8240
	move.l	picture+6,$ff8244
	move.l	picture+10,$ff8248
	move.l	picture+14,$ff824c
	move.l	picture+18,$ff8250
	move.l	picture+22,$ff8254
	move.l	picture+26,$ff8258
	move.l	picture+30,$ff825c
	move.l	#mfp1,$120.w
	clr.b	$fffa1b
	bclr		#0,$fffa0f
	rte
	

oldvbl
	dc.l		0
oldkey
	dc.l		0
vbldone
	dc.w		0
screen
	dc.l		$78000
oldstack
	dc.l		0

scroller_on
	dc.w		0
music_on
	dc.w		0
colcount
	dc.w		32
colpos
	dc.l		colours
colstart
	dc.l		startcols
startcols
	dcb.w	40,$500
colours
	dc.w		$666,$555,$444,$333,$222,$111,0,0,0,0,0,$110,$220,$330,$440,$550,$660,$770,$660,$550,$440,$330,$220,$110,0,0,0,0,0
	dc.w		$101,$202,$303,$404,$505,$606,$707,$606,$505,$404,$303,$202,$101,0,0,0,0,0,$111,$222,$333,$444,$555,$666,-1
	dc.w		$666,$555,$444,$333,$222,$111,0,0,0,0,0,$110,$220,$330,$440,$550,$660,$770,$660,$550,$440,$330,$220,$110,0,0,0,0,0
	dc.w		$101,$202,$303,$404,$505,$606,$707,$606,$505,$404,$303,$202,$101,0,0,0,0,0,$111,$222,$333,$444,$555,$666,-1

char1	dc.l		charset
char2	dc.l	 	charset
char3	dc.l		charset
char4	dc.l		charset
char5	dc.l		charset
char6	dc.l		charset
char7	dc.l		charset
char8	dc.l		charset
char9	dc.l		charset
char10	dc.l		charset
char11	dc.l		charset

scrollpos
	dc.w		0
messpos
	dc.l		message
message	
	dc.b		"                THIS DISK NOW RUNS ON 4 MEG MACHINES (ONLY RICH PEOPLE WOULD KNOW THAT IT DID NOT WORK - HENCE NO ONE IN AUTOMATION KNEW!!)    "
	dc.b		'                HI THERE FOLKS AND WELCOME TO AUTOMATION DISK 120, THIS IS ANDY THE ARFLING AT THE KEYBOARD DOING MY FIRST DISK UNDER THE AUTOMATION NAME SO I''LL KEEP THIS INTRO QUITE TAME, PLUS THERE ISN''T '
	DC.B		'MUCH ROOM LEFT ON THE DISK. LOOKS FAMILIAR TO BBC 12 DOESN''T IT ?   COMING SOON WILL BE ALL THE GAMES FROM THE OLD BBC DISKS, REPACKED '
	DC.B		'USING V2.3, ALSO ASTAROTH, CRASH GARRETT, SKY BLASTER, SKY FIGHTER, DOMINATOR AND MAYBE EVEN GAUNTLET II OR PRISON. I HAD ALL SORTS OF IDEAS AND INTERESTING TOPICS I WAS GOING TO TALK ABOUT ON THIS DISK, BUT NOW I COME TO ACTUALLY'
	DC.B		' WRITING THE MESSAGE,I CAN''T THINK OF A THING!!!  ERRR........CREDITS, ALL CODING BY ME, CHARACTER SET BY MR.MOO, OTHER GRAPHIX BY WAYNE, MUSIC BY CHRISPY NOODLE...... ERRRR....... GREETINGS TO THE REST OF '
	DC.B		'AUTOMATION ,HOSKAS,ARMANI (SORRY OUR UNION DIDN''T WORK OUT, I HOPE YOU''RE NOT TOO DISAPPOINTED,I''M LOOKING FORWARD TO WORKING WITH '
	DC.B		'YOU ON OUR PC-SHOW PROJECT),THE TIMELORDS  (HI T.T.C.,ULTRA MAGNETIC,ETC..), THE LOST BOYS,THE MEDWAYS BOYS, JOBIL AND JOHN, STAN THE MAN, HAL AND THE EDITMAN, ELECTRONIC IMAGES.... THAT''S IT FOR THE PEOPLE I KNOW, IF YOU''RE '
	DC.B		'NOT INCLUDED CHECK OUT THE EARLY BBC DISKS THEN GIVE ME A CALL (HINT,HINT). NOW ONTO A MORE SERIOUS SUBJECT,WHY HAVE LONDON GROUPS STARTED ADDING "OF LONDON# TO THE END OF THEIR NAMES?  FIRST THERE WAS '
	DC.B		'THE LOST BOYS OF LONDON,THEN THE TIMELORDS OF LONDON,WHAT NEXT,THE BBC OF LONDON?           '
	dc.b		'WELL NOW, AS MY FIRST AUTOMATION SCROLLER DRAWS TO A CLOSE, AS NEIL PUTS IT, GET PRESSING.........CHEEEEEEEEEEEEEEEERIO        ',0

file1
	dc.b		'THUN0',0
file2
	dc.b		'BEAM0',0
file3
	dc.b		'RICK.BBC',0

	even

music
	incbin	'sexpress.mus'
	even
picture
	incbin	'ship.pi1'
charset
	incbin	'big_moo.dat'

	section	bss

charset2
	ds.b		$cad0

	end