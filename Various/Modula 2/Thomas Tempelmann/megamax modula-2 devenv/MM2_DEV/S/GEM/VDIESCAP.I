IMPLEMENTATION MODULE VDIEscapes;
(*$L-, N-, Y+*)


(*      Implementation der MEGAMAX MODULA II GEM Library (Escape-Funk.)
 *
 *      geschrieben von Manuel Chakravarty
 *
 *      Version 2.2     V#0038      Erstellt MÑrz-Oktober 1987
 *)

(*  ???????? TT  V2.1   | REF-Parm.
 *  02.04.90 MCH V2.2   | Anpassung auf public arrays
 *  15.09.91 MS         | WriteToMetafile korrigiert
 *)
 
 
FROM    SYSTEM          IMPORT ASSEMBLER, ADDRESS;
 
FROM    GrafBase        IMPORT Point, Rectangle;
 
IMPORT  GEMShare;

FROM    GEMEnv          IMPORT DeviceHandle;

(*$I GEMOPS.ICL *)


PROCEDURE GetCharCells(handle:DeviceHandle;VAR rows,columns:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.L  -12(A3),(A3)+
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #VQ_CHCELLS,(A3)+
        JSR     vdi_if
        MOVE.L  pubs,A0
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.vINTOUT+2(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.vINTOUT(A0),(A1)
        SUBQ.L  #4,A3
  END;
END GetCharCells;

PROCEDURE ExitCursorMode(handle:DeviceHandle);

BEGIN
  ASSEMBLER
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_EXIT_CUR,(A3)+
        JSR     vdi_if
  END;
END ExitCursorMode;

PROCEDURE EnterCursorMode(handle:DeviceHandle);

BEGIN
  ASSEMBLER
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_ENTER_CUR,(A3)+
        JSR     vdi_if
  END;
END EnterCursorMode;

PROCEDURE CursorUp(handle:DeviceHandle);

BEGIN
  ASSEMBLER
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_CURUP,(A3)+
        JSR     vdi_if
  END;
END CursorUp;

PROCEDURE CursorDown(handle:DeviceHandle);

BEGIN
  ASSEMBLER
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_CURDOWN,(A3)+
        JSR     vdi_if
  END;
END CursorDown;

PROCEDURE CursorRight(handle:DeviceHandle);

BEGIN
  ASSEMBLER
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_CURRIGHT,(A3)+
        JSR     vdi_if
  END;
END CursorRight;

PROCEDURE CursorLeft(handle:DeviceHandle);

BEGIN
  ASSEMBLER
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_CURLEFT,(A3)+
        JSR     vdi_if
  END;
END CursorLeft;

PROCEDURE CursorHome(handle:DeviceHandle);

BEGIN
  ASSEMBLER
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_CURHOME,(A3)+
        JSR     vdi_if
  END;
END CursorHome;

PROCEDURE EraseToEndOfScreen(handle:DeviceHandle);

BEGIN
  ASSEMBLER
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_EEOS,(A3)+
        JSR     vdi_if
  END;
END EraseToEndOfScreen;

PROCEDURE EraseToEndOfLine(handle:DeviceHandle);

BEGIN
  ASSEMBLER
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_EEOL,(A3)+
        JSR     vdi_if
  END;
END EraseToEndOfLine;

PROCEDURE LocateCursor(handle:DeviceHandle;column,row:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.L  pubs,A0
        MOVE.L  -(A3),D0
        SWAP    D0
        MOVE.L  D0,pubArrays.vINTIN(A0)
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #VS_CURADDRESS,(A3)+
        JSR     vdi_if
  END;
END LocateCursor;

PROCEDURE CursorText(handle:DeviceHandle;REF str:ARRAY OF CHAR);

BEGIN
  ASSEMBLER
        MOVE.L  D4,-(A7)
        CLR.W   D4                      ; Kein Offset
        JSR     stringIntoINTIN
        MOVE.W  -(A3),D0                ; RÅckgabewert: StringlÑnge
        
        MOVE.W  D0,-(A7)
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     setDevice
        MOVE.W  (A7)+,D1
        MOVE.W  (A7)+,D0
        TST.W   D1
        BEQ     ende
        
        MOVE.L  our_cb,A0
        MOVE.L  A0,(A3)+                ; our_cb^ fÅr vdi_call pushen
        MOVE.W  #ESCAPE,cb.V_CONTRL.opcode(A0)
        CLR.W   cb.V_CONTRL.sptsin(A0)
        MOVE.W  D0,cb.V_CONTRL.sintin(A0)
        MOVE.W  #V_CURTEXT,cb.V_CONTRL.subcmd(A0)
        MOVE.L  cb.CURDEVICE(A0),A1
        MOVE.W  device.handle(A1),cb.V_CONTRL.handle(A0)
        JSR     vdi_call
ende
        MOVE.L  (A7)+,D4
  END;
END CursorText;

PROCEDURE ReverseVideoOn(handle:DeviceHandle);

BEGIN
  ASSEMBLER
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_RVON,(A3)+
        JSR     vdi_if
  END;
END ReverseVideoOn;

PROCEDURE ReverseVideoOff(handle:DeviceHandle);

BEGIN
  ASSEMBLER
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_RVOFF,(A3)+
        JSR     vdi_if
  END;
END ReverseVideoOff;

PROCEDURE GetCursorLocation(handle:DeviceHandle;VAR column,row:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.L  -12(A3),(A3)+
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #VQ_CURADDRESS,(A3)+
        JSR     vdi_if
        MOVE.L  pubs,A0
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.vINTOUT(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.vINTOUT+2(A0),(A1)
        SUBQ.L  #4,A3
  END;
END GetCursorLocation;

PROCEDURE TabletStatus(handle:DeviceHandle):BOOLEAN;

BEGIN
  ASSEMBLER
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #VQ_TABSTATUS,(A3)+
        JSR     vdi_if
        MOVE.L  pubs,A0
        MOVE.W  pubArrays.vINTOUT(A0),(A3)+
  END;
END TabletStatus;

PROCEDURE HardCopy(handle:DeviceHandle);

BEGIN
  ASSEMBLER
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_HARDCOPY,(A3)+
        JSR     vdi_if
  END;
END HardCopy;

PROCEDURE DisplayCursor(handle:DeviceHandle;row,column:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.L  pubs,A0
        MOVE.L  -(A3),pubArrays.PTSIN(A0)
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_DSPCUR,(A3)+
        JSR     vdi_if
  END;
END DisplayCursor;

PROCEDURE RemoveCursor(handle:DeviceHandle);

  BEGIN
    ASSEMBLER
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_RMCUR,(A3)+
        JSR     vdi_if
    END;
  END RemoveCursor;

(*      Folgende Routinen sind nur bei geladenem GDOS verfÅgbar.
 *)
 
PROCEDURE FormAdvance (handle:DeviceHandle);

  BEGIN
    ASSEMBLER
        MOVE.W  #ESCAPE, (A3)+
        MOVE.W  #V_FORM_ADV, (A3)+
        JSR     vdi_if
    END;
  END FormAdvance;

PROCEDURE OutputWindow (handle:DeviceHandle; frame:Rectangle);

  BEGIN
    ASSEMBLER
        MOVE.L  pubs, A0
        LEA     pubArrays.PTSIN+8(A0), A1
        JSR     getCalcedFrame
        MOVE.W  #ESCAPE, (A3)+
        MOVE.W  #V_OUTPUT_WINDOW, (A3)+
        JSR     vdi_if
    END;
  END OutputWindow;
         
PROCEDURE ClearDisplayList (handle:DeviceHandle);

  BEGIN
    ASSEMBLER
        MOVE.W  #ESCAPE, (A3)+
        MOVE.W  #V_CLEAR_DISP_LIST, (A3)+
        JSR     vdi_if
    END;
  END ClearDisplayList;
         
PROCEDURE OutputBitImage (handle:DeviceHandle; REF fname:ARRAY OF CHAR;
                          aspect:AspectRatio; scaling: ScaleMode;
                          numPts:CARDINAL; frame:Rectangle);
                          
  END OutputBitImage;
         
PROCEDURE SelectPalette (handle:DeviceHandle; palette:CARDINAL);

  END SelectPalette;
         
PROCEDURE GetFilmTypes (handle:DeviceHandle; VAR films:ARRAY OF CHAR);

  END GetFilmTypes;
         
PROCEDURE GetDriverState (handle:DeviceHandle; VAR port, film:CARDINAL;
                          VAR lightness:INTEGER; VAR interlace:BOOLEAN;
                          VAR planes:CARDINAL; VAR indexes:IndexArray);
                          
  END GetDriverState;
         
PROCEDURE SetDriverState (handle:DeviceHandle; port, film:CARDINAL;
                          lightness:INTEGER; interlace:BOOLEAN;
                          planes:CARDINAL; indexes:IndexArray);
                          
  END SetDriverState;
         
PROCEDURE SaveDriverState (handle:DeviceHandle);

  END SaveDriverState;
         
PROCEDURE SuppressPaletteMsg (handle:DeviceHandle);

  END SuppressPaletteMsg;
         
PROCEDURE PaletteError (handle:DeviceHandle): CARDINAL;

  END PaletteError;
         
PROCEDURE MetafileExtents (handle:DeviceHandle; min, max:Point);

  BEGIN
    ASSEMBLER
        MOVE.L  pubs, A0
        MOVE.L  -(A3), pubArrays.PTSIN+4(A0)
        MOVE.L  -(A3), pubArrays.PTSIN(A0)
        MOVE.W  #ESCAPE, (A3)+
        MOVE.W  #V_META_EXTENTS, (A3)+
        JSR     vdi_if
    END;
  END MetafileExtents;

PROCEDURE WriteToMetafile (handle:DeviceHandle;
                           numIntin:CARDINAL; REF vINTIN:ARRAY OF INTEGER;
                           numPtsin:CARDINAL; REF ptsin:ARRAY OF INTEGER);

  (*$L+*)
  BEGIN
    ASSEMBLER
        MOVE.L  handle(A6), (A3)+
        ; MOVE.L  A1,-(A7)             (* !MS *)
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     setDevice
        ; MOVE.W  (A7)+,(A3)+          (* !MS *)
        ; MOVE.L  (A7)+,A1             (* !MS *)
        TST.W   (A7)+                  (* !MS *)
        BEQ     ende

        MOVE.L  our_cb,A0               ; Build up the ctrl-array
        MOVE.L  A0, (A3)+               ; our_cb^ fÅr vdi_call pushen !MS
        MOVE.W  #ESCAPE,cb.V_CONTRL.opcode(A0)
        MOVE.W  #V_WRITE_META,cb.V_CONTRL.subcmd(A0)
        MOVE.L  cb.CURDEVICE(A0),A1
        MOVE.W  device.handle(A1),cb.V_CONTRL.handle(A0)

        MOVE.W  numIntin(A6), cb.V_CONTRL.sintin(A0)
        MOVE.W  numPtsin(A6), cb.V_CONTRL.sptsin(A0)
        MOVE.L  cb.VDIPB.intin(A0), -(A7)
        MOVE.L  cb.VDIPB.ptsin(A0), -(A7)
        MOVE.L  vINTIN(A6), cb.VDIPB.intin(A0)
        MOVE.L  ptsin(A6), cb.VDIPB.ptsin(A0)

        JSR     vdi_call

        MOVE.L  our_cb, A0
        MOVE.L  (A7)+, cb.VDIPB.ptsin(A0)
        MOVE.L  (A7)+, cb.VDIPB.intin(A0)
ende
    END;
  END WriteToMetafile;
  (*$L=*)

PROCEDURE SetVDIFileName (handle:DeviceHandle; REF fname:ARRAY OF CHAR);

  BEGIN
    ASSEMBLER
        MOVE.L  D4,-(A7)
        CLR.W   D4                      ; Kein Offset
        JSR     stringIntoINTIN
        MOVE.W  -(A3),D0                ; RÅckgabewert: StringlÑnge
        
        MOVE.W  D0,-(A7)
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     setDevice
        MOVE.W  (A7)+,D1
        MOVE.W  (A7)+,D0
        TST.W   D1
        BEQ     ende
        
        MOVE.L  our_cb,A0
        MOVE.L  A0,(A3)+                ; our_cb^ fÅr vdi_call pushen
        MOVE.W  #ESCAPE,cb.V_CONTRL.opcode(A0)
        CLR.W   cb.V_CONTRL.sptsin(A0)
        MOVE.W  D0,cb.V_CONTRL.sintin(A0)
        MOVE.W  #VM_FILENAME,cb.V_CONTRL.subcmd(A0)
        MOVE.L  cb.CURDEVICE(A0),A1
        MOVE.W  device.handle(A1),cb.V_CONTRL.handle(A0)
        JSR     vdi_call
ende
        MOVE.L  (A7)+,D4
    END;
  END SetVDIFileName;
 
PROCEDURE SetLineOffset (handle:DeviceHandle; offset:INTEGER);

BEGIN
  ASSEMBLER
        MOVE.L  pubs,A0
        MOVE.W  -(A3),pubArrays.vINTIN(A0)
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_OFFSET,(A3)+
        JSR     vdi_if
  END;
END SetLineOffset;
         
PROCEDURE InitSystemFont (handle:DeviceHandle; fontHeader:ADDRESS);

BEGIN
  ASSEMBLER
        MOVE.L  pubs,A0
        MOVE.L  -(A3),pubArrays.vINTIN(A0)
        MOVE.W  #ESCAPE,(A3)+
        MOVE.W  #V_FONTINIT,(A3)+
        JSR     vdi_if
  END;
END InitSystemFont;
         

END VDIEscapes.
(* $FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFEDE4C8$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770$FFF8D770Ä$00000194T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$FFEDE4C8$FFEDE4C8$FFEDE4C8$00000161$0000016C$00000175$00000194$00000188$FFEDE4C8$FFEC5652$000023C1$000023DF$FFEC5652$000024B6$000024D4$00000033†ÄÉ*)
