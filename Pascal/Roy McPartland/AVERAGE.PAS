

PROGRAM Quiz;
       {This program asks the user to enter a name and five scores
     then display them on the screen.  Stored on disk as QUIZ.PAS.}

       USES CRT;
       VAR Name:STRING [20];
       Score1,Score2,Score3,Score4,Score5:INTEGER;
       AV_SCORE:REAL;

PROCEDURE EnterName;

BEGIN
       WRITELN ('Please Enter Students Name');
       WRITELN ('Up to a maximum of 20 letters');
       READLN (Name);
       CLRSCR;
END;

PROCEDURE EnterScores;
BEGIN
       WRITELN ('Please Enter Five Scores');
       READLN  (Score1,Score2,Score3,Score4,Score5);

CLRSCR;
END;

PROCEDURE Calculated;
BEGIN
      AV_SCORE:= ( Score1 + Score2 + Score3 + Score4 + Score5) / 5;

END;

PROCEDURE  DisplayInformation;
BEGIN
     WRITELN('STUDENTS NAME      ',Name);
     WRITELN('QUIZ SCORES        ',Score1,'  ',Score2,'  ',Score3);
     WRITELN( Score4,'  ',Score5);
     WRITELN('AVERAGE SCORE :' ,AV_SCORE:8:2);
END;

BEGIN {Main program }
      CLRSCR;
      EnterName;
      EnterScores;
      Calculated;
      DisplayInformation;
END.
