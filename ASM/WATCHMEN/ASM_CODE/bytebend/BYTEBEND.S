
***********************************************
*   Byte-Bender routine for Nighthawks Font   *
*                                             *
*      By the sexy one from The Watchmen      *
*                                             *
***********************************************
* A LITTLE NOTE FROM MANIKIN:- 
* UNFORTUNATELY THE WATCHMEN HAVE FORGOTTEN TO INCLUDE RATHER AN
* IMPORTANT FILE ON THE DISK. THE TEXT FILE. BECAUSE OF THE WAY 
* THERE FONT IS ARRANGED YOU HAVE TO DOCTOR THE TEXT FILE FOR 
* IT TO APPEAR INTELLIGIBLE. ALSO THEIR CODE IS RATHER BUGGY AND 
* YOU MUST LEAVE THE ERROR HANDLING BIT IN THE CODE OR IT WON'T 
* WORK AT ALL. WE'LL TRY AND GET THE PROGRAM TO CREATE THE TEXT FILE
* AND ALSO THE MISSING TEXT FILE IN THE NEXT ISSUE (WON'T WE WATCHMEN!!!)


	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	lea	ourstack,a7
	clr	$ffff8240.w

	dc.w	$a00a
**********ERROR HANDLING BIT
	move.l	#return,8.w
	move.l	#return,12.w
	move.l	#return,16.w
****************************
	clr	-(sp)
	move.l	#$f0000,-(sp)
	move.l	#$f0000,-(sp)
	move	#5,-(sp)
	trap	#14
	adda.l	#12,sp

	bsr	clear_screens
	bsr	make_font
	bsr	copy_logo
	bsr	make_text
	bsr	do_music

	move.l	logic,d0

	rol	#8,d0
	move.b	d0,$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w

	move.l	#blank_int,$4d2


blank_int
	lea	logopal+2,a0
	move	(a0)+,$ffff8242.w
	movem.l	(a0),d0-d2
	movem.l	d0-d2,$ffff8244.w

	move.l	#-1,$ffff8250.w
	move.l	#-1,$ffff8254.w
	move.l	#-1,$ffff8258.w
	move.l	#-1,$ffff825c.w

	pea	palsplit
	move	#67,-(sp)
	move	#8,-(sp)
	move	#1,-(sp)
	move	#31,-(sp)
	trap	#14
	adda.l	#12,sp

	move.l	logic,d0
	move.l	wavepos,a2
	move.l	textpos,a3

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	addq	#1,a1
	move.l	(a3)+,a0
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	addq	#8,a1
	move.l	(a3)+,a0
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#9,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#16,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	adda	#17,a1
	move.l	(a3)+,a0
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#24,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#25,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	adda	#32,a1
	move.l	(a3)+,a0
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	adda	#33,a1
	move.l	(a3)+,a0
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#40,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#41,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#48,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#49,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#56,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#57,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#64,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#65,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#72,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#73,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#80,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#81,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#88,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#89,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#96,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	adda	#97,a1
	move.l	(a3)+,a0
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#104,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#105,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#112,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	adda	#113,a1
	move.l	(a3)+,a0
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#120,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#121,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#128,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#129,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#136,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#137,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#144,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#145,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#152,a1
	bsr	draw_char

	move.l	#0,a1
	move	(a2)+,a1
	add.l	d0,a1
	move.l	(a3)+,a0
	adda	#153,a1
	bsr	draw_char

	addq.l	#4,textpos
	move.l	textpos,a0
	cmpi.l	#-1,160(a0)
	bne	blank_2
	move.l	#text_data,textpos
blank_2
	subq.l	#2,wavepos
	cmpi.l	#wavestart,wavepos
	bne	blank_end
	move.l	#wavend,wavepos
blank_end
	rts

wave_right
	addq.l	#2,wavepos
	cmpi.l	#wavend,wavepos
	bne	wrend
	move.l	#wavestart,wavepos
wrend

wave_left
	subq.l	#2,wavepos
	cmpi.l	#wave,wavepos
	bne	wlend
	move.l	#wavend,wavepos
wlend

wave_stop
	bra.s	wstop
wstop	equ	(wlend-wave_left)+wave_stop

make_text
	lea	text,a0
	lea	text_data,a1
maktxt0
	moveq	#0,d0
	move.b	(a0)+,d0
 	cmpi	#$ff,d0
	beq.s	maktxt1
	mulu	#75*4,d0
	add.l	#font,d0
	move.l	d0,(a1)+
	add.l	#75,d0
	move.l	d0,(a1)+
	add.l	#75,d0
	move.l	d0,(a1)+
	add.l	#75,d0
	move.l	d0,(a1)+
	bra.s	maktxt0
maktxt1
	move.l	#-1,(a1)+
	move.l	#-1,(a1)+
	move.l	#-1,(a1)+
	move.l	#-1,(a1)+
	rts

palsplit
	clr.b	$fffffa1b.w
	move	fontpal+2,$ffff8242.w
	move.l	fontpal+4,$ffff8244.w
	move.l	fontpal+8,$ffff8248.w
	move.l	fontpal+12,$ffff824c.w
	rte


copy_logo
	lea	logopal,a1
	lea	logo,a0
	bsr	copy_palette
	move.l	logic,a1
	move.l	#67*20-1,d7
logo_loop
	move.l	(a0)+,(a1)+
	move	(a0)+,(a1)+
	clr	(a1)+
	dbra	d7,logo_loop
	rts
	
clear_screens
	lea	$f0000,a0
	move.w	#16383,d0
cl_loop	clr.l	(a0)+
	dbf	d0,cl_loop
	rts

make_font
	lea	font,a0
	lea	fontpal,a1
	bsr	copy_palette
	move.l	physic,a1
	move.l	#47*25*12/4-1,d7
makfnt
	move.l	(a0)+,(a1)+
	dbra	d7,makfnt
	move.l	physic,a0
	lea	font,a1
	moveq	#46,d7
makfnt0
	bsr	make_strips
	dbra	d7,makfnt0
	rts

make_strips

	bsr	makstrps
	addq.l	#1,a0
	bsr	makstrps
	addq.l	#5,a0
	bsr	makstrps
	addq.l	#1,a0
	bsr	makstrps
	adda.l	#25*12-7,a0
	rts

makstrps
	move.b	12*0(a0),(a1)+
	move.b	12*0+2(a0),(a1)+
	move.b	12*0+4(a0),(a1)+

	move.b	12*1(a0),(a1)+
	move.b	12*1+2(a0),(a1)+
	move.b	12*1+4(a0),(a1)+

	move.b	12*2(a0),(a1)+
	move.b	12*2+2(a0),(a1)+
	move.b	12*2+4(a0),(a1)+

	move.b	12*3(a0),(a1)+
	move.b	12*3+2(a0),(a1)+
	move.b	12*3+4(a0),(a1)+

	move.b	12*4(a0),(a1)+
	move.b	12*4+2(a0),(a1)+
	move.b	12*4+4(a0),(a1)+

	move.b	12*5(a0),(a1)+
	move.b	12*5+2(a0),(a1)+
	move.b	12*5+4(a0),(a1)+

	move.b	12*6(a0),(a1)+
	move.b	12*6+2(a0),(a1)+
	move.b	12*6+4(a0),(a1)+

	move.b	12*7(a0),(a1)+
	move.b	12*7+2(a0),(a1)+
	move.b	12*7+4(a0),(a1)+

	move.b	12*8(a0),(a1)+
	move.b	12*8+2(a0),(a1)+
	move.b	12*8+4(a0),(a1)+

	move.b	12*9(a0),(a1)+
	move.b	12*9+2(a0),(a1)+
	move.b	12*9+4(a0),(a1)+

	move.b	12*10(a0),(a1)+
	move.b	12*10+2(a0),(a1)+
	move.b	12*10+4(a0),(a1)+

	move.b	12*11(a0),(a1)+
	move.b	12*11+2(a0),(a1)+
	move.b	12*11+4(a0),(a1)+

	move.b	12*12(a0),(a1)+
	move.b	12*12+2(a0),(a1)+
	move.b	12*12+4(a0),(a1)+

	move.b	12*13(a0),(a1)+
	move.b	12*13+2(a0),(a1)+
	move.b	12*13+4(a0),(a1)+

	move.b	12*14(a0),(a1)+
	move.b	12*14+2(a0),(a1)+
	move.b	12*14+4(a0),(a1)+

	move.b	12*15(a0),(a1)+
	move.b	12*15+2(a0),(a1)+
	move.b	12*15+4(a0),(a1)+

	move.b	12*16(a0),(a1)+
	move.b	12*16+2(a0),(a1)+
	move.b	12*16+4(a0),(a1)+

	move.b	12*17(a0),(a1)+
	move.b	12*17+2(a0),(a1)+
	move.b	12*17+4(a0),(a1)+

	move.b	12*18(a0),(a1)+
	move.b	12*18+2(a0),(a1)+
	move.b	12*18+4(a0),(a1)+

	move.b	12*19(a0),(a1)+
	move.b	12*19+2(a0),(a1)+
	move.b	12*19+4(a0),(a1)+

	move.b	12*20(a0),(a1)+
	move.b	12*20+2(a0),(a1)+
	move.b	12*20+4(a0),(a1)+

	move.b	12*21(a0),(a1)+
	move.b	12*21+2(a0),(a1)+
	move.b	12*21+4(a0),(a1)+

	move.b	12*22(a0),(a1)+
	move.b	12*22+2(a0),(a1)+
	move.b	12*22+4(a0),(a1)+

	move.b	12*23(a0),(a1)+
	move.b	12*23+2(a0),(a1)+
	move.b	12*23+4(a0),(a1)+

	move.b	12*24(a0),(a1)+
	move.b	12*24+2(a0),(a1)+
	move.b	12*24+4(a0),(a1)+

	rts
set_palette
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

copy_palette
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	rts


draw_char
	clr.b	(a1)
	clr.b	2(a1)
	clr.b	4(a1)

	clr.b	160(a1)
	clr.b	162(a1)
	clr.b	164(a1)


	move.b	(a0)+,320(a1)
	move.b	(a0)+,322(a1)
	move.b	(a0)+,324(a1)

	move.b	(a0)+,480(a1)
	move.b	(a0)+,482(a1)
	move.b	(a0)+,484(a1)

	move.b	(a0)+,640(a1)
	move.b	(a0)+,642(a1)
	move.b	(a0)+,644(a1)

	move.b	(a0)+,800(a1)
	move.b	(a0)+,802(a1)
	move.b	(a0)+,804(a1)

	move.b	(a0)+,960(a1)
	move.b	(a0)+,962(a1)
	move.b	(a0)+,964(a1)

	move.b	(a0)+,1120(a1)
	move.b	(a0)+,1122(a1)
	move.b	(a0)+,1124(a1)

	move.b	(a0)+,1280(a1)
	move.b	(a0)+,1282(a1)
	move.b	(a0)+,1284(a1)

	move.b	(a0)+,1440(a1)
	move.b	(a0)+,1442(a1)
	move.b	(a0)+,1444(a1)

	move.b	(a0)+,1600(a1)
	move.b	(a0)+,1602(a1)
	move.b	(a0)+,1604(a1)

	move.b	(a0)+,1760(a1)
	move.b	(a0)+,1762(a1)
	move.b	(a0)+,1764(a1)

	move.b	(a0)+,1920(a1)
	move.b	(a0)+,1922(a1)
	move.b	(a0)+,1924(a1)

	move.b	(a0)+,2080(a1)
	move.b	(a0)+,2082(a1)
	move.b	(a0)+,2084(a1)

	move.b	(a0)+,2240(a1)
	move.b	(a0)+,2242(a1)
	move.b	(a0)+,2244(a1)

	move.b	(a0)+,2400(a1)
	move.b	(a0)+,2402(a1)
	move.b	(a0)+,2404(a1)

	move.b	(a0)+,2560(a1)
	move.b	(a0)+,2562(a1)
	move.b	(a0)+,2564(a1)

	move.b	(a0)+,2720(a1)
	move.b	(a0)+,2722(a1)
	move.b	(a0)+,2724(a1)

	move.b	(a0)+,2880(a1)
	move.b	(a0)+,2882(a1)
	move.b	(a0)+,2884(a1)

	move.b	(a0)+,3040(a1)
	move.b	(a0)+,3042(a1)
	move.b	(a0)+,3044(a1)

	move.b	(a0)+,3200(a1)
	move.b	(a0)+,3202(a1)
	move.b	(a0)+,3204(a1)

	move.b	(a0)+,3360(a1)
	move.b	(a0)+,3362(a1)
	move.b	(a0)+,3364(a1)

	move.b	(a0)+,3520(a1)
	move.b	(a0)+,3522(a1)
	move.b	(a0)+,3524(a1)

	move.b	(a0)+,3680(a1)
	move.b	(a0)+,3682(a1)
	move.b	(a0)+,3684(a1)

	move.b	(a0)+,3840(a1)
	move.b	(a0)+,3842(a1)
	move.b	(a0)+,3844(a1)

	move.b	(a0)+,4000(a1)
	move.b	(a0)+,4002(a1)
	move.b	(a0)+,4004(a1)

	move.b	(a0)+,4160(a1)
	move.b	(a0)+,4162(a1)
	move.b	(a0)+,4164(a1)

	clr.b	4320(a1)
	clr.b	4322(a1)
	clr.b	4324(a1)

	clr.b	4480(a1)
	clr.b	4482(a1)
	clr.b	4484(a1)

	rts

logic	dc.l	$f8000
physic	dc.l	$f0000
logopal	ds.l	8
fontpal	ds.l	8
wavepos	dc.l	wavend
textpos	dc.l	text_data


; ROUTINE TO RELOCATE A RELOCATEABLE FILE (GOBBLE GLOOKE?)

do_music
	MOVE.L  #music,A0    Start of HEADER 
	MOVE.L  2(A0),D0      Length of PROGRAM 
	ADD.L   6(A0),D0      
	ADD.L   14(A0),D0     Length of SYMBOL TABLE
; D0 contains relative position of RELOCATION TABLE
	ADD.L   #$1C,A0       A0 Points to programs start adress
	MOVE.L  A0,A1         
	MOVE.L  A1,A2         
	MOVE.L  #music+$1c,D1    This is the adress we relocate the program
;                             to execute from

	ADD.L   D0,A1         Get adress of RELOCATION TABLE
	MOVE.L  (A1)+,D0      Get the Long Word
	ADD.L   D0,A2         
	ADD.L   D1,(A2)       Relocate it
	CLR.L   D0            
mRELO:	MOVE.B  (A1)+,D0      Get next byte from table
	BEQ     mRELEND        Is it the end (zero)
	CMP.B   #1,D0         1 is a 254 jump
	BEQ     mJUMP          If it is then do it
	ADD.L   D0,A2         If not find next absolute adress
	ADD.L   D1,(A2)       and relocate it
	BRA     mRELO          Continue until the zero is found
mJUMP:	ADD.L   #254,A2       Jump 254 bytes
	BRA     mRELO          and continue
mRELEND:
	move	#$4e75,music+$2c
	jsr	music
	rts

return	rte

music
	incbin	"a:\programm.ing\bytebend.twm\i_karate.tos"


wavestart
	dcb.w	40,125*160
	include	"programm.ing\bytebend.twm\bbendtab.s"
wavend
	dcb.w	40,125*160
text
	dc.b	'                            '
	dc.b	' YO THIS IS THE WATCHMENS EXCELLENT BYTE BENDER SCROLLINE. FIND THE COMPLETE SOURCE CODE ON THIS DISK. MANY THANKS TO THE WATCHMEN FOR THEIR INVALUABLE '
	dc.b	'ASSISTANCE TO THE LOST BOYS DISK MAGGIE ISSUE 2....'
	dc.b	'                            '
	dc.b	$ff
	even
	ds.l	100
ourstack
logo
	incbin	"programm.ing\bytebend.twm\3bit_twm.dat"
font
	incbin	"programm.ing\bytebend.twm\nitehawk.dat"
a0	equ	font
a1	equ	a0+75
a2	equ	a1+75
a3	equ	a2+75
b0	equ	a3+75
b1	equ	b0+75
b2	equ	b1+75
b3	equ	b2+75
c0	equ	b3+75
c1	equ	c0+75
c2	equ	c1+75
c3	equ	c2+75
d0	equ	c3+75
d1	equ	d0+75
d2	equ	d1+75
d3	equ	d2+75
e0	equ	d3+75
e1	equ	e0+75
e2	equ	e1+75
e3	equ	e2+75
f0	equ	e3+75
f1	equ	f0+75
f2	equ	f1+75
f3	equ	f2+75
g0	equ	f3+75
g1	equ	g0+75
g2	equ	g1+75
g3	equ	g2+75
h0	equ	g3+75
h1	equ	h0+75
h2	equ	h1+75
h3	equ	h2+75
i0	equ	h3+75
i1	equ	i0+75
i2	equ	i1+75
i3	equ	i2+75
j0	equ	i3+75
j1	equ	j0+75
j2	equ	j1+75
j3	equ	j2+75
k0	equ	j3+75
k1	equ	k0+75
k2	equ	k1+75
k3	equ	k2+75
l0	equ	k3+75
l1	equ	l0+75
l2	equ	l1+75
l3	equ	l2+75
m0	equ	l3+75
m1	equ	m0+75
m2	equ	m1+75
m3	equ	m2+75
n0	equ	m3+75
n1	equ	n0+75
n2	equ	n1+75
n3	equ	n2+75
o0	equ	n3+75
o1	equ	o0+75
o2	equ	o1+75
o3	equ	o2+75
p0	equ	o3+75
p1	equ	p0+75
p2	equ	p1+75
p3	equ	p2+75
q0	equ	p3+75
q1	equ	q0+75
q2	equ	q1+75
q3	equ	q2+75
r0	equ	q3+75
r1	equ	r0+75
r2	equ	r1+75
r3	equ	r2+75
s0	equ	r3+75
s1	equ	s0+75
s2	equ	s1+75
s3	equ	s2+75
t0	equ	s3+75
t1	equ	t0+75
t2	equ	t1+75
t3	equ	t2+75
u0	equ	t3+75
u1	equ	u0+75
u2	equ	u1+75
u3	equ	u2+75
v0	equ	u3+75
v1	equ	v0+75
v2	equ	v1+75
v3	equ	v2+75
w0	equ	v3+75
w1	equ	w0+75
w2	equ	w1+75
w3	equ	w2+75
x0	equ	w3+75
x1	equ	x0+75
x2	equ	x1+75
x3	equ	x2+75
y0	equ	x3+75
y1	equ	y0+75
y2	equ	y1+75
y3	equ	y2+75
z0	equ	y3+75
z1	equ	z0+75
z2	equ	z1+75
z3	equ	z2+75
num00	equ	z3+75
num01	equ	num00+75
num02	equ	num01+75
num03	equ	num02+75
num10	equ	num03+75
num11	equ	num10+75
num12	equ	num11+75
num13	equ	num12+75
num20	equ	num13+75
num21	equ	num20+75
num22	equ	num21+75
num23	equ	num22+75
num30	equ	num23+75
num31	equ	num30+75
num32	equ	num31+75
num33	equ	num32+75
num40	equ	num33+75
num41	equ	num40+75
num42	equ	num41+75
num43	equ	num42+75
num50	equ	num43+75
num51	equ	num50+75
num52	equ	num51+75
num53	equ	num52+75
num60	equ	num53+75
num61	equ	num60+75
num62	equ	num61+75
num63	equ	num62+75
num70	equ	num63+75
num71	equ	num70+75
num72	equ	num71+75
num73	equ	num72+75
num80	equ	num73+75
num81	equ	num80+75
num82	equ	num81+75
num83	equ	num82+75
num90	equ	num83+75
num91	equ	num90+75
num92	equ	num91+75
num93	equ	num92+75
lbrk0	equ	num93+75
lbrk1	equ	lbrk0+75
lbrk2	equ	lbrk1+75
lbrk3	equ	lbrk2+75
excl0	equ	lbrk3+75
excl1	equ	excl0+75
excl2	equ	excl1+75
excl3	equ	excl2+75
rbrk0	equ	excl3+75
rbrk1	equ	rbrk0+75
rbrk2	equ	rbrk1+75
rbrk3	equ	rbrk2+75
col0	equ	rbrk3+75
col1	equ	col0+75
col2	equ	col1+75
col3	equ	col2+75
hyp0	equ	col3+75
hyp1	equ	hyp0+75
hyp2	equ	hyp1+75
hyp3	equ	hyp2+75
dot0	equ	hyp3+75
dot1	equ	dot0+75
dot2	equ	dot1+75
dot3	equ	dot2+75
com0	equ	dot3+75
com1	equ	com0+75
com2	equ	com1+75
com3	equ	com2+75
aps0	equ	com3+75
aps1	equ	aps0+75
aps2	equ	aps1+75
aps3	equ	aps2+75
qte0	equ	aps3+75
qte1	equ	qte0+75
qte2	equ	qte1+75
qte3	equ	qte2+75
qse0	equ	qte3+75
qse1	equ	qse0+75
qse2	equ	qse1+75
qse3	equ	qse2+75
spc0	equ	qse3+75
spc1	equ	spc0+75
spc2	equ	spc1+75
spc3	equ	spc2+75
text_data equ	spc3+75
