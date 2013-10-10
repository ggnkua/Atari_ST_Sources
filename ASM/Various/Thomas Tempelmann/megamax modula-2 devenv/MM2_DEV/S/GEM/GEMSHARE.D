DEFINITION MODULE GEMShare;


(*      Megamax Modula-2 GEM Library: Von allen GEM-Library-Modulen genutzte
 *                                    Definitionen und Routinen.
 *                                    (INTERNES MODUL)
 *
 *      Autor: Manuel Chakravarty       Erstellt: MÑrz-Dezember 1987
 *
 *      Version 2.1     V#0164
 *
 *
 *      29.10.93, Dirk Steins:
 *        VDI- und AES-INTIN-Arrays getrennt.
 *)


FROM SYSTEM     IMPORT ADDRESS, WORD, LONGWORD, BYTE;

FROM MOSGlobals IMPORT MemArea;

FROM GrafBase   IMPORT Point, Rectangle, PtrMouseFormDef;

FROM GEMGlobals IMPORT GemChar, MButtonSet, SpecialKeySet, TEffectSet;


EXPORT  p_device, device, deviceList, p_cb, cb, root_cb, our_cb, error,
        intinMax, ptsinMax, keyboardPlugActive, buttonPlugActive,
        firstRectPlugActive, secondRectPlugActive, messagePlugActive,
        timerPlugActive, keyboardPlug, buttonPlug, firstRectPlug,
        secondRectPlug, messagePlug, timerPlug, noErrorTrap, deviceMagic,
        cbMagic, PtrPrivDevParm, PrivGDPFkt, PrivInputDev, PrivDeviceType,
        PrivScreenType, PrivTextRotType, PrivGDPAttribute, logInpDev,
        inputMode, errNum, ptrToErrHdler, errorProcPtr, pubs, pubArrays,
        ptrPubArrays,
        
        aes_call, aes_if, vdi_call, vdi_if, testINTOUT0, testErrorCheck,
        setINT0attribut, getCalcedFrame, superData, stringIntoINTIN,
        (*enchantSuperMode, *)stringIntoCFormat, setDevice, gemErrorOccured,
        
        ptrVectorList, vecListElem, timerVecList, butChgVecList, msMoveVecList,
        curChgVecList, orgTimerVec, orgButChgVec, orgMsMoveVec, orgCurChgVec,
        deltaT,
        grafMouse, updateWindow, showCursor, closeWindow, deleteWindow,
        exchangeTimerVec, exchangeMouseVec, removeTimerVector,
        removeButChgVector, removeMsMoveVector, removeCurChgVector,
        unloadFonts, hideCursor, selectFile, selectFileExtended, shellRead;
        
        
CONST           (* Misc. private Const's *)
        
        intinMax                = 127;   (* Highest index of the INTIN-Array *)
        ptsinMax                = 511;   (* Highest index of the PTSIN-Array *
                                          * GEM erlaubt nicht mehr.          *)
        
        noErrorTrap             = 6;     (* Nummer des Trap's fÅr Errorbehand.*)
        
        deviceMagic             = 10765; (* Ein denkwÅrdiges Datum *)
        cbMagic                 = 666;   (* HÑ, HÑ... *)
        
        
        
(*  Die nachfolgende Deklaration muû mit der in 'GEMEnv' Åbereinstimmen !!!!! *)
(*  ************************************************************************* *)

TYPE    PrivGDPAttribute= (lineOpPriv, markerOpPriv, textOpPriv, fillOpPriv,
                           noAttributePriv, notAvaiblePriv);
        PrivGDPFkt      = (barGDPPriv, arcGDPPriv, pieGDPPriv, circleGDPPriv,
                           ellipseGDPPriv, eArcGDPPriv,  ePieGDPPriv,
                           rRectGDPPriv, fRectGDPPriv, jTextGDPPriv);
        PrivInputDev    = (keybdPriv, otherPriv);
        PrivDeviceType  = (outDevPriv, inDevPriv, inoutDevPriv,
                           reservedDevPriv, metafilePriv);
        PrivScreenType  = (noScreenPriv, difCtrlDifScrnPriv, difCtrlSamScrnPriv,
                           samCtrlDifMemPriv,  samCtrlSamMemPriv);
        PrivTextRotType = (noTextRotPriv, step90Priv, everyDirecPriv);
        
        PtrPrivDevParm  = POINTER TO PrivDevParm;
        PrivDevParm     = RECORD
          charWidth          : CARDINAL;
          charHeight          : CARDINAL;
          cellWidth          : CARDINAL;
          cellHeight          : CARDINAL;
          rasterWidth          : CARDINAL;
          rasterHeight          : CARDINAL;
          pointWidth          : CARDINAL;
          pointHeight          : CARDINAL;
          fontSizes          : CARDINAL;
          lTypes          : CARDINAL;
          lWidths          : CARDINAL;
          mTypes          : CARDINAL;
          mSizes          : CARDINAL;
          fonts          : CARDINAL;
          fPatterns          : CARDINAL;
          fHatchings          : CARDINAL;
          noColors          : CARDINAL;
          minWChar          : CARDINAL;
          maxWChar          : CARDINAL;
          minHChar          : CARDINAL;
          maxHChar          : CARDINAL;
          minWRow          : CARDINAL;
          maxWRow          : CARDINAL;
          minWMark          : CARDINAL;
          maxWMark          : CARDINAL;
          minHMark          : CARDINAL;
          maxHMark          : CARDINAL;
          bgColors          : CARDINAL;
          maxRasterPls          : CARDINAL;
          op16PerSec          : CARDINAL;
          noWrtModes          : CARDINAL;
          maxInMode          : CARDINAL;
          maxMarker          : CARDINAL;
          maxStrLen          : CARDINAL;
          noMButts          : CARDINAL;
          thickLnModes                                  : CARDINAL;
          possibleGDPs                                  : ARRAY PrivGDPFkt OF
                                                           PrivGDPAttribute;
          color          : BOOLEAN;
          fill          : BOOLEAN;
          cArray          : BOOLEAN;
          zooming          : BOOLEAN;
          lookUpTab          : BOOLEAN;
          textJust          : BOOLEAN;
          contFill          : BOOLEAN;
          penChange          : BOOLEAN;
          colorRibbon          : BOOLEAN;
          thickLnTyps                                   : BOOLEAN;
          grafCCtrl             : PrivInputDev;
          valueIn             : PrivInputDev;
          caseIn             : PrivInputDev;
          alphanumIn                                    : PrivInputDev;
          deviceType                                    : PrivDeviceType;
          screen                                        : PrivScreenType;
          useTEffects                                   : TEffectSet;
          textRot                                       : PrivTextRotType;
        END;
        
TYPE    logInpDev       = (noDev, location, value, choice, str);
        inputMode       = (noMode, request, sample);
        
TYPE    p_device        = POINTER TO device;
        device          = RECORD
                            magic        : CARDINAL;
                            mode         : CARDINAL;
                            handle       : CARDINAL;
                            
                            params       : PrivDevParm;
                            
                            noHdCurs,
                            oldHdCurs    : CARDINAL;
                            
                            fontsLoaded  : BOOLEAN;
                            
                            curInpMode   : ARRAY logInpDev OF inputMode;
                            
                            next         : p_device;
                          END;
        deviceList      = p_device;
        
        ptrVectorList   = POINTER TO vecListElem;
        vecListElem     = RECORD
                            newVec       : PROC; (*Die unterschiedlichen Para-
                                   meter interessieren auf Masch.ebene nicht! *)
                            wsp          : MemArea;
                            next         : ptrVectorList;
                            futureAddr   : ADDRESS;
                          END;
                         
        superData       = RECORD
                            noGrafMouse  : CARDINAL;
                            oldGrafMouse : CARDINAL; (* Number of mouse hides *)
                            noUpWind     : CARDINAL;
                            noMouseCtrl  : CARDINAL; (* No. wind. updates/ctrls*)
                            
                            createWinds  : LONGWORD;
                            openWinds    : LONGWORD; (* Created/opned windows *)
                            
                            timerChgd,
                            butChgChgd,
                            msMoveChgd,
                            curChgChgd   : BOOLEAN;  (* Vectors changed ~ TRUE*)
                            timerPrev,       (* Ptr. to list element of the *)
                            butChgPrev,      (* vector, that was top before *)
                            msMovePrev,      (* these Level. NIL ~ orig. Vec*)
                            curChgPrev   : ptrVectorList;
                          END;
        
        pubArrays       = RECORD
                            vINTIN       : ARRAY[0..intinMax] OF INTEGER;
                            aINTIN       : ARRAY[0..intinMax] OF INTEGER;
                            vINTOUT      : ARRAY[0..127] OF INTEGER;
                            aINTOUT      : ARRAY[0..127] OF INTEGER;
                            PTSIN       : ARRAY[0..ptsinMax] OF INTEGER;
                            PTSOUT      : ARRAY[0..11]  OF INTEGER;
                            ADDRIN      : ARRAY[0..2] OF ADDRESS;
                            ADDROUT     : ARRAY[0..1] OF ADDRESS;
                          END;
        ptrPubArrays    = POINTER TO pubArrays;
          
        (*  cb (control block) ist eine Struktur, die bei
         *  jedem 'InitGem' dynamisch erzeugt wird und ab
         *  dann die Parameter enthÑlt, die dem, 'InitGem'
         *  aufrufenden Modul als Verbindung zum GEM die-
         *  nen. 'ExitGem' dealloc. die Struktur wieder.
         *)
         
        p_cb    = POINTER TO cb;
        cb      = RECORD
                    
                    (*  AES-Control-Array
                     *)
                    A_CONTRL    : RECORD
                                    opcode      : CARDINAL;
                                    sintin      : CARDINAL;
                                    sintout     : CARDINAL;
                                    saddrin     : CARDINAL;
                                    saddrout    : CARDINAL
                                  END;
                                  
                    (*  VDI-Control-Array
                     *)
                    V_CONTRL    : RECORD
                                    opcode      : CARDINAL;
                                    sptsin      : CARDINAL;
                                    sptsout     : CARDINAL;
                                    sintin      : CARDINAL;
                                    sintout     : CARDINAL;
                                    subcmd      : CARDINAL;
                                    handle      : INTEGER;
                                    multi1      : INTEGER;
                                    multi2      : INTEGER;
                                    multi3      : INTEGER;
                                    multi4      : INTEGER;
                                    multi5      : INTEGER;
                                  END;
                             
                    (*  AES-Global-Array
                     *)
                    GLOBAL      : RECORD
                                    ap_version  : INTEGER;
                                    ap_count    : INTEGER;
                                    ap_id       : INTEGER;
                                    ap_pprivate : ADDRESS;
                                    ap_ptree    : ADDRESS;
                                    ap_pmem     : ADDRESS;
                                    ap_lmem     : INTEGER;
                                    ap_nplanes  : INTEGER;
                                    ap_resvd11  : INTEGER;
                                    ap_resvd12  : INTEGER;
                                    ap_bvdisk   : BITSET;
                                    ap_bvhard   : BITSET;
                                  END;
                                  
                    (*  VDI-Parameterblock
                     *)
                    VDIPB       : RECORD
                                    contrl      : ADDRESS;
                                    intin       : ADDRESS;
                                    ptsin       : ADDRESS;
                                    intout      : ADDRESS;
                                    ptsout      : ADDRESS;
                                  END;
                                  
                    (*  AES-Parameterblock
                     *)
                    AESPB       : RECORD
                                    contrl      : ADDRESS;
                                    global      : ADDRESS;
                                    intin       : ADDRESS;
                                    intout      : ADDRESS;
                                    addrin      : ADDRESS;
                                    addrout     : ADDRESS;
                                  END;
                           
                    HANDLE      : INTEGER;    (* AES Grafikhandle *)
                    
                    DEVICES     : deviceList; (* Liste der VDI-GerÑte *)
                    CURDEVICE   : p_device;   (* Aktuelles GerÑt *)
                    
                    FSEL        : PROC;       (* Selector vor Init. d. Levels *)
                    
                    ISACC       : BOOLEAN;    (* = 'cb'-Besitzer ist ein Acc. *)
                    
                    MAGIC       : CARDINAL;
                    SUPERVISION : superData;
                    OWNER_ID    : INTEGER;    (* ID des cb Besitzers *)
                    
                    DIDAPPLINIT : BOOLEAN;    (* appl_init aufgerufen? *)
                    
                    LASTCB      : p_cb        (*  Zeigt auf alten (nÑchsten) cb
                                               *  NIL ~ Kein weiterer cb
                                               *)
        END;
        
VAR     our_cb, root_cb : p_cb; (*  root_cb ~ Zeiger auf die Liste mit den
                                 *            Kontollblîcken.
                                 *  our_cb  ~ Zeiger auf den momentan aktiven
                                 *            Kontr.block
                                 *)
        
        pubs            : ptrPubArrays;
                                                 
        error           : BOOLEAN;
        errNum          : INTEGER; (*  Ist 'error = TRUE', so steht in
                                    *  'errNum' der Wert der den Fehler aus-
                                    *  lîûte.
                                    *)
        errorProcPtr    : POINTER TO PROC; (*  Tritt ein Fehler auf, der von
                                            *  der Anwendung nicht erfragt
                                            *  wird, so wird 'errorProc^'
                                            *  ausgefÅhrt, falls installiert.
                                            *)
        
        timerVecList,butChgVecList,             (* Vector Variablen *)
        msMoveVecList,curChgVecList                     :ptrVectorList;
        orgTimerVec,orgButChgVec,orgMsMoveVec,
        orgCurChgVec                                    :PROC;
        deltaT                                          :CARDINAL;
        
                (* Plugs for the event watch-dogs (see also 'EventHandler') *)
        
        keyboardPlugActive,buttonPlugActive,
        firstRectPlugActive,secondRectPlugActive,
        messagePlugActive,timerPlugActive       :BOOLEAN;
        
        keyboardPlug    : PROC;
                       (* PROCEDURE(VAR (*char:*)GemChar,
                                    VAR (*keys:*)SpecialKeySet):BOOLEAN;
                        *)
        
        buttonPlug      : PROC;
                       (* PROCEDURE((*clicks:*)CARDINAL,(*loc:*)Point,
                                    (*buts:*)MButtonSet,(*keys:*)SpecialKeySet)
                                   :BOOLEAN;
                        *)
                                            
        firstRectPlug   : PROC;
                       (* PROCEDURE((*loc:*)Point,(*buts:*)MButtonSet,
                                    (*keys:*)SpecialKeySet):BOOLEAN;
                        *)
                        
        secondRectPlug  : PROC;
                       (* PROCEDURE((*loc:*)Point,(*buts:*)MButtonSet,
                                    (*keys:*)SpecialKeySet):BOOLEAN;
                        *)
                        
        messagePlug     : PROC;
                       (* PROCEDURE((*buffer:*)MessageBuffer):BOOLEAN;
                        *)
                        
        timerPlug       : PROC;
                       (* PROCEDURE():BOOLEAN;
                        *)
                        
    
        (*  Misc. subroutines  *)
        (*  =================  *)
        
PROCEDURE stringIntoINTIN(REF str:ARRAY OF CHAR):CARDINAL;

(*  stringIntoINTIN -- geg.: Open Array of CHAR 'str', Offset fÅr INTIN   *
 *                           Indizierung in D4 ( in Elementen )           *
 *                     ges.: Die CHAR's des Array befinden sich im INTIN- *
 *                           Array und als RÅckgabewert die StringlÑnge   *
 
 *                !! Aufruf nur von Assemblerteilen !!                    *)


PROCEDURE getCalcedFrame(frame:Rectangle);
        
(*  getCalcedFrame -- geg.: Ein Rechteck 'frame' auf dem Param.stack und die *
 *                          Zieladdresse+8 in A1                             *
 *                    ges.: (A1-8).W = frame.x, 2(A1-8).W = frame.y          *
 *                          4(A1-8).W = frame.x+frame.w-1,                   *
 *                          6(A1-8).W = frame.y+frame.h-1                    *
 
 *              Aufruf nur aus Assemblerteilen!!                             *)


(*
PROCEDURE enchantSuperMode;

(*  enchantSuperMode -- Gehe in den Supervisor-Mode
 *)
 *)

PROCEDURE stringIntoCFormat(REF str:ARRAY OF CHAR);
        
(*  stringIntoCFormat -- geg.: 'str' ein String                           *
 *                       ges.: Kopiert 'str' auf den Stack und hÑngt eine *
 *                             $0 dran. Danach zeigt D2 auf den Stringanf.*
 *                             und mit 'MOVE.L  (A7),A7' wird der String  *
 *                             wieder vom Stack entfernt.                 *
 
 *              Aufruf nur von Assembler!                                 *)
 
 
PROCEDURE setDevice(handle:p_device;VAR success:BOOLEAN);
        (* Legt das aktuelle VDI-Device fest. 'success=FALSE' falls das *
         * 'handle' ungÅltig war.                                       *)
         

        (*  global error handling  *)
        (*  =====================  *)
 
PROCEDURE testINTOUT0;

(*  testINTOUT0  - geg.: FehlerrÅckmeldung in INTOUT[0]  *
 *                 ges.: 'error'=(our_cb.INTOUT[0]=0)    *)
 

PROCEDURE testErrorCheck;

(*  testErrorCheck - Lîst ein HALT aus, falls der User versÑumt hat einen *
 *                   Fehler abzufragen!                                   *)
 
 
PROCEDURE gemErrorOccured;

(*  gemErrorOccured - Lîst Fehlerbehandlung aus *)
 


        (* A E S *)
        
PROCEDURE aes_call(pb:p_cb);
        (* Ruft Application Enviroment Services mit dem Parameterblock *
         * 'pb' auf.                                                   *)

PROCEDURE aes_if(opcode:CARDINAL);
        (* Bereitet Aufruf der AES-Funktion mit der Nummer 'opcode' vor *
         * und ruft danach 'aes-call' mit dem aktuellen Parameterblock  *
         * auf.                                                         *)


        (* V D I *)

PROCEDURE vdi_call(para:p_cb);
        (* Ruft Virtual Display Interface mit dem Parameterblock 'para' auf. *)

PROCEDURE vdi_if(handle:p_device;opcode,subcmd:CARDINAL);
        (* Bereitet Aufruf der VDI-Funktion mit der Nummer 'opcode' vor, *
         * falls diese Unterfunktionsnummern besitzt werden diese in     *
         * 'subcmd' Åbergeben (, sonst setzt man 'subcmd=0'). Dann wird  *
         * 'vdi_call' mit dem aktuellen Parameterblock aufgerufen.       *)

PROCEDURE setINT0attribut(handle:p_device);(* ParameterÅbergabe in D0 + D1 *)
        
(*  setINT0attribute -- geg.: D0 Wert eines Attributes und D1 VDI-Fktsopcode*
 *                      ges.: Aufruf der Funktion die dem Opcode entspricht *
 *                            wobei der Wert Åbergeben wird. Die Globale    *
 *                            Var. 'error' wird 'TRUE', falls der Wert vom  *
 *                            VDI nicht angenommen wird.                    *
 
 *      Aufruf nur von ASSEMBLER-Teilen!                                    *)



PROCEDURE selectFile (VAR name, path: ARRAY OF CHAR; VAR ok: BOOLEAN);
PROCEDURE selectFileExtended (REF label     : ARRAY OF CHAR;
                              VAR name, path: ARRAY OF CHAR;
                              VAR ok        : BOOLEAN);

        (*  Die GEM File-Selektor-Box fÅr die entsprechende Option
         *  in 'GEMEnv'.
         *  'selectFileExtended' erst ab TOS 1.4
         *)
         
PROCEDURE shellRead (VAR cmd, tail: ARRAY OF CHAR);

        (*  Entspricht der von 'AESMisc' exportierten Prozedur.
         *  Ist hier nur impl., damit keine zyklischen Importe durch
         *  die Tatsache entstehen, daû 'GEMEnv' die Proc. benutzt.
         *)



        (*  Von mehren Moduln genutzte GEM-Calls (for supervision)  *)
        (*  ======================================================  *)
       
PROCEDURE grafMouse (form:WORD(* ~ AESGraphics.MouseForm*);
                     mFormDefPtr:PtrMouseFormDef);

PROCEDURE showCursor (handle:p_device;force:BOOLEAN);

PROCEDURE hideCursor (handle:p_device);


PROCEDURE updateWindow (update:WORD);


PROCEDURE closeWindow (handle:CARDINAL);

PROCEDURE deleteWindow (handle:CARDINAL);


PROCEDURE exchangeTimerVec(new:PROC;VAR time:CARDINAL):PROC;

(*  exchangeTimeVec -- geg.: 'new' der neue Timerinterrupt vector    *
 *                     ges.: In 'time' steht die Zeit die zwischen 2 *
 *                           Timerinter. vergeht(in ms), der neue    *
 *                           Vector ist beim VDI angemeldet und der  *
 *                           alte Vector ist RÅckgabewert.           *)
 
        
PROCEDURE exchangeMouseVec(opcode:CARDINAL;new:PROC):PROC;

(*  exchangeMouseVec -- geg.: 'opcode' der VDI-Opcode fÅr einen Mouse- *
 *                            vector exchange und 'new' die neue Proc. *
 *                      ges.: neue Proc. bei VDI angemeldet und alter  *
 *                            Vector als RÅckgabewert                  *)


PROCEDURE removeTimerVector(VAR hdl:vecListElem);

PROCEDURE removeButChgVector(VAR hdl:vecListElem);

PROCEDURE removeMsMoveVector(VAR hdl:vecListElem);

PROCEDURE removeCurChgVector(VAR hdl:vecListElem);

PROCEDURE unloadFonts (handle:p_device; select:WORD);

VAR ptrToErrHdler: POINTER TO PROC;

END GEMShare.
