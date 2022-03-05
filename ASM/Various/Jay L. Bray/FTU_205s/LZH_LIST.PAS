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
			Writev( Temp, '>> Verbose Listing of ', File_Name:12, ' <<' );
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
							Writev( Temp, File_Name, ' Isn''t A Valid Lzh File...');
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

