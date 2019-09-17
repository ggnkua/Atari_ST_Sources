PROGRAM Pool_Draws;
{       This program, written by Roy McPartland,
        is to help in checking Football Pools
        entries. The user is invited to type in
        the goals scored by each team in a match.
        The computer decides which of four categories
        the result falls in and the decision is output.
        The program then prompts the user for next matches'
        scores. This continues until a negative number is
        entered. At that stage the program will output 6
        pieces of infomation, then end.                       }

USES
    CRT;

VAR
     Home_Team_Scr         : Integer;   {Variable for the home team's score}
     Away_Team_Scr         : Integer;   {Variable for the away team's score}
     Home_Win              : Real;      {The home team win counter variable}
     Away_Win              : Real;      {The likewise away win variable}
     Score_Draw            : Real;      {As above, but for score draws}
     No_Scr_Draw           : Real;      {Again as above, but for no score draws}
     Match_Count           : Real;      {Counts the amount of matches entered}
     Total_Points          : Real;      {Variable for the total points gained}

PROCEDURE Value_Of_Variables;  {States the begining values of variables}
     BEGIN
          Home_Win      := 0;
          Away_Win      := 0;
          Score_Draw    := 0;
          No_Scr_Draw   := 0;
          Home_Team_Scr := 0;
          Match_Count   := 0;
     END;


PROCEDURE Intro_Page; {Displays who wrote the program}
     BEGIN
         CLRSCR;
         GOTOXY (2,0);
         WRITELN ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
         GOTOXY (26,10);
         WRITELN ('P O O L S   C H E C K E R');
         GOTOXY (26,11);
         WRITELN ('~~~~~~~~~~~~~~~~~~~~~~~~~');
         GOTOXY (63,23);
         WRITELN ('By Roy McPartland');
         GOTOXY (1,24);
         WRITELN ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
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
                          Home_Win := Home_Win + 1;
                          WRITELN ('Home win');
                     END;  {End of sub loop}
                  IF Home_Team_Scr < Away_Team_Scr THEN
                     BEGIN
                         Away_Win := Away_Win + 1;
                         WRITELN ('Away win');
                     END;
                  IF Home_Team_Scr + Away_Team_Scr = 0 THEN
                     BEGIN
                         No_Scr_Draw := No_Scr_Draw + 1;
                         WRITELN ('No score draw');
                     END;
                  IF (Home_Team_Scr = Away_Team_Scr) AND (Home_Team_Scr > 0) THEN
                     BEGIN
                         Score_Draw := Score_Draw + 1;
                         WRITELN ('Score draw');
                     END;
                  Match_Count := Match_Count + 1;
                  DELAY (700);  {Holds the answer on screen for 7/10s of a second}
             END; {End of loop}
     END;

PROCEDURE Input_The_Scores;  {Allows user to enter the teams' results}
     BEGIN
          WHILE Home_Team_Scr >= 0 DO
                BEGIN {Begining of loop}
                     CLRSCR;
                     GOTOXY (26,1);
                     WRITELN ('FOOTBALL POOLS CHECKER');
                     GOTOXY (26,2);
                     WRITELN ('**********************');
                     GOTOXY (20,4);
                     WRITE ('Please enter the home teams score  ');
                     READLN (Home_Team_Scr);   {User enters the home team's score}
                     Calculate_Categories;   {Calls the preceding procedure of that name}
                END; {End of loop}
     END;

PROCEDURE Display_Categories;
     BEGIN
         Calculate_Points; {Calls the preceding procedure of that name}
         CLRSCR;
         GOTOXY (2,0);
         WRITE ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
         GOTOXY (19,6);
         WRITELN ('From a total number of matches of ',Match_Count:3:0);
         GOTOXY (24,10);
         WRITELN (Home_Win:5:0,' were home wins');
         GOTOXY (24,11);
         WRITELN (Away_Win:5:0,' were away wins');
         GOTOXY (24,12);
         WRITELN (No_Scr_Draw:5:0,' were no score draws');
         GOTOXY (24,13);
         WRITELN (Score_Draw:5:0,' were score draws');
         GOTOXY (18,17);
         WRITELN ('Giving a total number of points of ',Total_Points:4:1);
         GOTOXY (1,24);
         WRITE ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
     END;

BEGIN   { Main program starts here }
     Value_Of_Variables;   {Call the variable stating procedure}
     Intro_Page;           {Display the 'Welcome message'}
     Input_The_Scores;     {Calls the inputting procedure}
     Display_Categories;   {Displays the final answers}
END.   { End of main program }


{                      STRUCTURE OF PROGRAM

      State the value of the variables. Display the welcome screen.
     Ask the user to input the home team's score.  If this score if
      less than 0 call the result table making procedure.  If the
  home team's score is more than 0 or is equal to 0 call the procedure
     that ask for the away team's score.  This procedure will also
    calculate what category of result has been entered, display the
      appropiate answer, adds 1 to the appropiate variable, e.g.
       Home_Win for a home win, and adds 1 to the match counter.
      The computer then calls up the result table procedure which
   immediately callls up the procedure that calculates the total amount
    of points gained from the matches entered.  It then returns to the
   result procedure, displays the proper answers and quits to the main
   program.  As there are no more procedures to 'run' the main program
                             ends itself.                                     }