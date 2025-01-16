***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  3 D - proc. do obracania obektu 3 D w czasie rzeczywistym *
* autor      :  STrych / TFTE (92.10.03)                                  *
* inne uwagi :  -                                                         *
***************************************************************************

****************************************
* Pierwotnie ta procedura miala byc    *
* dolaczona do magazynu The Voice, ale *
* ostatecznie zdecydowalem sie dolaczyc*
* do QM.							   *
****************************************
* Wszystkie obliczenia sa wykonywane   *
* na bierzaco (w czasie rzeczywistym)  *
****************************************

     
	OPT D+

	CLR.L -(SP)
 	MOVE.W #$20,-(SP)                      	* Tryb supervisor
	TRAP #1
	ADDQ.L #6,SP
pocz	
   	cmp.b #57,$fffc02
  	beq	ex
	move.l #360*4,d7
da
	move.w #$666,$ff8240
	move.w #37,-(sp)
	trap #14
	addq.l #2,sp
	move.w #$777,$ff8240
	jsr obr_objektu

	TST.W SWITCH		
	BNE.S TIME
	MOVE.L #$78000,SCREEN1	
	MOVE.L #$70000,SCREEN	
	MOVE.W #1,SWITCH	
	BRA.S TIME2
TIME	MOVE.L #$70000,SCREEN1	
	MOVE.L #$78000,SCREEN	
	MOVE.W #0,SWITCH	
TIME2	MOVE.W #-1,-(SP)	
	MOVE.L SCREEN1,-(SP)	
	MOVE.L SCREEN,-(SP)	
	MOVE.W #5,-(SP)
	TRAP #14
	ADD.L #12,SP

	move.l SCREEN,a0
	add.l #160*58,a0
	move.l #92,d0
as
	clr.w 13*4+16(a0)
	clr.w 14*4+16(a0)
	clr.w 15*4+16(a0)
	clr.w 16*4+16(a0)
	clr.w 17*4+16(a0)
	clr.w 18*4+16(a0)
	add.l #160,a0
	dbf d0,as


	sub.l #4*4,d7
	cmp.l #0,d7
	bne da 	

	bra pocz

obr_objektu:				; podac kat*4 w d7
	lea CZYSTO(PC),a4
	movem.l (a4),d0-d6
	lea TABELA_SIN(PC),a0
	lea TABELA_COS(PC),a1
	lea OBJECT(PC),a6
	move.w (a6)+,d6		; linii
	movem.w (a6)+,d3-d5
	lea miejsce(pc),a5
	lea pery(pc),a4
	
	movem.w (a6)+,d0-d2
	bsr obrot_y			; obracaj wg osi y 
	bsr obrot_x 
	bsr obrot_z 
	bsr oblicz
	movem.w d0-d1,(a5)				

* drugi punkt

	movem.w (a6)+,d0-d2
	bsr obrot_y 
	bsr obrot_x 
	bsr obrot_z
	bsr oblicz
	movem.w d0-d1,4(a5)				

	movem.l a0-a1/d0-d5,-(sp)
	movem.w	(a5),d0-d3
	bsr draw
	movem.l (sp)+,a0-a1/d0-d5

loop
	movem.w (a6)+,d0-d2
	bsr obrot_y 
	bsr obrot_x
	bsr obrot_z 
	bsr oblicz
	movem.w d0-d1,8(a5)				

	movem.w (a6)+,d0-d2
	bsr obrot_y 
	bsr obrot_x
	bsr obrot_z 
	bsr oblicz
	movem.w d0-d1,12(a5)				

* rysowanie

	movem.l a0-a1/d0-d5,-(sp)
	movem.w	8(a5),d0-d3
	bsr draw
	movem.l (sp)+,a0-a1/d0-d5


	dbf d6,loop
	rts
ex	clr.w (sp)
	trap #1
	

obrot_z:    ; podac d7-kat,d0-d2 - punkty objektu, d3-5 -wokol punkty
			;		a0 -tab.sin, a1 - tab.cos	
	movem.l d3-d7/a3-a5,-(sp)

	move.l d2,a2		; z=z1
	sub.w d3,d0 		; d0=x2-x0; d0-d3 
	sub.w d4,d1  		; d1=y2-y0; d1-d4
	move.l (a0,d7.w),d2 ; d2=sin d7
	move.l (a1,d7.w),d5	; d5=COS D7
	move.l d0,d6		
	move.l d1,a5
	muls d5,d0			; d0=cos * x2-x0 => d5*d0
	muls d2,d1			; d1=sin * y2-y0 => d2*d1
	add.l d1,d0			; d0=d1+d0
	muls #10000,d3
	add.l  d3,d0			; d0=punkt X_obr

	move.l a5,d1
	muls d5,d1			; d0=cos * y2-y0 => d5*d1
	muls d2,d6			; d1=sin * x2-x0 => d2*d0
	sub.l d6,d1			; d0=d1-d0
	muls #10000,d4
	add   d4,d1			; d1=punkt y_obr
	move.l a2,d2

	move.l #10000,d3
	divs d3,d0
	divs d3,d1
	and.l #$0000ffff,d0
	and.l #$0000ffff,d1
	movem.l (sp)+,d3-d7/a3-a5

	
	rts
	
obrot_y: 
	move.l d1,a2		; z=z1
	movem.l d3-d7/a4-a6,-(sp)
	sub.l d3,d0 		; d0=x2-x0; d0-d3 
	sub.l d5,d2  		; d1=z2-z0; d2-d5
	move.l (a0,d7.w),d1 ; d1=sin d7
	move.l (a1,d7.w),d4	; d4=COS D7
	move.l d0,d6		
	move.l d2,a5
	muls d4,d0			; d0=cos * x2-x0 => d5*d0
	muls d1,d2			; d2=sin * y2-y0 => d2*d1
	sub.l d2,d0			; d0=d0-d2
	muls #10000,d3
	add.l  d3,d0			; d0=punkt X_obr
	move.l a5,d2
	muls d4,d2			; d0=cos * z2-z0 => d5*d1
	muls d1,d6			; d1=sin * x2-x0 => d2*d0
	add.l d6,d2			; d0=d2+d0
	muls #10000,d5
	add.l  d5,d2			; d2=punkt z_obr
	move.l a2,d1
	move.l #10000,d3
	divs d3,d0
	divs d3,d2
	and.l #$0000ffff,d0
	and.l #$0000ffff,d2
	movem.l (sp)+,a4-a6/d3-d7
	rts

obrot_x:
	move.l d0,a2		; x=x1
	movem.l d3-d7/a4-a6,-(sp)
	sub.w d4,d1			; d1=y2-y0; d1-d4 
	sub.w d5,d2  		; d2=z2-z0; d2-d5
	move.l (a0,d7.w),d0 ; d0=sin d7
	move.l (a1,d7.w),d3	; d3=COS D7
	move.l d1,d6		
	move.l d2,a5
	muls d3,d1			; d1=cos * y2-y0 => d3*d1
	muls d0,d2			; d2=sin * z2-z0 => d2*d1
	add.l d2,d1			; d1=d1+d2
	muls #10000,d4
	add.l  d4,d1			; d1=punkt y_obr
	move.l a5,d2
	muls d3,d2			; d2=cos * z2-z0 => d3*d2
	muls d0,d6			; d1=sin * x2-x0 => d6*d0
	sub.l d6,d2			; d0=d2-d0
	muls #10000,d5
	add.l  d5,d2			; d2=punkt z_obr
	move.l a2,d0
	move.l #10000,d3
	divs d3,d1
	divs d3,d2
	and.l #$0000ffff,d1
	and.l #$0000ffff,d2
	movem.l (sp)+,a4-a6/d3-d7
	rts
oblicz:
	; podac w d3-d4-d5 - perespektywe d6-d7 - punkty srodka
	movem.l d3-d7,-(sp)
	movem.w (a4),d3-d5 		; punkty pery
	move.l #1600,d6
	moveq.l #100,d7
	move.l d3,a2
	move.l d4,a3
	sub.w d0,d3			;d3=xv-x2
	sub.w d5,d2			;d2=z2-zv
	muls  d5,d3			;d5=zv*(xv-x2)
	divs d2,d3			;d3=(xv-x2)/z2-zv
	sub d1,d4			;d4=yv-y2
	muls d5,d4			;d4=zv*(yv-y2)  
	divs d2,d4			;d4=zv*(yv-y2)/z2-zv
	move.l a2,d0		;d3
	move.l a3,d1		;d4
	add.w d4,d1
	add.w d3,d0
	add.w d6,d0			; punkt x
	add.w d7,d1			; punkt y
	movem.l (sp)+,d3-d7
	rts	 


DRAW1:
	MOVE.L #319,D0                         	* X - poczatku
	MOVE.L #0,D1                           	* Y - poczatku
	MOVE.L D6,D2                          	* X - konca
	MOVE.L #199,D3			* Y - konca
	BSR SUB1				* skok do rys. 1-lini
E:
	DBF D6,DRAW1

draw:
	MOVE.L $44E,A0                         	* Adres ekranu
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
	BSR RYS.2
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
	BSR RYS
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

	SECTION DATA
SWITCH		dc.l 0	
SCREEN1		dc.l 0	
SCREEN		dc.l 0
CZYSTO:
	dcb.l 0,20
pery:
	dc.w 0,0,100

OBJECT:
	dc.w 10  			; ilosc punktow/2

	dc.w 0,0,0			; punkty wokol

	dc.w -20,20,-20		; po 3 punkty ( 1 linia )
	dc.w 20,20,-20		; po 3 punkty

	dc.w 20,20,-20		; po 3 punkty
	dc.w 20,-20,-20		; po 3 punkty

	dc.w 20,-20,-20		; po 3 punkty
	dc.w -20,-20,-20	; po 3 punkty

	dc.w -20,-20,-20	; po 3 punkty
	dc.w -20,20,-20		; po 3 punkty

	dc.w -20,20,-20		; po 3 punkty
	dc.w 0,0,10			; po 3 punkty


	dc.w -20,-20,-20	; po 3 punkty
	dc.w 0,0,10			; po 3 punkty

	dc.w 20,-20,-20		; po 3 punkty
	dc.w 0,0,10			; po 3 punkty

	dc.w 20,20,-20		; po 3 punkty
	dc.w 0,0,10			; po 3 punkty

	dc.w -20,-20,20		; po 3 punkty
	dc.w -20,-20,-20	; po 3 punkty

	dc.w 20,-20,20		; po 3 punkty
	dc.w 20,-20,-20		; po 3 punkty

	dc.w 20,20,20		; po 3 punkty
	dc.w 20,20,-20		; po 3 punkty

	dc.w -20,20,20		; po 3 punkty
	dc.w -20,20,-20		; po 3 punkty
*
	dc.w -20,-20,20		; po 3 punkty
	dc.w 20,20,-20		; po 3 punkty

	dc.w 20,-20,20		; po 3 punkty
	dc.w -20,20,-20		; po 3 punkty

	dc.w 20,20,20		; po 3 punkty
	dc.w -20,-20,-20	; po 3 punkty

	dc.w -20,20,20		; po 3 punkty
	dc.w 20,-20,-20		; po 3 punkty


miejsce:
	dcb.w 0,100

TABELA_SIN:
    dc.l 0
    dc.l 174
    dc.l 348
    dc.l 523
    dc.l 697
    dc.l 871
    dc.l 1045
    dc.l 1218
    dc.l 1391
    dc.l 1564
    dc.l 1736
    dc.l 1908
    dc.l 2079
    dc.l 2249
    dc.l 2419
    dc.l 2588
    dc.l 2756
    dc.l 2923
    dc.l 3090
    dc.l 3255
    dc.l 3420
    dc.l 3583
    dc.l 3746
    dc.l 3907
    dc.l 4067
    dc.l 4226
    dc.l 4383
    dc.l 4539
    dc.l 4694
    dc.l 4848
    dc.l 5000
    dc.l 5150
    dc.l 5299
    dc.l 5446
    dc.l 5591
    dc.l 5735
    dc.l 5877
    dc.l 6018
    dc.l 6156
    dc.l 6293
    dc.l 6427
    dc.l 6560
    dc.l 6691
    dc.l 6819
    dc.l 6946
    dc.l 7071
    dc.l 7193
    dc.l 7313
    dc.l 7431
    dc.l 7547
    dc.l 7660
    dc.l 7771
    dc.l 7880
    dc.l 7986
    dc.l 8090
    dc.l 8191
    dc.l 8290
    dc.l 8386
    dc.l 8480
    dc.l 8571
    dc.l 8660
    dc.l 8746
    dc.l 8829
    dc.l 8910
    dc.l 8987
    dc.l 9063
    dc.l 9135
    dc.l 9205
    dc.l 9271
    dc.l 9335
    dc.l 9396
    dc.l 9455
    dc.l 9510
    dc.l 9563
    dc.l 9612
    dc.l 9659
    dc.l 9702
    dc.l 9743
    dc.l 9781
    dc.l 9816
    dc.l 9848
    dc.l 9876
    dc.l 9902
    dc.l 9925
    dc.l 9945
    dc.l 9961
    dc.l 9975
    dc.l 9986
    dc.l 9993
    dc.l 9998
    dc.l 10000
    dc.l 9998
    dc.l 9993
    dc.l 9986
    dc.l 9975
    dc.l 9961
    dc.l 9945
    dc.l 9925
    dc.l 9902
    dc.l 9876
    dc.l 9848
    dc.l 9816
    dc.l 9781
    dc.l 9743
    dc.l 9702
    dc.l 9659
    dc.l 9612
    dc.l 9563
    dc.l 9510
    dc.l 9455
    dc.l 9396
    dc.l 9335
    dc.l 9271
    dc.l 9205
    dc.l 9135
    dc.l 9063
    dc.l 8987
    dc.l 8910
    dc.l 8829
    dc.l 8746
    dc.l 8660
    dc.l 8571
    dc.l 8480
    dc.l 8386
    dc.l 8290
    dc.l 8191
    dc.l 8090
    dc.l 7986
    dc.l 7880
    dc.l 7771
    dc.l 7660
    dc.l 7547
    dc.l 7431
    dc.l 7313
    dc.l 7193
    dc.l 7071
    dc.l 6946
    dc.l 6819
    dc.l 6691
    dc.l 6560
    dc.l 6427
    dc.l 6293
    dc.l 6156
    dc.l 6018
    dc.l 5877
    dc.l 5735
    dc.l 5591
    dc.l 5446
    dc.l 5299
    dc.l 5150
    dc.l 5000
    dc.l 4848
    dc.l 4694
    dc.l 4539
    dc.l 4383
    dc.l 4226
    dc.l 4067
    dc.l 3907
    dc.l 3746
    dc.l 3583
    dc.l 3420
    dc.l 3255
    dc.l 3090
    dc.l 2923
    dc.l 2756
    dc.l 2588
    dc.l 2419
    dc.l 2249
    dc.l 2079
    dc.l 1908
    dc.l 1736
    dc.l 1564
    dc.l 1391
    dc.l 1218
    dc.l 1045
    dc.l 871
    dc.l 697
    dc.l 523
    dc.l 348
    dc.l 174
    dc.l 0
    dc.l -175
    dc.l -349
    dc.l -524
    dc.l -698
    dc.l -872
    dc.l -1046
    dc.l -1219
    dc.l -1392
    dc.l -1565
    dc.l -1737
    dc.l -1909
    dc.l -2080
    dc.l -2250
    dc.l -2420
    dc.l -2589
    dc.l -2757
    dc.l -2924
    dc.l -3091
    dc.l -3256
    dc.l -3421
    dc.l -3584
    dc.l -3747
    dc.l -3908
    dc.l -4068
    dc.l -4227
    dc.l -4384
    dc.l -4540
    dc.l -4695
    dc.l -4849
    dc.l -5000
    dc.l -5151
    dc.l -5300
    dc.l -5447
    dc.l -5592
    dc.l -5736
    dc.l -5878
    dc.l -6019
    dc.l -6157
    dc.l -6294
    dc.l -6428
    dc.l -6561
    dc.l -6692
    dc.l -6820
    dc.l -6947
    dc.l -7072
    dc.l -7194
    dc.l -7314
    dc.l -7432
    dc.l -7548
    dc.l -7661
    dc.l -7772
    dc.l -7881
    dc.l -7987
    dc.l -8091
    dc.l -8192
    dc.l -8291
    dc.l -8387
    dc.l -8481
    dc.l -8572
    dc.l -8661
    dc.l -8747
    dc.l -8830
    dc.l -8911
    dc.l -8988
    dc.l -9064
    dc.l -9136
    dc.l -9206
    dc.l -9272
    dc.l -9336
    dc.l -9397
    dc.l -9456
    dc.l -9511
    dc.l -9564
    dc.l -9613
    dc.l -9660
    dc.l -9703
    dc.l -9744
    dc.l -9782
    dc.l -9817
    dc.l -9849
    dc.l -9877
    dc.l -9903
    dc.l -9926
    dc.l -9946
    dc.l -9962
    dc.l -9976
    dc.l -9987
    dc.l -9994
    dc.l -9999
    dc.l -10000
    dc.l -9999
    dc.l -9994
    dc.l -9987
    dc.l -9976
    dc.l -9962
    dc.l -9946
    dc.l -9926
    dc.l -9903
    dc.l -9877
    dc.l -9849
    dc.l -9817
    dc.l -9782
    dc.l -9744
    dc.l -9703
    dc.l -9660
    dc.l -9613
    dc.l -9564
    dc.l -9511
    dc.l -9456
    dc.l -9397
    dc.l -9336
    dc.l -9272
    dc.l -9206
    dc.l -9136
    dc.l -9064
    dc.l -8988
    dc.l -8911
    dc.l -8830
    dc.l -8747
    dc.l -8661
    dc.l -8572
    dc.l -8481
    dc.l -8387
    dc.l -8291
    dc.l -8192
    dc.l -8091
    dc.l -7987
    dc.l -7881
    dc.l -7772
    dc.l -7661
    dc.l -7548
    dc.l -7432
    dc.l -7314
    dc.l -7194
    dc.l -7072
    dc.l -6947
    dc.l -6820
    dc.l -6692
    dc.l -6561
    dc.l -6428
    dc.l -6294
    dc.l -6157
    dc.l -6019
    dc.l -5878
    dc.l -5736
    dc.l -5592
    dc.l -5447
    dc.l -5300
    dc.l -5151
    dc.l -5000
    dc.l -4849
    dc.l -4695
    dc.l -4540
    dc.l -4384
    dc.l -4227
    dc.l -4068
    dc.l -3908
    dc.l -3747
    dc.l -3584
    dc.l -3421
    dc.l -3256
    dc.l -3091
    dc.l -2924
    dc.l -2757
    dc.l -2589
    dc.l -2420
    dc.l -2250
    dc.l -2080
    dc.l -1909
    dc.l -1737
    dc.l -1565
    dc.l -1392
    dc.l -1219
    dc.l -1046
    dc.l -872
    dc.l -698
    dc.l -524
    dc.l -349
    dc.l -175
    dc.l 0
	even
TABELA_COS:
    dc.l 10000
    dc.l 9998
    dc.l 9993
    dc.l 9986
    dc.l 9975
    dc.l 9961
    dc.l 9945
    dc.l 9925
    dc.l 9902
    dc.l 9876
    dc.l 9848
    dc.l 9816
    dc.l 9781
    dc.l 9743
    dc.l 9702
    dc.l 9659
    dc.l 9612
    dc.l 9563
    dc.l 9510
    dc.l 9455
    dc.l 9396
    dc.l 9335
    dc.l 9271
    dc.l 9205
    dc.l 9135
    dc.l 9063
    dc.l 8987
    dc.l 8910
    dc.l 8829
    dc.l 8746
    dc.l 8660
    dc.l 8571
    dc.l 8480
    dc.l 8386
    dc.l 8290
    dc.l 8191
    dc.l 8090
    dc.l 7986
    dc.l 7880
    dc.l 7771
    dc.l 7660
    dc.l 7547
    dc.l 7431
    dc.l 7313
    dc.l 7193
    dc.l 7071
    dc.l 6946
    dc.l 6819
    dc.l 6691
    dc.l 6560
    dc.l 6427
    dc.l 6293
    dc.l 6156
    dc.l 6018
    dc.l 5877
    dc.l 5735
    dc.l 5591
    dc.l 5446
    dc.l 5299
    dc.l 5150
    dc.l 5000
    dc.l 4848
    dc.l 4694
    dc.l 4539
    dc.l 4383
    dc.l 4226
    dc.l 4067
    dc.l 3907
    dc.l 3746
    dc.l 3583
    dc.l 3420
    dc.l 3255
    dc.l 3090
    dc.l 2923
    dc.l 2756
    dc.l 2588
    dc.l 2419
    dc.l 2249
    dc.l 2079
    dc.l 1908
    dc.l 1736
    dc.l 1564
    dc.l 1391
    dc.l 1218
    dc.l 1045
    dc.l 871
    dc.l 697
    dc.l 523
    dc.l 348
    dc.l 174
    dc.l 0
    dc.l -175
    dc.l -349
    dc.l -524
    dc.l -698
    dc.l -872
    dc.l -1046
    dc.l -1219
    dc.l -1392
    dc.l -1565
    dc.l -1737
    dc.l -1909
    dc.l -2080
    dc.l -2250
    dc.l -2420
    dc.l -2589
    dc.l -2757
    dc.l -2924
    dc.l -3091
    dc.l -3256
    dc.l -3421
    dc.l -3584
    dc.l -3747
    dc.l -3908
    dc.l -4068
    dc.l -4227
    dc.l -4384
    dc.l -4540
    dc.l -4695
    dc.l -4849
    dc.l -5000
    dc.l -5151
    dc.l -5300
    dc.l -5447
    dc.l -5592
    dc.l -5736
    dc.l -5878
    dc.l -6019
    dc.l -6157
    dc.l -6294
    dc.l -6428
    dc.l -6561
    dc.l -6692
    dc.l -6820
    dc.l -6947
    dc.l -7072
    dc.l -7194
    dc.l -7314
    dc.l -7432
    dc.l -7548
    dc.l -7661
    dc.l -7772
    dc.l -7881
    dc.l -7987
    dc.l -8091
    dc.l -8192
    dc.l -8291
    dc.l -8387
    dc.l -8481
    dc.l -8572
    dc.l -8661
    dc.l -8747
    dc.l -8830
    dc.l -8911
    dc.l -8988
    dc.l -9064
    dc.l -9136
    dc.l -9206
    dc.l -9272
    dc.l -9336
    dc.l -9397
    dc.l -9456
    dc.l -9511
    dc.l -9564
    dc.l -9613
    dc.l -9660
    dc.l -9703
    dc.l -9744
    dc.l -9782
    dc.l -9817
    dc.l -9849
    dc.l -9877
    dc.l -9903
    dc.l -9926
    dc.l -9946
    dc.l -9962
    dc.l -9976
    dc.l -9987
    dc.l -9994
    dc.l -9999
    dc.l -10000
    dc.l -9999
    dc.l -9994
    dc.l -9987
    dc.l -9976
    dc.l -9962
    dc.l -9946
    dc.l -9926
    dc.l -9903
    dc.l -9877
    dc.l -9849
    dc.l -9817
    dc.l -9782
    dc.l -9744
    dc.l -9703
    dc.l -9660
    dc.l -9613
    dc.l -9564
    dc.l -9511
    dc.l -9456
    dc.l -9397
    dc.l -9336
    dc.l -9272
    dc.l -9206
    dc.l -9136
    dc.l -9064
    dc.l -8988
    dc.l -8911
    dc.l -8830
    dc.l -8747
    dc.l -8661
    dc.l -8572
    dc.l -8481
    dc.l -8387
    dc.l -8291
    dc.l -8192
    dc.l -8091
    dc.l -7987
    dc.l -7881
    dc.l -7772
    dc.l -7661
    dc.l -7548
    dc.l -7432
    dc.l -7314
    dc.l -7194
    dc.l -7072
    dc.l -6947
    dc.l -6820
    dc.l -6692
    dc.l -6561
    dc.l -6428
    dc.l -6294
    dc.l -6157
    dc.l -6019
    dc.l -5878
    dc.l -5736
    dc.l -5592
    dc.l -5447
    dc.l -5300
    dc.l -5151
    dc.l -5000
    dc.l -4849
    dc.l -4695
    dc.l -4540
    dc.l -4384
    dc.l -4227
    dc.l -4068
    dc.l -3908
    dc.l -3747
    dc.l -3584
    dc.l -3421
    dc.l -3256
    dc.l -3091
    dc.l -2924
    dc.l -2757
    dc.l -2589
    dc.l -2420
    dc.l -2250
    dc.l -2080
    dc.l -1909
    dc.l -1737
    dc.l -1565
    dc.l -1392
    dc.l -1219
    dc.l -1046
    dc.l -872
    dc.l -698
    dc.l -524
    dc.l -349
    dc.l -175
    dc.l 0
    dc.l 174
    dc.l 348
    dc.l 523
    dc.l 697
    dc.l 871
    dc.l 1045
    dc.l 1218
    dc.l 1391
    dc.l 1564
    dc.l 1736
    dc.l 1908
    dc.l 2079
    dc.l 2249
    dc.l 2419
    dc.l 2588
    dc.l 2756
    dc.l 2923
    dc.l 3090
    dc.l 3255
    dc.l 3420
    dc.l 3583
    dc.l 3746
    dc.l 3907
    dc.l 4067
    dc.l 4226
    dc.l 4383
    dc.l 4539
    dc.l 4694
    dc.l 4848
    dc.l 5000
    dc.l 5150
    dc.l 5299
    dc.l 5446
    dc.l 5591
    dc.l 5735
    dc.l 5877
    dc.l 6018
    dc.l 6156
    dc.l 6293
    dc.l 6427
    dc.l 6560
    dc.l 6691
    dc.l 6819
    dc.l 6946
    dc.l 7071
    dc.l 7193
    dc.l 7313
    dc.l 7431
    dc.l 7547
    dc.l 7660
    dc.l 7771
    dc.l 7880
    dc.l 7986
    dc.l 8090
    dc.l 8191
    dc.l 8290
    dc.l 8386
    dc.l 8480
    dc.l 8571
    dc.l 8660
    dc.l 8746
    dc.l 8829
    dc.l 8910
    dc.l 8987
    dc.l 9063
    dc.l 9135
    dc.l 9205
    dc.l 9271
    dc.l 9335
    dc.l 9396
    dc.l 9455
    dc.l 9510
    dc.l 9563
    dc.l 9612
    dc.l 9659
    dc.l 9702
    dc.l 9743
    dc.l 9781
    dc.l 9816
    dc.l 9848
    dc.l 9876
    dc.l 9902
    dc.l 9925
    dc.l 9945
    dc.l 9961
    dc.l 9975
    dc.l 9986
    dc.l 9993
    dc.l 9998
    dc.l 10000
	even	