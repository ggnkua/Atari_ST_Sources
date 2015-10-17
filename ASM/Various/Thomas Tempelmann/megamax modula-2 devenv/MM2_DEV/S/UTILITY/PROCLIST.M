MODULE ProcList;

(*
 * Zeigt alle Prozedurnamen eines residenten Moduls (ggf. erst laden!)
 * an, sofern die Namen nicht durch optimiertes Linken oder die Direktive
 * $M- entfernt wurden.
 *
 * Beim Start des Programms kann ein Modulname eingegeben werden,
 * daraufhin werden alle Prozedurnamen daraus angezeigt.
 * Ende des Programms durch eine Leereingabe.
 *)

IMPORT GEMDOSIO; (*$E MOS *)

FROM InOut IMPORT
  Done, ReadString, WriteLn, Write, WriteString, WriteLHex;

FROM SYSTEM IMPORT ADDRESS;

FROM ModCtrl IMPORT GetProcAddr, ProcQuery;


PROCEDURE listIt ( REF procName: ARRAY OF CHAR; procAddr: ADDRESS );
  BEGIN
    WriteString ('  ');
    WriteLHex (procAddr, 7);
    WriteString ('  ');
    WriteString (procName);
    WriteLn;
  END listIt;

VAR modName: ARRAY [0..19] OF CHAR;
    ok: BOOLEAN;
    addr: ADDRESS;

BEGIN
  LOOP
    WriteLn;
    WriteString ('Which module? ');
    ReadString (modName);
    IF NOT Done OR (modName[0] = '') THEN EXIT END;
    ProcQuery (modName, listIt, ok);
    IF NOT ok THEN
      GetProcAddr (modName, addr);
      IF addr = NIL THEN
        (* Modul gibt's gar nicht *)
        WriteString ('This module is not resident!')
      ELSE
        (* Modul wurde mit $M- Åbersetzt oder optimiert gelinkt *)
        WriteString ('This module contains no symbols!')
      END;
      WriteLn
    END;
  END
END ProcList.
