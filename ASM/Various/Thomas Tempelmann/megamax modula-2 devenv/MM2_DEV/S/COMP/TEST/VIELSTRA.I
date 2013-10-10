
IMPLEMENTATION MODULE Vielstrahlinterferenz;

FROM MathLib0 IMPORT sin,cos,pi;


PROCEDURE MultVV2C (A,B: Vector2C): Complex;
BEGIN
  RETURN Complex
         {
          A[0].Re*B[0].Re + A[1].Re*B[1].Re - A[0].Im*B[0].Im - A[1].Im*B[1].Im,
          A[0].Re*B[0].Im + A[1].Re*B[1].Im + A[0].Im*B[0].Re + A[1].Im*B[1].Re
         }
END MultVV2C;

PROCEDURE MultMM2C (A,B: Matrix2C): Matrix2C;
BEGIN
  RETURN Matrix2C
         {
           MultMV2C (A,B[0]),
           MultMV2C (A,B[1])
         }
END MultMM2C;

PROCEDURE MultMV2C (M: Matrix2C; V: Vector2C): Vector2C;
BEGIN
  RETURN Vector2C
         {
           MultVV2C ( Vector2C{ M[0,0] , M[1,0] } , V),
           MultVV2C ( Vector2C{ M[0,1] , M[1,1] } , V)
         }
END MultMV2C;




(* Berechnung der Einzelnen Matrizen aus den Stoffeigenschaften: *)

(* öbergangsmatrix H: *)
PROCEDURE GetH (tau,rho: LONGREAL): Matrix2C;
BEGIN
  RETURN Matrix2C
         {
           Vector2C { Complex{1.0/tau , 0.0} , Complex {rho/tau , 0.0} },
           Vector2C { Complex{rho/tau , 0.0} , Complex {1.0/tau , 0.0} }
         }
END GetH;

(* Ausbreitungsmatrix L: *)


(* Das RETURN fÅhrt zum AufhÑngen des Compilers!!!*)
PROCEDURE GetL (n,d,lambda0: LONGREAL): Matrix2C;
  VAR beta,Sinus,Cosinus: LONGREAL;
BEGIN
  beta := 2.0*pi*n*d/lambda0;
  Sinus := sin(beta);
  Cosinus := cos(beta);
  
  RETURN Matrix2C
         {
           Vector2C { Complex { Cosinus , -Sinus } , Zero },
           Vector2C { Zero , Complex { Cosinus ,  Sinus } }
         }
END GetL;
(**)

(* Interner Fehler:
PROCEDURE GetL (n,d,lambda0: LONGREAL): Matrix2C;
  VAR beta,Sinus,Cosinus: LONGREAL;
      L: Matrix2C;
BEGIN
  beta := 2.0*pi*n*d/lambda0;
  Sinus := sin(beta);
  Cosinus := cos(beta);
  
  L := Matrix2C
       {
         Vector2C { Complex { Cosinus , -Sinus } , Zero },
         Vector2C { Zero , Complex { Cosinus ,  Sinus } }
         (* Fehler :     ^ *)
       };
  RETURN L
END GetL;
*)

(* Interner Fehler:
PROCEDURE GetL (n,d,lambda0: LONGREAL): Matrix2C;
  VAR beta,Sinus,Cosinus: LONGREAL;
      L: Matrix2C;
BEGIN
  beta := 2.0*pi*n*d/lambda0;
  Sinus := sin(beta);
  Cosinus := cos(beta);
  
  L[0] := Vector2C { Complex { Cosinus , -Sinus } , Zero };
  L[1] := Vector2C { Zero , Complex { Cosinus ,  Sinus } };
                       (* ^ *)
  RETURN L
END GetL;
*)

(* Funktioniert:
PROCEDURE GetL (n,d,lambda0: LONGREAL): Matrix2C;
  VAR beta,Sinus,Cosinus: LONGREAL;
      L: Matrix2C;
BEGIN
  beta := 2.0*pi*n*d/lambda0;
  Sinus := sin(beta);
  Cosinus := cos(beta);
  
  L[0] := Vector2C { Complex { Cosinus , -Sinus } , Zero };
  L[1,0] := Zero;
  L[1,1] := Complex { Cosinus ,  Sinus };
  
  RETURN L
END GetL;
*)



END Vielstrahlinterferenz.

