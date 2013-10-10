DEFINITION MODULE MM2LnkIO;

PROCEDURE InitOutput (maxModules: CARDINAL; REF title: ARRAY OF CHAR);

PROCEDURE VerboseOutput;

PROCEDURE Report (n: CARDINAL; REF s: ARRAY OF CHAR);
PROCEDURE Prompt (n: CARDINAL; REF s: ARRAY OF CHAR);
(*
 * 'n': 0 = output file name, 1 = main module, 2 = stack size, 3 = link-process
 *)

PROCEDURE Read (VAR c: CHAR);
PROCEDURE ReadString (VAR s: ARRAY OF CHAR);
PROCEDURE WriteString (REF s: ARRAY OF CHAR);
PROCEDURE ClearEOP;

PROCEDURE WriteMod (modNo: CARDINAL; REF modName, fileName: ARRAY OF CHAR);
PROCEDURE ClearMod (modNo: CARDINAL);
PROCEDURE DiscardMods (downTo: CARDINAL);

PROCEDURE ReportRealFormat (code: CARDINAL);
PROCEDURE ReportCodeLen (text, bss, data: LONGCARD);

PROCEDURE ReportLinkError (REF mod, client, msg: ARRAY OF CHAR);
PROCEDURE ReportIOError (no: INTEGER);
PROCEDURE ReportError (REF s: ARRAY OF CHAR);


CONST MaxSymbolLen = 60;  (* Max. LÑnge fÅr Symbole *)

TYPE SymbolList = POINTER TO SymbolEntry;
     SymbolEntry = RECORD
       next: SymbolList; (* nÑchstes Symbol, NIL = Ende d. Liste *)
       typ : CARDINAL;   (* z.Zt. unbenutzt *)
       addr: LONGCARD;   (* MSB: Segment (0:TEXT/1:DATA/2:BSS) *)
       name: ARRAY [0..MaxSymbolLen] OF CHAR;
     END;

     LongSet = SET OF [0..31];

     ModList = POINTER TO ModDesc;
     ModDesc = RECORD
                 next: ModList;    (* nÑchstes Modul, NIL = Ende d. Liste *)
              codeAdr: LONGCARD;   (* Offset des Moduls im TEXT-Segment *)
              codeLen: LONGCARD;   (* LÑnge des Moduls; Null, wenn entfernt. *)
               varAdr: LONGCARD;   (* Offset der Vars im BSS-Segment *)
               varLen: LONGCARD;   (* LÑnge der Variablen *)
              dataAdr: LONGCARD;   (* z.Zt. unbenutzt *)
              dataLen: LONGCARD;   (* z.Zt. unbenutzt *)
           sourceName: ARRAY [0..11] OF CHAR; (* Name des Quelltextes *)
             codeName: ARRAY [0..99] OF CHAR; (* Name/Pfad des Modulcodes *)
                 name: ARRAY [0..39] OF CHAR; (* ModulName *)
           symbolRoot: SymbolList; (* Liste der Symbole, = NIL, wenn leer *)
             compOpts: LongSet;    (* Verwendete Direktiven (Bit 1 = 'A' *)
              mainMod: BOOLEAN;    (* FALSE: ist'n importiertes Modul *)
     END;

PROCEDURE OutputSymbols (REF arg, prgname: ARRAY OF CHAR; mod: ModList): BOOLEAN;

PROCEDURE OutputInitList (REF arg, prgname: ARRAY OF CHAR;
                          init: ARRAY OF CARDINAL;
                          highIdx, firstIdx: CARDINAL): BOOLEAN;

PROCEDURE BeginWriting;
PROCEDURE WritingOut (modNo: CARDINAL);
PROCEDURE EndWriting;

END MM2LnkIO.
