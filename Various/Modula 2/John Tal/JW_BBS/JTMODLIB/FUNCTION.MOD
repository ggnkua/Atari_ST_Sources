IMPLEMENTATION MODULE Functions;

FROM Strings         IMPORT Length,Pos,Copy,Insert,Concat;
FROM RealConversions IMPORT RealToString,StringToReal;


PROCEDURE CardWidth( a : CARDINAL) : CARDINAL;
VAR
 cw : CARDINAL;
BEGIN
  IF (a > 0) AND (a < 10) THEN
    cw := 1;
  ELSIF (a > 9) AND (a < 100) THEN
    cw := 2;
  ELSIF (a > 99) AND (a < 1000) THEN
    cw := 3;
  ELSIF (a > 999) AND (a < 10000) THEN
    cw := 4;
  ELSIF (a > 9999) AND (a < 65535) THEN
    cw := 5;
  END;
  RETURN(cw);
END CardWidth;

PROCEDURE CardMin( a,b : CARDINAL) : CARDINAL;
BEGIN
  IF b < a THEN
     RETURN(b);
   ELSE
     RETURN(a);
  END;
END CardMin;

PROCEDURE IntMin( a,b : INTEGER) : INTEGER;
BEGIN
  IF b < a THEN
     RETURN(b);
   ELSE
     RETURN(a);
  END;
END IntMin;

PROCEDURE RealMin( a,b : REAL) : REAL;
BEGIN
  IF b < a THEN
     RETURN(b);
   ELSE
     RETURN(a);
  END;
END RealMin;

PROCEDURE CardMax( a,b : CARDINAL) : CARDINAL;
BEGIN
  IF b > a THEN
     RETURN(b);
   ELSE
     RETURN(a);
  END;
END CardMax;

PROCEDURE IntMax( a,b : INTEGER) : INTEGER;
BEGIN
  IF b > a THEN
     RETURN(b);
   ELSE
     RETURN(a);
  END;
END IntMax;

PROCEDURE RealMax( a,b : REAL) : REAL;
BEGIN
  IF b > a THEN
    RETURN(b);
   ELSE
     RETURN(a);
  END;
END RealMax;

PROCEDURE RightPad(VAR dest : ARRAY OF CHAR; source : ARRAY OF CHAR;
                   i : CARDINAL);
VAR
 c,q : CARDINAL;
BEGIN
 c := Length(source);
 Copy(source,0,c,dest);
 IF (c < i) THEN
   FOR q := c TO i-1 DO
     dest[q] := ' ';
   END;   (* for *)
 END;  (* if *)
 dest[i] := CHR(0);
END RightPad;

PROCEDURE LeftPad(VAR dest : ARRAY OF CHAR; source : ARRAY OF CHAR;
                   i : CARDINAL);
VAR
 c,f,q : CARDINAL;
BEGIN
 c := Length(source);
 Copy(source,0,c,dest);
 f := i - c;
 IF f > 0 THEN
   FOR q := c TO 0 BY -1 DO
     dest[q+f] := dest[q];
   END;
   FOR q := 0 TO f-1 DO
     dest[q] := ' ';
   END;
   dest[i] := CHR(0);
 END;
END LeftPad;

PROCEDURE ToSpaces(VAR dest : ARRAY OF CHAR; i : CARDINAL);
VAR
 q : CARDINAL;
BEGIN
 IF i > 0 THEN
   FOR q := 0 TO i-1 DO
     dest[q] := ' ';
   END;
   dest[i] := CHR(0);
 ELSE
   dest[0] := CHR(0);
 END;
END ToSpaces;

PROCEDURE RightTrim(VAR dest : ARRAY OF CHAR; source : ARRAY OF CHAR);
VAR
 c : CARDINAL;
BEGIN
 c := Length(source);
 Copy(source,0,c,dest);
 IF c > 0 THEN
   DEC(c);  (* change from length to element of string *)
   WHILE (dest[c] = ' ') AND (c > 0) DO
     DEC(c);
   END;   (* while *)
   IF (c = 0) AND (dest[c] = ' ') THEN
     dest[c] := CHR(0);
   ELSIF c < Length(source) THEN
    dest[c+1] := CHR(0);
   END;
 END;
END RightTrim;

PROCEDURE LeftTrim(VAR dest : ARRAY OF CHAR; source : ARRAY OF CHAR);
VAR
 c,d,q : CARDINAL;
BEGIN
 c := Length(source);
 Copy(source,0,c,dest);
 q := 0;
 WHILE dest[q] = ' ' DO
   INC(q);
 END;   (* while *)
 IF q <> 0 THEN
   FOR d := q TO c DO
      dest[d-q] := dest[d];
   END;
   dest[c-q] := CHR(0);
 END;
END LeftTrim;

PROCEDURE LeftString(VAR dest : ARRAY OF CHAR; source : ARRAY OF CHAR;
                     i : CARDINAL);
VAR
 c,d,q : CARDINAL;
BEGIN
  Copy(source,0,i,dest);
END LeftString;

PROCEDURE RightString(VAR dest : ARRAY OF CHAR; source : ARRAY OF CHAR;
                     i : CARDINAL);
VAR
 c,d,q : CARDINAL;
BEGIN
  c := Length(source);
  q := c-i;
  FOR d := 0 TO i DO
    dest[d] := source[q+d];
  END;
  dest[i] := CHR(0);
END RightString;

PROCEDURE RepeatString(VAR dest : ARRAY OF CHAR; ch : CHAR; i : CARDINAL);
VAR
 c : CARDINAL;
BEGIN
 FOR c := 0 TO i DO
   dest[c] := ch;
 END;
 dest[i] := CHR(0);
END RepeatString;

PROCEDURE StringReplace(VAR dest : ARRAY OF CHAR; ch1,ch2 : CHAR);
VAR
 a,h : CARDINAL;
BEGIN
  h := HIGH(dest);
  a := Pos(ch1,dest);
  WHILE a <= h DO
    dest[a] := ch2;
    a := Pos(ch1,dest);
  END;
END StringReplace;

PROCEDURE MidString(VAR dest : ARRAY OF CHAR; source : ARRAY OF CHAR;
                    beg,len : CARDINAL);

VAR
  i,k : CARDINAL;
BEGIN
  k := CardMin(len,Length(source));
  FOR i := 0 TO k-1 DO
    dest[i] := source[beg+i];
  END;
  dest[k] := CHR(0);
END MidString;

PROCEDURE StrToMid(VAR dest : ARRAY OF CHAR; beg,len : CARDINAL;
                     source : ARRAY OF CHAR);

VAR
  i,l : CARDINAL;
  x,p : INTEGER;
  temps : ARRAY[0..255] OF CHAR;
BEGIN
  l := CardMin(len,Length(source));
  p := INTEGER(Length(dest));
  IF p = 0 THEN
    ToSpaces(dest,beg);
    p := INTEGER(beg);
  END;
  x := INTEGER(beg) - p;
  IF x > 0 THEN
    RightPad(temps,dest,beg);
    Copy(temps,0,Length(temps),dest);
  END;
  FOR i := beg TO beg+l-1  DO
    dest[i] := source[i-beg];
  END;
  IF (Length(dest) < (beg+l)) THEN
    dest[beg+l-1] := 0C;
  END;
END StrToMid;

PROCEDURE MidStrToMid(VAR dest : ARRAY OF CHAR; beg1,len1 : CARDINAL;
                        source : ARRAY OF CHAR; beg2 : CARDINAL);

VAR
  i,k,p,j,x : CARDINAL;
  temps : ARRAY[0..255] OF CHAR;
BEGIN
  k := CardMin(len1,Length(source));
  p := Length(st);
  IF p === 0 THEN
    ToSpaces(dest,beg1);
    p := beg1;
  END;
  x := beg1 - p;
  IF x > 0 THEN
    RightPad(temps,dest,beg1);
    Copy(temps,0,Length(temps),dest);
  END;
  j := beg2;
  FOR i := beg1 TO beg1+len1 DO
    dest[i] := source[j];
    INC(j);
  END;
  IF (Length(dest) <= (beg1+len1)) THEN
    dest[beg1+len1] := 0C;
  END;
END MidStrToMid;

PROCEDURE RealSign(x : REAL) : REAL;
BEGIN
 IF x < 0.0 THEN
   RETURN(-1.0);
  ELSE
   RETURN(1.0);
 END;
END RealSign;

PROCEDURE Round (R : REAL) : REAL;
VAR
 width : CARDINAL;
 RStr : ARRAY[0..64] OF CHAR;
 okay : BOOLEAN;
BEGIN
 width := 0;
 R := RealSign(R) * (R + 0.0047);
 REPEAT
   INC(width);
   RealToString(R,2,width,RStr,okay);
 UNTIL okay;
 WriteLn; WriteString(RStr); WriteLn;
 StringToReal(RStr,R,okay);
 RETURN R;
END Round;

PROCEDURE RecHi( recno, filelen : CARDINAL) : CARDINAL;
VAR
 rechi : CARDINAL;
 RECHI,HI,RECNO,FILELEN : REAL;
BEGIN
 HI := 65536.0;

 IF (recno > 0) THEN
   RECNO := FLOAT(recno-1);
   FILELEN := FLOAT(filelen);
   RECHI := RECNO * FILELEN;

   IF RECHI <= (HI-1.0) THEN
      RETURN(0);
   ELSE
      rechi := 0;
      WHILE RECHI > (HI-1.0) DO
        RECHI := RECHI - HI;
        INC(rechi);
      END;
      RETURN(rechi);
   END;
 ELSE
   RETURN(0);
 END;
END RecHi;

PROCEDURE RecLo( recno, filelen : CARDINAL) : CARDINAL;
VAR
 RECLO,HI,RECNO,FILELEN : REAL;
BEGIN
 HI := 65536.0;

 IF (recno > 0 ) THEN
   RECNO := FLOAT(recno-1);
   FILELEN := FLOAT(filelen);
   RECLO := RECNO * FILELEN;

   IF RECLO <= (HI-1.0) THEN
     RETURN(TRUNC(RECLO));
   ELSE
     WHILE RECLO > (HI-1.0) DO
       RECLO := RECLO - HI;
     END;
     RETURN(TRUNC(RECLO));
   END;
 ELSE
   RETURN(0);
 END;
END RecLo;

PROCEDURE PrintUsing(VAR Using : ARRAY OF CHAR; mask : ARRAY OF CHAR; number : REAL);

TYPE
  st255 = ARRAY[0..255] OF CHAR;
  st80 = ARRAY[0..80] OF CHAR;
  st32 = ARRAY[0..32] OF CHAR;

VAR
     comma,point,minussign : CHAR;
     fieldwidth, integerlength, i, j, places,pointposition : CARDINAL;
     usingcommas, decimal, negative, ok : BOOLEAN;
     outstring, integerstring       : st80;
     temps : st255;

BEGIN
     comma := ',';
     point := '.';
     minussign := '-';

     negative    := number < 0.0;
     number      := ABS(number);
     places      := 0;

     IF Pos('CR',mask) > HIGH(mask) THEN
        fieldwidth  := Length(mask);
     ELSE
        fieldwidth := Length(mask) - 2;
     END;


     usingcommas := Pos(comma,mask) < HIGH(mask);
     decimal     := Pos(point,mask) < HIGH(mask);

     IF decimal THEN
       pointposition := Pos(point,mask);
       places        := fieldwidth - pointposition;
     END;


     RealToString(number,places-1,fieldwidth,outstring,ok);
     (*  str( number : 0 : places, outstring);  *)

     IF usingcommas THEN
       j := 0;
       (*  integerstring := copy(outstring, 1, length( outstring ) - places );  *)
       Copy(outstring,0,(Length(outstring)-places),integerstring);
       integerlength := Length( integerstring );
       IF decimal THEN
         integerlength := integerlength -1;
       END;
       FOR  i := integerlength TO 2 BY -1 DO
          j := j + 1;
          IF ( ((j MOD 3) = 0) AND (outstring[i] # ' ') ) THEN
            Insert(comma,outstring,i); (* insert ( comma, outstring, i ) *)
          END;
       END;
    END;

    IF Length(outstring) < fieldwidth THEN
        ToSpaces(temps,(fieldwidth - Length(outstring)));
        Concat(temps,outstring,outstring);
        (*  outstring := spaces(fieldwidth - length(outstring)) + outstring; *)
    END;

    IF (negative) THEN
      IF (Pos('CR',mask) <> 0) THEN
          Concat(outstring,'CR',outstring);
          (*  outstring := outstring + 'CR'; *)
      ELSE;
          Concat(minussign,outstring,outstring);
          (* outstring := minussign + outstring; *)
      END;
    END;

    Copy(outstring,0,Length(outstring),Using);

END PrintUsing;

PROCEDURE Power(n : CARDINAL)   : CARDINAL;
BEGIN
   IF n=1  THEN
     RETURN x;
   ELSIF n <= 0 THEN
     RETURN 1;
   ELSE
     RETURN (x * Power(x,n-1));
  END;
END Power;

PROCEDURE ShiftCardLeft(c,s: CARDINAL): CARDINAL;
BEGIN
   RETURN c * Power(2,s);
END ShiftCardLeft;

PROCEDURE ShiftCardRight(c,s: CARDINAL): CARDINAL;
BEGIN
   RETURN c DIV Power(2,s);
END ShiftCardRight;

END Functions.
