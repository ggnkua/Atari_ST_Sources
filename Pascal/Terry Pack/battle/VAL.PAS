
{ The Include File Version }

Procedure Kill_BS(Var InStr: Str255);
Var BS: Char;
    B: Integer;
Begin
  BS:=Chr(8);
  Repeat
    B:=Pos(BS,InStr);
    If B=1 then Delete(InStr,B,1);
    If B>1 then Delete(InStr,B-1,2);
  Until B=0;
End;

FUNCTION Real_Val( St: Str255): Real;
Const Max_Digits=9;

Var
  Dec_Exp,
  Exp_Value,
  Count,
  Position:     Integer;
  Chr:          Char;
  Result:       Real;
  Dec_Sign,
  Exp_Sign:     Boolean;

  PROCEDURE Add_Digit;

  Begin
    Result := (Result * 10) + (Ord(Chr) & $0F);
  End;

  PROCEDURE Read_Chr;
  Begin
    Position := Position + 1;
    If Position > Length(St) Then
      Chr := 'X'
    Else
      Chr := St[Position];
  End;

Begin { Real_Val }
  Kill_BS(St);
  Position := 0;
  Read_Chr;
  Result := 0.0;

{ Get sign }

  Dec_Sign := False;
  If Chr = '+' Then Read_Chr;
  If Chr = '-' Then
  Begin
    Read_Chr;
    Dec_Sign := True;
  End;

{ Get digits to left of decimal point }

  Dec_Exp := 0;
  Count := Max_Digits;
  While ('0' <= Chr) And (Chr <= '9') Do
  Begin
    If Count > 0 Then
    Begin
      Add_Digit;
      Count := Count - 1;
    End
    Else
     Dec_Exp := Dec_Exp + 1;
    Read_Chr;
  End;

{ Get digits to the right of decimal point }

  If Chr = '.' Then
  Begin
    Read_Chr;
    While ('0' <= Chr) And (Chr <= '9') Do
    Begin
      If Count > 0 Then
      Begin
        Add_Digit;
        Dec_Exp := Dec_Exp - 1;
        Count := Count - 1;
      End;
      Read_Chr;
    End
  End;

{ Get exponent part }

  If (Chr = 'E') Or (Chr = 'e') Then
  Begin
    Read_Chr;
    Exp_Sign := False;
    If Chr = '+' Then Read_Chr;
    If Chr = '-' Then
    Begin
      Read_Chr;
      Exp_Sign := True;
    End;
    Exp_Value := 0;
    If ('0'<=Chr) And (Chr<='9') Then Exp_Value := (Ord(Chr) & $0F)*10;
    Read_Chr;
    If ('0'<=Chr) And (Chr<='9') Then Exp_Value := Exp_Value+(Ord(Chr) & $0F);
    If (Chr = 'X') And (Exp_Value >= 10) Then Exp_Value:= Exp_Value Div 10;
    If Exp_Sign Then
      Dec_Exp := Dec_Exp - Exp_Value
    Else
      Dec_Exp := Dec_Exp + Exp_Value;
  End;
  If Dec_Exp > 0 Then
    Result := Result * PwrOfTen(Dec_Exp)
  Else
    Result := Result / PwrOfTen(Abs(Dec_Exp));
  If Dec_Sign Then Result:=-Result;
  Real_Val:=Result
End;

Function Val(St: Str255): Integer;
Begin
  Val:=Trunc(Real_Val(St))
End;

Function Long_Val(St: Str255): Long_Integer;
Begin
  Long_Val:=Long_Trunc(Real_Val(St))
End;


