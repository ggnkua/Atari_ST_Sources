PROGRAM Series_of_Numbers;

{       This program uses a loop to add together
        the sums of consecutive numbers, e.g.
        (1+2)+3... until the series reaches a
        user definable number of terms in the
        series. Written by Pete Bala 15/10/91
        Saved on diskette as SUMTERMS.PAS          }

USES
    CRT;

VAR
    Sum,Count,Input_Number : Integer;

BEGIN {Main program};
    WRITELN ('Please enter number of term in series');
    READLN (Input_Number);
    Sum :=0;
    Count :=1;
     REPEAT
      Sum := Sum + Count;
      Count := Count + 1;
     UNTIL (Count = Input_Number + 1);
    WRITELN  ('The sum of ',Input_Number,' terms equals ',Sum);
END.