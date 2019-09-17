PROGRAM Fibonacci_Numbers;

USES
    CRT;

VAR
    A : INTEGER;
    B : INTEGER;
    C : INTEGER;
    COUNT : INTEGER;
    FILBON : INTEGER;

BEGIN
     CLRSCR;
     COUNT := 0;
     WRITELN ('Please enter the amount of Fibonacci numbers');
     READLN (FILBON);
     A := 1;
     B := 1;
     C := A + B;
     REPEAT
     CLRSCR;
     WRITE (A:2,' + ',B:2,' = ',C:2);
     DELAY (1000);
     C := A + B;
     A := B;
     B := C;
     C := A + B;
     COUNT := COUNT + 1;
     UNTIL COUNT = FILBON;
end.