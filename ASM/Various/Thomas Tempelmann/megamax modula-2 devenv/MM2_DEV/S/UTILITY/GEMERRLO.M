MODULE GEMErrLocator;

(*
 * Wenn bei Aufruf einer GEM-Funktion ein Fehler auftritt, merkt
 * man in der Regel dort erstmal nichts, weil selten der Fehler
 * mittels "GEMEnv.GemError()" abgefragt wird. DafÅr wird dann
 * aber beim nÑchsten GEM-Aufruf automatisch Åber die "GEMEnv.
 * ErrorProc" ein Fehler angezeigt, dessen Text etwa so lautet:
 *
 *  "Fehler bei letztem GEM-Aufruf"
 *
 * Wie soll man den nun finden? Welches ist der vorige GEM-Aufruf,
 * bei dem der Fehler auftrat?
 *
 * Dazu dient dieses Modul. Wird es gestartet, meldet es Åber
 * "GEMEnv.ErrHdlProc" jeden GEM-Fehler sofort. Dann wird die
 * bekannte Scan-Box angezeigt, sodaû Sie darin die aufrufende
 * Funktion leicht finden kînnen.
 *
 * Um das Modul wieder zu entfernen, brauchen Sie es nur erneut
 * zu starten oder die Shell zu verlassen.
 *)

FROM ModCtrl IMPORT InstallModule, ReleaseModule, FirstModuleStart;
FROM PrgCtrl IMPORT TermProcess;
FROM MOSGlobals IMPORT MemArea;
FROM SysTypes IMPORT ScanDesc;
FROM SysCtrl IMPORT GetScanAddr;
FROM GEMScan IMPORT InitChain, InputScan;
FROM AESForms IMPORT FormAlert;
FROM GEMEnv IMPORT GemError, ErrHdlProc;

PROCEDURE showGEMerror;
  VAR scanidx, button: CARDINAL;
      scan: ScanDesc;
      dummy: BOOLEAN;
  BEGIN
    dummy:= GemError (); (* GEM-Fehler abfragen, um autom. Meldung abzustellen*)
    GetScanAddr (scan); (* eigene Scan-Position ermitteln *)
    InitChain (scan);   (* Scan-Positionen der Aufruferkette ermitteln *)
    scanidx:= 2;
    InputScan ('GEM-Fehler aufgetreten!', scanidx); (* Scanner anzeigen *)
    (* Nachfragen, ob Programm beendet werden soll *)
    FormAlert (1, "[0][ Programm beenden? ][ Ja |Nein]", button);
    IF button = 1 THEN
      TermProcess (-1)
    END
  END showGEMerror;

VAR oldValue: PROC;

PROCEDURE release;
  BEGIN
    (* Modul entfernen, vorigen Err-Handler wieder installieren *)
    ErrHdlProc:= oldValue;
    ReleaseModule ()
  END release;

BEGIN
  IF FirstModuleStart () THEN
    oldValue:= ErrHdlProc;
    ErrHdlProc:= showGEMerror;
    InstallModule (release, MemArea {NIL, 0})
  ELSE
    release
  END
END GEMErrLocator.
