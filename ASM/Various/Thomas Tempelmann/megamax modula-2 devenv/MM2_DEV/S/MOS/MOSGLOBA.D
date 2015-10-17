DEFINITION MODULE MOSGlobals;

FROM SYSTEM IMPORT LOC, ADDRESS;

TYPE    MemArea = RECORD                (* Definiert einen Speicherbereich: *)
                    bottom: ADDRESS;    (* Startadresse *)
                    length: LONGCARD    (* LÑnge in Bytes *)
                  END;

PROCEDURE MEM (VAR data: LONGARRAY OF LOC): MemArea;
  (*
   * Liefert die Speicherbereichs-Beschreibung einer Variablen.
   * Ist ggf. bequemer anzuwenden, als ADR und SIZE der Variable
   * einzeln zu ermitteln.
   *)

TYPE
        CtrlKey = ( shift, control, alternate, capsLock );
        CtrlSet = SET OF CtrlKey;

        Key = RECORD
                ch  : CHAR;
                ctrl: CtrlSet;
                scan: CARDINAL;
              END;


        FileStr  = ARRAY [0..139] OF CHAR; (* Datei- & Pfadname *)
        DriveStr = ARRAY [0..1] OF CHAR;   (* Laufwerksname *)
        PathStr  = ARRAY [0..127] OF CHAR; (* Pfadname (incl. Laufwerk) *)
        NameStr  = ARRAY [0..11] OF CHAR;  (* Dateiname ohne Pfad *)
        PfxStr   = ARRAY [0..7] OF CHAR;   (* Prefix (Name ohne Extension) *)
        SfxStr   = ARRAY [0..2] OF CHAR;   (* Suffix (Extension) ohne '.' *)

        Drive = ( defaultDrv, drvA, drvB, drvC, drvD, drvE, drvF, drvG,
                  drvH, drvI, drvJ, drvK, drvL, drvM, drvN, drvO, drvP);

        DriveSet = SET OF [drvA..drvP];


        Date = RECORD
                 day  : [1..31];
                 month: [1..12];
                 year : INTEGER;
               END;

        Time = RECORD
                 second: [0..59];
                 minute: [0..59];
                 hour  : [0..23]
               END;


CONST

  (* Laufzeit-Fehlernummern *)

        NoErr          =  0;  (* Kein Fehler *)
        GeneralErr     = -1;  (* Nicht nÑher spezifizierter Fehler *)
        BusFault       = -2;  (* Zugriff auf nicht existente Adresse *)
        OddBusAddr     = -3;  (* Wortweiser Zugriff auf ungerade Adresse *)
        IllegalInstr   = -4;  (* CPU traf auf unbekannte Instruktion *)
        DivByZero      = -5;  (* Division durch Null *)
        OutOfRange     = -6;  (* Variable auûerhalb des definierten Bereichs *)
        Overflow       = -7;  (* öberlauf bei einer Berechnung *)
        StringOverflow = -8;  (* String oder Open Array faût Daten nicht *)
        NoValidRETURN  = -9;  (* RÅckkehr aus Funktion ohne WertrÅckgabe *)
        OutOfStack     = -10; (* StackÅberlauf *)
        HALTInstr      = -11; (* HALT - Breakpoint erreicht *)
        FileSystemErr  = -12; (* Fehler im Dateisystem *)
        OutOfMemory    = -13; (* Kein genÅgender Speicherplatz mehr *)
        IllegalCall    = -14; (* Unerlaubter Aufruf (ggf. falsche Argumente) *)
        CoroutineRtn   = -15; (* RÅckkehr aus Coroutine *)
        InternalFault  = -16; (* Interner Fehler *)
        IllegalProcVar = -17; (* Undefinierte PROCEDURE - Variable *)
        IllegalPointer = -18; (* Uninitialisierte POINTER - Variable *)
        UserBreak      = -19; (* Abbruch vom Anwender *)
        IllegalState   = -20; (* Interner Statusfehler *)
        Exception      = -21; (* CPU erzeugte diverse Exception *)
        GenFPErr       = -22; (* Allg. Floating-Point Fehler *)
        CaseSelectErr  = -23; (* Nicht erfÅllter CASE-Fall *)
        ConfigErr      = -24; (* Allg. Konfigurationsfehler, z.B. keine FPU *)
        IllegalClosure = -25; (* Zuweisung lokaler Proz. an Proc-Variable *)
        GemErr         = -26; (* GEM-Fehler trat auf (s. GEMEnv.ErrorProc) *)


  (* Datei-Fehlernummern (Files, Text, NumberIO, Binary, Directory *)

        (* Von MM2 (intern) definiert: *)
        fNoMatchingFiles = 5;     (* Directory.DirQuery: Verz. ist leer *)
        fNotDeleted = 4;          (* Directory.Delete: Datei nicht vorhanden *)
        fWasNotOpen = 3;          (* Files.Close: Datei war nicht offen *)
        fEOF = 2;                 (* Dateiende erreicht *)
        fEOL = 1;                 (* Zeilenende erreicht *)
        
        (* Von GEMDOS definiert: *)
        fOK = 0;                  (* Kein Fehler *)
        fError = -1;              (* Allgemeiner Fehler, z.B. Timeout *)
        fDriveNotReady = -2;      (* Laufwerk nicht ansprechbar *)
        fUnknownCmd = -3;         (* Unbekannte Funktion *)
        fCRCError = -4;           (* PrÅfsummenfehler *)
        fBadRequest = -5;         (* Unerlaubte Funktionsanforderung *)
        fSeekError = -6;          (* Diskzugriff: Medium defekt *)
        fUnknownMedia = -7;       (* Diskzugriff: Unbekanntes Format *)
        fSectorNotFound = -8;     (* Diskzugriff: Sektor nicht vorhanden *)
        fNoPaper = -9;            (* Drucker: Papier fehlt *)
        fWriteFault = -10;        (* Diskzugriff: Schreibfehler *)
        fReadFault = -11;         (* Diskzugriff: Lesefehler *)
        fGenError = -12;          (* Diskzugriff: Allgemeiner Fehler *)
        fWriteProtected = -13;    (* Diskzugriff: Schreibschutz aktiv *)
        fMediaChanged = -14;      (* Diskzugriff: Diskette wurde gewechselt *)
        fUnknownDevice = -15;     (* Unbekanntes GerÑt *)
        fBadSectorsOnFormat = -16;(* Fehlerhafte Sektoren beim Formatieren *)
        fInsertOtherDisk = -17;   (* Andere Disk (A: <-> B:) einlegen *)
        fInvalidFunctionNr = -32; (* Unerlaubte Funktionsnummer *)
        fFileNotFound = -33;      (* Datei nicht gefunden *)
        fPathNotFound = -34;      (* Directory nicht gefunden *)
        fTooManyOpen = -35;       (* Zu viele Dateien geîffnet *)
        fAccessDenied = -36;      (* Zugriff verwehrt *)
        fInvalidHandle = -37;     (* Unerlaubte Zugriffskennung *)
        fInsufficientMemory = -39;(* Zu wenig Speicher *)
        fInvalidMemBlkAddr = -40; (* Unbekannte Speicherblockadresse *)
        fInvalidDrive = -46;      (* Unerlaubtes Laufwerk *)
        fDiffDrives = -48;        (* Rename: Quell- und Ziel-LW sind versch. *)
        fNoMoreFiles = -49;       (* Fsnext(): Keine weiteren Dateien *)
        fRangeError = -64;        (* BereichsÅberschreitung *)
        fInternalError = -65;     (* Interner Fehler *)
        fBadFormatOfPrg = -66;    (* Illegales Format der Programmdatei *)
        fResizeFailure = -67;     (* Speicherblock nicht vergrîûbar *)

        (* Von MM2 (intern) definiert: *)
        fOutOfMem = -128;         (* Nicht genÅgend Speicherplatz frei *)
        fFileExists = -129;       (* Datei existiert schon *)
        fNoReadAllowed = -130;    (* Lesezugriff nicht erlaubt *)
        fFileNotClosed = -131;    (* Datei noch offen *)
        fFileNotOpen = -132;      (* Datei nicht offen *)
        fInternalErr1 = -133;     (* Interner Fehler *)
        fInternalErr2 = -134;     (* Interner Fehler *)
        fBadOp = -136;            (* Zugriff in falschem Modus *)
        fBadAccess = -137;        (* Lese- bzw. Schreibzugriff nicht erlaubt *)
        fEndOfFile = -138;        (* Dateiende Åberschritten *)
        fDoubleUndo = -139;       (* Wiederholter 'UndoRead'-Aufruf *)
        fNameTooLarge = -140;     (* Dateiname zu lang *)
        fDiskFull = -141;         (* Kein Speicherplatz auf Disk mehr *)
        fIllegalCall = -142;      (* Unerlaubter Funktionsaufruf *)

END MOSGlobals.
