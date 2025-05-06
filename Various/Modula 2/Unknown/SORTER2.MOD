MODULE Sorter; (* to put lists in alpha or numeric order *)
FROM Strings IMPORT Compare, Assign, CompareResults;
FROM GEMDOS IMPORT ConIn, ConOut, ConWS, Open, Close, Create,
     Read, Write, SFirst, GetDTA;
FROM SYSTEM IMPORT ADDRESS, ADR;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
 
CONST Maxnum = 2400;
 
VAR strg: ARRAY[1..Maxnum] OF ARRAY[0..80] OF CHAR;
    buffer, fname: ARRAY[0..80] OF CHAR;
    substrg: ARRAY[1..Maxnum] OF ARRAY[0..20] OF CHAR;
    cardstrg: ARRAY[0..6] OF CHAR;
    count: LONGCARD;
    i, j, k, max, start, length, flen: CARDINAL;
    a, ch: CHAR;
    handle: INTEGER;
    continue: BOOLEAN;

PROCEDURE CR;
BEGIN
  ConOut(CHR(13));
  ConOut(CHR(10));
END CR;


PROCEDURE Conrs(VAR strg: ARRAY OF CHAR); (* my own ConRS *)
VAR i: CARDINAL;
    ch: CHAR;
BEGIN
  i:= 0;
  LOOP (* until CR *)
    ConIn(ch);
    CASE ORD(ch) OF
      13: strg[i]:= CHR(0); EXIT |
       8: IF i > 0 THEN DEC(i); strg[i]:= CHR(0);
           ELSIF i = 0 THEN ConOut(' ');
          END; (* if *)
          ConOut(' ');
          ConOut(CHR(8));  |
     ELSE strg[i]:= ch; INC(i);
    END; (* case *)
  END; (* loop *)
END Conrs;


PROCEDURE Pwr(x, exp: CARDINAL): CARDINAL;
VAR i, y: CARDINAL;
BEGIN
  y:= x;
(*  ConCard(x); ConOut('^'); ConCard(exp); ConOut('='); *)
  IF exp = 0 THEN y:= 1;
  ELSIF exp > 1 THEN
    FOR i:= 2 TO exp DO
      y:= y*x;
    END; (* for *)
  END; (* if *) (* note: if exp=1 then y just stays as x *)
(*  ConCard(y);
  ConIn(a); *) 
  RETURN y;
END Pwr;


PROCEDURE Cardtostrg(x: CARDINAL; VAR cardstrg: ARRAY OF CHAR);
VAR i, place: CARDINAL;
    big: BOOLEAN;
BEGIN
  i:= 0;
  big:= FALSE;
  FOR place:= 5 TO 1 BY -1 DO
    IF (x >= Pwr(10, place)) OR big THEN
      cardstrg[i]:= CHR(x DIV Pwr(10, place) + 48);
      x:= x MOD Pwr(10, place);
      big:= TRUE;
      i:= i + 1;
    END; (* if *)
  END; (* for place=5 to 1 *)
  cardstrg[i]:= CHR(x + 48);
  cardstrg[i + 1]:= CHR(0);
END Cardtostrg;


PROCEDURE Card(a: CHAR): CARDINAL;
BEGIN
  RETURN ORD(a)-48;
END Card;
(* this is only good for a one-digit number *)


PROCEDURE Strgtocard(cardstrg: ARRAY OF CHAR): CARDINAL;
VAR i, x, y: CARDINAL;
BEGIN
  x:= 0;
  y:= 0;
  i:= 0;
  WHILE cardstrg[i] <> CHR(0) DO
    y:= Card(cardstrg[i]);
    x:= x * 10 + y;
    INC(i);
  END; (* while *)
  RETURN x;
END Strgtocard;


PROCEDURE Sort;
VAR i, j: CARDINAL;
BEGIN
  CR;
  ConWS('Sorting...'); CR;
  i:= 1;
  REPEAT
    FOR j:= i + 1 TO max DO
(*      ConWS(substrg[i]); *)
      IF Compare(substrg[j], substrg[i]) = Less THEN (* switch them *)
        Assign(buffer, strg[i]);
        Assign(strg[i], strg[j]);
        Assign(strg[j], buffer);
        Assign(buffer, substrg[i]);
        Assign(substrg[i], substrg[j]);
        Assign(substrg[j], buffer);
(*      ConWS(' < '); *)
      END; (* if less *)
(*      ConOut(' ');
      ConWS(substrg[j]); CR; *)
    END; (* for j *)
    Cardtostrg(i, cardstrg);
    ConWS(cardstrg);
    ConWS('= ');
    ConWS(substrg[i]);
    CR;
    INC(i);
  UNTIL i = max+1;
  ConWS('Done sorting.'); CR;
END Sort;


PROCEDURE Flength(fname: ARRAY OF CHAR): CARDINAL;
VAR address: ADDRESS;
    result: INTEGER;
    longaddress: POINTER TO LONGCARD;
BEGIN
  NEW(longaddress);
  SFirst(fname, 0, result);
  GetDTA(address);
  longaddress:= address + 26;
  RETURN CARDINAL(longaddress^);
(*ConWS('writelongcard: ');
  WriteLongCard(length, 0);
  clength:= CARDINAL(length);
  ConWS('writecard: ');
  WriteCard(clength, 0);
  Cardtostrg(clength, cardstrg);
  ConWS('cardstrg: ');
  ConWS(cardstrg);
*)
END Flength;


PROCEDURE Getfile;
VAR i: CARDINAL;
BEGIN
  i:= 0;
  REPEAT (* get file name *)
    INC(i);
    CR;
    ConWS('File to sort: ');
    Conrs(fname); CR;
    ConWS('Getting file length...');
    flen:= Flength(fname);
    Cardtostrg(flen, cardstrg);
    ConWS(cardstrg); CR;
    ConWS('Opening: ');
    ConWS(fname); CR;
    Open(fname, 0, handle);
    IF handle < 0 THEN
      ConWS('ERROR: -');
      Cardtostrg(VAL(CARDINAL, ABS(handle)), cardstrg);
      ConWS(cardstrg);
      IF handle = -33 THEN ConWS('  file not found.'); END;
      CR;
      IF i > 2 THEN ConWS("3 strikes, you're out."); HALT; END; (* if *)
    END; (* if error *)
  UNTIL handle > 0;
END Getfile;


PROCEDURE Intro(VAR continue: BOOLEAN);
VAR a: CHAR;
BEGIN
  CR;
  ConWS('         SORTER version 1.0'); CR; CR;
  ConWS(' Written by Craig Harvey with TDI Modula-2.'); CR;
  ConWS('   The CLEAR THINKING BBS 313-761-2444'); CR;
  ConWS(' Ann Arbor, Michigan  3/1200 baud  24 hrs'); CR; CR;
  ConWS('          Sorts any text file on a column range of your choice');
  CR;
  ConWS('            as long as each line ends with a Carriage Return.');
  CR;
  ConWS(' (e.g. a BBS list with the phone numbers in the same columns of each  line)'); CR; CR;
  ConWS(' ** Maximum file length = 64K, max line length = 80 **'); CR;
  ConWS(' ** max lines = 2000    max sort string length = 20 **'); CR; CR;
  ConWS(' Hit [Esc]ape or [Q]uit to quit or any other key to continue.'); CR;
  ConIn(a);
  IF (a = CHR(27)) OR (CAP(a) = 'Q') THEN continue:= FALSE;
   ELSE continue:= TRUE;
  END; (* if *)
END Intro;


BEGIN
  i:= 1;
  count:= 1;
  Intro(continue);
IF continue THEN (* do the deal *)
  
  Getfile;
  ConWS(' Sort string starts at what column [1]: ');
  Conrs(cardstrg); CR; CR;
(*ConWS('startstrg = ');
  ConWS(cardstrg); ConOut('!'); CR;
*)
  IF cardstrg[0] = CHR(0) THEN start:= 0;
   ELSE start:= Strgtocard(cardstrg) - 1;
  END; (* if *)
(*  ConWS('starting column = ');
  Cardtostrg(start + 1, cardstrg);
  ConWS(cardstrg);
  CR;
*)
  ConWS(' Length of sort string [12]: ');
  Conrs(cardstrg);
  IF cardstrg[0] = CHR(0) THEN length:= 12;
   ELSE length:= Strgtocard(cardstrg);
  END; (* if *)
  CR; CR;
  ConWS(' Reading file...'); CR;
  k:= 0; (* counter of bytes of file *)
  LOOP (* read file into array, until eof *)
    j:= 0;
    ConOut('.');
    REPEAT (* until eol *)
      INC(k);
      Read(handle, count, ADR(ch));
      strg[i, j]:= ch;
      INC(j);
    UNTIL (ch = CHR(10)) OR (k >= flen);
    IF ch = CHR(10) THEN strg[i, j]:= CHR(0); INC(i); END; (* if *)
    IF k >= flen THEN EXIT; END; (* if *)
(*    Cardtostrg(i-1, cardstrg);
    ConWS('strg[');
    ConWS(cardstrg);
    ConOut(']');
    ConWS('= ');
    ConWS(strg[i-1]);
    Cardtostrg(k, cardstrg);
    ConWS(cardstrg);
    CR; *)
  END; (* loop *)
  CR;
  IF Close(handle) THEN ConWS('done reading, hit a key.'); CR;
   ELSIF NOT Close(handle) THEN ConWS('** Not closed for some reason **');
  END; (* if *)
  ConIn(a);
  max:= i - 1;
  Cardtostrg(max, cardstrg);
  ConWS(cardstrg);
  ConWS(' lines to be sorted. Hit a key.');
  ConIn(a); CR;
  ConWS('Getting sort strings... '); CR;
  FOR i:= 1 TO max DO
    FOR j:= 0 TO length - 1 DO
(*    Cardtostrg(j, cardstrg);
      ConWS('j= ');
      ConWS(cardstrg); CR; *)
      substrg[i, j]:= strg[i, start + j];
    END; (* for j *)
    substrg[i, length]:= CHR(0);
(*    Cardtostrg(i, cardstrg);
    ConWS(cardstrg);
    ConOut(' ');
    ConWS(substrg[i]);
    ConOut('!');
    CR;
*)
  END; (* for i *)

  Sort;

  Create('SORTED.NEW', 0, handle);
  i:= 0;
  j:= 0;
  ConWS('Writing to new file: SORTED.NEW  please wait...'); CR;
  REPEAT (* until done *)
    INC(i);
    j:= 0;
(*  Cardtostrg(i, cardstrg);
    ConWS(cardstrg); CR; 
    ConWS(strg[i]);
*)
    LOOP
      ch:= strg[i, j];
      IF ch = CHR(0) THEN EXIT;
       ELSE Write(handle, count, ADR(ch));
            INC(j);
      END; (* if *)
    END; (* loop *)
  UNTIL i >= max;
  IF Close(handle) THEN ConWS('New file written. Hit a key.');
  END; (* if *)
  ConIn(a);
  
END; (* if continue *)
END Sorter.
