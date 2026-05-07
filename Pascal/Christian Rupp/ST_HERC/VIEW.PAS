Program View;


{ Liest ein Hercules-Bild von Diskette und zeigt es am Bildschirm an }


Const GrafBase = $B000;


Type strg40 = string [40];


Var SourceName : strg40;
    Taste      : Char;





Procedure HGCgrafmode;

{ Schaltet die Hercules-Karte in den Grafikmodus, Bildschirmseite 1 }

Const Ysync = $58;
      Modus : Array [0..11] of Byte
            = ($36, $2D, $2F, $07, $5B, $00, $58,
               Ysync, $02, $03, $00, $00);

Var   Reg   : byte;

Begin
  Port [$03BF] := 3;
  For Reg := 0 to 11 do Begin
                          Port [$03B4] := Reg;
                          Port [$03B5] := Modus [Reg];
                        End;
  Inline ($BA/$BA/$03/$EC/$24/$80/$E1/$FB);
  Port [$03B8] := $0A;
  Port [$03BF] := $03;
  FillChar (mem [GrafBase:0000], $7FFF, 0);
End;





Procedure HGCtextmode;

{ Schaltet die Hercules-Karte zurÅck in den Textmodus }

Var Register : Record
                 ax, bx, cx, dx, bp,
                 di, si, ds, es, flags : Integer;
               End;
Begin
  With register do Begin
                     ax := 7;
                     intr ($10, Register);
                   End;
End;





Procedure Bild_laden (Filename : Strg40);

Const Bildgroesse = 256;

Var Zeiger_Byte : ^Byte;
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
  If ParamCount = 1
    then SourceName := ParamStr (1)
    else Begin
           ClrScr;
           Write ('Geben Sie den Namen des Bildes ein: ');
           Readln (SourceName);
         End;
  ClrScr;
  HGCgrafmode;
  Bild_laden (SourceName);
  Repeat Until keypressed;
  Read (KBD, Taste);  { Puffer leeren }
  HGCtextmode;
End.
