IMPLEMENTATION MODULE UserBreak;
(*$M-,S-,Y+,R-*)

(*
 * Zweck des Moduls: Siehe Definitionstext.
 *
 * Das Modul hÑngt sich auf zwei Arten ins Laufzeitsystem ein:
 * 1. FÅr die Control-C-Erkennung werden Watchdogs (s. EventHandler)
 *    installiert. Eine globale BOOLEAN-Var 'break' wird von ihnen
 *    geprÅft (sie wird u.a. vom Keyboard-Watchdog gesetzt). Ist sie
 *    TRUE, wird 'doBreak' aufgerufen. Dort wird eine GEM-Dialogbox
 *    angezeigt und ggf. das Programm beendet.
 * 2. FÅr Control-Enter wird direkt der Tastatur-Interrupt angezapft.
 *    Wird darin Control-Enter erkannt, wird sofort das Programm beendet.
 *    Dort wird zudem auch Control-C erkannt, jedoch dann nur 'Break' auf
 *    TRUE gesetzt.
 *
 * 02.04.88 TT: Programmabbruch nur im Hauptprozeû (nicht in Envelopes) mîglich.
 * 09.06.88 TT: Es wird immer die zuletzt statt die zuerst eingegebene Taste
 *              ÅberprÅft.
 * 04.11.90 TT: HÑngt nicht mehr im VBL sondern direkt in Kbd-Vektor;
 *              Benutzt nicht mehr Coroutinen (wg. Super-Aufruf/TRAP-Benutzung)
 * 09.12.90 TT: 'Break' wird exportiert
 * 11.12.90 TT: Nach Ctrl-C wird trotzdem noch auf Ctrl-Enter reagiert.
 * 17.12.90 TT: Ctrl-C wird nicht aus Kbd-Puffer entfernt, damit ggf. GEMDOS
 *              auch noch reagieren kann.
 *)

FROM SYSTEM IMPORT ASSEMBLER, ADDRESS, CALLSYS, ADR, CAST, WORD, BYTE;
FROM XBIOS IMPORT KeyboardVectors;
FROM KbdCtrl IMPORT LookMostRecentKey, GetKey, ClrKeyBuffer;
FROM SysTypes IMPORT ScanDesc;
FROM SysCtrl IMPORT GetScanAddr, ScanBack;
FROM GEMScan IMPORT InputScan, InitChain, CallingChain;
FROM Calls IMPORT NewCaller, Registers, CallExtRegs, CallProc;
FROM MOSGlobals IMPORT Key, MemArea, UserBreak, MEM;
FROM PrgCtrl IMPORT CatchProcessTerm, ProcessState, PState, TermCarrier,
        TermProcess;
FROM GrafBase IMPORT Point;
FROM AESForms IMPORT FormAlert;
FROM GEMGlobals IMPORT GemChar, MButtonSet, SpecialKeySet;
FROM AESEvents IMPORT Event, MessageBuffer, unspecMessage;
FROM EventHandler IMPORT EventProc, WatchDogCarrier, MessageProc,
        DeInstallWatchDog, InstallWatchDog;
IMPORT SysBuffers, XBRA;


CONST  SoftBreak     = 3C;          (* Code fÅr Ctrl-C *)
       HardBreakScan = $72;
       HardBreakChar = CHAR ($0A);  (* Code fÅr Ctrl-Enter *)

       Kennung = 'MM2U';  (* XBRA-Kennung *)


VAR terminating, enabled: BOOLEAN;
    entry: ADDRESS;

(*
 * Folgende Routine hÑngt im Interrupt-Vektor fÅr TastendrÅcke
 *)
PROCEDURE hdlKbd (VAR r: Registers);
  TYPE ByteSet = SET OF [0..7];
  VAR k: Key; ok: BOOLEAN; ISRB [$FFFFFA11]: ByteSet;
  BEGIN
    CallExtRegs (XBRA.PreviousEntry (entry), r);
    IF NOT terminating THEN
      LookMostRecentKey (k, ok); (* gerade eben gedrÅckte Taste holen *)
      WITH k DO
        IF ch = SoftBreak THEN (* Control-C? *)
          Break:= TRUE;
        ELSIF (ch = HardBreakChar) & (scan = HardBreakScan) THEN
          terminating:= TRUE;
          ClrKeyBuffer;
          IF ProcessState () = running THEN
            (* sofortiger Programmabbruch bei Control-Enter *)
            EXCL (ISRB, 6);
            TermProcess (UserBreak)
          END
        END
      END
    END;
  END hdlKbd;

(*
 * Scan-Box anzeigen, ggf. Programm beeenden
 *)
PROCEDURE doBreak (dummy:ADDRESS);
  VAR button, index: CARDINAL; scan: ScanDesc; b: BOOLEAN;
  BEGIN
    ClrKeyBuffer;
    GetScanAddr (scan);
    FOR index:= 1 TO 5 DO b:= ScanBack (scan) END;
    InitChain (scan);
    index:= 1;
    InputScan ('Unterbrechung vom Anwender', index);
    FormAlert (1, '[2][Programm beenden ?][ Ja |Nein]', button);
    Break:= FALSE;
    IF button = 1 THEN
      TermProcess (UserBreak)
    END;
  END doBreak;

(*
 * Es folgen die Watchdog-Prozeduren
 *)

PROCEDURE handleBreak;
  BEGIN
    IF Break & (ProcessState () = running) THEN
      (* 'doBreak' bekommt einen eigenen Stack, da nie sicher ist, daû
       * der augenblickliche Stack noch ausreicht. Dabei wird der Stack
       * verwendet, der fÅr die Laufzeitfehlerbehandlung reserviert ist.
       * Da hier keine Laufzeitfehler auftreten dÅrften und diese Routine
       * auch nicht wÑhrend einer Laufzeitfehlerbehandlung aktiv werden
       * kann, dÅrfte es dabei keine Kollisionen (gleichzeite Benutzung
       * des Stack-Speichers durch mehrere Routinen) geben.               *)
      CallProc (doBreak, NIL, MEM (SysBuffers.HdlErrorStack))
    END
  END handleBreak;

PROCEDURE handleTimer (): BOOLEAN;
  BEGIN
    handleBreak;
    RETURN TRUE
  END handleTimer;

PROCEDURE handleKey ( VAR c: GemChar; VAR s: SpecialKeySet ): BOOLEAN;
  BEGIN
    IF (c.ascii = SoftBreak)
    OR (c.ascii = HardBreakChar) & (c.scan = CAST (BYTE,HardBreakScan)) THEN
      Break:= TRUE
    END;
    handleBreak;
    RETURN TRUE
  END handleKey;

PROCEDURE handleBut ( clicks: CARDINAL; loc: Point;
                      buts: MButtonSet; keys: SpecialKeySet ) :BOOLEAN;
  BEGIN
    handleBreak;
    RETURN TRUE
  END handleBut;

PROCEDURE handleMsg (buf: MessageBuffer): BOOLEAN;
  BEGIN
    handleBreak;
    RETURN TRUE
  END handleMsg;

(*
 * Ende der Watchdog-Prozeduren
 *)

VAR kbdStack: ARRAY [1..400] OF WORD;  (* 800 Byte fÅr Interrupt-Stack *)
    Carrier: XBRA.Carrier;
    kbdV: ADDRESS;
    wd1carrier, wd2carrier, wd3carrier, wd4carrier: WatchDogCarrier;

PROCEDURE EnableBreak (): BOOLEAN;
  VAR wdproc: EventProc; at: ADDRESS; kbdentry: ADDRESS;
  BEGIN
    IF ~enabled THEN
      terminating:= FALSE;
      Break:= FALSE;
      enabled:= TRUE;
      (* Watchdogs installieren *)
      WITH wdproc DO
        event:= timer;
        timeHdler:= handleTimer;
        InstallWatchDog (wd1carrier, wdproc);
        event:= keyboard;
        keyHdler:= handleKey;
        InstallWatchDog (wd2carrier, wdproc);
        event:= mouseButton;
        butHdler:= handleBut;
        InstallWatchDog (wd3carrier, wdproc);
        event:= message;
        msgType:= unspecMessage;
        msgHdler:= handleMsg;
        InstallWatchDog (wd4carrier, wdproc)
      END;
      (* Keyboard-Interrupt-Routine installieren *)
      kbdV:= ADDRESS (KeyboardVectors ()) + $20L;
      NewCaller (hdlKbd, FALSE, MEM (kbdStack), kbdentry);
      IF NOT XBRA.Installed (Kennung, kbdV, at) THEN
        XBRA.Create (Carrier, Kennung, kbdentry, entry);
        XBRA.Install (entry, at);
      END;
    END;
    RETURN TRUE
  END EnableBreak;

PROCEDURE DisableBreak;
  VAR at: ADDRESS;
  BEGIN
    IF enabled THEN
      enabled:= FALSE;
      IF XBRA.Installed (Kennung, kbdV, at) THEN
        XBRA.Remove (at);
      END;
      DeInstallWatchDog (wd4carrier);
      DeInstallWatchDog (wd3carrier);
      DeInstallWatchDog (wd2carrier);
      DeInstallWatchDog (wd1carrier);
    END
  END DisableBreak;


VAR wsp: MemArea;
    tcarrier: TermCarrier;

BEGIN
  enabled:= FALSE;
  wsp.bottom:= NIL;
  CatchProcessTerm (tcarrier, DisableBreak, wsp);
END UserBreak.
