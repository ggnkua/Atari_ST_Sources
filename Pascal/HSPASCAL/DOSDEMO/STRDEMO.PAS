Program StrDemo;

{ This small program demonstrates how to use one of the new }
{ features in the UTILUNIT.PAS file                         }

Uses UtilUnit;

Var
        R : Real;

Begin
  Write('Enter a number: '); ReadLn(R);

  { All output to the StrOut file is stored in the string StrData. }
  Write(StrOut,R :20:10);

  { StrData now contains the entered number. }
  { Including the formatting spaces. }
  Writeln('You entered: ',StrData);
End.
