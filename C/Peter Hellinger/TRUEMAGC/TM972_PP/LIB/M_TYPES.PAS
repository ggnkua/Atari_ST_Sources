UNIT M_Types;

INTERFACE

USES Basics;

CONST   MagicName = 'magic.prg'#0;

(*--- Struktur des Cookies -----------------------------------------*)

TYPE  tDispatcher =     PROCEDURE (d0, d1, d2: LONGINT; func: LONGINT;
                                   a0, a1: POINTER; p: POINTER);

TYPE  tColorTable =     ^ColorTable;
      ColorTable =      ARRAY [0..5, 0..1, 1..6] OF INTEGER;

TYPE  tFKeys =          (fkHelp,        (* Helpbutton auslîsen         *)
                         fkUndo,        (* UndoButton auslîsen         *)
                         fkEscape,      (* EscapeButton auslîsen       *)
                         fkHistory,     (* History durchlaufen         *)
                         fkSearch,      (* History durchsuchen         *)
                         fkCutClip,     (* Zeile ausschneiden          *)
                         fkCopyClip,    (* Zeile auf Clip kopieren     *)
                         fkPasteClip,   (* Clipboard lesen             *)
                         fkSelectAll,   (* Alles als Block selektieren *)
                         fkSelectStart, (* Alles als Block selektieren *)
                         fkCycleWin,    (* Fenster cyclen              *)
                         fkCloseWin,    (* Fenster schliessen          *)
                         fkFullWin,     (* Fenster auf volle Grîûe     *)
                         fkLineup,      (* Zeile nach oben rollen      *)
                         fkPageup,      (* Seite nach oben rollen      *)
                         fkTopdoc,      (* Zum Anfang des Dokuments    *)
                         fkLinedown,    (* Zeile nach unten rollen     *)
                         fkPagedown,    (* Seite nach unten rollen     *)
                         fkBottomdoc,   (* Zum Ende des Dokuments      *)
                         fkLineleft,    (* Spalte nach links rollen    *)
                         fkPageleft,    (* Seite nach links rollen     *)
                         fkLeftdoc,     (* Zur ersten Spalte.          *)
                         fkLineright,   (* Spalte nach rechts rollen   *)
                         fkPageright,   (* Seite nach rechts rollen    *)
                         fkRightdoc     (* Zur letzten Spalte          *)
                        );

TYPE  tFKeytable =      ^FKeytable;
      FKeytable =       ARRAY [tFKeys] OF INTEGER;

TYPE  tValues =         (vWinsize,    (* Sizearea-Breite           *)
                         vPopdelay,   (* Delay bei Popups          *)
                         vDropdelay,  (* Delay bei Drop-Circlebuttons *)
                         vMintid,     (* ID des Kernels unter MiNT *)
                         vMagixTask,
                         vNumTasks,
                         vRes7,
                         vRes8,
                         vRes9,
                         vRes10
                        );
      tValuetable =     ^Valuetable;
      Valuetable =      ARRAY [tValues] OF INTEGER;

TYPE  PtrConfig =  ^TheConfig;
      TheConfig =  RECORD
                    version:    INTEGER;     (* Versionsnummer                *)
                    deadkeys:   BITSET;      (* Daten Åber die DeadKeys       *)
                    flags:      LONGBITSET;  (* Flags siehe unten             *)
                    dispatcher: tDispatcher; (* Einsprung in MAGIC.PRG        *)
                    path:       PtrCSTRING;  (* Pfad fÅr Magic.PRG            *)
                    colortable: tColortable; (* Zeiger auf Button-Farbtabelle *)
                    fkeytable:  tFkeytable;  (* Zeiger auf die Standardtasten *)
                    valuetable: tValuetable; (* Zeiger auf Werte-Tabelle      *)
                    actapp:     POINTER;     (* Zeiger auf den App-Block      *)
                    help:       PCHAR;       (* Default-Helpprogramm          *)
                    tlpath:     PCHAR;       (* Pfad fÅr MagicTools           *)
                    res1:       POINTER;
                    res2:       POINTER;
                    res3:       POINTER;
                    res4:       POINTER;
                    res5:       POINTER;
                   END;

(* Flags bei TheCookie.flags: *)

CONST   cfConfig =      lBit0;   (* Config-Dial zulassen         *)
        cfSolid =       lBit1;   (* Solide Verschieben           *)
        cfClip =        lBit2;   (* GEM-Clipboard benutzen       *)
        cfDeadkey =     lBit3;   (* Deadkeys im Edit benutzen    *)
        cfCenter =      lBit4;   (* Dialog zentrieren            *)
        cfMouse =       lBit5;   (* Dialog an Mouseposition      *)
        cfPos =         lBit6;   (* Dialog an letzter Position   *)
        cfGrowbox =     lBit7;   (* Grow-/Shrinkboxen            *)
        cf3DButtons =   lBit8;   (* Buttons im 3D-Look and Feel  *)
        cfWinDials =    lBit9;   (* Dialog im Fenster gewÅnscht  *)
        cfWinAlerts =   lBit10;  (* Alle Alerts in Fenstern      *)
        cfButtonLeft =  lBit11;  (* Alertbuttons LinksbÅndig     *)
        cfButtonRight = lBit12;  (* Alertbuttons RechtsbÅndig    *)
        cfAltIcon =     lBit13;  (* Alternative Icons verwenden  *)
        cfAllSize =     lBit14;  (* Fenster an allen Ecken und Kanten sizen *)
        cfAllMove =     lBit15;  (* Fenster an allen Ecken und Kanten moven *)
        cfPopClick =    lBit16;  (* Popups durch klicken wÑhlen/verlassen *)
        cfIconpos =     lBit17;  (* iconified Fenster werden beim Vergrîssern 
                                  * auf die Iconposition gesetzt, sonst auf die
                                  * letzte Fensterposition *)
        cfSubmode =     lBit18;  (* Modus der SubmenÅs *)
        cfXFSL =        lBit19;  (* XFSL-Fontselektor *)
        cfMFSL =        lBit20;  (* MFSL-Fontselektor *)
        cfLoadfonts =   lBit21;  (* Fonts laden *)
        cfFreeze =      lBit22;  (* Unter MagiX freezen? *)
        cfRes23 =       lBit23;  (* Reserviert *)
        cfRes24 =       lBit24;  (* Reserviert *)
        cfRes25 =       lBit25;  (* Reserviert *)
        cfRes26 =       lBit26;  (* Reserviert *)
        cfRes27 =       lBit27;  (* Reserviert *)
        cfRes28 =       lBit28;  (* Reserviert *)
        cfRes29 =       lBit29;  (* Reserviert *)
        cfRes30 =       lBit30;  (* Reserviert *)
        cfRes31 =       lBit31;  (* Reserviert *)

(*------------------------------------------------------------------*)


TYPE    PtrWS =          ^WORKSTATION;
        WORKSTATION =    RECORD
                          Handle:             INTEGER; (* Handle der Workstation *)
                          Flags:              LONGBITSET;
                          MaxWidth:           INTEGER; (* workout[ 0]*)
                          MaxHeight:          INTEGER; (* workout[ 1]*)
                          Devicecoord:        INTEGER; (* workout[ 2]*)
                          PixelWidth:         INTEGER; (* workout[ 3]*)
                          PixelHight:         INTEGER; (* workout[ 4]*)
                          FontHeights:        INTEGER; (* workout[ 5]*)
                          LineTypes:          INTEGER; (* workout[ 6]*)
                          LineWidth:          INTEGER; (* workout[ 7]*)
                          MarkerTypes:        INTEGER; (* workout[ 8]*)
                          MarkerSize:         INTEGER; (* workout[ 9]*)
                          SystemFonts:        INTEGER; (* workout[10]*)
                          PatternTypes:       INTEGER; (* workout[11]*)
                          HatchTypes:         INTEGER; (* workout[12]*)
                          DefColors:          INTEGER; (* workout[13]*)
                          GDPFunctions:       INTEGER; (* workout[14]*)
                          GDP01:              INTEGER; (* workout[15]*)
                          GDP02:              INTEGER; (* workout[16]*)
                          GDP03:              INTEGER; (* workout[17]*)
                          GDP04:              INTEGER; (* workout[18]*)
                          GDP05:              INTEGER; (* workout[19]*)
                          GDP06:              INTEGER; (* workout[20]*)
                          GDP07:              INTEGER; (* workout[21]*)
                          GDP08:              INTEGER; (* workout[22]*)
                          GDP09:              INTEGER; (* workout[23]*)
                          GDP10:              INTEGER; (* workout[24]*)
                          GDPAttrib01:        INTEGER; (* workout[25]*)
                          GDPAttrib02:        INTEGER; (* workout[26]*)
                          GDPAttrib03:        INTEGER; (* workout[27]*)
                          GDPAttrib04:        INTEGER; (* workout[28]*)
                          GDPAttrib05:        INTEGER; (* workout[29]*)
                          GDPAttrib06:        INTEGER; (* workout[30]*)
                          GDPAttrib07:        INTEGER; (* workout[31]*)
                          GDPAttrib08:        INTEGER; (* workout[32]*)
                          GDPAttrib09:        INTEGER; (* workout[33]*)
                          GDPAttrib10:        INTEGER; (* workout[34]*)
                          ColorPossible:      INTEGER; (* workout[35]*)
                          TextRotPossible:    INTEGER; (* workout[36]*)
                          AreaFillPossible:   INTEGER; (* workout[37]*)
                          CellArrayPossible:  INTEGER; (* workout[38]*)
                          MaxColors:          INTEGER; (* workout[39]*)
                          CursorControl:      INTEGER; (* workout[40]*)
                          ValuatorControl:    INTEGER; (* workout[41]*)
                          ChoiceControl:      INTEGER; (* workout[42]*)
                          AlphaControl:       INTEGER; (* workout[43]*)
                          InOutType:          INTEGER; (* workout[44]*)
                          MinCharWidth:       INTEGER; (* workout[45]*)
                          MinCharHeight:      INTEGER; (* workout[46]*)
                          MaxCharWidth:       INTEGER; (* workout[47]*)
                          MaxCharHeight:      INTEGER; (* workout[48]*)
                          MinLineWidth:       INTEGER; (* workout[49]*)
                          MaxLineWidth:       INTEGER; (* workout[51]*)
                          MinMarkerWidth:     INTEGER; (* workout[53]*)
                          MinMarkerHeight:    INTEGER; (* workout[54]*)
                          MaxMarkerWidth:     INTEGER; (* workout[55]*)
                          MaxMarkerHeight:    INTEGER; (* workout[56]*)

                          (* Extended Inquire *)
                          ScreenType:         INTEGER; (* workout[ 0]*)
                          BackgroundColors:   INTEGER; (* workout[ 1]*)
                          Texteffects:        BITSET;  (* workout[ 2]*)
                          Upsizing:           INTEGER; (* workout[ 3]*)
                          Bitplanes:          INTEGER; (* workout[ 4]*)
                          LookupTable:        INTEGER; (* workout[ 5]*)
                          RasterOps:          INTEGER; (* workout[ 6]*)
                          ContourFill:        INTEGER; (* workout[ 7]*)
                          TextRotation:       INTEGER; (* workout[ 8]*)
                          WriteModes:         INTEGER; (* workout[ 9]*)
                          InputModes:         INTEGER; (* workout[10]*)
                          TextJustification:  INTEGER; (* workout[11]*)
                          PencilChange:       INTEGER; (* workout[12]*)
                          ColorChange:        INTEGER; (* workout[13]*)
                          MaxCoordPairs:      INTEGER; (* workout[14]*)
                          MaxIntin:           INTEGER; (* workout[15]*)
                          MaxMouseButtons:    INTEGER; (* workout[16]*)
                          FatLineTypes:       INTEGER; (* workout[17]*)
                          FatLineModes:       INTEGER; (* workout[18]*)
                          Clipping:           INTEGER; (* workout[19]*)
                          ClipLeftX:          INTEGER; (* workout[45]*)
                          ClipLeftY:          INTEGER; (* workout[46]*)
                          ClipRightX:         INTEGER; (* workout[47]*)
                          ClipRightY:         INTEGER; (* workout[48]*)
                            
                          Reserved1:          POINTER; (* Nicht benutzen!!! *)
                          Reserved2:          POINTER; (* Nicht benutzen!!! *)
                          Reserved3:          POINTER; (* Nicht benutzen!!! *)

                          DeviceNum:          INTEGER;
                          Name:               CSTRING;
                         END;


(*----------------------------------------------------------------------*
 * Bemerkungen zu den Tastencodes                                       *
 *                                                                      *
 * Sh =          Shift                                                  *
 * Ctrl =        Control                                                *
 * ShCtrl =      Shift + Control                                        *
 * Alt =         Alternate                                              *
 * ShAlt =       Shift + Alternate                                      *
 * CtrlAlt =     Control + Alternate                                    *
 * ShCtrlAlt =   Shift + Control + Alternate                            *
 *                                                                      *
 * Groûbuchstaben Åber CAPSLOCK werden mit Shift-Status gemeldet!       *
 *                                                                      *
 * Einige Kombinationen sind nicht Åber die Tastatur zugÑnglich (zB:    *
 * Maus-Emulation des OS, Ctrl-Alt-Del, Alt-Help)                       *
 *                                                                      *
 * Die Scancodes fÅr Shift-F1 bis Shift-F10 sowie fÅr Alt-1 bis Alt-'   *
 * werden bei den jeweiligen Basiscodes mitgemeldet.  Ein Auswerten     *
 * dieser Codes hat also nicht viel Sinn...                             *
 *----------------------------------------------------------------------*)

TYPE tKey = (

{Escape    }  Esc,      ShEsc,      CtrlEsc,      ShCtrlEsc,      AltEsc,      ShAltEsc,      CtrlAltEsc,      ShCtrlAltEsc,
{1 !       }  Char1,    Sh1,        Ctrl1,        ShCtrl1,        Alt1,        ShAlt1,        CtrlAlt1,        ShCtrlAlt1,
{2 "       }  Char2,    Sh2,        Ctrl2,        ShCtrl2,        Alt2,        ShAlt2,        CtrlAlt2,        ShCtrlAlt2,
{3 ›       }  Char3,    Sh3,        Ctrl3,        ShCtrl3,        Alt3,        ShAlt3,        CtrlAlt3,        ShCtrlAlt3,
{4 $       }  Char4,    Sh4,        Ctrl4,        ShCtrl4,        Alt4,        ShAlt4,        CtrlAlt4,        ShCtrlAlt4,
{5 %       }  Char5,    Sh5,        Ctrl5,        ShCtrl5,        Alt5,        ShAlt5,        CtrlAlt5,        ShCtrlAlt5,
{6 &       }  Char6,    Sh6,        Ctrl6,        ShCtrl6,        Alt6,        ShAlt6,        CtrlAlt6,        ShCtrlAlt6,
{7 /       }  Char7,    Sh7,        Ctrl7,        ShCtrl7,        Alt7,        ShAlt7,        CtrlAlt7,        ShCtrlAlt7,
{8 (       }  Char8,    Sh8,        Ctrl8,        ShCtrl8,        Alt8,        ShAlt8,        CtrlAlt8,        ShCtrlAlt8,
{9 )       }  Char9,    Sh9,        Ctrl9,        ShCtrl9,        Alt9,        ShAlt9,        CtrlAlt9,        ShCtrlAlt9,
{0 =       }  Char0,    Sh0,        Ctrl0,        ShCtrl0,        Alt0,        ShAlt0,        CtrlAlt0,        ShCtrlAlt0,
{û ?       }  CharSS,   ShSS,       CtrlSS,       ShCtrlSS,       AltSS,       ShAltSS,       CtrlAltSS,       ShCtrlAltSS,
{' `       }  Quote,    ShQuote,    CtrlQuote,    ShCtrlQuote,    AltQuote,    ShAltQuote,    CtrlAltQuote,    ShCtrlAltQuote,
{Backspace }  Bs,       ShBs,       CtrlBs,       ShCtrlBs,       AltBs,       ShAltBs,       CtrlAltBs,       ShCtrlAltBs,
{Tab       }  Tab,      ShTab,      CtrlTab,      ShCtrlTab,      AltTab,      ShAltTab,      CtrlAltTab,      ShCtrlAltTab,
{q Q       }  CharQ,    ShQ,        CtrlQ,        ShCtrlQ,        AltQ,        ShAltQ,        CtrlAltQ,        ShCtrlAltQ,
{w W       }  CharW,    ShW,        CtrlW,        ShCtrlW,        AltW,        ShAltW,        CtrlAltW,        ShCtrlAltW,
{e E       }  CharE,    ShE,        CtrlE,        ShCtrlE,        AltE,        ShAltE,        CtrlAltE,        ShCtrlAltE,
{r R       }  CharR,    Sh_R,       CtrlR,        ShCtrlR,        AltR,        ShAltR,        CtrlAltR,        ShCtrlAltR,
{t T       }  CharT,    ShT,        CtrlT,        ShCtrlT,        AltT,        ShAltT,        CtrlAltT,        ShCtrlAltT,
{z Z       }  CharZ,    ShZ,        CtrlZ,        ShCtrlZ,        AltZ,        ShAltZ,        CtrlAltZ,        ShCtrlAltZ,
{u U       }  CharU,    ShU,        CtrlU,        ShCtrlU,        AltU,        ShAltU,        CtrlAltU,        ShCtrlAltU,
{i I       }  CharI,    ShI,        CtrlI,        ShCtrlI,        AltI,        ShAltI,        CtrlAltI,        ShCtrlAltI,
{o O       }  CharO,    ShO,        CtrlO,        ShCtrlO,        AltO,        ShAltO,        CtrlAltO,        ShCtrlAltO,
{p P       }  CharP,    ShP,        CtrlP,        ShCtrlP,        AltP,        ShAltP,        CtrlAltP,        ShCtrlAltP,
{Å ö   @ \ }  CharUE,   ShUE,       CtrlUE,       ShCtrlUE,       AltUE,       ShAltUE,       CtrlAltUE,       ShCtrlAltUE,
{+ *       }  Plus,     ShPlus,     CtrlPlus,     ShCtrlPlus,     AltPlus,     ShAltPlus,     CtrlAltPlus,     ShCtrlAltPlus,
{Return    }  Return,   ShReturn,   CtrlReturn,   ShCtrlReturn,   AltReturn,   ShAltReturn,   CtrlAltReturn,   ShCtrlAltReturn,
{Control   }  Scan29,   ShScan29,   CtrlScan29,   ShCtrlScan29,   AltScan29,   ShAltScan29,   CtrlAltScan29,   ShCtrlAltScan29,
{a A       }  CharA,    ShA,        CtrlA,        ShCtrlA,        AltA,        ShAltA,        CtrlAltA,        ShCtrlAltA,
{s S       }  CharS,    ShS,        CtrlS,        ShCtrlS,        AltS,        ShAltS,        CtrlAltS,        ShCtrlAltS,
{d D       }  CharD,    ShD,        CtrlD,        ShCtrlD,        AltD,        ShAltD,        CtrlAltD,        ShCtrlAltD,
{f F       }  CharF,    ShF,        CtrlF,        ShCtrlF,        AltF,        ShAltF,        CtrlAltF,        ShCtrlAltF,
{g G       }  CharG,    ShG,        CtrlG,        ShCtrlG,        AltG,        ShAltG,        CtrlAltG,        ShCtrlAltG,
{h H       }  CharH,    ShH,        CtrlH,        ShCtrlH,        AltH,        ShAltH,        CtrlAltH,        ShCtrlAltH,
{j J       }  CharJ,    ShJ,        CtrlJ,        ShCtrlJ,        AltJ,        ShAltJ,        CtrlAltJ,        ShCtrlAltJ,
{k K       }  CharK,    ShK,        CtrlK,        ShCtrlK,        AltK,        ShAltK,        CtrlAltK,        ShCtrlAltK,
{l L       }  CharL,    Sh_L,       CtrlL,        ShCtrlL,        AltL,        ShAltL,        CtrlAltL,        ShCtrlAltL,
{î ô   [ { }  CharOE,   ShOE,       CtrlOE,       ShCtrlOE,       AltOE,       ShAltOE,       CtrlAltOE,       ShCtrlAltOE,
{Ñ é   ] . }  CharAE,   ShAE,       CtrlAE,       ShCtrlAE,       AltAE,       ShAltAE,       CtrlAltAE,       ShCtrlAltAE,
{# ^       }  Number,   ShNumber,   CtrlNumber,   ShCtrlNumber,   AltNumber,   ShAltNumber,   CtrlAltNumber,   ShCtrlAltNumber,
{L-Shift   }  Scan42,   ShScan42,   CtrlScan42,   ShCtrlScan42,   AltScan42,   ShAltScan42,   CtrlAltScan42,   ShCtrlAltScan42,
{~ |       }  Tilde,    ShTilde,    CtrlTilde,    ShCtrlTilde,    AltTilde,    ShAltTilde,    CtrlAltTilde,    ShCtrlAltTilde,
{y Y       }  CharY,    ShY,        CtrlY,        ShCtrlY,        AltY,        ShAltY,        CtrlAltY,        ShCtrlAltY,
{x X       }  CharX,    ShX,        CtrlX,        ShCtrlX,        AltX,        ShAltX,        CtrlAltX,        ShCtrlAltX,
{c C       }  CharC,    ShC,        CtrlC,        ShCtrlC,        AltC,        ShAltC,        CtrlAltC,        ShCtrlAltC,
{v V       }  CharV,    ShV,        CtrlV,        ShCtrlV,        AltV,        ShAltV,        CtrlAltV,        ShCtrlAltV,
{b B       }  CharB,    ShB,        CtrlB,        ShCtrlB,        AltB,        ShAltB,        CtrlAltB,        ShCtrlAltB,
{n N       }  CharN,    ShN,        CtrlN,        ShCtrlN,        AltN,        ShAltN,        CtrlAltN,        ShCtrlAltN,
{m M       }  CharM,    ShM,        CtrlM,        ShCtrlM,        AltM,        ShAltM,        CtrlAltM,        ShCtrlAltM,
{, ;       }  Colon,    ShColon,    CtrlColon,    ShCtrlColon,    AltColon,    ShAltColon,    CtrlAltColon,    ShCtrlAltColon,
{. :       }  Point,    ShPoint,    CtrlPoint,    ShCtrlPoint,    AltPoint,    ShAltPoint,    CtrlAltPoint,    ShCtrlAltPoint,
{- _       }  Minus,    ShMinus,    CtrlMinus,    ShCtrlMinus,    AltMinus,    ShAltMinus,    CtrlAltMinus,    ShCtrlAltMinus,
{R-Shift   }  Scan54,   ShScan54,   CtrlScan54,   ShCtrlScan54,   AltScan54,   ShAltScan54,   CtrlAltScan54,   ShCtrlAltScan54,
{ nicht da }  Scan55,   ShScan55,   CtrlScan55,   ShCtrlScan55,   AltScan55,   ShAltScan55,   CtrlAltScan55,   ShCtrlAltScan55,
{Alternate }  Scan56,   ShScan56,   CtrlScan56,   ShCtrlScan56,   AltScan56,   ShAltScan56,   CtrlAltScan56,   ShCtrlAltScan56,
{          }  Space,    ShSpace,    CtrlSpace,    ShCtrlSpace,    AltSpace,    ShAltSpace,    CtrlAltSpace,    ShCtrlAltSpace,
{Capslock  }  Scan58,   ShScan58,   CtrlScan58,   ShCtrlScan58,   AltScan58,   ShAltScan58,   CtrlAltScan58,   ShCtrlAltScan58,
{F1        }  F1,       ShF1,       CtrlF1,       ShCtrlF1,       AltF1,       ShAltF1,       CtrlAltF1,       ShCtrlAltF1,
{F2        }  F2,       ShF2,       CtrlF2,       ShCtrlF2,       AltF2,       ShAltF2,       CtrlAltF2,       ShCtrlAltF2,
{F3        }  F3,       ShF3,       CtrlF3,       ShCtrlF3,       AltF3,       ShAltF3,       CtrlAltF3,       ShCtrlAltF3,
{F4        }  F4,       ShF4,       CtrlF4,       ShCtrlF4,       AltF4,       ShAltF4,       CtrlAltF4,       ShCtrlAltF4,
{F5        }  F5,       ShF5,       CtrlF5,       ShCtrlF5,       AltF5,       ShAltF5,       CtrlAltF5,       ShCtrlAltF5,
{F6        }  F6,       ShF6,       CtrlF6,       ShCtrlF6,       AltF6,       ShAltF6,       CtrlAltF6,       ShCtrlAltF6,
{F7        }  F7,       ShF7,       CtrlF7,       ShCtrlF7,       AltF7,       ShAltF7,       CtrlAltF7,       ShCtrlAltF7,
{F8        }  F8,       ShF8,       CtrlF8,       ShCtrlF8,       AltF8,       ShAltF8,       CtrlAltF8,       ShCtrlAltF8,
{F9        }  F9,       ShF9,       CtrlF9,       ShCtrlF9,       AltF9,       ShAltF9,       CtrlAltF9,       ShCtrlAltF9,
{F10       }  F10,      ShF10,      CtrlF10,      ShCtrlF10,      AltF10,      ShAltF10,      CtrlAltF10,      ShCtrlAltF10,
{ nicht da }  Scan69,   ShScan69,   CtrlScan69,   ShCtrlScan69,   AltScan69,   ShAltScan69,   CtrlAltScan69,   ShCtrlAltScan69,
{ nicht da }  Scan70,   ShScan70,   CtrlScan70,   ShCtrlScan70,   AltScan70,   ShAltScan70,   CtrlAltScan70,   ShCtrlAltScan70,
{Clr/Home  }  Clr,      ShClr,      CtrlClr,      ShCtrlClr,      AltClr,      ShAltClr,      CtrlAltClr,      ShCtrlAltClr,
{Cursor Up }  Up,       ShUp,       CtrlUp,       ShCtrlUp,       AltUp,       ShAltUp,       CtrlAltUp,       ShCtrlAltUp,
{ nicht da }  Scan73,   ShScan73,   CtrlScan73,   ShCtrlScan73,   AltScan73,   ShAltScan73,   CtrlAltScan73,   ShCtrlAltScan73,
{NumBlock -}  NumMinus, ShNumMinus, CtrlNumMinus, ShCtrlNumMinus, AltNumMinus, ShAltNumMinus, CtrlAltNumMinus, ShCtrlAltNumMinus,
{Curs Left }  Left,     ShLeft,     CtrlLeft,     ShCtrlLeft,     AltLeft,     ShAltLeft,     CtrlAltLeft,     ShCtrlAltLeft,
{ nicht da }  Scan76,   ShScan76,   CtrlScan76,   ShCtrlScan76,   AltScan76,   ShAltScan76,   CtrlAltScan76,   ShCtrlAltScan76,
{Curs Right}  Right,    ShRight,    CtrlRight,    ShCtrlRight,    AltRight,    ShAltRight,    CtrlAltRight,    ShCtrlAltRight,
{NumBlock +}  NumPlus,  ShNumPlus,  CtrlNumPlus,  ShCtrlNumPlus,  AltNumPlus,  ShAltNumPlus,  CtrlAltNumPlus,  ShCtrlAltNumPlus,
{ nicht da }  Scan79,   ShScan79,   CtrlScan79,   ShCtrlScan79,   AltScan79,   ShAltScan79,   CtrlAltScan79,   ShCtrlAltScan79,
{Curs  Down}  Down,     ShDown,     CtrlDown,     ShCtrlDown,     AltDown,     ShAltDown,     CtrlAltDown,     ShCtrlAltDown,
{ nicht da }  Scan81,   ShScan81,   CtrlScan81,   ShCtrlScan81,   AltScan81,   ShAltScan81,   CtrlAltScan81,   ShCtrlAltScan81,
{Insert    }  Ins,      ShIns,      CtrlIns,      ShCtrlIns,      AltIns,      ShAltIns,      CtrlAltIns,      ShCtrlAltIns,
{Delete    }  Del,      ShDel,      CtrlDel,      ShCtrlDel,      AltDel,      ShAltDel,      CtrlAltDel,      ShCtrlAltDel,
{Shift-F1  }  Scan84,   ShScan84,   CtrlScan84,   ShCtrlScan84,   AltScan84,   ShAltScan84,   CtrlAltScan84,   ShCtrlAltScan84,
{Shift-F2  }  Scan85,   ShScan85,   CtrlScan85,   ShCtrlScan85,   AltScan85,   ShAltScan85,   CtrlAltScan85,   ShCtrlAltScan85,
{Shift-F3  }  Scan86,   ShScan86,   CtrlScan86,   ShCtrlScan86,   AltScan86,   ShAltScan86,   CtrlAltScan86,   ShCtrlAltScan86,
{Shift-F4  }  Scan87,   ShScan87,   CtrlScan87,   ShCtrlScan87,   AltScan87,   ShAltScan87,   CtrlAltScan87,   ShCtrlAltScan87,
{Shift-F5  }  Scan88,   ShScan88,   CtrlScan88,   ShCtrlScan88,   AltScan88,   ShAltScan88,   CtrlAltScan88,   ShCtrlAltScan88,
{Shift-F6  }  Scan89,   ShScan89,   CtrlScan89,   ShCtrlScan89,   AltScan89,   ShAltScan89,   CtrlAltScan89,   ShCtrlAltScan89,
{Shift-F7  }  Scan90,   ShScan90,   CtrlScan90,   ShCtrlScan90,   AltScan90,   ShAltScan90,   CtrlAltScan90,   ShCtrlAltScan90,
{Shift-F8  }  Scan91,   ShScan91,   CtrlScan91,   ShCtrlScan91,   AltScan91,   ShAltScan91,   CtrlAltScan91,   ShCtrlAltScan91,
{Shift-F9  }  Scan92,   ShScan92,   CtrlScan92,   ShCtrlScan92,   AltScan92,   ShAltScan92,   CtrlAltScan92,   ShCtrlAltScan92,
{Shift-F10 }  Scan93,   ShScan93,   CtrlScan93,   ShCtrlScan93,   AltScan93,   ShAltScan93,   CtrlAltScan93,   ShCtrlAltScan93,
{ nicht da }  Scan94,   ShScan94,   CtrlScan94,   ShCtrlScan94,   AltScan94,   ShAltScan94,   CtrlAltScan94,   ShCtrlAltScan94,
{ nicht da }  Scan95,   ShScan95,   CtrlScan95,   ShCtrlScan95,   AltScan95,   ShAltScan95,   CtrlAltScan95,   ShCtrlAltScan95,
{< >       }  Small,    ShSmall,    CtrlSmall,    ShCtrlSmall,    AltSmall,    ShAltSmall,    CtrlAltSmall,    ShCtrlAltSmall,
{Undo      }  Undo,     ShUndo,     CtrlUndo,     ShCtrlUndo,     AltUndo,     ShAltUndo,     CtrlAltUndo,     ShCtrlAltUndo,
{Help      }  Help,     ShHelp,     CtrlHelp,     ShCtrlHelp,     AltHelp,     ShAltHelp,     CtrlAltHelp,     ShCtrlAltHelp,
{NumBlock (}  LBracket, ShLBracket, CtrlLBracket, ShCtrlLBracket, AltLBracket, ShAltLBracket, CtrlAltLBracket, ShCtrlAltLBracket,
{NumBlock )}  RBracket, ShRBracket, CtrlRBracket, ShCtrlRBracket, AltRBracket, ShAltRBracket, CtrlAltRBracket, ShCtrlAltRBracket,
{NumBlock /}  Slash,    ShSlash,    CtrlSlash,    ShCtrlSlash,    AltSlash,    ShAltSlash,    CtrlAltSlash,    ShCtrlAltSlaSh,
{NumBlock *}  Asteric,  ShAsteric,  CtrlAsteric,  ShCtrlAsteric,  AltAsteric,  ShAltAsteric,  CtrlAltAsteric,  ShCtrlAltAsteric,
{NumBlock 7}  Num7,     ShNum7,     CtrlNum7,     ShCtrlNum7,     AltNum7,     ShAltNum7,     CtrlAltNum7,     ShCtrlAltNum7,
{NumBlock 8}  Num8,     ShNum8,     CtrlNum8,     ShCtrlNum8,     AltNum8,     ShAltNum8,     CtrlAltNum8,     ShCtrlAltNum8,
{NumBlock 9}  Num9,     ShNum9,     CtrlNum9,     ShCtrlNum9,     AltNum9,     ShAltNum9,     CtrlAltNum9,     ShCtrlAltNum9,
{NumBlock 4}  Num4,     ShNum4,     CtrlNum4,     ShCtrlNum4,     AltNum4,     ShAltNum4,     CtrlAltNum4,     ShCtrlAltNum4,
{NumBlock 5}  Num5,     ShNum5,     CtrlNum5,     ShCtrlNum5,     AltNum5,     ShAltNum5,     CtrlAltNum5,     ShCtrlAltNum5,
{NumBlock 6}  Num6,     ShNum6,     CtrlNum6,     ShCtrlNum6,     AltNum6,     ShAltNum6,     CtrlAltNum6,     ShCtrlAltNum6,
{NumBlock 1}  Num1,     ShNum1,     CtrlNum1,     ShCtrlNum1,     AltNum1,     ShAltNum1,     CtrlAltNum1,     ShCtrlAltNum1,
{NumBlock 2}  Num2,     ShNum2,     CtrlNum2,     ShCtrlNum2,     AltNum2,     ShAltNum2,     CtrlAltNum2,     ShCtrlAltNum2,
{NumBlock 3}  Num3,     ShNum3,     CtrlNum3,     ShCtrlNum3,     AltNum3,     ShAltNum3,     CtrlAltNum3,     ShCtrlAltNum3,
{NumBlock 0}  Num0,     ShNum0,     CtrlNum0,     ShCtrlNum0,     AltNum0,     ShAltNum0,     CtrlAltNum0,     ShCtrlAltNum0,
{NumBlock .}  NumPoint, ShNumPoint, CtrlNumPoint, ShCtrlNumPoint, AltNumPoint, ShAltNumPoint, CtrlAltNumPoint, ShCtrlAltNumPoint,
{Enter     }  Enter,    ShEnter,    CtrlEnter,    ShCtrlEnter,    AltEnter,    ShAltEnter,    CtrlAltEnter,    ShCtrlAltEnter,
{ nicht da }  Scan115,  ShScan115,  CtrlScan115,  ShCtrlScan115,  AltScan115,  ShAltScan115,  CtrlAltScan115,  ShCtrlAltScan115,
{ nicht da }  Scan116,  ShScan116,  CtrlScan116,  ShCtrlScan116,  AltScan116,  ShAltScan116,  CtrlAltScan116,  ShCtrlAltScan116,
{ nicht da }  Scan117,  ShScan117,  CtrlScan117,  ShCtrlScan117,  AltScan117,  ShAltScan117,  CtrlAltScan117,  ShCtrlAltScan117,
{ nicht da }  Scan118,  ShScan118,  CtrlScan118,  ShCtrlScan118,  AltScan118,  ShAltScan118,  CtrlAltScan118,  ShCtrlAltScan118,
{ nicht da }  Scan119,  ShScan119,  CtrlScan119,  ShCtrlScan119,  AltScan119,  ShAltScan119,  CtrlAltScan119,  ShCtrlAltScan119,
{Alt-1     }  Scan120,  ShScan120,  CtrlScan120,  ShCtrlScan120,  AltScan120,  ShAltScan120,  CtrlAltScan120,  ShCtrlAltScan120,
{Alt-2     }  Scan121,  ShScan121,  CtrlScan121,  ShCtrlScan121,  AltScan121,  ShAltScan121,  CtrlAltScan121,  ShCtrlAltScan121,
{Alt-3     }  Scan122,  ShScan122,  CtrlScan122,  ShCtrlScan122,  AltScan122,  ShAltScan122,  CtrlAltScan122,  ShCtrlAltScan122,
{Alt-4     }  Scan123,  ShScan123,  CtrlScan123,  ShCtrlScan123,  AltScan123,  ShAltScan123,  CtrlAltScan123,  ShCtrlAltScan123,
{Alt-5     }  Scan124,  ShScan124,  CtrlScan124,  ShCtrlScan124,  AltScan124,  ShAltScan124,  CtrlAltScan124,  ShCtrlAltScan124,
{Alt-6     }  Scan125,  ShScan125,  CtrlScan125,  ShCtrlScan125,  AltScan125,  ShAltScan125,  CtrlAltScan125,  ShCtrlAltScan125,
{Alt-7     }  Scan126,  ShScan126,  CtrlScan126,  ShCtrlScan126,  AltScan126,  ShAltScan126,  CtrlAltScan126,  ShCtrlAltScan126,
{Alt-8     }  Scan127,  ShScan127,  CtrlScan127,  ShCtrlScan127,  AltScan127,  ShAltScan127,  CtrlAltScan127,  ShCtrlAltScan127,
{Alt-9     }  Scan128,  ShScan128,  CtrlScan128,  ShCtrlScan128,  AltScan128,  ShAltScan128,  CtrlAltScan128,  ShCtrlAltScan128,
{Alt-0     }  Scan129,  ShScan129,  CtrlScan129,  ShCtrlScan129,  AltScan129,  ShAltScan129,  CtrlAltScan129,  ShCtrlAltScan129,
{Alt-û     }  Scan130,  ShScan130,  CtrlScan130,  ShCtrlScan130,  AltScan130,  ShAltScan130,  CtrlAltScan130,  ShCtrlAltScan130,
{Alt-'     }  Scan131,  ShScan131,  CtrlScan131,  ShCtrlScan131,  AltScan131,  ShAltScan131,  CtrlAltScan131,  ShCtrlAltScan131,
{ nicht da }  Scan132,  ShScan132,  CtrlScan132,  ShCtrlScan132,  AltScan132,  ShAltScan132,  CtrlAltScan132,  ShCtrlAltScan132,

{Nada      }  NullChar); {Phew!}

TYPE  PtrKeymap = ^Keymap;
      KeyMap =    ARRAY [tKey] OF CHAR;
                 (* Die Keymap bestimmt, welche Zeichen einem Tastendruck 
                  * zugeordnet werden.  Nicht jede Tastenkombination entspricht
                  * einen lesbarem Asciizeichen!
                  *)

CONST DkCircum = Bit0;  { ^ }
      DkTilde =  Bit1;  { ~ }
      DkAgui =   Bit2;  { ' }
      DkGrave =  Bit3;  { ` }
      DkQuote =  Bit4;  { " }
      DkSmoere = Bit5;  { ¯ }
      DkCedil =  Bit6;  { , }
      DkSlash =  Bit7;  { / }

(* Eventhandler *)

CONST MaxHandler =      63; (* (0..MaxHandler) Handler maximal zulassen 
                             * Kann bei Bedarf erweitert werden, Magic
                             * reagiert darauf!!!
                             *)

TYPE  PtrEP =           ^EventParameter;
      EventParameter =  RECORD
                         id:      INTEGER;
                         mstatus: BITSET;  (* Maustastenstatus *)
                         mx, my:  INTEGER; (* Mausposition *)
                         mklicks: INTEGER; (* Anzahl Klicks *)
                         kcode:   tKey;    (* mpKeyboard-Tastenkode *)
                         ktaste:  INTEGER; (* AES-Tastenkode *)
                         kscan:   INTEGER; (* Scancode *)
                         kascii:  CHAR;    (* Ascii-Kode *)
                         kstatus: BITSET;  (* Sondertastenstatus *)
                         mesag:   ARRAY [0..7] OF INTEGER; (* Messagebuffer *)
                         stepin:  INTEGER; (* TRUE = Rechteck betreten *)
                         ready:   INTEGER; (* <> 0 Ereignis bearbeitet *)
                         app:     POINTER;
                         res1:    BITSET;  (* Don't use it... *)
                         res2:    BITSET;  (* ...or the bombs... *)
                         res3:    INTEGER; (* ...will get you!!! *)
                        END;
      
TYPE  HandleEvent =    PROCEDURE (para: PtrEP);

TYPE  HandlerArray =   ARRAY [0..MaxHandler] OF
                         RECORD
                          proc: HandleEvent;
                          used: INTEGER;
                         END;

TYPE  TimerArray =      ARRAY [0..MaxHandler] OF
                         RECORD
                          proc:    HandleEvent;
                          time:    LONGINT;
                          elapsed: LONGINT;
                          used:    INTEGER;
                         END;

TYPE  RectArray =       ARRAY [0..MaxHandler] OF
                         RECORD
                          proc: HandleEvent;
                          rect: tRect;
                          drin: INTEGER;
                          used: INTEGER;
                         END;

TYPE  PtrHandlerList =  ^tHandlerList;
      tHandlerList =    RECORD
                         max:        INTEGER;
                         events:     BITSET;
                         disabled:   BITSET;
                         prioKeybd:  INTEGER;
                         prioButton: INTEGER;
                         prioMesag:  INTEGER;
                         prioTimer:  INTEGER;
                         parablock:  EventParameter;
                         keybd:      HandlerArray;
                         button:     HandlerArray;
                         mesag:      HandlerArray;
                         moved:      HandlerArray;
                         timer:      TimerArray;
                         rects:      RectArray;
                        END;


(* Magic Felder *)

TYPE  tLongArray =      ARRAY [0..15] OF LONGINT;
      tAddrArray =      ARRAY [0..15] OF POINTER;

TYPE  PtrMagicPB =      ^MagicParablock;
      MagicParablock =  RECORD
                         intin:    tIntin;
                         longin:   tLongArray;
                         addrin:   tAddrArray;
                         intout:   tIntin;
                         longout:  tLongArray;
                         addrout:  tAddrArray;
                         reserved: tAddrArray;
                         version:  INTEGER;
                         idcode:   INTEGER;
                         flags:    LONGBITSET;
                        END;


CONST MaxDials = 15; (* Stapeltiefe fÅr normale Dialoge. Kann bei Bedarf
                      * beliebig erweitert werden, Magic reagiert darauf.
                      *)

TYPE PtrDialstack =     ^DialStack;
     DialStack =        RECORD
                         stackptr: INTEGER; (* Stapeltiefe der Dialoge *)
                         max:      INTEGER; (* Wieviele dÅrfens denn sein? *)
                         dials:    ARRAY [0..MaxDials] OF POINTER;
                        END;

CONST MaxValues = 9; (* Anzahl der EintrÑge im Valuetable.
                       * Kann beliebig erweitert werden, Magic reagiert darauf.
                       *)

TYPE  PtrAppValues =    ^AppValues;
      AppValues =       RECORD
                         max:    INTEGER;
                         values: ARRAY [0..MaxValues] OF LONGINT;
                        END;
     

(* Parameterblîcke *)

TYPE PtrApp =           ^Application;
     Application =      RECORD
                         AESPB:         PtrAESPB;   (* AES-Parameter *)
                         VDIPB:         PtrVDIPB;   (* VDI-Parameter *)
                         MagicPB:       PtrMagicPB; (* Magic Parameter *)
                         
                         (* Eventdispatcher *)
                         Handler:       PtrHandlerList;
                         
                         Dials:         POINTER;
                         Alert:         POINTER;
                         Stack:         PtrDialstack;
                         (* da steht spÑter fÅr jede Applikation die Liste 
                          * der Dialoge drin...
                          *)

                         Windows:       POINTER;
                         TopWindow:     POINTER;
                         TextWindow:    POINTER;
                         TopTextwin:    POINTER;
                         ApplIcon:      POINTER; (* Applikations-Icon *)
                         reserverd:     POINTER; (* Reserviert *)
                          (* ...und hier die Fenster... *)
                          
                         MainMenu:      POINTER;
                         Menus:         POINTER;
                          (* ...und die MenÅzeilen... *)
                          
                         Popups:        POINTER;
                          (* ...und die Popups... *)
                        
                         Rsc:           POINTER;
                          (* ...die geladenen Resourcen *)
                          
                         Workstations:  PtrWS;
                          (* Liste der Workstations *)

                         TermProc:      POINTER;
                          (* Liste der End-Prozeduren *)
                          
                         Name:          POINTER;
                          (* Zeiger auf Nullchar-terminierte Zeichenkette, 
                           * die den Namen des Programms enthÑlt
                           *)
                         
                         Values:        PtrAppValues;
                          (* Zeiger auf den Valuetable einer Applikation
                           * Hier werden diverse Werte zwischengespeichert,
                           * als Quasi-Konstanten sozusagen.
                           *)
                         
                         Keyboard:      ^KeyMap;
                           
                         flags:         LONGBITSET;
                         dummy:         LONGINT;
                         errcode:       LONGINT;
                         wucount:       LONGINT;
                         Reserved1:     POINTER;
                         Reserved2:     POINTER;
                         Reserved3:     POINTER;
                         Reserved4:     POINTER;
                         UserEmergency: PROCEDURE;
                          (* Vorsichtshalber, man weiss ja nie was kommt *)
                         Next:          PtrApp;
                        END;

CONST Appsize = SIZEOF (Application);


CONST AppGesperrt =   lBit0;  (* Applikationsspezifische Flags *)
      EndDispatch =   lBit1;
      ScreenLocked =  lBit2;
      ScreenControl = lBit3;
      MapNblock =     lBit4;
      (* Alle anderen Flags sind fÅr interne Zwecke reserviert!!! *)

(* Typdeklarationen nach dem Profibuch *)

TYPE    Int11Array =    ARRAY [0.. 11] OF INTEGER;
        Int255Array =   ARRAY [0..255] OF INTEGER;
        Int512Array =   ARRAY [0..512] OF INTEGER;

TYPE    PtrPD =         ^PD;
        PD =            RECORD
                         pLowtpa:       POINTER;
                         pHitpa:        POINTER;
                         pTbase:        POINTER;
                         pTlen:         LONGINT;
                         pDbase:        POINTER;
                         pDlen:         LONGINT;
                         pBbase:        POINTER;
                         pBlen:         LONGINT;
                         pDta:          POINTER;
                         pParent:       PtrPD;
                         res1:          POINTER;
                         pEnv:          POINTER;
                         devx:          ARRAY [0..5] OF BYTE;
                         res2:          BYTE;
                         defdrv:        BYTE;
                         pUndef:        ARRAY [0..17] OF LONGINT;
                         pCmdlin:       ARRAY [0..126] OF CHAR;
                        END;

TYPE    BITBLK =        RECORD
                         bWd:           INTEGER;
                         bHt:           INTEGER;
                         planeCt:       INTEGER;
                         fgCol:         INTEGER;
                         bgCol:         INTEGER;
                         opTab:         ARRAY [0..3] OF BYTE;
                         sXmin:         INTEGER;
                         sYmin:         INTEGER;
                         sForm:         POINTER;
                         sNxwd:         INTEGER;
                         sNxln:         INTEGER;
                         sNxpl:         INTEGER;
                         dXmin:         INTEGER;
                         dYmin:         INTEGER;
                         dForm:         POINTER;
                         dNxwd:         INTEGER;
                         dNxln:         INTEGER;
                         dNxpl:         INTEGER;
                         pAddr:         POINTER;
                         pNxln:         INTEGER;
                         pNxpl:         INTEGER;
                         pMask:         INTEGER;
                         filler:        ARRAY [0..23] OF BYTE;
                        END;

TYPE    PtrFONTHDR =    ^FONTHDR;
        FONTHDR =       RECORD
                         fontId:        INTEGER;
                         point:         INTEGER;
                         name:          ARRAY [0..31] OF CHAR;
                         firstAde:      INTEGER;
                         lastAde:       INTEGER;
                         top:           INTEGER;
                         ascent:        INTEGER;
                         half:          INTEGER;
                         descent:       INTEGER;
                         bottom:        INTEGER;
                         maxCharwidth:  INTEGER;
                         maxCellwidth:  INTEGER;
                         leftOffset:    INTEGER;
                         rightOffset:   INTEGER;
                         thicken:       INTEGER;
                         ulSize:        INTEGER;
                         lighten:       INTEGER;
                         skew:          INTEGER;
                         flags:         BITSET;
                         horTable:      ^Int255Array;
                         offTable:      ^Int255Array;
                         datTable:      POINTER;
                         formWidth:     INTEGER;
                         formHeight:    INTEGER;
                         nextFont:      PtrFONTHDR;
                        END;

TYPE    IMGHEADER =     RECORD
                         imVersion:     INTEGER;
                         imHeadlength:  INTEGER;
                         imNplanes:     INTEGER;
                         imPatlen:      INTEGER;
                         imPixwidth:    INTEGER;
                         imPixheight:   INTEGER;
                         imScanwidth:   INTEGER;
                         imNlines:      INTEGER;
                        END;

TYPE    PtrLINEA =      ^LINEAVARS;
        LINEAVARS =     RECORD
                         PLANES:        INTEGER;
                         WIDTH:         INTEGER;
                         CONTRL:        ^Int11Array;
                         INTIN:         ^Int255Array;
                         PTSIN:         ^Int255Array;
                         INTOUT:        ^Int255Array;
                         PTSOUT:        ^Int255Array;
                         COLBIT0:       INTEGER;
                         COLBIT1:       INTEGER;
                         COLBIT2:       INTEGER;
                         COLBIT3:       INTEGER;
                         LSTLIN:        INTEGER;
                         LNMASK:        BITSET;
                         WMODE:         INTEGER;
                         X1:            INTEGER;
                         Y1:            INTEGER;
                         X2:            INTEGER;
                         Y2:            INTEGER;
                         PATPTR:        POINTER;
                         PATMSK:        BITSET;
                         MFILL:         INTEGER;
                         CLIP:          INTEGER;
                         XMINCL:        INTEGER;
                         YMINCL:        INTEGER;
                         XMAXCL:        INTEGER;
                         YMAXCL:        INTEGER;
                         XDDA:          INTEGER;
                         DDAINC:        INTEGER;
                         SCALDIR:       INTEGER;
                         MONO:          INTEGER;
                         SOURCEX:       INTEGER;
                         SOURCEY:       INTEGER;
                         DESTX:         INTEGER;
                         DESTY:         INTEGER;
                         DELX:          INTEGER;
                         DELY:          INTEGER;
                         FBASE:         PtrFONTHDR;
                         FWIDTH:        INTEGER;
                         STYLE:         BITSET;
                         LITEMASK:      BITSET;
                         SKEWMASK:      BITSET;
                         WEIGHT:        INTEGER;
                         ROFF:          INTEGER;
                         LOFF:          INTEGER;
                         SCALE:         INTEGER;
                         CHUP:          INTEGER;
                         TEXTFG:        INTEGER;
                         SCRTCHP:       POINTER;
                         SCRTP2:        INTEGER;
                         TEXTBG:        INTEGER;
                         COPYTRAN:      INTEGER;
                         SEEDABORT:     POINTER;
                        END;

TYPE    PtrLINEAFonts = ^LINEAFontArray;
        LINEAFontArray = ARRAY [0..2] OF PtrFONTHDR;

TYPE    METAHDR =       RECORD
                         mfHeader:      INTEGER;
                         mfHlenght:     INTEGER;
                         mfVersion:     INTEGER;
                         mfNdcrcfl:     INTEGER;
                         mfExtents:     ARRAY [0..3] OF INTEGER;
                         mfPagesz:      ARRAY [0..1] OF INTEGER;
                         mfCoords:      ARRAY [0..3] OF INTEGER;
                         mfImgflag:     INTEGER;
                         mfResvd:       ARRAY [0..8] OF INTEGER;
                        END;

TYPE    MFORM =         RECORD
                         mfXhot:        INTEGER;
                         mfYhot:        INTEGER;
                         mfNplanes:     INTEGER;
                         mfFg:          INTEGER;
                         mfBg:          INTEGER;
                         mfMask:        ARRAY [0..15] OF INTEGER;
                         mfData:        ARRAY [0..15] OF INTEGER;
                        END;

TYPE    RSHDR =         RECORD
                         rshVrsn:       INTEGER;
                         rshObject:     INTEGER;
                         rshTedinfo:    INTEGER;
                         rshIconblk:    INTEGER;
                         rshBitblk:     INTEGER;
                         rshFrstr:      INTEGER;
                         rshString:     INTEGER;
                         rshImdata:     INTEGER;
                         rshFrimg:      INTEGER;
                         rshTrindex:    INTEGER;
                         rshNobs:       INTEGER;
                         rshNtree:      INTEGER;
                         rshNted:       INTEGER;
                         rshNib:        INTEGER;
                         rshNbb:        INTEGER;
                         rshNstring:    INTEGER;
                         rshNimages:    INTEGER;
                         rshRssize:     WORD;
                        END;

TYPE    SDB =           RECORD
                         xhot:          INTEGER;
                         yhot:          INTEGER;
                         form:          INTEGER;
                         bgcol:         INTEGER;
                         fgcol:         INTEGER;
                         image:         ARRAY [0..31] OF INTEGER;
                        END;

TYPE    PtrSYSHDR =     ^SYSHDR;
        SYSHDR =        RECORD
                         osEntry:       INTEGER; 
                         osVersion:     INTEGER;
                         osReset:       POINTER;
                         osBeg:         POINTER;
                         osEnd:         POINTER;
                         osRsv1:        POINTER;
                         osMagic:       POINTER;
                         osDate:        LONGINT;
                         osConf:        INTEGER;
                         osDosdate:     INTEGER;
                         root:          POINTER;
                         kbshift:       POINTER;
                         run:           POINTER;
                         osRsv2:        POINTER; 
                        END;

TYPE    PtrVDIESC =     ^VDIESCVars;
        VDIESCVars =    RECORD
                         RESERVED6:     LONGINT;
                         CURFONT:       ^FONTHDR;
                         RESERVED5:     ARRAY [0..23] OF INTEGER;
                         MPOSHX:        INTEGER;
                         MPOSHY:        INTEGER;
                         MPLANES:       INTEGER;
                         MCDBBG:        INTEGER;
                         MCDBFG:        INTEGER;
                         MASKFORM:      ARRAY [0..31] OF INTEGER;
                         INQTAB:        ARRAY [0..44] OF INTEGER;
                         DEVTAB:        ARRAY [0..44] OF INTEGER;
                         GCURX:         INTEGER;
                         GCURY:         INTEGER;
                         MHIDCT:        INTEGER;
                         MOUSEBT:       INTEGER;
                         REQCOL:        ARRAY [0..47] OF INTEGER;
                         SIZTAB:        ARRAY [0..14] OF INTEGER;
                         RESERVED4:     ARRAY [0..1] OF INTEGER;
                         CURWORK:       POINTER;
                         DEFFONT:       ^FONTHDR;
                         FONTRING:      ARRAY [0..3] OF POINTER;
                         FONTCOUNT:     INTEGER;
                         RESERVED3:     ARRAY [0..44] OF INTEGER;
                         CURMSSTAT:     BYTE;
                         RESERVED2:     BYTE;
                         VHIDCNT:       INTEGER;
                         CURX:          INTEGER;
                         CURY:          INTEGER;
                         CURFLAG:       BYTE;
                         MOUSEFLAG:     BYTE;
                         RESERVED1:     LONGINT;
                         VSAVXY:        ARRAY [0..1] OF INTEGER;
                         SAVELEN:       INTEGER;
                         SAVEADDR:      POINTER;
                         SAVESTAT:      BITSET;
                         SAVEAREA:      ARRAY [0..63] OF LONGINT;
                         USERTIM:       POINTER;
                         NEXTTIM:       POINTER;
                         USERBUT:       POINTER;
                         USERCUR:       POINTER;
                         USERMOT:       POINTER;
                         VCELHT:        INTEGER;
                         VCELMX:        INTEGER;
                         VCELMY:        INTEGER;
                         VCELWR:        INTEGER;
                         VCOLBG:        INTEGER;
                         VCOLFG:        INTEGER;
                         VCURAD:        POINTER;
                         VCUROF:        INTEGER;
                         VCURXY:        ARRAY [0..1] OF INTEGER;
                         VPERIOD:       BYTE;
                         VCURCT:        BYTE;
                         VFNTAD:        POINTER;
                         VFNTND:        INTEGER;
                         VFNTST:        INTEGER;
                         VFNTWD:        INTEGER;
                         VREZHZ:        INTEGER;
                         VOFFAD:        POINTER;
                         RESERVED:      INTEGER;
                         VREZVT:        INTEGER;
                         BYTESLIN:      INTEGER;
                        END;

TYPE tChar =    RECORD
                 CASE INTEGER OF
                  0: (long:     LONGINT);
                  1: (hi, lo:   INTEGER);
                  2: (kbshift, reserved, scan, char: CHAR);
                END;

TYPE    PtrDTA =        ^mDTA;
        mDTA =          RECORD
                         dReserved: ARRAY [0..20] OF Byte;
                         dAttrib:   BYTE;
                         dTime:     INTEGER;
                         dDate:     INTEGER;
                         dLength:   LONGINT;
                         dFname:    ARRAY [0..13] OF CHAR;
                        END;

CONST   ReadOnly =      Bit0;
        Hidden =        Bit1;
        Systemfile =    Bit2;
        Volume =        Bit3;
        Folder =        Bit4;
        Archive =       Bit5;

IMPLEMENTATION

END (*M_Types*).
