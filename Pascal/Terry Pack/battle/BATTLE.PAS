Program Battle;

{ Battle for the Throne: a stratagy game for 1 to 4 players. }
{ Written by Terry Pack in Personal Pascal Version 1.10      }
{                                                            }
{           Copyright 1988 Antic Publishing Inc.             }
{                                                            }

Const
     {$I C:\Includes\GemConst.Pas               }
      G_Pass= -2;
      G_Exit= -3;
      MaxPlayers=4; { Maximum number of players }
      MaxSides=5;   { MaxPlayers + Bandits      }
      Mx=11;        { How wide the map is  }
      My=6;         { How Tall the map is  }
      TS=24;
      Text_C=9;   { Lt Brown  }
      Borders=10; { Dk Brown  }
      Fill=11;    { Sea Blue  }
      FillPat=3;

Type
     {$I C:\Includes\Gemtype.Pas      }
     {$I C:\Games\Battle\BatType.Pas  }

Var B: Integer;
    Campaigns,Month,Year: Integer;
    C_Item,D_Item,D2_Item: Integer;
    DeskColors,TerrainColors,TitleColors: HeadType;
    Dry,Wet,Snow: Boolean;
    Gold: Array[0..MaxSides] of Long_Integer;
    I_Title,B_Item,Cr_Item,In_Item,Lo_Item: Integer;
    M_Buf,Scn_Buf,St_Buf,T_Buf,Title_Buf: ScreenType;
    Map,Screen,Storage,Terrain,TitlePage: MFDB;
    Menu: Menu_Ptr;
    Order: Array[0..MaxSides] of Integer; { What order the players are in }
    Owner,Pop,Tiles,Troops: Array[0..Mx,0..My] of Integer;
    P,Pn: Integer;
    P_Color: Array[0..MaxSides] of Integer;
    P_Item,P_Title,Q_Item: Integer;
    P_Name: Array[0..MaxSides] of Str255;
    S_Item,Sa_Item: Integer;
    Scn_ptr : S_Ptr;                 { a pointer to the screen }
    T_Effects: Array[0..13] of Real;
    BTB_Item,BTBB_Item,BTC_Item,BTCB_Item,BTD_Item: Integer;
    BTE_Item,BTEB_Item,BTN_Item,Ta_Item,Tr_Item,BTX_Item: Integer;
    T_Box: Dialog_Ptr;

{$I A:\Gemsubs.Pas           }
{$I C:\Includes\Str.Pas      }
{$I C:\Includes\LongStr.Pas  }
{$I C:\Includes\TeHeight.Pas }
{$I C:\Includes\Val.Pas      }

Procedure Init_form(var form: MFDB; var Addr: ScreenType);
External;

Procedure Copy_rect(var s,d:MFDB; from_x,from_y,to_x,to_y,wid,ht,Mode:Integer);
External;

Function Physbase: S_Ptr;    { xbios routine returns address of screen }
Xbios(2);

Function Getrez: Integer;
Xbios(4);

Function F_Open(Var Name: Path_Chars; Mode: Integer): Integer;
Gemdos($3D);

Function Current_Disk: Integer;
Gemdos($19);

Function Rand(N:Integer): Integer;
Function Random: Integer;
Xbios(17);
Begin
  Rand:=Abs(Random mod N)
End;

Procedure Sav_Scn;          { proc saves screen to Scn_buf }
{$P-}                       { turn pointer checking off }
   Begin
     Scn_Ptr := Physbase;   { get addr of screen in memory }
     Scn_buf := Scn_Ptr^    { do assignment, copy entire array }
   End;
{$P=}                       { restore pointer checking to old state }

Procedure Rest_Scn;         { restore screen from buf }
{$P-}                       { turn pointer checking off }
   Begin
      Scn_ptr := Physbase;  { get addr of screen in memory }
      Scn_ptr^:= Scn_Buf    { assign, copy array }
   End;
{$P=}                       { set pointer checking to old state }

Procedure Make_Path(Var Ps: Str255; Var Cs: Path_Chars);
Var I: Integer;
Begin
  For I:=1 to Length(Ps) do Cs[i]:=Ps[i];
  Cs[length(ps)+1]:=Chr(0)
End;

Function Neo_Read(Handle:  Integer;
                  Count:   Long_Integer;
                  Var buf: Neo_Type ): Long_Integer;
Gemdos($3F);

Procedure SetColor(Colornum, Color: Integer);
Xbios(7);

Function ReadColor(Colornum, Color: Integer): Integer;
Xbios(7);

Procedure Set_Color_Registers(Var Header: HeadType);
Var I: Integer;
Begin
  For I:=0 to 15 do SetColor(I,Header[I+2])
End;

Procedure Read_Color_Registers(Var Header: HeadType);
Var I: Integer;
Begin
  For I:=0 to 15 do Header[I+2]:=ReadColor(I,-1)
End;

Procedure Fade_Color(Var T: HeadType);
Var B,I,J,K,Dummy: Integer;
    F: HeadType;
    FC,TC: Array[1..3] of Integer;
    Msg: Message_Buffer;
Begin
  Read_Color_Registers(F);
  For J:=0 to 7 do
    Begin
      For I:=0 to 15 do
        Begin
          FC[1]:=(F[I+2] & 3840) div 256;
          FC[2]:=(F[I+2] &  240) div  16;
          FC[3]:=(F[I+2] &   15);
          TC[1]:=(T[I+2] & 3840) div 256;
          TC[2]:=(T[I+2] &  240) div  16;
          TC[3]:=(T[I+2] &   15);
          For K:=1 to 3 do If FC[K]<TC[K] then FC[K]:=FC[K]+1;
          For K:=1 to 3 do If FC[K]>TC[K] then FC[K]:=FC[K]-1;
          F[I+2]:=FC[1]*256+FC[2]*16+FC[3]
        End;
      B:=Get_Event(E_Timer,0,0,0,90,
                   False,0,0,0,0,False,0,0,0,0,
                   Msg,Dummy,Dummy,Dummy,Dummy,Dummy,Dummy);
      Set_Color_Registers(F)
    End
End;

Procedure Load_Terrain;
Var B: Long_Integer;
    Handle: Integer;
    Neo_Buf: Neo_Type;
    Path: Path_Chars;
    Ps: Str255;
Begin
  Ps:='Terrain.Neo';
  Make_Path(Ps,Path);
  Handle:=F_Open(Path,0);
  B:=Neo_Read(Handle,32127,Neo_Buf);
  Scn_Buf:=Neo_Buf.Pic;
  TerrainColors:=Neo_Buf.Head
End;

Procedure Load_TitlePage;
Var B: Long_Integer;
    Handle: Integer;
    Path: Path_Chars;
    Ps: Str255;
    Neo_Buf: Neo_Type;
Begin
  Ps:='TitlePage.Neo';
  Make_path(Ps,Path);
  Handle:=F_Open(Path,0);
  B:=Neo_Read(Handle,32127,Neo_Buf);
  Scn_Buf:=Neo_Buf.Pic;
  TitleColors:=Neo_Buf.Head
End;

Procedure Initialize;
Var I: Integer;

Procedure Init_BTBox;
Var H,W: Integer;
Begin
  H:=17;
  W:=27;

  T_Box:=New_Dialog(14,0,0,W,H);
  BTN_Item :=Add_DItem(T_Box,G_BoxText,None,
                       1,1,W-2,1,-2,Borders*4096|Text_C*256|128);
  Ta_Item  :=Add_DItem(T_Box,G_Text,None,
                       1,3,W-2,1,-2,Borders*4096|Text_C*256|128);
  Tr_Item  :=Add_DItem(T_Box,G_Text,None,
                       1,4,W-2,1,-2,Borders*4096|Text_C*256|128);
  BTB_Item :=Add_DItem(T_Box,G_Text,None,
                       5,6,W-6,1,-2,Borders*4096|Text_C*256|128);
  BTBB_Item:=Add_DItem(T_Box,G_Box,Selectable|Exit_Btn|Radio_Btn,
                       1,6,3,1,2,Borders*4096|128);
  BTC_Item :=Add_DItem(T_Box,G_Text,None,
                       5,8,W-6,1,-2,Borders*4096|Text_C*256|128);
  BTCB_Item:=Add_DItem(T_Box,G_Box,Selectable|Exit_Btn|Radio_Btn,
                       1,8,3,1,2,Borders*4096|128);
  BTD_Item :=Add_DItem(T_Box,G_Text,None,
                       5,9,W-6,1,-2,Borders*4096|Text_C*256|128);
  BTEB_Item:=Add_DItem(T_Box,G_Box,Selectable|Exit_Btn|Radio_Btn,
                       1,11,3,1,2,Borders*4096|128);
  BTE_Item :=Add_DItem(T_Box,G_Text,None,
                       5,11,W-6,1,-2,Borders*4096|Text_C*256|128);
  BTX_Item :=Add_DItem(T_Box,G_BoxText,Selectable|Exit_Btn|Radio_Btn|Default,
                       W div 2-1,H-3,4,1,-2,Borders*4096|Text_C*256|128);

  Set_DText(T_Box,BTN_Item,'      Player Name      ',System_Font,TE_Center);
  Set_DText(T_Box,BTB_Item,'Build castle troops',System_Font,TE_Left);
  Set_DText(T_Box,BTC_Item,'Build troops from',System_Font,TE_Left);
  Set_DText(T_Box,BTD_Item,'treasury money.',System_Font,TE_Left);
  Set_DText(T_Box,BTE_Item,'Show Map.',System_Font,TE_Left);
  Set_DText(T_Box,BTX_Item,'Exit',Small_Font,TE_Center);
  Set_DText(T_Box,Ta_Item,'Taxes         00000',System_Font,TE_Left);
  Set_DText(T_Box,Tr_Item,'Treasury      00000',System_Font,TE_Left);

  Center_Dialog(T_Box)
End;

Begin { Initialize }
  Init_Mouse;
  Hide_Mouse;

  Read_Color_Registers(DeskColors);
  For I:=0 to 15 do SetColor(I,0); { Make Screen Black while all of this }
                                   { is going on }

  Screen[addr1]:=0; Screen[addr2]:=0; { The Physical Screen }
  Init_Form(Map,M_Buf);
  Init_Form(Storage,St_Buf);
  Init_Form(Terrain,T_Buf);
  Init_Form(TitlePage,Title_Buf);

  Load_Terrain;
  Rest_scn; { Put Scn_Buf on Physical Screen }
  Copy_Rect(Screen,Terrain,0,0,0,0,320,200,3);

  Load_TitlePage;
  Rest_scn; { Put Scn_Buf on Physical Screen }
  Copy_Rect(Screen,TitlePage,0,0,0,0,320,200,3);

  Set_Color_Registers(TitleColors);
  Show_Mouse;

  Menu:=New_Menu(10,'  Game Info  ');
  P_Title:=Add_MTitle(Menu,' Play Game ');
  I_Title:=Add_MTitle(Menu,' Info ');
  P_Item :=Add_MItem(Menu,P_Title,'  Start New Game     ');
  C_Item :=Add_MItem(Menu,P_Title,'  Continue Old Game  ');
  Lo_Item:=Add_MItem(Menu,P_Title,'  Load Game          ');
  Sa_Item:=Add_MItem(Menu,P_Title,'  Save Game          ');
  D_Item :=Add_MItem(Menu,P_Title,'---------------------');
  S_Item :=Add_MItem(Menu,P_Title,'  Show Scores        ');
  D2_Item:=Add_MItem(Menu,P_Title,'---------------------');
  Q_Item :=Add_MItem(Menu,P_Title,'  Quit               ');
  B_Item :=Add_MItem(Menu,I_Title,'  Background   ');
  Cr_Item:=Add_MItem(Menu,I_Title,'  Credits      ');
  In_Item:=Add_MItem(Menu,I_Title,'  Instructions ');

  Menu_Disable(Menu,C_Item);
  Menu_Disable(Menu,D_Item);
  Menu_Disable(Menu,D2_Item);
  Menu_Disable(Menu,S_Item);
  Menu_Disable(Menu,Sa_Item);

  Init_BTBox;

  T_Effects[ 0]:=1.1;  { Clear }
  T_Effects[ 1]:=1.2;  { Forrest }
  T_Effects[ 2]:=1.5;  { Village }
  T_Effects[ 3]:=1.4;  { Swamp }
  T_Effects[ 4]:=0.9;  { Lake }
  T_Effects[ 5]:=3.0;  { Castle }
  T_Effects[ 6]:=3.0;  { Castle }
  T_Effects[ 7]:=3.0;  { Castle }
  T_Effects[ 8]:=3.0;  { Castle }
  T_Effects[ 9]:=1.3;  { Ruined Vilage }
  T_Effects[10]:=0.0;  { Bay }
  T_Effects[11]:=0.0;  { Flooded Swamp }
  T_Effects[12]:=0.0;  { Mountians }
  T_Effects[13]:=1.1;  { Dry Lake }

  P_Name[ 0]:='Independent';
  P_Name[ 5]:='Bandits';

End;

Procedure Get_Players;
Var B,D_Item,H: Integer;
    N_Item: Array[1..MaxPlayers] of Integer;
    Num: Str255;
    P: Integer;
    Pl_Box,Pn_Box: Dialog_Ptr;
    Pn_Item,T_Item,W,X_Item: Integer;
Begin
  W:=24;
  H:=6;
  Pn_Box:=New_Dialog(4,0,0,W,H);
  Pn_Item:=Add_DItem(Pn_Box,G_FText,Editable,1,1,W-2,1,
                     0,Borders*4096|Text_C*256|128);
  D_Item:=Add_DItem(Pn_Box,G_BoxText,Default|Selectable|Exit_Btn,
                    W div 2-3,H-2,6,1,
                    -3,Borders*4096|Text_C*256);
  Set_DEdit(Pn_Box,Pn_Item,'How many players ?  _','9','',System_Font,
            TE_Left);
  Set_DText(Pn_Box,D_Item,' Done ',System_Font,TE_Center);
  Center_Dialog(Pn_Box);
  Repeat
    B:=Do_Dialog(Pn_Box,Pn_Item);
    Get_DEdit(Pn_Box,Pn_Item,Num);
    Pn:=Val(Num)
  Until (Pn<=MaxPlayers) and (Pn>0);
  End_Dialog(Pn_Box);
  Delete_Dialog(Pn_Box);

  W:=24;
  H:=7+Pn;
  Pl_Box:=New_Dialog(8,0,0,W,H);
  T_Item:=Add_DItem(Pl_Box,G_BoxText,None,1,1,W-2,2,
                    2,Borders*4096|Text_C*256|3*16|Fill);
  For P:=1 to Pn do
    N_Item[P]:=Add_DItem(Pl_Box,G_FText,Editable,2,P+3,W-2,1,
                         0,Borders*4096|Text_C*256|128);
  X_Item:=Add_DItem(Pl_Box,G_BoxText,Selectable|Exit_Btn,W div 2-3,H-2,6,1,
                   -2,Borders*4096|Text_C*256);
  Set_DText(Pl_Box,T_Item,' The Players ',System_Font,TE_Center);
  For P:=1 to Pn do Set_DEdit(Pl_Box,N_Item[P],'Name: _____________',
                                                     'aaaaaaaaaaaaa',
                                                     '',System_Font,TE_Left);
  Set_DText(Pl_Box,X_Item,' Done ',System_Font,TE_Center);
  Center_Dialog(Pl_Box);
  B:=Do_Dialog(Pl_Box,N_Item[1]);
  For P:=1 to Pn do Get_DEdit(Pl_Box,N_Item[P],P_Name[P]);

  P_Color[Pn+1]:=13;
  P_Name [Pn+1]:='Bandits';

  End_Dialog(Pl_Box);
  Delete_Dialog(Pl_Box);

End;

Procedure Clear_Forrest(X,Y: Integer);
Var N: Integer;
Begin
  For N:=1 to Rand(9) do
    Begin
      Case Rand(4) of
          0: X:=X-1;
          1: Y:=Y-1;
          2: X:=X+1;
          3: Y:=Y+1
        End;
      If X<0 then X:=0;
      If Y<0 then Y:=0;
      If X>Mx then X:=Mx;
      If Y>My then Y:=My;
      If Tiles[X,Y]=1 then Tiles[X,Y]:=0
    End
End;

{

+----------------+---------+---------------+
| Terrain        |  Tile   | Defender Mult |
+----------------+---------+---------------+
| Clear          |  0      |     1.1       |
| Forrest        |  1      |     1.2       |
| Village        |  2      |     1.5       |
| Swamp          |  3      |     1.4       |
| Lake           |  4      |     0.9       |
| Castles        |  5..8   |     3.0       |
| Ruined Village |  9      |     1.3       |
| Bay            | 10      |     0.0       |
| Flooded Swamp  | 11      |     0.0       |
| Mountians      | 12      |     0.0       |
| Dry Lake       | 13      |     1.1       |
+----------------+---------+---------------+

}

Procedure Survey;
Var X,Y: Integer;
Begin
  For X:=1 to Mx-1 do
    For Y:=1 to My-1 do
      Begin
        If (Tiles[X,Y]=4) and
          ((Tiles[X,Y-1]=10) or (Tiles[X,Y+1]=10) or
           (Tiles[X-1,Y]=10) or (Tiles[X+1,Y]=10))
           then Tiles[X,Y]:=10; { Bay }
      End;
  For X:=0 to Mx do
    For Y:=0 to My do
      If (Tiles[X,Y]=1) and (Pop[X,Y]>0) then Tiles[X,Y]:=0; { Clear Forest }
  For X:=0 to Mx do
    For Y:=0 to My do
      Begin
        If (Tiles[X,Y]=9) and (Pop[X,Y]=0) then Tiles[X,Y]:=0; { Clear Ruins }
        If (Tiles[X,Y] in [0,1]) and (Pop[X,Y]>2) then { New Village }
          Begin
            Tiles[X,Y]:=2;
            Clear_Forrest(X,Y);
          End;
        If (Tiles[X,Y]=2) and (Pop[X,Y]=0) then Tiles[X,Y]:=9; { New Ruins }
      End
End;

Procedure Generate_Terrain;
Var D,I,J,N: Integer;
    X,Y: Integer;
Begin
{ Forrest }
  For X:=0 to Mx do For Y:=0 to My do Tiles[X,Y]:=1;
{ Lakes and Bays }
  For I:=0 to Rand(7) do
    Begin
      X:=Rand(Mx+1);
      Y:=Rand(My+1);
      If (X=0) or (X=Mx) or (Y=0) or (Y=My)
        Then Tiles[X,Y]:=10
        Else
          If (Tiles[X-1,Y]=10) or (Tiles[X+1,Y]=10) or
             (Tiles[X,Y-1]=10) or (Tiles[X,Y+1]=10)
            Then Tiles[X,Y]:=10
            Else Tiles[X,Y]:=4
    End;
{ Mountians }
  For I:=0 to Rand(3) do
    Begin
      X:=Mx div 2 - Rand(2) + Rand(2);
      Y:=My div 2 - Rand(2) + Rand(2);
      Tiles[X,Y]:=12
    End;
{ The Swamps }
  For I:=0 to Rand (5) do
    Begin
      X:=Rand(Mx+1);
      Y:=Rand(My+1);
      N:=0;
      Repeat
        If (Tiles[X,Y] in [0,1]) Then Tiles[X,Y]:=3;
        Case Rand(4) of
            0: X:=X-1;
            1: Y:=Y-1;
            2: X:=X+1;
            3: Y:=Y+1
          End;
        N:=N+1;
      Until (X<0) or (Y<0) or (X>Mx) or (Y>My) or (N>Rand(5));
    End;

{ Castles }
  Tiles[Rand(Mx div 2),Rand(My div 2)]:=5;
  Tiles[Mx div 2+Rand(Mx div 2)+1,My div 2+Rand(My div 2)+1]:=6;
  If Pn>2 Then Tiles[Mx div 2+Rand(Mx div 2)+1,Rand(My div 2)]:=7;
  If Pn>3 Then Tiles[Rand(Mx div 2),My div 2+Rand(My div 2)+1]:=8;
End;

Procedure Pop_Generate;
Var I,M,N: Integer;
    Pop_Count: Integer;
    Regional_Pop: Integer;
    X,Y: Integer;
Begin
  Regional_Pop:=Rand(8)+Rand(8)+Rand(8)+Rand(8)+6;
  For X:=0 to Mx do For Y:=0 to My do Pop[X,Y]:=0;
  For X:=0 to Mx do
    For Y:=0 to My do
      If Tiles[X,Y] in [5..8] then
        Begin
          Pop_Count:=0;
          Repeat
            M:=X+Rand(3)-Rand(3);
            N:=Y+Rand(3)-Rand(3);
            If (M>=0) and (N>=0) and (M<=Mx) and (N<=My) Then
              If Tiles[M,N] in [0,1,5..8] then
                Begin
                  Pop_Count:=Pop_Count+1;
                  Pop[M,N]:=Pop[M,N]+1;
                End;
          Until Pop_Count>=Regional_Pop;
        End;
End;

Procedure Setup_Castles;
Var P,X,Y: Integer;
Begin
  P:=1;
  For X:=0 to Mx do
    For Y:=0 to My do
      Begin
        If (Tiles[X,Y] in [5..8]) and (P<=Pn) then
          Begin
            Owner[X,Y]:=P;
            Troops[X,Y]:=10;
            Gold[P]:=0;
            P:=P+1
          End Else
            Begin
              Owner[X,Y]:=0;
              Troops[X,Y]:=0
            End
      End
End;

Procedure Setup_Bandits;
Var X,Y: Integer;
Begin
  For X:=0 to Mx do
    For Y:=0 to My do
      If (Rand(3)=0) and (Tiles[X,Y]=1) then
        Begin
          Owner[X,Y]:=Pn+1;
          Troops[X,Y]:=1
        End
End;

Procedure ROrder;
Var I,P,T,Q: Integer;
Begin
  For P:=0 to Pn+1 do Order[P]:=P;
  For I:=0 to 4*Pn do
    Begin
      P:=Rand(Pn+1)+1;
      Q:=Rand(Pn+1)+1;
      T:=Order[P];
      Order[P]:=Order[Q];
      Order[Q]:=T
    End
End;

Procedure Setup;
Begin
  Generate_Terrain;
  Pop_Generate;
  Setup_Castles;
  Survey;
  Setup_Bandits;
  Year:=1;
  Month:=1;
  Campaigns:=Rand(3)+Rand(3)+2;
  ROrder;
  P:=1;
End;

Procedure Outside;
Var Dummy,Event: Integer;
    Msg: Message_Buffer;
    Ox,Oy: Integer;

Procedure Show_Troops(X,Y: Integer);
Var F: Integer;
    TStr: Str255;
Begin
  If Troops[X,Y]<>0 then
    Begin
      Case Owner[X,Y] of
          1: F:=  5;
          2: F:= 42;
          3: F:=175;
          4: F:=187
        End;
      If (Owner[X,Y]>Pn) or (Owner[X,Y]<1) then F:=240;
      Text_Color(P_Color[Owner[x,y]]);
      Text_Height(4);
      Str(Troops[X,Y],TStr);
      TStr:=Concat(Chr(F),TStr);
      If Not ((Owner[X,Y]=Pn+1) and (Tiles[X,Y] in [1,3])) then
        Draw_String(X*TS+Ox+1,Y*TS+Oy+5,TStr)
    End
End;

Procedure Show_Pop(X,Y: Integer);
Var PStr: Str255;
Begin
  Text_Color(1);
  Text_Height(4);
  If Pop[X,Y]>0 then
    Begin
      Str(Pop[X,Y],PStr);
      Draw_String(X*TS+Ox+1,(Y+1)*TS+Oy-3,PStr)
    End
End;

Procedure Draw_Terrain;
Var I,Sx,Sy,X,Y: Integer;
Begin
  Paint_Color(11); { Sea Blue }
  Paint_Style(1);
  Paint_Rect(0,0,320,200);
  For X:=0 to Mx do
    For Y:=0 to My do
      Begin
        Sx:=Rand(18);
        Sy:=Rand(18);
        Case Tiles[X,Y] of
{Clear}     0: Copy_Rect(Terrain,Screen,  4+Sx, 4+Sy,X*TS+Ox,Y*TS+Oy,TS,TS,3);
{Forest}    1: Copy_Rect(Terrain,Screen, 55+Sx, 4+Sy,X*TS+Ox,Y*TS+Oy,TS,TS,3);
{Village}   2: Copy_Rect(Terrain,Screen,113+Sx, 4+Sy,X*TS+Ox,Y*TS+Oy,TS,TS,3);
{Swamp}     3: Copy_Rect(Terrain,Screen,167+Sx, 4+Sy,X*TS+Ox,Y*TS+Oy,TS,TS,3);
{Lake}   4,13: Copy_Rect(Terrain,Screen,   250,   10,X*TS+Ox,Y*TS+Oy,TS,TS,3);
{Castle1}   5: Copy_Rect(Terrain,Screen,    15,   72,X*TS+Ox,Y*TS+Oy,TS,TS,3);
{Castle2}   6: Copy_Rect(Terrain,Screen,    50,   72,X*TS+Ox,Y*TS+Oy,TS,TS,3);
{Castle3}   7: Copy_Rect(Terrain,Screen,    86,   73,X*TS+Ox,Y*TS+Oy,TS,TS,3);
{Castle4}   8: Copy_Rect(Terrain,Screen,   122,   73,X*TS+Ox,Y*TS+Oy,TS,TS,3);
{Ruins}     9: Copy_Rect(Terrain,Screen,170+Sx,65+Sy,X*TS+Ox,Y*TS+Oy,TS,TS,3);
{Bay}      10: Copy_Rect(Terrain,Screen,   240,   75,X*TS+Ox,Y*TS+Oy,TS,TS,3);
{Flooded Swamp }
           11: Copy_Rect(Terrain,Screen,   250,   10,X*TS+Ox,Y*TS+Oy,TS,TS,3);
{ Mountians }
           12: Copy_Rect(Terrain,Screen,283-Rand(3)+Rand(3),
                                 68-Rand(3)+Rand(3),X*TS+Ox,Y*TS+Oy,TS,TS,3);
          End
      End
End;

Procedure Do_Colors;
Const C=125;
Begin
  If Snow then
    Begin
      Set_Color( 3,C*7,C*7,C*7);
      Set_Color( 4,C*7,C*7,C*7);
      Set_Color( 6,C*7,C*7,C*7);
      Set_Color( 8,C*7,C*7,C*7);
      Set_Color( 9,C*7,C*7,C*7);
      Set_Color(13,C*7,C*7,C*7);
      Set_Color(14,C*7,C*7,C*7)
    End;
  If Dry then
    Begin
      Set_Color( 8,C*4,C*4,C*1);
      Set_Color(14,C*5,C*3,C*0)
    End;
  P_Color[ 0]:= 1;
  P_Color[ 1]:= 5;
  P_Color[ 2]:=10;
  P_Color[ 3]:=12;
  P_Color[ 4]:=15;
  P_Color[Pn+1]:=13;
End;

Procedure Draw_Map;
Var X,Y: Integer;
Begin
  Hide_Mouse;
  Set_Color_Registers(TerrainColors);
  Ox:=(320-TS*(Mx+1)) div 2;
  Oy:=8;
  Draw_Terrain;
  Copy_Rect(Screen,Map,0,0,0,0,320,200,3); { Store Map Picture }
  For Y:=0 to My do For X:=0 to Mx do Show_Pop(X,Y);
  For Y:=0 to My do For X:=0 to Mx do Show_Troops(X,Y);
  Show_Mouse
End;

Procedure Play_Game;
Const C=125;
Var B,H,M_Item,P_Item: Integer;
    Stn: String;
    Sx,Sy,W,X,X_Item,Y: Integer;
    Next: Boolean;

Function Move_Troops(P: Integer): Integer;
Var B,Fwx,Fwy,Fwh,Fww,FX,FY: Integer;
    Stf,Stn,Stt,Stx,Sty: Str255;
    Twx,Twy,Twh,Tww,TX,TY,X,Y: Integer;

Function GetCoords: Integer;
Label 1;
Const H=19;          W=312;         X=5;         Y=181;
      ExitBH=11;     ExitBW=33;     ExitBX=279;  ExitBY=185;
      PassBH=ExitBH; PassBW=ExitBW; PassBX=241;  PassBY=ExitBY;
Var B,Dummy,Event,GC,Key,Mox,Moy: Integer;
    Msg: Message_Buffer;

Procedure GC_Box;
Begin
  Hide_Mouse;
     { Whole Box }
  Paint_Outline(True);
  Paint_Color(Borders);
  Paint_Style(1);
  Paint_Rect(X,Y,W,H);
  Paint_Color(Fill);
  Paint_Style(FillPat);
  Paint_Rect(X+2,Y+2,W-4,H-4);

     { Pass Button }
  Paint_Color(Borders);
  Paint_Style(1);
  Paint_Rect(PassBX,PassBY,PassBW,PassBH);
  Paint_Color(0);
  Paint_Rect(PassBX+2,PassBY+2,PassBW-4,PassBH-4);
  Text_Color(Text_C);
  Draw_String(PassBX+5,PassBY+7,'Pass');

     { Exit Button }
  Paint_Color(Borders);
  Paint_Style(1);
  Paint_Rect(ExitBX,ExitBY,ExitBW,ExitBH);
  Paint_Color(0);
  Paint_Rect(ExitBX+2,ExitBY+2,ExitBW-4,ExitBH-4);
  Text_Color(Text_C);
  Draw_String(ExitBX+5,ExitBY+7,'Exit');

  Show_Mouse
End;

Begin { GetCoords }
  GC:=0;
  GC_Box;
  Stn:=P_Name[P];
  Stf:='From ?';
  Text_Color(P_Color[P]);
  Draw_String(X+   6,Y+10,Stn);
  Text_Color(Text_C);
  Draw_String(X+11*8-1,Y+10,Stf);

  Show_Mouse;
  Repeat
    Repeat
      Event:=Get_Event(E_Button,1,1,1,0,
                       False,0,0,0,0,False,0,0,0,0,
                       Msg,Key,Dummy,Dummy,Mox,Moy,Dummy);
      If (Mox>=PassBX)  and (Mox<=PassBX+PassBW)   and
         (Moy>=PassBY)  and (Moy<=PassBY+PassBH)   Then GC:=G_Pass;
      If (Mox>=ExitBX)  and (Mox<=ExitBX+ExitBW)   and
         (Moy>=ExitBY)  and (Moy<=ExitBY+ExitBH)   Then GC:=G_Exit;
      If GC<0 then Goto 1;
      FX:=Trunc((Mox-Ox)/Ts); Str(FX,Stx);
      FY:=Trunc((Moy-Oy)/Ts); Str(FY,Sty);
      If (FX>=0) and (FY>=0) and (FX<=Mx) and (FY<=My)
        then Stf:=Concat('From: ',Stx,'-',Sty,' ')
        Else Stf:='From: The Sea ? ';
      If (FX>=0) and (FY>=0) and (FX<=Mx) and (FY<=My) Then
        If Owner[Fx,Fy]<>P then Stf:='You don''t own that area.';

      GC_Box;

      Text_Color(P_Color[P]);
      Hide_Mouse;
      Draw_String(X+6,Y+10,Stn);
      Text_Color(Text_C);
      Draw_String(X+11*8-1,Y+10,Stf);
      Show_Mouse;

    Until ((FX>=0) and (FY>=0) and (FX<=Mx) and (FY<=My));
  Until (Owner[Fx,Fy]=P);
  Hide_Mouse;
  Stt:='To ?';

  GC_Box;
  Text_Color(P_Color[P]);
  Draw_String(X+   6,Y+10,Stn);
  Text_Color(Text_C);
  Draw_String(X+11*8-1,Y+10,Stt);

  Show_Mouse;
  Repeat
    Repeat
      Event:=Get_Event(E_Button|E_Keyboard,1,1,1,0,
                       False,0,0,0,0,False,0,0,0,0,
                       Msg,Key,Dummy,Dummy,Mox,Moy,Dummy);
      If (Mox>=ExitBX)  and (Mox<=ExitBX+ExitBW)   and
         (Moy>=ExitBY)  and (Moy<=ExitBY+ExitBH)   Then GC:=G_Exit;
      If (Mox>=PassBX)  and (Mox<=PassBX+PassBW)   and
         (Moy>=PassBY)  and (Moy<=PassBY+PassBH)   Then GC:=G_Pass;
      If GC<0 then Goto 1;
      TX:=Trunc((Mox-Ox)/Ts); Str(TX,Stx);
      TY:=Trunc((Moy-Oy)/Ts); Str(TY,Sty);
      If (TX<FX+2) and (TX>FX-2) and (Ty<Fy+2) and (Ty>Fy-2)
          Then Stt:=Concat('To: ',Stx,'-',Sty,' ')
          Else Stt:='Only one space.';
      If (TX<0) or (TY<0) or (TX>Mx) or (TY>My)
          then Stt:='Not to the sea.'
          else
            Begin
              If (Tiles[Tx,Ty] in [4,10,11]) then Stt:='Too wet.';
              If (Tiles[Tx,Ty]=12) then Stt:='Impassable';
            End;
      GC_Box;
      Text_Color(P_Color[P]);
      Draw_String(X+   6,Y+10,Stn);
      Text_Color(Text_C);
      Draw_String(X+11*8-1,Y+10,Stt);
    Until ((TX<FX+2) and (TX>FX-2) and (Ty<Fy+2) and (Ty>Fy-2) and
           (TX>=0)   and (TY>=0)   and (TX<=Mx)  and (TY<=My))
  Until (Tiles[Tx,Ty] in [0..3,5..9,13]) or (Snow and (Tiles[Tx,Ty]=4));
  GC:=1;
  Hide_Mouse;
  Paint_Style(1); { Redraw Sea }
  Paint_Color(11);
  Paint_Rect(X,Y,W,H);
1: GetCoords:=GC
End;

Procedure ShowStats(A: Integer);
Var Num,St: Str255;
Begin
  Paint_Style(1);
  Paint_Color(Borders);
  Paint_Rect(FwX,FwY,FwW,FwH);
  Paint_Color(Fill);
  Paint_Style(FillPat);
  Paint_Rect(FwX+3,FwY+3,FwW-6,FwH-6);

  Text_Color(Text_C);
  Draw_String(Fwx+8,Fwy+ 8,Stf);
  Copy_Rect(Map,Screen,Fx*Ts+Ox-1,Fy*Ts+Oy-1,
            Fwx+Fww div 2-Ts div 2,Fwy+16,TS+2,TS+2,3);
  St:=Concat('Owner: ',P_Name[Owner[Fx,Fy]]);
  Draw_String(Fwx+8,Fwy+Ts+24,St);

  Str(Troops[Fx,Fy],Num);
  St:=Concat('Troops: ',Num);
  Draw_String(Fwx+8,Fwy+Ts+32,St);

  Str(A,Num);
  St:=Concat('Attacking: ',Num);
  Draw_String(Fwx+8,Fwy+Ts+40,St);

  Paint_Style(1);
  Paint_Color(Borders);
  Paint_Rect(TwX,TwY,TwW,TwH);
  Paint_Color(Fill);
  Paint_Style(FillPat);
  Paint_Rect(TwX+3,TwY+3,TwW-6,TwH-6);

  Draw_String(Twx+8,Twy+ 8,Stt);
  Copy_Rect(Map,Screen,Tx*Ts+Ox-1,Ty*Ts+Oy-1,
            Twx+Tww div 2-Ts div 2,Twy+16,TS+2,TS+2,3);
  St:=Concat('Owner: ',P_Name[Owner[Tx,Ty]]);
  Draw_String(Twx+8,Twy+Ts+24,St);
  Str(Troops[Tx,Ty],Num);
  St:=Concat('Troops: ',Num);
  Draw_String(Twx+8,Twy+Ts+32,St)
End;

Procedure Fight(A:Integer);
Var A_Item,B_Item,R_Item: Integer;
    F_Box: Dialog_Ptr;
    B,D,H,W,X,Y: Integer;
Begin
  H:=3;
  W:=Fww div 8 - 2;
  X:=Fwx div 8 + 1;
  Y:=(Fwy+Fwh) div 8 - 3;
  F_Box:=New_Dialog(5,X,Y,W,H);
  B_Item:=Add_DItem(F_Box,G_Box,None,
                    0,0,W,H,
                   -2,Borders*4096|Text_C*256|3*16|Fill);
  A_Item:=Add_DItem(F_Box,G_BoxText,Selectable|Default|Exit_Btn,
                      W div 3-4,1,6,1,
                    -3,Borders*4096|Text_C*256);
  R_Item:=Add_DItem(F_Box,G_BoxText,Selectable|Exit_Btn,
                    2*W div 3-2,1,6,1,
                    -2,Borders*4096|Text_C*256);
  Set_DText(F_Box,A_Item,'Attack',Small_Font,TE_Center);
  Set_DText(F_Box,R_Item,'Retreat',Small_Font,TE_Center);
  Repeat
    ShowStats(A);
    Show_Mouse;
    If A<>0 then B:=Do_Dialog(F_Box,0);
    Obj_SetState(F_Box,A_Item,Normal,False);
    Obj_SetState(F_Box,R_Item,Normal,False);
    Hide_Mouse;
    If B<>R_Item then
      Begin
        D:=Troops[Tx,Ty]-Round(A/2/T_Effects[Tiles[Tx,Ty]]); If D<1 then D:=0;
        A:=A-Round(Troops[Tx,Ty]/2*T_Effects[Tiles[Tx,Ty]]); If A<1 then A:=0;
        Troops[Tx,Ty]:=D
      End;
  Until (B=R_Item) or (A<1) or (Troops[Tx,Ty]<1);
  If Troops[Tx,Ty]=0 then Owner[Tx,Ty]:=0;
  If B=R_Item then Begin Troops[Fx,Fy]:=Troops[Fx,Fy]+A; A:=0 End;
  If A<>0     then Begin Troops[Tx,Ty]:=A; Owner[Tx,Ty]:=P End;
  End_Dialog(F_Box);
  Delete_Dialog(F_Box)
End;

Function SnowLost(Troops: Integer): Integer;
Var B,H,L: Integer;
    Num: Str255;
    S_Box: Dialog_Ptr;
    S_Item,X_Item: Integer;
    SStr,TStr: Str255;
    T_Item,W: Integer;
Begin
  L:=0;
  If Troops>Rand(20) then L:=1;
  If Troops>10 then L:=Round(Rand(10)/100*Troops);

  H:=6; W:=34;
  S_Box:=New_Dialog(4,X,Y,W,H);
  S_Item:=Add_DItem(S_Box,G_Text,None,
                    1,1,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  T_Item:=Add_DItem(S_Box,G_Text,None,
                    1,2,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  X_Item:=Add_DItem(S_Box,G_BoxText,Selectable|Default|Exit_Btn,
                    W div 2-9,4,18,1,
                    -2,Borders*4096|Text_C*256|128);

  Str(L,Num);
  SStr:=Concat(Num,' of your troops were lost');
  Case Rand(4) of
      0: TStr:='missing after a blizzard.';
      1: TStr:='in the snow.';
      2: TStr:='when they ran out of supplies.';
      3: TStr:='they mysteriously dissappeared.'
    End;

  Set_DText(S_Box,S_Item,SStr,System_Font,TE_Left);
  Set_DText(S_Box,T_Item,TStr,System_Font,TE_Left);
  Set_DText(S_Box,X_Item,'Shiver.',System_Font,TE_Center);
  Center_Dialog(S_Box);
  Show_Mouse;
  If L>0 then B:=Do_Dialog(S_Box,0);
  Hide_Mouse;
  End_Dialog(S_Box);
  Delete_Dialog(S_Box);
  SnowLost:=L
End;

Function SwampLost(Troops: Integer): Integer;
Var B,H,L,W,X,Y: Integer;
    Num,SStr,TStr: Str255;
    S_Box: Dialog_Ptr;
    S_Item,T_Item,X_Item: Integer;
Begin
  L:=0;
  If Troops>Rand(10) then L:=1;
  If Troops>10 then L:=Round(Rand(20)/100*Troops);

  H:=6; W:=30;
  S_Box:=New_Dialog(4,X,Y,W,H);
  S_Item:=Add_DItem(S_Box,G_Text,None,
                    1,1,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  T_Item:=Add_DItem(S_Box,G_Text,None,
                    1,2,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  X_Item:=Add_DItem(S_Box,G_BoxText,Selectable|Default|Exit_Btn,
                    W div 2-9,4,18,1,
                    -2,Borders*4096|Text_C*256|128);

  Str(L,Num);
  SStr:=Concat(Num,' of your troops were lost');
  Case Rand(4) of
      0: TStr:='in the quicksand.';
      1: TStr:='attacked by Swamp Trolls.';
      2: TStr:='to the Creaping Crud.';
      3: TStr:='they mysteriously dissappeared';
    End;

  Set_DText(S_Box,S_Item,SStr,System_Font,TE_Left);
  Set_DText(S_Box,T_Item,TStr,System_Font,TE_Left);
  Set_DText(S_Box,X_Item,'Ahhhhrrrrgggg!!!',System_Font,TE_Center);
  Center_Dialog(S_Box);
  Show_Mouse;
  If L>0 then B:=Do_Dialog(S_Box,0);
  Hide_Mouse;
  Delete_Dialog(S_Box);
  SwampLost:=L
End;

Procedure Get_Troops;
Var A,B,H,Lost,N_Item,W,X,Y: Integer;
    GT_Box: Dialog_Ptr;
    Num: Str255;
Begin
  H:=3;
  W:=Fww div 8 - 2;
  X:=Fwx div 8 + 1;
  Y:=(Fwy+Fwh) div 8 - 3;
  GT_Box:=New_Dialog(5,X,Y,W,H);
  N_Item:=Add_DItem(GT_Box,G_FBoxText,Default|Editable,0,0,W,H,
                    3,Borders*4096|Text_C*256|128);
  Set_DEdit(GT_Box,N_Item,'How Many ? ___','999','',System_Font,TE_Center);
  Repeat
    Show_Mouse;
    B:=Do_Dialog(GT_Box,N_Item);
    Hide_Mouse;
    Get_DEdit(GT_Box,N_Item,Num);
    A:=Val(Num);
  Until A<=Troops[Fx,Fy];

  End_Dialog(GT_Box);
  Delete_Dialog(GT_Box);
  Troops[Fx,Fy]:=Troops[Fx,Fy]-A;

  If (Tiles[Tx,Ty]=3) and Not Snow and Not Dry
    then Lost:=SwampLost(A) Else Lost:=0;
  If Snow Then Lost:=Lost+SnowLost(A-Lost);
  If (A>0) and (A=Lost) Then
    Begin
      A:=0;
      Next:=True
    End Else
      A:=A-Lost;

  If A>0 then
    If (Owner[Tx,Ty]=0) or (Owner[Tx,Ty]=P) Then
      Begin
        Owner[Tx,Ty]:=P;
        Troops[Tx,Ty]:=Troops[Tx,Ty]+A;
        If Troops[Fx,Fy]=0 then Owner[Fx,Fy]:=0;
        Next:=True
      End Else
      Begin
        Fight(A);
        Next:=True
      End
End;

Begin { Move_Troops }
  Fww:=144; Fwh:=104; Fwx:=320 div 4 - Fww div 2; Fwy:=200 div 2 - Fwh div 2;
  Tww:=Fww; Twh:=Fwh; Twx:=3 * 320 div 4 - Tww div 2; Twy:=Fwy;
  Hide_Mouse;
                 { Store Screen }
  Copy_Rect(Screen,Storage,Fwx-8,Fwy-8,Fwx-8,Fwy-8,Fww+16,Fwh+16,3);
  Copy_Rect(Screen,Storage,Twx-8,Twy-8,Twx-8,Twy-8,Tww+16,Twh+16,3);

  Show_Mouse;
  B:=GetCoords;
  If B=G_Pass Then Next:=True;
  If (B>=0) Then { Not Skiping or Exiting }
    Begin
      ShowStats(0);
      Get_Troops;
                { Restore Screen }
      Hide_Mouse;
      Copy_Rect(Storage,Screen,Fwx-8,Fwy-8,Fwx-8,Fwy-8,Fww+16,Fwh+16,3);
      Copy_Rect(Storage,Screen,Twx-8,Twy-8,Twx-8,Twy-8,Tww+16,Twh+16,3);
      Copy_Rect(Map,Screen,Fx*Ts+Ox,Fy*Ts+Oy,FX*TS+Ox,FY*TS+Oy,TS,TS,3);
      Show_Pop(FX,FY);
      Show_Troops(FX,FY);
      Copy_Rect(Map,Screen,Tx*Ts+Ox,Ty*Ts+Oy,TX*TS+Ox,TY*TS+Oy,TS,TS,3);
      Show_Pop(TX,TY);
      Show_Troops(TX,TY);
      Show_Mouse
    End;
  Move_Troops:=B
End;

Procedure Economics(P: Integer);
Var Castles,N,Tx,Ty,X,Y: Integer;
    Tax: Long_Integer;

Procedure GetSquare(Var Tx,Ty: Integer; Castle: Boolean);
Const H=19; W=312; X=5; Y=181;
Var Dummy,Event,Key,Mox,Moy: Integer;
    Error: Boolean;
    Msg: Message_Buffer;
    Stn,Stt: Str255;
Begin
  Hide_Mouse;
  Paint_Outline(True);
  Paint_Color(Borders);
  Paint_Style(1);
  Paint_Rect(X,Y,W,H);
  Paint_Color(Fill);
  Paint_Style(FillPat);
  Stn:=P_Name[P];
  Stt:='To ?';
  Repeat
    Error:=False;
    Paint_Rect(X+2,Y+2,W-4,H-4);
    Text_Color(P_Color[P]);
    Draw_String(X+8,Y+10,Stn);
    Text_Color(Text_C);
    Draw_String(X+12*8,Y+10,Stt);
    Show_Mouse;
    Event:=Get_Event(E_Button|E_Keyboard,1,1,1,0,
                     False,0,0,0,0,False,0,0,0,0,
                     Msg,Key,Dummy,Dummy,Mox,Moy,Dummy);
    Hide_Mouse;
    TX:=Trunc((Mox-Ox)/Ts);
    TY:=Trunc((Moy-Oy)/Ts);
    If (Tx<0) or (Tx>Mx) or (Ty<0) or (Ty>My) then
      Begin
        Error:=True;
        Stt:=' Too wet.';
        Tx:=0; Ty:=0
      End;
    If (Owner[Tx,Ty]<>P) and Not Error then
      Stt:=' You don''t own that area.';
    If Castle and Not (Tiles[Tx,Ty] in [5..8]) then
      Begin
        Error:=True;
        Stt:=' Castles only.'
      End;
  Until (Owner[Tx,Ty]=P) and Not Error;
  Paint_Style(1); { Redraw Sea }
  Paint_Color(11);
  Paint_Rect(X,Y,W,H);
  Show_Mouse
End;

Function Find_Castle(Var Tx,Ty: Integer): Integer;
Var C,X,Y: Integer;
Begin
  C:=0;
  For X:=0 to Mx do
    For Y:=0 to My do
      If (Owner[X,Y]=P) and (Tiles[X,Y] in [5..8]) then
        Begin
          Tx:=X; Ty:=Y; C:=C+1
        End;
  Find_Castle:=C
End;

Function Get_Number(Max: Long_Integer): Integer;
Var B,N,X,Y,W,H: Integer;
    G_Box: Dialog_Ptr;
    G_Item: Integer;
    HStr,MStr,NStr: Str255;
Begin
  H:=6;
  W:=26;
  G_Box:=New_Dialog(3,X,Y,W,H);
  G_Item:=Add_DItem(G_Box,G_FText,Editable,
                     1,1,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  X_Item:=Add_DItem(G_Box,G_BoxText,Selectable|Default|Exit_Btn,
                     W div 2-2,4,4,1,
                    -2,Borders*4096|Text_C*256|128);
  Long_Str(Max,MStr);
  HStr:=Concat('How Many (Max=',MStr,') ? ___');
  Set_DEdit(G_Box,G_Item,HStr,'999','',System_Font,TE_Center);
  Set_DText(G_Box,X_Item,'Done',Small_Font,TE_Center);
  Center_Dialog(G_Box);
  Repeat
    Obj_SetState(G_Box,X_Item,Normal,False);
    B:=Do_Dialog(G_Box,0);
    Get_DEdit(G_Box,G_Item,NStr);
    N:=Val(NStr)
  Until (N<=Max) and (N>=0);
  End_Dialog(G_Box);
  Delete_Dialog(G_Box);
  Get_Number:=N
End;

Procedure Build_Troops;
Var B,Event,H,W,X,Y: Integer;
    CStr,Num: Str255;
    Msg: Message_Buffer;
    N: Long_Integer;
Begin

  H:=17;
  W:=27;
  X:=20-W div 2;
  Y:=12-H div 2;

  Set_DText(T_Box,BTN_Item,P_Name[P],System_Font,TE_Center);

  Hide_Mouse;
  Copy_Rect(Screen,Storage,0,0,0,0,320,200,3);
  Show_Mouse;
  Show_mouse;

  Repeat
    If Tax<2000 then
      Begin
        Obj_SetState(T_Box,BTBB_Item,Shadowed|Disabled,False);
        Obj_SetState(T_Box,BTB_Item,Disabled,False);
      End Else
      Begin
        Obj_SetState(T_Box,BTBB_Item,Shadowed,False);
        Obj_SetState(T_Box,BTB_Item,Normal,False);
      End;
    If Gold[P]<2000 then
      Begin
        Obj_SetState(T_Box,BTCB_Item,Shadowed|Disabled,False);
        Obj_SetState(T_Box,BTC_Item,Disabled,False);
        Obj_SetState(T_Box,BTD_Item,Disabled,False);
      End Else
      Begin
        Obj_SetState(T_Box,BTCB_Item,Shadowed,False);
        Obj_SetState(T_Box,BTC_Item,Normal,False);
        Obj_SetState(T_Box,BTD_Item,Normal,False);
      End;
    Obj_SetState(T_Box,BTEB_Item,Shadowed,False);
    Obj_SetState(T_Box,BTX_Item,Shadowed,False);
    Long_Str(Tax,Num);
    CStr:=Concat('Taxes        ',Num);
    Set_DText(T_Box,Ta_Item,CStr,System_Font,TE_Left);
    Long_Str(Gold[P],Num);
    CStr:=Concat('Treasury     ',Num);
    Set_DText(T_Box,Tr_Item,CStr,System_Font,TE_Left);

    B:=Do_Dialog(T_Box,0);

    If B=BTBB_Item then
      Begin
        N:=Get_Number(Tax div 2000);
        Castles:=Find_Castle(Tx,Ty);
        Hide_mouse;
        Copy_Rect(Storage,Screen,(X-2)*8,(Y-1)*8,(X-2)*8,(Y-1)*8,
                 (W+2)*8,(H+3)*8,3);
        Show_Mouse;
        If (Castles>1) and (N>0) then GetSquare(Tx,Ty,True);
        Troops[Tx,Ty]:=Troops[Tx,Ty]+Int(N);
        Tax:=Tax-2000*N;
        Hide_mouse;
        Copy_Rect(Map,Screen,Tx*TS+Ox,Ty*TS+Oy,TX*TS+Ox,TY*TS+Oy,TS,TS,3);
        Show_Pop(TX,TY);
        Show_Troops(TX,TY);
        Copy_Rect(Screen,Storage,Tx*TS+Ox,Ty*TS+Oy,TX*TS+Ox,TY*TS+Oy,TS,TS,3);
        Show_Mouse;
      End;
    If B=BTCB_Item then
      Begin
        N:=Get_Number(Gold[P] div 2000);
        Hide_mouse;
        Copy_Rect(Storage,Screen,(X-2)*8,(Y-1)*8,(X-2)*8,(Y-1)*8,
                 (W+2)*8,(H+3)*8,3);
        Show_Mouse;
        If N>0 then GetSquare(Tx,Ty,False);
        Troops[Tx,Ty]:=Troops[Tx,Ty]+Int(N);
        Gold[P]:=Gold[P]-2000*N;
        Hide_mouse;
        Copy_Rect(Map,Screen,Tx*TS+Ox,Ty*TS+Oy,TX*TS+Ox,TY*TS+Oy,TS,TS,3);
        Show_Pop(TX,TY);
        Show_Troops(TX,TY);
        Copy_Rect(Screen,Storage,Tx*TS+Ox,Ty*TS+Oy,TX*TS+Ox,TY*TS+Oy,TS,TS,3);
        Show_Mouse
      End;
    If B=BTEB_Item then
      Begin
        Hide_mouse;
        Copy_Rect(Storage,Screen,(X-2)*8,(Y-1)*8,(X-2)*8,(Y-1)*8,
                 (W+2)*8,(H+3)*8,3);
        Show_Mouse;
        Event:=Get_Event(E_Button|E_Keyboard,1,1,1,0,
                         False,0,0,0,0,False,0,0,0,0,
                         Msg,Dummy,Dummy,Dummy,Dummy,Dummy,Dummy);
      End
  Until B=BTX_Item;
  End_Dialog(T_Box);
  Hide_mouse;
  Copy_Rect(Storage,Screen,0,0,0,0,320,180,3)
End;

Begin { Economics }
  Tax:=0;
  Castles:=Find_Castle(Tx,Ty);
  If Castles>0 then
    Begin
      For X:=0 to Mx do
        For Y:=0 to My do If Owner[X,Y]=P then Tax:=Tax+1000*Pop[X,Y];
      If Gold[P]+Tax>=2000 then Build_Troops;
      Gold[P]:=Gold[P]+Tax
    End;
  Next:=True;
End;

Function Count_Troops(P: Integer): Integer;
Var N,X,Y: Integer;
Begin
  N:=0;
  For X:=0 to Mx do
    For Y:=0 to My do If Owner[X,Y]=P then N:=N+Troops[X,Y];
  Count_Troops:=N
End;

Procedure Move_Bandits;
Var D,Dx,Dy,Fx,Fy,Loops: Integer;
    MPoints,MTroops,N: Integer;
    Passable: Boolean;
    Points: Array[0..Mx,0..My] of Integer;
    Sc,Tx,Ty,X,Y: Integer;
Begin
  Dx:=0; Dy:=0; Fx:=0; Fy:=0; Loops:=0;

                       { Get Point Value }
  For X:=0 to Mx do
    For Y:=0 to My do
      If Owner[X,Y]<>Pn+1
        then Points[X,Y]:= Round(3*Pop[X,Y]-Troops[X,Y]*T_Effects[Tiles[X,Y]])
        Else Points[X,Y]:=-Round(3*         Troops[X,Y]*T_Effects[Tiles[X,Y]]);
  Repeat
                        { Get From }
    MTroops:=0;
    For X:=0 to Mx do
      For Y:=0 to My do
        Begin
          If (Owner[X,Y]=PN+1) and (Troops[X,Y]>MTroops) then
            Begin
              MTroops:=Troops[X,Y];
              Fx:=X;
              Fy:=Y
            End
        End;
                        { Get To }
    MPoints:=0;
    For Y:=My downto 0 do
      For X:=Mx downto 0 do
        Begin
          If (Points[X,Y]>MPoints) then
            Begin
              MPoints:=Points[X,Y];
              Dx:=X;
              Dy:=Y
            End
        End;

    Tx:=Fx; Ty:=Fy;
    If Fx>Dx then Tx:=Fx-1;
    If Fy>Dy then Ty:=Fy-1;
    If Fx<Dx then Tx:=Fx+1;
    If Fy<Dy then Ty:=Fy+1;

    N:=Troops[Fx,Fy]-1; If N<1 then N:=0;
    If (Tiles[Tx,Ty] in [4,10,11,12]) then { Dont Move Into the water or Mts. }
      Begin
        Passable:=False;
        Points[Dx,Dy]:=-2000;
        Loops:=Loops+1;
      End Else Passable:=True;
  Until Passable or (Loops>Mx*My);

  If Passable then  { Move Troops }
    Begin
      If Owner[Tx,Ty]=Pn+1 then
        Begin
          Troops[Fx,Fy]:=Troops[Fx,Fy]-N;
          If Tiles[Tx,Ty]=3 then N:=Round(0.8*N); { Swamp Hazards }
          Troops[Tx,Ty]:=Troops[Tx,Ty]+N;
        End Else
        begin
          Troops[Fx,Fy]:=Troops[Fx,Fy]-N;
          If Tiles[Tx,Ty]=3 then N:=Round(0.8*N); { Swamp Hazards }

          D:=Troops[Tx,Ty]-Round(N/2/T_Effects[Tiles[Tx,Ty]]);
          If D<1 then D:=0;
          N:=N-Round(Troops[Tx,Ty]/2*T_Effects[Tiles[Tx,Ty]]);
          If N<1 then N:=0;

          If D=0 then
            Begin
              If N<>0 then Owner[Tx,Ty]:=PN+1;  { Victory! }
              Troops[Tx,Ty]:=N;
            End Else
            Begin
              Troops[Tx,Ty]:=D; { Retreat... }
              If D=0 then Owner[Tx,Ty]:=0;
              Troops[Fx,Fy]:=Troops[Fx,Fy]+N;
            End
        End;

                        { Redraw Screen }
      Copy_Rect(Map,Screen,FX*Ts+Ox,FY*Ts+OY,FX*TS+Ox,FY*TS+Oy,TS,TS,3);
      Show_Pop(FX,FY);
      Show_Troops(FX,FY);
      Copy_Rect(Map,Screen,TX*Ts+Ox,TY*Ts+Oy,TX*TS+Ox,TY*TS+Oy,TS,TS,3);
      Show_Pop(TX,TY);
      Show_Troops(TX,TY)
    End
End;

Procedure Add_Bandits(P: Integer);
Var X,Y: Integer;
Begin
  For X:=0 to Mx do
    For Y:=0 to My do
      If Owner[X,Y]=P then
        Begin
          Troops[X,Y]:=Troops[X,Y]+Pop[X,Y] div 3+Rand(Pop[X,Y] mod 2+2);
          If Tiles[X,Y] in [4,10,11,12] then Troops[X,Y]:=0;
          Copy_Rect(Map,Screen,X*Ts+Ox,Y*Ts+Oy,X*TS+Ox,Y*TS+Oy,TS,TS,3);
          Show_Pop(X,Y);
          Show_Troops(X,Y)
        End
End;

Procedure Fate;
Var N: Integer;

Procedure Curse;
Const Text_C=1;
Var A_Item,B_Item,C_Item,D_Item,X_Item: Integer;
    Blood: HeadType;
    Box: Dialog_Ptr;
    H,I,P,X,Y,W: Integer;
Begin
  Read_Color_Registers(Blood);
  For I:=0 to 15 do Blood[I+2]:=(Blood[I+2] & 3840);
  Fade_Color(Blood);
  For P:=1 to Pn do Gold[P]:=0;
  H:=9;
  W:=29;
  Box:=New_Dialog(6,X,Y,W,H);
  A_Item :=Add_DItem(Box,G_Text,None,
                     1,1,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  B_Item :=Add_DItem(Box,G_Text,None,
                     1,2,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  C_Item :=Add_DItem(Box,G_Text,None,
                     1,3,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  D_Item :=Add_DItem(Box,G_Text,None,
                     1,4,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  X_Item :=Add_DItem(Box,G_BoxText,Selectable|Exit_Btn|Default,
                     W div 2-9,H-2,18,1,
                    -3,Borders*4096|Text_C*256|128);
  Set_DText(Box,A_Item,'Fizzbin the Wizard casts',System_Font,TE_Left);
  Set_DText(Box,B_Item,'a curse on the Princes:',System_Font,TE_Left);
  Set_DText(Box,C_Item,'All of their gold turns to',System_Font,TE_Left);
  Set_DText(Box,D_Item,'Blood.',System_Font,TE_Left);
  Set_DText(Box,X_Item,' Blub Blub Blub ',System_Font,TE_Center);
  Center_Dialog(Box);
  Copy_Rect(Screen,Storage,0,0,0,0,320,200,3);
  Show_Mouse;
  B:=Do_Dialog(Box,0);
  Hide_mouse;
  End_Dialog(Box);
  Delete_Dialog(Box);
  Copy_Rect(Storage,Screen,0,0,0,0,320,200,3);
  Fade_Color(TerrainColors)
End;

Procedure Plauge;
Const Text=1;
Var A_Item,B_Item: Integer;
    C,H,I,X,Y,W,X_Item: Integer;
    Box: Dialog_Ptr;
    Darkness: HeadType;
Begin
  Read_Color_Registers(Darkness);
  For I:=0 to 15 do
    Begin
      C:=(Darkness[I+2] & 3840) div 256;
      Darkness[I+2]:=C*256+C*16+C
    End;
  Fade_Color(Darkness);
  H:=7;
  W:=29;
  Box:=New_Dialog(6,X,Y,W,H);
  A_Item :=Add_DItem(Box,G_Text,None,
                     1,1,W-2,1,
                    -2,Borders*4096|Text*256|128);
  B_Item :=Add_DItem(Box,G_Text,None,
                     1,2,W-2,1,
                    -2,Borders*4096|Text*256|128);
  X_Item :=Add_DItem(Box,G_BoxText,Selectable|Exit_Btn|Default,
                     W div 2-5,H-2,10,1,
                    -3,Borders*4096|Text*256|128);
  Set_DText(Box,A_Item,'Plague strikes throughout',System_Font,TE_Left);
  Set_DText(Box,B_Item,'the Land.',System_Font,TE_Left);
  Set_DText(Box,X_Item,' Groan... ',System_Font,TE_Center);
  Center_Dialog(Box);
  Copy_Rect(Screen,Storage,0,0,0,0,320,200,3);
  Show_Mouse;
  B:=Do_Dialog(Box,0);
  End_Dialog(Box);
  Delete_Dialog(Box);
  Hide_mouse;
  Copy_Rect(Storage,Screen,0,0,0,0,320,200,3);
  For X:=0 to Mx do
    For Y:=0 to My do
      Begin
        Pop[X,Y]:=Pop[X,Y] div 2;
        Troops[X,Y]:=Trunc(Troops[X,Y]*0.5);
        If Troops[X,Y]=0 then Owner[X,Y]:=0
      End;
  Survey;
  Draw_Terrain;
  Copy_Rect(Screen,Map,0,0,0,0,320,200,3); { Store Map Picture }
  For Y:=0 to My do For X:=0 to Mx do Show_Pop(X,Y);
  For Y:=0 to My do For X:=0 to Mx do Show_Troops(X,Y);
  Fade_Color(TerrainColors)
End;

Procedure Census;
Var A_Item,B_Item: Integer;
    Box: Dialog_Ptr;
    C,H,I: Integer;
    X,Y,W,X_Item: Integer;
Begin
  H:=7;
  W:=32;
  Box:=New_Dialog(6,X,Y,W,H);
  A_Item :=Add_DItem(Box,G_Text,None,
                     1,1,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  B_Item :=Add_DItem(Box,G_Text,None,
                     1,2,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  X_Item :=Add_DItem(Box,G_BoxText,Selectable|Exit_Btn|Default,
                     W div 2-5,H-2,10,1,
                    -3,Borders*4096|Text_C*256|128);
  Set_DText(Box,A_Item,'Latest census shows population',System_Font,TE_Left);
  Set_DText(Box,B_Item,'increases throughout the land.',System_Font,TE_Left);
  Set_DText(Box,X_Item,' Hurrah! ',System_Font,TE_Center);
  Center_Dialog(Box);
  Copy_Rect(Screen,Storage,0,0,0,0,320,200,3);
  Show_Mouse;
  B:=Do_Dialog(Box,0);
  End_Dialog(Box);
  Delete_Dialog(Box);
  Hide_mouse;
  Copy_Rect(Storage,Screen,0,0,0,0,320,200,3);
  For X:=0 to Mx do
    For Y:=0 to My do
      Case Tiles[X,Y] of
{ Clear }                      0: Pop[X,Y]:=Pop[X,Y]+Rand(2);
{ Villages & Castles } 2,5,6,7,8: Pop[X,Y]:=Pop[X,Y]+Rand(2)+Rand(2);
        End;
  Survey;
  Draw_Terrain;
  Copy_Rect(Screen,Map,0,0,0,0,320,200,3); { Store Map Picture }
  For Y:=0 to My do For X:=0 to Mx do Show_Pop(X,Y);
  For Y:=0 to My do For X:=0 to Mx do Show_Troops(X,Y);
End;

Procedure Wet_Winter;
Const C=125;
Var A_Item,B_Item,X_Item: Integer;
    Box: Dialog_Ptr;
    H: Integer;
    W,X,Y: Integer;
    Xc,Yc: Integer;
Begin
  H:=7;
  W:=32;
  Wet:=True;
  For Xc:=0 to Mx do
    For Yc:=0 to My do
      If Tiles[Xc,Yc]=3 then
        Begin
          Tiles [Xc,Yc]:=11;
          Troops[Xc,Yc]:=0; { Drown troops in swamp }
          Owner [Xc,Yc]:=0;
          Copy_Rect(Terrain,Screen,250,10,Xc*TS+Ox,Yc*TS+Oy,TS,TS,3);
          Set_Color(6,125*0,125*0,125*7);
        End;
  Box:=New_Dialog(6,X,Y,W,H);
  A_Item :=Add_DItem(Box,G_Text,None,
                     1,1,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  B_Item :=Add_DItem(Box,G_Text,None,
                     1,2,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  X_Item :=Add_DItem(Box,G_BoxText,Selectable|Exit_Btn|Default,
                     W div 2-8,H-2,16,1,
                    -3,Borders*4096|Text_C*256|128);
  Set_DText(Box,A_Item,'Heavy rains flood low lying',System_Font,TE_Left);
  Set_DText(Box,B_Item,'  areas.',System_Font,TE_Left);
  Set_DText(Box,X_Item,' Drip, Drip... ',System_Font,TE_Center);
  Center_Dialog(Box);
  Copy_Rect(Screen,Storage,0,0,0,0,320,200,3);
  Show_Mouse;
  B:=Do_Dialog(Box,0);
  End_Dialog(Box);
  Delete_Dialog(Box);
  Hide_mouse;
  Copy_Rect(Storage,Screen,0,0,0,0,320,200,3);
End;

Procedure Dry_Winter;
Const C=125;
Var A_Item,B_Item,X_Item: Integer;
    Box: Dialog_Ptr;
    H,W,X,Y: Integer;
    Xc,Yc: Integer;
Begin
  H:=7;
  W:=32;
  Dry:=True;

  Set_Color( 8,C*4,C*4,C*1);
  Set_Color(14,C*5,C*3,C*0);

  For Xc:=0 to Mx do
    For Yc:=0 to My do
      If Tiles[Xc,Yc]=4 then Tiles [Xc,Yc]:=13;

  Box:=New_Dialog(6,X,Y,W,H);
  A_Item :=Add_DItem(Box,G_Text,None,
                     1,1,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  B_Item :=Add_DItem(Box,G_Text,None,
                     1,2,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  X_Item :=Add_DItem(Box,G_BoxText,Selectable|Exit_Btn|Default,
                     W div 2-5,H-2,10,1,
                    -3,Borders*4096|Text_C*256|128);
  Set_DText(Box,A_Item,'The Kingdom struck by',System_Font,TE_Left);
  Set_DText(Box,B_Item,'a terrible drought.',System_Font,TE_Left);
  Set_DText(Box,X_Item,' Water... ',System_Font,TE_Center);
  Center_Dialog(Box);
  Copy_Rect(Screen,Storage,0,0,0,0,320,200,3);
  Show_Mouse;
  B:=Do_Dialog(Box,0);
  End_Dialog(Box);
  Delete_Dialog(Box);
  Hide_mouse;
  Copy_Rect(Storage,Screen,0,0,0,0,320,200,3)
End;

Procedure Late_Snow;
Const C=125;
Var A_Item,B_Item,X_Item: Integer;
    Box: Dialog_Ptr;
    H,W,X,Y: Integer;
Begin
  H:=7;
  W:=32;
  Snow:=True;

  Set_Color( 3,C*7,C*7,C*7);
  Set_Color( 4,C*7,C*7,C*7);
  Set_Color( 6,C*7,C*7,C*7);
  Set_Color( 8,C*7,C*7,C*7);
  Set_Color( 9,C*7,C*7,C*7);
  Set_Color(13,C*7,C*7,C*7);
  Set_Color(14,C*7,C*7,C*7);

  Box:=New_Dialog(6,X,Y,W,H);
  A_Item :=Add_DItem(Box,G_Text,None,
                     1,1,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  B_Item :=Add_DItem(Box,G_Text,None,
                     1,2,W-2,1,
                    -2,Borders*4096|Text_C*256|128);
  X_Item :=Add_DItem(Box,G_BoxText,Selectable|Exit_Btn|Default,
                     W div 2-5,H-2,10,1,
                    -3,Borders*4096|Text_C*256|128);
  Set_DText(Box,A_Item,'A late snow fall catches the',System_Font,TE_Left);
  Set_DText(Box,B_Item,'troops in the field.',System_Font,TE_Left);
  Set_DText(Box,X_Item,' Brrrrr! ',System_Font,TE_Center);
  Center_Dialog(Box);
  Copy_Rect(Screen,Storage,0,0,0,0,320,200,3);
  Show_Mouse;
  B:=Do_Dialog(Box,0);
  End_Dialog(Box);
  Delete_Dialog(Box);
  Hide_mouse;
  Copy_Rect(Storage,Screen,0,0,0,0,320,200,3)
End;

Function TotalPop: Integer;
Var T,X,Y: Integer;
Begin
  T:=0;
  For X:=0 to Mx do
    For Y:=0 to My do T:=T+Pop[X,Y];
  TotalPop:=T
End;

Function Greatest_Army: Integer;
Var B,X,Y: Integer;
Begin
  B:=0;
  For X:=0 to Mx do
    For Y:=0 to My do If Troops[X,Y]>B then B:=Troops[X,Y];
  Greatest_Army:=B
End;

Begin { Fate }
  N:=Rand(6);
  If TotalPop<20 then N:=N+1;
  If Greatest_Army>100 then N:=N-1;
  Case N of
     -1,0: Plauge;
        1: Curse;
        2: Dry_Winter;
        3: Wet_Winter;
        4: Late_Snow;
      5,6: Census
    End
End;

Function Winner: Boolean;
Const Text=4;
      Borders=15;
Var A_Item,B_Item,C_Item,X_Item: Integer;
    Active,B,H,P,W,X,Y: Integer;
    Box: Dialog_Ptr;
    TStr: Str255;
Begin
  Active:=0;
  Winner:=True;
  For P:=1 to Pn+1 do If Count_Troops(P)>0 then Active:=Active+1;
  Copy_Rect(Screen,Storage,0,0,0,0,320,200,3);
  If Active=1 then
    Begin
      H:=11;
      W:=28;
      Box:=New_Dialog(4,X,Y,W,H);
      A_Item :=Add_DItem(Box,G_Text,None,
                         1,2,W-2,1,-2,Borders*4096|Text_C*256|128);
      B_Item :=Add_DItem(Box,G_Text,None,
                         1,4,W-2,1,-2,Borders*4096|Text_C*256|128);
      C_Item :=Add_DItem(Box,G_Text,None,
                         1,6,W-2,1,-2,Borders*4096|Text_C*256|128);
      X_Item :=Add_DItem(Box,G_BoxText,Selectable|Exit_Btn|Default,
                         W div 2-11,H-2,22,1,-3,Borders*4096|Text_C*256|128);
      Set_DText(Box,A_Item,'The war is over!',System_Font,TE_Center);
      For P:=1 to Pn+1 do
        If Count_Troops(P)>0 then
          If P>Pn then TStr:='Crobvar of the Bandits'
                  else TStr:=P_Name[P];
      Set_DText(Box,B_Item,TStr,System_Font,TE_Center);
      Set_DText(Box,C_Item,'is crowned the new King!',System_Font,TE_Center);
      Set_DText(Box,X_Item,' Long Live the King! ',System_Font,TE_Center);
      Center_Dialog(Box);
      Show_Mouse;
      B:=Do_Dialog(Box,0);
      Hide_mouse;
      Copy_Rect(Storage,Screen,0,0,0,0,320,200,3);
      Show_Mouse;
      End_Dialog(Box);
      Delete_Dialog(Box);
    End else Winner:=False;
End;

Begin { Play_Game }
  Repeat
    Repeat
      Repeat
        If (Count_Troops(Order[P])>0) and (Order[P]<=Pn)
          then B:=Move_Troops(Order[P])
          Else Next:=True;
        If Order[P]>Pn then Move_Bandits;
        If Winner then B:=G_Exit;
        If Next then Begin P:=P+1; Next:=False End
      Until (P>Pn+1) or (B=G_Exit);
      If B<>G_Exit then { End of Month Processing }
        Begin
          If (Wet=True) and (Rand(2)=0) then
            Begin
              Wet:=False;
              Fade_Color(TerrainColors);
              For X:=0 to Mx do
                For Y:=0 to My do
                  If Tiles[X,Y]=11 then
                    Begin
                      Tiles[X,Y]:=3;
                      Sx:=Rand(18);
                      Sy:=Rand(18);
                      Copy_Rect(Terrain,Screen,
                                167+Sx,4+Sy,X*TS+Ox,Y*TS+Oy,TS,TS,3);
                    End;
            End;
          If (Dry=True) and (Rand(2)=0) then
            Begin
              Dry:=False;
              Fade_Color(TerrainColors);
              For X:=0 to Mx do
                For Y:=0 to My do
                  If Tiles[X,Y]=13 then
                    Begin
                      Tiles[X,Y]:=4;
                      Troops[X,Y]:=0;
                      Copy_Rect(Terrain,Screen,250,10,X*TS+Ox,Y*TS+Oy,TS,TS,3)
                    End
            End;
          If (Month>0) and Snow then { Spring arrives }
            Begin
              Snow:=False;
              Fade_Color(TerrainColors);
              For X:=0 to Mx do
                For Y:=0 to My do
                  If Tiles[X,Y]=4 then
                    Begin
                      Troops[X,Y]:=0;
                      Copy_Rect(Terrain,Screen,250,10,X*TS+Ox,Y*TS+Oy,TS,TS,3)
                    End
            End;
          Month:=Month+1;
          ROrder;
          P:=1
        End;

    Until (Month>Campaigns) or (B=G_Exit);
    Hide_Mouse;
    Paint_Color(11); { Sea Blue }
    Paint_Style(1);
    Paint_Rect(5,181,312,19);
    Show_Mouse;
    If B<>G_Exit then { End of Year }
      Begin
        Repeat
          If (Count_Troops(Order[P])>0) and (Order[P]<=Pn)
            Then Economics(Order[P])
            Else Next:=True;
          If Order[P]>Pn then Add_Bandits(Order[P]);
          If Next then Begin P:=P+1; Next:=False End
        Until (P>Pn+1);
        If Rand(5)=0 then Fate;
        Year:=Year+1;
        If Snow then Month:=-Rand(2) else Month:=1;
        Campaigns:=Rand(3)+Rand(3)+2;
        ROrder;
        P:=1
      End
  Until (B=G_Exit)
End;

Procedure About_Dialog;
Var A_Box: Dialog_Ptr;
    B,B_Item,C_Item,D_Item,H,V_Item,Ok_Item,W_Item,W,X,Y: Integer;
Begin
  H:=13;
  W:=30;
  A_Box:=New_Dialog(7,X,Y,W,H);
  C_Item :=Add_DItem(A_Box,G_Text,None,
                     1,1,W-2,1,
                     0,Borders*4096|Text_C*256);
  B_Item :=Add_DItem(A_Box,G_Text,None,
                     1,3,W-2,1,
                     0,Borders*4096|Text_C*256);
  V_Item :=Add_DItem(A_Box,G_Text,None,
                     1,5,W-2,1,
                     0,Borders*4096|Text_C*256);
  D_Item :=Add_DItem(A_Box,G_Text,None,
                     1,7,W-2,1,
                     0,Borders*4096|Text_C*256);
  W_Item :=Add_DItem(A_Box,G_Text,None,
                     1,8,W-2,1,
                     0,Borders*4096|Text_C*256);
  Ok_Item:=Add_DItem(A_Box,G_BoxText,Selectable|Default|Exit_Btn,
                     W div 2-2,H-2,4,1,
                    -2,Borders*4096|Text_C*256);
  Center_Dialog(A_Box);
  Set_DText(A_Box,C_Item,'Battle for the Throne',System_Font,TE_Center);
  Set_DText(A_Box,B_Item,'By Terry Pack',System_Font,TE_Center);
  Set_DText(A_Box,V_Item,'Version 1.11',System_Font,TE_Center);
  Set_DText(A_Box,D_Item,'(C) 1987',System_Font,TE_Center);
  Set_DText(A_Box,W_Item,'Written in Personal Pascal',System_Font,TE_Center);
  Set_DText(A_Box,Ok_Item,'OK',System_Font,TE_Center);
  B:=Do_Dialog(A_Box,0);
  Delete_Dialog(A_Box);
  Hide_Mouse;
  Copy_Rect(TitlePage,Screen,0,11,0,11,320,188,3);
  Menu_Normal(Menu,3);
  Draw_Menu(Menu);
  Show_Mouse
End;

Procedure Show_Scores;
Var B,H: Integer;
    Box: Dialog_Ptr;
    GStr,TStr,PStr: Str255;
    Na_Item,Go_Item,Tr_Item: Array[1..MaxPlayers] of Integer;
    Ok_Item,P,T,Ti_Item,W,X,Y: Integer;
Begin
  H:=4*(Pn+1)+1;
  W:=20;
  Box:=New_Dialog(4*(Pn+1)+1,X,Y,W,H);
  Ti_Item :=Add_DItem(Box,G_BoxText,None,
                     1,1,W-2,1,
                    -2,Borders*4096|Text_C*256);
  For P:=1 to PN do
    Begin
      Na_Item[P]:=Add_DItem(Box,G_Text,None,
                            1,4*P-1,W-2,1,0,Borders*4096|Text_C*256);
      Go_Item[P]:=Add_DItem(Box,G_Text,None,
                            1,4*P+0,W-2,1,0,Borders*4096|Text_C*256);
      Tr_Item[P]:=Add_DItem(Box,G_Text,None,
                            1,4*P+1,W-2,1,0,Text_C*256)
    End;
  Ok_Item:=Add_DItem(Box,G_BoxText,Selectable|Default|Exit_Btn,
                     W div 2-2,H-2,4,1,
                    -2,Borders*4096|Text_C*256);
  Center_Dialog(Box);
  Set_DText(Box,Ti_Item,' Scores ',System_Font,TE_Center);
  Set_DText(Box,Ok_Item,' OK ',System_Font,TE_Center);
  For P:=1 to PN do
    Begin
      Long_Str(Gold[P],GStr);
      T:=0;
      For X:=0 to Mx do
        For Y:=0 to My do
          If Owner[X,Y]=P then T:=T+Troops[X,Y];
      Str(T,TStr);

      GStr:=Concat('Treasury  : ',GStr);
      TStr:=Concat('Troops    : ',TStr);

      Set_DText(Box,Na_Item[P],P_Name[P],System_Font,TE_Center);
      Set_DText(Box,Go_Item[P],GStr,System_Font,TE_Left);
      Set_DText(Box,Tr_Item[P],TStr,System_Font,TE_Left)
    End;
  B:=Do_Dialog(Box,0);
  Delete_Dialog(Box);
  Hide_Mouse;
  Copy_Rect(TitlePage,Screen,0,11,0,11,320,188,3);
  Show_Mouse;
  Menu_Normal(Menu,P_Title)
End;

Procedure Background;
Const N=12;
      W=31;
Var Box: Dialog_Ptr;
    H,I: Integer;
    Item: Array[1..N] of Integer;
    X_Item: Integer;
Begin
  H:=N+4;
  Box:=New_Dialog(N+2,0,0,W,H);
  For I:=1 to N do
    Item[I]:=Add_DItem(Box,G_Text,None,1,I,W-2,1,
                       0,Borders*4096|Text_C*256);
  X_Item:=Add_DItem(Box,G_BoxText,Selectable|Exit_Btn,W div 2-11,H-2,22,1,
                    -2,Borders*4096|Text_C*256);

  Set_DText(Box,Item[1],'  In the Kingdom of Thrania',System_Font,TE_Left);
  Set_DText(Box,Item[2],'the crown has never passed',System_Font,TE_Left);
  Set_DText(Box,Item[3],'down peacefully from one',System_Font,TE_Left);
  Set_DText(Box,Item[4],'generation to the next.',System_Font,TE_Left);
  Set_DText(Box,Item[5],'  As the news passes from',System_Font,TE_Left);
  Set_DText(Box,Item[6],'village to village, the sons',System_Font,TE_Left);
  Set_DText(Box,Item[7],'of old King Tharn gather',System_Font,TE_Left);
  Set_DText(Box,Item[8],'their troops and prepare for',System_Font,TE_Left);
  Set_DText(Box,Item[9],'battle. Even Crobvar, the',System_Font,TE_Left);
  Set_DText(Box,Item[10],'bastard, assembles his motley',System_Font,TE_Left);
  Set_DText(Box,Item[11],'force of bandits at his',System_Font,TE_Left);
  Set_DText(Box,Item[12],'forest hideout.',System_Font,TE_Left);

  Set_DText(Box,X_Item,'The battle begins...',System_Font,TE_Center);
  Center_Dialog(Box);
  B:=Do_Dialog(Box,0);
  Delete_Dialog(Box);
  Hide_Mouse;
  Copy_Rect(TitlePage,Screen,0,11,0,11,320,188,3);
  Show_Mouse;
  Menu_Normal(Menu,I_Title)
End;

Procedure Instructions;
Const N=13;
      W=34;
Var P1,P2,P3: Dialog_Ptr;
    H,I: Integer;
    It: Array[1..3,1..N] of Integer;
    Page: Integer;
    X_Item1,N_Item1,P_Item1: Integer;
    X_Item2,N_Item2,P_Item2: Integer;
    X_Item3,N_Item3,P_Item3: Integer;
Begin
  H:=N+4;
  P1:=New_Dialog(N+4,0,0,W,H);
  For I:=1 to N do
    It[1,I]:=Add_DItem(P1,G_Text,None,1,I,W-2,1,0,Borders*4096|Text_C*256);
  P_Item1:=Add_DItem(P1,G_BoxText,Selectable|Exit_Btn,  W div 4-2,H-2,6,1,
                    -2,Borders*4096|Text_C*256);
  N_Item1:=Add_DItem(P1,G_BoxText,Selectable|Exit_Btn,2*W div 4-2,H-2,6,1,
                    -2,Borders*4096|Text_C*256);
  X_Item1:=Add_DItem(P1,G_BoxText,Selectable|Exit_Btn,3*W div 4-2,H-2,6,1,
                    -2,Borders*4096|Text_C*256);

  Set_DText(P1,It[1, 1],'  The object of the game is to',System_Font,TE_Left);
  Set_DText(P1,It[1, 2],'eliminate the other Players''',System_Font,TE_Left);
  Set_DText(P1,It[1, 3],'troops by defeating them in',System_Font,TE_Left);
  Set_DText(P1,It[1, 4],'battle.',System_Font,TE_Left);
  Set_DText(P1,It[1, 5],'  The number on the top of each',System_Font,TE_Left);
  Set_DText(P1,It[1, 6],'space is the number of troops',System_Font,TE_Left);
  Set_DText(P1,It[1, 7],'in that space. To move your',System_Font,TE_Left);
  Set_DText(P1,It[1, 8],'troop use the mouse to click',System_Font,TE_Left);
  Set_DText(P1,It[1, 9],'once on the square where you',System_Font,TE_Left);
  Set_DText(P1,It[1,10],'have troops and then on the one',System_Font,TE_Left);
  Set_DText(P1,It[1,11],'where you want to go.   You',System_Font,TE_Left);
  Set_DText(P1,It[1,12],'will then get a dialog box',System_Font,TE_Left);
  Set_DText(P1,It[1,13],
                      'asking how many you want to move.',System_Font,TE_Left);

  Set_DText(P1,P_Item1,'Prev',System_Font,TE_Center);
  Set_DText(P1,N_Item1,'Next',System_Font,TE_Center);
  Set_DText(P1,X_Item1,'Exit',System_Font,TE_Center);

  P2:=New_Dialog(N+4,0,0,W,H);
  For I:=1 to N do
    It[2,I]:=Add_DItem(P2,G_Text,None,1,I,W-2,1,0,Borders*4096|Text_C*256);
  P_Item2:=Add_DItem(P2,G_BoxText,Selectable|Exit_Btn,W div 4-2,H-2,6,1,
                    -2,Borders*4096|Text_C*256);
  N_Item2:=Add_DItem(P2,G_BoxText,Selectable|Exit_Btn,2*W div 4-2,H-2,6,1,
                    -2,Borders*4096|Text_C*256);
  X_Item2:=Add_DItem(P2,G_BoxText,Selectable|Exit_Btn,3*W div 4-2,H-2,6,1,
                    -2,Borders*4096|Text_C*256);

  Set_DText(P2,It[2,1],'  In battle the defender''s',System_Font,TE_Left);
  Set_DText(P2,It[2,2],'terrain improves the defense.',System_Font,TE_Left);
  Set_DText(P2,It[2,3],'Castles have the best defense',System_Font,TE_Left);
  Set_DText(P2,It[2,4],'and clear terrain the worst. Be',System_Font,TE_Left);
  Set_DText(P2,It[2,5],'careful  when moving into',System_Font,TE_Left);
  Set_DText(P2,It[2,6],'swamps, they are full of',System_Font,TE_Left);
  Set_DText(P2,It[2,7],'quicksand as well as nastier',System_Font,TE_Left);
  Set_DText(P2,It[2, 8],'things.',System_Font,TE_Left);
  Set_DText(P2,It[2, 9],'',System_Font,TE_Left);
  Set_DText(P2,It[2,10],'  There are 2-6 movement turns',System_Font,TE_Left);
  Set_DText(P2,It[2,11],'each year and then taxes are',System_Font,TE_Left);
  Set_DText(P2,It[2,12],'collected.',System_Font,TE_Left);
  Set_DText(P2,It[2,13],'',System_Font,TE_Left);

  Set_DText(P2,P_Item2,'Prev',System_Font,TE_Center);
  Set_DText(P2,N_Item2,'Next',System_Font,TE_Center);
  Set_DText(P2,X_Item2,'Exit',System_Font,TE_Center);

  P3:=New_Dialog(N+4,0,0,W,H);
  For I:=1 to N do
    It[3,I]:=Add_DItem(P3,G_Text,None,1,I,W-2,1,0,Borders*4096|Text_C*256);
  P_Item3:=Add_DItem(P3,G_BoxText,Selectable|Exit_Btn,W div 4-2,H-2,6,1,
                    -2,Borders*4096|Text_C*256);
  N_Item3:=Add_DItem(P3,G_BoxText,Selectable|Exit_Btn,2*W div 4-2,H-2,6,1,
                    -2,Borders*4096|Text_C*256);
  X_Item3:=Add_DItem(P3,G_BoxText,Selectable|Exit_Btn,3*W div 4-2,H-2,6,1,
                    -2,Borders*4096|Text_C*256);

  Set_DText(P3,It[3, 1],'  Each year you are able to',System_Font,TE_Left);
  Set_DText(P3,It[3, 2],'collect taxes based on your',System_Font,TE_Left);
  Set_DText(P3,It[3, 3],'population (the lower number',System_Font,TE_Left);
  Set_DText(P3,It[3, 4],'on each space on the map).',System_Font,TE_Left);
  Set_DText(P3,It[3, 5],'  You get 1000 Gold pieces for',System_Font,TE_Left);
  Set_DText(P3,It[3, 6],'each unit of population. Troops',System_Font,TE_Left);
  Set_DText(P3,It[3, 7],'cost 2000 each to build. Money',System_Font,TE_Left);
  Set_DText(P3,It[3,8],'stored in your treasury from the',System_Font,TE_Left);
  Set_DText(P3,It[3, 9],'previous year can be used to',System_Font,TE_Left);
  Set_DText(P3,It[3,10],'raise troops anywhere in your',System_Font,TE_Left);
  Set_DText(P3,It[3,11],'territory. Taxes collected this',System_Font,TE_Left);
  Set_DText(P3,It[3,12],'year can only be used to build',System_Font,TE_Left);
  Set_DText(P3,It[3,13],'troops in castles.',System_Font,TE_Left);

  Set_DText(P3,P_Item3,'Prev',System_Font,TE_Center);
  Set_DText(P3,N_Item3,'Next',System_Font,TE_Center);
  Set_DText(P3,X_Item3,'Exit',System_Font,TE_Center);

  Center_Dialog(P1);
  Center_Dialog(P2);
  Center_Dialog(P3);

  Obj_SetState(P1,P_Item1,Disabled,False);
  Obj_SetState(P3,N_Item3,Disabled,False);

  Page:=1;
  Repeat
    Case Page of
        1: B:=Do_Dialog(P1,0);
        2: B:=Do_Dialog(P2,0);
        3: B:=Do_Dialog(P3,0);
        Else: B:=X_Item1;
      End;
    If B=N_Item1 then Page:=Page+1;
    If B=P_Item1 then Page:=Page-1;
    Obj_SetState(P1,N_Item1,Normal,False);
    Obj_SetState(P2,P_Item2,Normal,False);
    Obj_SetState(P2,N_Item2,Normal,False);
    Obj_SetState(P3,P_Item2,Normal,False);
  Until B=X_Item1;

  Delete_Dialog(P1);
  Delete_Dialog(P2);
  Delete_Dialog(P3);

  Hide_Mouse;
  Copy_Rect(TitlePage,Screen,0,11,0,11,320,188,3);
  Show_Mouse;
  Menu_Normal(Menu,I_Title)
End;

Procedure Credits;
Const N=10;
      W=30;
Var Box: Dialog_Ptr;
    H,I: Integer;
    Item: Array[1..N] of Integer;
    X_Item: Integer;
Begin
  H:=N+4;
  Box:=New_Dialog(N+2,0,0,W,H);
  For I:=1 to N do
    Item[I]:=Add_DItem(Box,G_Text,None,1,I,W-2,1,
                       0,Borders*4096|Text_C*256);
  X_Item:=Add_DItem(Box,G_BoxText,Selectable|Exit_Btn,W div 2-8,H-2,16,1,
                    -2,Borders*4096|Text_C*256);
  Set_DText(Box,Item[ 1],'The Playtesters:',System_Font,TE_Center);
  Set_DText(Box,Item[ 2],' ',System_Font,TE_Center);
  Set_DText(Box,Item[ 3],'Dan ''Spaniel'' Sprigg',System_Font,TE_Center);
  Set_DText(Box,Item[ 4],'Mark Kelley',System_Font,TE_Center);
  Set_DText(Box,Item[ 5],'Neil Luna',System_Font,TE_Center);
  Set_DText(Box,Item[ 6],'Michael ''Fletch'' Fletcher',System_Font,TE_Center);
  Set_DText(Box,Item[ 7],'Brad ''Elric'' Falk',System_Font,TE_Center);
  Set_DText(Box,Item[ 8],'Bryce Zimpfer',System_Font,TE_Center);
  Set_DText(Box,Item[ 9],'Jimmy Lee',System_Font,TE_Center);
  Set_DText(Box,Item[10],'Sam Aten',System_Font,TE_Center);
  Set_DText(Box,X_Item,' Good Work Guys ',System_Font,TE_Center);
  Center_Dialog(Box);
  B:=Do_Dialog(Box,0);
  Delete_Dialog(Box);
  Hide_Mouse;
  Copy_Rect(TitlePage,Screen,0,11,0,11,320,188,3);
  Show_Mouse;
  Menu_Normal(Menu,I_Title)
End;

Procedure Save_Game;
Var D,Player,S,W,Weather,X,Y: Integer;
    Default,Name_G: Path_Name;
    F: File of Text;
Begin
  Text_Color(1);
  Text_Height(6);
  Draw_String(116,20,' Save Game ');
  Default:=Concat(Chr(65+Current_Disk),':\*.SAV');
  If Get_In_File(Default,Name_G) Then
    Begin
      Set_Mouse(M_Bee);
      Hide_Mouse;
      Copy_Rect(TitlePage,Screen,0,11,0,11,320,188,3);
      Show_Mouse;
      Rewrite(F,Name_G);
        Writeln(F,Campaigns);
        Writeln(F,P);
        Writeln(F,Month);
        Writeln(F,Year);
        Writeln(F,Pn);
        If Dry  then D:=1 else D:=0;
        If Snow then S:=1 else S:=0;
        If Wet  then W:=1 else W:=0;
        Weather:=4*D+2*S+W;
        Writeln(F,Weather);
        For Player:=0 to Pn+1 do
          Begin
            Writeln(F,Gold[Player]);
            Writeln(F,Order[Player]);
            Writeln(F,P_Name[Player])
          End;
        For X:=0 to Mx do
          For Y:=0 to My do
            Begin
              Writeln(F,Owner[X,Y]);
              Writeln(F,Pop[X,Y]);
              Writeln(F,Tiles[X,Y]);
              Writeln(F,Troops[X,Y])
            End;
      Close(F);
    End Else
    Begin
      Hide_Mouse;
      Copy_Rect(TitlePage,Screen,0,11,0,11,320,188,3);
      Show_Mouse
    End;
  Menu_Normal(Menu,P_Title);
  Menu_Enable(Menu,C_Item);
  Menu_Enable(Menu,S_Item);
  Menu_Enable(Menu,Sa_Item);
  Draw_Menu(Menu);
  Set_Mouse(M_Arrow)
End;

Procedure Load_Game;
Var D: Integer;
    Default,Name_G: Path_Name;
    F: File of Text;
    Player,S,W,Weather,X,Y: Integer;
Begin
  Text_Color(1);
  Text_Height(6);
  Draw_String(116,20,' Load Game ');
  Default:=Concat(Chr(65+Current_Disk),':\*.SAV');
  If Get_In_File(Default,Name_G) Then
    Begin
      Hide_Mouse;
      Copy_Rect(TitlePage,Screen,0,11,0,11,320,188,3);
      Show_Mouse;
      Set_Mouse(M_Bee);
      Reset(F,Name_G);
        Readln(F,Campaigns);
        Readln(F,P);
        Readln(F,Month);
        Readln(F,Year);
        Readln(F,Pn);
        Readln(F,Weather);
        D:=  Weather div 4;
        S:= (Weather - 4 * D) div 2;
        W:=  Weather - 4 * D - 2 * S;
        If D=1 then Dry :=True else Dry :=False;
        If S=1 then Snow:=True else Snow:=False;
        If W=1 then Wet :=True else Wet :=False;
        For Player:=0 to Pn+1 do
          Begin
            Readln(F,Gold  [Player]);
            Readln(F,Order [Player]);
            Readln(F,P_Name[Player]);
          End;
        For X:=0 to Mx do
          For Y:=0 to My do
            Begin
              Readln(F,Owner[X,Y]);
              Readln(F,Pop[X,Y]);
              Readln(F,Tiles[X,Y]);
              Readln(F,Troops[X,Y])
            End;
      Close(F)
    End Else
    Begin
      Hide_Mouse;
      Copy_Rect(TitlePage,Screen,0,11,0,11,320,188,3);
      Show_Mouse
    End;
  Menu_Normal(Menu,P_Title);
  Menu_Enable(Menu,C_Item);
  Menu_Enable(Menu,S_Item);
  Menu_Enable(Menu,Sa_Item);
  Draw_Menu(Menu);
  Set_Mouse(M_Arrow)
End;

Begin { Outside }
  Draw_Menu(Menu);
  Repeat
    Event:=Get_Event(E_Message,0,0,0,0,
                     False,0,0,0,0,False,0,0,0,0,
                     Msg,Dummy,Dummy,Dummy,Dummy,Dummy,Dummy);
    If Msg[3]=3 then About_Dialog;
    If Msg[4]=B_Item Then Background;
    If Msg[4]=C_Item Then
      Begin
        Erase_Menu(Menu);
        Draw_Map;
        Play_Game;
        Hide_Mouse;
        Copy_Rect(TitlePage,Screen,0,0,0,0,320,200,3);
        Set_Color_Registers(TitleColors);
        Menu_Normal(Menu,P_Title);
        Draw_Menu(Menu);
        Show_Mouse
      End;
    If Msg[4]=Cr_Item Then Credits;
    If Msg[4]=In_Item Then Instructions;
    If Msg[4]=Lo_Item Then Load_Game;
    If Msg[4]=P_Item Then
      Begin
        Erase_Menu(Menu);
        Get_Players;
        Setup;
        Do_Colors;
        Draw_Map;
        Play_Game;
        Hide_Mouse;
        Copy_Rect(TitlePage,Screen,0,0,0,0,320,200,3);
        Set_Color_Registers(TitleColors);
        Menu_Enable(Menu,C_Item);
        Menu_Enable(Menu,S_Item);
        Menu_Enable(Menu,Sa_Item);
        Menu_Normal(Menu,P_Title);
        Draw_Menu(Menu);
        Show_Mouse
      End;
    If Msg[4]=S_Item Then Show_Scores;
    If Msg[4]=Sa_Item Then Save_Game
  Until Msg[4]=Q_Item;
  Delete_Dialog(T_Box);
  Erase_Menu(Menu);
  Delete_Menu(Menu);
  Hide_Mouse;
  Clear_Screen;
  Set_Color_Registers(DeskColors);
  Show_Mouse
End;

Begin { Main Program }
  If Init_Gem>=0 then
    If Getrez=0 then
      Begin
        Initialize;
        Outside
      End
      Else B:=Do_Alert(
              '[1][ You must be in Low-Res to run Battle. ][ Argh! ]',1);
  Exit_Gem
End.



