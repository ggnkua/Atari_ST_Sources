MODULE Traces;

(* Ausgabe von Traces
| Datum     Version Autor   Aktion
| -----     ------- -----   ------
| 14.05.94  1.00    Ra      Erste freigegebene Version
| 04.03.95  1.01    SJ      StrLn und Dump hinzugefgt
*)


IMPORT
  S:=SYSTEM, IO, XBIOS;


VAR
  address : S.PTR;
  Byte: SHORTINT;


PROCEDURE CR*  (* Ausgabe von CR *);
BEGIN
  IO.WriteLn;
END CR;

PROCEDURE I* (* Ausgabe einer Zahl *)
  (n   :  LONGINT             (* auszugebende Zahl *)
  );
BEGIN
  IO.WriteInt(n);
END I;


PROCEDURE I1* (* Ausgabe einer Zahl mit Erl„uterungstext *)
  ( t   :  ARRAY OF CHAR       (* Erl„uterungstext *);
    n   :  LONGINT             (* auszugebende Zahl *)
  );
BEGIN
  IO.WriteString (t); IO.WriteString (" : ");
  IO.WriteInt(n);
END I1;


PROCEDURE I1cr* (* Ausgabe einer Zahl mit Erl„uterungstext und CR *)
  ( t   :  ARRAY OF CHAR       (* Erl„uterungstext *);
    n   :  LONGINT             (* auszugebende Zahl *)
  );
BEGIN
  I1(t,n);
  IO.WriteLn     (* CR, LF *);
END I1cr;

PROCEDURE XY* (* Ausgabe von 2 LongInt in Klammern *)
  ( k,l         :  LONGINT              (* auszugebende Zahlen *)
  );
BEGIN
  IO.WriteChar ("(");
  IO.WriteInt(k); IO.WriteChar(",");
  IO.WriteInt(l); IO.WriteChar (")");
END XY;


PROCEDURE I2* (* Ausgabe von 2 LongInt mit Erl„uterungstext *)
  ( t           :  ARRAY OF CHAR        (* Erl„uterungstext *);
    k,l         :  LONGINT              (* auszugebende Zahlen *)
  );
BEGIN
  IO.WriteString (t); IO.WriteString (" : ");
  IO.WriteInt(k); IO.WriteChar(",");
  IO.WriteInt(l);
END I2;

PROCEDURE I2cr* (* Ausgabe von 2 LongInt mit Erl„uterungstext und CR *)
  ( t           :  ARRAY OF CHAR        (* Erl„uterungstext *);
    k,l         :  LONGINT              (* auszugebende Zahlen *)
  );
BEGIN
  I2(t,k,l);
  IO.WriteLn     (* CR, LF *);
END I2cr;


PROCEDURE I4* (* Ausgabe von 4 LongInt mit Erl„uterungstext *)
  ( t           :  ARRAY OF CHAR        (* Erl„uterungstext *);
    k,l,m,n     :  LONGINT              (* auszugebende Zahlen *)
  );
BEGIN
  IO.WriteString (t); IO.WriteString (" : ");
  IO.WriteInt(k); IO.WriteChar(",");
  IO.WriteInt(l); IO.WriteChar(",");
  IO.WriteInt(m); IO.WriteChar(",");
  IO.WriteInt(n);
END I4;


PROCEDURE I4cr* (* Ausgabe von 4 LongInt mit Erl„uterungstext und CR *)
  ( t           :  ARRAY OF CHAR        (* Erl„uterungstext *);
    k,l,m,n     :  LONGINT              (* auszugebende Zahlen *)
  );
BEGIN
  I4(t,k,l,m,n);
  IO.WriteLn     (* CR, LF *);
END I4cr;


PROCEDURE Str* (* Ausgabe eines Strings *)
  ( s           :  ARRAY OF CHAR        (* Auszugebender Text *));
BEGIN
  IO.WriteString (s);
END Str;


PROCEDURE StrLn* (* Ausgabe eines Strings mit LineFeed *)
  ( s			:  ARRAY OF CHAR 		(* Auszugebender Text *));
BEGIN
  IO.WriteString (s); IO.WriteLn;
END StrLn;

(*$-k *)

PROCEDURE GetByte;
 BEGIN
  S.GET(address, Byte);
 END GetByte;

(*$+k *)

PROCEDURE Dump*(t: ARRAY OF CHAR; dumpAd : S.PTR; bytes : LONGINT);
(*
 Dump bytes at dumpAd. Works with protected memory (i.e. memory which can
 only be accessed in supervisor mode).
 *)
  VAR
    i : INTEGER;
    ascii : ARRAY 18 OF CHAR;
 BEGIN
  IO.WriteString( t); IO.WriteLn;
  REPEAT
    IO.WriteFInt(dumpAd,16,IO.right,8,"0");
    IO.WriteString("  "); i := 0;
    REPEAT
      address := dumpAd;
      XBIOS.Supexec(GetByte);
      IO.WriteFInt(S.LONG(Byte), 16, IO.right, 2, "0");
      IF (Byte >= 0) AND (Byte < 20H) THEN ascii[i] := 0FAX
      ELSE ascii[i] := CHR(Byte)
      END;
      IO.WriteChar(" "); INC(i); INC(dumpAd);
      IF i = 8 THEN IO.WriteChar(" ") END;
      DEC(bytes);
    UNTIL (i = 16) OR (bytes = 0);
    ascii[i] := 0X;
    IF i < 8 THEN IO.WriteChar(" ") END;
    WHILE i < 16 DO IO.WriteString("   "); INC(i) END;
    IO.WriteChar("|");
    IO.WriteString(ascii);
    IO.WriteChar("|");
    IO.WriteLn;
  UNTIL bytes = 0;
 END Dump;


END Traces.