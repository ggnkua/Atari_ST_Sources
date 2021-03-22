MODULE MakeUpper;

(*$E MOS *)
IMPORT MoreIO;
FROM InOut IMPORT WriteLn, Write, WriteString, WriteHex, OpenOutput;
FROM Strings IMPORT (*Compare,*) Relation;
FROM SYSTEM IMPORT ASSEMBLER;

(*$L-*)
PROCEDURE Compare (REF str0,str1: ARRAY OF CHAR): Relation;
  BEGIN
    ASSEMBLER
        MOVE    -(A3),D0
        MOVE.L  -(A3),A0
        MOVE.W  -(A3),D1
        MOVE.L  -(A3),A1
        LEA     tab(PC),A2
        CLR.W   D2

l       MOVE.B  (A0)+,D2
        BEQ     equ1
        CMP.B   (A1)+,D2
        BNE     ne
        SUBQ    #1,D0
        BCS     e
        DBRA    D1,l

        ; str1 zu Ende, str0 aber nicht
        TST.B   (A0)+
        BEQ     equ0
        BRA     hi

equ1    ; str0 zu Ende, str1 prfen
        TST.B   (A1)+
        BEQ     equ0
        BRA     low

ne      MOVE.B  0(A2,D2.W),D1
        MOVE.B  -(A1),D0
        CMP.B   0(A2,D0.W),D1
        BHI     hi
        BCS     low
        CMP.B   D0,D2   ; wenn Umlaute gleich, dann ASCII-Wert vergleichen
        BHI     hi
        BRA     low

e       ; str0 zu Ende, str1 prfen
        TST     D1
        BEQ     equ0
        TST.B   (A1)+
        BNE     low

equ0    MOVE    #equal,(A3)+
        RTS
hi      MOVE    #less,(A3)+
        RTS
low     MOVE    #greater,(A3)+
        RTS

tab     DC.B    $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
        DC.B    $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F
        DC.B    $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F
        DC.B    $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F
        DC.B    $40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F
        DC.B    $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D,$5E,$5F
        DC.B    $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$6C,$6D,$6E,$6F
        DC.B    $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7A,$7B,$7C,$7D,$7E,$7F
        DC.B    'C','u','e','a','a','a','a','c','e','e','e','i','i','i','A','A'
        DC.B    'E','a','A','o','o','o','u','u','y','O','U',$9B,$9C,$9D,'s',$9F
        DC.B    'a','i','o','u','n','N','a','o',$A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF
        DC.B    'a','o','O','o','o','O','A','A','O',$B9,$BA,$BB,$BC,$BD,$BE,$BF
        DC.B    'i','I',$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF
        DC.B    $D0,$D1,$D2,$D3,$D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF
        DC.B    $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7,$E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF
        DC.B    $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF
    END
  END Compare;

VAR c1, c2: CHAR;
    n: CARDINAL;
    tb: ARRAY CHAR OF BOOLEAN;
    tc: ARRAY CHAR OF CHAR;

BEGIN
  IF Compare ('a','b') # less THEN HALT END;
  IF Compare ('a','„') # less THEN HALT END;
  IF Compare ('„','b') # less THEN HALT END;
  
  FOR c1:= 0C TO 377C DO
    tb[c1]:= TRUE;
    tc[c1]:= c1
  END;
  FOR n:= 0 TO 255 DO
    c2:= 377C;
    FOR c1:= 0C TO 377C DO
      IF tb[c1] & (Compare (c1, c2) = less) THEN
        c2:= c1
      END;
    END;
    tb[c2]:= FALSE;
    (*
      WriteHex (n, 3);
      Write (' ');
    *)
    IF n >= 64 THEN
      Write (c2)
    END
  END;
  WriteLn;
END MakeUpper.
