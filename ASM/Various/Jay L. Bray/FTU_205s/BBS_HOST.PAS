{$S8}
Program Exp_Host;
{$I AuxSubs.Pas}

Const
	Modem = 1;
	Console = 2;
	Timeout = -1;
	BkSp = 8;
	Cr  = 13;
	Lf  = 10;
	Esc = 27;
	Block_Size = 8192;

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
	Undo = 97;
	Help_Key = 98;

Type
	Cstring = Packed Array[0..79] Of Char;
	Fn_String = Packed Array[1..14] of Char;
	Baud_Rates = Packed Array[1..6] of Integer;
	Months = Packed Array[1..12] of String[4];
	BlockIO = Packed Array[1..Block_Size] Of Byte;
	Str60 = String[60];

	SysData = Packed Record
		Hi_Msg         : Integer;
		Todays_Date    : string [8];
		Total_Calls    : Long_Integer;
		Calls_Today    : Integer;
		Feedback_Mode  : Byte;
		Total_Msg_Bases: Byte;
		Min_Baud_Rate  : Byte;            { 0, 1, 2, 3, 4 }
		Max_Baud_Rate  : Byte;            { 0, 1, 2, 3, 4 }
		Start_Baud_Rate: Byte;            { 0, 1, 2, 3, 4 }
		Secondary_Pword: string [15];
		Message_Path   : string [60];
		Userlog_Path   : string [60];
		Helpfile_Path  : string [60];
		Help40_Path    : string [60];
		Logfile        : string [60];
		Message_Drives : Packed Array [1..32] of Char;
		Num_Of_SIGs    : Byte;
		SIG_Name       : Packed Array [1..32] of string [30];
		SIG_Path       : Packed Array [1..32] of string [60];
		SIG_Desc       : Packed Array [1..32] of Boolean;
		SIG_Show_Free  : Packed Array [1..32] of Boolean;
		MC_User_Cmd    : Packed Array [1..26] of Char;
		MC_BBS_Cmd     : Packed Array [1..26] of Char;
		MC_Sec_Lvl     : Packed Array [1..26] of Byte;
		MC_Disp_Str    : Packed Array [0..26] of string [31];
		MC_File_View   : Packed Array [1..26] of string [8];
		BC_User_Cmd    : Packed Array [1..26] of Char;
		BC_BBS_Cmd     : Packed Array [1..26] of Char;
		BC_Sec_Lvl     : Packed Array [1..26] of Byte;
		BC_Disp_Str    : Packed Array [0..26] of string [31];
		BC_File_View   : Packed Array [1..26] of string [8];
		TC_Idx         : Integer;
		TC_Name        : Packed Array [1..50] of string [30];
		TC_Baud        : Packed Array [1..50] of string [4];
		TC_Date        : Packed Array [1..50] of string [8];
		TC_On_At       : Packed Array [1..50] of string [11];
		TC_Off_At      : Packed Array [1..50] of string [11];
		Keep_New_Flag   : Boolean;
		Allow_DL_Over_TL: Boolean;
		Allow_Handles   : Boolean;
	End;
		
	UserData = Packed Record
		In_Use    : Boolean;
	End;

Var
	System      : Sysdata;
	UserRec     : UserData;
	Blkio       : BlockIO;
	Baud        : Baud_Rates;
	Month       : Months;
	Local       : Boolean;     { local log-on flag          }
	Baudrate    : String;      { current caller's baud rate }
	Speed       : Integer;     { Baud rate in numeric Form  }
	Seconds     : Integer;
	Lin_Count   : Integer;     { Counter For Lines Printed On Screen }
	Fnct_Key    : Integer;
	Bd          : Integer;
	Call_300    : Integer;
	Call_1200   : Integer;
	Call_2400   : Integer;
	Call_9600   : Integer;
	Call_Other  : Integer;
	Calls_Today : Integer;
	Total_Calls : Integer;
	Old_Msg     : Integer;
	Hi_Msg      : Integer;
	Msg_Today   : Integer;
	Connections : Integer;
	By_Local    : Integer;
	Date_Today  : Integer;
	Old_Date    : Integer;
	Total_Users : Integer;
	In_Use      : Integer;
	Start_Baud  : Integer;
	Ring_Now    : Boolean;
	Caps        : Boolean;
	Done        : Boolean;
	UserFilename: String;
	Line        : String;
	Binkley     : String;
	Bink_C      : CString;
	BBS         : String;
	BBS_Path    : CString;

	Function SetDrv( Drive: Integer ):Long_Integer;
		GemDos($0E);

	Function CurDisk: Integer;
		GemDos($19);

	Function ChDir( Var P:Cstring ):Integer;
		GemDos($3B);  { Path Name }

	Function Create_File( Var P:Cstring; Attr: Integer ):Integer;
		GemDos($3C);  { Attr: 0=Norm, 1=R/O }

	Function Open_File( Var P: Cstring; Md: Integer ):Integer;
		GemDos($3D);  { Md: 0=Read Only, 1=Write Only, 2=Read & Write}

	Function Close_File( H: Integer ):Integer;
		GemDos($3E);

	Function FRead_Sys(H:Integer; Count:Long_Integer; Var S:Sysdata):Long_Integer;
		Gemdos( $3F );

	Function FRead_Usr(H:Integer; Count:Long_Integer; Var S:UserData):Long_Integer;
		Gemdos( $3F ); 

	Function BlockRead( H: Integer; Sz: Long_Integer; Var Loc: BlockIO ):Long_Integer;
		GemDos($3F);

	Function BlockWrite( H: Integer; Sz: Long_Integer; Var Loc: BlockIO ):Long_Integer;
		GemDos($40);

	Function UnLink(Var P: CString ): Integer;
		GemDos($41);

	Function Fseek( Where : Long_Integer ; FHandle, Mode: Integer ):Long_Integer;
		Gemdos($42); { Mode: 0=From Start, 1=from current pos, 2=from End }	

	Procedure GetDir( Var P:CString; Drive: Integer );
		GemDos($47);

	Function Exec( Md: Integer; Var Fil, Com, Env: CString ):Integer;
		GemDos($4B);

	Function SFirst( Var Name:Cstring; Attr: Integer ):Integer;
		Gemdos($4E);

	Function SNext: Integer;
		Gemdos($4F);

	Function Bconstat( Device: Integer ):Integer;
 	  Bios(1);

	Function Inready( Device: Integer ):Boolean;
	Var
		X: Integer;
	Begin
		X := Bconstat( Device );
		If ( X=0 ) Then Inready := False Else Inready := True;
	End;

	Function Bconin( Device: Integer ):Long_Integer;
 	  Bios(2);

	Procedure Bconout( Device: Integer; Ch: Char );
		Bios(3);

	Procedure RSconf( Speed, Flowctl, Ucr, Rsr, Tsr, Scr : Integer );
		XBios(15);

	Function OffGiBit( Bitnum : Integer ):Integer;
		XBios(29);

	Function OnGiBit( Bitnum : Integer ):Integer;
		XBios(30);

	Function Timer: Long_Integer;
	Begin
		Super( True );
 		Timer := Lpeek($4Ba);
 	 	Super( False );
	End;

	Procedure Zerotimer;
	Begin
   	Super( True );
 		Lpoke( $4Ba, 1 );
 		Super( False );
	End;

	Function Carrier: Boolean;	
	Var
		X : Integer;
	Begin
		Super( True );
		X := Wpeek( $fffa00 );
		X := (X & 2);
		If X = 0 Then Carrier := True
			Else Carrier := False;
		Super( False );
		If Local Then Carrier := True;
	End;

	Function Ring: Boolean;	
	Var
		X : Integer;
	Begin
		Super( True );
		X := Wpeek( $fffa00 );
		X := (X & 64);
		If X = 0 Then Ring := True
			Else Ring := False;
		Super( False );
	End;

	Function Upper_C( C: Char ): Char;
	Begin
		If ( C In ['a'..'z'] ) Then
			C := Chr( Ord(C) -32 );
		Upper_C := C		
	End;

	Function Lower_C( C: Char ):Char;
	Begin
   		Lower_C := C;
   	If ( C In ['A'..'Z'] ) Then
   		Lower_C := Chr( Ord(C) + 32 )
	End;

	Procedure Upcase( Var Line: String );
	Var
   	I : Integer;
	Begin
   	If Length(Line)>0 Then Begin
			For I := 1 To Length(Line) Do
 			If Line[I] In ['a'..'z'] Then
      	Line[I] := Chr( Ord(Line[I]) - 32 );
			End;
	End;

	Procedure Pause( Jif : Long_Integer );
	Var
		X : Long_Integer;
	Begin
		X := Timer + Jif;
		While X >= Timer Do;
	End;

	Procedure Hang_Up;
	Var
		X : Integer;
	Begin
		X := OnGiBit( 16 );
		Pause( 400 );
		X := OffGiBit( $ffef );
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
   	For X := 1 To Length(Source) Do
   		Dest[X-1] := Source[X];
   	X := Length(Source);
   	Dest[X] := Chr(0);
	End;

	Function FCreate( Var F:String; Attr: Integer ):Integer;
	{ Attr: 0=Norm, 1=R/O }
	Var
		C : Cstring;
	Begin
		MakeCstring( F, C );
		FCreate := Create_File( C, Attr );
	End;

	Function FOpen( Var F: String; Md: Integer ):Integer;
	{ Md: 0=Read Only, 1=Write Only, 2=Read & Write}
	Var
		C : Cstring;
	Begin
		MakeCstring( F, C );
		FOpen := Open_File( C, Md );
	End;

	Function Exists( Filename: String ):Boolean;
	Var
		Junkfile : Text;
	Begin
		Io_Check( False );
   	Reset( Junkfile, Filename );
   	If Io_result=0 Then Exists := True
   	Else Exists := False;
   	Close( Junkfile );
		Io_Check( True );
	End;
								
	Procedure Put_Console( Ch : Char );
	Begin
		Bconout( Console, Ch );
	End;

	Procedure Put_Modem( Ch : Char );
	Begin
		Bconout( Modem, Ch );
	End;

	Procedure Clear_Local;
	Begin
		Put_Console( Chr(Esc) );
		Put_Console( 'Y' );
		Put_Console( Chr(38) );
		Put_Console( ' ' );
		Put_Console( Chr(Esc) );
		Put_Console( 'J' );
		Lin_Count := 0;		
	End;

	Procedure Clear_Screen;
	Begin
   	If Carrier Then Begin
   		If (Not Local) Then Begin
   			Put_Modem( Chr(Esc) );
   			Put_Modem( 'H' );
   			Put_Modem( Chr(Esc) );
   			Put_Modem( 'J' );
				Put_Modem( Chr(12) );
			End;
			Clear_Local;		
		End;
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
		Put_Console( Chr(38) );
		Put_Console( ' ' );
 		Put_Console( Chr(Esc) );
 		Put_Console( 'M' );
		Get_Curs;
 		Put_Console( Chr(Esc) );
 		Put_Console( 'A' );
	End;

	Procedure Show_Top;
	Var
		I,X : Integer;
		S,T : String;
	Begin
		Clear_Local;
		InverseVideo;
 (*        '01234567890123456789012345678901234567890123456789012345678901234567890123456789' *)
		GotoXY( 0,0 );
		Write( '      BBS Host Server      For Express BBS 1.30 - 1.50      By Jay L. Bray      ' );
		GotoXY( 0,1 );
		Write( '                                                                                ' );
		GotoXY( 0,2 );
		Write( ' Total Calls: ____   Calls Today: ____   Connections: ____   Local Logons: ____ ' );
		GotoXY( 0,3 );
		Write( ' Connections At -->  300: ____  1200: ____  2400: ____  9600: ____  14.4k: ____ ' );
		GotoXY( 0,4 );
		Write( ' Hi Msg#: _____  Msgs Posted Today: ____    Users Allocated: ____  In Use: ____ ' );
		GotoXY( 0,5);
		Write( ' Net Calls Received: ____      Net Msgs Received: ____      Net Msgs Sent: ____ ' );
		NormVideo;
		GotoXY( 10,7 );
		Write( 'Commands:' );
		GotoXY( 2,9 );
		Write( '[ F1 ] Local Logon' );
		GotoXY( 2,11 );
		Write( '[Undo] Return To DeskTop' );

		GotoXY( 55,7 );
		Write( 'Last 14 Callers:' );
		For I := 1 to 14 Do Begin
			GotoXY( 36,8+I );
			Write( I:2,'. ',System.TC_Name[I+36] );  {30}

			GotoXY( 62,8+I );
			Line := System.TC_Date[I+36]; {8}
			S := Copy( Line, 1,2 );
			Readv( S,X );
			T := Month[X];
			S := Copy( Line, 4,2 );
			Write( '  ',T,S );

			GotoXY( 72,8+I );
			Line := System.TC_On_At[I+36]; {11}
			S := Copy( Line, 1,2 );
			T := Copy( Line, 10,2 );
			Readv( S,X );
			If (X=12) and (T='am') Then X := 0
			Else If T='pm' Then X := X + 12;
			Writev( T, X:2 );
			S := Copy( Line, 3,6 );
			Write( T,S );
		End;
	End;

	Procedure Update_Stats;
	Begin
		InverseVideo;
		GotoXY( 14,2 );
		Write( Total_Calls );
		GotoXY( 34,2 );
		Write( Calls_Today );
		GotoXY( 54,2 );
		Write( Connections );
		GotoXY( 75,2 );
		Write( By_Local );

		GotoXY( 26,3 );
		Write( Call_300 );
		GotoXY( 38,3 );
		Write( Call_1200 );
		GotoXY( 50,3 );
		Write( Call_2400 );
		GotoXY( 62,3 );
		Write( Call_9600 );
		GotoXY( 75,3 );
		Write( Call_Other );

		GotoXY( 10,4 );
		Write( Hi_Msg );
		GotoXY( 36,4 );
		Write( Msg_Today );

		GotoXY( 61,4 );
		Write( Total_Users );
		GotoXY( 75,4 );
		Write( In_Use );

	(*	GotoXY( 21,5 );
		Write( System.TC_Idx ); *)

		NormVideo;
	End;

	Procedure Clear_Stats;
	Begin
		Calls_Today := 0;
		Connections := 0;
		By_Local    := 0;

		Call_300    := 0;
		Call_1200   := 0;
		Call_2400   := 0;
		Call_9600   := 0;
		Call_Other  := 0;

		Msg_Today   := 0;
	End;

	Procedure Get_SysData;
	Var
		SysData : String;
		SysDataFile : text;
		Count : Long_Integer;
	Begin
		SysData := 'sysdata.dat';
		Reset( SysDataFile, Sysdata );
		Count := Fseek( 0, Handle(SysdataFile), 0);
		Count := FRead_Sys( handle(SysDataFile), Sizeof(System), System );
		Close( SysDataFile );
		Connections := System.Calls_Today;
		If (Calls_Today=0) Then Calls_Today := Connections; 
		Total_Calls := System.Total_Calls;
		Hi_Msg      := System.Hi_Msg;
		If (Old_Msg=0) Then Old_Msg := Hi_Msg
		Else If (Hi_Msg>Old_Msg) Then Msg_Today := (Hi_Msg - Old_Msg);
		UserFileName := System.UserLog_Path;
	End;

	Procedure Get_UserData;
	Var
   	S1, X, Count : Long_Integer;
		I : Integer;
		UserFile : Text;
	Begin
		Reset( Userfile, Userfilename );
		X := Fseek( 0, Handle(Userfile), 2 );
		Total_Users := (X Div 288) - 3;
		Close( Userfile );

		In_Use := 0;
		Reset( Userfile, Userfilename );
		For I := 1 To Total_Users Do Begin
			Count := Fseek( 288, Handle(UserFile), 1);
			Count := FRead_Usr( handle(UserFile), SizeOf(UserRec), UserRec );
			If (UserRec.In_Use) Then In_Use := In_Use + 1;
		End;
		Close( Userfile );
	End;

	Procedure Bell( Jif : Long_Integer );
	Begin
		Pause( Jif );
		If (Not Local) Then Put_Modem( Chr(7) );
		Put_Console( Chr(7) );
	End;

	Procedure Put_Char( Ch: Char );
	Begin
 		If (Not Local) Then Put_Modem( Ch );
	 	Put_Console( Ch );
	End;

	Procedure CCrLf;
	Begin
		Lin_Count := Lin_Count + 1;
		If Lin_Count > 17 then Del_Line;
		Put_Console( Chr(Cr) );
		Put_Console( Chr(Lf) );
	End;

	Procedure EchoC( L : String );
	Var
   	I : Integer;
	Begin
 		For I := 1 To Length( L ) Do Begin
 			Put_Console( L[I] );
   	End;
	End;

	Procedure EchoCE( L : String );
	Begin
		EchoC( L );
		CCrLf;
	End;

	Procedure CrLf;
	Begin
		If Carrier Then Begin
			If (Not Local) Then Begin
				Put_Modem( Chr(Cr) );
				Put_Modem( Chr(Lf) );
			End;
			CCrLf;
		End;
	End;

	Procedure MCrLf;
	Begin
		Put_Modem( Chr(Cr) );
		Put_Modem( Chr(Lf) );
	End;

	Procedure EchoM( L : String );
	Var
		I : Integer;
	Begin
		For I := 1 to Length( L ) Do Put_Modem( L[I] );
	End;

	Procedure EchoME( L : String );
	Begin
   	EchoM( L );
   	MCrlf;
	End;

	Procedure EchoS( L : String );
	Var
		I : Integer;
	Begin
		For I := 1 to Length( L ) Do Put_Char( L[I] );
	End;

	Procedure EchoSE( L : String );
	Begin
   	EchoS( L );
   	Crlf;
	End;

	Procedure Show_Wrong;
	Begin
		EchoSE( 'Wrong Key Try ''?'' ');
	End;

	Procedure Show_Msg( S: String );
	Begin
		GotoXY( 20,24 );
		Put_Console( Chr(27) );
		Put_Console( 'K' );
		EchoC( S );
	End;

	Procedure Back_Space;
	Begin
	  Put_Char( Chr(Bksp) );
 		Put_Char( ' ' );
 		Put_Char( Chr(Bksp) );
	End;

	Function Get_Modem : Integer;
	Var
		X : Long_Integer;
	Begin
		X := Bconin( Modem );
		Get_Modem := X;
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

	Function Scan_Console : Integer;
	Var
		X : Integer;
	Begin
		X := TimeOut;
		If Inready(Console) Then X := Get_Console;
		Scan_Console := X;
	End;

	Function Scan_Input : Integer;
	Var
		X : Integer;
	Begin
		X := TimeOut;
	 	If Inready(Modem) And (Not Local) Then X := Get_Modem
		Else If Inready(Console) Then X := Get_Console;
		Scan_Input := X;
	End;

	Function Get_Char: Char;
	Var
   	Maxtime : Long_Integer;
   	I : Integer;
		Ch : Char;
		Ok,Sec2 : Boolean;
	Begin
		Ok := False;
		Sec2 := False;
   	Maxtime := Timer + 36200;
		I := TimeOut;
   	Repeat
			Seconds := ( MaxTime-Timer) Div 200;
			If (Seconds=30) And (Sec2=False) Then Begin
				CrLf; CrLf; EchoSE('\r<<30 Seconds Till Auto-Logoff>>\b'); CrLf; Sec2:=True; End;
  		I := Scan_Input;
 			If (I>31) And (I<129) or (I=Cr) Then Ok := True;
   	Until (I>Timeout) Or (Carrier=False) Or (Timer>Maxtime) Or (Ok);
		If Timer>MaxTime Then Hang_Up;
		Get_char := Chr( I );
	End;

	Procedure Line_In( Var Temp: String; Lgth : Short_Integer );
	Var
   	Ch : Char;
		X : Short_Integer;
   	Dun : Boolean;
	Begin
   	Temp := '';
   	Dun := False;
		X := 0;
   	Repeat
   		Ch := Get_char;
			If (Caps) Then Ch := Upper_C( Ch );
	 		If (Ord(Ch)=Cr) or (Carrier=False) Then Dun := True
			Else
				If (Ord(Ch)=Bksp) And (X>=1) Then Begin
					Back_Space;
					X := X - 1;
					Temp[0] := Chr(X);
				End
			Else
				Begin
					Temp := Concat( Temp, Ch );
					Put_Char( Ch );
					X := X + 1;
				End;
		Until (Dun) or (X = Lgth);
	End;

	Function Yes_No( Md : Char ) : Boolean;
	Var
		Ch : Char;
		K : Short_Integer;
	Begin
		Yes_No := False;
		If (Md='Y') Then EchoS( '(\gY\b/n) ' )
			Else EchoS( '(y/\gN\b) ' );
		Repeat
			Ch := Get_Char;
			Ch := Upper_C( Ch );
			K := Ord(Ch);
		Until (Ch='Y') or (Ch='N') or (K=Cr) or (Carrier=False);
		If (Ch='Y') or ((Md='Y') And (K=Cr)) Then Begin
			EchoSE( 'Yes' );
			Yes_No := True;
		End
			Else EchoSE( 'No' );
	End;

	Function Get_Number( Num: Integer ): Integer;
	Var
		Temp : String[8];
		X,Ln : Integer;
		I : Long_Integer;
		Ch : Char;
	Begin
		Temp := '';
		Writev( Temp, Num);
		Ln := Length( Temp );
		Temp := '';
		Repeat
			Repeat
				Repeat
					If (Not Local) Then Ch := Get_Char
						Else Ch := Chr(Get_Console);
				Until (Ch In['0'..'9']) or (Ord( Ch)=Cr) or (Carrier=False);
				If Ch In['0'..'9'] Then Begin
					Temp := Concat( Temp, Ch );
					EchoS( Ch );
				End;
			Until (Length(Temp)=Ln) or (Ord(Ch)=Cr) or (Carrier=False);
			If Length(Temp) >0 Then Begin
				Readv( Temp, I );
				If (I>Num) Then Begin
					For X := 1 to (Length(Temp)) Do
						Back_Space;
					Temp := '';
				End;
			End
			Else I := -1;
		Until (I<=Num) or (Carrier=False);
		Get_Number := I;
	End;

	Procedure Flush_Input;
	Var
   	C : Long_Integer;
	Begin
   	If Not Local Then Begin
   		While Inready( Modem ) Do
 			C := Bconin( Modem );
   	End;
   	While Inready( Console ) Do
   		C := Bconin( Console );
	End;

	Procedure Do_Bootup_Modem;
	Var
		X, TBytes : Long_Integer;
		I : Integer;
		B : Byte;
		MdmFile : String;
		Mdm : Text;
	Begin
		MdmFile := 'Bootup.Mdm';
		If Exists( MdmFile ) Then Begin
			Reset( Mdm, MdmFile );
			X := Fseek( 0, Handle(Mdm), 0);
			TBytes := BlockRead( Handle(Mdm), Block_Size, BlkIO );
			If (TBytes>0) Then Begin
				For I := 1 To TBytes Do Begin
					B := BlkIo[I];
					Put_Modem( Chr( B ) );
					If (B=39) Then Pause( 1000 )
					Else If (B=Lf) Then Pause( 350 )
					Else Pause( 30 );
				End;
				Flush_Input;
			End;
		End;
	End;

	Procedure Reset_Modem;
	Begin
		EchoME( 'ATS0=1 M0 S2=128 X4' );
		Pause( 200 );
		Flush_Input;
	End;

	Procedure Do_Reset_Modem;
	Var
		X, TBytes : Long_Integer;
		I : Integer;
		B : Byte;
		MdmFile : String;
		Mdm : Text;
	Begin
		ZeroTimer;
		Hang_Up;
		Flush_Input;
		Show_Msg( 'Reseting Modem...' );
		MdmFile := 'Reset.Mdm';
		RSconf( Baud[Start_Baud], -1, -1, -1, -1, -1 );
		Pause( 200 );
		EchoME( 'ATZ' );
		Pause( 200 );
		Flush_Input;
		If Exists( MdmFile ) Then Begin
			Write( 'From Reset.Mdm...' );
			Reset( Mdm, MdmFile );
			X := Fseek( 0, Handle(Mdm), 0);
			TBytes := BlockRead( Handle(Mdm), Block_Size, BlkIO );
			If (TBytes>0) Then Begin
				For I := 1 To TBytes Do Begin
					B := BlkIo[I];
					Put_Modem( Chr( B ) );
					If (B=39) Then Pause( 1000 )
					Else If (B=Lf) Then Pause( 350 )
					Else Pause( 30 );
				End;
				Flush_Input;
			End;
		End
		Else Reset_Modem;
	End;

	Procedure Exec_BBS;
	Var
		I, X : Integer;
		C, E : CString;
		Bink : Text;
	Begin
		CrLf;
		EchoSE( 'Loading BBS, Please Stand-By...' );
		If Not Local Then Begin
			ReWrite( Bink, BinkLey );
			WriteLn( Bink, Bd );
			Close( Bink );
		End;
		For I := 0 to 27 Do C[I] := Chr(0);
		For I := 0 to 27 Do E[I] := Chr(0);
		X := Exec( 0, BBS_Path, C, E );
	End;

	Procedure Show_Time_Date;
	Var
		X, H, S : Integer;
		M, D, Y : Integer;
		St : String[12];
		Line: String;
	Begin
		Save_Curs;
		Hide_Curs;
		Get_Date( M, D, Y );		
		If Old_Date=0 Then Old_Date := (M*12)+D
		Else If (M*12)+D>Old_Date Then Begin
			ZeroTimer;
			Clear_Stats;
			Old_Date := (M*12)+D;
			Show_Top;
			Update_Stats;
		End;
		Writev( Line,Month[M], D:2, ', ', Y );
		GotoXY(26,7);
		Write( Line );

		Get_Time( H, M, S );
		GotoXY(40,7);
		Writev( St, H:2, ':' );
		If M<10 then St := Concat( St, '0' );
		Writev( Line, M, ':' );
		St := Concat( St, Line );
		If S<10 Then St := Concat( St, '0' );
		Writev( Line, S );
		St := Concat( St, Line );
		Write( St );
		Get_Curs;
		Show_Curs;
	End;

	Procedure Ask_Command;
	Var
		X : Integer;
	Begin
		CrLf;
		EchoSE( '****************************' );
		EchoSE( '*      Welcome To The      *' );
		EchoSE( '*  Express BBS Host Server *' );
		EchoSE( '*  Written & Copyright By  *' );
		EchoSE( '*       Jay L. Bray        *' );
		EchoSE( '*   Pre-Release Version    *' );
		EchoSE( '****************************' );
		CrLf;
		CrLf;
		EchoSE( 'Enter Your Express-Net Node# Now, or' );
		EchoS ( 'Press <Return> To Enter The BBS -> ' );
		X := Get_Number( 32767 );;
		If (X>=0) Then Begin
			CrLf;
			EchoSE( 'Invalid Node#, Try Again Next Call...' );
			CrLf;
		End
		Else CrLf;
		Exec_BBS;
	End;

	Procedure Get_BaudRate;
	Var
		Ch : Char;
		X : Integer;
		I : Long_Integer;
	Begin
		GotoXY( 31,24 );
		Write( 'Determining Baud Rate...' );
		I := Timer + 2000;
		Loop
			Exit If (Timer>=I) or (Inready( Modem ) );
		End;
		BaudRate := '';
		While InReady( Modem ) Do Begin
			Ch := Chr( Get_Modem );
			BaudRate := Concat( BaudRate, Ch );
		End;
		Write( BaudRate );
		If Pos( '19200', BaudRate ) >0 Then Speed := 19200
		Else If Pos( '14400', BaudRate ) >0 Then Speed := 14400
		Else If Pos( '9600', BaudRate ) >0 Then Speed := 9600
		Else If Pos( '2400', BaudRate ) >0 Then Speed := 2400
		Else If Pos( '1200', BaudRate ) >0 Then Speed := 1200
		Else If Pos( 'CONNECT', BaudRate ) >0 Then Speed := 300;
		If Speed<>0 Then Begin
			If Speed > 14000 Then Begin; X := 1; Call_Other:=Call_Other+1; End
			Else If Speed = 9600 Then Begin; X := 2; Call_9600:=Call_9600+1; End
			Else If Speed = 2400 Then Begin; X := 3; Call_2400:=Call_2400+1; End
			Else If Speed = 1200 Then Begin; X := 4; Call_1200:=Call_1200+1; End
			Else Begin; X := 5; Call_300:=Call_300+1; End;
			RSconf( Baud[X], -1, -1, -1, -1, -1 );
			If (X=5) Then Bd := 0
			Else If (X=4) Then Bd := 1
			Else If (X=3) Then Bd := 2
			Else If (X=2) Then Bd := 3
			Else Bd := 4;
			Pause( 200 );
		End;
	End;

	Function Wait_Ring: Boolean;
	Var
		X, K, Count : Integer;
		I : Long_Integer;
		Ch : Char;
	Begin
		X := UnLink( Bink_C );
		Get_SysData;
		Get_UserData;
		Show_Top;
		Update_Stats;
		Do_Reset_modem;
		Fnct_Key := 0;
		Wait_Ring := False;
		Ring_Now := False;
		Local := False;
		Show_Msg( 'Waiting For A Call, Or Your Command....' );
		I := Timer + 100;
		Repeat
			If Timer >= I Then Begin
				X := Scan_Console;
				Show_Time_Date;
				I := Timer + 100;
			End;
			If (Ring) Then Begin
				Pause( 50 );
				If (Ring) Then Ring_Now := True;
			End;
			If (Carrier) Then Pause( 100 );
		Until (Carrier) or (Ring_Now) or (Fnct_Key=F1) or (Fnct_Key=Undo);
		If (Fnct_Key=F1) Then Begin; Local := True; By_Local:=By_Local+1; End;

		Speed := 0;
		If (Ring_Now) Then Begin
			Calls_Today := Calls_Today + 1;
			Show_Msg( 'Ring...' );
			Flush_Input;
			Pause( 400 );
			GotoXY( 28,24 );
			Write( 'Waiting For A Carrier' );
			I := Timer + 5000;
			Loop
				Exit If (Carrier) or (Timer>=I);
			End;
		End;

		If (Carrier) Then Begin
			Show_Msg( 'Connect...' );
			If (Fnct_Key=0) Then Get_Baudrate;
		End;
		Count := 0;
		X := 0;
		If (Fnct_Key=0) And (Carrier) And (Speed=0) Then Begin
			Repeat
				Count := Count + 1;
				X := X + 1;
				If X>6 Then X := 1;
				RSconf( Baud[X], -1, -1, -1, -1, -1 );
				If (X=5) Then Bd := 0
				Else If (X=4) Then Bd := 1
				Else If (X=3) Then Bd := 2
				Else If (X=2) Then Bd := 3
				Else Bd := 4;
				Pause( 500 );
				EchoSE( 'Press That [Return] Key Now...' );
				I := Timer + 1000;
				Loop
					If Inready( Modem ) Then Ch := Get_Char;
					Exit If (Ord(Ch)=Cr) or (Timer>=I);
				End;
				If (Ord(Ch)=Cr) Then Begin
					If (Bd=4) Then Call_Other:=Call_Other+1
					Else If (Bd=3) Then Call_9600:=Call_9600+1
					Else If (Bd=2) Then Call_2400:=Call_2400+1
					Else If (Bd=1) Then Call_1200:=Call_1200+1
					Else Call_300:=Call_300+1;
					EchoSE('Great! - Loading The BBS Now...' );
				End;
			Until (Count=18) or ( Ord(Ch)=Cr );
		End
		Else If Fnct_Key=Undo Then Done := True;
		If ( Ord(Ch)=Cr ) or (Fnct_Key=F1) or (Speed>0) Then Wait_Ring := True
		Else Wait_Ring := False;
	End;

Begin

	BBS := 'bbs.Prg';
	MakeCString( BBS, BBS_Path );
	BinkLey := 'Binkley.Mdm';
	MakeCString( Binkley, Bink_C );
	Done := False;
	ZeroTimer;
	Old_Msg := 0;

	Baud[1] := 0; {19200 & 14400}
	Baud[2] := 1; {9600}
	Baud[3] := 4; {2400}
	Baud[4] := 7; {1200}
	Baud[5] := 9; {300}

	Month[1] := 'Jan ';
	Month[2] := 'Feb ';
	Month[3] := 'Mar ';
	Month[4] := 'Apr ';
	Month[5] := 'May ';
	Month[6] := 'Jun ';
	Month[7] := 'Jul ';
	Month[8] := 'Aug ';
	Month[9] := 'Sep ';
	Month[10] := 'Oct ';
	Month[11] := 'Nov ';
	Month[12] := 'Dec ';
	Fnct_Key := 0;
	Lin_Count := 0;

	Get_SysData;
	Bd := System.Start_Baud_Rate;
	If (Bd=0) Then Start_Baud := 5
	Else If (Bd=1) Then Start_Baud := 4
	Else If (Bd=2) Then Start_Baud := 3
	Else If (Bd=3) Then Start_Baud := 2
	Else If (Bd=4) Then Start_Baud := 1;
	RSconf( Baud[Start_Baud], -1, -1, -1, -1, -1 );
	Pause( 200 );
	Clear_Stats;
	Do_Bootup_Modem;

	Repeat
		If (Wait_Ring) Then Ask_Command;
	Until (Done);

	EchoME('ATH1');
End.

