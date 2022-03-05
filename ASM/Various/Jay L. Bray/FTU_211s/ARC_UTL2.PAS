
	Procedure Arc_Menu;
	Var
		S : String;
	Begin
		New_Line := False;
		EchoSE ( 'Archive Utility Options:' ); CrLf;
		S := ( '[\rA\b] Add A File To ARC_FILE.???' );       Show_40( S );
		S := ( '[\rC\b] Clear All Files In ARC_FILE.???' );  Show_40( S );
		S := ( '[\rT\b] Type A File From Archive' );         Show_40( S );
		S := ( '[\rR\b] Remove File(s) From ARC_FILE.???' ); Show_40( S );
		S := ( '[\rV\b] View File(s) In Archive' );          Show_40( S );
		CrLf;  CrLf;
		EchoS( 'Choice, [Return] To Exit :> ' );
	End;

	Procedure Do_Arc( Md : Integer );
	Var
		Typ : Integer;
		Ch : Char;
		Ok : Boolean;
	Begin
		Ok := False;
		CLear_Screen;
		CrLf; EchoSE( 'Select Archive Method:' ); CrLf;
		EchoSE( '[1] ARC' );  EchoSE( '[2] ARJ' );
		EchoSE( '[3] LZH' );  EchoSE( '[4] ZIP' );
		EchoSE( '[5] ZOO' );
		CrLf;
		EchoS ( 'Choice :> ' );
		Repeat
			Ch := Get_Char;  If ( Ch In[ '1'..'5' ] ) Then Ok := True;
		Until ( Ok ) or ( Carrier = False );
		If ( OK ) Then Begin
			Typ := Ord( Ch ) - 48;
			Exec_Archive( Typ );
		End;
	End;

	Procedure Arc_Utils;
	Var
		Choice : Char;
		Done : Boolean;
		X, Y : Integer;
	Begin
		New_Line := False;
		Clear_Screen;
		Repeat
			Arc_Menu;
			Choice := Get_Char;  Upper_C( Choice );  X := Ord( Choice );
			Case Choice of
				'A' : Begin EchoSE ( 'Add' );    Do_Arc( 1 ); End;
				'C' : Begin EchoSE ( 'Clear' );  Do_Arc( 2 ); End;
				'T' : Begin EchoSE ( 'Type' );   Do_Arc( 3 ); End;
				'R' : Begin EchoSE ( 'Remove' ); Do_Arc( 4 ); End;
				'V' : Begin EchoSE ( 'View' );   Do_Arc( 5 ); End;
			End;
		Until ( X = Cr ) or ( Carrier=False );
		CrLf;
	End;

	Procedure Exec_Archive( Typ : Integer );
	Var
		I : Integer;
		A_Path, C, E : CString;
		A : String;
	Begin
		If ( Typ = 1 ) Then A := Arc_Path
		Else If ( Typ = 2 ) Then A := Arj_Path
		Else If ( Typ = 3 ) Then A := Lzh_Path
		Else If ( Typ = 4 ) Then A := Zip_Path
		Else A := Zoo_Path;
		MakeCString( A, A_Path );  MakeCString( Cmd_Line, C );
		For I := 0 to 27 Do E[I] := Chr( 0 );
		I := Exec( 0, A_Path, C, E );
		If ( I<0 ) Then Show_Error( A, I );
	End;

