MENU	equ	0	* Glowne menu
INFO	equ	1	* Informacja o programie
QUIT	equ	2	* Wyjscie z programu
ZLATGA	equ	3	* Nie znana targa
POSTEPY	equ	4	* Postepy w pracy
METODY	equ	5	* Metody filtrowania
BRAKP	equ	6	* Nie wybrano pliku
OVERW	equ	7	* Plik istnieje, nadpisac?
NOMEM	equ	8	* Brak pamieci!

	jsr	clrregs
	bra	start

	include	macro.s
	include	gemmacro.i
	include	aeslib.s

	section text

start	super_on	stack
	move.l	a7,a5
	move.l	#newstack,a7
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp

* inicjacja AES
	appl_init
	
* Zaladownie drzewa
	rsrc_load	#rsc

	jsr	init
* inicjacja MENU
menuinit	rsrc_gaddr	#0,#MENU
	menu_ienable	addr_out,#$11,#1
	menu_ienable	addr_out,#$13,#1
	move.b	sve_en,d0
	tst.b	d0
	bne	nie_sve
	menu_ienable	addr_out,#$11,#0
nie_sve	move.b	flt_en,d0
	tst.b	d0
	bne	nie_flt
	menu_ienable	addr_out,#$13,#0
	
nie_flt	menu_bar	addr_out,#1
menu	evnt_multi	#17,#-1,#-1,#-1,#-1,#-1,#-1,#-1,#-1,#-1,#-1,#-1,#-1,#-1,#raport
	jsr	rap_out
*******************************************************************************
* Klawiatura
* Mysz
* Info?
	cmp.w	#$1700,d0
	beq	info
	cmp.w	#$0007,d0
	beq	info
* Load?
	cmp.w	#$2600,d0
	beq	load
	cmp.w	#$0010,d0
	beq	load
* Save?
	cmp.w	#$1f00,d0
	beq	save
	cmp.w	#$0011,d0
	beq	save
* Filter?
	cmp.w	#$2100,d0
	beq	filter
	cmp.w	#$0013,d0
	beq	filter
* Method?
	cmp.w	#$3200,d0
	beq	method
	cmp.w	#$0014,d0
	beq	method
* Quit?
	cmp.w	#$1000,d0
	beq	wyjscie
	cmp.w	#$0016,d0
	beq	wyjscie
	jmp	menu
	nop
koniec	quit
*******************************************************************************
info	moveq	#3,d6
	clr.w	d7
	jsr	menu_en
	rsrc_gaddr	#0,#INFO
	jsr	draw_window
	objc_change	addr_out,#1,#0,#0,#0,#0,#0,#0
	moveq	#3,d6
	moveq	#1,d7
	jsr	menu_en
	bra	menuinit
*******************************************************************************
load	clr.b	flt_en
	clr.b	sve_en
	moveq	#4,d6
	clr.w	d7
	jsr	menu_en
	lea	pathin,a0
	lea	path,a1
load0	move.b	(a0)+,(a1)+
	bne	load0
	lea	file,a0
	lea	filin,a1
load00	move.b	(a1)+,(a0)+
	bne	load00
	fsel_exinput	#path,#file,#comment
	tst.w	int_out+2
	bne	load1
	bra	load4
load1	lea	file,a0
	tst.b	(a0)
	beq	niemapliku
	lea	path,a1
	lea	pathin,a2
	lea	filin,a3
load2	move.b	(a1)+,(a2)+
	bne	load2
load2a	cmp.b	#"\",-(a1)
	bne	load2a
	add.l	#1,a1
load3	move.b	(a0),(a1)+
	move.b	(a0)+,(a3)+
	bne	load3
	jsr	czytaj
	graf_mouse	#0
load4	moveq	#4,d6
	moveq	#1,d7
	jsr	menu_en
	bra	menuinit
niemapliku
	rsrc_gaddr	#0,#BRAKP
	jsr	draw_window
	objc_change	addr_out,#1,#0,#0,#0,#0,#0,#0
	bra	load4
*******************************************************************************
save	cmp.b	#1,sve_en
	bne	save9
	moveq	#4,d6
	clr.w	d7
	jsr	menu_en
	cmp.b	#1,savenr
	bne	save8
	lea	pathout,a0
	lea	path,a1
saved1	move.b	(a0)+,(a1)+
	bne	saved1
saved2	lea	filin,a0
	lea	file,a1
saved3	move.b	(a0)+,(a1)+
	bne	saved3
	bra	saved0
save8	lea	pathin,a0
	lea	path,a1
save80	move.b	(a0)+,(a1)+
	bne	save80
saved0	fsel_exinput	#path,#file,#comment2
	tst.w	int_out+2
	beq	save9
	lea	path,a0
	lea	pathout,a1
save81	move.b	(a0)+,(a1)+
	bne	save81
save82	cmp.b	#"*",-(a0)
	bne	save82
	lea	file,a1
save83	move.b	(a1)+,(a0)+
	bne	save83
	open	#path,lacz
	tst.l	d0
	bmi	niema
	rsrc_gaddr	#0,#OVERW
	jsr	draw_window
	objc_change	addr_out,#1,#0,#0,#0,#0,#0,#0
	objc_change	addr_out,#2,#0,#0,#0,#0,#0,#0
	move.w	reply,d0
	cmp.w	#1,d0
	beq	save8
niema	graf_mouse	#2
	jsr	zapisz
	graf_mouse	#0
save9	moveq	#4,d6
	moveq	#1,d7
	jsr	menu_en
	bra	menuinit
*******************************************************************************
filter	cmp.b	#1,flt_en
	bne	filter9
	clr.b	flt_en
	moveq	#4,d6
	clr.w	d7
	jsr	menu_en
	rsrc_gaddr	#1,#51
	move.l	addr_out,a6
	add.w	#20,a6
	clr.w	(a6)
	rsrc_gaddr	#0,#POSTEPY
	form_center	addr_out
	move.w	int_out+2,x
	move.w	int_out+4,y
	move.w	int_out+6,w
	move.w	int_out+8,h
	form_dial	#0,#0,#0,#0,#0,x,y,w,h
	form_dial	#1,#0,#0,#0,#0,x,y,w,h
	objc_draw	addr_out,#0,#2,x,y,w,h

	move.b	#1,sve_en
	graf_mouse	#2
	jsr	do_filter
	graf_mouse	#0
	form_dial	#2,#0,#0,#0,#0,x,y,w,h
	form_dial	#3,#0,#0,#0,#0,x,y,w,h
	moveq	#4,d6
	moveq	#1,d7
	jsr	menu_en
filter9	bra	menuinit
	
*******************************************************************************
method	moveq	#4,d6
	clr.w	d7
	jsr	menu_en
	rsrc_gaddr	#0,#METODY
	jsr	draw_window
	objc_change	addr_out,#1,#0,#0,#0,#0,#0,#0
	jsr	test_buttons
	moveq	#4,d6
	moveq	#1,d7
	jsr	menu_en
	bra	menuinit
test_buttons
	move.w	#57,d0	* 1 (od gory) przycisk (bez sprawdzania)
	jsr	test_b1
	bne	sel1
	bra	sel2	* WYBRANY 2
*	move.w	#58,d0	* 2 przycisk
*	jsr	test_b1
*	bne	sel2
*	move.w	#59,d0	* 3 przycisk
*	jsr	test_b1
*	bne	sel3
*	bra	sel4
test_b1	rsrc_gaddr	#1,d0
	move.l	addr_out,a0
	move.b	$b(a0),d0
	and.b	#1,d0
	rts	
sel1	move.b	#1,nr_met
	rts
sel2	move.b	#2,nr_met
	rts
sel3	move.b	#3,nr_met
	rts
sel4	move.b	#4,nr_met
	rts
*******************************************************************************
wyjscie	moveq	#4,d6
	clr.w	d7
	jsr	menu_en
	rsrc_gaddr	#0,#QUIT
	jsr	draw_window
	objc_change	addr_out,#1,#0,#0,#0,#0,#0,#0
	objc_change	addr_out,#2,#0,#0,#0,#0,#0,#0
	moveq	#4,d6
	moveq	#1,d7
	jsr	menu_en
	move.w	reply,d0
	cmp.w	#1,d0
	beq	koniec
	bra	menuinit
*******************************************************************************
rap_out	move.w	int_out,d0
	btst	#0,d0
	beq	mouse
	btst	#4,d0
	beq	keyboard
	rts
mouse	move.w	raport+8,d0
	rts
keyboard	cmp.w	#$0008,int_out+8
	bne	keyboard1
	move.w	int_out+10,d0
keyboard1	rts
* Wyszukiwanie i wyswietlanie objektu
*******************************************************************************
draw_window
*******************************************************************************
	form_center	addr_out
	move.w	int_out+2,x
	move.w	int_out+4,y
	move.w	int_out+6,w
	move.w	int_out+8,h
	form_dial	#0,#0,#0,#0,#0,x,y,w,h
	form_dial	#1,#0,#0,#0,#0,x,y,w,h
	objc_draw	addr_out,#0,#2,x,y,w,h
	form_do	addr_out,#0
	move.w	int_out,reply
	form_dial	#2,#0,#0,#0,#0,x,y,w,h
	form_dial	#3,#0,#0,#0,#0,x,y,w,h
	rts
*******************************************************************************
menu_en
*******************************************************************************
	rsrc_gaddr	#0,#MENU
	menu_tnormal	addr_out,d6,d7
	rts
*******************************************************************************
czytaj
*******************************************************************************
	open	#path,lacz
	move.l	tgadat,a6
	read	a6,#16,lacz
	cmp.l	#$00000200,(a6)
	bne	nietarga

memory	clr.l	d6
	clr.l	d7
	move.b	$d(a6),d7
	rol.w	#8,d7
	move.b	$c(a6),d7
	move.w	d7,d6
	add.l	d7,d7
	add.l	d6,d7
	move.b	$f(a6),d6
	rol.w	#8,d6
	move.b	$e(a6),d6
	mulu	d6,d7
	add.l	#16,d7
xxx	move.l	d7,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq	#6,sp
	tst.l	d0
	bpl	czytaj1
no_mem	rsrc_gaddr	#0,#NOMEM
	jsr	draw_window
	objc_change	addr_out,#1,#0,#0,#0,#0,#0,#0
	rts

czytaj1	move.l	d0,tgadat
	move.l	d0,a5
	move.l	(a6)+,(a5)+
	move.l	(a6)+,(a5)+
	move.l	(a6)+,(a5)+
	move.l	(a6)+,(a5)+
	graf_mouse	#2
	read	a5,#-1,lacz
	add.l	#16,d0
	move.l	d0,lenght
	move.b	#1,flt_en
	close	lacz
	rts
nietarga	rsrc_gaddr	#0,#ZLATGA
	jsr	draw_window
	objc_change	addr_out,#1,#0,#0,#0,#0,#0,#0
	clr.b	file
	clr.b	path
	rts

	
*******************************************************************************
zapisz
*******************************************************************************
	create	#0,#path,lacz
	move.l	tgadat,a6
	move.l	lenght,d0
	write	a6,d0,lacz
	close	lacz
	move.b	#1,savenr
	move.l	tgadat,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq	#6,sp
	rts
*******************************************************************************
do_filter
*******************************************************************************
	jsr	flush_kbd
	move.l	tgadat,a0	* okreslenie rozmiarow obrazka
	add.l	#12,a0
	move.b	(a0)+,d0
	ror.l	#8,d0
	move.b	(a0)+,d0
	rol.l	#8,d0
	subq	#1,d0
	move.w	d0,szer
	move.b	(a0)+,d0
	ror.l	#8,d0
	move.b	(a0)+,d0
	rol.l	#8,d0
	subq	#1,d0
	move.w	d0,wys

	move.w	szer,d0
	addq	#1,d0
	mulu.w	#3,d0
	move.l	d0,wt
	clr.l	d0
	clr.l	d1
	move.w	wys,d0
	addq	#1,d0
	move.l	#240,d1
	swap	d1
	divu.l	d0,d1
	clr.l	counter
	clr.w	ht		* wyczyszczenie licznika pixeli dla baru
	move.l	d1,count_n	* liczba okreslajaca co ile zwieksza sie licznik
				* dla paska na ekranie
	move.l	tgadat,a0
	add.l	#$12,a0

	move.w	wys,d7
petla0	move.w	szer,d6

petla	cmp.w	szer,d6
	beq	poczl
	cmp.w	#0,d6
	beq	konl
	cmp.w	wys,d7
	beq	plinia
	cmp.w	#0,d7
	beq	olinia

	move.l	a0,a1	* wariant 5
	clr.w	d0
	clr.l	d1
	sub.l	wt,a1
	move.b	-3(a1),d1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	divu.w	#9,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	sub.l	wt,a1
	move.b	-3(a1),d1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	divu.w	#9,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	sub.l	wt,a1
	move.b	-3(a1),d1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	divu.w	#9,d1
	jsr	srednia
	move.b	d1,(a0)+

p9	dbf	d6,petla
* TRZEBA DOROBIC KLAWISZ ESC
	cmp.b	#1+128,$fffffc02.w
	beq	przerwij
	
	move.l	a0,savereg
	move.l	a1,savereg+4
	move.l	counter,d0
	move.l	d0,d1
	move.l	count_n,d2
	add.l	d2,d1
	move.l	d1,counter
	clr.w	d1
	clr.w	d0
	cmp.l	d0,d1
	beq	nie_zwiekszaj
	add.w	#1,ht
	move.w	ht,(a6)
	objc_draw	addr_out,#4,#2,x,y,w,h
	move.l	savereg+4,a1
	move.l	savereg,a0
nie_zwiekszaj
	dbf	d7,petla0
	rts
przerwij
	clr.b	sve_en
	clr.b	flt_en
	rts

poczl	cmp.w	wys,d7
	beq	pix00
	cmp.w	#0,d7
	beq	pix10

	move.l	a0,a1	* wariant 4
	clr.w	d0
	clr.l	d1
	move.b	(a1),d1
	move.b	3(a1),d0
	add.w	d0,d1
	sub.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	add.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	divu	#6,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	move.b	(a1),d1
	move.b	3(a1),d0
	add.w	d0,d1
	sub.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	add.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	divu	#6,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	move.b	(a1),d1
	move.b	3(a1),d0
	add.w	d0,d1
	sub.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	add.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	divu	#6,d1
	jsr	srednia
	move.b	d1,(a0)+
	bra	p9

konl	cmp.w	wys,d7
	beq	pix01
	cmp.w	#0,d7
	beq	pix11

	move.l	a0,a1	* wariant 6
	clr.w	d0
	clr.l	d1
	sub.l	wt,a1
	move.b	-3(a1),d1
	move.b	(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	divu.w	#6,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	sub.l	wt,a1
	move.b	-3(a1),d1
	move.b	(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	divu.w	#6,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	sub.l	wt,a1
	move.b	-3(a1),d1
	move.b	(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	divu.w	#6,d1
	jsr	srednia
	move.b	d1,(a0)+
	bra	p9

plinia	move.l	a0,a1	* wariant 2
	clr.w	d0
	clr.l	d1
	move.b	(a1),d1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	sub.l	#3,a1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	move.b	6(a1),d0
	add.w	d0,d1
	divu	#6,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	move.b	(a1),d1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	sub.l	#3,a1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	move.b	6(a1),d0
	add.w	d0,d1
	divu	#6,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	move.b	(a1),d1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	sub.l	#3,a1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	move.b	6(a1),d0
	add.w	d0,d1
	divu	#6,d1
	jsr	srednia
	move.b	d1,(a0)+
	bra	p9


olinia	move.l	a0,a1	* wariant 8
	clr.w	d0
	clr.l	d1
	move.b	-3(a1),d1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	sub.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	divu.w	#6,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	move.b	-3(a1),d1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	sub.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	divu.w	#6,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	move.b	-3(a1),d1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	sub.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	divu.w	#6,d1
	jsr	srednia
	move.b	d1,(a0)+
	bra	p9
pix00	move.l	a0,a1	* wariant 1
	clr.w	d0
	clr.l	d1
	move.b	(a1),d1
	move.b	3(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	lsr.w	#2,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	move.b	(a1),d1
	move.b	3(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	lsr.w	#2,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	move.b	(a1),d1
	move.b	3(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	lsr.w	#2,d1
	jsr	srednia
	move.b	d1,(a0)+
	bra	p9
pix01	move.l	a0,a1	* wariant 3
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	move.b	(a1),d1
	move.b	-3(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	sub.l	#3,a1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	lsr.w	#2,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	move.b	(a1),d1
	move.b	-3(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	sub.l	#3,a1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	lsr.w	#2,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	move.b	(a1),d1
	move.b	-3(a1),d0
	add.w	d0,d1
	add.l	wt,a1
	sub.l	#3,a1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	lsr.w	#2,d1
	jsr	srednia
	move.b	d1,(a0)+
	bra	p9



pix10	move.l	a0,a1	* wariant 7
	clr.w	d0
	clr.l	d1
	move.b	(a1),d1
	move.b	3(a1),d0
	add.w	d0,d1
	sub.l	wt,a1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	lsr.w	#2,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	move.b	(a1),d1
	move.b	3(a1),d0
	add.w	d0,d1
	sub.l	wt,a1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	lsr.w	#2,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	move.b	(a1),d1
	move.b	3(a1),d0
	add.w	d0,d1
	sub.l	wt,a1
	move.b	(a1),d0
	add.w	d0,d1
	move.b	3(a1),d0
	add.w	d0,d1
	lsr.w	#2,d1
	jsr	srednia
	move.b	d1,(a0)+
	bra	p9

pix11	move.l	a0,a1	* wariant 9
	clr.w	d0
	clr.l	d1
	move.b	-3(a1),d1
	move.b	(a1),d0
	add.w	d0,d1
	sub.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	lsr.w	#2,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	move.b	-3(a1),d1
	move.b	(a1),d0
	add.w	d0,d1
	sub.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	lsr.w	#2,d1
	jsr	srednia
	move.b	d1,(a0)+
	move.l	a0,a1
	clr.w	d0
	clr.l	d1
	move.b	-3(a1),d1
	move.b	(a1),d0
	add.w	d0,d1
	sub.l	wt,a1
	move.b	-3(a1),d0
	add.w	d0,d1
	move.b	(a1),d0
	add.w	d0,d1
	lsr.w	#2,d1
	jsr	srednia
	move.b	d1,(a0)+
	bra	p9


srednia	cmp.b	#1,nr_met
	beq	nies0
	move.l	a0,a1
	move.b	(a0),d2
	sub.l	wt,a1
	move.b	(a1),d0
	cmp.b	d0,d2
	beq	nies
	add.l	wt,a1
	move.b	-3(a1),d0
	cmp.b	d0,d2
	beq	nies
	move.b	3(a1),d0
	cmp.b	d0,d2
	beq	nies
	add.l	wt,a1
	move.b	(a1),d0
	cmp.b	d0,d2
	beq	nies
nies0	rts
nies	move.b	(a0),d1
	rts

clrregs	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	move.l	d0,a0
	move.l	d1,a1
	move.l	d2,a2
	move.l	d3,a3
	move.l	d4,a4
	move.l	d5,a5
	move.l	d6,a6
	rts
*******************************************************************************
szer	dc.w	0
wys	dc.w	0
wt	dc.l	0
ht	dc.l	0
*******************************************************************************
init	move.w	#$19,-(sp)
	trap	#1
	addq	#2,sp
	add.b	#$41,d0
	lea	pathin,a6
	move.b	d0,(a6)+
	move.b	#":",(a6)+
	move.w	#0,-(sp)
	move.l	a6,-(sp)
	move.w	#$47,-(sp)
	trap	#1
	addq	#8,sp
	lea	ext,a0
	lea	pathin,a1
init0	tst.b	(a1)+
	bne	init0
	sub.l	#1,a1
init1	move.b	(a0)+,(a1)+
	bne	init1
	lea	freemem,a0
	add.l	#$20000,a0
	move.l	a0,tgadat
	graf_mouse	#0
	rts
****************************************************************************
flush_kbd
****************************************************************************
	btst.b  #0,$fffffc00.w
	bne.s   flush1
	rts
flush1	move.b  $fffffc02.w,d7
	bra.s   flush_kbd
****************************************************************************
	SECTION DATA
rsc	dc.b	"d:\asm\filter\filter.rsc",0
x	dc.w	0
y	dc.w	0
w	dc.w	0
h	dc.w	0
raport	ds.b	16
reply	dc.w	0
sve_en	dc.b	0
flt_en	dc.b	0
nr_met	dc.b	0
lacz	dc.w	0
ext	dc.b	"\*.TGA",0
path	ds.b	128
pathin	ds.b	128
pathout	ds.b	128
lenght	dc.l	0
filin	ds.b	13
filout	ds.b	13
file	ds.b	13
savenr	dc.b	0
comment	dc.b	"Choose TGA file to LOAD.",0
comment2	dc.b	"Choose TGA file to SAVE.",0
stack	dc.l	0
	ds.l	100
newstack	ds.l	1
	ds.l	100
tgadat	dc.l	0
counter	dc.l	0
count_n	dc.l	0
savereg	ds.b	8
freemem	dc.b	0