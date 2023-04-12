;*------------------------------------------------------------------------*
;*  QuaST Magazyn IX (C) 28.12.1975 QuaST Club / dysk #C - procedury *.S  *
;*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
;|																		  |
;|				Scroll II- scrolowanie rysunka na ST				  	  |
;|  																	  |
;| autor: Yoyo								    				  		  |	
;| uwagi: skrolowanie buforowane co 8 piksli, na 4 planach (movem)		  |																  |
;*------------------------------------------------------------------------*

linie	equ 171

		SECTION TEXT
		opt 	d+
	
		clr.l 	-(sp)
		move.w 	#32,-(sp)
		trap 	#1
		addq.w 	#6,sp
	
		move.l 	sp,stary
		move.l 	#stos,sp
	
		move.l 	#rys+34,adr
		move.l 	#rys+34+16,adr+4
		move.l 	#rys+34+32,adr+4*2
		move.l 	#rys+34+48,adr+4*3
		move.l 	#rys+34,adr+4*4
		move.l 	#rys+34,adr+4*5
		move.l 	#0,adr+4*6
	
		lea 	rys+2,a0
		lea 	$ffff8240.w,a1
		movem.l (a0),d0-d7
		movem.l d0-d7,(a1)
	
		move.w 	#0,-(sp)
		move.l 	#$f8000,-(sp)
		move.l 	#$f8000,-(sp)
		move.w 	#5,-(sp)
		trap 	#14
		adda.w 	#12,sp
	
		lea 	$f0000,a0
		bsr 	czysc_ekr
		lea 	$f8000,a0
		bsr 	czysc_ekr
		
		lea 	adr+4,a3

prg:	bsr 	wvbl
		move.w 	#$777,$ff8240
		bsr 	scroll
		move.w 	#$000,$ff8240
		cmpi.b 	#57,$fffffc02
		bne.s 	prg
	
		move.l 	stary,sp
	
		move.w 	#$000,$ff8240
		move.w 	#$070,$ff8246
	
		clr.w 	-(sp)
		trap 	#1

*******************************************************
	
SCROLL:	move.l (a3),a2
		tst.b 	$ffff8203.w
		beq 	ekran_f8000
	
		move.b 	#0,$ffff8203.w
		tst.b 	fantom
		beq.s 	srodek_fontu
		move.l 	-4(a3),a1
		lea 	9(a1),a1			4.b poprzedniego fnt
		clr.b 	fantom
		bra.s 	myk
srodek_fontu:
		lea 	8(a2),a2			3.b fnt
		lea 	-7(a2),a1			2.b fnt
		st 		fantom
myk:	lea 	$f0008,a0
		rept 	linie
		bsr 	copy
		endr
		RTS

*******************************

ekran_f8000:
		move.b 	#$80,$ffff8203.w
		tst.b 	fantom
		beq.s 	cyk
druga_polowa:
		lea 	8(a2),a2
		addq.w 	#4,a3
		tst.l 	(a3)
		beq 	od_poczatku
cyk:	lea 	$f8008,a0
		rept linie
		bsr copy1
		endr
		RTS

****************************************************

copy:	movem.l (a0)+,d0-d7/a5-a6
		movem.l d0-d7/a5-a6,-48(a0)
		movem.l (a0)+,d0-d7/a5-a6
		movem.l d0-d7/a5-a6,-48(a0)
		movem.l (a0)+,d0-d7/a5-a6
		movem.l d0-d7/a5-a6,-48(a0)
		movem.l (a0)+,d0-d7
		movem.l d0-d7,-40(a0)
		movep.l (a1),d0
		movep.l d0,-8(a0)
		movep.l (a2),d0
		movep.l d0,-7(a0)
		lea 	8(a0),a0
		lea 	160(a1),a1
		lea 	160(a2),a2
		rts
	
copy1:	movem.l (a0)+,d0-d7/a5-a6
		movem.l d0-d7/a5-a6,-48(a0)
		movem.l (a0)+,d0-d7/a5-a6
		movem.l d0-d7/a5-a6,-48(a0)
		movem.l (a0)+,d0-d7/a5-a6
		movem.l d0-d7/a5-a6,-48(a0)
		movem.l (a0)+,d0-d7
		movem.l d0-d7,-40(a0)
		move.l 	(a2)+,-8(a0)
		move.l 	(a2)+,-4(a0)
		lea 	160-8(a2),a2
		lea 	8(a0),a0
		rts
	
od_poczatku:
		lea 	adr+4,a3
		bra 	cyk	

czysc_ekr:	
		move.w 	#7999,d0
wx:		clr.l 	(a0)+
		dbf 	d0,wx
		rts
wvbl:	movem.l a0-a2/d0-d2,-(sp)
		move.w 	#37,-(sp)
		trap 	#14
		addq.w 	#2,sp
		movem.l (sp)+,a0-a2/d0-d2
		rts
	
		SECTION DATA
	
rys:	incbin \asembler.s\dane.dat\rys.pi1
end:	dc.b 0
fantom:	dc.b -1	

		SECTION BSS
	
		even
		ds.w 200
stos:
		ds.w 10
stary:	ds.l 1
poke:	ds.w 1
adr:	ds.l 80