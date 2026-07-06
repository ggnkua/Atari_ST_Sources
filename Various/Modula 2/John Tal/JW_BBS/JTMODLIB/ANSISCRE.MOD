IMPLEMENTATION MODULE AnsiScreen;

FROM Terminal         IMPORT WriteString, Write, WriteLn;
FROM NumberConversion IMPORT CardToString;
FROM Strings          IMPORT Concat, Copy, Length;
FROM Functions        IMPORT LeftTrim;

VAR
  out   : ARRAY[0..16] OF CHAR;
  x1,y1 : ARRAY[0..2] OF CHAR;
  x,y : CARDINAL;


PROCEDURE Locate( y,x : CARDINAL );
 BEGIN
    Write(CHR(27));
    Write('[');
     CardToString(y,y1,2);
     LeftTrim(y1,y1);
     WriteString(y1);
    Write(';');
     CardToString(x,x1,2);
     LeftTrim(x1,x1);
     WriteString(x1);
    Write('H');
  END Locate;


PROCEDURE Cls();
  BEGIN
    Write(CHR(27));
    WriteString('[2J');
  END Cls;


PROCEDURE EraseLine(Row : CARDINAL);
  BEGIN
    Locate(Row,1);
    Concat(CHR(27),'[K',out);
    WriteString(out);
  END EraseLine;


PROCEDURE DisplayString(Row,Col,Color : CARDINAL; It : ARRAY OF CHAR);
BEGIN
  Locate(Row,Col);
  TextColor(Color);
  WriteString(It);
END DisplayString;


PROCEDURE TextColor( c : INTEGER );
  BEGIN
    CASE c OF
      -1 : Concat(CHR(27),'[0;7m',out);       (*  inverse video  *)
           WriteString(out)|

       0 : Concat(CHR(27),'[8m',out);
           WriteString(out)|

       1 : Concat(CHR(27),'[0;4m',out);
           WriteString(out)|

       7 : Concat(CHR(27),'[0m',out);
           WriteString(out)|

       9 : Concat(CHR(27),'[1;4m',out);
           WriteString(out)|

      15 : Concat(CHR(27),'[0;1m',out);
           WriteString(out)|

      17 : Concat(CHR(27),'[0;5;4m',out);
           WriteString(out)|

      25 : Concat(CHR(27),'[0;1;5;4m',out);
           WriteString(out)|

      31 : Concat(CHR(27),'[0;1;5m',out);
           WriteString(out)
    END;
  END TextColor;


PROCEDURE TextBackground ( c : INTEGER );
  BEGIN
  END TextBackground;


END AnsiScreen.
