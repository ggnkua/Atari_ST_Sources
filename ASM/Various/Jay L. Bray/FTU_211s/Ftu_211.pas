Program FTU;

Const
	Modem = 1;
	Console = 2;
	Timeout = -1;
	Input_Mode = 0;
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
	Cstring   = Packed Array[0..79] Of Char;
	Fn_String = Packed Array[1..14] of Char;
	BlockIO   = Packed Array[1..Block_Size] Of Byte;
	Months    = Packed Array[1..12] of String[4];
	Arc_Types = Packed Array[1..6] of String[3];
	ArcTypes  = Packed Array[1..8] of String[10];
	ZipTypes  = Packed Array[1..5] of String[10];
	SitTypes  = Packed Array[1..10] of String[10];
	Ratings   = Packed Array[1..6] of String[10];
	DLine     = Packed Array[1..5] of String[80];
	MLine     = Packed Array[1..25] of String[80];
	Errors    = Packed Array[1..70] of String[40];
	Xyzs      = Packed Array[0..25] of String[55];
	Tran      = Packed Array[0..4] of String[8];
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
		Userlog  : String[60];
		LogFile  : String[60];
		Upld_Pth : String[60];
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
		Posts_Per_Call : Integer;
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
		SIG_Scan       : Long_Integer;  {   "     "  v1.60 }
	End;

	BM_Area = Packed Record          { Batch Mark Info }    
		BM_FName  : String;
		BM_FSize  : Long_Integer;
		BM_FTime  : Long_Integer;
		BM_Sig    : Integer;
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
	DTA_Data    : DTA;                { Blkio used For dir searches       }

	Usr_Addr    : Long_Integer;
	Timeon      : Long_Integer;       { time the user Entered Files Area }
	TimeLeft    : Long_Integer;       { Time the user has left online...}
	Connected   : Long_Integer;       { Time The User Has Been Online...}
	Time_Start  : Long_Integer;
	Time_Finish : Long_Integer;
	Ftu_Length  : Long_Integer;       { Length Between FTU & UserData }
	Dummy_L     : Long_Integer;

	Sig_Access  : Packed Array[1..32] Of Integer;
	Sig2_Access : Packed Array[0..1023] Of Integer;
	Sig2_Valid  : Packed Array[0..1023] Of Integer;
	Sig2_Edit   : Packed Array[0..1023] Of Integer;
	Sig2_Kill   : Packed Array[0..1023] Of Integer;

	Kywrd_File  : Packed Array[1..256] Of Integer;
	Kywrd_Cnt   : Integer;

	BMark       : Array[1..20] Of BM_Area;
	SMark       : Array[1..16] Of BM_Area;

	UsrDataFtu  : Text;
	Userfile    : File Of Userdata;   { the userlog data file }

	Ftu_UserFile: Str60;
	Ftu_MaskFile: Str60;
	Log_Filename: Str60;
	Userfilename: Str60;         { filename For the userfile  }

	U_Handle    : String;
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
	Ftu_Path    : String;
	FPath       : String;
	Desc_Path   : String;
	Sspec       : String;
	Cmd_Line    : String[128];
	Mil_Time    : String[8];

	Fname       : Cstring;
	Desc_Path_C : CString;
	Xyz_Path    : CString;
	F_Path      : CString;
	Boot_Path   : CString;

	Sig_Num     : Integer;
	Usr_No      : Integer;
	Usr_Tmp     : Integer;
	Visitor_Rec : Integer;
	NewUser_Rec : Integer;
	Usr_Lst_Call: Integer;
	M, D, Y     : Integer;
	NumSigs     : Integer;
	Cur_Time    : Integer;
	Cur_Date    : Integer;
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
	FCur        : Integer;
	FCnt        : Integer;  { Counter used in SFirst - SNext }
	FMax        : Integer;  { Maximum # Of Files Found In SSpec }
	Eod         : Integer;  { End Of Directory Flag }
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
	Rez         : Integer;
	Boot_drv    : Integer;
	Dummy_I     : Integer;
	WidT        : Integer;
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
	Sig_Op      : Boolean;
	Sig_Ops     : Boolean;
	Chat        : Boolean;
	Abort       : Boolean;
	Is_Ok       : Boolean;
	Caps        : Boolean;
	Color				: Boolean;
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

	Prompt      : Char;
	MesgL       : MLine;
	DescL       : Dline;

	Procedure Dummy_Routine;
	Var
		A, B, C : Integer;
	Begin
		A := 9;  B := 9;  C := 9;
		Line := 'Registered To: <<< UnRegistered FTU User >>>  ';
	End;

	Function  Proc_addr( Procedure P ): Long_Integer; External;
	Function  Addr( Var A1 : UserData ): Long_Integer; External;
	Procedure Get_Usr( Dest, Src, Lngth : Long_Integer ); External;
	Procedure Put_Usr( Dest, Src, Lngth : Long_Integer ); External;
	Procedure Draw_Six( W,X,Y,Yoff,CT,CB: Integer; Var S: String );External;
	Procedure Shrink_S( Size, Res: Integer );External;
	Function  Addr_Str( Var S:String ):Long_Integer;External;
	Function  ItoL( X:Integer ):Long_Integer; External;
	Function  LtoI( X:Long_Integer ):Integer; External;
	Function  Peek ( A:Long_Integer ):Byte; External;
	Procedure Poke ( A:Long_Integer; B:Byte ); External;
	Procedure WPoke( A:Long_Integer; W:Integer ); External;
	Function  WPeek( A:Long_Integer ):Integer; External;
	Function  LPeek( A:Long_Integer ):Long_Integer; External;
	Procedure LPoke( A:Long_Integer; L:Long_Integer ); External;
	Procedure Save5;  External;
	Procedure Rest5;  External;
	Procedure Clear5; External;
	Procedure Set_BTD( TD:Long_Integer; Md:Integer ); External;
	Function  Get_BTD( Md:Integer ):Long_Integer; External;
	Function  Fsel_In( Var C1,C2:CString ):Integer; External;
	Procedure Mouse_On; External;
	Procedure Mouse_Off; External;
	Procedure Hang_Up; External;
	Function  Chk_Carrier( L:Boolean ):Boolean; External;
	Procedure Pause( Jif:Integer ); External;
	Procedure Zero_Timer; External;
	Function  Get_Timer : Long_Integer; External;
	Function  Bit_Test( L:Long_Integer; I:Integer ):Boolean; External;
	Procedure Bit_Set ( Var L:Long_Integer; I:Integer ); External;
	Procedure Bit_Clr ( Var L:Long_Integer; I:Integer ); External;
	Function  Drive_Exist( D:Integer ): Boolean; External;
	Function  XOR (Source, Mask: Integer): Integer; External;
	Function Search (Ln, A:Long_Integer ;Var S:String):Long_Integer; External;
	Function Search1(Ln, A:Long_Integer ;Var S:String):Long_Integer; External;
	
	Function SetDrv( Drive: Integer ):Long_Integer;
		GemDos( $0E );

	Function CurDisk: Integer;
		GemDos( $19 );

	Procedure SetDta( Var B: DTA );
		Gemdos( $1A );

	Function Get_SDate: Integer;
		GemDos( $2A );

	Function Get_STime: Integer;
		GemDos( $2C );

	Function DFree( Var B:BlockIO; Drive: Integer ):Integer;
		GemDos( $36 ); { 1:L=Free Clusters, 3:L=Sect Size, 4:L=Sect/Cluster}

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

	Procedure RSconf( Speed, Flowctl, Ucr, Rsr, Tsr, Scr : Integer );
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
		Fnct_Key := Shr( X,16 );
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
		While S[X+1]=' ' Do X := X + 1;
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

	Procedure Get_Time( Var H, M, S : Integer );
	Var X : Long_Integer;
	Begin
		X := Get_BTD( 1 );
		S := ( X & 255 );
		X := Shr( X,8 );
		M := ( X & 255 );
		X := Shr( X,8 );
		H := ( X & 255 );
	End;

	Procedure Get_Date;
	Var X : Long_Integer;
	Begin
		X := Get_BTD( 0 );
		D := ( X & 255 );
		X := Shr( X,8 );
		M := ( X & 255 );
		X := Shr( X,8 );
		Y := ( X & 255 );
	End;

	Procedure Shrink_Scrn( Ln : Integer );
	Begin
		If ( Rez = 2 ) And ( Ln = 5 ) Then Ln := 3;
		Shrink_S( Ln, Rez );
	End;

	Procedure Write_Six( X,Y,C1,C2:Integer; S:String );
	Var
		YOff : Integer;
	Begin
		If ( Rez = 2 ) Then Begin        { Monochrome }
			YOff := 368;
			C1 := Blk;
			C2 := Wht;
		End
		Else YOff := 169;                { Color }
		If ( Ord( S[0] ) > 60 ) Then S[0] := Chr( 60 );
		S := Concat( S, Chr(0), Chr(0) );
		Draw_Six( 16,X,Y,YOff,C1,C2,S );
	End;

	Procedure Get_TimeLeft;
	Begin
		Connected := Get_Timer - Timeon;
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
		Writev( Line, '( \r', Timeleft, '\b Mins ) ' );
	End;

	Procedure Show_Secs_Left;
	Begin
		writev( Temp, Seconds:3 );
		Write_Six( 77, 1, Redd, Blk, Temp );
	End;

	Procedure Show_DL_UL;
	Begin
		UserRec.Downloads := UserRec.Downloads + New_Dls;
		UserRec.Uploads := UserRec.Uploads + New_Uls;
		Writev( Temp, UserRec.UpLoads );
		Write_Six( 62,2,Blk,Redd, Temp );
		Writev( Temp, UserRec.DownLoads );
		Write_Six( 75,2,Blk,Grn, Temp );
	End;

	Procedure Lower_C( Var Ch:Char );
	Begin
		If ( Ch In ['A'..'Z'] ) Then Ch := Chr( Ord(Ch) + 32 );
	End;

	Procedure Lower_Case( Var S: String );
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

	Procedure Con_Red;
	Begin
		If ( Rez <> 2 ) Then Begin
			Put_Console( Chr( 27 ) );
			Put_Console( 'b' );
			Put_Console( '1' );
		End;
	End;

	Procedure Con_Green;
	Begin
		If ( Rez <> 2 ) Then Begin
			Put_Console( Chr( 27 ) );
			Put_Console( 'b' );
			Put_Console( '2' );
		End;
	End;

	Procedure Con_Black;
	Begin
		If ( Rez <> 2 ) Then Begin
			Put_Console( Chr( 27 ) );
			Put_Console( 'b' );
			Put_Console( '3' );
		End;
	End;

	Procedure Con_Inverse_On;
	Begin
		Put_Console( Chr( 27 ) );  Put_Console( 'p' );
	End;

	Procedure Con_Inverse_Off;
	Begin
		Put_Console( Chr( 27 ) );  Put_Console( 'q' );
	End;

	Procedure Esc_Red;
	Begin
		Con_Red;
		If ( Not Local ) Then Begin
			Put_Modem( Chr( 27 ) );
			Put_Modem( 'b' );
			Put_Modem( '1' );
		End;
	End;

	Procedure Esc_Green;
	Begin
		Con_Green;
		If ( Not Local ) Then Begin
			Put_Modem( Chr( 27 ) );
			Put_Modem( 'b' );
			Put_Modem( '2' );
		End;
	End;

	Procedure Esc_Black;
	Begin
		Con_Black;
		If ( Not Local ) Then Begin
			Put_Modem( Chr( 27 ) );
			Put_Modem( 'b' );
			Put_Modem( '3' );
		End;
	End;

	Procedure Esc_Inverse_On;
	Begin
		Con_Inverse_On;
		If ( Not Local ) Then Begin
			Put_Modem( Chr( 27 ) );
			Put_Modem( 'p' );
		End;
	End;

	Procedure Esc_Inverse_Off;
	Begin
		Con_Inverse_Off;
		If ( Not Local ) Then Begin
			Put_Modem( Chr( 27 ) );
			Put_Modem( 'q' );
		End;
	End;

	Procedure AnC_Red;
	Begin
		Con_Red;
		If ( Not Local ) Then Begin
			Put_Modem( Chr( 27 ) );
			Put_Modem( '[' );
			Put_Modem( '3' );
			Put_Modem( '1' );
			Put_Modem( 'm' );
		End;
	End;

	Procedure AnC_Green;
	Begin
		Con_Green;
		If ( Not Local ) Then Begin
			Put_Modem( Chr( 27 ) );
			Put_Modem( '[' );
			Put_Modem( '3' );
			Put_Modem( '2' );
			Put_Modem( 'm' );
		End;
	End;

	Procedure AnC_Black;
	Begin
		Con_Black;
		If ( Not Local ) Then Begin
			Put_Modem( Chr( 27 ) );
			Put_Modem( '[' );
			Put_Modem( '3' );
			Put_Modem( '0' );
			Put_Modem( 'm' );
		End;
	End;

	Procedure AnC_InVerse_On;
	Begin
		Con_Inverse_On;
		If ( Not Local ) Then Begin
			Put_Modem( Chr( 27 ) );
			Put_Modem( '[' );
			Put_Modem( '7' );
			Put_Modem( 'm' );
		End;
	End;

	Procedure AnC_InVerse_Off;
	Begin
		Con_Inverse_Off;
		If ( Not Local ) Then Begin
			Put_Modem( Chr( 27 ) );
			Put_Modem( '[' );
			Put_Modem( '0' );
			Put_Modem( 'm' );
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
				If ( Length( S ) >I ) Then C := S[I+1];
				If (Ch='\') and ( C In [ 'r','g','b','i','o' ] ) Then Begin
					If ( V_Color ) Then Begin
						If C='r' Then Esc_Red
						Else If C='g' Then Esc_Green
						Else If C='b' Then Esc_Black
						Else If C='i' Then Esc_Inverse_On
						Else If C='o' Then Esc_Inverse_Off;
						I := I + 1;
					End
					Else If ( A_Color ) Then Begin
						If C='r' Then AnC_Red
						Else If C='g' Then AnC_Green
						Else If C='b' Then AnC_Black
						Else If C='i' Then AnC_Inverse_On
						Else If C='o' Then AnC_Inverse_Off;
						I := I + 1;
					End
					Else If ( V_Color=False ) Then I := I + 1;
				End
				Else Begin
					Put_Console( Ch );
					If ( Not Local ) Then Put_Modem( Ch );
				End;
				X := Scan_Input;
				If ( X = CtrlC ) Then I := Length( S )
				Else If ( X = CtrlS ) Then Begin
					Repeat
						X := Scan_Input;
					Until ( X = CtrlS ) or ( X = CtrlQ ) or ( Carrier = False );
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
		Chat := True; Write_Six( 45,2,Blk,Wht,'         ' );
		CrLf; EchoSE( 'SysOp Entering Chat Mode...' );  CrLf;  CrLf;
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
		Until ( Fnct_Key=F5 ) or ( Carrier=False );
		Fnct_Key := 0;
		CrLf; EchoSE( 'You Now Have Control...' ); CrLf; CrLf;
		Chat := False; { Maxtime := Get_Timer + 36200; }
	End;

	Procedure Show_Wrong;
	Begin
		EchoSE( 'Wrong Key Try ''?'' ' );  CrLf;
	End;

	Procedure Clear_Local;
	Begin
		Put_Console( Chr( Esc ) );  Put_Console( 'H' );
		Put_Console( Chr( Esc ) );  Put_Console( 'J' );
		Lin_Count := 0;		
	End;

	Procedure Clear_Screen;
	Begin
		Clear_Local;		
		If Carrier Then Begin
			If ( VT52 ) And ( Not Local ) Then Begin
				Put_Modem( Chr( Esc ) );  Put_Modem( 'H' );
				Put_Modem( Chr( Esc ) );  Put_Modem( 'J' );
			End;
			If ( VT52 = False ) And ( Not Local ) Then Put_Modem( Chr( 12 ) );
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

	Procedure Show_Cur_Time;
	Var
		X, H, M, S : Integer;
		St : String[12];
	Begin
		Get_Time( H, M, S );
		Writev( St, H:2, ':' );
		If ( M < 10 ) Then St := Concat( St, '0' );
		Writev( Line, M, ':' );
		St := Concat( St, Line );
		If ( S < 10 ) Then St := Concat( St, '0' );
		Writev( Line, S );
		St := Concat( St, Line );
		Write_Six( 82,4,Blk, Wht, ST );
		Mil_Time := St;
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
		S := ( Time & 31 );
		If H=0 Then H := 12;
		If H>12 Then Begin
			H := H - 12;
			Pm := 'pm';
		End;
		Writev( Line, H, ':' );
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
		M := Shr( M, 5 );
		D := ( Date & 31 );
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
		Get_Date;		
		Writev( Line,Month[M], D:2, ', ', Y );
		Write_Six( 93,4,Blk, Wht, Line );
	End;

	Procedure Show_40( Var S: String );
	Var
		I, X : Integer;
	Begin
		X := 0;
		For I := 1 to Length( S ) Do If ( S[I]='\' ) Then X := X + 1;
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
		Maxtime := ( Get_Timer + 36200 );  I := TimeOut;  Sec2 := False;
		Repeat
			Get_TimeLeft;
			If ( Timeleft < 1 ) Then Begin  UsedUp_Time;  I := Timeout;  End
			Else Begin
				Seconds := ( MaxTime-Get_Timer ) Div 200;
				If ( Seconds = 30 ) And ( Sec2=False ) Then Begin
					CrLf; CrLf; EchoSE( '\r<<30 Seconds (Bells) Till Auto-Logoff>>\b' );
					CrLf; Sec2:=True;
				End;
				If ( Seconds <= 30 ) Then Bell( 190 );
				Show_Secs_Left;  Show_Cur_Time;  Show_Connected;  I := Scan_Input;
			End;
		Until ( I>Timeout ) Or ( Carrier=False ) Or ( Get_Timer>Maxtime );
		If ( Get_Timer>MaxTime ) or ( Seconds=0 ) Then Disconnect;
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
		Until ( I=Cr ) or ( X=Lgth ) or ( Carrier=False );
	End;

	Function Yes_No( Md : Char ) : Boolean;
	Var
		Ch : Char;
		K : Integer;
	Begin
		Yes_No := False;
		If ( Md='Y' ) Then EchoS( '( \gY\b/n ) ' )  Else EchoS( '( y/\gN\b ) ' );
		Repeat
			Ch := Get_Char;  Upper_C( Ch );  K := Ord( Ch );
		Until ( Ch='Y' ) or ( Ch='N' ) or ( K=Cr ) or ( Carrier=False );
		If ( Ch='Y' ) or ( ( Md='Y' ) And ( K=Cr ) ) Then Begin
			EchoSE( 'Yes' );
			Yes_No := True;
		End
		Else EchoSE( 'No' );
	End;

	Function Get_Number( Num: Integer ): Integer;
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
				Until ( Ch In['0'..'9'] ) or ( Ord(Ch) = Cr ) or ( Carrier=False );
				If Ch In['0'..'9'] Then Begin
					NS := Concat( NS, Ch );  EchoS( Ch );
				End;
			Until ( Length( NS ) = Ln ) or ( Ord(Ch) = Cr ) or ( Carrier=False );
			If Length( NS ) >0 Then Begin
				Readv( NS, I );
				If ( I>Num ) Then Begin
					For X := 1 to ( Length( NS ) ) Do Back_Space;  NS := '';
				End;
			End
			Else I := Timeout;
		Until ( I<=Num ) or ( Carrier=False );
		Get_Number := I;
	End;

	Procedure Press_Any;
	Var
		Ch : Char;
	Begin
		CrLf;
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
		S := Concat( S, Chr( Cr ) , Chr( Lf ) );
		X := Length( S );
		For I := 1 to X Do Blkio[I] := Ord( S[I] );
		I := BlockWrite( Hndl, X, Blkio );
	End;

	Function Exists( Filename: String ):Boolean;
	Var
		Junkfile : Text;
	Begin
		Reset( Junkfile, Filename );
		If ( Io_result = 0 ) Then Result := True  Else Result := False;
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
		If Exists( S ) Then H := FOpen( S, Update_Mode )  Else H := FCreate( S, 0 );
		X := Fseek( 0, H, 2 );
		For I := 1 to Num Do Write_Ln( H, DescL[I] );
		I := Close_File( H );
	End;

	Procedure Show_File( Var F : String );
	Var
		I : Integer;
		Ch : Char;
	Begin
		Lower_Case( F );
		Line := F;
		AddSpaces( Line, 40 );
		Write_Six( 7,4, Blk,Wht, Line );
	End;

	Function F_Search( X : Integer ):Integer;
	Var
		A, I, T : Integer;
		C : CString;
	Begin
		MakeCString ( FPath, C );  T := FCnt;
		If ( FCnt=0 ) Then Begin I := SFirst( C, 0 ); FCnt := 1; End
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
			Log( 3 );
		End;
	End;

	Procedure Show_Error( P:String; Error: Integer );
	Var
		Temp,Desc: String;
	Begin
		If Error <> 0 Then Begin
			Error := Abs( Error );
			Writev( Temp, '-', Error );
			If Error >70 Then Error := 70;
			Desc := Err[Error];
			DescL[1] := ' ';
			DescL[2] := Concat( 'System Error: ', Temp );
			DescL[3] := Concat( '    Filename: ', P );
			DescL[4] := Concat( ' Description: ', Desc );
			Log( 4 );
			EchoSE( DescL[1] );
			EchoSE( DescL[2] );
			EchoSE( DescL[3] );
			EchoSE( DescL[4] );
			CrLf;
		End;
	End;

	Procedure Change_Drv_Path( Var S: Str60 );
	Var
		L,I,X : Integer;
		C_Pth : CString;
		P_Pth : String;
	Begin
		F_Name := S;
		L := Length( S );
		Show_File( F_Name );
		Drv := ord( S[1] ) - 65;
		If ( ( Drv>=0 ) And ( Drv<16 ) ) And ( L>2 ) Then Begin
			For X := 0 to 79 Do C_Pth[X] := Chr( 0 );
			X := 0;
			L := L - 3;
			I := 3;
			Loop
				Exit If ( X=L );
				C_Pth[ X ] := S[I];
				X := X + 1; I := I + 1;
			End;
			C_Pth[X] := Chr( 0 );
			Dummy_L := SetDrv( Drv );
			Dummy_I := ChDir( C_Pth );
			Show_Error( S, Dummy_I );
		End
		Else Begin
			If ( L<3 ) then Begin
				Line := Concat( 'Pathname for ', System2.TNames[Top_Sig], '>' );
				Line := Concat( Line, System2.Names[Sig_Num], ' Too Short!!!' );
				Show_Error( Line, -68 );
			End;
			If ( Drv<0 ) or ( Drv>15 ) then Begin
				Line := Concat( 'Invalid Drive In Pathname: ', S );
				Show_Error( Line, -68 );
			End;
		End;
	End;

	Procedure DT_Stamp( Var S:String );
	Var
		H, X: Integer;
		F : CString;
	Begin
		X := Get_STime;
		Blkio[1] := Shr( X, 8 );
		Blkio[2] := ( X & 255 );
		X := Get_SDate;
		Blkio[3] := Shr( X, 8 );
		Blkio[4] := ( X & 255 );
		H := Open_File( F, 0 );
		If H>0 Then Begin
			X := GSDTOF( Blkio, H, 1 );
			Show_Error( S, X );
			X := Close_File ( H );
			If X<0 Then Show_Error( S, H );
			If Sfirst( F, 0 ) = 0 Then X := 0;
			EchoSE( '  Time/Date Stamp Updated...' ); CrLf;
		End
		Else Show_Error( S, H );
	End;

	Procedure Get_Dfree( Var Fre, Tcl, Ssb, Cps : Long_Integer );
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
	Begin
		S := Concat( 'Drive: ', Chr( Drv+Ord( 'B' ) ) );
		X := DFree( FH.Buff, Drv+1 );
		Dummy_I := Int( X );  If ( Dummy_I < 0 ) Then Show_Error( S, Dummy_I );
		Fre := FH.Data[1]; { number of free clusters }
		Tcl := FH.Data[2]; { total number of clusters }
		Ssb := FH.Data[3]; { sector size in bytes }
		Cps := FH.Data[4]; { clusters per sector }
	End;

	Function Get_2nd_Reg : Boolean;
	Var
		Ok : Boolean;
		X, Days1, Days2 : Long_Integer;
		B1, B2 : Byte;
		Dom: Packed Array[1..12] Of Byte;
		M1,D1,Y1, Date, Days : Integer;
		M2,D2,Y2, Sct : Integer;
	Begin
		Dom[1] := 31;  Dom [2] := 28;  Dom [3] := 31;  Dom [4] := 30;
		Dom[5] := 31;  Dom [6] := 30;  Dom [7] := 31;  Dom [8] := 31;
		Dom[9] := 30;  Dom[10] := 31;  Dom[11] := 30;  Dom[12] := 31;
		Rwabs( 0, BlkIo, 1, 0, Boot_Drv );
		B1 := BlkIo[20];  B2 := BlkIo[21];
		Sct := ( B2 * 256 ) + B1 - 1;
		Rwabs( 0, BlkIo, 1, Sct, Boot_Drv );
		Date := ( BlkIo[1] * 256 ) + BlkIO[2];
		Convert_Date( Date );  Y := Y - 1980;  M1 := M-1; D1 := D; Y1 := Y-1;
		Line := Concat( 'FTU Started On ', Line );  EchoSE( Line );
		Get_Date;  Y := Y - 80;  M2 := M-1; D2 := D; Y2 := Y-1;
		Days1 := ( Y1 * 365 ) + D1;
		If ( M1>0 ) Then For Date := 1 To M1 Do Days1 := Days1 + Dom[Date];
		Days2 := ( Y2 * 365 ) + D2;
		If ( M2>0 ) Then For Date := 1 To M2 Do Days2 := Days2 + Dom[Date];
		If ( Days2 > Days1 ) Then Days := Int(Days2 - Days1)
		Else If ( Days1 = Days2 ) Then Days := 0
		Else Days := 31;
		WriteV( Line, 'FTU Has Been Active For \r', Days, '\b Days...' );
		EchoSE( Line ); CrLf;
		Ok := True;  M1 := BlkIo[3];
		If ( M1<>9 ) Then Begin
			If ( Days > 30 ) Then Begin
				EchoSE( 'FTU Has Been Running Now For More Than 30 Days!' );
				EchoSE( 'IT WILL NOT RUN ANYMORE UNTIL IT HAS BEEN REGISTERED!!!' );
				Ok := False;
			End;
		End;
		Press_Any;
		Get_2nd_Reg := Ok;
	End;

	Procedure Show_Dfree;
	Var
		Fre, Tcl, Ssb, Cps, Free : Long_Integer;
	Begin
		Get_DFree( Fre, Tcl, Ssb, Cps );
		Free := ( Ssb * Cps );
		Free := ( Free * Fre );
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
		H1  := FOpen( In_File, 0 );
		Siz := FSeek( 0, H1, 2 );
		X   := Close_File( H1 );
		H1  := FOpen( In_File, 0 );
		H2  := FCreate( Out_File, 0 );
		Tot := Siz;
		Repeat
			X := Close_File( H2 );
			H2 := FOpen( Out_File, 1 );
			X := FSeek( 0, H2, 2 );
			If ( Tot >= Block_Size ) Then TSiz := Block_Size  Else Tsiz := Tot;
			N := BlockRead( H1, TSiz, Blkio );
			If ( N < 0 ) Then Begin
				Show_Error( In_File, N );
				Tot := 0;
			End
			Else If ( N > 0 ) Then Begin
				X := BlockWrite( H2, TSiz, Blkio );
				If ( X < 0 ) Then Begin
					Show_Error( Out_File, X );
					Tot := 0;
				End
				Else Tot := Tot - Tsiz;
			End;
		Until ( Tot=0 );
		X := Close_File( H1 );
		X := Close_File( H2 );
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
		X : Integer;
	Begin
		X := Cps - ( Cps Div 30 );
		DL_Time := ( Dta_Data.Size Div X ); If ( DL_Time=0 ) Then DL_Time := 5;
		Get_DL_Time_Str( DL_Time );
	End;

	Procedure Show_None_Marked;
	Begin
		EchoSE( ' \rYou Do Not Have Any Files Marked Yet!\b' );  CrLf;
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
				BMark[BM_Num].BM_Fname := File_Name;
				BMark[BM_Num].BM_Fsize := Dta_Data.Size;
				BMark[BM_Num].BM_Sig := Sig_Num;
				BMark[BM_Num].BM_D_Time := DL_Time;
				Tot_DL_Time := Tot_DL_Time + DL_Time;
			End
			Else Begin
				CrLf;
				EchoSE( '\r Sorry, Maximum Files Is 20...\b' );
				Press_Any;
			End;
		End
		Else Begin
			CrLf;
			EchoSE( '\r Sorry, You Do Not Have Enough Time Left To Include This File...\b' );
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
			CrLf;  EchoSE( '\rIllegal Filename...\b' );  CrLf;
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
				Writev( Line, ' [\r', I:2, '\b]  ', Temp, BMark[I].BM_Fsize:8, '  ' );
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
		If BM_Num >0 Then Begin
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

	Procedure Find_User_Addr : Long_Integer;
	Var
		TT, T2, U, X : Long_Integer;
		S : String;
	Begin
		S := U_Handle;  Lower( S );  UserRec.UHandle := U_Handle;
		TT := Proc_addr( Dummy_Routine );  T2 := TT - FTU_Length;
		U := Addr( UserRec );
		X := Search( Prg_Offset, T2, S );
		If ( X>0 ) Then Begin
			Usr_Addr := X - 2;
			Writev( Line, 'Address Of UserData Is $', Usr_Addr:8:h );
			EchoCE( Line );
			Get_Usr( U, Usr_Addr, SizeOf( UserRec ) );
			Writev( Line, 'OffSet For FTU.HLP Is ', TT-X, ' Bytes...' );
			EchoCE( Line );
		End
		Else Begin
			Usr_Addr := 65536;
			EchoCE( 'Offset For FTU.INF Needs To Be Increased...' );
		End;
	End;

	Procedure Get_MaskData( Num : Integer );
	Var
	Ftu_Mask : Text;
		X , Count : Long_Integer;
	Begin
		Count := ( SizeOf( UserAcs ) * ( Num-1 ) );
		Reset( Ftu_Mask, ftu_maskfile );
		X := Fseek( Count, Handle( Ftu_Mask ),  0 );
		If ( X<0 ) Then Show_Error( Ftu_MaskFile, X );
		X := FRead_Usr2( Handle( Ftu_Mask ),  SizeOf( UserAcs ),  UserAcs );
		If ( X<0 ) Then Show_Error( Ftu_MaskFile, X );
		Close( Ftu_Mask );
	End;

	Procedure Save_Ftu_User;
	Var
		S1, S2, X, Count : Long_Integer;
	Begin
		S1 := SizeOf( UserAcs );
		S2 := ( Usr_No-1 );
		Count := S1 * S2;
		Reset( UsrDataFtu, Ftu_UserFile );
		X := Fseek( Count, Handle( UsrDataFtu ),  0 );
		If ( X<0 ) Then Show_Error( Ftu_UserFile, X );
		X := FWrite_Usr2( Handle( UsrDataFtu ),  SizeOf( UserAcs ),  UserAcs );
		If ( X<0 ) Then Show_Error( Ftu_UserFile, X );
		Close( UsrDataFtu );
	End;

	Procedure Get_Ftu_User;
	Var
		I, U : Integer;
		S1, S2, X, Count : Long_Integer;
	Begin
		S1 := SizeOf( UserAcs );  U := Usr_No;
		Reset( UsrDataFtu, Ftu_UserFile );
		X := Fseek( 0, Handle( UsrDataFtu ),  2 );
		If ( X<0 ) Then Show_Error( Ftu_UserFile, X );
		I := ( X Div S1 );
		If ( UserRec.New_User ) Then U := I;
		S2 := ( U-1 );  Count := S1 * S2;
		X := Fseek( Count, Handle( UsrDataFtu ),  0 );
		If ( X<0 ) Then Show_Error( Ftu_UserFile, X );
		X := FRead_Usr2( Handle( UsrDataFtu ),  S1, UserAcs );
		If ( X<0 ) Then Show_Error( Ftu_UserFile, X );
		Close( UsrDataFtu );
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
		If Exists( FtuData ) Then Begin
			Reset( Sigdatafile, FtuData );
			Count := Fseek( 0, Handle( SigdataFile ),  0 );
			If ( Count<0 ) Then Show_Error( FtuData, Count );
			Count := FRead_Sys2( handle( sigdatafile ),  sizeof( system2 ),  System2 );
			If ( Count<0 ) Then Show_Error( FtuData, Count );
			Close( Sigdatafile );
			Userfilename := System2.Userlog;
			Log_Filename := System2.Logfile;
			Numsigs := System2.TSigcount;
		End
		Else Begin
			CrLf;
			EchoSE( '\r\iUnable To Open FTU_DATA.SIG file....\o\b' );
			EchoSE( 'Returning To The BBS.' );
			CrLf;
		End;
	End;

	Procedure Show_SigOp_Stats;
	Begin
		If ( Sig2_Edit [ Sig_Num ]=1 ) Then Write_Six( 18,3,Blk,Redd, '-E' )
			Else Write_Six( 18,3,Blk,Redd, '  ' );
		If ( Sig2_Valid[ Sig_Num ]=1 ) Then Write_Six( 20,3,Blk,Redd, '-V' )
			Else Write_Six( 20,3,Blk,Redd, '  ' );
		If ( Sig2_Kill [ Sig_Num ]=1 ) Then Write_Six( 22,3,Blk,Redd, '-K' )
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

	Procedure Show_UInfo;
	Var X : Long_Integer;
	Begin
		Temp := UserRec.Name; AddSpaces( Temp,31 );
		Write_Six( 1,0,Blk,Redd,  Temp );
		Temp := UserRec.Computer_Type; AddSpaces( Temp,15 );
		Write_Six( 40,0,Blk,Redd, Temp );
		Temp := UserRec.Last_Call_Date;
		Convert_Date2( Temp );
		Y := Y - 1980;
 		M := Shl( M, 5 );
 		Y := Shl( Y, 9 );
		Usr_Lst_Call := Y + M + (D-1);
		Write_Six( 67,0,Blk,Redd, Temp );
		Writev( Temp, Usr_No );
		Write_Six( 100,0,Blk,Wht, Temp );

		Temp := UserRec.UHandle; AddSpaces( Temp,31 );
		Write_Six( 1,1,Blk,Grn,   Temp );
		Writev( Temp, UserRec.Age );
		Write_Six( 40,1,Blk,Grn,  Temp );

		If ( UserRec.New_User ) Then Temp := 'New User'
			Else Temp := 'Validated';
		Write_Six( 44,1,Blk,Wht, Temp );

		Write_Six( 67,1,Blk,Redd, '0/0    ' );
		Write_Six( 77,1,Blk,Wht,  '180' );

		Temp := Concat( UserRec.City,', ', UserRec.State ); Addspaces( Temp, 24 );
		Write_Six( 1,2,Blk,Wht,   Temp );
		If ( Chat ) Then Temp := 'On ' Else Temp := 'Off';
		Write_Six( 40,2,Blk,Grn,  Temp );

		Temp := UserRec.Phone_Number; AddSpaces( Temp, 16 );
		Write_Six( 1,3,Blk,Wht,   Temp );
		Write_Six( 40,3,Blk,Redd, BaudRate );

		Show_Cur_Time;
		Show_Cur_Date;
		Show_Connected;
		X := Malloc( -1 ); Writev( Temp, X );
		Write_Six( 86,0,Blk,Redd,Temp );

		If ( Local ) Then Temp := 'Local'  Else Temp := 'Remote';
		Write_Six( 48,3,Blk,Redd, Temp );
		If ( Usr_No = 1 ) Then Temp := 'SysOp'
		Else If ( Sig_Op ) Then Temp := 'SigOp'
		Else Temp := 'User';
		Write_Six( 56,3,Blk,Redd, Temp );
		Temp := Concat( 'Video Width: ', Width );
		Write_Six( 64,3,Blk,Redd, Temp );
	End;

	Function Exec_Xyz : Integer;
	Var
		H, I, X : Integer;
		L : Long_Integer;
		C, E : CString;
		Temp, S : String;
	Begin
		Save5;
		Cmd_Line := Concat ( Cmd_Line,' -s -t -c -r150' );

		If ( Batch_Down ) Then Begin
			EchoCE( '    Sending Files:' );
			For I := 1 to BM_Num Do Begin
				Temp :=BMark[ I ].BM_Fname;
				X := BMark[ I ].BM_Sig;
				S := Concat( System2.Paths[ X ], Temp );
				MesgL[ I ] := S;  EchoCE( S );
			End;
			S := 'C:\FTU.OUT';
			Cmd_Line := Concat ( Cmd_Line, ' -i', S );
			H := FCreate( S, 0 ); L := Fseek( 0, H, 2 );
			For I := 1 to BM_Num Do Write_Ln( H, MesgL[I] );
			I := Close_File( H );
		End
		Else If ( Batch_Upld=False ) Then Cmd_Line := Concat( Cmd_Line, ' ', File_Name );
		Cmd_Line := Concat( Cmd_Line, ' -oC:\FTU.XFR', Chr(0) );

		Temp := Concat( Xfer_Type, ' Ready, Start Transfer Now...' );
		CrLf;  EchoSE( Temp );
		For I := 1 To Length( Cmd_Line ) Do C[I] := Cmd_Line[I];

		C[0] := Chr( Length( Cmd_Line ) );
		For I := 0 to 27 Do E[I] := Chr( 0 );

		Clear_Local;  EchoCE( Cmd_Line );  CrLf;
		I := Exec( 0, Xyz_Path, C, E );
		Exec_Xyz := I;
		Rest5;
		Show_Top5;
		Show_DL_UL;
		Clear_Local;
		If ( I<>0 ) Then Show_Xyz_Error( I );
		CrLf;
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
		Desc_Path := Concat( System2.Paths[ Sig_Num ], 'DESC\', File_Name );
		MakeCstring( Desc_Path, Desc_Path_C );
		Hide_Mode := False;
		X := Dta_Data.Attribute & 1;
		If ( X=0 ) Then Hide_Mode := True;
	End;

	Procedure Get_Sig_Access;
	Var
		I, I1, I2, X, Count : Integer;
		FSig_A, FSig_U, FSig_V, FSig_E, FSig_K : Long_Integer;
	Begin
		For I := 1 to 32 Do  Sig_Access[I] := 0;
		For I := 0 to 1023 Do Sig2_Access[I] := 0;
		Count := 1; X := 0;
		FSig_A := UserAcs.TSig_Accs;
		Repeat
			Line := System2.TNames[ X+1 ];
			If ( Length( Line ) >0 ) Then Begin
				If Bit_Test( FSig_A, X ) Then Begin
					Sig_Access[ Count ] := X + 1;
					Count := Count + 1;
				End;
			End;
			X := X + 1;
		Until ( X=32 );
		Max_Sig := Count - 1;
		For I := 0 to Max_Sig Do Begin
			Count := 0; X := 0; I2 := I * 32; I1 := I + 1;
			FSig_A := UserAcs.Sig_Accs [ I1 ];
			FSig_U := UserAcs.User_Mask[ I1 ];
			FSig_V := UserAcs.Sig_Valid[ I1 ];
			FSig_E := UserAcs.Sig_Edit [ I1 ];
			FSig_K := UserAcs.Sig_Kill [ I1 ];
			Repeat
				Line := System2.Names[ I2 + X ];
				If ( Length( Line ) >0 ) Then Begin
					If ( Bit_Test( FSig_U, X ) ) And ( Bit_Test( FSig_A, X ) ) Then Begin
						Sig2_Access[ I2 + Count ] := ( I2 + X );
						If Bit_Test( FSig_V, X ) Then Sig2_Valid[ I2 + X ] := 1;
						If Bit_Test( FSig_E, X ) Then Sig2_Edit [ I2 + X ] := 1;
						If Bit_Test( FSig_K, X ) Then Sig2_Kill [ I2 + X ] := 1;
						Count := Count + 1;
					End;
				End;
				X := X + 1;
			Until ( X=32 );
		End;
	End;

	Procedure Show_Top_Sigs;
	Var
		X,X1,I : Integer;
		Temp : String;
	Begin
		If ( Max_Sig>0 ) Then Begin
			X := 0; I := 0; Clear_Screen; CrLf;
			EchoSE( '  Topic Sigs Available:' ); CrLf;
			Repeat
				I := I + 1; X1 := Sig_Access[I];
				Writev( Temp, '[\r', I, '\b] ', System2.TNames[X1] );
				If ( I<10 ) Then Temp := Concat( ' ', Temp );
				If ( WidT=80 ) Then Addspaces( Temp ,43 );
				X := X + 1;
				If ( Odd( X ) And ( WidT=80 ) ) Then EchoS( Temp ) Else EchoSE( Temp );
			Until ( I=Max_Sig ) or ( Carrier=False );
			If Odd( X ) Then CrLf;
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
		EchoSE( 'Show Sigs' );  Clear_Screen;  CrLf;
		Temp := Concat( 'File Sigs Available In ', System2.TNames[Top_Sig] );
		EchoSE( Temp );  CrLf;
		X := 0;  I := ( Top_Sig-1 ) * 32;
		If ( Max_Sub>0 ) And ( T<>0 ) Then Begin
			Repeat
				X := X + 1;  X1 := Sig2_Access [ I ];
				Writev( Temp, '[\r', X, '\b] ', System2.Names[X1] );
				If X<10 Then Temp := Concat( ' ', Temp );
				If WidT=80 Then Addspaces( Temp ,43 );
				If ( Odd( X ) And ( WidT=80 ) ) Then EchoS( Temp )  Else EchoSE( Temp );
				I := I + 1;
			Until ( X=Max_Sub ) or ( Carrier=False );
			If Odd( X ) Then CrLf;
		End
		Else EchoSE( ' You Don''t Have Access Here!' );
		CrLf;
	End;

	Procedure Get_Sig_Nums;
	Var
		I, X, Num : Integer;
		F : Long_Integer;
	Begin
		Top_Sig := Sig_Access [ Top_Cntr ];
		I := ( Top_Sig - 1 ) * 32;
		Num := I + ( Sig_Cntr - 1 ); If ( Num<0 ) Then Num := 0;
		Sig_Num   := Sig2_Access       [ Num ];
		Use_Desc  := System2.Use_Desc  [ Sig_Num ];
		Show_Free := System2.Show_Free [ Sig_Num ];
		Max_Avail := System2.Sigcount  [ Top_Sig - 1 ];
		F := UserAcs.User_Mask[Top_Sig];
		Max_Sub := 0;
		For X := 0 to 31 Do
			If ( Bit_Test( F, X ) ) And ( System2.Names[ X+I ] <> '' ) Then
				Max_Sub := Max_Sub + 1;
		Sig_Op := False;  Sig_Ops := False;
		F := UserRec.Sec_Lvl;
		If ( Bit_Test( F, 30 ) ) Then Sig_Ops := True;
		If ( Sig2_Valid[Sig_Num]=1 ) or ( Sig2_Edit[Sig_Num]=1 )
			or ( Sig2_Kill[Sig_Num]=1 ) Then Sig_Op := True;
		Show_SigOp_Stats;
	End;

	Procedure Change_Topic( Md: Integer );
	Var
		X1, X, Y, T, Num : Integer;
		Choice : Char;
	Begin
		T := Top_Cntr;
		EchoS ( 'Enter Topic Sig# or ''?'' For List -> ' );
		Choice := Get_Char;
		If ( Choice = '?' ) Then Begin
			Show_Top_Sigs;
			If ( Md=0 ) Then EchoS( ' Enter Topic Sig# -> ' )
			Else EchoS( ' Select Topic Sig To Copy File To :> ' );
			Choice := Get_Char;
		End;
		If Choice In['1'..'9'] Then Begin
			Put_Char( Choice ); X := Ord( Choice ) - 48; Y := 16;
			If Max_Sig >= ( X * 10 ) Then Begin
				Choice := Get_Char;
				If Choice In['0'..'9'] Then Put_Char( Choice );
				If Ord( Choice ) <> 13 Then Begin
					Y := Ord( Choice ) - 48; If Y = 10 Then Y := 0;
				End;
			End;
			If ( X <= Max_Sig ) And ( Y = 16 ) Then Top_Cntr := X
			Else Begin
					X := ( X * 10 ) + Y;
					If ( X <= Max_Sig ) Then Top_Cntr := X;
				End;
			CrLf;
		End;
		Sig_Cntr := 1; Get_Sig_Nums;
		Change_Drv_Path( System2.Paths[Sig_Num] );
		CrLf;
	End;

	Procedure Change_Sig;
	Var  T,S : Integer;
	Begin
		T := Top_Cntr;  S := Sig_Cntr;
		Repeat
			Tot_Sig := False;  Sig_Cntr := Sig_Cntr +1;
			If Sig_Cntr > Max_Sub Then Begin
				Sig_Cntr := 1;  Top_Cntr := Top_Cntr + 1;
				If Top_Cntr > Max_Sig Then Begin
					Top_Cntr := Max_Sig;  Tot_Sig := True;
				End;
			End;
			Get_Sig_Nums;
		Until ( Max_Sub>0 ) or ( Tot_Sig ) or ( Carrier=False );
		If ( Tot_Sig ) And ( Max_Sub=0 ) Then Begin
			Top_Cntr := T; Sig_Cntr := S; Get_Sig_Nums;
		End
		Else Change_Drv_Path( System2.Paths[Sig_Num] );
		CrLf;
	End;

	Procedure Show_DL_Stats;
	Var
		DL_More, DL_Check : Long_Integer;
	Begin
		DL_Check := ( UserRec.Uploads * UserRec.DL_Ratio );
		DL_More := DL_Check - UserRec.Downloads;
		CrLf;  CrLf;
		Writev( Line, ' \rDownloads\b    : ', UserRec.Downloads );
		EchoSE( Line );
		Writev( Line, ' \rUploads\b      : ', UserRec.Uploads );
		EchoSE( Line );
		Writev( Line, ' \rUL/DL Ratio\b  : ', UserRec.Dl_ratio, ':1' );
		EchoSE( Line );
		CrLf;  Line := '';
		If ( DL_More < 1 ) Then
			EchoSE( '\r\i You Have Exceeded Your Download Limit!\o\b' )
		Else Writev( Line, ' You Can Download ( \r\i', DL_More, '\o\b ) More Files Before Uploading...' );
		EchoSE( Line );
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
		CrLf; EchoS( 'Paging SysOp ' );
		Repeat
			I := I + 1; EchoS( '*' ); Bell( 30 );
			If ( Con_In ) Then Begin
				X := Get_Console;
				Done := True;
			End;
		Until ( Done ) or ( I=25 ) or ( Carrier=False );
		If I=25 then Begin
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
		X : Integer;
		DscFile : Text;
	Begin
		For X := 1 to Cnt Do MesgL[X] := '';  Msg_Ln := 0;
		If ( Use_Desc ) Then Begin
			Show_File( Desc_Path );
			If Exists( Desc_Path ) Then Begin
				Reset( DscFile, Desc_Path );
				X := 0;
				Repeat
					X := X + 1;  ReadLn( DscFile, MesgL[X] );
				Until ( Eof( DscFile ) ) or ( X=Cnt ) or ( Carrier=False );
				Close( DscFile );
				Msg_Ln := X;
			End;
		End;
		If ( Msg_Ln = 0 ) Then Begin
			MesgL[4] := 'No Description';
			Msg_Ln := 4;
		End;
		If ( MesgL[1] ='' ) Then MesgL[1] := 'SysOp';
		If ( MesgL[2] ='' ) Then MesgL[2] := '0';
		If ( MesgL[3] ='' ) Then MesgL[3] := 'Not Tested...';
	End;

	Function Get_FTU_XFR : Integer;
	Var
		X : Integer;
		Xfr_File : Text;
		S : String;
	Begin
		S := 'C:\FTU.XFR';
		For X := 1 To 20 Do MesgL[X] := ''; Show_File( S );
		If Exists( S ) Then Begin
			Reset( Xfr_File, S );
			X := 0;
			Repeat
				X := X + 1;
				ReadLn( Xfr_File, MesgL[X] );
			Until ( Eof( Xfr_File ) ) or ( Carrier=False );
			Close( Xfr_File );  X := X - 1;
		End;
		Get_Ftu_Xfr := X;
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
		EOF := False;  Abort := False;
		S := '';  KyCnt := 0;
		Show_File( F_Name );
		MakeCString( F_Name, F );
		H := Open_File( F, Input_Mode );
		If H < 0 then EOF := True
		Else Repeat
			Tbytes := BlockRead( H, Block_Size, BlkIO );
			If ( Tbytes>0 ) and ( Abort=False ) Then Begin
				For I := 1 to Tbytes do begin
					X := Blkio[I];
					If ( X > 31 ) And ( X < 128 ) And ( Length ( S ) < 78 ) Then Begin
						S := Concat( S, Chr( X ) );  KyCnt := KyCnt + 1;
						If X=32 Then S := '';
						If ( KyCnt >= WidT-2 ) And ( Length ( S ) > 0 ) Then Begin
							For X := 1 to Length( S ) Do Back_Space;
							CrLf;  KyCnt := 0;  EchoS( S );  S := '';
							If ( Abort ) Then I := Tbytes;
						End
						Else EchoS( Chr( X ) );
					End
					Else If ( X=Cr ) or ( X=155 ) Then Begin CrLf;	KyCnt := 0; End;
				End;
			End
			Else EOF := True;
		Until ( EOF ) or ( Abort ) or ( Carrier=False );
		RC := Close_File( H );
		Abort := False;
		Press_Any;
	End;

	Procedure Enter_Line( Var S:String; Var Word:String; Var Ch:Char;
		Var KyCnt:Integer; Var Wrap:Boolean; Temp:String );
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
		If ( Temp <> S ) Then Begin
			S:=Temp; KyCnt:=Length( S ); WrdCnt:=KyCnt;
		End;
		EchoS( '\r' );
		EchoS( Prompt );
		EchoS( '\b' );
		EchoS( S );
		Repeat
		200:
			Ch := Get_Char;  Cc := Ord( Ch );
			If ( Cc=Bksp ) And ( KyCnt>0 ) Then Begin
				Back_Space;
				KyCnt := KyCnt -1;
				If WrdCnt>1 Then WrdCnt := WrdCnt -1;
				S[0] := Chr( KyCnt );
				Word[0] := Chr( WrdCnt );
			End
			Else If CC>31 Then Begin
				EchoS( Ch );
				S := Concat( S, Ch );
				Word := Concat( Word, Ch );
				KyCnt := KyCnt + 1;
				WrdCnt:= WrdCnt + 1;
				If Ch=' ' Then Begin WrdCnt := 0; Word:= ''; End;
				If ( KyCnt=WidT-2 ) And ( WrdCnt<>KyCnt ) And ( WW_Toggle ) Then Begin
					For I := 1 To Length( Word ) Do Back_Space;
					S[0] := Chr( KyCnt-WrdCnt );
					Wrap := True;
				End
				Else If ( KyCnt=WidT-2 ) And ( WrdCnt=KyCnt ) And ( WW_Toggle ) Then CC := Cr
				Else If ( KyCnt=WidT-1 ) And ( WW_Toggle=False ) Then Begin
					Back_Space;
					KyCnt:=KyCnt-1;
					Goto 200;
				End;
			End
		Until ( ( Ch='/' ) And ( KyCnt=1 ) ) or ( CC=Cr ) or ( Wrap ) or ( Carrier=False );
		If Ch='/' Then Begin
			Back_Space;  Back_Space;
			EchoS( '\r(E>\b ' );
			Ch := Get_Char;  Upper_C( Ch );
		End;
	End;

	Procedure Save_Description;
	Var
		H, X : Integer;
	Begin
		H := FCreate( Desc_Path, 0 );
		If H<0 Then Show_Error( Desc_Path, H );
		For X := 1 to Msg_Ln Do Write_Ln( H, MesgL[X] );
		X := Close_File( H );
		CrLf;
	End;

	Procedure Frmt_List;
	Var I:Integer;
	Begin
		Clear_Screen;
		For I:=1 to Msg_Ln Do EchoSE( MesgL[I] );
	End;

	Procedure Delete_Desc_Line;
	Var
		I,X,Strt,Lst:Integer;
	Begin
		EchoS( 'Delete ( 1-' );
		Writev( Line,Msg_Ln );
		EchoS( Line );
		EchoS( ' ) From [1]: ' );
		I := Get_Number( Msg_Ln );
		If I <> 0 Then Begin
			If I = -1 Then Begin Strt := 1; EchoS( '1' ); End
			Else Strt := I;
			EchoS( ' To [' );
			Writev( Line,Strt );
			EchoS( Line );
			EchoS( ']: ' );
			I := Get_Number( Msg_Ln );
			If I = -1 Then Begin Lst := Strt; Writev( Line, Lst ); EchoS( Line ); End
			Else Lst := I;
			X:=Lst-( Strt-1 );  { Total # of Lines...}
			For I:=Strt to Msg_Ln Do MesgL[I] := MesgL[I+X];
			Msg_Ln := Msg_Ln - X;
		End;
		CrLf;
	End;

	Procedure List_Desc_Line( Md:Integer );
	Var
		I,Strt,Lst:Integer;
		Temp : String;
	Begin
		Strt := 1;
		Lst := Msg_Ln;
		EchoS( 'List ( 1-' );
		Writev( Line,Msg_Ln );
		EchoS( Line );
		EchoS( ' ) From [1]: ' );
		I := Get_Number( Msg_Ln );
		If I <> 0 Then Begin
			If I = -1 Then Begin Strt := 1; EchoS( '1' ); End
			Else Strt := I;
			EchoS( ' To [' );
			Writev( Line,Msg_Ln );
			EchoS( Line );
			EchoS( ']: ' );
			I := Get_Number( Msg_Ln );
			If I = -1 Then Begin Lst := Msg_Ln; Writev( Line, Lst ); EchoS( Line ); End
			Else Lst := I;
			CrLf;
			For I:=Strt to Lst Do Begin
				If Md=2 Then Writev( Temp,I:2, ': ', MesgL[I] )
					Else Temp := MesgL[I];
				If Ord( Temp[0] ) >= 79 Then Temp[0] := Chr( 79 );
				EchoSE( Temp );
			End;
		End;
	End;

	Procedure Insert_Line;
	Var
		I, X, Strt, Lst : Integer;
		Temp : String;
	Begin
		EchoS( 'Insert Before ( 1-' );
		Writev( Line,Msg_Ln );
		EchoS( Line );
		EchoS( ' ) Line [' );
		Writev( Line,Msg_Ln );
		EchoS( Line );
		EchoS( ']: ' );
		X := Get_Number( Msg_Ln );
		If ( X>0 ) And ( X<=Msg_Ln ) Then Begin
			Strt := X +1;
			Lst := Msg_Ln +1;
			For I := Lst Downto Strt Do MesgL[I] := MesgL[I-1];
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
		EchoS( 'Edit Which Line ( 1-' );
		Writev( Line,Msg_Ln );
		EchoS( Line );
		EchoS( ' ) ?' );
		I := Get_Number( Msg_Ln );
		If ( I<>0 ) And ( I<=Msg_Ln ) Then Begin
			If ( I<>-1 ) And ( I<>-2 ) Then Begin
				CrLf;
				OldL := MesgL[I];
				EchoSE( ' Old Line Reads:' );
				Writev( Line,'- ',OldL );
				EchoSE( Line );
				EchoS( '+ ' );
				Caps := False;
				Line_In( Temp, 78 );
				MesgL[I] := Temp;
			End
			Else EchoSE( 'Line Unchanged...' );
		End
		Else EchoSE( 'Line Unchanged...' );
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
			Temp := MesgL[X];
			Ok:=True;
			For I := 1 To Length( Temp ) Do If Temp[I]<>' ' Then Ok:=False;
			If ( Temp='' ) or ( Ok ) Then Begin
				For I:=X to Msg_Ln Do MesgL[I] := MesgL[I+1];
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
		If WidT=40 Then EchoSE( '\r ----\b+\r----\g1\r----\b+\r----\g2\r----\b+\r----\g3\r----\b+\r---\b' )
		Else Begin
			EchoS ( '\r ' );
			EchoS ( '----\b+\r----\g1\r----\b+\r----\g2\r----\b+\r----\g3\r----\b+\r----\g4\r' );
			EchoSE( '----\b+\r----\g5\r----\b+\r----\g6\r----\b+\r----\g7\r----\b+\r---\b' );
		End;
	End;

	Procedure Show_Desc_Help;
	Var S : String;
	Begin
		New_Line := False;
		Clear_Screen;
		CrLf; EchoSE( ' Mesage Editor Commands:' ); CrLf;

		S := '[\rA\b] Abort This Message';             Show_40( S );
		S := '[\rB\b] Begin Over Again';               Show_40( S );
		S := '[\rC\b] Display Column Bar';             Show_40( S );
		S := '[\rD\b] Delete Line(s)';                 Show_40( S );
		S := '[\rE\b] Edit A Line';                    Show_40( S );
		S := '[\rF\b] Formatted List';                 Show_40( S );
		S := '[\rI\b] Insert A Line';                  Show_40( S );
		S := '[\rL\b] List Lines (No numbers)';        Show_40( S );
		S := '[\rN\b] Line Lines (With Numbers)';      Show_40( S );
		S := '[\rP\b] Pack (Remove All Blank Lines)';  Show_40( S );
		S := '[\rR\b] Repeat Last Line';               Show_40( S );
		S := '[\rS\b] Save Message';                   Show_40( S );
		S := '[\rU\b] Save Message (Unformatted)';     Show_40( S );
		S := '[\rV\b] Video Width Change';             Show_40( S );
		S := '[\rW\b] Word Wrap Toggle (On/Off)';      Show_40( S );
		S := '[\rY\b] Change Your Prompt Char';        Show_40( S );
		S := '[\r/\b] Clear The Screen';               Show_40( S );
		S := '[\r?\b] This Help Screen';               Show_40( S );
		CrLf;
		EchoSE( 'Precede These Comnds with a Forward Slash "\r/\b" ' );
		CrLf;
	End;

	Procedure Show_Line_Status;
	Begin
		CrLf;
		If ( Msg_Ln<=19 ) Then Begin
			Msg_Ln := Msg_Ln + 1;
			MesgL[Msg_Ln] := MLin;
		End
		Else EchoSE( 'Out Of Room...' );
		If ( Msg_Ln=19 ) Then EchoSE( 'One More Line Left...' );
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
		EchoS ( '\r\i Press \g/\r To Enter Edit Mode, ' );
		EchoSE( '\g/S\r - Save,  \g/A\r - Abort, \g/?\r - Help\o\b' );
		CrLf;
		Show_Column_Bar;
		Repeat
			If ( Wrap ) Then Begin
				Enter_Line( MLin, Word, Ch, KyCnt, Wrap, Word );
			End
			Else If ( Wrap = False ) Then
				Enter_Line( MLin, Word, Ch, KyCnt, Wrap, Null );
			If ( KyCnt=1 ) And ( Wrap=False ) Then Begin
				Case Ch of
					'A' : Abort := True;
					'B' : Begin
									EchoS( 'Begin Over...Are You Sure? ' );
									If ( Yes_No( 'N' ) ) Then Begin
										Msg_Ln:=Lin_No;
										Clear_Screen;
										EchoSE( 'Entire Message Has Been Erased...' );
										Goto 100;
									End;
								End;
					'C' : Show_Column_Bar;
					'D' : Delete_Desc_Line;
					'E' : Edit_Line;
					'F' : Frmt_List;
					'I' : Insert_Line;
					'L' : List_Desc_Line( 1 );
					'N' : List_Desc_Line( 2 );
					'P' : Pack_Lines;
					'R' : If Msg_Ln <20 Then Begin
									EchoSE( MesgL[Msg_Ln] );
									Msg_Ln := Msg_Ln + 1;
									MesgL[Msg_Ln] := MesgL[Msg_Ln - 1];
								End;
					'S' : Begin
									EchoS( 'Saving Description...' );
									Save_Description;
									EchoSE( 'Thanks' );
									SaveM := True;
								End;
					'U' : Begin Save_Description; SaveM := True; End;
					'V' : Begin
									If WidT = 80 Then WidT := 40  Else WidT := 80;
									Writev( S, 'Video Width Now ', WidT );
									EchoSE( S );
								End;
					'W' : Begin
									If WW_Toggle = True Then WW_Toggle:=False
										Else WW_Toggle:=True;
									EchoS( 'Word Wrap Is Now ' );
									If WW_Toggle = True Then S:='On'  Else S:='Off';
									EchoSE( S );
								End;
					'Y' : Begin
									EchoS( 'Enter New Prompt Char :> ' );
									Prompt := Get_Char;
								End;
					'/' : Clear_Screen;
					'?' : Show_Desc_Help;
					Else If Ord( Ch ) = Cr Then Show_Line_Status
					Else Begin Back_Space; Back_Space; Back_Space; End;
				End; { Case }
			End
			Else Show_Line_Status;
		Until ( Abort ) or ( SaveM ) or ( Carrier=False );
	End;

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
		EchoS( '[\r1\b] ' );  EchoSE( Rating[1] );
		EchoS( '[\r2\b] ' );  EchoSE( Rating[2] );
		EchoS( '[\r3\b] ' );  EchoSE( Rating[3] );
		EchoS( '[\r4\b] ' );  EchoSE( Rating[4] );
		EchoS( '[\r5\b] ' );  EchoSE( Rating[5] );
		EchoS( '[\r6\b] ' );  EchoSE( Rating[6] );
		CrLf;
		EchoS( 'Enter Rating Of This File -> ' );
		Repeat
			Choice := Get_Char;
			If Choice In['0'..'6'] Then Begin
				S := Rating[Ord( Choice ) - 48];
				MesgL[3] := S;
				EchoSE( S );
				Done := True;
			End;
		Until ( Done ) or ( Carrier=False );
	End;

	Procedure Edit_Descript2;
	Begin
		Temp := Concat( 'Current File -> ', File_Name );  EchoSE( Temp );
		Desc_Path := Concat( System2.Paths[ Sig_Num ], 'DESC\', File_Name );
		MakeCstring( Desc_Path, Desc_Path_C );
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
	End;

	Procedure Kill_File;
	Var
		X : Integer;
	Begin
		CrLf;
		EchoS( '\r Kill\b, Are You Sure? ' );
		If ( Yes_No( 'N' ) ) Then Begin
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
		If ( Length(Temp) > 0 ) Then Begin
			Old_N := Concat( System2.Paths[Sig_Num], File_Name );
			MakeCstring( Old_N, OldN );
			New_N := Concat( System2.Paths[Sig_Num], Temp );
			MakeCstring( New_N, NewN );
			X := Rename( 0, OldN, NewN );
			Dummy_I := Int( X );
			Show_Error( Old_N, Dummy_I );

			Old_N := Concat( System2.Paths[Sig_Num], 'DESC\', File_Name );
			MakeCstring( Old_N, OldN );
			New_N := Concat( System2.Paths[Sig_Num], 'DESC\', Temp );
			MakeCstring( New_N, NewD );
			X := Rename( 0, OldN, NewD );
			Dummy_I := Int( X );
			Show_Error( Old_N, Dummy_I );
			Fname := NewN;
			If Sfirst( NewN, 0 ) = 0 Then Make_F_Names;
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

	Procedure Show_Batch_Status( Md:Integer; Cnt:Integer );
	Var
		I, X : Integer;
		C : Cstring;
		Temp, F : String;
	Begin
		For I := 1 to BM_Num Do Begin
			Temp :=BMark[ I ].BM_Fname;  X := BMark[ I ].BM_Sig;
			Desc_Path := Concat( System2.Paths[ X ], 'DESC\', Temp );
			MakeCstring( Desc_Path, Desc_Path_C );
			Update_DL_Status;
		End;
	End;

	Procedure Batch_Send;
	Var
		Ch : Char;
		Lgff : Boolean;
		L : Long_Integer;
		K,X,I,T : Integer;
	Begin
		If ( BM_Num > 0 ) Then Begin
			L := 59;
			For I := 1 to BM_Num Do  L := L + BMark[ I ].BM_D_Time;
			L := L Div 60;
			CrLf;
			WriteV( Line, 'Time Required : ', L:3, ' Mins' );  EchoSE( Line );
			WriteV( Line, 'Time Remaining: ', TimeLeft:3, ' Mins' );  EchoSE( Line );
			CrLf;
			If ( L <= TimeLeft ) Then Begin
				EchoS( ' [\rY\b]Modem,  [\rZ\b]Modem  [\rA\b]bort >' );
				Return := 16;  Lgff := False;
				Repeat
					Ch := Get_Char;  Upper_C( Ch );  K := Ord( Ch );
				Until ( Ch In [ 'A','Y','Z' ] ) or ( Carrier=False );
				If ( Carrier ) And ( Ch <> 'A' ) Then Begin
					If ( Ask_LogOff ) Then Lgff := True;
					Case Ch of
						'Y' : Begin
										EchoSE( ' YModem' );
										Cmd_Line := '-u -y';
										Xfer_Type := 'Ymodem Batch';
									End;
						'Z' : Begin
										EchoSE( ' ZModem' );
										Cmd_Line := '-u -z';
										Xfer_Type := 'Zmodem Batch';
									End;
					End; { Case }
					Batch_Down := True;
					Return := Exec_Xyz;
					If ( Return = 0 ) Then Begin
						New_Dls := New_Dls + BM_Num;
						Show_DL_UL;
						DescL[1] := Concat( 'Completed ', Xfer_Type, ' Download Of :' );
						Log( 1 );
						Show_Batch_Status( 1,BM_Num );
						BM_Num := 0;
					End
					Else Begin
						X := Get_Ftu_Xfr;
						DescL[1] := Concat( 'Aborted ', Xfer_Type, ' Download Of :' );
						Writev( DescL[2], 'Files Transfered = ', X );
						Log( 2 );
						For I := 1 to BM_Num Do Begin
							X := BMark[ I ].BM_Sig;
							Temp := Concat( System2.Paths[ X ], BMark[ I ].BM_Fname );
							DescL[1] := Temp; Log( 1 );
						End;
					End;
					If ( Lgff ) Then Begin
						CrLf;
						EchoSE( 'Transfer Completed... Logging Off As Requested...' );
						Disconnect;
					End;
				End
				Else If ( K=Cr ) Then EchoSE( 'Aborted...' );
			End
			Else Begin
				EchoSE( 'The Time Required To Download These Files Exceeds The Time Limit' );
				EchoSE( 'You Have Remaining On This Call...' );
				CrLf;
			End;
		End
		Else Show_None_Marked;
	End;

	Procedure DownLoad_File( Var F : String );
	Var
		Ch, C2 : Char;
		Lgff : Boolean;
		K : Integer;
		X : Integer;
	Begin
		File_Name := F;
		Lgff := False;
		CrLf;  EchoSE( ' Download Protocols Available:' );  CrLf;
		EchoS ( '[\rX\b]Modem  [\rC\b]rc XModem  1[\rK\b] XModem  ' );
		EchoS ( '[\rY\b]Modem  [\rZ\b]Modem  [\rA\b]bort >' );
		Repeat
			Ch := Get_Char;  Upper_C( Ch );  K := Ord( Ch );
		Until ( Ch In[ 'A','C','K','X','Y','Z' ] ) Or ( Carrier = False );
		If ( Carrier ) And ( Ch <> 'A' ) Then Begin
			Case Ch of
				'X' : Begin
								EchoSE( ' Xmodem' );
								Cmd_Line := '-u -xc';
								Xfer_Type := 'Xmodem Std';
							End;
				'C' : Begin
								EchoSE( ' Xmodem Crc' );
								Cmd_Line := '-u -x';
								Xfer_Type := 'Xmodem Crc';
							End;
				'K' : Begin
								EchoSE( ' Xmodem 1k' );
								Cmd_Line := '-u -x1k';
								Xfer_Type := 'Xmodem 1k';
							End;
				'Y' : Begin
								EchoSE( ' Ymodem' );
								Cmd_Line := '-u -y';
								Xfer_Type := 'Ymodem';
							End;
				'Z' : Begin
								EchoSE( ' Zmodem' );
								Cmd_Line := '-u -z';
								Xfer_Type := 'Zmodem';
							End;
			End; { Case }
			If ( Ask_LogOff ) Then Lgff := True;
			Return := Exec_Xyz;
			If ( Return = 0 ) Then Begin
				New_Dls := New_Dls + 1;
				Show_DL_UL;
				Update_DL_Status;
				DescL[1] := Concat( 'Completed ', Xfer_Type, ' Download Of : ', File_Name );
			End
			Else If ( Return < 0 ) Then Begin
				DescL[1] := Concat( 'Aborted ', Xfer_Type, ' Download Of : ', File_Name );
				EchoSE( 'Aborted...' );
			End;
			Log( 1 );
			If ( Lgff ) Then Begin
				CrLf;
				EchoSE( 'Transfer Completed... Logging Off As Requested...' );
				Disconnect;
			End;
		End
		Else EchoSE( 'Aborted...' );
	End;

	Procedure Download_A_File;
	Var
		F : String;
	Begin
		CrLf;
		EchoS( ' Enter Filename -> ' );
		Caps := True;  Line_In( F, 12 );
		If ( Filename_Ok( F ) ) Then Begin
			File_Name := F;
			If Exists( File_Name ) Then Download_File( F )
			Else EchoSE( ' Sorry, That File Doesn''t Exist!!!' );
		End
		Else EchoSE( '\r Illegal Filename...\b' );
	End;

	Procedure Batch_Upload( Ch : Char );
	Var
		T, I, X : Integer;
		S, D : String;
		C : CString;
	Begin
		Batch_Upld := True;
		T := FMax;
		Case Ch of
			'Y' : Begin
							EchoSE( ' YModem' );
							Cmd_Line := '-d -y';
							Xfer_Type := 'Ymodem';
						End;
			'Z' : Begin
							EchoSE( ' ZModem' );
							Cmd_Line := '-d -z';
							Xfer_Type := 'Zmodem';
						End;
		End; { Case }
		Change_Drv_Path( System2.Upld_Pth );
		Return := Exec_Xyz;
		FPath := Concat( System2.Upld_Pth, '*.*' );
		Max_File;
		If ( FMax > 0 ) Then Begin
			DescL[1] := Concat( 'Completed ', Xfer_Type, ' Upload Of : ' );
			Log( 1 );
			New_Uls := New_Uls + FMax;
			Show_DL_UL;
			For I := 1 To FMax Do Begin
				FCnt := 0;
				X := F_Search( 1 );
				MakeFname( Dta_Data.Name, File_Name );
				DescL[1] := Concat( '      ', File_Name );  Log( 1 );
				F_Name := Concat( System2.Paths[Sig_Num], File_Name );
				MakeCstring( F_Name, F_Path );
				D := F_Name;  S := Concat( System2.Upld_Pth, File_Name );
				Copy_File( S, D );
				MakeCstring( S, C );
				X := UnLink( C );
				Hide_File;
				If ( Use_Desc ) Then Edit_Descript2;
			End;
			FMax := T;
		End
		Else If ( FMax <= 0 ) Then Begin
			DescL[1] := Concat( 'Aborted ', Xfer_Type, ' Upload : ' );
			EchoSE( 'Aborted...' );
			Log( 1 );
		End;
		Change_Drv_Path( System2.Paths[Sig_Num] );
	End;

	Procedure Upload_A_File;
	Var
		K  : Integer;
		Ch : Char;
		F  : String;
		Abort : Boolean;
	Begin
		CrLf;
		If ( Show_Free ) Then Show_Dfree;
		CrLf;  EchoSE( ' Upload Protocols Available:' );  CrLf;
		EchoS ( '[\rX\b]Modem  [\rC\b]rc XModem  1[\rK\b] XModem  [\rY\b]Modem  [\rZ\b]Modem  ' );
		EchoS ( '[\rA\b]bort >' );
		Repeat
			Ch := Get_Char;  Upper_C( Ch );  K := Ord( Ch );
		Until ( Ch In['A','C','K','X','Y','Z'] ) Or ( Carrier=False );
		If ( Carrier ) And ( Ch <> 'A' ) Then Begin
			Abort := False;
			If ( Ch <> 'Y' ) And ( Ch <> 'Z' ) Then Begin
				EchoS( ' Enter Filename -> ' );
				Caps := True;  Line_In( F, 12 );
				If ( Filename_Ok( F ) ) Then Begin
					If ( Exists( F ) ) Then Begin
						EchoSE( 'That File Already Exists...' );
						Abort := True;
					End;
				End
				Else Begin
					Abort := True;
					EchoSE( ' \rIllegal Filename...\b' ); CrLf;
				End;
				If ( Abort = False ) Then Begin
					CrLf; CrLf;
					File_Name := F;
					Case Ch of
						'X' : Begin
										EchoSE( ' Xmodem' );
										Cmd_Line := '-d -xc';
										Xfer_Type := 'Xmodem Std';
									End;
						'C' : Begin
										EchoSE( ' Xmodem Crc' );
										Cmd_Line := '-d -x';
										Xfer_Type := 'Xmodem Crc';
									End;
						'K' : Begin
										EchoSE( ' Xmodem 1k' );
										Cmd_Line := '-d -x1k';
										Xfer_Type := 'Xmodem 1k';
									End;
					End; { Case }
					Return := Exec_Xyz;
					If ( Exists( F ) ) Then Begin
						New_Uls := New_Uls + 1;
						Show_DL_UL;
						F_Name := Concat( System2.Paths[Sig_Num], File_Name );
						MakeCstring( F_Name, F_Path );
						DT_Stamp( F_Name );
						Hide_File;
						If ( Use_Desc ) Then Edit_Descript2;
						DescL[1] := Concat( 'Completed ', Xfer_Type, ' Upload Of : ', File_Name );
					End
					Else If ( Return < 0 ) Then Begin
						DescL[1] := Concat( 'Aborted ', Xfer_Type, ' Upload Of : ', File_Name );
						EchoSE( 'Aborted...' );
					End;
					Log( 1 );
				End;
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
		CrLf;
		EchoS( '[\rA\b]gain  ' );
		If ( FCnt < FMax ) Then EchoS( '<\gC\b>ont  ' );
		EchoS( '[\rJ\b]ump  [\rM\b]ark  ' );
		If Arc_File Then Begin
			Line := Concat( '[\rU\b]n', Arc_Type[ArcT], ' ' );
			EchoS( Line );
			End;
		If Arc_File = False Then EchoS( '[\rR\b]ead  ' );
		EchoS ( '[\rQ\b]uit  [\rD\b]ownload  ' );
		If ( FCnt > 1 ) Then EchoS ( '[\rL\b]ast  ' );
		EchoSE( '[\r?\b]Help' );

		If ( Sig_Op ) Then Begin
			EchoS( '\r\iSigOp Commands:>\o\b ' );
			If ( Sig2_Kill [Sig_Num]=1 ) Then EchoS( '[\rK\b]ill  ' );
			If ( Sig2_Valid[Sig_Num]=1 ) Then Begin
				If ( Hide_Mode ) Then EchoS( '[\rH\b]ide ' )
				Else EchoS( '[\rV\b]alid' );
			End;
			If ( Sig2_Edit[Sig_Num]=1 ) Then Begin
				EchoSE( ' [\rE\b]dit  [\rN\b]ame  [\rF\b]ile Maint.' );
			End;
		End;
		CrLf;
		EchoS( 'File Cmnd:> ' );
	End;

	Procedure Show_File_Help;
	Var
		S : String;
	Begin
		New_Line := False;
		Clear_Screen;
		CrLf;
		EchoSE( ' File Commands:' );
		CrLf;
		S := '[\rA\b] Again - Same Description';           Show_40( S );
		S := '[\gC\b] Continue (Or Press "Return")';       Show_40( S );
		S := '[\rD\b] Download This File';                 Show_40( S );
		S := '[\rJ\b] Jump To A File';                     Show_40( S );
		S := '[\rL\b] Last File';                          Show_40( S );
		S := '[\rM\b] Mark This File For Batch Transfer';  Show_40( S );
		S := '[\rR\b] Read ASCII Text File';               Show_40( S );
		S := '[\rU\b] Verbose Listing Of ARCHIVED FILE';   Show_40( S );
		S := '[\rQ\b] Quit To SIG Menu';                   Show_40( S );
		CrLf; CrLf;

		EchoSE( ' SigOp Commands:' ); CrLf;

		S := '[\rE\b] Edit Description & File Stats';      Show_40( S );
		S := '[\rH\b] Hide This File';                     Show_40( S );
		S := '[\rK\b] Kill This File';                     Show_40( S );
		S := '[\rN\b] Name This File';                     Show_40( S );
		S := '[\rV\b] Validate File (Time/Date Stamp)';   Show_40( S );
		CrLf;
		Show_List_Opt;
	End;

	Procedure Show_Scan_Text;
	Var
		FF, Temp : String;
	Begin
		Fn_Convert( File_Name, FF );  AddSpaces( FF, 14 );
		Writev( Temp, Lines:2, '  ', FF );         { 18 }
		Writev( Line, Dta_Data.Size:6, '  ' );
		Temp := Concat( Temp, Line );              { 26 }
		Convert_Date( Dta_Data.Date );
		AddSpaces( Line, 14 );
		Temp := Concat( Temp, Line );              { 40 }
		Line := MesgL[4];
		If ( Ord( Line[0] ) >38 ) Then Line[0] := Chr( 39 );
		Temp := Concat( Temp, Line );
		EchoSE( Temp );
	End;

	Procedure Show_List_Text;
	Var
		Temp : String;
		X : Long_Integer;
	Begin
		Clear_Screen;
		CrLf;
		New_Line := False; Arc_File := False;
		If Pos( '.ARC', File_Name ) >1 Then Begin ArcT:= 1;Arc_File := True; End;
		If Pos( '.ARK', File_Name ) >1 Then Begin ArcT:= 1;Arc_File := True; End;
		If Pos( '.ARJ', File_Name ) >1 Then Begin ArcT:= 2;Arc_File := True; End;
		If Pos( '.LHA', File_Name ) >1 Then Begin ArcT:= 3;Arc_File := True; End;
		If Pos( '.LZH', File_Name ) >1 Then Begin ArcT:= 3;Arc_File := True; End;
		If Pos( '.SIT', File_Name ) >1 Then Begin ArcT:= 4;Arc_File := True; End;
		If Pos( '.ZIP', File_Name ) >1 Then Begin ArcT:= 5;Arc_File := True; End;
		If Pos( '.ZOO', File_Name ) >1 Then Begin ArcT:= 6;Arc_File := True; End;

		Temp := Concat( '\rFilename\b  : ', File_Name );
		AddSpaces( Temp, 34 );
		If ( Hide_Mode=False ) Then Temp := Concat( Temp, '<<New>>' );
		Show_40( Temp );

		Writev( Temp, '\rFile Nmbr\b : ', FCnt, ' Of ', FMax );
		If ( Kywrd_Srch ) Then
		Writev( Temp, '\rFile Nmbr\b : ', FCur, ' Of ', Kywrd_Cnt );
		Show_40( Temp );

		Get_DL_Time;
		Writev( Temp, '\rXfer Time\b : ', DL_Time_Str, ' @ ',BaudRate,' Baud' );
		Show_40( Temp );

		Convert_Date( Dta_Data.Date ); Temp := Line;
		Convert_Time( Dta_Data.Time );
		Temp := Concat( '\rUploaded\b  : ', Temp, '  ', Line ); Show_40( Temp );

		Writev( Temp, '\rFile Size\b : ', Dta_Data.Size ); Show_40( Temp );
		Writev( Temp, '\rUploader\b  : ', MesgL[1] ); Show_40( Temp );
		Writev( Temp, '\rDL Count\b  : ', MesgL[2] ); Show_40( Temp );
		Writev( Temp, '\rRating\b    : ', MesgL[3] ); Show_40( Temp );

		X := ( ( Dta_Data.Size ) + 1023 ) Div 1024;
		Writev( Temp, '\rBlocks\b    : Y/Zmodem: ', X );
		EchoS( Temp );

		X := ( ( Dta_Data.Size ) + 127 ) Div 128;
		Writev( Temp, ',  Xmodem: ', X );
		EchoSE( Temp );

		CrLf;
		If Msg_Ln >3 Then For X := 4 to Msg_Ln Do EchoSE( MesgL[X] )
		Else EchoSE( ' No Description' );
	End;

	Procedure Edit_File;
	Var
		Done, No_Chng: Boolean;
		Choice : Char;
	Begin
		Done := False;
		No_Chng := False;
		Repeat
			Show_List_Text;
			CrLf;
			EchoSE( '[\rU\b]ploader  [\rC\b]ount  [\rR\b]ating  [\rL\b]evel  [\rD\b]escription' );
			EchoSE( '[\rA\b]bort     [\rZ\b] Done' );
			CrLf;
			EchoS( 'Edit Command -> ' );
			Choice := Get_Char;  Upper_C( Choice );
			Case Choice Of
				'A' : Begin EchoSE( 'Abort' ); No_Chng := True; End;
				'Z' : Begin
								EchoSE( 'Done' );
								If ( Use_Desc ) Then Save_Description;
								If Sfirst( Fname, 0 ) = 0 Then Done := True;
								Done := True;
							End;
				'U' : Begin EchoSE( 'Uploader' ); Edit_Uploader; End;
				'C' : Begin EchoSE( 'D/L Count' ); Edit_DL_Count; End;
				'R' : Begin EchoSE( 'Rating' ); Edit_Rating; End;
				'D' : Begin
								EchoSE( 'Description' );
								Edit_Description;
								If ( Abort ) Then Abort := False;
								End;
				Else Show_Wrong;
			End; { Case }
		Until ( Done ) or ( No_Chng ) or ( Carrier=False );
	End;

	Procedure Copy_2_Sig( Md : Integer );
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

		Change_Topic( 1 );
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
			If ( Md=1 ) Then Begin
				X := UnLink( Cs );
				If ( X<0 ) Then Show_Error( Old_N, X );
			End;

			Old_N := Concat( System2.Paths[Y], 'DESC\', File_Name );
			New_N := Concat( System2.Paths[Sig_Num], 'DESC\', File_Name );
			MakeCString( Old_N, Cs );
			EchoS ( 'Copying ' );
			EchoSE( Old_N );
			EchoS ( ' To --> ' );
			EchoSE( New_N );
			Copy_File( Old_N, New_N );
			If ( Md=1 ) Then Begin
				X := UnLink( Cs );
				If ( X<0 ) Then Show_Error( Old_N, X );
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
			EchoSE( ' [\rT\b]  Touch File ( Time/Date Stamp	' );
			CrLf;
			EchoS( ' Enter Choice, [Return] to Exit -> ' );
			Repeat
				Ch := Get_Char;  Upper_C( Ch );  X := Ord( Ch );
			Until ( Ch In[ 'C','M','S','T' ] ) or ( X=Cr ) or ( Carrier=False );
			If ( X=Cr ) Then Done := True;
			Case Ch Of
				'C' : Copy_2_Sig( 0 );
				'M' : Copy_2_Sig( 1 );
				'S' : Begin CrLf; Show_DFree; Press_Any; End;
				'T' : DT_Stamp( F_Name );
			End; {Case}
		Until ( Done ) or ( Carrier=False );
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
				'C' : Begin EchoSE( 'Cont' ); Done := True; End;
				'M' : Begin EchoSE( 'Mark' ); Batch_Mark_File; Done := True; End;
				'D' : Begin EchoSE( 'Download' ); Download_File( File_Name ); Show := True; End; 
				'U' : If Arc_File Then Begin
								Show_File( F_Name );
								Temp := Concat( 'Un\r', Arc_Type[ArcT], '\b  ' );
								EchoS( Temp );
								If ArcT = 1 Then List_Arc( F_Name )
								Else If ArcT = 2 Then List_Arj( F_Name )
								Else If ArcT = 3 Then List_Lzh( F_Name )
								Else If ArcT = 4 Then List_Sit( F_Name )
								Else If ArcT = 5 Then List_Zip( F_Name )
								Else If ArcT = 6 Then List_Zoo( F_Name );
								Press_Any;
								Show := True;
								End;
				'R' : If Arc_File = False Then Begin
								EchoSE( 'Read' );
								Read_File;
								Show := True;
							End;
				'V' : If ( Hide_Mode=False ) And ( Sig2_Valid[Sig_Num]=1 ) Then Begin
								EchoSE( 'Valid' );
								Valid_File;
								Show := True;
							End
							Else Show_Wrong;
				'H' : If ( Hide_Mode ) and ( Sig2_Valid[Sig_Num]=1 ) Then Begin
								EchoSE( 'Hide' );
								Hide_File;
								Show := True;
							End
							Else Show_Wrong;
				'E' : If ( Sig2_Edit[Sig_Num]=1 ) Then Begin
								EchoSE( 'Edit' );
								Edit_File;
								Show := True;
							End
							Else Show_Wrong;
				'F' : If ( Sig2_Edit[Sig_Num]=1 ) Then Begin
								EchoSE( 'Maint.' );
								File_Maint;
								Show := True;
							End
							Else Show_Wrong;
				'N' : If ( Sig2_Edit[Sig_Num]=1 ) Then Begin
								EchoSE( 'Name' );
								Rename_File;
								Show := True;
							End
							Else Show_Wrong;
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
				'K' : If ( Sig2_Kill[Sig_Num]=1 ) Then Begin
								EchoSE( 'Kill' );
								Kill_File;
								Done := True;
							End
							Else Show_Wrong;
				'L' : Begin EchoSE( 'Last' ); Num := -1; Done := True; End;
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
				Else If Ord( Ch ) <>Cr Then Show_Wrong;
			End;
		Until ( Abort ) or ( Carrier=False ) or ( Done ) or ( Ord( Ch ) = Cr );
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
			If ( Sig2_Valid[Sig_Num]=0 ) And ( Hide_Mode=False ) Then Ok := False;
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
			If ( New_Files ) And ( Dta_Data.Date < Usr_Lst_Call ) Then Ok := False
			Else If ( Kywrd_Srch ) And ( Kywrd_Cnt = 0 ) Then Ok := False
			Else If ( Find_File ) And ( Dta_Data.Date < Find_Date ) Then Ok := False;
			If ( Ok ) Then Begin
				CrLf;
				EchoSE( 'No  Filename       Size   Uploaded On   Short Description' );
				EchoSE( '--  ------------  ------  ------------  -----------------' );
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
				If ( Sig2_Valid[Sig_Num]=0 ) And ( Hide_Mode=False ) Then Ok := False;
				If ( Ok ) And ( Kywrd_Srch ) Then Ok := Search_4_Kywrd;
				If ( Ok ) Then Begin
					If ( Kywrd_Cnt = 1 ) Then Show_Scan_Hdr;
					Get_DL_Time;
					SMark[Lines].BM_FName  := File_Name;
					SMark[Lines].BM_FSize  := Dta_Data.Size;
					SMark[Lines].BM_FTime  := Dta_Data.Time;
					SMark[Lines].BM_D_Time := DL_Time;
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
			Writev( Line, 'Mark Which File ( 1-', Lines-1, ' ) -> ' );
			EchoS( Line );
			K := Get_Number( Lines-1 );
			If ( K>0 ) Then Begin
				File_Name     := SMark[K].BM_Fname;
				Dta_Data.Size := SMark[K].BM_Fsize;
				DL_Time       := SMark[K].BM_D_Time;
				Batch_Mark_File;
			End;
		Until ( K<1 ) or ( Carrier=False );
		CrLf;
	End;

	Procedure Scan_DL;
	Var
		K : Integer;
	Begin
		CrLf;
		Writev( Line, 'DownLoad Which File ( 1-', Lines-1, ' ) -> ' );
		EchoS( Line );
		K := Get_Number( Lines-1 );
		If ( K>0 ) Then Begin
			File_Name     := SMark[K].BM_Fname;
			Dta_Data.Size := SMark[K].BM_Fsize;
			DL_Time       := SMark[K].BM_D_Time;
			DownLoad_File( File_Name );
		End;
		CrLf;
	End;

	Procedure Scan_Browse;
	Var
		K : Integer;
	Begin
		CrLf;
		Writev( Line, 'Browse Which File ( 1-', Lines-1, ' ) -> ' );
		EchoS( Line );
		K := Get_Number( Lines-1 );
		If ( K>0 ) Then Begin
			File_Name     := SMark[K].BM_FName;
			Dta_Data.Size := SMark[K].BM_FSize;
			Dta_Data.Time := SMark[K].BM_FTime;
			DL_Time       := SMark[K].BM_D_Time;
			Get_Description( 20 );
			Show_List_Text;
			Press_Any;
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
				EchoS( '[\rB\b]rowse  [\rD\b]ownload  [\rJ\b]ump  ' );
				If ( FCnt>17 ) Then EchoS( '[\rL\b]ast  ' );
				EchoS( '[\rM\b]ark  ' );
				If ( X=0 ) Then EchoS( '[\gN\b]ext ' );
				EchoS( '[\rQ\b]uit ' );
				Repeat
					Ch := Get_Char;  Upper_C( Ch );
					Case Ch Of
						'B' : Begin
										EchoSE( 'Browse' );  Scan_Browse; Again := True;
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
						'J' : Begin
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
						Else If ( Ch = Chr( Cr ) ) Then Begin
							If ( X >= 0 ) Then Begin
								EchoSE( 'Next' ); Lines := 1;
							End
							Else Done := True;
						End;
					End;
				Until (Again) or (Done) or (Abort) or (Carrier=False) or (Lines=1);
				If ( Again ) Then Begin
					Clear_Screen;
					If ( FCnt > 16 ) Then Lines := Lines + 16
						Else Lines := Lines + FCnt;
					If ( FCnt<FMax ) Then Lines := Lines - 1;
					X := 0 - Lines;
					X := F_Search( X ); If ( FCnt=1 ) Then FCnt := 0;
					Lines := 1;
				End;
			End;
		Until ( Done ) or ( Abort ) or ( Carrier=False ) or ( X<0 );
		If ( FCnt=0 ) And ( X<0 ) Then Begin
			CrLf;
			If Sspec = '*.*' Then EchoSE( 'This Sig Is Empty...' )
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
				Line := Copy( Temp, Ln-1, 2 );
				Date_Ok := Is_Numeric( Line );
				If ( Date_Ok ) Then Begin
					Readv( Line, Y );
					If ( Y<80 ) and ( Y>99 ) Then Date_Ok := False;
					X := Pos( '/', Temp );
					Line := Copy( Temp, 1, X-1 );
					Date_Ok := Is_Numeric( Line );
					If ( Date_Ok ) Then Begin
						Readv( Line, M );
						If ( M<1 ) and ( M>12 ) Then Date_Ok := False;
						Temp := Copy( Temp, X+1,3 );
						X := Pos( '/', Temp );
						Line := Copy( Temp, 1, X-1 );
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
		Line := Concat( 'Checking Files In -> ',System2.TNames[Top_Sig], '>' );
		Line := Concat( Line, System2.Names[Sig_Num], ' :> ' );
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
		Ch := Get_Char;  Upper_C( Ch );
		If Ord( Ch ) =Cr Then Ch := 'N';
		Case Ch Of
			'N' : Begin
							Quick_Scan := True;
							EchoSE( 'ALL New Files...' );
							Top_Cntr := 1;
							Sig_Cntr := 0;
							Top_Sig := Sig_Access[Top_Cntr];
							Max_Sub := System2.SigCount[Top_Sig-1];
							Loop
								Change_Sig;
								Exit If ( Tot_Sig ) or ( Quick_Scan=False );
								List_New_Files;
							End;
							Quick_Scan := False;
						End;
			'D' : Begin
							Quick_Scan := True;
							EchoSE( 'By Date...' );
							If ( Get_Find_Date ) Then Begin
								Top_Cntr := 1;
								Sig_Cntr := 0;
								Top_Sig := Sig_Access[Top_Cntr];
								Max_Sub := System2.SigCount[Top_Sig-1];
								Loop
									Change_Sig;
									Exit If ( Tot_Sig ) or ( Quick_Scan=False );
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
		EchoSE( 'By: [\gA\b]ll [\rK\b]eyword [\rN\b]ew [\rS\b]ince Date' );
		CrLf;
		EchoS( 'Choice -> ' );
		Choice := Get_Char;  Upper_C( Choice );
		If Ord( Choice ) = Cr Then Choice := 'A';
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
		Fa,Fm,Fv,Fe,Fk,V : Long_Integer;
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
			For I := 0 to 31 Do Begin
				If Bit_Test( Fa, I ) Then Mesgl[1] := Concat( MesgL[1], 'Y' )
					Else Mesgl[1] := Concat( MesgL[1], '.' );
				If Bit_Test( Fm, I ) Then Mesgl[2] := Concat( MesgL[2], 'Y' )
					Else Mesgl[2] := Concat( MesgL[2], '.' );
				If Bit_Test( Fe, I ) Then Mesgl[3] := Concat( MesgL[3], 'Y' )
					Else Mesgl[3] := Concat( MesgL[3], '.' );
				If Bit_Test( Fv, I ) Then Mesgl[4] := Concat( MesgL[4], 'Y' )
					Else Mesgl[4] := Concat( MesgL[4], '.' );
				If Bit_Test( Fk, I ) Then Mesgl[5] := Concat( MesgL[5], 'Y' )
					Else Mesgl[5] := Concat( MesgL[5], '.' );
			End;
			Clear_Screen;
			CrLf;
			Writev( S, 'Editing Topic Sig #', Sig, '  -  ', System2.TNames[Sig] );
			EchoNE( S );
			CrLf;
			EchoNE( '                       Sub-Topic File SIGS       ' );
			EchoNE( '                          1         2         3  ' );
			EchoNE( '     Function    12345678901234567890123456789012' );
			EchoNE( '     ---------   --------------------------------' );
			EchoNE( MesgL[1] );
			EchoNE( MesgL[2] );
			EchoNE( MesgL[3] );
			EchoNE( MesgL[4] );
			EchoNE( MesgL[5] );
			CrLf;
			Done := False;  I := 0;
			EchoN( 'Enter Function To Edit [Return] to Exit -> ' );
			Repeat
				Ch := Get_Char;  I := Ord( Ch );
			Until ( Ch IN['1'..'5'] ) or ( I=Cr ) or ( Carrier=False );
			CrLf;  CrLf;
			If ( I=Cr ) Then Done := True;
			If Ch In['1'..'5'] Then Begin
				Y := Ord( Ch ) - 48;
				S := Concat( ' Old -> ', MesgL[Y] );  EchoNE( S );
				S := Concat( ' New -> ', MesgL[Y] );  EchoN( S );
				For I := 1 to 32 Do Back_Space;  V := 0;
				For I := 0 to 31 Do Begin
					Repeat
						Ch := Get_Char;  Upper_C( Ch );
					Until ( Ch='Y' ) or ( Ch='N' ) or ( Carrier=False );
					If Ch = 'Y' Then EchoS( Ch ) Else EchoS( '.' );
					If Ch='Y' Then Bit_Set( V, I );
				End;
				CrLf; CrLf;
				If Y = 1 Then UserAcs.Sig_Accs[ Sig ] := V
				Else If Y = 2 Then UserAcs.User_Mask[ Sig ] := V
				Else If Y = 3 Then UserAcs.Sig_Edit[ Sig ] := V
				Else If Y = 4 Then UserAcs.Sig_Valid[ Sig ] := V
				Else UserAcs.Sig_Kill[ Sig ] := V;
			End;
		Until ( Done ) or ( Carrier=False );
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
				For I := 1 to 32 Do If Sig_Access[I] = Sig Then Ok := True;
				Writev( S, '  ',Sig:4, '.  ' );
				If Length( SysTem2.TNames[Sig] ) = 0 Then S := Concat( S, '*- Empty -*' )
				Else If ( Ok=False ) Then S := Concat( S, ' - Not Authorized -' )
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
			If ( Sig>0 ) Then Begin
				Edit_TopSig( Sig );
			End;
		Until ( Sig<0 ) or ( Carrier=False );
	End;

	Function Change_Stats : Integer;
	Var
		X, Z, I, I2 : Integer;
		Fa, Fb : Long_Integer;
		Temp : String;
		B : Packed Array [1..32] of Integer;
	Begin
		Clear_Screen;  CrLf;
		X := 0; Z := 0;  I := ( Top_Sig - 1 ) * 32;
		Fa := UserAcs.Sig_Accs[ Top_Sig ];
		Fb := UserAcs.User_Mask[ Top_Sig ];
		EchoSE( 'Sigs You Currently Have Access To:' );  CrLf;
		Repeat
			I2 := I + X;  X := X + 1;  Temp := System2.Names[ I2 ];
			If ( Bit_Test ( Fa, X-1 ) ) And ( Length ( Temp ) > 0 ) Then Begin
				Z := Z + 1; B [ Z ] := X;
				Writev( Temp, '[\r', Z, '\b] ', System2.Names[ I2 ] );
				If X<10 Then Temp := Concat( ' ', Temp );  Addspaces( Temp ,39 );
				If Bit_Test( Fb, X-1 ) Then Temp := Concat( Temp, 'Yes ' )
					Else Temp := Concat( Temp, 'No  ' );
				If ( Odd( X ) ) And ( WidT=80 ) Then EchoS( Temp ) Else EchoSE( Temp );
			End;
		Until ( X = 32 ) or ( Carrier=False );
		If Odd( Z ) Then CrLf;  CrLf;
		EchoS( 'Enter Sig# To Change, ''0'' to Clear All or [Return] To Exit -> ' );
		I := Get_Number( Max_Avail );
		If ( I = 0 ) Then UserAcs.User_Mask[ Top_Sig ] := 0
		Else If ( I >= 0 ) Then Begin
			X := B [ I ] - 1;
			If Bit_Test( Fb, X ) Then Bit_Clr( Fb, X )  Else Bit_Set( Fb, X );
			UserAcs.User_Mask[ Top_Sig ] := Fb;
		End;
		Get_Sig_Access;
		Get_Sig_Nums;
		CrLf; CrLf;
		Change_Stats := I;
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
		EchoNE( ' [2]  Validate New Files          ' );
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
								EchoNE( '[2]  Apply User Mask  ' );
								CrLf;
								EchoN( 'Choice, [Return] To Exit -> ' );
								Ch := Get_Char;
								Case Ch Of
									'1' : Edit_Usr_Sigs;
									'2' : Begin
												S := 'Enter Mask Number to Apply, [Return] To Exit  -> ';
												EchoN( S );
												Z := Get_Number( 10 );
												If ( Z>0 ) Then Get_MaskData( Z );
											End;
								End; { Case }
							Until ( Ord( Ch ) = Cr ) or ( Carrier=False );
							Save_Ftu_User;
							Get_Sig_Access;
							CrLf;
						End;
			'2' : Begin
							EchoSE( 'Validate New' );
							Top_Cntr := 1;
							Sig_Cntr := 0;
							Top_Sig := Sig_Access[Top_Cntr];
							Max_Sub := System2.SigCount[Top_Sig-1];
							Loop
								Change_Sig;
								Exit If ( Tot_Sig );
								Find_New_Files;
							End;
						End;
			End; {Case}
		Clear_Screen;
	End;

	Procedure Batch_Menu;
	Var
		S : String;
	Begin
		New_Line := False;
		EchoSE ( 'Batch Options:' ); CrLf;
		S := ( '[\rA\b] Add A File To Batch List' );       Show_40( S );
		S := ( '[\rC\b] Clear All Files In Batch List' );  Show_40( S );
		S := ( '[\rD\b] Download Files In Batch List' );   Show_40( S );
		S := ( '[\rL\b] List Files In Batch List' );       Show_40( S );
		S := ( '[\rR\b] Remove File( s ) In Batch List' ); Show_40( S );
		CrLf;  CrLf;
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
			Case Choice of
				'A' : Begin EchoSE ( 'Add' );          Batch_Mark;          End;
				'C' : Begin EchoSE ( 'Clear' );        Clear_Batch;         End;
				'D' : Begin EchoSE ( 'Batch D/Load' ); Batch_Send;          End;
				'L' : Begin EchoSE ( 'List' );         Review_Marked_Files; End;
				'R' : Begin EchoSE ( 'Remove' );       Wipe_Marked;         End;
			End;
		Until ( X = Cr ) or ( Carrier=False );
		CrLf;
		CrLf;
	End;

	Procedure Show_Menu;
	Var
		S : String;
	Begin
		Clear_Screen;
		CrLf;
		S := '\r\i FTU \b Main Menu \o';            EchoNE ( S );
		CrLf;
		New_Line := False;
		S := '[\rB\b] Batch Options';               Show_40( S );
		S := '[\rC\b] Change User Settings';        Show_40( S );
		S := '[\rD\b] Download A File';             Show_40( S );
		S := '[\rL\b] List Files';                  Show_40( S );
		S := '[\rN\b] New File Scan Of ALL SIGS';   Show_40( S );
		S := '[\rO\b] Change Topic SIG';            Show_40( S );
		S := '[\rP\b] Page SysOp';                  Show_40( S );
		S := '[\rS\b] Scan Files';                  Show_40( S );
		S := '[\rT\b] Time Display Toggle';         Show_40( S );
		S := '[\rU\b] Upload A File';               Show_40( S );
		S := '[\rX\b] eXit, Return To BBS';         Show_40( S );
		S := '[\rY\b] Your D/L Stats';              Show_40( S );
		New_Line := False;
		CrLf;
		S := '[\r#\b] Jump To Sig# Entered';        Show_40( S );
		S := '[\r/\b] Goto Next File Sig';          Show_40( S );
		S := '[\r*\b] Show Available File Sigs';    Show_40( S );
		S := '[\r!\b] Quick Log-Off';               Show_40( S );
		S := '[\r?\b] This Menu';                   Show_40( S );
		CrLf; CrLf;
	End;

	Procedure Change_All_Stats;
	Var
		X : Integer;
	Begin
		Repeat
			X := Change_Stats;
		Until ( X<1 ) or ( Carrier=False );
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
		S := ( '[\rC\b] Change User Settings' ); Show_40( S );
		S := ( '[\rO\b] Change Topic SIG' );     Show_40( S );
		S := ( '[\rX\b] eXit, Return To BBS' );  Show_40( S );
		S := ( '[\r?\b] This Menu' );            Show_40( S );
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
		Top_Cntr := 1; Sig_Cntr := 1; Get_Sig_Nums; Sig_Cntr := 0;
		Change_Sig;
		CrLf; Show_Top_Sigs; EchoSE( 'Press ''O'' To Change Topic Sig...' ); CrLf;
		Repeat
			Done := False;  Abort := False;  List_Mode := False;
			Scan_Mode := False;  Clr_Kywrd_File;
			Flush_Input;
			If ( Shw_Time ) Then Begin Show_Timeleft; EchoS( Line ); End;
			If ( Max_Sub=0 ) Then Begin
				Writev ( Line, '[\r', Top_Cntr, '\b>\r0\b> ' );
				EchoS( Line );
				Line := Concat( System2.TNames[Top_Sig], '> No Access :> ' );
				EchoS( Line );
				Choice := Get_Char;  Upper_C( Choice );
				If ( Fnct_Key=F1 ) or ( ( Ord( Choice ) = CtrlE ) And ( Sig_Ops ) ) Then SigOp_Functions;
				Case Choice of
					'C' : Begin EchoSE( 'Change Stats' ); Change_All_Stats; End;
					'O' : Begin EchoSE( 'Change Topic SIG' ); Change_Topic( 0 ); End;
					'X' : Begin EchoSE( 'eXit' ); Done := True; End;
					'?' : Begin EchoSE( 'Help' ); Show_Q_Help; End;
					Else Show_Wrong;
				End; { Case }
			End
			Else If ( TimeLeft > 0 ) Then Begin
				Writev( Line, '[\r', Top_Cntr, '\b>\r', Sig_Cntr, '\b> ' );
				EchoS( Line );
				Line := Concat( System2.TNames[Top_Sig], '>' );
				Line := Concat( Line, System2.Names[Sig_Num], ' :> ' );
				EchoS( Line );
				Choice := Get_Char;  Upper_C( Choice );
				Case Choice of
					'B' : Begin EchoSE( 'Batch Options' ); Batch_Options; End;
					'C' : Begin EchoSE( 'Change Stats' ); Change_All_Stats; End;
					'D' : Begin EchoSE( 'Download' ); DownLoad_A_File; End;
					'L' : Begin EchoSE( 'List Files' ); List_Mode:=True; List_Scan; End;
					'N' : Begin EchoSE( 'New Files' ); Search_New; End;
					'O' : Begin EchoSE( 'Change Topic SIG' ); Change_Topic( 0 ); End;
					'P' : Begin EchoSE( 'Page' ); Page_SysOp; End;
					'S' : Begin EchoSE( 'Scan Files' ); Scan_Mode:=True; List_Scan; End;
					'T' : Time_Toggle;
					'U' : Begin EchoSE( 'Upload' ); Upload_A_File; End;
					'X' : Begin EchoSE( 'eXit' ); Done := True; End;
					'Y' : Begin EchoSE( 'Your D/L Stats' ); Show_DL_Stats; End;
					'?' : Begin EchoSE( 'Help' ); Show_Menu; End;
					'/' : Begin EchoSE( 'Change Sig' ); Change_Sig; End;
					'*' : Show_Sigs;
					'!' : Disconnect;
					Else If Choice In['1'..'9'] Then Begin
						Put_Char( Choice );
						X := Ord( Choice ) - 48;
						Y := 16;
						If Max_Sub >= ( X * 10 ) Then Begin
							Choice := Get_Char;
							If Choice In['0'..'9'] Then Begin
								Put_Char( Choice );
								If Ord( Choice ) <> 13 Then Begin
									Y := Ord( Choice ) - 48;
									If Y = 10 Then Y := 0;
								End;
							End;
						End;
						If ( X <= Max_Sub ) And ( Y = 16 ) Then Sig_Cntr := X
						Else Begin
							X := ( X * 10 ) + Y;
							If ( X <= Max_Sub ) Then Sig_Cntr := X;
						End;
						If Sig_Cntr >0 Then Begin
							Get_Sig_Nums;
							Change_Drv_Path( System2.Paths[Sig_Num] );
						End;
						CrLf;
					End
					Else Begin
						If ( Fnct_Key=F1 ) or ( ( Ord( Choice ) = CtrlE ) And ( Sig_Ops ) ) Then SigOp_Functions
						Else If Fnct_Key = Help_Key Then Show_Main_Help
						Else If Fnct_Key = SF10 Then Disconnect
						Else Show_Wrong; 
					End;
				End; {Case}
			End
			Else Done := True;
		Until ( Done ) or ( Carrier=False );
		CrLf;
		CrLf;
	End;

	Procedure About;
	Begin
		CrLf;
		EchoSE( '*************************************' );
		EchoSE( '* Express BBS File Transfer Utility *' );
		EchoSE( '*   Version 2.11    Jan 06, 1993    *' );
		EchoSE( '*      Written By Jay L. Bray       *' );
		EchoSE( '*************************************' );
		CrLf;
	End;

	Procedure Chk_Registration;
	Var
		B, B1, B2, B3 : Byte;
		X, W, Un : Integer;
		L1, L2, A1, A2 : Long_Integer;
	Begin
		L1 := Proc_Addr( Dummy_Routine );
		L2 := L1 + 62; { 126 w/debug or 62 w/o }
		X := 0;
		Repeat
			A1 := L2 + X;  A2 := A1 + 1;
			W := ( Peek( A1 ) * 256 ) + Peek( A2 );
			W := Xor ( W, 1234 );
			W := Xor ( W, 4321 );
			B := ( W & 255 );  Poke ( A2, B );
			B := Shr( W, 8 );  Poke ( A1, B );
			X := X + 2
		Until ( X = 46 );
		B1 := Peek ( L1+37 );  B2 := Peek ( L1+45 );  B3 := Peek ( L1+53 );
		Un := ( B1 * 100 ) + ( B2 * 10 ) + B3;
		Dummy_Routine;
		EchoSE ( Line );
	End;

Begin
	Io_check( False );
	Rez := Get_Rez;
	SetDta( DTA_Data );
	Boot_Drv := CurDisk;
	GetDir( Boot_Path, 0 );
	Zero_Timer;
	Timeon := Get_Timer;
	BM_Num := 0;

	Shw_Time   := True;    Chat    := False;   Color := False;
	VT52       := False;   Local   := False;
	Batch_Down := False;   V_Color := False;
	ANSI       := False;   A_Color := False;

	If ( Cmd_Args <> 7 ) Then Begin
		WriteLn( 'Invalid number of command line parameters.' );
		WriteLn( 'Usage:' );
		WriteLn( 'Ftu_200 Offset Baud Handle User# VW Time_Left Translation' );
		Halt;
	End;
	Shrink_Scrn( 5 );
	Clear_Screen;

	Cmd_Getarg( 1, Line );
	Cmd_Getarg( 2, Baudrate );
	Cmd_Getarg( 3, U_Handle );
	Cmd_Getarg( 4, Number );
	Cmd_Getarg( 5, Width );
	Cmd_Getarg( 6, Time_left );
	Cmd_Getarg( 7, Translation );  { 0= Ascii, 1 = Mono, 2 = Color }
	For M := 1 To Length( U_Handle ) Do Begin
		If ( U_Handle[ M ] = Chr(160) ) Then U_Handle[ M ] := ' ';
	End;

	Readv( Line, Ftu_Length );
	If Baudrate = '19200' Then Local := True;
	If Baudrate = '14.4' Then Baudrate := '14400';
	Readv( Baudrate, Speed );  Cps := ( Speed Div 10 );
	Readv( Number, Usr_No );
	Readv( Width, WidT );
	Readv( Time_left, Minutes );
	Readv( Translation, Transv );

	If ( Transv = 1 ) or ( Transv = 2 ) Then VT52 := True;
	If ( Transv = 2 ) Then V_Color := True;
	If ( Transv = 3 ) or ( Transv = 4 ) Then ANSI := True;
	If ( Transv = 4 ) Then A_Color := True;
	EchoSE( 'Loading...' );

	Trans[0] := ' Ascii  ';  Trans[1] := ' VT52 M ';
	Trans[2] := ' VT52 C ';  Trans[3] := ' Ansi M ';
	Trans[4] := ' Ansi C ';

	Prompt := '>';
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
	Err[68]:= 'Oops, YOU Messed Up!!!';
	Err[70]:= 'Unknown Error';

	Xyz[0] := 'XYZ.TTP Not Located In BBS Path...';
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
	Xyz[23]:= 'Modem carrier lost';
	Xyz[24]:= 'Batch mode disabled -- file skipped';

	ArcType[1] := ' Stored   ';   ArcType[2] := ' Packed   ';
	ArcType[3] := ' Squeezed ';   ArcType[4] := ' Crunched ';
	ArcType[5] := ' Squashed ';   ArcType[6] := ' <<Dir>>  ';
	ArcType[7] := ' Unknown  ';

	ZipType[1] := ' Stored   ';   ZipType[2] := ' Shrunk   ';
	ZipType[3] := ' Reduced  ';   ZipType[4] := ' Imploded ';
	ZipType[5] := ' Unknown  ';

	SitType[1] := ' None     ';   SitType[2] := ' RLE      ';
	SitType[3] := ' LZW      ';   SitType[4] := ' Huffman  ';
	SitType[5] := ' * None   ';   SitType[6] := ' * RLE    ';
	SitType[7] := ' * LZW    ';   SitType[8] := ' * Huff   ';
	SitType[9] := ' <<Dir>>  ';   SitType[10]:= ' Unknown  ';

	Lin_Count := 0;
	Tot_DL_Time := 0;
	F_Name[1] := Chr( Ord( 'A' ) + Boot_Drv );
	F_Name[2] := ':' ;
	F_Name[0] := chr( 2 );
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
	Show_Top5;
	Clear_Screen;
	Show_File( Ftu_Path );

	Usr_Addr := Find_User_Addr;
	Get_SysData;
	Get_Ftu_User;
	Get_Sig_Access;

	Show_UInfo;
	If ( Max_Sig=0 ) Then Begin
		CrLf;
		EchoSE( 'Sorry, You Can''t Access The Files Yet!!!' );
		Press_Any;
	End
	Else Begin
		Show_DL_UL;
		Show_File( F_Name );
		CrLf;
		Chk_Registration;
		New_Dls := 0;  New_Uls := 0;
		Caps := False;
		Quick_Scan := False;
		Forced_Off := False;
		Valid_New := False;
		DescL[1] := ' ';
		DescL[2] := Concat( 'Entered FTU At: ', Mil_Time );
		Log( 2 );
		About;
		If ( Get_2nd_Reg ) Then Begin
			Menu;
			Put_Usr( Addr( UserRec ), Usr_Addr, SizeOf( UserRec ) );
		End
		Else Begin
			DescL[1] := '****************************************************';
			DescL[2] := 'FTU HAS RAN BEYOND IT''S 30 DAY FREE TRIAL PERIOD!!!';
			DescL[3] := '****************************************************';
			Log( 3 );
		End;
		DescL[1] := Concat( 'Exited FTU At: ', Mil_Time );
		DescL[2] := ' ';
		Log( 2 );
	End;
	Dummy_I := ChDir( Boot_Path );
	Io_check( True );
	Shrink_Scrn( 1 );
End.

