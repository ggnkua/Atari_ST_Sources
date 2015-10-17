MODULE SpaltenSatz;
(*$E MOS *)

(*
 * Fgt entweder die Texte zweier Dateien nebeneinander zusammen
 * oder bereitet einen Text fr zweispaltigen Druck vor.
 *
 * V1.2: Nun fehlen nicht mehr die letzten Zeilen, die nur Text in der
 *       1. Spalte fllen.
 *
 * V1.3: Wird ein Argument bergeben, wird der Text der Datei zweispaltig
 *       (80 Zeichen pro Spalte f. 139 Zl/Seite) unter dem selben Namen mit
 *       der Endung ".2" erzeugt.
 *       Aužerdem wird kein FF mehr am Dateiende erzeugt und vor einem FF
 *       steht kein CR/LF mehr.
 *)

IMPORT GEMDOSIO;
FROM ArgCV IMPORT InitArgCV, PtrArgStr;
FROM InOut IMPORT Write, WriteLn, WriteString, WriteInt, WriteCard,
        ReadString, ReadCard, ReadInt;
IMPORT Files, Text;
FROM Strings IMPORT Append, DelTrailingBlanks, Copy, Assign;
FROM FileNames IMPORT ConcatName;

(*
 * Mischt zwei Textfiles so, daž die Zeilen der 2. Datei rechts neben
 * der 1. erscheinen.
 *)

TYPE String = ARRAY [0..255] OF CHAR;

VAR spc, s1, s2, s3: String;
    firstSide, ok, second, onefile, buffered: BOOLEAN;
    f1, f2, f3: Files.File;
    n: INTEGER;
    ofs, lps, line, bufferedlines: INTEGER;
    linebuf: ARRAY [1..200] OF String;
    argc: CARDINAL;
    argv: ARRAY [0..2] OF PtrArgStr;

PROCEDURE flush;
  VAR l: INTEGER;
  BEGIN
    IF NOT firstSide & (bufferedlines > 0) THEN
      Text.WritePg (f3);
    END;
    FOR l:= 1 TO bufferedlines DO
      Text.WriteString (f3, linebuf[l]);
      IF l = bufferedlines THEN
        Text.Write (f3, CHR(13)); (* CR ohne LF *)
      ELSE
        Text.WriteLn (f3)
      END;
    END;
    firstSide:= FALSE;
    bufferedlines:= 0;
    line:= 1
  END flush;

BEGIN
  FOR n:= 0 TO SIZE (spc)-1 DO
    spc[n]:= ' '
  END;
  WriteString ("Spaltensatz V1.3"); WriteLn; WriteLn;
  InitArgCV (argc, argv);
  IF (argc = 2) THEN
    Files.Open (f1, argv[1]^, Files.readSeqTxt);
    WriteString ("Eingabedatei: "); WriteString (argv[1]^); WriteLn;
    IF Files.State (f1) < 0 THEN
      WriteString ('Fehler!');
      WriteLn;
      RETURN
    END;
    ConcatName (argv[1]^, "2", s1);
    WriteString ("Ausgabedatei: "); WriteString (s1); WriteLn;
    Files.Create (f3, s1, Files.writeSeqTxt, Files.replaceOld);
    IF Files.State (f3) < 0 THEN
      WriteString ('Fehler!');
      WriteLn;
      Files.Close (f2);
      Files.Close (f1);
      RETURN
    END;
    second:= FALSE;
    onefile:= TRUE;
    ofs:= 80;
    lps:= 139;
  ELSE
    WriteString ("1. Datei? ");
    ReadString (s1);
    Files.Open (f1, s1, Files.readSeqTxt);
    IF Files.State (f1) < 0 THEN
      WriteString ('Fehler!');
      WriteLn;
      RETURN
    END;
    WriteString ("2. Datei (oder nix)? ");
    ReadString (s1);
    second:= s1[0] # '';
    onefile:= ~second;
    IF second THEN
      Files.Open (f2, s1, Files.readSeqTxt);
      IF Files.State (f2) < 0 THEN
        WriteString ('Fehler!');
        WriteLn;
        Files.Close (f1);
        RETURN
      END;
    END;
    WriteString ("Ausgabedatei? ");
    ReadString (s1);
    Files.Create (f3, s1, Files.writeSeqTxt, Files.replaceOld);
    IF Files.State (f3) < 0 THEN
      WriteString ('Fehler!');
      WriteLn;
      Files.Close (f2);
      Files.Close (f1);
      RETURN
    END;
    WriteString ("Spaltenoffset? ");
    ReadInt (ofs);
    IF ofs = 0 THEN Files.Close (f3); Files.Close (f2); Files.Close (f1); RETURN END;
    WriteString ("Zeilenanzahl pro Seite (0 f. unendlich)? ");
    ReadInt (lps);
    IF onefile & (lps = 0) THEN
      WriteString ("Bei 1-File-Spaltendruck nicht erlaubt!");
      WriteLn;
      Files.Close (f3); Files.Close (f2); Files.Close (f1); RETURN
    END;
  END;
  buffered:= onefile OR (lps > 0);
  line:= 1;
  bufferedlines:= 0;
  firstSide:= TRUE;
  LOOP
    Text.ReadFromLine (f1, s1);
    IF ~Files.EOF (f1) THEN Text.ReadLn (f1) END;
    s2:= '';
    IF onefile THEN
      IF second THEN
        s2:= s1;
        s1:= linebuf[line]
      END;
    ELSIF second THEN
      Text.ReadFromLine (f2, s2);
      second:= ~Files.EOF (f2);
      IF second THEN
        Text.ReadLn (f2);
        second:= ~Files.EOF (f2);
      END;
    END;
    Copy (spc, 0, ofs-INT(LENGTH (s1)), s3, ok);
    Append (s3, s1, ok);
    IF LENGTH(s2) # 0 THEN s1[ofs]:= 0C END;
    Append (s2, s1, ok);
    DelTrailingBlanks (s1);
    IF buffered THEN
      linebuf[line]:= s1;
      IF line > bufferedlines THEN bufferedlines:= line END;
      IF line = lps THEN
        IF onefile THEN
          IF ~second THEN
            second:= TRUE;
            line:= 1;
          ELSE
            second:= FALSE;
            flush;
          END
        ELSE
          flush;
        END
      ELSE
        INC (line)
      END
    ELSE
      Text.WriteString (f3, s1);
      Text.WriteLn (f3);
    END;
    IF Files.EOF (f1) THEN EXIT END;
  END;
  IF buffered THEN
    flush;
  END;
  Files.Close (f3);
  Files.Close (f2);
  Files.Close (f1);
END SpaltenSatz.
