Procedure FixReal(Var RealTotal : Real; DecPlaces : Byte);
{******************************************************************************
**                                                                           **
**                       Procedure RealTotal                                 **
**                                                                           **
**        Purpose : To correct Real Number Errors by rounding them off to a  **
**                  specified accuracy/decimal point.                        **
**                                                                           **
**        Passed  : RealTotal - VAR Real number passed to routine to adjust  **
**                  DecPlaces - Integer degree to "FIX" the passed number    **
**                                                                           **
**                  Written by : Stewart J Dimon, c1986                      **
******************************************************************************}

Var

    I        : Integer;
    Decimals : Real;

Begin
    If (DecPlaces > 0) Then
        Begin
            Decimals := 1.0;
            For I := 1 to DecPlaces Do
                Decimals := 10.0 * Decimals;
            RealTotal := RealTotal * Decimals;
            RealTotal := Round(RealTotal);
            RealTotal := Trunc(RealTotal);
            RealTotal := RealTotal/Decimals;
        End; {If DecPlaces > 0}
End; {Procedure FixReal}
