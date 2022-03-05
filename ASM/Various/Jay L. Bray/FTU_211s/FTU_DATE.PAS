{$S20}
Program FTU_Date;

Const
	Block_Size = 8192;

Type
	BlockIO   = Packed Array[1..Block_Size] Of Byte;

Var
	Blkio       : BlockIO;
	Boot_drv    : Integer;

	Function CurDisk: Integer;
		GemDos( $19 );

	Function Get_SDate: Integer;
		GemDos( $2A );

	Function Rwabs( Flg:Integer; Var B:BlockIo; Num, Sct, Drv : Integer ):Integer;
		Bios( 4 );  { Flg = 0-Read, 1-Write } 

	Procedure Put_2nd_Reg;
	Var
		X  : Long_Integer;
		Date, Sct, I  : Integer;
		B1,B2 : Byte;
		S : String;
	Begin
		I := Rwabs( 0, BlkIo, 1, 0, Boot_Drv );
		B1 := BlkIo[20];  B2 := BlkIo[21];
		Sct := ( B2 * 256 ) + B1;
		Date := Get_SDate;
		Blkio[1] := Shr( Date, 8 );
		Blkio[2] := ( Date & 255 );
		Blkio[3] := 9;
		Sct := Sct - 1;
		I := Rwabs( 1, BlkIo, 1, Sct, Boot_Drv );
		WriteLn( 'Drive=', Boot_Drv, ' Sect=', Sct, ' I= ', I );
		ReadLn( S );
	End;

Begin
	Boot_Drv := CurDisk;
	Put_2nd_Reg;
End.

