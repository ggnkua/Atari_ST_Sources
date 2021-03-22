
DEFINITION MODULE Vielstrahlinterferenz;

(* 5.5.91 Gerd Castan
 * nach Klein, Furtak: Optik, Kapitel 5.4: Vielstrahlinterferenz.
 *
 * Schreibweise:
 *   H      : šbergangsmatrix;
 *   L      : Ausbreitungsmatrix;
 *   tau    : Transmissionskoeffizient;
 *   rho    : Reflexionskoeffizient;
 *   lambda0: Wellenl„nge im Vakuum;
 *   n      : Brechungsindex;
 *   d      : Schichtdicke;
 *)


(* Grundlegende Datentypen und Mathematische Operationen: *)

TYPE Complex = RECORD
                 Re: LONGREAL;
                 Im: LONGREAL
               END;
     
     Vector2C = ARRAY [0..1] OF Complex;
     
     Matrix2C = ARRAY [0..1] OF Vector2C;

CONST Zero = Complex { 0.0 , 0.0 };     (* ISO-Modula 2 *)
      One  = Complex { 1.0 , 0.0 };

PROCEDURE MultMM2C (A,B: Matrix2C): Matrix2C;     (* ISO-Modula 2 *)

PROCEDURE MultMV2C (M: Matrix2C; V: Vector2C): Vector2C;



(* Berechnung der Einzelnen Matrizen aus den Stoffeigenschaften: *)

(* šbergangsmatrix H: *)
PROCEDURE GetH (tau,rho: LONGREAL): Matrix2C;

(* Ausbreitungsmatrix L: *)
PROCEDURE GetL (n,d,lamda0: LONGREAL): Matrix2C;




END Vielstrahlinterferenz.

