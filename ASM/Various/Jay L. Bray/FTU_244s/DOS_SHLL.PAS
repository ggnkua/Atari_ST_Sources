
  Procedure Split_Str( Var S, S1, S2 : String );
  Var
    X : Integer;
  Begin
    S1 := '';  S2 := '';
    X := Pos( ',',S );
    If ( X=0 ) Then X := Pos( ' ',S );
    If ( X>1 ) Then Begin
      S1 := Copy( S, 1, X-1 );
      If ( Length( S ) > X+1 ) Then S2 := Copy( S, X+1, Length( S ) - X );
      Strip_L( S1 );  Strip_L( S2 );
      Strip_T( S1 );  Strip_T( S2 );
    End
    Else S1 := S;
  End;

  Procedure Do_Directory( Var S:String );
  Var
  I,X,Y : Integer;
  F : String;
  FSize, FDate, FTime, FAtrb : String;
  Begin
    CrLf; CrLf;
    Abort := False;
    If ( S='' ) Then S := '*.*';
    Temp := Concat( Work_Path, S );
    FPath := Temp;
    Max_File;
    If ( FMax > 0 ) Then Begin
      FCnt := 0;
      For Y := 1 To FMax Do Begin
        X := F_Search( 1 );
        MakeFname( Dta_Data.Name, File_Name );
        AddSpaces( File_Name, 14 );
        Fatrb := '';
        I := DTA_Data.Attribute;
        If ( I & 16 ) <> 0 Then FAtrb := '/r<Dir>/b  '
        Else Begin
          If ( I & 1 ) <> 0  Then FAtrb := Concat( Fatrb, 'r' )
            Else FAtrb := Concat( FAtrb,' ' );
          If ( I & 2 ) <> 0 Then FAtrb := Concat( Fatrb, 'h' )
            Else FAtrb := Concat( FAtrb,' ' );
          If ( I & 4 ) <> 0 Then FAtrb := Concat( Fatrb, 's' )
            Else FAtrb := Concat( FAtrb,' ' );
          If ( I & 8 ) <> 0 Then FAtrb := Concat( Fatrb, 'v' )
            Else FAtrb := Concat( FAtrb,' ' );
          If ( I & 32 ) <> 0 Then FAtrb := Concat( Fatrb, 'a' )
            Else FAtrb := Concat( FAtrb,' ' );
          FAtrb := Concat( FAtrb,'  ' );
        End;
        Writev( FSize, DTA_Data.Size:6 );
        AddSpaces( FSize, 8 );
        Convert_Date( DTA_Data.Date ); FDate := Line;
        AddSpaces( FDate, 14 );
        Convert_Time( DTA_Data.Time ); FTime := Line;
        F := Concat( File_Name, FAtrb, FSize, FDate, FTime );
        EchoSE ( F );
      End;
    End;
    CrLf;
    Writev( S, 'Total of ', FMax, ' File(s)' );
    EchoSE( S );
    Abort := False;
  End;

  Procedure Move_File( Var In_File, Out_File :String );
  Var
    C : CString;
    X : Integer;
    Ok : Boolean;
  Begin
    MakeCString( In_File, C );  Ok := True;
    If ( Exists( Out_File ) ) Then Begin
      EchoS( '/rWARNING!/b Destination File Already Exists, Overwrite? ' );
      Ok := Yes_No( 'N' );
    End;
    If ( Ok ) Then Begin
      EchoS ( ' Moving ' );  EchoSE( In_File );
      EchoS ( ' To --> ' );  EchoSE( Out_File );
      Copy_File( In_File, Out_File, 0 );
      X := UnLink( C );
    End;
  End;

  Procedure Lock_File( Var S:String );
  Var
    X : Integer;
  Begin
    CrLf;
    MakeCString( S, FName );
    X := ChMode( FName, 1, 1 );
    If X<0 Then Show_Error( S, X)
    Else EchoSE( ' File Is Now /rLocked/b...' );
  End;

  Procedure UnLock_File( Var S:String );
  Var
    X : Integer;
  Begin
    CrLf;
    MakeCString( S, FName );
    X := ChMode( FName, 1, 0 );
    If X<0 Then Show_Error( S, X)
    Else EchoSE( ' File Is Now /gUnLocked/b...' );
  End;

  Procedure Make_Dir( Var S:String );
  Var
    C : CString;
    X : Integer;
  Begin
    S := Concat( S, Chr(0) );
    MakeCString( S, C );
    X := MkDir( C );
    Show_Error( S, X );
  End;

  Procedure Remove_Dir( Var S:String );
  Var
    C : CString;
    X : Integer;
  Begin
    S := Concat( S, Chr(0) );
    MakeCString( S, C );
    X := RmDir( C );
    Show_Error( S, X );
  End;

  Function Exec_TOS( S, C:String ): Integer;
  Var
    X : Integer;
    CL, E, Fil : CString;
  Begin
    Save5;
    Mouse_Off; Clear_Local; CursConf( 1, 100 );
    For X := 0 to 31 Do  E[X] := Chr(0); C := Concat( C, Chr(0) );
    MakeCString( S, Fil );
    MakeCString( C, CL );
    X := Exec( 0, Fil, CL, E );
    If ( X < 0 ) Then Show_Error( S, X );
    Mouse_Off; CursConf( 1, 100 );
    Exec_TOS := X;
    Rest5;  Show_Top5;  Clear_Local;
  End;

  Function Exec_GEM( S, C:String ): Integer;
  Var
    X : Integer;
    CL, E, Fil : CString;
  Begin
    Save5;
    Clear_Local; CursConf( 0, 100 ); Mouse_On;
    For X := 0 to 31 Do  E[X] := Chr(0); C := Concat( C, Chr(0) );
    MakeCString( S, Fil );
    MakeCString( C, CL );
    X := Exec( 0, Fil, CL, E ); If ( X < 0 ) Then Show_Error( S, X );
    Mouse_Off; CursConf( 1, 100 );
    Exec_GEM := X;
    Rest5;  Show_Top5;  Clear_Local;
  End;

  Procedure Show_Dos_Cmnds;
  Begin
    View_Menu( 'DOS.MNU' )
  End;

  Procedure Dos_Shell;
  Var
    L,S,S1,S2 : String;
    Dc,Ln,X : Integer;
    Ch : Char;
    Use_D, Done : Boolean;
  Begin
    Dos_Mode := True;  Use_D := Use_Desc;  Use_Desc := True;
    Ch := Chr( Boot_Drv + 65 );  X  := Change_Drive( Ch );
    Done := False;  Drv := Boot_Drv;
    CrLf;
    Repeat
      CrLf;
      S := Concat( '/b[/r',Work_Path,'/b]-> ' );  EchoS( S );
      Line_In( L, 80 );
      If ( L[2]=':' ) And ( Length( L ) =2 ) Then Begin
        Ln := 2;  Dc := 1;
      End
      Else Begin
        X := Dos_Cmnd( Addr_Str( L ) );  Dc := X & 255;  Ln := Shr( X, 8 );
      End;
      If ( Dc>0 ) Then Begin
        If ( Ln < Length( L ) ) Then Begin
          S := Copy( L, Ln + 1, Length( L ) - Ln );
          Strip_L( S );  Strip_T( S );
        End
        Else S := ''; 
        F_Name := S; File_Name := S;  Ch := L[1];
        Case Dc Of
           1 : X := Change_Drive( Ch );
           2 : Do_Directory( S );
           3 : Change_Dir( S );
           4 : Make_Dir( S );
           5 : Remove_Dir( S );
           6 : Begin
                 Ch := S[ 6 ];  Show_DFree( Ch );
               End;
           7 : Begin          { TOS }
                 Split_Str( S, S1,S2 );  X := Exec_TOS( S1,S2 );
               End;
           8 : Begin          { GEM }
                 Split_Str( S, S1,S2 );  X := Exec_GEM( S1,S2 );
               End;
           9 : Begin
                 Split_Str( S, S1,S2 );  Copy_File( S1,S2,0 );
               End;
          10 : Begin
                 Split_Str( S, S1,S2 );  Move_File( S1,S2 );
               End;
          11 : Begin
                 CrLf;  CrLf;  Read_File;
               End;
          12 : Begin
                 Split_Str( S, S1,S2 );  Rename_A_File( S1,S2 );
               End;
          13 : X := Delete_File( S );
          14 : DT_Stamp( S );
          15 : Begin
                 Desc_Path := S;
                 Get_Description( 99 );
                 Edit_Description( 1 );
               End;
          16 : Begin  CrLf;  Validate_New; End;
          17 : Upload_A_File;
          18 : Download_A_File;
          19 : If Exists( S ) Then List_Arc( S );
          20 : If Exists( S ) Then List_Arj( S );
          21 : If Exists( S ) Then List_Lzh( S );
          22 : If Exists( S ) Then List_Sit( S );
          23 : If Exists( S ) Then List_Zip( S );
          24 : If Exists( S ) Then List_Zoo( S );
          25 : Begin
                 Get_Free_Mem;
                 WriteV( S, ' TOS Free Memory = ', Sys_Mem, ' Bytes' );
                 EchoSE( S );
               End;
          26 : Show_Dos_Cmnds;
          27 : Done := True;    { eXit }
          28 : Clear_Local;
          29 : Lock_File( S );
          30 : UnLock_File( S );
        End;
      End
      Else EchoSE( ' <-- Invalid Command!!!' );
    Until ( Done ) or ( Carrier=False );
    CrLf;  CrLf;
    Dos_Mode := False;  Use_Desc := Use_D;
  End;

