{$E+}
{====================================}
Procedure List_Arj( S: String );

Type

  ArjHdr = Packed Record
    Case Integer of
      1 : (Arj_Hdr     : Integer;
           B1          : Byte;
           B2          : Byte;
           Bas_Hdr_Siz : Integer );
      2 : (Buff: BlockIO );
  End;

  Frst_Siz = Packed Record
    Case Integer of
      1:  (Frst_Hdr_Siz: Byte );
      2 : (Buff: BlockIO );
  End;

  ArjDat = Packed Record
    Case Integer of
      1: (Buff       : Packed Array[0..33] of Byte);
      2: (Arc_Vers   : Byte;
          Min_Arc    : Byte;
          Host_Os    : Byte;
          Arj_Flag   : Byte;
          Method     : Byte;
          File_Type  : Byte;
          Rsrvd      : Byte;
          Date_Time  : Long_Integer;
          Comp_Size  : Long_Integer;
          Orig_Size  : Long_Integer;
          Orig_CRC   : Long_Integer;
          File_Pos   : Integer;
          F_Acs_Mode : Integer;
          Host_Data  : Integer;
          Extra1     : Byte;
          Extra2     : Byte;
          Extra3     : Byte;
          Extra4     : Byte );
  End;

  ArjInf = Packed Record
    Case Integer of
      1 : ( Data : Packed Array [0..79] of Byte );
      2 : ( Buff : BlockIO );
  End;


  Var
    Header      : ArjHdr;
    Data        : ArjDat;
    Info        : ArjInf;
    Frst        : Frst_Siz;
    Aborted     : Boolean;
    Done        : Boolean;
    First       : Boolean;
    Bad_File    : Boolean;
    Bad_Hdr     : Boolean;
    Tbytes      : Integer;
    H, RC, C    : Integer;
    X, Y, I     : Integer;
    P           : Long_Integer;
    TotalNow    : Long_Integer;
    TotalOrig   : Long_Integer;
    Orig_Size   : Long_Integer;
    Comp_Size   : Long_Integer;
    Snumber,
    F_E,
    F_B         : String;
    F           : CString;

  Begin
    Bad_File  := False;
    Bad_Hdr   := False;
    Done      := False;
    First     := True;
    Aborted   := False;
    TotalNow  := 0;
    TotalOrig := 0;
    CrLf;
    MakeCString( S, F  );
    H := Open_File( F, Input_Mode );
    If ( H > 0 ) Then Begin
      CrLf;
      Writev( F_B, '>> Verbose Listing of ', File_Name:12, ' <<'  );
      EchoSE( F_B  );
      CrLf;
      Repeat
        Tbytes := BlockRead( H, 4, Header.Buff  );
        If ( Tbytes = 4 ) Then Begin
          Header.Bas_Hdr_Siz := ( Header.B2 * 256 ) + Header.B1;
          If ( Header.Arj_Hdr = $60EA ) Then Begin  { Valid Header }
            X := Header.Bas_Hdr_Siz;
            If ( X > 0 ) And ( X <= 2600 ) Then Begin  { 0 = End Of Archive }
              If ( First ) Then Begin
                EchoSE( 'Filename     Original Compressed'  );
                EchoSE( '------------ -------- ----------'  );
                First := False;
              End;
              Tbytes := BlockRead( H, 1, Frst.Buff  );
              P      := Frst.Frst_Hdr_Siz - 1;
              Tbytes := BlockRead( H, P, Info.Buff  );
              If ( Tbytes = P ) Then Begin
                Data.Buff[4 ] := Info.Data[ 4]; { Comp Method }
                Data.Buff[5 ] := Info.Data[ 5]; { File Type }
                Data.Buff[12] := Info.Data[14]; { Comp Size }
                Data.Buff[13] := Info.Data[13];
                Data.Buff[14] := Info.Data[12];
                Data.Buff[15] := Info.Data[11];
                Data.Buff[16] := Info.Data[18]; { Orig Size }
                Data.Buff[17] := Info.Data[17];
                Data.Buff[18] := Info.Data[16];
                Data.Buff[19] := Info.Data[15];
                Data.Buff[24] := Info.Data[24]; { FileSpec Pos In Filename }
                Data.Buff[25] := Info.Data[23];
                Orig_Size := Data.Orig_Size;
                Comp_Size := Data.Comp_Size;
                P := 80;
                I := Data.File_Pos;            { Pos Of Filename In Path }
                Y := X - Frst.Frst_Hdr_Siz;    { Len Of Filename & Comment }
                If ( I > 0 ) Then Begin
                  P := FSeek ( I, H, 1 );  Y := Y - I;
                End;
                If ( P > 0 ) Then Begin
                  X := 0; F_E := '';
                  Repeat
                    X := X + 1;
                    Tbytes := BlockRead( H, 1, Info.Buff  );
                    C := Info.Data[ 0 ];
                    If ( C <> 0 ) Then F_E := Concat( F_E, Chr( C  ) );
                  Until ( C=0 );
                  P := Y - X;                    { Just The Comment Left }
                  P := FSeek ( P, H, 1 );
                  If ( P > 0 ) Then Begin
                    Rc := Length( F_E  );
                    EchoS( F_E  );
                    For I := 1 to ( 13 - Rc ) do EchoS (' ' );
                    Writev( Snumber, Orig_Size:8  );
                    EchoS ( Snumber );
                    Writev( Snumber, '   ', Comp_Size:8  );
                    EchoSE( Snumber );
                    TotalNow  := TotalNow  + Comp_Size;
                    TotalOrig := TotalOrig + Orig_Size;
                    Tbytes := BlockRead( H, 6, Info.Buff  );
                    If ( TBytes = 6 ) Then Begin
                      X := (Info.Data[5]*256) + Info.Data[4];
                      If ( X>0 ) Then Begin
                        P := X + 4;  P := FSeek ( P, H, 1 );
                        If ( P<0 ) Then Bad_File := True;
                      End;
                      P := Data.Comp_Size;
                      P := FSeek ( P, H, 1 );
                      If ( P<0 ) Then Bad_File := True;
                    End
                    Else Bad_File := True;
                  End
                  Else Bad_File := True;
                End
                Else Bad_File := True;
              End;
            End
            Else If ( X = 0 ) Then Done := True
            Else Bad_Hdr := True;
          End
          Else Bad_Hdr := True;
        End
        Else Bad_File := True;
      Until (Done) or (Aborted) or (Carrier=False) or (Bad_File );
      RC := Close_File( H  );
      If ( First ) Then Begin
        Writev( F_B, File_Name, ' Isn''t A Valid Arj File...'  );
        EchoSE( F_B  );
      End;
      If (Bad_File) Then EchoSE( ' Unexpected End Of File...'  );
      If (Bad_Hdr ) Then EchoSE( ' Invalid Header In Archive...' );
      If (Aborted=False) and (Carrier) Then Begin
        EchoSE( '------------ -------- ----------'  );
        EchoS ( '   Totals    ' );
        Writev( Snumber, TotalOrig:8  );
        EchoS ( Snumber  );
        EchoS ('   ' );
        Writev( Snumber, TotalNow:8  );
        EchoSE( Snumber  );
        CrLf;
      End;
    End
    Else EchoSE (' Unable To UnArj That File...' );  { Can't Open }
  End;

