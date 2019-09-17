PROGRAM QUIZ;
      {  Program asks user to enter name and 5 quiz scores and then display
         info on screen. Started on disk as Quiz Sco. PAS                   }

 USES   CRT;

VAR     Name: String [20];
         Score1, Score2, Score3, Score4, Score5 : INTEGER;

PROCEDURE EnterName;
     BEGIN
       WRITELN('Please enter students name');
       WRITELN('Up to maximum of 20 letters');
       READLN (Name);
       CLRSCR;
     END;

PROCEDURE EnterScores;
     BEGIN
       WRITELN('Please enter 5 quiz scores');
       READLN(Score1, Score2, Score3, Score4, Score5);
       CLRSCR;
     END;

PROCEDURE DisplayInfo;
     BEGIN
       WRITELN('Students Name',   ',   ', Name);
       WRITELN('Quiz Scores  ', Score1,'  ',Score2,'  ',Score3);
       WRITELN( Score4,'  ',Score5);
     END;

PROCEDURE CalculateAverage;
     BEGIN
       WRITELN('Average');
       WRITELN((Score1+Score2+Score3+Score4+Score5)/5:8:2);
     END;

    BEGIN {Main Program}
      CLRSCR;
      EnterName;
      EnterScores;
      DisplayInfo;
      CalculateAverage;
    END.

