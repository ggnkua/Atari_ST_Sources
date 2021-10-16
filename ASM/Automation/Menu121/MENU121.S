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

	movem.l	picture+2,d0-d7
	movem.l	d0-d7,$ff8240

	lea		picture+34,a0
	move.l	screen,a1
	move.l	screen2,a2
	move.w	#7999,d0
copypic
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf		d0,copypic

	bsr		music

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
	add.w	#160*10,a1		Line 10 on screen
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
	move.b	#66,$fffa21
	move.b	#8,$fffa1b
	movem.l	pallette,d0-d7
	movem.l	d0-d7,$ff8240
	
	bsr		music+$a8
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
	movem.l	d0-d7,-(a7)
	movem.l	picture+2,d0-d7
	movem.l	d0-d7,$ff8240
	movem.l	(a7)+,d0-d7
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
oldstack
	dc.l		0

pallette
	dc.w		$557,$222,$444,$555,$666,$700,$722,$744,$60,$272,$707,$770,$337,$7,$4,$777

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
	dc.b		'             WELCOME TO AUTOMATION DISK 121,AGAIN COMPILED BY ANDY THE ARFLING,BUT NO NEED TO WORRY ON THE SCROLLER FRONT BECAUSE I''M NOT WRITING THIS ONE, JUST A QUICK DISCLAIMER : ANYTHIND SAID IN THE FOLLOWING SCROLLER IS ENTIRELY '
	DC.B		'FICTICOUS.NOW ON WITH THE SHOW..... BBC, THE BEST SHOWS....     '
	DC.B		'TO SCROLL OR NOT TO SCROLL,THAT IS THE QUESTION..... THIS IS ELTRON.... TELL ME BOY, DO YOU HAVE ROOM..... IN YOUR HEART.... FOR THE COMPUTER BOOM..... HELLO BOYS AND GIRLS. LET''S GO AND SEE WHAT''S HAPPENING ON THE MAGIC ROUNDABOUT. '
	DC.B		'AND WHERE DO YOU FIND THE MAGIC ROUNDABOUT? THAT''S RIGHT CHILDREN - THROUGH THE BROKEN WINDOW..... IN THE GARDEN TODAY ARE DOUGHAL AND FLORENCE. "FLORENCE,# SAID DOUGHAL,"ARE YOU A VIRGIN ?# "YOU''D BETTER ASK ZEBEDY ABOUT THAT" SAID '
	DC.B		'FLORENCE, "BUT I THOUGHT YOU WERE ON THE PILL# SAID DOUGHAL. "NO,I USE ZEBEDY''S COIL#. DOUGHAL COULD SEE HE WAS BARKING UP THE WRONG TREE, SO HE WEED UP FLORENCE''S LEG INSTEAD. WE NO A SONG ABOUT THAT,DON''T WE CHILDREN. I CAN SEE '
	DC.B		'SOMEONE ELSE IN THE GARDEN, HE''S A LITTLE CHAP IN BLUE AND WHITE STRIPED PYJAMAS AND A LITTLE BOBBLE HAT. NOW WHO DO YOU THINK THAT COULD BE? DO YOU THINK IT''S ANDY-PANDY CHILDREN? ALMOST RIGHT,IT''S ANDY ARFLING. LET''S ALL WAVE TO '
	DC.B		'HIM. ARE YOU WAVING CHILDREN? (DON''T YOU FEEL STUPID WAVING AT YOUR ST,I HOPE NOBODY''S WATCHING YOU) "HELLO ANDY ARFLING# SAID DOUGHAL. "WHAT HAVE YOU BEEN DOING#. "I''V BEEN PLAYING WITH LOOPY-LOO# SAID ANDY."YOU DIRTY LITTLE '
	DC.B		'PERVERT# SAID FLORENCE. "HAVEN''T YOU GOT GAMES TO CRACK,HACK,PACK AND ALL THAT# SAID DOUGHAL. "I THOUGHT I''D LET THE WOODEN TOPS,CHRISPY AND PHIL,HAVE SOME OF THE GLORY FOR THE CHANGE. I''M GOING TO UNIVERSITY SOON AND I''VE GOT TO '
	DC.B		'STUDY#. "BIOLOGY PRATICAL WITH LOOPY LOO!# SAID DOUGHAL WITH A KNOWING SMILE. "WAIT A SECOND# SAID FLORENCE,"HOW CAN A DOG GIVE A KNOWING SMILE?# "TWO REASONS# SAID THE OMNI-PRESENT NARRATOR, "FIRSTLY THIS IS CHILDREN''S TELLY SO '
	DC.B		'ANYTHING IS ALLOWED,AND SECONDLY,DOUGHAL DRINKS CARLING BLACK NAME-TAG#. "SHOULD WE REALLY BE TALKING ABOUT ALCOHOL ON CHILDREN''S TV?# PERSISTED FLORENCE. "SHUT UP FLORENCE,YOU''RE SO SQAURE SOMETIMES# SAID DOUGHAL. JUST THE BRIAN CAME '
	DC.B		'BY MOVING AS FAST AS ANY SNAIL WITH A RED STRIPE DOWN HIS SHELL CAN, "WHAT''S THE HURRY, BRIAN?# SAID FLORENCE, "THAT FRENCH CHEF FROM THE LUNCH TIME COOKERY PROGRAM IS AFTER ME AGAIN#. "DID YOU KNOW THAT THE MAGIC ROUNDABOUT IS IN '
	DC.B		'FACT FRENCH AND ALL OUR VOICES ARE DUBBED ON AFTERWARDS IN ENGLISH" SAID ANDY ARFLING, TRYING TO PROVE THAT HE IS WORTHY OF ONE OF THE COUNTRY''S TOP UNIVERSITIES. "YOU MEAN I AM REALLY FRENCH?# SAID DOUGHAL, "WELL IF I AM A FRENCH DOG '
	DC.B		'I''D BETTER GO OUT AND CATCH RABIES LIKE ALL THE OTHER FRENCH DOGS.#  "AND I''D BETTER GO AND TAKE ALL MY UNDERWEAR OFF AND LOOSE ALL MY BRITISH BROADCASTING CORPORATION MORALS# SAID FLORENCE. "I DIDN''T KNOW YOU HAD ANY# SAID DOUGHAL. '
	DC.B		'"PISS OFF# SAID FLORENCE. "THAT''S THE SPIRIT# SAID BRIAN (REAL NAME : PIERRE) "WELCOME TO EUROPE.#  MEANWHILE,IN THE WOODENTOPS'' LITTLE HOUSE,PHIL AND CHRISPY ARE HARD AT IT. THEN MAZ WENT HOME AND THEY WERE ABLE TO GET ON WITH SOME '
	DC.B		'WORK. "I''VE JUST CRACKED XYBOTS INTO FILES IN 57 SECONDS# SAID PHIL. HE NEEDN''T HAVE BOTHERED SINCE CHRISPY WAS REALLY STILL IN AMERICA AND WAS ONLY THERE IN SPIRIT TO STOP MAZ GETTING TOTALLY BORED.I THINK THIS HAS GONE ON FAR TOO '
	DC.B		'SERIOUSLY LONG ENOUGH BY HALF. I AM ELTRON, THE SUPER HANGER-ON, SCROLL-WRITER EXCLUSIVELY TO THE BBC (ALTHOUGH I CAN BE BOUGHT). ALTHOUGH SHE DENIES IT VIGOROUSLY, THIS SCROLLER WAS CO-WRITTEN BY GILL. I KNOW THIS IS A RELATIVELY SHORT '
	DC.B		'SCROLLER BY MY STANDARDS, BUT I HOPE YOU FOUND IT ENTERTAINING. I BELIEVE IN QUALITY RATHER THAN QUANTITY, BESIDES, DON''T YOU THINK IT''S ABOUT TIME YOU SELECTED ONE OF THE GREAT GAMES CONTAINED ON THE AUTOMATION DISK. IF YOU ARE '
	DC.B		'ABROAD, CONTACT US. JUST SAY HI AND TELL US WHAT YOU THINK OF OUR STUFF. ARE WE BIG IN JAPAN? ARE WE INTO AMERICA? BACK IN THE USSR? NO MATTER WHERE YOU ARE ALL YOU NEED IS SOFTWARE, SWEET SOFTWARE, THERE''L BE SOFTWARE EVERYWHERE! YEAH! '
	DC.B		'I''M SURE WE MUST HAVE MADE IT IN EUROPE BY NOW. THIS IS ELTRON (WITH A LITTLE HELP FROM GILL) OF THE BBC SIGNING OFF UNTIL THE NEXT TIME, STAY COOL EVERYONE.                                      W R A P                ',0
 
	
file1
	dc.b		'STORMER.BBC',0
file2
	dc.b		'ASTAROTH.BBC',0

	even

music
	incbin	'ANDY.MUS'
picture
	incbin	'ferrari.pi1'
charset
	incbin	'big_moo.dat'

	section	bss

charset2
	ds.b		$cad0

	end