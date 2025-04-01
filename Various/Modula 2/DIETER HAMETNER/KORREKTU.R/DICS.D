DEFINITION MODULE Dics;

FROM Strings    IMPORT  String;
FROM MOSGlobals IMPORT  FileStr;

TYPE    Dic;                     (* opaker Typ !!! *)
        ErrorState = (ok, outOfMem, fileErr);
        queryProc = PROCEDURE (Dic, VAR ARRAY OF CHAR): BOOLEAN;
        
PROCEDURE CreateDic (VAR d: Dic; over, step: LONGCARD);
        
(*  Liefert in 'd' eine Kennung fr das Dictionary.
 *  'over' gibt an wieviel Speicherplatz beim Anlegen alloziert
 *  werden soll,  'step' um wieviel der Speicherplatz bei šberlauf
 *  vergr”žert werden sollte (vorgesehen aber noch nicht implementiert.)
 *  Als Wert fr over gilt etwa - pro 10.000 Worte 50 KB.
 *)

PROCEDURE LoadDic (fName: FileStr; VAR d: Dic; over, step: LONGCARD);

(*  Lesen eines Dictionarys, Parameter - siehe Create. *)
         
PROCEDURE SaveDic (fName: FileStr; d: Dic);

(*  Schreiben eines Dictionarys. *)

PROCEDURE ReleaseDic (VAR d: Dic);
        
(*  Gibt den von 'd' belegten Speicher frei. *)

PROCEDURE InsertDic (d: Dic; REF x: ARRAY OF CHAR; VAR scs: BOOLEAN);
        
(*  Wenn noch Platz war wird 'x' eingetragen. *)

PROCEDURE DeleteDic (d: Dic; REF x: ARRAY OF CHAR);
        
(*  L”scht den Eintrag 'x'. *)

PROCEDURE FindDic (d: Dic; REF x: ARRAY OF CHAR): BOOLEAN;

(*  Sucht nach 'x' - TRUE falls gefunden, FALSE sonst.
 *  SpellMode muž vorher eingeschaltet sein.*)

PROCEDURE QueryDic (d: Dic; x: ARRAY OF CHAR; elemProc: queryProc);

(*  Liefert 'elemProc' die Zeichenketten aus 'd' ab Stelle 'x[0]'.
 *  Abgebrochen wird falls 'elemProc' FALSE liefert oder das Ende
 *  erreicht wurde. Falls 'x' ein Leerstring ist wird das
 *  gesamte Dic durchlaufen.
 *)

PROCEDURE SetSpellMode (d: Dic; every: CARDINAL);
        
(*  every > 0 schaltet den SpellMode ein. (=0 aus). *)

PROCEDURE CountWords (d: Dic): LONGCARD;
END Dics.