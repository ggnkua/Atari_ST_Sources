  {$E+}
  {====================================}

  Function Chk_Registration : Boolean;
  Var
    S : String[ 160 ];
    E : String[ 160 ];
    A, B, H, I, W : Integer;
    L : Long_Integer;
    O : Boolean;
  Begin
    O := False;
    Dummy_Routine;
    If Exists( Key_File ) Then Begin
      H := FOpen( Key_File, 0 );
      If ( H > 0 ) Then Begin
        L := BlockRead( H, 4096, Blkio );
        If ( L = 4096 ) Then Begin
          I := Close_File( H );
          H := 0;  I := 0;  O := True;
          Repeat
            A := BlkIo[ I+1 ] - 48;  If ( A > 9 ) Then A := A - 7;
            B := BlkIo[ I+2 ] - 48;  If ( B > 9 ) Then B := B - 7;
            W := ( A * 10 ) + B;   BlkIo[ H+1 ] := W;
            I := I + 2;  H := H + 1;
          Until ( I = 610 );
          I := 0;  S := '';
          Repeat
            A := BlkIo[ I+1 ] - 48;  If ( A > 9 ) Then A := A - 7;
            B := BlkIo[ I+2 ] - 48;  If ( B > 9 ) Then B := B - 7;
            W := ( A * 16 ) + B;   S := Concat( S, Chr( W ) );
            I := I + 2;
          Until ( I = 306 );

          I := 1;  E := '';  Line := '';
          E := Copy( S, 11, 132 );
          S[0]:= Chr(10);
          Reg_Num := Copy( S, 1, 10 );

          Repeat
            A := Ord(E[ I ]) - 48;  If ( A > 9 ) Then A := A - 7;
            B := Ord(E[I+1]) - 48;  If ( B > 9 ) Then B := B - 7;
            If ( A=0 ) Then A := 5  Else If ( A=1 ) Then A := 12
            Else If ( A= 2 ) Then A :=  7  Else If ( A= 3 ) Then A := 15
            Else If ( A= 4 ) Then A :=  0  Else If ( A= 5 ) Then A := 10
            Else If ( A= 6 ) Then A :=  3  Else If ( A= 7 ) Then A := 9
            Else If ( A= 8 ) Then A := 11  Else If ( A= 9 ) Then A := 4
            Else If ( A=10 ) Then A := 14  Else If ( A=11 ) Then A := 1
            Else If ( A=12 ) Then A :=  6  Else If ( A=13 ) Then A := 13
            Else If ( A=14 ) Then A :=  2  Else If ( A=15 ) Then A := 8;
            If ( B=0 ) Then B := 5  Else If ( B=1 ) Then B := 12
            Else If ( B= 2 ) Then B :=  7  Else If ( B= 3 ) Then B := 15
            Else If ( B= 4 ) Then B :=  0  Else If ( B= 5 ) Then B := 10
            Else If ( B= 6 ) Then B :=  3  Else If ( B= 7 ) Then B := 9
            Else If ( B= 8 ) Then B := 11  Else If ( B= 9 ) Then B := 4
            Else If ( B=10 ) Then B := 14  Else If ( B=11 ) Then B := 1
            Else If ( B=12 ) Then B :=  6  Else If ( B=13 ) Then B := 13
            Else If ( B=14 ) Then B :=  2  Else If ( B=15 ) Then B := 8;
            W := ( A * 16 ) + B;
            Line := Concat( Line, Chr( W ) );
            I := I + 2;
          Until ( I >= 129 );
          Reg_Date := Copy( Line, 1, 10 );
          Reg_MaxDays := Copy( Line, 12, 5 );
          Delete( Line, 1, 16 );
        End;
        EchoSE ( Line );  CrLf;
      End;
    End;
    Chk_Registration := O;
  End;

  Function Security_Chk : Boolean;
  Var
    Ok : Boolean;
    Date_Ok : Boolean;
    S  : String;
    C  : CString;
    X, Days1, Days2 : Long_Integer;
    Dom: Packed Array[1..12] Of Byte;
    M1, D1, Y1, Date, Days, H, I : Integer;
    M2, D2, Y2 : Integer;
  Begin
    Ok := False;
    If ( Chk_Registration ) Then Begin
      Dom[1] := 31;  Dom [2] := 28;  Dom [3] := 31;  Dom [4] := 30;
      Dom[5] := 31;  Dom [6] := 30;  Dom [7] := 31;  Dom [8] := 31;
      Dom[9] := 30;  Dom[10] := 31;  Dom[11] := 30;  Dom[12] := 31;

      Date_Ok := False;
      S := Copy( Reg_Date, 1, 2 );
      If ( Is_Numeric( S ) ) Then Begin
        Readv( S, M1 );
        S := Copy( Reg_Date, 4, 2 );
        If ( Is_Numeric( S ) ) Then Begin
          Readv( S, D1 );
          S := Copy( Reg_Date, 7, 4 );
          If ( Is_Numeric( S ) ) Then Begin
            Readv( S, Y1 );
            Date_Ok := True;
          End;
        End;
      End;
      If ( Date_Ok ) Then Begin
        Line := Concat( 'FTU Started On ', Reg_Date );
        EchoSE( Line );
        Get_SDate;
        M2 := M;
        D2 := D;
        Y2 := Y;
  {     WriteV(Line, 'Reg-Yr=', Y1, '  Act-Yr=', Y2 );  EchoSE( Line );
        Y1 := Y1 - 1900; }
        Y  := Y2 - Y1;
        Days1 := 0; Days2 := 0;

        If ( M1>0 ) Then For Date := 1 To M1-1 Do
          Days1 := Days1 + Dom[Date];
          Days1 := Days1 + D1;
        If ( M2>0 ) Then For Date := 1 To M2-1 Do
          Days2 := Days2 + Dom[Date];
          Days2 := Days2 + D2;
        Days := Days2 - Days1;
        Days := ( Y * 365 ) + Days;
        If ( Days >= 0 ) Then Begin
          WriteV( Line, 'FTU Has Been Active For /r', Days, '/b Days...' );
          EchoSE( Line );
          CrLf;
          Ok := True;
          S := Copy( Reg_MaxDays, 1, 5 );
          If ( Is_Numeric( S ) ) Then Begin
            Readv( S, I );
            If ( Days > I ) Then Begin
              EchoSE( 'FTU Has Been Running Past The Free Trial Period!' );
              EchoSE( 'IT WILL NOT RUN ANYMORE UNTIL IT HAS BEEN REGISTERED!!!' );
              Ok := False;
            End;
          End;
        End
        Else Begin
          EchoSE( 'FTU Will NOT Run Before The Start Date!!!' );
        End;
      End
      Else Begin
        EchoSE( 'WARNING:  FTU  Key File Is Corrupted!!!  Program Aborted...' );
        Ok := False;
      End;
      Press_Any;
      Security_Chk := Ok;
    End;
  End;


