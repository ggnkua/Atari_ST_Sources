IMPLEMENTATION MODULE AESWindows;
(*$L-, N+, Y+*)


(*  Megamax Modula-2 GEM-Library :  Die AES Fensterfunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  05.11.87
 *
 *  Version   2.2     V#0029
 *)
 
(*  05.11.87    | öbernahme von 'GEMBase' und 'GEMExt'
 *  20.11.87    | Def. + Impl. von 'ResetWindows'
 *  15.02.90    | Anpassung an Compilerversion 4.0
 *  02.04.90    | Anpassung an public arrays
 *  05.10.90    | Keine verdrehten SETs mehr
 *)


FROM    SYSTEM          IMPORT ASSEMBLER;

FROM    MOSGlobals      IMPORT MemArea;

FROM    GrafBase        IMPORT Point, Rectangle;

FROM    GEMGlobals      IMPORT PtrMaxStr, PtrObjTree;

IMPORT  GEMShare;

(*$I GEMOPS.ICL *)
 
 
PROCEDURE CreateWindow(kind:WElementSet;max:Rectangle; VAR handle:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.L  -(A3),-(A7)
        
        MOVE.L  pubs,A0
        LEA     pubArrays.aINTIN+$A(A0),A0
        MOVE.L  -(A3),-(A0)
        MOVE.L  -(A3),-(A0)
        MOVE.W  -(A3), D0
        ;ROR.L   #8, D0                  ; SET conversion
        MOVE.W  D0,-(A0)
        MOVE.W  #WIND_CREATE,(A3)+
        JSR     aes_if
        MOVE.L  pubs,A0
        MOVE.L  our_cb, A1
        MOVE.W  pubArrays.aINTOUT(A0),D0
        
        CMP.W   #NoWindow,D0
        BEQ     noSuper                 ; falls supervision und korr. Wind.Hand.
        MOVE.L  cb.SUPERVISION.createWinds(A1),D1
        BSET    D0,D1                   ; speichere das handle in der Liste
        MOVE.L  D1,cb.SUPERVISION.createWinds(A1)
noSuper

        MOVE.L  (A7)+,A0
        MOVE.W  D0,(A0)
  END;
END CreateWindow;

PROCEDURE OpenWindow(handle:CARDINAL;frame:Rectangle);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.L      our_cb, A2
    LEA         pubArrays.aINTIN+$A(A0),A1
    MOVE.L      -(A3),-(A1)
    MOVE.L      -(A3),-(A1)
    MOVE.W      -(A3),D0
    
    MOVE.L      cb.SUPERVISION.openWinds(A2),D1
    MOVE.L      D1,-(A7)                ; alte Liste auf den Stack
    CMP.W       #31,D0
    BHI         noSuper                 ; springe, falls 'handle' zu groû
    BSET        D0,D1                   ; fÅge neues handle ein
    MOVE.L      D1,cb.SUPERVISION.openWinds(A2)
noSuper

    MOVE.W      D0,-(A1)
    MOVE.W      #WIND_OPEN,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
    MOVE.L      our_cb,A0
    
    MOVE.L      (A7)+,D1                ; Hole alte Liste vom Stack
    TST.W       error
    BEQ         noSuper2                ; falls Fehler aufgetretten ist,...
    MOVE.L      our_cb,A0               ; alte Liste -> aktuelle Liste
    MOVE.L      D1,cb.SUPERVISION.openWinds(A0)
noSuper2
  END;
END OpenWindow;

PROCEDURE CloseWindow(handle:CARDINAL);

BEGIN
  ASSEMBLER
        JMP     closeWindow
  END;
END CloseWindow;

PROCEDURE DeleteWindow(handle:CARDINAL);

BEGIN
  ASSEMBLER
        JMP     deleteWindow
  END;
END DeleteWindow;

  (* Aufteilung von 'wind_get' *)

PROCEDURE WindowSize(handle:CARDINAL;typ:WSizeMode):Rectangle;
                   
BEGIN
  ASSEMBLER
    MOVE.L      pubs,A1
    LEA         pubArrays.aINTIN+$4(A1),A1
    MOVE.W      -(A3),D0
    ADDQ.W      #4,D0           ; passe AufzÑhl.typ an wi_gfield an
    MOVE.W      D0,-(A1)
    MOVE.W      -(A3),-(A1)
    MOVE.W      #WIND_GET,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
    MOVE.L      pubs,A0
    LEA         pubArrays.aINTOUT+2(A0),A0
    MOVE.L      (A0)+,(A3)+
    MOVE.L      (A0)+,(A3)+
  END;
END WindowSize;
                   
PROCEDURE WindowSliderValue(handle:CARDINAL;typ:WSliderMode):INTEGER;
                     
BEGIN
  ASSEMBLER
    MOVE.L      pubs,A1
    LEA         pubArrays.aINTIN+$4(A1),A1
    MOVE.W      -(A3),D0
    ADDQ.W      #8,D0           ; erste Korrektur fÅr wi_gfield
    CMP.W       #$A,D0
    BLT         cont
    ADDQ.W      #5,D0           ; und eventuell eine zweite
cont
    MOVE.W      D0,-(A1)
    MOVE.W      -(A3),-(A1)
    MOVE.W      #WIND_GET,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
    MOVE.L      pubs,A0
    MOVE.W      pubArrays.aINTOUT+2(A0),(A3)+
  END;
END WindowSliderValue;
                     
PROCEDURE TopWindow():CARDINAL;

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.W      #$A,pubArrays.aINTIN+2(A0) ; wi_gField=10
    MOVE.W      #WIND_GET,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
    MOVE.L      pubs,A0
    MOVE.W      pubArrays.aINTOUT+2(A0),(A3)+
  END;
END TopWindow;

PROCEDURE WindowRectList(handle:CARDINAL;typ:RListMode):Rectangle;
                       
BEGIN
  ASSEMBLER
    ADDQ.W      #7,-2(A3) ; korrigiere AufzÑhl.typ fÅr wi_gfield
    JSR         WindowSize
  END;
END WindowRectList;

PROCEDURE ScreenBuffer(handle:CARDINAL):MemArea;

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.W      -(A3),pubArrays.aINTIN(A0)
    MOVE.W      #17,pubArrays.aINTIN+2(A0) ; wi_gField=17
    MOVE.W      #WIND_GET,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
    MOVE.L      pubs,A0
    MOVE.L      pubArrays.aINTOUT+2(A0),D0
    MOVE.L      D0,(A3)+
    MOVE.L      pubArrays.aINTOUT+6(A0),D0
    MOVE.L      D0,(A3)+
  END;
END ScreenBuffer;


  (* Aufteilung von 'wind_set' *)

PROCEDURE SetWindowString(handle:CARDINAL;typ:WStringMode;str:PtrMaxStr);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    LEA         pubArrays.aINTIN+8(A0),A0
    MOVE.L      -(A3),-(A0)
    MOVE.W      -(A3),D0
    ADDQ.W      #2,D0           ; AufzÑhl.typ auf wi_sfield korrigieren
    MOVE.W      D0,-(A0)
    MOVE.W      -(A3),-(A0)
    MOVE.W      #WIND_SET,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
  END;
END SetWindowString;

PROCEDURE SetWindowSize(handle:CARDINAL;frame:Rectangle);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    LEA         pubArrays.aINTIN+$C(A0),A0
    MOVE.L      -(A3),-(A0)
    MOVE.L      -(A3),-(A0)
    MOVE.W      #5,-(A0)        ; wi_sfield = 5
    MOVE.W      -(A3),-(A0)
    MOVE.W      #WIND_SET,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
  END;
END SetWindowSize;

PROCEDURE SetWindowSlider(handle:CARDINAL;typ:WSliderMode;value:INTEGER);
                     
BEGIN
  ASSEMBLER
    MOVE.L      pubs,A1
    LEA         pubArrays.aINTIN+$6(A1),A1
    MOVE.W      -(A3),-(A1)
    MOVE.W      -(A3),D0
    ADDQ.W      #8,D0           ; erste Korrektur fÅr wi_gfield
    CMP.W       #$A,D0
    BLT         cont
    ADDQ.W      #5,D0           ; und eventuell eine zweite
cont
    MOVE.W      D0,-(A1)
    MOVE.W      -(A3),-(A1)
    MOVE.W      #WIND_SET,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
  END;
END SetWindowSlider;

PROCEDURE SetTopWindow(handle:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    LEA         pubArrays.aINTIN+4(A0),A0
    MOVE.W      #$A,-(A0)               ; wi_gField = 10
    MOVE.W      -(A3),-(A0)
    MOVE.W      #WIND_SET,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
  END;
END SetTopWindow;

PROCEDURE SetNewDesk(objaddr:PtrObjTree;first:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    LEA         pubArrays.aINTIN+$A(A0),A0
    MOVE.W      -(A3),-(A0)
    MOVE.L      -(A3),-(A0)
    MOVE.W      #$E,-(A0)        ; wi_sfield = 14
    MOVE.W      #WIND_SET,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
  END;
END SetNewDesk;

PROCEDURE FindWindow (mouseLoc:Point) :CARDINAL;

BEGIN
  ASSEMBLER
        MOVE.L  pubs,A0
        MOVE.L  -(A3),pubArrays.aINTIN(A0)
        MOVE.W  #WIND_FIND,(A3)+
        JSR     aes_if
        MOVE.L  pubs,A0
        MOVE.W  pubArrays.aINTOUT(A0),(A3)+
  END;
END FindWindow;

PROCEDURE MouseControl(user:BOOLEAN);

BEGIN
  ASSEMBLER
    ADDQ.W      #2,-2(A3)    ; correct wi_ubegend
    JMP         updateWindow    ; Eigentliche Routine anspringen
  END;
END MouseControl;

PROCEDURE UpdateWindow(update:BOOLEAN);

BEGIN
  ASSEMBLER
    JMP         updateWindow            ; Rufe eigentliche Routine auf
  END;
END UpdateWindow;

PROCEDURE CalcWindow(typ:WCalcMode;kind:WElementSet;in:Rectangle):Rectangle;

  BEGIN
    ASSEMBLER
        MOVE.L  pubs,A0
        LEA     pubArrays.aINTIN+$C(A0),A0
        MOVE.L  -(A3),-(A0)
        MOVE.L  -(A3),-(A0)
        MOVE.W  -(A3), -(A0)
        MOVE.W  -(A3),-(A0)
        MOVE.W  #WIND_CALC,(A3)+
        JSR     aes_if
        MOVE.L  pubs,A0
        LEA     pubArrays.aINTOUT+$2(A0),A0
        MOVE.L  (A0)+,(A3)+
        MOVE.L  (A0)+,(A3)+
        JMP     testINTOUT0
    END;
  END CalcWindow;

PROCEDURE ResetWindows ();

  BEGIN
    ASSEMBLER
        MOVE.L  our_cb, A0
        CLR.W   cb.SUPERVISION.noMouseCtrl(A0)
        CLR.W   cb.SUPERVISION.noUpWind(A0)
        CLR.L   cb.SUPERVISION.createWinds(A0)
        CLR.L   cb.SUPERVISION.openWinds(A0)
        MOVE.W  #WIND_NEW, (A3)+
        JMP     aes_if
    END;
  END ResetWindows;
  

END AESWindows.
