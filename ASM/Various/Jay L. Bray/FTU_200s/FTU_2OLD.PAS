{$S16}
Program FTU_200;
{$I D:\Pascal\Per_Pasc\AuxSubs.Pas}

Const
	Modem = 1;
	Console = 2;
	Timeout = -1;
	Input_Mode = 0;
	Output_Mode = 1;
	Update_Mode = 2;
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
	Cstring = Packed Array[0..79] Of Char;
	Fn_String = Packed Array[1..14] of Char;
	BlockIO = Packed Array[1..Block_Size] Of Byte;
	Months = Packed Array[1..12] of String[4];
	Arc_Types = Packed Array[1..5] of String[3];
	ArcTypes = Packed Array[1..8] of String[10];
	ZipTypes = Packed Array[1..5] of String[10];
	SitTypes = Packed Array[1..10] of String[10];
	Ratings = Packed Array[1..6] of String[10];
	DLine = Packed Array[1..5] of String[80];
	MLine = Packed Array[1..20] of String[80];
	Errors = Packed Array[1..70] of String[40];
	Xyzs = Packed Array[1..22] of String[55];
	Tran = Packed Array[0..4] of String[8];
	Str60 = String[60];

	DTA = Packed Record
		Reserved  : Packed Array[0..19] Of Byte;
		Reserved2 : Byte;
		Attribute : Byte;
		Time      : Integer;
		Date      : Integer;
		Size      : Long_Integer;
		Name      : Fn_String;
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
 		TSigcount: Integer;
 		TNames   : Array[1..32] Of String[30];
		Sigcount : Packed Array[0..31] Of Integer;
		Names    : Packed Array[0..1023] Of String[30];
		Paths    : Packed Array[0..1023] Of Str60;
		Show_Free: Packed Array[0..1023] Of Boolean;
		Use_Desc : Packed Array[0..1023] Of Boolean;
		Temp_Path: Str60;
 		Userlog  : Str60;
		LogFile  : Str60;
		Upld_Pth : Str60;
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
		Sig_read_mask  : Long_Integer;  { Search Data }
		Sig_validate   : Long_Integer;  {   "     "   }
		Sig_edit_desc  : Long_Integer;  {   "     "   }
		Sig_delete_file: Long_Integer;  {   "     "   }
{ ==========================  New In 1.60  ===================== }
		Sig_Accs_Mask  : Long_Integer;  {   "     "   }
{ ============================================================== }
	End;

	BM_Area = Packed Record          { Batch Mark Info }    
		BM_Fname  : String;
		BM_Fsize  : Long_Integer;
		BM_Sig	  : Integer;
		BM_D_Time : Integer;
	End;

Var
	System2     : SigData2;
	UserRec     : Userdata;           { the user's userlog file entry      }
	UserAcs     : UserAccess;
	Blkio       : BlockIO;
	Month       : Months;
	Trans       : Tran;
	Arc_Type    : Arc_Types;
	ArcType     : ArcTypes;
	ZipType     : ZipTypes;
	SitType     : SitTypes;
	Rating      : Ratings;
	Err         : Errors;
	Xyz         : Xyzs;
	Cur_Time    : Integer;
	Cur_Date    : Integer;
	Local       : Boolean;            { local log-on flag                }
	Usr_Addr    : Long_Integer;
	Timeon      : Long_Integer;       { time the user Entered Files Area }
	TimeLeft    : Long_Integer;       { Time the user has left online...}
	Connected   : Long_Integer;				{ Time The User Has Been Online...}
	Ftu_Length  : Long_Integer;  { Length Between FTU & UserData }
	Time_Start  : Long_Integer;
	Time_Finish : Long_Integer;
	Xfer_Time   : Long_Integer;
	M, D, Y     : Integer;
	NumSigs     : Integer;
	VT52        : Boolean;
	Result      : Boolean;
	Stop_Send   : Boolean;
	Sig_Access  : Packed Array[1..32] Of Integer;
	Sig2_Access : Packed Array[0..1023] Of Integer;
	Sig2_Valid  : Packed Array[0..1023] Of Integer;
	Sig2_Edit   : Packed Array[0..1023] Of Integer;
	Sig2_Kill   : Packed Array[0..1023] Of Integer;
	BMark       : Array[1..20] Of BM_Area;
	SMark       : Array[1..16] Of BM_Area;
	UsrDataFtu  : Text;
	Ftu_UserFile: Str60;
	Ftu_MaskFile: Str60;
	Log_Filename: Str60;
	Userfile    : File Of Userdata;   { the userlog data file              }
	Userfilename: Str60;              { filename For the userfile          }
	DTA_Data    : DTA;                { Blkio used For dir searches       }
	Use_Desc    : Boolean;
	Show_Free   : Boolean;
	Sig_Num     : Integer;
	Usr_No      : Integer;
	Usr_Tmp     : Integer;
	Visitor_Rec : Integer;
	NewUser_Rec : Integer;
	Usr_Lst_Call: Integer;
	Baudrate    : String;       { current caller's baud rate         }
	Number      : String;       { user number passed from BBS        }
	Width       : String;
	Time_left   : String;       { time left For caller on this call  }
	Translation : String;
	Speed       : Integer;      { Baud rate in numeric Form          }
	Minutes     : Integer;      { Minutes left this call             }
	Seconds     : Integer;      { Seconds Left Before Timeout        }
	BM_Num      : Integer;      { Number of files in Batch Mark Area }
	Find_Date   : Integer;
	Lin_Count   : Integer;      { Counter For Lines Printed On Screen }
	Lines       : Integer;      { Counter For Lines Shown During Scan }
	Msg_Ln      : Integer;      { Counter For # of Lines in Message }
	Lin_No      : Integer;      { Current Line# in Message }
	Max_Sig     : Integer;
	Cps         : Integer;
	Tot_DL_Time : Integer;
	DL_Time     : Integer;
	Return      : Integer;
	Eod         : Integer;      { End Of Directory Flag }
	ArcT        : Integer;
	Drv         : Integer;
	Fnct_Key    : Integer;
	Top_Sig     : Integer;
	Max_Sub     : Integer;
	Max_Avail   : Integer;
	Top_Cntr    : Integer;
	Sig_Cntr    : Integer;
	New_Dls     : Integer;
	New_Uls     : Integer;
	Transv      : Integer;
	Dummy_I     : Integer;
	Dummy_L     : Long_Integer;
	Prompt      : Char;
	WidT        : Short_Integer;
	Forced_Off  : Boolean;
	One_Sig     : Boolean;
	Valid_New   : Boolean;
	WW_Toggle   : Boolean;
	Word_Pending: Boolean;
	SaveM       : Boolean;
	Sig_Op      : Boolean;
	Sig_Ops     : Boolean;
	Chat        : Boolean;
	Abort       : Boolean;
	Is_Ok       : Boolean;
	Caps        : Boolean;
	Color				: Boolean;
	Inverse     : Boolean;
	Arc_File    : Boolean;
	Hide_Mode   : Boolean;
	New_Files   : Boolean;
	Find_File   : Boolean;
	Kywrd_Srch  : Boolean;
	Quick_Scan  : Boolean;
	List_Mode   : Boolean;
	Scan_Mode   : Boolean;
	Tot_Sig     : Boolean;
	Batch_Mode  : Boolean;
	Batch_Upld  : Boolean;
	New_Line    : Boolean;
	Shw_Time    : Boolean;
	Srch_Str    : String;
	F_Name      : String;
	File_Name   : String;
	Ftu_Path    : String;
	FPath       : String;
	Desc_Path   : String;
	Sspec       : String;
	Cmd_Line    : String[128];
	Xfer_Type   : String;
	Line        : String;
	MLin        : String;  { Temp Line In Message }
	Mil_Time    : String[8];
	Fname       : Cstring;
	Desc_Path_C : CString;
	Xyz_Path    : CString;
	F_Path      : CString;
	Boot_Path   : CString;
	Boot_drv    : Integer;
	MesgL       : MLine;
	DescL       : Dline;

	Procedure Dummy_Routine;
	Begin
		Write('...Program Starts Here...');
	End;

	Function Proc_addr( Procedure P ) : Long_Integer;
      External;

	Function Addr( Var What : UserData ) : Long_Integer;
		External;

	Function SetDrv( Drive: Integer ):Long_Integer;
		GemDos($0E);

	Function CurDisk: Integer;
		GemDos($19);

	Procedure SetDta( Var B: DTA );
		Gemdos($1A);

	Function Get_SDate: Integer;
		GemDos($2A);

	Function Get_STime: Integer;
		GemDos($2C);

	Function DFree( Var B:BlockIO; Drive: Integer ):Integer;
		GemDos($36); { 1:L=Free Clusters, 3:L=Sect Size, 4:L=Sect/Cluster}

	Function ChDir( Var P:Cstring ):Integer;
		GemDos($3B);  { Path Name }

	Function Create_File( Var P:Cstring; Attr: Integer ):Integer;
		GemDos($3C);  { Attr: 0=Norm, 1=R/O }

	Function Open_File( Var P: Cstring; Md: Integer ):Integer;
		GemDos($3D);  { Md: 0=Read Only, 1=Write Only, 2=Read & Write}

	Function Close_File( H: Integer ):Integer;
		GemDos($3E);

	Function BlockRead( H: Integer; Sz: Long_Integer; Var Loc: BlockIO ):Long_Integer;
		GemDos($3F);

	Function BlockWrite( H: Integer; Sz: Long_Integer; Var Loc: BlockIO ):Long_Integer;
		GemDos($40);

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

	Function UnLink(Var P: CString ): Integer;
		GemDos($41);

	Function Fseek( Where : Long_Integer ; FHandle, Mode: Integer ):Long_Integer;
		Gemdos($42); { Mode: 0=From Start, 1=from current pos, 2=from End }	

	Function ChMode(Var P:CString; Attr: Integer; Md: Integer ):Integer;
		Gemdos($43);

	Procedure GetDir( Var P:CString; Drive: Integer );
		GemDos($47);

	Function Malloc( M:Long_Integer ):Long_Integer;
		GemDos($48);

	Function Exec( Md: Integer; Var Fil, Com, Env: CString ):Integer;
		GemDos($4B);

	Function SFirst( Var Name:Cstring; Attr: Integer ):Integer;
		Gemdos($4E);

	Function SNext: Integer;
		Gemdos($4F);

	Function ReName( X:Integer; Var OldName:Cstring; Var NewName:Cstring ):Long_Integer;
		Gemdos($56);

	Function GSDTOF(Var B:BlockIO; H:Integer; Md:Integer ):Integer;
		Gemdos($57);   { 1:W Time, 2:W Date }

	Function Inready( Device: Integer ):Boolean;
 	  Bios(1);

	Function Bconin( Device: Integer ):Long_Integer;
 	  Bios(2);

	Procedure Bconout( Device: Integer; Ch: Char );
		Bios(3);

	Procedure RSconf( Speed, Flowctl, Ucr, Rsr, Tsr, Scr : Integer );
		XBios(15);

	Procedure CursConf( Funct, Rate: Integer );
		XBios(21);

	Function OffGiBit( Bitnum : Integer ):Integer;
		XBios(29);

	Function OnGiBit( Bitnum : Integer ):Integer;
		XBios(30);

	Function Carrier: Boolean;	
	Var
		X : Integer;
	Begin
		If (In_Super=False) Then Super( True );
		X := Wpeek( $fffa00 );
		X := (X & 2);
		If X = 0 Then Carrier := True
			Else Carrier := False;
		Super( False );
		If Local Then Carrier := True;
		If (Forced_Off) Then Carrier := False;
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
								
	Procedure Put_Console( Ch : Char );
	Begin
		Bconout( Console, Ch );
	End;

	Procedure Put_Modem( Ch : Char );
	Begin
		Bconout( Modem, Ch );
	End;

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

	Procedure Pause( Jif : Long_Integer );
	Var
		X : Long_Integer;
	Begin
		X := Timer + Jif;
		While Timer < X Do;
	End;

	Procedure Bell( Jif : Long_Integer );
	Begin
		Pause( Jif );
		If (Not Local) Then Put_Modem( Chr(7) );
		Put_Console( Chr(7) );
	End;

	Procedure Get_TimeLeft;
	Begin
		Connected := Timer - Timeon;
		Connected := Connected Div 12000;
		Timeleft := Minutes - Connected;
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

	Procedure Put_Char( Ch: Char );
	Begin
 		If (Not Local) Then Put_Modem( Ch );
	 	Put_Console( Ch );
	End;

	Procedure Back_Space;
	Begin
	  Put_Char( Chr(Bksp) );
 		Put_Char( ' ' );
 		Put_Char( Chr(Bksp) );
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
		Put_Console( '%' );
		Put_Console( ' ' );
 		Put_Console( Chr(Esc) );
 		Put_Console( 'M' );
		Get_Curs;
 		Put_Console( Chr(Esc) );
 		Put_Console( 'A' );
	End;

	Procedure CCrLf;
	Begin
		Lin_Count := Lin_Count + 1;
		If Lin_Count > 19 then Del_Line;
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

	Procedure Chat_Wrap( Var S: String; X: Integer; Var KyCnt: Integer; Md: Integer );
	Begin
		S := Concat( S, Chr(X) );
		KyCnt := KyCnt + 1;
		If X=32 Then S := '';
		If (KyCnt>=WidT-2) And (Length(S)=WidT-2) Then Begin; CrLf; S:=''; KyCnt:=0; End
		Else If (KyCnt>=WidT-2) And (Length(S)>0) Then Begin
			KyCnt := Length( S );
			For X := 1 to KyCnt Do Back_Space;
			CrLf;
			For X := 1 to KyCnt Do Put_Char( S[X] );
		End
		Else Begin
			If Md=1 Then Begin
				Put_Console( Chr(X) );
				Put_Modem( Chr(X) );
			End
			Else Put_Console( Chr(X) );
		End;
	End;

	Procedure Chat_Mode;
	Var
		X, I : Long_Integer;
		Temp : String[40];
		S : String;
		KyCnt : Integer;
	Begin
		Chat := True;
		Save_Curs;
		Hide_Curs;
		GotoXY( 39,2 );
		InverseVideo;
		EchoC( '         ' );
		NormVideo;
		Get_Curs;
		Show_Curs;
		CrLf;
		Temp := 'SysOp Entering Chat Mode...';
		For I := 1 to Length(Temp) Do
		 Put_Char( Temp[I] );
		CrLf;
		CrLf;
		Fnct_Key := 0;
		S := '';
		KyCnt := 0;
		Repeat
		 	If Inready(Modem) And (Not Local) Then Begin
				X := Bconin( Modem );
				Put_Modem( Chr(X) );
				If X=Cr Then Begin; CrLf; S := ''; KyCnt := 0; End
				Else If (X<>Cr) And (X<>Lf) And (X<>Esc) Then Chat_Wrap( S, X, KyCnt, 0 );
			End
			Else If Inready(Console) Then Begin
 				I := Bconin( Console );
				Fnct_Key := Shr( I,16 );
				X := ( I & 65535 );
				If X=Cr Then Begin; CrLf; S := ''; KyCnt := 0; End
				Else If (X<>Cr) And (X<>Lf) And (X<>Esc) Then Chat_Wrap( S, X, KyCnt, 1 );
			End;
		Until (Fnct_Key=F5) or (Carrier=False);
		Fnct_Key := 0;
		CrLf;
		Temp := 'You Now Have Control...';
		For I := 1 to Length(Temp) Do
		 Put_Char( Temp[I] );
		CrLf;
		CrLf;
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
		If Fnct_Key=F5 Then Chat_Mode;
		X := ( I & 65535 );
		Get_Console := X;
	End;

	Function Scan_Input : Integer;
	Var
		X : Integer;
		I : Long_Integer;
	Begin
		X := TimeOut;
	 	If Inready(Modem) And (Not Local) Then X := Get_Modem
		Else If Inready(Console) Then X := Get_Console;
		Scan_Input := X;
	End;

	Procedure Esc_Red;
	Begin
		If (Not Local) Then Begin
			Put_Modem( Chr(27) );
			Put_Modem( 'b' );
			Put_Modem( '1' );
		End;
		Put_Console( Chr(27) );
		Put_Console( 'b' );
		Put_Console( '1' );
	End;

	Procedure Esc_Green;
	Begin
		If (Not Local) Then Begin
			Put_Modem( Chr(27) );
			Put_Modem( 'b' );
			Put_Modem( '2' );
		End;
		Put_Console( Chr(27) );
		Put_Console( 'b' );
		Put_Console( '2' );
	End;

	Procedure Esc_Black;
	Begin
		If (Not Local) Then Begin
			Put_Modem( Chr(27) );
			Put_Modem( 'b' );
			Put_Modem( '3' );
		End;
		Put_Console( Chr(27) );
		Put_Console( 'b' );
		Put_Console( '3' );
	End;

	Procedure Esc_Inverse;
	Begin
		If (Inverse) Then Begin
			If (Not Local) Then Begin
				Put_Modem( Chr(27) );
				Put_Modem( 'p' );
			End;
			Put_Console( Chr(27) );
			Put_Console( 'p' );
			Inverse := False;
		End
		Else Begin
			If (Not Local) Then Begin
				Put_Modem( Chr(27) );
				Put_Modem( 'q' );
			End;
			Put_Console( Chr(27) );
			Put_Console( 'q' );
			Inverse := True;
		End;
	End;

	Procedure EchoS( Temp : String );
	Var
   	I, X : Integer;
		Ch, C2 : Char;
		Valid : Boolean;
	Begin
   	If (Carrier) Then Begin
			For I := 1 to Length( Temp ) do Begin;
				Valid := False;
				Ch := Temp[I];
				C2 := Chr(0);
				If (Length(Temp)>I) Then C2 := Temp[I+1];
				If (Ch='\') and ((C2='r') or (C2='g') or (C2='b') or (C2='i')) Then Valid := True;
				If (Valid) And (VT52) Then Begin
					If C2='r' Then Esc_Red
					Else If C2='g' Then Esc_Green
					Else If C2='b' Then Esc_Black
					Else Esc_Inverse;
					I := I + 1;
				End
				Else If (Valid) And (VT52=False) Then I := I +1
				Else If (Carrier) Then Begin
					If (Not Local) Then Put_Modem( Ch );
 		  		Put_Console( Ch );
					X := Scan_Input;
					If X=CtrlC Then Begin
						Abort := True;
						I := Length( Temp );
					End
					Else If X=CtrlS Then Begin
						Repeat
							X := Scan_Input;
						Until (X=CtrlS) or (X=CtrlQ) or (Carrier=False);
					End;
				End;
			If (Carrier=False) Then I := Length(Temp);
			End;
		End;
	End;

	Procedure EchoSE( L : String );
	Begin
   	EchoS( L );
   	Crlf;
	End;

	Procedure AddSpaces( Var L : String ; Lngth: Integer );
	Begin
   	While Length( L ) < Lngth Do
   		L := Concat( L, ' ' );
	End;

	Procedure EchoN( S : String );
	Var
		N, X : Integer;
	Begin
		X := Length( S );
		If (X < WidT) Then Begin
			N := (WidT - X) Div 2;
	   	While Length( S ) < N + X Do
   		S := Concat( ' ', S );
		End;
   	EchoS( S );
	End;

	Procedure EchoNE( S : String );
	Begin
   	EchoN( S );
		CrLf
	End;

	Procedure Show_Wrong;
	Begin
		EchoSE( 'Wrong Key Try ''?'' ');
	End;

	Procedure Clear_Local;
	Begin
		Put_Console( Chr(Esc) );
		Put_Console( 'Y' );
		Put_Console( '%' );
		Put_Console( ' ' );
		Put_Console( Chr(Esc) );
		Put_Console( 'J' );
		Lin_Count := 0;		
	End;

	Procedure Clear_Screen;
	Begin
   	If Carrier Then Begin
   		If (VT52) And (Not Local) Then Begin
   			Put_Modem( Chr(Esc) );
   			Put_Modem( 'H' );
   			Put_Modem( Chr(Esc) );
   			Put_Modem( 'J' );
			End;
			If (VT52 = False) And (Not Local) Then Begin 
				Put_Modem( Chr(12) );
			End;
			Clear_Local;		
		End;
	End;

	Function FileName_Ok( Var S : String): Boolean;
	Var
		Ch : Char;
		Cnt, Pnt, I : Integer;
	Begin
		Cnt := 0;
		Pnt := 0;
		For I := 1 to Length( S ) Do Begin
			Ch := S[I];
			If (Ch='.') Then Pnt := Pnt + 1;
			If (Ch In['0'..'9']) or (Ch In['A'..'Z']) or 
				(Ch='_') or (Ch='.') Then Cnt := Cnt + 1;
		End;
		If (Cnt=Length(S)) And (Pnt<2) Then FileName_Ok := True
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
		If Ln = X Then Is_Numeric := True
		Else Is_Numeric := False;
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
		If X = Cnt Then Check_Line := True
		Else Check_Line := False;
	End;

	Procedure Show_Cur_Time;
	Var
		X, H, M, S : Integer;
		St : String[12];
	Begin
		Get_Time( H, M, S );
		Save_Curs;
		Hide_Curs;
		GotoXY(56,0);
		InverseVideo;
		Writev( St, H:2, ':' );
		If M<10 then St := Concat( St, '0' );
		Writev( Line, M, ':' );
		St := Concat( St, Line );
		If S<10 Then St := Concat( St, '0' );
		Writev( Line, S );
		St := Concat( St, Line );
		EchoC( St );
		Mil_Time := St;
		Get_Curs;
		Show_Curs;
		NormVideo;
	End;

	Procedure Convert_Time( Time: Integer );
	Var
		H : Long_Integer;
		M, S : Integer;
		Pm : String[2];
		Temp: String[6];
	Begin
		Pm := 'am';
		H := (Time & 63488);
		H := Shr(H, 11 );
		M := (Time & 2016);
		M := Shr(M, 5 );
		S := (Time & 31);
		If H=0 Then H := 12;
		If H>12 Then Begin
			H := H - 12;
			Pm := 'pm';
		End;
		Writev( Line, H, ':' );
 		If M<10 Then Line := Concat(Line, '0' );
		Writev(Temp, M);
		Line := Concat(Line, Temp );
		Line := Concat(Line, ':' );
 		If S<10 Then Line := Concat(Line, '0' );
		Writev(Temp, S);
		Line := Concat(Line, Temp );
		Line := Concat(Line, Pm );
	End;

	Procedure Convert_Date( Date: Integer );
	Begin
		M := (Date & 480);
		M := Shr(M, 5 );
		Y := (Date & 65024);
		Y := Shr(Y, 9 );
		Y := Y + 1980;
		D := (Date & 31);
		Writev( Line, Month[M], D:2, ', ', Y );
	End;

	Procedure Show_Cur_Date;
	Begin
		Get_Date( M, D, Y );		
		Writev( Line,Month[M], D:2, ', ', Y );
		Save_Curs;
		GotoXY(67,0);
		InverseVideo;
		EchoC( Line );
		Get_Curs;
		NormVideo;
	End;

	Procedure Show_Connected;
	Begin
		Get_TimeLeft;
		writev( Line, Connected, '/', Minutes );
		Save_Curs;
		Hide_Curs;
		GotoXY( 67,2 );
		InverseVideo;
		EchoC( Line );
		NormVideo;
		Get_Curs;
		Show_Curs;
	End;

	Procedure Show_Secs_Left;
	Begin
		writev( Line, Seconds:3 );
		Save_Curs;
		Hide_Curs;
		GotoXY( 76,2 );
		InverseVideo;
		EchoC( Line );
		NormVideo;
		Get_Curs;
		Show_Curs;
	End;

	Procedure Show_40( Var S: String );
	Begin
		If (WidT=80) Then AddSpaces(S, 43);
		EchoS( S );
		If ((WidT=80) And (New_Line)) or (WidT=40) Then CrLf;
		New_Line := Not New_Line;
	End;

	Procedure Hang_Up;
	Var
		X : Integer;
	Begin
		X := OnGiBit( 16 );
		Pause( 400 );
		X := OffGiBit( 6 );
		Forced_Off := True;
	End;

	Procedure Disconnect;
	Begin
		CrLf;
		CrLf;
		Line := Concat( 'Thanks For Calling ', UserRec.UHandle, ',' );
		EchoSE(Line); EchoSE('Call Back Again Soon...');
		Hang_Up;
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
		Ok,Sec2 : Boolean;
	Begin
		Ok := False;
		Sec2 := False;
		Flush_Input;
   	Maxtime := Timer + 36200;
		I := TimeOut;
   	Repeat
			Get_TimeLeft;
			If Timeleft < 1 Then Begin
				UsedUp_Time;
				I := Timeout;
			End
			Else Begin
				Seconds := ( MaxTime-Timer) Div 200;
				If (Seconds=30) And (Sec2=False) Then Begin
					CrLf; CrLf; EchoSE('\r<<30 Seconds Till Auto-Logoff>>\b'); CrLf; Sec2:=True; End;
				Show_Secs_Left;
				Show_Cur_Time;
				Show_Connected;
 		 		I := Scan_Input;
				If (Chat) Then Begin; Chat := False; Maxtime := Timer + 36200; I:=Timeout; End;
 				If (I>31) And (I<129) or (I=Cr) Or (I=CtrlE) Then Ok := True;
			End;
   	Until (I>Timeout) Or (Carrier=False) Or (Timer>Maxtime) Or (Ok);
		If Timer>MaxTime Then Disconnect;
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
	 		If (Ord(Ch)=Cr) or (Carrier=False) Then Done := True
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
		Until (Done) or (X = Lgth);
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
		Done : Boolean;
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

	Procedure Press_Any;
	Var
		Ch : Char;
	Begin
		EchoS( '\gPress Any Key To Continue...\b' );
		Ch := Get_Char;
		CrLf;
	End;

	Procedure Fn_Convert( Var S1: String; Var S2: String );
	Var
		I : Integer;
		Q,R : String;
	Begin
		I := Pos( '.', S1 );
		If I > 1 Then Begin
			Q := Copy( S1, 1, I-1 );
			AddSpaces( Q, 8 );
			R := Copy( S1, I, (Length(S1)-I)+1 );
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

	Procedure Write_Ln( Hndl: Integer; S: String );
	Var
		I,X : Long_Integer;
	Begin
		S := Concat( S, Chr(Cr), Chr(Lf) );
		X := Length(S);
		For I := 1 to X Do
			Blkio[I] := Ord( S[I] );
		I := BlockWrite( Hndl, X, Blkio );
	End;

	Function Exists( Filename: String ):Boolean;
	Var
		Junkfile : Text;
	Begin
   	Reset( Junkfile, Filename );
   	If Io_result=0 Then
   		Result := True
   	Else
   		Result := False;
   	Close( Junkfile );
   	Exists := Result;
	End;

	Procedure Log( Num : Integer );
	Var
   	X : Long_Integer;
		H,I : Integer;
		S : String;
	Begin
		S := Log_Filename;
		If Exists( S ) Then H := FOpen( S, Update_Mode )
		Else H := FCreate( S, 0 );
		X := Fseek( 0, H, 2 );
		For I := 1 to Num Do
			Write_Ln( H, DescL[I] );
		I := Close_File( H );
	End;

	Procedure Show_File( Var F : String );
	Var
		I : Integer;
		Ch : Char;
	Begin
		For I := 1 to Length( F ) Do Begin
			Ch := F[I];
      If Ch In['A'..'Z'] Then Ch := Chr(Ord(Ch)+32);
      F[I] := Ch;
		End;
		Save_Curs;
		Hide_Curs;
		GotoXY( 39,3 );
		InverseVideo;
		Line := F;
		AddSpaces( Line, 40 );
		Line[0] := Chr(40);
		EchoC( Line );
		NormVideo;
		Get_Curs;
		Show_Curs;
	End;

	Procedure Show_Xyz_Error( Error: Integer );
	Var
		Temp,Desc: String;
	Begin
		If Error <> 0 Then Begin
			Error := Abs(Error);
			Writev( Temp, '-', Error );
			Desc := Xyz[Error];
			DescL[1] := ' ';
			DescL[2] := Concat ('   XYZ Error: ', Temp);
			DescL[3] := Concat (' Description: ', Desc);
			Log(3);
		End;
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
			Log(4);
			EchoSE( DescL[1]);
			EchoSE( DescL[2]);
			EchoSE( DescL[3]);
			EchoSE( DescL[4]);
			CrLf;
		End;
	End;

	Procedure DT_Stamp( Var F: CString );
	Var
		H, X: Integer;
		S : String;
	Begin
		MakePString( F, S );
		X := Get_STime;
		Blkio[1] := (X Div 256);
		Blkio[2] := (X Mod 256);
		X := Get_SDate;
		Blkio[3] := (X Div 256);
		Blkio[4] := (X Mod 256);
		H := Open_File( F, 0 );
		If H<0 Then Show_Error( S, H );
		X := GSDTOF( Blkio, H, 1 );
		Show_Error( S, X );
		X := Close_File ( H );
		If X<0 Then Show_Error( S, H );
		If Sfirst( F, 0 ) = 0 Then X := 0;
		EchoSE( 'Time/Date Stamp Updated...' );
	End;

	Procedure Show_Dfree;
	Type
		FreeHdr = Packed Record
		Case Integer of
			1 : (Data: Packed Array[1..4] of Long_Integer);
			2 : (Buff: BlockIO);
	End;
	Var
		FH : FreeHdr;
		B1,B2,B3,B4,X,Free : Long_Integer;
		S : String[12];
	Begin
		S := Concat( 'Drive: ', Chr(Drv+Ord('B')) );
		X := DFree( FH.Buff, Drv+1 );
		Dummy_I := Int( X );
		Show_Error( S, Dummy_I );
		B1 := FH.Data[1]; { number of free clusters }
		B2 := FH.Data[2]; { total number of clusters }
		B3 := FH.Data[3]; { sector size in bytes }
		B4 := FH.Data[4]; { clusters per sector }
		Free := ( B3 * B4 );
		Free := ( Free * B1 );
		Writev( Line, 'Total Upload Space = ', Free, ' Bytes' );
		CrLf;
		EchoSE( Line );
		CrLf;
	End;

	Procedure Copy_File( Var In_File, Out_File :String );
	Var
		N,X,Tot,Siz,Tsiz : Long_Integer;
		H1, H2 : Integer;
	Begin
		H1 := FOpen( In_File, 0 );
		Siz := FSeek( 0, H1, 2 );
		X := Close_File( H1 );
		H1 := FOpen( In_File, 0 );
		H2 := FCreate( Out_File, 0 );
		Tot := Siz;
		Repeat
			X := Close_File( H2 );
			H2 := FOpen( Out_File, 1 );
			X := FSeek( 0, H2, 2 );
			If Tot>=Block_Size Then TSiz := Block_Size
				Else Tsiz := Tot;
			N := BlockRead( H1, TSiz, Blkio );
			If N < 0 Then Begin
				Show_Error( In_File, N );
				Tot := 0;
			End
			Else If N > 0 Then Begin
				X := BlockWrite( H2, TSiz, Blkio );
				If X < 0 Then Begin
					Show_Error( Out_File, X );
					Tot := 0;
				End
				Else Tot := Tot - Tsiz;
			End;
		Until (Tot=0);
		X := Close_File( H1 );
		X := Close_File( H2 );
	End;

	Procedure Show_None_Marked;
	Begin
		EchoSE(' \rYou Do Not Have Any Files Marked Yet!\b' );
		CrLf;
	End;

	Procedure Batch_Mark_File;
	Begin
		CrLf;
		If BM_Num = 0 Then Tot_DL_Time := 0;
		If (Tot_DL_Time+DL_Time) < TimeLeft Then Begin
			If ((BM_Num<8) And (One_Sig)) or
			((BM_Num<20) And (One_Sig=False)) Then Begin
				CrLf;
				BM_Num := BM_Num + 1;
				BMark[BM_Num].BM_Fname := File_Name;
				BMark[BM_Num].BM_Fsize := Dta_Data.Size;
				BMark[BM_Num].BM_Sig := Sig_Num;
				BMark[BM_Num].BM_D_Time := DL_Time;
				Tot_DL_Time := Tot_DL_Time + DL_Time;
			End
			Else Begin
				CrLf;
				If (One_Sig) Then EchoSE('\r Sorry, Maximum Files Is 8...\b')
					Else EchoSE('\r Sorry, Maximum Files Is 20...\b');
				Press_Any;
			End;
		End
		Else Begin
			CrLf;
			EchoSE('\r Sorry, You Do Not Have Enough Time Left To Include This File...\b');
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
	   	FPath := Concat( System2.Paths[Sig_Num], S );
			If Exists( FPath ) Then Begin
				MakeCstring( FPath, Fname );
				Lines :=1;
				If Sfirst( Fname, 0 ) = 0 Then Begin
					DL_Time := ((Dta_Data.Size Div Cps) Div 60);
					If DL_Time <1 Then DL_Time := 1;
					File_Name := S;
					Batch_Mark_File;
				End;
			End
			Else Begin
				CrLf;
				EchoS( S );
				EchoSE( ' Does Not Exist...' );
				CrLf;
			End;
		End
		Else Begin
			CrLf;
			EchoSE( '\rIllegal Filename...\b' );
			CrLf;
		End;
	End;

	Procedure Review_Marked_Files;
	Var
		Temp : String;
		I, T_Tot : Integer;
		F_Tot : Long_Integer;
	Begin
		I := 0;
		F_Tot := 0;
		T_Tot := 0;
		If BM_Num >0 Then Begin
			CrLf;
			CrLf;
			EchoSE(' No.   Filename      Size      D/L Time' );
			EchoSE(' ----  ------------  --------  --------' );
			Repeat
				I := I + 1;
				Temp := BMark[I].BM_Fname;
				AddSpaces( Temp, 14 );
				Writev(Line, ' [\r', I, '\b]  ', Temp, BMark[I].BM_Fsize:8, '  ' );
				If I<10 Then Line := Concat( ' ', Line );
				Writev(Temp, BMark[I].BM_D_Time:3, ' Mins' );
				F_Tot := F_Tot + BMark[I].BM_FSize;
				T_Tot := T_Tot + BMark[I].BM_D_Time;;
				Line := Concat(Line, Temp );
				EchoSE( Line );
			Until I = BM_Num;
			EchoSE(' ----  ------------  --------  --------' );
			EchoS( ' Totals              ');
			Writev( Line, F_Tot:8, '  ', T_Tot:3, ' Mins' );
			EchoSE( Line );
			CrLf;
		End
		Else Show_None_Marked;
	End;

	Procedure Wipe_Marked;
	Var
		X, Y : Integer;
		Choice : Char;
	Begin
		If BM_Num >0 Then Begin
			Review_Marked_Files;
			EchoSE(' Enter Number Of File To Wipe');
			EchoS(' or [\rA\b] To Wipe All Files :> ');
		  Choice := Get_Char;
			Choice := Upper_C( Choice );
			Case Choice of
				'A' : Begin; EchoSE('All'); BM_Num := 0; Tot_DL_Time := 0; End;
				Else If Choice In['1'..'9'] Then Begin
					Put_Char( Choice );
					X := Ord(Choice) - 48;
					Y := 16;
					If BM_Num > (X * 10) Then Begin
						Choice := Get_Char;
						If Choice In['0'..'9'] Then Begin
							Put_Char( Choice );
							If Ord(Choice) <> 13 Then Begin
								Y := Ord(Choice) - 48;
								If Y = 10 Then Y := 0;
							End;
						End;
					End;
					If (X <= BM_Num) And (Y = 16) Then Y := X
					Else Y := ( X * 10 ) + Y;
					CrLf;
					If Y <= BM_Num Then Begin
						If Y < BM_Num Then Begin
							Tot_DL_Time := Tot_DL_Time - BMark[Y].BM_D_Time;
							X := Y - 1;
							Y := BM_Num -1;
							Repeat
								X := X + 1;
								BMark[X].BM_Fname := BMark[X+1].BM_FName;
								BMark[X].BM_Fsize := BMark[X+1].BM_Fsize;
								BMark[X].BM_Sig   := BMark[X+1].BM_Sig;
								BMark[X].BM_D_Time:= BMark[X+1].BM_D_Time;
							Until X = Y;
							BM_Num := BM_Num - 1;
							CrLf;
							EchoSE( 'Done...' );
						End
						Else
							BM_Num := BM_Num - 1;
							Tot_DL_Time := Tot_DL_Time - BMark[Y].BM_D_Time;
					End;
					CrLf;
				End
				Else Show_Wrong;
			End; {Case}
		End
		Else Show_None_Marked;
	End;

	Function Find_User_Addr : Long_Integer;
	Label
		2200;
	Var
		T1, TT, T2, U, X : Long_Integer;
		I : Integer;
		B1, B2, Cnt1, Cnt2 : Byte;
		Again, Found : Boolean;
	Begin
		Cnt2 := Length(UserRec.UHandle);
		T2 := Proc_addr( Dummy_Routine );
		TT := T2;
		T2 := T2 - FTU_Length;
		U := Addr( UserRec ) + 3;
		If (Cnt2=1) Then U := U -1;
	2200:
		Found := False;
		Repeat
			Cnt1 := 1;
			T1 := U;
			Again := False;
			B1 := Peek( T1 );
			B2 := Peek( T2 );
			If (B1=B2) Then Begin
				Repeat
					Cnt1 := Cnt1 + 1;
					T1 := T1 + 1;
					T2 := T2 + 1;
					B1 := Peek( T1 );
					B2 := Peek( T2 );
					If ((B1=B2) And (Cnt1=Cnt2)) or (T2>=T1) Then Found := True
						Else If (B1<>B2) Then Again := True;
				Until (Found) or (Again) or (Carrier=False);
			End;
			T2 := T2 + 1;
		Until (Found) or (Carrier=False);
		T2 := T2 - 1;
		If T2 >= U Then X := 0
			Else Begin
				T2 := (T2-2) - Cnt2; 
				If Odd(T2) Then T2 := T2 + 1;
				If (Wpeek( T2+220 ) = UserRec.Downloads) And
				(Wpeek( T2+222 ) = UserRec.Uploads) And
				(Lpeek( T2+272 ) = UserRec.Sig_Read_Mask) And
				(Lpeek( T2+276 ) = UserRec.Sig_Validate) And
				(Lpeek( T2+280 ) = UserRec.Sig_Edit_Desc) And
				(Lpeek( T2+284 ) = UserRec.Sig_Delete_File) then X := T2
				Else Begin
					T2 := (T2+3) + Cnt2;
					Goto 2200;
				End;
			End;
		Find_User_Addr := X;
		Writev( Line, 'OffSet For FTU.HLP Is ', TT-T2, ' Bytes...' );
		EchoCE( Line );
	End;

	Procedure Get_MaskData( Num : Integer );
	Var
	Ftu_Mask : Text;
   	X , Count : Long_Integer;
	Begin
		Count := ( SizeOf(UserAcs) * (Num-1) );
		Reset( Ftu_Mask, ftu_maskfile );
		X := Fseek( Count, Handle(Ftu_Mask), 0 );
		If (X<0) Then Show_Error( Ftu_MaskFile, X );
		X := FRead_Usr2( Handle(Ftu_Mask), SizeOf(UserAcs), UserAcs );
		If (X<0) Then Show_Error( Ftu_MaskFile, X );
		Close( Ftu_Mask );
	End;

	Procedure Save_Ftu_User;
	Var
		S1, S2, X, Count : Long_Integer;
	Begin
		S1 := SizeOf(UserAcs);
		S2 := (Usr_No-1);
		Count := S1 * S2;
		Reset( UsrDataFtu, Ftu_UserFile );
		X := Fseek( Count, Handle(UsrDataFtu), 0 );
		If (X<0) Then Show_Error( Ftu_UserFile, X );
		X := FWrite_Usr2( Handle(UsrDataFtu), SizeOf(UserAcs), UserAcs );
		If (X<0) Then Show_Error( Ftu_UserFile, X );
		Close( UsrDataFtu );
	End;

	Procedure Get_Ftu_User;
	Var
   	S1, S2, X, Count : Long_Integer;
	Begin
		S1 := SizeOf(UserAcs);
		S2 := (Usr_No-1);
		Count := S1 * S2;
		Reset( UsrDataFtu, Ftu_UserFile );
		X := Fseek( Count, Handle(UsrDataFtu), 0 );
		If (X<0) Then Show_Error( Ftu_UserFile, X );
		X := FRead_Usr2( Handle(UsrDataFtu), SizeOf(UserAcs), UserAcs );
		If (X<0) Then Show_Error( Ftu_UserFile, X );
		Close( UsrDataFtu );
	End;

	Procedure Get_UserData;
	Var
   	S1, X, Count : Long_Integer;
	Begin
		Usr_Tmp := Usr_No;
		Reset( Userfile, Userfilename );
		X := Fseek( 0, Handle(Userfile), 2 );
		If (X<0) Then Show_Error( UserFilename, X );
		NewUser_Rec := (X Div 292) - 1;
		Visitor_Rec := NewUser_Rec - 1;
		If (UserRec.New_User) Then Usr_No := NewUser_Rec
			Else If (Usr_No=-1) Then Usr_No := Visitor_Rec;
		S1 := Usr_No;
		Count := S1 * 292;
		Close( Userfile );
		Reset( Userfile, Userfilename );
		X := Fseek( Count, Handle(Userfile), 0 );
		If (X<0) Then Show_Error( UserFilename, X );
		X := FRead_Usr( handle(UserFile), sizeof(UserRec), UserRec );
		If (X<0) Then Show_Error( UserFilename, X );
		Close( Userfile );
		If (UserRec.New_User) Then Usr_No := Usr_Tmp;
	End;

	Procedure Get_SysData;
	Var
		FtuData : String;
		Sigdatafile : text;
		I, J : Integer;
		Ch : Char;
		Count : Long_Integer;
	Begin
		FtuData := 'ftu_data.sig';
		If Exists( FtuData ) Then Begin
			Reset( Sigdatafile, FtuData );
			Count := Fseek( 0, Handle(SigdataFile), 0);
			If (Count<0) Then Show_Error( FtuData, Count );
			Count := FRead_Sys2( handle(sigdatafile), sizeof(system2), System2 );
			If (Count<0) Then Show_Error( FtuData, Count );
			Close( Sigdatafile );
			Userfilename := System2.Userlog;
			Log_Filename := System2.Logfile;
			Numsigs := System2.TSigcount;
		End
		Else Begin
			CrLf;
			EchoSE( '\r\iUnable To Open FTU_DATA.SIG file....\i\b' );
			EchoSE( 'Returning To The BBS.' );
			CrLf;
		End;
	End;

	Procedure Show_SigOp_Stats;
	Begin
		Save_Curs;
		Hide_Curs;
		InverseVideo;
		GotoXY( 18,3 );
		If (Sig2_Edit[Sig_Num]=1) Then EchoC( '-E' )
			Else EchoC( '  ' );
		If (Sig2_Valid[Sig_Num]=1) Then EchoC( '-V' )
			Else EchoC( '  ' );
		If (Sig2_Kill[Sig_Num]=1) Then EchoC( '-K' )
			Else EchoC( '  ' );
		NormVideo;
		Get_Curs;
		Show_Curs;
	End;

	Procedure Show_DL_UL;
	Var Temp : String;
	Begin
		Save_Curs;
		Hide_Curs;
		InverseVideo;
		UserRec.Downloads := UserRec.Downloads + New_Dls;
		UserRec.Uploads := UserRec.Uploads + New_Uls;
		GotoXY( 42,4 );
		Writev( Temp, UserRec.DownLoads );
		EchoC( Temp );
		GotoXY( 51,4 );
		Writev( Temp, UserRec.UpLoads );
		EchoC( Temp );
		NormVideo;
		Get_Curs;
		Show_Curs;
	End;

	Procedure Show_Top5;
	Var
		Temp : String;
		I : Long_Integer;
	Begin
		InverseVideo;
 (*        '01234567890123456789012345678901234567890123456789012345678901234567890123456789' *)
		GotoXY( 0,0 );
		EchoC( '                                 Cpu :                  10:12:12   Jan 22, 1990 ' );
		GotoXY( 0,1 );
		EchoC( '                                 Age :                  Last Call: Jan 12, 1989 ' );
		GotoXY( 0,2 );
		EchoC( '                                 Chat:                  Connected:              ' );
		GotoXY( 0,3 );
 		EchoC( '                                 File:                                          ' );
		GotoXY( 0,4 );
		EchoC( ' Md:     St:     Wid:       Bd:       Dl:      Ul:      Rto:    :1 Fre:         ' );
		GotoXY( 24,3 );
		EchoC( Trans[Transv] );
		If (Usr_No=-1) Then Begin
			GotoXY( 44,1 );
			EchoC( '*Visitor*' );
		End
		Else Begin
			If (UserRec.New_User) Then Begin
				GotoXY( 44,1 );
				EchoC( 'New User' );
			End
			Else Begin
				GotoXY( 44,1 );
				EchoC( 'Validated' );
			End;
		End;
		GotoXY( 1,0 );
		EchoC ( UserRec.UHandle );
		GotoXY( 1,1 );
		EchoC ( UserRec.Name );
		GotoXY( 1,2 );
		Temp := Concat( UserRec.City, ' ', UserRec.State );
		EchoC ( Temp );
		GotoXY( 1,3 );
		EchoC ( UserRec.Phone_Number );
		GotoXY( 39,0 );
		EchoC ( UserRec.Computer_Type );
		GotoXY( 39,1 );
		Writev(Temp, UserRec.Age );
		EchoC ( Temp );
		GotoXY( 39,2 );
		EchoC ( 'On' );
		Temp := Copy( UserRec.Last_call_date, 1, 2 );
 		Readv( Temp, M );
 		Temp := Copy( UserRec.Last_call_date, 4, 2 );
 		Readv( Temp, D );
 		Temp := Copy( UserRec.Last_call_date, 7, 2 );
 		Readv( Temp, Y );
		Y := Y + 1900;
		Writev( Temp, Month[M], D:2, ', ', Y );
		GotoXY( 67,1 );
		EchoC( Temp );
		Y := Y - 1980;
 		M := Shl( M, 5 );
 		Y := Shl( Y, 9 );
		Usr_Lst_Call := Y + M + (D-1);

		GotoXY( 5,4 );
		If Local Then EchoC( 'Loc' )
			Else EchoC( 'Rmt' );
		GotoXY( 13,4 );
		If Local Then EchoC( 'Sys' )
			Else If (Sig_Op) Then EchoC( 'Sig' )
			Else EchoC( 'Usr' );
		GotoXY( 22,4 );
		EchoC( Width );
		GotoXY( 32,4 );
		EchoC( BaudRate );
		GotoXY( 61,4 );
		Writev ( Temp, UserRec.DL_Ratio:3 );
		EchoC( Temp );
		GotoXY( 72,4 );
		I := Malloc( -1 );
		Writev( Temp, I );
		EchoC( Temp );
		CursConf( 3, 0 );
		Show_Cur_Time;
		Show_Cur_Date;
		Show_Connected;
		NormVideo;
	End;

	Function Exec_Xyz : Integer;
		Var
			I, X : Integer;
			C, E : CString;
			Temp, InF, OutF : String;
		Begin
			Cmd_Line := Concat ( Cmd_Line,'-s -t ');
			If (Batch_Mode) And (One_Sig) Then Begin
				For I := 1 to BM_Num Do Begin
					Temp :=BMark[I].BM_Fname;
					Temp := Concat( Temp, ' ' );
					Cmd_Line := Concat( Cmd_Line, Temp );
				End;
			End
			Else If (Batch_Mode) And (One_Sig=False) Then Begin
				Cmd_Line := Concat( Cmd_Line, System2.Temp_Path, '*.*' );
				EchoSE( 'Copying Files:' );
				For I := 1 to BM_Num Do Begin
					Temp :=BMark[I].BM_Fname;
					EchoSE( Temp );
					X := BMark[I].BM_Sig;
   				InF := Concat( System2.Paths[X], Temp);
			   	OutF := Concat( System2.Temp_Path, Temp );
					Copy_File( InF, OutF );
				End;
			End
			Else If (Batch_Upld=False) Then Cmd_Line := Concat( Cmd_Line, File_Name );
			Temp := Concat( Xfer_Type, ' Ready, Start Transfer Now...' );
			CrLf;
			EchoSE( Temp );
			For I := 1 To Length( Cmd_Line ) Do
				C[I] := Cmd_Line[I];
			C[ Length(Cmd_Line)+1 ] := Chr(0);
			C[0] := Chr( Length(Cmd_Line) );
			For I := 0 to 27 Do
				E[I] := Chr(0);
			Time_Start := Timer;
			Put_Console( Chr(Esc) );
			Put_Console( 'H' );
			Put_Console( Chr(Esc) );
			Put_Console( 'J' );
			EchoCE( Cmd_Line );
			CrLf;
			I := Exec( 0, Xyz_Path, C, E );
			Exec_Xyz := I;
			Time_Finish := Timer;
			Xfer_Time := Time_Finish - Time_Start;
			Xfer_Time := Xfer_Time Div 12000;
			Show_Top5;
			Show_DL_UL;
			Clear_Local;
			If (I<>0) Then Show_Xyz_Error( I );
			CrLf;
			If (Batch_Upld) Then Batch_Upld := False;
		End;

	Procedure Make_F_Names;
	Var
		X : Integer;
		Ch : Char;
	Begin
		MakeFname( Dta_Data.Name, File_Name );
   	F_Name := Concat( System2.Paths[Sig_Num], File_Name );
		MakeCstring( F_Name, F_Path );
   	Desc_Path := Concat( System2.Paths[Sig_Num], 'DESC\', File_Name );
		MakeCstring( Desc_Path, Desc_Path_C );
		Hide_Mode := False;
		X := Dta_Data.Attribute & 1;
		If (X=0) Then Hide_Mode := True;
	End;

	Procedure Get_Sig_Access;
	Var
		Fa, Fv, Fe, Fk, I, I1, X, Z, Count : Integer;
		F, FSig_A, FSig_V, FSig_E, FSig_K, Bit, Xa, Xv, Xe, Xk, V : Long_Integer;
	Begin
		For I := 1 to 32 Do   Sig_Access[I] := 0;
		For I := 0 to 1023 Do Sig2_Access[I] := 0;
		Count := 1;
		Bit := 1;
		Fa := 0;
		FSig_A := UserAcs.TSig_Accs;
		V := $80000000;
		Repeat
			Fa := Fa + 1;
			Line := System2.TNames[Fa];
			If Line[0] <> Chr(0) Then Begin
	  	 	Xa := (Bit & FSig_A);
		   	If (Xa>0) or (Xa=V) Then Begin
					Sig_Access[Count] := Fa;
					Count := Count + 1;
				End;
			End;
			Bit := Bit * 2;
		Until (Fa=NumSigs);
		Max_Sig := Count -1;
		Fa := 0;
		For I := 0 to 31 Do Begin
			I1 := I + 1;  Count := 0;  Bit := 1;  Z := 0;
			FSig_A := UserAcs.Sig_Accs  [ I1 ];
			F      := UserAcs.User_Mask [ I1 ];
 			FSig_V := UserAcs.Sig_Valid [ I1 ];
 			FSig_E := UserAcs.Sig_Edit  [ I1 ];
 			FSig_K := UserAcs.Sig_Kill  [ I1 ];
			Repeat
				Z := Z + 1;  Fv := 0;  Fe := 0;  Fk := 0;
				Line := System2.Names[Fa];
				If Line[0] <> Chr(0) Then Begin
		  	 	X := (Bit & F);
		  	 	Xa := (Bit & FSig_A);
			   	If ((Xa>0) or (Xa=V)) And ((X>0) or (X=V)) Then Begin
						Sig2_Access[ (I*32) + Count] := Fa;  Xv := (Bit & FSig_V);
						If (Xv>0) or (Xv=V) Then Fv := 1;
						Sig2_Valid[ (I*32) + Count] := Fv;   Xe := (Bit & FSig_E);
						If (Xe>0) or (Xe=V) Then Fe := 1;
						Sig2_Edit[ (I*32) + Count] := Fe;    Xk := (Bit & FSig_K);
						If (Xk>0) or (Xk=V) Then Fk := 1;
						Sig2_Kill[ (I*32) + Count] := Fk;
						Count := Count + 1;
					End;
				End;
				Bit := Bit * 2;
				Fa := Fa + 1;
			Until (Z=32);
		End;
	End;

	Procedure Show_DL_Stats;
	Var
		DL_More, DL_Check : Integer;
	Begin
		DL_Check := (UserRec.Uploads * UserRec.DL_Ratio);
		DL_More := DL_Check - UserRec.Downloads;
		EchoSE( ' ' );
		EchoSE( ' ' );
		Writev( Line, ' \rDownloads\b    : ', UserRec.Downloads );
		EchoSE( Line );
		Writev( Line, ' \rUploads\b      : ', UserRec.Uploads );
		EchoSE( Line );
		Writev( Line, ' \rUL/DL Ratio\b  : ', UserRec.Dl_ratio, ':1' );
		EchoSE( Line );
		EchoSE( ' ' );
   	If DL_More < 1 Then
			Begin
				EchoSE( '\r\i You Have Exceeded Your Download Limit!\i\b' );
			End
		Else
			Writev( Line, ' You Can Download (\r\i', DL_More, '\i\b) More Files Before Uploading...' );
			EchoSE( Line );
		EchoSE( ' ' );
	End;

	Procedure Time_Toggle;
	Begin
		CrLf;
		If (Shw_Time) Then Shw_Time := False
			Else Shw_Time := True;
	End;

	Procedure Show_TimeLeft;
	Begin
		Get_TimeLeft;
		Writev( Line, '(\r', Timeleft, '\b Mins) ' );
	 	EchoS( Line );
	End;

	Procedure Page_SysOp;
	Var
		I, X : Integer;
		Done : Boolean;
	Begin
		Save_Curs;
		Hide_Curs;
		GotoXY( 39,2 );
		InverseVideo;
		EchoC( '<<Paged>>' );
		NormVideo;
		Get_Curs;
		Show_Curs;
		Done := False;
		CrLf;
		EchoS( 'Paging SysOp ' );
		I := 0;
		Repeat
			I := I + 1;
			EchoS( '*' );
			Bell( 30 );
			If Inready(Console) Then Begin
				X := Get_Console;
				Done := True;
			End;
		Until (Done) or (I=25) or (Carrier=False);
		If I=25 then Begin
			CrLf;
			CrLf;
			EchoSE( 'Sorry, The SysOp Isn''t Around Right Now.' );
			CrLf;
		End;
	End;

{$I Arc_List.Pas}
{$I Lzh_List.Pas}
{$I Zip_List.Pas}
{$I Sit_List.Pas}

	Function FRead_Dsc(H:Integer; Count:Long_Integer; Var S:BlockIO):Long_Integer;
	Gemdos( $3F ); 

	Procedure Get_Description( Cnt : Integer );
	Var
   	X : Integer;
		DscFile : Text;
	Begin
		For X := 1 to Cnt Do
		MesgL[X] := '';
		Msg_Ln := 0;
		Show_File( Desc_Path );
		If Exists(Desc_Path) Then Begin
	   	Reset( DscFile, Desc_Path );
			X := 0;
			Repeat
				X := X + 1;
				ReadLn( DscFile, MesgL[X] );
			Until (Eof(DscFile)) or (X=Cnt) or (Carrier=False);
 	  	Close( DscFile );
			Msg_Ln := X;
		End
		Else Begin
			MesgL[1] := 'SysOp';
			MesgL[2] := '0';
			MesgL[3] := 'Not Tested...';
			MesgL[4] := 'No Description';
			Msg_Ln := 4;
		End;
	End;

	Procedure Read_File;
	Var
		TBytes : Long_Integer;
		KyCnt : Integer;
		H, X, I, RC : Integer;
		EOF : Boolean;
		F : CString;
		S : String;
	Begin
		EOF := False;
		Abort := False;
		S := '';
		KyCnt := 0;
		Show_File( F_Name );
		MakeCString( F_Name, F );
		H := Open_File( F, Input_Mode);
		If H < 0 then
			EOF := True
		Else
		Repeat
			Tbytes := BlockRead( H, Block_Size, BlkIO );
			If (Tbytes>0) and (Abort=False) Then Begin
				For I := 1 to Tbytes do begin
					X := Blkio[I];
					If ((X>31) And (X<128)) Then Begin
						S := Concat( S, Chr(X) );
						KyCnt := KyCnt + 1;
						If X=32 Then S := '';
						If (KyCnt>=WidT-2) And (Length(S)>0) Then Begin
							For X := 1 to Length( S ) Do
				   			Back_Space;
							CrLf;
							KyCnt := 0;
 	  			  	EchoS( S );
							S := '';
							If (Abort) Then I := Tbytes;
						End
						Else EchoS( Chr(X) );
					End
					Else If (X=Cr) or (X=155) Then Begin; CrLf;	KyCnt := 0; End;
				End;
			End
			Else EOF := True;
		Until (EOF) or (Abort) or (Carrier=False);
		RC := Close_File( H );
		Abort := False;
		CrLf;
		Press_Any;
	End;

	Procedure Enter_Line( Var S:String; Var Word:String; Var Ch:Char;
									Var KyCnt:Integer; Var Wrap:Boolean; Temp:String);
	Label
		200;
	Var
		WrdCnt,I,CC : Integer;
	Begin
		Wrap := False;
		KyCnt := 0;
		WrdCnt := 0;
		S := '';
		Word := '';
		If Temp<>S Then Begin; S:=Temp; KyCnt:=Length(S); WrdCnt:=KyCnt; End;
		EchoS( '\r' );
		EchoS( Prompt );
		EchoS( '\b' );
		EchoS( S );
		Repeat
		200:
			Ch := Get_Char;
			Cc := Ord(Ch);
			If (Cc=Bksp) And (KyCnt>0) Then Begin
				Back_Space;
				KyCnt := KyCnt -1;
				If WrdCnt>1 Then WrdCnt := WrdCnt -1;
				S[0] := Chr(KyCnt);
				Word[0] := Chr(WrdCnt);
			End
			Else If CC>31 Then Begin
				EchoS( Ch );
				S := Concat( S, Ch );
				Word := Concat( Word, Ch );
				KyCnt := KyCnt + 1;
				WrdCnt:= WrdCnt + 1;
				If Ch=' ' Then Begin; WrdCnt := 0; Word:= ''; End;
				If (KyCnt=WidT-2) And (WrdCnt<>KyCnt) And (WW_Toggle) Then Begin
			 		For I := 1 To Length( Word ) Do Begin
						Back_Space;
	 			 	End;
					S[0] := Chr(KyCnt-WrdCnt);
					Wrap := True;
				End
				Else If (KyCnt=WidT-2) And (WrdCnt=KyCnt) And (WW_Toggle) Then CC := Cr
				Else If (KyCnt=WidT-1) And (WW_Toggle=False) Then Begin
					Back_Space;
					KyCnt:=KyCnt-1;
					Goto 200;
				End;
			End
		Until ((Ch='/') And (KyCnt=1)) or (CC=Cr) or (Wrap) or (Carrier=False);
		If Ch='/' Then Begin
			Back_Space;
			Back_Space;
			EchoS( '\r(E>\b' );
			Ch := Get_Char;
			Ch := Upper_C( Ch );
		End;
	End;

	Procedure Save_Description;
	Var
		H, X : Integer;
	Begin
		H := FCreate( Desc_Path, 0 );
		If H<0 Then Show_Error( Desc_Path, H );
		For X := 1 to Msg_Ln Do Begin;
			Write_Ln( H, MesgL[X] );
		End;
		X := Close_File( H );
		CrLf;
	End;

	Procedure Frmt_List;
	Var I:Integer;
	Begin
		Clear_Screen;
		For I:=1 to Msg_Ln Do Begin
			EchoSE( MesgL[I] );
		End;
	End;

	Procedure Delete_Desc_Line;
	Var
		I,X,Strt,Lst:Integer;
	Begin
		EchoS( 'Delete (1-' );
		Writev(Line,Msg_Ln);
		EchoS( Line );
		EchoS( ') From [1]: ' );
		I := Get_Number( Msg_Ln );
		If I <> 0 Then Begin
			If I = -1 Then Begin; Strt := 1; EchoS( '1' ); End
			Else
				Strt := I;
			EchoS( ' To [' );
			Writev(Line,Strt);
			EchoS( Line );
			EchoS( ']: ' );
			I := Get_Number( Msg_Ln );
			If I = -1 Then Begin; Lst := Strt; Writev( Line, Lst ); EchoS( Line ); End
			Else
				Lst := I;
			X:=Lst-(Strt-1);  { Total # of Lines...}
			For I:=Strt to Msg_Ln Do Begin
				MesgL[I] := MesgL[I+X];
			End;
			Msg_Ln := Msg_Ln - X;
		End;
		CrLf;
	End;

	Procedure List_Desc_Line( Md:Short_Integer );
	Var
		I,Strt,Lst:Integer;
		Temp : String;
	Begin
		Strt := 1;
		Lst := Msg_Ln;
		EchoS( 'List (1-' );
		Writev(Line,Msg_Ln);
		EchoS( Line );
		EchoS( ') From [1]: ' );
		I := Get_Number( Msg_Ln );
		If I <> 0 Then Begin
			If I = -1 Then Begin; Strt := 1; EchoS( '1' ); End
			Else
				Strt := I;
			EchoS( ' To [' );
			Writev(Line,Msg_Ln);
			EchoS( Line );
			EchoS( ']: ' );
			I := Get_Number( Msg_Ln );
			If I = -1 Then Begin; Lst := Msg_Ln; Writev( Line, Lst ); EchoS( Line ); End
			Else
				Lst := I;
			CrLf;
			For I:=Strt to Lst Do Begin
				If Md=2 Then Writev( Temp,I:2, ': ', MesgL[I] )
					Else Temp := MesgL[I];
				If Ord(Temp[0]) >= 79 Then Temp[0] := Chr(79);
				EchoSE( Temp );
			End;
		End;
	End;

	Procedure Insert_Line;
	Var
		I, X, Strt, Lst : Integer;
		Temp : String;
	Begin
		EchoS( 'Insert Before (1-' );
		Writev(Line,Msg_Ln);
		EchoS( Line );
		EchoS( ') Line [' );
		Writev(Line,Msg_Ln);
		EchoS( Line );
		EchoS( ']: ' );
		X := Get_Number( Msg_Ln );
		If (X>0) And (X<=Msg_Ln) Then Begin
			Strt := X +1;
			Lst := Msg_Ln +1;
			For I := Lst Downto Strt Do Begin
				MesgL[I] := MesgL[I-1];
			End;
			CrLf;
			CrLf;
			EchoS( ']' );
			Caps := False;
			Line_In( Temp, 78 );
			MesgL[X] := Temp;
			Msg_Ln := Msg_Ln +1;
			CrLf;
		End
		Else EchoSE( ' Aborted...' );
	End;

	Procedure Edit_Line;
	Var
		I : Integer;
		Temp,OldL : String;
	Begin
		EchoS( 'Edit Which Line (1-' );
		Writev(Line,Msg_Ln);
		EchoS( Line );
		EchoS( ') ?' );
		I := Get_Number( Msg_Ln );
		If (I<>0) And (I<=Msg_Ln) Then Begin
			If (I<>-1) And (I<>-2) Then Begin
				CrLf;
				OldL:=MesgL[I];
				EchoSE( ' Old Line Reads:' );
				Writev( Line,'- ',OldL );
				EchoSE( Line );
				EchoS( '+ ' );
				Caps := False;
				Line_In( Temp, 78 );
				MesgL[I] := Temp;
			End
			Else EchoSE( 'Line Unchanged...');
		End
		Else EchoSE( 'Line Unchanged...');
		CrLf;
	End;

	Procedure Pack_Lines;
	Var
	N,X,I : Integer;
	Ok : Boolean;
	Temp : String;
	Begin
		X := Msg_Ln;
		Repeat
			Temp:=MesgL[X];
			Ok:=True;
			For I := 1 To Length(Temp) Do
	 			If Temp[I]<>' ' Then Ok:=False;
			If (Temp='') or (Ok) Then Begin
				For I:=X to Msg_Ln Do Begin
					MesgL[I] := MesgL[I+1];
				End;
				Msg_Ln := Msg_Ln -1;
			End;
			X := X -1;
		Until X=1;
		EchoSE( 'Packing...Done' );
		CrLf;
	End;

	Procedure Show_Column_Bar;
	Begin
		Back_Space;
		Back_Space;
		Back_Space;
		If WidT=40 Then Begin
			EchoSE('\r ----+----|----+----|----+----|----+---\b');
			End
		Else Begin
			EchoS( '\r' );
			EchoS(' ----+----|----+----|----+----|----+----|----+----|----+----|----+----|----+---');
			EchoSE( '\b' );
		End;
	End;

	Procedure Show_Desc_Help;
	Var S : String;
	Begin
		Clear_Screen;
		CrLf;
		EchoSE( ' Mesage Editor Commands: ' );
		CrLf;
		S := '[\rA\b] Abort This Message';
		Show_40( S );
		S := '[\rB\b] Begin Over Again';
		Show_40( S );
		S := '[\rC\b] Display Column Bar';
		Show_40( S );
		S := '[\rD\b] Delete Line(s)';
		Show_40( S );
		S := '[\rE\b] Edit A Line';
		Show_40( S );
		S := '[\rF\b] Formatted List';
		Show_40( S );
		S := '[\rI\b] Insert A Line';
		Show_40( S );
		S := '[\rL\b] List Lines (No numbers)';
		Show_40( S );
		S := '[\rN\b] Line Lines (With Numbers)';
		Show_40( S );
		S := '[\rP\b] Pack (Remove All Blank Lines)';
		Show_40( S );
		S := '[\rR\b] Repeat Last Line';
		Show_40( S );
		S := '[\rS\b] Save Message';
		Show_40( S );
		S := '[\rU\b] Save Message (Unformatted';
		Show_40( S );
		S := '[\rV\b] Video Width Change';
		Show_40( S );
		S := '[\rW\b] Word Wrap Toggle (On/Off)';
		Show_40( S );
		S := '[\rY\b] Change Your Prompt Char';
		Show_40( S );
		S := '[\r/\b] Clear The Screen';
		Show_40( S );
		S := '[\r?\b] This Help Screen';
		Show_40( S );
		CrLf;
		EchoSE('Precede These Comnds with a Forward Slash "\r/\b" ');
		CrLf;
	End;

	Procedure Show_Line_Status;
	Begin
		CrLf;
		If (Msg_Ln<=19) Then Begin
			Msg_Ln := Msg_Ln + 1;
			MesgL[Msg_Ln] := MLin;
		End
		Else EchoSE( 'Out Of Room...' );
		If (Msg_Ln=19) Then EchoSE( 'One More Line Left...' );
	End;

	Procedure Edit_Description;
	Label
		100;
	Var
		KyCnt, Strt, Lst : Integer;
		Ch : Char;
		Wrap, Done : Boolean;
		S,Word,Null : String;
	Begin
		Clear_Screen;
		Lin_No := Msg_Ln;
		WW_Toggle:=True;
100:
		SaveM := False;
		MLin :='';
		Null := '';
		Wrap := False;
		CrLf;
		EchoSE('\r\i Press / To Enter Edit Mode, /S - Save,  /A - Abort, /? - Help\i\b' );
		CrLf;
		Show_Column_Bar;
		Repeat
			If (Wrap) Then Begin; Enter_Line( MLin, Word, Ch, KyCnt, Wrap, Word ); End
				Else If Wrap=False Then Enter_Line( MLin, Word, Ch, KyCnt, Wrap, Null );
			If (KyCnt=1) And (Wrap=False) Then Begin
				Case Ch of
					'A' : Abort := True;
					'B' : Begin
									EchoS( 'Begin Over...Are You Sure? ' );
									If ( Yes_No('N') ) Then Begin
										Msg_Ln:=Lin_No;
										Clear_Screen;
										Goto 100;
									End;
								End;
					'C' : Show_Column_Bar;
					'D' : Delete_Desc_Line;
					'E' : Edit_Line;
					'F' : Frmt_List;
					'I' : Insert_Line;
					'L' : List_Desc_Line(1);
					'N' : List_Desc_Line(2);
					'P' : Pack_Lines;
					'R' : If Msg_Ln <20 Then Begin
									EchoSE( MesgL[Msg_Ln] );
									Msg_Ln := Msg_Ln + 1;
									MesgL[Msg_Ln] := MesgL[Msg_Ln - 1];
								End;
					'S' : Begin
									EchoS( 'Saving Description...');
									Save_Description;
									EchoSE( 'Thanks' );
									SaveM := True;
								End;
					'U' : Begin; Save_Description; SaveM := True; End;
					'V' : Begin
									If WidT = 80 Then WidT := 40
									Else WidT := 80;
									Writev( S, 'Video Width Now ', WidT );
									EchoSE( S );
								End;
					'W' : Begin
									If WW_Toggle = True Then WW_Toggle:=False
									Else WW_Toggle:=True;
									EchoS( 'Word Wrap Is Now ' );
									If WW_Toggle = True Then S:='On'
									Else S:='Off';
									EchoSE( S );
								End;
					'Y' : Begin
									EchoS( 'Enter New Prompt Char :> ');
									Prompt := Get_Char;
								End;
					'/' : Clear_Screen;
					'?' : Show_Desc_Help;
					Else If Ord(Ch)=Cr Then Show_Line_Status
					Else Begin; Back_Space; Back_Space; Back_Space; End;
				End; { Case }
			End
			Else Show_Line_Status;
		Until (Abort) or (SaveM) or (Carrier=False);
	End;

	Procedure Edit_Uploader;
	Var
		S : String;
	Begin
		CrLf;
		EchoS('Enter New Name -> ');
		Caps := False;
		Line_In( S, 22 );
		MesgL[1] := S;
	End;

	Procedure Edit_DL_Count;
	Var
		S : String;
	Begin
		CrLf;
		EchoS('Enter New D/L Count -> ');
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
		EchoSE('Rating Selections');
		CrLf;
		EchoS( '[\r1\b] ' );
		EchoSE( Rating[1] );
		EchoS( '[\r2\b] ' );
		EchoSE( Rating[2] );
		EchoS( '[\r3\b] ' );
		EchoSE( Rating[3] );
		EchoS( '[\r4\b] ' );
		EchoSE( Rating[4] );
		EchoS( '[\r5\b] ' );
		EchoSE( Rating[5] );
		EchoS( '[\r6\b] ' );
		EchoSE( Rating[6] );
		CrLf;
		EchoS( 'Enter Rating Of This File -> ' );
		Repeat
			Choice := Get_Char;
			If Choice In['0'..'6'] Then Begin
				S := Rating[Ord(Choice)-48];
				MesgL[3] := S;
				EchoSE( S );
				Done := True;
			End;
		Until (Done) or (Carrier=False);
	End;

	Procedure Kill_File;
	Var
		X : Integer;
	Begin
		CrLf;
		EchoS( '\r Kill\b, Are You Sure? ' );
		If ( Yes_No('N') )Then Begin
			CrLf;
			X := UnLink( Desc_Path_C );
			If X <0 Then Show_Error( Desc_Path, X );
			X := UnLink( F_Path );
			If X >= 0 Then EchoSE( ' File Is Now Erased From Drive...' )
			Else Show_Error( F_Name, X );
		End
		Else EchoSE( ' Aborted...' );
	End;

	Procedure Hide_File;
	Var
		X : Integer;
	Begin
		X := ChMode( F_Path, 1, 1 );
		If X<0 Then Show_Error(F_Name, X);
		CrLf;
		EchoSE( ' File Is Now Hidden...' );
		Hide_Mode := False;
	End;

	Procedure Valid_File;
	Var
		X : Integer;
	Begin
		X := ChMode( F_Path, 1, 0 );
		If X<0 Then Show_Error(F_Name, X);
		CrLf;
		EchoSE( ' File Is Now Visible...' );
		DT_Stamp( F_Path );
		Hide_Mode := True;
	End;

	Procedure Rename_File;
	Var
		X : Long_Integer;
		Temp, Old_N, New_N : String;
		OldN, NewN, NewD : Cstring;
	Begin
		CrLf;
		EchoS( ' Enter NEW Name Of File -> ' );
		Caps := False;
		Line_In( Temp, 12 );
		Old_N := Concat( System2.Paths[Sig_Num], File_Name );
		MakeCstring( Old_N, OldN );
		New_N := Concat( System2.Paths[Sig_Num], Temp );
		MakeCstring( New_N, NewN );
		X := Rename( 0, OldN, NewN );
		Dummy_I := Int(X);
		Show_Error( Old_N, Dummy_I );

		Old_N := Concat( System2.Paths[Sig_Num], 'DESC\', File_Name );
		MakeCstring( Old_N, OldN );
		New_N := Concat( System2.Paths[Sig_Num], 'DESC\', Temp );
		MakeCstring( New_N, NewD );
		X := Rename( 0, OldN, NewD );
		Dummy_I := Int(X);
		Show_Error( Old_N, Dummy_I );
		Fname := NewN;
		If Sfirst( NewN, 0 ) = 0 Then Make_F_Names;
		Show_File( F_Name );
	End;

	Procedure Change_Drv_Path( Var S: Str60 );
	Var
		L,I,X : Integer;
		C_Pth : CString;
		P_Pth : String;
	Begin
		F_Name := S;
		L := Length(S);
		Show_File( F_Name );
		Drv := ord( S[1] ) - 65;
		If ((Drv>=0) And (Drv<16)) And (L>2) Then Begin
			For X := 0 to 79 Do
				C_Pth[X] := Chr(0);
			X := 0;
			L := L - 3;
			I := 3;
			Repeat
				C_Pth[X] := S[I];
				X := X + 1;
				I := I + 1;
			Until (X=L);
			C_Pth[X] := Chr(0);
			Dummy_L := SetDrv( Drv );
			Dummy_I := ChDir( C_Pth );
			Show_Error( S, Dummy_I );
		End
		Else Begin
			If (L<3) then Begin
				Line := Concat( 'Pathname for ', System2.TNames[Top_Sig], '>', System2.Names[Sig_Num], ' Too Short!!!' );
				Show_Error( Line, -68 );
			End;
			If (Drv<0) or (Drv>15) then Begin
				Line := Concat( 'Invalid Drive In Pathname: ', S );
				Show_Error( Line, -68 );
			End;
		End;
	End;

	Procedure Update_DL_Status;
	Var
		X : Integer;
		S : String[6];
	Begin
		If (Use_Desc) Then Begin
			MakeCstring( Desc_Path, Desc_Path_C );
			Get_Description(20);
			Readv( MesgL[2], X );
			X := X + 1;
			Writev( S, X );
			MesgL[2] := S;
			Save_Description;
		End;
	End;

	Function Ask_LogOff:Boolean;
	Begin
		Ask_LogOff := False;
		CrLf;
		EchoS( 'Log Off After Tranfer? ' );
		If  ( Yes_No('N') ) Then Begin
			Ask_LogOff := True;
		End;
	End;

	Procedure Show_Batch_Status( Md:Integer; Cnt:Integer );
	Var
		K : Short_Integer;
		X : Integer;
		C : Cstring;
		Temp, F : String;
	Begin
		Log(1);
		For K := 1 to BM_Num Do Begin
			Temp :=BMark[K].BM_Fname;
			If (Md=1) And (K<=Cnt) Then Begin
				X := BMark[K].BM_Sig;
				Desc_Path := Concat( System2.Paths[X], 'DESC\', Temp);
				Update_DL_Status;
			End;
	   	F := Concat( System2.Temp_Path, Temp );
			DescL[1] := F;
			Log(1);
			If (One_Sig=False) Then Begin
				MakeCString( F, C );
				X := UnLink( C );
				If X <0 Then Show_Error( F, X );
			End;
		End;
	End;

	Procedure Batch_Send;
	Var
		Ch : Char;
		Lgff : Boolean;
		K,X : Short_Integer;
		I,T : Integer;
	Begin
		If BM_Num >0 Then Begin
			CrLf;
			EchoSE( ' [\rY\b] YModem' );
			EchoSE( ' [\rZ\b] ZModem' );
			CrLf;
			EchoS( ' Choice, [Return] to Exit -> ' );
			Return := 16;
			Repeat
				Lgff := False;
				Ch := Get_Char;
				Ch := Upper_C( Ch );
				K := Ord( Ch );
			Until (Ch='Y') or (Ch='Z') or (K=Cr) or (Carrier=False);
			If (Ch='Y') or (Ch='Z') Then Begin
				If (Ask_LogOff) Then Lgff := True;
				Case Ch of
					'Y' : Begin
									EchoSE( ' YModem' );
									Cmd_Line := '-u -y ';
									Batch_Mode := True;
									Xfer_Type := 'Ymodem Batch';
									Return := Exec_Xyz;
								End;
					'Z' : Begin
									EchoSE( ' ZModem' );
									Cmd_Line := '-u -z ';
									Batch_Mode := True;
									Xfer_Type := 'Zmodem Batch';
								Return := Exec_Xyz;
								End;
				End; { Case }
				I := 0;
				T := 0;
				If Return <> 0 Then Begin
					For X := 1 to BM_Num Do Begin
						I := I + BMark[X].BM_D_Time;
						If (I<Xfer_Time) Then T := X;
					End;
					Writev( Line, 'Xfer_Time = ', Xfer_Time, '  Estimated Time = ', I, ' of ', BM_Num, ' Files...' );
					Descl[1] := Line;
					Log(1);
					If T>0 Then Return := 0;
				End
				Else T := BM_Num;
				If (Return=0) Then Begin
					New_Dls := New_Dls + BM_Num;
					Show_DL_UL;
					DescL[1] := Concat( 'Completed ', Xfer_Type, ' Download Of :' );
					Show_Batch_Status(1,T);
				End
				Else Begin
					DescL[1] := Concat( 'Aborted ', Xfer_Type, ' Download Of :' );
					Show_Batch_Status(0,T);
				End;
				BM_Num := 0;
				One_Sig := True;
				Batch_Mode := False;
				If (Lgff) Then Begin
					CrLf;
					EchoSE( 'Transfer Completed... Logging Off As Requested...' );
					Disconnect;
				End;
			End
			Else If (K=Cr) Then EchoSE( 'Aborted...' );
		End
		Else Show_None_Marked;
	End;

	Procedure DownLoad_File( Var Temp : String );
	Var
		Ch, C2 : Char;
		Done, Lgff : Boolean;
		K : Short_Integer;
		X : Integer;
	Begin
   	File_Name := Temp;
		Lgff := False;
		CrLf;
		EchoSE( ' Download Protocols Available' );
		CrLf;
		EchoSE( ' [\rA\b] Ascii' );
		EchoSE( ' [\rX\b] XModem' );
		EchoSE( ' [\rC\b] XModem Crc' );
		EchoSE( ' [\rK\b] XModem 1k' );
		EchoSE( ' [\rY\b] Ymodem (Single-File)' );
		EchoSE( ' [\rZ\b] ZModem (Single-File)' );
		EchoSE( ' [\rB\b] Batch Send' );
		EchoSE( ' [\gReturn\b] to Abort' );
		CrLf;
		EchoS( ' Choice -> ' );
		Repeat
			Return := 16;
			Ch := Get_Char;
			Ch := Upper_C( Ch );
			K := Ord( Ch );
			Case Ch of
				'A' : Begin
								EchoSE( ' Ascii' );
								Xfer_Type := 'Ascii';
								Done := True;
							End;
				'X' : Begin
								EchoSE( ' Xmodem' );
								Cmd_Line := '-u -x -c ';
								Xfer_Type := 'Xmodem Std';
								Done := True;
							End;
				'C' : Begin
								EchoSE( ' Xmodem Crc' );
								Cmd_Line := '-u -x ';
								Xfer_Type := 'Xmodem Crc';
								Done := True;
							End;
				'B' : Begin
								EchoSE( ' Batch Send' );
								Return := 1;
								Batch_Send;
								Done := True;
							End;
				'K' : Begin
								EchoSE( ' Xmodem 1k' );
								Cmd_Line := '-u -x1k ';
								Xfer_Type := 'Xmodem 1k';
								Done := True;
							End;
				'Y' : Begin
								EchoSE( ' Ymodem' );
								Cmd_Line := '-u -y ';
								Xfer_Type := 'Ymodem';
								Done := True;
							End;
				'Z' : Begin
								EchoSE( ' Zmodem' );
								Cmd_Line := '-u -z ';
								Xfer_Type := 'Zmodem';
								Done := True;
							End;
			End; { Case }
		Until (Done) or (Carrier=False) or (K=Cr);
		If (K=Cr) Then EchoSE( 'Aborted...' )
		Else If (Return<>1) Then Begin
			If (Ask_LogOff) Then Lgff := True;
			If (Ch='A') Then Read_File
			Else If (Ch='X') or (Ch='C') or (Ch='K') or (Ch='Y') or (Ch='Z') Then
				Return := Exec_Xyz;
			If (Done) And (Return=0) Then Begin
				New_Dls := New_Dls + 1;
				Show_DL_UL;
				Update_DL_Status;
				DescL[1] := Concat( 'Completed ', Xfer_Type, ' Download Of : ', File_Name );
			End
			Else If (Return<0) Then Begin
				DescL[1] := Concat( 'Aborted ', Xfer_Type, ' Download Of : ', File_Name );
				EchoSE( 'Aborted...' );
				End;
			Log(1);
		End;
		If (Lgff) Then Begin
			CrLf;
			EchoSE( 'Transfer Completed... Logging Off As Requested...' );
			Disconnect;
		End;
	End;

	Procedure Download_A_File;
	Var
		Temp : String;
	Begin
		CrLf;
		EchoS( ' Enter Filename -> ' );
		Caps := True;
		Line_In( Temp, 12 );
		If Filename_Ok( Temp ) = True Then Begin
	   	File_Name := Temp;
			If Exists( File_Name ) Then
				Download_File( Temp )
			Else
				EchoSE( ' Sorry, That File Doesn''t Exist!!!' );
		End
		Else EchoSE( '\r Illegal Filename...\b' );
	End;

	Procedure Batch_Upload;
	Var
		Ch : Char;
		Done : Boolean;
		K : Short_Integer;
	Begin
		CrLf;
		CrLf;
		EchoSE( ' [\rY\b] YModem' );
		EchoSE( ' [\rZ\b] ZModem' );
		CrLf;
		EchoS( ' Choice (Return to Exit) -> ' );
		Repeat
			Done := False;
			Ch := Get_Char;
			Ch := Upper_C( Ch );
			K := Ord( Ch );
			Case Ch of
				'Y' : Begin
								EchoSE( ' YModem' );
								Cmd_Line := '-y ';
								Batch_Upld := True;
								Xfer_Type := 'Ymodem Batch';
								Change_Drv_Path( System2.Upld_Pth );
								Return := Exec_Xyz;
								Change_Drv_Path( System2.Paths[Sig_Num] );
								Done := True;
							End;
				'Z' : Begin
								EchoSE( ' ZModem' );
								Cmd_Line := '-z ';
								Batch_Upld := True;
								Xfer_Type := 'Zmodem Batch';
								Change_Drv_Path( System2.Upld_Pth );
								Return := Exec_Xyz;
								Change_Drv_Path( System2.Paths[Sig_Num] );
								Done := True;
							End;
			End; { Case }
		Until (Done) or (Carrier=False) or (K=Cr);
		DescL[1] := Concat( 'Completed ', Xfer_Type, ' Upload...' );
		Log(1);
		BM_Num := 0;
		If (K=Cr) Then EchoSE( 'Aborted...' )
	End;

	Procedure Upload_A_File;
	Var
		Ch : Char;
		Temp : String;
		Done : Boolean;
		K : Short_Integer;
	Begin
		CrLf;
		EchoS( '[\rS\b]ingle File, [\rB\b]atch -> ' );
		Repeat
			Ch := Get_Char;
			Ch := Upper_C( Ch );
			K := Ord( Ch );
		Until (K=Cr) or (Ch='B') or (Ch='S') or (Carrier=False);
		If (Ch='S') Then Begin
			If (Show_Free) Then Show_Dfree;
			EchoS( ' Enter Filename -> ' );
			Caps := True;
			Line_In( Temp, 12 );
			If Filename_Ok( Temp ) = True Then Begin
				If Exists( Temp ) Then EchoSE( 'That File Already Exists...' )
				Else Begin
					CrLf;
					CrLf;
					File_Name := Temp;
					EchoSE( ' Upload Protocols Available:' );
					CrLf;
					EchoSE( ' [\rX\b] XModem Std' );
					EchoSE( ' [\rC\b] XModem Crc' );
					EchoSE( ' [\rK\b] XModem 1k' );
					EchoSE( ' [\rY\b] Ymodem (Single File)' );
					EchoSE( ' [\rZ\b] ZModem (Single-File)' );
					EchoSE( ' [\rA\b] or [Return] to Abort ');
					CrLf;
					EchoS( ' Choice -> ' );
					Repeat
						Return := 16;
						Ch := Get_Char;
						Ch := Upper_C( Ch );
						K := Ord( Ch );
						Case Ch of
							'X' : Begin
											EchoSE( ' Xmodem' );
											Cmd_Line := '-d -xc ';
											Xfer_Type := 'Xmodem Std';
											Return := Exec_Xyz;
											Done := True;
										End;
							'C' : Begin
											EchoSE( ' Xmodem Crc' );
											Cmd_Line := '-d -x ';
											Xfer_Type := 'Xmodem Crc';
											Return := Exec_Xyz;
											Done := True;
										End;
							'K' : Begin
											EchoSE( ' Xmodem 1k' );
											Cmd_Line := '-d -x ';
											Xfer_Type := 'Xmodem 1k';
											Return := Exec_Xyz;
											Done := True;
										End;
							'Y' : Begin
											EchoSE( ' Ymodem' );
											Cmd_Line := '-d -y ';
											Xfer_Type := 'Ymodem';
											Batch_Upld := True;
											Return := Exec_Xyz;
											Done := True;
										End;
							'Z' : Begin
											EchoSE( ' Zmodem' );
											Cmd_Line := '-d -z ';
											Xfer_Type := 'Zmodem';
											Batch_Upld := True;
											Return := Exec_Xyz;
											Done := True;
										End;
						End; { Case }
					Until (Done) or (Carrier=False) or (K=Cr);
					If (Ch='A') or (K=Cr) Then EchoSE( 'Aborted...' )
					Else If (Done) And (Return=0) Then Begin
						New_Uls := New_Uls + 1;
						Show_DL_UL;
						F_Name := Concat( System2.Paths[Sig_Num], File_Name );
						MakeCstring( F_Name, F_Path );
						Desc_Path := Concat( System2.Paths[Sig_Num], 'DESC\', File_Name );
						MakeCstring( Desc_Path, Desc_Path_C );
						DT_Stamp( F_Path );
						Hide_File;
						Clear_Screen;
						MesgL[1] := UserRec.UHandle;
						MesgL[2] := '0';
						Edit_Rating;
						Msg_Ln := 4;
						CrLf;
						Temp := Concat( 'Please Enter A Description Of ', File_Name );
						EchoSE( Temp );
						CrLf;
						Clear_Screen;
						Edit_Description;
						DescL[1] := Concat( 'Completed ', Xfer_Type, ' Upload Of : ', File_Name);
					End
					Else If (Return<0) or (Return=16) Then Begin
						DescL[1] := Concat( 'Aborted ', Xfer_Type, ' Upload Of : ', File_Name);
						EchoSE( 'Aborted...' );
					End;
				End;
				Log(1);
			End
			Else EchoSE( ' \rIllegal Filename...\b' );
			CrLf;
		End
		Else If (Ch='B') Then Batch_Upload
		Else EchoSE( 'Aborted...' );
	End;

	Procedure Show_List_Opt;
	Begin
		CrLf;
		EchoS( '[\rA\b]gain  ');
		EchoS( '<\gC\b>ont  ' );
		EchoS( '[\rM\b]ark  ' );
		If Arc_File Then Begin
			Line := Concat( '[\rU\b]n', Arc_Type[ArcT], '  ' );
			EchoS( Line );
			End;
		If Arc_File = False Then EchoS( '[\rR\b]ead   ' );
		EchoS( '[\rQ\b]uit  ' );
		EchoS( '[\rD\b]ownload  ' );
		EchoS( '[\r?\b]Help  ');
		If (Sig_Op) Then Begin
			CrLf;
			EchoS( '\r\iSigOp Commands:>\i\b ' );
			If (Sig2_Edit[Sig_Num]=1) Then EchoS( '[\rE\b]dit  ' );
			If (Sig2_Kill[Sig_Num]=1) Then EchoS( '[\rK\b]ill  ' );
			If (Sig_Ops) Then EchoS( ' [\rN\b]ame  ' );
			If (Sig2_Valid[Sig_Num]=1) And (Hide_Mode=False) Then EchoS( '[\rV\b]alid' );
			If (Sig2_Valid[Sig_Num]=1) And (Hide_Mode) Then EchoS( '[\rH\b]ide ' );
			If (Sig_Ops) Then EchoSE( ' [\rF\b]ile Maint.' );
			CrLf;
		End
			Else CrLf;
		EchoS( 'File Cmnd:> ' );
	End;

	Procedure Show_File_Help;
	Var
		S : String;
	Begin
		Clear_Screen;
		CrLf;
		EchoSE( ' File Commands:' );
		CrLf;
		S := '[\rA\b] Again - Same Description';
		Show_40( S );
		S := '[\gC\b] Continue (Or Press "Return")';
		Show_40( S );
		S := '[\rM\b] Mark This File For Batch Transfer';
		Show_40( S );
		S := '[\rR\b] Read ASCII Text File';
		Show_40( S );
		S := '[\rU\b] Verbose Listing Of ARC/LZH/ZIP/SIT';
		Show_40( S );
		S := '[\rQ\b] Quit To SIG Menu';
		Show_40( S );
		S := '[\rD\b] Download This File';
		Show_40( S );
		CrLf;
		CrLf;
		EchoSE( ' SigOp Commands:' );
		CrLf;
		S := '[\rE\b] Edit Description & File Stats';
		Show_40( S );
		S := '[\rK\b] Kill This File';
		Show_40( S );
		S := '[\rN\b] Name This File';
		Show_40( S );
		S := '[\rH\b] Hide This File';
		Show_40( S );
		S := '[\rV\b] Validate File (Time/Date Stamp)';
		Show_40( S );
		CrLf;
		Show_List_Opt;
	End;

	Procedure Show_File1;
	Var
		FF, Temp : String;
	Begin
		Fn_Convert( File_Name, FF );
		AddSpaces( FF, 14 );
		Writev( Temp, Lines:2, '  ', FF );
		Writev( Line, Dta_Data.Size:6, '  ' );
		Temp := Concat( Temp, Line );
		Convert_Date( Dta_Data.Date );
		AddSpaces( Line, 14 );
		Temp := Concat( Temp, Line );
		Line := MesgL[4];
		If Ord(Line[0])>38 Then Line[0] := Chr( 39 );
		Temp := Concat( Temp, Line );
		EchoSE( Temp );
	End;

	Procedure Show_File2;
	Var
		Temp : String;
		X : Long_Integer;
	Begin
		CrLf;
		CrLf;
		New_Line := False;

		Arc_File := False;
		If Pos('.ARC', File_Name) >1 Then Begin; ArcT:= 1;Arc_File := True; End;
		If Pos('.LZH', File_Name) >1 Then Begin; ArcT:= 2;Arc_File := True; End;
		If Pos('.ZIP', File_Name) >1 Then Begin; ArcT:= 3;Arc_File := True; End;
		If Pos('.SIT', File_Name) >1 Then Begin; ArcT:= 4;Arc_File := True; End;

		Temp := Concat( '\rFilename\b      : ', File_Name );
		AddSpaces( Temp, 34 );
		If (Hide_Mode=False) Then Temp := Concat( Temp, '<<New>>' );
		Show_40( Temp );

		DL_Time := ((Dta_Data.Size Div Cps) Div 60);
		If DL_Time <1 Then DL_Time := 1;
		Writev( Temp, '\rDownLoad Time\b : ', DL_Time, ' Mins' );
		Show_40( Temp );

		Writev( Temp, '\rFile Size\b     : ', Dta_Data.Size );
		Show_40( Temp );

		Writev( Temp, '\rUploaded By\b   : ', MesgL[1] );
		Show_40( Temp );

		Writev( Temp, '\rDownLoad Count\b: ', MesgL[2] );
		Show_40( Temp );

		Convert_Date( Dta_Data.Date );
		Writev( Temp, '\rUploaded On\b   : ', Line );
		Show_40( Temp );

		Writev( Temp, '\rUser Rating\b   : ', MesgL[3] );
		Show_40( Temp );

		Convert_Time( Dta_Data.Time );
		Writev( Temp, '\rUploaded At\b   : ', Line );
		Show_40( Temp );

		X := ((Dta_Data.Size) + 1023) Div 1024;
		Writev(Temp, '\rBlocks\b : Y/Zmodem: ', X );
		EchoS(Temp);

		X := ((Dta_Data.Size) + 127) Div 128;
		Writev(Temp, ',  Xmodem: ', X );
		EchoSE(Temp);
		CrLf;
		If Msg_Ln >3 Then Begin
			For X := 4 to Msg_Ln Do
				EchoSE( MesgL[X] );
			End
		Else
			EchoSE(' No Description');
	End;

	Procedure Edit_File;
	Var
		Done, No_Chng: Boolean;
		Choice : Char;
	Begin
		Done := False;
		No_Chng := False;
		Repeat
			Clear_Screen;
			Show_File2;
			CrLf;
			EchoSE( '[\rU\b]ploader  [\rC\b]ount  [\rR\b]ating  [\rL\b]evel  [\rD\b]escription' );
			EchoSE( '[\rA\b]bort     [\rS\b]ave');
			CrLf;
			EchoS( 'Edit Command -> ' );
			Choice := Get_Char;
			Choice := Upper_C( Choice );
			Case Choice Of
				'A' : Begin; EchoSE('Abort'); No_Chng := True; End;
				'S' : Begin
								EchoSE('Save');
								If (Use_Desc) Then Save_Description;
								If Sfirst( Fname, 0 ) = 0 Then Done := True;
								Done := True;
							End;
				'U' : Begin; EchoSE('Uploader'); Edit_Uploader; End;
				'C' : Begin; EchoSE('D/L Count'); Edit_DL_Count; End;
				'R' : Begin; EchoSE('Rating'); Edit_Rating; End;
				'D' : Begin
								EchoSE('Description');
								Edit_Description;
								If (Abort) Then Abort := False;
								End;
				Else Begin
					Show_Wrong;
					CrLf;
				End;
			End; { Case }
		Until (Done) or (No_Chng) or (Carrier=False);
	End;

	Procedure Show_Top_Sigs;
	Var
		X,X1,I : Integer;
		Temp : String;
	Begin
		X := 0;
		I := 0;
		Clear_Screen;
		CrLf;
		If Max_Sig >0 Then Begin
			EchoSE( '  Topic Sigs Available:' );
			CrLf;
			Repeat
				I := I + 1;
				X1 := Sig_Access[I];
				Writev( Temp, '[\r', I, '\b] ', System2.TNames[X1] );
				If I<10 Then Temp := Concat( ' ', Temp );
				If WidT=80 Then Addspaces( Temp ,43 );
				X := X + 1;
				If (Odd(X)) And (WidT=80) Then EchoS( Temp )
					Else EchoSE( Temp );
			Until (I=Max_Sig) or (Carrier=False);
			If Odd(X) Then CrLf;
		End;
		CrLf;
	End;

	Procedure Show_Sigs;
	Var
		X,X1,I : Integer;
		T : Long_Integer;
		Temp : String;
	Begin
		T := UserAcs.User_Mask[Top_Sig];
		EchoSE( 'Show Sigs' );
		Clear_Screen;
		CrLf;
		Temp := Concat( 'File Sigs Available In ', System2.TNames[Top_Sig] );
		EchoSE( Temp );
		X := 0;
		I := (Top_Sig-1) * 32;
		CrLf;
		If (Max_Sub>0) And (T<>0) Then Begin
			Repeat
				X := X + 1;
				X1 := Sig2_Access[I];
				Writev( Temp, '[\r', X, '\b] ', System2.Names[X1] );
				If X<10 Then Temp := Concat( ' ', Temp );
				If WidT=80 Then Addspaces( Temp ,43 );
				If (Odd(X)) And (WidT=80) Then EchoS( Temp )
					Else EchoSE( Temp );
				I := I + 1;
			Until (X=Max_Sub) or (Carrier=False);
			If Odd(X) Then CrLf;
		End
		Else EchoSE(' You Don''t Have Access Here!' );
		CrLf;
	End;

	Procedure Get_Sig_Nums;
	Var
		I, X, Num : Integer;
		V, F, A, Bit : Long_Integer;
	Begin
		Top_Sig := Sig_Access[Top_Cntr];
		I := ((Top_Sig-1)*32);
		Num := I+(Sig_Cntr-1);
		Sig_Num := Sig2_Access[Num];
		Use_Desc := System2.Use_Desc[Num];
		Show_Free := System2.Show_Free[Num];
		Max_Avail := System2.Sigcount[Top_Sig-1];
		Max_Sub := 0;
		V := $80000000;
		F := UserAcs.User_Mask[Top_Sig];
		Bit := 1;
		For X := 1 to 32 Do Begin
	   	If (F & Bit>0) or (F & Bit=V) Then Max_Sub := Max_Sub + 1;
			Bit := Bit * 2;
		End;
		Sig_Op := False;
		Sig_Ops := False;
		V := $20000000;
		F := UserRec.Sec_Lvl;
		If (F & V > 0) Then Sig_Ops := True;
		If (Sig2_Valid[Sig_Num]=1) or (Sig2_Edit[Sig_Num]=1)
			or (Sig2_Kill[Sig_Num]=1) Then Sig_Op := True;
		Show_SigOp_Stats;
	End;

	Procedure Change_Topic( Md: Short_Integer );
	Var
		X1, X, Y, T, Num : Integer;
		Choice : Char;
	Begin
		T := Top_Cntr;
		Show_Top_Sigs;
		If (Md=0) Then EchoS( ' Enter Topic Sig# -> ')
		Else EchoS( ' Select Topic Sig To Copy File To :> ' );
		Choice := Get_Char;
		If Choice In['1'..'9'] Then Begin
			Put_Char( Choice );
			X := Ord(Choice) - 48;
			Y := 16;
			If Max_Sig >= (X * 10) Then Begin
				Choice := Get_Char;
				If Choice In['0'..'9'] Then Put_Char( Choice );
				If Ord(Choice) <> 13 Then Begin
					Y := Ord(Choice) - 48;
					If Y = 10 Then Y := 0;
				End;
			End;
			If (X <= Max_Sig) And (Y = 16) Then Top_Cntr := X
			Else Begin
					X := ( X * 10 ) + Y;
					If (X <= Max_Sig) Then Top_Cntr := X;
				End;
			CrLf;
		End;
		Sig_Cntr := 1;
		Get_Sig_Nums;
		Change_Drv_Path( System2.Paths[Sig_Num] );
		CrLf;
		CrLf;
	End;

	Procedure Copy_2_Sig( Md : Short_Integer );
	Var
		X,Y, Top_Tmp, Sig_Tmp, TS, Mxg, Mxb : Integer;
		Old_N, New_N : String;
		Cs : CString;
	Begin
		Y := Sig_Num;
		Ts := Top_Sig;
		Mxg := Max_Sig;
		Mxb := Max_Sub;
		Top_Tmp := Top_Cntr;
		Sig_Tmp := Sig_Cntr;

		Change_Topic(1);
		Show_Sigs;
		EchoS( ' Select SubTopic Sig To Copy File To :> ' );
		X := Get_Number( Max_Sub );
		If X >0 Then Begin
			Sig_Cntr := X;
			Get_Sig_Nums;
			Change_Drv_Path( System2.Paths[Sig_Num] );
			CrLf;
	   	Old_N := Concat( System2.Paths[Y], File_Name );
 	  	New_N := Concat( System2.Paths[Sig_Num], File_Name );
			MakeCString( Old_N, Cs );
			EchoS ( 'Copying ' );
			EchoSE( Old_N );
			EchoS ( ' To --> ' );
			EchoSE( New_N );
			Copy_File( Old_N, New_N );
			If (Md=1) Then Begin
				X := UnLink( Cs );
				If (X<0) Then Show_Error( Old_N, X );
			End;

	   	Old_N := Concat( System2.Paths[Y], 'DESC\', File_Name );
 	  	New_N := Concat( System2.Paths[Sig_Num], 'DESC\', File_Name );
			MakeCString( Old_N, Cs );
			EchoS ( 'Copying ' );
			EchoSE( Old_N );
			EchoS ( ' To --> ' );
			EchoSE( New_N );
			Copy_File( Old_N, New_N );
			If (Md=1) Then Begin
				X := UnLink( Cs );
				If (X<0) Then Show_Error( Old_N, X );
			End;
		End;

		Sig_Num := Y;
		Top_Sig := Ts;
		Max_Sig := Mxg;
		Max_Sub := Mxb;
		Top_Cntr := Top_Tmp;
		Sig_Cntr := Sig_Tmp;
	End;

	Procedure File_Maint;
	Var
		X : Integer;
		Ch : Char;
		Done : Boolean;
	Begin
		Clear_Screen;
		Repeat
			CrLf;
			EchoSE( ' [\rC\b]  Copy File To Another SIG' );
			EchoSE( ' [\rM\b]  Move File To Another SIG' );
			EchoSE( ' [\rS\b]  Show Free Space On Current Drive' );
			EchoSE( ' [\rT\b]  Touch File (Time/Date Stamp)' );
			CrLf;
			EchoS( ' Enter Choice, [Return] to Exit -> ' );
			Repeat
				Ch := Get_Char;
				Ch := Upper_C( Ch );
				X := Ord( Ch );
			Until (Ch='C') or (Ch='M') or (Ch='S') or (Ch='T') or
			(X=Cr) or (Carrier=False);
			If (X=Cr) Then Done := True;
			Case Ch Of
				'C' : Copy_2_Sig(0);
				'M' : Copy_2_Sig(1);
				'S' : Begin; CrLf; Show_DFree; Press_Any; End;
				'T' : DT_Stamp( F_Path );
			End; {Case}
		Until (Done) or (Carrier=False);
	End;

	Procedure Get_Lst_Options;
	Var
		Ch : Char;
		Temp : String;
		Done : Boolean;
		Show : Boolean;
	Begin
		Show := False;
		Show_File2;
		Show_List_Opt;
		Repeat
			If (Show) Then Begin
				Clear_Screen;
				Show_File2;
				Show_List_Opt;
			End;
			Done:=False;
			Ch := Get_Char;
			Ch := Upper_C(Ch);
			Case Ch Of
				'A' : Begin; EchoSE('Again'); Show := True; End;
				'C' : Begin; EchoSE('Cont'); Done := True; End;
				'M' : Begin; EchoSE('Mark'); Batch_Mark_File; Done := True; End;
				'D' : Begin; EchoSE('Download'); Download_File(File_Name); Show := True; End; 
				'U' : If Arc_File Then Begin
								Show_File( F_Name );
								Temp := Concat( 'Un\r', Arc_Type[ArcT], '\b  ' );
								EchoS( Temp );
								If ArcT = 1 Then List_Arc( F_Name )
								Else If ArcT = 2 Then List_Lzh( F_Name )
								Else If ArcT = 3 Then List_Zip( F_Name )
								Else If ArcT = 4 Then List_Sit( F_Name );
								Press_Any;
								Show := True;
								End;
				'R' : If Arc_File = False Then Begin
								EchoSE('Read');
								Read_File;
								Show := True;
							End;
				'V' : If (Hide_Mode=False) And (Sig2_Valid[Sig_Num]=1) Then Begin
								EchoSE('Valid');
								Valid_File;
								Show := True;
							End
							Else Show_Wrong;
				'H' : If (Hide_Mode) and (Sig2_Valid[Sig_Num]=1) Then Begin
								EchoSE('Hide');
								Hide_File;
								Show := True;
							End
							Else Show_Wrong;
				'E' : If (Sig2_Edit[Sig_Num]=1) Then Begin
								EchoSE('Edit');
								Edit_File;
								Show := True;
							End
							Else Show_Wrong;
				'F' : If (Sig2_Edit[Sig_Num]=1) Then Begin
								EchoSE('Maint.');
								File_Maint;
								Show := True;
							End
							Else Show_Wrong;
				'N' : If (Sig2_Edit[Sig_Num]=1) Then Begin
								EchoSE('Name');
								Rename_File;
								Show := True;
							End
							Else Show_Wrong;
				'K' : If (Sig2_Kill[Sig_Num]=1) Then Begin
								EchoSE('Kill');
								Kill_File;
								Done := True;
							End
							Else Show_Wrong;
				'?' : Begin; EchoSE('Help'); Show_File_Help; Show := False; End;
				'Q' : Begin
								If (Quick_Scan) Then Begin
									EchoS( 'Abort Quick Scan? ' );
								  If ( Yes_No('N') ) Then Begin
										Quick_Scan := False;
										Abort := True;
									End;
								End
								Else EchoSE('Quit');
								Abort :=True;
							End;
				Else If Ord(Ch)<>Cr Then Show_Wrong;
			End;
		Until (Abort) or (Carrier=False) or (Done) or (Ord(Ch)=Cr);
		CrLf;
	End;

	Procedure Show_List;
	Var
		I,X : Integer;
		Ok : Boolean;
		Ch : Char;
		Temp : String;
	Begin
		If (New_Files) And (Usr_Lst_Call<=Dta_Data.Date) And (Valid_New=False) or
			(Find_File) And (Dta_Data.Date>=Find_Date) or
			(New_Files) And (Valid_New) or
			(New_Files=False) And (Find_File=False) Then Begin
				Ok := True;
				If (Use_Desc) Then Begin
					If (Valid_New=False) Then Get_Description(20);
					If (Sig2_Valid[Sig_Num]=0) And (Hide_Mode=False) Then Ok := False;
					Is_Ok := Ok;
				End;
				If (Valid_New=False) And (Ok) Then Clear_Screen;
				If (Kywrd_Srch) And (Use_Desc) And (Ok) Then Begin
					Ok := False;
					For X := 1 to Msg_Ln Do Begin
						Temp := MesgL[X];
						For I := 1 to Length( Temp ) Do Begin
							Ch := Temp[I];
							If (Ch In['a'..'z']) Then Begin
								Ch := Chr(Ord(Ch)-32);
								Temp[I] := Ch;
							End;
						End;
						If Pos(Srch_Str, Temp) >1 Then Ok := True
					End;
				End;
				If (Valid_New) And (Hide_Mode) Then Ok := False;
				If (Ok) And (Valid_New) Then Get_Description(20);
				If (Ok) Then Get_Lst_Options;
			End
	End;

	Procedure Show_Scan;
	Var
		I,X : Integer;
		Ok : Boolean;
		Ch : Char;
		Temp : String;
	Begin
		If (New_Files) And (Usr_Lst_Call<=Dta_Data.Date) or
			(Find_File) And (Dta_Data.Date>=Find_Date) or
			(New_Files=False) And (Find_File=False) Then Begin
				Ok := True;
				If (Use_Desc) Then Begin
					If (Kywrd_Srch=False) Then Get_Description(4)
						Else If (Kywrd_Srch) Then Get_Description(20);
					If (Sig2_Valid[Sig_Num]=0) And (Hide_Mode=False) Then Ok := False;
				End;
				If (Ok) And (Kywrd_Srch) And (Use_Desc) Then Begin
					Ok := False;
					For X := 1 to Msg_Ln Do Begin
						Temp := MesgL[X];
						For I := 1 to Length( Temp ) Do Begin
							Ch := Temp[I];
							If (Ch In['a'..'z']) Then Begin
								Ch := Chr(Ord(Ch)-32);
								Temp[I] := Ch;
							End;
						End;
						If Pos(Srch_Str, Temp) >1 Then Ok := True
					End;
				End;
				If (Ok) Then Begin
					DL_Time := ((Dta_Data.Size Div Cps) Div 60);
					If DL_Time <1 Then DL_Time := 1;
					SMark[Lines].BM_Fname := File_Name;
					SMark[Lines].BM_Fsize := Dta_Data.Size;
					SMark[Lines].BM_D_Time := DL_Time;
					If Carrier Then Show_File1;
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
			Writev( Line, 'Mark Which File (1-', Lines-1, ') -> ' );
			EchoS( Line );
			K := Get_Number( Lines-1 );
			If (K>0) Then Begin
				File_Name     := SMark[K].BM_Fname;
				Dta_Data.Size := SMark[K].BM_Fsize;
				DL_Time       := SMark[K].BM_D_Time;
				Batch_Mark_File;
			End;
		Until (K<1) or (Carrier=False);
		CrLf;
	End;

	Procedure Show_Scn_Hdr;
	Begin
		If New_Files = False Then Begin
			CrLf;
			EchoSE( 'No  Filename       Size   Uploaded On   Short Description' );
			EchoSE( '--  ------------  ------  ------------  -----------------' );
		End;
	End;

	Procedure Scan_Files( Mode : Integer );
	Var
   	X : Integer;
		Ch : Char ;
		Done : Boolean;
	Begin
		Done := False;
		If Mode<1 Then
			Begin
				CrLf;
 				EchoS( 'Enter Search Spec Or (Return For *.*): ');
				Caps := True;
 		  	Line_In( Sspec, 12 );
 		  	If (Sspec='') Then Sspec := '*.*';
				CrLf;
			End
		Else Sspec := '*.*';
   	FPath := Concat( System2.Paths[Sig_Num], Sspec );
		MakeCstring( FPath, Fname );
		Lines :=1;
		If Sfirst( Fname, 0 ) = 0 Then Begin
			Show_Scn_Hdr;
			Make_F_Names;
			Show_Scan;
			While (Snext=0) And (Done=False) Do Begin
				Make_F_Names;
				Show_Scan;
				If Lines = 17 Then Begin
					CrLf;
					EchoS( '[\rD\b]ownload  [\rM\b]ark  [\gN\b]ext Page  [\rQ\b]uit ' );
					Repeat
						Ch := Get_Char;
						Ch := Upper_C(Ch);
						Case Ch Of
							'D' : Begin; EchoSE('Download'); DownLoad_A_File; Done := True; End;
							'M' : Begin; EchoSE('Mark'); Scan_Mark; Lines:=1; Show_Scn_Hdr; End;
							'N' : Begin; EchoSE('Next'); Lines := 1; Show_Scn_Hdr; End;
							'Q' : Begin
											If (Quick_Scan) Then Begin
												EchoS( 'Abort Quick Scan? ' );
											  If ( Yes_No('N') ) Then Quick_Scan := False;
											End
											Else EchoSE('Quit');
											Abort :=True;
											Done := True;
										End;
						Else If Ch=Chr(Cr) Then Begin; EchoSE('Next'); Lines := 1; Show_Scn_Hdr; End;
						End;
					Until (Done) or (Abort) or (Carrier=False) or (Lines=1);
				End;
			End; {While}
			If (Lines>1) And (Done=False) And (Abort=False) Then Begin
				CrLf;
				EchoS( '[\rD\b]ownload  [\rM\b]ark  [\gQ\b]uit ' );
				Repeat
					Ch := Get_Char;
					Ch := Upper_C(Ch);
					Case Ch Of
						'D' : Begin; EchoSE('Download'); DownLoad_A_File; Done := True; End;
						'M' : Begin; EchoSE('Mark'); Scan_Mark; Done:=True; End;
						'Q' : Begin
										If (Quick_Scan) Then Begin
											EchoS( 'Abort Quick Scan? ' );
										  If ( Yes_No('N') ) Then Quick_Scan := False;
										End
										Else EchoSE('Quit');
										Abort :=True;
										Done := True;
									End;
					Else If Ch=Chr(Cr) Then Begin; EchoSE('Quit'); Done:=True; End;
					End; {Case}
				Until (Done) or (Abort) or (Carrier=False);
				CrLf;
				CrLf;
			End;
		End
		Else Begin
			CrLf;
			If Sspec = '*.*' Then EchoSE( 'This Sig Is Empty...' )
				Else EchoSE( 'No Files Match Search Spec...' );
		End;
		If (New_Files=False) Then CrLf;
		If (Abort) Then Abort := False;
 	End;

	Procedure List_Files( Mode : Integer );
	Var
   	X : Integer;
	Begin
		If Mode<1 Then
			Begin
				CrLf;
 				EchoS( 'Enter Search Spec Or (Return For *.*): ');
				Caps := True;
 	  		Line_In( Sspec, 12 );
 	  		If (Sspec='') Then Sspec := '*.*';
				CrLf;
			End
		Else Sspec := '*.*';
   	FPath := Concat( System2.Paths[Sig_Num], Sspec );
		MakeCstring( FPath, Fname );
		If (Sfirst( Fname, 0 ) = 0) Then Begin
			Make_F_Names;
			Show_List;
			While ( Snext=0 ) and (Abort=False) Do Begin
				Make_F_Names;
				Show_List;
				If (New_Files=False) And (Find_File=False) And (Is_Ok) Then CrLf;
			End;
			If (New_Files=False) And (Abort=False) Then Begin; CrLf; EchoSE( 'No More Files...' ); End;
		End
		Else Begin
			CrLf;
			If Sspec = '*.*' Then EchoSE( 'This Sig Is Empty...' )
				Else EchoSE( 'No Files Match Search Spec...' );
		End;
		If (New_Files=False) Then CrLf;
		If (Abort) Then Abort := False;
 	End;

	Procedure Keyword_Search;
	Var
		Ln, X, Y : Integer;
	Begin
		Kywrd_Srch := True;
		CrLf;
		EchoS( 'Enter String To Search -> ' );
		Caps := True;
		Line_In( Srch_Str, 15 );
		Ln := Length( Srch_Str );
		If Ln>0 Then Begin
			CrLf;
			If (List_Mode) Then List_Files( 3 )
				Else Scan_Files( 3 );
		End
		Else EchoSE(' Aborted...' );
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
		If Ln>2 Then Begin
			If (Check_Line(Temp, '/', 2 )) Then Begin
				Line := Copy( Temp, Ln-1, 2 );
				Date_Ok := Is_Numeric( Line );
				If (Date_Ok) Then Begin
					Readv( Line, Y );
					If (Y<1) and (Y>99) Then Date_Ok := False;
					X := Pos( '/', Temp );
					Line := Copy( Temp, 1, X-1 );
					Date_Ok := Is_Numeric( Line );
					If (Date_Ok) Then Begin
						Readv( Line, M );
						If (M<1) and (M>12) Then Date_Ok := False;
						Temp := Copy( Temp, X+1,3);
						X := Pos( '/', Temp );
						Line := Copy( Temp, 1, X-1 );
						Date_Ok := Is_Numeric( Line );
						If (Date_Ok) Then Begin
							Readv( Line, D );
							If (D<1) and (D>31) Then Date_Ok := False;
							If (Date_Ok) Then Begin
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
			If (Date_Ok = False) Then Begin
				EchoSE(' Invalid Date Format!');
				Crlf;
			End;
		End
		Else EchoSE(' Aborted...' );
		Get_Find_Date := Date_Ok;
	End;

	Procedure Do_New_Files;
	Begin
		Line := Concat( 'Checking Files In -> ',System2.TNames[Top_Sig], '>', System2.Names[Sig_Num], ' :> ' );
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

	Procedure Change_Sig;
	Begin
		Repeat
			Tot_Sig := False;
			Sig_Cntr := Sig_Cntr +1;
			If Sig_Cntr > Max_Sub Then Begin
				Sig_Cntr := 1;
				Top_Cntr := Top_Cntr + 1;
				If Top_Cntr > Max_Sig Then Begin
					Top_Cntr := Max_Sig;
					Tot_Sig := True;
				End;
			End;
			Get_Sig_Nums;
		Until (Max_Sub>0) or (Tot_Sig) or (Carrier=False);
		Change_Drv_Path( System2.Paths[Sig_Num] );
		CrLf;
		If BM_Num <> 0 Then One_Sig := False;
	End;

	Procedure Search_New;
	Var
   	Done : Boolean;
		Ch : Char;
		X,Y, Top_Tmp, Sig_Tmp, TS, Mxg, Mxb : Integer;
	Begin
		Y := Sig_Num;
		Ts := Top_Sig;
		Mxg := Max_Sig;
		Mxb := Max_Sub;
		Top_Tmp := Top_Cntr;
		Sig_Tmp := Sig_Cntr;
		Done := False;
		Find_File := False;
		Flush_Input;
		CrLf;
		EchoSE( '[\gN\b] All New Files Since Last Call' );
		EchoSE( '[\rD\b] All Files By Specified Date' );
		CrLf;
		EchoS( 'Choice -> ' );
		Ch := Get_Char;
		Ch := Upper_C( Ch );
		If Ord(Ch)=Cr Then Ch := 'N';
		Case Ch Of
			'N' : Begin
							Quick_Scan := True;
							EchoSE('ALL New Files...');
							Top_Cntr := 1;
							Sig_Cntr := 0;
							Top_Sig := Sig_Access[Top_Cntr];
							Max_Sub := System2.SigCount[Top_Sig-1];
							Loop
								Change_Sig;
								Exit If (Tot_Sig) or (Quick_Scan=False);
								List_New_Files;
							End;
							Quick_Scan := False;
						End;
			'D' : Begin
							Quick_Scan := True;
							EchoSE('By Date...');
							If (Get_Find_Date) Then Begin
								Top_Cntr := 1;
								Sig_Cntr := 0;
								Top_Sig := Sig_Access[Top_Cntr];
								Max_Sub := System2.SigCount[Top_Sig-1];
								Loop
									Change_Sig;
									Exit If (Tot_Sig) or (Quick_Scan=False);
								(*	List_Files( 2 ); *)
									List_New_Files;
								End;
								Quick_Scan := False;
							End;
						End;
			End; { Case }
		Sig_Num := Y;
		Top_Sig := Ts;
		Max_Sig := Mxg;
		Max_Sub := Mxb;
		Top_Cntr := Top_Tmp;
		Sig_Cntr := Sig_Tmp;
		Find_File := False;
	End;

	Procedure List_Scan;
	Var
   	Done : Boolean;
		Choice : Char;
		X,Y, Top_Tmp, Sig_Tmp, TS, Mxg, Mxb : Integer;
	Begin
		Y := Sig_Num;
		Ts := Top_Sig;
		Mxg := Max_Sig;
		Mxb := Max_Sub;
		Top_Tmp := Top_Cntr;
		Sig_Tmp := Sig_Cntr;
		Done := False;
		Find_File := False;
		Flush_Input;
		CrLf;
		EchoSE( '[\gA\b] All Files' );
		EchoSE( '[\rN\b] New Files' );
		EchoSE( '[\rS\b] Since Specified Date' );
		EchoSE( '[\rK\b] Keyword Search of Description' );
		CrLf;
		EchoS( 'Choice -> ' );
		Choice := Get_Char;
		Choice := Upper_C( Choice );
		If Ord(Choice)=Cr Then Choice := 'A';
		Case Choice Of
			'S' : Begin
							EchoSE('By Date');
							If (Get_Find_Date) Then Begin
								If (List_Mode) Then List_Files( 2 )
									Else Scan_Files( 2 );
							End;
						End;
			'K' : Begin; EchoSE('Keyword Search'); Keyword_Search; End;
			'A' : Begin
							If (List_Mode) Then Begin
								EchoSE('List All');
								List_Files(0);
								End
							Else Begin
								EchoSE('Scan All');
								Scan_Files(0);
								End;
						End;
			'N' : Begin
							If (List_Mode) Then Begin
								EchoSE('List New');
								New_Files := True;
								List_Files( 1 );
								New_Files := False;
								End
							Else Begin
								EchoSE('Scan New');
								New_Files := True;
								Scan_Files( 1 );
								New_Files := False;
								End;
						End;
		End; {Case}
		Sig_Num := Y;
		Top_Sig := Ts;
		Max_Sig := Mxg;
		Max_Sub := Mxb;
		Top_Cntr := Top_Tmp;
		Sig_Cntr := Sig_Tmp;
	End;

	Procedure Edit_TopSig( Sig : Integer );
	Var
		S : String;
		Ch : Char;
		Done : Boolean;
		X,Y,I : Integer;
		Fa,Fm,Fv,Fe,Fk,V, Bit : Long_Integer;
	Begin
		Repeat
			MesgL[1] := ' [1] Access    : ';
			MesgL[2] := ' [2] User Mask : ';
			MesgL[3] := ' [3] Edit Desc : ';
			MesgL[4] := ' [4] Validate  : ';
			MesgL[5] := ' [5] Kill File : ';
			Fa := UserAcs.Sig_Accs[ Sig ];
			Fm := UserAcs.User_Mask[ Sig ];
			Fe := UserAcs.Sig_Edit[ Sig ];
			Fv := UserAcs.Sig_Valid[ Sig ];
			Fk := UserAcs.Sig_Kill[ Sig ];
			Bit := 1;
			X := 32;
			V := $80000000;
			For I := 1 to 32 Do Begin
				If (Fa & Bit>0) or (Fa & Bit=V) Then Mesgl[1] := Concat( MesgL[1], 'Y' )
					Else Mesgl[1] := Concat( MesgL[1], '.' );
				If (Fm & Bit>0) or (Fm & Bit=V) Then Mesgl[2] := Concat( MesgL[2], 'Y' )
					Else Mesgl[2] := Concat( MesgL[2], '.' );
				If (Fe & Bit>0) or (Fe & Bit=V) Then Mesgl[3] := Concat( MesgL[3], 'Y' )
					Else Mesgl[3] := Concat( MesgL[3], '.' );
				If (Fv & Bit>0) or (Fv & Bit=V) Then Mesgl[4] := Concat( MesgL[4], 'Y' )
					Else Mesgl[4] := Concat( MesgL[4], '.' );
				If (Fk & Bit>0) or (Fk & Bit=V) Then Mesgl[5] := Concat( MesgL[5], 'Y' )
					Else Mesgl[5] := Concat( MesgL[5], '.' );
				Bit := Shl(Bit,1);
				X := X + 1;
			End;
			Clear_Screen;
			CrLf;
			Writev( S, 'Editing Topic Sig #', Sig, '  -  ', System2.TNames[Sig] );
			EchoNE( S );
			CrLf;
			EchoNE('                       Sub-Topic File SIGS       ' );
			EchoNE('                         1         2         3   ' );
			EchoNE('     Function    12345678901234567890123456789012' );
			EchoNE('     ---------   --------------------------------' );
			EchoNE( MesgL[1] );
			EchoNE( MesgL[2] );
			EchoNE( MesgL[3] );
			EchoNE( MesgL[4] );
			EchoNE( MesgL[5] );
			CrLf;
			Done := False;
			I := 0;
			EchoN( 'Enter Function To Edit [Return] to Exit -> ' );
			Repeat
				Ch := Chr( Get_Console );
				I := Ord(Ch);
			Until (Ch IN['1'..'5']) or (I=Cr) or (Carrier=False);
			CrLf;
			CrLf;
			If (I=Cr) Then Done := True;
			If Ch In['1'..'5'] Then Begin
				Y := Ord(Ch) - 48;
				S := Concat( ' Old -> ', MesgL[Y] );
				EchoNE( S );
				S := Concat( ' New -> ', MesgL[Y] );
				EchoN( S );
				For I := 1 to 32 Do
					Back_Space;
				V := 0;
				X := 31;
				Bit := 1;
				For I := 1 to 32 Do Begin
					Repeat
						Ch := Chr( Get_Console );
						Ch := Upper_C( Ch );
					Until (Ch='Y') or (Ch='N' ) or (Carrier=False);
					If Ch = 'Y' Then EchoS( Ch )
						Else EchoS('.');
					If Ch='Y' Then V := ( V | Bit);
					Bit := Shl(Bit,1);
				End;
				CrLf;
				CrLf;
				If Y = 1 Then UserAcs.Sig_Accs[ Sig ] := V
				Else If Y = 2 Then UserAcs.User_Mask[ Sig ] := V
				Else If Y = 3 Then UserAcs.Sig_Edit[ Sig ] := V
				Else If Y = 4 Then UserAcs.Sig_Valid[ Sig ] := V
				Else UserAcs.Sig_Kill[ Sig ] := V;
			End;
		Until (Done) or (Carrier=False);
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
			CrLf;
			For Sig := 1 to NumSigs Do Begin
				Ok := False;
				For I := 1 to 32 Do
					If Sig_Access[I] = Sig Then Ok := True;
				Writev( S, '  ',Sig:4, '.  ' );
				If Length(SysTem2.TNames[Sig]) = 0 Then S := Concat( S, '*- Empty -*')
				Else If (Ok=False) Then S := Concat( S, ' - Not Authorized -' )
				Else S := Concat( S, System2.TNames[Sig] );
				AddSpaces( S, 39 );
				EchoS( S );
				If Not Odd( Sig ) Then CrLf;
			End;
			If Odd( Sig ) Then CrLf;
			CrLf;
			S := ' Enter # Of Topic Sig To Edit [Return] to Exit -> ';
			EchoN( S );
			Sig := Get_Number( NumSigs );
			If (Sig>0) Then Begin
				Edit_TopSig( Sig );
			End;
		Until (Sig<0) or (Carrier=False);
	End;

	Function Change_Stats : Integer;
	Var
		X,X1,I : Integer;
		Fa, Fb, Bit, V : Long_Integer;
		Temp : String;
		Sig_X : Packed Array[1..32] of Integer;
		Sig_B : Packed Array[1..32] of Long_Integer;
	Begin
		Clear_Screen;
		CrLf;
		Bit := 1;
		X := 0;
		X1 := 0;
		V := $80000000;
		I := (Top_Sig-1) * 32;
		Fa := UserAcs.Sig_Accs[ Top_Sig ];
		Fb := UserAcs.User_Mask[ Top_Sig ];
		EchoSE( 'Sigs You Currently Have Access To:' );
		CrLf;
		Repeat
			If (Fa & Bit>0) or (Fa & Bit=V) Then Begin
				X := X + 1;
				Sig_X[X] := X;
				Sig_B[X] := Bit;
				Writev( Temp, '[\r', X, '\b] ', System2.Names[I] );
				If X<10 Then Temp := Concat( ' ', Temp );
				Addspaces( Temp ,39 );
				If ((Fa & Bit>0) or (Fa & Bit=V)) And ((Fb & Bit>0) or (Fb & Bit=V))
				Then Temp := Concat(Temp, 'Yes ') Else Temp := Concat(Temp, 'No  ');
				If (Odd(X)) And (WidT=80) Then EchoS(Temp) Else EchoSE(Temp);
			End;
			X1 := X1 + 1;
			I := I + 1;
			Bit := Bit * 2;
		Until (X1=Max_Avail) or (Carrier=False);
		If Odd(X) Then CrLf;
		CrLf;
		EchoS( 'Enter Sig# To Change or [Return] To Exit -> ' );
		I := Get_Number( Max_Avail );
		If I>0 Then Begin
			X1 := 1;
			Repeat
				X := Sig_X[X1];
				X1 := X1 + 1;
			Until (X=I) or (Carrier=False);
			Bit := Sig_B[X];
			If (Fb & Bit>0) or (Fb & Bit=V) Then Fb := ( Fb - Bit)
				Else Fb := ( Fb | Bit);
			UserAcs.User_Mask[ Top_Sig ] := Fb;
		End;
		Get_Sig_Access;
		Get_Sig_Nums;
		CrLf;
		CrLf;
		Change_Stats := I;
	End;

	Procedure Edit_User;
	Var
		C,I,U,N,Z, Usr_T : Integer;
		X : Long_Integer;
		Done : Boolean;
		S : String;
		Ch : Char;
	Begin
		Usr_T := Usr_No;
   	Reset( Userfile, Userfilename );
   	X := Fseek( 0, Handle(Userfile), 2 );
   	Close( Userfile );
		X := (X Div 292) - 1;
		Done := False;
		N := 15;
		For I := 1 to X Do Begin
			Clear_Screen;
			CrLf;
			EchoNE( '  User   User_Handle           User_Name           ' );
			EchoNE( '  ----   --------------------  --------------------' );  
			If (I+15) > X Then N := (X-I);
			For U := I To (I+N) Do Begin
				Usr_No := U;
				Get_UserData;
				If (UserRec.In_Use) Then Writev( S, '  ',Usr_No:4, '>  ', UserRec.UHandle )
					Else Writev( S, '  ',Usr_No:4, '>  <Deleted User>' );
				AddSpaces( S, 30 );
				If (UserRec.In_Use) Then S := Concat( S, UserRec.Name );
				AddSpaces( S, 51 );
				EchoNE( S );
			End;
			CrLf;
			S := 'Enter User# To Edit, [Return] For More, ''0'' To Exit  -> ';
			EchoN( S );
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
					EchoNE( S );
					CrLf;
					EchoNE( '[1]  Edit Sig Access  ' );
					CrLf;
					EchoNE( '[2  Apply User Mask  ' );
					CrLf;
					S := 'Enter Choice or [Return] To Exit -> ';
					EchoN( S );
					Ch := Get_Char;
					CrLf;
					Case Ch Of
						'1' : Edit_Usr_Sigs;
						'2' : Begin
									S := 'Enter Mask Number to Apply, [Return] To Exit  -> ';
									EchoN( S );
									Z := Get_Number( 10 );
									If (Z>0) Then Get_MaskData( Z );
									End;
					End; { Case }
					If (Ord(Ch)=Cr) Then Done := True;
				Until (Done) or (Carrier=False);
				Save_Ftu_User;
			End
			Else If (Z<0) Then Begin
				I := I + N;
				If I >= X Then I := X;
			End
			Else If (Z=0) Then I := X;
		End;
		Usr_No := Usr_T;
		Get_UserData;
		Get_Ftu_User;
		Get_Sig_Access;
	End;
	
	Procedure SigOp_Functions;
	Var
		Ch : Char;
		S : String;
		Z : Integer;
	Begin
		Fnct_Key := 0;
		Clear_Screen;
		CrLf;
		EchoNE( ' [1]  Edit User Currently Online  ' );
		EchoNE( ' [2]  Edit User From Userdata File' );
		EchoNE( ' [3]  Validate New Files          ' );
		CrLf;
		EchoN( ' Choice -> ' );
		Ch := Get_Char;
		Case Ch Of
			'1' : Begin
							Repeat
								Clear_Screen;
								CrLf;
								EchoNE( '[1]  Edit Sig Access  ' );
								CrLf;
								EchoNE( '[2  Apply User Mask  ' );
								CrLf;
								EchoN( 'Choice, [Return] To Exit -> ' );
								Ch := Get_Char;
								Case Ch Of
									'1' : Edit_Usr_Sigs;
									'2' : Begin
												S := 'Enter Mask Number to Apply, [Return] To Exit  -> ';
												EchoN( S );
												Z := Get_Number( 10 );
												If (Z>0) Then Get_MaskData( Z );
											End;
								End; { Case }
							Until (Ord(Ch)=Cr) or (Carrier=False);
							Save_Ftu_User;
							Get_Sig_Access;
							CrLf;
						End;
			'2' : Edit_User;
			'3' : Begin
							EchoSE('Validate New');
							Top_Cntr := 1;
							Sig_Cntr := 0;
							Top_Sig := Sig_Access[Top_Cntr];
							Max_Sub := System2.SigCount[Top_Sig-1];
							Loop
								Change_Sig;
								Exit If (Tot_Sig);
								Find_New_Files;
							End;
						End;
			End; {Case}
		Clear_Screen;
	End;

	Procedure Show_Menu;
	Var
		S : String;
	Begin
		Clear_Screen;
		CrLf;
		New_Line := False;
		S := ( '[\rB\b] Batch Download Marked Files' );
		Show_40( S );
		S := ( '[\rC\b] Change User Settings' );
		Show_40( S );
		S := ( '[\rD\b] Download A File' );
		Show_40( S );
		S := ( '[\rL\b] List Files' );
		Show_40( S );
		S := ( '[\rM\b] Mark A File For Batch Transfer' );
		Show_40( S );
		S := ( '[\rN\b] New File Scan Of ALL SIGS' );
		Show_40( S );
		S := ( '[\rO\b] Change Topic SIG' );
		Show_40( S );
		S := ( '[\rP\b] Page SysOp' );
		Show_40( S );
		S := ( '[\rR\b] Review Marked Files' );
		Show_40( S );
		S := ( '[\rS\b] Scan Files' );
		Show_40( S );
		S := ( '[\rT\b] Time Display Toggle');
		Show_40( S );
		S := ( '[\rU\b] Upload A File' );
		Show_40( S );
		S := ( '[\rW\b] Wipe File(s) From Batch List' );
		Show_40( S );
		S := ( '[\rX\b] eXit, Return To BBS' );
		Show_40( S );
		S := ( '[\rY\b] Your D/L Stats' );
		Show_40( S );
		New_Line := False;
		CrLf;
		S := ( '[\r/\b] Goto Next File Sig' );
		Show_40( S );
		S := ( '[\r*\b] Show Available File Sigs' );
		Show_40( S );
		S := ( '[\r!\b] Quick Log-Off' );
		Show_40( S );
		S := ( '[\r?\b] This Menu' );
		Show_40( S );
		CrLf;
	End;

	Procedure Change_All_Stats;
	Var
		X : Integer;
	Begin
		Repeat
			X := Change_Stats;
		Until (X<1) or (Carrier=False);
		Get_Sig_access;
		Save_Ftu_User;
	End;

	Procedure Show_Q_Help;
	Var
		S : String;
	Begin
		Clear_Screen;
		CrLf;
		New_Line := False;
		S := ( '[\rC\b] Change User Settings' );
		Show_40( S );
		S := ( '[\rO\b] Change Topic SIG' );
		Show_40( S );
		S := ( '[\rX\b] eXit, Return To BBS' );
		Show_40( S );
		S := ( '[\r?\b] This Menu' );
		Show_40( S );
		CrLf;
	End;

	Procedure Show_Main_Help;
	Begin
		Clear_Local;
		EchoCE( '        F1  - Edit User Info,  Validate Files' );
		EchoCE( '        F5  - Enter Chat Mode' );
		EchoCE( ' Shift F10 - Kick Off User' );
		CrLf;
	End;

	Procedure Menu;
	Var
		Choice : Char;
		Done : Boolean;
		X, Y : Integer;
	Begin
		Top_Cntr := 1;
		Sig_Cntr := 1;
		Get_Sig_Nums;
		Sig_Cntr := 0;
		Change_Sig;
		CrLf;
		Show_Top_Sigs;
		EchoSE( 'Press ''O'' To Change Topic Sig...' );
		CrLf;
		Repeat
			Done := False;
			Abort := False;
			List_Mode := False;
			Scan_Mode := False;
			Flush_Input;
			If (Shw_Time) Then Show_Timeleft;
			If (Max_Sub=0) Then Begin
				Writev (Line, '[\r', Top_Cntr, '\b>\r0\b> ' );
				EchoS( Line );
				Line := Concat( System2.TNames[Top_Sig], '> No Access :> ' );
				EchoS( Line );
				Choice := Get_Char;
				Choice := Upper_C( Choice );
				If (Fnct_Key=F1) or ((Ord(Choice)=CtrlE) And (Sig_Ops)) Then SigOp_Functions;
				Case Choice of
					'C' : Begin; EchoSE('Change Stats'); Change_All_Stats; End;
					'O' : Begin; EchoSE('Change Topic SIG'); Change_Topic(0); End;
					'X' : Begin; EchoSE('eXit'); Done := True; End;
					'?' : Begin; EchoSE('Help'); Show_Q_Help; End;
					Else Begin; Show_Wrong; CrLf; End;
				End; { Case }
			End
			Else Begin
				Writev( Line, '[\r', Top_Cntr, '\b>\r', Sig_Cntr, '\b> ' );
				EchoS( Line );
				Line := Concat( System2.TNames[Top_Sig], '>', System2.Names[Sig_Num], ' :> ' );
				EchoS( Line );
				Choice := Get_Char;
				Choice := Upper_C( Choice );
				Case Choice of
					'B' : Begin; EchoSE('Batch D/Load'); Batch_Send; End;
					'C' : Begin; EchoSE('Change Stats'); Change_All_Stats; End;
					'D' : Begin; EchoSE('Download'); DownLoad_A_File; End;
					'L' : Begin; EchoSE('List Files'); List_Mode:=True; List_Scan; End;
					'M' : Begin; EchoSE('Mark'); Batch_Mark; End;
					'N' : Begin; EchoSE('New Files'); Search_New; End;
					'O' : Begin; EchoSE('Change Topic SIG'); Change_Topic(0); End;
					'P' : Begin; EchoSE('Page'); Page_SysOp; End;
					'R' : Begin; EchoSE('Review'); Review_Marked_Files; End;
					'S' : Begin; EchoSE('Scan Files'); Scan_Mode:=True; List_Scan; End;
					'T' : Time_Toggle;
					'U' : Begin; EchoSE('Upload'); Upload_A_File; End;
					'W' : Begin; EchoSE('Wipe'); Wipe_Marked; End;
					'X' : Begin; EchoSE('eXit'); Done := True; End;
					'Y' : Begin; EchoSE('Your D/L Stats'); Show_DL_Stats; End;
					'?' : Begin; EchoSE('Help'); Show_Menu; End;
					'/' : Begin; EchoSE('Change Sig'); Change_Sig; End;
					'*' : Show_Sigs;
					'!' : Disconnect;
					Else If Choice In['1'..'9'] Then Begin
						Put_Char( Choice );
						X := Ord(Choice) - 48;
						Y := 16;
						If Max_Sub >= (X * 10) Then Begin
							Choice := Get_Char;
							If Choice In['0'..'9'] Then Begin
								Put_Char( Choice );
								If Ord(Choice) <> 13 Then Begin
									Y := Ord(Choice) - 48;
									If Y = 10 Then Y := 0;
								End;
							End;
						End;
						If (X <= Max_Sub) And (Y = 16) Then Sig_Cntr := X
						Else Begin
							X := ( X * 10 ) + Y;
							If (X <= Max_Sub) Then Sig_Cntr := X;
						End;
						If Sig_Cntr >0 Then Begin
							Get_Sig_Nums;
							Change_Drv_Path( System2.Paths[Sig_Num] );
						End;
						CrLf;
					End
					Else Begin
						If (Fnct_Key=F1) or ((Ord(Choice)=CtrlE) And (Sig_Ops)) Then SigOp_Functions
						Else If Fnct_Key = Help_Key Then Show_Main_Help
						Else If Fnct_Key = SF10 Then Disconnect
						Else Show_Wrong;
					End;
				End; {Case}
			End;
		Until (Done) or (Carrier=False);
		CrLf;
		CrLf;
	End;

	Procedure About;
	Begin
		CrLf;
		EchoSE( '*************************************' );
		EchoSE( '* Express BBS File Transfer Utility *' );
		EchoSE( '*   Version 2.05    Apr 14, 1991    *' );
		EchoSE( '*      Written By Jay L. Bray       *' );
		EchoSE( '*************************************' );
		CrLf;
		Press_Any;
	End;

Begin           (* Main Program Begins Here... *)
	Io_check( False );
	SetDta( DTA_Data );
	Boot_Drv := CurDisk;
	GetDir( Boot_Path, 0 );
 	Zerotimer;
 	Timeon := Timer;
 	BM_Num := 0;

	Shw_Time := True;
	Chat := False;
	Color := False;
	Inverse := True;
 	VT52 := False;
	Local := False;
	Batch_Mode := False;

	If Cmd_args < 7 Then Begin
		WriteLn( 'Invalid number of command line parameters.' );
		Halt;
	End;
 	Cmd_Getarg( 1, Line );
 	Readv( Line, Ftu_Length );
 	Cmd_Getarg( 2, Baudrate );
	If Baudrate = '19200' Then Begin; Local := True; Baudrate := '2400'; End
	Else If Baudrate = '14.4' Then Baudrate := '14400';
 	Readv( Baudrate, Speed );
	Cps := (Speed Div 10) + 2;
 	Cmd_Getarg( 3, Line );
 	Cmd_Getarg( 4, Number );
	Readv( Number, Usr_No );
	Cmd_Getarg( 5, Width );
	Readv( Width, WidT );
 	Cmd_Getarg( 6, Time_left );
 	Readv( Time_left, Minutes );
 	Cmd_Getarg( 7, Translation );  (* 0= Ascii, 1 = Mono, 2 = Color *)
	Readv( Translation, Transv );

 	If Transv = 2 Then VT52 := True;

	Trans[0] := ' Ascii  ';
	Trans[1] := ' VT52 M ';
	Trans[2] := ' VT52 C ';
	Trans[3] := ' Ansi M ';
	Trans[4] := ' Ansi C ';

	Prompt := '>';
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
	Arc_Type[1] := 'Arc';
	Arc_Type[2] := 'Lzh';
	Arc_Type[3] := 'Zip';
	Arc_Type[4] := 'Sit';
	Arc_Type[5] := 'Pak';
	Rating[1]:= 'Poor';
	Rating[2]:= 'Fair';
	Rating[3]:= 'Good';
	Rating[4]:= 'Very Good';
	Rating[5]:= 'Excellent';
	Rating[6]:= 'Not Tested';

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

	ArcType[1] := ' Stored   ';
	ArcType[2] := ' Packed   ';
	ArcType[3] := ' Squeezed ';
	ArcType[4] := ' Crunched ';
	ArcType[5] := ' Squashed ';
	ArcType[6] := ' <<Dir>>  ';
	ArcType[7] := ' Unknown  ';

	ZipType[1] := ' Stored   ';
	ZipType[2] := ' Shrunk   ';
	ZipType[3] := ' Reduced  ';
	ZipType[4] := ' Imploded ';
	ZipType[5] := ' Unknown  ';

	SitType[1] := ' None     ';
	SitType[2] := ' RLE      ';
	SitType[3] := ' LZW      ';
	SitType[4] := ' Huffman  ';
	SitType[5] := ' * None   ';
	SitType[6] := ' * RLE    ';
	SitType[7] := ' * LZW    ';
	SitType[8] := ' * Huff   ';
	SitType[9] := ' <<Dir>>  ';
	SitType[10]:= ' Unknown  ';

	Lin_Count := 0;
	Tot_DL_Time := 0;
	F_Name[1] := Chr( Ord('A') + Boot_Drv );
	F_Name[2] := ':' ;
	F_Name[0] := chr(2);
	MakePString( Boot_Path, Line );
	F_Name := Concat( F_Name, Line );
	F_Name := Concat( F_Name, '\' );
	Ftu_Path := F_Name;
	Line := Ftu_Path;
	Line := Concat( Line, 'XYZ.TTP' );
	MakeCstring( Line, Xyz_Path );
	Line := Ftu_Path;
	Ftu_UserFile := Concat( Line, 'ftu_data.usr' );
	Ftu_MaskFile := Concat( Line, 'ftu_data.msk' );
 	Get_SysData;
	Get_UserData;
	Get_Ftu_User;
	Get_Sig_Access;
	If (Max_Sig=0) Then Begin
		CrLf;
		EchoSE( 'Sorry, You Can''t Access The Files Yet!!!' );
	End
	Else Begin
		Show_Top5;
		Show_DL_UL;
		Show_File( F_Name );
		Clear_Screen;
		CrLf;
		Usr_Addr := Find_User_Addr;
		New_Dls := 0;
		New_Uls := 0;
		Caps := False;
		Quick_Scan := False;
		Forced_Off := False;
		One_Sig := True;
		Valid_New := False;
		DescL[1] := ' ';
		DescL[2] := Concat( 'Entered FTU At: ', Mil_Time );
		Log(2);
		About;
		Menu;
		If Usr_Addr>2048 Then Begin
			Wpoke( Usr_Addr+220, UserRec.Downloads + New_Dls );
			Wpoke( Usr_Addr+222, UserRec.Uploads + New_Uls );
		End
		Else Begin
			Dummy_I := 0;
			If (New_Uls>0) Then Begin
				Dummy_I := Dummy_I + 1;
				Writev( DescL[Dummy_I], 'Note: Add ', New_Uls, ' To User Uploads...' );
			End;
			If (New_Dls>0) Then Begin
				Dummy_I := Dummy_I + 1;
				Writev( DescL[Dummy_I], 'Note: Add ', New_Dls, ' To User Downloads...' );
			End;
			If (Dummy_I>0) Then Log(Dummy_I);
		End;
		DescL[1] := Concat( 'Exited FTU At: ', Mil_Time );
		DescL[2] := ' ';
		Log(2);
	End;
	Dummy_I := ChDir( Boot_Path );
	Io_check( True );
End.

