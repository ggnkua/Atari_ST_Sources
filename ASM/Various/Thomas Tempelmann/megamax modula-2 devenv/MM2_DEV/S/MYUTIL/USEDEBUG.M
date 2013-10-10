MODULE UseDebug;

FROM MOSGlobals IMPORT MEM, MemArea;
FROM ModCtrl IMPORT FirstModuleStart, ReleaseModule, InstallModule;
IMPORT TOSDebug;

VAR ok: BOOLEAN;
    wsp, termwsp: MemArea;
    stack: ARRAY [1..50000] OF CARDINAL; (* 100 KB Stack *)

PROCEDURE term;
  BEGIN
    ReleaseModule;
  END term;

BEGIN
  IF FirstModuleStart () THEN
    wsp:= MEM (stack);
    IF ODD (wsp.length) THEN DEC (wsp.length) END; (* wg. Fehler in MEM *)
    InstallModule (term, termwsp);  (* Modul resident machen *)
  ELSE
    term;
  END
END UseDebug.
