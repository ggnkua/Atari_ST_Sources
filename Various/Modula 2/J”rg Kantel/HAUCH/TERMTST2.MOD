MODULE TermTst2;
(* Testet die Eingabe-Mîglichkeiten des Modules
   TermWindow.
   Autor: Jîrg Kantel
   (c) MAXON Computer 1993
*)

FROM TermWindow IMPORT InitTerminal,
                       OpenTerminal,
                       CloseTerminal,
                       DeleteTerminal, NewTitle,
                       WriteString,
                       Write, WriteLn, Read;
FROM RealInOut  IMPORT StringToReal,
                       RealToStringFixed;
(* "RealInOut" ist aus "Modula.LPR", Maxon-
   PD 247.
*)

TYPE String = ARRAY[1..20] OF CHAR;

VAR  c             : CHAR;
     s             : String;
     i             : CARDINAL;
     r             : REAL;
     zahl          : BOOLEAN;

   PROCEDURE ReadString(VAR s : String);
   (* Liest einen String ein, der mit einem
      Leerzeichen oder mit [ENTER] abgeschlos-
      sen wird. Die maximale LÑnge des Strings
      wird in TYPE String vereinbart.
      WÑhrend der Eingabe des Strings kann mit
      [Backspace] korrigiert werden.
    *)
   VAR c : CHAR;
       i : INTEGER;
   BEGIN
      i := 1;
      REPEAT
          Read(c); Write(c);
          IF (i <= 20) THEN s[i] := c; END;
          IF ((i > 1) AND (c = 10C)) THEN
          (* Eingabe Backspace? *)
             i := i - 1;
          ELSE
             i := i + 1;
          END;
      UNTIL ((c = ' ') OR (c = 15C));
      s[i-1] := CHR(0C);
   END ReadString;

   PROCEDURE ReadReal(VAR s : String;
                      VAR r : REAL) : BOOLEAN;
   (* Prozedur liest einen String ein und kon-
      vertiert ihn zu einer Real-Zahl. Dabei
      werden Komma oder Dezimalpunkt ebenso
      berÅcksichtigt, wie die Exponent-/Man-
      tisse-Darstellung (25e-10, 25E10 etc.)
      Der String wird auf jeden Fall zurÅck-
      gegeben - auch wenn ein Fehler auftritt.
   *)
   VAR c  : CHAR;
       i  : INTEGER;
       ok : BOOLEAN;
   BEGIN
      i := 1;
      REPEAT
          Read(c); Write(c);
          IF (i <= 20) THEN s[i] := c; END;
          IF (c = ',') THEN s[i] := '.'; END;
          IF (c = 'e') THEN s[i] := 'E'; END;
          IF ((i > 1) AND (c = 10C)) THEN
          (* Eingabe Backspace? *)
             i := i - 1;
          ELSE
             i := i + 1;
          END;
      UNTIL ((c = ' ') OR (c = 15C));
      s[i-1] := CHR(0C);
      StringToReal(s, r, ok);
      RETURN ok;
   END ReadReal;

BEGIN
   InitTerminal(TRUE);
   NewTitle('Ein- und Ausgabe-Test');
   OpenTerminal(8,20, 230,380);

   WriteLn;
   WriteString('     Terminal-Test       ');
   WriteLn;
   WriteString('-------------------------');
   WriteLn;
   WriteString('Geben Sie ein Wort ein: ');
   WriteLn;
   WriteString('\>');
   ReadString(s);
   WriteLn;
   WriteString('Die Eingabe lautet: ');
   WriteLn;
   WriteString(' '); WriteString(s); WriteLn;

   WriteLn;
   WriteString('Und nun eine Zahl: ');WriteLn;
   WriteString('\>');
   zahl := ReadReal(s, r);
   WriteLn;
   WriteString('Ihre Eingabe: ');WriteLn;
   WriteString(' '); WriteString(s); WriteLn;
   WriteLn;
   IF (NOT zahl) THEN
      WriteString(s);
      WriteString(' ist nicht korrekt!');
   ELSE
      r := r*r;
      RealToStringFixed(s, r, 12,4);
      WriteString('Die Eingabe quadriert: ');
      WriteLn;
      WriteString(s);
   END;
   WriteLn;

   WriteLn;
   WriteString('Und nun das Scrollen:'); WriteLn;
   WriteString('Weiter mit [ENTER]');    WriteLn;
   WriteString('\>');
   REPEAT Read(c) UNTIL (c = 15C);

   WriteLn;
   FOR i := 1 TO 100 DO
      WriteString('Test'); WriteLn;
   END;
   WriteLn;
   WriteString('Das waren 100 Zeilen.'); WriteLn;
   WriteLn;

   WriteLn;
   WriteString('Ende mit ESC'); WriteLn;
   WriteString('\>');
   REPEAT Read(c) UNTIL (c = 33C);
   CloseTerminal;
   DeleteTerminal;

END TermTst2.
