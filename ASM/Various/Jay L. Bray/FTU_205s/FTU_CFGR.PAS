{$S16}
Program FTU_CFGR;
{$I D:\Pascal\Per_Pasc\AuxSubs.Pas}

Const
	Console = 2;
	Timeout = -1;
	Bksp = 8;
	Cr  = 13;
	Lf  = 10;
	Esc = 27;

Type
	Cstring = packed Array[0..79] of Char;
	Errors = Packed Array[1..70] of String[40];
	DLine = Packed Array[1..5] of String[80];

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
 		TSig_Accs : Long_Integer;
 		User_Mask : Packed Array[1..32] of Long_Integer;
		Sig_Accs  : Packed Array[1..32] of Long_Integer;
		Sig_Valid : Packed Array[1..32] of Long_Integer;
		Sig_Edit  : Packed Array[1..32] of Long_Integer;
		Sig_Kill  : Packed Array[1..32] of Long_Integer;
	End;

	SigData2 = Packed Record
 		TSigCount: Integer;
 		TNames   : Array[1..32] Of String[30];
 		Sigcount : Packed Array[0..31] Of Integer;
 		Names    : Packed Array[0..1023] Of String[30];
 		Paths    : Packed Array[0..1023] Of String[60];
		Show_Free: Packed Array[0..1023] Of Boolean;
		Use_Desc : Packed Array[0..1023] Of Boolean;
		Temp_Path: String[60];
 		Userlog  : String[60];
		LogFile  : String[60];
		Upld_Pth : String[60];
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
 		Sig_Accs_Mask  : Long_Integer;
 	End;

Var
	System2     : SigData2;
 	UserRec     : Userdata;           { the user's userlog file entry      }
	UserAcs     : UserAccess;
	Err         : Errors;
	DescL       : Dline;
	DTA_Data    : DTA;                { Blkio used For dir searches }
 	Userfile    : File Of Userdata;   { the userlog data file }
 	Userfilename: String[61];         { filename For the userfile }
	Sig_Access  : Packed Array[1..32] Of Integer;
	NumSigs     : Integer;
	Fnct_Key    : Integer;
	Usr_No      : Integer;
	Lin_Count   : Integer;
	Caps        : Boolean;
	Result      : Boolean;
	Line        : String;

	Procedure SetDta( Var B: DTA );
		Gemdos($1A);

	Function Open_File( Var P: Cstring; Md: Integer ):Integer;
		GemDos($3D);  { Md: 0=Read Only, 1=Write Only, 2=Read & Write}

	Function Close_File( H: Integer ):Integer;
		GemDos($3E);

	Function FRead_Sys2(H:Integer; Count:Long_Integer; Var S:SigData2):Long_Integer;
		Gemdos( $3F );

	Function FWrite_Sys2(H:Integer; Count:Long_Integer; Var S:SigData2):Long_Integer;
		Gemdos( $40 );

	Function FWrite_Usr2(H:Integer; Count:Long_Integer; Var S:UserAccess):Long_Integer;
		Gemdos( $40 );

	Function FRead_Usr(H:Integer; Count:Long_Integer; Var S:UserData):Long_Integer;
		Gemdos( $3F ); 

	Function FRead_Usr2(H:Integer; Count:Long_Integer; Var S:UserAccess):Long_Integer;
		Gemdos( $3F ); 

	Function Fseek( Where : Long_Integer ; FHandle, Mode: Integer ):Long_Integer;
		Gemdos($42); { Mode: 0=From Start, 1=from current pos, 2=from End }	

	Function Inready( Device: Integer ):Boolean;
 	  Bios(1);

	Function Bconin( Device: Integer ):Long_Integer;
 	  Bios(2);

	Procedure Bconout( Device: Integer; Ch: Char );
		Bios(3);

	Procedure MakeCstring( Var Source: String; Var Dest: Cstring );
	Var
   	X : Integer;
	Begin
   	For X := 1 To Length(Source) Do
   		Dest[X-1] := Source[X];
   	X := Length(Source);
   	Dest[X] := Chr(0);
	End;

	Function FOpen( Var F: String; Md: Integer ):Integer;
	{ Md: 0=Read Only, 1=Write Only, 2=Read & Write}
	Var
		C : Cstring;
	Begin
		MakeCstring( F, C );
		FOpen := Open_File( C, Md );
	End;

	Function Upper_C( C: Char ): Char;
	Begin
		If ( C In ['a'..'z'] ) Then
			C := Chr( Ord(C) -32 );
		Upper_C := C		
	End;

	Function Lower_C( C: Char ): Char;
	Begin
		If ( C In ['A'..'Z'] ) Then
			C := Chr( Ord(C) +32 );
		Lower_C := C		
	End;
								
	Procedure Put_Console( Ch : Char );
	Begin
		Bconout( Console, Ch );
	End;

	Procedure Hide_Curs;
	Begin
		Put_Console( Chr(Esc) );
		Put_Console( 'f' );
	End;

	Procedure Show_Curs;
	Begin
 		Put_Console( Chr(Esc) );
 		Put_Console( 'e' );
	End;

	Procedure Save_Curs;
	Begin
		Put_Console( Chr(Esc) );
		Put_Console( 'j' );
	End;

	Procedure Get_Curs;
	Begin
 		Put_Console( Chr(Esc) );
 		Put_Console( 'k' );
	End;

	Procedure Del_Line;
	Begin
		Save_Curs;
		Put_Console( Chr(Esc) );
 		Put_Console( 'Y' );
		Put_Console( '#' );
		Put_Console( ' ' );
 		Put_Console( Chr(Esc) );
 		Put_Console( 'M' );
		Get_Curs;
 		Put_Console( Chr(Esc) );
 		Put_Console( 'A' );
	End;

	Procedure CrLf;
	Begin
		Lin_Count := Lin_Count + 1;
		If Lin_Count > 21 then Del_Line;
		Put_Console( Chr(Cr) );
		Put_Console( Chr(Lf) );
	End;

	Function Get_Console : Integer;
	Var
		X : Integer;
		I : Long_Integer;
	Begin
		Fnct_Key := 0;
 		I := Bconin( Console );
		Fnct_Key := Shr( I,16 );
		X := ( I & 65535 );
		Get_Console := X;
	End;

	Function Scan_Input : Integer;
	Var
		X : Integer;
	Begin
		X := TimeOut;
		If Inready(Console) Then X := Get_Console;
		Scan_Input := X;
	End;

	Procedure EchoS( Temp : String );
	Var
   	I, X : Integer;
		Ch : Char;
	Begin
		For I := 1 to Length( Temp ) Do
  		Put_Console( Temp[I] );
	End;

	Procedure EchoSE( Line : String );
	Begin
   	EchoS( Line );
   	Crlf;
	End;

	Procedure Back_Space;
	Begin
		Put_Console( Chr(Bksp) );
		Put_Console( ' ' );
		Put_Console( Chr(Bksp) );
	End;

	Procedure Addspaces( Var Line: String ; Lngth: Integer );
	Begin
   	While Length(Line) < Lngth Do
   		Line := Concat( Line, ' ' );
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
		If Ln = X Then Is_Numeric := True
		Else Is_Numeric := False;
	End;
	
	Function Get_Char: Char;
	Var
   	I : Integer;
		Ch : Char;
		Ok : Boolean;
	Begin
		Ok := False;
   	Repeat
  		I := Scan_Input;
 			If (I>31) And (I<129) or (I=Cr) or (I=Bksp) Then Ok := True;
   	Until (Ok);
		Get_char := Chr( I );
	End;

	Procedure Line_In( Var Temp: String; Lgth : Short_Integer );
	Var
   	Ch : Char;
		X : Short_Integer;
   	Done : Boolean;
	Begin
   	Temp := '';
   	Done := False;
		X := 0;
   	Repeat
   		Ch := Get_char;
			If (Caps) Then Ch := Upper_C( Ch );
	 		If (Ord(Ch)=Cr) Then Done := True
			Else If (Ord(Ch)=Bksp) And (X>=1) Then Begin
				Back_Space;
				X := X - 1;
				Temp[0] := Chr(X);
			End
			Else Begin
				Temp := Concat( Temp, Ch );
				Put_Console( Ch );
				X := X + 1;
			End;
		Until (Done) or (X = Lgth);
	End;

	Function Get_Number( Num: Integer ): Integer;
	Var
		Temp : String;
		X,Ln : Integer;
		I : Long_Integer;
		Ch : Char;
		Done : Boolean;
	Begin
		Temp := '';
		Writev( Temp, Num);
		Ln := Length( Temp );
		Temp := '';
		Repeat
			Repeat
				Repeat
					Ch := Get_Char;
				Until (Ch In['0'..'9']) or (Ord( Ch)=Cr);
				If Ch In['0'..'9'] Then Begin
					Temp := Concat( Temp, Ch );
					EchoS( Ch );
				End;
			Until (Length(Temp)=Ln) or (Ord(Ch)=Cr);
			If Length(Temp) >0 Then Begin
				Readv( Temp, I );
				If (I>Num) Then Begin
					For X := 1 to (Length(Temp)) Do
						Back_Space;
					Temp := '';
				End;
			End
			Else I := -1;
		Until (I<=Num);
		Get_Number := I;
	End;

	Procedure Clear_Screen;
	Begin
		Put_Console( Chr(Esc) );
		Put_Console( 'Y' );
		Put_Console( '#' );
		Put_Console( ' ' );
		Put_Console( Chr(Esc) );
		Put_Console( 'J' );
		Lin_Count := 0;		
	End;

	Procedure Show_Error( P:String; Error: Integer );
	Var
		Temp,Desc: String;
	Begin
		If Error <> 0 Then Begin
			Error := Abs(Error);
			Writev( Temp, '-', Error );
			If Error >70 Then Error := 70;
			Desc := Err[Error];
			DescL[1] := ' ';
			DescL[2] := Concat( 'System Error: ', Temp );
			DescL[3] := Concat( '    Filename: ', P );
			DescL[4] := Concat( ' Description: ', Desc );
			EchoSE( DescL[1]);
			EchoSE( DescL[2]);
			EchoSE( DescL[3]);
			EchoSE( DescL[4]);
			CrLf;
			EchoS( 'Press Any Key To Continue...' );
			Readln( Line );
		End;
	End;

	Function Exists( Filename: String ):Boolean;
	Var
		Junkfile : Text;
	Begin
   	Io_check( False );
   	Reset( Junkfile, Filename );
   	If Io_result=0 Then
   		Result := True
   	Else
   		Result := False;
   	Close( Junkfile );
   	Exists := Result;
   	Io_check( True );
	End;

	Procedure Get_SysData;
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
			If Count<0 Then Show_Error( F, Count );
			Close( Sigdatafile );
			UserFileName := System2.UserLog;
			If System2.TSigCount>0 Then NumSigs := System2.TSigCount
			Else NumSigs := 32;
		End
		Else Begin
				GotoXY( 34,2 );
				EchoS( 'FTU_DATA.SIG File Is Missing!!!' );
			End;
	End;

	Procedure Calc_Sig_Nums;
	Var
		I,X,Count,Ssig : Integer;
	Begin
		For I := 0 to (NumSigs-1) Do Begin
			Count := 0;
			For X := 0 to 31 Do Begin
				Ssig := (I * 32) + X;
				If Length(SysTem2.Names[Ssig]) > 0 Then Count := Count + 1;
			End;
			System2.SigCount[I] := Count;
		End;
	End;

	Procedure Save_Ftu_Sig;
	Var
		Sigdataftu : text;
		X : Long_Integer;
		F : String;
	Begin
		F := 'ftu_data.sig';
		ReWrite( SigDataFtu, F );
		X := FWrite_Sys2( Handle(SigDataFtu), SizeOf(System2), System2 );
		If X<0 Then Show_Error( F, X );
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
		If X<0 Then Show_Error( F, X );
		X := FWrite_Usr2( Handle(Ftu_Mask), SizeOf(UserAcs), UserAcs );
		If X<0 Then Show_Error( F, X );
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
		If X<0 Then Show_Error( F, X );
		X := FRead_Usr2( Handle(Ftu_Mask), SizeOf(UserAcs), UserAcs );
		If X<0 Then Show_Error( F, X );
		Close( Ftu_Mask );
	End;

	Procedure Save_Ftu_User;
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
		If X<0 Then Show_Error( F, X );
		X := FWrite_Usr2( Handle(UsrDataFtu), SizeOf(UserAcs), UserAcs );
		If X<0 Then Show_Error( F, X );
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
		S2 := (Usr_No-1);
		Count := S1 * S2;
		Reset( UsrDataFtu, F );
		X := Fseek( Count, Handle(UsrDataFtu), 0 );
		If X<0 Then Show_Error( F, X );
		X := FRead_Usr2( Handle(UsrDataFtu), SizeOf(UserAcs), UserAcs );
		If X<0 Then Show_Error( F, X );
		Close( UsrDataFtu );
	End;

	Procedure Get_UserData;
	Var
   	S1, S2, X, Count : Long_Integer;
	Begin
		S1 := SizeOf(UserRec);
		S2 := Usr_No;
		Count := S1 * S2;
		Reset( Userfile, Userfilename );
		X := Fseek( Count, Handle(Userfile), 0 );
		If X<0 Then Show_Error( Userfilename, X );
		X := FRead_Usr( handle(UserFile), sizeof(UserRec), UserRec );
		If X<0 Then Show_Error( Userfilename, X );
		Close( Userfile );
	End;

	Procedure Get_Sig_Access;
	Var
		Fa, Count : Integer;
		FSig_A, Bit, Xa, V : Long_Integer;
		Line : String;
	Begin
		For Count := 1 to 32 Do
			Sig_Access[Count] := 0;
		Count := 1;
		Bit := 1;
		Fa := 0;
		FSig_A := UserAcs.TSig_Accs;
		V := $80000000;
		Repeat
			Fa := Fa + 1;
			Writev( Line, System2.TNames[Fa] );
			If Line[0] <> Chr(0) Then Begin
	  	 	Xa := (Bit & FSig_A);
		   	If (Xa>0) or (Xa=V) Then Sig_Access[Count] := Fa;
				Count := Count + 1;
			End;
			Bit := Bit * 2;
		Until Fa = NumSigs;
	End;

	Procedure Show_Masks;
	Begin
		Clear_Screen;
		GotoXY( 31,4 );
		EchoSE( ' 1.  User Mask # 1' );
		GotoXY( 31,5 );
		EchoSE( ' 2.  User Mask # 2' );
		GotoXY( 31,6 );
		EchoSE( ' 3.  User Mask # 3' );
		GotoXY( 31,7 );
		EchoSE( ' 4.  User Mask # 4' );
		GotoXY( 31,8 );
		EchoSE( ' 5.  User Mask # 5' );
		GotoXY( 31,9 );
		EchoSE( ' 6.  User Mask # 6' );
		GotoXY( 31,10 );
		EchoSE( ' 7.  User Mask # 7' );
		GotoXY( 31,11 );
		EchoSE( ' 8.  User Mask # 8' );
		GotoXY( 31,12 );
		EchoSE( ' 9.  User Mask # 9' );
		GotoXY( 31,13 );
		EchoSE( '10.  User Mask #10' );
	End;

	Procedure Edit_SubSig( Sig : Integer );
	Var
		I,T,SSig,Bsig,MSig : Integer;
		S : String;
		Ch : Char;
		Done : Boolean;
	Begin
		Sig := Sig - 1;
		BSig := (Sig * 32);
		MSig := (Bsig + 31);
		Repeat
			Clear_Screen;
			Writev( S, 'Editing Topic Sig #', Sig+1, '  -  ', System2.TNames[Sig+1] );
			GotoXY( (80-Length(S)) Div 2, 3);
			EchoSE( S );
			CrLf;
			I := 1;
			For SSig := BSig to MSig Do Begin
				Writev( S, '  ',I:4, '.  ' );
				If Length(SysTem2.Names[SSIG]) = 0 Then S := Concat( S, '*- Empty -*')
				Else S := Concat( S, System2.Names[SSig] );
				AddSpaces( S, 39 );
				EchoS( S );
				If Not Odd( I ) Then CrLf;
				I := I + 1;
			End;
			If Odd( I ) Then CrLf;
			CrLf;
			S :='Enter # Of Sub-Topic Sig To Edit [Return] to Exit -> ';
			GotoXY( (80-Length(S)) Div 2, 23);
			EchoS( S );
			T := Get_Number( 32 );
			If (T>0) Then Begin
				SSig := ((T-1) + BSig);
				Done := False;
				Repeat
					Clear_Screen;
					Writev( S, 'Editing Sub-Topic Sig #', T, '  -  ', System2.Names[SSig] );
					GotoXY( (80-Length(S)) Div 2, 3);
					EchoS( S );
					GotoXY( 12,5);
					EchoS( '[1]  File SIG Name: ' );
					GotoXY( 32,5);
					EchoS( System2.Names[SSig] );
					GotoXY( 12,7);
					EchoS( '[2]  File SIG Path' );
					GotoXY( 15,8);
					EchoS( '=> ' );
					EchoS( System2.Paths[SSig] );
					GotoXY( 12,10);
					EchoS( '[3]  Use Descriptions?' );
					GotoXY( 36,10);
					If (System2.Use_Desc[SSig]) Then EchoS('Yes')
						Else EchoS('No');
					GotoXY( 12,12);
					EchoS( '[4]  Show Free Space Before Upload?' );
					GotoXY( 49,12);
					If (System2.Show_Free[SSig]) Then EchoS('Yes')
						Else EchoS('No');
					GotoXY( 12,14);
					EchoS( '[X]  Exit' );
					GotoXY( 12,16);
					EchoS( 'Choice -> ' );
					Ch := Get_Char;
					Ch := Upper_C( Ch );
					Case Ch Of
						'1' : Begin
										GotoXY( 32,5);
										Put_Console( Chr(Esc));
										Put_Console( 'K' );
										Caps := False;
										Line_In( S, 30);
										System2.Names[SSig] := S;
									End;
						'2' : Begin
										GotoXY( 18,8);
										Put_Console( Chr(Esc));
										Put_Console( 'K' );
										Caps := True;
										Line_In( S, 60);
										System2.Paths[SSig] := S;
									End;
						'3' : Begin
										If (System2.Use_Desc[SSig]) Then Begin
											System2.Use_Desc[SSig] := False;
										End
										Else Begin
											System2.Use_Desc[SSig] := True;
										End;
									End;
						'4' : Begin
										If (System2.Show_Free[SSig]) Then Begin
											System2.Show_Free[SSig] := False;
										End
										Else Begin
											System2.Show_Free[SSig] := True;
										End;
									End;
						'X' : Done := True;
					End; { Case }
				Until (Done);
			End;
			Get_Curs;
		Until (T<0);
	End;

	Procedure Edit_TopSig_Name( Sig: Integer );
	Var
		S : String;
		X : Integer;
	Begin
		Clear_Screen;
		S := Concat( 'Old Topic Sig Name :> ', System2.TNames[Sig] );
		X := (80-Length(S)) Div 2;
		GotoXY( X, 4);
		EchoS( S );
		GotoXY( X, 6);
		EchoS( 'New Topic Sig Name :> ' );
		Caps := False;
		Line_In( S, 60);
		System2.TNames[Sig] := S;
	End;

	Procedure Edit_TSigName;
	Var
		I,Sig : Integer;
		S : String;
	Begin
		Repeat
			Clear_Screen;
			For Sig := 1 to 32 Do Begin
				Writev( S, '  ',Sig:4, '.  ' );
				If Length(System2.TNames[Sig]) = 0 Then S := Concat( S, '*- Empty -*')
				Else S := Concat( S, System2.TNames[Sig] );
				AddSpaces( S, 39 );
				EchoS( S );
				If Not Odd( Sig ) Then CrLf;
			End;
			If Odd( Sig ) Then CrLf;
			CrLf;
			S :='Enter # Of Topic Sig To Edit [Return] to Exit -> ';
			GotoXY( (80-Length(S)) Div 2, 23);
			EchoS( S );
			Sig := Get_Number( 32 );
			If (Sig>0) Then Begin
				Edit_TopSig_Name( Sig );
			End;
		Until (Sig<0);
		Sig := 0;
		For I := 1 to 32 Do
			If Length(System2.TNames[I]) >0 Then Sig := Sig + 1;
 		System2.TSigcount := Sig;
		NumSigs := Sig;
	End;

	Procedure Edit_SIGS;
	Var
		I,Sig : Integer;
		S : String;
	Begin
		Repeat
			Clear_Screen;
			For Sig := 1 to NumSigs Do Begin
				Writev( S, '  ',Sig:4, '.  ' );
				If Length(System2.TNames[Sig]) = 0 Then S := Concat( S, '*- Empty -*')
				Else S := Concat( S, System2.TNames[Sig] );
				AddSpaces( S, 39 );
				EchoS( S );
				If Not Odd( Sig ) Then CrLf;
			End;
			If Odd( Sig ) Then CrLf;
			CrLf;
			S :='Enter # Of Topic Sig To Edit [Return] to Exit -> ';
			GotoXY( (80-Length(S)) Div 2, 23);
			EchoS( S );
			Sig := Get_Number( NumSigs );
			If (Sig>0) Then Begin
				Edit_SubSig( Sig );
			End;
		Until (Sig<0);
	End;

	Procedure Edit_TopSig( Sig : Integer );
	Var
		S : String;
		Ch : Char;
		Done : Boolean;
		X,Y,I : Integer;
		Fa,Fm,Fv,Fe,Fk,V, Bit : Long_Integer;
	Begin
		Clear_Screen;
		Writev( S, 'Editing Topic Sig #', Sig, '  -  ', System2.TNames[Sig] );
		GotoXY( (80-Length(S)) Div 2, 3);
		EchoS( S );
		GotoXY( 15,5 );
		EchoS('                       Sub-Topic File SIGS       ' );
		GotoXY( 15,6 );
		EchoS('                         1         2         3   ' );
		GotoXY( 15,7 );
		EchoS('     Function    12345678901234567890123456789012' );
		GotoXY( 15,8 );
		EchoS('     ---------   --------------------------------' );
		GotoXY( 15,9 );
		EchoS(' [1] Access    : ' );
		GotoXY( 15,10 );
		EchoS(' [2] User Mask : ' );
		GotoXY( 15,11 );
		EchoS(' [3] Edit Desc : ' );
		GotoXY( 15,12 );
		EchoS(' [4] Validate  : ' );
		GotoXY( 15,13 );
		EchoS(' [5] Kill File : ' );
		Fa := UserAcs.Sig_Accs[ Sig ];
		Fm := UserAcs.User_Mask[ Sig ];
		Fe := UserAcs.Sig_Edit[ Sig ];
		Fv := UserAcs.Sig_Valid[ Sig ];
		Fk := UserAcs.Sig_Kill[ Sig ];
		Bit := 1;
		X := 32;
		For I := 1 to 32 Do Begin
			V := $80000000;
			GotoXY( X,9 );
			If (Fa & Bit>0) or (Fa & Bit=V) Then EchoS( 'Y' )
				Else EchoS( '.' );
			GotoXY( X,10 );
			If (Fm & Bit>0) or (Fm & Bit=V) Then EchoS( 'Y' )
				Else EchoS( '.' );
			GotoXY( X,11 );
			If (Fe & Bit>0) or (Fe & Bit=V) Then EchoS( 'Y' )
				Else EchoS( '.' );
			GotoXY( X,12 );
			If (Fv & Bit>0) or (Fv & Bit=V) Then EchoS( 'Y' )
				Else EchoS( '.' );
			GotoXY( X,13 );
			If (Fk & Bit>0) or (Fk & Bit=V) Then EchoS( 'Y' )
				Else EchoS( '.' );
			Bit := Shl(Bit,1);
			X := X + 1;
		End;
		Done := False;
		I := 0;
		Repeat
			GotoXY( 55,15 );
			EchoS( '  ' );
			GotoXY( 18,16 );
			EchoS( 'Enter Function To Edit [Return] to Exit -> ' );
			Repeat
				Ch := Get_Char;
			Until (Ch IN['1'..'5']) or (Ord(Ch)=Cr);
			If (Ord(Ch)=Cr) Then Done := True;
			If Ch In['1'..'5'] Then Begin
				If Ch = '1' Then Y := 9
				Else If Ch = '2' Then Y := 10
				Else If Ch = '3' Then Y := 11
				Else If Ch = '4' Then Y := 12
				Else Y := 13;
				V := 0;
				X := 31;
				Bit := 1;
				For I := 1 to 32 Do Begin
					GotoXY( X+I,Y );
					Repeat
						Ch := Get_Char;
						Ch := Upper_C( Ch );
					Until (Ch='Y') or (Ch='N' );
					If Ch = 'Y' Then EchoS( Ch )
						Else EchoS('.');
					If Ch='Y' Then V := ( V | Bit);
					Bit := Shl(Bit,1);
				End;
				If Y = 9 Then UserAcs.Sig_Accs[ Sig ] := V
				Else If Y = 10 Then UserAcs.User_Mask[ Sig ] := V
				Else If Y = 11 Then UserAcs.Sig_Edit[ Sig ] := V
				Else If Y = 12 Then UserAcs.Sig_Valid[ Sig ] := V
				Else UserAcs.Sig_Kill[ Sig ] := V;
			End;
		Until (Done);
	End;

	Procedure Edit_Top_Sig;
	Var
		S : String;
		Ch : Char;
		Done : Boolean;
		X,Y,I : Integer;
		Fa,V, Bit : Long_Integer;
	Begin
		Clear_Screen;
		Writev( S, 'Editing Topic Sig Access' );
		GotoXY( (80-Length(S)) Div 2, 3);
		EchoS( S );
		GotoXY( 15,5 );
		EchoS('                          Topic File SIGS' );
		GotoXY( 15,6 );
		EchoS('                         1         2         3   ' );
		GotoXY( 15,7 );
		EchoS('     Function    12345678901234567890123456789012' );
		GotoXY( 15,8 );
		EchoS('     ---------   --------------------------------' );
		GotoXY( 15,9 );
		EchoS(' [1] Access    : ' );
		Fa := UserAcs.TSig_Accs;
		Bit := 1;
		X := 32;
		V := $80000000;
		For I := 1 to 32 Do Begin
			GotoXY( X,9 );
			If (Fa & Bit>0) or (Fa & Bit=V) Then EchoS( 'Y' )
				Else EchoS( '.' );
			Bit := Shl(Bit,1);
			X := X + 1;
		End;
		Done := False;
		I := 0;
		Repeat
			GotoXY( 61,11 );
			EchoS( '  ' );
			GotoXY( 18,11 );
			EchoS( 'Enter Function To Edit [Return] to Exit -> ' );
			Repeat
				Ch := Get_Char;
			Until (Ch='1') or (Ord(Ch)=Cr);
			If (Ord(Ch)=Cr) Then Done := True;
			If Done = False Then Begin
				V := 0;
				X := 31;
				Bit := 1;
				For I := 1 to 32 Do Begin
					GotoXY( X+I,9 );
					Repeat
						Ch := Get_Char;
						Ch := Upper_C( Ch );
					Until (Ch='Y') or (Ch='N' );
					If Ch = 'Y' Then EchoS( Ch )
						Else EchoS('.');
					If Ch='Y' Then V := ( V | Bit);
					Bit := Shl(Bit,1);
				End;
				UserAcs.TSig_Accs := V;
			End;
		Until (Done);
	End;

	Procedure Edit_Usr_Sigs;
	Var
		S : String;
		Ok : Boolean;
		I, Sig : Integer;
		V, Bit : Long_Integer;
	Begin
		Repeat
			Clear_Screen;
			For Sig := 1 to NumSigs Do Begin
				Ok := False;
				For I := 1 to 32 Do
					If Sig_Access[I] = Sig Then Ok := True;
				Writev( S, '  ',Sig:4, '.  ' );
				If Length(System2.TNames[Sig]) = 0 Then S := Concat( S, '*- Empty -*')
				Else If (Ok=False) Then S := Concat( S, ' - Not Authorized -' )
				Else S := Concat( S, System2.TNames[Sig] );
				AddSpaces( S, 39 );
				EchoS( S );
				If Not Odd( Sig ) Then CrLf;
			End;
			If Odd( Sig ) Then CrLf;
			CrLf;
			S := ' Enter # Of Topic Sig To Edit [Return] to Exit -> ';
			GotoXY( (80-Length(S)) Div 2, 23);
			EchoS( S );
			Sig := Get_Number( 32 );
			If (Sig>0) Then Begin
				Edit_TopSig( Sig );
			End;
		Until (Sig<0);
	End;

	Procedure Edit_User;
	Var
		C,I,U,N,Z : Integer;
		X : Long_Integer;
		Done : Boolean;
		S : String;
		Ch : Char;
	Begin
   	Reset( Userfile, Userfilename );
   	X := Fseek( 0, Handle(Userfile), 2 );
   	Close( Userfile );
		X := (X Div 292) - 1;
		Done := False;
		U := 0;
		N := 15;
		For I := 1 to X Do Begin
			Clear_Screen;
			GotoXY( 14,3 );
			EchoS( '  User   User_Handle           User_Name           ' );
			GotoXY( 14,4 );
			EchoS( '  ----   --------------------  --------------------' );  
			If (I+15) > X Then N := (X - I);
			C := 5;
			For U := I To I + N Do Begin
				Usr_No := U;
				Get_UserData;
				If (UserRec.In_Use) Then Writev( S, '  ',U:4, '>  ', UserRec.UHandle )
					Else Writev( S, '  ',U:4, '>  <Deleted User>' );
				AddSpaces( S, 30 );
				If (UserRec.In_Use) Then S := Concat( S, UserRec.Name );
				GotoXY( 14,C );
				EchoSE( S );
				C := C + 1;
			End;
			CrLf;
			S := 'Enter User# To Edit, [Return] For More, ''0'' To Exit  -> ';
			GotoXY( (80-Length(S)) Div 2, 23);
			EchoS( S );
			Z := Get_Number( U );
			If (Z>0) Then Begin
				Usr_No := Z;
				Clear_Screen;
				CrLf;
				Get_UserData;
				Get_Ftu_User;
				Get_Sig_Access;
				Done := False;
				Repeat
					Clear_Screen;
					Writev( S, 'Editing User# ', Z, ',  Name: ' );
					S := Concat( S, UserRec.Name );
					S := Concat( S, ',  Alias: ' );
					S := Concat( S, UserRec.UHandle );
					GotoXY( (80-Length(S)) Div 2, 3);
					EchoS( S );
					GotoXY( 29,5 );
					EchoS( '[1]  Edit Sub Sig Access' );
					GotoXY( 29,7 );
					EchoS( '[2]  Edit Topic Sig Access' );
					GotoXY( 29,9 );
					EchoS( '[3]  Apply User Mask' );
					S := 'Enter Choice or [Return] To Exit -> ';
					GotoXY( (80-Length(S)) Div 2, 11);
					EchoS( S );
					Ch := Get_Char;
					Case Ch Of
						'1' : Edit_Usr_Sigs;
						'2' : Edit_Top_Sig;
						'3' : Begin
									Show_Masks;
									S := 'Enter Mask Number to Apply, [Return] To Exit  -> ';
									GotoXY( (80-Length(S)) Div 2, 15);
									EchoS( S );
									Z := Get_Number( 10 );
									If (Z>0) Then Get_MaskData( Z );
									End;
					End; { Case }
					If (Ord(Ch)=Cr) Then Done := True;
				Until (Done);
				Save_Ftu_User;
			End
			Else If (Z<0) Then Begin
				I := I + N;
				If I >= X Then I := X;
			End
			Else If (Z=0) Then I := X;
		End;
	End;

	Procedure Edit_Masks;
	Var
		C,I,X,U,N,Z : Integer;
		Done : Boolean;
		S : String;
		Ch : Char;
	Begin
		For I := 1 to 32 Do
			Sig_Access[I] := I;
		Show_Masks;
		S := 'Enter Mask# To Edit, [Return] To Exit  -> ';
		GotoXY( (80-Length(S)) Div 2, 15);
		EchoS( S );
		Z := Get_Number( U );
		If (Z>0) Then Begin
			Usr_No := Z;
			Clear_Screen;
			CrLf;
			Get_MaskData( Z );
			Done := False;
			Repeat
				Clear_Screen;
				Writev( S, 'Editing User Mask # ', Z );
				GotoXY( (80-Length(S)) Div 2, 3);
				EchoS( S );
				GotoXY( 29,5 );
				EchoS( '[1]  Edit Sub Sig Access' );
				GotoXY( 29,7 );
				EchoS( '[2]  Edit Topic Sig Access' );
				S := 'Enter Choice or [Return] To Exit -> ';
				GotoXY( (80-Length(S)) Div 2, 9);
				EchoS( S );
				Ch := Get_Char;
				Ch := Upper_C( Ch );
				Case Ch Of
					'1' : Edit_Usr_Sigs;
					'2' : Edit_Top_Sig;
				End; { Case }
				If (Ord(Ch)=Cr) Then Done := True;
			Until (Done);
			Save_MaskData( Z );
		End;
	End;

	Procedure Edit_Upld;
	Var
		S : String;
		X : Integer;
	Begin
		Clear_Screen;
		S := Concat( 'Old Upload Path :> ', System2.Upld_Pth );
		X := (80-Length(S)) Div 2;
		GotoXY( X, 4);
		EchoS( S );
		GotoXY( X, 6);
		EchoS( 'New Upload Path :> ' );
		Caps := True;
		Line_In( S, 60);
		If (Length(S)>1) Then System2.Upld_Pth := S;
	End;

	Procedure Edit_Temp;
	Var
		S : String;
		X : Integer;
	Begin
		Clear_Screen;
		S := Concat( 'Old Temporary Path :> ', System2.Temp_Path );
		X := (80-Length(S)) Div 2;
		GotoXY( X, 4);
		EchoS( S );
		GotoXY( X, 6);
		EchoS( 'New Temporary Path :> ' );
		Caps := True;
		Line_In( S, 60);
		If (Length(S)>1) Then System2.Temp_Path := S;
	End;

	Procedure Edit_UserLog;
	Var
		S : String;
		X : Integer;
	Begin
		Clear_Screen;
		S := Concat( 'Old UserLog Path :> ', System2.UserLog );
		X := (80-Length(S)) Div 2;
		GotoXY( X, 4);
		EchoS( S );
		GotoXY( X, 6);
		EchoS( 'New UserLog Path :> ' );
		Caps := True;
		Line_In( S, 60);
		If (Length(S)>1) Then System2.UserLog := S;
		UserFileName := System2.UserLog;
	End;

	Procedure Edit_LogFile;
	Var
		S : String;
		X : Integer;
	Begin
		Clear_Screen;
		S := Concat( 'Old Log File Path :> ', System2.LogFile );
		X := (80-Length(S)) Div 2;
		GotoXY( X, 4);
		EchoS( S );
		GotoXY( X, 6);
		EchoS( 'New Log File Path :> ' );
		Caps := True;
		Line_In( S, 60);
		If (Length(S)>1) Then System2.LogFile := S;
	End;

	Procedure Apply_All_Masks;
	Var
		S : String;
		I, Num, Z : Integer;
		X : Long_Integer;
	Begin
		Num := 1;
		Show_Masks;
		S := 'Enter Mask# To Apply, [Return] To Exit  -> ';
		GotoXY( (80-Length(S)) Div 2, 15);
		EchoS( S );
		Z := Get_Number( 10 );
		If Z>0 Then Begin
			Get_MaskData( Z );
 	  	Reset( Userfile, Userfilename );
 	  	X := Fseek( 0, Handle(Userfile), 2 );
 	  	Close( Userfile );
			If X<0 Then Show_Error( UserFileName, X )
				Else Num := (X Div 292) - 3;
			For I := 1 to Num Do Begin
				Writev( S, 'Updating User# ', I );
				GotoXY( (80-Length(S)) Div 2, 17);
				EchoS( S );
				Usr_No := I;
				Save_Ftu_User;
			End;
		End;
	End;

	Procedure Extend_Ftu_User;
	Var
		Exp_U, Ftu_U, X : Long_Integer;
   	S1, S2, Count : Long_Integer;
		H, I, Num : Integer;
		UsrDataFtu : Text;
		F, S : String;
	Begin
		Exp_U := 0;
		Ftu_U := 0;
   	Reset( Userfile, Userfilename );
   	X := Fseek( 0, Handle(Userfile), 2 );
   	Close( Userfile );
		If X<0 Then Show_Error( UserFileName, X )
			Else Exp_U := (X Div 292) - 1;
		F := 'ftu_data.usr';
		S1 := SizeOf(UserAcs);
		S2 := (Usr_No-1);
		Count := S1 * S2;
		Reset( UsrDataFtu, F );
		X := Fseek( 0, Handle(UsrDataFtu), 2 );
		Close( UsrDataFtu );
		If X<0 Then Show_Error( F, X )
			Else Ftu_U := ( X Div SizeOf(UserAcs) );
		Writev( S, 'Users In Express UserData -> ', Exp_U, '  Users In FTU UserData -> ', Ftu_U );
		GotoXY( (80-Length(S)) Div 2, 20);
		EchoS( S );
		If Ftu_U < Exp_U Then Begin
			Num := Exp_U - Ftu_U;
			Writev( S, 'Extending FTU UserData By ', Num, ' Users...' );
			GotoXY( (80-Length(S)) Div 2, 22);
			EchoS( S );
			H := FOpen( F, 2 );
			If H<0 Then Show_Error( F, H )
			Else Begin;
				X := Fseek( 0, H, 2 );
				For I := 1 to Num Do Begin
					X := FWrite_Usr2( H, SizeOf(UserAcs), UserAcs );
					If X<0 Then Show_Error( F, X );
				End;
				X := Close_File( H );
			End;
		End;
	End;

	Procedure Show_Menu_Cmnd;
	Begin
		Clear_Screen;
		GotoXY( 10,4);
		EchoS( '[A]  Edit User Levels         [B]  Edit SIG Masks' );
		GotoXY( 10,6);
		EchoS( '[C]  Edit Topic Sig Names     [D]  Edit File Sigs' );
		GotoXY( 10,8);
		EchoS( '[E]  Edit Temporary Path      [F]  Edit UserLog Path' );
		GotoXY( 10,10);
		EchoS( '[G]  Edit Log_File Path       [H]  Edit Upload Path' );
		GotoXY( 10,12);
		EchoS( '[I]  Extend FTU Userdata      [J]  Apply A Mask To ALL Users' );
		GotoXY( 32,14);
		EchoS( '[Q]  Quit & Save' );
		GotoXY( 35,16);
		EchoS( 'Choice -> ' );
	End;

	Procedure Menu;
	Var
   	Done : Boolean;
		Ch : Char;
		X,Y : Integer;
	Begin
		Done := False;
		Repeat
			Show_Menu_Cmnd;
			Ch := Get_Char;
			Ch := Upper_C( Ch );
			Case Ch Of
				'A' : Edit_User;
				'B' : Edit_Masks;
				'C' : Edit_TSigName;
				'D' : Edit_Sigs;
				'E' : Edit_Temp;
				'F' : Edit_UserLog;
				'G' : Edit_LogFile;
				'H' : Edit_Upld;
				'I' : Extend_Ftu_User;
				'J' : Apply_All_Masks;
				'Q' : Done := True;
			End; {Case}
		Until (Done);
		GotoXY( 27,24 );
		EchoS( 'Save Changes To SIG Data? ' );
		Repeat
			Ch := Get_Char;
			Ch := Upper_C( Ch );
		Until (Ch='Y') or (Ch='N');
		If Ch = 'Y' Then Begin
			EchoS( 'Yes' );
			Calc_Sig_Nums;
			Save_Ftu_Sig;
		End
		Else EchoS( 'No' );
	End;

Begin									   (* Main Program Begins Here... *)
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

	SetDta( DTA_Data );
 	Get_SysData;
	Lin_Count := 0;
	GotoXY( 16,0 );
	EchoS( 'File Transfer Utility (FTU) Configurator/Editor' );
	GotoXY( 15,1 );
	EchoS( 'Written By Jay L. Bray      Copyright 1989 - 1991' );
	Clear_Screen;
	Caps := False;
	Menu; 
End.

