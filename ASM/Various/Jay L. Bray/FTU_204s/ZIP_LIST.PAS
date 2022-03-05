	{$E+}
	{====================================}
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
			Writev( Temp, '>> Verbose Listing of ', File_Name:12, ' <<' );
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
								Writev( Temp, File_Name, ' Isn''t A Valid Zip File...' );
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

