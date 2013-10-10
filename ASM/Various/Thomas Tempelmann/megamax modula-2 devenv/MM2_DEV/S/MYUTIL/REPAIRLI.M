MODULE RepairLIB;
(*
 * Dieses Modul korrigiert die Lib-Datei MM2LIB.M2L (vom 20.11.91),
 * die beim aktuellen System 2.3 mitgeliefert wird.
 * Die Lib-Datei enthÑlt zu Beginn einen leeren Dateieintrag, welcher
 * es unmîglich macht, die einzelnen Dateien auf der Library mit dem
 * LibManager-Programm herauszukopieren.
 *
 * Dieses Programm muû Åbersetzt und dann von der Shell aus gestartet
 * werden. Es sucht dann selbsttÑtig die Lib-Datei und Ñndert den
 * fehlerhaften Namen in "DUMMY" um. Ist die Lib-Datei nicht defekt,
 * weil sie schon korrigiert wurde, passiert auch nichts.
 * Achtung: Die Datei "DUMMY" darf nicht mit dem LibManager gelîscht
 * werden, denn das wÅrde die Lib-Datei zerstîren. Stattdessen sollten
 * besser alle Dateien aus der Lib-Datei mittels des LibManagers
 * herauskopiert werden, die Lib-Datei gelîscht, und dann die Dateien
 * wieder in eine neu erzeugte Lib-Datei "MM2DEF.M2L" kopiert werden.
 *)

IMPORT MOSGlobals, Files, Binary;
FROM InOut IMPORT WriteLn, WriteString, Read;
FROM Paths IMPORT SearchFile, ListPos;
FROM Directory IMPORT FileAttrSet;
FROM Strings IMPORT String;
FROM ShellMsg IMPORT DefPaths, DefLibName;

TYPE
  LibHead = RECORD
    str: ARRAY [0..7] OF CHAR;
    layout: CARDINAL;
    fileSize: LONGCARD;
    start: LONGCARD;
    entries: CARDINAL;
  END;

  LibEntry = RECORD
     name: ARRAY [0..11] OF CHAR;
     attr: FileAttrSet;
     time: CARDINAL;
     date: CARDINAL;
     size: LONGCARD;
     start: LONGCARD
   END;

VAR     f: Files.File;
        found: BOOLEAN;
        name: MOSGlobals.FileStr;
        ch: CHAR;
        lh: LibHead;
        le: LibEntry;

BEGIN
  name:= DefLibName;
  SearchFile (name, DefPaths, fromStart, found, name);
  IF ~found THEN
    WriteString ("Die Datei ");
    WriteString (name);
    WriteString (" ist nicht auf den Def-Pfaden zu finden.");
  ELSE
    Files.Open (f, name, Files.readWrite);
    Binary.ReadBlock (f, lh);
    IF lh.start # $1E4AE THEN
      WriteString ("Die Datei ");
      WriteString (name);
      WriteString (" ist nicht defekt.");
    ELSE
      Binary.Seek (f, lh.start, Binary.fromBegin);
      Binary.ReadBlock (f, le);
      IF le.name[0] # 0C THEN
        WriteString ("Die Datei ");
        WriteString (name);
        WriteString (" scheint bereits repariert zu sein.");
      ELSE
        WITH le DO
          name:= "DUMMY"; attr:= FileAttrSet{};
          time:= 0; date:= 0; size:= 0; start:= 0;
        END;
        Binary.Seek (f, lh.start, Binary.fromBegin);
        Binary.WriteBlock (f, le);
        WriteString ("Die Datei ");
        WriteString (name);
        WriteString (" ist repariert.");
      END
    END;
    Files.Close (f)
  END;
  WriteLn;
  WriteString ("Taste...");
  Read (ch);
END RepairLIB.
