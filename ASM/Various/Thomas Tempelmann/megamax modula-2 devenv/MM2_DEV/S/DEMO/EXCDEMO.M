MODULE ExcDemo;

(*
 * Dieses Programm demonstriert, wie Modula-Funktionen in Exception-
 * Vektoren installiert werden k”nnen.
 *
 * Hier wird die Prozedur 'vbl' im Interrupt-Vektor (Level 4) installiert.
 * Somit wird sie ca. 50-70 Mal pro Minute aufgerufen. Die Funktion l„žt
 * zur Kontrolle ein kleines Lauflicht oben links auf dem Bildschirm er-
 * scheinen.
 *
 * Wird das Modul unter der Shell gestartet, kann es beim Beenden der Shell
 * oder durch wiederholten Start wieder freigegeben werden.
 *
 * Achtung:
 *   Das Modul darf nicht vollst„ndig optimiert werden, wenn es gelinkt
 *   werden soll. Vielmehr ist die mittlere Optimierung zu w„hlen, damit
 *   die Link-Informationen zum Residentmachen des Programms erhalten
 *   bleiben.
 *)

FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD;
FROM ModCtrl IMPORT FirstModuleStart, ReleaseModule, InstallModule;
FROM MOSGlobals IMPORT MemArea;
FROM SysTypes IMPORT ExcSet, ExcDesc, IRLevel4;
FROM Excepts IMPORT DeInstallExc, SysInstallPreExc;
FROM XBIOS IMPORT ScreenLogicalBase;

VAR bp, oldv, hdl: ADDRESS;
    ok: BOOLEAN;
    st: ARRAY [1..1000] OF CARDINAL;
    cnt, c2, i,a:CARDINAL;
    p: POINTER TO ARRAY [0..399] OF ARRAY [0..39] OF BITSET;
    vblwsp, termwsp: MemArea;


PROCEDURE term;
  BEGIN
    DeInstallExc (hdl);
    ReleaseModule;
  END term;

PROCEDURE vbl (VAR x: ExcDesc): BOOLEAN;
  (*$R- keine Pfungen, damit es etwas schneller geht *)
  VAR b: BITSET;
  BEGIN
    INC (cnt);
    IF cnt > 3 THEN
      cnt:= 0;
      b:= {};
      INCL (b, a);
      IF a=0 THEN a:= 15; ELSE DEC (a) END;
      p^[0,0]:= b;
      p^[1,0]:= b;
      p^[2,0]:= b;
      p^[3,0]:= b;
    END;
    RETURN TRUE
  END vbl;
  (*$R=*)

BEGIN
  IF FirstModuleStart () THEN
    p:= ScreenLogicalBase ();
    vblwsp.bottom:= ADR (st);
    vblwsp.length:= SIZE (st);
    SysInstallPreExc (ExcSet {IRLevel4}, vbl, FALSE, vblwsp, hdl);
    IF hdl # NIL THEN
      InstallModule (term, termwsp);  (* Modul resident machen *)
    END
  ELSE
    term
  END
END ExcDemo.
