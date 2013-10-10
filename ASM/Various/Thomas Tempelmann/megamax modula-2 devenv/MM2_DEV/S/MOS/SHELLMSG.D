DEFINITION MODULE ShellMsg;

(*
 * EnthÑlt Variablen fÅr die Kommunikation der Shell mit Compiler,
 * Editor, Linker und Make.
 *
 * ---------------------------------------------------------------------------
 * 20.10.91  TT  LinkerParm um Symboldatei-Felder erweitert.
 *)

FROM SYSTEM IMPORT LONGWORD;
FROM MOSGlobals IMPORT SfxStr, PathStr, FileStr, NameStr;
FROM Strings IMPORT String;
FROM PathCtrl IMPORT PathList;

TYPE    LinkDesc = RECORD
                     valid: BOOLEAN;
                     name : ARRAY [0..39] OF CHAR
                   END;

        LLRange = [1..8];
        
        LinkMode= (noOptimize, nameOptimize, partOptimize, fullOptimize);


VAR     Active: BOOLEAN;  (* TRUE = Eine Shell ist vorhanden / vorbereitet *)

(*
 * Statische Werte, die von diesem Modul selbst eingestellt werden
 * ---------------------------------------------------------------
 *)

    (* FÅr Compiler: Suffices fÅr erzeugte Dateien *)
        DefSfx: SfxStr;      (* Extension f. Symboldateien *)
        ImpSfx: SfxStr;      (* Extension f. Implementations-Codes *)
        ModSfx: SfxStr;      (* Extension f. Hauptmodul-Codes *)
        SymSfx: SfxStr;      (* z.Zt. unbenutzt, reserviert *)

    (* FÅr Shell, ModRef *)
        DefSrcSfx: SfxStr;      (* Extension f. Definitions-Texte *)
        ImpSrcSfx: SfxStr;      (* Extension f. Implementations-Texte *)
        ModSrcSfx: SfxStr;      (* Extension f. Hauptmodul-Texte *)

(*
 * Statische Werte, die von der MM2Shell eingestellt werden
 * --------------------------------------------------------
 *)

    (* Shell: global, z.B. f. Make *)
        TemporaryPath: PathStr;         (* f. temporÑre Dateien *)
        ShellPath: PathStr;             (* Pfad (HomePath) der Shell selbst *)

    (* Compiler / Linker / Debugger *)
        StdPaths: PathList;  (* Suchliste f. Shell: Module/Programme/Batch *)
        DefPaths: PathList;  (* Suchliste f. Compiler: Symbol-Dateien (.DEF) *)
        ImpPaths: PathList;  (* Suchliste f. Linker: Code-Dateien (.IMP) *)
        ModPaths: PathList;  (* Suchliste f. Linker: Code-Dateien (.MOD) *)
        SrcPaths: PathList;  (* Suchliste f. Compiler und Editor: Quelltexte *)
        SymPaths: PathList;  (* z.Zt. unbenutzt, reserviert *)

    (* FÅr Compiler: Ausgabepfade f. erzeugte Dateien                    *)
    (* Bei leeren Strings wird der Code im Pfad des Quelltextes abgelegt *)
        DefOutPath: PathStr;      (* Pfad f. Symboldateien (.DEF) *)
        ImpOutPath: PathStr;      (* Pfad f. Implementations-Codes (.IMP) *)
        ModOutPath: PathStr;      (* Pfad f. Hauptmodul-Codes (.MOD) *)
        SymOutPath: PathStr;      (* z.Zt. unbenutzt, reserviert *)

    (* FÅr Compiler: Name der Fehlertextdatei *)
        ErrListFile: FileStr;

    (* FÅr Compiler: Name der Libray-Datei mit Definitionscodes *)
        DefLibName: FileStr;

    (* FÅr Linker *)
        LinkerParm: RECORD
                      name         : String;
                                        (*  Linkername                  *)
                      linkStackSize: LONGCARD;
                                        (* Stackgrîûe f. gelinkte Prg.  *)
                      maxLinkMod   : CARDINAL;
                                        (* Maximal zu linkende Module.  *)
                      linkList     : ARRAY LLRange OF LinkDesc;
                                        (* Einzulinkende Treibermodule. *)
                      optimize     : LinkMode;
                                        (* Legt Optimierungsstrategie fest   *)
                      fastLoad     : BOOLEAN;
                                        (* Setze Fast-Load-Bit (ab TOS 1.4)  *)
                      fastCode     : BOOLEAN;
                                        (* Nur Atari TT                      *)
                      fastMemory   : BOOLEAN;
                                        (* Nur Atari TT                      *)
                      outputName   : String;
                                        (* Expliziter Name f. Ausgabedatei   *)
                      symbolFile   : BOOLEAN;
                                        (* Erzeugen einer Symboldatei        *)
                      symbolArgs   : String;
                                        (* Argumente f. " (s. MM2LnkIO)      *)
                    END;
        
        

    (* FÅr Make *)
        MakeFileName: FileStr;  (* Default-Name, wenn sonst keiner angegeben *)

    (* FÅr Editor und Shell zum Aufruf des Compilers: *)
        CompilerParm: RECORD
                        name     : String;  (*  Compilername       *)
                        shortMsgs: BOOLEAN; (*  quiet compilation  *)
                        protocol : BOOLEAN; (*  write protocol     *)
                        protName : String;  (*  protocol file name *)
                        protWidth: CARDINAL;(*  protocol width     *)
                      END;

    (* FÅr Shell zum Aufruf des Editors: *)
        EditorParm   : RECORD
                         name          : String;       (*  Editorname  *)
                         passErrorPos  : BOOLEAN;
                         passErrorText : BOOLEAN;
                         passName      : BOOLEAN;
                         passArgument  : BOOLEAN;
                         tempShellFile : BOOLEAN;
                         tempEditorFile: BOOLEAN;
                         searchSources : BOOLEAN;
                         waitOnError   : BOOLEAN;

                         tempShellName : NameStr;
                         tempEditorName: NameStr;
                       END;

(*
 *  Variable, die zum Austausch von Informationen zwischen
 *     Compiler, Editor, Make, Linker und Shell dienen.
 * --------------------------------------------------------
 *)

    (* Inhalt des "Ausgabepfads" in der Compiler-Box der Shell.
     * Hierauf greift der Compiler nicht direkt zu, sondern die
     * Shell Åbergibt den String ggf. Åber die Argumentzeile
     * (mit "/O"-Option, siehe Shell-Source).
     *)
        MainOutputPath: PathStr; (* Wenn nicht leer, hat dieser Pfad   *)
                                 (* Vorrang vor den einzelnen Ausgabe- *)
                                 (* pfaden 'Def/Imp/ModOutPath'!       *)

        CompilerArgs: String;    (* ZusÑtzliche Argumente an Compiler, *)
                                 (* z.B: "-R -S", um Range-, Overflow- *)
                                 (* und Stack-PrÅfungen zu unterbinden *)

    (* Akt. Dateien der Shell, modifizierbar *)
        CodeName: FileStr;        (* Name der Code-Datei *)
        TextName: FileStr;        (* Name des Quelltextes *)

    (* An Compiler v. Shell / ErrorHandler *)
        ScanMode: BOOLEAN;
        ScanAddr: LONGCARD;
        ScanOpts: LONGWORD;

    (* Von GEMError an Shell *)
        ScanIndex: CARDINAL;   (* Index auf 'GEMScan.CallingChain' *)

    (* Vom Compiler / ErrorHandler an Shell: *)

        (* ExitCode=0 (Compilation/Scanning OK): *)
        CodeSize: LONGCARD;
        ModuleName: ARRAY [0..79] OF CHAR;

        (* ExitCode=1 (No name) *)

        (* ExitCode=2 (I/O error), *)
        (* ExitCode=3 (Comp-error): *)
        ErrorMsg: ARRAY [0..79] OF CHAR;  (* Fehlermeldung vom Compiler *)
        TextLine: CARDINAL;               (* Nur nach Comp-Fehler *)
        TextCol : CARDINAL;               (* Nur nach Comp-Fehler *)

END ShellMsg.
