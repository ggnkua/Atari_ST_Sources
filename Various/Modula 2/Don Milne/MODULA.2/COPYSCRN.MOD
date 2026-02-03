TITLE: Modula-2 program to copy to and from the screen
This program uses the CopyRasterOpaque procedure to copy the screen to
an array, then shoot it back to the screen.  It is very similar to a C
listing shown previously.  This will only work if you have the Developer's
version with the XBIOS module.

MODULE CopyScreen;

FROM SYSTEM IMPORT ADR, BYTE;

FROM XBIOS IMPORT ScreenPhysicalBase;

FROM GEMVDIbase IMPORT
  VDIWorkInType, VDIWorkOutType, BigPxyArrayType;

FROM AESApplications IMPORT
  ApplInitialise, ApplExit;

FROM AESGraphics IMPORT GrafHandle;

FROM VDIControls IMPORT
  OpenVirtualWorkstation, CloseVirtualWorkstation;

FROM TextIO IMPORT
  WriteString, WriteLn, ReadLn;

FROM VDIRasters IMPORT
  MFDBType, CopyRasterOpaque;

FROM VDIEscapes IMPORT
  CursorHome, EraseToEOS;

VAR GraphHandle            : INTEGER;
    ScreenBuffer           : ARRAY [0..31999] OF BYTE;
    ScreenMFDB, BufferMFDB : MFDBType;
    PxyArray               : BigPxyArrayType;

PROCEDURE CloseWindow;

  BEGIN
    CloseVirtualWorkstation (GraphHandle);
    ApplExit;
  END CloseWindow;

PROCEDURE OpenWindow;

  VAR Appl     : INTEGER;
      i,j      : INTEGER;
      workIn   : VDIWorkInType;
      workOut  : VDIWorkOutType;

  BEGIN
    Appl := ApplInitialise();
    GraphHandle := GrafHandle (j,j,j,j);
    FOR i := 0 TO 9 DO
       workIn[i] := 1;
    END;
    workIn[10] := 2;
    OpenVirtualWorkstation (workIn, GraphHandle, workOut);
  END OpenWindow;

PROCEDURE InitVariables;

  BEGIN
    WITH ScreenMFDB DO
      pointer := ScreenPhysicalBase();
      width   := 639;
      height  := 399;
      widthW  := 40;
      format  := 1;
      planes  := 1;
      rsrvd1  := 0;
      rsrvd2  := 0;
    END;
    WITH BufferMFDB DO
      pointer := ADR(ScreenBuffer);
      width   := 639;
      height  := 399;
      widthW  := 40;
      format  := 1;
      planes  := 1;
      rsrvd1  := 0;
      rsrvd2  := 0;
    END;
    PxyArray[0] := 0;
    PxyArray[1] := 0;
    PxyArray[2] := 639;
    PxyArray[3] := 399;
    PxyArray[4] := 0;
    PxyArray[5] := 0;
    PxyArray[6] := 639;
    PxyArray[7] := 399;
  END InitVariables;

BEGIN (* main routine *)
  OpenWindow;
  InitVariables;
CopyRasterOpaque (GraphHandle, 3, PxyArray,
                    ADR(ScreenMFDB), ADR(BufferMFDB));
  CursorHome (GraphHandle);
  EraseToEOS (GraphHandle);
  WriteString ("The Screen has been copied into a buffer.");
  WriteLn;
  WriteString ("Press Return to restore the screen, then press Return");
  WriteString (" again to exit the program.");
  ReadLn;
  CopyRasterOpaque (GraphHandle, 3, PxyArray,
                    ADR(BufferMFDB), ADR(ScreenMFDB));
  ReadLn;
  CloseWindow;
END CopyScreen.
