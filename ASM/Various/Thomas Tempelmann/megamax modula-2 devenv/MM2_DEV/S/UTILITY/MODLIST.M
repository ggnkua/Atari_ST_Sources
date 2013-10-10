MODULE ModList;

(*
 * Gibt eine Liste aller z.Zt. in der Shell importierten Module aus.
 * Ist „hnlich der Funktion <Alternate>-R in der Shell.
 *)

IMPORT GEMDOSIO; (*$E MOS *)

FROM SYSTEM IMPORT ADDRESS;

FROM InOut IMPORT
  WriteLn, Write, WriteString, WriteLHex;

FROM Strings IMPORT Length;

FROM ModCtrl IMPORT ModQuery;

PROCEDURE listIt ( REF modName:  ARRAY OF CHAR;
                       modAddr:  ADDRESS;
                       modLen:   LONGCARD;
                       varAddr:  ADDRESS;
                       varLen:   LONGCARD;
                   REF fileName: ARRAY OF CHAR;
                       module:   BOOLEAN;
                       loaded:   BOOLEAN;
                       resident: BOOLEAN );

  VAR i: CARDINAL;  c: CHAR;

  BEGIN
    WriteString ( modName );
    FOR i:= 1 TO 20 - Length (modName) DO Write (' ') END;
    WriteString ('Code: ');
    WriteLHex ( modAddr, 7 );
    IF ~module THEN
      WriteString (' / program')
    ELSE
      WriteString ('  Var: ');
      WriteLHex ( varAddr, 7 );
      WriteString ('  VLen: ');
      WriteLHex ( varLen, 7 );
      IF loaded THEN WriteString (' / loaded') END;
      IF resident THEN WriteString (' / resident') END
    END;
    WriteLn;
  END listIt;

VAR ch:CHAR;

BEGIN
  WriteLn;
  ModQuery ( listIt );
END ModList.
