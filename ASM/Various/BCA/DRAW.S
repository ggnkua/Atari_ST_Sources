* Program rysujacy linie.                                       (c) BCA

S:					
	CLR.L -(SP)
 	MOVE.W #$20,-(SP)                      	* Tryb supervisor
	TRAP #1
	ADDQ.L #6,SP
	MOVE.L #639,D6                         	* Ilosc lini

DRAW:
	MOVE.L $44E,A0                         	* Adres ekranu
	MOVE.L #319,D0                         	* X - poczatku
	MOVE.L #0,D1                           	* Y - poczatku
	MOVE.L D6,D2                          	* X - konca
	MOVE.L #199,D3			* Y - konca
	JSR SUB1				* skok do rys. 1-lini
E:
	DBF D6,DRAW
END:
	MOVE.W #7,-(sp)			* Czekanie na klawisz
	TRAP #1
	ADDQ.L #2,sp
		
	CLR.L -(SP)
	TRAP #1


SUB1:                                  		
	SUB.W D0,D2                            	* Obl. dl. wektora
	BPL PLUS1				* dla dlugosci X

	SUBQ.W #1,D2
	MOVE.W #$D440,WP2.2                    	* Modyfikacja programu 
	MOVE.W #$D440,WP5.2                    	* rysujacego dla 
	MOVE.W #-4,WP1+2                       	* ujemnego kroku
	MOVE.W #-4,WP3.2+2
	MOVE.W #$0,WP4.2+2
	BSET #0,B
	NOT D2                                 	* Wartosc absolutna D2 (dl.X)
	ADDQ.W #1,D2
	BRA SUB2
PLUS1:
	ADDQ.W #1,D2
	MOVE.W #$9440,WP2.2                    	* Modyfikacja programu 
	MOVE.W #$9440,WP5.2                    	* rysujacego dla 
	MOVE.W #$4,WP1+2                       	* dodatniego kroku
	MOVE.W #$4,WP3.2+2
	MOVE.W #$F00F,WP4.2+2
	BCLR #0,B

SUB2:                                   	* Obl. dl. wektora 
	SUB.W D1,D3                             * dla dlugosci Y
	BPL PLUS2
	
	SUBQ.W #1,D3
	MOVE.W #-160,WP+2                       * Modyfikacja programu
	MOVE.W #-160,WP.2+2                     * dla ujemnego kroku
	NOT D3                                  * Wartosc absolutna D3 (dl.Y)
	ADDQ #1,D3
	BRA ADR 
PLUS2:
	ADDQ.W #1,D3
	MOVE.W #160,WP+2                        * Modyfikacja programu 
	MOVE.W #160,WP.2+2                      * dla dodatniego kroku
	
ADR:
	MULU #160,D1                            * Procedura obliczajaca
	ADD.L D1,A0                             * adres poczatkowy draw-a
	MOVE.W D0,D4
	LSR.W #2,D0
	AND.W #-4,D0
	NOT D4
	AND #15,D4
	ADD.L D0,A0
	
	CMP.W D2,D3                             * Porownanie dl. wekt. X z Y
	BGE MNIEJ
	
	MOVE D2,D5                              * Wartosc dla petli rys.
	SUBQ.W #1,D5
	CMP.W #8,D2
	BGE STEPX
	MOVE.L #$FFFF,D0                        * Obliczenie kroku X
	DIVU D2,D0
	MULU D0,D3
	BRA STEPX1
STEPX: 
	MOVE.L #$7FFF8,D0                       * Obliczenie kroku X
	DIVU D2,D0			*(wieksza dokladnosc kroku)
	MULU D0,D3
	LSR.L #3,D3
STEPX1:	
	MOVE.W D3,D1
	MOVEQ #0,D2			* pozycja pierwszego piksela...
	MOVE.B D4,D2
	SWAP D2
	ASR.L #4,D2
	MOVE.B D4,D2			* nr bitu (piksela na ekranie)
	MOVEQ #0,D4
	MOVE.W #$1001,D0
	JSR RYS.2
	RTS

MNIEJ:
	MOVE.W D3,D5                            * Wartosc dla petli rys.
	SUBQ.W #1,D5
	CMP.W #8,D3
	BGE STEPY
	MOVE.L #$FFFF,D1                        * Obliczenie kroku Y
	DIVU D3,D1
	MULU D1,D2 
	BRA STEPY1
STEPY:	
	MOVE.L #$7FFF8,D1                       * Obliczenie kroku Y
	DIVU D3,D1
	MULU D1,D2 
	LSR.L #3,D2
STEPY1:
	MOVE.W D2,D3                            * Wartosc kroku
	MOVEQ #0,D0
	BSET D4,D0                              * Pierwszy punkt
	JSR RYS
	RTS
	
	
RYS:                                  		* Procedura rysujaca 
	                                        * przesuniecie X - co krok 
	                                        * przesuniecie Y - stale
	OR.W D0,(A0)                            * Nalozenie na ekran (wyswietlenie)
WP: 
	LEA -160(A0),A0                         * zmiana adresu (pozycji w Y), (zalezne od kroku wpisywane wyzej  -160 lub 160) 
	ADD.W D2,D3                             * dodanie kroku
	BCS B                                   * spr. przeniesienia
	DBF D5,RYS			* petla rysujaca
	RTS
B:
	ROL.W #1,D0                             * przesuniecie piksela (zalezne od kroku  ROL lub ROR)
	BCS WP1                                 * spr. czy poza slowem
	DBF D5,RYS
	RTS
WP1:
	LEA -4(A0),A0                           * zmiana adresu (pozycji w X), (zalezne od kroku 4 lub -4)
	DBF D5,RYS
	RTS 
	
	
RYS.2:                                 		* Procedura rysujaca 
	                                        * przesuniecie X - stele 
	                                        * przesuniecie Y - co krok
	BSET D2,D4			* zapalenie bitu (piksela)
	ADD.W D1,D3                             * dodanie kroku Y
	BCS B2.2
WP2.2:
	ADD.W D0,D2			* dodanie dla spr.czy nie poza slowem (wpisywane wyzej add lub sub)
	BCS B2
	DBF D5,RYS.2			* petla rysujaca
	OR.W D4,(A0)                            * wyswietlenie slowa
	RTS
B2:
	OR.W D4,(A0)                            * wyswietlenie slowa
WP3.2: 
	LEA 4(A0),A0  			* nastepne slowo (wpisane wyzej SUB lub ADD)
	MOVEQ #0,D4
WP4.2:
	MOVE.W #$0,D2			* (wpisane $0 lub $F00F) 
	DBF D5,RYS.2
	RTS
B2.2: 
	OR.W D4,(A0)                            * wyswietlenie
WP.2:
	LEA -160(A0),A0			* zmiana adresu (pozycji w Y)
	MOVEQ #0,D4
WP5.2: 
	ADD.W D0,D2  			* to samo co WP2.2:
	BCS B2
	DBF D5,RYS.2
	OR.W D4,(A0)                            * wyswietlenie
	RTS

*********************************************************************************************************************