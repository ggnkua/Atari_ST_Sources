{$S8}
Program UPDT_USR;

{$I AuxSubs.Pas}

Type
  CString   = Packed Array[0..80] Of Char;

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
     Phone_number   : String [15];
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
     Sig_Scan       : Long_Integer;
   End;

  UserAccess_Old = Packed Record
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

  UserAccess_New = Packed Record
    User_Mask  : Packed Array[ 1..8 ] of Long_Integer;
    Sig_Accs   : Packed Array[ 1..8 ] of Long_Integer;
    Sig_Valid  : Packed Array[ 1..8 ] of Long_Integer;
    Sig_Edit   : Packed Array[ 1..8 ] of Long_Integer;
    Sig_Kill   : Packed Array[ 1..8 ] of Long_Integer;
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
    Colors     : Packed Array [ 1..16 ] Of Integer;
  End;

Var

  System2 : SigData2;
  UserRec : Userdata;           { the user's userlog file entry      }
  UserNew : UserAccess_New;
  UserOld : UserAccess_Old;

  Function FRead_Sys2( H:Integer; Count:Long_Integer; Var S:SigData2 ):Long_Integer;
  Gemdos( $3F );

  Function FRead_Usr( H:Integer; Count:Long_Integer; Var S:UserData):Long_Integer;
  Gemdos( $3F );

  Function FRead_UsrO(H:Integer; Count:Long_Integer; Var S:UserAccess_Old):Long_Integer;
  Gemdos( $3F );

  Function FWrite_UsrN(H:Integer; Count:Long_Integer; Var S:UserAccess_New):Long_Integer;
  Gemdos( $40 );

  Function Fseek( Where : Long_Integer ; FHandle, Mode: Integer ):Long_Integer;
    Gemdos($42); { Mode: 0=From Start, 1=from current pos, 2=from End }  

  Function FReName( X:Integer; Var OldName:Cstring; Var NewName:Cstring ):Long_Integer;
    Gemdos( $56 );

  Procedure MakeCstring( Source: String; Var Dest: Cstring );
  Var
    X : Integer;
  Begin
    For X := 1 To Length( Source ) Do Dest[X - 1] := Source[X];
    X := Length( Source );
    Dest[X] := Chr( 0 );
  End;

  Procedure Get_SysData;
  Var
    FtuData : String;
    Sigdatafile : text;
    I, J : Integer;
    Ch : Char;
    Count : Long_Integer;
  Begin
    FtuData := 'FTU_DATA.SIG';
    Reset( Sigdatafile, FtuData );
    Count := Fseek( 0, Handle( SigdataFile ),  0 );
    Count := FRead_Sys2( handle( sigdatafile ),  sizeof( system2 ),  System2 );
    Close( Sigdatafile );
  End;

  Procedure Make_New;
  Var
    Usrdata  : text;
    UsrdataN : text;
    UsrdataO : text;
    OldN, NewN : CString;
    F : String;
    I : Integer;
    X, Count : Long_Integer;
  Begin
    Get_SysData;
    Reset( UsrdataO, 'ftu_data.usr' );
    Count := Fseek( 0, Handle( UsrdataO ), 2 );
    X := ( Count Div SizeOf( UserOld ) );
    Close( UsrDataO );

    WriteLn;
    WriteLn( 'Converting ', X, ' Users...' );
    WriteLn;

    Rewrite( UsrdataN, 'ftu_data.usx' );
    Count := Fseek( 0, Handle( UsrdataN ), 0);

    F := System2.UserLog;
    Reset( Usrdata , F );
    Count := Fseek( 0, Handle( Usrdata ), 0);

    Reset( UsrdataO, 'ftu_data.usr' );
    Count := Fseek( 0, Handle( UsrdataO ), 0);
    Count := FRead_Usr ( Handle( Usrdata ), Sizeof( UserRec ), UserRec );

    For I := 1 to X Do Begin
      Count := FRead_Usr ( Handle( Usrdata ), Sizeof( UserRec ), UserRec );
      Count := FRead_UsrO( Handle( UsrdataO), Sizeof( UserOld ), UserOld );
      UserNew.User_Mask  :=  UserOld.User_Mask;
      UserNew.Sig_Accs   :=  UserOld.Sig_Accs;
      UserNew.Sig_Valid  :=  UserOld.Sig_Valid;
      UserNew.Sig_Edit   :=  UserOld.Sig_Edit;
      UserNew.Sig_Kill   :=  UserOld.Sig_Kill;
      UserNew.XModem_Type:=  UserRec.XModem_Type;
      UserNew.Downloads  :=  UserRec.Downloads;
      UserNew.Uploads    :=  UserRec.Uploads;
      UserNew.K_Dnld     :=  UserOld.K_Dnld;
      UserNew.K_Dnld     :=  UserOld.K_Dnld;
      UserNew.K_Upld     :=  UserOld.K_Upld;
      UserNew.Pts_Dnld   :=  UserOld.Pts_Dnld;
      UserNew.Pts_Upld   :=  UserOld.Pts_Upld;
      UserNew.DL_Ratio   :=  UserRec.DL_Ratio;
      UserNew.K_Ratio    :=  UserOld.K_Ratio;
      UserNew.Pts_Ratio  :=  UserOld.Pts_Ratio;
      UserNew.Ratio_Typ  :=  UserOld.Ratio_Typ;
      UserNew.Colors[ 1 ]:= 49;  UserNew.Colors[ 2 ]:= 50;
      UserNew.Colors[ 3 ]:= 48;  UserNew.Colors[ 4 ]:=  0;
      UserNew.Colors[ 5 ]:=  0;  UserNew.Colors[ 6 ]:=  0;
      UserNew.Colors[ 7 ]:=  0;  UserNew.Colors[ 8 ]:=  0;
      UserNew.Colors[ 9 ]:=  0;  UserNew.Colors[ 10]:=  0;
      UserNew.Colors[ 11]:=  0;  UserNew.Colors[ 12]:=  0;
      UserNew.Colors[ 13]:=  0;  UserNew.Colors[ 14]:=  0;
      UserNew.Colors[ 15]:=  0;  UserNew.Colors[ 16]:=  0;

 {    WriteLn( UserRec.Downloads  ,'  ', UserNew.Downloads );
      WriteLn( UserRec.DL_Ratio    ,'  ', UserNew.Dl_Ratio );
      WriteLn( UserRec.Uploads  ,'  ',   UserNew.Uploads );  }

      Count := FWrite_UsrN( Handle(UsrdataN), SizeOf(UserNew), UserNew );
    End;
    Close( UsrData  );
    Close( UsrDataO );
    Close( UsrDataN );

    Rewrite( UsrdataN, 'ftu_data.msx' );
    Count := Fseek( 0, Handle(UsrdataN), 0);
    Reset( UsrdataO, 'ftu_data.msk' );
    Count := Fseek( 0, Handle(UsrdataO), 0);
    For I := 1 to 10 Do Begin
      Count := FRead_UsrO( Handle( UsrdataO ), Sizeof( UserOld ), UserOld );
      UserNew.User_Mask :=  UserOld.User_Mask;
      UserNew.Sig_Accs  :=  UserOld.Sig_Accs;
      UserNew.Sig_Valid :=  UserOld.Sig_Valid;
      UserNew.Sig_Edit  :=  UserOld.Sig_Edit;
      UserNew.Sig_Kill  :=  UserOld.Sig_Kill;
      UserNew.XModem_Type:=  0;
      UserNew.Downloads :=   0;
      UserNew.Uploads   :=   0;
      UserNew.K_Dnld    :=  UserOld.K_Dnld;
      UserNew.K_Dnld    :=  UserOld.K_Dnld;
      UserNew.K_Upld    :=  UserOld.K_Upld;
      UserNew.Pts_Dnld  :=  UserOld.Pts_Dnld;
      UserNew.Pts_Upld  :=  UserOld.Pts_Upld;
      UserNew.DL_Ratio  :=  UserOld.DL_Ratio;
      UserNew.K_Ratio   :=  UserOld.K_Ratio;
      UserNew.Pts_Ratio :=  UserOld.Pts_Ratio;
      UserNew.Ratio_Typ :=  UserOld.Ratio_Typ;
      Count := FWrite_UsrN( Handle(UsrdataN), SizeOf(UserNew), UserNew );
    End;
    Close( UsrDataO );
    Close( UsrDataN );

    MakeCstring( 'Ftu_Data.Usr', OldN );
    MakeCstring( 'Ftu_Data.Ubk', NewN );
    X := FRename( 0, OldN, NewN );

    MakeCstring( 'Ftu_Data.Usx', OldN );
    MakeCstring( 'Ftu_Data.Usr', NewN );
    X := FRename( 0, OldN, NewN );

    MakeCstring( 'Ftu_Data.Msk', OldN );
    MakeCstring( 'Ftu_Data.Mbk', NewN );
    X := FRename( 0, OldN, NewN );

    MakeCstring( 'Ftu_Data.Msx', OldN );
    MakeCstring( 'Ftu_Data.Msk', NewN );
    X := FRename( 0, OldN, NewN );

  End;

Begin                     (* Main Program Begins Here... *)
  Make_New;
End.

