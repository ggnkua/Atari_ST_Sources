MODULE MsMovTst;

FROM VDIInputs IMPORT MsMoveVecCarrier, InstallMsMoveProc;
FROM GrafBase IMPORT Point;
FROM MOSGlobals IMPORT MemArea;
FROM InOut IMPORT WriteString, Read;
FROM SYSTEM IMPORT ADR;

PROCEDURE MsMove (VAR loc: Point): BOOLEAN;
  BEGIN
    RETURN TRUE
  END MsMove;
  
VAR hdl: MsMoveVecCarrier;
    wsp: MemArea;
    ch: CHAR;
    stack: ARRAY [0..1000] OF CARDINAL;

BEGIN
  WriteString ('Test fÅr VDIInputs.InstallMsMoveProc ');
  wsp.bottom:= ADR (stack);
  wsp.length:= SIZE (stack);
  InstallMsMoveProc (hdl, MsMove, wsp);
  Read (ch);
END MsMovTst.
