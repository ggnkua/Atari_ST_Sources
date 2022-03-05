{E+}
(* ---------------------------------------- *)
(* --        F-Mail Read & Send          -- *)
(* ---------------------------------------- *)

Var
	Usr_Cnt   : Integer;


	Procedure Valid_User( Var U : String );
	Begin
	End;

	Procedure Add_User( Var U : String );
	Begin
		Usr_Cnt := Usr_Cnt + 1;
		FMail_User[Usr_Cnt] := U;
	End;

	Procedure Send_Fmail;
	Label
		100;
	Var
		Count : Integer;
		Hndl  : String;
		FMail : String;
		Done  : Boolean;
		Ch    : Char;
	Begin
		Done := False;
		Repeat
			CrLf;
			EchoS( 'Enter User's Handle -> ' );
			Line_In( Hndl, 15 );
			If (Valid_User( Hndl ) ) Then Add_User( Hndl )
				Else EchoSE( ' That User Doesn't Exist!' );
			EchoS( 'Send Same File To Another User? (y/N) ' );
			Ch := Get_Char;
			Ch := Upper_C( Ch );
			If (Ch='Y') Then Goto 100
				Else Done := True;
		Until (Done) or (Carrier=False);
		CrLf;
		EchoS( 'Enter Filename Of F-Mail -> ' );
		Line_In( Fmail, 12 );
		If (Valid_File( FMail ) ) Then Begin
			Upload_File;
			Get_Description;
			CrLf;
			EchoSE( 'User(s) Will Be Notified Of Their F-Mail...' );
		End;
	End;

	Procedure Send_This_Fmail;
	Var
	Begin
	End;

	Function Check_4_FMail: Integer;
	 Var
			X, Count : Integer;
			S : MaxString;
			U : MaxCString;
		Begin
			Count := 0;
			Writev( S, 'F:\BBS\F_MAIL\USR_', Userdata.User_No, '.*' );
			MakeCString( S, U );
			X := SFirst( U );
			If X > 0 Then Count := 1;
			Repeat
				X := SNext;
				If X > 0 Then Count := Count + 1;
			Until X < 0;
		End;

	Procedure Read_FMail;
	 Var
			X : Integer;
			S : MaxString;
			U : MaxCString;
		Begin
			Writev( S, 'F:\BBS\F_MAIL\USR_', Userdata.User_No, '.*' );
			MakeCString( S, U );
			X := SFirst( U );
			If X > 0 Then Send_This_FMail;
			Repeat
				X := SNext;
				If X > 0 Then Send_This_FMail;
			Until X < 0;
		End;

	Procedure F_Mail( Md: Integer);
	Var
		Ch : Char;
		X  : Integer;
		Done : Boolean;
	Begin
		CrLf;
		Done := False;
		Repeat
			If (Md=0) Then Begin
				EchoSE( ' [R]ead Your F-Mail' );
				EchoSE( ' [S]end F-Mail to User' );
				CrLf;
				EchoS( ' Choice -> ' );
				Ch := Get_Char;
				Ch := Upper_C( Ch );
			End
				Else Ch := 'R';
			Case Ch of:
				'R' : Begin
								EchoSE( ' Read F-Mail' );
								X := Check_4_FMail;
								If X > 0 Then Read_FMail
									Else EchoSE( ' Sorry, No F-Mail Today...' );
							End;
				'S' : Begin
								EchoSE( ' Send F-Mail' );
								Send_FMail;
							End;
			End;  { Case }
			If Ord( Ch ) = Cr Then Done := True;
		Until (Done) or (Carrier=False) or (Md>0);
	End;

