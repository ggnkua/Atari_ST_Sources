	Io_check( False );
	SetDta( DTA_Data );
	Boot_Drv := CurDisk;
	GetDir( Boot_Path, 0 );
 	Zerotimer;
 	Timeon := Timer;
 	BM_Num := 0;
	Batch_Mode := False;
	If Cmd_args < 7 Then Begin
		WriteLn( 'Invalid number of command line parameters.' );
		Halt;
	End;
 	Cmd_Getarg( 1, Line );
 	Readv( Line, Ftu_Length );
 	Cmd_Getarg( 2, Baudrate );
 	Readv( Baudrate, Speed );
	Cps := Speed Div 10;
 	Cmd_Getarg( 3, Line );
 	Cmd_Getarg( 4, Number );
	Readv( Number, Usr_No );
	Cmd_Getarg( 5, Width );
	Readv( Width, WidT );
 	Cmd_Getarg( 6, Time_left );
 	Readv( Time_left, Minutes );
 	Cmd_Getarg( 7, Translation );  (* 0= Ascii, 1 = Mono, 2 = Color *)
	Readv( Translation, Transv );

	Shw_Time := True;
	Chat := False;
	Color := False;
	Inverse := True;
 	VT52 := False;
	Local := False;

 	If Transv = 2 Then VT52 := True;
	If Speed = 19200 Then Local := True;

	Trans[0] := ' Ascii  ';
	Trans[1] := ' VT52 M ';
	Trans[2] := ' VT52 C ';
	Trans[3] := ' Ansi M ';
	Trans[4] := ' Ansi C ';

	Prompt := '>';
	Month[1] := 'Jan ';
	Month[2] := 'Feb ';
	Month[3] := 'Mar ';
	Month[4] := 'Apr ';
	Month[5] := 'May ';
	Month[6] := 'Jun ';
	Month[7] := 'Jul ';
	Month[8] := 'Aug ';
	Month[9] := 'Sep ';
	Month[10] := 'Oct ';
	Month[11] := 'Nov ';
	Month[12] := 'Dec ';
	Arc_Type[1] := 'Arc';
	Arc_Type[2] := 'Lzh';
	Arc_Type[3] := 'Zip';
	Arc_Type[4] := 'Sit';
	Arc_Type[5] := 'Pak';
	Rating[1]:= 'Poor';
	Rating[2]:= 'Fair';
	Rating[3]:= 'Good';
	Rating[4]:= 'Very Good';
	Rating[5]:= 'Excellent';
	Rating[6]:= 'Not Tested';

	Err[1] := 'General Error';
	Err[2] := 'Drive Not Ready';
	Err[3] := 'Unknown Command';
	Err[4] := 'CRC Error';
	Err[5] := 'Bad Request';
	Err[6] := 'Seek Error';
	Err[7] := 'Unknown Media';
	Err[8] := 'Sector Not Found';
	Err[9] := 'No Paper';
	Err[10]:= 'Write Error';
	Err[11]:= 'Read Error';
	Err[12]:= 'General Error';
	Err[13]:= 'Disk Write Protected';
	Err[14]:= 'Disk Was Changed';
	Err[15]:= 'Unknown Device';
	Err[16]:= 'Bad Sector';
	Err[17]:= 'Insert Disk';
	Err[32]:= 'Invalid Function Number';
	Err[33]:= 'File Not Found';
	Err[34]:= 'Pathname Not Found';
	Err[35]:= 'Too Many Files Open';
	Err[36]:= 'Access Not Possible';
	Err[37]:= 'Invalid Handle Number';
	Err[39]:= 'Not Enough Memory';
	Err[40]:= 'Invalid Memory Block Address';
	Err[46]:= 'Invalid Drive Specification';
	Err[49]:= 'No More Files';
	Err[64]:= 'GEMDOS range error, Seek Wrong?';
	Err[65]:= 'GEMDOS internal error';
	Err[66]:= 'Invalid executable file format';
	Err[67]:= 'Memory Block Growth Failure';
	Err[68]:= 'Oops, YOU Messed Up!!!';
	Err[70]:= 'Unknown Error';

	Xyz[1] := 'Missing block number';
	Xyz[2] := 'Missing or bad header';
	Xyz[3] := 'Synchronization error';
	Xyz[4] := 'Timed out';
	Xyz[5] := 'Checksum error';
	Xyz[6] := 'User aborted';
	Xyz[7] := 'File error';
	Xyz[8] := 'Too many retries';
	Xyz[9] := 'CRC error';
	Xyz[10]:= 'Filename must be specified';
	Xyz[11]:= 'Bad escape character';
	Xyz[12]:= 'Bad or unsupported packet type';
	Xyz[13]:= 'Bad hexadecimal character';
	Xyz[14]:= 'Sender not ready or set to receive';
	Xyz[15]:= 'Subpacket too long';
	Xyz[16]:= 'Sender aborted';
	Xyz[17]:= 'File position error';
	Xyz[18]:= 'Sender indicates end of file, but file length is wrong';
	Xyz[19]:= 'Receiver canceled';
	Xyz[20]:= 'End of transmission not acknowledged';
	Xyz[21]:= 'Bad option on command line';
	Xyz[22]:= 'Not enough memory to allocate buffers';

	ArcType[1] := ' Stored   ';
	ArcType[2] := ' Packed   ';
	ArcType[3] := ' Squeezed ';
	ArcType[4] := ' Crunched ';
	ArcType[5] := ' Squashed ';
	ArcType[6] := ' <<Dir>>  ';
	ArcType[7] := ' Unknown  ';

	ZipType[1] := ' Stored   ';
	ZipType[2] := ' Shrunk   ';
	ZipType[3] := ' Reduced  ';
	ZipType[4] := ' Imploded ';
	ZipType[5] := ' Unknown  ';

	SitType[1] := ' None     ';
	SitType[2] := ' RLE      ';
	SitType[3] := ' LZW      ';
	SitType[4] := ' Huffman  ';
	SitType[5] := ' * None   ';
	SitType[6] := ' * RLE    ';
	SitType[7] := ' * LZW    ';
	SitType[8] := ' * Huff   ';
	SitType[9] := ' <<Dir>>  ';
	SitType[10]:= ' Unknown  ';

	Lin_Count := 0;
	Tot_DL_Time := 0;
	F_Name[1] := Chr( Ord('A') + Boot_Drv );
	F_Name[2] := ':' ;
	F_Name[0] := chr(2);
	MakePString( Boot_Path, Line );
	F_Name := Concat( F_Name, Line );
	F_Name := Concat( F_Name, '\' );
	Ftu_Path := F_Name;
	Line := Ftu_Path;
	Line := Concat( Line, 'XYZ.TTP' );
	MakeCstring( Line, Xyz_Path );
	Line := Ftu_Path;
	Ftu_UserFile := Concat( Line, 'ftu_data.usr' );
	Ftu_MaskFile := Concat( Line, 'ftu_data.msk' );
 	Get_SysData;
	Get_UserData;
	Get_Ftu_User;
	Get_Sig_Access;
	If (Max_Sig=0) Then Begin
		CrLf;
		EchoSE( 'Sorry, You Can''t Access The Files Yet!!!' );
	End
	Else Begin
		Show_Top5;
		Show_DL_UL;
		Show_File( F_Name );
		Clear_Screen;
		CrLf;
		Usr_Addr := Find_User_Addr;
		New_Dls := 0;
		New_Uls := 0;
		Caps := False;
		Quick_Scan := False;
		Forced_Off := False;
		One_Sig := True;
		Valid_New := False;
		DescL[1] := ' ';
		DescL[2] := Concat( 'Entered FTU At: ', Mil_Time );
		Log(2);
		(* About *)
		(* Menu *)
		If Usr_Addr>2048 Then Begin
			Wpoke( Usr_Addr+220, UserRec.Downloads + New_Dls );
			Wpoke( Usr_Addr+222, UserRec.Uploads + New_Uls );
		End
		Else Begin
			Dummy_I := 0;
			If (New_Uls>0) Then Begin
				Dummy_I := Dummy_I + 1;
				Writev( DescL[Dummy_I], 'Note: Add ', New_Uls, ' To User Uploads...' );
			End;
			If (New_Dls>0) Then Begin
				Dummy_I := Dummy_I + 1;
				Writev( DescL[Dummy_I], 'Note: Add ', New_Dls, ' To User Downloads...' );
			End;
			If (Dummy_I>0) Then Log(Dummy_I);
		End;
		DescL[1] := Concat( 'Exited FTU At: ', Mil_Time );
		DescL[2] := ' ';
		Log(2);
	End;
	Dummy_I := ChDir( Boot_Path );
	Io_check( True );
