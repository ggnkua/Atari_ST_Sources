IMPLEMENTATION  MODULE DRAWINNDC;
IMPORT VDIControls;
IMPORT GEMVDIbase;
IMPORT AESEvents;
IMPORT VDIAttribs;
IMPORT VDIOutputs;
IMPORT GEMAESbase;

PROCEDURE DRAWNDC(HANDLE:INTEGER);
VAR 
        PXY:ARRAY [0..3] OF INTEGER;
       X1,Y1,X2,Y2,INCR: INTEGER;
BEGIN
        X1:=0;
        Y1:=0;
        X2:=32767;
        Y2:=32767;
        INCR:=3000;
        WHILE (X1< 32767 ) AND (X2>=0) DO
              PXY[0]:=X1;
              PXY[1]:=Y1;
              PXY[2]:=X2;
              PXY[3]:=Y2;
            VDIOutputs.PolyLine(HANDLE,2,PXY); (* OUTPUT 2 POINT POLYLINE *)
              X1:=X1 + INCR;
              Y1:=Y1 + INCR;
              X2:=X2- INCR;
       END; (* WHILE *)
  
END DRAWNDC;

BEGIN
END DRAWINNDC.

 