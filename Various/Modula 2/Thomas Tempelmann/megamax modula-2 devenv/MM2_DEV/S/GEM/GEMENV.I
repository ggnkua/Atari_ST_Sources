IMPLEMENTATION MODULE GEMEnv;
(*$Y+*)

(*
FROM Terminal IMPORT WriteString, WriteLn, Read; (*  FOR DEBUGGING ONLY  *)
FROM StrConv  IMPORT CardToStr;
*)


(*      Implementation der Megamax Modula-2 GEM Library (Enviroment)
 *
 *      geschrieben von Manuel Chakravarty
 *
 *      Version 2.2     V#0395      Erstellt MÑrz-Oktober 1987
 *)


(* TT  22.01.88: Parameter in 'GrafHandle' korrekt behandelt
 * TT  22.01.88: SysInit mit Level 0 statt -1
 *     02.06.88: Fehlermeldung bei Benutzung von 'SuspendedProcess'
 *     13.06.88: Optimierung in ASM (bis teilweise 'OpenDevice')
 *     27.06.88: Optimierung in ASM ('OpenDevice')
 *     21.07.88: Jetzt hoffentlich richtige Indexoffsetberechnung in
 *               'OpenDevice'
 *     27.06.89: Benutzt 'ResCtrl'.
 *     02.08.89: 'SuspendedProcess' raus
 *     11.08.89: Verschiebung wÑhrend dem Kopieren der GerÑteparameterliste
 *               korrigiert.
 *     20.08.89: 'GDOSAvailable' + 'GEMVersion' def. + impl. auûerdem
 *               Selektorgeschichte auf den 'SelectFileExtended' umgestellt.
 * TT  07.09.89: Kein extended FSel bei GEM V2;
 * TT  ????????: REF-Parm.
 *     01.02.90: 'errorProcPtr' wird im Body gesetzt.
 *     02.04.90: 'GEMAvailable' def. + impl.; Anpassung an public arrays
 * TT  26.06.90: FileSelect raus -> nun im PathEnv-Modul; InitGem init. PathEnv
 *               auch Doku zu InitGem im Def-Text erweitert!
 *               nur der durch InitGem zugewiesene SelectFile schaltet die Maus
 *               selbstst. ein! Bisher wurde das immer von SelectFile hier
 *               erledigt, egal, welche Routine angemeldet war - Mist?!
 * TT  21.11.90: GDOSAvailable drin und getestet; Nur noch ein globales
 *               appl_init und appl_exit pro Prozeû;
 *               Damit ModLoad auch nach Aufruf von "termProc" noch InitGem u.
 *               ExitGem tÑtigen kann, wird "modId" zu Beginn auf 2 statt 1
 *               gesetzt. So ist "modID"=1 nach "termProc", sodaû die OWNER_ID
 *               bei einem InitGem nicht Null ist (denn dan wÅrde ExitGem nix
 *               freigeben).
 *               'ErrorProc' ist nicht mehr HALT sondern ein neuer TRAP#6-Code;
 *               outOfMemory: LINK A5 statt A6; GEMAvailable angepaût;
 *               envelopeProc/ExitGem: 'error' wird immer auf FALSE gesetzt,
 *               damit dort nicht noch Fehler gemeldet werden.
 * TT  10.12.90: InitGem/Dev: ShellRead wird nur einmal pro Prozeû gemacht.
 * TT  12.12.90: InitDev: Bei TT-TOS wird auch extended-fileSelector verwendet;
 *               Envelopes: PathEnv.SelectFile wird vom Vater-Prozeû Åbernommen
 * TT  25.02.91: CloseDevice macht "unloadFonts", wenn nîtig.
 * TT  17.04.91: PathEnv.SelectFile wird sowohl bei InitGem als auch bei
 *               InitApplication gesetzt.
 * TT  10.07.93: Kein automatische Error-Meldung mehr bei GemErrors, damit
 *               keine Probleme mehr mit den vielen neuen GEM-Versionen.
 *
 *)

FROM    SYSTEM          IMPORT ASSEMBLER, ADDRESS, LONGWORD, WORD,
                               ADR;

FROM    Storage         IMPORT SysAlloc, DEALLOCATE;

FROM    MOSGlobals      IMPORT MemArea, IllegalPointer, GeneralErr, OutOfMemory,
                               GemErr, FileStr;

FROM    PrgCtrl         IMPORT EnvlpCarrier, TermCarrier,
                               Accessory, SetEnvelope, CatchProcessTerm;

FROM    ResCtrl         IMPORT RemovalCarrier,
                               CatchRemoval;

IMPORT  Directory, FileNames, PathEnv;

FROM    GEMGlobals      IMPORT TEffectSet;

IMPORT  GEMShare;

(* fÅr Tests:
  FROM SysTypes IMPORT ScanDesc;
  FROM SysCtrl IMPORT GetScanAddr;
  FROM GEMScan IMPORT InitChain, InputScan;
  VAR scanidx: CARDINAL; scan: ScanDesc;
*)


(*$I GEMOPS.ICL *)
(*$I GEMCNF.ICL *)


CONST   TestVersion     = FALSE; (*  Debugging?  *)

(*$? NOT TestVersion: (*$R-*)
 *)

TYPE    GemHandle       = p_cb;


VAR     noInits         : CARDINAL;  (*  ZÑhlt die Anzahl der '(Sys)InitGem's *)
        modID           : INTEGER;   (*  ZÑhlt die Ebenen angemeldeter Module
                                      *  (=0: SysEbene; >0: Mod.init.)
                                      *)
        gemStatus       : (unkown, available);
        
        voidI           : INTEGER;

        didShRead: ARRAY [-1..15] OF BOOLEAN; (* 'shellRead' durchgefÅhrt? *)
        appIsInit: ARRAY [-1..15] OF BOOLEAN; (* appIsInit[modID] zeigt an,
                                               * ob schon appl_init() auf-
                                               * gerugen wurde. *)


                (*  misc. internal proc.s  *)
                (*  =====================  *)

PROCEDURE outOfMemory;

  (*$L-*)
  BEGIN
    ASSEMBLER
        LINK    A5, #0
        TRAP    #noErrorTrap
        DC.W    OutOfMemory - $6000
        UNLK    A5
    END;
  END outOfMemory;
  (*$L=*)


                        (*  exported proc.s  *)
                        (*  ===============  *)

PROCEDURE GrafHandle (VAR charW,
                          charH,
                          cellW,
                          cellH: CARDINAL;
                      VAR hdl  : CARDINAL);

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.W      #GRAF_HANDLE,(A3)+
        JSR         aes_if
        MOVE.L      -(A3),A2
        MOVE.L      pubs,A0
        LEA         pubArrays.aINTOUT+$A(A0),A0
        MOVEQ       #$3,D0
    loop
        MOVE.L      -(A3),A1
        MOVE.W      -(A0),(A1)
        DBF         D0,loop
        MOVE.W      -(A0),(A2)      ; !TT 22.01.88
    END;
  END GrafHandle;
  (*$L=*)


(*$J-*)
PROCEDURE opnwrk0 (    opcode, handle  : CARDINAL;
                       device, koorSys : CARDINAL;
                   VAR param           : ARRAY OF INTEGER): CARDINAL;
(*$J=*)

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D1
        MOVE.L  -(A3),A1
        MOVE.L  pubs,A0
        MOVE.W  -(A3),pubArrays.vINTIN+20(A0)
        MOVE.W  -(A3),pubArrays.vINTIN(A0)
        CMP.W   #56,D1
        BCC     cont
        
        TRAP    #noErrorTrap
        DC.W    GeneralErr-$2000
        
cont
        LEA     pubArrays.vINTIN+2(A0),A2
        MOVEQ   #8,D0
loop
        MOVE.W  #1,(A2)+
        DBF     D0,loop
        
        MOVE.L  our_cb, A0
        MOVE.W  -(A3),cb.V_CONTRL.handle(A0)
        
        MOVE.L  cb.VDIPB.intout(A0),-(A7)
        MOVE.L  cb.VDIPB.ptsout(A0),-(A7)
        MOVE.L  A1,cb.VDIPB.intout(A0)
        LEA     90(A1),A1
        MOVE.L  A1,cb.VDIPB.ptsout(A0)
        
        MOVE.W  -(A3),D0
        CLR.L   (A3)+
        MOVE.W  D0,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        
        MOVE.L  our_cb,A0
        MOVE.L  (A7)+,cb.VDIPB.ptsout(A0)
        MOVE.L  (A7)+,cb.VDIPB.intout(A0)
        MOVE.W  cb.V_CONTRL.handle(A0),(A3)+
    END;
  END opnwrk0;
  (*$L=*)

(*$J-*)
PROCEDURE v_opnwk (    device,
                       koorSys: CARDINAL;
                   VAR param  : ARRAY OF INTEGER): CARDINAL;
(*$J=*)

(*

  VAR     oldpts,oldint           :ADDRESS;
          i                       :CARDINAL;
          
  (*$L+*)
  BEGIN
    IF HIGH(param)<56 THEN        (* Nicht genug Platz fÅr die Parameter *)
      ASSEMBLER
          TRAP    #noErrorTrap
          DC.W    GeneralErr-$2000      ; !TT 22.01.88
      END;
    END;
    our_cb^.V_CONTRL.handle:=0;
    WITH our_cb^ DO
      oldpts:=VDIPB.ptsout;
      oldint:=VDIPB.intout;
      VDIPB.intout:= ADR (param[0]);
      VDIPB.ptsout:= ADR (param[45]);
      vINTIN[0]:=device;
      FOR i:=1 TO 9 DO vINTIN[i]:=1 END;   (* Wird vom GEM ignoriert *)
      vINTIN[10]:=koorSys;
    END;
    vdi_if(NIL,V_OPNWK,0);
    WITH our_cb^ DO
      VDIPB.intout:=oldint;
      VDIPB.ptsout:=oldpts;
      RETURN V_CONTRL.handle
    END;
  END v_opnwk;
  (*$L=*)
 
 *)
 
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),D1
        MOVE.L  -(A3),D2
        
        MOVE.W  #V_OPNWK,(A3)+
        CLR.W   (A3)+
        MOVE.L  D2,(A3)+
        MOVE.L  D1,(A3)+
        MOVE.W  D0,(A3)+
        JSR     opnwrk0
    END;
  END v_opnwk;
  (*$L=*)

(*$J-*)
PROCEDURE v_opnvwk (    handle          : CARDINAL;
                        device, koorSys : CARDINAL;
                    VAR param           : ARRAY OF INTEGER): CARDINAL;
(*$J=*)

(*

  VAR     oldpts,oldint           :ADDRESS;
          i                       :CARDINAL;
          
  (*$L+*)
  BEGIN
    IF HIGH(param)<56 THEN        (* Nicht genug Platz fÅr die Parameter *)
      ASSEMBLER
          TRAP    #noErrorTrap
          DC.W    GeneralErr-$2000      ; !TT 22.01.88
      END;
    END;
    our_cb^.V_CONTRL.handle:=handle;
    WITH our_cb^ DO
      oldpts:=VDIPB.ptsout;
      oldint:=VDIPB.intout;
      VDIPB.intout:= ADR (param[0]);
      VDIPB.ptsout:= ADR (param[45]);
      vINTIN[0]:=device;
      FOR i:=1 TO 9 DO vINTIN[i]:=1 END;   (* Wird vom GEM ignoriert *)
      vINTIN[10]:=koorSys;
    END;
    vdi_if(NIL,OPEN_V_WORK,0);
    WITH our_cb^ DO
      VDIPB.intout:=oldint;
      VDIPB.ptsout:=oldpts;
      RETURN V_CONTRL.handle
    END;
  END v_opnvwk;
  (*$L=*)

 *)

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),D1
        MOVE.L  -(A3),D2
        
        MOVE.W  #OPEN_V_WORK,(A3)+
        MOVE.L  D2,(A3)+
        MOVE.L  D1,(A3)+
        MOVE.L  D0,(A3)+
        JSR     opnwrk0
    END;
  END v_opnvwk;
  (*$L=*)

PROCEDURE v_clswk (handle: DeviceHandle);

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.W  #V_CLSWK,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
     END;
  END v_clswk;
  (*$L=*)

PROCEDURE v_clsvwk (handle: DeviceHandle);

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.W  #CLOSE_V_WORK,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
     END;
  END v_clsvwk;
  (*$L=*)


TYPE    DeviceHandle    = p_device;

PROCEDURE extendedInquire (handle: DeviceHandle; VAR param: ARRAY OF INTEGER);

(*

  VAR     oldpts,oldint           :ADDRESS;
  
  (*$L+*)
  BEGIN
    IF HIGH(param)<56 THEN        (* Nicht genug Platz fÅr die Parameter *)
      ASSEMBLER
          TRAP    #noErrorTrap
          DC.W    GeneralErr-$2000      ; !TT 22.01.88
      END;
    END;
    WITH our_cb^ DO
      oldpts:=VDIPB.ptsout;
      oldint:=VDIPB.intout;
      VDIPB.intout:= ADR (param[0]);
      VDIPB.ptsout:= ADR (param[45]);
      vINTIN[0]:=1;                     (* Erfrage erweiterte Parameter *)
    END;
    vdi_if(handle,EXTENDED_INQUIRE,0);
    WITH our_cb^ DO
      VDIPB.intout:=oldint;
      VDIPB.ptsout:=oldpts;
    END;
  END extendedInquire;
  (*$L=*)

 *)

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D1
        MOVE.L  -(A3),A1
        MOVE.L  our_cb,A0
        CMP.W   #56,D1
        BCC     cont
        
        TRAP    #noErrorTrap
        DC.W    GeneralErr-$2000
        
cont
        MOVE.L  cb.VDIPB.intout(A0),-(A7)
        MOVE.L  cb.VDIPB.ptsout(A0),-(A7)
        MOVE.L  A1,cb.VDIPB.intout(A0)
        LEA     90(A1),A1
        MOVE.L  A1,cb.VDIPB.ptsout(A0)
        
        MOVE.L  pubs, A0
        MOVE.W  #1,pubArrays.vINTIN(A0)
        
        MOVE.W  #EXTENDED_INQUIRE,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        
        MOVE.L  our_cb,A0
        MOVE.L  (A7)+,cb.VDIPB.ptsout(A0)
        MOVE.L  (A7)+,cb.VDIPB.intout(A0)
    END;
  END extendedInquire;
  (*$L=*)
  

PROCEDURE OpenDevice (dev, sysKoor, newMode: CARDINAL; VAR hdl: DeviceHandle);

  CONST   maxParm         = 56;
  
  VAR     i               : INTEGER;
          current         : p_device;
          parameters      : ARRAY[0..maxParm] OF INTEGER;
          j               : PrivGDPFkt;
          success         : BOOLEAN;
          
  PROCEDURE appendDevice (VAR dev: p_device; VAR success: BOOLEAN);
  
    VAR   i       : logInpDev;
    
    BEGIN
      IF dev = NoDevice THEN
      
        SysAlloc (dev, SIZE (dev^));
        success := (dev # NIL);
        IF success THEN
        
           WITH dev^ DO
             noHdCurs := 0;
             next := NoDevice;
             magic := deviceMagic;
             fontsLoaded:= FALSE;
             FOR i := MIN (logInpDev) TO MAX (logInpDev) DO
               curInpMode[i] := noMode;
             END
           END;
           
        END;
        
      ELSE
        appendDevice (dev^.next, success);
      END;
    END appendDevice;
    
  
  PROCEDURE deleteLast(VAR dev: p_device);
  
    BEGIN
      IF dev^.next # NoDevice THEN dev^.magic := 0; DISPOSE (dev)
      ELSE deleteLast (dev^.next) END;
    END deleteLast;

  BEGIN
    WITH our_cb^ DO
    
      appendDevice (DEVICES, success);
      IF NOT success THEN hdl := NoDevice; RETURN END;
      current := DEVICES;
      WHILE current^.next # NoDevice DO current := current^.next END;
      WITH current^ DO
      
        params.charHeight := 0;
        params.charWidth  := 0;
        params.cellHeight := 0;
        params.cellWidth  := 0;
        mode := newMode;
        IF mode = NonVirtual THEN handle := v_opnwk (dev, sysKoor, parameters)
        ELSE handle := v_opnvwk (mode, dev, sysKoor, parameters) END;
        
      END;
      
    END;
    IF current^.handle = 0
    THEN
      deleteLast (our_cb^.DEVICES);
      hdl := NoDevice;
      RETURN
    ELSE
    
      ASSEMBLER
  (*
      our_cb^.CURDEVICE:=current;
      current^.params.rasterWidth:=parameters[0];
      current^.params.rasterHeight:=parameters[1];
      current^.params.pointWidth:=parameters[3];
      current^.params.pointHeight:=parameters[4];
      current^.params.fontSizes:=parameters[5];
      current^.params.lTypes:=parameters[6];
      current^.params.lWidths:=parameters[7];
      current^.params.mTypes:=parameters[8];
      current^.params.mSizes:=parameters[9];
      current^.params.fonts:=parameters[10];
      current^.params.fPatterns:=parameters[11];
      current^.params.fHatchings:=parameters[12];
      current^.params.noColors:=parameters[39];
      current^.params.minWChar:=parameters[45];
      current^.params.minHChar:=parameters[46];
      current^.params.maxWChar:=parameters[47];
      current^.params.maxHChar:=parameters[48];
      current^.params.minWRow:=parameters[49];
      current^.params.maxWRow:=parameters[51];
      current^.params.minWMark:=parameters[53];
      current^.params.minHMark:=parameters[54];
      current^.params.maxWMark:=parameters[55];
      current^.params.maxHMark:=parameters[56];
   *)
        MOVE.L  our_cb,A0
        MOVE.L  current(A6),A1
        MOVE.L  A1,cb.CURDEVICE(A0)
        
        LEA     parameters(A6),A0
        MOVE.W  (A0)+,p_device.params.rasterWidth(A1)
        MOVE.W  (A0)+,p_device.params.rasterHeight(A1)
        LEA     parameters+6(A6),A0
        MOVE.W  (A0)+,p_device.params.pointWidth(A1)
        MOVE.W  (A0)+,p_device.params.pointHeight(A1)
        MOVE.W  (A0)+,p_device.params.fontSizes(A1)
        MOVE.W  (A0)+,p_device.params.lTypes(A1)
        MOVE.W  (A0)+,p_device.params.lWidths(A1)
        MOVE.W  (A0)+,p_device.params.mTypes(A1)
        MOVE.W  (A0)+,p_device.params.mSizes(A1)
        MOVE.W  (A0)+,p_device.params.fonts(A1)
        MOVE.W  (A0)+,p_device.params.fPatterns(A1)
        MOVE.W  (A0)+,p_device.params.fHatchings(A1)
        
        MOVE.W  parameters+78(A6),p_device.params.noColors(A1)
        
        LEA     parameters+90(A6),A0
        MOVE.W  (A0)+,p_device.params.minWChar(A1)
        MOVE.W  (A0)+,p_device.params.minHChar(A1)
        MOVE.W  (A0)+,p_device.params.maxWChar(A1)
        MOVE.W  (A0)+,p_device.params.maxHChar(A1)
        MOVE.W  (A0)+,p_device.params.minWRow(A1)
        
        MOVE.W  parameters+102(A6),p_device.params.maxWRow(A1)
        
        LEA     parameters+106(A6),A0
        MOVE.W  (A0)+,p_device.params.minWMark(A1)
        MOVE.W  (A0)+,p_device.params.minHMark(A1)
        MOVE.W  (A0)+,p_device.params.maxWMark(A1)
        MOVE.W  (A0)+,p_device.params.maxHMark(A1)
(*
      FOR j:=barGDPPriv TO jTextGDPPriv DO
        current^.params.possibleGDPs[j]:=notAvaiblePriv;
      END;
      FOR i:=0 TO parameters[14]-1 DO
        current^.params.possibleGDPs[VAL(PrivGDPFkt,parameters[i+15]-1)]:=
           VAL(PrivGDPAttribute,parameters[i+25]);
      END;
 *)
        MOVE.W  #jTextGDPPriv,D0
        MOVE.W  #notAvaiblePriv,D1
        MOVE.L  current(A6),A0
        LEA     p_device.params.possibleGDPs(A0),A0
loop1
        MOVE.W  D1,(A0)+
        DBF     D0,loop1
        
        MOVE.W  parameters+28(A6),D0
        SUBQ.W  #1,D0
        MOVE.L  current(A6),A0
        LEA     p_device.params.possibleGDPs(A0),A0
loop2
        MOVE.W  D0,D1
        ADD.W   #15,D1
        ADD.W   D1,D1
        MOVE.W  parameters(A6,D1.W),D1
        ADD.W   D1,D1
        MOVE.W  D0,D2
        ADD.W   #25,D2
        ADD.W   D2,D2
        MOVE.W  parameters(A6,D2.W),-2(A0,D1.W)
        DBF     D0,loop2
    
(*
      current^.params.color:=(parameters[35]=1);
      current^.params.fill:=(parameters[37]=1);
      current^.params.cArray:=(parameters[38]=1);
      current^.params.grafCCtrl:=VAL(PrivInputDev,parameters[40]-1);
      current^.params.valueIn:=VAL(PrivInputDev,parameters[41]-1);
      current^.params.caseIn:=VAL(PrivInputDev,parameters[42]-1);
      current^.params.alphanumIn:=VAL(PrivInputDev,parameters[43]-1);
      current^.params.deviceType:=VAL(PrivDeviceType,parameters[44]);
 *)
        MOVE.L  current(A6),A1
        MOVE.W  parameters+70(A6),p_device.params.color(A1)
        MOVE.W  parameters+74(A6),p_device.params.fill(A1)
        MOVE.W  parameters+76(A6),p_device.params.cArray(A1)
        
        LEA     parameters+80(A6),A0
        MOVE.W  (A0)+,D0
        SUBQ.W  #1,D0
        MOVE.L  D0,p_device.params.grafCCtrl(A1)
        MOVE.W  (A0)+,D0
        SUBQ.W  #1,D0
        MOVE.L  D0,p_device.params.valueIn(A1)
        MOVE.W  (A0)+,D0
        SUBQ.W  #1,D0
        MOVE.L  D0,p_device.params.caseIn(A1)
        MOVE.W  (A0)+,D0
        SUBQ.W  #1,D0
        MOVE.L  D0,p_device.params.alphanumIn(A1)
        MOVE.W  (A0)+,p_device.params.deviceType(A1)
(*
      extendedInquire(current,parameters);  (* erweiterte Parameter *)
      current^.params.screen:=VAL(PrivScreenType,parameters[0]);
      current^.params.bgColors:=parameters[1];
      current^.params.useTEffects:=TEffectSet(SHORT(WORD(parameters[2])));
      current^.params.zooming:=(parameters[3]=1);
      current^.params.maxRasterPls:=parameters[4];
      current^.params.lookUpTab:=(parameters[5]=0);
      current^.params.op16PerSec:=parameters[6];
      current^.params.contFill:=(parameters[7]=1);
      current^.params.textRot:=VAL(PrivTextRotType,parameters[8]);
      current^.params.noWrtModes:=parameters[9];
      current^.params.maxInMode:=parameters[10];
      current^.params.textJust:=(parameters[11]=1);
      current^.params.penChange:=(parameters[12]=0);
      current^.params.colorRibbon:=(parameters[13]=0);
      current^.params.maxMarker:=parameters[14];
      IF intinMax <= parameters[15] THEN
        current^.params.maxStrLen:=intinMax (* Unser Array ist eben nicht grîûer*)
      ELSE
        current^.params.maxStrLen:=parameters[15]
      END;
      current^.params.noMButts:=parameters[16];
      current^.params.thickLnTyps:=(parameters[17]=1);
      current^.params.thickLnModes:=parameters[18];
   *)
        MOVE.L  current(A6),(A3)+
        LEA     parameters(A6),A0
        MOVE.L  A0,(A3)+
        MOVE.W  #maxParm,(A3)+
        JSR     extendedInquire
        
        LEA     parameters(A6),A0       ; 'ADR (parameters)' -> A0
        MOVE.L  current(A6),A1          ; 'current' -> A1
        
        MOVE.W  (A0)+,p_device.params.screen(A1)
        MOVE.W  (A0)+,p_device.params.bgColors(A1)
        MOVE.W  (A0)+,D0
        MOVE.B  D0,p_device.params.useTEffects(A1)
        MOVE.W  (A0)+,p_device.params.zooming(A1)
        MOVE.W  (A0)+,p_device.params.maxRasterPls(A1)
        MOVE.W  (A0)+,p_device.params.lookUpTab(A1)
        MOVE.W  (A0)+,p_device.params.op16PerSec(A1)
        MOVE.W  (A0)+,p_device.params.contFill(A1)
        MOVE.W  (A0)+,p_device.params.textRot(A1)
        MOVE.W  (A0)+,p_device.params.noWrtModes(A1)
        MOVE.W  (A0)+,p_device.params.maxInMode(A1)
        MOVE.W  (A0)+,p_device.params.textJust(A1)
        TST.W   (A0)+
        SEQ     D0
        AND.W   #1,D0
        MOVE.W  D0,p_device.params.penChange(A1)
        TST.W   (A0)+
        SEQ     D0
        AND.W   #1,D0
        MOVE.W  D0,p_device.params.colorRibbon(A1)
        MOVE.W  (A0)+,p_device.params.maxMarker(A1)
        
        MOVE.W  (A0)+,D0
        CMP.W   #intinMax,D0
        BCS     else1
        MOVE.W  #intinMax,p_device.params.maxStrLen(A1)
        BRA     endif1
else1
        MOVE.W  D0,p_device.params.maxStrLen(A1)
endif1

        MOVE.W  (A0)+,p_device.params.noMButts(A1)
        MOVE.W  (A0)+,p_device.params.thickLnTyps(A1)
        MOVE.W  (A0)+,p_device.params.thickLnModes(A1)
      END;
      
    END;
    hdl := current;
    
  END OpenDevice;

PROCEDURE CloseDevice (handle: DeviceHandle);

  VAR   current: p_device;
        success: BOOLEAN;
        
  PROCEDURE deleteDevice (VAR dev: p_device; toDelete: p_device);
  
    BEGIN
      IF dev = toDelete THEN
        dev := toDelete^.next;
        DISPOSE (toDelete);
      ELSE deleteDevice (dev^.next, toDelete) END
    END deleteDevice;

  BEGIN
    setDevice (handle, success);
    IF success THEN
      current := our_cb^.CURDEVICE;
      IF current^.fontsLoaded THEN
        unloadFonts (current, 0)
      END;
      IF current^.mode = NonVirtual THEN v_clswk (current)
      ELSE v_clsvwk (current) END;
      current^.magic := 0;
      deleteDevice (our_cb^.DEVICES, current);
    END;
  END CloseDevice;

PROCEDURE DeviceParameter (handle: DeviceHandle): PtrDevParm;

  VAR     success : BOOLEAN;
  
  BEGIN
    setDevice (handle, success);
    IF success THEN RETURN ADR (our_cb^.CURDEVICE^.params)
    ELSE RETURN NIL END;
  END DeviceParameter;


PROCEDURE GemActive (): BOOLEAN;

  (*$L-*)
  BEGIN
    ASSEMBLER
        CLR.W   D0              ; noInits=0 => FALSE
        TST.W   noInits
        SEQ     D0
        ADDQ.B  #1,D0
        MOVE.W  D0,(A3)+
    END;
  END GemActive;
  (*$L=*)

PROCEDURE GemError (): BOOLEAN;

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.W      error,(A3)+
        CLR.W       error
    END;
  END GemError;
  (*$L=*)

PROCEDURE ErrorNumber (): INTEGER;

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.W  errNum,(A3)+
    END;
  END ErrorNumber;
  (*$L=*)


FORWARD selectFileTOSDependent (REF label     : ARRAY OF CHAR;
                                VAR path, name: ARRAY OF CHAR;
                                VAR ok        : BOOLEAN);


PROCEDURE initGem (VAR success: BOOLEAN;
                       sys    : BOOLEAN);
  
  VAR   oldc                            : p_cb;
        virgin                          : BOOLEAN;      (*  Erster cb?  *)
  
  BEGIN
    
    success := FALSE;
    virgin := (root_cb = NIL);
    
    oldc := our_cb;                 (* Alte private Var's merken *)
    SysAlloc (our_cb, SIZE (our_cb^));
    IF our_cb = NIL                 (* Speicher voll => Abbruch *) THEN
      outOfMemory;
      our_cb := oldc;
      RETURN
    END;
    
    (*  Falls nîtig fordere die public arrays an.
     *)
    IF virgin THEN
    
      SysAlloc (pubs, SIZE (pubs^));
      IF pubs = NIL THEN
        outOfMemory;
        DEALLOCATE (our_cb, SIZE (our_cb^));
        our_cb := oldc;
        RETURN
      END;
      
    END;
    
    (*  Init neue private Vars *)
    
    WITH our_cb^ DO
    
      LASTCB := root_cb;     (*  Neuer 'cb' ist erster in der Liste  *)
      
     (*  Supervision-Parameter initialisieren
      *)
      WITH SUPERVISION DO
        noGrafMouse := 0;
        noUpWind := 0;
        noMouseCtrl := 0;
        openWinds := LONGWORD (0L);
        createWinds := LONGWORD (0L);
        timerChgd := FALSE;
        butChgChgd := FALSE;
        msMoveChgd := FALSE;
        curChgChgd := FALSE;
      END;
      
      A_CONTRL.saddrout := 0;
      
      (*  AES-/VDI-Paramterblîcke mit Array-Adresse init.
       *)
      AESPB.contrl  := ADR (A_CONTRL);
      AESPB.global  := ADR (GLOBAL);
      AESPB.intin   := ADR (pubs^.aINTIN);
      AESPB.intout  := ADR (pubs^.aINTOUT);
      AESPB.addrin  := ADR (pubs^.ADDRIN);
      AESPB.addrout := ADR (pubs^.ADDROUT);
      VDIPB.contrl  := ADR (V_CONTRL);
      VDIPB.ptsin   := ADR (pubs^.PTSIN);
      VDIPB.ptsout  := ADR (pubs^.PTSOUT);
      VDIPB.intin   := ADR (pubs^.vINTIN);
      VDIPB.intout  := ADR (pubs^.vINTOUT);
      
      (*  Anmeldung beim AES
       *)
      IF NOT appIsInit[modID] THEN
        GLOBAL.ap_version:= 0;
        aes_if (APPL_INIT);
        GLOBAL.ap_id := pubs^.aINTOUT[0];
        IF GLOBAL.ap_version # 0 THEN gemStatus := available END;
        IF (gemStatus # available) OR (GLOBAL.ap_id < 0)  (*  AES o.k.?  *) THEN
          IF virgin THEN DEALLOCATE (pubs, SIZE (pubs^)) END;
          DEALLOCATE (our_cb, SIZE (our_cb^));
          our_cb := oldc;
          RETURN
        END;
        PathEnv.SelectFile:= selectFileTOSDependent;
        DIDAPPLINIT:= TRUE;
        appIsInit[modID]:= TRUE;
        error:= FALSE;
      ELSE
        DIDAPPLINIT:= FALSE;
        GLOBAL:= root_cb^.GLOBAL
      END;
      
      (*  GerÑteliste := leere Liste
       *)
      DEVICES := NoDevice;
      CURDEVICE:=NoDevice;

    END;(*WITH*)
    
    (*
      GetScanAddr (scan); InitChain (scan);
      scanidx:= 1; InputScan ('InitGem', scanidx);
    *)
    
    (*
      saveSelector;                 (* Aktuelle File-Selektor-Box retten *)
    *)
    
    IF sys THEN
      our_cb^.OWNER_ID := -modID;   (* Merke ID des anmeldenden Moduls *)
    ELSE
      our_cb^.OWNER_ID := modID;    (* Merke ID des anmeldenden Moduls *)
    END;
    root_cb := our_cb;            (*  Neuer cb bildet Listenanfang
                                   *  Listenordnung: historisch
                                   *)
    our_cb^.MAGIC := cbMagic;
    INC (noInits);                (* Anzahl der Level-Init's erhîhen *)
    
    success := TRUE;              (* Neuer Level erfolgreich angemeldet! *)
  END initGem;

PROCEDURE InitApplication (VAR success: BOOLEAN);
  (*$L-*)
  BEGIN
    ASSEMBLER
        CLR.W   (A3)+
        JMP     initGem
    END
  END InitApplication;
  (*$L=*)

PROCEDURE SysInitApplication (VAR success: BOOLEAN);
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE    #TRUE,(A3)+
        JMP     initGem
    END
  END SysInitApplication;
  (*$L=*)

PROCEDURE ExitApplication;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  our_cb,-(A7)
        MOVE.L  A7,(A3)+        ; VAR-Parameter!
        JSR     ExitGem         ; ExitGem (CurrGemHandle())
        ADDQ.L  #4,A7
    END
  END ExitApplication;
  (*$L=*)


PROCEDURE initDev (    sysKoor: CARDINAL;
                   VAR handle : DeviceHandle;
                   VAR success: BOOLEAN;
                       sys    : BOOLEAN);

  CONST   screen  = 1;     (*  device = Bildschirm  *)

  VAR   oldc                            : p_cb;
        wrkStation                      : CARDINAL;
        charH, charW, cellW, cellH      : CARDINAL;
        virgin                          : BOOLEAN;      (*  Erster cb?  *)
        args                            : ARRAY[0..127] OF CHAR;
        name                            : FileStr;
  
  BEGIN
    virgin := (root_cb = NIL);
    oldc := our_cb;                 (* Alte private Vars merken *)
    initGem (success, sys);
    IF success THEN
      WITH our_cb^ DO
        
        (* StandardgerÑt (Screen) anmelden *)
        GrafHandle (charH, charW, cellH, cellW, wrkStation);
        OpenDevice (screen, sysKoor, wrkStation, handle);
        IF handle = NoDevice THEN
          IF virgin THEN DEALLOCATE (pubs, SIZE (pubs^)) END;
          DEALLOCATE (our_cb, SIZE (our_cb^));
          our_cb := oldc;
          success := FALSE;
          RETURN
        END;
          
        WITH DEVICES^.params DO
          charHeight:=charH;
          charWidth:=charW;
          cellHeight:=cellH;
          cellWidth:=cellH;
        END;
        CURDEVICE:=DEVICES;
        
      END;(*WITH*)

      (* PathEnv-Vars / File-Selektor-Box init. *)
      IF NOT didShRead[modID] THEN
        (* nur beim 1. Mal, da spÑter evtl. durch rsrc_load bei alten TOS-
         * Versionen der Shell-Puffer Åberschrieben wird! *)
        shellRead (name, args);
        FileNames.SplitPath (name, PathEnv.HomePath, name);
        IF PathEnv.HomePath [0] = 0C THEN
          Directory.GetDefaultPath (PathEnv.HomePath)
        END;
        didShRead[modID]:= TRUE
      END;
    END;
  END initDev;

PROCEDURE InitGem (    sysKoor: CARDINAL;
                   VAR handle : DeviceHandle;
                   VAR success: BOOLEAN);
  (*$L-*)
  BEGIN
  (*$? TestVersion:
    WriteString ("--'GemEnv.InitGem' invoked'--");
   *)
    ASSEMBLER
        CLR     (A3)+
        JMP     initDev
    END;
  END InitGem;
  (*$L=*)

PROCEDURE SysInitGem (    sysKoor: CARDINAL;
                      VAR handle : DeviceHandle;
                      VAR success: BOOLEAN);
  (*$L-*)
  BEGIN
  (*$? TestVersion:
    WriteString ("--'GemEnv.SysInitGem' invoked'--");
   *)
    ASSEMBLER
        MOVE    #TRUE,(A3)+
        JMP     initDev
    END;
  END SysInitGem;
  (*$L=*)

PROCEDURE closeDelWinds;

  (*$L-*)
  BEGIN
    (*$? doSupervision:
    ASSEMBLER
                                ; Schlieûe Fenster
        MOVE.L  our_cb,A0
        CLR.W   D0              ; Beginne bei Handle #0
        MOVE.L  cb.SUPERVISION.openWinds(A0),D1
loop1
        BCLR    D0,D1           ; Lîsche Handle-Bit
        BEQ     cont1           ; Springe, falls Handle nicht eingetrag.
        MOVE.W  D0,(A3)+
        MOVEM.L D0/D1/A0,-(A7)
        JSR     closeWindow     ; closeWindow(D0)
        MOVEM.L (A7)+,D0/D1/A0
cont1
        ADDQ.W  #1,D0           ; nÑchstes Handle
        TST.L   D1
        BNE     loop1           ; nochmal, falls ein Handle Åbrig
        
                                ; Lîsche Fenster
        CLR.W   D0              ; Beginne bei Handle #0
        MOVE.L  cb.SUPERVISION.createWinds(A0),D1
loop2
        BCLR    D0,D1           ; Lîsche Handle-Bit
        BEQ     cont2           ; Springe, falls Handle nicht eingetrag.
        MOVE.W  D0,(A3)+
        MOVEM.L D0/D1/A0,-(A7)
        JSR     deleteWindow    ; deleteWindow(D0)
        MOVEM.L (A7)+,D0/D1/A0
cont2
        ADDQ.W  #1,D0           ; nÑchstes Handle
        TST.L   D1
        BNE     loop2           ; nochmal, falls ein Handle Åbrig
    END;
    *)
  END closeDelWinds;
  (*$L=*)

(*$J-*)
PROCEDURE isValidGemHandle (handle: GemHandle): BOOLEAN;
(*$J=*)

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0        ; 'handle' -> D0
        ANDI.W  #-2,D0          ; nur gerade Addr. zulassen
        MOVE.L  D0,A0           ; 'handle' -> A0
        
        CMPA.L  #NIL,A0
        BNE     notNIL          ; jump, if curr. 'handle # NIL'
        MOVE.W  #FALSE,(A3)+    ; ERROR!
        BRA     ende
        
notNIL
        MOVE.W  cb.MAGIC(A0),D0
        CMP.W   #cbMagic,D0
        BEQ     validHandle     ; jump, if magic is valid
        TRAP    #noErrorTrap
        DC.W    IllegalPointer - $4000
        MOVE.W  #FALSE,(A3)+
        BRA     ende
        
validHandle
        MOVE.W  #TRUE,(A3)+
ende
    END;
  END isValidGemHandle;
  (*$L=*)


(*  mouseInput0 -- Ist 'start = TRUE', so werden alle mouse-hides des
 *                 aktuellen 'cb' rÅckgÑnig gemacht. Ist 'start = FALSE'
 *                 werden die mouse hides wieder durchgefÅhrt. Also
 *                 der alte Status wiederhergestellt.
 *)

PROCEDURE mouseInput0 (start:BOOLEAN);

  CONST   mouseOff        = 9;    (* Ordinalzahl des Modula-AufzÑhlungs- *)
          mouseOn         = 10;   (* typen 'MouseForm'                   *)
  
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVEM.L D4/D5/A4,-(A7)
        
        MOVE.W  -(A3),D4
        
        (*$? doSupervision:
        
        ;                       'GrafMouse' bearbeiten
        MOVE.L  our_cb,A0
        TST.W   D4
        BEQ     hideIt1
        MOVE.W  cb.SUPERVISION.noGrafMouse(A0),D5
        MOVE.W  D5,cb.SUPERVISION.oldGrafMouse(A0)
        BRA     loop1Start
hideIt1
        MOVE.W  cb.SUPERVISION.oldGrafMouse(A0),D5
        BRA     loop1Start
loop1
        MOVE.W  #mouseOff,D2
        TST.W   D4
        BEQ     hideIt2
        MOVE.W  #mouseOn,D2
hideIt2
        MOVE.W  D2,(A3)+
        CLR.L   (A3)+
        JSR     grafMouse
loop1Start
        DBF     D5,loop1
        
        ;                       'Hide-/ShowCursor' bearbeiten
        MOVE.L  our_cb,A0
        MOVE.L  cb.DEVICES(A0),A4
        BRA     loop3Start
        
loop3
        TST.W   D4
        BEQ     hideIt3
        MOVE.W  device.noHdCurs(A4),D5
        MOVE.W  D5,device.oldHdCurs(A4)
        BRA     loop2Start
hideIt3
        MOVE.W  device.oldHdCurs(A4),D5
        BRA     loop2Start
loop2
        MOVE.L  A4,(A3)+
        TST.W   D4
        BEQ     hideIt4
        MOVE    #FALSE,(A3)+
        JSR     showCursor
        BRA     c1
hideIt4
        JSR     hideCursor
c1
loop2Start
        DBF     D5,loop2
        MOVE.L  device.next(A4),A4
loop3Start
        MOVE.L  A4,D0
        BNE     loop3
        
        *)
        
        MOVEM.L (A7)+,D4/D5/A4
    END;
  END mouseInput0;
  (*$L=*)

(*  mouseInput -- Wie 'mouseInput0', nur fÅr alle mouse hides, die von
 *                dieser GEM-Bibliothek durchgefÅhrt wurden (alle 'cb's)
 *)

PROCEDURE mouseInput (start:BOOLEAN);

  VAR     oldHdl  : GemHandle;
  
  BEGIN
    (*$? doSupervision:
    ASSEMBLER
        MOVE.L  A4,-(A7)
        JSR     CurrGemHandle
        MOVE.L  -(A3),oldHdl(A6)
        
        MOVE.L  root_cb,A4
        BRA     loopStart
loop
        MOVE.L  A4,(A3)+
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     SetCurrGemHandle
        TST.W   (A7)+
        BEQ     errHdl
        MOVE.W  start(A6),(A3)+
        JSR     mouseInput0
errHdl
        MOVE.L  cb.LASTCB(A4),A4
loopStart
        MOVE.L  A4,D0
        BNE     loop
        
        MOVE.L  oldHdl(A6),(A3)+
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     SetCurrGemHandle
        TST.W   (A7)+
        MOVE.L  (A7)+,A4
    END;
    *)
  END mouseInput;

PROCEDURE exitGem (VAR handle: GemHandle; remove: BOOLEAN);

  PROCEDURE whipFromList (VAR list: p_cb; elem: p_cb);
  
    BEGIN
      IF list = elem THEN list := elem^.LASTCB
      ELSE whipFromList (list^.LASTCB, elem) END;
    END whipFromList;


  VAR   oldc    : p_cb;
        current : p_device;
        i       : CARDINAL;
  
  BEGIN
(*$? TestVersion:
  WriteString ("'ExitGem' invoked...");
 *)
    (*
      GetScanAddr (scan); InitChain (scan);
      scanidx:= 1; InputScan ('ExitGem', scanidx);
    *)
    
    IF isValidGemHandle (handle) THEN
    
      our_cb := handle;
      
      IF our_cb^.OWNER_ID # 0 THEN
      
      (*
        RemoveSelector;     (* Alte File-Selektor-Box wieder einhÑngen *)
       *)
        mouseInput (TRUE);  (* Alten Mausstatus wiederherstellen *)

                              (* VDI zurÅcksetzen *)

(*
$? TestVersion:
  WriteString ("reset VDI...");
 *)
         (*  'showCursor'-Aufrufe sind schon ausgefÅhrt worden
          *)
         (*$? doSupervision:
         WITH our_cb^.SUPERVISION DO    (* Melde alle GEM-IR-Vektoren ab *)
           WHILE timerChgd DO
             removeTimerVector (timerVecList^)
           END;
           WHILE butChgChgd DO
             removeButChgVector (butChgVecList^)
           END;
           WHILE msMoveChgd DO
             removeMsMoveVector (msMoveVecList^)
           END;
           WHILE curChgChgd DO
             removeCurChgVector (curChgVecList^)
           END;
         END;(*WITH*)
         *)

                        (* Devices abmelden *)

(*
$? TestVersion:
  WriteString ("deinstall devices...");
 *)
        WHILE our_cb^.DEVICES # NIL DO
          CloseDevice (our_cb^.DEVICES);
        END;

                      (* AES zurÅcksetzen und eventuell Obj. abmelden *)

(*
$? TestVersion:
  WriteString ("reset AES...");
 *)
        (*$? doSupervision:
        WITH our_cb^.SUPERVISION DO
          FOR i := 1 TO noUpWind DO updateWindow (FALSE) END;
          FOR i := 1 TO noMouseCtrl DO updateWindow (ORD (FALSE) + 2) END;
          closeDelWinds; (* Schlieûe und lîsche alle Fenster dieser Modulebene*)
        END;
        *)
        
        IF our_cb^.DIDAPPLINIT THEN
          aes_if (APPL_EXIT);
          our_cb^.DIDAPPLINIT:= FALSE;
          appIsInit[modID]:= FALSE;
          error:= FALSE
        END
      END;(*IF OWNER_ID # 0*)

                  (* Kette our_cb aus der cb-Liste aus *)

(*
$? TestVersion:
  WriteString ("delist 'cb'...");
 *)
      IF remove THEN
      
        oldc := our_cb^.LASTCB;
        whipFromList (root_cb, our_cb);
        our_cb^.MAGIC := 0;
        DEALLOCATE (our_cb, SIZE (our_cb^));
        our_cb := oldc; (* our_cb should point to the cb of the calling module*)
        DEC (noInits);
        handle := NIL;
        
      END;
      
    ELSE                  (* 'handle' is not valid *)
      gemErrorOccured
    END;
    
    (*  'our_cb' mustn't be 'NIL', if there is any 'cb' left.
     *)
    IF our_cb = NIL THEN our_cb := root_cb END;
    
    (*  Gib public arrays frei, falls letzter cb abgemeldet wurde.
     *)
    IF root_cb = NIL THEN DEALLOCATE (pubs, SIZE (pubs^)) END;
    
(*$? TestVersion:
  WriteString ("leave 'ExitGem'."); WriteLn;
 *)
  END exitGem;

PROCEDURE ExitGem (VAR handle: GemHandle);

  BEGIN
    testErrorCheck;
    exitGem (handle, TRUE);
  END ExitGem;
  
PROCEDURE CurrGemHandle (): GemHandle;

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  our_cb,(A3)+    ; RETURN our_cb
    END;
  END CurrGemHandle;
  (*$L=*)

PROCEDURE SetCurrGemHandle (handle:GemHandle; VAR success:BOOLEAN);
         
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -4(A3),-(A7)
        JSR     isValidGemHandle
        MOVE.L  (A7)+,A0        ; 'handle' -> A0
        MOVE.L  (A7)+,A1        ; ADR (success) -> A1
        MOVE.W  -(A3),(A1)
        BEQ     noValidHandle
        
        MOVE.L  A0,our_cb       ; is valid => set handle
        
noValidHandle
    END;
  END SetCurrGemHandle;
  (*$L=*)


                (* Die File-Selektor-Box-Option *)
                
(*
VAR     selector        : FileSelectProc;
         
PROCEDURE SetSelector (fsel: FileSelectProc);

  (*$L-*)
  BEGIN
    ASSEMBLER
        JSR     testErrorCheck
        MOVE.L  -(A3),selector
    END;
  END SetSelector;
  (*$L=*)

PROCEDURE RemoveSelector;

  (*$L-*)
  BEGIN
    ASSEMBLER
        JSR     testErrorCheck
        MOVE.L  our_cb,A0
        MOVE.L  cb.FSEL(A0),selector
    END;
  END RemoveSelector;
  (*$L=*)

PROCEDURE SelectFile (REF label     : ARRAY OF CHAR;
                      VAR path, name: ARRAY OF CHAR;
                      VAR ok        : BOOLEAN);

  (*$L-*)
  BEGIN
    ASSEMBLER
        JSR     testErrorCheck
        MOVE.W  #TRUE,(A3)+
        JSR     mouseInput
        
        MOVE.L  selector,A1
        JSR     (A1)
  
        MOVE.W  #FALSE,(A3)+
        JSR     mouseInput
    END;
  END SelectFile;
  (*$L=*)

PROCEDURE saveSelector;

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  our_cb,A0
        MOVE.L  selector,cb.FSEL(A0)
    END;
  END saveSelector;
  (*$L=*)
 *)
  
PROCEDURE selectFileTOSDependent (REF label     : ARRAY OF CHAR;
                                  VAR path, name: ARRAY OF CHAR;
                                  VAR ok        : BOOLEAN);

  (*$L-*)
  BEGIN
    ASSEMBLER
        JSR     testErrorCheck
        MOVE.W  #TRUE,(A3)+
        JSR     mouseInput
        
        JSR     GEMVersion
        MOVE.W  -(A3),D0
        CMP.W   #$0300,D0
        BCC     newTOS                  ; GEM 3.0 kann fsel_exinput
        CMP.W   #$0200,D0
        BCC     oldTOS                  ; GEM 2.0 kann fsel_exinput nicht
        CMP.W   #$0140,D0
        BCS     oldTOS                  ; erst 1.4 kann fsel_exinput

newTOS  JSR     selectFileExtended
        MOVE.W  #FALSE,(A3)+
        JMP     mouseInput

oldTOS
        JSR     selectFile
        SUBQ.L  #6,A3
        MOVE.W  #FALSE,(A3)+
        JMP     mouseInput
    END;
  END selectFileTOSDependent;
  (*$L=*)
  

                        (*  Nachfragefunktionen  *)
                        (*  ===================  *)

PROCEDURE GEMAvailable (): BOOLEAN;
  VAR   success: BOOLEAN;
  BEGIN
    IF gemStatus = unkown THEN
      (*  Als Seiteneffekt setzt 'InitGem' die Var. 'gemStatus': *)
      InitApplication (success);
      IF success THEN
        ExitApplication
      END;
    END;
    RETURN gemStatus = available
  END GEMAvailable;
  
PROCEDURE GDOSAvailable (): BOOLEAN;
  (* Liefert bei GEM 2.1 immer TRUE *)
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVEQ   #TRUE,D0
        MOVE.L  our_cb,A0
        CMPI.W  #$0210,cb.GLOBAL.ap_version(A0)
        BEQ     rtn
      vq_gdos
        MOVEQ   #-2,D0
        TRAP    #2
        ADDQ.W  #2,D0
        SNE     D0
        ANDI    #1,D0
      rtn
        MOVE    D0,(A3)+
    END;
  END GDOSAvailable;
  (*$L=*)
  
PROCEDURE ApplicationID (): CARDINAL;

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  our_cb,A0
        MOVE.W  cb.GLOBAL.ap_id(A0),(A3)+
    END;
  END ApplicationID;
  (*$L=*)

PROCEDURE GEMVersion (): CARDINAL;

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  our_cb, D0
        BEQ     err
        MOVE.L  D0, A0
        MOVE.W  cb.GLOBAL.ap_version(A0), (A3)+
        BRA     ende
err
        TRAP    #noErrorTrap
        DC.W    GeneralErr - $E000
        ACZ     'GEM NOT INIT.'
        SYNC
        CLR.W   (A3)+
ende
    END;
  END GEMVersion;
  (*$L=*)
  
PROCEDURE MaxPoints():CARDINAL;

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.W  #ptsinMax,D0
        ADDQ.W  #1,D0
        LSR.W   #1,D0
        MOVE.W  D0,(A3)+        ; liefere (ptsinMax+1)DIV 2
    END;
  END MaxPoints;
  (*$L=*)

PROCEDURE NoHideCursor (dev:DeviceHandle) :CARDINAL;

  (*$L-*)
  BEGIN
    ASSEMBLER
        JSR     testErrorCheck
        
        SUBQ.W  #2,A7
        MOVE.L  A7,(A3)+
        JSR     setDevice
        TST.W   (A7)+
        BNE     deviceOk
        CLR.W   (A3)+
        BRA     ende
        
deviceOk
        MOVE.L  our_cb,A0
        MOVE.L  cb.CURDEVICE(A0),A0
        MOVE.W  device.noHdCurs(A0),(A3)+
ende
    END;
  END NoHideCursor;
  (*$L=*)

PROCEDURE NoGrafMouseOff () :CARDINAL;

  (*$L-*)
  BEGIN
    ASSEMBLER
        JSR     testErrorCheck
        MOVE.L  our_cb,A0
        MOVE.W  cb.SUPERVISION.noGrafMouse(A0),(A3)+
    END;
  END NoGrafMouseOff;
  (*$L=*)
  
PROCEDURE NoUpdateWindow():CARDINAL;

  (*$L-*)
  BEGIN
    ASSEMBLER
        JSR     testErrorCheck
        MOVE.L  our_cb,A0
        MOVE.W  cb.SUPERVISION.noUpWind(A0),(A3)+
    END;
  END NoUpdateWindow;
  (*$L=*)

PROCEDURE NoMouseControl():CARDINAL;

  (*$L-*)
  BEGIN
    ASSEMBLER
        JSR     testErrorCheck
        MOVE.L  our_cb,A0
        MOVE.W  cb.SUPERVISION.noMouseCtrl(A0),(A3)+
    END;
  END NoMouseControl;
  (*$L=*)

PROCEDURE MouseInput (start:BOOLEAN);

  (*$L-*)
  BEGIN
    ASSEMBLER
        JMP     mouseInput
    END;
  END MouseInput;
  (*$L=*)


                        (*  Misc. managment  *)
                        (*  ===============  *)

VAR fathersSelectFile: PathEnv.FileSelectProc;
    gotFather: BOOLEAN;

PROCEDURE envelopeProc (start, child: BOOLEAN; VAR id: INTEGER);

  VAR     ptr     : p_cb;
          again   : BOOLEAN;

  BEGIN
    IF NOT child THEN
      IF start THEN
        gotFather:= FALSE;
        IF GemActive () THEN
          fathersSelectFile:= PathEnv.SelectFile;
          gotFather:= TRUE
        END
      END
    ELSE
      IF start THEN
        INC (modID);
        appIsInit[modID]:= FALSE;
        didShRead[modID]:= FALSE;
        (*
         * Damit ein Prg "EasyGEM1.SelectFile" benutzen kann, ohne selbst
         * ein GemInit machen zu mÅssen, muû hier die Routine neu zuge-
         * wiesen werden, da EasyGEM1 nur dann selbst ein GemInit macht,
         * wenn GemActive () FALSE liefert.
         *)
        IF gotFather THEN PathEnv.SelectFile:= fathersSelectFile END;
      ELSE
      
(*$? TestVersion:
  WriteString ("'GEMEnv': Killing level "); WriteString (CardToStr (modID, 0));
  WriteString (' [');
 *)
        ptr := root_cb;
        LOOP

          IF ptr = NIL THEN EXIT
          ELSIF ptr^.OWNER_ID = modID THEN
(*$? TestVersion:
  WriteString (' ID: '); WriteString (CardToStr (ptr^.OWNER_ID, 0));
 *)
            exitGem (ptr, TRUE);
            ptr := root_cb;
          ELSIF ptr^.OWNER_ID = - modID THEN
(*$? TestVersion:
  WriteString (' ID: '); WriteString (CardToStr (ptr^.OWNER_ID, 0));
 *)
            exitGem (ptr, FALSE);
            ptr^.OWNER_ID := 0;
            ptr := root_cb;
          ELSE ptr := ptr^.LASTCB END;
          error:= FALSE
          
        END;
(*$? TestVersion:
  WriteString (']'); WriteLn;
 *)
        
        DEC (modID);
        
      END;
      
    END;
  END envelopeProc;

PROCEDURE termProc;

  BEGIN
  
(*$? TestVersion:
  WriteString ("'GEMEnv' terminating (Level: ");
  WriteString (CardToStr (modID, 0)); WriteString (")..."); WriteLn;
 *)
 
    (*  Current 'modID = 2'. That means all init.s but the SysInit.s are
     *  released.
     *  Decrements 'modID' to '1', to release the SysInit.s at the call
     *  of 'removalProc'.
     *)
    envelopeProc (FALSE, TRUE, voidI);
    
(*$? TestVersion:
  WriteString ("...'GEMEnv' terminated."); WriteLn;
 *)
 
  END termProc;

PROCEDURE removalProc;
  
  BEGIN
  
(*$? TestVersion:
  WriteString ("'GEMEnv' removing (Level: ");
  WriteString (CardToStr (modID, 0)); WriteString ("..."); WriteLn;
 *)
 
    (*  Current 'modID = 1'. That means all init.s are released.
     *  Decrements 'modID' to '0'.
     *)
    envelopeProc (FALSE, TRUE, voidI);
    
(*$? TestVersion:
  WriteString ("...'GEMEnv' removed."); WriteLn;
 *)
 
  END removalProc;


(* nicht mehr benutzt:
  (*$L-*)
  PROCEDURE GemErrorHandler;
    BEGIN
      ASSEMBLER
          TRAP    #noErrorTrap
          DC.W    GemErr
      END
    END GemErrorHandler;
  (*$L=*)
*)

(*$L-*)
PROCEDURE emptyProc;
  END emptyProc;
(*$L=*)

VAR     wsp             : MemArea;
        envlpHandle     : EnvlpCarrier;
        termHandle      : TermCarrier;
        removalHandle   : RemovalCarrier;

BEGIN

 (*
  (*  Erste Selektor-Box ist die GEM-Box
   *)
  selector := selectFileTOSDependent;
  *)
  
  (*  Anmeldung der ModulÅberwachung
   *)
  noInits := 0;
  modID := 2;                     (* ZÑhle Module levels *)
  SetEnvelope (envlpHandle, envelopeProc, wsp);
  CatchProcessTerm (termHandle, termProc, wsp);
  CatchRemoval (removalHandle, removalProc, wsp);
  
  ErrorProc := emptyProc; (* ehemals: GemErrorHandler; *)
  errorProcPtr := ADR (ErrorProc);
  ErrHdlProc:= emptyProc;
  ptrToErrHdler := ADR (ErrHdlProc);
  
  gemStatus := unkown;
  
END GEMEnv.

