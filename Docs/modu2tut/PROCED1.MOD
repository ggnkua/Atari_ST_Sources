                                         (* Chapter 5 - Program 1 *)
MODULE Proced1;

FROM InOut IMPORT WriteString, WriteLn;

VAR Count : INTEGER;

PROCEDURE WriteHeader;
BEGIN
   WriteString("This is the header");
   WriteLn;
END WriteHeader;

PROCEDURE WriteMessage;
BEGIN
   WriteString("This is the message");
   WriteLn;
END WriteMessage;

PROCEDURE WriteEnding;
BEGIN
   WriteString("This is the end");
   WriteLn;
END WriteEnding;

BEGIN        (* Main program *)
   WriteHeader;
   FOR Count := 1 TO 8 DO
      WriteMessage;
   END;
   WriteEnding;
END Proced1.
