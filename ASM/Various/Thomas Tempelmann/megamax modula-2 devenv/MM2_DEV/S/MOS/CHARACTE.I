IMPLEMENTATION MODULE Characters;
(*$Y+,C-,L-,N+*)

FROM SYSTEM IMPORT ASSEMBLER;

PROCEDURE isASCII7 (c: CHAR): BOOLEAN;
  BEGIN
    ASSEMBLER
        TST.W   -(A3)
        SPL     D0
        ANDI    #1,D0
        MOVE    D0,(A3)+
    END
  END isASCII7;

PROCEDURE isLetter (c: CHAR): BOOLEAN;
  BEGIN
    ASSEMBLER
        SUBQ.L  #1,A3
        MOVE.B  -(A3),D0
        CMPI.B  #32,D0
        BCS     n
        CMPI.B  #127,D0
        BEQ     n
        MOVE    #1,(A3)+
        RTS
     n: CLR     (A3)+
    END
  END isLetter;

PROCEDURE isControl (c: CHAR): BOOLEAN;
  BEGIN
    ASSEMBLER
        SUBQ.L  #1,A3
        MOVE.B  -(A3),D0
        CMPI.B  #32,D0
        BCS     y
        CMPI.B  #127,D0
        BEQ     y
        CLR     (A3)+
        RTS
     y: MOVE    #1,(A3)+
    END
  END isControl;

PROCEDURE isDigit (c: CHAR): BOOLEAN;
  BEGIN
    ASSEMBLER
        SUBQ.L  #1,A3
        MOVE.B  -(A3),D0
        CMPI.B  #'0',D0
        BCS     n
        CMPI.B  #'9',D0
        BHI     n
        MOVE    #1,(A3)+
        RTS
     n: CLR     (A3)+
    END
  END isDigit;

PROCEDURE isNum (c: CHAR): BOOLEAN;
  BEGIN
    ASSEMBLER
        JMP     isDigit
    END
  END isNum;

PROCEDURE isHexDigit (c: CHAR): BOOLEAN;
  BEGIN
    ASSEMBLER
        SUBQ.L  #1,A3
        MOVE.B  -(A3),D0
        CMPI.B  #'0',D0
        BCS     n
        CMPI.B  #'9',D0
        BLS     y
        CMPI.B  #'A',D0
        BCS     n
        CMPI.B  #'Z',D0
        BLS     y
        CMPI.B  #'a',D0
        BCS     n
        CMPI.B  #'z',D0
        BHI     n
     y: MOVE    #1,(A3)+
        RTS
     n: CLR     (A3)+
    END
  END isHexDigit;

PROCEDURE isAlpha (c: CHAR): BOOLEAN;
  BEGIN
    ASSEMBLER
        SUBQ.L  #1,A3
        MOVE.B  -(A3),D0
        BMI     s
        CMPI.B  #'A',D0
        BCS     n
        CMPI.B  #'z',D0
        BHI     n
        CMPI.B  #'Z',D0
        BLS     y
        CMPI.B  #'a',D0
        BCS     n
     y: MOVE    #1,(A3)+
        RTS
     s: CMPI.B  #$9A,D0
        BLS     y
        CMPI.B  #$9E,D0
        BEQ     y
        CMPI.B  #$A0,D0
        BCS     n
        CMPI.B  #$A7,D0
        BLS     y
        CMPI.B  #$B0,D0
        BCS     n
        CMPI.B  #$B8,D0
        BLS     y
        CMPI.B  #$C1,D0
        BHI     n
        CMPI.B  #$C0,D0
        BCC     y
     n: CLR     (A3)+
    END
  END isAlpha;

PROCEDURE isAlphaNum (c: CHAR): BOOLEAN;
  BEGIN
    ASSEMBLER
        SUBQ.L  #1,A3
        MOVE.B  -(A3),D0
        BMI     s
        CMPI.B  #'0',D0
        BCS     n
        CMPI.B  #'9',D0
        BLS     y
        CMPI.B  #'A',D0
        BCS     n
        CMPI.B  #'z',D0
        BHI     n
        CMPI.B  #'Z',D0
        BLS     y
        CMPI.B  #'a',D0
        BCS     n
     y: MOVE    #1,(A3)+
        RTS
     s: CMPI.B  #$9A,D0
        BLS     y
        CMPI.B  #$9E,D0
        BEQ     y
        CMPI.B  #$A0,D0
        BCS     n
        CMPI.B  #$A7,D0
        BLS     y
        CMPI.B  #$B0,D0
        BCS     n
        CMPI.B  #$B8,D0
        BLS     y
        CMPI.B  #$C1,D0
        BHI     n
        CMPI.B  #$C0,D0
        BCC     y
     n: CLR     (A3)+
    END
  END isAlphaNum;

PROCEDURE isSpace (c: CHAR): BOOLEAN;
  BEGIN
    ASSEMBLER
        SUBQ.L  #1,A3
        MOVE.B  -(A3),D0
        CMPI.B  #32,D0
        BEQ     y
        BHI     n
        CMPI.B  #9,D0
        BCS     n
        CMPI.B  #13,D0
        BHI     n
     y: MOVE    #1,(A3)+
        RTS
     n: CLR     (A3)+
    END
  END isSpace;

PROCEDURE isGreek (c: CHAR): BOOLEAN;
  BEGIN
    ASSEMBLER
        SUBQ.L  #1,A3
        MOVE.B  -(A3),D0
        CMPI.B  #$E0,D0
        BCS     n
        CMPI.B  #$F0,D0
        BCC     n
        MOVE    #1,(A3)+
        RTS
     n: CLR     (A3)+
    END
  END isGreek;

PROCEDURE isUpper (c: CHAR): BOOLEAN;
  BEGIN
   ASSEMBLER
        SUBQ.L  #1,A3
        CLR     D0
        MOVE.B  -(A3),D0
        LEA     tbl(PC),A0
        MOVE.B  0(A0,D0.W),D0
        MOVE    D0,(A3)+
        RTS

    tbl DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        DC.B  1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1
        DC.B  1,0,1,0,0,0,0,0,0,1,1,0,0,0,0,0
        DC.B  0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,1,0,0,1,1,1,1,0,0,0,0,0,0,0
        DC.B  0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    END
  END isUpper;


PROCEDURE isLower (c: CHAR): BOOLEAN;
  BEGIN
   ASSEMBLER
        SUBQ.L  #1,A3
        CLR     D0
        MOVE.B  -(A3),D0
        LEA     tbl(PC),A0
        MOVE.B  0(A0,D0.W),D0
        MOVE    D0,(A3)+
        RTS

    tbl DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        DC.B  1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0
        DC.B  0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0
        DC.B  0,1,0,1,1,1,1,1,1,0,0,0,0,0,1,0
        DC.B  1,1,1,1,1,0,1,1,0,0,0,0,0,0,0,0
        DC.B  1,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0
        DC.B  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    END
  END isLower;

END Characters.

(* $0000105E$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$0000105E$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22$FFF6BC22€$00000029T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$FFEDB15C$0000105E$000013FA$00001452$00000056$0000004A$00000037$00000029$000004F5$000006B3$FFF68A85$00000611$00000648$00000611$00000648$0000065F €€*)
