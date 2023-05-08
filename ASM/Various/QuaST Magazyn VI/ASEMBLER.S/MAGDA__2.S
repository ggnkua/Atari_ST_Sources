; MARCHEW /TTS/WATCH UNION PREZENTUJE/POKAZUJE/ODKRYWA
; MARCHEW RZaDZI MARCHEW RADZI MARCHEW NIGDY CIe NIE ZDRADZI
;TAK,JAK OBIECYWALEM PRZEDSTAWIAM SOURCE >PLASTUSIOWEGO PAMIETNIKA<
;Ogolna zasada dzialania:
;-procedura timera co linia wpisuje do rejestru koloru tla wartosc 
; z bufora na ktorym to operujemy-wpisujac w nia wartoasci kolorow
; ktore maja byc wyswietlane
;-bufor ten wyglada jak jednowymiarowa pamiec ekranu
; z tym,ze nic nie obrazuje a tylko dane tam bedace generuja kolory
;-'kolorowe paly' stawiamy tak,ze adczytujemy kolejna wartosc z odpowiedniego
; sinusa.(pal jest 10!) i z takim offsetem wpisujemy pale do bufora
;-tak,ze operujemy tylko na tym buforze.Timer_b robi caly czas to samo
; to jest rzuca ciagle kolejne wartosci z tablicy ktora generujemy na vbl'u
;to wszystko
;acha!   Bardzo prosto jest napisac procedura ktora bedzie rzucala
;nieskonczona ilosc rastrow.. jak?! dojdz do tego lub zadzwon do mnie!
 
here_is_it_
	jsr	super_on			;SUPERVIZOR ON
	jsr czysc				;EKRAN WON

	JSR INICJACJA_PALY		;USTAWIENIE POINTEROW NA KOL (BUFOR NA 
                            ;KTORYM OPERUJEMY) ORAZ 	SINUSOW DO A_...
							;SINUSY SA JUZ Z ;;OPOZNIENIEM;; 

	jsr	inicjacja_vbl		;VBL WLACZ
	jsr inicjacja_mfp		;TIMER_B ZALACZ
	jsr key					;CZEKAJ NA KLAWISZ
	jsr koniec_vbl			;A JAK SIE ZJAWISZ WYLACZ VBL
	jsr koniec_mfp			;I TIMER_B	
	jsr koniec				;TO ZNAMY
	ILLEGAL					;A DO TEGO NIE ZAGLADAMY 

inicjacja_mfp
	and.b #$df,$fffa09		*zezwolenie na timer b
	move.l $120,zachowaj120
	lea $fffa06,a0			
	lea	mfpzachowaj,a1			;ZAPAMIETAMY POCZ.WART. MFP
	move.w #($21-7)/2,d0		
syf1	move.w (a0)+,(a1)+
	dbf d0,syf1

	ori.b	#$1,$fffa07		*rejestr zezwolenia przerw. tmr. a
	move.b   #2,$fffa21		*rej danych tmr b
	move.l #timer,$120		*adres nowego przerwania na vektor
	move.b  #8,$FFFa1b		*rej kontrolny tmr b
	ori.b	#$1,$fffa13		*rej maski tmr a
	rts	
inicjacja_vbl
	move.l	$70,zachowaj70		*tego nie tlumacze
	move.l #vbl,$70			*bo wstyd...
	rts
key							*systemowo i h..owo
	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	rts
koniec_vbl				   *co sie odpala to sie konczy
	move.l zachowaj70,$70	   *co na glowie to nie w Bonczy
	rts					   *gdzie sie swiat konczy
koniec_mfp
	lea	$fffa06,a0
	lea mfpzachowaj,a1
	move.w #($21-7)/2,d0	*zwracamy co zapamietalem byl
syf2	move.w (a1)+,(a0)+
	dbf d0,syf2
	move.l zachowaj120,$120
	ori.b #$20,$fffa09		
	rts
koniec
	move.w #$0,$ff8246			*black ink
	move.w #$777,$ff8240		*white paper
	clr.w -(sp)	
	trap #1

vbl
	movem.l	d0-d7/a0-a6,-(sp)	*zapamietaj rejestry
	move.l #kol,col_poin			*ustaw pointer na poczatek bufora
	move.b	#0,$fffa1b				*dla timera
	move.b	#8,$fffa1b				*dla timura
	jsr RUSZAJ					*nasze 10 pal
	jsr RUSZAJ2
	jsr RUSZAJ3
	jsr RUSZAJ4
	jsr RUSZAJ5
	jsr RUSZAJ6
	jsr RUSZAJ7
	jsr RUSZAJ8
	jsr RUSZAJ9
	jsr RUSZAJ10
	movem.l  (sp)+,d0-d7/a0-a6	*zwracamy ejestry
	rte
timer
	movem.l	a0,-(sp)		*zapamietaj
	move.b	#1,$fffa21		*co jedna linia nowa wartosc koloru

	move.l col_poin,a0	*pointer/kolejny kolor/ do A0
	move.w (a0),$ff8240	*co odczytales do rejestru tak,ze kazda linijka 
						*bedzie miala inny kolor.To jest wlasciwie 
						*istota procedury.Wystarczy teraz odpowiednio
						*wpisywac wartosci kolorow aby dostac co sie chce

	bclr.b	#0,$fffa0f		*rej przerw tmr a
	addQ.l #2,col_poin		*skok na nast.pozycje
	movem.l	(sp)+,a0		*zwracamy
	rte
*jakies syfy dla przerwan	
zachowaj70	ds.l 1
zachowaj120	ds.l 1
mfpzachowaj	ds.b $20
col_poin	dc.l kol
*te procedury znamy juz
czysc
	move.l #31999,a0
	move.l $44e,a0
tutu	clr.l	(a0)+
	dbf d0,tutu
	rts

super_on
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	add.l	#6,sp
	move.l d0,sav_ssp
	rts
super_off
	move.l sav_ssp,-(sp)
	move.w #$20,-(sp)
	trap #1
	add.l #6,sp
	rts
sav_ssp		dc.w 0
std_hbl
	jsr super_on
	move.l #$fc06c8,$68
	jsr super_off
licz ds.w 1
*tu jest nasza tablica-bufor gdzie sa kolory pal i ona jest potrzebna
*do timera.Non-stop jest rzucana do rej.tla
*do niej tez wpisujemy paly z odpowiednim offsetem (pozycja)
kol
	DS.W 200	;200*.w bo 200 lini a w kazdej inny kolor
	even

INICJACJA_PALY

	MOVE.L #kol,A_EKR
	move.l #SIN,A_2

	MOVE.L #kol,A_EKR2
	move.l #SIN2,A_22

	MOVE.L #kol,A_EKR3
	move.l #SIN3,A_23

	MOVE.L #kol,A_EKR4
	move.l #SIN4,A_24

	MOVE.L #kol,A_EKR5
	move.l #SIN5,A_25

	MOVE.L #kol,A_EKR6
	move.l #SIN6,A_26

	MOVE.L #kol,A_EKR7
	move.l #SIN7,A_27

	MOVE.L #kol,A_EKR8
	move.l #SIN8,A_28

	MOVE.L #kol,A_EKR9
	move.l #SIN9,A_29

	MOVE.L #kol,A_EKR10
	move.l #SIN10,A_210
	RTS
*te procedurki licza w ktore miejsce bufora wpisac pale
RUSZAJ		
	move.l A_2,a0	*pointer do a0
	jsr OBLICZ
	jsr PICTURE2	
	move.l a0,A_2	*a0 do pointerka
    RTS
RUSZAJ2
	move.l A_22,a0
	jsr OBLICZ2
	jsr PICTURE22
	move.l a0,A_22
    RTS
RUSZAJ3
	move.l A_23,a0
	jsr OBLICZ3
	jsr PICTURE23
	move.l a0,A_23
    RTS
RUSZAJ4
	move.l A_24,a0
	jsr OBLICZ4
	jsr PICTURE24
	move.l a0,A_24
    RTS
RUSZAJ5
	move.l A_25,a0
	jsr OBLICZ5
	jsr PICTURE25
	move.l a0,A_25
    RTS
RUSZAJ6
	move.l A_26,a0
	jsr OBLICZ6
	jsr PICTURE26
	move.l a0,A_26
    RTS
RUSZAJ7
	move.l A_27,a0
	jsr OBLICZ7
	jsr PICTURE27
	move.l a0,A_27
    RTS
RUSZAJ8
	move.l A_28,a0
	jsr OBLICZ8
	jsr PICTURE28
	move.l a0,A_28
    RTS
RUSZAJ9
	move.l A_29,a0
	jsr OBLICZ9
	jsr PICTURE29
	move.l a0,A_29
    RTS
RUSZAJ10
	move.l A_210,a0
	jsr OBLICZ10
	jsr PICTURE210
	move.l a0,A_210
    RTS
	
zeruj			*jesli spotkamy $ff =koniec tablicy sinusa to od poczatku
	MOVE.L #SIN,A_2
	JMP RUSZAJ
	rts
zeruj2
	MOVE.L #SIN2,A_22
	JMP RUSZAJ2
	rts
zeruj3
	MOVE.L #SIN3,A_23
	JMP RUSZAJ3
	rts
zeruj4
	MOVE.L #SIN4,A_24
	JMP RUSZAJ4
	rts
zeruj5
	MOVE.L #SIN5,A_25
	JMP RUSZAJ5
	rts
zeruj6
	MOVE.L #SIN6,A_26
	JMP RUSZAJ6
	rts
zeruj7
	MOVE.L #SIN7,A_27
	JMP RUSZAJ7
	rts
zeruj8
	MOVE.L #SIN8,A_28
	JMP RUSZAJ8
	rts
zeruj9
	MOVE.L #SIN9,A_29
	JMP RUSZAJ9
	rts
zeruj10
	MOVE.L #SIN10,A_210
	JMP RUSZAJ10
	rts

PICTURE2
	move.l a0,a_0
	MOVE.L A_EKR,A1		*w a1 jest adres dla paly w buforze
	JSR PALA			*stawiaj kolory-paly lub co tam k.... chcesz
	move.l a_0,a0
	RTS
PICTURE22
	move.l a0,a_02
	MOVE.L A_EKR2,A1
	JSR PALA
	move.l a_02,a0

 	RTS 
PICTURE23
	move.l a0,a_03
	MOVE.L A_EKR3,A1
	JSR PALA
	move.l a_03,a0

 	RTS 

PICTURE24
	move.l a0,a_04
	MOVE.L A_EKR4,A1
	JSR PALA
	move.l a_04,a0

 	RTS 
PICTURE25
	move.l a0,a_05
	MOVE.L A_EKR5,A1
	jsr PALA
	move.l a_05,a0

 	RTS 
PICTURE26
	move.l a0,a_06
	MOVE.L A_EKR6,A1
	jsr PALA
	move.l a_06,a0

 	RTS 
PICTURE27
	move.l a0,a_07
	MOVE.L A_EKR7,A1
	jsr PALA
	move.l a_07,a0

 	RTS 
PICTURE28
	move.l a0,a_08
	MOVE.L A_EKR8,A1
	jsr PALA
	move.l a_08,a0

 	RTS 
PICTURE29
	move.l a0,a_09
	MOVE.L A_EKR9,A1
	jsr PALA
	move.l a_09,a0

 	RTS 
PICTURE210
	move.l a0,a_010
	MOVE.L A_EKR10,A1
	jsr PALA
	move.l a_010,a0

 	RTS 
*te procedurki obliczaja adres 
OBLICZ
	MOVE.L (a0)+,D5			*to co z pointera
	CMP.B #$FF,D5			*sprawdz czy koniec
	beq zeruj				*jak tak to ustaw na poczatek
	ADD.L D5,A_EKR			*to co z pointera dodaj do 'adresu' dla paly
	RTS
OBLICZ2
	MOVE.L (a0)+,D5
	CMP.B #$FF,D5
	beq zeruj2
	ADD.L D5,A_EKR2
	RTS

OBLICZ3
	MOVE.L (a0)+,D5
	CMP.B #$FF,D5
	beq zeruj3
	ADD.L D5,A_EKR3
	RTS
OBLICZ4
	MOVE.L (a0)+,D5
	CMP.B #$FF,D5
	beq zeruj4
	ADD.L D5,A_EKR4
	RTS

OBLICZ5
	MOVE.L (a0)+,D5
	CMP.B #$FF,D5
	beq zeruj5
	ADD.L D5,A_EKR5
	RTS
OBLICZ6
	MOVE.L (a0)+,D5
	CMP.B #$FF,D5
	beq zeruj6
	ADD.L D5,A_EKR6
	RTS
OBLICZ7
	MOVE.L (a0)+,D5
	CMP.B #$FF,D5
	beq zeruj7
	ADD.L D5,A_EKR7
	RTS
OBLICZ8
	MOVE.L (a0)+,D5
	CMP.B #$FF,D5
	beq zeruj8
	ADD.L D5,A_EKR8
	RTS
OBLICZ9
	MOVE.L (a0)+,D5
	CMP.B #$FF,D5
	beq zeruj9
	ADD.L D5,A_EKR9
	RTS
OBLICZ10
	MOVE.L (a0)+,D5
	CMP.B #$FF,D5
	beq zeruj10
	ADD.L D5,A_EKR10
	RTS
PALA				*tu stawiamy nasze kochane(wreszcie)paly

	MOVE.W #$0,(A1)
	MOVE.W #$0,2(A1)
	MOVE.W #$001,4(A1)
	MOVE.W #$002,6(A1)
	MOVE.W #$003,8(A1)
	MOVE.W #$004,10(A1)
	MOVE.W #$005,12(A1)
	MOVE.W #$006,14(A1)
	MOVE.W #$007,16(A1)
	MOVE.W #$006,18(A1)
	MOVE.W #$005,20(A1)
	MOVE.W #$004,22(A1)
	MOVE.W #$003,24(A1)
	MOVE.W #$002,26(A1)
	MOVE.W #$001,28(A1)
	MOVE.W #$0,30(A1)
	MOVE.W #$0,32(A1)

	RTS
*SEKACJA DANYCH
A_EKR	DC.L 0
A_EKR2	DC.L 0
A_EKR3	DC.L 0
A_EKR4	DC.L 0
A_EKR5	DC.L 0
A_EKR6	DC.L 0
A_EKR7	DC.L 0
A_EKR8	DC.L 0
A_EKR9	DC.L 0
A_EKR10	DC.L 0
*sinusy dla kazdej paly
*moje chodza tak samo tylko,ze z opoznieniem ktore ciagle wzrasta
*jeslo opoznienia maja byc takie same to zmien w 'zeruj' aby
*wracaly w jakies jedno miejsce

SIN
	dc.l 0
SIN2
	dc.l 0
SIN3
	dc.l 0
SIN4
	dc.l 0
SIN5
	dc.l 0
SIN6
	dc.l 0
SIN7
	dc.l 0
SIN8
	dc.l 0
SIN9
	dc.l 0
SIN10		*te sinusy to tak naprawde: 'ile dodac do poprzedniej pozycji
			*adres parzysty tak ,ze jedna linia=2,2=4 itd
	DC.L 0,0,0,2,0,0,0,2,0,0,2,0,0,2,0,0,2,0,2,0,2,2
	DC.L 2,2,2,2,2,2,2,2
	DC.L 2,4,2,4
	DC.L 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
	DC.L 2,4,2,4
	DC.L 2,2,2,2,2,2,2,2
	DC.L 2,0,2,0,2,0,0,2,0,0,2,0,0,0,2,0,0,0,2,0,0,0,2,0

	DC.L 0,0,0,2,0,0,0,2,0,0,2,0,0,2,0,0,2,0,2,0,2,2
	DC.L 2,2,2,2,2,2,2,2
	DC.L 2,4,2,4
	DC.L 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
	DC.L 2,4,2,4
	DC.L 2,2,2,2,2,2,2,2
	DC.L 2,0,2,0,2,0,0,2,0,0,2,0,0,0,2,0,0,0,2,0,0,0,2,0

	DC.L 0,0,0,-2,0,0,0,-2,0,0,-2,0,0,-2,0,0,-2,0,-2,0,-2,-2
	DC.L -2,-2,-2,-2,-2,-2,-2,-2
	DC.L -2,-4,-2,-4
	DC.L -4,-4,-4,-4,-4,-4,-4,-4, -4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4
	DC.L -2,-4,-2,-4
	DC.L -2,-2,-2,-2,-2,-2,-2,-2
	DC.L -2,0,-2,0,-2,0,0,-2,0,0,-2,0,0,0,-2,0,0,0,-2,0,0,0,-2,0

	DC.L 0,0,0,2,0,0,0,2,0,0,2,0,0,2,0,0,2,0,2,0,2,2
	DC.L 2,2,2,2,2,2,2,2
	DC.L 2,4,2,4
	DC.L 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
	DC.L 2,4,2,4
	DC.L 2,2,2,2,2,2,2,2
	DC.L 2,0,2,0,2,0,0,2,0,0,2,0,0,0,2,0,0,0,2,0,0,0,2,0

	DC.L 0,0,0,-2,0,0,0,-2,0,0,-2,0,0,-2,0,0,-2,0,-2,0,-2,-2
	DC.L -2,-2,-2,-2,-2,-2,-2,-2
	DC.L -2,-4,-2,-4
	DC.L -4,-4,-4,-4,-4,-4,-4,-4, -4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4
	DC.L -2,-4,-2,-4
	DC.L -2,-2,-2,-2,-2,-2,-2,-2
	DC.L -2,0,-2,0,-2,0,0,-2,0,0,-2,0,0,0,-2,0,0,0,-2,0,0,0,-2,0

	DC.L 0,0,0,-2,0,0,0,-2,0,0,-2,0,0,-2,0,0,-2,0,-2,0,-2,-2
	DC.L -2,-2,-2,-2,-2,-2,-2,-2
	DC.L -2,-4,-2,-4
	DC.L -4,-4,-4,-4,-4,-4,-4,-4, -4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4
	DC.L -2,-4,-2,-4
	DC.L -2,-2,-2,-2,-2,-2,-2,-2
	DC.L -2,0,-2,0,-2,0,0,-2,0,0,-2,0,0,0,-2,0,0,0,-2,0,0,0,-2,0


	DC.L $FF		*oznacza koniec

*

A_2	dc.l 0
a_0	dc.l 0

A_22	dc.l 0
a_02	dc.l 0

A_23	dc.l 0
a_03	dc.l 0

A_24	dc.l 0
a_04	dc.l 0

A_25	dc.l 0
a_05	dc.l 0

A_26	dc.l 0
a_06	dc.l 0

A_27	dc.l 0
a_07	dc.l 0

A_28	dc.l 0
a_08	dc.l 0

A_29	dc.l 0
a_09	dc.l 0

A_210	dc.l 0
a_010   dc.l 0
*och.to bylo meczace....
*to jest najprostrza wersja tej procedury ale za to przejrzysta
*jest to versja nr 1  sa tez inne sposoby....

	end