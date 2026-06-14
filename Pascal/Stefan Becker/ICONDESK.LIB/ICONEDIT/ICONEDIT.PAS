{$s50}

{ IconEdit von Dirk Sabiwalsky 5/89 fr Pascal+ 2.02    }
{ Assembler-Stuff : Stefan Becker                       }
{ Link: Movelib,Icondraw,Mousebut,Stadpac               }

Program IconEdit;

Const {$I GEMCONST.PAS}

Type {$I GEMTYPE.PAS}

     Icon           = Packed Array [1..32,1..32] of Boolean;
     Icon_Zeile     = Packed Array [1..32] of Boolean;
     Menu_Set       = Set of 26..70;
     Cstring        = Packed Array [0..255] of Char;

Var M_Handle        : Menu_Ptr;
   { Menuindizes }
    Info,
    D_Neu,          D_Oeffnen,
    D_Schliessen,   Unused1,
    D_Sichern,      D_Sichern_als,
    Unused2,        D_Ende,
    I_Neu,          I_Oeffnen,
    Unused3,        I_Sichern,
    I_Sichern_als,  E_Loeschen,
    E_Invertieren,  E_Fuellen,
    E_Spiegeln,     S_Offset,
    S_Suchen,       K_Icon_Datei,
    K_Datei_Icon,   So_Maske,
    So_And,         So_Or,
    So_Xor,         Unused4,
    Bi_Laden,       Bi_Grab,
   { Get_Event-Parameter }
    W_Handle,       Event,
    d,              Maus_x,
    Maus_y,         Taste,
    bcnt,           bstate,
   { Menutitel }
    MDatei,         MIcon,
    MEdit,          MSuchen,
    MKopie,         MSonst,
    MBild,
   { Dateiabh„ngige Variablen }
    Offset_Pos,Box_Width    : Integer;
   { Puffer ... }
    Screen,
    Screen_Buffer,
    Icon_Buffer,
    Datei_Buffer,
    Picture_Buffer,
    IBuffer,
   { Pufferl„ngen, etc. ... }
    Buffer_Laenge,
    Datei_Laenge,
    Offset,
   { Line-A Pattern }
    Line_Pattern,
    Move_Pattern,
    Erase_Pattern   : Long_Integer;
    Msg             : Message_Buffer;
   { Flags }
    Quit,Erase,
    Changes,No_Draw : Boolean;
    Akt_Icon        : Icon;
   { Gesperrte Menueintr„ge }
    M_Gesperrt      : Menu_Set;
   { Dateinamen }
    Icon_Name,
    Just_I_Name,
    Datei_Name,Pfad,
    Just_D_Name     : String;

{$I GEMSUBS.PAS}
{$I MOVESUBS.PAS}
{$I TOSEXT.PAS}

Procedure Drawbuf(Screen,Buffer : Long_Integer);
External;

Procedure InitMaus;
External;

Function Buttons : Integer;
External;

Function Getstad(Buffer : Long_Integer) : Integer;
External;

Procedure Eintrag_Check;
Var i : Integer;
Begin
 For i:=D_Neu to Bi_Grab do
  If i in M_Gesperrt Then Menu_Disable(M_Handle,i)
                     Else Menu_Enable(M_Handle,i)
End;

Procedure Menu_Minus(Abzugsmenge : Menu_Set);
Begin
 M_Gesperrt:=M_Gesperrt+Abzugsmenge;
 Eintrag_Check
End;

Procedure Menu_Plus(Zuzaehlmenge : Menu_Set);
Begin
 M_Gesperrt:=M_Gesperrt-Zuzaehlmenge;
 Eintrag_Check
End;

Procedure Bee;
Begin
 Set_Mouse(M_Bee);
 Show_Mouse
End;

Procedure No_Bee;
Begin
 Hide_Mouse;
 Set_Mouse(M_Arrow)
End;

Procedure Init_Menu;
Begin
 M_Handle:=New_Menu(40,' IconEdit ');
 Info:=13;
 MDatei:=Add_MTitle(M_Handle,' Datei ');
 MIcon:=Add_MTitle(M_Handle,' Icon ');
 MEdit:=Add_MTitle(M_Handle,' Editieren ');
 MSuchen:=Add_MTitle(M_Handle,' Suchen ');
 MKopie:=Add_MTitle(M_Handle,' Kopieren ');
 MSonst:=Add_MTitle(M_Handle,' Sonstiges ');
 MBild:=Add_MTitle(M_Handle,' Bild ');
 D_Neu         :=Add_MItem(M_Handle,MDatei,  ' Neu             ');
 D_Oeffnen     :=Add_MItem(M_Handle,MDatei,  ' ™ffnen ...      ');
 D_Schliessen  :=Add_MItem(M_Handle,MDatei,  ' Schliežen       ');
 Unused1       :=Add_MItem(M_Handle,MDatei,  '-----------------');
 D_Sichern     :=Add_MItem(M_Handle,MDatei,  ' Sichern         ');
 D_Sichern_als :=Add_MItem(M_Handle,MDatei,  ' Sichern als ... ');
 Unused2       :=Add_MItem(M_Handle,MDatei,  '-----------------');
 D_Ende        :=Add_MItem(M_Handle,MDatei,  ' Ende            ');
 I_Neu         :=Add_MItem(M_Handle,MIcon,   ' Neu             ');
 I_Oeffnen     :=Add_MItem(M_Handle,MIcon,   ' ™ffnen ...      ');
 Unused3       :=Add_MItem(M_Handle,MIcon,   '-----------------');
 I_Sichern     :=Add_MItem(M_Handle,MIcon,   ' Sichern         ');
 I_Sichern_als :=Add_MItem(M_Handle,MIcon,   ' Sichern als ... ');
 E_Loeschen    :=Add_MItem(M_Handle,MEdit,   ' L”schen      ');
 E_Invertieren :=Add_MItem(M_Handle,MEdit,   ' Invertieren  ');
 E_Fuellen     :=Add_MItem(M_Handle,MEdit,   ' Fllen ...   ');
 E_Spiegeln    :=Add_MItem(M_Handle,MEdit,   ' Spiegeln ... ');
 S_Offset      :=Add_MItem(M_Handle,MSuchen, ' Setze Offset ... ');
 S_Suchen      :=Add_MItem(M_Handle,MSuchen, ' Icon suchen      ');
 K_Icon_Datei  :=Add_MItem(M_Handle,MKopie,  ' Icon -> Datei ');
 Unused4       :=Add_MItem(M_Handle,MKopie,  '---------------');
 K_Datei_Icon  :=Add_MItem(M_Handle,MKopie,  ' Datei -> Icon ');
 So_Maske      :=Add_MItem(M_Handle,MSonst,  ' Maske erzeugen      ');
 So_And        :=Add_MItem(M_Handle,MSonst,  ' Icon AND=Datei      ');
 So_Or         :=Add_MItem(M_Handle,MSonst,  ' Icon OR=Datei       ');
 So_Xor        :=Add_MItem(M_Handle,MSonst,  ' Icon XOR=Datei      ');
 Bi_Laden      :=Add_MItem(M_Handle,MBild,   ' Bild laden  ');
 Bi_Grab       :=Add_MItem(M_Handle,MBild,   ' Icon klauen ');
 Menu_Minus([D_Schliessen..Unused2,Unused3,S_Offset..K_Datei_Icon,So_And..So_Xor]);
 Menu_Plus([D_Neu,D_Oeffnen,D_Ende..I_Oeffnen,I_Sichern..E_Spiegeln,So_Maske,Bi_Laden,Bi_Grab])
End;

Procedure Rect (x,y,b,h : Integer);
Begin
 Set_Clipping(False,0,0,0,0);
 HLine(x,y,x+b,1,1,1,1,0,Line_Pattern,1);
 HLine(x,y,x+b,1,1,1,1,0,Line_Pattern,1);
 HLine(x,y+h,x+b,1,1,1,1,0,Line_Pattern,1);
 LINE(x,y,x,y+h,1,1,1,1,Line_Pattern,1);
 LINE(x+b,y,x+b,y+h,1,1,1,1,Line_Pattern,1)
End;

Procedure Fill_Rect(x,y,b,h : Integer);
Begin
 Set_Clipping(False,0,0,0,0);
 Fill_Rectangle(x,y,x+b,y+h,1,1,1,1,0,Erase_Pattern,1)
End;

Procedure Box(x,y,b,h : Integer);
Begin
 Fill_Rect(x,y,b,h);
 Rect(x,y,b,h)
End;

Procedure TBox(x,y,b,h : Integer);
Begin
 Box(x,y,b,h);
 Rect(x-1,y-1,b+2,h+2)
End;

Procedure Pause;
Var l : Long_Integer;
Begin
 For l:=1 to 500 do
End;

Procedure GrowFrame (x,y,b,h : Integer);
Var l : Long_Integer;
Begin
 l:=-1;
 HLine(x,y,x+b,1,1,1,1,0,l,1);
 HLine(x,y+h,x+b,1,1,1,1,0,l,1);
 Line(x,y,x,y+h,1,1,1,1,-1,0);
 Line(x+b,y,x+b,y+h,1,1,1,1,-1,0);
 Pause
End;

Procedure EraseGrowFrame (x,y,b,h : Integer);
Var l : Long_Integer;
Begin
 l:=0;
 HLine(x,y,x+b,1,1,1,1,0,l,1);
 HLine(x,y+h,x+b,1,1,1,1,0,l,1);
 Line(x,y,x,y+h,1,1,1,1,0,0);
 Line(x+b,y,x+b,y+h,1,1,1,1,0,0);
 Pause
End;

Procedure Grow_Box (x,y,b,h : Integer);
Var i,j,k : Integer;
Begin
 x:=x*8;
 b:=b*8;
 y:=y*16;
 h:=h*16;
 Set_Clipping(False,0,0,0,0);
 j:=b div 20;
 k:=h div 20;
 For i:=1 to 10 do
  GrowFrame(x+(b Div 2)-j*i,y+(h Div 2)-k*i,2*i*j,2*i*k);
 For i:=1 to 10 do
  EraseGrowFrame(x+(b Div 2)-j*i,y+(h Div 2)-k*i,2*i*j,2*i*k)
End;

Procedure Show_Icon;
Var i : Integer;
Begin
 For i:=1 to 32 do
  Movebytes(Icon_Buffer+(i-1)*4,Screen+4880+38+i*80,4)
End;

Procedure Show_Datei_Icon;
Var i     : Integer;
    L1,L2 : Long_Integer;
Begin
 For i:=1 to 32 do
  Movebytes(Datei_Buffer+Offset+(i-1)*4,Screen+22880+2+i*80,4);
 If Datei_Laenge=256
  Then For i:=1 to 32 do
       Begin
        L1:=LPeek(Datei_Buffer+(i-1)*4);
        L2:=LPeek(Datei_Buffer+128+(i-1)*4);
        LPoke(Screen+22880+8+i*80,~L1 & L2)
       End
End;

Procedure Paint_Icon;
Begin
 Show_Icon;
 Drawbuf(Screen,Icon_Buffer)
End;

Procedure Put_String (x,y : Integer; s : String);
Var i : Integer;
Begin
  Set_Clipping(False,0,0,0,0);
  For i:=1 to Length(s) do
    Put_Char(s[i],x+(i-1)*8,y-12,2,0,0)
End;

Procedure Small_String (x,y : Integer; s : String);
Var i : Integer;
Begin
  Set_Clipping(False,0,0,0,0);
  For i:=1 to Length(s) do
    Put_Char(s[i],x+(i-1)*8,y-12,1,0,0)
End;

Procedure Print(x,y : Integer; s : String);
Begin
 While Length(s)<30 do s:=concat(s,' ');
 Put_String(x,y,s)
End;

Procedure Print_Long(x,y : Integer; l : Long_Integer);
Var dummy : String;
Begin
 Writev(dummy,l);
 While Length(dummy)<8 do dummy:=concat(dummy,' ');
 Put_String(x,y,dummy)
End;

Procedure Restauriere;
Var i,k : Integer;
Begin
 Set_Clipping(False,0,0,0,0);
 Paint_Style(5);
 Paint_Color(1);
 Paint_Rect(0,18,640,382);
 Box(297,55,45,45);           { Icon              }
 Box(360,30,268,298);         { Zoom              }
 TBox(480,35,20,20);          { Scrollboxen ...   }
 TBox(510,35,20,20);
 TBox(540,35,20,20);
 TBox(570,35,20,20);
 TBox(290,240,60,30);         { Erase             }
 TBox(10,120,340,30);         { Iconname          }
 TBox(10,160,340,30);         { Dateiname         }
 Box(10,200,150,30);          { L„nge             }
 TBox(200,200,150,30);        { Offset            }
 Box(9,280,45,45);            { DateiIcon         }
 Box(57,280,45,45);           { MaskenIcon        }
 Box(10,340,620,50);          { Dateiposition     }
 TBox(15,350,30,30);          { 1 links           }
 TBox(50,350,45,30);          { 32 links          }
 TBox(545,350,45,30);         { 32 rechts         }
 TBox(595,350,30,30);         { 1 Rechts          }
 Rect(302,60,35,35);    { Iconrahmen ...    }
 Rect(301,59,37,37);
 Rect(14,285,35,35);    { Dateifenster      }
 Rect(13,284,37,37);
 Rect(62,285,35,35);    { Maskenfenster     }
 Rect(61,284,37,37);
 Rect(366,60,257,257);  { Zoomrahmen ...    }
 Rect(365,59,259,259);
 Rect(100,350,440,30);  { Dateirahmen       }
 For i:=1 to 31 do            { Raster            }
  For k:=1 to 31 do
   Put_Pixel(366+i*8,60+k*8,1);
 For i:=1 to 7 do
 Begin
  HLine(366,60+i*32,623,1,1,1,1,0,Line_Pattern,1);
  LINE(366+i*32,60,366+i*32,317,1,1,1,1,Line_Pattern,1)
 End;
 Put_Char(Chr(1),486,37,2);
 Put_Char(Chr(2),516,37,2);
 Put_Char(Chr(4),546,37,2);
 Put_Char(Chr(3),576,37,2);
 Put_String(372,45,'Zoom:');
 Put_String(18,140,'Icon :');
 Put_String(18,180,'Datei:');
 Put_String(18,220,'L„nge:');
 Put_String(208,220,'Offset:');
 Put_String(75,140,Just_I_Name);
 Put_String(75,180,Just_D_Name);
 Print_Long(75,220,Datei_Laenge);
 Print_Long(272,220,Offset);
 Put_String(20,370,'<');
 Put_String(55,370,'<<');
 Put_String(569,370,'>>');
 Put_String(612,370,'>');
 If Erase
  Then Put_String(298,260,'Erase')
  Else Put_String(298,260,'Draw ');
 Paint_Icon;
 Show_Datei_Icon
End;

Procedure Clear_Icon;
Var i,k : Integer;
Begin
 For i:=1 to 32 do
  For k:=1 to 32 do
   Akt_Icon[i,k]:=False
End;

Function Quadrant(x : Integer) : Integer;
Begin
 If x<=8
  Then Quadrant:=1
  Else If x<=16
        Then Quadrant:=2
        Else If x<=24
              Then Quadrant:=3
              Else Quadrant:=4
End;

Procedure Set_Buffer_Pixel(x,y : Integer; v : Boolean);
Var i : Byte;
Begin
 i:=Shr(128,x-1-(Quadrant(x)-1)*8);
 If v
  Then Poke(Icon_Buffer+(y-1)*4+Quadrant(x)-1,
         Peek(Icon_Buffer+(y-1)*4+Quadrant(x)-1) | i)

  Else Poke(Icon_Buffer+(y-1)*4+Quadrant(x)-1,
         Peek(Icon_Buffer+(y-1)*4+Quadrant(x)-1) & ~i)
End;

Function Get_Buffer_Pixel(x,y : Integer) : Boolean;
Var i : Byte;
Begin
 i:=Shr(128,x-1-(Quadrant(x)-1)*8);
 Get_Buffer_Pixel:=(Peek(Icon_Buffer+(y-1)*4+Quadrant(x)-1) & i)<>0
End;

Procedure Copy_To_Buffer;
Var x,y : Integer;
Begin
 For y:=1 to 32 do
  For x:=1 to 32 do
   Set_Buffer_Pixel(x,y,Akt_Icon[x,y])
End;

Procedure Copy_To_Icon;
Var x,y : Integer;
Begin
 For y:=1 to 32 do
  For x:=1 to 32 do
   Akt_Icon[x,y]:=Get_Buffer_Pixel(x,y);
End;

Procedure Save_Screen;
Begin
 Movelongs(Screen,Screen_Buffer,8000)
End;

Procedure Show_Screen;
Begin
 Movelongs(Screen_Buffer,Screen,8000)
End;

Procedure Nachricht(Meldung,Weiter : String);
Var Message_Dialog  : Dialog_Ptr;
    Zeile,Dialog,Ok : Tree_Index;
    Breite          : Integer;

 Function Max(a,b : Integer) : Integer;
 Begin
  If a>b Then Max:=a
         Else Max:=b
 End;

Begin
 No_Draw:=True;
 Breite:=Max(Length(Meldung),Length(Weiter));
 Message_Dialog:=New_Dialog(3,(74-Breite) Div 2,9,Breite+6,7);
 Zeile:=Add_Ditem(Message_Dialog,G_Text,None,2,1,Breite,1,0,Black*256);
 Set_Dtext(Message_Dialog,Zeile,Meldung,System_Font,Te_Left);
 Ok:=Add_Ditem(Message_Dialog,G_Button,
               Selectable | Default | Exit_Btn | Radio_Btn | Touch_Exit,
               2,3,Breite+2,3,-2,Black*256 | Black*4096);
 Set_Dtext(Message_Dialog,Ok,Weiter,System_Font,Te_Center);
 Save_Screen;
 Grow_Box((74-Breite) Div 2,9,Breite+6,7);
 Show_Mouse;
 Dialog:=Do_Dialog(Message_Dialog,Null_Index);
 Hide_Mouse;
 End_Dialog(Message_Dialog);
 Delete_Dialog(Message_Dialog);
 Show_Screen;
End;

Function Auswahl(Meldung     : String;
                 Wahl1,Deflt : String) : Integer;
Var Message_Dialog  : Dialog_Ptr;
    Me_Zeile,
    De_Zeile,
    w1_Zeile,
    Dialog,Ok       : Tree_Index;
Begin
 No_Draw:=True;
 Message_Dialog:=New_Dialog(3,14,9,51,7);
 Me_Zeile:=Add_Ditem(Message_Dialog,G_Text,None,2,1,40,1,0,Black*256);
 Set_Dtext(Message_Dialog,Me_Zeile,Meldung,System_Font,Te_Left);
 w1_Zeile:=Add_Ditem(Message_Dialog,G_Button,
                     Selectable | Exit_Btn | Radio_Btn | Touch_Exit,
                     2,3,15,3,-2,Black*256 | Black*4096);
 De_Zeile:=Add_Ditem(Message_Dialog,G_Button,
                     Selectable | Default | Exit_Btn | Radio_Btn | Touch_Exit,
                     34,3,15,3,-2,Black*256 | Black*4096);
 Set_Dtext(Message_Dialog,w1_Zeile,Wahl1,System_Font,Te_Center);
 Set_Dtext(Message_Dialog,De_Zeile,Deflt,System_Font,Te_Center);
 Save_Screen;
 Grow_Box(14,9,51,7);
 Show_Mouse;
 Dialog:=Do_Dialog(Message_Dialog,Null_Index);
 Hide_Mouse;
 End_Dialog(Message_Dialog);
 Delete_Dialog(Message_Dialog);
 Show_Screen;
 If Dialog=De_Zeile Then Auswahl:=2
                    Else Auswahl:=1
End;

Procedure Make_C_String(    Pascal_String : String;
                        Var C_String      : Cstring);
Var i : Integer;
Begin
 For i:=1 to Length(Pascal_String) do C_String[i-1]:=Pascal_String[i];
 C_String[Length(Pascal_String)]:=#0
End;

Function Lies_Datei(    Anzahl,
                        Adresse : Long_Integer;
                    Var Name    : String) : Long_Integer;
Var Laenge,
    F_Laenge,
    dta_buffer,
    ldummy     : Long_Integer;
    F_Handle,
    Dummy      : Integer;
    C_Dummy    : Cstring;
    In_File    : Boolean;
Begin
 Laenge:=-1;
 Save_Screen;
 Show_Mouse;
 If Length(Name)=0 Then Name:='Unbenannt';
 In_File:=Get_In_File(Pfad,Name);
 No_Draw:=True;
 Hide_Mouse;
 Show_Screen;
 If In_File And (Length(Name)>0)
  Then Begin
        dta_buffer:=Fgetdta;
        Make_C_String(Name,C_Dummy);
        ldummy:=Fsfirst(C_Dummy,0);
        Laenge:=LPeek(dta_buffer+26);
        If Laenge>Anzahl
         Then Begin
               Nachricht('Die Datei ist zu grož !','Abbruch');
               Laenge:=-1
              End
         Else Begin
               F_Handle:=Fopen(C_Dummy,0);
               If F_Handle<0
                Then Nachricht('Die Datei existiert nicht !','Abbruch')
                Else Begin
                      Bee;
                      Laenge:=Fread(F_Handle,Anzahl,Adresse);
                      No_Bee;
                      If Laenge<=0
                       Then Nachricht('Die Datei kann nicht richtig gelesen werden !','Abbruch')
                       Else Begin
                             Fclose(F_Handle);
                             If Laenge>Anzahl
                              Then Begin
                                    Nachricht('Die Datei pažt nicht in den Speicher !','Pech');
                                    Laenge:=-1
                                   End
                            End
                     End
              End
       End;
 Lies_Datei:=Laenge
End;

Procedure Last_Part(s : String; Var t : String);
Var i : Integer;
Begin
 i:=Length(s);
 While((i>0) And (s[i]<>'\')) do i:=i-1;
 if i>0
  Then t:=Copy(s,i+1,Length(s)-i)
  Else t:=s
End;

Procedure Lade_Icon;
Begin
 If Lies_Datei(128,Icon_Buffer,Icon_Name)<>128
  Then Begin
        Icon_Name:='';
        Just_I_Name:='Unbenannt';
        Clear_Icon
       End
  Else Last_Part(Icon_Name,Just_I_Name);
 Print(75,140,Just_I_Name)
End;

Procedure Datei_Leiste;
Begin
 If Datei_Laenge>0
  Then Begin
        Offset_Pos:=Round((438*Offset)/Datei_Laenge);
        If Offset_Pos=0 Then Offset_Pos:=1;
        Box_Width:=Round(436/(Datei_Laenge/128));
        If Box_Width<5 Then Box_Width:=5;
        If Offset_Pos+Box_Width>438 Then Offset_Pos:=438-Box_Width;
        Paint_Style(1);
        Paint_Color(0);
        Vsync;
        Paint_Rect(101+Offset_Pos,351,Box_Width,29);
        Paint_Style(3);
        Paint_Color(1);
        Paint_Rect(101,351,Offset_Pos,29);
        Paint_Rect(101+Offset_Pos+Box_Width,351,440-(Offset_Pos+Box_Width),29);
        Line_Style(1);
        Line_Color(1);
        Vsync;
        Frame_Rect(101+Offset_Pos,351,Box_Width,29);
        Print_Long(272,220,Offset);
        Show_Datei_Icon
       End
  Else Begin
        Fill_Rect(101,351,438,28)
       End
End;

Procedure Lade_Datei;
Begin
 Box(57,280,45,45);
 Rect(62,285,35,35);
 Rect(61,284,37,37);
 If Datei_Laenge=0
  Then Begin
        Datei_Laenge:=Lies_Datei(Buffer_Laenge,Datei_Buffer,Datei_Name);
        If Datei_Laenge<128
         Then Begin
               If Datei_Laenge>0 Then Nachricht('Datei enth„lt keine Icons !','Abbruch');
               Datei_Laenge:=0;
               Datei_Name:='';
               Just_D_Name:='Unbenannt'
              End
         Else Begin
               Offset:=0;
               Changes:=False;
               Last_Part(Datei_Name,Just_D_Name);
               Menu_Minus([D_Neu,D_Oeffnen]);
               Menu_Plus([D_Schliessen,D_Sichern,D_Sichern_als,S_Offset..K_Icon_Datei,K_Datei_Icon,So_And..So_Xor]);
               Datei_Leiste
              End
       End
  Else Nachricht('Erst die alte Datei schliežen !','Abbruch');
 Print(75,180,Just_D_Name);
 Print_Long(75,220,Datei_Laenge)
End;

Function Lies_String(    A_Str,Vorgabe : String;
                         E_Breite      : Integer;
                     Var E_Str         : Str255) : Boolean;
Var Nice_Dialog       : Dialog_Ptr;
    Ausgabe,Eingabe,
    Abbruch,Ok,Dialog : Tree_Index;
    A_Breite,i        : Integer;
    E_Us,E_Chars      : String;

Begin
 No_Draw:=True;
 Nice_Dialog:=New_Dialog(8,20,7,40,10);
 A_Breite:=Length(A_Str);
 E_Us:='______________________________________________________';
 E_Us[0]:=Chr(E_Breite);
 E_Chars:='XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
 E_Us[0]:=Chr(E_Breite);
 Ausgabe:=Add_Ditem(Nice_Dialog,G_Text,None,4,1,A_Breite,1,0,Black*256);
 Eingabe:=Add_Ditem(Nice_Dialog,G_Fboxtext,Editable,4,3,E_Breite,1,0,Black*256);
 Abbruch:=Add_Ditem(Nice_Dialog,G_Button,Selectable | Exit_Btn | Radio_Btn | Touch_Exit,4,6,13,3,-2,Black*256 | Black*4096);
 Ok:=Add_Ditem(Nice_Dialog,G_Button,Selectable | Default | Exit_Btn | Radio_Btn | Touch_Exit,23,6,13,3,-2,Black*256 | Black*4096);
 Set_Dtext(Nice_Dialog,Ausgabe,A_Str,System_Font,Te_Left);
 Set_Dedit(Nice_Dialog,Eingabe,E_Us,E_Chars,Vorgabe,System_Font,Te_Center);
 Set_Dtext(Nice_Dialog,Abbruch,' Abbruch ',System_Font,Te_Center);
 Set_Dtext(Nice_Dialog,Ok,' OK ',System_Font,Te_Center);
 Save_Screen;
 Grow_Box(20,7,40,10);
 Show_Mouse;
 Dialog:=Do_Dialog(Nice_Dialog,Eingabe);
 Hide_Mouse;
 Get_Dedit(Nice_Dialog,Eingabe,E_Str);
 End_Dialog(Nice_Dialog);
 Delete_Dialog(Nice_Dialog);
 Show_Screen;
 Lies_String:=(Dialog=4) And (Length(E_Str)>0)
End;

Function Upcase(Ch : Char) : Char;
Begin
 If Ch in ['a'..'z'] Then Upcase:=Chr(Ord(Ch)-32)
                     Else Upcase:=Ch
End;

Function Hex_String(Str : Str255) : Boolean;
Var i : Integer;
    b : Boolean;
Begin
 b:=True;
 For i:=1 to Length(Str) do
  If Not (Upcase(Str[i]) in ['0'..'9','A'..'F'])
   Then b:=False;
 Hex_String:=b
End;

Function Hex_To_Long(Str : String) : Long_Integer;
Var i,l    : Integer;
    Summe  : Long_Integer;
    Pot_16 : Array[0..7] of Long_Integer;

 Function Char_Hex_Value(Ch : Char) : Integer;
 Begin
  Ch:=Upcase(Ch);
  If (Ch in ['0'..'9']) Then Char_Hex_Value:=Ord(Ch)-48
                        Else Char_Hex_Value:=Ord(Ch)-55
 End;

Begin
 Summe:=0;
 Pot_16[0]:=1; Pot_16[1]:=16; Pot_16[2]:=256; Pot_16[3]:=4096;
 Pot_16[4]:=65536; Pot_16[5]:=1048575;
 Pot_16[6]:=0; Pot_16[7]:=0;
 l:=Length(Str);
 For i:=0 to l-1 do
  Summe:=Summe+Char_Hex_Value(Str[l-i])*Pot_16[i];
 Hex_To_Long:=Summe
End;

Function Integer_String(Str : Str255) : Boolean;
Var i : Integer;
    b : Boolean;
Begin
 b:=True;
 For i:=1 to Length(Str) do If Not (Str[i] in ['0'..'9']) Then b:=False;
 Integer_String:=b
End;

Function String_Long_Wert(Int_String : String) : Long_Integer;
Var l : Long_Integer;
Begin
 l:=0;
 If Integer_String(Int_String)
    And (Length(Int_String)>0)
    And (Length(Int_String)<7)
   Then Readv(Int_String,l);
 String_Long_Wert:=l
End;

Function String_To_Long(s : String) : Long_Integer;
Var Dummy : String[8];
    N_Var : Long_Integer;
Begin
 N_Var:=-1;
 If Length(s)>0
  Then If s[1]='$'
        Then Begin
              Delete(s,1,1);
              If Hex_String(s)
               Then Begin
                     Dummy:=s;
                     N_Var:=Hex_To_Long(Dummy)
                    End
             End
        Else If Integer_String(s) Then N_Var:=String_Long_Wert(s);
 String_To_Long:=N_Var
End;

Procedure Setze_Offset;
Var s     : String[255];
    Value : Long_Integer;
Begin
 If Lies_String('Neuer Offset ?','$',8,s)
  Then Begin
        Value:=String_To_Long(s);
        If (Value>=0) And (Value+32<=Datei_Laenge)
         Then Begin
               Offset:=Value;
               Datei_Leiste
              End
         Else Nachricht('Falscher Wert !','Abbruch')
       End
End;

Function Maus (Var x,y : Integer) : Integer;
Type Pointer  = ^Char;
     Int_In_Params   = Array [0..15] of Integer;
     Int_Out_Params  = Array [0..45] of Integer;
     Addr_In_Params  = Array [0..1] of Pointer;
     Addr_Out_Params = Array [0..0] of Pointer;
Var IntIn   : Int_In_Params;
    IntOut  : Int_Out_Params;
    AddrIn  : Addr_In_Params;
    AddrOut : Addr_Out_Params;
Begin
 Aes_Call(79,IntIn,IntOut,AddrIn,AddrOut);
 x:=IntOut[1];
 y:=IntOut[2];
 Maus:=Buttons
End;

Function In_Box(Xko,Yko,x,y,b,h : Integer) : Boolean;
Begin
 In_Box:=(Xko>=x) And (Xko<=x+b) And (Yko>=y) And (Yko<=y+h)
End;

Procedure Pixel_Edit;
Var x,y : Integer;
Begin
 x:=((Maus_x-368) Div 8)+1;
 If x=0 Then x:=1;
 y:=((Maus_y-62) Div 8)+1;
 If y=0 Then y:=1;
 If (bcnt>0) And (Buttons<>0)
  Then Akt_Icon[x,y]:=Not Erase
  Else Akt_Icon[x,y]:=Not Akt_Icon[x,y];
 Set_Clipping(False,0,0,0,0);
 If Akt_Icon[x,y]
  Then Begin
        Fill_Rectangle(368+(x-1)*8,62+(y-1)*8,368+(x-1)*8+4,62+(y-1)*8+4,1,1,1,1,0,Line_Pattern,1);
        Put_Pixel(303+x,61+y,1)
       End
  Else Begin
        Fill_Rectangle(368+(x-1)*8,62+(y-1)*8,368+(x-1)*8+4,62+(y-1)*8+4,1,1,1,1,0,Erase_Pattern,1);
        Put_Pixel(303+x,61+y,0)
       End;
 Set_Buffer_Pixel(x,y,Akt_Icon[x,y])
End;

Procedure Scroll_Hoch;
Begin
 Movelongs(Icon_Buffer+4,Icon_Buffer,31);
 Fillbytes(Icon_Buffer+124,4,0);
 Copy_To_Icon;
 Paint_Icon
End;

Procedure Scroll_Runter;
Var i : Integer;
Begin
 For i:=31 downto 1 do
  Movelongs(Icon_Buffer+(i-1)*4,Icon_Buffer+i*4,1);
 Fillbytes(Icon_Buffer,4,0);
 Copy_To_Icon;
 Paint_Icon
End;

Procedure Scroll_Rechts;
Var i : Integer;
Begin
 For i:=0 to 31 do
  LPoke(Icon_Buffer+i*4,Shr(LPeek(Icon_Buffer+i*4),1));
 Copy_To_Icon;
 Paint_Icon
End;

Procedure Scroll_Links;
Var i : Integer;
Begin
 For i:=0 to 31 do
  LPoke(Icon_Buffer+i*4,Shl(LPeek(Icon_Buffer+i*4),1));
 Copy_To_Icon;
 Paint_Icon
End;

Procedure Handle_Mouse;
Begin
 If In_Box(Maus_x,Maus_y,10,120,340,30)
  Then Begin
        Lade_Icon;
        Copy_To_Icon;
        Paint_Icon
       End
 Else If In_Box(Maus_x,Maus_y,10,160,340,30)
        Then Lade_Datei
 Else If In_Box(Maus_x,Maus_y,200,200,150,30)
       Then If Datei_Laenge>0
             Then Setze_Offset
             Else Nachricht('Erst Datei laden !','Abbruch')
 Else If In_Box(Maus_x,Maus_y,15,350,30,30)
       Then If Datei_Laenge>0
             Then If Offset>=1
                   Then Begin
                         Offset:=Offset-1;
                         Datei_Leiste
                        End
                   Else Write(Chr(7))
             Else Nachricht('Erst Datei laden !','Abbruch')
 Else If In_Box(Maus_x,Maus_y,50,350,45,30)
       Then If Datei_Laenge>0
             Then If Offset>=32
                   Then Begin
                         Offset:=Offset-32;
                         Datei_Leiste
                        End
                   Else Write(Chr(7))
             Else Nachricht('Erst Datei laden !','Abbruch')
 Else If In_Box(Maus_x,Maus_y,545,350,45,30)
       Then If Datei_Laenge>0
             Then If Offset+32+128<=Datei_Laenge
                   Then Begin
                         Offset:=Offset+32;
                         Datei_Leiste
                        End
                   Else Write(Chr(7))
             Else Nachricht('Erst Datei laden !','Abbruch')
 Else If In_Box(Maus_x,Maus_y,595,350,30,30)
       Then If Datei_Laenge>0
             Then If Offset+1+128<=Datei_Laenge
                   Then Begin
                         Offset:=Offset+1;
                         Datei_Leiste
                        End
                   Else Write(Chr(7))
             Else Nachricht('Erst Datei laden !','Abbruch')
 Else If In_Box(Maus_x,Maus_y,101,350,Offset_Pos-1,30)
       Then If Datei_Laenge>0
             Then If Offset>=128
                   Then Begin
                         Offset:=Offset-128;
                         Datei_Leiste;
                        End
                   Else Write(Chr(7))
             Else Nachricht('Erst Datei laden !','Abbruch')
 Else If In_Box(Maus_x,Maus_y,101+Offset_Pos+Box_Width,350,438-(Offset_Pos+Box_Width),30)
       Then If Datei_Laenge>0
             Then If Offset+256<=Datei_Laenge
                   Then Begin
                         Offset:=Offset+128;
                         Datei_Leiste;
                        End
                   Else Write(Chr(7))
             Else Nachricht('Erst Datei laden !','Abbruch')
 Else If In_Box(Maus_x,Maus_y,101+Offset_Pos,350,Box_Width,30)
       Then If Datei_Laenge>0
             Then Repeat
                   Offset_Pos:=Maus_x-101;
                   If Offset_Pos+Box_Width>438 Then Offset_Pos:=438-Box_Width;
                   If Offset_Pos<=0 Then Offset_Pos:=1;
                   Offset:=((Datei_Laenge*Offset_Pos) Div 438)-1;
                   If Offset<0 Then Offset:=0;
                   Datei_Leiste
                  Until Maus(Maus_x,Maus_y)=0
             Else Nachricht('Erst Datei laden !','Abbruch')
 Else If In_Box(Maus_x,Maus_y,290,240,60,30)
       Then Begin
             Erase:=Not Erase;
             If Erase
              Then Put_String(298,260,'Erase')
              Else Put_String(298,260,'Draw ')
            End
 Else If In_Box(Maus_x,Maus_y,480,35,20,20)
       Then Scroll_Hoch
 Else If In_Box(Maus_x,Maus_y,510,35,20,20)
       Then Scroll_Runter
 Else If In_Box(Maus_x,Maus_y,540,35,20,20)
       Then Scroll_Links
 Else If In_Box(Maus_x,Maus_y,570,35,20,20)
       Then Scroll_Rechts
 Else If In_Box(Maus_x,Maus_y,366,60,257,257)
       Then Pixel_Edit
       Else Write(Chr(7))
End;

Procedure Handle_Keyboard;
Begin
End;

Procedure Invert_Icon;
Var i,k : Integer;
Begin
 For i:=1 to 32 do
  For k:=1 to 32 do
   Akt_Icon[i,k]:=Not Akt_Icon[i,k]
End;

Procedure Schreib_Datei(    Anzahl,
                            Adresse : Long_Integer;
                        Var Name : String);
Var Laenge    : Long_Integer;
    F_Handle  : Integer;
    C_Dummy   : Cstring;
    In_File,
    Writefile : Boolean;
    Pfad      : String[80];
Begin
 Laenge:=-1;
 If Length(Name)>0
  Then Begin
        Make_C_String(Name,C_Dummy);
        Writefile:=True;
        F_Handle:=Fopen(C_Dummy,1);
        If F_Handle>=0
         Then Writefile:=(Auswahl('šberschreiben der alten Datei ?','Ja','Nein')=1);
        If Writefile
         Then Begin
               F_Handle:=Fcreate(C_Dummy,0);
               If F_Handle<0
                Then Nachricht('Die Datei konnte nicht erzeugt werden !','Abbruch')
                Else Begin
                      Bee;
                      Laenge:=Fwrite(F_Handle,Anzahl,Adresse);
                      No_Bee;
                      If Laenge<>Anzahl
                       Then Nachricht('Die Datei konnte nicht richtig geschrieben werden !','Abbruch')
                       Else Fclose(F_Handle)
                     End
              End
       End
End;

Procedure Schreib_Neue_Datei(    Anzahl,
                                 Adresse : Long_Integer;
                             Var Name    : String);
Var Laenge    : Long_Integer;
    F_Handle  : Integer;
    C_Dummy   : Cstring;
    In_File,
    Writefile : Boolean;
Begin
 Laenge:=-1;
 Save_Screen;
 Show_Mouse;
 Name:='Unbenannt';
 In_File:=Get_In_File(Pfad,Name);
 No_Draw:=True;
 Hide_Mouse;
 Show_Screen;
 If In_File And (Length(Name)>0)
  Then Begin
        Make_C_String(Name,C_Dummy);
        Writefile:=True;
        F_Handle:=Fopen(C_Dummy,1);
        If F_Handle>=0
         Then Writefile:=(Auswahl('šberschreiben der alten Datei ?','Ja','Nein')=1);
        If Writefile
         Then Begin
               F_Handle:=Fcreate(C_Dummy,0);
               If F_Handle<0
                Then Nachricht('Die Datei konnte nicht erzeugt werden !','Abbruch')
                Else Begin
                      Bee;
                      Laenge:=Fwrite(F_Handle,Anzahl,Adresse);
                      No_Bee;
                      If Laenge<>Anzahl
                       Then Nachricht('Die Datei konnte nicht richtig geschrieben werden !','Abbruch')
                       Else Fclose(F_Handle)
                     End
              End
       End
End;

Procedure Fuelle;
Var x,y : Integer;

 Procedure Fuelle_Array(x,y : Integer);
 Begin
  If In_Box(x,y,1,1,31,31)
   Then If Not Akt_Icon[x,y]
         Then Begin
               Akt_Icon[x,y]:=True;
               Fuelle_Array(x-1,y);
               Fuelle_Array(x+1,y);
               Fuelle_Array(x,y-1);
               Fuelle_Array(x,y+1)
              End
 End;

Begin
 x:=((Maus_x-368) Div 8)+1;
 If x=0 Then x:=1;
 y:=((Maus_y-62) Div 8)+1;
 If y=0 Then y:=1;
 If Not Akt_Icon[x,y]
  Then Fuelle_Array(x,y)
  Else Write(Chr(7))
End;

Procedure Zeige_Info;
Begin
 Save_Screen;
 Box(150,100,340,200);
 Text_Height(26);
 Draw_String(170,140,'ICONEDIT 1.0');
 Small_String(370,140,'Mai 1989');
 Put_String(170,190,'Pascal-Source   : Dirk Sabiwalsky');
 Put_String(170,210,'Assembler-Stuff : Stefan Becker');
 TBox(160,260,35,30);
 Put_String(170,280,'OK');
 Show_Mouse;
 Repeat
 Until (Maus(Maus_x,Maus_y)<>0) And In_Box(Maus_x,Maus_y,160,250,40,40);
 Hide_Mouse;
 Show_Screen;
End;

Procedure Make_I_String(Var s : Str255);
Var i : Integer;
Begin
 s[0]:=Chr(128);
 For i:=1 to 128 do s[i]:=Chr(Peek(Icon_Buffer+i-1))
End;

Procedure Swap_Boolean(x,y,x1,y1 : Integer);
Var b : Boolean;
Begin
 b:=Akt_Icon[x,y]; Akt_Icon[x,y]:=Akt_Icon[x1,y1]; Akt_Icon[x1,y1]:=b
End;

Procedure Spiegel_Hor;
Var x,y : Integer;
Begin
 For y:=1 to 32 do
  For x:=1 to 16 do
   Swap_Boolean(x,y,33-x,y)
End;

Procedure Spiegel_Vert;
Var x,y : Integer;
Begin
 For x:=1 to 32 do
  For y:=1 to 16 do
   Swap_Boolean(x,y,x,33-y)
End;

Procedure Make_Maske;
Var i : Integer;
Begin
 Movelongs(Icon_Buffer,IBuffer,32);
 For i:=1 to 32 do
  LPoke(Icon_Buffer+(i-1)*4,  LPeek(Icon_Buffer+(i-1)*4)
                            | Shl(LPeek(IBuffer+(i-1)*4),1)
                            | Shr(LPeek(IBuffer+(i-1)*4),1));
 For i:=1 to 31 do
  LPoke(Icon_Buffer+(i-1)*4,  LPeek(Icon_Buffer+(i-1)*4)
                            | LPeek(IBuffer+i*4));
 For i:=2 to 32 do
  LPoke(Icon_Buffer+(i-1)*4,  LPeek(Icon_Buffer+(i-1)*4)
                            | LPeek(IBuffer+(i-2)*4));

 Copy_To_Icon;
 Paint_Icon
End;

Procedure Do_And;
Var i : Integer;
Begin
 For i:=1 to 32 do
  LPoke(Icon_Buffer+(i-1)*4,  LPeek(Datei_Buffer+Offset+(i-1)*4)
                            & LPeek(Icon_Buffer+(i-1)*4));
 Copy_To_Icon;
 Paint_Icon
End;

Procedure Do_Or;
Var i : Integer;
Begin
 For i:=1 to 32 do
  LPoke(Icon_Buffer+(i-1)*4,  LPeek(Datei_Buffer+Offset+(i-1)*4)
                            | LPeek(Icon_Buffer+(i-1)*4));
 Copy_To_Icon;
 Paint_Icon
End;

Procedure Do_Xor;
Var L1,L2 : Long_Integer;
    i     : Integer;
Begin
 For i:=1 to 32 do
 Begin
  L1:=LPeek(Icon_Buffer+(i-1)*4);
  L2:=LPeek(Datei_Buffer+Offset+(i-1)*4);
  LPoke(Icon_Buffer+(i-1)*4,(L1 & ~L2) | (~L1 & L2));
 End;
 Copy_To_Icon;
 Paint_Icon
End;

Procedure S_Adr_Buffer_Pixel(Address : Long_Integer;
                             x,y     : Integer;
                             v       : Boolean);
Var i : Byte;
Begin
 i:=Shr(128,x-1-(Quadrant(x)-1)*8);
 If v
  Then Poke(Address+(y-1)*4+Quadrant(x)-1,
         Peek(Address+(y-1)*4+Quadrant(x)-1) | i)

  Else Poke(Address+(y-1)*4+Quadrant(x)-1,
         Peek(Address+(y-1)*4+Quadrant(x)-1) & ~i)
End;

Function G_Adr_Buffer_Pixel(Address : Long_Integer;
                          x,y     : Integer) : Boolean;
Var i : Byte;
Begin
 i:=Shr(128,x-1-(Quadrant(x)-1)*8);
 G_Adr_Buffer_Pixel:=(Peek(Address+(y-1)*4+Quadrant(x)-1) & i)<>0
End;

Procedure Copy_Icon_To_Address(Var I : Icon; Address : Long_Integer);
Var x,y : Integer;
Begin
 For y:=1 to 32 do
  For x:=1 to 32 do
   S_Adr_Buffer_Pixel(Address,x,y,I[x,y])
End;

Procedure Copy_Address_To_Icon(Address : Long_Integer; Var I : Icon);
Var x,y : Integer;
Begin
 For y:=1 to 32 do
  For x:=1 to 32 do
   I[x,y]:=G_Adr_Buffer_Pixel(Address,x,y);
End;

Procedure Make_Icon_Maske;
Var i,j    : Integer;
    D_Icon : Icon;
Begin
 Copy_Address_To_Icon(Datei_Buffer,D_Icon);
 For i:=1 to 32 do
  For j:=1 to 32 do
   If Akt_Icon[i,j] And D_Icon[i,j]
    Then D_Icon[i,j]:=False
    Else If Akt_Icon[i,j] Then D_Icon[i,j]:=True;
 Copy_Icon_To_Address(D_Icon,Datei_Buffer+128);
 Datei_Leiste;
 Changes:=True
End;

Procedure Flip_Frame(x,y : Integer);
Begin
 Set_Clipping(False,0,0,0,0);
 HLine(x,y,x+31,1,1,1,1,2,Line_Pattern,1);
 HLine(x,y+31,x+31,1,1,1,1,2,Line_Pattern,1);
 LINE(x,y,x,y+31,1,1,1,1,Line_Pattern,2);
 LINE(x+31,y,x+31,y+31,1,1,1,1,Line_Pattern,2)
End;

Procedure Grab_Icon;
Var x,y,lx,ly,But : Integer;
Begin
 Save_Screen;
 Movelongs(Picture_Buffer,Screen,8000);
 If Maus(lx,ly)<>0 Then;
 If lx>608 Then lx:=608;
 If ly>368 Then ly:=368;
 Flip_Frame(lx,ly);
 But:=0;
 While But=0 do
 Begin
  But:=Maus(x,y);
  If x>608 Then x:=608;
  If y>368 Then y:=368;
  If (lx<>x) Or (ly<>y)
   Then Begin
         VSync;
         Flip_Frame(lx,ly);
         Flip_Frame(x,y);
         lx:=x;
         ly:=y
        End
 End;
 Flip_Frame(x,y);
 If But=2
  Then Begin
        For lx:=1 to 32 do
         For ly:=1 to 32 do
          Akt_Icon[lx,ly]:=Get_Pixel(x+lx-1,y+ly-1)=1;
        Copy_To_Buffer
       End;
 Show_Screen;
 Paint_Icon
End;

Function Position(s : String; Ch : Char) : Integer;
Var i     : Integer;
    found : Boolean;
Begin
 If Length(s)=0
  Then i:=0
  Else Begin
        i:=1;
        found:=False;
        Repeat
         If s[i]=Ch Then found:=True;
         If Not found Then i:=i+1
        Until found Or (i>Length(s));
        If Not found Then i:=0
       End;
 Position:=i
End;

Procedure Extension(s : String; Var t : String);
Var i : Integer;
Begin
 i:=Length(s);
 While((i>0) And (s[i]<>'.')) do i:=i-1;
 If i>0
  Then If i<Length(s)
        Then t:=Copy(s,i+1,Length(s)-i)
        Else t:=''
  Else t:=''
End;

Procedure Handle_Menu;
Var I_String   : Str255;
    i          : Integer;
    l,Laenge   : Long_Integer;
    Dummy_Name,
    Picture_Name,
    Ext        : String;
Begin
 Erase_Menu(M_Handle);
 If Msg[4]=Info Then Zeige_Info Else
 If Msg[4]=D_Neu
  Then Begin
        Datei_Laenge:=256;
        Offset:=0;
        Changes:=False;
        Print_Long(75,220,Datei_Laenge);
        Menu_Minus([D_Neu,D_Oeffnen]);
        Menu_Plus([D_Schliessen,D_Sichern,D_Sichern_als,S_Offset..K_Icon_Datei,K_Datei_Icon,So_And..So_Xor]);
        Datei_Leiste
       End
  Else
 If Msg[4]=D_Oeffnen Then Lade_Datei Else
 If Msg[4]=D_Schliessen
  Then Begin
        i:=1;
        If Changes Then i:=Auswahl('Die Datei wurde ver„ndert !','Schliežen','Abbruch');
        If i=1
         Then Begin
               Datei_Laenge:=0;
               Offset:=0;
               Changes:=False;
               Datei_Leiste;
               Datei_Name:='';
               Just_D_Name:='Unbenannt';
               Print(75,180,Just_D_Name);
               Print_Long(75,220,Datei_Laenge);
               Menu_Minus([D_Schliessen..Unused2,Unused3,S_Offset..K_Datei_Icon,So_And..So_Xor]);
               Menu_Plus([D_Neu,D_Oeffnen,D_Ende..I_Oeffnen,I_Sichern..E_Spiegeln,So_Maske])
              End
       End;
 If Msg[4]=D_Sichern
  Then If Datei_Laenge>0
        Then Begin
              Schreib_Datei(Datei_Laenge,Datei_Buffer,Datei_Name);
              Changes:=False
             End
        Else Nachricht('Erst Datei laden !','Abbruch')
  Else
 If Msg[4]=D_Sichern_als
  Then If Datei_Laenge>0
        Then Begin
              Schreib_Neue_Datei(Datei_Laenge,Datei_Buffer,Dummy_Name);
              If (Datei_Name='') And (Dummy_Name<>'')
               Then Begin
                     Datei_Name:=Dummy_Name;
                     Last_Part(Datei_Name,Just_D_Name);
                     Print(75,180,Just_D_Name);
                    End
             End
        Else Nachricht('Erst Datei laden !','Abbruch')
  Else
 If Msg[4]=D_Ende
  Then Begin
        i:=1;
        If Changes Then i:=Auswahl('Die Datei wurde ver„ndert !','Ende','Abbruch');
        Quit:=(i=1)
       End
  Else
 If Msg[4]=I_Neu
  Then Begin
        Clear_Icon;
        Copy_To_Buffer;
        Paint_Icon;
        Icon_Name:='';
        Just_I_Name:='Unbenannt';
        Print(75,140,Just_I_Name)
       End
  Else
 If Msg[4]=I_Oeffnen
  Then Begin
        Lade_Icon;
        Copy_To_Icon;
        Paint_Icon
       End
  Else
 If Msg[4]=I_Sichern
  Then If Length(Icon_Name)=0
        Then Nachricht('Unbenanntes Icon mit Sichern als ... speichern','Abbruch')
        Else Schreib_Datei(128,Icon_Buffer,Icon_Name)
  Else
 If Msg[4]=I_Sichern_als
  Then Begin
        Schreib_Neue_Datei(128,Icon_Buffer,Dummy_Name);
        If (Icon_Name='') And (Dummy_Name<>'')
         Then Begin
               Icon_Name:=Dummy_Name;
               Last_Part(Icon_Name,Just_I_Name);
               Print(75,140,Just_I_Name)
              End
       End
  Else
 If Msg[4]=E_Loeschen
  Then Begin
        Clear_Icon;
        Copy_To_Buffer;
        Paint_Icon
       End
  Else
 If Msg[4]=E_Invertieren
  Then Begin
        Invert_Icon;
        Copy_To_Buffer;
        Paint_Icon
       End
  Else
 If Msg[4]=E_Fuellen
  Then Begin
        Show_Mouse;
        Repeat
        Until Maus(Maus_x,Maus_y)<>0;
        Repeat
        Until Maus(Maus_x,Maus_y)=0;
        Hide_Mouse;
        If Not In_Box(Maus_x,Maus_y,366,60,257,257)
         Then Write(Chr(7))
         Else Begin
               Fuelle;
               Copy_To_Buffer;
               Paint_Icon
              End
       End
  Else
 If Msg[4]=E_Spiegeln
  Then Begin
        If Auswahl('Wie spiegeln ?','vertikal','horizontal')=2
         Then Spiegel_Hor
         Else Spiegel_Vert;
        Copy_To_Buffer;
        Paint_Icon
       End
  Else
 If Msg[4]=S_Offset Then Setze_Offset Else
 If Msg[4]=S_Suchen
  Then If Datei_Laenge-Offset>128
        Then Begin
              Make_I_String(I_String);
              Bee;
              l:=Searchstring(Datei_Buffer+Offset,Datei_Laenge-Offset,I_String);
              No_Bee;
              If l>=0
               Then Begin
                     Offset:=l-Datei_Buffer;
                     Datei_Leiste
                    End
               Else Nachricht('Icon nicht gefunden !','Abbruch')
              End
        Else Nachricht('Datei zu kurz oder Offset zu grož !','Abbrechen')
  Else
 If Msg[4]=K_Icon_Datei
  Then Begin
        Movebytes(Icon_Buffer,Datei_Buffer+Offset,128);
        Datei_Leiste;
        Changes:=True
       End
  Else
 If Msg[4]=K_Datei_Icon
  Then Begin
        Movebytes(Datei_Buffer+Offset,Icon_Buffer,128);
        Copy_To_Icon;
        Paint_Icon
       End
  Else
 If Msg[4]=So_Maske Then Make_Maske Else
 If Msg[4]=So_And Then Do_And Else
 If Msg[4]=So_Or Then Do_Or Else
 If Msg[4]=So_Xor Then Do_Xor Else
 If Msg[4]=Bi_Laden
  Then Begin
        Laenge:=Lies_Datei(32034,Picture_Buffer,Picture_Name);
        If Laenge=32034
         Then Begin
               Movelongs(Picture_Buffer+34,Screen_Buffer,8000);
               Movelongs(Screen_Buffer,Picture_Buffer,8000)
              End
         Else Begin
               Extension(Picture_Name,Ext);
               If Ext='PAC'
                Then Begin
                      Save_Screen;
                      If Getstad(Picture_Buffer)=1
                       Then Movelongs(Screen,Picture_Buffer,8000)
                       Else Nachricht('Falsches Format !','Abbruch');
                      Show_Screen
                     End
              End
       End
  Else
 If Msg[4]=Bi_Grab Then Begin
                         Erase_Menu(M_Handle);
                         Grab_Icon;
                         Draw_Menu(M_Handle)
                        End;
 Draw_Menu(M_Handle);
 Menu_Normal(M_Handle,Msg[3])
End;

Procedure Error(m : String);
Begin
 Clear_Screen;
 WriteLn(m);
 WriteLn('<Taste>');
 Readln;
 Halt
End;

Procedure Init_Daten;
Var CurDrv : Integer;
Begin
 Screen:=Physbase;
 Screen_Buffer:=Malloc(32000);
 Picture_Buffer:=Malloc(32064);
 Icon_Buffer:=Malloc(200);
 IBuffer:=Malloc(200);
 If    (Screen_Buffer<=0) Or (Icon_Buffer<=0)
    Or (IBuffer<=0)       Or (Picture_Buffer<=0)
  Then Error('Zu wenig Speicher');
 Icon_Buffer:=Icon_Buffer+10;
 Buffer_Laenge:=Malloc(-1);
 If Buffer_Laenge>50000 Then Buffer_Laenge:=Buffer_Laenge-50000;
 If Buffer_Laenge<135 Then Error('Zu wenig Speicher');
 Datei_Buffer:=Malloc(Buffer_Laenge);
 If Datei_Buffer<=0 Then Error('Zu wenig Speicher');
 Buffer_Laenge:=Buffer_Laenge-10;
 InitMaus;
 Quit:=False;
 Icon_Name:='';
 Just_I_Name:='Unbenannt';
 Datei_Name:='';
 Just_D_Name:='Unbenannt';
 Datei_Laenge:=0;
 Offset:=0;
 Erase:=False;
 Changes:=False;
 CurDrv:=Dgetdrv;
 Offset_Pos:=0;
 Box_Width:=0;
 No_Draw:=True;
 Pfad:=Concat(Chr(CurDrv+65),':\*.*');
 Line_Pattern:=$FFFFFFFF;
 Move_Pattern:=$EAEAEAEA;
 Erase_Pattern:=$00000000;
 M_Gesperrt:=[];
End;

Procedure Clear_Msg;
Var i : Integer;
Begin
 For i:=0 to 15 do Msg[i]:=0
End;

Procedure Fenster_Auf;
Var W_Title : Window_Title;
Begin
 W_Title:='DisabSoft';
 W_Handle:=New_Window(None,W_Title,0,0,640,400);
 Open_Window(W_Handle,0,0,0,0)
End;

Begin
 Write(#27,'v');
 If Getrez<>2 Then Error('Dieses Programm l„uft nur in hoher Aufl”sung !');
 Init_Daten;
 If Init_Gem<>0
  Then Begin
        Mfree(Screen_Buffer);
        Error('Init_Gem fehlgeschlagen');
       End;
 Init_Mouse;
 Hide_Mouse;
 Fenster_Auf;
 Init_Menu;
 Draw_Menu(M_Handle);
 Clear_Icon;
 Restauriere;
 Repeat
  Show_Mouse;
  Clear_Msg;
  Repeat
   Event:=Get_Event(E_Message | E_Button | E_Timer | E_Keyboard,
                    1,1,2,$1000,False,0,0,0,0,False,0,0,0,0,
                    Msg,Taste,bcnt,bstate,Maus_x,Maus_y,d);
  Until (   (Event & E_Button<>0)
         Or (Msg[0]=Mn_Selected)
         Or (Event & E_Keyboard<>0)
         Or (Msg[0]=Wm_Redraw));
  Hide_Mouse;
  If Msg[0]=Wm_Redraw
   Then If No_Draw Then No_Draw:=False
                   Else Restauriere;
  If Msg[0]=Mn_Selected
   Then Handle_Menu
   Else If Event & E_Button<>0
         Then Handle_Mouse
         Else Handle_Keyboard
 Until Quit;
 Show_Mouse;
 Erase_Menu(M_Handle);
 Delete_Menu(M_Handle);
 Close_Window(W_Handle);
 Delete_Window(W_Handle);
 Exit_Gem;
 Mfree(Screen_Buffer);
 MFree(Datei_Buffer);
 MFree(Icon_Buffer);
End.

