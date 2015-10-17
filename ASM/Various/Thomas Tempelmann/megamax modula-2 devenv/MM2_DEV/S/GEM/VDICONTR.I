IMPLEMENTATION MODULE VDIControls;
(*$L-, N+, Y+*)


(*  MEGAMAX MODULA 2 GEM-Library :  Die VDI Kontrollfunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  29.10.87
 *
 *  MS: Michael Seyfried
 *
 *  Version   2.2     V#0021
 *)
 
(* 29.10.87     | öbernahme aus GEMBase
 * 08.04.89     | 'LoadFonts' liefert 'loaded' jetzt richtig als VAR-Parm.
 * 02.04.90     | Anpassung auf public arrays
 * 25.02.91 TT  | unloadFonts nach GEMShare Åbertragen; LoadFonts lîscht die
 *                Anzahl, wenn's schiefgeht.
 * 20.05.91 MS  | LoadFonts korrigiert
 *)
 
 
FROM    SYSTEM          IMPORT ASSEMBLER, WORD;

FROM    GrafBase        IMPORT Rectangle;

IMPORT  GEMShare;

FROM    GEMEnv          IMPORT DeviceHandle;

(*$I GEMOPS.ICL *)


PROCEDURE ClearWorkstation(handle:DeviceHandle);

BEGIN
  ASSEMBLER
        MOVE.W  #CLEAR_WORKSTATION,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
  END;
END ClearWorkstation;

PROCEDURE UpdateWorkstation(handle:DeviceHandle);

BEGIN
  ASSEMBLER
        MOVE.W  #UPDATE_WORKSTATION,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
  END;
END UpdateWorkstation;

PROCEDURE LoadFonts (handle: DeviceHandle; select: WORD; VAR loaded: CARDINAL);

  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  pubs,A0
        MOVE.W  -(A3),pubArrays.vINTIN(A0)
        MOVE.L  -4(A3),(A3)+            ; !MS 'handle' retten

        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     setDevice
        TST.W   (A7)+
        BNE     ok
        MOVE.L  (A7)+,A1
        CLR.W   (A1)
        SUBQ.L  #4,A3                   ; !MS 'handle' wegrÑumen
        BRA     ende
ok      MOVE.W  #LOAD_FONTS,(A3)+       ; !MS hier liegt 'handle' auf A3-Stack
        CLR.W   (A3)+
        JSR     vdi_if

        MOVE.L  pubs,A0
        MOVE.L  (A7)+,A1
        MOVE.W  pubArrays.vINTOUT(A0),(A1)
        BEQ     ende                    ; !MS hier stand falsch: 'BNE'

        MOVE.L  our_cb,A0
        MOVE.L  cb.CURDEVICE(A0),A1
        MOVE.W  #1,device.fontsLoaded(A1)
ende
    END;
  END LoadFonts;

PROCEDURE UnloadFonts(handle:DeviceHandle;select:WORD);

BEGIN
  ASSEMBLER
        JMP     unloadFonts
  END;
END UnloadFonts;

PROCEDURE SetClipping(handle:DeviceHandle;frame:Rectangle);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.W      #1,pubArrays.vINTIN(A0)
    LEA         pubArrays.PTSIN+8(A0),A1
    JSR         getCalcedFrame
    MOVE.W      #SET_CLIPPING,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
  END;
END SetClipping;

PROCEDURE DisableClipping(handle:DeviceHandle);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    CLR.W       pubArrays.vINTIN(A0)
    MOVE.W      #SET_CLIPPING,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
  END;
END DisableClipping;


END VDIControls.
(* $FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$0000032F$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665$FFF8B665Ä$00000250T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000001AF$00000253$00000232$0000023C$00000250$FFF1339E$FFF1339E$FFF1339E$FFF1339E$FFF1339E$FFF1339E$FFEB643A$FFF1339E$00000228$FFF1339E$000000E1îÄÉ*)
