IMPLEMENTATION MODULE VDIInputs;
(*$L-, N+, Y+*)


(*  MEGAMAX MODULA 2 GEM-Library :  Die VDI Eingabefunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  04.11.87
 *
 *  Version   2.2     V#0039
 *)
 
(*  04.11.87    | öbernahme aus 'GEMBase' und 'GEMExt'
 *  27.12.87    | Vector-Handler arbeiten im Usermode
 *                'setInputMode' arbeitet lokal zum aktuellen device
 *  14.6.88     | 'GetMouseState' behandelt das 'MButtonSet' mit .B
 *  01.02.90    | Anpassung auf Compiler V4.0 (verdrehte SET's)
 *  02.04.90    | Anpassung auf public arrays
 *  25.02.91 TT | "error"-Setzung Åber occured-Funktion
 *  15.09.91 MS | KeyboardState korrigiert
 *  14.07.93 TT | ButChg/MouseMove/Timer-IR-Routinen korrigiert (SSP wird nun
 *                ebenfalls gerettet/restauriert).
 *)
 
 
FROM    SYSTEM          IMPORT ASSEMBLER, WORD, LONGWORD;

FROM    MOSGlobals      IMPORT MemArea;
 
FROM    GrafBase        IMPORT Point, Rectangle, PtrMouseFormDef;

FROM    GEMGlobals      IMPORT GemChar, MButtonSet, SpecialKeySet;

IMPORT  GEMShare;
 
FROM    GEMEnv          IMPORT DeviceHandle;

(*$I GEMOPS.ICL *)
 
 
(*  setInputMode -- Legt das logische EingabegerÑt und dessen Eingabe-  *
 *                  modus fest. Der Aufruf wird nur ausgefÅhrt, wenn    *
 *                  die zu setzende Einstellung sich von der momentanen *
 *                  Einstellung unterscheidet. !! 'GemError' beachten!! *)

PROCEDURE setInputMode (handle:DeviceHandle; dev:logInpDev;mode:inputMode);

BEGIN
  ASSEMBLER
        MOVE.L  -8(A3),(A3)+
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     setDevice
        TST.W   -(A7)
        BNE     cont2
        SUBQ.L  #8,A3
        BRA     ende
        
cont2
        MOVE.W  -(A3),D0                ; 'mode' -> D0
        MOVE.W  -(A3),D2                ; 'dev' -> D2
        MOVE.W  D2,D1
        ADD.W   D1,D1
        MOVE.L  -4(A3),A0
        LEA     device.curInpMode(A0),A0
        ADDA.W  D1,A0
        CMP.W   (A0),D0                 ; handle^.curInpMode [dev] = mode
        BEQ     cont                    ; branch if equal
        
        MOVE.W  D0,-(A7)                ; FÅr spÑteren Test
        MOVE.L  A0,-(A7)
        
        MOVE.L  pubs,A0
        MOVE.W  D1,pubArrays.vINTIN(A0)
        MOVE.W  D0,pubArrays.vINTIN+2(A0)
        MOVE.W  D0,-(A7)
        MOVE.W  #SET_INPUT_MODE,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        
        MOVE.L  pubs,A0
        MOVE.W  pubArrays.vINTOUT(A0),D0
        MOVE.L  (A7)+,A0
        MOVE.W  D0,(A0)
        CMP.W   (A7)+,D0
        BEQ     ende
        JSR     gemErrorOccured
        BRA     ende
cont
        ADDQ.L  #6,A3
ende
  END;
END setInputMode;

PROCEDURE RequestLoc(handle:DeviceHandle; start:Point;
                     VAR termbut:CHAR;VAR loc:Point);

BEGIN
  ASSEMBLER
        MOVE.L  -16(A3),(A3)+
        MOVE.W  #location,(A3)+
        MOVE.W  #request,(A3)+
        JSR     setInputMode
        TST.W   error
        BNE     err
        
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  pubs,A0
        MOVE.L  -(A3),pubArrays.PTSIN(A0)
        MOVE.W  #INPUT_LOCATOR,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        MOVE.L  (A7)+,A1
        MOVE.L  pubs,A0
        MOVE.B  pubArrays.vINTOUT+1(A0),(A1)
        MOVE.L  (A7)+,A1                ; ADR(loc) -> A1
        MOVE.L  pubArrays.PTSOUT(A0),(A1)
        BRA     ende
        
err
        SUBA.W  #16,A3
ende
  END;
END RequestLoc;

PROCEDURE TestLoc(handle:DeviceHandle; start:Point;
                  VAR termbut:CHAR;VAR keyPress,koorChange:BOOLEAN;
                  VAR loc:Point);
                      
BEGIN
  ASSEMBLER
        MOVE.L  -24(A3),(A3)+
        MOVE.W  #location,(A3)+
        MOVE.W  #sample,(A3)+
        JSR     setInputMode
        TST.W   error
        BNE     err
        
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  pubs,A0
        MOVE.L  -(A3),pubArrays.PTSIN(A0)
        MOVE.W  #INPUT_LOCATOR,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        MOVE.L  (A7)+,A1                ; ADR(termbut) -> A1
        MOVE.L  our_cb,A0               ; our_cb -> A0
        TST.W   cb.V_CONTRL.sintout(A0)
        BEQ     noKey                   ; branch if no key pressed
        MOVE.L  pubs, A0
        MOVE.B  pubArrays.vINTOUT+1(A0),(A1)
        MOVE.L  (A7)+,A1
        MOVE.W  #TRUE,(A1)
        BRA     cont1
noKey
        CLR.B   (A1)
        MOVE.L  (A7)+,A1
        CLR.W   (A1)
cont1
        MOVE.L  (A7)+,A1
        MOVE.L  our_cb,A0               ; our_cb -> A0
        TST.W   cb.V_CONTRL.sptsout(A0)
        BEQ     noPnt
        MOVE.L  (A7)+,A2                ; ADR(loc) -> A2
        MOVE.L  pubs, A0
        MOVE.L  pubArrays.PTSOUT(A0),(A2)
        MOVE.W  #TRUE,(A1)
        BRA     ende
noPnt
        MOVE.L  pubArrays.PTSIN(A0),(A2)
        CLR.W   (A1)
        BRA     ende
        
err
        SUBA.W  #24,A3
ende
  END;
END TestLoc;
                      
PROCEDURE RequestValue(handle:DeviceHandle; start:CARDINAL;
                       VAR termbut:CHAR;VAR value:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.L  -14(A3),(A3)+
        MOVE.W  #value,(A3)+
        MOVE.W  #request,(A3)+
        JSR     setInputMode
        TST.W   error
        BNE     ende
        
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  pubs,A0
        MOVE.W  -(A3),pubArrays.vINTIN(A0)
        MOVE.W  #INPUT_VALUATOR,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        MOVE.L  (A7)+,A1
        MOVE.L  pubs,A0
        MOVE.W  pubArrays.vINTOUT+2(A0),(A1)
        MOVE.L  (A7)+,A1
        MOVE.W  pubArrays.vINTOUT(A0),(A1)
        BRA     ende
        
err
        SUBA.W  #14,A3
ende
  END;
END RequestValue;

PROCEDURE TestValue (handle:DeviceHandle; start:CARDINAL;
                     VAR termbut:CHAR; VAR status:TValState;
                     VAR value:CARDINAL);
                   
BEGIN
  ASSEMBLER
        MOVE.L  -18(A3),(A3)+
        MOVE.W  #value,(A3)+
        MOVE.W  #sample,(A3)+
        JSR     setInputMode
        TST.W   error
        BNE     ende
        
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  pubs,A0
        MOVE.W  -(A3),pubArrays.vINTIN(A0)
        MOVE.W  #INPUT_VALUATOR,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        MOVE.L  (A7)+,A1
        MOVE.L  our_cb,A0
        MOVE.W  cb.V_CONTRL.sintout(A0),D0
        MOVE.W  D0,(A1)
        MOVE.L  (A7)+,A1
        TST.W   D0
        BNE     aAction
        CLR.W   (A1)
        MOVE.L  (A7)+,A2
        MOVE.L  pubs,A0
        MOVE.W  pubArrays.vINTIN(A0),(A2)
        BRA     ende
aAction
        MOVE.W  pubArrays.vINTOUT(A0),(A2)
        CMP.W   #1,D0
        BNE     both
        CLR.W   (A1)
        BRA     ende
both
        MOVE.W  pubArrays.vINTOUT+2(A0),(A1)
        BRA     ende
        
err
        SUBA.W  #18,A3
ende
  END;
END TestValue;
                   
PROCEDURE RequestChoice(handle:DeviceHandle;start:CARDINAL;VAR choice:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.L  -10(A3),(A3)+
        MOVE.W  #choice,(A3)+
        MOVE.W  #request,(A3)+
        JSR     setInputMode
        TST.W   error
        BNE     ende
        
        MOVE.L  -(A3),-(A7)
        MOVE.L  pubs,A0
        MOVE.W  -(A3),pubArrays.vINTIN(A0)
        
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     setDevice
        TST.W   (A7)+
        BEQ     ende
        
        MOVE.L  our_cb,A0
        MOVE.W  #INPUT_CHOICE,cb.V_CONTRL.opcode(A0)
        CLR.W   cb.V_CONTRL.sptsin(A0)
        MOVE.W  #1,cb.V_CONTRL.sintin(A0)
        MOVE.L  cb.CURDEVICE(A0),A1
        MOVE.W  device.handle(A1),cb.V_CONTRL.handle(A0)
        MOVE.L  A0,(A3)+
        JSR     vdi_call
        MOVE.L  pubs,A0
        MOVE.L  (A7)+,A1
        MOVE.W  pubArrays.vINTOUT(A0),(A1)
        BRA     ende
        
err
        SUBA.W  #10,A3
ende
  END;
END RequestChoice;

PROCEDURE TestChoice(handle:DeviceHandle;
                     VAR keyPress:BOOLEAN;VAR choice:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.L  -12(A3),(A3)+
        MOVE.W  #choice,(A3)+
        MOVE.W  #sample,(A3)+
        JSR     setInputMode
        TST.W   error
        BNE     err
        
        MOVE.L    -(A3),-(A7)
        MOVE.L    -(A3),-(A7)
        
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     setDevice
        TST.W   (A7)+
        BEQ     err2
        
        MOVE.L  our_cb,A0
        MOVE.W  #INPUT_CHOICE,cb.V_CONTRL.opcode(A0)
        CLR.W   cb.V_CONTRL.sptsin(A0)
        MOVE.W  #1,cb.V_CONTRL.sintin(A0)
        MOVE.L  cb.CURDEVICE(A0),A1
        MOVE.W  device.handle(A1),cb.V_CONTRL.handle(A0)
        MOVE.L  A0,(A3)+
        JSR     vdi_call
        MOVE.L  (A7)+,A1
        MOVE.L  our_cb,A0
        MOVE.W  cb.V_CONTRL.sintout(A0),D0
        MOVE.W  D0,(A1)
        MOVE.L  (A7)+,A1
        BEQ     noKey
        MOVE.L  pubs,A0
        MOVE.W  pubArrays.vINTOUT(A0),(A1)
        BRA     ende
noKey
        CLR.W   (A1)
        BRA     ende
        
err
        SUBA.W  #12,A3
        BRA     ende
err2
        ADDQ.L  #4,A7
ende
  END;
END TestChoice;


PROCEDURE RequestString(handle:DeviceHandle;
                        VAR str:ARRAY OF CHAR; echo:BOOLEAN;echoLoc:Point);

END RequestString;

PROCEDURE TestString(handle:DeviceHandle;
                     VAR str:ARRAY OF CHAR; echo:BOOLEAN;echoLoc:Point;
                     VAR success:BOOLEAN);

END TestString;

PROCEDURE RStringCode(handle:DeviceHandle;
                      VAR str:ARRAY OF GemChar; echo:BOOLEAN;echoLoc:Point);

END RStringCode;

PROCEDURE TStringCode(handle:DeviceHandle;
                      VAR str:ARRAY OF GemChar; echo:BOOLEAN;echoLoc:Point;
                      VAR success:BOOLEAN);
                      
END TStringCode;


PROCEDURE SetMouseForm(handle:DeviceHandle; newForm:PtrMouseFormDef);

BEGIN
  ASSEMBLER
    MOVE.L      our_cb,A0
    MOVE.L      cb.VDIPB.intin(A0),-(A7)
    MOVE.L      -(A3),cb.VDIPB.intin(A0)
    MOVE.W      #SET_MOUSE_FORM,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
    MOVE.L      our_cb,A0
    MOVE.L      (A7)+,cb.VDIPB.intin(A0)
  END;
END SetMouseForm;

PROCEDURE ShowCursor(handle:DeviceHandle;force:BOOLEAN);

BEGIN
  ASSEMBLER
        JMP     showCursor      ; Eigentliche Routine anspringen
  END;
END ShowCursor;

PROCEDURE HideCursor(handle:DeviceHandle);

BEGIN
  ASSEMBLER
        JMP     hideCursor
  END;
END HideCursor;

PROCEDURE GetMouseState(    handle  : DeviceHandle;
                        VAR position: Point;
                        VAR buts    : MButtonSet);

BEGIN
  ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.W  #MOUSE_BUTTONS,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        MOVE.L  pubs,A0
        MOVE.L  (A7)+,A1
        MOVE.L  pubArrays.PTSOUT(A0),(A1)
        MOVE.W  pubArrays.vINTOUT(A0),D0
        MOVE.L  (A7)+,A1
        MOVE.B  D0,(A1)
  END;
END GetMouseState;


PROCEDURE KeyboardState (handle: DeviceHandle): SpecialKeySet;

BEGIN
  ASSEMBLER
        MOVE.W  #KEY_STATE,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        MOVE.L  pubs,A0
        MOVE.B  pubArrays.vINTOUT+1(A0),(A3)+    (* !MS *)
        ADDQ.L  #1, A3
  END;
END KeyboardState;


TYPE    regSaveArea     = ARRAY[0..16] OF LONGWORD;
                         
VAR     timerSArea,butChgSArea,msMoveSArea,curChgSArea  : regSaveArea;
        locTemp,locTemp2                                : Point;
        butsTemp                                        : MButtonSet;
        
(*  timerIRHandler -- Wird vom GEM bei jedem Timerinterrupt angesprungen, *
 *                    falls sich eine Userroutine Åber 'SetTimerVector'   *
 *                    angemeldet hat. Bei jedem Aufruf springt 'timerIR-  *
 *                    Handler' die Elemente der TimerVecList der Reihen-  *
 *                    folge entsprechend, beim Listenanfang beginnend an, *
 *                    bis eine Procedur FALSE als RÅckgabe liefert ,oder  *
 *                    das Listenende erreicht ist.                        *)

PROCEDURE timerIRHandler;

BEGIN
  ASSEMBLER
        MOVE.L  A0,timerSArea
        LEA     timerSArea,A0
        ADDA.W  #68,A0
        MOVEM.L D0-D7/A1-A7,-(A0)
        MOVE.L  USP,A1
        MOVE.L  A1,-(A0)                ; rette USP
        ANDI    #-1-$2000,SR            ; Usermode
        MOVE.L  timerVecList,A0
loop
        CMPA.L  #NIL,A0
        BEQ     callOld                 ; if list end, then call orig. Vec.
        MOVE.L  vecListElem.wsp.bottom(A0),A3
        MOVE.L  A3,A7
        ADDA.L  vecListElem.wsp.length(A0),A7
        MOVE.L  A0,-(A7)                ; Listenzeiger und alten Stack retten
        MOVE.L  vecListElem.newVec(A0),A0
        JSR     (A0)
        MOVE.L  (A7)+,A0                ; Listenzeiger wieder herstellen
        TST.W   -(A3)
        BEQ     ready                   ; RÅckgabe von FALSE => fertig!
        MOVE.L  vecListElem.next(A0),A0 ; nÑchstes Listenelem.
        BRA     loop
callOld                                 ; A3 und A7 enthalten noch letzten wsp!
        ; ZurÅck in Supervisormode
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6, A7
        
        LEA     timerSArea,A0
        ADDQ.L  #4,A0
        MOVE.L  (A0)+,A1
        MOVE.L  A1,USP                  ; stelle USP wieder her
        MOVEM.L (A0)+,D0-D7/A1-A7       ; Stelle Regs wieder her
        MOVE.L  timerSArea,A0
        MOVE.L  orgTimerVec,-(A7)       ; Sprungaddresse auf den Stack
        RTS
ready                                   ; A3 und A7 enthalten noch letzten wsp!
        ; ZurÅck in Supervisormode
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6, A7
        
        LEA     timerSArea,A0
        ADDQ.L  #4,A0
        MOVE.L  (A0)+,A1
        MOVE.L  A1,USP                  ; stelle USP wieder her
        MOVEM.L (A0)+,D0-D7/A1-A7       ; Stelle Regs wieder her
        MOVE.L  timerSArea,A0
  END;
END timerIRHandler;

(*  butChgIRHandler -- siehe 'timerIRHandler' *)

PROCEDURE butChgIRHandler;

BEGIN
  ASSEMBLER
        MOVE.L  A0,butChgSArea
        LEA     butChgSArea,A0
        ADDA.W  #68,A0
        MOVEM.L D0-D7/A1-A7,-(A0)
        MOVE.L  USP,A1
        MOVE.L  A1,-(A0)                ; rette USP
        ANDI    #-1-$2000,SR            ; Usermode
        MOVE.L  butChgVecList,A0
        MOVE.B  D0,butsTemp             ; speichere Buttonzustand(fÅr VAR)
loop
        CMPA.L  #NIL,A0
        BEQ     callOld                 ; if list end, then call orig. Vec.
        MOVE.L  vecListElem.wsp.bottom(A0),A3
        MOVE.L  A3,A7
        ADDA.L  vecListElem.wsp.length(A0),A7
        MOVEM.L D0/A0-A1,-(A7)          ; Listenzeiger und alten Stack retten
        MOVE.L  vecListElem.newVec(A0),A0
        MOVE.L  #butsTemp,(A3)+         ; öbergib 'VAR MButtonSet'
        JSR     (A0)
        MOVEM.L (A7)+,D0/A0-A1          ; Listenzeiger wieder herstellen
        TST.W   -(A3)
        BEQ     ready                   ; RÅckgabe von FALSE => fertig!
        MOVE.L  vecListElem.next(A0),A0 ; nÑchstes Listenelem.
        BRA     loop
callOld                                 ; A3 und A7 enthalten noch letzten wsp!
        ; ZurÅck in Supervisormode
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6, A7
        
        LEA     butChgSArea,A0
        ADDQ.L  #4,A0
        MOVE.L  (A0)+,A1
        MOVE.L  A1,USP                  ; stelle USP wieder her
        MOVEM.L (A0)+,D0-D7/A1-A7       ; Stelle Regs wieder her
        MOVE.L  butChgSArea,A0
        MOVE.B  butsTemp,D0
        MOVE.L  orgButChgVec,-(A7)      ; Sprungaddresse auf den Stack
        RTS
ready                                   ; A3 und A7 enthalten noch letzten wsp!
        ; ZurÅck in Supervisormode
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6, A7
        
        LEA     butChgSArea,A0
        ADDQ.L  #4,A0
        MOVE.L  (A0)+,A1
        MOVE.L  A1,USP                  ; stelle USP wieder her
        MOVEM.L (A0)+,D0-D7/A1-A7       ; Stelle Regs wieder her
        MOVE.L  butChgSArea,A0
        MOVE.B  butsTemp,D0
  END;
END butChgIRHandler;

(*  msMoveIRHandler -- siehe 'timerIRHandler' *)

PROCEDURE msMoveIRHandler;

BEGIN
  ASSEMBLER
        MOVE.L  A0,msMoveSArea
        LEA     msMoveSArea,A0
        ADDA.W  #68,A0
        MOVEM.L D0-D7/A1-A7,-(A0)
        MOVE.L  USP,A1
        MOVE.L  A1,-(A0)                ; rette USP
        ANDI    #-1-$2000,SR            ; Usermode
        MOVE.L  msMoveVecList,A0
        LEA     locTemp,A1              ; temporÑrer x/y-Speicher(fÅr VAR)
        MOVE.W  D0,(A1)+
        MOVE.W  D1,(A1)
loop
        CMPA.L  #NIL,A0
        BEQ     callOld                 ; if list end, then call orig. Vec.
        MOVE.L  vecListElem.wsp.bottom(A0),A3
        MOVE.L  A3,A7
        ADDA.L  vecListElem.wsp.length(A0),A7
        MOVEM.L A0/A1,-(A7)             ; Listenzeiger und alten Stack retten
        MOVE.L  vecListElem.newVec(A0),A0
        MOVE.L  #locTemp,(A3)+          ; öbergib 'VAR Point'
        JSR     (A0)
        MOVEM.L (A7)+,A0/A1             ; Listenzeiger wieder herstellen
        TST.W   -(A3)
        BEQ     ready                   ; RÅckgabe von FALSE => fertig!
        MOVE.L  vecListElem.next(A0),A0 ; nÑchstes Listenelem.
        BRA     loop
callOld                                 ; A3 und A7 enthalten noch letzten wsp!
        ; ZurÅck in Supervisormode
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6, A7
        
        LEA     msMoveSArea,A0
        ADDQ.L  #4,A0
        MOVE.L  (A0)+,A1
        MOVE.L  A1,USP                  ; stelle USP wieder her
        MOVEM.L (A0)+,D0-D7/A1-A7       ; Stelle Regs wieder her
        LEA     locTemp,A0
        MOVE.W  (A0)+,D0
        MOVE.W  (A0),D1
        MOVE.L  msMoveSArea,A0
        MOVE.L  orgMsMoveVec,-(A7)      ; Sprungaddresse auf den Stack
        RTS
ready                                   ; A3 und A7 enthalten noch letzten wsp!
        ; ZurÅck in Supervisormode
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6, A7
        
        LEA     msMoveSArea,A0
        ADDQ.L  #4,A0
        MOVE.L  (A0)+,A1
        MOVE.L  A1,USP                  ; stelle USP wieder her
        MOVEM.L (A0)+,D0-D7/A1-A7       ; Stelle Regs wieder her
        LEA     locTemp,A0
        MOVE.W  (A0)+,D0
        MOVE.W  (A0),D1
        MOVE.L  msMoveSArea,A0
  END;
END msMoveIRHandler;

(*  CurChgIRHandler -- siehe 'timerIRHandler' *)

PROCEDURE curChgIRHandler;

BEGIN
  ASSEMBLER
        MOVE.L  A0,curChgSArea
        LEA     curChgSArea,A0
        ADDA.W  #68,A0
        MOVEM.L D0-D7/A1-A7,-(A0)
        MOVE.L  USP,A1
        MOVE.L  A1,-(A0)                ; rette USP
        ANDI    #-1-$2000,SR            ; Usermode
        MOVE.L  curChgVecList,A0
        LEA     locTemp2,A1             ; temporÑrer x/y-Speicher(fÅr VAR)
        MOVE.W  D0,(A1)+
        MOVE.W  D1,(A1)
loop
        CMPA.L  #NIL,A0
        BEQ     callOld                 ; if list end, then call orig. Vec.
        MOVE.L  vecListElem.wsp.bottom(A0),A3
        MOVE.L  A3,A7
        ADDA.L  vecListElem.wsp.length(A0),A7
        MOVEM.L A0/A1,-(A7)             ; Listenzeiger und alten Stack retten
        MOVE.L  vecListElem.newVec(A0),A0
        MOVE.L  #locTemp2,(A3)+         ; öbergib 'VAR Point'
        JSR     (A0)
        MOVEM.L (A7)+,A0/A1             ; Listenzeiger wieder herstellen
        TST.W   -(A3)
        BEQ     ready                   ; RÅckgabe von FALSE => fertig!
        MOVE.L  vecListElem.next(A0),A0 ; nÑchstes Listenelem.
        BRA     loop
callOld                                 ; A3 und A7 enthalten noch letzten wsp!
        ; ZurÅck in Supervisormode
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6, A7
        
        LEA     curChgSArea,A0
        ADDQ.L  #4,A0
        MOVE.L  (A0)+,A1
        MOVE.L  A1,USP                  ; stelle USP wieder her
        MOVEM.L (A0)+,D0-D7/A1-A7       ; Stelle Regs wieder her
        LEA     locTemp2,A0             ; geÑnderte location Åbergeben
        MOVE.W  (A0)+,D0
        MOVE.W  (A0),D1
        MOVE.L  curChgSArea,A0
        MOVE.L  orgCurChgVec,-(A7)      ; Sprungaddresse auf den Stack
        RTS
ready                                   ; A3 und A7 enthalten noch letzten wsp!
        ; ZurÅck in Supervisormode
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6, A7
        
        LEA     curChgSArea,A0
        ADDQ.L  #4,A0
        MOVE.L  (A0)+,A1
        MOVE.L  A1,USP                  ; stelle USP wieder her
        MOVEM.L (A0)+,D0-D7/A1-A7       ; Stelle Regs wieder her
        LEA     locTemp2,A0             ; geÑnderte location Åbergeben
        MOVE.W  (A0)+,D0
        MOVE.W  (A0),D1
        MOVE.L  curChgSArea,A0
  END;
END curChgIRHandler;

PROCEDURE InstallTimerProc(VAR hdl:TimerVecCarrier;newVector:TimerVecProc;
                           wsp:MemArea;VAR deltaTime:CARDINAL);
                         
BEGIN
  ASSEMBLER
        MOVE.L  our_cb,A0
        
        LEA     cb.SUPERVISION(A0),A0
        TST.W   superData.timerChgd(A0)
        BNE     cont            ; bra, if not first timerVec in this level
        MOVE.W  #1,superData.timerChgd(A0)
        MOVE.L  timerVecList,superData.timerPrev(A0)
cont

        MOVE.L  timerVecList,D0 ; Hole Zeiger auf Listenanfang
        BNE     anotherVec      ; springe, falls schon Vec's vorhanden
        
                          ; Anmeldung beim VDI
        MOVE.L  #timerIRHandler,(A3)+
        MOVE.L  #deltaT,(A3)+
        JSR     exchangeTimerVec
        MOVE.L  -(A3),orgTimerVec
        
anotherVec                ; Userroutine einketten
        MOVE.L  -(A3),A0        ; Param. vom A3-Stack holen
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),D1
        MOVE.L  -(A3),D2
        MOVE.L  -(A3),A1
        MOVE.L  D1,vecListElem.wsp.bottom(A1)   ; save workspace
        MOVE.L  D0,vecListElem.wsp.length(A1)
        MOVE.L  D2,vecListElem.newVec(A1)       ; save 'newVector'
        MOVE.L  timerVecList,vecListElem.next(A1) ; einketten
        MOVE.L  A1,timerVecList
        MOVE.W  deltaT,(A0)                     ; Zeitabstand Åbergeben
  END;
END InstallTimerProc;

PROCEDURE RemoveTimerProc(VAR hdl:TimerVecCarrier);

BEGIN
  ASSEMBLER
        JMP     removeTimerVector
  END;
END RemoveTimerProc;

PROCEDURE InstallButChgProc(VAR hdl:ButChgVecCarrier;newVector:ButChgVecProc;
                            wsp:MemArea);

BEGIN
  ASSEMBLER
        MOVE.L  our_cb,A0
        
        LEA     cb.SUPERVISION(A0),A0
        TST.W   superData.butChgChgd(A0)
        BNE     cont            ; bra, if not first butChgVec in this level
        MOVE.W  #1,superData.butChgChgd(A0)
        MOVE.L  butChgVecList,superData.butChgPrev(A0)
cont

        MOVE.L  butChgVecList,D0 ; Hole Zeiger auf Listenanfang
        BNE     anotherVec       ; springe, falls schon Vec's vorhanden
        
                           ; Anmeldung beim VDI
        MOVE.W  #EX_BUT_CHANGE,(A3)+
        MOVE.L  #butChgIRHandler,(A3)+
        JSR     exchangeMouseVec        ; exchangeMV(EX_BUT_CHANGE,butChgIR..)
        MOVE.L  -(A3),orgButChgVec
        
anotherVec                 ; Userroutine einketten
        MOVE.L  -(A3),D0                ; Hole Param. vom Stack
        MOVE.L  -(A3),D1
        MOVE.L  -(A3),D2
        MOVE.L  -(A3),A1
        MOVE.L  D1,vecListElem.wsp.bottom(A1)   ; save workspace
        MOVE.L  D0,vecListElem.wsp.length(A1)
        MOVE.L  D2,vecListElem.newVec(A1)       ; save 'newVector'
        MOVE.L  butChgVecList,vecListElem.next(A1) ; einketten
        MOVE.L  A1,butChgVecList
  END;
END InstallButChgProc;

PROCEDURE RemoveButChgProc(VAR hdl:ButChgVecCarrier);

BEGIN
  ASSEMBLER
        JMP     removeButChgVector
  END;
END RemoveButChgProc;

PROCEDURE InstallMsMoveProc(VAR hdl:MsMoveVecCarrier;newVector:MsMoveVecProc;
                            wsp:MemArea);

BEGIN
  ASSEMBLER
        MOVE.L  our_cb,A0
        
        LEA     cb.SUPERVISION(A0),A0
        TST.W   superData.msMoveChgd(A0)
        BNE     cont            ; bra, if not first msMoveVec in this level
        MOVE.W  #1,superData.msMoveChgd(A0)
        MOVE.L  msMoveVecList,superData.msMovePrev(A0)
cont

        MOVE.L  msMoveVecList,D0 ; Hole Zeiger auf Listenanfang
        BNE     anotherVec       ; springe, falls schon Vec's vorhanden
                
                           ; Anmeldung beim VDI
        MOVE.W  #EX_MOUSE_MOVE,(A3)+
        MOVE.L  #msMoveIRHandler,(A3)+
        JSR     exchangeMouseVec
        MOVE.L  -(A3),orgMsMoveVec
        
anotherVec                 ; Userroutine einketten
        MOVE.L  -(A3),D0                ; Hole Param. vom Stack
        MOVE.L  -(A3),D1
        MOVE.L  -(A3),D2
        MOVE.L  -(A3),A1
        MOVE.L  D1,vecListElem.wsp.bottom(A1)   ; save workspace
        MOVE.L  D0,vecListElem.wsp.length(A1)
        MOVE.L  D2,vecListElem.newVec(A1)       ; save 'newVector'
        MOVE.L  msMoveVecList,vecListElem.next(A1) ; einketten
        MOVE.L  A1,msMoveVecList
  END;
END InstallMsMoveProc;

PROCEDURE RemoveMsMoveProc(VAR hdl:MsMoveVecCarrier);

BEGIN
  ASSEMBLER
        JMP     removeMsMoveVector
  END;
END RemoveMsMoveProc;

PROCEDURE InstallCurChgProc(VAR hdl:CurChgVecCarrier;newVector:CurChgVecProc;
                            wsp:MemArea);
                          
BEGIN
  ASSEMBLER
        MOVE.L  our_cb,A0
        
        LEA     cb.SUPERVISION(A0),A0
        TST.W   superData.curChgChgd(A0)
        BNE     cont            ; bra, if not first curChgVec in this level
        MOVE.W  #1,superData.curChgChgd(A0)
        MOVE.L  curChgVecList,superData.curChgPrev(A0)
cont

        MOVE.L  curChgVecList,D0 ; Hole Zeiger auf Listenanfang
        BNE     anotherVec       ; springe, falls schon Vec's vorhanden
                
                           ; Anmeldung beim VDI
        MOVE.W  #EX_MOUSE_CHANGE,(A3)+
        MOVE.L  #curChgIRHandler,(A3)+
        JSR     exchangeMouseVec
        MOVE.L  -(A3),orgCurChgVec
        
anotherVec                 ; Userroutine einketten
        MOVE.L  -(A3),D0                ; Hole Param. vom Stack
        MOVE.L  -(A3),D1
        MOVE.L  -(A3),D2
        MOVE.L  -(A3),A1
        MOVE.L  D1,vecListElem.wsp.bottom(A1)   ; save workspace
        MOVE.L  D0,vecListElem.wsp.length(A1)
        MOVE.L  D2,vecListElem.newVec(A1)       ; save 'newVector'
        MOVE.L  curChgVecList,vecListElem.next(A1) ; einketten
        MOVE.L  A1,curChgVecList
  END;
END InstallCurChgProc;

PROCEDURE RemoveCurChgProc(VAR hdl:CurChgVecCarrier);

BEGIN
  ASSEMBLER
        JMP     removeCurChgVector
  END;
END RemoveCurChgProc;


BEGIN
  timerVecList:=NIL; butChgVecList:=NIL;  (* Vektorlisten initialisieren *)
  msMoveVecList:=NIL; curChgVecList:=NIL;
END VDIInputs.