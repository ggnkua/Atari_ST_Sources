{$M+,$E+}
Program Edit_Usr;

{$I Auxsubs.Pas}
{$I Gemsubs.Pas}

Const
{$I BBS_Con.Pas}

Type
{$I BBS_Type.Pas}

Var
{$I BBS_Var.Pas}

	Procedure Convert_User; External;
	Procedure Show_40( S:String ); External;
	Function Get_Console: Integer; External;
	Function Get_Char: Char; External;
	Procedure Line_In( Var S:String; X:Integer ); External;
	Procedure Upper_C( Var Ch:Char ); External;
	Procedure Clr_Scr; External;
	Procedure CrLf; External;
	Procedure EchoS ( S:String ); External;
	Procedure EchoSE( S:String ); External;
	Procedure EchoN ( S:String ); External;
	Procedure EchoNE( S:String ); External;
	Function Get_Number( X:Integer ): Integer; External;
	Function Yes_No( Ch:Char ): Boolean; External;
	Function Carrier: Boolean; External;
	Procedure Back_Space; External;

	Procedure Show_User_Info;
	Var
		S : String;
	Begin
		Convert_User;
		Clr_Scr;
		S := 'Users Status Is '; If ( UserRec.In_Use ) Then S := Concat( S, '  ^gACTIVE^b  ' )
		Else S := Concat( S, '  ^rINACTIVE^b  ' ); Show_40( S );
		S := 'This Is A '; If ( UserRec.New_User ) Then S := Concat( S, '  ^rNEW^b User' )
		Else S := Concat( S, '  ^gVALIDATED^b User' ); Show_40( S );
		CrLf;
		S := Concat( '[A] First Name    : ',UserRec.First_Name ); Show_40( S );
		S := Concat( '[B] Last  Name    : ',UserRec.Last_Name );  Show_40( S );
		S := Concat( '[C] Handle        : ',User_Handle );
		If Ord( S[0] ) > 37 Then S[0] := Chr( 38 );               Show_40( S );
		S := Concat( '[D] Address       : ',User_Addr );       Show_40( S );
		S := Concat( '[E] City          : ',User_City );       Show_40( S );
		S := Concat( '[F] State         : ',User_State );      Show_40( S );
		S := Concat( '[G] Country       : ',User_Country );    Show_40( S );
		S := Concat( '[H] Zip Code      : ',User_Zip );        Show_40( S );
		S := Concat( '[I] Phone Number  : ',User_Phone );  Show_40( S );
		S := Concat( '[J] Computer Type : ',User_Cpu ); Show_40( S );
		S := Concat( '[K] Password      : ',UserRec.PWord );      Show_40( S );
		S := Concat( '[L] Last Called   : ',UserRec.Last_Call_Date ); Show_40( S );
		S := Concat( '[M] Birth Day     : ',UserRec.Birth_Day );  Show_40( S );

		Writev( S, UserRec.Age );           S := Concat( '[N] Current Age   : ', S );
		Show_40( S );
		Writev( S, UserRec.Calls_Per_Day ); S := Concat( '[O] Calls Per Day : ', S );
		Show_40( S );
		Writev( S, UserRec.Calls_Today );   S := Concat( '[P] Calls Today   : ', S );
		Show_40( S );
		Writev( S, UserRec.Total_Calls );   S := Concat( '[Q] Total Calls   : ', S );
		Show_40( S );
		Writev( S, UserRec.Max_Time_Call ); S := Concat( '[R] Max Time/Call : ', S );
		Show_40( S );
		Writev( S, UserRec.Max_Time_Day );  S := Concat( '[S] Max Time/Day  : ', S );
		Show_40( S );
		Writev( S, UserRec.Mins_Today );    S := Concat( '[T] Min Used Today: ', S );
		Show_40( S );
		Writev( S, UserRec.Dl_Ratio );      S := Concat( '[U] Download Ratio: ', S );
		Show_40( S );
		Writev( S, UserRec.Uploads );       S := Concat( '[V] Uploads       : ', S );
		Show_40( S );
		Writev( S, UserRec.Downloads );     S := Concat( '[W] Downloads     : ', S );
		Show_40( S );
		Writev( S, UserRec.Hi_Msg_Read );   S := Concat( '[X] High Msg Read : ', S );
		Show_40( S );
		Writev( S, UserRec.Msgs_Posted );   S := Concat( '[Y] Msgs Posted   : ', S );
		Show_40( S );
		Writev( S, UserRec.Msgs_Replied );  S := Concat( '[Z] Msgs Replied  : ', S );
		Show_40( S );
		Writev( S, UserRec.Emails_Sent );   S := Concat( '[1] Emails Sent   : ', S );
		Show_40( S );
		Writev( S, UserRec.Fmails_Sent );   S := Concat( '[2] Fmails Sent   : ', S );
		Show_40( S );

		Writev( S, UserRec.Video_Width );   S := Concat( '[3] Video Width   : ', S );
		Show_40( S );
		S := Concat( '[4] Translation   : ', Trans[ UserRec.Translation ] );
		Show_40( S );
		If ( UserRec.Colour ) Then S := 'YES' Else S := 'NO';
		S := Concat( '[5] Color Enabled : ', S );
		Show_40( S );
		S := Concat( '[6] Xfer Protocol : ', Xfer[ UserRec.Xfer_Protocol ] );
		Show_40( S );
		S := '[/] Toggles Active/Inactive Status';
		Show_40( S );
		S := '[*] Toggles New User Status';
		Show_40( S );
	End;

	Procedure Edit_User_Info;
	Var
		S : String;
		Ch : Char;
		I : Integer;
	Begin
		Show_User_Info;
		Repeat
			CrLf;
			EchoS( 'Enter Item To Edit, [Return] to Exit, or ''?'' to Display User Info > ' );
			Repeat
				Ch := Get_Char;
				Upper_C( Ch );
				I := Ord(Ch);
			Until ( Ch In ['A'..'Z'] ) or ( Ch In ['1'..'6'] ) or ( Ch='?' )
				Or ( Ch='/') or ( Ch='*' ) or ( ord( Ch ) = Cr ) or ( Carrier=False );
			CrLf;
			CrLf;
			Case Ch Of
				'A' : Begin EchoS( 'Enter New First Name > ' ); Line_In( S, 15 ); UserRec.First_Name := S; End;
				'B' : Begin EchoS( 'Enter New Last Name > ' ); Line_In( S, 15 ); UserRec.Last_Name := S; End;
				'C' : Begin EchoS( 'Enter New Handle > ' ); Line_In( S, 31 ); UserRec.UHandle := S; End;
				'D' : Begin EchoS( 'Enter New Address > ' ); Line_In( S, 25 ); UserRec.Addr := S; End;
				'E' : Begin EchoS( 'Enter New City > ' ); Line_In( S, 20 ); UserRec.City := S; End;
				'F' : Begin EchoS( 'Enter New State > ' ); Line_In( S, 2 ); UserRec.State := S; End;
				'G' : Begin EchoS( 'Enter New Country > ' ); Line_In( S, 15 ); UserRec.Country := S; End;
				'H' : Begin EchoS( 'Enter New Zip Code > ' ); Line_In( S, 10 ); UserRec.Zip := S; End;
				'I' : Begin EchoS( 'Enter New Phone Number > ' ); Line_In( S, 15 ); UserRec.Phone_number := S; End;
				'J' : Begin EchoS( 'Enter New Computer Type > ' ); Line_In( S, 15 ); UserRec.Computer_Type := S; End;
				'K' : Begin EchoS( 'Enter New Password > ' ); Line_In( S, 15 ); UserRec.Pword := S; End;
				'L' : Begin EchoS( 'Enter New Date Last Called as MMDDYY > ' ); Line_In( S, 6 ); UserRec.Last_Call_Date := S; End;
				'M' : Begin EchoS( 'Enter New Birth Day as MMDDYY > ' ); Line_In( S, 6 ); UserRec.Birth_Day := S; End;
				'N' : Begin EchoS( 'Enter New Age ( 128 max ) > ' ); UserRec.Age           := Get_Number( 128 ); End;
				'O' : Begin EchoS( 'Enter New Calls Per Day ( 32767 max ) > ' ); UserRec.Calls_Per_Day := Get_Number( 32767 ); End;
				'P' : Begin EchoS( 'Enter New Calls Today ( 32767 max ) > ' ); UserRec.Calls_Today   := Get_Number( 32767 ); End;
				'Q' : Begin EchoS( 'Enter New Total Calls ( 65535 max ) > ' ); UserRec.Total_Calls   := Get_Number( 65535 ); End;
				'R' : Begin EchoS( 'Enter New Max Time Per Call  ( 32767 max ) > ' ); UserRec.Max_Time_Call := Get_Number( 32767 ); End;
				'S' : Begin EchoS( 'Enter New Max Time Per Day ( 65535 max ) > ' ); UserRec.Max_Time_Day  := Get_Number( 65535 ); End;
				'T' : Begin EchoS( 'Enter New Minutes Today ( 32767 max ) > ' ); UserRec.Mins_Today    := Get_Number( 32767 ); End;
				'U' : Begin EchoS( 'Enter New DL Ratio ( 32767 max ) > ' ); UserRec.Dl_Ratio      := Get_Number( 32767 ); End;
				'V' : Begin EchoS( 'Enter New Uploads ( 65535 max ) > ' ); UserRec.Uploads       := Get_Number( 65535 ); End;
				'W' : Begin EchoS( 'Enter New Downloads ( 65535  max ) > ' ); UserRec.Downloads     := Get_Number( 65535 ); End;
				'X' : Begin EchoS( 'Enter New High Msg Read( 65535 max ) > ' ); UserRec.Hi_Msg_Read   := Get_Number( 65535 ); End;
				'Y' : Begin EchoS( 'Enter New Msgs Posted ( 65535 max ) > ' ); UserRec.Msgs_Posted   := Get_Number( 65535 ); End;
				'Z' : Begin EchoS( 'Enter New Msgs Replied ( 65535 max ) > ' ); UserRec.Msgs_Replied  := Get_Number( 65535 ); End;
				'1' : Begin EchoS( 'Enter New Emails Sent ( 65535 max ) > ' ); UserRec.Emails_Sent   := Get_Number( 65535 ); End;
				'2' : Begin EchoS( 'Enter New Fmails Sent ( 65535 max ) > ' ); UserRec.Fmails_Sent   := Get_Number( 65535 ); End;
				'3' : Begin EchoS( 'Enter New Video Width ( 80 max ) > ' ); UserRec.Video_Width   := Get_Number( 80 ); End;
				'4' : Begin
								Clr_Scr;
								CrLf; EchoNE( 'Translation Selections' ); Crlf;
								For I := 1 to 5 Do Begin
									S := Concat( '[',Chr( I + 48 ),'] ', Trans[I-1] );
									EchoNE( S );
								End;
								EchoN( 'Enter New Translation ( 5 max ) > ' );
								UserRec.Translation := Get_Number( 5 ) - 1;
							End;
				'5' : Begin
								EchoS( 'Can User Support Color Text ? ' );
								UserRec.Colour := Yes_No( 'Y' );
							End;
				'6' : Begin
								Clr_Scr;
								CrLf; EchoNE( 'Tranfer Protocols Available' ); Crlf;
								For I := 1 to 5 Do Begin
									S := Concat( '[',Chr( I + 48 ),'] ', Xfer[I-1] );
									EchoNE( S );
								End;
								EchoN( 'Enter New Xfer Protocol ( 5  max ) > ' );
								UserRec.Xfer_Protocol := Get_Number( 5 ) - 1;
							End;
				'*' : Begin
								UserRec.New_User := Not UserRec.New_User;
								S := 'User Is Now ';
								If ( UserRec.New_User ) Then S := Concat( S, 'A NEW USER...' )
									Else S := Concat( S, 'A VALIDATED USER...' );
								EchoNE( S );
							End;
				'/' : Begin
								UserRec.In_Use := Not UserRec.In_Use;
								S := 'User Is Now ';
								If ( UserRec.In_Use ) Then S := Concat( S, 'ACTIVE...' )
									Else S := Concat( S, 'INACTIVE...' );
								EchoNE( S );
							End;
				'?' : Show_User_Info;
			End; { Case }
		Until ( Ord( Ch ) = Cr ) or ( Carrier = False );
	End;

	Procedure Edit_64_Sigs( Var Msg:String; C:Integer );
	Var
		S : String;
		Ch,C2 : Char;
		Done : Boolean;
		X,Y,I : Integer;
		V, Bit : Long_Integer;
	Begin
		C2 := Chr( C + 48 );
		Repeat
			Mesgl[1] := Descl[1];
			Mesgl[2] := Descl[2];
			Mesgl[3] := Descl[3];
			Mesgl[4] := Descl[4];
			Mesgl[5] := Descl[5];
			Mesgl[6] := Descl[6];
			Bit := 1;
			X := 32;
			V := $80000000;
			For I := 1 to 32 Do Begin
				If (Sa1 & Bit>0) or (Sa1 & Bit=V) Then Mesgl[1] := Concat( MesgL[1], 'Y' )
					Else Mesgl[1] := Concat( MesgL[1], '.' );
				If ( C>1 ) Then Begin
					If (Sb1 & Bit>0) or (Sb1 & Bit=V) Then Mesgl[2] := Concat( MesgL[2], 'Y' )
						Else Mesgl[2] := Concat( MesgL[2], '.' );
				End;
				If ( C>2 ) Then Begin
					If (Sc1 & Bit>0) or (Sc1 & Bit=V) Then Mesgl[3] := Concat( MesgL[3], 'Y' )
						Else Mesgl[3] := Concat( MesgL[3], '.' );
				End;
				If ( C>3 ) Then Begin
					If (Sd1 & Bit>0) or (Sd1 & Bit=V) Then Mesgl[4] := Concat( MesgL[4], 'Y' )
						Else Mesgl[4] := Concat( MesgL[4], '.' );
				End;
				If ( C>4 ) Then Begin
					If (Se1 & Bit>0) or (Se1 & Bit=V) Then Mesgl[5] := Concat( MesgL[5], 'Y' )
						Else Mesgl[5] := Concat( MesgL[5], '.' );
				End;
				If ( C>5 ) Then Begin
					If (Sf1 & Bit>0) or (Sf1 & Bit=V) Then Mesgl[6] := Concat( MesgL[6], 'Y' )
						Else Mesgl[6] := Concat( MesgL[6], '.' );
				End;
				Bit := Shl(Bit,1);
				X := X + 1;
			End;
			If ( C=1 ) or ( C>2 ) Then Begin
				Bit := 1;
				X := 32;
				For I := 1 to 32 Do Begin
					If (Sa2 & Bit>0) or (Sa2 & Bit=V) Then Mesgl[1] := Concat( MesgL[1], 'Y' )
						Else Mesgl[1] := Concat( MesgL[1], '.' );
					If ( C>1 ) Then Begin
						If (Sb2 & Bit>0) or (Sb2 & Bit=V) Then Mesgl[2] := Concat( MesgL[2], 'Y' )
							Else Mesgl[2] := Concat( MesgL[2], '.' );
					End;
					If ( C>2 ) Then Begin
						If (Sc2 & Bit>0) or (Sc2 & Bit=V) Then Mesgl[3] := Concat( MesgL[3], 'Y' )
							Else Mesgl[3] := Concat( MesgL[3], '.' );
					End;
					If ( C>3 ) Then Begin
						If (Sd2 & Bit>0) or (Sd2 & Bit=V) Then Mesgl[4] := Concat( MesgL[4], 'Y' )
							Else Mesgl[4] := Concat( MesgL[4], '.' );
					End;
					If ( C>4 ) Then Begin
						If (Se2 & Bit>0) or (Se2 & Bit=V) Then Mesgl[5] := Concat( MesgL[5], 'Y' )
						Else Mesgl[5] := Concat( MesgL[5], '.' );
					End;
					If ( C>5 ) Then Begin
						If (Sf2 & Bit>0) or (Sf2 & Bit=V) Then Mesgl[6] := Concat( MesgL[6], 'Y' )
							Else Mesgl[6] := Concat( MesgL[6], '.' );
					End;
					Bit := Shl(Bit,1);
					X := X + 1;
				End;
			End;
			Clr_Scr;
			CrLf;
			EchoNE( Msg );
			CrLf;
			S := '                        1         2         3  ';
			If ( C <>2 ) Then S := Concat( S, '       4         5         6    ' );
			EchoNE( S );
			S := '    Function   12345678901234567890123456789012';
			If ( C <>2 ) Then S := Concat( S, '34567890123456789012345678901234' );
			EchoNE( S );
			S := '    --------   --------------------------------';
			If ( C <>2 ) Then S := Concat( S, '--------------------------------' );
			EchoNE( S );
			EchoNE( MesgL[1] );
			If ( C>1 ) Then EchoNE( MesgL[2] );
			If ( C>2 ) Then EchoNE( MesgL[3] );
			If ( C>3 ) Then EchoNE( MesgL[4] );
			If ( C>4 ) Then EchoNE( MesgL[5] );
			If ( C>5 ) Then EchoNE( MesgL[6] );
			CrLf;
			Done := False;
			I := 0;
			EchoN( 'Enter Function To Edit [Return] to Exit -> ' );
			Repeat
				Ch := Chr( Get_Console );
				I := Ord(Ch);
			Until ( Ch IN['1'..C2] ) or ( I=Cr ) or ( Carrier=False );
			CrLf;
			CrLf;
			If (I=Cr) Then Done := True;
			If Ch In['1'..C2] Then Begin
				EchoS( '^r' );
				Y := Ord(Ch) - 48;
				S := MesgL[Y];
				EchoNE( S );
				EchoS( '^b' );
				EchoN( S );
				If ( C=2 ) Then X := 32  Else X := 64;
				For I := 1 to X Do Back_Space;
				V := 0;
				X := 31;
				Bit := 1;
				For I := 1 to 32 Do Begin
					Repeat
						Ch := Chr( Get_Console );
						Upper_C( Ch );
					Until (Ch='Y') or (Ch='N' ) or (Carrier=False);
					If Ch = 'Y' Then Begin
						EchoS( Ch );
						V := ( V | Bit);
					End
					Else EchoS('.');
					Bit := Shl(Bit,1);
				End;
				If Y = 1 Then Sa1 := V
				Else If Y = 2 Then Sb1 := V
				Else If Y = 3 Then Sc1 := V
				Else If Y = 4 Then Sd1 := V
				Else If Y = 5 Then Se1 := V
				Else Sf1 := V;
				If ( C <> 2 ) Then Begin
					V := 0;
					X := 31;
					Bit := 1;
					For I := 1 to 32 Do Begin
						Repeat
							Ch := Chr( Get_Console );
							Upper_C( Ch );
						Until (Ch='Y') or (Ch='N' ) or (Carrier=False);
						If Ch = 'Y' Then Begin
							EchoS( Ch );
							V := ( V | Bit);
						End
						Else EchoS('.');
						Bit := Shl(Bit,1);
					End;
					If Y = 1 Then Sa2 := V
					Else If Y = 2 Then Sb2 := V
					Else If Y = 3 Then Sc2 := V
					Else If Y = 4 Then Sd2 := V
					Else If Y = 5 Then Se2 := V
					Else Sf2 := V;
				End;
				CrLf;
				CrLf;
			End;
		Until (Done) or (Carrier=False);
	End;

	Procedure Edit_Command_Levels;
	Var S : String;
	Begin
		DescL[1] := '[1] Commands : ';
		Sa1 := UserRec.Sec_Lvl [ 1 ];
		Sa2 := UserRec.Sec_Lvl [ 2 ];
		S := 'Command Levels';
		Edit_64_Sigs( S, 1 );
		UserRec.Sec_Lvl [ 1 ] := Sa1;
		UserRec.Sec_Lvl [ 2 ] := Sa2;
	End;

	Procedure Edit_Priv_User;
	Var S : String;
	Begin
		DescL[1] := '[1] Priv Flgs: ';
		DescL[2] := '[2] User Flgs: ';
		Sa1 := UserRec.Priv_Flags;
		Sb1 := UserRec.User_Flags;
		S := 'Privileges & User Flags';
		Edit_64_Sigs( S, 2 );
		UserRec.Priv_Flags := Sa1;
		UserRec.User_Flags := Sb1;
	End;
	
	Procedure Edit_Msg_Bases;
	Var S : String;
	Begin
		DescL[1] := '[1] Read  Msg: ';
		DescL[2] := '[2] User Scan: ';
		DescL[3] := '[3] Post  Msg: ';
		DescL[4] := '[4] Edit  Msg: ';
		DescL[5] := '[5] Kill  Msg: ';
		DescL[6] := '[6] Print Msg: ';
		Sa1 := UserRec.Msg_Read_Mask  [ 1 ];
		Sa2 := UserRec.Msg_Read_Mask  [ 2 ];
		Sb1 := UserRec.Scan_Boards    [ 1 ];
		Sb2 := UserRec.Scan_Boards    [ 2 ];
		Sc1 := UserRec.Msg_Post_Mask  [ 1 ];
		Sc2 := UserRec.Msg_Post_Mask  [ 2 ];
		Sd1 := UserRec.Msg_Edit_Mask  [ 1 ];
		Sd2 := UserRec.Msg_Edit_Mask  [ 2 ];
		Se1 := UserRec.Msg_Delete_Mask[ 1 ];
		Se2 := UserRec.Msg_Delete_Mask[ 2 ];
		Sf1 := UserRec.Msg_Print_Mask [ 1 ];
		Sf2 := UserRec.Msg_Print_Mask [ 2 ];
		S := 'Message Bases';
		Edit_64_Sigs( S, 6 );
		UserRec.Msg_Read_Mask  [ 1 ] := Sa1;
		UserRec.Msg_Read_Mask  [ 2 ] := Sa2;
		UserRec.Scan_Boards    [ 1 ] := Sb1;
		UserRec.Scan_Boards    [ 2 ] := Sb2;
		UserRec.Msg_Post_Mask  [ 1 ] := Sc1;
		UserRec.Msg_Post_Mask  [ 2 ] := Sc2;
		UserRec.Msg_Edit_Mask  [ 1 ] := Sd1;
		UserRec.Msg_Edit_Mask  [ 2 ] := Sd2;
		UserRec.Msg_Delete_Mask[ 1 ] := Se1;
		UserRec.Msg_Delete_Mask[ 2 ] := Se2;
		UserRec.Msg_Print_Mask [ 1 ] := Sf1;
		UserRec.Msg_Print_Mask [ 2 ] := Sf2;
	End;
		
	Procedure Edit_File_Sigs;
	Var S : String;
	Begin
		DescL[1] := '[1] Access   : ';
		DescL[2] := '[2] User Mask: ';
		DescL[3] := '[3] Edit Desc: ';
		DescL[4] := '[4] Validate : ';
		DescL[5] := '[5] Kill File: ';
		Sa1 := UserRec.Sig_Accs_Mask[ 1 ];
		Sa2 := UserRec.Sig_Accs_Mask[ 2 ];
		Sb1 := UserRec.Sig_User_Mask[ 1 ];
		Sb2 := UserRec.Sig_User_Mask[ 2 ];
		Sc1 := UserRec.Sig_Edit_Desc[ 1 ];
		Sc2 := UserRec.Sig_Edit_Desc[ 2 ];
		Sd1 := UserRec.Sig_Validate [ 1 ];
		Sd2 := UserRec.Sig_Validate [ 2 ];
		Se1 := UserRec.Sig_Kill_File[ 1 ];
		Se2 := UserRec.Sig_Kill_File[ 2 ];
		S := 'File SIGS';
		Edit_64_Sigs( S, 5 );
		UserRec.Sig_Accs_Mask[ 1 ] := Sa1;
		UserRec.Sig_Accs_Mask[ 2 ] := Sa2;
		UserRec.Sig_User_Mask[ 1 ] := Sb1;
		UserRec.Sig_User_Mask[ 2 ] := Sb2;
		UserRec.Sig_Edit_Desc[ 1 ] := Sc1;
		UserRec.Sig_Edit_Desc[ 2 ] := Sc2;
		UserRec.Sig_Validate [ 1 ] := Sd1;
		UserRec.Sig_Validate [ 2 ] := Sd2;
		UserRec.Sig_Kill_File[ 1 ] := Se1;
		UserRec.Sig_Kill_File[ 2 ] := Se2;
	End;

	Procedure Edit_User;
	Var
		Z, Usr_T : Integer;
		Done : Boolean;
		S : String;
		Ch : Char;
	Begin
		Usr_T := Usr_No;
		Done := False;
		Repeat
			Clr_Scr;
			Writev( S, 'Editing User# ', Usr_T, ',  Name: ' );
			S := Concat( S, User_Name, ',  Alias: ' , UserRec.UHandle );
			EchoNE( S );
			CrLf;
			EchoNE( '[1]  Edit User Information' );
			CrLf;
			EchoNE( '[2]  Edit Command Levels  ' );
			CrLf;
			EchoNE( '[3]  Edit Priv/User Levels' );
			CrLf;
			EchoNE( '[4]  Edit Msg Base Access ' );
			CrLf;
			EchoNE( '[5]  Edit File Sig Access ' );
			CrLf;
			EchoNE( '[6]  Apply User Mask      ' );
			CrLf;
			S := 'Enter Choice or [Return] To Exit -> ';
			EchoN( S );
			Repeat
				Ch := Get_Char;
			Until ( Ch In['1'..'6'] ) or ( ord( Ch ) = Cr );
			CrLf;
			Case Ch Of
				'1' : Edit_User_Info;
				'2' : Edit_Command_Levels;
				'3' : Edit_Priv_User;
				'4' : Edit_Msg_Bases;
				'5' : Edit_File_Sigs;
				'6' : Begin
								S := 'Enter Mask Number to Apply, [Return] To Exit  -> ';
								EchoN( S );
								Z := Get_Number( 10 );
								(*	If (Z>0) Then Get_MaskData( Z ); *)
							End;
			End; { Case }
			If ( Ord( Ch )=Cr ) Then Done := True;
		Until ( Done ) or ( Carrier=False );
		Usr_No := Usr_T;
		CrLf;
	End;

Begin
;   { dummy }
End.
