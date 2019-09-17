PROGRAM Economic_Crisis_At_Tention_Point_In_Warrington;

{       This program changes pound sterling
        to either drachma or pesetas using
        the IF..THEN function of this crap
        computer's idea of a good high
        level language, locally known as
        Pascal.  Written by an Atari ST
        owning, homage payer to Jochen
        Hippel (the hippy), Roy Mc
        Partland 5/11/91 (remember,
        remember the fitht of November      }

USES
     CRT;

VAR
      Pound_to_Drac_Pes     : Real;
      Amount_of_Pounds      : Real;
      Amount_When_Exchanged : Real;
      Drach_Pes             : String [50];

 PROCEDURE Input_Data;
     BEGIN
          CLRSCR;
          WRITELN ('Please enter the amount of money in Sterling');
          READLN (Amount_of_Pounds);
          WRITELN ('Do you want to change this amount to Drachmas or Pesetas?');
          READLN (Drach_Pes);
          WRITELN ('How many ',Drach_Pes,' to the pound?');
          READLN (Pound_to_Drac_Pes);
     END;

PROCEDURE Calculationficationism;
     BEGIN
          Amount_When_Exchanged := Amount_of_Pounds * Pound_to_Drac_Pes;
     END;

PROCEDURE Display_the_answer;
     BEGIN
          CLRSCR;
          WRITELN ('You will receive ',Amount_When_Exchanged:3:2,' ',
            Drach_Pes,'s for your œ',Amount_of_Pounds:3:2);
     END;

BEGIN
     Input_Data;
     Calculationficationism;
     Display_the_answer;
END.





