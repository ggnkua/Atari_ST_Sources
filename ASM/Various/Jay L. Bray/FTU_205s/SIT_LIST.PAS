	{$E+}
	{====================================}
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
				Writev( Temp, File_Name, ' Isn''t A Valid Sit File...');
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
						Writev( Temp, File_Name, ' Isn''t A Valid Sit File...');
						EchoSE( Temp );
						Aborted := True;
					End;
				If (Aborted = False) Then Begin
					Writev( Temp, '>> Verbose Listing of ', File_Name:12, ' <<' );
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

