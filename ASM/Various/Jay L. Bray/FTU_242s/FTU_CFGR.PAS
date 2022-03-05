{$U350 }
Program FTU_CFGR;
{$I AuxSubs.Pas}
{$I GemSubs.Pas}

Const
{$I FTU_Cfgr.Inc}

  Console = 2;
  Timeout = -1;
  Bksp = 8;
  Cr  = 13;
  Lf  = 10;
  Esc = 27;
  Block_Size = 8192;
  max_windows = 7 ;

Type
  BlockIO = Packed Array[ 1..Block_Size] Of Byte;
  Cstring = packed Array[0..80] of Char;
  Errors  = Packed Array[1..70] of String[40];
  DLine   = Packed Array[1..5] of String[80];
  window_range = -1..max_windows;

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
    CD_ROM    : Packed Array[ 1..256 ] Of Boolean; { New }
    SLvl_Kill : Packed Array[ 1..256 ] Of Long_Integer; { New }
    SLvl_Edit : Packed Array[ 1..256 ] Of Long_Integer; { New }
    SLvl_Name : Packed Array[ 1..256 ] Of Long_Integer; { New }
    SLvl_Vald : Packed Array[ 1..256 ] Of Long_Integer; { New }
    Mask_Comment : Packed Array[ 1..10 ] Of String[ 31 ];
  End;

  UserAccess = Packed Record
    User_Mask  : Packed Array[ 1..8 ] of Long_Integer;
    Sig_Accs   : Packed Array[ 1..8 ] of Long_Integer;
    Xmodem_Type: Integer;
    Downloads  : Integer;
    Uploads    : Integer;
    K_Dnld     : Long_Integer; { Total Bytes  Downloaded }
    K_Upld     : Long_Integer; { Total Bytes  Uploaded }
    Pts_Dnld   : Long_Integer; { Total Points Downloaded }
    Pts_Upld   : Long_Integer; { Total Points Uploaded }
    DL_Ratio   : Integer;      { Files D/L : 1 }
    K_Ratio    : Integer;      {   k   D/L : 1 }
    Pts_Ratio  : Integer;      {  Pts  D/L : 1 }
    Ratio_Typ  : Integer;      { 0=None, 1=D/L, 2=K, 3=Pts }
    Colors     : Packed Array [ 0..16 ] Of Integer;
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
     Dl_ratio       : Integer;
     Downloads      : Integer;
     Uploads        : Integer;
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

  Prg_Done,
  Menu_On,
  Result      : Boolean;

  P_Path,
  Work_Path,
  F_Path,
  Wrong_Rez,
  Temp1,
  TLine       : String;

  Path,
  Boot_Path   : CString;

  Menu        : Menu_Ptr;

  About_Dial  : Dialog_Ptr;

  N5_String   : String[5];
  N8_String   : String[8];
  N10_String  : String[10];
  N15_String  : String[15];
  N20_String  : String[20];
  N25_String  : String[25];
  N30_String  : String[30];
  N31_String  : String[31];
  B5_Str      : String[5];
  B8_Str      : String[8];
  B10_Str     : String[10];
  B15_Str     : String[15];
  B20_Str     : String[20];
  B25_Str     : String[25];
  B30_Str     : String[30];
  B31_Str     : String[31];
  B60_Str     : String[60];
  P60_String  : String[60];

{$I Gem_Box.Pas }

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

  Function Inready( Device: Integer ):Boolean;
    Bios(1);

  Function Bconin( Device: Integer ):Long_Integer;
    Bios(2);

  Procedure Bconout( Device: Integer; Ch: Char );
    Bios(3);

  Function Get_Rez : Integer ;
    Xbios( 4 ) ;

  Function  Bit_Test( L:Long_Integer; I:Integer ):Boolean; External;
  Procedure Bit_Set ( Var L:Long_Integer; I:Integer ); External;
  Procedure Bit_Clr ( Var L:Long_Integer; I:Integer ); External;
  Function  Fsel_In( Var C1,C2:CString ):Integer; External;


  Procedure Show_Error( F:String; V:Integer );
  Var
    S : String[255];
    X : Integer;
  Begin
    V := Abs( V );
    WriteV( S, '-', V ); If ( V < 0 ) or ( V > 70 ) Then V := 70;
    S := Concat( '[1][ System Error ', S, ' | ', Err[V],' | ', F, ' |  ][ Ok ]' );
    X := Do_Alert( F, 1 );
  End;

  Procedure ReadLVal( S: String; Var V: Long_Integer );
  Var
    Minus: Boolean;
    I, N : Integer;
  Begin
    I := 1;
    While (I < Length(S)) And (S[I] = ' ') Do I := I + 1;
    N := 0;
    If ( Length(S) >= I ) Then Begin
      If S[I] <> '-' Then Minus := False
      Else Begin
        Minus := True;
        I := I + 1;
      End;
      While (I <= Length(S)) And (S[I] In ['0'..'9']) Do Begin
        N := (N * 10) + Ord(S[I]) - Ord('0');
        I := I + 1;
      End;
      If Minus Then N := -N;
    End;
    V := N;
  End;

  Procedure ReadVal( S: String; Var V: Integer );
  Var
    L : Long_Integer;
  Begin
    ReadLVal( S, L );
    V := Int( L );
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

  Procedure Form_Do( Item, State :Short_Integer );
  Var
    FormD_Obj : Dialog_Ptr;
  Begin
    Find_Dialog( Item, FormD_Obj);
    Center_Dialog(FormD_Obj);
    Dummy := Do_Dialog( FormD_Obj, 0) & $7fff;
    Obj_SetState( FormD_Obj, Dummy, State, False ) ;
    End_Dialog(FormD_Obj);
    Delete_Dialog(FormD_Obj);
  End;

  Function Which_Window ( Wind_handle: Integer): Window_Range;
  Var
    I: integer;
    Found: boolean;
  Begin
    I := 1;
    found := false;
    WHILE (i <= max_windows) AND NOT found DO
      IF handle = wind_handle THEN found := true
      ELSE i := i + 1;
    IF found THEN which_window := i
    ELSE which_window := No_Window;
  END;

  Procedure Do_Redraw ( Window, X0, Y0, W0, H0: Integer );
  Var
    X, Y, W, H: Integer;
    Index : Window_Range;
  Begin
   Index := Which_Window( Window );
   Hide_Mouse;
   First_Rect( Window, X, Y, W, H ); { Get Coordinates Of Window }
     While ( W <> 0 ) Or ( H <> 0 ) Do Begin
       If Rect_Intersect( x0, y0, w0, h0, x, y, w, h ) Then Begin
         Set_Clip( x, y, w, h);      { set boundaries of text in window }
         Paint_Style( Solid );
         Paint_Color( White );
         Paint_Rect( x, y, w, h);
         END;
       Next_Rect( window, x, y, w, h );{move to the next rectangle}
     END;
   Show_Mouse
  End;

  Procedure Disable_Menu;
  Begin
    Menu_Enable ( Menu, F_Load );
    Menu_Enable ( Menu, Make_Neu );
    Menu_Disable( Menu, F_Save );
    Menu_Disable( Menu, Ext_Ulog );
    Menu_Disable( Menu, Misc );
    Menu_Disable( Menu, Chg_All_Sec_Lvls );
    Menu_Disable( Menu, Frm_Usr_Lstng );
    Menu_Disable( Menu, New_URec );
    Menu_Disable( Menu, Vis_Rec );
    Menu_Disable( Menu, Usr_Masks );
    Menu_Disable( Menu, FileSigs );
    Menu_On := False;
  End;

  Procedure Enable_Menu;
  Begin
    Menu_Disable( Menu, F_Load );
    Menu_Disable( Menu, Make_Neu );
    Menu_Enable ( Menu, F_Save );
    Menu_Enable ( Menu, Chg_All_Sec_Lvls );
    Menu_Enable ( Menu, Ext_Ulog );
    Menu_Enable ( Menu, Misc );
    Menu_Enable ( Menu, Frm_Usr_Lstng );
    Menu_Enable ( Menu, Vis_Rec );
    Menu_Enable ( Menu, New_URec );
    Menu_Enable ( Menu, Usr_Masks );
    Menu_Enable ( Menu, FileSigs );
    Menu_On := True;
  End;

  Procedure Get_Dialog( D: Dialog_Ptr; Item:Short_Integer; Var X, Y, W, H :Integer; Var A: Long_Integer );
  Begin
    A := Lpeek( Addr( D ) );
    X := Wpeek( A + ( Item * 24) + 16 );
    Y := Wpeek( A + ( Item * 24) + 18 );
    W := Wpeek( A + ( Item * 24) + 20 );
    H := Wpeek( A + ( Item * 24) + 22 );
  End;

  Function File_Select( Var Name,Path : String ):Boolean;
  Var
    Ok : Boolean;
    X : Integer;
    Ps,Ns,T : String;
    Pc,Nc : CString;
    R : Integer;
  Begin
   If ( Get_In_File( Path, Name ) ) Then Ok := True Else Ok := False;
 {   MakeCString( Path, Pc );  MakeCString( Name, Nc );
    R := Fsel_In( Nc,Pc );
    MakePString( Pc, Ps );  MakePString( Nc, Ns );
    If ( R = 0 ) Then Ok := False;
    If ( R = 1 ) And ( Path = Ps )  And ( Name = Ns ) Then Ok := False;
    If ( R = 1 ) Then Ok := True; }
    If ( Ok ) Then Begin
   {   Path := Ps;  Name := Ns; }
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
      X := Pos( '*.*', Path ); Path[0] := Chr( X-1 );
      S := Path;
      If ( Md = 1 ) Then S := Concat( S, Name );
    End
    Else S := '';
  End;

  Function Upper_C( C: Char ): Char;
  Begin
    If ( C In ['a'..'z'] ) Then C := Chr( Ord(C) -32 );
    Upper_C := C    
  End;

  Function Lower_C( C: Char ): Char;
  Begin
    If ( C In ['A'..'Z'] ) Then C := Chr( Ord(C) +32 );
    Lower_C := C    
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

  Procedure Do_Bitz( F : Dialog_Ptr; Md : Integer );
  Var
    I, X, X1 : Short_Integer;
  Begin
    For X := 1 To 8 Do Begin
      If ( X = 1 ) Then X1 := Box1
      Else If ( X = 2 ) Then X1 := Box33
      Else If ( X = 3 ) Then X1 := Box65
      Else If ( X = 4 ) Then X1 := Box97
      Else If ( X = 5 ) Then X1 := Box129
      Else If ( X = 6 ) Then X1 := Box161
      Else If ( X = 7 ) Then X1 := Box193
      Else If ( X = 8 ) Then X1 := Box225;
      For I := 1 to 32 Do Begin
        If ( Md = 0 ) Then Obj_SetState( F, X1, Normal, True )
        Else Obj_SetState( F, X1, Selected, True );
        If ( X1 = Box9 ) or ( X1 = Box19 ) or ( X1 = Box29 ) 
        or ( X1 = Box39 ) or ( X1 = Box49 ) or ( X1 = Box59 ) 
        or ( X1 = Box69 ) or ( X1 = Box79 ) or ( X1 = Box89 ) 
        or ( X1 = Box99 ) or ( X1 = Box109 ) or ( X1 = Box119 ) 
        or ( X1 = Box129 ) or ( X1 = Box139 ) or ( X1 = Box149 ) 
        or ( X1 = Box159 ) or ( X1 = Box169 ) or ( X1 = Box179 ) 
        or ( X1 = Box189 ) or ( X1 = Box199 ) or ( X1 = Box209 ) 
        or ( X1 = Box219 ) or ( X1 = Box229 ) or ( X1 = Box239 ) 
        or ( X1 = Box249 ) Then X1 := X1 + 2
        Else X1 := X1 + 1;
      End;
    End;
  End;

  Procedure Do_Masks;
  Var
    Masks_Dial : Dialog_Ptr;
    X,I :Short_Integer;
    Temp : String[255];
  Begin
    Find_Dialog( Masks, Masks_Dial );
    Center_Dialog( Masks_Dial );
    For X := 1 To 10 Do Begin
      I := ( X * 2 ) + 1;
      Set_DText( Masks_Dial, I, System2.Mask_Comment[ X ], System_Font, TE_Left );
    End;
    Repeat
      Dummy := Do_Dialog( Masks_Dial, 0) & $7fff;
      Obj_SetState( Masks_Dial, Dummy, Normal + Shadowed, True );
      If ( Dummy >= Msk_B1 ) And ( Dummy <= Msk_B10 ) Then Begin
        X := ( Dummy Div 2 );
        Get_MaskData( X );
      End;
    Until ( Dummy = Msks_Cnx );
    End_Dialog( Masks_Dial );
    Delete_Dialog( Masks_Dial );
  End;

  Function Select_Bitz : Boolean;
  Var
    F1_Dial : Dialog_Ptr;
    X1, Y1, W1, H1, I, X, Dum1, Dum2, FArea : Short_Integer;
    L, V1 : Long_Integer;
    Frst : Boolean;
  Begin
    Frst := False;
    FA := 0;  US := 0;  Y1 := 0;
    Find_Dialog( Select_Bits, F1_Dial );
    Center_Dialog( F1_Dial );
    Obj_SetState( F1_Dial, Add_All, Disabled, False );
    Obj_SetFlags( F1_Dial, Add_All, None );
    Obj_SetState( F1_Dial, Clear_All, Disabled, False );
    Obj_SetFlags( F1_Dial, Clear_All, None );
    Obj_SetState( F1_Dial, Sel2_Ok, Disabled, False );
    Obj_SetFlags( F1_Dial, Sel2_Ok, None );
    Obj_SetState( F1_Dial, Sel2_Cnx, Disabled, False );
    Obj_SetFlags( F1_Dial, Sel2_Cnx, None );
    Repeat
      If ( Frst ) Then Dum1 := ReDo_Dialog( F1_Dial, 0) & $7fff
      Else Dum1 := Do_Dialog( F1_Dial, 0) & $7fff;
 {     If ( Frst = False ) Then Frst := True; }

      If ( Dum1 = Apply_Mask ) Then Begin
        Do_Masks;
        Obj_SetState( F1_Dial, Dum1, Shadowed, False );
        FA := 3;  US := 3;
      End;

      If ( Dum1 = FSig_Access ) or ( Dum1 = Usr_Sig_Accs ) Then Begin
        Repeat
          Obj_SetState( F1_Dial, Dum1, Disabled, True );
          If ( Dum1 <> FSig_Access ) Then
            Obj_SetState( F1_Dial, FSig_Access, Disabled, True );
          If ( Dum1 <> Usr_Sig_Accs ) Then
            Obj_SetState( F1_Dial, Usr_Sig_Accs, Disabled, True );
          Obj_SetFlags( F1_Dial, Apply_Mask, None );
          Obj_SetState( F1_Dial, Apply_Mask, Disabled, True );
          Obj_SetFlags( F1_Dial, FSig_Access, None );
          Obj_SetFlags( F1_Dial, Usr_Sig_Accs, None );
          Obj_SetState( F1_Dial, Select_Ok, Disabled, True );
          Obj_SetFlags( F1_Dial, Select_Ok, None );
          Obj_SetState( F1_Dial, Select_Cnx, Disabled, True );
          Obj_SetFlags( F1_Dial, Select_Cnx, None );
          Obj_SetState( F1_Dial, Add_All, Normal, True );
          Obj_SetFlags( F1_Dial, Add_All, Selectable + Touch_Exit );
          Obj_SetState( F1_Dial, Clear_All, Normal, True );
          Obj_SetFlags( F1_Dial, Clear_All, Selectable + Touch_Exit );
          Obj_SetState( F1_Dial, Sel2_Ok, Normal, True );
          Obj_SetFlags( F1_Dial, Sel2_Ok, Selectable + Default + Touch_Exit );
          Obj_SetState( F1_Dial, Sel2_Cnx, Normal, True );
          Obj_SetFlags( F1_Dial, Sel2_Cnx, Selectable + Touch_Exit );
          For FArea := 1 To 8 Do Begin
            If ( Dum1 = FSig_Access ) Then V1 := UserAcs.Sig_Accs[ FArea ]
            Else If ( Dum1 = Usr_Sig_Accs ) Then V1 := UserAcs.User_Mask[ FArea ];
            If ( FArea = 1 ) Then X1 := Box1
            Else If ( FArea = 2 ) Then X1 := Box33
            Else If ( FArea = 3 ) Then X1 := Box65
            Else If ( FArea = 4 ) Then X1 := Box97
            Else If ( FArea = 5 ) Then X1 := Box129
            Else If ( FArea = 6 ) Then X1 := Box161
            Else If ( FArea = 7 ) Then X1 := Box193
            Else If ( FArea = 8 ) Then X1 := Box225;
            For I := 1 to 32 Do Begin
              If ( Bit_Test( V1,I ) ) Then Obj_SetState( F1_Dial, X1, Selected, True )
              Else Obj_SetState( F1_Dial, X1, Normal, True );
              If ( X1 = Box9 ) or ( X1 = Box19 ) or ( X1 = Box29 ) 
              or ( X1 = Box39 ) or ( X1 = Box49 ) or ( X1 = Box59 ) 
              or ( X1 = Box69 ) or ( X1 = Box79 ) or ( X1 = Box89 ) 
              or ( X1 = Box99 ) or ( X1 = Box109 ) or ( X1 = Box119 ) 
              or ( X1 = Box129 ) or ( X1 = Box139 ) or ( X1 = Box149 ) 
              or ( X1 = Box159 ) or ( X1 = Box169 ) or ( X1 = Box179 ) 
              or ( X1 = Box189 ) or ( X1 = Box199 ) or ( X1 = Box209 ) 
              or ( X1 = Box219 ) or ( X1 = Box229 ) or ( X1 = Box239 ) 
              or ( X1 = Box249 ) Then X1 := X1 + 2
              Else X1 := X1 + 1;
            End;
          End;
          Dum2 := ReDo_Dialog( F1_Dial, 0) & $7fff;
          Obj_SetState( F1_Dial, Dum2, Normal, True );
          If ( Dum2 = Add_All ) Then Begin
            Do_Bitz( F1_Dial, 1 );
            V1 := $FFFFFFFF;
            For FArea := 1 to 8 Do Begin
              If ( Dum1 = FSig_Access ) Then UserAcs.Sig_Accs[ FArea ] := V1
              Else UserAcs.User_Mask[ FArea ] := V1;
            End;
          End;
          If ( Dum2 = Clear_All ) Then Begin
            Do_Bitz( F1_Dial, 0 );
            V1 := 0;
            For FArea := 1 to 8 Do Begin
              If ( Dum1 = FSig_Access ) Then UserAcs.Sig_Accs[ FArea ] := V1
              Else UserAcs.User_Mask[ FArea ] := V1;
            End;
          End;
          If ( Dum2 = Sel2_Ok ) Then Begin
            If ( Obj_State( F1_Dial, Turn_Off ) & Selected <> 0 ) Then Y1 := 1
            Else If ( Obj_State( F1_Dial, Turn_On ) & Selected <> 0 ) Then Y1 := 2
            Else If ( Obj_State( F1_Dial, Select_As_Shown ) & Selected <> 0 ) Then Y1 := 3;
            If ( Dum1 = FSig_Access ) Then FA := Y1
            Else If ( Dum1 = Usr_Sig_Accs ) Then US := Y1;
            For FArea := 1 to 8 Do Begin
              V1 := 0;
              If ( FArea = 1 ) Then X1 := Box1
              Else If ( FArea = 2 ) Then X1 := Box33
              Else If ( FArea = 3 ) Then X1 := Box65
              Else If ( FArea = 4 ) Then X1 := Box97
              Else If ( FArea = 5 ) Then X1 := Box129
              Else If ( FArea = 6 ) Then X1 := Box161
              Else If ( FArea = 7 ) Then X1 := Box193
              Else If ( FArea = 8 ) Then X1 := Box225;
              For I := 1 To 32 Do Begin
                If ( Obj_State( F1_Dial, X1 ) & Selected <> 0 ) Then Begin
                  If ( Y1 = 1 ) Then Bit_Clr( V1,I )
                  Else If ( Y1 = 2 ) or ( Y1 = 3 ) Then Bit_Set( V1,I );
                End
                Else
                  If ( Obj_State( F1_Dial, Select_As_Shown ) & Selected <> 0 ) Then Bit_Clr( V1,I );
                If ( X1 = Box9 ) or ( X1 = Box19 ) or ( X1 = Box29 ) 
                or ( X1 = Box39 ) or ( X1 = Box49 ) or ( X1 = Box59 ) 
                or ( X1 = Box69 ) or ( X1 = Box79 ) or ( X1 = Box89 ) 
                or ( X1 = Box99 ) or ( X1 = Box109 ) or ( X1 = Box119 ) 
                or ( X1 = Box129 ) or ( X1 = Box139 ) or ( X1 = Box149 ) 
                or ( X1 = Box159 ) or ( X1 = Box169 ) or ( X1 = Box179 ) 
                or ( X1 = Box189 ) or ( X1 = Box199 ) or ( X1 = Box209 ) 
                or ( X1 = Box219 ) or ( X1 = Box229 ) or ( X1 = Box239 ) 
                or ( X1 = Box249 ) Then X1 := X1 + 2
                Else X1 := X1 + 1;
              End;
              If ( Dum1=FSig_Access ) Then UserAcs.Sig_Accs[ FArea ] := V1
              Else If ( Dum1=Usr_Sig_Accs ) Then UserAcs.User_Mask[ FArea ] := V1;
            End;
          End;
          If ( Dum2 = Sel2_Cnx ) or ( Dum2 = Sel2_Ok ) Then Begin
            Obj_SetFlags( F1_Dial, FSig_Access, Selectable + Touch_Exit );
            Obj_SetFlags( F1_Dial, Usr_Sig_Accs, Selectable + Touch_Exit );
            Obj_SetState( F1_Dial, FSig_Access, Normal, True );
            Obj_SetState( F1_Dial, Usr_Sig_Accs, Normal, True );
            Obj_SetState( F1_Dial, Sel2_Ok, Disabled, True );
            Obj_SetFlags( F1_Dial, Sel2_Ok, None );
            Obj_SetState( F1_Dial, Sel2_Cnx, Disabled, True );
            Obj_SetFlags( F1_Dial, Sel2_Cnx, None );
            Obj_SetState( F1_Dial, Select_Ok, Shadowed, True );
            Obj_SetFlags( F1_Dial, Select_Ok, Selectable + Default + Touch_Exit );
            Obj_SetState( F1_Dial, Select_Cnx, Shadowed, True );
            Obj_SetFlags( F1_Dial, Select_Cnx, Selectable + Touch_Exit );
            Obj_SetFlags( F1_Dial, Apply_Mask, Selectable + Touch_Exit );
            Obj_SetState( F1_Dial, Apply_Mask, Shadowed, True );
            Obj_SetState( F1_Dial, Add_All, Disabled, False );
            Obj_SetFlags( F1_Dial, Add_All, None );
            Obj_SetState( F1_Dial, Clear_All, Disabled, False );
            Obj_SetFlags( F1_Dial, Clear_All, None );
          End;
        Until ( Dum2 = Sel2_Ok ) or ( Dum2 = Sel2_Cnx );
      End;
    Until ( Dum1 = Select_Ok ) or ( Dum1 = Select_Cnx );
    Obj_SetState( F1_Dial, Dum1, Shadowed, False );
    End_Dialog( F1_Dial );
    Delete_Dialog( F1_Dial );
    If ( Dum1 = Select_Ok ) Then Select_Bitz := True
      Else Select_Bitz := False;
  End;

  Procedure Select_All_Bitz;
  Var
    F1_Dial : Dialog_Ptr;
    S1, S2, X, V, Count : Long_Integer;
    H, I, U, A : Integer;
    F, T : String;
  Begin
    Find_Dialog( Update_Info, F1_Dial );
    Center_Dialog( F1_Dial );
    For I := 1 To 8 Do Begin
      UserAcs.Sig_Accs [ I ] := 0;
      UserAcs.User_Mask[ I ] := 0;
    End;
    If ( Select_Bitz ) And ( ( FA <> 0 ) or ( US <> 0 ) ) Then Begin
      UserTmp := UserAcs;
      F := 'Ftu_Data.Usr';
      S1 := SizeOf( UserAcs );
      H := FOpen( F, 2 );
      Show_Dialog( F1_Dial, 0 );
      For I := 1 To ( Max_Users - 2 ) Do Begin
        WriteV( T, I:4 );
        Set_Dtext( F1_Dial, Updt_Txt, T, System_Font, TE_Left );
        Obj_ReDraw( F1_Dial, Updt_Txt );
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
    End_Dialog( F1_Dial );
    Delete_Dialog( F1_Dial );
  End;

  Procedure Do_Misc;
  Var
    M_Dial : Dialog_Ptr;
    Dum1   : Short_Integer;
    S      : String;
    Temp   : String[ 255 ];
  Begin
    Find_Dialog( Misc_Vars, M_Dial );  Center_Dialog( M_Dial );
    S := System2.Upld_Pth;
    Set_Dedit( M_Dial, Upload_Path, B60_Str, P60_String, S, System_Font, TE_Left );
    S := System2.LogFile;
    Set_DEdit( M_Dial, UserLog_File, B60_Str, P60_String, S, System_Font, TE_Left );
    S := System2.Userlog;
    Set_DEdit( M_Dial, UserData_File, B60_Str, P60_String, S, System_Font, TE_Left );

    If ( System2.Sig1 ) Then Obj_SetState( M_Dial, Sig1_Y, Selected, True )
      Else Obj_SetState( M_Dial, Sig1_N, Selected, True );
    WriteV( S, System2.Pts_K );
    Set_DEdit( M_Dial, Pnts_File, '____', '9999', S, System_Font, TE_Left );

    Repeat
      Dum1 := Do_Dialog( M_Dial, 0) & $7fff;
      Obj_SetState( M_Dial, Dum1, Shadowed, True );
      If ( Dum1 = Upload_Path ) Then Begin
        S := '';  Get_File_Sel( 0, S );
        If ( S <> '' ) Then
        Set_Dedit( M_Dial, Upload_Path, B60_Str, P60_String, S, System_Font, TE_Left );
      End;
      If ( Dum1 = UserLog_File ) Then Begin
        S := '';  Get_File_Sel( 1, S );
        If ( S <> '' ) Then
        Set_DEdit( M_Dial, UserLog_File, B60_Str, P60_String, S, System_Font, TE_Left );
      End;
      If ( Dum1 = UserData_File ) Then Begin
        S := '';  Get_File_Sel( 1, S );
        If ( S <> '' ) Then
        Set_DEdit( M_Dial, UserData_File, B60_Str, P60_String, S, System_Font, TE_Left );
      End;
      If ( Dum1 = Misc_Ok ) Then Begin
        Get_Dedit( M_Dial, Upload_Path, Temp );
        If ( Temp[ Length( Temp ) ] <> '\' ) Then Temp := Concat( Temp, '\' );
        System2.Upld_Pth := Temp;
        Get_Dedit( M_Dial, UserLog_File, Temp );  System2.LogFile := Temp;
        Get_Dedit( M_Dial, UserData_File, Temp );  System2.UserLog:= Temp;
        Get_DEdit( M_Dial, Pnts_File, Temp );  ReadVal( S, System2.Pts_K );
        If ( Obj_State( M_Dial, Sig1_Y ) & Selected <> 0 ) Then System2.Sig1 := True
          Else System2.Sig1 := False;
      End;
    Until ( Dum1 = Misc_Ok ) or ( Dum1 = Misc_Cnx );
    End_Dialog( M_Dial );
    Delete_Dialog( M_Dial );
  End;

  Procedure Do_File_Sigs;
  Var
    F1_Dial, F2_Dial : Dialog_Ptr;
    X1, I, X, Dum1, Dum2, FArea : Short_Integer;
    L, V1 : Long_Integer;
    S : String;
    Temp : String[ 255 ];
  Begin
    Find_Dialog( File_SIGS, F1_Dial );  Center_Dialog( F1_Dial );
    X1 := 0;
    Repeat
      L := UserAcs.Sig_Accs[ 1 ];  I := FSig_Nm1;
      Set_Dtext( F1_Dial, FSigs_UName, UserRec.Name, System_Font, TE_Center );
      X := ( X1 * 32 ) + 1;
      Repeat
        WriteV( Temp, X );
        Set_Dtext( F1_Dial, I, Temp, Small_Font, TE_Right );
        Temp := System2.Names[ X ];
        Set_Dtext( F1_Dial, I+1, Temp, Small_Font, TE_Left );
        I := I + 2; X := X + 1;
      Until ( I > FSig_Nm32 );
      Dum1 := Do_Dialog( F1_Dial, 0) & $7fff;
      If ( Dum1 >= FSig_N1 ) And ( Dum1 <= FSig_N32 ) Then Obj_SetState( F1_Dial, Dum1, Normal, True )
      Else Obj_SetState( F1_Dial, Dum1, Shadowed, True );
      If ( Dum1 = Prev_FSig ) And ( X1 > 0 ) Then X1 := X1 - 1;
      If ( Dum1 = Next_FSig ) And ( X1 < 7 ) Then X1 := X1 + 1;
      If ( Dum1 >= FSig_N1 ) And ( Dum1 <= FSig_N32 ) Then Begin
        Find_Dialog( FSig_More, F2_Dial );  Center_Dialog( F2_Dial );
        FArea := ( ( Dum1 - 2 ) div 2 ) + ( X1 * 32 );
        Temp := System2.Names[ FArea ];
        Set_DEdit( F2_Dial, FSig_Name, B30_Str, N30_String, Temp, System_Font, TE_Left );
        Temp := System2.Paths[ FArea ];
        Set_DEdit( F2_Dial, FSig_Path, B60_Str, P60_String, Temp, System_Font, TE_Left );
        Temp := System2.Desc_Path[ FArea ];
        Set_DEdit( F2_Dial, FSig_Desc, B60_Str, P60_String, Temp, System_Font, TE_Left );

        Writev( Temp, System2.SLvl_Kill[ FArea ] );
        Set_DEdit( F2_Dial, SLvl_Kill, '_____', '99999', Temp, System_Font, TE_Left );
        Writev( Temp, System2.SLvl_Edit[ FArea ] );
        Set_DEdit( F2_Dial, SLvl_Edit, '_____', '99999', Temp, System_Font, TE_Left );
        Writev( Temp, System2.SLvl_Name[ FArea ] );
        Set_DEdit( F2_Dial, SLvl_Name, '_____', '99999', Temp, System_Font, TE_Left );
        Writev( Temp, System2.SLvl_Vald[ FArea ] );
        Set_DEdit( F2_Dial, SLvl_Valid, '_____', '99999', Temp, System_Font, TE_Left );

        Obj_SetState( F2_Dial, Desc_Y, Normal, False );
        Obj_SetState( F2_Dial, Desc_N, Normal, False );
        Obj_SetState( F2_Dial, Free_SP_Y, Normal, False );
        Obj_SetState( F2_Dial, Free_SP_N, Normal, False );
        Obj_SetState( F2_Dial, Free_DL_Y, Normal, False );
        Obj_SetState( F2_Dial, Free_DL_N, Normal, False );
        Obj_SetState( F2_Dial, Upld_Y, Normal, False );
        Obj_SetState( F2_Dial, Upld_N, Normal, False );
        Obj_SetState( F2_Dial, CD_ROM_Y, Normal, False );
        Obj_SetState( F2_Dial, CD_ROM_N, Normal, False );

        If ( System2.Use_Desc[ FArea ] ) Then Obj_SetState( F2_Dial, Desc_Y, Selected, True )
          Else Obj_SetState( F2_Dial, Desc_N, Selected, True );
        If ( System2.Show_Free[ FArea ] ) Then Obj_SetState( F2_Dial, Free_SP_Y, Selected, True )
          Else Obj_SetState( F2_Dial, Free_SP_N, Selected, True );
        If ( System2.Upload_Ok[ FArea ] ) Then Obj_SetState( F2_Dial, Upld_Y, Selected, True )
          Else Obj_SetState( F2_Dial, Upld_N, Selected, True );
        If ( System2.Free_Dnld[ FArea ] ) Then Obj_SetState( F2_Dial, Free_DL_Y, Selected, True )
          Else Obj_SetState( F2_Dial, Free_DL_N, Selected, True );
        If ( System2.CD_ROM[ FArea ] ) Then Obj_SetState( F2_Dial, CD_ROM_Y, Selected, True )
          Else Obj_SetState( F2_Dial, CD_ROM_N, Selected, True );

        Repeat
          Dum2  := Do_Dialog( F2_Dial, 0) & $7fff;
          Obj_SetState( F2_Dial, Dum2, Normal, True );
          If ( Dum2 = FSig_Path ) Then Begin
            S := '';  Get_File_Sel( 0, S );
            If ( S <> '' ) Then Begin
              Set_DEdit( F2_Dial, FSig_Path, B60_Str, P60_String, S, System_Font, TE_Left );
              S := Concat( S, 'DESC\' );
              Set_DEdit( F2_Dial, FSig_Desc, B60_Str, P60_String, S, System_Font, TE_Left );
            End;
          End;
          If ( Dum2 = FSig_Desc ) Then Begin
            S := '';  Get_File_Sel( 0, S );
            If ( S <> '' ) Then Begin
              Set_DEdit( F2_Dial, FSig_Desc, B60_Str, P60_String, S, System_Font, TE_Left );
            End;
          End;
          If ( Dum2 = FSig_MoK ) Then Begin
            Get_Dedit( F2_Dial, FSig_Name, Temp ); System2.Names[ FArea ] := Temp;
            Get_Dedit( F2_Dial, FSig_Path, Temp );
            If ( Temp[ Length( Temp ) ] <> '\' ) Then Temp := Concat( Temp, '\' );
            System2.Paths[ FArea ] := Temp;
            Get_Dedit( F2_Dial, FSig_Desc, Temp );
            If ( Temp[ Length( Temp ) ] <> '\' ) Then Temp := Concat( Temp, '\' );
            System2.Desc_Path[ FArea ] := Temp;
            Get_Dedit( F2_Dial, SLvl_Kill, Temp );
            ReadLVal( Temp, System2.SLvl_Kill[ FArea ] );
            Get_Dedit( F2_Dial, SLvl_Edit, Temp );
            ReadLVal( Temp, System2.SLvl_Edit[ FArea ] );
            Get_Dedit( F2_Dial, SLvl_Name, Temp );
            ReadLVal( Temp, System2.SLvl_Name[ FArea ] );
            Get_Dedit( F2_Dial, SLvl_Valid, Temp );
            ReadLVal( Temp, System2.SLvl_Vald[ FArea ] );

            If ( Obj_State( F2_Dial, Desc_Y ) & Selected <> 0 ) Then System2.Use_Desc[ FArea ] := True
              Else System2.Use_Desc[ FArea ] := False;
            If ( Obj_State( F2_Dial, Upld_Y ) & Selected <> 0 ) Then System2.Upload_Ok[ FArea ] := True
              Else System2.Upload_Ok[ FArea ] := False;
            If ( Obj_State( F2_Dial, Free_SP_Y ) & Selected <> 0 ) Then System2.Show_Free[ FArea ] := True
              Else System2.Show_Free[ FArea ] := False;
            If ( Obj_State( F2_Dial, Free_DL_Y ) & Selected <> 0 ) Then System2.Free_Dnld[ FArea ] := True
              Else System2.Free_Dnld[ FArea ] := False;
            If ( Obj_State( F2_Dial, CD_ROM_Y ) & Selected <> 0 ) Then System2.CD_ROM[ FArea ] := True
              Else System2.CD_ROM[ FArea ] := False;
          End;
        Until ( Dum2 = FSig_Mok ) or ( Dum2 = FSig_MCnx );
        Obj_SetState( F2_Dial, Dum2, Shadowed, True );
        End_Dialog( F2_Dial );
        Delete_Dialog( F2_Dial );
      End;
    Until ( Dum1 = Done_FSig );
    End_Dialog( F1_Dial );
    Delete_Dialog( F1_Dial );
  End;

  Procedure Get_SysData;
  Var
    F1_Dial : Dialog_Ptr;
    N, P : String;
    S    : String;
    C    : CString;
    H, I : Integer;
    L, Count: Long_Integer;
    X1, Y1, W1, H1 :Short_Integer;
  Begin
    N := 'SYSDATA.DAT';
    P := Concat( Work_Path, '*.*' );
    Find_Dialog( Info_Mesg, F1_Dial );
    Center_Dialog( F1_Dial );
    Get_Dialog( F1_Dial, 0, X1,Y1,W1,H1,L );
    Wpoke( L + 18, 13 );
    Show_Dialog( F1_Dial, 0 );
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
        System2.Slvl_Kill[ I ] := 65535;
        System2.Slvl_Edit[ I ] := 65535;
        System2.Slvl_Name[ I ] := 65535;
        System2.Slvl_Vald[ I ] := 65535;
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
    End_Dialog( F1_Dial ) ;
    Delete_Dialog( F1_Dial );
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
 {  B1 := Shr( Date, 8 );
    B2 := ( Date & 255 ); }
    System.Hi_Msg := Date;
    H  := Create_File( C, 7 );
    If ( H > 0 ) Then L  := FWrite_Sys( H, SizeOf( System ), System );
    I  := Close_File( H );
  End;

  Procedure Get_FTU_SysData;
  Var
    Sigdatafile : text;
    I, J : Integer;
    F, Temp : String;
    Ch : Char;
    count : Long_Integer;
  Begin
    F := 'ftu_data.sig';
    If Exists( F ) Then Begin
      Reset( Sigdatafile, F );
      Count := Fseek( 0, Handle(SigdataFile), 0);
      If Count<0 Then Show_Error( F, Count );
      Count := FRead_Sys2( handle(sigdatafile), sizeof(system2), System2 );
      If ( Count < 0 ) Then Show_Error( F, Count )
      Else Enable_Menu;
      Close( Sigdatafile );
      UserFileName := System2.UserLog;
      Get_MaxU;
    End
    Else Dummy := Do_Alert( '[3][ FTU_DATA.SIG File Is Missing!][ Cancel ]', 0 );
  End;

  Procedure Make_New_File;
  Var
    I_Dial : Dialog_Ptr;
    H, I, U, Users : Integer;
    Dum1 : Short_Integer;
    X, Count : Long_Integer;
    F,
    SigDataFtu,
    UsrDataFtu,
    Sig_Mask    : String;
    C : Cstring;
  Begin
    Find_Dialog( Init_Stuff, I_Dial );  Center_Dialog( I_Dial );
    Get_SysData;
    F := UserFileName;
    If ( F <> 'XXX' ) Then Begin
      Put_2nd_Reg;
      Obj_SetState( I_Dial, Init_FSys, Shadowed, True );
      Obj_SetState( I_Dial, Init_FUser, Shadowed, True );
      Obj_SetState( I_Dial, Init_FMask, Shadowed, True );
      Dum1 := Do_Dialog( I_Dial, 0 ) & $7fff;
      Obj_SetState( I_Dial, Dum1, Shadowed, True );
      If ( Dum1 = Init_Doit ) Then Begin
        If ( Obj_State( I_Dial, Init_FSys ) & Selected <> 0 ) And
          ( Obj_State( I_Dial, Init_FUser ) & Selected <> 0 ) And
          ( Obj_State( I_Dial, Init_FMask ) & Selected <> 0 ) Then Enable_Menu;

        If ( Obj_State( I_Dial, Init_FSys ) & Selected <> 0 ) Then Begin
          Obj_SetState( I_Dial, Init_FSys, Shadowed, True );
          
          MakeCString( 'FTU_DATA.SIG', C );
          H := Create_File( C, 0 );
          Count := FWrite_Sys2( H, SizeOf( System2 ), System2 );
          I := Close_File( H );
        End;

        If ( Obj_State( I_Dial, Init_FUser ) & Selected <> 0 ) Then Begin
          Obj_SetState( I_Dial, Init_FUser, Shadowed, True );
          MakeCString( F, C );
          H := Open_File( C, 0 );
          X := Fseek( 0, H, 2 );
          I := Close_File( H );

          Users := (X Div SizeOf( UserRec )) - 1;
          UserAcs.K_Dnld := 0;    UserAcs.K_Upld := 0;
          UserAcs.Pts_Dnld := 0;  UserAcs.Pts_Upld := 0;
          UserAcs.DL_Ratio := 0;  UserAcs.K_Ratio := 0;
          UserAcs.Pts_Ratio := 0; UserAcs.Ratio_Typ := 1;
          MakeCString( 'FTU_DATA.USR', C );
          H := Create_File( C, 0 );
          For I := 1 To Users Do 
            Count := FWrite_Usr2( H, SizeOf( UserAcs ), UserAcs );
          I := Close_File( H );
          Get_MaxU;
        End;

        If ( Obj_State( I_Dial, Init_FMask ) & Selected <> 0 ) Then Begin
          Obj_SetState( I_Dial, Init_FMask, Shadowed, True );
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
      End;
    End;
    End_Dialog( I_Dial );
    Delete_Dialog( I_Dial );
  End;

  Procedure Extend_Ftu_User;
  Var
    Exp_U, Ftu_U, X : Long_Integer;
    S1, S2, Count : Long_Integer;
    H, I, Num : Integer;
    E_Dial : Dialog_Ptr;
    Temp : String[255];
    UsrDataFtu : Text;
    F, S : String;
  Begin
    Find_Dialog( Extend_UData, E_Dial );
    Center_Dialog( E_Dial );
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

    WriteV( Temp, Exp_U );
    Set_DText( E_Dial, Exp_Users, Temp, System_Font, TE_Left );
    WriteV( Temp, Ftu_U );
    Set_Dedit( E_Dial, Ftu_Users, '_____', '99999', Temp, System_Font, TE_Left );
    If ( Ftu_U < Exp_U ) Then Begin
      Obj_SetFlags( E_Dial, Extnd_Ok, Selectable + Default + Touch_Exit );
      Obj_SetState( E_Dial, Extnd_Ok, Shadowed, True );
      Obj_SetState( E_Dial, Extnd_Warn, Disabled, True );
    End
    Else Begin
      Obj_SetFlags( E_Dial, Extnd_Ok, None );
      Obj_SetState( E_Dial, Extnd_Ok, Disabled, True );
      Obj_SetState( E_Dial, Extnd_Warn, Normal, True );
    End;
    Dummy := Do_Dialog( E_Dial, 0) & $7fff;

    If ( Dummy = Extnd_Ok ) And ( Ftu_U < Exp_U ) Then Begin
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
    End_Dialog( E_Dial );
    Delete_Dialog( E_Dial );
  End;

  Function Show_User_Info( Var N, H : String ): Boolean;
  Var
    UI1_Dial : Dialog_Ptr;
    Temp : String[255];
    I :Short_Integer;
    L : Long_Integer;
  Begin
    Find_Dialog( User_Info, UI1_Dial);
    Center_Dialog(UI1_Dial);

    Set_DText( UI1_Dial, UName, N, System_Font, TE_Left );
    Set_DText( UI1_Dial, UHandle, H, System_Font, TE_Left );
    Writev( Temp, Usr_No );
    Set_DText( UI1_Dial, Usr_Num, Temp, System_Font, TE_Left );

    Writev( Temp, UserAcs.DL_Ratio );
    Set_Dedit( UI1_Dial, Ratio_File, '___', '999', Temp, System_Font, TE_Left );
    Writev( Temp, UserAcs.K_Ratio );
    Set_Dedit( UI1_Dial, Ratio_K, '___', '999', Temp, System_Font, TE_Left );
    Writev( Temp, UserAcs.Pts_Ratio );
    Set_Dedit( UI1_Dial, Ratio_Pts, '___', '999', Temp, System_Font, TE_Left );

    Writev( Temp, UserAcs.DownLoads );
    Set_Dedit( UI1_Dial, DL_File, B8_Str, N8_String, Temp, System_Font, TE_Left );
    Writev( Temp, UserAcs.K_Dnld );
    Set_Dedit( UI1_Dial, DL_K, B8_Str, N8_String, Temp, System_Font, TE_Left );
    Writev( Temp, UserAcs.Pts_Dnld );
    Set_Dedit( UI1_Dial, DL_Pts, B8_Str, N8_String, Temp, System_Font, TE_Left );

    Writev( Temp, UserAcs.UpLoads );
    Set_Dedit( UI1_Dial, UL_File, B8_Str, N8_String, Temp, System_Font, TE_Left );
    Writev( Temp, UserAcs.K_Upld );
    Set_Dedit( UI1_Dial, UL_K, B8_Str, N8_String, Temp, System_Font, TE_Left );
    Writev( Temp, UserAcs.Pts_Upld );
    Set_Dedit( UI1_Dial, UL_Pts, B8_Str, N8_String, Temp, System_Font, TE_Left );

    If UserAcs.XModem_Type = 0 Then
      Obj_SetState( UI1_Dial, Xmodem, Selected, False )
    Else Obj_SetState( UI1_Dial, Xmodem, Normal, False );

    If UserAcs.XModem_Type = 1 Then
      Obj_SetState( UI1_Dial, Xmodem_Crc, Selected, False )
    Else Obj_SetState( UI1_Dial, Xmodem_Crc, Normal, False );

    If UserAcs.XModem_Type = 2 Then
      Obj_SetState( UI1_Dial, Xmodem_1k, Selected, False )
    Else Obj_SetState( UI1_Dial, Xmodem_1k, Normal, False );

    If UserAcs.XModem_Type = 3 Then
      Obj_SetState( UI1_Dial, Y_modem, Selected, False )
    Else Obj_SetState( UI1_Dial, Y_modem, Normal, False );

    If UserAcs.XModem_Type = 4 Then
      Obj_SetState( UI1_Dial, Zmodem, Selected, False )
    Else Obj_SetState( UI1_Dial, Zmodem, Normal, False );

    If UserAcs.XModem_Type = 5 Then
      Obj_SetState( UI1_Dial, Ymodem_G, Selected, False )
    Else Obj_SetState( UI1_Dial, Ymodem_G, Normal, False );

    Obj_SetState( UI1_Dial, RT_File, Normal, False );
    Obj_SetState( UI1_Dial, RT_K, Normal, False );
    Obj_SetState( UI1_Dial, RT_Pts, Normal, False );
    Obj_SetState( UI1_Dial, RT_None, Normal, False );

    If UserAcs.Ratio_Typ = 1 Then Obj_SetState( UI1_Dial, RT_File, Selected, True )
    Else If UserAcs.Ratio_Typ = 2 Then Obj_SetState( UI1_Dial, RT_K, Selected, True )
    Else If UserAcs.Ratio_Typ = 3 Then Obj_SetState( UI1_Dial, RT_Pts, Selected, True )
    Else Obj_SetState( UI1_Dial, RT_None, Selected, True );

    Repeat
      Dummy := Do_Dialog( UI1_Dial, 0) & $7fff;
      Obj_SetState( UI1_Dial, Dummy, Normal + Shadowed, True );

      If Dummy = Edit_Sigs Then Result := Select_Bitz;

      Show_User_Info := False;
      If Dummy = UInf_Ok Then Begin
        Show_User_Info := True;
        If Obj_State( UI1_Dial, Xmodem ) & Selected <>0 Then
          UserAcs.XModem_Type := 0
        Else If Obj_State( UI1_Dial, Xmodem_Crc ) & Selected <>0 Then
          UserAcs.XModem_Type := 1
        Else If Obj_State( UI1_Dial, Xmodem_1k ) & Selected <>0 Then
          UserAcs.XModem_Type := 2
        Else If Obj_State( UI1_Dial, Y_modem ) & Selected <>0 Then
          UserAcs.XModem_Type := 3
        Else If Obj_State( UI1_Dial, Ymodem_G ) & Selected <>0 Then
          UserAcs.XModem_Type := 5
        Else If Obj_State( UI1_Dial, Zmodem ) & Selected <>0 Then
          UserAcs.XModem_Type := 4;

       If Obj_State( UI1_Dial, RT_File ) & Selected <> 0 Then 
         UserAcs.Ratio_Typ := 1
       Else If Obj_State( UI1_Dial, RT_K ) & Selected  <> 0 Then
         UserAcs.Ratio_Typ := 2
       Else If Obj_State( UI1_Dial, RT_Pts ) & Selected <> 0 Then
         UserAcs.Ratio_Typ := 3
       Else UserAcs.Ratio_Typ := 0;

        Get_Dedit( UI1_Dial, Ratio_File, Temp );
        ReadVal( Temp, UserAcs.DL_Ratio );
        Get_Dedit( UI1_Dial, Ratio_K, Temp );
        ReadVal( Temp, UserAcs.K_Ratio );
        Get_Dedit( UI1_Dial, Ratio_Pts, Temp );
        ReadVal( Temp, UserAcs.Pts_Ratio );

        Get_Dedit( UI1_Dial, Dl_File, Temp );
        ReadVal( Temp, UserAcs.DownLoads );
        Get_Dedit( UI1_Dial, DL_K, Temp );
        ReadLVal( Temp, UserAcs.K_Dnld );
        Get_Dedit( UI1_Dial, DL_Pts, Temp );
        ReadLVal( Temp, UserAcs.Pts_Dnld );

        Get_Dedit( UI1_Dial, UL_File, Temp );
        ReadVal( Temp, UserAcs.UpLoads );
        Get_Dedit( UI1_Dial, UL_K, Temp );
        ReadLVal( Temp, UserAcs.K_Upld );
        Get_Dedit( UI1_Dial, UL_Pts, Temp );
        ReadLVal( Temp, UserAcs.Pts_Upld );

      End;
    Until ( Dummy = UInf_Ok ) or ( Dummy = UInf_Cnx );
    End_Dialog( UI1_Dial );
    Delete_Dialog( UI1_Dial );
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
    Masks_Dial : Dialog_Ptr;
    X,I : Integer;
    Name, Hand : String;
    Temp : String[255];
  Begin
    Find_Dialog( User_Masks, Masks_Dial );
    Center_Dialog( Masks_Dial );
    For X := 1 To 10 Do Begin
      I := ( X * 2 ) + 1;
      Set_Dedit( Masks_Dial, I, B31_Str, N31_String,
        System2.Mask_Comment[ X ], System_Font, TE_Left );
    End;
    Repeat
      Dummy := Do_Dialog( Masks_Dial, 0) & $7fff;
      Obj_SetState( Masks_Dial, Dummy, Normal + Shadowed, True );
      If ( Dummy >= UMb1 ) And ( Dummy <= UMb10 ) Then Begin
        X := ( Dummy Div 2 );  Usr_No := X;
        Get_MaskData( X );
        WriteV( Name, 'Mask Data #', X );  Hand := Name;
        If ( Show_User_Info( Name, Hand ) ) Then Save_MaskData( X );
      End;
    Until ( Dummy = Usr_MOk );
    For X := 1 To 10 Do Begin
      Get_Dedit( Masks_Dial, ( ( X * 2 ) + 1 ), Temp );
      System2.Mask_Comment[ X ] := Temp;
    End;
    End_Dialog( Masks_Dial );
    Delete_Dialog( Masks_Dial );
  End;

  Procedure Redraw_SlidBar( Box: Dialog_Ptr; Item:Short_Integer );
  Begin
    Obj_ReDraw( Box, Item );
    Obj_ReDraw( Box, Item+1 );
  End;

  Procedure Show_User_Listing;
  Var
    Ptr, Ctr, I, I2, R, X, X1, Y1, W1, H1, Bh, Max :Short_Integer;
    X2, Y2, W2, H2, Y, Y_off, Mx, My,Ypos :Short_Integer;
    X3, Y3, W3, H3, Btn_Y :Short_Integer;
    L : Long_Integer;
    Bv,Upt : Real;
    Temp : String;
    Name, Hand : String;
    Frst : Boolean;
    UList_Dial : Dialog_Ptr;
  Begin
    Read_URecs( Usr_Ptr );
    Frst := True;
    Find_Dialog( User_Listing, UList_Dial);
    Center_Dialog(UList_Dial);
    Obj_SetState( UList_Dial, Slid_Bar, Normal, True );
    Obj_SetState( UList_Dial, Slid_Btn, Normal, True );
    Obj_Offset( UList_Dial, Slid_Btn, R, X1, Y1 );
    Y_Off := Y1;
    Get_Dialog( UList_Dial, Slid_Bar, X2,Y2,W2,H2,L );
    Get_Dialog( UList_Dial, Slid_Btn, X1,Y1,W1,H1,L );
    Get_Dialog( Ulist_Dial, Usr_Box, X3,Y3,W3,H3,L );
    H3 := H3 + 10;
    Max := Max_Users - 19;
    If ( Max < 1 ) Then H1 := H2  Else H1 := ( H2 Div (Max_Users Div 20) );
    Wpoke( L + ( Slid_Btn * 24 ) + 22, H1 );
    Bh := ( H2 - H1 );
    Bv := ( Max / Bh );
    Upt := ( Usr_Ptr / Bv );
    Ypos := Trunc( Upt );
    Wpoke( L + ( Slid_Btn *24 ) + 18, Ypos );
    Repeat
      Get_Dialog( UList_Dial, Slid_Btn, X1,Y1,W1,H1,L );
      Ptr := Usr1;
      For I := 0 To 19 Do Begin
        Writev( Temp, I + Usr_Ptr );
        Set_DText( UList_Dial, Ptr, Temp, System_Font, TE_Left );
        Set_DText( UList_Dial, Ptr+1, User_Recs[I].UHandle, System_Font, TE_Left );
        Writev( Temp, User_Recs[I].Name );
        Set_DText( UList_Dial, Ptr+2, Temp, System_Font, TE_Left );
        Ptr := Ptr + 3;
      End;
      If Frst=False Then
        Obj_Draw( Ulist_Dial, Usr_Box, 255, X3, Y3, W3, H3 );
      If (Frst) Then Begin
        Dummy := Do_Dialog( UList_Dial, 0) & $7fff;
        Frst := False;
      End
      Else Dummy := ReDo_Dialog( UList_Dial, 0) & $7fff;
      Obj_SetState( UList_Dial, Dummy, Normal, True );

      If (Dummy >= Handle1) And (Dummy <= Real_Name20) Then Begin
        X := ( Dummy Div 3) - 4;
        Usr_No := ( Usr_Ptr + X );
        Get_Ftu_User;
        UserRec:= User_Recs[ X ];
        Name   := User_Recs[ X ].Name;
        Hand   := User_Recs[ X ].UHandle;
        End_Dialog( UList_Dial );
        If ( Show_User_Info( Name, Hand ) ) Then Begin
          User_Recs[ X ] := UserRec;
          Save_FTU_User;
          X := ( X * 3 );
          Set_DText( UList_Dial, X, Hand, System_Font, TE_Left );
          Set_DText( UList_Dial, X+1, Name, System_Font, TE_Left );
        End;
        Frst := True;
      End

      Else If ( Dummy = Up_Lstng ) And ( Usr_Ptr > 1 ) Then Begin
        Usr_Ptr := Usr_Ptr - 1;
        Read_URecs( Usr_Ptr );
        Upt := ( Usr_Ptr / Bv );
        Ypos := Trunc( Upt );
        Wpoke( L + (Slid_Btn*24) + 18, Ypos );
        ReDraw_SlidBar( Ulist_Dial, Slid_Bar );
      End

      Else If ( Dummy = Dwn_Lstng ) And ( Usr_Ptr < Max ) Then Begin
        Usr_Ptr := Usr_Ptr + 1;
        Read_URecs( Usr_Ptr );
        Upt := ( Usr_Ptr / Bv );
        Ypos := Trunc( Upt );
        Wpoke( L + (Slid_Btn*24) + 18, Ypos );
        ReDraw_SlidBar( Ulist_Dial, Slid_Bar );
      End

      Else If Dummy = Slid_Btn Then Begin
        Obj_Offset( UList_Dial, Slid_Btn, R, X1, Y1 );
        Obj_Offset( UList_Dial, Slid_Bar, R, X2, Y2 );
        Drag_Box( W1, H1, X1, Y1, X2, Y2, W2, H2, X, Y );
        Btn_Y := Wpeek( L + (Slid_Btn*24) + 18 );
        Move_Box( W1, H1, X1, Y1, X+1, Y, R );
        Ypos := ( Y - Y_Off );
        If Ypos < 1 Then Ypos := 0
        Else If Ypos > Bh Then Ypos := Bh;
        Wpoke( L + (Slid_Btn*24) + 18, Ypos );
        ReDraw_SlidBar( Ulist_Dial, Slid_Bar );
        Upt := ( Ypos * Bv ) + 1.0;
        Usr_Ptr := Trunc ( Upt );
        If ( Usr_Ptr > Max ) Then Usr_Ptr := Max;
        Read_URecs( Usr_Ptr );
      End

      Else If Dummy = Slid_Bar Then Begin
        Graf_MKstate( Mx, My ); 
        My := My - 22;
        If My < Y1 Then Begin
          Usr_Ptr := Usr_Ptr - 20;
          If ( Usr_Ptr < 1 ) Then Usr_Ptr := 1;
        End
        Else If My > Y1 Then Begin
          Usr_Ptr := Usr_Ptr + 20;
          If ( Usr_Ptr > Max ) Then Usr_Ptr := Max;
        End;
        Read_URecs( Usr_Ptr );
        Upt := ( Usr_Ptr / Bv );
        Ypos := Trunc( Upt );
        Wpoke( L + (Slid_Btn*24) + 18, Ypos );
        ReDraw_SlidBar( Ulist_Dial, Slid_Bar );
      End;
    Until (Dummy = UListing_Ok);
    End_Dialog(UList_Dial);
    Delete_Dialog(UList_Dial);
  End;

  Procedure Do_Alt;
  Begin
    Case Fnct_Key Of
      $1E : Form_Do( About , Normal);  { A }
      $2E : If ( Menu_On ) Then Select_All_Bitz;           { C }
      $12 : If ( Menu_On ) Then Extend_Ftu_User;           { E }
      $21 : If ( Menu_On ) Then Do_File_SIGS;              { F }
      $17 : If ( Menu_On = False ) Then Make_New_File;     { I }
      $26 : If ( Menu_On = False ) Then Get_FTU_SysData;   { L }
      $32 : If ( Menu_On ) Then Do_Misc;                   { M }
      $31 : If ( Menu_On ) Then Edit_User( NewU_Rec );     { N }
      $10 : If ( Menu_On ) Then Prg_Done := True;          { Q }
      $1F : If ( Menu_On ) Then Save_FTU_Sig;              { S }
      $16 : If ( Menu_On ) Then Show_User_Listing;         { U }
      $2F : If ( Menu_On ) Then Edit_User( Visit_Rec );    { V }
      $2D : If ( Menu_On ) Then Edit_Usr_Masks;            { X }
    End;
  End;

  Procedure Do_MKeyBd( C : Integer );
  Var
    Key : Integer;
  Begin
    Key := ( C & $FF);  Fnct_Key := Shr( C, 8 );
    If ( Key = 0 ) Then Begin
      If ( Fnct_Key In[ $1E,$2E,$12,$21,$17,$26,$32,$31,$10,$1F,$16,$2F,$2D ] ) Then
        Do_ALT;
    End;
  End;

  Procedure Do_Menu( title, item :Short_Integer );
  Begin
    Case item Of
      About_FTUEdit    : Form_Do( About , Normal);  { A }
      F_Load           : Get_FTU_SysData;           { L }
      Make_Neu         : Make_New_File;             { I }
      F_Save           : Save_FTU_Sig;              { S }
      Prg_Quit         : Prg_Done := True;          { Q }
      Chg_All_Sec_Lvls : Select_All_Bitz;           { C }
      Ext_Ulog         : Extend_Ftu_User;           { E }
      Misc             : Do_Misc;                   { M }
      Frm_Usr_Lstng    : Show_User_Listing;         { U }
      New_URec         : Edit_User( NewU_Rec );     { N }
      Vis_Rec          : Edit_User( Visit_Rec );    { V }
      Usr_Masks        : Edit_Usr_Masks;            { X }
      FileSigs         : Do_File_SIGS;              { F }
    End;
    Menu_Normal( Menu, title );
  End;

  Procedure Do_Message( Msg: Message_Buffer );
  Begin
    Case Msg[0] Of
      WM_Redraw:  Do_Redraw( Msg[3], Msg[4], Msg[5], Msg[6], Msg[7] );
      Otherwise: Do_Menu( Msg[3], Msg[4] );
    End;
  End;

  Procedure Event_Loop;
  Var
    Which, Key : Integer;
    Done : Boolean;
    Msg  : Message_Buffer;
  Begin
    Usr_Ptr := 1;  Usr_No := 1;
    Repeat
      Which := Get_Event( E_Message | E_Keybd,
        0, 0, 0, 0,
        False,
        0, 0, 0, 0,
        False,
        0, 0, 0, 0,
        Msg, Key, dummy, dummy, dummy, dummy, dummy );
      If ( Which & E_Message <> 0 ) Then Do_Message( Msg );
      If ( Which & E_Keybd ) <> 0 Then Do_MKeyBd( Key );
    Until ( Prg_Done );
  End;


Begin                     (* Main Program Begins Here... *)
  Prg_Done := False;

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

  N5_String  := '99999';
  N8_String  := '99999999';
  N10_String := 'XXXXXXXXXX';
  N15_String := 'XXXXXXXXXXXXXXX';
  N20_String := 'XXXXXXXXXXXXXXXXXXXX';
  N25_String := 'XXXXXXXXXXXXXXXXXXXXXXXXX';
  N30_String := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
  N31_String := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
  P60_String := 'PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP';

  B5_Str := '_____';
  B8_Str := '________';
  B10_Str:= '__________';
  B15_Str:= '_______________';
  B20_Str:= '____________________';
  B25_Str:= '_________________________';
  B30_Str:= '______________________________';
  B31_Str:= '_______________________________';
  B60_Str:= '____________________________________________________________';

  SetDta( DTA_Data );
  GetDir( Boot_Path, 0 );
  MakePString( Boot_Path, TLine );
  Path     := Boot_Path;
  P_Path   := TLine;
  Boot_Drv := CurDisk;
  F_Path   := Concat( Chr( Ord('A') + Boot_Drv ), ':', TLine, '\' );
  Work_Path:= F_Path;

  If ( Init_Gem <> -1 ) Then Begin
    Show_Mouse;
    Rez := Get_Rez;
    Case Rez of
      1 : Begin
            If NOT Exists( 'FTU_CFGR.RSC' ) Then Begin
              dummy := Do_Alert( '[3][Error Finding FTU_CFGR.RSC!][ Cancel ]', 1 );
            End;
            If Not Load_Resource( 'FTU_CFGR.RSC' ) Then Begin
              dummy := Do_Alert( '[3][Error Loading FTU_CFGR.RSC!][ Cancel ]', 1 );
              Rez := 10;
            End;
          End;
      0 : Begin
            Wrong_Rez := '[3][You must use medium or|high resolution to use|';
            Wrong_Rez := ConCat( Wrong_Rez, 'The User Editor.][ Cancel ]');
            dummy := Do_Alert( Wrong_Rez, 0 );
            Rez := 10;
          End;
    End; { Case }
    If ( Rez <> 10 ) Then Begin
      Find_Menu( User_Menu, Menu );
      Draw_Menu( Menu );
      Disable_Menu;
      Init_Mouse;
      Set_Mouse( M_Arrow );
      Menu_Enable( Menu, Prg_Quit );
      Form_Do( About, Normal );
      Event_Loop;
      Disable_Menu;
      Erase_Menu( Menu );
      Delete_Menu( Menu );
      Free_Resource;
      Exit_Gem;
    End;
  End;
End.

