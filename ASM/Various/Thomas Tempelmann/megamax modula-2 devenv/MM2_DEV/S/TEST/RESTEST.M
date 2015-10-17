MODULE ExcDemo;

FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD, VAL;
FROM ModCtrl IMPORT FirstModuleStart, ReleaseModule, InstallModule;
FROM MOSGlobals IMPORT MemArea;
FROM SysTypes IMPORT ExcSet, IRLevel4;
FROM Excepts IMPORT DeInstallExc, SysInstallSupvExc, ExcDesc, ExcProc;
FROM XBIOS IMPORT ScreenLogicalBase;

VAR bp, oldv, hdl: ADDRESS;
    ok: BOOLEAN;
    st: ARRAY [1..1000] OF CARDINAL;
    cnt, c2, i,a:CARDINAL;
    p: POINTER TO ARRAY [0..399] OF ARRAY [0..39] OF BITSET;
    vblwsp, termwsp: MemArea;


PROCEDURE term;
  BEGIN
    ASSEMBLER BREAK NOP NOP END;
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
    (*
    p:= ScreenLogicalBase ();
    vblwsp.bottom:= ADR (st);
    vblwsp.length:= SIZE (st);
    SysInstallSupvExc ( ExcSet {IRLevel4}, vbl, vblwsp, hdl);
    IF hdl # NIL THEN
    *)
      InstallModule (term, termwsp);  (* Modul resident machen *)
      ASSEMBLER BREAK END;
    (*END*)
  ELSE
    term
  END
END ExcDemo.
