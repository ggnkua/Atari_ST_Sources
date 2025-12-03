Program Dragon_Maze;

Const {$I C:\Includes\GEMConst.PAS }
       Mx=13;      { How Wide the Maze is in blocks }
       My=13;      { How Tall the Maze is in blocks }
       Background=0;
       Walls=1;

TYPE {$I C:\Includes\GEMTYPE.PAS }
   Mfdb_fields = (addr1,addr2,wid_pix,ht_pix,wid_wds,flag,num_planes,r1,r2,r3);
   Mfdb = Array[Mfdb_fields] of integer;
   Path_Chars = Packed Array[1..80] of Char;
   ScreenType = Packed Array[1..32000] of Byte;
   HeadType = Packed Array[0..63] of Integer;
   Neo_Type = Packed Record
                Head: HeadType;
                Pic: ScreenType
              End;
   S_Ptr = ^ScreenType;     { Pointer to screen data }
   Player_Type = Record     { Used in keeping track of the high Score }
                   Name: String;
                   Score: Integer;
                 End;

Var About_Dialog: Dialog_Ptr;
    B: Integer;
    D_Buf,T_Buf,I_Buf: ScreenType;
    D_Item,b_Item,Ok_Item,v_Item,W_Item: Integer;
    DeskColors,DragonColors,TitleColors,InstrColors: HeadType;
    Dragons,Instructions,Screen,TitlePage: MFDB;
    File_Title,Start_Title,High_Title,HS_Window: Integer;
    I_Item: Integer;
    Maze: Array[0..Mx,0..My] of Integer;  { The Maze itself }
    O_Title,HS_Title: Window_Title;
    Outside_Window,P_Color: Integer;
    Player: Array[1..11] of Player_Type;
    Quit_Item,Start_Item,Show_Item,Last_Item,Clear_Item: Integer;
    S: Str255;
    ScH,ScW: Integer;
    Scn_Buf: ScreenType;
    Scn_Ptr: S_Ptr;
    ScX,ScY: Integer;
    Start,Finish: Integer;
    The_Menu: Menu_Ptr;

{$I C:\Includes\GEMSUBS.Pas }

Procedure IO_Check(B:Boolean);
External;

PROCEDURE Init_form(Var form: MFDB; Var addr: ScreenType);
External;

PROCEDURE copy_rect(Var s,d: MFDB;fx,fy,Tx,Ty,W,H,Mode :Integer);
External;

Function T_GetTime: Integer;
GEMDOS($2C);

Function F_Open(Var Name: Path_Chars; Mode: Integer): Integer;
Gemdos($3D);

Function Neo_Read(Handle: Integer;
                  Count: Long_Integer;
                  Var Buf: Neo_Type): Long_Integer;
Gemdos($3F);

Function Physbase: S_Ptr;
XBios(2);

Function Getrez: Integer;
Xbios(4);

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

{ Text_Height - Set the height in pixels of text, when it is drawn using the
      Draw_String library call. }

PROCEDURE Text_Height( height : Integer );
TYPE  Ctrl_Parms      = ARRAY [ 0..11 ] OF integer ;
      Int_In_Parms    = ARRAY [ 0..15 ] OF integer ;
      Int_Out_Parms   = ARRAY [ 0..45 ] OF Integer ;
      Pts_In_Parms    = ARRAY [ 0..11 ] OF integer ;
      Pts_Out_Parms   = ARRAY [ 0..11 ] Of Integer ;
VAR   Control : Ctrl_Parms ;
      Int_in  : Int_In_Parms ;
      int_Out : Int_Out_Parms ;
      Pts_In  : Pts_In_Parms ;
      Pts_out : Pts_Out_Parms ;

PROCEDURE VDI_Call(cmd, sub_cmd : integer ; nints, npts : integer ;
                   VAR ctrl : Ctrl_Parms ;
                   VAR Int_In : Int_In_Parms ; VAR Int_Out : Int_Out_Parms ;
                   VAR pts_In : Pts_In_Parms ; VAR pts_out : Pts_Out_Parms ;
                   Translate: Boolean ) ;
EXTERNAL;

Begin  { Text_Height }
   pts_in[0] := 0 ;
   pts_in[1] := height ;
   VDI_Call(12, 0, 0, 2, control, int_in, int_out, pts_in, pts_Out, False);
END;

Procedure Str(N: Integer; Var Num:string);
Var e: real;       { a fudge factor }
    F: Integer;
Begin
  E:=0.0000001;
  F:=0;
  Num:='';
  If n<0 then begin n:=-n; Num:='-' End;
  if (Trunc(n/10000+e)>0) or (F=1) then
    Begin
      Num:=concat(num,chr(48+Trunc(n/10000+e)));
      N:=N-10000*Trunc(n/10000+e); f:=1
    end;
  if (trunc(n/1000+e)>0) or (f=1) then
    Begin
      Num:=Concat(Num,Chr(48+Trunc(N/1000+E)));
      n:=n-1000*trunc(n/1000+e); f:=1
    End;
  if (trunc(N/100+E)>0) or (F=1) then
    begin
      num:=concat(num,chr(48+trunc(n/100+E)));
      n:=n-100*Trunc(n/100+e); f:=1
    End;
  if (Trunc(n/10+e)>0) or (F=1) then
    Begin
      Num:=concat(Num,Chr(48+Trunc(N/10+E)));
      n:=n-10*trunc(n/10+E); F:=1
    end;
  Num:=concat(num,chr(48+N))
end;

Function Val(Var Num: String): Integer;
var d,I,n,s: integer;
Begin
  N:=0;
  If num[1]='-' then S:=-1 else S:=1;
  for I:=1 to Length(Num) do
    if num[i] in ['0'..'9'] then
      Begin
        d:=ord(num[i])-Ord('0');
        n:=n*10+D
      End;
  Val:=N*S
End;

Function Rand(N:integer):Integer; { returns a random number 0..n-1 }

Function random:integer;
XBIOS(17);

Begin
  Rand:=abs(random mod n)
End;

Procedure Sav_Scn;
{$P-}
  Begin
    Scn_Ptr:=Physbase;
    Scn_Buf:=Scn_Ptr^
  End;
{$P=}

Procedure Rest_Scn;
{$P-}
  Begin
    Scn_Ptr:=Physbase;
    Scn_Ptr^:=Scn_Buf
  End;
{$P=}

Procedure Make_Path(Var Ps: Str255; Var Cs: Path_Chars);
Var I: Integer;
Begin
  For I:=1 to Length(Ps) do Cs[I]:=Ps[I];
  Cs[Length(Ps)+1]:=Chr(0)
End;

Procedure Draw_Block(X,Y:Integer);
Begin
  If Maze[X,Y] &  1 <> 0 then Line_Color(Walls) else Line_Color(Background);
  Line(ScX*(x+1),Scy*y,ScX*(x+1),Scy*(y+1));
  If Maze[x,y] &  2 <> 0 then line_Color(Walls) else Line_Color(Background);
  Line(Scx*X,Scy*(y+1),Scx*(x+1),Scy*(Y+1));
  if Maze[x,y] &  4 <> 0 then line_Color(Walls) else Line_Color(Background);
  Line(Scx*x,Scy*Y,Scx*x,Scy*(y+1));
  if Maze[x,y] &  8 <> 0 then line_Color(Walls) else Line_Color(Background);
  Line(scx*x,Scy*y,Scx*(X+1),Scy*Y)
End;

Procedure Draw_Maze;
Label 1;
Var D,Nx,Ny,X,Y: Integer;
    Event,Key,Dummy: Integer;
    Msg: Message_Buffer;
    X1,y1: Integer;

Function New_X(x,D:Integer): Integer;
Begin
  Case D of
        1: X:=x+1;
        3: X:=X-1
      End;
  New_X:=x
End;

Function New_Y(Y,D: Integer): Integer;
Begin
  Case D of
      0: Y:=Y-1;
      2: Y:=Y+1
    End;
  New_Y:=Y
End;

Function New_Block(X,Y:Integer): Boolean;
Var D: integer;
    Nx,Ny: Integer;
Begin
  New_Block:=False;
  For D:=0 to 3 do
     Begin
       Nx:=New_X(x,d);
       Ny:=New_Y(Y,D);
       If (Nx>=0) and (Ny>=0) and (Nx<=Mx) and (Ny<=My) then
         If Maze[nx,ny]=15 then New_Block:=true
     End
End;

Function All_Used: Boolean;
Var X,Y: Integer;
begin
  All_Used:=True;
  For X:=0 to Mx do
    For Y:=0 to My do
      if maze[x,y]=15 then all_used:=False
End;

Procedure Add_Block;
begin
  Case D of
    0: Begin
         Maze[X,Y]:=Maze[X,y]&7;
         Maze[nx,ny]:=Maze[nx,ny]&13;
         Draw_Block(X,Y);
         Draw_Block(Nx,Ny)
       end;
    1: Begin
         Maze[x,y]:=Maze[x,y]&14;
         Maze[nx,ny]:=Maze[nx,ny]&11;
         Draw_Block(X,Y);
         Draw_Block(Nx,Ny)
       End;
    2: Begin
         Maze[X,Y]:=Maze[x,y]&13;
         Maze[Nx,Ny]:=Maze[Nx,Ny]&7;
         Draw_Block(X,Y);
         Draw_Block(Nx,Ny)
       End;
    3: Begin
         Maze[X,Y]:=Maze[x,y]&11;
         Maze[Nx,ny]:=Maze[nx,ny]&14;
         Draw_Block(X,Y);
         Draw_Block(NX,NY)
       End
    End;
  x:=Nx;
  Y:=Ny
End;

Begin { Draw_Maze }
  Set_Clip(0,0,ScW,ScH);
  Paint_Color(Background);
  Paint_Rect(0,0,ScW,ScH);
  For x:=0 to Mx do
    For y:=0 to My do
      Maze[x,Y]:=15;
  Maze[0,0]:=31;
  Repeat
    For X1:=0 to MX do
      For Y1:=0 to My do
        If (Maze[X1,y1]<>15) Then
          Begin
            X:=X1;Y:=Y1;
1:          Repeat
              Repeat
                D:=Rand(4);
                Nx:=new_x(x,d); Ny:=New_Y(y,d);
              Until (Nx>=0) and (Ny>=0) and (Nx<=Mx) and (Ny<=My);
            Until (Maze[Nx,Ny]=15)            { Found empty block }
              or (New_Block(x,y)=False);  { There are no empty blocks }
            If Maze[NX,NY]=15 then Add_Block;
            if New_Block(x,Y) then goto 1;
          End
  Until All_Used;
  Repeat
    Event:=Get_Event(E_Timer,
                     0,0,0, { No Buttons }
                     1000,  { wait 1 second }
                     False,0,0,0,0,
                     False,0,0,0,0,
                     Msg,
                     Key,
                     Dummy,dummy,dummy,dummy,dummy);
  Until (Event & E_Timer)>0;
End;

Procedure Do_Maze;
Var Button,D_Dir,Dummy,Dx,Dy,X,Y: Integer;
    Event,Key: Integer;
    Msg: Message_buffer;

Procedure Erase_Person;
Begin
  Copy_Rect(Dragons,Screen,23,43,X*ScX+1,Y*ScY+1,ScX-1,ScY-1,3);
End;

Procedure Draw_Person;
Begin
  Copy_Rect(Dragons,Screen,177,57,X*ScX+1,Y*ScY+1,ScX-1,ScY-1,3);
End;

Procedure Left;
Begin
  Erase_Person;
  If Maze[X,Y] & 4 = 0 then X:=X-1
                       Else Line(Scx*x,Scy*y,Scx*x,Scy*(y+1));
  Draw_Person;
End;

Procedure Right;

Procedure New_HS;
Var HS_Dialog: Dialog_Ptr;
    N,NTT_Item,Name_Item,Done_Item: Integer;
    St: Str255;

Procedure Sort_Scores;
Var I: Integer;
    T: Player_Type;
    St: Str255;
    S: string;
Begin
  For I:=11 downto 2 do
    If Player[i].Score>player[i-1].Score then
      Begin
        T:=Player[I];
        Player[i]:=Player[i-1];
        Player[I-1]:=T
      End
End;

Begin { New_HS }
  HS_Dialog:=New_Dialog(4,0,0,22,7);
  NTT_Item:=Add_DItem(HS_Dialog,G_Text,None,1,1,12,2,0,Black*256);
  Name_Item:=Add_DItem(HS_Dialog,G_FText,Selectable|Editable,
                       1,3,20,1,0,128|Black*256);
  Done_Item:=Add_DItem(HS_Dialog,G_Button,Selectable|Default|Exit_Btn,
                       8,5,6,1,1,Black*256);
  Set_DText(HS_Dialog,NTT_Item,' New Top 10 ',System_Font,TE_Center);
  Set_DText(HS_Dialog,Done_Item,' Done ',System_Font,TE_Center);
  Set_DEdit(HS_Dialog,Name_Item,'_______________',
                                'nnnnnnnnnnnnnnn','',System_Font,TE_Center);
  Center_Dialog(HS_Dialog);
  N:=Do_Dialog(HS_Dialog,Name_Item);
  End_Dialog(HS_Dialog);
  Get_DEdit(HS_Dialog,Name_Item,St);
  player[11].name:=St;
  Sort_Scores;
  Delete_Dialog(HS_Dialog)
End;

Begin { Right }
  If Maze[X,Y] & 32 <> 0 then
    Begin
      Erase_Person;
      Player[11].Score:=400+Start-T_GetTime;
      Button:=Do_alert('[1][    You Made It.    ][ Exit ]',1);
      Str(Player[11].Score,s);
      s:=concat('[1][ Score = ',s,' ][ Exit ]');
      Button:=Do_Alert(S,1);
      if Player[11].score>Player[10].score then New_HS
    End Else
      Begin
        Erase_Person;
        If Maze[X,Y] & 1 = 0 then X:=X+1
                             else Line(scx*(x+1),Scy*y,Scx*(x+1),Scy*(y+1));
        Draw_Person;
      End;
End;

Procedure Up;
Begin
  Erase_Person;
  If Maze[x,y] & 8 = 0 then y:=Y-1
    else Line(Scx*x,Scy*y,Scx*(x+1),Scy*y);
  Draw_Person;
End;

Procedure Down;
var n: Integer;
Begin
  Erase_Person;
  If Maze[X,Y] & 2 = 0 then y:=y+1
    else Line(scx*x,Scy*(Y+1),Scx*(x+1),Scy*(Y+1));
  Draw_Person;
end;

Procedure Erase_Dragon;
Begin
  Copy_Rect(Dragons,Screen,23,43,Dx*ScX+1,Dy*ScY+1,ScX-1,ScY-1,3);
End;

Procedure Draw_Dragon(D: Integer);
Begin
  Case D of
      0: Copy_Rect(Dragons,Screen,67,43,Dx*ScX+1,Dy*Scy+1,ScX-1,ScY-1,3);
      1: Copy_Rect(Dragons,Screen,89,57,Dx*ScX+1,Dy*Scy+1,ScX-1,ScY-1,3);
      2: Copy_Rect(Dragons,Screen,67,71,Dx*ScX+1,Dy*Scy+1,ScX-1,ScY-1,3);
      3: Copy_Rect(Dragons,Screen,45,57,Dx*ScX+1,Dy*Scy+1,ScX-1,ScY-1,3);
    End;
End;

Procedure Move_Dragon;
Const P=25;  { For a Nastier Dragon, use a smaller P }
Var Face: Integer;
Begin
  Erase_Dragon;
  Face:=D_Dir;
  D_Dir:=(D_Dir+2) Mod 4; { Start with the dragon backing up }

  If (D_Dir=0) and (Maze[dx,Dy] & 8<>0) then D_Dir:=(D_Dir+1) Mod 4;
  if (D_Dir=1) and (Maze[dx,Dy] & 1<>0) then D_Dir:=(D_Dir+1) Mod 4;
  if (D_Dir=2) and (Maze[dx,Dy] & 2<>0) then D_Dir:=(D_Dir+1) Mod 4;
  If (D_Dir=3) and (Maze[dx,Dy] & 4<>0) then D_Dir:=(D_Dir+1) Mod 4;

  If (Y<Dy) and ((Maze[Dx,Dy] & 8=0) or (Rand(P)=0)) Then
    Begin
      D_Dir:=0;
      Face:=D_Dir;
    End;
  If (X>dx) and ((Maze[dx,dy] & 1=0) or (Rand(p)=0)) then
    Begin
      D_Dir:=1;
      Face:=D_Dir;
    End;
  If (Y>dy) and ((Maze[dx,dy] & 2=0) or (Rand(P)=0)) then
    Begin
      D_Dir:=2;
      Face:=D_Dir;
    End;
  If (x<dx) and ((Maze[dx,dy] & 4=0) or (rand(p)=0)) then
    Begin
      D_Dir:=3;
      Face:=D_Dir
    End;

  Case D_Dir of
      0: DY:=DY-1;
      1: DX:=DX+1;
      2: DY:=DY+1;
      3: DX:=DX-1
    end;
  Draw_Dragon(Face);
  If (dx=x) and (dy=y) then
    Begin
      Button:=Do_alert('[1][ The Dragon ate You. ][ Exit ]',1);
      Player[11].Score:=0
    End;
  Draw_Person;
End;

Begin { Do_Maze }
  Draw_Maze;
  Button:=0;
  Paint_Color(Background);
  Paint_Rect(0,0,Scw,Sch);
  Line_Color(Walls);
  Line(0,0,(Mx+1)*Scx,0);
  Line((Mx+1)*Scx,0,(Mx+1)*scx,(My+1)*scy);
  Line((Mx+1)*scx,(My+1)*ScY,0,(My+1)*ScY);
  Line(0,(My+1)*ScY,0,0);

  X:=0;
  Y:=Rand(My);
  Draw_Person;

  DX:=MX;
  DY:=Rand(My);
  Maze[Dx,Dy]:=Maze[Dx,Dy] | 32; { The maze's exit   }
  Line_Color(Background);
  Line(scx*(Dx+1),ScY*Dy,Scx*(Dx+1),Scy*(Dy+1));

  D_Dir:=3;
  Draw_Dragon(D_Dir);

  Start:=T_GetTime;
  Repeat
    Repeat
      Event:=Get_Event(E_keyboard,
                       0,0,0, { No Buttons }
                       0,
                       False,0,0,0,0,
                       False,0,0,0,0,
                       Msg,
                       Key,
                       Dummy,Dummy,Dummy,Dummy,Dummy);
    Until (Event & E_Keyboard<>0);
    Key:=Key div $100;
    Line_Color(Walls);
    Case Key of
         $4B,$6A: Left;
         $4D,$6C: Right;
         $48,$68: Up;
         $50,$6E: Down
       End;
    Move_Dragon;
  Until (Key=$61) or (Button=1);
End;

Procedure Clear_HS;
Var I: Integer;
Begin
  For I:=1 to 10 do
    Begin
      Player[i].Name:='';
      player[i].Score:=0
    End
End;

Procedure Save_HS;
Var F: File of Text;
    I: Integer;
Begin
  Rewrite(F,'DRAGON.HS');
  For I:=1 to 10 do
    Begin
      Writeln(F,Player[I].name);
      Writeln(F,Player[I].Score)
    End;
  Close(F)
End;

Procedure Load_DragonPic;
Var B: Long_Integer;
    Handle: Integer;
    Neo_Buf: Neo_Type;
    Path: Path_Chars;
    Ps: Str255;
Begin
  Ps:='Dragon.Neo';
  Make_Path(Ps,Path);
  Handle:=F_Open(Path,0);
  B:=Neo_Read(Handle,32127,Neo_Buf);
  Scn_Buf:=Neo_Buf.Pic;
  DragonColors:=Neo_Buf.Head
End;

Procedure Load_TitlePic;
Var B: Long_Integer;
    Handle: Integer;
    Neo_Buf: Neo_Type;
    Path: Path_Chars;
    Ps: Str255;
Begin
  Ps:='TitlePag.Neo';
  Make_Path(Ps,Path);
  Handle:=F_Open(Path,0);
  B:=Neo_Read(Handle,32127,Neo_Buf);
  Scn_Buf:=Neo_Buf.Pic;
  TitleColors:=Neo_Buf.Head
End;

Procedure Load_InstrPic;
Var B: Long_Integer;
    Handle: Integer;
    Neo_Buf: Neo_Type;
    Path: Path_Chars;
    Ps: Str255;
Begin
  Ps:='Instr.Neo';
  Make_Path(Ps,Path);
  Handle:=F_Open(Path,0);
  B:=Neo_Read(Handle,32127,Neo_Buf);
  Scn_Buf:=Neo_Buf.Pic;
  InstrColors:=Neo_Buf.Head
End;

Procedure Init_Stuff;
Var F: File of Text;
    I: Integer;
    Num: String;
Begin
  Init_Mouse;
  Hide_Mouse;
  Read_Color_Registers(DeskColors);
  For I:=0 to 15 do SetColor(I,0);
  Screen[Addr1]:=0; Screen[Addr2]:=0;

  Init_Form(Dragons,D_Buf);
  Init_Form(Instructions,I_Buf);
  Init_Form(TitlePage,T_Buf);

  Load_DragonPic;
  Rest_Scn;  { Put Scn_Buf on Physical screen }
  Copy_Rect(Screen,Dragons,0,0,0,0,320,200,3);

  Load_InstrPic;
  Rest_Scn;
  Copy_Rect(Screen,Instructions,0,0,0,0,320,200,3);

  Load_TitlePic;
  Rest_Scn;
  Copy_Rect(Screen,TitlePage,0,0,0,0,320,200,3);

  Show_Mouse;
  O_Title:=' Dragon Maze ';
  Outside_Window:=New_Window(0,O_Title,0,0,0,0);
  HS_Title:='  High Scores  ';
  HS_Window:=New_Window(G_Name|G_Close,HS_Title,0,0,0,0);
  The_menu:=New_Menu(10,'  About Dragon Maze  ');
  Start_Title:=Add_MTitle(The_Menu,' The Game ');
  High_Title :=Add_MTitle(The_Menu,' High Score ');
  File_Title :=Add_MTitle(The_Menu,' Quit ');
  Start_Item:=Add_MItem(The_Menu,Start_Title,'  Start Game      ');
  Last_Item :=Add_MItem(The_Menu,Start_Title,'  Show last maze  ');
  I_Item    :=Add_MItem(The_Menu,Start_Title,'  Instructions    ');
  Show_Item :=Add_MItem(The_Menu,High_Title, '  Show High Scores   ');
  Clear_Item:=Add_MItem(The_Menu,High_Title, '  Clear High Scores  ');
  Quit_Item :=Add_MItem(The_Menu,File_Title, '  Quit  ');
  About_Dialog:=New_Dialog(10,0,0,33,12);
  D_Item:=Add_DItem(About_Dialog,G_Text,None,1,1,33,1,0,Black*256);
  B_Item:=Add_DItem(About_Dialog,G_Text,None,1,3,33,1,0,Black*256);
  V_Item:=Add_DItem(About_Dialog,G_Text,None,1,5,33,1,0,Black*256);
  W_Item:=Add_DItem(About_Dialog,G_Text,None,1,7,33,1,0,Black*256);

  Ok_Item:=Add_DItem(About_Dialog,G_Button,Selectable|Default|Exit_Btn,
                     15,9,4,2,1,Black*256);

  Menu_Disable(The_Menu,Last_Item);

  Center_Dialog(About_Dialog);
  Set_DText(About_Dialog,D_Item,'Dragon Maze',System_Font,TE_Center);
  Set_DText(About_Dialog,B_Item,'By Terry Pack',System_Font,TE_Center);
  Set_DText(About_Dialog,V_Item,'Version 2.01',System_Font,TE_Center);
  Set_DText(About_Dialog,W_Item,'Written in Personal Pascal',
            System_Font,TE_Center);
  Set_DText(About_Dialog,Ok_Item,' OK ',System_Font,TE_Center);
  IO_Check(False);
  Reset(F,'DRAGON.HS');
  If Not Eof(F) then
  For I:=1 to 10 do
    Begin
      Readln(F,Player[i].name);
      Readln(F,Num);
      Player[I].Score:=val(Num)
    End;
  Close(F);
  IO_Check(True);
  ScX:=22;     { How Wide each block is }
  ScY:=14;     { How Tall each block is }
  P_Color:=Red;
  ScH:=200;
  ScW:=320
End;

Procedure Outside_Menu;
Var Event,Dummy: Integer;
    H,N,x,y,w: Integer;
    Msg: Message_Buffer;

Procedure Draw_O_Window;
Begin
  Hide_Mouse;
  Set_Color_Registers(TitleColors);
  Set_Clip(0,0,320,200);
  Copy_Rect(TitlePage,Screen,0,11,0,11,320,189,3);
  Draw_Menu(The_menu);
  Show_Mouse
End;

Procedure Show_HS;
Const C=8;
Var Event,H,I,Key: Integer;
    Msg: Message_Buffer;
    Num,S: String;
    W,X,Y: Integer;
Begin
  W:=256; H:=102;
  X:=(scw-w) div 2; Y:=(sch-H) Div 2;
  Open_Window(HS_Window,x,y,W,h);
  Work_Rect(HS_Window,x,y,w,h);
  Set_Clip(X,y,w,h);
  Paint_Color(White);
  Hide_Mouse;
  Paint_Rect(X,Y,w,h);
  For I:=1 to 10 do
    Begin
      str(Player[i].Score,Num);
      S:=Concat(Player[I].Name,'                                    ');
      Insert(Num,S,23);
      Draw_String(X+2*C,Y+C*I,S);
    End;
  Show_Mouse;
  Repeat
    Event:=Get_Event(E_Message|E_Keyboard,
                     0,0,0,0,false,0,0,0,0,False,0,0,0,0,Msg,
                     Key,dummy,dummy,dummy,Dummy,Dummy)
  Until (Msg[0]=WM_Closed) or (Event & E_Keyboard<>0);
  Close_Window(HS_Window)
End;

Procedure Show_Last;
Var Dummy,Event,Key,X,y: Integer;
    Msg: Message_Buffer;
Begin
  Set_Clip(0,0,ScW,ScH);
  Paint_Color(Background);
  Paint_Style(1);
  Paint_Rect(0,0,ScW,ScH);
  For X:=0 to Mx do For y:=0 to My do Draw_Block(X,Y);
  Repeat
    Event:=Get_Event(E_Button|E_Keyboard,3,1,1,0,False,0,0,0,0,False,0,0,0,0,
                     Msg,Key,Dummy,Dummy,Dummy,Dummy,Dummy);
  Until (Event&E_Keyboard<>0) or (Event&E_Button<>0)
End;

Procedure Show_Instr;
Var Dummy,Event,Key: Integer;
    Msg: Message_Buffer;
Begin
  Hide_Mouse;
  Copy_Rect(Instructions,Screen,0,0,0,0,320,200,3);
  Event:=Get_Event(E_Button|E_Keyboard,
                   3,1,1,1,False,0,0,0,0,False,0,0,0,0,
                   Msg,Key,Dummy,Dummy,Dummy,Dummy,Dummy);
  Show_Mouse
End;

Begin { Outside_Menu }
  W:=320; H:=200-11;
  X:=0; Y:=11;
  Open_Window(Outside_Window,X,y,W,H);
  Repeat
    Event:=Get_Event(E_Message,
                     0,0,0,0,False,0,0,0,0,False,0,0,0,0,Msg,
                     Dummy,Dummy,dummy,dummy,Dummy,Dummy);
    If (Msg[3]=3) Then
      Begin
        Obj_SetState(About_Dialog,Ok_Item,Normal,False);
        N:=Do_Dialog(About_Dialog,0);
        End_Dialog(About_Dialog);
        Menu_Normal(The_Menu,3)
      End;
    If Msg[4]=Show_Item then
      Begin
        Show_HS;
        Menu_Normal(The_Menu,High_Title);
      End;
    If (Msg[3]=High_Title) and (Msg[4]=Clear_Item) then
      Begin
        Clear_HS;
        Menu_Normal(The_Menu,High_Title);
      End;
    If (Msg[3]=Start_Title) and (Msg[4]=Start_Item) then
      Begin
        Hide_Mouse;
        Close_Window(Outside_Window);
        Erase_Menu(The_Menu);
        Set_Color_Registers(DragonColors);
        Do_maze;
        Set_Color_Registers(TitleColors);
        Menu_Normal(The_Menu,Start_Title);
        Menu_Enable(The_Menu,Last_Item);
        Draw_Menu(The_Menu);
        Open_Window(Outside_Window,X,Y,W,H);
        Show_Mouse
      End;
    If (Msg[3]=Start_Title) and (Msg[4]=Last_Item) Then
      Begin
        Hide_Mouse;
        Close_Window(Outside_Window);
        Erase_Menu(The_Menu);
        Set_Color_Registers(DragonColors);
        Show_Last;
        Set_Color_Registers(TitleColors);
        Menu_Normal(The_Menu,Start_Title);
        Draw_Menu(The_Menu);
        Open_Window(Outside_Window,X,Y,W,H);
        Show_Mouse
      End;
    If (Msg[3]=Start_Title) and (Msg[4]=I_Item) Then
      Begin
        Close_Window(Outside_Window);
        Erase_Menu(The_Menu);
        Set_Color_Registers(InstrColors);
        Show_Instr;
        Set_Color_Registers(TitleColors);
        Menu_Normal(The_Menu,Start_Title);
        Draw_Menu(The_Menu);
        Open_Window(Outside_Window,X,Y,W,H);
      End;
    If (Msg[0]=WM_Redraw) then Draw_O_Window;
  Until (Msg[0]=WM_Closed) or (Msg[4]=Quit_Item);
  Close_Window(Outside_Window);
  Erase_Menu(The_Menu);
  Delete_Dialog(About_Dialog);
  Delete_Menu(The_Menu);
  Delete_Window(HS_Window);
  Delete_Window(Outside_Window);
  Set_Color_Registers(DeskColors);
  Save_HS;
end;

Begin { Main Program }
  If Init_GEM>=0 Then
    Begin
      If Getrez=0 then
        Begin
          Init_Stuff;
          Outside_Menu
        End Else
          B:=Do_Alert(
                     '[1][ Dragon Maze will only work in low rez ][arrgh!]',1);
      Exit_Gem
    End else Writeln('Error initializing GEM')
End.

