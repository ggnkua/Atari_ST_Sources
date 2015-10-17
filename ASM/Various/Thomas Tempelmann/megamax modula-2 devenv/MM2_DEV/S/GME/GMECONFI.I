
(*      GMEConfig
        ---------

  Stand: 21.05.91                           (c) 1990 by Johannes Leckebusch

  Dieses Modul enthÑlt die Konfiguration der Benutzerschnittstelle.
  Sein Quelltext steht erfahrenen Programmierern zur VerfÅgung, damit
  sie sich die Bedienung des Editors - insbesondere die Tastaturbelegung -
  nach eigenen WÅnschen anpassen kînnen. Eine Anleitung hierzu finden Sie in
  Abschnitt 5.1 und 5.2 des GME-Handbuchs.

  ACHTUNG: Die beiden im folgenden auskommentierten Definitionen
  von GMEBase und GMEConfig sind vorher zu Åbersetzen, um die benîtigten
  DEF-Files zu erhalten!

-------------------------------------------------------------------------------
18.12.90    Verîffentlichung mit MM2 Version 2.2
19.02.91    Die KbdEvents werden ggf. wieder deinstalliert.
09.03.91    GME Version 1.1: "LiesTaste" liefert RightMous/Leftmous wiederholt
            solange, wie die Taste niedergedrÅckt bleibt.
21.05.91    Definitionstexte aktualisiert, so daû kein Versionskonflikt mehr
            bei NeuÅbersetzung auftritt.
-------------------------------------------------------------------------------
*)

(*
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

DEFINITION MODULE GMEConfig;
(*$Z+*)

FROM GMEBase IMPORT
  einKey, einStatus, cTastaturEbenen, einLinePointer, einPufferPointer,
  einBefehl;

TYPE    einTastenTyp =          (keineTaste, Zeichen, Befehl, String,
                                 Makro, Mausklick, Tastenebene);

        einTastaturPointer =    POINTER TO eineTastenEbene;
        einMakroPointer =       POINTER TO einMakro;

        einTasteneintrag =      RECORD
                                  CASE TT: einTastenTyp OF
                                    keineTaste: |
                                    Zeichen:    zch:    CHAR;|
                                    Befehl:     bef:    einBefehl;|
                                    String:     str:    einLinePointer;|
                                    Makro:      mak:    einMakroPointer;|
                                    Mausklick:  x, y:   CARDINAL;|
                                    Tastenebene: teb:   einTastaturPointer;|
                                  END (* CASE *);
                                END (* einTasteneintrag *);
 
        einMakro =              RECORD
                                  makro:        einTasteneintrag;
                                  next:         einMakroPointer;
                                END;

        eineTastenEbene =       ARRAY einKey OF einTasteneintrag;
        eineTastatur =          ARRAY [0..cTastaturEbenen] OF einTastaturPointer;
 
VAR     Tastatur:               eineTastatur;
        ConfigInit:     BOOLEAN;

PROCEDURE TastaturIndex (s: einStatus): CARDINAL;
PROCEDURE NewTastenebene (VAR T: einTastaturPointer);
PROCEDURE RemoveTastenebene (VAR T: einTastaturPointer);
PROCEDURE InitTastenebene (keyStatus: einStatus; T: einTastaturPointer);
PROCEDURE InitTastatur (VAR T: eineTastatur);
PROCEDURE SetTaste (key: einKey; T: einTastaturPointer;
                    eintrag: einTasteneintrag);
PROCEDURE LiesTastMaus (VAR t: einTasteneintrag; keys: einStatus);
PROCEDURE LiesBefehl (VAR b: einBefehl);
PROCEDURE LiesTaste (VAR t: einTasteneintrag);
PROCEDURE LiesZeichen (VAR ch: CHAR);
PROCEDURE TasteBereit(): BOOLEAN;
PROCEDURE LoescheQueue;
PROCEDURE InitConfig (VAR Puff: einPufferPointer);
PROCEDURE CopyConfig (VAR Q, Z: einPufferPointer);

END GMEConfig.
*)

IMPLEMENTATION MODULE GMEConfig;

(*$Y+*)
(*$R-*)
(*$Z+*)

IMPORT EasyGEM0;

FROM SYSTEM IMPORT CAST, BYTE;
FROM Granule IMPORT ALLOCATE, DEALLOCATE;
FROM SystemError IMPORT OutOfMemory;
FROM PrgCtrl IMPORT TermProcess, CatchProcessTerm, TermCarrier;
FROM Paths IMPORT SearchFile, ListPos;
FROM PathEnv IMPORT HomePath;
FROM ShellMsg IMPORT StdPaths, ShellPath;
FROM SysUtil0 IMPORT VarEqual;
FROM UserBreak IMPORT DisableBreak;
FROM KbdEvents IMPORT KbdEventsInstalled, InstallKbdEvents, DeInstallKbdEvents;
FROM MOSGlobals IMPORT MemArea;

FROM AESResources IMPORT LoadResource, ResourcePart, ResourceAddr;
FROM AESMenus IMPORT MenuBar, NormalTitle, CheckItem, EnableItem;
FROM AESEvents IMPORT Event, EventSet, menuSelected, windRedraw, unspecMessage,
  RectEnterMode, MessageBuffer, MultiEvent, KeyboardEvent;
FROM AESWindows IMPORT UpdateWindow;
FROM GEMGlobals IMPORT PtrObjTree, GemChar, MouseButton, MButtonSet,
  SpecialKey, SpecialKeySet;
FROM GEMEnv IMPORT GemError;
FROM GrafBase IMPORT Point, Rectangle, Rect;
FROM VDIInputs IMPORT GetMouseState;
FROM GMEBase IMPORT MausEin, Nachricht, CursorAus, ClearAES,
  ScreenHandle, WriteLine, WriteLn, WriteConst, WriteChar, GotoXY,
  LoescheZeile;

FROM GMEBase IMPORT einKey, einStatus, einStatusKey, cTastaturEbenen,
        ReadKey, KeyReady, KillKeyInput, ScanTab, eineScanTabelle;

FROM GMEBase IMPORT cRevision, cZeile, cTabWeite, cSchreibZaehler;
FROM GMEBase IMPORT einLinePointer, CharSet, Mode, Moden, eineInfo,
  einPufferPointer;
FROM GMEBase IMPORT einBefehl;
FROM GMEBase IMPORT EditPuffer, ClipBoard, ConfigPuffer;
FROM GMEBase IMPORT PufferLeer;

FROM GMEBase IMPORT DoClipboard;

CONST   nul =   0C;

VAR     Menu:                   PtrObjTree;
        noClicks:               CARDINAL;
        butMask, butState:      MButtonSet;
        moveDirec1, moveDirec2: RectEnterMode;
        rect1Size, rect2Size:   Rectangle;
        msg:                    MessageBuffer;
        time:                   LONGCARD;
        mouseLoc, oldLoc:       Point;
        buttons:                MButtonSet;
        keyState:               SpecialKeySet;
        key:                    GemChar;
        doneClicks:             CARDINAL;
        occuredEvents:          EventSet;
        MenuBefehl:             CARDINAL;

CONST
(* Vom Resource Construction Set: *)
(*
        ACHTUNG!!!

   Wenn Sie die GEM-Resource-Datei Ñndern, mÅssen Sie aus dem
   davon erzeugten D-Modul die nachfolgenden Konstanten neu
   Åbernehmen. Beachten Sie auch die nachfolgende Initialisierung
   der MenuTabelle und die Konstante "cMaxMenu" unten!!!
*)

CONST
  Gmemenue =   0;  (* Menuebaum *)
  Deskmenu =   3;  (* TITLE in Baum GMEMENUE *)
  Datemenu =   4;  (* TITLE in Baum GMEMENUE *)
  Blockmen =   5;  (* TITLE in Baum GMEMENUE *)
  Markmenu =   6;  (* TITLE in Baum GMEMENUE *)
  Suchmenu =   7;  (* TITLE in Baum GMEMENUE *)
  Editmenu =   8;  (* TITLE in Baum GMEMENUE *)
  Programm =   9;  (* TITLE in Baum GMEMENUE *)
  Golemedi =  12;  (* STRING in Baum GMEMENUE *)
  Acc1     =  14;  (* STRING in Baum GMEMENUE *)
  Acc2     =  15;  (* STRING in Baum GMEMENUE *)
  Acc3     =  16;  (* STRING in Baum GMEMENUE *)
  Acc4     =  17;  (* STRING in Baum GMEMENUE *)
  Acc5     =  18;  (* STRING in Baum GMEMENUE *)
  Acc6     =  19;  (* STRING in Baum GMEMENUE *)
  Neuertex =  22;  (* STRING in Baum GMEMENUE *)
  Laden    =  23;  (* STRING in Baum GMEMENUE *)
  Bllesen  =  24;  (* STRING in Baum GMEMENUE *)
  Sichern  =  26;  (* STRING in Baum GMEMENUE *)
  Speicher =  27;  (* STRING in Baum GMEMENUE *)
  Blspeich =  28;  (* STRING in Baum GMEMENUE *)
  Textloes =  29;  (* STRING in Baum GMEMENUE *)
  Konfigea =  31;  (* STRING in Baum GMEMENUE *)
  Backupan =  32;  (* STRING in Baum GMEMENUE *)
  Konfigsi =  34;  (* STRING in Baum GMEMENUE *)
  Qallsave =  35;  (* STRING in Baum GMEMENUE *)
  Ende     =  36;  (* STRING in Baum GMEMENUE *)
  Blcut    =  38;  (* STRING in Baum GMEMENUE *)
  Blversch =  39;  (* STRING in Baum GMEMENUE *)
  Blkkopie =  40;  (* STRING in Baum GMEMENUE *)
  Bledit   =  41;  (* STRING in Baum GMEMENUE *)
  Blanfang =  43;  (* STRING in Baum GMEMENUE *)
  Blende   =  44;  (* STRING in Baum GMEMENUE *)
  Zeilmark =  45;  (* STRING in Baum GMEMENUE *)
  Allmark  =  46;  (* STRING in Baum GMEMENUE *)
  Gemscrap =  48;  (* STRING in Baum GMEMENUE *)
  Setzema1 =  50;  (* STRING in Baum GMEMENUE *)
  Setzema2 =  51;  (* STRING in Baum GMEMENUE *)
  Setzema3 =  52;  (* STRING in Baum GMEMENUE *)
  Zumarke1 =  53;  (* STRING in Baum GMEMENUE *)
  Zumarke2 =  54;  (* STRING in Baum GMEMENUE *)
  Zumarke3 =  55;  (* STRING in Baum GMEMENUE *)
  Zeilennr =  57;  (* STRING in Baum GMEMENUE *)
  Letztepo =  58;  (* STRING in Baum GMEMENUE *)
  Fehlerme =  60;  (* STRING in Baum GMEMENUE *)
  Wortsuch =  62;  (* STRING in Baum GMEMENUE *)
  Grosskle =  63;  (* STRING in Baum GMEMENUE *)
  Suche    =  65;  (* STRING in Baum GMEMENUE *)
  Tausche  =  66;  (* STRING in Baum GMEMENUE *)
  Pickwort =  67;  (* STRING in Baum GMEMENUE *)
  Picktaus =  68;  (* STRING in Baum GMEMENUE *)
  Nochmsuc =  69;  (* STRING in Baum GMEMENUE *)
  Overwrit =  71;  (* STRING in Baum GMEMENUE *)
  Autoinde =  72;  (* STRING in Baum GMEMENUE *)
  Next     =  74;  (* STRING in Baum GMEMENUE *)
  Help     =  75;  (* STRING in Baum GMEMENUE *)
  Bleinrue =  77;  (* STRING in Baum GMEMENUE *)
  Mcompile =  79;  (* STRING in Baum GMEMENUE *)
  Datum    =  80;  (* STRING in Baum GMEMENUE *)
  Compilie =  82;  (* STRING in Baum GMEMENUE *)
  Comprun  =  83;  (* STRING in Baum GMEMENUE *)
  Qmake    =  84;  (* STRING in Baum GMEMENUE *)
  Makeexec =  85;  (* STRING in Baum GMEMENUE *)
  Gmeinfo  =   1;  (* Formular/Dialog *)
  Version  =   5;  (* STRING in Baum GMEINFO *)
(* ***************************************** *)

CONST   cMaxMenu =              86;
VAR     MenuTabelle:            ARRAY [0..cMaxMenu] OF einBefehl;

PROCEDURE InitMenuTabelle;
BEGIN

(* GME                *) MenuTabelle [Deskmenu] := nothing;
(* ================== *)
(* Der Golemeditor    *) MenuTabelle [Golemedi] := GMECopyrightBox;
(* ------------------ *)
(*    Accessories     *) MenuTabelle [Acc1    ] := nothing;
(*                    *) MenuTabelle [Acc2    ] := nothing;
(*                    *) MenuTabelle [Acc3    ] := nothing;
(*                    *) MenuTabelle [Acc4    ] := nothing;
(*                    *) MenuTabelle [Acc5    ] := nothing;
(*    Accessories     *) MenuTabelle [Acc6    ] := nothing;

(* Datei              *) MenuTabelle [Datemenu] := nothing;
(* ================== *)
(* Konfiguration spei *) MenuTabelle [Konfigea] := TextParam;
(* ------------------ *)
(* Neu                *) MenuTabelle [Neuertex] := InsertPuff;
(* ôffnen             *) MenuTabelle [Laden   ] := TextLoad;
(* EinfÅgen           *) MenuTabelle [Bllesen ] := BlockRead;
(* ------------------ *)
(* Sichern            *) MenuTabelle [Sichern ] := Update;
(* Sichern mit Frage  *) MenuTabelle [Speicher] := TextSave;
(* Block Sichern...   *) MenuTabelle [Blspeich] := BlockWrit;
(* Schlieûen          *) MenuTabelle [Textloes] := LoescheText;
(* ------------------ *)
(* Backup anlegen     *) MenuTabelle [Backupan] := BackupAnlegen;
(* Parameter Sichern  *) MenuTabelle [Konfigsi] := GlobParam;
(* Quit alles Sichern *) MenuTabelle [Qallsave] := SpeichereAllePuffer;
(* Beenden            *) MenuTabelle [Ende    ] := ExitEditor;

(* Block              *) MenuTabelle [Blockmen] := nothing;
(* ================== *)
(* Ausschneiden       *) MenuTabelle [Blcut   ] := CutToClipboard;
(* Merken             *) MenuTabelle [Blversch] := CopyToClipboard;
(* EinfÅgen           *) MenuTabelle [Blkkopie] := Paste;
(* Editieren          *) MenuTabelle [Bledit  ] := EditBlock;
(* ------------------ *)
(* Anfang markieren   *) MenuTabelle [Blanfang] := setAMark;
(* Ende markieren     *) MenuTabelle [Blende  ] := setEMark;
(* Wort markieren     MenuTabelle [Wortmark] := SelectWord; *)
(* Zeile markieren    *) MenuTabelle [Zeilmark] := SelectLine;
(* Alles markieren    *) MenuTabelle [Allmark ] := SelectAll;
(* ------------------ *)
(* GEM-Klemmbrett     *) MenuTabelle [Gemscrap] := GEMKlemmbrettEinAus;

(* Marken             *) MenuTabelle [Markmenu] := nothing;
(* ================== *)
(* Setze Marke 1      *) MenuTabelle [Setzema1] := set1Mark;
(* Setze Marke 2      *) MenuTabelle [Setzema2] := set2Mark;
(* Setze Marke 3      *) MenuTabelle [Setzema3] := set3Mark;
(* Zu Marke 1         *) MenuTabelle [Zumarke1] := zur1Mark;
(* Zu Marke 2         *) MenuTabelle [Zumarke2] := zur2Mark;
(* Zu Marke 3         *) MenuTabelle [Zumarke3] := zur3Mark;
(* ------------------ *)
(* Zu Zeilennummer    *) MenuTabelle [Zeilennr] := zuNrZeile;
(* Letzte Position    *) MenuTabelle [Letztepo] := LetztePos;
(* ------------------ *)
(* Zur Fehlermeldung  *) MenuTabelle [Fehlerme] := QueryError;

(* Suchen             *) MenuTabelle [Suchmenu] := nothing;
(* ================== *)
(* Grossklein         *) MenuTabelle [Grosskle] := Grossklein;
(* Wort suchen        *) MenuTabelle [Wortsuch] := Wortsuche;
(* ------------------ *)
(* Suchen...          *) MenuTabelle [Suche   ] := SuchString;
(* Tauschen...        *) MenuTabelle [Tausche ] := StriTausch;
(* Pick Wort          *) MenuTabelle [Pickwort] := PickWort;
(* Pick Tauschen      *) MenuTabelle [Picktaus] := PickTausch;
(* Nochmal Suchen     *) MenuTabelle [Nochmsuc] := WeitSuch;

(* Editieren          *) MenuTabelle [Editmenu] := nothing;
(* ================== *)
(* öberschreiben      *) MenuTabelle [Overwrit] := insert;
(* Automatisch EinrÅck*) MenuTabelle [Autoinde] := indent;
(* ------------------ *)
(* NÑchster Text      *) MenuTabelle [Next    ] := NaechstenPuffer;
(* Hintergrund        *) MenuTabelle [Help    ] := help;
(* ------------------ *)
(* Block EinrÅcken    *) MenuTabelle [Bleinrue] := Einrueck;

(*
(* Bildschirm         *) MenuTabelle [Bildschi] := nothing;
(* ------------------ *)
(* Hochrollen         *) MenuTabelle [Scrollup] := Rollup;
(* Runterrollen       *) MenuTabelle [Scroldow] := Rolldown;
(* ------------------ *)
(* Wort links         *) MenuTabelle [Wortlink] := Wortleft;
(* Wort rechts        *) MenuTabelle [Wortrech] := Wortrigt;
(* Zeilenanfang       *) MenuTabelle [Zeilanfa] := ZeilAnf;
(* Zeilenende         *) MenuTabelle [Zeilende] := ZeilEnde;
(* Seite nach oben    *) MenuTabelle [Seithoch] := Seitup;
(* Seite nach unten   *) MenuTabelle [Seitrunt] := Seitdown;
(* Zum Textanfang     *) MenuTabelle [Ctextanf] := zumDAnf;
(* Zum Textende       *) MenuTabelle [Ctextend] := zumDEnde;
*)

(* Programm           *) MenuTabelle [Programm] := nothing;
(* ------------------ *)
(* Compilieren        *) MenuTabelle [Mcompile] := Compile;
(* Make               *) MenuTabelle [Qmake   ] := Make;
(* Make & Run         *) MenuTabelle [Makeexec] := MakeExec;
(* Datum              *) MenuTabelle [Datum   ] := ZeitUndDatum;
(* ------------------ *)
(* Q-Compilieren      *) MenuTabelle [Compilie] := QuitCompile;
(* Q-Comp. & Run      *) MenuTabelle [Comprun ] := QuitCompileRun;

END InitMenuTabelle;

PROCEDURE CopyConfig (VAR Q, Z: einPufferPointer);
BEGIN
  WITH Z^ DO
    MagicRevision := cRevision;
    Modus := Q^.Modus;
    Max := Q^.Max;
    TabWeite := Q^.TabWeite;
    SchreibZaehler := Q^.SchreibZaehler;
  END (* WITH *);
END CopyConfig;

(* Die folgende Prozedur bestimmt die Einstellung des Editors beim Start. *)

PROCEDURE InitConfig (VAR Puff: einPufferPointer);
BEGIN
  IF ~ConfigInit THEN
    WITH Puff^ DO
      MagicRevision := cRevision;
(*
      (* Beispiel 1: Automatisch einrÅcken, BAK-Datei erzeugen *)
      Modus := Moden {ControlZeichen, AutoIndent, TabFiltern, MakeBAK};
*)
      (* Beispiel 2: Auûerdem Konfiguration laden u. zu Texten speichern *
       *             keine BAK-Datei erzeugen                            *)
      Modus := Moden {ControlZeichen, AutoIndent, TabFiltern,
                      KonfigSpeichern, WortSuche};
      Pfad := ''; Name := '';
      Max := cZeile;
      TabWeite := cTabWeite;
      SchreibZaehler := cSchreibZaehler;
    END (* WITH *);
  ELSE
    WITH Puff^ DO
      MagicRevision := cRevision;
      Modus := ConfigPuffer^.Modus;
      Pfad := ConfigPuffer^.Pfad; (* ??? *)
      Name := '';
      Max := ConfigPuffer^.Max;
      TabWeite := ConfigPuffer^.TabWeite;
      SchreibZaehler := ConfigPuffer^.SchreibZaehler;
    END (* WITH *);
  END (* IF ConfigInit *);
END InitConfig;


PROCEDURE ShowGMEInfo;
  VAR button: CARDINAL;
  BEGIN
    EasyGEM0.DoSimpleBox (ResourceAddr (treeRsrc, Gmeinfo),
      Rect (-1,-1,-1,-1), button);
  END ShowGMEInfo;

PROCEDURE TasteBereit(): BOOLEAN;
BEGIN RETURN (* KeyReady() *) TRUE; END TasteBereit;

PROCEDURE LoescheQueue;
VAR     k: einKey;
        localEvents: EventSet;
BEGIN
  (* UpdateWindow (FALSE); *)
  REPEAT
    (* KeyBoardEvent (key); *)
    (* hm... wie soll das gehen, ehe ich nicht weiû, ob noch
       KeyBoardEvents anhÑngig sind??? *)
    MultiEvent (EventSet {keyboard, timer},
                0, butMask, butState,
                moveDirec1, rect1Size,
                moveDirec2, rect2Size,
                msg, time, mouseLoc, buttons,
                keyState, key, doneClicks, localEvents);
    
  UNTIL ~(keyboard IN localEvents);
  (* UpdateWindow (TRUE); *)
END LoescheQueue;

PROCEDURE TastaturIndex (s: einStatus): CARDINAL;
CONST   cTastaturLimit =        cTastaturEbenen + 1;
BEGIN
  RETURN ORD (CAST (BYTE, s)) MOD cTastaturLimit;
END TastaturIndex;

PROCEDURE StatusVonKeySet (ks: SpecialKeySet): einStatus;
(* Oh Gott - dies ev. in Atzempler machen - oder wie??? *)
VAR     c:      CARDINAL;
BEGIN
  c := ORD (CAST (BYTE, ks)) DIV 2;
  IF ODD (ORD (CAST (BYTE, ks))) THEN INC (c); END;
  RETURN CAST (einStatus, c);
END StatusVonKeySet;

PROCEDURE NewTastenebene (VAR T: einTastaturPointer);
BEGIN
  NEW (T);
  IF T = NIL THEN OutOfMemory END;
END NewTastenebene;

PROCEDURE RemoveTastenebene (VAR T: einTastaturPointer);
BEGIN
  IF T # NIL THEN DISPOSE (T); END;
END RemoveTastenebene;

PROCEDURE SetTaste (key: einKey; T: einTastaturPointer;
                    eintrag: einTasteneintrag);
BEGIN
  T^ [key] := eintrag;
END SetTaste;

PROCEDURE ShiftAscii (keyStatus: einStatus; ch: CHAR): CHAR;
BEGIN
  IF (Caps IN keyStatus) & (ch IN CharSet {'a'..'z', 'Ñ', 'î', 'Å'}) THEN
                (* Hier fehlen ev. noch kleine Zeichen mit Akzenten... *)
    (* das kann MM2 besser:
      IF ((ch >= 'a') & (ch <= 'z'))
      THEN ch := CHR (ORD (ch) - 32);
      ELSE CASE ch OF
        'Ñ':      ch := 'é';|
        'î':      ch := 'ô';|
        'Å':      ch := 'ö';|
        ELSE;
        END (* CASE *);
      END (* IF *);
      RETURN ch;
    *)
    RETURN CAP (ch)
  END;
  IF Shift IN keyStatus THEN
    (* auch hier mÅûte CAP besser tun:
      ch := CHR (ORD (ch) - 32);
      RETURN ch;
    *)
    RETURN CAP (ch)
  END;
  IF Control IN keyStatus THEN
    RETURN CHR (ORD (ch) - 96);
  END;
  RETURN ch;
END ShiftAscii;

PROCEDURE InitFunktionstasten (keyStatus: einStatus; T: einTastaturPointer);
VAR     key:    einKey;

  PROCEDURE SetzF (f1, f2, f3, f4, f5, f6, f7, f8, f9, f0: einBefehl);
  BEGIN
    T^ [F1].bef := f1;
    T^ [F2].bef := f2;
    T^ [F3].bef := f3;
    T^ [F4].bef := f4;
    T^ [F5].bef := f5;
    T^ [F6].bef := f6;
    T^ [F7].bef := f7;
    T^ [F8].bef := f8;
    T^ [F9].bef := f9;
    T^ [F10].bef := f0;
  END SetzF;
  
  PROCEDURE SetzC (Esc, Tab, Backspace, Delete, Return,
        Help, Undo, Insert, Up, Home, Left, Down, Right: einBefehl);
  BEGIN
    T^ [TEsc       ].bef := Esc;
    T^ [TTab       ].bef := Tab;
    T^ [TBackspace ].bef := Backspace;
    T^ [TDel       ].bef := Delete;
    T^ [TRet       ].bef := Return;
    T^ [NEnter     ].bef := Return;
    T^ [CHelp      ].bef := Help;
    T^ [CUndo      ].bef := Undo;
    T^ [CInsert    ].bef := Insert;
    T^ [CUp        ].bef := Up;
    T^ [CHome      ].bef := Home;
    T^ [CLeft      ].bef := Left;
    T^ [CDown      ].bef := Down;
    T^ [CRight     ].bef := Right;
  END SetzC;

BEGIN (* InitFunktionstasten *)
  FOR key := F1 TO F10 DO
    WITH T^ [key] DO
      TT := Befehl;
    END (* WITH *);
  END (* FOR *);
  FOR key := CHelp TO CRight DO
    WITH T^ [key] DO
      TT := Befehl;
    END (* WITH *);
  END (* FOR *);
  T^ [TEsc      ].TT := Befehl;
  T^ [TTab      ].TT := Befehl;
  T^ [TBackspace].TT := Befehl;
  T^ [TDel      ].TT := Befehl;
  T^ [TRet      ].TT := Befehl;
  T^ [NEnter    ].TT := Befehl;
  IF (keyStatus = einStatus {}) OR (keyStatus = einStatus {Caps}) THEN
    SetzF (SuchString, StriTausch, PickWort, WeitSuch, nothing,
           Paste, zurAMark, zurEMark, zur1Mark, zur2Mark);
    SetzC (Quit, tabulator, DelLChar, DelRChar, return,
           help, RestoreCurrentLine,
           insert, cursup, PopCopyLine,
           cursleft, cursdown, cursright);
  ELSIF (keyStatus = einStatus {Shift}) OR (keyStatus = einStatus {Shift, Caps}) THEN
    SetzF (SuchWort, WortTausch, PickTausch, zuNrZeile, QueryError,
           CopyToClipboard, setAMark, setEMark, set1Mark, set2Mark);
    SetzC (QuitCompile, backtab, DelLWort, DelRWort, return,
           EditBlock, CopyLastBufferLine,
           indent, Seitup, PopDeleteLine,
           Wortleft, Seitdown, Wortrigt);
    T^ [NMinus].TT := Befehl; T^ [NMinus].bef := Rolldown;
    T^ [NPlus].TT := Befehl;  T^ [NPlus].bef := Rollup;
  ELSIF (keyStatus = einStatus {Control}) OR (keyStatus = einStatus {Control, Caps}) THEN
    SetzC (QuitCompileRun, ZeilEnde, DelBZeil, DelEZeil, return,
           nothing, PopLastBufferLine,
           Paste, zumDAnf, DeleteBlock,
           ZeilAnf, zumDEnde, ZeilEnde);
  ELSIF (keyStatus = einStatus {Alternate}) OR (keyStatus = einStatus {Alternate, Caps}) THEN
    SetzC (Quit, tabulator, DelLChar, PopDeleteLine, return,
           help, RestoreCurrentLine,
           PopCopyLine, cursup, home,
           cursleft, cursdown, cursright);
  END (* IF *);
END InitFunktionstasten;

PROCEDURE InitTastenebene (keyStatus: einStatus; T: einTastaturPointer);
VAR     key:    einKey;
        ch:     CHAR;
BEGIN
  (* Vorinitialisierung: *)
  FOR key := NoKey TO KeyError DO
    WITH T^ [key] DO
      TT := Zeichen; zch := nul;
    END (* WITH *);
  END (* FOR *);
END InitTastenebene;

PROCEDURE SetControl (t: einTastaturPointer;
                      k: einKey; b: einBefehl);
BEGIN
  WITH t^[k] DO
    TT := Befehl; bef := b;
  END (* WITH *);
END SetControl;


PROCEDURE CtrlZeich (t: einTastaturPointer; k: einKey);
BEGIN
  NewTastenebene (t^ [k].teb); t^ [k].TT := Tastenebene;
  InitTastenebene (einStatus {Control}, t^ [k].teb);
END CtrlZeich;

PROCEDURE CtrlKEbene (t: einTastaturPointer; k: einKey);
BEGIN
  NewTastenebene (t^ [k].teb); t^ [k].TT := Tastenebene;
  InitTastenebene (einStatus {}, t^ [k].teb);
  WITH t^ [k] DO
    SetControl (teb, T1, set1Mark);
    SetControl (teb, T2, set2Mark);
    SetControl (teb, T3, set3Mark);
    SetControl (teb, Ta, SpeichereAllePuffer);
    SetControl (teb, Tb, setAMark);
    SetControl (teb, Tc, Kopier);
    SetControl (teb, Td, TextSave);
    SetControl (teb, Te, Einrueck);
    SetControl (teb, Tf, TextParam);
    SetControl (teb, Tg, DeleteBlock);
    SetControl (teb, Th, BlockMLoe);
    SetControl (teb, Ti, SelectAll);
    SetControl (teb, Tj, LoadParam);
    SetControl (teb, Tk, setEMark);
    SetControl (teb, Tl, TextLoad);
    SetControl (teb, Tm, CopyToClipboard);
    SetControl (teb, Tn, InsertPuff);
    SetControl (teb, To, EditBlock);
    SetControl (teb, Tp, GlobParam);
    SetControl (teb, Tq, ExitEditor);
    SetControl (teb, Tr, BlockRead);
    SetControl (teb, Ts, Update);
    SetControl (teb, Tt, SelectWord);
    SetControl (teb, Tu, TextParam);
    SetControl (teb, Tv, Verschieb);
    SetControl (teb, Tw, BlockWrit);
    SetControl (teb, Tx, QuitCompile);
    SetControl (teb, Ty, CutToClipboard);
    SetControl (teb, Tz, SelectLine);
  END (* WITH *);
END CtrlKEbene;

PROCEDURE CtrlOEbene (t: einTastaturPointer; k: einKey);
BEGIN
  NewTastenebene (t^ [k].teb); t^ [k].TT := Tastenebene;
  InitTastenebene (einStatus {}, t^ [k].teb);
  WITH t^ [k] DO
    SetControl (teb, Ta, RollFLeft);
    SetControl (teb, Td, SteuerZeichenAnzeige);
    SetControl (teb, Tf, RollFRight);
    SetControl (teb, Tg, indent);
    SetControl (teb, Ti, TabLaen);
    SetControl (teb, Ty, LoescheText);
    SetControl (teb, Tz, LoescheAllePuffer);
  END (* WITH *);
END CtrlOEbene;

PROCEDURE CtrlQEbene (t: einTastaturPointer; k: einKey);
BEGIN
  NewTastenebene (t^ [k].teb); t^ [k].TT := Tastenebene;
  InitTastenebene (einStatus {}, t^ [k].teb);
  WITH t^ [k] DO
    SetControl (teb, T1, zur1Mark);
    SetControl (teb, T2, zur2Mark);
    SetControl (teb, T3, zur3Mark);
    SetControl (teb, Ta, StriTausch);
    SetControl (teb, Tb, zurAMark);
    SetControl (teb, Tc, zumDEnde);
    SetControl (teb, Td, ZeilEnde);
    SetControl (teb, Te, QueryError);
    SetControl (teb, Tf, SuchString);
    SetControl (teb, Tg, Grossklein);
    SetControl (teb, Ti, PickWort);
    SetControl (teb, Tj, LoadParam);
    SetControl (teb, Tk, zurEMark);
    SetControl (teb, Tn, zuNrZeile);
    SetControl (teb, To, PickTausch);
    SetControl (teb, Tp, LetztePos);
    SetControl (teb, Tr, zumDAnf);
    SetControl (teb, Ts, ZeilAnf);
    SetControl (teb, Tt, Wortsuche);
    SetControl (teb, Tv, LetzteSuchPos);
    SetControl (teb, Tw, SuchWort);
    SetControl (teb, Tq, WortTausch);
    SetControl (teb, Ty, DelEZeil);
  END (* WITH *);
END CtrlQEbene;

PROCEDURE InitControl (T: einTastaturPointer);
  (* Einfache Control-Befehle: *)
BEGIN
  (* obere Tastenreihe *)
  CtrlQEbene (T, Tq);
  SetControl (T, Tw,      Rollup);
  SetControl (T, Te,      cursup);
  SetControl (T, Tr,      Seitup);
  SetControl (T, Tt,      DelRWort);
  SetControl (T, Tz,      Rolldown);
  SetControl (T, Tu,      RestoreCurrentLine);
  SetControl (T, Ti,      tabulator);
  CtrlOEbene (T, To);
  CtrlZeich  (T, Tp);     (* Controlzeichen eingeben *)

  (* mittlere Tastenreihe *)
  SetControl (T, Ta,      Wortleft);
  SetControl (T, Ts,      cursleft);
  SetControl (T, Td,      cursright);
  SetControl (T, Tf,      Wortrigt);
  SetControl (T, Tg,      DelRChar);
  SetControl (T, Th,      DelLChar);
  SetControl (T, Tj,      NaechstenPuffer);
  CtrlKEbene (T, Tk);
  SetControl (T, Tl,      WeitSuch);

  (* untere Tastenreihe *)
  SetControl (T, Ty,      PopDeleteLine);
  SetControl (T, Tx,      CutToClipboard);
  SetControl (T, Tc,      CopyToClipboard);
  SetControl (T, Tv,      Paste);
  SetControl (T, Tb,      nothing);
  SetControl (T, Tn,      AsciiOrd);
END InitControl;

PROCEDURE InitAlternate (T: einTastaturPointer);
BEGIN
  SetControl (T, Ta,      QuitCompileRun); (* Speichern und RETURN 2 *)
  SetControl (T, Tc,      QuitCompile); (* = Compilieren aus d. Editor! *)
  SetControl (T, Td,      Compile); (* Im Speicher compilieren *)
  SetControl (T, Tm,      Make); (* RETURN 3 *)
  SetControl (T, Tr,      MakeExec); (* Quit Return 4 *)
  SetControl (T, Tt,      ZeitUndDatum);
  SetControl (T, Tx,      ExitEditor);
END InitAlternate;

PROCEDURE InitTastatur (VAR T: eineTastatur);
VAR     index:  CARDINAL;
BEGIN
  FOR index := 0 TO cTastaturEbenen DO
    NewTastenebene (T [index]);
    InitTastenebene (CAST (einStatus, index), T [index]);
    InitFunktionstasten (CAST (einStatus, index), T [index]);
  END (* FOR *);
  InitControl (T [ORD (CAST (BYTE, einStatus {Control}))]);
  InitAlternate (T [ORD (CAST (BYTE, einStatus {Alternate}))]);
END InitTastatur;

VAR     OldModus:       Moden;
        firstCommand, oldRight, rightButton: BOOLEAN;
        OldClipLeer, OldDoClipboard, OldNextPuff: BOOLEAN;

PROCEDURE LiesTaste (VAR t: einTasteneintrag);
TYPE    CharSet =  SET OF CHAR;
VAR     k:      einKey;
        s:      einStatus;
        n:      CARDINAL;
        tt:     einTasteneintrag;
        localEvents: EventSet;
        
BEGIN
  (* HÑkchen updaten... *)
  WITH EditPuffer^ DO
    IF OldModus <> Modus THEN
      OldModus := Modus;
      CheckItem (Menu, Backupan, MakeBAK IN Modus);
      CheckItem (Menu, Konfigea, KonfigSpeichern IN Modus);
      CheckItem (Menu, Grosskle, GrossKleinSuche IN Modus);
      CheckItem (Menu, Wortsuch, WortSuche IN Modus);
      CheckItem (Menu, Autoinde, AutoIndent IN Modus);
      CheckItem (Menu, Overwrit, OverWrite IN Modus);
    END (* IF *);
    IF (OldDoClipboard # DoClipboard)
    OR (OldClipLeer # PufferLeer (ClipBoard)) THEN
      OldClipLeer:= PufferLeer (ClipBoard);
      EnableItem (Menu, Blkkopie, DoClipboard OR ~OldClipLeer)
    END;
    IF OldDoClipboard # DoClipboard THEN
      OldDoClipboard:= DoClipboard;
      CheckItem (Menu, Gemscrap, DoClipboard)
    END;
    IF OldNextPuff # (EditPuffer^.NaechsterPuffer # EditPuffer) THEN
      OldNextPuff:= (EditPuffer^.NaechsterPuffer # EditPuffer);
      EnableItem (Menu, Next, OldNextPuff)
    END;
  END (* WITH *);
  
  UpdateWindow (FALSE);
  
  t.TT := keineTaste;
  REPEAT
  (* Schleife zur Eventabfrage. Die Schleife wird nur verlassen, wenn
     ein fÅr den Editor relevanter Event aufgetreten ist. Das ist
     entweder ein Tastendruck (keyboard), eine Maustaste (mouseButton)
     oder eine Auswahl aus der Menuleiste (message): *)
    
    IF occuredEvents = EventSet {} THEN
      MultiEvent (EventSet {keyboard, mouseButton, message, timer},
                  noClicks, butMask, butState,
                  moveDirec1, rect1Size,
                  moveDirec2, rect2Size,
                  msg, time, mouseLoc, buttons,
                  keyState, key, doneClicks, occuredEvents);
    END;

    IF NOT VarEqual (mouseLoc, oldLoc) THEN
      MausEin; oldLoc := mouseLoc;
    END;
    
    (* AES verweilt in diesem Aufruf, bis einer der oben angegeben
       Events eingetreten ist... *)
    IF message IN occuredEvents THEN
      WITH msg DO
        CASE msgType OF
          menuSelected:         t.TT := Befehl; t.bef := MenuTabelle [selItem]|
          windRedraw:           IF NOT firstCommand THEN
                                  t.TT := Befehl; t.bef := home; (* Redraw *)
                                END
          ELSE
        END (* CASE *);
        NormalTitle (Menu, selTitle, TRUE);
      END (* WITH *);
      EXCL (occuredEvents, message);
    ELSIF keyboard IN occuredEvents THEN

    (* Das folgende ist eine Umschreibung der ursprÅnglichen Tastatur-
       abfrage des G2E. Da MultiEvents keinen Tastenstatus liefert, kînnen
       die Tastaturebenen nicht direkt angesprochen werden.
       
       ZunÑchst stellen wir fest, zu welcher Tastenart der Scancode der
       Taste gehîrt: *)
      t := Tastatur [0]^ [ScanTab [ORD (key.scan)]];
      CASE t.TT OF
      
             (* Wenn es ein normales Zeichen ist, Åbernehmen wir einfach das
                von MultiEvents gelieferte Zeichen: *)
        Zeichen: IF key.ascii >= ' ' THEN
                   t.zch := key.ascii;
                   (* Wir Åbernehmen die ASCII-Zeichen aus der TOS-Tabelle *)
                 ELSIF key.ascii # nul THEN
                   (* War es ein Code kleiner als ' ', so nehmen wir an,
                      es ist die Control-Ebene gemeint: *)
                   t := Tastatur [ORD (CAST (BYTE, einStatus {Control}))]^
                        [ScanTab [ORD (key.scan)]];
                 ELSE
                   (* Es ist eine Alternate-Kombination: *)
                   t := Tastatur [ORD (CAST (BYTE, einStatus {Alternate}))]^
                        [ScanTab [ORD (key.scan)]];
                 END;
        |
        Befehl:
          (* In diesem Fall handelt es sich um eine Funktionstaste. Wir mÅssen
             nun den Tastaturstatus kÅnstlich bilden: *)
           s := StatusVonKeySet (keyState);
           t := Tastatur [ORD (CAST (BYTE, s))]^ [ScanTab [ORD (key.scan)]];
        |
        ELSE;
      END (* CASE *);
      EXCL (occuredEvents, keyboard);
    ELSE
      GetMouseState (ScreenHandle, mouseLoc, buttons);
      EXCL (occuredEvents, mouseButton);
      IF msBut1 IN buttons THEN
        t.TT := Befehl;
        IF (rightShiftKey IN keyState) OR (leftShiftKey IN keyState) THEN
          t.bef := RightMous;
        ELSE
          t.bef := LeftMous;
        END;
      END (* IF Mausknopf *);
      IF msBut2 IN buttons THEN
        t.TT := Befehl;
        t.bef := RightMous;
      END (* IF Mausknopf *);
    END (* IF keyboard *);
    EXCL (occuredEvents, timer);
  UNTIL t.TT # keineTaste;
  UpdateWindow (TRUE); (* muû spÑtest. hier stehen wg. LiesTaste-Aufruf unten!*)
  firstCommand:= FALSE;

  CASE t.TT OF
    Befehl:       IF t.bef = AsciiOrd THEN
                    n := 0;
                    REPEAT
                      LiesTaste (t);
                      IF (t.TT = Zeichen) & (t.zch IN CharSet {'0'..'9'}) THEN
                        n := n * 10 + ORD (t.zch) - ORD ('0');
                      END (* IF *);
                    UNTIL ~((t.TT = Zeichen) & (t.zch IN CharSet {'0'..'9'}));
                    n := n MOD 256;
                    t.TT := Zeichen; t.zch := CHR (n);
                  ELSIF t.bef = GMECopyrightBox THEN
                    ShowGMEInfo;
                  END (* IF *);
    |
    Tastenebene:  WHILE t.TT = Tastenebene DO
                    MultiEvent (EventSet {keyboard, mouseButton, message},
                                noClicks, butMask, MButtonSet{},
                                moveDirec1, rect1Size,
                                moveDirec2, rect2Size,
                                msg, time, mouseLoc, buttons,
                                keyState, key, doneClicks, localEvents);

                    IF keyboard IN localEvents THEN
                      tt := Tastatur [0]^ [ScanTab [ORD (key.scan)]];
                      IF (tt.TT = Zeichen) & (key.ascii <= 'z') THEN
                        t := t.teb^ [ScanTab [ORD (key.scan)]];
                      ELSE t.TT := keineTaste;
                      END (* IF *);
                    (*ELSE t.TT := keineTaste;*)
                    END (* IF keyboard *);

                   END (* WHILE *);
    |
    ELSE;
  END (* CASE *);
END LiesTaste;

PROCEDURE LiesTastMaus (VAR t: einTasteneintrag; keys: einStatus);
END LiesTastMaus;

PROCEDURE LiesZeichen (VAR ch: CHAR);
VAR     t:      einTasteneintrag;
BEGIN
  LiesTaste (t);
  IF t.TT = Zeichen THEN ch := t.zch ELSE ch := nul; END;
END LiesZeichen;

PROCEDURE LiesBefehl (VAR b: einBefehl);
VAR     t:      einTasteneintrag;
BEGIN
  LiesTaste (t);
  IF t.TT = Befehl THEN b := t.bef; ELSE b := nothing; END;
END LiesBefehl;


VAR     RessPfad:       eineInfo;
        gefunden:       BOOLEAN;
        DateiName:      ARRAY [0..13] OF CHAR;
        termHdl:        TermCarrier;

BEGIN
(* GEM-MenÅleiste: *)
  
  DisableBreak;
  IF NOT KbdEventsInstalled () THEN
    CatchProcessTerm (termHdl, DeInstallKbdEvents, MemArea {NIL, 0});
    InstallKbdEvents
  END;
  
  HomePath:= ShellPath;
  DateiName := 'GMEMENUE.RSC';
  SearchFile (DateiName, StdPaths, fromStart, gefunden, RessPfad);
  
  LoadResource (RessPfad); (* Muû auf meinem Pfad sein! *)
  IF GemError() THEN
    Nachricht (' Die Datei GMEMENUE.RSC| wurde nicht gefunden!');
    CursorAus; MausEin; (* Schaltet wieder auf GEM-Oberflaeche zurueck *)
    (*TastReset; *)
    ClearAES;
    TermProcess (0);
  END;
  Menu := ResourceAddr (treeRsrc, Gmemenue);
  MenuBar (Menu, TRUE);
  noClicks := 1;
  butMask := MButtonSet {};
  butState := MButtonSet {};
  moveDirec1 := lookForEntry; moveDirec2 := lookForEntry;
  WITH rect1Size DO x := 0; y := 0; w := 0; h := 0; END (* WITH *);
  WITH rect2Size DO x := 0; y := 0; w := 0; h := 0; END (* WITH *);
  time := 0; (* MUSS NULL SEIN, sonst geht Autorepeat nicht!? *)

  InitTastatur (Tastatur);
  InitMenuTabelle;
  ConfigInit := FALSE;
  
  oldRight:= FALSE;
  OldClipLeer:= FALSE;
  OldDoClipboard:= ~DoClipboard;
  OldNextPuff:= FALSE;
  OldModus := Moden {};
  firstCommand:= TRUE;
END GMEConfig.
