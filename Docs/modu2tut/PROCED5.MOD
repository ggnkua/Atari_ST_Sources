                                         (* Chapter 5 - Program 5 *)
MODULE Proced5;

FROM InOut IMPORT WriteString, WriteLn;

PROCEDURE One;
BEGIN
   WriteString("This is procedure One.");
   WriteLn;
END One;

PROCEDURE Two;
BEGIN
   One;
   WriteString("This is procedure Two.");
   WriteLn;
END Two;

PROCEDURE Three;
BEGIN
   Two;
   WriteString("This is procedure Three.");
   WriteLn;
END Three;

BEGIN   (* Main program *)
   One;
   WriteLn;
   Two;
   WriteLn;
   Three;
   WriteLn;
END Proced5.
