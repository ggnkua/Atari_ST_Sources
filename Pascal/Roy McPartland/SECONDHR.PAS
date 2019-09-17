~~~~~~~~~~~~~~~~');
         DELAY (3000);
     END;
PROCEDURE Calculate_Points; {Calculates the total points by multiplying the
                              amount of wins in each category by the
                              appropiate figure                             }
     BEGIN
         Total_Points := (Home_Win) + (Away_Win * 1.5) + (No_Scr_Draw * 2) + (Score_Draw * 3);
     END;

PROCEDURE Calculate_Categories;   {If the home team's score is more than or is equal to 0 the
                                   program asks the user for the way team's score}
     BEGIN
          IF Home_Team_Scr < 0 THEN
             BEGIN {Begining of loop}
                  GOTOXY (31,12);
                  WRITELN ('End of Entries');
                  DELAY (700);
             END; {End of loop}
          IF Home_Team_Scr >= 0 THEN
             BEGIN {Start of loop}
                  GOTOXY (21,6);
                  WRITE ('Now enter the away teams score  ');
                  READLN (Away_Team_Scr);
                  GOTOXY (31,12);  {Screen area to display answer}
                  IF Home_Team_Scr > Away_Team_Scr THEN
                     BEGIN {Start of sub loop}
    