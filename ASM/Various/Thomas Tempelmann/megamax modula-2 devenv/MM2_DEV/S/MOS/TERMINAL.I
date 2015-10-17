IMPLEMENTATION MODULE Terminal; (* V#054 *)
(*$L-,R-*)
(*$Y+*)

(*
  19.4.88 TT  WritePg geht.
  23.5.89 TT  ETXKey gibt's nicht mehr - stattdessen hat /Enter/ nun gleiche
                Funktion wie /Return/; /Esc/ bricht ab; SOLn/EOLn nun mit Ctrl
                statt Shift.
*)
FROM SYSTEM IMPORT ASSEMBLER;

FROM SYSTEM IMPORT LONGWORD;

FROM TermBase IMPORT DoBusy, DoWrite, DoWriteCt,
        DoGetRows, DoGetCols, DoGetGSX;

FROM MOSGlobals IMPORT Key;

IMPORT StringEditor, MOSConfig, Strings;


VAR lastCh: LONGWORD;
    getLast: BOOLEAN;


PROCEDURE UndoRead;
  BEGIN
    ASSEMBLER
        MOVE    #1,getLast
    END
  END UndoRead;
  

PROCEDURE NumRows (): CARDINAL;
  BEGIN
    ASSEMBLER
        MOVE.L  DoGetRows,A0
        JMP     (A0)
    END
  END NumRows;

PROCEDURE NumCols (): CARDINAL;
  BEGIN
    ASSEMBLER
        MOVE.L  DoGetCols,A0
        JMP     (A0)
    END
  END NumCols;


PROCEDURE Write (ch: CHAR);
  BEGIN
    ASSEMBLER
        LEA     -2(A3),A0
        MOVE.L  A0,(A3)+
        CLR     (A3)+
        MOVE.L  DoWrite,A0
        JSR     (A0)
        SUBQ.L  #2,A3
    END
  END Write;

PROCEDURE WriteCtrl (ch: CHAR);
  BEGIN
    ASSEMBLER
        LEA     -2(A3),A0
        MOVE.L  A0,(A3)+
        CLR     (A3)+
        MOVE.L  DoWriteCt,A0
        JSR     (A0)
        SUBQ.L  #2,A3
    END
  END WriteCtrl;

PROCEDURE WriteLn;
  BEGIN
    ASSEMBLER
        MOVE    #$0D0A,-(A7)
        MOVE.L  A7,(A3)+
        MOVE    #1,(A3)+
        MOVE.L  DoWrite,A0
        JSR     (A0)
        ADDQ.L  #2,A7
    END
  END WriteLn;

PROCEDURE WritePg;
  BEGIN
    ASSEMBLER
        MOVE    #$1B45,-(A7)
        MOVE.L  A7,(A3)+
        MOVE    #1,(A3)+
        MOVE.L  DoWrite,A0
        JSR     (A0)
        ADDQ.L  #2,A7
    END
  END WritePg;

PROCEDURE GotoXY (x, y: CARDINAL);
  BEGIN
    ASSEMBLER
        MOVE.L  #$1B592020,-(A7)  ; ESC, 'Y'
        MOVE    -(A3),D0
        ADD.B   D0,2(A7)
        MOVE    -(A3),D0
        ADD.B   D0,3(A7)
        MOVE.L  A7,(A3)+
        MOVE    #3,(A3)+
        MOVE.L  DoWrite,A0
        JSR     (A0)
        ADDQ.L  #4,A7
    END
  END GotoXY;

PROCEDURE GotoRowCol (row, col: CARDINAL);
  BEGIN
    ASSEMBLER
        MOVE.L  #$1B592020,-(A7)  ; ESC, 'Y'
        MOVE    -(A3),D0
        ADD.B   D0,3(A7)
        MOVE    -(A3),D0
        ADD.B   D0,2(A7)
        MOVE.L  A7,(A3)+
        MOVE    #3,(A3)+
        MOVE.L  DoWrite,A0
        JSR     (A0)
        ADDQ.L  #4,A7
    END
  END GotoRowCol;

PROCEDURE WriteCtrlString (REF str: ARRAY OF CHAR);
  BEGIN
    ASSEMBLER
        MOVE.L  DoWriteCt,A0
        JMP     (A0)
    END
  END WriteCtrlString;

PROCEDURE WriteString (REF str: ARRAY OF CHAR);
  BEGIN
    ASSEMBLER
        MOVE.L  DoWrite,A0
        JMP     (A0)
    END
  END WriteString;

PROCEDURE get;
  (* holt Taste nach D0 *)
  (* EQ: last geholt -> kein erneutes Echo! *)
  BEGIN
    ASSEMBLER
        TST     getLast
        BNE     b
        MOVE.L  DoGetGSX,A0
        JSR     (A0)
        MOVE.L  -(A3),D0
        MOVE.L  D0,lastCh
        RTS
      b MOVE.L  lastCh,D0
        CLR     getLast
    END
  END get;

PROCEDURE waiting;
  (* NE: Taste wartet *)
  BEGIN
    ASSEMBLER
        TST     getLast
        BNE     b
        MOVE.L  DoBusy,A0
        JSR     (A0)
        TST     -(A3)
      b
    END
  END waiting;
  
PROCEDURE GetKey (VAR k: Key);
  BEGIN
    ASSEMBLER
        JSR     get
        ROR.L   #8,D0
        SWAP    D0
        LSR.B   #1,D0
        BCC     n
        BSET    #0,D0
     n: ANDI.B  #1111%,D0
        SWAP    D0
        LSR.W   #8,D0
        MOVE.L  -(A3),A0
        MOVE.L  D0,(A0)
    END
  END GetKey;

PROCEDURE Read (VAR ch: CHAR);
  BEGIN
    ASSEMBLER
        SUBQ.L  #4,A7
        ; Zuerst prÅfen, ob schon ein Zeichen ansteht.
        JSR     waiting
        BNE     waits
        ; Cursor anschalten
        MOVE    #$1B65,(A7)   ; ESC, 'e'
        MOVE.L  A7,(A3)+
        MOVE    #1,(A3)+
        MOVE.L  DoWrite,A0
        JSR     (A0)
      waits
        ; Zeichen holen
        MOVE    getLast,-(A7)
        JSR     get
        MOVE    (A7)+,D2
        MOVE.L  -(A3),A0
        MOVE.B  D0,(A0)
        ; Cursor ausschalten und Zeichen ausgeben
        MOVE    #$1B66,(A7)   ; ESC, 'f'
        MOVE.B  D0,2(A7)
        MOVE.L  A7,(A3)+
        MOVEQ   #1,D1
        TST     D2
        BNE     notpr
        CMPI.B  #' ',D0
        BCS     notpr
        ADDQ    #1,D1
      notpr
        MOVE    D1,(A3)+
        MOVE.L  DoWrite,A0
        JSR     (A0)
        ADDQ.L  #4,A7
    END
  END Read;

PROCEDURE GetChar (VAR ch: CHAR);
  BEGIN
    ASSEMBLER
        JSR     get
        MOVE.L  -(A3),A0
        MOVE.B  D0,(A0)
    END
  END GetChar;

PROCEDURE KeyPressed (): BOOLEAN;
  BEGIN
    ASSEMBLER
        JSR     waiting
        SNE     D0
        ANDI    #1,D0
        MOVE    D0,(A3)+
    END
  END KeyPressed;

PROCEDURE CondRead (VAR ch: CHAR; VAR success: BOOLEAN);
  BEGIN
    ASSEMBLER
        JSR     waiting
        SNE     D0
        AND     #1,D0
        MOVE.L  -(A3),A0
        MOVE    D0,(A0)
        BEQ     noCh
        JSR     get
        MOVE.L  -(A3),A0
        MOVE.B  D0,(A0)
        RTS
      noCh
        MOVE.L  -(A3),A0
        CLR.B   (A0)
    END
  END CondRead;

PROCEDURE BusyRead (VAR ch:CHAR);
  BEGIN
    ASSEMBLER
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     CondRead
        ADDQ.L  #2,A7
    END
  END BusyRead;

PROCEDURE FlushKbd;
  BEGIN
    ASSEMBLER
      c JSR     waiting
        BEQ     ende
        JSR     get
        BRA     c
      ende
    END
  END FlushKbd;


PROCEDURE moveX (no: INTEGER);
  VAR  i: INTEGER;
      ch: CHAR;
  (*$L+*)
  BEGIN
    IF no < 0 THEN ch:= 'D' ELSE ch:= 'C' END;
    FOR i:= 1 TO ABS (no) DO
      Write(33C);
      Write(ch)
    END
  END moveX;
  (*$L=*)

VAR globLeadingBlanks: BOOLEAN;
    globToken: BOOLEAN;

PROCEDURE rdCmd (VAR c: StringEditor.Commands; VAR ch: CHAR);
  (*$L+*)
  VAR k: Key; again, isSep: BOOLEAN;
  BEGIN
    Write (33C); (* ESC *)
    Write ('e'); (* cursor ein *)
    again:= FALSE;
    REPEAT
      GetKey (k);
      ch:= k.ch;
      c:= StringEditor.StdCmd (k);
      IF globToken THEN
        isSep:= ch IN MOSConfig.Separators;
        IF globLeadingBlanks THEN
          IF isSep THEN
            IF ch >= ' ' THEN
              Write (ch)
            END;
            again:= TRUE;
          ELSE
            globLeadingBlanks:= FALSE
          END
        ELSIF isSep THEN
          IF ch >= ' ' THEN
            Write (ch)
          END;
          c:= StringEditor.enter
        END
      END
    UNTIL ~again;
    Done:= (c # StringEditor.abort);
    Write (33C); (* ESC *)
    Write ('f'); (* cursor aus *)
  END rdCmd;
  (*$L=*)

PROCEDURE myEditLine( VAR dStr: ARRAY OF CHAR; mayCtrl, token: BOOLEAN);
  (*$L+*)
  BEGIN
    globToken:= token;
    globLeadingBlanks:= TRUE;
    StringEditor.Edit (dStr, mayCtrl, WriteCtrl, WriteCtrlString, moveX, rdCmd)
  END myEditLine;
  (*$L=*)


PROCEDURE EditLine (VAR str: ARRAY OF CHAR);
  BEGIN
    ASSEMBLER
        CLR     (A3)+
        CLR     (A3)+
        JMP     myEditLine
    END
  END EditLine;

PROCEDURE ReadLine (VAR str: ARRAY OF CHAR);
  BEGIN
    ASSEMBLER
        MOVE.L  -6(A3),A0
        CLR.B   (A0)
        JMP     EditLine
    END
  END ReadLine;

PROCEDURE EditCtrlLine (VAR str: ARRAY OF CHAR);
  BEGIN
    ASSEMBLER
        MOVE    #1,(A3)+
        CLR     (A3)+
        JMP     myEditLine
    END
  END EditCtrlLine;

PROCEDURE ReadCtrlLine (VAR str: ARRAY OF CHAR);
  BEGIN
    ASSEMBLER
        MOVE.L  -6(A3),A0
        CLR.B   (A0)
        JMP     EditCtrlLine
    END
  END ReadCtrlLine;


PROCEDURE ReadString (VAR str: ARRAY OF CHAR);
  BEGIN
    ASSEMBLER
        JMP     ReadLine
    END
  END ReadString;

PROCEDURE ReadToken (VAR str: ARRAY OF CHAR);
  BEGIN
    ASSEMBLER
        MOVE.L  -6(A3),A0
        CLR.B   (A0)
        CLR     (A3)+
        MOVE    #1,(A3)+
        JMP     myEditLine
    END
  END ReadToken;


BEGIN
  Write (33C); (* ESC *)
  Write ('v'); (* automatisches CR am Zeilenende *)
  Write (33C); (* ESC *)
  Write ('f'); (* cursor aus *)
END Terminal.

(* $00000DB6$FFEEC2C1$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$00001B43$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7$FFFC30A7Ä$00001C77T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$FFED85AF$00001C2D$FFED85AF$FFED85AF$FFED85AF$FFED85AF$00001C2D$FFED85AF$00001C77$00001C59$00001C6A$00000035$00000144$00000042$00000125$00001BEB∞ÄÅ*)
