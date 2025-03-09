(******************************************************************)
(* Beispielprogramm zur einfachen Fixpunktiteration in            *)
(* in mehreren Unbekannten.                                       *)
(* -------------------------------------------------------------- *)
(* Entwickelt mit SPC Modula 2.                        20.02.1989 *)
(* (c) MAXON Computer GmbH                                        *)
(******************************************************************)

(* --------- + ---------------- *)
(* Listing 4 /  by D. Rabich    *)
(* --------- + ---------------- *)

MODULE FixpunktIteration;

(* Importe *)
FROM InOut IMPORT WriteReal,WriteCard,WriteLn,WriteString,Read;

(* Konstanten *)
CONST FloatFehler = 1.0E-6;
      MaxDim      =  3;
      MaxCount    = 50;
  
(* Typ *)
TYPE Vektor = ARRAY [1..MaxDim] OF REAL;

(* Variablen *)
VAR VoidChar : CHAR;
    x,y      : Vektor;
    Counter  : CARDINAL;
 
(* Funktion F(x,y,z) *) 
PROCEDURE F (x : Vektor; VAR y : Vektor); 

 BEGIN
  y[1]:=x[2]*x[3]/6.0;
  y[2]:=5.0*x[1]-3.0;
  y[3]:=x[1]*x[2]*x[3]/2.0
 END F;
 
(* Maximaler Abstand der Vektorkomponenten *) 
PROCEDURE MaxAbsV (x,y : Vektor) : REAL;

 VAR i         : CARDINAL;
     MaxV,Help : REAL;
 
 BEGIN
  MaxV:=0.0;
  FOR i:=1 TO MaxDim DO
   Help:=ABS(x[i]-y[i]);
   IF Help>MaxV THEN
    MaxV:=Help
   END
  END;
  RETURN MaxV
 END MaxAbsV;
 
BEGIN

 Counter:=0;

 (* Startwerte *)
 x[1]:=1.0;
 x[2]:=1.8;
 x[3]:=3.2;
 
 LOOP
  F(x,y);
  IF (MaxAbsV(x,y)<FloatFehler) OR (Counter>MaxCount) THEN
   EXIT
  END;
  INC(Counter);
  x:=y
 END;
 
 IF Counter<=MaxCount THEN
  WriteString('Iterationsschritte:');
  WriteCard(Counter,5);
  WriteLn;
  WriteString('Fixpunkt:');
  WriteLn;
  WriteReal(y[1],12,8);
  WriteLn;
  WriteReal(y[2],12,8);
  WriteLn;
  WriteReal(y[3],12,8);
  WriteLn
 END;
  
 Read(VoidChar)
END FixpunktIteration.
  
 
    

