(* This program is actually a very silly program with little or    *)
(* no utilitarian value.  It is valuable as an illustration of a   *)
(* method of implementing a menu for selection purposes.  Notice   *)
(* when you run it, that the response to your input is immediate   *)
(* No "return" is required.                                        *)

MODULE Areas;

FROM InOut IMPORT Read, WriteString, Write, WriteLn;
FROM RealInOut IMPORT WriteReal, ReadReal;

VAR InChar, CapInChar : CHAR;

(* ************************************************** AreaOfSquare *)
PROCEDURE AreaOfSquare;
VAR Length, Area : REAL;
BEGIN
   WriteString("Square    Enter length of a side ");
   ReadReal(Length);
   Area := Length * Length;
   WriteLn;
   WriteString("The area is ");
   WriteReal(Area,15);
   WriteLn;
END AreaOfSquare;

(* *********************************************** AreaOfRectangle *)
PROCEDURE AreaOfRectangle;
VAR Width, Height, Area : REAL;
BEGIN
   WriteString("Rectangle    Enter Width ");
   ReadReal(Width);
   WriteLn;
   WriteString("Enter Height ");
   ReadReal(Height);
   Area := Width * Height;
   WriteString("      The area is ");
   WriteReal(Area,15);
   WriteLn;
END AreaOfRectangle;

(* ************************************************ AreaOfTriangle *)
PROCEDURE AreaOfTriangle;
VAR Base, Height, Area : REAL;
BEGIN
   WriteString("Triangle    Enter base ");
   ReadReal(Base);
   WriteLn;
   WriteString("Enter height ");
   ReadReal(Height);
   Area := 0.5 * Base * Height;
   WriteString("      The area is ");
   WriteReal(Area,15);
   WriteLn;
END AreaOfTriangle;

(* ************************************************** AreaOfCIrcle *)
PROCEDURE AreaOfCircle;
VAR Radius, Area : REAL;
BEGIN
   WriteString("Circle      Enter Radius ");
   ReadReal(Radius);
   WriteLn;
   Area := 3.141592 * Radius * Radius;
   WriteString("The area is ");
   WriteReal(Area,15);
   WriteLn;
END AreaOfCircle;

(* ************************************************** Main Program *)
BEGIN
   REPEAT
      WriteLn;
      WriteString("You only need to input the first letter ");
      WriteString("of the selection.");
      WriteLn;
      WriteString("Select shape; Square Rectangle Triangle ");
      WriteString("Circle Quit");
      WriteLn;
      WriteString("Requested shape is ");
      Read(InChar);
      CapInChar := CAP(InChar);           (* Get capital of letter *)
      CASE CapInChar OF
        'S' : AreaOfSquare; |
        'R' : AreaOfRectangle; |
        'T' : AreaOfTriangle; |
        'C' : AreaOfCircle; |
        'Q' : WriteString("Quit    Return to DOS");
              WriteLn;
      ELSE
         Write(InChar);
         WriteString(" Invalid Character ");
         WriteLn;
      END;
   UNTIL CapInChar = 'Q';
END Areas.
