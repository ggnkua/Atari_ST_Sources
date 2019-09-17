PROGARM VAT Reckoner
                   { SA1MPY.PAS written by Pete Younger 13/11/91
                     amended by ?????????? ??/??/??.
                     This program prompts the user to enter the cost of
                     an item before VAT.  The VAT is calculated and added
                     for output.                                         }

USES
   CTR;

VARS
   InputCost        :REAL;
   CalcVat          :REAL;
   CalcTot          :REAL:

PROCEDURE InputData;
   BEGIN
          CLRSCR;
          WRITELN('VAT Reckoner');
          WRITELN;
          WRITELN('Input cost of item.);
          WRITE  ('VAT will be added ');
          WRITELN('at standard rate - 17.5%');
          WRITELN;
          WRITE  ('Enter cost of item - œ');
          READLN(InputCost);
    END;

PROCEDURE CalcAnswers;
   BEIN
          CalcVat := InputCost * 0.175;
          CalcTot := InputCost + CalVat
   END;

PROCEDURE OutputAnswer;
   BEGIN
          WRITELN;
          WRITELN ('Original price - œ',InputCost:6:2);
          WRITELN ('+ VAT @ 17.5%  - œ ,CalcVat:6:2);
          WRITELN ('                  ------')
          WRITELN ('= Total cost   - œ',CalcTot:6:2
   END;

BEGIN
   InputData;
   CalcAnswers;
   OutputAnswers
.
