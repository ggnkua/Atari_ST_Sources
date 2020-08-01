MODULE In;

(*****************************************************************************)
(* Oakwood-like In.                                                          *)
(* --------------------------------------------------------------------------*)
(* Simple, formatted input of characters, strings and numbers.               *)
(* --------------------------------------------------------------------------*)
(* 30-Okt-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

(* Basic character input is done through module IO. 'Char' uses 'IO.ReadChar',
   the other procedures use 'IO.ReadString'. Therefore every input operation,
   except 'Char', reads a complete line, which has to be terminated with CR
   right after the item to be read. Also there is no end-of-file condition.
   This is unlike the stream oriented ETH original, but is more suited
   for interactive input (in fact it's only suited for interactive input).

   'Open' only sets Done to TRUE.
   'Name' simply reads a sequence of characters.
   The syntax of the number input routines is somewhat relaxed.
   Beside these, the behaviour should conform to the Oakwood guidelines.
   For further information, please refer to OAKWOOD.TXT or have a look at
   the sources.
 *)

IMPORT S:=SYSTEM, IO, FConvBase, LowReal, LowLong, ConvTypes;

CONST
  CR = 0DX;
  LF = 0AX;
  HT = 09X;

VAR
  Done- : BOOLEAN;

  line  : ARRAY 256 OF CHAR;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE readline ((* -- /AUS *) VAR start : INTEGER );

VAR c : CHAR;
    i : INTEGER;

BEGIN
 IO.ReadString(line);
 i := 0;
 REPEAT
   c := line[i];
   INC(i);;
 UNTIL (c # ' ') & (c # CR) & (c # LF) & (c # HT);
 start := i - 1;
END readline;

(*---------------------------------------------------------------------------*)

PROCEDURE Open*;
BEGIN
 Done := TRUE;
END Open;

(*---------------------------------------------------------------------------*)

PROCEDURE Char* ((* -- /AUS *) VAR ch : CHAR );
BEGIN
 IF Done THEN
   ch := IO.ReadChar();
 END;
END Char;

(*---------------------------------------------------------------------------*)

PROCEDURE String* ((* -- /AUS *) VAR str : ARRAY OF CHAR );

VAR c     : CHAR;
    i     : INTEGER;
    start : INTEGER;
    len   : INTEGER;

BEGIN
 IF Done THEN
   readline(start);
   IF line[start] = '"' THEN
     i := start;
     INC(start);
     REPEAT
       INC(i);
       c := line[i];
     UNTIL (c < ' ') OR (c = '"');
     len := i - start;
     IF (c = '"') & (line[i+1] = 0X) & (len < LEN(str)) THEN
       S.MOVE(S.ADR(line[start]), S.ADR(str), len);
       str[len] := 0X;
     ELSE
       Done := FALSE;
     END;
   ELSE
     Done := FALSE;
   END;
 END;
END String;

(*---------------------------------------------------------------------------*)

PROCEDURE Name* ((* -- /AUS *) VAR str : ARRAY OF CHAR );

VAR c     : CHAR;
    i     : INTEGER;
    start : INTEGER;
    len   : INTEGER;

BEGIN
 IF Done THEN
   readline(start);
   IF line[start] > ' ' THEN
     i := start;
     REPEAT
       INC(i);
       c := line[i];
     UNTIL c < ' ';
     len := i - start;
     IF (len < LEN(str)) & (line[i] = 0X) THEN
       S.MOVE(S.ADR(line[start]), S.ADR(str), len);
       str[len] := 0X;
     ELSE
       Done := FALSE;
     END;
   ELSE
     Done := FALSE;
   END;
 END;
END Name;

(*---------------------------------------------------------------------------*)

PROCEDURE LongInt* ((* - /AUS *) VAR li : LONGINT );

VAR c            : CHAR;
    i            : INTEGER;
    first        : INTEGER;
    last         : INTEGER;
    isHex        : BOOLEAN;
    hexDig       : BOOLEAN;
    neg          : BOOLEAN;
    maxLastDigit : LONGINT;
    maxDivTen    : LONGINT;
    val          : LONGINT;
    num          : LONGINT;
    tmp          : LONGINT;

BEGIN
 IF Done THEN
   readline(i);
   neg := line[i] = '-';
   IF neg OR (line[i] = '+') THEN
     INC(i);
   END;
   IF (line[i] >= '0') & (line[i] <= '9') THEN
     (* Fuehrende Nullen ueberlesen *)
     WHILE line[i] = '0' DO
       INC(i);
     END;
     isHex := FALSE;
     first := i;
     DEC(i); (* Wegen REPEAT-Schleife *)
     REPEAT
       INC(i);
       c      := CAP(line[i]);
       hexDig := (c >= 'A') & (c <= 'F');
       isHex  := isHex OR hexDig;
     UNTIL (c < '0') OR (c > '9') & ~hexDig;
     last := i - 1;
     IF isHex & (c # 'H') THEN
       Done := FALSE;
       RETURN;
     END;
     IF c = 'H' THEN
       isHex := TRUE;
       INC(i);
     END;
     IF line[i] # 0X THEN
       Done := FALSE;
       RETURN;
     END;

     val := 0;
     IF first <= last THEN
       i := first;
       IF isHex THEN
         IF neg & (line[i] > '7') OR (last - first > 7) THEN
           (* Ueberlauf *)
           Done := FALSE;
           RETURN;
         END;
         FOR i := first TO last DO
           c := CAP(line[i]);
           (* Durch die Oder-Funktion statt Addition kann vorzeichenlos
            * gewandelt werden.
            *)
           IF c > '9' THEN
             val := S.ORL(S.LSH(val, 4), ORD(c) - ORD('A') + 10);
           ELSE
             val := S.ORL(S.LSH(val, 4), ORD(c) - ORD('0'));
           END;
         END;
       ELSE
         maxDivTen := MAX(LONGINT) DIV 10;
         IF neg THEN
           maxLastDigit := MAX(LONGINT) MOD 10 + 1;
         ELSE
           maxLastDigit := MAX(LONGINT) MOD 10;
         END;
         FOR i := first TO last DO
           num := ORD(line[i]) - ORD('0');
           IF    (val < maxDivTen)
              OR (val = maxDivTen) & (num <= maxLastDigit)
           THEN
             (* val := val * 10 + num; *)
             INC(val, val);
             tmp := val;
             INC(val, val);
             INC(val, val);
             INC(val, tmp);
             INC(val, num);
           ELSE
             (* Ueberlauf *)
             Done := FALSE;
             RETURN;
           END;
         END;
       END;
     END;
     IF neg THEN
       val := -val;
     END;
     li := val;
   ELSE
     Done := FALSE;
   END;
 END;
END LongInt;

(*---------------------------------------------------------------------------*)

PROCEDURE Int* ((* -- /AUS *) VAR i : INTEGER );

VAR li : LONGINT;

BEGIN
 LongInt(li);
 IF Done & (li >= MIN(INTEGER)) & (li <= MAX(INTEGER)) THEN
   i := SHORT(li);
 ELSE
   Done := FALSE;
 END;
END Int;

(*---------------------------------------------------------------------------*)

PROCEDURE LongReal* ((* -- /AUS *) VAR lr : LONGREAL );

VAR i   : INTEGER;
    res : SHORTINT;

BEGIN
 IF Done THEN
   readline(i);
   S.MOVE(S.ADR(line[i]), S.ADR(line), SIZE(line) - i);
   lr := SHORT(FConvBase.strToReal(line,
                                   LowLong.small,
                                   FConvBase.MinLExp,
                                   LowLong.large,
                                   FConvBase.MaxLExp,
                                   res));
   Done := res = ConvTypes.strAllRight;
 END;
END LongReal;

(*---------------------------------------------------------------------------*)

PROCEDURE Real* ((* -- /AUS *) VAR r : REAL );

VAR i   : INTEGER;
    res : SHORTINT;

BEGIN
 IF Done THEN
   readline(i);
   S.MOVE(S.ADR(line[i]), S.ADR(line), SIZE(line) - i);
   r := SHORT(FConvBase.strToReal(line,
                                  LowReal.small,
                                  FConvBase.MinExp,
                                  LowReal.large,
                                  FConvBase.MaxExp,
                                  res));
   Done := res = ConvTypes.strAllRight;
 END;
END Real;

BEGIN
 Done := FALSE;
END In.
