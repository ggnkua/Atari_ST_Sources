IMPLEMENTATION MODULE GEMError;
(*$B+,Y+,M-,S-,R-*)

(*
 * Hilfsmodul zum Abfangen und Anzeigen von Laufzeitfehlern.
 * Auûerdem werden alle Fehlertextvariablen mit deutschen Texten initialisiert.
 *
 * 25.10.88 TT  SysInitGem / CatchRemoval-Aufruf
 * 07.11.88 TT  LoaderMsg [7] verbessert
 * 17.06.89 TT  Fehler GenFPErr aufgenommen
 * 19.08.89 TT  Fehler CaseSelectErr und NoErr aufgenommen
 * 28.09.90 TT  'bye'-Funktion besser dokumentiert
 * 17.01.94 TT  LoaderMsg [16] verbessert
 *)

IMPORT MOSGlobals;
FROM Storage IMPORT ALLOCATE;
FROM SystemError IMPORT OutOfMemory;
FROM MOSGlobals IMPORT MemArea, BusFault, OddBusAddr, NoValidRETURN, OutOfStack;
FROM SysBuffers IMPORT HdlErrorStack;
FROM AESForms IMPORT FormAlert;
FROM GEMEnv IMPORT GemHandle, ExitGem, CurrGemHandle, SysInitApplication;
FROM Strings IMPORT String, Pos, Delete, Assign, Insert, Concat, Copy, Length,
        Empty, Space, Append, Upper;
FROM SYSTEM IMPORT ASSEMBLER, LONGWORD, WORD, ADDRESS, BYTE, ADR;
FROM SysTypes IMPORT ExcDesc, ScanDesc;
FROM FileBase IMPORT CloseFile, HandleError;
FROM Files IMPORT File, ResetState, Close, Remove, GetStateMsg, State,
                GetFileName;
FROM StrConv IMPORT CardToStr, StrToLCard, IntToStr, LHexToStr;
FROM PrgCtrl IMPORT TermProcess;
FROM ResCtrl IMPORT RemovalCarrier, CatchRemoval;
FROM HdlError IMPORT GetErrorMsg, ReleaseCatcher, SysCatchErrors;
FROM ErrBase IMPORT RtnCond, ErrResp;
FROM MOSConfig IMPORT LoaderMsg, RuntimeErrMsg, FileErrMsg;
FROM ShellMsg IMPORT ScanMode, ScanAddr, TextName, ErrorMsg, DefPaths,
        ModPaths, Active, ScanIndex, ImpPaths, SrcPaths;
FROM GEMScan IMPORT InputScan, InitChain, CallingChain;
FROM MOSCtrl IMPORT ModLevel;
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

(* english messages:
        DC.W    32767  ; default fÅr undefinierte positive Fehlernummern:
                        ACZ 'Undefined warning: @'  ASC '           '
        DC.W    MOSGlobals.fNotDeleted
                        ACZ 'File did not exist'  ASC '             '
        DC.W    MOSGlobals.fWasNotOpen
                        ACZ 'File wasn't open'  ASC '               '
        DC.W    MOSGlobals.fEOF
                        ACZ 'End of file'  ASC '                    '
        DC.W    MOSGlobals.fEOL
                        ACZ 'End of line'  ASC '                    '
        DC.W    MOSGlobals.fOK
                        ACZ 'No error'  ASC '                       '
        DC.W    MOSGlobals.fError
                        ACZ 'General error'  ASC '                  '
        DC.W    MOSGlobals.fDriveNotReady
                        ACZ 'Drive not ready'  ASC '                '
        DC.W    MOSGlobals.fUnknownCmd
                        ACZ 'Unknown command'  ASC '                '
        DC.W    MOSGlobals.fCRCError
                        ACZ 'CRC error'  ASC '                      '
        DC.W    MOSGlobals.fBadRequest
                        ACZ 'Bad request'  ASC '                    '
        DC.W    MOSGlobals.fSeekError
                        ACZ 'Seek error'  ASC '                     '
        DC.W    MOSGlobals.fUnknownMedia
                        ACZ 'Unknown media'  ASC '                  '
        DC.W    MOSGlobals.fSectorNotFound
                        ACZ 'Sector not found'  ASC '               '
        DC.W    MOSGlobals.fNoPaper
                        ACZ 'Out of paper'  ASC '                   '
        DC.W    MOSGlobals.fWriteFault
                        ACZ 'Write fault'  ASC '                    '
        DC.W    MOSGlobals.fReadFault
                        ACZ 'Read fault'  ASC '                     '
        DC.W    MOSGlobals.fGenError
                        ACZ 'General disk error'  ASC '             '
        DC.W    MOSGlobals.fWriteProtected
                        ACZ 'Disk is write-protected'  ASC '        '
        DC.W    MOSGlobals.fMediaChanged
                        ACZ 'Media change detected'  ASC '          '
        DC.W    MOSGlobals.fUnknownDevice
                        ACZ 'Unknown device'  ASC '                 '
        DC.W    MOSGlobals.fBadSectorsOnFormat
                        ACZ 'Bad sectors on format'  ASC '          '
        DC.W    MOSGlobals.fInsertOtherDisk
                        ACZ 'Insert other disk'  ASC '              '
        DC.W    MOSGlobals.fInvalidFunctionNr
                        ACZ 'Invalid function number'  ASC '        '
        DC.W    MOSGlobals.fFileNotFound
                        ACZ 'File not found'  ASC '                 '
        DC.W    MOSGlobals.fPathNotFound
                        ACZ 'Path not found'  ASC '                 '
        DC.W    MOSGlobals.fTooManyOpen
                        ACZ 'Handle pool exhausted'  ASC '          '
        DC.W    MOSGlobals.fAccessDenied
                        ACZ 'Access denied'  ASC '                  '
        DC.W    MOSGlobals.fInvalidHandle
                        ACZ 'Invalid handle'  ASC '                 '
        DC.W    MOSGlobals.fInsufficientMemory
                        ACZ 'Insufficient memory'  ASC '            '
        DC.W    MOSGlobals.fInvalidMemBlkAddr
                        ACZ 'Invalid memory block address'  ASC '   '
        DC.W    MOSGlobals.fInvalidDrive
                        ACZ 'Invalid drive specification'  ASC '    '
        DC.W    MOSGlobals.fDiffDrives
                        ACZ 'Rename: different drives spec.'  ASC ' '
        DC.W    MOSGlobals.fNoMoreFiles
                        ACZ 'No more files'  ASC '                  '
        DC.W    MOSGlobals.fRangeError
                        ACZ 'Range error'  ASC '                    '
        DC.W    MOSGlobals.fInternalError
                        ACZ 'GEMDOS internal error'  ASC '          '
        DC.W    MOSGlobals.fBadFormatOfPrg
                        ACZ 'Invalid executable file format'  ASC ' '
        DC.W    MOSGlobals.fResizeFailure
                        ACZ 'Memory block growth failure'  ASC '    '
        DC.W    MOSGlobals.fOutOfMem
                        ACZ 'Insufficient memory'  ASC '            '
        DC.W    MOSGlobals.fFileExists
                        ACZ 'File exists'  ASC '                    '
        DC.W    MOSGlobals.fNoReadAllowed
                        ACZ 'Read access not allowed'  ASC '        '
        DC.W    MOSGlobals.fFileNotClosed
                        ACZ 'File not closed'  ASC '                '
        DC.W    MOSGlobals.fFileNotOpen
                        ACZ 'File not opened'  ASC '                '
        DC.W    MOSGlobals.fInternalErr1
                        ACZ 'Internal error (Pos>Length)'  ASC '    '
        DC.W    MOSGlobals.fInternalErr2
                        ACZ 'Internal error (2)'  ASC '             '
        DC.W    MOSGlobals.fBadOp
                        ACZ 'Bad access mode'  ASC '                '
        DC.W    MOSGlobals.fBadAccess
                        ACZ 'Read or write not allowed here'  ASC ' '
        DC.W    MOSGlobals.fEndOfFile
                        ACZ 'End of file reached'  ASC '            '
        DC.W    MOSGlobals.fDoubleUndo
                        ACZ "Repeated 'UndoRead' call"  ASC '       '
        DC.W    MOSGlobals.fNameTooLarge
                        ACZ 'File name too long'  ASC '             '
        DC.W    MOSGlobals.fDiskFull
                        ACZ 'Disk full'  ASC '                      '
        DC.W    MOSGlobals.fIllegalCall
                        ACZ 'Illegal function call'  ASC '          '
        DC.W    -32768 ; default fÅr undefinierte negative Fehlernummern:
                        ACZ 'Undefined error: @'  ASC '             '
*)
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

(*  English (?) error messages:
        DC.W  -32768  ; default fÅr undefinierte Fehlernummern:
                        ACZ 'Undefined error: @'  ASC '             '
        DC.W  MOSGlobals.NoErr
                        ACZ 'No error'  ASC '                       '
        DC.W  MOSGlobals.GeneralErr
                        ACZ 'General error'  ASC '                  '
        DC.W  MOSGlobals.BusFault
                        ACZ 'Bus error'  ASC '                      '
        DC.W  MOSGlobals.OddBusAddr
                        ACZ 'Address error'  ASC '                  '
        DC.W  MOSGlobals.IllegalInstr
                        ACZ 'Illegal instruction'  ASC '            '
        DC.W  MOSGlobals.DivByZero
                        ACZ 'Division by zero'  ASC '               '
        DC.W  MOSGlobals.OutOfRange
                        ACZ 'Out of range'  ASC '                   '
        DC.W  MOSGlobals.Overflow
                        ACZ 'Overflow'  ASC '                       '
        DC.W  MOSGlobals.StringOverflow
                        ACZ 'String overflow'  ASC '                '
        DC.W  MOSGlobals.NoValidRETURN
                        ACZ 'No valid RETURN from function'  ASC '  '
        DC.W  MOSGlobals.OutOfStack
                        ACZ 'Out of stack space'  ASC '             '
        DC.W  MOSGlobals.HALTInstr
                        ACZ 'HALT encountered'  ASC '               '
        DC.W  MOSGlobals.FileSystemErr
                        ACZ 'Error in file system'  ASC '           '
        DC.W  MOSGlobals.OutOfMemory
                        ACZ 'Out of memory'  ASC '                  '
        DC.W  MOSGlobals.IllegalCall
                        ACZ 'Illegal function call'  ASC '          '
        DC.W  MOSGlobals.CoroutineRtn
                        ACZ 'Return from coroutine'  ASC '          '
        DC.W  MOSGlobals.InternalFault
                        ACZ 'Internal error'  ASC '                 '
        DC.W  MOSGlobals.IllegalProcVar
                        ACZ 'Undefined PROCEDURE variable'  ASC '   '
        DC.W  MOSGlobals.IllegalPointer
                        ACZ 'Undefined pointer variable'  ASC '     '
        DC.W  MOSGlobals.UserBreak
                        ACZ 'Interrupt by user'  ASC '              '
        DC.W  MOSGlobals.IllegalState
                        ACZ 'Internal state fault'  ASC '           '
        DC.W  MOSGlobals.Exception
                        ACZ 'Unspecified exception'  ASC '          '
        DC.W  MOSGlobals.GenFPErr
                        ACZ 'General Floating-Point error'  ASC '   '
        DC.W  MOSGlobals.CaseSelectErr
                        ACZ 'CASE selection error'  ASC '           '
        DC.W  MOSGlobals.ConfigErr
                        ACZ 'Fatal configuration error'  ASC '      '
        DC.W  MOSGlobals.IllegalClosure
                        ACZ 'Assignment of local procedure'  ASC '  '
        DC.W  MOSGlobals.GemErr
                        ACZ 'Error at last GEM-call'  ASC '         '
*)

        DC.W  0,0       ; Endekennzeichnung fÅr die Liste
    END
  END errMessages;
  (*$L=*)


VAR stck: MemArea;
    rHdl: RemovalCarrier;
    ok: BOOLEAN;
    gemHdl: GemHandle;

PROCEDURE freeSys;
  BEGIN
    ExitGem (gemHdl);
    ReleaseCatcher (bye)
  END freeSys;

BEGIN
  SysInitApplication (ok);
  gemHdl:= CurrGemHandle ();
  CatchRemoval (rHdl, freeSys, stck);

  (* Abfangen aller Fehlermeldungen: *)
  stck.bottom := ADR (HdlErrorStack);
  stck.length := SIZE (HdlErrorStack);
  IF ~SysCatchErrors (bye,stck) THEN OutOfMemory END;
  CloseFile:= closeFile0;
  HandleError:= handleError0;
  FileErrMsg:= ADDRESS (fileMessages);
  RuntimeErrMsg:= ADDRESS (errMessages);
  
  NEW (LoaderMsg);
  IF LoaderMsg = NIL THEN OutOfMemory END;
  
  (* Fehlertexte des Moduls 'Loader' in Englisch:
  LoaderMsg^[0]:=  "Can't find @I";
  LoaderMsg^[1]:=  'Importing @I into @C: file not found';
  LoaderMsg^[2]:=  'File @I is physically damaged';
  LoaderMsg^[3]:=  'Illegal data in @I';
  LoaderMsg^[4]:=  'Bad layout of @I';
  LoaderMsg^[5]:=  'Conflict of versions between @I and @C';
  LoaderMsg^[6]:=  'Out of memory';
  LoaderMsg^[7]:=  '@I is resident'; (* linked / schon initialisiert *)
  LoaderMsg^[8]:=  'Illegal module name';
  LoaderMsg^[9]:=  'Nesting of module calls too deep';
  LoaderMsg^[10]:= 'Program can't be executed';
  LoaderMsg^[11]:= 'Program not found';
  LoaderMsg^[12]:= 'Initialization of environment failed';
  LoaderMsg^[13]:= 'De-initialization of environment failed';
  LoaderMsg^[14]:= '"@I" is compressed';
  LoaderMsg^[15]:= '"@I" has wrong real format';
  LoaderMsg^[16]:= '"@I": wrong FPU type (ST<->TT)';
  LoaderMsg^[17]:= 'Too many modules to initialize';
  *)
  
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
  LoaderMsg^[16]:= '"@I": falscher FPU-Typ (ST<->TT)';
  LoaderMsg^[17]:= 'Zu viele Module zu initialisieren';

END GEMError.
