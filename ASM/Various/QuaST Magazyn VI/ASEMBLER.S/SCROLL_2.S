*************************************
*To jest chyba najszybsza procedurka*
*przesowajaca fontki co 1 pixel bez *
*uzywania jakichkolwiek przeliczen! *
*Jesli zakodujesz to samo tylko, ze *
*szybciej to napisz do mnie. A tak  *
*pozatem to wiele ludzi na scenie   *
*uwazajacych sie za koderow??? moze *
*sie stad wiele nauczyc!            *
*                              VAT! *
*************************************
wysokosc equ	8		*wysokosc literek skrola
	bsr	Res		*przygotowanie.

Loop	
	bsr	Scroll		*przesun na ekranie.
	bsr	Vbl		*synchronizuj.
	bra	Loop		*skocz na poczatek petli.

Koniec
	move.b	#8,$fffffc02.w	*wlacz mysz.
	move.w	#$555,-$7da2.w	*kolor tla.
	clr.l	-(a7)
	trap	#1		*zakoncz program.


Vbl:
	move.l	$466.w,d0	*licznik ramki.
.Vbl	cmp.l	$466.w,d0	*czekaj do nastepnego VBL.
	beq.s	.Vbl
	cmpi.b	#57,$fffffc02.w	*czy nacisnieto spacje?
	beq.s	Koniec		*jesli tak? to zakoncz.
	rts			*powrot z podprogramu


Scroll
	lea	LitBuf(pc),a2	*adres bufora ostatniej literki.
	lea	Shift(pc),a4	*adres dla wartosci przesuniecia.
	cmp.w	#-1,(a4)	*czy pobrac nowa literke?
	bne.s	Roluj		*gdy nie? to przeskocz inicjalizacje.
	moveq	#0,d0		*czysc rejestr D0.
	lea	Tekst(pc),a0	*adres poczatku tekstu.
	lea	WitchL(pc),a1	*ktora literka wchodzi na ekran.
	move.w	#7,(a4)		*wartosc nowego przesuniecia.
	move.w	(a1),d0		*pobierz: gdzie jest nastepna literka.
	move.b	(a0,d0.w),d0	*wez kod tej literki z pola "Tekst".
	cmp.b	#0,d0		*czy to nie aby ostatnia literka skrola?
	bne.s	NotLast		*gdy jeszcze nie? to przeskocz inicjalizacje.
	move.b	(a0),d0		*pobierz kod pierwszej literki z pola "Tekst".
	clr.w	(a1)		*czysc licznik literek.
NotLast	addq.w	#1,(a1)		*dodaj #1 aby skroll trwal dalej-
				*(sprobuj wykasowac te instrukcje?!).
	lea	Font(pc),a1	*adres naszych fontkow.
	sub.w	#32,d0		*odejmij 32 od kodu fontu.
	lsl.w	#3,d0		*pomnoz przez 8 bo literka ma 8 bajtow 
				*(aby latwiej bylo ja znalesc w pamieci).
	move.l	(a1,d0.w),d1	*pobierz pierwsze 4 bajty (4*8 bitow) literki.
	move.l	4(a1,d0.w),d2	*pobierz drugie 4 bajty (4*8 bitow) literki.
	movem.l	d1-d2,(a2)	*zapamietana literke wloz do bufora ("LitBuf").
Roluj
	lea	$78000,a3	*adres poczatku ekranu.
	moveq	#0,d0		*wyczysc rejestr D0.
	moveq	#0,d1		*wyczysc rejestr D1.
	move.w	(a4),d1		*pobierz wartosc przesuniecia.
	moveq	#wysokosc-1,d7
Powtorz	roxl	152(a3)		*przesow na ekranie
	roxl	144(a3)
	roxl	136(a3)
	roxl	128(a3)
	roxl	120(a3)
	roxl	112(a3)
	roxl	104(a3)
	roxl	096(a3)
	roxl	088(a3)
	roxl	080(a3)
	roxl	072(a3)
	roxl	064(a3)
	roxl	056(a3)
	roxl	048(a3)
	roxl	040(a3)
	roxl	032(a3)
	roxl	024(a3)
	roxl	016(a3)
	roxl	008(a3)
	roxl	000(a3)
	move.b	(a2)+,d0	*pobierz kolejny bajt (8 bitow) literki.
	lsr.w	d1,d0		*przesun bajt o to co na ekranie.
	and.w	#1,d0		*wyczysc ewentualne smieci.
	bclr	#0,153(a3)	*czysc pozycje aby wstawic nowa literke.
	or.w	d0,152(a3)	*wstaw nowy kawalek literki.
	lea	160(a3),a3	*dodaj 320 pix (jestesmy o linie na ekranie nizej).
	dbf	d7,Powtorz	*powtorz tyle razy: jaka jest wysokosc do skrolowania.
	subq.w	#1,(a4)		*odejmij 1 od wartosci przesuniecia.
	rts			*powrot z podprogramu.


Res	
	clr.l	-(a7)		*nowy (supervisor) stos.
	move.w	#32,-(a7)	*funkscja 32 GEMDOSu.
	trap	#1		*wlacz tryb SUPERVISOR
	addq.l	#6,a7		*koryguj stos.
	clr.w	-(a7)		*niska rozdzielczosc.
	pea	$78000		*adres ekranu.
	pea	$78000		*adres ekranu.
	move.w	#5,-(a7)	*funkcja 5 XBIOSu.
	trap	#14		*ustaw parametry ekranu.
	lea	12(a7),a7	*koryguj stos.
	move.b	#18,$fffffc02.w	*wylacz mysz.
	move.w	#$777,$ffff8240.w	*kolor literek skrola.
	move.w  #$000,$ffff8246.w
	rts			*powrot z podprogramu.

WitchL	ds.w	1	*ktora literka bedzie nastepna.
Shift	dc.w	-1	*wartosc przesuniecia fontu na ekranie.
LitBuf	ds.b	8	*bufor literki wjezdzajacej na ekran.
Font	incbin	\asembler.s\dane.dat\vat-font.dat
Tekst	dc.b	'MA*Y SKROLIK NA ROXLACH BAJ VAT OF KORS!!!             ',0
	even		*zakoncz "Tekst" parzystym adresem.
