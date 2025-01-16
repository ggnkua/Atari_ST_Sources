; (c) The Voice 5
; TFTE
***************************************************
* procedura do czytania z dysku gdy gra modul TCB *
***************************************************
* Dziala tylko na dysku formatowanym pod Deskiem. *
* Nie chce mi sie jej opisywac,a takze jej popra- *
* wiac, poniewaz juz nie chce mi sie nic robic na *
* ST.											  *
***************************************************
* Na koncu nalezy podac nazwe pliku do wladowania.*
***************************************************
* Laduje pod $40000 (mozna zmienic)				  *
***************************************************
* Proc. do czytania sekt. wycielem, juz nie	      *
* pamietam skad.								  *
***************************************************
* Coded by STRych/TFTE							  *
* Jezeli uzyjesz gdzies tej procedury to napisz   *
* choc, ze STRych ma w tym swoj udzial.			  *
***************************************************


	move.l 	a0,adresik	; LDAUJE PO $40000
	move.w #$20,-(sp)	; NAZWA -DUZYMI LITERAMI
	trap #1				; DYSK 728 KB (FORMAT POD TOS)
	addq.l #2,sp
	move #1,-(sp)
	move #1,-(sp)
	move #0,-(sp)
	move #3,-(sp)
	move #0,-(sp)
	clr.l -(sp)
	pea FAT
	move #8,-(sp)
	trap #14
	add.l #20,sp

	; tu podprogram (bsr my_txt)
my_txt
	movem.l d0-d2,STRycho
	jsr nazwa
	jsr txt_czytaj
	cmp.b #$ff,d2
	beq .nie_ma

	move.l d1,d4	;trak
	move.l d0,d2	; sek

	move.l d5,d1
	move.l d5,d0
	
	lsr.l #8,d1

	and.l #$ff000000,d0
	lsr.l #8,d0
	lsr.l #8,d0
	lsr.l #8,d0
	
	lsl.l #8,d5
	and.l #$00ff0000,d5
	and.l #$0000ff00,d1

	add.l d5,d1		
	add.l d0,d1		
	divs #512,d1
	move.l d1,d5
	and.l #$ffff0000,d5
	cmp.l #0,d5
	beq .tylko_1
	addq.w #2,d1
.tylko_1:	
	and.l #$ffff,d1
	
	  MOVEQ.L   #0,D0					; musi byc
      LEA       $40000,A0 				; adres (tu ladujemy)
	  jsr READ_SEC

.nie_ma
	movem.l STRycho,d0-d2
	rts

txt_czytaj				; d0=sektor
	mulu #2,d0
	add.l #15,d0
	moveq.l #9,d1		;dzeilni
	divs d1,d0			;d0= sek,track
	move.l d0,d1
	lsr.l #8,d0
	lsr.l #8,d0			; d0=sek

	cmp.b #0,d0
	bne tu
	moveq.l #9,d0
	subq.w #1,d1
tu
	and.l #$ffff,d1
	divs #2,d1			; track
	move.l d1,d3
	lsr.l #8,d3	
	lsr.l #8,d3		    ;strona
	and.l #$ff,d1
	rts
nazwa:
	lea name,a0
	lea FAT,a1
	move.l (a0),d0
	move.l 4(a0),d1
.loop
	move.l (a1),d2
	move.l 4(a1),d3
	cmp.l #$ffffffff,d2
	beq .end
	cmp.l d2,d0
	bne .nie
	cmp.l d1,d3
	bne .nie
	moveq.l #0,d0	
	moveq.l #0,d5	
	move.w 26(a1),d0		; sektor
	move.l 28(a1),d5		; dlugosc
	move.l d0,d1
	and.w #$ff,d0
	lsr.l #8,d1
	lsl.l #8,d0
	add.l d1,d0
	bra .end	
.nie
	add.l #32,a1	
	bra .loop
.end
	rts

READ_SEC:
      MOVE.B    #$E,-$7800.W
      MOVE.B    -$7800.W,D5 
      AND.B     #-8,D5
      OR.B      #5,D5 
      EOR.B     D3,D5 
      MOVE.B    D5,-$77FE.W 
      LEA       $FFFF8604.W,A1 
      MOVE.W    #$86,2(A1) 
      MOVE.W    D4,(A1) 
      MOVE.W    #$80,2(A1) 
      MOVE.W    #$13,(A1) 
L0007:BTST      #5,-$5FF.W
      BNE.B     L0007 
L0008:BSR       L0012 
      CMP.W     D0,D1 
      BNE.B     L0008 
	  rts

	**************************************
	* a0 - adrees						 *
	* d0/d1 - ilosc sek
	* d2 - sek
	* d4 - rtack
	* 
L0012:move.l 	a0,adresik
      lea 		adresik(pc),a0
      MOVE.B    3(A0),9(A1) 
      MOVE.B    2(A0),7(A1) 
      MOVE.B    1(A0),5(A1)
	  move.l 	adresik,a0
      MOVE.W    #$90,2(A1) 
      MOVE.W    #$190,2(A1)
      MOVE.W    #$90,2(A1) 
      MOVE.W    #1,(A1) 
      MOVE.W    #$82,2(A1) 
      MOVE.W    D4,(A1) 
      MOVE.W    #$84,2(A1) 
      MOVE.W    D2,(A1) 
      MOVE.W    #$80,2(A1) 
      MOVE.W    #$80,(A1) 
L0013:BTST      #5,-$5FF.W
      BNE.B     L0013 
      LEA       512(A0),A0
      ADDQ.W    #1,D0 
      ADDQ.W    #1,D2 
      CMPI.W    #$a,D2
      BNE.B     L0015 
      MOVEQ     #1,D2 
      MOVE.B    #$E,-$7800.W
      MOVE.B    -$7800.W,D5 
      EORI.B    #1,D5 
      MOVE.B    D5,-$77FE.W 
      ADDQ.W    #1,D3 
      CMPI.W    #2,D3 
      BNE.B     L0015 
      MOVEQ     #0,D3 
      ADDQ.W    #1,D4 
      MOVE.W    #$80,2(A1) 
      MOVE.W    #$43,(A1) 
L0014:BTST      #5,-$5FF.W
      BNE.B     L0014 
L0015:RTS 
	even
adresik:
	dc.l 0,0
name
	dc.b "FIX     .PRG"  	
	even
STRycho:		ds.l 10
FAT:
	ds.b 1024
	dcb.b $ff,32
      