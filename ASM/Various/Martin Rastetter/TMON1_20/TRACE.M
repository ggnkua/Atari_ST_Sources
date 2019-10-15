MODULE Trace;

(*******************************************************************
 * Dieses Programm dient als Debug-Hilfe zum Debugger TEMPLEMON.
 * Es wurde mit dem MEGAMAX Modula-2 Entwicklungssystem erstellt
 * (welches ich sehr empfehlen kann - das ist nÑmlich auch von mir!).
 * Das Programm (ohne den besonders markierten Programmabschnitte
 * fÅr das Beispielprogramm TRACE.MOS) kann als Rumpf fÅr alle
 * weiteren User-Trace Routinen dienen.
 ******************************************************************)

(*$ E MOS   Suffix: Kennzeichnung als TOS-Applikation *)

(* Importe *)

FROM ModCtrl IMPORT InstallModule, ReleaseModule, FirstModuleStart;

FROM MOSGlobals IMPORT MemArea;

FROM Terminal IMPORT WriteLn, WriteString, Read;

FROM Calls IMPORT CallSupervisor;

FROM SYSTEM IMPORT ADDRESS;


VAR  TraceVector [$3F0]: ADDRESS;

(* spezifische Konstante fuer Zugriffe auf die Prozessorregister *)

CONST   RegD0 = 04;
        RegD1 = 08;
        RegD2 = 12;
        RegD3 = 16;
        RegD4 = 20;
        RegD5 = 24;
        RegD6 = 28;
        RegD7 = 32;
        RegA0 = 36;
        RegA1 = 40;
        RegA2 = 44;
        RegA3 = 48;
        RegA4 = 52;
        RegA5 = 56;
        RegA6 = 60;
        RegA7 = 64;
        RegSR = 02;
        RegPC = 68;
        RegUSP = 80;
        RegSSP = 84;


(******************** User - Trace Routine ***************************)

PROCEDURE usrTrc;
  (*$L-*)
  BEGIN
    ASSEMBLER
        ;Hier ist der Einsprungspunkt fuer die User-Trace Routine.
        ;Hier koennen Abfragen in Assembler programmiert werden.
        ;Die augenblicklichen Register A0 und D7 duerfen nicht
        ;veraendert werden; in D0.W wird Nicht-Null oder Null zu-
        ;rueckgegeben, je nachdem, ob das Tracing abgebrochen wer-
        ;densoll oder ob weitergetraced werden soll.
        ;Auf die im Debugger zwischengespeicherten Register der
        ;CPU fuer die naechste auszufuehrende Instruktion kann
        ;mit den obigen Definitionen (Reg..) zugegriffen werden.
        ;Die Register (Reg..) koennen auch veraendert werden.
        ;Dieses Programm wird immer im Supervisormodus aufgerufen.
        ;
        ;Z.B. kann eine Ueberpruefung, ob als naechste Instruktion
        ;ein Line-A Aufruf stattfindet, folgendermassen program-
        ;miert werden :
        ;
        ; CLR.W   D0
        ; MOVE.L  RegPC(A0),A1  ;PC laden
        ; MOVE.W  (A1),D1       ;Instruktion laden
        ; ANDI.W  #0xF000,D1    ;oberstes Nibble der Instr. maskieren
        ; CMPI.W  #0xA000,D1    ;Line-A Instruktion ?
        ; SEQ     D0            ;je nachdem D0.B auf 0 oder -1 setzen
        ;
        
        ;**** Beispiel-Text f. TRACE.MOS ******
        
        CLR.W   D0
        MOVE.L  $44E,A1      ;Adr. des Bildschirmbereichs
        TST.W   640(A1)      ;Sind die Bits der ersten 8 Spalten
                             ;in der zweiten Zeile geloescht ?
        SNE     D0           ;Wenn nicht, dann Stop
    END
  END usrTrc;
  (*$L=*)


PROCEDURE installTrace (dummy: ADDRESS);
  BEGIN
    TraceVector:= ADDRESS (usrTrc)
  END installTrace;

PROCEDURE deinstallTrace (dummy: ADDRESS);
  BEGIN
    TraceVector:= NIL
  END deinstallTrace;

PROCEDURE restore;
  VAR wsp: MemArea;
  BEGIN
    wsp.bottom:= NIL;
    CallSupervisor (deinstallTrace, NIL, wsp); (* Routine deinstallieren *)
  END restore;


PROCEDURE wait;
  VAR c: CHAR;
  BEGIN
    WriteLn;
    WriteString ('Bitte eine Taste...');
    WriteLn;
    Read (c)
  END wait;

VAR wsp: MemArea;

BEGIN (* main *)
  wsp.bottom:= NIL;
  IF FirstModuleStart () THEN
    (* Programm beenden, aber Speicher dieses Programms nicht freigeben *)
    InstallModule (restore, wsp);
    CallSupervisor (installTrace, NIL, wsp); (* Trace-Routine installieren *)
    WriteLn;
    WriteString ('TEMPLEMON User-Trace ist installiert.');
    WriteLn;
    WriteString ('DrÅcke gleich ALT/HELP, um den Monitor aufzurufen, sofern');
    WriteLn;
    WriteString ('er bereits einmal gestartet wurde. Gebe dann "T+", danach');
    WriteLn;
    WriteString ('"G" ein. DrÅcke dann "A". Nun ist die Trace-Routine aktiv');
    WriteLn;
    WriteString ('und der Monitor meldet sich zurÅck, sobald die Maus die');
    WriteLn;
    WriteString ('linke obere Ecke des Bildschirms erreicht.');
    WriteLn;
    wait
  ELSE
    (* Speicher dieses Programms freigeben *)
    CallSupervisor (deinstallTrace, NIL, wsp); (* Routine deinstallieren *)
    ReleaseModule;
    WriteLn;
    WriteString ('TEMPLEMON User-Trace ist nun entfernt.');
    WriteLn;
    wait
  END
END Trace.
