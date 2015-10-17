
IMPLEMENTATION MODULE PrgLoader;

(*
 * Mini-Version des "Loader"-Moduls von Megamax Modula-2.
 *
 * Dieses Modul kann nur Programme im GEMDOS-Format resident laden
 * und starten, jedoch keine einzelnen Megamax-Module.
 *
 * In der Ausgabe 4/91 der Zeitschrift TOS finden Sie die ausfÅhrliche
 * Beschreibung dieses nÅtzlichen Programms.
 *
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
 *   Sie dÅrfen das Programm verÑndern, jedoch nicht selbst "verbesserte"
 *   Versionen dieses Programms verbreiten. Dies obliegt allein dem Urheber
 *   Thomas Tempelmann.
 *
 *   Ich hoffe, Sie beachten diese Hinweise. Ich wÑre schwer enttÑuscht,
 *   wenn plîtzlich eine Version 2.1, die nicht von mir stammt, auf
 *   dem PD- oder Raubkopiermarkt erscheint. Dann kînnte dies der letzte
 *   Beitrag von mir gewesen sein. Fairness und Vertrauen sind wichtig
 *   fÅr das Weiterleben dieser Form der Softwareverîffentlichung!
 *
 *   FÅr Fragen, WÅnsche, Verbesserungen und Verîffentlichungen wenden
 *   Sie sich bitte an den Autor:
 *      Thomas Tempelmann, Nordendstr. 64, D-8000 MÅnchen 40.
 *
 * ------------------------------------------------------------------------
 *)

(*$R-,S-*)

FROM SYSTEM IMPORT CAST, WORD, ADDRESS, ADR, CADR, ASSEMBLER;
FROM MOSGlobals IMPORT NameStr, PathStr, FileStr;
FROM Strings IMPORT StrEqual, Upper, Assign;
FROM FileNames IMPORT PathConc, SplitPath, ConcatPath;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
FROM MOSCtrl IMPORT ProcessID;
FROM SysTypes IMPORT PtrBP;
FROM SysUtil1 IMPORT BPoke;
FROM SysInfo IMPORT UseStackFrame;
IMPORT GEMDOS;
IMPORT Block;
IMPORT XBRA;

CONST   MaxPrgToLoad = 10;  (* Anzahl maximal ladbarer Programme *)

        Kennung = "PLdr";   (* XBRA-Kennung fÅr GEMDOS-Handler *)


TYPE    LoadRange  = [1..MaxPrgToLoad];

        PrgEntry = RECORD  (* Beschreibung fÅr ein geladenes Programm *)
                     used: BOOLEAN;
                     name: NameStr;
                     path: PathStr;
                     basepage: PtrBP;
                     currentHeapSize: LONGCARD;
                     neededHeapSize: LONGCARD;
                     isMM2: BOOLEAN;
                     runs: SHORTCARD;
                     owner: ADDRESS;
                   END;

VAR     Loaded: ARRAY LoadRange OF PrgEntry; (* Liste der geladenen Programme *)
        CurrentField, CurrentBasePage: ADDRESS;
        TPAOffset: LONGCARD;
        GemdosEntry: ADDRESS;
        StackFrameOffs: SHORTCARD;

PROCEDURE Mfree (addr: ADDRESS);
  VAR ok: BOOLEAN;
  BEGIN
    ok:= GEMDOS.Free (addr)
  END Mfree;

PROCEDURE Mshrink (addr: ADDRESS; newAmount: LONGCARD);
  VAR ok: BOOLEAN;
  BEGIN
    ok:= GEMDOS.Shrink (addr, newAmount);
  END Mshrink;

PROCEDURE prgUnload (bp: PtrBP);
  (*
   * Gibt den Speicher eines geladenen Programms wieder frei.
   *)
  BEGIN
    Mfree (bp^.p_env); (* Environment freigeben *)
    Mfree (bp)         (* TPA / Prg. freigeben *)
  END prgUnload;

PROCEDURE prgLoad (REF name: ARRAY OF CHAR; VAR result: LONGINT);
  (*
   * LÑdt ein Programm mit der GEMDOS-Funktion "Pexec"
   *)
  VAR nullstring: CHAR; fullname: FileStr; ok: BOOLEAN;
  BEGIN
    nullstring:= 0C;
    Assign (name, fullname, ok);
    GEMDOS.Pexec (3, ADR (fullname), ADR (nullstring), 0, result)
  END prgLoad;

PROCEDURE getLoaderResult (execRes: INTEGER; VAR myRes: LoaderResults);
  (*
   * IN: GEMDOS-Fehlercode
   * OUT: Loader-Fehlercode
   *)
  BEGIN
    IF (execRes = -33) OR (execRes = -34) THEN
      myRes:= notFound;
    ELSIF (execRes = -39) THEN
      myRes:= outOfMemory;
    ELSE
      myRes:= badFile;
    END;
  END getLoaderResult;

PROCEDURE envLength (env: ADDRESS): LONGCARD;
  (*
   * Liefert die LÑnge eines Environment-Strings
   *)
  VAR (*$Reg*) p: POINTER TO CHAR;
  BEGIN
    p:= env;
    WHILE p^ # 0C DO
      REPEAT
        INC (p)
      UNTIL p^ = 0C;
      INC (p)
    END;
    RETURN ADDRESS (p) - env + 2
  END envLength;

PROCEDURE CodeSize (bp: PtrBP): LONGCARD;
  (*
   * Liefert LÑnge des statisch belegten Bereichs ohne den Heap-Bonus
   *)
  BEGIN
    WITH bp^ DO
      RETURN 256 + p_tlen + p_dlen + p_blen
    END
  END CodeSize;

PROCEDURE prgPrepare (bp: PtrBP; heapSize: LONGCARD): BOOLEAN;
  (*
   * Nimmt Anpassungen nach dem Laden eines Programms vor
   *)
  VAR newlen: LONGCARD; bpsize: LONGCARD;
  BEGIN
    (* belegten Speicher (TPA) berechnen: *)
    bpsize:= LONGCARD (bp^.p_hitpa) - LONGCARD (bp);
    (* benîtigten Speicher berechnen: *)
    newlen:= CodeSize (bp) + heapSize;
    (* Haben wir genug Platz im TPA erhalten? *)
    IF newlen > bpsize THEN
      (* wenn nicht, dann Laden abbrechen *)
      prgUnload (bp);
      RETURN FALSE
    END;
    (* TPA auf benîtigten Bereich verkleinern *)
    Mshrink (bp, newlen);
    bp^.p_hitpa:= ADDRESS (bp) + newlen;
    RETURN TRUE
  END prgPrepare;

PROCEDURE removeGemdosHdler;
  (*
   * TrÑgt den hiesigen GEMDOS-Handler (hdlGemdos) aus.
   *)
  (*$S-  hier ist kein Stack-Check nîtig *)
  VAR at: ADDRESS;
  BEGIN
    IF XBRA.Installed (Kennung, $84, at) THEN
      XBRA.Remove (at);
    END;
  END removeGemdosHdler;
  (*$S=  vorige Einstellung zurÅck *)

VAR Stack: ARRAY [1..600] OF WORD;

PROCEDURE hdlGemdos;
(*
 * Diese Funktion hÑngt im GEMDOS-TRAP-Handler und wartet darauf, daû
 * das Åber 'CallProgram' gestartete Programm die 'Mshrink'-Funktion
 * aufruft. Dann wird daraus die benîtigte Heap-Grîûe ermittelt und
 * diese Funktion wieder ausgehÑngt.
 *)
  (*$L-*)
  BEGIN
    ASSEMBLER
        BTST.B  #5,(A7)         ; War Supervisormode aktiv ?
        BNE.B   super           ; Ja, dann stehen Arg. auf SSP
        MOVE.L  USP,A0
        CMPI.W  #$4A,(A0)       ; Mshrink - Funktion ?
        BEQ.B   hdlMshrinkUser
dos     ; normale GEMDOS-Funktion ausfÅhren
        MOVE.L  GemdosEntry,A0
        MOVE.L  -4(A0),A0
        JMP     (A0)
super   MOVE.W  StackFrameOffs,D0 ; damit es auch mit einer 68010/20/30 geht
        CMPI.W  #$4A,6(A7,D0.W) ; Mshrink - Funktion ?
        BNE.B   dos             ; Nein -> GEMDOS aufrufen
        LEA     6(A7,D0.W),A0   ; Basis d. Argumente nach A0
hdlMshrinkUser
        MOVE.L  4(A0),A1        ; Argument 'addr' von Mshrink (addr, newamount)
        CMPA.L  CurrentBasePage,A1 ; ist es die TPA des gesuchten Programms?
        BNE     dos
        MOVE.L  8(A0),D0        ; 'newamount'-Parm von Mshrink: neue TPA-Grîûe
        MOVE.L  D0,D1
        ADD.L   A1,D0
        CMP.L   4(A1),D0        ; newamout > p_hitpa (alte TPA-Grîûe)?
        BHI     noNewHi         ;  dann ist zu wenig Speicher da
        MOVE.L  D0,4(A1)        ; p_hitpa in Base Page neu setzen
noNewHi TST.L   UsedHeapSize
        BPL     ignore          ; Heap-Grîûe wurde bereits ermittelt
        SUB.L   TPAOffset,D1    ; Subtr. die Grîûe des stat. Bereichs ohne Heap
        MOVE.L  D1,UsedHeapSize ; Das ist die gesuchte Heap-Grîûe
        MOVE.L  CurrentField,A0
        MOVE.L  D1,PrgEntry.neededHeapSize(A0)
        CMP.L   PrgEntry.currentHeapSize(A0),D1
        BCC     ignore
        MOVE.L  D1,PrgEntry.currentHeapSize(A0)
ignore  ; Diese Routine kann nun aus dem GEMDOS-TRAP entfernt werden
        MOVE.L  A3,-(A7)
        MOVE.L  A7,D0
        LEA     Stack,A3
        LEA     SIZE(Stack) (A3),A7
        MOVE.L  D0,-(A7)
        JSR     removeGemdosHdler
        MOVE.L  (A7)+,A7
        MOVE.L  (A7)+,A3
        BRA     dos     ; Nun lassen wir endlich Mshrink ausfÅhren
    END
  END hdlGemdos;
  (*$L=*)


PROCEDURE prgExec (bp: PtrBP; filename: ADDRESS; REF arg: ArgStr;
                   env: ADDRESS; multi, isMM2: BOOLEAN; VAR exitcode: LONGINT);
  (*
   * Startet geladenes Programm.
   * 'multi': TRUE heiût, daû geladenes Prg nicht nur einmal gestartet
   *   werden kann und deshalb DATA-Bereich usw. gerettet werden mÅssen.
   *)

  TYPE ptrLInt = POINTER TO LONGINT;

  VAR el, dl: LONGCARD; oldEnv, hitpa, at, envcopy, data: ADDRESS;
      carrier: XBRA.Carrier; p3: ptrLInt; stackSize: LONGINT;

  BEGIN
    IF multi THEN
      (* Base Page- und DATA-Bereich retten *)
      dl:= bp^.p_dlen + 128; (* LÑnge des zu rettenden Data/Basepage-Bereichs *)
      ALLOCATE (data, dl);
      IF data = NIL THEN
        (* kein Speicherplatz mehr frei *)
        exitcode:= -39;
        RETURN
      END;
      Block.Copy (bp, 128, data); (* die ersten 128 Byte der Base Page retten *)
      Block.Copy (bp^.p_dbase, bp^.p_dlen, data+128);
      IF isMM2 THEN p3:= ADDRESS(bp)+(256+56); stackSize:= p3^ END;

      (* BSS lîschen *)
      Block.Clear (bp^.p_bbase, bp^.p_hitpa - bp^.p_bbase);
    END;
    
    (* Commandline in die Base Page kopieren *)
    Block.Copy (CADR (arg), 128, ADR (bp^.cmdline));
    
    IF multi THEN
      (* Pfade v. Parent Åbernehmen *)
      Block.Copy (ProcessID^+$37, 1, ADDRESS(bp)+$37);
      Block.Copy (ProcessID^+$40, 16, ADDRESS(bp)+$40);
    END;
    
    (* DTA auf Cmdline *)
    bp^.p_dta:= ADR (bp^.cmdline);
    
    (* Environment kopieren, da Pexec dies wie so vieles *
     * beim Nur-Starten fÑlschlicherweise nicht tut.    *)
    oldEnv:= bp^.p_env;
    IF multi & (env # 0) THEN
      el:= envLength (env);
      ALLOCATE (envcopy, el)
    END;
    IF multi & (env # 0) & (envcopy = NIL) THEN
      (* kein Speicherplatz mehr frei *)
      exitcode:= -39;
    ELSE
      IF multi & (env # 0) THEN
        Block.Copy (env, el, envcopy);
        bp^.p_env:= envcopy;
      END;
      
      (* 'hdlGemdos' in TRAP #1 einhÑngen *)
      XBRA.Create (carrier, Kennung, CAST (ADDRESS, hdlGemdos), GemdosEntry);
      XBRA.Install (GemdosEntry, $84);
      
      (* Prozeû starten *)
      TPAOffset:= CodeSize (bp);
      CurrentBasePage:= bp;
      GEMDOS.Pexec (4, filename, bp, env, exitcode);
      CurrentBasePage:= NIL;
      
      (* 'hdlGemdos' wieder aushÑngen *)
      removeGemdosHdler;
      
      IF multi & (env # 0) THEN
        DEALLOCATE (envcopy, 0)  (* Kopie vom Environment wieder freigeben *)
      END
    END;
    bp^.p_env:= oldEnv;

    IF multi THEN
      (* geretteten Base Page- und DATA-Bereich zurÅckkopieren *)
      hitpa:= bp^.p_hitpa;
      Block.Copy (data, 128, bp);
      bp^.p_hitpa:= hitpa;
      IF isMM2 THEN p3^:= stackSize END;
      Block.Copy (data+128, bp^.p_dlen, bp^.p_dbase);
      DEALLOCATE (data, 0); (* gesamten DATA-Bereich wieder freigeben *)
    END
  END prgExec;


PROCEDURE isLoaded (REF nameWOpath: ARRAY OF CHAR;
                    VAR index: LoadRange): BOOLEAN;
  (*
   * Liefert TRUE, wenn "nameWOpath" geladen ist.
   * Der Åbergebene Name darf keinen Pfad enthalten.
   * 'index' enthÑlt den Feldindex in "Loaded", wenn Prg. geladen ist,
   * ansonsten liefert es den Index auf ein unbenutztes Feld in "Loaded".
   *)

  VAR c: LoadRange; free: BOOLEAN;

  BEGIN
    free:= FALSE;
    FOR c:= MIN (LoadRange) TO MAX (LoadRange) DO
      WITH Loaded[c] DO
        IF used THEN
          IF StrEqual (nameWOpath, name) THEN
            (* wir haben ihn gefunden *)
            index:= c;
            RETURN TRUE
          END
        ELSE
          IF NOT free THEN
            (* ersten freien Eintrag merken *)
            index:= c;
            free:= TRUE
          END
        END
      END
    END;
    RETURN FALSE
  END isLoaded;


PROCEDURE LoadProgram (    filename: ARRAY OF CHAR;
                           heapSize: LONGCARD;
                       VAR result  : LoaderResults);
(*
 * LÑdt ein Programm mit der angegeben Heap-Grîûe.
 * Ergebnis in 'result'.
 *)

  TYPE ptrStr = POINTER TO ARRAY [0..19] OF CHAR;
       ptrCard= POINTER TO CARDINAL;

  VAR prgname: NameStr; prgpath: PathStr; index: LoadRange;
      ploadres: LONGINT; bp: ADDRESS; p1: ptrStr; p2: ptrCard;

  BEGIN
    Upper (filename);
    SplitPath (filename, prgpath, prgname);
    
    (* Programm schon geladen? Dann Abbruch *)
    IF isLoaded (prgname, index) THEN
      result:= alreadyLoaded;
      RETURN
    END;
    
    (* Programm laden *)
    prgLoad (filename, ploadres);
    IF ploadres < 0 THEN
      (* Fehler beim Laden aufgetreten *)
      getLoaderResult (SHORT (ploadres), result);
      RETURN
    END;
    
    (* Programm im Speicher vorbereiten *)
    bp:= PtrBP (ploadres);
    IF NOT prgPrepare (bp, heapSize) THEN
      (* Speicher reicht nicht *)
      prgUnload (bp);
      result:= outOfMemory;
      RETURN
    END;
    
    (* Programm erfolgreich geladen. Nun eintragen *)
    WITH Loaded[index] DO
      used:= TRUE;
      name:= prgname;
      path:= prgpath;
      basepage:= bp;
      neededHeapSize:= LONGCARD (-1);  (* noch undefiniert *)
      currentHeapSize:= heapSize;
      runs:= 0;
      owner:= ProcessID^;
      p1:= ADDRESS (bp) + (256 + 18); p2:= ADDRESS (bp) + (256 + 38);
      isMM2:= StrEqual ("Megamax Modula-2 V2", p1^) AND (p2^ = 4)
    END;
    result:= noError;
  END LoadProgram;


PROCEDURE UnLoadProgram (    filename: ARRAY OF CHAR;
                         VAR result  : LoaderResults);
(*
 * Gibt geladenes Programm frei.
 * Ergebnis in 'result'.
 *)

  VAR prgname: NameStr; prgpath: PathStr; index: LoadRange;

  BEGIN
    Upper (filename);
    SplitPath (filename, prgpath, prgname);
    IF isLoaded (prgname, index) THEN
      WITH Loaded[index] DO
        prgUnload (basepage);
        used:= FALSE
      END;
      result:= noError
    ELSE
      result:= notFound
    END
  END UnLoadProgram;


PROCEDURE Arg (REF in: ARRAY OF CHAR): ArgStr;
  (*
   * Erzeugt die GEMDOS-Cmdline fÅr Pexec() aus einem Modula-String.
   *)
  VAR l: CARDINAL; out: ArgStr;
  BEGIN
    l:= LENGTH (in);
    IF l > 125 THEN l:= 125 END;
    Block.Clear (ADR (out), SIZE (out));    (* Cmdline zuerst lîschen *)
    Block.Copy (CADR (in), l, ADR (out)+1); (* Arg. eintragen *)
    BPoke (ADR (out), l);                   (* LÑnge in 1.Byte eintragen *)
    RETURN out
  END Arg;


PROCEDURE CallProgram (    filename   : ARRAY OF CHAR;
                       REF argLine    : ArgStr;
                           environment: ADDRESS;
                       VAR exitCode   : LONGINT);
(*
 * Startet Programm, auch ungeladen. 'args' enthÑlt die Command Line als
 * normalen Modula-String.
 * Ergebnis in 'exitCode'.
 *)

  VAR prgname: NameStr; prgpath: PathStr; index: LoadRange;
      bp: ADDRESS; fullname: FileStr; ok: BOOLEAN;

  BEGIN
    CurrentField:= NIL;
    UsedHeapSize:= LONGCARD (-1);
    Upper (filename);
    SplitPath (filename, prgpath, prgname);
    IF isLoaded (prgname, index) THEN
      (* geladenes Prg starten *)
      CurrentField:= ADR (Loaded[index]);
      WITH Loaded[index] DO
        ConcatPath (path, name, fullname);
        INC (runs);
        prgExec (basepage, ADR (fullname), argLine, environment, TRUE, isMM2,
                 exitCode)
      END
    ELSE
      (* Programm laden & starten, und zwar getrennt, um 'HeapSize'
       * ermitteln zu kînnen. *)
      prgLoad (filename, exitCode);
      IF exitCode < 0 THEN (* Fehler beim Laden aufgetreten *) RETURN END;
      bp:= ADDRESS (exitCode); (* Base Page merken *)
      Assign (filename, fullname, ok);
      prgExec (bp, ADR (fullname), argLine, environment, FALSE, FALSE,
               exitCode);
      prgUnload (bp);
    END
  END CallProgram;

PROCEDURE ProgramLoaded (filename: ARRAY OF CHAR): BOOLEAN;
(*
 * Liefert TRUE, wenn Programm geladen ist
 *)
  VAR prgname: NameStr; prgpath: PathStr; index: LoadRange;
  BEGIN
    Upper (filename);
    SplitPath (filename, prgpath, prgname);
    RETURN isLoaded (prgname, index);
  END ProgramLoaded;

(*$H+*)
PROCEDURE QueryLoaded (call: QueryPrgProc);
  VAR c: CARDINAL;
  BEGIN
    FOR c:= MIN (LoadRange) TO MAX (LoadRange) DO
      WITH Loaded[c] DO
        IF used THEN
          IF NOT call (PathConc (path, name), runs,
                       currentHeapSize, neededHeapSize) THEN
            RETURN
          END
        END
      END
    END
  END QueryLoaded;

BEGIN
  IF UseStackFrame () THEN StackFrameOffs:= 2 ELSE StackFrameOffs:= 0 END;
END PrgLoader.
