IMPLEMENTATION  MODULE DRAWINRC;
IMPORT VDIControls;
IMPORT GEMVDIbase;
IMPORT AESEvents;
IMPORT VDIAttribs;
IMPORT VDIOutputs;
IMPORT GEMAESbase;
FROM Strings IMPORT String;

PROCEDURE DRAWRC(HANDLE:INTEGER;DX,DY,SW,SH:INTEGER);
VAR 
        LABELS:ARRAY [0..6] OF String;
        PXY:ARRAY [0..3] OF INTEGER;
        SETINT,CURY,INCRY,LINETYPE:INTEGER;

BEGIN
        LABELS[0]:=' 0';
        LABELS[1]:=' 1';
        LABELS[2]:=' 2';
        LABELS[3]:= ' 3';
        LABELS[4]:= ' 4';
        LABELS[5]:=' 5';
        LABELS[6]:=' 6';
        INCRY := SH DIV 7;
        CURY:= DY + INCRY;
        PXY[2] := DX + (SW DIV 8);
        PXY[0]:= DX + 6*(SW DIV 8);
        FOR LINETYPE := 1 TO 6 DO
           SETINT:=  VDIAttribs.SetLineType(HANDLE,LINETYPE);
            PXY[1]:=CURY;
            PXY[3]:=CURY;
            VDIOutputs.PolyLine(HANDLE,2,PXY);
            VDIOutputs.GraphicText(HANDLE,PXY[0],PXY[1],LABELS[LINETYPE]);
            CURY:= CURY + INCRY;
       END;
        SETINT:= VDIAttribs.SetLineType(HANDLE,1); (* RESET TO DEFAULT *)
END DRAWRC;

BEGIN
END DRAWINRC.

 