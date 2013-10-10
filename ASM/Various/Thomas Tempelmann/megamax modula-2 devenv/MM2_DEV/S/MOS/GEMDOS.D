DEFINITION MODULE GEMDOS;

(*
 * GEMDOS-Interface nach TDI V3.00
 * Mit Korrekturen und Erweiterungen von Thomas Tempelmann
 *
 * Die Dokumentation wurde direkt von TDI Åbernommen.
 *
 * Bei jeder Funktion steht im Kommentar zu Beginn ihr Originalname von Atari.
 *
 * Wichtig: Die Term-Routinen (Term0, Term, TermRes) sollte in der Regel
 *  nicht verwendet werden, sonst stattdessen TermProcess aus dem Modul
 *  PrgCtrl, denn sonst werden die Abmelderoutinen (s. CatchProcessTerm)
 *  unter bestimmten Betriebssystemen (KAOS, Mag!X) ggf. nicht ganz
 *  korrekt ausgefÅhrt, zumindest wird dann ein falscher Exit Code geliefert.
 *
 * 'SetOrGet' wurde durch eine korrekte, andere, Definition ersetzt.
 * 'Exec' wurde in 'Pexec' geÑndert, die Argumente sind nun ADDRESS-Types.
 * 'Term' hat kein BOOLEAN-Result mehr.
 * 'Super' hat eine neue Definition.
 * 'Alloc' hat einen LONGINT-Parameter, um auch -1 Åbergeben zu kînnen
 * 'Dup' und 'Force' hinzugefÅgt.
 * 'Xalloc' fÅr den Atari TT hinzugefÅgt.
 *)


FROM SYSTEM IMPORT BYTE, ADDRESS;

CONST
  (* BIOS error codes *)
  EOK           =   0;
  Error         =  -1;
  EDrvNR        =  -2;         (* Drive not ready *)
  EUnCmd        =  -3;         (* Unknown command *)
  ECRC          =  -4;         (* CRC error *)
  EBadRq        =  -5;         (* Bad request *)
  ESeek         =  -6;         (* Seek error *)
  EMedia        =  -7;         (* Unknown media *)
  ESecNF        =  -8;         (* Sector not found *)
  EPaper        =  -9;         (* No paper *)
  EWritF        = -10;         (* Write fault *)
  EReadF        = -11;         (* Read fault *)
  EGenrl        = -12;         (* General error *)
  EWrPro        = -13;         (* Write protect *)
  EChng         = -14;         (* Media change *)
  EUnDev        = -15;         (* Unknown device *)
  EBadSF        = -16;         (* Bad sectors on format *)
  EOther        = -17;         (* Insert other disk *)

  (* BDOS Error codes *)
  EInvFN        = -32;         (* Invalid function number *)
  EFilNF        = -33;         (* File not found *)
  EPthNF        = -34;         (* Path not found *)
  ENHndl        = -35;         (* No handles left *)
  EAccDn        = -36;         (* Access denied *)
  EIHndl        = -37;         (* Invalid handle *)
  ENSMem        = -39;         (* Insufficient memory *)
  EIMBA         = -40;         (* Invalid memory block address *)
  EDrive        = -46;         (* Invaild drive specified *)
  ENMFil        = -49;         (* No more files *)

  (* Other errors *)
  ERange        = -64;         (* Range error *)
  EIntrn        = -65;         (* Internal error *)
  EPLFmt        = -66;         (* Invalid program load format *)
  EGSBF         = -67;         (* Setblock failure due to growth restr *)

  (*** Konstanten fÅr 'Pexec' ***)

  loadExecute = 0;
  load = 3;
  execute = 4;
  createBasepage = 5;
  executeAndFree = 6;  (* neuer Modus ab TOS 1.4 *)
  createBPwMode  = 7;  (* neuer Modus bei Atari TT *)

  (*** Modi fÅr 'Xalloc': ***)

  stRAMonly = 0;
  fastRAMonly = 1;
  stRAMprefered = 2;
  fastRAMprefered = 3;


TYPE

  IOMode = (read, write);
  SeekMode = (beginning, relative, end);

(*
 * Diese Type wurde eingeklammert, weil sie falsch von TDI
 * definiert wurde. Stattdessen ist die folg. Definition zu verwenden!
 *
 * SetOrGet = ( set, get );
 *)

  TimeAccessMode = ( getTime, setTime );

  DiskInfoBuffer = RECORD
                     freeSpace  : LONGCARD; (* in clusters *)
                     clusters   : LONGCARD; (* num on disk *)
                     sectorSize : LONGCARD; (* in bytes *)
                     clusterSize: LONGCARD; (* sectors per cluster *)
                   END;

PROCEDURE OldTerm ();
(* Achtung: In der Regel stattdessen 'TermProcess(0)' benutzen! *)

PROCEDURE ConIn ( VAR Ch: CHAR );
(* 'Cconin': Read character from standard input *)

PROCEDURE ConScanIn ( VAR Ch, Scan: CHAR );
(* 'Cconin': Read character and scan code from standard input *)

PROCEDURE ConOut ( Ch: CHAR );
(* 'Cconout': Write character to standard output *)

PROCEDURE AuxIn ( VAR Ch: CHAR );
(* 'Cauxin': Read character from auxiliary port *)

PROCEDURE AuxOut ( Ch: CHAR );
(* 'Cauxout': Write character to auxiliary port *)

PROCEDURE PrnOut ( Ch: CHAR );
(* 'Cprnout': Write character to printer port *)

PROCEDURE RawIO ( VAR Ch: CHAR; Mode: IOMode );
(* 'Crawio': Raw IO to standard input/output device *)

PROCEDURE RawIn ( VAR Ch: CHAR );
(* 'Crawcin': Raw input from standard input *)

PROCEDURE RawScanIn ( VAR Ch, Scan: CHAR );
(* 'Crawcin': Raw input of character and scan code from standard input *)

PROCEDURE NecIn ( VAR Ch: CHAR );
(* 'Cnecin': Read character from standard input with no echo *)

PROCEDURE ConWS ( REF String: ARRAY OF CHAR );
(* 'Cconws': Write null terminated string to standard output device *)

PROCEDURE ConRS ( VAR String: ARRAY OF BYTE );
(* 'Cconws': Read edited string from standard input device *)

PROCEDURE ConIS (): BOOLEAN;
(* 'Cconis': Return status of standard input *)

PROCEDURE SetDrv ( Drive: CARDINAL; VAR DriveMap: LONGCARD );
(* 'Dsetdrv': Set default drive *)

PROCEDURE ConOS (): BOOLEAN;
(* 'Cconos': Return output status of standard output *)

PROCEDURE PrnOS (): BOOLEAN;
(* 'Cprnos': Return output status of standard printer *)

PROCEDURE AuxIS (): BOOLEAN;
(* 'Cauxis': Return status of standard auxiliary *)

PROCEDURE AuxOS (): BOOLEAN;
(* 'Cauxos': Return output status of standard auxiliary *)

PROCEDURE GetDrv ( VAR Drive: CARDINAL );
(* 'Dgetdrv': Get default drive *)

PROCEDURE SetDTA ( Address: ADDRESS );
(* 'Fsetdta': Set disk transfer address *)

PROCEDURE GetDate ( VAR Date: CARDINAL );
(* 'Tgetdate': Get Date *)

PROCEDURE SetDate ( Date: CARDINAL );
(* 'Tsetdate': Set Date *)

PROCEDURE GetTime ( VAR Time: CARDINAL );
(* 'Tgettime': Get Date *)

PROCEDURE SetTime ( Time: CARDINAL );
(* 'Tsettime': Set Date *)

PROCEDURE GetDTA ( VAR Addr: ADDRESS );
(* 'Fgetdta': Get disk transfer address *)

PROCEDURE Version ( VAR Ver: CARDINAL );
(* 'Sversion': Get version number *)

PROCEDURE TermRes ( NumBytes: LONGCARD; ExitCode: INTEGER );
(* 'Ptermres': Terminate and stay resident *)

PROCEDURE DFree (VAR InfoBuffer: DiskInfoBuffer; Drive: CARDINAL );
(* 'Dfree': Get drive free space *)

PROCEDURE DirCreate ( REF Path: ARRAY OF CHAR ): BOOLEAN;
(* 'Dcreate': Create a subdirectory *)

PROCEDURE DirDelete ( REF Path: ARRAY OF CHAR ): BOOLEAN;
(* 'Ddelete': Delete a subdirectory *)

PROCEDURE SetPath ( REF Path: ARRAY OF CHAR ): BOOLEAN;
(* 'Dsetpath': Set current directory *)

PROCEDURE Create ( REF Name: ARRAY OF CHAR; Attr: CARDINAL;
                   VAR Handle: INTEGER  );
(* 'Fcreate': Create a file *)

PROCEDURE Open ( REF Name: ARRAY OF CHAR; Mode: CARDINAL;
                 VAR Handle: INTEGER );
(* 'Fopen': Open a file *)

PROCEDURE Close ( Handle: INTEGER ): BOOLEAN;
(* 'Fclose': Close a file *)

PROCEDURE Read ( Handle: INTEGER; VAR Count: LONGCARD; Buffer: ADDRESS );
(* 'Fread': Read file *)

PROCEDURE Write ( Handle: INTEGER; VAR Count: LONGCARD; Buffer: ADDRESS );
(* 'Fwrite': Write file *)

PROCEDURE Delete ( REF Name: ARRAY OF CHAR ): BOOLEAN;
(* 'Fdelete': Delete file *)

PROCEDURE Seek ( Offset: LONGINT; Handle: INTEGER; Mode: SeekMode;
                 VAR Position: LONGINT );
(* 'Fseek': Seek file pointer *)

PROCEDURE Attrib ( REF Name: ARRAY OF CHAR; getOrSet: TimeAccessMode;
                   VAR Attr: CARDINAL );
(* 'Fattrib': Get/Set file attributes *)

PROCEDURE Dup ( stdHandle: INTEGER; VAR newHandle: INTEGER );
(* 'Fdup': Liefert eine Kopie eines Standard-Handles (0-5) *)

PROCEDURE Force ( stdHandle, newHandle: INTEGER ): BOOLEAN;
(* 'Fforce': LÑût 'stdHandle' auf 'newHandle' verweisen *)

PROCEDURE GetPath ( VAR PathName: ARRAY OF CHAR; Drive: CARDINAL );
(* 'Dgetpath': Get current directory *)

PROCEDURE Alloc ( Bytes: LONGINT; VAR Addr: ADDRESS );
(* 'Malloc': Allocate memory, 'bytes = -1' returns amount of largest block *)

PROCEDURE Free ( Addr: ADDRESS ): BOOLEAN;
(* 'Mfree': Free memory *)

PROCEDURE Shrink ( Addr: ADDRESS; NewSize: LONGCARD ): BOOLEAN;
(* 'Mshrink': Shrink size of allocated memory *)

PROCEDURE Pexec ( Mode: CARDINAL; Name, Arguments, Environment: ADDRESS;
                  VAR Result: LONGINT );
(* 'Pexec': Load or execute a process *)

PROCEDURE Term ( Code: INTEGER );
(* Achtung: In der Regel stattdessen 'TermProcess(Code)' benutzen! *)

PROCEDURE SFirst ( REF Name: ARRAY OF CHAR; Attr: CARDINAL;
                   VAR Result: INTEGER );
(* 'Fsfirst': Search for first file *)

PROCEDURE SNext ( VAR Result: INTEGER );
(* 'Fsnext': Search for next file *)

PROCEDURE Rename ( REF CurrentName, NewName: ARRAY OF CHAR );
(* 'Frename': Rename a file *)

PROCEDURE DaTime ( Handle: INTEGER; Buffer: ADDRESS; getOrSet: TimeAccessMode );
(* 'Fdatime': Get/Set file date and time stamp *)

PROCEDURE Super (stack: LONGINT): LONGINT;
(* 'Super':
 * Ist 'stack' Null, wird in den Supervisormode gelangt und ein Wert
 * geliefert, der beim ZurÅckschalten in den Usermode hier wieder angegeben
 * werden muû.
 * Ist 'stack' Eins, wird der aktuelle Modus geliefert: Null fÅr den
 * Usermode, -1 fÅr den Supervisormode.
 *)

PROCEDURE Xalloc ( Bytes: LONGINT; mode: CARDINAL; VAR Addr: ADDRESS );
(* 'Mxalloc': Erweiterte Alloc-Funktion fÅr den Atari TT. *)

END GEMDOS.
