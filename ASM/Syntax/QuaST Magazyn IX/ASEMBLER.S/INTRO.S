;*------------------------------------------------------------------------*
;*  QuaST Magazyn IX (C) 28.12.1975 QuaST Club / dysk #C - procedury *.S  *
;*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
;|																		  |
;|		Intro i list - swego czasu tak odpisywalem ludziom na listy		  |
;|  																	  |
;| autor: Van Eijik		    											  |
;| uwagi: Tekst listu nie zostal zmieniony, prosze sie nie smiac!!!		  |
;*------------------------------------------------------------------------*
    

POSY		equ		$78000+5120

START:	   	clr.l 	-(sP)					* supervisor !
			move.w 	#32,-(SP)
			trap 	#1
			addq.l 	#6,SP	

			move.b 	#$12,$ffffc02		* wylaczenie myszki

		    clr.w 	-(a7)                    
    		pea 	$78000                  * niska rozdzielczosc
	    	pea 	$78000                     
	    	move.w 	#5,-(a7)                
		    trap 	#14                       
    		adda.l 	#12,a7  

			lea		TAB(pc),a0				* okreslenie literek do wypiski,
			moveq	#0,d0
			moveq	#90,d7
PT1:		move.l	d0,(a0)+
			addq.l	#8,d0
			dbf		d7,PT1
						
*---------------------------------------------------*

			move.l 	#$78000+0*160,a0			* czyszczenie ekranu
			move.w 	#280*40-1,d0
SPRZATAJ1:	clr.l 	(a0)+
			dbf d0,SPRZATAJ1

			jsr 	PALETA					* ustawienie nowych kolorow

			move.l 	#$78000+6*160,a0		* rysunek na ekran
			move.l 	#PIC+34,a1
			move.w 	#16*40-1,d0
KOPIUJ:		move.l 	(a1)+,(a0)+
			dbf 	d0,KOPIUJ

			move.l 	#SAFEREG,a0			* zapamietanie rejestrow MFP
			move.b 	$fffa07,(a0)+
			move.b 	$fffa09,(a0)+
			move.b 	$fffa0b,(a0)+
			move.b 	$fffa0f,(a0)+
			move.b 	$fffa13,(a0)+
			move.b 	$fffa17,(a0)+
			move.b 	$fffa19,(a0)+	
			move.b 	$fffa1f,(a0)+	
			move.b 	$fffa1b,(a0)+
			move.b 	$fffa1d,(a0)+		
			move.b 	$fffa21,(a0)+
			MOVE.L 	$70,OLD_VBL			* zapamietanie starego VBLa
			move.l 	$120,OLD_TIMERB		* zapamietanie starego TIMERA B
			move.l 	$134,OLD_TIMERA    	* zapamietanie starego TIMERA A

			moveq	#1,d0
			jsr		MUSIC

			move.b 	#8,$fffa1b			* ladowanie nowych wartosci pod TIMERy
			move.b 	#4,$fffa21
			andi.b 	#%11011111,$fffa09
			clr.b  	$fffffa19		
			move.b 	#$21,$fffffa07	
			move.b 	#$21,$fffffa13	
			bclr   	#3,$fffffa17	
			move.l 	#VBL,$70				* nowa procedura dla VBLa
			move.l 	#TIMERB1,$120        *     --//--     dla TIMERA B
			move.l 	#TIMER_A,$134		*     --//--     dla TIMERA A
			move.w 	#$2300,sr		

LOOP:		cmp.w	#-1,PM
			bne		LOOP
KEYS:
			CMP.B 	#57,$FFFC02
			BNE.S 	KEYS

			move.l	#$78000+5120,a0
			move.w	#260*40-1,d7
POI:		clr.l	(a0)+
			dbf 	d7,POI

			move.w	#0,PM
			bra		LOOP

ENDED		jsr END						* skok do proc. zwracajacej stare wartosci
			move.l 	#$78000,a0			* kasowanie zawartosci ekranu
			move.w 	#280*40-1,d0
SPRZATAJ:	clr.l 	(a0)+
			dbf 	d0,SPRZATAJ
			clr 	-(sp)
			trap 	#1	

VBL:							* procedura przerwania VBLa
			clr.b	$fffffa19		
			move.b	#100,$fffffa1f	
			move.b	#4,$fffffa19	
			clr.b	$fffffa1b		
			move.b	#2,$fffffa21	
			move.l	#TIMERB1,$120	
			move.b	#8,$fffffa1b	
			movem.l	d0-d7/a0-a6,-(sp)
			jsr 	MUSIC+8			* skok do procedury odgrywajacej
			movem.l	(sp)+,d0-d7/a0-a6
			jsr 	WYPIS					* skok do procedury wypisujacej,
			cmp.b #1,$fffc02
			beq ENDED
			rte

*---------------------------------------------------*

TIMERB1:	move.l	#TIMERB2,$120.w
			move.w	#$000,$fff8240	
			move.w	#$077,$fff8242
			move.w	#$022,$fff8244	
			move.w	#$033,$fff8246	
			move.w	#$044,$fff8248	
			move.w	#$055,$fff824a	
			move.w	#$066,$fff824c	
			move.w	#$011,$fff824e	
			rte
TIMERB2:	move.l	#TIMERB3,$120.w
			move.w	#$005,$fff8240	
			rte
TIMERB3:	move.l	#TIMERB4,$120.w
			move.w	#$005,$fff8240	
			rte
TIMERB4:	move.l	#TIMERB5,$120.w
			move.w	#$005,$fff8240	
			rte
TIMERB5:	move.l	#TIMERB6,$120.w
			move.w	#$005,$fff8240	
			rte
TIMERB6:	move.l	#TIMERB7,$120.w
			move.w	#$005,$fff8240	
			rte
TIMERB7:	move.l	#TIMERB8,$120.w
			move.w	#$005,$fff8240	
			rte
TIMERB8:	move.l	#TIMERB9,$120.w
			move.w	#$005,$fff8240	
			rte
TIMERB9:	move.l	#TIMERB10,$120.w
			move.w	#$005,$fff8240	
			rte
TIMERB10:	move.l	#TIMERB11,$120.w
			move.w	#$005,$fff8240	
			rte
TIMERB11:	move.l	#TIMERB12,$120.w
			move.w	#$005,$fff8240	
			rte
TIMERB12:	move.l	#TIMERB13,$120.w
			move.w	#$000,$fff8240	
			rte
TIMERB13:	move.l	#TIMERB14,$120.w
			move.b	#8,$ffff8800
			move.b	$ffff8800,d0
			move.b	d0,$fff8240	
			rte
TIMERB14:	move.l	#TIMERB15,$120.w
			move.w	#$000,$fff8240	
			rte
TIMERB15:	move.l	#TIMERB16,$120.w
			move.b	#9,$ffff8800
			move.b	$ffff8800,d1
			move.b	d1,$fff8240	
			rte
TIMERB16:	move.l	#TIMERB17,$120.w
			move.w	#$000,$fff8240	
			rte
TIMERB17:	move.l	#TIMERB18,$120.w
			move.b	#10,$ffff8800
			move.b	$ffff8800,d2
			move.b	d2,$fff8240	
			rte
TIMERB18:	move.l	#TIMERB19,$120.w
			move.w	#$000,$fff8240	
			rte
TIMERB19:	move.l	#TIMERB20,$120.w
			move.w	#$000,$fff8240	
			rte
TIMERB20:	move.l	#TIMER_B,$120.w
			move.w	#$000,$fff8240	
			move.b	#228-42,$fffffa21	
			rte
TIMER_B:						* procedura przerwania TIMERa B
			move.w	d0,-(sp)		
			rept	32		
			nop			nop 
			endr			
			clr.w	d0		
			move.b	$ffff8209,d0	
			neg.b	d0		
			add.b	#192,d0		
			lsl.b	d0,d0		
			move.w	#18,d0		
PAUSE:		dbra	d0,PAUSE		
			move.b	#0,$ffff820a	
			rept	12		
			nop			nop 
			endr			
			move.b	#2,$ffff820a	
			move.w	(sp)+,d0		
			move.w #$000,$ffff8240
			rte

TIMER_A		move.w	#$2100,sr		* procedura przerwania TIMERa A
			stop	#$2100		
			clr.b	$fffffa19	
			rept	78		
			nop			nop 
			endr			
			clr.b	$ffff820a
			nop			nop
			nop			nop 
			move.b	#2,$ffff820a	
			rte			

PALETA:							* ustawienie nowych kolorow
			move.l 	#PAL,-(sp)
			move.w 	#6,-(sp)
			trap 	#14
			addq.l 	#6,sp
			rts

END:							* zwort starych wartoscu ukladu MPF
			MOVE.L 	OLD_VBL,$70			* stary VBL
			andi.b 	#%11111110,$fffa07
			andi.b 	#%11111110,$fffa13
			move.l 	OLD_TIMERB,$120		* stary TIMER B
			move.l 	OLD_TIMERA,$134		* stary TIMER A
			move.l 	#SAFEREG,a0
			move.b 	(a0)+,$fffa07
			move.b 	(a0)+,$fffa09
			move.b 	(a0)+,$fffa0b                              
			move.b 	(a0)+,$fffa0f
			move.b 	(a0)+,$fffa13
			move.b 	(a0)+,$fffa17
			move.b 	(a0)+,$fffa19	
			move.b 	(a0)+,$fffa1f	
			move.b 	(a0)+,$fffa1b
			move.b 	(a0)+,$fffa1d
			move.b 	(a0)+,$fffa21
			move.b 	#$f7,$fffa23
			move.w	#$2700,sr		
			bset	#3,$fffffa17	
			move.w	#$2300,sr		
			move.w 	#$777,$ff8240    	* kolory...            
			move.w 	#$000,$ff8246
			move.b 	#8,$ffffc02
			moveq	#0,d0
			jsr		MUSIC
			move.b	#255,$484
			rts

OLD_VBL:	ds.l 1
OLD_TIMERB: ds.l 1
OLD_TIMERA: ds.l 1
SAFEREG: 	ds.b 12
MUSIC		incbin \asembler.s\dane.dat\sectori1.mus
PIC:		incbin \asembler.s\dane.dat\LIST.PI1
PAL:							* dane do kolorow
			dc.w $000,$777,$011,$777,$022,$777,$033,$777
			dc.w $044,$777,$055,$777,$066,$777,$077,$777

*---------------------------------------------------*

WYPIS:
			cmp.w	#-1,PM
			beq		RTE3
			cmp.w	#1,KUTWA		* szybkosc wyswietlanego tekstu,
			bne.s	RTE1
			movem.l	d0-d7/a0-a6,-(sp)
			bsr		TXT
			movem.l	(sp)+,d0-d7/a0-a6
			clr.w	KUTWA
RTE1:		addq.w	#1,KUTWA
			bra.s	RTE3
RTE2:		jsr	CZYSCIEC
			RTS
RTE3:		RTS

TXT:		moveq	#0,d0
			moveq	#0,d1
			lea		KTORA_LITERKA(pc),a1
			lea		2(a1),a0
			move.w	(a1),d0
			move.b	(a0,d0.w),d0
			and.w	#$ff,d0
			cmp.b	#0,d0
			bne.s	NIC_TO1
			clr.w	(a1)
			move.l	#posy,SCREEN
			move.l	#posy,GDIE
			bra		RTS2

NIC_TO1:	cmp.b	#10,d0
			bne.s	NIC_TO2
			move.l	#posy,SCREEN
			move.l	#posy,GDIE
			move.w	#-1,PM
			bra		RTS
NIC_TO2:	cmp.b	#13,d0
			bne.s	NIE_RUSZ
			add.l	#9*160,SCREEN
			move.l	SCREEN(pc),GDIE
			clr.l	ADD
			bra.s	RTS
NIE_RUSZ:	sub.w	#32,d0
			add.w	d0,d0
			add.w	d0,d0
			lea		TAB(pc),a1
			lea		FONCIKI(pc),a0
			add.l	(a1,d0.w),a0
			move.l	GDIE(pc),a1
			move.b	(a0),(a1)
			move.b	1(a0),160(a1)
			move.b	2(a0),320(a1)
			move.b	3(a0),480(a1)
			move.b	4(a0),640(a1)
			move.b	5(a0),800(a1)
			move.b	6(a0),960(a1)
			move.b	7(a0),1120(a1)
			lea		ADD(pc),a0
			bchg	#1,DUPA
			btst	#1,DUPA
			beq.s	NIE
			move.l	#1,(a0)
			bra.s	PIXXX
NIE:		move.l	#7,(a0)
PIXXX:		move.l	(a0),d0
			add.l	d0,gdie
RTS:		addq.w	#1,KTORA_LITERKA
RTS2: 		rts

PM			ds.w	1

CLIN:		lea		$7b53c,a0
			moveq	#0,d0
			move.w	#79,d7
FIUT:		move.w	d0,(a0)
			move.w	d0,8(a0)
			move.w	d0,16(a0)
			move.w	d0,24(a0)
			move.w	d0,32(a0)
			move.w	d0,40(a0)
			move.w	d0,48(a0)
			move.w	d0,56(a0)
			move.w	d0,64(a0)
			move.w	d0,72(a0)
			move.w	d0,80(a0)
   			move.w	d0,88(a0)	
			move.w	d0,96(a0)
			move.w	d0,104(a0)
			lea		160(a0),a0
			dbf		d7,FIUT
			rts
DUPA:		ds.w	1

KTORA_LITERKA:		ds.w	1

		dc.b	"Drogi Damianie !                        ",13
		dc.b	"Na wst&pie tego listu pozdrawiam Ci& se-",13
		dc.b	"rdecznie i dzi&kuj& za Tw/j kontakt z   ",13
		dc.b	"klubem. Aby nie przeci$ga% tego listu   ",13
		dc.b	"przejd& odrazu do odpowiedzi na posta-  ",13
		dc.b	"wione przez Ciebie pytania.             ",13
		dc.b	"1) Aby nale>e% do klubu nale>y przes*a%:",13
		dc.b	" - dok*adne dane o sobie (imie i nazwi- ",13
		dc.b	"   sko, wiek)                           ",13
		dc.b	" - adres zamieszkania ( ulica i numer   ",13
		dc.b	"   domu, miasto i kod pocztowy, telefon)",13
		dc.b	" - dane o posiadanym sprz&cie (typ Atari",13
		dc.b	"   ,pami&% Ram, monitor, telewizor, dru-",13
		dc.b	"   karka, sapler, dodatkowa stacja,itp.)",13
		dc.b	" - na w*asno<% klubu dyskietk& ze spisem",13
		dc.b	"   posiadanego oprogramowania.          ",13
		dc.b	"2) Klub przede wszystkim zajmuje si&    ",13
		dc.b	"   zrzeszaniem cz*onk/w, a ponadto:     ",13
		dc.b	" - pozwala na wymian& oprogramowania po-",13
		dc.b	"   mi&dzy cz*onkami                     ",13
		dc.b	" - pozwala na wymian& do<wiadcze+ w ka- ",13
		dc.b	"   >dej dziedzinie                      ",13
		dc.b	" - organizuje raz do roku spotkanie     ",13
		dc.b	"   cz*onk/w (w roku 93 odby*o si& one w ",13
		dc.b	"...SPACJA...                            ",13,10
*	
		dc.b	"   Ornecie w dniach 9-11 Lipca, natomia-",13
		dc.b	"   st w tym roku odb&dzie si& ono w Na- ",13
		dc.b	"   kle nad Noteci$ w dniach 26-28 Sie-  ",13
		dc.b	"   rpnia)                               ",13
		dc.b	"3) Klub wydaje magazyn dyskowy nazwany  ",13
		dc.b	"   Quast Magazine. Do tej pory wysz*o 6 ",13
		dc.b	"   numer/w, z czym ten ostatni jest dwu-",13
		dc.b	"   dyskowy. Wszystkie magazyny s$ typu  ",13
		dc.b	"   Public Domain i mo>esz je otrzyma% za",13
		dc.b	"   darmo. Inaczej ma si& sprawa z Quast ",13
		dc.b	"   Magazinem 7, kt/ry jest ju> komercy- ",13
		dc.b	"   jny i b&dzie go mo>na dosta% za 100  ",13
		dc.b	"   tys. z*. Mo>e si& wydawa%, >e to dro-",13
		dc.b	"   go ale w cen& wliczone s$ dwie dy-   ",13
		dc.b	"   skietki (2x20 tys. z*) i koszty prze-",13
		dc.b	"   sy*ki 12 tys. z*. Je<li chcesz to ta-",13
		dc.b	"   mte 6 numer/w mo>esz dosta%,przesy*a-",13
		dc.b	"   j$c mi dyskietki i 15 tys. na paczk& ",13
		dc.b	"   zwrotn$. Je<li natomiast b&dziesz    ",13
		dc.b	"   chcia* QM 7 to pieni$>ki przekazem   ",13
		dc.b	"   poleconym i sprawa z g*owy. Aby< nie ",13
		dc.b	"   kupowa* kota w worku, streszcz& zawa-",13
		dc.b	"   rto<% magazynu nr. 7, kt/rego wydanie",13
		dc.b	"   planuj& za oko*o tydzie+.            ",13
		dc.b	"...SPACJA...                            ",13,10
*	
		dc.b	"Na dysku A znajduje si&:                ",13
		dc.b	"- Program informacyjny o magazynie i o  ",13
		dc.b	"  dzia*alno<ci klubu,                   ",13
		dc.b	"- Program pokazuj$cy par& fajnych rysu- ",13
		dc.b	"  nk/w,                                 ",13
		dc.b	"- Program po<wi&cony muzyce analogowej, ",13
		dc.b	"- Trzy programy demonstracyjne na Atari ",13
		dc.b	"  ST i dwa na Atari STe,                ",13
		dc.b	"- Program z dwudziestoma artyku*ami,    ",13
		dc.b	"Na dysku B znajduje si&:                ",13
		dc.b	"- Quastografia - program ze spisem oko*o",13
		dc.b	"  160 cz*onk/w,                         ",13
		dc.b	"- Tfmx Play - prosty programik do odtwa-",13
		dc.b	"  rzania muzyki analogowej,             ",13
		dc.b	"- Drucker - program do drukowania norma-",13 
		dc.b	"  lnych tekst/w w kodzie Ascii z polski-",13
		dc.b	"  mi znakami w trybie polonici na druka-",13
		dc.b	"  rce z polskimi znakami w trybie Mazo- ",13
		dc.b	"  vii lub Latina,                       ",13
		dc.b	"- Virus Studio - demonstracyjna wersja  ",13
		dc.b	"  programu do generowania wirus/w,      ",13
		dc.b	"- Monitor - monitor pami&ciowy,         ",13
		dc.b	"- Ospa - program do zawirusowywania dy- ",13
		dc.b	"  sk/w popularnymi wirusami,            ",13
		dc.b	"...SPACJA...                            ",13,10
*	
		dc.b	"- Driver48 - driver do Calamusa dla dru-",13
		dc.b	"  karki Star Jet 48,                    ",13
		dc.b	"- Water - program dzi&ki kt/remu mo>esz ",13 
		dc.b	"  sprawdzi% wydajno<% swojego m/zgu w   ",13
		dc.b	"  zakresie mno>enia,                    ",13
		dc.b	"- Calc - program do obliczania p/l i    ",13
		dc.b	"  obwod/w r/>nych fig/r p*askich i prze-",13
		dc.b	"  strzennych,                           ",13
		dc.b	"- Przeb/j - modu* do Protrackera w rama-",13
		dc.b	"  listy przeboj/w,                      ",13
		dc.b	"- 25 proced/r do Assemblera (Devpac'a), ",13
		dc.b	"- 22 proced/ry do Gfa Basica.           ",13
		dc.b	"I tak si& ma sprawa z numerem 7.        ",13
		dc.b	"",13
		dc.b	"Wracaj$c do listu...                    ",13
		dc.b	"Ka>da mi*a osoba jest w klubie mile wi- ",13
		dc.b	"dziana, wi&c nam/w kumpli do wst&powania",13
		dc.b	"do klubu, z pewno<ci$ nie po>a*uj$.     ",13
		dc.b	"Jak zauwa>y*e< list ten jest w odmiennej",13
		dc.b	"formie, ale m/wi$c szczerze nie chcia*o ",13
		dc.b	"mi si& ju> drukowa% i z reszt$ tusz mi  ",13
		dc.b	"si& ko+czy w kartrid>u. Prosz& Ci& oczy-",13
		dc.b	"wi<cie o zwrot mojej dyskietki. Jak b&- ",13
		dc.b	"dziesz mi odpisywa* i wysy*a* dysk wpi- ",13
		dc.b	"sowy(...)            ...SPACJA...       ",13,10
*
		dc.b	"to je<li masz jakie< modu*y do trackera ",13
		dc.b	"to prosz& aby< mi par& z nich nagra*.   ",13
		dc.b	"Jestem tak mo>na powiedzie% kolekcjone- ",13
		dc.b	"rem modu*/w. Jak b&dziesz wysy*a* jakie<",13
		dc.b	"dyskietki to wysy*aj je zawsze listami  ",13
		dc.b	"poleconymi (kradn$ !!) i znaczki zwrotne",13
		dc.b	"te> niech b&d$ odpowiednio cenowo.      ",13
		dc.b	"Najwi&kszym problemem w korespondencji z",13
		dc.b	"klubem jest brak znaczk/w zwrotnych,wi&c",13
		dc.b	"prosz& Ci& aby< nigdy o tym nie zapo-   ",13
		dc.b	"mnia*, bo jak zapomnisz to napewno nie  ",13
		dc.b	"b&dziesz m/g* liczy% na szybki odpis.   ",13
		dc.b	"Nie b&d& si& ju> tutaj rozwodzi*, je<li ",13
		dc.b	"masz jakie< problemy to wal <mia*o, nie ",13
		dc.b	"kr&puj si&, w ko+cu ka>dy zaczyna* od   ",13
		dc.b	"gier. No i to chyba na tyle...          ",13
		dc.b	"                   Z powa>aniem         ",13
		dc.b	"                 Artur  Borkowski       ",13
		dc.b	"",13
		dc.b	"Orneta 1994 7 kwiecie+                  ",13
		dc.b	"                            ...SPACJA...",13,10,0
*

LAST_WORD:	ds.b	1
			even
ADD:		dc.l	1
SCREEN:		dc.l	posy
GDIE:		dc.l	posy
TAB:		ds.l	64
POLICZNIJ:	ds.w	1
GBR:		ds.l	1
GBR2:		ds.l	1
PIZDKA:		dc.l	posy
NEXTY:		ds.w	1
CZYSCIEC:	rts
FONCIKI:	incbin	\asembler.s\dane.dat\VANEIJK3.DAT
KUTWA:		ds.w	1

