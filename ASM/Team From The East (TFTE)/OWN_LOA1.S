; (c) The Voice 5
; TFTE
**************************************
* pewien kawalek kodu z pliku DISK.s *
**************************************

	move.w #$20,-(sp)
	trap #1
	addq.l #2,sp
	  MOVEQ.L   #0,D0					; musi byc
      MOVE.W    #2,D1					; ile sek
      LEA       $40000,A0 				; adres
      MOVE.W    #7,D2 					; pocz sek
      MOVE.W    #1,D3 					; pocz strona
      MOVE.W    #$22,D4 				; pocz trak	
	  jsr READ_SEC
	illegal

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
      CMPI.W    #$B,D2
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
