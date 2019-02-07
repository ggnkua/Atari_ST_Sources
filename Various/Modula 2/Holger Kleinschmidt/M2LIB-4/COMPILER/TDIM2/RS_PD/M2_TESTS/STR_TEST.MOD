MODULE StrTest;
(*$S-,$T-,$Q+*)
(*
   Obwohl im Speicher das abschlieûende 0c hinter String-Konstanten immer
   existiert, zeigt das Disassembling: Es wird nicht immer mitkopiert, denn
   der tag-Wert berÅcksichtigt 0c nicht!
   Abhilfe: Dummy als letzte lokal deklarieren.
*)
PROCEDURE Test (s: ARRAY OF CHAR);
 VAR   x, Dummy: CARDINAL;
 BEGIN    Dummy := 0 END Test;

END StrTest.
(*
    0H  4E56 FFFC LINK   A6,#FFFCH
    4H  3A2E 000C MOVE.W 12(A6),D5
    8H  5245      ADDQ.W #1,D5; len = hi +1
    AH  0805 0000 BTST   #0H,D5; odd?
    EH  6702      BEQ    [2] =12H
   10H  5245      ADDQ.W #1,D5; even!
   12H  48C5      EXT.L  D5
   14H  9FC5      SUBA.L D5,A7
   16H  286E 0008 MOVE.L 8(A6),A4
   1AH  2D4F 0008 MOVE.L A7,8(A6)
   1EH  264F      MOVE.L A7,A3
   20H  5345      SUBQ.W #1,D5
   22H  16DC      MOVE.B (A4)+,(A3)+; bytes!
   24H  51CD FFFC DBRA   D5,[-4] =22H
   28H  426E FFFC CLR.W  -4(A6)
   2CH  4E5E      UNLK   A6
   2EH  4E75      RTS
*)
