IMPLEMENTATION MODULE PcScreen;

FROM Strings IMPORT Length;
FROM MachDep IMPORT Locate;
FROM SYSTEM  IMPORT ADDRESS,GETREG,AX,SWI;
FROM Environment IMPORT Ptr,SType,ScreenType,Screen,RowAdj,ColAdj,
                        RowMax,ColMax;

PROCEDURE Cls;
VAR r1,c1 : CARDINAL;
BEGIN
 Locate(1,1);
 FOR r1 := RowMax TO 1 BY -1 DO    (*  clear by scrolling up / not trad. down *)
   FOR c1 := 1 TO ColMax DO
     Screen^[r1,c1].Code := ' ';
     Screen^[r1,c1].Attr := CHR(7);
   END
 END
END Cls;

PROCEDURE EraseLine(Row : CARDINAL);
VAR c1 : CARDINAL;
BEGIN
  Row := RowAdj(Row);
  FOR c1 := 1 TO ColMax DO
    Screen^[Row,c1].Code := ' ';
    Screen^[Row,c1].Attr := CHR(7);
  END
END EraseLine;

PROCEDURE ColorAdj( Color : CARDINAL) : CARDINAL;
VAR
  ColorBits,ReturnBits : BITSET;
  invisible,bold,highlight,light,italic,underline,outline,shadow,
  blink,reverse,normal: BITSET;
BEGIN
 invisible := {};   (* 0   PC *)
 bold      := {0};  (* 1   GEM *)
 highlight := {0};  (* 1   PC *)
 light     := {1};  (* 2   G *)
 italic      := {2};  (* 4   GEM *)
 underline := {3};  (* 8   PC/GEM *)
 outline   := {4};  (* 16  GEM *)
 shadow    := {5};  (* 32  GEM *)
 blink     := {6};  (* 64  PC *)
 reverse   := {7};  (* 128 PC *)
 normal    := {8};  (* 256 PC~GEM *)
  ColorBits := BITSET(Color);
  IF ScreenType = Mono THEN
    IF ColorBits = invisible THEN RETURN 0;
      ELSIF ColorBits * normal = normal THEN RETURN 7;
      ELSIF ColorBits * reverse = reverse THEN RETURN 112;
    ELSE
      ReturnBits := {2,1,0};  (* Start with Normal *)
      IF ColorBits * underline = underline THEN
        ReturnBits := ReturnBits / {2,1};
      END;
      IF ColorBits * blink = blink THEN
        ReturnBits := ReturnBits + {7};
      END;
      IF ColorBits * highlight = highlight THEN
        ReturnBits := ReturnBits + {3};
      END;
      RETURN CARDINAL(ReturnBits);
    END;
  ELSE
    (* Color Screen is being used.  IF generic (monochrome) colors are being
       used, then translate.  Else used color supplied.  *)
    CASE Color OF
       2 : RETURN 2FH |       (*  color 1  underline / green & white *)
       1 : RETURN 07H |       (*        7  normal  *)
      10 : RETURN 2BH |       (*        9  bright/underline  *)
       8 : RETURN 0FH |       (*        15 bright  *)
       6 : RETURN 2FH+80H |   (*        17 blink/underline  *)
       4 : RETURN 07H+80H |   (*        23 blink  *)
      14 : RETURN 2BH+80H |   (*        25 bright/blink/underline  *)
      12 : RETURN 0FH+80H |   (*        31 bright/blink  *)
      16 : RETURN 20H       (*  inverse  *)
     ELSE
       RETURN Color;
    END;
  END; (* if *)
END ColorAdj;


PROCEDURE DisplayString(Row,Col,Color : CARDINAL; Str : ARRAY OF CHAR);
VAR I : CARDINAL;
BEGIN
IF Length(Str) > 0 THEN
  Color := ColorAdj(Color);
  Row := RowAdj(Row); Col := ColAdj(Col);
  FOR I := 0 TO (Length(Str)-1) DO
     Screen^[Row,Col+I].Code := Str[I];
     Screen^[Row,Col+I].Attr := CHR(Color);
   END;
END;
END DisplayString;

PROCEDURE DisplayStringMid(Row,Col,Color : CARDINAL; Str : ARRAY OF CHAR;
                           beg,len : CARDINAL);
VAR
  I : CARDINAL;
BEGIN
  Color := ColorAdj(Color);
  Row := RowAdj(Row); Col := ColAdj(Col);
  FOR I := beg TO (beg+len-1) DO
    Screen^[Row,Col+I-beg].Code := Str[I];
    Screen^[Row,Col+I-beg].Attr := CHR(Color);
  END; (* for i *)
END DisplayStringMid;

PROCEDURE WriteScreenChar(Row,Col,Color : CARDINAL; Letter : CHAR);
BEGIN
  Color := ColorAdj(Color);
  Row := RowAdj(Row); Col := ColAdj(Col);
  Screen^[Row,Col].Code := Letter;
  Screen^[Row,Col].Attr := CHR(Color);
END WriteScreenChar;

PROCEDURE ReadScreenChar(Row,Col : CARDINAL) : CHAR;
BEGIN
  Row := RowAdj(Row); Col := ColAdj(Col);
  RETURN(Screen^[Row,Col].Code);
END ReadScreenChar;

PROCEDURE WriteScreenCol(Row,Col,Color : CARDINAL);
BEGIN
  Row := RowAdj(Row); Col := ColAdj(Col);
  Screen^[Row,Col].Attr := CHR(Color);
END WriteScreenCol;

PROCEDURE ReadScreenCol(Row,Col : CARDINAL) : CARDINAL;
BEGIN
  Row := RowAdj(Row); Col := ColAdj(Col);
  RETURN(ORD(Screen^[Row,Col].Attr));
END ReadScreenCol;

END PcScreen.
