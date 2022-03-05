{$S20}
Program Key;

{$I AuxSubs.Pas}

Type
  CString = Packed Array[ 0..80 ] Of Char;
  BlockIo = Packed Array[ 1..4096 ] Of Byte;

Var
  BlkIo : BlockIo;
  Line  : String;

  (* GEMDOS Funtions *)

  Function Make_File( Var P: Cstring; Md: Integer ):Integer;
    GemDos($3C);  { Md: 0=Read Only, 1=Write Only, 2=Read & Write}

  Function Close_File( H: Integer ):Integer;
    GemDos($3E);

  Function FR ( H:Integer; C:Long_Integer; Var S: BlockIo ):Long_Integer;
    Gemdos( $3F );

  Function FW ( H:Integer; C:Long_Integer; Var S: BlockIo ):Long_Integer;
    Gemdos( $40 );

  Function Fseek( Where: Long_Integer ; FHandle, Mode: Integer ):Long_Integer;
    Gemdos($42);  { Mode: 0=From Start, 1=from current pos, 2=from End }
  
  Function XB_Rnd : Long_Integer; { get xbios random 24-bit number }
    Xbios( 17 );

  Function Rnd : Real;
  Begin
    Rnd := ( XB_Rnd / 16777216.0 );
  End;

  Function Random( Low, Hi : Integer ) : Integer;
  Begin
    Random := Low + Trunc( Rnd * ( Hi - Low +1 ) );
  End;

  Procedure Make_Key;
  Var
    S, T, X : String;
    H, I, W : Integer;
    C  : CString;
    U  : String[255];
    L  : Long_Integer;
    B  : Byte;
    Ch1,Ch2 : Char;
  Begin
    I := 1;
    Repeat
      BlkIo[ I ] := Random( 52, 53 );  I := I + 1;
      BlkIo[ I ] := Random( 48, 57 );  I := I + 1;
    Until ( I = 4097 );
    X := '5C7F0A39B4E16D28';

    WriteLn( '            FTU Key Maker version 2.0' );
    WriteLn( '' );
    WriteLn( '  0  - Not Registered' );
    WriteLn( '  1  - Jay L. Bray' );
    WriteLn( '  2  - W.A.S.T.E.D' );
    WriteLn( '  3  - The Keep BBS' );
    WriteLn( '  4  - C&R Systems' );
    WriteLn( '  5  - Lee R. Chase' );
    WriteLn( '  6  - Steve Yeomans' );
    WriteLn( '' );
    Write  ( 'Press Number for desired Key File...' );
    ReadLn ( S );
    Ch1 := S[ 1 ];
    If Ch1 = '0' Then Begin
      Line := '03/17/1996-00090 This Program Is NOT REGISTERED To THIS BBS!      ';
      U := 'FTU_000000';
    End
    Else If Ch1 = '1' Then Begin
      Line := '03/17/1996-32767 REGISTERED To:  << Jay L. Bray >>                ';
      U := 'FTU_100000';
    End
    Else If Ch1 = '2' Then Begin
      Line := '03/17/1996-32767 REGISTERED To:  << W.A.S.T.E.D. BBS >>           ';
      U := 'FTU_100040';
    End
    Else If Ch1 = '3' Then Begin
      Line := '03/17/1996-32767 REGISTERED To:  << The KEEP BBS >>               ';
      U := 'FTU_100070';
    End
    Else If Ch1 = '4' Then Begin
      Line := '03/17/1996-32767 REGISTERED To:  << C&R Systems >>                ';
      U := 'FTU_100090';
    End
    Else If Ch1 = '5' Then Begin
      Line := '03/17/1996-32767 REGISTERED To:  << Lee R. Chasse >>              ';
      U := 'FTU_100100';
    End
    Else If Ch1 = '6' Then Begin
      Line := '03/17/1996-32767 REGISTERED To:  << Steve Yeomans >>              ';
      U := 'FTU_100110';
    End;
    WriteLn( Line );

    For I := 1 To 66 Do Begin
      B  := Ord( Line[ I ] );  WriteV ( T, B:2:h );
      Ch1 := T[ 1 ]; W := Pos( Ch1, X ) - 1;
        WriteV( S,W:1:h ); U := Concat( U, S );
      Ch2 := T[ 2 ]; W := Pos( Ch2, X ) - 1;
        WriteV( S,W:1:h ); U := Concat( U, S );
    End;
      W := 1;  S := '';
    For I := 1 To 152 Do Begin
      B  := Ord( U[ I ] );  WriteV ( T, B:2:h );
      Ch1 := T[ 1 ]; WriteV( S, Ord( Ch1 ):2 );
      If ( S[ 1 ] = ' ' ) Then S[ 1 ] := '0';
      Blkio[ W ] := Ord( S[ 1 ] );  W := W + 1;
      Blkio[ W ] := Ord( S[ 2 ] );  W := W + 1;
      Ch2 := T[ 2 ]; WriteV( S, Ord( Ch2 ):2 );
      If ( S[ 1 ] = ' ' ) Then S[ 1 ] := '0';
      Blkio[ W ] := Ord( S[ 1 ] );  W := W + 1;
      Blkio[ W ] := Ord( S[ 2 ] );  W := W + 1;
    End;

    S := concat( 'FTU.KEY', Chr(0) );
    For I := 1 To Length( S ) Do C[ I-1 ] := S[ I ];
    H := Make_File ( C, 0 );
    L := FW ( H, 4096, BlkIo );
    I := Close_File ( H );
  End;

Begin
  Make_Key;  
End.

