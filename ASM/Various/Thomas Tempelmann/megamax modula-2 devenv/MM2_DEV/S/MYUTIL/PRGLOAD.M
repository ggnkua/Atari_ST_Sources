
MODULE PrgLoad;

(*
 * Hinweis/Copyright:
 * ------------------
 *   Die Verwendungsrechte dieses Programms und seiner Quellen in der
 *   vorliegenden Version 2.0 liegt bei der Zeitschrift TOS (ICP-Verlag,
 *   Vaterstetten). Ein Verkauf dieses Programms oder seiner Quellen
 *   getrennt von den Zeitschriften des ICP-Verlags ist jedoch nicht
 *   gestattet.
 *
 *   Mit Erwerb der Zeitschrift "TOS" steht es Ihnen frei, das Programm
 *   zu nutzen. Das Programm ist also keine Freeware oder PD!
 *   Sie drfen das Programm ver„ndern, jedoch nicht selbst "verbesserte"
 *   Versionen dieses Programms verbreiten. Dies obliegt allein dem Urheber
 *   Thomas Tempelmann.
 *
 *   Ich hoffe, Sie beachten diese Hinweise. Ich w„re schwer entt„uscht,
 *   wenn pl”tzlich eine Version 2.1, die nicht von mir stammt, auf
 *   dem PD- oder Raubkopiermarkt erscheint. Dann k”nnte dies der letzte
 *   Beitrag von mir gewesen sein. Fairness und Vertrauen sind wichtig
 *   fr das Weiterleben dieser Form der Softwarever”ffentlichung!
 *
 *   Fr Fragen, Wnsche, Verbesserungen und Ver”ffentlichungen wenden
 *   Sie sich bitte an den Autor:
 *      Thomas Tempelmann, Nordendstr. 64, D-8000 Mnchen 40.
 *
 * šber dieses Programm:
 * ---------------------
 *   In der Ausgabe 4/91 der Zeitschrift TOS finden Sie die ausfhrliche
 *   Beschreibung dieses ntzlichen Programms.
 *
 *   Dieses Modul ist ohne Žnderungen nur mit Megamax Modula-2 (System 2.2,
 *   Compiler 4.0) oder h”her bersetzbar. Desweiteren geh”ren die beiden
 *   Quellen des Moduls "PrgLoader" (PRGLOADE.D & PRGLOADE.I) zu diesem
 *   Programm und mssen zuvor bersetzt werden.
 *
 *   Zum Linken reicht ein kleiner Stack, z.B. 4000 Byte.
 *   Als Treibermodule ist lediglich "M2Init" einzubinden.
 *
 * M”gliche Verbesserungen:
 * ------------------------
 * - šberwachen, ob "UsedHeapSize" bei jedem Programmlauf gleich bleibt.
 * - Selbstmodifizierenden Code erkennen und dann Warnung anzeigen mit
 *   Option, das Programm freizugeben.
 *
 *----------------------------------------------------------------------------
 * 22.10.88  TT  Grunderstellung ModLoad
 * 21.12.88  TT  Fertigstellung der Version 1.0 aus ModLoad 1.0
 * 05.02.91  TT  Fertigstellung der Version 2.0 aus ModLoad 1.3
 *----------------------------------------------------------------------------
 *)

(*$E MAC  -> Linker erzeugt ACC-Endung *)
(*$R-,S-  -> Keine Bereichs-, šberlauf- und Stack-Prfungen erzeugen *)

FROM PrgLoader IMPORT
  QueryLoaded, LoadProgram, UnLoadProgram, ProgramLoaded, CallProgram,
  UsedHeapSize, LoaderResults, ArgStr;

FROM SYSTEM IMPORT
  ASSEMBLER, CAST, ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD;

FROM AESWindows IMPORT
  UpdateWindow;

FROM AESForms IMPORT
  FormAlert;

FROM AESMisc IMPORT
  ShellFind;

FROM AESMisc IMPORT
  SelectFile;

FROM EasyGEM0 IMPORT
  WrapAlert;

FROM MOSGlobals IMPORT
  PathStr, NameStr, FileStr, SfxStr, MemArea;

FROM FileNames IMPORT
  FileName, PathConc, SplitPath, SplitName;

FROM Files IMPORT
  File, Open, Close, EOF, State, Access;

FROM Text IMPORT
  EOL, ReadFromLine, ReadLn;

FROM StrConv IMPORT
  CardToStr, StrToLCard;

FROM GEMEnv IMPORT
  GemError, InitApplication, ExitApplication;

FROM AESEvents IMPORT
  MessageEvent, MessageBuffer, accOpen;

FROM AESMenus IMPORT
  RegisterAcc;

FROM PrgCtrl IMPORT
  Accessory;

FROM MOSCtrl IMPORT
  ProcessID (* Zeiger auf den aktuellen GEMDOS-Prozež *);

FROM SysInfo IMPORT
  UseStackFrame;

FROM Directory IMPORT
  GetDefaultPath;

IMPORT FuncStrings, Strings, XBRA, BIOS;


CONST   LoaderStackSize = 4000; (* Stackgr”že zum Aufruf des Loaders *)

        Kennung = 'PrgL';       (* XBRA-Kennung fr TRAP #1-Handler *)
        PrgName = 'PrgLoad';    (* Name dieses Moduls (auch ACC-Eintrag) *)
        Version = '2.0';        (* Nicht „ndern und ver”ffentlichen (s.o.)! *)
        InfName = 'PRGLOAD.INF';(* Name der INF-Datei *)


TYPE ptrArgStr = POINTER TO ArgStr;

     PtrPexecPar = POINTER TO RECORD
                     mode: (loadExec, unused1, unused2, load, exec, create);
                     fileName: ADDRESS;
                     arg: ptrArgStr;
                     env: ADDRESS
                   END;

VAR
  DefaultHeap: LONGCARD;    (* Heap-Gr”že, wenn keine andere Angabe *)
  DidShowInfo, GotHeapSize, GetHeapSize: BOOLEAN;
  Desktop: ADDRESS;         (* Prozežkennung des Desktops, invariabel *)

  myName: Strings.String;
  path: ARRAY [0..127] OF CHAR;

  entry, at: ADDRESS;
  carrier: XBRA.Carrier;
  stackhi: ADDRESS;
  doingPexec: BOOLEAN;
  stackFrameOffs: SHORTCARD;
  ok: BOOLEAN;


PROCEDURE Alert (s: ARRAY OF CHAR);
(*
 * Einen beliebigen Hinweistext als Alert-Meldung anzeigen.
 *)

  VAR button: CARDINAL;
      ok: BOOLEAN;
      msg: ARRAY [0..250] OF CHAR;

  BEGIN
    Strings.Assign (s, msg, ok);
    (* Meldung mit FormAlert-Dialog anzeigen *)
    WrapAlert (msg, 0);
    Strings.Insert ('[0][', 0, msg, ok);
    Strings.Append ('][ OK ]', msg, ok);
    FormAlert (1, msg, button);
  END Alert;

PROCEDURE doLoadWithMsg (REF name: ARRAY OF CHAR);
(*
 * Das Programm laden und dann eine Erfolgs- bzw. Fehlermeldung anzeigen
 *)
  VAR result: LoaderResults;
      msg: ARRAY [0..60] OF CHAR;
  BEGIN
    IF ProcessID^ # Desktop THEN
      Alert ("Das Laden ist nur vom Desktop aus m”glich!")
    ELSE
      SplitPath (name, path, msg); (* 'msg' enth„lt nun den Programmnamen *)
      LoadProgram (name, DefaultHeap, result);
      IF result = noError THEN
        Strings.Append (' wurde geladen', msg, ok)
      ELSIF result = alreadyLoaded THEN
        Strings.Append (' ist bereits geladen', msg, ok)
      ELSE
        Strings.Append (' kann nicht geladen werden', msg, ok)
      END;
      Alert (msg)
    END;
  END doLoadWithMsg;

PROCEDURE doUnLoadWithMsg (REF name: ARRAY OF CHAR);
(*
 * Programm freigeben und Meldung anzeigen
 *)
  VAR result: LoaderResults;
      msg: ARRAY [0..50] OF CHAR;
  BEGIN
    SplitPath (name, path, msg);
    UnLoadProgram (name, result);
    IF result = noError THEN
      Strings.Append (' wurde freigegeben', msg, ok);
    ELSE
      Strings.Append (' war nicht geladen', msg, ok)
    END;
    Alert (msg)
  END doUnLoadWithMsg;

PROCEDURE hdlPexec (par: PtrPexecPar; VAR exitCode: LONGINT): BOOLEAN;
(*
 * Diese Routine wird von 'hdlGemdos' aufgerufen, wenn die
 * Pexec-Funktion des GEMDOS von einem Programm aufgerufen
 * wird. Hier wird geprft, ob das Programm schon geladen
 * ist, um es dann aus dem Speicher statt von Disk zu starten.
 * In 'par' wird ein Zeiger auf die Parameter des Pexec-Aufrufs
 * bergeben; 'hdlPexec' muž FALSE zurckgeben, wenn am Ende
 * doch das GEMDOS die Pexec-Funktion ausfhren soll, andernfalls
 * muž sie in 'exitCode' den Fehlercode liefern.
 *)

  VAR fn: POINTER TO FileStr;
      result: LoaderResults;

  BEGIN (* hdlPexec *)
    fn:= par^.fileName;
    IF par^.mode = loadExec (*trifft immer zu, da schon vorher geprft*) THEN
      IF (ProcessID^ = Desktop) & (BIOS.ControlKey IN BIOS.GetKBShift ()) THEN
        (* Das Laden ist nur vom Desktop aus erlaubt! *)
        IF BIOS.LeftShift IN BIOS.GetKBShift () THEN
          (* Mit Shift&Control kann Programm wieder freigegeben werden *)
          doUnLoadWithMsg (fn^)
        ELSE
          (* Mit Control-Taste wird Programm geladen und nicht gestartet *)
          doLoadWithMsg (fn^)
        END;
        exitCode:= 0;
        RETURN TRUE
      ELSE
        IF GetHeapSize OR ProgramLoaded (fn^) THEN
          (* hier normalerweise nur geladene Programme starten; nicht
           * geladene Programme unimttelbar ber GEMDOS starten lassen,
           * um evtl. Seiteneffekte zu vermeiden. *)
          GotHeapSize:= TRUE;
          CallProgram (fn^, par^.arg^, par^.env, exitCode);
          RETURN TRUE
        END
      END;
    END;
    RETURN FALSE
  END hdlPexec;

VAR regStack: ARRAY [1..256] OF WORD; (* Stack fr Register-Sicherung («KB) *)

PROCEDURE hdlGemdos;
(*
 * Diese Funktion h„ngt im GEMDOS-TRAP-Handler und berwacht, ob
 * die Pexec-Funktion aufgerufen wird. Wenn nicht, wird die Kontrolle
 * normal ans GEMDOS weitergereicht, sonst wird 'hdlPexec' aufgerufen.
 *)
  (*$L-  -> keinen Modula-Eintrittscode erzeugen *)
  BEGIN
    ASSEMBLER
        BTST.B  #5,(A7)         ; War Supervisormode aktiv ?
        BNE.B   super           ; Ja, dann stehen Arg. auf SSP
        MOVE.L  USP,A0
        CMPI.W  #$4B,(A0)       ; Pexec - Funktion ?
        BEQ.B   hdlPexecUser
dos     ; normale GEMDOS-Funktion ausfhren
        MOVE.L  entry,A0
        MOVE.L  -4(A0),A0
        JMP     (A0)
super   MOVE.W  stackFrameOffs,D0 ; damit es auch mit einer 68010/20/30 geht
        CMPI.W  #$4B,6(A7,D0.W) ; Pexec - Funktion ?
        BNE.B   dos             ; Nein -> GEMDOS aufrufen
        LEA     6(A7,D0.W),A0   ; Basis d. Argumente nach A0
hdlPexecUser:
        TST.W   doingPexec      ; ist dies der "Pexec" von "CallModule"?
        BEQ     noPexec         ;   nein -> dann werten wir ihn selbst aus.

        CLR.W   doingPexec
        BRA     dos             ;   ja -> dann lassen wir ihn zum GEMDOS durch

noPexec ; prfen, ob Prg gestartet & ausgefhrt werden soll.
        ADDQ.L  #2,A0
        CMPI    #loadExec,PtrPexecPar.mode(A0)
        BNE     dos

        MOVE.L  stackhi,A1      ; neuen SP f. Modula-Funktionen laden
        ; Register auf regStack retten:
        MOVEM.L D1-D7/A2-A6,-(A1)
        MOVE.W  (A7)+,-(A1)     ; SR vom SSP retten
        MOVE.L  (A7)+,-(A1)     ; PC vom SSP retten
        TST.W   stackFrameOffs  ; StackFrame vorhanden?
        BEQ     noSF1           ; nein
        MOVE.W  (A7)+,-(A1)     ; StackFrame vom SSP retten
noSF1:  MOVE.L  USP,A2
        MOVE.L  A2,-(A1)        ; USP retten
        MOVE.L  A7,-(A1)        ; SSP retten
        MOVE.L  A1,stackhi
        MOVE.L  A1,USP          ; den regStack auch fr Malloc-Aufruf nutzen
        ANDI    #$CFFF,SR       ; User Mode aktivieren

        ; Stack f. Modula-Funktionen (Loader-Aufruf) reservieren
        MOVE.L  A0,-(A7)
        MOVE.L  #LoaderStackSize,-(A7)
        MOVE    #$48,-(A7)      ; Malloc()
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.L  (A7)+,A0
        MOVE.L  D0,A3
        LEA     LoaderStackSize(A3),A7

        ; Parameter fr 'hdlPexec' auf den Parm-Stack (A3) laden
        MOVE.L  A0,(A3)+        ; Adr. der Parameter bergeben
        LEA     exitCode(PC),A0
        MOVE.L  A0,(A3)+        ; Adr. der exitCode-Variable bergeben
        MOVE    #1,doingPexec   ; Flag gegen Wiedereintritt setzen
        JSR     hdlPexec        ; Pexec-Sonderbehandlung
        CLR.W   doingPexec
        MOVE.W  -(A3),D0        ; Pexec-Rckgabewert (BOOLEAN = 2 Byte)

        ; Modula-Stack wieder freigeben
        MOVE.L  stackhi,A7      ; regStack wieder fr SP verwenden
        MOVE.L  D0,-(A7)
        MOVE.L  A3,-(A7)
        MOVE    #$49,-(A7)      ; Mfree()
        TRAP    #1
        ADDQ.L  #6,A7
        
        ; zurck in den Supervisor-Mode:
        CLR.L   -(A7)
        MOVE    #$20,-(A7)      ; Super (0L)
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.L  (A7)+,D0
        
        MOVE.L  A7,A1
        MOVE.L  (A1)+,A7        ; SSP zurck
        MOVE.L  (A1)+,A0        ; USP zurck
        MOVE.L  A0,USP
        TST.W   stackFrameOffs  ; StackFrame vorhanden?
        BEQ     noSF2           ; nein
        MOVE.W  (A1)+,-(A7)     ; StackFrame zurck
noSF2:  MOVE.L  (A1)+,-(A7)     ; PC zurck
        MOVE.W  (A1)+,-(A7)     ; SR zurck
        MOVEM.L (A1)+,D1-D7/A2-A6
        MOVE.L  A1,stackhi

        TST.W   D0              ; hdlPexec-Rckgabewert prfen
        BEQ     dos             ; Wurde nicht ausgefhrt -> GEMDOS aufrufen
        
        MOVE.L  exitCode(PC),D0 ; Exitcode laden
        RTE                     ; und zurck zum Aufrufer

exitCode: DS    4               ; 4 Byte fr Exitcode reservieren
    END
  END hdlGemdos;
  (*$L=*)

PROCEDURE readInfFile;
  (*
   * Liest die Datei "MODLOAD.INF" und l„dt die darin angegebenen Module.
   *)
  
  VAR f: File;
      s, s2: Strings.String;
      heapValid: BOOLEAN;
      pos: CARDINAL;
      heap: LONGCARD;
      result: LoaderResults;
  
  BEGIN
    s:= InfName;
    ShellFind (s);
    IF NOT GemError () THEN
      Open (f, s, readSeqTxt);
      WHILE NOT EOF (f) DO
        ReadFromLine (f, s);            (* Zeile einlesen *)
        ReadLn (f);                     (* Zeilenende berlesen *)
        (* Den String beim ersten Leerzeichen nach 's' und 's2' auftrennen: *)
        Strings.Split (s, Strings.PosLen (' ', s, 0), s, s2, ok);
        Strings.Upper (s);
        pos:= 0;
        (* Im zweiten Wort ('s2') eine evtl. vorhandene Zahl ermitteln: *)
        heap:= StrToLCard (s2, pos, heapValid);
        IF Strings.StrEqual (s, "HEAP") THEN
          (* Setzen der voreingestellten Heap-Gr”že *)
          IF heapValid THEN DefaultHeap:= heap END
        ELSE
          (* Wenn hinter dem Programmnamen eine Zahl angegeben ist, dann
           * diese als Heap-Gr”že, sonst die voreingestellte Gr”že nehmen
           * und das Programm laden. *)
          IF NOT heapValid THEN heap:= DefaultHeap END;
          LoadProgram (s, heap, result)   (* Programm laden *)
        END
      END;
      Close (f);
    END
  END readInfFile;

PROCEDURE service;
(*
 * Dialogroutine des Accessories
 *)

  VAR defbut, button: CARDINAL;
      s: ARRAY [0..199] OF CHAR;
      name: NameStr;
      didShow, ok: BOOLEAN;

  PROCEDURE showPrg (REF name: ARRAY OF CHAR; noOfRuns: CARDINAL;
                     currentHeapSize, neededHeapSize: LONGCARD): BOOLEAN;
  (*
   * Subroutine, um die geladenen Programme anzuzeigen
   *)
    BEGIN
      s:= "[0][ |";
      Strings.Append (FileName (name), s, ok);
      Strings.Append (" | |", s, ok);
      IF noOfRuns > 0 THEN
        Strings.Append ("Aktuelle Heap-Gr”že: ", s, ok);
        Strings.Append (CardToStr (currentHeapSize, 0), s, ok);
        Strings.Append (" |", s, ok);
        IF currentHeapSize < neededHeapSize THEN
          (* Wenn zu wenig Heap reserviert wurde, dann dies anzeigen *)
          Strings.Append ("Ben”tigte Heap-Gr”že: ", s, ok);
          Strings.Append (CardToStr (neededHeapSize, 0), s, ok)
        END
      ELSE
        Strings.Append ("(Wurde noch nicht gestartet) |", s, ok)
      END;
      Strings.Append (" ][Weiter|Freigabe|Abbruch]", s, ok);
      FormAlert (1, s, button);
      IF button = 2 THEN
        doUnLoadWithMsg (name)
      END;
      didShow:= TRUE;
      RETURN button # 3
    END showPrg;

  BEGIN
    IF GetHeapSize THEN
      (* Wenn vorher "Heap-Gr”že ermitteln" gew„hlt wurde, dies nun auswerten *)
      GetHeapSize:= FALSE;
      IF NOT GotHeapSize THEN
        Alert ('Sie haben doch noch kein Programm gestartet, oder?')
      ELSIF UsedHeapSize = MAX (LONGCARD) THEN
        Alert ('Das Programm scheint allen verfgbaren Speicher zu belegen')
      ELSE
        s:= '[0][ |Die ben”tigte Heap-Gr”že ist: | |';
        Strings.Append (CardToStr (UsedHeapSize,15), s, ok);
        Strings.Append ("| ][ OK ]", s, ok);
        FormAlert (1, s, button);
      END
    END;
    defbut:= 1;
    LOOP
      s:= "[0][         "+PrgName+" "+Version+"|"
             +" |"
             +"Erstellt von Thomas Tempelmann |"
             +"     mit Megamax Modula-2|"
             +"  fr das TOS-Magazin (4/91)]"
             +"[Mehr...|Info|Ausgang]";
      IF NOT DidShowInfo THEN
        defbut:= 2
      END;
      FormAlert (defbut, s, button);
      IF button = 3 THEN
        EXIT
      ELSIF button = 2 THEN
        FormAlert (1, "[0][Autor:      |  Thomas Tempelmann  |"
                   +"  Nordendstraže 64|  D-8000 Mnchen 40|  West Germany]"
                   +"[ OK ]", button);
        Alert ("PrgLoad "+Version+" ist weder Freeware noch PD! "+
               "Die Verwendungsrechte fr diese Version liegen "+
               "beim ICP-Verlag, Vaterstetten. ");
        Alert ("Der Autor beh„lt sich exklusiv vor, "+
               "weitere Versionen zu ver”ffentlichen.");
        Alert ("Ausfhrliche Informationen und die Quelltexte "+
               "zu diesem Programm finden Sie "+
               "im TOS-Magazin, Ausgabe 4/91.");
        DidShowInfo:= TRUE
      ELSE (* button = 1 *)
        s:=  "[0][ |W„hlen Sie:| Geladene Programme zeigen |"
            +" Heap-Gr”že ermitteln/setzen | ";
        IF ProcessID^ = Desktop THEN
          (* Das Laden ist nur vom Desktop aus erlaubt! *)
          Strings.Append ("Programm laden", s, ok)
        ELSE
          Strings.Append ("(Laden nur im Desktop m”glich)", s, ok)
        END;
        Strings.Append ("][ Zeige | Heap ", s, ok);
        IF ProcessID^ = Desktop THEN
          Strings.Append ("| Lade ", s, ok)
        ELSE
          Strings.Append ("|Abbruch", s, ok)
        END;
        Strings.Append ("]", s, ok);
        FormAlert (1, s, button);
        IF button = 3 THEN
          IF ProcessID^ = Desktop THEN
            name:= '';
            GetDefaultPath (path);
            SelectFile (path, name, ok);
            IF ok & (name[0] # '') THEN
              doLoadWithMsg (PathConc (path, name));
            END
          END
        ELSIF button = 1 THEN
          didShow:= FALSE;
          QueryLoaded (showPrg);
          IF NOT didShow THEN
            Alert ("Es ist kein Programm geladen.")
          END
        ELSE
          FormAlert (1, "[0][W„hlen Sie:|"
                             +" Heap-Gr”že setzen|"
                             +" Benutzte Heap-Gr”že|"
                             +"  eines Programms ermitteln | ]"
                             +"[Setzen|Ermitteln]", button);
          IF button = 2 THEN
            Alert ("Starten Sie nun ein Programm und melden Sie sich dann zurck.");
            GotHeapSize:= FALSE;
            GetHeapSize:= TRUE;
            RETURN
          ELSE
            LOOP
              s:= "[0][Voreingestellte Heap-Gr”že |"
                 +"zum Laden von Programmen:| |";
              Strings.Append (CardToStr (DefaultHeap, 15), s, ok);
              Strings.Append ("| ][Mehr|Weniger|OK]", s, ok);
              FormAlert (3, s, button);
              IF button = 1 THEN
                DefaultHeap:= DefaultHeap + DefaultHeap DIV 2
              ELSIF button = 2 THEN
                DefaultHeap:= DefaultHeap - DefaultHeap DIV 3
              ELSE
                EXIT
              END
            END
          END
        END
      END;
      defbut:= 3
    END (* LOOP *)
  END service;

VAR msg: MessageBuffer;
    menuID: CARDINAL;
    button: CARDINAL;

BEGIN
  (* Anmeldung beim GEM *)
  InitApplication (ok);
  IF NOT Accessory () THEN
    Alert ('PrgLoad l„uft nur als Accessory!')
  ELSE
    (* Initialisierung der globalen Variable *)
    doingPexec:= FALSE;
    DefaultHeap:= 16364;   (* Heap-Gr”že, wenn keine andere Angabe *)
    GetHeapSize:= FALSE;
    DidShowInfo:= FALSE;
    Desktop:= ProcessID^;  (* Prozež vom GEM/Desktop merken *)
    stackhi:= ADR(regStack)+SIZE(regStack); (* Stack-Pointer fr Reg.-Save *)
    (* Stackframe fr 'hdlGemdos' ermitteln *)
    IF UseStackFrame () THEN stackFrameOffs:= 2 ELSE stackFrameOffs:= 0 END;
    (* 'hdlGemdos' in TRAP #1 ber XBRA einh„ngen *)
    IF NOT XBRA.Installed (Kennung, $84 (* GEMDOS/TRAP#1 *), at) THEN
      XBRA.Create (carrier, Kennung, CAST (ADDRESS, hdlGemdos), entry);
      XBRA.Install (entry, at);
      (* Zusammensetzen des Namens und Eintrag als Accessory *)
      myName:= "  "+PrgName;
      RegisterAcc (ADR (myName), menuID, ok);
      UpdateWindow (TRUE);
      readInfFile;
      UpdateWindow (FALSE);
      LOOP
        MessageEvent (msg);
        IF (msg.msgType = accOpen) THEN
          service
        END
      END
    END
  END
END PrgLoad.
