MODULE MM2Comp43C_Patch;
(*
 * Patch-Programm fÅr Megamax Modula-2 zum Compiler 4.3c.
 *
 * Dieses Programm korrigiert einen Fehler im Compiler 4.3c:
 *  Bei Verwendung von verschachtelten Value-Constructors
 *  meldet der Compiler u.U. einen internen Fehler, wÑhrend
 *  Ñltere Versionen hier kein Problem hatten.
 *
 * Im Compiler muû lediglich das Wort auf Offset $43EA in
 * "MM2COMP.IMP" von $670A auf $670C geÑndert werden.
 * Das erledigt dieses Programm fÅr diejenigen, die es nicht
 * mit einem BinÑrdatei-Editor manuell erledigen wollen.
 * Einfach dieses Programm Åbersetzen und von der Shell aus
 * starten. Es sucht den Compiler in den von der Shell ver-
 * wendeten Suchpfaden und korrigiert das File "MM2COMP.IMP"
 * entsprechend.
 *
 * Die korrigierte Version erhÑlt die Versionsnr. 4.3d
 *)

FROM SYSTEM IMPORT ADR;
FROM Paths IMPORT ListPos, SearchFile;
FROM ShellMsg IMPORT CompilerParm, ShellPath, StdPaths;
FROM Strings IMPORT String, Assign;
FROM InOut IMPORT WriteString, WriteLn, Read;
FROM Files IMPORT Open, Close, Access, File;
FROM Binary IMPORT ReadBytes, WriteBytes, FileSize, Seek, SeekMode;
FROM PathEnv IMPORT HomePath;


CONST len = 79590;
      ofs = $43EA;
      ver = $1F1C;

VAR buf: ARRAY [0..40000] OF CARDINAL;
    found: BOOLEAN;
    name: ARRAY [0..132] OF CHAR;
    l: LONGCARD;
    f: File;

PROCEDURE wait;
  VAR c: CHAR;
  BEGIN
    WriteLn; WriteString ("Taste..."); Read (c);
    Close (f);
  END wait;

BEGIN
  HomePath:= ShellPath; (* um die "*" richtig zu interpretieren *)
  SearchFile (CompilerParm.name (* oder: "MM2COMP.IMP" *),
              StdPaths, fromStart, found, name);
  IF ~found THEN
    WriteString ('"'); WriteString (CompilerParm.name);
    WriteString ('" ist nicht zu finden!');
    wait; RETURN;
  END;
  Open (f, name, readWrite);
  IF FileSize (f) # len THEN
    WriteString ('"'); WriteString (name);
    WriteString ('" hat falsche LÑnge - ist es wirklich V4.3c?');
    wait; RETURN;
  END;
  ReadBytes (f, ADR (buf), len, l);
  IF l # len THEN HALT (* nanu? *) END;
  IF buf[ofs DIV 2] = $670C THEN
    WriteString ('"'); WriteString (name);
    WriteString ('" ist bereits gepatcht.');
    wait; RETURN;
  END;
  IF (buf[ofs DIV 2] # $670A) OR (buf[ver DIV 2] # $6300) THEN
    WriteString ('"'); WriteString (name);
    WriteString ('" scheint nicht V4.3c zu sein!');
    wait; RETURN;
  END;
  buf[ofs DIV 2]:= $670C;  (* Dies ist der notwendige Patch *)
  buf[ver DIV 2]:= $6400;  (* Versionsnr. auf 4.3d Ñndern *)
  Seek (f, 0, fromBegin);
  WriteBytes (f, ADR (buf), len);
  Close (f);
  WriteString ('"'); WriteString (name);
  WriteString ('" wurde erfolgreich gepatcht.');
  wait;
END MM2Comp43C_Patch.
