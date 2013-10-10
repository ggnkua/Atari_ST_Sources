
(*
!TT 4.4.94 - Fehler in MM2Comp2 behoben

Gruppe: Pers”nliche
ID  : P9637@K0
Wg. : MM2 Update Bugreport No. 1B
Von : castan@cip.physik.uni-stuttgart.de (Di, 22.02.94 12:44)
Name: Gerd Castan
An  : Thomas Tempelmann @ M
MId : 0097A709.0D49E580.11300@cip.physik.uni-stuttgart.de
 
Hallo Thomas,

Ich hatte Dir geschrieben
>Mit dem neuen Compiler gibt es bei der letzten geschweiften Klammer die
>Fehlermeldung:
>Interner Fehler: Adresse nicht ansprechbar > V#3592:196,18640,101874,109892

Ich habe das Modul von Magic-Importen befreit, indem ich die entsprechenden
Magic-Typen einfach ins Modul kopiert habe.
Helli moege es mir verzeihen.
Der Fehler tritt auch weiterhin auf.
Er tritt auch auf, wenn das Compilieren nach dem einschalten des Rechners
sofort durchgefuehrt wird ohne vorher etwas anderes zu tun.

Der Fehler in Dirks Modul l„žt sich nicht mehr reproduzieren, obwohl er
beliebig reproduzierbar war, als ich Dir den Bugreport geschrieben habe.

*)

DEFINITION MODULE TT;
(*------------------------------------------------------------------------*)
(* FSM-Score                                                              *)
(* FontInfo                                                               *)
(*------------------------------------------------------------------------*)
(* Version | Datum    | Arbeitsbericht                                    *)
(* 1       | 24.06.93 | tFontInfo                                         *)
(* 2       | 29.01.95 | tLineInfo                                         *)
(* 3       | 29.01.95 | tFillInfo                                         *)
(* 4       | 29.01.95 | tPFillInfo                                        *)
(*------------------------------------------------------------------------*)

IMPORT SYSTEM;

(*------------------------------------------------------------------------*)
(* MagicVDI:                                                              *)
(*------------------------------------------------------------------------*)

CONST   LeftJust =      0;
        Centerd =       1;
        RightJust =     2;

CONST   BaseJust =      0;
        HalfJust =      1;
        AscentJust =    2;
        BottomJust =    3;
        DescentJust =   4;
        TopJust =       5;

CONST   Line =          1;      (* Linienstile *)
        LongDash =      2;
        Dot =           3;
        DashDot =       4;
        Dash =          5;
        DashDotDot =    6;
        User =          7;

CONST   Cornerd =       0;      (* Linien-Endtypen *)
        Arrow =         1;
        Rounded =       2;

CONST   REPLACE =        1;      (* Schreibmodi *)
        TRANSPARENT =    2;
        XOR =            3;
        REVTRANSPARENT = 4;

CONST   None =          0;      (* Flltypen *)
        Full =          1;
        Pattern =       2;
        Hatch =         3;
        UserFill =      4;


(*------------------------------------------------------------------------*)
(* MagicAES:                                                              *)
(*------------------------------------------------------------------------*)

CONST   WHITE =          0;     (* Farben *)
        BLACK =          1;

(*------------------------------------------------------------------------*)
(* MagicSys:                                                              *)
(*------------------------------------------------------------------------*)

(* 16-Bit Typen *)

TYPE    sWORD =         SYSTEM.WORD;
        sINTEGER =      INTEGER;
        sCARDINAL =     CARDINAL;
        sBITSET =       BITSET;

(*------------------------------------------------------------------------*)
(* Spezialfall:                                                           *)
(* wrmode wirkt sich auf alle Ausgaben (Text, Linien, Fllmuster) aus.    *)
(* Deshalb taucht diese Variable in allen t...Info auf.                   *)
(*                                                                        *)
(* In GcLazyVDI geniežt diese Variable deshalb eine Sonderbehandlung      *)
(*------------------------------------------------------------------------*)


(*------------------------------------------------------------------------*)
(* Font                                                                   *)
(*------------------------------------------------------------------------*)

TYPE
  tFontInfo =
    RECORD
      id:     sINTEGER;     (* Font-ID *)
      color:  sINTEGER;     (* Farbindex *)
      rot:    sINTEGER;     (* Rotationsrichtung *)
      halign: sINTEGER;     (* Horizontale Ausrichtung *)
      valign: sINTEGER;     (* Vertikale Ausrichtung *)
      effect: sBITSET;      (* Texteffekte *)
      wrmode: sINTEGER;     (* TRANSPARENT... *)
      point:  sINTEGER;     (* aktuelle Gr”že des Fonts *)
      width:  sINTEGER;     (* Breite bei FSM-Fonts *)
      skew:   sINTEGER;     (* Neigung bei FSM-Fonts *)
      mono:   BOOLEAN;      (* TRUE, wenn Monospaced *)
      fsm:    BOOLEAN;      (* TRUE, wenn FSM-Font *)
      charmap: sINTEGER;    (* Atari oder Bitstream bei Speedo *)
      kern:    sINTEGER;    (* Kerning-mode bei Speedo *)
    END;


CONST
  Atcs = 0;
  emptyFontInfo = tFontInfo {
    1,          (* id *)
    BLACK,      (* color *)
    0,          (* rot *)
    LeftJust,   (* halign *)
    BaseJust,   (* valign *)
    sBITSET{},  (* effect *)
    TRANSPARENT,(* wrmode *)
    10,         (* point *)
    10,         (* width *)
    0,          (* skew *)
    TRUE,       (* mono *)
    FALSE,      (* fsm *)
    Atcs,       (* charmap *)
    1           (* kern, 1=normal *)
  };

(*------------------------------------------------------------------------*)
(* Line                                                                   *)
(*------------------------------------------------------------------------*)

TYPE
  tLineInfo =
    RECORD
      type   : sINTEGER;  (* Falls type=User muž width=1 sein! *)
      udsty  : sINTEGER;
      width  : sINTEGER;
      color  : sINTEGER;
      begin  : sINTEGER;
      end    : sINTEGER;
      wrmode : sINTEGER;     (* TRANSPARENT... *)
    END;

CONST
  emptyLineInfo = tLineInfo {
    Line,
    MIN(sINTEGER),
    1,
    BLACK,
    Cornerd,
    Cornerd,
    REPLACE
  };

(*------------------------------------------------------------------------*)
(* Fllmuster                                                             *)
(*------------------------------------------------------------------------*)

TYPE
  tFillInfo =
    RECORD
      interior  : sINTEGER;
      style     : sINTEGER;
      color     : sINTEGER;
      perimeter : BOOLEAN;
      wrmode    : sINTEGER;     (* TRANSPARENT... *)
    END;

CONST
  emptyFillInfo = tFillInfo {
    Full,
    0,
    BLACK,
    TRUE,
    REPLACE
  };

(*------------------------------------------------------------------------*)
(* Fllmuster mit Rand                                                    *)
(*------------------------------------------------------------------------*)

TYPE
  tPFillInfo =
    RECORD
      f: tFillInfo;
      l: tLineInfo;
    END;

CONST
  emptyPFillInfo = tPFillInfo {
    emptyFillInfo,
    emptyLineInfo
(*Interner Fehler: Adresse nicht ansprechbar > V#3592:196,18640,101874,109892
 * an der Klammer in der n„chsten Zeile *)
  };

END TT.

(*
CASTAN@cip.physik.uni-stuttgart.de; alias: G.Castan@physik.uni-stuttgart.de
Gerd Castan * Hoehbergstr. 16 * D-70327 Stuttgart
*)
