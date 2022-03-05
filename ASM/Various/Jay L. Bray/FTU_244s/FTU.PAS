{$S30}
Program FTU;

Const
  Modem       = 1;
  Console     = 2;
  Timeout     = -1;
  Input_Mode  = 0;
  Output_Mode = 1;
  Update_Mode = 2;
  Wht  = 0;
  Redd = 1;
  Grn  = 2;
  Blk  = 3;

  Nul = 0;
  Soh = 1;
  Stx = 2;
  Eot = 4;
  Ack = 6;
  Bksp= 8;
  CtrlC = 3;
  CtrlE = 5;
  CtrlQ = 17;
  CtrlS = 19;
  Nak = 21;
  Can = 24;  
  Cr  = 13;
  Lf  = 10;
  Esc = 27;
  F1  = 59;
  F2  = 60;
  F3  = 61;
  F4  = 62;
  F5  = 63;
  F6  = 64;
  F7  = 65;
  F8  = 66;
  F9  = 67;
  F10 = 68;
  SF1 = 84;
  SF2 = 85;
  SF3 = 86;
  SF4 = 87;
  SF5 = 88;
  SF6 = 89;
  SF7 = 90;
  SF8 = 91;
  SF9 = 92;
  SF10= 93;
  Help_Key = 98;
  Block_Size = 8192;

Type
  Cstring   = Packed Array[0..80] Of Char;
  Fn_String = Packed Array[1..14] of Char;
  BlockIO   = Packed Array[1..Block_Size] Of Byte;
  Months    = Packed Array[0..12] of String[4];
  Arc_Types = Packed Array[1..6] of String[3];
  ArcTypes  = Packed Array[1..8] of String[10];
  ZipTypes  = Packed Array[1..9] of String[10];
  SitTypes  = Packed Array[1..10] of String[10];
  Ratings   = Packed Array[1..6] of String[10];
  BLine     = Packed Array[1..25] of String;
  DLine     = Packed Array[1..5] of String;
  MLine     = Packed Array[1..100] of String;
  Errors    = Packed Array[1..70] of String[40];
  Xyzs      = Packed Array[0..25] of String[55];
  Tran      = Packed Array[0..5] of String[10];
  Str60     = String[60];

  DTA = Packed Record
    Reserved  : Packed Array[0..19] Of Byte;
    Reserved2 : Byte;
    Attribute : Byte;
    Time      : Integer;
    Date      : Integer;
    Size      : Long_Integer;
    Name      : Fn_String;
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
    Slvl_DOSS : Long_Integer;                           { New 2.41 }
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
    BlankInt1  : Integer;     { New 2.40 }
    BlankInt2  : Integer;     { New 2.40 }
    BlankInt3  : Integer;     { New 2.40 }
    XpertUser  : Boolean;     { New 2.40 }
    BlankBool2 : Boolean;     { New 2.40 }
    BlankBool3 : Boolean;     { New 2.40 }
  End;

  UserData = Packed Record
    In_Use         : Boolean;      { Search Data }
    UHandle        : String [30];  {    "    "   }
    Name           : String [30];
    Pword          : String [15];
    Addr           : String [25];
    City           : String [20];
    State          : String [2];
    Zip            : String [10];
    Country        : String [15];
    Phone_number   : String [15];
    Age            : Byte;
    Computer_Type  : String [14];
    Sec_Lvl        : Long_Integer;
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
    Posts_Per_Call : Integer;
    Flags          : Long_Integer;       { 32 on/off flags}
    Translation    : Integer;            { 0-Ascii, 1-ST Mono, 2-ST Color }
    Cont_scroll    : Boolean;
    New_user       : Boolean;
    Surveys        : Long_Integer;       { 32 survey flags }
    Scan_boards    : Long_Integer;       { 32 Q-Scan flags }
    Msg_read_mask  : Long_Integer;
    Msg_post_mask  : Long_Integer;
    Msg_edit_mask  : Long_Integer;
    Msg_delete_mask: Long_Integer;
    Msg_print_mask : Long_Integer;
    Sig_read_mask  : Long_Integer;  { Search Data }
    Sig_validate   : Long_Integer;  {   "     "   }
    Sig_edit_desc  : Long_Integer;  {   "     "   }
    Sig_delete_file: Long_Integer;  {   "     "   }
    SIG_Scan       : Long_Integer;  {   "     "  v1.60 }
  End;

  BM_Area = Packed Record          { Batch Mark Info }    
    BM_FName  : String;
    BM_FSize  : Long_Integer;
    BM_FTime  : Long_Integer;
    BM_Sig    : Integer;
    BM_D_Time : Integer;
    BM_CD_ROM : Boolean;
  End;

Var
  System2     : SigData2;
  UserRec     : UserData;    { the user's userlog file entry  }
  UserAcs     : UserAccess;
  Blkio       : BlockIO;
  Month       : Months;
  Trans       : Tran;
  Prots       : Packed Array [ 0..8 ] of Char;
  Arc_Type    : Arc_Types;
  ArcType     : ArcTypes;
  ZipType     : ZipTypes;
  SitType     : SitTypes;
  Rating      : Ratings;
  Err         : Errors;
  Xyz         : Xyzs;
  DTA_Data    : DTA;                { Blkio used For dir searches       }

  Speed       : Long_Integer;       { Baud rate in numeric Form          }
  Usr_Addr    : Long_Integer;
  Timeon      : Long_Integer;       { time the user Entered Files Area }
  TimeLeft    : Long_Integer;       { Time the user has left online...}
  Connected   : Long_Integer;       { Time The User Has Been Online...}
  Time_Start  : Long_Integer;
  Time_Finish : Long_Integer;
  Ftu_Length  : Long_Integer;       { Length Between FTU & UserData }
  Sys_Mem     : Long_Integer;
  Dummy_L     : Long_Integer;

  Sig_Access : Packed Array[ 1..256 ] Of Integer;

  Kywrd_File  : Packed Array[1..256] Of Integer;
  Kywrd_Cnt   : Integer;

  BMark       : Array[1..20] Of BM_Area;
  SMark       : Array[1..16] Of BM_Area;

  Ftu_UserFile: String;
  Ftu_MaskFile: String;
  Ftu_SigFile : String;
  Ftu_ErrFile : String;
  Log_Filename: Str60;
  Userfilename: Str60;         { filename For the userfile  }

  XferT       : Packed Array [ 0..6 ] Of String[ 10 ];
  U_Handle    : String;
  BBS_Vers    : String;
  Baudrate    : String;       { current caller's baud rate  }
  Number      : String;       { user number passed from BBS }
  Width       : String;
  Time_left   : String;       { time left For caller on this call  }
  Translation : String;
  Xfer_Type   : String;
  Line,
  DL_Time_Str,
  Temp        : String;
  MLin        : String;  { Temp Line In Message }
  Srch_Str    : String;
  F_Name      : String;
  File_Name   : String;

  Chat_On,
  Arc_FName,
  Key_File,
  Ftu_Xfr,
  Ftu_Out,
  Ftu_Menu,
  Work_Path   : String;
  Ftu_Path    : String;
  FPath       : String;
  Desc_Path   : String;
  Sspec       : String;
  Cmd_Line    : String[128];
  Mil_Time    : String[8];
  Reg_Num     : String[10];
  Reg_Date    : String[10];
  Reg_MaxDays : String[5];
  Clk         : String[4];

  FName       : Cstring;
  Desc_Path_C : CString;
  Xyz_Path    : CString;
  F_Path      : CString;
  Boot_Path   : CString;

  BBS_Version,
  Sig_Num     : Integer;
  Sig_Cntr    : Integer;
  Max_Sig     : Integer;
  NumSigs     : Integer;
  Usr_No      : Integer;
  Usr_Tmp     : Integer;
  Visitor_Rec : Integer;
  NewUser_Rec : Integer;
  Usr_Lst_Call: Integer;
  M, D, Y     : Integer;
  Cur_Time    : Integer;
  Cur_Date    : Integer;
  Minutes     : Integer;      { Minutes left this call             }
  Seconds     : Integer;      { Seconds Left Before Timeout        }
  BM_Num      : Integer;      { Number of files in Batch Mark Area }
  Find_Date   : Integer;
  Lin_Count   : Integer;      { Counter For Lines Printed On Screen }
  Lines       : Integer;      { Counter For Lines Shown During Scan }
  Msg_Ln      : Integer;      { Counter For # of Lines in Message }
  Lin_No      : Integer;      { Current Line# in Message }
  Cps         : Integer;
  Tot_DL_Time : Integer;
  DL_Time     : Integer;
  Return      : Integer;
  FCur        : Integer;
  FCnt        : Integer;  { Counter used in SFirst - SNext }
  FMax        : Integer;  { Maximum # Of Files Found In SSpec }
  Eod         : Integer;  { End Of Directory Flag }
  ArcT        : Integer;
  Drv         : Integer;
  Fnct_Key    : Integer;
  Transv      : Integer;
  Rez         : Integer;
  Boot_Drv    : Integer;
  Dummy_I     : Integer;
  WidT        : Integer;
  Protocol    : Integer;
  Arc_Kind    : Integer;

  Byt         : Byte;

  Local       : Boolean;            { local log-on flag  }
  VT52        : Boolean;
  V_Color     : Boolean;
  ANSI        : Boolean;
  A_Color     : Boolean;
  Use_Desc    : Boolean;
  Show_Free   : Boolean;
  Result      : Boolean;
  Stop_Send   : Boolean;
  Forced_Off  : Boolean;
  Valid_New   : Boolean;
  WW_Toggle   : Boolean;
  Word_Pending: Boolean;
  SaveM       : Boolean;
  Sig_Edit    : Boolean;
  Sig_Name    : Boolean;
  Sig_Kill    : Boolean;
  Sig_Vald    : Boolean;
  Sig_Op      : Boolean;
  Chat        : Boolean;
  Abort       : Boolean;
  Is_Ok       : Boolean;
  Caps        : Boolean;
  Arc_Chose   : Boolean;
  Arc_File    : Boolean;
  Hide_Mode   : Boolean;
  New_Files   : Boolean;
  Find_File   : Boolean;
  Kywrd_Srch  : Boolean;
  Quick_Scan  : Boolean;
  List_Mode   : Boolean;
  Scan_Mode   : Boolean;
  Tot_Sig     : Boolean;
  Batch_Down  : Boolean;
  Batch_Upld  : Boolean;
  New_Line    : Boolean;
  Shw_Time    : Boolean;
  Dos_Mode    : Boolean;

  W_Color,
  R_Color,
  G_Color,
  B_Color,
  Bk_Color,
  Color_F,
  Color_B,
  Tb_Color,
  Tf_Color,
  Escp,
  Prompt      : Char;

  BachL       : BLine;
  MesgL       : MLine;
  DescL       : Dline;

  Procedure Dummy_Routine;
  Var
    A, B, C : Integer;
  Begin
    A := 9;  B := 9;  C := 9;
    Line := 'Registered To: <<< UnRegistered FTU User >>>  ';
  End;

  Function  Addr( Var A1 : UserData ): Long_Integer; External;

  Function  Addr_Str( Var S:String ):Long_Integer; External; { Used In  }
  Function  Dos_Cmnd( A1:Long_Integer ):Integer;External;    { Dos_Shll }

{  Procedure Poke ( A:Long_Integer; B:Byte ); External;
  Function  XOR (Source, Mask: Integer): Integer; External; }

  Function  Bit_Cmp( A,B : Long_Integer ):Boolean; External;
  Function  Proc_Addr( Procedure P ): Long_Integer; External;
  Procedure Shrink_S( Size, Res: Integer );External;
  Procedure Draw_Six( W,X,Y,Yoff,CT,CB: Integer; Var S: String );External;
  Procedure Get_Usr( Dest, Src, Lngth : Long_Integer ); External;
  Procedure Put_Usr( Dest, Src, Lngth : Long_Integer ); External;
  Function  ItoL( X:Integer ):Long_Integer; External;
  Function  LtoI( X:Long_Integer ):Integer; External;
  Function  Peek ( A:Long_Integer ):Byte; External;
  Function  WPeek( A:Long_Integer ):Integer; External;
  Function  LPeek( A:Long_Integer ):Long_Integer; External;
  Procedure WPoke( A:Long_Integer; W:Integer ); External;
  Procedure LPoke( A:Long_Integer; L:Long_Integer ); External;
  Procedure Save5;  External;
  Procedure Rest5;  External;
  Procedure Clear5; External;
  Procedure Init_200Hz; External;
  Procedure Rstr_200Hz; External;
  Procedure Set_Time( Tm:Long_Integer ); External;
  Function  Get_Time: Long_Integer; External;
  Procedure Set_Date( Dt:Long_Integer ); External;
  Function  Get_Date: Long_Integer; External;
  Function  Fsel_In( Var C1,C2:CString ):Integer; External;
  Procedure Mouse_On; External;
  Procedure Mouse_Off; External;
  Function  Chk_Carrier( L:Boolean ):Boolean; External;
  Function  Get_Timr : Long_Integer; External;
  Procedure Zero_Timer; External;
  Procedure Pause( Jif:Integer ); External;
  Function  Bit_Test( L:Long_Integer; I:Integer ):Boolean; External;
  Procedure Bit_Set ( Var L:Long_Integer; I:Integer ); External;
  Procedure Bit_Clr ( Var L:Long_Integer; I:Integer ); External;
  Function  Drive_Exist( D:Integer ): Boolean; External;
  Function  Search (Ln, A:Long_Integer ;Var S:String):Long_Integer; External;
  Function  Search1(Ln, A:Long_Integer ;Var S:String):Long_Integer; External;
  Procedure Hang_Up; External;
  
  Function SetDrv( Drive: Integer ):Integer;
    GemDos( $0E );

  Function CurDisk: Integer;
    GemDos( $19 );

  Procedure SetDta( Var B: DTA );
    Gemdos( $1A );

  Function Get_SDate2: Integer;
    GemDos( $2A );

  Function Get_STime2: Integer;
    GemDos( $2C );

  Function DFree( Var B:BlockIO; Drive: Integer ):Integer;
    GemDos( $36 ); { 1:L=Free Clusters, 3:L=Sect Size, 4:L=Sect/Cluster}

  Function MkDir( Var P:Cstring ):Integer;
    GemDos( $39 );  { Path Name }

  Function RmDir( Var P:Cstring ):Integer;
    GemDos( $3A );  { Path Name }

  Function ChDir( Var P:Cstring ):Integer;
    GemDos( $3B );  { Path Name }

  Function Create_File( Var P:Cstring; Attr: Integer ):Integer;
    GemDos( $3C );  { Attr: 0=Norm, 1=R/O }

  Function Open_File( Var P: Cstring; Md: Integer ):Integer;
    GemDos( $3D );  { Md: 0=Read Only, 1=Write Only, 2=Read & Write}

  Function Close_File( H: Integer ):Integer;
    GemDos( $3E );

  Function BlockRead( H: Integer; Sz: Long_Integer; Var Loc: BlockIO ):Long_Integer;
    GemDos( $3F );

  Function BlockWrite( H: Integer; Sz: Long_Integer; Var Loc: BlockIO ):Long_Integer;
    GemDos( $40 );

  Function FRead_Sys2( H:Integer; Count:Long_Integer; Var S:SigData2 ):Long_Integer;
  Gemdos( $3F );

  Function FWrite_Sys2( H:Integer; Count:Long_Integer; Var S:SigData2 ):Long_Integer;
  Gemdos( $40 );

  Function FWrite_Usr2( H:Integer; Count:Long_Integer; Var S:UserAccess ):Long_Integer;
  Gemdos( $40 );

  Function FRead_Usr2( H:Integer; Count:Long_Integer; Var S:UserAccess ):Long_Integer;
  Gemdos( $3F );

  Function UnLink( Var P: CString ): Integer;
    GemDos( $41 );

  Function Fseek( Where : Long_Integer ; FHandle, Mode: Integer ):Long_Integer;
    Gemdos( $42 ); { Mode: 0=From Start, 1=from current pos, 2=from End }  

  Function ChMode( Var P:CString; Attr: Integer; Md: Integer ):Integer;
    Gemdos( $43 );

  Procedure GetDir( Var P:CString; Drive: Integer );
    GemDos( $47 );

  Function Malloc( M:Long_Integer ):Long_Integer;
    GemDos( $48 );

  Function Exec( Md: Integer; Var Fil, Com, Env: CString ):Integer;
    GemDos( $4B );

  Function SFirst( Var Name:Cstring; Attr: Integer ):Integer;
    Gemdos( $4E );

  Function SNext: Integer;
    Gemdos( $4F );

  Function ReName( X:Integer; Var OldName:Cstring; Var NewName:Cstring ):Long_Integer;
    Gemdos( $56 );

  Function GSDTOF( Var B:BlockIO; H:Integer; Md:Integer ):Integer;
    Gemdos( $57 );   { 1:W Time, 2:W Date }

  Function BconStat( Device: Integer ):Integer;
    Bios( 1 );

  Function Bconin( Device: Integer ):Long_Integer;
    Bios( 2 );

  Procedure Bconout( Device: Integer; Ch: Char );
    Bios( 3 );

  Procedure Rwabs( Flg:Integer; Var B:BlockIo; Num, Sct, Drv : Integer );
    Bios( 4 );  { Flg = 0-Read, 1-Write } 

  Function Get_Rez : Integer ;
    Xbios( 4 ) ;

  Procedure RSconf( Spd, Flowctl, Ucr, Rsr, Tsr, Scr : Integer );
    XBios( 15 );

  Procedure CursConf( Funct, Rate: Integer );
    XBios( 21 );

  Function OffGiBit( Bitnum : Integer ):Integer;
    XBios( 29 );

  Function OnGiBit( Bitnum : Integer ):Integer;
    XBios( 30 );

  Function Carrier: Boolean;  
  Begin
    Carrier := Chk_Carrier( Local );
    If ( Local ) Then Carrier := True;
  End;

  Function No_Carrier : Boolean;
  Begin
    No_Carrier := Not Carrier;
  End;

  Function Con_In: Boolean;
  Begin
    If ( BConStat( Console ) =0 ) Then Con_In := False  Else Con_In := True;
  End;

  Function Mdm_In: Boolean;
  Begin
    If ( BConStat( Modem ) =0 ) Then Mdm_In := False  Else Mdm_In := True;
  End;

  Function Get_Modem : Integer;
  Var
    X : Long_Integer;
  Begin
    X := Bconin( Modem );
    Get_Modem := Int( X );
  End;

  Function Get_Console : Integer;
  Var
    X : Long_Integer;
  Begin
    X := Bconin( Console );
    Fnct_Key := Shr( X, 16 );
    Get_Console := Int( X );
  End;

  Function Scan_Input : Integer;
  Var
    X : Integer;
  Begin
    X := TimeOut;
    If ( Mdm_In ) And ( Not Local ) Then X := Get_Modem
    Else If ( Con_In ) Then X := Get_Console;
    Scan_Input := X;
  End;
                
  Procedure Put_Console( Ch : Char );
  Begin
    Bconout( Console, Ch );
  End;

  Procedure Put_Modem( Ch : Char );
  Begin
    Bconout( Modem, Ch );
  End;

  Procedure Strip_L( Var S : String );
  Var X : Integer;
  Begin
    X := 0;
    While S[ X + 1 ] = ' ' Do X := X + 1;
    If ( X = Length( S ) ) Then S := ''
    Else If ( X >= 1 ) Then S := Copy( S, X+1, Length( S ) - X );
  End;

  Procedure Strip_T( Var S : String );
  Var X : Integer;
  Begin
    X := Length( S );
    While S[X]=' ' Do X := X - 1;
    If ( X >0 ) Then S[0] := Chr( X ) Else S := '';
  End;

  Function Val( S: String ): Integer;
  Var
    I, Ln, V, N, X : Integer;
    Ch : Char;
  Begin
    V := 0;
    X := 1;
    Strip_L ( S );
    Ln := Length( S );
    If ( Ln>0 ) Then Begin
      For I := Ln Downto 1 Do Begin
        Ch := S[I];
        N := Ord( Ch ) - 48;
        If ( N>0 ) And ( N <=9 ) Then V := V + ( N * X );
        X := ( X * 10 );
      End;
    End;
    Val := V;
  End;

  Procedure Get_STime( Var H, M, S : Integer );
  Var X : Long_Integer;
  Begin
    X := Get_Time;
    S := ( X & 255 );
    X := Shr( X,8 );
    M := ( X & 255 );
    X := Shr( X,8 );
    H := ( X & 255 );
  End;

  Procedure Get_SDate;
  Var X : Long_Integer;
  Begin
    X := Get_Date;
    Y := ( X & 255 );
    X := Shr( X,8 );
    M := ( X & 255 );
    X := Shr( X,8 );
    D := ( X & 255 );
    Y := Y + 1980;
  End;

  Procedure Shrink_Scrn( Ln : Integer );
  Begin
    If ( Rez = 2 ) And ( Ln = 5 ) Then Ln := 3;
    Shrink_S( Ln, Rez );
  End;

  Procedure Write_Six( X, Y, C1, C2:Integer; S:String );
  Var
    YOff : Integer;
  Begin
    If ( Rez = 2 ) Then Begin        { Monochrome }
      YOff := 368;
      C1 := Blk;
      C2 := Wht;
    End
    Else YOff := 169;                { Color }
    If ( Length( S ) > 60 ) Then S[0] := Chr( 60 );
    S := Concat( S, Chr(0), Chr(0) );
    Draw_Six( 16, X, Y, YOff, C1, C2, S );
  End;

  Procedure Get_TimeLeft;
  Begin
    Connected := Get_Timr - Timeon;
    Connected := Connected Div 12000;
    Timeleft := Minutes - Connected;
  End;

  Procedure Show_Connected;
  Begin
    Get_TimeLeft;
    writev( Line, Connected, '/', Minutes );
    Write_Six( 67, 1, Blk, Redd, Line );
  End;

  Procedure Show_TimeLeft;
  Begin
    Get_TimeLeft;
    Writev( Line, '( /r', Timeleft, '/b Mins ) ' );
  End;

  Procedure Show_Secs_Left;
  Begin
    writev( Temp, Seconds:3 );
    Write_Six( 77, 1, Redd, Blk, Temp );
  End;

  Procedure Show_DL_UL;
  Begin
    Writev( Temp, UserAcs.UpLoads );    Write_Six( 62,2,Blk,Redd, Temp );
    Writev( Temp, UserAcs.DownLoads );  Write_Six( 75,2,Blk,Grn, Temp );
  End;

  Procedure Lower_C( Var Ch:Char );
  Begin
    If ( Ch In ['A'..'Z'] ) Then Ch := Chr( Ord(Ch) + 32 );
  End;

  Procedure Lower_S( Var S: String );
  Var
    I : Integer;
    Ch: Char;
  Begin
    If ( Length( S ) >0 ) Then Begin
      For I := 1 To Length( S ) Do Begin
        Ch := S[ I ];  Lower_C( Ch );  S[ I ] := Ch;
      End;
    End;
  End;

  Procedure Upper_C( Var Ch:Char );
  Begin
    If ( Ch In ['a'..'z'] ) Then Ch := Chr( Ord(Ch) - 32 );
  End;

  Procedure Upper_Case( Var S: String );
  Var
    I : Integer;
    Ch: Char;
  Begin
    If ( Length( S ) >0 ) Then Begin
      For I := 1 To Length( S ) Do Begin
        Ch := S[ I ];  Upper_C( Ch );  S[ I ] := Ch;
      End;
    End;
  End;

  Procedure Bell( Jif : Integer );
  Begin
    Pause( Jif );
    Put_Console( Chr( 7 ) );
    If ( Not Local ) Then Put_Modem( Chr( 7 ) );
  End;

  Procedure Flush_Input;
  Var
    X : Integer;
  Begin
    If Not Local Then Begin
      While ( Mdm_In ) Do X := Get_Modem;
    End;
    While ( Con_In ) Do X := Get_Console;
  End;

  Procedure Put_Char( Ch: Char );
  Begin
    Put_Console( Ch );
    If ( Not Local ) Then Put_Modem( Ch );
  End;

  Procedure Back_Space;
  Begin
    Put_Char( Chr( Bksp ) );
    Put_Char( ' ' );
    Put_Char( Chr( Bksp ) );
  End;

  Procedure CCrLf;
  Begin
    Put_Console( Chr( Cr ) );
    Put_Console( Chr( Lf ) );
  End;

  Procedure EchoC( L : String );
  Var
    I : Integer;
  Begin
    For I := 1 To Length( L ) Do Put_Console( L [ I ] );
  End;

  Procedure EchoCE( L : String );
  Begin
    EchoC( L );  CCrLf;
  End;

  Procedure CrLf;
  Begin
    If Carrier Then Begin
      If ( Not Local ) Then Begin
        Put_Modem( Chr( Cr ) );
        Put_Modem( Chr( Lf ) );
      End;
      CCrLf;
    End;
  End;

  Procedure CEscape( S : String );
  Var
    I : Integer;
  Begin
    Put_Console( Escp );
    For I := 1 To Length( S ) Do
      Put_Console( S[ I ] );
  End;

  Procedure MEscape( S : String );
  Var
    I : Integer;
  Begin
    Put_Modem( Escp );
    For I := 1 To Length( S ) Do
      Put_Modem( S[ I ] );
  End;

  Procedure Con_White( Md:Byte );
  Begin
    If ( Rez <> 2 ) Then Begin
      If ( Md = 0 ) Then CEscape( 'b0' )  Else CEscape( 'c0' );
    End;
  End;

  Procedure Con_Red( Md:Byte );
  Begin
    If ( Rez <> 2 ) Then Begin
      If ( Md = 0 ) Then CEscape( 'b1' )  Else CEscape( 'c1' );
    End;
  End;

  Procedure Con_Green( Md:Byte );
  Begin
    If ( Rez <> 2 ) Then Begin
      If ( Md = 0 ) Then CEscape( 'b2' )  Else CEscape( 'c2' );
    End;
  End;

  Procedure Con_Black( Md:Byte );
  Begin
    If ( Rez <> 2 ) Then Begin
      If ( Md = 0 ) Then CEscape( 'b3' )  Else CEscape( 'c3' );
    End;
  End;

  Procedure Esc_White( Md:Byte );
  Begin
    Con_White( Md );
    If ( Not Local ) Then Begin
      If ( Md = 0 ) Then MEscape( 'b0' )  Else MEscape( 'c0' );
    End;
  End;

  Procedure Esc_Red( Md:Byte );
  Begin
    Con_Red( Md );
    If ( Not Local ) Then Begin
      If ( Md = 0 ) Then MEscape( 'b1' )  Else MEscape( 'c1' );
    End;
  End;

  Procedure Esc_Green( Md:Byte );
  Begin
    Con_Green( Md );
    If ( Not Local ) Then Begin
      If ( Md = 0 ) Then MEscape( 'b2' )  Else MEscape( 'c2' );
    End;
  End;

  Procedure Esc_Black( Md:Byte );
  Begin
    Con_Black( Md );
    If ( Not Local ) Then Begin
      If ( Md = 0 ) Then MEscape( 'b3' )  Else MEscape( 'c3' );
    End;
  End;

  Procedure AnC_White( Md:Byte );
  Begin
    Con_White( Md );
    If ( Not Local ) Then Begin
      Put_Modem( Chr( 27 ) );
      Put_Modem( '[' );
      If ( Md = 0 ) Then Put_Modem( '3' )  Else Put_Modem( '4' );
      Put_Modem( W_Color );
      Put_Modem( 'm' );
    End;
  End;

  Procedure AnC_Red( Md:Byte );
  Begin
    Con_Red( Md );
    If ( Not Local ) Then Begin
      Put_Modem( Chr( 27 ) );
      Put_Modem( '[' );
      If ( Md = 0 ) Then Put_Modem( '3' )  Else Put_Modem( '4' );
      Put_Modem( R_Color );
      Put_Modem( 'm' );
    End;
  End;

  Procedure AnC_Green( Md:Byte );
  Begin
    Con_Green( Md );
    If ( Not Local ) Then Begin
      Put_Modem( Chr( 27 ) );
      Put_Modem( '[' );
      If ( Md = 0 ) Then Put_Modem( '3' )  Else Put_Modem( '4' );
      Put_Modem( G_Color );
      Put_Modem( 'm' );
    End;
  End;

  Procedure AnC_Black( Md:Byte );
  Begin
    Con_Black( Md );
    If ( Not Local ) Then Begin
      Put_Modem( Chr( 27 ) );
      Put_Modem( '[' );
      If ( Md = 0 ) Then Put_Modem( '3' )  Else Put_Modem( '4' );
      Put_Modem( B_Color );
      Put_Modem( 'm' );
    End;
  End;

  Procedure Set_Background;
  Begin
    CEscape( 'c0' );
    If ( VT52 ) And ( Not Local ) Then MEscape( 'c0' )
    Else If ( ANSI ) And ( Not Local ) Then Begin
      MEscape( '[4' );
      Put_Modem( Bk_Color );  Put_Modem( 'm' );
    End;
  End;

  Procedure EchoS( S : String );
  Var
    I, X : Integer;
    Ch, C : Char;
  Begin
    If ( Carrier ) Then Begin
      For I := 1 to Length( S ) Do Begin
        Ch := S[ I ];  C := Chr( 0 );
        If ( Length( S ) >I ) Then C := S[ I + 1 ];
        If (Ch='/') and ( C In [ 'w','r','g','b','W','R','G','B','K' ] ) Then Begin
          If ( C = 'K' ) Then Set_Background;
          If ( VT52 ) Then Begin
            If ( V_Color ) Then
              Case C of
                'w' : Esc_White(0);
                'r' : Esc_Red(0);
                'g' : Esc_Green(0);
                'b' : Esc_Black(0);
                'W' : Esc_White(1);
                'R' : Esc_Red(1);
                'G' : Esc_Green(1);
                'B' : Esc_Black(1);
              End;
              I := I + 1;
          End
          Else If ( ANSI ) Then Begin
            If ( A_Color ) Then
              Case C of
                'w' :  AnC_White(0);
                'r' :  AnC_Red(0);
                'g' :  AnC_Green(0);
                'b' :  AnC_Black(0);
                'W' :  AnC_White(1);
                'R' :  AnC_Red(1);
                'G' :  AnC_Green(1);
                'B' :  AnC_Black(1);
            End;
            I := I + 1;
          End
          Else If ( V_Color=False ) And ( A_Color = False ) Then I := I + 1;
        End
        Else Begin
          Put_Console( Ch );
          If ( Not Local ) Then Put_Modem( Ch );
        End;
        X := Scan_Input;
        If ( X = CtrlC ) Then Begin I := Length( S ); Abort := True; End
        Else If ( X = CtrlS ) Then Begin
          Repeat
            X := Scan_Input;
          Until ( X=CtrlS ) or ( X=CtrlQ ) or ( X=CtrlC ) or ( No_Carrier );
          If ( X = CtrlC ) Then Begin I := Length( S ); Abort := True; End;
        End;
      End;
    End;
  End;

  Procedure EchoSE( L : String );
  Begin
    EchoS( L );  Crlf;
  End;

  Procedure AddSpaces( Var L : String ; Lngth: Integer );
  Begin
    While Length( L ) < Lngth Do L := Concat( L, ' ' );
    If ( Ord( L[0] ) > Lngth ) Then L[0] := Chr( Lngth );
  End;

  Procedure EchoN( S : String );
  Var
    N, X : Integer;
  Begin
    X := Length( S );
    If ( X < WidT ) Then Begin
      N := ( WidT - X ) Div 2;
      While Length( S ) < N + X Do S := Concat( ' ', S );
    End;
    EchoS( S );
  End;

  Procedure EchoNE( S : String );
  Begin
    EchoN( S );  CrLf
  End;

  Procedure Chat_Wrap( Var S: String; X: Integer; Var KyCnt: Integer; Md: Integer );
  Begin
    S := Concat( S, Chr( X ) );
    KyCnt := KyCnt + 1;
    If X=32 Then S := '';
    If ( KyCnt>=WidT-2 ) And ( Length( S ) =WidT-2 ) Then Begin CrLf; S:=''; KyCnt:=0; End
    Else If ( KyCnt>=WidT-2 ) And ( Length( S ) >0 ) Then Begin
      KyCnt := Length( S );
      For X := 1 to KyCnt Do Back_Space;
      CrLf;
      For X := 1 to KyCnt Do Put_Char( S[X] );
    End
    Else Begin
      If Md=1 Then Begin
        Put_Console( Chr( X ) );
        Put_Modem( Chr( X ) );
      End
      Else Put_Console( Chr( X ) );
    End;
  End;

  Procedure Chat_Mode;
  Var
    Temp : String[40];
    S : String;
    I, KyCnt : Integer;
  Begin
    Write_Six( 45,2,Blk,Wht,'         ' );
    CrLf; EchoSE( 'SysOp Entering Chat Mode...' );
    EchoCE( 'Press F5 To Exit Chat Mode...' ); CrLf;  CrLf;
    Fnct_Key := 0;  KyCnt := 0;  S := '';
    Repeat
      If ( Mdm_In ) And ( Not Local ) Then Begin
        I := Get_Modem;  Put_Modem( Chr( I ) );
        If ( I=Cr ) Then Begin CrLf; S := ''; KyCnt := 0; End
        Else If ( I<>Cr ) And ( I<>Lf ) And ( I<>Esc ) Then Chat_Wrap( S, I, KyCnt, 0 );
      End
      Else If ( Con_In ) Then Begin
        I := Get_Console;
        If ( I=Cr ) Then Begin CrLf; S := ''; KyCnt := 0; End
        Else If ( I<>Cr ) And ( I<>Lf ) And ( I<>Esc ) Then Chat_Wrap( S, I, KyCnt, 1 );
      End;
    Until ( Fnct_Key=F5 ) or ( No_Carrier );
    Fnct_Key := 0;
    CrLf; EchoSE( 'You Now Have Control...' ); CrLf; CrLf;
    { Maxtime := Get_Timr + 36200; }
  End;

  Procedure Toggle_Chat;
  Var
    S : String;
  Begin
    If ( Chat ) Then Begin S := 'Off'; Chat := False; End
    Else Begin S := 'On'; Chat := True; End;
    Write_Six( 40,2,Blk,Grn,  S );  CrLf;  CrLf;
  End;

  Procedure Show_Wrong;
  Begin
    EchoSE( 'Wrong Key Try ''?'' ' );  CrLf;
  End;

  Procedure Clear_Local;
  Begin
    CEscape( 'c0' );  CEscape( 'H' );  CEscape( 'J' );
    Lin_Count := 0;    
  End;

  Procedure Clear_Screen;
  Begin
    Clear_Local;    
    If Carrier Then Begin
      Set_BackGround;
      If ( VT52 ) And ( Not Local ) Then Begin
        MEscape( 'H' );  MEscape( 'J' );
      End
      Else If ( ANSI ) And ( Not Local ) Then Begin
        MEscape( '[1m' );  MEscape( '[2J' );
      End
      Else If ( Not Local ) Then Put_Modem( Chr( 12 ) );
    End;
  End;

  Procedure Extract_Filename( S:String; Var D : String );
  Var
    I, X : Integer;
  Begin
    I := Length( S ); X := I; D := '';
    If ( Pos( '\', S ) >0 ) Then Begin
      While ( S[X] <> '\' ) Do X := X - 1;
      D := Copy( S, X+1, I-X );
    End
    Else If ( Pos( '/', S ) >0 ) Then Begin
      While ( S[X] <> '/' ) Do X := X - 1;
      D := Copy( S, X+1, I-X );
    End
    Else D := S;
    X := Length( D );
    If ( X > 12 ) Then Delete( D, 13, X - 12 );
  End;

  Function FileName_Ok( Var S : String ): Boolean;
  Var
    Ch : Char;
    Cnt, Pnt, I : Integer;
  Begin
    Cnt := 0;
    Pnt := 0;
    For I := 1 to Length( S ) Do Begin
      Ch := S[I];
      If ( Ch='.' ) Then Pnt := Pnt + 1;
      If ( Ch In['0'..'9'] ) or ( Ch In['A'..'Z'] ) or 
        ( Ch='_' ) or ( Ch='.' ) Then Cnt := Cnt + 1;
    End;
    If ( Cnt=Length( S ) ) And ( Pnt<2 ) Then FileName_Ok := True
      Else FileName_Ok := False;
  End;

  Function Is_Numeric( Var Str : String ): Boolean;
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

  Function Check_Line( Var Str: String; Ch: Char; Cnt: Integer ): Boolean;
  Var
    Ln, I, X : Integer;
    Ch2 : Char;
  Begin
    X := 0;
    Ln := Length( Str );
    For I := 1 to Ln Do Begin
      Ch2 := Str[I];
      If Ch2 = Ch Then X := X +1;
    End;
    If X = Cnt Then Check_Line := True  Else Check_Line := False;
  End;

  Procedure Show_Cur_Time;    { Updated 2-22-96 }
  Var
    X, H, M, S : Integer;
    H2,M2,S2: String[2];
  Begin
    Get_STime( H, M, S );
    Writev( H2, H:2 );
    Writev( M2, M:2 );
    Writev( S2, S:2 );
    If ( M < 10 ) Then M2[1] := '0';
    If ( S < 10 ) Then S2[1] := '0';
    Line := Concat( H2,':',M2,':',S2 );
    Write_Six( 82,4,Blk, Wht, Line );
    Mil_Time := Line;
  End;

  Procedure Convert_Time( Time: Integer );
  Var
    H : Long_Integer;
    M, S : Integer;
    Pm : String[2];
    Temp: String[6];
  Begin
    Pm := 'am';
    H := ( Time & 63488 );
    H := Shr( H, 11 );
    M := ( Time & 2016 );
    M := Shr( M, 5 );
    S := ( Time & 31 ) * 2;
    If H=0 Then H := 12;
    If H>12 Then Begin
      H := H - 12;
      Pm := 'pm';
    End;
    Writev( Line, H:2, ':' );
    If ( M < 10 ) Then Line := Concat( Line, '0' );
    Writev( Temp, M );
    Line := Concat( Line, Temp );
    Line := Concat( Line, ':' );
    If ( S < 10 ) Then Line := Concat( Line, '0' );
    Writev( Temp, S );
    Line := Concat( Line, Temp );
    Line := Concat( Line, Pm );
  End;

  Procedure Convert_Date( Date: Integer );
  Begin
    Y := ( Date & 65024 );
    Y := Shr( Y, 9 );
    Y := Y + 1980;
    M := ( Date & 480 );
    M := Shr( M, 5 );   If ( M < 1 ) Then M := 12;
    D := ( Date & 31 ); If ( D < 1 ) Then D := 30;
    Writev( Line, Month[M], D:2, ', ', Y );
  End;

  Procedure Convert_Date2( Var Line : String );
  Var S : String;
  Begin
    While ( Length( Line ) <6 ) Do  Line := Concat( Line, '1' );
    S := Copy( Line, 1,2 );
    M := Val( S );
    S := Copy( Line, 4,2 );
    D := Val( S );
    S := Copy( Line, 7,2 );
    Y := Val( S ) + 1900;
    Writev( Line, Month[M], D:2, ', ', Y );
  End;

  Procedure Show_Cur_Date;
  Begin
    Get_SDate;    
    Writev( Line, 'M=', M, ' D=', D, ' Y=', Y );  EchoSE( Line  );
    Writev( Line, Month[ M ], D:2, ', ', Y );
    Write_Six( 93,4,Blk, Wht, Line );
  End;

  Procedure Show_40( Var S: String );
  Var
    I, X : Integer;
  Begin
    X := 0;
    For I := 1 to Length( S ) Do If ( S[I]='/' ) Then X := X + 1;
    If ( WidT=80 ) Then AddSpaces( S, (X*2)+39 );  EchoS( S );
    If ( ( WidT=80 ) And ( New_Line ) ) or ( WidT=40 ) Then CrLf;
    New_Line := Not New_Line;
  End;

  Procedure Disconnect;
  Begin
    CrLf; CrLf;
    Line := Concat( 'Thanks For Calling ', UserRec.UHandle, ',' );
    EchoSE( Line ); EchoSE( 'Call Back Again Soon...' );
    Pause( 200 );
    Hang_Up;  Local := False;
  End;

  Procedure Do_LogOFF;
  Var
    Maxtime : Long_Integer;
    I : Integer;
    Ch : Char;
  Begin
    CrLf;
    EchoSE( '  Transfer Completed... ' );  CrLf;
    EchoS ( 'Log-Off in 10 Seconds, Press [/rH/b]ang-Up Now or [/rR/b]eturn to BBS ' );
    Maxtime := ( Get_Timr + 2200 );  I := TimeOut;
    Repeat
      Repeat
        Seconds := ( MaxTime-Get_Timr ) Div 200;
        Show_Secs_Left;  Show_Cur_Time;  Show_Connected;  I := Scan_Input;
      Until ( I > 0 ) Or ( No_Carrier ) Or ( Get_Timr > Maxtime );
      Ch := Chr( I );  Upper_C( Ch );
    Until ( Ch = 'H' ) or ( Ch = 'R' ) or ( No_Carrier ) Or ( Get_Timr > Maxtime );
    If ( Ch = 'H' ) or ( Get_Timr > MaxTime ) Then Disconnect;
  End;

  Procedure UsedUp_Time;
  Begin
    CrLf;
    EchoSE( 'Sorry, You''ve Used Up All Of Your Time For This Call...' );
    Disconnect;
  End;

  Function Get_Char: Char;
  Var
    Maxtime : Long_Integer;
    I : Integer;
    Ch : Char;
    Sec2 : Boolean;
  Begin
    Maxtime := ( Get_Timr + 36200 );  I := TimeOut;  Sec2 := False;
    Repeat
      Get_TimeLeft;
      If ( Timeleft < 1 ) Then Begin  UsedUp_Time;  I := Timeout;  End
      Else Begin
        Seconds := ( MaxTime-Get_Timr ) Div 200;
        If ( Seconds = 30 ) And ( Sec2=False ) Then Begin
          CrLf; CrLf; EchoSE( '/r<<30 Seconds (Bells) Till Auto-Logoff>>/b' );
          CrLf; Sec2:=True;
        End;
        If ( Seconds <= 30 ) Then Bell( 190 );
        Show_Secs_Left;  Show_Cur_Time;  Show_Connected;  I := Scan_Input;
      End;
    Until ( I>Timeout ) Or ( No_Carrier ) Or ( Get_Timr>Maxtime );
    If ( Get_Timr>MaxTime ) or ( Seconds=0 ) Then Disconnect;
    Get_char := Chr( I );
  End;

  Procedure Line_In( Var Temp:String; Lgth:Integer );
  Var
    Ch : Char;
    I, X : Integer;
  Begin
    Temp := ''; X := 0;
    Repeat
      Ch := Get_char;  I  := Ord ( Ch );
      If ( Caps ) Then Upper_C( Ch );
      If ( I=Bksp ) And ( X >0 ) Then Begin
        Back_Space;
        X := X - 1;
        Temp[0] := Chr( X );
      End
      Else If ( I>31 ) Then Begin
        Temp := Concat( Temp, Ch );
        Put_Char( Ch );
        X := X + 1;
      End;
    Until ( I=Cr ) or ( X=Lgth ) or ( No_Carrier );
  End;

  Function Yes_No( Md : Char ) : Boolean;
  Var
    Ch : Char;
    K : Integer;
  Begin
    Yes_No := False;
    If ( Md='Y' ) Then EchoS( '( /gY/b/n ) ' )  Else EchoS( '( y//gN/b ) ' );
    Repeat
      Ch := Get_Char;  Upper_C( Ch );  K := Ord( Ch );
    Until ( Ch='Y' ) or ( Ch='N' ) or ( K=Cr ) or ( No_Carrier );
    If ( Ch='Y' ) or ( ( Md='Y' ) And ( K=Cr ) ) Then Begin
      EchoSE( 'Yes' );
      Yes_No := True;
    End
    Else EchoSE( 'No' );
  End;

  Function Get_A_Number( Num: Long_Integer ): Long_Integer;
  Var
    NS : String[8];
    X,Ln : Integer;
    I : Long_Integer;
    Ch : Char;
  Begin
    NS := '';  Writev( NS, Num );  Ln := Length( NS );  NS := '';
    Repeat
      Repeat
        Repeat
          Ch := Get_Char;
        Until ( Ch In['0'..'9'] ) or ( Ord(Ch) = Cr ) or ( No_Carrier );
        If Ch In['0'..'9'] Then Begin
          NS := Concat( NS, Ch );  EchoS( Ch );
        End;
      Until ( Length( NS ) = Ln ) or ( Ord(Ch) = Cr ) or ( No_Carrier );
      If Length( NS ) >0 Then Begin
        Readv( NS, I );
        If ( I>Num ) Then Begin
          For X := 1 to ( Length( NS ) ) Do Back_Space;  NS := '';
        End;
      End
      Else I := Timeout;
    Until ( I<=Num ) or ( No_Carrier );
    Get_A_Number := I;
  End;

  Function Get_Number( Num: Integer ): Integer;
  Begin
    Get_Number := Int( Get_A_Number( Num ) );
  End;

  Procedure Press_Any;
  Var
    Ch : Char;
  Begin
    CrLf;
    EchoS( '/gPress Any Key To Continue.../b' );
    Ch := Get_Char;
    CrLf;
  End;

  Procedure Fn_Convert( Var S1: String; Var S2: String );
  Var
    I : Integer;
    Q,R : String;
  Begin
    I := Pos( '.', S1 );
    If ( I > 1 ) Then Begin
      Q := Copy( S1, 1, I - 1 );
      AddSpaces( Q, 8 );
      R := Copy( S1, I, ( Length( S1 ) - I + 1 ) );
      S2 := Concat( Q, R );
    End
    Else Begin
      S2 := S1;
      AddSpaces( S2, 12 );
    End;
  End;

  Procedure MakeFname( Var Name : Fn_String; Var S: String );
  Var I: Integer;
  Begin
    S := '';
    I := 1;
    While Name[I]<> #0 Do Begin
      S := Concat( S, Name[I] );
      I := I + 1;
    End;
  End;

  Procedure MakePString( Var Name:Cstring; Var S: String );
  Var I: Integer;
  Begin
    S := '';
    I := 0;
    While Name[I]<> #0 Do Begin
      S := Concat( S, Name[I] );
      I := I + 1;
    End;
  End;

  Procedure MakeCstring( Var Source: String; Var Dest: Cstring );
  Var
    X : Integer;
  Begin
    For X := 1 To Length( Source ) Do Dest[X - 1] := Source[X];
    X := Length( Source );
    Dest[X] := Chr( 0 );
  End;

  Procedure Show_File( F : String );
  Var
    I : Integer;
    Ch : Char;
  Begin
    Lower_S( F );
    Line := F;
    AddSpaces( Line, 40 );
    Write_Six( 7,4, Blk,Wht, Line );
  End;

  Function FCreate( Var F:String; Attr: Integer ):Integer;
  { Attr: 0=Norm, 1=R/O }
  Var
    C : Cstring;
  Begin
    Show_File( F );
    MakeCstring( F, C );
    FCreate := Create_File( C, Attr );
  End;

  Function FOpen( Var F: String; Md: Integer ):Integer;
  { Md: 0=Read Only, 1=Write Only, 2=Read & Write}
  Var
    C : Cstring;
  Begin
    Show_File( F );
    MakeCstring( F, C );
    FOpen := Open_File( C, Md );
  End;

  Procedure Write_Ln( Hndl: Integer; S: String );
  Var
    I,X : Long_Integer;
  Begin
    S := Concat( S, Chr( Cr ) , Chr( Lf ) );
    X := Length( S );
    For I := 1 to X Do Blkio[I] := Ord( S[I] );
    I := BlockWrite( Hndl, X, Blkio );
  End;

  Function Read_Ln( H, Max:Integer ): Integer;
  Var
    I,X : Long_Integer;
    B  : Byte;
    L  : Integer;
    Ch : Char;
  Begin
    X := FSeek( 0, H, 2 );  I := FSeek( 0, H, 0 );
    If ( X >= Block_Size ) Then X := Block_Size;
    I := BlockRead( H, X, Blkio );
    L := 0;  I := 0;
    Repeat
      L := L + 1;  Temp := '';
      Repeat
        I := I + 1;  B := BlkIo[ I ];  Ch := Chr( B );
        If ( B<>13 ) And ( B<>10 ) Then Temp := Concat( Temp, Ch );
      Until ( B = 13 ) or ( I >= X ) or ( Length( Temp ) = 80 );
      MesgL[ L ] := Temp;
      I := I + 1;
    Until ( I >= X ) or ( L >= Max );
    Read_Ln := L;
  End;

  Function Exists( F: String ):Boolean;
  Var
    H,X : Integer;
  Begin
    Result := False;
    H := FOpen( F, 0 );  If ( H >= 0 ) Then Result := True;
    X := Close_File( H );
    Exists := Result;
  End;

  Function F_Search( X : Integer ):Integer;
  Var
    A, I, T, Y : Integer;
    C : CString;
  Begin
    Y := 0;  If ( Dos_Mode ) Then Y := 63;
    MakeCString ( FPath, C );  T := FCnt;
    If ( FCnt=0 ) Then Begin I := SFirst( C, Y ); FCnt := 1; End
    Else If ( X<0 ) Then Begin
      X := Abs ( X );
      If ( FCnt >= X ) Then FCnt := FCnt - X Else  FCnt := 0;
      I := SFirst( C, 0 ); T := FCnt - 1;
      If ( FCnt>0 ) Then For A := 1 To T Do I := SNext;
    End
    Else If ( X>0 ) Then Begin
      FCnt := FCnt + X;
      T := ( FCnt - T );
      For A := 1 To T Do I := SNext;
    End;
    If ( FCnt=0 ) Then FCnt := 1;
    F_Search := I;
  End;

  Procedure Max_File;
  Var
    X : Integer;
  Begin
    FCnt := 0;  X := 0;
    While ( F_Search( 1 ) = 0 ) Do X := X + 1;
    FMax := X;
  End;

  Procedure Log( Md, Num : Integer );
  Var
    X : Long_Integer;
    H,I : Integer;
    S,Q : String;
  Begin
    If ( Md = 0 ) Then S := Log_Filename Else S := Ftu_ErrFile;
    If Exists( S ) Then H := FOpen( S, Update_Mode )
      Else H := FCreate( S, 0 );
    If ( H < 0 ) Then Begin
      H := Abs( H );
      Writev( Q, 'Error -', H ); If ( H > 70 ) Then H := 70;
      Q := Concat( Q, '  ', Err[H] );
      CrLf;
      WriteLn( Q ); Write( 'Unable To Open -> ' ); WriteLn( S );
      CrLf;
    End
    Else Begin
      X := Fseek( 0, H, 2 );  I := Int( X );
      If ( I >= 0 ) Then Begin
        For I := 1 to Num Do Write_Ln( H, DescL[I] );
      End;
      I := Close_File( H );
    End;
  End;

  Procedure Show_Xyz_Error( Error: Integer );
  Var
    Temp,Desc: String;
  Begin
    If Error <> 0 Then Begin
      Error := Abs( Error );
      If ( Error > 22 ) Then Error := 23;
      Writev( Temp, '-', Error );
      Desc := Xyz[Error];
      DescL[1] := ' ';
      DescL[2] := Concat ( '   XYZ Error: ', Temp );
      DescL[3] := Concat ( ' Description: ', Desc );
      Log( 1, 3 );
    End;
  End;

  Procedure Show_Error( P:String; Error: Integer );
  Var
    Temp,Desc: String;
  Begin
    If Error <> 0 Then Begin
      Error := Abs( Error );
      Writev( Temp, '-', Error );
      If ( Error > 70 ) Then Error := 70;
      Desc := Err[Error];
      DescL[1] := ' ';
      DescL[2] := Concat( 'System Error: ', Temp );
      DescL[3] := Concat( '    Filename: ', P );
      DescL[4] := Concat( ' Description: ', Desc );
      EchoSE( DescL[1] );
      EchoSE( DescL[2] );
      EchoSE( DescL[3] );
      EchoSE( DescL[4] );
      CrLf;
      Log( 1, 4 );
    End;
  End;

  Procedure Make_Work_Path;
  Var
    C : CString;
    F : String;
  Begin
    GetDir( C, 0 );  MakePString( C, F );
    Work_Path := Concat( Chr( 65 + Drv ), ':', F, '\' );
    Show_File( Work_Path );
    Upper_Case( Work_Path );
  End;

  Function Change_Drive( D:Char ) : Integer;
  Var
    X, I, Dd : Integer;
    F : String;
  Begin
    Upper_C( D );  Dd := Drv;  Drv := Ord( D ) - 65;  I := 0;
    If Drive_Exist( Drv ) Then Begin
      I := 1;
      X := SetDrv( Drv );
      Make_Work_Path;
    End;
    If ( I = 0 ) Then Begin
      Show_Error( F, -69 );
      Drv := Dd;
    End;
    Change_Drive := I;
  End;

  Procedure Change_Dir( Var S:String );
  Var
    C : CString;
    X : Integer;
  Begin
    S := Concat( S, Chr(0) );  MakeCString( S, C );
    X := ChDir( C );
    If ( X < 0 ) Then Show_Error( S, X )
    Else Make_Work_Path;
 {   WriteV( Line, 'ChDir Status => ', X ); EchoSE( Line ); }
  End;

  Procedure Change_Drv_Path( S: String );
  Var
    L,X : Integer;
    F : String;
    Ch : Char;
  Begin
    F_Name := S;  F := S; L := Length( S );  Show_File( F_Name );
    Ch := S[1]; X := Change_Drive( Ch );
    If ( X = 1 ) And ( L > 2 ) Then Begin
      Delete( S, 1, 2 );  Change_Dir( S );
    End;
    If ( L<3 ) then Begin
      Show_Error( F, -68 );
    End;
  End;

  Procedure DT_Stamp( Var S:String );
  Var
    H, I, T, X: Integer;
    F : CString;
  Begin
    T := Get_Stime2;  Blkio[1] := Shr( T, 8 );  Blkio[2] := ( T & 255 );
    I := Get_SDate2;  Blkio[3] := Shr( I, 8 );  Blkio[4] := ( I & 255 );
    MakeCString( S, F );
    H := Open_File( F, 0 );
    If ( H > 0 ) Then Begin
      X := GSDTOF( Blkio, H, 1 );
      If ( X < 0 ) Then Show_Error( S, X )
      Else Begin
        Dta_Data.Time := T;  Dta_Data.Date := I;
      End;
      X := Close_File ( H );
      If ( X < 0 ) Then Show_Error( S, X );
      EchoSE( '  Time/Date Stamp Updated...' ); CrLf;
    End
    Else Show_Error( S, H );
  End;

  Procedure Get_Dfree( Var Fre, Tcl, Ssb, Cps : Long_Integer; Ch:Char );
  Type
    FreeHdr = Packed Record
    Case Integer of
      1 : ( Data: Packed Array[1..4] of Long_Integer );
      2 : ( Buff: BlockIO );
    End;
  Var
    FH : FreeHdr;
    X  : Long_Integer;
    S : String[12];
    I : Integer;
  Begin
    I := Drv;  If ( Ch <> '.' ) Then Drv := Ord( Ch ) - 65;
    S := Concat( 'Drive: ', Chr( Drv + 66 ) );
    X := DFree( FH.Buff, Drv+1 );
    Dummy_I := Int( X );  If ( Dummy_I < 0 ) Then Show_Error( S, Dummy_I );
    Fre := FH.Data[1]; { number of free clusters }
    Tcl := FH.Data[2]; { total number of clusters }
    Ssb := FH.Data[3]; { sector size in bytes }
    Cps := FH.Data[4]; { clusters per sector }
    Drv := I;
  End;

{$I Sec_Chk.Pas }

{  Function Security_Chk : Boolean;
  Begin
    Dummy_Routine;
    EchoSE ( Line );  CrLf;
    Security_Chk := True;
  End; }

  Procedure Show_Dfree( Ch : Char );
  Var
    Fre, Tcl, Ssb, Cps, Free : Long_Integer;
  Begin
    Get_DFree( Fre, Tcl, Ssb, Cps, Ch );
    Free := ( Ssb * Cps );
    Free := ( Free * Fre );
    Writev( Line, 'Total Upload Space = ', Free, ' Bytes' );
    CrLf;
    EchoSE( Line );
    CrLf;
  End;

  Procedure Copy_File( Var In_File, Out_File :String; Md:Integer );
  Var
    N,X,Tot,Siz,Tsiz,Fp,FPos : Long_Integer;  { updated 3-15-96 }
    H1, H2, R : Integer;
  Begin
    H1 := FOpen( In_File, 0 );  Siz := FSeek( 0, H1, 2 );
    X  := FSeek( 0, H1, 0 );    H2  := FCreate( Out_File, 0 );
    If ( H2 < 0 ) Then Show_Error( In_File, H2 )
    Else Begin
      Tot := Siz;  FPos := 0;
      If ( Md = 1 ) Then Begin
        R := Close_File( H1 );
        R := Close_File( H2 );
      End;
      If ( H2 > 0 ) Then Repeat
        If ( Tot >= Block_Size ) Then TSiz := Block_Size  Else Tsiz := Tot;
        If ( Md = 1 ) Then Begin
          H1 := FOpen( In_File, 0 );  Fp := FSeek( FPos, H1, 0 );
        End;
        N := BlockRead( H1, TSiz, Blkio );
        If ( N < 0 ) Then Begin
          Show_Error( In_File, Int( N ) );  Tot := 0;
        End
        Else FPos := FPos + N;
        If ( Md = 1 ) Then R := Close_File( H1 );
        If ( N > 0 ) Then Begin
          If ( Md = 1 ) Then Begin
            H2 := FOpen( Out_File, 2 );  X  := FSeek( 0, H2, 2 );
          End;
          X := BlockWrite( H2, TSiz, Blkio );
          If ( X < 0 ) Then Begin
            Show_Error( Out_File, Int( X ) );  Tot := 0;
          End
          Else Tot := Tot - Tsiz;
          If ( Md = 1 ) Then R := Close_File( H2 );
        End;
      Until ( Tot = 0 );
    End;
    R := Close_File( H1 );  R := Close_File( H2 );
  End;

  Procedure Get_DL_Time_Str( X : Integer );
  Var
    H,M,S : Integer;
  Begin
    H := 0; M := 0; S := 0;
    H := ( X div 3600 ); If (H>0) Then X := X - ( H * 3600 );
    M := ( X Div 60 );   If (M>0) Then X := X - ( M * 60 );
    S := X; 
    Writev( DL_Time_Str, H:2, ':', M:2, ':', S:2 );
    If ( H<10 ) Then DL_Time_Str[1] := '0';
    If ( M<10 ) Then DL_Time_Str[4] := '0';
    If ( S<10 ) Then DL_Time_Str[7] := '0';
  End;

  Procedure Get_DL_Time;
  Var
    D, X : Long_Integer;
  Begin
    X := Cps - ( Cps Div 30 );
    D := Dta_Data.Size;
    DL_Time := Int ( D Div X );
    If ( DL_Time < 5 ) Then DL_Time := 5;
    Get_DL_Time_Str( DL_Time );
  End;

  Function Dl_Ratio_Ok( A1:Integer; A2,A3:Long_Integer ) : Boolean;
  Var
    Ok : Boolean;
    R : Integer;
    X, DL, UL, RT, DL_Check, DL_More : Long_Integer;
  Begin
    Ok := False;
    R := UserAcs.Ratio_Typ;
    If ( System2.Free_Dnld[ Sig_Num ] ) or ( R = 0 ) Then Ok := True
    Else Begin
      If ( R = 1 ) Then Begin
        DL := UserAcs.Downloads;
        UL := UserAcs.Uploads;
        RT := UserAcs.DL_Ratio;
        DL_Check := ( UL * RT ); DL_More := ( DL_Check - DL );
        If ( DL_More >= A1 ) Then Ok := True;
      End
      Else If ( R = 2 ) Then Begin
        DL := UserAcs.K_Dnld;
        UL := UserAcs.K_Upld;
        RT := UserAcs.K_Ratio;
        If ( A2 <> 0 ) Then X := A2
          Else X  := ( ( DTA_Data.Size + 1023 ) Div 1024 );
        DL_Check := ( UL * RT ); DL_More := ( DL_Check - DL );
        If ( DL_More >= X ) Then Ok := True;
      End
      Else If ( R = 3 ) Then Begin
        DL := UserAcs.Pts_Dnld;
        UL := UserAcs.Pts_Upld;
        RT := UserAcs.Pts_Ratio;
        If ( A3 <> 0 ) Then X := A3
        Else X  := ( ( DTA_Data.Size + 1023 ) Div 1024 ) * System2.Pts_K;
        DL_Check := ( UL * RT ); DL_More := ( DL_Check - DL );
        If ( DL_More >= X ) Then Ok := True;
      End;
    End;
    Dl_Ratio_Ok := Ok;
  End;

  Procedure Show_None_Marked;
  Begin
    EchoSE( ' /rYou Do Not Have Any Files Marked Yet!/b' );  CrLf;
  End;

  Procedure Batch_Mark_File;
  Var
    X : Long_Integer;
  Begin
    CrLf;
    X := ( Tot_DL_Time + DL_Time ) Div 60;
    If ( BM_Num = 0 ) Then Tot_DL_Time := 0;
    If ( X < TimeLeft ) Then Begin
      If ( BM_Num < 20 ) Then Begin
        CrLf;
        BM_Num := BM_Num + 1;
        BMark[BM_Num].BM_Fname  := File_Name;
        BMark[BM_Num].BM_Fsize  := Dta_Data.Size;
        BMark[BM_Num].BM_Sig    := Sig_Num;
        BMark[BM_Num].BM_D_Time := DL_Time;
        BMark[BM_Num].BM_CD_ROM := System2.CD_ROM[ Sig_Num ];
        Tot_DL_Time := Tot_DL_Time + DL_Time;
      End
      Else Begin
        CrLf;
        EchoSE( '/r Sorry, Maximum Files Is 20.../b' );
        Press_Any;
      End;
    End
    Else Begin
      CrLf;
      EchoSE( '/r Sorry, You Do Not Have Enough Time Left To Include This File.../b' );
      Press_Any;
    End;
  End;

  Procedure Batch_Mark;
  Var
    S :String;
    X : Integer;
  Begin
    CrLf;
    EchoS( 'Enter Filename To Mark -> ' );
    Caps := True;
    Line_In( S, 12 );
    If Filename_Ok( S ) = True Then Begin
       FPath := Concat( System2.Paths[ Sig_Num ], S );
      If Exists( FPath ) Then Begin
        MakeCstring( FPath, FName );
        Lines :=1;
        If Sfirst( FName, 0 ) = 0 Then Begin
          Get_DL_Time;
          File_Name := S;
          Batch_Mark_File;
        End;
      End
      Else Begin
        CrLf;  EchoS( S );  EchoSE( ' Does Not Exist...' );  CrLf;
      End;
    End
    Else Begin
      CrLf;  EchoSE( '/rIllegal Filename.../b' );  CrLf;
    End;
  End;

  Procedure Review_Marked_Files;
  Var
    Temp : String;
    I, T_Tot : Integer;
    F_Tot : Long_Integer;
  Begin
    I := 0;  F_Tot := 0;  T_Tot := 0;
    If BM_Num >0 Then Begin
      CrLf;  CrLf;
      EchoSE( ' No.   Filename      Size      D/L Time' );
      EchoSE( ' ----  ------------  --------  --------' );
      Repeat
        I := I + 1;
        Temp := BMark[I].BM_Fname;
        AddSpaces( Temp, 14 );
        Writev( Line, ' [/r', I:2, '/b]  ', Temp, BMark[I].BM_Fsize:8, '  ' );
        F_Tot := F_Tot + BMark[I].BM_FSize;
        T_Tot := T_Tot + BMark[I].BM_D_Time;
        Get_DL_Time_Str( BMark[I].BM_D_Time );
        Line := Concat( Line, DL_Time_Str );
        EchoSE( Line );
      Until I = BM_Num;
      EchoSE( ' ----  ------------  --------  --------' );
      EchoS( ' Totals              ' );
      Get_DL_Time_Str( T_Tot );
      Writev( Line, F_Tot:8, '  ', DL_Time_Str );
      EchoSE( Line );  CrLf;
    End
    Else Show_None_Marked;
  End;

  Procedure Clear_Batch;
  Begin
    BM_Num := 0; Tot_DL_Time := 0;
    EchoSE ( 'Batch List Now Cleared...' );
  End;

  Procedure Wipe_Marked;
  Var
    X, Y : Integer;
    Choice : Char;
  Begin
    If ( BM_Num > 0 ) Then Begin
      Review_Marked_Files;
      EchoSE( ' Enter Number Of File To Wipe :> ' );
      Choice := Get_Char;  Upper_C( Choice );
      If Choice In['1'..'9'] Then Begin
        Put_Char( Choice );
        X := Ord( Choice ) - 48;
        Y := 16;
        If BM_Num > ( X * 10 ) Then Begin
          Choice := Get_Char;
          If Choice In['0'..'9'] Then Begin
            Put_Char( Choice );
            If Ord( Choice ) <> 13 Then Begin
              Y := Ord( Choice ) - 48;
              If Y = 10 Then Y := 0;
            End;
          End;
        End;
        If ( X <= BM_Num ) And ( Y = 16 ) Then Y := X  Else Y := ( X * 10 ) + Y;
        CrLf;
        If Y <= BM_Num Then Begin
          If Y < BM_Num Then Begin
            Tot_DL_Time := Tot_DL_Time - BMark[Y].BM_D_Time;
            X := Y - 1;
            Y := BM_Num - 1;
            Repeat
              X := X + 1;
              BMark[X].BM_Fname := BMark[X+1].BM_FName;
              BMark[X].BM_Fsize := BMark[X+1].BM_Fsize;
              BMark[X].BM_Sig   := BMark[X+1].BM_Sig;
              BMark[X].BM_D_Time:= BMark[X+1].BM_D_Time;
              BMark[X].BM_CD_Rom:= BMark[X+1].BM_CD_Rom;
            Until X = Y;
            BM_Num := BM_Num - 1;
            CrLf;
            EchoSE( 'Done...' );
          End
          Else BM_Num := BM_Num - 1;
          Tot_DL_Time := Tot_DL_Time - BMark[Y].BM_D_Time;
        End;
        CrLf;
      End
      Else If ( Ord ( Choice ) = Cr ) Then EchoSE ( 'Aborted...' )
      Else Show_Wrong;
    End
    Else Show_None_Marked;
  End;

  Procedure Find_User_Addr;
  Var
    TT, T2, U, X : Long_Integer;
    S : String;
  Begin
    If ( FTU_Length = 99999 ) Then Begin
      Usr_Addr := 99999;
      UserRec.UHandle  := 'SysOp';
      UserRec.New_User := False;
      UserRec.Name     := 'Test Mode';
      UserRec.Computer_Type := 'ST';
      UserRec.Last_Call_Date := '04/04/96';
      UserRec.Age      := 99;
      UserRec.PWord    := '';
      UserRec.City     := 'San Diego';  UserRec.State := 'CA';
      UserRec.Phone_Number := '(555)555-1234';
      UserRec.Sec_Lvl  := -1;
      UserRec.Translation := 2;
      UserRec.Video_Width := 80;
    End
    Else Begin
      EchoCE( 'Checking Address of User in RAM...' );
      S := U_Handle;  Lower_S( S );
      UserRec.UHandle := U_Handle;
      TT := Proc_addr( Dummy_Routine );  T2 := TT - FTU_Length;
      U := Addr( UserRec );
      X := Search( FTU_Length, T2, S );
      If ( X > 0 ) Then Begin
        Usr_Addr := X - 2;
        Writev( Line, 'Address Of UserData Is $', Usr_Addr:8:h );
        EchoCE( Line );
        Get_Usr( U, Usr_Addr, SizeOf( UserRec ) );
        Writev( Line, 'OffSet For FTU.HLP Is ', TT-X, ' Bytes...' );
      EchoCE( Line );
      Pause( 600 );
      End
      Else Begin
        Usr_Addr := 65536;
        EchoCE( 'Offset For FTU.INF Needs To Be Increased...' );
      End;
    End;
  End;

  Procedure Get_MaskData( Num : Integer );
  Var
    H, I : Integer;
    X , Count : Long_Integer;
  Begin
    Count := ( SizeOf( UserAcs ) * ( Num - 1 ) );
    H  := FOpen( Ftu_MaskFile, 0 );
    If ( H < 0 ) Then Show_Error( Ftu_MaskFile, H )
    Else Begin
      X := Fseek( Count, H,  0 );
      If ( X < 0 ) Then Show_Error( Ftu_MaskFile, Int( X ) )
      Else Begin
        X := FRead_Usr2( H,  SizeOf( UserAcs ),  UserAcs );
        If ( X < 0 ) Then Show_Error( Ftu_MaskFile, Int( X ) );
      End;
    End;
    I := Close_File( H );
  End;

  Procedure Save_Ftu_User;
  Var
    H, X : Integer;
    S1, S2, L, Count : Long_Integer;
  Begin
    S1 := SizeOf( UserAcs );
    S2 := ( Usr_No - 1 );
    Count := S1 * S2;
    H  := FOpen( Ftu_UserFile, 0 );
    If ( H < 0 ) Then Show_Error( Ftu_UserFile, H )
    Else Begin
      L := Fseek( Count, H,  0 );
      If ( L < 0 ) Then Show_Error( Ftu_UserFile, Int( L ) )
      Else Begin
        L := FWrite_Usr2( H,  SizeOf( UserAcs ),  UserAcs );
        If ( L < 0 ) Then Show_Error( Ftu_UserFile, Int( L ) );
      End;
    End;
    X := Close_File( H );
  End;

  Function Get_Ftu_User: Boolean;
  Var
    H, I, U : Integer;
    Ok : Boolean;
    S1, S2, X, Count : Long_Integer;
  Begin
    EchoCE( 'Checking FTU_DATA.USR...' );
    Ok := False;
    S1 := SizeOf( UserAcs );  U := Usr_No;
    H  := FOpen( Ftu_UserFile, 0 );
    If ( H < 0 ) Then Show_Error( Ftu_UserFile, H )
    Else Begin
      X := Fseek( 0, H,  2 );
      If ( X < 0 ) Then Show_Error( Ftu_UserFile, Int( X ) )
      Else Begin
        I := ( X Div S1 );
        If ( UserRec.New_User ) Then U := I;
        S2 := ( U - 1 );  Count := S1 * S2;
        X := Fseek( Count, H,  0 );
        If ( X < 0 ) Then Show_Error( Ftu_UserFile, Int( X ) )
        Else Begin
          X := FRead_Usr2( H,  S1, UserAcs );
          If ( X < 0 ) Then Show_Error( Ftu_UserFile, Int( X ) )
          Else Ok := True;
        End;
      End;
    End;
    I := Close_File( H );
    Get_Ftu_User := Ok;
  End;

  Function Get_SysData : Boolean;
  Var
    H, X, I, J : Integer;
    Ch : Char;
    Ok : Boolean;
    Count : Long_Integer;
  Begin
    EchoCE( 'Checking FTU_DATA.SIG...' );
    Ok := False;
    If Exists( Ftu_SigFile ) Then Begin
      H := FOpen( Ftu_SigFile, 0 );
      If ( H < 0 ) Then Show_Error( Ftu_SigFile, H )
      Else Begin
        Count := Fseek( 0, H,  0 );
        If ( Count < 0 ) Then Show_Error( Ftu_SigFile, Int( Count ) )
        Else Begin
          Count := FRead_Sys2( H,  sizeof( system2 ),  System2 );
          If ( Count < 0 ) Then Show_Error( Ftu_SigFile, Int( Count ) )
          Else Begin
            Userfilename := System2.Userlog;
            Log_Filename := System2.Logfile;
            Line         := System2.XYZ_TTP;
            MakeCstring( Line, Xyz_Path );
            Ok := True;
          End;
        End;
      End;
      X := Close_File( H );
    End;
    If ( Ok = False ) Then Begin
      CrLf;
      EchoSE( '/b/RUnable To Open FTU_DATA.SIG file..../b/K' );
      EchoSE( 'Returning To The BBS.' );
      CrLf;
    End;
    Get_SysData := Ok;
  End;

  Procedure Show_SigOp_Stats;
  Begin
    If ( Sig_Edit ) Then Write_Six( 18,3,Blk,Redd, '-E' )
      Else Write_Six( 18,3,Blk,Redd, '  ' );
    If ( Sig_Name ) Then Write_Six( 20,3,Blk,Redd, '-N' )
      Else Write_Six( 18,3,Blk,Redd, '  ' );
    If ( Sig_Vald ) Then Write_Six( 22,3,Blk,Redd, '-V' )
      Else Write_Six( 20,3,Blk,Redd, '  ' );
    If ( Sig_Kill ) Then Write_Six( 24,3,Blk,Redd, '-K' )
      Else Write_Six( 22,3,Blk,Redd, '  ' );
  End;

  Procedure Show_Top5;
  Begin
    Clear5;
    Write_Six( 34,0,Blk,Wht, ' Cpu: ' );
    Write_Six( 56,0,Blk,Wht, 'Last Call: Jan 12, 1989 ' );
    Write_Six( 80,0,Blk,Wht, ' Ram:         User:' );
    Write_Six( 34,1,Blk,Wht, ' Age: ' );
    Write_Six( 56,1,Blk,Wht, 'Time Used: ' );
    Write_Six( 34,2,Blk,Wht, 'Chat: ' );
    Write_Six( 56,2,Blk,Wht, 'Upld:        Dnld: ' );
    Write_Six( 34,3,Blk,Wht, 'Baud: ' );
    Write_Six(  0,4,Blk,Wht, ' File:' );
    Write_Six( 80,4,Blk,Wht, '  10:12:12   Jan 22, 90 ' );
  End;

  Procedure Get_Free_Mem;
  Begin
    Sys_Mem := Malloc( TimeOut );
  End;

  Procedure Show_UInfo;
  Var
    X : Long_Integer;
    S : String;
  Begin
    S := UserRec.Name; AddSpaces( S,31 );
    Write_Six( 1,0,Blk,Redd,  S );
    S := UserRec.Computer_Type; AddSpaces( S,15 );
    Write_Six( 40,0,Blk,Redd, S );
    S := UserRec.Last_Call_Date;
    Convert_Date2( S );
    Y := Y - 1980;
    M := Shl( M, 5 );
    Y := Shl( Y, 9 );
    Usr_Lst_Call := Y + M + D;
    Write_Six( 67,0,Blk,Redd, S );
    Writev( S, Usr_No );
    Write_Six( 100,0,Blk,Wht, S );

    S := UserRec.UHandle; AddSpaces( S,31 );
    Write_Six( 1,1,Blk,Grn,   S );
    Writev( S, UserRec.Age );
    Write_Six( 40,1,Blk,Grn,  S );

    If ( UserRec.New_User ) Then S := 'New User'
    Else If ( UserRec.PWord = 'A Visitor' ) Then S := 'A Visitor'
    Else S := 'Validated';
    Write_Six( 44,1,Blk,Wht, S );

    Write_Six( 67,1,Blk,Redd, '0/0    ' );
    Write_Six( 77,1,Blk,Wht,  '180' );

    S := Concat( UserRec.City,', ', UserRec.State ); Addspaces( S, 24 );
    Write_Six( 1,2,Blk,Wht,   S );
    If ( Chat ) Then S := 'On ' Else S := 'Off';
    Write_Six( 40,2,Blk,Grn,  S );

    S := UserRec.Phone_Number; AddSpaces( S, 16 );
    Write_Six( 1,3,Blk,Wht,   S );
    Write_Six( 40,3,Blk,Redd, BaudRate );

    Show_Cur_Time;
    Show_Cur_Date;
    Show_Connected;
    Get_Free_Mem;
    WriteV( S, Sys_Mem );
    Write_Six( 86, 0, Blk, Grn, S );

    If ( Local ) Then S := 'Local'  Else S := 'Remote';
    Write_Six( 48,3,Blk,Redd, S );
    If ( Usr_No = 1 ) Then S := 'SysOp'
    Else If ( Sig_Op ) Then S := 'SigOp'
    Else S := 'User';
    Write_Six( 56,3,Blk,Grn, S );

    S := Concat( 'Video: ', Trans[ TransV ], ' - Width: ', Width );
    Write_Six( 64,3,Blk,Redd, S );

    S := Concat( 'BBS: ', BBS_Vers );
    Write_Six( 96,3,Blk,Grn, S );

    S := Concat( 'Protocol: ', XferT[ Protocol ] );
    Write_Six( 82,2,Blk,Grn, S );
  End;

  Procedure Write_Ftu_Out( Cnt : Integer );
  Var
    H, I : Integer;
    L : Long_Integer;
  Begin
    H := FCreate( Ftu_Out, 0 ); L := Fseek( 0, H, 2 );
    For I := 1 to Cnt Do Write_Ln( H, BachL[ I ] );
    I := Close_File( H );
    Cmd_Line := Concat ( Cmd_Line, ' -i', Ftu_Out );
  End;

  Function Exec_Xyz : Integer;
  Var
    H, I, X, CD : Integer;
    L : Long_Integer;
    C, E : CString;
    Temp, S, D : String;
  Begin
    Save5;
    Cmd_Line := Concat ( Cmd_Line,' -s -t -c -r50' );
    If ( Batch_Down ) Then Begin
      EchoCE( '    Sending Files:' );
      For I := 1 to BM_Num Do Begin
        Temp :=BMark[ I ].BM_Fname;
        X := BMark[ I ].BM_Sig;
        S := Concat( System2.Paths[ X ], Temp );
        D := Concat( System2.Upld_Pth, Temp );
        If ( BMark[ I ].BM_CD_ROM  = False ) Then BachL[ I ] := S
        Else Begin
          EchoSE( 'Copying ' );
          EchoSE( Temp );
          EchoSE( '  From CD-ROM to Hard Drive...' );
          Copy_File( S, D, 1 );  BachL[ I ] := D;
        End;
        EchoCE( S );
      End;
      Write_Ftu_Out( BM_Num );
    End;
    Cmd_Line := Concat( Cmd_Line, ' -o', Ftu_Xfr, Chr(0) );

    Temp := Concat( Xfer_Type, ' Ready, Start Transfer Now...' );
    CrLf;  EchoSE( Temp );
    For I := 1 To Length( Cmd_Line ) Do C[I] := Cmd_Line[I];

    C[0] := Chr( Length( Cmd_Line ) - 1 );
    For I := 0 to 27 Do E[I] := Chr( 0 );

    Clear_Local;  EchoCE( Cmd_Line );  CrLf;
    I := Exec( 0, Xyz_Path, C, E );
    Exec_Xyz := I;
    Rest5;
    Show_Top5;
    Show_UInfo;
    Show_DL_UL;
    Clear_Local;
    If ( I<>0 ) Then Show_Xyz_Error( I );
    CrLf;
    If ( Batch_Down ) Then Begin
      For I := 1 To BM_Num Do Begin
        Temp :=BMark[ I ].BM_Fname;
        D := Concat( System2.Upld_Pth, Temp );
        If ( Exists( D ) ) Then Begin
          MakeCString( D, C );
          H := UnLink( C );
        End;
      End;
    End;
    Batch_Down := False;  Batch_Upld := False;
  End;

  Procedure Make_F_Names;
  Var
    X : Integer;
    Ch : Char;
  Begin
    MakeFname( Dta_Data.Name, File_Name );
    F_Name := Concat( System2.Paths[Sig_Num], File_Name );
    MakeCstring( F_Name, F_Path );
    Desc_Path := Concat( System2.Desc_Path[ Sig_Num ], File_Name );
    Hide_Mode := False;
    X := Dta_Data.Attribute & 1;
    If ( X=0 ) Then Hide_Mode := True;
  End;

  Procedure Get_Sig_Access;
  Var
    A, X, X1, Sig : Integer;
    FSig_A, FSig_U : Long_Integer;
  Begin
    For A := 1 to 256 Do Sig_Access[ A ] := 0;
    Max_Sig := 0;
    For A := 0 to 7 Do Begin
      FSig_A := UserAcs.Sig_Accs [ A + 1 ];
      FSig_U := UserAcs.User_Mask[ A + 1 ];
      For X := 1 to 32 Do Begin
        X1 := X - 1;
        Sig  := ( A * 32 ) + X;
        Line := System2.Names[ Sig ];
        If ( Length( Line ) > 0 ) Then Begin
          If ( Bit_Test( FSig_U, X1 ) ) And ( Bit_Test( FSig_A, X1 ) ) Then Begin
            Sig_Access[ Sig ] := Sig;  Max_Sig := Sig;
          End;
        End;
      End;
    End;
  End;

  Procedure Show_Sigs;
  Var
    A,X,X1,I : Integer;
    S : String;
  Begin
    EchoSE( 'Show Sigs' );  Clear_Screen;  CrLf;
    EchoSE( 'File Sigs Available:' );  CrLf;
    X1 := 1;
    For X := 1 to 256 Do Begin
      A := Sig_Access [ X ];
      If ( A <> 0 ) Then Begin
        Writev( S, '[/r', X:3, '/b] ', System2.Names[ X ] );
        If WidT=80 Then Addspaces( S ,43 );
        If ( Odd( X1 ) And ( WidT=80 ) ) Then EchoS( S ) Else EchoSE( S );
        X1 := X1 + 1;
        If (( X1=23 ) And (WidT=40)) or (( X1=43 ) And ( WidT=80 )) Then Begin
          EchoS( '<More> ' );  If ( Yes_No( 'Y' ) = False ) Then X := 255
          Else Begin For I := 1 To 10 Do  Back_Space;  X1 := 1;  End;
        End;
      End;
    End;
    If ( Not Odd( X1 ) ) Then CrLf;  CrLf;
  End;

  Procedure Get_Sig_Nums;
  Var
    F : Long_Integer;
  Begin
    Sig_Num  := 0;
    If ( Sig_Cntr > 0 ) Then Sig_Num  := Sig_Access[ Sig_Cntr ];
    Sig_Edit := False;  Sig_Kill := False;
    Sig_Name := False;  Sig_Vald := False;
    Sig_Op   := False;
    If ( Sig_Num > 0 ) Then Begin
      Use_Desc  := System2.Use_Desc  [ Sig_Num ];
      Show_Free := System2.Show_Free [ Sig_Num ];
      F := UserRec.Sec_Lvl;
      If ( Bit_Cmp( F, System2.Slvl_Edit[ Sig_Num ] ) ) Then Sig_Edit := True;
      If ( Bit_Cmp( F, System2.Slvl_Kill[ Sig_Num ] ) ) Then Sig_Kill := True;
      If ( Bit_Cmp( F, System2.Slvl_Name[ Sig_Num ] ) ) Then Sig_Name := True;
      If ( Bit_Cmp( F, System2.Slvl_Vald[ Sig_Num ] ) ) Then Sig_Vald := True;
      If ( Sig_Edit ) or ( Sig_Kill ) or ( Sig_Name )
        or ( Sig_Vald ) Then Sig_Op := True;
    End;
    Show_SigOp_Stats;
{   WriteV( Line, 'Sig_Cntr=', Sig_Cntr, ' Max_Sig=', Max_Sig );  EchoSE( Line );
    WriteV( Line, 'Sig_Num =', Sig_Num , ' Tot_Sig=', Tot_Sig );  EchoSE( Line ); }
  End;

  Procedure Change_Prv_Sig;
  Var  S : Integer;
  Begin
    S := Sig_Cntr;
    Repeat
      Tot_Sig := False;
      If ( Sig_Cntr > 1 ) Then Begin
        Sig_Cntr := Sig_Cntr - 1;
        Get_Sig_Nums;
        If ( Sig_Num = 0 ) And ( Sig_Cntr = 1 ) Then Begin
          Sig_Cntr := S; Get_Sig_Nums;
        End;
      End;
    Until ( Sig_Num <> 0 ) or ( No_Carrier );
    Change_Drv_Path( System2.Paths[ Sig_Num ] );
    CrLf;
  End;

  Procedure Change_Nxt_Sig;
  Var  S : Integer;
  Begin
    S := Sig_Cntr;
    Repeat
      Tot_Sig := False;
      If ( Sig_Cntr < Max_Sig ) Then Begin
        Sig_Cntr := Sig_Cntr + 1;
        If ( Sig_Cntr = Max_Sig ) Then Tot_Sig := True;
      End;
      Get_Sig_Nums;
    Until ( Sig_Num <> 0 ) or ( Tot_Sig ) or ( Max_Sig = 0 ) or ( No_Carrier );
    If ( Tot_Sig ) And ( Max_Sig = 0 ) Then Begin
      Sig_Cntr := S; Get_Sig_Nums;
    End
    Else If ( Sig_Num > 0 ) Then Change_Drv_Path( System2.Paths[ Sig_Num ] );
    CrLf;
  End;

  Procedure Show_Exceeded_Limit;
  Begin
    CrLf;
    EchoSE( '/b/R You Have Exceeded Your Download Limit!/b/K' );
    CrLf;
  End;

  Procedure Show_DL_Stats;
  Var
    S : String;
    DL, UL, FT, BD, BU, PD, PU, KT, PT, DL_More, DL_Check : Long_Integer;
    RT : Integer;
  Begin
    DL := UserAcs.Downloads; UL := UserAcs.Uploads;  FT := UserAcs.DL_Ratio;
    BD := UserAcs.K_Dnld;    BU := UserAcs.K_Upld;   KT := UserAcs.K_Ratio;
    PD := UserAcs.Pts_Dnld;  PU := UserAcs.Pts_Upld; PT := UserAcs.Pts_Ratio;
    RT := UserAcs.Ratio_Typ;
    CrLf;  CrLf;  New_Line := False;
    Writev( S, '    Files Downloaded : /r', DL:8,'/b' ); Show_40( S );
    Writev( S, ' Files Uploaded   : /r', UL:8,'/b' );    Show_40( S );
    Writev( S, '    Bytes Downloaded : /r', BD:8,'/b' ); Show_40( S );
    Writev( S, ' Bytes Uploaded   : /r', BU:8,'/b' );    Show_40( S );
    Writev( S, '   Points Downloaded : /r', PD:8,'/b' ); Show_40( S );
    Writev( S, 'Points Uploaded   : /r', PU:8,'/b' );    Show_40( S );
    CrLf;
    Writev( S, '1)   /rUL/DL Ratio/b  : ', FT, ':1' );  EchoNE( S );
    Writev( S, '2)   /r  K   Ratio/b  : ', KT, ':1' );  EchoNE( S );
    Writev( S, '3)  /rPoints Ratio/b  : ', PT, ':1' );  EchoNE( S );
    Writev( S, 'Ratio Type ( 0 = Not Used ) : /r', RT, '/b' );  EchoNE( S );
    CrLf;  Line := '';
    If ( Rt = 0 ) Then Begin
      EchoNE( 'You Have An /rUnLimited/b Download Limit!!!' )
    End
    Else Begin
      If ( Rt = 3 ) Then Begin
        DL_Check := ( PU * PT ); DL_More := ( DL_Check - PD ); S := ' Points';
      End
      Else If ( Rt = 2 ) Then Begin
        DL_Check := ( BU * KT ); DL_More := ( DL_Check - BD ); S := ' k';
      End
      Else If ( Rt = 1 ) Then Begin
        DL_Check := ( UL * FT ); DL_More := ( DL_Check - DL ); S := ' Files';
      End;
      If ( DL_More < 1 ) Then Show_Exceeded_Limit
      Else Begin
        Writev( Line, ' You Have ( /r', DL_More, '/b )', S,' Left For Downloading...' );
        EchoNE( Line );
      End;
    End;
    CrLf;
  End;

  Procedure Time_Toggle;
  Begin
    CrLf;
    If ( Shw_Time ) Then Shw_Time := False  Else Shw_Time := True;
  End;

  Procedure Page_SysOp;
  Var
    I, X : Integer;
    Done : Boolean;
  Begin
    Write_Six( 45,2,Redd,Wht, '<<Paged>>' );
    I := 0; Done := False;
    If ( Chat ) Then Begin
      CrLf; EchoS( 'Paging SysOp ' );
      Repeat
        I := I + 1; EchoS( '*' ); Bell( 30 );
        If ( Con_In ) Then Begin
          X := Get_Console;
          Done := True;
        End;
      Until ( Done ) or ( I=25 ) or ( No_Carrier );
    End;
    If ( I = 25 ) or ( Chat = False ) Then Begin
      CrLf; CrLf; EchoSE( 'Sorry, The SysOp Isn''t Around Right Now.' );
      CrLf;
    End;
  End;

{$I Arc_List.Pas}
{$I ArJ_List.Pas}
{$I Lzh_List.Pas}
{$I Sit_List.Pas}
{$I Zip_List.Pas}
{$I Zoo_List.Pas}

  Function FRead_Dsc( H:Integer; Count:Long_Integer; Var S:BlockIO ):Long_Integer;
  Gemdos( $3F ); 

  Procedure Get_Description( Cnt : Integer );
  Var
    H, X : Integer;
  Begin
    For X := 1 to Cnt Do MesgL[X] := '';  Msg_Ln := 0;
    If ( Use_Desc ) Then Begin
      Show_File( Desc_Path );
      If Exists( Desc_Path ) Then Begin
        H := FOpen( Desc_Path, 0 );
        If ( H < 0 ) Then Show_Error( Desc_Path, H )
        Else Msg_Ln := Read_Ln( H, Cnt );
        X := Close_File( H );
      End;
    End;
    If ( Cnt < 60 ) Then Begin
      If ( Msg_Ln = 0 ) Then Begin
        MesgL[4] := 'No Description';
        Msg_Ln := 4;
      End;
      If ( MesgL[1] ='' ) Then MesgL[1] := 'SysOp';
      If ( MesgL[2] ='' ) Then MesgL[2] := '0';
      If ( MesgL[3] ='' ) Then MesgL[3] := 'Not Tested...';
    End;
  End;

  Function Get_FTU_XFR : Integer;
  Var
    H, I, X : Integer;
  Begin
    I := 0;  Msg_Ln := 0;
    For X := 1 To 20 Do MesgL[X] := ''; Show_File( Ftu_Xfr );
    If Exists( Ftu_Xfr ) Then Begin
      H := FOpen( Ftu_Xfr, 0 );
      If ( H < 0 ) Then Show_Error( Ftu_Xfr, H )
      Else Msg_Ln := Read_Ln( H, 20 );
      X := Close_File( H );
    End;
    If ( Msg_Ln > 0 ) Then Begin
      For X := 1 to 20 Do  If ( MesgL[X] <> '' ) Then I := I + 1;
    End;
    Get_Ftu_Xfr := I;
  End;

  Procedure Read_File;
  Var
    TBytes : Long_Integer;
    KyCnt, H, X, I, RC, W : Integer;
    EOF : Boolean;
    F : CString;
    S : String;
  Begin
    EOF := False;  Abort := False;  S := '';  KyCnt := 0;  W := WidT - 1;
    Show_File( F_Name );  MakeCString( F_Name, F );
    H := Open_File( F, Input_Mode );
    If ( H < 0 ) Then EOF := True
    Else Repeat
      Tbytes := BlockRead( H, Block_Size, BlkIO );
      If ( Tbytes > 0 ) and ( Abort = False ) Then Begin
        For I := 1 to Tbytes Do Begin
          X := Blkio[I];
          If ( X > 24 ) Then Begin
            KyCnt := KyCnt + 1;
            If ( KyCnt = W ) Then Begin
              CrLf;  KyCnt := 0;
            End
            Else EchoS( Chr( X ) );
            If ( Abort ) Then I := Tbytes;
          End
          Else If ( X=9 ) Then Begin
            X := 8 - ( KyCnt - ( ( KyCnt Div 8 ) * 8 ) );
            For RC := 1 to X Do Put_Char( ' ' );
          End
          Else If ( X=Cr ) or ( X=155 ) Then Begin CrLf;  KyCnt := 0; End;
        End;
      End
      Else EOF := True;
    Until ( EOF ) or ( Abort ) or ( No_Carrier );
    RC := Close_File( H );
    Abort := False;
    Press_Any;
  End;

  Procedure View_Menu( F:String );
  Var
    H, X : Integer;
    S : String;
  Begin
    F_Name := Concat( FTU_Menu, F );
    Show_File( F_Name );
    If Exists( F_Name ) Then Begin
      H := FOpen( F_Name, 0 );
      If ( H < 0 ) Then Show_Error( F_Name, H )
      Else Msg_Ln := Read_Ln( H, 88 );
      X := Close_File( H );
      If ( Msg_Ln > 0 ) Then Begin
        For X := 1 To Msg_Ln Do EchoSE( MesgL[ X ] );
      End;
    End;
  End;

{$I Msg_Edit.Pas }

  Procedure Edit_Uploader;
  Var
    S : String;
  Begin
    CrLf;
    EchoS( 'Enter New Name -> ' );
    Caps := False;
    Line_In( S, 22 );
    MesgL[1] := S;
  End;

  Procedure Edit_DL_Count;
  Var
    S : String;
  Begin
    CrLf;
    EchoS( 'Enter New D/L Count -> ' );
    Caps := False;
    Line_In( S, 6 );
    MesgL[2] := S;
  End;

  Procedure Edit_Rating;
  Var
    Done : Boolean;
    Choice : Char;
    S : String[20];
  Begin
    Done := False;
    CrLf;
    EchoSE( 'Rating Selections' );
    CrLf;
    EchoS( '[/r1/b] ' );  EchoSE( Rating[1] );
    EchoS( '[/r2/b] ' );  EchoSE( Rating[2] );
    EchoS( '[/r3/b] ' );  EchoSE( Rating[3] );
    EchoS( '[/r4/b] ' );  EchoSE( Rating[4] );
    EchoS( '[/r5/b] ' );  EchoSE( Rating[5] );
    EchoS( '[/r6/b] ' );  EchoSE( Rating[6] );
    CrLf;
    EchoS( 'Enter Rating Of This File -> ' );
    Repeat
      Choice := Get_Char;
      If Choice In['1'..'6'] Then Begin
        S := Rating[Ord( Choice ) - 48];
        MesgL[3] := S;
        EchoSE( S );
        Done := True;
      End;
    Until ( Done ) or ( No_Carrier );
  End;

  Procedure Edit_Descript2( Z : Integer );
  Begin
    Temp := Concat( 'Current File -> ', File_Name );  EchoSE( Temp );
    Desc_Path := Concat( System2.Desc_Path[ Z ], File_Name );
    MesgL[1] := UserRec.UHandle;
    MesgL[2] := '0';
    If ( Carrier ) Then Edit_Rating  Else MesgL[3] := 'Dropped Carrier!';
    Msg_Ln := 3;
    If ( Carrier ) Then Begin
      CrLf;
      Temp := Concat( 'Please Enter A Description Of ', File_Name );
      EchoSE( Temp );
      CrLf;
      Clear_Screen;
      Edit_Description( 0 );
    End
    Else Save_Description;
  End;

  Function Delete_File( Var S:String ) : Integer;
  Var
    X : Integer;
    C : CString;
  Begin
    CrLf;
    EchoS( '/r Kill/b, Are You Sure? ' );
    If ( Yes_No('N') )Then Begin
      CrLf;
      MakeCString( S,C );  X := UnLink( C );
      If X >= 0 Then EchoSE( ' File Is Now /rErased/b From Drive...' )
      Else Show_Error( S, X );
    End
    Else EchoSE( ' Aborted...' );
    Delete_File := X;
  End;

  Procedure Kill_File;
  Var
    X : Integer;
  Begin
    If Exists( Desc_Path ) Then X := Delete_File( Desc_Path );
    X := Delete_File( F_Name );
    If ( X >= 0 ) Then Begin
      If ( FMax > 0 ) Then Begin
        FMax := FMax - 1;  FCnt := FCnt - 1;
      End;
      If ( Kywrd_Cnt > 0 ) Then Begin
        Kywrd_Cnt := Kywrd_Cnt - 1;  FCur := FCur - 1;
      End;
    End;
  End;

  Procedure Hide_File;
  Var
    X : Integer;
  Begin
    X := ChMode( F_Path, 1, 1 );
    If ( X < 0 ) Then Show_Error( F_Name, X )
    Else Hide_Mode := False;
  End;

  Procedure Valid_File;
  Var
    X : Integer;
  Begin
    X := ChMode( F_Path, 1, 0 );
    If ( X < 0 ) Then Show_Error( F_Name, X )
    Else Begin
      DT_Stamp( F_Name );
      Hide_Mode := True;
    End;
  End;

  Procedure Rename_A_File( Var In_File, Out_File :String );
  Var
    X : Long_Integer;
    OldN, NewN : Cstring;
  Begin
    CrLf;
    MakeCstring( In_File, OldN );
    MakeCstring( Out_File, NewN );
    X := Rename( 0, OldN, NewN );
    Dummy_I := Int(X);
    Show_Error( In_File, Dummy_I );
  End;

  Procedure Rename_File;
  Var
    I : Integer;
    Temp, Old_N, New_N : String;
  Begin
    CrLf;
    EchoS( ' Enter NEW Name Of File -> ' );
    Caps := False;
    Line_In( Temp, 12 );
    If ( Length(Temp) > 0 ) Then Begin
      Old_N := Concat( System2.Paths[Sig_Num], File_Name );
      New_N := Concat( System2.Paths[Sig_Num], Temp );
      Rename_A_File( Old_N, New_N );
      If ( Use_Desc ) Then Begin
        Old_N := Concat( System2.Desc_Path[Sig_Num], File_Name );
        New_N := Concat( System2.Desc_Path[Sig_Num], Temp );
        Rename_A_File( Old_N, New_N );
      End;
      For I := 1 To Length( Temp ) Do  DTA_Data.Name[ I ] := Temp[ I ];
      DTA_Data.Name[ I+1 ] := Chr(0);
      Make_F_Names;
      Show_File( F_Name );
    End
    Else EchoSE( 'Aborted...' );
  End;

  Function Ask_LogOff:Boolean;
  Begin
    Ask_LogOff := False;
    CrLf;
    EchoS( 'Log Off After Tranfer? ' );
    If  ( Yes_No( 'N' ) ) Then Ask_LogOff := True;
    CrLf;
  End;

  Procedure Update_DL_Status;
  Var
    X : Integer;
    S : String[6];
  Begin
    If ( Use_Desc ) Then Begin
      Get_Description( 20 );
      Readv( MesgL[2], X );
      X := X + 1;
      Writev( S, X );
      MesgL[2] := S;
      Save_Description;
    End;
  End;

  Procedure Show_Batch_Status( Cnt:Integer );
  Var
    I, X : Integer;
    L : Long_Integer;
    Temp, F : String;
  Begin
    If ( System2.Free_Dnld[ Sig_Num ] = False ) Then
      UserAcs.Downloads := UserAcs.Downloads + Cnt;
    Show_DL_UL;
    DescL[1] := Concat( 'Completed ', Xfer_Type, ' Download Of :' );
    Log( 0, 1 );
    For I := 1 to Cnt Do Begin
      F := BMark[ I ].BM_Fname;   X := BMark[ I ].BM_Sig;
      L := ( ( BMark[ I ].BM_FSize + 1023 ) Div 1024 );
      UserAcs.K_Upld := UserAcs.K_Upld + L;
      L := L * System2.Pts_K;
      UserAcs.Pts_Upld := UserAcs.Pts_Upld + L;
      Temp := System2.Paths[ X ];
      DescL[1] := Concat( Temp, F );
      Desc_Path := Concat( System2.Desc_Path[ X ], F );
      Log( 0, 1 );  Update_DL_Status;
    End;
    If ( Cnt < BM_Num ) Then Begin
      For I := 1 To Cnt Do Begin
        X := Cnt + I;
        BMark[I].BM_Fname := BMark[X].BM_FName;
        BMark[I].BM_Fsize := BMark[X].BM_Fsize;
        BMark[I].BM_Sig   := BMark[X].BM_Sig;
        BMark[I].BM_D_Time:= BMark[X].BM_D_Time;
        BMark[I].BM_CD_ROM:= BMark[X].BM_CD_ROM;
      End;
    End;
    Bm_Num := BM_Num - Cnt;
  End;

  Procedure Batch_Send;
  Var
    Ch : Char;
    Lgff : Boolean;
    L, L1 : Long_Integer;
    K,X,I,Cnt : Integer;
  Begin
    If ( BM_Num > 0 ) Then Begin
      X := 0;  L := 0;
      For I := 1 to BM_Num Do
        L := L + ( ( BMark[ I ].BM_FSize + 1023 ) Div 1024 );
      L1 := ( L * System2.Pts_K );
      If ( Dl_Ratio_Ok( BM_Num, L, L1 ) ) Then Begin
        L := 59;
        For I := 1 to BM_Num Do  L := L + BMark[ I ].BM_D_Time;
        L := L Div 60;
        CrLf;
        WriteV( Line, 'Time Required : ', L:3, ' Mins' );  EchoSE( Line );
        WriteV( Line, 'Time Remaining: ', TimeLeft:3, ' Mins' );  EchoSE( Line );
        CrLf;
        If ( L <= TimeLeft ) Then Begin
          EchoS( ' [/rY/b]Modem,  [/rZ/b]Modem  [/gA/b]bort >' );
          Return := 16;  Lgff := False;
          Repeat
            Ch := Get_Char;  Upper_C( Ch );  K := Ord( Ch );
          Until ( Ch In [ 'A','Y','Z' ] ) or ( No_Carrier ) or ( K = Cr );
          If ( K = Cr ) Then Ch := 'A';
          If ( Carrier ) And ( Ch <> 'A' ) Then Begin
            Case Ch of
              'Y' : Begin
                      Cmd_Line := '-u -y';  Xfer_Type := 'Ymodem Batch';
                    End;
              'Z' : Begin
                      Cmd_Line := '-u -z';  Xfer_Type := 'Zmodem Batch';
                    End;
            End; { Case }
            EchoSE( Xfer_Type );
            If ( Ask_LogOff ) Then Lgff := True;
            Batch_Down := True;  Cnt := 0;
            Return := Exec_Xyz;
            If ( Return = 0 ) Then Begin
              Cnt := BM_Num;  Show_Batch_Status( Cnt );
            End
            Else Begin
              Cnt := Get_Ftu_Xfr;
              Writev( DescL[1], 'Files Transfered = ', Cnt );  Log( 0, 1 );
              If ( Cnt > 0 ) Then Show_Batch_Status( Cnt );
              If ( BM_Num > 0 ) Then Begin
                DescL[1] := Concat( 'Aborted ', Xfer_Type, ' Download Of :' );
                Log( 0, 1 );
                For I := 1 to BM_Num Do Begin
                  X := BMark[ I ].BM_Sig;
                  Temp := Concat( System2.Paths[ X ], BMark[ I ].BM_Fname );
                  DescL[1] := Temp;
                  Log( 0, 1 );
                End;
              End;
            End;
            If ( Lgff ) Then Do_LogOFF;
          End
          Else If ( K=Cr ) Then EchoSE( 'Aborted...' );
        End
        Else Begin
          EchoSE( 'The Time Required To Download These Files Exceeds The Time Limit' );
          EchoSE( 'You Have Remaining On This Call...' );
          CrLf;
        End;
      End
      Else Begin
        CrLf;
        EchoNE( '/rDownload - Upload Ratio UnBallanced!!!/b' );
        EchoNE( 'You Must Remove 1 or More Files From Batch List To Proceede...' );
        CrLf;
      End;
    End
    Else Show_None_Marked;
  End;

  Procedure DownLoad_File( Var F : String; Md:Integer );
  Var
    Ch, C2 : Char;
    S, D : String;
    Lgff : Boolean;
    K, X : Integer;
    L : Long_Integer;
  Begin
    File_Name := F;  Lgff := False;  D := F;
    If ( DL_Ratio_Ok( 1,0,0 ) ) or ( Md = 1 ) Then Begin
      CrLf;  EchoSE( ' Download Protocols Available:' );  CrLf;
      EchoS ( '[/rX/b]Modem  Xmodem [/rC/b]rc  XModem 1[/rK/b]  [/rY/b]Modem' );
      EchoSE( '  YModem-[/rG/b]  [/rZ/b]Modem  [/rA/b]bort' );
      EchoS ( '  Choice (/g' ); EchoS( Prots[ Protocol ] ); EchoS( '/b) :> ' );
      Repeat
        Ch := Get_Char;  Upper_C( Ch );  K := Ord( Ch );
      Until ( Ch In[ 'A','C','G','K','X','Y','Z' ] )
        Or ( No_Carrier ) or ( K = Cr ); CrLf;
      If ( K = Cr ) Then Ch := Prots[ Protocol ];
      If ( Carrier ) And ( Ch <> 'A' ) Then Begin
        Case Ch of
          'X' : Begin
                  Protocol := 0;
                  Cmd_Line := '-u -xc';  Xfer_Type := 'Xmodem';
                End;
          'C' : Begin
                  Protocol := 1;
                  Cmd_Line := '-u -x';   Xfer_Type := 'Xmodem Crc';
                End;
          'K' : Begin
                  Protocol := 2;
                  Cmd_Line := '-u -x1k'; Xfer_Type := 'Xmodem 1k';
                End;
          'Y' : Begin
                  Protocol := 3;
                  Cmd_Line := '-u -y';   Xfer_Type := 'Ymodem';
                End;
          'G' : Begin
                  Protocol := 5;
                  Cmd_Line := '-u -yg';  Xfer_Type := 'Ymodem-G';
                End;
          'Z' : Begin
                  Protocol := 4;
                  Cmd_Line := '-u -z';  Xfer_Type := 'Zmodem';
                End;
        End; { Case }
        EchoSE( Xfer_Type );
        If ( Ask_LogOff ) Then Lgff := True;
        If ( System2.CD_ROM[ Sig_Num ] ) And ( Md = 0 ) Then Begin
          S := Concat( System2.Paths[ Sig_Num ], F );
          D := Concat( System2.Upld_Pth, F );
          CrLf;  EchoSE( 'Copying File From CD-ROM to Hard Drive...' );
          Copy_File( S, D, 1 );
        End;
        Cmd_Line := Concat( Cmd_Line, ' ', D );
        Return := Exec_Xyz;
        If ( Return = 0 ) Then Begin
          If ( System2.Free_Dnld[ Sig_Num ] = False ) Then
            UserAcs.Downloads := UserAcs.Downloads + 1;
          Show_DL_UL;
          L := ( ( DTA_Data.Size + 1023 ) Div 1024 );
          UserAcs.K_Dnld := UserAcs.K_Dnld + L;
          L := L * System2.Pts_K;
          UserAcs.Pts_Dnld := UserAcs.Pts_Dnld + L;
          If ( Md <> 10 ) Then Update_DL_Status;
          DescL[1] := Concat( 'Completed ', Xfer_Type, ' Download Of : ', File_Name );
        End
        Else If ( Return < 0 ) Then Begin
          DescL[1] := Concat( 'Aborted ', Xfer_Type, ' Download Of : ', File_Name );
          EchoSE( 'Aborted...' );
        End;
        Log( 0, 1 );
        If ( Lgff ) Then Do_LogOFF;
      End
      Else EchoSE( 'Aborted...' );
    End
    Else Show_Exceeded_Limit;
  End;

  Procedure Download_A_File;
  Var
    F : String;
  Begin
    CrLf;
    If ( DL_Ratio_Ok( 1,0,0 ) ) Then Begin
      EchoS( ' Enter Filename -> ' );
      Caps := True;  Line_In( F, 12 );
      If ( Filename_Ok( F ) ) Then Begin
        File_Name := F;
        If Exists( F ) Then Download_File( F,0 )
        Else EchoSE( ' Sorry, That File Doesn''t Exist!!!' );
      End
      Else EchoSE( '/r Illegal Filename.../b' );  CrLf;
    End
    Else Show_Exceeded_Limit;
  End;

  Function Chk_Dupe( F : String ) : Boolean;
  Var
    Ok : Boolean;
    C, I : Integer;
  Begin
    Ok := False;  CrLf;  CrLf;
    EchoSE( 'Checking For Duplicate File... ' );
    I := 1;  C := 1;
    Repeat
      If ( System2.Names[ I ] <> '' ) Then Begin
        Put_Char( Clk[ C ] );
        Change_Drv_Path( System2.Paths[ I ] );
        If ( Exists ( F ) ) Then Ok := True;
        C := C + 1;  If ( C = 5 ) Then C := 1;  Back_Space;
      End;
      I := I + 1;
    Until ( I = 257 );
    Chk_Dupe := Ok;  CrLf;  CrLf;
  End;

  Procedure Batch_Upload( Ch : Char );
  Var
    T, I, X, Z : Integer;
    L : Long_Integer;
    S, D, U : String;
    C : CString;
  Begin
    Batch_Upld := True;  T := FMax; U := System2.Upld_Pth; Z := Sig_Num;
    If ( System2.Sig1 ) Then Z := 1;
    Case Ch of
      'Y' : Begin
              Protocol := 3;
              Cmd_Line := '-d -y';  Xfer_Type := 'Ymodem';
            End;
      'Z' : Begin
              Protocol := 4;
              Cmd_Line := '-d -z';  Xfer_Type := 'Zmodem';
            End;
    End; { Case }
    EchoSE( Xfer_Type );
    Change_Drv_Path( U );
    Cmd_Line := Concat( Cmd_Line, ' ', System2.Upld_Pth );
    Return := Exec_Xyz;
    FPath := Concat( U, '*.*' );
    Max_File;
    If ( FMax > 0 ) Then Begin
      DescL[1] := Concat( 'Completed ', Xfer_Type, ' Upload Of : ' );
      Log( 0, 1 );
      FCnt := 0;
      For I := 1 To FMax Do Begin
        X := F_Search( 1 );
        MakeFname( Dta_Data.Name, File_Name );
        DescL[1] := Concat( '      ', File_Name );
        Log( 0, 1 );
        F_Name := Concat( System2.Paths[ Z ], File_Name );
        MakeCstring( F_Name, F_Path );
        D := F_Name;  S := Concat( U, File_Name );
        If ( Exists( D ) = False ) Then Begin
          L := ( ( DTA_Data.Size + 1023 ) Div 1024 );
          UserAcs.K_Upld := UserAcs.K_Upld + L;
          L := L * System2.Pts_K;
          UserAcs.Pts_Upld := UserAcs.Pts_Upld + L;
          UserAcs.Uploads  := UserAcs.Uploads + 1;
          Show_DL_UL;
          Copy_File( S, D, 0 );
          Hide_File;
          If ( Use_Desc ) Then Edit_Descript2( Z );
        End
        Else Begin
          CrLf;  EchoS( ' Alert! -> ' );  EchoS( File_Name );
          EchoSE( ' <- Already Exists...  Upload Credit Withdrawn...' );
          CrLf;
        End;
        MakeCstring( S, C );
        X := UnLink( C );
      End;
      FMax := T;
    End
    Else If ( FMax <= 0 ) Then Begin
      DescL[1] := Concat( 'Aborted ', Xfer_Type, ' Upload : ' );
      EchoSE( 'Aborted...' );
      Log( 0, 1 );
    End;
    Change_Drv_Path( System2.Paths[Sig_Num] );
  End;

  Procedure Upload_A_File;
  Var
    K, X  : Integer;
    L : Long_Integer;
    Ch, C2 : Char;
    C  : CString;
    F,U  : String;
    Abort : Boolean;
  Begin
    CrLf;
    If ( Show_Free ) Then Show_DFree( '.' );
    CrLf;  EchoSE( ' Upload Protocols Available:' );  CrLf;
    EchoS ( '[/rX/b]Modem  [/rC/b]rc XModem  1[/rK/b] XModem  [/rY/b]Modem' );
    EchoSE( '  [/rZ/b]Modem  [/rA/b]bort ' );
    EchoS ( '  Choice (/g' );
    C2 := Prots[ Protocol ];  If ( C2 = 'G' ) Then C2 := 'Y';
    Put_Char( C2 );  EchoS( '/b) :> ' );
    Repeat
      Ch := Get_Char;  Upper_C( Ch );  K := Ord( Ch );
    Until ( Ch In['A','C','K','X','Y','Z'] ) Or ( No_Carrier ) or ( K=Cr );
    If ( K = Cr ) Then Ch := C2;
    If ( Carrier ) And ( Ch <> 'A' ) Then Begin
      CrLf;  CrLf;  Abort := False;
      If ( Ch <> 'Y' ) And ( Ch <> 'Z' ) Then Begin
        EchoS( ' Enter Filename -> ' );
        Caps := True;  Line_In( F, 12 );
        If ( Filename_Ok( F ) ) Then Begin
          If ( Chk_Dupe( F ) ) Then Begin
            EchoSE( 'That File Already Exists...' );
            Abort := True;
          End;
        End
        Else Begin
          Abort := True;
          EchoSE( ' /rIllegal Filename.../b' ); CrLf;
        End;
        If ( Abort = False ) Then Begin
          CrLf; CrLf;
          File_Name := F;
          Case Ch of
            'X' : Begin
                    Protocol := 0;
                    Cmd_Line := '-d -xc';  Xfer_Type := 'Xmodem';
                  End;
            'C' : Begin
                    Protocol := 1;
                    Cmd_Line := '-d -x';   Xfer_Type := 'Xmodem Crc';
                  End;
            'K' : Begin
                    Protocol := 2;
                    Cmd_Line := '-d -x1k'; Xfer_Type := 'Xmodem 1k';
                  End;
          End; { Case }
          EchoSE( Xfer_Type );
          U := System2.Upld_Pth;  Change_Drv_Path( U );
          Cmd_Line := Concat( Cmd_Line, ' ', F );
          Return := Exec_Xyz;
          If ( Return = 0 ) Then Begin
            X := F_Search( 1 );
            L := ( ( DTA_Data.Size + 1023 ) Div 1024 );
            UserAcs.K_Upld := UserAcs.K_Upld + L;
            L := L * System2.Pts_K;
            UserAcs.Pts_Upld := UserAcs.Pts_Upld + L;
            F := Concat( U, File_Name );
            UserAcs.Uploads := UserAcs.Uploads + 1;
            Show_DL_UL;
            If ( System2.Sig1 ) Then U := System2.Paths[ 1 ]
              Else U := System2.Paths[ Sig_Num ];
            F_Name := Concat( U, File_Name );
            MakeCstring( F_Name, F_Path );
            Copy_File( F, F_Name, 0 );
            DT_Stamp( F_Name );
            Hide_File;
            If ( Use_Desc ) Then Edit_Descript2( Sig_Num );
            MakeCstring( F, C );
            K := UnLink( C );
            DescL[1] := Concat( 'Completed ', Xfer_Type, ' Upload Of : ', File_Name );
          End
          Else If ( Return < 0 ) Then Begin
            DescL[1] := Concat( 'Aborted ', Xfer_Type, ' Upload Of : ', File_Name );
            EchoSE( 'Aborted...' );
          End;
          Log( 0, 1 );
        End;
        If ( System2.Sig1 ) Then Change_Drv_Path( System2.Paths[Sig_Num] );
      End
      Else Batch_Upload( Ch );
    End
    Else EchoSE( 'Aborted...' );
  End;

  Procedure Clr_Kywrd_File;
  Var
    I : Integer;
  Begin
    For I := 1 To 256 Do Kywrd_File[ I ] := 0;
    Kywrd_Cnt := 0;  FCur := 0;
  End;

  Procedure Add_Kywrd_File;
  Var
    I, X : Integer;
  Begin
    X := 0;
    For I := 1 To 256 Do If ( Kywrd_File[ I ] = FCnt ) Then X := 1;
    If ( X = 0 ) Then Begin
      Kywrd_Cnt := Kywrd_Cnt + 1;  FCur := FCur + 1;
      If ( Kywrd_Cnt <= 256 ) Then Kywrd_File[ Kywrd_Cnt ] := FCnt;
    End
    Else If ( Kywrd_Cnt > FCur ) Then FCur := FCur + 1;
  End;

  Procedure Show_List_Opt;
  Begin
    If ( Not UserAcs.XpertUser ) Then Begin
      CrLf;
      EchoS( '[/rA/b]gain  </rX/b>pert [/rJ/b]ump  [/rM/b]ark  ' );
      If Arc_File Then Begin
        Line := Concat( '[/rU/b]n', Arc_Type[ArcT], ' ' );
        EchoS( Line );
        End;
      If Arc_File = False Then EchoS( '[/rR/b]ead  ' );
      EchoS ( '[/rQ/b]uit  [/rD/b]ownload  ' );
      If ( FCnt > 1 ) Then EchoS ( '[/rL/b]ast  ' );
      EchoSE( '[/r?/b]Help' );
      If ( Sig_Op ) Then Begin
        EchoS( '/r/BSigOp :>/K/b ' );
        If ( Sig_Kill ) Then EchoS( '[/rK/b]ill  ' );
        If ( Sig_Vald ) Then Begin
          If ( Hide_Mode ) Then EchoS( '[/rH/b]ide ' )
          Else EchoS( '[/rV/b]alid' );
        End;
        If ( Sig_Edit ) Then EchoS ( ' [/rE/b]dit ' );
        If ( Sig_Name ) Then EchoS ( ' [/rN/b]ame  Co[/rp/b]y  M[/ro/b]ve ' );
        If ( Sig_Name ) Then EchoSE( ' [/rF/b]ree  [/rT/b]ouch ' );
      End;
    End;  
    CrLf;
    If ( Shw_Time ) Then Begin Show_TimeLeft; EchoS( Line ); End;
    EchoS( 'File Cmnd:> ' );
  End;  

  Procedure Show_File_Help;
  Begin
    Clear_Screen;
    View_Menu( 'SIG.MNU' );
    Show_List_Opt;
  End;

  Procedure Show_Scan_Text;
  Var
    FF, Temp : String;
  Begin
    Fn_Convert( File_Name, FF );  AddSpaces( FF, 14 );
    Writev( Temp, Lines:2, '  ', FF );         { 18 }
    Writev( Line, Dta_Data.Size:7, '  ' );
    Temp := Concat( Temp, Line );              { 27 }
    Convert_Date( Dta_Data.Date );
    AddSpaces( Line, 14 );
    Temp := Concat( Temp, Line );              { 41 }
    Line := MesgL[4];
    If ( Ord( Line[0] ) >37 ) Then Line[0] := Chr( 38 );
    Temp := Concat( Temp, Line );
    EchoSE( Temp );
  End;

  Procedure Test_Arc_File;
  Begin
    Arc_File := False;
    If Pos( '.ARC', File_Name ) >1 Then Begin ArcT:= 1;Arc_File := True; End;
    If Pos( '.ARK', File_Name ) >1 Then Begin ArcT:= 1;Arc_File := True; End;
    If Pos( '.ARJ', File_Name ) >1 Then Begin ArcT:= 2;Arc_File := True; End;
    If Pos( '.LHA', File_Name ) >1 Then Begin ArcT:= 3;Arc_File := True; End;
    If Pos( '.LZH', File_Name ) >1 Then Begin ArcT:= 3;Arc_File := True; End;
    If Pos( '.SIT', File_Name ) >1 Then Begin ArcT:= 4;Arc_File := True; End;
    If Pos( '.ZIP', File_Name ) >1 Then Begin ArcT:= 5;Arc_File := True; End;
    If Pos( '.ZOO', File_Name ) >1 Then Begin ArcT:= 6;Arc_File := True; End;
  End;

  Procedure View_Arc_File;
  Begin
    Show_File( F_Name );
    If ArcT = 1 Then List_Arc( F_Name )
    Else If ArcT = 2 Then List_Arj( F_Name )
    Else If ArcT = 3 Then List_Lzh( F_Name )
    Else If ArcT = 4 Then List_Sit( F_Name )
    Else If ArcT = 5 Then List_Zip( F_Name )
    Else If ArcT = 6 Then List_Zoo( F_Name );
    Press_Any;
  End;

  Procedure Show_List_Text;
  Var
    Temp : String;
    X : Long_Integer;
  Begin
    Clear_Screen;
    CrLf;
    New_Line := False;
    Test_Arc_File;

    Temp := Concat( '/rFilename/b  : ', File_Name );
    AddSpaces( Temp, 34 );
    If ( Hide_Mode = False ) Then Temp := Concat( Temp, '<<New>>' );
    Show_40( Temp );

    Writev( Temp, '/rFile Nmbr/b : ', FCnt, ' Of ', FMax );
    If ( Kywrd_Srch ) Then
    Writev( Temp, '/rFile Nmbr/b : ', FCur, ' Of ', Kywrd_Cnt );
    Show_40( Temp );

    Get_DL_Time;
    Writev( Temp, '/rXfer Time/b : ', DL_Time_Str, ' @ ',BaudRate,' Baud' );
    Show_40( Temp );

    Convert_Date( Dta_Data.Date ); Temp := Line;
    Convert_Time( Dta_Data.Time );
    Temp := Concat( '/rUploaded/b  : ', Temp, '  ', Line ); Show_40( Temp );

    Writev( Temp, '/rFile Size/b : ', Dta_Data.Size ); Show_40( Temp );
    Writev( Temp, '/rUploader/b  : ', MesgL[1] ); Show_40( Temp );
    Writev( Temp, '/rDL Count/b  : ', MesgL[2] ); Show_40( Temp );
    Writev( Temp, '/rRating/b    : ', MesgL[3] ); Show_40( Temp );

    X := ( ( Dta_Data.Size ) + 127 ) Div 128;
    Writev( Line, '/rBlocks/b    : Xmodem-', X );

    X := ( ( Dta_Data.Size ) + 1023 ) Div 1024;
    Writev( Temp, Line, ', (1k)-', X );         Show_40( Temp );

    Writev( Temp, '/rSIG/g [', SIG_Num:3,']/b : ', System2.Names[ Sig_Num ] );
    If ( Length( Temp ) > 44 ) Then Temp[0] := Chr( 45 );  EchoSE( Temp );

    CrLf;
    If ( Msg_Ln > 3 ) Then For X := 4 to Msg_Ln Do EchoSE( MesgL[X] )
    Else EchoSE( ' No Description' );
  End;

  Procedure Edit_File;
  Var
    Done : Boolean;
    Choice : Char;
  Begin
    Done := False;
    Repeat
      Show_List_Text;
      CrLf;
      EchoSE( '[/rU/b]ploader  [/rC/b]ount  [/rR/b]ating  [/rD/b]escription' );
      EchoSE( '[/rA/b]bort     [/rZ/b] Done' );
      CrLf;
      EchoS( 'Edit Command -> ' );
      Choice := Get_Char;  Upper_C( Choice );
      Case Choice Of
        'A' : Begin EchoSE( 'Abort' ); Done := True; End;
        'C' : Begin EchoSE( 'D/L Count' ); Edit_DL_Count; End;
        'D' : Begin
                EchoSE( 'Description' );
                Edit_Description( 1 );
                If ( Abort ) Then Abort := False;
              End;
        'R' : Begin EchoSE( 'Rating' ); Edit_Rating; End;
        'U' : Begin EchoSE( 'Uploader' ); Edit_Uploader; End;
        'Z' : Begin
                EchoSE( 'Done' );
                If ( Use_Desc ) Then Save_Description;
                Done := True;
              End;
        Else Bell( 20 );
      End; { Case }
    Until ( Done ) or ( No_Carrier );
  End;

  Procedure Copy_2_Sig( Md : Integer );
  Var
    X,Y, Z : Integer;
    Old_N, New_N : String;
    Ok : Boolean;
    Cs : CString;
  Begin
    Y := Sig_Num;  CrLf; CrLf;
    EchoS( 'Do You Want To See The File SIG Listing First? ' );
    If ( Yes_No( 'N' ) ) Then Show_Sigs;
    CrLf;  CrLf;
    EchoS( ' Select Sig To Copy File To :> ' );
    Z := Get_Number( Max_Sig );
    If ( Z > 0 ) Then Begin
      CrLf;  Ok := True;
      Old_N := Concat( System2.Paths[ Y ], File_Name );
      New_N := Concat( System2.Paths[ Z ], File_Name );
      MakeCString( Old_N, Cs );
      If ( Exists( New_N ) ) Then Begin
        EchoS( 'WARNING! Destination File Already Exists, Overwrite? ' );
        Ok := Yes_No( 'N' );
      End;
      If ( Ok ) Then Begin
        EchoS ( 'Copying ' );  EchoSE( Old_N );
        EchoS ( ' To --> ' );  EchoSE( New_N );
        Copy_File( Old_N, New_N, 0 );
        If ( Md=1 ) Then Begin
          X := UnLink( Cs );
          If ( X < 0 ) Then Show_Error( Old_N, X );
        End;
        If ( Use_Desc ) And ( System2.Use_Desc[ Z ] ) Then Begin
          Old_N := Concat( System2.Desc_Path[ Y ], File_Name );
          New_N := Concat( System2.Desc_Path[ Z ], File_Name );
          MakeCString( Old_N, Cs );
          EchoS ( 'Copying ' );  EchoSE( Old_N );
          EchoS ( ' To --> ' );  EchoSE( New_N );
          Copy_File( Old_N, New_N, 0 );
          If ( Md=1 ) Then X := UnLink( Cs );
        End
        Else Begin CrLf; EchoSE( 'Can NOT Copy File Description...' ); End;
      End;
    End;
  End;

  Function Search_4_Kywrd : Boolean;
  Var
    Ok : Boolean;
    X,P  : Integer;
    S  : String;
  Begin
    Ok := False;
    If ( Use_Desc ) Then Begin
      For X := 1 to Msg_Ln Do Begin
        S := MesgL[X]; Upper_Case( S );
        P := Pos( Srch_Str, S );  If ( P >0 ) Then Ok := True;
      End;
    End;
    P := Pos( Srch_Str, File_Name );
    If ( Length( Srch_Str ) < 11 ) And ( P > 0 ) Then Ok := True;
    If ( Ok ) Then Add_Kywrd_File;
    Search_4_Kywrd := Ok;
  End;

  Procedure Get_Lst_Options( Var Num:Integer );
  Var
    Ch : Char;
    Done, Show : Boolean;
    X, I : Integer;
  Begin
    Num := 1;
    Show := False;
    Show_List_Text;  Show_List_Opt;
    Repeat
      If ( Show ) Then Begin
        Show_List_Text;
        Show_List_Opt;
      End;
      Done:=False;
      Ch := Get_Char;  Upper_C( Ch );
      Case Ch Of
        'A' : Begin EchoSE( 'Again' ); Show := True; End;
        'X' : Begin EchoSE( 'Xpert Toggle' );
                UserAcs.XpertUser := NOT UserAcs.XpertUSer;
                Show := True;
              End;
        'C' : Begin EchoSE( 'Cont' ); Done := True; End;
        'M' : Begin EchoSE( 'Mark' ); Batch_Mark_File; Done := True; End;
        'D' : Begin EchoSE( 'Download' ); Download_File( File_Name,0 ); Show := True; End; 
        'U' : If ( Arc_File ) Then Begin
                Temp := Concat( 'Un/r', Arc_Type[ArcT], '/b  ' );
                EchoS( Temp );
                View_Arc_File;
                Show := True;
              End;
        'R' : If Arc_File = False Then Begin
                EchoSE( 'Read' );
                Read_File;
                Show := True;
              End;
        'V' : If ( Hide_Mode=False ) And ( Sig_Vald ) Then Begin
                EchoSE( 'Valid' );
                Valid_File;
                Show := True;
              End
              Else Bell( 20 );
        'H' : If ( Hide_Mode ) and ( Sig_Vald ) Then Begin
                EchoSE( 'Hide' );
                Hide_File;
                Show := True;
              End
              Else Bell( 20 );
        'E' : If ( Sig_Edit ) Then Begin
                EchoSE( 'Edit' );
                Edit_File;
                Show := True;
              End
              Else Bell( 20 );
        'P' : If ( Sig_Name ) Then Begin
                Copy_2_Sig( 0 );  { Copy }
                Show := True;
              End
              Else Bell( 20 );
        'O' : If ( Sig_Name ) Then Begin
                Copy_2_Sig( 1 );  { Move }
                Show := True;
              End
              Else Bell( 20 );
        'F' : If ( Sig_Name ) Then Begin
                CrLf;
                Show_DFree( '.' );
                Press_Any;
                Show := True;
              End
              Else Bell( 20 );
        'T' : If ( Sig_Name ) Then Begin
                DT_Stamp( F_Name );
                Show := True;
              End
              Else Bell( 20 );
        'N' : If ( Sig_Name ) Then Begin
                EchoSE( 'Name' );
                Rename_File;
                Show := True;
              End
              Else Bell( 20 );
        'J' : Begin
                If ( Kywrd_Srch ) Then X := Kywrd_Cnt  Else X := FMax;
                Writev( Temp, 'Enter File# 1-', X, ' > ' );
                I := Length( Temp );
                EchoS( Temp );
                Num := Get_Number( X );  FCur := Num;
                If ( Num=0 ) Then I := I + 1;
                If ( Num>0 ) Then Begin
                  If ( Kywrd_Srch ) Then Num := Kywrd_File[ Num ];
                  If ( Num < FCnt ) Then Num := 0 - ( FCnt - Num )
                  Else Num := Num - FCnt;
                  If ( Num = 0 ) Then Show := True
                  Else Begin
                    FCur := FCur - 1;
                    Done := True;
                  End;
                End
                Else For X := 1 To I Do Back_Space;
              End;
        'K' : If ( Sig_Kill ) Then Begin
                EchoSE( 'Kill' );
                Kill_File;
                Done := True;
              End
              Else Bell( 20 );
        'L' : If ( FCnt > 1 ) Then Begin
                EchoSE( 'Last' );
                Num := -1;
                Done := True;
              End;
        '?' : Begin EchoSE( 'Help' ); Show_File_Help; Show := False; End;
        'Q' : Begin
                If ( Quick_Scan ) Then Begin
                  EchoS( 'Abort Quick Scan? ' );
                  If ( Yes_No( 'N' ) ) Then Begin
                    Quick_Scan := False;
                    Abort := True;
                  End;
                End
                Else EchoSE( 'Quit' );
                Abort :=True;
              End;
        Else If Ord( Ch ) <>Cr Then Bell( 20 );
      End;
    Until ( Abort ) or ( No_Carrier ) or ( Done ) or ( Ord( Ch ) = Cr );
    CrLf;
  End;

  Procedure Show_List( Var Num : Integer );
  Var
    I,X : Integer;
    Ok : Boolean;
    Ch : Char;
  Begin
    If ( New_Files ) And ( Usr_Lst_Call<=Dta_Data.Date ) And ( Valid_New=False )
      or ( Find_File ) And ( Dta_Data.Date>=Find_Date )
      or ( New_Files ) And ( Valid_New )
      or ( New_Files=False ) And ( Find_File=False ) Then Begin
      Ok := True;
      If ( Valid_New=False ) Then Get_Description( 20 );
      If ( Sig_Vald=False ) And ( Hide_Mode=False ) Then Ok := False;
      Is_Ok := Ok;
      If ( Kywrd_Srch ) And ( Ok ) Then Ok := Search_4_Kywrd;
      If ( Valid_New ) And ( Hide_Mode ) Then Ok := False;
      If ( Ok ) And ( Valid_New ) Then Get_Description( 20 );
      If ( Ok ) Then Get_Lst_Options( Num );
    End;
  End;

  Procedure List_Files( Mode : Integer );
  Var
    X, Num : Integer;
  Begin
    If ( Mode < 1 ) Then Begin
      CrLf; EchoS( 'Enter Search Spec Or ( Return For *.* ): ' );
      Caps := True; Line_In( Sspec, 12 ); CrLf;
      If ( Sspec='' ) Then Sspec := '*.*';
    End
    Else Sspec := '*.*';
    FPath := Concat( System2.Paths[Sig_Num], Sspec );
    MakeCstring( FPath, Fname );
    Max_File;
    If ( FMax > 0 ) Then Begin
      FCnt := 0; Num := 1;
      While ( F_Search( Num ) = 0 ) and ( Abort=False ) Do Begin
        Make_F_Names;
        Show_List( Num );
      End;
    End
    Else Begin
      CrLf;
      If Sspec = '*.*' Then EchoSE( 'This Sig Is Empty...' )
        Else EchoSE( 'No Files Match Search Spec...' );
    End;
    If ( New_Files=False ) Then CrLf;
    If ( Abort ) Then Abort := False;
  End;

  Procedure Show_Scan_Hdr;
  Var
    Ok : Boolean;
  Begin
    Ok := True;
    If ( Lines = 1 ) Then Begin
      If ( New_Files ) And ( Dta_Data.Date <= Usr_Lst_Call ) Then Ok := False
      Else If ( Kywrd_Srch ) And ( Kywrd_Cnt = 0 ) Then Ok := False
      Else If ( Find_File ) And ( Dta_Data.Date < Find_Date ) Then Ok := False;
      If ( Ok ) Then Begin
        CrLf;
        EchoSE( 'No  Filename      Size     Uploaded On   Short Description' );
        EchoSE( '--  ------------  -------  ------------  -----------------' );
      End;
    End;
  End;

  Procedure Show_Scan;
  Var
    Ok : Boolean;
  Begin
    If (( New_Files ) And ( Usr_Lst_Call <= Dta_Data.Date )) or
      (( Find_File ) And ( Dta_Data.Date >= Find_Date )) or
      (( New_Files = False ) And ( Find_File = False )) Then Begin
        Ok := True;
        If ( Kywrd_Srch ) Then Get_Description( 20 ) Else Get_Description( 4 );
        If ( Sig_Vald=False ) And ( Hide_Mode=False ) Then Ok := False;
        If ( Ok ) And ( Kywrd_Srch ) Then Ok := Search_4_Kywrd;
        If ( Ok ) Then Begin
          If ( Kywrd_Cnt = 1 ) Then Show_Scan_Hdr;
          Get_DL_Time;
          SMark[Lines].BM_FName  := File_Name;
          SMark[Lines].BM_FSize  := Dta_Data.Size;
          SMark[Lines].BM_FTime  := Dta_Data.Time;
          SMark[Lines].BM_D_Time := DL_Time;
          SMark[Lines].BM_Sig    := Sig_Num;
          SMark[Lines].BM_CD_ROM := System2.CD_ROM[ Sig_Num ];
          If ( Carrier ) Then Show_Scan_Text;
          Lines := Lines + 1;
        End;
      End;
  End;

  Procedure Scan_Mark;
  Var
    K : Integer;
  Begin
    CrLf;
    Repeat
      Writev( Line, 'Mark Which File ( 1-', Lines - 1, ' ) -> ' );
      EchoS( Line );
      K := Get_Number( Lines - 1 );
      If ( K>0 ) Then Begin
        File_Name     := SMark[K].BM_Fname;
        Dta_Data.Size := SMark[K].BM_Fsize;
        Dta_Data.Time := SMark[K].BM_FTime;
        DL_Time       := SMark[K].BM_D_Time;
        Batch_Mark_File;
      End;
    Until ( K<1 ) or ( No_Carrier );
    CrLf;
  End;

  Procedure Scan_DL;
  Var
    K : Integer;
  Begin
    CrLf;
    Writev( Line, 'DownLoad Which File ( 1-', Lines - 1, ' ) -> ' );
    EchoS( Line );
    K := Get_Number( Lines - 1 );
    If ( K>0 ) Then Begin
      File_Name     := SMark[K].BM_Fname;
      Dta_Data.Size := SMark[K].BM_FSize;
      Dta_Data.Time := SMark[K].BM_FTime;
      DL_Time       := SMark[K].BM_D_Time;
      DownLoad_File( File_Name,0 );
    End;
    CrLf;
  End;

  Procedure Scan_Read;
  Var
    K : Integer;
  Begin
    Writev( Line, 'Read Which File ( 1-', Lines - 1, ' ) -> ' );
    EchoS( Line );
    K := Get_Number( Lines - 1 );
    If ( K > 0 ) Then Begin
      File_Name := SMark[K].BM_FName;  F_Name := File_Name;
      Test_Arc_File;
      If ( Arc_File = False ) Then Begin  CrLf;  CrLf; Read_File; End
        Else EchoSE( ' File IS An Archived File!' );
    End;
    CrLf;
  End;

  Procedure Scan_UnArc;
  Var
    K : Integer;
  Begin
    Writev( Line, 'UnArc Which File ( 1-', Lines - 1, ' ) -> ' );
    EchoS( Line );
    K := Get_Number( Lines - 1 );
    If ( K > 0 ) Then Begin
      File_Name := SMark[K].BM_FName;  F_Name := File_Name;
      Test_Arc_File;
      If ( Arc_File ) Then View_Arc_File
        Else EchoSE( ' NOT An Archived File!' );
    End;
    CrLf;
  End;

  Procedure Scan_Browse;
  Var
    K,F,I : Integer;
  Begin
    CrLf;
    Writev( Line, 'Browse Which File ( 1-', Lines - 1, ' ) -> ' );
    EchoS( Line );
    K := Get_Number( Lines - 1 );
    If ( K>0 ) Then Begin
      I := Lines; If ( Lines > 16 ) Then I := 16;
      F := FCnt;  FCnt := FCnt - ( I - K );
      File_Name     := SMark[K].BM_FName;
      Dta_Data.Size := SMark[K].BM_FSize;
      Dta_Data.Time := SMark[K].BM_FTime;
      DL_Time       := SMark[K].BM_D_Time;
      Desc_Path     := Concat( System2.Desc_Path[ Sig_Num ], File_Name );
      Get_Description( 20 );
      Show_List_Text;
      Press_Any;
      FCnt := F;
    End;
    CrLf;
  End;

  Procedure Scan_Files( Mode : Integer );
  Var
    X, I  : Integer;
    Ch : Char ;
    Again, Done : Boolean;
  Begin
    Done := False;
    If ( Mode < 1 ) Then Begin
      CrLf;  EchoS( 'Enter Search Spec Or ( Return For *.* ): ' );
      Caps := True;  Line_In( Sspec, 12 );  CrLf;
      If ( Sspec='' ) Then Sspec := '*.*';
    End
    Else Sspec := '*.*';
    FPath := Concat( System2.Paths[Sig_Num], Sspec );
    MakeCstring( FPath, Fname );
    Max_File;
    Lines :=1;  FCnt := 0;
    Repeat
      X := F_Search( 1 );  Again := False;
      If ( X = 0 ) Then Begin
        Show_Scan_Hdr;
        Make_F_Names;
        Show_Scan;
      End;
      If ( Lines = 17 ) or (( X<0 ) And (Lines > 1 )) Then Begin
        CrLf;
        EchoS( '[/rB/b]rowse  [/rD/b]ownload  [/rJ/b]ump  ' );
        If ( FCnt>17 ) Then EchoS( '[/rL/b]ast  ' );
        EchoS( '[/rM/b]ark  [/rU/b]nArc  [/rR/b]ead  ' );
        If ( X=0 ) Then EchoS( '[/gN/b]ext ' );
        EchoS( '[/rQ/b]uit ' );
        Repeat
          Ch := Get_Char;  Upper_C( Ch );
          Case Ch Of
            'B' : Begin
                    EchoSE( 'Browse' );  Scan_Browse;
                    Again := True;
                  End;
            'D' : Begin
                    EchoSE( 'Download' ); Scan_DL; Again := True;
                  End;
            'M' : Begin
                    EchoSE( 'Mark' ); Scan_Mark; Lines := 1;
                  End;
            'N' : If ( X>0 ) Then Begin
                    EchoSE( 'Next' ); Lines := 1;
                  End;
            'L' : If ( FCnt >16 ) Then Begin
                    EchoSE( 'Last' ); Again := True;
                  End;
            'J' : If ( FMax >16 ) Then Begin
                    EchoSE( 'Jump' );
                    If ( Kywrd_Srch ) Then FMax := Kywrd_Cnt;
                    Writev( Temp, ' Enter File# 1-',FMax, ' > ' );
                    I := Length( Temp );  CrLf;
                    EchoS( Temp ); X := Get_Number( FMax );
                    If ( X=0 ) Then I := I + 1;
                    If ( X>0 ) Then Begin
                      CrLf; CrLf;
                      If ( X > 1 ) Then Begin
                        If ( Kywrd_Srch ) Then X := Kywrd_File[ X ];
                        If ( X < FCnt ) Then X := 0 - ( FCnt - X + 1 )
                        Else X := X - ( FCnt + 1 );
                        X := F_Search( X );
                      End
                      Else FCnt := 0;
                      Lines := 1;
                    End
                    Else For X := 1 To I Do Back_Space;
                  End;
            'Q' : Begin
                    If ( Quick_Scan ) Then Begin
                      EchoS( 'Abort Quick Scan? ' );
                       If ( Yes_No( 'N' ) ) Then Quick_Scan := False;
                    End
                    Else EchoSE( 'Quit' );
                    Abort :=True;  Done := True;
                  End;
            'R' : Begin
                    EchoSE( 'Read' );  Scan_Read;
                    Again := True;
                  End;
            'U' : Begin
                    EchoSE( 'UnArc' );  Scan_UnArc;
                    Again := True;
                  End;
            Else If ( Ch = Chr( Cr ) ) Then Begin
              If ( X >= 0 ) Then Begin
                EchoSE( 'Next' ); Lines := 1;
              End
              Else Done := True;
            End;
          End;
        Until (Again) or (Done) or (Abort) or ( No_Carrier ) or (Lines=1);
        If ( Again ) Then Begin
          Clear_Screen;
          If ( FCnt > 16 ) Then Begin
            If ( Ch = 'L' ) Then Lines := Lines + 15;
          End
          Else Lines := Lines + FCnt;
          If ( FCnt < FMax ) Then Lines := Lines - 1;
          X := 0 - Lines;
          X := F_Search( X ); If ( FCnt = 1 ) Then FCnt := 0;
          Lines := 1;
        End;
      End;
    Until ( Done ) or ( Abort ) or ( No_Carrier ) or ( X < 0 );
    If ( FCnt = 0 ) And ( X < 0 ) Then Begin
      CrLf;
      If ( Sspec = '*.*' ) Then EchoSE( 'This Sig Is Empty...' )
        Else EchoSE( 'No Files Match Search Spec...' );
    End;
    If ( Kywrd_Srch ) And ( Lines=1 ) Then Begin
      CrLf;
      EchoSE( 'Keyword Not Found In Either Filename Or Description...' );
    End;
    CrLf;
    If ( New_Files = False ) Then CrLf;
    If ( Abort ) Then Abort := False;
  End;

  Procedure Keyword_Search;
  Var
    Ln, X, Y : Integer;
  Begin
    Kywrd_Srch := True;
    CrLf;
    EchoS( 'Enter String To Search (15 Chars Max) -> ' );
    Caps := True;
    Line_In( Srch_Str, 15 );
    Ln := Length( Srch_Str );
    If ( Ln > 0 ) Then Begin
      CrLf;
      If ( List_Mode ) Then List_Files( 3 )  Else Scan_Files( 3 );
    End
    Else EchoSE( ' Aborted...' );
    Kywrd_Srch := False;
  End;

  Function Get_Find_Date: Boolean;
  Var
    Temp : String;
    X, Ln : Integer;
    Date_Ok : Boolean;
  Begin
    Date_Ok := False;
    CrLf;
    EchoS( 'Enter Start Date ex: mm/dd/yy -> ' );
    Caps := False;
    Line_In( Temp, 8 );
    Ln := Length( Temp );
    If ( Ln = 8 ) Then Begin
      If ( Check_Line( Temp, '/', 2 ) ) Then Begin
        Line := Copy( Temp, Ln - 1, 2 );
        Date_Ok := Is_Numeric( Line );
        If ( Date_Ok ) Then Begin
          Readv( Line, Y );
          If ( Y<80 ) and ( Y>99 ) Then Date_Ok := False;
          X := Pos( '/', Temp );
          Line := Copy( Temp, 1, X - 1 );
          Date_Ok := Is_Numeric( Line );
          If ( Date_Ok ) Then Begin
            Readv( Line, M );
            If ( M<1 ) and ( M>12 ) Then Date_Ok := False;
            Temp := Copy( Temp, X+1,3 );
            X := Pos( '/', Temp );
            Line := Copy( Temp, 1, X - 1 );
            Date_Ok := Is_Numeric( Line );
            If ( Date_Ok ) Then Begin
              Readv( Line, D );
              If ( D<1 ) and ( D>31 ) Then Date_Ok := False;
              If ( Date_Ok ) Then Begin
                Y := Y - 80;
                M := Shl( M, 5 );
                Y := Shl( Y, 9 );
                Find_Date := Y + M + D;
                Find_File := True;
                Abort := False;
                CrLf;
              End;
            End;
          End;
        End;
      End;
      If ( Date_Ok = False ) Then Begin
        EchoSE( ' Invalid Date Format!' );
        Crlf;
      End;
    End
    Else EchoSE( ' Aborted...' );
    Get_Find_Date := Date_Ok;
  End;

  Procedure Do_New_Files;
  Begin
    Line := Concat( 'Checking Files In -> ',System2.Names[Sig_Num], ' :>' );
    EchoSE( Line );
    New_Files := True;
  End;

  Procedure Scan_New_Files;
  Begin
    Do_New_Files;
    Scan_Files( 1 );
    New_Files := False;
  End;

  Procedure List_New_Files;
  Begin
    Do_New_Files;
    List_Files( 1 );
    New_Files := False;
  End;

  Procedure Find_New_Files;
  Begin
    Valid_New := True;
    Do_New_Files;
    List_Files( 9 );
    New_Files := False;
    Valid_New := False;
  End;

  Procedure Search_New;
  Var
    Done : Boolean;
    Ch : Char;
    X,Y, Sig_Tmp, Mxg, Mxb : Integer;
    S : String;
  Begin
    Y := Sig_Num;
    Mxg := Max_Sig;
    Sig_Tmp := Sig_Cntr;
    Done := False;
    Find_File := False;
    Flush_Input;
    CrLf;
    S := UserRec.Last_Call_Date;  Convert_Date2( S );
    S := Concat( '[/gN/b] All New Files Since /g', S, '/b' );  EchoSE( S );
    EchoSE( '[/rD/b] All Files By Specified Date' );
    CrLf;
    EchoS( 'Choice -> ' );
    Ch := Get_Char;  Upper_C( Ch );
    If Ord( Ch ) =Cr Then Ch := 'N';
    If ( Ch In[ 'N','D' ] ) Then Begin
      Case Ch Of
        'N' : Begin
                Quick_Scan := True;
                EchoSE( 'ALL New Files...' );
                Sig_Cntr := 1;
                Sig_Num := Sig_Access[ Sig_Cntr ];
                Loop
                  Change_Nxt_Sig;
                  Exit If ( Tot_Sig ) or ( Quick_Scan=False );
                  List_New_Files;
                End;
                Quick_Scan := False;
              End;
        'D' : Begin
                Quick_Scan := True;
                EchoSE( 'By Date...' );
                If ( Get_Find_Date ) Then Begin
                  Sig_Cntr := 1;
                  Sig_Num := Sig_Access[ Sig_Cntr ];
                  Loop
                    Change_Nxt_Sig;
                    Exit If ( Tot_Sig ) or ( Quick_Scan=False );
                    List_New_Files;
                  End;
                  Quick_Scan := False;
                End;
              End;
      End; { Case }
    End
    Else CrLf;  CrLf;
    Sig_Num := Y;
    Max_Sig := Mxg;
    Sig_Cntr := Sig_Tmp;
    Find_File := False;
  End;

  Procedure List_Scan;
  Var
    Done : Boolean;
    Choice : Char;
    X,Y, Sig_Tmp, Mxg, Mxb : Integer;
  Begin
    Y := Sig_Num;
    Mxg := Max_Sig;
    Sig_Tmp := Sig_Cntr;
    Done := False;
    Find_File := False;
    Flush_Input;
    CrLf;
    EchoSE( 'By: [/gA/b]ll [/rK/b]eyword [/rN/b]ew [/rS/b]ince Date' );
    CrLf;
    EchoS( 'Choice -> ' );
    Choice := Get_Char;  Upper_C( Choice );
    If ( Ord( Choice ) = Cr ) Then Choice := 'A';
    If ( Choice In[ 'A','K','N','S' ] ) Then Begin
      Case Choice Of
        'S' : Begin
                EchoSE( 'By Date' );
                If ( Get_Find_Date ) Then Begin
                  If ( List_Mode ) Then List_Files( 2 ) Else Scan_Files( 2 );
                End;
              End;
        'K' : Begin EchoSE( 'Keyword Search' ); Keyword_Search; End;
        'A' : Begin
                If ( List_Mode ) Then Begin
                  EchoSE( 'List All' );
                  List_Files( 0 );
                End
                Else Begin
                  EchoSE( 'Scan All' );
                  Scan_Files( 0 );
                End;
              End;
        'N' : Begin
                New_Files := True;
                If ( List_Mode ) Then Begin
                  EchoSE( 'List New' );
                  List_Files( 1 );
                End
                Else Begin
                  EchoSE( 'Scan New' );
                  Scan_Files( 1 );
                End;
                New_Files := False;
              End;
      End; {Case}
    End
    Else CrLf;  CrLf;
    Sig_Num := Y;
    Max_Sig := Mxg;
    Sig_Cntr := Sig_Tmp;
  End;

  Procedure Xfer_F_Desc;
  Var
    H1, H2, I,Strt,Nd, X,Z,A : Integer;
    Ch : Char;
    S,F : String;
    L : Long_Integer;
  Begin
    F := Concat( System2.Temp_Pth, 'FILES.DSC' );
    CrLf;
    EchoS( 'Download Descriptions From [/rT/b]his SIG or [/rA/b]ll Selected SIGs ?' );
    Repeat
      Ch := Get_Char;  Upper_C( Ch );  I := Ord( Ch );
    Until ( Ch IN['A','T'] ) or ( I=Cr ) or ( No_Carrier );
    CrLf;  CrLf;
    If ( I <> Cr ) Then Begin
      Strt := 1;  Nd := 256;
      If ( Ch = 'T' ) Then Begin
        Strt := Sig_Num;  Nd := Strt;
      End;
      CrLf;  EchoSE( 'Copying Files To ->FILES.DSC' );
      H1 := FCreate( F, 0 );
      Write_Ln( H1, 'File Descriptions From FTU By Jay L. Bray' );
      Write_Ln( H1, '-----------------------------------------' );
      For I := Strt to Nd Do Begin
        X := Sig_Access [ I ];
        If ( X > 0 ) Then Begin
          If ( System2.Use_Desc[ X ] ) Then Begin
            FPath := Concat( System2.Desc_Path[ X ], '*.*' );
            Max_File;
            If ( FMax > 0 ) Then Begin
              FCnt := 0;
              For A := 1 To FMax Do Begin
                Z := F_Search( 1 );
                MakeFname( Dta_Data.Name, File_Name );
                S := Concat( 'Description Of: ', File_Name );
                Write_Ln( H1, S );
                Write_Ln( H1, '---------------------------' );
                F_Name := Concat( System2.Desc_Path[ X ], File_Name );
                H2 := FOpen( F_Name, 0 ); { Read Only }
                If ( H2 < 0 ) Then Show_Error( F_Name, H2 )
                Else Begin
                  L  := BlockRead ( H2, Block_Size, Blkio );
                  If ( L < 0 ) Then Show_Error( F_Name, H2 )
                  Else Begin
                    L  := BlockWrite( H1, L, Blkio );
                    If ( L < 0 ) Then Show_Error( F_Name, H1 );
                  End;
                  Z  := Close_File( H2 );
                  Write_Ln( H1, '/^\/^\/^\/^\/^\/^\/^\/^\/^\' );
                End;
              End;
            End;
          End;
        End;
      End;
      Z := Close_File( H1 );
      DownLoad_File( F,1 );
    End;
  End;

{$I Arc_Util.Pas }

  Procedure Edit_Sig( Sig : Integer );
  Var
    S : String;
    Ch : Char;
    Done : Boolean;
    X,Y,I,N1,N2 : Integer;
    Fa,Fm,V : Long_Integer;
  Begin
    N1 := ( Sig * 32 );  N2 := ( N1 - 31 );
    Repeat
      MesgL[1] := ' [1] Access    : ';
      MesgL[2] := ' [2] User Mask : ';
      Fa := UserAcs.Sig_Accs [ Sig ];
      Fm := UserAcs.User_Mask[ Sig ];
      For I := 0 to 31 Do Begin
        If Bit_Test( Fa, I ) Then Mesgl[1] := Concat( MesgL[1], 'Y' )
          Else Mesgl[1] := Concat( MesgL[1], '.' );
        If Bit_Test( Fm, I ) Then Mesgl[2] := Concat( MesgL[2], 'Y' )
          Else Mesgl[2] := Concat( MesgL[2], '.' );
      End;
      Clear_Screen;
      CrLf;
      Writev( S, 'Editing File Sig #''s ', N2, '  -  ', N1 );
      EchoNE( S );
      CrLf;
      EchoNE( '                            File SIGS       ' );
      If ( Sig = 1 ) Then Begin
        EchoNE( '                          1         2         3  ' );
        EchoNE( '     Function    12345678901234567890123456789012' );
      End
      Else If ( Sig = 2 ) Then Begin
        EchoNE( '                 4      4         5         6    ' );
        EchoNE( '     Function    34567890123456789012345678901234' );
      End
      Else If ( Sig = 3 ) Then Begin
        EchoNE( '                 6    7         8         9      ' );
        EchoNE( '     Function    56789012345678901234567890123456' );
      End
      Else If ( Sig = 4 ) Then Begin
        EchoNE( '                    1         1         1        ' );
        EchoNE( '                 9  0         1         2        ' );
        EchoNE( '     Function    78901234567890123456789012345678' );
      End
      Else If ( Sig = 5) Then Begin
        EchoNE( '                  1         1         1         1' );
        EchoNE( '                  3         4         5         6' );
        EchoNE( '     Function    90123456789012345678901234567890' );
      End
      Else If ( Sig = 6 ) Then Begin
        EchoNE( '                 1        1         1         1  ' );
        EchoNE( '                 6        7         8         9  ' );
        EchoNE( '     Function    12345678901234567890123456789012' );
      End
      Else If ( Sig = 7 ) Then Begin
        EchoNE( '                 1      2         2         2    ' );
        EchoNE( '                 9      0         1         2    ' );
        EchoNE( '     Function    34567890123456789012345678901234' );
      End
      Else If ( Sig = 8 ) Then Begin
        EchoNE( '                 2    2         2         2      ' );
        EchoNE( '                 2    3         4         5      ' );
        EchoNE( '     Function    56789012345678901234567890123456' );
      End;
      EchoNE( '     ---------   --------------------------------' );
      EchoNE( MesgL[1] );
      EchoNE( MesgL[2] );
      CrLf;
      Done := False;  I := 0;
      EchoN( 'Enter Function To Edit [Return] to Exit -> ' );
      Repeat
        Ch := Get_Char;  I := Ord( Ch );
      Until ( Ch IN['1'..'2'] ) or ( I=Cr ) or ( No_Carrier );
      CrLf;  CrLf;
      If ( I=Cr ) Then Done := True;
      If Ch In['1'..'2'] Then Begin
        Y := Ord( Ch ) - 48;
        S := Concat( ' Old -> ', MesgL[Y] );  EchoNE( S );
        S := Concat( ' New -> ', MesgL[Y] );  EchoN( S );
        For I := 1 to 32 Do Back_Space;  V := 0;
        For I := 0 to 31 Do Begin
          Repeat
            Ch := Get_Char;  Upper_C( Ch );
          Until ( Ch='Y' ) or ( Ch='N' ) or ( No_Carrier );
          If Ch = 'Y' Then EchoS( Ch ) Else EchoS( '.' );
          If Ch='Y' Then Bit_Set( V, I );
        End;
        CrLf; CrLf;
        If Y = 1 Then UserAcs.Sig_Accs[ Sig ] := V
        Else If Y = 2 Then UserAcs.User_Mask[ Sig ] := V;
      End;
    Until ( Done ) or ( No_Carrier );
  End;

  Procedure Edit_Usr_Sigs;
  Var
    S : String;
    Ch : Char;
    Ok : Boolean;
    X, I, N : Integer;
    V, Bit : Long_Integer;
  Begin
    For I := 0 to 7 Do Begin
      Repeat
        Clear_Screen;  CrLf;
        For N := 1 to 32 Do Begin
          Ok := False;
          X := ( I * 32 ) + N;
          If ( Sig_Access[ X ] <> 0 ) Then Ok := True;
          Writev( S, '   ',X:3, '.  ' );
          If Length( SysTem2.Names[X] ) = 0 Then S := Concat( S, '*- Empty -*' )
          Else S := Concat( S, System2.Names[X] );
          If ( Ok ) Then S[2] := '*';
          AddSpaces( S, 39 );  EchoS( S );
          If ( Not Odd( N ) ) Then CrLf;
        End;
        CrLf;
        S := 'Press ''E'' To Edit These Sigs or [Return] '; If ( I=7 ) Then S := Concat( S, 'to Exit -> ' )
        Else S := Concat( S, 'For More -> ' );  EchoN( S );
        Repeat
          Ch := Get_Char;  N := Ord( Ch ); Upper_C( Ch );
        Until ( Ch = 'E' ) or ( N = Cr ) or ( No_Carrier );
        If ( Ch = 'E' ) Then Edit_Sig( I+1 );
      Until ( N = Cr ) or ( No_Carrier );
    End;
  End;

  Procedure Change_Stats;
  Var
    X, Z, I, I2, I3, N, A, W : Integer;
    Fa, Fb : Long_Integer;
    Temp : String;
    B : Packed Array [1..256] of Integer;
  Begin
    For I := 1 To 256 Do  B[ I ] := 0;  X := 0;  I := -1;
    For N := 0 To 7 Do Begin
      Fa := UserAcs.Sig_Accs[ N+1 ];  Fb := UserAcs.User_Mask[ N+1 ];
      If ( Fa <> 0 ) Then Repeat
        Clear_Screen;  CrLf; Z := 1;  W := 0;
        EchoSE( 'Sigs You Currently Have Access To:' );  CrLf;
        For X := 0 To 31 Do Begin
          I := ( N * 32 );  I2 := I + X;  I3 := I2 + 1;
          Temp := System2.Names[ I3 ];
          If ( Bit_Test ( Fa, X ) ) And ( Length ( Temp ) > 0 ) Then Begin
            B [ I3 ] := X;  W := W + 1;
            Writev( Temp, '[/r', I3:3, '/b] ', System2.Names[ I3 ] );
            Addspaces( Temp ,39 );
            If Bit_Test( Fb, X ) Then Temp := Concat( Temp, 'Yes ' )
              Else Temp := Concat( Temp, 'No  ' );
            If ( Odd( Z ) ) And ( WidT=80 ) Then EchoS( Temp ) Else EchoSE( Temp );
            Z := Z + 1;
          End;
        End; { 0-31 }
        If ( Not Odd( Z ) ) Then CrLf; CrLf;
        If ( W = 0 ) Then Begin
          WriteV( Temp, 'Sorry, Nothing Available On Page ', N+1 );
          EchoSE( Temp );  I := -1;
        End
        Else Begin
          EchoS( 'Enter /gSig#/b To Change, [/r0/b]Clear All, [/r999/b]Add All or [Return] ' );
          If ( I3 >= Max_Sig ) Then EchoS( 'to Quit -> ' )
            Else EchoS( 'For More -> ' );
          I := Get_Number( 999 );
          If ( I = 0 ) Then Begin
            UserAcs.User_Mask[ N+1 ] := 0;
            Fb := 0;
          End
          Else If ( I = 999 ) Then Begin
            UserAcs.User_Mask[ N+1 ] := -1;
            Fb := -1;
          End
          Else If ( I > 0 ) And ( I <= I3 ) Then Begin
            A := B [ I ];
            If Bit_Test( Fb, A ) Then Bit_Clr( Fb, A )  Else Bit_Set( Fb, A );
            UserAcs.User_Mask[ N+1 ] := Fb;
          End;
        End;
      Until ( I < 0 ) or ( No_Carrier );
    End; { 0-7 }
    Get_Sig_Access;
    Sig_Cntr := 0;
    Change_Nxt_Sig;
    CrLf;  CrLf;
    Save_Ftu_User;
  End;

  Procedure Get_DL_32767( Var I : Integer );
  Begin
    EchoS ( 'Enter New Number (0-32767), ( [/gReturn/b] = No Change ) -> ' );
    I := Get_Number( 32767 );
  End;

  Procedure Get_DL_99999999( Var L : Long_Integer );
  Begin
    EchoS ( 'Enter New Number (0-99999999), ( [/gReturn/b] = No Change ) -> ' );
    L := Get_A_Number( 99999999 );
  End;

  Procedure Show_Level;
  Var
    F : Long_Integer;
    X : Integer;
  Begin
    F := UserRec.Sec_Lvl;
    Clear_Local;
    CrLf;
    EchoSE( '/rUser Access ( Command ) Level:/b' );
    For X := 0 to 31 Do
      If ( Bit_Test ( F, X ) ) Then EchoS( 'X' )  Else EchoS( '-' );
    CrLf;
    CrLf;
    EchoSE( '/r Access Level Required To:/b      Access?' );
    EchoSE( '/rEdit:/b' );
    For X := 0 to 31 Do
      If ( Bit_Test ( System2.Slvl_Edit[ Sig_Num ], X ) ) Then EchoS( 'X' )
        Else EchoS( '-' );
    If ( Sig_Edit ) Then EchoSE( '    Yes' )  Else EchoSE( '    No' );
    EchoSE( '/rKill:/b' );
    For X := 0 to 31 Do
      If ( Bit_Test ( System2.Slvl_Kill[ Sig_Num ], X ) ) Then EchoS( 'X' )
        Else EchoS( '-' );
    If ( Sig_Kill ) Then EchoSE( '    Yes' )  Else EchoSE( '    No' );
    EchoSE( '/rName:/b' );
    For X := 0 to 31 Do
      If ( Bit_Test ( System2.Slvl_Name[ Sig_Num ], X ) ) Then EchoS( 'X' )
        Else EchoS( '-' );
    If ( Sig_Name ) Then EchoSE( '    Yes' )  Else EchoSE( '    No' );
    EchoSE( '/rVald:/b' );
    For X := 0 to 31 Do
      If ( Bit_Test ( System2.Slvl_Vald[ Sig_Num ], X ) ) Then EchoC( 'X' )
        Else EchoS( '-' );
    If ( Sig_Vald ) Then EchoSE( '    Yes' )  Else EchoSE( '    No' );
    CrLf;
    CrLf;
  End;

  Procedure Edit_DL_Ratios;
  Var
    Ch : Char;
    S  : String;
    I  : Integer;
    L  : Long_Integer;
  Begin
    Repeat
      Clear_Screen;
      CrLf;
      EchoNE( ' [/rA/b]  Edit Total  Files Downloaded ' );
      EchoNE( ' [/rB/b]  Edit Total  Files Uploaded   ' );
      EchoNE( ' [/rC/b]  Edit Total   (k)  Downloaded ' );
      EchoNE( ' [/rD/b]  Edit Total   (k)  Uploaded   ' );
      EchoNE( ' [/rE/b]  Edit Total Points Downloaded ' );
      EchoNE( ' [/rF/b]  Edit Total Points Uploaded   ' );
      EchoNE( ' [/rG/b]  Edit  File  Ratio    (1)     ' );
      EchoNE( ' [/rH/b]  Edit   (k)  Ratio    (2)     ' );
      EchoNE( ' [/rI/b]  Edit Points Ratio    (3)     ' );
      EchoNE( ' [/rJ/b]  Change Ratio Type ----^      ' );
      CrLf;
      EchoN ( ' Choice [/gReturn/b] To Quit -> ' );
      Ch := Get_Char;  Upper_C( Ch );
      If ( Ch IN[ 'A'..'J' ] ) Then Begin  CrLf;  CrLf;  End;
      Case Ch Of
        'A' : Begin
                WriteV( S, 'Current Files Downloaded -> ', UserAcs.Downloads );
                EchoSE( S ); CrLf;
                Get_DL_32767( I );
                If ( I >= 0 ) Then UserAcs.Downloads := I;
              End;
        'B' : Begin
                WriteV( S, 'Current Files Uploaded -> ', UserAcs.Uploads );
                EchoSE( S ); CrLf;
                Get_DL_32767( I );
                If ( I >= 0 ) Then UserAcs.Uploads := I;
              End;
        'C' : Begin
                WriteV( S, 'Total (k) Downloaded -> ', UserAcs.K_Dnld );
                EchoSE( S ); CrLf;
                Get_DL_99999999( L );
                If ( L >= 0 ) Then UserAcs.K_Dnld := L;
              End;
        'D' : Begin
                WriteV( S, 'Total (k) Uploaded -> ', UserAcs.K_Upld );
                EchoSE( S ); CrLf;
                Get_DL_99999999( L );
                If ( L >= 0 ) Then UserAcs.K_Upld := L;
              End;
        'E' : Begin
                WriteV( S, 'Total Points Downloaded -> ', UserAcs.Pts_Dnld );
                EchoSE( S ); CrLf;
                Get_DL_99999999( L );
                If ( L >= 0 ) Then UserAcs.Pts_Dnld := L;
              End;
        'F' : Begin
                WriteV( S, 'Total Points Uploaded -> ', UserAcs.Pts_Upld );
                EchoSE( S ); CrLf;
                Get_DL_99999999( L );
                If ( L >= 0 ) Then UserAcs.Pts_Upld := L;
              End;
        'G' : Begin
                WriteV( S, 'File Ratio -> ', UserAcs.DL_Ratio );
                EchoSE( S ); CrLf;
                Get_DL_32767( I );
                If ( I >= 0 ) Then UserAcs.DL_Ratio := I;
              End;
        'H' : Begin
                WriteV( S, '(k) Ratio -> ', UserAcs.K_Ratio );
                EchoSE( S ); CrLf;
                Get_DL_32767( I );
                If ( I >= 0 ) Then UserAcs.K_Ratio := I;
              End;
        'I' : Begin
                WriteV( S, 'Points Ratio -> ', UserAcs.Pts_Ratio );
                EchoSE( S ); CrLf;
                Get_DL_32767( I );
                If ( I >= 0 ) Then UserAcs.Pts_Ratio := I;
              End;
        'J' : Begin
                WriteV( S, 'Ratio Type ( 0 = None ) -> ', UserAcs.Ratio_Typ );
                EchoSE( S ); CrLf;
                EchoS ( 'Enter New Number (0-3), ( [/gReturn/b] = No Change ) -> ' );
                I := Get_Number( 3 );
                If ( I >= 0 ) Then UserAcs.Ratio_Typ := I;
              End;
      End;
    Until ( Ord( Ch ) = Cr ) or ( No_Carrier );
  End;  

  Procedure Edit_User;
  Var
    Ch : Char;
    S : String;
    Z : Integer;
  Begin
    Fnct_Key := 0;
    Clear_Screen;
    Repeat
      Clear_Screen;
      CrLf;
      EchoNE( '[/r1/b]  Edit Sig Access  ' );
      CrLf;
      EchoNE( '[/r2/b]  Apply User Mask  ' );
      CrLf;
      EchoNE( '[/r3/b]  Edit D/L Ratios  ' );
      CrLf;
      EchoN( 'Choice, [/gReturn/b] To Exit -> ' );
      Ch := Get_Char;
      Case Ch Of
        '1' : Begin
                Edit_Usr_Sigs;
                Get_Sig_Access;
                Sig_Cntr := 0;
                Change_Nxt_Sig;
              End;
        '2' : Begin
                S := 'Enter Mask Number to Apply, [/gReturn/b] To Exit  -> ';
                CrLf;  CrLf;
                EchoN( S );
                Z := Get_Number( 10 );
                If ( Z > 0 ) Then Begin
                  Get_MaskData( Z );
                  Get_Sig_Access;
                  Sig_Cntr := 0;
                  Change_Nxt_Sig;
                End;
              End;
        '3' : Edit_DL_Ratios;
      End; { Case }
    Until ( Ord( Ch ) = Cr ) or ( No_Carrier );
    Save_Ftu_User;
    CrLf;
    Clear_Screen;
  End;

  Procedure Validate_New;
  Begin
    EchoSE( 'Validate New' );
    Sig_Cntr := 1;
    Sig_Num := Sig_Access[ Sig_Cntr ];
    Loop
      Change_Nxt_Sig;
      Exit If ( Tot_Sig );
      Find_New_Files;
     End;
  End;

  Procedure Batch_Menu;
  Begin
    View_Menu( 'Batch.Mnu' );
    EchoS( 'Choice, [Return] To Exit :> ' );
  End;

  Procedure Batch_Options;
  Var
    Choice : Char;
    Done : Boolean;
    X, Y : Integer;
  Begin
    New_Line := False;
    Clear_Screen;
    Repeat
      Batch_Menu;
      Choice := Get_Char;  Upper_C( Choice );  X := Ord( Choice );
      If ( Choice In[ 'A','C','D','L','R' ] ) or ( X=Cr ) Then Begin
        Case Choice of
          'A' : Begin EchoSE ( 'Add' );          Batch_Mark;          End;
          'C' : Begin EchoSE ( 'Clear' );        Clear_Batch;         End;
          'D' : Begin EchoSE ( 'Batch D/Load' ); Batch_Send;          End;
          'L' : Begin EchoSE ( 'List' );         Review_Marked_Files; End;
          'R' : Begin EchoSE ( 'Remove' );       Wipe_Marked;         End;
        End;
        If ( X <> Cr ) Then Begin Press_Any; Clear_Screen; End;
      End;
    Until ( X = Cr ) or ( No_Carrier );
    CrLf;
    CrLf;
  End;

  Procedure Convert_Translation;
  Begin
    VT52    := False;   V_Color := False;
    ANSI    := False;   A_Color := False;
    If ( Transv = 1 ) or ( Transv = 2 ) Then VT52 := True;
    If ( Transv = 2 ) Then V_Color := True;
    If ( Transv = 3 ) or ( Transv = 4 ) Then ANSI := True;
    If ( Transv = 4 ) Then A_Color := True;
    If ( ANSI ) And ( Not Local ) Then MEscape( '[0m' );  { ReSet Colors }
  End;

  Procedure Show_Profile;
  Var
    S : String;
    I : Integer;
    C : Char;
  Begin
    Repeat
      Clear_Screen;
      EchoNE( 'Current /rProfile/b' );
      CrLf;
      EchoS( '  Baud Rate          : ' );      EchoSE( BaudRate );
      EchoS( '  Video [/rW/b]idth      : ' );  EchoSE( Width );
      EchoS( ' [/rT/b]ransfer Protocol : ' );
      WriteV( S, XferT[ Protocol ] );             EchoSE( S );
      EchoS( ' [/rV/b]ideo Translation : ' );
      WriteV( S, Trans[ UserRec.Translation ] );  EchoSE( S );
      CrLf;
      EchoS( 'Enter Choice or [/rX/b] to eXit -> ' );
      Repeat
        C := Get_Char;  Upper_C( C );
      Until ( No_Carrier ) or ( C In[ 'T','V'..'X' ] );
      Case C Of
        'T' : Begin
                CrLf;  CrLf;
                EchoSE( 'Transfer Protocols Available:' );  CrLf;
                For I := 1 To 6 Do Begin
                  WriteV( S, '[/r', I, '/b] ', XferT[ I - 1 ] );
                  EchoSE( S );
                End;
                CrLf;
                EchoS( 'Press 1-6 or [/rReturn/b] To Abort -> ' );
                I := Get_Number( 6 );
                If ( I > 0 ) Then Protocol := I - 1;
                UserAcs.Xmodem_Type := Protocol;
              End;
        'V' : Begin
                CrLf;  CrLf;
                EchoSE( 'Video Translations Available:' );  CrLf;
                For I := 1 To 5 Do Begin
                  WriteV( S, '[/r', I, '/b] ', Trans[ I - 1 ] );
                  EchoSE( S );
                End;
                CrLf;
                EchoS( 'Press 1-5 or [/rReturn/b] To Abort -> ' );
                I := Get_Number( 5 );
                If ( I > 0 ) Then Begin
                  TransV := I - 1;  UserRec.Translation := TransV;
                  Convert_Translation;
                End;
              End;
        'W' : Begin
                CrLf;  CrLf;
                EchoS( 'Press [/r4/b]0 Column or [/r8/b]0 Column -> ' );
                C := Get_Char;  I := ( Ord( C ) - 48 );
                If ( I = 4 ) Then WidT := 40  Else If ( I = 8 ) Then WidT := 80;
                UserRec.Video_Width := WidT;
                Writev( Width, WidT );
              End;
      End; { Case }
    Until ( No_Carrier ) or ( C = 'X' );
    If ( Carrier ) Then Show_UInfo;
    CrLf;  CrLf;
  End;

  Procedure ANSI_Stuff;
  Var
    Ch : Char;
    X : Integer;
    S : String;
  Begin
    Clear_Screen;
    If ( ANSI ) Then Begin
      Repeat
        EchoNE( '/w/B ' );
        Clear_Screen;
        CrLf;
        EchoNE( 'ANSI Screen Attribute Options' );
        CrLf;
        EchoNE( '/w[/r1/w]/g  Set Screen Colors    /w' );
        EchoNE( '/w[/r2/w]/g  Set Background Color /w' );
        EchoNE( '/w[/r3/w]/g  Exit Ansi Options    /w' );
        CrLf;
        EchoN ( 'Choice -> ' );
        Repeat
          Ch := Get_Char;  Upper_C( Ch );
        Until ( Ch In[ '1'..'3' ] ) Or ( No_Carrier );
        If ( Ch = '1' ) Then Begin
          Repeat
            Clear_Screen;
            S := Concat( Escp,'[40;37m' );  EchoSE( S );
            EchoNE( 'Colors Available:' );  CrLf;
            S := Concat( Escp,'[40;37m0 - ', Escp, '[40;30m Grey   ' );  EchoNE(S);
            S := Concat( Escp,'[40;37m1 - ', Escp, '[40;31m Red    ' );  EchoNE(S);
            S := Concat( Escp,'[40;37m2 - ', Escp, '[40;32m Green  ' );  EchoNE(S);
            S := Concat( Escp,'[40;37m3 - ', Escp, '[40;33m Yellow ' );  EchoNE(S);
            S := Concat( Escp,'[40;37m4 - ', Escp, '[40;34m Blue   ' );  EchoNE(S);
            S := Concat( Escp,'[40;37m5 - ', Escp, '[40;35m Magenta' );  EchoNE(S);
            S := Concat( Escp,'[40;37m6 - ', Escp, '[40;36m Cyan   ' );  EchoNE(S);
            S := Concat( Escp,'[40;37m7 - ', Escp, '[40;37m White  ' );  EchoNE(S);
            CrLf;
            EchoNE( '/b[A] Change Color #0 /wTEXT' );
            EchoNE( '/b[B] Change Color #1 /rTEXT' );
            EchoNE( '/b[C] Change Color #2 /gTEXT' );
            EchoNE( '/b[D] Change Color #3 /bTEXT' );
            EchoNE( '/w[E] Exit Color Options    ' );
            EchoN ( '/gChoice -> ' );
            Repeat
              Ch := Get_Char;  Upper_C( Ch );
            Until ( Ch In[ 'A'..'E' ] ) Or ( No_Carrier );
            If ( Ch <> 'E' ) Then Begin
              Put_Char( Ch );  CrLf;  CrLf;
              EchoN( 'Enter New Color ( 0-7 ) :> ' );
              X := Get_Number( 7 );
              If ( X >= 0 ) Then Begin
                X := X + 48;
                If ( Ch = 'A' ) Then Begin
                  W_Color := Chr( X );  UserAcs.Colors[ 0 ] := X;
                End
                Else If ( Ch = 'B' ) Then Begin
                  R_Color := Chr( X );  UserAcs.Colors[ 1 ] := X;
                End
                Else If ( Ch = 'C' ) Then Begin
                  G_Color := Chr( X );  UserAcs.Colors[ 2 ] := X;
                End
                Else If ( Ch = 'D' ) Then Begin
                  B_Color := Chr( X );  UserAcs.Colors[ 3 ] := X;
                End;
              End;
            End;
          Until ( Ch = 'E' );
        End;
        If ( Ch = '2' ) Then Begin
          Repeat
            Clear_Screen;  CrLf;
            EchoNE( 'Background Colors Available:' );  CrLf;
            S := Concat( Escp,'[40;37m 0 - ',Escp,'[40;30m Black  ',Escp,'[4',Bk_Color,'m ' );
            EchoNE(S);
            S := Concat( Escp,'[40;37m 1 - ',Escp,'[41;31m Red    ',Escp,'[4',Bk_Color,'m ' );
            EchoNE(S);
            S := Concat( Escp,'[40;37m 2 - ',Escp,'[42;32m Green  ',Escp,'[4',Bk_Color,'m ' );
            EchoNE(S);
            S := Concat( Escp,'[40;37m 3 - ',Escp,'[43;33m Brown  ',Escp,'[4',Bk_Color,'m ' );
            EchoNE(S);
            S := Concat( Escp,'[40;37m 4 - ',Escp,'[44;34m Blue   ',Escp,'[4',Bk_Color,'m ' );
            EchoNE(S);
            S := Concat( Escp,'[40;37m 5 - ',Escp,'[45;35m Magenta',Escp,'[4',Bk_Color,'m ' );
            EchoNE(S);
            S := Concat( Escp,'[40;37m 6 - ',Escp,'[46;36m Cyan   ',Escp,'[4',Bk_Color,'m ' );
            EchoNE(S);
            S := Concat( Escp,'[40;37m 7 - ',Escp,'[47;37m Grey   ',Escp,'[4',Bk_Color,'m ' );
            EchoNE(S);
            CrLf;
            EchoN( 'Enter New Background Color ( 0-7 or "9" to Exit ) :> ' );
            X := Get_Number( 9 );
            If ( X >= 0 ) And ( X < 8 ) Then Begin
              X := X + 48;
              Bk_Color := Chr( X );  UserAcs.Colors[ 16 ] := X;
            End;
          Until ( X = 9 );
        End;
      Until( Ch = '3' ) or ( No_Carrier );
    End
    Else EchoSE( 'These Functions Are ONLY For ANSI Terminals...' );
    CrLf;
  End;

{$I Dos_Shll.Pas }

  Procedure Show_Menu;
  Begin
    Clear_Screen;
    View_Menu( 'Main.Mnu' );
  End;

  Procedure Show_Q_Help;
  Var
    S : String;
  Begin
    Clear_Screen;
    CrLf;
    New_Line := False;
    S := ( '[/rC/b] Change User Settings' ); Show_40( S );
    S := ( '[/rX/b] eXit, Return To BBS' );  Show_40( S );
    S := ( '[/r?/b] This Menu' );            Show_40( S );
    CrLf;
  End;

  Procedure Show_Main_Help;
  Begin
    Clear_Local;
    CrLf;
    EchoNE( '/rSysOp Main Help/b' );
    CrLf;
    EchoNE( '       /rF1/b - Edit User Info   ' );
    EchoNE( '       /rF2/b - Validate Files   ' );
    EchoNE( '       /rF3/b - Show User Level  ' );
    EchoNE( '       /rF5/b - Enter Chat Mode  ' );
    EchoNE( '       /rF6/b - Toggle Chat Mode ' );
    EchoNE( '      /rF10/b - Terminal Mode    ' );
    EchoNE( '/rShift F10/b - Kick Off User    ' );
    CrLf;
  End;

  Procedure Help_Mode;
  Var
    Ch : Char;
    Done : Boolean;
  Begin
    Done := False;
    Repeat
      If ( TimeLeft > 0 ) Then Begin
        CrLf;
        EchoSE( '        /rHELP Mode Active/b' );  CrLf;
        EchoSE( 'Press:  A,B,C,D,F,H,I,L,N,P,S,T,U,V,X,Y,[,],*,!,? ' );
        EchoS ( '  or [ Return ] To Exit Help :> ' );
        Ch := Get_Char;  Upper_C( Ch );
        If ( Ch In [ 'A'..'D','F','H','I','L','N','P','*' ] ) 
        or ( Ch In [ 'S'..'V','X','Y','?','[',']','!' ] ) Then Begin
          If ( Ch = '*' ) Then Ch := '0'
          Else If ( Ch = '?' ) Then Ch := '1'
          Else If ( Ch = '[' ) Then Ch := '2'
          Else If ( Ch = ']' ) Then Ch := '3'
          Else If ( Ch = '!' ) Then Ch := '4';
          F_Name := Concat( FTU_Path, 'HELP\Help_', Ch );
          CrLf;  CrLf;
          Read_File;
        End
        Else If ( Ord( Ch ) = Cr ) Then Done := True;
      End;
    Until ( Done ) or ( No_Carrier );
    CrLf;  CrLf;
  End;

  Procedure Term_Mode;
  Var
    X : Integer;
  Begin
    Fnct_Key := 0;
    Clear_Screen;  CrLf;
    EchoCE( 'Terminal Mode  -  Press F10 to Exit...' );  CrLf;
    Repeat
      If ( Mdm_In ) Then Begin
        X := Get_Modem;
        Put_Console( Chr( X ) );
      End
      Else If ( Con_In ) Then Begin
        X := Get_Console;
        Put_Modem( Chr( X ) );
      End;
    Until ( Fnct_Key = F10 );
    Fnct_Key := 0;
  End;

  Procedure Bell_C2;
  Begin
    Bell( 20 );
    CrLf;  CrLf;
  End;

  Procedure Show_Drives;
  Var
    I : Integer;
  Begin
    CrLf;  CrLf;
    EchoSE( 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z' );
    For I := 0 To 25 Do Begin
      If Drive_Exist( I ) Then EchoS( '* ' )  Else EchoS( '- ' );
    End;
    CrLf;  CrLf;
  End;

  Procedure Menu;
  Var
    Choice : Char;
    Done : Boolean;
    W, X, Y, Z : Integer;
    L : Long_Integer;
  Begin
    Sig_Cntr := 0;
    Change_Nxt_Sig;
    CrLf;
    Repeat
      WriteV( Line, 'Sig:', Sig_Num:3, '/', Max_Sig );
      Write_Six( 65,4, Grn, Blk, Line );
      Done := False;  Abort := False;  List_Mode := False;
      Scan_Mode := False;  Clr_Kywrd_File;
      Flush_Input;
      If ( Shw_Time ) Then Begin Show_TimeLeft; EchoS( Line ); End;
      If ( Max_Sig = 0 ) or ( Sig_Cntr = 0 ) Then Begin
        EchoS( '[/r0/b> No Access :> ' );
        Choice := Get_Char;  Upper_C( Choice );
        If ( Fnct_Key=F1 ) Then Edit_User
        Else Case Choice of
          'C' : Begin EchoSE( 'Change Stats' ); Change_Stats; End;
          'X' : Begin EchoSE( 'eXit' ); Done := True; End;
          '?' : Begin EchoSE( 'Help' ); Show_Q_Help; End;
          Else Bell_C2;
        End; { Case }
      End
      Else If ( TimeLeft > 0 ) Then Begin
        Writev( Line, '[/r', Sig_Num, '/b> ' );
        EchoS( Line );
        Line := Concat( System2.Names[ Sig_Num ], ' :> ' );
        EchoS( Line );
        Choice := Get_Char;  Upper_C( Choice );
        Case Choice of
          'A' : If ( System2.Use_Arc ) Then Begin
                  EchoSE( 'Arc Utils' );
                  Arc_Utils;
                 End
                 Else EchoSE( 'Sorry, Archive Utilities Not Active...' );
          'B' : Begin EchoSE( 'Batch Options' ); Batch_Options; End;
          'C' : Begin EchoSE( 'Change Stats' ); Change_Stats; End;
          'D' : Begin EchoSE( 'Download' ); DownLoad_A_File; End;
          'F' : Begin EchoSE( 'Download File Descriptions' );
                  Xfer_F_Desc;
                End;
          'H' : Begin EchoSE( 'Help Mode' ); Help_Mode; End;
          'I' : Begin EchoSE( 'ANSI Options' ); ANSI_Stuff; End;
          'L' : Begin EchoSE( 'List Files' ); List_Mode:=True; List_Scan; End;
          'N' : Begin EchoSE( 'New Files' ); Search_New; End;
          'P' : Begin EchoSE( 'Page' ); Page_SysOp; End;
          'S' : Begin EchoSE( 'Scan Files' ); Scan_Mode:=True; List_Scan; End;
          'T' : Time_Toggle;
          'U' : Begin EchoSE( 'Upload' );
                  If ( System2.Upload_Ok[ Sig_Num ] ) Or ( System2.Sig1 ) 
                    Then Upload_A_File
                  Else EchoSE( 'Uploads Are /rNOT/b Allowed To This File SIG!' );
                End;
          'V' : Begin EchoSE( 'View Profile' ); Show_Profile; End;
          'X' : Begin EchoSE( 'eXit' ); Done := True; End;
          'Y' : Begin EchoSE( 'Your D/L Stats' ); Show_DL_Stats; End;
          '*' : Show_Sigs;
          '$' : Begin EchoSE( 'Dos Shell' );
                  If ( Bit_Cmp( UserRec.Sec_Lvl, System2.SLvl_DOSS ) ) Then
                  Dos_Shell Else EchoSE( 'You Do NOT Have Acess Here...' );
                End;
          '?' : Begin EchoSE( 'Help' ); Show_Menu; End;
          '[' : If ( Sig_Cntr > 1 ) Then Begin
                  EchoSE( 'Change Prev Sig' );
                  Change_Prv_Sig;
                End
                Else Bell_C2; 
          ']' : If ( Sig_Cntr < Max_Sig ) Then Begin
                  EchoSE( 'Change Next Sig' );
                  Change_Nxt_Sig;
                End
                Else Bell_C2;
          '!' : Disconnect;
          Else If Choice In['1'..'9'] Then Begin
            Put_Char( Choice );  Z := 16;
            X := Ord( Choice ) - 48;  Y := 16;  W := Sig_Cntr;
            If ( Max_Sig >= ( X * 10 ) ) Then Begin
              Choice := Get_Char;
              If Choice In['0'..'9'] Then Begin
                Put_Char( Choice );
                If Ord( Choice ) <> 13 Then Begin
                  Y := Ord( Choice ) - 48;
                  If Y = 10 Then Y := 0;
                  If ( Max_Sig >= ( X * 100 ) ) Then Begin
                    Choice := Get_Char;
                    If Choice In['0'..'9'] Then Begin
                      Put_Char( Choice );
                      If Ord( Choice ) <> 13 Then Begin
                        Z := Ord( Choice ) - 48;
                        If Z = 10 Then Z := 0;
                      End;
                    End;
                  End;
                End;
              End;
            End;
            If ( X <= Max_Sig ) And ( Y = 16 ) Then Sig_Cntr := X
            Else Begin
              If ( Max_Sig >= ( X * 100 ) ) And ( Z <> 16 ) Then
                X := ( X * 100 ) + ( Y * 10 ) + Z
              Else X := ( X * 10 ) + Y;
              If ( X <= Max_Sig ) Then Sig_Cntr := X;
            End;
            If ( Sig_Cntr >= 1 ) Then Begin
              Z := Sig_Num;
              Get_Sig_Nums;
              If ( Sig_Num = 0 ) Then Begin
                Sig_Cntr := W;  Sig_Num := Z;
              End
              Else Change_Drv_Path( System2.Paths[Sig_Num] );
            End;
            CrLf;
          End
          Else Begin
            If ( Fnct_Key=F1 ) Then Edit_User
            Else If ( Fnct_Key = F2 ) Then Validate_New
            Else If ( Fnct_Key = F3 ) Then Show_Level
            Else If ( Fnct_Key = F5 ) Then Chat_Mode
            Else If ( Fnct_Key = F6 ) Then Toggle_Chat
            Else If ( Fnct_Key = F9 ) Then Show_Drives
            Else If ( Fnct_Key = F10 ) Then Term_Mode
            Else If ( Fnct_Key = Help_Key ) Then Show_Main_Help
            Else If ( Fnct_Key = SF10 ) Then Disconnect
            Else Show_Wrong; 
          End;
        End; {Case}
      End
      Else Begin
        Bell_C2;
        EchoSE( 'Sorry, you have ran out of time for this call...' );
        CrLf;
        DescL[1] := 'User Ran Out Of Time...';
        DescL[2] := ' ';
        Log( 0, 2 );
        Done := True;
      End;
    Until ( Done ) or ( No_Carrier );
    If ( No_Carrier ) Then Begin
      DescL[1] := 'Lost Carrier From User...';
      DescL[2] := ' ';
      Log( 0, 2 );
    End;
    CrLf;
    CrLf;
  End;

  Procedure Init_Data;
  Begin
    Trans[0] := 'Ascii  ';     Trans[1] := 'VT52 Mono';
    Trans[2] := 'VT52 Color';  Trans[3] := 'ANSI Mono ';
    Trans[4] := 'ANSI Color';

    XferT[0] := 'Xmodem';      XferT[1] := 'Xmodem Crc';
    XferT[2] := 'Xmodem-1k';   XferT[3] := 'Ymodem';
    XferT[4] := 'Zmodem';      XferT[5] := 'Ymodem-G';

    Prots[0] := 'X';  Prots[1] := 'C';   Prots[2] := 'K';
    Prots[3] := 'Y';  Prots[4] := 'Z';   Prots[5] := 'G';

    W_Color  := '7';  R_Color  := '1';  G_Color  := '2';
    Bk_Color := '0';  B_Color  := '0';

    Escp     := Chr( 27 );
    Prompt   := '>';
    Clk      := '|/-/';

    Month[0] := 'Fix ';
    Month[1] := 'Jan ';    Month[2] := 'Feb ';
    Month[3] := 'Mar ';    Month[4] := 'Apr ';
    Month[5] := 'May ';    Month[6] := 'Jun ';
    Month[7] := 'Jul ';    Month[8] := 'Aug ';
    Month[9] := 'Sep ';    Month[10] := 'Oct ';
    Month[11] := 'Nov ';   Month[12] := 'Dec ';

    Arc_Type[1] := 'ARC';  Arc_Type[2] := 'ARJ';
    Arc_Type[3] := 'LZH';  Arc_Type[4] := 'SIT';
    Arc_Type[5] := 'ZIP';  Arc_Type[6] := 'ZOO';

    Rating[1]:= 'Poor';        Rating[2]:= 'Fair';
    Rating[3]:= 'Good';        Rating[4]:= 'Very Good';
    Rating[5]:= 'Excellent';   Rating[6]:= 'Not Tested';

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
    Err[68]:= 'PathName Too Short!';
    Err[69]:= 'Invalid Drive In PathName!';
    Err[70]:= 'Unknown Error';

    Xyz[0] := 'XYZ.TTP Not Located In FTU Path...';
    Xyz[1] := 'Missing block number';
    Xyz[2] := 'Missing or bad header';
    Xyz[3] := 'Synchronization error';
    Xyz[4] := 'Timed out';
    Xyz[5] := 'Checksum error';
    Xyz[6] := 'User aborted';
    Xyz[7] := 'File error';
    Xyz[8] := 'Too many retries';
    Xyz[9] := 'CRC error';
    Xyz[10]:= 'Filename must be specified';
    Xyz[11]:= 'Bad escape character';
    Xyz[12]:= 'Bad or unsupported packet type';
    Xyz[13]:= 'Bad hexadecimal character';
    Xyz[14]:= 'Sender not ready or set to receive';
    Xyz[15]:= 'Subpacket too long';
    Xyz[16]:= 'Sender aborted';
    Xyz[17]:= 'File position error';
    Xyz[18]:= 'Sender indicates end of file, but file length is wrong';
    Xyz[19]:= 'Receiver canceled';
    Xyz[20]:= 'End of transmission not acknowledged';
    Xyz[21]:= 'Bad option on command line';
    Xyz[22]:= 'Not enough memory to allocate buffers';
    Xyz[23]:= 'Modem Carrier lost';
    Xyz[24]:= 'Batch mode disabled -- file skipped';

    ArcType[1] := ' Stored   ';   ArcType[2] := ' Packed   ';
    ArcType[3] := ' Squeezed ';   ArcType[4] := ' Crunched ';
    ArcType[5] := ' Squashed ';   ArcType[6] := ' <<Dir>>  ';
    ArcType[7] := ' Unknown  ';

    ZipType[1] := ' Stored   ';   ZipType[2] := ' Shrunk   ';
    ZipType[3] := ' Reduced1 ';   ZipType[4] := ' Reduced2 ';
    ZipType[5] := ' Reduced3 ';   ZipType[6] := ' Reduced4 ';
    ZipType[7] := ' Imploded ';   ZipType[8] := ' Deflated ';
    ZipType[9] := ' Unknown  ';

    SitType[1] := ' None     ';   SitType[2] := ' RLE      ';
    SitType[3] := ' LZW      ';   SitType[4] := ' Huffman  ';
    SitType[5] := ' * None   ';   SitType[6] := ' * RLE    ';
    SitType[7] := ' * LZW    ';   SitType[8] := ' * Huff   ';
    SitType[9] := ' <<Dir>>  ';   SitType[10]:= ' Unknown  ';
  End;

  Procedure About;
  Begin
    Clear_Screen;
    CrLf;
    EchoNE( '.___________________________________.' );
    EchoNE( '| Express BBS File Transfer Utility |' );
    EchoNE( '|   Version 2.44    May 10, 1996    |' );
    EchoNE( '|      Copyright (c) 1989-1996      |' );
    EchoNE( '|    Jay L. Bray - ToWaReS Inc.     |' );
    EchoNE( '|___________________________________|' );
    CrLf;
  End;

  Procedure Check_Key;
  Begin
    EchoCE( 'Checking FTU.KEY...' );
    If ( Security_Chk ) Then Begin
      Clear_Screen;
      Menu;
      UserAcs.Xmodem_Type := Protocol;
      Save_Ftu_User;
    {  Put_Usr( Addr( UserRec ), Usr_Addr, SizeOf( UserRec ) ); }
    End
    Else Begin
      DescL[1] := '****************************************************';
      DescL[2] := 'FTU HAS RAN BEYOND IT''S 90 DAY FREE TRIAL PERIOD!!!';
      DescL[3] := '****************************************************';
      Log( 1, 3 );
    End;
  End;

  Procedure Start_FTU;
  Begin
    About;
    If ( Get_SysData ) Then Begin
      If ( Get_Ftu_User ) Then Begin
        EchoCE( 'Checking SIG Access...' );
        Get_Sig_Access;
        W_Color := Chr( UserAcs.Colors[ 0 ] );
        R_Color := Chr( UserAcs.Colors[ 1 ] );
        G_Color := Chr( UserAcs.Colors[ 2 ] );
        B_Color := Chr( UserAcs.Colors[ 3 ] );
        Bk_Color:= Chr( UserAcs.Colors[ 16 ] );

        Protocol := UserAcs.Xmodem_Type;
        EchoCE( 'Displaying User Info...' );
        Show_UInfo;
        EchoCE( 'Displaying D/l-U/l Info...' );
        Show_DL_UL;
        Show_File( F_Name );
        CrLf;
        Caps := False;
        Dos_Mode   := False;
        Quick_Scan := False;
        Forced_Off := False;
        Valid_New  := False;
        Arc_Chose  := False;
        DescL[1] := ' ';
        DescL[2] := Concat( 'Entered FTU At: ', Mil_Time );
        Log( 0, 2 );
        Check_Key;  { And Run... }
        DescL[1] := Concat( 'Exited FTU At: ', Mil_Time );
        DescL[2] := ' ';
        Log( 0, 2 );
      End;
    End
    Else Begin
      DescL[1] := ' ';
      DescL[2] := Concat( 'Error Loading SysData File At: ', Mil_Time );
      Log( 1, 2 );
    End;
  End;

Begin
  EchoSE( 'Loading...' );
  Io_check( False );
  Rez := Get_Rez;
  SetDta( DTA_Data );
  Boot_Drv := CurDisk;
  GetDir( Boot_Path, 0 );
  Zero_Timer;
  Timeon := Get_Timr;
  BM_Num := 0;

  Shw_Time   := True;
  Local   := False;    Batch_Down := False;

  If ( Cmd_Args > 0 ) And ( Cmd_Args < 9 ) Then Begin
    DescL[1] := 'Invalid number of command line parameters.';
    DescL[2] := 'Usage:';
    DescL[3] := 'Ftu_2nn Offset Baud Version Chat Handle User# VW Time_Left Translation';
    DescL[4] := ' ';
    Log( 1, 4 );
    WriteLn( DescL[ 1 ] );  WriteLn( DescL[ 2 ] );  WriteLn( DescL[ 3 ] );
    Halt;
  End
  Else If ( Cmd_Args = 0 ) Then Begin
    Line    := '99999';  Baudrate := 'LOCAL';  BBS_Vers    := '999';
    Chat_On := 'OUT';    U_Handle    := 'SysOp';  Number      := '1';
    Width   := '80';     Time_Left   := '500';    Translation := '2';
  End
  Else If ( Cmd_Args = 9 ) Then Begin
    Cmd_Getarg( 1, Line );
    Cmd_Getarg( 2, Baudrate );
    Cmd_Getarg( 3, BBS_Vers );
    Cmd_Getarg( 4, Chat_On );
    Cmd_Getarg( 5, U_Handle );
    Cmd_Getarg( 6, Number );
    Cmd_Getarg( 7, Width );
    Cmd_Getarg( 8, Time_left );
    Cmd_Getarg( 9, Translation );  { 0= Ascii, 1 = Mono, 2 = Color }
  End;

  Shrink_Scrn( 5 );
  Clear_Screen;

  For M := 1 To Length( U_Handle ) Do Begin
    If ( U_Handle[ M ] = Chr(160) ) Then U_Handle[ M ] := ' ';
  End;

  If ( Chat_On = 'IN' ) Then Chat := True  Else Chat := False;

  Readv( Line, Ftu_Length );
  Readv( BBS_Vers, BBS_Version );
  If ( BBS_Version < 184 ) Then Begin
    If ( Baudrate = '19200' ) Then Local := True;
  End
  Else If ( BBS_Version >= 184 ) Then Begin
    If ( Baudrate = 'LOCAL' ) Then Begin
      Local := True;
      BaudRate := '76800';
    End;
  End;
  If ( Pos( '.', BaudRate ) >0 ) Then Begin
    Readv( Baudrate, Speed );
    Speed := ( Speed * 1000 );
    Writev( BaudRate, Speed );
  End;

  Readv( Baudrate, Speed );
  Cps := Int ( Speed Div 10 );

  Readv( Number, Usr_No );
  Readv( Width, WidT );
  Readv( Time_left, Minutes );
  Readv( Translation, Transv );
  Convert_Translation;

  Init_Data;
  Lin_Count := 0;
  Tot_DL_Time := 0;
  F_Name[1] := Chr( Ord( 'A' ) + Boot_Drv );
  F_Name[2] := ':' ;
  F_Name[0] := chr( 2 );
  MakePString( Boot_Path, Line );
  F_Name := Concat( F_Name, Line );
  F_Name := Concat( F_Name, '\' );
  Ftu_Path     := F_Name;
  Work_Path    := F_Name;
  Line         := F_Name;
  Ftu_UserFile := Concat( Line, 'ftu_data.usr' );
  Ftu_MaskFile := Concat( Line, 'ftu_data.msk' );
  Ftu_SigFile  := Concat( Line, 'ftu_data.sig' );
  Ftu_ErrFile  := Concat( Line, 'ftu.err' );
  Ftu_Out      := Concat( Line, 'ftu.Out' );
  Ftu_Xfr      := Concat( Line, 'ftu.Xfr' );
  Ftu_Menu     := Concat( Line, 'MENU\' );
  Key_File     := Concat( Line, 'ftu.key' );
  Show_Top5;
  Clear_Screen;
  Show_File( Ftu_Path );

  Init_200Hz;

  Find_User_Addr;
  If ( Usr_Addr > 65536 ) Then Start_FTU;
  Dummy_I := ChDir( Boot_Path );
  Io_check( True );
  Shrink_Scrn( 1 );

  Rstr_200Hz;

End.

