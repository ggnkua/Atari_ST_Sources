{$S16}
Program FSIG_LST;
{$I AuxSubs.Pas}


Type
  Cstring = packed Array[0..79] of Char;


  SigData2 = Packed Record
    SigCount  : Integer;
    Sig1      : Boolean;
    Pts_K     : Integer;
    Names     : Packed Array[ 1..256 ] Of String[30];
    Paths     : Packed Array[ 1..256 ] Of String[60];
    Show_Free : Packed Array[ 1..256 ] Of Boolean;
    Use_Desc  : Packed Array[ 1..256 ] Of Boolean;
    Desc_Path : Packed Array[ 1..256 ] Of String[60];
    Userlog   : String[60];
    LogFile   : String[60];
    Upld_Pth  : String[60];
  End;

Var
  System2     : SigData2;


  Function Open_File( Var P: Cstring; Md: Integer ):Integer;
    GemDos($3D);  { Md: 0=Read Only, 1=Write Only, 2=Read & Write}

  Function Close_File( H: Integer ):Integer;
    GemDos($3E);

  Function FRead_Sys2(H:Integer; Count:Long_Integer; Var S:SigData2):Long_Integer;
    Gemdos( $3F );

  Function Fseek( Where : Long_Integer ; FHandle, Mode: Integer ):Long_Integer;
    Gemdos($42); { Mode: 0=From Start, 1=from current pos, 2=from End }  

  Procedure MakeCstring( Var Source: String; Var Dest: Cstring );
  Var
    X : Integer;
  Begin
    For X := 1 To Length(Source) Do  Dest[X-1] := Source[X];
    X := Length( Source );
    Dest[ X ] := Chr( 0 );
    Dest[X+1] := Chr( 0 );
  End;

  Procedure MakePstring( Var Source: CString; Var Dest: String );
  Var
    X : Integer;
  Begin
    X := 0;
    While ( Source[X] <> #0 ) Do Begin
      Dest[X+1] := Source[X];
      X := X + 1;
    End;
    Dest[0] := Chr( X );
  End;

  Function FOpen( Var F: String; Md: Integer ):Integer;
    { Md: 0=Read Only, 1=Write Only, 2=Read & Write}
  Var
    C : Cstring;
  Begin
    MakeCstring( F, C );
    FOpen := Open_File( C, Md );
  End;

  Procedure Get_SysData;
  Var
    Sigdatafile : text;
    I, J : Integer;
    F, Temp : String;
    Ch : Char;
    count : Long_Integer;
  Begin
    F := 'ftu_data.sig';
    Reset( Sigdatafile, F );
    Count := Fseek( 0, Handle(SigdataFile), 0);
    Count := FRead_Sys2( handle(sigdatafile), sizeof(system2), System2 );
    Close( Sigdatafile );
  End;

  Procedure Write_File;
  Var
    TFile : text;
    I, J : Integer;
    F, Temp : String;
  Begin
    Get_SysData;
    F := 'FILE_SIG.LST';
    Rewrite( Tfile, F );
    For I := 1 to 256 Do Begin
      If ( System2.Names[ I ] <> '' ) Then Begin
        WriteLN( TFile, System2.Names[ I ] );
        WriteLN( TFile, System2.Paths[ I ] );
      End;
    End;
    Close( Tfile );
  End;

Begin
  Write_File;
End.

