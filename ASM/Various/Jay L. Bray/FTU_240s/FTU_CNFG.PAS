{$U35 }
Program FTU_CNFG;
{$I AuxSubs.Pas}
{$I GemSubs.Pas}

Const

  Console = 2;
  Timeout = -1;
  Bksp = 8;
  Cr  = 13;
  Lf  = 10;
  Esc = 27;
  Block_Size = 8192;

Type
  BlockIO = Packed Array[ 1..Block_Size] Of Byte;
  Cstring = packed Array[0..80] of Char;
  Errors  = Packed Array[1..70] of String[40];
  DLine   = Packed Array[1..5] of String[80];

  DTA = Packed Record
    Reserved  : Packed Array[0..19] Of Byte;
    Reserved2 : Byte;
    Attribute : Byte;
    Time      : Integer;
    Date      : Integer;
    Size      : Long_Integer;
    Name      : String[14];
  End;
    
  SysData = Packed Record
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
    
  SigData2 = Packed Record
    SigCount  : Integer;
    Sig1      : Boolean;
    Pts_K     : Integer;
    Userlog   : String[60];
    LogFile   : String[60];
    Upld_Pth  : String[60];
    Names     : Packed Array[ 1..256 ] Of String[30];
    Paths     : Packed Array[ 1..256 ] Of String[60];
    Desc_Path : Packed Array[ 1..256 ] Of String[60];
    Show_Free : Packed Array[ 1..256 ] Of Boolean;
    Use_Desc  : Packed Array[ 1..256 ] Of Boolean;
    Upload_Ok : Packed Array[ 1..256 ] Of Boolean;
    Free_Dnld : Packed Array[ 1..256 ] Of Boolean;
    CD_ROM    : Packed Array[ 1..256 ] Of Boolean;      { New 2.40 }
    SLvl_Kill : Packed Array[ 1..256 ] Of Long_Integer; { New }
    SLvl_Edit : Packed Array[ 1..256 ] Of Long_Integer; { New }
    SLvl_Name : Packed Array[ 1..256 ] Of Long_Integer; { New }
    SLvl_Vald : Packed Array[ 1..256 ] Of Long_Integer; { New }
    Mask_Comment : Packed Array[ 1..10 ] Of String[ 31 ];
    A_Path    : Packed Array[ 1..6 ] Of String[60];     { New 2.40 }
    A_Cmd     : Packed Array[ 1..6 ] Of String[8];      {     "    }
    D_Cmd     : Packed Array[ 1..6 ] Of String[8];      {     "    }
    X_Cmd     : Packed Array[ 1..6 ] Of String[8];      {     "    }
    T_Cmd     : Packed Array[ 1..6 ] Of String[8];      {     "    }
    Use_Arc   : Boolean;                                {     "    }
    Test_Arc  : Boolean;                                {     "    }
    Temp_Pth  : String[60];                             {     "    }
    Xyz_ttp   : String[60];                             {     "    }
  End;

  UserAccess = Packed Record
    User_Mask  : Packed Array[ 1..8 ] of Long_Integer;
    Sig_Accs   : Packed Array[ 1..8 ] of Long_Integer;
    Xmodem_Type: Integer;
    File_Dnld  : Integer;
    File_Upld  : Integer;
    K_Dnld     : Long_Integer; { Total Bytes  Downloaded }
    K_Upld     : Long_Integer; { Total Bytes  Uploaded }
    Pts_Dnld   : Long_Integer; { Total Points Downloaded }
    Pts_Upld   : Long_Integer; { Total Points Uploaded }
    File_Ratio : Integer;      { Files D/L : 1 }
    K_Ratio    : Integer;      {   k   D/L : 1 }
    Pts_Ratio  : Integer;      {  Pts  D/L : 1 }
    Ratio_Typ  : Integer;      { 0=None, 1=D/L, 2=K, 3=Pts }
    Colors     : Packed Array [ 0..16 ] Of Integer;
    BlankInt1  : Integer;     { New 2.40 }
    BlankInt2  : Integer;     { New 2.40 }
    BlankInt3  : Integer;     { New 2.40 }
    XpertUser  : Boolean;     { New 2.40 }
    BlankBool2 : Boolean;     { New 2.40 }
    BlankBool3 : Boolean;     { New 2.40 }
  End;

   Userdata = Packed Record
     In_Use         : Boolean;
     UHandle        : String [30];
     Name           : String [30];
     Pword          : String [15];
     Addr           : String [25];
     City           : String [20];
     State          : String [2];
     Zip            : String [10];
     Country        : String [15];
     Phone_Number   : String [15];
     Age            : Byte;
     Computer_Type  : String [14];
     Sec_lvl        : Long_Integer;
     Last_call_date : String [8];
     Time_limit_call: Integer;
     Time_limit_day : Integer;
     Mins_today     : Integer;
     Last_read_msg  : Integer;
     File_ratio     : Integer;
     File_Dnld      : Integer;
     File_Upld      : Integer;
     Messages_posted: Integer;
     Emails_sent    : Integer;
     Total_calls    : Integer;
     Video_Width    : Integer;            { video width }
     Xmodem_Type    : Integer;
     Pad_Type       : Integer;
     Flags          : Long_Integer;       { 32 on/off flags}
     Translation    : Integer;            {1=mono 2=color }
     Cont_scroll    : Boolean;
     New_user       : Boolean;
     Surveys        : Long_Integer;       { 32 survey flags }
     Scan_boards    : Long_Integer;       { 32 Q-Scan flags }
     Msg_read_mask  : Long_Integer;
     Msg_post_mask  : Long_Integer;
     Msg_edit_mask  : Long_Integer;
     Msg_delete_mask: Long_Integer;
     Msg_print_mask : Long_Integer;
     Sig_read_mask  : Long_Integer;
     Sig_validate   : Long_Integer;
     Sig_edit_desc  : Long_Integer;
     Sig_delete_file: Long_Integer;
     Sig_Accs_Mask  : Long_Integer;
   End;

  User_Rcds = Array [0..20] of UserData;

Var
  BlkIo       : BlockIO;
  System      : SysData;
  System2     : SigData2;
  UserRec     : Userdata;           { the user's userlog file entry      }
  UserAcs     : UserAccess;
  UserTmp     : UserAccess;
  User_Recs   : User_Rcds;
  Err         : Errors;
  DescL       : Dline;
  DTA_Data    : DTA;                { Blkio used For dir searches }
  Userfile    : File Of Userdata;   { the userlog data file }
  Userfilename: String[61];         { filename For the userfile }
  XProt       : Packed Array[ 0..6 ] Of String;
  Ratios      : Packed Array[ 0..6 ] Of String;

  FA,
  FE,
  FV,
  FK,
  US,
  Rez,
  Dummy,
  Fnct_Key,
  Usr_No,
  Usr_Ptr,
  Max_Users,
  NewU_Rec,
  Visit_Rec,
  Lin_Count,
  Boot_Drv    : Integer;

  File_Loaded,
  Prg_Done,
  Result      : Boolean;

  P_Path,
  Work_Path,
  F_Path,
  Wrong_Rez,
  Temp1,
  TLine       : String;

  Path,
  Boot_Path   : CString;

  Function Addr( var what: Dialog_Ptr): Long_Integer; external;

  Function CurDisk: Integer;
    GemDos($19);

  Procedure SetDta( Var B: DTA );
    Gemdos($1A);

  Function Get_SDate: Integer;
    GemDos( $2A );

  Function Create_File( Var P:Cstring; Attr: Integer ):Integer;
    GemDos( $3C );  { Attr: 0=Norm, 1=R/O 2=Hid, 4=Sys, 8=Vol }

  Function Open_File( Var P: Cstring; Md: Integer ):Integer;
    GemDos($3D);  { Md: 0=Read Only, 1=Write Only, 2=Read & Write}

  Function Close_File( H: Integer ):Integer;
    GemDos($3E);

  Function FRead_Sys(H:Integer; Count:Long_Integer; Var S:SysData):Long_Integer;
    Gemdos( $3F ); 

  Function FWrite_Sys(H:Integer; Count:Long_Integer; Var S:SysData):Long_Integer;
    Gemdos( $40 ); 

  Function FRead_Sys2(H:Integer; Count:Long_Integer; Var S:SigData2):Long_Integer;
    Gemdos( $3F );

  Function FWrite_Sys2(H:Integer; Count:Long_Integer; Var S:SigData2):Long_Integer;
    Gemdos( $40 );

  Function FWrite_Usr2(H:Integer; Count:Long_Integer; Var S:UserAccess):Long_Integer;
    Gemdos( $40 );

  Function FRead_Usr(H:Integer; Count:Long_Integer; Var S:UserData):Long_Integer;
    Gemdos( $3F ); 

  Function FRead_URecs(H:Integer; Count:Long_Integer; Var S:User_Rcds):Long_Integer;
    Gemdos( $3F ); 

  Function FRead_Usr2(H:Integer; Count:Long_Integer; Var S:UserAccess):Long_Integer;
    Gemdos( $3F ); 

  Function Fseek( Where : Long_Integer ; FHandle, Mode: Integer ):Long_Integer;
    Gemdos($42); { Mode: 0=From Start, 1=from current pos, 2=from End }  

  Procedure GetDir( Var P:CString; D:Integer );
    GemDos($47);

  Function BConStat( Device: Integer ):Integer;
    Bios(1);

  Function Bconin( Device: Integer ):Long_Integer;
    Bios(2);

  Procedure Bconout( Device: Integer; Ch: Char );
    Bios(3);

  Procedure CursConf( fnct: Integer; rate: integer );
    XBios(21);


  Function  Bit_Test( L:Long_Integer; I:Integer ):Boolean; External;
  Procedure Bit_Set ( Var L:Long_Integer; I:Integer ); External;
  Procedure Bit_Clr ( Var L:Long_Integer; I:Integer ); External;
  Function  Fsel_In( Var C1,C2:CString ):Integer; External;


  Function Inready( Device: Integer ):Boolean;
  Var
    X: Integer;
  Begin
    X := Bconstat( Device );
    If ( X=0 ) Then Inready := False Else Inready := True;
  End;

  Function Get_Console : Integer;
  Var
    X : Integer;
    I : Long_Integer;
  Begin
    Fnct_Key := 0;
     I := Bconin( Console );
    Fnct_Key := Shr( I,16 );
{    gotoxy( 0,22 ); write( fnct_key, '  ' ); }
    X := ( I & 65535 );
    Get_Console := X;
  End;

  Function Scan_Console : Integer;
  Var
    X : Integer;
  Begin
    X := TimeOut;
    If Inready(Console) Then X := Get_Console;
    Scan_Console := X;
  End;
                
  Procedure Put_Console( Ch : Char );
  Begin
    Bconout( Console, Ch );
  End;

  Function Get_Char: Char;
  Var
     I : Integer;
  Begin
     Repeat
       I := Scan_Console;
     Until ( I>Timeout );
    Get_char := Chr( I );
  End;

  Procedure Get_Line( Var S: String; Ln : Integer );
  Var
    I : Integer;
    C : Char;
  Begin
    S := '';
    Repeat
      C := Get_Char;  I := Ord( C );
      If ( I = BkSp ) And ( Length( S ) > 0 ) Then Begin
        S[0] := Chr( Length( S ) - 1 );
        Put_Console( Chr( BkSp ) );
        Put_Console( '_' );
        Put_Console( Chr( BkSp ) );
      End
      Else If ( I <> BkSp ) And ( Length( S ) < Ln ) Then Begin
        If ( I <> Cr ) and ( I <> Lf ) Then Begin
          S := Concat( S, C );
          Put_Console( C );
        End;
      End;
    Until( I = Cr ) or ( I = Lf );
  End;

  Procedure Clr_Scr;
  Begin
    GotoXY( 0,0 );
    Put_Console( Chr(Esc) );
    Put_Console( 'H' );
    Put_Console( Chr(Esc) );
    Put_Console( 'J' );
  End;

  Procedure CrLf;
  Begin
    Put_Console( Chr( Cr ) );
    Put_Console( Chr( Lf ) );
  End;

  Procedure Echo( S : String );
  Var
    I : Integer;
    Ch : Char;
  Begin
    For I := 1 To Length( S ) Do Begin
      Ch := S[ I ];
      Put_Console( Ch );
    End;
  End;

  Procedure EchoSE( S : String );
  Begin
    Echo( S );  CrLf;
  End;

  Procedure Show_Error( F:String; V:Integer );
  Var
    S : String;
    X : Integer;
    C : Char;
  Begin
    V := Abs( V );
    If ( V < 0 ) or ( V > 70 ) Then V := 70;
    CrLf;
    WriteV( S, 'System Error -', V ); EchoSE( S );
    WriteV( S, 'Desc: ', Err[V] );    EchoSE( S );
    WriteV( S, 'File: ', F );         EchoSE( S );
    CrLf;
    Echo( 'Press Return' );  C := Get_Char;
  End;

  Procedure MakeCstring( Source: String; Var Dest: Cstring );
  Var
    X : Integer;
  Begin
    For X := 1 To Length(Source) Do  Dest[X-1] := Source[X];
    X := Length( Source );
    Dest[ X ] := Chr( 0 );
    Dest[X+1] := Chr( 0 );
  End;

  Procedure MakePstring( Source: CString; Var Dest: String );
  Var
    X : Integer;
  Begin
    X := 0;
    While ( Source[X] <> #0 ) Do Begin
      Dest[X+1] := Source[X];
      X := X + 1;
    End;
    Dest[0] := Chr( X );
  End;

  Function FOpen( Var F: String; Md: Integer ):Integer;
    { Md: 0=Read Only, 1=Write Only, 2=Read & Write}
  Var
    C : Cstring;
  Begin
    MakeCstring( F, C );
    FOpen := Open_File( C, Md );
  End;

  Function FMake( Var F: String; Attr: Integer ):Integer;
    { Attr: 0=Norm, 1=R/O }
  Var
    C : Cstring;
  Begin
    MakeCstring( F, C );
    FMake := Create_File( C, Attr );
  End;

  Function File_Select( Var Name,Path : String ):Boolean;
  Var
    Ok : Boolean;
    X : Integer;
    R : Integer;
  Begin
   If ( Get_In_File( Path, Name ) ) Then Ok := True Else Ok := False;
    If ( Ok ) Then Begin
      Loop
        X := Pos( '.\', Path );
        Exit If ( X = 0 );
        If ( X > 0 ) Then Delete( Path, X, 1 );
      End;
    End;
    File_Select := Ok;
  End;

  Procedure Get_File_Sel( Md:Integer; Var S : String );
  Var
    Path, Name : String;
    Rtn, X : Integer;
  Begin
    Path := Concat( F_Path, '*.*' );
    Name := '';
    Show_Mouse;
    If ( File_Select( Name, Path ) ) Then Begin
      X := Pos( '*.*', Path );
      Delete( Path, X, 3 );
      S := Path;  X := Length( Name );
      Loop
        Exit If ( Name[ X ] = '\' ) or ( X = 1 );
        X := X - 1;
      End;
      Delete( Name, 1, X );
      If ( Md = 1 ) Then S := Concat( S, Name );
    End
    Else S := '';
  End;

  Procedure Upper_C( Var C: Char );
  Begin
    If ( C In ['a'..'z'] ) Then C := Chr( Ord(C) -32 );
  End;

  Procedure Lower_C( Var C: Char );
  Begin
    If ( C In ['A'..'Z'] ) Then C := Chr( Ord(C) +32 );
  End;

  Procedure AddSpaces( Var Line: String ; Lngth: Integer );
  Begin
    If ( Length( Line ) < Lngth ) Then Begin
      While Length(Line) < Lngth Do  Line := Concat( Line, ' ' );
    End
    Else Line[0] := Chr( Lngth );
  End;

  Function Is_Numeric( Str : String ): Boolean;
  Var
    Ch : Char;
    I, X, Ln : Integer;
  Begin
    X := 0;
    Ln := Length( Str );
    For I := 1 to Ln Do Begin
      Ch := Str[I];
      If Ch In['0'..'9'] Then X := X + 1;
    End;
    If Ln = X Then Is_Numeric := True  Else Is_Numeric := False;
  End;

  Function Exists( Filename: String ):Boolean;
  Var
    Junkfile : Text;
  Begin
     Io_check( False );
     Reset( Junkfile, Filename );
     If Io_result=0 Then Result := True  Else Result := False;
     Close( Junkfile );
     Exists := Result;
     Io_check( True );
  End;

  Function Get_LNumber( Num: Long_Integer ): Long_Integer;
  Var
    T  : String;
    I  : Long_Integer;
    Ln : Integer;
    Ch : Char;
  Begin
    T := '';  Writev( T, Num);  Ln := Length( T );  T := ''; I := -1;
    Repeat
      Repeat
        Ch := Get_Char;
      Until ( Ch In['0'..'9'] ) or ( Ord( Ch ) = 13 );
      If ( Ch In['0'..'9'] ) Then Begin
        T := Concat( T, Ch );
        Echo( Ch );
      End;
    Until ( Length( T ) = Ln ) or ( Ord( Ch ) = 13 );
    If ( Length( T ) > 0 ) Then Readv( T, I );
    If ( I < 0 ) or ( I > Num ) Then I := -1;
    Get_LNumber := I;
  End;

  Function Get_Number( Num: Integer ): Integer;
  Var
    N : Integer;
  Begin
    N := Int( Get_LNumber( Num ) );
    Get_Number := N;
  End;

  Procedure Get_MaxU;
  Var
    H : Integer;
    F : String;
    L, T : Long_Integer;
  Begin
    F := UserFileName;
    If Exists( F ) Then Begin
      T := SizeOf( UserData );
      H := FOpen( F, 0 );  L := Fseek( 0, H, 2 );
      Max_Users := ( L Div T ) - 1;
      NewU_Rec := Max_Users;
      Visit_Rec := NewU_Rec - 1;
      H := Close_File( H );
    End;
  End;

  Procedure Read_URecs( X : Integer );
  Var
    H : Integer;
    F : String;
    L, T : Long_Integer;
  Begin
    F := UserFileName;
    If Exists( F ) Then Begin
      T := SizeOf( UserData );
      H := FOpen( F, 0 );
      T := T * X;
      L := Fseek( T, H, 0 );
      If ( L < 0 ) Then Show_Error( F, L );
      L := FRead_URecs( H, Sizeof( User_Recs ), User_Recs );
      If ( L < 0 ) Then Show_Error( F, L );
      H := Close_File( H );
    End;
  End;

  Procedure Calc_Sig_Nums;
  Var
    I, Count : Integer;
  Begin
    Count := 0;
    For I := 1 to 256 Do Begin
      If Length( SysTem2.Names[ I ]) > 0 Then Count := Count + 1;
    End;
    System2.SigCount := Count;
  End;

  Procedure Save_FTU_Sig;
  Var
    Sigdataftu : text;
    X : Long_Integer;
    F : String;
  Begin
    F := 'ftu_data.sig';
    ReWrite( SigDataFtu, F );
    X := FWrite_Sys2( Handle(SigDataFtu), SizeOf(System2), System2 );
    If ( X < 0 ) Then Show_Error( F, X );
    Close( SigDataFtu );
  End;

  Procedure Save_MaskData( Num : Integer );
  Var
    X, Count : Long_Integer;
    Ftu_Mask : Text;
    F : String;
  Begin
    F := 'ftu_data.msk';
    Count := ( SizeOf(UserAcs) * (Num-1) );
    Reset( Ftu_Mask, F );
    X := Fseek( Count, Handle(Ftu_Mask), 0 );
    If ( X < 0 ) Then Show_Error( F, X );
    X := FWrite_Usr2( Handle(Ftu_Mask), SizeOf(UserAcs), UserAcs );
    If ( X < 0 ) Then Show_Error( F, X );
    Close( Ftu_Mask );
  End;

  Procedure Get_MaskData( Num : Integer );
  Var
  Ftu_Mask : Text;
    X , Count : Long_Integer;
    F : String;
  Begin
    F := 'ftu_data.msk';
    Count := ( SizeOf(UserAcs) * (Num-1) );
    Reset( Ftu_Mask, F );
    X := Fseek( Count, Handle(Ftu_Mask), 0 );
    If ( X < 0 ) Then Show_Error( F, X );
    X := FRead_Usr2( Handle(Ftu_Mask), SizeOf(UserAcs), UserAcs );
    If ( X < 0 ) Then Show_Error( F, X );
    Close( Ftu_Mask );
  End;

  Procedure Save_FTU_User;
  Var
    S1, S2, X, Count : Long_Integer;
    UsrDataFtu : Text;
    F : String;
  Begin
    F := 'ftu_data.usr';
    S1 := SizeOf(UserAcs);
    S2 := (Usr_No-1);
    Count := S1 * S2;
    Reset( UsrDataFtu, F );
    X := Fseek( Count, Handle(UsrDataFtu), 0 );
    If ( X < 0 ) Then Show_Error( F, X );
    X := FWrite_Usr2( Handle(UsrDataFtu), SizeOf(UserAcs), UserAcs );
    If ( X < 0 ) Then Show_Error( F, X );
    Close( UsrDataFtu );
  End;

  Procedure Get_Ftu_User;
  Var
    UsrDataFtu : Text;
    F : String;
    S1, S2, X , Count : Long_Integer;
  Begin
    F := 'ftu_data.usr';
    S1 := SizeOf(UserAcs);
    S2 := ( Usr_No - 1 );
    Count := S1 * S2;
    Reset( UsrDataFtu, F );
    X := Fseek( Count, Handle(UsrDataFtu), 0 );
    If ( X < 0 ) Then Show_Error( F, X );
    X := FRead_Usr2( Handle( UsrDataFtu ), SizeOf( UserAcs ), UserAcs );
    If ( X < 0 ) Then Show_Error( F, X );
    Close( UsrDataFtu );
  End;

  Procedure Get_UserData;
  Var
    S1, S2, X, Count : Long_Integer;
  Begin
    S1 := SizeOf( UserRec );
    S2 := Usr_No;
    Count := S1 * S2;
    Reset( Userfile, Userfilename );
    X := Fseek( Count, Handle(Userfile), 0 );
    If ( X < 0 ) Then Show_Error( Userfilename, X );
    X := FRead_Usr( handle(UserFile), sizeof( UserRec ), UserRec );
    If ( X < 0 ) Then Show_Error( Userfilename, X );
    Close( Userfile );
  End;

  Procedure Show_Grid;
  Var
    I : Integer;
  Begin
    GotoXY( 18,1 ); Echo( 'File SIG Areas ( "*"=Used, "-" = Not Used )' );
    GotoXY( 25,3 ); Echo( '         11111111112222222222333' );
    GotoXY( 25,4 ); Echo( '12345678901234567890123456789012' );
    GotoXY( 20,5 ); Echo( '+  0' );
    GotoXY( 20,6 ); Echo( '+ 32' );
    GotoXY( 20,7 ); Echo( '+ 64' );
    GotoXY( 20,8 ); Echo( '+ 96' );
    GotoXY( 20,9 ); Echo( '+128' );
    GotoXY( 20,10); Echo( '+160' );
    GotoXY( 20,11); Echo( '+192' );
    GotoXY( 20,12); Echo( '+224' );
  End;

  Procedure Do_Bitz( Md : Integer );
  Var
    X, Y : Integer;
    Ch : Char;
  Begin
    For Y := 1 To 8 Do Begin
      For X := 1 to 32 Do Begin
        If ( Md = 0 ) Then Ch := '-' Else Ch := '*';
        GotoXY( X+24, Y+4 );
        Echo( Ch );
      End;
    End;
  End;

  Procedure Do_Masks;
  Var
    I :Short_Integer;
    S : String;
  Begin
    Clr_Scr;
    EchoSE( 'Mask Comment' );
    EchoSE( '---- -------------------------------' );
    For I := 1 To 10 Do Begin
      GotoXY( 0,2+I );
      WriteV( S, ' ', I:2, '  ', System2.Mask_Comment[ I ] );
      Echo( S );
    End;
    GotoXY(  2,15 ); Echo( 'Enter Mask# ( 1 to 10 ) ->' );
    I := Get_Number( 10 );
    If ( I > 0 ) Then Begin
      Get_MaskData( I );
    End;
  End;

  Function Select_Bitz : Boolean;
  Var
    I, X, FArea, Y1 : Integer;
    V1 : Long_Integer;
    Ch, C2, C3 : Char;
  Begin
    FA := 0;  US := 0;  Y1 := 0;
    Repeat
      Clr_Scr;
      Show_Grid;  Do_Bitz( 0 );
      GotoXY( 0,24 );
      Echo( 'Edit [S]IG Access  [U]ser Access  Apply [M]ask  [D]one  [A]bort ->' );
      Repeat
        Ch := Get_Char;  Upper_C( Ch );
      Until( Ch In[ 'A','D','M','U','S' ] );
      If ( Ch = 'M' ) Then Begin
        Do_Masks;
        FA := 3;  US := 3;
      End
      Else If ( Ch = 'S' ) or ( Ch = 'U' ) Then Begin
        Repeat
          Clr_Scr;
          Show_Grid;
          For FArea := 1 To 8 Do Begin
            If ( Ch = 'S' ) Then V1 := UserAcs.Sig_Accs[ FArea ]
            Else If ( Ch = 'U' ) Then V1 := UserAcs.User_Mask[ FArea ];
            For I := 1 to 32 Do Begin
              If ( Bit_Test( V1, I ) ) Then C2 := '*'  Else C2 := '-';
              GotoXY( I+24, FArea+4 );
              Echo( C2 );
            End;
          End;
          GotoXY( 0,24 );
          Echo( '    [A]dd All  [C]lear All  [D]one  [E]dit  a[B]ort ->' );
          Repeat
            C2 := Get_Char;  Upper_C( C2 );
          Until( C2 In[ 'A'..'E' ] );
          If ( C2 = 'A' ) Then Begin
            Do_Bitz( 1 );
            V1 := $FFFFFFFF;
            If ( Ch = 'S' ) Then FA := 3  Else US := 3;
            For FArea := 1 to 8 Do Begin
              If ( Ch = 'S' ) Then UserAcs.Sig_Accs[ FArea ] := V1
              Else UserAcs.User_Mask[ FArea ] := V1;
            End;
          End;
          If ( C2 = 'C' ) Then Begin
            Do_Bitz( 0 );
            V1 := 0;
            If ( Ch = 'S' ) Then FA := 3  Else US := 3;
            For FArea := 1 to 8 Do Begin
              If ( Ch = 'S' ) Then UserAcs.Sig_Accs[ FArea ] := V1
              Else UserAcs.User_Mask[ FArea ] := V1;
            End;
          End;
          If ( C2 = 'E' ) Then Begin
            GotoXY( 0,24 );
            Echo( '        [1]Turn Off  [2]Turn On  [3]Select as Shown ->' );
            Y1 := Get_Number( 3 );
            If ( Y1 > 0 ) Then Begin
              If ( Ch = 'S' ) Then FA := Y1  Else US := Y1;
              For FArea := 1 to 8 Do Begin
                V1 := 0;
                For I := 1 To 32 Do Begin
                  GotoXY( I+24, FArea+4 );
                  Repeat
                    C3 := Get_Char;  Lower_C( C3 );
                  Until( C3 = '*' ) or ( C3 = '-' );
                  Echo( C3 );
                  If ( C3 = '*' ) Then Begin
                    If ( Y1 = 1 ) Then Bit_Clr( V1, I )
                    Else Bit_Set( V1, I );
                  End
                  Else If ( Y1 = 3 ) Then Bit_Clr( V1, I );
                End;
                If ( Ch = 'S' ) Then UserAcs.Sig_Accs[ FArea ] := V1
                Else UserAcs.User_Mask[ FArea ] := V1;
              End;
            End;
          End;
        Until ( C2 = 'D' ) or ( C2 = 'B' );
      End;
    Until ( Ch = 'D' ) or ( Ch = 'A' );
    If ( Ch = 'D' ) Then Select_Bitz := True  Else Select_Bitz := False;
  End;

  Procedure Select_All_Bitz;
  Var
    S1, S2, X, V, Count : Long_Integer;
    H, I, U, A : Integer;
    F, T : String;
  Begin
    For I := 1 To 8 Do Begin
      UserAcs.Sig_Accs [ I ] := 0;
      UserAcs.User_Mask[ I ] := 0;
    End;
    If ( Select_Bitz ) And ( ( FA <> 0 ) or ( US <> 0 ) ) Then Begin
      Clr_Scr;
      UserTmp := UserAcs;
      F := 'Ftu_Data.Usr';
      S1 := SizeOf( UserAcs );
      H := FOpen( F, 2 );
      For I := 1 To ( Max_Users - 2 ) Do Begin
        WriteV( T, 'Updating User#', I:4 );
        GotoXY( 30,12 );  Echo( T );
        S2 := ( I - 1 );  Count := S1 * S2;
        X := Fseek( Count, H, 0 );
        If ( X < 0 ) Then Show_Error( F, X );
        X := FRead_Usr2( H, SizeOf( UserAcs ), UserAcs );
        If ( X < 0 ) Then Show_Error( F, X );
        If ( FA <> 0 ) Then Begin
          For U := 1 To 8 Do Begin
            V := UserTmp.Sig_Accs [ U ];
            If ( FA = 1 ) Then Begin
              For A := 1 To 32 Do
                If ( Bit_Test( V, A ) ) Then Bit_Clr( UserAcs.Sig_Accs[ U ], A );
            End
            Else If ( FA = 2 ) Then Begin
              For A := 1 To 32 Do
                If ( Bit_Test( V, A ) ) Then Bit_Set( UserAcs.Sig_Accs[ U ], A );
            End
            Else If ( FA = 3 ) Then UserAcs.Sig_Accs[ U ] := V;
          End;
        End;
        If ( US <> 0 ) Then Begin
          For U := 1 To 8 Do Begin
            V := UserTmp.User_Mask[ U ];
            If ( US = 1 ) Then Begin
              For A := 1 To 32 Do
                If ( Bit_Test( V, A ) ) Then Bit_Clr( UserAcs.User_Mask[ U ], A );
            End
            Else If ( US = 2 ) Then Begin
              For A := 1 To 32 Do
                If ( Bit_Test( V, A ) ) Then Bit_Set( UserAcs.User_Mask[ U ], A );
            End
            Else If ( US = 3 ) Then UserAcs.User_Mask[ U ] := V;
          End;
        End;
        X := Fseek( Count, H, 0 );
        If ( X < 0 ) Then Show_Error( F, X );
        X := FWrite_Usr2( H, SizeOf( UserAcs ), UserAcs );
        If ( X < 0 ) Then Show_Error( F, X );
      End;
      H := Close_File( H );
    End;
  End;

  Procedure Do_ArcUtils;
  Var
    X,I : Integer;
    S,Q  : String;
  Begin
    Repeat
      Clr_Scr;
      WriteV( S, '[1] Arc.TTP File->', System2.A_Path[ 1 ] );
      GotoXY( 2,2 );  Echo( S );
      WriteV( S, '[2] Lzh.TTP File->', System2.A_Path[ 2 ] );
      GotoXY( 2,3 );  Echo( S );
      WriteV( S, '[3] Zip.TTP File->', System2.A_Path[ 3 ] );
      GotoXY( 2,4 );  Echo( S );
      WriteV( S, '[4] Temp Path   ->', System2.Temp_Pth );
      GotoXY( 2,5 );  Echo( S );

      If ( System2.Use_Arc ) Then Q := 'Yes' Else Q := 'No ';
      WriteV( S, '[5] Use Archive Utilities ->', Q );
      GotoXY( 2,7 ); Echo( S );
      If ( System2.Test_Arc ) Then Q := 'Yes' Else Q := 'No ';
      WriteV( S, '[6] Test Files Before U/L ->', Q );
      GotoXY( 40,7 ); Echo( S );

      GotoXY( 24,9 ); Echo( 'ARC.TTP       LZH.TTP       ZIP.TTP' );
      GotoXY( 2,10 ); Echo( 'Add     Command->' );
      GotoXY( 2,11 ); Echo( 'Delete  Command->' );
      GotoXY( 2,12 ); Echo( 'Extract Command->' );
      GotoXY( 2,13 ); Echo( 'Test    Command->' );
      S := Concat( '[ 7] ',System2.A_Cmd[ 1 ] ); GotoXY( 20,10 ); Echo( S );
      S := Concat( '[ 8] ',System2.A_Cmd[ 2 ] ); GotoXY( 34,10 ); Echo( S );
      S := Concat( '[ 9] ',System2.A_Cmd[ 3 ] ); GotoXY( 48,10 ); Echo( S );
      S := Concat( '[10] ',System2.D_Cmd[ 1 ] ); GotoXY( 20,11 ); Echo( S );
      S := Concat( '[11] ',System2.D_Cmd[ 2 ] ); GotoXY( 34,11 ); Echo( S );
      S := Concat( '[12] ',System2.D_Cmd[ 3 ] ); GotoXY( 48,11 ); Echo( S );
      S := Concat( '[13] ',System2.X_Cmd[ 1 ] ); GotoXY( 20,12 ); Echo( S );
      S := Concat( '[14] ',System2.X_Cmd[ 2 ] ); GotoXY( 34,12 ); Echo( S );
      S := Concat( '[15] ',System2.X_Cmd[ 3 ] ); GotoXY( 48,12 ); Echo( S );
      S := Concat( '[16] ',System2.T_Cmd[ 1 ] ); GotoXY( 20,13 ); Echo( S );
      S := Concat( '[17] ',System2.T_Cmd[ 2 ] ); GotoXY( 34,13 ); Echo( S );
      S := Concat( '[18] ',System2.T_Cmd[ 3 ] ); GotoXY( 48,13 ); Echo( S );
      GotoXY( 2,15); Echo( '[0] All Done' );
      GotoXY( 2,17); Echo( 'Choice ( 0 to 18 ) ->' );

      X := Get_Number( 18 );
      If ( X = 1 ) Then Begin
        S := '';  Get_File_Sel( 1, S );
        If ( S <> '' ) Then System2.A_Path[ 1 ] := S;
      End
      Else If ( X = 2 ) Then Begin
        S := '';  Get_File_Sel( 1, S );
        If ( S <> '' ) Then System2.A_Path[ 2 ] := S;
      End
      Else If ( X = 3 ) Then Begin
        S := '';  Get_File_Sel( 1, S );
        If ( S <> '' ) Then System2.A_Path[ 3 ] := S;
      End
      Else If ( X = 4 ) Then Begin
        S := '';  Get_File_Sel( 0, S );
        If ( S <> '' ) Then System2.Temp_Pth := S;
      End
      Else If ( X = 5 ) Then System2.Use_Arc := Not System2.Use_Arc
      Else If ( X = 6 ) Then System2.Test_Arc := Not System2.Test_Arc
      Else If ( X >= 7 ) And ( X <= 18 ) Then Begin
        GotoXY(  2,21 ); Echo( 'Enter New Command ->' );
        GotoXY( 23,21 ); Echo( '________' );  GotoXY( 23,21 );
        Get_Line( S, 8 );
        If ( X = 7 ) Then System2.A_Cmd[ 1 ] := S
        Else If ( X = 8 ) Then System2.A_Cmd[ 2 ] := S
        Else If ( X = 9 ) Then System2.A_Cmd[ 3 ] := S
        Else If ( X = 10 ) Then System2.D_Cmd[ 1 ] := S
        Else If ( X = 11 ) Then System2.D_Cmd[ 2 ] := S
        Else If ( X = 12 ) Then System2.D_Cmd[ 3 ] := S
        Else If ( X = 13 ) Then System2.X_Cmd[ 1 ] := S
        Else If ( X = 14 ) Then System2.X_Cmd[ 2 ] := S
        Else If ( X = 15 ) Then System2.X_Cmd[ 3 ] := S
        Else If ( X = 16 ) Then System2.T_Cmd[ 1 ] := S
        Else If ( X = 17 ) Then System2.T_Cmd[ 2 ] := S
        Else If ( X = 18 ) Then System2.T_Cmd[ 3 ] := S;
      End;
    Until( X = 0 );
  End;

  Procedure Do_Misc;
  Var
    X,I : Integer;
    S,Q  : String;
  Begin
    Repeat
      Clr_Scr;
      WriteV( S, '[1] Upload Path ->', System2.Upld_Pth );
      GotoXY( 2,2 );  Echo( S );
      WriteV( S, '[2] Log File    ->', System2.LogFile );
      GotoXY( 2,3 );  Echo( S );
      WriteV( S, '[3] UserData    ->', System2.Userlog );
      GotoXY( 2,4 );  Echo( S );
      WriteV( S, '[4] Xyz.TTP     ->', System2.Xyz_ttp );
      GotoXY( 2,5 );  Echo( S );

      If ( System2.Sig1 ) Then Q := 'Yes' Else Q := 'No ';
      WriteV( S, '[5] Files Uploaded To Sig#1 ->', Q );
      GotoXY( 2,7 ); Echo( S );
      WriteV( S, '[6] Points Per (k) ->', System2.Pts_K );
      GotoXY( 2,9 ); Echo( S );

      GotoXY( 2,11); Echo( '[0] All Done' );
      GotoXY( 2,13); Echo( 'Choice ( 0 to 6 ) ->' );

      X := Get_Number( 6 );
      If ( X = 1 ) Then Begin
        S := '';  Get_File_Sel( 0, S );
        If ( S <> '' ) Then Begin
          If ( S[ Length( S ) ] <> '\' ) Then S := Concat( S, '\' );
          System2.Upld_Pth := S;
        End;
      End
      Else If ( X = 2 ) Then Begin
        S := '';  Get_File_Sel( 1, S );
        If ( S <> '' ) Then System2.LogFile := S;
      End
      Else If ( X = 3 ) Then Begin
        S := '';  Get_File_Sel( 1, S );
        If ( S <> '' ) Then System2.UserLog := S;
      End
      Else If ( X = 4) Then Begin
        S := '';  Get_File_Sel( 0, S );
        If ( S <> '' ) Then System2.Xyz_TTP := S;
      End
      Else If ( X = 5 ) Then System2.Sig1 := Not System2.Sig1
      Else If ( X = 6 ) Then Begin
        GotoXY( 40,10 ); Echo( 'Enter Points Per File(0 to 9999)->' );
        I := Get_Number( 9999 );
        System2.Pts_K := I;
      End;
    Until( X = 0 );
  End;

  Procedure Do_File_Sigs;
  Var
    X1, I, X, A, FArea : Integer;
    L, V1 : Long_Integer;
    S,Qn,Qy : String;
    Ch,C2 : Char;
  Begin
    X1 := 0; Qn := 'No '; Qy := 'Yes';
    Repeat
      Clr_Scr;
      L := UserAcs.Sig_Accs[ 1 ];
      X := ( X1 * 32 ) + 1;
      For I := 1 To 16 Do Begin
        WriteV( S, X:2, ' ', System2.Names[ X ] );
        GotoXY( 2, I ); Echo( S );
        WriteV( S, X+1:2, ' ', System2.Names[ X+1 ] );
        GotoXY( 42, I ); Echo( S );
        X := X + 2;
      End;
      GotoXY( 21,24 );  Echo( '[E]dit  [N]ext  [P]revious  [D]one ->' );
      Ch := Get_Char; Upper_C( Ch );
      If ( Ch = 'P' ) And ( X1 > 0 ) Then X1 := X1 - 1;
      If ( Ch = 'N' ) And ( X1 < 7 ) Then X1 := X1 + 1;
      If ( Ch = 'E' ) Then Begin
        WriteV( S, 'Which File SIG ( ', (X1*32)+1, ' to ', (X1*32)+32, ' ) ->' );
        GotoXY( 20, 22 );  Echo( S );
        I := Get_Number( (X1*32)+32 );
        If ( I > (X1*32) ) Then Begin
          Repeat
            Clr_Scr;
            FArea := I;
            WriteV( S, '[A] Name: ', System2.Names[ FArea ] );
            GotoXY( 2, 2 );  Echo( S );
            WriteV( S, '[B] Path: ', System2.Paths[ FArea ] );
            GotoXY( 2, 3 );  Echo( S );
            WriteV( S, '[C] Desc: ', System2.Desc_Path[ FArea ] );
            GotoXY( 2, 4 );  Echo( S );
            WriteV( S, '[D] Level Required To Kill A File    : ', System2.SLvl_Kill[ FArea ] );
            GotoXY( 2, 6 );  Echo( S );
            WriteV( S, '[E] Level Required To Edit A File    : ', System2.SLvl_Edit[ FArea ] );
            GotoXY( 2, 7 );  Echo( S );
            WriteV( S, '[F] Level Required To reName A File  : ', System2.SLvl_Name[ FArea ] );
            GotoXY( 2, 8 );  Echo( S );
            WriteV( S, '[G] Level Required To Validate A File: ', System2.SLvl_Vald[ FArea ] );
            GotoXY( 2, 9 );  Echo( S );
            GotoXY( 2,11 );  Echo( '[H] Use Description      ' );
            If ( System2.Use_Desc[ FArea ] ) Then Echo( Qy ) Else Echo(Qn);
            GotoXY( 2,12 );  Echo( '[I] Show Free Uploads    ' );
            If ( System2.Show_Free[ FArea ] ) Then Echo( Qy ) Else Echo(Qn);
            GotoXY( 2,13 );  Echo( '[J] Allow Uploads        ' );
            If ( System2.Upload_Ok[ FArea ] ) Then Echo( Qy ) Else Echo(Qn);
            GotoXY( 2,14 );  Echo( '[K] Allow Free Downloads ' );
            If ( System2.Free_Dnld[ FArea ] ) Then Echo( Qy ) Else Echo(Qn);
            GotoXY( 2,15 );  Echo( '[L] CD ROM File SIG      ' );
            If ( System2.CD_ROM[ FArea ] ) Then Echo( Qy ) Else Echo(Qn);
            GotoXY( 2,17 );  Echo( '[Q] All Done' );
            GotoXY( 2,19 );  Echo( 'Choice ->' );
            C2 := Get_Char;  Upper_C( C2 );
            If ( C2 = 'A' ) Then Begin
              GotoXY(  2,21 ); Echo( 'Enter New Name ->' );
              GotoXY( 19,21 ); Echo( '______________________________' );
              GotoXY( 19,21 );
              Get_Line( S, 30 );
              System2.Names[ FArea ] := S;
            End;
            If ( C2 = 'B' ) Then Begin
              S := '';  Get_File_Sel( 0, S );
              If ( S <> '' ) Then Begin
                If ( S[ Length( S ) ] <> '\' ) Then S := Concat( S, '\' );
                System2.Paths[ FArea ] := S;
                S := Concat( S, 'DESC\' );
                System2.Desc_Path[ FArea ] := S;
              End;
            End;
            If ( C2 = 'C' ) Then Begin
              S := '';  Get_File_Sel( 0, S );
              If ( S <> '' ) Then Begin
                If ( S[ Length( S ) ] <> '\' ) Then S := Concat( S, '\' );
                System2.Desc_Path[ FArea ] := S;
              End;
            End;
            If ( C2 = 'D' ) Then Begin
              GotoXY( 41,6 );  Echo( 'Enter New Value (0-99999)->' );
              System2.SLvl_Kill[ FArea ] := Get_LNumber( 99999 );
            End;
            If ( C2 = 'E' ) Then Begin
              GotoXY( 41,7 );  Echo( 'Enter New Value (0-99999)->' );
              System2.SLvl_Edit[ FArea ] := Get_LNumber( 99999 );
            End;
            If ( C2 = 'F' ) Then Begin
              GotoXY( 41,8 );  Echo( 'Enter New Value (0-99999)->' );
              System2.SLvl_Name[ FArea ] := Get_LNumber( 99999 );
            End;
            If ( C2 = 'G' ) Then Begin
              GotoXY( 41,9 );  Echo( 'Enter New Value (0-99999)->' );
              System2.SLvl_Vald[ FArea ] := Get_LNumber( 99999 );
            End;
            If ( C2 = 'H' ) Then
              System2.Use_Desc[ FArea ] := NOT System2.Use_Desc[ FArea ];
            If ( C2 = 'I' ) Then
              System2.Show_Free[ FArea ] := NOT System2.Show_Free[ FArea ];
            If ( C2 = 'J' ) Then
              System2.Upload_Ok[ FArea ] := NOT System2.Upload_Ok[ FArea ];
            If ( C2 = 'K' ) Then
              System2.Free_Dnld[ FArea ] := NOT System2.Free_Dnld[ FArea ];
            If ( C2 = 'L' ) Then
              System2.CD_ROM[ FArea ] := NOT System2.CD_ROM[ FArea ];
          Until ( C2 = 'Q' );
        End;
      End; { Edit }
    Until ( Ch = 'D' );
  End;

  Procedure Get_SysData;
  Var
    N, P : String;
    S    : String;
    C    : CString;
    H, I : Integer;
    L, Count: Long_Integer;
  Begin
    N := 'SYSDATA.DAT';
    P := Concat( Work_Path, '*.*' );
    If ( File_Select( N, P ) ) And ( Pos ( 'SYSDATA.DAT', N ) > 2 )
      And ( Exists( N ) ) Then Begin
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
      System2.Sig1      := False;
      System2.Pts_K     := 2;
      For I := 1 to 9 Do  System2.Mask_Comment[ I ] := '';
      System2.Mask_Comment[ 10 ] := 'SysOp Status';
      For I := 1 To 256 Do Begin
        System2.Names    [ I ] := '';
        System2.Paths    [ I ] := '';
        System2.Desc_Path[ I ] := '';
        System2.Use_Desc [ I ] := True;
        System2.Show_Free[ I ] := False;
        System2.Upload_Ok[ I ] := True;
        System2.Free_Dnld[ I ] := False;
        System2.CD_ROM   [ I ] := False;
        System2.Slvl_Kill[ I ] := -1;
        System2.Slvl_Edit[ I ] := -1;
        System2.Slvl_Name[ I ] := -1;
        System2.Slvl_Vald[ I ] := -1;
      End;
      For I := 1 To 32 Do Begin
        System2.Names[ I ] := System.SIG_Name[ I ];
        System2.Paths[ I ] := System.SIG_Path[ I ];
        System2.Use_Desc [ I ] := System.SIG_Desc[ I ];
        System2.Desc_Path[ I ] := Concat( System2.Paths[ I ], 'DESC\' );
        System2.Show_Free[ I ] := System.SIG_Show_Free[ I ];
      End;
    End
    Else UserFilename  := 'XXX';
  End;

  Procedure Put_2nd_Reg;
  Var
    Date, H, I : Integer;
    L : Long_Integer;
    S : String;
    C : CString;
  Begin
    S  := 'FTU.INT';  MakeCString( S, C );
    Date := Get_SDate;
    System.Hi_Msg := Date;
    H  := Create_File( C, 7 );
    If ( H > 0 ) Then L  := FWrite_Sys( H, SizeOf( System ), System );
    I  := Close_File( H );
  End;

  Procedure Get_FTU_SysData;
  Var
    Sigdatafile : text;
    I, J : Integer;
    F, S : String;
    Ch : Char;
    count : Long_Integer;
  Begin
    F := 'ftu_data.sig';
    If Exists( F ) Then Begin
      Reset( Sigdatafile, F );
      Count := Fseek( 0, Handle(SigdataFile), 0);
      If ( Count < 0 ) Then Show_Error( F, Count );
      Count := FRead_Sys2( handle(sigdatafile), sizeof(system2), System2 );
      If ( Count < 0 ) Then Show_Error( F, Count );
      Close( Sigdatafile );
      UserFileName := System2.UserLog;
      Get_MaxU;
    End
    Else Echo( 'FTU_DATA.SIG File Is Missing!' );
  End;

  Procedure Make_New_File;
  Var
    H, I, U, Users, Dum1 : Integer;
    X, Count : Long_Integer;
    F,
    SigDataFtu,
    UsrDataFtu,
    Sig_Mask    : String;
    C : Cstring;
  Begin
    Get_SysData;
    F := UserFileName;  I := 4;
    If ( F <> 'XXX' ) Then Repeat
      Clr_Scr;
      Put_2nd_Reg;
      GotoXY( 2, 2 );  Echo( '[1] Init FTU System File' );
      GotoXY( 2, 3 );  Echo( '[2] Init FTU User   File' );
      GotoXY( 2, 4 );  Echo( '[3] Init FTU Mask   File' );
      GotoXY( 2, 5 );  Echo( '[4] Done' );
      GotoXY( 2, 7 );  Echo( 'Choice ->' );
      I := Get_Number( 4 );
      If ( I = 1 ) Then Begin
        MakeCString( 'FTU_DATA.SIG', C );
        H := Create_File( C, 0 );
        Count := FWrite_Sys2( H, SizeOf( System2 ), System2 );
        I := Close_File( H );
      End
      Else If ( I = 2 ) Then Begin
        MakeCString( F, C );
        H := Open_File( C, 0 );
        X := Fseek( 0, H, 2 );
        I := Close_File( H );
        Users := (X Div SizeOf( UserRec )) - 1;
        UserAcs.K_Dnld := 0;     UserAcs.K_Upld := 0;
        UserAcs.Pts_Dnld := 0;   UserAcs.Pts_Upld := 0;
        UserAcs.File_Ratio := 0; UserAcs.K_Ratio := 0;
        UserAcs.Pts_Ratio := 0;  UserAcs.Ratio_Typ := 1;
        UserAcs.XpertUser := False;
        MakeCString( 'FTU_DATA.USR', C );
        H := Create_File( C, 0 );
        For I := 1 To Users Do 
          Count := FWrite_Usr2( H, SizeOf( UserAcs ), UserAcs );
        I := Close_File( H );
        Get_MaxU;
      End
      Else If ( I = 3 ) Then Begin
        MakeCString( 'FTU_DATA.MSK', C );
        H := Create_File( C, 0 );
        For U := 1 To 8 Do Begin
          UserAcs.User_Mask [ U ] := 0;
          UserAcs.Sig_Accs  [ U ] := 0;
        End;
        For I := 1 To 10 Do Begin
          If ( I = 10 ) Then For U := 1 To 8 Do Begin
            UserAcs.User_Mask [ U ] := $FFFFFFFF;
            UserAcs.Sig_Accs  [ U ] := $FFFFFFFF;
          End;
          Count := FWrite_Usr2( H, SizeOf( UserAcs ), UserAcs );
        End;
        I := Close_File( H );
      End;
    Until( I = 4 );
  End;

  Procedure Extend_Ftu_User;
  Var
    Exp_U, Ftu_U, X : Long_Integer;
    S1, S2, Count : Long_Integer;
    H, I, Num : Integer;
    UsrDataFtu : Text;
    F, S : String;
    Ch : Char;
  Begin
    Clr_Scr;
    Exp_U := 0;  Ftu_U := 0;
    Reset( Userfile, Userfilename );
    X := Fseek( 0, Handle(Userfile), 2 );
    Close( Userfile );
    If ( X < 0 ) Then Show_Error( UserFileName, X )
      Else Exp_U := (X Div SizeOf( UserRec )) - 1;
    F := 'ftu_data.usr';
    S1 := SizeOf(UserAcs);
    S2 := ( Usr_No - 1 );
    Count := S1 * S2;
    Reset( UsrDataFtu, F );
    X := Fseek( 0, Handle(UsrDataFtu), 2 );
    Close( UsrDataFtu );
    If ( X < 0 ) Then Show_Error( F, X )
      Else Ftu_U := ( X Div SizeOf(UserAcs) );
    WriteV( S, 'Old Users = ', Exp_U, '  New Users = ', Ftu_U );
    GotoXY( 20, 10 );  Echo( S );
    GotoXY( 20, 12 );  Echo( 'Extend Users (Y/N)? ' );
    Repeat
      Ch := Get_Char;  Upper_C( Ch );
    Until( Ch = 'Y' ) or ( Ch = 'N' );
    If ( Ftu_U < Exp_U ) And ( Ch = 'Y' ) Then Begin
      Num := Exp_U - Ftu_U;
      H := FOpen( F, 2 );
      If ( H < 0 ) Then Show_Error( F, H )
      Else Begin;
        X := Fseek( 0, H, 2 );
        For I := 1 to Num Do Begin
          X := FWrite_Usr2( H, SizeOf(UserAcs), UserAcs );
          If ( X < 0 ) Then Show_Error( F, X );
        End;
        X := Close_File( H );
      End;
    End;
  End;

  Function Show_User_Info( Var N, H : String ): Boolean;
  Var
    S : String;
    I : Integer;
    L : Long_Integer;
    Ch : Char;
  Begin
    Show_User_Info := False;
    Repeat
      Clr_Scr;
      GotoXY( 2,0 ); Echo( N );  GotoXY( 42, 0 ); Echo( H );
      Writev( S, '             User# ', Usr_No );
      GotoXY( 2,2 ); Echo( S );
      Writev( S, '[A]     File Ratio ', UserAcs.File_Ratio );
      GotoXY( 2,3 ); Echo( S );
      Writev( S, '[B]        k/Ratio ', UserAcs.K_Ratio );
      GotoXY( 2,4 ); Echo( S );
      Writev( S, '[C]      Pts/Ratio ', UserAcs.Pts_Ratio );
      GotoXY( 2,5 ); Echo( S );
      Writev( S, '[D]      Downloads ', UserAcs.File_Dnld );
      GotoXY( 2,6 ); Echo( S );
      Writev( S, '[E]    k Downloded ', UserAcs.K_Dnld );
      GotoXY( 2,7 ); Echo( S );
      Writev( S, '[F] Pts Downloaded ', UserAcs.Pts_Dnld );
      GotoXY( 2,8 ); Echo( S );
      Writev( S, '[G]        Uploads ', UserAcs.File_Upld );
      GotoXY( 2,9 ); Echo( S );
      Writev( S, '[H]     k Uploaded ', UserAcs.K_Upld );
      GotoXY( 2,10); Echo( S );
      Writev( S, '[I]   Pts Uploaded ', UserAcs.Pts_Upld );
      GotoXY( 2,11); Echo( S );
      Writev( S, '[J]  Xfer Protocol ', XProt[ UserAcs.Xmodem_Type ] );
      GotoXY( 2,12); Echo( S );
      Writev( S, '[K]     Ratio Type ', Ratios[ UserAcs.Ratio_Typ ] );
      GotoXY( 2,13); Echo( S );
      GotoXY( 2,15 ); Echo( '[L] Edit File Sig Access' );
      GotoXY( 2,17 ); Echo( '[Q] All Done' );
      GotoXY( 2,19 ); Echo( 'Choice ->' );
      Repeat
        Ch := Get_Char; Upper_C( Ch );
      Until( Ch IN[ 'A'..'L', 'Q' ] );
      If ( Ch <> 'Q' ) Then Show_User_Info := True;
      If ( Ch = 'L' ) Then Result := Select_Bitz;
      If ( Ch = 'J' ) Then Begin
        UserAcs.XModem_Type := UserAcs.XModem_Type + 1;
        If ( UserAcs.XModem_Type > 5 ) Then UserAcs.XModem_Type := 0;
      End
      Else If ( Ch = 'K' ) Then Begin
        UserAcs.Ratio_Typ := UserAcs.Ratio_Typ + 1;
        If ( UserAcs.Ratio_Typ > 4 ) Then UserAcs.Ratio_Typ := 1;
      End
      Else If ( Ch = 'A' ) Then Begin
        GotoXY( 30, 3 ); Write('Enter New Value (0-999)->' );
        UserAcs.File_Ratio := Get_Number( 999 );
      End
      Else If ( Ch = 'B' ) Then Begin
        GotoXY( 30, 4 ); Write('Enter New Value (0-999)->' );
        UserAcs.K_Ratio  := Get_Number( 999 );
      End
      Else If ( Ch = 'C' ) Then Begin
        GotoXY( 30, 5 ); Echo('Enter New Value (0-999)->' );
        UserAcs.Pts_Ratio:= Get_Number( 999 );
      End
      Else If ( Ch = 'D' ) Then Begin
        GotoXY( 30, 6 ); Echo('Enter New Value (0-32767)->' );
        UserAcs.File_Dnld:= Get_Number( 32767 );
      End
      Else If ( Ch = 'E' ) Then Begin
        GotoXY( 30, 7 ); Echo('Enter New Value (0-99999999->' );
        UserAcs.K_Dnld   := Get_LNumber( 99999999 );
      End
      Else If ( Ch = 'F' ) Then Begin
        GotoXY( 30, 8 ); Echo('Enter New Value (0-99999999)->' );
        UserAcs.Pts_Dnld := Get_LNumber( 99999999 );
      End
      Else If ( Ch = 'G' ) Then Begin
        GotoXY( 30, 9 ); Echo('Enter New Value (0-32767)->' );
        UserAcs.File_Upld  := Get_Number( 32767 );
      End
      Else If ( Ch = 'H' ) Then Begin
        GotoXY( 30,10 ); Echo('Enter New Value ->' );
        UserAcs.K_Upld   := Get_LNumber( 99999999 );
      End
      Else If ( Ch = 'I' ) Then Begin
        GotoXY( 30,11 ); Echo( 'Enter New Value ->' );
        UserAcs.Pts_Upld := Get_LNumber( 99999999 );
      End;
    Until ( Ch = 'Q' );
  End;

  Procedure Edit_User( U : Integer );
  Var
    Name, Hand : String;
  Begin
    Usr_No := U;
    Get_Ftu_User;
    Get_UserData;
    Name := UserRec.Name;  Hand := UserRec.UHandle;
    If ( Show_User_Info( Name, Hand ) ) Then Save_FTU_User;
  End;

  Procedure Edit_Usr_Masks;
  Var
    X, I : Integer;
    Name, Hand : String;
    S : String;
    Ch : Char;
  Begin
    Repeat
      Clr_Scr;
      EchoSE( 'Mask Comment' );
      EchoSE( '---- -------------------------------' );
      Ch := 'D';
      For X := 1 To 10 Do Begin
        WriteV( S, ' ', X:2, '  ', System2.Mask_Comment[ X ] );
        GotoXY( 0,1+X ); Echo( S );
      End;
      GotoXY(  30,15 ); Echo( '[E]dit Mask  [D]one' );
      GotoXY(  35,17 ); Echo( 'Choice ->' );
      Ch := Get_Char;  Upper_C( Ch );
      If ( Ch = 'E' ) Then Begin
        GotoXY(  2,19 ); Echo( 'Enter Mask# ( 1 to 10 ) ->' );
        I := Get_Number( 10 );
        If ( I > 0 ) Then Begin
          GotoXY(  2,19 ); Echo( ' Edit Mask Comment (Y/N) ->' );
          Repeat
            Ch := Get_Char;  Upper_C( Ch );
          Until( Ch = 'Y' ) or ( Ch = 'N' );
          If ( Ch = 'Y' ) Then Begin
            GotoXY(  2,19 ); Echo( 'New Mask Comment -> ' );
            GotoXY( 22,19 ); Echo( '_______________________________' );
            GotoXY( 22,19 );
            Get_Line( S, 31 );  System2.Mask_Comment[ I ] := S;
          End;
          Usr_No := I;
          Get_MaskData( I );
          WriteV( Name, 'Mask Data #', I ); Hand := System2.Mask_Comment[I];
          If ( Show_User_Info( Name, Hand ) ) Then Save_MaskData( I );
        End;
      End;
    Until ( Ch = 'D' );
  End;

  Procedure Show_User_Listing;
  Var
    Ptr, Pg, I, I2, R, X, Mx, Max :Integer;
    L : Long_Integer;
    S : String;
    Name, Hand : String;
    Ch : Char;
  Begin
    Read_URecs( Usr_Ptr );
    Max := Max_Users - 19;  Pg := 0;
    Clr_Scr;
    EchoSE( 'User  Handle                         Name' );
    EchoSE( '----- ------------------------------ ------------------------------' );
    Ch := 'D';
    Repeat
      I := 0;
      Loop
        I2 := I + Usr_Ptr;
        GotoXY(  0,2+I ); Clr_Eos;
        WriteV( S, I2:5 );
        GotoXY(  0,2+I ); Echo( S );
        S := User_Recs[I].UHandle;
        GotoXY(  6,2+I ); Echo( S );
        S := User_Recs[I].Name;
        GotoXY( 37,2+I ); Echo( S );
        I := I + 1;
        Exit If ( I > 19 ) or ( I2 = Max_Users );
      End;
      GotoXY(  0,23 ); Echo( '[E]dit User  [-]Previous  [+]Next  [D]one ->' );
      Ch := Get_Char;  Upper_C( Ch );
      If ( Ch = 'E' ) Then Begin
        X := ( Pg * 20 ) + 1;  Mx := X + 19;
        If ( Mx > Max_Users ) Then Mx := Max_Users;
        WriteV( S, 'Enter User# ( ',X,' to ',Mx,' ) ->' );
        GotoXY(  2,24 ); Echo( S );
        R := Get_Number( Max_Users );
        If ( R >= X ) And ( R <= Mx ) Then Begin
          Usr_No := R;
          R := ( R - ( Pg * 20 ) - 1 );
          Get_Ftu_User;
          UserRec:= User_Recs[ R ];
          Name   := User_Recs[ R ].Name;
          Hand   := User_Recs[ R ].UHandle;
          If ( Show_User_Info( Name, Hand ) ) Then Begin
            User_Recs[ R ] := UserRec;
            Save_FTU_User;
          End;
        End;
      End
      Else If ( Ch ='-' ) And ( Usr_Ptr > 19 ) Then Begin
        Usr_Ptr := Usr_Ptr - 20;
        Pg := Pg - 1;
        Read_URecs( Usr_Ptr );
      End
      Else If ( Ch = '+' ) And ( Usr_Ptr < Max ) Then Begin
        Usr_Ptr := Usr_Ptr + 20;
        Pg := Pg + 1;
        Read_URecs( Usr_Ptr );
      End;
    Until( Ch = 'D' );
  End;

  Procedure Do_Menu;
  Var
    I : Integer;
    Ch : Char;
  Begin
    Prg_Done := False;
    File_Loaded := False;
    Usr_Ptr := 1;  Usr_No := 1;
    Repeat
      Clr_Scr;
      EchoSE( '     FTU_CNFG.PRG     ' );
      EchoSE( '  (c) By Jay L. Bray  ' );
      EchoSE( '     Version 2.40     ' );
      EchoSE( '     Feb 26, 1995     ' );
      CrLf;
      EchoSE( ' [L]  Load  FTU System Files' );
      EchoSE( ' [S]  Save  FTU System Files' );
      EchoSE( ' [I] Create FTU System Files' );
      CrLf;
      EchoSE( ' [C] Change All Sec Levels' );
      EchoSE( ' [E] Extend FTU User File ' );
      EchoSE( ' [R] Edit Archive Utilities' );
      EchoSE( ' [M] Edit Misc FTU        ' );
      CrLf;
      EchoSE( ' [U] Edit User From Listing' );
      EchoSE( ' [N] Edit New User Record ' );
      EchoSE( ' [V] Edit Visitor  Record ' );
      CrLf;
      EchoSE( ' [F] Edit File Sigs       ' );
      EchoSE( ' [X] Edit Masks           ' );
      EchoSE( ' [Q] Quit                 ' );
      CrLf;
      Echo( ' Enter Choice ->' );
      Ch := Get_Char;  Upper_C( Ch );
      If ( Ch In[ 'C','E','F','M','N','R','S','U','V','X' ] ) And ( Not File_Loaded ) Then Begin
        Clr_Scr;
        EchoSE( 'You MUST [L]oad or [I] Create The Files First Before Editing...' );
        CrLf;
        Echo( 'Press Return ' ); Ch := Get_Char;  Ch := 'A';
      End;
      Case Ch Of
        'L' : Begin
                Get_FTU_SysData;         { L }
                File_Loaded := True;
              End;
        'S' : Save_FTU_Sig;              { S }
        'I' : Begin
                Make_New_File;           { I }
                File_Loaded := True;
              End;
        'C' : Select_All_Bitz;           { C }
        'E' : Extend_Ftu_User;           { E }
        'R' : Do_ArcUtils;               { R }
        'M' : Do_Misc;                   { M }
        'U' : Show_User_Listing;         { U }
        'N' : Edit_User( NewU_Rec );     { N }
        'V' : Edit_User( Visit_Rec );    { V }
        'X' : Edit_Usr_Masks;            { X }
        'F' : Do_File_SIGS;              { F }
        'Q' : Prg_Done := True;          { Q }
     End; { Case }
    Until( Prg_Done );
  End;

Begin                     (* Main Program Begins Here... *)

  Err[1] := 'General Error';
  Err[2] := 'Drive Not Ready';
  Err[3] := 'Unknown Command';
  Err[4] := 'CRC Error';
  Err[5] := 'Bad Request';
  Err[6] := 'Seek Error';
  Err[7] := 'Unknown Media';
  Err[8] := 'Sector Not Found';
  Err[9] := 'No Paper';
  Err[10]:= 'Write Error';
  Err[11]:= 'Read Error';
  Err[12]:= 'General Error';
  Err[13]:= 'Disk Write Protected';
  Err[14]:= 'Disk Was Changed';
  Err[15]:= 'Unknown Device';
  Err[16]:= 'Bad Sector';
  Err[17]:= 'Insert Disk';
  Err[32]:= 'Invalid Function Number';
  Err[33]:= 'File Not Found';
  Err[34]:= 'Pathname Not Found';
  Err[35]:= 'Too Many Files Open';
  Err[36]:= 'Access Not Possible';
  Err[37]:= 'Invalid Handle Number';
  Err[39]:= 'Not Enough Memory';
  Err[40]:= 'Invalid Memory Block Address';
  Err[46]:= 'Invalid Drive Specification';
  Err[49]:= 'No More Files';
  Err[64]:= 'GEMDOS range error, Seek Wrong?';
  Err[65]:= 'GEMDOS internal error';
  Err[66]:= 'Invalid executable file format';
  Err[67]:= 'Memory Block Growth Failure';
  Err[68]:= 'Oops, YOU Messed Up!!!';
  Err[70]:= 'Unknown Error';

  XProt[ 0 ] := 'Xmodem    ';
  XProt[ 1 ] := 'Xmodem Crc';
  XProt[ 2 ] := 'Xmodem 1k ';
  XProt[ 3 ] := 'Ymodem    ';
  XProt[ 4 ] := 'Zmodem    ';
  XProt[ 5 ] := 'Ymodem G  ';
  XProt[ 6 ] := '??????    ';

  Ratios[ 1 ] := 'File   ';
  Ratios[ 2 ] := '(k)Size';
  Ratios[ 3 ] := 'Points ';
  Ratios[ 4 ] := 'None   ';

  Dummy := Init_GEM;
  SetDta( DTA_Data );
  GetDir( Boot_Path, 0 );
  MakePString( Boot_Path, TLine );
  Path     := Boot_Path;
  P_Path   := TLine;
  Boot_Drv := CurDisk;
  F_Path   := Concat( Chr( Ord('A') + Boot_Drv ), ':', TLine, '\' );
  Work_Path:= F_Path;
  Curs_On;
  CursConf( 2,3 );
  Do_Menu;
  Curs_Off;
  Exit_Gem;
End.

