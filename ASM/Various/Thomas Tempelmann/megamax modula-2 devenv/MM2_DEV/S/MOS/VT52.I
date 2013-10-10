IMPLEMENTATION MODULE VT52;

(*$Y+,R-*)

CONST  TermCH = 0C;   (* Zeichen fÅr String-Ende *)
       ESC    = 33C;
       CR     = 15C;
       LF     = 12C;


PROCEDURE GetGotoRowColSeq ( row, col: CARDINAL; VAR seq: ARRAY OF CHAR );
  BEGIN
    IF HIGH (seq) < 3 THEN
      HALT (* String ist zu klein *)
    ELSE
      seq [0]:= Seq [gotoRowCol,0];
      seq [1]:= Seq [gotoRowCol,1];
      seq [2]:= CHR (row+32);
      seq [3]:= CHR (col+32);
      IF HIGH (seq) >= 4 THEN seq [4]:= TermCH END
    END
  END GetGotoRowColSeq;

PROCEDURE GetWritingColorSeq ( color: CARDINAL; VAR seq: ARRAY OF CHAR );
  BEGIN
    IF HIGH (seq) < 2 THEN
      HALT (* String ist zu klein *)
    ELSE
      seq [0]:= Seq [writingColor,0];
      seq [1]:= Seq [writingColor,1];
      seq [2]:= CHR (color+64);
      IF HIGH (seq) >= 3 THEN seq [3]:= TermCH END
    END
  END GetWritingColorSeq;

PROCEDURE GetBackgroundColorSeq ( color: CARDINAL; VAR seq: ARRAY OF CHAR );
  BEGIN
    IF HIGH (seq) < 2 THEN
      HALT (* String ist zu klein *)
    ELSE
      seq [0]:= Seq [backgroundColor,0];
      seq [1]:= Seq [backgroundColor,1];
      seq [2]:= CHR (color+64);
      IF HIGH (seq) >= 3 THEN seq [3]:= TermCH END
    END
  END GetBackgroundColorSeq;

PROCEDURE GotoRowColSeq ( row, col: CARDINAL ): ExtSeqStr;
  VAR s: ExtSeqStr;
  BEGIN
    GetGotoRowColSeq (row, col, s);
    RETURN s
  END GotoRowColSeq;

PROCEDURE WritingColorSeq ( color: CARDINAL ): ExtSeqStr;
  VAR s: ExtSeqStr;
  BEGIN
    GetWritingColorSeq (color, s);
    RETURN s
  END WritingColorSeq;

PROCEDURE BackgroundColorSeq ( color: CARDINAL ): ExtSeqStr;
  VAR s: ExtSeqStr;
  BEGIN
    GetBackgroundColorSeq (color, s);
    RETURN s
  END BackgroundColorSeq;

(*
VAR c: SeqRange;

BEGIN
  FOR c:= MIN (SeqRange) TO MAX (SeqRange) DO
    Seq [c,0]:= ESC;
    Seq [c,1]:= TermCH;
    Seq [c,2]:= TermCH;
  END;
  Seq [up,1]:= 'A';
  Seq [down,1]:= 'B';
  Seq [right,1]:= 'C';
  Seq [left,1]:= 'D';
  Seq [moveUp,1]:= 'I';
  Seq [moveDown,0]:= LF;  (* Dieser Code existiert nicht als ESC-Sequenz *)
  Seq [home,1]:= 'H';
  Seq [firstCol,0]:= CR;  (* Dieser Code existiert nicht als ESC-Sequenz *)
  Seq [gotoRowCol,1]:= 'Y';
  Seq [saveRowCol,1]:= 'j';
  Seq [restoreRowCol,1]:= 'k';
  Seq [clearScreen,1]:= 'E';
  Seq [clearEOS,1]:= 'J';
  Seq [clearEOL,1]:= 'K';
  Seq [clearBOS,1]:= 'd';
  Seq [clearBOL,1]:= 'o';
  Seq [clearLine,1]:= 'l';
  Seq [insertLine,1]:= 'L';
  Seq [deleteLine,1]:= 'M';
  Seq [writingColor,1]:= 'b';
  Seq [backgroundColor,1]:= 'c';
  Seq [cursorOn,1]:= 'e';
  Seq [cursorOff,1]:= 'f';
  Seq [reverseOn,1]:= 'p';
  Seq [reverseOff,1]:= 'q';
  Seq [wrapOn,1]:= 'v';
  Seq [wrapOff,1]:= 'w';
  Seq [enhancedOn,1]:= CHR (5);
  Seq [flush,1]:= CHR (16);
  Seq [enhancedOff,1]:= CHR (6);
*)
END VT52.
