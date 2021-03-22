MODULE KbdTest;

(*
 *                                                   Thomas Tempelmann, 4.7.89
 *
 * Dieses Modul dient zur Demonstration der Module 'KbdCtrl' und 'Keyboard'
 * sowie der Anwendung von XBRA.
 *
 * Wird es gestartet, installiert es eine Prozedur als Auswertungsroutine
 * fÅr gedrÅckte Tasten. Die Prozedur ruft immer, wenn eine Taste ausgewertet
 * werden muû, die bisherige Auswertungsfunktion auf und sieht dann nach,
 * welche Taste gedrÅckt wurde (bzw. im Tastaturpuffer steht). Ist es
 * Shift-F1, werden stattdessen andere Tasten in den Puffer geschrieben.
 *
 * Mit diesem Verfahren ist es also auf einfache Weise mîglich, eingegebene
 * Tasten zu Åberwachen und sie ggf. durch andere zu ersetzen oder bestimmte
 * Funktionen daraufhin auszulîsen.
 *
 * Eine weitere Anwendung, wie TastendrÅcke direkt Åberwacht werden kînnen,
 * findet sich im Modul 'UserBreak', dessen Quelltext sich im Ordner "MOS"
 * befindet.
 *
 * Wird das Modul unter der Shell gestartet, kann es beim Beenden der Shell
 * oder durch wiederholten Start wieder freigegeben werden.
 *
 * Achtung:
 *   Das Modul darf nicht vollstÑndig optimiert werden, wenn es gelinkt
 *   werden soll. Vielmehr ist die mittlere Optimierung zu wÑhlen, damit
 *   die Link-Informationen zum Residentmachen des Programms erhalten
 *   bleiben.
 *)

FROM MOSCtrl IMPORT
  ModLevel;
FROM PrgCtrl IMPORT
  GetBasePageAddr;
FROM SYSTEM IMPORT
  ASSEMBLER, ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD;
FROM ModCtrl IMPORT
  FirstModuleStart, ReleaseModule, InstallModule;
FROM MOSGlobals IMPORT
  MemArea, Key, CtrlKey, CtrlSet;
FROM Strings IMPORT
  Length;
FROM XBIOS IMPORT
  KeyboardVectors;
FROM Calls IMPORT
  DisposeCaller, SysNewCaller, CallExtRegs, Registers;
FROM KbdCtrl IMPORT
  LookKey, GetKey, PutKey, UnlockKeyBuffer, LockKeyBuffer, PushBackKey;
FROM Keyboard IMPORT
  KeyCap, undoCap, SpecialKey, f11;
IMPORT
  XBRA;

CONST
  f11macro = 'Hallo !';  (* Dieser Text wird fÅr Shift-F1 (F11) ersetzt *)

  Kennung = 'KBDT';  (* XBRA-Kennung (s.u.) *)


VAR
  kbdstack: ARRAY [1..800] OF CARDINAL;
  kbdentry: ADDRESS;
  kbdwsp: MemArea;
  kbdV: POINTER TO ADDRESS;
  termwsp: MemArea;
  ok: BOOLEAN;
  txt: ARRAY [0..39] OF CHAR;
  entry, at: ADDRESS;
  carrier: XBRA.Carrier;


PROCEDURE FormAlert (but: CARDINAL; msg: ADDRESS);
(*
 * Ersatz fÅr FormAlert aus GEM-Modul, um die Importe zum mindern.
 *)
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0        ; msg
        LEA     Data(PC),A1
        LEA     24(A1),A2
        MOVE.L  A0,(A2)
        MOVE.L  A2,16(A1)
        ADDQ    #4,A2
        MOVE.L  A2,8(A1)
        MOVE    -(A3),(A2)+     ; Default Button-Nr.
        MOVE.L  A2,12(A1)
        MOVE.L  A2,-(A7)
        ADDQ    #2,A2
        MOVE.L  A2,4(A1)
        LEA     Control(PC),A0
        MOVE.L  A0,(A1)
        CLR.L   10(A2)
        MOVE.L  A1,D1
        MOVE    #$C8,D0
        TRAP    #2
        MOVE.L  (A7)+,A0
        MOVE    (A0),D0     ; hier ist der gedrÅckte 'button' drin
        RTS

Control DC.W    52,1,1,1,0,0
Data    DS      52
    END
  END FormAlert;
  (*$L=*)


PROCEDURE term;
(*
 * wird bei Deinstallation ausgefÅhrt
 *)
  VAR at: ADDRESS;
  BEGIN
    IF XBRA.Installed (Kennung, kbdV, at) THEN
      XBRA.Remove (at);
      DisposeCaller (kbdentry);
    END;
    ReleaseModule;
    txt:= '[0][KbdTest deaktiviert][ OK ]';
    FormAlert ( 1, ADR (txt) );
  END term;

PROCEDURE kbdWriteString (s: ARRAY OF CHAR);
(*
 * schreibt einen String in den Tastaturpuffer
 *)
  VAR i: INTEGER; k: Key;
  BEGIN
    k.scan:= 0;
    k.ctrl:= CtrlSet {};
    (* LockKeyBuffer-Aufruf hier unnîtig, da wir schon im IR sind. *)
    FOR i:= 0 TO INTEGER (Length (s))-1 DO
      k.ch:= s [i];
      PutKey (k, ok)
    END
  END kbdWriteString;

PROCEDURE hdlKbd (VAR r: Registers);
(*
 * wird direkt nach jedem Tastendruck aufgerufen.
 * Achtung: Bei "Auto-Repeat" einer Taste wird dies hier nicht erkannt.
 * Dazu mÅûte zusÑtzlich noch im 200 HZ-Interrupt eine Ñhnliche Routine
 * installiert werden oder generell der Tastatur-Repeat abgeschaltet werden!
 *)
  VAR k: Key;
  BEGIN
    CallExtRegs (XBRA.PreviousEntry (entry), r);
                                          (* Kbd-Routine des TOS aufrufen *)
    LookKey (k, ok);                      (* welche Taste wurde gedrÅckt? *)
    IF ok THEN                            (* ist Taste gekommen? *)
      IF SpecialKey (k) = f11 THEN        (* ist es Shift-F1? *)
        GetKey (k, ok);                   (* - dann Taste abholen *)
        kbdWriteString (f11macro)         (* und durch andere Tasten ersetzen*)
      END
    END;
  END hdlKbd;

BEGIN
  kbdV:= ADDRESS (KeyboardVectors ()) + $20L; (* Vektor f. Kbd-Auswertung *)
  IF XBRA.Installed (Kennung, kbdV, at) THEN
    (* Wenn Routine schon installiert ist, diese entfernen *)
    term
  ELSE
    (* Ansonsten Installation vornehmen *)
    kbdwsp.bottom:= ADR (kbdstack);             (* Stackbereich bestimmen *)
    kbdwsp.length:= SIZE (kbdstack);
    SysNewCaller ( hdlKbd, FALSE, kbdwsp, kbdentry ); (* Entry-Code erzeugen *)
    IF kbdentry # NIL THEN
      XBRA.Create ( carrier, Kennung, kbdentry, entry );
      XBRA.Install ( entry, at );
      termwsp.bottom:= NIL;
      InstallModule (term, termwsp);            (* Modul resident machen *)
      txt:= '[0][KbdTest aktiviert][ OK ]';
      FormAlert ( 1, ADR (txt) )
    END;
  END
END KbdTest.
