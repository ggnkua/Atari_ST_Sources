screen	equ	$f8000

	opt	d+
	
	text
	
	pea	0
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
	
	clr.b	$ffff8260.w
	move.l	#screen,d0
	lea	$ffff8200.w,a0
	lsr.l	#8,d0
	movep	d0,1(a0)
	
	lea	screen,a0
	move	#(200*40)-1,d0
clear_scr	clr.l	(a0)+
	dbra	d0,clear_scr
	
	movem.l	pic_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	move.l	#dist,last_dist
	clr.l	pos_txt
			
	bsr	shiftit
	
main	move	#$25,-(a7)
	trap	#14
	addq	#2,a7
	
	clr	$ffff8240.w
	
	bsr	scroll
	
	move	#$2,$ffff8240.w
	
	cmp.b	#$39,$fffffc02.w
	bne.s	main
	
	pea	0
	trap	#1

font_heigh	equ	27

scroll	lea	screen+160*100,a1	
	lea	font_corres,a2	* Corresp: font-adresse
	lea	scroll_txt,a3	
	
	lea	ad_font,a6	* Corresp: abscisse-shift

	move.l	pos_txt,d4
	*neg.l	d4
	addq.L	#1,pos_txt
	cmp.L	#32*2,pos_txt
	bmi.s	zok
	clr.L	pos_txt
zok
	move.l	last_dist,a5
	addq	#2,a5
	tst	(a5)
	bpl.s	zloti
	lea	dist,a5
zloti	move.l	a5,last_dist
	
	clr	ligne_s
	
	moveq	#font_heigh,d0	* Nbre de lignes
big_affich	
	moveq	#10,d7	* 2 Caracteres
	lea	(a1),a4	* Adresse ecran
	
	move.l	d4,d6
	add	(a5)+,d6	* Valeur de la dist pour cette ligne
	*move	(a5)+,d2
	
	MOVE	D6,D2
	move	d2,d3
	and	#$fff0,d2	* Adresse on screen
	lsr	#1,d2
	and	#$f,d3	* pixel wise adress
	add	d3,d3
	add	d2,a4
	
	
	tst	(a5)
	bpl.s	zlotib
	lea	dist,a5
zlotib	
	move.l	d6,d1
	
	lsr.l	#5,d1	* On /32: on est de fonte a fonte
	move.b	(a3,d1),d1	* Valeur du caractere
	add	d1,d1
	add	d1,d1
	move.l	(a2,d1),a0	* Adresse du caractere
	add	(a6,d3),a0	* Adresse de la bonne zone
	add	ligne_s,a0	* Adresse de la bonne ligne
	
	move.l	(a0)+,d1
	or.l	d1,(a4)
	move	(a0)+,d1
	or	d1,4(a4)
	
	move.l	(a0)+,8(a4)
	move	(a0)+,12(a4)
	move.l	(a0)+,16(a4)
	move	(a0)+,20(a4)
	
	lea	16(a4),a4
	add	#32,d6
	
	dbra	d7,zlotib
	lea	160+32(a1),a1
	add	#18,ligne_s
	
	dbra	d0,big_affich
	
	lea	screen+160*100+16,a0
	lea	screen+160*150,a1
	moveq	#font_heigh,d0
bozod	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a1)
	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,48(a1)
	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,96(a1)
	movem.l	(a0)+,d1-d4
	movem.l	d1-d4,96+48(a1)
	lea	160(a1),a1
	lea	32(a0),a0
	dbra	d0,bozod
	
	rts
	
shiftit	lea	fonts_ad,a0
	lea	shift_buf,a1
	lea	shift_font,a2
	moveq	#1,d0	* Nbre de lettres
big_bucle	
* Copie de la lettre dans son buffer de shift	
	move.l	(a0)+,a3
	lea	(a1),a4
	moveq	#font_heigh,d1	* Hauteur
copy_shi	*movem.l	(a3),d2-d4	* On copie une ligne entiere de la
	*movem.l	d2-d4,(a4)+	* lettre
	move.l	(a3),(a4)+
	move	4(a3),(a4)+
	move.l	8(a3),(a4)+
	move	12(a3),(a4)+
	clr.l	(a4)+
	clr	(a4)+
	
	lea	160(a3),a3
	dbra	d1,copy_shi
* Shifting de la lettre
	moveq	#15,d1	* Nbre de shifts
bucle_shi	
* Sauvegarde de la lettre apres chaque shifte
	lea	(a1),a3
	moveq	#font_heigh,d2
copy_back	movem.l	(a3)+,d3-d6
	movem.l	d3-d6,(a2)
	lea	16(a2),a2
	move	(a3)+,(a2)+
	dbra	d2,copy_back

* Shiftage de la lettre
	lea	(a1),a3
	moveq	#font_heigh,d2	* Hauteur	
shift	roxr	(a3)
	roxr	6(a3)
	roxr	12(a3)
	
	roxr	2(a3)
	roxr	8(a3)
	roxr	14(a3)
	
	roxr	4(a3)
	roxr	10(a3)
	roxr	16(a3)
	
	lea	18(a3),a3
	dbra	d2,shift
	
	dbra	d1,bucle_shi
	dbra	d0,big_bucle
	rts


	data
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0
scroll_txt	dc.b	0,1,0,1,0,1,0,1,0,1,0,1

dist	DC.W	0
	*DC.W	$FFFF
gizi	set	0
	rept	40
	dc.w	gizi
gizi	set	gizi+1
	endr
	rept	40
	dc.w	gizi
gizi	set	gizi-1
	endr
	dc.w	$ffff

font_corres	dc.l	shift_font
	dc.l	shift_font+16*6*3*(font_heigh+1)

ad_font	
gizi	set	0
	rept	16
	dc.w	gizi*6*3*(font_heigh+1)
gizi	set	gizi+1
	endr
	
fonts_ad	dc.l	pic_dat
	dc.l	pic_dat+16
	
pici	incbin	"tristar.pi1"
pic_pal	equ	pici+2
pic_dat	equ	pici+34

	bss
ligne_s	ds.w	1
pos_txt	ds.l	1
last_dist	ds.l	1
shift_buf	ds.b	6*3*(font_heigh+1)
shift_font	ds.b	6*3*(font_heigh+1)*16*40	