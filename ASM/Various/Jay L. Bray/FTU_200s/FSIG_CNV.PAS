{$S30}
Program FSIG_Cnv;

Type

	SigData2O = Packed Record
		Sigcount  : Integer;
		Sig1      : Boolean;
		Pts_K     : Integer;
		Names     : Packed Array[ 1..256 ] Of String[30];
		Paths     : Packed Array[ 1..256 ] Of String[60];
		Show_Free : Packed Array[ 1..256 ] Of Boolean;
		Use_Desc  : Packed Array[ 1..256 ] Of Boolean;
		Desc_Path : Packed Array[ 1..256 ] Of String[60];
		Userlog   : String[60];
		LogFile   : String[60];
		Upld_Pth  : String[60];
	End;

	SigData2N = Packed Record
		Sigcount  : Integer;
		Sig1      : Boolean;
		Pts_K     : Integer;
		Names     : Packed Array[ 1..256 ] Of String[30];
		Paths     : Packed Array[ 1..256 ] Of String[60];
		Show_Free : Packed Array[ 1..256 ] Of Boolean;
		Use_Desc  : Packed Array[ 1..256 ] Of Boolean;
		Desc_Path : Packed Array[ 1..256 ] Of String[60];
		Userlog   : String[60];
		LogFile   : String[60];
		Upld_Pth  : String[60];
		Upload_Ok : Packed Array[ 1..256 ] Of Boolean;
		Free_Dnld : Packed Array[ 1..256 ] Of Boolean;
	End;

Var
	System2o   : SigData2o;
	System2n   : SigData2n;


	Function FRead_Sys2( H:Integer; Count:Long_Integer; Var S:SigData2o ):Long_Integer;
	Gemdos( $3F );

	Function FWrite_Sys2( H:Integer; Count:Long_Integer; Var S:SigData2n ):Long_Integer;
	Gemdos( $40 );

	Function Fseek( Where : Long_Integer ; FHandle, Mode: Integer ):Long_Integer;
		Gemdos( $42 ); { Mode: 0=From Start, 1=from current pos, 2=from End }	


	Procedure Get_SysData;
	Var
		FtuData : String;
		Sigdatafile : text;
		Count : Long_Integer;
	Begin
		FtuData := 'FTU_DATA.SIG';
		Reset( Sigdatafile, FtuData );
		Count := Fseek( 0, Handle( SigdataFile ),  0 );
		Count := FRead_Sys2( Handle( Sigdatafile ),  Sizeof( system2o ),  System2o );
		Close( Sigdatafile );
	End;

	Procedure Save_SysData;
	Var
		FtuData : String;
		Sigdatafile : text;
		Count : Long_Integer;
	Begin
		FtuData := 'FTU_DATA.SIG';
		Rewrite( Sigdatafile, FtuData );
		Count := Fseek( 0, Handle( SigdataFile ),  0 );
		Count := FWrite_Sys2( Handle( Sigdatafile ),  Sizeof( System2n ),  System2n );
		Close( Sigdatafile );
	End;

	Procedure Convert_FSigs;
	Var
		I, X : Integer;
		S : String;
	Begin
		Get_SysData;

		System2n.Sigcount  := System2o.Sigcount;
		System2n.Sig1      := System2o.Sig1;
		System2n.Pts_K     := System2o.Pts_K;
		System2n.Userlog   := System2o.Userlog;
		System2n.LogFile   := System2o.LogFile;
		System2n.Upld_Pth  := System2o.Upld_Pth;

		For I := 1 To 256 Do Begin
			System2n.Names     [ I ] := System2o.Names[ I ];
			System2n.Paths     [ I ] := System2o.Paths[ I ];
			System2n.Show_Free [ I ] := System2o.Show_Free[ I ];
			System2n.Use_Desc  [ I ] := System2o.Use_Desc[ I ];
			System2n.Desc_Path [ I ] := System2o.Desc_Path[ I ];
			X := Length( System2n.Paths[ I ] );
			S := Copy( System2n.Desc_Path[ I ], 1, X );
			If ( S = System2n.Paths[ I ] ) Then System2n.Upload_Ok[ I ] := True
			Else System2n.Upload_Ok[ I ] := False;
			System2n.Free_Dnld [ I ] := False;
		End;

		Save_SysData;
	End;

Begin
	Convert_FSIGS;
End.

