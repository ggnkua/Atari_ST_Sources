{$M+, E+}
Program Arc_List;

{$I Auxsubs.Pas}
{$I Gemsubs.Pas}

Const
{$I BBS_Con.Pas}

Type
{$I BBS_Type.Pas}

Var
{$I BBS_Var.Pas}

(*	Procedure CrLf; External;
	Procedure EchoS ( S:String ); External;
	Procedure EchoSE( S:String ); External;
	Function Carrier: Boolean; External;
	Procedure MakeCstring( Var S: String; Var D: Cstring ); External; *)

	Function Open_File( Var P: Cstring; Md: Integer ):Integer;
		GemDos($3D);  { Md: 0=Read Only, 1=Write Only, 2=Read & Write}

	Function Close_File( H: Integer ):Integer;
		GemDos($3E);

	Function BlockRead( H: Integer; Sz: Long_Integer; Var Loc: BlockIO ):Long_Integer;
		GemDos($3F);

	Function Fseek( Where: Long_Integer ; FHandle, Mode: Integer ):Long_Integer;
		Gemdos($42);  { Mode: 0=From Start, 1=from current pos, 2=from End }

	Procedure List_ARC( S: String );

	Type ArcD = Packed Record
		Case Integer of
			1: (Buffer   : Packed Array[0..7] of Byte);
			2: (SizeNow  : Long_Integer; OrigSize : Long_Integer);
		End;

	ArcHdr = Packed Record
		Case Integer of
			1 : (Data: Packed Array[0..50] of Byte);
			2 : (Buff: BlockIO);
	End;

	Var
		Header    : ArcHdr;
		ArcData   : ArcD;
		Bad_File  : Boolean;
		Aborted   : Boolean;
		First     : Boolean;
		Tbytes    : Integer;
		H, RC     : Integer;
		X, Y      : Integer;
		P         : Long_Integer;
		TotalNow  : Long_Integer;
		TotalOrig : Long_Integer;
		Snumber, Temp : String;
		F         : CString;

	Begin
		Bad_File := False;
		First := True;
		Aborted := False;
		TotalNow  := 0;
		TotalOrig := 0;
		CrLf;
		MakeCString( S, F );
		H := Open_File( F, Input_Mode);
		If H < 0 then
			EchoSE (' Unable To UnArc That File...')
		Else
			CrLf;
			Writev( Temp, '>> Verbose Listing of ', F_Name:12, ' <<' );
			EchoSE( Temp );
			CrLf;
			EchoSE( '  Filename    Length  Stowage  Size Now' );
			EchoSE( '------------ -------- -------- --------' );
		Repeat
			Tbytes := BlockRead (H, 29, Header.Buff);
			If (Tbytes < 29) then
				Header.Data[0] := 0
			Else
				If (Header.Data[0] in [0,$1A]) and         { valid header? }
					(Header.Data[1] > 0) then
				Else
					Begin
						If First then Begin
							Writev( Temp, F_Name, ' Isn''t A Valid ARC File...');
							EchoSE( Temp );
						End;
						Header.Data[0] := 0;
					End;
				First := False;
				If Header.Data[0] > 0 then begin
					X := 2;
					While (Header.Data[X] <> 0) and (X < 14) do begin
					EchoS( Chr(Header.Data[X] ));
					X := X + 1;
				End;
				For Y := 1 to (15 - X) do
				EchoS (' ');
				ArcData.Buffer[0] := Header.Data[18];
				ArcData.Buffer[1] := Header.Data[17];
				ArcData.Buffer[2] := Header.Data[16];
				ArcData.Buffer[3] := Header.Data[15];
				ArcData.Buffer[4] := Header.Data[28];
				ArcData.Buffer[5] := Header.Data[27];
				ArcData.Buffer[6] := Header.Data[26];
				ArcData.Buffer[7] := Header.Data[25];
				Writev( Snumber, ArcData.OrigSize:8 );
				EchoS( Snumber );
				X := Header.Data[1];
				If (X>0) And (X<3) Then X:=1
				Else If X=3 Then X:=2
				Else If X=4 Then X:=3
				Else If (X>4) And (X<9) Then X:=4
				Else If X=9 Then X:=5
				Else If X=30 Then X:=6
				Else X:=7;
				EchoS( ArcType[X] );
				Writev( Snumber, ArcData.SizeNow:8 );
				EchoSE( Snumber );
				TotalNow  := TotalNow  + ArcData.SizeNow;
				TotalOrig := TotalOrig + ArcData.OrigSize;
				P := FSeek (ArcData.SizeNow, H, 1);         { from curr. pos }
				If P < 0 then Bad_File := True;
			End;
		Until (Header.Data[0]=0) or (Aborted) or (Carrier=False) or (Bad_File);
		RC := Close_File( H );
		If (Bad_File) Then EchoSE( ' Unexpected End Of File...' );
		If (TotalNow > 0) and (Aborted=False) and (Carrier) then begin
			EchoSE( '------------ -------- -------- --------' );
			EchoS( '   Totals    ' );
			Writev( Snumber, TotalOrig:8 );
			EchoS( Snumber );
			EchoS('          ');
			Writev( Snumber, TotalNow:8 );
			EchoSE( Snumber );
			CrLf;
		End;
	End;

	Procedure List_Lzh( S: String );

	Type LzhD = Packed Record
		Case Integer of
			1: (Buffer   : Packed Array[0..7] of Byte);
			2: (SizeNow  : Long_Integer; OrigSize : Long_Integer);
		End;

	LzhHdr = Packed Record
		Case Integer of
			1 : (Data: Packed Array[0..50] of Byte);
			2 : (Buff: BlockIO);
	End;

	Var
		Header    : LzhHdr;
		LzhData   : LzhD;
		Aborted   : Boolean;
		First     : Boolean;
		Bad_File  : Boolean;
		Tbytes    : Integer;
		H, RC     : Integer;
		X, Y, I   : Integer;
		P         : Long_Integer;
		TotalNow  : Long_Integer;
		TotalOrig : Long_Integer;
		Snumber, Temp : String;
		F         : CString;

	Begin
		Bad_File := False;
		First := True;
		Aborted := False;
		TotalNow  := 0;
		TotalOrig := 0;
		CrLf;

		MakeCString( S, F );
		H := Open_File( F, Input_Mode);
		If H < 0 then
			EchoSE (' Unable To UnLzh That File...')
		Else
			CrLf;
			Writev( Temp, '>> Verbose Listing of ', F_Name:12, ' <<' );
			EchoSE( Temp );
			CrLf;
			EchoSE( '  Filename    Length  Method  Size Now' );
			EchoSE( '------------ -------- ------- --------' );
		Repeat
			Tbytes := BlockRead( H, 2, Header.Buff );
			X := Header.Data[0];
			IF X = 0 Then
			Else
				Tbytes := BlockRead( H, X, Header.Buff );
				If (Tbytes < X) then
					Header.Data[0] := 0
				Else
					If Header.Data[0] = 45 Then         { valid header? }
					Else
						Begin
						If First then Begin
							Writev( Temp, F_Name, ' Isn''t A Valid Lzh File...');
							EchoSE( Temp );
						End;
						Header.Data[0] := 0;
					End;
				If Header.Data[0] > 0 then begin
					First := False;
					Y := 20;
					I := Header.Data[19];
					Rc:= I;
					While (Header.Data[Y] <> 0) and (I >0 ) do begin
						EchoS( Chr(Header.Data[Y] ));
						Y := Y + 1;
						I := I - 1;
					End;
					For I := 1 to (13 - Rc) do
					EchoS (' ');
					LzhData.Buffer[0] := Header.Data[8];
					LzhData.Buffer[1] := Header.Data[7];
					LzhData.Buffer[2] := Header.Data[6];
					LzhData.Buffer[3] := Header.Data[5];
					LzhData.Buffer[4] := Header.Data[12];
					LzhData.Buffer[5] := Header.Data[11];
					LzhData.Buffer[6] := Header.Data[10];
					LzhData.Buffer[7] := Header.Data[9];
					Writev( Snumber, LzhData.OrigSize:8 );
					EchoS( Snumber );
					EchoS( '  ' );
					For I := 0 to 4 do
						EchoS( Chr(Header.Data[I] ));
					EchoS( '  ' );
					Writev( Snumber, LzhData.SizeNow:8 );
					EchoSE( Snumber );
					TotalNow  := TotalNow  + LzhData.SizeNow;
					TotalOrig := TotalOrig + LzhData.OrigSize;
					P := FSeek (LzhData.SizeNow, H, 1);         { from curr. pos }
					If P < 0 then	Bad_File := True;
				End;
		Until (Header.Data[0]=0) or (Aborted) or (Carrier=False) or (Bad_File);
		RC := Close_File( H );
		If (Bad_File) Then EchoSE( ' Unexpected End Of File...' );
		If (TotalNow > 0) and (Aborted=False) and (Carrier) then begin
			EchoSE( '------------ -------- ------- --------' );
			EchoS( '   Totals    ' );
			Writev( Snumber, TotalOrig:8 );
			EchoS( Snumber );
			EchoS('         ');
			Writev( Snumber, TotalNow:8 );
			EchoSE( Snumber );
			CrLf;
		End;
	End;

	Procedure List_Sit( S: String );

	Type SitD = Packed Record
		Case Integer of
			1: (Buffer     : Packed Array[0..23] of Byte);
			2: (SType      : Long_Integer;
				SCrea        : Long_Integer;
				RsrcOrigSize : Long_Integer;
				DataOrigSize : Long_Integer;
				RsrcSizeNow  : Long_Integer;
				DataSizeNow  : Long_Integer);
		End;

	SitHdr = Packed Record
		Case Integer of
			1 : (Data: Packed Array[0..150] of Byte);
			2 : (Buff: BlockIO);
	End;

	Var
		Header    : SitHdr;
		SitData   : SitD;
		EOS       : Boolean;
		Aborted   : Boolean;
		Bad_File  : Boolean;
		B, C1, C2 : Byte;
		Tbytes    : Integer;
		H, RC     : Integer;
		X, Y, I   : Integer;
		P, Z      : Long_Integer;
		TotalNow  : Long_Integer;
		TotalOrig : Long_Integer;
		Snumber, Temp : String;
		F         : CString;

	Begin
		EOS := False;
		Bad_File := False;
		Aborted := False;
		TotalNow  := 0;
		TotalOrig := 0;
		CrLf;
		MakeCString( S, F );
		H := Open_File( F, Input_Mode);
		If H < 0 then
			EchoSE (' Unable To UnSit That File...')
		Else
			CrLf;
			Tbytes := BlockRead (H, 150, Header.Buff);
			If (Tbytes < 150) then Begin
				Writev( Temp, F_Name, ' Isn''t A Valid Sit File...');
				EchoSE( Temp );
				Aborted := True;
			End;
			If (Aborted = False) Then Begin
				SitData.Buffer[0] := Header.Data[65];   { Type }
				SitData.Buffer[1] := Header.Data[66];
				SitData.Buffer[2] := Header.Data[67];
				SitData.Buffer[3] := Header.Data[68];
				SitData.Buffer[4] := Header.Data[69];   { Creator }
				SitData.Buffer[5] := Header.Data[70];
				SitData.Buffer[6] := Header.Data[71];
				SitData.Buffer[7] := Header.Data[72];
				P := $53495421;
				If ( SitData.SType <> P ) And ( SitData.SCrea <> P ) Then
					Begin
						Writev( Temp, F_Name, ' Isn''t A Valid Sit File...');
						EchoSE( Temp );
						Aborted := True;
					End;
				If (Aborted = False) Then Begin
					Writev( Temp, '>> Verbose Listing of ', F_Name:12, ' <<' );
					EchoSE( Temp );
					CrLf;
					EchoSE( 'Name  Fork  Length    Stowage  Size Now' );
					EchoSE( '----  ----  -------- --------- --------' );
					Repeat
						Tbytes := BlockRead (H, 112, Header.Buff);
						If (Tbytes < 112) then EOS := True;
						B := Header.Data[2];
						If (EOS=False) And (B>0) then Begin
							SitData.Buffer[8] := Header.Data[84];   { Rcsc Orig Size }
							SitData.Buffer[9] := Header.Data[85];
							SitData.Buffer[10] := Header.Data[86];
							SitData.Buffer[11] := Header.Data[87];
							SitData.Buffer[12] := Header.Data[88];  { Data Orig Size }
							SitData.Buffer[13] := Header.Data[89];
							SitData.Buffer[14] := Header.Data[90];
							SitData.Buffer[15] := Header.Data[91];
							SitData.Buffer[16] := Header.Data[92];  { Rcsc Size Now }
							SitData.Buffer[17] := Header.Data[93];
							SitData.Buffer[18] := Header.Data[94];
							SitData.Buffer[19] := Header.Data[95];
							SitData.Buffer[20] := Header.Data[96];  { Data Size Now }
							SitData.Buffer[21] := Header.Data[97];
							SitData.Buffer[22] := Header.Data[98];
							SitData.Buffer[23] := Header.Data[99];
							C1 := Header.Data[0];
							C2 := Header.Data[1];
							If ((C1<4) or (C1=32) or ((C1>15) And (C1<20))) And
								((C2<4) or (C2=32) or ((C2>15) And (C2<20))) Then Begin
								Y := 3;
								For I := 1 to B do Begin
									EchoS( Chr(Header.Data[Y] ));
									Y := Y + 1;
								End;
								CrLf;
								EchoS( '    Rsrc -> ' );
								Writev( Snumber, SitData.RsrcOrigSize:8 );
								EchoS( Snumber );
								If C1 = 0 Then X := 1
								Else If C1 = 1 Then X := 2
								Else If C1 = 2 Then X := 3
								Else If C1 = 3 Then X := 4
								Else If C1 = 16 Then X := 5
								Else If C1 = 17 Then X := 6
								Else If C1 = 18 Then X := 7
								Else If C1 = 19 Then X := 8
								Else If C1 = 32 Then X := 9
								Else X := 10;
								EchoS( SitType[X] );
								EchoS( ' ' );
								Writev( Snumber, SitData.RsrcSizeNow:8 );
								EchoSE( Snumber );
								EchoS( '    Data -> ' );
								Writev( Snumber, SitData.DataOrigSize:8 );
								EchoS( Snumber );
								If C2 = 0 Then X := 1
								Else If C2 = 1 Then X := 2
								Else If C2 = 2 Then X := 3
								Else If C2 = 3 Then X := 4
								Else If C2 = 16 Then X := 5
								Else If C2 = 17 Then X := 6
								Else If C2 = 18 Then X := 7
								Else If C2 = 19 Then X := 8
								Else If C2 = 32 Then X := 9
								Else X := 10;
								EchoS( SitType[X] );
								EchoS( ' ' );
								Writev( Snumber, SitData.DataSizeNow:8 );
								EchoSE( Snumber );
								TotalNow  := TotalNow  + SitData.RsrcSizeNow + SitData.DataSizeNow;
								TotalOrig := TotalOrig + SitData.RsrcOrigSize + SitData.DataOrigSize;
								Z := SitData.RsrcSizeNow + SitData.DataSizeNow;
								P := FSeek ( Z, H, 1);         { from curr. pos }
								If P < 0 then Bad_File := True;
							End;
						End;
					Until (EOS) or (Carrier=False) or (Bad_File);
				End;
			End;
			RC := Close_File( H );
			If (Bad_File) Then EchoSE( ' Unexpected End Of File...' );
			If (EOS) and (Aborted=False) and (Carrier) then begin
				EchoSE( '----  ----  -------- --------- --------' );
				EchoS( '  Totals    ' );
				Writev( Snumber, TotalOrig:8 );
				EchoS( Snumber );
				EchoS('           ');
				Writev( Snumber, TotalNow:8 );
				EchoSE( Snumber );
				CrLf;
			End;
	End;

	Procedure List_Zip( S: String );

	Type ZipD = Packed Record
		Case Integer of
			1: (Buffer  : Packed Array[0..17] of Byte);
			2: (PK_Hdr  : Long_Integer;
				SizeNow   : Long_Integer;
				OrigSize  : Long_Integer;
				File_Len  : Integer;
				Field_Len : Integer;
				Method    : Integer);
		End;

	ZipHdr = Packed Record
		Case Integer of
			1 : (Data: Packed Array[0..30] of Byte);
			2 : (Buff: BlockIO);
	End;

	Var
		Header    : ZipHdr;
		ZipData   : ZipD;
		Aborted   : Boolean;
		First     : Boolean;
		Bad_File  : Boolean;
		Tbytes    : Integer;
		H, RC     : Integer;
		X, Y, I   : Integer;
		P         : Long_Integer;
		TotalNow  : Long_Integer;
		TotalOrig : Long_Integer;
		Snumber, Temp : String;
		F         : CString;

	Begin
		Bad_File := False;
		First := True;
		Aborted := False;
		TotalNow  := 0;
		TotalOrig := 0;
		CrLf;

		MakeCString( S, F );
		H := Open_File( F, Input_Mode);
		If H < 0 then
			EchoSE (' Unable To UnZip That File...')
		Else
			CrLf;
			Writev( Temp, '>> Verbose Listing of ', F_Name:12, ' <<' );
			EchoSE( Temp );
			CrLf;
			EchoSE( '  Filename    Length   Stowage  Size Now' );
			EchoSE( '------------ -------- --------- --------' );
			Repeat
				Tbytes := BlockRead( H, 30, Header.Buff );
				If (Tbytes < 30) then
					Header.Data[0] := 0
				Else
					ZipData.Buffer[0] := Header.Data[0];  { PK Header }
					ZipData.Buffer[1] := Header.Data[1];
					ZipData.Buffer[2] := Header.Data[2];
					ZipData.Buffer[3] := Header.Data[3];
					ZipData.Buffer[4] := Header.Data[21]; { Size Now }
					ZipData.Buffer[5] := Header.Data[20];
					ZipData.Buffer[6] := Header.Data[19];
					ZipData.Buffer[7] := Header.Data[18];
					ZipData.Buffer[8] := Header.Data[25]; { Orig Size }
					ZipData.Buffer[9] := Header.Data[24];
					ZipData.Buffer[10]:= Header.Data[23];
					ZipData.Buffer[11]:= Header.Data[22];
					ZipData.Buffer[12]:= Header.Data[27]; { Filename Len }
					ZipData.Buffer[13]:= Header.Data[26];
					ZipData.Buffer[14]:= Header.Data[29]; { Extra Field Len }
					ZipData.Buffer[15]:= Header.Data[28];
					ZipData.Buffer[16]:= Header.Data[9];  { Compression Method }
					ZipData.Buffer[17]:= Header.Data[8];
					If ZipData.PK_Hdr = $504b0304 Then    { valid header? }
					Else
						Begin
							If (First) Then Begin
								Writev( Temp, F_Name, ' Isn''t A Valid Zip File...' );
								EchoSE( Temp );
							End;
							Header.Data[0] := 0;
						End;
					If Header.Data[0] > 0 then Begin
						First := False;
						Rc := ZipData.File_Len;
						X := Rc + ZipData.Field_Len;
						Tbytes := BlockRead( H, X, Header.Buff );
						If Tbytes = X Then Begin
							Y := 0;
							For I := 0 to Rc-1 do
								EchoS( Chr(Header.Data[I] ));
							For I := 0 to (12 - Rc) do
							EchoS (' ');
							Writev( Snumber, ZipData.OrigSize:8 );
							EchoS( Snumber );
							Y := ZipData.Method;
							If Y = 0 Then X := 1
							Else If Y = 1 Then X := 2
							Else If (Y>1) And (Y<6) Then X := 3
							Else If Y = 6 Then X := 4
							Else Y := 5;
							EchoS( ZipType[X]);
							EchoS( ' ' );
							Writev( Snumber, ZipData.SizeNow:8 );
							EchoSE( Snumber );
							TotalNow  := TotalNow  + ZipData.SizeNow;
							TotalOrig := TotalOrig + ZipData.OrigSize;
							P := FSeek (ZipData.SizeNow, H, 1);         { from curr. pos }
							If P < 0 then Bad_File := True;
						End
						Else Bad_File := True;
					End;
			Until (Header.Data[0]=0) or (Aborted) or (Carrier=False) or (Bad_File);
			RC := Close_File( H );
			If (Bad_File) Then EchoSE( ' Unexpected End Of File...' );
			If (Aborted=False) and (Carrier) then begin
				EchoSE( '------------ -------- --------- --------' );
				EchoS( '   Totals    ' );
				Writev( Snumber, TotalOrig:8 );
				EchoS( Snumber );
				EchoS('           ');
				Writev( Snumber, TotalNow:8 );
				EchoSE( Snumber );
				CrLf;
			End;
	End;

Begin
; { Dummy }
End.
