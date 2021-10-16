; Ok,this is still a pretty shitty menu,but
; at least it's a bit better now!
; Circles can be included occasionally
; depending on time of music
; ANADIN still required!!!!


tester	equ	$0		Change to 0 to run on half meg

	MOVE.L $4(A7),A5
	MOVE.L #$100,-(SP)
	MOVE.L A5,-(SP)
	MOVE.L #$4A0000,-(SP)
	TRAP #1
	LEA $C(A7),A7

	lea	charset,a0
	lea	$38000+tester,a1		
	move.w	#$1f3f,d0
rrt2	move.l	(a0)+,(a1)+
	dbf		d0,rrt2
	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l d0,ssp
	move.w #2,-(sp)
	trap #14
	move.l d0,scrn
	move.l a7,sava7
	lea $ffff8240.w,a0
	movem.l (a0)+,d0-d7
	movem.l d0-d7,col
	clr.b	$ff8260		(Hope that's in the VBL!!!)
	move.b	#$7,$ff8201
	move.b	#$0,$ff8203
	lea $7fff8,a7
	lea $70000,a0
loop	clr.l	(a0)+
	cmp.l	#$7f000,a0
	bne.s	loop
;		SPECTRUM ROUTINE
	lea pic(pc),a0
r_go
	move.l	a0,a5
	move.l $4(a0),d0
	move.l $8(a0),d1
	subq.l #1,d0
	subq.l #1,d1
	lea $c(a0),a0
	lea $20000+tester,a1
kkkl	move.b (a0)+,(a1)+
	dbf d0,kkkl
	lea $28000+tester,a2
lllk	move.b (a0)+,(a2)+
	dbf d1,lllk
	bsr tosc
;	END SPECTRUM ROUTINE
r_rts
	pea moff
	move.l #$190001,-(sp)
	trap #14
	addq.l #8,sp

	move.b $fffffa1b.w,xa1b
	move.b $fffffa21.w,xa21
	move.b $fffffa0f.w,xa0f
	move.b $fffffa11.w,xa11
	moveq	#0,d0
	bsr		music
	move.l $120.w,sav120

	move.l #s4d6,$4d6
	lea $fffffa00.w,a0
	movep.w $7(a0),d0
	move.w d0,xfa07
	movep.w $13(a0),d0
	move.w d0,xfa13
	move.l #int4ce2,$4d2
	move.w #$100,d0
	movep.w d0,$7(a0)
	movep.w d0,$13(a0)

	move.l #8,td7
	move.w #0,fl7
	move.l #scroller,$4da.w
	move.l #keys,$4de.w
	bra mainlp
t8	dc.l 0
fl7	dc.w 0
td7	dc.l 0
one	dc.l 0,0
sav118	dc.l 0

*********************************
******** S C R O L L E R ********
*********************************

scroller	movem.l	d0-d7/a0-a6,-(a7)
		bsr		scroll
		bsr		circles		    No time for these,try Jochen's music
		movem.l	(a7)+,d0-d7/a0-a6		
		rts							

scroll	subq.w	#4,scrlpos
		move.w	scrlpos,d0
		and.w	#$1f,d0
		jmp		scrltab(pc,d0.w)

scrlpos	dc.w		32
scrloff	dc.w		32
		
scrltab
		bra		scroll1
		bra		scroll2
		bra		scroll3
		bra		scroll4
		bra		scroll5
		bra		scroll6
		bra		scroll7
		bra		scroll8

scrollp1	equ		$70000-$230*$80+tester
scrollp2	equ		$70000-$230*$60+tester
scrollp3	equ		$70000-$230*$40+tester
scrollp4	equ		$70000-$230*$20+tester
		
scroll1
		lea		scrollp1+8,a0
		bsr		show
		lea		scrollp1+$23f0,a0
		move.l	chargraf,a1
		add.w	#$100,a1
		moveq	#0,d0
		bsr	addlet
		move.l	messpos,a0
		moveq	#0,d0
		move.b	(a0)+,d0
		bpl.s	okchar
		moveq	#32,d0
		lea	message,a0
okchar		move.l	a0,messpos
		sub.w	#32,d0
		moveq	#9,d1
		lsl.w	d1,d0
;		add.l	#charset,d0
		add.l	#$38000+tester,d0		Where I move the charset
		move.l	d0,chargraf
		add.w	#$10,scrloff
		cmp.w	#$130,scrloff
		bne.s	nooffrpt
		move.w	#$20,scrloff
nooffrpt	
		rts

scroll2
		lea		scrollp2+8,a0
		bsr		show
		lea		scrollp2+$23f0,a0
		move.l	chargraf,a1
		add.w	#$100,a1
		moveq	#4,d0
		bra		addlet
scroll3
		lea		scrollp3+8,a0
		bsr		show
		lea		scrollp3+$23f0,a0
		move.l	chargraf,a1
		add.w	#$100,a1
		moveq	#8,d0
		bra		addlet
scroll4
		lea		scrollp4+8,a0
		bsr		show
		lea		scrollp4+$23f0,a0
		move.l	chargraf,a1
		add.w	#$100,a1
		moveq	#12,d0
		bra		addlet
scroll5
		lea		scrollp1,a0
		bsr		show
		lea		scrollp1+$f0,a0
		move.l	chargraf,a1
		moveq	#0,d0
		bra		addlet
scroll6
		lea		scrollp2,a0
		bsr		show
		lea		scrollp2+$f0,a0
		move.l	chargraf,a1
		moveq	#4,d0
		bra		addlet
scroll7
		lea		scrollp3,a0
		bsr		show
		lea		scrollp3+$f0,a0
		move.l	chargraf,a1
		moveq	#8,d0
		bra		addlet
scroll8
		lea		scrollp4,a0
		bsr		show
		lea		scrollp4+$f0,a0
		move.l	chargraf,a1
		moveq	#12,d0
		bra		addlet

show
		add.w	scrloff,a0
		lea		$77d00+4*160,a1
		rept		32
		movem.l	(a0)+,d0-d7/a2-a3
		movem.l	d0-d7/a2-a3,(a1)
		movem.l	(a0)+,d0-d7/a2-a3
		movem.l	d0-d7/a2-a3,40(a1)
		movem.l	(a0)+,d0-d7/a2-a3
		movem.l	d0-d7/a2-a3,80(a1)
		movem.l	(a0)+,d0-d7/a2-a3
		movem.l	d0-d7/a2-a3,120(a1)
		lea		$190(a0),a0
		lea		160(a1),a1
		endr
		rts

addlet	add.w	scrloff,a0
		moveq	#15,d3
addone	rept		4
		moveq	#0,d2
		move.w	(a1)+,d1
		swap		d1
		move.w	6(a1),d1
		move.w	d1,d2
		swap 	d2
		lsr.l	d0,d1
		lsr.l	d0,d2
		move.w	d1,8(a0)
		move.w	d1,8-$110(a0)
		move.w	d2,16(a0)
		move.w	d2,16-$110(a0)
		swap		d1
		or.w		d1,(a0)+
		move.w	-2(a0),-$112(a0)
		endr
		lea		$228(a0),a0
		addq.l	#8,a1
		dbf		d3,addone
		rts


charpal	dc.w		0,$220,$330,$440,$550,$660,$770,$555,0,0,0,0,0,0,0,0

chargraf	dc.l		charset
messpos	dc.l		startmess

startmess	dcb.b	10,' '
message	dc.b	'       HI THERE FOLKS OUT THERE IN CD LAND,NOW COME ON,OWN UP,WHO PUT GEORGE MICHAEL IN MY SPECTRUM PIC?'
	dc.b	'     STOP PRESS : THERE IS A DOC FILE FOR WARHEAD ON THIS DISK,PRESS SPACE TO SEE IT.   '
	dc.b	'   NOW IT''S GETTING VERY LATE AND I''M GETTING VERY PISSED OFF TODAY SO I''LL KEEP THIS SHORT,SO LET''S WRAP!!!'
	dc.b	'  NO,SERIOUSLY,I SHOULD AT LEAST GREET SOME PEEPS FIRST,SO HERE GOES....   GREETINGS TO THE MEDWAY BOYS,THE REPLICANTS,'
	DC.B	'THE BIG FOUR,ST AMIGOS,THE POMPEY PIRATES,OVERLANDERS,THE EMPIRE,DEREK MD,THE HOMEBOY,YOUNG JOE,THE LOST BOYS,OMEGA,SYNC,'
	DC.B	'FLEXIBLE FRONT,NIGHTBREED,SEWER SOFT AND TO ALL THOSE (EX) HACKERS AT THALION!  FINALLY,DOES ANYONE HAVE A SPARE ST LYING AROUND?'
	DC.B	' MY POOR MACHINE PASSED ON OVER A MONTH AGO,WHICH IS MY MAIN EXCUSE WHY I''VE NOT BEEN DOING ''NUFF ''NUFF LATELY. FINALLY FINALLY,'
	DC.B	' TELEPHONE GREETS TO HAL,WHY NOT DO HIM A FAVOUR,CALL 0898 446970 (WORTH A LAUGH TOO!).     WRAP!        '
	dc.b	' YES I THOUGHT I WAS GOING TOO,JUST ONE SMALL THING,I THINK I''VE JUST FIXED THE BOTTOM BORDER ROUTINE TO WORK ON STE''S.'
	dc.b	' CAN SOMEONE TELL ME IF IT WORKS?             ',-1   

		even

*******************************************************************

*********************************
********  C I R C L E S  ********
*********************************

circles	lea		circs,a0
		lea		$77d00+4*160+6,a1
		rept		2		
		movem.w	(a0)+,d0-d7/a2-a5
		move.w	d0,(a1)
		move.w	d1,152(a1)
		move.w	d2,160(a1)
		move.w	d3,312(a1)
		move.w	d4,320(a1)
		move.w	d5,472(a1)
		move.w	d6,480(a1)
		move.w	d7,632(a1)
		move.w	a2,640(a1)
		move.w	a3,792(a1)
		move.w	a4,800(a1)
		move.w	a5,952(a1)
		movem.w	(a0)+,d0-d7/a2-a5
		move.w	d0,960(a1)
		move.w	d1,960+152(a1)
		move.w	d2,960+160(a1)
		move.w	d3,960+312(a1)
		move.w	d4,960+320(a1)
		move.w	d5,960+472(a1)
		move.w	d6,960+480(a1)
		move.w	d7,960+632(a1)
		move.w	a2,960+640(a1)
		move.w	a3,960+792(a1)
		move.w	a4,960+800(a1)
		move.w	a5,960+952(a1)
		movem.w	(a0)+,d0-d7
		move.w	d0,960+960(a1)
		move.w	d1,960+1112(a1)
		move.w	d2,960+1120(a1)
		move.w	d3,960+1272(a1)
		move.w	d4,960+1280(a1)
		move.w	d5,960+1432(a1)
		move.w	d6,960+1440(a1)
		move.w	d7,960+1592(a1)
		lea		960+1600(a1),a1
		endr
		rts

************************************************

s4d6		movem.l 	d0-d7/a0-a6,-(sp)		Music
		bsr	music+$4
		movem.l 	(a7)+,d0-d7/a0-a6
		rts


ssp	dc.l 0
sava7	dc.l 0
scrn	dc.l 0
tosc	lea $20000+tester,a0
	lea $70000,a1
	moveq.l #1,d1
	clr.l d6
	moveq.l #7,d7
	lea $7d00(a1),a2
	lea $8(a2),a3
x1	lea -$7c60(a2),a1
x2	move.b (a0)+,d6
	ext.w d6
	bmi.s x4
x3	move.b (a0)+,(a1)
	adda.w d1,a1
	exg d1,d7
	dbf d6,x3
	bra.s v3
x4	neg.w d6
	addq.w #1,d6
	move.b (a0)+,d0
x5	move.b d0,(a1)
	adda.w d1,a1
	exg d1,d7
	dbf d6,x5
v3	cmpa.l a2,a1
	bcs.s x2
	bne.s ex
	addq.l #2,a2
	cmpa.l a3,a2
	bcs.s x1
	move.l a0,d0
	addq.l #1,d0
	bclr #0,d0
	subi.l #$20000+tester,d0
	move.l	a5,a4
	cmp.l $4(a4),d0
	bne.s ex
	lea $28000+tester,a0
	lea $2c5f6+tester,a1
	move.w #$254,d7
	clr.w d0
x6	moveq.l #13,d6
	move.w (a0)+,d1
	lsr.w #1,d1
	move.w d0,(a1)+
x7	lsr.w #1,d1
	bcc.s x8
	move.w (a0)+,(a1)+
	dbf d6,x7
	bra.s x9
x8	move.w d0,(a1)+
	dbf d6,x7
x9	move.w d0,(a1)+
	dbf d7,x6
ex	rts
;	SPECTRUM INTERUPT
int4ce2	
	move.w sr,-(sp)
	movem.l a0-a6/d0-d7,-(sp)
	bsr s4d2	; LOW BORDER SHIT

	lea $ffff8240.w,a4
	lea $ffff8209.w,a5
	lea (a4),a0
	lea (a4),a1
	lea (a4),a2
	lea pppp(pc),a6
	lea $2c616+tester,a3
	move.w #$c4,d1			Can be less for more tune time
	clr.l d0
v1a	tst.b (a5)
	beq.s v1a
	move.b (a5),d0
	adda.l d0,a6
	jmp (a6)
pppp	rept $78
	nop
	endr
v2a	nop
	nop
	lea (a4),a0
	lea (a4),a1
	lea (a4),a2
	rept 8
	move.l (a3)+,(a0)+
	endr
	rept 8
	move.l (a3)+,(a1)+
	endr
	rept 8
	move.l (a3)+,(a2)+
	endr
	dbf d1,v2a
	nop
	lea (a4),a0
	lea (a4),a1
	lea (a4),a2
	rept 8
	move.l (a3)+,(a0)+
	endr
	rept 8
	move.l (a3)+,(a1)+
	endr
	rept 8
	move.l (a3)+,(a2)+
	endr
	lea (a4),a0
	lea (a4),a1
	lea (a4),a2
	lea -$4a60(a3),a4
	nop
	nop
	nop
	rept 8
	move.l (a3)+,(a0)+
	endr
	rept 8
	move.l (a3)+,(a1)+
	endr
	rept 8
	move.l (a4)+,(a2)+
	endr
	movem.l charpal,d0-d7 	BORDER FONT COLS
	movem.l d0-d7,$ffff8240.w
	movem.l (a7)+,a0-a6/d0-d7
	move.w (a7)+,sr
	rts

keys
		move.b	$fffffc02.w,d1
		cmp.b	#$b,d1
		bne.s	nohtz
		bchg	#0,hz50_60
		eor.w	#7,charpal
		rts		
nohtz		move.l	#file1,d7
		cmp.b	#$2,d1
		beq.s 	DDD
		move.l	#file2,d7
		cmp.b	#$3,d1
		beq.s 	DDD
		move.l	#file3,d7
		cmp.b	#$39,d1
		beq.s	DDD
		rts

mainlp		dc.w	$60fe

DDD
	move.w #$2700,sr
	move.l sav120,$120.w
	lea $fffffa00.W,A0
	move.w xfa07,d0
	movep.w d0,$7(a0)
	move.w xfa13,d0
	movep.w d0,$13(a0)
	move.b	#7,$ffff8800.w
	move.b	$ffff8800.w,d1
	or.b	#$3f,d1
	moveq.w	#12,d0
clrsnd	move.b	d0,$ffff8800.w
	clr.b	$ffff8802.w
	dbra	d0,clrsnd
	move.b	#7,$ffff8800.w
	move.b	d1,$ffff8802.w
	move.b xa1b,$fffffa1b.w
	move.b xa21,$fffffa21.w
	move.b xa0f,$fffffa0f.w
	clr.b $fffffa11.w
	clr.l	$4d2
	clr.l	$4d6
	clr.l	$4da
	clr.l	$4de
	lea		$ff8240,a0
	moveq	#15,d0
clrcol clr.w	(a0)+
	dbf		d0,clrcol
letgo move.b	$fffffc02.w,d0
	btst		#7,d0
	beq.s	letgo
	move 	#$2300,sr
	move.b	scrn+1,$ff8201
	move.b	scrn+2,$ff8203
	move.l	scrn,a0
	move.w	#$1f3f,d0
.clear	clr.l	(a0)+
	dbf	d0,.clear
	pea moff+2
	move.l #$190001,-(sp)
	trap #14
	addq.l #8,sp
	clr.w $ffff8240.w
	move.w #$777,$ffff8246.w
	move.w #$777,$ffff825e.w
	move.b hz50_60,$ffff820a.w
	move.l ssp,-(sp)
	move.w #32,-(sp)
	trap #1
	sub.l #8,scrn
	move.l scrn,a7	
	pea		dummy
	pea		dummy
	move.l		d7,-(a7)
	pea		$4b0000
	trap		#1
	lea		16(a7),a7
	clr.w	-(a7)
	trap		#1

s4d2		movem.l d0-d7,-(sp)
		clr.b $fffa1b
		move.l #s120,$120
		move.b #$c6,$fffa21
		move.b #8,$fffa1b
		movem.l charpal,d0-d7
		movem.l d0-d7,$ff8240
		movem.l (a7)+,d0-d7
		rts



togfl		dc.l 0
moff		dc.l $1a121408
s120		clr.b $fffa1b
		bclr #0,$fffa0f
		move.w #$2200,sr
		move.l #s120b,$120
		move.b #$1,$fffa21
		move.b #8,$fffa1b
		rte
s120b		clr.b $fffa1b
		move.l d0,-(sp)
		move.w #$24,d0
xa		dbf d0,xa
		move.b #0,$ff820a
		move.w #2,d0
xa2		nop
		dbf d0,xa2
		move.b #2,$ff820a
		bclr #0,$fffa0f
		move.l (a7)+,d0
		rte


dummy	dc.l		0
file1	dc.b		'warhead1.bbc',0
file2	dc.b		'tjds',0
file3	dc.b		'no_file',0
	
		even

xa0f		dc.b 0
xfa07	dc.w 0
xfa13	dc.w 0
xa21		dc.b 0
xa1b		dc.b 0,0

sav120	dc.l 0
xa11		dc.w 0

	even

hz50_60	dc.b	2,0
col	ds.b 	32
	even

circs	incbin	'end_3.dat'
music    	incbin 	'foft.mus'
pic	incbin	'menu_252.spc'
charset	incbin	'phalanx.dat'
