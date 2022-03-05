{$S16}
Program FTU_INIT;
{$I D:\Pascal\Per_Pasc\AuxSubs.Pas}

Const
	Console = 2;
	Cr  = 13;
	Lf  = 10;
	Esc = 27;
Type

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
		
 	Sysdata = Packed Record
 		Hi_Msg   : Integer;
 		Date     : String[8];
		Tot_Calls: Long_Integer;
		Cls_Today: Integer;
		FeedBack : Byte;
		Tot_MsgB : Byte;
		Min_Bd   : Byte;
		Max_Bd   : Byte;
		Strt_Bd  : Byte;
 		Sysop    : String[15];
 		Msgbase  : String[60];
 		Upload_Pth : String[60];
 		FMail_Pth  : String[60];
 		Userlog  : String[60];
 		Menus80  : String[60];
 		Menus40  : String[60];
 		LogFile  : String[60];
 		Basemask : Packed Array[1..32] Of Byte;
 		Sigcount : Integer;
 		Names    : Array[1..32] Of String[30];
 		Paths    : Array[1..32] Of String[60];
 	End;
		
Var
 	System      : Sysdata;
	System2     : SigData2;
	UserAcs     : UserAccess;
	DTA_Data    : DTA;                { Blkio used For dir searches }
 	Userfilename: String[61];         { filename For the userfile }
	Usr_No      : Integer;

	Procedure SetDta( Var B: DTA );
		Gemdos($1A);

	Function FRead_Sys(H:Integer; Count:Long_Integer; Var S:SysData):Long_Integer;
		Gemdos( $3F ); 

	Function FWrite_Sys2(H:Integer; Count:Long_Integer; Var S:SigData2):Long_Integer;
		Gemdos( $40 );

	Function FWrite_Usr2(H:Integer; Count:Long_Integer; Var S:UserAccess):Long_Integer;
		Gemdos( $40 );

	Function Fseek( Where : Long_Integer ; FHandle, Mode: Integer ):Long_Integer;
		Gemdos($42); { Mode: 0=From Start, 1=from current pos, 2=from End }	

	Procedure Get_SysData;
	Var
		Sysdatafile : text;
		I, J : Integer;
		Temp : String;
		Ch : Char;
		count : Long_Integer;
	Begin
		Reset( sysdatafile, 'sysdata.dat' );
		Count := Fseek( 0, Handle(SysdataFile), 0);
		Count := FRead_Sys( handle(sysdatafile), sizeof(system), System );
		Close( sysdatafile );
		Userfilename := System.Userlog;
		System2.UserLog := System.UserLog;
		System2.LogFile := System.LogFile;
		System2.TsigCount := System.SigCount;
		System2.TNames := System.Names;
		System2.Upld_Pth := System.Upload_Pth;
	End;

	Procedure Make_New;
	Var
		X : Long_Integer;
		I, Users : Integer;
		Count : Long_Integer;
		SigDataFtu : Text;
		UsrDataFtu : Text;
		Sig_Mask   : Text;
		UserFile   : Text;
	Begin
   	Reset( Userfile, Userfilename );
   	X := Fseek( 0, Handle(Userfile), 2 );
   	Close( Userfile );
		Users := (X Div 292) - 1;
		Writeln( ' ' );
		WriteLn( 'Your UserData File Can Hold Up To ', Users-2, ' Users...' );
		Writeln( ' ' );
		Rewrite( UsrDataFtu, 'ftu_data.usr' );
		For I := 1 To Users Do
			Count := FWrite_Usr2( Handle(UsrDataFtu), SizeOf(UserAcs), UserAcs );
		Close( UsrDataFtu );

		Rewrite( Sig_Mask, 'ftu_data.msk' );
		For I := 1 To 10 Do
			Count := FWrite_Usr2( Handle(Sig_Mask), SizeOf(UserAcs), UserAcs );
		Close( Sig_Mask );

		ReWrite( SigDataFtu, 'ftu_data.sig' );
		Count := FWrite_Sys2( Handle(SigDataFtu), SizeOf(System2), System2 );
		Close( SigDataFtu );
	End;

Begin									   (* Main Program Begins Here... *)
	SetDta( DTA_Data );
 	Get_SysData;
	WriteLn( 'File Transfer Utility (FTU) Initializer' );
	WriteLn( ' ' );
	WriteLn( 'Creating FTU Data Files...' );
	Make_New;
	WriteLn( 'Done...' );
End.

