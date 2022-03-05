{$S50 }
Program FTU_INIT;
{$I AuxSubs.Pas}
{$I GEMSubs.Pas}

Const
  Console = 2;
  Cr  = 13;
  Lf  = 10;
  Esc = 27;
  Block_Size = 8192;

Type

  BlockIO  = Packed Array[ 1..Block_Size] Of Byte;
  CString  = Packed Array[ 0..80  ] Of Char;

  DTA = Packed Record
    Reserved  : Packed Array[0..19] Of Byte;
    Reserved2 : Byte;
    Attribute : Byte;
    Time      : Integer;
    Date      : Integer;
    Size      : Long_Integer;
    Name      : String[14];
  End;

  UserAccess = Packed Record
    User_Mask : Packed Array[ 1..8 ] of Long_Integer;
    Sig_Accs  : Packed Array[ 1..8 ] of Long_Integer;
    Sig_Valid : Packed Array[ 1..8 ] of Long_Integer;
    Sig_Edit  : Packed Array[ 1..8 ] of Long_Integer;
    Sig_Kill  : Packed Array[ 1..8 ] of Long_Integer;
    K_Dnld    : Long_Integer; { Total Bytes  Downloaded }
    K_Upld    : Long_Integer; { Total Bytes  Uploaded }
    Pts_Dnld  : Long_Integer; { Total Points Downloaded }
    Pts_Upld  : Long_Integer; { Total Points Uploaded }
    DL_Ratio  : Integer;      { Files D/L : 1 }
    K_Ratio   : Integer;      {   k   D/L : 1 }
    Pts_Ratio : Integer;      {  Pts  D/L : 1 }
    Ratio_Typ : Integer;      { 0=None, 1=D/L, 2=K, 3=Pts }
  End;

  SigData2 = Packed Record
    Sigcount  : Integer;
    Sig1      : Boolean;
    Pts_K     : Integer;
    Names     : Packed Array[ 1..256 ] Of String[30];
    Paths     : Packed Array[ 1..256 ] Of String[60];
    Show_Free : Packed Array[ 1..256 ] Of Boolean;
    Use_Desc  : Packed Array[ 1..256 ] Of Boolean;
    Desc_Path : Packed Array[ 1..256 ] Of String[60];
    Userlog   : String[60];
    LogFile   : String[60];
    Upld_Pth  : String[60];
    Upload_Ok : Packed Array[ 1..256 ] Of Boolean;
    Free_Dnld : Packed Array[ 1..256 ] Of Boolean;
  End;
    
  Sysdata = Packed Record
    Hi_Msg          : Integer;
    Todays_Date     : String [8];
    Total_Calls     : Long_Integer;
    Calls_Today     : Integer;
    Feedback_Mode   : Byte;
    Total_Msg_Bases : Byte;
    Min_Baud_Rate   : Byte;  { 0, 1, 2 }
    Max_Baud_Rate   : Byte;  { 0, 1, 2 }
    Start_Baud_Rate : Byte;  { 0, 1, 2 }
    Secondary_Pword : String [15];
    Message_Path    : String [60];
    Upload_Path     : String [60]; { v1.60 }
    Fmail_Path      : String [60]; { v1.60 }
    Userlog_Path    : String [60];
    Helpfile_Path   : String [60];
    Help40_Path     : String [60];
    Logfile         : String [60];
    Message_Drives  : Packed Array [1..32] of Char;
    Num_Of_SIGs     : Byte;
    SIG_Name        : Packed Array [1..32] of String [30];
    SIG_Path        : Packed Array [1..32] of String [60];
    SIG_Desc        : Packed Array [1..32] of Boolean;
    SIG_Show_Free   : Packed Array [1..32] of Boolean;
  End;
    
Var
  BlkIo       : BlockIO;
  System      : Sysdata;
  System2     : SigData2;
  UserAcs     : UserAccess;
  DTA_Data    : DTA;                { Blkio used For dir searches }
  Userfilename: String[61];         { filename For the userfile }
  Dum,
  Usr_No      : Integer;
  Boot_Drv    : Integer;
  Temp1,
  Work_Path   : String;
  Boot_Path   : CString;
  Info_Dial   : Dialog_Ptr ;


  Function CurDisk: Integer;
    GemDos( $19 );

  Procedure SetDta( Var B: DTA );
    Gemdos($1A);

  Function Get_SDate: Integer;
    GemDos( $2A );

  Function Create_File( Var P:Cstring; Attr: Integer ):Integer;
    GemDos( $3C );  { Attr: 0=Norm, 1=R/O 2=Hid, 4=Sys, 8=Vol }

  Function Open_File( Var P: Cstring; Md: Integer ):Integer;
    GemDos( $3D );  { Md: 0=Read Only, 1=Write Only, 2=Read & Write}

  Function Close_File( H: Integer ):Integer;
    GemDos( $3E );

  Function FRead_Sys(H:Integer; Count:Long_Integer; Var S:SysData):Long_Integer;
    Gemdos( $3F ); 

  Function FWrite_Sys(H:Integer; Count:Long_Integer; Var S:SysData):Long_Integer;
    Gemdos( $40 ); 

  Function FWrite_Sys2(H:Integer; Count:Long_Integer; Var S:SigData2):Long_Integer;
    Gemdos( $40 );

  Function FWrite_Usr2(H:Integer; Count:Long_Integer; Var S:UserAccess):Long_Integer;
    Gemdos( $40 );

  Function Fseek( Where : Long_Integer ; FHandle, Mode: Integer ):Long_Integer;
    Gemdos( $42 ); { Mode: 0=From Start, 1=from current pos, 2=from End }  

  Procedure GetDir( Var P:CString; Drive: Integer );
    GemDos( $47 );

  Function Rwabs( Flg:Integer; Var B:BlockIo; Num, Sct, Drv : Integer ):Integer;
    Bios( 4 );  { Flg = 0-Read, 1-Write } 


  Procedure Info_Msg( Msg : Str255) ;
  Var
  Item, dial_ind : Tree_Index ;
  Begin
    info_dial := New_Dialog( 2, 20, 2, 40, 1 );
    item := Add_Ditem( info_dial, G_BoxText, None, 1, 0, 38, 1,
          0, D_Color( Black, Black, True, 0, 0 ) );
    Set_Dtext( info_dial, item, msg, System_Font, TE_Center ) ;
    Obj_Draw( info_dial, 0, 255, 155, 12, 0, 0 ) ;
    Show_Dialog( info_dial, 0 );
  End ;

  Procedure MakePString( Name:Cstring; Var S: String );
  Var I: Integer;
  Begin
    S := '';  I := 0;
    While ( Name[ I ] <> #0 ) Do Begin
      S := Concat( S, Name[ I ] );
      I := I + 1;
    End;
  End;

  Procedure MakeCstring( Source: String; Var Dest: Cstring );
  Var
    X : Integer;
  Begin
    For X := 1 To Length(Source) Do  Dest[X-1] := Source[X];
    X := Length(Source);
    Dest[X] := Chr(0);
  End;

  Function File_Select( Var Name,Path : String ):Boolean;
  Begin
    File_Select := Get_In_File( Path, Name );
  End;

  Procedure Get_SysData;
  Var
    N, P : String;
    S    : String;
    C    : CString;
    H, I : Integer;
    Count: Long_Integer;
  Begin
    N := 'SYSDATA.DAT';
    P := Concat( Work_Path, '*.*' );
    Info_Msg( 'Select SysData File' ) ;
    If File_Select( N, P ) Then Begin
      MakeCString( N, C );
      H := Open_File( C, 0 );
      Count := Fseek( 0, H, 0);
      Count := FRead_Sys( H, Sizeof( System ), System );
      I := Close_File( H );
      Userfilename      := System.Userlog_Path;
      System2.UserLog   := System.UserLog_Path;
      System2.LogFile   := System.LogFile;
      System2.Upld_Pth  := System.Upload_Path;
      System2.SigCount  := System.Num_Of_Sigs;
      System2.Sig1      := True;
      System2.Pts_K     := 2;
      For I := 1 To 32 Do Begin
        System2.Names[ I ] := System.SIG_Name[ I ];
        System2.Paths[ I ] := System.SIG_Path[ I ];
        System2.Use_Desc [ I ] := System.SIG_Desc[ I ];
        System2.Desc_Path[ I ] := Concat( System2.Paths[ I ], 'DESC\' );
        System2.Show_Free[ I ] := System.SIG_Show_Free[ I ];
        System2.Upload_Ok[ I ] := True;
        System2.Free_Dnld[ I ] := False;
      End;
    End
    Else UserFilename  := 'XXX';
    End_Dialog( Info_Dial ) ;
    Delete_Dialog( Info_Dial );
  End;

  Procedure Put_2nd_Reg;
  Var
    Date, H, I : Integer;
    L : Long_Integer;
    S : String;
    C : CString;
    B1,B2 : Byte;
  Begin
    S  := 'FTU.INT';  MakeCString( S, C );
    Date := Get_SDate;
    B1 := Shr( Date, 8 );
    B2 := ( Date & 255 );
    H  := Create_File( C, 7 );
    System.Hi_Msg := Date;
    If ( H > 0 ) Then L  := FWrite_Sys( H, SizeOf( System ), System );
    I  := Close_File( H );
  End;

  Procedure Make_New;
  Var
    X : Long_Integer;
    H, I, U, Users : Integer;
    Count : Long_Integer;
    SigDataFtu,
    UsrDataFtu,
    Sig_Mask    : String;
    C : Cstring;
  Begin
    Put_2nd_Reg;
    MakeCString( Userfilename, C );
    H := Open_File( C, 0 );
    X := Fseek( 0, H, 2 );
    I := Close_File( H );
    Users := (X Div 292) - 1;
    Writeln( ' ' );
    WriteLn( 'Your UserData File Can Hold Up To ', Users-2, ' Users...' );
    Writeln( ' ' );
    UserAcs.K_Dnld := 0;    UserAcs.K_Upld := 0;
    UserAcs.Pts_Dnld := 0;  UserAcs.Pts_Upld := 0;
    UserAcs.DL_Ratio := 0;  UserAcs.K_Ratio := 0;
    UserAcs.Pts_Ratio := 0; UserAcs.Ratio_Typ := 1;
    MakeCString( 'FTU_DATA.USR', C );
    H := Create_File( C, 0 );
    For I := 1 To Users Do 
      Count := FWrite_Usr2( H, SizeOf(UserAcs), UserAcs );
    I := Close_File( H );
    MakeCString( 'FTU_DATA.MSK', C );
    H := Create_File( C, 0 );
    For I := 1 To 10 Do Begin
      If ( I = 1 ) Then Begin
        For U := 1 To 8 Do Begin
          UserAcs.User_Mask [ U ] := -1;
          UserAcs.Sig_Accs  [ U ] := -1;
          UserAcs.Sig_Valid [ U ] := -1;
          UserAcs.Sig_Edit  [ U ] := -1;
          UserAcs.Sig_Kill  [ U ] := -1;
        End;
      End;
      Count := FWrite_Usr2( H, SizeOf(UserAcs), UserAcs );
    End;
    I := Close_File( H );
    MakeCString( 'FTU_DATA.SIG', C );
    H := Create_File( C, 0 );
    Count := FWrite_Sys2( H, SizeOf(System2), System2 );
    I := Close_File( H );
  End;

Begin                     (* Main Program Begins Here... *)
  If ( Init_Gem >= 0 ) Then Begin
    Show_Mouse;
    Work_Path := Concat( Chr( CurDisk + 65 ), ':' );
    GetDir( Boot_Path, 0 ) ;
    MakePString( Boot_Path, Temp1 );
    Work_Path := ConCat( Work_Path, Temp1, '\' );
    Get_SysData;
    If ( UserFileName <> 'XXX' ) Then Begin
      WriteLn( 'File Transfer Utility (FTU) Initializer' );
      WriteLn( ' ' );
      WriteLn( 'Creating FTU Data Files...' );
      Make_New;
      WriteLn( 'Done...' );
    End
    Else WriteLn( 'FTU Initializer Aborted...' );
    Exit_Gem;
  End;
End.

