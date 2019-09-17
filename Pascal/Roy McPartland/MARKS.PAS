PROGRAM Exam_Marks;

{       Program to input a student's exam
        mark and display the following messages
        Excellent  if the mark's more than 70
        Good  if the mark's between 50 and 70
        Pass  if the mark's between 40 and 49
        Fail  if the mark is less than 40
        Written by Roy Mc P, who's here today
        13/11/91.                                   }

USES
    CRT;

VAR
      Input_Score    :   Integer;

PROCEDURE Input_Marks;
     BEGIN
         CLRSCR;
         WRITELN ('Please enter the score achieved');
         READLN (Input_Score);
     END;

PROCEDURE Calculations;
     BEGIN
         IF (Input_Score > 70) THEN WRITE ('Excellent');
         IF (Input_Score < 70) > 50 THEN WRITE ('Good');
         IF (Input_Score < 49) > 40 THEN WRITE ('Pass');
         IF (Input_Score < 40) THEN WRITE (FAIL);
     END;

BEGIN
    Input_Marks;
    Calculations;
END.
