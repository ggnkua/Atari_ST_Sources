MODULE Conv_M2P;

(*
 * Paût M2P-Dateien automatisch auf neues Format an, wenn die neue Shell die
 * Dateien sonst nicht mehr akzeptiert.
 *
 * Anwendung: Programm Åbersetzen und starten, dann mit dem File-Selektor
 * die Verzeichnisse mit den M2P-Dateien aufsuchen und <OK> anklicken.
 * Wiederholen, bis alle M2P-Dateien konvertiert. Dann <Abbruch> anklicken.
 *)

IMPORT Block;
FROM EasyGEM0 IMPORT ShowArrow, FormAlert;
FROM EasyGEM1 IMPORT SelectFile, SelectMask;
FROM MOSGlobals IMPORT fNoMatchingFiles, PathStr, FileStr;
IMPORT Files, Binary;
FROM FuncStrings IMPORT ConcStr;
FROM Directory IMPORT Delete, DirQuery, DirQueryProc, DirEntry, FileAttrSet,
        QueryFiles, SetFileAttr;
FROM FileNames IMPORT SplitPath, PathConc;
FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD;

VAR ok: BOOLEAN; name: FileStr; but: CARDINAL; f: Files.File;
    buf: ARRAY [1..60000] OF BYTE;

PROCEDURE process (REF path: ARRAY OF CHAR; dir: DirEntry): BOOLEAN;
  
  VAR origlen, len: LONGCARD; (*$Reg*)p: POINTER TO LONGCARD;
      name: FileStr;
      en, st: ADDRESS;
  
  PROCEDURE copy (ofs, add: LONGCARD);
    BEGIN
      st:= ADR(buf)+ofs;
      en:= ADR(buf)+len;
      Block.Copy (st, len-ofs, st+add);
      Block.Clear (st, add);
      INC (len, add);
    END copy;
    
  BEGIN
    name:= PathConc (path, dir.name);
    Files.Open (f, name, Files.readOnly);
    Binary.ReadBytes (f, ADR (buf), SIZE (buf), len);
    IF len > SIZE (buf)-10000 THEN HALT (* Puffer ist zu klein *) END;
    Files.Close (f);
    origlen:= len;
    p:= ADR (buf);
    IF p^ = 10071898L + 00600000000L THEN (* MM2SHELL.M2P bis V2.2f *)
      copy ($108E, 2*80+2);
      p^:= 10071898L + 00700000000L
    END;
    IF p^ = 10071898L + 02600000000L THEN (* MM2TINYS.M2P bis V2.2f *)
      copy ($1060, 2*80+2);
      p^:= 10071898L + 02700000000L
    END;
    
    (* ... hier sind neue Formate zu behandeln. *)
    
    (* Und nun neue Datei wieder schreiben *)
    IF len = origlen THEN
      FormAlert (1, ConcStr (ConcStr ('[0][Parameter-Datei|', name), '|ist bereits up-to-date. ][OK]'), but);
    ELSE
      Files.Create (f, name, Files.writeOnly, Files.replaceOld);
      Binary.WriteBytes (f, ADR (buf), len);
      Files.Close (f);
      IF Files.State (f) < 0 THEN
        FormAlert (1, ConcStr (ConcStr ('[0][Fehler beim Erzeugen von|', name), '][OK]'), but);
      ELSE
        FormAlert (1, ConcStr (ConcStr ('[0][Parameter-Datei|', name), '|wurde konvertiert. ][OK]'), but);
      END;
    END;
    RETURN TRUE
  END process;

VAR res: INTEGER;

BEGIN
  ShowArrow;
  FormAlert (1, '[0][ |*.M2P-Konvertierer |fÅr Megamax Modula-2 | ][ OK ]', but);
  SelectMask:= '*.M2P';
  LOOP
    name:= '';
    SelectFile ('WÑhle Verzeichnis', name, ok);
    IF ~ok THEN EXIT END;
    DirQuery (PathConc (name, '*.M2P'), QueryFiles, process, res);
    IF res = fNoMatchingFiles THEN
      FormAlert (1, '[0][Dies Verzeichnis enthÑlt|keine M2P-Dateien.][OK]', but);
    END;
  END
END Conv_M2P.
