	{$E+}
	{====================================}
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
		H, RC, C  : Integer;
		X, Y, I   : Integer;
		P         : Long_Integer;
		TotalNow  : Long_Integer;
		TotalOrig : Long_Integer;
		Snumber,
		F_E,
		F_B       : String;
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
		If ( H < 0 ) Then EchoSE (' Unable To UnLzh That File...')
		Else Begin
			CrLf;
			Writev( F_B, '>> Verbose Listing of ', File_Name:12, ' <<' );
			EchoSE( F_B );
			CrLf;
			EchoSE( '  Filename    Length  Method  Size Now' );
			EchoSE( '------------ -------- ------- --------' );
			Repeat
				Tbytes := BlockRead( H, 2, Header.Buff );
				X := Header.Data[0];
				If ( X > 0 ) Then Tbytes := BlockRead( H, X, Header.Buff );
				If (Tbytes < X) Then Header.Data[0] := 0
				Else If Header.Data[0] = 45 Then         { valid header? }
				Else Begin
					If First then Begin
						Writev( F_B, File_Name, ' Isn''t A Valid Lzh File...');
						EchoSE( F_B );
					End;
					Header.Data[0] := 0;
				End;
				If Header.Data[0] > 0 then begin
					First := False;
					Y := 19;
					I := Header.Data[19]; F_B := '';
					For X := 1 to I Do Begin
						C := Header.Data[ Y + X ];
						If ( C <> 0 ) Then F_B := Concat( F_B, Chr( C ) );
					End;
					Extract_FileName( F_B, F_E );  Rc := Length( F_E );
					EchoS( F_E );
					For I := 1 to (13 - Rc) do EchoS (' ');
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
					For I := 0 to 4 do EchoS( Chr(Header.Data[I] ));
					EchoS( '  ' );
					Writev( Snumber, LzhData.SizeNow:8 );
					EchoSE( Snumber );
					TotalNow  := TotalNow  + LzhData.SizeNow;
					TotalOrig := TotalOrig + LzhData.OrigSize;
					P := FSeek (LzhData.SizeNow, H, 1);         { from curr. pos }
					If ( P<0 ) Then	Bad_File := True;
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
	End;

