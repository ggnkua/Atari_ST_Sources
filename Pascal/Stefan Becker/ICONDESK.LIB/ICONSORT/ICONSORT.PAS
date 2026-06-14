{$s50}

{ IconSort von Dirk Sabiwalsky 5/89 fr Pascal+ 2.02 Link: Movelib }

Program IconSort;

Const {$I GEMCONST.PAS}

      { Koordinaten: }

      Box_Width  = 120;
      Box_Height =  40;
      LC_x = 500; LC_y =  10;
      SC_x = 500; SC_y =  60;
      LI_x = 500; LI_y = 110;
      SI_x = 500; SI_y = 160;
      DI_x = 500; DI_y = 210;
      SW_x = 500; SW_y = 260;
      QU_x = 500; QU_y = 350;
      NP_x =  10; NP_y =  10; NP_h = 30;
      PP_x = 140; PP_y =  10; PP_h = 30;
      MS_x = 270; MS_y =  10; MS_w = 160; MS_h = 30;

      { Kommando-Codes: }

      NO  =    0;
      LC  =    1;
      SC  =    2;
      LI  =    3;
      SI  =    4;
      DI  =    5;
      SW  =    6;
      QU  =    7;
      NP  =    8;
      PP  =    9;

Type {$I GEMTYPE.PAS}
     Swaps   = (NoSwap,SearchFirst,SearchSecond);

Var Matches         : Array [1..256,1..10] of String[12];
    First_Icon,
    Last_Icon,
    S_First         : Integer;
    Line_Pattern,
    Erase_Pattern,
    Screen,
    Screen_Buffer,
    Icons,
    IBuffer         : Long_Integer;
    Swap_Status     : Swaps;
    Icon_Pfad,
    Konfig_Pfad     : String;

{$I GEMSUBS.PAS}
{$I TOSEXT.PAS}
{$I MOVESUBS.PAS}

Procedure Box(x,y,b,h : Integer);
Begin
 Paint_Style(1);
 Paint_Color(0);
 Paint_Rect(x,y,b,h);
 Line_Style(1);
 Line_Color(1);
 Frame_Rect(x,y,b,h)
End;

Procedure Fat_Box(x,y,b,h : Integer);
Begin
 Box(x,y,b,h);
 Frame_Rect(x-1,y-1,b+2,h+2)
End;

Procedure Draw_Integer(x,y : Integer; i : Integer);
Var s : String;
Begin
 Writev(s,i);
 Draw_String(x,y,s)
End;

Procedure Build_Screen;
Var i : Integer;
Begin
 Clear_Screen;
 Paint_Color(1);
 Paint_Style(2);
 Paint_Rect(0,0,640,400);
 For i:=0 to 9 do
 Begin
  Box(14,50+(i*34),210,35);
  Box(278,50+(i*34),210,35)
 End;
 Fat_Box(LC_x,LC_y,Box_Width,Box_Height);
 Fat_Box(SC_x,SC_y,Box_Width,Box_Height);
 Fat_Box(LI_x,LI_y,Box_Width,Box_Height);
 Fat_Box(SI_x,SI_y,Box_Width,Box_Height);
 Fat_Box(DI_x,DI_y,Box_Width,Box_Height);
 Fat_Box(SW_x,SW_y,Box_Width,Box_Height);
 Fat_Box(QU_x,QU_y,Box_Width,Box_Height);
 Fat_Box(NP_x,NP_y,Box_Width,NP_h);
 Fat_Box(PP_x,PP_y,Box_Width,PP_h);
 Box(MS_x-4,MS_y-4,MS_w+8,MS_h+8);
 Fat_Box(MS_x,MS_y,MS_w,MS_h);
 Draw_String(LC_x+5,LC_y+30,'Konf. laden');
 Draw_String(SC_x+5,SC_y+30,'Konf. sichern');
 Draw_String(LI_x+5,LI_y+30,'Icon laden');
 Draw_String(SI_x+5,SI_y+30,'Icon sichern');
 Draw_String(DI_x+5,DI_y+30,'Icon l”schen');
 Draw_String(SW_x+5,SW_y+30,'Icons tauschen');
 Draw_String(QU_x+5,QU_y+30,'ENDE');
 Draw_String(NP_x+5,NP_y+18,'Seite weiter');
 Draw_String(PP_x+5,PP_y+18,'Seite zurck')
End;

Procedure Erase_Message;
Begin
 Box(MS_x-4,MS_y-4,MS_w+8,MS_h+8);
 Fat_Box(MS_x,MS_y,MS_w,MS_h);
End;

Procedure Draw_Message(s : String);
Begin
 Draw_String(MS_x+5,MS_y+18,s)
End;

Procedure Save_Screen;
Begin
 Movelongs(Screen,Screen_Buffer,8000)
End;

Procedure Show_Screen;
Begin
 Movelongs(Screen_Buffer,Screen,8000)
End;

Function Auswahl(Meldung     : String;
                 Wahl1,Deflt : String) : Integer;
Var Message_Dialog  : Dialog_Ptr;
    Me_Zeile,
    De_Zeile,
    w1_Zeile,
    Dialog,Ok       : Tree_Index;
Begin
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
 Show_Mouse;
 Dialog:=Do_Dialog(Message_Dialog,Null_Index);
 Hide_Mouse;
 End_Dialog(Message_Dialog);
 Delete_Dialog(Message_Dialog);
 Show_Screen;
 If Dialog=De_Zeile Then Auswahl:=2
                    Else Auswahl:=1
End;

Procedure Nachricht(Meldung,Weiter : String);
Var Message_Dialog  : Dialog_Ptr;
    Zeile,Dialog,
    Frame,Ok        : Tree_Index;
    Breite          : Integer;

 Function Max(a,b : Integer) : Integer;
 Begin
  If a>b Then Max:=a
         Else Max:=b
 End;

Begin
 Breite:=Max(Length(Meldung),Length(Weiter));
 Message_Dialog:=New_Dialog(4,0,0,Breite+8,9);
 Frame:=Add_DItem(Message_Dialog,G_Box,None,1,1,Breite+6,7,1,Black | 4*16 | Black*4096);
 Zeile:=Add_Ditem(Message_Dialog,G_Text,None,2,2,Breite,1,0,Black*256);
 Set_Dtext(Message_Dialog,Zeile,Meldung,System_Font,Te_Left);
 Ok:=Add_Ditem(Message_Dialog,G_Button,
               Selectable | Default | Exit_Btn | Radio_Btn | Touch_Exit,
               2,4,Breite+2,3,-2,Black*256 | Black*4096);
 Set_Dtext(Message_Dialog,Ok,Weiter,System_Font,Te_Center);
 Center_Dialog(Message_Dialog);
 Save_Screen;
 Show_Mouse;
 Dialog:=Do_Dialog(Message_Dialog,Null_Index);
 Hide_Mouse;
 End_Dialog(Message_Dialog);
 Delete_Dialog(Message_Dialog);
 Show_Screen
End;

Procedure Paint_Icon(Icon_Number : Integer);
Var byte_x,koord_y,i : Integer;
Begin
 byte_x:=7;
 koord_y:=51+((Icon_Number-1) Mod 20)*34;
 If koord_y>358 Then Begin
                      byte_x:=41;
                      koord_y:=koord_y-340
                     End;
 For i:=1 to 32 do
  Movebytes(Icons+(Icon_Number-1)*256+(i-1)*4,Screen+koord_y*80+byte_x+i*80,4)
End;

Procedure Show_Icontext(Icon_Number : Integer);
Var x,y        : Integer;
    SDummy     : String;
Begin
 WriteV(SDummy,Icon_Number:3);
 x:=118;
 y:=77+((Icon_Number-1) Mod 20)*34;
 If y>383 Then Begin
                x:=382;
                y:=y-340
               End;
 Draw_String(x-100,y-3,SDummy);
 Draw_String(x,y,'             ');
 If Length(Matches[Icon_Number,1])>0
  Then Draw_String(x,y,Matches[Icon_Number,1]);
End;

Procedure Erase_Icon(Icon_Number : Integer);
Var byte_x,koord_y,i : Integer;
Begin
 byte_x:=7;
 koord_y:=51+((Icon_Number-1) Mod 20)*34;
 If koord_y>358 Then Begin
                      byte_x:=41;
                      koord_y:=koord_y-340
                     End;
 Fillbytes(IBuffer,128,0);
 For i:=1 to 32 do
  Movebytes(IBuffer,Screen+koord_y*80+byte_x+i*80,4)
End;

Procedure Erase_Icontext(Icon_Number : Integer);
Var x,y        : Integer;
    SDummy     : String;
Begin
 x:=118;
 y:=77+((Icon_Number-1) Mod 20)*34;
 If y>383 Then Begin
                x:=382;
                y:=y-340
               End;
 Draw_String(x-100,y-3,'   ');
 Draw_String(x,y,'             ')
End;

Function Min(x,y : Integer) : Integer;
Begin
 If x<y Then Min:=x Else Min:=y
End;

Procedure Show_Gallery;
Var Icon_Number : Integer;
Begin
 Erase_Message;
 For Icon_Number:=1 to 20 do
 Begin
  Erase_Icon(Icon_Number);
  Erase_Icontext(Icon_Number)
 End;
 For Icon_Number:=First_Icon to Min(First_Icon+19,Last_Icon) do
 Begin
  Paint_Icon(Icon_Number);
  Show_Icontext(Icon_Number)
 End;
 If Swap_Status=SearchFirst Then Draw_Message('Welches Icon ?');
 If Swap_Status=SearchSecond Then Draw_Message('Womit vertauschen ?')
End;

Procedure First(Var s : String);
Var i : Integer;
Begin
 i:=Length(s);
 While (i>0) And (s[i]<>'.') do i:=i-1;
 s[0]:=Chr(i-1)
End;

Function Dez(i : Integer) : Integer;
Begin
 If Chr(i) in ['0'..'9'] Then Dez:=i-48
                         Else Dez:=i-55
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

Procedure DelChar(Var s : String; Pos : Integer);
Var i : Integer;
Begin
 If (Length(s)>0) And (Pos>0)
  Then Begin
        If Pos<Length(s)
         Then For i:=Pos to Length(s)-1 do s[i]:=s[i+1];
        s[0]:=Chr(Ord(s[0])-1)
       End
End;

Function NewMatch : Boolean;
Var Index,i,cnt     : Integer;
    s               : String;
    Error           : Boolean;
Begin
 Error:=False;
 If     (Peek(IBuffer+8)=Ord('.'))
    And (Peek(IBuffer+12)=Ord('='))
    And (Peek(IBuffer+15)=Ord(';'))
  Then Begin
        i:=0;
        While i<12 do
        Begin
         s[i+1]:=Chr(Peek(IBuffer+i));
         i:=i+1
        End;
        s[0]:=Chr(12);
        While Position(s,' ')>0 do DelChar(s,Position(s,' '));
        Index:=Dez(Peek(IBuffer+13))*16+Dez(Peek(IBuffer+14))+1;
        If     (Index<=Last_Icon)
           And (Index>=1)
           And (Length(Matches[Index,10])=0)
         Then Begin
               cnt:=1;
               While (Length(Matches[Index,cnt])>0) do cnt:=cnt+1;
               Matches[Index,cnt]:=s;
              End
         Else Error:=True
       End
  Else Error:=True;
 NewMatch:=Error
End;

Procedure Make_C_String(    P_String : String;
                        Var C_String : TE_Cstring);
Var i : Integer;
Begin
 For i:=1 to Length(P_String) do C_String[i-1]:=P_String[i];
 C_String[Length(P_String)]:=#0
End;

Procedure Make_P_String(    C_String : TE_CString;
                        Var P_String : String);
Var i : Integer;
Begin
 i:=0;
 While (i<80) And (C_String[i]<>#0) do
 Begin
  i:=i+1;
  P_String[i]:=C_String[i-1];
 End;
 P_String[0]:=Chr(i)
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

Procedure Init_Matches;
Var i,k : Integer;
Begin
 For i:=1 to 256 do
  For k:=1 to 10 do
   Matches[i,k]:=''
End;

Procedure Load_Config;
Var Anzahl,
    BufOffset       : Long_Integer;
    Match_Handle,
    Icon_Handle,
    i               : Integer;
    C_Name          : TE_Cstring;
    In_File         : Boolean;
    Name            : String;
    Error           : Boolean;
Begin
 Draw_Message('Konf. laden');
 Save_Screen;
 Show_Mouse;
 Name:='ICONS.IMG';
 In_File:=Get_In_File(Konfig_Pfad,Name);
 Hide_Mouse;
 Show_Screen;
 If Pos('.',Name)<=0
  Then Nachricht('Falscher Dateiname ! Format: <NAME>.IMG','Abbruch')
  Else If In_File And (Length(Name)>0)
        Then Begin
              Make_C_String(Name,C_Name);
              Icon_Handle:=Fopen(C_Name,0);
              If Icon_Handle<0
               Then Nachricht('Die Icondatei existiert nicht !','Abbruch')
               Else Begin
                     Init_Matches;
                     First_Icon:=1;
                     BufOffset:=0;
                     Bee;
                     Repeat
                      Anzahl:=Fread(Icon_Handle,256,Icons+BufOffset*256);
                      If Anzahl=256 Then BufOffset:=BufOffset+1
                     Until (Anzahl<>256) Or (BufOffset=256);
                     Last_Icon:=BufOffset;
                     Fclose(Icon_Handle);
                     No_Bee;
                     First(Name);
                     Name:=Concat(Name,'.MAT');
                     Make_C_String(Name,C_Name);
                     Match_Handle:=Fopen(C_Name,0);
                     If Match_Handle<0
                      Then Nachricht('Die Matchdatei existiert nicht !','Abbruch')
                      Else Begin
                            Bee;
                            Error:=False;
                            Repeat
                             Anzahl:=Fread(Match_Handle,16,IBuffer);
                             If Anzahl=16 Then Error:=NewMatch
                            Until (Anzahl<16) Or Error;
                            Fclose(Match_Handle);
                            No_Bee;
                            If Error
                             Then Begin
                                   Nachricht('Matchdatei: falsches Dateiformat !','Abbruch');
                                   Init_Matches
                                  End
                           End;
                     Show_Gallery
                    End
             End
End;

Procedure Make_Match(Index,k : Integer);
Var i,pos       : Integer;
    s,HexString : String;
Begin
 HexString:='0123456789ABCDEF';
 Fillbytes(IBuffer,16,32);
 s:=Matches[Index,k];
 pos:=Position(s,'.');
 If pos=0
  Then For i:=1 to 8 do
        If i<=Length(s) Then Poke(IBuffer+i-1,Ord(s[i]))
                        Else
  Else For i:=1 to pos-1 do Poke(IBuffer+i-1,Ord(s[i]));
 Poke(IBuffer+8,Ord('.'));
 If pos>0
  Then For i:=1 to 3 do
        If i+pos<=Length(s) Then Poke(IBuffer+i+8,Ord(s[i+pos]));
 Poke(IBuffer+12,Ord('='));
 Index:=Index-1;
 Poke(IBuffer+13,Ord(HexString[(Index Div 16)+1]));
 Poke(IBuffer+14,Ord(HexString[(Index Mod 16)+1]));
 Poke(IBuffer+15,Ord(';'))
End;

Procedure Save_Config;
Var Anzahl,
    BufOffset       : Long_Integer;
    Match_Handle,
    Icon_Handle,
    i,k             : Integer;
    In_File,Err     : Boolean;
    Name            : String;
    C_Name          : TE_CString;
Begin
 Draw_Message('Konf. sichern');
 Save_Screen;
 Show_Mouse;
 Name:='ICONS.IMG';
 In_File:=Get_In_File(Konfig_Pfad,Name);
 Hide_Mouse;
 Show_Screen;
 If In_File And (Length(Name)>0)
  Then Begin
        Make_C_String(Name,C_Name);
        Icon_Handle:=Fcreate(C_Name,0);
        If Icon_Handle<0
         Then Nachricht('Die Icondatei kann nicht erzeugt werden !','Abbruch')
         Else Begin
               BufOffset:=0;
               Bee;
               Repeat
                Anzahl:=Fwrite(Icon_Handle,256,Icons+BufOffset*256);
                If Anzahl=256 Then BufOffset:=BufOffset+1
               Until (Anzahl<>256) Or (BufOffset=Last_Icon);
               Fclose(Icon_Handle);
               No_Bee;
               If Anzahl<>256 Then Nachricht('Icondatei: es ist ein Schreibfehler aufgetreten !','Weiter');
               First(Name);
               Name:=Concat(Name,'.MAT');
               Make_C_String(Name,C_Name);
               Match_Handle:=Fcreate(C_Name,0);
               If Match_Handle<0
                Then Nachricht('Die Matchdatei kann nicht erzeugt werden !','Abbruch')
                Else Begin
                      Err:=False;
                      Bee;
                      For i:=1 to Last_Icon do
                       For k:=1 to 10 do
                        If (Length(Matches[i,k])>0) And (Not Err)
                         Then Begin
                               Make_Match(i,k);
                               Anzahl:=Fwrite(Match_Handle,16,IBuffer);
                               If Anzahl<>16 Then Err:=True;
                              End;
                      No_Bee;
                      Fclose(Match_Handle);
                      If Anzahl<>16 Then Nachricht('Matchdatei: es ist ein Schreibfehler aufgetreten !','Weiter');
                     End
              End
       End
End;

Function Lies_Datei(Anzahl,Adresse : Long_Integer) : Long_Integer;
Var Laenge,
    F_Laenge,
    dta_buffer,
    ldummy     : Long_Integer;
    F_Handle,
    Dummy      : Integer;
    C_Name     : TE_CString;
    In_File    : Boolean;
    Name       : String;
Begin
 Laenge:=-1;
 Save_Screen;
 Show_Mouse;
 Name:='ICON.DBL';
 In_File:=Get_In_File(Icon_Pfad,Name);
 Hide_Mouse;
 Show_Screen;
 If In_File And (Length(Name)>0)
  Then Begin
        dta_buffer:=Fgetdta;
        Make_C_String(Name,C_Name);
        ldummy:=Fsfirst(C_Name,0);
        Laenge:=LPeek(dta_buffer+26);
        If Laenge>Anzahl
         Then Begin
               Nachricht('Die Datei ist zu grož !','Abbruch');
               Laenge:=0
              End
         Else Begin
               F_Handle:=Fopen(C_Name,0);
               If F_Handle<0
                Then Nachricht('Die Datei existiert nicht !','Abbruch')
                Else Begin
                      Bee;
                      Laenge:=Fread(F_Handle,Anzahl,Adresse);
                      No_Bee;
                      If Laenge<=0
                       Then Nachricht('Die Datei kann nicht richtig gelesen werden !','Abbruch')
                       Else Fclose(F_Handle);
                     End
              End
       End;
 Lies_Datei:=Laenge
End;

Procedure Schreib_Datei(Anzahl,Adresse : Long_Integer);
Var Laenge     : Long_Integer;
    F_Handle   : Integer;
    C_Name     : TE_CString;
    In_File,
    Writefile  : Boolean;
    Name       : String;
Begin
 Save_Screen;
 Show_Mouse;
 Name:='ICON.DBL';
 In_File:=Get_In_File(Icon_Pfad,Name);
 Hide_Mouse;
 Show_Screen;
 If In_File And (Length(Name)>0)
  Then Begin
        Make_C_String(Name,C_Name);
        Writefile:=True;
        F_Handle:=Fopen(C_Name,1);
        If F_Handle>=0
         Then Writefile:=(Auswahl('šberschreiben der alten Datei ?','Ja','Nein')=1);
        If Writefile
         Then Begin
               F_Handle:=Fcreate(C_Name,0);
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

Procedure Swap_Init;
Begin
 Draw_Message('Welches Icon ?');
 Swap_Status:=SearchFirst
End;

Function In_Box(Xko,Yko,x,y,b,h : Integer) : Boolean;
Begin
 In_Box:=(Xko>=x) And (Xko<=x+b) And (Yko>=y) And (Yko<=y+h)
End;

Procedure Get_Icon(Var Icon_Number : Integer);
Var Msg             : Message_Buffer;
    Taste,d,Event,
    Maus_x,Maus_y   : Integer;

Begin
 Show_Mouse;
 Repeat
  Event:=Get_Event(E_Button | E_Timer,
                   1,1,1,$10,False,0,0,0,0,False,0,0,0,0,
                   Msg,Taste,d,d,Maus_x,Maus_y,d);
 Until (Event & E_Button)<>0;
 Hide_Mouse;
 If In_Box(Maus_x,Maus_y,14,50,210,340) Or In_Box(Maus_x,Maus_y,278,50,210,340)
  Then Begin
         Icon_Number:=((Maus_y-50) Div 34);
         If Maus_x>270 Then Icon_Number:=Icon_Number+10;
         Icon_Number:=Icon_Number+First_Icon
        End
  Else Icon_Number:=-1
End;

Procedure Clear_Match(i : Integer);
Var k : Integer;
Begin
 For k:=1 to 10 do Matches[i,k]:=''
End;

Procedure Load_Icon;
Var Erg             : Long_Integer;
    Icon_Position,
    Index,k         : Integer;
Begin
 If Last_Icon>0
  Then Begin
        Draw_Message('Wohin laden ?');
        Get_Icon(Icon_Position);
        If Icon_Position>Last_Icon Then Icon_Position:=Last_Icon+1
       End
  Else Icon_Position:=Last_Icon+1;
 Erase_Message;
 Draw_Message('Icon laden');
 If Icon_Position>0
  Then Begin
        Erg:=Lies_Datei(256,IBuffer);
        If Erg=256
         Then Begin
               Last_Icon:=Last_Icon+1;
               If Icon_Position=Last_Icon
                Then Movebytes(IBuffer,Icons+(Last_Icon-1)*256,256)
                Else Begin
                      For Index:=Last_Icon downto Icon_Position+1 do
                      Begin
                       For k:=1 to 10 do Matches[Index,k]:=Matches[Index-1,k];
                       Movebytes(Icons+(Index-2)*256,Icons+(Index-1)*256,256)
                      End;
                      Movebytes(IBuffer,Icons+(Icon_Position-1)*256,256);
                     End;
               Clear_Match(Icon_Position);
               Show_Gallery
              End
         Else If Erg>=0 Then Nachricht('Das ist keine gltige Icondatei','Abbruch')
       End
  Else Nachricht('Da ist kein Icon !','Abbruch')
End;

Procedure Save_Icon;
Var Icon_Number,Index,k : Integer;
Begin
 Draw_Message('Welches sichern ?');
 Get_Icon(Icon_Number);
 Erase_Message;
 Draw_Message('Icon sichern');
 If (Icon_Number>0) And (Icon_Number<=Last_Icon)
  Then Schreib_Datei(256,Icons+(Icon_Number-1)*256)
  Else If Icon_Number<0
        Then Nachricht('Da ist kein Icon !','Abbruch')
        Else Nachricht('Icon nicht definiert !','Abbruch')
End;

Procedure Delete_Icon;
Var Icon_Number,i,k : Integer;
Begin
 Draw_Message('Icon l”schen');
 Get_Icon(Icon_Number);
 If Icon_Number>0
  Then If Icon_Number=Last_Icon
        Then Begin
              Clear_Match(Last_Icon);
              Last_Icon:=Last_Icon-1;
              Show_Gallery
             End
        Else If Icon_Number<Last_Icon
              Then Begin
                    For i:=Icon_Number+1 to Last_Icon do
                    Begin
                     For k:=1 to 10 do
                      Matches[i-1,k]:=Matches[i,k];
                     Movelongs(Icons+(i-1)*256,Icons+(i-2)*256,64)
                    End;
                    Clear_Match(Last_Icon);
                    Last_Icon:=Last_Icon-1;
                    Show_Gallery
                   End
              Else Nachricht('Icon nicht definiert !','Abbruch')
  Else Nachricht('Da ist kein Icon !','Abbruch')
End;

Procedure Next_Page;
Begin
 If First_Icon+20<=Last_Icon
  Then Begin
        First_Icon:=First_Icon+20;
        Show_Gallery
       End
End;

Procedure Previous_Page;
Begin
 If First_Icon-20>0
  Then Begin
        First_Icon:=First_Icon-20;
        Show_Gallery
       End
End;

Procedure UpCase(Var s : String);
Var i : Integer;
Begin
 For i:=1 to Length(s) do
  If s[i] in ['a'..'z'] Then s[i]:=Chr(Ord(s[i])-32)
End;

Procedure Icon_Dialog(Icon_Number : Integer);
Var D               : Dialog_Ptr;
    Frame,Head,Ok,
    Cancel,TDummy,
    Dialog          : Tree_Index;
    StrArr          : Array [1..10] of Tree_Index;
    i,Index         : Integer;
    SDummy,
    T_s,T_c         : String[255];
Begin
 D:=New_Dialog(26,1,1,40,23);
 Frame:=Add_DItem(D,G_Box,None,1,1,38,21,1,Black | 4*16 | Black*4096);
 Frame:=Add_DItem(D,G_Box,None,13,2,14,3,1,Black | 2*16 | Black*4096);
 Frame:=Add_DItem(D,G_Box,None,2,6,36,12,1,White | Black*4096);
 Head:=Add_DItem(D,G_Text,None,14,3,12,1,0,Black*256);
 T_s:='____________';
 T_c:='XXXXXXXXXXXX';
 For i:=1 to 10 do
 Begin
  TDummy:=Add_DItem(D,G_Text,None,3,6+i,3,1,0,Black*256);
  WriteV(SDummy,i:3);
  Set_DText(D,TDummy,Concat(SDummy,':'),System_Font,TE_Left);
  StrArr[i]:=Add_DItem(D,G_FBoxText,Editable,8,6+i,12,1,0,128 | Black*256);
  Set_DEdit(D,StrArr[i],T_s,T_c,Matches[Icon_Number,i],System_Font,TE_Left);
 End;
 Ok:=Add_DItem(D,G_BoxText,Selectable | Default | Exit_Btn | Touch_Exit,
               5,19,10,2,3,Black*256 | Black*4096);
 Cancel:=Add_DItem(D,G_BoxText,Selectable | Exit_Btn | Touch_Exit,
                   25,19,10,2,1,Black*256 | Black*4096);
 WriteV(SDummy,Icon_Number);
 Set_DText(D,Head,Concat('Icon Nr. ',SDummy,':'),System_Font,TE_Center);
 Set_DText(D,Ok,'OK',System_Font,TE_Center);
 Set_DText(D,Cancel,'Abbruch',System_Font,TE_Center);
 Center_Dialog(D);
 Save_Screen;
 Show_Mouse;
 Dialog:=Do_Dialog(D,StrArr[1]);
 If Dialog=Ok
  Then Begin
        Clear_Match(Icon_Number);
        Index:=1;
        For i:=1 to 10 do
        Begin
         Get_DEdit(D,StrArr[i],SDummy);
         If Length(SDummy)>0
          Then Begin
                UpCase(SDummy);
                Matches[Icon_Number,Index]:=SDummy;
                Index:=Index+1
               End
        End
       End;
 Hide_Mouse;
 End_Dialog(D);
 Delete_Dialog(D);
 Show_Screen
End;

Procedure Swap_Icons(i1,i2 : Integer);
Var k : Integer;
    A : Array [1..10] of String[12];
Begin
 For k:=1 to 10 do
  A[k]:=Matches[i1,k];
 For k:=1 to 10 do
  Matches[i1,k]:=Matches[i2,k];
 For k:=1 to 10 do
  Matches[i2,k]:=A[k];
 Movelongs(Icons+(i1-1)*256,IBuffer,64);
 Movelongs(Icons+(i2-1)*256,Icons+(i1-1)*256,64);
 Movelongs(IBuffer,Icons+(i2-1)*256,64);
 Show_Gallery
End;

Procedure Icon_Choice(x,y : Integer);
Var Icon_Number : Integer;
Begin
 Icon_Number:=((y-50) Div 34);
 If x>270 Then Icon_Number:=Icon_Number+10;
 Icon_Number:=Icon_Number+First_Icon;
 If Icon_Number<=Last_Icon
  Then If Swap_Status=NoSwap
        Then Begin
              Icon_Dialog(Icon_Number);
              Show_Icontext(Icon_Number)
             End
        Else If Swap_Status=SearchFirst
              Then Begin
                    S_First:=Icon_Number;
                    Erase_Message;
                    Draw_Message('Womit vertauschen ?');
                    Swap_Status:=SearchSecond
                   End
              Else Begin
                    Swap_Icons(S_First,Icon_Number);
                    Swap_Status:=NoSwap
                   End
  Else Nachricht('Icon nicht definiert !','Abbruch')
End;

Function Do_Action(Action : Integer) : Boolean;
Var Quit : Boolean;
Begin
 Quit:=False;
 Case Action of
  LC : Load_Config;
  SC : If Last_Icon>0
        Then Save_Config
        Else Nachricht('Noch keine Konfiguration erstellt !','Abbruch');
  LI : If Last_Icon<256
        Then Load_Icon
        Else Nachricht('Der Iconspeicher ist voll !','Abbruch');
  SI : If Last_Icon>0
        Then Save_Icon
        Else Nachricht('Noch kein Icon definiert !','Abbruch');
  DI : If Last_Icon>0
        Then Delete_Icon
        Else Nachricht('Noch kein Icon definiert !','Abbruch');
  SW : If Last_Icon>=2
        Then Swap_Init
        Else Nachricht('Noch nicht genug Icons definiert !','Abbruch');
  QU : Quit:=Auswahl('Programm beenden ?','Nein','Ja')=2;
  NO : ;
 End;
 Do_Action:=Quit
End;

Function Get_Action(x,y : Integer) : Integer;
Begin
 If In_Box(x,y,LC_x,LC_y,Box_Width,Box_Height)
  Then If Swap_Status=NoSwap Then Get_Action:=LC Else
 Else If In_Box(x,y,SC_x,SC_y,Box_Width,Box_Height)
  Then If Swap_Status=NoSwap Then Get_Action:=SC Else
 Else If In_Box(x,y,LI_x,LI_y,Box_Width,Box_Height)
  Then If Swap_Status=NoSwap Then Get_Action:=LI Else
 Else If In_Box(x,y,SI_x,SI_y,Box_Width,Box_Height)
  Then If Swap_Status=NoSwap Then Get_Action:=SI Else
 Else If In_Box(x,y,DI_x,DI_y,Box_Width,Box_Height)
  Then If Swap_Status=NoSwap Then Get_Action:=DI Else
 Else If In_Box(x,y,SW_x,SW_y,Box_Width,Box_Height)
  Then If Swap_Status=NoSwap Then Get_Action:=SW Else
 Else If In_Box(x,y,QU_x,QU_y,Box_Width,Box_Height)
  Then If Swap_Status=NoSwap Then Get_Action:=QU Else
 Else If In_Box(x,y,NP_x,NP_y,Box_Width,Box_Height)
  Then Begin
        Next_Page;
        Get_Action:=NO
       End
 Else If In_Box(x,y,PP_x,PP_y,Box_Width,Box_Height)
  Then Begin
        Previous_Page;
        Get_Action:=NO
       End
 Else If In_Box(x,y,14,50,210,340) Or In_Box(x,y,278,50,210,340)
  Then Begin
        Icon_Choice(x,y);
        Get_Action:=NO
       End
 Else Begin
       Write(#7);
       Get_Action:=NO;
      End
End;

Procedure CommandFrame;
Var Quit            : Boolean;
    Msg             : Message_Buffer;
    Taste,d,Event,
    Maus_x,Maus_y,
    Action          : Integer;

Begin
 Repeat
  Show_Mouse;
  Repeat
   Event:=Get_Event(E_Button | E_Timer,
                    1,1,2,$10,False,0,0,0,0,False,0,0,0,0,
                    Msg,Taste,d,d,Maus_x,Maus_y,d);
  Until (Event & E_Button)<>0;
  Hide_Mouse;
  Action:=Get_Action(Maus_X,Maus_Y);
{  if Swap_Status=NoSwap Then Activate(Action); }
  Quit:=Do_Action(Action);
  If Swap_Status=NoSwap
   Then Begin
         Erase_Message;
{         Desactivate(Action) }
        End
 Until Quit
End;

Procedure Init_Daten;
Var C_Pfad : TE_CString;
Begin
 Screen:=Physbase;
 Screen_Buffer:=Malloc(32000);
 Icons:=Malloc(65536);
 IBuffer:=Malloc(256);
 If (Screen_Buffer<=0) Or (Icons<=0) Or (IBuffer<=0)
  Then Begin
        WriteLn(#27,'ENicht genug Speicher ! <RETURN>');
        ReadLn;
        If Screen_Buffer>0 Then Mfree(Screen_Buffer);
        If Icons>0 Then Mfree(Icons);
        If IBuffer>0 Then Mfree(IBuffer);
        Halt
       End;
 First_Icon:=1;
 Dgetpath(C_Pfad,0);
 Make_P_String(C_Pfad,Icon_Pfad);
 Icon_Pfad:=Concat(Chr(Dgetdrv+65),':',Icon_Pfad,'\*.DBL');
 Make_P_String(C_Pfad,Konfig_Pfad);
 Konfig_Pfad:=Concat(Chr(Dgetdrv+65),':',Konfig_Pfad,'\*.IMG');
 Last_Icon:=0;
 Init_Matches;
 Swap_Status:=NoSwap
End;


Begin
 If Getrez<>2
  Then Begin
        WriteLn(#27,'EDieses Programm l„uft nur in hoher Aufl”sung ! <RETURN>');
        ReadLn;
        Halt
       End;
 If Init_Gem<>0
  Then Begin
        WriteLn(#27,'EGem kann nicht initialisiert werden ! <RETURN>');
        ReadLn;
        Halt
       End;
 Init_Daten;
 Init_Mouse;
 Hide_Mouse;
 Build_Screen;
 Show_Gallery;
 CommandFrame;
 Show_Mouse;
 Exit_Gem;
 Mfree(Screen_Buffer);
 Mfree(Icons);
 Mfree(IBuffer)
End.

