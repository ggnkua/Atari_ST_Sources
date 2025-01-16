***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  Blitter - sposob programowania blittera                   *
* autor      :  Wachu                                                     *
* inne uwagi :  320x200 !!! Atari z Blitterem                             *
***************************************************************************

**************************************************************************
* Uwaga! Program wykonuje sie pod GENSTem w wersji 2.0 lub wyzszej! 	 *
* Prosze ustawic tabulacje na 10 miejsc!			         *
**************************************************************************
*   Programowanie BLiTTER'a - program pierwszy, czyli jak zmazac ekran   *
*      i zrobic duszka, ktory poruszajac sie robi negatyw rysunku.       *
*  Procedura dziala na komputerach serii STE, MEGA STE oraz na FALCONie, *
* na monitorze kolorowym, wykorzystuje pierwszy bitplan niskiej rozdziel-*
*  -czosci ST i zajmuje ok. 25% czasu miedzy kolejnymi zobrazowaniami.   *
*                                                                        *
* Uwagi wstepne dotyczace ekranu w niskiej rozdzielczosci ST:            *
* => 200 linii po 320 punktow kazda				         *	
* => 4 plany, czyli 16 kolorow numerowanych 0-15 (bez zadnych sztuczek)  *
* => na jeden plan w linii przypada 20 slow (40 bajtow)                  *
* => czyli na kazda linie przypada 80 slow (160 bajtow)                  *
* Dane dotyczace programu:					         *
* => program uzywa 1 planu, wiec duszek bedzie jednokolorowy             *
* => duszkiem bedzie napisem 'ATARI' o wymiarach 208*70 pikseli  	 *
* => zeby zrobic negatyw rysunku trzeba odpowiednio dobrac kolory wedlug *
*   nastepujacej, prostej reguly: kolor tla (kolor nr 0), kolor negatywu *
*   (nr 1), kolor rysunku (nr 2), kolor negatywu (nr 3), kolor rysunku (4)*
*   kolor negatywu (5) itd., az do ostatniego, 16 koloru (patrz: rysunek *
*   motoru w dowolnym programie graficznym czytajacym rozszerzenie 'PI1')*
* => z takiego ustawienia kolorow wynikaja dwie podstawowe rzeczy:	 *
*   a) rysunek moze miec max. 8 kolorow (wliczajac w to kolor tla)	 *
*   b) negatyw ma rowniez max. 8 kolorow				 *
************************************************************************** 
* Teraz czas na zapoznanie sie z rejestrami naszego kochanego ukladu.
* Opis po polsku i angielsku (przydaje sie w razie czytania angielskiej
* literatury dotyczacej pana B.)
* Uwaga! Wszystkie adresy wymienione ponizej sa adresami starszymi 
* (parzystymi), istnieja jeszcze adresy mlodsze (nieparzyste), ktore nie
* sa uzywane zbyt czesto i mozna sie bez nich obyc
*
* Blitter chip registers (rejestry blittera)
*
* $FF8A00 - blitter chip base addres (poczatek rejestrow blittera)
* $FF8A00 do $FF8A20 (halftone) - 16 half tone RAM registers (16 rejestrow half tone)
* $FF8A20 (srcxinc) - source x increment (odstep miedzy planami rastra zrodlowego)
* $FF8A22 (srcyinc) - source y increment (odstep miedzy liniami rastra zrodlowego)
* $FF8A24 (srcaddr) - source addres (starsze slowo adresu rastra zrodlowego)
* $FF8A28 (endmsk1) - left end mask (maskowanie pierwszego slowa)
* $FF8A2A (endmsk2) - middle mask (maskowanie slow srodkowych)
* $FF8A2C (endmsk3) - right end mask (maskowanie ostatniego slowa)
* $FF8A2E (dstxinc) - destination x increment (odstep miedzy planami rastra docelowego)
* $FF8A30 (dstyinc) - destination y increment (odstep miedzy liniami rastra docelowego)
* $FF8A32 (dstaddr) - destination addres (starsze slowo adresu rastra docelowego)
* $FF8A36 (xcount)  - x count (szerokosc bloku docelowego)
* $FF8A38 (ycount)  - y count (wysokosc bloku docelowego)
* $FF8A3A (hop)     - halfttone operation (operacje half tone)
* $FF8A3B (op)      - logical operation (operacje logiczne)
* $FF8A3C (linenum) - line number/smudge/HOG/busy (bity 0-3 - numer rejestru half tone;
* bit 5 - smudge; bit 6 - HOG; bit 7- busy)
* $FF8A3D (skew)    - source shift (bity 0-3 - przesuniecie; bit 6 - NFSR; bit 7 - FXSR)
* $FF8A3E - prawdopodobnie nieuzywane
* $FF8A3F - prawdopodobnie nieuzywane
*
* Parametry funkcji XBIOS 64 (blitmode)
* (-1)  - odczyt statusu:
*                        gdy bit 0 jest ustawiony - blitter aktywny
*                        gdy bit 1 jest ustawiony - blitter zainstalowany
* ( 0)  - wylaczenie blittera
* ( 1)  - wlaczenie blittera
*
* Wzory obliczen potrzebnych przy programowaniu blittera (dla jednego bitplanu i niskiej rozdzielczosci):
*
* 1.> obliczenie adresu dla rastra zrodlowego i docelowego (scraddr i dstaddr):
*     adr=adr.ekranu + y*dl.lini + 2*int(x/16), gdzie x i y to wspolrzedne
*     odpowiednio kopiowanego bloku i bloku docelowego
* 2.> odstep miedzy slowami (srcxinc i dstxinc):8
* 3.> przesuniecie pomiedzy danymi poszczegolnych lini ekranu srcyinc i dstyinc):
*     odleglosc=dl.lini - (xcount*8-8) 
* 4.> obliczenie xcount: (ilosc pixeli/16)+1 (najlepiej, kiedy blok jest wielokrotnoscia liczby 16, np. 16,32,48..., w innym wypadku trzeba korzystac z masek)
* 5.> okreslenie wysokosci kopiowanego bloku docelowego (ycount):
*     nalezy wpisac wysokosc bloku docelowego w liniach ekranowych
*
*		autor programu i opisu: WACHU (Tomasz Wachowiak)
*
*  Jesli chcialbys sie ze mna skontaktowac pisz pod adres :
*						Tomasz Wachowiak
*						Os. B. Chrobrego 20a/24
*						Poznan 60-681
* lub dzwon!  tel.(061) 223-593
*
****************  POCZATEK PROGRAMU *******************
blitter	equ	$fff8a00
halfton	equ	0	
srcxinc	equ	$20	
srcyinc	equ	$22	
srcaddr	equ	$24	
endmsk1	equ	$28	
endmsk2	equ	$2a	
endmsk3	equ	$2c	
dstxinc	equ	$2e	
dstyinc	equ	$30	
dstaddr	equ	$32	
xcount	equ	$36	
ycount	equ	$38	
hop	equ	$3a	
op	equ	$3b	
linenum	equ	$3c	
skew	equ	$3d	
	
*section	text		;sekcja tekstowa programu
	move.l	4(sp),a0	;sekwencja startowa dla GEM-u		
	move.l	12(a0),d0
	add.l	20(a0),d0
	add.l	28(a0),d0
	add.l	#$1100,d0
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	clr	-(sp)
	move	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	bsr	start
	bsr	czysc
	bsr	load_rys
	bsr	wart_init
loop:		
*	move.w	#$400,$fff8240	;jesli chcesz zobaczyc, ile czasu procesora
				;zajmuje ta procedura skasuj gwiazdki 
				;(kolor czerwony to czas wolny)
	bsr	vsync		;oczekiwanie na koniec kolejnego zobrazowania
*	move.w	#0,$fff8240
	
	bsr	rysuj		;podprogram rysujacy znak ATARI
	cmpi.b	#57,$ffffc02	;czy wcisnieto spacje?
	beq	end		;gdy tak to skocz na koniec
	bra.s	loop		;a jednak NiE! wiec zapetl...



start:
	clr.l 	-(sp)		;wlaczenie trybu 'supervisor' procesora
	move.w 	#32,-(sp)
	trap 	#1
	addq.l 	#6,sp	
	move.l	d0,old_ssp	;zapamietaj stary stos
	move.b 	#$12,$ffffc02	;wylaczenie myszki
	move.b	#10,$484	;bez kliku klawiatury
    	move.b	$fff820a,old_sync ;zapamietaj czestotliwosc wyswietlania obrazu (50 lub 60 Hz)
	movem.l	$fff8240,d0-d7
	movem.l	d0-d7,old_pal	;zachowaj kolory
	move.b	$fff8260,d0
	and.w	#3,d0
	move.w	d0,old_res	;zachowaj rozdzielczosc
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_fiz	;zapamietaj adres ekranu fizycznego
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_log	;zapamietaj adres ekranu logicznego
	move.b	#$07,$fff8201	;ustaw adres wyswietlania ekranu STARSZY
	move.b	#$80,$fff8203	;MLODSZY
	bsr	vsync
	move.b	#2,$fff820a	;ustaw tryb shifter'a na 50 Hz	
	clr.w	$fff8260	;wlacz niska rozdzielczosc
	rts
czysc:
	lea	$68000,a0
	move.w	#1999,d0	;w D0 licznik do petli
	moveq	#0,d1
hlo:
	rept	4		;czyszczenie pamieci (ekranow)
	move.l	d1,(a0)+	;czysc kolejne dwa plany (4 bajty)
	endr
	dbf	d0,hlo		;powtorz 2000 razy (200 lini * 10 (po 16 bajtow))
	rts
load_rys:			;ladowanie rysunkow ATARI (naszego duszka) i motoru, procedura wyswietla rysunek formatu .PI1 (Degas)
	lea	$60000,a0
	lea	$78000,a2
	lea	$70000,a4
	lea	atari+34,a1	;adres poczatku obrazka atari w pamieci
	lea	motor+34,a3	;adres poczatku obrazka motoru w pamieci
	move.l	a3,a5
	move.w	#8000-1,d0	;wartosc dla licznika
loa:
	move.l	(a1)+,(a0)+	;dane spod adresu, gdzie znajduje sie rysunek sa przenoszone pod adres $c0000
	move.l	(a3)+,(a2)+	;tutaj podobnie, zmieniaja sie adresy
	move.l	(a5)+,(a4)+	;----------------||-----------------
	dbf	d0,loa		;powtorz 8000 razy (200 lini po 40 bajtow)
		
	lea	motor+2,a0	;adres palety kolorow dla rysunku motoru
	movem.l	(a0),d0-d7	;pobierz nasza palete
	movem.l	d0-d7,$fff8240	;ustaw nasza palete
	rts
wart_init:
	lea	blitter,a6	;adres blittera do rejestru a6
	lea	$78000,a5	;ekran 1 (fizyczny) do rejestru a5
	lea	$70000,a4	;ekran 2 (logiczny) itd.
	lea	$60000,a3	;rysunek ATARI itd.
	lea	$68000,a2	;adres spod ktorego blitter bedzie pobieral dane do czyszczenia ekranu, oczywiscie do rejestru a2
	lea	wspolrzedne(pc),a1 ;nazwa wskazuje, ze sa to wspolrzedne dla trajektorii duszka
	rts
rysuj:				;nareszcie procedura czyszenia ekranu i poruszania sprite'a
	exg.l	a5,a4		;zamien rejestry (zamiana adresu ekranu 1 i 2)
	move.l	a5,d0		;adres ekranu do rejestru d0
	lsr.l	#8,d0		;podziel przez 256
	move.b	d0,$fff8203	;wartosc do sredniego bajtu pamieci ekranu
	lsr.w	#8,d0
	move.b	d0,$fff8201	;wartosc do starszego bajtu pamieci ekranu
	move.l	a5,a0
				;jak nalezy rozumiec taki dziwny tryb adresowania? Dla przykladu pierwszy rozkaz 'move.w #21,xcount(a6)' oznacza wpisanie wartosci 21 do adresu $ff8a36 (a6-adres blitera + xcount, czyli 36
				; - zobacz poczatek programu). Jeszcze efektywniejsze bylyby rozkazy typu np. 'move.w (a0)+,xcount(a6)', gdzie a0 byloby adresem tablicy, ale zaciemniloby to program.
	move.w	#21,xcount(a6)	;czyscimy 320 punktow (zgodnie ze wzorem 320/16+1=21)
	move.w	#8,srcxinc(a6)	;odstep
	move.w	#0,srcyinc(a6)	;tyle zostaje: 160-(21*8-8)=0
	move.w	#8,dstxinc(a6)	;odstep	
	move.w	#0,dstyinc(a6)	;to samo, co w srcyinc
	move.b	#2,hop(a6)	;wartosc '2' oznacza, ze nie korzystamy z rejestrow 'halftone' (moga one sluzyc do uzyskania wzorow wypelniajacych, ale o tym innym razem)
	move.b	#0,skew(a6)	;bez przesuniecia (po co, kiedy to jest mazanie ekranu)	
	move.b	#3,op(a6)	;operacja logiczna 'kladz blok zrodlowy'	
	move.w	#$ffff,endmsk1(a6) ;bez masek
	move.w	#$ffff,endmsk2(a6)	
	move.w	#$ffff,endmsk3(a6)
	move.l	a2,srcaddr(a6)	;pobierz blok spod adresu okreslonego w rejestrze a2	
	move.l	a5,dstaddr(a6)	;poloz blok pod adresem okreslonym rejestrem a5	
	move.w	#200,ycount(a6)	;kladz 200 linii
	move.b	#192,linenum(a6) ;uruchomienie blittera (tryb pracy HOG - motorola jest zatrzymywana do czasu ukonczenia transmisji danych)
	
				;to bylo czyszenie, a teraz kladzenie duszka
	move.w	(a1)+,d1	;wspolrzedna 'x' z tablicy do rejestru d1	
	cmpi.w	#400,d1		;porownanie
	blt.s 	tutaj		;czy mniejszy od 400, jesli tak, to skocz do procedury 'tutaj'
	lea	wspolrzedne(pc),a1 ;jesli nie, to laduj tablice wspolrzednych do rejestru a1	
	move.w	(a1)+,d1	;pobierz 'x'
tutaj:	move.w	(a1)+,d0	;pobierz 'y' do rejestru d0	
				;nastepne instrukcje to przeliczenie wspolrzednych na adresy
	mulu	#160,d0		;y*160
	adda.w	d0,a0		;dodaj do adresu poczatku ekranu	
	ext.l	d1		;rozszerz rejestr d1 do dlugiego slowa
	divu	#16,d1		;podziel przez 16
	swap	d1		;wymien miedzy soba polowki rejestru d1
	move.w	d1,d0
	swap	d1
	lsl.w	#3,d1		;d1*8	
	add.w	d1,a0		;dodaj do adresu obliczonego wczesniej
				;koniec przeliczania
	move.w	#14,xcount(a6)	;duszek jest szeroki na 208 pikseli xcount=(208/16+1)	
	move.w	#8,srcxinc(a6)	;jak zwykle przy jednym bitplanie wartosc 8		
	move.w	#56,srcyinc(a6)	;160-(14*8-8)		
	move.w	#8,dstxinc(a6)	;to samo, co wyzej
	move.w	#56,dstyinc(a6)	;to samo, co wyzej		
	move.b	#2,hop(a6)	;bez rejestrow 'halftone'	
	move.b	#3,op(a6)	;operacja logiczna 'kladz blok zrodlowy' - sprobuj innych wartosci (0-15)
	move.w	#$ffff,d1	
	lsr.w	d0,d1		;logiczne przesuniecie bitow rejestru d1 o d0 bitow w prawo
	move.w	d1,endmsk1(a6)	;d1 do maski poczatkowej (maskowanie pierwszego slowa) 
	move.w	#$ffff,endmsk2(a6) ;wartosc '$ffff' do maski sredkowej (maskowanie srodkowych slow) 
	not.w	d1		;dopelnienie logiczne
	move.w	d1,endmsk3(a6)	;zmieniona poprzednia instrukcja d1 do maski koncowej (maskowanie koncowego slowa), a wszystko (maski) po to, zeby duszek nie poruszal sie skokowo
	move.b	d0,skew(a6)	;wartosc z d0 dla przesuniecia
	move.l	a3,srcaddr(a6)	;adres duszka
	move.l	a0,dstaddr(a6)	;obliczony adres ekranu
	move.w	#70,ycount(a6)	;wysokosc duszka - 70 pikseli	
	move.b	#192,linenum(a6) ;HEJ, BLiTTER!!! Zrob, co trzeba...
	rts
end:		
	move.b	old_sync,$fff820a ;stara czestotliwosc
	move.w	old_res,-(sp)	;rozdzielczosc
	move.l	old_fiz,-(sp)	;ekran fizyczny
	move.l	old_log,-(sp)	;ekran logiczny
	move	#5,-(sp)
	trap	#14
	adda.l	#12,sp
	movem.l	old_pal,d0-d7	;stare kolory
	movem.l	d0-d7,$ff8240
	move.b 	#8,$ffffc02	;i wlaczenie myszki
	move.b	#7,$484		;a takze dzwieku klawiatury
	move.w	#0,$fff8246
	move.w	#$fff,$fff8240
	move.l	old_ssp,-(sp)	;powrot z 'supervisor' do trybu 'user'
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.w 	-(sp)		;zakonczenie programu
	trap #1

vsync:
	move.l	d0,-(sp)
	move.l	$466,d0
ble:
	cmp.l	$466,d0		;czy nastapilo juz zobrazowanie???
	beq.s	ble		;jesli nie to czekaj (skok do 'ble')
	move.l	(sp)+,d0
	rts
*section	data		;sekcja danych

wspolrzedne
	dc.w	56,133,58,132,61,132,63,132,66,131,68,130,71,129,73,128,76,127,78,125,81,124,83,122,85,120,87,118,89,116,91,113,93,111,94,108,96,106,97,103,99,100,100,97,101,94,102,91,103,88,104,84,104,81,105,78,105,74,105,71
        dc.w	106,68,105,64,105,61,105,57,104,54,104,51,103,47,102,44,101,41,100,38,99,35,97,32,96,29,94,27,93,24,91,22,89,19,87,17,85,15,83,13,81,11,78,10,76,8,73,7,71,6,68,5,66,4,63,3,61,3,58,3
        dc.w	56,3,53,3,50,3,48,3,45,4,43,5,40,6,38,7,35,8,33,10,31,11,28,13,26,15,24,17,22,19,20,22,18,24,17,27,15,29,14,32,12,35,11,38,10,41,9,44,8,47,7,51,7,54,6,57,6,61,6,64
        dc.w	6,68,6,71,6,74,6,78,7,81,7,84,8,88,9,91,10,94,11,97,12,100,14,103,15,106,17,108,18,111,20,113,22,116,24,118,26,120,28,122,31,124,33,125,35,127,38,128,40,129,43,130,45,131,48,132,50,132,53,132
        dc.w	450
atari	incbin	a:asembler.s\dane.dat\atari.pi1
motor	incbin	a:asembler.s\dane.dat\motor.pi1

*section	bss		;sekcja bss

old_ssp	ds.l	1
old_log	ds.l	1
old_fiz	ds.l	1
old_res	ds.w	1
old_sync ds.b	2
old_pal	ds.l	8
	end
