{$E+}
	{====================================}
	Procedure List_Zoo( S: String );

	Type ZooHdr = Packed Record
		Case Integer of
			1: (Buff    : BlockIO);
			2: (ZooStr  : Packed Array[1..20] Of Char;
				Zoo_Sig   : Long_Integer;
				Zoo_Start : Long_Integer;
				Zoo_Minus : Long_Integer;
				Major_Ver : Byte;
				Minor_Ver : Byte);
		End;

	ZooDir = Packed Record
		Case Integer of
			1: (Buff    : BlockIO);
			2: (ZoofSig : Long_Integer; { A7DCFDC4 }
				ZoofTyp   : Byte;
				ZoofCmp   : Byte;         { Comp Method }
				ZoofNxt   : Long_Integer; { Pos Of Next Dir Entry }
				ZoofCur   : Long_Integer; { Pos Of This File }
				ZoofDate  : Integer;
				ZoofTime  : Integer;
				ZoofCrc   : Integer;
				ZoofOSize : Long_Integer; { Original Size }
				ZoofNSize : Long_Integer; { Compressed Size }
				ZoofMver  : Byte;         { Ver That Made This File }
				ZoofMin   : Byte;         { Min Ver Needed To Extract }
				ZoofDel   : Byte;         { 1 If Deleted From Archive, 0 If Not }
				ZoofCmtP  : Long_Integer; { Pointer To Comment }
				ZoofCmtL  : Integer;      { Length Of Comment, 0 If None }
				    Fill  : Byte;
				ZoofName  : Packed Array [1..13] Of Char);
	End;

	ZooHex = Packed Record
		Case Integer of
			1: (Buff : BlockIO);
			2: (Data : Packed Array[ 1..51 ] Of Byte);
	End;

	Var
		DirEnt    : ZooDir;
		ZHeader   : ZooHdr;
		ZHex      : ZooHex;
		Aborted   : Boolean;
		Done      : Boolean;
		Bad_File  : Boolean;
		Tbytes    : Integer;
		H, RC, C  : Integer;
		X, Y, I   : Integer;
		P         : Long_Integer;
		TotalNow  : Long_Integer;
		TotalOrig : Long_Integer;
		Snumber,
		F_B       : String;
		F         : CString;

	Begin
		Done      := False;
		Bad_File  := False;
		Aborted   := False;
		TotalNow  := 0;
		TotalOrig := 0;

		CrLf;
		MakeCString( S, F );
		H := Open_File( F, Input_Mode);
		If ( H < 0 ) Then EchoSE ( ' Unable To UnZoo That File...' )
		Else Begin
			Tbytes := BlockRead( H, 34, ZHex.Buff );
			If ( Tbytes = 34 ) Then Begin
				ZHeader.Buff[ 21 ] := ZHex.Data[ 21 ];
				ZHeader.Buff[ 22 ] := ZHex.Data[ 22 ];
				ZHeader.Buff[ 23 ] := ZHex.Data[ 23 ];
				ZHeader.Buff[ 24 ] := ZHex.Data[ 24 ];
				ZHeader.Buff[ 25 ] := ZHex.Data[ 28 ];
				ZHeader.Buff[ 26 ] := ZHex.Data[ 27 ];
				ZHeader.Buff[ 27 ] := ZHex.Data[ 26 ];
				ZHeader.Buff[ 28 ] := ZHex.Data[ 25 ];
				If ( ZHeader.Zoo_Sig = $DCA7C4FD ) Then Begin { Valid ZOO Header? }
					CrLf;
					P := ZHeader.Zoo_Start;
					If ( P > 34 ) Then Begin
						P := P - 34;
						P := FSeek ( P, H, 1 );    { from Curr. Pos }
						If ( P < 0 ) Then Bad_File := True;
					End;
					If ( Bad_File = False ) Then Begin
						Writev( F_B, '>> Verbose Listing of ', File_Name:12, ' <<' );
						EchoSE( F_B );
						CrLf;
						EchoSE( '  Filename    Length   Stowage  Size Now' );
						EchoSE( '------------ -------- --------- --------' );
						Repeat
							Tbytes := BlockRead( H, 51, ZHex.Buff );
							If ( Tbytes = 51 ) Then Begin
								For X := 1 To 51 Do DirEnt.Buff[ X ] := ZHex.Data[ X ];
								DirEnt.Buff[  7 ] := ZHex.Data[ 10 ];
								DirEnt.Buff[  8 ] := ZHex.Data[  9 ];
								DirEnt.Buff[  9 ] := ZHex.Data[  8 ];
								DirEnt.Buff[ 10 ] := ZHex.Data[  7 ];
								DirEnt.Buff[ 21 ] := ZHex.Data[ 24 ];
								DirEnt.Buff[ 22 ] := ZHex.Data[ 23 ];
								DirEnt.Buff[ 23 ] := ZHex.Data[ 22 ];
								DirEnt.Buff[ 24 ] := ZHex.Data[ 21 ];
								DirEnt.Buff[ 25 ] := ZHex.Data[ 28 ];
								DirEnt.Buff[ 26 ] := ZHex.Data[ 27 ];
								DirEnt.Buff[ 27 ] := ZHex.Data[ 26 ];
								DirEnt.Buff[ 28 ] := ZHex.Data[ 25 ];
								If ( DirEnt.ZoofSig = $DCA7C4FD ) Then Begin { Valid Dir Ent? }
									If ( DirEnt.ZoofNxt > 0 ) Then Begin
										Y := 39;  F_B := '';
										Loop
											C := DirEnt.Buff[Y];
											Exit If ( C = 0 ) or ( Y = 51 );
											F_B := Concat( F_B, Chr( C ) );
											Y := Y + 1;
										End;
										Rc := Length( F_B ); EchoS( F_B );
										For I := 1 to (13 - Rc) Do EchoS (' ');
										Writev( Snumber, DirEnt.ZoofOSize:8 );
										EchoS( Snumber );
										Y := DirEnt.ZoofCmp;
										If ( Y = 0 ) Then EchoS( '  Stored   ' )
										Else EchoS( '  Crushed  ' );
										Writev( Snumber, DirEnt.ZoofNSize:8 );
										EchoSE( Snumber );
										TotalNow  := TotalNow  + DirEnt.ZoofNSize;
										TotalOrig := TotalOrig + DirEnt.ZoofOSize;
										P := FSeek ( DirEnt.ZoofNxt, H, 0 );
										If ( P < 0 ) Then Bad_File := True;
									End
									Else Done := True;
								End
								Else Begin
									Writev( F_B, File_Name, ' Has A Corrupted Directory Entry!' );
									EchoSE( F_B );  Aborted := True;
								End;
							End
							Else Bad_File := True;
						Until (Done) or (Aborted) or (Carrier=False) or (Bad_File);
					End;
					If (Aborted=False) and (Carrier) Then Begin
						EchoSE( '------------ -------- --------- --------' );
						EchoS( '   Totals    ' );
						Writev( Snumber, TotalOrig:8 );
						EchoS( Snumber );
						EchoS('           ');
						Writev( Snumber, TotalNow:8 );
						EchoSE( Snumber );
						CrLf;
					End;
				End
				Else Begin
					Writev( F_B, File_Name, ' Isn''t A Valid Zoo File...' );
					EchoSE( F_B );  Aborted := True;
				End;
			End
			Else Bad_File := True;
			RC := Close_File( H );
			If (Bad_File) Then EchoSE( ' Unexpected End Of File...' );
		End;
	End;

