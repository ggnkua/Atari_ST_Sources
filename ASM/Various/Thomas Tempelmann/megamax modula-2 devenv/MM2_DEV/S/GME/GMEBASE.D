DEFINITION MODULE GMEBase;
(*$Z+*)

FROM SYSTEM IMPORT TSIZE;
FROM GEMEnv IMPORT DeviceHandle, GemHandle;

(* Von EditConst *)

CONST
        maxItem =               24; (* Magic Number in MENU.MOD *)
        maxItemLen =            78;
        maxLev =                1; (* MENU.Grenzen *)
        
        cRevision =             000011L;
        cAllocate =             16;

(* Definition wichtiger ASCII-Codes (NICHT Tastencodes! *)

        eot =           32C; (* ??? *)

        cZeile =                1023;
        cInfo =                 128;

        cTextUmbruch =          65;
        cUeberschriftLaenge =   68;
        cTabWeite =             8;
        cKopfVorlauf =          0;
        cKopfNachlauf =         2;
        cZeilenAbstand =        2; (* 1/72 Zoll! Zahl unsinnig. *)
        cSpiegel =              60;
        cOffset =               0;
        cSchreibZaehler =       1500;

(* Von EditType *)

TYPE    einStringPointer =      POINTER TO eineZeile;
        eineZeile =             ARRAY [0..cZeile] OF CHAR;
        eineInfo =              ARRAY [0..cInfo] OF CHAR;
        CharSet =               SET OF CHAR;
 
        einLinePointer =        POINTER TO aLine;

        aLine =                 RECORD
                                  vorige, naechste: einLinePointer;   (* 8 *)
                                  ZeilPointer:      einStringPointer; (* 4 *)
                                  laenge:           CARDINAL;         (* 2 *)
                                  terminator:   ARRAY [0..1] OF CHAR; (* 2 *)
                                END (* aLine *);    (* TSIZE =          16 *)
 
        einMerkPointer =        POINTER TO einMerkPunkt;
 
        einMerkPunkt =          RECORD
                                  zeilpos:      CARDINAL;             (* 2 *)
                                  charpos:      CARDINAL;             (* 2 *)
                                  merkline:     einLinePointer;       (* 4 *)
                                  merkinfo:     einLinePointer;       (* 4 *)
                                  nextMerk:     einMerkPointer;       (* 4 *)
                                END (* einMerkPunkt *); (* TSIZE =      16 *)
 
        MerkIndex =             (ErsteZeile, LaufendeZeile,
                                 MerkPunkt1, MerkPunkt2, CompilerInfo,
                                 BlockMarke1, BlockMarke2, PufferVergleich,
                                 IndexListe, DruckerSteuer,
                                 Protokoll, Textbausteine, Datei, M13, M14,
                                 LetztePosition);
 
        einMerkSet =            SET OF MerkIndex;
 
        Mode =                  ((*TextModus*) Compiliert, ControlZeichen,
                                 (* ControlZFiltern - fehlt leider *)
                                 OverWrite, AutoIndent, Editiert,
                                 WortSuche, GrossKleinSuche,
                                 BlockIstMarkiert,
                                 Changed,
                                 IndexScan, (* Indexgenerierung - not used*)
                                 Exit, (* 10 *)
 
                                 (* File-Flags: *)
                                 KonfigSpeichern, AutoSave, TabFiltern,
                                 DruckerfilterLaden, FontLaden, (* 15 *)
 
                                 (* *)
                                 Flag16, Flag17,
                                 Flag18, Flag19, (* 19 *)
                                 Flag20, Flag21,
                                 Flag22, Flag23, (* 23 *)
                                 Flag24, Flag25,
                                 Flag26, Flag27, (* 27 *)
                                 Flag28,
                                 MakeBAK (* .BAK, .OLD *),
                                 Flag30, (* 30 *)
                                 Expand0); (* 31 = 32 Bit *)

        Moden =                 SET OF Mode;
 
        einPufferPointer = POINTER TO einPufferDeskriptor;

        einPufferDeskriptor =
                        RECORD
                          MagicRevision:                LONGCARD;
                          Puffer:                       einLinePointer;
                                                                   (* 4 *)
                          ZeilenAnzahl:                 CARDINAL;  (* 2 *)
                          MerkPunkte:                   ARRAY MerkIndex OF
                                                          einMerkPunkt;
                                                        (* 16 * 16 =  256 *)
                          Modus:                        Moden;    (*  4 *)
                          Pfad, Name:                   eineInfo;(* 120 *)
                          Max:                          CARDINAL;  (* 2 *)
                          TabWeite:                     CARDINAL;  (* 2 *)
                          NaechsterPuffer:              einPufferPointer;
                          
                          SchreibZaehler:               CARDINAL;  (* 2 *)
                            (* Fuer Autosave *)
                          tageszeit:                    CARDINAL;  (* 2 *)
                          datum:                        CARDINAL;  (* 2 *)
                        END (* einPufferDeskriptor *); (* TSIZE =    *)

VAR     PuffRecSize: (*TSIZE (einPufferDeskriptor)*) LONGCARD;

(* Von ScreenBase *)

CONST   (* Definition wichtiger ASCII-Codes (NICHT Tastencodes! *)
        nul =           0C;     (* ASCII-Nul, kein Zeichen *)

        bel =           07C;
        backspace =     10C;    (* rueckwaerts loeschen *)
        tab =           11C;    (* in 8er-Positionen einruecken *)

        (* Bildschirmattribute: *)

        hasinsert =     FALSE;
        hasdelete =     FALSE;

        escape =        33C;
        lf =            12C;
        cr =            15C;

        linedel =      115C;
        lineins =      114C;
        
        Ja =            1;
        Nein =          2;
        Abbruch =       3;

TYPE    einButton =        (Left, Right);
        ButtonSet =        SET OF einButton;

VAR     ScreenHandle:                 DeviceHandle;
        ApId:                         GemHandle;
        WindowHandle:                 CARDINAL;
        CharWidth, CharHeight:        CARDINAL;
        ScreenWidth, ScreenHeight:    CARDINAL;
        LineHeight:                   CARDINAL;
                                      
        CharsInLine:                  CARDINAL;
        LinesOnScreen:                CARDINAL;

(* Von EditBefehle *)
        
TYPE    einBefehl =
 (nothing,
 
 (* Cursorbewegungen: *)
  cursup, cursdown, cursleft, cursright,
  Rollup, Rolldown, RollLeft, RollRight, RollFLeft, RollFRight,
  Wortleft, Wortrigt, ZeilAnf, ZeilEnde,
  Seitup, Seitdown, zumDAnf, zumDEnde, home, InsertBlank,
  Bildoben, Bildunten,
  tabulator, backtab, return,

 (* Maustasten: *)
  LeftMous, RightMous,
 
 (* Suchen & Tauschen: *)
  SuchString, StriTausch, SuchWort, WortTausch, PickWort, PickTausch,
  WeitSuch, QueryError, (* naechste Compilerfehlermeldung *)
  Lookup,
 
 (* Lîschen/EinfÅgen: *)
  DelLChar, DelRChar, DelLWort, DelRWort, DelBZeil, DelEZeil,
  PopDeleteLine, PopCopyLine,
  RestoreCurrentLine, CopyLastBufferLine, PopLastBufferLine, ZeilIns,
  
 (* Modus/Parameter: *)
  insert, indent, TextProg, RandOffset, TabLaen,
  TextParam, GlobParam, LoadParam, BackupAnlegen,
  SteuerZeichenAnzeige,
  Grossklein, Wortsuche,
  
 (* Marken, Goto: *)
  set1Mark, set2Mark, set3Mark, zur1Mark, zur2Mark, zur3Mark,
  setAMark, setEMark, zurAMark, zurEMark,
  zuNrZeile, LetztePos, (* Letzte Editstelle *) LetzteSuchPos,
  
 (* Dynamische Merker: *)
  MerkList, MerkPunkt, SetzList, SetzPunkt,
  WaehleListe,

 (* Blockmarken/Operationen: *)
  BlockMLoe, CopyToClipboard, CutToClipboard, DeleteBlock, Paste, Kopier,
  Verschieb, GEMKlemmbrettEinAus, Einrueck, SelectWord, SelectLine,
  SelectParagraph, SelectAll,

 (* Laden/Speichern/Lîschen: *)
  TextLoad, TextSave, BlockRead, BlockWrit, Update,
  LoescheText,
  TextFragLad, LoescheAllePuffer, SpeichereAllePuffer,
  LoadFiles,
  
 (* Puffer setzen: *)
  SetHelp, InsertPuff,
  PufferWaehlen, NaechstenPuffer,
  LoeschUndo, KillPuff, LoeschAlle,

 (* Metabefehle: *)
  ExitEditor,
  Quit, QuitCompile, QuitCompileRun, Compile, Make, MakeExec,
  help, EditBlock,
  TextVergleich, ZeitUndDatum,
  CallFilebox (* Pfad Ñndern *), GMECopyrightBox,

 (* Verschiedene: *)
  AsciiOrd,

  error);

        Befehlssatz =   SET OF einBefehl;

(* Von EditBuffer *)

PROCEDURE InitBuffer;

VAR     UndoPuffer:             einPufferPointer; (* eineZeile; *)
        ClipBoard:              einPufferPointer;
        HilfsPuffer:            einPufferPointer;
        ConfigPuffer:           einPufferPointer;
        EditPuffer:             einPufferPointer;
        AlternEdit:             einPufferPointer;
        DruckPuff:              einPufferPointer;
        FehlerPuffer:           einPufferPointer;
        MailPuffer:             einPufferPointer;
        GolemPuffer:            einPufferPointer;
        SendePuffer:            einPufferPointer;
        Tausch:                 einPufferPointer;
        PSCPuffer:              einPufferPointer;
        LoadPuffer:             einPufferPointer;
        DruckerBatch:           einPufferPointer;
        TextVergleichP:         einPufferPointer;
        WaehlPuffer:            einPufferPointer;
        StartPuffer:            einPufferPointer;
        Puffer1, Puffer2,
        Puffer3, Puffer4:       einPufferPointer;
        
        undone:                 BOOLEAN;

(* Von KeyBase *)

CONST   cTastaturEbenen =       15;

CONST   MinScanCode =   1;
        MaxScanCode =   131;


TYPE    einStatusKey = (Shift, Control, Alternate, Caps,
                        RMouse, LMouse);

        einStatus =     SET OF einStatusKey;

        einKey = (NoKey,
        
    (* Funktionstasten: *)
  F1, F2, F3, F4, F5, F6, F7, F8, F9, F10,

    (* Tastaturblock: *)
  TEsc, T1, T2, T3, T4, T5, T6, T7, T8, T9, T0, Tsz, TApo, TNum, TBackspace,
  TTab, Tq, Tw, Te, Tr, Tt, Tz, Tu, Ti, To, Tp, Tue, TPlus, TRet, TDel,
  Ta, Ts, Td, Tf, Tg, Th, Tj, Tk, Tl, Toe, Tae, TTild,
  TGr, Ty, Tx, Tc, Tv, Tb, Tn, Tm, TKomma, TPunkt, TMinus,
  TLeer,
  
    (* Cursorblock: *)
  CHelp, CUndo, CInsert, CUp, CHome,
  CLeft, CDown, CRight,
  
    (* Numerikblock: *)
  NLeftp, NRightp, NSlash, NAsterix,
  N7, N8, N9, NMinus,
  N4, N5, N6, NPlus,
  N1, N2, N3,
  N0, NPoint, NEnter, KeyError);

TYPE    eineScanTabelle =  ARRAY [MinScanCode..MaxScanCode] OF einKey;

VAR     ScanTab:        eineScanTabelle;
  
  PROCEDURE KeyReady(): BOOLEAN;
  PROCEDURE ReadKey (VAR k: einKey; VAR s: einStatus);
  PROCEDURE KillKeyInput;
  PROCEDURE TastInit;
  PROCEDURE Init;
  PROCEDURE TastReset;

(* ScreenBase *)

PROCEDURE GetVersion (VAR version: ARRAY OF CHAR);
  
PROCEDURE WrapOff;
PROCEDURE WrapOn;

PROCEDURE WriteChar (c: CHAR);
PROCEDURE WriteLine (REF s: ARRAY OF CHAR);
(* schnelle Stringausgabe, kein LF *)
PROCEDURE WriteConst (REF s: ARRAY OF CHAR);

PROCEDURE Trace (REF s: ARRAY OF CHAR);
PROCEDURE WriteLn; (* CR + LF *)
PROCEDURE InsertLn;
PROCEDURE DeleteLn;
PROCEDURE WhereXY (VAR x, y: CARDINAL);
PROCEDURE GotoXY (x, y: CARDINAL);
PROCEDURE CursorEin;
PROCEDURE CursorAus;
PROCEDURE CursorStumm;
PROCEDURE CursorSchnell;
PROCEDURE LoescheZeile;
PROCEDURE LoescheBild;
PROCEDURE LoescheEndeBild;
PROCEDURE HighLight;
PROCEDURE Normal;

PROCEDURE MausEin;
PROCEDURE MausAus;
PROCEDURE MausBusy;

PROCEDURE MausPos (VAR x, y: CARDINAL; VAR bewegt: BOOLEAN;
                   VAR Knoepfe: ButtonSet);

PROCEDURE MausDoppel (VAR x, y: CARDINAL; VAR bewegt: BOOLEAN;
                   VAR Knoepfe: ButtonSet);

PROCEDURE Nachricht (REF m: ARRAY OF CHAR);
PROCEDURE FrageJaNein (default: CARDINAL; m: ARRAY OF CHAR): BOOLEAN;
PROCEDURE Auswahl (VAR default: CARDINAL; m: ARRAY OF CHAR);
PROCEDURE TopBox;
PROCEDURE ClearAES;

(* Von EditBase *)

VAR     AutoCount:      CARDINAL;
VAR     DoClipboard:    BOOLEAN;

PROCEDURE PuffInit (VAR Puff: einPufferPointer);
PROCEDURE Loeschen (VAR Puff: einPufferPointer);
PROCEDURE PufferLeer (Puff: einPufferPointer): BOOLEAN;
PROCEDURE InsertPuffer (Puff: einPufferPointer): einPufferPointer;
PROCEDURE FindeLeerpuffer (Puff: einPufferPointer): einPufferPointer;
PROCEDURE DeletePuffer (VAR Puff: einPufferPointer);
PROCEDURE GetLine (p: einLinePointer; VAR s: ARRAY OF CHAR);
  (* Kopiere Zeileninhalt in String *)
PROCEDURE PutConstLine (VAR p: einLinePointer; REF s: ARRAY OF CHAR);
PROCEDURE PutLine (VAR p: einLinePointer;
                   REF s: ARRAY OF CHAR);
  (* Kopiere String in eine Zeile (Allocate optimiert) *)
PROCEDURE DeAllocLine (VAR p: einLinePointer);
PROCEDURE AllocLine (VAR p: einLinePointer; groesse: CARDINAL);

(************************** Von EditDirectory *****************)

PROCEDURE GetDirectory (VAR Pfad, FileName: ARRAY OF CHAR;
                        Meldung: ARRAY OF CHAR;
                        VAR Butt: INTEGER; GEM: BOOLEAN);
PROCEDURE GetPfad (VAR pf: ARRAY OF CHAR);
PROCEDURE DeleteTail (VAR s: ARRAY OF CHAR);

END GMEBase.

