***************************************************************************
* Q u a s t  V I - programowanie w assemblerze							  *
***************************************************************************
* program  		 - rastry, czyli wiecej niz 16 kolorow					  *
* autor    		 - Costek  											      *
* typ Atari		 - ST/E												      *
***************************************************************************
* CZESC POCZATKUJACY ASSEMBLEROWCY,BO TO DO WAS ADRESOWANY JEST TEN
* ARTYKULIK.STARZY WYJADACZE ROBILI COS TAKIEGO JUZ DAWNO I MOGA
* NIE ZADAWAC SOBIE TRUDU URUCHAMIANIA TEJ PROCEDURKI.
* A SA NAJPROSTSZE RASTRY POD TIMEREM B
* NIE JEST TO NIC TRUDNEGO,MAM WIEC NADZIEJE,ZE NAJWIEKSZE OFIARY
* TEZ SIE POLAPIA.
* W RAZIE PROBLEMOW KONTAKTUJCIE SIE ZE MNA.
*                           BYE NOW I DO ROBTY
*                                COSTEK.

* SUPERVISOR!!!!!	
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,-(sp)

* LOW RESOLUTION
	move.w #0,-(sp)
	move.l #-1,-(sp)
	move.l #-1,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #12,sp

*TU LADUJEMY ADRES TABLICY KOLORKOW DO WSKAZNIKA
 	move.l #kolory,kol

* ZAPAMIETUJEMY STARE WARTOSCI REJESTROW MFPORAZ WEKTORY PRZERWAN VBL($70) I TIMER B($120)
	move.l #safereg,a0
	move.b $fffa07,(a0)+
	move.b $fffa09,(a0)+	
	move.b $fffa0b,(a0)+
	move.b $fffa0f,(a0)+
	move.b $fffa13,(a0)+
	move.b $fffa17,(a0)+
	move.b $fffa1b,(a0)+
	move.b $fffa1d,(a0)+
	move.b $fffa21,(a0)+
	move.l $70,oldvbl
	move.l $120,oldtimb

* USTAWIAMY NOWE WARTOSCI TYCHZE REJESTROW
	move.b #8,$fffa1b                 * TRYB ZLICZANIA ZEGARA B
	move.b #1,$fffa21                 * PRZERWANIE CO JEDNA LINIE ( SPROBUJ INNYCH )
	ori.b #%00000001,$fffa07          * ZEZWOLENIE NA PRZERWANIE TIMERA B 
	andi.b #%11011111,$fffa09         * MASKA PRZERWAN PORTU B  ( WYLACZAMY ZEGAR C,GDYZ MOZE NAROZRABIAC )
	ori.b #%00000001,$fffa13          * MASKA PRZERWAN PORTU A (URUCHAMIAMY TIMER ) 
	move.l #vbl,$70                   * NORMALKA - NOWY VBL
	move.l #timerb,$120               * J/W      - NOWY TIMER B

*******************************

* PETLA OCZEKIWANIA NA KLAWISZ (SPACJA)
loop
	cmp.b #185,$fffc02
	bne.s loop

* KONIEC - ZWRACAMY STARE REJESTRY....
	move.l #safereg,a0
	move.b (a0)+,$fffa07
	move.b (a0)+,$fffa09
	move.b (a0)+,$fffa0b
	move.b (a0)+,$fffa0f
	move.b (a0)+,$fffa13
	move.b (a0)+,$fffa17
	move.b (a0)+,$fffa1b
	move.b (a0)+,$fffa1d
	move.b (a0)+,$fffa21
	move.b #$f7,$fffa23
	move.l oldvbl,$70
	move.l oldtimb,$120
	move.w #$777,$ff8240                
* .... I WYCHODZIMY Z PROGRAMU.
	clr.l -(sp)
	trap #1

* TO JEST PROCEDURKA VBL (TIMER B POBRAL I WYRYSOWAL WSZYSTKIE 200 LINII,
* TRZEBA WIEC WSKAZNIK USTAWIC NA POCZATEK,ZEBY WYSWIETLIC ZNOW TO SAMO.
vbl
	move.l #kolory,kol
	rte

* TU JEST PROCEDURKA TIMERA B JEST ONA WYKONYWANA CO 1 LINIE (W TYM PRZYPADKU.JESLI NP.
* ZMIENISZ WARTOSC WPISYWANA POD ADRES $FFFA21 NA 2 TO CO DWIE LINIE ITD.
timerb
	move.b #1,$fffa21       * TU WLASNIE LADUJEMY CO KTORA LINIE
	move.l kol,a0           * POZYCJA KOLORKOW DO A0
	move.w (a0)+,$ff8240    * KOLOR 0 = WARTOSC SPOD TEGO ADRESU
	move.l a0,kol           * ZAPISZ POD WSKAZNIK ADRES NASTEPNEGO KOLORKA
	bclr.b #0,$fffa0f       * TO MUSI BYC - INFORMUJESZ MFP,ZE NIE MA WIECEJ OBSLUGIWANYCH PRZERWAN I MOZNA CZEKAC NA NASTEPNA LINIE
	rte                     * KONIEC PROCEDURY PRZERWANIA


* TU JEST REZERWOWANA PAMIEC DLA STARYCH DANYCH ,ORAZ SA DANE KOLORKOW
kol	ds.l 1
oldvbl	ds.l 1
oldtimb ds.l 1
safereg ds.b 10
	even
kolory                      * W FORMACIE $Red Green Blue
	dc.w $200,$200,$300,$300,$400,$400,$500,$500,$600,$600
	dc.w $500,$500,$400,$400,$300,$300,$200,$200,$100,$100
	dc.w $020,$020,$030,$030,$040,$040,$050,$050,$060,$060
	dc.w $050,$050,$040,$040,$030,$030,$020,$020,$010,$010
	dc.w $002,$002,$003,$003,$004,$004,$005,$005,$006,$006
	dc.w $005,$005,$004,$004,$003,$003,$002,$002,$001,$001
	dc.w $022,$022,$033,$033,$044,$044,$055,$055,$066,$066
	dc.w $055,$055,$044,$044,$033,$033,$022,$022,$011,$011
	dc.w $220,$220,$330,$330,$440,$440,$550,$550,$660,$660
	dc.w $550,$550,$440,$440,$330,$330,$220,$220,$110,$110
	dc.w $202,$202,$303,$303,$404,$404,$505,$505,$606,$606
	dc.w $505,$505,$404,$404,$303,$303,$202,$202,$101,$101
   	dc.w $200,$200,$300,$300,$400,$400,$500,$500,$600,$600
	dc.w $500,$500,$400,$400,$300,$300,$200,$200,$100,$100
	dc.w $020,$020,$030,$030,$040,$040,$050,$050,$060,$060
	dc.w $050,$050,$040,$040,$030,$030,$020,$020,$010,$010
	dc.w $002,$002,$003,$003,$004,$004,$005,$005,$006,$006
	dc.w $005,$005,$004,$004,$003,$003,$002,$002,$001,$001
	dc.w $022,$022,$033,$033,$044,$044,$055,$055,$066,$066
	dc.w $055,$055,$044,$044,$033,$033,$022,$022,$011,$011
	dc.w $220,$220,$330,$330,$440,$440,$550,$550,$660,$660
	dc.w $550,$550,$440,$440,$330,$330,$220,$220,$110,$110
	dc.w $202,$202,$303,$303,$404,$404,$505,$505,$606,$606
	dc.w $505,$505,$404,$404,$303,$303,$202,$202,$101,$101
	dc.w 0,0,0,0,0,0,0,0,0,0
