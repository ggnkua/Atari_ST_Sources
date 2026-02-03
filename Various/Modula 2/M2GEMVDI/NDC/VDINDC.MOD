MODULE VDIOPEN;
IMPORT AESApplications;
IMPORT AESGraphics;
IMPORT VDIControls;
IMPORT GEMVDIbase;
IMPORT AESEvents;
IMPORT VDIAttribs;
IMPORT VDIOutputs;
IMPORT GEMAESbase;
FROM  DRAWINNDC IMPORT DRAWNDC;

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
        WORKIN[10]:= 0; (*NDC *)
        VDIControls.OpenVirtualWorkstation(WORKIN,HANDLE,WORKOUT);
        DRAWNDC(HANDLE);
        VDIOutputs.GraphicText(HANDLE,32767,0,'PRESS ANY KEY TO CONTINUE');
        KEY:=AESEvents.EventKeyboard();
        VDIControls.CloseVirtualWorkstation(HANDLE);
        AESApplications.ApplExit;
END VDIOPEN.
