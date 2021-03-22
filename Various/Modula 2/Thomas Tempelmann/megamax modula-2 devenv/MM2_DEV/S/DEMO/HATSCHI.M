MODULE HaTschi;

(*
 * Dies ist eine erweiterte Version des bekannten Coroutine-Demoprogramms
 * aus dem Standardwerk "Programmierung in Modula-2" von Dal Cin/Lutz/Risse.
 *
 * Das Hauptmodul erzeugt zwei Coroutinen, die sich dann abwechseld aktivieren.
 * ZusÑtzlich wird gezeigt, wie IOTRANSFER angewendet werden kann:
 * 1. wird dazu unten eine TRAP-Instruktion statt einer TRANSFER-Anweisung
 *    ausgefÅhrt,
 * 2. wird im lokalen Modul "IR" eine Coroutine als Interruptroutine
 *    installiert.
 *)

FROM SYSTEM IMPORT ASSEMBLER;
FROM SYSTEM IMPORT ADDRESS, LISTEN, TRANSFER, IOTRANSFER, NEWPROCESS, ADR;

FROM Storage IMPORT ALLOCATE, DEALLOCATE;

FROM InOut IMPORT KeyPressed, WriteString, WriteLn;

FROM RandomGen IMPORT RandomCard;

IMPORT MOSGlobals, PrgCtrl; (* nur f. lokales Modul *)


(*$J-  (fÅr langsame FOR-Schleifen) *)


MODULE IR [5];

  (*
   * Lokales Modul, das sich in VBL-Vektor installiert.
   * Dadurch wird die Routine 'serveProc' regelmÑûig vom GEMDOS
   * aufgerufen und setzt nach jeweils einer bestimmten Anzahl
   * von Aufrufen eine Variable ('Key') auf TRUE.
   *)

  IMPORT TRANSFER, IOTRANSFER, NEWPROCESS, ADDRESS, ADR, LISTEN;

  FROM PrgCtrl IMPORT CatchProcessTerm, TermCarrier;

  FROM MOSGlobals IMPORT MemArea;

  EXPORT Key;

  VAR main, server: ADDRESS;
      stack: ARRAY [1..800] OF CARDINAL;
      terminate, Key: BOOLEAN;

  PROCEDURE serveProc;
    VAR i: CARDINAL;
    BEGIN
      i:= 0;
      LOOP
        IOTRANSFER (server, main, $4DEL);  (* VBL-Queue *)
        IF terminate THEN
          TRANSFER (server, main);
        END;
        INC (i);
        IF i > 50 THEN
          Key:= TRUE;
          i:= 0
        END
      END
    END serveProc;
  
  PROCEDURE terminateIR;
    BEGIN
      terminate:= TRUE;
      TRANSFER (main, server)
    END terminateIR;

  VAR carrier: TermCarrier;
      wsp: MemArea;

  BEGIN
    Key:= FALSE;
    terminate:= FALSE;

    (*
     * Prozeû einrichten und starten
     *)
    NEWPROCESS (serveProc, ADR (stack), SIZE (stack), server);
    TRANSFER (main, server);

    (*
     * Die Prozedur 'terminateIR' soll dafÅr sorgen, daû bei
     * Programmende der IOTRANSFER-Zyklus beendet wird.
     *)
    wsp.bottom:= NIL;
    CatchProcessTerm (carrier, terminateIR, wsp);
  END IR;


CONST StackSize = 2000L;

VAR a1, a2: ADDRESS;
    Main, Ha, Tschi: ADDRESS;
    Count: CARDINAL;
    
PROCEDURE schreibeHa;
  VAR l:LONGCARD;
  BEGIN
    LOOP
      IF RandomCard (1,5) # 5 THEN
        WriteString (" Ha ");
        FOR l:= 1L TO 3000L DO END
      ELSE
        IF Key THEN
          Key:= FALSE;
          WriteString (" <Key> ")
        END;
        TRANSFER (Ha, Tschi); (* direkter Transfer auf 'Tschi' *)
        ASSEMBLER
          TRAP #0             (* indirekter Transfer Åber TRAP #0 -> 'Tschi' *)
        END;
        WriteLn;
      END;
      IF Count >= 50 THEN
        TRANSFER (Ha, Main);  (* Ende *)
      END
    END
  END schreibeHa;

PROCEDURE schreibeTschi;
  (*
   * Durch das folgende Verlassen dieser Coroutine Åber 'IOTRANSFER'
   * statt 'TRANSFER' kann sie sowohl durch einen TRANSFER auf sie
   * zurÅck als auch Åber IO-Kanal (in diesem Fall 'TRAP #0') wieder
   * aktiviert werden.
   *)
  BEGIN
    LOOP
      WriteString (" Tschi ");
      INC (Count);
      IOTRANSFER (Tschi, Ha, $80L);  (* Installation auf TRAP #0 *)
    END;
  END schreibeTschi;

BEGIN
  ALLOCATE (a1, StackSize);
  ALLOCATE (a2, StackSize);
  NEWPROCESS (schreibeHa, a1, StackSize, Ha);
  NEWPROCESS (schreibeTschi, a2, StackSize, Tschi);
  Count:= 0;
  (*
   * Nun niesen wir ein paarmal...
   *)
  TRANSFER (Main, Ha);
  (*
   * Danach warten wir auf einen Tastendruck, wÑhrenddessen weiterhin
   * im VBL-Interrupt 'Key' zyklisch gesetzt wird.
   *)
  WHILE NOT KeyPressed () DO
    IF Key THEN
      Key:= FALSE;
      WriteString (" <Key> ")
    END
  END;
  DEALLOCATE (a1, StackSize);
  DEALLOCATE (a2, StackSize);
END HaTschi.
