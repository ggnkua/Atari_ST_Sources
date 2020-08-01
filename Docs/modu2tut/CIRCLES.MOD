                                        (* Chapter 13 - Program 3 *)
IMPLEMENTATION MODULE Circles;

PROCEDURE GetPi(VAR Pi : REAL);
BEGIN
   Pi := 3.14159;
END GetPi;

PROCEDURE AreaOfCircle(Radius : REAL; VAR Area : REAL);
VAR Pie : REAL;
BEGIN
   GetPi(Pie);
   Area := Pie * Radius * Radius;
END AreaOfCircle;

PROCEDURE PerimeterOfCircle(Radius : REAL; VAR Perim : REAL);
VAR Cake : REAL;
BEGIN
   GetPi(Cake);
   Perim := 2.0 * Cake * Radius;
END PerimeterOfCircle;

BEGIN            (* IMPLEMENTATION MODULE body, empty in this case *)
END Circles.
