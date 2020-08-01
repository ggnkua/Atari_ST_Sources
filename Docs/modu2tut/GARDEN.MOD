                                        (* Chapter 13 - Program 4 *)
MODULE Garden;

FROM InOut IMPORT WriteString, WriteLn;
FROM RealInOut IMPORT WriteReal;
FROM Circles IMPORT AreaOfCircle, PerimeterOfCircle;

VAR Radius, Area, Circumference : REAL;

BEGIN    (* Main program *)
   Radius := 12.0;
   AreaOfCircle(Radius,Area);
   PerimeterOfCircle(Radius,Circumference);

          (* Calculations complete - output results *)

   WriteString("Radius = ");
   WriteReal(Radius,12);
   WriteString("     Area =");
   WriteReal(Area,12);
   WriteLn;
   WriteString("Circumference = ");
   WriteReal(Circumference,12);
   WriteLn;
END Garden.
