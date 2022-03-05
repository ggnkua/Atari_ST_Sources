{$S40}
Program SysData_Converter;

	{$I gemsubs.pas}

Type
 	Cstring = Packed Array[1..80] Of Char;

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

	SysDataNew = Packed Record
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
{ =========================== New Additions ================== }
		FMail_Path     : string [60];
		FMail_Days     : Byte;
		Prot_Names     : Packed Array [1..10] of string [20];
		Prot_Paths     : Packed Array [1..10] of string [60];
		Prot_Up_Parms  : Packed Array [1..10] of string [15];
		Prot_Dn_Parms  : Packed Array [1..10] of string [15];
		Use_Prot_UL    : Packed Array [1..10] of Boolean;
		Use_Prot_DL    : Packed Array [1..10] of Boolean;
{ ============================================================= }
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

Var

	Sys_DataO  : SysdataOld;
	Sys_DataN  : SysdataNew;
	SysData_Path,
	P_Path,
	Work_Path  : Path_Name;
	Path       : Cstring;
	SysData_File : Text;

	Function Dgetdrv : Integer ;
		Gemdos( $19 ) ;

	Procedure Dgetpath( Var Path_Buf : Cstring ; Drive : Integer ) ;
		Gemdos( $47 ) ;

	Procedure C_To_PPath( C_Path : Cstring ; Var P_Path : Path_Name ) ;
	Var
		I : Integer;
	Begin
		I := 1 ;
		While (C_Path[I] <> Chr(0)) And (C_Path[I] <>' ') And ( I<=80 ) Do Begin
			P_Path[I] := C_Path[I]; 
			I := I + 1;
		End;
	P_Path[0] := Chr( I - 1 );
	End;

	Function Lseek( Where : Long_Integer ; FHandle, Mode: Integer ):Long_Integer;
		Gemdos($42);

	Function FRead_Sys(H:Integer; Count:Long_Integer; Var S:SysDataOld):Long_Integer;
	Gemdos( $3F ); 

	Function FWrite_Sys(H:Integer; Count:Long_Integer; Var S:SysDataNew):Long_Integer;
	Gemdos( $40 );

{	Function FCreate( Var N:SysData_Path; A:Integer ):Short_Integer;}

	Procedure Read_File;
	Var
		X : Integer;
		Sys_Name, Temp : string;
	Begin
		Sys_Name := 'SYSDATA.DAT';
		SysData_Path := Concat( Work_Path, Sys_Name );
		If Get_In_File( SysData_Path, Sys_Name ) Then Begin
			Reset( SysData_File, Sys_Name );
			X := Lseek( 0, Handle(SysData_File), 0);
			X := FRead_Sys( Handle(SysData_File), Sizeof(Sys_DataO), Sys_DataO );
			Close( SysData_File );
		End;
	End;

	Procedure Save_File;
	Var
		X : Integer;
		Sys_Name, Temp : string;
	Begin
		Sys_Name := 'SYSDATA.DAT';
		SysData_Path := Concat( Work_Path, Sys_Name );
		Reset( SysData_File, Sys_Name );
		X := Lseek( 0, Handle(SysData_File), 0);
		X := FWrite_Sys( Handle(SysData_File), Sizeof(Sys_DataN), Sys_DataN );
		Close( SysData_File );
	End;

	Procedure Convert_Sysdata;
	Begin
	Sys_DataN.Hi_Msg := Sys_DataO.Hi_Msg;
	Sys_DataN.Todays_Date := Sys_DataO.Todays_Date;
	Sys_DataN.Total_Calls := Sys_DataO.Total_Calls;
	Sys_DataN.Calls_Today := Sys_DataO.Calls_Today;
	Sys_DataN.Feedback_Mode := Sys_DataO.Feedback_Mode;
	Sys_DataN.Total_Msg_Bases := Sys_DataO.Total_Msg_Bases;
	Sys_DataN.Min_Baud_Rate := Sys_DataO.Min_Baud_Rate;
	Sys_DataN.Max_Baud_Rate := Sys_DataO.Max_Baud_Rate;
	Sys_DataN.Start_Baud_Rate := Sys_DataO.Start_Baud_Rate;
	Sys_DataN.Secondary_Pword := Sys_DataO.Secondary_Pword;
	Sys_DataN.Message_Path := Sys_DataO.Message_Path;
	Sys_DataN.UserLog_Path := Sys_DataO.UserLog_Path;
	Sys_DataN.HelpFile_Path := Sys_DataO.HelpFile_Path;
	Sys_DataN.Help40_Path := Sys_DataO.Help40_Path;
	Sys_DataN.LogFile := Sys_DataO.LogFile;
	Sys_DataN.Message_Drives := Sys_DataO.Message_Drives;
	Sys_DataN.Num_Of_Sigs := Sys_DataO.Num_Of_Sigs;
	Sys_DataN.Sig_Name := Sys_DataO.Sig_Name;
	Sys_DataN.Sig_Path := Sys_DataO.Sig_Path;
	Sys_DataN.Sig_Desc := Sys_DataO.Sig_Desc;
	Sys_DataN.Sig_Show_Free := Sys_DataO.Sig_Show_Free;
	Sys_DataN.MC_User_Cmd := Sys_DataO.MC_User_Cmd;
	Sys_DataN.MC_BBS_Cmd := Sys_DataO.MC_BBS_Cmd;
	Sys_DataN.MC_Sec_Lvl := Sys_DataO.MC_Sec_Lvl;
	Sys_DataN.MC_Disp_Str := Sys_DataO.MC_Disp_Str;
	Sys_DataN.MC_File_View := Sys_DataO.MC_File_View;
	Sys_DataN.Hi_Msg := Sys_DataO.Hi_Msg;
	Sys_DataN.BC_User_Cmd := Sys_DataO.BC_User_Cmd;
	Sys_DataN.BC_BBS_Cmd := Sys_DataO.BC_BBS_Cmd;
	Sys_DataN.BC_Sec_Lvl := Sys_DataO.BC_Sec_Lvl;
	Sys_DataN.BC_Disp_Str := Sys_DataO.BC_Disp_Str;
	Sys_DataN.BC_File_View := Sys_DataO.BC_File_View;
	Sys_DataN.TC_Idx := Sys_DataO.TC_Idx;
	Sys_DataN.TC_Name := Sys_DataO.TC_Name;
	Sys_DataN.TC_Baud := Sys_DataO.TC_Baud;
	Sys_DataN.TC_Date := Sys_DataO.TC_Date;
	Sys_DataN.TC_On_At := Sys_DataO.TC_On_At;
	Sys_DataN.TC_Off_At := Sys_DataO.TC_Off_At;
	Sys_DataN.Keep_New_Flag := Sys_DataO.Keep_New_Flag;
	Sys_DataN.Allow_DL_Over_TL := Sys_DataO.Allow_DL_Over_TL;
	Sys_DataN.Allow_Handles := Sys_DataO.Allow_Handles;
	End;

	Begin
		IF Init_Gem <> -1 THEN Begin
			Work_Path[1] := Chr( ord('A') + Dgetdrv );
			Work_Path[2] := ':';
			Work_Path[0] := Chr(2);
			Dgetpath( Path, 0 ) ;
			C_To_PPath(Path, P_Path);
	    Work_Path := ConCat( Work_Path, P_Path );
			Work_Path := Concat( Work_Path, '\' );
			Init_Mouse;
			Set_Mouse( M_Arrow );
			Read_File;
			Convert_SysData;
			Save_File;
			Exit_Gem;
		End;
	End.


