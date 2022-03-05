{$S8}
Program UPDT_SIG;
{$I D:\Pascal\Per_Pasc\AuxSubs.Pas}

Type

	SigData1 = Packed Record
 		Sigcount : Packed Array[0..31] Of Integer;
 		Names    : Packed Array[0..1023] Of String[30];
 		Paths    : Packed Array[0..1023] Of String[60];
		Show_Free: Packed Array[0..1023] Of Boolean;
		Use_Desc : Packed Array[0..1023] Of Boolean;
		Temp_Path: String[60];
	End;

	SigData2 = Packed Record
 		TSigcount: Integer;
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

Var

	System2 : SigData2;
	System1 : SigData1;

	Function FRead_Sys1(H:Integer; Count:Long_Integer; Var S:SigData1):Long_Integer;
	Gemdos( $3F );

	Function FWrite_Sys1(H:Integer; Count:Long_Integer; Var S:SigData1):Long_Integer;
	Gemdos( $40 );

	Function FRead_Sys2(H:Integer; Count:Long_Integer; Var S:SigData2):Long_Integer;
	Gemdos( $3F );

	Function FWrite_Sys2(H:Integer; Count:Long_Integer; Var S:SigData2):Long_Integer;
	Gemdos( $40 );

	Function Fseek( Where : Long_Integer ; FHandle, Mode: Integer ):Long_Integer;
		Gemdos($42); { Mode: 0=From Start, 1=from current pos, 2=from End }	


	Procedure Change_Data;
	Begin
 		System2.Sigcount  := System1.Sigcount;
 		System2.Names     := System1.Names;
 		System2.Paths     := System1.Paths;
		System2.Show_Free := System1.Show_Free;
		System2.Use_Desc  := System1.Use_Desc;
		System2.Temp_Path := System1.Temp_Path;
	End;

	Procedure Get_FTU_Sig;
	Var
		Sigdataftu : text;
		count : Long_Integer;
	Begin
		Reset( Sigdataftu, 'ftu_data.sig' );
		Count := Fseek( 0, Handle(SigdataFtu), 0);
		Count := FRead_Sys1( handle(sigdataftu), sizeof(system1), System1 );
		Close( SigDataFtu );
	End;

	Procedure Save_Ftu_Sig;
	Var
		Sigdataftu : text;
		X : Long_Integer;
	Begin
		ReWrite( SigDataFtu, 'ftu_data.sig' );
		X := FWrite_Sys2( Handle(SigDataFtu), SizeOf(System2), System2 );
		Close( SigDataFtu );
	End;

Begin									   (* Main Program Begins Here... *)
 	Get_Ftu_Sig;
	Change_Data;
	Save_Ftu_Sig;
End.

