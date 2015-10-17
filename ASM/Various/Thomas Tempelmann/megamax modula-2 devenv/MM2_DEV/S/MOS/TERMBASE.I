IMPLEMENTATION MODULE TermBase;
(*$Y+, L-,R-,M-*)

FROM SYSTEM IMPORT ASSEMBLER;

(*
  27.07.89 TT  WriteString optimiert
*)

FROM SYSTEM IMPORT LONGWORD;

PROCEDURE WriteString (REF str: ARRAY OF CHAR);
  BEGIN
    ASSEMBLER
        MOVEM.L D4/A4,-(A7)
        MOVE.W  -(A3),D4
        MOVE.L  -(A3),A4
        CLR.W   -(A7)
        MOVE.L  #$00030002,-(A7)
      l MOVE.W  #$0003,(A7)     ; muž wegen eines Fehlers in TOS 1.4 (8.8.88)
                                ; immer wieder gesetzt werden
        MOVE.B  (A4)+,5(A7)
        BEQ     e
        TRAP    #13
        DBRA    D4,l
      e ADDQ.L  #6,A7
        MOVEM.L (A7)+,D4/A4
    END
  END WriteString;

PROCEDURE WriteVisible (REF str: ARRAY OF CHAR);
  BEGIN
    ASSEMBLER
        MOVEM.L D4/A4,-(A7)
        MOVE.W  -(A3),D4
        MOVE.L  -(A3),A4
        CLR.W   -(A7)
        MOVE.L  #$00030005,-(A7)
      l MOVE.W  #$0003,(A7)     ; muž wegen eines Fehlers in TOS 1.4 (8.8.88)
                                ; immer wieder gesetzt werden
        MOVE.B  (A4)+,5(A7)
        BEQ     e
        TRAP    #13
        DBRA    D4,l
      e ADDQ.L  #6,A7
        MOVEM.L (A7)+,D4/A4
    END
  END WriteVisible;

PROCEDURE Busy (): BOOLEAN;
  BEGIN
    ASSEMBLER
        MOVE.L  #$00010002,-(A7)
        TRAP    #13
        ADDQ.L  #4,A7
        TST     D0
        SNE     D0
        AND     #1,D0
        MOVE    D0,(A3)+
    END
  END Busy;

PROCEDURE GetGSX (): LONGWORD;
  BEGIN
    ASSEMBLER
        MOVE.L  #$00020002,-(A7)
        TRAP    #13
        ADDQ.L  #4,A7
        MOVE.L  D0,(A3)+
    END
  END GetGSX;

PROCEDURE GetRows (): CARDINAL;
  BEGIN
    ASSEMBLER
        MOVE    #25,(A3)+
    END
  END GetRows;

PROCEDURE GetCols (): CARDINAL;
  BEGIN
    ASSEMBLER
        PEA     u(PC)
        MOVE    #38,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
        MOVE    D0,(A3)+
        RTS
      u TST.B   $44C
        BEQ     l
        MOVEQ   #80,D0
        RTS
      l MOVEQ   #40,D0
    END
  END GetCols;

PROCEDURE InitDisplay;
  BEGIN
    DoWrite:= WriteString;
    DoGetRows:= GetRows;
    DoGetCols:= GetCols;
    DoWriteCt:= WriteVisible;
  END InitDisplay;

PROCEDURE InitKeyboard;
  BEGIN
    DoBusy:= Busy;
    DoGetGSX:= GetGSX;
  END InitKeyboard;

BEGIN
  InitKeyboard;
  InitDisplay;
END TermBase.

(* $FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$00000036$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B$FFFC3D6B€$00000028T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$FFEE7ABD$FFEE7ABD$FFEE7ABD$000005B9$000008EF$000000C2$000002D2$00000055$00000034$00000028$000000A5$0000009A$000008A3$00000670$00000908$FFEE7ABD¨€€*)
