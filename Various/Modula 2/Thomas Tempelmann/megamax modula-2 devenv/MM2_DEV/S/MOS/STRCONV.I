IMPLEMENTATION MODULE StrConv;
(*$Y+,L-,R-,N+*)

(*
 *----------------------------------------------------------------------------
 * Copyright Januar 1987 Thomas Tempelmann
 *----------------------------------------------------------------------------
 * System - Version   : MOS 2.0
 * Version            : 1.1
 * Text - Version     : V#0042
 *----------------------------------------------------------------------------
 * Modul-Beschreibung : Umwandlungsfunktionen zw. Zahlen und Strings
 *----------------------------------------------------------------------------
 * Datum     Version  Autor  Bemerkung (Arbeitsbericht)
 *----------------------------------------------------------------------------
 * 20.01.87  1.0      TT     Impl.
 * 06.12.87  1.0      TT     Assembler-Umstellung
 * 18.08.89  1.1      TT     fill-Parameter bei NumToStr
 *----------------------------------------------------------------------------
 *)

FROM SYSTEM IMPORT ASSEMBLER;
FROM SYSTEM IMPORT LONGWORD, WORD, ADR;

FROM Strings IMPORT String;

FROM Convert IMPORT GetInfo;

IMPORT Convert;


TYPE MyInf = RECORD
               pstr: POINTER TO ARRAY [0..79] OF String;
               len : CARDINAL;
               pidx: POINTER TO INTEGER;
             END;


PROCEDURE chrGet (VAR info: GetInfo);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.L  GetInfo.userPtr(A0),A1
        MOVE.L  MyInf.pidx(A1),A2
        ADDQ.W  #1,(A2)
        MOVE.W  (A2),D0
        CMP.W   MyInf.len(A1),D0
        BHI     full            ; index hat HIGH-Wert Åberschritten
        MOVE.L  MyInf.pstr(A1),A1
        MOVE.B  0(A1,D0.W),GetInfo.ch(A0)
        RTS
      full
        CLR.B   GetInfo.ch(A0)
    END
  END chrGet;

PROCEDURE prpTo;
  BEGIN
    ASSEMBLER
        MOVE.L  (A7)+,A2
        MOVE.L  -(A3),D2        ; valid
        PEA     -10(A3)         ; GetInfo.userPtr
        SUBQ.L  #2,A7           ; GetInfo.ch
        MOVE.L  -4(A3),A0
        SUBQ.W  #1,(A0)         ; DEC (pos)
        MOVE.L  #chrGet,(A3)+   ; get-Procedure
        CLR.L   (A3)+           ; get-static link
        MOVE.L  A7,(A3)+        ; ADR (GetInfo)
        MOVE.L  D2,(A3)+        ; ADR (valid)
        JMP     (A2)
    END
  END prpTo;

PROCEDURE prpToN;
  BEGIN
    ASSEMBLER
        MOVE.L  (A7)+,A2
        MOVE.L  -(A3),D2        ; valid
        MOVE.L  -(A3),A1        ; pos
        MOVE.W  -(A3),D0        ; base
        MOVE.L  A1,(A3)+        ; pos
        SUBQ.W  #1,(A1)         ; DEC (pos)
        PEA     -10(A3)         ; GetInfo.userPtr
        SUBQ.L  #2,A7           ; GetInfo.ch
        MOVE.L  #chrGet,(A3)+   ; get-Procedure
        CLR.L   (A3)+           ; get-static link
        MOVE.L  A7,(A3)+        ; ADR (GetInfo)
        MOVE.W  D0,(A3)+        ; base
        MOVE.L  D2,(A3)+        ; ADR (valid)
        JMP     (A2)
    END
  END prpToN;

PROCEDURE fin4;
  BEGIN
    ASSEMBLER
        ADDQ.L  #6,A7
        MOVE.L  -(A3),D2
        SUBA.W  #10,A3
        MOVE.L  D2,(A3)+
    END
  END fin4;

PROCEDURE fin2;
  BEGIN
    ASSEMBLER
        ADDQ.L  #6,A7
        MOVE.W  -(A3),D2
        SUBA.W  #10,A3
        MOVE.W  D2,(A3)+
    END
  END fin2;

PROCEDURE StrToLCard ( REF str: ARRAY OF CHAR; VAR pos: CARDINAL;
                       VAR valid : BOOLEAN ): LONGCARD;
  BEGIN
    ASSEMBLER
        JSR     prpTo
        JSR     Convert.ConvToLCard
        JMP     fin4
    END
  END StrToLCard;

PROCEDURE StrToCard  ( REF str: ARRAY OF CHAR; VAR pos: CARDINAL;
                       VAR valid: BOOLEAN ): CARDINAL;
  BEGIN
    ASSEMBLER
        JSR     prpTo
        JSR     Convert.ConvToCard
        JMP     fin2
    END
  END StrToCard;

PROCEDURE StrToLInt  ( REF str: ARRAY OF CHAR; VAR pos: CARDINAL;
                       VAR valid: BOOLEAN ): LONGINT;
  BEGIN
    ASSEMBLER
        JSR     prpTo
        JSR     Convert.ConvToLInt
        JMP     fin4
    END
  END StrToLInt;

PROCEDURE StrToInt   ( REF str: ARRAY OF CHAR; VAR pos: CARDINAL;
                       VAR valid: BOOLEAN ): INTEGER;
  BEGIN
    ASSEMBLER
        JSR     prpTo
        JSR     Convert.ConvToInt
        JMP     fin2
    END
  END StrToInt;


PROCEDURE StrToLNum (     REF str: ARRAY OF CHAR;
                          base: CARDINAL; (* [2..36] *)
                      VAR pos: CARDINAL;
                      VAR valid : BOOLEAN ): LONGCARD;
  BEGIN
    ASSEMBLER
        JSR     prpToN
        JSR     Convert.ConvToLNum
        JMP     fin4
    END
  END StrToLNum;

PROCEDURE StrToNum (    REF str: ARRAY OF CHAR;
                        base: CARDINAL; (* [2..36] *)
                    VAR pos: CARDINAL;
                    VAR valid: BOOLEAN ): CARDINAL;
  BEGIN
    ASSEMBLER
        JSR     prpToN
        JSR     Convert.ConvToNum
        JMP     fin2
    END
  END StrToNum;


PROCEDURE StrToReal ( REF str: ARRAY OF CHAR; VAR pos: CARDINAL;
                      VAR valid: BOOLEAN ): LONGREAL;
  BEGIN
    ASSEMBLER
        JSR     prpTo
        JSR     Convert.ConvToReal
        ADDQ.L  #6,A7
        MOVE.L  -(A3),D2
        MOVE.L  -(A3),D1
        SUBA.W  #10,A3
        MOVE.L  D1,(A3)+
        MOVE.L  D2,(A3)+
    END
  END StrToReal;


PROCEDURE prpL;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),D1
        MOVE.L  A3,A1
        ADDA.W  #80,A3          ; Platz f. String
        MOVE.L  D1,(A3)+
        MOVE.W  D0,(A3)+
        MOVE.L  A1,(A3)+
        MOVE    #79,(A3)+
    END
  END prpL;

PROCEDURE prpW;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0
        MOVE.L  A3,A1
        ADDA.W  #80,A3          ; Platz f. String
        MOVE.L  D0,(A3)+
        MOVE.L  A1,(A3)+
        MOVE    #79,(A3)+
    END
  END prpW;

PROCEDURE prpR;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),D1
        MOVE.L  -(A3),D2
        MOVE.L  A3,A1
        ADDA.W  #80,A3          ; Platz f. String
        MOVE.L  D2,(A3)+
        MOVE.L  D1,(A3)+
        MOVE.L  D0,(A3)+
        MOVE.L  A1,(A3)+
        MOVE    #79,(A3)+
    END
  END prpR;

PROCEDURE CardToStr ( v: LONGCARD; spc: CARDINAL): String;
  BEGIN
    ASSEMBLER
        JSR     prpL
        JMP     Convert.ConvCard
    END
  END CardToStr;

PROCEDURE IntToStr  ( v: LONGINT;  spc: CARDINAL): String;
  BEGIN
    ASSEMBLER
        JSR     prpL
        JMP     Convert.ConvInt
    END
  END IntToStr;
  
PROCEDURE LHexToStr ( v: LONGWORD; spc: CARDINAL): String;
  BEGIN
    ASSEMBLER
        JSR     prpL
        JMP     Convert.ConvLHex
    END
  END LHexToStr;
  
PROCEDURE HexToStr  ( v: WORD;     spc: CARDINAL): String;
  BEGIN
    ASSEMBLER
        JSR     prpW
        JMP     Convert.ConvHex
    END
  END HexToStr;
  
PROCEDURE LBinToStr ( v: LONGWORD; spc: CARDINAL): String;
  BEGIN
    ASSEMBLER
        JSR     prpL
        JMP     Convert.ConvLBin
    END
  END LBinToStr;

PROCEDURE BinToStr  ( v: WORD;     spc: CARDINAL): String;
  BEGIN
    ASSEMBLER
        JSR     prpW
        JMP     Convert.ConvBin
    END
  END BinToStr;

PROCEDURE LNumToStr (    lnum : LONGWORD;
                         base : CARDINAL; (* [2..36] *)
                         space: CARDINAL;
                         fill : CHAR    ):String;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D2
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),D1
        MOVE.L  A3,A1
        ADDA.W  #80,A3          ; Platz f. String
        MOVE.L  D1,(A3)+
        MOVE.L  D0,(A3)+
        MOVE.W  D2,(A3)+
        MOVE.L  A1,(A3)+
        MOVE    #79,(A3)+
        JMP     Convert.ConvLNum
    END
  END LNumToStr;

PROCEDURE NumToStr (    num  : WORD;
                        base : CARDINAL; (* [2..36] *)
                        space: CARDINAL;
                        fill : CHAR    ):String;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),D1
        MOVE.L  A3,A1
        ADDA.W  #80,A3          ; Platz f. String
        MOVE.L  D1,(A3)+
        MOVE.L  D0,(A3)+
        MOVE.L  A1,(A3)+
        MOVE    #79,(A3)+
        JMP     Convert.ConvNum
    END
  END NumToStr;

PROCEDURE FloatToStr ( v: LONGREAL; spc, n:CARDINAL): String;
  BEGIN
    ASSEMBLER
        JSR     prpR
        JMP     Convert.ConvFloat
    END
  END FloatToStr;

PROCEDURE FixToStr ( v: LONGREAL; spc, n:CARDINAL): String;
  BEGIN
    ASSEMBLER
        JSR     prpR
        JMP     Convert.ConvFix
    END
  END FixToStr;

PROCEDURE RealToStr( v: LONGREAL; spc, n: CARDINAL): String;
  BEGIN
    ASSEMBLER
        JSR     prpR
        JMP     Convert.ConvReal
    END
  END RealToStr;

PROCEDURE EngToStr ( v: LONGREAL; spc, n:CARDINAL): String;
  BEGIN
    ASSEMBLER
        JSR     prpR
        JMP     Convert.ConvEng
    END
  END EngToStr;

END StrConv.

(* $FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$000008DC$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407$FFFBE407Ä$00000ACCT.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000022A5$00000D6D$00000834$0000083C$0000085D$0000082A$0000085D$00000811$00000803$FFEE0BED$00000ACC$0000002E$000013E0$000020A6$00002152$000021FA∞ÄÅ*)
