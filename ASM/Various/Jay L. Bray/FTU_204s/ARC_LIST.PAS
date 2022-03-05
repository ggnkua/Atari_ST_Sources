	{$E+}
	{====================================}
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
			Writev( Temp, '>> Verbose Listing of ', File_Name:12, ' <<' );
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
							Writev( Temp, File_Name, ' Isn''t A Valid ARC File...');
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

