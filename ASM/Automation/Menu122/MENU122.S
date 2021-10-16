start
	pea		$500.w
	move.l	8(a7),-(a7)
	move.l	#$4a0000,-(a7)
	trap		#1
	add.w	#12,a7
	move.w	#2,-(a7)
	trap		#14
	addq.l	#2,a7
	move.l	d0,screen
	sub.l	#$7d00,d0
	move.l	d0,screen2
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
	move.l	#mfp,$120.w


;******** Pre-shift for character set ************
	lea		charset,a0
	lea		charset2,a1
	move.w	#$cac,d0
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

	lea		scrollheight,a0
	lea		scrollhgt,a1
multy
	move.b	(a0)+,d0
	and.w	#$ff,d0
	cmp.w	#$ff,d0
	beq.s	endmulty
	move.w	d0,(a1)+
	mulu		#160,d0
	move.w	d0,(a1)+
	bra.s	multy
endmulty
	move.w	#-1,(a1)

	lea		picture+34,a0
	move.l	screen,a1
	move.l	screen2,a2
	move.w	#799,d0
copypix
	movem.l	(a0)+,d1-d7/a3-a5
	movem.l	d1-d7/a3-a5,(a1)
	movem.l	d1-d7/a3-a5,(a2)
	lea		40(a1),a1
	lea		40(a2),a2
	dbf		d0,copypix

	move.b	#$d,music

	move.w	#$2300,sr			Initialised

main_loop
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
	move.l	screen,d0
	lsr.l	#8,d0	
	move.b	d0,$ff8203
	lsr.w	#8,d0
	move.b	d0,$ff8201
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
	cmp.l	#file2,a6
	beq.s	xtd
	lea		start+$400,a7
	pea		dummy
	pea		dummy
	move.l	a6,-(a7)
	move.l	#$4b0000,-(a7)
	trap		#1
	add.w	#16,a7
xtd
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
	move.l	screenpos,a1
	move.w	(a1)+,d0
	move.w	d0,inth
	move.w	(a1)+,d0
	tst.w	(a1)
	bpl.s	nosrpt
	lea		scrollhgt,a1
nosrpt
	move.l	a1,screenpos
	move.l	screen,a1
	add.w	d0,a1
	move.w	d0,oldht
	movem.l	blankmemory,d0-d7/a2-a3
	movem.l	d0-d7/a2-a3,(a1)
	movem.l	d0-d7/a2-a3,40(a1)
	movem.l	d0-d7/a2-a3,80(a1)
	movem.l	d0-d7/a2-a3,120(a1)
	movem.l	d0-d7/a2-a3,56*160(a1)
	movem.l	d0-d7/a2-a3,56*160+40(a1)
	movem.l	d0-d7/a2-a3,56*160+80(a1)
	movem.l	d0-d7/a2-a3,56*160+120(a1)
	lea		160(a1),a1
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

vbl
	movem.l	d0-d7/a0-a6,-(a7)
	move.b	inth+1,$fffa21
	move.b	#8,$fffa1b
	move.b	#56,$fffa21
	
	bsr		music+$2

	move.w	oldht2,d0
	move.w	oldht,oldht2
	lea		picture+34,a0
	move.l	screen,a1
	add.w	d0,a0
	add.w	d0,a1
	rept		57
	movem.l	(a0)+,d0-d7/a2-a3
	movem.l	d0-d7/a2-a3,(a1)
	movem.l	(a0)+,d0-d7/a2-a3
	movem.l	d0-d7/a2-a3,40(a1)
	movem.l	(a0)+,d0-d7/a2-a3
	movem.l	d0-d7/a2-a3,80(a1)
	movem.l	(a0)+,d0-d7/a2-a3
	movem.l	d0-d7/a2-a3,120(a1)
	lea		160(a1),a1
	endr
	
	bsr		scroller
	move.l	screen,d0
	move.l	screen2,screen
	move.l	d0,screen2
	lsr.l	#8,d0
	move.b	d0,$ff8203
	lsr.w	#8,d0
	move.b	d0,$ff8201

	st		vbldone
	movem.l	(a7)+,d0-d7/a0-a6
	rte


key
	tst.b	-$3fe.w		($fffc02)
	tst.b	-$3fa.w		($fffc06)
	bclr		#6,-$5ef.w	($fffa11)
	rte

mfp
	move.w	#$222,$ff8240
	movem.l	d0-d7,-(a7)
	movem.l	pallette,d0-d7
	movem.l	d0-d7,$ff8240
	movem.l	(a7)+,d0-d7
	move.l	#mfp2,$120.w
	bclr		#0,$fffa0f
	rte

mfp2
	clr.w	$ff8240
	movem.l	d0-d7,-(a7)
	movem.l	picture+2,d0-d7
	movem.l	d0-d7,$ff8240
	movem.l	(a7)+,d0-d7
	move.l	#mfp,$120.w
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
	dc.l		$f8000
screen2
	dc.l		$f0000
oldht
	dc.w		0
oldht2
	dc.w		0
inth
	dc.w		0
oldstack
	dc.l		0
screenpos
	dc.l		scrollhgt
scrollheight
	incbin	'points'
	dc.b		-1

	even

pallette
	dc.w		$222,$333,$444,$555,$666,$700,$722,$744,$60,$272,$707,$770,$337,$7,$4,$777

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
	DC.B		'         HI THERE FOLKS AND WELCOME TO AUTOMATION DISK 122, COMPILED BY ANDY THE ARFLING.  IF I DON''T MENTION THAT SKY FIGHTER WAS REPACKED BY THE PILOT HE WILL NEVER STOP MOANING, SO NOW YOU KNOW  ( I 1-FILED IT AS MUCH AS POSSIBLE ORI'
	DC.B		'GINALLY BUT THEN I HAPPY PACKED IT, STILL, WHO CARES ANYWAY? ).   GREETS GO TO ALL USUAL PEOPLE, THE MEDWAY BOYS, THE TIMELORDS, THE LOST BOYS, ARMANI, STAN THE MAN, JOBIL AND JOHN, HAL AND THE EDITMAN, DEREK M.D.  AND NOT FORGETTING THE '
	DC.B		'MEGA-MIGHTY CAREBEARS ( SLURP,SLURP ).  MY APOLOGIES THAT THIS DISK COMES AFTER 124 AND 127 BUT I''VE BEEN TRYING TO HACK GAUNTLET II, MORE NEWS ON THAT FRONT SOME OTHER TIME. I''VE HEARD VIGILANTE IS CAUSING SOME GRIEF AND AGGREVATION TO '
	DC.B		'SOME PEOPLE,  WILL SOMEONE SEND IT TO ME,PLEASE!     HOW DID YOU LIKE THE SCROLL MESSAGE ON THE LAST DISK, WRITTEN BY ELTRON,I NOW HAVE TWO MORE SCROLLERS FROM HIM,BUT I''VE NO TIME OR DISK SPACE FOR ANOTHER ONE NOW.   NOW FOR ANOTHER '
	DC.B		'PLEA,WOULD PEOPLE PLEASE STOP PHONING ME AND TELLING ME THAT AUTOMATION ARE SPLITTING UP,IT''S JUST NOT TRUE, DISK 200 HERE WE COME!   MESSAGE TO BIRDY, I''VE HEARD THAT YOU THINK I WAS BULL-SHITTING WHEN I SAID I''VE CRACKED THE UNION DEMO'
	DC.B		', JUST NAME A SCREEN AND I''LL SEND IT TO YOU IN A FILE,SO THERE,SUCK ON THAT!    WELL,I''M GOING WRAP THINGS UP NOW,SO CHEEEEEEEEEEEEEEEEEEEERIO FROM ME,ANDY THE ARFLING.  ',0
 
	
file1
	dc.b		'forgottn.bbc',0
file2
	dc.b		'skyfight.bbc',0

	even

music
	incbin	'thunwing.mus'
picture
	incbin	'spacefly.pi1'
charset
	incbin	'big_moo.dat'

	section	bss

charset2
	ds.b		$cad0
blankmemory
	ds.b		40
scrollhgt
	ds.l		100

	end