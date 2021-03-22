MODULE ModLoad; (*$E MAC  -> Linker erzeugt ACC-Endung *)

(*
 * Loadtime Linker zum Starten der Module ohne die MM2Shell.
 *
 * Wird dieses Modul gelinkt (Treiber: "M2Init", "GEMIO" oder ein anderer
 * InOut-Treiber; Optimierung: keine oder nur Prozedurnamen entfernen),
 * kann es vom Desktop gestartet (Endung PRG oder APP) oder als Accessory
 * mit der Endung ACC auf das Bootlaufwert installiert werden.
 *
 * Dabei bleibt es resident und hÑngt sich in den GEMDOS-Trap-Handler ein,
 * um die Pexec-Aufrufe zu Åberwachen. Damit allerdings importierte Module
 * gefunden werden, mÅssen noch die Pfade, auf denen auf dem verwendeten
 * Rechner-System die Code-Module liegen, im lokalen Modul 'MyPaths' (s.u.,
 * Aufrufe der Prozedur 'append') eingetragen werden.
 *
 * So ist es mîglich, alle Megamax-Module unter dem Desktop oder auch von
 * anderen Programmen aus (z.B. GEMINI) zu starten. Dies erspart dem Anwender,
 * die Module extra zu PRG-Dateien zusammenzulinken.
 * Besonders fÅr Anwender ohne Festplatte lÑût sich das oft benîtigte Starten
 * der Modula-Shell vereinfachen. Dazu muû die MM2Shell nur zu einem Modul
 * compiliert werden. Sie kann dann zusammen mit Compiler und Editor resident
 * gemacht (geladen) werden. Wird die Shell verlassen, wird ein erneuter
 * Aufruf der Shell innerhalb von 2-3 Sekunden durchgefÅhrt (lediglich die
 * Resource-Datei und die Parameter- und Batch-Dateien mÅssen noch jedesmal
 * geladen werden).
 *
 * Damit die Module vom Desktop aus zu starten sind, mÅssen sie als Programm-
 * dateien ausgewiesen werden. Dazu sind mit einem Editor (nicht den Gepard-
 * Editor verwenden!) in die Datei 'DESKTOP.INF' folgende Zeilen einzufÅgen
 * (ohne die AnfÅhrungszeichen - vergleiche die schon darin existierenden
 * Zeilen f. 'PRG', 'TOS', usw!):
 *
 * "#G 03 FF   *.MOD@ @ "  bestimmt ausfÅhrbare GEM-Programme;
 * "#F 03 04   *.MOS@ @ "  bestimmt ausfÅhrbare TOS-Programme;
 * "#P 03 04   *.MTP@ @ "  bestimmt ausfÅhrbare TTP-Programme.
 *
 * Beim Neustart des Rechners sollten dann alle Module auf dem Desktop mit
 * dem Programm-Symbol angezeigt werden. Ist ModLoad installiert, kann
 * jedes andere Modul vom Desktop aus mit einem Doppelklick gestartet werden
 * (z.B. der Compiler).
 *
 * Sollen Module, wie z.B. die Shell, geladen werden, ist beim Doppelklick
 * die Control-Taste festzuhalten; bei Freigabe ist ebenfalls auf das ge-
 * wÅnschte Modul doppelt zu klicken und sowohl die Control- als auch die
 * linke Shift-Taste zu drÅcken. Beides kann natÅrlich auch Åber die als
 * Modul gestartete Shell in gewohnter Weise durchgefÅhrt werden: MM2Shell
 * kann sich sowohl selbst 'laden' als daû sie auch wieder 'entladen'
 * werden kann, indem sie aus dem Resident-Fenster in den MÅlleimer gezogen
 * wird - dann wird zwar angezeigt, das Modul wÑre nicht freigegeben worden,
 * aber das liegt ja auch daran, daû die Shell noch aktiv ist - sobald sie
 * aber verlassen wird, wird sie auch freigegeben und beim nÑchsten Start
 * muû sie wieder von Disk gelesen werden.
 *
 * Beim Start des Programms liest es die Datei "MODLOAD.INF", die sich im
 * selben Verzeichnis wie ModLoad befinden muû. Darin kînnen Module und
 * Programme zeilenweise aufgelistet werden, die ModLoad dann automatisch
 * lÑdt. Die Module mÅssen ggf. mit vollst. Pfad und Endung angegeben sein.
 * Werden die spÑter benîtigten Module gleich beim Start von ModLoad Åber
 * die INF-Datei geladen, kann nebenbei auch ein ÅbermÑûiges ZerstÅckeln
 * des freien Speichers vermieden werden.
 *
 * öbrigens: NatÅrlich kînnen auch normale, gelinkte Programme geladen
 * werden - ganz wie in der Shell. Das liegt daran, daû fÅr die ganze
 * Programm-/Modulverwaltung einfach der Loader benutzt wird.
 *
 * Wird 'TOS Fehler #35' (oder so) beim Doppelklick eines Moduls angezeigt,
 * so ist dieses Programm (ModLoad) nicht installiert.
 *
 * Da das alles natÅrlich viel Speicher verschlingt, kann auch alles wieder
 * bei Belieben freigegeben werden, indem 'MODLOAD.PRG' erneut durch Doppel-
 * klick gestartet wird (geht nicht, wenn ModLoad als Accessory installiert
 * ist oder beim TOS auf dem TT). Dabei dÅrfte kein Diskzugriff stattfinden
 * und danach sind alle Module inclusive ModLoad wieder entfernt.
 *
 * Dies Programm kînnte noch verbessert werden: Es kînnte die Pfadliste
 * aus einer Datei lesen, auch kînnten darin Module/Programme eingetragen
 * sein, die automatisch beim Start geladen werden.
 * Wenn man die Funktionen der MM2Shell, wie die das Setzen der Parameter
 * fÅr Compiler, Linker usw, durch kleine Programme ersetzt, kann vîllig
 * auf die MM2Shell verzichtet werden - dann kann jede beliebige Shell
 * als Entwicklungsumgebung verwendet werden, ohne auf die Vorteile des
 * Loadtime Linkings und der Laufzeitumgebung verzichten zu mÅssen.
 * Als alternative Shell bietet sich besonders das Shareware-Produkt
 * "GEMINI" an.
 *
 * Wenn Sie dieses Programm erweitert oder Sie gar ein paar Hilfsprogramme
 * fÅr die Arbeit mit anderen Shells erstellt haben, wenden Sie sich doch
 * bitte damit an uns (oder den Vertrieb), wir wÅrden es gerne auch anderen
 * MM2-Anwendern zukommen lassen (z.B. Åber den MeMoX-Service).
 *
 * Wenn Sie eine Shell-Einbindung vorhaben, sich das aber nicht allein
 * zutrauen, dann wenden Sie sich erst recht an uns! Wir freuen uns, Ihnen
 * dabei unter die Arme zu greifen. Megamax Modula-2 ist schlieûlich mit
 * genau dieser Philosophie entwickelt worden: Wir wollen Ihnen mit unserem
 * Know-How beim Programmieren die bestmîgliche UnterstÅtzung bieten!
 *
 *----------------------------------------------------------------------------
 * 22.10.88  TT       Grunderstellung
 * 21.12.88  TT  1.0  Fertigstellung mit Doku
 * 04.07.89  TT  1.1  LÑuft nun fehlerfrei mit neuem Loader/ModBase/ModCtrl
 *                      vom 4.7.89.
 * 03.05.90  TT  1.2  Anpassung an System 2.2
 * 17.08.90  TT       $Y+ hinzugefÅgt
 * 10.11.90  TT       XBRA-Kennung "ModL" eingefÅgt.
 * 21.11.90  TT  1.3  Modul 'GEMError' eingefÅgt; kleine Korrekturen; nun auch
 *                    als Accessory installierbar (einfach Endung auf .ACC
 *                    Ñndern); Stack fÅr Loader wird per Malloc() reserviert,
 *                    so daû es keine Probleme mehr mit dem Stack geben dÅrfte;
 *                    die Datei "MODLOAD.INF" wird eingelesen und alle darin
 *                    enthaltenen Dateien als Module/Programme geladen.
 * 28.02.91  TT  1.4  LÑuft nun auch auf dem Atari TT / hyperCACHE 030.
 *                    UnterstÅtzt ARGV-Methode.
 *)

(*$Y+,R-,S-*)

FROM SYSTEM IMPORT
  CADR, ASSEMBLER, CAST, ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD;

IMPORT BIOS, XBIOS;

FROM SysInfo IMPORT
  UseStackFrame;

FROM AESWindows IMPORT
  UpdateWindow;

FROM ModCtrl IMPORT
  GetOwnName, FirstModuleStart, ReleaseModule, InstallModule;

FROM MOSGlobals IMPORT
  MemArea;

FROM StorBase IMPORT
  FullStorBaseAccess, MemSize;

FROM Storage IMPORT ALLOCATE;

IMPORT Strings;

FROM FileNames IMPORT
  SplitPath, SplitName;

FROM Console IMPORT
  Write, WriteLn, WriteString, KeyPressed, FlushKbd;

FROM AESMisc IMPORT
  ShellFind;

FROM Files IMPORT
  File, Open, Close, EOF, State, Access;

FROM Text IMPORT
  ReadString, ReadLn;

FROM Loader IMPORT
  DefaultStackSize, LoadModule, UnLoadModule, CallModule, LoaderResults;

FROM AESWindows IMPORT
  DeskHandle, ScreenBuffer;

FROM GEMEnv IMPORT
  GemActive, GemError, InitApplication, ExitApplication;

FROM EasyGEM0 IMPORT
  FormAlert, WrapAlert;

FROM AESEvents IMPORT MessageEvent, MessageBuffer, accOpen;
FROM AESMenus IMPORT RegisterAcc;
FROM PrgCtrl IMPORT Accessory;

FROM MOSCtrl IMPORT
  ProcessID, ModLevel, PtrPDB, GetPDB;

IMPORT XBRA, Lists, PrgCtrl;

IMPORT MOSGlobals, SystemError, SysBuffers, SysTypes, FileBase, Files,
       StrConv, ResCtrl, HdlError, ErrBase, MOSConfig, SysCtrl, ShellMsg,
       GEMScan;


CONST  LoaderStackSize = 16000; (* Stackgrîûe fÅr Aufruf des Loaders *)

       Kennung = 'ModL';  (* XBRA-Kennung *)

       MyName = "ModLoad";


MODULE GEMError;

(*
 * lokales Modul. Kopie aus "GEMERROR.I"
 *)

IMPORT MOSGlobals, SystemError, ALLOCATE;
FROM MOSGlobals IMPORT MEM, MemArea, BusFault, OddBusAddr, NoValidRETURN,
        OutOfStack;
FROM SysBuffers IMPORT HdlErrorStack;
IMPORT FormAlert;
IMPORT InitApplication, ExitApplication;
FROM Strings IMPORT String, Pos, Delete, Assign, Insert, Concat, Copy, Length,
        Empty, Space, Append, Upper;
IMPORT ASSEMBLER, LONGWORD, WORD, ADDRESS, BYTE, ADR;
FROM SysTypes IMPORT ExcDesc, ScanDesc;
FROM FileBase IMPORT CloseFile, HandleError;
FROM Files IMPORT File, ResetState, Close, Remove, GetStateMsg, State,
                GetFileName;
FROM StrConv IMPORT CardToStr, StrToLCard, IntToStr, LHexToStr;
FROM PrgCtrl IMPORT TermProcess, EnvlpCarrier, SysSetEnvelope;
FROM ResCtrl IMPORT RemovalCarrier, CatchRemoval;
FROM HdlError IMPORT GetErrorMsg, ReleaseCatcher, CatchErrors;
FROM ErrBase IMPORT RemoveExc, RtnCond, ErrResp;
FROM MOSConfig IMPORT LoaderMsg, RuntimeErrMsg, FileErrMsg;
FROM ShellMsg IMPORT ScanMode, ScanAddr, TextName, ErrorMsg, DefPaths,
        ModPaths, Active, ScanIndex, ImpPaths, SrcPaths;
FROM GEMScan IMPORT InputScan, InitChain, CallingChain;
IMPORT ModLevel;
FROM SysCtrl IMPORT ExcToScanAddr;

VAR strVal:BOOLEAN;

PROCEDURE prepare (VAR msg: ARRAY OF CHAR; mayCont: BOOLEAN; index: CARDINAL;
                   VAR mayEdit: BOOLEAN);
  BEGIN
    Insert ('[0][',0,msg,strVal);
    Append ('][Quit',msg,strVal);
    IF mayCont THEN
      Append ('|Cont',msg,strVal)
    END;
    mayEdit:= Active & (ModLevel>1) & ~Empty (CallingChain [index].modName);
    IF mayEdit THEN
      Append ('|Scan',msg,strVal)
    END;
    Append (']',msg,strVal);
  END prepare;


(* Folgende Funktion fÑngt allgemeine Laufzeitfehler ab. *)

PROCEDURE bye(nr: INTEGER; msg: ARRAY OF CHAR; causer: ErrResp;
              cont: RtnCond; VAR info: ExcDesc): BOOLEAN;
  
  VAR scan: ScanDesc;
      msg1:ARRAY [0..133] OF CHAR; (* reicht f. 4 Zeilen *)
      showAddr,
      mayCont,
      mayEdit: BOOLEAN;
      defBut, index, button:CARDINAL;
      relad:LONGCARD;
      str,
      mname:ARRAY [0..31] OF CHAR;
  BEGIN
    (* Fehlermeldung vorbereiten *)
    IF Empty (msg) THEN  (* Wurde ein Text Åbergeben? *)
      GetErrorMsg (nr,str) (* Nein, dann Standardtext verwenden *)
    ELSE
      Assign (msg,str,strVal)
    END;
    (* bei Bus- und Adreûfehlern soll auch die Zugriffsadr. angezeigt werden:*)
    showAddr:= (nr=BusFault) OR (nr=OddBusAddr);
    (* Scanner-Record vorbereiten: *)
    ExcToScanAddr (info, scan);
    (* Start-Tiefe bei Scanner-Anzeige festlegen *)
    IF causer=callerCaused THEN
      index:= 1
    ELSE
      index:= 0
    END;
    mayCont:= cont=mayContinue;
    (*
     * Nun Text fÅr FormAlert-Meldung bei 'InputScan' vorbereiten
     *)
    IF showAddr THEN
      Concat (str,'| auf ',msg1,strVal);
      Append (LHexToStr(info.accessAddr,0),msg1,strVal)
    ELSE
      Assign (str,msg1,strVal)
    END;
    (* Aufruferkette erstellen *)
    InitChain (scan);
    (* Scanner starten *)
    InputScan (msg1,index);
    (*
     * Nun Meldung "Quit|Cont|Scan" vorbereiten und anzeigen
     *)
    Append ( Space (22 - INTEGER (Length (str))), msg1, strVal);
    prepare (msg1, mayCont, index, mayEdit);
    FormAlert (1+ORD(mayEdit)+ORD(mayCont), msg1, button);
    (*
     * Zuletzt Programm beenden, fortfÅhren oder Scanning des Compilers starten
     *)
    IF button = 2+ORD(mayCont) THEN (* Scan *)
      (* f. Scanning des Compilers werden einige Vars gesetzt, damit *
       * die Shell bei ProgrammrÅckkehr sofort die Aktion startet.   *)
      ScanMode := TRUE;
      ScanIndex:= index;
      Assign (str,ErrorMsg,strVal);
      TermProcess (nr)
    ELSIF button = 1 THEN (* Quit *)
      TermProcess (nr)
    ELSE (* Cont *)
      RETURN FALSE
    END
  END bye;


(* Folgende Prozedur fÑngt Dateifehler ab. *)

PROCEDURE handleError0 (VAR f:File; errNo: INTEGER; scan: ScanDesc);
  VAR index,retBut:CARDINAL;
      mayEdit: BOOLEAN;
      name: ARRAY [0..23] OF CHAR;
      str: ARRAY [0..31] OF CHAR;
      msg:ARRAY [0..109] OF CHAR;
  BEGIN
    GetStateMsg (errNo,str);
    Concat ('Dateifehler:|',str,msg,strVal);
    InitChain (scan);
    index:= 1;
    InputScan (msg,index);
    Append ("|Datei: ",msg,strVal);
    GetFileName (f,name);
    Append (name,msg,strVal);
    prepare (msg, TRUE, index, mayEdit);
    FormAlert (2+ORD(mayEdit), msg, retBut);
    IF retBut = 1 THEN
      TermProcess (MOSGlobals.FileSystemErr)
    ELSIF retBut = 3 THEN
      ScanMode := TRUE;
      ScanIndex:= index;
      Assign (str,ErrorMsg,strVal);
      TermProcess (MOSGlobals.FileSystemErr)
    ELSE
      ResetState (f)
    END
  END handleError0;


(* Folgende Prozedur zeigt bei Prozeûende offen gebliebene Dateien an. *)

PROCEDURE closeFile0 (f: File; new:BOOLEAN);
  VAR res: INTEGER;
      retBut:CARDINAL;
      msg1,msg: ARRAY [0..99] OF CHAR;
      name: ARRAY [0..23] OF CHAR;
      ch: CHAR;
      strVal:BOOLEAN;
  BEGIN
    GetFileName (f,name);
    Concat ('Datei ',name,msg,strVal);
    Append ('|wurde nicht geschlossen.',msg,strVal);
    IF new THEN
      msg1 := '[1][][Schlieûen|Lîschen]';
    ELSE
      msg1 := '[1][][Schlieûen]';
    END;
    Insert (msg,4,msg1,strVal);
    FormAlert (1,msg1,retBut);
    IF retBut=1 THEN
      Close (f);
      res:= State (f);
      IF res<0 THEN
        GetStateMsg (res,msg);
        Insert ("[1][Fehler beim Schlieûen:|",0,msg,strVal);
        Append ("][ OK ]",msg,strVal);
        FormAlert (1,msg,retBut)
      END
    ELSE
      Remove (f)
    END
  END closeFile0;


(* Folgende Prozedur dient als Datenfeld mit allen Dateifehlertexten. *)

PROCEDURE fileMessages;
  (*$L- : keinen Eingangscode erzeugen. *)
  BEGIN
    ASSEMBLER
(* deutsche Meldungen: *)
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
                        ACZ 'Unbekanntes GerÑt o. Laufwerk'  ASC '  '
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
        DC.W    MOSGlobals.NoErr
                        ACZ 'Kein Fehler'  ASC '                    '
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
                        ACZ 'Fehlende RETURN-Anweisung'  ASC '      '
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
                        ACZ 'Div. Floating-Point Fehler'  ASC '     '
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


VAR rHdl: RemovalCarrier;
    level: CARDINAL;

PROCEDURE envelope (open, child: BOOLEAN; VAR exitcode: INTEGER);
  VAR appOK: BOOLEAN;
  BEGIN
    IF child THEN
      IF open THEN
        IF level = 0 THEN
          InitApplication (appOK);
          IF NOT appOK THEN
            exitcode:= MOSGlobals.fInternalError
          ELSE
            IF NOT CatchErrors (bye,MEM(HdlErrorStack)) THEN
              exitcode:= MOSGlobals.fInsufficientMemory
            END;
          END;
        END;
        INC (level)
      ELSE
        DEC (level);
        IF level = 0 THEN
          ExitApplication ();
          ReleaseCatcher (bye);
          RemoveExc; (* Exc-Handler wieder entfernen *)
        END
      END
    END
  END envelope;

VAR ec: EnvlpCarrier;

BEGIN
  level:= 0;
  CloseFile:= closeFile0;
  HandleError:= handleError0;
  FileErrMsg:= ADDRESS (fileMessages);
  RuntimeErrMsg:= ADDRESS (errMessages);
  SysSetEnvelope (ec, envelope, MemArea {NIL,0});

  (*
   * Den Exception-Handler, der automatisch vom HdlError-Modul eingerichtet
   * wurde, falls dies Prg nicht als Accessory sondern vom Desktop gestartet
   * wird, erstmal wieder entfernen. Bei Aufruf von 'CatchErrors' (s.o.)
   * wird er automatisch wieder installiert.
   *)
  RemoveExc;

  NEW (LoaderMsg);
  IF LoaderMsg = NIL THEN SystemError.OutOfMemory END;

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
  
END GEMError;


MODULE MyPaths;

  IMPORT ADDRESS, ADR;
  IMPORT MemArea;
  IMPORT Lists, Strings;

  EXPORT QUALIFIED init, exit, paths;

  CONST   pathSize = 64;  (* -- Dieser Wert darf verÑndert werden -- *)
          maxPath = 10;   (* -- Dieser Wert darf verÑndert werden -- *)

  VAR     pathArray: ARRAY [1..maxPath] OF ARRAY [0..pathSize] OF CHAR;
          paths: Lists.List;
          err: BOOLEAN;
          idx: CARDINAL;

  PROCEDURE append (REF name: ARRAY OF CHAR);
    VAR ok: BOOLEAN;
    BEGIN
      IF Strings.Length (name) >= pathSize THEN
        HALT (* Pfadname ist zu groû ! >> 'pathSize' erhîhen ! *)
      ELSE
        IF idx < maxPath THEN
          INC (idx);
          Strings.Assign (name, pathArray [idx], ok);
          Lists.AppendEntry (paths, ADR(pathArray[idx]), err);
          IF err THEN HALT END
        ELSE
          HALT (* Zuviele Pfadnamen ! >> 'maxPath' erhîhen ! *)
        END
      END
    END append;

  PROCEDURE exit;
    VAR dummy: ADDRESS;
    BEGIN
      Lists.ResetList (paths);
      dummy:= Lists.PrevEntry (paths);
      REPEAT
        Lists.RemoveEntry (paths, err)
      UNTIL err;
      Lists.DeleteList (paths, err);
      IF err THEN HALT END
    END exit;

  PROCEDURE init;
    BEGIN
      Lists.CreateList (paths, err);
      IF err THEN HALT END;
      idx:= 0;
      append ('.\');              (* Dieser Pfad sollte immer dabei sein *)
      (* Und dann noch weitere Pfade in denen sich IMPs befinden... *)
      append ('D:\NEW\CA\IMP\');
    END init;

  END MyPaths;


TYPE PtrPexecPar = POINTER TO RECORD
                     mode: (loadExec, unused1, unused2, load, exec, create);
                     fileName: ADDRESS;
                     arg: ADDRESS;
                     env: ADDRESS
                   END;

VAR
  myUpperName: Strings.String;
  path: ARRAY [0..127] OF CHAR;
  arg: ARRAY [0..128] OF CHAR;
  baseProcess: ADDRESS;
  entry, at: ADDRESS;
  carrier: XBRA.Carrier;
  stackhi: ADDRESS;
  doingPexec: BOOLEAN;
  ok: BOOLEAN;
  stackFrameOffs: SHORTCARD;



PROCEDURE Alert (s: ARRAY OF CHAR; wait: BOOLEAN);

  VAR button: CARDINAL;
      ok: BOOLEAN;
      msg: ARRAY [0..250] OF CHAR;

  BEGIN
    Strings.Assign (s, msg, ok);
    (*
      (* Meldung als TOS-Text ausgeben *)
      WriteLn;
      WriteString (msg);
      WriteLn;
      IF wait THEN
        WriteString ('Press a key...');
        WriteLn;
        REPEAT UNTIL KeyPressed (); FlushKbd;
      END
    *)
    (* Meldung mit FormAlert-Dialog anzeigen *)
    WrapAlert (msg, 0);
    Strings.Insert ('[0][', 0, msg, ok);
    Strings.Append ('][ OK ]', msg, ok);
    FormAlert (1, msg, button);
  END Alert;


PROCEDURE release;
  BEGIN
    (* TRAP #1 wieder freigeben *)
    IF XBRA.Installed (Kennung, $84, at) THEN
      XBRA.Remove (at);
    END;
    ReleaseModule;
  END release;

PROCEDURE hdlPexec (par: PtrPexecPar; VAR exitCode: LONGINT): BOOLEAN;
  (* Return: FALSE: alte Pexec-Funktion aufrufen, sonst Trap beenden *)

  PROCEDURE getArg (dosArg: ADDRESS; VAR txt: ARRAY OF CHAR);
    (*
     * Wandelt Pexec-Argumentzeile in String um
     *)
    BEGIN
      ASSEMBLER
        MOVE.L  dosArg(A6),A0           ; A0: dosArg
        MOVE.L  txt(A6),A1              ; A1: ADR (txt)
        CLR     D0
        MOVE.B  (A0)+,D0                ; LÑnge der Arg-Zeile
        CMPI.B  #$7F,D0                 ; ARGV-öbergabe?
        BNE     c
        MOVE.B  D0,(A1)+                ; bei ARGV das LÑngenbyte Åbernehmen
        BRA     c
      l MOVE.B  (A0)+,(A1)+             ; Zeile kopieren
      c DBRA    D0,l
        CLR.B   (A1)                    ; String-Ende mit 0C abschlieûen
      END
    END getArg;

  VAR fn: POINTER TO ARRAY [0..141] OF CHAR;
      prgname: ARRAY [0..11] OF CHAR;
      sfx: ARRAY [0..2] OF CHAR;
      msg: ARRAY [0..99] OF CHAR;
      result: LoaderResults;
      exitCode2: INTEGER;
      ok: BOOLEAN;
      ch: CHAR;

  BEGIN (* hdlPexec *)
    fn:= par^.fileName;
    SplitPath (fn^, path, prgname);
    SplitName (prgname, prgname, sfx);
    Strings.Upper (prgname);
    IF Strings.StrEqual (myUpperName, prgname) THEN
      (* Erneuter Start dieses Programms -> Freigeben *)
      Alert ('ModLoad is de-installed', TRUE);
      IF Accessory () THEN
        Alert ("But the Accessory's memory won't be deallocated", TRUE);
      END;
      release;
      RETURN TRUE
    ELSE
      IF (BIOS.ControlKey IN BIOS.GetKBShift ()) THEN
        IF BIOS.LeftShift IN BIOS.GetKBShift () THEN
          UnLoadModule (prgname, result);
          Strings.Assign (prgname, arg, ok);
          IF result = noError THEN
            Strings.Append (' is unloaded', arg, ok);
          ELSE
            Strings.Append (' has still clients!', arg, ok)
          END;
          Alert (arg, TRUE);
        ELSE
          MyPaths.init;
          LoadModule (fn^, MyPaths.paths, arg, msg, result);
          MyPaths.exit;
          IF result = noError THEN
            Strings.Append (' is loaded', arg, ok)
          ELSE
            Strings.Append (" couldn't be loaded", arg, ok)
          END;
          Alert (arg, TRUE)
        END;
        RETURN TRUE
      ELSE
        getArg (par^.arg, arg);
        MyPaths.init; (* Suchpfade setzen *)
        CallModule (fn^, MyPaths.paths, arg, NIL, exitCode2, msg, result);
        MyPaths.exit;
        IF result = noError THEN
          IF exitCode2 >= 0 THEN
            exitCode:= LONG (exitCode2)
          ELSE
            exitCode:= LONG (exitCode2) + 65536
          END
        ELSIF result = notFound THEN
          exitCode:= -33
        ELSIF result = outOfMemory THEN
          exitCode:= -39
        ELSE
          exitCode:= -1;
          Alert (msg, TRUE)
        END;
        RETURN TRUE
      END;
    END;
  END hdlPexec;


VAR regStack: ARRAY [1..256] OF WORD; (* Stack fÅr Register-Sicherung (´KB) *)

PROCEDURE hdlGemdos;
  (*$L-*)
  BEGIN
    ASSEMBLER
        BTST.B  #5,(A7)         ; War Supervisormode aktiv ?
        BNE.B   super           ; Ja, dann stehen Arg. auf SSP
        MOVE.L  USP,A0
        CMPI.W  #$4B,(A0)       ; Pexec - Funktion ?
        BEQ.B   hdlPexecUser
dos     ; normale GEMDOS-Funktion ausfÅhren
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
        
noPexec ; prÅfen, ob Prg gestartet & ausgefÅhrt werden soll.
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
        MOVE.L  A1,USP          ; den regStack auch fÅr Malloc-Aufruf nutzen
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

        ; Parameter fÅr 'hdlPexec' auf den Parm-Stack (A3) laden
        MOVE.L  A0,(A3)+        ; Adr. der Parameter Åbergeben
        LEA     exitCode(PC),A0
        MOVE.L  A0,(A3)+        ; Adr. der exitCode-Variable Åbergeben
        MOVE    #1,doingPexec   ; Flag gegen Wiedereintritt setzen
        JSR     hdlPexec        ; Pexec-Sonderbehandlung
        CLR.W   doingPexec
        MOVE.W  -(A3),D0        ; Pexec-RÅckgabewert (BOOLEAN = 2 Byte)

        ; Modula-Stack wieder freigeben
        MOVE.L  stackhi,A7      ; regStack wieder fÅr SP verwenden
        MOVE.W  D0,-(A7)
        MOVE.L  A3,-(A7)
        MOVE    #$49,-(A7)      ; Mfree()
        TRAP    #1
        ADDQ.L  #6,A7
        
        ; zurÅck in den Supervisor-Mode:
        CLR.L   -(A7)
        MOVE    #$20,-(A7)      ; Super (0L)
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.W  (A7)+,D0
        
        MOVE.L  A7,A1
        MOVE.L  (A1)+,A7        ; SSP zurÅck
        MOVE.L  (A1)+,A0        ; USP zurÅck
        MOVE.L  A0,USP
        TST.W   stackFrameOffs  ; StackFrame vorhanden?
        BEQ     noSF2           ; nein
        MOVE.W  (A1)+,-(A7)     ; StackFrame zurÅck
noSF2:  MOVE.L  (A1)+,-(A7)     ; PC zurÅck
        MOVE.W  (A1)+,-(A7)     ; SR zurÅck
        MOVEM.L (A1)+,D1-D7/A2-A6
        MOVE.L  A1,stackhi

        TST.W   D0              ; hdlPexec-RÅckgabewert prÅfen
        BEQ     dos             ; Wurde nicht ausgefÅhrt -> GEMDOS aufrufen
        
        MOVE.L  exitCode(PC),D0 ; Exitcode laden
        RTE                     ; und zurÅck zum Aufrufer

exitCode: DS    4               ; 4 Byte fÅr Exitcode reservieren
    END
  END hdlGemdos;
  (*$L=*)

PROCEDURE readInfFile;
  (*
   * Liest die Datei "MODLOAD.INF" und lÑdt die darin angegebenen Module.
   *)
  
  VAR f: File;
      s: Strings.String;
      msg: ARRAY [0..99] OF CHAR;
      result: LoaderResults;
  
  BEGIN
    s:= 'MODLOAD.INF';
    ShellFind (s);
    IF NOT GemError () THEN
      MyPaths.init; (* Suchpfade setzen *)
      Open (f, s, readSeqTxt);
      WHILE NOT EOF (f) DO
        ReadString (f, s);        (* String am Zeilenbeginn einlesen *)
        ReadLn (f);               (* Zeilenende Åberlesen *)
        LoadModule (s, MyPaths.paths, s, msg, result) (* Datei laden *)
      END;
      Close (f);
      MyPaths.exit
    END
  END readInfFile;
  
PROCEDURE initMsg;
  BEGIN
    Alert ('ModLoad 1.4 is installed. Written by Thomas Tempelmann with Megamax Modula-2', FALSE);
  END initMsg;

VAR termwsp: MemArea;
    pdb: PtrPDB;
    pr: ADDRESS;
    msg: MessageBuffer;
    menuID: CARDINAL;

BEGIN
  IF UseStackFrame () THEN stackFrameOffs:= 2 ELSE stackFrameOffs:= 0 END;
  baseProcess:= ProcessID^;
  doingPexec:= FALSE;
  DefaultStackSize:= 16000;
  (* 'hdlGemdos' in TRAP #1 einhÑngen *)
  IF NOT XBRA.Installed (Kennung, $84 (* GEMDOS/TRAP#1 *), at) THEN
    XBRA.Create (carrier, Kennung, CAST (ADDRESS, hdlGemdos), entry);
    XBRA.Install (entry, at);
    stackhi:= ADR (regStack) + SIZE (regStack);
    GetPDB (pdb, pr);
    myUpperName:= MyName;
    Strings.Upper (myUpperName);
    IF NOT Accessory () THEN
      Alert ('PrgLoad lÑuft nur als Accessory!', TRUE)
    ELSE
      InitApplication (ok);
      IF NOT ok THEN HALT END;
      RegisterAcc (CADR ("  "+MyName), menuID, ok);
      UpdateWindow (TRUE);
      readInfFile;
      UpdateWindow (FALSE);
      LOOP
        MessageEvent (msg);
        IF (msg.msgType = accOpen) THEN
          initMsg;
        END
      END
    (*
    ELSE
      (* resident installieren *)
      termwsp.bottom:= NIL;
      InstallModule (release, termwsp);        (* Modul resident machen *)
      readInfFile;
      initMsg;
    *)
    END
  END
END ModLoad.
