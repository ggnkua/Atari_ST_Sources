MODULE MemTest;
(*$E MOS *)
IMPORT TOSIO;

  (* Fehler im Modula-System: Irgendwas ist im Storage-Modul schiefgelaufen.
   * Soweit ich den Fehler ausmachen kann, liefern die Abfrageprozeduren
   * fr den freien Speicherplatz nach einer bestimmten Anzahl von Aufrufen
   * mit anschliežender Speicherallokation falsche Werte.
   *
   * Die hier aufgefhrte Prozedur testIt macht das deutlich. In einer
   * WHILE-Schleife wird auf 8kByte freien Speicherplatz abgefragt und dann
   * ein wesentlich kleinerer Speicherbereich alloziiert, d.h. die Allokation
   * mžte eigentlich immer erfolgreich ablaufen (was aber bei dem neuesten
   * Modula-Update nicht der Fall ist; bei der „lteren Version funktionierte
   * es ganz wunderbar !)
   *)

FROM InOut      IMPORT WriteString, WriteLn, WriteCard, Read;
FROM GEMEnv     IMPORT InitGem, ExitGem, GemError, CurrGemHandle, RC,
                       DeviceHandle, GemHandle;
FROM Storage    IMPORT ALLOCATE, MemAvail, Available;

VAR  success    : BOOLEAN;
     dev        : DeviceHandle;
     gemHdl     : GemHandle;
     c          : CHAR;

PROCEDURE testIt;
CONST amount = 128000;
VAR block : POINTER TO CHAR;
    ok    : BOOLEAN;
    count : CARDINAL;
  BEGIN
    WriteString('Speicher wird alloziert...'); WriteLn;
    ok:=TRUE; count:=0;

    (*
    ok:= FALSE;
    *)
    WHILE ok & Available (amount) DO
    (*(MemAvail()>LONG(8192)) DO*)
      ALLOCATE(block,amount);

      ok:=block#NIL;    (* Drfte eigentlich nie FALSE werden, da ja vorher
                         * auf viel mehr Speicher abgeprft wird !
      ******************** Der Fehler tritt brigens auch dann auf, wenn
      * statt auf MemAvail()>LONG(8192) zum Beispiel auf Available(amount)
      * abgefragt wird.
      *)
      
      IF ok THEN INC(count) END
    END;

    IF ~ok THEN
      WriteString('Fehler eingetreten nach ');
      WriteCard(count,0);
      WriteString(' Allokationen. MemAvail() = ');
      WriteCard(MemAvail(),0);
    ELSE WriteString('Kein Fehler.') END;
    WriteLn
  END testIt;

BEGIN
  InitGem(RC, dev, success);
  IF success THEN
    gemHdl:=CurrGemHandle();

    testIt;
    Read(c);

    ExitGem(gemHdl)
  END
END MemTest.
