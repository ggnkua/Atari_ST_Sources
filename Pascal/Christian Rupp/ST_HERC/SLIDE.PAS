Program Slide_Show;

{ Bringt eine Serie von Hercules-Bildern nacheinander auf den Bildschirm. }
{ Die Dateinamen der Bilder sind in der Datei INHALT abgelegt.            }


{$C-}
{$U-}


Const GrafBase = $B000;


Type strg40 = string [40];


Var SourceName : strg40;
    Eingabe    : Char;
    Liste      : Text;
    Filenamen  : Array [1..50] of strg40;
    Anz_Files  : Integer;
    Bild       : Integer;
    Abbruch    : Boolean;



procedure HGCgrafmode;
const ysync = $58;
      modus : array [0..11] of byte
            = ($36, $2D, $2F, $07, $5B, $00, $58,
               ysync, $02, $03, $00, $00);
var   reg   : byte;
Begin
  port [$03BF] := 3;
  for reg := 0 to 11 do Begin
                          port [$03B4] := reg;
                          port [$03B5] := modus [reg];
                        End;
  Inline ($BA/$BA/$03/$EC/$24/$80/$E1/$FB);
  port [$03B8] := $0A;
  port [$03BF] := $03;
  fillchar (mem [grafbase:0000],$7FFF,0);
End;





Procedure HGCtextmode;
var register : record
                 ax, bx, cx, dx, bp,
                 di, si, ds, es, flags : integer;
               end;
Begin
  with register do Begin
                     ax := 7;
                     intr ($10, register);
                   End;
End;





Procedure Warte (Zeit : Integer);
Var I : Integer;
    Z : Char;
Begin
  If Zeit > 30 then Zeit := 30;
  I := 1;
  Repeat
    delay (8);
    I := I + 1;
  Until (I > (Zeit * 100)) or keypressed;
  While keypressed do Read (KBD, Z);
  If (Z = #27) then Abbruch := TRUE
               else Abbruch := FALSE;
End;





Procedure Bild_laden (Filename : strg40);
const Bildgroesse = 256;
var Zeiger_Byte : ^Byte;
    Bilddatei   : File;
Begin
  Zeiger_Byte := Ptr (GrafBase,$0000);
  Assign (Bilddatei, Filename);
  {$I-}
  Reset (Bilddatei);
  {$I+}
  If IOresult = 0 then Begin
                         BlockRead (Bilddatei,Zeiger_Byte^,Bildgroesse);
                         Close (Bilddatei);
                       End;
End;





Begin
  ClrScr;
  Assign (liste, 'INHALT');
  {$I-}
  Reset (liste);
  {$I+}
  If IOresult = 0
    then Begin
           Anz_Files := 0;
           Repeat
             Anz_Files := Anz_Files + 1;
             Readln (liste, Filenamen [Anz_Files]);
           Until Eof (liste);
           ClrScr;
           HGCgrafmode;
           Repeat
             For Bild := 1 to Anz_Files do
               If not Abbruch then Begin
                                     Bild_laden (Filenamen [Bild]);
                                     Warte (30);
                                   End;
           Until Abbruch;
           HGCtextmode;
           ClrScr;
         End
    else Write ('Fehler beim ™ffnen der Datei "INHALT" !',#7);
End.


