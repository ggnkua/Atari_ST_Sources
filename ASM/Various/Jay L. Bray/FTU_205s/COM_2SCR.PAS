{S16}
Program Com_2SCR;
{$I AuxSubs.Pas}
{$I GemSubs.Pas}

	{ Converts "Express BBS .COM" files to Untokenized Ascii..... }

	{ $FF 00 = Blank Line }

	{ $FF 01 -\           }
	{    '    -> CommAnds }
	{ $FF 47 -/           }

	{ $FC 01 -\                }
	{    '    -> User Variable }
	{ $FC "" -/                }

	{ $FD = Space         }

Type
	Cstring  = Packed Array[0..79] of Char;
	Commands = Packed Array[1..80] of String[20];
	Dos_Name = Packed Array[1..80] Of Char;
	BLockIo  = Packed Array[1..16384] of Byte;

Var
	Cmnd      : Commands;
	Blkio     : BlockIo;
	L         : String[160];
	Com_Name  : String;
	Directory : String;
	Ln        : Long_Integer;
	Ptr       : Integer;
	Lines     : Integer;
	File_Out  : Text;
	Is_Set    : Boolean;
	Fsel_Btn  : Boolean;
	New_Dir   : Boolean;

	Function GetDrv : Integer;
		GemDos($19);

	Function Open_File( Var P: Cstring; Md: Integer ):Integer;
		GemDos($3D);  { Md: 0=Read Only, 1=Write Only, 2=Read & Write}

	Function Close_File( H: Integer ):Integer;
		GemDos($3E);

	Function FRead( H: Integer; C: Long_Integer; Var A: BlockIo ):Long_Integer;
		GemDos($3F);

	Function Fseek( Where: Long_Integer; FHandle: Integer; Mode: Integer ):Long_Integer;
		GemDos($42); { Mode: 0=From Start, 1=from current pos, 2=from End }	

	Procedure GetDir(Var Path: Dos_Name; Drv: Integer);
		GemDos($47);

	Procedure MakeCstring( Var Source: String; Var Dest: Cstring );
	Var
   	X : Integer;
	Begin
   	For X := 1 To Length(Source) Do
   		Dest[X-1] := Source[X];
   	X := Length(Source);
   	Dest[X] := Chr(0);
	End;

	Function FOpen( Var F: String; Md: Integer ):Integer;
	{ Md: 0=Read Only, 1=Write Only, 2=Read & Write}
	Var
		C : Cstring;
	Begin
		MakeCstring( F, C );
		FOpen := Open_File( C, Md );
	End;

	Procedure GetPath( Var Str: String);
	Var
		I : Integer;
		Path : Dos_Name;
	Begin
		GetDir( Path,0 );
		I := 1;
		While Path[I] <> Chr(0) Do Begin
			Str[I] := Path[I];
			I := I+1;
		End;
		Str[0] := Chr(I-1);
	End;

	Procedure Null;
	Begin
	End;

	Procedure Make_String( I: Integer );
	Var
		X, Y : Integer;
		S : String;
	Begin
		S := '';
		Repeat
			X := Blkio[ Ptr ];
			Y := Blkio[ Ptr + 1];
			If (Y=$fd) Then Y := 32;
			If (X=$fd) Then X := 0
			Else S := Concat( S, Chr(X) );
			Ptr := Ptr + 1;
		Until (Y>127) or (X=0);
		L := Concat( L, S );
	End;

	Procedure Add_Space;
	Begin
		L := Concat( L, ' ' );
		Ptr := Ptr + 1;
	End;

	Procedure Add_SVar( Y: Integer );
	Var
		U : String;
	Begin
		Writev( U, '[Var', Y, ']' );
		L := Concat( L, U );
		Ptr := Ptr + 2;
	End;

	Procedure Add_Var( Y: Integer );
	Var
		U : String;
	Begin
		Writev( U, 'Var', Y );
		L := Concat( L, U );
		Ptr := Ptr + 2;
	End;

	Procedure Make_One( A : Integer );
	Var
		B: Integer;
	Begin
		L := Concat( L, '(''' );
		B := Blkio[ Ptr + 1 ];
		Repeat
			If A = $FC Then Add_SVar( B )
			Else Begin
				Make_String( 0 );
			End;
			A := Blkio[ Ptr ];
			B := Blkio[ Ptr + 1 ];
		Until (A=$ff) or (B=$ff);
		L := Concat( L, ''')' );
	End;

	Procedure Make_Two( A: Integer );
	Var
		B : Integer;
	Begin
		B := Blkio[ Ptr + 1 ];
		If A = $FC Then Add_SVar( B )
		Else Begin
			L := Concat( L, '(''' );
			Make_String( 1 );
			L := Concat( L, '''), (''' );
			A := Blkio[ Ptr ];
			B := Blkio[ Ptr + 1 ];
			If A = $FC Then Add_Var( B )
			Else Begin
				Make_String( 0 );
				L := Concat( L, ''')' );
			End;
		End;
	End;

	Procedure Do_T_S( A: Integer );
	Var
		B: Integer;
	Begin
		Make_String( 1 );
		L := Concat( L, ', (''' );
		B := Blkio[ Ptr + 1 ];
		If A = $FC Then Add_SVar( B )
		Else Begin
			Make_String( 1 );
		End;
		L := Concat( L, ''')' );
	End;

	Procedure Do_S_T( A: Integer );
	Var
		B: Integer;
	Begin
		L := Concat( L, '(''' );
		B := Blkio[ Ptr + 1 ];
		If A = $FC Then Add_SVar( B )
		Else Begin
			Make_String( 1 );
		End;
		L := Concat( L, '''),' );
	End;

	Procedure Do_Define( X: Integer );
	Var
		S, T: String;
		A, B: Integer;
	Begin
		S := '';
		B := Blkio[ Ptr + 1 ];
		If X = $FC Then Add_Var( B );
		Repeat
			A := BlkIo[ Ptr ];
			B := BlkIo[ Ptr + 1 ];
			If (A=$fd) Then A := 32;
			If (B=$fd) Then B := 32;
			If (B=$Fc) Then Add_SVar( B )
			Else Begin
				S := Concat( S, Chr( A ));
				Ptr := Ptr + 1;
			End;
		Until (B>127);
		A := Pos( '=', S );
		B := Length( S );
		If (A=B) Then S := ''
		Else Begin
			T := Copy( S, A+2, B-A );
			T := Concat( ' = (''', T, ''')' );
			L := Concat( L, T );
		End;
	End;

	Procedure Make_Command( Y: Integer; Var Z: Integer );
	Var
		A : Integer;
	Begin
		A := Z;
		If (Y<>11) And (Lines>2) Then Is_Set := False;
		If (Y=11) And (Is_Set) Then Y := 26;
		L := Concat( L, Cmnd[ Y ] );
		Ptr := Ptr + 2;
		If (Z<>$FF) Then Begin
			Case Y Of
				 1 : Make_One( A );   { Print   }
				 2 : Make_One( A );   { Printe  }
				11 : Null;            { Set     }
				15 : Do_S_T( A );     { Open    }
				16 : Make_One( A );   { FPrint  }
				23 : Make_One( A );   { Execute }
				26 : Do_Define( A );  { Define  }
				36 : Make_Two( A );   { TOS     }
				45 : Make_One( A );   { Total_Words }
				46 : Do_S_T( A );     { Get_Word  }
				49 : Do_T_S( A );     { Table_Put }
				50 : Make_One( A );   { Table_Load }
				51 : Make_One( A );   { Table_Find }
				53 : Null;            { Array_Put  }
				54 : Do_T_S( A );     { Array_Find }
				61 : Make_Two( A );   { File_Copy  }
				62 : Make_One( A );   { File_Delete }
				63 : Make_Two( A );   { File_Rename }
				64 : Make_Two( A );   { GEM  }
				65 : Make_One( A );   { File_ChgDir }
				68 : Make_Two( A );   { Pos  }
				69 : Make_One( A );   { File_Print  }
				70 : Make_Two( A );   { TTP  }
				71 : Make_One( A );   { ShutDown    }
				72 : Make_One( A );   { File_ChgDrive }
				76 : Make_One( A );   { File_Date   }
			End; { Case }
			Z := BlkIo[ Ptr ];
		End;
	End;

	Procedure Build_Line;
	Var
		U : String;
		Eol : Integer;
		X, Y, Z : Integer;
		Neu : Boolean;
	Begin
		Neu := False;
		L := '';
		Repeat
			If Ptr>=Ln Then Neu := True;
			If (Neu=False) Then Begin
				X := Blkio[ Ptr ];
				Y := Blkio[ Ptr + 1];
				Z := Blkio[ Ptr + 2];
				Case X of
					$FF : Begin
									If (Y=0) Then Begin
										L := '';
										Ptr := Ptr + 2;
										Neu := True;
										Lines := Lines + 1;
									End
									Else Begin
										Lines := Lines + 1;
										Make_Command( Y, Z );
										If Z=$FF Then Neu := True;
									End;
								End;
					$FC	: Begin
									If Z=$FF Then Neu := True;
									Add_Var( Y );
								End;
					$FD	:	Begin
									Add_Space;
									If Y=$FF Then Neu := True;
								End;
					$3A	:	Begin
									L := Concat( L, ':' );
									Ptr := Ptr + 1;
									If (Y=$FF) Then Neu := True;
								End;
					Else Begin
						L := Concat( L, Chr(X) );
						Ptr := Ptr + 1;
						If Y=$FF Then Neu := True;
					End;
				End; { Case }
			End;
		Until (Neu);	
  	WriteLn( L );
		WriteLn( File_Out, L );
	End;

	Procedure Convert_File;
	Var
		H, L : Integer;
		X : Long_Integer;
		Fo : String;
		Done : Boolean;
	Begin
		Lines := 0;
		Done := False;
		Fo := Com_Name;
		L := Pos( '.', Fo );
		Fo[ L + 1 ] := 'S';
		Fo[ L + 2 ] := 'C';
		Fo[ L + 3 ] := 'R';
		H  := FOpen( Com_Name, 0 );
		Ln := FRead( H, SizeOf(BlkIo), BlkIo );
		X := Close_File( H );

		Rewrite( File_Out, Fo );
		X  := Fseek( 0, Handle( File_Out), 2 );
		Ptr := 2;
		Repeat
			If Ptr >= Ln Then Begin
				Close( File_Out );
				Done := True;
			End
				Else Build_Line;
		Until (Done);
	End;

Begin
	Is_Set  := True;

	Cmnd[1] := 'Print ';
	Cmnd[2] := 'Printe ';
	Cmnd[3] := 'Input ';
	Cmnd[4] := 'If ';
	Cmnd[5] := 'Ef ';
	Cmnd[6] := 'Else ';
	Cmnd[7] := 'EndIf';
	Cmnd[8] := 'Goto ';
	Cmnd[9] := 'Dump';
	Cmnd[10] := '>10<';
	Cmnd[11] := 'Set ';
	Cmnd[12] := 'Clear ';
	Cmnd[13] := '>13<';
	Cmnd[14] := 'View ';
	Cmnd[15] := 'Open ';
	Cmnd[16] := 'Fprint ';
	Cmnd[17] := '>17<';
	Cmnd[18] := 'Finput ';
	Cmnd[19] := 'Close';
	Cmnd[20] := 'Foreground ';
	Cmnd[21] := 'Background ';
	Cmnd[22] := 'Inverse ';	
	Cmnd[23] := 'Execute ';
	Cmnd[24] := 'Backspace ';
	Cmnd[25] := 'Expand ';
	Cmnd[26] := 'Define ';
	Cmnd[27] := 'Gosub ';
	Cmnd[28] := 'Return';
	Cmnd[29] := 'Debug';
	Cmnd[30] := 'Bell';
	Cmnd[31] := 'Margin ';
	Cmnd[32] := 'Abort ';
	Cmnd[33] := 'Increase ';
	Cmnd[34] := 'Decrease ';
	Cmnd[35] := 'Disconnect';
	Cmnd[36] := 'TOS ';
	Cmnd[37] := 'Copy ';
	Cmnd[38] := 'Random ';
	Cmnd[39] := 'Time_Limit ';
	Cmnd[40] := 'For ';
	Cmnd[41] := 'Endfor';
	Cmnd[42] := 'Break';
	Cmnd[43] := 'Note ';
	Cmnd[44] := 'Point ';
	Cmnd[45] := 'Total_Words ';
	Cmnd[46] := 'Get_Word ';
	Cmnd[47] := 'Shuffle ';
	Cmnd[48] := 'Table_Get ';
	Cmnd[49] := 'Table_Put ';
	Cmnd[50] := 'Table_Load ';
	Cmnd[51] := 'Table_Find ';
	Cmnd[52] := 'Array_Get ';
	Cmnd[53] := 'Array_Put ';
	Cmnd[54] := 'Array_Find ';
	Cmnd[55] := 'Value ';
	Cmnd[56] := 'Length ';
	Cmnd[57] := 'Exit';
	Cmnd[58] := 'End';
	Cmnd[59] := 'Version';
	Cmnd[60] := 'UpperCase ';
	Cmnd[61] := 'File_Copy ';
	Cmnd[62] := 'File_Delete ';
	Cmnd[63] := 'File_Rename ';
	Cmnd[64] := 'GEM ';
	Cmnd[65] := 'File_ChgDir ';
	Cmnd[66] := 'Get_Key ';
	Cmnd[67] := 'Array_Clear ';
	Cmnd[68] := 'Pos ';
	Cmnd[69] := 'File_Print ';
	Cmnd[70] := 'TTP ';
	Cmnd[71] := 'ShutDown ';
	Cmnd[72] := 'File_ChgDrive ';
	Cmnd[73] := 'Translation ';
	Cmnd[74] := 'Chat ';
	Cmnd[75] := 'Page ';
	Cmnd[76] := 'File_Date ';
	Cmnd[77] := 'Cont_Scroll ';

	New_Dir := False;
	Ptr := Init_Gem;
	Ptr := GetDrv;
	GetPath( Directory );
	Directory := Concat( Chr(65+Ptr),':',Directory,'\*.COM' );
	Repeat
		Fsel_Btn := Get_In_File( Directory, Com_Name );
		If (Fsel_Btn) Then Begin
		Ptr := Length( Com_Name );
		If (Com_Name[Ptr]='\') Then Fsel_Btn := False
			Else Begin
				If (New_Dir=False) Then Begin
					Directory := Com_Name;
					Ptr := Length(Directory);
					Loop
						Exit If (Directory[Ptr]='\') or (Ptr=1);
						Ptr := Ptr - 1;
					End;
					Directory[0] := Chr( Ptr );
					Directory := Concat( Directory, '*.COM' );
					New_Dir := True;
				End;
				Convert_File;
			End;
		End;
	Until (Fsel_Btn=False);
	Exit_gem

End.

