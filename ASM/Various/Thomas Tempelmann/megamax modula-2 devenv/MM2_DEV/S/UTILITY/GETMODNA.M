MODULE GetModName;

(*
 * Zeigt an, welche Prozedur welches Moduls an einer bestimmten
 * Adresse liegt.
 *)

FROM SYSTEM IMPORT ADDRESS;
FROM ModCtrl IMPORT GetModName;
FROM InOut IMPORT Done, ReadLCard, WriteLn, WriteString;

VAR addr: ADDRESS;
    modname, procname: ARRAY [0..39] OF CHAR;
    relpos: LONGCARD;

BEGIN
  LOOP
    WriteLn;
    WriteString ('Address? ');
    ReadLCard (addr);
    IF ~ Done THEN EXIT END;
    GetModName (addr, modname, relpos, procname);
    IF modname[0] = '' THEN
      WriteString ('  No module at this address');
    ELSE
      WriteString ('  Mod:  ');
      WriteString (modname);
      WriteLn;
      WriteString ('  Proc: ');
      WriteString (procname);
    END;
    WriteLn
  END
END GetModName.
