PROGRAM Array_Example;
{       A program to enter the exam marks
        of 10 students and then display
        the marks on the screen               }

VAR   Marks : ARRAY [1..10] OF INTEGER;
      Count : INTEGER; {Loop counter}

PROCEDURE InputMarks;
     BEGIN
         WRITELN ('Please enter the students marks');
         FOR Count := 1 TO 10 DO
             BEGIN
                 READLN (Marks[Count]);
             END;
     END;

PROCEDURE DisplayMarks;
     BEGIN
         FOR Count := 1 TO 10 DO
             BEGIN
                  WRITELN (Count:3,'     ',Marks [Count]:4);
             END;
     END;

BEGIN
    InputMarks;
    DisplayMarks;
END.



















