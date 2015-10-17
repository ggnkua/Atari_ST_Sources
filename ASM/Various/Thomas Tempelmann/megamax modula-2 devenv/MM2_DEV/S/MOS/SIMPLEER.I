IMPLEMENTATION MODULE SimpleError;
(*$R-,Y+,S-,M-,B+*)

(*$S-  StackprÅfung hier unnîtig, da seine Grîûe bereits bestimmt ist. *)

(*
   Hilfsmodul zum Abfangen und Anzeigen von Laufzeitfehlern.

   GegenÅber GEMError werden
     - keine Fehlertexte f. Loader-Fehler und allg. Laufzeitfehler
       initialisiert,
     - keine automatisch erkannten Dateifehler angezeigt sondern ignoriert,
     - keine Prozedur- oder Modulnamen bei einem Fehler angezeigt,
     - kein Error-Scan ermîglicht,
     - Bei Bus- und Adreûfehlern nicht die Zugriffsadr. angezeigt.

  25.10.88  TT  SysCatchErrors statt CatchErrors
  14.05.90  TT  Dateifehlermeldungen werden initialisiert
  25.07.90  TT  Normale Laufzeitfehlermeldungen werden auch initialisiert
*)


FROM SYSTEM IMPORT ASSEMBLER, LONGWORD, WORD, ADDRESS, BYTE, ADR;
FROM SystemError IMPORT OutOfMemory;
FROM SysBuffers IMPORT HdlErrorStack;
FROM PrgCtrl IMPORT TermProcess;
FROM ResCtrl IMPORT RemovalCarrier, CatchRemoval;
IMPORT MOSGlobals;
FROM Strings IMPORT Assign, Insert, Concat, Empty, Append;
FROM SysTypes IMPORT ExcDesc;
FROM HdlError IMPORT GetErrorMsg, ReleaseCatcher, SysCatchErrors;
FROM ErrBase IMPORT RtnCond, ErrResp;
FROM MOSConfig IMPORT RuntimeErrMsg, FileErrMsg;


PROCEDURE FormAlert (but: CARDINAL; msg: ADDRESS): CARDINAL;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0        ; msg
        LEA     Data(PC),A1
        LEA     24(A1),A2
        MOVE.L  A0,(A2)
        MOVE.L  A2,16(A1)
        ADDQ    #4,A2
        MOVE.L  A2,8(A1)
        MOVE    -(A3),(A2)+     ; Default Button-Nr.
        MOVE.L  A2,12(A1)
        MOVE.L  A2,-(A7)
        ADDQ    #2,A2
        MOVE.L  A2,4(A1)
        LEA     Control(PC),A0
        MOVE.L  A0,(A1)
        CLR.L   10(A2)
        MOVE.L  A1,D1
        MOVE    #$C8,D0
        TRAP    #2
        MOVE.L  (A7)+,A0
        MOVE    (A0),(A3)+
        RTS

Control DC.W    52,1,1,1,0,0
Data    DS      52
    END
  END FormAlert;
  (*$L=*)


(* Folgende Funktion fÑngt allgemeine Laufzeitfehler ab. *)

PROCEDURE bye (nr: INTEGER; msg: ARRAY OF CHAR; causer: ErrResp;
               cont: RtnCond; VAR info: ExcDesc): BOOLEAN;

  VAR strVal: BOOLEAN;
      str: ARRAY [0..81] OF CHAR;

  BEGIN
    IF Empty (msg) THEN
      GetErrorMsg (nr, str)
    ELSE
      Assign (msg,str,strVal)
    END;
    Insert ('[3][', 0, str, strVal);
    Append ('][Quit',str,strVal);
    IF cont = mayContinue THEN
      Append ('|Cont',str,strVal)
    END;
    Append (']',str,strVal);
    IF FormAlert (1, ADR (str)) = 1 THEN (* Quit *)
      TermProcess (nr)
    ELSE (* Cont *)
      RETURN FALSE
    END
  END bye;
  (*$S=*)

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
        DC.W    MOSGlobals.GemErr
                        ACZ 'Error at last GEM-call'  ASC '         '
*)

        DC.W  0,0       ; Endekennzeichnung fÅr die Liste
    END
  END errMessages;
  (*$L=*)

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

PROCEDURE freeSys;
  BEGIN
    ReleaseCatcher (bye)
  END freeSys;

VAR stck: MOSGlobals.MemArea;
    rHdl: RemovalCarrier;

BEGIN
  CatchRemoval (rHdl, freeSys, stck);
  (* Abfangen aller Fehlermeldungen: *)
  stck.bottom := ADR (HdlErrorStack);
  stck.length := SIZE (HdlErrorStack);
  IF ~SysCatchErrors (bye, stck) THEN OutOfMemory END;
  FileErrMsg:= ADDRESS (fileMessages);
  RuntimeErrMsg:= ADDRESS (errMessages);
END SimpleError.
