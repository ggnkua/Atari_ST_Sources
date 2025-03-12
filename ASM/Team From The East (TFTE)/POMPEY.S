; The Voice 5
; TFTE
*********************************
* Procedura do depaku danych    *
* spakowanych POMPEY PAKEREM	*
*********************************
* Ripped by STRych				*
*********************************

* wyciete z POMPEY PAKERA		*

	lea prog,a4		 ; wystarczy jedynie podac adres spak. danych
					 ; rozpakowanie dane znajdziesz pod tym samym 
					 ; adresem.
					 ; Pompey paker jest najlepszym, znanym mi, pakerem 
					 ; na ST.
					 ; 
POMPEY:					;w a4 podaj adres pliku spakowanego pompeyem 1.5
      MOVEA.L   A4,A0 
      MOVEA.L   A4,A2 
      ADDQ.L    #4,A2 
      MOVE.L    -(A0),D6
      MOVE.L    -(A0),D2
      SUBA.L    D2,A2 
      MOVEA.L   A2,A4 
      ADDA.L    D6,A2 
      MOVEQ     #0,D0 
      MOVEA.L   #$FF8240,A6 
      MOVE.W    (A6),D7 
L003F:MOVE.B    -(A0),D0
      BEQ.B     L003F 
L0040:MOVEQ     #0,D2 
      BSR       L004D 
      BCS.B     L0043 
      MOVE.B    -(A0),D2
L0041:MOVE.B    D2,-(A2)
      BRA.B     L0045 
L0042:MOVEQ     #$F,D4
      MOVEQ     #2,D3 
      BSR       L0050 
      BNE.B     L004B 
      MOVE.W    D4,D2 
      BRA.B     L0041 
L0043:BSR.B     L004D 
      BCC.B     L0047 
      BSR.B     L004D 
      BCC.B     L0042 
      BSR.B     L004D 
      BCS.B     L0044 
      MOVEQ     #2,D1 
      BSR       L0053 
      EXG       D2,D1 
      ADDQ.W    #1,D2 
      BSET      D1,D2 
      BRA.B     L0041 
L0044:BSR.B     L004D 
      BCS.B     L0046 
      MOVEQ     #$F,D4
      MOVE.W    #3,D3 
      BSR.B     L0050 
      BNE.B     L004B 
      MOVE.B    (A2),-(A2)
L0045:
*      MOVE.W    D7,(A6) 
*	  NEG.W     (A6)
	  move.W     d0,(A6)

      CMPA.L    A2,A4 
      BLT.B     L0040 
      MOVE.W    D7,(A6) 
      RTS 
L0046:MOVEQ     #4,D3 
      BRA.B     L004A 
L0047:BSR.B     L004D 
      BCS.B     L0057 
      MOVEQ     #1,D1 
L0048:LSR.B     #1,D0 
      BNE.B     L0049 
      MOVE.B    -(A0),D0
      ROXR.B    #1,D0 
L0049:ADDX.W    D2,D2 
      DBF       D1,L0048
      MOVE.W    D2,D1 
      BEQ.B     L0056 
      ADDQ.W    #1,D1 
      ADD.W     D1,D1 
      SUBQ.W    #1,D1 
      BSR.B     L0053 
      MOVE.W    D2,D3 
L004A:BSR.B     L004F 
L004B:MOVEA.L   A2,A1 
      ADDA.L    D2,A1 
L004C:MOVE.B    -(A1),-(A2) 
      DBF       D3,L004C
      BRA.B     L0045 
L004D:LSR.B     #1,D0 
      BNE.B     L004E 
      MOVE.B    -(A0),D0
      ROXR.B    #1,D0 
L004E:RTS 

L004F:MOVEQ     #0,D4 
L0050:MOVEQ     #1,D1 
      MOVEQ     #0,D2 
L0051:LSR.B     #1,D0 
      BNE.B     L0052 
      MOVE.B    -(A0),D0
      ROXR.B    #1,D0 
L0052:ADDX.W    D2,D2 
      DBF       D1,L0051
      MOVE.W    D2,D1 
      ADDQ.W    #1,D1 
      LSL.W     #2,D1 
      SUBQ.W    #1,D1 
      EOR.B     D1,D4 
      BNE.B     L0053 
      RTS 
      MOVEQ     #7,D1 
L0053:MOVEQ     #0,D2 
L0054:LSR.B     #1,D0 
      BNE.B     L0055 
      MOVE.B    -(A0),D0
      ROXR.B    #1,D0 
L0055:ADDX.W    D2,D2 
      DBF       D1,L0054
      RTS 
L0056:BSR.B     L004F 
      MOVE.W    D2,D3 
      MOVEQ     #1,D2 
      BRA.B     L004B 
L0057:MOVEQ     #1,D3 
      MOVE.B    -(A0),D2
      BRA.B     L004B 
L0058:BSR       L005C 
      MOVEM.L   A0/D0-D1,-(A7)
      MOVEA.L   #0,A0 
L0059 EQU       *-4 
      MOVE.L    #$7D0,D1
      MOVEQ     #0,D0 
L005A:MOVE.L    D0,(A0)+
      MOVE.L    D0,(A0)+
      MOVE.L    D0,(A0)+
      MOVE.L    D0,(A0)+
      DBF       D1,L005A
      BSR       L005B 
      DC.B      'L',$DF,$01,$03,'Nu'
L005B:DC.B      'H',$E7,$E0,$F0,$A0,$00,' h'
      DC.B      $00,$08,'BP',$A0,$09,'L',$DF
      DC.B      $0F,$07,'Nu'
L005C:DC.B      'H',$E7 
      ASR       10(A0,A2.W) 
      MOVEM.L   (A7)+,A0-A3/D0-D2 
      RTS 
	even
prog
	incbin abc.dat	 ; dane spakowanie pompeyem 1.5