
  Procedure Do_Arc( Md : Integer );
  Var
    I,Ln : Integer;
    A_Path, C, E : CString;
    A,M,F : String;
  Begin
    File_Name := '';
    If ( Md In[ 1,4 ] ) Then Begin
      CrLf;
      EchoS( 'Enter Filename -> ' );
      Caps := True;  Line_In( F, 12 );
      If ( Length( F ) > 0 ) Then Begin
        If ( Filename_Ok( F ) ) Then Begin
          If Exists( F ) Then File_Name := F
          Else EchoSE( ' Sorry, That File Doesn''t Exist!!!' );
        End
        Else Begin
          EchoSE( '/r Illegal Filename.../b' );  CrLf;
        End;
      End;
    End;
    M := '';  Ln := Length( File_Name );
    A := System2.A_Path[ Arc_Kind ];
    Case Md Of
      1 : M := System2.A_Cmd[ Arc_Kind ];        { Add }
      2 : Begin                                  { Clear }
            MakeCString( Arc_FName, C );
            I := UnLink( C );
            If ( I < 0 ) Then Show_Error( Arc_FName, I );
          End;
      3 : Begin                                  { Download }
            If Exists( Arc_FName ) Then Download_File( Arc_FName, 10 )
          End;
      4 : M := System2.D_Cmd[ Arc_Kind ];         { Remove }
      5 : Begin                                   { View }
            File_Name := Arc_FName;  F_Name := File_Name;
            Test_Arc_File;
            If ( Arc_File ) Then View_Arc_File;
          End;
      6 : M := System2.T_Cmd[ Arc_Kind ];         { Test }
    End;
    If ( ( Md In[ 1,4 ] ) And ( Ln > 0 )) or ( Md = 6 ) Then Begin
      CrLf;
      M := Concat( M, ' ', Arc_FName );
      If ( Md In[ 1,4 ] ) Then M := Concat( M, ' ', File_Name );
      MakeCString( A, A_Path );  M := Concat( M, Chr( 0 ) );
      For I := 1 to Length( M ) Do C[ I ] := M[ I ];
      C[ 0 ] := Chr( Length( M ) - 1 );
      For I := 0 to 27 Do E[I] := Chr( 0 );
      I := Exec( 0, A_Path, C, E );
      If ( I < 0 ) Then Show_Error( A, I );
    End;
    CrLf;
  End;

  Procedure Get_Arc_Type;
  Var
    I : Integer;
    Ch : Char;
  Begin
    Arc_FName := Concat( System2.Temp_Pth, 'ARCHIVE.' );
    Clear_Screen;
    CrLf; EchoSE( 'Select Archive Method:' ); CrLf;
    EchoSE( '[1] ARC' );
    EchoSE( '[2] LZH' );
    EchoSE( '[3] ZIP' );
    CrLf;
    EchoS ( 'Choice (1-3) :> ' );
    I := Get_Number( 3 );
    If ( I > 0 ) Then Begin
      Arc_Chose := True;
      Arc_Kind  := I;
      Case I Of
        1 : Begin
              EchoSE( 'ARC' );
              Arc_FName := Concat( Arc_FName, 'ARC' );
            End;
        2 : Begin
              EchoSE( 'LZH' );
              Arc_FName := Concat( Arc_FName, 'LZH' );
            End;
        3 : Begin
              EchoSE( 'ZIP' );
              Arc_FName := Concat( Arc_FName, 'ZIP' );
            End;
      End; { Case }
    End
    Else Begin
      Arc_Chose := True;
      Arc_Kind  := 1;
      Arc_FName := Concat( Arc_FName, 'ARC' );
      EchoSE( 'Defaulted To ARC' );
    End;
  End;

  Procedure Arc_Utils;
  Var
    Ch : Char;
    Done : Boolean;
    X, Y : Integer;
    S : String;
  Begin
    CrLf;
    If ( Arc_Chose = False ) Then Get_Arc_Type;
    Repeat
      New_Line := False;
      EchoSE ( 'Archive Utility Options:' ); CrLf;
      S := ( '[/rA/b] Add A File To ARCHIVE.???' );       Show_40( S );
      S := ( '[/rC/b] Clear All Files In ARCHIVE.???' );  Show_40( S );
      S := ( '[/rD/b] Download ARCHIVE.???' );            Show_40( S );
      S := ( '[/rR/b] Remove File From ARCHIVE.???' );    Show_40( S );
      S := ( '[/rS/b] Set New Archive Type' );            Show_40( S );
      S := ( '[/rT/b] Test Archive' );                    Show_40( S );
      S := ( '[/rV/b] View File(s) In Archive' );         Show_40( S );
      CrLf;  CrLf;
      EchoS( 'Choice, [Return] To Exit :> ' );
      Repeat
        Ch := Get_Char;  Upper_C( Ch );  X := Ord( Ch );
      Until( Ch IN[ 'A','C','D','R'..'T','V' ] ) or ( No_Carrier ) or ( X = Cr );
      Case Ch of
        'A' : Begin EchoSE ( 'Add' );      Do_Arc( 1 ); End;
        'C' : Begin EchoSE ( 'Clear' );    Do_Arc( 2 ); End;
        'D' : Begin EchoSE ( 'Download' ); Do_Arc( 3 ); End;
        'R' : Begin EchoSE ( 'Remove' );   Do_Arc( 4 ); End;
        'S' : Begin EchoSE ( 'Set' );      Get_Arc_Type; End;
        'T' : Begin EchoSE ( 'Test' );     Do_Arc( 6 ); End;
        'V' : Begin EchoSE ( 'View' );     Do_Arc( 5 ); End;
      End;
    Until ( X = Cr ) or ( Carrier = False );
    CrLf;  CrLf;
  End;

