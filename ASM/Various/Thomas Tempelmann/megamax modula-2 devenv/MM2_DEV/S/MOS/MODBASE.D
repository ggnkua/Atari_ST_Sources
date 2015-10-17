DEFINITION MODULE ModBase;

(*
 * Internes Modul
 *)

FROM SYSTEM IMPORT ADDRESS, BYTE, LONGWORD;

FROM Lists IMPORT List, LCarrier;

FROM MOSGlobals IMPORT PathStr, PfxStr, FileStr, NameStr, MemArea;

FROM SysTypes IMPORT PtrBP;


(*
   Neue Verwaltung der Modulinformationen
   --------------------------------------

  Zu jedem vollst. Modul im Speicher, das importierbar ist, gehîrt ein
Record "ModEntry". In ihm werden alle Modulinformationen abgelegt,
der alte Header vom Modulcode ist nicht mehr prÑsent!

  Dabei kînnen die notwendigen Informationen in drei Kategorien aufgeteilt
werden:
1) Wird ein Prg vollst. gelinkt und wird kein Loader.CallModule verwendet,
  sind eigentlich auch keine Informationen notwendig. Fehlen daher die entspr.
  Daten vom Linker, wird eine leere Modulliste angelegt.
2) Zum besseren Debuggen in optimierten Prgs sind folg. Daten notwendig:
    - Modul-Start/-LÑnge
    - Var-Start/-LÑnge
    - Liste mit Proc-Namen
    - Body-Adr
    - Namen v. Code, Source, Symbolfile
    - code-options
  Diese Daten werden vom Linker bei halber Optimierung Åbergeben
3) Damit die gelinkten Module importiert werden kînnen, sind deren
  Export-Liste und deren Keys nîtig. ZusÑtzlich ist fÅr die dynamisch
  geladenen Module noch eine Liste der importierten Module anzulegen.
  Die Export-Liste wird daher vom Linker nur bei Linken ohne Optimierung
  erzeugt.

  Der Linker reserviert in den FÑllen 2) und 3) den Platz f. die
ModEntry-Records in einem Array, das Åber den PDB mitgeteilt wird.
FÅr den Fall 3) muû sich der Loader ggf. Åber 'ModEntry.ldr' weiteren
Platz anlegen.

TYPE    PStr = ARRAY [0..79] OF CHAR;

        PtrLoaderInfo = POINTER TO LoaderInfo;
        
        LoaderInfo = RECORD
                       codeNameUp: ModStr;   (* in Groûbuchstaben *)
                       fileName  : PfxStr;   (* Name o. Sfx, groû *)
                       filePath  : PathStr;
                       imports   : POINTER TO ARRAY [0..65535] OF ModRef;
                     END;

        ModEntry = RECORD
                     codeStart : ADDRESS;  (* echte Code-Adr ohne Head *)
                     codeLen   : LONGCARD; (* echte Code-LÑnge o. Head *)
                     varStart  : ADDRESS;  (* Start der globalen Variablen *)
                     varLen    : LONGCARD;
                     checksum  : LONGCARD; (* z.Zt. unbenutzt *)
                     codeName  : POINTER TO ModStr;
                     sourceName: POINTER TO FileStr;
                     symbolName: POINTER TO FileStr;
                     symbolKey : LONGCARD;
                     symbolAddr: ADDRESS;  (* # NIL, wenn Symbolfile geladen *)
                     options   : LONGWORD; (* Bit 1:'A', Bit 26: 'Z' *)
                     state     : ModStates;
                     body      : ADDRESS;
                     procName  : POINTER TO RECORD next: ADDRESS; s: PStr END;
                     removeInfo: PROC;
                     removeWsp : MemArea;
                     exports   : ADDRESS;
                     key       : LONGCARD
                     ldr       : PtrLoaderInfo;
                   END;
*)

TYPE

        ModStr = ARRAY [0..39] OF CHAR;

        ModState = (linked,     (* Immer resident *)
                    loaded,     (* Mit 'LoadModule' geladen *)
                    loadImp,    (* temporÑr intern benutzt *)
                    installed,  (* Mit 'InstallModule' res. gemacht *)
                    instImp,    (* unbenutzt *)
                    mainMod,    (* Oberstes Modul, von CallModule gestartet *)
                    running,    (* Laufendes Modul (sonst nur 'loaded') *)
                    initialized,(* Modul wurde schon ausgefÅhrt *)
                    firstCall,  (* Wird gerade zum ersten Mal ausgefÅhrt *)
                    program,    (* Ist kein Modul sondern selbst. Programm *)
                    procSym,    (* Modul enthÑlt Prozedurnamen *)
                    crunched,   (* Modul ist komprimiert *)
                    dirty,      (* Modul wurde neu compiliert *)
                    reentrant,  (* Modul ist reentrant, Vars bleiben erhalten *)
                    msr1,       (* temporÑr intern benutzt *)
                    msr2);      (* temporÑr intern benutzt *)

        ModStates = SET OF ModState;

        ModHeader = RECORD
                      (* wird an dieser Stelle schon ignoriert:
                        str   : ARRAY [0..7] OF CHAR; (* = "MM2Code" *)
                      *)
                      layout: BYTE;
                      id    : SET OF [0..7];
                      key   : LONGCARD;
                      body  : LONGCARD;
                      modEnd: LONGCARD;
                      importList: LONGCARD;
                      exportList: LONGCARD;
                      CASE : CARDINAL OF
                        1: relocList: LONGCARD|
                        2: codeEnd: LONGCARD (* Code+Data! *)
                      END;
                      sourceName: LONGCARD;
                      codeName  : LONGCARD;
                      symbolName: LONGCARD;
                      procSize  : LONGCARD;
                      codeStart : LONGCARD;
                      options   : LONGWORD; (* Bit 1:'A', Bit 26: 'Z' *)
                      clinkresv : LONGWORD;
                      stackSize : LONGCARD;
                      prgFlags  : LONGWORD;
                      dataStart : LONGWORD; (* DATA: zw. Code und Reloc-List *)
                      reserved  : ARRAY [3..6] OF LONGWORD;
                    END;

        PtrModHeader = POINTER TO ModHeader;

        PtrBSS = POINTER TO RECORD
                   prev: PtrBSS;
                   data: CARDINAL
                 END;

        ModRef = POINTER TO ModEntry;

        ModEntry = RECORD
                     header    : PtrModHeader; (* Modul-Beginn *)
                     codeStart : ADDRESS; (* Echter Beginn des Codes (ohne Head) *)
                     codeLen   : LONGCARD;
                     varRef    : ADDRESS; (* Start der globalen Variablen *)
                     varLen    : LONGCARD;
                     codeName  : POINTER TO ModStr;
                     codeNameUp: ModStr;   (* in Groûbuchstaben *)
                     fileName  : PfxStr;   (* Name o. Sfx, groû *)
                     (* filePath  : PathStr; *)
                     imports   : POINTER TO ARRAY [0..65535] OF ModRef;
                     exports   : ADDRESS;
                     state     : ModStates;
                     prevBSS   : PtrBSS; (* saved BSS for non-reentrant mods *)
                     removeInfo: PROC;
                     removeWsp : MemArea;
                     owner     : ADDRESS; (* Prozeû, in dem's geladen wurde *)
                   END;

        Criterion = ( modName,     (* Suche nach Modulname *)
                      fileName,    (* Suche nach Dateinamen (12 Zeichen) *)
                      codeAddr,    (* Suche bezgl. einer Code-Adresse *)
                      varAddr,     (* Suche bezgl. Adr. einer globalen Variablen *)
                      user,        (* Suche nach allen, die "ref" importieren *)
                      loadedMod ); (* Suche nach 'geladenen' Moduln *)

        SearchDesc = RECORD
                       CASE mode: Criterion OF
                          modName:            mname: POINTER TO ModStr|
                          fileName:           fname: POINTER TO PfxStr|
                          codeAddr, varAddr:  addr: ADDRESS|
                          user:               uCnt: ADDRESS;
                                              ref : ModRef|
                          loadedMod:          lCnt: ADDRESS|
                        END
                      END;

VAR Release: PROCEDURE (VAR ModRef, BOOLEAN, BOOLEAN);

    ModLst: List;


PROCEDURE GetModRef ( VAR what: SearchDesc; VAR ref: ModRef );
  (*
   * Sucht, je nachdem, was in "what" bestimmt wurde, ein 'ModEntry' und
   * liefert einen Zeiger darauf in "ref". Wenn "ref" = NIL, dann ist
   * der verlangte 'ModEntry' nicht vorhanden.
   *
   * Bei "what.mode" = 'user' muû neben dem gesuchten 'ModRef' in "what.ref"
   * zusÑtzlich beim ersten Suchaufruf "what.uCnt" auf NIL gesetzt werden.
   * Wiederholte Aufrufe von "GetModRef" liefern dann alle 'ModEntry', die
   * "what.ref" importieren, bis "ref" am Ende NIL ist.
   * Gleiches gilt, wenn "what.mode" = 'loadedMod' ist (dann muû bei Such-
   * beginn "what.lCnt" auf NIL gesetzt werden).
   *)

PROCEDURE MarkState ( client: ModRef; pen: ModState );

PROCEDURE CallEnvelopes ( opening: BOOLEAN; inChild: BOOLEAN ): INTEGER;

PROCEDURE FindRef ( ad: ADDRESS; VAR ref: ModRef );

PROCEDURE SplitModName ( REF source: ARRAY OF CHAR;
                         VAR name, sfx: ARRAY OF CHAR ): BOOLEAN;

PROCEDURE ModLoaded (REF fname: ARRAY OF CHAR; import: BOOLEAN;
                     VAR mname: ARRAY OF CHAR; VAR ref: ModRef): BOOLEAN;

PROCEDURE CreateBasePage (VAR bp: PtrBP; stacksize: LONGCARD;
                          name: ADDRESS; prgFlags: LONGWORD): BOOLEAN;

PROCEDURE ExecProcess (bp: PtrBP; call: PROC; name: ADDRESS; prgFlags: LONGWORD;
                       VAR termState: CARDINAL; VAR exitCode: INTEGER);

PROCEDURE FreeMod (VAR client: ModRef);

END ModBase.
