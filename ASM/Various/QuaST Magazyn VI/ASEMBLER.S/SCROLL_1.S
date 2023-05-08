*************************************
* To jest procedurka do skrolowania *
* 4-planowej (16 kolorow) grafiki co*
* 8 pixeli. Ta procedurka nie jest  *
* najszybsza, ale chyba najlepsza   *
* napisana uzywajac zwyklej techniki*
* skrolowania.                      *
*                              VAT! *
*************************************
	dc.w	$a00a		*wylacz wskaznik myszy.
	clr.w	-(a7)		*niska rozdzielczosc.
	pea	$78000		*adres ekranu.
	pea	$78000		*adres ekranu.
	move.w	#5,-(a7)	*funkcja 5 XBIOSu.
	trap	#14		*ustaw parametry ekranu.
	adda.l	#12,a7		*skoryguj stos.
	pea	(fonts+2)(pc)	*adres palety kolorow.
	move.w	#6,-(a7)	*funkcja 6 XBIOSu.
	trap	#14		*ustaw nowa palete.
	addq.l	#6,a7		*skoryguj stos.
	clr.l	-(a7)		*nowy (supervisor) stos.
	move.w	#32,-(a7)	*funkcja 32 GEMDOSu.
	trap	#1		*ustaw tryb supervisor.
	addq.l	#6,a7		*skoryguj stos.
loop
	bsr	skroll		*skocz do podprogramu (przesun grafike).
	bsr	vbl		*skocz do podprogramu (synchronizacja pionowa).
	bra.s	loop		*rozpocznij petle od nowa.

vbl	move.w	#$25,-(a7)	*funkcja 37 XBIOSu.
	trap	#14		*czekaj na nastepne VBL.
	addq.l	#2,a7		*skoryguj stos.
	cmpi.b	#57,$fffffc02.w	*czy nacisnieto spacje?
	beq.s	Koniec		*jesli tak? to zakoncz.
	rts			*powrot z podprogramu
Koniec	clr.l	-(a7)
	trap	#1		*zakoncz wykonywanie programu.

skroll	tst.w	control		*czy juz nowa literka wchodzi na ekran?
	bne.s	przesun		*jesli nie? to przeskocz inicjalizace.
	clr.w	kupa		*wyczysc wskaznik 
	move.w	lit,d0		*licznik wartosci kolejnej literki.
	lea	text(pc),a1	*adres poczatku tekstu.
	move.b	(a1,d0.w),d0	*pobierz kod nowej literki do wrzucenia
				*na ekran.
	tst.b	d0		*czy juz koniec tekstu?
	bne.s	jeszcze		*jesli nie? to przeskocz inicjalizace.
	move.b	(a1),d0		*pobierz pierwsza literke z tekstu.
	clr.w	lit		*wyczysc licznik literek (bo zaczynamy od
				*poczatku).
jeszcze	
	sub.w	#32,d0		*odejmij 32 od kodu literki aby latwiej
				*zliczyc adres literki wchodzacej na ekran.
	and.l	#$3f,d0		*wyczysc ewentualne smieci.
	addq.w	#1,lit		*dodaj 1 do licznika aby ustawic go na
				*nastepnej literce.
	lsl.w	#2,d0		*pomnoz przez 4 aby pobrac przesuniecie z
				*tabeli adresow fontow.
	lea	letter(pc),a1	*adres tabeli adresow fontow.
	adda.l	d0,a1		*dodaj znalezione przesuniecie do adresu tabeli.
	move.l	(a1),a1		*wez przesuniecie z tablicy poczatku grafiki.
	adda.l	#(fonts+34),a1	*dodaj adres fontow.
	move.l	a1,adr		*zapamietaj obliczony adres.
	move.w	#32,control	*dlugosc liter (32 pixele).
przesun	
	move.l	#$7e900,a0	*adres poczatku wyswietlania na ekranie.
	move.l	adr,a1		*pobierz zapamietany adres.
	addq.l	#1,adr		*dodaj 1 do adresu.
	moveq	#31,d7		*wysokosc liter (32 pixele).
go_and_do_it_again
	movep.l	001(a0),d0	*przesuwanie grafiki na ekranie.
	movep.l	d0,000(a0)
	movep.l	008(a0),d0
	movep.l	d0,001(a0)
	movep.l	009(a0),d0
	movep.l	d0,008(a0)
	movep.l	016(a0),d0
	movep.l	d0,009(a0)
	movep.l	017(a0),d0
	movep.l	d0,016(a0)
	movep.l	024(a0),d0
	movep.l	d0,017(a0)
	movep.l	025(a0),d0
	movep.l	d0,024(a0)
	movep.l	032(a0),d0
	movep.l	d0,025(a0)
	movep.l	033(a0),d0
	movep.l	d0,032(a0)
	movep.l	040(a0),d0
	movep.l	d0,033(a0)
	movep.l	041(a0),d0
	movep.l	d0,040(a0)
	movep.l	048(a0),d0
	movep.l	d0,041(a0)
	movep.l	049(a0),d0
	movep.l	d0,048(a0)
	movep.l	056(a0),d0
	movep.l	d0,049(a0)
	movep.l	057(a0),d0
	movep.l	d0,056(a0)
	movep.l	064(a0),d0
	movep.l	d0,057(a0)
	movep.l	065(a0),d0
	movep.l	d0,064(a0)
	movep.l	072(a0),d0
	movep.l	d0,065(a0)
	movep.l	073(a0),d0
	movep.l	d0,072(a0)
	movep.l	080(a0),d0
	movep.l	d0,073(a0)
	movep.l	081(a0),d0
	movep.l	d0,080(a0)
	movep.l	088(a0),d0
	movep.l	d0,081(a0)
	movep.l	089(a0),d0
	movep.l	d0,088(a0)
	movep.l	096(a0),d0
	movep.l	d0,089(a0)
	movep.l	097(a0),d0
	movep.l	d0,096(a0)
	movep.l	104(a0),d0
	movep.l	d0,097(a0)
	movep.l	105(a0),d0
	movep.l	d0,104(a0)
	movep.l	112(a0),d0
	movep.l	d0,105(a0)
	movep.l	113(a0),d0
	movep.l	d0,112(a0)
	movep.l	120(a0),d0
	movep.l	d0,113(a0)
	movep.l	121(a0),d0
	movep.l	d0,120(a0)
	movep.l	128(a0),d0
	movep.l	d0,121(a0)
	movep.l	129(a0),d0
	movep.l	d0,128(a0)
	movep.l	136(a0),d0
	movep.l	d0,129(a0)
	movep.l	137(a0),d0
	movep.l	d0,136(a0)
	movep.l	144(a0),d0
	movep.l	d0,137(a0)
	movep.l	145(a0),d0
	movep.l	d0,144(a0)
	movep.l	152(a0),d0
	movep.l	d0,145(a0)
	movep.l	153(a0),d0
	movep.l	d0,152(a0)
	movep.l	(a1),d0
	movep.l	d0,153(a0)
	adda.l	#160,a0		*dodaj linie (320 pix) do grafiki w pamieci.
	adda.l	#160,a1		*dodaj linie (320 pix) do grafiki na ekranie.
	dbf	d7,go_and_do_it_again
	addq.w	#1,kupa
	cmp.w	#2,kupa
	bne.s	nic_to
	addq.l	#6,adr
nic_to	subq.w	#8,control	*odejmij 8 (wrzucone 8 pix skrola na ekran).
	rts
lit	ds.w	1
adr	dc.l	text
control	ds.w	1
kupa	ds.w	1
text	dc.b	'VAT PRESENTS HIS FIRST FOUR BIT-PLANE SCROLL...    '
	dc.b	'AND NOW LITTLE GFX TEST:  !"#$%&',39,'()*+,-./01234'
	dc.b	'56789:;<=>?',64,'ABCDEFGHIJKLMNOPQRSTUVWXYZ       ',0
	even
letter	dc.l  $0000,$0010,$0020,$0030,$0040,$0050,$0060,$0070,$0080,$0090
	dc.l  $1400,$1410,$1420,$1430,$1440,$1450,$1460,$1470,$1480,$1490
	dc.l  $2800,$2810,$2820,$2830,$2840,$2850,$2860,$2870,$2880,$2890
	dc.l  $3C00,$3C10,$3C20,$3C30,$3C40,$3C50,$3C60,$3C70,$3C80,$3C90
	dc.l  $5000,$5010,$5020,$5030,$5040,$5050,$5060,$5070,$5080,$5090
	dc.l  $6400,$6410,$6420,$6430,$6440,$6450,$6460,$6470,$6480,$6490
	dc.l  $64A0,$64B0,$64C0
fonts	incbin	\asembler.s\dane.dat\4b_fonty.pi1
