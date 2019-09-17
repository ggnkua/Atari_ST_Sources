PROGRAM Dart_Scores;

USES
    CRT;

VAR
    Players_Name : String [25];
    Raw_Score    : Integer;

PROCEDURE Input_Data;
     BEGIN
          CLRSCR;
          WRITELN ('Please enter the name of the player');
          WRITELN ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
          READLN (Players_Name);
          WRITELN ('Now enter their score');
          WRITELN ('~~~~~~~~~~~~~~~~~~~~~');
          READLN (Raw_Score);
     END;

PROCEDURE Weird_Calculations;
     BEGIN
         IF Raw_Score > 499 THEN Raw_Score := Raw_Score + 100;
         IF Raw_Score MOD 10 = 0 THEN Raw_Score := Raw_Score + 50;
         IF Raw_Score MOD 10 = 5 THEN Raw_Score := Raw_Score + 25;
     END;

PROCEDURE Display_Scores;
     BEGIN
         CLRSCR;
         GOTOXY (10,20);
         WRITELN ('You  have scored ',Raw_Score:4,' ',Players_Name);
     END;

BEGIN
      Input_Data;
      Weird_Calculations;
      Display_Scores;
END.
