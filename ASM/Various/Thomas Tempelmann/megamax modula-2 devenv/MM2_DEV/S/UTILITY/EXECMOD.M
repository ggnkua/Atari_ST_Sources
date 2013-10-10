MODULE ExecMod;

(*
        Dieses Modul muû gelinkt werden. Dann erlaubt es, vom
        Desktop aus Module (Endung '.MOD') direkt zu starten,
        indem sie mit einem Doppelklick angewÑhlt werden.

        So wird's gemacht:
        Dieses Modul compilieren, dann in Linker-Optionen nur die
        Module 'M2INIT' und 'GEMIO' aktivieren und dies Modul linken
        (Vorsicht: Unbedingt KEINE Optimierung im Linker einstellen!).
        Dann die Shell verlassen, im Desktop das Fenster mit der
        erzeugten Prg-Datei (EXECMOD.PRG) îffnen und die Datei einmal
        anklicken. Dann oben in der MenÅzeile 'Anwendung anmelden'
        anwÑhlen. Es erscheint eine Box, in der als Dateiart 'MOD'
        einzugeben ist. Zuletzt muû noch 'OK' angeklickt werden (nicht
        RETURN drÅcken !). Nun kann eine beliebige MOD-Datei doppelt
        angeklickt werden, wodurch automatisch 'EXECMOD.PRG' gestar-
        tet wird, welches wiederum mit 'CallModule' (s.u.) das an-
        geklickte Modul startet. Werden noch weitere Module benîtigt,
        werden sie in zwei weiteren Verzeichnissen gesucht: Dort, woher
        das angelickte Modul stammt, und im Ordner "IMP" des darÅber
        liegenden Verzeichnisses (s. 'initPaths').
        Bei Bedarf kînnen die Suchpfade unten in der Prozedur
        'initPaths' geÑndert werden, um z.B. die Module immer aus
        einem Ordner auf einem festgelegten Laufwerk suchen zu lassen.
        Wird ein Modul nicht gefunden, erscheint eine Fehlermeldung.

        Um den automatischen Aufruf dieses Programms beim Anklik-
        ken von Modulen dauerhaft zu machen, muû in der MenÅzeile
        des Desktops 'Arbeit sichern' angewÑhlt werden.

        Dieses Programm sorgt dafÅr, daû bei Bedarf die Ausgabe
        Åber InOut auf ein Textfenster erfolgt.
        Um Speicherplatz zu sparen, ist es auch mîglich, von
        diesem Programm eine Version zu erstellen, die anstatt
        'GEMIO' das Modul 'TOSIO' verwendet. Dann werden die Aus-
        gaben auf den normalen TOS-Bildschirm (ohne Grafik) ge-
        leitet. Die so aktivierten Module sollten dann aber, wie
        auch unter der Shell, die Endung 'MOS' statt 'MOD' erhal-
        ten und entsprechend dieses modifizierte Programm bei
        'Anwendung anmelden' fÅr 'MOS'-Endungen installiert wer-
        den.

        Achtung: Keinesfalls darf dieses Modul beim Linken kom-
        primiert werden (unbenutzte Funktionen entfernen), da
        sonst die hier eingelinkten Module nicht mehr vom anderen
        Modul verwendet werden kînnen.

        Ersteller: Thomas Tempelmann, 14.3.88
        FÅr Megamax Modula-2
*)

FROM SYSTEM IMPORT LONGWORD, WORD, ADDRESS, BYTE, ADR, ASSEMBLER;

FROM GEMEnv IMPORT RC, DeviceHandle, InitGem;

FROM SysBuffers IMPORT HdlErrorStack;

FROM Loader IMPORT LoaderResults, CallModule;

FROM Storage IMPORT ALLOCATE;

FROM SystemError IMPORT OutOfMemory;

FROM ArgCV IMPORT InitArgCV, PtrArgStr;

IMPORT Lists;

FROM PrgCtrl IMPORT TermProcess;

FROM SysCtrl IMPORT ExcToScanAddr;

FROM AESForms IMPORT FormAlert;

FROM EasyGEM0 IMPORT WrapAlert;

IMPORT MOSGlobals, Strings, SysTypes, FileBase, StrConv,
        HdlError, ErrBase, MOSConfig, GEMScan;


MODULE simpleGEMError;  (* lokales Modul *)
(*$R-,S-*)

  (*
   * Hilfsmodul zum Abfangen und Anzeigen von Laufzeitfehlern.
   * GegenÅber GEMError wird kein Scanning ermîglicht und bei Dateifehlern
   * wird nur die Fehlernummer angezeigt.
   * Die Fehlertextvariablen werden mit deutschen Texten initialisiert.
   *)
  
  IMPORT MOSGlobals;
  
  IMPORT ASSEMBLER, LONGWORD, WORD, ADDRESS, BYTE, ADR;
  
  FROM MOSGlobals IMPORT MEM, BusFault, OddBusAddr, NoValidRETURN, OutOfStack;
  
  IMPORT WrapAlert, FormAlert;
  
  IMPORT ALLOCATE, OutOfMemory;
  
  FROM Strings IMPORT String, Pos, Delete, Assign, Insert, Concat, Copy,
        Length, Empty, Space, Append, Upper;
  
  FROM SysTypes IMPORT ScanDesc;
  
  FROM FileBase IMPORT CloseFile, HandleError, File0;
  
  FROM StrConv IMPORT CardToStr, StrToLCard, IntToStr, LHexToStr;
  
  IMPORT TermProcess;
  
  FROM SysTypes IMPORT ExcDesc;
  
  FROM HdlError IMPORT GetErrorMsg, CatchErrors;
  
  FROM ErrBase IMPORT RtnCond, ErrResp;
  
  FROM MOSConfig IMPORT LoaderMsg, FileErrMsg, RuntimeErrMsg;
  
  FROM GEMScan IMPORT InputScan, InitChain, CallingChain;
  
  IMPORT HdlErrorStack;
  IMPORT ExcToScanAddr;
  
  
  (* Folgende Funktion fÑngt allgemeine Laufzeitfehler ab. *)
  
  PROCEDURE bye(nr: INTEGER; msg: ARRAY OF CHAR; causer: ErrResp;
                cont: RtnCond; VAR info: ExcDesc): BOOLEAN;
    
    VAR scan: ScanDesc;
        msg2: String;
        msg1:ARRAY [0..133] OF CHAR; (* reicht f. 4 Zeilen *)
        mayCont,
        strVal:BOOLEAN;
        defBut, index, button:CARDINAL;
        relad:LONGCARD;
        str,
        mname:ARRAY [0..31] OF CHAR;
    BEGIN
      IF Empty (msg) THEN
        GetErrorMsg (nr,str)
      ELSE
        Assign (msg,str,strVal)
      END;
      (* Scanner-Record vorbereiten: *)
      ExcToScanAddr (info, scan);
      IF causer=callerCaused THEN
        index:= 1
      ELSE
        index:= 0
      END;
      mayCont:= cont=mayContinue;
      IF (nr=BusFault) OR (nr=OddBusAddr) THEN
        Concat (str,'| auf ',msg2,strVal);
        Append (LHexToStr(info.accessAddr,0),msg2,strVal)
      ELSE
        Assign (str,msg2,strVal)
      END;
      InitChain (scan);
      InputScan (msg2,index);
      msg1:= '[0][][Quit';
      IF mayCont THEN
        Append ('|Cont',msg1,strVal)
      END;
      Append (']',msg1,strVal);
      Append ( Space (22 - INTEGER (Length (str))), msg2, strVal);
      Insert (msg2,4,msg1,strVal);
      FormAlert (1+ORD(mayCont), msg1, button);
      IF button = 1 THEN (* Quit *)
        TermProcess (nr)
      ELSE (* Cont *)
        RETURN FALSE
      END
    END bye;
  
  
  (* Folgende Prozedur fÑngt Dateifehler ab. *)
  
  PROCEDURE handleError0 (VAR f: File0; errNo: INTEGER; scan: ScanDesc);
    VAR index,retBut:CARDINAL;
        strVal:BOOLEAN;
        name: ARRAY [0..23] OF CHAR;
        str: ARRAY [0..31] OF CHAR;
        msg:ARRAY [0..99] OF CHAR;
    BEGIN
      InitChain (scan);
      Concat ('Dateifehler ', IntToStr (errNo, 0), msg, strVal);
      WrapAlert (msg, 0);
      index:= 1;
      InputScan (msg,index);
      Insert ("[3][",0,msg,strVal);
      Append ("][Quit|Cont]",msg,strVal);
      FormAlert (2, msg, retBut);
      IF retBut = 1 THEN
        TermProcess (MOSGlobals.FileSystemErr)
      ELSE
        (* Fehler ignorieren *)
      END
    END handleError0;
  
  
  (* Folgende Prozedur dient als Datenfeld mit allen Dateifehlertexten. *)
  
  PROCEDURE fileMessages;
    (*$L- : keinen Eingangscode erzeugen. *)
    BEGIN
      ASSEMBLER
          DC.W    32767  ; default fÅr undefinierte positive Fehlernummern:
                          ACZ 'Undefinierte Warnung: @'  ASC '        '
          DC.W    MOSGlobals.fNotDeleted
                          ACZ 'Datei war nicht vorhanden'  ASC '      '
          DC.W    MOSGlobals.fWasNotOpen
                          ACZ 'Datei war nicht geîffnet'  ASC '       '
          DC.W    MOSGlobals.fEOF
                          ACZ 'Dateiende erreicht'  ASC '             '
          DC.W    MOSGlobals.fEOL
                          ACZ 'Zeilenende erreicht'  ASC '            '
          DC.W    MOSGlobals.fOK
                          ACZ 'Kein Fehler'  ASC '                    '
          DC.W    MOSGlobals.fError
                          ACZ 'Allgemeiner Fehler'  ASC '             '
          DC.W    MOSGlobals.fDriveNotReady
                          ACZ 'Laufwerk nicht ansprechbar'  ASC '     '
          DC.W    MOSGlobals.fUnknownCmd
                          ACZ 'Unbekannte Funktion'  ASC '            '
          DC.W    MOSGlobals.fCRCError
                          ACZ 'PrÅfsummenfehler'  ASC '               '
          DC.W    MOSGlobals.fBadRequest
                          ACZ 'Unerlaubte Funktion'  ASC '            '
          DC.W    MOSGlobals.fSeekError
                          ACZ 'Disk defekt'  ASC '                    '
          DC.W    MOSGlobals.fUnknownMedia
                          ACZ 'Unbekanntes Disk-Format'  ASC '        '
          DC.W    MOSGlobals.fSectorNotFound
                          ACZ 'Sektor nicht vorhanden'  ASC '         '
          DC.W    MOSGlobals.fNoPaper
                          ACZ 'Drucker: Papierende'  ASC '            '
          DC.W    MOSGlobals.fWriteFault
                          ACZ 'Schreibfehler'  ASC '                  '
          DC.W    MOSGlobals.fReadFault
                          ACZ 'Lesefehler'  ASC '                     '
          DC.W    MOSGlobals.fGenError
                          ACZ 'Allgemeiner Disk-Fehler'  ASC '        '
          DC.W    MOSGlobals.fWriteProtected
                          ACZ 'Disk ist schreibgeschÅtzt'  ASC '      '
          DC.W    MOSGlobals.fMediaChanged
                          ACZ 'Disk wurde gewechselt'  ASC '          '
          DC.W    MOSGlobals.fUnknownDevice
                          ACZ 'Unbekanntes GerÑt'  ASC '              '
          DC.W    MOSGlobals.fBadSectorsOnFormat
                          ACZ 'Fehlerhafte Sektoren'  ASC '           '
          DC.W    MOSGlobals.fInsertOtherDisk
                          ACZ 'Disk wechseln (A<->B)'  ASC '          '
          DC.W    MOSGlobals.fInvalidFunctionNr
                          ACZ 'Unerlaubte Funktionsnummer'  ASC '     '
          DC.W    MOSGlobals.fFileNotFound
                          ACZ 'Datei existiert nicht'  ASC '          '
          DC.W    MOSGlobals.fPathNotFound
                          ACZ 'Directory existiert nicht'  ASC '      '
          DC.W    MOSGlobals.fTooManyOpen
                          ACZ 'Zu viele Dateien offen'  ASC '         '
          DC.W    MOSGlobals.fAccessDenied
                          ACZ 'Zugriff verwehrt'  ASC '               '
          DC.W    MOSGlobals.fInvalidHandle
                          ACZ 'Unerlaubte Zugriffskennung'  ASC '     '
          DC.W    MOSGlobals.fInsufficientMemory
                          ACZ 'Zu wenig Speicher'  ASC '              '
          DC.W    MOSGlobals.fInvalidMemBlkAddr
                          ACZ 'Speicherblock existiert nicht'  ASC '  '
          DC.W    MOSGlobals.fInvalidDrive
                          ACZ 'Unerlaubtes Laufwerk'  ASC '           '
          DC.W    MOSGlobals.fDiffDrives
                          ACZ 'Rename: verschiedene Laufwerke'  ASC ' '
          DC.W    MOSGlobals.fNoMoreFiles
                          ACZ 'Keine weiteren Dateien'  ASC '         '
          DC.W    MOSGlobals.fRangeError
                          ACZ 'BereichsÅberschreitung'  ASC '         '
          DC.W    MOSGlobals.fInternalError
                          ACZ 'Interner Fehler'  ASC '                '
          DC.W    MOSGlobals.fBadFormatOfPrg
                          ACZ 'Programmdatei defekt'  ASC '           '
          DC.W    MOSGlobals.fResizeFailure
                          ACZ 'Speicherblock nicht vergrîûbar'  ASC ' '
          DC.W    MOSGlobals.fOutOfMem
                          ACZ 'Zu wenig Speicher'  ASC '              '
          DC.W    MOSGlobals.fFileExists
                          ACZ 'Datei existiert schon'  ASC '          '
          DC.W    MOSGlobals.fNoReadAllowed
                          ACZ 'Lesezugriff nicht erlaubt'  ASC '      '
          DC.W    MOSGlobals.fFileNotClosed
                          ACZ 'Datei noch offen'  ASC '               '
          DC.W    MOSGlobals.fFileNotOpen
                          ACZ 'Datei nicht offen'  ASC '              '
          DC.W    MOSGlobals.fInternalErr1
                          ACZ 'Interner Fehler (Pos>Length)'  ASC '   '
          DC.W    MOSGlobals.fInternalErr2
                          ACZ 'Interner Fehler (2)'  ASC '            '
          DC.W    MOSGlobals.fBadOp
                          ACZ 'Zugriff in falschem Modus'  ASC '      '
          DC.W    MOSGlobals.fBadAccess
                          ACZ 'Zugriff nicht erlaubt'  ASC '          '
          DC.W    MOSGlobals.fEndOfFile
                          ACZ 'Dateiende Åberschritten'  ASC '        '
          DC.W    MOSGlobals.fDoubleUndo
                          ACZ "Wiederholter 'UndoRead'-Aufruf"  ASC ' '
          DC.W    MOSGlobals.fNameTooLarge
                          ACZ 'Dateiname zu lang'  ASC '              '
          DC.W    MOSGlobals.fDiskFull
                          ACZ 'Disk ist voll'  ASC '                  '
          DC.W    MOSGlobals.fIllegalCall
                          ACZ 'Unerlaubter Funktionsaufruf'  ASC '    '
          DC.W    -32768 ; default fÅr undefinierte negative Fehlernummern:
                          ACZ 'Undefinierter Fehler: @'  ASC '        '
          
          DC.W  0,0       ; Endekennzeichnung fÅr die Liste
      END
    END fileMessages;
    (*$L=*)
  
  
  (* Folgende Prozedur dient als Datenfeld mit allen Laufzeitfehlertexten. *)
  
  PROCEDURE errMessages;
    (*$L- : keinen Eingangscode erzeugen. *)
    BEGIN
      ASSEMBLER
          DC.W  -32768  ; default fÅr undefinierte Fehlernummern:
                          ACZ 'Undefinierter Fehler: @'  ASC '        '
  
          DC.W    MOSGlobals.GeneralErr
                          ACZ 'Genereller Fehler'  ASC '              '
          DC.W    MOSGlobals.BusFault
                          ACZ 'Adresse nicht ansprechbar'  ASC '      '
          DC.W    MOSGlobals.OddBusAddr
                          ACZ 'Zugriff auf ungerade Adresse'  ASC '   '
          DC.W    MOSGlobals.IllegalInstr
                          ACZ 'Unbekannte Maschinenanweisung'  ASC '  '
          DC.W    MOSGlobals.DivByZero
                          ACZ 'Division durch Null'  ASC '            '
          DC.W    MOSGlobals.OutOfRange
                          ACZ 'BereichsÅberschreitung'  ASC '         '
          DC.W    MOSGlobals.Overflow
                          ACZ 'öberlauf'  ASC '                       '
          DC.W    MOSGlobals.StringOverflow
                          ACZ 'String-öberlauf'  ASC '                '
          DC.W    MOSGlobals.NoValidRETURN
                          ACZ 'RETURN ohne gÅltiges Argument'  ASC '  '
          DC.W    MOSGlobals.OutOfStack
                          ACZ 'StackÅberlauf'  ASC '                  '
          DC.W    MOSGlobals.HALTInstr
                          ACZ 'HALT - Anweisung'  ASC '               '
          DC.W    MOSGlobals.FileSystemErr
                          ACZ 'Fehler im Dateisystem'  ASC '          '
          DC.W    MOSGlobals.OutOfMemory
                          ACZ 'UngenÅgend freier Speicher'  ASC '     '
          DC.W    MOSGlobals.IllegalCall
                          ACZ 'Unerlaubter Funktionsaufruf'  ASC '    '
          DC.W    MOSGlobals.CoroutineRtn
                          ACZ 'RÅckkehr aus Coroutine'  ASC '         '
          DC.W    MOSGlobals.InternalFault
                          ACZ 'Interner Fehler'  ASC '                '
          DC.W    MOSGlobals.IllegalProcVar
                          ACZ 'Undefinierte PROCEDURE-Var.'  ASC '    '
          DC.W    MOSGlobals.IllegalPointer
                          ACZ 'Uninitialisierte POINTER-Var.'  ASC '  '
          DC.W    MOSGlobals.UserBreak
                          ACZ 'Abbruch durch den Anwender'  ASC '     '
          DC.W    MOSGlobals.IllegalState
                          ACZ 'Interner Statusfehler'  ASC '          '
          DC.W    MOSGlobals.Exception
                          ACZ 'Diverse Exception'  ASC '              '
          DC.W    MOSGlobals.GenFPErr
                          ACZ 'Allg. Floating-Point Fehler'  ASC '    '
          DC.W    MOSGlobals.CaseSelectErr
                          ACZ 'UnerfÅllte CASE-Anweisung'  ASC '      '
          DC.W    MOSGlobals.ConfigErr
                          ACZ 'Fataler Konfigurationsfehler'  ASC '   '
          DC.W    MOSGlobals.IllegalClosure
                          ACZ 'Zuweisung lokaler Prozedur'  ASC '     '
          DC.W    MOSGlobals.GemErr
                          ACZ 'Fehler bei letztem GEM-Aufruf'  ASC '  '
          DC.W  0,0       ; Endekennzeichnung fÅr die Liste
      END
    END errMessages;
    (*$L=*)
  
  
  BEGIN
    (* Abfangen aller Fehlermeldungen: *)
    IF ~CatchErrors (bye, MEM(HdlErrorStack)) THEN OutOfMemory END;
    HandleError:= handleError0;
    FileErrMsg:= ADDRESS (fileMessages);
    RuntimeErrMsg:= ADDRESS (errMessages);
    
    NEW (LoaderMsg);
    IF LoaderMsg = NIL THEN OutOfMemory END;
    
    (* Fehlertexte des Moduls 'Loader' in Deutsch: *)
    LoaderMsg^[0]:=  '"@I" nicht vorhanden';
    LoaderMsg^[1]:=  '"@I" beim Importieren in "@C" nicht gefunden';
    LoaderMsg^[2]:=  '"@I" ist defekt';
    LoaderMsg^[3]:=  'Unerlaubte Daten in "@I"';
    LoaderMsg^[4]:=  'Unerlaubtes Layout von "@I"';
    LoaderMsg^[5]:=  'Versionskonflikt zwischen "@I" und "@C"';
    LoaderMsg^[6]:=  'Kein ausreichender Speicherplatz mehr';
    LoaderMsg^[7]:=  '"@I" ist resident und schon initialisiert';
    LoaderMsg^[8]:=  'Unerlaubter Modulname';
    LoaderMsg^[9]:=  'Zu viele verschachtelte Modulaufrufe';
    LoaderMsg^[10]:= 'Programm ist nicht ausfÅhrbar';
    LoaderMsg^[11]:= 'Programm nicht gefunden';
    LoaderMsg^[12]:= 'Laufzeitfehler wÑhrend Initialisierung';
    LoaderMsg^[13]:= 'Laufzeitfehler wÑhrend Deinitialisierung';
    LoaderMsg^[14]:= '"@I" ist komprimiert';
    LoaderMsg^[15]:= '"@I" hat falsches Real-Format';
    LoaderMsg^[16]:= '"@I": FPU nicht vorhanden';
    LoaderMsg^[17]:= 'Zu viele Module zu initialisieren';
  END simpleGEMError;  (* lokales Modul *)
(*$R=*)


VAR     pathArray: ARRAY [0..1] OF ARRAY [0..64] OF CHAR; (* global ! *)
        paths: Lists.List;

PROCEDURE initPaths;
  VAR err: BOOLEAN;
  BEGIN
    Lists.CreateList (paths,err);
    pathArray [0]:= '*\';           (* Aktueller Pfad *)
    pathArray [1]:= '*\..\IMP\';    (* Subdirectory "IMP" im Vorverzeichnis *)
    Lists.AppendEntry (paths,ADR(pathArray[0]),err);
    Lists.AppendEntry (paths,ADR(pathArray[1]),err);
  END initPaths;


VAR argc: CARDINAL;
    argv: ARRAY [0..1] OF PtrArgStr;
    exitcode: INTEGER;
    msg: ARRAY [0..99] OF CHAR;
    res: LoaderResults;
    button: CARDINAL;
    ok: BOOLEAN;
    devHdl: DeviceHandle;

BEGIN
  InitGem (RC, devHdl, ok);
  IF ok THEN
    initPaths;                    (* Suchpfade fÅr importierte Module setzen *)
    InitArgCV (argc, argv);         (* Name der angeklickten Datei ermitteln *)
    CallModule (argv[1]^, paths, '', NIL, exitcode, msg, res);
    IF res # noError THEN
      WrapAlert (msg, 0);
      Strings.Insert ('[0][', 0, msg, ok);
      Strings.Append ('][OK]', msg, ok);
      FormAlert (1, msg, button);
      exitcode:= -1
    END;
    TermProcess (exitcode)
  ELSE
    TermProcess (-39) (* out of memory *)
  END
END ExecMod.
