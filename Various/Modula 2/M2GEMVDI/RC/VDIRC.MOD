MODULE VDIOPEN;
IMPORT AESApplications;
IMPORT AESGraphics;
IMPORT VDIControls;
IMPORT GEMVDIbase;
IMPORT AESEvents;
IMPORT VDIAttribs;
IMPORT VDIOutputs;
IMPORT GEMAESbase;
FROM  DRAWINRC IMPORT DRAWRC;

 VAR
        APPL,HANDLE,MAXW,MAXH,KEY,I,WCHAR,HCHAR,WBOX,HBOX:INTEGER;
        WORKIN:GEMVDIbase.VDIWorkInType;
        WORKOUT:GEMVDIbase.VDIWorkOutType;


BEGIN
        APPL:= AESApplications.ApplInitialise();
        HANDLE:=AESGraphics.GrafHandle(WCHAR,HCHAR,WBOX,HBOX);
        AESGraphics.GrafMouse(GEMAESbase.MouseOff,NIL);
        VDIControls.ClearWorkstation(HANDLE);
        FOR I:= 0 TO 10 DO; 
            WORKIN[I]:=1;
        END;
        WORKIN[10]:= 2; (* RC *)
        VDIControls.OpenVirtualWorkstation(WORKIN,HANDLE,WORKOUT);
        MAXW:=WORKOUT[0]; MAXH:=WORKOUT[1];
        DRAWRC(HANDLE,0,0,MAXW,MAXH);
        VDIOutputs.GraphicText(HANDLE,MAXW,MAXH,'PRESS ANY KEY TO CONTINUE');
        KEY:=AESEvents.EventKeyboard();
        VDIControls.CloseVirtualWorkstation(HANDLE);
        AESApplications.ApplExit;
END VDIOPEN.


(******* end of VDIRC.MOD  file *********)

DEFINITION  MODULE DRAWINRC;


PROCEDURE DRAWRC(HANDLE:INTEGER;DX,DY,SW,SH:INTEGER);

END DRAWINRC.

 
(**** END OF DRAWINRC.DEF **)

IMPLEMENTATION  MODULE DRAWINRC;
IMPORT VDIControls;
IMPORT GEMVDIbase;
IMPORT AESEvents;
IMPORT VDIAttribs;
IMPORT VDIOutputs;
IMPORT GEMAESbase;

PROCEDURE DRAWRC(HANDLE:INTEGER;DX,DY,SW,SH:INTEGER);
CONST 
        SQUARED =0;
        ARROWED = 1;
        ROUNDED = 2;
VAR
         THICKTAB:ARRAY [0..3] OF INTEGER ;
          PXY:ARRAY[0..3] OF INTEGER;
          CURX,CURY,INCRX,INCRY,SEPY:INTEGER;
          TT,THICKNESS,BEGINSTYLE,ENDSTYLE:INTEGER;
          SETINT:INTEGER;
BEGIN
        THICKTAB[0]:= 1 ;
         THICKTAB[1]:=4 ;
          THICKTAB[2]:=8 ;
           THICKTAB[3]:=16 ;
        THICKNESS:= SW DIV 600; (* MAGIC MULTIPLIER; SYSTEM DEPENDENT *)
        FOR TT:=0 TO 3 DO 
            THICKTAB[TT]:= THICKTAB[TT] * THICKNESS;
        END;
        INCRX:=SW DIV 10 ; (* COLUMN WIDTH *)
        INCRY := SH DIV 4; (* ROW HEIGHT *)
        SEPY:= INCRY DIV 6; (* DISTANCE TO SEPARATE ROWS *)
        CURY:= DY + SH - (SEPY DIV 2) ; (* DISPLAY AT BOTTOM OF SCREEN *)
        FOR TT := 0 TO 3 DO
            THICKNESS:=THICKTAB[TT];
            SETINT:=VDIAttribs.SetLineWidth(HANDLE,THICKNESS);
            CURX:= DX + (INCRX DIV 2);
            FOR ENDSTYLE := SQUARED TO ROUNDED DO
                FOR BEGINSTYLE := SQUARED TO ROUNDED DO
                    VDIAttribs.SetEndLineStyle(HANDLE,BEGINSTYLE,ENDSTYLE);
                    PXY[0]:=CURX;
                    PXY[1]:=CURY;
                    CURX:=CURX + INCRX;
                    PXY[2]:=CURX;
                    PXY[3]:=CURY - (INCRY-SEPY);
                    VDIOutputs.PolyLine(HANDLE,2,PXY);
               END;
                END; 
               CURY:= CURY-INCRY;
           END; (* for tt *)
      SETINT:=VDIAttribs.SetLineWidth(HANDLE,1); (* RESET LINE THICKNESS *)
         VDIAttribs.SetEndLineStyle(HANDLE,SQUARED,SQUARED);            
     
END DRAWRC;

BEGIN
END DRAWINRC.

 
(***** END OF LINESYTLE.MOD FILE ******)
