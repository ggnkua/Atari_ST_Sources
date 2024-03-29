UNIT M_Advanced;

INTERFACE

USES Basics, M_Appl, AES;

(* Modus-flags *)

                              (* Generelle Flags                                 *)
                              (*-------------------------------------------------*)
CONST fbRedraw =     lBit0;   (* List- bzw. Dropbox nach dem F�llen neu anzeigen *)
      fbOneSpace =   lBit1;   (* 1 Leerzeichen vor dem Eintrag lassen            *)
      fbTwoSpace =   lBit2;   (* 2 Leerzeichen vor dem Eintrag lassen            *)

                              (* Bits f�r Fillfontbox                            *)
                              (*-------------------------------------------------*)
CONST fbAll =        lBit8;   (* Alle Fonts in die Listbox                       *)
      fbBitmap =     lBit9;   (* Nur Bitmapfonts in die Listbox                  *)
      fbSpeedo =     lBit10;  (* Nur Speedofonts in die Listbox                  *)
      fbTTF =        lBit11;  (* Nur Truetypefonts in die Listbox                *)
      fbType1 =      lBit12;  (* Nur Postscriptfonts in die Listbox              *)
      fbMono =       lBit13;  (* Nur monospaced Fonts in die Listbox             *)
      fbMarkMono =   lBit14;  (* monospaced speziell Markieren                   *)

                              (* Bits f�r Fillcolorbox                           *)
                              (*-------------------------------------------------*)
CONST fbEnglish =    lBit8;   (* Texte in englischer Sprache                     *)



PROCEDURE FillFontbox   (tree: tObjctree; item, ws, default: INTEGER; mode: LONGBITSET);
(* F�llt eine List- oder Dropbox mit eine Liste von Fonts 
 *
 * tree = Adresse des Objektbaums der Listbox 
 * item = Objektnummer der Listbox 
 * ws =   Handle der Workstation
 * mode = Modus
 *
 * Wenn man den Inhalt eines Listboxeintrags einer mit dieser Funktion
 * gef�llten Listbox mit GetEntry abfragt, erh�lt man im Parameter 'data'
 * einen Zeiger auf ein Datenfeld vom Typ PtrFONT.
 *)

PROCEDURE FillDriverbox (tree: tObjctree; item: INTEGER; dev: Device; default: INTEGER; mode: LONGBITSET);
(* F�llt eine List- oder Dropbox mit eine Liste von VDI-Treibern 
 *
 * tree = Adresse des Objektbaums der Listbox 
 * item = Objektnummer der Listbox 
 * dev =  Device das behandelt werden soll
 * mode = Nur allgemeine Funktionen
 *
 * Wenn man den Inhalt eines Listboxeintrags einer mit dieser Funktion
 * gef�llten Listbox mit GetEntry abfragt, erh�lt man im Parameter 'data'
 * gewandelt in ein INTEGER (physnum:= INTEGER (data);) die physikalische 
 * Devicenummer.  Diese braucht man zum gezielten �ffnen des jeweiligen Ger�ts!
 *)

PROCEDURE FillFilebox   (tree: tObjctree; item, default: INTEGER; CONST path: ARRAY OF CHAR; mode: LONGBITSET);
(*
 * NOCH NICHT IMPLEMENTIERT!!!
 *
 * F�llt eine List- oder Dropbox mit eine Liste von Files 
 *
 * tree = Adresse des Objektbaums der Listbox 
 * item = Objektnummer der Listbox 
 * path = Laufwerk und Pfad, das behandelt werden soll
 * mode = Nur allgemeine Funktionen
 *
 * Wenn man den Inhalt eines Listboxeintrags einer mit dieser Funktion
 * gef�llten Listbox mit GetEntry abfragt, erh�lt man im Parameter 'data'
 * einen Zeiger auf folgende Struktur:
 *)

PROCEDURE FillColorbox  (tree: tObjctree; item, default: INTEGER; mode: LONGBITSET);

IMPLEMENTATION

USES M_Sys;

PROCEDURE FillFontbox   (tree: tObjctree; item, ws, default: INTEGER; mode: LONGBITSET);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:=  item;
 App^.MagicPB^.IntIn[1]:=  ws;
 App^.MagicPB^.IntIn[2]:=  default;
 App^.MagicPB^.LongIn[0]:= LBitsetToLong (mode);
 CallMagic (2600);
END (*FillFontbox*);

PROCEDURE FillDriverbox (tree: tObjctree; item: INTEGER; dev: Device; default: INTEGER; mode: LONGBITSET);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:=  item;
 App^.MagicPB^.IntIn[1]:=  ORD (dev);
 App^.MagicPB^.IntIn[2]:=  default;
 App^.MagicPB^.LongIn[0]:= LBitsetToLong (mode);
 CallMagic (2601);
END (*Filldriverbox*);

PROCEDURE FillFilebox (tree: tObjctree; item, default: INTEGER; CONST path: ARRAY OF CHAR; mode: LONGBITSET);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= ADDR (path);
 App^.MagicPB^.IntIn[0]:=  item;
 App^.MagicPB^.IntIn[1]:=  default;
 App^.MagicPB^.LongIn[0]:= LBitsetToLong (mode);
 CallMagic (2602);
END (*FillFilebox*);

PROCEDURE FillColorbox  (tree: tObjctree; item, default: INTEGER; mode: LONGBITSET);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:=  item;
 App^.MagicPB^.IntIn[1]:=  default;
 App^.MagicPB^.LongIn[0]:= LBitsetToLong (mode);
 CallMagic (2603);
END (*FillFilebox*);

END (*m_Advanced*).
