MODULE VBLTest;

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
FROM MOSGlobals IMPORT MemArea;
FROM SysTypes IMPORT ExcSet, ExcDesc, IRLevel4;
FROM Excepts IMPORT DeInstallExc, SysInstallPreExc;
FROM InOut IMPORT WriteString, WriteLn, WriteCard, Write, BusyRead;

CONST freq = 100;

VAR cnt2[4]: LONGCARD;

VAR bp, oldv, hdl: ADDRESS;
    ch: CHAR;
    tick, ok: BOOLEAN;
    st: ARRAY [1..1000] OF CARDINAL;
    ticks, vbl_cnt, c2, i,a:CARDINAL;
    p: POINTER TO ARRAY [0..399] OF ARRAY [0..39] OF BITSET;
    vblwsp, termwsp: MemArea;
    l: LONGCARD;


PROCEDURE vbl (VAR x: ExcDesc): BOOLEAN;
  (*$R- keine Pfungen, damit es etwas schneller geht *)
  VAR b: BITSET;
  BEGIN
    INC (vbl_cnt);
    IF (vbl_cnt MOD freq) = 0 THEN
      INC (ticks);
      tick:= TRUE;
    END;
    RETURN TRUE
  END vbl;
  (*$R=*)

BEGIN
  vblwsp.bottom:= ADR (st);
  vblwsp.length:= SIZE (st);
  SysInstallPreExc (ExcSet {IRLevel4}, vbl, FALSE, vblwsp, hdl);
  IF hdl # NIL THEN
    vbl_cnt:= 0;
    ticks:= 0;
    tick:= FALSE;
    cnt2:= 0;
    l:= cnt2 + freq;
    LOOP
      BusyRead (ch);
      IF (ch # 0C) THEN EXIT END;
      IF cnt2 >= l THEN
        l:= cnt2 + freq;
        WriteString ("        ");
        WriteCard (cnt2 DIV freq, 0);
        WriteLn;
      END;
      IF tick THEN
        tick:= FALSE;
        WriteCard (ticks, 0);
        WriteLn;
      END;
    END;
    DeInstallExc (hdl);
  END
END VBLTest.
